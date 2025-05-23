//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// Prg level menu functions
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

#define MENU_FIRST_ID   32000
#define CONTEXTMENU_FIRST_ID   32900
#define FLAG_DISABLED   1
#define FLAG_CHECK      2

STATIC s__aMenuDef, s__oWnd, s__aAccel, s__nLevel, s__Id, s__oMenu, s__oBitmap

CLASS HMenu INHERIT HObject
   DATA handle
   DATA aMenu 
   METHOD New() INLINE Self
   METHOD End() INLINE hwg_DestroyMenu(::handle)
   METHOD Show(oWnd, xPos, yPos, lWnd)
ENDCLASS

METHOD HMenu:Show(oWnd, xPos, yPos, lWnd)

   //LOCAL aCoor // variable not used

   HB_SYMBOL_UNUSED(oWnd)
   HB_SYMBOL_UNUSED(xPos)
   HB_SYMBOL_UNUSED(yPos)
   HB_SYMBOL_UNUSED(lWnd)

/*
   oWnd:oPopup := Self
   IF Pcount() == 1 .OR. lWnd == NIL .OR. !lWnd
      IF Pcount() == 1
         aCoor := hwg_GetCursorPos()
         xPos  := aCoor[1]
         yPos  := aCoor[2]
      ENDIF
      hwg_trackmenu(::handle, xPos, yPos, oWnd:handle)
   ELSE
      aCoor := hwg_ClientToScreen(oWnd:handle, xPos, yPos)
      hwg_trackmenu(::handle, aCoor[1], aCoor[2], oWnd:handle)
   ENDIF
*/
RETURN NIL

FUNCTION hwg_CreateMenu

   LOCAL hMenu

   IF (Empty(hMenu := hwg__CreateMenu()))
      RETURN NIL
   ENDIF

RETURN {{},,, hMenu}

FUNCTION hwg_SetMenu(oWnd, aMenu)

   IF !Empty(oWnd:handle)
      IF hwg__SetMenu(oWnd:handle, aMenu[5])
         oWnd:menu := aMenu
      ELSE
         RETURN .F.
      ENDIF
   ELSE
      oWnd:menu := aMenu
   ENDIF

RETURN .T.

/*
 *  AddMenuItem(aMenu, cItem, nMenuId, lSubMenu, [bItem] [, nPos]) --> aMenuItem
 *
 *  If nPos is omitted, the function adds menu item to the end of menu,
 *  else it inserts menu item in nPos position.
 */
FUNCTION hwg_AddMenuItem(aMenu, cItem, nMenuId, lSubMenu, bItem, nPos)

   LOCAL hSubMenu

   IF nPos == NIL
      nPos := Len(aMenu[1]) + 1
   ENDIF

   hSubMenu := aMenu[5]
   hSubMenu := hwg__AddMenuItem(hSubMenu, cItem, nPos - 1, hwg_GetActiveWindow(), nMenuId,, lSubMenu)

   IF nPos > Len(aMenu[1])
      IF lSubmenu
         AAdd(aMenu[1], {{}, cItem, nMenuId, 0, hSubMenu})
      ELSE
         AAdd(aMenu[1], {bItem, cItem, nMenuId, 0, hSubMenu})
      ENDIF
      RETURN ATail(aMenu[1])
   ELSE
      AAdd(aMenu[1], NIL)
      Ains(aMenu[1], nPos)
      IF lSubmenu
         aMenu[1, nPos] := {{}, cItem, nMenuId, 0, hSubMenu}
      ELSE
         aMenu[1, nPos] := {bItem, cItem, nMenuId, 0, hSubMenu}
      ENDIF
      RETURN aMenu[1, nPos]
   ENDIF

RETURN NIL

