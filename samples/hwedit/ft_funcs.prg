// Harbour Project source code:
// FT_FUNCS.Prg File support Functions For hbdoc
//
// Copyright 2000 Luiz Rafael Culik <culik@sl.conex.net>
// www - http://www.harbour-project.org

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this software; see the file COPYING.  If not, write to
// the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
// Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
//
// As a special exception, the Harbour Project gives permission for
// additional uses of the text contained in its release of Harbour.
//
// The exception is that, if you link the Harbour libraries with other
// files to produce an executable, this does not by itself cause the
// resulting executable to be covered by the GNU General Public License.
// Your use of that executable is in no way restricted on account of
// linking the Harbour library code into it.
//
// This exception does not however invalidate any other reasons why
// the executable file might be covered by the GNU General Public License.
//
// This exception applies only to the code released by the Harbour
// Project under the name Harbour.  If you copy code from other
// Harbour Project or Free Software Foundation releases into a copy of
// Harbour, as the General Public License permits, the exception does
// not apply to the code that you add in this way.  To avoid misleading
// anyone as to the status of such modified files, you must delete
// this exception notice from them.
//
// If you write modifications of your own for Harbour, it is your choice
// whether to permit this exception to apply to your modifications.
// If you do not wish that, delete this exception notice.

#include <directry.ch>
#include <fileio.ch>
#include <inkey.ch>
#include "hbdocdef.ch"
#include <common.ch>

#define xReadBuffer 4096
DECLARE  FT_FUSE(CFILE AS STRING, NMODE AS NUMERIC) AS NUMERIC
DECLARE  ft_FEOF() AS LOGICAL
DECLARE  FReadLn(cLine) AS STRING
DECLARE  FT_FReadLn() AS STRING
DECLARE  FT_FGotop()  //AS USUAL
DECLARE  FT_FSKIP(n AS NUMERIC) //AS USUAL
DECLARE  FT_MKDIR(CDIR AS STRING) //AS USUAL
DECLARE  StrPos(cBuffer AS STRING) AS NUMERIC
DECLARE  GetNumberofTableItems(cBuffer AS STRING) AS NUMERIC
DECLARE  FREADline(nH AS NUMERIC, @cB AS STRING, nMaxLine AS NUMERIC)
//DECLARE  HBMAKE_FILEBASE() AS OBJECT
DECLARE  HBMAKE_FILEBASE ;
    New(cname AS STRING) AS CLASS HBMAKE_FILEBASE;
    FOpen()   AS OBJECT;
    closefile() AS OBJECT;
    fskip(OPTIONAL n AS NUMERIC)  AS OBJECT;
    FWrite(c AS STRING) AS OBJECT;
    retrieve() AS STRING;
    fgoTop()      AS OBJECT;
    fgoBottom()     AS OBJECT;
    fgoto()    AS NUMERIC;
    create() AS OBJECT;
    fappendByte(cByte)    AS OBJECT;
    BuffGet METHOD BufferGet(OPTIONAL lDirection AS LOGICAL) AS NUMERIC;
    SKIP(OPTIONAL nRecord AS NUMERIC)                  AS OBJECT;
    WRITE(cChar AS STRING)                   AS OBJECT;
    goTop()                          AS OBJECT;
    goBottom()                       AS OBJECT;
    GOTO(OPTIONAL nValue AS NUMERIC)                   AS NUMERIC;
    OPEN()                           AS OBJECT;
    append(OPTIONAL cline AS STRING) AS OBJECT

STATIC TheHandle AS OBJECT

/****
*   FT_FUSE(cFile, nMode)   ---> nHandle
*   Open a File
*/

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function FT_FUSE()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION FT_FUSE(cFile AS STRING, nMode AS NUMERIC)

   LOCAL nHandle AS NUMERIC

   IF nMode == NIL
      nMode := 2
   ENDIF
   IF cFile == NIL
      theHandle:closefile()
   ENDIF
   IF cFile != NIL
      IF nMode != 0
         theHandle := HBMake_FileBase():new(cFile):open()
      ELSE
         theHandle := HBMake_FileBase():new(cFile):open()
      ENDIF
   ENDIF
   nHandle := theHandle:nHan

RETURN nHandle

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function ft_FEOF()
*+
*+    Called from ( hbdoc.prg    )   1 - function readln()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION ft_FEOF()

   LOCAL lRETURN AS LOGICAL := theHandle:lAtBottom

RETURN lRETURN

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function FReadLn()
*+
*+    Called from ( ft_funcs.prg )   1 - function ft_freadln()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION FReadLn(cLine AS STRING)

   cLine := theHandle:retrieve()

