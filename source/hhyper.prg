//
// HWGUI - Harbour Win32 GUI library source code:
// HStaticLink class
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

#define _HYPERLINK_EVENT   WM_USER + 101
#define LBL_INIT           0
#define LBL_NORMAL         1
#define LBL_VISITED        2
#define LBL_MOUSEOVER      3
//#define TRANSPARENT        1 // defined in windows.ch

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Class HStaticLink
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
CLASS HStaticLink FROM HSTATIC

   DATA state
   DATA m_bFireChild INIT .F.

   DATA m_hHyperCursor INIT hwg_LoadCursor(32649)

   DATA m_bMouseOver INIT .F.
   DATA m_bVisited INIT .F.

   DATA m_oTextFont
   DATA m_csUrl
   DATA dc

   DATA m_sHoverColor
   DATA m_sLinkColor
   DATA m_sVisitedColor
   
   DATA allMouseOver INIT .F.
   DATA hBitmap
   DATA iStyle         INIT ST_ALIGN_HORIZ  //ST_ALIGN_HORIZ_RIGHT
   DATA lAllUnderline  INIT .T.
   DATA oFontUnder
   DATA llost INIT .F.
   DATA lOverTitle    INIT .F.
   DATA nWidthOver


CLASS VAR winclass INIT "STATIC"

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
               bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor, hbitmap, bClick)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                    bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)
   METHOD Init()
   METHOD onEvent(msg, wParam, lParam)
   METHOD GoToLinkUrl(csLink)
   METHOD GetLinkText()
   METHOD SetLinkUrl(csUrl)
   METHOD GetLinkUrl()
   METHOD SetVisitedColor(sVisitedColor)
   METHOD SetHoverColor(cHoverColor)
   METHOD SetFireChild(lFlag) INLINE ::m_bFireChild := lFlag
   METHOD OnClicked()
   METHOD OnSetCursor(pWnd, nHitTest, message)
   METHOD SetLinkText(csLinkText)
   METHOD SetLinkColor(sLinkColor)
   METHOD PAint(lpDis)
   METHOD OnMouseMove(nFlags, lParam)
   METHOD Resize(x, y)

ENDCLASS

METHOD HStaticLink:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
            bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor, hbitmap, bClick)
   LOCAL oPrevFont

   nStyle := hwg_BitOR(nStyle, SS_NOTIFY + SS_RIGHT)
   ::lAllUnderline := IIf(Empty(cLink), .F., ::lAllUnderline)
   ::title := IIf(cCaption != NIL, cCaption, "HWGUI HomePage")
   ::hbitmap := hbitmap

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, bClick)

   DEFAULT vColor TO hwg_RGB(5, 34, 143)
   DEFAULT lColor TO hwg_RGB(0, 0, 255)
   DEFAULT hColor TO hwg_RGB(255, 0, 0)
   ::m_csUrl := cLink
   ::m_sHoverColor   := hColor
   ::m_sLinkColor    := lColor
   ::m_sVisitedColor := vColor

   ::state := LBL_INIT
   ::title := IIf(cCaption == NIL, "", cCaption)

   // Test The Font the underline must be 1
   IF ::oFont == NIL
      IF ::oParent:oFont != NIL
         ::oFont := HFONT():Add(::oParent:oFont:name, ;
                                ::oParent:oFont:width, ;
                                ::oParent:oFont:height, ;
                                ::oParent:oFont:weight, ;
                                ::oParent:oFont:charset, ;
                                ::oParent:oFont:italic, ;
                                1, ;
                                ::oParent:oFont:StrikeOut)
      ELSE
         ::oFont := HFONT():Add("Arial", 0, -12, , , , IIf(::lAllUnderline, 1,))
      ENDIF
   ELSE
      IF ::oFont:Underline  == 0 .AND. ::lAllUnderline
         oPrevFont := ::oFont
         ::oFont:Release()
         ::oFont := HFONT():Add(oPrevFont:name, ;
                                oPrevFont:width, ;
                                oPrevFont:height, ;
                                oPrevFont:weight, ;
                                oPrevFont:charset, ;
                                oPrevFont:italic, ;
                                1, ;
                                oPrevFont:StrikeOut)
      ENDIF
   ENDIF
   ::oFontUnder := HFONT():Add(::oFont:Name, 0, ::oFont:Height, , , , 1)
   ::nWidthOver := nWidth
   IF lTransp != NIL .AND. lTransp
      //::extStyle += WS_EX_TRANSPARENT
      ::backstyle := WINAPI_TRANSPARENT
   ENDIF

   ::Activate()

   RETURN Self

