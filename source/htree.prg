//
// $Id: htree.prg 1895 2012-09-12 11:56:05Z lfbasso $
//
// HWGUI - Harbour Win32 GUI library source code:
// HTree class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

STATIC s_aEvents

CLASS HTreeNode INHERIT HObject

   DATA handle
   DATA oTree, oParent
   DATA aItems INIT {}
   DATA bAction, bClick
   DATA cargo
   DATA title
   DATA image1, image2
   DATA lchecked INIT .F.

   METHOD New(oTree, oParent, oPrev, oNext, cTitle, bAction, aImages, lchecked, bClick)
   METHOD AddNode(cTitle, oPrev, oNext, bAction, aImages)
   METHOD Delete(lInternal)
   METHOD FindChild(h)
   METHOD GetText() INLINE hwg_TreeGetNodeText(::oTree:handle, ::handle)
   METHOD SetText(cText) INLINE hwg_TreeSetItem(::oTree:handle, ::handle, TREE_SETITEM_TEXT, cText), ::title := cText
   METHOD Checked(lChecked)  SETGET
   METHOD GetLevel(h)

ENDCLASS

METHOD New(oTree, oParent, oPrev, oNext, cTitle, bAction, aImages, lchecked, bClick) CLASS HTreeNode

   LOCAL aItems
   LOCAL i
   LOCAL h
   LOCAL im1
   LOCAL im2
   LOCAL cImage
   LOCAL op
   LOCAL nPos

   ::oTree    := oTree
   ::oParent  := oParent
   ::Title    := cTitle
   ::bAction  := bAction
   ::bClick   := bClick
   ::lChecked := IIf(lChecked == NIL, .F., lChecked)

   IF aImages == NIL
      IF oTree:Image1 != NIL
         im1 := oTree:Image1
         IF oTree:Image2 != NIL
            im2 := oTree:Image2
         ENDIF
      ENDIF
   ELSE
      FOR i := 1 TO Len(aImages)
         cImage := Upper(aImages[i])
         IF (h := AScan(oTree:aImages, cImage)) == 0
            AAdd(oTree:aImages, cImage)
            aImages[i] := IIf(oTree:Type, hwg_LoadBitmap(aImages[i]), hwg_OpenBitmap(aImages[i]))
            hwg_Imagelist_Add(oTree:himl, aImages[i])
            h := Len(oTree:aImages)
         ENDIF
         h--
         IF i == 1
            im1 := h
         ELSE
            im2 := h
         ENDIF
      NEXT
   ENDIF
   IF im2 == NIL
      im2 := im1
   ENDIF

   nPos := IIf(oPrev == NIL, 2, 0)
   IF oPrev == NIL .AND. oNext != NIL
      op := IIf(oNext:oParent == NIL, oNext:oTree, oNext:oParent)
      FOR i := 1 TO Len(op:aItems)
         IF op:aItems[i]:handle == oNext:handle
            EXIT
         ENDIF
      NEXT
      IF i > 1
         oPrev := op:aItems[i - 1]
         nPos := 0
      ELSE
         nPos := 1
      ENDIF
   ENDIF
   ::handle := hwg_TreeAddNode(Self, oTree:handle,               ;
                            IIf(oParent == NIL, NIL, oParent:handle), ;
                            IIf(oPrev == NIL, NIL, oPrev:handle), nPos, cTitle, im1, im2)

   aItems := IIf(oParent == NIL, oTree:aItems, oParent:aItems)
   IF nPos == 2
      AAdd(aItems, Self)
   ELSEIF nPos == 1
      AAdd(aItems, NIL)
      AIns(aItems, 1)
      aItems[1] := Self
   ELSE
      AAdd(aItems, NIL)
      h := oPrev:handle
      IF (i := AScan(aItems, {|o|o:handle == h})) == 0
         aItems[Len(aItems)] := Self
      ELSE
         AIns(aItems, i + 1)
         aItems[i + 1] := Self
      ENDIF
   ENDIF
   ::image1 := im1
   ::image2 := im2

   RETURN Self

METHOD AddNode(cTitle, oPrev, oNext, bAction, aImages) CLASS HTreeNode
   
   LOCAL oParent := Self
   LOCAL oNode := HTreeNode():New(::oTree, oParent, oPrev, oNext, cTitle, bAction, aImages)

   RETURN oNode

