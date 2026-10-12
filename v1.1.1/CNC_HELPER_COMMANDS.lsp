; ===================================
; CNC_HELPER_COMMANDS_1.1.1.lsp
; Version 1.1.1
; G-code helper for AutoCAD
; Commands: IDC, G0P, G1P, G2R, G3R, G2P, G3P
; ===================================

;; ------------------------
;; copy2clip: Write txt to clipboard via Windows shell
;; ------------------------
(defun copy2clip (txt / tmpdir tmpfile fh shell cmd)
  (vl-load-com)
  (setq tmpdir (getenv "TEMP"))
  (if (not tmpdir) (setq tmpdir "C:\\Windows\\Temp"))
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
      (setq x (rtos (car pt) 2 4)
            y (rtos (cadr pt) 2 4)
            z (rtos (caddr pt) 2 4)
            str (strcat "X" x " Y" y " Z" z))
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
;; G0P - rapid move
;; ------------------------
(defun c:G0P (/ pt x y z str)
  (setq pt (getpoint "\nPick a point: "))
  (if pt
    (progn
      (setq x (rtos (car pt) 2 4)
            y (rtos (cadr pt) 2 4)
            z (rtos (caddr pt) 2 4)
            str (strcat "G0 X" x " Y" y " Z" z))
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
;; G1P - multiple feed moves
;; ------------------------
(defun c:G1P (/ pt x y feed str out)
  (setq out "")
  (setq feed (getreal "\nEnter feedrate <2000>: "))
  (if (not feed) (setq feed 2000))
  (princ "\nPick points for G1 (Enter to finish, Esc to cancel).")
  (while (setq pt (getpoint "\nPick point: "))
    (setq x (rtos (car pt) 2 4)
          y (rtos (cadr pt) 2 4)
          str (strcat "G1 X" x " Y" y " F" (rtos feed 2 0))
          out (strcat out str "\n"))
    (princ (strcat "\nAdded: " str))
  )
  (if (> (strlen out) 0)
    (if (copy2clip out)
      (princ "\nAll G1 copied to clipboard.")
      (princ "\nFailed to copy G1.")
    )
  )
  (princ)
)

;; ------------------------
;; G2R / G3R - Arc with endpoint + radius
;; ------------------------
(defun c:G2R (/ pt x y feed r str)
  (setq pt (getpoint "\nPick Endpoint of arc: "))
  (if pt
    (progn
      (setq x (rtos (car pt) 2 4)
            y (rtos (cadr pt) 2 4)
            feed (getreal "\nEnter feedrate <2000>: "))
      (if (not feed) (setq feed 2000))
      (setq r (getreal "\nSet radius: "))
      (if (and r (> r 0))
        (progn
          (setq str (strcat "G2 X" x " Y" y " R" (rtos r 2 3) " F" (rtos feed 2 0)))
          (if (copy2clip str)
            (princ (strcat "\nG2 (R) copied: " str))
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
      (setq x (rtos (car pt) 2 4)
            y (rtos (cadr pt) 2 4)
            feed (getreal "\nEnter feedrate <2000>: "))
      (if (not feed) (setq feed 2000))
      (setq r (getreal "\nSet radius: "))
      (if (and r (> r 0))
        (progn
          (setq str (strcat "G3 X" x " Y" y " R" (rtos r 2 3) " F" (rtos feed 2 0)))
          (if (copy2clip str)
            (princ (strcat "\nG3 (R) copied: " str))
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
;; G2P / G3P - Arc with endpoint + center (I,J,K)
;; ------------------------
(setq *last-plane* "G17") ; <== NEW: remembers last selected plane

(defun get-plane-code (/ ans clean)
  (initget "G17 G18 G19 XY XZ YZ G17(XY) G18(XZ) G19(YZ)")
  (setq ans (getkword
    (strcat "\nSelect working plane [G17(XY)/G18(XZ)/G19(YZ)] <" *last-plane* ">: ")))
  (cond
    ((not ans) (setq clean *last-plane*)) ; use last remembered
    ((wcmatch ans "*G17*") (setq clean "G17"))
    ((wcmatch ans "*G18*") (setq clean "G18"))
    ((wcmatch ans "*G19*") (setq clean "G19"))
    ((wcmatch ans "*XY*")  (setq clean "G17"))
    ((wcmatch ans "*XZ*")  (setq clean "G18"))
    ((wcmatch ans "*YZ*")  (setq clean "G19"))
    (T (setq clean *last-plane*))
  )
  (setq *last-plane* clean) ; save for next session
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
            ((= plane "G17")
              (setq x (rtos (car end) 2 4)
                    y (rtos (cadr end) 2 4)
                    i (rtos (- (car cen) (car start)) 2 4)
                    j (rtos (- (cadr cen) (cadr start)) 2 4)
                    str (strcat plane " " cw " X" x " Y" y " I" i " J" j " F" (rtos feed 2 0))))
            ((= plane "G18")
              (setq x (rtos (car end) 2 4)
                    z (rtos (caddr end) 2 4)
                    i (rtos (- (car cen) (car start)) 2 4)
                    k (rtos (- (caddr cen) (caddr start)) 2 4)
                    str (strcat plane " " cw " X" x " Z" z " I" i " K" k " F" (rtos feed 2 0))))
            ((= plane "G19")
              (setq y (rtos (cadr end) 2 4)
                    z (rtos (caddr end) 2 4)
                    j (rtos (- (cadr cen) (cadr start)) 2 4)
                    k (rtos (- (caddr cen) (caddr start)) 2 4)
                    str (strcat plane " " cw " Y" y " Z" z " J" j " K" k " F" (rtos feed 2 0))))
          )
          (if (copy2clip str)
            (princ (strcat "\n" cw " (" plane ") copied: " str))
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

;; ------------------------
;; Info banner
;; ------------------------
(defun show-cnc-helper-info ()
  (textscr)
  (princ "\n===================================================")
  (princ "\n   CNC HELPER COMMANDS v1.1.1 Successfully Loaded   ")
  (princ "\n===================================================")
  (princ "\n  Commands: IDC, G0P, G1P, G2R, G3R, G2P, G3P")
  (princ "\nCreated by: VILLAFRANCA | github.com/Hans930v")
  (princ "\n   License: MIT")
  (princ "\n===================================================")
  (princ)
  (graphscr)
)
(show-cnc-helper-info)
