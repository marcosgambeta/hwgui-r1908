//
// HWGUI - Harbour Win32 GUI library source code:
// HSplitter class
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//#define TRANSPARENT 1 // defined in windows.ch

CLASS HSplitter INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA aLeft
   DATA aRight
   DATA lVertical
   DATA hCursor
   DATA lCaptured INIT .F.
   DATA lMoved INIT .F.
   DATA bEndDrag
   DATA lScrolling

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, ;
               bSize, bDraw, color, bcolor, aLeft, aRight, lTransp, lScrolling)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Paint()
   METHOD Drag(lParam)
   METHOD DragAll(lScroll)

ENDCLASS

METHOD HSplitter:New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, ;
            bSize, bDraw, color, bcolor, aLeft, aRight, lTransp, lScrolling)
                                                         //+  WS_CLIPCHILDREN
   ::Super:New(oWndParent, nId, WS_VISIBLE + SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight,,, ;
              bSize, bDraw,, color, bcolor)

   ::title := ""

   ::aLeft := IIf(aLeft == NIL, {}, aLeft)
   ::aRight := IIf(aRight == NIL, {}, aRight)
   ::lVertical := (::nHeight > ::nWidth)
   ::lScrolling := IIf(lScrolling == NIL, .F., lScrolling)
   IF (lTransp != NIL .AND. lTransp)
      ::BackStyle := WINAPI_TRANSPARENT
      ::extStyle += WS_EX_TRANSPARENT
   ENDIF
   ::Activate()

RETURN Self

METHOD HSplitter:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatic(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::extStyle)
      ::Init()
   ENDIF

RETURN NIL

METHOD HSplitter:Init()

   IF !::lInit
      ::Super:Init()
      ::nHolder := 1
      hwg_SetWindowObject(::handle, Self)
      hwg_InitWinCtrl(::handle)
   ENDIF

RETURN NIL

#if 0 // old code for reference (to be deleted)
METHOD HSplitter:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)

   IF msg == WM_MOUSEMOVE
      IF ::hCursor == NIL
         ::hCursor := hwg_LoadCursor(IIf(::lVertical, IDC_SIZEWE, IDC_SIZENS))
      ENDIF
      hwg_SetCursor(::hCursor)
      IF ::lCaptured
         ::Drag(lParam)
         IF ::lScrolling
            ::DragAll(.T.)
         ENDIF
      ENDIF
   ELSEIF msg == WM_PAINT
      ::Paint()
   ELSEIF msg == WM_ERASEBKGND

   ELSEIF msg == WM_LBUTTONDOWN
      hwg_SetCursor(::hCursor)
      hwg_SetCapture(::handle)
      ::lCaptured := .T.
      hwg_InvalidateRect(::handle, 1)
   ELSEIF msg == WM_LBUTTONUP
      hwg_ReleaseCapture()
      ::lCaptured := .F.
      ::lMoved := .F.
      ::DragAll(.F.)
      IF hb_IsBlock(::bEndDrag)
       //  Eval(::bEndDrag, Self)
      ENDIF
   ELSEIF msg == WM_DESTROY
      ::End()
   ENDIF

   RETURN - 1
#else
METHOD HSplitter:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)

   SWITCH msg

   CASE WM_MOUSEMOVE
      IF ::hCursor == NIL
         ::hCursor := hwg_LoadCursor(IIf(::lVertical, IDC_SIZEWE, IDC_SIZENS))
      ENDIF
      hwg_SetCursor(::hCursor)
      IF ::lCaptured
         ::Drag(lParam)
         IF ::lScrolling
            ::DragAll(.T.)
         ENDIF
      ENDIF
      EXIT

   CASE WM_PAINT
      ::Paint()
      EXIT

   CASE WM_ERASEBKGND
      EXIT

   CASE WM_LBUTTONDOWN
      hwg_SetCursor(::hCursor)
      hwg_SetCapture(::handle)
      ::lCaptured := .T.
      hwg_InvalidateRect(::handle, 1)
      EXIT

   CASE WM_LBUTTONUP
      hwg_ReleaseCapture()
      ::lCaptured := .F.
      ::lMoved := .F.
      ::DragAll(.F.)
      IF hb_IsBlock(::bEndDrag)
         //Eval(::bEndDrag, Self)
      ENDIF
      EXIT

   CASE WM_DESTROY
      ::End()

   ENDSWITCH

RETURN -1
#endif

