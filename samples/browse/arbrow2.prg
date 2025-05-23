//
// Demo hbrowse
//

#include "hwgui.ch"

#define x_BLUE       16711680
#define x_RED             255

***********************
FUNCTION Main()
***********************

   LOCAL oWinMain
   LOCAL i
   LOCAL a
   LOCAL b

   INIT WINDOW oWinMain MAIN  ;
      TITLE "Test scroll in HBrowse" AT 0, 0 SIZE 600, 400;
      FONT HFont():Add("Verdana", 0, -13, 400) ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER
    
    @  10, 20 BROWSE oBrw1 ARRAY SIZE 180, 325 ON SIZE {|o, x, y|o:Move(, , , y - 70)} MULTISELECT
    @ 200, 20 BROWSE oBrw2 ARRAY SIZE 180, 325 

    oBrw1:oHeadFont := HFont():Add("Times New Roman", 0, -22, 400)
    a := {} 
    FOR i := 1 TO 16
        AAdd(a, {i, Chr(Asc("a") - 1 + i)})
    NEXT
    FOR i := 1 TO 16
        AAdd(a, {i, Chr(Asc("A") - 1 + i)})
    NEXT
    FOR i := 1 TO 16
        AAdd(a, {i, Chr(Asc("a") - 1 + i)})
    NEXT

    oBrw1:aArray := a
    hwg_CreateArList(oBrw1, a)
    oBrw1:aColumns[1]:length := 5
    oBrw1:aColumns[2]:length := 5
    oBrw1:aColumns[1]:width := 50
    oBrw1:aColumns[2]:width := 50

    b := {} 
    FOR i := 1 TO 5
        AAdd(b, {i, Chr(Asc("a") - 1 + i)})
    NEXT

    oBrw2:aArray := b
    hwg_CreateArList(oBrw2, b)
    oBrw2:lAdjRight := .F.
    oBrw2:aColumns[1]:length := 5
    oBrw2:aColumns[2]:length := 5
    oBrw2:aColumns[1]:width := 50
    oBrw2:aColumns[2]:width := 50



    oBrw1:aColumns[1]:bColorFoot := {||{x_BLUE, x_RED}}
    oBrw1:aColumns[1]:bHeadClick := {||hwg_MsgInfo("HeadClick")}
    oBrw1:aColumns[1]:heading := "Header 1;second line"
    oBrw1:aColumns[2]:heading := "Header 2"
    oBrw1:aColumns[1]:footing := "Footer 1;F1L2"
    oBrw1:aColumns[2]:footing := "Footer 2"
    oBrw1:SetMargin(2)

    //oBrw2:SetRowHeight(100)

    // @ 400, 160 UPDOWN 10 RANGE 0, 50 SIZE 50, 32 STYLE WS_BORDER
    @ 400, 160 BUTTONEX oButton1 CAPTION "Font" SIZE 50, 32 ON CLICK {||oBrw1:oHeadFont := HFont():Add("Times New Roman", 0, -12, 400), oBrw1:Refresh()}

    @ 400, 200 BUTTONEX oButton1 CAPTION "100" SIZE 50, 32 ON CLICK {||oBrw1:SetRowHeight(100)}
    @ 400, 240 BUTTONEX oButton1 CAPTION "70" SIZE 50, 32 ON CLICK {||oBrw1:SetRowHeight(70)}
    @ 400, 280 BUTTONEX oButton1 CAPTION "50" SIZE 50, 32 ON CLICK {||oBrw1:SetRowHeight(50)}

    oWinMain:Activate()

RETURN NIL
