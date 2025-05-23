//
// HWGUI - Harbour Win32 and Linux (GTK) GUI library
// dbview.prg - dbf browsing sample
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "hwgui.ch"
#include "gtk.ch"

REQUEST HB_CODEPAGE_RU866
REQUEST HB_CODEPAGE_RUKOI8
//REQUEST HB_CODEPAGE_RU1251

REQUEST DBFCDX
REQUEST DBFFPT

REQUEST ORDKEYNO
REQUEST ORDKEYCOUNT

STATIC aFieldTypes := {"C", "N", "D", "L"}
STATIC dbv_cLocate
STATIC dbv_nRec
STATIC dbv_cSeek

FUNCTION Main()

   LOCAL oWndMain
   LOCAL oPanel

   MEMVAR oBrw
   MEMVAR oFont

   PRIVATE oBrw
   PRIVATE oSay1
   PRIVATE oSay2
   PRIVATE oFont
   PRIVATE DataCP
   PRIVATE currentCP
   PRIVATE currFname

   RDDSETDEFAULT("DBFCDX")

   oFont := HFont():Add("Courier", 0, -14)
   INIT WINDOW oWndMain MAIN TITLE "Dbf browse" AT 200, 100 SIZE 300, 300

   MENU OF oWndMain
     MENU TITLE "&File"
       MENUITEM "&Open" ACTION FileOpen()
       SEPARATOR
       MENUITEM "&Exit" ACTION oWndMain:Close()
     ENDMENU
     MENU TITLE "&Index" ID 31010
       MENUITEM "&Select order" ACTION SelectIndex()
       MENUITEM "&New order" ACTION NewIndex()
       MENUITEM "&Open index file" ACTION OpenIndex()
       SEPARATOR
       MENUITEM "&Reindex all" ACTION ReIndex()
       SEPARATOR
       MENUITEM "&Close all indexes" ACTION CloseIndex()
     ENDMENU
     MENU TITLE "&Structure" ID 31020
       MENUITEM "&Modify structure" ACTION ModiStru(.F.)
     ENDMENU
     MENU TITLE "&Move" ID 31030
       MENUITEM "&Go To" ACTION dbv_Goto()
       MENUITEM "&Seek" ACTION dbv_Seek()
       MENUITEM "&Locate" ACTION dbv_Locate()
       MENUITEM "&Continue" ACTION dbv_Continue()
     ENDMENU
     MENU TITLE "&Command" ID 31040
       MENUITEM "&Delete record" ACTION dbv_DelRec()
       MENUITEM "&Pack" ACTION dbv_Pack()
       MENUITEM "&Zap" ACTION dbv_Zap()
     ENDMENU
     MENU TITLE "&View"
       MENUITEM "&Font" ACTION ChangeFont()
       MENU TITLE "&Local codepage"
          MENUITEMCHECK "EN" ACTION hb_SetCodepage("EN")
          MENUITEMCHECK "RUKOI8" ACTION hb_SetCodepage("RUKOI8")
          MENUITEMCHECK "RU1251" ACTION hb_SetCodepage("RU1251")
       ENDMENU
       MENU TITLE "&Data's codepage"
          MENUITEMCHECK "EN" ACTION SetDataCP("EN")
          MENUITEMCHECK "RUKOI8" ACTION SetDataCP("RUKOI8")
          MENUITEMCHECK "RU1251" ACTION SetDataCP("RU1251")
          MENUITEMCHECK "RU866"  ACTION SetDataCP("RU866")
       ENDMENU
     ENDMENU
     MENU TITLE "&Help"
       MENUITEM "&About" ACTION hwg_MsgInfo("Dbf Files Browser" + Chr(10) + "2005")
     ENDMENU
   ENDMENU

   @ 0, 0 BROWSE oBrw                 ;
      SIZE 300, 272                   ;
      STYLE WS_VSCROLL + WS_HSCROLL  ;
      FONT oFont                     ;
      ON SIZE {|o, x, y|o:Move(, , x - 1, y - 28)}

   oBrw:bScrollPos := {|o, n, lEof, nPos|hwg_VScrollPos(o, n, lEof, nPos)}

   @ 0, 272 PANEL oPanel SIZE 0, 26 ON SIZE {|o, x, y|o:Move(0, y - 26, x - 1, y - 8)}
   @ 5, 4 SAY oSay1 CAPTION "" OF oPanel SIZE 150, 22 FONT oFont
   @ 160, 4 SAY oSay2 CAPTION "" OF oPanel SIZE 100, 22 FONT oFont

   hwg_EnableMenuItem(, 31010, .F.)
   hwg_EnableMenuItem(, 31020, .F.)
   hwg_EnableMenuItem(, 31030, .F.)
   hwg_EnableMenuItem(, 31040, .F.)

   ACTIVATE WINDOW oWndMain

