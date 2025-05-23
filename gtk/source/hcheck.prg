//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HCheckButton class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HCheckButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"
   DATA bSetGet
   DATA value

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor, bGFocus)
   METHOD Activate()
   METHOD Init()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Refresh()
   METHOD SetValue(lValue) INLINE hwg_CheckButton(::handle, lValue)
   METHOD GetValue() INLINE ::value := hwg_IsButtonChecked(::handle)

ENDCLASS

METHOD HCheckButton:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor, bGFocus)

   nStyle   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), BS_AUTO3STATE + WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor)

   ::title   := cCaption
   ::value   := IIf(vari == NIL .OR. !hb_IsLogical(vari), .F., vari)
   ::bSetGet := bSetGet

   ::Activate()

   ::bLostFocus := bClick
   ::bGetFocus  := bGFocus

   hwg_SetSignal(::handle, "clicked", WM_LBUTTONUP, 0, 0)
   // ::oParent:AddEvent(BN_CLICKED, ::id, {|o, id|__Valid(o:FindControl(id))})
   IF bGFocus != NIL
      hwg_SetSignal(::handle, "enter", BN_SETFOCUS, 0, 0)
      // ::oParent:AddEvent(BN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
   ENDIF

RETURN Self

METHOD HCheckButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateButton(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      hwg_SetWindowObject(::handle, Self)
      ::Init()
   ENDIF
RETURN NIL

METHOD HCheckButton:Init()
   IF !::lInit
      ::Super:Init()
      IF ::value
         hwg_CheckButton(::handle, .T.)
      ENDIF
   ENDIF
RETURN NIL

#if 0 // old code for reference (to be deleted)
METHOD HCheckButton:onEvent(msg, wParam, lParam)

   IF msg == WM_LBUTTONUP
      __Valid(Self)
   ELSEIF msg == BN_SETFOCUS
      __When(Self)
   ENDIF

RETURN NIL
#else
METHOD HCheckButton:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   SWITCH msg
   CASE WM_LBUTTONUP
      __Valid(Self)
      EXIT
   CASE BN_SETFOCUS
      __When(Self)
   ENDSWITCH

RETURN NIL
#endif

METHOD HCheckButton:Refresh()

   LOCAL var

   IF ::bSetGet != NIL
       var := Eval(::bSetGet, , NIL)
       ::value := IIf(var == NIL, .F., var)
   ENDIF

   hwg_CheckButton(::handle, ::value)
RETURN NIL

STATIC FUNCTION __Valid(oCtrl)

   LOCAL res

   oCtrl:value := hwg_IsButtonChecked(oCtrl:handle)

   IF oCtrl:bSetGet != NIL
      Eval(oCtrl:bSetGet, oCtrl:value, oCtrl)
   ENDIF
   IF oCtrl:bLostFocus != NIL .AND. ;
         hb_IsLogical(res := Eval(oCtrl:bLostFocus, oCtrl:value, oCtrl)) ;
	 .AND. !res
      hwg_SetFocus(oCtrl:handle)
   ENDIF

RETURN .T.

STATIC FUNCTION __When(oCtrl)

   LOCAL res

   oCtrl:Refresh()

   IF oCtrl:bGetFocus != NIL
      res := Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet, , oCtrl), oCtrl)
      IF hb_IsLogical(res) .AND. !res
         hwg_GetSkip(oCtrl:oParent, oCtrl:handle, 1)
      ENDIF
      RETURN res
   ENDIF

RETURN .T.
