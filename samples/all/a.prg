//
// HWGUI using sample
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include "hwgui.ch"

// REQUEST HB_CODEPAGE_RU866
// REQUEST HB_CODEPAGE_RU1251

FUNCTION Main()

   PRIVATE oMainWindow
   PRIVATE oPanel
   PRIVATE oFont := NIL
   PRIVATE cImageDir := "..\image\"
   PRIVATE nColor
   PRIVATE oBmp2

   // hb_SetCodepage("RU1251")

   INIT WINDOW oMainWindow MDI TITLE "Example" ;
         MENUPOS 3 COLOR HBrush():Add(16744703):handle 

   @ 0, 0 PANEL oPanel SIZE 0, 32
   @ 2, 3 OWNERBUTTON OF oPanel ON CLICK {||CreateChildWindow()} ;
       SIZE 32, 26 FLAT ;
       BITMAP cImageDir + "new.bmp" COORDINATES 0, 4, 0, 0 TOOLTIP "New MDI child window"

//   ADD STATUS oStatus TO oMainWindow PARTS 400

   MENU OF oMainWindow
      MENU TITLE "&File"
         MENUITEM "&New" ACTION CreateChildWindow()
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
         MENUITEM "&Checked" ID 1001 ;
               ACTION hwg_CheckMenuItem(, 1001, !hwg_IsCheckedMenuItem(, 1001))
         SEPARATOR
         MENUITEM "&Test Tab" ACTION TestTab()
         MENUITEM "&Class HRect" ACTION RRectangle()
         SEPARATOR
         MENUITEM "&MsgGet" ;
               ACTION hwg_CopyStringToClipboard(hwg_MsgGet("Dialog Sample", "Input table name"))
         MENUITEM "&Dialog from prg" ACTION DialogFromPrg()
         MENUITEM "&MdiChild from prg" ACTION MdiChildFromPrg()
         MENUITEM "&DOS print" ACTION PrintDos()
         MENUITEM "&Windows print" ;
               ACTION IIf(hwg_OpenReport("a.rpt", "Simple"), hwg_PrintReport(,, .T.), .F.)
         MENUITEM "&Print Preview" ACTION PrnTest()
         MENUITEM "&Sending e-mail using Outlook" ACTION Sendemail("test@test.com")
         MENUITEM "&Command ProgressBar" ACTION TestProgres()
         SEPARATOR
         MENUITEM "&Test No Exit" ACTION NoExit()
      ENDMENU

      MENU TITLE "&TopMost"
         MENUITEM "&Active" ACTION ActiveTopMost(oMainWindow:Handle, .T.)
         MENUITEM "&Desactive" ACTION ActiveTopMost(oMainWindow:Handle, .F.)
      ENDMENU

      MENU TITLE "&Help"
         MENUITEM "&About" ACTION OpenAbout()
         MENUITEM "&Window2Bitmap" ACTION About2()
         MENUITEM "&Version HwGUI and Compilator" ACTION hwg_MsgInfo(HwG_Version(1))
         MENUITEM "&Version HwGUI" ACTION hwg_MsgInfo(HwG_Version())
      ENDMENU
      MENU TITLE "&Windows"
         MENUITEM "&Tile"  ;
            ACTION hwg_SendMessage(HWindow():GetMain():handle, WM_MDITILE, MDITILE_HORIZONTAL, 0)
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

RETURN NIL

