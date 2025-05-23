//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HTab class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

#ifndef TCM_SETCURSEL
#define TCM_SETCURSEL           4876     // (TCM_FIRST + 12)
#define TCM_SETCURFOCUS         4912     // (TCM_FIRST + 48)
#define TCM_GETCURFOCUS         4911     // (TCM_FIRST + 47)
#define TCM_GETITEMCOUNT        4868     // (TCM_FIRST + 4)
#define TCM_SETIMAGELIST        4867
#endif

CLASS HTab INHERIT HControl

   CLASS VAR winclass INIT "SysTabControl32"
   DATA aTabs
   DATA aPages INIT {}
   DATA bChange, bChange2
   DATA oTemp
   DATA bAction

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  oFont, bInit, bSize, bPaint, aTabs, bChange, aImages, lResour, nBC, ;
                  bClick, bGetFocus, bLostFocus)
   METHOD Activate()
   METHOD Init()
   METHOD SetTab(n)
   METHOD StartPage(cname)
   METHOD EndPage()
   METHOD ChangePage(nPage)
   METHOD HidePage(nPage)
   METHOD ShowPage(nPage)
   METHOD GetActivePage(nFirst, nEnd)

   HIDDEN:
     DATA nActive INIT 0         // Active Page

ENDCLASS

METHOD HTab:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  oFont, bInit, bSize, bPaint, aTabs, bChange, aImages, lResour, nBC, bClick, bGetFocus, bLostFocus)

   //LOCAL i // variable not used
   //LOCAL aBmpSize // variable not used

   HB_SYMBOL_UNUSED(aImages)
   HB_SYMBOL_UNUSED(lResour)
   HB_SYMBOL_UNUSED(nBC)

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint)

   ::title   := ""
   ::oFont   := IIf(oFont == NIL, ::oParent:oFont, oFont)
   ::aTabs   := IIf(aTabs == NIL, {}, aTabs)
   ::bChange := bChange

   ::bChange2 := bChange

   ::bGetFocus := IIf(bGetFocus == NIL, NIL, bGetFocus)
   ::bLostFocus := IIf(bLostFocus == NIL, NIL, bLostFocus)
   ::bAction   := IIf(bClick == NIL, NIL, bClick)

   ::Activate()

RETURN Self

METHOD HTab:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateTabControl(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)

      ::Init()
   ENDIF
RETURN NIL

METHOD HTab:Init()

   LOCAL i
   LOCAL h

   IF !::lInit
      ::Super:Init()
      FOR i := 1 TO Len(::aTabs)
         h := hwg_AddTab(::handle, ::aTabs[i])
	 AAdd(::aPages, {0, 0, .F., h})
      NEXT
      
      hwg_SetWindowObject(::handle, Self)

      FOR i := 2 TO Len(::aPages)
         ::HidePage(i)
      NEXT
   ENDIF

RETURN NIL

METHOD HTab:SetTab(n)
   hwg_SendMessage(::handle, TCM_SETCURFOCUS, n - 1, 0)
RETURN NIL

METHOD HTab:StartPage(cname)

   LOCAL i := IIf(cName == NIL, Len(::aPages) + 1, AScan(::aTabs, cname))
   LOCAL lNew := (i == 0)

   ::oTemp := ::oDefaultParent
   ::oDefaultParent := Self
   IF lNew
      AAdd(::aTabs, cname)
      i := Len(::aTabs)
   ENDIF
   DO WHILE Len(::aPages) < i
      AAdd(::aPages, {Len(::aControls), 0, lNew, 0})
   ENDDO
   ::nActive := i
   ::aPages[i, 4] := hwg_AddTab(::handle, ::aTabs[i])

RETURN NIL

METHOD HTab:EndPage()

   ::aPages[::nActive, 2] := Len(::aControls) - ::aPages[::nActive, 1]
   IF ::nActive > 1 .AND. ::handle != NIL .AND. !Empty(::handle)
      ::HidePage(::nActive)
   ENDIF
   ::nActive := 1

   ::oDefaultParent := ::oTemp
   ::oTemp := NIL

   ::bChange = {|o, n|o:ChangePage(n)}

RETURN NIL

METHOD HTab:ChangePage(nPage)

   IF !Empty(::aPages)

      ::HidePage(::nActive)

      ::nActive := nPage

      ::ShowPage(::nActive)

   ENDIF

   IF ::bChange2 != NIL
      Eval(::bChange2, Self, nPage)
   ENDIF

RETURN NIL

METHOD HTab:HidePage(nPage)

   LOCAL i
   LOCAL nFirst
   LOCAL nEnd

   nFirst := ::aPages[nPage, 1] + 1
   nEnd   := ::aPages[nPage, 1] + ::aPages[nPage, 2]
   FOR i := nFirst TO nEnd
      ::aControls[i]:Hide()
   NEXT

RETURN NIL

METHOD HTab:ShowPage(nPage)

   LOCAL i
   LOCAL nFirst
   LOCAL nEnd

   nFirst := ::aPages[nPage, 1] + 1
   nEnd   := ::aPages[nPage, 1] + ::aPages[nPage, 2]
   FOR i := nFirst TO nEnd
      ::aControls[i]:Show()
   NEXT
   FOR i := nFirst TO nEnd
      IF __ObjHasMsg(::aControls[i], "BSETGET") .AND. ::aControls[i]:bSetGet != NIL
         hwg_SetFocus(::aControls[i]:handle)
         Exit
      ENDIF
   NEXT

RETURN NIL

METHOD HTab:GetActivePage(nFirst, nEnd)

   IF !Empty(::aPages)
      nFirst := ::aPages[::nActive, 1] + 1
      nEnd   := ::aPages[::nActive, 1] + ::aPages[::nActive, 2]
   ELSE
      nFirst := 1
      nEnd   := Len(::aControls)
   ENDIF

RETURN ::nActive

