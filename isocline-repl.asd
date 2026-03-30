(asdf:defsystem "isocline-repl"
  :depends-on ("isocline")
  :license "MIT"
  :author "Shubhamkar Ayare (digikar@proton.me)"
  :version "0.0.0"
  :pathname "lisp/"
  :build-operation "program-op"
  :build-pathname "../cl-isocline-repl"
  :entry-point "isocline-repl:run"
  :components ((:file "isocline-repl")))


#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  ;; (eval (print
  ;;        `(push :sb-aclrepl ,(find-symbol "*CONTRIB-BLACKLIST*" :cl-repl))))
  ;; (uiop:symbol-call :cl-repl '#:require-all-contribs)
  (uiop:dump-image (asdf:output-file o c)
                   :executable t
                   :compression t))

