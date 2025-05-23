#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 0, 0 SIZE hwg_GetDesktopWidth(), hwg_GetDesktopHeight() - 28

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION oMainWindow:Close()
      MENUITEM "&More" ACTION DlgGet()
      MENUITEM "Shell ABout" ACTION hwg_ShellAbout("Rodrigo Moreno", "Test")
      MENUITEM "Exclamation" ACTION hwg_MsgExclamation("Are You Sure ?", "Warning")
      MENUITEM "Retry Cancel" ACTION hwg_MsgRetryCancel("Are You Sure ?", "Retry")
      MENUITEM "Calc" ACTION hwg_ShellExecute("calc")
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

   INIT DIALOG oModDlg TITLE "Test"  ;
   AT 0, 0 SIZE 450, 350 STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU ;
   FONT oFont

   @ 20, 10 SAY "Input something:" SIZE 260, 22
   @ 20, 35 GET oGet VAR e1  ;
        STYLE WS_DLGFRAME   ;
        SIZE 260, 26 COLOR hwg_VColor("FF0000")

   @ 20, 70 GET CHECKBOX c1 CAPTION "Check 1" SIZE 90, 20
   @ 20, 95 GET CHECKBOX c2 CAPTION "Check 2" SIZE 90, 20 COLOR hwg_VColor("0000FF")

   @ 160, 70 GROUPBOX "RadioGroup" SIZE 130, 75

   GET RADIOGROUP r1
   @ 180, 90 RADIOBUTTON "Radio 1"  ;
        SIZE 90, 20 ON CLICK {||oGet:SetColor(hwg_VColor("0000FF"),, .T.)}
   @ 180, 115 RADIOBUTTON "Radio 2" ;
        SIZE 90, 20 ON CLICK {||oGet:SetColor(hwg_VColor("FF0000"),, .T.)}
   END RADIOGROUP

   @ 20, 120 GET COMBOBOX cm ITEMS aCombo SIZE 100, 150

   @ 20, 170 GET UPDOWN upd RANGE 0, 80 SIZE 50, 30
   @ 160, 170 GET DATEPICKER d1 SIZE 80, 20

   @  10, 240 BUTTON "Ok" ID IDOK SIZE 50, 32
   @  70, 240 BUTTON "Cancel" ID IDCANCEL SIZE 50, 32
   @ 130, 240 BUTTON "Enable/Disable" SIZE 100, 32 ON CLICK {||IIf(oGet:IsEnabled(), oGet:Disable(), oGet:Enable())}
   @ 240, 240 BUTTON "SetFocus" SIZE 70, 32 ON CLICK {||oGet:Setfocus()}
   @ 320, 240 BUTTON "Enabled ?" SIZE 70, 32 ON CLICK {||IIf(oGet:IsEnabled(), hwg_MsgInfo("Yes"), hwg_MsgStop("No"))}
   @ 400, 240 BUTTON "Close" SIZE 50, 32 ON CLICK {||oModDlg:Close()}

   @  10, 280 BUTTON "WinDir" SIZE 100, 32 ON CLICK {||hwg_MsgInfo(hwg_GetWindowsDir())}
   @ 120, 280 BUTTON "SystemDir" SIZE 100, 32 ON CLICK {||hwg_MsgInfo(hwg_GetSystemDir())}
   @ 230, 280 BUTTON "TempDir" SIZE 100, 32 ON CLICK {||hwg_MsgInfo(hwg_GetTempDir())}

   ACTIVATE DIALOG oModDlg
   oFont:Release()

   IF oModDlg:lResult
      hwg_MsgInfo(e1 + Chr(10) + Chr(13) +                               ;
               "Check1 - " + IIf(c1, "On", "Off") + Chr(10) + Chr(13) + ;
               "Check2 - " + IIf(c2, "On", "Off") + Chr(10) + Chr(13) + ;
               "Radio: " + Str(r1, 1) + Chr(10) + Chr(13) +            ;
               "Combo: " + aCombo[cm] + Chr(10) + Chr(13) +           ;
               "UpDown: " + Str(upd) + Chr(10) + Chr(13) +              ;
               "DatePicker: " + Dtoc(d1), "Results:")
   ENDIF

RETURN NIL