FUNCTION hwg_FindMenuItem(aMenu, nId, nPos)

   LOCAL nPos1
   LOCAL aSubMenu

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF aMenu[1, npos, 3] == nId
         RETURN aMenu
      ELSEIF hb_IsArray(aMenu[1, npos, 1])
         IF (aSubMenu := hwg_FindMenuItem(aMenu[1, nPos], nId, @nPos1)) != NIL
            nPos := nPos1
            RETURN aSubMenu
         ENDIF
      ENDIF
      nPos ++
   ENDDO
RETURN NIL

FUNCTION hwg_GetSubMenuHandle(aMenu, nId)

   LOCAL aSubMenu := hwg_FindMenuItem(aMenu, nId)

RETURN IIf(aSubMenu == NIL, 0, aSubMenu[5])

FUNCTION hwg_BuildMenu(aMenuInit, hWnd, oWnd, nPosParent, lPopup)

   LOCAL hMenu
   LOCAL nPos
   LOCAL aMenu
   //LOCAL i // variable not used
   //LOCAL oBmp // variable not used

   IF nPosParent == NIL   
      IF lPopup == NIL .OR. !lPopup
         hMenu := hwg__CreateMenu()
      ELSE
         hMenu := hwg__CreatePopupMenu()
      ENDIF
      aMenu := {aMenuInit,,,, hMenu}
   ELSE
      hMenu := aMenuInit[5]
      nPos := Len(aMenuInit[1])
      aMenu := aMenuInit[1, nPosParent]
      hMenu := hwg__AddMenuItem(hMenu, aMenu[2], nPos + 1, hWnd, aMenu[3], aMenu[4], .T.)
      IF Len(aMenu) < 5
         AAdd(aMenu, hMenu)
      ELSE
         aMenu[5] := hMenu
      ENDIF
   ENDIF

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF hb_IsArray(aMenu[1, nPos, 1])
         hwg_BuildMenu(aMenu, hWnd,, nPos)
      ELSE 
         IF aMenu[1, nPos, 1] == NIL .OR. aMenu[1, nPos, 2] != NIL
            IF Len(aMenu[1, npos]) == 4
               AAdd(aMenu[1, npos], NIL)
            ENDIF
            aMenu[1, npos, 5] := hwg__AddMenuItem(hMenu, aMenu[1, npos, 2], ;
                          nPos, hWnd, aMenu[1, nPos, 3], aMenu[1, npos, 4], .F.)
         ENDIF
      ENDIF
      nPos ++
   ENDDO
   IF hWnd != NIL .AND. oWnd != NIL
      hwg_SetMenu(oWnd, aMenu)
   ELSEIF s__oMenu != NIL
      s__oMenu:handle := aMenu[5]
      s__oMenu:aMenu := aMenu
   ENDIF
RETURN NIL

FUNCTION hwg_BeginMenu(oWnd, nId, cTitle)

   LOCAL aMenu
   LOCAL i

   IF oWnd != NIL
      s__aMenuDef := {}
      s__aAccel   := {}
      s__oBitmap  := {}
      s__oWnd     := oWnd
      s__oMenu    := NIL
      s__nLevel   := 0
      s__Id       := IIf(nId == NIL, MENU_FIRST_ID, nId)
   ELSE
      nId   := IIf(nId == NIL, ++s__Id, nId)
      aMenu := s__aMenuDef
      FOR i := 1 TO s__nLevel
         aMenu := Atail(aMenu)[1]
      NEXT
      s__nLevel++
      IF !Empty(cTitle)
         cTitle := StrTran(cTitle, "\t", "")
         cTitle := StrTran(cTitle, "&", "_")
      ENDIF
      AAdd(aMenu, {{}, cTitle, nId, 0})
   ENDIF
RETURN .T.

FUNCTION hwg_ContextMenu()
   s__aMenuDef := {}
   s__oBitmap  := {}
   s__oWnd := NIL
   s__nLevel := 0
   s__Id := CONTEXTMENU_FIRST_ID
   s__oMenu := HMenu():New()
RETURN s__oMenu

