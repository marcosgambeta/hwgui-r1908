//
// HWGUI - Harbour Win32 GUI library source code:
// HControl class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

#define CONTROL_FIRST_ID 34000
//#define TRANSPARENT 1 // defined in windows.ch

//-------------------------------------------------------------------------------------------------------------------//

CLASS HControl INHERIT HCustomWindow

   DATA id
   DATA tooltip
   DATA lInit INIT .F.
   DATA lnoValid INIT .F.
   DATA lnoWhen INIT .F.
   DATA nGetSkip INIT 0
   DATA Anchor INIT 0
   DATA BackStyle INIT OPAQUE
   DATA lNoThemes INIT .F.
   DATA DisablebColor
   DATA DisableBrush
   DATA xControlSource
   DATA xName HIDDEN
   ACCESS Name INLINE ::xName
   ASSIGN Name(cName) INLINE ::AddName(cName)

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip, tcolor, ;
      bColor)
   METHOD Init()
   METHOD AddName(cName) HIDDEN
   //METHOD SetColor(tcolor, bColor, lRepaint)
   METHOD NewId()
   METHOD Show(nShow) INLINE ::Super:Show(nShow), IIf(::oParent:lGetSkipLostFocus, ;
      hwg_PostMessage(hwg_GetActiveWindow(), WM_NEXTDLGCTL, IIf(::oParent:FindControl(, hwg_GetFocus()) != NIL, ;
      0, ::handle), 1), .T.)
   METHOD Hide() INLINE (::oParent:lGetSkipLostFocus := .F., ::Super:Hide())
   //METHOD Disable() INLINE hwg_EnableWindow(::handle, .F.)
   METHOD Disable() INLINE (IIf(hwg_SelfFocus(::handle), hwg_SendMessage(hwg_GetActiveWindow(), WM_NEXTDLGCTL, 0, 0),), ;
      hwg_EnableWindow(::handle, .F.))
   METHOD Enable()
   METHOD IsEnabled() INLINE hwg_IsWindowEnabled(::handle)
   METHOD Enabled(lEnabled) SETGET
   METHOD SetFont(oFont)
   METHOD SetFocus(lValid)
   METHOD GetText() INLINE hwg_GetWindowText(::handle)
   METHOD SetText(c) INLINE hwg_SetWindowText(::handle, c), ::title := c, ::Refresh()
   #ifdef __SYGECOM__   
      METHOD VarGet()      INLINE ::GetText()
   #endif      
   METHOD Refresh() VIRTUAL
   METHOD onAnchor(x, y, w, h)
   METHOD SetToolTip(ctooltip)
   METHOD ControlSource(cControlSource) SETGET
   METHOD DisableBackColor(DisableBColor) SETGET
   METHOD FontBold(lTrue) SETGET
   METHOD FontItalic(lTrue) SETGET
   METHOD FontUnderline(lTrue) SETGET
   METHOD End()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip, tcolor, ;
   bColor)

   ::oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id := IIf(nId == NIL, ::NewId(), nId)
   ::style := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_VISIBLE + WS_CHILD)
   ::nLeft := IIf(nLeft == NIL, 0, nLeft)
   ::nTop := IIf(nTop == NIL, 0, nTop)
   ::nWidth := IIf(nWidth == NIL, 0, nWidth)
   ::nHeight := IIf(nHeight == NIL, 0, nHeight)
   ::oFont := oFont
   ::bInit := bInit
   ::bSize := bSize
   ::bPaint := bPaint
   ::tooltip := cTooltip

   ::SetColor(tcolor, bColor)
   ::oParent:AddControl(Self)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:NewId()

   LOCAL oParent := ::oParent
   LOCAL i := 0
   LOCAL nId

   DO WHILE oParent != NIL
      nId := CONTROL_FIRST_ID + 1000 * i + Len(::oParent:aControls)
      oParent := oParent:oParent
      i++
   ENDDO
   IF AScan(::oParent:aControls, {|o|o:id == nId}) != 0
      nId--
      DO WHILE nId >= CONTROL_FIRST_ID .AND. AScan(::oParent:aControls, {|o|o:id == nId}) != 0
         nId--
      ENDDO
   ENDIF