RETURN cLine

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function FT_FReadLn()
*+
*+    Called from ( hbdoc.prg    )   1 - function readln()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION FT_FReadLn()

   LOCAL cBuffer AS STRING := ""

   cBuffer := FReadLn(@cBuffer)

   cBuffer := STRTRAN(cBuffer, Chr(13), "")

RETURN cBuffer

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function FT_FGotop()
*+
*+    Called from ( genng.prg    )   1 - static function readfromtop()
*+                ( genrtf.prg   )   1 - static function readfromtop()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION FT_FGotop()

   theHandle:Gotop()

RETURN NIL

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function FT_FSKIP()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION FT_FSKIP(n AS NUMERIC)

   TheHandle:Skip(n)

RETURN NIL

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function FT_MKDIR()
*+
*+    Called from ( hbdoc.prg    )   6 - function main()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION FT_MKDIR(CDIR AS STRING)

   MAKEDIR(cdir)

RETURN NIL

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function StrPos()
*+
*+    Called from ( genhtm1.prg  )   1 - function prochtmtable()
*+                ( genhtm2.prg  )   1 - function prochtmtable()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION StrPos(cBuffer AS STRING)

   LOCAL nPos AS NUMERIC := 0
   LOCAL x AS NUMERIC
   LOCAL cChar AS STRING

   FOR x := 1 TO Len(cBuffer)
      cChar := SubStr(cBuffer, x, 1)
      IF cChar >= Chr(64) .AND. cChar <= Chr(90) .OR. cChar >= Chr(97) ;
                 .AND. cChar <= Chr(122) .OR. cChar >= Chr(48) .AND. cChar <= Chr(57) ;
                 .OR. cChar == Chr(60) .OR. cchar == Chr(Asc("-")) ;
                 .OR. cchar == Chr(Asc("(")) .OR. cchar = Chr(Asc("|")) .OR. ;
                 cchar == Chr(Asc(".")) .OR. cchar == Chr(Asc("*")) .OR. ;
                 cchar == Chr(Asc("#")) .OR. cchar == Chr(Asc('"')) .OR. ;
                 cchar == Chr(Asc("/")) .OR. cchar == Chr(Asc("@")) ;
                 .OR. cchar == Chr(Asc("=")) .OR. cchar == Chr(Asc("Ä")) ;
                 .OR. cchar == Chr(Asc("?")) .OR. cchar == Chr(Asc("!")) ;
                 .OR. cchar == Chr(Asc("<")) .OR. cchar == Chr(Asc(">")) ;
                 .OR. cchar == Chr(Asc("!")) .OR. cchar == Chr(Asc("+"))

         nPos := x

         EXIT
      ENDIF
   NEXT

RETURN nPos

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function GetNumberofTableItems()
*+
*+    Called from ( genhtm.prg   )   1 - function prochtmdesc()
*+                ( genng.prg    )   1 - function procngdesc()
*+                ( genng1.prg   )   1 - function procngdesc()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION GetNumberofTableItems(cBuffer)

   LOCAL cItem AS STRING
   LOCAL nItem AS NUMERIC := 0

   cBuffer := AllTrim(cBuffer)

   DO WHILE AT(SPACE(3), cBuffer) > 0
      cItem := SubStr(cBuffer, 1, AT(SPACE(3), cBuffer) - 1)
      IF AT(SPACE(3), cBuffer) == 0
         nItem ++
      ELSE
         cBuffer := AllTrim(StrTran(cBuffer, cItem, ""))
         nItem ++
      ENDIF
   ENDDO
   nItem ++

RETURN nItem

#define EOL hb_osnewline()

*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
*+    Function FREADline()
*+
*+    Called from ( genng.prg    )   1 - static function readfromtop()
*+                ( genrtf.prg   )   1 - static function readfromtop()
*+
*+ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
*+
FUNCTION FREADline(nH as Numeric, cB AS STRING, nMaxLine as Numeric)

   LOCAL cLine AS STRING
   LOCAL nSavePos AS NUMERIC
   LOCAL nEol AS NUMERIC
   LOCAL nNumRead AS NUMERIC
   LOCAL lReturn AS LOGICAL

   cLine := SPACE(nMaxLine)
   cB := ""
   nSavePos := FSeek(nH, 0, FS_RELATIVE)
   nNumRead := FRead(nH, @cLine, nMaxLine)
   IF (nEol := AT(EOL, SubStr(cLine, 1, nNumRead))) == 0
      cB := cLine
   ELSE
      cB := SubStr(cLine, 1, nEol - 1)
      FSeek(nH, nSavePos + nEol + 1, FS_SET)
   ENDIF
    lReturn := (nNumRead != 0)

RETURN lReturn

*+ EOF: FT_FUNCS.PRG
