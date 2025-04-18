//
// $Id: htool.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include "hwgui.ch"

//#define TRANSPARENT 1 // defined in windows.ch

CLASS HToolBar INHERIT HControl

   DATA winclass INIT "ToolbarWindow32"
   Data TEXT, id, nTop, nLeft, nwidth, nheight
   CLASSDATA oSelected INIT NIL
   DATA State INIT 0
   Data ExStyle
   Data bClick, cTooltip

   DATA lPress INIT .F.
   DATA lFlat
   DATA nOrder
   Data aItem init {}
   DATA Line

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
                  bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aItem)

   METHOD Activate()
   METHOD INIT()
   METHOD REFRESH()
   //METHOD AddButton(a, s, d, f, g, h)
   METHOD AddButton(nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu)
   METHOD onEvent(msg, wParam, lParam)
   METHOD EnableAllButtons()
   METHOD DisableAllButtons()
   METHOD EnableButtons(n)
   METHOD DisableButtons(n)



ENDCLASS


METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
                  bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aitem) CLASS hToolBar

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   Default  aItem to {}
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctooltip, tcolor, bcolor)

   ::aitem := aItem

   ::Activate()

RETURN Self

METHOD Activate() CLASS hToolBar
   IF !Empty(::oParent:handle)

      ::handle := hwg_CreateToolBar(::oParent:handle)
      hwg_SetWindowObject(::handle, Self)
      ::Init()
   ENDIF
RETURN NIL

METHOD INIT() CLASS hToolBar

   LOCAL n
   //LOCAL n1 // variable not used
   //LOCAL aTemp // variable not used
   //LOCAL hIm // variable not used
   LOCAL aButton := {}
   //LOCAL aBmpSize // variable not used
   LOCAL oImage
   //LOCAL nPos // variable not used
   LOCAL aItem

   IF !::lInit
      ::Super:Init()
      For n := 1 TO len(::aItem)

//         IF HB_IsBlock(::aItem[n, 7])
//
//            ::oParent:AddEvent(BN_CLICKED, ::aItem[n, 2], ::aItem[n, 7])
//
//         ENDIF

//         IF HB_IsArray(::aItem[n, 9])
//
//            ::aItem[n, 10] := hwg__CreatePopupMenu()
//            aTemp := ::aItem[n, 9]
//
//            FOR n1 :=1 to Len(aTemp)
//               hwg__AddMenuItem(::aItem[n, 10], aTemp[n1, 1], -1, .F., aTemp[n1, 2], , .F.)
//               ::oParent:AddEvent(BN_CLICKED, aTemp[n1, 2], aTemp[n1, 3])
//            NEXT
//
//         ENDIF
         if HB_IsNumeric(::aItem[n, 1])
            IF !Empty(::aItem[n, 1])
               AAdd(aButton, ::aItem[n, 1])
            ENDIF
         elseif  HB_IsChar(::aItem[n, 1])
            if ".ico" $ lower(::aItem[n, 1]) //if ".ico" in lower(::aItem[n, 1])
               oImage := hIcon():AddFile(::aItem[n, 1])
            else
               oImage := hBitmap():AddFile(::aItem[n, 1])
            endif
            if HB_IsObject(oImage)
               AAdd(aButton, Oimage:handle)
               ::aItem[n, 1] := Oimage:handle
            endif
         ENDIF

      NEXT n

/*      IF Len(aButton) > 0

          aBmpSize := hwg_GetBitmapSize(aButton[1])

          IF aBmpSize[3] == 4
             hIm := hwg_CreateImageList({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR4 + ILC_MASK)
          ELSEIF aBmpSize[3] == 8
             hIm := hwg_CreateImageList({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR8 + ILC_MASK)
          ELSEIF aBmpSize[3] == 24
             hIm := hwg_CreateImageList({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
          ENDIF

          FOR nPos :=1 to Len(aButton)

             aBmpSize := hwg_GetBitmapSize(aButton[nPos])

             IF aBmpSize[3] == 24
//             hwg_Imagelist_AddMasked(hIm, aButton[nPos], hwg_RGB(236, 223, 216))
                hwg_Imagelist_Add(hIm, aButton[nPos])
             ELSE
                hwg_Imagelist_Add(hIm, aButton[nPos])
             ENDIF

          NEXT

       hwg_SendMessage(::Handle, TB_SETIMAGELIST, 0, hIm)

      ENDIF
*/
      if Len(::aItem) > 0
         For Each aItem in ::aItem

            if aItem[4] == TBSTYLE_BUTTON

               aItem[11] := hwg_CreateToolBarButton(::handle, aItem[1], aItem[6], .F.)
               aItem[2] := hb_enumindex()
