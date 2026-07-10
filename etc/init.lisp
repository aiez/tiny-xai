;;;; Tiny emacs for tiny-xai: mouse, MELPA packages, SLY
;;;; (sbcl repl) and the catppuccin theme. Launch via the
;;;; sibling `ide` script: ignores ~/.emacs.d entirely.

;; mouse in the terminal
(xterm-mouse-mode 1)
(setq mouse-wheel-progressive-speed nil)

;; package support (MELPA), auto-install what is missing
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(dolist (p '(sly catppuccin-theme))
  (unless (package-installed-p p)
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install p)))

;; sly -> sbcl
(setq inferior-lisp-program "sbcl")

;; catppuccin theme
(setq catppuccin-flavor 'mocha)
(load-theme 'catppuccin t)

;; small niceties
(show-paren-mode 1)
(electric-pair-mode 1)
(global-display-line-numbers-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(setq make-backup-files nil
      auto-save-default nil
      inhibit-startup-screen t)
(fset 'yes-or-no-p 'y-or-n-p)