RETURN nId

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:AddName(cName)

   IF !Empty(cName) .AND. hb_IsChar(cName) .AND. !(":" $ cName) .AND. !("[" $ cName) .AND. !("->" $ cName)
      ::xName := cName
      __objAddData(::oParent, cName)
      ::oParent:&(cName) := Self
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:Init()

   LOCAL oForm := ::GetParentForm()

   IF !::lInit
      //IF ::tooltip != NIL
      //   hwg_AddToolTip(::oParent:handle, ::handle, ::tooltip)
      //ENDIF
      ::oparent:lSuspendMsgsHandling := .T.
      IF Len(::aControls) == 0 .AND. ::winclass != "SysTabControl32" .AND. !hb_IsNumeric(oForm)
         hwg_AddToolTip(oForm:handle, ::handle, ::tooltip)
      ENDIF
      ::oparent:lSuspendMsgsHandling := .F.
      IF ::oFont != NIL .AND. !hb_IsNumeric(::oFont) .AND. ::oParent != NIL
         hwg_SetCtrlFont(::oParent:handle, ::id, ::oFont:handle)
      ELSEIF oForm != NIL .AND. !hb_IsNumeric(oForm) .AND. oForm:oFont != NIL
         hwg_SetCtrlFont(::oParent:handle, ::id, oForm:oFont:handle)
      ELSEIF ::oParent != NIL .AND. ::oParent:oFont != NIL
         hwg_SetCtrlFont(::handle, ::id, ::oParent:oFont:handle)
      ENDIF
      IF oForm != NIL .AND. oForm:Type != WND_DLG_RESOURCE .AND. (::nLeft + ::nTop + ::nWidth + ::nHeight != 0)
         // fix init position in FORM reduce  flickering
         hwg_SetWindowPos(::handle, NIL, ::nLeft, ::nTop, ::nWidth, ::nHeight, SWP_NOACTIVATE + SWP_NOSIZE + SWP_NOZORDER + SWP_NOOWNERZORDER + SWP_NOSENDCHANGING) //+ SWP_DRAWFRAME)
      ENDIF

      IF hb_IsBlock(::bInit)
        ::oparent:lSuspendMsgsHandling := .T.
        Eval(::bInit, Self)
        ::oparent:lSuspendMsgsHandling := .F.
      ENDIF
      IF ::lnoThemes
         HWG_SETWINDOWTHEME(::handle, 0)
      ENDIF

      ::lInit := .T.
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

#if 0 // moved to HCWINDOW
METHOD HControl:SetColor(tcolor, bColor, lRepaint)

   IF tcolor != NIL
      ::tcolor := tcolor
      IF bColor == NIL .AND. ::bColor == NIL
         bColor := hwg_GetSysColor(COLOR_3DFACE)
      ENDIF
   ENDIF

   IF bColor != NIL
      ::bColor := bColor
      IF ::brush != NIL
         ::brush:Release()
      ENDIF
      ::brush := HBrush():Add(bColor)
   ENDIF

   IF lRepaint != NIL .AND. lRepaint
      hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   ENDIF

RETURN NIL
#endif

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:SetFocus(lValid)

   LOCAL lSuspend := ::oParent:lSuspendMsgsHandling

   IF !hwg_IsWindowEnabled(::handle)
      ::oParent:lSuspendMsgsHandling := .T.
      //hwg_GetSkip(::oParent, ::handle, , 1)
      hwg_SendMessage(hwg_GetActiveWindow(), WM_NEXTDLGCTL, 0, 0)
      ::oParent:lSuspendMsgsHandling := lSuspend
   ELSE
      ::oParent:lSuspendMsgsHandling := !Empty(lValid)
      IF ::GetParentForm():Type < WND_DLG_RESOURCE
         hwg_SetFocus(::handle)
      ELSE
         hwg_SendMessage(hwg_GetActiveWindow(), WM_NEXTDLGCTL, ::handle, 1)
      ENDIF
      ::oParent:lSuspendMsgsHandling := lSuspend
   ENDIF
   IF ::GetParentForm():Type < WND_DLG_RESOURCE
      ::GetParentForm():nFocus := ::handle
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:Enable()

   LOCAL lEnable := hwg_IsWindowEnabled(::handle)
   LOCAL nPos
   LOCAL nNext

   hwg_EnableWindow(::handle, .T.)
   IF ::oParent:lGetSkipLostFocus .AND. !lEnable .AND. hwg_BitaND(hwg_GetWindowStyle(::handle), WS_TABSTOP) > 0
      nNext := AScan(::oParent:aControls, {|o|hwg_PtrToUlong(o:handle) == hwg_PtrToUlong(hwg_GetFocus())})
      nPos := AScan(::oParent:acontrols, {|o|hwg_PtrToUlong(o:handle) == hwg_PtrToUlong(::handle)})
      IF nPos < nNext
         hwg_SendMessage(hwg_GetActiveWindow(), WM_NEXTDLGCTL, ::handle, 1)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:DisableBackColor(DisableBColor)

   IF DisableBColor != NIL
      ::DisableBColor := DisableBColor
      IF ::Disablebrush != NIL
         ::Disablebrush:Release()
      ENDIF
      ::Disablebrush := HBrush():Add(::DisableBColor)
      IF !::IsEnabled() .AND. hwg_IsWindowVisible(::handle)
         hwg_InvalidateRect(::handle, 0)
      ENDIF
   ENDIF

