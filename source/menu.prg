//
// $Id: menu.prg 1810 2011-12-25 20:22:41Z LFBASSO $
//
// HWGUI - Harbour Win32 GUI library source code:
// Prg level menu functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define  MENU_FIRST_ID   32000
#define  CONTEXTMENU_FIRST_ID   32900
#define  FLAG_DISABLED   1
#define  FLAG_CHECK      2

STATIC _aMenuDef, _oWnd, _aAccel, _nLevel, _Id, _oMenu, _oBitmap
STATIC s_nWidthBmp, s_nHeightBmp, s_nbkColor  

CLASS HMenu INHERIT HObject
   DATA handle
   DATA aMenu
   METHOD New() INLINE Self
   METHOD END() INLINE hwg_DestroyMenu(::handle)
   METHOD Show(oWnd, xPos, yPos, lWnd)
ENDCLASS

METHOD Show(oWnd, xPos, yPos, lWnd) CLASS HMenu
   LOCAL aCoor

   oWnd:oPopup := Self
   IF PCount() == 1 .OR. lWnd == NIL .OR. !lWnd
      IF PCount() == 1
         aCoor := hwg_GetCursorPos()
         xPos  := aCoor[1]
         yPos  := aCoor[2]
      ENDIF
      hwg_trackmenu(::handle, xPos, yPos, oWnd:handle)
   ELSE
      aCoor := hwg_ClientToScreen(oWnd:handle, xPos, yPos)
      hwg_trackmenu(::handle, aCoor[1], aCoor[2], oWnd:handle)
   ENDIF

   RETURN NIL

FUNCTION hwg_CreateMenu
   LOCAL hMenu

   IF Empty(hMenu := hwg__CreateMenu())
      RETURN NIL
   ENDIF

   RETURN {{}, , , hMenu}

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
 *  AddMenuItem(aMenu, cItem, nMenuId, lSubMenu, [bItem] [,nPos]) --> aMenuItem
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
   hSubMenu := hwg__AddMenuItem(hSubMenu, cItem, nPos - 1, .T., nMenuId,, lSubMenu)

   IF nPos > Len(aMenu[1])
      IF lSubMenu
         AAdd(aMenu[1], {{}, cItem, nMenuId, 0, hSubMenu})
      ELSE
         AAdd(aMenu[1], {bItem, cItem, nMenuId, 0})
      ENDIF
      RETURN ATail(aMenu[1])
   ELSE
      AAdd(aMenu[1], NIL)
      AIns(aMenu[1], nPos)
      IF lSubMenu
         aMenu[1, nPos] := {{}, cItem, nMenuId, 0, hSubMenu}
      ELSE
         aMenu[1, nPos] := {bItem, cItem, nMenuId, 0}
      ENDIF
      RETURN aMenu[1, nPos]
   ENDIF

   RETURN NIL

FUNCTION hwg_FindMenuItem(aMenu, nId, nPos)
   LOCAL nPos1, aSubMenu
   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF aMenu[1, nPos, 3] == nId
         RETURN aMenu
      ELSEIF Len(aMenu[1, nPos]) > 4
         IF (aSubMenu := hwg_FindMenuItem(aMenu[1, nPos] , nId, @nPos1)) != NIL
            nPos := nPos1
            RETURN aSubMenu
         ENDIF
      ENDIF
      nPos++
   ENDDO
   RETURN NIL

FUNCTION hwg_GetSubMenuHandle(aMenu, nId)
   LOCAL aSubMenu := hwg_FindMenuItem(aMenu, nId)

   RETURN IIf(aSubMenu == NIL, 0, aSubMenu[5])

