//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HDialog class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

REQUEST HWG_ENDWINDOW

STATIC s_aMessModalDlg := { ;
         {WM_COMMAND, {|o, w, l|hwg_DlgCommand(o, w, l)}}, ;
         {WM_SIZE, {|o, w, l|onSize(o, w, l)}}, ;
         {WM_INITDIALOG, {|o, w, l|InitModalDlg(o, w, l)}}, ;
         {WM_ERASEBKGND, {|o, w|onEraseBk(o, w)}}, ;
         {WM_DESTROY, {|o|onDestroy(o)}}, ;
         {WM_ENTERIDLE, {|o, w, l|onEnterIdle(o, w, l)}}, ;
         {WM_ACTIVATE, {|o, w, l|onActivate(o, w, l)}} ;
      }

STATIC FUNCTION onDestroy(oDlg)

   IF oDlg:bDestroy != NIL
      Eval(oDlg:bDestroy, oDlg)
      oDlg:bDestroy := NIL
   ENDIF
   oDlg:Super:onEvent(WM_DESTROY)
   HDialog():DelItem(oDlg, .T.)
   IF oDlg:lModal
      hwg_gtk_exit()
   ENDIF

RETURN 0

// Class HDialog

CLASS HDialog INHERIT HCustomWindow

   CLASS VAR aDialogs       SHARED INIT {}
   CLASS VAR aModalDialogs  SHARED INIT {}

   DATA fbox
   DATA menu
   DATA oPopup                // Context menu for a dialog
   DATA lResult INIT .F.     // Becomes TRUE if the OK button is pressed
   DATA lUpdated INIT .F.     // TRUE, if any GET is changed
   DATA lClipper INIT .F.     // Set it to TRUE for moving between GETs with ENTER key
   DATA GetList INIT {}      // The array of GET items in the dialog
   DATA KeyList INIT {}      // The array of keys ( as Clipper's SET KEY )
   DATA lExitOnEnter INIT .T. // Set it to False, if dialog shouldn't be ended after pressing ENTER key,
                              // Added by Sandro Freire
   DATA lExitOnEsc INIT .T. // Set it to False, if dialog shouldn't be ended after pressing ENTER key,
                              // Added by Sandro Freire
   DATA nLastKey INIT 0
   DATA oIcon, oBmp
   DATA bActivate
   DATA lActivated INIT .F.
   DATA xResourceID
   DATA lModal
   //DATA lActivated INIT .F. // duplicated
   DATA nScrollBars INIT - 1
   

   METHOD New(lType, nStyle, x, y, width, height, cTitle, oFont, bInit, bExit, bSize, ;
                  bPaint, bGfocus, bLfocus, bOther, lClipper, oBmp, oIcon, lExitOnEnter, nHelpId, xResourceID, lExitOnEsc)
   METHOD Activate(lNoModal)
   METHOD onEvent(msg, wParam, lParam)
   METHOD AddItem(oWnd, lModal)
   METHOD DelItem(oWnd, lModal)
   METHOD FindDialog(hWnd)
   METHOD GetActive()
   METHOD Center() INLINE hwg_CenterWindow(Self)
   METHOD Restore() INLINE hwg_WindowRestore(::handle)
   METHOD Maximize() INLINE hwg_WindowMaximize(::handle)
   METHOD Minimize() INLINE hwg_WindowMinimize(::handle)
   METHOD Close() INLINE EndDialog(::handle)
ENDCLASS

METHOD HDialog:New(lType, nStyle, x, y, width, height, cTitle, oFont, bInit, bExit, bSize, ;
                  bPaint, bGfocus, bLfocus, bOther, lClipper, oBmp, oIcon, lExitOnEnter, nHelpId, xResourceID, lExitOnEsc)

   HB_SYMBOL_UNUSED(nHelpId)

   ::oDefaultParent := Self
   ::xResourceID := xResourceID
   ::type     := lType
   ::title    := cTitle
   ::style    := IIf(nStyle == NIL, WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX, nStyle)
   ::oBmp     := oBmp
   ::oIcon    := oIcon
   ::nTop     := IIf(y == NIL, 0, y)
   ::nLeft    := IIf(x == NIL, 0, x)
   ::nWidth   := IIf(width == NIL, 0, width)
   ::nHeight  := IIf(height == NIL, 0, height)
   ::oFont    := oFont
   ::bInit    := bInit
   ::bDestroy := bExit
   ::bSize    := bSize
   ::bPaint   := bPaint
   ::bGetFocus  := bGFocus
   ::bLostFocus := bLFocus
   ::bOther     := bOther
   ::lClipper   := IIf(lClipper == NIL, .F., lClipper)
   ::lExitOnEnter := IIf(lExitOnEnter == NIL, .T., !lExitOnEnter)
   ::lExitOnEsc  :=IIf(lExitOnEsc == NIL, .T., !lExitOnEsc)

   IF hwg_BitAnd(::style, DS_CENTER) > 0
      ::nLeft := Int((hwg_GetDesktopWidth() - ::nWidth) / 2)
      ::nTop  := Int((hwg_GetDesktopHeight() - ::nHeight) / 2)
   ENDIF
   ::handle := hwg_CreateDlg(Self)

