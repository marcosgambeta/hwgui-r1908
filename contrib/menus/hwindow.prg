/*
 *$Id: hwindow.prg 1615 2011-02-18 13:53:35Z mlacecilia $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * Window class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://www.geocities.com/alkresin/
*/

#include "windows.ch"
#include <HBClass.ch>
#include "guilib.ch"

#define  FIRST_MDICHILD_ID     501
#define  MAX_MDICHILD_WINDOWS   18
#define  WM_NOTIFYICON         WM_USER+1000
#define  ID_NOTIFYICON           1

#define WM_MENUSELECT   287
#define MF_HILITE       128

CLASS HObject
   // DATA classname
ENDCLASS

CLASS HCustomWindow INHERIT HObject
   CLASS VAR oDefaultParent SHARED
   DATA handle  INIT 0
   DATA oParent
   DATA title
   DATA type
   DATA nTop, nLeft, nWidth, nHeight
   DATA tcolor, bcolor, brush
   DATA style
   DATA extStyle  INIT 0
   DATA lHide INIT .F.
   DATA oFont
   DATA aEvents   INIT {}
   DATA aNotify   INIT {}
   DATA aControls INIT {}
   DATA bInit
   DATA bDestroy
   DATA bSize
   DATA bPaint
   DATA bGetFocus
   DATA bLostFocus
   DATA bOther
   DATA cargo
   
   METHOD AddControl(oCtrl) INLINE AAdd(::aControls, oCtrl)
   METHOD DelControl(oCtrl)
   METHOD AddEvent(nEvent, nId, bAction, lNotify) ;
      INLINE AAdd(IIf(lNotify == NIL .OR. !lNotify, ::aEvents, ::aNotify), {nEvent, nId, bAction})
   METHOD FindControl(nId, nHandle)
   METHOD Hide() INLINE (::lHide:=.T., hwg_HideWindow(::handle))
   METHOD Show() INLINE (::lHide:=.F., hwg_ShowWindow(::handle))
   METHOD Restore() INLINE hwg_SendMessage(::handle,  WM_SYSCOMMAND, SC_RESTORE, 0)
   METHOD Maximize() INLINE hwg_SendMessage(::handle,  WM_SYSCOMMAND, SC_MAXIMIZE, 0)
   METHOD Minimize() INLINE hwg_SendMessage(::handle,  WM_SYSCOMMAND, SC_MINIMIZE, 0)
ENDCLASS

METHOD FindControl(nId, nHandle) CLASS HCustomWindow
Local i := IIf(nId != NIL, AScan(::aControls, {|o|o:id == nId}), ;
                       AScan(::aControls, {|o|o:handle == nHandle}))
RETURN IIf(i == 0, NIL, ::aControls[i])

METHOD DelControl(oCtrl) CLASS HCustomWindow
Local h := oCtrl:handle
Local i := Ascan(::aControls, {|o|o:handle == h})

   hwg_SendMessage(h, WM_CLOSE, 0, 0)
   IF i != 0
      Adel(::aControls, i)
      ASize(::aControls, Len(::aControls) - 1)
   ENDIF
RETURN NIL

CLASS HWindow INHERIT HCustomWindow

   CLASS VAR aWindows   INIT {}
   CLASS VAR szAppName  SHARED INIT "HwGUI_App"

   DATA menu, nMenuPos, oPopup, hAccel
   DATA oIcon, oBmp
   DATA oNotifyIcon, bNotify, oNotifyMenu
   DATA lClipper
   DATA lTray INIT .F.
   DATA aOffset
   DATA lMaximize INIT .F.

   METHOD New(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, oFont, ;
          bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, cAppName, oBmp, lMaximize)
   METHOD Activate(lShow)
   METHOD InitTray(oNotifyIcon, bNotify, oNotifyMenu)
   METHOD AddItem(oWnd)
   METHOD DelItem(oWnd)
   METHOD FindWindow(hWnd)
   METHOD GetMain()
   METHOD GetMdiActive()
   METHOD Close()	INLINE hwg_EndWindow()
ENDCLASS