FUNCTION CreateChildWindow()

   LOCAL oChildWnd
   LOCAL oPanel
   LOCAL oFontBtn
   LOCAL oBoton1
   LOCAL oBoton2
   LOCAL e1 := "Dialog from prg"
   LOCAL e2 := Date()
   LOCAL e3 := 10320.54
   LOCAL e4 := "11222333444455"
   LOCAL e5 := 10320.54

   PREPARE FONT oFontBtn NAME "MS Sans Serif" WIDTH 0 HEIGHT -12

   INIT WINDOW oChildWnd MDICHILD TITLE "Child";
     STYLE WS_CHILD + WS_OVERLAPPEDWINDOW
     //STYLE WS_VISIBLE + WS_OVERLAPPEDWINDOW

   @ 0, 0 PANEL oPanel OF oChildWnd SIZE 0, 44

   @ 2, 3 OWNERBUTTON oBoton1 OF oPanel ID 108 ON CLICK {||oBoton2:Enable()} ;
       SIZE 44, 38 FLAT ;
       TEXT "New" FONT oFontBtn COORDINATES 0, 20, 0, 0  ;
       BITMAP cImageDir + "new.bmp" COORDINATES 0, 4, 0, 0 TOOLTIP "New"
   @ 46, 3 OWNERBUTTON oBoton2 OF oPanel ID 109 ON CLICK {||oBoton2:disable()} ;
       SIZE 44, 38 FLAT ;
       TEXT "Open" FONT oFontBtn COORDINATES 0, 20, 0, 0 ;
       BITMAP cImageDir + "open.bmp" COORDINATES 0, 4, 0, 0 TOOLTIP "Open" DISABLED

   @ 20, 55 GET e1                       ;
        PICTURE "XXXXXXXXXXXXXXX"       ;
        SIZE 260, 25

   @ 20, 80 GET e2 SIZE 260, 25

   @ 20, 105 GET e3 SIZE 260, 25

   @ 20, 130 GET e4                      ;
        PICTURE "@R 99.999.999/9999-99" ;
        SIZE 260, 25

   @ 20, 155 GET e5                      ;
        PICTURE "@e 999,999,999.99"     ;
        SIZE 260, 25

   @ 20, 190  BUTTONEX "Ok" SIZE 100, 32 ON CLICK {||(hwg_MsgInfo(e1 + Chr(10) + Chr(13) + ;
               Dtoc(e2) + Chr(10) + Chr(13) + ;
               Str(e3) + Chr(10) + Chr(13) +  ;
               e4 + Chr(10) + Chr(13) +       ;
               Str(e5) + Chr(10) + Chr(13), "Results:"), oChildWnd:Close())}
   @ 180, 190 BUTTONEX "Cancel" SIZE 100, 32 ON CLICK {||oChildWnd:Close()}

   oChildWnd:Activate()

RETURN NIL

FUNCTION MdiChildFromPrg(o)

   LOCAL cTitle := "MdiChild from prg"
   LOCAL cText := "Input something"
   LOCAL oChildWnd
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL cRes
   LOCAL aCombo := {"First", "Second"}
   LOCAL oEdit
   LOCAL vard := "Monday"
   // LOCAL aTabs := {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday"}
   LOCAL oCmd1
   LOCAL oCmd2
   LOCAL oCmd3

   INIT WINDOW oChildWnd MDICHILD TITLE "Child";
   AT 210, 10 SIZE 350, 350                    ;
   FONT oFont                                 ;
   STYLE WS_CHILD + WS_OVERLAPPEDWINDOW        ;
   ON EXIT {||hwg_MsgYesNo("Really exit ?")}

   @ 20, 10 SAY cText SIZE 260, 22
   @ 20, 35 EDITBOX oEdit CAPTION ""    ;
        STYLE WS_DLGFRAME              ;
        SIZE 260, 26 COLOR hwg_VColor("FF0000")
   oEdit:anchor := 11

   @ 20, 70 CHECKBOX "Check 1" SIZE 90, 20
   @ 20, 95 CHECKBOX "Check 2"  ;
        SIZE 90, 20 COLOR IIf(nColor == NIL, hwg_VColor("0000FF"), nColor)

   @ 160, 70 GROUPBOX "RadioGroup" SIZE 130, 75

   RADIOGROUP
   @ 180, 90 RADIOBUTTON "Radio 1"  ;
        SIZE 90, 20 ON CLICK {||oEdit:SetColor(hwg_VColor("0000FF"),, .T.)}
   @ 180, 115 RADIOBUTTON "Radio 2" ;
        SIZE 90, 20 ON CLICK {||oEdit:SetColor(hwg_VColor("FF0000"),, .T.)}
   END RADIOGROUP SELECTED 2

   @ 20, 120 COMBOBOX aCombo STYLE WS_TABSTOP ;
        SIZE 120, 24

   @ 20, 160 UPDOWN 10 RANGE -10, 50 SIZE 50, 32 STYLE WS_BORDER

   @ 160, 150 TAB oTab ITEMS {} SIZE 130, 66
   oTab:Anchor := 240
   BEGIN PAGE "Monday" OF oTab
      @ 20, 34 GET vard SIZE 80, 22 STYLE WS_BORDER
   END PAGE OF oTab
   BEGIN PAGE "Tuesday" OF oTab
      @ 20, 34 EDITBOX "" SIZE 80, 22 STYLE WS_BORDER
   END PAGE OF oTab

   @ 100, 220 LINE LENGTH 100

   @ 20, 240 BUTTONEX oCmd1 CAPTION "Ok" ID IDOK  ;
        SIZE 100, 32 COLOR hwg_VColor("FF0000")
   @ 140, 240 BUTTONEX oCmd2 CAPTION "11"   ;
        SIZE 20, 32 ON CLICK {|o|CreateC(o)}
   @ 180, 240 BUTTONEX oCmd3 CAPTION "Cancel" ID IDCANCEL  ;
        SIZE 100, 32
   oCmd1:Anchor := 4
   oCmd2:Anchor := 4
   oCmd3:Anchor := 4
   
   ACTIVATE WINDOW oChildWnd
 
