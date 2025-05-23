//
// HwGUI Samples
// testget2.prg - GET system and Timer in dialog box.
//

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow

   PRIVATE var1 := 10320.54

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 200, 0 SIZE 400, 150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Get a value" ACTION DlgGet(.F.)
      MENUITEM "&Get using hwg_SetColorInFocus" ACTION DlgGet(.T.)
      MENUITEM "&Text Ballon" ACTION TestBallon()
      MENUITEM "&Hd Serial  " ACTION hwg_MsgInfo(hwg_HdSerial("C:\"), "HD Serial number")
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION DlgGet(lColor)

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL oTimer
   LOCAL e1 := "Dialog from prg"
   LOCAL e2 := Date()
   LOCAL e3 := 10320.54
   LOCAL e4 := "11222333444455"
   LOCAL e5 := 10320.54
   LOCAL e6 := "Max Lenght = 15"
   LOCAL e7 := "Password"

   PRIVATE oSayT

   INIT DIALOG oModDlg CLIPPER NOEXIT TITLE "Get a value"  ;
      AT 210, 10 SIZE 300, 320                  ;
      FONT oFont ;
      ON INIT {||SetTimer(oModDlg, @oTimer)}

   SET KEY FSHIFT, VK_F3 TO hwg_MsgInfo("Shift-F3")
   SET KEY FCONTROL, VK_F3 TO hwg_MsgInfo("Ctrl-F3")
   SET KEY 0, VK_F3 TO hwg_MsgInfo("F3")

   IF lColor != NIL
      hwg_SetColorInFocus(lColor)
   ENDIF

   @ 20, 10 SAY "Input something:" SIZE 260, 22

   @ 20, 35 GET e1                       ;
        PICTURE "XXXXXXXXXXXXXXX"       ;
        SIZE 260, 26

   @ 20, 65 GET e6                       ;
        MAXLENGTH 15                    ;
        SIZE 260, 26

   @ 20, 95 GET e2 SIZE 260, 26

   @ 20, 125 GET e3 SIZE 260, 26

   @ 20, 155 GET e4                      ;
        PICTURE "@R 99.999.999/9999-99" ;
        SIZE 260, 26

   @ 20, 185 GET e5                      ;
        PICTURE "@e 999,999,999.9999"     ;
        SIZE 260, 26

   @ 20, 215 GET e7                      ;
        PASSWORD                        ;
        SIZE 260, 26

   @  20, 250 BUTTON "Ok" SIZE 100, 32 ON CLICK {||oModDlg:lResult := .T., EndDialog()}
   @ 180, 250 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32

   @ 100, 295 SAY oSayT CAPTION "" SIZE 100, 22 STYLE WS_BORDER + SS_CENTER ;
      COLOR 10485760 BACKCOLOR 12507070

   ReadExit(.T.)
   ACTIVATE DIALOG oModDlg

   oTimer:End()

   IF oModDlg:lResult
      hwg_MsgInfo(e1 + Chr(10) + Chr(13) +       ;
               e6 + Chr(10) + Chr(13) +       ;
               Dtoc(e2) + Chr(10) + Chr(13) + ;
               Str(e3) + Chr(10) + Chr(13) +  ;
               e4 + Chr(10) + Chr(13) +       ;
               Str(e5) + Chr(10) + Chr(13) +  ;
               e7 + Chr(10) + Chr(13), "Results:")
   ENDIF

RETURN NIL

STATIC FUNCTION SetTimer(oDlg, oTimer)

   SET TIMER oTimer OF oDlg VALUE 1000 ACTION {||TimerFunc()}

RETURN NIL

STATIC FUNCTION TimerFunc()

   oSayT:SetValue(Time())

RETURN NIL

FUNCTION TestBallon()

   LOCAL oWnd

   hwg_SetToolTipBalloon(.T.)

   INIT DIALOG oWnd CLIPPER TITLE "Dialog text Balon" ;
      AT 100, 100 SIZE 140, 100

   @ 20, 20 BUTTON "Button 1" ON CLICK {||hwg_MsgInfo("Button 1")} SIZE 100, 40 ;
       TOOLTIP "ToolTip do Button 1"

   ACTIVATE DIALOG oWnd

RETURN NIL
