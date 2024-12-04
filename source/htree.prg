//
// $Id: htree.prg 1895 2012-09-12 11:56:05Z lfbasso $
//
// HWGUI - Harbour Win32 GUI library source code:
// HTree class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define TVM_DELETEITEM       4353   // (TV_FIRST + 1) 0x1101
#define TVM_EXPAND           4354   // (TV_FIRST + 2)
#define TVM_SETIMAGELIST     4361   // (TV_FIRST + 9)
#define TVM_GETNEXTITEM      4362   // (TV_FIRST + 10)
#define TVM_SELECTITEM       4363   // (TV_FIRST + 11)
#define TVM_EDITLABEL        4366   // (TV_FIRST + 14)
#define TVM_GETEDITCONTROL   4367   // (TV_FIRST + 15)
#define TVM_ENDEDITLABELNOW  4374   //(TV_FIRST + 22)
#define TVM_GETITEMSTATE     4391   // (TV_FIRST + 39)
#define TVM_SETITEM          4426   // (TV_FIRST + 63)
#define TVM_SETITEMHEIGHT    4379   // (TV_FIRST + 27)
#define TVM_GETITEMHEIGHT    4380
#define TVM_SETLINECOLOR     4392 

#define TVE_COLLAPSE            0x0001
#define TVE_EXPAND              0x0002
#define TVE_TOGGLE              0x0003

#define TVSIL_NORMAL            0

#define TVGN_ROOT               0   // 0x0000
#define TVGN_NEXT               1   // 0x0001
#define TVGN_PREVIOUS           2   // 0x0002
#define TVGN_PARENT             3   // 0x0003
#define TVGN_CHILD              4   // 0x0004
#define TVGN_FIRSTVISIBLE       5   // 0x0005
#define TVGN_NEXTVISIBLE        6   // 0x0006
#define TVGN_PREVIOUSVISIBLE    7   // 0x0007
#define TVGN_DROPHILITE         8   // 0x0008
#define TVGN_CARET              9   // 0x0009
#define TVGN_LASTVISIBLE       10   // 0x000A

#define TVIS_STATEIMAGEMASK    61440

#define TVN_SELCHANGING      (-401) // (TVN_FIRST-1)
#define TVN_SELCHANGED       (-402)
#define TVN_GETDISPINFO      (-403)
#define TVN_SETDISPINFO      (-404)
#define TVN_ITEMEXPANDING    (-405)
#define TVN_ITEMEXPANDED     (-406)
#define TVN_BEGINDRAG        (-407)
#define TVN_BEGINRDRAG       (-408)
#define TVN_DELETEITEM       (-409)
#define TVN_BEGINLABELEDIT   (-410)
#define TVN_ENDLABELEDIT     (-411)
#define TVN_KEYDOWN          (-412)
#define TVN_ITEMCHANGINGA    (-416)
#define TVN_ITEMCHANGINGW    (-417)
#define TVN_ITEMCHANGEDA     (-418)
#define TVN_ITEMCHANGEDW     (-419)


#define TVN_SELCHANGEDW       (-451)
#define TVN_ITEMEXPANDINGW    (-454)
#define TVN_BEGINLABELEDITW   (-459)
#define TVN_ENDLABELEDITW     (-460)

#define TVI_ROOT              (-65536)

#define TREE_GETNOTIFY_HANDLE       1
#define TREE_GETNOTIFY_PARAM        2
#define TREE_GETNOTIFY_EDIT         3
#define TREE_GETNOTIFY_EDITPARAM    4
#define TREE_GETNOTIFY_ACTION       5
#define TREE_GETNOTIFY_OLDPARAM     6

#define TREE_SETITEM_TEXT           1
#define TREE_SETITEM_CHECK          2

//#define  NM_CLICK               - 2
#define  NM_DBLCLK               - 3
#define  NM_RCLICK               - 5
#define  NM_KILLFOCUS            - 8
#define  NM_SETCURSOR            - 17    // uses NMMOUSE struct
#define  NM_CHAR                 - 18   // uses NMCHAR struct