METHOD Delete(lInternal) CLASS HTreeNode
   
   LOCAL h := ::handle
   LOCAL j
   LOCAL alen
   LOCAL aItems

   IF !Empty(::aItems)
      alen := Len(::aItems)
      FOR j := 1 TO alen
         ::aItems[j]:Delete(.T.)
         ::aItems[j] := NIL
      NEXT
   ENDIF
   hwg_Tree_ReleaseNode(::oTree:handle, ::handle)
   hwg_SendMessage(::oTree:handle, TVM_DELETEITEM, 0, ::handle)
   IF lInternal == NIL
      aItems := IIf(::oParent == NIL, ::oTree:aItems, ::oParent:aItems)
      j := AScan(aItems, {|o|o:handle == h})
      ADel(aItems, j)
      ASize(aItems, Len(aItems) - 1)
   ENDIF
   // hwg_DecreaseHolders(::handle)

   RETURN NIL

METHOD FindChild(h) CLASS HTreeNode
   
   LOCAL aItems := ::aItems
   LOCAL i
   LOCAL alen := Len(aItems)
   LOCAL oNode

   FOR i := 1 TO alen
      IF aItems[i]:handle == h
         RETURN aItems[i]
      ELSEIF !Empty(aItems[i]:aItems)
         IF (oNode := aItems[i]:FindChild(h)) != NIL
            RETURN oNode
         ENDIF
      ENDIF
   NEXT
   RETURN NIL

METHOD Checked(lChecked) CLASS HTreeNode
   
   LOCAL state

   IF lChecked != NIL
      hwg_TreeSetItem(::oTree:handle, ::handle, TREE_SETITEM_CHECK, IIf(lChecked, 2, 1))
      ::lChecked := lChecked
   ELSE
      state := hwg_SendMessage(::oTree:handle, TVM_GETITEMSTATE, ::handle,, TVIS_STATEIMAGEMASK) - 1
      ::lChecked := int(state / 4092) == 2
   ENDIF
   RETURN ::lChecked

METHOD GetLevel(h) CLASS HTreeNode
   
   LOCAL iLevel := 1
   LOCAL oNode := IIf(Empty(h), Self, h)

   DO WHILE (oNode:oParent) != NIL
       oNode := oNode:oParent
       iLevel++
   ENDDO
   RETURN iLevel

CLASS HTree INHERIT HControl

