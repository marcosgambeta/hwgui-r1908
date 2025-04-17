//
// $Id: rmsample.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 and Linux (GTK) GUI library
// rmsample.prg - sample of ActiveX container for the RMCHART ocx
//
// RMChart can be downloaded from http://www.rmchart.com/
//
// Copyright 2006 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//
// Sample code derived from a sample code found on Internet.... oohg ?
//

#include "hwgui.ch"
#include "rmchart.ch"
#include <hbclass.ch>


/* Class RmChart has been defined in order to intercept in a possible OOP way
   events generated by the RMChart object (mouse clicks and the likes)
*/

CLASS RmChart FROM HActiveX
CLASS VAR winclass INIT "RmChart"
  METHOD Clicked        // Intercept the Click event
  METHOD New()
ENDCLASS

METHOD New(p1, p2, p3, p4, p5, p6) CLASS RmChart

  ::EventMap(1, "CLICKED", SELF)
                                      // Map event 1 to Clicked method
                                      // ...7... I don't remember why I put 7
                                      // should be the number of parameters to
                                      // pass to the function
                                      // Mapping must be done before calling New
  ::Super:New(p1, p2, p3, p4, p5, p6)        //

RETURN NIL

METHOD Clicked(...) CLASS RmChart

hwg_MsgInfo("Mouse button pressed", ::winclass)

RETURN NIL

FUNCTION Main()

   LOCAL oMainWnd
   LOCAL oPanelTool
   LOCAL oPanelIE
   LOCAL oFont
   LOCAL cUrl
   LOCAL oIE

   PRIVATE oEdit
   PRIVATE oChart

   PREPARE FONT oFont NAME "Times New Roman" WIDTH 0 HEIGHT -15
   INIT WINDOW oMainWnd TITLE "rmchart example" AT 200, 0 SIZE 500, 400 FONT oFont

   MENU OF oMainWnd
      MENU TITLE "File"
         MENUITEM "E&xit" ACTION oMainWnd:Close()
      ENDMENU
   ENDMENU

    @ 0, 0 PANEL oPanelTool SIZE 500, 32

    @ 5, 4 BUTTON "Show" OF oPanelTool SIZE 50, 24 ;
        ON CLICK {||oChart:Show()}

    @ 55, 4 BUTTON "Hide" OF oPanelTool SIZE 50, 24 ;
        ON CLICK {||oChart:Hide()}

    @ 105, 4 BUTTON "Enable" OF oPanelTool SIZE 50, 24 ;
        ON CLICK {||oChart:Enable()}

    @ 155, 4 BUTTON "Disable" OF oPanelTool SIZE 50, 24 ;
        ON CLICK {||oChart:Disable()}

    @ 205, 4 BUTTON "Redraw" OF oPanelTool SIZE 50, 24 ;
        ON CLICK {||oChart:Draw(.T.)}

    @ 0, 34 PANEL oPanel SIZE 500, 366 ON SIZE {|o, x, y|o:Move(, , x, y), oChart:Move(, , x, y - 32), oChart:Refresh()}

    oChart := RmChart():New(oPanel, "RMChart.RMChartX", 0, 0, oPanel:nHeight, oPanel:nWidth)

    oChart:Clear()
    oChart:Reset()
    oChart:Font := "Tahoma"
    oChart:RMCStyle := RMC_CTRLSTYLEFLAT
    oChart:RMCUserWatermark := "Test Test Test"
    oChart:AddRegion()
    r1 := oChart:Region(1)
    r1:Footer = "hwgui does ocx too!"
    r1:AddCaption()
    WITH OBJECT r1 			// oChart:Region(1)
         WITH OBJECT :Caption()
              :Titel := "rmchart test"
              :FontSize := 10
              :Bold := .T.
         END
         :AddGridlessSeries()
         WITH OBJECT :GridLessSeries
               :SeriesStyle := RMC_PIE_GRADIENT
               :Alignment := RMC_FULL
               :Explodemode := RMC_EXPLODE_NONE
               :Lucent := .F.
               :ValueLabelOn := RMC_VLABEL_ABSOLUTE
               :HatchMode := RMC_HATCHBRUSH_OFF
               :StartAngle := 0
               :DataString := "30*15*40*35"
         END
   END
   oChart:Draw2Clipboard(RMC_EMF)  // Copy in clipboard
   ris = oChart:Draw(.T.)
   oChart:Enable()
   oChart:Show()

   ACTIVATE WINDOW oMainWnd

RETURN NIL
