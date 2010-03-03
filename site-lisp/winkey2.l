(provide "winkey2")

(in-package "editor")

;;; winkey.lからコピー
(defvar *default-selection-keymap*
  (let ((keymap (make-sparse-keymap)))
	(define-key keymap #\C-c 'copy-selection-to-clipboard)
	(define-key keymap #\C-x 'kill-selection-to-clipboard)
    (define-key keymap #\TAB 'tabshift-selection)
    (define-key keymap #\S-F15 'untabshift-selection)
    (set-extended-key-translate-table exkey-S-tab #\S-F15)
	keymap))


;;;;;;;;;;;;;;;;;;
;; ■ 範囲選択中にタブが押されたら冒頭にタブを挿入
(defun perform-replace-selection (pattern replacement query regexp interactive-p noerror)
  "選択範囲内を perform-replace"
  (interactive "*p")
  (let ((type (get-selection-type)))
    (selection-start-end (start end)
      (save-restriction
        (narrow-to-region start end) (goto-char (point-min))
        (perform-replace pattern replacement query regexp interactive-p noerror)
        (save-excursion
          (goto-char (point-min))
          (start-selection type t (point-max))
          (fix-selection-point)
          )))))
(defun tabshift-selection ()
  "冒頭にタブを挿入"
  (interactive "*p")
  (perform-replace-selection "^.+$" "\t\\0" nil t nil t))
(defun untabshift-selection ()
  "冒頭のタブを１つ削除（タブがなければ何もしない）"
  (interactive "*p")
  (perform-replace-selection "^\t" "" nil t nil t))
(setq-default selection-keymap *default-selection-keymap*)

#|
;;; winkey.lからコピー
(defvar *default-selection-keymap*
  (let ((keymap (make-sparse-keymap)))
	(define-key keymap #\C-c 'copy-selection-to-clipboard)
	(define-key keymap #\C-x 'kill-selection-to-clipboard)
	keymap))
(setq-default selection-keymap *default-selection-keymap*)
|#


(setq-default selection-keymap *default-selection-keymap*)
(global-set-key #\C-z 'undo)
(global-set-key #\C-v 'paste-from-clipboard)
(define-key esc-map #\C-x #'ctl-x-prefix)
(define-key esc-map #\C-c #'specific-command-prefix)


;;; Windowsっぽい設定
;(global-set-key #\C-A 'selection-whole-buffer)
;(global-set-key #\C-F 'search-dialog)
(global-set-key #\C-N 'new-file)
;(global-set-key #\C-O 'open-filer)
(global-set-key #\C-P 'print-selected-buffer-dialog)
;(global-set-key #\C-R 'replace-dialog)
;(global-set-key #\C-S 'save-buffer-dialog)
;(global-set-key #\Home 'beginning-of-virtual-line)
;(global-set-key #\End 'end-of-virtual-line)
(global-set-key #\C-Home 'beginning-of-buffer)
(global-set-key #\C-End 'end-of-buffer)
(global-set-key #\S-C-Home 'selection-beginning-of-buffer)
(global-set-key #\S-C-End 'selection-end-of-buffer)
;(global-set-key #\F3 'search-forward-again)
;(global-set-key #\S-F3 'search-backward-again)
(global-set-key #\M-F4 'kill-xyzzy)
(global-set-key #\C-F4 'close-selected-buffer)
(global-set-key #\C-Left 'backward-word)
(global-set-key #\C-Right 'forward-word)
(global-set-key #\S-C-Left 'selection-backward-word)
(global-set-key #\S-C-Right 'selection-forward-word)

