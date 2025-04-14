//
// $Id: hbrowse.prg 1625 2011-08-05 13:14:50Z druzus $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HBrowse class - browse databases and arrays
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <inkey.ch>
#include <dbstruct.ch>
#include "hwgui.ch"
#include "gtk.ch"

REQUEST DBGOTOP
REQUEST DBGOTO
REQUEST DBGOBOTTOM
REQUEST DBSKIP
REQUEST RECCOUNT
REQUEST RECNO
REQUEST EOF
REQUEST BOF

#ifndef SB_HORZ
#define SB_HORZ             0
#define SB_VERT             1
#define SB_CTL              2
#define SB_BOTH             3
#endif
#define HDM_GETITEMCOUNT    4608

#define GDK_BackSpace       0xFF08
#define GDK_Tab             0xFF09
#define GDK_Return          0xFF0D
#define GDK_Escape          0xFF1B
#define GDK_Delete          0xFFFF
#define GDK_Home            0xFF50
#define GDK_Left            0xFF51
#define GDK_Up              0xFF52
#define GDK_Right           0xFF53
#define GDK_Down            0xFF54
#define GDK_Page_Up         0xFF55
#define GDK_Page_Down       0xFF56
#define GDK_End             0xFF57
#define GDK_Insert          0xFF63
#define GDK_Control_L       0xFFE3
#define GDK_Control_R       0xFFE4

STATIC crossCursor := NIL
STATIC arrowCursor := NIL
STATIC vCursor     := NIL
STATIC xDrag
//----------------------------------------------------//
CLASS HColumn INHERIT HObject

   DATA block, heading, footing, width, type
   DATA length INIT 0
   DATA dec, cargo
   DATA nJusHead, nJusLin        // Para poder Justificar los Encabezados
                                 // de las columnas y lineas.
                                 // WHT. 27.07.2002
   DATA tcolor, bcolor, brush
   DATA oFont
   DATA lEditable INIT .F.       // Is the column editable
   DATA aList                    // Array of possible values for a column -
                                 // combobox will be used while editing the cell
   DATA aBitmaps
   DATA bValid, bWhen             // When and Valid codeblocks for cell editing
   DATA bEdit                    // Codeblock, which performs cell editing, if defined
   DATA cGrid
   DATA lSpandHead INIT .F.
   DATA lSpandFoot INIT .F.
   DATA Picture
   DATA bHeadClick
   DATA bColorBlock              //   bColorBlock must return an array containing four colors values
                                 //   oBrowse:aColumns[1]:bColorBlock := {||IF(nNumber < 0, ;
                                 //      {textColor, backColor, textColorSel, backColorSel} , ;
                                 //      {textColor, backColor, textColorSel, backColorSel})}

   METHOD New(cHeading, block, type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick)

ENDCLASS

//----------------------------------------------------//
METHOD New(cHeading, block, type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick) CLASS HColumn

   ::heading   := IIf(cHeading == NIL, "", cHeading)
   ::block     := block
   ::type      := type
   ::length    := length
   ::dec       := dec
   ::lEditable := IIf(lEditable != NIL, lEditable, .F.)
   ::nJusHead  := IIf(nJusHead == NIL, DT_LEFT, nJusHead) // Por default
   ::nJusLin   := IIf(nJusLin == NIL, DT_LEFT, nJusLin) // Justif.Izquierda
   ::picture   := cPict
   ::bValid    := bValid
   ::bWhen     := bWhen
   ::aList     := aItem
   ::bColorBlock := bColorBlock
   ::bHeadClick  := bHeadClick

RETURN Self

//----------------------------------------------------//
CLASS HBrowse INHERIT HControl

   DATA winclass   INIT "BROWSE"
   DATA active     INIT .T.
   DATA lChanged   INIT .F.
   DATA lDispHead  INIT .T.                    // Should I display headers ?
   DATA lDispSep   INIT .T.                    // Should I display separators ?
   DATA aColumns                               // HColumn's array
   DATA rowCount                               // Number of visible data rows
   DATA rowPos     INIT 1                      // Current row position
   DATA rowCurrCount INIT 0                    // Current number of rows
   DATA colPos     INIT 1                      // Current column position
   DATA nColumns                               // Number of visible data columns
   DATA nLeftCol                               // Leftmost column
   DATA xpos
   DATA freeze                                 // Number of columns to freeze
   DATA nRecords                               // Number of records in browse
   DATA nCurrent      INIT 1                   // Current record
   DATA aArray                                 // An array browsed if this is BROWSE ARRAY
   DATA recCurr INIT 0
   DATA headColor                              // Header text color
   DATA sepColor INIT 12632256                 // Separators color
   DATA lSep3d  INIT .F.
   DATA varbuf                                 // Used on Edit()
   DATA tcolorSel, bcolorSel, brushSel
   DATA bSkip, bGoTo, bGoTop, bGoBot, bEof, bBof
   DATA bRcou, bRecno, bRecnoLog
   DATA bPosChanged, bLineOut, bScrollPos
   DATA bEnter, bKeyDown, bUpdate
   DATA internal
   DATA alias                                  // Alias name of browsed database
   DATA x1, y1, x2, y2, width, height
   DATA minHeight INIT 0
   DATA lEditable INIT .F.
   DATA lAppable  INIT .F.
   DATA lAppMode  INIT .F.
   DATA lAutoEdit INIT .F.
   DATA lUpdated  INIT .F.
   DATA lAppended INIT .F.
   DATA lAdjRight INIT .T.                     // Adjust last column to right
   DATA nHeadRows INIT 1                       // Rows in header
   DATA nFootRows INIT 0                       // Rows in footer
   DATA nCtrlPress INIT 0                      // Left or Right Ctrl key code while Ctrl key is pressed
   DATA aSelected                              // An array of selected records numbers
   
   DATA area
   DATA hScrollV  INIT NIL
   DATA hScrollH  INIT NIL
   DATA nScrollV  INIT 0
   DATA nScrollH  INIT 0
   DATA oGet, nGetRec
   DATA lBtnDbl   INIT .F.
   DATA nCursor   INIT 0

   METHOD New(lType, oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, ;
                  bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoVScroll, lNoBorder,;
                  lAppend, lAutoedit, bUpdate, bKeyDown, bPosChg, lMultiSelect)
   METHOD InitBrw(nType)
   METHOD Rebuild()
   METHOD Activate()
   METHOD Init()
   METHOD onEvent(msg, wParam, lParam)
   METHOD AddColumn(oColumn)
   METHOD InsColumn(oColumn, nPos)
   METHOD DelColumn(nPos)
   METHOD Paint()
   METHOD LineOut()
   METHOD HeaderOut(hDC)
   METHOD FooterOut(hDC)
   METHOD SetColumn(nCol)
   METHOD DoHScroll(wParam)
   METHOD DoVScroll(wParam)
   METHOD LineDown(lMouse)
   METHOD LineUp()
   METHOD PageUp()
   METHOD PageDown()
   METHOD Home() INLINE ::DoHScroll(SB_LEFT)
   METHOD Bottom(lPaint)
   METHOD Top()
   METHOD ButtonDown(lParam)
   METHOD ButtonUp(lParam)
   METHOD ButtonDbl(lParam)
   METHOD MouseMove(wParam, lParam)
   METHOD MouseWheel(nKeys, nDelta, nXPos, nYPos)
   METHOD Edit(wParam, lParam)
   METHOD Append() INLINE (::Bottom(.F.), ::LineDown())
   METHOD RefreshLine()
   METHOD Refresh(lFull)
   METHOD ShowSizes()
   METHOD End()

ENDCLASS

//----------------------------------------------------//
METHOD New(lType, oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, ;
                  bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoVScroll,;
                  lNoBorder, lAppend, lAutoedit, bUpdate, bKeyDown, bPosChg, lMultiSelect) CLASS HBrowse

   nStyle   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_CHILD+WS_VISIBLE+ ;
                    IIf(lNoBorder == NIL .OR. !lNoBorder, WS_BORDER, 0)+            ;
                    IIf(lNoVScroll == NIL .OR. !lNoVScroll, WS_VSCROLL, 0))
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, IIf(nWidth == NIL, 0, nWidth), ;
             IIf(nHeight == NIL, 0, nHeight), oFont, bInit, bSize, bPaint)

   ::type    := lType
   IF oFont == NIL
      ::oFont := ::oParent:oFont
   ENDIF
   ::bEnter  := bEnter
   ::bGetFocus   := bGFocus
   ::bLostFocus  := bLFocus
   
   ::lAppable    := IIf(lAppend == NIL, .F., lAppend)
   ::lAutoEdit   := IIf(lAutoedit == NIL, .F., lAutoedit)
   ::bUpdate     := bUpdate
   ::bKeyDown    := bKeyDown
   ::bPosChanged := bPosChg
   IF lMultiSelect != NIL .AND. lMultiSelect
      ::aSelected := {}
   ENDIF

   ::InitBrw()
   ::Activate()
   
RETURN Self

//----------------------------------------------------//
METHOD Activate CLASS HBrowse

   if !Empty(::oParent:handle)
      ::handle := hwg_CreateBrowse(Self)
      ::Init()
   endif
RETURN Self

