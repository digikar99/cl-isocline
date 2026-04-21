isocline and isocline-repl (Common Lisp)
---

`isocline-repl` is a feature-rich Common Lisp REPL with support for:

- multiline editing
- history
- syntax highlighting
- basic debugging

![](demo.gif)

If you are new to Common Lisp, you can head straight to the  [latest release](https://github.com/digikar99/cl-isocline/releases/latest/) and grab a

| Operating System | Architecture             | Binary version                                                                                                           |
|------------------|--------------------------|--------------------------------------------------------------------------------------------------------------------------|
| Windows          | Intel/AMD                | [windows.x86_64](https://github.com/digikar99/cl-isocline/releases/download/latest/cl-isocline-repl.windows.x86_64.zip)  |
| MacOS            | Intel/AMD                | [darwin.x86-64](https://github.com/digikar99/cl-isocline/releases/download/latest/cl-isocline-repl.darwin.x86-64.tar.gz) |
| MacOS            | M series                 | [darwin.arm64](https://github.com/digikar99/cl-isocline/releases/download/latest/cl-isocline-repl.darwin.arm64.tar.gz)   |
| Linux            | Intel/AMD                | [linux.x86-64](https://github.com/digikar99/cl-isocline/releases/download/latest/cl-isocline-repl.linux.x86-64.tar.gz)   |
| Linux            | Snapdragon / VM@M-series | [linux.arm64](https://github.com/digikar99/cl-isocline/releases/download/latest/cl-isocline-repl.linux.arm64.tar.gz)     |

The binaries contained in the zip or tar.gz are *standalone* binaries. This means they should just work and should not require you to install anything else. This is great if you are still in the initial steps of learning Common Lisp. Later, once you are more familiar with Common Lisp, you can check out Emacs, Slime/Sly, or VS Code and Alive, or the other [editors](https://lispcookbook.github.io/cl-cookbook/editor-support.html).

But besides the REPL itself, this repository contains the C library [isocline](https://github.com/daanx/isocline) along with a Common Lisp FFI interface to it. Isocline is an alternative to
libreadline, libedit and the likes. In contrast to the contagious GPL-licensed libreadline, it is

-   MIT licensed
-   Pure C
-   Portable across Unix, Windows, MacOS
-   Supports multiline editing out of the box
-   ... and much more ...

This means it works as an awesome portable repl for Common Lisp, across operating systems and lisp implementations. If you want to supply a portable rich REPL for your Common Lisp application, this repository might just be your thing!

The current repository contains source code for version 1.0.9 of Isocline, along with [lisp bindings](lisp/isocline.lisp) and a [simple repl](lisp/isocline-repl.lisp) that also serves as an example for Isocline. This itself is based upon [isocline/test/example.c](isocline/test/isocline.c).

# Contents

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [isocline and isocline-repl (Common Lisp)](#isocline-and-isocline-repl-common-lisp)
- [Contents](#contents)
- [Installation](#installation)
    - [A. Binaries](#a-binaries)
    - [B. Compiling from source](#b-compiling-from-source)
        - [1. Get a Lisp compiler (or interpreter)](#1-get-a-lisp-compiler-or-interpreter)
            - [Linux](#linux)
            - [MacOS](#macos)
            - [Windows](#windows)
        - [2. Install the quicklisp client](#2-install-the-quicklisp-client)
        - [3. Install ultralisp](#3-install-ultralisp)
        - [4. Run isocline-repl](#4-run-isocline-repl)
        - [5. Making the binary](#5-making-the-binary)
    - [C. Roswell](#c-roswell)
- [TODO](#todo)
- [API Reference](#api-reference)
    - [add-completion](#add-completion)
    - [add-completion-ex](#add-completion-ex)
    - [add-completions](#add-completions)
    - [alloc](#alloc)
    - [arg](#arg)
    - [attrs](#attrs)
    - [bbcode](#bbcode)
    - [cached-cpos](#cached-cpos)
    - [cached-upos](#cached-upos)
    - [closure](#closure)
    - [complete](#complete)
    - [complete-filename](#complete-filename)
    - [complete-qword](#complete-qword)
    - [complete-qword-ex](#complete-qword-ex)
    - [complete-word](#complete-word)
    - [completion-env](#completion-env)
    - [cursor](#cursor)
    - [enable-auto-tab](#enable-auto-tab)
    - [enable-beep](#enable-beep)
    - [enable-brace-insertion](#enable-brace-insertion)
    - [enable-brace-matching](#enable-brace-matching)
    - [enable-color](#enable-color)
    - [enable-completion-preview](#enable-completion-preview)
    - [enable-highlight](#enable-highlight)
    - [enable-hint](#enable-hint)
    - [enable-history-duplicates](#enable-history-duplicates)
    - [enable-inline-help](#enable-inline-help)
    - [enable-multiline](#enable-multiline)
    - [enable-multiline-indent](#enable-multiline-indent)
    - [env](#env)
    - [free](#free)
    - [get-continuation-prompt-marker](#get-continuation-prompt-marker)
    - [get-prompt-marker](#get-prompt-marker)
    - [highlight](#highlight)
    - [highlight-env](#highlight-env)
    - [highlight-formatted](#highlight-formatted)
    - [history-add](#history-add)
    - [history-clear](#history-clear)
    - [history-remove-last](#history-remove-last)
    - [input](#input)
    - [input-len](#input-len)
    - [libisocline](#libisocline)
    - [malloc](#malloc)
    - [mem](#mem)
    - [print](#print)
    - [printf](#printf)
    - [println](#println)
    - [readline](#readline)
    - [realloc](#realloc)
    - [set-default-completer](#set-default-completer)
    - [set-default-highlighter](#set-default-highlighter)
    - [set-hint-delay](#set-hint-delay)
    - [set-history](#set-history)
    - [set-insertion-braces](#set-insertion-braces)
    - [set-matching-braces](#set-matching-braces)
    - [set-prompt-marker](#set-prompt-marker)
    - [set-tty-esc-delay](#set-tty-esc-delay)
    - [style-close](#style-close)
    - [style-def](#style-def)
    - [style-open](#style-open)
    - [term-bold](#term-bold)
    - [term-color-ansi](#term-color-ansi)
    - [term-color-rgb](#term-color-rgb)
    - [term-done](#term-done)
    - [term-flush](#term-flush)
    - [term-get-color-bits](#term-get-color-bits)
    - [term-init](#term-init)
    - [term-italic](#term-italic)
    - [term-reset](#term-reset)
    - [term-reverse](#term-reverse)
    - [term-style](#term-style)
    - [term-underline](#term-underline)
    - [term-write](#term-write)
    - [term-writef](#term-writef)
    - [term-writeln](#term-writeln)

<!-- markdown-toc end -->


# Installation

There are three methods:

## A. Binaries

See the [Releases](https://github.com/digikar99/cl-isocline/releases/).

These come with a builtin way to set up the package manager quicklisp. Once you are able to run the binary, the package manager quicklisp can be installed using:

```lisp
(ql-https:ensure-quicklisp)
```

This assumes the availability of `curl openssl tar git`. Recommended way to obtain these on Windows is using [MSYS2](https://www.msys2.org/). Once MSYS2 is installed, open the MINGW terminal and:

```sh
pacman -S git openssl
```

## B. Compiling from source

### 1. Get a C and Lisp compiler (or interpreter)

We default to [sbcl](http://sbcl.org).

#### Linux

```sh
sudo apt install sbcl gcc
```

#### MacOS

Install [homebrew](https://brew.sh) if you don't have it:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install sbcl and gcc

```sh
brew install sbcl gcc
```

#### Windows

1. Install [MSYS2](https://www.msys2.org/).
2. Launch the "MSYS2 MINGW" terminal.
3. `pacman -S mingw-w64-x86_64-sbcl mingw-w64-x86_64-gcc`

### 2. Install the quicklisp client

[rudolfochrist/ql-https](https://github.com/rudolfochrist/ql-https) is a quicklisp client variant that uses https.

```sh
curl https://raw.githubusercontent.com/rudolfochrist/ql-https/master/install.sh | bash
```

### 3. Install ultralisp

```lisp
;; ql-https will upgrade the URLs from http to https
(ql-dist:install-dist "http://dist.ultralisp.org/" :prompt nil)
```

### 4. Run isocline-repl

If you have ultralisp installed, then you can

```lisp
(ql:quickload "isocline-repl")
(isocline-repl:main)
```

This assumes you have `gcc` installed. It will be used to compile `libisocline.so` from the sources. By default, isocline depends on the foreign library. However, the [github action workflow](./github/workflows) has been set up to use [sbcl-goodies](https://github.com/sionescu/sbcl-goodies) to build and statically link libisocline.a into the lisp image. These lisp images can then be used as standalone programs without any dependencies on *extra* foreign libraries.

### 5. Making the binary

The following should create a `cl-isocline-repl` in the root directory of `isocline-repl`.

```lisp
(asdf:make "isocline-repl")
```

## C. Roswell

Note: For portability reasons, roswell does not ship with ql-https. Thus, you should set it up roswell's quicklisp with https support using the steps [here](https://github.com/rudolfochrist/ql-https). The simplest can be to symlink `.roswell/lisp/quicklisp` to the default quicklisp installation `~/quicklisp`. 

```
ln -s ~/quicklisp ~/.roswell/lisp/quicklisp
```

```
ros install digikar99/cl-isocline
ros run -- --eval '(ql-dist:install-dist "http://dist.ultralisp.org/" :prompt nil)
ros install isocline-repl
```

The last line should point you to the binary.

# TODO

Contributions welcome!

- [x] History
- [x] [ql-https](https://github.com/rudolfochrist/ql-https) bootstrapping
- [x] Debugger Support
- [x] Compile standalone binaries for MacOS
- [x] Compile standalone binaries for Linux
- [x] Add completion support
- [x] Syntax highlighting
- [x] Better copy-paste support
- [x] Ship with [CIEL](https://ciel-lang.org/)
- [ ] Easy: Process command line arguments (load, eval) with unix-opts
- [ ] Easy: Add a dumb mode so that it can work directly with SLIME or the likes
- [ ] Moderate: Add more functionality from [isocline/include/isocline.h](isocline/include/isocline.h) to [lisp/isocline.lisp](lisp/isocline.lisp)

# API Reference

### +version+

```lisp
Constant: 1.0.4
```

### add-completion

```lisp
Function: (add-completion cenv completion)
```

In a completion callback (usually from ic_complete_word()), use this function to add a completion.
(the completion string is copied by isocline and do not need to be preserved or allocated).

Returns `true` if the callback should continue trying to find more possible completions.
If `false` is returned, the callback should try to return and not add more completions (for improved latency).

### add-completion-ex

```lisp
Function: (add-completion-ex cenv completion display help)
```

In a completion callback (usually from ic_complete_word()), use this function to add a completion.
The `display` is used to display the completion in the completion menu, and `help` is
displayed for hints for example. Both can be NULL for the default.
(all are copied by isocline and do not need to be preserved or allocated).

Returns `true` if the callback should continue trying to find more possible completions.
If `false` is returned, the callback should try to return and not add more completions (for improved latency).

### add-completions

```lisp
Function: (add-completions cenv prefix completions)
```

In a completion callback (usually from ic_complete_word()), use this function to add completions.
The `completions` array should be terminated with a NULL element, and all elements
are added as completions if they start with `prefix`.

Returns `true` if the callback should continue trying to find more possible completions.
If `false` is returned, the callback should try to return and not add more completions (for improved latency).

### alloc

No documentation found for `alloc`

### arg

No documentation found for `arg`

### attrs

No documentation found for `attrs`

### bbcode

No documentation found for `bbcode`

### cached-cpos

No documentation found for `cached-cpos`

### cached-upos

No documentation found for `cached-upos`

### closure

No documentation found for `closure`

### complete

No documentation found for `complete`

### complete-filename

```lisp
Function: (complete-filename cenv prefix dir-separator roots extensions)
```

Complete a filename.
Complete a filename given a semi-colon separated list of root directories `roots` and
semi-colon separated list of possible extensions (excluding directories).
If `roots` is NULL, the current directory is the root (".").
If `extensions` is NULL, any extension will match.
Each root directory should _not_ end with a directory separator.
If a directory is completed, the `dir_separator` is added at the end if it is not 0.
Usually the `dir_separator` is `/` but it can be set to `\` on Windows systems.
For example:
```
/ho         --> /home/
/home/.ba   --> /home/.bashrc
```
(This already uses ic_complete_quoted_word() so do not call it from inside a word handler).


### complete-qword

No documentation found for `complete-qword`

### complete-qword-ex

No documentation found for `complete-qword-ex`

### complete-word

```lisp
Function: (complete-word cenv prefix fun is-word-char)
```

Complete a _word_ (i.e. _token_).
Calls the user provided function `fun` to complete on the
current _word_. Almost all user provided completers should use this function.
If `is_word_char` is NULL, the default `&ic_char_is_nonseparator` is used.
The `prefix` passed to `fun` is modified to only contain the current word, and
any results from `ic_add_completion` are automatically adjusted to replace that part.
For example, on the input "hello w", a the user `fun` only gets `w` and can just complete
with "world" resulting in "hello world" without needing to consider `delete_before` etc.
@see ic_complete_qword() for completing quoted and escaped tokens.

### completion-env

No documentation found for `completion-env`

### cursor

No documentation found for `cursor`

### enable-auto-tab

```lisp
Function: (enable-auto-tab enable)
```

to expand as far as possible if the completions are unique. (disabled by default).
Returns the previous setting.

### enable-beep

```lisp
Function: (enable-beep enable)
```

Disable or enable sound (enabled by default).
A beep is used when tab cannot find any completion for example.
Returns the previous setting.

### enable-brace-insertion

```lisp
Function: (enable-brace-insertion enable)
```

Enable automatic brace insertion (enabled by default).

### enable-brace-matching

```lisp
Function: (enable-brace-matching enable)
```

Enable highlighting of matching braces (and error highlight unmatched braces).`

### enable-color

```lisp
Function: (enable-color enable)
```

Disable or enable color output (enabled by default).
Returns the previous setting.

### enable-completion-preview

```lisp
Function: (enable-completion-preview enable)
```

Disable or enable preview of a completion selection (enabled by default)
Returns the previous setting.

### enable-highlight

```lisp
Function: (enable-highlight enable)
```

Disable or enable syntax highlighting (enabled by default).
This applies regardless whether a syntax highlighter callback was set (`ic_set_highlighter`)
Returns the previous setting.

### enable-hint

```lisp
Function: (enable-hint enable)
```

Disable or enable hinting (enabled by default)
Shows a hint inline when there is a single possible completion.
@returns the previous setting.

### enable-history-duplicates

```lisp
Function: (enable-history-duplicates enable)
```

Disable or enable duplicate entries in the history (disabled by default).
Returns the previous setting.

### enable-inline-help

```lisp
Function: (enable-inline-help enable)
```

Disable or enable display of short help messages for history search etc.
(full help is always dispayed when pressing F1 regardless of this setting)
@returns the previous setting.

### enable-multiline

```lisp
Function: (enable-multiline enable)
```

Disable or enable multi-line input (enabled by default).
Returns the previous setting.

### enable-multiline-indent

```lisp
Function: (enable-multiline-indent enable)
```

Disable or enable automatic identation of continuation lines in multiline
input so it aligns with the initial prompt.
Returns the previous setting.

### env

No documentation found for `env`

### free

No documentation found for `free`

### get-continuation-prompt-marker

```lisp
Function: (get-continuation-prompt-marker)
```

Get the current continuation prompt marker.

### get-prompt-marker

```lisp
Function: (get-prompt-marker)
```

Get the current prompt marker.

### highlight

```lisp
Function: (highlight henv pos count style)
```

Set the style of characters starting at position `pos`.

### highlight-env

No documentation found for `highlight-env`

### highlight-formatted

```lisp
Function: (highlight-formatted henv input formatted)
```

Experimental: Convenience function for highlighting with bbcodes.
Can be called in a `ic_highlight_fun_t` callback to colorize the `input` using the
the provided `formatted` input that is the styled `input` with bbcodes. The
content of `formatted` without bbcode tags should match `input` exactly.


### history-add

```lisp
Function: (history-add entry)
```

### history-clear

```lisp
Function: (history-clear)
```

### history-remove-last

```lisp
Function: (history-remove-last)
```

### input

No documentation found for `input`

### input-len

No documentation found for `input-len`

### libisocline

No documentation found for `libisocline`

### malloc

No documentation found for `malloc`

### mem

No documentation found for `mem`

### print

```lisp
Function: (print s)
```

See [here](https://github.com/daanx/isocline#bbcode-format) for a description of the full bbcode format.

### printf

```lisp
Macro: (printf fmt &rest varargs0)
```

Print formatted with bbcode markup.
@see ic_print

### println

```lisp
Function: (println s)
```

Print with bbcode markup ending with a newline.
@see ic_print()

### readline

```lisp
Function: (readline prompt-text)
```

Read input from the user using rich editing abilities.
@param prompt_text   The prompt text, can be NULL for the default ("").
  The displayed prompt becomes `prompt_text` followed by the `prompt_marker` ("> ").
@returns the heap allocated input on succes, which should be `free`d by the caller.
  Returns NULL on error, or if the user typed ctrl+d or ctrl+c.

If the standard input (`stdin`) has no editing capability
(like a dumb terminal (e.g. TERM=`dumb`), running in a debuggen, a pipe or redirected file, etc.)
the input is read directly from the input stream up to the
next line without editing capability.
See also a ic_set_prompt_marker(), a ic_style_def()

@see ic_set_prompt_marker(), ic_style_def()


### realloc

No documentation found for `realloc`

### set-default-completer

```lisp
Function: (set-default-completer completer arg)
```

Set the default completion handler.
  @param completer  The completion function
  @param arg        Argument passed to the a completer.
There can only be one default completion function, setting it again disables the previous one.
The initial completer use `ic_complete_filename`.

### set-default-highlighter

```lisp
Function: (set-default-highlighter highlighter arg)
```

Set a syntax highlighter.
There can only be one highlight function, setting it again disables the previous one.

### set-hint-delay

```lisp
Function: (set-hint-delay delay-ms)
```

Set millisecond delay before a hint is displayed. Can be zero. (500ms by default).

### set-history

```lisp
Function: (set-history fname max-entries)
```

### set-insertion-braces

```lisp
Function: (set-insertion-braces brace-pairs)
```

Set matching brace pairs for automatic insertion.
Pass a NULL for the default `()[]{}""''`

### set-matching-braces

```lisp
Function: (set-matching-braces brace-pairs)
```

Set matching brace pairs.
Pass a NULL for the default `"()[]{}"`.

### set-prompt-marker

```lisp
Function: (set-prompt-marker prompt-marker continuation-prompt-marker)
```

Set a prompt marker and a potential marker for extra lines with multiline input.
Pass a NULL for the `prompt_marker` for the default marker (`"> "`).
Pass a NULL for continuation prompt marker to make it equal to the `prompt_marker`.

### set-tty-esc-delay

```lisp
Function: (set-tty-esc-delay initial-delay-ms followup-delay-ms)
```

Set millisecond delay for reading escape sequences in order to distinguish
a lone ESC from the start of a escape sequence. The defaults are 100ms and 10ms,
but it may be increased if working with very slow terminals.

### style-close

```lisp
Function: (style-close)
```

End a global style.

### style-def

```lisp
Function: (style-def style-name fmt)
```

Define or redefine a style.
@param style_name The name of the style.
@param fmt        The `fmt` string is the content of a tag and can contain
  other styles. This is very useful to theme the output of a program
  by assigning standard styles like `em` or `warning` etc.

### style-open

```lisp
Function: (style-open fmt)
```

Start a global style that is only reset when calling a matching ic_style_close().

### term-bold

```lisp
Function: (term-bold enable)
```

Set text attribute to bold.

### term-color-ansi

```lisp
Function: (term-color-ansi foreground color)
```

Set text attribute to ansi color palette index between 0 and 255 (or 256 for the ANSI "default" color).
(auto matched to smaller palette if not supported)

### term-color-rgb

```lisp
Function: (term-color-rgb foreground color)
```

Set text attribute to 24-bit RGB color (between `0x000000` and `0xFFFFFF`).
(auto matched to smaller palette if not supported)

### term-done

```lisp
Function: (term-done)
```

Call this when done with the terminal functions.

### term-flush

```lisp
Function: (term-flush)
```

Flush the terminal output.
(happens automatically on newline characters ('n') as well).

### term-get-color-bits

```lisp
Function: (term-get-color-bits)
```

Get the palette used by the terminal:
This is usually initialized from the COLORTERM environment variable. The
possible values of COLORTERM for each palette are given in parenthesis.

- 1: monochrome (`monochrome`)
- 3: old ANSI terminal with 8 colors, using bold for bright (`8color`/`3bit`)
- 4: regular ANSI terminal with 16 colors.     (`16color`/`4bit`)
- 8: terminal with ANSI 256 color palette.     (`256color`/`8bit`)
- 24: true-color terminal with full RGB colors. (`truecolor`/`24bit`/`direct`)


### term-init

```lisp
Function: (term-init)
```

Initialize for terminal output.
Call this before using the terminal write functions (`ic_term_write`)
Does nothing on most platforms but on Windows it sets the console to UTF8 output and possible enables virtual terminal processing.


### term-italic

```lisp
Function: (term-italic enable)
```

Set text attribute to italic

### term-reset

```lisp
Function: (term-reset)
```

Reset the text attributes

### term-reverse

```lisp
Function: (term-reverse enable)
```

Set text attribute to reverse video.

### term-style

```lisp
Function: (term-style style)
```

Set text attributes from a style.

### term-underline

```lisp
Function: (term-underline enable)
```

Set text attribute to underline.

### term-write

```lisp
Function: (term-write s)
```

Write a string to the console (and process CSI escape sequences).

### term-writef

```lisp
Macro: (term-writef fmt &rest varargs0)
```

Write a formatted string to the console.
(and process CSI escape sequences).

### term-writeln

```lisp
Function: (term-writeln s)
```

Write a string to the console and end with a newline
(and process CSI escape sequences).

