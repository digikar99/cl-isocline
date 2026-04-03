(cl:in-package :isocline)

(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (cl:defvar *isocline-root-directory*
    (uiop:pathname-parent-directory-pathname
     (asdf:component-pathname
      (asdf:find-system "isocline")))))

(cffi:define-foreign-library libisocline
  (cl:t #.(cl:let ((shared-library-pathname
                     (cl:merge-pathnames (cl:ecase (uiop:operating-system)
                                           (:macosx #P"libisocline.dylib")
                                           (:linux #P"libisocline.so")
                                           (:win #P"libisocline.dll"))
                                         *isocline-root-directory*)))
            (cl:unless (cl:probe-file shared-library-pathname)
              (uiop:with-current-directory (*isocline-root-directory*)
                (uiop:run-program
                 (cl:format cl:nil "gcc -shared -o ~A -Iinclude -fpic isocline/src/isocline.c"
                            (cl:file-namestring shared-library-pathname))
                 :output cl:t
                 :error-output cl:t)))
            shared-library-pathname)))

(cffi:load-foreign-library 'libisocline)
