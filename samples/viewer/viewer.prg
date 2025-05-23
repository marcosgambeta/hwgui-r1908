//
// JPEG, BMP, PNG, MNG, TIFF images viewer.
// FreeImage.dll should present to use this sample
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "hwgui.ch"

#define SB_HORZ             0
#define SB_VERT             1

#define SCROLLVRANGE       20
#define SCROLLHRANGE       20

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL oFont
   //LOCAL hDCwindow

   PRIVATE oToolBar
   PRIVATE oImage
   PRIVATE oSayMain
   PRIVATE oSayScale
   PRIVATE aScreen
   PRIVATE nKoef
   PRIVATE lScrollV := .F.
   PRIVATE lScrollH := .F.
   PRIVATE nStepV := 0
   PRIVATE nStepH := 0
   PRIVATE nVert
   PRIVATE nHorz

#ifdef __FREEIMAGE__
   IF !FI_Init()
      RETURN NIL
   ENDIF
#endif

   PREPARE FONT oFont NAME "Times New Roman" WIDTH 0 HEIGHT -17

   INIT WINDOW oMainWindow MAIN TITLE "Viewer"  ;
     COLOR COLOR_3DLIGHT + 1                      ;
     AT 200, 0 SIZE 400, 150                      ;
     FONT oFont                                 ;
     ON OTHER MESSAGES {|o, m, wp, lp|MessagesProc(o, m, wp, lp)}
     //      ON PAINT {|o|PaintWindow(o)}               ;

   MENU OF oMainWindow
      MENU TITLE "&File"
         MENUITEM "&Open" ACTION FileOpen(oMainWindow)
         SEPARATOR
         MENUITEM "&Exit" + Chr(9) + "Alt+x" ACTION hwg_EndWindow() ;
           ACCELERATOR FALT, Asc("X")
      ENDMENU
      MENU TITLE "&View"
         MENUITEM "Zoom &in" ACTION Zoom(oMainWindow, -1)
         MENUITEM "Zoom &out" ACTION Zoom(oMainWindow, 1)
         MENUITEM "Ori&ginal size" ACTION Zoom(oMainWindow, 0)
      ENDMENU
      MENU TITLE "&Help"
         MENUITEM "&About" ACTION hwg_MsgInfo("About")
      ENDMENU
   ENDMENU

   @ 0, 0 PANEL oToolBar SIZE oMainWindow:nWidth, 28 ;
      ON SIZE {|o, x, y|hwg_MoveWindow(o:handle, 0, 0, x, o:nHeight)}



   @ 2, 2 OWNERBUTTON OF oToolBar ON CLICK {||FileOpen(oMainWindow)} ;
        SIZE 24, 24 BITMAP "BMP_OPEN" FROM RESOURCE FLAT             ;
        TOOLTIP "Open file"
   @ 26, 2 OWNERBUTTON OF oToolBar ON CLICK {||Zoom(oMainWindow, 1)} ;
        SIZE 24, 24 BITMAP "BMP_ZOUT" FROM RESOURCE FLAT              ;
        TOOLTIP "Zoom out"
   @ 50, 2 OWNERBUTTON OF oToolBar ON CLICK {||Zoom(oMainWindow, -1)} ;
        SIZE 24, 24 BITMAP "BMP_ZIN" FROM RESOURCE FLAT               ;
        TOOLTIP "Zoom in"
   @ 74, 2 OWNERBUTTON OF oToolBar ON CLICK {||ImageInfo()} ;
        SIZE 24, 24 BITMAP "BMP_INFO" FROM RESOURCE TRANSPARENT FLAT  ;
        TOOLTIP "Info"

   @ 106, 3 SAY oSayScale CAPTION "" OF oToolBar SIZE 60, 22 STYLE WS_BORDER ;
        FONT oFont BACKCOLOR 12507070

#ifdef __FREEIMAGE__
   @ 0, oToolBar:nHeight IMAGE oSayMain SHOW NIL SIZE oMainWindow:nWidth, oMainWindow:nHeight
#else
   @ 0, oToolBar:nHeight BITMAP oSayMain SHOW NIL SIZE oMainWindow:nWidth, oMainWindow:nHeight
#endif

   aScreen := GetWorkareaRect()
   // writelog(Str(aScreen[1]) + Str(aScreen[2]) + Str(aScreen[3]) + Str(aScreen[4]))

   ACTIVATE WINDOW oMainWindow

RETURN NIL

