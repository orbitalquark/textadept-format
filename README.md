# Format

Format/reformat paragraph and code.

Install this module by copying it into your *~/.textadept/modules/* directory or Textadept's
*modules/* directory, and then putting the following in your *~/.textadept/init.lua*:

    require('format')

There will be an "Edit > Reformat" menu. You can also assign a keybinding:

    keys['ctrl+alt+j'] = require('format').paragraph


## Fields defined by `format`

<a id="format.line_length"></a>
### `format.line_length` (number)

The maximum number of characters to allow on a line when reformatting paragraphs. The
  default value is 100.

<a id="format.on_save"></a>
### `format.on_save` (bool)

Whether or not to invoke a code formatter on save. The default value is `true`.


## Functions defined by `format`

<a id="format.code"></a>
### `format.code`()

Reformats using a code formatter for the current buffer's lexer language either the selected
text or the current paragraph, according to the rules of `textadept.editing.filter_through()`.

See also:

* [`format.commands`](#format.commands)

<a id="format.paragraph"></a>
### `format.paragraph`()

Reformats using the Unix `fmt` tool either the selected text or the current paragraph,
according to the rules of `textadept.editing.filter_through()`.
For styled text, paragraphs are either blocks of same-styled lines (e.g. code comments),
or lines surrounded by blank lines.
If the first line matches any of the lines in `ignore_header_lines`, it is not reformatted.
If the last line matches any of the lines in `ignore_footer_lines`, it is not reformatted.

See also:

* [`format.ignore_header_lines`](#format.ignore_header_lines)
* [`format.ignore_footer_lines`](#format.ignore_footer_lines)
* [`format.line_length`](#format.line_length)


## Tables defined by `format`

<a id="format.commands"></a>
### `format.commands`

Map of lexer languages to string code formatter commands or functions that return such commands.

<a id="format.ignore_file_patterns"></a>
### `format.ignore_file_patterns`

Patterns that match filenames to ignore when formatting on save.
This is useful for projects with a top-level format config file, but subfolder dependencies
whose code should not be formatted on save.

<a id="format.ignore_footer_lines"></a>
### `format.ignore_footer_lines`

Footer lines to ignore when reformatting paragraphs.
These can be Doxygen footers for example.

<a id="format.ignore_header_lines"></a>
### `format.ignore_header_lines`

Header lines to ignore when reformatting paragraphs.
These can be LuaDoc or Doxygen headers for example.

---
