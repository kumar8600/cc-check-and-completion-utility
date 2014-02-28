;;; yabai-client.el --- yabai-mode back-end for client of compilation database sever

;; Author: kumar8600 <kumar8600@gmail.com>

;; Copyright (c) 2014 by kumar8600
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without modification,
;; are permitted provided that the following conditions are met:

;; * Redistributions of source code must retain the above copyright notice, this
;;   list of conditions and the following disclaimer.

;; * Redistributions in binary form must reproduce the above copyright notice, this
;;   list of conditions and the following disclaimer in the documentation and/or
;;   other materials provided with the distribution.

;; * Neither the name of the kumar8600 nor the names of its
;;   contributors may be used to endorse or promote products derived from
;;   this software without specific prior written permission.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
;; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
;; ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;;; Code:

(require 'yabai-utilities)

;;;;====================================================================================
;;;; Variables
;;;;====================================================================================
(yabai/def-option-var yabai/emacs-executable
		      (executable-find "emacs")
		      "Location of emacs executable."
		      :type 'file)

(defconst yabai/server-process-name "emacs-yabai-server")
(defconst yabai/server-buffer-name "*yabai/server*")
(defconst yabai/server-el-path (expand-file-name "server.el"
						 (file-name-directory (or load-file-name
									  (buffer-file-name)))))
(defvar yabai/server-process nil)

;;;;====================================================================================
;;;; Functions
;;;;====================================================================================
(defun yabai/start-server ()
  "Start the compilation database server."
  (interactive)
  (when (yabai/client-is-server-working)
    (error "Compilation database server process has already been launched"))
  (let ((prc (start-process yabai/server-process-name
			    yabai/server-buffer-name
			    (format "%s --script %s"
				    yabai/emacs-executable
				    yabai/server-el-path))))
    (set-process-query-on-exit-flag prc nil)
    (set-process-filter prc #'yabai/client-filter-function)
    (setq yabai/server-process prc)))

(defun yabai/stop-server ()
  "Stop the compilation database server."
  (interactive)
  (unless (yabai/client-is-server-working)
    (error "To begin with, compilation database server is not working"))
  (interrupt-process yabai/server-process))

;;;; Variable
(defvar yabai/client-identifier->buffer-sentinel-table (make-hash-table :test 'equal))

(defun yabai/client-filter-function (proc str)
  "When server outputed something, this function is called.

This function provides mechanism of sentinel.
PROC and STR are arguments passed by Emacs."
  (let ((it 0))
    (let ((lst (read-from-string str it)))
      (setq it (cdr lst))
      (let ((identifier (car lst))
	    (result (cdr lst)))
	(let ((buffer-sentinel (gethash identifier yabai/client-identifier->buffer-sentinel-table)))
	  (when buffer-sentinel
	    (let ((buffer (car buffer-sentinel))
		  (sentinel (cdr buffer-sentinel)))
	      (with-current-buffer buffer
		(funcall sentinel result))
	      (remhash identifier yabai/client-identifier->buffer-sentinel-table))))))))

(defun yabai/client-send-string-to-server (str)
  "Send STR to the compilation database server."
  (let ((status (process-status yabai/server-process)))
    (unless (yabai/client-is-server-working)
      (error "Compilation database server is not working")))
  (process-send-string yabai/server-process
		       str))

(defun yabai/client-send-list-to-server (lst)
  "Send LST to the compilation database server."
  (yabai/client-send-string-to-server (concat (prin1-to-string lst) "\n")))

(defun yabai/client-request (lst &optional sentinel)
  "Send request LST to server.

When the job is end, SENTINEL is called.
SENTINEL is function takes argument RESULT.
RESULT is object."
  (let ((identifier (make-temp-name (buffer-file-name))))
    (when sentinel
      (puthash identifier
	       (cons (current-buffer) sentinel)
	       yabai/client-identifier->buffer-sentinel-table))
    (yabai/client-send-list-to-server (cons identifier lst))))

;;;;====================================================================================
;;;; Utilities
;;;;====================================================================================
(defun yabai/client-is-server-working ()
  "If compilation database server is working, return non-nil."
  (let ((status (process-status yabai/server-process)))
    (if (or (eq status 'run)
	    (eq status 'stop))
	t
      nil)))

(defun yabai/client-request-add-database (database-path &optional sentinel)
  "Add compilation database at DATABASE-PATH to server.

When this job is end, SENTINEL is called.
SENTINEL is function takes argument RESULT.
RESULT is object."
  (let ((lst (list 'add-database database-path)))
    (yabai/client-request lst sentinel)))

(defun yabai/client-request-get-options (src-file-path database-path &optional sentinel)
  "Request to get compilation options of SRC-FILE-PATH defined in DATABASE-PATH.

When this job is end, SENTINEL is called.
SENTINEL is function takes argument RESULT.
RESULT is object."
  (let ((lst (list 'get-options src-file-path database-path)))
    (yabai/client-request lst sentinel)))

;; (defun yabai/client-set-process-filter (filter)
;;   "Set process FILTER function to database server process."
;;   (let ((status (process-status yabai/server-process)))
;;     (unless (or (eq status 'run)
;; 		(eq status 'stop))
;;       (error "Compilation database server is not working")))
;;   (set-process-filter yabai/server-process
;; 		      filter))

(provide 'yabai-client)

;;; yabai-client.el ends here
