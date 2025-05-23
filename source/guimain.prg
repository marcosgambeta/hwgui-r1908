//
// HWGUI - Harbour Win32 GUI library source code:
// Main prg level functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <common.ch>
#include "hwgui.ch"

#ifdef __XHARBOUR__
   #xtranslate hb_processOpen([<x,...>])   => hb_openProcess(<x>)
   #xtranslate hb_NumToHex([<n,...>])      => NumToHex(<n>)
#endif

//STATIC _winwait (variable not used)

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_InitObjects(oWnd)

   LOCAL i
   LOCAL pArray := oWnd:aObjects
   LOCAL LoadArray := HObject():aObjects

   IF !Empty(LoadArray)
      FOR i := 1 TO Len(LoadArray)
         IF !Empty(oWnd:handle)
            IF __ObjHasMsg(LoadArray[i], "INIT")
               LoadArray[i]:Init(oWnd)
               LoadArray[i]:lInit := .T.
            ENDIF
         ENDIF
      NEXT
   ENDIF
   IF pArray != NIL
      FOR i := 1 TO Len(pArray)
         IF __ObjHasMsg(pArray[i], "INIT")
            pArray[i]:Init(oWnd)
         ENDIF
      NEXT
   ENDIF
   HObject():aObjects := {}

RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_InitControls(oWnd, lNoActivate)

   LOCAL i
   LOCAL pArray := oWnd:aControls
   LOCAL lInit

   lNoActivate := IIf(lNoActivate == NIL, .F., lNoActivate)

   IF pArray != NIL
      FOR i := 1 TO Len(pArray)
         // hwg_WriteLog("InitControl1" + Str(pArray[i]:handle) + "/" + pArray[i]:classname + " " + Str(pArray[i]:nWidth) + "/" + Str(pArray[i]:nHeight))
         IF Empty(pArray[i]:handle) .AND. !lNoActivate
//         IF Empty(pArray[i]:handle) .AND. !lNoActivate
            lInit := pArray[i]:lInit
            pArray[i]:lInit := .T.
            pArray[i]:Activate()
            pArray[i]:lInit := lInit
         ELSEIF !lNoActivate
            pArray[i]:lInit := .T.
         ENDIF
//           IF Empty(pArray[i]:handle)// <= 0
         IF IIf(hb_IsPointer(pArray[i]:handle), hwg_PtrToUlong(pArray[i]:handle), pArray[i]:handle) <= 0 // TODO: verificar
            pArray[i]:handle := hwg_GetDlgItem(oWnd:handle, pArray[i]:id)

            // hwg_WriteLog("InitControl2" + Str(pArray[i]:handle) + "/" + pArray[i]:classname)
         ENDIF
         IF !Empty(pArray[i]:aControls)
            hwg_InitControls(pArray[i])
         ENDIF
         pArray[i]:Init()
          // nando required to classes that inherit the class of patterns hwgui
         IF !pArray[i]:lInit
            pArray[i]:Super:Init()
         ENDIF
      NEXT
   ENDIF

RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_FindParent(hCtrl, nLevel) // TODO: static ?

   LOCAL i
   LOCAL oParent
   LOCAL hParent := hwg_GetParent(hCtrl)

   IF !Empty(hParent)
      IF (i := AScan(HDialog():aModalDialogs, {|o|o:handle == hParent})) != 0
         RETURN HDialog():aModalDialogs[i]
      ELSEIF (oParent := HDialog():FindDialog(hParent)) != NIL
         RETURN oParent
      ELSEIF (oParent := HWindow():FindWindow(hParent)) != NIL
         RETURN oParent
      ENDIF
   ENDIF
   IF nLevel == NIL
      nLevel := 0
   ENDIF
   IF nLevel < 2
      IF (oParent := hwg_FindParent(hParent, nLevel + 1)) != NIL
         RETURN oParent:FindControl(, hParent)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_FindSelf(hCtrl)

   LOCAL oParent

   oParent := hwg_FindParent(hCtrl)
   IF oParent == NIL
      oParent := hwg_GetAncestor(hCtrl, GA_PARENT)
   ENDIF
   IF oParent != NIL .AND. !hb_IsNumeric(oParent)
      RETURN oParent:FindControl(, hCtrl)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_WriteStatus(oWnd, nPart, cText, lRedraw)

   LOCAL aControls
   LOCAL i

   aControls := oWnd:aControls
   IF (i := AScan(aControls, {|o|o:ClassName() == "HSTATUS"})) > 0
      hwg_WriteStatusWindow(aControls[i]:handle, nPart - 1, cText)
      IF lRedraw != NIL .AND. lRedraw
         hwg_RedrawWindow(aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_ReadStatus(oWnd, nPart)

   LOCAL aControls
   LOCAL i
   LOCAL ntxtLen
   LOCAL cText := ""

   aControls := oWnd:aControls
   IF (i := AScan(aControls, {|o|o:ClassName() == "HSTATUS"})) > 0
      ntxtLen := hwg_SendMessage(aControls[i]:handle, SB_GETTEXTLENGTH, nPart - 1, 0)
      cText := Replicate(Chr(0), ntxtLen)
      hwg_SendMessage(aControls[i]:handle, SB_GETTEXT, nPart - 1, @cText)
   ENDIF

RETURN cText

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_VColor(cColor)

   LOCAL i
   LOCAL res := 0
   LOCAL n := 1
   LOCAL iValue

   cColor := Trim(cColor)
   FOR i := 1 TO Len(cColor)
      iValue := Asc(SubStr(cColor, Len(cColor) - i + 1, 1))
      IF iValue < 58 .AND. iValue > 47
         iValue -= 48
      ELSEIF iValue >= 65 .AND. iValue <= 70
         iValue -= 55
      ELSEIF iValue >= 97 .AND. iValue <= 102
         iValue -= 87
      ELSE
         RETURN 0
      ENDIF
      res += iValue * n
      n *= 16
   NEXT

RETURN res

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_MsgGet(cTitle, cText, nStyle, x, y, nDlgStyle, cResIni)

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL cRes := IIf(cResIni != NIL, Trim(cResIni), "")

   //IF !Empty(cRes)
   //   hwg_Keyb_Event(VK_END)
   //ENDIF
   nStyle := IIf(nStyle == NIL, 0, nStyle)
   x := IIf(x == NIL, 210, x)
   y := IIf(y == NIL, 10, y)
   nDlgStyle := IIf(nDlgStyle == NIL, 0, nDlgStyle)

   INIT DIALOG oModDlg TITLE cTitle At x, y SIZE 300, 140 FONT oFont CLIPPER ;
      STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + nDlgStyle

   @ 20, 10 SAY cText SIZE 260, 22
   #ifdef __SYGECOM__
   @ 20, 35 GET cRes  SIZE 260, 26 STYLE WS_TABSTOP + ES_AUTOHSCROLL + nStyle TOOLTIP "Pressione ESC para cancelar"
   #else
   @ 20, 35 GET cRes  SIZE 260, 26 STYLE WS_TABSTOP + ES_AUTOHSCROLL + nStyle
   #endif
   oModDlg:aControls[2]:Anchor := 11
   @ 20, 95 BUTTON "Ok" ID IDOK SIZE 100, 32
   @ 180, 95 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32
   oModDlg:aControls[4]:Anchor := 9

   ACTIVATE DIALOG oModDlg ON ACTIVATE {||IIf(!Empty(cRes), hwg_Keyb_Event(VK_END), .T.)}

   oFont:Release()
   IF oModDlg:lResult
      RETURN Trim(cRes)
   ELSE
      cRes := ""
   ENDIF

RETURN cRes

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_WaitRun(cRun)
//#ifdef __XHARBOUR__

   LOCAL hIn
   LOCAL hOut
   LOCAL nRet
   LOCAL hProc

   // "Launching process", cProc
   hProc := hb_processOpen(cRun, @hIn, @hOut, @hOut)

   // "Reading output"
   // "Waiting for process termination"
   nRet := HB_ProcessValue(hProc)

   FClose(hProc)
   FClose(hIn)
   FClose(hOut)

RETURN nRet
//#else
//  __Run(cRun)
//   RETURN 0
//#endif

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_WChoice(arr, cTitle, nLeft, nTop, oFont, clrT, clrB, clrTSel, clrBSel, cOk, cCancel)

   LOCAL oDlg
   LOCAL oBrw
   LOCAL nChoice := 0
   LOCAL lArray := .T.
   LOCAL nField
   LOCAL lNewFont := .F.
   LOCAL i
   LOCAL aLen
   LOCAL nLen := 0
   LOCAL addX := 20
   LOCAL addY := 20
   LOCAL minWidth := 0
   LOCAL x1
   LOCAL hDC
   LOCAL aMetr
   LOCAL width
   LOCAL height
   LOCAL aArea
   LOCAL aRect
   LOCAL nStyle := WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX

   IF cTitle == NIL
      cTitle := ""
   ENDIF
   IF nLeft == NIL .AND. nTop == NIL
      nStyle += DS_CENTER
   ENDIF
   IF nLeft == NIL
      nLeft := 0
   ENDIF
   IF nTop == NIL
      nTop := 0
   ENDIF
   IF oFont == NIL
      oFont := HFont():Add("MS Sans Serif", 0, -13)
      lNewFont := .T.
   ENDIF
   IF cOk != NIL
      minWidth += 120
      IF cCancel != NIL
         minWidth += 100
      ENDIF
      addY += 30
   ENDIF

   IF hb_IsChar(arr)
      lArray := .F.
      aLen := RecCount()
      IF (nField := FieldPos(arr)) == 0
         RETURN 0
      ENDIF
      nLen := dbFieldInfo(3, nField)
   ELSE
      aLen := Len(arr)
      IF hb_IsArray(arr[1])
         FOR i := 1 TO aLen
            nLen := Max(nLen, Len(arr[i, 1]))
         NEXT
      ELSE
         FOR i := 1 TO aLen
            nLen := Max(nLen, Len(arr[i]))
         NEXT
      ENDIF
   ENDIF

   hDC := hwg_GetDC(hwg_GetActiveWindow())
   hwg_SelectObject(hDC, oFont:handle)
   aMetr := hwg_GetTextMetric(hDC)
   aArea := hwg_GetDeviceArea(hDC)
   aRect := hwg_GetWindowRect(hwg_GetActiveWindow())
   hwg_ReleaseDC(hwg_GetActiveWindow(), hDC)
   height := (aMetr[1] + 1) * aLen + 4 + addY + 8
   IF height > aArea[2] - aRect[2] - nTop - 60
      height := aArea[2] - aRect[2] - nTop - 60
   ENDIF
   width := Max(aMetr[2] * 2 * nLen + addX, minWidth)

   INIT DIALOG oDlg TITLE cTitle ;
        At nLeft, nTop           ;
        SIZE width, height       ;
        STYLE nStyle            ;
        FONT oFont              ;
        ON INIT {|o|hwg_ResetWindowPos(o:handle), o:nInitFocus := oBrw}
       //ON INIT {|o|hwg_ResetWindowPos(o:handle), oBrw:setfocus()}
   IF lArray
      @ 0, 0 Browse oBrw Array
      oBrw:aArray := arr
      IF hb_IsArray(arr[1])
         oBrw:AddColumn(HColumn():New(, {|value, o|HB_SYMBOL_UNUSED(value), o:aArray[o:nCurrent, 1]}, "C", nLen))
      ELSE
         oBrw:AddColumn(HColumn():New(, {|value, o|HB_SYMBOL_UNUSED(value), o:aArray[o:nCurrent]}, "C", nLen))
      ENDIF
   ELSE
      @ 0, 0 Browse oBrw DATABASE
      oBrw:AddColumn(HColumn():New(, {|value, o|HB_SYMBOL_UNUSED(value), (o:Alias)->(FieldGet(nField))}, "C", nLen))
   ENDIF

   oBrw:oFont := oFont
   oBrw:bSize := {|o, x, y|hwg_MoveWindow(o:handle, addX / 2, 10, x - addX, y - addY)}
   oBrw:bEnter := {|o|nChoice := o:nCurrent, EndDialog(o:oParent:handle)}
   oBrw:bKeyDown := {|o, key|HB_SYMBOL_UNUSED(o), IIf(key == 27, (EndDialog(oDlg:handle), .F.), .T.)}

   oBrw:lDispHead := .F.
   IF clrT != NIL
      oBrw:tcolor := clrT
   ENDIF
   IF clrB != NIL
      oBrw:bcolor := clrB
   ENDIF
   IF clrTSel != NIL
      oBrw:tcolorSel := clrTSel
   ENDIF
   IF clrBSel != NIL
      oBrw:bcolorSel := clrBSel
   ENDIF

   IF cOk != NIL
      x1 := Int(width / 2) - IIf(cCancel != NIL, 90, 40)
      @ x1, height - 36 BUTTON cOk SIZE 80, 30 ON CLICK {||nChoice := oBrw:nCurrent, EndDialog(oDlg:handle)}
      IF cCancel != NIL
         @ x1 + 100, height - 36 BUTTON cCancel SIZE 80, 30 ON CLICK {||nChoice := 0, EndDialog(oDlg:handle)}
      ENDIF
   ENDIF

   ACTIVATE DIALOG oDlg
   IF lNewFont
      oFont:Release()
   ENDIF

RETURN nChoice

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_ShowProgress(nStep, maxPos, nRange, cTitle, oWnd, x1, y1, width, height)

   STATIC oDlg
   STATIC hPBar
   STATIC iCou
   STATIC nLimit

   LOCAL nStyle := WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX

   IF nStep == 0
      nLimit := IIf(nRange != NIL, Int(nRange / maxPos), 1)
      iCou := 0
      x1 := IIf(x1 == NIL, 0, x1)
      y1 := IIf(x1 == NIL, 0, y1)
      width := IIf(width == NIL, 220, width)
      height := IIf(height == NIL, 55, height)
      IF x1 == 0
         nStyle += DS_CENTER
      ENDIF
      IF oWnd != NIL
         oDlg := NIL
         hPBar := hwg_CreateProgressBar(oWnd:handle, maxPos, 20, 25, width - 40, 20)
      ELSE
         INIT DIALOG oDlg TITLE cTitle   ;
              At x1, y1 SIZE width, height ;
              STYLE nStyle               ;
              ON INIT {|o|hPBar := hwg_CreateProgressBar(o:handle, maxPos, 20, 25, width - 40, 20)}
         ACTIVATE DIALOG oDlg NOMODAL
      ENDIF
   ELSEIF nStep == 1
      iCou++
      IF iCou == nLimit
         iCou := 0
         hwg_UpdateProgressBar(hPBar)
      ENDIF
   ELSEIF nStep == 2
      hwg_UpdateProgressBar(hPBar)
   ELSEIF nStep == 3
      hwg_SetWindowText(oDlg:handle, cTitle)
      IF maxPos != NIL
         hwg_SetProgressBar(hPBar, maxPos)
      ENDIF
   ELSE
      hwg_DestroyWindow(hPBar)
      IF oDlg != NIL
         EndDialog(oDlg:handle)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_EndWindow()

   IF HWindow():GetMain() != NIL
      hwg_SendMessage(HWindow():aWindows[1]:handle, WM_SYSCOMMAND, SC_CLOSE, 0)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

// TODO: mover para outro arquivo .prg por não ter relação nenhuma com GUI
FUNCTION hwg_HdSerial(cDrive)

   LOCAL n := hwg_HDGetSerial(cDrive)
   LOCAL cHex := HB_NUMTOHEX(n)
   LOCAL cResult

   cResult := SubStr(cHex, 1, 4) + "-" + SubStr(cHex, 5, 4)

RETURN cResult

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_GetIni(cSection, cEntry, cDefault, cFile)
RETURN hwg_GetPrivateProfileString(cSection, cEntry, cDefault, cFile)

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_WriteIni(cSection, cEntry, cValue, cFile)
RETURN hwg_WritePrivateProfileString(cSection, cEntry, cValue, cFile)

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_SetHelpFileName(cNewName)

   STATIC cName := ""

   LOCAL cOldName := cName

   IF cNewName != NIL
      cName := cNewName
   ENDIF

RETURN cOldName

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_RefreshAllGets(oDlg)

   AEval(oDlg:GetList, {|o|o:Refresh()})

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

// cTitle:   Window Title
// cDescr:  'Data Bases','*.dbf'
// cTip  :   *.dbf
// cInitDir: Initial directory

FUNCTION hwg_SelectMultipleFiles(cDescr, cTip, cIniDir, cTitle)

   LOCAL aFiles
   LOCAL cPath
   LOCAL cFile
   LOCAL cFilter
   LOCAL nAt
   LOCAL hWnd := 0
   LOCAL nFlags := NIL
   LOCAL nIndex := 1

   cFilter := cDescr + Chr(0) + cTip + Chr(0)
   // initialize buffer with 0 bytes. Important is the 1-st character,
   // from MSDN:  The first character of this buffer must be NULL
   //             if initialization is not necessary
   cFile := repl(Chr(0), 32000)
   aFiles := {}

   cPath := hwg__GetOpenFileName(hWnd, @cFile, cTitle, cFilter, nFlags, cIniDir, NIL, @nIndex)

   nAt := At(Chr(0) + Chr(0), cFile)
   IF nAt != 0
      cFile := Left(cFile, nAt - 1)
      nAt := At(Chr(0), cFile)
      IF nAt != 0
         // skip path which is already in cPath variable
         cFile := SubStr(cFile, nAt + 1)
         // decode files
         DO WHILE !(cFile == "")
            nAt := At(Chr(0), cFile)
            IF nAt != 0
               AAdd(aFiles, cPath + hb_osPathSeparator() + Left(cFile, nAt - 1))
               cFile := SubStr(cFile, nAt + 1)
            ELSE
               AAdd(aFiles, cPath + hb_osPathSeparator() + cFile)
               EXIT
            ENDIF
         ENDDO
      ELSE
         // only single file selected
         AAdd(aFiles, cPath)
      ENDIF
   ENDIF

RETURN aFiles

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION HWG_Version(oTip)

   LOCAL oVersion

   IF oTip == 1
      oVersion := "HwGUI " + HWG_VERSION + " " + Version()
   ELSE
      oVersion := "HwGUI " + HWG_VERSION
   ENDIF

RETURN oVersion

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_TxtRect(cTxt, oWin, oFont)

   LOCAL hDC
   LOCAL ASize
   LOCAL hFont

   oFont := IIf(oFont != NIL, oFont, oWin:oFont)

   hDC := hwg_GetDC(oWin:handle)
   IF oFont == NIL .AND. oWin:oParent != NIL
      oFont := oWin:oParent:oFont
   ENDIF
   IF oFont != NIL
      hFont := hwg_SelectObject(hDC, oFont:handle)
   ENDIF
   ASize := hwg_GetTextSize(hDC, cTxt)
   IF oFont != NIL
      hwg_SelectObject(hDC, hFont)
   ENDIF
   hwg_ReleaseDC(oWin:handle, hDC)

RETURN ASize

//-------------------------------------------------------------------------------------------------------------------//

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(ENDWINDOW, HWG_ENDWINDOW);
HB_FUNC_TRANSLATE(VCOLOR, HWG_VCOLOR);
HB_FUNC_TRANSLATE(INITOBJETCS, HWG_INITOBJECTS);
HB_FUNC_TRANSLATE(INITCONTROLS, HWG_INITCONTROLS);
HB_FUNC_TRANSLATE(FINDPARENT, HWG_FINDPARENT);
HB_FUNC_TRANSLATE(FINDSELF, HWG_FINDSELF);
HB_FUNC_TRANSLATE(WRITESTATUS, HWG_WRITESTATUS);
HB_FUNC_TRANSLATE(READSTATUS, HWG_READSTATUS);
HB_FUNC_TRANSLATE(MSGGET, HWG_MSGGET);
HB_FUNC_TRANSLATE(WAITRUN, HWG_WAITRUN);
HB_FUNC_TRANSLATE(WCHOICE, HWG_WCHOICE);
HB_FUNC_TRANSLATE(SHOWPROGRESS, HWG_SHOWPROGRESS);
HB_FUNC_TRANSLATE(HDSERIAL, HWG_HDSERIAL);
HB_FUNC_TRANSLATE(SETHELPFILENAME, HWG_SETHELPFILENAME);
HB_FUNC_TRANSLATE(REFRESHALLGETS, HWG_REFRESHALLGETS);
HB_FUNC_TRANSLATE(SELECTMULTIPLEFILES, HWG_SELECTMULTIPLEFILES);
HB_FUNC_TRANSLATE(TXTRECT, HWG_TXTRECT);
#endif

#pragma ENDDUMP

//-------------------------------------------------------------------------------------------------------------------//