RETURN NIL

FUNCTION NoExit()

   LOCAL oDlg
   LOCAL oGet
   LOCAL vGet := "Dialog if no close in ENTER or EXIT"

   INIT DIALOG oDlg TITLE "No Exit Enter and Esc"     ;
   AT 190, 10 SIZE 360, 240   NOEXIT NOEXITESC
   @ 10, 10 GET oGet VAR vGET SIZE 200, 32
   @ 20, 190  BUTTON "Ok" SIZE 100, 32;
   ON CLICK {||oDlg:Close()}
   oDlg:Activate()

RETURN NIL

FUNCTION OpenAbout()

   LOCAL oModDlg
   LOCAL oFontBtn
   LOCAL oFontDlg
   LOCAL oBrw
   LOCAL aSample := {{.T., "Line 1", 10}, {.T., "Line 2", 22}, {.F., "Line 3", 40}}
   LOCAL oBmp
   LOCAL oIcon := HIcon():AddFile("image\PIM.ICO")
   LOCAL oSay

   PREPARE FONT oFontDlg NAME "MS Sans Serif" WIDTH 0 HEIGHT -13
   PREPARE FONT oFontBtn NAME "MS Sans Serif" WIDTH 0 HEIGHT -13 ITALIC UNDERLINE

   INIT DIALOG oModDlg TITLE "About"     ;
   AT 190, 10 SIZE 360, 240               ;
   ICON oIcon                            ;
   ON EXIT {||oBmp2 := HBitmap():AddWindow(oBrw), .T.} ;
   FONT oFontDlg

   oModDlg:bActivate := {||hwg_MsgInfo("!!")}
      

   // @ 20, 30 BITMAP "image\OPEN.BMP"
   // @ 20, 20 ICON "image\PIM.ICO"
   @ 10, 10 IMAGE "..\image\ASTRO.JPG" SIZE 50, 50

   @ 20, 60 SAY "Sample Dialog"        ;
       SIZE 130, 22 STYLE SS_CENTER  ;
        COLOR hwg_VColor("0000FF")

   @ 20, 80 SAY "Written as a sample"  ;
        SIZE 130, 22 STYLE SS_CENTER
   @ 20, 100 SAY "of Harbour GUI" ;
        SIZE 130, 22 STYLE SS_CENTER
   @ 20, 120 SAY "application"    ;
        SIZE 130, 22 STYLE SS_CENTER

   @ 20, 140 SAY "Hwgui Page"        ;
   LINK "http://kresin.belgorod.su/hwgui.html" ;
       SIZE 130, 22 STYLE SS_CENTER  ;
        COLOR hwg_VColor("0000FF") ;
        VISITCOLOR hwg_RGB(241, 249, 91)

   @ 20, 160 SAY "Hwgui international Forum"        ;
   LINK "http://br.groups.yahoo.com/group/hwguibr" ;
       SIZE 200, 22 STYLE SS_CENTER  ;
        COLOR hwg_VColor("0000FF") ;
        VISITCOLOR hwg_RGB(241, 249, 91)


   @ 160, 30 BROWSE oBrw ARRAY SIZE 180, 110 ;
        STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   @ 80, 180 OWNERBUTTON ON CLICK {||EndDialog()}        ;
       SIZE 180, 35 FLAT                                  ;
       TEXT "Close" COLOR hwg_VColor("0000FF") FONT oFontBtn ;
       BITMAP cImageDir + "door.bmp" COORDINATES 40, 10, 0, 0
       // 

   hwg_CreateArList(oBrw, aSample)
   oBrw:bColorSel := 12507070  // 15149157449

   oBmp := HBitmap():AddStandard(OBM_LFARROWI)
   oBrw:aColumns[1]:aBitmaps := {{{|l|l}, oBmp}}
   oBrw:aColumns[2]:length := 6
   oBrw:aColumns[3]:length := 4
   oBrw:bKeyDown := {|o, key|BrwKey(o, key)}

   ACTIVATE DIALOG oModDlg
   oIcon:Release()

