//
// Designer
// Simple code editor
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "windows.ch"
#include "guilib.ch"
#include "hxml.ch"
#include <common.ch>

#define ES_SAVESEL 0x00008000

STATIC oDlg, oEdit, cIniName
STATIC nTextLength

CLASS HDTheme

   CLASS VAR aThemes  INIT {}
   CLASS VAR nSelected
   CLASS VAR oFont
   CLASS VAR lChanged INIT .F.
   CLASS VAR aKeyWords
   DATA name
   DATA normal
   DATA command
   DATA comment
   DATA quote
   DATA number

   METHOD New(name) INLINE (::name := name, Self)
   METHOD Add(name) INLINE (::name := name, AAdd(::aThemes, Self), Self)
ENDCLASS

FUNCTION LoadEdOptions(cFileName)

   LOCAL oIni := HXMLDoc():Read(cFileName)
   LOCAL i
   LOCAL j
   LOCAL j1
   LOCAL cTheme
   LOCAL oTheme
   LOCAL oThemeXML
   LOCAL arr
   LOCAL oOptDesc

   cIniName := cFileName
   oOptDesc := oIni:aItems[1]
   FOR i := 1 TO Len(oOptDesc:aItems)
      IF oOptDesc:aItems[i]:title == "font"
         HDTheme():oFont := hfrm_FontFromxml(oOptDesc:aItems[i])
      ELSEIF oOptDesc:aItems[i]:title == "keywords"
         HDTheme():aKeyWords := hfrm_Str2Arr(oOptDesc:aItems[i]:aItems[1])
      ELSEIF oOptDesc:aItems[i]:title == "themes"
         cTheme := oOptDesc:aItems[i]:GetAttribute("selected")
         FOR j := 1 TO Len(oOptDesc:aItems[i]:aItems)
            oThemeXML := oOptDesc:aItems[i]:aItems[j]
            oTheme := HDTheme():Add(oThemeXML:GetAttribute("name"))
            IF oTheme:name == cTheme
               HDTheme():nSelected := j
            ENDIF
            FOR j1 := 1 TO Len(oThemeXML:aItems)
               arr := {oThemeXML:aItems[j1]:GetAttribute("tcolor"), ;
                       oThemeXML:aItems[j1]:GetAttribute("bcolor"), ;
                       oThemeXML:aItems[j1]:GetAttribute("bold"), ;
                       oThemeXML:aItems[j1]:GetAttribute("italic")}
               IF arr[1] != NIL
                  arr[1] := Val(arr[1])
               ENDIF
               IF arr[2] != NIL
                  arr[2] := Val(arr[2])
               ENDIF
               arr[3] := (arr[3] != NIL)
               arr[4] := (arr[4] != NIL)
               IF oThemeXML:aItems[j1]:title == "normal"
                  oTheme:normal := arr
               ELSEIF oThemeXML:aItems[j1]:title == "command"
                  oTheme:command := arr
               ELSEIF oThemeXML:aItems[j1]:title == "comment"
                  oTheme:comment := arr
               ELSEIF oThemeXML:aItems[j1]:title == "quote"
                  oTheme:quote := arr
               ELSEIF oThemeXML:aItems[j1]:title == "number"
                  oTheme:number := arr
               ENDIF
            NEXT
         NEXT
      ENDIF
   NEXT
RETURN NIL

FUNCTION SaveEdOptions(oOptDesc)

   LOCAL oIni := HXMLDoc():Read(m->cCurDir + cIniName)
   LOCAL i
   LOCAL oNode
   LOCAL nStart
   LOCAL oThemeDesc
   LOCAL aAttr

