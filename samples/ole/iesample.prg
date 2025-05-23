//
// HWGUI - Harbour Win32 and Linux (GTK) GUI library
// iesample.prg - sample of ActiveX container for the IE browser object
//
// Copyright 2006 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWnd
   LOCAL oPanelTool
   LOCAL oPanelIE
   LOCAL oFont
   LOCAL oEdit
   LOCAL cUrl
   LOCAL oIE

   PREPARE FONT oFont NAME "Times New Roman" WIDTH 0 HEIGHT -15
   INIT WINDOW oMainWnd TITLE "Example" AT 200, 0 SIZE 500, 400 FONT oFont

   MENU OF oMainWnd
      MENU TITLE "File"
         MENUITEM "&Open file" ACTION OpenFile(oIE, oEdit)
         SEPARATOR
         MENUITEM "E&xit" ACTION oMainWnd:Close()
      ENDMENU
   ENDMENU

    @ 0, 0 PANEL oPanelTool SIZE 500, 32

    @ 5, 4 EDITBOX oEdit CAPTION "http://kresin.belgorod.su" OF oPanelTool SIZE 400, 24
    @ 405, 4 BUTTON "Go!" OF oPanelTool SIZE 30, 24 ;
        ON CLICK {||IIf(!Empty(cUrl := hwg_GetEditText(oEdit:oParent:handle, oEdit:id)), oIE:DisplayPage(cUrl), .T.)}
    @ 435, 4 BUTTON "Search" OF oPanelTool SIZE 55, 24 ;
        ON CLICK {||IIf(!Empty(cUrl := hwg_GetEditText(oEdit:oParent:handle, oEdit:id)), FindInGoogle(cUrl, oIE, oEdit), .T.)}

    @ 0, 34 PANEL oPanelIE SIZE 500, 366 ON SIZE {|o, x, y|o:Move(, , x, y - 34)}

    oIE := HHtml():New(oPanelIE)

    ACTIVATE WINDOW oMainWnd

RETURN NIL

STATIC FUNCTION OpenFile(oIE, oEdit)

   LOCAL mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
   LOCAL fname := hwg_SelectFile("HTML files", "*.htm;*.html", mypath)

   IF !Empty(fname)
      oEdit:SetText(fname)
      oIE:DisplayPage(fname)
   ENDIF

RETURN NIL

STATIC FUNCTION FindInGoogle(cQuery, oIE, oEdit)

   LOCAL cUrl := "http://www.google.com/search?q="
   LOCAL cItem

   IF !Empty(cItem := hwg_NextItem(cQuery, .T., " "))
      cUrl += cItem
      DO WHILE !Empty(cItem := hwg_NextItem(cQuery, , " "))
         cUrl += "+" + cItem
      ENDDO
      oEdit:SetText(cUrl)
      oIE:DisplayPage(cUrl)
   ENDIF

RETURN NIL
