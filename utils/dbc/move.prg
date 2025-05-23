//
// DBCHW - DBC ( Harbour + HWGUI )
// Move functions ( Locate, seek, ... )
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
#ifdef RDD_ADS
#include "ads.ch"
#endif

STATIC cLocate := "", cFilter := "", cSeek := ""
STATIC klrecf := 200

FUNCTION Move(nMove)
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_MOVE" ON INIT {||InitMove(nMove)}
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDOK         ACTION {||EndMove(.T., nMove)}   ;
        ON 0, IDCANCEL     ACTION {||EndMove(.F., nMove)}
   aModDlg:Activate()

RETURN NIL

STATIC FUNCTION InitMove(nMove)
Local hDlg := hwg_GetModalHandle(), cTitle
   hwg_WriteStatus(HMainWindow():GetMdiActive(), 3, "")
   IF nMove == 1
      cTitle := "Input locate expression"
      hwg_SetDlgItemText(hDlg, IDC_EDIT6, cLocate)
   ELSEIF nMove == 2
      cTitle := "Input seek string"
      hwg_SetDlgItemText(hDlg, IDC_EDIT6, cSeek)
   ELSEIF nMove == 3
      cTitle := "Input filter expression"
      hwg_SetDlgItemText(hDlg, IDC_EDIT6, cFilter)
   ELSEIF nMove == 4
      cTitle := "Input record number"
   ENDIF
   hwg_SetDlgItemText(hDlg, IDC_TEXTHEAD, cTitle)
   hwg_SetFocus(hwg_GetDlgItem(hDlg, IDC_EDIT6))
RETURN NIL

