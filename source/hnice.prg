//
// HWGUI - Harbour Win32 GUI library source code:
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include "hwgui.ch"

//#define TRANSPARENT 1 // defined in windows.ch

CLASS HNiceButton INHERIT HControl

   DATA winclass INIT "NICEBUTT"
   DATA TEXT, id, nTop, nLeft, nwidth, nheight
   CLASSDATA oSelected INIT NIL
   DATA State INIT 0
   DATA ExStyle
   DATA bClick, cTooltip

   DATA lPress INIT .F.
   DATA r INIT 30
   DATA g INIT 90
   DATA b INIT 90
   DATA lFlat
   DATA nOrder

   METHOD New(oWndParent, nId, nStyle, nStyleEx, nLeft, nTop, nWidth, nHeight, ;
               bInit, bClick, ;
               cText, cTooltip, r, g, b)

   METHOD Redefine(oWndParent, nId, nStyleEx, ;
                    bInit, bClick, ;
                    cText, cTooltip, r, g, b)

   METHOD Activate()
   METHOD Init()
   METHOD Create()
   METHOD Size()
   METHOD Moving()
   METHOD Paint()
   METHOD MouseMove(wParam, lParam)
   METHOD MDown()
   METHOD MUp()
   METHOD Press() INLINE(::lPress := .T., ::MDown())
   METHOD Release()
   METHOD End()

ENDCLASS

METHOD HNiceButton:New(oWndParent, nId, nStyle, nStyleEx, nLeft, nTop, nWidth, nHeight, ;
            bInit, bClick, ;
            cText, cTooltip, r, g, b)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight,, bInit, ;
              ,, cTooltip)
   DEFAULT g TO ::g
   DEFAULT b TO ::b

   DEFAULT r TO ::r
   ::lFlat  := .T.
   ::bClick := bClick
   ::nOrder  := IIf(oWndParent == NIL, 0, Len(oWndParent:aControls))

   ::ExStyle := nStyleEx
   ::text    := cText
   ::r       := r
   ::g       := g
   ::b       := b
   ::nTop    := nTop
   ::nLeft   := nLeft
   ::nWidth  := nWidth
   ::nHeight := nHeight

   hwg_Regnice()
   ::Activate()

   RETURN Self


METHOD HNiceButton:Redefine(oWndParent, nId, nStyleEx, ;
                 bInit, bClick, ;
                 cText, cTooltip, r, g, b)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0,, bInit,,, cTooltip)

   DEFAULT g TO ::g
   DEFAULT b TO ::b
   DEFAULT r TO ::r

   ::lFlat  := .T.

   ::bClick := bClick

   ::ExStyle := nStyleEx
   ::text    := cText
   ::r       := r
   ::g       := g
   ::b       := b

   hwg_Regnice()

   RETURN Self

METHOD HNiceButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateNiceBtn(::oParent:handle, ::id, ;
                                 ::Style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::ExStyle, ::Text)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HNiceButton:Init()

   IF !::lInit
      ::Super:Init()
      ::Create()
   ENDIF
   RETURN NIL

#if 0 // old code for reference
FUNCTION hwg_NiceButtProc(hBtn, msg, wParam, lParam)

   LOCAL oBtn
   IF msg != WM_CREATE
      IF AScan({WM_MOUSEMOVE, WM_PAINT, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK, WM_DESTROY, WM_MOVING, WM_SIZE}, msg) > 0
         IF (oBtn := hwg_FindSelf(hBtn)) == NIL
            RETURN .F.
         ENDIF

         IF msg == WM_PAINT
            oBtn:Paint()
         ELSEIF msg == WM_LBUTTONUP
            oBtn:MUp()
         ELSEIF msg == WM_LBUTTONDOWN
            oBtn:MDown()
         ELSEIF msg == WM_MOUSEMOVE
            oBtn:MouseMove(wParam, lParam)
         ELSEIF msg == WM_SIZE
            oBtn:Size()

         ELSEIF msg == WM_DESTROY
            oBtn:End()
            RETURN .T.
         ENDIF
      ENDIF

   ENDIF
   RETURN .F.
#else
FUNCTION hwg_NiceButtProc(hBtn, msg, wParam, lParam)

   LOCAL oBtn

   SWITCH msg

   //CASE WM_CREATE
   //   EXIT

   CASE WM_MOUSEMOVE
      IF (oBtn := hwg_FindSelf(hBtn)) != NIL
         oBtn:MouseMove(wParam, lParam)
      ENDIF
      EXIT

   CASE WM_PAINT
      IF (oBtn := hwg_FindSelf(hBtn)) != NIL
         oBtn:Paint()
      ENDIF
      EXIT

   CASE WM_LBUTTONDOWN
      IF (oBtn := hwg_FindSelf(hBtn)) != NIL
         oBtn:MDown()
      ENDIF
      EXIT

   CASE WM_LBUTTONUP
      IF (oBtn := hwg_FindSelf(hBtn)) != NIL
         oBtn:MUp()
      ENDIF
      EXIT

   //CASE WM_LBUTTONDBLCLK
   //   IF (oBtn := hwg_FindSelf(hBtn)) != NIL
   //   ENDIF
   //   EXIT

   CASE WM_DESTROY
      IF (oBtn := hwg_FindSelf(hBtn)) != NIL
         oBtn:End()
         RETURN .T.
      ENDIF
      EXIT

   //CASE WM_MOVING
   //   IF (oBtn := hwg_FindSelf(hBtn)) != NIL
   //   ENDIF
   //   EXIT

   CASE WM_SIZE
      IF (oBtn := hwg_FindSelf(hBtn)) != NIL
         oBtn:Size()
      ENDIF

   ENDSWITCH

