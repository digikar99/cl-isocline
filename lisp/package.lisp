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
