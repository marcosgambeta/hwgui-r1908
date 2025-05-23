//
// HWGUI - Harbour Win32 GUI library source code:
// TVideo component
//
// Copyright 2003 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//----------------------------------------------------------------------------//

CLASS TVideo FROM hControl


   DATA oMci
   DATA cAviFile

   METHOD New(nRow, nCol, nWidth, nHeight, cFileName, oWnd, ;
               bWhen, bValid, lNoBorder, nid) CONSTRUCTOR

   METHOD ReDefine(nId, cFileName, oDlg, bWhen, bValid) CONSTRUCTOR

   METHOD Initiate()

   METHOD Play(nFrom, nTo) INLINE  ::oMci:Play(nFrom, nTo, ::oparent:handle)

ENDCLASS

//----------------------------------------------------------------------------//

METHOD TVideo:New(nRow, nCol, nWidth, nHeight, cFileName, oWnd, lNoBorder, nid)

   DEFAULT nWidth TO 200, nHeight TO 200, cFileName TO "", ;
   lNoBorder TO .F.

   ::nTop      := nRow *  VID_CHARPIX_H  // 8
   ::nLeft     := nCol * VID_CHARPIX_W   // 14
   ::nHeight   := ::nTop  + nHeight - 1
   ::nWidth    := ::nLeft + nWidth + 1
   ::Style     := hwg_bitOR(WS_CHILD + WS_VISIBLE + WS_TABSTOP, IIf(!lNoBorder, WS_BORDER, 0))

   ::oParent   := IIf(oWnd == NIL, ::oDefaultParent, oWnd)
   ::id        := IIf(nid == NIL, ::NewId(), nid)
   ::cAviFile  := cFileName
   ::oMci      := TMci():New("avivideo", cFileName)
   ::Initiate()

   IF !Empty(::oparent:handle)
      ::oMci:lOpen()
      ::oMci:SetWindow(Self)
   ELSE
      ::oparent:AddControl(Self)
   ENDIF

   RETURN Self

//----------------------------------------------------------------------------//

METHOD TVideo:ReDefine(nId, cFileName, oDlg, bWhen, bValid)

   ::nId      := nId
   ::cAviFile := cFileName
   ::bWhen    := bWhen
   ::bValid   := bValid
   ::oWnd     := oDlg
   ::oMci     := TMci():New("avivideo", cFileName)

   oDlg:AddControl(Self)

   RETURN Self

//----------------------------------------------------------------------------//

METHOD TVideo:Initiate()

   ::Super:Init()
   ::oMci:lOpen()
   ::oMci:SetWindow(Self)

   RETURN NIL

//----------------------------------------------------------------------------//