STATIC FUNCTION EndMove(lOk, nMove)
Local hDlg := hwg_GetModalHandle()
Local cExpres, nrec, key
Local hWnd, oWindow, aControls, iCont

   IF lOk
      cExpres := hwg_GetDlgItemText(hDlg, IDC_EDIT6, 80)
      IF Empty(cExpres)
         hwg_SetFocus(hwg_GetDlgItem(hDlg, IDC_EDIT6))
         RETURN NIL
      ENDIF

      oWindow := HMainWindow():GetMdiActive()
      IF oWindow != NIL
         aControls := oWindow:aControls
         iCont := Ascan(aControls, {|o|o:classname() == "HBROWSE"})
      ENDIF
      IF nMove == 1
         F_Locate(aControls[iCont], cExpres)
      ELSEIF nMove == 2
         cSeek := cExpres
         nrec := RECNO()
         IF TYPE(OrdKey()) == "N"
            key := VAL(cSeek)
         ELSEIF TYPE(OrdKey()) = "D"
            key := CToD(Trim(cSeek))
         ELSE
            key := cSeek
         ENDIF
         SEEK key
         IF !FOUND()
            GO nrec
            hwg_MsgStop("Record not found")
         ELSE
            hwg_WriteStatus(oWindow, 3, "Found")
         ENDIF
      ELSEIF nMove == 3
         F_Filter(aControls[iCont], cExpres)
      ELSEIF nMove == 4
         IF (nrec := VAL(cExpres)) != 0
            GO nrec
         ENDIF
      ENDIF

      IF iCont > 0
         hwg_RedrawWindow(aControls[iCont]:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ENDIF

   EndDialog(hDlg)
RETURN NIL

FUNCTION F_Locate(oBrw, cExpres)
Local nrec, i, res, block
   cLocate := cExpres
   IF hb_IsLogical(&cLocate)
      nrec := RECNO()
      block := &("{||" + cLocate + "}")
      IF oBrw:prflt
         FOR i := 1 TO Min(oBrw:nRecords, klrecf - 1)
            GO oBrw:aArray[i]
            IF Eval(block)
               res := .T.
               EXIT
            ENDIF
         NEXT
         IF !res .AND. i < oBrw:nRecords
            SKIP
            DO WHILE !Eof()
               IF Eval(block)
                  res := .T.
                  EXIT
               ENDIF
               i ++
               SKIP
            ENDDO
         ENDIF
      ELSE
         __dbLocate(block, , , , .F.)
      ENDIF
      IF (oBrw:prflt .AND. !res) .OR. (!oBrw:prflt .AND. !FOUND())
         GO nrec
         hwg_MsgStop("Record not found")
      ELSE
         hwg_WriteStatus(HMainWindow():GetMdiActive(), 3, "Found")
         IF oBrw:prflt
            oBrw:nCurrent := i
         ENDIF
      ENDIF
   ELSE
      hwg_MsgInfo("Wrong expression")
   ENDIF
RETURN NIL

FUNCTION F_Filter(oBrw, cExpres)
Local i, nrec
   cFilter := cExpres
   IF hb_IsLogical(&cFilter)
      nrec := RECNO()
      dbSetFilter(&( "{||" + cFilter + "}" ), cFilter)
      GO TOP
      i       := 1
      oBrw:nRecords := 0
      IF oBrw:aArray == NIL
         oBrw:aArray := Array(klrecf)
      ENDIF
      DO WHILE !EOF()
         oBrw:aArray[i] = RECNO()
         IF i < klrecf
            i ++
         ENDIF
         oBrw:nRecords ++
         IF INKEY() = 27
            oBrw:nRecords := 0
            EXIT
         ENDIF
         SKIP
      ENDDO
      oBrw:nCurrent := 1
      IF oBrw:nRecords > 0
         GO oBrw:aArray[1]
         oBrw:prflt := .T.
         oBrw:bSkip := &("{|o,x|" + oBrw:alias + "->(FSKIP(o,x))}")
         oBrw:bGoTop := &("{|o|" + oBrw:alias + "->(FGOTOP(o))}")
         oBrw:bGoBot := &("{|o|" + oBrw:alias + "->(FGOBOT(o))}")
         oBrw:bEof  := &("{|o|" + oBrw:alias + "->(FEOF(o))}")
         oBrw:bBof  := &("{|o|" + oBrw:alias + "->(FBOF(o))}")
         hwg_WriteStatus(HMainWindow():GetMdiActive(), 1, Ltrim(Str(oBrw:nRecords, 10)) + " records filtered")
      ELSE
         oBrw:prflt := .F.
         SET FILTER TO
         GO nrec
         oBrw:bSkip := &("{|a,x|" + oBrw:alias + "->(DBSKIP(x))}")
         oBrw:bGoTop := &("{||" + oBrw:alias + "->(DBGOTOP())}")
         oBrw:bGoBot := &("{||" + oBrw:alias + "->(DBGOBOTTOM())}")
         oBrw:bEof  := &("{||" + oBrw:alias + "->(EOF())}")
         oBrw:bBof  := &("{||" + oBrw:alias + "->(BOF())}")
         hwg_MsgInfo("Records not found")
         hwg_WriteStatus(HMainWindow():GetMdiActive(), 1, Ltrim(Str(Reccount(), 10)) + " records")
      ENDIF
   ELSE
      hwg_MsgInfo("Wrong expression")
   ENDIF
RETURN NIL

FUNCTION FGOTOP(oBrw)
   IF oBrw:nRecords > 0
      oBrw:nCurrent := 1
      GO oBrw:aArray[1]
   ENDIF
RETURN NIL

FUNCTION FGOBOT(oBrw)
   oBrw:nCurrent := oBrw:nRecords
   GO IIf(oBrw:nRecords < klrecf, oBrw:aArray[oBrw:nRecords], oBrw:aArray[klrecf])
RETURN NIL

PROCEDURE FSKIP(oBrw, kolskip)
LOCAL tekzp1
   IF oBrw:nRecords = 0
      RETURN
   ENDIF
   tekzp1   := oBrw:nCurrent
   oBrw:nCurrent := oBrw:nCurrent + kolskip + IIf(tekzp1 = 0, 1, 0)
   IF oBrw:nCurrent < 1
      oBrw:nCurrent := 0
      GO oBrw:aArray[1]
   ELSEIF oBrw:nCurrent > oBrw:nRecords
      oBrw:nCurrent := oBrw:nRecords + 1
      GO IIf(oBrw:nRecords < klrecf, oBrw:aArray[oBrw:nRecords], oBrw:aArray[klrecf])
   ELSE
      IF oBrw:nCurrent > klrecf - 1
         SKIP IIf(tekzp1 = oBrw:nRecords + 1, kolskip + 1, kolskip)
      ELSE
         GO oBrw:aArray[oBrw:nCurrent]
      ENDIF
   ENDIF
RETURN

FUNCTION FBOF(oBrw)
RETURN IIf(oBrw:nCurrent = 0, .T., .F.)

FUNCTION FEOF(oBrw)
RETURN IIf(oBrw:nCurrent > oBrw:nRecords, .T., .F.)