METHOD HStaticLink:Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                 bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)
   LOCAL oPrevFont

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)

   DEFAULT vColor TO hwg_RGB(5, 34, 143)
   DEFAULT lColor TO hwg_RGB(0, 0, 255)
   DEFAULT hColor TO hwg_RGB(255, 0, 0)
   ::state := LBL_INIT
   ::m_csUrl := cLink
   ::m_sHoverColor   := hColor
   ::m_sLinkColor    := lColor
   ::m_sVisitedColor := vColor

   IF ::oFont == NIL
      IF ::oParent:oFont != NIL
         ::oFont := HFONT():Add(::oParent:oFont:name, ;
                                ::oParent:oFont:width, ;
                                ::oParent:oFont:height, ;
                                ::oParent:oFont:weight, ;
                                ::oParent:oFont:charset, ;
                                ::oParent:oFont:italic, ;
                                1, ;
                                ::oParent:oFont:StrikeOut)
      ENDIF
   ELSE
      IF ::oFont:Underline  == 0
         oPrevFont := ::oFont
         ::oFont:Release()
         ::oFont := HFONT():Add(oPrevFont:name, ;
                                oPrevFont:width, ;
                                oPrevFont:height, ;
                                oPrevFont:weight, ;
                                oPrevFont:charset, ;
                                oPrevFont:italic, ;
                                1, ;
                                oPrevFont:StrikeOut)
      ENDIF
   ENDIF

   ::title   := cCaption
   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0

   IF lTransp != NIL .AND. lTransp
      //::extStyle += WS_EX_TRANSPARENT
      ::backstyle := WINAPI_TRANSPARENT
   ENDIF

   RETURN Self

METHOD HStaticLink:Init()

   IF !::lInit

      /*
      IF ::GetParentForm():Type <= WND_MDICHILD .OR. ::TYPE == NIL
         ::nHolder := 1
         hwg_SetWindowObject(::handle, Self)
       //  hwg_InitWinCtrl(::handle)
         HWG_INITSTATICPROC(::handle)
      ENDIF
      */
      ::Resize()
      ::Super:Init()
      IF ::Title != NIL
         hwg_SetWindowText(::handle, ::title)
      ENDIF

   ENDIF

   RETURN NIL

#if 0 // old code for reference (to be deleted)
METHOD HStaticLink:onEvent(msg, wParam, lParam)

   IF msg == WM_PAINT
      //::PAint()

   ELSEIF msg == WM_MOUSEMOVE
      hwg_SetCursor(::m_hHyperCursor)
     ::OnMouseMove(wParam, lParam)
        /*
         IF ::state != LBL_MOUSEOVER
            //::allMouseOver := .T.
      //      ::state := LBL_MOUSEOVER
            hwg_TrackMousEvent(::handle)
          ELSE
            hwg_TrackMousEvent(::handle, TME_HOVER + TME_LEAVE)
         ENDIF
        */
   ELSEIF (msg == WM_MOUSELEAVE .OR. msg == WM_NCMOUSELEAVE)
        ::state := LBL_NORMAL
   ELSEIF msg == WM_MOUSEHOVER
   ELSEIF msg == WM_SETCURSOR
      ::OnSetCursor(msg, wParam, lParam)

   ELSEIF msg == WM_LBUTTONDOWN
      hwg_SetCursor(::m_hHyperCursor)
      ::OnClicked()
   ELSEIF msg == WM_SIZE

   ENDIF

   RETURN - 1
#else
METHOD HStaticLink:onEvent(msg, wParam, lParam)

   SWITCH msg

   //CASE WM_PAINT
   //   //::PAint()
   //   EXIT

   CASE WM_MOUSEMOVE
      hwg_SetCursor(::m_hHyperCursor)
      ::OnMouseMove(wParam, lParam)
      /*
         IF ::state != LBL_MOUSEOVER
            //::allMouseOver := .T.
      //      ::state := LBL_MOUSEOVER
            hwg_TrackMousEvent(::handle)
          ELSE
            hwg_TrackMousEvent(::handle, TME_HOVER + TME_LEAVE)
         ENDIF
      */
      EXIT

   CASE WM_MOUSELEAVE
   CASE WM_NCMOUSELEAVE
      ::state := LBL_NORMAL
      EXIT

   //CASE WM_MOUSEHOVER
   //   EXIT

   CASE WM_SETCURSOR
      ::OnSetCursor(msg, wParam, lParam)
      EXIT

   CASE WM_LBUTTONDOWN
      hwg_SetCursor(::m_hHyperCursor)
      ::OnClicked()
      //EXIT

   //CASE WM_SIZE

   ENDSWITCH

