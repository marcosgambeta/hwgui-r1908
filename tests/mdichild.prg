#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN MDI TITLE "Test"

   MENU OF oMainWindow
      MENUITEM "&New child" ACTION NewChild()
      MENUITEM "&Exit" ACTION hwg_EndWindow()
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

RETURN NIL

STATIC FUNCTION NewChild()

   STATIC nChildNum := 0

   LOCAL oChildWindow

   ++nChildNum

   INIT WINDOW oChildWindow MDICHILD TITLE "Child Window #" + AllTrim(Str(nChildNum)) ;
      AT 0, 0 SIZE 640, 480 STYLE WS_VISIBLE + WS_OVERLAPPEDWINDOW

   ACTIVATE WINDOW oChildWindow CENTERED

RETURN NIL