RETURN Self

METHOD HDialog:Activate(lNoModal)

   LOCAL hParent
   LOCAL oWnd

   hwg_CreateGetList(Self)

   IF lNoModal == NIL
      lNoModal := .F.
   ENDIF
   ::lModal := !lNoModal
   ::lResult := .F.
   ::AddItem(Self, !lNoModal)
   IF !lNoModal
      hParent := IIf(::oParent != NIL .AND. ;
             __ObjHasMsg(::oParent, "HANDLE") .AND. ::oParent:handle != NIL ;
             .AND. !Empty(::oParent:handle), ::oParent:handle, ;
             IIf((oWnd := HWindow():GetMain()) != NIL, ;
             oWnd:handle, NIL))
      hwg_Set_Modal(::handle, hParent)
   ENDIF
   hwg_ShowAll(::handle)
   InitModalDlg(Self)
   ::lActivated := .T.
   hwg_ActivateDialog(::handle, lNoModal)

RETURN NIL

METHOD HDialog:onEvent(msg, wParam, lParam)

   LOCAL i

   // writelog(str(msg) + str(wParam) + str(lParam))
   IF (i := AScan(s_aMessModalDlg, {|a|a[1] == msg})) != 0
      RETURN Eval(s_aMessModalDlg[i, 2], Self, wParam, lParam)
   ELSE
      RETURN ::Super:onEvent(msg, wParam, lParam)
   ENDIF

RETURN 0

METHOD HDialog:AddItem(oWnd, lModal)
   AAdd(IIf(lModal, ::aModalDialogs, ::aDialogs), oWnd)
RETURN NIL

METHOD HDialog:DelItem(oWnd, lModal)

   LOCAL i

   IF lModal
      IF (i := AScan(::aModalDialogs, {|o|o == oWnd})) > 0
         ADel(::aModalDialogs, i)
         ASize(::aModalDialogs, Len(::aModalDialogs) - 1)
      ENDIF
   ELSE
      IF (i := AScan(::aDialogs, {|o|o == oWnd})) > 0
         ADel(::aDialogs, i)
         ASize(::aDialogs, Len(::aDialogs) - 1)
      ENDIF
   ENDIF
RETURN NIL

METHOD HDialog:FindDialog(hWnd)
/*
LOCAL i := AScan(::aDialogs, {|o|o:handle == hWnd})
RETURN IIf(i == 0, NIL, ::aDialogs[i])
*/
RETURN hwg_GetWindowObject(hWnd)

METHOD HDialog:GetActive()

   LOCAL handle := hwg_GetFocus()
   LOCAL i := AScan(::Getlist, {|o|o:handle == handle})

RETURN IIf(i == 0, NIL, ::Getlist[i])

// End of class
// ------------------------------------

STATIC FUNCTION InitModalDlg(oDlg)

   //LOCAL iCont // variable not used

   // writelog(str(oDlg:handle) + " " + oDlg:title)
   IF hb_IsArray(oDlg:menu)
      hwg__SetMenu(oDlg:handle, oDlg:menu[5])
   ENDIF
   /*
   IF oDlg:oIcon != NIL
      hwg_SendMessage(oDlg:handle, WM_SETICON, 1, oDlg:oIcon:handle)
   ENDIF
   */
   IF oDlg:Title != NIL
      hwg_SetWindowText(oDlg:Handle, oDlg:Title)
   ENDIF
   /*
   IF oDlg:oFont != NIL
      hwg_SendMessage(oDlg:handle, WM_SETFONT, oDlg:oFont:handle, 0)
   ENDIF
   */
   IF oDlg:bInit != NIL
      Eval(oDlg:bInit, oDlg)
   ENDIF

RETURN 1

