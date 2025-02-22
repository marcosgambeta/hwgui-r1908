//
// $Id: hsayicon.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HSayIcon class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "hbclass.ch"
#include "hwgui.ch"

//- HSayIcon

CLASS HSayIcon INHERIT HSayImage

   METHOD New( oWndParent,nId,nLeft,nTop,nWidth,nHeight,Image,lRes,bInit, ;
                  bSize,ctoolt )

ENDCLASS

METHOD New( oWndParent,nId,nLeft,nTop,nWidth,nHeight,Image,lRes,bInit, ;
                  bSize,ctoolt ) CLASS HSayIcon

   ::Super:New( oWndParent,nId,SS_ICON,nLeft,nTop,nWidth,nHeight,bInit,bSize,ctoolt )

   IF lRes == Nil ; lRes := .F. ; ENDIF
   ::oImage := IIf(lRes .OR. ValType(Image) == "N",    ;
                   HIcon():AddResource(Image),  ;
                   IIf(ValType(Image) == "C",    ;
                   HIcon():AddFile(Image), Image))
   ::Activate()

Return Self