RETURN ::DisableBColor

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:SetFont(oFont)

   IF oFont != NIL
      IF hb_IsObject(oFont)
         ::oFont := oFont:SetFontStyle()
         hwg_SetWindowFont(::handle, ::oFont:handle, .T.)
      ENDIF
   ELSEIF ::oParent:oFont != NIL
      hwg_SetWindowFont(::handle, ::oParent:oFont:handle, .T.)
   ENDIF

RETURN ::oFont

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:FontBold(lTrue)

   LOCAL oFont

   IF ::oFont == NIL
      IF ::GetParentForm() != NIL .AND. ::GetParentForm():oFont != NIL
         oFont := ::GetParentForm():oFont
      ELSEIF ::oParent:oFont != NIL
         oFont := ::oParent:oFont
      ENDIF
      IF oFont == NIL .AND. lTrue == NIL
          RETURN .T.
      ENDIF
      ::oFont := IIf(oFont != NIL, HFont():Add(oFont:name, oFont:Width), ;
         HFont():Add("", 0, , IIf(!Empty(lTrue), FW_BOLD, FW_REGULAR)))
   ENDIF
   IF lTrue != NIL
      ::oFont := ::oFont:SetFontStyle(lTrue)
      hwg_SendMessage(::handle, WM_SETFONT, ::oFont:handle, hwg_MAKELPARAM(0, 1))
      hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_INVALIDATE + RDW_FRAME + RDW_INTERNALPAINT)
   ENDIF

RETURN ::oFont:weight == FW_BOLD

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:FontItalic(lTrue)

   LOCAL oFont

   IF ::oFont == NIL
      IF ::GetParentForm() != NIL .AND. ::GetParentForm():oFont != NIL
         oFont := ::GetParentForm():oFont
      ELSEIF ::oParent:oFont != NIL
         oFont := ::oParent:oFont
      ENDIF
      IF oFont == NIL .AND. lTrue == NIL
          RETURN .F.
      ENDIF
      ::oFont := IIf(oFont != NIL, HFont():Add(oFont:name, oFont:width, , , , IIf(lTrue, 1, 0)), ;
         HFont():Add("", 0, , , , IIf(lTrue, 1, 0)))
   ENDIF
   IF lTrue != NIL
      ::oFont := ::oFont:SetFontStyle(, , lTrue)
      hwg_SendMessage(::handle, WM_SETFONT, ::oFont:handle, hwg_MAKELPARAM(0, 1))
      hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_INVALIDATE + RDW_FRAME + RDW_INTERNALPAINT)
   ENDIF

RETURN ::oFont:Italic == 1

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:FontUnderline(lTrue)

   LOCAL oFont

   IF ::oFont == NIL
      IF ::GetParentForm() != NIL .AND. ::GetParentForm():oFont != NIL
         oFont := ::GetParentForm():oFont
      ELSEIF ::oParent:oFont != NIL
         oFont := ::oParent:oFont
      ENDIF
      IF oFont == NIL .AND. lTrue == NIL
         RETURN .F.
      ENDIF
      ::oFont := IIf(oFont != NIL, HFont():Add(oFont:name, oFont:width, , , , , IIf(lTrue, 1, 0)), ;
         HFont():Add("", 0, , , , , IIf(lTrue, 1, 0)))
   ENDIF
   IF lTrue != NIL
      ::oFont := ::oFont:SetFontStyle(, , , lTrue)
      hwg_SendMessage(::handle, WM_SETFONT, ::oFont:handle, hwg_MAKELPARAM(0, 1))
      hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_INVALIDATE + RDW_FRAME + RDW_INTERNALPAINT)
   ENDIF

RETURN ::oFont:Underline == 1

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:SetToolTip (cToolTip)

   IF hb_IsChar(cToolTip) .AND. cToolTip != ::ToolTip
      hwg_SetToolTipTitle(::GetparentForm():handle, ::handle, ctooltip)
      ::Tooltip := cToolTip
   ENDIF

RETURN ::tooltip

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:Enabled(lEnabled)

  IF lEnabled != NIL
     IF lEnabled
        ::enable()
     ELSE
        ::disable()
     ENDIF
  ENDIF