STATIC FUNCTION onEnterIdle(oDlg, wParam, lParam)

   LOCAL oItem
   
   HB_SYMBOL_UNUSED(oDlg)

   IF wParam == 0 .AND. (oItem := Atail(HDialog():aModalDialogs)) != NIL ;
         .AND. oItem:handle == lParam .AND. !oItem:lActivated
      oItem:lActivated := .T.
      IF oItem:bActivate != NIL
         Eval(oItem:bActivate, oItem)
      ENDIF
   ENDIF
RETURN 0

STATIC FUNCTION onEraseBk(oDlg, hDC)

   //LOCAL aCoors // variable not used

   HB_SYMBOL_UNUSED(oDlg)
   HB_SYMBOL_UNUSED(hDC)

/*
   IF __ObjHasMsg(oDlg, "OBMP")
      IF oDlg:oBmp != NIL
         hwg_SpreadBitmap(hDC, oDlg:handle, oDlg:oBmp:handle)
         RETURN 1
      ELSE
        aCoors := hwg_GetClientRect(oDlg:handle)
        IF oDlg:brush != NIL
           IF !hb_IsNumeric(oDlg:brush)
              hwg_FillRect(hDC, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, oDlg:brush:handle)
           ENDIF
        ELSE
           hwg_FillRect(hDC, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, COLOR_3DFACE + 1)
        ENDIF
        RETURN 1
      ENDIF
   ENDIF
*/   
RETURN 0