RETURN NIL

STATIC FUNCTION About2()

   IF oBmp2 == NIL
      RETURN NIL
   ENDIF

   INIT DIALOG oModDlg TITLE "About2"   ;
   AT 190, 10 SIZE 360, 240

   @ 10, 10 BITMAP oBmp2

   ACTIVATE DIALOG oModDlg

RETURN NIL

STATIC FUNCTION BrwKey(oBrw, key)

   IF key == 32
      oBrw:aArray[oBrw:nCurrent, 1] := !oBrw:aArray[oBrw:nCurrent, 1]
      oBrw:RefreshLine()
   ENDIF

RETURN .T.

FUNCTION FileOpen()

   LOCAL oModDlg
   LOCAL oBrw
   LOCAL mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
   LOCAL fname := hwg_SelectFile("xBase files( *.dbf )", "*.dbf", mypath)
   LOCAL nId

   IF !Empty(fname)
      mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
      // use &fname new codepage RU866
      use &fname new
      nId := 111

      INIT DIALOG oModDlg TITLE "1"                    ;
            AT 210, 10 SIZE 500, 300                    ;
            ON INIT {|o|hwg_SetWindowText(o:handle, fname)} ;
            ON EXIT {|o|Fileclose(o)}

      MENU OF oModDlg
         MENUITEM "&Font" ACTION (oBrw:oFont := HFont():Select(oFont), oBrw:Refresh())
         MENUITEM "&Exit" ACTION EndDialog(oModDlg:handle)
      ENDMENU

      @ 0, 0 BROWSE oBrw DATABASE OF oModDlg ID nId ;
            SIZE 500, 300                           ;
            STYLE WS_VSCROLL + WS_HSCROLL          ;
            ON SIZE {|o, x, y|hwg_MoveWindow(o:handle, 0, 0, x, y)} ;
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

   LOCAL oBrw := oDlg:FindControl(111)
   
   dbSelectArea(oBrw:alias)
   dbCloseArea()

RETURN .T.

FUNCTION PrintDos()

   LOCAL han := FCreate("LPT1", 0)

   IF han != -1
      FWrite(han, Chr(10) + Chr(13) + "Example of dos printing ..." + Chr(10) + Chr(13))
      FWrite(han, "Line 2 ..." + Chr(10) + Chr(13))
      FWrite(han, "---------------------------" + Chr(10) + Chr(13) + Chr(12))
      FClose(han)
   ELSE
      hwg_MsgStop("Can't open printer port!")
   ENDIF

RETURN NIL