FUNCTION BuildMenu(aMenuInit, hWnd, oWnd, nPosParent, lPopup)
   LOCAL hMenu, nPos, aMenu, oBmp

   IF nPosParent == NIL
      IF lPopup == NIL .OR. !lPopup
         hMenu := hwg__CreateMenu()
      ELSE
         hMenu := hwg__CreatePopupMenu()
      ENDIF
      aMenu := {aMenuInit, , , , hMenu}
   ELSE
      hMenu := aMenuInit[5]
      nPos := Len(aMenuInit[1])
      aMenu := aMenuInit[1, nPosParent]
      /* This code just for sure menu runtime hfrmtmpl.prg is enable */
      IIf(hb_IsLogical(aMenu[4]), aMenu[4] := .F.,)
      hMenu := hwg__AddMenuItem(hMenu, aMenu[2], nPos + 1, .T., aMenu[3], aMenu[4], .T.)
      IF Len(aMenu) < 5
         AAdd(aMenu, hMenu)
      ELSE
         aMenu[5] := hMenu
      ENDIF
   ENDIF

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF hb_IsArray(aMenu[1, nPos, 1])
         BuildMenu(aMenu,,, nPos)
      ELSE
         IF aMenu[1, nPos, 1] == NIL .OR. aMenu[1, nPos, 2] != NIL
            /* This code just for sure menu runtime hfrmtmpl.prg is enable */
            IIf(hb_IsLogical(aMenu[1, nPos, 4]), aMenu[1, nPos, 4] := .F.,)
            hwg__AddMenuItem(hMenu, aMenu[1, nPos, 2], nPos, .T., ;
                              aMenu[1, nPos, 3], aMenu[1, nPos, 4], .F.)
            oBmp := hwg_SearchPosBitmap(aMenu[1, nPos, 3])
            IF oBmp[1]
               SetMenuItemBitmaps(hMenu, aMenu[1, nPos, 3], oBmp[2], "")
            ENDIF

         ENDIF
      ENDIF
      nPos++
   ENDDO
   IF hWnd != NIL .AND. oWnd != NIL
      hwg_SetMenu(oWnd, aMenu)
      IF s_nbkColor != NIL
         hwg_SetMenuInfo(oWnd:handle, s_nbkColor)
      ENDIF
   ELSEIF _oMenu != NIL
      _oMenu:handle := aMenu[5]
      _oMenu:aMenu := aMenu
   ENDIF
   RETURN NIL

FUNCTION hwg_BeginMenu(oWnd, nId, cTitle, nbkColor, nWidthBmp, nHeightBmp)
   LOCAL aMenu, i
   IF oWnd != NIL
      _aMenuDef := {}
      _aAccel   := {}
      _oBitmap  := {}
      _oWnd     := oWnd
      _oMenu    := NIL
      _nLevel   := 0
      _Id       := IIf(nId == NIL, MENU_FIRST_ID, nId)
      s_nWidthBmp  := IIf(nWidthBmp == NIL .OR. !HWG_ISWIN7(), GETSYSTEMMETRICS(SM_CXMENUCHECK), nWidthBmp)
      s_nHeightBmp := IIf(nHeightBmp == NIL .OR. !HWG_ISWIN7(), GETSYSTEMMETRICS(SM_CYMENUCHECK), nHeightBmp)
      s_nbkColor   := nbkColor 
   ELSE
      nId   := IIf(nId == NIL, ++_Id, nId)
      aMenu := _aMenuDef
      FOR i := 1 TO _nLevel
         aMenu := ATail(aMenu)[1]
      NEXT
      _nLevel++
      AAdd(aMenu, {{}, cTitle, nId, 0})
   ENDIF
   RETURN .T.

FUNCTION hwg_ContextMenu()
   _aMenuDef := {}
   _oBitmap  := {}
   _oWnd := NIL
   _nLevel := 0
   _Id := CONTEXTMENU_FIRST_ID
   _oMenu := HMenu():New()
   RETURN _oMenu

FUNCTION hwg_EndMenu()
   IF _nLevel > 0
      _nLevel--
   ELSE
      BuildMenu(AClone(_aMenuDef), IIf(_oWnd != NIL, _oWnd:handle, NIL), ;
                 _oWnd,, IIf(_oWnd != NIL, .F., .T.))
      IF _oWnd != NIL .AND. _aAccel != NIL .AND. !Empty(_aAccel)
         _oWnd:hAccel := CreateAcceleratorTable(_aAccel)
      ENDIF
      _aMenuDef := NIL
      _oBitmap  := NIL
      _aAccel   := NIL
      _oWnd     := NIL
      _oMenu    := NIL
   ENDIF
   RETURN .T.

