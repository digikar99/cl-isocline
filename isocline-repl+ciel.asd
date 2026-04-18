(asdf:defsystem "isocline-repl+ciel"
  :depends-on ("isocline-repl"
               "ciel")
  :license "MIT"
  :author "Shubhamkar Ayare (digikar@proton.me)"
  :version "0.0.0"
  :pathname "lisp/"
  :build-operation "program-op"
  :build-pathname "../cl-isocline-repl+ciel"
  :entry-point "isocline-repl:main")
