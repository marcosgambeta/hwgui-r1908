//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// Pens, brushes, fonts, bitmaps, icons handling
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include <hbclass.ch>
#include "hwgui.ch"

#ifndef HS_HORIZONTAL
#define HS_HORIZONTAL       0       /* ----- */
#define HS_VERTICAL         1       /* ||||| */
#define HS_FDIAGONAL        2       /* \\\\\ */
#define HS_BDIAGONAL        3       /* ///// */
#define HS_CROSS            4       /* +++++ */
#define HS_DIAGCROSS        5       /* xxxxx */
#endif

//- HFont

CLASS HFont INHERIT HObject

   CLASS VAR aFonts INIT {}
   DATA handle
   DATA name, width, height, weight
   DATA charset, italic, Underline, StrikeOut
   DATA nCounter INIT 1

   METHOD Add(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle, lLinux)
   METHOD Select(oFont)
   METHOD Release()

ENDCLASS

METHOD HFont:Add(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, ;
                   fdwUnderline, fdwStrikeOut, nHandle, lLinux)

   LOCAL i
   LOCAL nlen := Len(::aFonts)

   nHeight  := IIf(nHeight == NIL, 13, Abs(nHeight))
   IF lLinux == NIL .OR. !lLinux
      nHeight -= 3
   ENDIF
   fnWeight := IIf(fnWeight == NIL, 0, fnWeight)
   fdwCharSet := IIf(fdwCharSet == NIL, 0, fdwCharSet)
   fdwItalic := IIf(fdwItalic == NIL, 0, fdwItalic)
   fdwUnderline := IIf(fdwUnderline == NIL, 0, fdwUnderline)
   fdwStrikeOut := IIf(fdwStrikeOut == NIL, 0, fdwStrikeOut)

   FOR i := 1 TO nlen
      IF ::aFonts[i]:name == fontName .AND.          ;
         ::aFonts[i]:width == nWidth .AND.           ;
         ::aFonts[i]:height == nHeight .AND.         ;
         ::aFonts[i]:weight == fnWeight .AND.        ;
         ::aFonts[i]:CharSet == fdwCharSet .AND.     ;
         ::aFonts[i]:Italic == fdwItalic .AND.       ;
         ::aFonts[i]:Underline == fdwUnderline .AND. ;
         ::aFonts[i]:StrikeOut == fdwStrikeOut

         ::aFonts[i]:nCounter ++
         IF nHandle != NIL
            hwg_DeleteObject(nHandle)
         ENDIF
         RETURN ::aFonts[i]
      ENDIF
   NEXT

   IF nHandle == NIL
      ::handle := hwg_CreateFont(fontName, nWidth, nHeight * 1024, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut)
   ELSE
      ::handle := nHandle
      nHeight := nHeight / 1024
   ENDIF

   ::name      := fontName
   ::width     := nWidth
   ::height    := nHeight
   ::weight    := fnWeight
   ::CharSet   := fdwCharSet
   ::Italic    := fdwItalic
   ::Underline := fdwUnderline
   ::StrikeOut := fdwStrikeOut

   AAdd(::aFonts, Self)

RETURN Self

METHOD HFont:Select(oFont)
   
   LOCAL af := hwg_SelectFont(oFont)

   IF af == NIL
      RETURN NIL
   ENDIF

RETURN ::Add(af[2], af[3], af[4], af[5], af[6], af[7], af[8], af[9], af[1], .T.)

METHOD HFont:Release()

   LOCAL i
   LOCAL nlen := Len(::aFonts)

   ::nCounter --
   IF ::nCounter == 0
   #ifdef __XHARBOUR__
      For EACH i in ::aFonts
         IF i:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aFonts, hb_enumindex())
            ASize(::aFonts, nlen - 1)
            Exit
         ENDIF
      NEXT
   #else
      For i := 1 TO nlen
         IF ::aFonts[i]:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aFonts, i)
            ASize(::aFonts, nlen - 1)
            Exit
         ENDIF
      NEXT
   #endif
   ENDIF
RETURN NIL

//- HPen

CLASS HPen INHERIT HObject

   CLASS VAR aPens INIT {}
   DATA handle
   DATA style, width, color
   DATA nCounter INIT 1

   METHOD Add(nStyle, nWidth, nColor)
   METHOD Get(nStyle, nWidth, nColor)
   METHOD Release()

ENDCLASS

METHOD HPen:Add(nStyle, nWidth, nColor)

   LOCAL i

   nStyle := IIf(nStyle == NIL, BS_SOLID, nStyle)
   nWidth := IIf(nWidth == NIL, 1, nWidth)
   nColor := IIf(nColor == NIL, hwg_VColor("000000"), nColor)

   #ifdef __XHARBOUR__
   For EACH i in ::aPens 
      IF i:style == nStyle .AND. ;
         i:width == nWidth .AND. ;
         i:color == nColor

         i:nCounter ++
         RETURN i
      ENDIF
   NEXT
   #else
   For i := 1 TO Len(::aPens)
      IF ::aPens[i]:style == nStyle .AND. ;
         ::aPens[i]:width == nWidth .AND. ;
         ::aPens[i]:color == nColor

         ::aPens[i]:nCounter ++
         RETURN ::aPens[i]
      ENDIF
   NEXT
   #endif

   ::handle := hwg_CreatePen(nStyle, nWidth, nColor)
   ::style  := nStyle
   ::width  := nWidth
   ::color  := nColor
   AAdd(::aPens, Self)