RETURN NIL

STATIC FUNCTION FileOpen()

   LOCAL mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
   LOCAL fname := hwg_SelectFile("xBase files( *.dbf )", "*.dbf", mypath)

   MEMVAR oBrw
   MEMVAR oSay1
   MEMVAR oSay2
   MEMVAR DataCP
   MEMVAR currentCP
   MEMVAR currFname

   IF !Empty(fname)
      close all

      IF DataCP != NIL
         use (fname) new codepage (DataCP)
         currentCP := DataCP
      ELSE
         use (fname) new
      ENDIF
      currFname := hwg_CutExten(fname)

      oBrw:InitBrw(2)
      oBrw:active := .F.
      hwg_CreateList(oBrw, .T.)
      oBrw:InsColumn(HColumn():New("*", {||IIf(Deleted(), "*", " ")}, "C", 1, 0), 1)
      oBrw:active := .T.
      oBrw:Refresh()
      oSay1:SetValue("Records: " + LTrim(Str(Eval(oBrw:bRcou, oBrw))))
      oSay2:SetValue("")
      dbv_cLocate := dbv_cSeek := ""
      dbv_nRec := 0
      
      hwg_EnableMenuItem(, 31010, .T.)
      hwg_EnableMenuItem(, 31020, .T.)
      hwg_EnableMenuItem(, 31030, .T.)
      hwg_EnableMenuItem(, 31040, .T.)

   ENDIF
   
RETURN NIL

STATIC FUNCTION ChangeFont()

   LOCAL oBrwFont

   MEMVAR oBrw
   MEMVAR oFont

   IF (oBrwFont := HFont():Select(oFont)) != NIL

      oFont := oBrwFont
      oBrw:oFont := oFont
      oBrw:ReFresh()
   ENDIF

RETURN NIL

STATIC FUNCTION SetDataCP(cp)

   MEMVAR DataCP

   DataCP := cp

RETURN NIL

STATIC FUNCTION SelectIndex()

   LOCAL aIndex := {{"None", "   ", "   "}}
   LOCAL i
   LOCAL indname
   LOCAL iLen := 0
   LOCAL oDlg
   LOCAL oBrowse
   LOCAL width
   LOCAL height
   LOCAL nChoice := 0
   LOCAL nOrder := OrdNumber() + 1

   MEMVAR oBrw
   MEMVAR oFont

   IF Len(oBrw:aColumns) == 0
      RETURN NIL
   ENDIF

   i := 1
   DO WHILE !Empty(indname := ORDNAME(i))
      AAdd(aIndex, {indname, ORDKEY(i), ORDBAGNAME(i)})
      iLen := Max(iLen, Len(OrdKey(i)))
      i ++
   ENDDO

   width := Min(oBrw:width * (iLen + 20), hwg_GetDesktopWidth())
   height := oBrw:height * (Len(aIndex) + 2)

   INIT DIALOG oDlg TITLE "Select Order" ;
         AT 0, 0                  ;
         SIZE width + 2, height + 2   ;
         FONT oFont

   @ 0, 0 BROWSE oBrowse ARRAY       ;
       SIZE width, height            ;
       FONT oFont                   ;
       STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL ;
       ON SIZE {|o, x, y|o:Move(, , x, y)} ;
       ON CLICK {|o|nChoice := o:nCurrent, EndDialog(o:oParent:handle)}

   oBrowse:aArray := aIndex
   oBrowse:AddColumn(HColumn():New("OrdName", {|v, o|o:aArray[o:nCurrent, 1]}, "C", 10, 0))
   oBrowse:AddColumn(HColumn():New("Order key", {|v, o|o:aArray[o:nCurrent, 2]}, "C", Max(iLen, 12), 0))
   oBrowse:AddColumn(HColumn():New("Filename", {|v, o|o:aArray[o:nCurrent, 3]}, "C", 10, 0))

   oBrowse:rowPos := nOrder
   Eval(oBrowse:bGoTo, oBrowse, nOrder)

   oDlg:Activate()

   IF nChoice > 0
      nChoice --
      Set Order To nChoice
      UpdBrowse()
   ENDIF

