//
// HWGUI - Harbour Win32 GUI library source code:
// HListBox class
//
// Copyright 2004 Vic McClung
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HListBox INHERIT HControl

   CLASS VAR winclass INIT "LISTBOX"

   DATA aItems
   DATA bSetGet
   DATA value INIT 1
   DATA nItemHeight
   DATA bChangeSel
   DATA bkeydown
   DATA bDblclick
   DATA bValid

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, aItems, oFont, bInit, bSize, ;
      bPaint, bChange, cTooltip, tColor, bcolor, bGFocus, bLFocus, bKeydown, bDblclick, bOther)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, bChange, cTooltip, bKeydown, ;
      bOther)
   METHOD Init()
   METHOD Refresh()
   METHOD Requery()
   METHOD Setitem(nPos)
   METHOD AddItems(p)
   METHOD DeleteItem(nPos)
   METHOD Valid(oCtrl)
   METHOD When(oCtrl)
   METHOD onChange(oCtrl)
   METHOD onDblClick()
   METHOD Clear()
   METHOD onEvent(msg, wParam, lParam)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, aItems, oFont, bInit, bSize, bPaint, ;
   bChange, cTooltip, tColor, bcolor, bGFocus, bLFocus, bKeydown, bDblclick, bOther)

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), ;
      WS_TABSTOP + WS_VSCROLL + LBS_DISABLENOSCROLL + LBS_NOTIFY + LBS_NOINTEGRALHEIGHT + WS_BORDER)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip, tColor, ;
      bcolor)

   ::value := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 0, vari)
   ::bSetGet := bSetGet

   IF aItems == NIL
      ::aItems := {}
   ELSE
      ::aItems := aItems
   ENDIF

   ::Activate()

   ::bChangeSel := bChange
   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus
   ::bKeydown := bKeydown
   ::bDblclick := bDblclick
   ::bOther := bOther

   IF bSetGet != NIL
      IF bGFocus != NIL
         ::lnoValid := .T.
         ::oParent:AddEvent(LBN_SETFOCUS, Self, {|o, id|::When(o:FindControl(id))}, , "onGotFocus")
      ENDIF
      ::oParent:AddEvent(LBN_KILLFOCUS, Self, {|o, id|::Valid(o:FindControl(id))}, .F., "onLostFocus")
      ::bValid := {|o|::Valid(o)}
   ELSE
      IF bGFocus != NIL
         ::oParent:AddEvent(LBN_SETFOCUS, Self, {|o, id|::When(o:FindControl(id))}, , "onGotFocus")
      ENDIF
      ::oParent:AddEvent(LBN_KILLFOCUS, Self, {|o, id|::Valid(o:FindControl(id))}, .F., "onLostFocus")
   ENDIF
   IF bChange != NIL .OR. bSetGet != NIL
      ::oParent:AddEvent(LBN_SELCHANGE, Self, {|o, id|::onChange(o:FindControl(id))}, , "onChange")
   ENDIF
   IF bDblclick != NIL
      ::oParent:AddEvent(LBN_DBLCLK, self, {||::onDblClick()})
   ENDIF

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateListbox(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:Redefine(oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, bChange, cTooltip, bKeydown, ;
   bOther)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, cTooltip)

   ::value := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 1, vari)
   ::bSetGet := bSetGet
   ::bKeydown := bKeydown
   ::bOther := bOther

   IF aItems == NIL
      ::aItems := {}
   ELSE
      ::aItems := aItems
   ENDIF

   IF bSetGet != NIL
      ::bChangeSel := bChange
      ::oParent:AddEvent(LBN_SELCHANGE, Self, {|o, id|::Valid(o:FindControl(id))}, "onChange")
   ENDIF

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:Init()

   LOCAL i

   IF !::lInit
      ::nHolder := 1
      hwg_SetWindowObject(::handle, Self)
      HWG_INITLISTPROC(::handle)
      ::Super:Init()
      IF ::aItems != NIL
         IF ::value == NIL
            ::value := 1
         ENDIF
         IF !Empty(::nItemHeight)
            hwg_SendMessage(::handle, LB_SETITEMHEIGHT, 0, ::nItemHeight)
         ENDIF
         hwg_SendMessage(::handle, LB_RESETCONTENT, 0, 0)
         FOR i := 1 TO Len(::aItems)
            hwg_ListboxAddString(::handle, ::aItems[i])
         NEXT
         hwg_ListboxSetString(::handle, ::value)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