RETURN Self

METHOD HPen:Get(nStyle, nWidth, nColor)

   LOCAL i

   nStyle := IIf(nStyle == NIL, PS_SOLID, nStyle)
   nWidth := IIf(nWidth == NIL, 1, nWidth)
   nColor := IIf(nColor == NIL, hwg_VColor("000000"), nColor)

   #ifdef __XHARBOUR__
   For EACH i in ::aPens 
      IF i:style == nStyle .AND. ;
         i:width == nWidth .AND. ;
         i:color == nColor

         RETURN i
      ENDIF
   NEXT
   #else
   For i := 1 TO Len(::aPens)
      IF ::aPens[i]:style == nStyle .AND. ;
         ::aPens[i]:width == nWidth .AND. ;
         ::aPens[i]:color == nColor

         RETURN ::aPens[i]
      ENDIF
   NEXT
   #endif

RETURN NIL

METHOD HPen:Release()

   LOCAL i
   LOCAL nlen := Len(::aPens)

   ::nCounter --
   IF ::nCounter == 0
   #ifdef __XHARBOUR__
      For EACH i  in ::aPens 
         IF i:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aPens, hb_EnumIndex())
            ASize(::aPens, nlen - 1)
            Exit
         ENDIF
      NEXT
   #else
      For i := 1 TO nlen
         IF ::aPens[i]:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aPens, i)
            ASize(::aPens, nlen - 1)
            Exit
         ENDIF
      NEXT
   #endif
   ENDIF
RETURN NIL

//- HBrush

CLASS HBrush INHERIT HObject

   CLASS VAR aBrushes INIT {}
   DATA handle
   DATA color
   DATA nHatch INIT 99
   DATA nCounter INIT 1

   METHOD Add(nColor)
   METHOD Release()

ENDCLASS

METHOD HBrush:Add(nColor)

   LOCAL i

   #ifdef __XHARBOUR__
   For EACH i IN ::aBrushes 
      IF i:color == nColor
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT
   #else
   For i := 1 TO Len(::aBrushes)
      IF ::aBrushes[i]:color == nColor
         ::aBrushes[i]:nCounter ++
         RETURN ::aBrushes[i]
      ENDIF
   NEXT
   #endif
   ::handle := hwg_CreateSolidBrush(nColor)
   ::color  := nColor
   AAdd(::aBrushes, Self)

RETURN Self

METHOD HBrush:Release()

   LOCAL i
   LOCAL nlen := Len(::aBrushes)

   ::nCounter --
   IF ::nCounter == 0
   #ifdef __XHARBOUR__
      For EACH i IN ::aBrushes 
         IF i:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aBrushes, hb_EnumIndex())
            ASize(::aBrushes, nlen - 1)
            Exit
         ENDIF
      NEXT
   #else
      For i := 1 TO nlen
         IF ::aBrushes[i]:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aBrushes, i)
            ASize(::aBrushes, nlen - 1)
            Exit
         ENDIF
      NEXT
   #endif
   ENDIF
RETURN NIL


//- HBitmap

CLASS HBitmap INHERIT HObject

   CLASS VAR aBitmaps INIT {}
   DATA handle
   DATA name
   DATA nWidth, nHeight
   DATA nCounter INIT 1

   METHOD AddResource(name)
   METHOD AddFile(name, HDC)
   METHOD AddWindow(oWnd, lFull)
   METHOD Release()

ENDCLASS

METHOD HBitmap:AddResource(name)

   LOCAL lPreDefined := .F.
   LOCAL i
   LOCAL aBmpSize

   IF hb_IsNumeric(name)
      name := LTrim(Str(name))
      lPreDefined := .T.
   ENDIF
   #ifdef __XHARBOUR__
   For EACH i  IN  ::aBitmaps 
      IF i:name == name
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT
   #else
   For i := 1 TO Len(::aBitmaps)
      IF ::aBitmaps[i]:name == name
         ::aBitmaps[i]:nCounter ++
         RETURN ::aBitmaps[i]
      ENDIF
   NEXT
   #endif
   ::handle :=   hwg_LoadBitmap(IIf(lPreDefined, Val(name), name))
   IF !Empty(::handle)
      ::name   := name
      aBmpSize  := hwg_GetBitmapSize(::handle)
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aBitmaps, Self)
   ELSE
      RETURN NIL
   ENDIF

RETURN Self

METHOD HBitmap:AddFile(name, HDC)

   LOCAL i
   LOCAL aBmpSize

   HB_SYMBOL_UNUSED(HDC)

   #ifdef __XHARBOUR__
   For EACH i IN ::aBitmaps
      IF i:name == name
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT
   #else
   For i := 1 TO Len(::aBitmaps)
      IF ::aBitmaps[i]:name == name
         ::aBitmaps[i]:nCounter ++
         RETURN ::aBitmaps[i]
      ENDIF
   NEXT
   #endif
   ::handle := hwg_OpenImage(name)
   IF !Empty(::handle)
      ::name := name
      aBmpSize  := hwg_GetBitmapSize(::handle)
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aBitmaps, Self)
   ELSE
      RETURN NIL
   ENDIF

