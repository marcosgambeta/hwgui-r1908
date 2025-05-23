//
// HWGUI - Harbour Win32 GUI library source code:
// HGroup class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//#define TRANSPARENT 1 // defined in windows.ch
#define BS_TYPEMASK SS_TYPEMASK
#define OFS_X 10 // distance from left/right side to beginning/end of text

//-------------------------------------------------------------------------------------------------------------------//

CLASS HGroup INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA oRGroup
   DATA oBrush
   DATA lTransparent HIDDEN

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, ;
      bColor, lTransp, oRGroup)
   METHOD Activate()
   METHOD Init()
   METHOD Paint(lpDis)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGroup:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, ;
   bColor, lTransp, oRGroup)

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), BS_GROUPBOX)

   ::title := cCaption
   ::oRGroup := oRGroup
   #ifdef __SYGECOM__
   ::setcolor(IIF(tcolor == NIL, 16711680, tcolor), bcolor) // define uma cor padr�o quando n�o vem preenchido
   #endif
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint,, tcolor, bColor)

   ::oBrush := IIf(bColor != NIL, ::brush, NIL)
   ::lTransparent := IIf(lTransp != NIL, lTransp, .F.)
   ::backStyle := IIf((lTransp != NIL .AND. lTransp) .OR. ::bColor != NIL, WINAPI_TRANSPARENT, OPAQUE)

   ::Activate()
   //::setcolor(tcolor, bcolor)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGroup:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateButton(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGroup:Init()

   LOCAL nbs

   IF !::lInit
      ::Super:Init()
      //-IF ::backStyle == WINAPI_TRANSPARENT .OR. ::bColor != NIL
      IF ::oBrush != NIL .OR. ::backStyle == WINAPI_TRANSPARENT
         nbs := hwg_GetWindowStyle(::handle)
         nbs := hwg_ModStyle(nbs, BS_TYPEMASK, BS_OWNERDRAW + WS_DISABLED)
         hwg_SetWindowStyle(::handle, nbs)
         ::bPaint := {|o, p|o:paint(p)}
      ENDIF
      IF ::oRGroup != NIL
         ::oRGroup:handle := ::handle
         ::oRGroup:id := ::id
         ::oFont := ::oRGroup:oFont
         ::oRGroup:lInit := .F.
         ::oRGroup:Init()
      ELSE
         IF ::oBrush != NIL
            /*
            nbs := AScan(::oparent:acontrols, {|o|o:handle == ::handle})
            FOR i := Len(::oparent:acontrols) TO 1 STEP -1
               IF nbs != i .AND.;
                   hwg_PtInRect({::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight}, {::oparent:acontrols[i]:nLeft, ::oparent:acontrols[i]:nTop}) //.AND. NOUTOBJS == 0
                   hwg_SetWindowPos(::oparent:acontrols[i]:handle, ::handle, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE + SWP_NOACTIVATE + SWP_FRAMECHANGED)
               ENDIF
            NEXT
            */
            hwg_SetWindowPos(::handle, NIL, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE + SWP_NOACTIVATE)
         ELSE
            hwg_SetWindowPos(::handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE + SWP_NOACTIVATE + SWP_NOSENDCHANGING)
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGroup:PAINT(lpdis)

   LOCAL drawInfo := hwg_GetDrawItemInfo(lpdis)
   LOCAL DC := drawInfo[3]
   LOCAL ppnOldPen
   LOCAL pnFrmDark
   LOCAL pnFrmLight
   LOCAL iUpDist
   LOCAL szText
   LOCAL aSize
   LOCAL dwStyle
   LOCAL rc := hwg_CopyRect({drawInfo[4], drawInfo[5], drawInfo[6] - 1, drawInfo[7] - 1})
   LOCAL rcText

   // determine text length
   szText := ::Title
   aSize := hwg_TxtRect(IIf(Empty(szText), "A", szText), Self)
   // distance from window top to group rect
   iUpDist := (aSize[2] / 2)
   dwStyle := ::Style //hwg_GetWindowStyle(::handle) //GetStyle();
   rcText := {0, rc[2] + iUpDist, 0, rc[2] + iUpDist}
   IF Empty(szText)
   ELSEIF hb_BitAnd(dwStyle, BS_CENTER) == BS_RIGHT // right aligned
      rcText[3] := rc[3] + 2 - OFS_X
      rcText[1] := rcText[3] - aSize[1]
   ELSEIF hb_BitAnd(dwStyle, BS_CENTER) == BS_CENTER  // text centered
      rcText[1] := (rc[3] - rc[1]  - aSize[1]) / 2
      rcText[3] := rcText[1] + aSize[1]
   ELSE //((!(dwStyle & BS_CENTER)) || ((dwStyle & BS_CENTER) == BS_LEFT))// left aligned   / default
      rcText[1] := rc[1] + OFS_X
      rcText[3] := rcText[1] + aSize[1]
   ENDIF
   hwg_SetBkMode(dc, WINAPI_TRANSPARENT)

   IF hwg_BitAND(dwStyle, BS_FLAT) != 0  // "flat" frame
      //pnFrmDark := hwg_CreatePen(PS_SOLID, 1, hwg_RGB(0, 0, 0)))
      pnFrmDark := HPen():Add(PS_SOLID, 1, hwg_RGB(64, 64, 64))
      pnFrmLight := HPen():Add(PS_SOLID, 1, hwg_GetSysColor(COLOR_3DHILIGHT))
      ppnOldPen := hwg_SelectObject(dc, pnFrmDark:handle)
      hwg_MoveTo(dc, rcText[1] - 2, rcText[2])
      hwg_LineTo(dc, rc[1], rcText[2])
      hwg_LineTo(dc, rc[1], rc[4])
      hwg_LineTo(dc, rc[3], rc[4])
      hwg_LineTo(dc, rc[3], rcText[4])
      hwg_LineTo(dc, rcText[3], rcText[4])
      hwg_SelectObject(dc, pnFrmLight:handle)
      hwg_MoveTo(dc, rcText[1] - 2, rcText[2] + 1)
      hwg_LineTo(dc, rc[1] + 1, rcText[2] + 1)
      hwg_LineTo(dc, rc[1] + 1, rc[4] - 1)
      hwg_LineTo(dc, rc[3] - 1, rc[4] - 1)
      hwg_LineTo(dc, rc[3] - 1, rcText[4] + 1)
      hwg_LineTo(dc, rcText[3], rcText[4] + 1)
   ELSE // 3D frame
      pnFrmDark := HPen():Add(PS_SOLID, 1, hwg_GetSysColor(COLOR_3DSHADOW))
      pnFrmLight := HPen():Add(PS_SOLID, 1, hwg_GetSysColor(COLOR_3DHILIGHT))
      ppnOldPen := hwg_SelectObject(dc, pnFrmDark:handle)
      hwg_MoveTo(dc, rcText[1] - 2, rcText[2])
      hwg_LineTo(dc, rc[1], rcText[2])
      hwg_LineTo(dc, rc[1], rc[4] - 1)
      hwg_LineTo(dc, rc[3] - 1, rc[4] - 1)
      hwg_LineTo(dc, rc[3] - 1, rcText[4])
      hwg_LineTo(dc, rcText[3], rcText[4])
      hwg_SelectObject(dc, pnFrmLight:handle)
      hwg_MoveTo(dc, rcText[1] - 2, rcText[2] + 1)
      hwg_LineTo(dc, rc[1] + 1, rcText[2] + 1)
      hwg_LineTo(dc, rc[1] + 1, rc[4] - 1)
      hwg_MoveTo(dc, rc[1], rc[4])
      hwg_LineTo(dc, rc[3], rc[4])
      hwg_LineTo(dc, rc[3], rcText[4] - 1)
      hwg_MoveTo(dc, rc[3] - 2, rcText[4] + 1)
      hwg_LineTo(dc, rcText[3], rcText[4] + 1)
   ENDIF

   // draw text (if any)
   IF !Empty(szText) && !(dwExStyle & (BS_ICON | BS_BITMAP))) // TODO: Harbour & ?
      hwg_SetBkMode(dc, WINAPI_TRANSPARENT)
      IF ::oBrush != NIL
         hwg_FillRect(DC, rc[1] + 2, rc[2] + iUpDist + 2, rc[3] - 2, rc[4] - 2, ::brush:handle)
         IF !::lTransparent
            hwg_FillRect(DC, rcText[1] - 2, rc[2] + 1, rcText[3] + 1, rc[2] + iUpDist + 2, ::brush:handle)
         ENDIF
      ENDIF
      hwg_DrawText(dc, szText, rcText, DT_VCENTER + DT_LEFT + DT_SINGLELINE + DT_NOCLIP)
   ENDIF
   // cleanup
   hwg_DeleteObject(pnFrmLight)
   hwg_DeleteObject(pnFrmDark)
   hwg_SelectObject(dc, ppnOldPen)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//
