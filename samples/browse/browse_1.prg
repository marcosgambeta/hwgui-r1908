#include "hwgui.ch"

STATIC nCount := 0
STATIC oBrowse

FUNCTION Main()

   LOCAL oMain

   CreateDB()

   INIT WINDOW oMain MAIN TITLE "Browse Example - Database" ;
      AT 0, 0 ;
      SIZE hwg_GetDesktopWidth(), hwg_GetDesktopHeight() - 28

   MENU OF oMain
      MENUITEM "&Exit"   ACTION oMain:Close()
      MENUITEM "&Browse" ACTION BrowseTest()
      MENUITEM "&Count"  ACTION hwg_MsgInfo(Str(nCount))
   ENDMENU

   ACTIVATE WINDOW oMain

RETURN NIL

FUNCTION BrowseTest()

   LOCAL oForm
   LOCAL oFont

   hwg_SetToolTipBalloon(.T.)

   PREPARE FONT oFont NAME "Courier New" WIDTH 0 HEIGHT -11

   INIT DIALOG oForm CLIPPER NOEXIT TITLE "Browse Database";
     FONT oFont ;
     AT 0, 0 SIZE 700, 425 ;
     STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

   @  5, 5 BROWSE oBrowse DATABASE OF oForm SIZE 690, 375 STYLE WS_VSCROLL + WS_HSCROLL ;
      AUTOEDIT ;
      APPEND ;
      ON KEYDOWN {|o, key|BrowseKey(o, key)} ;
      ON UPDATE {|oBrow, Colpos|BrowseUpdate(oBrow, colpos)} ;
      ON POSCHANGE {||BrowseMove()}

   PUBLIC TENTA := 1

   ADD COLUMN FieldBlock(Fieldname(1)) TO oBrowse ;
      HEADER "Code";
      TYPE "N";
      LENGTH 6 ;
      DEC 0 ;
      EDITABLE ;
      PICTURE "@E 999,999";
      JUSTIFY HEAD DT_CENTER ;
      JUSTIFY LINE DT_RIGHT ;
      VALID BrowseValid() ;
      WHEN  BrowseWhen()

   ADD COLUMN FieldBlock(Fieldname(2)) TO oBrowse ;
      HEADER "Description" ;
      EDITABLE ;
      PICTURE "@!" ;
      JUSTIFY HEAD DT_CENTER ;
      JUSTIFY LINE DT_LEFT

   ADD COLUMN FieldBlock(Fieldname(3)) TO oBrowse ;
      HEADER "List Code" ;
      EDITABLE ;
      ITEMS {"Code 1", "Code 2", "Code 3"}

   ADD COLUMN FieldBlock(Fieldname(4)) TO oBrowse ;
      HEADER "Creation Date" ;
      EDITABLE

   ADD COLUMN FieldBlock(Fieldname(5)) TO oBrowse ;
      HEADER "Bool Status" ;
      EDITABLE

   ADD COLUMN FieldBlock(Fieldname(6)) TO oBrowse ;
      HEADER "Price" ;
      EDITABLE ;
      PICTURE "@E 999,999.99"

   ACTIVATE DIALOG oForm

RETURN NIL

STATIC FUNCTION BrowseWhen()

   hwg_MsgExclamation("When Event")

RETURN .T.

STATIC FUNCTION BrowseValid()

   hwg_MsgExclamation("Valid Event" + Str(TENTA))
   ++TENTA

RETURN .T.

STATIC FUNCTION BrowseMove()

   hwg_MsgInfo("Going to record " + LTrim(Str(RecNo())))

RETURN NIL

STATIC FUNCTION BrowseUpdate(oBrow, colpos)

   hwg_MsgExclamation("Column " + LTrim(Str(colpos)) + " Changed")

   IF colpos == 2
      oBrow:Append()
   ELSE
      oBrow:DoHScroll(SB_LINERIGHT)
      oBrow:Edit()
   ENDIF

   oBrowse:RefreshLine()

RETURN NIL

STATIC FUNCTION BrowseKey(oBrowse, key)

   IF key == VK_INSERT
      oBrowse:Append()
   ENDIF

RETURN .T.

STATIC FUNCTION CreateDB()

   IF file("browse_1.dbf")
      FErase("browse_1.dbf")
   ENDIF

   DBCreate("browse_1", {{"code", "N", 6, 0}, ;
                         {"desc", "C", 40, 0}, ;
                         {"list", "N", 1, 0}, ;
                         {"creation", "D", 8, 0}, ;
                         {"status", "L", 1, 0}, ;
                         {"price", "N", 10, 2}})

   USE browse_1 EXCLUSIVE

   APPEND BLANK
   REPLACE Code WITH 1
   REPLACE Desc WITH "Testing code"
   REPLACE list WITH 1
   REPLACE creation WITH Date()
   REPLACE Status WITH .T.
   REPLACE Price WITH 150.31

RETURN NIL
