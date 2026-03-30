(defpackage :isocline-repl
  (:use :cl)
  (:local-nicknames (:ic :isocline))
  (:export #:run))

(in-package :isocline-repl)

(defun prompt-string ()
  (package-name *package*))

(defun run ()
  (loop :for c-input := (ic:readline (prompt-string))
        :until (cffi:null-pointer-p c-input)
        :for input := (cffi:foreign-string-to-lisp c-input)
        :for form := (read-from-string input)
        :for results := (multiple-value-list (eval form))
        :do (ic:print (format nil ";=> ~{~S~^, ~}~%" results))
            (cffi:foreign-free c-input)))
