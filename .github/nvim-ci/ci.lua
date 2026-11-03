-- Helpers for check.sh. Loaded with `nvim --headless --cmd "lua dofile(...)"`, i.e. before
-- init.lua, so that the vim.notify() hook below sees every notification.
--
-- Everything meant for the CI is printed as "[nvim-ci] ..." lines. check.sh fails a step when
-- the output has an "[nvim-ci] ERROR" line (or one of Neovim's own error messages) or lacks
-- the "[nvim-ci] done: <check>" line.

local M = {}
_G.NvimCI = M

--- Writes "[nvim-ci] <line>" lines to stderr. (Not with print(): in --headless mode Nvim does
--- not end its messages with a newline, so they would be glued together.)
---@param ... string
local function log(...)
	local lines = {}
	for i = 1, select("#", ...) do
		lines[i] = "[nvim-ci] " .. select(i, ...)
	end
	io.stderr:write("\n" .. table.concat(lines, "\n") .. "\n")
end

local function log_error(msg)
	log("ERROR: " .. msg)
end

-- vim.notify(ERROR) messages have no fixed wording (lazy.nvim's "Failed to run `config` for ...",
-- "Failed to load `plugins.foo`", ...), so tag them. Not while Nvim exits: background jobs are
-- killed then, e.g. mason.nvim reports the installations it aborts as failed. (Errors in
-- VimLeavePre autocmds are still reported by Nvim itself.)
local notify = vim.notify
vim.notify = function(msg, level, opts)
	if level == vim.log.levels.ERROR and vim.v.exiting == vim.NIL then
		log_error("vim.notify: " .. tostring(msg):match("^[^\n]*"))
	end
	return notify(msg, level, opts)
end

--- Processes events (scheduled callbacks, timers, jobs) until `cond` returns true or `ms` passed.
---@param ms integer
---@param cond? fun(): boolean
---@param interval? integer ms between the calls of `cond`
local function wait(ms, cond, interval)
	return vim.wait(ms, cond or function()
		return false
	end, interval or 50)
end

--- Runs `fn` once Neovim has started (after VimEnter), then quits.
---@param fn fun()
local function after_startup(fn)
	local function run()
		local ok, err = xpcall(fn, debug.traceback)
		if not ok then
			log_error(tostring(err))
		end
		vim.cmd("qall!")
	end
	if vim.v.vim_did_enter == 1 then
		vim.schedule(run)
	else
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				vim.schedule(run)
			end,
		})
	end
end

