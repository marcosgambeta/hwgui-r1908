//
// HWGUI using sample
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "windows.ch"
#include "guilib.ch"

#define TEST_PRINT

FUNCTION Main
Local oMainWindow, oPanel
Private oFont := NIL, cImageDir := "/" + Curdir() + "/../../image/"
Private nColor, oBmp2

   // hb_SetCodepage("RU1251")

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 200, 0 SIZE 400, 150
     
   @ 0, 0 PANEL oPanel SIZE 0, 32
   @ 2, 3 OWNERBUTTON OF oPanel ON CLICK {||FileOpen()} ;
   SIZE 32, 26 FLAT ;
   BITMAP cImageDir + "new.bmp" TRANSPARENT COLOR 12632256 COORDINATES 0, 4, 0, 0 ;
   TOOLTIP "Open File"

   MENU OF oMainWindow
      MENU TITLE "&File"
         MENUITEM "&Open" ACTION FileOpen()
         SEPARATOR
         MENUITEM "&Font" ACTION oFont := HFont():Select(oFont)
         MENUITEM "&Color" ACTION (nColor := hwg_ChooseColor(nColor, .F.), ;
                     hwg_MsgInfo(IIf(nColor != NIL, Str(nColor), "--"), "Color value"))
         SEPARATOR
         MENUITEM "&Move Main Window" ACTION oMainWindow:Move(50, 60, 200, 300)
         MENUITEM "&Exit" ACTION hwg_EndWindow()
      ENDMENU
      MENU TITLE "&Samples"
         MENUITEMCHECK "&Checked" ID 1001 
         SEPARATOR
         MENUITEM "&Test Tab" ACTION TestTab()
         SEPARATOR
         MENUITEM "&MsgGet" ;
               ACTION hwg_CopyStringToClipboard(hwg_MsgGet("Dialog Sample", "Input table name"))
         MENUITEM "&Dialog from prg" ACTION DialogFromPrg()
         #ifdef TEST_PRINT         
         SEPARATOR
         MENUITEM "&Print Preview" ACTION PrnTest()
         #endif
      ENDMENU

   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION FileOpen
Local oModDlg, oBrw
Local mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
Local fname := hwg_SelectFile("xBase files( *.dbf )", "*.dbf", mypath)
Local nId

   IF !Empty(fname)
   
      mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
      use &fname new
      nId := 111

      INIT DIALOG oModDlg TITLE "1"                    ;
            AT 210, 10  SIZE 500, 300                    ;
            ON INIT {|o|hwg_SetWindowText(o:handle, fname)} ;
            ON EXIT {|o|Fileclose(o)}
/*
      MENU OF oModDlg
         MENUITEM "&Font" ACTION (oBrw:oFont := HFont():Select(oFont), oBrw:Refresh())
         MENUITEM "&Exit" ACTION EndDialog(oModDlg:handle)
      ENDMENU
*/
      @ 0, 0 BROWSE oBrw DATABASE OF oModDlg ID nId ;
            SIZE 500, 300                           ;
            STYLE WS_VSCROLL + WS_HSCROLL          ;
            ON SIZE {|o, x, y|o:Move(,, x, y)}         ;
            ON GETFOCUS {|o|dbSelectArea(o:alias)}
      hwg_CreateList(oBrw, .T.)
      oBrw:bScrollPos := {|o, n, lEof, nPos|hwg_VScrollPos(o, n, lEof, nPos)}
      IF oFont != NIL
         oBrw:ofont := oFont
      ENDIF
      AEval(oBrw:aColumns, {|o|o:bHeadClick := {|oB, n|hwg_MsgInfo("Column number " + Str(n))}})

      ACTIVATE DIALOG oModDlg NOMODAL
   ENDIF
RETURN NIL

FUNCTION FileClose(oDlg)
   Local oBrw := oDlg:FindControl(111)
   dbSelectArea(oBrw:alias)
   dbCloseArea()
RETURN .T.

FUNCTION printdos
Local han := fcreate("LPT1", 0)
  IF han != -1
     fwrite(han, Chr(10) + Chr(13) + "Example of dos printing ..." + Chr(10) + Chr(13))
     fwrite(han, "Line 2 ..." + Chr(10) + Chr(13))
     fwrite(han, "---------------------------" + Chr(10) + Chr(13) + Chr(12))
     fclose(han)
  ELSE
     hwg_MsgStop("Can't open printer port!")
  ENDIF
RETURN NIL

