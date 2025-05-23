//
// HWGUI - Harbour Win32 GUI library source code:
// HGrid class
//
// Copyright 2004 Rodrigo Moreno <rodrigo_moreno@yahoo.com>
//

/*
TODO: 1) In line edit
         The better way is using listview_hittest to determine the item and subitem position
      2) Imagelist
         The way is using the ListView_SetImageList
      3) Checkbox
         The way is using the NM_CUSTOMDRAW and DrawFrameControl()

*/

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HGrid INHERIT HControl

   CLASS VAR winclass INIT "SYSLISTVIEW32"

   DATA aBitMaps INIT {}
   DATA ItemCount
   DATA color
   DATA bkcolor
   DATA aColumns INIT {}
   DATA nRow INIT 0
   DATA nCol INIT 0

   DATA lNoScroll INIT .F.
   DATA lNoBorder INIT .F.
   DATA lNoLines INIT .F.
   DATA lNoHeader INIT .F.

   DATA bEnter
   DATA bKeyDown
   DATA bPosChg
   DATA bDispInfo

   DATA bGfocus
   DATA bLfocus

   METHOD New(oWnd, nId, nStyle, x, y, width, height, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, ;
              lNoScroll, lNoBord, bKeyDown, bPosChg, bDispInfo, nItemCount, lNoLines, color, bkcolor, lNoHeader, aBit)
   METHOD Activate()
   METHOD Init()
   METHOD AddColumn(cHeader, nWidth, nJusHead, nBit) INLINE AAdd(::aColumns, {cHeader, nWidth, nJusHead, nBit})
   METHOD Refresh()
   METHOD RefreshLine() INLINE hwg_ListView_Update(::handle, hwg_Listview_GetFirstItem(::handle))
   METHOD SetItemCount(nItem) INLINE hwg_Listview_SetItemCount(::handle, nItem)
   METHOD Row() INLINE hwg_Listview_GetFirstItem(::handle)
   METHOD Notify(lParam)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGrid:New(oWnd, nId, nStyle, x, y, width, height, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoScroll, ;
           lNoBord, bKeyDown, bPosChg, bDispInfo, nItemCount, lNoLines, color, bkcolor, lNoHeader, aBit)

   DEFAULT aBit TO {}

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), LVS_SHOWSELALWAYS + WS_TABSTOP + IIf(lNoBord, 0, WS_BORDER) + ;
                       LVS_REPORT + LVS_OWNERDATA + LVS_SINGLESEL)

   ::Super:New(oWnd, nId, nStyle, x, y, width, height, oFont, bInit, bSize, bPaint)

   ::ItemCount := nItemCount
   ::aBitMaps := aBit
   ::bGfocus := bGfocus
   ::bLfocus := bLfocus
   ::color := color
   ::bkcolor := bkcolor
   ::lNoScroll := lNoScroll
   ::lNoBorder := lNoBord
   ::lNoLines := lNoLines
   ::lNoHeader := lNoHeader
   ::bEnter := bEnter
   ::bKeyDown := bKeyDown
   ::bPosChg := bPosChg
   ::bDispInfo := bDispInfo

   HWG_InitCommonControlsEx()

   ::Activate()

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGrid:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_ListView_Create(::oParent:handle, ::id, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::style, ::lNoHeader, ;
                                  ::lNoScroll)
      ::Init()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGrid:Init()

   LOCAL i
   LOCAL nPos
   LOCAL aButton := {}
   LOCAL aBmpSize
   LOCAL n

   IF !::lInit
      ::Super:Init()
      FOR n := 1 TO Len(::aBitmaps)
         AAdd(aButton, hwg_LoadImage(, ::aBitmaps[n], IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE + LR_CREATEDIBSECTION))
      NEXT

      IF Len(aButton) > 0

         aBmpSize := hwg_GetBitmapSize(aButton[1])

         IF aBmpSize[3] == 4
            ::hIm := hwg_CreateImageList({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR4 + ILC_MASK)
         ELSEIF aBmpSize[3] == 8
            ::hIm := hwg_CreateImageList({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR8 + ILC_MASK)
         ELSEIF aBmpSize[3] == 24
            ::hIm := hwg_CreateImageList({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
         ENDIF

         FOR nPos := 1 TO Len(aButton)

            aBmpSize := hwg_GetBitmapSize(aButton[nPos])

            IF aBmpSize[3] == 24
               //hwg_Imagelist_AddMasked(::hIm, aButton[nPos], hwg_RGB(236, 223, 216))
               hwg_Imagelist_Add(::hIm, aButton[nPos])
            ELSE
               hwg_Imagelist_Add(::hIm, aButton[nPos])
            ENDIF

         NEXT

         hwg_ListView_SetImageList(::handle, ::him)

      ENDIF

      hwg_Listview_Init(::handle, ::ItemCount, ::lNoLines)

      FOR i := 1 TO Len(::aColumns)
         hwg_Listview_AddColumn(::handle, i, ::aColumns[i, 2], ::aColumns[i, 1], ::aColumns[i, 3], ;
                            IIf(::aColumns[i, 4] != NIL, ::aColumns[i, 4], 0))
      NEXT

      IF ::color != NIL
         hwg_ListView_SetTextColor(::handle, ::color)
      ENDIF

      IF ::bkcolor != NIL
         hwg_Listview_SetBkColor(::handle, ::bkcolor)
         hwg_Listview_SetTextBkColor(::handle, ::bkcolor)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGrid:Refresh()

   LOCAL iFirst
   LOCAL iLast

   iFirst := hwg_ListView_GetTopIndex(::handle)
   iLast := iFirst + hwg_ListView_GetCountPerPage(::handle)
   hwg_ListView_RedrawItems(::handle, iFirst, iLast)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HGrid:Notify(lParam)
RETURN hwg_ListViewNotify(Self, lParam)

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_ListViewNotify(oCtrl, lParam)

   LOCAL aCord

   SWITCH hwg_GetNotifyCode(lParam)

   CASE LVN_KEYDOWN
      IF hb_IsBlock(oCtrl:bKeydown)
         Eval(oCtrl:bKeyDown, oCtrl, hwg_ListView_GetGridKey(lParam))
      ENDIF
      EXIT

   CASE NM_DBLCLK
      IF hb_IsBlock(oCtrl:bEnter)
         aCord := hwg_ListView_HitTest(oCtrl:handle, hwg_GetCursorRow() - hwg_GetWindowRow(oCtrl:handle), ;
                                   hwg_GetCursorCol() - hwg_GetWindowCol(oCtrl:handle))
         oCtrl:nRow := aCord[1]
         oCtrl:nCol := aCord[2]
         Eval(oCtrl:bEnter, oCtrl)
      ENDIF
      EXIT

   CASE NM_SETFOCUS
      IF hb_IsBlock(oCtrl:bGfocus)
         Eval(oCtrl:bGfocus, oCtrl)
      ENDIF
      EXIT

   CASE NM_KILLFOCUS
      IF hb_IsBlock(oCtrl:bLfocus)
         Eval(oCtrl:bLfocus, oCtrl)
      ENDIF
      EXIT

   CASE LVN_ITEMCHANGED
      oCtrl:nRow := oCtrl:Row()
      IF hb_IsBlock(oCtrl:bPosChg)
         Eval(oCtrl:bPosChg, oCtrl, hwg_Listview_GetFirstItem(oCtrl:handle))
      ENDIF
      EXIT

   CASE LVN_GETDISPINFO
      IF hb_IsBlock(oCtrl:bDispInfo)
         aCord := hwg_ListView_GetDispInfo(lParam)
         oCtrl:nRow := aCord[1]
         oCtrl:nCol := aCord[2]
         hwg_ListView_SetDispInfo(lParam, Eval(oCtrl:bDispInfo, oCtrl, oCtrl:nRow, oCtrl:nCol))
      ENDIF

   ENDSWITCH

RETURN 0

//-------------------------------------------------------------------------------------------------------------------//

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(LISTVIEWNOTIFY, HWG_LISTVIEWNOTIFY);
#endif

#pragma ENDDUMP
