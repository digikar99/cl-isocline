(asdf:defsystem "isocline-repl"
  :depends-on ("isocline"
               "ql-https"
               "eclector-concrete-syntax-tree"
               "trivial-backtrace"
               "uiop")
  :license "MIT"
  :author "Shubhamkar Ayare (digikar@proton.me)"
  :version "0.0.0"
  :pathname "lisp/"
  :build-operation "program-op"
  :build-pathname "../cl-isocline-repl"
  :entry-point "isocline-repl:main"
  :components ((:file "isocline-repl")
               (:file "contribs" :if-feature :sbcl)
               (:file "ql-https")))


#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  ;; I had first developed the contrib part for "SBCL-PLUS-CONTRIB" which is supposed
  ;; to be an SBCL image with all the contribs already loaded.
  (when (member :sbcl cl:*features*)
    (eval (print
           `(push :sb-aclrepl ,(find-symbol "*CONTRIB-BLACKLIST*" :isocline-repl))))
    (uiop:symbol-call :isocline-repl '#:require-all-contribs))
  (uiop:dump-image (asdf:output-file o c)
                   :executable t
                   :compression t))
