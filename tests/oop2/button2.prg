#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog

   WITH OBJECT oDialog := MyDialog():new()
      :title   := "My dialog window"
      :nWidth  := 640
      :nHeight := 480
      :myMethod()
      :activate()
   ENDWITH

RETURN NIL

#include <hbclass.ch>

CLASS MyDialog FROM HDialog

   DATA oButtonOK
   DATA oButtonCancel

   METHOD myMethod

ENDCLASS

METHOD myMethod() CLASS MyDialog

   WITH OBJECT ::oButtonOK := HButton():new()
      :title  := "&OK"
      :nLeft  := 20
      :nTop   := 20
      :bClick := {||hwg_MsgInfo("OK clicked", "Information")}
   ENDWITH

   WITH OBJECT ::oButtonCancel := HButton():new()
      :title  := "&Cancel"
      :nLeft  := 120
      :nTop   := 20
      :bClick := {||hwg_MsgInfo("Cancel clicked", "Information")}
   ENDWITH

RETURN NIL
