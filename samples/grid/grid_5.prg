//
// HWGUI - Harbour Win32 GUI library source code:
// HGrid class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
// Copyright 2004 Rodrigo Moreno <rodrigo_moreno@yahoo.com>
//
// This sample show how to edit records with grid control
//

#include "hwgui.ch"

#define GET_FIELD   1
#define GET_LABEL   2
#define GET_PICT    3
#define GET_EDIT    4
#define GET_VALID   5
#define GET_LIST    6
#define GET_LEN     7
#define GET_TYPE    8
#define GET_VALUE   9
#define GET_HEIGHT 10
#define GET_OBJECT 11

STATIC oMain
STATIC oForm
STATIC oBrowse

#xcommand ADD COLUMN TO GRIDEDIT <aGrid> ;
            FIELD <cField>               ;
            [ LABEL <cLabel> ]           ;
            [ PICTURE <cPicture> ]       ;
            [ <lReadonly:READONLY> ]     ;
            [ VALID <bValid> ]           ;
            [ LIST <aList> ]             ;
          => ;
          AAdd(<aGrid>, {<cField>, <cLabel>, <cPicture>, <.lReadonly.>, <{bValid}>, <aList>})

FUNCTION Main()

   INIT WINDOW oMain MAIN TITLE "Grid Edition Sample" ;
      AT 0, 0 ;
      SIZE hwg_GetDesktopWidth(), hwg_GetDesktopHeight() - 28

   MENU OF oMain
      MENUITEM "&Exit" ACTION oMain:Close()
      MENUITEM "&Demo" ACTION Test()
   ENDMENU

   ACTIVATE WINDOW oMain

RETURN NIL

FUNCTION Test()

   LOCAL aItems := {}
   LOCAL i

    PREPARE FONT oFont NAME "Courier New" WIDTH 0 HEIGHT -11

    Ferase("temp.dbf")

    DBCreate("temp.dbf", {{"field_1", "N", 10, 0}, ;
	                  {"field_2", "C", 30, 0}, ;
	                  {"field_3", "L", 1, 0}, ;
	                  {"field_4", "D", 8, 0}, ;
	                  {"field_5", "M", 10, 0}})

    use temp new

    For i := 1 to 100
        append blank
        REPLACE field_1 WITH i
        REPLACE field_2 WITH "Test " + Str(i)
        REPLACE field_3 WITH Mod(i, 10) == 0
        REPLACE field_4 WITH Date() + i
        REPLACE field_5 WITH "Memo Test"
    Next

    commit

    ADD COLUMN TO GRIDEDIT aItems FIELD "Field_1" LABEL "Number" LIST {"List 1", "List 2"}
    ADD COLUMN TO GRIDEDIT aItems FIELD "Field_2" LABEL "Char" PICTURE "@!" //READONLY
    ADD COLUMN TO GRIDEDIT aItems FIELD "Field_3" LABEL "Bool"
    ADD COLUMN TO GRIDEDIT aItems FIELD "Field_4" LABEL "Date"
    ADD COLUMN TO GRIDEDIT aItems FIELD "Field_5" LABEL "Memo"

    INIT DIALOG oForm CLIPPER NOEXIT TITLE "Grid Edit";
        FONT oFont ;
        AT 0, 0 SIZE 700, 425 ;
        STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

        @ 10, 10 GRID oGrid OF oForm SIZE 680, 375;
                ITEMCOUNT LastRec() ;
                ON KEYDOWN {|oCtrl, key|OnKey(oCtrl, key, aItems)} ;
                ON CLICK {|oCtrl|OnClick(oCtrl, aItems)} ;
                ON DISPINFO {|oCtrl, nRow, nCol|OnDispInfo(oCtrl, nRow, nCol)}

        ADD COLUMN TO GRID oGrid HEADER "Number" WIDTH 100
        ADD COLUMN TO GRID oGrid HEADER "Descr"  WIDTH 250
        ADD COLUMN TO GRID oGrid HEADER "Bool"   WIDTH 70
        ADD COLUMN TO GRID oGrid HEADER "Date"   WIDTH 100
        ADD COLUMN TO GRID oGrid HEADER "Memo"   WIDTH 200

        @  10, 395 BUTTON "Insert" SIZE 75, 25 ON CLICK {||OnKey(oGrid, VK_INSERT, aItems)}
        @  90, 395 BUTTON "Change" SIZE 75, 25 ON CLICK {||OnClick(oGrid, aItems)}
        @ 170, 395 BUTTON "Delete" SIZE 75, 25 ON CLICK {||OnKey(oGrid, VK_DELETE, aItems)}

        @ 620, 395 BUTTON "Close" SIZE 75, 25 ON CLICK {||oForm:close()}

    ACTIVATE DIALOG oForm