HB_SYMBOL_UNUSED(oOptDesc)

   oNode := oIni:aItems[1]
   nStart := 1
   IF oNode:Find("font", @nStart) == NIL
      oNode:Add(hwg_Font2XML(HDTheme():oFont))
   ELSE
      oNode:aItems[nStart] := hwg_Font2XML(HDTheme():oFont)
   ENDIF
   IF oNode:Find("themes", @nStart) != NIL
      oNode := oNode:aItems[nStart]
      oNode:SetAttribute("selected", HDTheme():aThemes[HDTheme():nSelected]:name)
      oNode:aItems := {}
      FOR i := 1 TO Len(HDTheme():aThemes)
         oThemeDesc := oNode:Add(HXMLNode():New("theme", , {{"name", HDTheme():aThemes[i]:name}}))
         aAttr := {{"tcolor", LTrim(Str(HDTheme():aThemes[i]:normal[1]))}, ;
                   {"bcolor", LTrim(Str(HDTheme():aThemes[i]:normal[2]))}}
         IF HDTheme():aThemes[i]:normal[3]
            AAdd(aAttr, {"bold", "True"})
         ENDIF
         IF HDTheme():aThemes[i]:normal[4]
            AAdd(aAttr, {"italic", "True"})
         ENDIF
         oThemeDesc:Add(HXMLNode():New("normal", HBXML_TYPE_SINGLE, aAttr))

         aAttr := {{"tcolor", LTrim(Str(HDTheme():aThemes[i]:command[1]))}}
         IF HDTheme():aThemes[i]:command[3]
            AAdd(aAttr, {"bold", "True"})
         ENDIF
         IF HDTheme():aThemes[i]:command[4]
            AAdd(aAttr, {"italic", "True"})
         ENDIF
         oThemeDesc:Add(HXMLNode():New("command", HBXML_TYPE_SINGLE, aAttr))

         aAttr := {{"tcolor", LTrim(Str(HDTheme():aThemes[i]:comment[1]))}}
         IF HDTheme():aThemes[i]:comment[3]
            AAdd(aAttr, {"bold", "True"})
         ENDIF
         IF HDTheme():aThemes[i]:comment[4]
            AAdd(aAttr, {"italic", "True"})
         ENDIF
         oThemeDesc:Add(HXMLNode():New("comment", HBXML_TYPE_SINGLE, aAttr))

         aAttr := {{"tcolor", LTrim(Str(HDTheme():aThemes[i]:quote[1]))}}
         IF HDTheme():aThemes[i]:quote[3]
            AAdd(aAttr, {"bold", "True"})
         ENDIF
         IF HDTheme():aThemes[i]:quote[4]
            AAdd(aAttr, {"italic", "True"})
         ENDIF
         oThemeDesc:Add(HXMLNode():New("quote", HBXML_TYPE_SINGLE, aAttr))

         aAttr := {{"tcolor", LTrim(Str(HDTheme():aThemes[i]:number[1]))}}
         IF HDTheme():aThemes[i]:number[3]
            AAdd(aAttr, {"bold", "True"})
         ENDIF
         IF HDTheme():aThemes[i]:number[4]
            AAdd(aAttr, {"italic", "True"})
         ENDIF
         oThemeDesc:Add(HXMLNode():New("number", HBXML_TYPE_SINGLE, aAttr))

      NEXT
   ENDIF
   oIni:Save(m->cCurDir + cIniName)

RETURN NIL

