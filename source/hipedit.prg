//
// HWGUI - Harbour Win32 GUI library source code:
// HTab class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

#define IPN_FIELDCHANGED 4294966436

//- HIPedit

CLASS HIPedit INHERIT HControl

CLASS VAR winclass   INIT "SysIPAddress32"
   DATA bSetGet
   DATA bChange
   DATA bKillFocus
   DATA bGetFocus
   DATA lnoValid   INIT .F.

   METHOD New(oWndParent, nId, aValue, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
               oFont, bGetFocus, bKillFocus)
   METHOD Activate()
   METHOD Init()
   METHOD SetValue(aValue)
   METHOD GetValue()
   METHOD Clear()
   METHOD End()

   HIDDEN:
   DATA aValue           // Valor atual

ENDCLASS

METHOD HIPedit:New(oWndParent, nId, aValue, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
            oFont, bGetFocus, bKillFocus)

   nStyle   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont)

   ::title   := ""

   ::bSetGet := bSetGet
   DEFAULT aValue TO {0, 0, 0, 0}
   ::aValue  := aValue
   ::bGetFocus  := bGetFocus
   ::bKillFocus := bKillFocus

   HWG_InitCommonControlsEx()
   ::Activate()


   //IF bSetGet != NIL
      /*
      ::bGetFocus := bGFocus
      ::bLostFocus := bLFocus
      ::oParent:AddEvent(EN_SETFOCUS, self, {|o, id|__When(o:FindControl(id))}, .T., "onGotFocus")
      ::oParent:AddEvent(EN_KILLFOCUS, self, {|o, id|__Valid(o:FindControl(id))}, .T., "onLostFocus")
      ::oParent:AddEvent(IPN_FIELDCHANGED, self, {|o, id|__Valid(o:FindControl(id))}, .T., "onChange")
      */
   //ELSE
   IF bGetFocus != NIL
      ::lnoValid := .T.
        // ::oParent:AddEvent(EN_SETFOCUS, self, ::bGetfocus, .T., "onGotFocus")
   ENDIF
   IF bKillFocus != NIL
        // ::oParent:AddEvent(EN_KILLFOCUS, self, ::bKillfocus, .T., "onLostFocus")
      ::oParent:AddEvent(IPN_FIELDCHANGED, Self, ::bKillFocus, .T., "onChange")
   ENDIF
  // ENDIF

   // Notificacoes de Ganho e perda de foco
   //::oParent:AddEvent(IPN_FIELDCHANGED, self, ::bKillFocus, .T., "onChange")
   ::oParent:AddEvent(EN_SETFOCUS, Self, {|o, id|__GetFocus(o:FindControl(id))},, "onGotFocus")
   ::oParent:AddEvent(EN_KILLFOCUS, Self, {|o, id|__KillFocus(o:FindControl(id))},, "onLostFocus")


   RETURN Self

METHOD HIPedit:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_InitIPAddress(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HIPedit:Init()

   IF !::lInit
      ::Super:Init()
      ::SetValue(::aValue)
      ::lInit := .T.
   ENDIF

   RETURN NIL

METHOD HIPedit:SetValue(aValue)
   hwg_SetIPAddress(::handle, aValue[1], aValue[2], aValue[3], aValue[4])
   ::aValue := aValue
   RETURN NIL


METHOD HIPedit:GetValue()
   ::aValue := hwg_GetIPAddress(::handle)
   RETURN ::aValue

METHOD HIPedit:Clear()
   hwg_ClearIPAddress(::handle)
   ::aValue := {0, 0, 0, 0}
   RETURN ::aValue


METHOD HIPedit:End()

   // Nothing to do here, yet!
   ::Super:End()

   RETURN NIL


STATIC FUNCTION __GetFocus(oCtrl)
   LOCAL xRet

   IF !hwg_CheckFocus(oCtrl, .F.)
      RETURN .T.
   ENDIF

   IF hb_IsBlock(oCtrl:bGetFocus)
      oCtrl:oparent:lSuspendMsgsHandling := .T.
      oCtrl:lnoValid := .T.
      xRet := Eval(oCtrl:bGetFocus, oCtrl)
      oCtrl:oparent:lSuspendMsgsHandling := .F.
      oCtrl:lnoValid := xRet
   ENDIF

   RETURN xRet


STATIC FUNCTION __KillFocus(oCtrl)
   LOCAL xRet

   IF !hwg_CheckFocus(oCtrl, .T.) .OR. oCtrl:lNoValid
      RETURN .T.
   ENDIF

   IF hb_IsBlock(oCtrl:bKillFocus)
      oCtrl:oparent:lSuspendMsgsHandling := .T.
      xRet := Eval(oCtrl:bKillFocus, oCtrl)
      oCtrl:oparent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN xRet
