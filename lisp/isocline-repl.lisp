(defpackage :isocline-repl
  (:use :cl)
  (:local-nicknames (:ic :isocline))
  (:export #:run))

(in-package :isocline-repl)

(defvar *debug-level* 0)

(defvar *restarts*)

(defun prompt-indent ()
  (make-string (* 2 *debug-level*) :initial-element #\space))

(defun prompt-string ()
  (if (zerop *debug-level*)
      (package-name *package*)
      (format nil "~A\\[~D] ~A"
              (prompt-indent)
              *debug-level*
              (package-name *package*))))

(defun debugger (condition hook)
  (declare (ignore hook))
  (let ((*debug-level* (1+ *debug-level*)))
    (when (typep condition 'error)
      (ic:term-bold t)
      (ic:term-style "ic-error")
      ;; The error
      (ic:println
       (format nil "~S: ~A~%" (class-name (class-of condition)) condition))
      (ic:term-bold nil)
      ;; The backtrace
      (uiop:print-backtrace :stream *error-output* :condition condition)
      ;; The restarts
      (ic:term-style "ic-hint")
      (let ((*restarts* (compute-restarts condition)))
        (ic:println (with-output-to-string (s)
                      (format s "Applicable restarts \\[:R1 :R2 etc]:~%")
                      (loop :for i :from 0
                            :for r :in *restarts*
                            :do (format s "~A  \\[:R~D] ~S: ~A~%"
                                        (prompt-indent)
                                        i
                                        (restart-name r)
                                        r))))
        (force-output *error-output*)
        (ic:term-reset)
        (run)))))

(defun may-be-invoke-restart (restart)
  (when (keywordp restart)
    (let* ((name (string restart))
           (prefix (char name 0))
           (suffix (ignore-errors (parse-integer (subseq name 1)))))
      (when (and (char-equal #\R prefix)
                 suffix
                 (< suffix (length *restarts*)))
        (invoke-restart-interactively (nth suffix *restarts*))))))

(defun print-eval-processing-errors (form)
  (let* ((*debugger-hook* #'debugger)
         (results (multiple-value-list (eval form))))
    (unless (zerop *debug-level*)
      (may-be-invoke-restart (first results)))
    (ic:term-italic t)
    (ic:println (format nil "~A;=> ~{~S~^, ~}~%" (prompt-indent) results))
    (ic:term-reset)))

(defun run ()
  (let ((*print-case* :downcase))
    (loop :initially (ic:term-init)
          :for c-input := (ic:readline (prompt-string))
          :until (cffi:null-pointer-p c-input)
          :for input := (cffi:foreign-string-to-lisp c-input)
          :for form := (read-from-string input)
          :do (if (zerop *debug-level*)
                  (with-simple-restart
                      (top-level-repl
                       "Ignore errors and skip to the top-level of the interactive REPL")
                    (print-eval-processing-errors form))
                  (print-eval-processing-errors form))
              (cffi:foreign-free c-input))))