CLASS VAR winclass   INIT "SysTreeView32"

   DATA aItems INIT {}
   DATA oSelected
   DATA oItem, oItemOld
   DATA hIml, aImages, Image1, Image2
   DATA bItemChange, bExpand, bRClick, bDblClick, bAction, bCheck, bKeyDown
   DATA bdrag, bdrop
   DATA lEmpty INIT .T.
   DATA lEditLabels INIT .F. HIDDEN
   DATA lCheckbox   INIT .F. HIDDEN
   DATA lDragDrop   INIT .F. HIDDEN

   DATA   lDragging  INIT .F. HIDDEN
   DATA  hitemDrag, hitemDrop HIDDEN

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, color, bcolor, ;
               aImages, lResour, lEditLabels, bAction, nBC, bRClick, bDblClick, lCheckbox, bCheck, lDragDrop, bDrag, bDrop, bOther)
   METHOD Init()
   METHOD Activate()
   METHOD AddNode(cTitle, oPrev, oNext, bAction, aImages)
   METHOD FindChild(h)
   METHOD FindChildPos(oNode, h)
   METHOD GetSelected() INLINE IIf(hb_IsObject(::oItem := hwg_TreeGetSelected(::handle)), ::oItem, NIL)
   METHOD EditLabel(oNode) BLOCK {|Self, o|hwg_SendMessage(::handle, TVM_EDITLABEL, 0, o:handle)}
   METHOD Expand(oNode, lAllNode)   //BLOCK {|Self, o|hwg_SendMessage(::handle, TVM_EXPAND, TVE_EXPAND, o:handle), hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_FRAME + RDW_INVALIDATE)}
   METHOD Select(oNode) BLOCK {|Self, o|hwg_SendMessage(::handle, TVM_SELECTITEM, TVGN_CARET, o:handle), ::oItem := hwg_TreeGetSelected(::handle)}
   METHOD Clean()
   METHOD Notify(lParam)
   METHOD END() INLINE (::Super:END(), ReleaseTree(::aItems))
   METHOD isExpand(oNodo) INLINE !hwg_CheckBit(oNodo, TVE_EXPAND)
   METHOD onEvent(msg, wParam, lParam)
   METHOD ItemHeight(nHeight) SETGET
   METHOD SearchString(cText, iNivel, oNode, inodo)
   METHOD Selecteds(oItem, aSels)
   METHOD Top() INLINE IIf(!Empty(::aItems), (::Select(::aItems[1]), hwg_SendMessage(::handle, WM_VSCROLL, hwg_MAKEWPARAM(0, SB_TOP), NIL)),)
   METHOD Bottom() INLINE IIf(!Empty(::aItems), (::Select(::aItems[Len(::aItems)]), hwg_SendMessage(::handle, WM_VSCROLL, hwg_MAKEWPARAM(0, SB_BOTTOM), NIL)),)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, color, bcolor, ;
            aImages, lResour, lEditLabels, bAction, nBC, bRClick, bDblClick, lcheckbox, bCheck, lDragDrop, bDrag, bDrop, bOther) CLASS HTree
   
   LOCAL i
   LOCAL aBmpSize

   lEditLabels := IIf(lEditLabels == NIL, .F., lEditLabels)
   lCheckBox   := IIf(lCheckBox == NIL, .F., lCheckBox)
   lDragDrop   := IIf(lDragDrop == NIL, .F., lDragDrop)

   nStyle   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP  + TVS_FULLROWSELECT + TVS_TRACKSELECT+; //TVS_HASLINES +  ;
                            TVS_LINESATROOT + TVS_HASBUTTONS  + TVS_SHOWSELALWAYS + ;
                          IIf(lEditLabels == NIL .OR. !lEditLabels, 0, TVS_EDITLABELS) +;
                          IIf(lCheckBox == NIL .OR. !lCheckBox, 0, TVS_CHECKBOXES) +;
                          IIf(!lDragDrop, TVS_DISABLEDRAGDROP, 0))

   ::sTyle := nStyle
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
              bSize,,, color, bcolor)

   ::lEditLabels :=  lEditLabels
   ::lCheckBox   :=  lCheckBox
   ::lDragDrop   :=  lDragDrop

   ::title   := ""
   ::Type    := IIf(lResour == NIL, .F., lResour)
   ::bAction := bAction
   ::bRClick := bRClick
   ::bDblClick := bDblClick
   ::bCheck  :=  bCheck
   ::bDrag   := bDrag
   ::bDrop   := bDrop
   ::bOther  := bOther

   IF aImages != NIL .AND. !Empty(aImages)
      ::aImages := {}
      FOR i := 1 TO Len(aImages)
         AAdd(::aImages, Upper(aImages[i]))
         aImages[i] := IIf(lResour != NIL .AND. lResour, hwg_LoadBitmap(aImages[i]), hwg_OpenBitmap(aImages[i]))
      NEXT
      aBmpSize := hwg_GetBitmapSize(aImages[1])
      ::himl := hwg_CreateImageList(aImages, aBmpSize[1], aBmpSize[2], 12, nBC)
      ::Image1 := 0
      IF Len(aImages) > 1
         ::Image2 := 1
      ENDIF
   ENDIF

   ::Activate()

   RETURN Self

METHOD Init() CLASS HTree

   IF !::lInit
      ::Super:Init()
      ::nHolder := 1
      hwg_SetWindowObject(::handle, Self)
      hwg_InitTreeView(::handle)
      IF ::himl != NIL
         hwg_SendMessage(::handle, TVM_SETIMAGELIST, TVSIL_NORMAL, ::himl)
      ENDIF

   ENDIF

   RETURN NIL

METHOD Activate() CLASS HTree

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateTree(::oParent:handle, ::id, ;
                              ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::tcolor, ::bcolor)
      ::Init()
   ENDIF

   RETURN NIL


