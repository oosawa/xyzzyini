(in-package "elisp-lib")

;; メジャーモードを指定。
(pushnew '("\\.howm$" . hateda-mode) *auto-mode-alist* :test #'equal)

;; メニューは日本語。
(setq howm-menu-lang 'ja)

;; howm-list-grep は常に大小文字を区別する。
;; コメントアウトしたままだと、*case-fold-search*
;; （検索ダイアログの大文字小文字を区別するチェック状態）に依存する。
;(setq default-case-fold-search t)

;; ウィンドウを縦に分割する。
;(setq howm-view-split-horizontally t)

;; 色の設定。
;; ツール>共通設定>表示色           '(文字色 背景色 装飾（複数指定可）)
;;                                                  :underline
;;                                                  :strike-out
;;                                                  :bold
;; メモのタイトル。=
(setq *howm-mode-title-face*        '( 4 nil :bold :underline))
;; goto リンク。>>> ほげほげ
(setq *howm-mode-ref-face*          '( 6   ))
;; come-from リンク。<<< ふがふが
(setq *howm-mode-keyword-face*      '( 7  4))
;; Wiki 風リンク。[[へろへろ]]
(setq *howm-mode-wiki-face*         '(14 nil :underline))
;; 覚え書き。[2002-10-20]- 
(setq *howm-reminder-normal-face*   '( 4   ))
;; todo。[2002-10-20]+
(setq *howm-reminder-todo-face*     '( 3   ))
;; 〆切。[2002-10-20]!
(setq *howm-reminder-deadline-face* '( 1   ))
;; 予定。[2002-10-20]@
(setq *howm-reminder-schedule-face* '(14   ))
;; 済。[2002-10-20].
(setq *howm-reminder-done-face*     '(15   ))
;; 今日の日付。
(setq *howm-reminder-today-face*    '( 8  3))
;; 明日の日付。
(setq *howm-reminder-tomorrow-face* '( 8  9))
;; 検索語など。
(setq *howm-view-hilit-face*        '( 1   ))
;; action-lock。{ }等。
(setq *action-lock-face*            '( 8 nil :underline))
;; メニューのショートカットキー。c[新規]
;;                               ^
(setq *howm-menu-key-face*          '( 3   ))

;; サマリとコンテンツは行番号なしにする。
(defun howm-no-line-number ()
  (set-local-window-flags (selected-buffer) *window-flag-line-number* nil))
(add-hook 'howm-view-summary-mode-hook 'howm-no-line-number)
(add-hook 'howm-view-contents-mode-hook 'howm-no-line-number)

;; [roma] 検索はしたいが、インクリメントサーチはいやな人は、
;; ↓を有効に。
;(global-set-key #\C-s 'ed::search-forward)
;(global-set-key #\C-r 'ed::search-backward)

;; howm-menu-mode のキーカスタマイズをしたい場合以下を有効に。
;(defun howm-menu-key-customize ()
;  (when (eq major-mode 'howm-menu-mode)
;    ; ここにキー定義を書く。
;    (define-key howm-menu-mode-map #\TAB 'func)
;    ))
;(add-hook 'action-lock-mode-on-hook 'howm-menu-key-customize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; howm-helper    minor addition to howm-wrap
;;  by deecay  version1.0   2005/09/25
;;
;;
;; インストール方法
;; ";;;;;;;"で区切られたセクションごとにhowm-init.lにコピー。
;; お好みで設定を書き換える。
;; howm-init.lを保存して再ダンプ。

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; キーワードサーチ
(defun howm-list-grep-fixed ()
  (interactive)
  (howm-list-grep t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; howm-prefixをC-c , だけじゃなくて、C-,でも。
(setq howm-prefix (string #\C-\,))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 新しいキー定義
;; howm-list-grep-fixed(キーワード検索)とhowm-history(履歴検索)を使う場合は、
;; それぞれのコメントをはずしてください。

(setq howm-default-key-table
  '(
    ;; ("key"  func list-mode-p global-p)

    ("r" howm-initialize-buffer)         
    ("l" howm-list-recent t t)
    ("a" howm-list-all t t)
    ("g" howm-list-grep t t)
    ("m" howm-list-migemo2 t t)
    ("t" howm-list-todo t t)
    ("y" howm-list-schedule t t)
    ("c" howm-create t t)
    ("," howm-menu t t)
    ;("A" howm-list-around)

    ;("D" howm-dup)                       
    ("i" howm-insert-keyword)              
    ("d" howm-insert-date)                       
    ("K" howm-keyword-to-kill-ring t t)        
    ("n" action-lock-goto-next-link)            
    ("p" action-lock-goto-previous-link)        
    ("Q" howm-kill-all t t)
    ("s" howm-list-grep-fixed t t)

    ("h" howm-history t t)
    ))

;; 上で定義したキーを有効に。
(eval-when (:compile-toplevel :load-toplevel :execute)
  (howm-set-keymap))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unix-utilsのgrep.exeを使って検索しよう、という試み。
;; ftp://garbo.uwasa.fi/win95/unix/UnxUpdates.zipのgrep.exeを
;; パスが通ったところにコピーしておいてください。
;;
;; 制限事項: メモに複数の文字コードが使われている場合には対応していません。
;;           メモの文字コードがutf8の場合、日本語の検索に失敗する場合がある。
;;           shift-jisなら大丈夫なはず。

;; 以下の三つはユーザー設定可

(defvar howm-view-file-list-length 600
  "call-processでgrep.exeを呼ぶとき、32,770文字以上の引数を与えるとエラーになる。
そこでファイルリストをここで指定した数でに分けてからgrepを呼ぶようにする。")

(defvar howm-view-grep-encoding *encoding-utf8n*
  "メモの文字コード。*encoding-sjis*, *encoding-utf8n*など。")

(setq howm-view-use-grep nil)			;2009/12/14 oosawa*



(setq howm-view-grep-command "grep -E")
(setq howm-view-fgrep-command "grep -F")

(defun howm-view-real-grep (str file-list &optional fixed-p)
  "Call grep and parse its result.
'((file line-number line) (file line-number line) ...)

"
  (let ((grep-command (if fixed-p
                          howm-view-fgrep-command
                        howm-view-grep-command))
        (opt (list howm-view-grep-option))
        (eopt (and howm-view-grep-expr-option
                   (list howm-view-grep-expr-option))))
    (when (and (not (let ((case-fold-search nil))
                      (string-match "[A-Z]" str)))
               howm-view-grep-ignore-case-option)
      (setq opt (cons howm-view-grep-ignore-case-option opt)))
      (let* ((fs (mapcar #'expand-file-name file-list))
			 (str (concat "\""

				   (if (string-match "[\X8200-\X9fff\Xe000-\Xfcff]" str)
					   (prin1-to-string
						(convert-encoding-from-internal howm-view-grep-encoding str))
					 str) "\""))
			 (lines (howm-view-real-grep-sub grep-command opt eopt str fs)) ;;

             (parsed (mapcar 'howm-view-grep-parse-line lines)))
		(remove nil parsed))))

(defun howm-view-real-grep-sub (grep-command opt eopt str fs)
  "execute grep.exe . Split argument in to multiple lists if needed.
Encode query to defined encoding if Japanese character is included."
  (let ((limit howm-view-file-list-length)
		result)
	(dotimes (n (/ (length fs) limit) result)
	  (let ((sub-fs (subseq fs (* n limit) (* (1+ n) limit))))
		(setq result (append result
							 (howm-view-call-process-ed grep-command
													 `(,@opt ,@eopt ,str ,@sub-fs))))))))

(defun howm-view-call-process-ed (command args)
  (let ((tmp-file (make-temp-file-name "elisp"))
		result)
	(ed::call-process (concat command " " (mapconcat #'string args " "))
					:input nil

					:output tmp-file
					:error nil
					:show :minimize
					:wait t)
	(prog1 (with-temp-buffer
			 (read-file tmp-file)
			 (split-string (buffer-substring (point-min) (point-max)) "\n"))
	  (delete-file tmp-file))))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; howm関連は別フレームに。

;; 以下の二つはユーザー設定可
(defvar howm-use-pframe t
  "フレームを使う場合はtに")
(setf howm-use-pframe t)

(defvar howm-frame-name "howm"

  "howm用のフレームの名前")


(defun howm-buffer-p (&optional buf)
  (with-current-buffer (or buf (current-buffer))
    (or howm-mode
        (member major-mode
                '(howm-view-summary-mode
                  howm-view-contents-mode)))))

(defun howm-buffer-in-pseudo-frame (buf)
  "hooked to create-buffer-hook"

  (interactive)
  (and (string-match "\\.howm$\\|\\*howm[MCS].*" (buffer-name buf))
       (string/= (ed::pseudo-frame-name (selected-pseudo-frame)) howm-frame-name)
       (select-pseudo-frame (or (find-pseudo-frame howm-frame-name)
                                (new-pseudo-frame howm-frame-name)))))

(defun howm-delete-frame ()
  (let ((frame (find-pseudo-frame "howm"))
        (howm-buffer-exist (delete nil (mapcar #'howm-buffer-p (buffer-list)))))
    (when (and frame (not howm-buffer-exist))
      (delete-pseudo-frame frame))))

(defun howm-view-kill-buffer ()
  (interactive)
  (let ((s (howm-view-summary-buffer))
        (c (howm-view-contents-buffer)))
    (kill-buffer s)
    (kill-buffer c)
    (howm-view-restore-window-configuration (not howm-view-quit-to-nonhowm))
    (howm-delete-frame)))

(defun howm-kill-all (&optional force-p)
  "Kill all buffers which is howm-mode and unmodified."

  (interactive "P")
  (let ((anyway (and force-p howm-kill-all-enable-force)))
    (when (if anyway
              (yes-or-no-p "Discard all unsaved changes on howm-mode buffers? ")
            (y-or-n-p "Kill all howm-mode buffers? "))
      (when (eq major-mode 'howm-view-summary-mode)
        (howm-view-restore-window-configuration))
      (mapc (lambda (b)
              (save-excursion

                (set-buffer b)
                (when (or howm-mode
                          (member major-mode
                                  '(howm-view-summary-mode
                                    howm-view-contents-mode)))
                  ;; dangerous!
                  (when anyway
                    (switch-to-buffer b)
                    (set-buffer-modified-p nil))
                  (when (not (buffer-modified-p b))
                    (kill-buffer b)))))
            (buffer-list))
      (howm-delete-frame)
      (message "Done."))))

(when howm-use-pframe
  (add-hook 'ed::*create-buffer-hook* 'howm-buffer-in-pseudo-frame))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; サマリモードでファイル内容の最後の一行が見れない問題の修正。

(defun howm-view-paragraph-region (&optional include-following-blank-p)
  (let ((b (save-excursion
             (end-of-line)
             (re-search-backward howm-view-title-regexp
                                 nil 'to-limit)
             (line-beginning-position)))
        (e (save-excursion

             (end-of-line)
             (let ((found (re-search-forward howm-view-title-regexp
                                             nil 'to-limit)))
               (if include-following-blank-p
                   (if found (match-beginning 0) (point-max))
                 (progn

                   (if found
                       (forward-line -1)
                     (goto-char (point-max)))
;                   (end-of-line)
                   (while (and (looking-at "^$")
                               (= (forward-line -1) 0)) ;; successful

                     nil) ;; dummy
                   (end-of-line)
                   (point)))))))
    (list b e)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 検索履歴
;;  ＋ メニューからのリマインダは直接開く

;; 以下の三つはユーザー設定可
(defvar howm-history-file "~/howm/.howm-history"

  "*Search history is recorded to that file.")

(defvar howm-history-limit 50
  "*Limit number of recorded search history, or nil for no limit.
Set 0 to inhibit recording.")

(defvar howm-history-unique t
  "*If non-nil, duplicated entries are removed from search history.")


(defvar howm-history-format "> %s | %s")
(defvar howm-history-remove-format "| %s$")

(defvar howm-menu-list-format "> %s | %s"

  "Format to show schedule/todo/recent/random list in `howm-menu-mode'.")

(defvar howm-menu-list-regexp "^\\(>\\)\\([^|\r\n]*|\\) +\\(.*\\)$"
  "Regexp to find and parse schedule/todo/recent/random list in `howm-menu-mode'.")

(defvar howm-menu-list-regexp-key-pos 3
  "Position of target string for action-lock on schedule/todo/recent/random list
in `howm-menu-mode'. This target is searched when action-lock is invoked.")

(defvar howm-menu-list-regexp-action-pos 1
  "Position of action-lock hilight on schedule/todo/recent/random list
in `howm-menu-mode'.")

(defvar howm-menu-list-regexp-face-pos 2
  "Position to apply `howm-menu-list-face' on schedule/todo/recent/random list
in `howm-menu-mode'.")

(defun howm-menu-action-lock-rules ()
  (let ((d action-lock-default-rules)
        (j (list (howm-action-lock-search "^\\(>\\)[^0-9\r\n]*[0-9]+ +\\(.*\\)$"

                                          2 1 nil t)))
        (m (mapcar (lambda (pair)
                     (let* ((h (car pair))
                            (r (if (listp h) (car h) h))
                            (n (if (listp h) (second h) nil))
                            (arg (if n
                                     `(match-string-no-properties ,n)
                                    nil))
                            (functab (cdr pair))
                            (c (howm-menu-action functab arg)))
                       (list r c)))
                   (howm-menu-command-table)))
        ;; for history action

        (l (howm-menu-list-rules)))
    (append m d j l)))

(defun howm-menu-list-rules ()
  (list (howm-action-lock-search howm-menu-list-regexp
                                 howm-menu-list-regexp-key-pos
                                 howm-menu-list-regexp-action-pos
                                 nil)))

(defun howm-write-history (message)
  (when (and howm-history-file
             (or (null howm-history-limit) (> howm-history-limit 0)))
    (howm-write-log message howm-history-format howm-history-file
                    howm-history-limit
                    (and howm-history-unique howm-history-remove-format))))

(defun howm-write-log (message fmt file &optional limit remove-fmt)
  "Write MESSAGE with format FMT to the top of FILE.
FORMAT must have two %s; the formar is time and the latter is message.
When LIMIT is non-nil, only that number of recent messages are recorded.
When REMOVE-FMT is non-nil, it is used to generate regular expression
to remove matched lines. REMOVE-FMT must have one %s."

  (save-excursion
    (with-current-buffer (find-file-noselect file)
      (goto-char (point-min))
      (when remove-fmt
        (save-excursion
          (flush-lines (format remove-fmt (regexp-quote message)))
          ))
      (insert (format fmt
                      (format-time-string howm-dtime-format (current-time))
                      message)
              "\n")
      (when limit
        ;; Since I don't understand `selective-display' in goto-line,

        ;; I avoid it.
        (goto-char (point-min))
        (when (= (forward-line limit) 1) ;; buffer lines > LIMIT

          (delete-region (point) (point-max))))
      (save-buffer))))

;; adding (howm-write-history arg)
(defun howm-view-filter-by-contents (str)
  (interactive "sSearch in result (grep): ")
  (let* ((orig (howm-view-name))
         (name (if (string= orig "")
                   str
                 (format "%s&%s" orig str)))
         (file-list (howm-view-file-list)))
    (howm-write-history str)
    (howm-view-search str file-list name)))

(defun howm-list-grep (&optional completion-p)
  (interactive "P")
  (let* ((regexp (if completion-p
                     (howm-completing-read-keyword)
                   (read-from-minibuffer "Search all (grep): "))))
    (when completion-p
      (howm-write-history regexp))
    (howm-search regexp completion-p)))

(defun howm-keyword-search (keyword &optional create-p open-unique-p)

;   (interactive "sKeyword: ")
  (let* ((wconf (current-window-configuration))
         ;(aliases (if (howm-support-aliases-p)
         ;             (howm-keyword-aliases keyword)
         ;           keyword))
         (menu-p (and howm-menu-keyword-regexp
                      (string-match howm-menu-keyword-regexp keyword)))
         ;(comefrom-regexp (if menu-p

         ;                     nil
         ;                   (howm-make-keyword-regexp2 aliases)))
;;          (all-p (not menu-p))
         (found (let ((*howm-view-force-case-fold-search* howm-keyword-case-fold-search))  ;; dirty!
                  (howm-call-view-search keyword t)))
;;          (found (howm-view-search keyword (howm-directory all-p)
;;                                   nil nil t))
         (matched (and found (howm-list-normalize keyword)))
         (keyword-matched (member 'keyword matched))
         (title (howm-make-keyword-string keyword)))
    (when (and menu-p keyword-matched)
        ;; dirty. peeking howm-view.el

      (let* ((item (car howm-view-item-list))
             (fname (howm-view-item-filename item))
             (place (howm-view-item-place item)))
        (howm-view-kill-buffer)
	    (when wconf
		  (set-window-configuration wconf))
        (howm-menu-open fname place
                        (howm-menu-name keyword))))
    (when (and create-p
               (not keyword-matched)

;;                (y-or-n-p (format "No match. Create [%s]? " title))
               )
      (howm-view-kill-buffer)
      (howm-create-file-with-title title)
      (message "New keyword."))
    ;; open unique
    (when (and open-unique-p (howm-single-element-p (howm-view-item-list)))
      (howm-keyword-search-open-unique wconf))
    ;;;history

    (when (not menu-p)
      (howm-write-history keyword))))

;; helper needed for howm-write-log
(defun flush-lines (regexp)
  "Delete lines containing matches for REGEXP.
If a match is split across lines, all the lines it lies in are deleted.
Applies to lines after point."
  (interactive "sFlush lines (containing match for regexp): ")
  (save-excursion

    (while (and (not (eobp))
        (re-search-forward regexp nil t))
      (delete-region (save-excursion (goto-char (match-beginning 0))
                     (beginning-of-line)
                     (point))
             (progn (forward-line 1) (point))))))

(defmacro with-current-buffer (buffer &rest body)
  `(save-window-excursion

     (ignore-errors
     (progn
       (set-buffer ,buffer)
       ,@body))))

(defun find-file-noselect (filename &optional nowarn rawfile)
  (unless (get-file-buffer filename)
    (editor::find-file-internal filename nowarn))
  (get-file-buffer filename))

(defun howm-action-lock-search (regexp pos &optional hilit-pos create-p open-unique-p)
  (howm-action-lock-general 'howm-keyword-search regexp pos hilit-pos create-p open-unique-p))

(defun howm-single-element-p (a)
  (and a (null (cdr a))))

(defun howm-keyword-search-open-unique (wconf)
  "Open unique match."

  ;; dirty. peeking howm-view.el
  (howm-view-summary-open)
  (let ((b (current-buffer)))
	(when wconf (set-window-configuration wconf))
    (switch-to-buffer b)))

(defun howm-history ()
  (interactive)
  (howm-menu-open howm-history-file))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 一覧表示窓の行数設定 (horizontalにも対応しているはず)

;; t splits window in half
(setq howm-view-summary-window-size 11)

(defun howm-view-refresh-window-configuration ()
  (when (member major-mode '(howm-view-summary-mode howm-view-contents-mode))
    (let ((orig (current-buffer))
          (s (howm-view-summary-buffer))
          (c (howm-view-contents-buffer))
          (horizontal howm-view-split-horizontally))
      (delete-other-windows)
      (switch-to-buffer c)
;      (ed::split-window howm-view-summary-window-size horizontal)
      (if (> (window-height) howm-view-summary-window-size)
          (ed::split-window howm-view-summary-window-size nil)
        (ed::split-window nil nil))
      (switch-to-buffer s)
      (select-window (get-buffer-window orig)))))

(defun howm-view-summary-update (item)
  ;(y-or-n-p (format "entering update."))

  (let* ((vbuf (howm-view-contents-buffer))
         (cwin (selected-window))
         (pop-up-windows (or pop-up-windows howm-view-pop-up-windows))
         (fname (howm-view-item-filename item))
         (name (howm-view-name))
         (horizontal howm-view-split-horizontally))
    (if (= (count-windows) 1)
        (ed::split-window howm-view-summary-window-size horizontal))
    (ed::pop-to-buffer vbuf)
    (howm-view-contents name (list item))
    (goto-char (point-min))
    (let ((home (howm-view-item-home item)))
      (when (numberp home)
        (goto-char home)
        (recenter howm-view-search-recenter))
      (message "View: %s" fname)
      (select-window cwin))))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; recentの数引数問題
;; howm-list-recent, filter-by-xtime, filter-by-date などが修正されるかも。

(defun howm-view-string<= (a b)
  (not (string< b a)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C-n/pで一覧中の次の「ファイル」に飛ぶ

(defun howm-view-summary-next-section (&optional n)
  (interactive "P")
  (setq n (or n 1))
  (let ((i (abs n))
        (step (if (>= n 0) 1 -1)))
    (while (and (> i 0)
                (howm-view-summary-next-section-sub step))
      (setq i (1- i)))))
(defun howm-view-summary-previous-section (&optional n)
  (interactive "P")
  (setq n (or n 1))
  (howm-view-summary-next-section (- n)))
(defun howm-view-summary-next-section-sub (step)
  (let ((orig (howm-view-item-filename (howm-view-summary-current-item))))
    (while (and (string= orig
                       (howm-view-item-filename (howm-view-summary-current-item)))
                (forward-line step))
      ;; no body

      )))

(defun howm-view-summary-current-item ()
  (ed::let ((n (riffle-line-number)))
    (nth (1- n) (howm-view-item-list))))

(defun riffle-line-number (&optional pos)
  (save-excursion

    (when pos
      (goto-char pos))
    (ed::let ((raw (count-lines (point-min) (point))))
      (if (bolp)
          (+ raw 1)
        raw))))

(define-key howm-view-summary-mode-map #\C-n 'howm-view-summary-next-section)
(define-key howm-view-summary-mode-map #\C-p 'howm-view-summary-previous-section)
(define-key howm-view-summary-mode-map #\n 'forward-line)
(define-key howm-view-summary-mode-map #\p 'backward-line)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODOに曜日を表示
;; ＋ メニューで「済み」は表示しない
(setq howm-menu-todo-show-day-of-week t)

(setq howm-menu-todo-priority -66666)

(defun howm-menu-insert-item (item &optional day-of-week-str)
  (let* ((p (howm-todo-parse item))
         (late (floor (car p)))
         (dow (fourth p))
         (dow-str (or day-of-week-str
                      (cond (howm-menu-todo-show-day-of-week
                             (howm-day-of-week-string dow))
                            (t "  "))))
         (h (format "> %s%3s " dow-str late))
         )
    (insert h (howm-view-item-summary item) "\n")))

(defun howm-day-of-week-string (&optional day-of-week)
  ;; 0 = Sunday

  (let ((dow (or day-of-week (nth 6 (decode-time)))))
    (substring (howm-day-of-week) dow (1+ dow))))

(defun howm-menu-todo ()
  (message "scanning todo...")
  (delete-region (match-beginning 0) (match-end 0))
  (mapc (lambda (item) (howm-menu-insert-item item)) ;;removed arg

        (howm-todo-menu howm-menu-todo-num howm-menu-todo-priority))  ;; do not display done
  (message "...done")
  )

(defun howm-reminder-summarizer (regexp &optional show-day-of-week)
  `(lambda (file line content)
     (let ((s (howm-reminder-omit-before ,regexp content)))

;;                 (string-match ,regexp content)
;;                 (substring content (match-beginning 0)))))
       ,(if show-day-of-week
            '(format "%s %s"
                     (howm-day-of-week-string (nth 4
                                                   (howm-todo-parse-string s)))
                     s)
          's))))

(defun howm-reminder-omit-before (regexp str)
  (string-match regexp str)
  (substring str (match-beginning 0)))

(defun howm-list-reminder (types name)
  (let* (
         (r (howm-reminder-regexp types))
         (rg (howm-reminder-regexp-grep types))
         (summarizer (howm-reminder-summarizer r t)) ;;day-of-week

         )
    (howm-view-search rg howm-directory name summarizer)
    (howm-list-exclude)
;;     (let ((howm-view-excluded-file-regexp howm-excluded-file-regexp)) ;; dirty!
;;       (howm-view-search rg (howm-directory) name summarizer))
    (howm-reminder-add-font-lock)
    (howm-mode-add-font-lock)
    ))

(defun howm-todo-menu (n limit-priority)
  (let* ((cutted (remove-if (lambda (item)
                                      (< (howm-todo-priority item)
                                         limit-priority))
                                    (howm-reminder-search howm-todo-types)))
         (sorted (howm-view-sort-items #'howm-todo-priority #'> cutted)))
    (if (null sorted) nil

      (remove-if #'null (if (< (length sorted) n)
                            sorted
                          (subseq sorted 0 n))))))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#|
;;2ch-modeと連携 (アイディア段階)
(require "2ch/main")

(setq howm-buffer-for-2ch nil)
(setq howm-2ch-template-format "= \n")

(defun howm-get-2ch-res (&optional create-new)
  (interactive "P")
  (let* ((initial-pos (point))
         (initial-clipboard-data (get-clipboard-data))
         (buf howm-buffer-for-2ch)
         (end (progn (2ch::thread-next-article) (make-marker) (point)))
         (start (progn (2ch::thread-previous-article) (point)))
         (contents (buffer-substring start end))
         (thread-url (2ch::thread-url-read 2ch::thread-host
                                           2ch::thread-path
                                           2ch::thread-dat))
         (url-and-title (2ch::thread-url-title-format 2ch::thread-board
                                                      2ch::thread-title
                                                      thread-url)))
    (when (or create-new (not buf) (and (bufferp buf)
                                      (deleted-buffer-p buf)))
      (elib::howm-create)
      (save-excursion
        (goto-char (point-max))
        (insert (elib::format "%s \n" url-and-title))
        (copy-to-clipboard initial-clipboard-data))
      (setq howm-buffer-for-2ch (selected-buffer)))
    (save-excursion
      (set-buffer howm-buffer-for-2ch)
      (goto-char (point-max))
      (insert "\n")
      (insert contents))
    (goto-char initial-pos)
    (message "added howm memo.")))


(define-key 2ch::*thread-map* #\h 'howm-get-2ch-res)
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 未達のTODOを携帯や仕事用のPCに一斉送信、とか？
#|
(defun howm-mail-todo ()
  (interactive)
  (let ((body (let ((result nil))
	(dolist (x (howm-todo-menu howm-menu-todo-num howm-menu-todo-priority) result)
	  (setq result (concat result (nth 1 x) "\n"))
	  result))))
	(call-process (concat "smail" .....))))

|#

;;;;;;;;;;;;;;;;;;
;; ■ howm ファイルのバッファ名をhowmデータのタイトルに
(defun change-buffer-name-to-howm-title ()
  (save-window-excursion
	(when (and (get-buffer-file-name)
			   (string-match ".*\\.howm" (get-buffer-file-name)))
    (let ((title (string-trim " =" (buffer-substring (progn (goto-char (point-min)) (point))
                                                     (progn (goto-eol) (point)))))
          (prefix "H: "))
      (when (> (length title) 0)
		(rename-buffer (concat prefix title)))))))
(add-hook 'howm-mode-on-hook 'change-buffer-name-to-howm-title)
(add-hook '*after-save-buffer-hook* 'change-buffer-name-to-howm-title)

;(setq howm-list-all-title t)
#|
;; xhttp://howm.sourceforge.jp/cgi-bin/hiki/hiki.cgi?HowmWrap
  (defun kill-howm-sidebar-list-all()
    "howm-list-allの時windowがそのままになるのでその対策"
    (setq f (find-buffer *howm-sidebar*))
    (when f
  	(setq b (get-buffer-window f))
  	(if b (set-window b))
  	(delete-window)
  	(delete-buffer *howm-sidebar*)
  	))
  ; サマリとコンテンツは行番号なしにする。より先に書く
  ; そうしないと行番号が表示される。
  (add-hook 'howm-view-contents-mode-hook 'kill-howm-sidebar-list-all)
  ; Sideber から howm-list-all した場合 "@" で連結表示した場合割れたままになる
  ; 対策 howm-view.el 142
  (defun howm-view-save-window-configuration ()
    (when (not (member major-mode howm-view-window-configuration-ignore))
  	(kill-howm-sidebar-list-all)
  	(setq howm-view-window-configuration (current-window-configuration))))
  ;; summary から open すると Menu と sidebar の window が残るのでその対策
  ;howm-view.el 336
  (defun howm-view-summary-open (&optional reverse-delete-p)
    (interactive "P")
    (let ((b (howm-view-contents-buffer))
          (looking-at-str (buffer-substring-no-properties (point)
                                                          (line-end-position)))
          (howm-view-contents-persistent (howm-view-persistent-p howm-view-summary-persistent))) ;; dirty!!
  	(kill-howm-sidebar-list-all)
      (pop-to-buffer b)
      (howm-view-contents-open reverse-delete-p)
      (end-of-line)
      (or (search-backward looking-at-str (line-beginning-position) t)
          (beginning-of-line))
      (run-hooks 'howm-view-open-hook)))
|#
