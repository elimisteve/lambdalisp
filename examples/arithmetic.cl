(defparameter **lambdalisp-suppress-repl** t) ;; Enters script mode and suppresses REPL messages

(print (+ 1 2 3 4 -5))
(print (- 1 2 3 4 -5))
(print (* 1 2 3 4 -5))

(print (floor 11 3))
(print (mod 11 3))


;; The extra `if ... 'T 'NIL` is present for compatibility with Common Lisp.
;; This is since LambdaLisp prints t and nil as `t` and `()`, while Common Lisp prints them as `T` and `NIL`.
;; Raw comparison expressions evaluate to either t or nil. For example, (< 1 2) => t.
(print (if (< 1 2)   'T 'NIL))
(print (if (< -1 2)  'T 'NIL))
(print (if (< 1 -2)  'T 'NIL))
(print (if (< -1 -2) 'T 'NIL))
(print (if (< 2 1)   'T 'NIL))
(print (if (< -2 1)  'T 'NIL))
(print (if (< 2 -1)  'T 'NIL))
(print (if (< 2 -1)  'T 'NIL))
(print (if (< 1 1)   'T 'NIL))
(print (if (< -1 -1) 'T 'NIL))

(print (if (> 1 2)   'T 'NIL))
(print (if (> -1 2)  'T 'NIL))
(print (if (> 1 -2)  'T 'NIL))
(print (if (> -1 -2) 'T 'NIL))
(print (if (> 2 1)   'T 'NIL))
(print (if (> -2 1)  'T 'NIL))
(print (if (> 2 -1)  'T 'NIL))
(print (if (> 2 -1)  'T 'NIL))
(print (if (> 1 1)   'T 'NIL))
(print (if (> -1 -1) 'T 'NIL))

(print (if (<= 1 2)   'T 'NIL))
(print (if (<= -1 2)  'T 'NIL))
(print (if (<= 1 -2)  'T 'NIL))
(print (if (<= -1 -2) 'T 'NIL))
(print (if (<= 2 1)   'T 'NIL))
(print (if (<= -2 1)  'T 'NIL))
(print (if (<= 2 -1)  'T 'NIL))
(print (if (<= 2 -1)  'T 'NIL))
(print (if (<= 1 1)   'T 'NIL))
(print (if (<= -1 -1) 'T 'NIL))

(print (if (>= 1 2)   'T 'NIL))
(print (if (>= -1 2)  'T 'NIL))
(print (if (>= 1 -2)  'T 'NIL))
(print (if (>= -1 -2) 'T 'NIL))
(print (if (>= 2 1)   'T 'NIL))
(print (if (>= -2 1)  'T 'NIL))
(print (if (>= 2 -1)  'T 'NIL))
(print (if (>= 2 -1)  'T 'NIL))
(print (if (>= 1 1)   'T 'NIL))
(print (if (>= -1 -1) 'T 'NIL))

(print (if (= 1 2)   'T 'NIL))
(print (if (= -1 2)  'T 'NIL))
(print (if (= 1 -2)  'T 'NIL))
(print (if (= -1 -2) 'T 'NIL))
(print (if (= 2 1)   'T 'NIL))
(print (if (= -2 1)  'T 'NIL))
(print (if (= 2 -1)  'T 'NIL))
(print (if (= 2 -1)  'T 'NIL))
(print (if (= 1 1)   'T 'NIL))
(print (if (= -1 -1) 'T 'NIL))