METHOD onEvent(msg, wParam, lParam) CLASS HTree
   
   LOCAL nEval
   LOCAL hitemNew
   LOCAL htiParent
   LOCAL htiPrev
   LOCAL htiNext

   IF hb_IsBlock(::bOther)
      IF (nEval := Eval(::bOther, Self, msg, wParam, lParam)) != NIL .AND. nEval != -1
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_ERASEBKGND
      RETURN 0
   ELSEIF msg == WM_CHAR
      IF wParam == 27
         RETURN DLGC_WANTMESSAGE
      ENDIF
      RETURN 0

   ELSEIF msg == WM_KEYUP
      IF hwg_ProcKeyList(Self, wParam)
         RETURN 0
      ENDIF

   ELSEIF msg == WM_LBUTTONDOWN

   ELSEIF msg == WM_LBUTTONUP .AND. ::lDragging .AND. ::hitemDrop != NIL
      ::lDragging := .F.
      hwg_SendMessage(::handle, TVM_SELECTITEM, TVGN_DROPHILITE, NIL)

      IF hb_IsBlock(::bDrag)
         nEval :=  Eval(::bDrag, Self, ::hitemDrag, ::hitemDrop)
         nEval := IIf(hb_IsLogical(nEval), nEval, .T.)
         IF !nEval
            RETURN 0
         ENDIF
      ENDIF
      IF ::hitemDrop != NIL
         IF ::hitemDrag:handle == ::hitemDrop:handle
                RETURN 0
         ENDIF
         htiParent := ::hitemDrop //:oParent
         DO WHILE (htiParent:oParent) != NIL
            htiParent := htiParent:oParent
            IF htiParent:handle = ::hitemDrag:handle
               RETURN 0
            ENDIF
         ENDDO
         IF !hwg_IsCtrlShift(.T.)
            IF (::hitemDrag:oParent == NIL .OR. ::hitemDrop:oParent == NIL) .OR. ;
               (::hitemDrag:oParent:handle == ::hitemDrop:oParent:handle)
               IF ::FindChildPos(::hitemDrop:oParent, ::hitemDrag:handle) > ::FindChildPos(::hitemDrop:oParent, ::hitemDrop:handle)
                  htiNext := ::hitemDrop //htiParent
               ELSE
                  htiPrev := ::hitemDrop  //htiParent
               ENDIF
            ELSE
            ENDIF
         ENDIF
      ENDIF
      // fazr a arotina para copias os nodos filhos ao arrastar
      IF !hwg_IsCtrlShift(.T.)
         IF ::hitemDrop:oParent != NIL
            hitemNew := ::hitemDrop:oParent:AddNode(::hitemDrag:GetText(), htiPrev, htiNext, ::hitemDrag:bAction,, ::hitemDrag:lchecked, ::hitemDrag:bClick) //, ::hitemDrop:aImages)
         ELSE
            hitemNew := ::AddNode(::hitemDrag:GetText(), htiPrev, htiNext, ::hitemDrag:bAction, , ::hitemDrag:lchecked, ::hitemDrag:bClick) //, ::hitemDrop:aImages)
         ENDIF
         DragDropTree(::hitemDrag, hitemNew, ::hitemDrop) //htiParent)
      ELSEIF ::hitemDrop != NIL
         hitemNew := ::hitemDrop:AddNode(::hitemDrag:Title, htiPrev, htiNext, ::hitemDrag:bAction, , ::hitemDrag:lchecked, ::hitemDrag:bClick) //, ::hitemDrop:aImages)
         DragDropTree(::hitemDrag, hitemNew, ::hitemDrop)
      ENDIF
      hitemNew:cargo  := ::hitemDrag:cargo
      hitemNew:image1 := ::hitemDrag:image1
      hitemNew:image2 := ::hitemDrag:image2
      ::hitemDrag:delete()
      ::Select(hitemNew)

      IF hb_IsBlock(::bDrop)
         Eval(::bDrop, Self, hitemNew, ::hitemDrop)
      ENDIF

   ELSEIF ::lEditLabels .AND. ((msg == WM_LBUTTONDBLCLK .AND. ::bDblClick == NIL) .OR. msg == WM_CHAR)
      ::EditLabel(::oSelected)
      RETURN 0
   ENDIF
   RETURN -1