STATIC FUNCTION MessagesProc(oWnd, msg, wParam, lParam)

   LOCAL i
   LOCAL aItem

   IF msg == WM_VSCROLL
      Vscroll(oWnd, hwg_LOWORD(wParam), hwg_HIWORD(wParam))
   ELSEIF msg == WM_HSCROLL
      Hscroll(oWnd, hwg_LOWORD(wParam), hwg_HIWORD(wParam))
   ELSEIF msg == WM_KEYUP
      IF wParam == 40        // Down
        VScroll(oWnd, SB_LINEDOWN)
      ELSEIF wParam == 38    // Up
        VScroll(oWnd, SB_LINEUP)
      ELSEIF wParam == 39    // Right
        HScroll(oWnd, SB_LINEDOWN)
      ELSEIF wParam == 37    // Left
        HScroll(oWnd, SB_LINEUP)
      ENDIF
   ENDIF

RETURN -1

STATIC FUNCTION Vscroll(oWnd, nScrollCode, nNewPos)

   LOCAL stepV

   IF nScrollCode == SB_LINEDOWN
      IF nStepV < SCROLLVRANGE
         nStepV ++
         stepV := Round((Round(oImage:nHeight * nKoef, 0) - (oWnd:nHeight - oToolbar:nHeight - nVert)) / SCROLLVRANGE, 0)
         oSayMain:nOffsetV := - nStepV * stepV
         hwg_SetScrollInfo(oWnd:handle, SB_VERT, 1, nStepV + 1, 1, SCROLLVRANGE)
         hwg_RedrawWindow(oSayMain:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ELSEIF nScrollCode == SB_LINEUP
      IF nStepV > 0
         nStepV --
         stepV := Round((Round(oImage:nHeight * nKoef, 0) - (oWnd:nHeight - oToolbar:nHeight - nVert)) / SCROLLVRANGE, 0)
         oSayMain:nOffsetV := - nStepV * stepV
         hwg_SetScrollInfo(oWnd:handle, SB_VERT, 1, nStepV + 1, 1, SCROLLVRANGE)
         hwg_RedrawWindow(oSayMain:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ELSEIF nScrollCode == SB_THUMBTRACK
      IF --nNewPos != nStepV
         nStepV := nNewPos
         stepV := Round((Round(oImage:nHeight * nKoef, 0) - (oWnd:nHeight - oToolbar:nHeight - nVert)) / SCROLLVRANGE, 0)
         oSayMain:nOffsetV := - nStepV * stepV
         hwg_SetScrollInfo(oWnd:handle, SB_VERT, 1, nStepV + 1, 1, SCROLLVRANGE)
         hwg_RedrawWindow(oSayMain:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION Hscroll(oWnd, nScrollCode, nNewPos)

   LOCAL stepH

   IF nScrollCode == SB_LINEDOWN
      IF nStepH < SCROLLHRANGE
         nStepH ++
         stepH := Round(Round(oImage:nWidth * nKoef - (oWnd:nWidth - nHorz), 0) / SCROLLVRANGE, 0)
         oSayMain:nOffsetH := - nStepH * stepH
         hwg_SetScrollInfo(oWnd:handle, SB_HORZ, 1, nStepH + 1, 1, SCROLLHRANGE)
         hwg_RedrawWindow(oSayMain:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ELSEIF nScrollCode == SB_LINEUP
      IF nStepH > 0
         nStepH --
         stepH := Round(Round(oImage:nWidth * nKoef - (oWnd:nWidth - nHorz), 0) / SCROLLVRANGE, 0)
         oSayMain:nOffsetH := - nStepH * stepH
         hwg_SetScrollInfo(oWnd:handle, SB_HORZ, 1, nStepH + 1, 1, SCROLLHRANGE)
         hwg_RedrawWindow(oSayMain:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ELSEIF nScrollCode == SB_THUMBTRACK
      IF --nNewPos != nStepH
         nStepH := nNewPos
         stepH := Round(Round(oImage:nWidth * nKoef - (oWnd:nWidth - nHorz), 0) / SCROLLVRANGE, 0)
         oSayMain:nOffsetH := - nStepH * stepH
         hwg_SetScrollInfo(oWnd:handle, SB_HORZ, 1, nStepH + 1, 1, SCROLLHRANGE)
         hwg_RedrawWindow(oSayMain:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF

   ENDIF

RETURN NIL

STATIC FUNCTION FileOpen(oWnd)

   LOCAL mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
   LOCAL fname
   LOCAL aCoors

#ifdef __FREEIMAGE__
   fname := hwg_SelectFile("Graphic files( *.jpg;*.png;*.psd;*.tif )", "*.jpg;*.png;*.psd;*.tif", mypath)
#else
   fname := hwg_SelectFile("Graphic files( *.jpg;*.gif;*.bmp )", "*.jpg;*.gif;*.bmp", mypath)
#endif
   IF !Empty(fname)
      nKoef := 1
      nStepV := nStepH := 0
      IF lScrollH
         hwg_SetScrollInfo(oWnd:handle, SB_HORZ, 1, nStepH + 1, 1, SCROLLHRANGE)
      ENDIF
      IF lScrollV
         hwg_SetScrollInfo(oWnd:handle, SB_VERT, 1, nStepV + 1, 1, SCROLLVRANGE)
      ENDIF
      /*
      IF oImage != NIL
         oImage:Release()
      ENDIF
      */
#ifdef __FREEIMAGE__
      // oImage := HFreeImage():AddFile(fname)
      oSayMain:ReplaceImage(fname)
#else
      // oImage := HBitmap():AddFile(fname)
      oSayMain:ReplaceBitmap(fname)
#endif
      oImage := oSayMain:oImage
      oSayMain:nOffsetH := oSayMain:nOffsetV := 0

      lScrollV := lScrollH := .F.
      hwg_ShowScrollBar(oWnd:handle, SB_HORZ, lScrollH)
      hwg_ShowScrollBar(oWnd:handle, SB_VERT, lScrollV)

      aCoors := hwg_GetClientRect(oWnd:handle)
      nVert := (oWnd:nHeight - aCoors[4])
      nHorz := (oWnd:nWidth - aCoors[3])
      DO WHILE .T.
         oWnd:nWidth := Round(oImage:nWidth * nKoef, 0) + nHorz
         oWnd:nHeight := Round(oImage:nHeight * nKoef, 0) + oToolBar:nHeight + nVert

         IF (oWnd:nWidth <= aScreen[3] .AND. oWnd:nHeight <= aScreen[4]) .OR. nKoef < 0.15
            IF oWnd:nLeft + oWnd:nWidth >= aScreen[3]
               oWnd:nLeft := 0
            ENDIF
            IF oWnd:nTop + oWnd:nHeight >= aScreen[4]
               oWnd:nTop := 0
            ENDIF
            EXIT
         ENDIF
         nKoef -= 0.1
      ENDDO
      IF oWnd:nWidth < 200
         oWnd:nWidth := 200
      ENDIF
      IF oWnd:nHeight < 100
         oWnd:nHeight := 100
      ENDIF

      // writelog("Window: " + Str(oWnd:nWidth) + Str(oWnd:nHeight) + Str(nKoef) + Str(oImage:nWidth) + Str(oImage:nHeight))
      hwg_MoveWindow(oWnd:handle, oWnd:nLeft, oWnd:nTop, oWnd:nWidth, oWnd:nHeight)
      oSayMain:nZoom := nKoef
      hwg_InvalidateRect(oSayMain:handle, 0)
      oSayMain:Move(, , oWnd:nWidth - nHorz, oWnd:nHeight - nVert - oToolBar:nHeight)
      oSayScale:SetValue(Str(nKoef * 100, 4) + " %")
   ENDIF

RETURN NIL

STATIC FUNCTION Zoom(oWnd, nOp)

   LOCAL aCoors
   LOCAL stepV
   LOCAL stepH

   IF oImage == NIL
      RETURN NIL
   ENDIF
   aCoors := hwg_GetClientRect(oWnd:handle)
   nVert := (oWnd:nHeight - aCoors[4])
   nHorz := (oWnd:nWidth - aCoors[3])

   IF nOp < 0 .AND. nKoef > 0.11
      nKoef -= 0.1
   ELSEIF nOp > 0
      nKoef += 0.1
   ELSEIF nOp == 0
      nKoef := 1
   ENDIF

   lScrollV := lScrollH := .F.
   oWnd:nWidth := Round(oImage:nWidth * nKoef, 0) + nHorz
   oWnd:nHeight := Round(oImage:nHeight * nKoef, 0) + oToolBar:nHeight + nVert
   // writelog("1->" + Str(oWnd:nWidth) + Str(aScreen[3]) + " - " + Str(oWnd:nHeight) + Str(aScreen[4]))
   IF oWnd:nLeft + oWnd:nWidth >= aScreen[3]
      oWnd:nLeft := 0
      IF oWnd:nWidth >= aScreen[3]
         oWnd:nWidth := aScreen[3]
         lScrollH := .T.
         // writelog("2->" + Str(oWnd:nWidth) + Str(aScreen[3]) + " - " + Str(oWnd:nHeight) + Str(aScreen[4]))
      ENDIF
   ENDIF
   IF oWnd:nTop + oWnd:nHeight >= aScreen[4]
      oWnd:nTop := 0
      IF oWnd:nHeight >= aScreen[4]
         oWnd:nHeight := aScreen[4]
         lScrollV := .T.
         // writelog("3->" + Str(oWnd:nWidth) + Str(aScreen[3]) + " - " + Str(oWnd:nHeight) + Str(aScreen[4]))
      ENDIF
   ENDIF
   IF oWnd:nWidth < 200
      oWnd:nWidth := 200
   ENDIF
   IF oWnd:nHeight < 100
      oWnd:nHeight := 100
   ENDIF

   oSayMain:nZoom := nKoef
   oSayScale:SetValue(Str(nKoef * 100, 4) + " %")
   hwg_InvalidateRect(oWnd:handle, 0)
   // writelog("Window: " + Str(oWnd:nWidth) + Str(oWnd:nHeight) + Str(nKoef) + Str(oImage:nWidth) + Str(oImage:nHeight))
   hwg_MoveWindow(oWnd:handle, oWnd:nLeft, oWnd:nTop, oWnd:nWidth, oWnd:nHeight)
   stepV := Round((Round(oImage:nHeight * nKoef, 0) - (oWnd:nHeight - oToolbar:nHeight - nVert)) / SCROLLVRANGE, 0)
   stepH := Round(Round(oImage:nWidth * nKoef - (oWnd:nWidth - nHorz), 0) / SCROLLVRANGE, 0)
   oSayMain:nOffsetV := - nStepV * stepV
   oSayMain:nOffsetH := - nStepH * stepH
   oSayMain:Move(, , oWnd:nWidth - nHorz, oWnd:nHeight - nVert - oToolBar:nHeight)
   hwg_ShowScrollBar(oWnd:handle, SB_HORZ, lScrollH)
   hwg_ShowScrollBar(oWnd:handle, SB_VERT, lScrollV)

RETURN NIL

/*
STATIC FUNCTION PaintWindow(oWnd)

   LOCAL stepV
   LOCAL stepH
   LOCAL nOffsV
   LOCAL nOffsH

   IF oImage == NIL
      RETURN -1
   ENDIF

   stepV := Round((Round(oImage:nHeight * nKoef, 0) - (oWnd:nHeight - oToolbar:nHeight - nVert)) / SCROLLVRANGE, 0)
   stepH := Round(Round(oImage:nWidth * nKoef - (oWnd:nWidth - nHorz), 0) / SCROLLVRANGE, 0)
   nOffsV := nStepV * stepV
   nOffsH := nStepH * stepH

   pps := hwg_DefinePaintStru()
   hDC := hwg_BeginPaint(oWnd:handle, pps)

   // writelog("Paint: " + Str(Round(oImage:nWidth * nKoef, 0)) + Str(Round(oImage:nHeight * nKoef, 0)))
#ifdef __FREEIMAGE__
   oImage:Draw(hDC, -nOffsH, oToolbar:nHeight - nOffsV, Round(oImage:nWidth * nKoef, 0), Round(oImage:nHeight * nKoef, 0))
#else
   hwg_DrawBitmap(hDC, oImage:handle,, -nOffsH, oToolbar:nHeight - nOffsV, Round(oImage:nWidth * nKoef, 0), Round(oImage:nHeight * nKoef, 0))
#endif

   IF lScrollV
      hwg_SetScrollInfo(oWnd:handle, SB_VERT, 1, nStepV + 1, 1, SCROLLVRANGE)
   ENDIF
   hwg_EndPaint(oWnd:handle, pps)

RETURN 0
*/

STATIC FUNCTION ImageInfo()

   IF oImage == NIL
      RETURN NIL
   ENDIF

RETURN NIL

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapicdp.h"

#define SPI_GETWORKAREA     48

HB_FUNC(GETWORKAREARECT)
{
   RECT rc;
   PHB_ITEM aMetr = hb_itemArrayNew(4);
   PHB_ITEM temp;

   SystemParametersInfo(

       SPI_GETWORKAREA, // system parameter to query or set
       0,               // depends on action to be taken
       (PVOID) &rc,     // depends on action to be taken
       0                // user profile update flag
      );

   temp = hb_itemPutNI(NULL, rc.left);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNI(NULL, rc.top);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNI(NULL, rc.right);
   hb_itemArrayPut(aMetr, 3, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNI(NULL, rc.bottom);
   hb_itemArrayPut(aMetr, 4, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);

}

#pragma ENDDUMP
