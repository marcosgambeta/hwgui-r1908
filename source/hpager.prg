//
// HWGUI - Harbour Win32 GUI library source code:
//
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include "hwgui.ch"

//#define TRANSPARENT 1 // defined in windows.ch

CLASS HPager INHERIT HControl

   DATA winclass INIT "SysPager"
   DATA TEXT, id, nTop, nLeft, nwidth, nheight
   CLASSDATA oSelected INIT NIL
   DATA ExStyle
   DATA bClick
   DATA lVert
   DATA hTool
   DATA m_nWidth, m_nHeight

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
               bSize, bPaint, ctooltip, tcolor, bcolor, lVert)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                    bSize, bPaint, ctooltip, tcolor, bcolor, lVert)
   METHOD SetScrollArea(nWidth, nHeight) INLINE  ::m_nWidth := nWidth, ::m_nHeight := nHeight
   METHOD Activate()
   METHOD Init()

   METHOD Notify(lParam)
   METHOD PAGERSETCHILD(b) INLINE ::hTool := b, hwg_PagerSetChild(::handle, b)
   METHOD PAGERRECALCSIZE() INLINE hwg_PagerRecalcSize(::handle)
   METHOD PAGERFORWARDMOUSE(b) INLINE hwg_PagerForwardMouse(::handle, b)
   METHOD PAGERSETBKCOLOR(b) INLINE hwg_PagerSetBkColor(::handle, b)
   METHOD PAGERGETBKCOLOR() INLINE hwg_PagerGetBkColor(::handle)
   METHOD PAGERSETBORDER(b) INLINE hwg_PagerSetBorder(::handle, b)
   METHOD PAGERGETBORDER() INLINE hwg_PagerGetBorder(::handle)
   METHOD PAGERSETPOS(b) INLINE hwg_PagerSetPos(::handle, b)
   METHOD PAGERGETPOS() INLINE hwg_PagerGetPos(::handle)
   METHOD PAGERSETBUTTONSIZE(b) INLINE hwg_PagerSetButtonSize(::handle, b)
   METHOD PAGERGETBUTTONSIZE() INLINE hwg_PagerGetButtonSize(::handle)
   METHOD PAGERGETBUTTONSTATE() INLINE hwg_PagerGetButtonState(::handle)

ENDCLASS


METHOD HPager:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
            bSize, bPaint, ctooltip, tcolor, bcolor, lvert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT  lvert  TO .F.
   ::lvert := lvert
   nStyle   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), ;
                          WS_VISIBLE + WS_CHILD + IIf(lvert, PGS_VERT, PGS_HORZ))
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()


   ::Activate()

   RETURN Self



METHOD HPager:Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                 bSize, bPaint, ctooltip, tcolor, bcolor, lVert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT  lVert TO .F.
   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()

   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0

   RETURN Self


METHOD HPager:Activate()

   IF !Empty(::oParent:handle)

      ::handle := hwg_CreatePager(::oParent:handle, ::id, ;
                               ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, IIf(::lVert, PGS_VERT, PGS_HORZ))

      ::Init()
   ENDIF
   RETURN NIL

METHOD HPager:Init()

   IF !::lInit
      ::Super:Init()
   ENDIF
   RETURN NIL

METHOD HPager:Notify(lParam)

   LOCAL nCode := hwg_GetNotifyCode(lParam)

   IF nCode == PGN_CALCSIZE
      hwg_PagerOnPagerCalcSize(lParam, ::hTool)
   ELSEIF nCode == PGN_SCROLL
      hwg_PagerOnPagerScroll(lParam)
   ENDIF

   RETURN 0


