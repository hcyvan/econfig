(defun search-regexp-in-files (wildcards regexp)
  "Search for regular expression REGEXP in files whose name matches WILDCARDS.
The results will be print to buffer *PrivateResults*."
  (let ((result (or (get-buffer "*PrivateResults*")       ; There will be only one result buffer
		    (generate-new-buffer "*PrivateResults*")))
	(file-list (file-expand-wildcards wildcards))     ; All matched files
	(buffer-to-kill nil))                            ; Record the buffer to be killed
    (if (eq file-list nil)
	(with-current-buffer result
	  (insert "Wrong file name!"))
      (dolist (file-path file-list)
	(setq file (file-name-nondirectory file-path))    ; Get the buffer name
	(let ((buffer (or (progn                          ; File buffer is exist
			    (setq buffer-to-kill nil)
			    (get-buffer file)) 
			  (progn                          ; Create buffer for a file
			    (setq buffer-to-kill file)
			    (find-file-noselect file)))))
	  (with-current-buffer buffer
	    (goto-char (point-min))
	    (while (re-search-forward regexp nil t)       ; no BOUND, NOERROR
	      (let ((hit-line (downcase (what-line))))
		(with-current-buffer result
		  (insert (format "file: %s (%s)\n" buffer hit-line))))))
	(with-current-buffer result
	  (if (eq (buffer-size result) 0)
	      (insert "No hits!"))))
	(if buffer-to-kill
	    (kill-buffer buffer-to-kill))))               ; Kill the buffer-to-kill
    (switch-to-buffer result)))

(defun buffer-line-substring ()
  "Return the line of buffer as string"
  (buffer-substring-no-properties
   (progn
     (beginning-of-line)
     (point))
   (progn
     (end-of-line)
     (point))))

(defun linux-tags ()
  "Search tags in TAGS of the linux kernel tree and go to the matched file.
This function is not finished. But it can work now. "
    (interactive)
    ;; (with-current-buffer (find-file-read-only (car tags-table-list))
    (with-current-buffer (find-file-read-only "/home/navy/linux/TAGS")
      (beginning-of-buffer)
      (isearch-forward t)                    ; Find tags in TAGS.
      (let* ((coordinate (split-string
			(car (last (split-string (buffer-line-substring) "")))
			","))
	     (line-num (car coordinate)))    ; Get the line of the matched tag
	(backward-paragraph)
	; Get the file name contain the matched tag and open it.
	(find-file-read-only (car (split-string (buffer-line-substring) ",")))
	(goto-line (string-to-number line-num)))))   ; Got to the line.


; Global Variable. For count how many shells opened
(setq shell-window-numbers 0)
; The head of the list is the right position
(setq shells-repository '(0))

(defun shells ()
  "Open multiple shells with different name in different buffers.
If *shell* is exist, `shells' open other buffer. If not, do nothing"
  (interactive)
  (with-current-buffer "*shell*"
    (progn
      (rename-buffer "*s0*")
      (shell)
      (setq shell-window-numbers (+ shell-window-numbers 1))
      (let ((shells-name (concat "*shell-" (number-to-string shell-window-numbers) "*")))
	;; add the new shells to the repository. (the second element)
	(let ((tmp (pop shells-repository)))
	  (push shells-name shells-repository)
	  (push tmp shells-repository))
	(setcar shells-repository (+ (car shells-repository) 1))
	
	(rename-buffer shells-name)
	(switch-to-buffer "*s0*")
	(rename-buffer "*shell*")
	(switch-to-buffer shells-name)))))

(defun shell-exit ()
  "Do the `exit' command in shell. "
  (interactive)
  (insert "exit")
  (comint-send-input))

(defun shells-loop-add ()
  "Add shells buffer to `shells-repository' wethear *shell* exist or not"
  (interactive)
  (if (get-buffer "*shell*")
      (shells)
    (shell)
    (shells)
    (with-current-buffer "*shell*" (shell-exit))))

(defun shells-loop (&optional offset)
  "Loop in the shells-repository. If the shell buffer is not exsit, just remove
the buffer name and switch to the next."
;;(interactive "nOffset: ")
  ;; modify the point of shells-repository
  (if (eq (length shells-repository) 1)
      ;; shells-repository have one element
      (or (eq (car shells-repository) 0)
	  (setcar shells-repository 0))
    ;; shells-repository have more than one elements
    (if (< (car shells-repository) 1)
	;; if the point is less than 1, then assign it the biggist value
	(setcar shells-repository (- (length shells-repository) 1)))
    (if (> (car shells-repository) (- (length shells-repository) 1))
	;; if the point is over the boundary, change it to 1 
	(setcar shells-repository 1)))
  ;; switch to the buffer point by (car shells-repository)
  (if (eq (length shells-repository) 1)
      ;; shells-repository is '(0)
      (message "No shells buffer in shells-repository!")        ; exit
      ;; shells-repository is not empty
    (if offset
	;; offset is set
	(progn
	  (setcar shells-repository (+ (car shells-repository) offset))
	  (shells-loop)) 	                      ; recursion entry
      ;; offset is nil
      (let ((buffer (nth (car shells-repository) shells-repository)))
	(if (get-buffer buffer)
	    ;; buffer is exist
	    (progn
	      (switch-to-buffer buffer)                          ; exit
	      (setcar shells-repository (- (car shells-repository) 1)))
	  ;; buffer is not exist
	  (delq buffer shells-repository)
	  (setcar shells-repository (- (car shells-repository) 1))
	  (shells-loop))))))                          ; recursion entry

(defun shells-switch ()
  "If the curent buffer is in the `shells-repository', call `shells-loop' to
loop it. If not, just return to the last buffer in `shells-repository'"
  (interactive)
  (if (< (length shells-repository) 2)
      ;; shells-repository is empty
      (message "No shells buffer in shells-repository!")
    (if (memq (buffer-name (current-buffer)) shells-repository)
	;; (current-buffer) is in shells-repository
	(shells-loop)
      ;; current buffer is not in the shells-repository
      (shells-loop 1))))

(defun kill-buffer-when-shell-exit ()
  "Close current buffer when `shell-mode' exit. This function set a sentinel
to shell and should be add to `shell-mode-hook'. If not, nothing will be done."
  (let ((process (ignore-errors (get-buffer-process (current-buffer)))))
    (when process
      (set-process-sentinel process
                            (lambda (proc change)
                              (when (string-match "finished" change)
                                (kill-buffer (process-buffer proc))))))))

(defun interpret-python ()
  "Interpreting the script by python"
  (interactive)
  (let ((buffer-name (buffer-file-name)))
    (call-process "python"
		  nil
		  (or (get-buffer "*python*")
		      (generate-new-buffer "*python*"))
		  nil
		  buffer-name)
    (switch-to-buffer-other-window "*python*" t)
    (other-window -1)))

(defun load-config ()
  "load .emacs. The global variables will be saved and restore."
  (interactive)
  (let ((global-variables-tmp `((shell-window-numbers . ,shell-window-numbers)
				(shells-repository . ,shells-repository))))
    (load-file "/home/navy/.emacs")
    (dolist (tmp global-variables-tmp)
      (set (car tmp) (cdr tmp)))))