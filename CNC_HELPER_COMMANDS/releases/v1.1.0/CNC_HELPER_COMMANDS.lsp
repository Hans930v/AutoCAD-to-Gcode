; ===================================
; CNC_HELPER_COMMANDS_1.1.0.lsp
; Version 1.1.0
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
;; IDC - copy single point X Y
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
;; G0P - multi-pick rapid moves
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
;; G2P / G3P - arc with endpoint + center (I,J,K)
;; Supports G17/G18/G19 with default G17 (XY)
;; ------------------------

(defun get-plane-code (/ ans clean)
  (initget "G17 G18 G19 XY XZ YZ G17(XY) G18(XZ) G19(YZ)")
  (setq ans (getkword "\nSelect working plane [G17(XY)/G18(XZ)/G19(YZ)] <G17>: "))
  
  ;; Handle user input (typed or clicked)
  (cond
    ((not ans) (setq clean "G17")) ; default
    ((wcmatch ans "*G17*") (setq clean "G17"))
    ((wcmatch ans "*G18*") (setq clean "G18"))
    ((wcmatch ans "*G19*") (setq clean "G19"))
    ((wcmatch ans "*XY*")  (setq clean "G17"))
    ((wcmatch ans "*XZ*")  (setq clean "G18"))
    ((wcmatch ans "*YZ*")  (setq clean "G19"))
    (T (setq clean "G17"))
  )
  clean
)

(defun make-g2g3 (cw / start end cen feed plane x y z i j k str)
  (setq plane (get-plane-code))
  (setq start (getpoint "\nPick START point of arc: "))
  (if start
    (progn
      (setq end (getpoint "\nPick END point of arc: "))
      (setq cen (getpoint "\nPick CENTER point of arc: "))
      (if (and end cen)
        (progn
          (setq feed (getreal "\nEnter feedrate <2000>: "))
          (if (not feed) (setq feed 2000))
          
          (cond
            ;; --- G17 XY plane ---
            ((= plane "G17")
              (setq x (rtos (car end) 2 4))
              (setq y (rtos (cadr end) 2 4))
              (setq i (rtos (- (car cen) (car start)) 2 4))
              (setq j (rtos (- (cadr cen) (cadr start)) 2 4))
              (setq str (strcat plane " " cw " X" x " Y" y " I" i " J" j " F" (rtos feed 2 0)))
            )
            ;; --- G18 XZ plane ---
            ((= plane "G18")
              (setq x (rtos (car end) 2 4))
              (setq z (rtos (caddr end) 2 4))
              (setq i (rtos (- (car cen) (car start)) 2 4))
              (setq k (rtos (- (caddr cen) (caddr start)) 2 4))
              (setq str (strcat plane " " cw " X" x " Z" z " I" i " K" k " F" (rtos feed 2 0)))
            )
            ;; --- G19 YZ plane ---
            ((= plane "G19")
              (setq y (rtos (cadr end) 2 4))
              (setq z (rtos (caddr end) 2 4))
              (setq j (rtos (- (cadr cen) (cadr start)) 2 4))
              (setq k (rtos (- (caddr cen) (caddr start)) 2 4))
              (setq str (strcat plane " " cw " Y" y " Z" z " J" j " K" k " F" (rtos feed 2 0)))
            )
          )
          
          (if (copy2clip str)
            (princ (strcat "\n" cw " (" plane ") copied to clipboard: " str))
            (princ "\nFailed to copy G-code.")
          )
        )
        (princ "\nEnd or Center not picked.")
      )
    )
    (princ "\nNo start picked.")
  )
  (princ)
)

(defun c:G2P () (make-g2g3 "G2"))
(defun c:G3P () (make-g2g3 "G3"))


(defun show-cnc-helper-info ()
  (textscr)
  (princ "\n===================================================")
  (princ "\n   CNC HELPER COMMANDS v1.1.0 Succesfully Loaded   ")
  (princ "\n===================================================")
  (princ "\nCommands loaded: IDC, G0P, G1P, G2R, G3R, G2P, G3P ")
  (princ "\n   Created by: VILLAFRANCA | github.com/Hans930v   ")
  (princ "\n                    License: MIT                   ")
  (princ "\n===================================================")
  (princ)
  (graphscr)
)
(show-cnc-helper-info)