RETURN NIL

STATIC FUNCTION NewIndex()

   LOCAL oDlg
   LOCAL of := HFont():Add("Courier", 0, -12)
   LOCAL cName := ""
   LOCAL lMulti := .T.
   LOCAL lUniq := .F.
   LOCAL cTag := ""
   LOCAL cExpr := ""
   LOCAL cCond := ""
   LOCAL oMsg

   MEMVAR oBrw

   IF Len(oBrw:aColumns) == 0
      RETURN NIL
   ENDIF

   INIT DIALOG oDlg TITLE "Create Order" ;
         AT 0, 0         ;
         SIZE 300, 250   ;
         FONT of

   @ 10, 10 SAY "Order name:" SIZE 100, 22
   @ 110, 1 GET cName SIZE 100, 24

   @ 10, 40 GET CHECKBOX lMulti CAPTION "Multibag" SIZE 100, 22
   @ 110, 40 GET cTag SIZE 100, 24

   @ 10, 65 GET CHECKBOX lUniq CAPTION "Unique" SIZE 100, 22

   @ 10, 85 SAY "Expression:" SIZE 100, 22
   @ 10, 107 GET cExpr SIZE 280, 24

   @ 10, 135 SAY "Condition:" SIZE 100, 22
   @ 10, 157 GET cCond SIZE 280, 24

   @  30, 210  BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDlg:lResult := .T., EndDialog()}
   @ 170, 210 BUTTON "Cancel" SIZE 100, 32 ON CLICK {||EndDialog()}

   oDlg:Activate()

   IF oDlg:lResult
      IF !Empty(cName) .AND. (!Empty(cTag) .OR. !lMulti) .AND. ;
            !Empty(cExpr)
         oMsg = DlgWait("Indexing")
         IF lMulti
            IF Empty(cCond)
               ORDCREATE(RTrim(cName), RTrim(cTag), RTrim(cExpr), &("{||" + RTrim(cExpr) + "}"), IIf(lUniq, .T., NIL))
            ELSE
               ordCondSet(RTrim(cCond), &("{||" + RTrim(cCond) + "}"),,,,, RecNo(),,,,)
               ORDCREATE(RTrim(cName), RTrim(cTag), RTrim(cExpr), &("{||" + RTrim(cExpr) + "}"), IIf(lUniq, .T., NIL))
            ENDIF
         ELSE
            IF Empty(cCond)
               dbCreateIndex(RTrim(cName), RTrim(cExpr),&("{||" + RTrim(cExpr) + "}"), IIf(lUniq, .T., NIL))
            ELSE
               ordCondSet(RTrim(cCond), &("{||" + RTrim(cCond) + "}"),,,,, RecNo(),,,,)
               ORDCREATE(RTrim(cName), RTrim(cTag), RTrim(cExpr), &("{||" + RTrim(cExpr) + "}"), IIf(lUniq, .T., NIL))
            ENDIF
         ENDIF
         oMsg:Close()
      ELSE
         hwg_MsgStop("Fill necessary fields")
      ENDIF
   ENDIF
   