FUNCTION DialogFromPrg()
Local cTitle := "Dialog from prg", cText := "Input something"
Local oModDlg, oFont := HFont():Add("Serif", 0, -13), oTab
Local cRes, aCombo := {"First", "Second"}, oEdit, vard := "Monday"

   CheckMenuItem(, 1001, !IsCheckedMenuItem(, 1001))
   
   INIT DIALOG oModDlg TITLE cTitle           ;
   AT 210, 10  SIZE 300, 300                    ;
   FONT oFont                                 ;
   ON EXIT {||hwg_MsgYesNo("Really exit ?")}

   @ 20, 10 SAY cText SIZE 260, 22
   @ 20, 35 EDITBOX oEdit CAPTION ""    ;
        STYLE WS_DLGFRAME              ;
        SIZE 260, 26 COLOR hwg_VColor("FF0000")

   @ 20, 70 CHECKBOX "Check 1" SIZE 90, 20
   @ 20, 95 CHECKBOX "Check 2"  ;
        SIZE 90, 20 COLOR IIf(nColor == NIL, hwg_VColor("0000FF"), nColor)

   @ 160, 70 GROUPBOX "RadioGroup"  SIZE 130, 75

   RADIOGROUP
   @ 180, 90 RADIOBUTTON "Radio 1"  ;
        SIZE 90, 20 ON CLICK {||oEdit:SetColor(hwg_VColor("0000FF"),, .T.)}
   @ 180, 115 RADIOBUTTON "Radio 2" ;
        SIZE 90, 20 ON CLICK {||oEdit:SetColor(hwg_VColor("FF0000"),, .T.)}
   END RADIOGROUP SELECTED 2

   @ 20, 120 COMBOBOX aCombo STYLE WS_TABSTOP ;
        SIZE 100, 25

   @ 20, 160 UPDOWN 10 RANGE -10, 50 SIZE 50, 32 STYLE WS_BORDER

   @ 160, 160 TAB oTab ITEMS {} SIZE 130, 56
   BEGIN PAGE "Monday" OF oTab
      @ 20, 10 GET vard SIZE 80, 22 STYLE WS_BORDER
   END PAGE OF oTab
   BEGIN PAGE "Tuesday" OF oTab
      @ 20, 10 EDITBOX "" SIZE 80, 22 STYLE WS_BORDER
   END PAGE OF oTab

   @ 100, 220 LINE LENGTH 100

   @ 20, 240 BUTTON "Ok" OF oModDlg ID IDOK  ;
        SIZE 100, 32 COLOR hwg_VColor("FF0000")
   @ 180, 240 BUTTON "Cancel" OF oModDlg ID IDCANCEL  ;
        SIZE 100, 32

   ACTIVATE DIALOG oModDlg
   oFont:Release()

RETURN NIL

FUNCTION TestTab()

Local oDlg, oTAB
Local oGet1, oGet2, oVar1 := "1", oVar2 := "2"
Local oGet3, oGet4, oVar3 := "3", oVar4 := "4", oGet5, oVar5 := "5"

INIT DIALOG oDlg CLIPPER NOEXIT AT 0, 0 SIZE 200, 200 ;
   ON INIT  {||hwg_SetFocus(oDlg:getlist[1]:handle)}

@ 10, 10 TAB oTab ITEMS {} SIZE 180, 180 ;
   ON LOSTFOCUS {||hwg_MsgInfo("Lost Focus")}


BEGIN PAGE "Page 01" of oTab

  @ 30, 60 Get oGet1 VAR oVar1 SIZE 100, 26
  @ 30, 90 Get oGet2 VAR oVar2 SIZE 100, 26
  @ 30, 120 Get oGet3 VAR oVar3 SIZE 100, 26
  @ 30, 150 Get oGet4 VAR oVar4 SIZE 100, 26

END PAGE of oTab

BEGIN PAGE "Page 02" of oTab

  @ 30, 60 Get oGet5 VAR oVar5 SIZE 100, 26

END PAGE of oTab

ACTIVATE DIALOG oDlg

RETURN NIL

#ifdef TEST_PRINT
FUNCTION PrnTest
Local oPrinter, oFont

   INIT PRINTER oPrinter
   IF oPrinter == NIL      
      RETURN NIL         
   ENDIF            
                              
   oFont := oPrinter:AddFont("Courier Regular", 10)
                  
   oPrinter:StartDoc(.T., "/tmp/_a.ps")
   oPrinter:StartPage()
   oPrinter:SetFont(oFont)
   oPrinter:Box(5, 5, oPrinter:nWidth - 5, oPrinter:nHeight - 5)
   oPrinter:Say("Windows printing first sample !", 50, 10, 165, 26, DT_CENTER, oFont)
   oPrinter:Line(45, 30, 170, 30)
   oPrinter:Line(45, 5, 45, 30)
   oPrinter:Line(170, 5, 170, 30)
   oPrinter:Say("----------", 50, 120, 150, 132, DT_CENTER)
   oPrinter:Box(50, 134, 160, 146)
   oPrinter:Say("End Of Report", 50, 135, 160, 146, DT_CENTER)
   oPrinter:EndPage()
   oPrinter:EndDoc()
   oPrinter:Preview()
   oPrinter:End()

RETURN NIL
#endif                                                               
                                                               
