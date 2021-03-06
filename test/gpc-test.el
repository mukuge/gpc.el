;;; gpc-test.el --- Tests for gpc

;;; Tests.

(ert-deftest gpc-set-spec-test/hash-table-generator ()
  (unintern "gpc-var" nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (should (hash-table-p (get 'gpc-var 'gpc-cache-spec))))

(ert-deftest gpc-set-spec-test/hash-table-variable ()
  (unintern "gpc-var" nil)
  (setq ht (make-hash-table))
  (gpc-set-spec gpc-var ht)
  (should (hash-table-p (get 'gpc-var 'gpc-cache-spec))))

(ert-deftest gpc-get-spec-test ()
  (unintern "gpc-var" nil)
  (setq gpc-var nil)
  (put 'gpc-var 'gpc-cache-spec (make-hash-table))
  (should (hash-table-p (gpc-get-spec gpc-var))))

(ert-deftest gpc-spec-set-entry-test ()
  (unintern "gpc-var" nil)
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (setq spec (gpc-get-spec gpc-var))
  (should (equal (gethash 'a spec) '(b (lambda () 'c)))))

(ert-deftest gpc-spec-get-entry-test ()
  (unintern "gpc-var" nil)
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (equal (gpc-spec-get-entry 'a gpc-var) '(b (lambda () 'c)))))

(ert-deftest gpc-spec-get-initval-test ()
  (unintern "gpc-var" nil)
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (eq (gpc-spec-get-initval 'a gpc-var) 'b)))

(ert-deftest gpc-spec-get-fetchfn-test ()
  (unintern "gpc-var" nil)
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (equal (gpc-spec-get-fetchfn 'a gpc-var) '(lambda () 'c))))

(ert-deftest gpc-spec-keyp-test/nil ()
  (unintern "gpc-var" nil)
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (should-not (gpc-spec-keyp 'a gpc-var)))

(ert-deftest gpc-spec-keyp-test/existent-key ()
  (unintern "gpc-var" nil)
  (setq gpc-var nil)
  (gpc-set-spec gpc-var (make-hash-table))
  (gpc-spec-set-entry 'a 'b '(lambda () 'c) gpc-var)
  (should (gpc-spec-keyp 'a gpc-var)))

(ert-deftest gpc-spec-keyp-test/non-existent-key ()
  (unintern "gpc-var" nil)
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
  (unintern "gpc-var" nil)
  (gpc-init gpc-var nil)
  (should (eq gpc-var nil))
  (should (eq (hash-table-count (gpc-get-spec gpc-var)) 0)))

(ert-deftest gpc-init-test/spec-with-one-entry ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((a b (lambda () nil))))
  (should (eq gpc-var nil))
  (should (eq (gpc-spec-get-initval 'a gpc-var) 'b))
  (should (equal (gpc-spec-get-fetchfn 'a gpc-var) '(lambda () nil))))

(ert-deftest gpc-init-test/spec-with-two-entries ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((a b (lambda () nil))
                      (c d (lambda () t))))
  (should (eq gpc-var nil))
  (should (eq (gpc-spec-get-initval 'a gpc-var) 'b))
  (should (eq (gpc-spec-get-initval 'c gpc-var) 'd))
  (should (equal (gpc-spec-get-fetchfn 'a gpc-var) '(lambda () nil)))
  (should (equal (gpc-spec-get-fetchfn 'c gpc-var) '(lambda () t))))

(ert-deftest gpc-overwrite-with-initvals-test/spec-with-no-entry ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var nil)
  (gpc-overwrite-with-initvals gpc-var)
  (should (eq gpc-var nil)))

(ert-deftest gpc-overwrite-with-initvals-test/spec-with-one-entry ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((a b (lambda () nil))))
  (gpc-overwrite-with-initvals gpc-var)
  (should (= (length gpc-var) 1))
  (should (eq (gpc-val 'a gpc-var) 'b)))

(ert-deftest gpc-overwrite-with-initvals-test/spec-with-two-entries ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((a b (lambda () nil))
                      (c d (lambda () t))))
  (gpc-overwrite-with-initvals gpc-var)
  (should (= (length gpc-var) 2))
  (should (eq (gpc-val 'a gpc-var) 'b))
  (should (eq (gpc-val 'c gpc-var) 'd)))

(ert-deftest gpc-fetch-test ()
  (unintern "gpc-var" nil)
  (setq system-value (s-chop-suffix "\n" (shell-command-to-string "uname")))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (should (equal (gpc-fetch 'system gpc-var) system-value)))

(ert-deftest gpc-get-test ()
  (unintern "gpc-var" nil)
  (setq system-value (s-chop-suffix "\n" (shell-command-to-string "uname")))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-overwrite-with-initvals gpc-var)
  (should (equal (gpc-get 'system gpc-var) "Hurd"))
  (gpc-clear gpc-var)
  (should (equal (gpc-get 'system gpc-var) system-value)))

(ert-deftest gpc-fetch-all-test/no-entry ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var nil)
  (gpc-fetch-all gpc-var)
  (should (eq gpc-var nil)))

(ert-deftest gpc-fetch-all-test/one-entry ()
  (unintern "gpc-var" nil)
  (setq system-value (s-chop-suffix "\n" (shell-command-to-string "uname")))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-fetch-all gpc-var)
  (should (equal (gpc-val 'system gpc-var) system-value)))

(ert-deftest gpc-fetch-all-test/two-entries ()
  (unintern "gpc-var" nil)
  (setq system-value (s-chop-suffix "\n" (shell-command-to-string "uname")))
  (setq machine-value (s-chop-suffix "\n" (shell-command-to-string "uname -m")))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))
                      (machine "mips" (lambda ()
                                        (s-chop-suffix "\n" (shell-command-to-string "uname -m"))))))
  (gpc-fetch-all gpc-var)
  (should (equal (gpc-val 'system gpc-var) system-value))
  (should (equal (gpc-val 'machine gpc-var) machine-value)))

(ert-deftest gpc-map-test/spec-is-nil ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var nil)
  (let ((res nil))
    (gpc-spec-map '(lambda (k v f) (push (list k v f) res)) gpc-var)
    (should (eq res nil))))

(ert-deftest gpc-map-test/spec-has-one-entry ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((a b (lambda () nil))))
  (let ((res nil))
    (gpc-spec-map '(lambda (k v f) (push (list k v f) res)) gpc-var)
    (should (equal res '((a b (lambda () nil)))))))

(ert-deftest gpc-map-test/spec-has-one-entry ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((a b (lambda () nil))
                      (c d (lambda () t))))
  (let ((res nil))
    (gpc-spec-map '(lambda (k v f) (push (list k v f) res)) gpc-var)
    (should (nalist-set-equal-p res '((a b (lambda () nil))
                                      (c d (lambda () t)))))))

(ert-deftest defcache-test/global/is-a-special-variable ()
  (unintern "gpc-var-g" nil)
  (defcache gpc-var-g :global nil)
  (should (special-variable-p 'gpc-var-g)))

(ert-deftest defcache-test/global/is-not-buffer-local ()
  (unintern "gpc-var-g" nil)
  (defcache gpc-var-g :global nil)
  (should-not (local-variable-p 'gpc-var-g)))

(ert-deftest defcache-test/global/is-not-automatically-buffer-local ()
  (unintern "gpc-var-g" nil)
  (defcache gpc-var-g :global nil)
  (should-not (local-variable-if-set-p 'gpc-var-g)))

(ert-deftest defcache-test/buffer-local/is-a-special-variable ()
  (unintern "gpc-var-abl" nil)
  (defcache gpc-var-abl :buffer-local nil)
  (should (special-variable-p 'gpc-var-abl)))

(ert-deftest defcache-test/buffer-local/is-buffer-local ()
  (unintern "gpc-var-abl" nil)
  (defcache gpc-var-abl :buffer-local nil)
  (should (local-variable-p 'gpc-var-abl)))

(ert-deftest defcache-test/buffer-local/is-automatically-buffer-local ()
  (unintern "gpc-var-abl" nil)
  (defcache gpc-var-abl :buffer-local nil)
  (should (local-variable-if-set-p 'gpc-var-abl)))

(ert-deftest defcache-test/spec-with-no-entry ()
  (unintern "gpc-var-g" nil)
  (defcache gpc-var-g :global nil)
  (should (= (hash-table-count (gpc-get-spec gpc-var-g)) 0)))

(ert-deftest defcache-test/spec-with-one-entry ()
  (unintern "gpc-var-g" nil)
  (defcache gpc-var-g :global
    nil
    (a b (lambda () nil)))
  (should (equal (gpc-util-hash-to-alist (gpc-get-spec gpc-var-g))
                 '((a b (lambda () nil))))))

(ert-deftest defcache-test/spec-with-two-entries ()
  (unintern "gpc-var-g" nil)
  (defcache gpc-var-g :global
    nil
    (a b (lambda () nil))
    (c d (lambda () t)))
  (should (nalist-set-equal-p (gpc-util-hash-to-alist (gpc-get-spec gpc-var-g))
                              '((a b (lambda () nil)) (c d (lambda () t))))))

(ert-deftest defcache-test/doc-string ()
  (unintern "gpc-var-g" nil)
  (defcache gpc-var-g :global "Documentation for gpc-var-g.")
  (should (equal (documentation-property 'gpc-var-g 'variable-documentation)
                 "Documentation for gpc-var-g.")))

(ert-deftest gpc-lock-test/no-lock ()
  ;; Use the name which is used only here to ensure we are testing the
  ;; untouched state of the symbol's propety lsit.  Actually, symbol's
  ;; propety list survives unintern sometime or allways.  Perhaps,
  ;; they are zombies from gc.
  (gpc-init gpc-var-gpc-lock-test/no-lock
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (should (eq (gpc-get-lock-list gpc-var-gpc-lock-test/no-lock) nil)))

(ert-deftest gpc-lock-test/one-lock ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (gpc-make-local-variable gpc-var)
    (gpc-lock gpc-var)
    (should (= (length (gpc-get-lock-list gpc-var)) 1))
    (should (gpc-helper-seq-set-equal-p (gpc-get-lock-list gpc-var) (list buffer-a)))))

(ert-deftest gpc-lock-test/two-locks ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a buffer-b)
    (set-buffer buffer-a)
    (gpc-lock gpc-var)
    (set-buffer buffer-b)
    (gpc-lock gpc-var)
    (should (= (length (gpc-get-lock-list gpc-var)) 2))
    (should (gpc-helper-seq-set-equal-p (gpc-get-lock-list gpc-var) (list buffer-a buffer-b)))))

(ert-deftest gpc-unlock-test/no-lock ()
  (gpc-init gpc-var-gpc-unlock-test/no-lock
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-unlock gpc-var-gpc-unlock-test/no-lock)
  (should (eq (gpc-get-lock-list gpc-var-gpc-unlock-test/no-lock) nil)))

(ert-deftest gpc-unlock-test/one-lock ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (gpc-lock gpc-var)
    (gpc-unlock gpc-var)
    (should (eq (gpc-get-lock-list gpc-var) nil))))

(ert-deftest gpc-unlock-test/two-locks-one-unlock ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a buffer-b)
    (set-buffer buffer-a)
    (gpc-lock gpc-var)
    (set-buffer buffer-b)
    (gpc-lock gpc-var)
    (gpc-unlock gpc-var)
    (should (gpc-helper-seq-set-equal-p (gpc-get-lock-list gpc-var) (list buffer-a)))))

(ert-deftest gpc-locked-p-test/no-lock ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (should-not (gpc-locked-p gpc-var))))

(ert-deftest gpc-locked-p-test/one-lock ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (gpc-lock gpc-var)
    (should (gpc-locked-p gpc-var))))

(ert-deftest gpc-locked-p-test/two-buffers-one-lock ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a buffer-b)
    (set-buffer buffer-a)
    (gpc-lock gpc-var)
    (set-buffer buffer-b)
    (should-not (gpc-locked-p gpc-var))
    (set-buffer buffer-a)
    (should (gpc-locked-p gpc-var))))

(ert-deftest gpc-lock-gc-test/one-lock-on-a-live-buffer ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (gpc-lock gpc-var)
    (gpc-lock-gc gpc-var)
    (should (gpc-helper-seq-set-equal-p (gpc-get-lock-list gpc-var) (list buffer-a)))))

(ert-deftest gpc-lock-gc-test/one-lock-on-a-killed-buffer ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (gpc-lock gpc-var))
  (gpc-lock-gc gpc-var)
  (should (eq (gpc-get-lock-list gpc-var) nil)))

(ert-deftest gpc-lock-gc-test/one-killed-buffer-lock-and-one-live-buffer-lock ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var
    '((system "Hurd" (lambda ()
                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (gpc-lock gpc-var))
  (with-temp-buffers (buffer-b)
    (set-buffer buffer-b)
    (gpc-lock gpc-var)
    (gpc-lock-gc gpc-var)
    (should (gpc-helper-seq-set-equal-p (gpc-get-lock-list gpc-var) (list buffer-b)))))

(ert-deftest gpc-lock-clear-test/two-locks ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (with-temp-buffers (buffer-a buffer-b)
    (set-buffer buffer-a)
    (gpc-lock gpc-var)
    (set-buffer buffer-b)
    (gpc-lock gpc-var)
    (gpc-lock-clear gpc-var)
    (should (eq (gpc-get-lock-list gpc-var) nil))))

(ert-deftest gpc-lock-test/fetch ()
  (unintern "gpc-var" nil)
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (gpc-lock-clear gpc-var)
  (with-temp-buffers (buffer-a)
    (set-buffer buffer-a)
    (gpc-overwrite-with-initvals gpc-var)
    (gpc-lock gpc-var)
    (should (equal (gpc-fetch 'system gpc-var) "Hurd"))))

(ert-deftest gpc-copy-test/happy-path ()
  (unintern "gpc-var" nil)
  (setq system-value (s-chop-suffix "\n" (shell-command-to-string "uname")))
  (gpc-init gpc-var '((system "Hurd" (lambda ()
                                       (s-chop-suffix "\n" (shell-command-to-string "uname"))))))
  (with-temp-buffers (buffer-a buffer-b)
    (set-buffer buffer-b)
    (gpc-make-local-variable gpc-var)
    (set-buffer buffer-a)
    (gpc-make-local-variable gpc-var)
    (gpc-fetch 'system gpc-var)
    (gpc-copy gpc-var buffer-a buffer-b)
    (set-buffer buffer-b)
    (should (equal (gpc-val 'system gpc-var) system-value))))

;; Local Variables:
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:

;;; gpc-test.el ends here