FUNCTION EditMethod(cMethName, cMethod)

   LOCAL i
   LOCAL lRes := .F.
   LOCAL dummy
   LOCAL oFont := HDTheme():oFont
   LOCAL cParamString
   MEMVAR oDesigner

   i := AScan(oDesigner:aMethDef, {|a|a[1] == Lower(cMethName)})
   cParamString := IIf(i == 0, "", oDesigner:aMethDef[i, 2])

   INIT DIALOG oDlg TITLE "Edit '" + cMethName + "' method"          ;
      AT 100, 240  SIZE 600, 300  FONT oDesigner:oMainWnd:oFont    ;
      STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_MAXIMIZEBOX + WS_SIZEBOX ;
      ON INIT {||hwg_MoveWindow(oDlg:handle, 100, 240, 600, 310)}        ;
      ON EXIT {||dummy := IIf(lRes := (oEdit:lChanged.AND.hwg_MsgYesNo("Code was changed! Save it?", "Designer")), cMethod := oEdit:GetText(), .F.), .T.}

   MENU OF oDlg
      MENU TITLE "&Options"
         MENUITEM "&Font" ACTION editChgFont()
         MENU TITLE "&Select theme"
            FOR i := 1 TO Len(HDTheme():aThemes)
               hwg_DefineMenuItem(HDTheme():aThemes[i]:name, 1020 + i, &("{||ChangeTheme(" + LTrim(Str(i, 2)) + "),HDTheme():lChanged:=.T.}"))
            NEXT
         ENDMENU
         MENUITEM "&Configure" ACTION EditColors()
      ENDMENU

      MENUITEM "&Parameters" ACTION IIf(!Empty(cParamString) .AND. Upper(Left(oEdit:Gettext(), 10)) != "PARAMETERS",(editShow("Parameters " + cParamString + Chr(10) + oEdit:Gettext()), oEdit:lChanged := .T.), .F.)

      MENU TITLE "&Templates " + cMethName

         MENUITEM "&Insert Field"     ACTION InsertField(1)
         MENUITEM "&Field:=xVarField" ACTION InsertField(0)

      ENDMENU

      MENUITEM "&Exit" ACTION oDlg:Close()
   ENDMENU

   @ 0, 0 RICHEDIT oEdit TEXT cMethod SIZE 400, oDlg:nHeight            ;
       STYLE WS_HSCROLL + WS_VSCROLL + ES_LEFT + ES_MULTILINE + ES_WANTRETURN ;
       ON INIT {||ChangeTheme(HDTheme():nSelected)}                 ;
       ON GETFOCUS {||IIf(oEdit:cargo,(hwg_SendMessage(oEdit:handle, EM_SETSEL, 0, 0), oEdit:cargo := .F.), .F.)} ;
       ON SIZE {|o, x, y|o:Move(,, x, y)}                                 ;
       FONT oFont
   //           STYLE ES_MULTILINE + ES_AUTOVSCROLL + ES_AUTOHSCROLL + ES_WANTRETURN + WS_VSCROLL + WS_HSCROLL
   oEdit:cargo := .T.

   // oEdit:oParent:AddEvent(EN_SELCHANGE, oEdit:id, {||EnChange(1)}, .T.)

   // oEdit:title := cMethod
   *-hwg_SetDlgKey(odlg, 0, VK_TAB, {hwg_MsgInfo("tab")})
         *-{hwg_SendMessage(oEdit:handle, EM_SETTABSTOPS, space(2), 0)})
   ACTIVATE DIALOG oDlg
   *-hwg_SetDlgKey(oEdit, 0, 9)
   IF lRes
      RETURN cMethod
   ENDIF
RETURN NIL

FUNCTION ChangeTheme(nTheme)

   IF HDTheme():nSelected != NIL
      hwg_CheckMenuItem(oDlg:handle, 1020 + HDTheme():nSelected, .F.)
   ENDIF
   hwg_CheckMenuItem(oDlg:handle, 1020 + nTheme, .T.)
   HDTheme():nSelected := nTheme
   editShow(, .T.)
RETURN NIL

STATIC FUNCTION editChgFont()

   LOCAL oFont

   IF (oFont := HFont():Select(oEdit:oFont)) != NIL
       oEdit:oFont := oFont
       hwg_SetWindowFont(oEdit:handle, oFont:handle)
       editShow(, .T.)
       // hwg_RedrawWindow(oEdit:handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
       HDTheme():oFont := oFont
       HDTheme():lChanged := .T.
   ENDIF
RETURN NIL

// hwg_RE_SetDefault(hCtrl, nColor, cName, nHeight, lBold, lItalic, lUnderline, nCharset)
// hwg_RE_SetCharFormat(hCtrl, n1, n2, nColor, cName, nHeight, lBold, lItalic, lUnderline)

STATIC FUNCTION editShow(cText, lRedraw)

   LOCAL arrHi
   LOCAL oTheme := HDTheme():aThemes[HDTheme():nSelected]

   IF lRedraw != NIL .AND. lRedraw
      // cText := oEdit:Gettext()
      nTextLength := hwg_SendMessage(oEdit:handle, WM_GETTEXTLENGTH, 0, 0) + 1
      cText := hwg_RE_GetTextRange(oEdit:handle, 1, nTextLength)
   ELSE
      IF cText == NIL
         cText := oEdit:title
      ENDIF
      nTextLength := Len(cText)
   ENDIF
   hwg_SendMessage(oEdit:handle, EM_SETEVENTMASK, 0, 0)
   hwg_RE_SetDefault(oEdit:handle, oTheme:normal[1], oEdit:oFont:name,, oTheme:normal[3], oTheme:normal[4],, oEdit:oFont:charset)
   hwg_SendMessage(oEdit:handle, EM_SETBKGNDCOLOR, 0, oTheme:normal[2])
   oEdit:SetText(cText)
   cText := hwg_RE_GetTextRange(oEdit:handle, 1, nTextLength)
   IF !Empty(arrHi := CreateHiLight(cText))
      hwg_RE_SetCharFormat(oEdit:handle, arrHi)
   ENDIF
   hwg_SendMessage(oEdit:handle, EM_SETEVENTMASK, 0, ENM_CHANGE + ENM_SELCHANGE)
   oEdit:oParent:AddEvent(EN_CHANGE, oEdit:id, {||EnChange(2)})

