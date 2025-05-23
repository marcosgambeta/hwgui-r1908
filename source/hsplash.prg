//
// HwGUI Harbour Win32 Gui Copyright (c) Alexander Kresin
//
// HwGUI HSplash Class
//
// Copyright (c) Sandro R. R. Freire <sandrorrfreire@yahoo.com.br>
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HSplash

   DATA oTimer
   DATA oDlg

   METHOD Create(cFile, oTime, oResource, nWidth, nHeight, nStyle) CONSTRUCTOR
   METHOD CountSeconds(oTime, oDlg)
   METHOD Release() INLINE ::oDlg:Close()

ENDCLASS

METHOD HSplash:Create(cFile, oTime, oResource, nWidth, nHeight, nStyle)
   LOCAL aWidth, aHeigth
   LOCAL bitmap

   IIf(Empty(oTime) .OR. oTime == NIL, oTime := 2000, oTime := oTime)

   IF oResource == NIL .OR. !oResource
      bitmap  := HBitmap():AddFile(cFile, , , nWidth, nHeight)
   ELSE
      bitmap  := HBitmap():AddResource(cFile, , , nWidth, nHeight)
   ENDIF

   aWidth := IIf(nWidth == NIL, bitmap:nWidth, nWidth)
   aHeigth := IIf(nHeight == NIL, bitmap:nHeight, nHeight)

   IF nWidth == NIL .OR. nHeight == NIL
      INIT DIALOG ::oDlg TITLE "" ;
        At 0, 0 SIZE aWidth, aHeigth  STYLE WS_POPUP + DS_CENTER + WS_VISIBLE + WS_DLGFRAME ;
        BACKGROUND bitmap bitmap ON INIT {||::CountSeconds(oTime, ::oDlg)}
      //oDlg:lBmpCenter := .T.
   ELSE
      INIT DIALOG ::oDlg TITLE "" ;
        At 0, 0 SIZE aWidth, aHeigth  STYLE WS_POPUP + DS_CENTER + WS_VISIBLE + WS_DLGFRAME ;
        ON INIT {||::CountSeconds(oTime, ::oDlg)}
      @ 0, 0 BITMAP Bitmap SHOW cFile STRETCH 0 SIZE nWidth, nHeight STYLE nStyle
   ENDIF
   
   ::oDlg:Activate(otime < 0)
   ::oTimer:End()

   RETURN Self

METHOD HSplash:CountSeconds(oTime, oDlg)

   SET TIMER ::oTimer OF oDlg VALUE oTime  ACTION {||EndDialog(hwg_GetModalHandle())}

   RETURN NIL




