//
// HWGUI - Harbour Win32 GUI library source code:
// HCheckButton class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

//#define TRANSPARENT 1 // defined in windows.ch

//-------------------------------------------------------------------------------------------------------------------//

CLASS HCheckButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA bSetGet
   DATA lValue
   DATA lEnter
   DATA lFocu INIT .F.
   DATA bClick

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, ;
      bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lEnter, lTransp, bLFocus)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, vari, bSetGet, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, ;
      bGFocus, lEnter)
   METHOD Init()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Refresh()
   // METHOD Disable()
   // METHOD Enable()
   METHOD SetValue(lValue)
   METHOD GetValue() INLINE (hwg_SendMessage(::handle, BM_GETCHECK, 0, 0) == 1)
   METHOD onGotFocus()
   METHOD onClick()
   METHOD KillFocus()
   METHOD Valid()
   METHOD When()
   METHOD Value(lValue) SETGET

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, ;
   bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lEnter, lTransp, bLFocus)

   IF pcount() == 0
      ::Super:New(NIL, NIL, BS_NOTIFY + BS_PUSHBUTTON + BS_AUTOCHECKBOX + WS_TABSTOP, 0, 0, 0, 0, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
      ::lValue := .F.
      ::Activate()
      ::oParent:AddEvent(BN_CLICKED, Self, {|o, id|::Valid(o:FindControl(id))},, "onClick")
      ::oParent:AddEvent(BN_KILLFOCUS, Self, {||::KILLFOCUS()})
      RETURN Self
   ENDIF

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), BS_NOTIFY + BS_PUSHBUTTON + BS_AUTOCHECKBOX + WS_TABSTOP)

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, ;
      bcolor)

   ::title := cCaption
   ::lValue := IIf(vari == NIL .OR. !hb_IsLogical(vari), .F., vari)
   ::bSetGet := bSetGet
   ::backStyle := IIf(lTransp != NIL .AND. lTransp, WINAPI_TRANSPARENT, OPAQUE)

   ::Activate()

   ::lEnter := IIf(lEnter == NIL .OR. !hb_IsLogical(lEnter), .F., lEnter)
   ::bClick := bClick
   ::bLostFocus := bLFocus
   ::bGetFocus := bGFocus

   IF bGFocus != NIL
      //::oParent:AddEvent(BN_SETFOCUS, Self, {|o, id|__When(o:FindControl(id))},, "onGotFocus")
      ::oParent:AddEvent(BN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))},, "onGotFocus")
      ::lnoValid := .T.
   ENDIF
   //::oParent:AddEvent(BN_CLICKED, Self, {|o, id|__Valid(o:FindControl(id),)},, "onClick")
   ::oParent:AddEvent(BN_CLICKED, Self, {|o, id|::Valid(o:FindControl(id))},, "onClick")
   ::oParent:AddEvent(BN_KILLFOCUS, Self, {||::KILLFOCUS()})

   RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateButton(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:Redefine(oWndParent, nId, vari, bSetGet, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, ;
   bGFocus, lEnter)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   ::lValue := IIf(vari == NIL .OR. !hb_IsLogical(vari), .F., vari)
   ::bSetGet := bSetGet
   ::lEnter := IIf(lEnter == NIL .OR. !hb_IsLogical(vari), .F., lEnter)
   ::bClick := bClick
   ::bLostFocus := bClick
   ::bGetFocus := bGFocus
   IF bGFocus != NIL
      ::oParent:AddEvent(BN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))},, "onGotFocus")
   ENDIF
   ::oParent:AddEvent(BN_CLICKED, self, {|o, id|::Valid(o:FindControl(id))},, "onClick")
   ::oParent:AddEvent(BN_KILLFOCUS, Self, {||::KILLFOCUS()})

   RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:Init()

   IF !::lInit
      ::nHolder := 1
      hwg_SetWindowObject(::handle, Self)
      HWG_INITBUTTONPROC(::handle)
      ::Super:Init()
      IF ::lValue
         hwg_SendMessage(::handle, BM_SETCHECK, 1, 0)
      ENDIF
   ENDIF

   RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

