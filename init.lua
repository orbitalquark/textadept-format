-- Copyright 2021-2024 Mitchell. See LICENSE.

--- Format/reformat paragraph and code.
--
-- Install this module by copying it into your *~/.textadept/modules/* directory or Textadept's
-- *modules/* directory, and then putting the following in your *~/.textadept/init.lua*:
--
--	require('format')
--
-- There will be an "Edit > Reformat" menu.
--
-- ### Key Bindings
--
-- Windows and Linux | macOS | Terminal | Command
-- -|-|-|-
-- **Edit**| | |
-- Ctrl+Shift+J | ⌘⇧J | ^J | Reformat paragraph
-- @module format
local M = {}

-- Localizations.
local _L = _L
if not rawget(_L, 'Reformat') then
	-- Menu.
	_L['Reformat'] = 'Reformat'
	_L['Code'] = '_Code'
	_L['Paragraph'] = '_Paragraph'
end

--- Helper function that returns whether or not the given config file exists in the current or
-- a parent directory of the current buffer's filename.
local function has_config_file(filename)
	if not buffer.filename then return false end
	local dir = buffer.filename:match('^(.+)[/\\]')
	while dir do
		if lfs.attributes(dir .. '/' .. filename) then return true end
		dir = dir:match('^(.+)[/\\]')
	end
	return false
end

--- Map of lexer languages to string code formatter commands or functions that return such
-- commands.
M.commands = {
	lua = function() return has_config_file('.lua-format') and 'lua-format' or nil end,
	cpp = function() return has_config_file('.clang-format') and 'clang-format -style=file' or nil end,
	go = 'gofmt'
}
M.commands.c = M.commands.cpp

--- Header lines to ignore when reformatting paragraphs.
-- These can be LuaDoc/LDoc or Doxygen headers for example.
M.ignore_header_lines = {'---', '/**'}

--- Prefixes to remap when reformatting paragraphs.
-- This is for paragraphs that have a first-line prefix that is different from subsequent
-- line prefixes. For example, LuaDoc/LDoc comments start with '---' but continue with '--',
-- and Doxygen comments start with '/**' but continue with ' *'.
M.prefix_map = {['/**'] = ' *', ['---'] = '--'}

--- Footer lines to ignore when reformatting paragraphs.
-- These can be Doxygen footers for example.
M.ignore_footer_lines = {'*/'}

--- Patterns that match filenames to ignore when formatting on save.
-- This is useful for projects with a top-level format config file, but subfolder dependencies
-- whose code should not be formatted on save.
M.ignore_file_patterns = {}

--- Whether or not to invoke a code formatter on save. The default value is `true`.
M.on_save = true

--- The maximum number of characters to allow on a line when reformatting paragraphs. The default
-- value is 100.
M.line_length = 100

--- Reformats using a code formatter for the current buffer's lexer language either the selected
-- text or the current paragraph, according to the rules of `textadept.editing.filter_through()`.
-- @see commands
function M.code()
	local command = M.commands[buffer.lexer_language]
	if type(command) == 'function' then command = command() end
	if not command then return end
	local current_dir = lfs.currentdir()
	local dir = (buffer.filename or ''):match('^(.+)[/\\]') or io.get_project_root()
	if dir and dir ~= current_dir then lfs.chdir(dir) end
	textadept.editing.filter_through(command)
	if dir and dir ~= current_dir then lfs.chdir(current_dir) end -- restore
end
events.connect(events.FILE_BEFORE_SAVE, function(filename)
	if not M.on_save then return end
	if filename then
		for _, patt in ipairs(M.ignore_file_patterns) do if filename:find(patt) then return end end
	end
	M.code()
end)

--- Reformats using the Unix `fmt` tool either the selected text or the current paragraph,
-- according to the rules of `textadept.editing.filter_through()`.
-- For styled text, paragraphs are either blocks of same-styled lines (e.g. code comments),
-- or lines surrounded by blank lines.
-- If the first line matches any of the lines in `format.ignore_header_lines`, it is not
-- reformatted. If the last line matches any of the lines in `format.ignore_footer_lines`,
-- it is not reformatted.
-- @see line_length
function M.paragraph()
	if buffer.selection_empty then
		local s = buffer:line_from_position(buffer.current_pos)
		local style = buffer.style_at[buffer.line_indent_position[s]]
		local e = s + 1
		for i = s - 1, 1, -1 do
			if buffer.style_at[buffer.line_indent_position[i]] ~= style then break end
			s = s - 1
		end
		local line = buffer:get_line(s)
		for _, header in ipairs(M.ignore_header_lines) do
			if line:find('^%s*' .. header:gsub('%p', '%%%0') .. '%s*$') then
				s = s + 1
				break
			end
		end
		for i = e, buffer.line_count do
			if buffer.style_at[buffer.line_indent_position[i]] ~= style then break end
			e = e + 1
		end
		line = buffer:get_line(e - 1)
		for _, footer in ipairs(M.ignore_footer_lines) do
			if line:find('^%s*' .. footer:gsub('%p', '%%%0')) then
				e = e - 1
				break
			end
		end
		buffer:set_sel(buffer:position_from_line(s), buffer:position_from_line(e))
	end

	buffer:begin_undo_action()
	local line_num = buffer:line_from_position(buffer.selection_start)
	local prefix = buffer:get_line(line_num):match('^%s*(%p*)')
	if M.prefix_map[prefix] then
		-- Replace the prefix with its mapped prefix.
		local pos = buffer:position_from_line(line_num)
		buffer:set_target_range(pos, pos + #prefix)
		buffer:replace_target(M.prefix_map[prefix])
	end
	local cmd = (not OSX and 'fmt' or 'gfmt') .. ' -w ' .. M.line_length .. ' -c'
	if prefix ~= '' then cmd = string.format('%s -p "%s"', cmd, M.prefix_map[prefix] or prefix) end
	textadept.editing.filter_through(cmd)
	if M.prefix_map[prefix] then
		-- Replace the mapped prefix with its original prefix.
		buffer:set_target_range(buffer.selection_start, buffer.selection_start + #M.prefix_map[prefix])
		buffer:replace_target(prefix)
		buffer.selection_start = buffer.selection_start - #prefix
	end
	buffer:end_undo_action()
end

-- Add menu entry.
local m_edit = textadept.menu.menubar['Edit']
table.insert(m_edit, #m_edit - 1, {
	title = _L['Reformat'], --
	{_L['Code'], M.code}, --
	{_L['Paragraph'], M.paragraph}
})
keys[not OSX and 'ctrl+J' or 'cmd+J'] = M.paragraph

return M