METHOD HSplitter:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors
   LOCAL x1
   LOCAL y1
   LOCAL x2
   LOCAL y2
   LOCAL oBrushFill

   pps := hwg_DefinePaintStru()
   hDC := hwg_BeginPaint(::handle, pps)
   aCoors := hwg_GetClientRect(::handle)

   x1 := aCoors[1] //+ IIf(::lVertical, 1, 2)
   y1 := aCoors[2] //+ IIf(::lVertical, 2, 1)
   x2 := aCoors[3] //- IIf(::lVertical, 0, 3)
   y2 := aCoors[4] //- IIf(::lVertical, 3, 0)

   hwg_SetBkMode(hDC, ::backStyle)
   IF hb_IsBlock(::bPaint)
      Eval(::bPaint, Self)
   ELSEIF !::lScrolling
      IF ::lCaptured
         oBrushFill := HBrush():Add(hwg_RGB(156, 156, 156))
         hwg_SelectObject(hDC, oBrushFill:handle)
         hwg_DrawEdge(hDC, x1, y1, x2, y2, EDGE_ETCHED, IIf(::lVertical, BF_RECT, BF_TOP) + BF_MIDDLE)
         hwg_FillRect(hDC, x1, y1, x2, y2, oBrushFill:handle)
      ELSEIF ::BackStyle == OPAQUE
         hwg_DrawEdge(hDC, x1, y1, x2, y2, EDGE_ETCHED, IIf(::lVertical, BF_LEFT, BF_TOP))
      ENDIF
   ELSEIF !::lMoved .AND. ::BackStyle == OPAQUE
      hwg_DrawEdge(hDC, x1, y1, x2, y2, EDGE_ETCHED, IIf(::lVertical, BF_RECT, BF_TOP)) //+ BF_MIDDLE)
   ENDIF
   hwg_EndPaint(::handle, pps)

RETURN NIL

METHOD HSplitter:Drag(lParam)

   LOCAL xPos := hwg_LOWORD(lParam)
   LOCAL yPos := hwg_HIWORD(lParam)

   IF ::lVertical
      IF xPos > 32000
         xPos -= 65535
      ENDIF
      ::nLeft += xPos
      yPos := 0
   ELSE
      IF yPos > 32000
         yPos -= 65535
      ENDIF
      ::nTop += yPos
      xPos := 0
   ENDIF
   ::Move(::nLeft + xPos, ::nTop + yPos, ::nWidth, ::nHeight) //, !::lScrolling)
   hwg_InvalidateRect(::oParent:handle, 1, ::nLeft, ::nTop, ::nleft + ::nWidth, ::nTop + ::nHeight)
   ::lMoved := .T.

RETURN NIL

METHOD HSplitter:DragAll(lScroll)

   LOCAL i
   LOCAL oCtrl
   LOCAL xDiff := 0
   LOCAL yDiff := 0

   lScroll := IIf(Len(::aLeft) == 0 .OR. Len(::aRight) == 0, .F., lScroll)

   FOR i := 1 TO Len(::aRight)
      oCtrl := ::aRight[i]
      IF ::lVertical
         xDiff := ::nLeft + ::nWidth - oCtrl:nLeft
         //oCtrl:nLeft += nDiff
         //oCtrl:nWidth -= nDiff
      ELSE
         yDiff := ::nTop + ::nHeight - oCtrl:nTop
         //oCtrl:nTop += nDiff
         //oCtrl:nHeight -= nDiff
      ENDIF
      oCtrl:Move(oCtrl:nLeft + xDiff, oCtrl:nTop + yDiff, oCtrl:nWidth - xDiff, oCtrl:nHeight - yDiff, !lScroll)
      //IF oCtrl:winclass == "STATIC"
      hwg_InvalidateRect(oCtrl:handle, 1)
      //ENDIF
   NEXT
   FOR i := 1 TO Len(::aLeft)
      oCtrl := ::aLeft[i]
      IF ::lVertical
         xDiff := ::nLeft - (oCtrl:nLeft + oCtrl:nWidth)
         //oCtrl:nWidth += nDiff
      ELSE
         yDiff := ::nTop - (oCtrl:nTop + oCtrl:nHeight)
        // oCtrl:nHeight += nDiff
      ENDIF
      oCtrl:Move(oCtrl:nLeft, oCtrl:nTop, oCtrl:nWidth + xDiff, oCtrl:nHeight + yDiff, !lScroll)
      //IF oCtrl:winclass == "STATIC"
      hwg_InvalidateRect(oCtrl:handle, 1)
      //ENDIF
   NEXT
   //::lMoved := .F.
   IF !lScroll
      hwg_InvalidateRect(::oParent:handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight)
   ELSEIF ::lVertical
      hwg_InvalidateRect(::oParent:handle, 0, ::nLeft - ::nWidth - xDiff - 1, ::nTop, ::nLeft + ::nWidth + xDiff + 1, ::nTop + ::nHeight)
   ELSE
      hwg_InvalidateRect(::oParent:handle, 0, ::nLeft, ::nTop - ::nHeight - yDiff - 1, ::nLeft + ::nWidth, ::nTop + ::nHeight + yDiff + 1)
   ENDIF
   IF hb_IsBlock(::bEndDrag)
      Eval(::bEndDrag, Self)
   ENDIF

RETURN NIL
