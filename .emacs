;; ========= Set colours ==========
;; ============================
;; Setup syntax, background, and foreground coloring
;; ============================

(set-background-color "Black")
(set-foreground-color "White")
(set-cursor-color "LightSkyBlue")
(set-mouse-color "LightSkyBlue")
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

;; Set cursor and mouse-pointer colours
;;(set-cursor-color "red")
;;(set-mouse-color "goldenrod")

;; Set region background colour
(set-face-background 'region "blue")

;; ============================
;; Key mappings
;; ============================

;; goto line function C-c C-g
(global-set-key [ (control c) (control g) ] 'goto-line)

;; Moving around more easily
(global-set-key [C-right] 'forward-word)
(global-set-key [C-left]  'backward-word)

;; ============================
;; Display
;; ============================

;; disable startup message
(setq inhibit-startup-message t)

;; setup font
(set-default-font
 "-Misc-Fixed-Medium-R-Normal--15-140-75-75-C-90-ISO8859-1")

;; display the current time
;(display-time)

;; Show column number at bottom of screen
(column-number-mode 1)
(column-number-mode 1)

;; alias y to yes and n to no
(defalias 'yes-or-no-p 'y-or-n-p)

;; highlight matches from searches
(setq isearch-highlight t)
(setq search-highlight t)
(setq-default transient-mark-mode t)

(when (fboundp 'blink-cursor-mode)
  (blink-cursor-mode -1))

;; format the title-bar to always include the buffer name
(setq frame-title-format "emacs - %b")

;; ===========================
;; Behaviour
;; ===========================

;; Pgup/dn will return exactly to the starting point.
(setq scroll-preserve-screen-position 1)

;; don't automatically add new lines when scrolling down at
;; the bottom of a buffer
(setq next-line-add-newlines nil)

;; scroll just one line when hitting the bottom of the window
(setq scroll-step 1)
(setq scroll-conservatively 1)

;; show a menu only when running within X (save real estate when
;; in console)
(menu-bar-mode (if window-system 1 -1))

;; -------------------------------------------
;; The new emacs 21 toolbar sucks 
;; -------------------------------------------
(tool-bar-mode 0)

;; replace highlighted text with what I type rather than just
;; inserting at a point
(delete-selection-mode t)