RETURN NIL

STATIC FUNCTION OpenIndex()

   LOCAL mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
   LOCAL fname := hwg_SelectFile("index files( *.cdx )", "*.cdx", mypath)

   MEMVAR oBrw

   IF Len(oBrw:aColumns) == 0
      RETURN NIL
   ENDIF

   IF !Empty(fname)
      Set Index To (fname)
      UpdBrowse()
   ENDIF

RETURN NIL

STATIC FUNCTION ReIndex()

   LOCAL oMsg

   MEMVAR oBrw

   IF Len(oBrw:aColumns) == 0
      RETURN NIL
   ENDIF

   oMsg = DlgWait("Reindexing")
   REINDEX
   oMsg:Close()
   oBrw:Refresh()

RETURN NIL

STATIC FUNCTION CloseIndex()

   MEMVAR oBrw

   IF Len(oBrw:aColumns) == 0
      RETURN NIL
   ENDIF

   OrdListClear()
   Set Order To 0
   UpdBrowse()

RETURN NIL

STATIC FUNCTION UpdBrowse()

   MEMVAR oBrw
   MEMVAR oSay1

   IF OrdNumber() == 0
      oBrw:bRcou := &("{||" + oBrw:alias + "->(RECCOUNT())}")
      oBrw:bRecnoLog := &("{||" + oBrw:alias + "->(RECNO())}")
   ELSE
      oBrw:bRcou := &("{||" + oBrw:alias + "->(ORDKEYCOUNT())}")
      oBrw:bRecnoLog := &("{||" + oBrw:alias + "->(ORDKEYNO())}")
   ENDIF
   oBrw:Refresh()
   oSay1:SetValue("Records: " + LTrim(Str(Eval(oBrw:bRcou, oBrw))))
   oSay2:SetValue("")

RETURN NIL

STATIC FUNCTION DlgWait(cTitle)

   LOCAL oDlg

   INIT DIALOG oDlg TITLE cTitle ;
         AT 0, 0                  ;
         SIZE 100, 50 STYLE DS_CENTER

   @ 10, 20 SAY "Wait, please ..." SIZE 80, 22

   ACTIVATE DIALOG oDlg NOMODAL

RETURN oDlg