--- Prints where the parsers bundled with Neovim are. Run with `-u NONE` (default 'runtimepath').
function M.info()
	local dirs = {}
	for _, file in ipairs(vim.api.nvim_get_runtime_file("parser/*", true)) do
		dirs[vim.fs.dirname(file)] = true
	end
	local list = vim.tbl_keys(dirs)
	table.sort(list)
	log("parser directories on the default 'runtimepath': " .. (#list > 0 and table.concat(list, ", ") or "none"))
end

--- Reports the plugins that are not installed or have a failed lazy.nvim task
--- (clone, checkout, docs, build, ...).
local function lazy_report()
	local ok, Config = pcall(require, "lazy.core.config")
	if not ok or vim.tbl_isempty(Config.plugins or {}) then
		log_error("lazy.nvim has no plugins (did init.lua fail before require('lazy').setup()?)")
		return
	end
	local Plugin = require("lazy.core.plugin")
	local names = vim.tbl_keys(Config.plugins)
	table.sort(names)
	local missing = {} ---@type string[]
	local failed = {} ---@type table<string, string[]> task name -> plugins
	for _, name in ipairs(names) do
		local plugin = Config.plugins[name]
		if not plugin._.installed then
			missing[#missing + 1] = name
		elseif Plugin.has_errors(plugin) then
			for _, task in ipairs(plugin._.tasks or {}) do
				if task:has_errors() then
					failed[task.name] = failed[task.name] or {}
					table.insert(failed[task.name], name)
				end
			end
		end
	end
	if #missing > 0 then
		log_error("lazy.nvim: not installed: " .. table.concat(missing, ", "))
	end
	local tasks = vim.tbl_keys(failed)
	table.sort(tasks)
	for _, task in ipairs(tasks) do
		log_error(
			("lazy.nvim: task `%s` failed for %d plugin(s): %s"):format(
				task,
				#failed[task],
				table.concat(failed[task], ", ")
			)
		)
	end
	log(("done: sync (%d plugins)"):format(#names))
end

--- Run with -c after `-c "Lazy! sync"`: reports the failed tasks once Nvim has started and quits.
--- (Not with `+qall`: while a -c command runs, Nvim prefixes the error messages printed when
--- it exits, e.g. by mason.nvim aborting its installations, with "Error in command line:".)
function M.sync()
	after_startup(lazy_report)
end

--- Loads every plugin, like a session in which all of them got used.
function M.load_all()
	-- lazy.nvim triggers VeryLazy on UIEnter, which never happens without a UI.
	vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
	local ok, lazy = pcall(require, "lazy")
	if not ok then
		log_error("lazy.nvim is not available")
		return
	end
	if not wait(10000, function()
		return vim.g.did_very_lazy == true
	end) then
		log_error("lazy.nvim did not trigger VeryLazy")
	end

	-- The plugins that still wait for a key, command, filetype, InsertEnter, ...
	local names = {}
	for _, plugin in ipairs(lazy.plugins()) do
		if not plugin._.loaded and plugin._.cond ~= false then
			names[#names + 1] = plugin.name
		end
	end
	table.sort(names)
	if #names > 0 then
		log("loading the remaining plugins: " .. table.concat(names, ", "))
		lazy.load({ plugins = names })
	end

	-- Let scheduled callbacks and timers run: lazy.nvim reports `config` errors with vim.schedule().
	wait(2000)

	local loaded = 0
	for _, plugin in ipairs(lazy.plugins()) do
		loaded = loaded + (plugin._.loaded and 1 or 0)
	end
	log(("plugins loaded: %d of %d"):format(loaded, #lazy.plugins()))
end

--- Start Neovim (with the files given on the command line), load every plugin and quit.
function M.startup()
	after_startup(function()
		M.load_all()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and name ~= "" then
				local clients = vim.tbl_map(function(client)
					return client.name
				end, vim.lsp.get_clients({ bufnr = buf }))
				log(
					("%s: filetype=%s treesitter=%s lsp=%s"):format(
						vim.fn.fnamemodify(name, ":~:."),
						vim.bo[buf].filetype,
						vim.treesitter.highlighter.active[buf] and "yes" or "no",
						#clients > 0 and table.concat(clients, ",") or "-"
					)
				)
			end
		end
		log("done: startup")
	end)
end

--- Names of the mason.nvim packages being installed.
---@return string[]
local function mason_installing()
	local names = {}
	for _, pkg in ipairs(require("mason-registry").get_all_packages()) do
		local busy
		if type(pkg.is_installing) == "function" then -- mason.nvim 2.x
			busy = pkg:is_installing()
		else -- mason.nvim 1.x
			local handle = pkg:get_handle()
			busy = handle:is_present() and not handle:get():is_closed()
		end
		if busy then
			names[#names + 1] = pkg.name
		end
	end
	return names
end

--- mason-lspconfig / mason-null-ls install their packages in the background after startup.
--- Wait for them (as on a machine that has been set up), since none-ls reports a source whose
--- command is not installed (yet) as an error.
---@param timeout integer ms
local function wait_for_mason(timeout)
	if not pcall(require, "mason-registry") then
		return
	end
	local start = vim.uv.hrtime()
	local idle_since, installing, query_err
	local idle = wait(timeout, function()
		local ok, names = pcall(mason_installing)
		if not ok then
			query_err = names
			return true
		end
		installing = names
		if #names > 0 then
			idle_since = nil
			return false
		end
		-- require a few idle seconds: ensure_installed starts installs only after a registry refresh
		idle_since = idle_since or vim.uv.hrtime()
		return vim.uv.hrtime() - idle_since > 3e9
	end, 1000) -- (each check reads mason's whole registry)
	local secs = (vim.uv.hrtime() - start) / 1e9
	if query_err then
		log("mason: could not check for running installations: " .. tostring(query_err))
	elseif idle then
		log(("mason: no installation running (waited %.0fs)"):format(secs))
	else
		-- not an error by itself; a missing tool shows up in the :checkhealth report
		log(("mason: still installing after %.0fs: %s"):format(secs, table.concat(installing or {}, ", ")))
	end
end

---@return integer?
local function health_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf) == "health://" then
			return buf
		end
	end
end

--- Load every plugin (:checkhealth only finds the healthchecks of loaded plugins), run
--- :checkhealth and write the report to `path`.
---@param path string
function M.checkhealth(path)
	after_startup(function()
		M.load_all()
		wait_for_mason(240000)
		log("running :checkhealth")
		vim.cmd("checkhealth")
		-- Nvim 0.12+ runs the healthchecks asynchronously; the report is made 'nomodifiable'
		-- once all of them are done.
		local buf
		local done = wait(300000, function()
			buf = health_buf()
			return buf ~= nil and not vim.bo[buf].modifiable
		end)
		if not buf then
			log_error(":checkhealth did not open its report")
			return
		end
		vim.fn.writefile(vim.api.nvim_buf_get_lines(buf, 0, -1, false), path)
		if not done then
			log_error(":checkhealth did not finish within 300s")
			return
		end
		log("done: checkhealth")
	end)
end

return M
