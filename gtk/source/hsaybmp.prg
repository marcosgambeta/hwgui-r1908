//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HSayBmp class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

//- HSayBmp

CLASS HSayBmp INHERIT HSayImage

   DATA nOffsetV INIT 0
   DATA nOffsetH INIT 0
   DATA nZoom

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
                  bSize, ctoolt)
   METHOD INIT()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Paint()
   METHOD ReplaceBitmap(Image, lRes)

ENDCLASS

METHOD HSayBmp:New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
                  bSize, ctoolt)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctoolt)

   IF Image != NIL
      IF lRes == NIL
         lRes := .F.
      ENDIF
      ::oImage := IIf(lRes .OR. hb_IsNumeric(Image), ;
                      HBitmap():AddResource(Image), ;
                      IIf(hb_IsChar(Image), ;
                      HBitmap():AddFile(Image), Image))
      IF !Empty(::oImage)
         IF nWidth == NIL .OR. nHeight == NIL
            ::nWidth  := ::oImage:nWidth
            ::nHeight := ::oImage:nHeight
         ENDIF
      ELSE
         RETURN NIL
      ENDIF
   ENDIF
   ::Activate()

RETURN Self

METHOD HSayBmp:INIT()
   IF !::lInit
      ::Super:Init()
      hwg_SetWindowObject(::handle, Self)
   ENDIF
RETURN NIL

METHOD HSayBmp:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_PAINT
      ::Paint()
   ENDIF
RETURN 0

METHOD HSayBmp:Paint()

   LOCAL hDC := hwg_GetDC(::handle)

   IF ::oImage != NIL
      IF ::nZoom == NIL
         hwg_DrawBitmap(hDC, ::oImage:handle,, ::nOffsetH, ;
               ::nOffsetV, ::nWidth, ::nHeight)
      ELSE
         hwg_DrawBitmap(hDC, ::oImage:handle,, ::nOffsetH, ;
               ::nOffsetV, ::oImage:nWidth * ::nZoom, ::oImage:nHeight * ::nZoom)
      ENDIF
   ENDIF
   hwg_releaseDC(::handle, hDC)

RETURN NIL

METHOD HSayBmp:ReplaceBitmap(Image, lRes)

   IF ::oImage != NIL
      ::oImage:Release()
   ENDIF
   IF lRes == NIL
      lRes := .F.
   ENDIF
   ::oImage := IIf(lRes .OR. hb_IsNumeric(Image), ;
                   HBitmap():AddResource(Image), ;
                   IIf(hb_IsChar(Image), ;
                   HBitmap():AddFile(Image), Image))

RETURN NIL
