#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL oLabel1
   LOCAL oLabel2
   LOCAL oTimer1
   LOCAL oTimer2

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 20, 20 SAY oLabel1 CAPTION Time() SIZE 120, 30
   @ 20, 60 SAY oLabel2 CAPTION SubStr(Time(), 7, 2) SIZE 120, 30

   SET TIMER oTimer1 OF oDialog VALUE 1000 ACTION {||oLabel1:SetText(Time())}
   SET TIMER oTimer2 OF oDialog VALUE 1000 ACTION {||oLabel2:SetText(SubStr(Time(), 7, 2))}

   ACTIVATE DIALOG oDialog

RETURN NIL