FUNCTION hwg_EndMenu()
   IF s__nLevel > 0
      s__nLevel --
   ELSE
      hwg_BuildMenu(Aclone(s__aMenuDef), IIf(s__oWnd != NIL,s__oWnd:handle, NIL), ;
                   s__oWnd,, IIf(s__oWnd != NIL, .F., .T.))
      IF s__oWnd != NIL .AND. s__aAccel != NIL .AND. !Empty(s__aAccel)
         // s__oWnd:hAccel := hwg_CreateAcceleratorTable(s__aAccel)
      ENDIF
      s__aMenuDef := NIL
      s__oBitmap  := NIL
      s__aAccel   := NIL
      s__oWnd     := NIL
      s__oMenu    := NIL
   ENDIF
RETURN .T.

FUNCTION hwg_DefineMenuItem(cItem, nId, bItem, lDisabled, accFlag, accKey, lBitmap, lResource, lCheck)

   LOCAL aMenu
   LOCAL i
   //LOCAL oBmp // variable not used
   LOCAL nFlag

   HB_SYMBOL_UNUSED(accFlag)
   HB_SYMBOL_UNUSED(accKey)
   HB_SYMBOL_UNUSED(lBitmap)
   HB_SYMBOL_UNUSED(lResource)

   lCheck := IIf(lCheck == NIL, .F., lCheck)
   lDisabled := IIf(lDisabled == NIL, .T., !lDisabled)
   nFlag := hwg_BitOr(IIf(lCheck, FLAG_CHECK, 0), IIf(lDisabled, 0, FLAG_DISABLED))

   aMenu := s__aMenuDef
   FOR i := 1 TO s__nLevel
      aMenu := Atail(aMenu)[1]
   NEXT
   nId := IIf(nId == NIL .AND. cItem != NIL, ++s__Id, nId)
   IF !Empty(cItem)
      cItem := StrTran(cItem, "\t", "")
      cItem := StrTran(cItem, "&", "_")
   ENDIF
   AAdd(aMenu, {bItem, cItem, nId, nFlag, 0})
   /*
   IF lBitmap != NIL .OR. !Empty(lBitmap)
      IF lResource == NIL
         lResource := .F.
      ENDIF
      IF !lResource
         oBmp := HBitmap():AddFile(lBitmap)
      ELSE
         oBmp := HBitmap():AddResource(lBitmap)
      ENDIF
      AAdd(s__oBitmap, {.T., oBmp:Handle, cItem, nId})
   ELSE
      AAdd(s__oBitmap, {.F., "", cItem, nID})
   ENDIF
   IF accFlag != NIL .AND. accKey != NIL
      AAdd(s__aAccel, {accFlag, accKey, nId})
   ENDIF
   */
RETURN .T.

/*
FUNCTION hwg_DefineAccelItem(nId, bItem, accFlag, accKey)

   LOCAL aMenu
   LOCAL i

   aMenu := s__aMenuDef
   FOR i := 1 TO s__nLevel
      aMenu := Atail(aMenu)[1]
   NEXT
   nId := IIf(nId == NIL, ++s__Id, nId)
   AAdd(aMenu, {bItem, NIL, nId, .T.})
   AAdd(s__aAccel, {accFlag, accKey, nId})
RETURN .T.


FUNCTION hwg_SetMenuItemBitmaps(aMenu, nId, abmp1, abmp2)

   LOCAL aSubMenu := hwg_FindMenuItem(aMenu, nId)
   LOCAL oMenu := aSubMenu

IIf(aSubMenu == NIL, oMenu := 0, oMenu := aSubMenu[5])
SetMenuItemBitmaps(oMenu, nId, abmp1, abmp2)
RETURN NIL

FUNCTION hwg_InsertBitmapMenu(aMenu, nId, lBitmap, oResource)

   LOCAL aSubMenu := hwg_FindMenuItem(aMenu, nId)
   LOCAL oMenu := aSubMenu
   LOCAL oBmp

IF !oResource .OR. oResource == NIL
     oBmp := HBitmap():AddFile(lBitmap)
ELSE
     oBmp := HBitmap():AddResource(lBitmap)
ENDIF
IIf(aSubMenu == NIL, oMenu := 0, oMenu := aSubMenu[5])
HWG__InsertBitmapMenu(oMenu, nId, obmp:handle)
RETURN NIL

FUNCTION hwg_SearchPosBitmap(nPos_Id)

   LOCAL nPos := 1
   LOCAL lBmp := {.F., ""}

   IF s__oBitmap != NIL
      DO WHILE nPos<=Len(s__oBitmap)

         IF s__oBitmap[nPos][4] == nPos_Id
            lBmp := {s__oBitmap[nPos][1], s__oBitmap[nPos][2],s__oBitmap[nPos][3]}
         ENDIF

         nPos ++

      ENDDO
   ENDIF

RETURN lBmp
*/ 