RETURN ::isEnabled()

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:ControlSource(cControlSource)

   LOCAL temp

   IF cControlSource != NIL .AND. !Empty(cControlSource) .AND. __objHasData(Self, "BSETGETFIELD")
      ::xControlSource := cControlSource
      temp := SubStr(cControlSource, At("->", cControlSource) + 2)
      ::bSetGetField := IIf("->" $ cControlSource, FieldWBlock(temp, SELECT(SubStr(cControlSource, 1, ;
         At("->", cControlSource) - 1))), FieldBlock(cControlSource))
   ENDIF

RETURN ::xControlSource

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:End()

   ::Super:End()

   IF ::tooltip != NIL
      hwg_DelToolTip(::oParent:handle, ::handle)
      ::tooltip := NIL
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HControl:onAnchor(x, y, w, h)

   LOCAL nAnchor
   LOCAL nXincRelative
   LOCAL nYincRelative
   LOCAL nXincAbsolute
   LOCAL nYincAbsolute
   LOCAL x1
   LOCAL y1
   LOCAL w1
   LOCAL h1
   LOCAL x9
   LOCAL y9
   LOCAL w9
   LOCAL h9
   LOCAL nCxv := IIf(HWG_BITAND(::style, WS_VSCROLL) != 0, hwg_GetSystemMetrics(SM_CXVSCROLL) + 1, 3)
   LOCAL nCyh := IIf(HWG_BITAND(::style, WS_HSCROLL) != 0, hwg_GetSystemMetrics(SM_CYHSCROLL) + 1, 3)

   nAnchor := ::anchor
   x9 := ::nLeft
   y9 := ::nTop
   w9 := ::nWidth  //- IIf(::winclass = "EDIT" .AND. __ObjHasMsg(Self, "hwndUpDown", hwg_GetClientRect(::hwndUpDown)[3], 0)
   h9 := ::nHeight

   x1 := ::nLeft
   y1 := ::nTop
   w1 := ::nWidth  //- IIf(::winclass = "EDIT" .AND. __ObjHasMsg(Self, "hwndUpDown"), hwg_GetClientRect(::hwndUpDown)[3], 0)
   h1 := ::nHeight
   //- calculo relativo
   IF x > 0
      nXincRelative := w / x
   ENDIF
   IF y > 0
      nYincRelative := h / y
   ENDIF
   //- calculo ABSOLUTE
   nXincAbsolute := (w - x)
   nYincAbsolute := (h - y)

   IF nAnchor >= ANCHOR_VERTFIX
      //- vertical fixed center
      nAnchor := nAnchor - ANCHOR_VERTFIX
      y1 := y9 + Round((h - y) * ((y9 + h9 / 2) / y), 2)
   ENDIF
   IF nAnchor >= ANCHOR_HORFIX
      //- horizontal fixed center
      nAnchor := nAnchor - ANCHOR_HORFIX
      x1 := x9 + Round((w - x) * ((x9 + w9 / 2) / x), 2)
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTREL
      // relative - RIGHT RELATIVE
      nAnchor := nAnchor - ANCHOR_RIGHTREL
      x1 := w - Round((x - x9 - w9) * nXincRelative, 2) - w9
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMREL
      // relative - BOTTOM RELATIVE
      nAnchor := nAnchor - ANCHOR_BOTTOMREL
      y1 := h - Round((y - y9 - h9) * nYincRelative, 2) - h9
   ENDIF
   IF nAnchor >= ANCHOR_LEFTREL
      // relative - LEFT RELATIVE
      nAnchor := nAnchor - ANCHOR_LEFTREL
      IF x1 != x9
         w1 := x1 - (Round(x9 * nXincRelative, 2)) + w9
      ENDIF
      x1 := Round(x9 * nXincRelative, 2)
   ENDIF
   IF nAnchor >= ANCHOR_TOPREL
      // relative  - TOP RELATIVE
      nAnchor := nAnchor - ANCHOR_TOPREL
      IF y1 != y9
         h1 := y1 - (Round(y9 * nYincRelative, 2)) + h9
      ENDIF
      y1 := Round(y9 * nYincRelative, 2)
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTABS
      // Absolute - RIGHT ABSOLUTE
      nAnchor := nAnchor - ANCHOR_RIGHTABS
      IF HWG_BITAND(::Anchor, ANCHOR_LEFTREL) != 0
         w1 := INT(nxIncAbsolute) - (x1 - x9) + w9
      ELSE
         IF x1 != x9
            w1 := x1 - (x9 +  INT(nXincAbsolute)) + w9
         ENDIF
         x1 := x9 +  INT(nXincAbsolute)
      ENDIF
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMABS
      // Absolute - BOTTOM ABSOLUTE
      nAnchor := nAnchor - ANCHOR_BOTTOMABS
      IF HWG_BITAND(::Anchor, ANCHOR_TOPREL) != 0
         h1 := INT(nyIncAbsolute) - (y1 - y9) + h9
      ELSE
         IF y1 != y9
            h1 := y1 - (y9 +  Int(nYincAbsolute)) + h9
         ENDIF
         y1 := y9 +  Int(nYincAbsolute)
      ENDIF
   ENDIF
   IF nAnchor >= ANCHOR_LEFTABS
      // Absolute - LEFT ABSOLUTE
      nAnchor := nAnchor - ANCHOR_LEFTABS
      IF x1 != x9
         w1 := x1 - x9 + w9
      ENDIF
      x1 := x9
   ENDIF
   IF nAnchor >= ANCHOR_TOPABS
      // Absolute - TOP ABSOLUTE
      //nAnchor := nAnchor - 1
      IF y1 != y9
         h1 := y1 - y9 + h9
      ENDIF
      y1 := y9
   ENDIF
   // REDRAW AND INVALIDATE SCREEN
   IF x1 != X9 .OR. y1 != y9 .OR. w1 != w9 .OR. h1 != h9
      IF hwg_IsWindowVisible(::handle)
         IF (x1 != x9 .OR. y1 != y9) .AND. x9 < ::oParent:nWidth
            hwg_InvalidateRect(::oParent:handle, 1, MAX(x9 - 1, 0), MAX(y9 - 1, 0), x9 + w9 + nCxv, y9 + h9 + nCyh)
         ELSE
             IF w1 < w9
                hwg_InvalidateRect(::oParent:handle, 1, x1 + w1 - nCxv - 1, MAX(y1 - 2, 0), x1 + w9 + 2, y9 + h9 + nCxv + 1)
             ENDIF
             IF h1 < h9
                hwg_InvalidateRect(::oParent:handle, 1, MAX(x1 - 5, 0), y1 + h1 - nCyh - 1, x1 + w9 + 2, y1 + h9 + nCYh)
             ENDIF
         ENDIF
         //::Move(x1, y1, w1, h1, HWG_BITAND(::Style, WS_CLIPSIBLINGS + WS_CLIPCHILDREN) == 0)

         IF ((x1 != x9 .OR. y1 != y9) .AND. (hb_IsBlock(::bPaint) .OR. x9 + w9 > ::oParent:nWidth)) .OR. ;
            (::backstyle == WINAPI_TRANSPARENT .AND. (::Title != NIL .AND. !Empty(::Title))) .OR. __ObjHasMsg(Self, "oImage")
            IF __ObjHasMsg(Self, "oImage") .OR. ::backstyle == WINAPI_TRANSPARENT //.OR. w9 != w1
               hwg_InvalidateRect(::oParent:handle, 1, MAX(x1 - 1, 0), MAX(y1 - 1, 0), x1 + w1 + 1, y1 + h1 + 1)
            ELSE
               hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_INVALIDATE + RDW_INTERNALPAINT)
            ENDIF
         ELSE
             IF Len(::aControls) == 0 .AND. ::Title != NIL
               hwg_InvalidateRect(::handle, 0)
             ENDIF
             IF w1 > w9
                hwg_InvalidateRect(::oParent:handle, 1, MAX(x1 + w9 - nCxv - 1, 0), MAX(y1, 0), x1 + w1 + nCxv, y1 + h1 + 2)
             ENDIF
             IF h1 > h9
                hwg_InvalidateRect(::oParent:handle, 1, MAX(x1, 0), MAX(y1 + h9 - nCyh - 1, 1), x1 + w1 + 2, y1 + h1 + nCyh)
             ENDIF
         ENDIF
         // redefine new position e new size
         ::Move(x1, y1, w1, h1, HWG_BITAND(::Style, WS_CLIPSIBLINGS + WS_CLIPCHILDREN) == 0)
         IF ::winClass == "ToolbarWindow32" .OR. ::winClass == "msctls_statusbar32"
            ::Resize(nXincRelative, w1 != w9, h1 != h9)
         ENDIF
      ELSE
         ::Move(x1, y1, w1, h1, 0)
         IF ::winClass == "ToolbarWindow32" .OR. ::winClass == "msctls_statusbar32"
            ::Resize(nXincRelative, w1 != w9, h1 != h9)
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

INIT PROCEDURE hwg_StartTheme()

   hwg_InitThemeLib()

RETURN

//-------------------------------------------------------------------------------------------------------------------//

EXIT PROCEDURE hgw_EndTheme()

   hwg_EndThemeLib()

RETURN

//-------------------------------------------------------------------------------------------------------------------//
