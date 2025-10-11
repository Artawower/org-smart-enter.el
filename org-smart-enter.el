;;; org-smart-enter.el --- Smart RET in Org-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2025 artawower

;; Author: artawower <artawower33@gmail.com>
;; URL: https://github.com/artawower/org-smart-enter.el
;; Package-Requires: ((emacs "27.1") (org "9.4"))
;; Version: 0.1.1
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
;; Context-aware RET for Org-mode:
;; - If point is on a link, open it via `org-open-at-point`.
;; - Otherwise fall back to `org-return`.
;;
;; Evil integration:
;; - Binds RET only in Evil normal state and only while this minor mode is enabled.
;;
;; Meow note:
;; - Meow uses emulation keymaps that have higher priority than minor-mode maps.
;;   Buffer-local rebinding of RET in meow normal state without global effects
;;   is difficult. Therefore, there is OPTIONAL integration below:
;;   globally rebind RET in `meow-normal-state-keymap`. By default it is
;;   disabled to avoid affecting other buffers. Enabled via variable
;;   `org-smart-enter-enable-meow-integration`.

;;; Code:

(require 'org)

(defgroup org-smart-enter nil
  "Smart RET in Org-mode."
  :group 'org
  :prefix "org-smart-enter-")

(defcustom org-smart-enter-enable-meow-integration nil
  "If non-nil, bind RET in `meow-normal-state-keymap' to `org-smart-enter'.
WARNING: This is GLOBAL for Meow normal state (affects all buffers)."
  :type 'boolean
  :group 'org-smart-enter)

(defun org-smart-enter--at-link-p ()
  "Return non-nil if point is on an Org link."
  (and (or (org-in-regexp org-link-bracket-re 1)
           (org-in-regexp org-link-plain-re 1)
           (org-in-regexp org-any-link-re 1))
       (not (looking-back "\\]\\]" (- (point) 2)))))

(defun org-smart-enter ()
  "Smart RET for Org-mode.
If point is on a link, open it. Otherwise, do `org-return`."
  (interactive)
  (if (org-smart-enter--at-link-p)
      (org-open-at-point)
    (org-return)))

;; Keymap must exist before `define-minor-mode`.
(defvar org-smart-enter-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Default fallback when no modal editor overrides it:
    (define-key map (kbd "RET") #'org-smart-enter)
    map)
  "Keymap for `org-smart-enter-mode'.")

;;;###autoload
(define-minor-mode org-smart-enter-mode
  "Minor mode to make RET in Org-mode context-aware."
  :lighter " ↵✓"
  :keymap org-smart-enter-mode-map
  ;; Nothing special needed here. Evil integration happens after load (see below).
  )

;;; Evil integration (only normal state, only while our mode is active).
(with-eval-after-load 'evil
  (evil-define-key 'normal org-smart-enter-mode-map
                   (kbd "RET") #'org-smart-enter))

;;; Optional Meow integration (GLOBAL for normal state).
(with-eval-after-load 'meow
  (when org-smart-enter-enable-meow-integration
    (when (boundp 'meow-normal-state-keymap)
      (define-key meow-normal-state-keymap (kbd "RET") #'org-smart-enter))))

;;;###autoload
(defun org-smart-enter-setup ()
  "Enable `org-smart-enter-mode` in Org buffers."
  (add-hook 'org-mode-hook #'org-smart-enter-mode))

(provide 'org-smart-enter)

;;; org-smart-enter.el ends here
