;;; gpc-test.el --- Tests for gpc

;;; Tests.

(ert-deftest gpc-set-spec-test/hash-table-generator ()
  (unintern "gpc-var")
  (gpc-set-spec gpc-var (make-hash-table))
  (should (hash-table-p (get 'gpc-var 'gpc-cache-spec))))

(ert-deftest gpc-set-spec-test/hash-table-variable ()
  (unintern "gpc-var")
  (setq ht (make-hash-table))
  (gpc-set-spec gpc-var ht)
  (should (hash-table-p (get 'gpc-var 'gpc-cache-spec))))

(ert-deftest gpc-get-spec-test ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (put 'gpc-var 'gpc-cache-spec (make-hash-table))
  (should (hash-table-p (gpc-get-spec gpc-var))))

(ert-deftest gpc-spec-set-entry-test ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (setq spec (gpc-get-spec gpc-var))
  (should (equal (gethash 'a spec) '(b (lambda () 'c)))))

(ert-deftest gpc-spec-get-entry-test ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (equal (gpc-spec-get-entry 'a gpc-var) '(b (lambda () 'c)))))

(ert-deftest gpc-spec-get-initval-test ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (eq (gpc-spec-get-initval 'a gpc-var) 'b)))

(ert-deftest gpc-spec-get-fetchfn-test ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (equal (gpc-spec-get-fetchfn 'a gpc-var) '(lambda () 'c))))

(ert-deftest gpc-spec-keyp-test/nil ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (should-not (gpc-spec-keyp 'a gpc-var)))

(ert-deftest gpc-spec-keyp-test/existent-key ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (gpc-spec-keyp 'a gpc-var)))

(ert-deftest gpc-spec-keyp-test/non-existent-key ()
  (unintern "gpc-var")
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should-not (gpc-spec-keyp 'b gpc-var)))

(ert-deftest gpc-util-hash-to-alist/hash-table-with-no-entry ()
  (setq ht (make-hash-table))
  (should (eq (gpc-util-hash-to-alist ht) nil)))

(ert-deftest gpc-util-hash-to-alist/hash-table-with-one-entry ()
  (setq ht (make-hash-table))
  (puthash 'a 'b ht)
  (should (equal (gpc-util-hash-to-alist ht) '((a . b)))))

(ert-deftest gpc-util-hash-to-alist/hash-table-with-two-entries ()
  (setq ht (make-hash-table))
  (puthash 'a 'b ht)
  (puthash 'c 'd ht)
  (should (nalist-set-equal-p (gpc-util-hash-to-alist ht) '((a . b) (c . d)))))

(ert-deftest gpc-util-alist-to-hash/alist-is-nil ()
  (setq alist nil)
  (should (= (hash-table-count (gpc-util-alist-to-hash alist)) 0)))

(ert-deftest gpc-util-alist-to-hash/alist-with-one-pair ()
  (setq alist '((a . b)))
  (setq ht (gpc-util-alist-to-hash alist))
  (should (= (hash-table-count ht) 1))
  (should (eq (gethash 'a ht) 'b)))

(ert-deftest gpc-util-alist-to-hash/alist-with-two-pairs ()
  (setq alist '((a . b) (c . d)))
  (setq ht (gpc-util-alist-to-hash alist))
  (should (= (hash-table-count ht) 2))
  (should (eq (gethash 'a ht) 'b))
  (should (eq (gethash 'c ht) 'd)))

(ert-deftest gpc-init-test/spec-with-no-entry ()
  (unintern "gpc-var")
  (gpc-init gpc-var nil)
  (should (eq gpc-var nil))
  (should (eq (hash-table-count (gpc-get-spec gpc-var)) 0)))

(ert-deftest gpc-init-test/spec-with-one-entry ()
  (unintern "gpc-var")
  (gpc-init gpc-var '((a b (lambda () nil))))
  (should (eq gpc-var nil))
  (should (eq (gpc-spec-get-initval 'a gpc-var) 'b))
  (should (equal (gpc-spec-get-fetchfn 'a gpc-var) '(lambda () nil))))

(ert-deftest gpc-init-test/spec-with-two-entries ()
  (unintern "gpc-var")
  (gpc-init gpc-var '((a b (lambda () nil))
                      (c d (lambda () t))))
  (should (eq gpc-var nil))
  (should (eq (gpc-spec-get-initval 'a gpc-var) 'b))
  (should (eq (gpc-spec-get-initval 'c gpc-var) 'd))
  (should (equal (gpc-spec-get-fetchfn 'a gpc-var) '(lambda () nil)))
  (should (equal (gpc-spec-get-fetchfn 'c gpc-var) '(lambda () t))))

(ert-deftest gpc-overwrite-with-initvals-test/spec-with-no-entry ()
  (unintern "gpc-var")
  (gpc-init gpc-var nil)
  (gpc-overwrite-with-initvals gpc-var)
  (should (eq gpc-var nil)))

(ert-deftest gpc-overwrite-with-initvals-test/spec-with-one-entry ()
  (unintern "gpc-var")
  (gpc-init gpc-var '((a b (lambda () nil))))
  (gpc-overwrite-with-initvals gpc-var)
  (should (= (length gpc-var) 1))
  (should (eq (gpc-val 'a gpc-var) 'b)))

(ert-deftest gpc-overwrite-with-initvals-test/spec-with-two-entries ()
  (unintern "gpc-var")
  (gpc-init gpc-var '((a b (lambda () nil))
                      (c d (lambda () t))))
  (gpc-overwrite-with-initvals gpc-var)
  (should (= (length gpc-var) 2))
  (should (eq (gpc-val 'a gpc-var) 'b))
  (should (eq (gpc-val 'c gpc-var) 'd)))

(ert-deftest gpc-fetch-test ()
  (unintern "gpc-var")
  (setq system-value (with-temp-buffer
                       (call-process "uname" nil t)
                       (s-chop-suffix "\n" (buffer-string))))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (with-temp-buffer
                                         (call-process "uname" nil t)
                                         (s-chop-suffix "\n" (buffer-string)))))))
  (should (equal (gpc-fetch 'system gpc-var) system-value)))

(ert-deftest gpc-get-test ()
  (unintern "gpc-var")
  (setq system-value (with-temp-buffer
                       (call-process "uname" nil t)
                       (s-chop-suffix "\n" (buffer-string))))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (with-temp-buffer
                                         (call-process "uname" nil t)
                                         (s-chop-suffix "\n" (buffer-string)))))))
  (gpc-overwrite-with-initvals gpc-var)
  (should (equal (gpc-get 'system gpc-var) "Hurd"))
  (gpc-clear gpc-var)
  (should (equal (gpc-get 'system gpc-var) system-value)))

(ert-deftest gpc-fetch-all-test/no-entry ()
  (unintern "gpc-var")
  (gpc-init gpc-var nil)
  (gpc-fetch-all gpc-var)
  (should (eq gpc-var nil)))

(ert-deftest gpc-fetch-all-test/one-entry ()
  (unintern "gpc-var")
  (setq system-value (with-temp-buffer
                       (call-process "uname" nil t)
                       (s-chop-suffix "\n" (buffer-string))))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (with-temp-buffer
                                         (call-process "uname" nil t)
                                         (s-chop-suffix "\n" (buffer-string)))))))
  (gpc-fetch-all gpc-var)
  (should (equal (gpc-fetch 'system gpc-var) system-value)))

(ert-deftest gpc-fetch-all-test/two-entries ()
  (unintern "gpc-var")
  (setq system-value (with-temp-buffer
                       (call-process "uname" nil t)
                       (s-chop-suffix "\n" (buffer-string))))
  (setq machine-value (with-temp-buffer
                        (call-process "uname" nil t nil "-m")
                        (s-chop-suffix "\n" (buffer-string))))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (with-temp-buffer
                                         (call-process "uname" nil t)
                                         (s-chop-suffix "\n" (buffer-string)))))
                      (machine "mips" (lambda ()
                                        (with-temp-buffer
                                          (call-process "uname" nil t nil "-m")
                                          (s-chop-suffix "\n" (buffer-string)))))))
  (gpc-fetch-all gpc-var)
  (should (equal (gpc-fetch 'system gpc-var) system-value))
  (should (equal (gpc-fetch 'machine gpc-var) machine-value)))

;; FIXME: This test of the feature should be more testing friendly.
(ert-deftest namespace-pollution-test ()
  (should (if gpc-namespace-pollution
              (eq (fboundp 'defgpc) t)
            (eq (fboundp 'defgpc) nil))))

(ert-deftest gpc-map-test/spec-is-nil ()
  (unintern "gpc-var")
  (gpc-init gpc-var nil)
  (let ((res nil))
    (gpc-spec-map '(lambda (k v f) (push (list k v f) res)) gpc-var)
    (should (eq res nil))))

(ert-deftest gpc-map-test/spec-has-one-entry ()
  (unintern "gpc-var")
  (gpc-init gpc-var '((a b (lambda () nil))))
  (let ((res nil))
    (gpc-spec-map '(lambda (k v f) (push (list k v f) res)) gpc-var)
    (should (equal res '((a b (lambda () nil)))))))

(ert-deftest gpc-map-test/spec-has-one-entry ()
  (unintern "gpc-var")
  (gpc-init gpc-var '((a b (lambda () nil))
                      (c d (lambda () t))))
  (let ((res nil))
    (gpc-spec-map '(lambda (k v f) (push (list k v f) res)) gpc-var)
    (should (nalist-set-equal-p res '((a b (lambda () nil))
                                      (c d (lambda () t)))))))

(ert-deftest gpc-defgpc-test/global/is-a-special-variable ()
  (unintern "gpc-var-g")
  (gpc-defgpc gpc-var-g :global nil)
  (should (special-variable-p 'gpc-var-g)))

(ert-deftest gpc-defgpc-test/global/is-not-buffer-local ()
  (unintern "gpc-var-g")
  (gpc-defgpc gpc-var-g :global nil)
  (should-not (local-variable-p 'gpc-var-g)))

(ert-deftest gpc-defgpc-test/global/is-not-automatically-buffer-local ()
  (unintern "gpc-var-g")
  (gpc-defgpc gpc-var-g :global nil)
  (should-not (local-variable-if-set-p 'gpc-var-g)))

(ert-deftest gpc-defgpc-test/buffer-local/is-a-special-variable ()
  (unintern "gpc-var-abl")
  (gpc-defgpc gpc-var-abl :buffer-local nil)
  (should (special-variable-p 'gpc-var-abl)))

(ert-deftest gpc-defgpc-test/buffer-local/is-buffer-local ()
  (unintern "gpc-var-abl")
  (gpc-defgpc gpc-var-abl :buffer-local nil)
  (should (local-variable-p 'gpc-var-abl)))

(ert-deftest gpc-defgpc-test/buffer-local/is-automatically-buffer-local ()
  (unintern "gpc-var-abl")
  (gpc-defgpc gpc-var-abl :buffer-local nil)
  (should (local-variable-if-set-p 'gpc-var-abl)))

(ert-deftest gpc-defgpc-test/spec-with-no-entry ()
  (unintern "gpc-var-g")
  (gpc-defgpc gpc-var-g :global nil)
  (should (= (hash-table-count (gpc-get-spec gpc-var-g)) 0)))

(ert-deftest gpc-defgpc-test/spec-with-one-entry ()
  (unintern "gpc-var-g")
  (gpc-defgpc gpc-var-g :global
    nil
    (a b (lambda () nil)))
  (should (equal (gpc-util-hash-to-alist (gpc-get-spec gpc-var-g))
                 '((a b (lambda () nil))))))

(ert-deftest gpc-defgpc-test/spec-with-two-entries ()
  (unintern "gpc-var-g")
  (gpc-defgpc gpc-var-g :global
    nil
    (a b (lambda () nil))
    (c d (lambda () t)))
  (should (nalist-set-equal-p (gpc-util-hash-to-alist (gpc-get-spec gpc-var-g))
                              '((a b (lambda () nil)) (c d (lambda () t))))))

(ert-deftest gpc-defgpc-test/doc-string ()
  (unintern "gpc-var-g")
  (gpc-defgpc gpc-var-g :global "Documentation for gpc-var-g.")
  (should (equal (documentation-property 'gpc-var-g 'variable-documentation)
                 "Documentation for gpc-var-g.")))

;; Local Variables:
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:

;;; gpc-test.el ends here
