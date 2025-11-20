; ===================================
; CNC_HELPER_COMMANDS_1.3.3.lsp
; Version 1.3.3 (fixed worker/launcher separation)
; Author: Hansoy
; GitHub: github.com/Hans930v
; License: MIT
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

;; ------------------------------
;; Globals: remember last choices
;; ------------------------------
(setq *last-gcode* "G0P")   ; last chosen G-code command (as key shown in prompts)
(setq *last-feed* "2000")   ; remember feed (string)
(setq *last-plane* "G17")   ; remember working plane for G2P/G3P

;; ------------------------------------------------------------
;; Helper: parse user input for plane (robust for clicks/typed)
;; ------------------------------------------------------------
(defun parse-plane-input (ans / clean)
  (cond
    ((not ans) (setq clean *last-plane*))
    ((wcmatch ans "*G17*") (setq clean "G17"))
    ((wcmatch ans "*G18*") (setq clean "G18"))
    ((wcmatch ans "*G19*") (setq clean "G19"))
    ((wcmatch ans "*XY*")  (setq clean "G17"))
    ((wcmatch ans "*XZ*")  (setq clean "G18"))
    ((wcmatch ans "*YZ*")  (setq clean "G19"))
    (T (setq clean *last-plane*))
  )
  (setq *last-plane* clean)
  clean
)

(defun get-plane-code (/ ans)
  (initget "G17 G18 G19 XY XZ YZ G17(XY) G18(XZ) G19(YZ)")
  (setq ans (getkword (strcat "\nSelect working plane [G17(XY)/G18(XZ)/G19(YZ)] <" *last-plane* ">: ")))
  (parse-plane-input ans)
)

;; -----------------------------
;; Worker functions (return strings only)
;; -----------------------------

;; IDC - return a coordinate string
(defun run-IDC	 (/ pt x y z)
  (setq pt (getpoint "\nPick a point: "))
  (if pt
    (progn
      (setq x (rtos (car pt) 2 4))
      (setq y (rtos (cadr pt) 2 4))
      (setq z (rtos (caddr pt) 2 4))
      (strcat "X" x " Y" y " Z" z)
    )
    nil
  )
)

;; G0P worker
(defun run-G0P (/ pt x y z)
  (setq pt (getpoint "\nPick a point for G0: "))
  (if pt
    (strcat "G0 X" (rtos (car pt) 2 4)
            " Y" (rtos (cadr pt) 2 4)
            " Z" (rtos (caddr pt) 2 4))
    nil)
)

;; G1P worker: returns multiline string with G1 moves, each line terminated by newline
(defun run-G1P (/ feed pt x y z out)
  (setq out "")
  (setq feed (getreal (strcat "\nEnter feedrate <" *last-feed* ">: ")))
  (if (not feed) (setq feed (atof *last-feed*)))
  (setq *last-feed* (rtos feed 2 0))
  (princ "\nPick points for G1 (Enter to finish, Esc to cancel).")
  (while (setq pt (getpoint "\nPick point: "))
    (setq x (rtos (car pt) 2 4)
          y (rtos (cadr pt) 2 4)
	  z (rtos (caddr pt) 2 4))
    (setq out (strcat out "G1 X" x " Y" y " X" Z " F" (rtos feed 2 0) "\n"))
  )
  (if (> (strlen out) 0) out nil)
)

;; G2P/G3P worker: returns a single line
(defun run-G2G3P (cw / start end cen feed plane x y z i j k line)
  (setq plane (get-plane-code))
  (setq start (getpoint "\nPick START point of arc: "))
  (if (not start) (progn (princ "\nNo start picked.") nil)
    (progn
      (setq end (getpoint "\nPick END point of arc: "))
      (setq cen (getpoint "\nPick CENTER point of arc: "))
      (if (and end cen)
        (progn
          (setq feed (getreal (strcat "\nEnter feedrate <" *last-feed* ">: ")))
          (if (not feed) (setq feed (atof *last-feed*)))
          (setq *last-feed* (rtos feed 2 0))
          (cond
            ((= plane "G17")
              (setq x (rtos (car end) 2 4))
              (setq y (rtos (cadr end) 2 4))
              (setq i (rtos (- (car cen) (car start)) 2 4))
              (setq j (rtos (- (cadr cen) (cadr start)) 2 4))
              (setq line (strcat plane " " cw " X" x " Y" y " I" i " J" j " F" (rtos feed 2 0)))
            )
            ((= plane "G18")
              (setq x (rtos (car end) 2 4))
              (setq z (rtos (caddr end) 2 4))
              (setq i (rtos (- (car cen) (car start)) 2 4))
              (setq k (rtos (- (caddr cen) (caddr start)) 2 4))
              (setq line (strcat plane " " cw " X" x " Z" z " I" i " K" k " F" (rtos feed 2 0)))
            )
            ((= plane "G19")
              (setq y (rtos (cadr end) 2 4))
              (setq z (rtos (caddr end) 2 4))
              (setq j (rtos (- (cadr cen) (cadr start)) 2 4))
              (setq k (rtos (- (caddr cen) (caddr start)) 2 4))
              (setq line (strcat plane " " cw " Y" y " Z" z " J" j " K" k " F" (rtos feed 2 0)))
            )
            (T (setq line nil))
          )
          line
        )
        (progn (princ "\nEnd or Center not picked.") nil)
      )
    )
  )
)

