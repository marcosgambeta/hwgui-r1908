#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL oBtn
   LOCAL aCombo := {"First", "Second"}
   LOCAL cTool := "Example"
   LOCAL oFont
   LOCAL aTabs := {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"}
   LOCAL oTab
   LOCAL acho := {{"First item", 180}, {"Second item", 200}}
   LOCAL oEdit
   LOCAL oGetTab
   LOCAL oTree
   LOCAL oItem

   PRIVATE aGetsTab := {"", "", "", "", "", "", "", "", "", "", "", "", "", ""}

   // PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -13
   PREPARE FONT oFont NAME "Times New Roman" WIDTH 0 HEIGHT -17 CHARSET 4

   INIT WINDOW oMainWindow MAIN TITLE "Example"  ;
     COLOR COLOR_3DLIGHT + 1                       ;
     AT 200, 0 SIZE 420, 300                       ;
     FONT oFont                                  ;
     ON EXIT {||hwg_MsgYesNo("Really want to quit ?")}

   @ 20, 10 RICHEDIT oEdit TEXT "Hello, world !" SIZE 200, 30

   hwg_RE_SetCharFormat(oEdit:handle, {{1, 6, , , , .T.}, {8, 13, 255,,,,, .T.}})

   @ 270, 10 COMBOBOX aCombo SIZE 100, 150 TOOLTIP "Combobox"

   @ 20, 50 LINE LENGTH 100

   @ 20, 60 TAB oTab ITEMS aTabs SIZE 140, 100      ;
         STYLE TCS_FIXEDWIDTH + TCS_FORCELABELLEFT  ;
         ON CHANGE {|o, n|ChangeTab(o, oGetTab, n)}
   // @ 20, 60 TAB oTab ITEMS aTabs SIZE 90, 100 STYLE TCS_FIXEDWIDTH + TCS_VERTICAL + TCS_FORCELABELLEFT + WS_CLIPSIBLINGS  // + TCS_RIGHT
   hwg_SetTabSize(oTab:handle, 20, 20)
   @ 10, 30 RICHEDIT oGetTab TEXT "" OF oTab SIZE 120, 60 ;
          STYLE ES_MULTILINE

   @ 180, 60 SAY "" SIZE 70, 22 STYLE WS_BORDER BACKCOLOR 12507070

   @ 270, 60 TREE oTree SIZE 140, 100 EDITABLE

   oTree:AddNode("First")
   oTree:AddNode("Second")
   oItem := oTree:AddNode("Third")
   oItem:AddNode("Third-1")
   oTree:AddNode("Forth")

   @ 100, 180 BUTTON "Close" SIZE 150, 30 ON CLICK {||hwg_EndWindow()}

   MENU OF oMainWindow
      MENU TITLE "File"
         MENUITEM "Ps" ACTION Ps1(oMainWindow)
         SEPARATOR
         MENUITEM "YYYYY" ACTION hwg_MsgGet("Example", "Input anything")
      ENDMENU
      MENU TITLE "Help"
         MENUITEM "About" ACTION hwg_MsgInfo("About")
         MENUITEM "Info" ACTION hwg_MsgTemp("")
      ENDMENU
      MENU TITLE "Third"
         MENUITEM "Wchoice" ACTION hwg_Wchoice(acho, "Select", , , , , 15132390, , hwg_VColor("008000"))
         MENUITEM "SelectFolder" ACTION hwg_MsgInfo(hwg_SelectFolder("!!!"))
         MENU TITLE "Submenu"
            MENUITEM "ShellExecute" ACTION (hwg_ShellExecute("d:\temp\podst.doc"), hwg_MsgInfo(Str(oMainWindow:handle)))
            MENUITEM "S2" ACTION hwg_MsgStop("S2")
         ENDMENU
      ENDMENU
   ENDMENU

/*   
   aMenu := { ;
     {{{{||hwg_MsgInfo("Xxxx")}, "XXXXX", 130}, ;
         {,, 131}, ;
         {{||hwg_MsgInfo("Yyyy")}, "YYYYY", 132} ;
       }, "File", 120}, ;
     {{||hwg_MsgInfo("Help")}, "Help", 121} ;
   }
   hwg_BuildMenu(aMenu, hWnd, aMainWindow)
*/

   ACTIVATE WINDOW oMainWindow

RETURN NIL

STATIC FUNCTION ChangeTab(oWnd, oGet, n)

   STATIC lastTab := 1

   aGetsTab[lastTab] := hwg_GetEditText(oGet:oParent:handle, oGet:id)
   hwg_SetDlgItemText(oGet:oParent:handle, oGet:id, aGetsTab[n])
   lastTab := n

RETURN NIL

FUNCTION PS1(oWnd)

   LOCAL oDlg1
   LOCAL oDlg2

   INIT DIALOG oDlg1 TITLE "PAGE_1" STYLE WS_CHILD + WS_VISIBLE + WS_BORDER
   @ 20, 15 EDITBOX "" SIZE 160, 26 STYLE WS_BORDER
   @ 10, 50 LINE  LENGTH 200

   INIT DIALOG oDlg2 TITLE "PAGE_2" STYLE WS_CHILD + WS_VISIBLE + WS_BORDER
   @ 20, 35 EDITBOX "" SIZE 160, 26 STYLE WS_BORDER

   hwg_PropertySheet(hwg_GetActiveWindow(), {oDlg1, oDlg2}, "Sheet Example", 210, 10, 300, 300)

RETURN NIL
