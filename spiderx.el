;;; spiderx.el --- work with licenses -*- lexical-binding: t -*-

;;; Copyright (C) 2018 Omair Majid

;; Author: Omair Majid <omair.majid@gmail.com>
;; URL: https://github.com/omajid/spiderx
;; Package-Requires: ((emacs "24.3"))
;; Keywords: files tools
;; Version: 0.1.20181024

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Utilities for working with licenses in source code

;; Uses SPDX identifiers throughout.

;; I am not a lawyer. I have no understanding of the actual licenses.
;; This package provides tools to make it easier to work with
;; licenses. But you need to figure out the license that you should
;; use for your projects with your own lawyer.

;;; Code:

(require 'json)
(require 'url)

(defvar spiderx-license-alist
  '(("AGPL-3.0" . "https://www.gnu.org/licenses/agpl-3.0.txt")
    ("Apache-2.0" . "http://www.apache.org/licenses/LICENSE-2.0.txt")
    ("GFDL-1.1" . "https://www.gnu.org/licenses/old-licenses/fdl-1.1.txt")
    ("GFDL-1.2" . "https://www.gnu.org/licenses/old-licenses/fdl-1.2.txt")
    ("GFDL-1.3" . "https://www.gnu.org/licenses/fdl.txt")
    ("GPL-2.0" . "https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt")
    ("GPL-3.0" . "https://www.gnu.org/licenses/gpl-3.0.txt")
    ("LGPL-2.0" . "https://www.gnu.org/licenses/old-licenses/lgpl-2.0.txt")
    ("LGPL-2.1" . "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt")
    ("LGPL-3.0" . "https://www.gnu.org/licenses/lgpl-3.0.txt")
    ("MPL-1.1" . "https://www.mozilla.org/media/MPL/1.1/index.0c5913925d40.txt")
    ("MPL-2.0" . "https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt")
    ("WTFPL" . "http://www.wtfpl.net/txt/copying/"))
  "An alist of (license-id . license-url).")

(defvar spiderx--license-root-url
  "https://raw.githubusercontent.com/spdx/license-list-data/master/json/licenses.json")

(defvar spiderx--license-json-details-url
  "https://raw.githubusercontent.com/spdx/license-list-data/master/json/details/%s.json")

(defvar spiderx--license-html-details-url
  "https://spdx.org/licenses/%s.html")

(defun spiderx-show-license (license-id)
  "Show the contents of LICENSE-ID."
  (interactive
   (list (completing-read "License name: "
                          (spiderx--get-license-ids)
                          nil
                          t)))
  (let ((buffer (get-buffer-create "*spiderx*"))
        (inhibit-read-only t)
        (license-url (format spiderx--license-html-details-url license-id)))
    (switch-to-buffer buffer)
    (erase-buffer)
    (goto-char (point-min))
    (insert "SPDX Url: ")
    (insert-text-button license-url
                        'url license-url
                        'action (lambda (b) (browse-url (button-get b 'url))))
    (insert "\n\n")
    (insert (format "SPX Identifier: %s\n\n" license-id))
    (insert "License Text:\n\n")
    (insert (spiderx--get-license-text license-id))
    (goto-char (point-min))))

(defun spiderx-insert-license (license-id)
  "Insert the contents of LICENSE-ID at current point."
  (interactive
   (list (completing-read "License name: "
                          (spiderx--get-license-ids)
                          nil
                          t)))
  (insert (spiderx--get-license-text license-id)))

(defun spiderx-add-license-file (license-id file-name)
  "Create a new file with name FILE-NAME and write LICENSE-ID to it."
  (interactive
   (list (completing-read "License name: "
                          (spiderx--get-license-ids)
                          nil
                          t)
         (read-file-name "File name: " nil "LICENSE")))
  (when (file-exists-p file-name)
    (user-error "File already exists"))
  (find-file-literally file-name)
  (insert (spiderx--get-license-text license-id))
  (save-buffer)
  (kill-current-buffer))

(defun spiderx--get-license-ids ()
  "Get a list of license ids."
  (let* ((licenses-url spiderx--license-root-url)
         (buffer (url-retrieve-synchronously licenses-url))
         (http-contents (spiderx--http-response-contents-from-and-kill-buffer buffer))
         (licenses-data (json-read-from-string http-contents))
         (license-data (cdr (assq 'licenses licenses-data))))
    (mapcar (lambda (elt) (cdr (assq 'licenseId elt))) license-data)))

(defun spiderx--get-license-text (license-id)
  "Get the license text of the given LICENSE-ID."
  (if (assoc license-id spiderx-license-alist)
      (spiderx--get-license-text-hardcoded license-id)
    (spiderx--get-license-text-spdx license-id)))

(defun spiderx--get-license-text-hardcoded (license-id)
  "Get the license text for LICENSE-ID from the known hardc-oded URLs in `spiderx-license-alist'."
  (let* ((buffer (url-retrieve-synchronously (cdr (assoc license-id spiderx-license-alist))))
         (body (spiderx--http-response-contents-from-and-kill-buffer buffer)))
    body))

(defun spiderx--get-license-text-spdx (license-id)
  "Get the license text for LICENSE-ID from spdx."
  (cdr (assq 'licenseText (spiderx--get-license-data license-id))))

(defun spiderx--get-license-data (license-id)
  "Get the spdx json data for the given LICENSE-ID."
  (let* ((license-url (format spiderx--license-json-details-url license-id))
         (buffer (url-retrieve-synchronously license-url))
         (http-contents (spiderx--http-response-contents-from-and-kill-buffer buffer))
         (license-data (json-read-from-string http-contents)))
    license-data))

(defun spiderx--http-response-contents-from-and-kill-buffer (buffer)
  "Extract http response body from and kill the given BUFFER."
  (prog2
      (switch-to-buffer buffer)
      (spiderx--http-response-contents)
    (kill-buffer buffer)))

(defun spiderx--http-response-contents ()
  "Assumes current buffer is the one containing result of `url-retrieve-synchronously' or some such."
  (goto-char (point-min))
  ;; find first newline indicating end of http headers
  (re-search-forward "^$")
  ;; skip empty lines
  (re-search-forward "[^\n]")
  (beginning-of-line)
  (buffer-substring-no-properties (point) (point-max)))

(provide 'spiderx)
;;; spiderx.el ends here
