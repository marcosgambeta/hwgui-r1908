//
// HWGUI - Harbour Win32 GUI library source code:
// HQhtm class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"
#include "hwg_qhtm.ch"

CLASS HQhtm INHERIT HControl

   DATA winclass   INIT "QHTM_Window_Class_001"
   DATA cText INIT ""
   DATA filename INIT ""
   DATA resname INIT ""
   DATA bLink, bSubmit

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, caption, ;
                  bInit, bSize, bLink, bSubmit, fname, resname)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, caption, bInit, bSize, bLink, bSubmit, fname, resname)
   METHOD Init()
   METHOD Notify(lParam)

ENDCLASS


METHOD HQhtm:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, caption, ;
                  bInit, bSize, bLink, bSubmit, fname, resname)

   // ::classname := "HQHTM"
   ::oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id      := IIf(nId == NIL, ::NewId(), nId)
   ::style   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE)
   ::nLeft   := nLeft
   ::nTop    := nTop
   ::nWidth  := nWidth
   ::nHeight := nHeight
   ::bInit   := bInit
   ::bSize   := bSize
   ::bLink   := bLink
   ::bSubmit := bSubmit
   IF caption != NIL
      ::cText := caption
   ELSEIF fname != NIL
      ::filename := fname
   ELSEIF resname != NIL
      ::resname := resname
   ENDIF

   ::oParent:AddControl(Self)
   ::Activate()

RETURN Self

METHOD HQhtm:Activate()
   IF ::oParent:handle != 0
      ::handle := hwg_CreateQHTM(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ELSE
      QHTM_INIT()
   ENDIF
RETURN NIL

METHOD HQhtm:Redefine(oWndParent, nId, caption, bInit, bSize, bLink, bSubmit, fname, resname)
   // ::classname := "HQHTM"
   ::oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id      := nId
   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::bInit   := bInit
   ::bSize   := bSize
   ::bLink   := bLink
   ::bSubmit := bSubmit
   IF caption != NIL
      ::cText := caption
   ELSEIF fname != NIL
      ::filename := fname
   ELSEIF resname != NIL
      ::resname := resname
   ENDIF

   ::oParent:AddControl(Self)
   QHTM_INIT()

RETURN Self

METHOD HQhtm:Init()

   IF !::lInit
      ::Super:Init()
      IF !Empty(::cText)
         hwg_SetWindowText(::handle, ::cText)
      ELSEIF !Empty(::filename)
         QHTM_LoadFile(::handle, ::filename)
      ELSEIF !Empty(::resname)
         QHTM_LoadRes(::handle, ::resname)
      ENDIF
      QHTM_FormCallBack(::handle)
   ENDIF

RETURN NIL

METHOD HQhtm:Notify(lParam)
Local cLink := QHTM_GetNotify(lParam)

   IF ::bLink == NIL .OR. !Eval(::bLink, Self, cLink)
      IF "tp://" $ clink
         RETURN 0
      ELSE
         IF File(cLink)
            QHTM_LoadFile(::handle, cLink)
         ELSE
            hwg_MsgStop(cLink, "File not found")
         ENDIF
      ENDIF
   ENDIF
   QHTM_SetReturnValue(lParam, .F.)
RETURN 0

FUNCTION QhtmFormProc(hCtrl, cMethod, cAction, cName, aFields)
Local oCtrl := hwg_FindSelf(hCtrl)

   IF oCtrl != NIL
      IF oCtrl:bSubmit != NIL
         Eval(oCtrl:bSubmit, oCtrl, cMethod, cAction, cName, aFields)
      ENDIF
   ENDIF

RETURN 0

// CLASS hQHTMButton

CLASS HQhtmButton INHERIT HButton

   CLASS VAR winclass   INIT "BUTTON"
   DATA cHtml
   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bClick, ctooltip)
   METHOD Redefine(oWnd, nId, cCaption, oFont, bInit, bSize, bClick, ctooltip)
   METHOD Init()

ENDCLASS

METHOD HQhtmButton:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bClick, ctooltip)

   ::cHtml := cCaption
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, "", , ;
                  bInit, bSize, , bClick, ctooltip)
   // ::classname := "HQHTMBUTTON"

RETURN Self

METHOD HQhtmButton:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bClick, ctooltip)

   ::cHtml := cCaption
   ::Super:Redefine(oWndParent, nId, , bInit, bSize, , bClick, ctooltip)
   // ::classname := "HQHTMBUTTON"

RETURN Self

METHOD HQhtmButton:Init()

   ::Super:Init()
   IF ::oFont == NIL .AND. ::oParent:oFont == NIL
      hwg_SetCtrlFont(::oParent:handle, ::id, hwg_GetStockObject(SYSTEM_FONT))
   ENDIF
   hwg_SetWindowText(::handle, ::cHtml)
   QHTM_SetHtmlButton(::handle)

RETURN NIL

EXIT PROCEDURE FreeQHTM
   QHTM_End()
RETURN
