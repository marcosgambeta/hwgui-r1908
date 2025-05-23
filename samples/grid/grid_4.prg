//
// HWGUI - Harbour Win32 GUI library source code:
// HGrid class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
// Copyright 2004 Rodrigo Moreno <rodrigo_moreno@yahoo.com>
//

#include "hwgui.ch"
#include <common.ch>

STATIC oMain
STATIC oForm
STATIC oFont
STATIC oGrid

FUNCTION Main()

   IF File("temp.dbf")
      FErase("temp.dbf")
   ENDIF

   DBCreate("temp.dbf", {{"LINE", "C", 300, 0}})

   USE temp

   INIT WINDOW oMain MAIN TITLE "File Viewer" ;
      AT 0, 0 ;
      SIZE hwg_GetDesktopWidth(), hwg_GetDesktopHeight() - 28

   MENU OF oMain
      MENUITEM "&Exit" ACTION oMain:Close()
      MENUITEM "&Open File" ACTION FileOpen()
   ENDMENU

   ACTIVATE WINDOW oMain
        
RETURN NIL

FUNCTION Test()

        PREPARE FONT oFont NAME "Courier New" WIDTH 0 HEIGHT -11
        
        INIT DIALOG oForm CLIPPER NOEXIT TITLE "File Viewer";
             FONT oFont ;
             AT 0, 0 SIZE 700, 425 ;
             STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

             @ 10, 10 GRID oGrid OF oForm SIZE 680, 375;
                     ITEMCOUNT Lastrec() ;
                     ON DISPINFO {|oCtrl, nRow, nCol|OnDispInfo(oCtrl, nRow, nCol)} ;
                     NOGRIDLINES

             ADD COLUMN TO GRID oGrid HEADER "" WIDTH  800
                                                              
             @ 620, 395 BUTTON "Close" SIZE 75, 25 ON CLICK {||oForm:Close()}
             
        ACTIVATE DIALOG oForm

RETURN NIL

FUNCTION OnDispInfo(o, x, y)

   LOCAL result := ""

    DBGoto(x)

    result := field->line

RETURN result

FUNCTION FileOpen()

   LOCAL fname

        fname := hwg_SelectFile("Select File", "*.*")

        Zap
        APPEND FROM (fname) SDF

RETURN Test()
