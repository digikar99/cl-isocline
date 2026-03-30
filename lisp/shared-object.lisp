(cl:in-package :isocline)

(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (cl:defvar *isocline-root-directory*
    (uiop:pathname-parent-directory-pathname
     (asdf:component-pathname
      (asdf:find-system "isocline")))))

(cffi:define-foreign-library libisocline
  (cl:t #.(cl:let ((shared-library-pathname
                     (cl:merge-pathnames #P"libisocline.so"
                                         *isocline-root-directory*)))
            (cl:unless (cl:probe-file shared-library-pathname)
              (uiop:with-current-directory (*isocline-root-directory*)
                (uiop:run-program
                 "gcc -shared -o libisocline.so -Iinclude -fpic isocline/src/isocline.c"
                 :output cl:t
                 :error-output cl:t)))
            shared-library-pathname)))

(cffi:load-foreign-library 'libisocline)