METHOD AddNode(cTitle, oPrev, oNext, bAction, aImages) CLASS HTree
   
   LOCAL oNode := HTreeNode():New(Self, NIL, oPrev, oNext, cTitle, bAction, aImages)

   ::lEmpty := .F.
   RETURN oNode

METHOD FindChild(h) CLASS HTree
   
   LOCAL aItems := ::aItems
   LOCAL i
   LOCAL alen := Len(aItems)
   LOCAL oNode

   FOR i := 1 TO alen
      IF aItems[i]:handle == h
         RETURN aItems[i]
      ELSEIF !Empty(aItems[i]:aItems)
         IF (oNode := aItems[i]:FindChild(h)) != NIL
            RETURN oNode
         ENDIF
      ENDIF
   NEXT
   RETURN NIL

METHOD FindChildPos(oNode, h) CLASS HTree
   
   LOCAL aItems := IIf(oNode == NIL, ::aItems, oNode:aItems)
   LOCAL i
   LOCAL alen := Len(aItems)

   FOR i := 1 TO alen
      IF aItems[i]:handle == h
         RETURN i
      ELSEIF .F. //!Empty(aItems[i]:aItems)
         RETURN ::FindChildPos(aItems[i], h)
      ENDIF
   NEXT
   RETURN 0

METHOD SearchString(cText, iNivel, oNode, inodo) CLASS HTree
   
   LOCAL aItems := IIf(oNode == NIL, ::aItems, oNode:aItems)
   Local i
   LOCAL alen := Len(aItems)
   LOCAL oNodeRet
   
   iNodo := IIf(inodo == NIL, 0, iNodo)
   FOR i := 1 TO aLen
      IF !Empty(aItems[i]:aItems) .AND. ;
         (oNodeRet := ::SearchString(cText, iNivel, aItems[i], iNodo)) != NIL
         RETURN oNodeRet
      ENDIF
      IF aItems[i]:Title = cText .AND. (iNivel == NIL .OR. aItems[i]:GetLevel() == iNivel)
         iNodo++ 
         RETURN aItems[i]
      ELSE
         iNodo++
      ENDIF
   NEXT
   RETURN NIL 

METHOD Clean() CLASS HTree

   ::lEmpty := .T.
   ReleaseTree(::aItems)
   hwg_SendMessage(::handle, TVM_DELETEITEM, 0, TVI_ROOT)
   ::aItems := {}

   RETURN NIL

METHOD ItemHeight(nHeight) CLASS HTree

   IF nHeight != NIL
      hwg_SendMessage(::handle, TVM_SETITEMHEIGHT, nHeight, 0)
   ELSE
      nHeight := hwg_SendMessage(::handle, TVM_GETITEMHEIGHT, 0, 0)
   ENDIF
   RETURN  nHeight

