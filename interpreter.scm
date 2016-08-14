(require-extension stack)

;;; BULLY is stack-oriented language.
;;; There are no variables, make a new stack and read from it instead.

;;; LUPS and the like

(define STACK-LUP '()) ; BULLY stack look up alist
(define DELAYED '()) ; alist of delayed values
(define COMMAND-LUP '()) ; BULLY command look up alist

(define *current-in-stack* "i")

(define COMMAND-add
  (lambda (key instr)
    (set! COMMAND-LUP (cons (cons key instr) COMMAND-LUP))))

(define STACK-add ; add a single item to STACK-LUP
  (lambda (key)
    (set! STACK-LUP (cons (cons key (make-stack)) STACK-LUP))))

(define STACK-many-add ; add multiple items to STACK-LUP
  (lambda (keys)
    (if (null? keys)
	1
	(begin
	  (STACK-add (car keys))
	  (STACK-many-add (cdr keys))))))

;;; Default stacks

(STACK-many-add '("i" "o" "d")) ; input, output, default (working) stacks

;;; Scaffolding

(define STACK-push ; push a new object to stack
  (lambda (obj stck)
    (let ((stack (alist-ref stck STACK-LUP equal?)))
      (stack-push! stack obj))))
      
(define STACK-pop ; remove top object from stack
  (lambda (stck)
    (let ((stack (alist-ref stck STACK-LUP equal?)))
      (stack-pop! stack))))

(define STACK-copy ; copy object at index from stack
  (lambda (stck index)
    (let ((stack (alist-ref stck STACK-LUP equal?)))
      (stack-peek stack index))))

(define STACK-count ; count objects in stack
  (lambda (stck)
    (stack-count (alist-ref stck STACK-LUP equal?))))

(define O-STACK-display ; display "o" stack to user
  (lambda ()
    (if (stack-empty? (alist-ref "o" STACK-LUP equal?))
	1
	(begin
	  (display (STACK-pop "o"))
	  (newline)
	  (O-STACK-display)))))

(define copy-from-stack ; copy all elements from stack
  (lambda (stck)
    (stack->list (alist-ref stck STACK-LUP equal?))))

(define copy-from-stack! ; copy all elements from stack and empty it
  (lambda (stck)
    (let ((out (copy-from-stack stck)))
      (empty-stack stck)
      out)))

(define write-to-stack ; push multiple values to stack
  (lambda (stck values)
    (if (null? values)
	1
	(begin
	  (if (list? values)
	      1
	      (set! values (list values)))
	  (STACK-push (car values) stck)
	  (write-to-stack stck (cdr values))))))

(define empty-stack ; empty stack
  (lambda (stck)
    (stack-empty! (alist-ref stck STACK-LUP equal?))))

(define construct-numeric-command ; construct ADD, MUL, DIV, SUB.
  (lambda (key op)
    (COMMAND-add key
		 (lambda (in-stack)
		   (let* ((out-stack (STACK-pop in-stack))
			 (lst (copy-from-stack in-stack)))
		     (empty-stack in-stack)
		     (STACK-push (apply op lst) out-stack))))))

(construct-numeric-command "ADD" +)
(construct-numeric-command "SUB" -)
(construct-numeric-command "MUL" *)
(construct-numeric-command "DIV" /)

(define exec
  (lambda (in-stack)
    (let ((op (alist-ref (STACK-pop in-stack) COMMAND-LUP equal?)))
      (op in-stack))))

(COMMAND-add "." exec)

(define prompt
  (lambda ()
    (display "BULLY:> ")))

(define read-word
  (lambda (lst)
    (let ((chr (read-char)))
      (if (equal? chr #\:)
	  (list->string lst)
	  (read-word (cons chr lst))))))

(define end-stack-name?
  (lambda (chr)
    (if (equal? #\: chr)
	#f
	#t)))

(define read-in-stack
  (lambda ()
    (let ((stack-name (read-token end-stack-name?)))
      (read-char)
      stack-name)))

(define clean
  (lambda (str)
    (let ((num (string->number str)))
      (if (number? num)
	  num
	  str))))

(define CURRENT-push
  (lambda (obj)
    (STACK-push obj *current-in-stack*)))

(define pop-all
  (lambda (in-stack out-stack)
    (if (stack-empty? (alist-ref in-stack STACK-LUP equal?))
	1
	(begin
	  (STACK-push (STACK-pop in-stack) out-stack)
	  (pop-all in-stack out-stack)))))

(COMMAND-add "POP"
	     (lambda (in-stack)
	       (let ((out-stack (STACK-pop in-stack)))
		 (pop-all in-stack out-stack))))

(define stack-push-values
  (lambda (values out-stack)
    (cond ((null? values) 1)
	  ((not (list? values)) (STACK-push values out-stack))
	  (#t (begin
		(STACK-push (car values) out-stack)
		(stack-push-values (cdr values) out-stack))))))

(COMMAND-add "PUSH"
	     (lambda (in-stack)
	       (let ((out-stack (STACK-pop in-stack)))
		 (stack-push-values (copy-from-stack in-stack) out-stack))))

(COMMAND-add "@" ; STACK command
	     (lambda (in-stack)
	       (let ((stack-names (copy-from-stack in-stack)))
		 (STACK-many-add stack-names))
	       (empty-stack in-stack)))

(COMMAND-add "DUP" ; DUPLICATE
	     (lambda (in-stack)
	       (let ((out-stack (STACK-pop in-stack))
		     (obj       (STACK-pop in-stack)))
		 (STACK-push obj out-stack)
		 (STACK-push obj out-stack))))

(COMMAND-add "SWAP"
	     (lambda (in-stack)
	       (let ((out-stack (STACK-pop in-stack))
		     (top       (STACK-pop in-stack))
		     (bottom    (STACK-pop in-stack)))
		 (STACK-push top    out-stack)
		 (STACK-push bottom out-stack))))

(COMMAND-add "COMP" ; compare
	     (lambda (in-stack)
	       (let ((out-stack (STACK-pop in-stack))
		     (top       (STACK-pop in-stack))
		     (bottom    (STACK-pop in-stack)))
		 (if (equal? top bottom)
		     (STACK-push 1  out-stack)
		     (STACK-push 0  out-stack)))))

(COMMAND-add "IF"
	     (lambda (in-stack)
	       (let ((out-stack   (STACK-pop in-stack))
		     (condition   (STACK-pop in-stack))
		     (then-branch (STACK-pop in-stack))
		     (else-branch (STACK-pop in-stack)))
		 (if (equal? condition 0)
		     (STACK-push else-branch out-stack)
		     (STACK-push then-branch out-stack)))))

(define DELAY-add-many
  (lambda (input)
    (if (null? input)
	1
	(begin
	  (let ((key (car input))
		(obj (cadr input)))
	    (set! DELAYED (cons (cons key obj) DELAYED)))
	  (DELAY-add-many (cddr input))))))

(COMMAND-add "DELAY"
	     (lambda (in-stack)
	       (DELAY-add-many (copy-from-stack in-stack))
	       (empty-stack in-stack)))

(define force-all
  (lambda ()
    (cond ((null? DELAYED) 1)
	  ((and (pair? DELAYED) (not (list? DELAYED)))
	   (begin
	     (STACK-push (cdr DELAYED) (car DELAYED))
	     (set! DELAYED '())))
	  ((not (null? DELAYED))
	   (begin
	     (STACK-push (cdar DELAYED) (caar DELAYED))
	     (set! DELAYED (cdr DELAYED))
	     (force-all))))))

(COMMAND-add "FORCE"
	     (lambda (in-stack)
	       (force-all)))

(define read-to-in-stack
  (lambda (line)
    (map CURRENT-push (map clean (string-split line)))))

(define linefy
  (lambda (line)
    (string-split line ".")))

(define evaluate
  (lambda (lines)
    (cond ((null? lines) 1)
	 ; ((or (equal? "" lines) (equal? " " lines))
	  ;   (exec *current-in-stack*))
	  (#t
	   (begin
	     (read-to-in-stack (car lines))
	     (exec *current-in-stack*)
	     (evaluate (cdr lines)))))))
   
(define repl
  (lambda ()
    (begin
      (prompt)
      (set! *current-in-stack* (read-in-stack))
      (evaluate (linefy (read-line)))
      (O-STACK-display)
      (repl))))

(repl)
