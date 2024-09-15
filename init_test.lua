-- Copyright 2020-2024 Mitchell. See LICENSE.

local format = require('format')

local have_clang_format = LINUX or OSX and os.getenv('CI') == ''

test('format.code should use clang-format if a .clang-format exists', function()
	local file = 'file.c'
	local dir<close> = test.tmpdir{
		['.clang-format'] = 'BasedOnStyle: LLVM', --
		[file] = 'int main(){return 0;}'
	}
	io.open_file(dir / file)

	format.code()

	test.assert_equal(buffer:get_text(), 'int main() { return 0; }')
end)
if have_clang_format then skip('clang-format is not available') end

test('format.code should not format on save if format.on_save is disabled', function()
	local _<close> = test.mock(format, 'on_save', false)
	local file = 'file.c'
	local code = test.lines{'int main(){return 0;}', ''}
	local dir<close> = test.tmpdir{['.clang-format'] = 'BasedOnStyle: LLVM', file}
	io.open_file(dir / file)
	buffer:append_text(code)

	buffer:save()

	test.assert_equal(buffer:get_text(), code)
end)
if have_clang_format then skip('clang-format is not available') end

test('format.code should ignore saving files matching format.ignore_file_patterns', function()
	local subdir = 'subdir'
	local subfile = 'subfile.c'
	local code = test.lines{'int main(){return 0;}', ''}
	local dir<close> = test.tmpdir{
		['.clang-format'] = 'BasedOnStyle: LLVM', --
		[subdir] = {[subfile] = code}
	}
	local _<close> = test.mock(format, 'ignore_file_patterns', {'/' .. subdir .. '/'})
	io.open_file(dir / (subdir .. '/' .. subfile))

	buffer:save()

	test.assert_equal(buffer:get_text(), code)
end)
if have_clang_format then skip('clang-format is not available') end

test('format.paragraph should reformat the current paragraph', function()
	local _<close> = test.mock(format, 'line_length', 10)
	buffer:append_text('this is a really long line')

	format.paragraph()

	test.assert_equal(buffer:get_text(), test.lines{
		'this is', --
		'a really', --
		'long line', --
		''
	})
end)
if not LINUX then skip('fmt si only installed on Linux') end

test('format.paragraph should only reformat selected lines', function()
	local _<close> = test.mock(format, 'line_length', 10)
	buffer:append_text(test.lines{
		'this is a', --
		'really long', --
		'line'
	})
	buffer:line_down_extend()
	buffer:char_right_extend()

	format.paragraph()

	test.assert_equal(buffer:get_text(), test.lines{
		'this is', --
		'a really', --
		'long', --
		'line'
	})
end)
if not LINUX then skip('fmt si only installed on Linux') end

test('format.paragraph should only reformat the current style (e.g. Lua comments)', function()
	local _<close> = test.mock(format, 'line_length', 10)
	local _<close> = test.tmpfile('.lua', test.lines{
		'local x = 1', --
		'-- This is a really long comment', --
		'local y = 2'
	}, true)
	buffer:line_down()

	format.paragraph()

	test.assert_equal(buffer:get_text(), test.lines{
		'local x = 1', --
		'-- This', --
		'-- is a', --
		'-- really', --
		'-- long', --
		'-- comment', --
		'local y = 2'
	})
end)
if not LINUX then skip('fmt si only installed on Linux') end

test('format.paragraph should ignore header and footer lines (e.g. Doxygen comments)', function()
	local _<close> = test.mock(format, 'line_length', 10)
	local _<close> = test.tmpfile('.c', test.lines{
		'/**', --
		' * This is really long', --
		' */', --
		'int x;'
	}, true)
	buffer:line_down()

	format.paragraph()

	test.assert_equal(buffer:get_text(), test.lines{
		'/**', --
		' * This', --
		' * is', --
		' * really', --
		' * long', --
		' */', --
		'int x;'
	})
end)
if not LINUX then skip('fmt si only installed on Linux') end

-- Coverage tests.

test('format.code should find files like .clang-format in subdirectories', function()
	local subdir = 'subdir'
	local subfile = 'subfile.c'
	local dir<close> = test.tmpdir{
		['.clang-format'] = 'BasedOnStyle: LLVM', --
		[subdir] = {[subfile] = test.lines{'int main(){return 0;}', ''}}
	}
	io.open_file(dir / (subdir .. '/' .. subfile))

	buffer:save()

	test.assert_equal(buffer:get_text(), test.lines{'int main() { return 0; }', ''})
end)
if have_clang_format then skip('clang-format is not available') end

test('format.code should not format without a file like .clang-format', function()
	local file = 'file.c'
	local code = 'int main(){return 0;}'
	local dir<close> = test.tmpdir{[file] = code}
	io.open_file(dir / file)

	format.code()

	test.assert_equal(buffer:get_text(), code)
end)
