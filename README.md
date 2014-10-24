# Translate

<pre>
Ruby program that translates Python source code from one language to other languages.
Phrase files can be shared between similar source files or versions.
Empty phrase files can be created and sent to translators.
One million lines translated per minute.
</pre>

## License and Proceeds

<pre>
Freeware
</pre>

## Usage

<pre>
ruby translate reversi .se    Translates reversi.py to swedish. One file.
ruby translate r1 r2 .se .dk  Translates r1.py and r2.py to swedish and danish. Four files.
</pre>

## Translation modes

<pre>
MODE=0: Strings only. (for end users)
MODE=1: Strings, variable names, function names and comments. (default, for programmers)
</pre>

## Directory and File structure:

<pre>
/original
  reversi.py       The original program (with all text in English normally).
/phrases
  /se
    reversi.se     Contains phrases in English and Swedish.
/translated
  /se
    reversi.py     The translated file in Swedish.
/feedback
  /se
    reversi.txt    Contains missing translations. Move lines to reversi.se and replace all *** occurences.
/ignore
  python.txt       Contains reserved words that should not be replaced.
translate.rb
</pre>

## Sample phrase lines:

### Include file

<pre>
@parentfile            Include phrases recursively. No depth limit. Uses same file extension.
@pygame.txt            More than one file can be included.
</pre>

### Phrases with translations.

<pre>
# Details:|# Detaljer: Comment
move|flytta            Variable name
'yellow'|'gul'         String '
"black"|"svart"        String "
</pre>

### Phrases without translations. These are not translated.

<pre>
# Reversi              Comment
i                      Variable name
"%s"                   String '
'%s'                   String "
</pre>

## To Do

<pre>
The escape character, backslash is not handled.
Doesn't handle multiline string.
</pre>
