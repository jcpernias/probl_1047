(require 'ox)
(require 'seq)

;; ================================================================================
;; Org utility functions
;; ================================================================================

(defun get-current-level (element)
  "Get the level to which ELEMENT belongs"
  (let ((headline (org-element-lineage element '(headline) t)))
    (if headline
        (org-element-property :level headline) 0)))

(defun get-affiliated (element)
  (buffer-substring (org-element-property :begin element)
                    (org-element-property :post-affiliated element)))

(defun get-post-blank (element)
  (org-element-property :post-blank element))


(defun delete-comments (doc)
  "Remove comments, comment blocks, and commented trees from Org document tree DOC"
  (org-element-map doc '(comment comment-block) 'org-element-extract-element)
  (org-element-map doc 'headline
    (lambda (hl)
      (and (org-element-property :commentedp hl)
           (org-element-extract-element hl)))))

(defun find-all-siblings (element)
  "Return a list with all siblings of ELEMENT including itself"
  (org-element-contents (org-element-property :parent element)))

(defun find-contents (element end-contents-p)
  "Return all siblings after ELEMENT and before END-CONTENS-P returns true"
  (let ((siblings (find-all-siblings element))
        (before t)
        (after))
    (seq-filter
     (lambda (e)
       (cond
        (before (progn
                  (when (eq e element)
                    (setq before nil))
                  nil))
        (after nil)
        (t (if (funcall end-contents-p e)
               (progn (setq after t) nil)
             t))))
     siblings)))

(defun headline-p (element)
  (eq (org-element-type element) 'headline))

(defun item-p (element)
  (eq (org-element-type element) 'item))

(defun comment-p (element)
  (eq (org-element-type element) 'comment))


;; Comments
;; --------------------------------------------------------------------------------
(defun make-comment (value)
  "Return a comment"
  (org-element-create
       'comment
       (list :value (concat "# " value))))

;; Sections
;; --------------------------------------------------------------------------------
(defun make-section ()
  (org-element-create 'section))


;; Property drawers
;; --------------------------------------------------------------------------------
(defun make-node-property (key value)
  "Return a node property"
  (org-element-create
       'node-property
       (list :key key :value value)))

(defun make-property-drawer (&rest nodes)
  "Return a property drawer with property nodes NODES"
  (apply 'org-element-create
         'property-drawer nil nodes))

;; Headlines
;; --------------------------------------------------------------------------------
(defun make-headline (title level &rest children)
  "Return a headline with the given TITLE and LEVEL"
  (apply 'org-element-create
         'headline (list :title title :level level)
         children))

(defun make-headline-unnumbered (title level)
  "Return an unnumbered headline with the given TITLE and LEVEL"
  (make-headline
   title level
   (make-property-drawer
    (make-node-property "UNNUMBERED" t))))

;; Special blocks
;; --------------------------------------------------------------------------------
(defun make-special-block (type &optional post-blank)
  "Return an empty special block of type TYPE"
  (let ((props (list :type type)))
    (and post-blank (setq props (append props (list :post-blank post-blank))))
    (org-element-create 'special-block props)))


;; Paragraphs
;; --------------------------------------------------------------------------------
(defun make-paragraph (contents &optional post-blank)
  "Return a paragraph with the given CONTENTS"
  (let ((props (and post-blank (list :post-blank post-blank))))
    (apply 'org-element-create
           'paragraph props contents)))

;; Links
;; --------------------------------------------------------------------------------
(defun make-link (type path)
  "Return a link"
  (org-element-create 'link (list :type type :path path)))


(defun make-par-link (type path &optional affiliated post-blank)
  "Return a paragraph with a link"
  (let ((link (make-link type path))
        (contents))
    (setq contents (if affiliated (list affiliated link) link))
    (make-paragraph contents post-blank)))


;; Keywords
;; --------------------------------------------------------------------------------
(defun make-keyword (key value)
  (org-element-create 'keyword (list :key key :value value)))


(defun make-latex-keyword (value)
  (make-paragraph (list (make-keyword "LATEX" value))))

;; ================================================================================
;; XXX keywords
;; ================================================================================


(defun xxx-keyword-p (element)
  "Returns t if ELEMENT is a xxx-keyword"
  (and (eq (org-element-type element) 'keyword)
       (string= (org-element-property :key element) "XXX")))

(defun xxx-col-p (element)
  "Returns t if ELEMENT is a col xxx-keyword
It only works after parse-xxx-keywords"
  (and (xxx-keyword-p element)
       (string= (org-element-property :xxx-type element) "col")))

(defun xxx-endcol-p (element)
  "Returns t if ELEMENT is a col xxx-keyword
It only works after parse-xxx-keywords"
  (and (xxx-keyword-p element)
       (string= (org-element-property :xxx-type element) "endcol")))

(defun parse-xxx-keywords (doc)
  "Add xxx-type and xxx-value properties to a xxx-keyword"
  (org-element-map doc 'keyword
    (lambda (keyword)
      (let ((type)
            (text)
            (value))
        (when (xxx-keyword-p keyword)
          (setq text (org-element-property :value keyword))
          (when (string-match
                 "[[:blank:]]*\\([^[:blank:]]+\\)\\(?:[[:blank:]]+\\(.*\\)\\)?[[:blank:]]*\\'" text)
            (setq keyword (org-element-put-property keyword :xxx-type (match-string 1 text)))
            (setq keyword (org-element-put-property keyword :xxx-value (match-string 2 text)))))))))


(defun process-xxx-keywords (doc)
  "Get the different parts of a XXX keyword and call the appropriate handler"
  (parse-xxx-keywords doc)
  (org-element-map doc 'keyword
    (lambda (keyword)
      (let ((type)
            (text)
            (value))
        (when (xxx-keyword-p keyword)
          (setq type (org-element-property :xxx-type keyword))
          (cond ((string= type "endcol") (xxx-endcol keyword))
                ((string= type "col") (xxx-col keyword))
                ((string= type "fig") (xxx-fig keyword))
                (t nil)))))))


;; Figures
;; --------------------------------------------------------------------------------
(defun fig-file-path (value lang)
  (if (string-match "\\*" value)
      (replace-match (or lang "\\LANG") nil t value)
    value))

(defun xxx-fig (element)
  (org-element-set-element
   element
   (make-par-link
    "file"
    (fig-file-path (org-element-property :xxx-value element) nil)
    (get-affiliated element)
    (get-post-blank element))))


;; Columns
;; --------------------------------------------------------------------------------

(defun end-xxx-col-contents-p (element)
  "Return t if ELEMENT is a headline, a list item or another xxx col."
  (or (headline-p element)
      (item-p element)
      (xxx-endcol-p element)
      (xxx-col-p element)))

(defun xxx-col (element)
  (let ((contents (find-contents element #'end-xxx-col-contents-p))
        (minipage (make-special-block "minipage"))
        (affiliated (get-affiliated element)))
    (apply 'org-element-adopt-elements minipage
           (seq-map #'org-element-extract-element contents))
    (and affiliated (setq minipage (list affiliated minipage)))
    (org-element-set-element
     element
     (make-paragraph minipage (get-post-blank element)))))

(defun xxx-endcol (element)
  (org-element-set-element
   element (make-comment "endcol")))

;; ================================================================================
;; Problems
;; ================================================================================

(defun handle-section (section)
  "Collect answers within a section.

Extract answers (level 3 headlines) and add them to the contents of a new section
with the same title as the original one.
"
  (let ((answers)
        (new-section))
    (setq answers
          (org-element-map section 'headline
            (lambda (hl)
              (when (= (org-element-property :level hl) 3)
                (org-element-put-property (org-element-extract-element hl) :level 2)))))
    (when answers
      (setq new-section (make-headline (org-element-property :title section) 1))
      (apply 'org-element-adopt-elements new-section answers))))


(defun make-solutions-section (doc)
  "Make a solutions section.

Iterate over first level sections and process then with handle-section.
Collect the results and add them to a new solutions section at the end
of the document."
  (let ((sections)
        (new-section))
    (setq sections
          (org-element-map doc 'headline
            (lambda (hl)
              (and (= (org-element-property :level hl) 1)
                   (handle-section hl)))))
    (setq new-section (make-section))
    (org-element-adopt-elements new-section (make-latex-keyword "\\SolutionsGeometry{}"))
    (org-element-adopt-elements new-section (make-latex-keyword "\\begin{solutions}"))
    (when sections
      (apply 'org-element-adopt-elements new-section sections))
    (org-element-adopt-elements new-section (make-latex-keyword "\\end{solutions}"))))

(defun handle-answers (headline)
  "Convert answer sections to special blocks."
  (let ((block))
    (and (= (org-element-property :level headline) 2)
         (progn
           (setq block (make-special-block "answer" (get-post-blank headline)))
           (apply 'org-element-adopt-elements block (org-element-contents headline))
           (org-element-set-element headline block)))))

(defun prepare-buffer ()
  "Parse problems document"
  ;; (interactive)
  (let ((doc))
    (org-export-expand-include-keyword)
    (setq doc (org-element-parse-buffer))
    (delete-comments doc)
    ;; (org-element-adopt-elements doc (make-solutions-section doc))
    (org-element-map doc 'headline 'handle-answers)
    (process-xxx-keywords doc)
    (org-element-interpret-data doc)))

(defun preprocess-document (backend)
  "Replace buffer with preprocessed document"
  (let ((new (prepare-buffer)))
    (erase-buffer)
    (insert new)))


;; (remove-hook 'org-export-before-parsing-hook 'preprocess-probl)
(add-hook 'org-export-before-parsing-hook 'preprocess-document)


(defun print-tree (tree &optional indent)
  (setq indent (or indent 0))
  (dolist (node tree)
    (princ
     (format "%s%s\n" (make-string (* 2 indent) ? )
             (org-element-type node)) (get-buffer "*scratch*"))
    (setq contents (org-element-contents node))
    (when contents
      (print-tree contents (+ indent 1)))))
