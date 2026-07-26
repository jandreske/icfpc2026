;; Script to create "History lesson" solution from icfp-history.txt.
;; The generated solution needs to formatting by hand to create a
;; proper box-shaped box befor submitting.


(defvar *text* (uiop:read-file-string "icfp-history.txt"))

(defun arith-from-to (a b)
  (cond ((= a b) "")
	((<= (+ a 1) b (+ a 9)) (format nil "M~D+" (- b a)))
	((<= (- a 9) b (- a 1)) (format nil "M~DN+" (- a b)))
	((>= b (- (* 2 a) 9))
	 (format nil "M+~A" (arith-from-to (* 2 a) b)))
	((<= b (+ (floor a 2) 9))
	 (format nil "M2W/~A" (arith-from-to (floor a 2) b)))
	((> b a) (concatenate 'string (arith-from-to a (+ a 9)) (arith-from-to (+ a 9) b)))
	(t (concatenate 'string (arith-from-to a (- a 9)) (arith-from-to (- a 9) b)))))



(defun encode (text)
  (let ((long
	 (with-output-to-string (s)
	   (format s "@`49`")
	   (let ((prev 49))
	     (loop for c across text do
		   (let ((code (char-code c)))
		     (format s "~As" (arith-from-to prev code))
		     (setf prev code)))))))
    (format t "Input length: ~D, output length: ~D~%" (length text) (length long))
    long))

(defun format-square (code)
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
  (let* ((lines (format-square (encode *text*)))
	 (width (apply #'max (mapcar #'length lines)))
	 (height (length lines)))
    (format t "width: ~D, height: ~D~%" width height)
    (with-open-file (out "history2.man" :direction :output)
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%")
      (loop for line in lines do
	    (format out "|~A|~%" line))
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%+-+ v~%|O|<<~%+-+~%"))))
	    
    