RETURN -1
#endif

METHOD HStaticLink:GoToLinkUrl(csLink)

   LOCAL hInstance := hwg_ShellExecute(csLink, "open", NIL, NIL, 2)
   //ShellExecute(NULL, _T("open"), csLink.operator LPCTSTR(), NULL, NULL, 2);

   IF hInstance < 33
      RETURN .F.
   ENDIF

   RETURN .T.

METHOD HStaticLink:GetLinkText()

   IF (Empty(::Title))
      RETURN ""
   ENDIF

   RETURN ::Title

METHOD HStaticLink:SetLinkUrl(csUrl)

   ::m_csUrl := csUrl

   RETURN NIL

METHOD HStaticLink:GetLinkUrl()

   RETURN ::m_csUrl

METHOD HStaticLink:SetVisitedColor(sVisitedColor)

   ::m_sVisitedColor := sVisitedColor
   RETURN NIL

METHOD HStaticLink:SetHoverColor(cHoverColor)

   ::m_sHoverColor := cHoverColor

   RETURN NIL

METHOD HStaticLink:OnClicked()
   LOCAL nCtrlID

   IF hb_IsBlock(::bClick)
      ::state := LBL_NORMAL

   ELSEIF !Empty(::m_csUrl)
      IF (::m_bFireChild)
         nCtrlID := ::id
         ::SendMessage(::oparent:handle, _HYPERLINK_EVENT, nCtrlID, 0)
      ELSE
         ::GoToLinkUrl(::m_csUrl)
      ENDIF
      ::m_bVisited := .T.
   ENDIF
   ::state := LBL_NORMAL
   hwg_InvalidateRect(::handle, 0)
   hwg_RedrawWindow(::oParent:handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT, ::nLeft, ::nTop, ::nWidth, ::nHeight)
   ::SetFocus()

   RETURN NIL

METHOD HStaticLink:OnSetCursor(pWnd, nHitTest, message)

   HB_SYMBOL_UNUSED(pWnd)
   HB_SYMBOL_UNUSED(nHitTest)
   HB_SYMBOL_UNUSED(message)

   hwg_SetCursor(::m_hHyperCursor)

   RETURN .T.

METHOD HStaticLink:SetLinkText(csLinkText)

   ::Title := csLinkText
   ::SetText(csLinkText)

   RETURN NIL

METHOD HStaticLink:SetLinkColor(sLinkColor)

   ::m_sLinkColor := sLinkColor

   RETURN NIL

