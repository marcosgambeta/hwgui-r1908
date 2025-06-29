// 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
// �        Class: RichText                                                   �
// �  Description: System for generating simple RTF files.                    �
// �     Language: Clipper/Fivewin                                            �
// �      Version: 0.90 -- This is a usable, but incomplete, version that is  �
// �               being distributed in case anyone cares to use it as-is,    �
// �               or wants to comment on it.                                 �
// �         Date: 01/28/97                                                   �
// �       Author: Tom Marchione                                              �
// �     Internet: 73313,3626@compuserve.com                                  �
// �                                                                          �
// �    Copyright: (C) 1997, Thomas R. Marchione                              �
// �       Rights: Use/modify freely for applicaton work, under the condition �
// �               that you include the original author's credits (i.e., this �
// �               header), and you do not offer the source code for sale.    �
// �               The author may or may not supply updates and revisions     �
// �               to this code as "freeware".                                �
// �                                                                          �
// �   Warranties: None. The code has not been rigorously tested in a formal  �
// �               development environment, and is offered as-is.  The author �
// �               assumes no responsibility for its use.                     �
// �                                                                          �
// �    Revisions:                                                            �
// �                                                                          �
// �    DATE       AUTHOR  COMMENTS                                           �
// 냐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캐
// �    01/28/97   TRM     Date of initial release                            �
// �    20/10/00   JIJA    Add new methods and rewrites the table methods     �
// �                       to make compatible with MSWORD.                    �
// �    01/12/00   JIJA    Add Image managament for WMF,JPG,TIFF,PCX                                                                      �
// �                                                                          �
// �                                                                          �
// 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"
#include "richtext.ch"

#define CRLF hb_osnewline()

CLASS RichText

   DATA cFileName, hFile
   DATA nFontSize
   DATA nFontColor
   DATA aTranslate
   DATA nFontNum
   DATA nScale
   DATA lTrimSpaces
   DATA nFontAct
   DATA cLastApar INIT ""
   DATA cLastBook INIT ""
   // Table Management
   DATA cTblHAlign, nTblFntNum, nTblFntSize, nTblRows, nTblColumns
   DATA nTblRHgt, aTableCWid, cRowBorder, cCellBorder, aColPct, nCellPct
   DATA lTblNoSplit, nTblHdRows, nTblHdHgt, nTblHdPct, nTblHdFont
   DATA nTblHdFSize, nTblHdColor, nTblHdFColor
   DATA cCellAppear, cHeadAppear
   DATA cCellHAlign, cHeadHAlign
   DATA nCurrRow, nCurrColumn
   DATA TblCJoin

   // textbox Variables
   DATA txtbox, aSztBox, aCltBox, cTpltBox, nWltBox, nFPtbox
   DATA aOfftbox

   // Facing
   DATA lFacing AS LOGICAL INIT .F.

   //Styles Managament

   DATA NStlDef INIT 1
   DATA nStlAct INIT 0
   DATA nCharStl INIT 1
   DATA nCharAct INIT 0
   DATA nStlSec INIT 1
   DATA nSectAct INIT 0

   DATA ParStyles AS Array INIT {}
   DATA CharStyles AS Array INIT {}
   DATA SectStyles AS Array INIT {}

   DATA oPrinter
   // Methods for opening & closing output file, and setting defaults
   METHOD New(cFileName, aFontData, aFontFam, aFontChar, nFontSize, nFontColor, nScale, aHigh) CONSTRUCTOR
   METHOD End() INLINE ::TextCode("par\pard"), ::CloseGroup(), FClose(::hFile)

   // Core methods for writing control codes & data to the output file
   METHOD TextCode(cCode) //INLINE FWRITE(::hFile, hwg_FormatCode(cCode))
   METHOD NumCode(cCode, nValue, lScale)
   METHOD LogicCode(cCode, lTest)
   METHOD Write(xData, lCodesOK)

   // Groups and Sections (basic RTF structures)
   METHOD OpenGroup() INLINE FWrite(::hFile, "{")
   METHOD CloseGroup() INLINE FWrite(::hFile, "}")

   METHOD NewSection(lLandscape, nColumns, nLeft, nRight, nTop, nBottom, ;
                     nWidth, nHeight, cVertAlign, lDefault)

   // Higher-level page setup methods
   METHOD PageSetup(nLeft, nRight, nTop, nBottom, nWidth, nHeight, nTabWidth, lLandscape, lNoWidow, cVertAlign, ;
      cPgNumPos, lPgNumTop)

   METHOD BeginHeader() INLINE ::OpenGroup(), ;
      IIf(!::lFacing, ::TextCode("header \pard"), ::TextCode("headerr \pard"))
   METHOD EndHeader() INLINE ::TextCode("par"), ::CloseGroup()
   METHOD BeginFooter() INLINE ::OpenGroup(), ;
      IIf(!::lFacing, ::TextCode("footer \pard"), ::TextCode("footerr \pard"))
   METHOD EndFooter() INLINE ::TextCode("par"), ::CloseGroup()

   METHOD Paragraph(cText, nFontNumber, nFontSize, cAppear, ;
                    cHorzAlign, aTabPos, nIndent, nFIndent, nRIndent, nSpace, ;
                    lSpExact, nBefore, nAfter, lNoWidow, lBreak, ;
                    lBullet, cBulletChar, lHang, lDefault, lNoPar, ;
                    nFontColor, cTypeBorder, cBordStyle, nBordCol, nShdPct, cShadPat, ;
                    nStyle, lChar)


   // Table Management
   METHOD DefineTable(cTblHAlign, nTblFntNum, nTblFntSize, ;
                       cCellAppear, cCellHAlign, nTblRows, ;
                       nTblColumns, nTblRHgt, aTableCWid, cRowBorder, cCellBorder, aColPct, nCellPct, ;
                       lTblNoSplit, nTblHdRows, nTblHdHgt, nTblHdPct, nTblHdFont, ;
                       nTblHdFSize, cHeadAppear, cHeadHAlign, nTblHdColor, nTblHdFColor)

   METHOD BeginRow() INLINE ::TextCode("trowd"), ::nCurrRow += 1
   METHOD EndRow() INLINE ::TextCode("row")

   METHOD WriteCell(cText, nFontNumber, nFontSize, cAppear, cHorzAlign, ;
                     nSpace, lSpExact, cCellBorder, nCellPct, nFontColor, lDefault)

   // Methods for formatting data

   METHOD Appearance(cAppear)
   METHOD HAlignment(cAlign)
   METHOD LineSpacing(nSpace, lSpExact)
   METHOD Borders(cEntity, cBorder)
   METHOD NewFont(nFontNumber)
   METHOD SetFontSize(nFontSize)
   METHOD SetFontColor(nFontColor)
   METHOD NewLine() INLINE FWrite(::hFile, CRLF), ::TextCode("par")
   METHOD NewPage() INLINE ::TextCode("page" + CRLF)
   METHOD NumPage() INLINE ::TextCode("chpgn")
   METHOD CurrDate(cFormat)

   // General service methods

   METHOD BorderCode(cBorderID)
   METHOD ShadeCode(cShadeID)
   METHOD ParaBorder(cBorder, cType)
   METHOD BegBookMark(texto)
   METHOD EndBookMark()

   // Someday maybe we'll handle:
   // Styles
   METHOD SetStlDef()
   METHOD IncStyle(cName, styletype, nFontNumber, nFontSize, ;
                    nFontColor, cAppear, cHorzAlign, nIndent, cKeys, ;
                    cTypeBorder, cBordStyle, nBordColor, nShdPct, cShadPat, lAdd, LUpdate)
   METHOD BeginStly()
   METHOD WriteStly()
   METHOD ParaStyle(nStyle)
   METHOD CharStyle(nStyle)

   // Alternating shading of table rows
   // Footnotes & Endnotes
   METHOD FootNote(cTexto, cChar, nFontNumber, nFontSize, cAppear, nFontColor, lEnd, lAuto, lUpper)
   // Shaded text
   // Frames
   // Text Boxes
   METHOD BegTextBox(cTexto, aOffset, ASize, cTipo, aColores, nWidth, nPatron, ;
                      lSombra, aSombra, nFontNumber, nFontSize, cAppear, nFontColor, nIndent, lRounded, lEnd)
   METHOD EndTextBox()
   METHOD SetFrame(ASize, cHorzAlign, cVertAlign, lNoWrap, cXAlign, xpos, cYAlign, ypos)

   // Font Colors
   METHOD SetClrTab()
   // Lines, Bitmaps & Graphics
   METHOD Linea(aInicio, aFinal, nxoffset, nyoffset, ASize, cTipo, ;
                 aColores, nWidth, nPatron, lSombra, aSombra)
   METHOD Image(cName, ASize, nPercent, lCell, lInclude, lFrame, aFSize, cHorzAlign, ;
                 cVertAlign, lNoWrap, cXAlign, xpos, cYAlign, ypos)
//    METHOD RtfJpg(cName, aSize, nPercent)
   //  METHOD Wmf2Rtf(cName, aSize, nPercent)
   // METHOD Bmp2Wmf(cName, aSize, nPercent)
   // Information
   METHOD InfoDoc(cTitle, cSubject, cAuthor, cManager, cCompany, cOperator, ;
                   cCategor, cKeyWords, cComment)
   METHOD DocFormat(nTab, nLineStart, lBackup, nDefLang, nDocType, ;
                    cFootType, cFootNotes, cEndNotes, cFootNumber, nPage, cProtect, lFacing, nGutter)
   // Lots of other cool stuff

   // New Methods for table managament
   METHOD EndTable() INLINE ::CloseGroup()
   METHOD TableDef(lHeader, nRowHead, cCellBorder, aColPct)
   METHOD TableCell(cText, nFontNumber, nFontSize, cAppear, cHorzAlign, ;
                     nSpace, lSpExact, nFontColor, ;
                     lDefault, lHeader, lPage, lDate)
   METHOD CellFormat(cCellBorder, aCellPct)
   METHOD DefNewTable(cTblHAlign, nTblFntNum, nTblFntSize, ;
                       cCellAppear, cCellHAlign, nTblRows, ;
                       nTblColumns, nTblRHgt, aTableCWid, cRowBorder, cCellBorder, aColPct, nCellPct, ;
                       lTblNoSplit, nTblHdRows, aHeadTit, nTblHdHgt, nTblHdPct, nTblHdFont, ;
                       nTblHdFSize, cHeadAppear, cHeadHAlign, nTblHdColor, nTblHdFColor, aTblCJoin)

   HIDDEN:

   DATA nFile INIT 1

