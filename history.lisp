;; Script to create "History lesson" solution from icfp-history.txt.
;; The generated solution needs some formatting by hand to create a
;; proper box-shaped box before submitting.

;; Solution approach:
;; We just output the characters sequentially.
;; To generate shorter code, we keep track of the contents of
;; both hands, and try to generate minimal code sequences to compute
;; the next character value from either A or B.


(defvar *text*
  "1996: Philadelphia, PA, USA \"Optimality and inefficiency: What isn't a cost model of the lambda calculus?\" (Julia Lawall and Harry Mairson); 1997: Amsterdam, Netherlands \"Functional reactive animation\" (Conal Elliott and Paul Hudak); 1998: Baltimore, MD, USA \"Cayenne - a language with dependent types\" (Lennart Augustsson); 1999: Paris, France \"Haskell and XML: Generic combinators or type-based translation?\" (Malcolm Wallace and Colin Runciman); 2000: Montreal, Canada \"QuickCheck: a lightweight tool for random testing of Haskell programs\" (Koen Claessen and John Hughes); 2001: Florence, Italy \"Recursive Structures for Standard ML\" (Claudio Russo); 2002: Pittsburgh, PA, USA \"Contracts for higher-order functions\" (Robert Findler and Matthias Felleisen); 2003: Uppsala, Sweden \"MLF: Raising ML to the Power of System F\" (Didier Le Botlan and Didier Remy); 2004: Snowbird, UT, USA \"Scrap More Boilerplate: Reflection, Zips, and Generalised Casts\" (Ralf Lammel and Simon Peyton Jones); 2005: Tallinn, Estonia \"Associated Type Synonyms\" (Manuel M. T. Chakravarty, Gabriele Keller, and Simon Peyton Jones); 2006: Portland, OR, USA \"Simple unification-based type inference for GADTs\" (Simon Peyton Jones, Dimitrios Vytiniotis, Stephanie Weirich, and Geoffrey Washburn); 2007: Freiburg, Germany \"Ott: Effective Tool Support for the Working Semanticist\" (Peter Sewell, Francesco Zappa Nardelli, Scott Owens, Gilles Peskine, Thomas Ridge, Susmit Sarkar, and Rok Strnisa); 2008: Victoria, BC, Canada \"Parametric higher-order abstract syntax for mechanized semantics\" (Adam Chlipala); 2009: Edinburgh, UK \"Runtime Support for Multicore Haskell\" (Simon Marlow, Simon Peyton Jones, and Satnam Singh); 2010: Baltimore, MD, USA \"Abstracting abstract machines\" (David Van Horn and Matthew Might); 2011: Tokyo, Japan \"Frenetic: a network programming language\" (Nate Foster, Rob Harrison, Michael Freedman, Christopher Monsanto, Jennifer Rexford, Alex Story, and David Walker); 2012: Copenhagen, Denmark \"Addressing covert termination and timing channels in concurrent information flow systems\" (Deian Stefan, Alejandro Russo, Pablo Buiras, Amit Levy, John C. Mitchell and David Mazieres); 2013: Boston, MA, USA \"Handlers in Action\" (Ohad Kammar, Sam Lindley, and Nicolas Oury); 2014: Gothenburg, Sweden \"Refinement Types for Haskell\" (Niki Vazou, Eric L. Seidel, Ranjit Jhala, Dimitrios Vytiniotis, and Simon Peyton-Jones); 2015: Vancouver, BC, Canada \"1ML - core and modules united (F-ing first-class modules)\" (Andreas Rossberg); 2016: Nara, Japan; 2017: Oxford, UK; 2018: St. Louis, MO, USA; 2019: Berlin, Germany; 2020: Jersey City, NJ, USA (virtual); 2021: Daejeon, South Korea (virtual); 2022: Ljubljana, Slovenia; 2023: Seattle, WA, USA; 2024: Milan, Italy; 2025: Singapore, Singapore; 2026: Indianapolis, IN, USA")

(defun charfreq (s)
  (let ((table (make-hash-table :test #'eql))
	(list nil))
    (loop for c across s do
	  (incf (gethash c table 0)))
    (maphash #'(lambda (k v) (push (cons k v) list)) table)
    (coerce (mapcar #'car (sort list #'(lambda (a b) (> a b)) :key #'cdr))
	    'string)))
    
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
	((and (> b 0) (= to (floor a b)))
	 (values "/" (mod a b)))
	((= to (logand a b))
	 (values "&" b))
	((= to (logior a b))
	 (values "|" b))
	((= to (logxor a b))
	 (values "~" b))
	((and (> b 0) (= to (ash a b)))
	 (values "{" b))
	((and (> b 0) (= to (ash a (- b))))
	 (values "}" b))
	((= to (- b a))
	 (values "W-" a))
	((and (> a 0) (= to (floor b a)))
	 (values "W/" (mod b a)))
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

(defun make-int (n)
  "Generate code to put N into the main hand.
Assumes that the off-hand contains 1.
Returns a string with the code sequence."
  (declare (type unsigned-byte n))
  (let ((code nil))
    (when (= n 0)
      (return-from make-int "0"))
    (loop while (> n 1) do
	  (if (= (mod n 2) 1)
	      (progn (push #\+ code)
		     (decf n))
	      (progn (push #\{ code)
		     (setf n (ash n -1)))))
    (coerce code 'string)))



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
		      (type (integer 0 128) B))
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
  (let ((width 120) ; (+ (floor (sqrt (length code))) 13))
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

(defvar *codes* (charfreq *text*))

(defun text-to-codes (text)
  (loop for c across text
	collect (position c *codes*)))

(defun encode2 (text)
  "Encode text to Littleman code.
Keep track of the contents of both hands, and try to generate
minimal code sequences to put the next character value in A
and send it to output."
  (let ((long
	 (with-output-to-string (s)
	   (format s "@5M1{+")
	   (let ((A 33)
		 (B 1))
	     (declare (type (integer 0 70) A)
		      (type (integer 0 126) B))
	     (loop for c across text do
		   (let ((code (position c *codes*)))
		     (multiple-value-bind (insns B2)
			 (arith-from-to A B code)
		       (format s "~As" insns)
		       (setf A code B B2))))))))
    (format t "Input length: ~D, output length: ~D~%" (length text) (length long))
    long))

(defun doit2 ()
  "Generate code emitter and write it to file history-code.man"
  (let* ((lines (format-square (encode2 *text*)))
	 (width (apply #'max (mapcar #'length lines)))
	 (height (length lines)))
    (format t "width: ~D, height: ~D~%" width height)
    (format t "width: ~D, height: ~D with boxes and output~%" (+ width 2) (+ height 5))
    (with-open-file (out "history-codes.man" :direction :output :if-exists :rename)
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%")
      (loop for line in lines do
	    (format out "|~A|~%" line))
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%+-+ v~%|O|<<~%+-+~%"))))

(defun doit3 ()
  "Generate code emitter and write it to file history-chars.man"
  (let* ((lines (format-square (encode *codes*)))
	 (width (apply #'max (mapcar #'length lines)))
	 (height (length lines)))
    (format t "width: ~D, height: ~D~%" width height)
    (format t "width: ~D, height: ~D with boxes and output~%" (+ width 2) (+ height 5))
    (with-open-file (out "history-chars.man" :direction :output :if-exists :rename)
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%")
      (loop for line in lines do
	    (format out "|~A|~%" line))
      (format out "+")
      (loop for i from 1 to width do (format out "-"))
      (format out "+~%+-+ v~%|O|<<~%+-+~%"))))
