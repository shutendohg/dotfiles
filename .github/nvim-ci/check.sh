#!/usr/bin/env bash
# Neovim checks of .github/workflows/dotfiles-ci.yml
#
#   check.sh sync     install/update the plugins (:Lazy! sync)
#   check.sh startup  start Nvim with a few files and load every plugin
#   check.sh health   run :checkhealth and check its report
#
# A check fails when Neovim or a plugin reports an error. In --headless mode
# Neovim prints its messages (errors included) to stderr and exits with 0 even
# after an error, so the output is logged and searched for error messages.
# ci.lua, loaded before init.lua, adds "[nvim-ci] ..." lines: errors that have
# no fixed wording, and a "done" line at the end of each check.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo=$(cd -- "$here/../.." && pwd)
# (not in the repo: chezmoi would apply the logs to $HOME)
logdir=${NVIM_CI_LOGDIR:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}/nvim-ci}
mkdir -p "$logdir"

# Like a UTF-8 terminal: `:checkhealth vim.health` reports a C locale and a
# failing `infocmp -L` (no $TERM) as errors.
export LC_ALL=C.UTF-8
export TERM=${TERM:-xterm-256color}

# Like a machine Nvim has run on before: Nvim only lists the 'runtimepath'
# directories that existed at startup, so on a fresh machine nvim-treesitter's
# healthcheck creates its install directory and then reports it as "not in
# runtimepath".
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site"

# Messages that Neovim prints only when something failed:
#   E5113: Lua chunk: ...       any error number
#   Error in .../init.lua:      ("Error detected while processing" before Nvim 0.12)
#   Lua callback: ...           Lua error in an autocmd, keymap, ... ("Error executing lua callback")
#   vim.schedule callback: ...  ("Error executing vim.schedule lua callback")
#   Failed to run `config` ...  lazy.nvim
#   [nvim-ci] ERROR: ...        ci.lua, e.g. for every vim.notify(..., ERROR)
# Not "stack traceback:": vim.deprecate() prints one with its warning.
error_re='(^|[^[:alnum:]_])E[0-9]+: |Error (in |detected while processing |executing )|Lua (:command )?callback:|vim\.schedule callback:|Luv (thread|callback, thread):|Failed to run `|\[nvim-ci\] ERROR'
# Where a message starts. Nvim does not end its messages with a newline in
# --headless mode, so they can be glued to the previous one.
message_start_re='Error (in|detected while processing|executing) |Lua (:command )?callback:|vim\.schedule callback:|Failed to run `'
# git's progress output (lazy.nvim prints it) only goes to the log file
progress_re='(Counting|Compressing|Receiving|Resolving|Enumerating) (objects|deltas): |Updating files: '

check=${1:-}
fail=0