;;; ------------------------------------------------------------
;;; Single-command usage - call worker, copy result to clipboard
;;; ------------------------------------------------------------
(defun c:IDC ()
  (vl-load-com)
  (setq line (run-IDC))
  (if line
    (progn (copy2clip line) (princ (strcat "\nIDC copied: " line)))
    (princ "\nIDC cancelled.")
  )
  (princ)
)

(defun c:G0P ()
  (vl-load-com)
  (setq line (run-G0P))
  (if line
    (progn (copy2clip line) (princ (strcat "\nG0 copied: " line)))
    (princ "\nG0 cancelled.")
  )
  (princ)
)

(defun c:G1P ()
  (vl-load-com)
  (setq lines (run-G1P))
  (if lines
    (progn (copy2clip lines) (princ "\nG1 block copied."))
    (princ "\nG1 cancelled.")
  )
  (princ)
)

(defun c:G2P ()
  (vl-load-com)
  (setq line (run-G2G3P "G2"))
  (if line
    (progn (copy2clip line) (princ (strcat "\nG2 copied: " line)))
    (princ "\nG2 cancelled.")
  )
  (princ)
)

(defun c:G3P ()
  (vl-load-com)
  (setq line (run-G2G3P "G3"))
  (if line
    (progn (copy2clip line) (princ (strcat "\nG3 copied: " line)))
    (princ "\nG3 cancelled.")
  )
  (princ)
)

;;; --------------------------------------------------------------------------
;;; Batch command: collect multiple lines, then copy all at once              
;;; Usage: type GCODE (or GCO) in command line, then pick commands from prompt.
;;; Press Enter at the Gcode prompt to finish and copy all accumulated lines. 
;;; --------------------------------------------------------------------------
(defun get-gcode-choice (/ ans clean)
  (initget "IDC G0 G0P G1 G1P G2 G2P G3 G3P Finish")
  (setq ans (getkword (strcat "\nSelect Gcode [IDC/G0P/G1P/G2P/G3P/Finish] <" *last-gcode* ">: ")))

  ;; If user pressed ENTER repeat last command (NOT exit)
  (if (not ans)
    (setq ans *last-gcode*)
    )
  (cond
    ((member ans '("IDC")) (setq clean "IDC"))
    ((member ans '("G0P" "G0")) (setq clean "G0P"))
    ((member ans '("G1P" "G1")) (setq clean "G1P"))
    ((member ans '("G2P" "G2")) (setq clean "G2P"))
    ((member ans '("G3P" "G3")) (setq clean "G3P"))
    ((member ans '("Finish" "F")) (setq clean nil))
  )

  (if clean (setq *last-gcode* clean))
  clean
)

(defun c:gcode (/ collected cmd line)
  (setq collected '())

  (while
    (setq cmd (get-gcode-choice))  ;; keeps asking until user Finish

    (setq line
      (cond
        ((equal cmd "IDC")  (run-IDC))
        ((equal cmd "G0P")  (run-G0P))
        ((equal cmd "G1P")  (run-G1P))
        ((equal cmd "G2P")  (run-G2G3P "G2"))
        ((equal cmd "G3P")  (run-G2G3P "G3"))
      )
    )

    ;; Saves Gcode String
    (if line
      (setq collected (append collected (list line)))
    )
  )

  ;; Copies all Gcode to Clipboard
  (if collected
    (progn
      (setq bigstr
        (apply 'strcat
          (mapcar '(lambda (s)(strcat s "\n")) collected)
        )
      )
      (copy2clip bigstr)
      (princ "\nAll G-code copied to clipboard.")
    )
    (princ "\nNo G-code generated.")
  )

  (princ)
)

;; -----------
;; Info banner
;; -----------
(defun show-cnc-helper-info ()
  (textscr)
  (princ "\n====================================================")
  (princ "\n   CNC HELPER COMMANDS v1.3.3 Successfully Loaded   ")
  (princ "\n=================================================== ")
  (princ "\nCommands loaded: IDC, G0P, G1P, G2P, G3P, GCODE     ")
  (princ "\n     Created by: VILLAFRANCA | github.com/Hans930v  ")
  (princ "\n        License: MIT")
  (princ "\n====================================================")
  (princ)
  (graphscr)
)
(show-cnc-helper-info)

(princ)