#if 0 // old code for reference (to be deleted)
METHOD HCheckButton:onEvent(msg, wParam, lParam)

   LOCAL oCtrl

   IF hb_IsBlock(::bOther)
      IF Eval(::bOther, Self, msg, wParam, lParam) != -1
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_KEYDOWN
      //IF hwg_ProcKeyList(Self, wParam)
      IF wParam == VK_TAB
         hwg_GetSkip(::oparent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      ELSEIF wParam == VK_LEFT .OR. wParam == VK_UP
         hwg_GetSkip(::oparent, ::handle, , -1)
         RETURN 0
      ELSEIF wParam == VK_RIGHT .OR. wParam == VK_DOWN
         hwg_GetSkip(::oparent, ::handle, , 1)
         RETURN 0
      ELSEIF (wParam == VK_RETURN) // .OR. wParam == VK_SPACE)
         IF ::lEnter
            ::SetValue(!::GetValue())
            ::VALID()
            RETURN 0 //-1
         ELSE
            hwg_GetSkip(::oparent, ::handle, , 1)
            RETURN 0
         ENDIF
      ENDIF
   ELSEIF msg == WM_KEYUP
      hwg_ProcKeyList(Self, wParam) // working in MDICHILD AND DIALOG

    ELSEIF msg == WM_GETDLGCODE .AND. !Empty(lParam)
      IF wParam == VK_RETURN .OR. wParam == VK_TAB
           RETURN -1
      ELSEIF wParam == VK_ESCAPE .AND. (oCtrl := ::GetParentForm:FindControl(IDCANCEL)) != NIL .AND. !oCtrl:IsEnabled()
         RETURN DLGC_WANTMESSAGE
      ELSEIF hwg_GetDlgMessage(lParam) == WM_KEYDOWN .AND. wParam != VK_ESCAPE
      ELSEIF hwg_GetDlgMessage(lParam) == WM_CHAR .OR. wParam == VK_ESCAPE .OR. ;
         hwg_GetDlgMessage(lParam) == WM_SYSCHAR
         RETURN -1
      ENDIF
      RETURN DLGC_WANTMESSAGE //+ DLGC_WANTCHARS
   ENDIF
   RETURN -1
#else
METHOD HCheckButton:onEvent(msg, wParam, lParam)

   LOCAL oCtrl

   IF hb_IsBlock(::bOther)
      IF Eval(::bOther, Self, msg, wParam, lParam) != -1
         RETURN 0
      ENDIF
   ENDIF

   SWITCH msg

   CASE WM_KEYDOWN
      //IF hwg_ProcKeyList(Self, wParam)
      SWITCH wParam
      CASE VK_TAB
         hwg_GetSkip(::oparent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      CASE VK_LEFT
      CASE VK_UP
         hwg_GetSkip(::oparent, ::handle, , -1)
         RETURN 0
      CASE VK_RIGHT
      CASE VK_DOWN
         hwg_GetSkip(::oparent, ::handle, , 1)
         RETURN 0
      CASE VK_RETURN // .OR. wParam == VK_SPACE)
         IF ::lEnter
            ::SetValue(!::GetValue())
            ::VALID()
            RETURN 0 //-1
         ELSE
            hwg_GetSkip(::oparent, ::handle, , 1)
            RETURN 0
         ENDIF
      ENDSWITCH
      EXIT

   CASE WM_KEYUP
      hwg_ProcKeyList(Self, wParam) // working in MDICHILD AND DIALOG
      EXIT

   CASE WM_GETDLGCODE
      IF !Empty(lParam)
         IF wParam == VK_RETURN .OR. wParam == VK_TAB
            RETURN -1
         ELSEIF wParam == VK_ESCAPE .AND. ;
            (oCtrl := ::GetParentForm:FindControl(IDCANCEL)) != NIL .AND. !oCtrl:IsEnabled()
            RETURN DLGC_WANTMESSAGE
         ELSEIF hwg_GetDlgMessage(lParam) == WM_KEYDOWN .AND. wParam != VK_ESCAPE
         ELSEIF hwg_GetDlgMessage(lParam) == WM_CHAR .OR.wParam == VK_ESCAPE .OR. hwg_GetDlgMessage(lParam) == WM_SYSCHAR
            RETURN -1
         ENDIF
         RETURN DLGC_WANTMESSAGE //+ DLGC_WANTCHARS
      ENDIF

   ENDSWITCH

   RETURN -1
#endif

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:SetValue(lValue)

   hwg_SendMessage(::handle, BM_SETCHECK, IIf(Empty(lValue), 0, 1), 0)
   ::lValue := IIf(lValue == NIL .OR. !hb_IsLogical(lValue), .F., lValue)
   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, lValue, Self)
   ENDIF
   ::Refresh()

   RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:Value(lValue)

   IF lValue != NIL
      ::SetValue(lValue)
   ENDIF

   RETURN hwg_SendMessage(::handle, BM_GETCHECK, 0, 0) == 1

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:Refresh()

   LOCAL var

   IF hb_IsBlock(::bSetGet)
      var := Eval(::bSetGet,, Self)
      IF var == NIL .OR. !hb_IsLogical(var)
        var := hwg_SendMessage(::handle, BM_GETCHECK, 0, 0) == 1
      ENDIF
      ::lValue := IIf(var == NIL .OR. !hb_IsLogical(var), .F., var)
   ENDIF
   hwg_SendMessage(::handle, BM_SETCHECK, IIf(::lValue, 1, 0), 0)

   RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

#if 0
METHOD HCheckButton:Disable()

   ::Super:Disable()
   hwg_SendMessage(::handle, BM_SETCHECK, BST_INDETERMINATE, 0)

   RETURN NIL
#endif

//-------------------------------------------------------------------------------------------------------------------//

#if 0
METHOD HCheckButton:Enable()

   ::Super:Enable()
   hwg_SendMessage(::handle, BM_SETCHECK, IIf(::lValue, 1, 0), 0)

   RETURN NIL
#endif

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:onGotFocus()

   RETURN ::When()

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:onClick()

   RETURN ::Valid()

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:killFocus()

   LOCAL ndown := hwg_GetKeyState(VK_RIGHT) + hwg_GetKeyState(VK_DOWN) + hwg_GetKeyState(VK_TAB)
   LOCAL nSkip := 0

   IF !hwg_CheckFocus(Self, .T.)
      RETURN .T.
   ENDIF

   IF ::oParent:classname = "HTAB"
      IF hwg_GetKeyState(VK_LEFT) + hwg_GetKeyState(VK_UP) < 0 .OR. (hwg_GetKeyState(VK_TAB) < 0 .AND. hwg_GetKeyState(VK_SHIFT) < 0)
         nSkip := -1
      ELSEIF ndown < 0
         nSkip := 1
      ENDIF
      IF nSkip != 0
         hwg_GetSkip(::oparent, ::handle, , nSkip)
      ENDIF
   ENDIF
   IF hwg_GetKeyState(VK_RETURN) < 0 .AND. ::lEnter
      ::SetValue(!::GetValue())
      ::VALID()
   ENDIF
   IF hb_IsBlock(::bLostFocus)
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bLostFocus, Self, ::lValue)
      ::oparent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:When()

   LOCAL res := .T.
   LOCAL nSkip

   IF !hwg_CheckFocus(Self, .F.)
      RETURN .T.
   ENDIF

   nSkip := IIf(hwg_GetKeyState(VK_UP) < 0 .OR. (hwg_GetKeyState(VK_TAB) < 0 .AND. hwg_GetKeyState(VK_SHIFT) < 0), -1, 1)

   IF hb_IsBlock(::bGetFocus)
      ::lnoValid := .T.
      ::oParent:lSuspendMsgsHandling := .T.
      IF hb_IsBlock(::bSetGet)
         res := Eval(::bGetFocus, Eval(::bSetGet, , Self), Self)
      ELSE
         res := Eval(::bGetFocus, ::lValue, Self)
      ENDIF
      ::lnoValid := !res
      IF !res
         hwg_WhenSetFocus(Self, nSkip)
      ENDIF
   ENDIF

   ::oParent:lSuspendMsgsHandling := .F.

   RETURN res

//-------------------------------------------------------------------------------------------------------------------//

METHOD HCheckButton:Valid()

   LOCAL l := hwg_SendMessage(::handle, BM_GETCHECK, 0, 0)

   IF !hwg_CheckFocus(Self, .T.) .OR. ::lnoValid
      RETURN .T.
   ENDIF

   IF l == BST_INDETERMINATE
      hwg_CheckDlgButton(::oParent:handle, ::id, .F.)
      hwg_SendMessage(::handle, BM_SETCHECK, 0, 0)
      ::lValue := .F.
   ELSE
      ::lValue := (l == 1)
   ENDIF

   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::lValue, Self)
   ENDIF

   IF hb_IsBlock(::bClick)
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bClick, Self, ::lValue)
      ::oparent:lSuspendMsgsHandling := .F.
   ENDIF

   IF Empty(hwg_GetFocus())
      hwg_GetSkip(::oParent, ::handle,, ::nGetSkip)
   ENDIF

   RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//
