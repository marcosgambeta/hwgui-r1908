#include "hwgui.ch"

FUNCTION Main()

   PRIVATE oRadiogroup1
   PRIVATE oL
   PRIVATE oRadiobutton1
   PRIVATE oRadiobutton2
   PRIVATE oPage
   PRIVATE oLabel1
   PRIVATE oLabel4
   PRIVATE oLabel3
   PRIVATE oLabel2

   cUser := "1"

   INIT DIALOG oDlg TITLE "Form1" ;
        AT 422, 66 SIZE 500, 400 ;
        ON INIT {||onDlgInit()}

  RADIOGROUP
   @ 50, 50 RADIOBUTTON oRadiobutton1 CAPTION "User 1      " OF oRadiogroup1 SIZE 110, 22   ;
        ON CLICK {||oRadiobutton1_onClick()}
   @ 159, 51 RADIOBUTTON oRadiobutton2 CAPTION "User 2      " OF oRadiogroup1 SIZE 110, 22   ;
        ON CLICK {||oRadiobutton2_onClick()}
  END RADIOGROUP SELECTED 1

   @ 315, 43 SAY oL      CAPTION "Label" SIZE 147, 22
   @ 27, 113 TAB oPage  ITEMS {} SIZE 455, 238   ;
        ON INIT {|oCtrl|oCtrl:bChange := {|o, nPage|Protek(o, nPage)}}
  BEGIN PAGE "Tab1" OF oPage
   @ 40, 62 SAY oLabel1 CAPTION "Here Page 1" OF oPage SIZE 225, 22
  END PAGE OF oPage

  BEGIN PAGE "Tab2" OF oPage
   @ 75, 105 SAY oLabel2 CAPTION "Here Page 2 " OF oPage SIZE 225, 22
  END PAGE OF oPage

  BEGIN PAGE "Tab3" OF oPage
   @ 59, 69 SAY oLabel3 CAPTION "Here Page 3 " OF oPage SIZE 225, 22
  END PAGE OF oPage

  BEGIN PAGE "Info" OF oPage
   @ 88, 64 SAY oLabel4 CAPTION "Demo Proteksi, User 1 only 1, 3, User 2 only 2, 3  " OF oPage SIZE 186, 73
  END PAGE OF oPage

   ACTIVATE DIALOG oDlg

RETURN NIL

STATIC FUNCTION protek()

   PARAMETERS o
   PARAMETERS n

   PRIVATE lOpen := .T.

 IF cUser == "1" .AND. n == 2
    lOpen := .F.
 ENDIF

 IF cUser == "2" .AND. n == 1
    lOpen := .F.
 ENDIF

 IF lOpen
 oPage:settab(n)
 oPage:ChangePage(n)
 ELSE
   hwg_MsgInfo("Sorry " + cUser + " You cannot access" + Str(n, 3))
 oPage:settab(4)
 oPage:ChangePage(4)
 ENDIF

RETURN NIL

STATIC FUNCTION onDlgInit()

oPage:settab(4)
oPage:ShowPage(4)

RETURN NIL

STATIC FUNCTION oRadiobutton1_onClick()

cUser := "1"
oL:settext("only 1,3")

RETURN NIL

STATIC FUNCTION oRadiobutton2_onClick()

cUser := "2"
oL:settext("only 2,3")

RETURN NIL