FUNCTION hwg_DefineMenuItem(cItem, nId, bItem, lDisabled, accFlag, accKey, lBitmap, lResource, lCheck)
   LOCAL aMenu, i, oBmp, nFlag

   lCheck := IIf(lCheck == NIL, .F., lCheck)
   lDisabled := IIf(lDisabled == NIL, .F., lDisabled)
   nFlag := hwg_BitOr(IIf(lCheck, FLAG_CHECK, 0), IIf(lDisabled, FLAG_DISABLED, 0))

   aMenu := _aMenuDef
   FOR i := 1 TO _nLevel
      aMenu := ATail(aMenu)[1]
   NEXT
   IF !Empty(cItem)
      cItem := StrTran(cItem, "\t", Chr(9))
   ENDIF
   nId := IIf(nId == NIL .AND. cItem != NIL, ++_Id, nId)
   AAdd(aMenu, {bItem, cItem, nId, nFlag})
   IF lBitmap != NIL .OR. !Empty(lBitmap)
      IF lResource == NIL
         lResource := .F.
      ENDIF
      IF lResource .OR. At(".", lBitmap) == 0
         oBmp := HBitmap():AddResource(lBitmap, LR_LOADMAP3DCOLORS + LR_SHARED + LR_LOADTRANSPARENT , , s_nWidthBmp, s_nHeightBmp)
      ELSE
         oBmp := HBitmap():AddFile(lBitmap, , .T. , s_nWidthBmp, s_nHeightBmp)
      ENDIF
      AAdd(_oBitmap, {.T., oBmp:handle, cItem, nId})
   ELSE
      AAdd(_oBitmap, {.F., "", cItem, nId})
   ENDIF
   IF accFlag != NIL .AND. accKey != NIL
      AAdd(_aAccel, {accFlag, accKey, nId})
   ENDIF
   RETURN .T.

FUNCTION hwg_DefineAccelItem(nId, bItem, accFlag, accKey)
   LOCAL aMenu, i
   aMenu := _aMenuDef
   FOR i := 1 TO _nLevel
      aMenu := ATail(aMenu)[1]
   NEXT
   nId := IIf(nId == NIL, ++_Id, nId)
   AAdd(aMenu, {bItem, NIL, nId, 0})
   AAdd(_aAccel, {accFlag, accKey, nId})
   RETURN .T.


FUNCTION hwg_SetMenuItemBitmaps(aMenu, nId, abmp1, abmp2)
   LOCAL aSubMenu := hwg_FindMenuItem(aMenu, nId)
   LOCAL oMenu

   oMenu := IIf(aSubMenu == NIL, 0, aSubMenu[5])
   SetMenuItemBitmaps(oMenu, nId, abmp1, abmp2)
   RETURN NIL

FUNCTION hwg_InsertBitmapMenu(aMenu, nId, lBitmap, oResource)
   LOCAL aSubMenu := hwg_FindMenuItem(aMenu, nId)
   LOCAL oMenu, oBmp

   //Serge(seohic) sugest
   IF oResource == NIL .OR. !oResource
      oBmp := HBitmap():AddFile(lBitmap)
   ELSE
      oBmp := HBitmap():AddResource(lBitmap)
   ENDIF
   oMenu := IIf(aSubMenu == NIL, 0, aSubMenu[5])
   HWG__InsertBitmapMenu(oMenu, nId, oBmp:handle)
   RETURN NIL

FUNCTION hwg_SearchPosBitmap(nPos_Id)

   LOCAL nPos := 1, lBmp := {.F., ""}

   IF _oBitmap != NIL
      DO WHILE nPos <= Len(_oBitmap)

         IF _oBitmap[nPos][4] == nPos_Id
            lBmp := {_oBitmap[nPos][1], _oBitmap[nPos][2], _oBitmap[nPos][3]}
         ENDIF

         nPos++

      ENDDO
   ENDIF

   RETURN lBmp

FUNCTION DeleteMenuItem(oWnd, nId)
   LOCAL aSubMenu, nPos

   IF (aSubMenu := hwg_FindMenuItem(oWnd:menu, nId, @nPos)) != NIL
      ADel(aSubMenu[1], nPos)
      ASize(aSubMenu[1], Len(aSubMenu[1]) - 1)

      hwg_DeleteMenu(GetMenuHandle(oWnd:handle), nId)
   ENDIF
   RETURN NIL
