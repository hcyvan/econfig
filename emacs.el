
;;****************** Global Set *******************

;(tool-bar-mode 0); emacs X
(menu-bar-mode 0); emacs and emacs X
;(scroll-bar-mode 0);emacs X
;(setq-default tab-width 8);设置tab宽度,注意此处用setq无效
;按tab键，直接插入等量空格（与用空格表示tab相区分），tab用C-q tab插入
;(setq-default indent-tabs-mode  nil)
;(setq line-number-mode t) 
(setq column-number-mode t)
(display-time)

;; 更改备份文件(*.~)的产生目录，至~/.emacs.d/backups
(setq backup-directory-alist (quote (("." . "~/.emacs.d/backups"))))
;; Load my elisp lib
(load-file "~/.emacs.d/elisplib.el")
(add-to-list 'tags-table-list "/home/navy/linux/TAGS")

(setq inhibit-startup-message t) ;; remove startup message
(setq initial-scratch-message t) ;; remove the message in *scratch*
;; shell-mode is the default mode.
;; (switch-to-buffer (get-buffer-create (shell)))
;; (setq debug-on-error t)

;;******************* Plug-in ********************

(add-to-list 'load-path "~/.emacs.d/plugin/")
; markdown-mode
(autoload 'markdown-mode "markdown-mode" "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
; color-theme
; 使用说明：下载后解压缩至~/.emacs.d/plugin/目录下，然后执行
; 如下命令。如果没有安装color-theme插件，可将下面的代码注释
; M-x color-theme-select: Select your comfrotable color theme.
(add-to-list 'load-path "~/.emacs.d/plugin/color-theme-6.6.0")
(require 'color-theme) 	;载入color-theme插件
(color-theme-initialize)	;必要初始化
;; (color-theme-deep-blue)      ;选择主题
(color-theme-calm-forest)
;; (color-theme-taming-mr-arneson)

;;******************* Build-in *********************
;; c-mode
(c-add-style "myC"
	     '("k&r"
	       (c-basic-offset . 8)))
(add-hook 'c-mode-hook
	  (lambda ()
	    (progn
	      (c-set-style "myC")
	      ; use tab other than spaces
	      (setq indent-tabs-mode t)
	      ;(setq tab-width 8)
	      (setq compile-command "gcc -Wall "))))
;; c++-mode
(add-hook 'c++-mode-hook (lambda ()
			 (setq compile-command "g++ -Wall ")))
;; python-mode
(add-hook 'python-mode-hook
	  (lambda ()
	    (progn
	      (define-key python-mode-map (kbd "<f5>") 'interpret-python)
	      (setq compile-command "python "))))

;; shell-mode
; 使 shell 的色彩信息能被 Emacs 解析
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)
; 向 hook 中添加哨兵
(add-hook 'shell-mode-hook
	  '(lambda ()
	     (progn
	       (kill-buffer-when-shell-exit))))

;;****************** Key Bind ***********************
;; python-mode:    C-c i    interpret-python

(global-set-key (kbd "C--") 'undo); undo
(global-set-key (kbd "C-c C-f") 'find-name-dired); "find ./ -name"
(global-set-key (kbd "<f6>") 'compile); compile
(global-set-key (kbd "<f5>") 'load-config); load-config
(global-set-key (kbd "<f12>") 'shell); shell
(global-set-key (kbd "<f10>") 'shells-loop-add); shells-loop-add
(global-set-key (kbd "<f9>") 'shells-switch); shells-switch
(global-set-key (kbd "C-c m") 'rectangle-mark-mode); rectangle


(server-start)





