//
// HWGUI - Harbour Win32 GUI library source code:
// Fonts handling
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include <hbclass.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HFont INHERIT HObject

   CLASS VAR aFonts INIT {}

   DATA handle
   DATA name
   DATA width
   DATA height
   DATA weight
   DATA charset
   DATA italic
   DATA Underline
   DATA StrikeOut
   DATA nCounter INIT 1

   METHOD Add(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle)
   METHOD Select(oFont, nCharSet)
   METHOD Release()
   METHOD SetFontStyle(lBold, nCharSet, lItalic, lUnder, lStrike, nHeight)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HFont:Add(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle)

   LOCAL i
   LOCAL nlen := Len(::aFonts)

   nHeight := IIf(nHeight == NIL, -13, nHeight)
   fnWeight := IIf(fnWeight == NIL, 0, fnWeight)
   fdwCharSet := IIf(fdwCharSet == NIL, 0, fdwCharSet)
   fdwItalic := IIf(fdwItalic == NIL, 0, fdwItalic)
   fdwUnderline := IIf(fdwUnderline == NIL, 0, fdwUnderline)
   fdwStrikeOut := IIf(fdwStrikeOut == NIL, 0, fdwStrikeOut)

   FOR i := 1 TO nlen
      IF ::aFonts[i]:name == fontName .AND. ;
         ::aFonts[i]:width == nWidth .AND. ;
         ::aFonts[i]:height == nHeight .AND. ;
         ::aFonts[i]:weight == fnWeight .AND. ;
         ::aFonts[i]:CharSet == fdwCharSet .AND. ;
         ::aFonts[i]:Italic == fdwItalic .AND. ;
         ::aFonts[i]:Underline == fdwUnderline .AND. ;
         ::aFonts[i]:StrikeOut == fdwStrikeOut
         ::aFonts[i]:nCounter++
         IF nHandle != NIL
            hwg_DeleteObject(nHandle)
         ENDIF
         RETURN ::aFonts[i]
      ENDIF
   NEXT

   IF nHandle == NIL
      ::handle := hwg_CreateFont(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut)
   ELSE
      ::handle := nHandle
   ENDIF

   ::name := fontName
   ::width := nWidth
   ::height := nHeight
   ::weight := fnWeight
   ::CharSet := fdwCharSet
   ::Italic := fdwItalic
   ::Underline := fdwUnderline
   ::StrikeOut := fdwStrikeOut

   AAdd(::aFonts, Self)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HFont:Select(oFont, nCharSet)

   LOCAL af := hwg_SelectFont(oFont)

   IF af == NIL
      RETURN NIL
   ENDIF

RETURN ::Add(af[2], af[3], af[4], af[5], IIf(Empty(nCharSet), af[6], nCharSet), af[7], af[8], af[9], af[1])

//-------------------------------------------------------------------------------------------------------------------//

METHOD HFont:SetFontStyle(lBold, nCharSet, lItalic, lUnder, lStrike, nHeight)

   LOCAL weight
   LOCAL Italic
   LOCAL Underline
   LOCAL StrikeOut

   IF lBold != NIL
      weight := IIf(lBold, FW_BOLD, FW_REGULAR)
   ELSE
      weight := ::weight
   ENDIF
   Italic := IIf(lItalic == NIL, ::Italic, IIf(lItalic, 1, 0))
   Underline := IIf(lUnder == NIL, ::Underline, IIf(lUnder, 1, 0))
   StrikeOut := IIf(lStrike == NIL, ::StrikeOut, IIf(lStrike, 1, 0))
   nheight := IIf(nheight == NIL, ::height, nheight)
   nCharSet := IIf(nCharSet == NIL, ::CharSet, nCharSet)

RETURN ::Add(::name, ::width, nheight, weight, nCharSet, Italic, Underline, StrikeOut) // ::handle)

//-------------------------------------------------------------------------------------------------------------------//

METHOD HFont:Release()

   LOCAL item
   LOCAL nlen := Len(::aFonts)

   ::nCounter--
   IF ::nCounter == 0
      FOR EACH item IN ::aFonts
         IF item:handle == ::handle
            hwg_DeleteObject(::handle)
            #ifdef __XHARBOUR__
            ADel(::aFonts, hb_enumindex())
            #else
            ADel(::aFonts, item:__enumIndex())
            #endif
            ASize(::aFonts, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

EXIT PROCEDURE hwg_CleanDrawWidgHFont

   LOCAL item

   FOR EACH item IN HFont():aFonts
      hwg_DeleteObject(item:handle)
   NEXT

RETURN

//-------------------------------------------------------------------------------------------------------------------//