#if 0 // old code for reference (to be deleted)
METHOD HListBox:onEvent(msg, wParam, lParam)

   LOCAL nEval

   IF hb_IsBlock(::bOther)
      IF (nEval := Eval(::bOther, Self, msg, wParam, lParam)) != -1 .AND. nEval != NIL
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_KEYDOWN
      IF hwg_ProcKeyList(Self, wParam)
         RETURN - 1
      ENDIF
      IF wParam == VK_TAB //.AND. nType < WND_DLG_RESOURCE
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
        //RETURN 0
      ENDIF
         IF hb_IsBlock(::bKeyDown)
         ::oparent:lSuspendMsgsHandling := .T.
         nEval := Eval(::bKeyDown, Self, wParam)
         IF (hb_IsLogical(nEval) .AND. !nEval) .OR. (nEval != -1 .AND. nEval != NIL)
            ::oparent:lSuspendMsgsHandling := .F.
            RETURN 0
         ENDIF
         ::oparent:lSuspendMsgsHandling := .F.
      ENDIF
   ELSEIF msg == WM_GETDLGCODE .AND. (wParam == VK_RETURN .OR. wParam == VK_ESCAPE) .AND. ::bKeyDown != NIL
      RETURN DLGC_WANTALLKEYS  //DLGC_WANTARROWS + DLGC_WANTTAB + DLGC_WANTCHARS
   ENDIF

RETURN -1
#else
METHOD HListBox:onEvent(msg, wParam, lParam)

   LOCAL nEval

   IF hb_IsBlock(::bOther)
      IF (nEval := Eval(::bOther, Self, msg, wParam, lParam)) != -1 .AND. nEval != NIL
         RETURN 0
      ENDIF
   ENDIF

   SWITCH msg

   CASE WM_KEYDOWN
      IF hwg_ProcKeyList(Self, wParam)
         RETURN -1
      ENDIF
      IF wParam == VK_TAB //.AND. nType < WND_DLG_RESOURCE
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
        //RETURN 0
      ENDIF
         IF hb_IsBlock(::bKeyDown)
         ::oparent:lSuspendMsgsHandling := .T.
         nEval := Eval(::bKeyDown, Self, wParam)
         IF (hb_IsLogical(nEval) .AND. !nEval) .OR. (nEval != -1 .AND. nEval != NIL)
            ::oparent:lSuspendMsgsHandling := .F.
            RETURN 0
         ENDIF
         ::oparent:lSuspendMsgsHandling := .F.
      ENDIF
      EXIT

   CASE WM_GETDLGCODE
      IF (wParam == VK_RETURN .OR. wParam == VK_ESCAPE) .AND. ::bKeyDown != NIL
         RETURN DLGC_WANTALLKEYS //DLGC_WANTARROWS + DLGC_WANTTAB + DLGC_WANTCHARS
      ENDIF

   ENDSWITCH

RETURN -1
#endif

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:Requery()

   LOCAL i

   hwg_SendMessage(::handle, LB_RESETCONTENT, 0, 0)
   FOR i := 1 TO Len(::aItems)
      hwg_ListboxAddString(::handle, ::aItems[i])
   NEXT
   hwg_ListboxSetString(::handle, ::value)
   ::refresh()

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:Refresh()

   LOCAL vari

   IF hb_IsBlock(::bSetGet)
      vari := Eval(::bSetGet)
   ENDIF

   ::value := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 0, vari)
   ::SetItem(::value)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:SetItem(nPos)

   ::value := nPos
   hwg_SendMessage(::handle, LB_SETCURSEL, nPos - 1, 0)

   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::value)
   ENDIF

   IF hb_IsBlock(::bChangeSel)
      Eval(::bChangeSel, ::value, Self)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:onDblClick()

  IF hb_IsBlock(::bDblClick)
       ::oParent:lSuspendMsgsHandling := .T.
      Eval(::bDblClick, self, ::value)
       ::oParent:lSuspendMsgsHandling := .F.
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:AddItems(p)

   //LOCAL i

   AAdd(::aItems, p)
   hwg_ListboxAddString(::handle, p)
   //   hwg_SendMessage(::handle, LB_RESETCONTENT, 0, 0)
   //   FOR i := 1 TO Len(::aItems)
   //      hwg_ListboxAddString(::handle, ::aItems[i])
   //   NEXT
   hwg_ListboxSetString(::handle, ::value)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:DeleteItem(nPos)

   IF hwg_SendMessage(::handle, LB_DELETESTRING, nPos - 1, 0) >= 0 //<= Len(ocombo:aitems)
      ADel(::Aitems, nPos)
      ASize(::Aitems, Len(::aitems) - 1)
      ::value := Min(Len(::aitems), ::value)
      IF hb_IsBlock(::bSetGet)
         Eval(::bSetGet, ::value, Self)
      ENDIF
      RETURN .T.
   ENDIF

