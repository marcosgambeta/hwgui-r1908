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

CLASS hrebar INHERIT HControl

   DATA winclass INIT "ReBarWindow32"
   DATA TEXT, id, nTop, nLeft, nwidth, nheight
   CLASSDATA oSelected INIT NIL
   DATA ExStyle
   DATA bClick
   DATA lVert
   DATA hTool
   DATA m_nWidth, m_nHeight
   DATA aBands INIT  {}

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
               bSize, bPaint, ctooltip, tcolor, bcolor, lVert)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                    bSize, bPaint, ctooltip, tcolor, bcolor, lVert)

   METHOD Activate()
   METHOD Init()
   METHOD ADDBARColor(pBar, clrFore, clrBack, pszText, dwStyle) INLINE hwg_AddBarColors(::handle, pBar, clrFore, clrBack, pszText, dwStyle)
   METHOD ADDBARBITMAP(pBar, pszText, pbmp, dwStyle) INLINE hwg_AddBarBitmap(::handle, pBar, pszText, pbmp, dwStyle)
   METHOD RebarBandNew(pBar, pszText, clrFore, clrBack, pbmp, dwStyle) INLINE ::CreateBands(pBar, pszText, clrFore, clrBack, pbmp, dwStyle)
   METHOD CreateBands(pBar, pszText, clrFore, clrBack, pbmp, dwStyle)

ENDCLASS


METHOD HRebar:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
            bSize, bPaint, ctooltip, tcolor, bcolor, lvert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT  lvert  TO .F.
   nStyle   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), ;
                          WS_VISIBLE + WS_CHILD)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)
   ::Title := ""
   HWG_InitCommonControlsEx()


   ::Activate()

   RETURN Self



METHOD HRebar:Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                 bSize, bPaint, ctooltip, tcolor, bcolor, lVert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT  lVert TO .F.
   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()

   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0

   RETURN Self


METHOD HRebar:Activate()

   IF !Empty(::oParent:handle)

      ::handle := CREATEREBAR(::oParent:handle, ::id, ;
                               ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)

      ::Init()
   ENDIF
   RETURN NIL

METHOD HRebar:Init()

   IF !::lInit
      ::Super:Init()
      ::CreateBands()
//      hwg_ReBarSetImageList(::handle, NIL)
   ENDIF
   RETURN NIL


METHOD HRebar:CreateBands(pBar, pszText, clrFore, clrBack, pbmp, dwStyle)
   LOCAL i

   IF pBar != NIL
      AAdd(::aBands, {pBar, pszText, clrFore, clrBack, pbmp, dwStyle})
   ENDIF
   IF !::lInit
      RETURN NIL
   ENDIF
   dwStyle := RBBS_GRIPPERALWAYS + RBBS_USECHEVRON
   FOR i := 1 TO Len(::aBands)
      ::aBands[i, 4] := IIf(::aBands[i, 4] == NIL, hwg_GetSysColor(COLOR_3DFACE), ::aBands[i, 4])
      ::aBands[i, 6] := IIf(::aBands[i, 6] == NIL, dwStyle, ::aBands[i, 6])
      IF !Empty(::aBands[i, 1])
         ::aBands[i, 1] := IIf(hb_IsChar(::aBands[i, 1]), &(::aBands[i, 1]), ::aBands[i, 1])
         IF (::aBands[i, 5] != NIL)
            hwg_AddBarBitmap(::handle, ::aBands[i, 1]:handle, ::aBands[i, 2], ::aBands[i, 5], ::aBands[i, 6])
         ELSE
           hwg_AddBarColors(::handle, ::aBands[i, 1]:handle, ::aBands[i, 3], ::aBands[i, 4], ::aBands[i, 2], ::aBands[i, 6])
         ENDIF
      ENDIF
   NEXT
   ::aBands := {}
   RETURN NIL