STATIC FUNCTION ModiStru(lNew)

   LOCAL oDlg
   LOCAL oBrowse
   LOCAL of := HFont():Add("Courier", 0, -12)
   LOCAL oMsg
   LOCAL oGet1
   LOCAL oGet2
   LOCAL oGet3
   LOCAL oGet4
   LOCAL af
   LOCAL af0
   LOCAL cName := ""
   LOCAL nType := 1
   LOCAL cLen := "0"
   LOCAL cDec := "0"
   LOCAL i
   LOCAL aTypes := {"Character", "Numeric", "Date", "Logical"}
   LOCAL fname
   LOCAL cAlias
   LOCAL nRec
   LOCAL nOrd
   LOCAL lOverFlow := .F.
   LOCAL xValue

   MEMVAR oBrw
   MEMVAR currentCP
   MEMVAR currFname

   IF lNew
      af := {{"", "", 0, 0}}
   ELSE
      af0 := dbStruct()
      af := dbStruct()
      FOR i := 1 TO Len(af)
         AAdd(af[i], i)
      NEXT
   ENDIF

   INIT DIALOG oDlg TITLE "Modify structure" ;
         AT 0, 0                  ;
         SIZE 400, 330            ;
         FONT of

   @ 10, 10 BROWSE oBrowse ARRAY  ;
       SIZE 250, 200              ;
       STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL ;
       ON POSCHANGE {|o|brw_onPosChg(o, oGet1, oGet2, oGet3, oGet4)}

   oBrowse:aArray := af
   oBrowse:AddColumn(HColumn():New("Name", {|v, o|o:aArray[o:nCurrent, 1]}, "C", 10, 0))
   oBrowse:AddColumn(HColumn():New("Type", {|v, o|o:aArray[o:nCurrent, 2]}, "C", 1, 0))
   oBrowse:AddColumn(HColumn():New("Length", {|v, o|o:aArray[o:nCurrent, 3]}, "N", 5, 0))
   oBrowse:AddColumn(HColumn():New("Dec", {|v, o|o:aArray[o:nCurrent, 4]}, "N", 2, 0))

   @ 10, 230 GET oGet1 VAR cName SIZE 100, 24
   @ 120, 230 GET COMBOBOX oGet2 VAR nType ITEMS aTypes SIZE 100, 24
   @ 230, 230 GET oGet3 VAR cLen SIZE 50, 24
   @ 290, 230 GET oGet4 VAR cDec SIZE 40, 24

   @ 20, 270 BUTTON "Add" SIZE 80, 30 ON CLICK {||UpdStru(oBrowse, oGet1, oGet2, oGet3, oGet4, 1)}
   @ 110, 270 BUTTON "Insert" SIZE 80, 30 ON CLICK {||UpdStru(oBrowse, oGet1, oGet2, oGet3, oGet4, 2)}
   @ 200, 270 BUTTON "Change" SIZE 80, 30 ON CLICK {||UpdStru(oBrowse, oGet1, oGet2, oGet3, oGet4, 3)}
   @ 290, 270 BUTTON "Remove" SIZE 80, 30 ON CLICK {||UpdStru(oBrowse, oGet1, oGet2, oGet3, oGet4, 4)}

   @ 280, 10  BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDlg:lResult := .T., EndDialog()}
   @ 280, 50 BUTTON "Cancel" SIZE 100, 32 ON CLICK {||EndDialog()}

   ACTIVATE DIALOG oDlg

   IF oDlg:lResult

      oMsg = DlgWait("Restructuring")
      cAlias := Alias()
      nOrd := ordNumber()
      nRec := RecNo()
      SET ORDER TO 0
      GO TOP

      fname := "a0_new"
      dbCreate(fname, af)
      IF currentCP != NIL
         use (fname) new codepage (currentCP)
      ELSE
         use (fname) new
      ENDIF
      dbSelectArea(cAlias)

      DO WHILE !Eof()
         dbSelectArea(fname)
         APPEND BLANK
         FOR i := 1 TO Len(af)
            IF Len(af[i]) > 4
               xValue := (cAlias)->(FieldGet(af[i, 5]))
               IF af[i, 2] == af0[af[i, 5], 2] .AND. af[i, 3] == af0[af[i, 5], 3]
                  FieldPut(i, xValue)
               ELSE
                  IF af[i, 2] != af0[af[i, 5], 2]
                     IF af[i, 2] == "C" .AND. af0[af[i, 5], 2] == "N"
                        xValue := Str(xValue, af0[af[i, 5], 3], af0[af[i, 5], 4])
                     ELSEIF af[i, 2] == "N" .AND. af0[af[i, 5], 2] == "C"
                        xValue := Val(LTrim(xValue))
                     ELSE
                        LOOP
                     ENDIF
                  ENDIF
                  IF af[i, 3] >= af0[af[i, 5], 3]
                     FieldPut(i, xValue)
                  ELSE
                     IF af[i, 2] == "C"
                        FieldPut(i, Left(xValue, af[i, 3]))
                     ELSEIF af[i, 2] == "N"
                        FieldPut(i, 0)
                        lOverFlow := .T.
                     ENDIF
                  ENDIF
               ENDIF
            ENDIF
         NEXT
         IF (cAlias)->(Deleted())
            DELETE
         ENDIF
         dbSelectArea(cAlias)
         SKIP
      ENDDO
      IF lOverFlow
         hwg_MsgInfo("There was overflow in Numeric field", "Warning!")
      ENDIF

      Close All
      Ferase(currFname + ".bak")
      Frename(currFname + ".dbf", currFname + ".bak")
      Frename("a0_new.dbf", currFname + ".dbf")
      IF File("a0_new.fpt")
         Frename("a0_new.fpt", currFname + ".fpt")
      ENDIF

      IF currentCP != NIL
         use (currFname) new codepage (currentCP)
      ELSE
         use (currFname) new
      ENDIF
      REINDEX

      GO nRec
      SET ORDER TO nOrd
      oMsg:Close()
      oBrw:Refresh()

   ENDIF