Static s_aEvents

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
   METHOD GetText() INLINE TreeGetNodeText(::oTree:handle, ::handle)
   METHOD SetText(cText) INLINE TreeSetItem(::oTree:handle, ::handle, TREE_SETITEM_TEXT, cText), ::title := cText
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
            aImages[i] := IIf(oTree:Type, LoadBitmap(aImages[i]), OpenBitmap(aImages[i]))
            Imagelist_Add(oTree:himl, aImages[i])
            h := Len(oTree:aImages)
         ENDIF
         h --
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
   ::handle := TreeAddNode(Self, oTree:handle,               ;
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
   tree_ReleaseNode(::oTree:handle, ::handle)
   SendMessage(::oTree:handle, TVM_DELETEITEM, 0, ::handle)
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
      TreeSetItem(::oTree:handle, ::handle, TREE_SETITEM_CHECK, IIf(lChecked, 2, 1))
      ::lChecked := lChecked
   ELSE
      state := SendMessage(::oTree:handle, TVM_GETITEMSTATE, ::handle,, TVIS_STATEIMAGEMASK) - 1
      ::lChecked := int(state / 4092) == 2
   ENDIF
   RETURN ::lChecked

METHOD GetLevel(h) CLASS HTreeNode
   
   LOCAL iLevel := 1
   LOCAL oNode := IIf(Empty(h), Self, h)

   DO WHILE (oNode:oParent) != NIL
       oNode := oNode:oParent
       iLevel ++
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
   METHOD GetSelected() INLINE IIf(hb_IsObject(::oItem := TreeGetSelected(::handle)), ::oItem, NIL)
   METHOD EditLabel(oNode) BLOCK {|Self, o|SendMessage(::handle, TVM_EDITLABEL, 0, o:handle)}
   METHOD Expand(oNode, lAllNode)   //BLOCK {|Self, o|SendMessage(::handle, TVM_EXPAND, TVE_EXPAND, o:handle), RedrawWindow(::handle, RDW_NOERASE + RDW_FRAME + RDW_INVALIDATE)}
   METHOD Select(oNode) BLOCK {|Self, o|SendMessage(::handle, TVM_SELECTITEM, TVGN_CARET, o:handle), ::oItem := TreeGetSelected(::handle)}
   METHOD Clean()
   METHOD Notify(lParam)
   METHOD END() INLINE (::Super:END(), ReleaseTree(::aItems))
   METHOD isExpand(oNodo) INLINE !CheckBit(oNodo, TVE_EXPAND)
   METHOD onEvent(msg, wParam, lParam)
   METHOD ItemHeight(nHeight) SETGET
   METHOD SearchString(cText, iNivel, oNode, inodo)
   METHOD Selecteds(oItem, aSels)
   METHOD Top() INLINE IIf(!Empty(::aItems), (::Select(::aItems[1]), SendMessage(::handle, WM_VSCROLL, MAKEWPARAM(0, SB_TOP), NIL)),)
   METHOD Bottom() INLINE IIf(!Empty(::aItems), (::Select(::aItems[Len(::aItems)]), SendMessage(::handle, WM_VSCROLL, MAKEWPARAM(0, SB_BOTTOM), NIL)),)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, color, bcolor, ;
            aImages, lResour, lEditLabels, bAction, nBC, bRClick, bDblClick, lcheckbox, bCheck, lDragDrop, bDrag, bDrop, bOther) CLASS HTree
   
   LOCAL i
   LOCAL aBmpSize

   lEditLabels := IIf(lEditLabels == NIL, .F., lEditLabels)
   lCheckBox   := IIf(lCheckBox == NIL, .F., lCheckBox)
   lDragDrop   := IIf(lDragDrop == NIL, .F., lDragDrop)

   nStyle   := Hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP  + TVS_FULLROWSELECT + TVS_TRACKSELECT+; //TVS_HASLINES +  ;
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
         aImages[i] := IIf(lResour != NIL .AND. lResour, LoadBitmap(aImages[i]), OpenBitmap(aImages[i]))
      NEXT
      aBmpSize := GetBitmapSize(aImages[1])
      ::himl := CreateImageList(aImages, aBmpSize[1], aBmpSize[2], 12, nBC)
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
      SetWindowObject(::handle, Self)
      Hwg_InitTreeView(::handle)
      IF ::himl != NIL
         SendMessage(::handle, TVM_SETIMAGELIST, TVSIL_NORMAL, ::himl)
      ENDIF

   ENDIF

   RETURN NIL

