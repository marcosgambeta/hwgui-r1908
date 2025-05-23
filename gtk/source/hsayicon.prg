//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HSayIcon class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

//- HSayIcon

CLASS HSayIcon INHERIT HSayImage

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
                  bSize, ctoolt)

ENDCLASS

METHOD HSayIcon:New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
                  bSize, ctoolt)

   ::Super:New(oWndParent, nId, SS_ICON, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctoolt)

   IF lRes == NIL
      lRes := .F.
   ENDIF
   ::oImage := IIf(lRes .OR. hb_IsNumeric(Image), ;
                   HIcon():AddResource(Image), ;
                   IIf(hb_IsChar(Image), ;
                   HIcon():AddFile(Image), Image))
   ::Activate()

RETURN Self
