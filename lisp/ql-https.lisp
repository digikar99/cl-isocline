(in-package :ql-https)

(defun ensure-ssl-tools ()
  (loop :for program :in '("curl" "openssl" "tar" "git")
        :do (uiop:run-program (list "which" program) :error t)))

(defvar *quicklisp-sexp-url* "https://beta.quicklisp.org/client/quicklisp.sexp")

(defvar *ql-https-url* "https://github.com/rudolfochrist/ql-https")

(defvar *ql-https-dir* (uiop:strcat (uiop:getenv "HOME") "/common-lisp/ql-https"))


(defun install-quicklisp-client (&optional (dir ql-setup:*quicklisp-home*))
  (let* ((quicklisp-sexp
           (read-from-string
            (progn
              (format t "Downloading quicklisp metadata...~%")
              (uiop:run-program (list "curl" *quicklisp-sexp-url*)
                                :output :string
                                :error-output t))))
         (client-tar (getf quicklisp-sexp :client-tar))
         (client-url (getf client-tar :url))
         (client-url
           ;; This will necessarily be https
           (if (uiop:string-prefix-p "https" client-url)
               client-url
               (uiop:strcat "https" (subseq client-url 4))))
         (expected-client-sha256 (getf client-tar :sha256))
         (client-tar-path
           (namestring
            (merge-pathnames "quicklisp.tar" dir))))

    (format t "Downloading quicklisp client...~%")
    (uiop:run-program (format nil "curl -s '~A' -o ~A"
                              client-url
                              client-tar-path)
                      :output t
                      :error-output t)

    (let ((obtained-client-sha256
            (second
             (uiop:split-string
              (uiop:run-program
               (format nil "openssl dgst -sha256 ~A" client-tar-path)
               :output '(:string :stripped t)
               :error-output t)))))

      (assert (string= obtained-client-sha256
                       expected-client-sha256)))

    (uiop:run-program (format nil "tar xf ~A -C ~A" client-tar-path dir)
                      :output t :error-output t)

    (uiop:delete-file-if-exists client-tar-path)))



(defun install-ql-https ()
  (uiop:run-program (list "git" "clone" *ql-https-url* *ql-https-dir*)
                    :output t
                    :error-output t))

(defun ql-https-setup (&optional (dir ql-setup:*quicklisp-home*))
  (with-open-file (f (merge-pathnames "setup.lisp" dir)
                     :if-exists :supersede
                     :if-does-not-exist :create
                     :direction :output)
    (write-string "(require 'asdf)
(let ((quicklisp-init #p\"~/common-lisp/ql-https/ql-setup.lisp\"))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)
    (asdf:load-system \"ql-https\")
    (uiop:symbol-call :quicklisp :setup)))

;; optional
#+ql-https
(setf ql-https:*quietly-use-https* t)"
                  f)
    t))


(defun install-quicklisp (&optional (dir ql-setup:*quicklisp-home*))

  (ensure-ssl-tools)
  (ensure-directories-exist dir)
  (install-quicklisp-client dir)
  (install-ql-https)

  (load (uiop:strcat *ql-https-dir* "/ql-setup.lisp"))
  (assert (equalp ql-http:*fetch-scheme-functions*
                  '(("http" . ql-https:fetcher)
                    ("https" . ql-https:fetcher))))
  (setf ql-https:*quietly-use-https* t)
  (quicklisp:setup)
  (ql-util:without-prompting (ql:add-to-init-file))

  (ql-https-setup dir))

(defun quicklisp-installed-p (&optional (dir ql-setup:*quicklisp-home*))
  (uiop:directory-exists-p dir))

(defun ensure-quicklisp
    (&optional (quicklisp-home ql-setup:*quicklisp-home*))
  (let ((ql:*quicklisp-home* quicklisp-home)
        (dir quicklisp-home))
    (if (quicklisp-installed-p dir)
        (format *error-output*
                "Cannot install Quicklisp because it seems it is already installed!~%Please check ~A~%" dir)
        (install-quicklisp dir))))

(export 'ensure-quicklisp)
