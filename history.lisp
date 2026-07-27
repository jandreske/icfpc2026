;; Script to create "History lesson" solution from icfp-history.txt.
;; The generated solution needs some formatting by hand to create a
;; proper box-shaped box before submitting.

;; Solution approach:
;; We just output the characters sequentially.
;; To generate shorter code, we keep track of the contents of
;; both hands, and try to generate minimal code sequences to compute
;; the next character value from either A or B.


(defvar *text* (uiop:read-file-string "icfp-history.txt"))

(defun delta (a b)
  (abs (- a b)))

(defun arith-from-to (a b to)
  "Generate a short code sequence to put TO in the main hand.
A and B are the current hand contents.
Returns the code sequence as a string and the new value of the off-hand."
  (cond ((= a to)
	 (values "" b))
	((eql b to) (values "W" a))
	((= to (+ a b))
	 (values "+" b))
	((= to (- a b))
	 (values "-" b))
	((= to (logand a b))
	 (values "&" b))
	((= to (logior a b))
	 (values "|" b))
	((= to (logxor a b))
	 (values "~" b))
	((= to (- b a))
	 (values "W-" a))
	((and (> b 0) (= (mod to b) 0) (<= 2 (floor to b) 9))
	 (values (format nil "~d*" (floor to b)) b))
	((<= (+ b 1) to (+ b 9))
	 (values (format nil "~D+" (- to b)) b))
	((<= (- b 9) to (- b 1))
	 (values (format nil "~DN+" (- b to)) b))
	((<= (+ a 1) to (+ a 9)) (values (format nil "M~D+" (- to a)) a))
	((<= (- a 9) to (- a 1)) (values (format nil "M~DN+" (- a to)) a))
	((and (> to a) (< (delta to (* 3 a)) (delta to (* 2 a))))
	 (multiple-value-bind (insts b2)
	     (arith-from-to (* 3 a) a to)
	   (values (format nil "M++~A" insts) b2)))
	((and (> to a) (< (delta to (* 2 a)) (delta to a)))
	 (multiple-value-bind (insts b2)
	     (arith-from-to (* 2 a) a to)
	   (values (format nil "M+~A" insts) b2)))
	((and (< to a) (< (delta to (floor a 3)) (delta to (floor a 2))))
	 (multiple-value-bind (insts b2)
	     (arith-from-to (floor a 3) (mod a 3) to)
	   (values (format nil "M3W/~A" insts) b2)))
	((and (< to a) (< (delta to (floor a 2)) (delta to a)))
	 (multiple-value-bind (insts b2)
	     (arith-from-to (floor a 2) (mod a 2) to)
	   (values (format nil "M2W/~A" insts) b2)))
	((and (> a 0) (= (mod to a) 0) (<= 2 (floor to a) 9))
	 (values (format nil "M~d*" (floor to a)) a))
	((> to a)
	 ;; output something like "M9W+++++W3+"
	 (multiple-value-bind (nines rest) (floor (- to a) 9)
	   (if (and (= nines 1) (oddp rest))
	       (values (format nil "M~dW++" (floor (+ 9 rest) 2))
		       (floor (+ 9 rest) 2))
	       (values (format nil "M9W~a~a"
			       (make-string nines :initial-element #\+)
			       (if (= rest 0) "" (format nil "W~d+" rest)))
		       (if (= rest 0) 9 (- to rest))))))
	(t
	 (multiple-value-bind (nines rest) (floor (- a to) 9)
	   (if (and (= nines 1) (oddp rest))
	       (values (format nil "M~dW--" (floor (+ 9 rest) 2))
		       (floor (+ 9 rest) 2))
	       (values (format nil "M9W~a~a"
			       (make-string nines :initial-element #\-)
			       (if (= rest 0) "" (format nil "W~dN+" rest)))
		       (if (= rest 0) 9 (+ to rest))))))))


(defun encode (text)
  "Encode text to Littleman code.
Keep track of the contents of both hands, and try to generate
minimal code sequences to put the next character value in A
and send it to output."
  (let ((long
	 (with-output-to-string (s)
	   (format s "@9M5*")
	   (let ((A 45)
		 (B 9))
	     (declare (type (integer 32 126) A)
		      (type (integer 0 126) B))
	     (loop for c across text do
		   (let ((code (char-code c)))
		     (multiple-value-bind (insns B2)
			 (arith-from-to A B code)
		       (format s "~As" insns)
		       (setf A code B B2))))))))
    (format t "Input length: ~D, output length: ~D~%" (length text) (length long))
    long))

(defun format-square (code)
  "Format code into a square, reversing alternating lines."
  (let ((width (+ (floor (sqrt (length code))) 2))
	(left-to-right t)
	(lines nil)
	(line nil)
	(col 0))
    (loop for c across code do
	  (when (>= col width)
	    (push #\v line)
	    (cond (left-to-right
		   (push (coerce (nreverse line) 'string) lines)
		   (setf line '(#\<)))
		  (t
		   (push (coerce line 'string) lines)
		   (setf line '(#\>))))
	    (setf left-to-right (not left-to-right))
	    (setf col 1))
	  (push c line)
	  (incf col))
    (when (> (length line) 1)
      (push (coerce (if left-to-right (nreverse line) line) 'string) lines))
    (nreverse lines)))
	    
    
	     
(defun doit ()
  "Generate solution and write it to file history.man"
  (let* ((lines (format-square (encode *text*)))
	 (width (apply #'max (mapcar #'length lines)))
	 (height (length lines)))
    (format t "width: ~D, height: ~D~%" width height)
    (format t "width: ~D, height: ~D with boxes and output~%" (+ width 2) (+ height 5))
    (with-open-file (out "history.man" :direction :output :if-exists :rename)
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%")
      (loop for line in lines do
	    (format out "|~A|~%" line))
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%+-+ v~%|O|<<~%+-+~%"))))
	    
    