METHOD Activate() CLASS HTree

   IF !Empty(::oParent:handle)
      ::handle := CreateTree(::oParent:handle, ::id, ;
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
      IF ProcKeyList(Self, wParam)
         RETURN 0
      ENDIF

   ELSEIF msg == WM_LBUTTONDOWN

   ELSEIF msg == WM_LBUTTONUP .AND. ::lDragging .AND. ::hitemDrop != NIL
      ::lDragging := .F.
      SendMessage(::handle, TVM_SELECTITEM, TVGN_DROPHILITE, NIL)

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
         IF !IsCtrlShift(.T.)
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
      IF !IsCtrlShift(.T.)
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
         iNodo ++ 
         RETURN aItems[i]
      ELSE
         iNodo ++   
      ENDIF
   NEXT
   RETURN NIL 

METHOD Clean() CLASS HTree

   ::lEmpty := .T.
   ReleaseTree(::aItems)
   SendMessage(::handle, TVM_DELETEITEM, 0, TVI_ROOT)
   ::aItems := {}

   RETURN NIL

METHOD ItemHeight(nHeight) CLASS HTree

   IF nHeight != NIL
      SendMessage(::handle, TVM_SETITEMHEIGHT, nHeight, 0)
   ELSE
      nHeight := SendMessage(::handle, TVM_GETITEMHEIGHT, 0, 0)
   ENDIF
   RETURN  nHeight

#if 0 // old code for reference (to be deleted)
METHOD Notify(lParam) CLASS HTree
   
   LOCAL nCode := GetNotifyCode(lParam)
   LOCAL oItem
   LOCAL cText
   LOCAL nAct
   LOCAL nHitem
   LOCAL leval
   LOCAL nkeyDown := GetNotifyKeydown(lParam)
    
   IF ncode == NM_SETCURSOR .AND. ::lDragging
      ::hitemDrop := tree_Hittest(::handle,,, @nAct)
      IF ::hitemDrop != NIL
         SendMessage(::handle, TVM_SELECTITEM, TVGN_DROPHILITE, ::hitemDrop:handle)
      ENDIF
   ENDIF

   IF nCode == TVN_SELCHANGING  //.AND. ::oitem != NIL // .OR. NCODE = -500

   ELSEIF nCode == TVN_SELCHANGED //.OR. nCode == TVN_ITEMCHANGEDW
      ::oItemOld := Tree_GetNotify(lParam, TREE_GETNOTIFY_OLDPARAM)
      oItem := Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         oItem:oTree:oSelected := oItem
         IF oItem != NIL .AND. !oItem:oTree:lEmpty
            IF oItem:bAction != NIL
               Eval(oItem:bAction, oItem, Self)
            ELSEIF oItem:oTree:bAction != NIL
               Eval(oItem:oTree:bAction, oItem, Self)
            ENDIF
            SendMessage(::handle, TVM_SETITEM, , oitem:handle)
         ENDIF
      ENDIF

   ELSEIF nCode == TVN_BEGINLABELEDIT .OR. nCode == TVN_BEGINLABELEDITW
      s_aEvents := aClone(::oParent:aEvents)
      ::oParent:AddEvent(0, IDOK, {||SendMessage(::handle, TVM_ENDEDITLABELNOW, 0, 0)})
      ::oParent:AddEvent(0, IDCANCEL, {||SendMessage(::handle, TVM_ENDEDITLABELNOW, 1, 0)})

      // RETURN 1

   ELSEIF nCode == TVN_ENDLABELEDIT .OR. nCode == TVN_ENDLABELEDITW
      IF !Empty(cText := Tree_GetNotify(lParam, TREE_GETNOTIFY_EDIT))
         oItem := Tree_GetNotify(lParam, TREE_GETNOTIFY_EDITPARAM)
         IF hb_IsObject(oItem)
            IF !(cText == oItem:GetText()) .AND. ;
               (oItem:oTree:bItemChange == NIL .OR. Eval(oItem:oTree:bItemChange, oItem, cText))
               TreeSetItem(oItem:oTree:handle, oItem:handle, TREE_SETITEM_TEXT, cText)
            ENDIF
         ENDIF
      ENDIF
      ::oParent:aEvents := s_aEvents

   ELSEIF nCode == TVN_ITEMEXPANDING .OR. nCode == TVN_ITEMEXPANDINGW
      oItem := Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         IF ::bExpand != NIL
            RETURN IIf(Eval(oItem:oTree:bExpand, oItem, ;
                              CheckBit(Tree_GetNotify(lParam, TREE_GETNOTIFY_ACTION), TVE_EXPAND)), ;
                        0, 1)
         ENDIF
      ENDIF

   ELSEIF nCode == TVN_BEGINDRAG .AND. ::lDragDrop
      ::hitemDrag := Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      ::lDragging := .T.

   ELSEIF nCode == TVN_KEYDOWN
      IF ::oItem:oTree:bKeyDown != NIL
         Eval(::oItem:oTree:bKeyDown, ::oItem, nKeyDown, Self)
      ENDIF

    ELSEIF nCode == NM_CLICK  //.AND. ::oitem != NIL // .AND. !::lEditLabels
       nHitem :=  Tree_GetNotify(lParam, 1)
       //nHitem :=  GETNOTIFYcode(lParam)
       oItem  := tree_Hittest(::handle,,, @nAct)
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
         oItem  := tree_Hittest(::handle,,, @nAct)
         Eval(::bDblClick, oItem, Self, nAct)
      ENDIF
   ELSEIF nCode == NM_RCLICK
      IF hb_IsBlock(::bRClick)
         oItem  := tree_Hittest(::handle,,, @nAct)
         Eval(::bRClick, oItem, Self, nAct)
      ENDIF

      /* working only windows 7
   ELSEIF nCode == - 24 .AND. ::oitem != NIL
      //nhitem := tree_Hittest(::handle,,, @nAct)
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

   LOCAL nCode := GetNotifyCode(lParam)
   LOCAL oItem
   LOCAL cText
   LOCAL nAct
   LOCAL nHitem
   LOCAL leval
   LOCAL nkeyDown := GetNotifyKeydown(lParam)

   SWITCH nCode

   CASE NM_SETCURSOR
      IF ::lDragging
         ::hitemDrop := tree_Hittest(::handle,,, @nAct)
         IF ::hitemDrop != NIL
            SendMessage(::handle, TVM_SELECTITEM, TVGN_DROPHILITE, ::hitemDrop:handle)
         ENDIF
      ENDIF
      EXIT

   CASE TVN_SELCHANGING
      EXIT

   CASE TVN_SELCHANGED
      ::oItemOld := Tree_GetNotify(lParam, TREE_GETNOTIFY_OLDPARAM)
      oItem := Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         oItem:oTree:oSelected := oItem
         IF oItem != NIL .AND. !oItem:oTree:lEmpty
            IF oItem:bAction != NIL
               Eval(oItem:bAction, oItem, Self)
            ELSEIF oItem:oTree:bAction != NIL
               Eval(oItem:oTree:bAction, oItem, Self)
            ENDIF
            SendMessage(::handle, TVM_SETITEM, , oitem:handle)
         ENDIF
      ENDIF
      EXIT

   CASE TVN_BEGINLABELEDIT
   CASE TVN_BEGINLABELEDITW
      s_aEvents := aClone(::oParent:aEvents)
      ::oParent:AddEvent(0, IDOK, {||SendMessage(::handle, TVM_ENDEDITLABELNOW, 0, 0)})
      ::oParent:AddEvent(0, IDCANCEL, {||SendMessage(::handle, TVM_ENDEDITLABELNOW, 1, 0)})
      // RETURN 1
      EXIT

   CASE TVN_ENDLABELEDIT
   CASE TVN_ENDLABELEDITW
      IF !Empty(cText := Tree_GetNotify(lParam, TREE_GETNOTIFY_EDIT))
         oItem := Tree_GetNotify(lParam, TREE_GETNOTIFY_EDITPARAM)
         IF hb_IsObject(oItem)
            IF !(cText == oItem:GetText()) .AND. ;
               (oItem:oTree:bItemChange == NIL .OR. Eval(oItem:oTree:bItemChange, oItem, cText))
               TreeSetItem(oItem:oTree:handle, oItem:handle, TREE_SETITEM_TEXT, cText)
            ENDIF
         ENDIF
      ENDIF
      ::oParent:aEvents := s_aEvents
      EXIT

   CASE TVN_ITEMEXPANDING
   CASE TVN_ITEMEXPANDINGW
      oItem := Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
      IF hb_IsObject(oItem)
         IF ::bExpand != NIL
            RETURN IIf(Eval(oItem:oTree:bExpand, oItem, ;
                            CheckBit(Tree_GetNotify(lParam, TREE_GETNOTIFY_ACTION), TVE_EXPAND)), ;
                       0, 1)
         ENDIF
      ENDIF
      EXIT

   CASE TVN_BEGINDRAG
      IF ::lDragDrop
         ::hitemDrag := Tree_GetNotify(lParam, TREE_GETNOTIFY_PARAM)
         ::lDragging := .T.
      ENDIF
      EXIT

   CASE TVN_KEYDOWN
      IF ::oItem:oTree:bKeyDown != NIL
         Eval(::oItem:oTree:bKeyDown, ::oItem, nKeyDown, Self)
      ENDIF
      EXIT

   CASE NM_CLICK
      nHitem :=  Tree_GetNotify(lParam, 1)
      //nHitem :=  GETNOTIFYcode(lParam)
      oItem  := tree_Hittest(::handle,,, @nAct)
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
         oItem := tree_Hittest(::handle,,, @nAct)
         Eval(::bDblClick, oItem, Self, nAct)
      ENDIF
      EXIT

   CASE NM_RCLICK
      IF hb_IsBlock(::bRClick)
         oItem := tree_Hittest(::handle,,, @nAct)
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
   
   SendMessage(::handle, TVM_EXPAND, TVE_EXPAND, oNode:handle)
   FOR i := 1 TO iLen
      IF !Empty(lAllNode) .AND. Len(oNode:aitems) > 0
         ::Expand(oNode:aItems[i], lAllNode)
      ENDIF
   NEXT
   RedrawWindow(::handle, RDW_NOERASE + RDW_FRAME + RDW_INVALIDATE)
   RETURN NIL

STATIC PROCEDURE ReleaseTree(aItems)
   
   LOCAL i
   LOCAL iLen := Len(aItems)

   FOR i := 1 TO iLen
      tree_ReleaseNode(aItems[i]:oTree:handle, aItems[i]:handle)
      ReleaseTree(aItems[i]:aItems)
      // hwg_DecreaseHolders(aItems[i]:handle)
   NEXT

   RETURN

STATIC PROCEDURE MarkCheckTree(oItem, state)
   
   LOCAL i
   LOCAL iLen := Len(oItem:aitems)
   LOCAL oParent

   FOR i := 1 TO iLen
      TreeSetItem(oItem:oTree:handle, oItem:aitems[i]:handle, TREE_SETITEM_CHECK, state)
      MarkCheckTree(oItem:aItems[i], state)
   NEXT
   IF state == 1
      oParent := oItem:oParent
      DO WHILE oParent != NIL
         TreeSetItem(oItem:oTree:handle, oParent:handle, TREE_SETITEM_CHECK, state)
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