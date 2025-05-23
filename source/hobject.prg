//
// HWGUI - Harbour Win32 GUI library source code:
// HObject class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HObject

   DATA aObjects INIT {}

   METHOD AddObject(oCtrl) INLINE AAdd(::aObjects, oCtrl)
   METHOD DelObject(oCtrl)
   METHOD Release() INLINE ::DelObject(Self)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HObject:DelObject(oCtrl)

   LOCAL h := oCtrl:handle
   LOCAL i := AScan(::aObjects, {|o|o:handle == h})

   hwg_SendMessage(h, WM_CLOSE, 0, 0)
   IF i != 0
      ADel(::aObjects, i)
      ASize(::aObjects, Len(::aObjects) - 1)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

PROCEDURE HB_GT_DEFAULT_NUL()
RETURN

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_AddMethod(oObjectName, cMethodName, pFunction)

   IF hb_IsObject(oObjectName) .AND. !Empty(cMethodName)
      IF !__ObjHasMsg(oObjectName, cMethodName)
         __objAddMethod(oObjectName, cMethodName, pFunction)
      ENDIF
      RETURN .T.
   ENDIF

RETURN .F.

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_AddProperty(oObjectName, cPropertyName, eNewValue)

   IF hb_IsObject(oObjectName) .AND. !Empty(cPropertyName)
      IF !__objHasData(oObjectName, cPropertyName)
         IF Empty(__objAddData(oObjectName, cPropertyName))
            RETURN .F.
         ENDIF
      ENDIF
      IF !Empty(eNewValue)
         IF hb_IsBlock(eNewValue)
            oObjectName: &(cPropertyName) := Eval(eNewValue)
         ELSE
            oObjectName: &(cPropertyName) := eNewValue
         ENDIF
      ENDIF
      RETURN .T.
   ENDIF

RETURN .F.

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_RemoveProperty(oObjectName, cPropertyName)

   IF hb_IsObject(oObjectName) .AND. !Empty(cPropertyName) .AND. __objHasData(oObjectName, cPropertyName)
       RETURN Empty(__objDelData(oObjectName, cPropertyName))
   ENDIF

RETURN .F.

//-------------------------------------------------------------------------------------------------------------------//
#ifndef __SYGECOM__
INIT PROCEDURE HWGINIT

   hwg_ErrorSys()

RETURN
#endif
//-------------------------------------------------------------------------------------------------------------------//

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(ADDMETHOD, HWG_ADDMETHOD);
HB_FUNC_TRANSLATE(ADDPROPERTY, HWG_ADDPROPERTY);
HB_FUNC_TRANSLATE(REMOVEPROPERTY, HWG_REMOVEPROPERTY);
#endif

#pragma ENDDUMP