error() { # <message>
	fail=1
	if [ "${GITHUB_ACTIONS:-}" = true ]; then
		local msg=${1//'%'/'%25'}
		msg=${msg//$'\r'/'%0D'}
		echo "::error title=$check::${msg//$'\n'/'%0A'}"
	else
		printf 'ERROR: %s\n' "$1"
	fi
}

group() { # <title>
	if [ "${GITHUB_ACTIONS:-}" = true ]; then echo "::group::$1"; else echo "--- $1"; fi
}

endgroup() {
	if [ "${GITHUB_ACTIONS:-}" = true ]; then echo "::endgroup::"; fi
}

# Runs `nvim --headless` with ci.lua and logs its output to $log; sets $status.
run_nvim() { # <log name> <timeout> <nvim args>...
	local timeout=$2
	log=$logdir/$1.log
	shift 2
	echo "+ nvim --headless $*"
	# stdbuf: lazy.nvim writes its progress to stdout, Nvim its messages to stderr
	{
		timeout --kill-after=30 "$timeout" stdbuf -oL \
			nvim --headless --cmd "lua dofile([[$here/ci.lua]])" "$@" 2>&1 |
			tee "$log" | grep --line-buffered -vE -- "$progress_re"
		status=${PIPESTATUS[0]}
	} || true
	echo
}

# Prints the lines of $log that report an error, only after the first line that
# contains <from> if given (and present).
find_errors() { # [<from>]
	local from=${1:-}
	if [ -n "$from" ] && ! grep -qF -- "$from" "$log"; then
		from=''
	fi
	sed -E -e 's/\x1b\[[0-9;]*[[:alpha:]]//g' -e 's/(.)(\[nvim-ci\] )/\1\n\2/g' "$log" |
		sed -E "/^\[nvim-ci\] /!s/(.)($message_start_re)/\1\n\2/g" |
		awk -v from="$from" 'from == "" || started { print; next } index($0, from) { started = 1 }' |
		grep -E -- "$error_re" || true
}

# Error lines without lazy.nvim's "[plugin] task | " prefix, repeated ones
# counted.
summarize() {
	sed -E 's/^\[[^]]+\] +[[:alnum:]_.-]+ \| //' |
		awk '!($0 in n) { order[++k] = $0 } { n[$0]++ }
			END { for (i = 1; i <= k; i++) print (n[order[i]] > 1 ? n[order[i]] "x " : "") order[i] }'
}

# Fails if Neovim did not exit normally, the check did not get to its end or
# the output (after <from>) has error messages.
check_output() { # <done marker> [<from>]
	local errors
	if [ "$status" -eq 124 ] || [ "$status" -eq 137 ]; then
		error "Neovim did not finish in time (log: $log)"
	elif [ "$status" -ne 0 ]; then
		error "Neovim exited with status $status (log: $log)"
	fi
	if ! grep -qF "[nvim-ci] done: $1" "$log"; then
		error "The check did not finish: no \"[nvim-ci] done: $1\" line in the output"
	fi
	errors=$(find_errors "${2:-}" | summarize)
	if [ -n "$errors" ]; then
		local n
		n=$(wc -l <<<"$errors")
		if [ "$n" -gt 30 ]; then
			errors=$(head -n 30 <<<"$errors")$'\n'"... and $((n - 30)) more lines, see the output above"
		fi
		error "Neovim reported errors:"$'\n'"$errors"
	fi
}

# "<healthcheck> / <section>: <message>" ("<healthcheck>: <message>" if there
# is no section) for each ERROR item of a :checkhealth report (first line of
# the message only).
health_errors() { # <report>
	awk '
		/^=+$/ { header = 1; next }
		header { hc = $0; sub(/:.*/, "", hc); section = ""; header = 0; next }
		/^[^- ].* ~$/ { section = $0; sub(/ ~$/, "", section); next }
		/^- ([^ ]+ )?ERROR( |$)/ {
			msg = $0; sub(/^- ([^ ]+ )?ERROR ?/, "", msg)
			print hc (section == "" ? "" : " / " section) ": " msg
		}
	' "$1"
}

health() {
	local report=$logdir/checkhealth.txt allowlist=$here/health-allowlist.txt
	local errors patterns ignored remaining
	rm -f "$report"
	run_nvim checkhealth 900 -c "lua NvimCI.checkhealth([[$report]])"
	# errors from before the plugins were loaded are the startup check's business
	check_output checkhealth "[nvim-ci] plugins loaded"
	if [ ! -s "$report" ]; then
		error "No :checkhealth report was written"
		return
	fi
	group ":checkhealth report"
	cat "$report"
	endgroup

	errors=$(health_errors "$report")
	patterns=$(grep -Ev '^[[:space:]]*(#|$)' "$allowlist" || true)
	if [ -n "$patterns" ]; then
		ignored=$(grep -E -f <(printf '%s\n' "$patterns") <<<"$errors" || true)
		remaining=$(grep -Ev -f <(printf '%s\n' "$patterns") <<<"$errors" || true)
	else
		ignored='' remaining=$errors
	fi
	if [ -n "$ignored" ]; then
		echo "Ignored :checkhealth errors (${allowlist#"$repo"/}):"
		echo "  ${ignored//$'\n'/$'\n'  }"
	fi
	if [ -n "$remaining" ]; then
		error ":checkhealth reported errors:"$'\n'"$remaining"
	else
		echo ":checkhealth: no errors other than the ignored ones"
	fi
}

main() {
	case $check in
	sync)
		nvim --version | sed -n 1,3p
		# where the parsers bundled with Neovim are (lazy.nvim resets 'runtimepath')
		nvim --headless -u NONE -i NONE --cmd "lua dofile([[$here/ci.lua]])" -c "lua NvimCI.info()" -c qall 2>&1
		echo
		run_nvim sync 900 -c "Lazy! sync" -c "lua NvimCI.sync()"
		check_output sync
		;;
	startup)
		run_nvim startup 300 -c "lua NvimCI.startup()" -o "$repo/README.md" "$repo/dot_config/nvim/init.lua"
		check_output startup
		;;
	health)
		health
		;;
	*)
		echo "usage: $0 sync|startup|health" >&2
		exit 2
		;;
	esac
	exit "$fail"
}

# (can be sourced to test the functions above)
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	main
fi
