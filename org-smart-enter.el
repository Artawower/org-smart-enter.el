;;; org-smart-enter.el --- Smart RET in Org-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2025 artawower

;; Author: artawower <artawower33@gmail.com>
;; URL: https://github.com/artawower/org-smart-enter.el
;; Package-Requires: ((emacs "27.1") (org "9.4"))
;; Version: 0.1.0
;; Keywords: convenience, outlines, hyperlinks, modal editing

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Provides a smarter RET key for Org-mode:
;; - If point is on a link, opens the link via `org-open-at-point`.
;; - Otherwise falls back to the usual `org-return` behavior.
;; Integrates with Evil and Meow to only override RET in normal state.

;;; Code:

(require 'org)

(defun org-smart-enter--at-link-p ()
  "Return non-nil if point is on an Org link."
  (or (org-in-regexp org-link-bracket-re 1)
      (org-in-regexp org-link-plain-re 1)
      (org-in-regexp org-any-link-re 1)))

(defun org-smart-enter ()
  "Smart RET for Org-mode.
If point is on a link, open it. Otherwise, do `org-return`."
  (interactive)
  (if (org-smart-enter--at-link-p)
      (org-open-at-point)
    (org-return)))

(defvar org-smart-enter--evil-keymap nil
  "Backup of `RET` binding in Evil normal state for restoration.")

(defvar org-smart-enter--meow-keymap nil
  "Backup of `RET` binding in Meow normal state for restoration.")

;;;###autoload
(define-minor-mode org-smart-enter-mode
  "Minor mode to make RET in Org-mode context-aware.
When enabled, pressing RET opens a link at point or does `org-return`."
  :lighter " ↵✓"
  (if org-smart-enter-mode
      (progn
        ;; Integration with Evil
        (when (featurep 'evil)
          (setq org-smart-enter--evil-keymap
                (lookup-key evil-normal-state-local-map (kbd "RET")))
          (evil-define-key 'normal org-smart-enter-mode-map
            (kbd "RET") #'org-smart-enter))
        ;; Integration with Meow
        (when (featurep 'meow)
          (setq org-smart-enter--meow-keymap
                (lookup-key meow-normal-state-keymap (kbd "RET")))
          (meow-normal-define-key '("RET" . org-smart-enter)))
        ;; Default binding
        (define-key org-smart-enter-mode-map (kbd "RET") #'org-smart-enter))
    ;; Disable mode: restore previous bindings
    (when (featurep 'evil)
      (evil-define-key 'normal org-smart-enter-mode-map
        (kbd "RET") org-smart-enter--evil-keymap))
    (when (featurep 'meow)
      (meow-normal-define-key
       '("RET" . ,org-smart-enter--meow-keymap)))
    (define-key org-smart-enter-mode-map (kbd "RET") nil)))

;;;###autoload
(defun org-smart-enter-setup ()
  "Enable `org-smart-enter-mode` in Org buffers."
  (add-hook 'org-mode-hook #'org-smart-enter-mode))

(provide 'org-smart-enter)

;;; org-smart-enter.el ends here