RETURN .F.

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:Clear()

   ::aItems := {}
   ::value := 0
   hwg_SendMessage(::handle, LB_RESETCONTENT, 0, 0)
   hwg_ListboxSetString(::handle, ::value)

RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:onChange(oCtrl)

   LOCAL nPos

   HB_SYMBOL_UNUSED(oCtrl)

   nPos := hwg_SendMessage(::handle, LB_GETCURSEL, 0, 0) + 1
   ::SetItem(nPos)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:When(oCtrl)

   LOCAL res := .T.
   LOCAL nSkip

   HB_SYMBOL_UNUSED(oCtrl)

   IF !hwg_CheckFocus(Self, .F.)
      RETURN .T.
   ENDIF
    nSkip := IIf(hwg_GetKeyState(VK_UP) < 0 .OR. (hwg_GetKeyState(VK_TAB) < 0 .AND. hwg_GetKeyState(VK_SHIFT) < 0), -1, 1)
   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::value, Self)
   ENDIF
   IF hb_IsBlock(::bGetFocus)
      ::lnoValid := .T.
      ::oparent:lSuspendMsgsHandling := .T.
      res := Eval(::bGetFocus, ::Value, Self)
      ::oparent:lSuspendMsgsHandling := .F.
      ::lnoValid := !res
      IF !res
         hwg_WhenSetFocus(Self, nSkip)
      ELSE
         ::SetFocus()
      ENDIF
   ENDIF

RETURN res

//-------------------------------------------------------------------------------------------------------------------//

METHOD HListBox:Valid(oCtrl)

   LOCAL res
   LOCAL oDlg
   //LOCAL ltab := hwg_GetKeyState(VK_TAB) < 0
   //LOCAL nSkip

   HB_SYMBOL_UNUSED(oCtrl)

   IF !hwg_CheckFocus(Self, .T.) .OR. ::lNoValid
      RETURN .T.
   ENDIF
   //nSkip := IIf(hwg_GetKeyState(VK_SHIFT) < 0, - 1, 1)
   IF (oDlg := hwg_ParentGetDialog(Self)) == NIL .OR. oDlg:nLastKey != 27
      ::value := hwg_SendMessage(::handle, LB_GETCURSEL, 0, 0) + 1
      IF hb_IsBlock(::bSetGet)
         Eval(::bSetGet, ::value, Self)
      ENDIF
      IF oDlg != NIL
         oDlg:nLastKey := 27
      ENDIF
      IF hb_IsBlock(::bLostFocus)
         ::oparent:lSuspendMsgsHandling := .T.
         res := Eval(::bLostFocus, ::value, Self)
         ::oparent:lSuspendMsgsHandling := .F.
         IF !res
            ::SetFocus(.T.) //(::handle)
            IF oDlg != NIL
               oDlg:nLastKey := 0
            ENDIF
            RETURN .F.
         ENDIF
      ENDIF
      IF oDlg != NIL
         oDlg:nLastKey := 0
      ENDIF
   ENDIF
   IF Empty(hwg_GetFocus())
      hwg_GetSkip(::oParent, ::handle,, ::nGetSkip)
   ENDIF

   //IF lTab .AND. hwg_GetFocus() == ::handle
   //   IF ::oParent:CLASSNAME = "HTAB"
   //      ::oParent:SETFOCUS()
   //   ENDIF
   //   hwg_GetSkip(::oparent, ::handle,, nSkip)
   //ENDIF

RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//