FUNCTION PrnTest()

   LOCAL oPrinter
   LOCAL oFont

   INIT PRINTER oPrinter
   IF oPrinter == NIL
      RETURN NIL
   ENDIF

   oFont := oPrinter:AddFont("Times New Roman", 10)

   oPrinter:StartDoc(.T.)
   oPrinter:StartPage()
   oPrinter:SetFont(oFont)
   oPrinter:Box(5, 5, oPrinter:nWidth - 5, oPrinter:nHeight - 5)
   oPrinter:SetTextColor(2788990)
   oPrinter:Say("Windows printing first sample !", 50, 10, 165, 26, DT_CENTER, oFont)
   oPrinter:Line(45, 30, 170, 30)
   oPrinter:Line(45, 5, 45, 30)
   oPrinter:Line(170, 5, 170, 30)
   oPrinter:Say("----------", 50, 120, 150, 132, DT_CENTER)
   oPrinter:Box(50, 134, 160, 146)
   oPrinter:Say("End Of Report", 50, 135, 160, 146, DT_CENTER)
   oPrinter:EndPage()
   oPrinter:StartPage()
   oPrinter:SetFont(oFont)
   oPrinter:Box(5, 5, oPrinter:nWidth - 5, oPrinter:nHeight - 5)
   oPrinter:SetTextColor(2755990)
   oPrinter:Say("Printing second sample !", 50, 10, 185, 26, DT_CENTER, oFont)
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

FUNCTION DialogFromPrg(o)

   LOCAL cTitle := "Dialog from prg"
   LOCAL cText := "Input something"
   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL cRes
   LOCAL aCombo := {"First", "Second"}
   LOCAL oEdit
   LOCAL vard := "Monday"
   // LOCAL aTabs := {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday"}

   // o:bGetFocus := NIL
   INIT DIALOG oModDlg TITLE cTitle           ;
   AT 210, 10 SIZE 300, 300                    ;
   FONT oFont                                 ;
   ON EXIT {||hwg_MsgYesNo("Really exit ?")}

   @ 20, 10 SAY cText SIZE 260, 22
   @ 20, 35 EDITBOX oEdit CAPTION ""    ;
        STYLE WS_DLGFRAME              ;
        SIZE 260, 26 COLOR hwg_VColor("FF0000")

   @ 20, 70 CHECKBOX "Check 1" SIZE 90, 20
   @ 20, 95 CHECKBOX "Check 2"  ;
        SIZE 90, 20 COLOR IIf(nColor == NIL, hwg_VColor("0000FF"), nColor)

   @ 160, 70 GROUPBOX "RadioGroup" SIZE 130, 75

   RADIOGROUP
   @ 180, 90 RADIOBUTTON "Radio 1"  ;
        SIZE 90, 20 ON CLICK {||oEdit:SetColor(hwg_VColor("0000FF"),, .T.)}
   @ 180, 115 RADIOBUTTON "Radio 2" ;
        SIZE 90, 20 ON CLICK {||oEdit:SetColor(hwg_VColor("FF0000"),, .T.)}
   END RADIOGROUP SELECTED 2

   @ 20, 120 COMBOBOX aCombo STYLE WS_TABSTOP ;
        SIZE 120, 24

   @ 20, 160 UPDOWN 10 RANGE - 10, 50 SIZE 50, 32 STYLE WS_BORDER

   @ 160, 150 TAB oTab ITEMS {} SIZE 130, 66
   BEGIN PAGE "Monday" OF oTab
      @ 20, 34 GET vard SIZE 80, 22 STYLE WS_BORDER
   END PAGE OF oTab
   BEGIN PAGE "Tuesday" OF oTab
      @ 20, 34 EDITBOX "" SIZE 80, 22 STYLE WS_BORDER
   END PAGE OF oTab

   @ 100, 220 LINE LENGTH 100

   @ 20, 240 BUTTON "Ok" OF oModDlg ID IDOK  ;
        SIZE 100, 32 COLOR hwg_VColor("FF0000")
   @ 140, 240 BUTTON "11" OF oModDlg  ;
        SIZE 20, 32 ON CLICK {|o|CreateC(o)}
   @ 180, 240 BUTTON "Cancel" OF oModDlg ID IDCANCEL  ;
        SIZE 100, 32

   ACTIVATE DIALOG oModDlg
   oFont:Release()