#if 0 // old code for reference (to be deleted)
METHOD Notify(lParam) CLASS HTree
   
   LOCAL nCode := hwg_GetNotifyCode(lParam)
   LOCAL oItem
   LOCAL cText
   LOCAL nAct
   LOCAL nHitem
   LOCAL leval
   LOCAL nkeyDown := hwg_GetNotifyKeyDown(lParam)
    
   IF ncode == NM_SETCURSOR .AND. ::lDragging
      ::hitemDrop := hwg_Tree_HitTest(::handle,,, @nAct)
      IF ::hitemDrop != NIL
         hwg_SendMessage(::handle, TVM_SELECTITEM, TVGN_DROPHILITE, ::hitemDrop:handle)
      ENDIF
   ENDIF

   IF nCode == TVN_SELCHANGING  //.AND. ::oitem != NIL // .OR. NCODE = -500

   ELSEIF nCode == TVN_SELCHANGED //.OR. nCode == TVN_ITEMCHANGEDW
      ::oItemOld := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_OLDPARAM)
      oItem := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         oItem:oTree:oSelected := oItem
         IF oItem != NIL .AND. !oItem:oTree:lEmpty
            IF oItem:bAction != NIL
               Eval(oItem:bAction, oItem, Self)
            ELSEIF oItem:oTree:bAction != NIL
               Eval(oItem:oTree:bAction, oItem, Self)
            ENDIF
            hwg_SendMessage(::handle, TVM_SETITEM, , oitem:handle)
         ENDIF
      ENDIF

   ELSEIF nCode == TVN_BEGINLABELEDIT .OR. nCode == TVN_BEGINLABELEDITW
      s_aEvents := aClone(::oParent:aEvents)
      ::oParent:AddEvent(0, IDOK, {||hwg_SendMessage(::handle, TVM_ENDEDITLABELNOW, 0, 0)})
      ::oParent:AddEvent(0, IDCANCEL, {||hwg_SendMessage(::handle, TVM_ENDEDITLABELNOW, 1, 0)})

      // RETURN 1

   ELSEIF nCode == TVN_ENDLABELEDIT .OR. nCode == TVN_ENDLABELEDITW
      IF !Empty(cText := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_EDIT))
         oItem := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_EDITPARAM)
         IF hb_IsObject(oItem)
            IF !(cText == oItem:GetText()) .AND. ;
               (oItem:oTree:bItemChange == NIL .OR. Eval(oItem:oTree:bItemChange, oItem, cText))
               hwg_TreeSetItem(oItem:oTree:handle, oItem:handle, TREE_SETITEM_TEXT, cText)
            ENDIF
         ENDIF
      ENDIF
      ::oParent:aEvents := s_aEvents

   ELSEIF nCode == TVN_ITEMEXPANDING .OR. nCode == TVN_ITEMEXPANDINGW
      oItem := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         IF ::bExpand != NIL
            RETURN IIf(Eval(oItem:oTree:bExpand, oItem, ;
                              hwg_CheckBit(hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_ACTION), TVE_EXPAND)), ;
                        0, 1)
         ENDIF
      ENDIF

   ELSEIF nCode == TVN_BEGINDRAG .AND. ::lDragDrop
      ::hitemDrag := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      ::lDragging := .T.

   ELSEIF nCode == TVN_KEYDOWN
      IF ::oItem:oTree:bKeyDown != NIL
         Eval(::oItem:oTree:bKeyDown, ::oItem, nKeyDown, Self)
      ENDIF

    ELSEIF nCode == NM_CLICK  //.AND. ::oitem != NIL // .AND. !::lEditLabels
       nHitem :=  hwg_Tree_GetNotify(lParam, 1)
       //nHitem :=  hwg_GetNotifyCode(lParam)
       oItem  := hwg_Tree_HitTest(::handle,,, @nAct)
       IF nAct == TVHT_ONITEMSTATEICON
          IF ::oItem == NIL .OR. oItem:handle != ::oitem:handle
            ::Select(oItem)
            ::oItem := oItem
         ENDIF
         IF hb_IsBlock(::bCheck)
            lEval := Eval(::bCheck, !::oItem:checked, ::oItem, Self)
         ENDIF
         IF lEval == NIL .OR. !Empty(lEval)
            MarkCheckTree(::oItem, IIf(::oItem:checked, 1, 2))
            RETURN 0
         ENDIF
         RETURN 1
      ELSEIF !::lEditLabels .AND. Empty(nHitem)
         IF !::oItem:oTree:lEmpty
            IF ::oItem:bClick != NIL
               Eval(::oItem:bClick, ::oItem, Self)
            ENDIF
         ENDIF
      ENDIF

   ELSEIF nCode == NM_DBLCLK
      IF hb_IsBlock(::bDblClick)
         oItem  := hwg_Tree_HitTest(::handle,,, @nAct)
         Eval(::bDblClick, oItem, Self, nAct)
      ENDIF
   ELSEIF nCode == NM_RCLICK
      IF hb_IsBlock(::bRClick)
         oItem  := hwg_Tree_HitTest(::handle,,, @nAct)
         Eval(::bRClick, oItem, Self, nAct)
      ENDIF

      /* working only windows 7
   ELSEIF nCode == - 24 .AND. ::oitem != NIL
      //nhitem := hwg_Tree_HitTest(::handle,,, @nAct)
      IF hb_IsBlock(::bCheck)
         lEval := Eval(::bCheck, !::oItem:checked, ::oItem, Self)
      ENDIF
      IF lEval == NIL .OR. !Empty(lEval)
         MarkCheckTree(::oItem, IIf(::oItem:checked, 1, 2))
      ELSE
         RETURN 1
      ENDIF
      */
   ENDIF

   IF hb_IsObject(oItem)
      ::oItem := oItem
   ENDIF
   RETURN 0