RETURN .F.
#endif

METHOD HNiceButton:Create()

   LOCAL Region
   LOCAL Rct
   LOCAL w
   LOCAL h

   Rct    := hwg_GetClientRect(::handle)
   w      := Rct[3] - Rct[1]
   h      := Rct[4] - Rct[2]
   Region := hwg_CreateRoundRectRgn(0, 0, w, h, h * 0.90, h * 0.90)
   hwg_SetWindowRgn(::handle, Region, .T.)
   hwg_InvalidateRect(::handle, 0, 0)

   RETURN Self

METHOD HNiceButton:Size()

   ::State := OBTN_NORMAL
   hwg_InvalidateRect(::handle, 0, 0)

   RETURN Self

METHOD HNiceButton:Moving()

   ::State := .F.
   hwg_InvalidateRect(::handle, 0, 0)

   RETURN Self

METHOD HNiceButton:MouseMove(wParam, lParam)

   LOCAL otmp

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF ::lFlat .AND. ::state != OBTN_INIT
      otmp := hwg_SetNiceBtnSelected()

      IF otmp != NIL .AND. otmp:id != ::id .AND. !otmp:lPress
         otmp:state := OBTN_NORMAL
         hwg_InvalidateRect(otmp:handle, 0)
         hwg_PostMessage(otmp:handle, WM_PAINT, 0, 0)
         hwg_SetNiceBtnSelected(NIL)
      ENDIF

      IF ::state == OBTN_NORMAL
         ::state := OBTN_MOUSOVER

         // aBtn[CTRL_HANDLE] := hBtn
         hwg_InvalidateRect(::handle, 0)
         hwg_PostMessage(::handle, WM_PAINT, 0, 0)
         hwg_SetNiceBtnSelected(Self)
      ENDIF
   ENDIF

   RETURN Self

METHOD HNiceButton:MUp()

   IF ::state == OBTN_PRESSED
      IF !::lPress
         ::state := IIf(::lFlat, OBTN_MOUSOVER, OBTN_NORMAL)
         hwg_InvalidateRect(::handle, 0)
         hwg_PostMessage(::handle, WM_PAINT, 0, 0)
      ENDIF
      IF !::lFlat
         hwg_SetNiceBtnSelected(NIL)
      ENDIF
      IF hb_IsBlock(::bClick)
         Eval(::bClick, ::oParent, ::id)
      ENDIF
   ENDIF

   RETURN Self

METHOD HNiceButton:MDown()

   IF ::state != OBTN_PRESSED
      ::state := OBTN_PRESSED

      hwg_InvalidateRect(::handle, 0, 0)
      hwg_PostMessage(::handle, WM_PAINT, 0, 0)
      hwg_SetNiceBtnSelected(Self)
   ENDIF

   RETURN Self

METHOD HNiceButton:PAINT()

   LOCAL ps        := hwg_DefinePaintStru()
   LOCAL hDC       := hwg_BeginPaint(::handle, ps)
   LOCAL Rct
   LOCAL Size
   LOCAL T
   LOCAL XCtr
   LOCAL YCtr
   LOCAL x
   LOCAL y
   LOCAL w
   LOCAL h
   //  *******************

   Rct  := hwg_GetClientRect(::handle)
   x    := Rct[1]
   y    := Rct[2]
   w    := Rct[3] - Rct[1]
   h    := Rct[4] - Rct[2]
   XCtr := (Rct[1] + Rct[3]) / 2
   YCtr := (Rct[2] + Rct[4]) / 2
   T    := hwg_GetWindowText(::handle)
   // **********************************
   //         Draw our control
   // **********************************

   IF ::state == OBTN_INIT
      ::state := OBTN_NORMAL
   ENDIF

   Size := hwg_GetTextSize(hDC, T)

   hwg_Draw_Gradient(hDC, x, y, w, h, ::r, ::g, ::b)
   hwg_SetBkMode(hDC, WINAPI_TRANSPARENT)

   IF (::State == OBTN_MOUSOVER)
      hwg_SetTextColor(hDC, hwg_VColor("FF0000"))
      hwg_TextOut(hDC, XCtr - (Size[1] / 2) + 1, YCtr - (Size[2] / 2) + 1, T)
   ELSE
      hwg_SetTextColor(hDC, hwg_VColor("0000FF"))
      hwg_TextOut(hDC, XCtr - Size[1] / 2, YCtr - Size[2] / 2, T)
   ENDIF

   hwg_EndPaint(::handle, ps)

   RETURN Self

METHOD HNiceButton:End()

   RETURN NIL

METHOD HNiceButton:Release()

   ::lPress := .F.
   ::state  := OBTN_NORMAL
   hwg_InvalidateRect(::handle, 0)
   hwg_PostMessage(::handle, WM_PAINT, 0, 0)

   RETURN NIL

FUNCTION hwg_SetNiceBtnSelected(oBtn)

   LOCAL otmp := HNiceButton() :oSelected

   IF PCount() > 0
      HNiceButton() :oSelected := oBtn
   ENDIF

   RETURN otmp

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(NICEBUTTPROC, HWG_NICEBUTTPROC);
HB_FUNC_TRANSLATE(SETNICEBTNSELECTED, HWG_SETNICEBTNSELECTED);
#endif

#pragma ENDDUMP
