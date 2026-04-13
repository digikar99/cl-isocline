(cl:defpackage :isocline
  (:import-from #:cffi
                #:defcfun
                #:defcvar
                #:defcstruct)
  (:use)
  (:export #:libisocline
           #:+version+

           #:readline

           #:print
           #:println
           #:printf

           #:style-def
           #:style-open
           #:style-close

           #:set-history
           #:history-remove-last
           #:history-clear
           #:history-add

           #:completion-env
           #:env
           #:input
           #:cursor
           #:arg
           #:closure
           #:complete

           #:set-default-completer
           #:add-completion
           #:add-completion-ex
           #:add-completions
           #:complete-filename
           #:complete-word
           #:complete-qword
           #:complete-qword-ex

           #:alloc
           #:malloc
           #:realloc
           #:free

           #:highlight-env
           #:attrs
           #:input
           #:input-len
           #:bbcode
           #:mem
           #:cached-upos
           #:cached-cpos

           #:set-default-highlighter
           #:highlight
           #:highlight-formatted

           #:set-prompt-marker
           #:get-prompt-marker
           #:get-continuation-prompt-marker
           #:enable-multiline
           #:enable-beep
           #:enable-color
           #:enable-history-duplicates
           #:enable-auto-tab
           #:enable-completion-preview
           #:enable-multiline-indent
           #:enable-inline-help
           #:enable-hint
           #:set-hint-delay
           #:enable-highlight
           #:set-tty-esc-delay
           #:enable-brace-matching
           #:set-matching-braces
           #:enable-brace-insertion
           #:set-insertion-braces

           #:term-init
           #:term-done
           #:term-flush
           #:term-write
           #:term-writeln
           #:term-writef

           #:term-style
           #:term-bold
           #:term-underline
           #:term-italic
           #:term-reverse
           #:term-color-ansi
           #:term-color-rgb
           #:term-reset
           #:term-get-color-bits))
