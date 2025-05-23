//
// HWGUI - Harbour Win32 GUI library source code:
// Brushes handling
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include <hbclass.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HBrush INHERIT HObject

   CLASS VAR aBrushes INIT {}

   DATA handle
   DATA color
   DATA nHatch INIT 99
   DATA nCounter INIT 1

   METHOD Add(nColor, nHatch)
   METHOD Release()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HBrush:Add(nColor, nHatch)

   LOCAL item

   IF nHatch == NIL
      nHatch := 99
   ENDIF
   IF hb_IsPointer(nColor)
      nColor := hwg_PtrToUlong(nColor)
   ENDIF
   FOR EACH item IN ::aBrushes
      IF item:color == nColor .AND. item:nHatch == nHatch
         item:nCounter++
         RETURN item
      ENDIF
   NEXT
   IF nHatch != 99
      ::handle := hwg_CreateHatchBrush(nHatch, nColor)
   ELSE
      ::handle := hwg_CreateSolidBrush(nColor)
   ENDIF
   ::color := nColor
   AAdd(::aBrushes, SELF)

RETURN SELF

//-------------------------------------------------------------------------------------------------------------------//

METHOD HBrush:Release()

   LOCAL item
   LOCAL nlen := Len(::aBrushes)

   ::nCounter--
   IF ::nCounter == 0
      FOR EACH item IN ::aBrushes
         IF item:handle == ::handle
            hwg_DeleteObject(::handle)
            #ifdef __XHARBOUR__
            ADel(::aBrushes, hb_enumindex())
            #else
            ADel(::aBrushes, item:__enumindex())
            #endif
            ASize(::aBrushes, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

EXIT PROCEDURE hwg_CleanDrawWidgHBrush

   LOCAL item

   FOR EACH item IN HBrush():aBrushes
      hwg_DeleteObject(item:handle)
   NEXT

RETURN

//-------------------------------------------------------------------------------------------------------------------//