RETURN NIL

STATIC FUNCTION EnChange(nEvent)

   LOCAL pos := hwg_SendMessage(oEdit:handle, EM_GETSEL, 0, 0)
   LOCAL nLength
   LOCAL pos1 := hwg_LOWORD(pos) + 1
   LOCAL pos2 := hwg_HIWORD(pos) + 1
   LOCAL cBuffer
   LOCAL nLine
   LOCAL arr := {}
   LOCAL nLinePos
   LOCAL oTheme := HDTheme():aThemes[HDTheme():nSelected]
   LOCAL nEditPos1
   LOCAL nEditPos2

   IF nEvent == 1        // EN_SELCHANGE
      nEditPos1 := pos1
      nEditPos2 := pos2
   ELSE                  // EN_CHANGE
      hwg_SendMessage(oEdit:handle, EM_SETEVENTMASK, 0, 0)
      nLength := hwg_SendMessage(oEdit:handle, WM_GETTEXTLENGTH, 0, 0)
      IF nLength - nTextLength > 2
         // writelog("1: " + Str(nLength, 5) + " " + Str(nTextLength, 5))
      ELSE
         nLine := hwg_SendMessage(oEdit:handle, EM_LINEFROMCHAR, -1, 0)
         cBuffer := hwg_RE_GetLine(oEdit:handle, nLine)
         // writelog("pos: " + LTrim(Str(pos1)) + " Line: " + LTrim(Str(nline)) + " " + Str(Len(cBuffer)) + "/" + cBuffer)
         nLinePos := hwg_SendMessage(oEdit:handle, EM_LINEINDEX, nLine, 0) + 1
         AAdd(arr, {nLinePos, nLinePos + Len(cBuffer), ;
            oTheme:normal[1],,, oTheme:normal[3], oTheme:normal[4],})
         HiLightString(cBuffer, arr, nLinePos)
         IF !Empty(arr)
            hwg_RE_SetCharFormat(oEdit:handle, arr)
         ENDIF
      ENDIF
      IF nTextLength != nLength
         oEdit:lChanged := .T.
      ENDIF
      nTextLength := nLength
      hwg_SendMessage(oEdit:handle, EM_SETEVENTMASK, 0, ENM_CHANGE + ENM_SELCHANGE)
   ENDIF
   // writelog("EnChange " + Str(pos1) + " " + Str(pos2)) // + " Length: " + Str(nLength))
RETURN NIL

STATIC FUNCTION CreateHilight(cText, oTheme)

   LOCAL arr := {}
   LOCAL nPos
   LOCAL nLinePos := 1

   DO WHILE .T.
      #ifdef __XHARBOUR__
      IF (nPos := At(Chr(10), cText, nLinePos)) != 0 .OR. (nPos := At(Chr(13), cText, nLinePos)) != 0
      #else
      IF (nPos := HB_At(Chr(10), cText, nLinePos)) != 0 .OR. (nPos := HB_At(Chr(13), cText, nLinePos)) != 0
      #endif
         HiLightString(SubStr(cText, nLinePos, nPos - nLinePos), arr, nLinePos, oTheme)
         nLinePos := nPos + 1
      ELSE
         HiLightString(SubStr(cText, nLinePos), arr, nLinePos, oTheme)
         EXIT
      ENDIF
   ENDDO
RETURN arr

