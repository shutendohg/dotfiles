KEYMAPS

These are the actionable keymaps configured by this Neovim setup.
Only mappings you can press directly are listed (internal <Plug>(…) bindings are omitted).
	•	Leader: <Space>
	•	Modes: n (normal), v (visual), x (visual-select), i (insert), s (select), o (operator-pending)

-

Legend
	•	Mode: where the mapping works.
	•	Keys: the exact keys to press.
	•	Action: what it does.
	•	Plugin/Source: where it comes from (plugin or user config).
	•	Notes: any caveats.

-

By Mode

Normal (n)

Keys	Action	Plugin/Source	Notes
<Esc>	Clear search highlight	User	:nohl
<Space>/	Grep (prompt)	User (ripgrep/Telescope hook)	
<Space>?	Grep word under cursor	User (ripgrep/Telescope hook)	
<Space>*	Repeat-change on next match (*''cgn)	User	Quick multi-replace trick
<Space>sr	Open GrugFar (search & replace UI)	grug-far.nvim	Bottom layout
<Space>fb	File Browser	telescope-file-browser	
<Space>xx	Diagnostics (Trouble)	trouble.nvim	
<Space>xX	Buffer Diagnostics (Trouble)	trouble.nvim	
<Space>xQ	Quickfix List (Trouble)	trouble.nvim	
<Space>xL	Location List (Trouble)	trouble.nvim	
<Space>cl	LSP defs/refs/… hub (Trouble)	trouble.nvim	
<Space>cs	Symbols (Trouble)	trouble.nvim	
<Space>qo	Open quickfix	User	
<Space>qc	Close quickfix	User	
<Space>qn	Next quickfix item	User	
<Space>qp	Prev quickfix item	User	
H / L	Previous / Next buffer	User	
cb	Keep previous buffer & close current (:bp | bd #)	User	
cw	Close window	User	
sl/sj/sk/sl	Window move →/↓/↑/←	User	<C-w> wrapper
ss/sv	Horizontal/Vertical split then focus	User	
<C-P>	Focus previous window	User	
<C-N>	Toggle NvimTree	nvim-tree	
<C-M>	Focus NvimTree	nvim-tree	
gcc	Toggle line comment	Comment.nvim	
gc	Toggle comment (operator)	Comment.nvim	Visual also supported
<C-A> / <C-X>	Increment / Decrement	dial.nvim	Numbers/dates etc.
gx	Open URL/path with system handler	Built-in Lua	
Y	Yank to end of line	User	y$
?	vimgrep current buffer → open quickfix	User	Populate latest search
[<Space>] / ]`	Insert empty line above/below	User	
[d / ]d	Prev / Next diagnostic	LSP	
[D / ]D	First / Last diagnostic	LSP	
gO	Document symbols	LSP	
gri	Go to implementation	LSP	
grr	Find references	LSP	
gra	Code action	LSP	Operator & Visual too
grn	Rename	LSP	
<C-w>d / <C-w><C-d>	Show diagnostics under cursor	LSP	
<C-L>	Clear hlsearch, update diff, redraw	User	Extended clear
%, g%, [%, ]%	Match pairs/tags	matchit (built-in pkg)	Also works in o/v
&	Repeat :s with g flag	Default	Same as :&&
[B/[b / ]B/]b	Buffers: rewind/prev/last/next	Default	
[T/[t / ]T/]t	Tags: rewind/prev/last/next	Default	
[A/[a / ]A/]a	Args: first/prev/last/next	Default	
[L/[l / ]L/]l	Loclist: first/prev/last/next	Default	
[Q/[q / ]Q/]q	Quickfix: first/prev/last/next	Default	
[<C-L>] / ]<C-L>	Loc prev/next file	Default	:lpfile / :lnfile
[<C-Q>] / ]<C-Q>	Quickfix prev/next file	Default	:cpfile / :cnfile

Visual (v) / Visual-Select (x)

Mode	Keys	Action	Plugin/Source	Notes
v	<Space>c	Copy selection via OSC52	nvim-osc52	Remote → local clipboard
v/x	gc	Toggle comment	Comment.nvim	
v/x	gx	Open URL/path	Built-in Lua	
v/x	a\``, a', a"`	Textobjects (quote pairs)	User	`2i`` etc.
v/x	%, g%, [%, ]%, a%	Match pairs/tags & textobject	matchit	
v	@	Play macro over selection	Default (Lua)	
v	Q	Replay last recorded macro	Default (Lua)	
v	# / *	Search under selection	Default (Lua)	
v/s	<Tab> / <S-Tab>	Snippet jump fwd/back	vim.snippet	If snippet active
v/s	<C-S>	Signature help	LSP	