METHOD HStaticLink:OnMouseMove(nFlags, lParam)

   LOCAL xPos
   LOCAL yPos
   LOCAL res  := .F.

   HB_SYMBOL_UNUSED(nFlags)

   IF ::state != LBL_INIT
      xPos := hwg_LOWORD(lParam)
      yPos := hwg_HIWORD(lParam)
      IF (!hwg_PtInRect({0, 0, ::nWidthOver, ::nHeight}, {xPos, yPos})) .AND. ::state != LBL_MOUSEOVER
          res := .T.
      ELSE
        hwg_SetCursor(::m_hHyperCursor)
        IF (!hwg_PtInRect({4, 4, ::nWidthover - 6, ::nHeight - 6}, {xPos, yPos}))
           //hwg_ReleaseCapture()
           res := .T.
        ENDIF
      ENDIF
      IF (res .AND. !::m_bVisited) .OR. (res .AND. ::m_bVisited)
         ::state := LBL_NORMAL
         hwg_InvalidateRect(::handle, 0)
         hwg_RedrawWindow(::oParent:handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ENDIF
      IF (::state == LBL_NORMAL .AND. !res) .OR. ;
         (::state == LBL_NORMAL .AND. !res .AND. ::m_bVisited)
         ::state := LBL_MOUSEOVER
         hwg_InvalidateRect(::handle, 0)
         hwg_RedrawWindow(::oParent:handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT, ::nLeft, ::nTop, ::nWidth, ::nHeight)
         //hwg_SetCapture(::handle)
      ENDIF

   ENDIF

   RETURN NIL

METHOD HStaticLink:Paint(lpDis)

   LOCAL drawInfo := hwg_GetDrawItemInfo(lpDis)
   LOCAL dc := drawInfo[3]
   LOCAL strtext := ::Title
   //LOCAL nOldBkMode
   LOCAL dwFlags
   //LOCAL clrOldText
   LOCAL rcClient
   //LOCAL POLDFONT
   //LOCAL DWSTYLE
   LOCAL bHasTitle
   LOCAL aBmpSize := IIf(!Empty(::hbitmap), hwg_GetBitmapSize(::hbitmap), {0, 0})
   LOCAL itemRect := hwg_CopyRect({drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7]})
   LOCAL captionRect := {drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7]}
   LOCAL bmpRect

   IF ::state == LBL_INIT
      ::State := LBL_NORMAL
   ENDIF
   rcClient := hwg_CopyRect({drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7]})

   IF hb_IsNumeric(::hbitmap)
      bHasTitle := hb_IsChar(strtext) .AND. !Empty(strtext)
      itemRect[4] := aBmpSize[2] + 1
      bmpRect := hwg_PrepareImageRect(::handle, dc, bHasTitle, @itemRect, @captionRect, , , ::hbitmap, ::iStyle)
      itemRect[4] := drawInfo[7]
      IF ::backstyle == WINAPI_TRANSPARENT
         hwg_DrawTransparentBitmap(dc, ::hbitmap, bmpRect[1], bmpRect[2])
      ELSE
         hwg_DrawBitmap(dc, ::hbitmap, , bmpRect[1], bmpRect[2])
      ENDIF
      rcclient[1] +=  IIf(::iStyle == ST_ALIGN_HORIZ, aBmpSize[1] + 8, 1)
   ENDIF
   hwg_SetBkMode(DC, ::backstyle)
   IF ::backstyle != WINAPI_TRANSPARENT
       hwg_SetBkColor(DC, IIf(::bColor == NIL, hwg_GetSysColor(COLOR_3DFACE), ::bcolor))
       hwg_FillRect(dc, rcclient[1], rcclient[2], rcclient[3], rcclient[4]) //, ::brush:handle)
   ENDIF
   dwFlags    := DT_LEFT + DT_WORDBREAK
   //dwstyle    := ::style
   dwFlags  += (DT_VCENTER + DT_END_ELLIPSIS)
   
   //::dc:SelectObject(::oFont:handle)
   hwg_SelectObject(dc, ::oFont:handle)
   IF ::state == LBL_NORMAL
      IF ::m_bVisited
         //::dc:SetTextColor(::m_sVisitedColor)
         hwg_SetTextColor(DC, ::m_sVisitedColor)
      ELSE
         //::dc:SetTextColor(::m_sLinkColor)
         hwg_SetTextColor(DC, ::m_sLinkColor)
      ENDIF
   ELSEIF ::state == LBL_MOUSEOVER
      //::dc:SetTextColor(::m_sHoverColor)
      hwg_SetTextColor(DC, ::m_sHoverColor)
   ENDIF

   //::dc:DrawText(strtext, rcClient, dwFlags)
   IF ::state == LBL_MOUSEOVER .AND. !::lAllUnderline
      hwg_SelectObject(DC, ::oFontUnder:handle)
      hwg_DrawText(dc, strText, rcClient, dwFlags)
      hwg_SelectObject(DC, ::oFont:handle)
   ELSE
      hwg_DrawText(dc, strText, rcClient, dwFlags)
   ENDIF

  // ::dc:End()

  RETURN NIL


METHOD HStaticLink:Resize(x, y)
   //LOCAL aCoors := hwg_GetClientRect(::handle)
   LOCAL aBmpSize, aTxtSize
   LOCAL nHeight := ::nHeight
   
   IF x != NIL .AND. x + y == 0
      RETURN NIL
   ENDIF

   x := IIf(x == NIL, 0, x - ::nWidth + 1)
   aBmpSize := IIf(!Empty(::hbitmap), hwg_GetBitmapSize(::hbitmap), {0, 0})
   aBmpSize[1] += IIf(aBmpSize[1] > 0, 6, 0)
   ::Move(, , ::nWidth + x, , 0)
   aTxtSize := hwg_TxtRect(::Title, Self)
   aTxtSize[2] += IIf(::lAllUnderline, 0, 3)
   IF aTxtSize[1] + 1  <  ::nWidth - aBmpSize[1] //tava 20
      ::nHeight := aTxtSize[2] + 2
   ELSE
      ::nHeight := aTxtSize[2] * 2 + 1
   ENDIF
   ::nWidthOver  := MIN(aTxtSize[1] + 1 + aBmpSize[1], ::nWidth)
   ::nHeight := MAX(::nHeight, aTxtSize[2])
   ::nHeight := MAX(::nHeight, aBmpSize[2] + 4)

   IF nHeight != ::nHeight
      ::Move(, , , ::nHeight, 0)
      hwg_InvalidateRect(::handle, 0)
   ENDIF

   RETURN NIL