//----------------------------------------------------//
#if 0 // old code for reference (to be deleted)
METHOD onEvent(msg, wParam, lParam)  CLASS HBrowse
Local aCoors, retValue := -1

   // WriteLog("Brw: "+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))
   IF ::active .AND. !Empty(::aColumns)

      IF ::bOther != NIL
         Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

      IF msg == WM_PAINT
         ::Paint()
         retValue := 1

      ELSEIF msg == WM_ERASEBKGND
         IF ::brush != NIL

            aCoors := hwg_GetClientRect(::handle)
            hwg_FillRect(wParam, aCoors[1], aCoors[2], aCoors[3]+1, aCoors[4]+1, ::brush:handle)
            retValue := 1
         ENDIF

      ELSEIF msg == WM_SETFOCUS
         IF ::bGetFocus != NIL
            Eval(::bGetFocus, Self)
         ENDIF

      ELSEIF msg == WM_KILLFOCUS
         IF ::bLostFocus != NIL
            Eval(::bLostFocus, Self)
         ENDIF

      ELSEIF msg == WM_HSCROLL
         ::DoHScroll()

      ELSEIF msg == WM_VSCROLL
         ::DoVScroll(wParam)

      ELSEIF msg == WM_COMMAND
         hwg_DlgCommand(Self, wParam, lParam)


      ELSEIF msg == WM_KEYUP
         IF wParam == GDK_Control_L .OR. wParam == GDK_Control_R
            IF wParam == ::nCtrlPress
               ::nCtrlPress := 0
            ENDIF
         ENDIF
         retValue := 1
      ELSEIF msg == WM_KEYDOWN
         IF ::bKeyDown != NIL
            IF !Eval(::bKeyDown, Self, wParam)
               retValue := 1
            ENDIF
         ENDIF
         IF wParam == GDK_Down        // Down
            ::LINEDOWN()
         ELSEIF wParam == GDK_Up    // Up
            ::LINEUP()
         ELSEIF wParam == GDK_Right    // Right
            LineRight(Self)
         ELSEIF wParam == GDK_Left    // Left
            LineLeft(Self)
         ELSEIF wParam == GDK_Home    // Home
            ::DoHScroll(SB_LEFT)
         ELSEIF wParam == GDK_End    // End
            ::DoHScroll(SB_RIGHT)
         ELSEIF wParam == GDK_Page_Down    // PageDown
            IF ::nCtrlPress != 0
               ::BOTTOM()
            ELSE
               ::PageDown()
            ENDIF
         ELSEIF wParam == GDK_Page_Up    // PageUp
            IF ::nCtrlPress != 0
               ::TOP()
            ELSE
               ::PageUp()
            ENDIF
         ELSEIF wParam == GDK_Return  // Enter
            ::Edit()
         ELSEIF wParam == GDK_Control_L .OR. wParam == GDK_Control_R
            IF ::nCtrlPress == 0
               ::nCtrlPress := wParam
            ENDIF
         ELSEIF (wParam >= 48 .AND. wParam <= 90 .OR. wParam >= 96 .AND. wParam <= 111) .AND. ::lAutoEdit
            ::Edit(wParam, lParam)
         ENDIF
         retValue := 1

      ELSEIF msg == WM_LBUTTONDOWN
         ::ButtonDown(lParam)

      ELSEIF msg == WM_LBUTTONUP
         ::ButtonUp(lParam)

      ELSEIF msg == WM_LBUTTONDBLCLK
         ::ButtonDbl(lParam)

      ELSEIF msg == WM_MOUSEMOVE
         ::MouseMove(wParam, lParam)

      ELSEIF msg == WM_MOUSEWHEEL
         ::MouseWheel(hwg_LOWORD(wParam),;
                          IIf(hwg_HIWORD(wParam) > 32768, ;
                          hwg_HIWORD(wParam) - 65535, hwg_HIWORD(wParam)),;
                          hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      ELSEIF msg == WM_DESTROY
         ::End()
      ENDIF

   ENDIF

RETURN retValue
#else
METHOD onEvent(msg, wParam, lParam)  CLASS HBrowse
Local aCoors, retValue := -1

   // WriteLog("Brw: "+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))
   IF ::active .AND. !Empty(::aColumns)

      IF ::bOther != NIL
         Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

      SWITCH msg

      CASE WM_PAINT
         ::Paint()
         retValue := 1
         EXIT

      CASE WM_ERASEBKGND
         IF ::brush != NIL
            aCoors := hwg_GetClientRect(::handle)
            hwg_FillRect(wParam, aCoors[1], aCoors[2], aCoors[3]+1, aCoors[4]+1, ::brush:handle)
            retValue := 1
         ENDIF
         EXIT

      CASE WM_SETFOCUS
         IF ::bGetFocus != NIL
            Eval(::bGetFocus, Self)
         ENDIF
         EXIT

      CASE WM_KILLFOCUS
         IF ::bLostFocus != NIL
            Eval(::bLostFocus, Self)
         ENDIF
         EXIT

      CASE WM_HSCROLL
         ::DoHScroll()
         EXIT

      CASE WM_VSCROLL
         ::DoVScroll(wParam)
         EXIT

      CASE WM_COMMAND
         hwg_DlgCommand(Self, wParam, lParam)
         EXIT

      CASE WM_KEYUP
         IF wParam == GDK_Control_L .OR. wParam == GDK_Control_R
            IF wParam == ::nCtrlPress
               ::nCtrlPress := 0
            ENDIF
         ENDIF
         retValue := 1
         EXIT

      CASE WM_KEYDOWN
         IF ::bKeyDown != NIL
            IF !Eval(::bKeyDown, Self, wParam)
               retValue := 1
            ENDIF
         ENDIF
         SWITCH wParam
         CASE GDK_Down        // Down
            ::LINEDOWN()
            EXIT
         CASE GDK_Up    // Up
            ::LINEUP()
            EXIT
         CASE GDK_Right    // Right
            LineRight(Self)
            EXIT
         CASE GDK_Left    // Left
            LineLeft(Self)
            EXIT
         CASE GDK_Home    // Home
            ::DoHScroll(SB_LEFT)
            EXIT
         CASE GDK_End    // End
            ::DoHScroll(SB_RIGHT)
            EXIT
         CASE GDK_Page_Down    // PageDown
            IF ::nCtrlPress != 0
               ::BOTTOM()
            ELSE
               ::PageDown()
            ENDIF
            EXIT
         CASE GDK_Page_Up    // PageUp
            IF ::nCtrlPress != 0
               ::TOP()
            ELSE
               ::PageUp()
            ENDIF
            EXIT
         CASE GDK_Return  // Enter
            ::Edit()
            EXIT
         CASE GDK_Control_L
         CASE GDK_Control_R
            IF ::nCtrlPress == 0
               ::nCtrlPress := wParam
            ENDIF
            EXIT
         #ifdef __XHARBOUR__
         DEFAULT
         #else
         OTHERWISE
         #endif
            IF (wParam >= 48 .AND. wParam <= 90 .OR. wParam >= 96 .AND. wParam <= 111) .AND. ::lAutoEdit
               ::Edit(wParam, lParam)
            ENDIF
         ENDSWITCH
         retValue := 1
         EXIT

      CASE WM_LBUTTONDOWN
         ::ButtonDown(lParam)
         EXIT

      CASE WM_LBUTTONUP
         ::ButtonUp(lParam)
         EXIT

      CASE WM_LBUTTONDBLCLK
         ::ButtonDbl(lParam)
         EXIT

      CASE WM_MOUSEMOVE
         ::MouseMove(wParam, lParam)
         EXIT

      CASE WM_MOUSEWHEEL
         ::MouseWheel(hwg_LOWORD(wParam),;
                          IIf(hwg_HIWORD(wParam) > 32768, ;
                          hwg_HIWORD(wParam) - 65535, hwg_HIWORD(wParam)),;
                          hwg_LOWORD(lParam), hwg_HIWORD(lParam))
         EXIT

      CASE WM_DESTROY
         ::End()

      ENDSWITCH

   ENDIF

RETURN retValue
#endif

//----------------------------------------------------//
METHOD Init CLASS HBrowse

   IF !::lInit
      ::Super:Init()
      // hwg_SetWindowObject(::handle, Self)
   ENDIF
RETURN NIL

//----------------------------------------------------//
METHOD AddColumn(oColumn) CLASS HBrowse
Local n

   AAdd(::aColumns, oColumn)
   ::lChanged := .T.
   InitColumn(Self, oColumn, Len(::aColumns))

RETURN oColumn

//----------------------------------------------------//
METHOD InsColumn(oColumn, nPos) CLASS HBrowse

   AAdd(::aColumns, NIL)
   ains(::aColumns, nPos)
   ::aColumns[nPos] := oColumn
   ::lChanged := .T.
   InitColumn(Self, oColumn, nPos)

RETURN oColumn

STATIC FUNCTION InitColumn(oBrw, oColumn, n)

   if oColumn:type == NIL
      oColumn:type := ValType(Eval(oColumn:block, , oBrw, n))
   endif 
   if oColumn:dec == NIL 
      if oColumn:type == "N" .AND. At('.', Str(Eval(oColumn:block, , oBrw, n))) != 0
         oColumn:dec := Len(SubStr(Str(Eval(oColumn:block, , oBrw, n)), ;
               At(".", Str(Eval(oColumn:block, , oBrw, n))) + 1))
      else
         oColumn:dec := 0
      endif
   endif
   if oColumn:length == NIL 
      if oColumn:picture != NIL
         oColumn:length := Len(Transform(Eval(oColumn:block, , oBrw, n), oColumn:picture))
      else
         oColumn:length := 10             
      endif
      oColumn:length := Max(oColumn:length, Len(oColumn:heading))
   endif

RETURN NIL

//----------------------------------------------------//
METHOD DelColumn(nPos) CLASS HBrowse
   ADel(::aColumns, nPos)
   ASize(::aColumns, Len(::aColumns) - 1)
   ::lChanged := .T.
RETURN NIL

//----------------------------------------------------//
METHOD End() CLASS HBrowse

   hwg_ReleaseObject(::area)
   IF ::hScrollV != NIL
      hwg_ReleaseObject(::hScrollV)
   ENDIF
   IF ::hScrollH != NIL
      hwg_ReleaseObject(::hScrollH)
   ENDIF

   ::Super:End()
   IF ::brush != NIL
      ::brush:Release()
      ::brushSel:Release()
   ENDIF  

RETURN NIL

//----------------------------------------------------//
METHOD InitBrw(nType)  CLASS HBrowse

   if nType != NIL
      ::type := nType
   else
      ::aColumns := {}
      ::rowPos    := ::nCurrent  := ::colpos := ::nLeftCol := 1
      ::freeze  := ::height := 0
      ::internal  := {15, 1}
      ::aArray     := NIL

      if Empty(crossCursor)
         crossCursor := hwg_LoadCursor(GDK_CROSS)
         arrowCursor := hwg_LoadCursor(GDK_LEFT_PTR)
         vCursor := hwg_LoadCursor(GDK_SB_V_DOUBLE_ARROW)
      endif
      
   endif

   if ::type == BRW_DATABASE
      ::alias   := Alias()
      ::bSKip   := &("{|o, x|" + ::alias + "->(DBSKIP(x)) }")
      ::bGoTop  := &("{||" + ::alias + "->(DBGOTOP())}")
      ::bGoBot  := &("{||" + ::alias + "->(DBGOBOTTOM())}")
      ::bEof    := &("{||" + ::alias + "->(EOF())}")
      ::bBof    := &("{||" + ::alias + "->(BOF())}")
      ::bRcou   := &("{||" + ::alias + "->(RECCOUNT())}")
      ::bRecnoLog := ::bRecno  := &("{||" + ::alias + "->(RECNO())}")
      ::bGoTo   := &("{|a,n|"  + ::alias + "->(DBGOTO(n))}")
   elseif ::type == BRW_ARRAY
      ::bSKip   := {|o, x|ARSKIP(o, x)}
      ::bGoTop  := {|o|o:nCurrent := 1}
      ::bGoBot  := {|o|o:nCurrent := o:nRecords}
      ::bEof    := {|o|o:nCurrent > o:nRecords}
      ::bBof    := {|o|o:nCurrent == 0}
      ::bRcou   := {|o|Len(o:aArray)}
      ::bRecnoLog := ::bRecno  := {|o|o:nCurrent}
      ::bGoTo   := {|o, n|o:nCurrent := n}
      ::bScrollPos := {|o, n, lEof, nPos|hwg_VScrollPos(o, n, lEof, nPos)}
   endif
RETURN NIL

//----------------------------------------------------//
METHOD Rebuild(hDC) CLASS HBrowse

   local i, j, oColumn, xSize, nColLen, nHdrLen, nCount

   IF ::brush != NIL
      ::brush:Release()
   ENDIF
   IF ::brushSel != NIL
      ::brushSel:Release()
   ENDIF
   IF ::bcolor != NIL
      ::brush     := HBrush():Add(::bcolor)
   ENDIF
   IF ::bcolorSel != NIL
      ::brushSel  := HBrush():Add(::bcolorSel)
   ENDIF

   ::nLeftCol  := ::freeze + 1
   ::lEditable := .F.

   ::minHeight := 0
   for i := 1 to Len(::aColumns)

      oColumn := ::aColumns[i]

      if oColumn:lEditable
         ::lEditable := .T.
      endif

      if oColumn:aBitmaps != NIL
         xSize := 0
         for j := 1 to Len(oColumn:aBitmaps)
            xSize := max(xSize, oColumn:aBitmaps[j, 2]:nWidth+2)
            ::minHeight := max(::minHeight, oColumn:aBitmaps[j, 2]:nHeight)
         next
      else
         // xSize := Round((Max(Len(FldStr(Self, i)), Len(oColumn:heading)) + 2) * 8, 0)
         nColLen := oColumn:length
         if oColumn:heading != NIL
            HdrToken(oColumn:heading, @nHdrLen, @nCount)
            if ! oColumn:lSpandHead
               nColLen := max(nColLen, nHdrLen)
            endif
            ::nHeadRows := Max(::nHeadRows, nCount)
         endif
         if oColumn:footing != NIL
            HdrToken(oColumn:footing, @nHdrLen, @nCount)
            if ! oColumn:lSpandFoot
               nColLen := max(nColLen, nHdrLen)
            endif
            ::nFootRows := Max(::nFootRows, nCount)
         endif
         xSize := Round((nColLen + 2) * 8, 0)
      endif

      oColumn:width := xSize

   next

   ::lChanged := .F.

RETURN NIL

//----------------------------------------------------//
METHOD Paint()  CLASS HBrowse
Local aCoors, aMetr, i, oldAlias, tmp, nRows
Local pps, hDC
Local oldBkColor, oldTColor

   IF !::active .OR. Empty(::aColumns)
      RETURN NIL
   ENDIF

   IF ::tcolor == NIL ; ::tcolor := 0 ; ENDIF
   IF ::bcolor == NIL ; ::bcolor := hwg_VColor("FFFFFF") ; ENDIF
   IF ::tcolorSel == NIL ; ::tcolorSel := hwg_VColor("FFFFFF") ; ENDIF
   IF ::bcolorSel == NIL ; ::bcolorSel := hwg_VColor("808080") ; ENDIF

   hDC := hwg_GetDC(::area)

   if ::ofont != NIL
      hwg_SelectObject(hDC, ::ofont:handle)
   endif
   IF ::brush == NIL .OR. ::lChanged
      ::Rebuild(hDC)
   ENDIF
   aCoors := hwg_GetClientRect(::handle)
   hwg_Rectangle(hDC, aCoors[1], aCoors[2], aCoors[3] - 1, aCoors[4] - 1)
   aMetr := hwg_GetTextMetric(hDC)
   
   ::width := aMetr[2]
   ::height := Max(aMetr[1], ::minHeight)
   ::x1 := aCoors[1]
   ::y1 := aCoors[2] + IIf(::lDispHead, ::height * ::nHeadRows, 0)
   ::x2 := aCoors[3]
   ::y2 := aCoors[4]

   ::nRecords := Eval(::bRcou, Self)
   IF ::nCurrent > ::nRecords .AND. ::nRecords > 0
      ::nCurrent := ::nRecords
   ENDIF

   ::nColumns := FLDCOUNT(Self, ::x1 + 2, ::x2 - 2, ::nLeftCol)
   ::rowCount := Int((::y2-::y1) / (::height+1)) - ::nFootRows
   nRows := Min(::nRecords, ::rowCount)
   
   IF ::hScrollV != NIL
      tmp := IIf(::nRecords < 100, ::nRecords, 100)
      i := IIf(::nRecords < 100, 1, ::nRecords / 100)
      hwg_SetAdjOptions(::hScrollV,, tmp+nRows, i, nRows, nRows)
   ENDIF 
   IF ::hScrollH != NIL
      tmp := Len(::aColumns)
      hwg_SetAdjOptions(::hScrollH,, tmp+1, 1, 1, 1)
   ENDIF 

   IF ::internal[1] == 0
      IF ::rowPos != ::internal[2] .AND. !::lAppMode
         Eval(::bSkip, Self, ::internal[2] - ::rowPos)
      ENDIF
      IF ::aSelected != NIL .AND. AScan(::aSelected, {|x|x = Eval(::bRecno, Self)}) > 0
         ::LineOut(::internal[2], 0, hDC, .T.)
      ELSE
         ::LineOut(::internal[2], 0, hDC, .F.)
      ENDIF
      IF ::rowPos != ::internal[2] .AND. !::lAppMode
         Eval(::bSkip, Self, ::rowPos - ::internal[2])
      ENDIF
   ELSE
      IF Eval(::bEof, Self)
         Eval(::bGoTop, Self)
         ::rowPos := 1
      ENDIF
      IF ::rowPos > nRows .AND. nRows > 0
         ::rowPos := nRows
      ENDIF
      tmp := Eval(::bRecno, Self)
      IF ::rowPos > 1
         Eval(::bSkip, Self, -(::rowPos - 1))
      ENDIF
      i := 1
      DO WHILE .T.
         IF Eval(::bRecno, Self) == tmp
            ::rowPos := i
         ENDIF
         IF i > nRows .OR. Eval(::bEof, Self)
            EXIT
         ENDIF
         IF ::aSelected != NIL .AND. AScan(::aSelected, {|x|x = Eval(::bRecno, Self)}) > 0
            ::LineOut(i, 0, hDC, .T.)
         ELSE
            ::LineOut(i, 0, hDC, .F.)
         ENDIF
         i ++
         Eval(::bSkip, Self, 1)
      ENDDO
      ::rowCurrCount := i - 1

      IF ::rowPos >= i
         ::rowPos := IIf(i > 1, i - 1, 1)
      ENDIF
      DO WHILE i <= nRows
         IF ::aSelected != NIL .AND. AScan(::aSelected, {|x|x = Eval(::bRecno, Self)}) > 0
            ::LineOut(i, 0, hDC, .T., .T.)
         ELSE
            ::LineOut(i, 0, hDC, .F., .T.)
         ENDIF
         i ++
      ENDDO

      Eval(::bGoTo, Self, tmp)
   ENDIF
   IF ::lAppMode
      ::LineOut(nRows+1, 0, hDC, .F., .T.)
   ENDIF

   ::LineOut(::rowPos, IIf(::lEditable, ::colpos, 0), hDC, .T.)
   IF hwg_Checkbit(::internal[1], 1) .OR. ::lAppMode
      ::HeaderOut(hDC)
      if ::nFootRows > 0
         ::FooterOut(hDC)
      endif
   ENDIF

   hwg_ReleaseDC(::area, hDC)
   ::internal[1] := 15
   ::internal[2] := ::rowPos
   tmp := Eval(::bRecno, Self)
   IF ::recCurr != tmp
      ::recCurr := tmp
      IF ::bPosChanged != NIL
         Eval(::bPosChanged, Self)
      ENDIF
   ENDIF

   IF ::lAppMode
      ::Edit()
   ENDIF

   IF ::oGet == NIL .AND. ((tmp := hwg_GetFocus()) == ::oParent:handle .OR. ;
         ::oParent:FindControl(, tmp) != NIL)
      hwg_SetFocus(::area)
   ENDIF
   ::lAppMode := .F.

RETURN NIL

//----------------------------------------------------//
METHOD HeaderOut(hDC) CLASS HBrowse
Local i, x, oldc, fif, xSize
Local nRows := Min(::nRecords+IIf(::lAppMode, 1, 0), ::rowCount)
Local oPen // , oldBkColor := hwg_SetBkColor(hDC, hwg_GetSysColor(COLOR_3DFACE))
Local oColumn, nLine, cStr, cNWSE, oPenHdr, oPenLight

   /*
   IF ::lSep3d
      oPenLight := HPen():Add(PS_SOLID, 1, hwg_GetSysColor(COLOR_3DHILIGHT))
   ENDIF
   */
   IF ::lDispSep
      oPen := HPen():Add(PS_SOLID, 1, ::sepColor)
      hwg_SelectObject(hDC, oPen:handle)
   ENDIF

   x := ::x1
   if ::headColor != NIL
      oldc := hwg_SetTextColor(hDC, ::headColor)
   endif
   fif := IIf(::freeze > 0, 1, ::nLeftCol)

   while x < ::x2 - 2
      oColumn := ::aColumns[fif]
      xSize := oColumn:width
      if ::lAdjRight .AND. fif == Len(::aColumns)
         xSize := Max(::x2 - x, xSize)
      endif
      if ::lDispHead .AND. !::lAppMode
         if oColumn:cGrid == NIL
            hwg_DrawButton(hDC, x-1, ::y1-::height*::nHeadRows, x+xSize-1, ::y1+1, 5)
         else
            hwg_DrawButton(hDC, x-1, ::y1-::height*::nHeadRows, x+xSize-1, ::y1+1, 0)
            if oPenHdr == NIL
               oPenHdr := HPen():Add(BS_SOLID, 1, 0)
            endif
            hwg_SelectObject(hDC, oPenHdr:handle)
            cStr := oColumn:cGrid + ';'
            for nLine := 1 to ::nHeadRows
               cNWSE := hb_tokenGet(@cStr, nLine, ';')
               if At('S', cNWSE) != 0
                  hwg_DrawLine(hDC, x-1, ::y1-(::height)*(::nHeadRows-nLine), x+xSize-1, ::y1-(::height)*(::nHeadRows-nLine))
               endif
               if At('N', cNWSE) != 0
                  hwg_DrawLine(hDC, x-1, ::y1-(::height)*(::nHeadRows-nLine+1), x+xSize-1, ::y1-(::height)*(::nHeadRows-nLine+1))
               endif
               if At('E', cNWSE) != 0
                  hwg_DrawLine(hDC, x+xSize-2, ::y1-(::height)*(::nHeadRows-nLine+1)+1, x+xSize-2, ::y1-(::height)*(::nHeadRows-nLine))
               endif
               if At('W', cNWSE) != 0
                  hwg_DrawLine(hDC, x-1, ::y1-(::height)*(::nHeadRows-nLine+1)+1, x-1, ::y1-(::height)*(::nHeadRows-nLine))
               endif
            next
            hwg_SelectObject(hDC, oPen:handle)
         endif
         // Ahora Titulos Justificados !!!
         cStr := oColumn:heading + ';'
         for nLine := 1 to ::nHeadRows
            hwg_DrawText(hDC, hb_tokenGet(@cStr, nLine, ';'), x, ::y1-(::height)*(::nHeadRows-nLine+1)+1, x+xSize-1, ::y1-(::height)*(::nHeadRows-nLine),;
               oColumn:nJusHead  + if(oColumn:lSpandHead, DT_NOCLIP, 0))
         next
      endif
      if ::lDispSep .AND. x > ::x1
         IF ::lSep3d
            hwg_SelectObject(hDC, oPenLight:handle)
            hwg_DrawLine(hDC, x - 1, ::y1 + 1, x - 1, ::y1 + (::height + 1) * nRows)
            hwg_SelectObject(hDC, oPen:handle)
            hwg_DrawLine(hDC, x - 2, ::y1 + 1, x - 2, ::y1 + (::height + 1) * nRows)
         ELSE
            hwg_DrawLine(hDC, x - 1, ::y1 + 1, x - 1, ::y1 + (::height + 1) * nRows)
         ENDIF
      endif
      x += xSize
      if ! ::lAdjRight .AND. fif == Len(::aColumns)
         hwg_DrawLine(hDC, x - 1, ::y1 - (::height * ::nHeadRows), x - 1, ::y1 + (::height + 1) * nRows)
      endif
      fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
      if fif > Len(::aColumns)
         exit
      endif
   enddo

   IF ::lDispSep
      for i := 1 to nRows
         hwg_DrawLine(hDC, ::x1, ::y1 + (::height + 1) * i, IIf(::lAdjRight, ::x2, x), ::y1 + (::height + 1) * i)
      next
      oPen:Release()
      if oPenHdr != NIL
         oPenHdr:Release()
      endif
      if oPenLight != NIL
         oPenLight:Release()
      endif  
   ENDIF

   /* hwg_SetBkColor(hDC, oldBkColor) */
   if ::headColor != NIL
      hwg_SetTextColor(hDC, oldc)
   ENDIF

RETURN NIL

//----------------------------------------------------//
METHOD FooterOut(hDC) CLASS HBrowse
Local i, x, fif, xSize, oPen, nLine, cStr
Local oColumn

   IF ::lDispSep
      oPen := HPen():Add(BS_SOLID, 1, ::sepColor)
      hwg_SelectObject(hDC, oPen:handle)
   ENDIF

   x := ::x1
   fif := IIf(::freeze > 0, 1, ::nLeftCol)

   while x < ::x2 - 2
      oColumn := ::aColumns[fif]
      xSize := oColumn:width
      if ::lAdjRight .AND. fif == Len(::aColumns)
         xSize := Max(::x2 - x, xSize)
      endif
      if oColumn:footing != NIL
         cStr := oColumn:footing + ';'
         for nLine := 1 to ::nFootRows
            hwg_DrawText(hDC, hb_tokenGet(@cStr, nLine, ';'),;
               x, ::y1+(::rowCount+nLine-1)*(::height+1)+1, x+xSize-1, ::y1+(::rowCount+nLine)*(::height+1),;
               oColumn:nJusLin + if(oColumn:lSpandFoot, DT_NOCLIP, 0))
         next
      endif
      x += xSize
      fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
      if fif > Len(::aColumns)
         exit
      endif
   enddo

   IF ::lDispSep
      hwg_DrawLine(hDC, ::x1, ::y1 + (::rowCount) * (::height + 1) + 1, IIf(::lAdjRight, ::x2, x), ::y1 + (::rowCount) * (::height + 1) + 1)
      oPen:Release()
   ENDIF

RETURN NIL

//----------------------------------------------------//
METHOD LineOut(nstroka, vybfld, hDC, lSelected, lClear) CLASS HBrowse
Local x, dx, i := 1, shablon, sviv, fif, fldname, slen, xSize
Local j, ob, bw, bh, y1, hBReal
Local oldBkColor, oldTColor, oldBk1Color, oldT1Color
Local oLineBrush := IIf(lSelected, ::brushSel, ::brush)
Local lColumnFont := .F.
Local aCores

   ::xpos := x := ::x1
   IF lClear == NIL ; lClear := .F. ; ENDIF

   IF ::bLineOut != NIL
      Eval(::bLineOut, Self, lSelected)
   ENDIF
   IF ::nRecords > 0
      oldBkColor := hwg_SetBkColor(hDC, IIf(lSelected, ::bcolorSel, ::bcolor))
      oldTColor  := hwg_SetTextColor(hDC, IIf(lSelected, ::tcolorSel, ::tcolor))
      fldname := Space(8)
      fif     := IIf(::freeze > 0, 1, ::nLeftCol)

      WHILE x < ::x2 - 2
         IF ::aColumns[fif]:bColorBlock != NIL
            aCores := eval(::aColumns[fif]:bColorBlock)
            IF lSelected
              ::aColumns[fif]:tColor := aCores[3]
              ::aColumns[fif]:bColor := aCores[4]
            ELSE
              ::aColumns[fif]:tColor := aCores[1]
              ::aColumns[fif]:bColor := aCores[2]
            ENDIF
            ::aColumns[fif]:brush := HBrush():Add(::aColumns[fif]:bColor)
         ENDIF
         xSize := ::aColumns[fif]:width
         IF ::lAdjRight .AND. fif == Len(::aColumns)
            xSize := Max(::x2 - x, xSize)
         ENDIF
         IF i == ::colpos
            ::xpos := x
         ENDIF

         IF vybfld == 0 .OR. vybfld == i
            IF ::aColumns[fif]:bColor != NIL .AND. ::aColumns[fif]:brush == NIL
               ::aColumns[fif]:brush := HBrush():Add(::aColumns[fif]:bColor)
            ENDIF
            hBReal := IIf(::aColumns[fif]:brush != NIL, ;
                         ::aColumns[fif]:brush:handle,   ;
                         oLineBrush:handle)
            hwg_FillRect(hDC, x, ::y1+(::height+1)*(nstroka-1)+1, x+xSize-IIf(::lSep3d, 2, 1)-1, ::y1+(::height+1)*nstroka, hBReal)
            IF !lClear
               IF ::aColumns[fif]:aBitmaps != NIL .AND. !Empty(::aColumns[fif]:aBitmaps)
                  FOR j := 1 TO Len(::aColumns[fif]:aBitmaps)
                     IF Eval(::aColumns[fif]:aBitmaps[j, 1], Eval(::aColumns[fif]:block, , Self, fif), lSelected)
                        ob := ::aColumns[fif]:aBitmaps[j, 2]
                        // IF ob:nHeight > ::height
                           y1 := 0
                           bh := ::height
                           bw := Int(ob:nWidth * (ob:nHeight / ::height))
                           hwg_DrawBitmap(hDC, ob:handle,, x, y1+::y1+(::height+1)*(nstroka-1)+1, bw, bh)
                        /*   
                        ELSE
                           y1 := Int((::height-ob:nHeight)/2)
                           bh := ob:nHeight
                           bw := ob:nWidth
                           hwg_DrawTransparentBitmap(hDC, ob:handle, x, y1+::y1+(::height+1)*(nstroka-1)+1)
                        ENDIF
                        */
                        EXIT
                     ENDIF
                  NEXT
               ELSE
                  sviv := AllTrim(FldStr(Self, fif))
                  // Ahora lineas Justificadas !!
                  IF ::aColumns[fif]:tColor != NIL
                     oldT1Color := hwg_SetTextColor(hDC, ::aColumns[fif]:tColor)
                  ENDIF
                  IF ::aColumns[fif]:bColor != NIL
                     oldBk1Color := hwg_SetBkColor(hDC, ::aColumns[fif]:bColor)
                  ENDIF
                  IF ::aColumns[fif]:oFont != NIL
                     hwg_SelectObject(hDC, ::aColumns[fif]:oFont:handle)
                     lColumnFont := .T.
                  ELSEIF lColumnFont
                     hwg_SelectObject(hDC, ::ofont:handle)
                     lColumnFont := .F.
                  ENDIF
                  hwg_DrawText(hDC, sviv, x, ::y1+(::height+1)*(nstroka-1)+1, x+xSize-2, ::y1+(::height+1)*nstroka-1, ::aColumns[fif]:nJusLin)
                  IF ::aColumns[fif]:tColor != NIL
                     hwg_SetTextColor(hDC, oldT1Color)
                  ENDIF
                  IF ::aColumns[fif]:bColor != NIL
                     hwg_SetBkColor(hDC, oldBk1Color)
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         x += xSize
         fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
         i ++
         IF ! ::lAdjRight .AND. fif > Len(::aColumns)
            EXIT
         ENDIF
      ENDDO
      hwg_SetTextColor(hDC, oldTColor)
      hwg_SetBkColor(hDC, oldBkColor)
      IF lColumnFont
         hwg_SelectObject(hDC, ::ofont:handle)
      ENDIF
   ENDIF
   
RETURN NIL


//----------------------------------------------------//
METHOD SetColumn(nCol) CLASS HBrowse
Local nColPos, lPaint := .F.

   IF ::lEditable
      IF nCol != NIL .AND. nCol >= 1 .AND. nCol <= Len(::aColumns)
         IF nCol <= ::freeze
            ::colpos := nCol
         ELSEIF nCol >= ::nLeftCol .AND. nCol <= ::nLeftCol + ::Columns - ::freeze - 1
            ::colpos := nCol - ::nLeftCol + ::freeze + 1
         ELSE
            ::nLeftCol := nCol
            ::colpos := ::freeze + 1
            lPaint := .T.
         ENDIF
         IF !lPaint
            ::RefreshLine()
         ELSE
            /* hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE) */
         ENDIF
      ENDIF

      IF ::colpos <= ::freeze
         nColPos := ::colpos
      ELSE
         nColPos := ::nLeftCol + ::colpos - ::freeze - 1
      ENDIF
      RETURN nColPos

   ENDIF

RETURN 1

//----------------------------------------------------//
METHOD DoHScroll(wParam) CLASS HBrowse
Local nScrollH, nLeftCol, colpos

   IF wParam == NIL
      nScrollH := hwg_getAdjValue(::hScrollH)
      IF nScrollH - ::nScrollH < 0
         LineLeft(Self)
      ELSEIF nScrollH - ::nScrollH > 0
         LineRight(Self)
      ENDIF
   ELSE
      IF wParam == SB_LEFT
         nLeftCol := colPos := 0
         DO WHILE nLeftCol != ::nLeftCol .OR. colPos != ::colPos
            nLeftCol := ::nLeftCol
            colPos := ::colPos
            LineLeft(Self, .F.)
         ENDDO
      ELSE
         nLeftCol := colPos := 0
         DO WHILE nLeftCol != ::nLeftCol .OR. colPos != ::colPos
            nLeftCol := ::nLeftCol
            colPos := ::colPos
            LineRight(Self, .F.)
         ENDDO
      ENDIF
      hwg_InvalidateRect(::area, 0)
   ENDIF

RETURN NIL

//----------------------------------------------------//
STATIC FUNCTION LINERIGHT(oBrw, lRefresh)
Local maxPos, nPos, oldLeft := oBrw:nLeftCol, oldPos := oBrw:colpos, fif
LocaL i, nColumns := Len(oBrw:aColumns)
   
   IF oBrw:lEditable .AND. oBrw:colpos < oBrw:nColumns
         oBrw:colpos ++
   ELSEIF oBrw:nColumns + oBrw:nLeftCol - oBrw:freeze - 1 < nColumns ;
               .AND. oBrw:nLeftCol < nColumns
      i := oBrw:nLeftCol + oBrw:nColumns
      DO WHILE oBrw:nColumns + oBrw:nLeftCol - oBrw:freeze - 1 < nColumns .AND. oBrw:nLeftCol + oBrw:nColumns = i
         oBrw:nLeftCol ++
      ENDDO
      oBrw:colpos := i - oBrw:nLeftCol + 1
   ENDIF
   
   IF oBrw:nLeftCol != oldLeft .OR. oBrw:colpos != oldpos
      IF oBrw:hScrollH != NIL
         maxPos := hwg_getAdjValue(oBrw:hScrollH, 1) - hwg_getAdjValue(oBrw:hScrollH, 4)
         fif := IIf(oBrw:lEditable, oBrw:colpos + oBrw:nLeftCol - 1, oBrw:nLeftCol)
         nPos := IIf(fif == 1, 0, IIf(fif = nColumns, maxpos, Int((maxPos + 1) * fif / nColumns)))
         hwg_SetAdjOptions(oBrw:hScrollH, nPos)
         oBrw:nScrollH := nPos
      ENDIF
      IF lRefresh == NIL .OR. lRefresh
         IF oBrw:nLeftCol == oldLeft
            oBrw:internal[1] := 1
            hwg_InvalidateRect(oBrw:area, 0, oBrw:x1, oBrw:y1+(oBrw:height+1)*oBrw:internal[2]-oBrw:height, oBrw:x2, oBrw:y1+(oBrw:height+1)*(oBrw:rowPos+1))
         ELSE
            hwg_InvalidateRect(oBrw:area, 0)
         ENDIF
      ENDIF
   ENDIF
   hwg_SetFocus(oBrw:area)
   
RETURN NIL

//----------------------------------------------------//
STATIC FUNCTION LINELEFT(oBrw, lRefresh)
Local maxPos, nPos, oldLeft := oBrw:nLeftCol, oldPos := oBrw:colpos, fif
LocaL nColumns := Len(oBrw:aColumns)

   IF oBrw:lEditable
      oBrw:colpos --
   ENDIF
   IF oBrw:nLeftCol > oBrw:freeze + 1 .AND. (!oBrw:lEditable .OR. oBrw:colpos < oBrw:freeze + 1)
      oBrw:nLeftCol --
      IF ! oBrw:lEditable .OR. oBrw:colpos < oBrw:freeze + 1
         oBrw:colpos := oBrw:freeze + 1 
      ENDIF
   ENDIF
   IF oBrw:colpos < 1
      oBrw:colpos := 1
   ENDIF
   IF oBrw:nLeftCol != oldLeft .OR. oBrw:colpos != oldpos
      IF oBrw:hScrollH != NIL
         maxPos := hwg_getAdjValue(oBrw:hScrollH, 1) - hwg_getAdjValue(oBrw:hScrollH, 4)
         fif := IIf(oBrw:lEditable, oBrw:colpos + oBrw:nLeftCol - 1, oBrw:nLeftCol)
         nPos := IIf(fif == 1, 0, IIf(fif = nColumns, maxpos, Int((maxPos + 1) * fif / nColumns)))
         hwg_SetAdjOptions(oBrw:hScrollH, nPos)
         oBrw:nScrollH := nPos
      ENDIF
      IF lRefresh == NIL .OR. lRefresh
         IF oBrw:nLeftCol == oldLeft
            oBrw:internal[1] := 1
            hwg_InvalidateRect(oBrw:area, 0, oBrw:x1, oBrw:y1+(oBrw:height+1)*oBrw:internal[2]-oBrw:height, oBrw:x2, oBrw:y1+(oBrw:height+1)*(oBrw:rowPos+1))
         ELSE
            hwg_InvalidateRect(oBrw:area, 0)
         ENDIF
      ENDIF
   ENDIF
   hwg_SetFocus(oBrw:area)

RETURN NIL

//----------------------------------------------------//
METHOD DoVScroll(wParam) CLASS HBrowse
Local nScrollV := hwg_getAdjValue(::hScrollV)

   if nScrollV - ::nScrollV == 1
      ::LINEDOWN(.T.)
   elseif nScrollV - ::nScrollV == -1
      ::LINEUP(.T.)
   elseif nScrollV - ::nScrollV == 10
      ::PAGEDOWN(.T.)
   elseif nScrollV - ::nScrollV == -10
      ::PAGEUP(.T.)
   else
      IF ::bScrollPos != NIL
         Eval(::bScrollPos, Self, SB_THUMBTRACK, .F., nScrollV)
      ENDIF
   endif
   ::nScrollV := nScrollV
   // writelog("DoVScroll " + LTrim(Str(::nScrollV)) + " " + LTrim(Str(::nCurrent)) + "( " + LTrim(Str(::nRecords)) + " )")
RETURN 0

//----------------------------------------------------//
METHOD LINEDOWN(lMouse) CLASS HBrowse
Local maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
Local nPos

   lMouse := IIf(lMouse == NIL, .F., lMouse)
   Eval(::bSkip, Self, 1)
   IF Eval(::bEof, Self)
      Eval(::bSkip, Self, -1)
      IF ::lAppable .AND. !lMouse
         ::lAppMode := .T.
      ELSE
         hwg_SetFocus(::area)
         RETURN NIL
      ENDIF
   ENDIF
   ::rowPos ++
   IF ::rowPos > ::rowCount
      ::rowPos := ::rowCount
      hwg_InvalidateRect(::area, 0)
   ELSE
      ::internal[1] := 1
      hwg_InvalidateRect(::area, 0, ::x1, ::y1+(::height+1)*::internal[2]-::height, ::x2, ::y1+(::height+1)*(::rowPos+1))
   ENDIF
   IF ::lAppMode 
      IF ::rowPos > 1
         ::rowPos --
      ENDIF
      ::colPos := ::nLeftCol := 1
   ENDIF
   IF !lMouse .AND. ::hScrollV != NIL
      IF ::bScrollPos != NIL
         Eval(::bScrollPos, Self, 1, .F.)
      ELSE
         nPos := hwg_getAdjValue(::hScrollV)
         nPos += Int(maxPos/(::nRecords-1))
         hwg_SetAdjOptions(::hScrollV, nPos)
         ::nScrollV := nPos
      ENDIF
   ENDIF

   hwg_SetFocus(::area)

RETURN NIL

//----------------------------------------------------//
METHOD LINEUP(lMouse) CLASS HBrowse
Local maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
Local nPos

   lMouse := IIf(lMouse == NIL, .F., lMouse)
   Eval(::bSkip, Self, -1)
   IF Eval(::bBof, Self)
      Eval(::bGoTop, Self)
   ELSE
      ::rowPos --
      IF ::rowPos = 0
         ::rowPos := 1
         hwg_InvalidateRect(::area, 0)
      ELSE
         ::internal[1] := 1
         hwg_InvalidateRect(::area, 0, ::x1, ::y1+(::height+1)*::internal[2]-::height, ::x2, ::y1+(::height+1)*::internal[2])
         hwg_InvalidateRect(::area, 0, ::x1, ::y1+(::height+1)*::rowPos-::height, ::x2, ::y1+(::height+1)*::rowPos)
      ENDIF

      IF !lMouse .AND. ::hScrollV != NIL
         IF ::bScrollPos != NIL
            Eval(::bScrollPos, Self, -1, .F.)
         ELSE
            nPos := hwg_getAdjValue(::hScrollV)
            nPos -= Int(maxPos/(::nRecords-1))
            hwg_SetAdjOptions(::hScrollV, nPos)
            ::nScrollV := nPos
         ENDIF
      ENDIF
      
   ENDIF
   hwg_SetFocus(::area)
   
RETURN NIL

//----------------------------------------------------//
METHOD PAGEUP(lMouse) CLASS HBrowse
Local maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
Local nPos, step, lBof := .F.

   lMouse := IIf(lMouse == NIL, .F., lMouse)
   IF ::rowPos > 1
      step := (::rowPos - 1)
      Eval(::bSKip, Self, -step)
      ::rowPos := 1
   ELSE
      step := ::rowCurrCount    // Min(::nRecords, ::rowCount)
      Eval(::bSkip, Self, -step)
      IF Eval(::bBof, Self)
         Eval(::bGoTop, Self)
         lBof := .T.
      ENDIF
   ENDIF

   IF !lMouse .AND. ::hScrollV != NIL
      IF ::bScrollPos != NIL
         Eval(::bScrollPos, Self, -step, lBof)
      ELSE
         nPos := hwg_getAdjValue(::hScrollV)
         nPos -= Int(maxPos/(::nRecords-1))
         nPos := Max(nPos - Int(maxPos*step/(::nRecords-1)), 0)
         hwg_SetAdjOptions(::hScrollV, nPos)
         ::nScrollV := nPos
      ENDIF
   ENDIF

   hwg_InvalidateRect(::area, 0)
   hwg_SetFocus(::area)
RETURN NIL

//----------------------------------------------------//
METHOD PAGEDOWN(lMouse) CLASS HBrowse
Local maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
Local nPos, nRows := ::rowCurrCount
Local step := IIf(nRows > ::rowPos, nRows - ::rowPos + 1, nRows), lEof

   lMouse := IIf(lMouse == NIL, .F., lMouse)
   Eval(::bSkip, Self, step)
   ::rowPos := Min(::nRecords, nRows)
   lEof := Eval(::bEof, Self)
   IF lEof .AND. ::bScrollPos == NIL
      Eval(::bSkip, Self, -1)
   ENDIF

   IF !lMouse .AND. ::hScrollV != NIL
      IF ::bScrollPos != NIL
         Eval(::bScrollPos, Self, step, lEof)
      ELSE
         nPos := hwg_getAdjValue(::hScrollV)
         IF lEof     
            nPos := maxPos
         ELSE
            nPos := Min(nPos + Int(maxPos*step/(::nRecords-1)), maxPos)
         ENDIF
         hwg_SetAdjOptions(::hScrollV, nPos)
         ::nScrollV := nPos
      ENDIF
   ENDIF

   hwg_InvalidateRect(::area, 0)
   hwg_SetFocus(::area)
RETURN NIL

//----------------------------------------------------//
METHOD BOTTOM(lPaint) CLASS HBrowse
Local nPos

   ::rowPos := lastrec()
   Eval(::bGoBot, Self)
   ::rowPos := min(::nRecords, ::rowCount)

   IF ::hScrollV != NIL
      nPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
      hwg_SetAdjOptions(::hScrollV, nPos)
      ::nScrollV := nPos
   ENDIF
   
   hwg_InvalidateRect(::area, 0)

   IF lPaint == NIL .OR. lPaint
      hwg_SetFocus(::area)
   ENDIF

RETURN NIL

//----------------------------------------------------//
METHOD TOP() CLASS HBrowse
Local nPos

   ::rowPos := 1
   Eval(::bGoTop, Self)

   IF ::hScrollV != NIL
      nPos := 0
      hwg_SetAdjOptions(::hScrollV, nPos)
      ::nScrollV := nPos
   ENDIF
   
   hwg_InvalidateRect(::area, 0)
   hwg_SetFocus(::area)

RETURN NIL

//----------------------------------------------------//
METHOD ButtonDown(lParam) CLASS HBrowse
Local hBrw := ::handle
Local nLine := Int(hwg_HIWORD(lParam)/(::height+1) + IIf(::lDispHead, 1 - ::nHeadRows, 1))
Local step := nLine - ::rowPos, res := .F., nrec
Local maxPos, nPos
Local xm := hwg_LOWORD(lParam), x1, fif

   ::lBtnDbl := .F.
   x1  := ::x1
   fif := IIf(::freeze > 0, 1, ::nLeftCol)
   DO WHILE fif < (::nLeftCol+::nColumns) .AND. x1 + ::aColumns[fif]:width < xm
      x1 += ::aColumns[fif]:width
      fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
   ENDDO

   IF nLine > 0 .AND. nLine <= ::rowCurrCount
      IF step != 0
         nrec := Recno()
         Eval(::bSkip, Self, step)
         IF !Eval(::bEof, Self)
            ::rowPos := nLine
	    IF ::hScrollV != NIL
               IF ::bScrollPos != NIL
                  Eval(::bScrollPos, Self, step, .F.)
               ELSE	    
                  nPos := hwg_getAdjValue(::hScrollV)
		  maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
                  nPos := Min(nPos + Int(maxPos*step/(::nRecords-1)), maxPos)
   	          hwg_SetAdjOptions(::hScrollV, nPos)
               ENDIF
	    ENDIF
            res := .T.
         ELSE
            Go nrec
         ENDIF
      ENDIF
      IF ::lEditable
         IF ::colpos != fif - ::nLeftCol + 1 + :: freeze
            ::colpos := fif - ::nLeftCol + 1 + :: freeze
	    IF ::hScrollH != NIL
	       maxPos := hwg_getAdjValue(::hScrollH, 1) - hwg_getAdjValue(::hScrollH, 4)
               nPos := IIf(fif == 1, 0, IIf(fif = Len(::aColumns), maxpos, ;
                       Int((maxPos + 1) * fif / Len(::aColumns))))
	       hwg_SetAdjOptions(::hScrollH, nPos)
	    ENDIF
            res := .T.
         ENDIF
      ENDIF
      IF res
         ::internal[1] := 1
         hwg_InvalidateRect(::area, 0, ::x1, ::y1+(::height+1)*::internal[2]-::height, ::x2, ::y1+(::height+1)*::internal[2])
         hwg_InvalidateRect(::area, 0, ::x1, ::y1+(::height+1)*::rowPos-::height, ::x2, ::y1+(::height+1)*::rowPos)
      ENDIF
      
   ELSEIF ::lDispHead .AND.;
          nLine >= -::nHeadRows .AND.;
          fif <= Len(::aColumns) .AND.;
          ::aColumns[fif]:bHeadClick != NIL

      Eval(::aColumns[fif]:bHeadClick, Self, fif)

   ELSEIF nLine == 0
      IF ::nCursor == 1
         ::nCursor := 2
         hwg_SetCursor(vCursor, ::area)
         xDrag := hwg_LOWORD(lParam)
      ENDIF
   ENDIF

RETURN NIL

//----------------------------------------------------//
METHOD ButtonUp(lParam) CLASS HBrowse
Local hBrw := ::handle
Local xPos := hwg_LOWORD(lParam), x := ::x1, x1, i := ::nLeftCol

   IF ::lBtnDbl
      ::lBtnDbl := .F.
      RETURN NIL
   ENDIF
   IF ::nCursor == 2
      DO WHILE x < xDrag
         x += ::aColumns[i]:width
         IF Abs(x-xDrag) < 10
            x1 := x - ::aColumns[i]:width
            EXIT
         ENDIF
         i++
      ENDDO
      IF xPos > x1
         ::aColumns[i]:width := xPos - x1
         hwg_SetCursor(arrowCursor, ::area)
         ::nCursor := 0     
         hwg_InvalidateRect(hBrw, 0)
      ENDIF
   ELSEIF ::aSelected != NIL
      IF ::nCtrlPress == GDK_Control_L
         IF (i := AScan(::aSelected, Eval(::bRecno, Self))) > 0
            ADel(::aSelected, i)
            ASize(::aSelected, Len(::aSelected) - 1)
         ELSE
            AAdd(::aSelected, Eval(::bRecno, Self))
         ENDIF
      ELSE
         IF Len(::aSelected) > 0
            ::aSelected := {}
            ::Refresh()
         ENDIF
      ENDIF
   ENDIF

   hwg_SetFocus(::area)
RETURN NIL

//----------------------------------------------------//
METHOD ButtonDbl(lParam) CLASS HBrowse
Local hBrw := ::handle
Local nLine := Int(hwg_HIWORD(lParam)/(::height+1) + IIf(::lDispHead, 1 - ::nHeadRows, 1))

   if nLine <= ::rowCurrCount
      ::ButtonDown(lParam)
      ::Edit()
   endif
   ::lBtnDbl := .T.
RETURN NIL

//----------------------------------------------------//
METHOD MouseMove(wParam, lParam) CLASS HBrowse
Local xPos := hwg_LOWORD(lParam), yPos := hwg_HIWORD(lParam)
Local x := ::x1, i := ::nLeftCol, res := .F.

   IF !::active .OR. Empty(::aColumns) .OR. ::x1 == NIL
      RETURN NIL
   ENDIF
   IF ::lDispSep .AND. yPos <= ::height+1
      IF wParam == 1 .AND. ::nCursor == 2
         hwg_SetCursor(vCursor, ::area)
         res := .T.
      ELSE
         DO WHILE x < ::x2 - 2 .AND. i <= Len(::aColumns)
            x += ::aColumns[i++]:width
            IF Abs(x - xPos) < 8
                  IF ::nCursor != 2
                     ::nCursor := 1
                  ENDIF
                  hwg_SetCursor(IIf(::nCursor == 1, crossCursor, vCursor), ::area)
               res := .T.
               EXIT
            ENDIF
         ENDDO
      ENDIF
      IF !res .AND. ::nCursor != 0
         hwg_SetCursor(arrowCursor, ::area)
         ::nCursor := 0
      ENDIF
   ENDIF
RETURN NIL

//----------------------------------------------------------------------------//
METHOD MouseWheel(nKeys, nDelta, nXPos, nYPos) CLASS HBrowse
   if hwg_BitAnd(nKeys, MK_MBUTTON) != 0
      if nDelta > 0
         ::PageUp()
      else
         ::PageDown()
      endif
   else
      if nDelta > 0
         ::LineUp()
      else
         ::LineDown()
      endif
   endif
RETURN NIL

//----------------------------------------------------//
METHOD Edit(wParam, lParam) CLASS HBrowse
Local fipos, lRes, x1, y1, fif, nWidth, lReadExit, rowPos
Local oColumn, type

   fipos := ::colpos + ::nLeftCol - 1 - ::freeze
   IF ::bEnter == NIL .OR. ;
         (HB_IsLogical(lRes := Eval(::bEnter, Self, fipos)) .AND. !lRes)
      oColumn := ::aColumns[fipos]
      IF ::type == BRW_DATABASE
         ::varbuf := (::alias)->(Eval(oColumn:block, , Self, fipos))
      ELSE
         ::varbuf := Eval(oColumn:block, , Self, fipos)
      ENDIF
      type := IIf(oColumn:type == "U" .AND. ::varbuf != NIL, ValType(::varbuf), oColumn:type)
      IF ::lEditable .AND. type != "O"        
         IF oColumn:lEditable .AND. (oColumn:bWhen == NIL .OR. Eval(oColumn:bWhen))
            IF ::lAppMode
               IF type == "D"
                  ::varbuf := CtoD("")
               ELSEIF type == "N"
                  ::varbuf := 0
               ELSEIF type == "L"
                  ::varbuf := .F.
               ELSE
                  ::varbuf := ""
               ENDIF
            ENDIF
         ELSE
            RETURN NIL
         ENDIF
         x1  := ::x1
         fif := IIf(::freeze > 0, 1, ::nLeftCol)
         DO WHILE fif < fipos
            x1 += ::aColumns[fif]:width
            fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
         ENDDO
         nWidth := Min(::aColumns[fif]:width, ::x2 - x1 - 1)
         rowPos := ::rowPos - 1
         IF ::lAppMode .AND. ::nRecords != 0
            rowPos ++
         ENDIF
         y1 := ::y1+(::height+1)*rowPos
	 
         ::nGetRec := Eval(::bRecno, Self)
         @ x1, y1 GET ::oGet VAR ::varbuf      ;
	       OF ::oParent                   ;
               SIZE nWidth, ::height+1        ;
               STYLE ES_AUTOHSCROLL           ;
               FONT ::oFont                   ;
               PICTURE oColumn:picture        ;
               VALID {||VldBrwEdit(Self, fipos)}
	 ::oGet:Show()
	 hwg_SetFocus(::oGet:handle)
	 hwg_edit_SetPos(::oGet:handle, 0)
       ::oGet:bAnyEvent := {|o, msg, c|GetEventHandler(Self, msg, c)}

      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION GetEventHandler(oBrw, msg, cod)

   IF msg == WM_KEYDOWN .AND. cod == GDK_Escape
      oBrw:oGet:nLastKey := GDK_Escape
      hwg_SetFocus(oBrw:area)
      RETURN 1
   ENDIF
RETURN 0

STATIC FUNCTION VldBrwEdit(oBrw, fipos)
Local oColumn := oBrw:aColumns[fipos], nRec, fif, nChoic

   IF oBrw:oGet:nLastKey != GDK_Escape
      IF oColumn:aList != NIL
         IF HB_IsNumeric(oBrw:varbuf)
            oBrw:varbuf := nChoic
         ELSE
            oBrw:varbuf := oColumn:aList[nChoic]
         ENDIF
      ENDIF
      IF oBrw:lAppMode
         oBrw:lAppMode := .F.
         IF oBrw:type == BRW_DATABASE
            (oBrw:alias)->(dbAppend())
            (oBrw:alias)->(Eval(oColumn:block, oBrw:varbuf, oBrw, fipos))
            UNLOCK
         ELSE
            IF HB_IsArray(oBrw:aArray[1])
               AAdd(oBrw:aArray, Array(Len(oBrw:aArray[1])))
               FOR fif := 2 TO Len((oBrw:aArray[1]))
                  oBrw:aArray[Len(oBrw:aArray), fif] := ;
                              IIf(oBrw:aColumns[fif]:type == "D", CToD(Space(8)), ;
                                 IIf(oBrw:aColumns[fif]:type == "N", 0, ""))
               NEXT
            ELSE
               AAdd(oBrw:aArray, NIL)
            ENDIF
            oBrw:nCurrent := Len(oBrw:aArray)
            Eval(oColumn:block, oBrw:varbuf, oBrw, fipos)
         ENDIF
         IF oBrw:nRecords > 0
            oBrw:rowPos ++
         ENDIF
         oBrw:lAppended := .T.
         oBrw:Refresh()
      ELSE
         IF (nRec := Eval(oBrw:bRecno, oBrw)) != oBrw:nGetRec
            Eval(oBrw:bGoTo, oBrw, oBrw:nGetRec)
         ENDIF
         IF oBrw:type == BRW_DATABASE
            IF (oBrw:alias)->(Rlock())
               (oBrw:alias)->(Eval(oColumn:block, oBrw:varbuf, oBrw, fipos))
            ELSE
               hwg_MsgStop("Can't lock the record!")
            ENDIF
         ELSE
            Eval(oColumn:block, oBrw:varbuf, oBrw, fipos)
         ENDIF
         IF nRec != oBrw:nGetRec
            Eval(oBrw:bGoTo, oBrw, nRec)
         ENDIF
         oBrw:lUpdated := .T.
      ENDIF
   ENDIF

   oBrw:Refresh()
   // Execute block after changes are made
   IF oBrw:oGet:nLastKey != GDK_Escape .AND. oBrw:bUpdate != NIL
       Eval(oBrw:bUpdate, oBrw, fipos)
   ENDIF
   oBrw:oParent:DelControl(oBrw:oGet)
   oBrw:oGet := NIL
   hwg_SetFocus(oBrw:area)

RETURN .T.

//----------------------------------------------------//
METHOD RefreshLine() CLASS HBrowse
   ::internal[1] := 0
   hwg_InvalidateRect(::area, 0, ::x1, ::y1+(::height+1)*::rowPos-::height, ::x2, ::y1+(::height+1)*::rowPos)
RETURN NIL

//----------------------------------------------------//
METHOD Refresh(lFull) CLASS HBrowse

   IF lFull == NIL .OR. lFull
      ::internal[1] := 15
      hwg_RedrawWindow(::area, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   ELSE
      hwg_InvalidateRect(::area, 0)
      ::internal[1] := hwg_SetBit(::internal[1], 1, 0)
   ENDIF
   
RETURN NIL

//----------------------------------------------------//
STATIC FUNCTION FldStr(oBrw, numf)

   local fldtype
   local rez
   local vartmp
   local nItem := numf
   local type
   local pict

   if numf <= Len(oBrw:aColumns)

      pict := oBrw:aColumns[numf]:picture

      if pict != NIL
         if oBrw:type == BRW_DATABASE
             rez := (oBrw:alias)->(transform(Eval(oBrw:aColumns[numf]:block, , oBrw, numf), pict))
         else
             rez := transform(Eval(oBrw:aColumns[numf]:block, , oBrw, numf), pict)
         endif

      else
         if oBrw:type == BRW_DATABASE
             vartmp := (oBrw:alias)->(Eval(oBrw:aColumns[numf]:block, , oBrw, numf))
         else
             vartmp := Eval(oBrw:aColumns[numf]:block, , oBrw, numf)
         endif

         type := (oBrw:aColumns[numf]):type
         if type == "U" .AND. vartmp != NIL
            type := ValType(vartmp)
         endif
         SWITCH type
         CASE "C"
            rez := padr(vartmp, oBrw:aColumns[numf]:length)
            EXIT
         CASE "N"
            rez := PADL(Str(vartmp, oBrw:aColumns[numf]:length, oBrw:aColumns[numf]:dec), oBrw:aColumns[numf]:length)
            EXIT
         CASE "D"
            rez := PADR(DTOC(vartmp), oBrw:aColumns[numf]:length)
            EXIT
         CASE "L"
            rez := PADR(IIf(vartmp, "T", "F"), oBrw:aColumns[numf]:length)
            EXIT
         CASE "M"
            rez := "<Memo>"
            EXIT
         CASE "O"
            rez := "<" + vartmp:Classname() + ">"
            EXIT
         CASE "A"
            rez := "<Array>"
            EXIT
         #ifdef __XHARBOUR__
         DEFAULT
         #else
         OTHERWISE
         #endif
            rez := Space(oBrw:aColumns[numf]:length)
         ENDSWITCH
      endif
   endif

RETURN rez

//----------------------------------------------------//
STATIC FUNCTION FLDCOUNT(oBrw, xstrt, xend, fld1)

   local klf := 0, i := IIf(oBrw:freeze > 0, 1, fld1)

   while .T.
      xstrt += oBrw:aColumns[i]:width
      IF xstrt > xend
         EXIT
      ENDIF
      klf ++
      i   := IIf(i = oBrw:freeze, fld1, i + 1)
      IF i > Len(oBrw:aColumns)
         EXIT
      ENDIF
   ENDDO
RETURN IIf(klf == 0, 1, klf)

//----------------------------------------------------//
FUNCTION HWG_CREATEARLIST(oBrw, arr)
   local i
   oBrw:type  := BRW_ARRAY
   oBrw:aArray := arr
   IF Len(oBrw:aColumns) == 0
      // oBrw:aColumns := {}
      IF HB_IsArray(arr[1])
         FOR i := 1 TO Len(arr[1])
            oBrw:AddColumn(HColumn():New(, hwg_ColumnArBlock()))
         NEXT
      ELSE
         oBrw:AddColumn(HColumn():New(, {|value, o|o:aArray[o:nCurrent]}))
      ENDIF
   ENDIF
   Eval(oBrw:bGoTop, oBrw)
   oBrw:Refresh()
RETURN NIL

//----------------------------------------------------//
PROCEDURE ARSKIP(oBrw, kolskip)
Local tekzp1
   if oBrw:nRecords != 0
      tekzp1   := oBrw:nCurrent
      oBrw:nCurrent += kolskip + IIf(tekzp1 == 0, 1, 0)
      IF oBrw:nCurrent < 1
         oBrw:nCurrent := 0
      ELSEIF oBrw:nCurrent > oBrw:nRecords
         oBrw:nCurrent := oBrw:nRecords + 1
      ENDIF
   ENDIF
RETURN

//----------------------------------------------------//
FUNCTION hwg_CreateList(oBrw, lEditable)
Local i
Local nArea := select()
Local kolf := FCOUNT()

   oBrw:alias := alias()
   oBrw:aColumns := {}
   
   for i := 1 TO kolf
      oBrw:AddColumn(HColumn():New(Fieldname(i),                      ;
                                   FieldWBlock(Fieldname(i), nArea), ;
                                   dbFieldInfo(DBS_TYPE, i),         ;
                                   dbFieldInfo(DBS_LEN, i),          ;
                                   dbFieldInfo(DBS_DEC, i),          ;
                                   lEditable))
   next

   oBrw:Refresh()

RETURN NIL

FUNCTION hwg_VScrollPos(oBrw, nType, lEof, nPos)
Local maxPos := hwg_getAdjValue(oBrw:hScrollV, 1) - hwg_getAdjValue(oBrw:hScrollV, 4)
Local oldRecno, newRecno

   IF nPos == NIL
      IF nType > 0 .AND. lEof
         Eval(oBrw:bSkip, oBrw, -1)
      ENDIF
      nPos := Round((maxPos / (oBrw:nRecords - 1)) * (Eval(oBrw:bRecnoLog, oBrw) - 1), 0)
      hwg_SetAdjOptions(oBrw:hScrollV, nPos)
      oBrw:nScrollV := nPos
   ELSE
      oldRecno := Eval(oBrw:bRecnoLog, oBrw)
      newRecno := Round((oBrw:nRecords - 1) * nPos / maxPos + 1, 0)
      IF newRecno <= 0
         newRecno := 1
      ELSEIF newRecno > oBrw:nRecords
         newRecno := oBrw:nRecords
      ENDIF
      IF newRecno != oldRecno
         Eval(oBrw:bSkip, oBrw, newRecno - oldRecno)
         IF oBrw:rowCount - oBrw:rowPos > oBrw:nRecords - newRecno
            oBrw:rowPos := oBrw:rowCount - (oBrw:nRecords - newRecno)
         ENDIF
         IF oBrw:rowPos > newRecno
            oBrw:rowPos := newRecno
         ENDIF
         oBrw:Refresh()
      ENDIF
   ENDIF

RETURN NIL

//----------------------------------------------------//
// Agregado x WHT. 27.07.02
// Locus metodus.
METHOD ShowSizes() CLASS HBrowse
   local cText := ""
   AEval(::aColumns, {|v, e|cText += ::aColumns[e]:heading + ": " + Str(Round(::aColumns[e]:width / 8, 0) - 2) + Chr(10) + Chr(13)})
   hwg_MsgInfo(cText)
RETURN NIL

FUNCTION hwg_ColumnArBlock()
RETURN {|value, o, n|IIf(value == NIL, o:aArray[o:nCurrent, n], o:aArray[o:nCurrent, n] := value)}

STATIC FUNCTION HdrToken(cStr, nMaxLen, nCount)
Local nL, nPos := 0

   nMaxLen := nCount := 0
   cStr += ';'
   while (nL := Len(hb_tokenPtr(@cStr, @nPos, ";"))) != 0
      nMaxLen := Max(nMaxLen, nL)
      nCount ++
   enddo
RETURN NIL

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(CREATEARLIST, HWG_CREATEARLIST);
HB_FUNC_TRANSLATE(CREATELIST, HWG_CREATELIST);
HB_FUNC_TRANSLATE(VSCROLLPOS, HWG_VSCROLLPOS);
HB_FUNC_TRANSLATE(COLUMNARBLOCK, HWG_COLUMNARBLOCK);
#endif

#pragma ENDDUMP