RETURN NIL

STATIC FUNCTION brw_onPosChg(oBrowse, oGet1, oGet2, oGet3, oGet4)

   oGet1:SetGet(oBrowse:aArray[oBrowse:nCurrent, 1])
   oGet1:Refresh()

   oGet2:SetItem(AScan(aFieldTypes, oBrowse:aArray[oBrowse:nCurrent, 2]))

   oGet3:SetGet(LTrim(Str(oBrowse:aArray[oBrowse:nCurrent, 3])))
   oGet3:Refresh()

   oGet4:SetGet(LTrim(Str(oBrowse:aArray[oBrowse:nCurrent, 4])))
   oGet4:Refresh()

RETURN NIL

STATIC FUNCTION UpdStru(oBrowse, oGet1, oGet2, oGet3, oGet4, nOperation)

   LOCAL cName
   LOCAL cType
   LOCAL nLen
   LOCAL nDec

   IF nOperation == 4
      Adel(oBrowse:aArray, oBrowse:nCurrent)
      Asize(oBrowse:aArray, Len(oBrowse:aArray) - 1)
      IF oBrowse:nCurrent < Len(oBrowse:aArray) .AND. oBrowse:nCurrent > 1
         oBrowse:nCurrent --
      ENDIF
   ELSE
      cName := oGet1:SetGet()
      cType := aFieldTypes[Eval(oGet2:bSetGet, , oGet2)]
      nLen := Val(oGet3:SetGet())
      nDec := Val(oGet4:SetGet())
      IF nOperation == 1
         AAdd(oBrowse:aArray, {cName, cType, nLen, nDec})
      ELSE
         IF nOperation == 2
            AAdd(oBrowse:aArray, NIL)
            Ains(oBrowse:aArray, oBrowse:nCurrent)
         ENDIF
         oBrowse:aArray[oBrowse:nCurrent, 1] := cName
         oBrowse:aArray[oBrowse:nCurrent, 2] := cType
         oBrowse:aArray[oBrowse:nCurrent, 3] := nLen
         oBrowse:aArray[oBrowse:nCurrent, 4] := nDec
      ENDIF
   ENDIF
   oBrowse:Refresh()

RETURN NIL

STATIC FUNCTION dbv_Goto()

   LOCAL nRec := Val(GetData(LTrim(Str(dbv_nRec)), "Go to ...", "Input record number:"))

   MEMVAR oBrw

   IF nRec != 0
      dbv_nRec := nRec
      dbGoTo(nRec)
      IF EVAL(oBrw:bEof, oBrw)
         EVAL(oBrw:bGoBot, oBrw)
      ENDIF
      oBrw:Refresh()
      Eval(oBrw:bScrollPos, oBrw, 0)
   ENDIF

RETURN NIL