ENDCLASS

//********************************************************************
// Description:  Initialize a new RTF object, and create an associated
//               file, with a valid RTF header.
//
// Arguments:
//
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/06/97   TRM         Creation
//
//********************************************************************
METHOD RichText:New(cFileName, aFontData, aFontFam, aFontChar, nFontSize, nFontColor, nScale, aHigh)

   LOCAL i
   LOCAL cTopFile := "rtf1\ansi\ansicpg1252\deff0"
   LOCAL cColors := ::SetClrTab() // Metodo nuevo. Establece los colores que puede
   // usar el documento.

   DEFAULT cFileName TO "REPORT.RTF"
   DEFAULT aFontData TO {"Courier New"}
   DEFAULT nFontSize TO 12
   DEFAULT nScale TO INCH_TO_TWIP
   DEFAULT nFontColor TO 0

   ::cFileName := cFileName
   ::nFontSize := nFontSize
   ::nScale := nScale
   ::nFontColor := nFontColor

   ::lTrimSpaces := .F.

   IF aFontFam == NIL
      aFontFam := Array(aFontData)
      AFill(aFontFam, "fnil")
   ENDIF
   IF aFontChar == NIL
      aFontChar := Array(aFontData)
      AFill(aFontChar, 0)
   ENDIF

   IF hb_IsArray(aHigh)
      ::aTranslate := aHigh
   ENDIF

// If no extension specified in file name, use ".RTF"
   IF !("." $ ::cFileName)
      ::cFileName += ".RTF"
   ENDIF

// Create/open a file for writing
   ::hFile := FCreate(::cFileName)
   ::oPrinter := NIL

   IF ::hFile >= 0

      // Generate RTF file header

      // This opens the top-most level group for the report
      // This group must be explicitly closed by the application!

      ::OpenGroup()

      ::TextCode(cTopFile)

      // Generate a font table, and write it to the header
      ::nFontNum := Len(aFontData)
      ::OpenGroup()
      ::TextCode("fonttbl")
      FOR i := 1 TO ::nFontNum
         ::OpenGroup()
         ::NewFont(i)
         ::NumCode("charset", aFontChar[i], .F.)
         ::TextCode(aFontFam[i])
         ::Write(aFontData[i] + ";")
         ::CloseGroup()
      NEXT
      ::CloseGroup()

      // Use default color info, for now...
      ::OpenGroup()
      ::TextCode(cColors)
      ::CloseGroup()

      // NOTE:  At this point, we have an open group (the report itself)
      // that must be closed at the end of the report.

   ENDIF

RETURN Self
//**************************  END OF New()  ***************************

//********************************************************************
// Description:  Define default page setup info for file
//               This information is placed in the "document formatting
//               group" of the RTF file, except for vertical alignment,
//               which, if supplied, is treated as a new section.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/06/97   TRM         Creation
//
//********************************************************************
METHOD RichText:PageSetup(nLeft, nRight, nTop, nBottom, nWidth, nHeight, nTabWidth, lLandscape, lNoWidow, cVertAlign, ;
   cPgNumPos, lPgNumTop)

   HB_SYMBOL_UNUSED(cPgNumPos)

   DEFAULT lLandscape TO .F.
   DEFAULT lNoWidow TO .F.
   DEFAULT lPgNumTop TO .F.

// Note -- "landscape" should not be specified here if landscape and
// portrait orientations are to be mixed.  If "landscape' is specified,
// the paper width and height should also be specified, and consistent
// (i.e., with landscape/letter, width==11 and height==8.5)

   ::LogicCode("landscape", lLandscape)
   ::NumCode("paperw", nWidth)
   ::NumCode("paperh", nHeight)

   ::LogicCode("widowctrl", lNoWidow)
   ::NumCode("margl", nLeft)
   ::NumCode("margr", nRight)
   ::NumCode("margt", nTop)
   ::NumCode("margb", nBottom)
   ::NumCode("deftab", nTabWidth)

// Vertical alignment and page number position are "section-specific"
// codes.  But we'll put them here anyway for now...

   IF !Empty(cVertAlign)
      ::TextCode("vertal" + Lower(Left(cVertAlign, 1)))
   ENDIF

// Set the initial font size
   ::SetFontSize(::nFontSize)
// Forget page numbers for now...

RETURN NIL
//**********************  END OF PageSetup()  *************************

//********************************************************************
// Description:  Write a new, formatted paragraph to the output file.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/12/97   TRM         Creation
//
//********************************************************************
METHOD RichText:Paragraph(cText, nFontNumber, nFontSize, cAppear, ;
                 cHorzAlign, aTabPos, nIndent, nFIndent, nRIndent, nSpace, ;
                 lSpExact, nBefore, nAfter, lNoWidow, lBreak, ;
                 lBullet, cBulletChar, lHang, lDefault, lNoPar, ;
                 nFontColor, cTypeBorder, cBordStyle, nBordCol, nShdPct, cShadPat, ;
                 nStyle, lChar)

   LOCAL i

   DEFAULT lDefault TO .F.
   DEFAULT lNoWidow TO .F.
   DEFAULT lBreak TO .F.
   DEFAULT lBullet TO .F.
   DEFAULT lHang TO .F.
   DEFAULT cAppear TO ""
   DEFAULT cHorzAlign TO ""
   DEFAULT cBulletChar TO "\bullet"
   DEFAULT lNoPar TO .F.
   DEFAULT nFontColor TO 0
   DEFAULT cTypeBorder TO NIL
   DEFAULT cBordStyle TO "SINGLE"
   DEFAULT nBordCol TO 0
   DEFAULT nShdPct TO 0
   DEFAULT cShadPat TO ""
   DEFAULT lChar TO .F.
   DEFAULT nStyle TO 0

   nShdPct := IIf(nShdPct < 1, nShdPct * 10000, nShdPct * 100)

   ::LogicCode("pagebb", lBreak)

   IF !lNoPar
      ::TextCode("par")
   ENDIF

   ::LogicCode("pard", lDefault)

   IF !lChar
      ::ParaStyle(nStyle)
   ENDIF

   ::NewFont(nFontNumber)
   ::SetFontSize(nFontSize)
   ::SetFontColor(nFontColor)
   ::Appearance(cAppear)
   ::HAlignment(cHorzAlign)

   IF hb_IsArray(aTabPos)
      AEval(aTabPos, {|x|::NumCode("tx", x)})
   ENDIF

   ::NumCode("li", nIndent)
   ::NumCode("fi", nFIndent)
   ::NumCode("ri", nRIndent)
   ::LineSpacing(nSpace, lSpExact)

   ::NumCode("sb", nBefore)
   ::NumCode("sa", nAfter)
   ::LogicCode("keep", lNoWidow)

   IF cTypeBorder != NIL // Hay bordes de parrafo
      IF AScan(cTypeBorder, "ALL") != 0
         ::ParaBorder("ALL", cBordStyle)
      ELSEIF AScan(cTypeBorder, "CHARACTER") != 0
         ::ParaBorder("CHARACTER", cBordStyle)
      ELSE
         FOR i := 1 TO Len(cTypeBorder)
            ::ParaBorder(cTypeBorder[i], cBordStyle)
         NEXT i
      ENDIF
   ENDIF

   IF lBullet
      ::OpenGroup()
      ::TextCode("*")
      ::TextCode("pnlvlblt")
      ::LogicCode("pnhang", lHang)
      ::TextCode("pntxtb " + cBulletChar)
      ::CloseGroup()
   ENDIF

   IF nShdPct > 0
      ::NumCode(IIf(!lChar, "shading", "chshdng"), nShdPct, .F.)
      IF !Empty(cShadPat)
         ::TextCode("bg" + ::ShadeCode(cShadPat))
      ENDIF
   ENDIF

   ::Write(cText)

   IF lChar
      IF cTypeBorder != NIL
         ::TextCode("chrbdr")
      ENDIF
      IF nShdPct > 0
         ::NumCode("chshdng", 0)
      ENDIF
      ::CharStyle(nStyle)
   ENDIF

RETURN NIL
//**********************  END OF Paragraph()  *************************

//********************************************************************
// Description:    Size in points -- must double value because
//                 RTF font sizes are expressed in half-points
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/06/97   TRM         Creation
//
//********************************************************************
METHOD RichText:SetFontSize(nFontSize)

   IF hb_IsNumeric(nFontSize)
      ::nFontSize := nFontSize
      ::NumCode("fs", ::nFontSize * 2, .F.)
   ENDIF

RETURN NIL
//**********************  END OF SetFontSize()  ***********************

//********************************************************************
// Description:    Size in points -- must double value because
//                 RTF font sizes are expressed in half-points
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/06/97   TRM         Creation
//
//********************************************************************
METHOD RichText:SetFontColor(nFontColor)

   IF hb_IsNumeric(nFontColor)
      ::nFontColor := nFontColor
      ::NumCode("cf", ::nFontColor, .F.)
   ENDIF

RETURN NIL
//**********************  END OF SetFontColor()  ***********************

