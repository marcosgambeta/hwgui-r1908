//
// HWGUI - Harbour Win32 GUI library source code:
// HTimer class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

#define TIMER_FIRST_ID 33900

CLASS HTimer INHERIT HObject

CLASS VAR aTimers   INIT {}

   DATA lInit   INIT .F.
   DATA id
   DATA value
   DATA oParent
   DATA bAction

   DATA xName          HIDDEN
   ACCESS Name INLINE ::xName
   ASSIGN Name(cName) INLINE IIf(!Empty(cName) .AND. hb_IsChar(cName) .AND. !(":" $ cName) .AND. !("[" $ cName), ;
         (::xName := cName, __objAddData(::oParent, cName), ::oParent: &(cName) := Self), NIL)
   ACCESS Interval INLINE ::value
   ASSIGN Interval(x) INLINE ::value := x, ;
                                           hwg_SetTimer(::oParent:handle, ::id, ::value)

   METHOD New(oParent, nId, value, bAction)
   METHOD Init()
   METHOD onAction()
   METHOD End()

ENDCLASS


METHOD HTimer:New(oParent, nId, value, bAction)

   ::oParent := IIf(oParent == NIL, HWindow():GetMain():oDefaultParent, oParent)
   IF nId == NIL
      nId := TIMER_FIRST_ID
      DO WHILE AScan(::aTimers, {|o|o:id == nId}) !=  0
         nId++
      ENDDO
   ENDIF
   ::id      := nId
   ::value   := IIf(hb_IsNumeric(value), value, 0)
   ::bAction := bAction
   /*
    IF ::value > 0
      hwg_SetTimer(oParent:handle, ::id, ::value)
   ENDIF
   */
   ::Init()
   AAdd(::aTimers, Self)
   ::oParent:AddObject(Self)

   RETURN Self

METHOD HTimer:Init()
   IF !::lInit
      IF ::value > 0
         hwg_SetTimer(::oParent:handle, ::id, ::value)
      ENDIF
   ENDIF
   RETURN  NIL

METHOD HTimer:End()
   LOCAL i

   IF ::oParent != NIL
      hwg_KillTimer(::oParent:handle, ::id)
   ENDIF
   IF (i := AScan(::aTimers, {|o|o:id == ::id})) > 0
      ADel(::aTimers, i)
      ASize(::aTimers, Len(::aTimers) - 1)
   ENDIF

   RETURN NIL

METHOD HTimer:onAction()

   hwg_TimerProc(, ::id, ::interval)

RETURN NIL


FUNCTION hwg_TimerProc(hWnd, idTimer, Time)
   LOCAL i := AScan(HTimer():aTimers, {|o|o:id == idTimer})

   HB_SYMBOL_UNUSED(hWnd)

   IF i != 0 .AND. HTimer():aTimers[i]:value > 0 .AND. HTimer():aTimers[i]:bAction != NIL .AND.;
      hb_IsBlock(HTimer():aTimers[i]:bAction)
      Eval(HTimer():aTimers[i]:bAction, HTimer():aTimers[i], time)
   ENDIF

   RETURN NIL



   EXIT PROCEDURE hwg_CleanTimers
   LOCAL oTimer, i

   FOR i := 1 TO Len(HTimer():aTimers)
      oTimer := HTimer():aTimers[i]
      hwg_KillTimer(oTimer:oParent:handle, oTimer:id)
   NEXT

   RETURN

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(TIMERPROC, HWG_TIMERPROC);
#endif

#pragma ENDDUMP