STATIC FUNCTION dbv_Seek()

   LOCAL cKey
   LOCAL nRec

   MEMVAR oBrw
   MEMVAR oSay2

   IF OrdNumber() == 0
      hwg_MsgStop("No active order !", "Seek record")
   ELSE
      cKey := GetData(dbv_cSeek, "Seek record", "Input key:")
      IF !Empty(cKey)
         dbv_cSeek := cKey
         nRec := Eval(oBrw:bRecNo, oBrw)
         IF dbSeek(cKey)
            oSay2:SetValue("Found")
            oBrw:Refresh()
            Eval(oBrw:bScrollPos, oBrw, 0)
         ELSE
            oSay2:SetValue("Not Found")
            Eval(oBrw:bGoTo, oBrw, nRec)
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION dbv_Locate()

   LOCAL cLocate := dbv_cLocate
   LOCAL bOldError
   LOCAL cType
   LOCAL nRec

   MEMVAR oBrw
   MEMVAR oSay2

   DO WHILE .T.

      cLocate := GetData(cLocate, "Locate", "Input condition:")
      IF Empty(cLocate)
         RETURN NIL
      ENDIF

      bOldError := ErrorBlock({|e|MacroError(e)})
      BEGIN SEQUENCE
         cType := ValType(&cLocate)
      RECOVER
         ErrorBlock(bOldError)
         LOOP
      END SEQUENCE
      ErrorBlock(bOldError)

      IF cType != "L"
         hwg_MsgStop("Wrong expression")
      ELSE
         EXIT
      ENDIF
   ENDDO

   dbv_cLocate := cLocate
   nRec := Eval(oBrw:bRecNo, oBrw)
   LOCATE FOR &cLocate
   IF Found()
      oSay2:SetValue("Found")
      oBrw:Refresh()
      Eval(oBrw:bScrollPos, oBrw, 0)
   ELSE
      oSay2:SetValue("Not Found")
      Eval(oBrw:bGoTo, oBrw, nRec)
   ENDIF

RETURN NIL

STATIC FUNCTION dbv_Continue()

   LOCAL nRec

   MEMVAR oBrw
   MEMVAR oSay2

   IF !Empty(dbv_cLocate)
      nRec := Eval(oBrw:bRecNo, oBrw)
      CONTINUE
      IF Found()
         oSay2:SetValue("Found")
         oBrw:Refresh()
         Eval(oBrw:bScrollPos, oBrw, 0)
      ELSE
         oSay2:SetValue("Not Found")
         Eval(oBrw:bGoTo, oBrw, nRec)
      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION GetData(cRes, cTitle, cText)

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)

   INIT DIALOG oModDlg TITLE cTitle AT 0, 0 SIZE 300, 140 ;
        FONT oFont CLIPPER STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + DS_CENTER

   @ 20, 10 SAY cText SIZE 260, 22
   @ 20, 35 GET cres SIZE 260, 26

   @ 20, 95 BUTTON "Ok" ID IDOK SIZE 100, 32
   @ 180, 95 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oModDlg

   oFont:Release()
   IF oModDlg:lResult
      RETURN Trim(cRes)
   ELSE
      cRes := ""
   ENDIF

RETURN cRes

STATIC FUNCTION MacroError(e)

   hwg_MsgStop(hwg_ErrorMessage(e), "Expression error")
   BREAK

RETURN .T.

STATIC FUNCTION dbv_Pack()

   LOCAL oMsg
   LOCAL cTitle := "Packing database"

   MEMVAR oBrw
   MEMVAR oSay1
   MEMVAR oSay2

   IF hwg_MsgYesNo("Are you really want it ?", cTitle)
      oMsg = DlgWait(cTitle)
      PACK
      oMsg:Close()
      oBrw:Refresh()
      Eval(oBrw:bScrollPos, oBrw, 0)
      oSay1:SetValue("Records: " + LTrim(Str(Eval(oBrw:bRcou, oBrw))))
      oSay2:SetValue("")
   ENDIF

RETURN NIL

STATIC FUNCTION dbv_Zap()

   LOCAL oMsg
   LOCAL cTitle := "Zap database"

   MEMVAR oBrw
   MEMVAR oSay1
   MEMVAR oSay2

   IF hwg_MsgYesNo("ALL DATA WILL BE LOST !!! Are you really want it ?", cTitle)
      oMsg = DlgWait(cTitle)
      ZAP
      oMsg:Close()
      oBrw:Refresh()
      Eval(oBrw:bScrollPos, oBrw, 0)
      oSay1:SetValue("Records: " + LTrim(Str(Eval(oBrw:bRcou, oBrw))))
      oSay2:SetValue("")
   ENDIF

RETURN NIL

STATIC FUNCTION dbv_DelRec()

   MEMVAR oBrw

   IF !Empty(Alias())
      IF Deleted()
         RECALL
      ELSE
         DELETE
      ENDIF
      oBrw:RefreshLine()
   ENDIF

RETURN NIL
