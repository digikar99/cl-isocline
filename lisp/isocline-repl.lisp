(defpackage :isocline-repl
  (:use :cl)
  (:import-from :trivial-backtrace
                #:frame-func
                #:frame-vars
                #:var-value)
  (:local-nicknames (:ic :isocline))
  (:export #:*history-file*
           #:*read-function*
           #:main
           #:repl))

(in-package :isocline-repl)

(defvar *history-file*)

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
  (let ((*debug-level* (1+ *debug-level*))
        (*debugger-hook* #'debugger)
        (indent (prompt-indent)))
    (when (typep condition 'error)
      (ic:term-style "ic-error")
      ;; The error
      (let ((*print-case* :upcase))
        (ic:print
         (format nil "  ~A~S: ~A~%~%"
                 indent
                 (class-name (class-of condition))
                 condition)))
      ;; The backtrace
      (let ((frame-depth -1))
        (format *error-output* "  ~ABacktrace:~%" indent)
        (trivial-backtrace:map-backtrace
         (lambda (frame)
           (format *error-output*
                   "  ~A  ~D: (~S ~{~S~^ ~})~%"
                   indent
                   (incf frame-depth)
                   (frame-func frame)
                   (mapcar #'var-value (frame-vars frame))))))
      (terpri *error-output*)
      ;; The restarts
      (ic:term-style "ic-hint")
      (let ((*restarts* (compute-restarts condition)))
        (write-string (with-output-to-string (s)
                        (format s "  ~AAvailable restarts [Type :r1 :r2 etc]:~%" indent)
                        (loop :for i :from 0
                              :for r :in *restarts*
                              :do (format s "  ~A  [:r~D] [~A]: ~A~%"
                                          indent
                                          i
                                          (string-upcase (restart-name r))
                                          r)))
                      *error-output*)
        (terpri *error-output*)
        (force-output *error-output*)
        (ic:term-reset)
        (repl)))))

(defun may-be-invoke-restart (restart)
  (when (keywordp restart)
    (let* ((name (string restart))
           (prefix (char name 0))
           (suffix (ignore-errors (parse-integer (subseq name 1)))))
      (when (and (char-equal #\R prefix)
                 suffix
                 (< suffix (length *restarts*)))
        (invoke-restart-interactively (nth suffix *restarts*))))))

(defvar *read-function* 'cl:read
  "The reader function used by Isocline REPL.")

(defun read-print-eval-processing-errors (input)
  (let* ((*debugger-hook* #'debugger)
         (input (string-trim '(#\space #\tab #\newline #\return) input)))
    (with-input-from-string (in input)
      (loop :while (listen in)
            :for form := (funcall *read-function* in)
            :for results := (multiple-value-list (eval form))
            :do (unless (zerop *debug-level*)
                  (may-be-invoke-restart (first results)))
                (ic:term-italic t)
                (ic:println (format nil "~A;=> ~{~S~^, ~}~%" (prompt-indent) results))
                (setf cl:*** cl:**
                      cl:** cl:*
                      cl:* (first results)
                      cl:+++ cl:++
                      cl:++ cl:+
                      cl:+ form)
                (ic:term-reset)))))



(defun repl ()

  (let ((*print-case* :downcase))

    (unwind-protect

         (loop :initially (ic:set-history *history-file* -1)
                          (ic:term-init)
               :for c-input := (ic:readline (prompt-string))
               :until (cffi:null-pointer-p c-input)
               :for input := (cffi:foreign-string-to-lisp c-input)
               :do (if (zerop *debug-level*)
                       (with-simple-restart
                           (top-level-repl
                            "Ignore errors and skip to the top-level of the interactive REPL")
                         (read-print-eval-processing-errors input))
                       (read-print-eval-processing-errors input))
                   (cffi:foreign-free c-input))

      (ic:term-done))))

(defun terminating-char-p (char)
  (declare (optimize speed))
  (or (member char '(#\space #\tab #\newline #\return) :test #'char=)
      (multiple-value-bind (fn non-terminating-p)
          (get-macro-character char)
        (and fn (not non-terminating-p)))))

(cffi:defcallback word-completer :void
    ((cenv (:pointer (:struct ic::completion-env)))
     (prefix :string))
  (declare (optimize (speed 1) safety (debug 3)))

  (handler-case
      (progn
        (let* ((input (cffi:foreign-slot-value cenv '(:struct ic:completion-env) 'ic:input))
               (cursor-position (cffi:foreign-slot-value cenv '(:struct ic:completion-env) 'ic:cursor))
               (colon-position (position-if (lambda (c) (char= #\: c)) input :from-end t :end cursor-position))
               (internal-symbols-p (or (not colon-position)
                                       (and colon-position
                                            (< 0 colon-position)
                                            (char= #\: (char input (1- colon-position))))))
               (pkg-name-end (if (and colon-position
                                      internal-symbols-p)
                                 (1- colon-position)
                                 colon-position))

               (pkg-name-start (when colon-position
                                 (position-if #'terminating-char-p
                                                input
                                                :from-end t
                                                :end pkg-name-end)))
               (pkg-prefix (when pkg-name-start
                             (subseq input (1+ pkg-name-start) pkg-name-end)))

               (*package* (cond (pkg-prefix
                                 (or (find-package (nstring-upcase pkg-prefix))
                                     *package*))
                                (colon-position
                                 (find-package :keyword))
                                (t
                                 *package*)))

               (pkg-completions
                 (loop :for pkg :in (list-all-packages)
                       :for pkg-name := (string-downcase (package-name pkg))
                       :if (uiop:string-prefix-p prefix pkg-name)
                         :collect pkg-name))
               (symbol-completions
                 (let ((symbol-names nil))
                   (if (and pkg-prefix
                            (not internal-symbols-p))
                       (do-external-symbols (s *package*)
                         (let ((name (string-downcase (symbol-name s))))
                           (when (uiop:string-prefix-p prefix name)
                             (push name symbol-names))))
                       (do-symbols (s *package*)
                         (let ((name (string-downcase (symbol-name s))))
                           (when (uiop:string-prefix-p prefix name)
                             (push name symbol-names)))))
                   symbol-names)))

            (loop :for c :in (if pkg-prefix
                                 (sort symbol-completions #'string<)
                                 (nconc (sort symbol-completions #'string<)
                                        (sort pkg-completions #'string<)))
                  :do (ic:add-completion cenv c))))

    (error (c)
      (format *error-output* "Error encountered while completing:~%~%  ~A~%~%" c)
      (uiop:print-backtrace :condition t :stream *error-output*)
      (terpri *error-output*)
      (force-output *error-output*))))

(cffi:defcallback completer :void
    ((cenv (:pointer (:struct ic::completion-env)))
     (prefix :string))
  (declare (optimize (speed 1) safety debug))
  (ic:complete-word cenv prefix (cffi:callback word-completer) (cffi:null-pointer)))

(defun main ()
  (setf *history-file*
        (uiop:native-namestring
         (merge-pathnames ".cl-isocline-repl" (first (directory (uiop:getenv "HOME"))))))
  (ic:set-default-completer (cffi:callback completer) (cffi:null-pointer))
  (repl))
