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
              (uiop:run-program
               (cl:format cl:nil
                          "cd '~A' && gcc -shared -o libisocline.so -Iinclude -fpic isocline/src/isocline.c"
                          (cl:namestring *isocline-root-directory*))
               :output cl:t
               :error-output cl:t))
            shared-library-pathname)))

(cffi:load-foreign-library 'libisocline)