//********************************************************************
// Description:  Write data to output file, accounting for any characters
//               above ASCII 127 (RTF only deals with 7-bit characters
//               directly) -- 8-bit characters must be handled as hex data.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/06/97   TRM         Creation
//********************************************************************
METHOD RichText:Write(xData, lCodesOK)

   LOCAL cWrite := ""
   LOCAL i
   LOCAL cChar
   LOCAL nChar
   LOCAL cString := cStr(xData) //cValToChar(xData)
   LOCAL aCodes := {"\", "{", "}"}

   DEFAULT lCodesOK TO .F.

   IF ::lTrimSpaces
      cString := RTrim(cString)
   ENDIF

   //cString := " " + cString

   FOR i := 1 TO Len(cString)

      cChar := SubStr(cString, i, 1)
      nChar := Asc(cChar)

      IF nChar < 128

         IF nChar > 91

            // Process special RTF symbols
            IF !lCodesOK
               IF AScan(aCodes, cChar) > 0
                  cChar := "\" + cChar
               ENDIF
            ENDIF

         ELSEIF nChar < 33
            IF nChar == 13 // Turn carriage returns into new paragraphs
               cChar := "\par "
            ELSEIF nChar == 10 // Ignore line feeds
               LOOP
            ENDIF
         ENDIF

         cWrite += cChar

      ELSE

         // We have a high-order character, which is a no-no in RTF.
         // If no international translation table for high-order characters
         // is specified, write data verbatim in hex format.  If a
         // translation table is specified, look up the appropriate
         // hex value to write.

         IF Empty(::aTranslate)
            // Ignore soft line breaks
            IF nChar == 141
               LOOP
            ELSE
               cWrite += "\plain\f" + AllTrim(Str(::nFontAct - 1)) + ;
                         "\fs" + AllTrim(Str(::nFontSize * 2)) + ;
                         "\cf" + AllTrim(Str(::nFontColor)) + AllTrim(::cLastApar) + "\'" + Lower(hwg_NewBase(nChar, 16))
            ENDIF
         ELSE
            cWrite += ::aTranslate[Asc(cChar) - 127]
         ENDIF

      ENDIF

   NEXT

   ::OpenGroup()
   FWrite(::hFile, cWrite)
   ::CloseGroup()

RETURN NIL
//*************************  END OF Write()  **************************

//********************************************************************
// Description:  Write an RTF code with a numeric parameter
//               to the output file,
//
//               NOTE: Most RTF numeric measurements must be specified
//               in "Twips" (1/20th of a point, 1/1440 of an inch).
//               However, the interface layer of the RichText class
//               defaults to accept inches.  Therefore, all such
//               measurements must be converted to Twips.
//
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/12/97   TRM         Creation
//
//********************************************************************
METHOD RichText:NumCode(cCode, nValue, lScale)

   LOCAL cWrite := ""

   IF hb_IsChar(cCode) .AND. hb_IsNumeric(nValue)

      cCode := hwg_FormatCode(cCode)

      cWrite += cCode

      DEFAULT lScale TO .T.
      IF lScale
         nValue := Int(nValue * ::nScale)
      ENDIF
      cWrite += AllTrim(Str(nValue)) //+ " "

      FWrite(::hFile, cWrite)

   ENDIF

RETURN cWrite
//***********************  END OF NumCode()  *************************

//********************************************************************
// Description:  Write an RTF code if the supplied value is true
//
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/12/97   TRM         Creation
//
//********************************************************************
METHOD RichText:LogicCode(cCode, lTest)

   LOCAL cWrite := ""

   IF hb_IsChar(cCode) .AND. hb_IsLogical(lTest)
      IF lTest
         cWrite := ::TextCode(cCode)
      ENDIF
   ENDIF

RETURN cWrite
//***********************  END OF LogicCode()  *************************

//********************************************************************
// Description:  Remove extraneous spaces from a code, and make sure
//               that it has a leading backslash ("\").
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/12/97   TRM         Creation
//
//********************************************************************
FUNCTION hwg_FormatCode(cCode)

   cCode := AllTrim(cCode)
   IF !(Left(cCode, 1) == "\")
      cCode := "\" + cCode
   ENDIF

RETURN cCode
//*********************  END OF hwg_FormatCode()  *********************

//********************************************************************
// Description:  Define the default setup for a table.
//               This simply saves the parameters to the object's
//               internal instance variables.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/18/97   TRM         Creation
//
//********************************************************************
METHOD RichText:DefineTable(cTblHAlign, nTblFntNum, nTblFntSize, ;
                    cCellAppear, cCellHAlign, nTblRows, ;
                    nTblColumns, nTblRHgt, aTableCWid, cRowBorder, cCellBorder, aColPct, nCellPct, ;
                    lTblNoSplit, nTblHdRows, nTblHdHgt, nTblHdPct, nTblHdFont, ;
                    nTblHdFSize, cHeadAppear, cHeadHAlign, nTblHdColor, nTblHdFColor)

   LOCAL i

   DEFAULT cTblHAlign TO "CENTER"
   DEFAULT nTblFntNum TO 1
   DEFAULT nTblFntSize TO ::nFontSize
   DEFAULT nTblRows TO 1
   DEFAULT nTblColumns TO 1
   DEFAULT nTblRHgt TO NIL
   DEFAULT aTableCWid TO Array(nTblColumns) // see below
   DEFAULT cRowBorder TO "NONE"
   DEFAULT cCellBorder TO "SINGLE"
   DEFAULT lTblNoSplit TO .F.
   DEFAULT nCellPct TO 0
   DEFAULT nTblHdRows TO 0
   DEFAULT nTblHdHgt TO nTblRHgt
   DEFAULT nTblHdPct TO 0
   DEFAULT nTblHdFont TO nTblFntNum
   DEFAULT nTblHdFSize TO ::nFontSize + 2
   DEFAULT nTblHdColor TO 0
   DEFAULT nTblHdFColor TO 0

   IF aTableCWid[1] == NIL
      AFill(aTableCWid, 6.5 / nTblColumns)
   ELSEIF hb_IsArray(aTableCWid[1])
      aTableCWid := AClone(aTableCWid[1])
   ENDIF

   // Turn independent column widths into "right boundary" info...
   FOR i := 2 TO Len(aTableCWid)
      aTableCWid[i] += aTableCWid[i - 1]
   NEXT

   IF aColPct == NIL
      aColPct := Array(nTblColumns)
      AFill(aColPct, 0)
   ENDIF

   ::cTblHAlign := Lower(Left(cTblHAlign, 1))
   ::nTblFntNum := nTblFntNum
   ::nTblFntSize := nTblFntSize
   ::cCellAppear := cCellAppear
   ::cCellHAlign := cCellHAlign
   ::nTblRows := nTblRows
   ::nTblColumns := nTblColumns
   ::nTblRHgt := nTblRHgt
   ::aTableCWid := aTableCWid
   ::cRowBorder := ::BorderCode(cRowBorder)
   ::cCellBorder := ::BorderCode(cCellBorder)
   ::aColPct := AClone(aColPct)
   ::nCellPct := IIf(nCellPct < 1, nCellPct * 10000, nCellPct * 100)
// Porcentajes para cada celda
   i := 1
   AEval(::aColPct, {||::aColPct[i] := IIf(::aColPct[i] < 1, ::aColPct[i] * 10000, ;
                                                 ::aColPct[i] * 100), i++})

   ::lTblNoSplit := lTblNoSplit
   ::nTblHdRows := nTblHdRows
   ::nTblHdHgt := nTblHdHgt
   ::nTblHdPct := IIf(nTblHdPct < 1, nTblHdPct * 10000, nTblHdPct * 100)
   ::nTblHdFont := nTblHdFont
   ::nTblHdFSize := nTblHdFSize
   ::nTblHdColor := nTblHdColor
   ::nTblHdFColor := nTblHdFColor
   ::cHeadAppear := cHeadAppear
   ::cHeadHAlign := cHeadHAlign

   ::nCurrColumn := 0
   ::nCurrRow := 0

RETURN NIL
//**********************  END OF DefineTable()  ***********************

//********************************************************************
// Description:  Write a formatted cell of data to the current row
//               of the current table.  Also takes care of the logic
//               required for headers & header formatting.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:WriteCell(cText, nFontNumber, nFontSize, cAppear, cHorzAlign, ;
                  nSpace, lSpExact, cCellBorder, nCellPct, nFontColor, lDefault)
   
   LOCAL i

   HB_SYMBOL_UNUSED(cCellBorder)
   HB_SYMBOL_UNUSED(nCellPct)

   DEFAULT cText TO ""
   DEFAULT lDefault TO .F.

// Increment/reset the column #
   IF ::nCurrColumn == ::nTblColumns
      ::nCurrColumn := 1
   ELSE
      ::nCurrColumn += 1
   ENDIF

// Apply any one-time formatting for header/body

   IF ::nCurrColumn == 1

      IF ::nCurrRow == 0 .AND. ::nTblHdRows > 0

         // Start a separate group for the header rows
         ::OpenGroup()
         ::BeginRow()

         // We need to apply header formats
         // The "\trgaph108" & "trleft-108" are the defaults used by MS-Word,
         // so if it's good enough for Word, it's good enough for me...

         ::TextCode("trgaph108\trleft-108")
         ::TextCode("trq" + ::cTblHAlign)
         ::Borders("tr", ::cRowBorder)
         ::NumCode("trrh", ::nTblHdHgt)
         ::TextCode("trhdr")
         ::LogicCode("trkeep", ::lTblNoSplit)

         // Set the default border & width info for each header cell
         FOR i := 1 TO Len(::aTableCWid)
            ::NumCode("clshdng", ::nTblHdPct, .F.)
            IF ::nTblHdColor > 0
               ::NumCode("clcbpat", ::nTblHdColor, .F.)
            ENDIF
            ::Borders("cl", ::cCellBorder)
            ::NumCode("cellx", ::aTableCWid[i])
         NEXT

         // Identify the header-specific font
         ::NewFont(::nTblHdFont)
         ::SetFontSize(::nTblHdFSize)
         IF ::nTblHdFColor > 0
            ::SetFontColor(::nTblHdFColor)
         ENDIF
         ::Appearance(::cHeadAppear)
         ::HAlignment(::cHeadHAlign)

         ::TextCode("intbl")

      ELSEIF ::nCurrRow == ::nTblHdRows

         // The header rows are over,
         // so we need to apply formats to the body of the table.

         // First close the header section, if one exists
         IF ::nTblHdRows > 0
            ::EndRow()
            ::CloseGroup()
         ENDIF

         ::BeginRow()
         ::TextCode("trgaph108\trleft-108")
         ::TextCode("trq" + ::cTblHAlign)
         ::Borders("tr", ::cRowBorder)
         ::NumCode("trrh", ::nTblRHgt)
         ::LogicCode("trkeep", ::lTblNoSplit)

         // Set the default shading, border & width info for each body cell
         FOR i := 1 TO Len(::aTableCWid)
            ::NumCode("clshdng", ::aColPct[i], .F.)
            ::Borders("cl", ::cCellBorder)
            ::NumCode("cellx", ::aTableCWid[i])
         NEXT

         // Write the body formatting codes
         ::NewFont(::nTblFntNum)
         ::SetFontSize(::nTblFntSize)
*      ::SetFontColor(nFontColor)
         ::Appearance(::cCellAppear)
         ::HAlignment(::cCellHAlign)

         ::TextCode("intbl")

      ELSE

         // End of a row of the table body.
         ::EndRow()

         // Prepare the next row for inclusion in table
         ::TextCode("intbl")

      ENDIF

   ENDIF

// Apply any cell-specific formatting, and write the text

   ::OpenGroup()

   ::LogicCode("pard", lDefault)
   ::NewFont(nFontNumber)
   ::SetFontSize(nFontSize)
   ::SetFontColor(nFontColor)
   ::Appearance(cAppear)
   ::HAlignment(cHorzAlign)
   ::LineSpacing(nSpace, lSpExact)

   // Now write the text
   ::Write(cText)

   ::CloseGroup()

// Close the cell
   ::TextCode("cell")

RETURN NIL
//***********************  END OF WriteCell()  ************************

//********************************************************************
// Description:  Open a new section, with optional new formatting
//               properties.
//
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/26/97   TRM         Creation
//********************************************************************
METHOD RichText:NewSection(lLandscape, nColumns, nLeft, nRight, nTop, nBottom, ;
                  nWidth, nHeight, cVertAlign, lDefault)

   DEFAULT lDefault TO .F.

//::OpenGroup()
   ::TextCode("sect")

   IF lDefault
      ::TextCode("sectd")
   ENDIF

   ::LogicCode("lndscpsxn", lLandscape)
   ::NumCode("cols", nColumns, .F.)
   ::NumCode("marglsxn", nLeft)
   ::NumCode("margrsxn", nRight)
   ::NumCode("margtsxn", nTop)
   ::NumCode("margbsxn", nBottom)
   ::NumCode("pgwsxn", nWidth)
   ::NumCode("pghsxn", nHeight)

   IF !Empty(cVertAlign)
      ::TextCode("vertal" + Lower(Left(cVertAlign, 1)))
   ENDIF

// Formato de numero de pagina
   ::TextCode("sbkpage")
   ::TextCode("pgncont")
   ::TextCode("pgndec")

RETURN NIL
//***********************  END OF NewSection()  **********************

//********************************************************************
// Description:  Change the current font.
//               Converts app-level font number into RTF font number.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:NewFont(nFontNumber)

   IF !Empty(nFontNumber) .AND. nFontNumber <= ::nFontNum
      ::NumCode("f", nFontNumber - 1, .F.)
      ::nFontAct := nFontNumber
   ENDIF

RETURN NIL
//************************  END OF NewFont()  *************************

//********************************************************************
// Description:  Change the "appearance" (bold, italic, etc.)
//               Appearance codes are concatenable at the app-level
//               and already contain backslashes.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:Appearance(cAppear)

   LOCAL cWrite := ""

// Special case (see .CH file) -- first remove leading slash ...ugh.
   IF !Empty(cAppear)
      cWrite := ::TextCode(SubStr(cAppear, 2))
      ::cLastApar := cAppear
   ENDIF

RETURN cWrite
//***********************  END OF Appearance()  ***********************

//********************************************************************
// Description:  Change the horizontal alignment
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:HAlignment(cAlign)

   IF !Empty(cAlign)
      ::TextCode("q" + Lower(Left(cAlign, 1)))
   ENDIF

RETURN NIL
//**********************  END OF HAlignment()  ************************

//********************************************************************
// Description:  Change the line spacing (spacing can either be "exact"
//               or "multiple" (of single spacing).  If exact, the units
//               of the supplied value must be converted to twips.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:LineSpacing(nSpace, lSpExact)

   DEFAULT lSpExact TO .F.

   ::NumCode("sl", nSpace, lSpExact)
   IF !Empty(nSpace)
      ::NumCode("slmult", IIf(lSpExact, 0, 1), .F.)
   ENDIF

RETURN NIL
//**********************  END OF LineSpacing()  ***********************

//********************************************************************
// Description:  Apply borders to rows or cells.  Currently limited to
//               one type of border per rectangle.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:Borders(cEntity, cBorder)

   LOCAL i
   LOCAL aBorder := {"t", "b", "l", "r"}

   IF hb_IsChar(cBorder)
      FOR i := 1 TO 4
         ::TextCode(cEntity + "brdr" + aBorder[i] + "\brdr" + cBorder)
      NEXT
   ENDIF

RETURN NIL
//************************  END OF Borders()  *************************

//********************************************************************
// Description:  Apply borders to paragraphs.  Currently limited to
//               one type of border per rectangle.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:ParaBorder(cBorder, cType)

   LOCAL codigo

   cBorder := Upper(AllTrim(cBorder))
   DO CASE
   CASE cBorder == "CHARACTER"
      codigo := "chbrdr"
   CASE cBorder == "ALL"
      codigo := "box"
   CASE cBorder == "TOP"
      codigo := "brdrt"
   CASE cBorder == "BOTTOM"
      codigo := "brdrb"
   CASE cBorder == "LEFT"
      codigo := "brdrl"
   CASE cBorder == "RIGHT"
      codigo := "RIGHT"
   ENDCASE

RETURN ::TextCode(codigo + "\brdr" + ::BorderCode(cType))

//************************  END OF Borders()  *************************

//********************************************************************
// Description:  Convert an application-level border ID into
//               a valid RTF border code.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/19/97   TRM         Creation
//
//********************************************************************
METHOD RichText:BorderCode(cBorderID)

   LOCAL cBorderCode := ""
   LOCAL n
   LOCAL aBorder := ;
         { ;
           {"NONE", NIL}, ;
           {"SINGLE", "s"}, ;
           {"DOUBLETHICK", "th"}, ;
           {"SHADOW", "sh"}, ;
           {"DOUBLE", "db"}, ;
           {"DOTTED", "dot"}, ;
           {"DASHED", "dash"}, ;
           {"HAIRLINE", "hair"}  ;
         }

   cBorderID := Upper(RTrim(cBorderID))

   n := AScan(aBorder, {|x|x[1] == cBorderID})

   IF n > 0
      cBorderCode := aBorder[n][2]
   ENDIF

RETURN cBorderCode
//************************  END  OF BorderCode()  *********************

//********************************************************************
// Description:  Convert an application-level border ID into
//               a valid RTF border code.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 06/07/00   JJA         Creation
//
//********************************************************************
METHOD RichText:ShadeCode(cShadeID)

   LOCAL cShadeCode := ""
   LOCAL n
   LOCAL aShade := ;
         { ;
           {"NONE", ""}, ;
           {"HORIZ", "horiz"}, ;
           {"VERT", "vert" }, ;
           {"CROSS", "cross"}, ;
           {"FORDIAG", "fdiag"}, ;
           {"BACKDIAG", "bdiag"} ;
         }

   cShadeID := Upper(RTrim(cShadeID))

   n := AScan(aShade, {|x|x[1] == cShadeID})

   IF n > 0
      cShadeCode := aShade[n][2]
   ENDIF

RETURN cShadeCode
//************************  END  OF BorderCode()  *********************

//********************************************************************
// Description:  Example of an array that could be used to map
//               high-order characters.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/06/97   TRM         Creation
//
//********************************************************************
FUNCTION hwg_IntlTranslate()

   LOCAL i
   LOCAL aTranslate[128]
   LOCAL aHighTable := ;
         { ;
           "\'fc", "\'e9", "\'e2", "\'e4", "\'e0", "\'e5", "\'e7", "\'ea", ;
           "\'eb", "\'e8", "\'ef", "\'ee", "\'ec", "\'c4", "\'c5", "\'c9", ;
           "\'e6", "\'c6", "\'f4", "\'f6", "\'f2", "\'fb", "\'f9", "\'ff", ;
           "\'d6", "\'dc", "\'a2", "\'a3", "\'a5", "\'83", "\'ed", "\'e1", ;
           "\'f3", "\'fa", "\'f1", "\'d1", "\'aa", "\'ba", "\'bf" ;
         }

   AFill(aTranslate, "")

   FOR i := 1 TO Len(aHighTable)
      aTranslate[i] := aHighTable[i]
   NEXT

RETURN aTranslate
//********************  END OF hwg_IntlTranslate()  *******************

//********************************************************************
// Description:  Convert a decimal numeric to a string in another
//               base system
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/12/97   TRM         Creation
//
//********************************************************************
FUNCTION hwg_NewBase(nDec, nBase)

   LOCAL cNewBase := ""
   LOCAL nDividend
   LOCAL nRemain
   LOCAL lContinue := .T.
   LOCAL cRemain

   DO WHILE lContinue

      nDividend := Int(nDec / nBase)
      nRemain := nDec % nBase

      IF nDividend >= 1
         nDec := nDividend
      ELSE
         lContinue := .F.
      ENDIF

      IF nRemain < 10
         cRemain := AllTrim(Str(nRemain, 2, 0))
      ELSE
         cRemain := Chr(nRemain + 55)
      ENDIF

      cNewBase := cRemain + cNewBase

   ENDDO

RETURN cNewBase
//**********************  END OF hwg_NewBase()  ***********************

METHOD RichText:BegBookMark(texto)

   DEFAULT texto TO "marca"

   ::cLastBook := StrTran(texto, " ", "_")
// Iniciar grupo

   ::OpenGroup()
   ::TextCode("*\bkmkstart " + Lower(::cLastBook))
   ::CloseGroup()

RETURN NIL

METHOD RichText:EndBookMark()

   ::OpenGroup()
   ::TextCode("*\bkmkend " + Lower(::cLastBook))
   ::CloseGroup()

RETURN NIL

METHOD RichText:Linea(aInicio, aFinal, nxoffset, nyoffset, ASize, cTipo, ;
              aColores, nWidth, nPatron, lSombra, aSombra)

   DEFAULT cTipo TO "SOLIDA"
   DEFAULT nxoffset TO 0
   DEFAULT nyoffset TO 0
   DEFAULT nWidth TO 0.01
   DEFAULT aColores TO {0, 0, 0}
   DEFAULT ASize TO {2.0, 0}
   DEFAULT nPatron TO 1
   DEFAULT lSombra TO .F.
   DEFAULT aSombra TO {0, 0}

   ::OpenGroup()
   ::TextCode("do\dobxmargin\dobypara\dpline")
   ::NumCode("dpptx", aInicio[1], .T.)
   ::NumCode("dppty", aInicio[2], .T.)
   ::NumCode("dpptx", aFinal[1], .T.)
   ::NumCode("dppty", aFinal[2], .T.)
   ::NumCode("dpx", nxoffset, .T.)
   ::NumCode("dpy", nyoffset, .T.)
   ::NumCode("dpxsize", ASize[1], .T.)
   ::NumCode("dpysize", ASize[2], .T.)
   DO CASE
   CASE cTipo == "SOLIDA"
      ::TextCode("dplinesolid")
   CASE cTipo == "PUNTOS"
      ::TextCode("dplinedot")
   CASE cTipo == "LINEAS"
      ::TextCode("dplinedash")
   CASE cTipo == "PUNTOLINEA"
      ::TextCode("dplinedado")
   ENDCASE
// Colores
   ::NumCode("dplinecob", aColores[1], .F.)
   ::NumCode("dplinecog", aColores[2], .F.)
   ::NumCode("dplinecor", aColores[3], .F.)
// Ancho de la linea
   ::NumCode("dplinew", nWidth, .T.)
// Patron
   ::NumCode("dpfillpat", nPatron, .F.)
// Linea con sombra
   ::LogicCode("dpshadow", lSombra)
   IF lSombra
      ::NumCode("dpshadx", aSombra[1], .T.)
      ::NumCode("dpshady", aSombra[2], .T.)
   ENDIF

   ::CloseGroup()

RETURN NIL

METHOD RichText:SetClrTab()

   LOCAL colors

   colors := "colortbl;\red0\green0\blue0;\red0\green0\blue128;\red0\green128\blue0;"
   colors += "\red0\green128\blue128;\red128\green0\blue0;\red128\green0\blue128;\red128\green128\blue0;"
   colors += "\red192\green192\blue192;\red128\green128\blue128;\red0\green0\blue255;"
   colors += "\red0\green255\blue0;\red0\green255\blue255;\red255\green0\blue0;"
   colors += "\red255\green0\blue255;\red255\green255\blue0;\red255\green255\blue255;"

RETURN colors

METHOD RichText:SetStlDef()

   ::IncStyle("Normal")
   ::IncStyle("Default Paragraph Font", "CHARACTER")

RETURN NIL

METHOD RichText:InfoDoc(cTitle, cSubject, cAuthor, cManager, cCompany, cOperator, ;
                cCategor, cKeyWords, cComment)

   DEFAULT cTitle TO "Informe"
   DEFAULT cSubject TO ""
   DEFAULT cAuthor TO ""
   DEFAULT cManager TO ""
   DEFAULT cCompany TO ""
   DEFAULT cOperator TO ""
   DEFAULT cCategor TO ""
   DEFAULT cKeyWords TO ""
   DEFAULT cComment TO ""

   ::OpenGroup()

   ::TextCode("info")

   ::OpenGroup()
   ::TextCode("title " + cTitle)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("subject " + cSubject)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("author " + cAuthor)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("manager " + cManager)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("company " + cCompany)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("operator " + cOperator)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("category " + cCategor)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("keywords " + cKeyWords)
   ::CloseGroup()
   ::OpenGroup()
   ::TextCode("comment " + cComment)
   ::CloseGroup()
   ::CloseGroup()

RETURN NIL

METHOD RichText:FootNote(cTexto, cChar, nFontNumber, ;
                 nFontSize, cAppear, nFontColor, lEnd, lAuto, lUpper)

   DEFAULT cTexto TO ""
   DEFAULT cChar TO "*"
   DEFAULT nFontNumber TO 0
   DEFAULT nFontSize TO 8
   DEFAULT cAppear TO ""
   DEFAULT nFontColor TO 0
   DEFAULT lUpper TO .T.
   DEFAULT lAuto TO .F.
   DEFAULT lEnd TO .F.

   cChar := IIf(lAuto, "", cChar)
   ::OpenGroup()
   ::OpenGroup()
   IF lUpper
      ::TextCode("super " + cChar)
   ELSE
      IF !Empty(cChar)
         ::Write(cChar)
      ENDIF
   ENDIF

   IF lAuto
      ::TextCode("chftn")
   ENDIF

   ::CloseGroup()

   ::OpenGroup()
   ::TextCode("footnote")
   IF lEnd
      ::TextCode("ftnalt")
   ENDIF

   ::NewFont(nFontNumber)
   ::SetFontSize(nFontSize)
   ::SetFontColor(nFontColor)
   ::Appearance(cAppear)

   ::OpenGroup()
   IF lUpper
      ::TextCode("super " + cChar)
   ELSE
      IF !Empty(cChar)
         ::Write(cChar)
      ENDIF
   ENDIF

   IF lAuto
      ::TextCode("chftn")
   ENDIF

   ::CloseGroup()

   ::Write(cTexto)

   ::CloseGroup()

   ::CloseGroup()

RETURN NIL

METHOD RichText:BegTextBox(cTexto, aOffset, ASize, cTipo, aColores, nWidth, nPatron, ;
                   lSombra, aSombra, nFontNumber, nFontSize, cAppear, nFontColor, nIndent, lRounded, lEnd)

   DEFAULT cTexto TO ""
   DEFAULT aOffset TO {0, 0}
   DEFAULT ASize TO {2.0, 1.0}
   DEFAULT cTipo TO "SOLIDA"
   DEFAULT aColores TO {0, 0, 0}
   DEFAULT nWidth TO 20
   DEFAULT nPatron TO 1
   DEFAULT lEnd TO .F.
   DEFAULT lRounded TO .F.
   DEFAULT lSombra TO .F.
   DEFAULT aSombra TO {0, 0}

   ::aOfftBox := aOffset
   ::aSztBox := ASize
   ::aCltBox := aColores
   ::cTpltBox := cTipo
   ::nWltBox := nWidth
   ::nFPtbox := nPatron

   ::OpenGroup()
   ::TextCode("do\dobxmargin\dobypara\dptxbx\dptxbxmar40")
   ::logicCode("dproundr", lRounded)
   ::LogicCode("dpshadow", lSombra)
   IF lSombra
      ::NumCode("dpshadx", aSombra[1], .T.)
      ::NumCode("dpshadx", aSombra[2], .T.)
   ENDIF
   ::OpenGroup()
   ::TextCode("dptxbxtext \s0\ql")
   IF !Empty(cTexto)
      ::Paragraph(cTexto, nFontNumber, nFontSize, cAppear, ;
                  ,, nIndent,,,,,,,,,,,, .F., .T., nFontColor)
   ENDIF

   IF lEnd
      ::EndTextBox()
   ENDIF

RETURN NIL

METHOD RichText:EndTextBox()

   ::CloseGroup() // Cierra el grupo de texto

   ::NumCode("dpx", ::aOfftbox[1], .T.)
   ::NumCode("dpy", ::aOfftbox[2], .T.)
   ::NumCode("dpxsize", ::aSztBox[1], .T.)
   ::NumCode("dpysize", ::aSztBox[2], .T.)
   DO CASE
   CASE ::cTpltBox == "SOLIDA"
      ::TextCode("dplinesolid")
   CASE ::cTpltBox == "PUNTOS"
      ::TextCode("dplinedot")
   CASE ::cTpltBox == "LINEAS"
      ::TextCode("dplinedash")
   CASE ::cTpltBox == "PUNTOLINEA"
      ::TextCode("dplinedado")
   ENDCASE
// Colores
   ::NumCode("dplinecob", ::aCltBox[1], .F.)
   ::NumCode("dplinecog", ::aCltBox[2], .F.)
   ::NumCode("dplinecor", ::aCltBox[3], .F.)
// Ancho de la linea
   ::NumCode("dplinew", ::nWltBox, .F.)
   ::TextCode("\dpfillbgcr255\dpfillbgcg255\dpfillbgcb255")
// Patron
   ::NumCode("dpfillpat", ::nFPtbox, .F.)

   ::CloseGroup()

RETURN NIL

METHOD RichText:SetFrame(ASize, cHorzAlign, cVertAlign, lNoWrap, cXAlign, xpos, cYAlign, ypos)

   LOCAL ancho

   IF Empty(ASize)
      RETURN NIL
   ENDIF

   ancho := Round((1.25 * ASize[1] * ::nScale) + 0.5, 0)
   ::TextCode("absh0")
   ::NumCode("absw", ancho, .F.)

   IF cXAlign == "MARGIN"
      ::TextCode("phmrg")
   ELSE
      ::TextCode("phpg")
   ENDIF

   IF xpos == NIL
      DO CASE
      CASE cHorzAlign == "LEFT"
         ::TextCode("posxl")
      CASE cHorzAlign == "RIGHT"
         ::TextCode("posxr")
      CASE cHorzAlign == "CENTER"
         ::TextCode("posxc")
      ENDCASE
   ELSE
      ::NumCode("posx", xpos, .T.)
   ENDIF

   IF cYAlign == "MARGIN"
      ::TextCode("pvmrg")
   ELSEIF cYAlign == "PARRAFO"
      ::TextCode("pvpara")
   ELSE
      ::TextCode("pvpg")
   ENDIF

   IF ypos == NIL
      DO CASE
      CASE cVertAlign == "TOP"
         ::TextCode("posyt")
      CASE cVertAlign == "BOTTOM"
         ::TextCode("posyb")
      CASE cVertAlign == "CENTER"
         ::TextCode("posyc")
      ENDCASE
   ELSE
      ::NumCode("posy", ypos, .T.)
   ENDIF

   IF lNoWrap
      ::TextCode("nowrap")
   ELSE
      ::TextCode("dxfrtext180\dfrmtxtx180\dfrmtxty0")
   ENDIF

   ::TextCode("par\li0\ql")

   ::ParaBorder("ALL", "SINGLE")

RETURN NIL

METHOD RichText:Image(cName, ASize, nPercent, lCell, lInclude, lFrame, aFSize, cHorzAlign, ;
              cVertAlign, lNoWrap, cXAlign, xpos, cYAlign, ypos)

   LOCAL cExt

   DEFAULT cName TO ""
   DEFAULT ASize TO {}
   DEFAULT cHorzAlign TO "CENTER"
   DEFAULT cVertAlign TO "TOP"
   DEFAULT lFrame TO .T.
   DEFAULT lNoWrap TO .F.
   DEFAULT lCell TO .F.
   DEFAULT xpos TO NIL
   DEFAULT cXAlign TO "MARGIN"
   DEFAULT cYAlign TO "PARRAFO"
   DEFAULT ypos TO NIL
   DEFAULT lInclude TO .F.
   DEFAULT nPercent TO 1

   IF Empty(cName)
      RETURN NIL
   ENDIF

   IF lCell
      ::nCurrColumn += 1

      ::LogicCode("pard", .T.)
      ::TextCode("intbl")
      ::OpenGroup()
   ELSE
      IF lFrame
         DEFAULT aFSize TO ASize
         ::SetFrame(aFSize, cHorzAlign, cVertAlign, lNoWrap, ;
                     cXAlign, xpos, cYAlign, ypos)
      ENDIF
   ENDIF

   IF !lInclude
      ::NumCode("sslinkpictw", ASize[1])
      ::NumCode("sslinkpicth", ASize[2])

      ::OpenGroup()
      ::TextCode("field")

      ::OpenGroup()
      ::TextCode("fldinst")

      FWrite(::hFile, " INCLUDEPICTURE ")
      cName := StrTran(cName, "\", "\\\\")
      FWrite(::hFile, " " + AllTrim(cName) + " \\*MERGEFORMAT ")

      ::CloseGroup()

      ::OpenGroup()
      ::TextCode("fldrslt")
      ::CloseGroup()
      ::CloseGroup()
   ELSE
      cExt := Upper(hwg_cFileExt(cName))

      DO CASE
      CASE cExt == "BMP"
         ::Bmp2Wmf(cName, ASize, nPercent)
      CASE cExt == "WMF"
         ::Wmf2Rtf(cName, ASize, nPercent)
      OTHERWISE
         ::RtfJpg(cName, ASize, nPercent)
      ENDCASE
   ENDIF

   IF lCell
      ::CloseGroup()
      ::TextCode("cell")

      IF ::nCurrColumn == ::nTblColumns // Ha terminado una columna
         ::TextCode("intbl\row")
         ::nCurrColumn := 0
      ENDIF
   ELSE
      ::TextCode("par\pard")
   ENDIF

RETURN NIL

METHOD RichText:IncStyle(cName, styletype, nFontNumber, nFontSize, ;
                 nFontColor, cAppear, cHorzAlign, nIndent, cKeys, ;
                 cTypeBorder, cBordStyle, nBordColor, nShdPct, cShadPat, lAdd, LUpdate)

   LOCAL lParrafo := .F.
   LOCAL lChar := .F.
   LOCAL i
   LOCAL cEstilo := ""

   DEFAULT cName TO ""
   DEFAULT styletype TO "PARAGRAPH"
   DEFAULT nFontNumber TO 1
   DEFAULT nFontSize TO ::nFontSize
   DEFAULT nFontColor TO ::nFontColor
   DEFAULT cAppear TO ""
   DEFAULT cHorzAlign TO "LEFT"
   DEFAULT nIndent TO 0
   DEFAULT cKeys TO ""
   DEFAULT cTypeBorder TO NIL
   DEFAULT cBordStyle TO "SINGLE"
   DEFAULT nBordColor TO 0
   DEFAULT nShdPct TO 0
   DEFAULT cShadPat TO ""
   DEFAULT lAdd TO .F.
   DEFAULT LUpdate TO .F.

   nShdPct := IIf(nShdPct < 1, nShdPct * 10000, nShdPct * 100)

   ::OpenGroup()

   DO CASE
   CASE styletype == "PARAGRAPH"
      ::NumCode("s", ::NStlDef, .F.)
      lParrafo := .T.
   CASE styletype == "CHARACTER"
      ::NumCode("*\cs", ::nCharStl, .F.)
      lChar := .T.
   CASE styletype == "SECTION"
      ::NumCode("ds", ::nStlSec, .F.)
   ENDCASE

   IF !Empty(cKeys)
      ::OpenGroup()
      ::TextCode("keycode " + cKeys)
      ::CloseGroup()
   ENDIF
   IF lParrafo
      IF cTypeBorder != NIL // Hay bordes de parrafo
         IF AScan(cTypeBorder, "ALL") != 0
            cEstilo += ::ParaBorder("ALL", cBordStyle)
         ELSE
            FOR i := 1 TO Len(cTypeBorder)
               cEstilo += ::ParaBorder(cTypeBorder[i], cBordStyle)
            NEXT i
         ENDIF
      ENDIF
      cEstilo += ::NumCode("\li", nIndent)
   ENDIF

   cEstilo += ::NumCode("f", nFontNumber - 1, .F.)
   cEstilo += ::NumCode("fs", nFontSize * 2, .F.)
   cEstilo += ::NumCode("cf", nFontColor, .F.)
   cEstilo += ::Appearance(cAppear)

   IF lChar
      cEstilo += ::LogicCode("\additive", lAdd)
      AAdd(::CharStyles, cEstilo)
      ::nCharStl += 1

   ENDIF
   cEstilo += ::LogicCode("\sautoupd", LUpdate)

   IF lParrafo
      IF nShdPct > 0
         cEstilo += ::NumCode("shading", nShdPct, .F.)
         IF !Empty(cShadPat)
            cEstilo += ::TextCode("bg" + ::ShadeCode(cShadPat))
         ENDIF
      ENDIF
      AAdd(::ParStyles, cEstilo)
      ::NStlDef += 1
   ENDIF

   FWrite(::hFile, " " + cName + ";")

   ::CloseGroup()

RETURN NIL

METHOD RichText:BeginStly()

   ::OpenGroup()
   ::TextCode("stylesheet")
   ::SetStlDef()

RETURN NIL

METHOD RichText:WriteStly()

   ::CloseGroup()

RETURN NIL

//********************************************************************
// Description:  Change the paragraph style
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/09/99
//
//********************************************************************
METHOD RichText:ParaStyle(nStyle)

   IF nStyle == 0
      RETURN NIL
   ENDIF

   IF ::nStlAct != nStyle
      IF nStyle <= Len(::ParStyles[nStyle])
         ::Numcode("par\pard\s", nStyle, .F.)
         FWrite(::hFile, ::ParStyles[nStyle])
         ::nStlAct := nStyle
      ENDIF
   ENDIF

RETURN NIL

//********************************************************************
// Description:  Change the character style
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 01/09/99
//
//********************************************************************
METHOD RichText:CharStyle(nStyle)

   IF nStyle == 0
      RETURN NIL
   ENDIF

   IF ::nCharAct != nStyle
      IF nStyle <= Len(::CharStyles[nStyle])
         ::Numcode("\cs", nStyle, .F.)
         FWrite(::hFile, ::CharStyles[nStyle])
         ::nCharAct := nStyle
      ENDIF
   ENDIF

RETURN NIL
//**********************  END OF HAlignment()  ************************

METHOD RichText:TextCode(cCode)

   LOCAL codigo

   codigo := hwg_FormatCode(cCode)

   FWrite(::hFile, codigo)

RETURN codigo

//********************************************************************
// Description:  Define the default setup for a table.
//               Saves the parameters to the object's
//               internal instance variables,and define the table
//               defaults.
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 22/10/00   JIJA        Modification of Define Table.
//                        You can introduce more than one header row
//
//********************************************************************
METHOD RichText:DefNewTable(cTblHAlign, nTblFntNum, nTblFntSize, ;
                    cCellAppear, cCellHAlign, nTblRows, ;
                    nTblColumns, nTblRHgt, aTableCWid, cRowBorder, cCellBorder, aColPct, nCellPct, ;
                    lTblNoSplit, nTblHdRows, aHeadTit, nTblHdHgt, nTblHdPct, nTblHdFont, ;
                    nTblHdFSize, cHeadAppear, cHeadHAlign, nTblHdColor, nTblHdFColor, ;
                    aTblCJoin)

   LOCAL i
   LOCAL j

   DEFAULT cTblHAlign TO "CENTER"
   DEFAULT nTblFntNum TO 1
   DEFAULT nTblFntSize TO ::nFontSize
   DEFAULT nTblRows TO 1
   DEFAULT nTblColumns TO 1
   DEFAULT nTblRHgt TO NIL
   DEFAULT aTableCWid TO Array(nTblColumns) // see below
   DEFAULT cRowBorder TO "NONE"
   DEFAULT cCellBorder TO "SINGLE"
   DEFAULT lTblNoSplit TO .F.
   DEFAULT nCellPct TO 0
   DEFAULT nTblHdRows TO 0
   DEFAULT aHeadTit TO {}
   DEFAULT nTblHdHgt TO nTblRHgt
   DEFAULT nTblHdPct TO 0
   DEFAULT nTblHdFont TO nTblFntNum
   DEFAULT nTblHdFSize TO ::nFontSize + 2
   DEFAULT nTblHdColor TO 0
   DEFAULT nTblHdFColor TO 0
   DEFAULT aTblCJoin TO {}

   IF aTableCWid[1] == NIL
      AFill(aTableCWid, 6.5 / nTblColumns)
   ELSEIF hb_IsArray(aTableCWid[1])
      aTableCWid := AClone(aTableCWid[1])
   ENDIF

   // Turn independent column widths into "right boundary" info...
   FOR i := 2 TO Len(aTableCWid)
      aTableCWid[i] += aTableCWid[i - 1]
   NEXT

   IF aColPct == NIL
      aColPct := Array(nTblColumns)
      AFill(aColPct, 0)
   ENDIF

   ::cTblHAlign := Lower(Left(cTblHAlign, 1))
   ::nTblFntNum := nTblFntNum
   ::nTblFntSize := nTblFntSize
   ::cCellAppear := cCellAppear
   ::cCellHAlign := cCellHAlign
   ::nTblRows := nTblRows
   ::nTblColumns := nTblColumns
   ::nTblRHgt := nTblRHgt
   ::aTableCWid := aTableCWid
   ::cRowBorder := ::BorderCode(cRowBorder)
   ::cCellBorder := ::BorderCode(cCellBorder)
   ::aColPct := AClone(aColPct)
   ::nCellPct := IIf(nCellPct < 1, nCellPct * 10000, nCellPct * 100)
// Porcentajes para cada celda
   i := 1
   AEval(::aColPct, {||::aColPct[i] := IIf(::aColPct[i] < 1, ::aColPct[i] * 10000, ;
                                                 ::aColPct[i] * 100), i++})

   ::lTblNoSplit := lTblNoSplit
   ::nTblHdRows := nTblHdRows
   ::nTblHdHgt := nTblHdHgt
   ::nTblHdPct := IIf(nTblHdPct < 1, nTblHdPct * 10000, nTblHdPct * 100)
   ::nTblHdFont := nTblHdFont
   ::nTblHdFSize := nTblHdFSize
   ::nTblHdColor := nTblHdColor
   ::nTblHdFColor := nTblHdFColor
   ::cHeadAppear := cHeadAppear
   ::cHeadHAlign := cHeadHAlign
   ::TblCJoin := AClone(aTblCJoin)

   ::nCurrColumn := 0
   ::nCurrRow := 0

   ::OpenGroup()

   FOR j := 1 TO ::nTblHdRows
      ::TableDef(.T., j)
      FOR i := 1 TO Len(::aTableCWid)
         ::TableCell(aHeadTit[j][i],,,,,,,, .T., .T.)
      NEXT i
   NEXT j

   ::TableDef()

RETURN NIL
//**********************  END OF DefNewTable()  ***********************

//********************************************************************
// Description:  Writes the row defaults on the output file.
//
//
//
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 22/10/00   JIJA
//
//
//********************************************************************
METHOD RichText:TableDef(lHeader, nRowHead, cCellBorder, aColPct)

   LOCAL i
   LOCAL j
   LOCAL pos

   DEFAULT lHeader TO .F.
   DEFAULT nRowHead TO 1
   DEFAULT cCellBorder TO ::cCellBorder
   DEFAULT aColPct TO AClone(::aColPct)

   ::TextCode("trowd\trgaph108\trleft-108")
   ::TextCode("trq" + ::cTblHAlign)
   ::Borders("tr", ::cRowBorder)
   ::NumCode("trrh", ::nTblRHgt)
   ::LogicCode("trhdr", lHeader)
   ::LogicCode("trkeep", ::lTblNoSplit)

   // Set the default shading, border & width info for each body cell
   FOR i := 1 TO Len(::aTableCWid)
      IF lHeader
         IF !Empty(::TblCJoin)
            FOR j := 1 TO Len(::TblCJoin[nRowHead])
               pos := AScan(::TblCJoin[nRowHead][j], i)
               IF pos == 1
                  ::TextCode("clvertalt")
                  ::TextCode("clmgf")
               ELSEIF pos != 0
                  ::TextCode("clmrg")
               ELSE
                  ::TextCode("clvertalt")
               ENDIF
            NEXT j
         ELSE
            ::TextCode("clvertalt")
         ENDIF
      ELSE
         ::TextCode("clvertalt")
      ENDIF
      ::Borders("cl", cCellBorder)
      IF lHeader
         ::NumCode("clshdng", ::nTblHdPct, .F.)
         IF ::nTblHdColor > 0
            ::NumCode("clcbpat", ::nTblHdColor, .F.)
         ENDIF
      ELSE
         ::NumCode("clshdng", aColPct[i], .F.)
      ENDIF
      ::NumCode("cellx", ::aTableCWid[i])
   NEXT

RETURN NIL
//**********************  END OF TableDef()  ***********************

//********************************************************************
// Description:  Writes the cell data and format on the output file.
//
//
//
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 22/10/00   JIJA
//
//
//********************************************************************
METHOD RichText:TableCell(cText, nFontNumber, nFontSize, cAppear, cHorzAlign, ;
                  nSpace, lSpExact, nFontColor, ;
                  lDefault, lHeader, lPage, lDate)

   DEFAULT nFontNumber TO -1
   DEFAULT nFontSize TO -1
   DEFAULT cAppear TO NIL
   DEFAULT cHorzAlign TO NIL
   DEFAULT nSpace TO 0
   DEFAULT nFontColor TO 0
   DEFAULT lDefault TO .F.
   DEFAULT lHeader TO .F.
   DEFAULT lPage TO .F.
   DEFAULT lDate TO .F.

   ::nCurrColumn += 1

   ::LogicCode("pard", lDefault)
   ::TextCode("intbl")

   IF lHeader
      ::NewFont(::nTblHdFont)
      ::SetFontSize(::nTblHdFSize)
      IF ::nTblHdFColor > 0
         ::SetFontColor(::nTblHdFColor)
      ENDIF
      ::Appearance(::cHeadAppear)
      ::HAlignment(::cHeadHAlign)
   ELSE
      ::NewFont(IIf(nFontNumber == - 1, ::nTblFntNum, nFontNumber))
      ::SetFontSize(IIf(nFontSize == - 1, ::nTblFntSize, nFontSize))
      ::SetFontColor(nFontColor)
      ::Appearance(IIf(cAppear == NIL, ::cCellAppear, cAppear))
      ::HAlignment(IIf(cHorzAlign == NIL, ::cCellHAlign, cHorzAlign))
      ::LineSpacing(nSpace, lSpExact)
   ENDIF

   ::Write(cText)
   IF lPage
      ::NumPage()
   ENDIF

   IF lDate
      ::CurrDate()
   ENDIF

   ::TextCode("cell")

   IF ::nCurrColumn == ::nTblColumns // Ha terminado una columna
      ::TextCode("intbl\row")
      ::nCurrColumn := 0
   ENDIF

RETURN NIL
//**********************  END OF TableCell()  ***********************

//********************************************************************
// Description:  Changes the format of one row.
//               Now we can change the celborders and shading for
//               a row on run time.
//
// Arguments:
// Return:
//
//--------------------------------------------------------------------
// Date       Developer   Comments
// 22/10/00   JIJA
//
//
//********************************************************************
METHOD RichText:CellFormat(cCellBorder, aCellPct)

   DEFAULT cCellBorder TO ::cCellBorder
   DEFAULT aCellPct TO AClone(::aColPct)

   ::TableDef(,, cCellBorder, aCellPct)

RETURN NIL
//**********************  END OF CellFormat()  ***********************

METHOD RichText:DocFormat(nTab, nLineStart, lBackup, nDefLang, nDocType, ;
                 cFootType, cFootNotes, cEndNotes, cFootNumber, nPage, ;
                 cProtect, lFacing, nGutter)

   DEFAULT nTab TO 0.5
   DEFAULT nLineStart TO 1
   DEFAULT lBackup TO .F.
   DEFAULT nDefLang TO 1034
   DEFAULT nDocType TO 0
   DEFAULT cFootType TO "FOOTNOTES"
   DEFAULT cEndNotes TO "SECTION"
   DEFAULT cFootNotes TO "SECTION"
   DEFAULT cFootNumber TO "SIMBOL"
   DEFAULT nPage TO 1
   DEFAULT cProtect TO "NONE"
   DEFAULT lFacing TO .F.
   DEFAULT nGutter TO 0

   ::lFacing := lFacing

   ::NumCode("deftab", nTab, .T.)
   ::NumCode("linestart", nLineStart, .F.)
   ::LogicCode("makebackup", lBackup)
   ::NumCode("deflang", nDefLang, .F.)
   ::NumCode("doctype", nDocType, .F.)

   DO CASE
   CASE cFootType == "FOOTNOTES"
      ::NumCode("fet", 0, .F.)
      IF cFootNotes == "SECTION"
         ::TextCode("endnotes")
      ELSE
         ::TextCode("enddoc")
      ENDIF
      ::TextCode("ftnbj")
   CASE cFootType == "ENDNOTES"
      ::NumCode("fet", 1, .F.)
      IF cEndNotes == "SECTION"
         ::TextCode("aendnotes")
      ELSE
         ::TextCode("aenddoc")
      ENDIF
      ::TextCode("aftnbj")
   CASE cFootType == "BOTH"
      ::NumCode("fet", 2, .F.)
      IF cFootNotes == "SECTION"
         ::TextCode("endnotes")
      ELSE
         ::TextCode("enddoc")
      ENDIF
      IF cEndNotes == "SECTION"
         ::TextCode("aendnotes")
      ELSE
         ::TextCode("aenddoc")
      ENDIF
      ::TextCode("ftnbj")
      ::TextCode("aftnbj")
   ENDCASE

   DO CASE
   CASE cFootNumber == "SIMBOL"
      ::TextCode("ftnnchi")
      ::TextCode("aftnnchi")
   CASE cFootNumber == "ARABIC"
      ::TextCode("ftnnar")
      ::TextCode("aftnnar")
   CASE cFootNumber == "ALPHA"
      ::TextCode("ftnnalc")
      ::TextCode("aftnnalc")
   CASE cFootNumber == "ROMAN"
      ::TextCode("ftnnrlc")
      ::TextCode("aftnnrlc")
   ENDCASE

   ::LogicCode("facingp", lFacing)
   IF lFacing
      ::NumCode("gutter", nGutter, .T.)
   ENDIF
   ::Numcode("pgnstart", nPage, .F.)

   DO CASE
   CASE cProtect == "REVISIONS"
      ::TextCode("revprot")
   CASE cProtect == "COMMENTS"
      ::TextCode("annotprot")
   ENDCASE

RETURN NIL

METHOD RichText:CurrDate(cFormat)

   DEFAULT cFormat TO "LONGFORMAT"

   DO CASE
   CASE cFormat == "LONGFORMAT"
      ::TextCode("chdpl")
   CASE cFormat == "SHORTFORMAT"
      ::TextCode("chdpa")
   CASE cFormat == "HEADER"
      ::TextCode("chdate")
   ENDCASE

RETURN NIL

/*
METHOD RichText:RtfJpg(cName, aSize, nPercent)

   LOCAL aInches[2]
   LOCAL in
   LOCAL nWidth
   LOCAL nHeight
   LOCAL i
   LOCAL cMenInter
   LOCAL n_bloque
   LOCAL nBytes
   LOCAL lHecho
   LOCAL codigo
   LOCAL scale
   LOCAL PictWidth
   LOCAL PictHeight
   LOCAL ScreenResY
   LOCAL ScreenResX

   DEFAULT aSize TO {}
   DEFAULT nPercent TO 1

   n_bloque := 1
   cMenInter := space(n_bloque)
   lHecho := .F.

   IF LoadPicture(cName, @nWidth, @nHeight, @ScreenResX, @ScreenResY) //NViewLib32(AllTrim(cName))

      aInches[1] := Round(((nWidth/ScreenResX) * ::nScale) + 0.5, 0)
      aInches[2] := Round(((nHeight/ScreenResY) * ::nScale) + 0.5, 0)

// Dimensiones de la imagen en twips

      IF Empty(aSize)
         PictWidth := Round(aInches[1] + 0.5, 0) * nPercent
         PictHeight := Round(aInches[2] + 0.5, 0) * nPercent
      ELSE
         PictWidth := Round((aSize[1] * ::nScale) + 0.5, 0)
         PictHeight := Round((aSize[2] * ::nScale) + 0.5, 0)
      ENDIF

      in := fopen(cName)
      ::OpenGroup()
      ::TextCode("pict\jpegblip")
      scale := Round((PictWidth * 100 / aInches[1]) + 0.5, 0)
      ::NumCode("picw", nWidth, .F.)
      ::NumCode("picwgoal", aInches[1], .F.)
      ::NumCode("picscalex", scale, .F.)
      scale := Round((PictHeight * 100 / aInches[2]) + 0.5, 0)
      ::NumCode("pich", nHeight, .F.)
      ::NumCode("pichgoal", aInches[2], .F.)
      ::NumCode("picscaley", scale, .F.)

      DO WHILE !lHecho
         nBytes := fread(in, @cMenInter, n_bloque)
         IF nBytes > 0
            codigo := PADL(L_DTOHEX(Asc(cMenInter)), 2, "0")
            FWRITE(::hfile, codigo)
         ELSE
            lHecho := .T.
         ENDIF
      ENDDO
      ::CloseGroup()

      fclose(in)
   ENDIF

RETURN NIL

METHOD RichText:Wmf2Rtf(cName, aSize, nPercent)

   LOCAL in
   LOCAL cMenInter
   LOCAL n_bloque
   LOCAL nBytes
   LOCAL lHecho
   LOCAL i
   LOCAL codigo
   LOCAL cBRead
   LOCAL scale
   LOCAL PictWidth
   LOCAL PictHeight
   LOCAL ancho
   LOCAL alto
   LOCAL bmHeight
   LOCAL bmWidth
   LOCAL x
   LOCAL aInfo[5]

   DEFAULT aSize TO {}
   DEFAULT nPercent TO 1

   n_bloque := 1
   cMenInter := space(n_bloque)
   lHecho := .F.
   cBRead := 0

   cBRead := GETBMETAFILE(cName, aInfo)

   IF cBRead > 0

      IF Empty(aSize)
         alto := (aInfo[3] - aInfo[1]) * nPercent  // Unidades
         ancho := (aInfo[4] - aInfo[2]) * nPercent
      ELSE
         alto := (aSize[2] * aInfo[5])
         ancho := (aSize[1] * aInfo[5])
      ENDIF

      bmHeight := Round((alto * 1440 / 2540) + 0.5, 0)
      bmWidth := Round((ancho * 1440 / 2540) + 0.5, 0)

      PictHeight := Round((alto * 1440 / ::oPrinter:nLogPixelY()) + 0.5, 0)
      PictWidth := Round((ancho * 1440 / ::oPrinter:nLogPixelX()) + 0.5, 0)

      in := fopen(cName)
      ::OpenGroup()
      ::TextCode("\pict\wmetafile8")
      x := Round((bmWidth * 2540 / 1440) + 0.5, 0)
      ::NumCode("picw", x, .F.)
      ::NumCode("picwgoal", bmWidth, .F.)
      scale := Round((PictWidth * 100 / bmWidth) + 0.5, 0)
      ::NumCode("picscalex", scale, .F.)
      x := Round((bmHeight * 2540 / 1440) + 0.5, 0)
      ::NumCode("pich", x, .F.)
      ::NumCode("pichgoal", bmHeight, .F.)
      scale := Round((PictHeight * 100 / bmHeight) + 0.5, 0)
      ::NumCode("picscaley", scale, .F.)
      ::OpenGroup()
      fseek(in, cBRead, 0)
      DO WHILE !lHecho
         nBytes := fread(in, @cMenInter, n_bloque)
         IF nBytes > 0
            codigo := PADL(L_DTOHEX(Asc(cMenInter)), 2, "0")
            FWRITE(::hFile, codigo)
         ELSE
            lHecho := .T.
         ENDIF
      ENDDO
      ::CloseGroup()
      ::CloseGroup()
      fclose(in)
   ENDIF

RETURN NIL
*/

****************************************************************************
* Funtion to load a picture using nviewlib.
*
/*
FUNCTION LoadPicture(cName, nWidth, nHeight, ScreenResX, ScreenResy)

   LOCAL hDll
   LOCAL uResult
   LOCAL cFarProc
   LOCAL oWnd
   LOCAL hWnd
   LOCAL hdc

   hDLL := LoadLib32("nviewlib.dll")

   IF Abs(hDll) <= 32
      RETURN .F.
   ENDIF

   cFarProc := GetProc32(hDll, "NViewLibLoad", .T., LONG, STRING, LONG)
   uResult := CallDll32(cFarProc, cName, 0)

   cFarProc := GetProc32(hDll, "GetWidth", .T., _INT)
   nWidth := CallDll32(cFarProc)
   cFarProc := GetProc32(hDll, "GetHeight", .T., _INT)
   nHeight := CallDll32(cFarProc)

   FreeLib32(hDll)

   oWnd := GetWndDefault()
   hWnd := oWnd:hWnd
   hdc := hwg_GetDC(hWnd)
   ScreenResX := GETDEVICEC(hdc, 88)
   ScreenResY := GETDEVICEC(hdc, 90)

RETURN .T.

METHOD RichText:Bmp2Wmf(cName, aSize, nPercent)

   LOCAL cMenInter
   LOCAL n_bloque
   LOCAL nBytes
   LOCAL lHecho
   local codigo
   LOCAL PictWidth
   LOCAL PictHeight
   LOCAL hDCOut
   LOCAL hDib
   LOCAL hPal
   LOCAL nRaster
   LOCAL cDir
   LOCAL temp
   LOCAL scalex
   LOCAL in
   LOCAL x
   LOCAL scaley
   LOCAL nWidth
   LOCAL nHeight
   LOCAL ResX
   LOCAL ResY
   LOCAL aInches[2]

   DEFAULT aSize TO {}
   DEFAULT nPercent TO 1

   n_bloque := 1
   cMenInter := space(n_bloque)
   lHecho := .F.

   cDir := GetEnv("TEMP")

   temp := cDir + "\tmp" + padl(AllTrim(Str(::nFile, 4, 0)), 4, "0") + ".wmf"

   hDCOut := hwg_CreateMetaFile(temp)

   hDib := DibRead(cName)

   IF hDib > 0
// Dimensiones en pixels
      nWidth := DIBWIDTH(hDib)
      nHeight := DIBHEIGHT(hDib)

      ResX := DIBXPIX(hDib) / 39.37
      ResY := DIBYPIX(hDib) / 39.37

// Dimensiones reales de la imagen en pulgadas

      aInches[1] := nWidth / ResX
      aInches[2] := nHeight / ResY

      IF Empty(aSize)
         aInches[1] *= nPercent
         aInches[2] *= nPercent
         scalex := INT(nPercent * 100)
         scaley := INT(nPercent * 100)
      ELSE
         scalex := Round(((aSize[1] * 100) / aInches[1]) + 0.5, 0)
         scaley := Round(((aSize[2] * 100) / aInches[2]) + 0.5, 0)
         aInches[1] := aSize[1]
         aInches[2] := aSize[2]
      ENDIF

      aInches[1] := Round(aInches[1] * 1440, 0)
      aInches[2] := Round(aInches[2] * 1440, 0)

    // initialize the metafile
      SETWNDEX(hDCOut, 0, 0)
      hwg_SetWindowExtEx(hDCOut, nWidth, nHeight);

      DibDraw(hDCOut, hDib, hPal, 0, 0, nWidth, nHeight, nRaster)

      GlobalFree(hDib)

      CloseMetafile(hDCOut)

      DELETEMETA(hDcOut)

// La matriz que se necesita para el metafile

      in := fopen(temp)
      ::OpenGroup()
      ::TextCode("\pict\wmetafile8")
      x := Round(((aInches[1] * 2540) / 1440) + 0.5, 0)
      ::NumCode("picw", x, .F.)
      ::NumCode("picwgoal", aInches[1], .F.)
      ::NumCode("picscalex", scalex, .F.)
      x := Round(((aInches[2] * 2540) / 1440) + 0.5, 0)
      ::NumCode("pich", x, .F.)
      ::NumCode("pichgoal", aInches[2], .F.)
      ::NumCode("picscaley", scaley, .F.)
      ::OpenGroup()
      DO WHILE !lHecho
         nBytes := fread(in, @cMenInter, n_bloque)
         IF nBytes > 0
            codigo := PADL(L_DTOHEX(Asc(cMenInter)), 2, "0")
            FWRITE(::hFile, codigo)
         ELSE
            lHecho := .T.
         ENDIF
      ENDDO
      ::CloseGroup()
      ::CloseGroup()
      fclose(in)
      FERASE(temp)
      ::nFile += 1
   ENDIF

RETURN NIL
*/

FUNCTION hwg_cFileExt(cFile)
RETURN SubStr(cFile, At(".", cFile) + 1)

#ifndef __XHARBOUR__
FUNCTION CStr(xExp) // TODO: prefixo HWG_

   LOCAL cType

   IF xExp == NIL
      RETURN "NIL"
   ENDIF

   cType := ValType(xExp)

   DO CASE

   CASE cType == "C"
      RETURN xExp

   CASE cType == "D"
      RETURN DToC(xExp)

   CASE cType == "L"
      RETURN IIf(xExp, ".T.", ".F.")

   CASE cType == "N"
      RETURN Str(xExp)

   CASE cType == "M"
      RETURN xExp

   CASE cType == "A"
      RETURN "{ Array of " +  LTrim(Str(Len(xExp))) + " Items }"

   CASE cType == "B"
      RETURN "{|| Block }"

   CASE cType == "O"
      RETURN "{ " + xExp:ClassName() + " Object }"

   CASE cType == "P"
#if defined(__XHARBOUR__)
      RETURN NumToHex(xExp)
#else
      RETURN hb_NumToHex(xExp)
#endif

   CASE cType == "H"
      RETURN "{ Hash of " +  LTrim(Str(Len(xExp))) + " Items }"

   OTHERWISE
      RETURN "Type: " + cType

   ENDCASE

RETURN ""
#endif

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(FORMATCODE, HWG_FORMATCODE);
HB_FUNC_TRANSLATE(INTLTRANSLATE, HWG_INTLTRANSLATE);
HB_FUNC_TRANSLATE(NEWBASE, HWG_NEWBASE);
HB_FUNC_TRANSLATE(CFILEEXT, HWG_CFILEEXT);
#endif

#pragma ENDDUMP
