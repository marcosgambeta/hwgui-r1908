//
// $Id: testini.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HwGUI Samples
// testini.prg - Test to use files ini
//

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL cIniFile := "HwGui.ini"

   //Create the inifile
   if !file(cIniFile)

      Hwg_WriteIni("Config", "WallParer", "No Paper", cIniFile)
      Hwg_WriteIni("Config", "DirHwGUima", "C:\HwGUI", cIniFile)
      Hwg_WriteIni("Print", "Spoll", "Epson LX 80", cIniFile)

    endif

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 200, 0 SIZE 400, 150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION EndWindow()
      MENUITEM "&Read Ini" ACTION ReadIni()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION ReadIni()

   LOCAL cIniFile := "HwGui.ini"

   hwg_MsgInfo(Hwg_GetIni("Config", "WallParer", , cIniFile))
   hwg_MsgInfo(Hwg_GetIni("Config", "DirHwGUima", , cIniFile))
   hwg_MsgInfo(Hwg_GetIni("Print", "Spoll", , cIniFile))

RETURN NIL
