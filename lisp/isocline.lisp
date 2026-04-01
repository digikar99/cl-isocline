(cl:in-package :isocline)

;; API in ISOCLINE_ROOT/isocline/include/isocline.h
;; Also see https://daanx.github.io/isocline/

(alexandria:define-constant +version+ "1.0.4" :test #'cl:string=)

(defcfun (readline "ic_readline") (:pointer :char)
  "/// Read input from the user using rich editing abilities.
/// @param prompt_text   The prompt text, can be NULL for the default (\"\").
///   The displayed prompt becomes `prompt_text` followed by the `prompt_marker` (\"> \").
/// @returns the heap allocated input on succes, which should be `free`d by the caller.
///   Returns NULL on error, or if the user typed ctrl+d or ctrl+c.
///
/// If the standard input (`stdin`) has no editing capability
/// (like a dumb terminal (e.g. `TERM`=`dumb`), running in a debuggen, a pipe or redirected file, etc.)
/// the input is read directly from the input stream up to the
/// next line without editing capability.
/// See also \a ic_set_prompt_marker(), \a ic_style_def()
///
/// @see ic_set_prompt_marker(), ic_style_def()
"
  (prompt-text :string))



(defcfun (print "ic_print") :void
  "See [here](https://github.com/daanx/isocline#bbcode-format) for a description of the full bbcode format."
  (s :string))


(defcfun (println "ic_println") :void
  "Print with bbcode markup ending with a newline.
@see ic_print()"
  (s :string))

(defcfun (printf "ic_printf") :void
  "Print formatted with bbcode markup.
@see ic_print"
  (fmt :string) cl:&rest)

;; TODO: vprintf

(defcfun (style-def "ic_style_def") :void
  "/// Define or redefine a style.
/// @param style_name The name of the style.
/// @param fmt        The `fmt` string is the content of a tag and can contain
///   other styles. This is very useful to theme the output of a program
///   by assigning standard styles like `em` or `warning` etc."
  (style-name :string)
  (fmt :string))

(defcfun (style-open "ic_style_open") :void
  "Start a global style that is only reset when calling a matching ic_style_close()."
  (fmt :string))

(defcfun (style-close "ic_style_close") :void
  "End a global style.")


(defcfun (set-history "ic_set_history") :void
  (fname :string)
  (max-entries :long))

(defcfun (history-remove-last "ic_history_remove_last") :void)
(defcfun (history-clear "ic_history_clear") :void)
(defcfun (history-add "ic_history_add") :void (entry :string))

;; TODO: Completion

(defcstruct completion-env
  (env :pointer) ; ic_env_t: the isocline environment
  (input :string) ; current full input
  (cursor :long) ; current cursor position
  (arg :pointer) ; argument given to ic_set_completer
  (closure :pointer) ; free variables for function composition
  (complete :pointer) ; ic_completion_fun_t*: function that adds a completion
  )

(defcfun (set-default-completer "ic_set_default_completer") :void
  "Set the default completion handler.
  @param completer  The completion function
  @param arg        Argument passed to the \a completer.
There can only be one default completion function, setting it again disables the previous one.
The initial completer use `ic_complete_filename`."
  (completer :pointer) ; ic_completion_fun_t*
  (arg :pointer))

(defcfun (add-completion "ic_add_completion") :bool
  "In a completion callback (usually from ic_complete_word()), use this function to add a completion.
(the completion string is copied by isocline and do not need to be preserved or allocated).

Returns `true` if the callback should continue trying to find more possible completions.
If `false` is returned, the callback should try to return and not add more completions (for improved latency)."
  (cenv (:pointer (:struct completion-env)))
  (completion :string))

(defcfun (add-completion-ex "ic_add_completion_ex") :bool
  "In a completion callback (usually from ic_complete_word()), use this function to add a completion.
The `display` is used to display the completion in the completion menu, and `help` is
displayed for hints for example. Both can be `NULL` for the default.
(all are copied by isocline and do not need to be preserved or allocated).

Returns `true` if the callback should continue trying to find more possible completions.
If `false` is returned, the callback should try to return and not add more completions (for improved latency)."
  (cenv (:pointer (:struct completion-env)))
  (completion :string)
  (display :string)
  (help :string))

(defcfun (add-completions "ic_add_completions") :bool
  "In a completion callback (usually from ic_complete_word()), use this function to add completions.
The `completions` array should be terminated with a NULL element, and all elements
are added as completions if they start with `prefix`.

Returns `true` if the callback should continue trying to find more possible completions.
If `false` is returned, the callback should try to return and not add more completions (for improved latency)."
  (cenv (:pointer (:struct completion-env)))
  (prefix :string)
  ;; const char** completions
  (completions (:pointer :string)))

(defcfun (complete-filename "ic_complete_filename") :void
  "Complete a filename.
Complete a filename given a semi-colon separated list of root directories `roots` and
semi-colon separated list of possible extensions (excluding directories).
If `roots` is NULL, the current directory is the root (\".\").
If `extensions` is NULL, any extension will match.
Each root directory should _not_ end with a directory separator.
If a directory is completed, the `dir_separator` is added at the end if it is not `0`.
Usually the `dir_separator` is `/` but it can be set to `\\` on Windows systems.
For example:
```
/ho         --> /home/
/home/.ba   --> /home/.bashrc
```
(This already uses ic_complete_quoted_word() so do not call it from inside a word handler).
"
  (cenv (:pointer (:struct completion-env)))
  (prefix :string)
  (dir-separator :char)
  (roots :string)
  (extensions :string))

(defcfun (complete-word "ic_complete_word") :void
  "Complete a _word_ (i.e. _token_).
Calls the user provided function `fun` to complete on the
current _word_. Almost all user provided completers should use this function.
If `is_word_char` is NULL, the default `&ic_char_is_nonseparator` is used.
The `prefix` passed to `fun` is modified to only contain the current word, and
any results from `ic_add_completion` are automatically adjusted to replace that part.
For example, on the input \"hello w\", a the user `fun` only gets `w` and can just complete
with \"world\" resulting in \"hello world\" without needing to consider `delete_before` etc.
@see ic_complete_qword() for completing quoted and escaped tokens."
  (cenv (:pointer (:struct completion-env)))
  (prefix :string)
  ;; ic_completer_fun_t* fun
  (fun :pointer)
  ;; ic_is_char_class_fun_t* is_word_char
  (is-word-char :pointer))

;; TODO
;; (defcfun (complete-qword))

;; TODO
;; (defcfun (complete-qword-ex))

;; TODO: Syntax

;; TODO: Options

;; TODO: Advanced completion

;; TODO: Character classes

(defcfun (term-init "ic_term_init") :void
  "Initialize for terminal output.
Call this before using the terminal write functions (`ic_term_write`)
Does nothing on most platforms but on Windows it sets the console to UTF8 output and possible enables virtual terminal processing.
")

(defcfun (term-done "ic_term_done") :void
  "Call this when done with the terminal functions.")

(defcfun (term-flush "ic_term_flush") :void
  "Flush the terminal output.
(happens automatically on newline characters ('\n') as well).")

(defcfun (term-write "ic_term_write") :void
  "Write a string to the console (and process CSI escape sequences)."
  (s :string))

(defcfun (term-writeln "ic_term_writeln") :void
  "Write a string to the console and end with a newline
(and process CSI escape sequences)."
  (s :string))

(defcfun (term-writef "ic_term_writef") :void
  "Write a formatted string to the console.
(and process CSI escape sequences)."
  (fmt :string)
  cl:&rest)

;; TODO: vwritef

(defcfun (term-style "ic_term_style") :void
  "Set text attributes from a style."
  (style :string))

(defcfun (term-bold "ic_term_bold") :void
  "Set text attribute to bold."
  (enable :bool))

(defcfun (term-underline "ic_term_underline") :void
  "Set text attribute to underline."
  (enable :bool))

(defcfun (term-italic "ic_term_italic") :void
  "Set text attribute to italic"
  (enable :bool))

(defcfun (term-reverse "ic_term_reverse") :void
  "Set text attribute to reverse video."
  (enable :bool))

(defcfun (term-color-ansi "ic_term_color_ansi") :void
  "Set text attribute to ansi color palette index between 0 and 255 (or 256 for the ANSI \"default\" color).
(auto matched to smaller palette if not supported)"
  (foreground :bool)
  (color :int))

(defcfun (term-color-rgb "ic_term_color_rgb") :void
  "Set text attribute to 24-bit RGB color (between `0x000000` and `0xFFFFFF`).
(auto matched to smaller palette if not supported)"
  (foreground :bool)
  (color :uint32))

(defcfun (term-reset "ic_term_reset") :void
  "Reset the text attributes")

(defcfun (term-get-color-bits "ic_term_get_color_bits") :int
  "Get the palette used by the terminal:
This is usually initialized from the COLORTERM environment variable. The
possible values of COLORTERM for each palette are given in parenthesis.

- 1: monochrome (`monochrome`)
- 3: old ANSI terminal with 8 colors, using bold for bright (`8color`/`3bit`)
- 4: regular ANSI terminal with 16 colors.     (`16color`/`4bit`)
- 8: terminal with ANSI 256 color palette.     (`256color`/`8bit`)
- 24: true-color terminal with full RGB colors. (`truecolor`/`24bit`/`direct`)
")

;; TODO: Async

;; TODO: Custom Allocation