METHOD NEW(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, oFont, ;
                  bInit, bExit, bSize, ;
                  bPaint, bGfocus, bLfocus, bOther, cAppName, oBmp, lMaximize) CLASS HWindow
   Local hParent
   Local oWndClient

   // ::classname:= "HWINDOW"
   ::oDefaultParent := Self
   ::type     := lType
   ::title    := cTitle
   ::style    := IIf(nStyle == NIL, 0, nStyle)
   ::nMenuPos := nPos
   ::oIcon    := oIcon
   ::oBmp     := oBmp
   ::nTop     := IIf(y == NIL, 0, y)
   ::nLeft    := IIf(x == NIL, 0, x)
   ::nWidth   := IIf(width == NIL, 0, width)
   ::nHeight  := IIf(height == NIL, 0, height)
   ::oFont    := oFont
   ::bInit    := bInit
   ::bDestroy := bExit
   ::bSize    := bSize
   ::bPaint   := bPaint
   ::bGetFocus  := bGFocus
   ::bLostFocus := bLFocus
   ::bOther     := bOther
   ::lMaximize  := lMaximize
   IF cAppName != NIL
      ::szAppName := cAppName
   ENDIF
   // ::lClipper   := IIf(lClipper == NIL, .F., lClipper)
   ::aOffset := Array(4)
   Afill(::aOffset, 0)

   ::AddItem(Self)
   IF lType == WND_MAIN

      ::handle := hwg_InitMainWindow(::szAppName, cTitle, cMenu,    ;
              IIf(oIcon != NIL, oIcon:handle, NIL), IIf(oBmp != NIL, -1, clr), ::Style, ::nLeft, ;
              ::nTop, ::nWidth, ::nHeight)

   ELSEIF lType == WND_MDI

      // Register MDI frame  class
      // Create   MDI frame  window -> aWindows[0]
      hwg_InitMdiWindow(::szAppName, cTitle, cMenu,  ;
              IIf(oIcon != NIL, oIcon:handle, NIL), clr, ;
              nStyle, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::handle = hwg_GetWindowHandle(1)

   ELSEIF lType == WND_CHILD // Janelas modeless que pertencem a MAIN - jamaj

      ::oParent := HWindow():GetMain()
      IF HB_IsObject(::oParent)
          ::handle := hwg_InitChildWindow(::szAppName, cTitle, cMenu,    ;
             IIf(oIcon != NIL, oIcon:handle, NIL), IIf(oBmp != NIL, -1, clr), nStyle, ::nLeft, ;
             ::nTop, ::nWidth, ::nHeight, ::oParent:handle)
      Else
          hwg_MsgStop("Nao eh possivel criar CHILD sem primeiro criar MAIN")
          RETURN (NIL)
      Endif

   ELSEIF lType == WND_MDICHILD //
      ::szAppName := "MDICHILD" + Alltrim(Str(hwg_GETNUMWINDOWS()))
      // Registra a classe
      hwg_InitMdiChildWindow(::szAppName , cTitle, cMenu,  ;
              IIf(oIcon != NIL, oIcon:handle, NIL), clr, ;
              nStyle, ::nLeft, ::nTop, ::nWidth, ::nHeight)

       // Cria a window
       ::handle := hwg_CreateMdiChildWindow(Self)
       // Janela pai = janela cliente MDI
       oWndClient := HWindow():FindWindow(hwg_GetWindowHandle(2))
       ::oParent := oWndClient

   ENDIF

RETURN Self
// Alterado por jamaj - added WND_CHILD support
METHOD Activate(lShow) CLASS HWindow
   Local oWndClient
   Local oWnd := SELF

   IF ::type == WND_MDICHILD


   ELSEIF ::type == WND_MDI
      hwg_InitClientWindow(oWnd:nMenuPos, oWnd:nLeft, oWnd:nTop+60, oWnd:nWidth, oWnd:nHeight)

      oWndClient := HWindow():New(0,,, oWnd:style, oWnd:title,, oWnd:nMenuPos, oWnd:bInit, oWnd:bDestroy, oWnd:bSize, ;
                              oWnd:bPaint, oWnd:bGetFocus, oWnd:bLostFocus, oWnd:bOther)

      oWndClient:handle := hwg_GetWindowHandle(2)
      oWndClient:oParent:= HWindow():GetMain()

      hwg_ActivateMdiWindow((lShow == NIL .OR. lShow), ::hAccel)
   ELSEIF ::type == WND_MAIN
      hwg_ActivateMainWindow((lShow == NIL .OR. lShow), ::hAccel)
   ELSEIF ::type == WND_CHILD
      hwg_ActivateChildWindow(::handle)
   Else
      
   ENDIF

RETURN NIL

METHOD InitTray(oNotifyIcon, bNotify, oNotifyMenu, cTooltip) CLASS HWindow

   ::bNotify     := bNotify
   ::oNotifyMenu := oNotifyMenu
   ::oNotifyIcon := oNotifyIcon
   hwg_ShellNotifyIcon(.T., ::handle, oNotifyIcon:handle, cTooltip)
   ::lTray := .T.

RETURN NIL

METHOD AddItem(oWnd) CLASS HWindow
   AAdd(::aWindows, oWnd)
RETURN NIL

METHOD DelItem(oWnd) CLASS HWindow
Local i, h := oWnd:handle
   IF (i := Ascan(::aWindows, {|o|o:handle == h})) > 0
      Adel(::aWindows, i)
      ASize(::aWindows, Len(::aWindows) - 1)
   ENDIF
RETURN NIL

METHOD FindWindow(hWnd) CLASS HWindow
Local i := Ascan(::aWindows, {|o|o:handle == hWnd})
RETURN IIf(i == 0, NIL, ::aWindows[i])

METHOD GetMain CLASS HWindow
RETURN IIf(Len(::aWindows) > 0,              ;
	 IIf(::aWindows[1]:type == WND_MAIN, ;
	   ::aWindows[1],                  ;
	   IIf(Len(::aWindows) > 1, ::aWindows[2], NIL)), NIL)

METHOD GetMdiActive() CLASS HWindow 
RETURN ::FindWindow (hwg_SendMessage(::GetMain():handle, WM_MDIGETACTIVE, 0, 0))

FUNCTION DefWndProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
Local iParHigh, iParLow
Local oWnd, oBtn, oitem

   // WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("DefWndProc -Inicio", 40) + "|")
   if (oWnd := HWindow():FindWindow(hWnd)) == NIL
      // hwg_MsgStop("Message: wrong window handle "+Str(hWnd)+"/"+Str(msg), "Error!")
      if msg == WM_CREATE
         if Len(HWindow():aWindows) != 0 .AND. ;
              (oWnd := HWindow():aWindows[Len(HWindow():aWindows)]) != NIL .AND. ;
              oWnd:handle == 0
            oWnd:handle := hWnd
            if oWnd:bInit != NIL
               Eval(oWnd:bInit, oWnd)
            endif
         endif
      endif
      RETURN -1
   endif
   if msg == WM_COMMAND
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - COMMAND", 40) + "|")
      if wParam == SC_CLOSE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0)
          endif
      elseif wParam == SC_RESTORE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0)
          endif
      elseif wParam == SC_MAXIMIZE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0)
          endif
      elseif wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
          nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
          hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0)
      endif
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
           (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
           Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
      ELSEIF HB_IsArray(oWnd:menu) .AND. ;
           (aMenu := hwg_FindMenuItem(oWnd:menu, iParLow, @iCont)) != NIL ;
           .AND. aMenu[1, iCont, 1] != NIL
         Eval(aMenu[1, iCont, 1])
      ELSEIF oWnd:oPopup != NIL .AND. ;
           (aMenu := hwg_FindMenuItem(oWnd:oPopup:aMenu, wParam, @iCont)) != NIL ;
           .AND. aMenu[1, iCont, 1] != NIL
         Eval(aMenu[1, iCont, 1])
      ELSEIF oWnd:oNotifyMenu != NIL .AND. ;
           (aMenu := hwg_FindMenuItem(oWnd:oNotifyMenu:aMenu, wParam, @iCont)) != NIL ;
           .AND. aMenu[1, iCont, 1] != NIL
         Eval(aMenu[1, iCont, 1])
      ENDIF
      RETURN 0
   elseif msg == WM_PAINT
      if oWnd:bPaint != NIL
         RETURN Eval(oWnd:bPaint, oWnd)
      endif
   elseif msg == WM_MOVE
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   elseif msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR each oItem in aControls
             IF oItem:bSize != NIL
                Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #else
         FOR iCont := 1 TO nControls
             IF aControls[iCont]:bSize != NIL
                Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #endif
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nWidth  := aControls[3]-aControls[1]
      oWnd:nHeight := aControls[4]-aControls[2]
      if HB_IsBlock(oWnd:bSize)
          Eval(oWnd:bSize, oWnd, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      endif
      if oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
          // writelog(str(hWnd)+"--"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          aControls := hwg_GetClientRect(hWnd)
          // writelog(str(hWnd)+"=="+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          hwg_MoveWindow(HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2], aControls[3]-oWnd:aOffset[1]-oWnd:aOffset[3], aControls[4]-oWnd:aOffset[2]-oWnd:aOffset[4])
          // aControls := hwg_GetClientRect(HWindow():aWindows[2]:handle)
          // writelog(str(HWindow():aWindows[2]:handle)+"::"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          RETURN 0
      endif
   elseif msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
   elseif msg == WM_ERASEBKGND
      if oWnd:oBmp != NIL
          hwg_SpreadBitmap(wParam, oWnd:handle, oWnd:oBmp:handle)
          RETURN 1
      endif
   elseif msg == WM_DRAWITEM

      if (oBtn := oWnd:FindControl(wParam)) != NIL
          if HB_IsBlock(oBtn:bPaint)
             Eval(oBtn:bPaint, oBtn, lParam)
          endif
      endif
   elseif msg == WM_NOTIFY
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - Notify", 40) + "|")
      RETURN DlgNotify(oWnd, wParam, lParam)
   elseif msg == WM_ENTERIDLE
      DlgEnterIdle(oWnd, wParam, lParam)

   elseif msg == WM_CLOSE
      hwg_ReleaseAllWindows(oWnd, hWnd)

   elseif msg == WM_DESTROY
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - DESTROY", 40) + "|")
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR EACH oItem IN aControls
             IF __ObjHasMsg(oItem, "END")
                oItem:End()
             ENDIF
         NEXT
      #else
         FOR i := 1 TO nControls
             IF __ObjHasMsg(aControls[i], "END")
                aControls[i]:End()
             ENDIF
         NEXT
      #endif
      HWindow():DelItem(oWnd)
      hwg_PostQuitMessage(0)
      RETURN 0
   elseif msg == WM_SYSCOMMAND
      if wParam == SC_CLOSE
          if HB_IsBlock(oWnd:bDestroy)
             i := Eval(oWnd:bDestroy, oWnd)
             i := IIf(HB_IsLogical(i), i, .T.)
             if !i
                RETURN 0
             endif
          Endif
          if oWnd:oNotifyIcon != NIL
             hwg_ShellNotifyIcon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
          endif
          if oWnd:hAccel != NIL
             hwg_DestroyAcceleratorTable(oWnd:hAccel)
          endif
      elseif wParam == SC_MINIMIZE
          if oWnd:lTray
             oWnd:Hide()
             RETURN 0
          endif
      endif
   elseif msg == WM_NOTIFYICON
      if wParam == ID_NOTIFYICON
          if lParam == WM_LBUTTONDOWN
             if HB_IsBlock(oWnd:bNotify)
                Eval(oWnd:bNotify)
             endif
          elseif lParam == WM_RBUTTONDOWN
             if oWnd:oNotifyMenu != NIL
                i := hwg_GetCursorPos()
                oWnd:oNotifyMenu:Show(oWnd, i[1], i[2])
             endif
          endif
      endif
   elseif msg == WM_MENUSELECT
      if NumAnd(hwg_HIWORD(wParam), MF_HILITE) != 0 // hwg_HIWORD(wParam) = FLAGS , function NUMAND of the LIBCT.LIB
         if HB_IsArray(oWnd:menu)
            if (aMenu := hwg_FindMenuItem(oWnd:menu, hwg_LOWORD(wParam), @iCont)) != NIL
               if aMenu[1, iCont, 2][2] != NIL
                  hwg_WriteStatus(oWnd, 1, aMenu[1, iCont, 2][2]) // show message on StatusBar
               else
                  hwg_WriteStatus(oWnd, 1, "") // clear message
               endif
            else
               hwg_WriteStatus(oWnd, 1, "") // clear message
            endif
         endif
      EndIf
      RETURN 0
   else
      if msg == WM_MOUSEMOVE
          hwg_DlgMouseMove()
      endif
      if HB_IsBlock(oWnd:bOther)
          Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
      endif
   endif

RETURN -1

FUNCTION DefChildWndProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
Local iParHigh, iParLow
Local oWnd, oBtn, oitem

   //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("DefChildWndProc -Inicio", 40) + "|")
   if (oWnd := HWindow():FindWindow(hWnd)) == NIL
      if msg == WM_CREATE
         if Len(HWindow():aWindows) != 0 .AND. ;
               (oWnd := HWindow():aWindows[Len(HWindow():aWindows)]) != NIL .AND. ;
            oWnd:handle == 0
            oWnd:handle := hWnd
            if oWnd:bInit != NIL
            Eval(oWnd:bInit, oWnd)
            endif
         endif
      endif
      RETURN 0
   endif
   if msg == WM_COMMAND
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Child - COMMAND", 40) + "|")
      if wParam == SC_CLOSE
          //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Child - Close", 40) + "|")
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0)
          endif
      elseif wParam == SC_RESTORE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0)
          endif
      elseif wParam == SC_MAXIMIZE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0)
          endif
      elseif wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
          nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
          hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0)
      endif
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
         (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
         Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
      ELSEIF HB_IsArray(oWnd:menu) .AND. ;
             (aMenu := hwg_FindMenuItem(oWnd:menu, iParLow, @iCont)) != NIL ;
             .AND. aMenu[1, iCont, 1] != NIL
         Eval(aMenu[1, iCont, 1])
      ELSEIF oWnd:oPopup != NIL .AND. ;
             (aMenu := hwg_FindMenuItem(oWnd:oPopup:aMenu, wParam, @iCont)) != NIL ;
             .AND. aMenu[1, iCont, 1] != NIL
         Eval(aMenu[1, iCont, 1])
      ELSEIF oWnd:oNotifyMenu != NIL .AND. ;
             (aMenu := hwg_FindMenuItem(oWnd:oNotifyMenu:aMenu, wParam, @iCont)) != NIL ;
             .AND. aMenu[1, iCont, 1] != NIL
         Eval(aMenu[1, iCont, 1])
      ENDIF
      RETURN 1
   elseif msg == WM_PAINT
      if oWnd:bPaint != NIL
          //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - DefWndProc -Fim", 40) + "|")
          RETURN Eval(oWnd:bPaint, oWnd)
      endif
   elseif msg == WM_MOVE
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   elseif msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR each oItem in aControls
             IF oItem:bSize != NIL
                Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #else
         FOR iCont := 1 TO nControls
             IF aControls[iCont]:bSize != NIL
                Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #endif
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nWidth  := aControls[3]-aControls[1]
      oWnd:nHeight := aControls[4]-aControls[2]
      if oWnd:bSize != NIL
          Eval(oWnd:bSize, oWnd, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      endif
      if oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
          // writelog(str(hWnd)+"--"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          aControls := hwg_GetClientRect(hWnd)
          // writelog(str(hWnd)+"=="+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          hwg_MoveWindow(HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2], aControls[3]-oWnd:aOffset[1]-oWnd:aOffset[3], aControls[4]-oWnd:aOffset[2]-oWnd:aOffset[4])
          // aControls := hwg_GetClientRect(HWindow():aWindows[2]:handle)
          // writelog(str(HWindow():aWindows[2]:handle)+"::"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          RETURN 1
      endif
   elseif msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
   elseif msg == WM_ERASEBKGND
      if oWnd:oBmp != NIL
          hwg_SpreadBitmap(wParam, oWnd:handle, oWnd:oBmp:handle)
          RETURN 1
      endif
   elseif msg == WM_DRAWITEM
      if (oBtn := oWnd:FindControl(wParam)) != NIL
          if oBtn:bPaint != NIL
             Eval(oBtn:bPaint, oBtn, lParam)
          endif
      endif
   elseif msg == WM_NOTIFY
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Child - Notify", 40) + "|")
      RETURN DlgNotify(oWnd, wParam, lParam)
   elseif msg == WM_ENTERIDLE
      if wParam == 0 .AND. (oItem := Atail(HDialog():aModalDialogs)) != NIL ;
        .AND. oItem:handle == lParam .AND. !oItem:lActivated
          oItem:lActivated := .T.
          IF oItem:bActivate != NIL
             Eval(oItem:bActivate, oItem)
          ENDIF
      endif
   elseif msg == WM_DESTROY
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Child - DESTROY", 40) + "|")
      aControls := oWnd:aControls
      nControls := Len(aControls)
     #ifdef __XHARBOUR__
      FOR EACH oItem IN aControls
          IF __ObjHasMsg(oItem, "END")
             oItem:End()
          ENDIF
      NEXT
     #else
      FOR i := 1 TO nControls
          IF __ObjHasMsg(aControls[i], "END")
             aControls[i]:End()
          ENDIF
      NEXT
     #endif
      HWindow():DelItem(oWnd)

      // RETURN 0  // Default

      hwg_PostQuitMessage(0)
      RETURN 1

   elseif msg == WM_SYSCOMMAND
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Child - SysCommand", 40) + "|")
      if wParam == SC_CLOSE
          //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Child - SysCommand - Close", 40) + "|")
          if oWnd:bDestroy != NIL
             if !Eval(oWnd:bDestroy, oWnd)
                RETURN 1
             endif
             if oWnd:oNotifyIcon != NIL
                hwg_ShellNotifyIcon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
             endif
             if oWnd:hAccel != NIL
                hwg_DestroyAcceleratorTable(oWnd:hAccel)
             endif
          endif
      elseif wParam == SC_MINIMIZE
          if oWnd:lTray
             oWnd:Hide()
             RETURN 1
          endif
      endif
   elseif msg == WM_NOTIFYICON
      if wParam == ID_NOTIFYICON
          if lParam == WM_LBUTTONDOWN
             if oWnd:bNotify != NIL
                Eval(oWnd:bNotify)
             endif
          elseif lParam == WM_RBUTTONDOWN
             if oWnd:oNotifyMenu != NIL
                i := hwg_GetCursorPos()
                oWnd:oNotifyMenu:Show(oWnd, i[1], i[2])
             endif
          endif
      endif
   else
      if msg == WM_MOUSEMOVE
          hwg_DlgMouseMove()
      endif
      if oWnd:bOther != NIL
          Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
      endif
   endif

   //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Child - DefChildWndProc -Fim", 40) + "|")

RETURN 0

FUNCTION DefMdiChildProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont
Local iParHigh, iParLow, oWnd, oBtn, oitem
Local nReturn
Local oWndBase   :=  HWindow():aWindows[1]
Local oWndClient :=  HWindow():aWindows[2]
Local hJanBase   :=  oWndBase:handle
Local hJanClient :=  oWndClient:handle
Local aMenu, hMenu, hSubMenu, nPosMenu

   // WriteLog("|DefMDIChild  "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))
   if msg == WM_NCCREATE
      // WriteLog("|DefMDIChild  "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10) + " WM_CREATE")
      // Procura objecto window com handle = 0
      oWnd := HWindow():FindWindow(0)

      IF HB_IsObject(oWnd) 

         oWnd:handle := hWnd
         hwg_InitControls(oWnd)
      ELSE

         hwg_MsgStop("DefMDIChild wrong hWnd : " + Str(hWnd, 10), "Create Error!")
         QUIT
         nReturn := 0
         RETURN (nReturn)
      ENDIF

   endif

   if (oWnd := HWindow():FindWindow(hWnd)) == NIL
      // hwg_MsgStop("MDI child: wrong window handle "+Str(hWnd) + "| " + Str(msg) , "Error!")
      // Deve entrar aqui apenas em WM_GETMINMAXINFO, que vem antes de WM_NCCREATE
      RETURN NIL
   endif

   if msg == WM_COMMAND
      if wParam == SC_CLOSE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0)
          endif
      endif
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
            (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
         Eval(oWnd:aEvents[iItem, 3])
      ENDIF
      nReturn := 1
      RETURN (nReturn)
   elseif msg == WM_MOUSEMOVE
      oBtn := SetOwnBtnSelected()
      if oBtn != NIL
          oBtn:state := OBTN_NORMAL
          InvalidateRect(oBtn:handle, 0)
          hwg_PostMessage(oBtn:handle, WM_PAINT, 0, 0)
          SetOwnBtnSelected(NIL)
      endif
   elseif msg == WM_PAINT

      if HB_ISObject(oWnd) .AND. HB_IsBlock(oWnd:bPaint)

         // WriteLog("|DefMDIChild Paint"+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))

         nReturn := Eval(oWnd:bPaint, oWnd)
         // Writelog("Saida: " + Valtype(nReturn))
         // RETURN (nReturn)
      
      endif

   elseif msg == WM_SIZE
      If HB_IsObject(oWnd)
         aControls := oWnd:aControls
         nControls := Len(aControls)
         #ifdef __XHARBOUR__
               FOR EACH oItem in aControls
                   IF oItem:bSize != NIL
                      Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
                   ENDIF
               NEXT
         #else
               FOR iCont := 1 TO nControls
                   IF aControls[iCont]:bSize != NIL
                      Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
                   ENDIF
               NEXT
         #endif
     Endif
   elseif msg == WM_NCACTIVATE
      //WriteLog("|DefMDIChild"+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))
      if HB_IsObject(oWnd)
         if wParam = 1 // Ativando
            // WriteLog("WM_NCACTIVATE" + " -> " + "Ativando" + " Wnd: " + Str(hWnd, 10)) 
            // Pega o menu atribuido
            aMenu := oWnd:menu
            //hMenu := aMenu[5]
            nPosMenu := 0
            //hSubMenu := GetSubMenu(hMenu, nPosMenu)
   
            // hwg_SendMessage(hJanClient, WM_MDISETMENU, hmenu, 0)
            hwg_DrawMenuBar(hJanBase)
   
            If  oWnd:bGetFocus != NIL
               Eval(oWnd:bGetFocus, oWnd)
            Endif
         Else   // Desativando
            // WriteLog("WM_NCACTIVATE" + " -> " + "Desativando" + " Wnd: " + Str(hWnd, 10))  
            If  oWnd:bLostFocus != NIL
               Eval(oWnd:bLostFocus, oWnd)
            Endif
         endif
      Endif

      nReturn := 0
      RETURN (nReturn)

   elseif msg == WM_MDIACTIVATE

      if wParam == 1 
            // WriteLog("WM_MDIACTIVATE" + " -> " + "Ativando" + " Wnd: " + Str(hWnd, 10))
            // Pega o menu atribuido
            aMenu := oWnd:menu
            hMenu := aMenu[5]

            hwg_SendMessage(hJanBase, WM_MDISETMENU, hMenu, 0)
            hwg_DrawMenuBar(hJanBase)
      endif

      nReturn := 0
      RETURN (nReturn)

   elseif msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
      /*
      if (oBtn := oWnd:FindControl(, lParam)) != NIL
          if oBtn:tcolor != NIL
             hwg_SetTextColor(wParam, oBtn:tcolor)
          endif
          if oBtn:bcolor != NIL
             hwg_SetBkColor(wParam, oBtn:bcolor)
             RETURN oBtn:brush:handle
          endif
          nReturn := 0
          RETURN (nReturn)
      endif
      */
   elseif msg == WM_DRAWITEM
      if (oBtn := oWnd:FindControl(wParam)) != NIL
          if oBtn:bPaint != NIL
             Eval(oBtn:bPaint, oBtn, wParam, lParam)
          endif
      endif

   elseif msg == WM_NCDESTROY
      If HB_IsObject(oWnd) 
        HWindow():DelItem(oWnd)
      Else
        hwg_MsgStop("oWnd nao e objeto! em NC_DESTROY!", "DefMDIChildProc")
      Endif
   elseif msg == WM_DESTROY
      if HB_IsObject(oWnd) 
         if HB_IsBlock(oWnd:bDestroy)
             Eval(oWnd:bDestroy, oWnd)
         endif
         aControls := oWnd:aControls
         nControls := Len(aControls)
         #ifdef __XHARBOUR__
            FOR each oItem in aControls
                IF __ObjHasMsg(oItem, "END")
                   oItem:End()
                ENDIF
            NEXT
         #else
            FOR i := 1 TO nControls
                IF __ObjHasMsg(aControls[i], "END")
                   aControls[i]:End()
                ENDIF
            NEXT
         #endif
         // HWindow():DelItem(oWnd)  -> alterado por jamaj
         // Temos que eliminar em NC_DESTROY
      Endif
      nReturn := 1
      RETURN (nReturn)
   elseif msg == WM_CREATE
      IF HB_IsBlock(oWnd:bInit)
         Eval(oWnd:bInit, oWnd)
      ENDIF
   else
      if HB_IsObject(oWnd) .AND. HB_IsBlock(oWnd:bOther)
         Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
      endif
   endif
   nReturn := NIL
RETURN (nReturn)

FUNCTION hwg_ReleaseAllWindows(oWnd, hWnd)
Local oItem, iCont, nCont

   //  Vamos mandar destruir as filhas
   // Destroi as CHILD's desta MAIN
   #ifdef __XHARBOUR__
   FOR EACH oItem IN HWindow():aWindows
      IF oItem:oParent != NIL .AND. oItem:oParent:handle == hWnd
          hwg_SendMessage(oItem:handle, WM_CLOSE, 0, 0)
      ENDIF
   NEXT
   #else
   nCont := Len(HWindow():aWindows)
 
   FOR iCont := 1 TO nCont

      IF HWindow():aWindows[iCont]:oParent != NIL .AND. ;
              HWindow():aWindows[iCont]:oParent:handle == hWnd
          hwg_SendMessage(HWindow():aWindows[iCont]:handle, WM_CLOSE, 0, 0)
      ENDIF

   NEXT
   #endif
   
   If HWindow():GetMain() == oWnd
      hwg_ExitProcess(0)
   Endif  

RETURN NIL

// Processamento da janela frame (base) MDI

FUNCTION DefMDIWndProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
Local iParHigh, iParLow
Local oWnd, oBtn, oitem
Local xRet, nReturn
Local oWndClient

   // WriteLog("|DefMDIWndProc"+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))
   if msg == WM_NCCREATE
      // WriteLog("|DefMDIWndProc"+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10) + " WM_CREATE")
      // Procura objecto window com handle = 0
      oWnd := HWindow():FindWindow(0)

      IF HB_IsObject(oWnd) 
         oWnd:handle := hWnd
      ELSE

         hwg_MsgStop("DefMDIWndProc wrong hWnd : " + Str(hWnd, 10), "Create Error!")
         QUIT
         nReturn := 0
         RETURN (nReturn)

      ENDIF

   endif


   if (oWnd := HWindow():FindWindow(hWnd)) == NIL
      // hwg_MsgStop("MDI wnd: wrong window handle "+Str(hWnd) + "| " + Str(msg) , "Error!")
      // Deve entrar aqui apenas em WM_GETMINMAXINFO, que vem antes de WM_NCCREATE
      RETURN NIL
   endif

   if msg == WM_CREATE
        if HB_IsBlock(oWnd:bInit)
            Eval(oWnd:bInit, oWnd)
        endif
   elseif msg == WM_COMMAND
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - COMMAND", 40) + "|")
      if wParam == SC_CLOSE
          //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - Close", 40) + "|")
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0)
          endif
      elseif wParam == SC_RESTORE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0)
          endif
      elseif wParam == SC_MAXIMIZE
          if Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0)
          endif
      elseif wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
          nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
          hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0)
      endif
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
         (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
         Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
      ELSEIF HB_IsArray(oWnd:menu) .AND. ;
         (aMenu := hwg_FindMenuItem(oWnd:menu, iParLow, @iCont)) != NIL ;
         .AND. aMenu[1, iCont, 1] != NIL

         Eval(aMenu[1, iCont, 1])

      ELSEIF oWnd:oPopup != NIL .AND. ;
         (aMenu := hwg_FindMenuItem(oWnd:oPopup:aMenu, wParam, @iCont)) != NIL ;
         .AND. aMenu[1, iCont, 1] != NIL

         Eval(aMenu[1, iCont, 1])
      ELSEIF oWnd:oNotifyMenu != NIL .AND. ;
         (aMenu := hwg_FindMenuItem(oWnd:oNotifyMenu:aMenu, wParam, @iCont)) != NIL ;
         .AND. aMenu[1, iCont, 1] != NIL

         Eval(aMenu[1, iCont, 1])
      ENDIF
      RETURN 1
   elseif msg == WM_PAINT
      if oWnd:bPaint != NIL
         //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("DefWndProc -Inicio", 40) + "|")
         RETURN Eval(oWnd:bPaint, oWnd)
      endif
   elseif msg == WM_MOVE
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   elseif msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR each oItem in aControls
             IF oItem:bSize != NIL
                Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #else
         FOR iCont := 1 TO nControls
             IF aControls[iCont]:bSize != NIL
                Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #endif
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nWidth  := aControls[3]-aControls[1]
      oWnd:nHeight := aControls[4]-aControls[2]
      if oWnd:bSize != NIL
          Eval(oWnd:bSize, oWnd, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      endif
      if oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
          // writelog(str(hWnd)+"--"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          aControls := hwg_GetClientRect(hWnd)
          // writelog(str(hWnd)+"=="+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          hwg_MoveWindow(HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2], aControls[3]-oWnd:aOffset[1]-oWnd:aOffset[3], aControls[4]-oWnd:aOffset[2]-oWnd:aOffset[4])
          // aControls := hwg_GetClientRect(HWindow():aWindows[2]:handle)
          // writelog(str(HWindow():aWindows[2]:handle)+"::"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]))
          RETURN 1
      endif
   elseif msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
   elseif msg == WM_ERASEBKGND
      if oWnd:oBmp != NIL
          hwg_SpreadBitmap(wParam, oWnd:handle, oWnd:oBmp:handle)
          RETURN 1
      endif
   elseif msg == WM_DRAWITEM
      
      if (oBtn := oWnd:FindControl(wParam)) != NIL
          if oBtn:bPaint != NIL
             Eval(oBtn:bPaint, oBtn, lParam)
          endif
      endif
   elseif msg == WM_NOTIFY
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - Notify", 40) + "|")
      RETURN DlgNotify(oWnd, wParam, lParam)
   elseif msg == WM_ENTERIDLE
      if wParam == 0 .AND. (oItem := Atail(HDialog():aModalDialogs)) != NIL ;
	    .AND. oItem:handle == lParam .AND. !oItem:lActivated
       oItem:lActivated := .T.
       IF oItem:bActivate != NIL
          Eval(oItem:bActivate, oItem)
       ENDIF
      endif
   
   elseif msg == WM_CLOSE
      hwg_ReleaseAllWindows(oWnd, hWnd)
   
   elseif msg == WM_DESTROY
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - DESTROY", 40) + "|")
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR EACH oItem IN aControls
             IF __ObjHasMsg(oItem, "END")
                oItem:End()
             ENDIF
         NEXT
      #else
         FOR i := 1 TO nControls
             IF __ObjHasMsg(aControls[i], "END")
                aControls[i]:End()
             ENDIF
         NEXT
      #endif
      // HWindow():DelItem(oWnd)

      if HB_IsBlock(oWnd:bDestroy)
          Eval(oWnd:bDestroy, oWnd)
      endif

      hwg_PostQuitMessage(0)

      // RETURN 0
      RETURN 1

   elseif msg == WM_NCDESTROY
      If HB_IsObject(oWnd) 
        HWindow():DelItem(oWnd)
      Else
        hwg_MsgStop("oWnd nao e objeto! em NC_DESTROY!", "DefMDIWndProc")
      Endif

   elseif msg == WM_SYSCOMMAND
      //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - SysCommand", 40) + "|")
      if wParam == SC_CLOSE
          //WriteLog("|Window: "+Str(hWnd, 10)+"|"+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10)  + "|" + PadR("Main - SysCommand - Close", 40) + "|")
          if oWnd:bDestroy != NIL
             xRet := Eval(oWnd:bDestroy, oWnd)
             xRet := IIf(HB_IsLogical(xRet), xRet, .T.)
             if !xRet
                RETURN 1
             endif
          Endif
   
          if oWnd:oNotifyIcon != NIL
             hwg_ShellNotifyIcon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
          endif
          if oWnd:hAccel != NIL
             hwg_DestroyAcceleratorTable(oWnd:hAccel)
          endif
          RETURN 0
      elseif wParam == SC_MINIMIZE
          if oWnd:lTray
             oWnd:Hide()
             RETURN 1
          endif
      endif
   elseif msg == WM_NOTIFYICON
      if wParam == ID_NOTIFYICON
          if lParam == WM_LBUTTONDOWN
             if oWnd:bNotify != NIL
                Eval(oWnd:bNotify)
             endif
          elseif lParam == WM_RBUTTONDOWN
             if oWnd:oNotifyMenu != NIL
                i := hwg_GetCursorPos()
                oWnd:oNotifyMenu:Show(oWnd, i[1], i[2])
             endif
          endif
      endif
   else
      If HB_IsObject(oWnd)
         if msg == WM_MOUSEMOVE
             hwg_DlgMouseMove()
         endif
         if HB_IsBlock(oWnd:bOther)
             Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
         endif
      Endif
   endif

RETURN NIL

FUNCTION GetChildWindowsNumber
RETURN Len(HWindow():aWindows) - 2