RETURN NIL

FUNCTION GridEdit(cAlias, aFields, lAppend, bChange)

   LOCAL i
   LOCAL cField
   LOCAL nSay := 0
   LOCAL nGet := 0
   LOCAL cType
   LOCAL nLen
   LOCAL nRowSize := 30
   LOCAL nGetSize := 10
   LOCAL oForm
   LOCAL nRow := 10
   LOCAL nCol
   LOCAL nHeight := 0
   LOCAL cValid
   LOCAL nStyle := 0
   LOCAL nArea := Select()

    DBSelectArea(cAlias)

    IF lAppend
        DBAppend()
    ELSE
        rlock()
    ENDIF

    /* set the highest say and get */
    FOR i := 1 TO Len(aFields)
        ASize(aFields[i], 12)

        nSay := Max(nSay, Len(aFields[i, GET_LABEL]))

        cType := Fieldtype(Fieldpos(aFields[i, GET_FIELD]))

        IF Empty(aFields[i, GET_PICT])

            IF cType == "M"
                nLen := 50
            ELSEIF cType == "D"
                nLen := 15
            ELSEIF cType == "L"
                nLen := 5
            ELSE
                nLen := FieldLen(Fieldpos(aFields[i, GET_FIELD]))
            ENDIF

        ELSE
            nLen := Len(transform(Fieldget(FieldPos(aFields[i, GET_FIELD])), aFields[i, GET_PICT]))

        ENDIF

        nGet := Max(nGet, nLen)

        aFields[i, GET_LEN] := nLen
        aFields[i, GET_TYPE] := cType
        aFields[i, GET_HEIGHT] := IIf(cType == "M", 150, 25)
        aFields[i, GET_VALUE] := Fieldget(FieldPos(aFields[i, GET_FIELD]))

        nHeight += aFields[i, GET_HEIGHT]
    NEXT
    
    nHeight += 5 * Len(aFields) + 15 + 30
    nRow := 10
    nCol := nSay * nGetSize

    INIT DIALOG oForm CLIPPER TITLE "Teste";
        FONT oFont ;
        AT 0, 0 ;
        SIZE Min(hwg_GetDesktopWidth() - 50, (nSay + nGet) * nGetSize + nGetSize), ;
             Min(hwg_GetDesktopHeight() - 28, nheight) ;
        STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

        For i := 1 to Len(aFields)
            @   10, nRow SAY aFields[i, GET_LABEL] SIZE Len(aFields[i, GET_LABEL]) * nGetSize, 25

            cType := Fieldtype(Fieldpos(aFields[i, GET_FIELD]))

            IF cType == "N" .AND. aFields[i, GET_LIST] != NIL
                aFields[i, GET_OBJECT] := HComboBox():New(oForm, ;
                            3000 + i, ;
                            aFields[i, GET_VALUE], ;
                            FieldBlock(aFields[i, GET_FIELD]), ;
                            IIf(!aFields[i, GET_EDIT], NIL, WS_DISABLED), ;
                            nCol, ;
                            nRow, ;
                            aFields[i, GET_LEN] * nGetSize, ;
                            Min(150, Len(aFields[i, GET_LIST]) * 25 + 25), ;
                            aFields[i, GET_LIST], ;
                            NIL, ;
                            NIL, ;
                            NIL, ;
                            NIL, ;
                            {|value, oCtrl|__valid(value, oCtrl, aFields, bChange)}, ;
                            NIL)

            ELSEIF cType == "L"
                aFields[i, GET_OBJECT] := HCheckButton():New(oForm, ;
                            3000 + i, ;
                            aFields[i, GET_VALUE], ;
                            FieldBlock(aFields[i, GET_FIELD]), ;
                            IIf(!aFields[i, GET_EDIT], NIL, WS_DISABLED), ;
                            nCol, ;
                            nRow, ;
                            aFields[i, GET_LEN] * nGetSize, ;
                            aFields[i, GET_HEIGHT], ;
                            "", ;
                            NIL, ;
                            NIL, ;
                            NIL, ;
                            NIL, ;
                            {|value, oCtrl|__valid(value, oCtrl, aFields, bChange)}, ;
                            NIL, ;
                            NIL, ;
                            NIL)

            ELSEIF cType = "D"
                aFields[i, GET_OBJECT] := HDatePicker():New(oForm, ;
                            3000 + i, ;
                            aFields[i, GET_VALUE], ;
                            FieldBlock(aFields[i, GET_FIELD ]), ;
                            IIf(!aFields[i, GET_EDIT], NIL, WS_DISABLED), ;
                            nCol, ;
                            nRow, ;
                            aFields[i, GET_LEN] * nGetSize, ;
                            aFields[i, GET_HEIGHT], ;
                            NIL, ;
                            NIL, ;
                            NIL, ;
                            {|value, oCtrl|__valid(value, oCtrl, aFields, bChange)}, ;
                            NIL, ;
                            NIL, ;
                            NIL)
            ELSE
                IF cType == "M"
                    nStyle := WS_VSCROLL + WS_HSCROLL + ES_AUTOHSCROLL + ES_MULTILINE
                ENDIF

                IF aFields[i, GET_EDIT]
                    nStyle += WS_DISABLED
                ENDIF

                aFields[i, GET_OBJECT] := HEdit():New(oForm, ;
                            3000 + i, ;
                            aFields[i, GET_VALUE], ;
                            FieldBlock(aFields[i, GET_FIELD]), ;
                            nStyle, ;
                            nCol, ;
                            nRow, ;
                            aFields[i, GET_LEN] * nGetSize, ;
                            aFields[i, GET_HEIGHT], ;
                            NIL, ;
                            NIL, NIL, NIL, ;
                            NIL, ;
                            {|value, oCtrl|__valid(value, oCtrl, aFields, bChange)}, ;
                            NIL, ;
                            NIL, ;
                            NIL, ;
                            aFields[i, GET_PICT], ;
                            .F.)
            ENDIF

            nRow += aFields[i, GET_HEIGHT] + 5

        Next

        @ oForm:nWidth - 160, oForm:nHeight - 30 BUTTON "Ok"     ID IDOK SIZE 75, 25
        @ oForm:nWidth -  80, oForm:nHeight - 30 BUTTON "Cancel" ID IDCANCEL SIZE 75, 25 ON CLICK {||oForm:Close()}

        oForm:bActivate := {||hwg_SetFocus(aFields[1, GET_OBJECT]:handle)}

    ACTIVATE DIALOG oForm                
    
    IF oForm:lResult
        DBCommit()
    ELSEIF lAppend
        Delete
    ELSE
        /* When canceled, reverte record to old information */
        For i := 1 TO Len(aFields)
            Fieldput(Fieldpos(aFields[i, GET_FIELD]), aFields[i, GET_VALUE])
        Next
    ENDIF

    Unlock
    DBSelectArea(nArea)
    
