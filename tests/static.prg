#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   @ 20, 20 SAY "Label 1" SIZE 130, 30 OF oDialog
   @ 20, 60 SAY "Label 2" SIZE 130, 30 COLOR 0xFF00FF  OF oDialog
   @ 20, 100 SAY "Label 3" SIZE 130, 30 BACKCOLOR 0x00FF00  OF oDialog
   @ 20, 140 SAY "Label 4" SIZE 130, 30 TRANSPARENT OF oDialog
   @ 20, 180 SAY "Label 5" SIZE 130, 30 STYLE SS_CENTER FONT HFont():Add("Courier New", 0, -15) OF oDialog

   ACTIVATE DIALOG oDialog

RETURN NIL
