//
// $Id: htimer.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HTimer class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

#define TIMER_FIRST_ID   33900

CLASS HTimer INHERIT HObject

   CLASS VAR aTimers   INIT {}
   DATA id, tag
   DATA value
   DATA lInit   INIT .F.
   DATA oParent
   DATA bAction

   //METHOD New(oParent, id, value, bAction)
   METHOD New(oParent, nId, value, bAction)
   METHOD Init()
   METHOD onAction()

   METHOD End()

   DATA   xName          HIDDEN
   ACCESS Name INLINE ::xName
   ASSIGN Name(cName) INLINE IIf(!Empty(cName) .AND. HB_IsChar(cName) .AND. !":" $ cName .AND. !"[" $ cName, ;
			(::xName := cName, __objAddData(::oParent, cName), ::oParent: &(cName) := Self), NIL)

ENDCLASS

METHOD New(oParent, nId, value, bAction) CLASS HTimer

   ::oParent := IIf(oParent == NIL, HWindow():GetMain(), oParent)
   IF nId == NIL
      nId := TIMER_FIRST_ID
      DO WHILE AScan(::aTimers, {|o|o:id == nId}) !=  0
         nId ++
      ENDDO
   ENDIF
   ::id      := nId
   /*
   ::value   := value
   ::bAction := bAction

//   ::tag := hwg_SetTimer(::id, ::value)

   */
   ::value   := IIf(HB_IsNumeric(value), value, 0)
   ::bAction := bAction
   /*
    if ::value > 0
      SetTimer(oParent:handle, ::id, ::value)
   endif
   */
   ::Init()
   AAdd(::aTimers, Self)
   ::oParent:AddObject(Self)





RETURN Self

METHOD End() CLASS HTimer
Local i

   hwg_KillTimer(::tag)
   i := AScan(::aTimers, {|o|o:id == ::id})
   IF i != 0
      ADel(::aTimers, i)
      ASize(::aTimers, Len(::aTimers) - 1)
   ENDIF

RETURN NIL

METHOD Init() CLASS HTimer
   IF ! ::lInit
      IF ::value > 0
         ::tag := hwg_SetTimer(::id, ::value)
      ENDIF
   ENDIF
   RETURN  NIL

METHOD onAction()

   hwg_TimerProc(, ::id, ::interval)

RETURN NIL


FUNCTION hwg_TimerProc(hWnd, idTimer, Time)
   LOCAL i := AScan(HTimer():aTimers, {|o|o:id == idTimer})

   HB_SYMBOL_UNUSED(hWnd)

   IF i != 0 .AND. HTimer():aTimers[i]:value > 0 .AND. HTimer():aTimers[i]:bAction != NIL .AND.;
      HB_IsBlock(HTimer():aTimers[i]:bAction)
      Eval(HTimer():aTimers[i]:bAction, HTimer():aTimers[i], time)
   ENDIF

   RETURN NIL

EXIT PROCEDURE CleanTimers
Local oTimer, i

   For i := 1 TO Len(HTimer():aTimers)
      oTimer := HTimer():aTimers[i]
      hwg_KillTimer(oTimer:tag)
   NEXT

RETURN

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(TIMERPROC, HWG_TIMERPROC);
#endif

#pragma ENDDUMP
