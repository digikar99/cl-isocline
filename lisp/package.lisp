(cl:defpackage :isocline
  (:import-from #:cffi
                #:defcfun
                #:defcvar)
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
