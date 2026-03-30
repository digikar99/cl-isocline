(asdf:defsystem "isocline"
  :depends-on ("alexandria"
               "cffi")
  :license "MIT"
  :author "Shubhamkar Ayare (digikar@proton.me)"
  :version "0.0.0"
  :pathname "lisp/"
  :components ((:file "package")
               (:file "isocline")
               (:file "shared-object")))
