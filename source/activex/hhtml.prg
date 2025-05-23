//
// HWGUI - Harbour Win32 GUI library source code:
// HHtml class
//
// Copyright 2006 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

#define WEBPAGE_GOBACK      0
#define WEBPAGE_GOFORWARD   1
#define WEBPAGE_GOHOME      2
#define WEBPAGE_SEARCH      3
#define WEBPAGE_REFRESH      4
#define WEBPAGE_STOP      5

CLASS HHtml // INHERIT HControl

   DATA oParent
   DATA handle  INIT 0

   METHOD New(oParent)
   METHOD DisplayPage(cUrl) INLINE hwgax_DisplayHtmlPage(::oParent:handle, cUrl)
   METHOD DisplayText(cText) INLINE hwgax_DisplayHtmlStr(::oParent:handle, cText)
   METHOD Activate()
   METHOD Resize(width, height)
   METHOD GoBack() INLINE hwgax_DoPageAction(::oParent:handle, WEBPAGE_GOBACK)
   METHOD GoForward() INLINE hwgax_DoPageAction(::oParent:handle, WEBPAGE_GOFORWARD)
   METHOD GoHome() INLINE hwgax_DoPageAction(::oParent:handle, WEBPAGE_GOHOME)
   METHOD Search() INLINE hwgax_DoPageAction(::oParent:handle, WEBPAGE_SEARCH)
   METHOD Refresh() INLINE hwgax_DoPageAction(::oParent:handle, WEBPAGE_REFRESH)
   METHOD Stop() INLINE hwgax_DoPageAction(::oParent:handle, WEBPAGE_STOP)
   METHOD End()
ENDCLASS

METHOD HHtml:New(oParent)

   IF !hwgax_OleInitialize()
      hwg_MsgStop("Can't open OLE!", "HHtml():New()")
      RETURN NIL
   ENDIF

   ::oParent := oParent

   ::Activate()

RETURN Self

METHOD HHtml:Activate()

   IF !Empty(::oParent:handle)
     ::oParent:oEmbedded := Self
      IF !hwgax_EmbedBrowserObject(::oParent:handle)
         hwg_MsgStop("Can't embed IE object!", "HHtml():New()")
      ENDIF
   ENDIF
RETURN NIL

METHOD HHtml:Resize(width, height)

   // hwg_WriteLog(Str(width) + " " + Str(height) + " / " + Str(::oParent:nwidth) + " " + Str(::oParent:nheight))
   hwgax_ResizeBrowser(::oParent:handle, width, height)
RETURN NIL

METHOD HHtml:End()

   hwgax_UnEmbedBrowserObject(::oParent:handle)
RETURN NIL

EXIT PROCEDURE EXITOLE
   hwgax_OleUninitialize()
RETURN