RETURN oForm:lResult

STATIC FUNCTION __valid(value, oCtrl, aFields, bChange)

   LOCAL result := .T.
   LOCAL i
   LOCAL n
   LOCAL oGet
   LOCAL val

    IF hb_IsObject(oCtrl)
        n := oCtrl:id - 3000

        Eval(bChange, oCtrl, n)

        IF aFields[n, GET_VALID] != NIL
            IF !Eval(aFields[n, GET_VALID])
                result := .F.
                oGet := aFields[n, GET_OBJECT]

                oGet:setfocus()
            ENDIF
        ENDIF

        FOR i := 1 TO Len(aFields)
            val := Fieldget(fieldpos(aFields[i, GET_FIELD]))

            IF hb_IsDate(val) .AND. Empty(val)
                Fieldput(Fieldpos(aFields[i, GET_FIELD]), Date())
            ENDIF

            oGet := aFields[i, GET_OBJECT]

            IF oGet:id != oCtrl:id .OR. hb_IsDate(val)
                oGet:refresh()
            ENDIF
        NEXT
    ENDIF

RETURN result

STATIC FUNCTION OnDispInfo(oCtrl, nRow, nCol)

   LOCAL result := ""

   DBGoto(nRow)

   IF nCol == 1
      result := Str(field->field_1)
   ELSEIF nCol == 2
      result := field->field_2
   ELSEIF nCol == 3
      result := IIf(field->field_3, "Y", "N")
   ELSEIF nCol == 4
      result := DToC(field->field_4)
   ELSEIF nCol == 5
      result := MemoLine(field->field_5, 100, 1)
   ENDIF

RETURN result

STATIC FUNCTION OnKey(o, k, aItems)

    IF k == VK_INSERT
        IF GridEdit("temp", aItems, .T., {|oCtrl, colpos|myblock(oCtrl, colpos)})
            o:SetItemCount(lastrec())
        ELSE
            MyDelete()
        ENDIF
    ELSEIF k == VK_DELETE .AND. hwg_MsgYesNo("Delete this record ?", "Warning")
        MyDelete()
    ENDIF

RETURN NIL

STATIC FUNCTION OnClick(o, aItems)

    GridEdit("temp", aItems, .F., {|oCtrl, colpos|myblock(oCtrl, colpos)})

RETURN NIL

STATIC FUNCTION myblock(oCtrl, colpos)

    IF colpos == 3
        replace field_5 with "hello"
    ENDIF

RETURN NIL

STATIC FUNCTION mydelete()

    DELETE
    PACK
    oGrid:SetItemCount(Lastrec())

RETURN NIL