RETURN Self

METHOD HBitmap:AddWindow(oWnd, lFull)
   
   //LOCAL i // variable not used
   LOCAL aBmpSize

   HB_SYMBOL_UNUSED(lFull)

   // ::handle := hwg_Window2Bitmap(oWnd:handle, lFull)
   ::name := LTrim(Str(oWnd:handle))
   aBmpSize  := hwg_GetBitmapSize(::handle)
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

RETURN Self

METHOD HBitmap:Release()

   LOCAL i
   LOCAL nlen := Len(::aBitmaps)

   ::nCounter --
   IF ::nCounter == 0
   #ifdef __XHARBOUR__
      For EACH i IN ::aBitmaps
         IF i:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aBitmaps, hb_EnumIndex())
            ASize(::aBitmaps, nlen - 1)
            Exit
         ENDIF
      NEXT
   #else
      For i := 1 TO nlen
         IF ::aBitmaps[i]:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aBitmaps, i)
            ASize(::aBitmaps, nlen - 1)
            Exit
         ENDIF
      NEXT
   #endif
   ENDIF
RETURN NIL


//- HIcon

CLASS HIcon INHERIT HObject

   CLASS VAR aIcons INIT {}
   DATA handle
   DATA name
   DATA nCounter INIT 1
   DATA nWidth, nHeight

   METHOD AddResource(name)
   //METHOD AddFile(name, HDC)
   METHOD AddFile(name)
   METHOD Release()

ENDCLASS

METHOD HIcon:AddResource(name)

   LOCAL lPreDefined //:= .F. (value not used)
   LOCAL i

   IF hb_IsNumeric(name)
      name := LTrim(Str(name))
      lPreDefined := .T.
      HB_SYMBOL_UNUSED(lPreDefined)
   ENDIF
   #ifdef __XHARBOUR__
   For EACH i IN ::aIcons
      IF i:name == name
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT
   #else
   For i := 1 TO Len(::aIcons)
      IF ::aIcons[i]:name == name
         ::aIcons[i]:nCounter ++
         RETURN ::aIcons[i]
      ENDIF
   NEXT
   #endif
   // ::handle :=   hwg_LoadIcon(IIf(lPreDefined, Val(name), name))
   ::name   := name
   AAdd(::aIcons, Self)

RETURN Self

METHOD HIcon:AddFile(name)

   LOCAL i
   LOCAL aBmpSize

#ifdef __XHARBOUR__
   For EACH i IN  ::aIcons 
      IF i:name == name
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT
#else
   For i := 1 TO Len(::aIcons)
      IF ::aIcons[i]:name == name
         ::aIcons[i]:nCounter ++
         RETURN ::aIcons[i]
      ENDIF
   NEXT
#endif
//   ::handle := hwg_LoadImage(0, name, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE + LR_LOADFROMFILE)
//   ::handle := hwg_OpenImage(name)
//   ::name := name
//   AAdd(::aIcons, Self)
//  Tracelog("name = ", name)
   ::handle := hwg_OpenImage(name)
//   tracelog("handle = ", ::handle)
   IF !Empty(::handle)
      ::name := name
      aBmpSize  := hwg_GetBitmapSize(::handle)
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aIcons, Self)
   ELSE
      RETURN NIL
   ENDIF

RETURN Self

METHOD HIcon:Release()

   LOCAL i
   LOCAL nlen := Len(::aIcons)

   ::nCounter --
   IF ::nCounter == 0
   #ifdef __XHARBOUR__
      For EACH i IN ::aIcons
         IF i:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aIcons, hb_EnumIndex())
            ASize(::aIcons, nlen - 1)
            Exit
         ENDIF
      NEXT
   #else
      For i := 1 TO nlen
         IF ::aIcons[i]:handle == ::handle
            hwg_DeleteObject(::handle)
            ADel(::aIcons, i)
            ASize(::aIcons, nlen - 1)
            Exit
         ENDIF
      NEXT
   #endif
   ENDIF
RETURN NIL


EXIT PROCEDURE CleanDrawWidg

   LOCAL i

   For i := 1 TO Len(HPen():aPens)
      hwg_DeleteObject(HPen():aPens[i]:handle)
   NEXT
   For i := 1 TO Len(HBrush():aBrushes)
      hwg_DeleteObject(HBrush():aBrushes[i]:handle)
   NEXT
   For i := 1 TO Len(HFont():aFonts)
      hwg_DeleteObject(HFont():aFonts[i]:handle)
   NEXT
   For i := 1 TO Len(HBitmap():aBitmaps)
      hwg_DeleteObject(HBitmap():aBitmaps[i]:handle)
   NEXT
   For i := 1 TO Len(HIcon():aIcons)
      // hwg_DeleteObject(HIcon():aIcons[i]:handle)
   NEXT

RETURN

