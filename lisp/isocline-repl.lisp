(defpackage :isocline-repl
  (:use :cl)
  (:import-from #:styled-strings
                #:format-styled
                #:make-styled-string)
  (:local-nicknames (:ic :isocline)
                    (:ec :eclector.reader)
                    (:ecst :eclector.concrete-syntax-tree)
                    (:cst :concrete-syntax-tree))
  (:shadow #:break)
  (:export #:*history-file*
           #:*read-function*
           #:*output-marker*
           #:*values-separator*
           #:*debugger-enabled-p*
           #:backtrace-as-list
           #:with-truncated-backtrace
           #:debugger
           #:main
           #:repl
           #:break))

(in-package :isocline-repl)

(defvar *history-file*)

(defvar *debug-level* 0)

(defvar *debugger-enabled-p* t
  "When non-NIL, drops into a debugger where users can evaluate code to
inspect the stack or invoke a restart.")

(defvar *restarts*)

(defun prompt-indent ()
  (make-string (* 2 *debug-level*) :initial-element #\space))

(defun package-nick-or-name (package)
  (or (loop :for name :in (package-nicknames package)
            :with shortest-name := nil
            :with shortest-len := nil
            :do (let ((len (length (string name))))
                  (when (or (null shortest-len)
                            (< len shortest-len))
                    (setf shortest-name name
                          shortest-len  len)))
            :finally (return shortest-name))
      (package-name package)))

(defun prompt-string ()
  (if (zerop *debug-level*)
      (package-nick-or-name *package*)
      (format nil "~A\\[~D] ~A"
              (prompt-indent)
              *debug-level*
              (package-nick-or-name *package*))))

(defvar *eb-color-map*)

(defun eb-cache-color (object &optional color)
  (let ((count (car (alexandria:ensure-gethash object *eb-color-map* (cons 0 color)))))
    (when color
      (setf (gethash object *eb-color-map*) (cons (incf count) color)))
    (if (> count 1)
        (cdr (gethash object *eb-color-map*))
        nil)))

(defvar *backtrace-top-frame-number* 0)

(defun backtrace-as-list ()
  #+sbcl (sb-debug:backtrace-as-list)
  #+ccl (ccl:backtrace-as-list)
  #-(or sbcl ccl) (error "Not implemented!"))

(defmacro with-truncated-backtrace (() &body body)
  `(let ((*backtrace-top-frame-number* (length (backtrace-as-list))))
     (declare (special *backtrace-top-frame-number*))
     ,@body))

(defun print-error-and-backtrace (condition stream &optional backtrace)
  (let ((indent (prompt-indent))
        (s stream))
    ;; The error
    (let ((*print-case* :upcase))
      (format s "~%    ~A" indent)
      (format-styled s "~S: ~A"
                     (list (class-name (class-of condition))
                           condition)
                     :foreground :red
                     :underline t
                     :italics t)
      (format s "~%~%"))
    ;; The backtrace
    #-(or sbcl ccl)
    (pprint-logical-block (s nil :per-line-prefix indent)
      (uiop:print-backtrace :condition t :stream s)
      (terpri s))
    #+(or sbcl ccl)
    (let ((frame-depth -1)
          (colors (set-difference (nconc (alexandria:iota 15 :start 1)
                                         (alexandria:iota 13 :start 39)
                                         (alexandria:iota 13 :start 75)
                                         (alexandria:iota 9 :start 115)
                                         (alexandria:iota 85 :start 147))
                                  ;; Exclude lighter shades
                                  '(0 7 15)))
          ;; CCL provides backtrace arguments as strings!
          (*eb-color-map* (make-hash-table :test #+sbcl #'eql #+ccl #'equal)))
      (format s "  ~ABacktrace:~%" indent)
      (block print-backtrace
        (mapc (lambda (funcall)
                (destructuring-bind (fun &rest fun-args) funcall
                  (eb-cache-color fun (alexandria:random-elt colors))
                  (mapcar (lambda (arg)
                            (eb-cache-color arg (alexandria:random-elt colors)))
                          fun-args)))
              (butlast backtrace *backtrace-top-frame-number*))
        (mapc (lambda (funcall)
                (destructuring-bind (fun &rest fun-args) funcall
                  (when (and *print-length*
                             (< *print-length* frame-depth))
                    (return-from print-backtrace nil))
                  (write-string "  " s)
                  (write-string indent s)
                  (write-string "  " s)
                  (write (incf frame-depth) :stream s)
                  (write-string ": " s)
                  (format s "(~{~A~^ ~})~%"
                          (list*
                           (format-styled nil "~S" fun
                                          :foreground (eb-cache-color fun))
                           (mapcar (lambda (arg)
                                     ;; CCL provides arguments as strings!
                                     (format-styled nil #+ccl "~A" #-ccl "~S" arg
                                                    :foreground (eb-cache-color arg)))
                                   fun-args)))))
              (butlast backtrace *backtrace-top-frame-number*)))
      (terpri s)))
  (ic:term-reset))

(defun debugger (condition hook)
  (declare (ignore hook))
  (if *debugger-enabled-p*
      (let ((*debug-level* (1+ *debug-level*))
            (*debugger-hook* #'debugger)
            (indent (prompt-indent)))
        (print-error-and-backtrace condition *debug-io* (backtrace-as-list))
        ;; The restarts
        (ic:term-style "ic-hint")
        (let ((*restarts* (compute-restarts condition)))
          (write-string (with-output-to-string (s)
                          (format s "  ~AAvailable restarts [Type :r1 :r2 etc]:~%" indent)
                          (loop :for i :from 0
                                :for r :in *restarts*
                                :do (format s "  ~A  [~A] [~A]: ~A~%"
                                            indent
                                            (format-styled nil ":r~D" i
                                                           :foreground :bright-green)
                                            (make-styled-string
                                             (string-upcase (restart-name r))
                                             :foreground :bright-green)
                                            (format-styled nil "~A" r
                                             :foreground :green))))
                        *debug-io*)
          (terpri *debug-io*)
          (force-output *debug-io*)
          (ic:term-reset)
          (repl)))
      (progn
        (print-error-and-backtrace condition *error-output* (backtrace-as-list))
        (invoke-restart 'top-level-repl))))

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

(defvar *output-marker* ";=>")
(defvar *values-separator* ", ")

(defun read-print-eval-processing-errors (input)
  (let* ((*debugger-hook* #'debugger)
         (input (string-trim '(#\space #\tab #\newline #\return) input)))
    (with-input-from-string (in input)
      (loop :while (listen in)
            :for form := (funcall *read-function* in)
            :for results := (multiple-value-list (with-truncated-backtrace () (eval form)))
            :do (unless (zerop *debug-level*)
                  (may-be-invoke-restart (first results)))
                (ic:term-italic t)
                (ic:println (with-output-to-string (*standard-output*)
                              (write-string *output-marker*)
                              (write-string (prompt-indent))
                              (loop :for i :from 0
                                    :for result :in results
                                    :do (unless (zerop i)
                                          (write-string *values-separator*))
                                        (write result))
                              (terpri)))
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

;; The SBCL 2.6.3 implementation of break as well as the following CLHS issue
;; recomment that cl:break should set *debugger-hook* to NIL.
;; Thus, we provide our own break.
;; http://www.ai.mit.edu/projects/iiip/doc/CommonLISP/HyperSpec/Issues/iss091-writeup.html
(defun break (&optional (format-control "Break") &rest format-arguments)
  (with-simple-restart (continue "Return from BREAK.")
    (let ((*debugger-hook* #'debugger))
      (invoke-debugger
       (make-condition 'simple-condition
                       :format-control format-control
                       :format-arguments format-arguments))))
  nil)

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
               (input-len (cffi:foreign-funcall "strlen" :pointer input :size))
               (cursor-position (cffi:foreign-slot-value cenv '(:struct ic:completion-env) 'ic:cursor))
               (colon-position (loop :for i :from cursor-position :above -1
                                     :if (= (char-code #\:)
                                            (cffi:mem-ref input :char i))
                                       :do (return i)))
               (internal-symbols-p (or (not colon-position)
                                       (and colon-position
                                            (< 0 colon-position)
                                            (= (char-code #\:)
                                               (cffi:mem-ref input :char (1- colon-position))))))
               (pkg-name-end (if (and colon-position
                                      internal-symbols-p)
                                 (max 0 (1- colon-position))
                                 colon-position))

               (pkg-name-start (when colon-position
                                 (or (loop :for i :from pkg-name-end :above -1
                                           :for ch := (cffi:mem-ref input :char i)
                                           :if (terminating-char-p (code-char ch))
                                             :do (return i))
                                     -1)))
               (pkg-prefix (when colon-position
                             (cffi:foreign-string-to-lisp
                              input
                              :offset (1+ pkg-name-start)
                              :count (- pkg-name-end pkg-name-start 1))))

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
    ((cenv (:pointer (:struct ic:completion-env)))
     (prefix :string))
  (declare (optimize (speed 1) safety debug))
  (ic:complete-word cenv prefix (cffi:callback word-completer) (cffi:null-pointer)))

(defclass non-interning-cst-client (ecst:cst-client) ())
(defvar *non-interning-cst-client* (make-instance 'non-interning-cst-client))
(defstruct uninterned-symbol package name)
(defstruct non-existent-package (name))

(defmethod ec:interpret-symbol-token ((client non-interning-cst-client)
                                      (input-stream t)
                                      (token t)
                                      (position-package-marker-1 t)
                                      (position-package-marker-2 t))
  ;; This is a minor modification of the method with (client t) specialization.
  ;; The modification is that the call to interpret-symbol has internp set to nil
  (let ((package-markers-end (or position-package-marker-2
                                 position-package-marker-1)))
    (flet ((interpret (package symbol)
             (handler-bind (((or ec:symbol-is-not-external
                                 ec:symbol-does-not-exist)
                              (lambda (c)
                                (let ((package (ec:desired-symbol-package c))
                                      (name (ec:desired-symbol-name c)))
                                  (multiple-value-bind (symbol status) (find-symbol name package)
                                    (when status
                                      (setf package (symbol-package symbol))))
                                  (invoke-restart 'ec::use-value
                                                  (make-uninterned-symbol
                                                   :package package
                                                   :name name)))))
                            (ec:package-does-not-exist
                              (lambda (c)
                                (invoke-restart 'ec::use-value
                                                (make-non-existent-package
                                                 :name (ec:desired-package-name c))))))
               (ec:interpret-symbol client input-stream package symbol nil))))
      (cond ((null position-package-marker-1)
             (interpret :current token))
            ((zerop position-package-marker-1)
             ;; We use PACKAGE-MARKERS-END so we can handle ::foo
             ;; which can happen when recovering from errors.
             (interpret :keyword
                        (subseq token (1+ package-markers-end))))
            ((not (null position-package-marker-2))
             (interpret (subseq token 0 position-package-marker-1)
                        (subseq token (1+ position-package-marker-2))))
            (t
             (interpret (subseq token 0 position-package-marker-1)
                        (subseq token (1+ position-package-marker-1))))))))

(cffi:defcallback highlighter :void
    ((henv (:pointer (:struct ic:highlight-env)))
     (input :string)
     (arg :pointer))
  (declare (optimize (speed 1) safety debug)
           (ignore arg))
  (multiple-value-bind (input-cst error)
      (ignore-errors (handler-bind ()
                       ;; We use ECST because we want to preserve source information
                       (let ((ecst::*cst-client* *non-interning-cst-client*))
                         (nth-value 0 (ecst:read-from-string input)))))
    (labels ((highlight (elt carp)
               (let* ((raw (cst:raw elt))
                      (pos (cst:source elt))
                      (start (car pos))
                      (length (when start (- (cdr pos) (car pos))))
                      (hl-class (cond ((vectorp raw) "string")
                                      ((numberp raw) "number")
                                      ((symbolp raw)
                                       (if carp
                                           (when (eq (find-package :cl)
                                                     (symbol-package raw))
                                             "keyword")
                                           (when (find-class raw nil)
                                             "type")))
                                      ((uninterned-symbol-p raw)
                                       (with-slots (name package) raw
                                         (if carp
                                             (when (eq package (find-package :cl))
                                               "keyword")
                                             (when (find-class (find-symbol name package) nil)
                                               "type")))))))
                 (when (and start hl-class)
                   (ic:highlight henv start length hl-class))))
             (traverse (tree)
               (if (cst:atom tree)
                   (highlight tree nil)
                   (progn
                     (highlight (cst:first tree) t)
                     (dotimes (i (1- (length (cst:raw tree))))
                       (traverse (cst:nth (1+ i) tree)))))))
      (unless error
        (traverse input-cst)))))

(defun main ()
  (setf *history-file*
        (uiop:native-namestring
         (merge-pathnames ".cl-isocline-repl" (user-homedir-pathname))))
  (setf cl:*print-length* 10)
  (ic:set-default-completer (cffi:callback completer) (cffi:null-pointer))
  (ic:set-default-highlighter (cffi:callback highlighter) (cffi:null-pointer))
  (ic:set-prompt-marker "> " "")
  (ic:enable-multiline-indent nil)
  (repl))
