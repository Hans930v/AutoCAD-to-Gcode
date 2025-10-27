; ===================================
; CNC_HELPER_COMMANDS_1.0.0.lsp
; Version 1.0.0
; G-code helper for AutoCAD
; Commands: IDC, G0P, G1P, G2R, G3R, G2P, G3P
; ===================================

;; copy2clip: write txt to temp file then pipe to Windows clipboard via clip.exe
(defun copy2clip (txt / tmpdir tmpfile fh shell cmd)
  (vl-load-com)
  (setq tmpdir (getenv "TEMP"))
  (if (not tmpdir)
    (setq tmpdir "C:\\Windows\\Temp")
  )
  (setq tmpfile (strcat tmpdir "\\ac_clip.txt"))
  (if (setq fh (open tmpfile "w"))
    (progn
      (write-line txt fh)
      (close fh)
      (setq shell (vlax-create-object "WScript.Shell"))
      (setq cmd (strcat "cmd /c type \"" tmpfile "\" | clip"))
      (vlax-invoke shell 'Run cmd 0 1)
      (vlax-release-object shell)
      T
    )
    (progn
      (princ "\nError: cannot open temp file for clipboard.")
      nil
    )
  )
)

;; ------------------------
;; IDC - copy single point X Y Z
;; ------------------------
(defun c:IDC (/ pt x y z str)
  (setq pt (getpoint "\nPick a point: "))
  (if pt
    (progn
      (setq x (rtos (car pt) 2 4))
      (setq y (rtos (cadr pt) 2 4))
      (setq z (rtos (caddr pt) 2 4))
      (setq str (strcat "X" x " Y" y " Z" z))
      (if (copy2clip str)
	(princ (strcat "\nCopied to clipboard: " str))
	(princ "\nFailed to copy to clipboard.")
      )
    )
    (princ "\nNo point picked.")
  )
  (princ)
)

;; ------------------------
;; G0P - single-pick rapid moves
;; ------------------------
(defun c:G0P (/ pt x y z str)
  (setq pt (getpoint "\nPick a point: "))
  (if pt
    (progn
      (setq x (rtos (car pt) 2 4))
      (setq y (rtos (cadr pt) 2 4))
      (setq z (rtos (caddr pt) 2 4))
      (setq str (strcat "G0 X" x " Y" y " Z" z))
      (if (copy2clip str)
	(princ (strcat "\nCopied to clipboard: " str))
	(princ "\nFailed to copy to clipboard.")
      )
    )
    (princ "\nNo point picked.")
  )
  (princ)
)

;; ------------------------
;; G1P - multi-pick feed moves
;; ------------------------
(defun c:G1P (/ pt x y feed str out)
  (setq out "")
  (setq feed (getreal "\nEnter feedrate <2000>: "))
  (if (not feed) (setq feed 2000))
  (princ
    "\nPick points for G1 (Enter to finish, Esc to cancel)."
  )
  (while (setq pt (getpoint "\nPick point: "))
    (setq x (rtos (car pt) 2 4))
    (setq y (rtos (cadr pt) 2 4))
    (setq str (strcat "G1 X" x " Y" y " F" (rtos feed 2 0)))
    (setq out (strcat out str "\n"))
    (princ (strcat "\nAdded: " str))
  )
  (if (> (strlen out) 0)
    (if	(copy2clip out)
      (princ "\nAll G1 copied to clipboard.")
      (princ "\nFailed to copy G1.")
    )
  )
  (princ)
)

;; ------------------------
;; G2R / G3R - arc with endpoint + radius
;; ------------------------
(defun c:G2R (/ pt x y feed r str)
  (setq pt (getpoint "\nPick Endpoint of arc: "))
  (if pt
    (progn
      (setq x (rtos (car pt) 2 4))
      (setq y (rtos (cadr pt) 2 4))
      (setq feed (getreal "\nEnter feedrate <2000>: "))
      (if (not feed) (setq feed 2000))
      (setq r (getreal "\nSet radius: "))
      (if (and r (> r 0))
	(progn
	  (setq	str (strcat "G2 X" x " Y" y " R" (rtos r 2 3) " F" (rtos feed 2 0))
	  )
	  (if (copy2clip str)
	    (princ (strcat "\nG2 (R) copied to clipboard: " str))
	    (princ "\nFailed to copy G2.")
	  )
	)
	(princ "\nInvalid radius.")
      )
    )
    (princ "\nNo point picked.")
  )
  (princ)
)

(defun c:G3R (/ pt x y feed r str)
  (setq pt (getpoint "\nPick Endpoint of arc: "))
  (if pt
    (progn
      (setq x (rtos (car pt) 2 4))
      (setq y (rtos (cadr pt) 2 4))
      (setq feed (getreal "\nEnter feedrate <2000>: "))
      (if (not feed) (setq feed 2000))
      (setq r (getreal "\nSet radius: "))
      (if (and r (> r 0))
	(progn
	  (setq	str (strcat "G3 X" x " Y" y " R" (rtos r 2 3) " F" (rtos feed 2 0))
	  )
	  (if (copy2clip str)
	    (princ (strcat "\nG3 (R) copied to clipboard: " str))
	    (princ "\nFailed to copy G3.")
	  )
	)
	(princ "\nInvalid radius.")
      )
    )
    (princ "\nNo point picked.")
  )
  (princ)
)

;; ------------------------
;; G2P / G3P - arc with endpoint + center (I,J)
;; ------------------------
(defun c:G2P (/ start end cen x y i j feed str)
  (setq start (getpoint "\nPick START point of arc: "))
  (if start
    (progn
      (setq end (getpoint "\nPick END point of arc: "))
      (setq cen (getpoint "\nPick CENTER point of arc: "))
      (if (and end cen)
	(progn
	  (setq x (rtos (car end) 2 4))
	  (setq y (rtos (cadr end) 2 4))
	  (setq i (rtos (- (car cen) (car start)) 2 4))
	  (setq j (rtos (- (cadr cen) (cadr start)) 2 4))
	  (setq feed (getreal "\nEnter feedrate <2000>: "))
	  (if (not feed) (setq feed 2000))
	  (setq	str (strcat "G2 X" x " Y" y " I" i " J" j " F" (rtos feed 2 0))
	  )
	  (if (copy2clip str)
	    (princ (strcat "\nG2 (I,J) copied to clipboard: " str))
	    (princ "\nFailed to copy G2.")
	  )
	)
	(princ "\nEnd or Center not picked.")
      )
    )
    (princ "\nNo start picked.")
  )
  (princ)
)

(defun c:G3P (/ start end cen x y i j feed str)
  (setq start (getpoint "\nPick START point of arc: "))
  (if start
    (progn
      (setq end (getpoint "\nPick END point of arc: "))
      (setq cen (getpoint "\nPick CENTER point of arc: "))
      (if (and end cen)
	(progn
	  (setq x (rtos (car end) 2 4))
	  (setq y (rtos (cadr end) 2 4))
	  (setq i (rtos (- (car cen) (car start)) 2 4))
	  (setq j (rtos (- (cadr cen) (cadr start)) 2 4))
	  (setq feed (getreal "\nEnter feedrate <2000>: "))
	  (if (not feed) (setq feed 2000))
	  (setq	str (strcat "G3 X" x " Y" y " I" i " J" j " F" (rtos feed 2 0))
	  )
	  (if (copy2clip str)
	    (princ (strcat "\nG3 (I,J) copied to clipboard: " str))
	    (princ "\nFailed to copy G3.")
	  )
	)
	(princ "\nEnd or Center not picked.")
      )
    )
    (princ "\nNo start picked.")
  )
  (princ)
)


(princ
  "\nCNC_HELPER_COMMANDS.lsp loaded. Commands: IDC, G0P, G1P, G2R, G3R, G2P, G3P"
)
(princ)
