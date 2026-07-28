(defun subset-sum (ns target)
  "Recursive subset sum."
  (labels ((try-tails (ns target)
	     (if (null ns)
		 'fail
		 (let ((res (subset-sum ns target)))
		   (if (symbolp res)
		       (try-tails (cdr ns) target)
		       res)))))
    (cond ((null ns) 'fail)
	  ((= (car ns) target) (list (car ns)))
	  ((> (car ns) target) 'fail)
	  (t (let ((res (try-tails (cdr ns) (- target (car ns)))))
	       (if (symbolp res)
		   (subset-sum (cdr ns) target)
		   (cons (car ns) res)))))))

(defun subset-sum-bits (ns target)
  "Subset sum generating permutations via the 1-bits of the
integers from 1 to 2^N-1."
  (let* ((ns (coerce ns 'vector))
	 (n (length ns))
	 (res-list nil)
	 (res (loop for bits from 1 below (ash 1 n) do
		    (let ((sum 0))
		      (when (loop for i from 0 below n
				  and mask = 1 then (ash mask 1) do
				  (when (plusp (logand bits mask))
				    (incf sum (svref ns i))
				    (when (> sum target) (return nil))
				    (when (= sum target) (return t))))
			(return bits))))))
    (if (not res)
	'fail
	(let ((sum 0))
	  (loop for i from 0 below n
		and mask = 1 then (ash mask 1) do
		(when (plusp (logand res mask))
		  ;; (format t "~D " (svref ns i))
		  (push (svref ns i) res-list)
		  (incf sum (svref ns i))
		  (when (= sum target)
		    (return (nreverse res-list)))))))))

;; Memory use:
;;  mem[0]: n
;;  mem[1]: target
;;  mem[2]: bits
;;  mem[3]: sum
;;  mem[4]: i
;;  mem[5]: mask
;;  mem[6..25]: numbers





(defun fib (n)
  "Recursive fibonacci function."
  (declare (type unsigned-byte n))
  (if (< n 2)
      n
      (+ (fib (- n 1))
	 (fib (- n 2)))))

(defun fib-stack (n)
  "Fibonacci function with recursion via data stack."
  (let ((stack nil))
    (push n stack)
    (push :arg stack)
    (loop
	  (ecase (pop stack)
	    (:arg
	     (let ((val (pop stack)))
	       (if (< val 2)
		   (progn (push val stack)
			  (push :result stack))
		   (progn (push (- val 1) stack)
			  (push :arg stack)
			  (push (- val 2) stack)
			  (push :arg stack)))))
	    (:result
	     (let ((val (pop stack)))
	       (when (null stack)
		 (return val))
	       (if (eq :arg (pop stack))
		   (let ((prev-arg (pop stack)))
		     (push val stack)
		     (push :result stack)
		     (push prev-arg stack)
		     (push :arg stack))
		   (let ((prev-arg (pop stack)))
		     (push (+ val prev-arg) stack)
		     (push :result stack)))))))))


  
(defparameter *public* ;; list of (input output) lists
  '(((35598 41872 81980 98583 65116 96540 10035 60706 14417 64505 248550)
     (35598 41872 96540 10035 64505))
    ((120 180 200 150 100 90 80 70 300 60 300)
     (120 180))
    ((59 89720 63262 24662 73570 35930 83954 41901 92098 37536 35156 701 33952 7954)
     (0))
    ((62554 40915 24211 27558 54959 22322 76841 33232 83608 97109 62554)
     (62554))
    ((1864 1519 695 1825 290 253 1919 302 1542 1283 1486 16687 16687)
     (16687))
    ((500 500 500 300 300 700 900 500 300 700 1000)
     (500 500))
    ((58443 79693 37155 15450 57084 20590 29841 13454 91581 60485 36863 169 33749 20147 72090 52216 92490 97963 96043 90230 633441)
     (58443 79693 15450 57084 20590 13454 91581 36863 72090 97963 90230))))

(defun solve (test)
  (let* ((input (first test))
	 (output (second test))
	 (ns (butlast input))
	 (target (car (last input)))
	 (result1 (subset-sum ns target))
	 (result (if (symbolp result1) '(0) result1)))
    (if (equal result output)
	'ok
	(format nil "failed: ~S.~%expected ~S~%but got  ~S" input output result))))

(defun solve2 (test)
  (let* ((input (first test))
	 (output (second test))
	 (ns (butlast input))
	 (target (car (last input)))
	 (result1 (subset-sum-bits ns target))
	 (result (if (symbolp result1) '(0) result1)))
    (if (equal result output)
	'ok
	(format nil "failed: ~S.~%expected ~S~%but got  ~S" input output result))))
