(require 'ert)
(require 'cl-lib)
(require 'blogmore)

(defconst blogmore--test-titles
  '(("" . "")
    ("Hello World!" . "hello-world")
    ("Emacs & Lisp" . "emacs-lisp")
    ("2026: A Blog Odyssey" . "2026-a-blog-odyssey")))

(ert-deftest blogmore--slug-test ()
  "Test that blogmore--slug produces expected slugs."
  (dolist (case blogmore--test-titles)
    (should (equal (blogmore--slug (car case)) (cdr case)))))

(ert-deftest blogmore--file-from-title-test ()
  "Test filename generation from post titles."
  (let ((blogmore--current-blog (make-blogmore--blog :posts-directory "/tmp/"))
        (post-dir (format-time-string "%Y"))
        (today (format-time-string "%Y-%m-%d")))
    (dolist (case blogmore--test-titles)
      (should (string-match
               (format "/tmp/%s/%s-%s.md"
                       post-dir
                       today
                       (cdr case))
               (blogmore--file-from-title (car case)))))))

(ert-deftest blogmore--current-categories-test ()
  "Test extraction of categories from post content."
  (cl-letf (((symbol-function 'blogmore--get-all)
             (lambda (_)
               '("category: Z"
                 "category: Emacs"
                 "category: Lisp"
                 "category: Life"
                 "category: A"))))
    (should (equal (blogmore--current-categories) '("A" "Emacs" "Life" "Lisp" "Z")))))

(ert-deftest blogmore--current-tags-test ()
  "Test extraction of tags from post content."
  (cl-letf (((symbol-function 'blogmore--get-all)
             (lambda (_)
               '("tags: Emacs, Lisp"
                 "tags: Emacs, Org"
                 "tags: Lisp, Emacs"
                 "tags: Z, A"))))
    (should (equal (sort (blogmore--current-tags) #'string-lessp)
                   '("A" "Emacs" "Lisp" "Org" "Z")))))

;;; blogmore-tests.el ends here