STATIC FUNCTION HiLightString(stroka, arr, nLinePos, oTheme)

   LOCAL nStart
   LOCAL nPos := 1
   LOCAL sLen := Len(stroka)
   LOCAL cWord

   IF oTheme == NIL
      oTheme := HDTheme():aThemes[HDTheme():nSelected]
   ENDIF

   IF Left(LTrim(stroka), 2) == "//"
      AAdd(arr, {nLinePos, nLinePos + Len(stroka), ;
          oTheme:comment[1],,, oTheme:comment[3], oTheme:comment[4],})
      RETURN arr
   ENDIF
   SET EXACT ON
   DO WHILE nPos < sLen
      cWord := NextWord(stroka, @nPos, @nStart)
      // writelog("-->" + Str(nStart) + " " + Str(nPos) + " " + Str(Len(cword)) + " " + Str(asc(cword)))
      IF !Empty(cWord)
         IF Left(cWord, 1) == '"' .OR. Left(cWord, 1) == "'"
            AAdd(arr, {nLinePos + nStart - 1, nLinePos + nPos - 1, ;
               oTheme:quote[1],,, oTheme:quote[3], oTheme:quote[4],})
         ELSEIF AScan(HDTheme():aKeyWords, Upper(cWord)) != 0
            AAdd(arr, {nLinePos + nStart - 1, nLinePos + nPos - 1, ;
               oTheme:command[1],,, oTheme:command[3], oTheme:command[4],})
         ELSEIF IsDigit(cWord)
            AAdd(arr, {nLinePos + nStart - 1, nLinePos + nPos - 1, ;
               oTheme:number[1],,, oTheme:number[3], oTheme:number[4],})
         ENDIF
      ENDIF
   ENDDO
   SET EXACT OFF

RETURN arr

