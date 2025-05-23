//
// HWGUI - Harbour Win32 GUI library source code:
// Windows errorsys replacement
//
// Copyright 2003 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

#define BUF_SIZE  200

//----------------------------------------------------------------------------//

CLASS TMci

   DATA nError, nId
   DATA cType, cFileName
   DATA oWnd
   DATA cBuffer

   METHOD New(cDevice, cFileName)  CONSTRUCTOR

   METHOD lOpen()

   METHOD Play(nFrom, nTo, hWnd) INLINE ;
   ::nError := hwg_nMciPlay(::nId, nFrom, nTo, hWnd)

   METHOD cGetError()


   METHOD SetWindow(oWnd) INLINE ;
   ::oWnd := oWnd, ;
   ::nError := hwg_nMciWindow(::nId, oWnd:handle)

   METHOD SendStr(cMciStr)

ENDCLASS

//----------------------------------------------------------------------------//

METHOD TMci:New(cDevice, cFileName)

   DEFAULT cDevice TO ""

   ::nError    := 0
   ::nId       := 0
   ::cType     := cDevice
   ::cFileName := cFileName
   ::cBuffer   := Space(BUF_SIZE)

   RETURN Self

//----------------------------------------------------------------------------//

METHOD TMci:SendStr(cMciStr)

   LOCAL cBuffer := ::cBuffer

   hwg_MciSendString(cMciStr, @cBuffer, ::oWnd:hWnd)
   ::cBuffer := cBuffer

   RETURN NIL

//----------------------------------------------------------------------------//
METHOD TMci:lOpen()
   LOCAL nId
   ::nError := hwg_nMciOpen(::cType, ::cFileName, @nId)
   ::nId := nId
   RETURN ::nError == 0

METHOD TMci:cGetError()
   LOCAL cError
   hwg_mciGetErrorString(::nError, @cError)
   RETURN    cError
