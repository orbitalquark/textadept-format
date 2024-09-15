# Format

Format/reformat paragraph and code.

Install this module by copying it into your *~/.textadept/modules/* directory or Textadept's
*modules/* directory, and then putting the following in your *~/.textadept/init.lua*:

	require('format')

There will be an "Edit > Reformat" menu.

## Key Bindings

Windows and Linux | macOS | Terminal | Command
-|-|-|-
**Edit**| | |
Ctrl+Shift+J | ⌘⇧J | ^J | Reformat paragraph

## Fields defined by `format`

<a id="format.commands"></a>
### `format.commands` &lt;table&gt;

Map of lexer languages to string code formatter commands or functions that return such
commands.

Fields:

- `lua`: 
- `cpp`: 
- `go`: 

<a id="format.ignore_file_patterns"></a>
### `format.ignore_file_patterns` &lt;table&gt;

Patterns that match filenames to ignore when formatting on save.
This is useful for projects with a top-level format config file, but subfolder dependencies
whose code should not be formatted on save.

<a id="format.ignore_footer_lines"></a>
### `format.ignore_footer_lines` &lt;table&gt;

Footer lines to ignore when reformatting paragraphs.
These can be Doxygen footers for example.

Fields:

- `*/`: 

<a id="format.ignore_header_lines"></a>
### `format.ignore_header_lines` &lt;table&gt;

Header lines to ignore when reformatting paragraphs.
These can be LuaDoc/LDoc or Doxygen headers for example.

Fields:

- `---`: 
- `/**`: 

<a id="format.line_length"></a>
### `format.line_length` 

The maximum number of characters to allow on a line when reformatting paragraphs. The default
value is 100.

<a id="format.on_save"></a>
### `format.on_save` 

Whether or not to invoke a code formatter on save. The default value is `true`.

<a id="format.prefix_map"></a>
### `format.prefix_map` &lt;table&gt;

Prefixes to remap when reformatting paragraphs.
This is for paragraphs that have a first-line prefix that is different from subsequent
line prefixes. For example, LuaDoc/LDoc comments start with '---' but continue with '--',
and Doxygen comments start with '/**' but continue with ' *'.

Fields:

- `[/**]`: 
- `[---]`: 


## Functions defined by `format`

<a id="format.code"></a>
### `format.code`()

Reformats using a code formatter for the current buffer's lexer language either the selected
text or the current paragraph, according to the rules of `textadept.editing.filter_through()`.

See also:

- [`format.commands`](#format.commands)

<a id="format.paragraph"></a>
### `format.paragraph`()

Reformats using the Unix `fmt` tool either the selected text or the current paragraph,
according to the rules of `textadept.editing.filter_through()`.
For styled text, paragraphs are either blocks of same-styled lines (e.g. code comments),
or lines surrounded by blank lines.
If the first line matches any of the lines in [`format.ignore_header_lines`](#format.ignore_header_lines), it is not
reformatted. If the last line matches any of the lines in [`format.ignore_footer_lines`](#format.ignore_footer_lines),
it is not reformatted.

See also:

- [`format.line_length`](#format.line_length)


---