Insert (i) / Select (s)

Mode	Keys	Action	Plugin/Source	Notes
i/s	<Tab> / <S-Tab>	Snippet jump fwd/back	vim.snippet	If snippet active
i/s	<C-S>	Signature help	LSP	
i	jj	Exit insert (to normal)	User	
i	<C-U>	Custom delete to BOS	User (Lua)	Overrides default
i	<C-W>	Delete word (undo break)	Default	With CTRL-G u

Operator-Pending (o)

Keys	Action	Plugin/Source	Notes
gc	Comment textobject	Comment.nvim	e.g. dgc
%, g%, [%, ]%, a%	Match pairs/tags & textobject	matchit	
a\``, a', a"`	Quote-pair textobjects	User	


-

By Plugin

nvim-osc52 (remote → local clipboard)

Mode	Keys	Action
n	<Space>c	Copy via OSC52
n	<Space>cc	Copy current line via OSC52
v	<Space>c	Copy selection via OSC52

trouble.nvim

Keys	Action
<Space>xx	Diagnostics
<Space>xX	Buffer Diagnostics
<Space>xQ	Quickfix List
<Space>xL	Location List
<Space>cl	LSP defs/refs/etc. hub
<Space>cs	Symbols

grug-far.nvim

Keys	Action
<Space>sr	Search & Replace UI (bottom)

telescope-file-browser

Keys	Action
<Space>fb	File Browser

nvim-tree

Keys	Action
<C-N>	Toggle tree
<C-M>	Focus tree

Comment.nvim

Mode	Keys	Action
n	gcc	Toggle line comment
n/v	gc	Toggle comment (operator/visual)
o	gc	Comment textobject

dial.nvim

Keys	Action
<C-A>	Increment
<C-X>	Decrement

LSP (core)

Mode	Keys	Action
n	gri	Go to implementation
n	grr	References
n/v	gra	Code action
n	grn	Rename
n	gO	Document symbols
n	<C-w>d, <C-w><C-d>	Show diagnostics under cursor
i/s	<C-S>	Signature help
n	[d ]d / [D ]D	Diagnostic prev/next & first/last

matchit (built-in package)

Mode	Keys	Action
n/v/o	%, g%	Jump between pairs/tags
n/v/o	[% / ]%	Multi-pair backward/forward
v/o	a%	Pair textobject

Core / Custom

Mode	Keys	Action
n	<Esc>	Clear hlsearch
n	<Space>/, <Space>?	Grep / Grep word
n	<Space>*	Repeat-change on next match
n	<Space>qo/qc/qn/qp	Quickfix open/close/next/prev
n	H / L	Prev / Next buffer
n	cb / cw	Close buffer window helpers
n	sl/sj/sk/sl	Window move
n	ss/sv	Split & focus
n	<C-P>	Focus previous window
n	gx	Open URL/path
n	Y	Yank to EOL
n	<C-L>	Clear hl + redraw/diff
n	[<Space>] / ]<Space>	Insert blank line


-

Notes
	•	Some default bracket/quickfix/loclist/tag motions (e.g. ]q, [L], …) are kept.
	•	OSC52 copy requires a compatible terminal/tmux setup (already handled in this dotfiles).
	•	dial.nvim increments dates/numbers/etc. contextually.
	•	jj in insert mode exits to normal for faster workflows.