STATIC FUNCTION EditColors()

   LOCAL oDlg
   LOCAL i
   LOCAL j
   LOCAL temp
   LOCAL oBtn2
   LOCAL cText := "// The code sample" + Chr(10) + ;
               "do while ++nItem < 120" + Chr(10) + ;
               "  if aItems[nItem] == 'scheme'" + Chr(10) + ;
               "    nFactor := 22.5" + Chr(10) + ;
               "  endif"

   MEMVAR oBrw
   MEMVAR oEditC
   MEMVAR oSayT
   MEMVAR oCheckB
   MEMVAR oCheckI
   MEMVAR oSayB
   MEMVAR aSchemes
   MEMVAR nScheme
   MEMVAR nType
   MEMVAR oTheme
   MEMVAR cScheme
   MEMVAR oDesigner

   PRIVATE oBrw
   PRIVATE oEditC
   PRIVATE oSayT
   PRIVATE oCheckB
   PRIVATE oCheckI
   PRIVATE oSayB
   PRIVATE aSchemes := Array(Len(HDTheme():aThemes))
   PRIVATE nScheme
   PRIVATE nType := 2
   PRIVATE oTheme := HDTheme():New()
   PRIVATE cScheme := ""

   FOR i := 1 TO Len(aSchemes)
      aSchemes[i] := {HDTheme():aThemes[i]:name, HDTheme():aThemes[i]:normal, ;
          HDTheme():aThemes[i]:command, HDTheme():aThemes[i]:comment, ;
          HDTheme():aThemes[i]:quote, HDTheme():aThemes[i]:number}
   NEXT

   INIT DIALOG oDlg TITLE "Color schemes" ;
      AT 200, 140 SIZE 440, 355  FONT oDesigner:oMainWnd:oFont ;
      ON INIT {||UpdSample()}

   @ 10, 10 BUTTON "Delete scheme" SIZE 110, 30 ON CLICK {||UpdSample(1)}

   @ 140, 10 BROWSE oBrw ARRAY SIZE 130, 80
   oBrw:bPosChanged := {||nScheme := oBrw:nCurrent, UpdSample()}
   oBrw:aArray := aSchemes
   oBrw:AddColumn(HColumn():New(, {|v, o|HB_SYMBOL_UNUSED(v), o:aArray[o:nCurrent, 1]}, "C", 15, 0, .T.))
   oBrw:lDispHead := .F.
   nScheme := oBrw:nCurrent := oBrw:rowPos := HDTheme():nSelected

   @ 290, 10 GET cScheme SIZE 110, 26
   @ 290, 40 BUTTON "Add scheme" SIZE 110, 30 ON CLICK {||UpdSample(2)}

   @ 10, 120 GROUPBOX "" SIZE 140, 140
   RADIOGROUP
   @ 20, 130 RADIOBUTTON "Normal" SIZE 120, 24 ON CLICK {||nType := 2, UpdSample(), oBtn2:Show()}
   @ 20, 154 RADIOBUTTON "Keyword" SIZE 120, 24 ON CLICK {||nType := 3, UpdSample(), oBtn2:Hide()}
   @ 20, 178 RADIOBUTTON "Comment" SIZE 120, 24 ON CLICK {||nType := 4, UpdSample(), oBtn2:Hide()}
   @ 20, 202 RADIOBUTTON "Quote" SIZE 120, 24 ON CLICK {||nType := 5, UpdSample(), oBtn2:Hide()}
   @ 20, 226 RADIOBUTTON "Number" SIZE 120, 24 ON CLICK {||nType := 6, UpdSample(), oBtn2:Hide()}
   END RADIOGROUP SELECTED 1

   @ 170, 110 GROUPBOX "" SIZE 250, 75
   @ 180, 127 SAY "Text color" SIZE 100, 24
   @ 280, 125 SAY oSayT CAPTION "" SIZE 24, 24
   @ 305, 127 BUTTON "..." SIZE 20, 20 ON CLICK {||IIf((temp := hwg_ChooseColor(aSchemes[nScheme, nType][1], .F.)) != NIL,(aSchemes[nScheme, nType][1] := temp, UpdSample()), .F.)}
   @ 180, 152 SAY "Background" SIZE 100, 24
   @ 280, 150 SAY oSayB CAPTION "" SIZE 24, 24
   @ 305, 152 BUTTON oBtn2 CAPTION "..." SIZE 20, 20 ON CLICK {||IIf((temp := hwg_ChooseColor(aSchemes[nScheme, nType][2], .F.)) != NIL,(aSchemes[nScheme, nType][2] := temp, UpdSample()), .F.)}
   @ 350, 125 CHECKBOX oCheckB CAPTION "Bold" SIZE 60, 24 ON CLICK {||aSchemes[nScheme, nType][3] := hwg_IsDlgButtonChecked(oCheckB:oParent:handle, oCheckB:id), UpdSample(), .T.}
   @ 350, 150 CHECKBOX oCheckI CAPTION "Italic" SIZE 60, 24 ON CLICK {||aSchemes[nScheme, nType][4] := hwg_IsDlgButtonChecked(oCheckI:oParent:handle, oCheckI:id), UpdSample(), .T.}

   @ 170, 190 RICHEDIT oEditC TEXT cText SIZE 250, 100 STYLE ES_MULTILINE

   @ 60, 310 BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDlg:lResult := .T., EndDialog()}
   @ 200, 310 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32

   oDlg:Activate()

   IF oDlg:lResult
      FOR i := 1 TO Len(HDTheme():aThemes)
         IF AScan(aSchemes, {|a|Lower(a[1]) == Lower(HDTheme():aThemes[i]:name)}) == 0
            ADel(HDTheme():aThemes, i)
            ASize(HDTheme():aThemes, Len(HDTheme():aThemes) - 1)
         ENDIF
      NEXT
      FOR i := 1 TO Len(aSchemes)
         j := AScan(HDTheme():aThemes, {|o|Lower(o:name) == Lower(aSchemes[i, 1])})
         IF j == 0
            HDTheme():Add(aSchemes[i, 1])
            j := Len(HDTheme():aThemes)
         ENDIF
         HDTheme():aThemes[j]:normal  := aSchemes[i, 2]
         HDTheme():aThemes[j]:command := aSchemes[i, 3]
         HDTheme():aThemes[j]:comment := aSchemes[i, 4]
         HDTheme():aThemes[j]:quote   := aSchemes[i, 5]
         HDTheme():aThemes[j]:number  := aSchemes[i, 6]
      NEXT
      HDTheme():lChanged := .T.
   ENDIF

RETURN NIL

