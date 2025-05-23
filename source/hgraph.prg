//
// HWGUI - Harbour Win32 GUI library source code:
// HGraph class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HGraph INHERIT HControl

CLASS VAR winclass   INIT "STATIC"
   DATA aValues
   DATA nGraphs INIT 1
   DATA nType
   DATA lGrid   INIT .F.
   DATA scaleX, scaleY
   DATA ymaxSet
   DATA tbrush
   DATA colorCoor INIT 16777215
   DATA oPen, oPenCoor
   DATA xmax, ymax, xmin, ymin PROTECTED

   METHOD New(oWndParent, nId, aValues, nLeft, nTop, nWidth, nHeight, oFont, ;
               bSize, ctooltip, tcolor, bcolor)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, aValues, oFont, ;
                    bSize, ctooltip, tcolor, bcolor)
   METHOD Init()
   METHOD CalcMinMax()
   METHOD Paint(lpDis)
   METHOD Rebuild(aValues, nType)

ENDCLASS

METHOD HGraph:New(oWndParent, nId, aValues, nLeft, nTop, nWidth, nHeight, oFont, ;
            bSize, ctooltip, tcolor, bcolor)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight, oFont,, ;
              bSize, {|o, lpdis|o:Paint(lpdis)}, ctooltip, ;
              IIf(tcolor == NIL, hwg_VColor("FFFFFF"), tcolor), IIf(bcolor == NIL, 0, bcolor))

   ::aValues := aValues
   ::nType   := 1
   ::nGraphs := 1

   ::Activate()

   RETURN Self

METHOD HGraph:Redefine(oWndParent, nId, aValues, oFont, ;
                 bSize, ctooltip, tcolor, bcolor)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, 0, 0, 0, 0, oFont,, ;
              bSize, {|o, lpdis|o:Paint(lpdis)}, ctooltip, ;
              IIf(tcolor == NIL, hwg_VColor("FFFFFF"), tcolor), IIf(bcolor == NIL, 0, bcolor))

   ::aValues := aValues

   RETURN Self

METHOD HGraph:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatic(::oParent:handle, ::id, ;
                                ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HGraph:Init()
   IF !::lInit
      ::Super:Init()
      ::CalcMinMax()
   ENDIF
   RETURN NIL

METHOD HGraph:CalcMinMax()
   LOCAL i, j, nLen
   ::xmax := ::xmin := ::ymax := ::ymin := 0
   IF ::ymaxSet != NIL .AND. ::ymaxSet != 0
      ::ymax := ::ymaxSet
   ENDIF
   FOR i := 1 TO ::nGraphs
      nLen := Len(::aValues[i])
      IF ::nType == 1
         FOR j := 1 TO nLen
            ::xmax := Max(::xmax, ::aValues[i, j, 1])
            ::xmin := Min(::xmin, ::aValues[i, j, 1])
            ::ymax := Max(::ymax, ::aValues[i, j, 2])
            ::ymin := Min(::ymin, ::aValues[i, j, 2])
         NEXT
      ELSEIF ::nType == 2
         FOR j := 1 TO nLen
            ::ymax := Max(::ymax, ::aValues[i, j, 2])
            ::ymin := Min(::ymin, ::aValues[i, j, 2])
         NEXT
         ::xmax := nLen
      ELSEIF ::nType == 3
         FOR j := 1 TO nLen
            ::ymax += ::aValues[i, j, 2]
         NEXT
      ENDIF
   NEXT

   RETURN NIL

METHOD HGraph:Paint(lpdis)

   LOCAL drawInfo := hwg_GetDrawItemInfo(lpdis)
   LOCAL hDC := drawInfo[3]
   LOCAL x1 := drawInfo[4]
   LOCAL y1 := drawInfo[5]
   LOCAL x2 := drawInfo[6]
   LOCAL y2 := drawInfo[7]
   LOCAL i
   LOCAL j
   LOCAL nLen
   LOCAL px1
   LOCAL px2
   LOCAL py1
   LOCAL py2
   LOCAL nWidth

   i := Round((x2 - x1) / 10, 0)
   x1 += i
   x2 -= i
   i := Round((y2 - y1) / 10, 0)
   y1 += i
   y2 -= i

   IF ::nType < 3
      ::scaleX := (::xmax - ::xmin) / (x2 - x1)
      ::scaleY := (::ymax - ::ymin) / (y2 - y1)
   ENDIF

   IF ::oPenCoor == NIL
      ::oPenCoor := HPen():Add(PS_SOLID, 1, ::colorCoor)
   ENDIF
   IF ::oPen == NIL
      ::oPen := HPen():Add(PS_SOLID, 2, ::tcolor)
   ENDIF

   hwg_FillRect(hDC, drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7], ::brush:handle)
   IF ::nType != 3
      hwg_SelectObject(hDC, ::oPenCoor:handle)
      hwg_Drawline(hDC, x1 + (0 - ::xmin) / ::scaleX, drawInfo[5] + 3, x1 + (0 - ::xmin) / ::scaleX, drawInfo[7] - 3)
      hwg_Drawline(hDC, drawInfo[4] + 3, y2 - (0 - ::ymin) / ::scaleY, drawInfo[6] - 3, y2 - (0 - ::ymin) / ::scaleY)
   ENDIF

   IF ::ymax == ::ymin .AND. ::ymax == 0
      RETURN NIL
   ENDIF

   hwg_SelectObject(hDC, ::oPen:handle)
   FOR i := 1 TO ::nGraphs
      nLen := Len(::aValues[i])
      IF ::nType == 1
         FOR j := 2 TO nLen
            px1 := Round(x1 + (::aValues[i, j - 1, 1] - ::xmin) / ::scaleX, 0)
            py1 := Round(y2 - (::aValues[i, j - 1, 2] - ::ymin) / ::scaleY, 0)
            px2 := Round(x1 + (::aValues[i, j, 1] - ::xmin) / ::scaleX, 0)
            py2 := Round(y2 - (::aValues[i, j, 2] - ::ymin) / ::scaleY, 0)
            IF px2 != px1 .OR. py2 != py1
               hwg_Drawline(hDC, px1, py1, px2, py2)
            ENDIF
         NEXT
      ELSEIF ::nType == 2
         IF ::tbrush == NIL
            ::tbrush := HBrush():Add(::tcolor)
         ENDIF
         nWidth := Round((x2 - x1) / (nLen * 2 + 1), 0)
         FOR j := 1 TO nLen
            px1 := Round(x1 + nWidth * (j * 2 - 1), 0)
            py1 := Round(y2 - (::aValues[i, j, 2] - ::ymin) / ::scaleY, 0)
            hwg_FillRect(hDC, px1, y2 - 2, px1 + nWidth, py1, ::tbrush:handle)
         NEXT
      ELSEIF ::nType == 3
         IF ::tbrush == NIL
            ::tbrush := HBrush():Add(::tcolor)
         ENDIF
         hwg_SelectObject(hDC, ::oPenCoor:handle)
         hwg_SelectObject(hDC, ::tbrush:handle)
         hwg_Pie(hDC, x1 + 10, y1 + 10, x2 - 10, y2 - 10, x1, Round(y1 + (y2 - y1) / 2, 0), Round(x1 + (x2 - x1) / 2, 0), y1)
      ENDIF
   NEXT

   RETURN NIL

METHOD HGraph:Rebuild(aValues, nType)

   ::aValues := aValues
   IF nType != NIL
      ::nType := nType
   ENDIF
   ::CalcMinMax()
   hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)

   RETURN NIL