FUNCTION hwg_DlgCommand(oDlg, wParam, lParam)

   LOCAL iParHigh := hwg_HIWORD(wParam)
   LOCAL iParLow := hwg_LOWORD(wParam)
   LOCAL aMenu
   LOCAL i
   LOCAL hCtrl
   
   HB_SYMBOL_UNUSED(lParam)

   // WriteLog(Str(iParHigh, 10) + "|" + Str(iParLow, 10) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10))
   IF iParHigh == 0
      IF iParLow == IDOK
         hCtrl := hwg_GetFocus()
         FOR i := Len(oDlg:GetList) TO 1 STEP -1
            IF !oDlg:GetList[i]:lHide .AND. hwg_IsWindowEnabled(oDlg:Getlist[i]:Handle)
               EXIT
            ENDIF
         NEXT
         IF i != 0 .AND. oDlg:GetList[i]:handle == hCtrl
            IF __ObjHasMsg(oDlg:GetList[i], "BVALID")
               IF Eval(oDlg:GetList[i]:bValid, oDlg:GetList[i]) .AND. ;
                      oDlg:lExitOnEnter
                  oDlg:lResult := .T.
                  EndDialog(oDlg:handle)
               ENDIF
               RETURN 1
            ENDIF
         ENDIF
         IF oDlg:lClipper
            IF !hwg_GetSkip(oDlg, hCtrl, 1)
               IF oDlg:lExitOnEnter
                  oDlg:lResult := .T.
                  EndDialog(oDlg:handle)
               ENDIF
            ENDIF
            RETURN 1
         ENDIF
      ELSEIF iParLow == IDCANCEL
         oDlg:nLastKey := 27
      ENDIF
   ENDIF

   IF oDlg:aEvents != NIL .AND. ;
      (i := AScan(oDlg:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
      Eval(oDlg:aEvents[i, 3], oDlg, iParLow)
   ELSEIF iParHigh == 0 .AND. ( ;
        (iParLow == IDOK .AND. oDlg:FindControl(IDOK) != NIL) .OR. ;
          iParLow == IDCANCEL)
      IF iParLow == IDOK
         oDlg:lResult := .T.
      ENDIF
      //Replaced by Sandro
      IF oDlg:lExitOnEsc
         EndDialog(oDlg:handle)
      ENDIF
   ELSEIF __ObjHasMsg(oDlg, "MENU") .AND. hb_IsArray(oDlg:menu) .AND. ;
        (aMenu := hwg_FindMenuItem(oDlg:menu, iParLow, @i)) != NIL ;
        .AND. aMenu[1, i, 1] != NIL
      Eval(aMenu[1, i, 1])
   ELSEIF __ObjHasMsg(oDlg, "OPOPUP") .AND. oDlg:oPopup != NIL .AND. ;
         (aMenu := hwg_FindMenuItem(oDlg:oPopup:aMenu, wParam, @i)) != NIL ;
         .AND. aMenu[1, i, 1] != NIL
         Eval(aMenu[1, i, 1])
   ENDIF

RETURN 1

STATIC FUNCTION onSize(oDlg, wParam, lParam)

   LOCAL aControls
   LOCAL iCont
   LOCAL nW1
   LOCAL nH1
   //LOCAL nW := hwg_LOWORD(lParam) // variable not used
   //LOCAL nH := hwg_HIWORD(lParam) // variable not used
   //LOCAL nScrollMax // variable not used

   HB_SYMBOL_UNUSED(wParam)

   /*
   IF (oDlg:nHeight = oDlg:minHeight .AND. nH < oDlg:minHeight) .OR. ;
      (oDlg:nHeight = oDlg:maxHeight .AND. nH > oDlg:maxHeight) .OR. ;
      (oDlg:nWidth = oDlg:minWidth .AND. nW < oDlg:minWidth) .OR. ;
      (oDlg:nWidth = oDlg:maxWidth .AND. nW > oDlg:maxWidth)
      RETURN 0
   ENDIF*/

   nW1 := oDlg:nWidth
   nH1 := oDlg:nHeight
   //aControls := hwg_GetWindowRect(oDlg:handle)
   oDlg:nWidth := hwg_LOWORD(lParam)  //aControls[3] - aControls[1]
   //

   IF oDlg:bSize != NIL .AND. ;
       (oDlg:oParent == NIL .OR. !__ObjHasMsg(oDlg:oParent, "ACONTROLS"))
      Eval(oDlg:bSize, oDlg, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
   ENDIF
   aControls := oDlg:aControls
   IF aControls != NIL
      oDlg:Anchor(oDlg, nW1, nH1, oDlg:nWidth, oDlg:nHeight)
      FOR iCont := 1 TO Len(aControls)
         IF aControls[iCont]:bSize != NIL
            Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
         ENDIF
      NEXT
   ENDIF

RETURN 0

STATIC FUNCTION onActivate(oDlg, wParam, lParam)

   LOCAL iParLow := hwg_LOWORD(wParam)
   
   HB_SYMBOL_UNUSED(lParam)

   IF iParLow > 0 .AND. oDlg:bGetFocus != NIL
      Eval(oDlg:bGetFocus, oDlg)
   ELSEIF iParLow == 0 .AND. oDlg:bLostFocus != NIL
      Eval(oDlg:bLostFocus, oDlg)
   ENDIF

RETURN 0

FUNCTION hwg_GetModalDlg()

   LOCAL i := Len(HDialog():aModalDialogs)

RETURN IIf(i > 0, HDialog():aModalDialogs[i], 0)

FUNCTION hwg_GetModalHandle()

   LOCAL i := Len(HDialog():aModalDialogs)

RETURN IIf(i > 0, HDialog():aModalDialogs[i]:handle, 0)

FUNCTION EndDialog(handle)

   LOCAL oDlg

   // writelog("EndDialog-0")
   IF handle == NIL
      IF (oDlg := Atail(HDialog():aModalDialogs)) == NIL
         // writelog("EndDialog-1")
         RETURN NIL
      ENDIF
   ELSE
      oDlg := hwg_GetWindowObject(handle)
   ENDIF

   // writelog("EndDialog-1")
   IF oDlg:bDestroy != NIL
      // writelog("EndDialog-2")
      Eval(oDlg:bDestroy, oDlg)
      oDlg:bDestroy := NIL
   ENDIF

   // writelog("EndDialog-10")
RETURN  hwg_DestroyWindow(oDlg:handle)

FUNCTION hwg_SetDlgKey(oDlg, nctrl, nkey, block)

   LOCAL i
   LOCAL aKeys

   IF oDlg == NIL
      oDlg := HCustomWindow():oDefaultParent
   ENDIF
   IF nctrl == NIL
      nctrl := 0
   ENDIF

   IF !__ObjHasMsg(oDlg, "KEYLIST")
      RETURN .F.
   ENDIF
   aKeys := oDlg:KeyList
   IF block == NIL

      IF (i := AScan(aKeys, {|a|a[1] == nctrl .AND. a[2] == nkey})) == 0
         RETURN .F.
      ELSE
         ADel(oDlg:KeyList, i)
         ASize(oDlg:KeyList, Len(oDlg:KeyList) - 1)
      ENDIF
   ELSE
      IF (i := AScan(aKeys, {|a|a[1] == nctrl .AND. a[2] == nkey})) == 0
         AAdd(aKeys, {nctrl, nkey, block})
      ELSE
         aKeys[i, 3] := block
      ENDIF
   ENDIF

RETURN .T.

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(DLGCOMMAND, HWG_DLGCOMMAND);
HB_FUNC_TRANSLATE(GETMODALDLG, HWG_GETMODALDLG);
HB_FUNC_TRANSLATE(GETMODALHANDLE, HWG_GETMODALHANDLE);
HB_FUNC_TRANSLATE(SETDLGKEY, HWG_SETDLGKEY);
#endif

#pragma ENDDUMP