STATIC FUNCTION UpdSample(nAction)

   MEMVAR aSchemes
   MEMVAR nScheme
   MEMVAR oBRW
   MEMVAR cScheme
   MEMVAR oSayT
   MEMVAR nType
   MEMVAR oSayB
   MEMVAR oTheme
   MEMVAR oCheckB
   MEMVAR oCheckI
   MEMVAR oEditC

   IF nAction != NIL
      IF nAction == 1
         IF Len(aSchemes) == 1
            hwg_MsgStop("Can't delete the only theme !", "Designer")
            RETURN NIL
         ENDIF
         IF hwg_MsgYesNo("Really delete the '" + aSchemes[nScheme, 1] + "' theme ?", "Designer")
            ADel(aSchemes, nScheme)
            ASize(aSchemes, Len(aSchemes) - 1)
            nScheme := oBrw:nCurrent := oBrw:rowPos := 1
            oBrw:Refresh()
         ELSE
            RETURN NIL
         ENDIF
      ELSEIF nAction == 2
         IF Empty(cScheme)
            hwg_MsgStop("You must specify the theme name !", "Designer")
            RETURN NIL
         ENDIF
         IF AScan(aSchemes, {|a|Lower(a[1]) == Lower(cScheme)}) == 0
            AAdd(aSchemes, {cScheme, AClone(aSchemes[nScheme, 2]), ;
                AClone(aSchemes[nScheme, 3]), AClone(aSchemes[nScheme, 4]), ;
                AClone(aSchemes[nScheme, 5]), AClone(aSchemes[nScheme, 6])})
            oBrw:Refresh()
         ELSE
            hwg_MsgStop("The " + cScheme + " theme exists already !", "Designer")
            RETURN NIL
         ENDIF
      ENDIF
   ENDIF

   oSayT:SetColor(, aSchemes[nScheme, nType][1], .T.)
   oSayB:SetColor(, aSchemes[nScheme, nType][2], .T.)
   hwg_CheckDlgButton(oCheckB:oParent:handle, oCheckB:id, aSchemes[nScheme, nType][3])
   hwg_CheckDlgButton(oCheckI:oParent:handle, oCheckI:id, aSchemes[nScheme, nType][4])

   oTheme:normal  := aSchemes[nScheme, 2]
   oTheme:command := aSchemes[nScheme, 3]
   oTheme:comment := aSchemes[nScheme, 4]
   oTheme:quote   := aSchemes[nScheme, 5]
   oTheme:number  := aSchemes[nScheme, 6]
   hwg_RE_SetDefault(oEditC:handle, oTheme:normal[1],,, oTheme:normal[3], oTheme:normal[4])
   hwg_SendMessage(oEditC:handle, EM_SETBKGNDCOLOR, 0, oTheme:normal[2])
   hwg_RE_SetCharFormat(oEditC:handle, CreateHiLight(oEditC:GetText(), oTheme))
RETURN NIL


STATIC FUNCTION InsertField(nModus)

   LOCAL cDBF := hwg_MsgGet("DBF Name", "input table name")

HB_SYMBOL_UNUSED(nModus)

  IF FILE(cDBF)

   hwg_MsgInfo("later..")


  ELSE
        hwg_MsgInfo(cDBF + chr(13) + "Not Found")
  ENDIF

  RETURN (NIL)


#pragma BEGINDUMP

   #include "hbapi.h"
   #include <windows.h>
   #include <string.h>

int At_Any( char* cFind, char* cStr, int* nPos)
{
   char c;
   int i;
   int iLen = strlen(cFind);

   while( ( c = *( cStr + (*nPos) ) ) != 0 )
   {
      for( i = 0; i < iLen; i ++ )
         if( c == *( cFind + i ) )
            break;
      if( i < iLen )
         break;
      (*nPos) ++;
   }

   return ( (c)? 1:0 );
}

HB_FUNC(NEXTWORD)
{
   char *cSep = " \t,.()[]+-/%";
   char *cStr  = (char*) hb_parc(1);
   char *ptr, *ptr1;
   int nPos = hb_parni( 2 ) - 1;

   ptr = cStr + nPos;
   while( *ptr && strchr( cSep,*ptr ) )
   {
      ptr++;
      nPos++;
   }
   if( *ptr == '\'' || *ptr == '\"' )
   {
      ptr1 = strchr( ptr + 1,*ptr );
      if( ptr1 )
      {
         nPos = ptr1 - cStr + 1;
         hb_retclen(ptr, ptr1 - ptr + 1);
      }
      else
      {
         nPos = strlen(cStr);
         hb_retc(ptr);
      }
   }
   else if( At_Any( cSep, cStr,&nPos ) )
      hb_retclen(ptr, nPos - (ptr - cStr));
   else
      hb_retc(ptr);
   hb_storni( nPos + 1, 2 );
   hb_storni( ptr - cStr + 1, 3 );
}

#pragma ENDDUMP