#else
METHOD Notify(lParam) CLASS HTree

   LOCAL nCode := hwg_GetNotifyCode(lParam)
   LOCAL oItem
   LOCAL cText
   LOCAL nAct
   LOCAL nHitem
   LOCAL leval
   LOCAL nkeyDown := hwg_GetNotifyKeyDown(lParam)

   SWITCH nCode

   CASE NM_SETCURSOR
      IF ::lDragging
         ::hitemDrop := hwg_Tree_HitTest(::handle,,, @nAct)
         IF ::hitemDrop != NIL
            hwg_SendMessage(::handle, TVM_SELECTITEM, TVGN_DROPHILITE, ::hitemDrop:handle)
         ENDIF
      ENDIF
      EXIT

   CASE TVN_SELCHANGING
      EXIT

   CASE TVN_SELCHANGED
      ::oItemOld := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_OLDPARAM)
      oItem := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         oItem:oTree:oSelected := oItem
         IF oItem != NIL .AND. !oItem:oTree:lEmpty
            IF oItem:bAction != NIL
               Eval(oItem:bAction, oItem, Self)
            ELSEIF oItem:oTree:bAction != NIL
               Eval(oItem:oTree:bAction, oItem, Self)
            ENDIF
            hwg_SendMessage(::handle, TVM_SETITEM, , oitem:handle)
         ENDIF
      ENDIF
      EXIT

   CASE TVN_BEGINLABELEDIT
   CASE TVN_BEGINLABELEDITW
      s_aEvents := aClone(::oParent:aEvents)
      ::oParent:AddEvent(0, IDOK, {||hwg_SendMessage(::handle, TVM_ENDEDITLABELNOW, 0, 0)})
      ::oParent:AddEvent(0, IDCANCEL, {||hwg_SendMessage(::handle, TVM_ENDEDITLABELNOW, 1, 0)})
      // RETURN 1
      EXIT

   CASE TVN_ENDLABELEDIT
   CASE TVN_ENDLABELEDITW
      IF !Empty(cText := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_EDIT))
         oItem := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_EDITPARAM)
         IF hb_IsObject(oItem)
            IF !(cText == oItem:GetText()) .AND. ;
               (oItem:oTree:bItemChange == NIL .OR. Eval(oItem:oTree:bItemChange, oItem, cText))
               hwg_TreeSetItem(oItem:oTree:handle, oItem:handle, TREE_SETITEM_TEXT, cText)
            ENDIF
         ENDIF
      ENDIF
      ::oParent:aEvents := s_aEvents
      EXIT

   CASE TVN_ITEMEXPANDING
   CASE TVN_ITEMEXPANDINGW
      oItem := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         IF ::bExpand != NIL
            RETURN IIf(Eval(oItem:oTree:bExpand, oItem, ;
                            hwg_CheckBit(hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_ACTION), TVE_EXPAND)), ;
                       0, 1)
         ENDIF
      ENDIF
      EXIT

   CASE TVN_BEGINDRAG
      IF ::lDragDrop
         ::hitemDrag := hwg_Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
         ::lDragging := .T.
      ENDIF
      EXIT

   CASE TVN_KEYDOWN
      IF ::oItem:oTree:bKeyDown != NIL
         Eval(::oItem:oTree:bKeyDown, ::oItem, nKeyDown, Self)
      ENDIF
      EXIT

   CASE NM_CLICK
      nHitem :=  hwg_Tree_GetNotify(lParam, 1)
      //nHitem :=  hwg_GetNotifyCode(lParam)
      oItem  := hwg_Tree_HitTest(::handle,,, @nAct)
      IF nAct == TVHT_ONITEMSTATEICON
         IF ::oItem == NIL .OR. oItem:handle != ::oitem:handle
            ::Select(oItem)
            ::oItem := oItem
         ENDIF
         IF hb_IsBlock(::bCheck)
            lEval := Eval(::bCheck, !::oItem:checked, ::oItem, Self)
         ENDIF
         IF lEval == NIL .OR. !Empty(lEval)
            MarkCheckTree(::oItem, IIf(::oItem:checked, 1, 2))
            RETURN 0
         ENDIF
         RETURN 1
      ELSEIF !::lEditLabels .AND. Empty(nHitem)
         IF !::oItem:oTree:lEmpty
            IF ::oItem:bClick != NIL
               Eval(::oItem:bClick, ::oItem, Self)
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE NM_DBLCLK
      IF hb_IsBlock(::bDblClick)
         oItem := hwg_Tree_HitTest(::handle,,, @nAct)
         Eval(::bDblClick, oItem, Self, nAct)
      ENDIF
      EXIT

   CASE NM_RCLICK
      IF hb_IsBlock(::bRClick)
         oItem := hwg_Tree_HitTest(::handle,,, @nAct)
         Eval(::bRClick, oItem, Self, nAct)
      ENDIF

   ENDSWITCH

   IF hb_IsObject(oItem)
      ::oItem := oItem
   ENDIF

