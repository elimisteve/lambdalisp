(progn
  (defglobal defmacro (macro (r e &rest b)
    `(defglobal ,r (macro ,e (block ,r ,@b)))))

  (defmacro defun (r e &rest b)
    `(defglobal ,r (lambda ,e (block ,r ,@b))))

  (defmacro defun-local (r e &rest b)
    `(setq ,r (lambda ,e (block ,r ,@b))))

  (defmacro defparameter (a b)
    `(defglobal ,a ,b))

  (defmacro funcall (f &rest e)
    `(,f ,@e))

  (defmacro floor (a b)
    `(/ ,a ,b))

  (defmacro mod (a b)
    `(% ,a ,b))

  (defglobal list (macro (&rest q)
    (if q
      (cons 'cons (cons (car q) (cons (cons 'list (cdr q)) ()))))))

  (defglobal cond (macro (a &rest b)
    (if a
      (list 'if (car a)
        (cons 'progn (cdr a))
        (cons 'cond b)))))

  (defun and (p &rest q)
    (if q
      (if p
        (apply and q))
      p))

  (defun or (a &rest b)
    (if b
      (if a t (apply or b))
      a))

  (defun not (p)
    (if p () t))

  (defun equal (p q)
    (or (eq p q) (= p q)))

  (defun stringp (p)
    (eq (type p) 'str))

  (defmacro labels (l &rest b)
    `(let (,@(mapcar (lambda (i) `(,(car i) ())) l))
      ,@(mapcar (lambda (i) `(setq ,(car i) (lambda ,@(cdr i)))) l)
      ,@b))

  (defun length (l)
    (if (atom l)
      0
      (+ 1 (length (cdr l)))))

  (defmacro return (&rest p)
    `(return-from () ,(if (atom p) p (car p))))

  (defun position* (i l test-f)
    (let ((i 0))
      (loop
        (if (atom l)
          (return ()))
        (if (test-f i (car l))
          (return i))
        (setq i (+ 1 i))
        (setq l (cdr l)))))

  (defmacro position (i l test test-f)
    `(position* ,i ,l ,test-f))

  (defmacro concatenate (p &rest e)
    `(+ ,@e))

  (defun write-to-string (p)
    (str p))

  (defun mapcar (f p)
    (if p
      (cons (f (car p)) (mapcar f (cdr p)))))

  (defun reverse (l)
    (let ((ret ()))
      (loop
        (if (atom l)
          (return ret))
        (setq ret (cons (car l) ret))
        (setq l (cdr l)))))

  (defmacro reduce (f l)
    `(eval (cons ,f ,l)))

  (defun string (p)
    (str p))

  (defun format (option str &rest e)
    ;; Supports ~a and ~%
    (let ((ret ()))
      (loop
        (cond
          ((eq str "")
            (return ()))
          ((eq (carstr str) "~")
            (setq str (cdrstr str))
            (cond
              ((eq (carstr str) "%")
                ;; `?` gets compiled to a newline in compile-prelude.sh
                (setq ret (cons "?" ret)))
              ((eq (carstr str) "a")
                (if e
                  (progn
                    (setq i (car e))
                    (setq e (cdr e)))
                  (setq i ()))
                (setq ret (cons (str i) ret)))))
          (t
            (setq ret (cons (carstr str) ret))))
        (setq str (cdrstr str)))

      (setq str "")
      (loop
        (if (eq ret ())
          (return ()))
        (setq str (+ (car ret) str))
        (setq ret (cdr ret)))
      (if option
        (progn
          (print str t)
          ())
        str)))

  ;;================================================================
  ;; Hash table
  ;;================================================================
  (defun make-hash-table* ()
    (let ((hashtable ()))
      (defun-local getter (key)
        (let ((hashlist hashtable))
          (loop
            (if (atom hashlist)
              (return ()))
            (if (eq key (car (car hashlist)))
              (return (cdr (car hashlist))))
            (setq hashlist (cdr hashlist)))))
      (defun-local setter (key value)
        (setq hashtable (cons (cons key value) hashtable)))
      (lambda (mode key &rest value)
        (if (eq mode 'get)
          (getter key)
          (if (eq mode 'set)
            (setter key (car value)))))))

  (defmacro make-hash-table (&rest p)
    (make-hash-table*))

  (defun gethash (key hashtable)
    (hashtable 'get key))


  ;;================================================================
  ;; Object system
  ;;================================================================
  (defmacro . (instance accesor)
    `(,instance ',accesor))

  (defmacro new (&rest e)
    `((lambda (instance)
        (if (. instance *init)
          ((. instance *init) ,@(cdr e)))
        instance)
      (,(car e))))

  (defmacro let* (r &rest b)
    (defun-local helper (e)
      (if e
        `(let (,(car e)) ,(helper (cdr e)))
        `(progn ,@b)))
    (helper r))

  (defmacro defclass (r superclass &rest b)
    (labels
      ((collect-fieldnames (e)
        (setq head (car (car e)))
        (if e
          (cons (if (eq head 'defmethod)
                  (car (cdr (car e)))
                  head)
                (collect-fieldnames (cdr e)))))
      (*parse-b (b)
        (setq *head (car (car b)))
        (if b
          (cons (if (eq *head 'defmethod)
                  (let ((fieldname (car (cdr (car b))))
                        (a (car (cdr (cdr (car b)))))
                        (*rest (cdr (cdr (cdr (car b))))))
                    `(,fieldname (lambda ,a ,@*rest)))
                  (car b))
                (*parse-b (cdr b)))))
      (*build-getter (e)
        (defun-local helper (e)
          (if e
            `(if (eq a ',(car e))
                ,(car e)
                ,(helper (cdr e)))
            '(if super
              (super a))))
        `(lambda (a) ,(helper (cons 'setter (cons 'super e)))))

      (*build-setter (e)
        (defun-local helper (e)
          (if e
            `(if (eq key ',(car e))
                (setq ,(car e) value)
                ,(helper (cdr e)))
            '(if super
              ((super 'setter) key value))))
        `(lambda (key value) ,(helper e))))
    (let ((fieldnames (collect-fieldnames b)))
      `(defun-local ,r ()
        (let* ((super ())
              (self ())
              (setter ())
              ,@(*parse-b b))
          (setq super ,superclass)
          (setq setter ,(*build-setter fieldnames))
          (setq self ,(*build-getter fieldnames)))))))

  (defmacro setf* (place value)
    (if (atom place)
      `(setq ,place ,value)
      ;; Hash table
      (if (eq (car place) 'gethash)
        `(,(car (cdr (cdr place))) 'set ,(car (cdr place)) ,value)
        ;; Class field
        (if (eq (car place) '.)
          (progn
            (setq instance (car (cdr place)))
            (setq fieldname (car (cdr (cdr place))))
            `((. ,instance setter) ',fieldname ,value))
          (error "unknown setf pattern")))))

  (defmacro setf (place value)
    `(setf* ,place ,value))

  (defun load (e)
    e)

  (set-macro-character "#"
    (lambda (char)
      (if (eq "\\" (peek-char))
        (progn
          (read-char)
          (read-char))
        (progn
          (if (eq "'" (peek-char))
            (read-char))
          (read))))))
