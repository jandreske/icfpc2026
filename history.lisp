;; Script to create "History lesson" solution from icfp-history.txt.
;; The generated solution needs to formatting by hand to create a
;; proper box-shaped box befor submitting.


(defvar *text* (uiop:read-file-string "icfp-history.txt"))

(defun delta (a b)
  (abs (- a b)))

(defun arith-from-to (a b to)
  (cond ((= a to) "")
	((eql b to) (values "W" a))
	((and (numberp b) (= to (+ a b)))
	 (values "+" b))
	((and (numberp b) (= to (- a b)))
	 (values "-" b))
	((and (numberp b) (= to (- b a)))
	 (values "W-" a))
	((and (numberp b) (<= (+ b 1) to (+ b 9)))
	 (values (format nil "~D+" (- to b)) b))
	((and (numberp b) (<= (- b 9) to (- b 1)))
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
	((and (< to a) (< (delta to (floor a 2)) (delta to a)))
	 (multiple-value-bind (insts b2)
	     (arith-from-to (floor a 2) (mod a 2) to)
	   (values (format nil "M2W/~A" insts) b2)))
	((> to a)
	 (multiple-value-bind (insts1 b2)
	     (arith-from-to a b (+ a 9))
	   (multiple-value-bind (insts2 b3)
	       (arith-from-to (+ a 9) b2 to)
	     (values (concatenate 'string insts1 insts2) b3))))
	(t
	 (multiple-value-bind (insts1 b2)
	     (arith-from-to a b (- a 9))
	   (multiple-value-bind (insts2 b3)
	       (arith-from-to (- a 9) b2 to)
	     (values (concatenate 'string insts1 insts2) b3))))))	 



(defun encode (text)
  (let ((long
	 (with-output-to-string (s)
	   (format s "@`49`")
	   (let ((A 49)
		 (B nil))
	     (declare (type (integer 32 126) A)
		      (type (or null (signed-byte 64)) B))
	     (loop for c across text do
		   (let ((code (char-code c)))
		     (multiple-value-bind (insns B2)
			 (arith-from-to A B code)
		       (format s "~As" insns)
		       (setf A code B B2))))))))
    (format t "Input length: ~D, output length: ~D~%" (length text) (length long))
    long))

(defun format-square (code)
  (let ((width (+ (floor (sqrt (length code))) 3))
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
  (let* ((lines (format-square (encode *text*)))
	 (width (apply #'max (mapcar #'length lines)))
	 (height (length lines)))
    (format t "width: ~D, height: ~D~%" width height)
    (with-open-file (out "history.man" :direction :output :if-exists :rename)
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%")
      (loop for line in lines do
	    (format out "|~A|~%" line))
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%+-+ v~%|O|<<~%+-+~%"))))
	    
    