STATIC FUNCTION GetMenuByHandle(hWnd)

   LOCAL i
   LOCAL aMenu
   LOCAL oDlg

   IF hWnd == NIL
      aMenu := HWindow():GetMain():menu
   ELSE
      IF (oDlg := HDialog():FindDialog(hWnd)) != NIL
         aMenu := oDlg:menu
      ELSEIF (i := AScan(HDialog():aModalDialogs, {|o|o:handle == hWnd})) != NIL
         aMenu := HDialog():aModalDialogs[i]:menu
      ELSEIF (i := AScan(HWindow():aWindows, {|o|o:handle == hWnd})) != NIL
         aMenu := HWindow():aWindows[i]:menu
      ENDIF
   ENDIF

RETURN aMenu

// TODO: adi��o do prefixo HWG_ conflita com fun��o j� existente
FUNCTION CheckMenuItem(hWnd, nId, lValue)

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos

   aMenu := GetMenuByHandle(hWnd)
   IF aMenu != NIL
      IF (aSubMenu := hwg_FindMenuItem(aMenu, nId, @nPos)) != NIL
         hwg_CheckMenuItem(aSubmenu[1, nPos, 5], lValue)
      ENDIF
   ENDIF

RETURN NIL

// TODO: adi��o do prefixo HWG_ conflita com fun��o j� existente
FUNCTION IsCheckedMenuItem(hWnd, nId)

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos
   LOCAL lRes := .F.
   
   aMenu := GetMenuByHandle(hWnd)
   IF aMenu != NIL
      IF (aSubMenu := hwg_FindMenuItem(aMenu, nId, @nPos)) != NIL
         lRes := hwg_IsCheckedMenuItem(aSubmenu[1, nPos, 5])
      ENDIF   
   ENDIF
   
RETURN lRes

// TODO: adi��o do prefixo HWG_ conflita com fun��o j� existente
FUNCTION EnableMenuItem(hWnd, nId, lValue)

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos

   aMenu := GetMenuByHandle(IIf(hWnd == NIL, HWindow():GetMain():handle, hWnd))
   IF aMenu != NIL
      IF (aSubMenu := hwg_FindMenuItem(aMenu, nId, @nPos)) != NIL
         hwg_EnableMenuItem(aSubmenu[1, nPos, 5], lValue)
      ENDIF
   ENDIF

RETURN NIL

// TODO: adi��o do prefixo HWG_ conflita com fun��o j� existente
FUNCTION IsEnabledMenuItem(hWnd, nId)

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos

   aMenu := GetMenuByHandle(IIf(hWnd == NIL, HWindow():GetMain():handle, hWnd))
   IF aMenu != NIL
      IF (aSubMenu := hwg_FindMenuItem(aMenu, nId, @nPos)) != NIL
         hwg_IsEnabledMenuItem(aSubmenu[1, nPos, 5])
      ENDIF   
   ENDIF
   
RETURN NIL

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(BUILDMENU, HWG_BUILDMENU);
#endif

#pragma ENDDUMP
