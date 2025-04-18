//ANNOUNCE HB_GT_DEFAULT_GUI
//REQUEST HB_GT_GUI

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow

   HWG_INITCOMMONCONTROLSEX()

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 200, 0 SIZE 400, 150

   MENU of  oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Get a value" ACTION DlgGet()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION DlgGet()

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL cRes
   LOCAL aCombo := {"First", "Second"}
   LOCAL oGet
   LOCAL e1 := "Dialog from prg"
   LOCAL c1 := .F.
   LOCAL c2 := .T.
   LOCAL r1 := 2
   LOCAL cm := 1
   LOCAL upd := 12
   LOCAL d1 := Date() + 1
   //LOCAL aitem := {{2, 701, 0x04, 0x0000, 0, "teste1", {|x, y|DlgGet()}}, {3, 702, 0x04, 0x0000, 0, "teste2",}, {-1, 702, 0x04, 0x0000, 0, "teste3",}}
   LOCAL otool
   LOCAL omenu
   LOCAL omenu1
   LOCAL amenu

   INIT DIALOG oModDlg TITLE "Get a value"  ;
      AT 210, 10 SIZE 300, 300                  ;
      FONT oFont // ON INIT {||CreateBar(oModDlg, @otool)}

   Create menubar aMenu
   MENUBARITEM  amenu CAPTION "teste" ON 904 ACTION {||hwg_MsgYesNo("Really want to quit ?")}
   MENUBARITEM  amenu CAPTION "teste1" ON 905 ACTION {||.T.}
   MENUBARITEM  amenu CAPTION "teste2" ON 906 ACTION {||.T.}

   @ 0, 0 toolbar oTool of oModDlg size oModDlg:nWidth, 40 ID 700
   TOOLBUTTON  otool ;
          ID 701 ;
           BITMAP 2;
           STYLE 0 + BTNS_DROPDOWN ;
           STATE 4;
           TEXT "teste1"  ;
           TOOLTIP "ola" ;
           menu amenu;
           ON CLICK {|x, y|DlgGet()}

   TOOLBUTTON  otool ;
          ID 702 ;
           BITMAP 3;
           STYLE 0 ;
           STATE 4;
           TEXT "teste2"  ;
           TOOLTIP "ola2" ;
           ON CLICK {|x, y|DlgGet()}

   TOOLBUTTON  otool ;
          ID 703 ;
           BITMAP 2;
           STYLE 0 ;
           STATE 4;
           TEXT ""  ;
           TOOLTIP "ola3" ;
           ON CLICK {|x, y|DlgGet()}

   @ 20, 50 SAY "Input something:" SIZE 260, 22
   @ 20, 75 GET oGet VAR e1  ;
        STYLE WS_DLGFRAME   ;
        SIZE 260, 26 COLOR hwg_VColor("FF0000")

   @ 20, 110 GET CHECKBOX c1 CAPTION "Check 1" SIZE 90, 20
   @ 20, 135 GET CHECKBOX c2 CAPTION "Check 2" SIZE 90, 20 COLOR hwg_VColor("0000FF")

   @ 160, 110 GROUPBOX "RadioGroup" SIZE 130, 75

   GET RADIOGROUP r1
   @ 180, 130 RADIOBUTTON "Radio 1"  ;
        SIZE 90, 20 ON CLICK {||oGet:SetColor(hwg_VColor("0000FF"),, .T.)}
   @ 180, 155 RADIOBUTTON "Radio 2" ;
        SIZE 90, 20 ON CLICK {||oGet:SetColor(hwg_VColor("FF0000"),, .T.)}
   END RADIOGROUP

   @ 20, 160 GET COMBOBOX cm ITEMS aCombo SIZE 100, 24

   @ 20, 200 GET UPDOWN upd RANGE 0, 80 SIZE 50, 24
   @ 160, 200 GET DATEPICKER d1 SIZE 90, 24

   @ 20, 240 BUTTON "Ok" ID IDOK SIZE 100, 32
   @ 180, 240 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oModDlg
   oFont:Release()

   IF oModDlg:lResult
      hwg_MsgInfo(e1 + Chr(10) + Chr(13) +                               ;
               "Check1 - " + IIf(c1, "On", "Off") + Chr(10) + Chr(13) + ;
               "Check2 - " + IIf(c2, "On", "Off") + Chr(10) + Chr(13) + ;
               "Radio: " + Str(r1, 1) + Chr(10) + Chr(13) +            ;
               "Combo: " + aCombo[cm] + Chr(10) + Chr(13) +           ;
               "UpDown: " + Str(upd) + Chr(10) + Chr(13) +              ;
               "DatePicker: " + DToC(d1), "Results:")
   ENDIF

RETURN NIL

PROCEDURE HB_GTSYS
RETURN

PROCEDURE HB_GT_DEFAULT_GUI
RETURN

FUNCTION CreateBar(oModDlg, otool)

   //LOCAL hTool
   //LOCAL aItem := {{-1, 701, 0x04, 0x0000, 0, "teste1"}, {-1, 702, 0x04, 0x0000, 0, "teste2"}, {-1, 703, 0x04, 0x0000, 0, "teste3"}}
   LOCAL aitem := {{2, 701, 0x04, 0x0000, 0, "teste1", {|x, y|DlgGet()}, "teste"}, {3, 702, 0x04, 0x0000, 0, "teste2", , "rtrt"}, {-1, 702, 0x04, 0x0000, 0, "teste3", , "teste222"}}
   //LOCAL pItem

//  hTool := CREATETOOLBAR(oModDlg:handle, 700, 0, 0, 0, 50, 100)
// //  pItem :=  hwg_ToolBarAddButtons(hTool, aTool, Len(aTool))
 //
//   otool := Htoolbar():New(, , , 0, 0, 50, 100, "Input something:", , , , , , , , .F., aitem)
//   oTool:oParent:AddEvent(BN_CLICKED, 701, {|x, y|DlgGet()})
/*   @ 0, 0 toolbar oTool of oModDlg size 50, 100 ID 700 items aItem

   TOOLBUTTON  otool ;
          ID 701 ;
           BITMAP 2;
           STYLE 0 + BTNS_DROPDOWN ;
           STATE 4;
           TEXT "teste1"  ;
           TOOLTIP "ola" ;
           ON CLICK {|x, y|DlgGet()}

   TOOLBUTTON  otool ;
          ID 702 ;
           BITMAP 3;
           STYLE 0 ;
           STATE 4;
           TEXT "teste2"  ;
           TOOLTIP "ola2" ;
           ON CLICK {|x, y|DlgGet()}

   TOOLBUTTON  otool ;
          ID 703 ;
           BITMAP 2;
           STYLE 0 ;
           STATE 4;
           TEXT ""  ;
           TOOLTIP "ola3" ;
           ON CLICK {|x, y|DlgGet()}
*/

RETURN NIL

#include <hbclass.ch>
class mymenu
data handle
method new(c) inline ::handle := c, self
endclass