RETURN 0
#endif

METHOD Selecteds(oItem, aSels) CLASS HTree
   
   LOCAL i
   LOCAL iLen
   LOCAL aSelecteds := IIf(aSels == NIL, {}, aSels)

   oItem := IIf(oItem == NIL, Self, oItem)
   iLen :=  Len(oItem:aitems)

   FOR i := 1 TO iLen
      IF oItem:aItems[i]:checked
         AAdd(aSelecteds, oItem:aItems[i])
      ENDIF
      ::Selecteds(oItem:aItems[i], aSelecteds)
   NEXT
   RETURN aSelecteds

METHOD Expand(oNode, lAllNode) CLASS HTree
   
   LOCAL i
   LOCAL iLen := Len(oNode:aitems)
   
   hwg_SendMessage(::handle, TVM_EXPAND, TVE_EXPAND, oNode:handle)
   FOR i := 1 TO iLen
      IF !Empty(lAllNode) .AND. Len(oNode:aitems) > 0
         ::Expand(oNode:aItems[i], lAllNode)
      ENDIF
   NEXT
   hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_FRAME + RDW_INVALIDATE)
   RETURN NIL

STATIC PROCEDURE ReleaseTree(aItems)
   
   LOCAL i
   LOCAL iLen := Len(aItems)

   FOR i := 1 TO iLen
      hwg_Tree_ReleaseNode(aItems[i]:oTree:handle, aItems[i]:handle)
      ReleaseTree(aItems[i]:aItems)
      // hwg_DecreaseHolders(aItems[i]:handle)
   NEXT

   RETURN

STATIC PROCEDURE MarkCheckTree(oItem, state)
   
   LOCAL i
   LOCAL iLen := Len(oItem:aitems)
   LOCAL oParent

   FOR i := 1 TO iLen
      hwg_TreeSetItem(oItem:oTree:handle, oItem:aitems[i]:handle, TREE_SETITEM_CHECK, state)
      MarkCheckTree(oItem:aItems[i], state)
   NEXT
   IF state == 1
      oParent := oItem:oParent
      DO WHILE oParent != NIL
         hwg_TreeSetItem(oItem:oTree:handle, oParent:handle, TREE_SETITEM_CHECK, state)
         oParent := oParent:oParent
      ENDDO
   ENDIF
   RETURN 


STATIC PROCEDURE DragDropTree(oDrag, oItem, oDrop)
   
   LOCAL i
   LOCAL iLen := Len(oDrag:aitems)
   LOCAL hitemNew

   FOR i := 1 TO iLen
      hitemNew := oItem:AddNode(oDrag:aItems[i]:GetText(), , , oDrag:aItems[i]:bAction, , oDrag:aItems[i]:lchecked, oDrag:aItems[i]:bClick) //, ::hitemDrop:aImages)
      hitemNew:oTree  := oDrag:aItems[i]:oTree
      hitemNew:cargo := oDrag:aItems[i]:cargo
      hitemNew:image1 := oDrag:aItems[i]:image1
      hitemNew:image2 := oDrag:aItems[i]:image2
      IF Len(oDrag:aitems[i]:aitems) > 0
         DragDropTree(oDrag:aItems[i], hitemNew, oDrop)
      ENDIF
      //oDrag:aItems[i]:delete()
   NEXT
   RETURN