//               hwg_SetSignal(aItem[11], "clicked", WM_LBUTTONUP, aItem[2], 0)
               hwg_TOOLBAR_SETACTION(aItem[11], aItem[7])
               if !Empty(aItem[8])
                  hwg_AddtoolTip(::handle, aItem[11], aItem[8])
               endif
            elseif aitem[4] == TBSTYLE_SEP
               aItem[11] := hwg_CreateToolBarButton(::handle,,, .T.)
               aItem[2] := hb_enumindex()
            endif
         next
      endif

   ENDIF
RETURN NIL
/*
METHOD Notify(lParam) CLASS hToolBar

    Local nCode :=  hwg_GetNotifyCode(lParam)
    Local nId

    Local nButton
    Local nPos

    IF nCode == TTN_GETDISPINFO

       nButton := hwg_ToolBar_GetDispInfoId(lParam)
       nPos := AScan(::aItem, {|x|x[2] == nButton})
       hwg_ToolBar_SetDispInfo(lParam, ::aItem[nPos, 8])

    ELSEIF nCode == TBN_GETINFOTIP

       nId := hwg_ToolBar_GetInfoTipId(lParam)
       nPos := AScan(::aItem, {|x|x[2] == nId})
       hwg_ToolBar_GetInfoTip(lParam, ::aItem[nPos, 8])

    ELSEIF nCode == TBN_DROPDOWN
       if HB_IsArray(::aItem[1, 9])
       nid := hwg_ToolBar_SubMenuExGetId(lParam)
       nPos := AScan(::aItem, {|x|x[2] == nId})
       hwg_ToolBar_SubMenuEx(lParam, ::aItem[nPos, 10], ::oParent:handle)
       else
              hwg_ToolBar_SubMenu(lParam, 1, ::oParent:handle)
       endif
    ENDIF

RETURN 0
*/
METHOD AddButton(nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu) CLASS hToolBar
   Local hMenu := NIL
   DEFAULT nBitIp to -1
   DEFAULT bstate to TBSTATE_ENABLED
   DEFAULT bstyle to 0x0000
   DEFAULT c to ""
   DEFAULT ctext to ""
   AAdd(::aItem, {nBitIp, nId, bState, bStyle, 0, cText, bClick, c, aMenu, hMenu, 0})
RETURN Self

METHOD onEvent(msg, wParam, lParam) CLASS HToolbar

   LOCAL nPos
   
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_LBUTTONUP
      nPos := AScan(::aItem, {|x|x[2] == wParam})
      if nPos > 0
         IF ::aItem[nPos, 7] != NIL
            Eval(::aItem[nPos, 7], Self)
         ENDIF
      endif
   ENDIF
RETURN  NIL

METHOD REFRESH() class htoolbar
   if ::lInit
      ::lInit := .F.
   endif
   ::init()
RETURN NIL

METHOD EnableAllButtons() class htoolbar
   Local xItem
   For Each xItem in ::aItem
      hwg_EnableWindow(xItem[11], .T.)
   Next
RETURN Self

METHOD DisableAllButtons() class htoolbar
   Local xItem
   For Each xItem in ::aItem
      hwg_EnableWindow(xItem[11], .F.)
   Next
RETURN Self

METHOD EnableButtons(n) class htoolbar
   hwg_EnableWindow(::aItem[n, 11 ], .T.)
RETURN Self

METHOD DisableButtons(n) class htoolbar
   hwg_EnableWindow(::aItem[n, 11 ], .T.)
RETURN Self