RETURN NIL

#define DTM_SETFORMAT       4101

STATIC FUNCTION CreateC(oDlg)

   STATIC lFirst := .F.
   STATIC o

   IF !lFirst
      @ 50, 200 DATEPICKER o SIZE 80, 24
      lFirst := .T.
   ENDIF
   hwg_SendMessage(o:handle, DTM_SETFORMAT, 0, "dd':'MM':'yyyy")

RETURN NIL

FUNCTION Sendemail(endereco)

hwg_ShellExecute("rundll32.exe", "open", ;
            "url.dll,FileProtocolHandler " + ;
            "mailto:" + endereco + "?cc=&bcc=" + ;
            "&subject=Ref%20:" + ;
            "&body=This%20is%20test%20.", , 1)

FUNCTION TestTab()

   LOCAL oDlg
   LOCAL oTAB
   LOCAL oGet1
   LOCAL oGet2
   LOCAL oVar1 := "1"
   LOCAL oVar2 := "2"
   LOCAL oGet3
   LOCAL oGet4
   LOCAL oVar3 := "3"
   LOCAL oVar4 := "4"
   LOCAL oGet5
   LOCAL oVar5 := "5"

INIT DIALOG oDlg CLIPPER NOEXIT AT 0, 0 SIZE 200, 200

@ 10, 10 TAB oTab ITEMS {} SIZE 180, 180 ;
   ON LOSTFOCUS {||hwg_MsgInfo("Lost Focus")};
   ON INIT {||hwg_SetFocus(oDlg:getlist[1]:handle)}

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

FUNCTION ActiveTopMost(nHandle, lActive)
    
    IF lActive
       lSucess := hwg_SetTopMost(nHandle)    // Set TopMost
    ELSE
       lSucess := hwg_RemoveTopMost(nHandle) // Remove TopMost
    ENDIF

RETURN lSucess

FUNCTION TestProgres()

   LOCAL oDlg
   LOCAL ostatus
   LOCAL oBar
   LOCAL cRes
   LOCAL aCombo := {"First", "Second"}

   PRIVATE oProg

INIT DIALOG oDlg TITLE "Progress Bar"    ;
   AT 190, 10 SIZE 360, 240               

@ 10, 10 PROGRESSBAR oProg  ;
             OF oDlg        ;
             SIZE 200, 25    ;
             BARWIDTH 10    ;
             QUANTITY 1000
ADD STATUS oStatus TO oDlg PARTS 400
oBar := HProgressBar():New(ostatus, , 0, 2, 200, 20, 200, 1000, hwg_RGB(12, 143, 243), hwg_RGB(243, 132, 143))
oCombo := HComboBox():New(ostatus, , , , 65536, 0, 2, 200, 20, aCombo, , , , , , , .F., .F., , ,)
@ 10, 60  BUTTON "Test" SIZE 100, 32 ON CLICK {||MudeProg(oBar)}
   
   oDlg:Activate() 

FUNCTION MudeProg(ostatus)

   LOCAL ct := 1

   DO WHILE ct < 1001
      oProg:Step()
      ostatus:Step()
      ++ct
   ENDDO

RETURN NIL

FUNCTION RRectangle()

   LOCAL oDlg
   LOCAL oR1
   LOCAL oR2
   LOCAL oR3

INIT DIALOG oDlg TITLE "Sample HRect"    ;
   AT 190, 10 SIZE 600, 400

       @ 230, 10, 400, 100 RECT oR1 of oDlg PRESS
       @ 10, 10, 200, 100 RECT oR2 of oDlg RECT_STYLE 3
       @ 10, 130, 100, 230 RECT oR3 of oDlg PRESS RECT_STYLE 2

       hwg_Rect(oDlg, 10, 250, 590, 320, , 1)

   oDlg:Activate()

RETURN NIL
