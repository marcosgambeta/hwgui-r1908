//
// HWGUI - Harbour Win32 GUI library source code:
// HLine class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HLine INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA lVert
   DATA LineSlant
   DATA nBorder
   DATA oPenLight, oPenGray

   METHOD New(oWndParent, nId, lVert, nLeft, nTop, nLength, bSize, bInit, tcolor, nHeight, cSlant, nBorder)
   METHOD Activate()
   METHOD Paint(lpDis)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HLine:New(oWndParent, nId, lVert, nLeft, nTop, nLength, bSize, bInit, tcolor, nHeight, cSlant, nBorder)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, , , , bInit, bSize, {|o, lp|o:Paint(lp)}, , tcolor)

   ::title := ""
   ::lVert := IIf(lVert == NIL, .F., lVert)
   ::LineSlant := IIf(Empty(cSlant) .OR. !(cSlant $ "/\"), "", cSlant)
   ::nBorder := IIf(Empty(nBorder), 1, nBorder)

   IF Empty(::LineSlant)
      IF ::lVert
         ::nWidth := ::nBorder + 1 //10
         ::nHeight := IIf(nLength == NIL, 20, nLength)
      ELSE
         ::nWidth := IIf(nLength == NIL, 20, nLength)
         ::nHeight := ::nBorder + 1 //10
      ENDIF
      ::oPenLight := HPen():Add(BS_SOLID, 1, hwg_GetSysColor(COLOR_3DHILIGHT))
      ::oPenGray := HPen():Add(BS_SOLID, 1, hwg_GetSysColor(COLOR_3DSHADOW))
   ELSE
      ::nWidth := nLength
      ::nHeight := nHeight
      ::oPenLight := HPen():Add(BS_SOLID, ::nBorder, tColor)
   ENDIF

   ::Activate()

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HLine:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatic(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HLine:Paint(lpdis)

   LOCAL drawInfo := hwg_GetDrawItemInfo(lpdis)
   LOCAL hDC := drawInfo[3]
   LOCAL x1 := drawInfo[4]
   LOCAL y1 := drawInfo[5]
   LOCAL x2 := drawInfo[6]
   LOCAL y2 := drawInfo[7]

   hwg_SelectObject(hDC, ::oPenLight:handle)

   IF Empty(::LineSlant)
      IF ::lVert
         // hwg_DrawEdge(hDC, x1, y1, x1 + 2, y2, EDGE_SUNKEN, BF_RIGHT)
         hwg_DrawLine(hDC, x1 + 1, y1, x1 + 1, y2)
      ELSE
         // hwg_DrawEdge(hDC, x1, y1, x2, y1 + 2, EDGE_SUNKEN, BF_RIGHT)
         hwg_DrawLine(hDC, x1, y1 + 1, x2, y1 + 1)
      ENDIF
      hwg_SelectObject(hDC, ::oPenGray:handle)
      IF ::lVert
         hwg_DrawLine(hDC, x1, y1, x1, y2)
      ELSE
         hwg_DrawLine(hDC, x1, y1, x2, y1)
      ENDIF
   ELSE
      IF (x2 - x1) <= ::nBorder //.OR. ::nWidth <= ::nBorder
         hwg_DrawLine(hDC, x1, y1, x1, y2)
      ELSEIF (y2 - y1) <= ::nBorder //.OR. ::nHeight <= ::nBorder
         hwg_DrawLine(hDC, x1, y1, x2, y1)
      ELSEIF ::LineSlant == "/"
         hwg_DrawLine(hDC, x1, y1 + y2, x1 + x2, y1)
      ELSEIF ::LineSlant == "\"
         hwg_DrawLine(hDC, x1, y1, x1 + x2, y1 + y2)
      ENDIF
    ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//
