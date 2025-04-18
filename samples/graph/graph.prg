#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" COLOR COLOR_3DLIGHT ;
     AT 200, 0 SIZE 400, 100

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Graph1" ACTION Graph1()
      MENUITEM "&Graph2" ACTION Graph2()
      MENUITEM "&Graph3" ACTION Graph3()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

STATIC FUNCTION Graph1()

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL oGraph
   LOCAL i
   LOCAL aGraph[1]

   aGraph[1] := {}
   FOR i := -40 TO 40
      AAdd(aGraph[1], {i, hwg_cos(i / 10)})
   NEXT

   INIT DIALOG oModDlg CLIPPER TITLE "Graph"        ;
           AT 210, 10 SIZE 300, 300                  ;
           FONT oFont

   @ 50, 30 GRAPH oGraph DATA aGraph SIZE 200, 100 COLOR 65280
   // oGraph:oPen := HPen():Add(PS_SOLID, 2, oGraph:tcolor)

   @ 90, 250 BUTTON "Close"  ;
       SIZE 120, 30          ;
       ON CLICK {||EndDialog()}

   ACTIVATE DIALOG oModDlg

RETURN NIL

STATIC FUNCTION Graph2()

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL oGraph
   LOCAL i
   LOCAL aGraph[1]

   aGraph[1] := {}
   FOR i := 1 TO 6
      AAdd(aGraph[1], {"", i * i})
   NEXT

   INIT DIALOG oModDlg CLIPPER TITLE "Graph"        ;
           AT 210, 10 SIZE 300, 300                  ;
           FONT oFont

   @ 50, 30 GRAPH oGraph DATA aGraph SIZE 200, 200 COLOR 65280
   oGraph:nType := 2

   @ 90, 250 BUTTON "Close"  ;
       SIZE 120, 30          ;
       ON CLICK {||EndDialog()}

   ACTIVATE DIALOG oModDlg

RETURN NIL

STATIC FUNCTION Graph3()

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL oGraph
   LOCAL i
   LOCAL aGraph[1]

   aGraph[1] := {}
   FOR i := 1 TO 6
      AAdd(aGraph[1], i * i)
   NEXT

   INIT DIALOG oModDlg CLIPPER TITLE "Graph"        ;
           AT 210, 10 SIZE 300, 300                  ;
           FONT oFont
/*
   @ 50, 30 GRAPH oGraph DATA aGraph SIZE 200, 200 COLOR 65280
   oGraph:nType := 3

   @ 90, 250 BUTTON "Close"  ;
       SIZE 120, 30          ;
       ON CLICK {||EndDialog()}
*/
   ACTIVATE DIALOG oModDlg

RETURN NIL
