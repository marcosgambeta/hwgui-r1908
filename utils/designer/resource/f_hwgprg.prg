#script WRITE
#debug

FUNCTION Font2Str

   PARAMETERS oFont

   RETURN " ;" + _Chr(10) + Space(8) + ;
      "FONT HFont():Add( '" + oFont:name + "'," + LTrim(Str(oFont:width, 5)) + "," + ;
      LTrim(Str(oFont:height, 5)) + "," + IIf(oFont:weight != 0, LTrim(Str(oFont:weight, 5)), "") + "," + ;
      IIf(oFont:charset != 0, LTrim(Str(oFont:charset, 5)), "") + "," + ;
      IIf(oFont:italic != 0, LTrim(Str(oFont:italic, 5)), "") + "," + ;
      IIf(oFont:underline != 0, LTrim(Str(oFont:underline, 5)), "") + ")"

   ENDFUNC

FUNCTION Menu2Prg

   PARAMETERS oCtrl, alMenu

   PRIVATE stroka := ""
   PRIVATE i
   PRIVATE j
   PRIVATE cName
   PRIVATE temp
   PRIVATE cMethod
   PRIVATE oNode
   // PRIVATE almenu

   //            [ ACCELERATOR <flag>, <key> ] ;
   //            [<lDisabled: DISABLED>]       ;

   i := 1
   IF hb_IsArray(aLMenu[i, 1])
      stroka := Space(2) + "  MENU TITLE '" + aLMenu[i, 2] + "' ID " + Str(aLMenu[i, 3]) + " "
      FWrite(han, _Chr(10) + stroka)
   ENDIF

   DO WHILE i <=  Len(aLMenu)

      IF hb_IsArray(aLMenu[i, 1])
         //BuildTree(oNode, aMenu[i, 1])
         stroka := Space(2 * nMaxid) + "  MENU TITLE '" + aLMenu[i, 2] + "' ID " + Str(aLMenu[i, 3]) + " "
         FWrite(han, _Chr(10) + stroka)
         nMaxId += 1
         hwg_CallFunc("Menu2Prg", {oCtrl, alMenu[i, 1]})
         nMaxId -= 1
         stroka := Space(2 * nmaxid) + "  ENDMENU  "
         FWrite(han, _Chr(10) + stroka)
      ELSE
         IF alMenu[i, 2] != "-"
            stroka := Space(2 * nMaxId + 2) + "MENUITEM '" + alMenu[i, 2] + "' ID " + LTrim(Str(alMenu[i, 3])) + "  "
            IF !Empty(alMenu[i, 4])
               // Methods ( events ) for the control
               cMethod := "ACTION ( "
               temp := StrTran(alMenu[i, 4], Chr(10), ", ")
               temp := StrTran(temp, Chr(13), "")
               stroka := stroka + cMethod + temp + " ) "
            ELSE
               stroka := stroka + 'ACTION ""'
            ENDIF
         ELSE
            stroka := Space(4 + nMaxId) + "SEPARATOR"
         ENDIF
         FWrite(han, _Chr(10) + stroka + " ")
      ENDIF
      i ++
   ENDDO

   RETURN

   ENDFUNC

FUNCTION Tool2Prg

   PARAMETERS oCtrl
   LOCAL nLocalParamPos := 0
   LOCAL lsubParameter := .F.
   PRIVATE cLocalParam := ""
   PRIVATE cFormParameters := ""

   PRIVATE cName := ""
   PRIVATE cTool := ""
   PRIVATE cId := ""
   PRIVATE temp
   PRIVATE i
   PRIVATE j
   PRIVATE k
   PRIVATE cTip
   PRIVATE oCtrl1
   PRIVATE aMethods

   // PRIVATE crelexpr
   // PRIVATE clink
   // PRIVATE cfilter
   // PRIVATE cKey

   cName := Trim(oCtrl:GetProp("Name"))
   //cTool += "    *- " + cname + _CHR(10)+ "    *- SCRIPT GERADO AUTOMATICAMENTE PELO DESIGNER" + _CHR(10) + "    *-  " + _CHR(10)
   IF cName == NIL .OR. Empty(cName)
      RETURN cTool
   ENDIF

   cId := Val(IIf((temp := oCtrl:GetProp("Id")) != NIL .AND. !Empty(temp), temp, "700"))
   FWrite(han, " ID " + LTrim(Str(cid)))
   //<O>:AddButton(<nBitIp>,<nId>,<bstate>,<bstyle>,<ctext>,<bclick>,<c>,<d>)
   IF Len(oCtrl:aControls) > 0
      FWrite(han, _CHR(10) + cTool)
      i := 1
      DO WHILE i <= Len(oCtrl:aControls)
         cName := Trim(oCtrl:GetProp("Name"))
         oCtrl1 := oCtrl:aControls[i]
         cTool += Space(4) + cname + ":AddButton("
         cTool += IIf((temp := oCtrl1:GetProp("Bitmap")) != NIL .AND. !Empty(temp), temp, "1") + ", "
         cTool += LTrim(Str(cId + i)) + ", "
         cTool += IIf((temp := oCtrl1:GetProp("State")) != NIL .AND. !Empty(temp), temp, "4") + ", "
         cTool += IIf((temp := oCtrl1:GetProp("Style")) != NIL .AND. !Empty(temp), temp, "0") + ", "
         cTool += IIf((temp := oCtrl1:GetProp("Caption")) != NIL .AND. !Empty(temp), '"' + temp + '"', '" "') + " "
         cTip  := IIf((temp := oCtrl1:GetProp("ToolTip")) != NIL .AND. !Empty(temp), "'" + temp + "'", "")
         // Methods ( events ) for the control
         k := 1
         aMethods := {}
         DO WHILE k <= Len(oCtrl1:aMethods)
            IF oCtrl1:aMethods[k, 2] != NIL .AND. !Empty(oCtrl1:aMethods[k, 2])

               IF Lower(Left(oCtrl1:aMethods[k, 2], 10)) == "parameters"
                  // Note, do we look for a CR or a LF??
                  j := At(_Chr(13), oCtrl1:aMethods[k, 2])
                  temp := SubStr(oCtrl1:aMethods[k, 2], 12, j - 12)

               ELSEIF Lower(Left(oCtrl1:aMethods[k, 2], 1)) == "("
                  // Note, do we look for a CR or a LF??
                  j := At(")", oCtrl1:aMethods[k, 2])
                  cLocalParam := SubStr(oCtrl1:aMethods[k, 2], 1, j)
                  temp := ""
                  lsubParameter := .T.

               ELSE
                  temp := ""
               ENDIF
               IF !Empty(oCtrl1:GetProp("LocalOnClickParam"))
                  cFormParameters := oCtrl1:GetProp("LocalOnClickParam")
               ENDIF

               //cMethod := " " + Upper(SubStr(oCtrl:aMethods[i, 1], 1))
               IF hb_IsChar(cName := hwg_Callfunc("FUNC_NAME", {oCtrl1, k}))
                  IF !Empty(cLocalParam)
                     // SubStr(oCtrl1:aMethods[k, 2], 1, j)
                     IF lsubParameter
                        temp :=  " {|" + temp + "| " +  cName + "(" + cFormParameters + ")  }"
                     ELSE
                        temp :=  " {|" + temp + "| " +  cName + cLocalParam + "  }"
                     ENDIF
                     IF lsubParameter
                        lsubParameter := .F.
                     ENDIF
                  ELSE
                     temp :=  " {|" + temp + "| " +  cName + "( " + temp + " ) }"
                  ENDIF
               ELSE
                  temp := " {|" + temp + "| " + IIf(Len(cName) == 1, cName[1], cName[2]) + " }"
               ENDIF
               AAdd(aMethods, {Lower(oCtrl1:aMethods[k, 1]), temp})
            ENDIF
            k ++
         ENDDO
         //IF  k > 1
         //        IF !Empty(cFormParameters)
         //                          cTool += ",{||" + cFormParameters + "}")
         //        ELSE
         cTool += "," + hwg_CallFunc("Bloco2Prg", {aMethods, "onClick"})
         //        ENDIF
         //ELSE
         //  cTool += ",{|| .T. }"
         //ENDIF
         cTool += "," + cTip + ",''"
         FWrite(han, cTool + ")" + _CHR(10))
         cTool := ""
         i ++
      ENDDO
      //cTool := "    *- FIM DE " + cname + _CHR(10)
      cTool := ""  //_CHR(10)
   ENDIF

   RETURN cTool

   ENDFUNC

FUNCTION Browse2Prg

   PARAMETERS oCtrl
#define BRW_ARRAY 1
#define BRW_DATABASE 2

   PRIVATE cName := ""
   PRIVATE cBrowser := ""
   PRIVATE cAdd := ""
   PRIVATE temp
   PRIVATE i
   PRIVATE j
   PRIVATE k
   PRIVATE nColumns
   PRIVATE caArray
   PRIVATE cAlias
   PRIVATE cTmpAlias
   PRIVATE oCtrl1
   PRIVATE crelexpr
   PRIVATE clink
   PRIVATE cfilter
   PRIVATE cKey
   PRIVATE nType
   PRIVATE aTypes
   PRIVATE cType
   PRIVATE nLength
   PRIVATE aWidths
   PRIVATE nDec
   PRIVATE lOpen := .F.
   PRIVATE nColunas
   PRIVATE cHeader
   PRIVATE cCampo
   PRIVATE aMethods

   PRIVATE aBrwXml := {"Alias", "ColumnsCount", "HeadRows", "FooterRows", "ShowHeader", ;
      "ShowGridLinesSep", "GridLinesSep3D", "HeadTextColor", "GridLinesSepColor", ;
      "LeftCol", "ColumnsFreeze", "AdjRight"}

   PRIVATE aBrwProp :=  {"alias", "nColumns", "nHeadRows", "nFootRows", "lDispHead", "lDispSep", ;
      "lSep3d", "headColor", "sepColor", "nLeftCol", "freeze", "lAdjRight"}

   cName := Trim(oCtrl:GetProp("Name"))

//   cBrowser += "    // " + cname + "    *- SCRIPT GERADO AUTOMATICAMENTE PELO DESIGNER" + _CHR(10) + "    //  " + _CHR(10)
   nType := IIf(oCtrl:GetProp("BrwType") != "dbf", BRW_ARRAY, BRW_DATABASE)
   IF cName == NIL .OR. Empty(cName) .OR. ((cAlias := oCtrl:GetProp("FileDbf")) == NIL .AND. nType = BRW_DATABASE)
      RETURN cBrowser
   ENDIF

   nColumns := IIf((temp := oCtrl:GetProp("ColumnsCount")) != NIL .AND. !Empty(temp), Val(temp), 0)
   nColunas := nColumns
   cBrowser += Space(4) + cname + ":aColumns := {}" + _chr(10)

   j := 3
   DO WHILE j < Len(aBrwProp)
      temp := oCtrl:GetProp(aBrwXml[j])
      IF temp  != NIL .AND. !Empty(temp)
         cBrowser += Space(4) + cname + ":" + aBrwProp[j] + ":= " + ;
            IIf(temp = "True", ".T.", IIf(temp = "False", ".F.", temp)) + _chr(10)
      ENDIF
      j ++
   ENDDO

   IF nType = BRW_DATABASE
      cAlias := Left(hwg_CutPath(cAlias), At(".", hwg_CutPath(cAlias)) - 1)
      cAlias := Lower(Trim(IIf((temp := oCtrl:GetProp("alias")) != NIL .AND. !Empty(temp), temp, calias)))
      cBrowser += Space(4) + cname + ":alias := '" + calias + "'" + _chr(10)
      // abrir tablea
      //     IF (temp := oCtrl:GetProp("filedbf")) != NIL //.AND. !Empty(temp)
      //      cTmpAlias := Lower(Left(hwg_CutPath(temp), At(".", hwg_CutPath(temp)) - 1))
      //      IF select(cTmpalias) = 0
      //        USE (value) NEW SHARED ALIAS (cTmpAlias) VIA "DBFCDX" //ftmp
      //SET INDEX TO (cTmpAlias)
      //hwg_MsgInfo(ALIAS())
      //        lopen := .T.
      //      ENDIF
      //USE (temp) NEW ALIAS ftmp SHARED
      //      SELECT (cTmpAlias)
      //     ELSE
      //       RETURN  ""
      //     ENDIF
      //calias := alias()
      nColumns := IIf(nColumns = 0, IIf(Len(oCtrl:aControls) = 0, &cTmpalias->(FCount()), Len(oCtrl:aControls)), nColumns)
      cBrowser += Space(4) + cname + ":nColumns := " + LTrim(Str(nColumns)) + _chr(10)
      cBrowser += Space(4) + "IF select(" + cname + ":alias) = 0 ; USE ('" + temp + "') NEW ALIAS (" + cname + ":alias) SHARED ;ENDIF" + _CHR(10)
      cBrowser += Space(4) + "SELECT (" + cname + ":alias) " + _CHR(10)
      //
      aTypes := &cTmpalias->(dbStruct())

      // CRIAR AS RELA�OES E O LINK
      temp := IIf((temp := oCtrl:GetProp("childorder")) != NIL .AND. !Empty(temp), Trim(temp), "")
      cKey := ""
      IF !Empty(temp)
         cBrowser += Space(4) + calias + "->(DBSETORDER('" + temp + "'))" + _chr(10)
         &calias->(dbSetOrder(temp))
         cKey := &calias->(OrdKey(temp))
         ckey := IIf(At("+", ckey) > 0, Left(ckey, At("+", ckey) - 1), ckey)
      ENDIF
      crelexpr := IIf((temp := oCtrl:GetProp("relationalexpr")) != NIL .AND. !Empty(temp), Trim(temp), cKey)
      clink := IIf((temp := oCtrl:GetProp("linkmaster")) != NIL .AND. !Empty(temp), Trim(temp), "")
      IF !Empty(crelexpr) .AND. !Empty(clink)
         cBrowser += "    *-  LINK --> RELACIONAMENTO E FILTER " + _CHR(10)
         cBrowser += Space(4) + clink + "->(DBSETRELATION('" + calias + "', {|| " + crelexpr + "},'" + crelexpr + "')) " + _chr(10)
         cfilter := crelexpr + "=" + clink + "->(" + crelexpr + ")"
         cBrowser += Space(4) + calias + "->(DBSETFILTER( {|| " + cfilter + "}, '" + cfilter + "' ))" + _chr(10) + "    *-" + _CHR(10)
      ENDIF
      // fim dos relacionamentos
   ELSE
      caArray := Trim(IIf((temp := oCtrl:GetProp("aarray")) != NIL .AND. !Empty(temp), temp, "{}" ) )
      cBrowser += Space(4) + cname + ":aArray := " + caArray + "" + _chr(10)
      nColumns := IIf(nColumns = 0, 1, nColumns)
   ENDIF

   IF Len(oCtrl:aControls) = 0 //nColunas = 0 // gerar automaticamente o BROWSE completo
      i := 1
      DO WHILE i <= nColumns
         IF nType = BRW_DATABASE
            cBrowser += Space(4) + cname + ":AddColumn( HColumn():New(FieldName(" + LTrim(Str(i)) + ") ,FieldBlock(FieldName(" + LTrim(Str(i)) + "))," + ;
               "'" + aTypes[i, 2] + "'," + LTrim(Str(aTypes[i, 3] + 1)) + "," + LTrim(Str(aTypes[i, 4])) + "))" + _chr(10) //,,,,,,,,, {|| .T.}))
         ELSE
            cBrowser += Space(4) + cname + ":AddColumn( HColumn():New( ,{|v,o|Iif(v!=NIL,o:aArray[o:nCurrent]:=v,o:aArray[o:nCurrent])},'C', 100,0))" + _CHR(10)
         ENDIF
         i ++
      ENDDO
      cBrowser :=  _CHR(10) + cBrowser + "    *- FIM DE " + cname
   ELSE
      FWrite(han, _chr(10) + _CHR(10) + cbrowser)
      i := 1
      DO WHILE i <= Len(oCtrl:aControls)
         cName := Trim(oCtrl:GetProp("Name"))
         oCtrl1 := oCtrl:aControls[i]
         cHeader := IIf((temp := oCtrl1:GetProp("Heading")) != NIL, "'" + temp + "'", "")
         cCampo  := Lower(IIf((temp := oCtrl1:GetProp("FieldName")) != NIL .AND. !Empty(temp), "" + temp + "", FieldName(i)))
         cCampo  := Lower(IIf((temp := oCtrl1:GetProp("FieldExpr")) != NIL .AND. !Empty(temp), "" + temp + "", ccampo))
         m->nLength := IIf((temp := oCtrl1:GetProp("Length")) != NIL, Val(temp), temp)
         IF nType = BRW_DATABASE
            cType  := Type("&cCampo")
            IF !(cAlias == cTmpAlias) .AND. cTmpAlias $ cCampo
               cCampo := StrTran(cCampo, cTmpAlias, cAlias)
            ENDIF
            temp := StrTran(Upper(cCampo), Upper(cAlias) + "->", "")
            // verificar se tem mais de um campo
            temp := SubStr(temp, 1, IIf(At("+", temp) > 0, At("+", temp) - 1, Len(temp)))
            j := {}
            AEval(aTypes, {|aField|AAdd(j, aField[1])})
            cHeader  := IIf(cHeader == NIL .OR. Empty(cHeader), '"' + temp + '"', "" + cHeader + "")
            IF m->nLength == NIL
               m->nLength := &cTmpAlias->(fieldlen(AScan(j, temp)))
               m->nLength := IIf(m->nLength = 0, IIf(Type("&cCampo") = "C", Len(&cCampo), 10), m->nLength)
            ENDIF
            m->nDec := &cTmpAlias->(FIELDDEC(AScan(j, temp)))
            cCampo := "{|| " + cCampo + " }"
            //cBrowser := SPACE(4) + cname + ":AddColumn(HColumn():New(" + cHeader + ",{|| " + cCampo + " }," + "'" + aTypes[i] + "'," + ;
            //      IIf((temp := oCtrl1:GetProp("Length")) != NIL, LTrim(Str(Val(temp))), "10") + ", " + ;
            //      LTrim(Str(aDecimals[i])) + " "
         ELSE
            cCampo := IIf(cCampo == NIL, ".T.", cCampo)
            cCampo := IIf(Type("&cCampo") = "B", cCampo, "{|| " + cCampo + " }")
            cType  := Type("&cCampo")
            m->nLength := IIf(m->nLength == NIL, 10, m->nLength)
            m->nDec := 0
         ENDIF
         IF (temp := oCtrl1:GetProp("Picture")) != NIL .AND. At(".9", temp) > 0
            m->nDec := Len(SubStr(temp, At(".9", temp) + 1))
            //cType := "N"
         ENDIF
         //cBrowser := SPACE(4) + cname + ":AddColumn( HColumn():New(" + cHeader + ",{|| " + cCampo + " }," + "'" + TYPE("&cCampo") + "'," +
         cBrowser := Space(4) + cname + ":AddColumn( HColumn():New(" + cHeader + ", " + cCampo + " ," + "'" + cTYPE + "'," + ;
            LTrim(Str(m->nLength)) + ", " + LTrim(Str(m->nDec)) + " "
         cbrowser += "," + IIf((temp := oCtrl1:GetProp("Editable")) != NIL, IIf(temp = "True", ".T.", ".F."), ".T.")
         cbrowser += "," + IIf((temp := oCtrl1:GetProp("JustifyHeader")) != NIL, LTrim(Str(Val(temp))), "")
         cbrowser += "," + IIf((temp := oCtrl1:GetProp("JustifyLine")) != NIL, LTrim(Str(Val(temp))), "")
         cbrowser += "," + IIf((temp := oCtrl1:GetProp("Picture")) != NIL .AND. !Empty(temp), "'" + Trim(temp) + "'", "")
         //Fwrite(han, +_Chr(10) + cbrowser)

         // Methods ( events ) for the control
         k := 1
         aMethods := {}
         DO WHILE k <= Len(oCtrl1:aMethods)
            IF oCtrl1:aMethods[k, 2] != NIL .AND. !Empty(oCtrl1:aMethods[k, 2])
               IF Lower(Left(oCtrl1:aMethods[k, 2], 10)) == "parameters"
                  // Note, do we look for a CR or a LF??
                  j := At(_Chr(13), oCtrl1:aMethods[k, 2])
                  temp := SubStr(oCtrl1:aMethods[k, 2], 12, j - 12)
               ELSE
                  temp := ""
               ENDIF
               //cMethod := " " + Upper(SubStr(oCtrl:aMethods[i, 1], 1))
               IF hb_IsChar(cName := hwg_Callfunc("FUNC_NAME", {oCtrl1, k}))
                  temp :=  " {|" + temp + "| " +  cName + "( " + temp + " ) }"
               ELSE
                  temp := " {|" + temp + "| " + IIf(Len(cName) == 1, cName[1], cName[2]) + " }"
               ENDIF
               AAdd(aMethods, {Lower(oCtrl1:aMethods[k, 1]), temp})
            ENDIF
            k ++
         ENDDO
         cbrowser += "," + hwg_CallFunc("Bloco2Prg", {aMethods, "onLostFocus"})
         cbrowser += "," + hwg_CallFunc("Bloco2Prg", {aMethods, "onGetFocus"})
         cbrowser += "," + IIf((temp := oCtrl1:GetProp("Items")) != NIL, temp, "")
         cbrowser += "," + hwg_CallFunc("Bloco2Prg", {aMethods, "ColorBlock"})
         cbrowser += "," + hwg_CallFunc("Bloco2Prg", {aMethods, "HeadClick"})
         //cbrowser += "))"
         FWrite(han, cbrowser + "))" + _CHR(10))
         //( <cHeader>,<block>,<cType>,<nLen>,<nDec>,<.lEdit.>,<nJusHead>, <nJusLine>, <cPict>, <{bValid}>, <{bWhen}>, <aItem>, <{bClrBlck}>, <{bHeadClick}> ) )
         i ++
      ENDDO
      cBrowser := "    *- FIM DE " + cname + _CHR(10)
   ENDIF
   IF nType = BRW_DATABASE .AND.  lOpen
      USE
   ENDIF

   RETURN cBrowser

   ENDFUNC

FUNCTION Bloco2Prg

   PARAMETERS aMetodos, cmetodo

   // Methods ( events ) for the control
   PRIVATE z
   PRIVATE temp

   z := AScan(aMetodos, {|aVal|aVal[1] == Lower(cmetodo)})
   temp := IIf(z > 0, aMetodos[z, 2], "")

   RETURN TEMP

   ENDFUNC

FUNCTION Imagem2Prg

   PARAMETERS oCtrl

   PRIVATE cImagem := ""
   PRIVATE temp := ""

   IF oCtrl:cClass == "form"
      temp := oCtrl:GetProp("icon")
      IF !Empty(temp)
         //cImagem += IIf(oCtrl:GetProp("lResource") := "True"," ICON HIcon():AddResource('" + temp + "') "," ICON " + temp + " ")
         cImagem += " ICON " + IIf(At(".", temp) != 0, "HIcon():AddFile('" + temp + "') ", "HIcon():AddResource('" + temp + "') ")
      ENDIF
      temp := oCtrl:GetProp("bitmap")
      IF !Empty(temp)
         //cImagem += " BACKGROUND BITMAP HBitmap():AddFile('" + temp + "') "
         cImagem += " BACKGROUND BITMAP " + IIf(At(".", temp) != 0, "HBitmap():AddFile('" + temp + "') ", "HBitmap():AddResource('" + temp + "') ")
      ENDIF

   ELSEIF oCtrl:cClass == "editbox" .OR. oCtrl:cClass == "richedit"

   ELSEIF oCtrl:cClass == "updown"

   ELSEIF oCtrl:cClass == "button" .OR. oCtrl:cClass == "ownerbutton"

   ENDIF

   IF Len(cImagem) > 0
      cImagem := ";" + _CHR(10) + Space(8) + cImagem
   ENDIF

   RETURN cImagem

   ENDFUNC

FUNCTION Color2Prg

   PARAMETERS oCtrl

   PRIVATE cColor := ""
   PRIVATE xProperty := ""

   IF oCtrl:GetProp("Textcolor", @j) != NIL .AND. !IsDefault(oCtrl, oCtrl:aProp[j])
      cColor += IIf(Empty(cStyle), "", ";" + _Chr(10) + Space(8)) + ;
         " COLOR " + LTrim(Str(oCtrl:tcolor)) + " "
   ENDIF
   IF oCtrl:GetProp("Backcolor", @j) != NIL .AND. !IsDefault(oCtrl, oCtrl:aProp[j])
      cColor += " BACKCOLOR " + LTrim(Str(oCtrl:bcolor))
   ENDIF
   IF oCtrl:cClass == "link"
      IF oCtrl:GetProp("VisitColor", @j) != NIL .AND. !IsDefault(oCtrl, oCtrl:aProp[j])
         cColor += IIf(Empty(cStyle), "", ";" + _Chr(10) + Space(8)) + ;
            " VISITCOLOR " + LTrim(Str(oCtrl:tcolor)) + " "
      ENDIF
      IF oCtrl:GetProp("LinkColor", @j) != NIL .AND. !IsDefault(oCtrl, oCtrl:aProp[j])
         cColor += " LINKCOLOR " + LTrim(Str(oCtrl:bcolor))
      ENDIF
      IF oCtrl:GetProp("HoverColor", @j) != NIL .AND. !IsDefault(oCtrl, oCtrl:aProp[j])
         cColor += " HOVERCOLOR " + LTrim(Str(oCtrl:bcolor))
      ENDIF
   ENDIF
   IF Len(Trim(cColor)) > 0
      cColor := ";" + _CHR(10) + Space(8)  + cColor //SubStr(cStyle, 2)
   ENDIF

   RETURN cColor

   ENDFUNC

FUNCTION Style2Prg

   PARAMETERS oCtrl

   PRIVATE cStyle := ""
   PRIVATE xProperty := ""

   cStyle := cStyle + IIf(oCtrl:GetProp("multiline") = "True" .OR. oCtrl:GetProp("wordwrap") = "True", "+ES_MULTILINE ", "")
   IF oCtrl:cClass == "label"
      cStyle := cStyle + IIf(oCtrl:GetProp("Justify") = "Center", "+SS_CENTER ", "")
      cStyle := cStyle + IIf(oCtrl:GetProp("Justify") = "Right", "+SS_RIGHT ", "")
      cStyle += IIf(oCtrl:oContainer != NIL .AND. oCtrl:oContainer:cclass != NIL .AND. oCtrl:oContainer:cclass = "page", "+SS_OWNERDRAW ", "")
   ELSE  //IF oCtrl:cClass == "editbox" .OR. oCtrl:cClass == "richedit"
      cStyle := cStyle + IIf(oCtrl:GetProp("Justify") = "Center", "+ES_CENTER ", "")
      cStyle := cStyle + IIf(oCtrl:GetProp("Justify") = "Right", "+ES_RIGHT ", "")
   ENDIF
   //ELSEIF oCtrl:cClass == "updown"
   IF oCtrl:cClass = "button" .OR. oCtrl:cClass == "ownerbutton" .OR. oCtrl:cClass == "shadebutton"
      cStyle := cStyle + "+WS_TABSTOP"
      cStyle := cStyle + IIf(oCtrl:GetProp("3DLook") = "False", "+BS_FLAT ", "")
   ELSE
      cStyle := cStyle + IIf(oCtrl:GetProp("Enabled") = "False", "+WS_DISABLED ", "")
   ENDIF

   IF oCtrl:cClass == "checkbox"
      cStyle := cStyle + IIf(oCtrl:GetProp("alignment") = "Top", "+BS_TOP ", ;
         IIf(oCtrl:GetProp("alignment") = "Bottom", "+BS_BOTTOM ", " "))
      cStyle := cStyle + IIf("Right" $ oCtrl:GetProp("alignment"), "+BS_RIGHTBUTTON ", " ")
      cStyle := cStyle + IIf(oCtrl:GetProp("3DLook") = "True", "+BS_PUSHLIKE ", " ")
   ENDIF
   cStyle := cStyle + IIf(oCtrl:GetProp("autohscroll") = "True", "+ES_AUTOHSCROLL ", "")
   cStyle := cStyle + IIf(oCtrl:GetProp("autovscroll") = "True", "+ES_AUTOVSCROLL ", "")
   cStyle := cStyle + IIf(oCtrl:GetProp("barshscroll") = "True", "+WS_HSCROLL ", "")
   cStyle := cStyle + IIf(oCtrl:GetProp("barsvscroll") = "True", "+WS_VSCROLL ", "")
   cStyle := cStyle + IIf(oCtrl:GetProp("VSCROLL") = "True", "+WS_VSCROLL ", "")
   cStyle := cStyle + IIf(oCtrl:GetProp("Border") = "True" .AND. oCtrl:cClass != "browse", "+WS_BORDER ", "")
   cStyle := cStyle + IIf(oCtrl:GetProp("readonly") = "True", "+ES_READONLY ", "")
   cStyle := cStyle + IIf(oCtrl:GetProp("autohscroll") = "True" .AND. oCtrl:cClass == "browse", "+WS_HSCROLL ", "")
   IF oCtrl:cClass == "page"
      cStyle := cStyle + IIf((xproperty := oCtrl:GetProp("TabOrientation")) != NIL, "+" + LTrim(Str(Val(xProperty))) + " ", " ")
      cStyle := cStyle + IIf((xproperty := oCtrl:GetProp("TabStretch")) != NIL, "+" + LTrim(Str(Val(xProperty))) + " ", " ")
   ENDIF
   IF oCtrl:cClass == "datepicker"
      cStyle := cStyle + IIf((xproperty := oCtrl:GetProp("Layout")) != NIL, "+" + LTrim(Str(Val(xProperty))) + " ", " ")
      cStyle := cStyle + IIf(oCtrl:GetProp("checked") = "True", "+DTS_SHOWNONE ", " ")
   ENDIF
   IF oCtrl:cClass == "trackbar"
      cStyle := cStyle + IIf(oCtrl:GetProp("TickStyle") = "Auto", "+ 1 ", ;
         IIf(oCtrl:GetProp("TickStyle") = "None", "+ 16", "+ 0"))
      cStyle := cStyle + IIf(oCtrl:GetProp("TickMarks") = "Both", "+ 8 ", ;
         IIf(oCtrl:GetProp("TickMarks") = "Top", "+ 4", "+ 0"))
   ENDIF
   IF Len(Trim(cStyle)) > 0  //.AND. VAL(&(SubStr(cStyle, 1))) > 0
      cStyle := ";" + _CHR(10) + Space(8) +  "STYLE " + SubStr(cStyle, 2)
   ELSE
      cStyle := ""
   ENDIF

   RETURN cStyle

   ENDFUNC

FUNCTION Func_name

   PARAMETERS oCtrl, nMeth

   PRIVATE cName
   PRIVATE arr := hwg_ParseMethod(oCtrl:aMethods[nMeth, 2])

   IF Len(arr) == 1 .OR. (Len(arr) == 2 .AND. ;
         Lower(Left(arr[1], 11)) == "parameters ")

      RETURN arr

   ELSE
      IF (cName := Trim(oCtrl:GetProp("Name"))) == NIL .OR. Empty(cName)
         cName := oCtrl:cClass + "_" + LTrim(Str(oCtrl:id - 34000))
      ENDIF

      cName += "_" + oCtrl:aMethods[nMeth, 1]

   ENDIF

   RETURN cName

   ENDFUNC

FUNCTION Ctrl2Prg

   PARAMETERS oCtrl
   LOCAL nLocalParamPos := 0
   LOCAL lAddVar := .F.
   LOCAL lsubParameter := .F.

   PRIVATE cLocalParam := ""
   PRIVATE cFormParameters := ""

   PRIVATE stroka := "   @ "
   PRIVATE classname
   PRIVATE cStyle
   PRIVATE i
   PRIVATE j
   PRIVATE cName
   PRIVATE temp
   PRIVATE varname
   PRIVATE cMethod
   PRIVATE nLeft
   PRIVATE nTop
   PRIVATE nWidth
   PRIVATE nHeight
   PRIVATE lGroup

   i := AScan(aClass, oCtrl:cClass)

   IF i  != 0
      varname := oCtrl:GetProp("varName")

      nLeft := oCtrl:nLeft
      nTop := oCtrl:nTop
      temp := oCtrl:oContainer
      DO WHILE temp != NIL
         lGroup := IIf(temp:GetProp("NoGroup") != NIL .AND. temp:GetProp("NoGroup") == "True", .F., .T.)
         IF temp:lContainer
            nLeft -= temp:nLeft
            nTop -= temp:nTop
            lgroup := .T.
         ENDIF
         temp := temp:oContainer
      ENDDO
      IF !Empty(oCtrl:GetProp("LocalOnClickParam"))
         cFormParameters := oCtrl:GetProp("LocalOnClickParam")
      ENDIF

      stroka += LTrim(Str(nLeft)) + "," + LTrim(Str(nTop)) + " "

      IF oCtrl:cClass == "editbox" .OR. oCtrl:cClass == "richedit"
         temp := oCtrl:GetProp("cInitValue")
      ELSEIF oCtrl:cClass != "ownerbutton" .AND. oCtrl:cClass != "shadebutton"
         temp := oCtrl:GetProp("Caption")
      ENDIF
      IF (cName := Trim(oCtrl:GetProp("Name"))) == NIL .OR. oCtrl:cClass = "radiogroup"
         cName := ""
      ENDIF

      // verificar se o combo tem check
      //IF oCtrl:cClass == "combobox"
      // aName[i] := IIf(oCtrl:GetProp("check") != NIL, {"GET COMBOBOXEX", "GET COMBOBOXEX"}, {"COMBOBOX", "GET COMBOBOX"})
      //ENDIF

      IF oCtrl:cClass != "radiogroup"      // NANDO
         IF varname == NIL .OR. Empty(varName)
            stroka += aName[i, 1] + " " + IIf(oCtrl:cClass != "timer" .AND. oCtrl:cClass != "listbox", cName, "")       //+
            IF oCtrl:cClass != "richedit"
               stroka += IIf(temp != NIL, IIf(!Empty(cName), ' CAPTION "' + temp,' "' + temp) + '"', "") + " "
            ELSE
               stroka += IIf(temp != NIL, IIf(!Empty(cName), ' TEXT "' + temp,' "' + temp) + '"', "") + " "
            ENDIF
            IF oCtrl:cClass == "browse"
               stroka += IIf(oCtrl:GetProp("BrwType") != "dbf", "ARRAY ", "DATABASE ")
            ENDIF

         ELSE
            IF oCtrl:cClass != "richedit"
               stroka += aName[i, 2] + " " + IIf(!Empty(cName), cName + IIf(oCtrl:cClass != "listbox", " VAR " + varname + " ", " "), " ")
            ELSE
               stroka += aName[i, 2] + " " + IIf(!Empty(cName), cName + " TEXT ", " ") + varname + " "
            ENDIF
         ENDIF
      ELSE
         // NANDO
         stroka +=  aName[i, 1] + " " + IIf(temp != NIL, '"' + temp + '"', "") + " "
      ENDIF

      IF oCtrl:cClass = "checkbox" .AND. varname != NIL
         stroka +=  IIf(temp != NIL, IIf(!Empty(cName), ' CAPTION "' + temp,' "' + temp) + '"', "") + " "
      ENDIF
      // butoes
      IF oCtrl:cClass == "button" .OR. oCtrl:cClass == "ownerbutton" .OR. oCtrl:cClass == "shadebutton"
         stroka += IIf((temp := oCtrl:GetProp("Id")) != NIL .AND. !Empty(temp), " ID " + temp, "") + " "
      ENDIF
      //
      nHeight := 1
      IF oCtrl:cClass == "combobox" .OR. oCtrl:cClass == "listbox"
         cStyle := IIf((temp := oCtrl:GetProp("aSort")) != NIL .AND. temp = "True", "ASORT(", "")
         IF (temp := oCtrl:GetProp("VarItems")) != NIL .AND. !Empty(temp)
            stroka += "ITEMS " + cStyle + Trim(temp) + IIf(cStyle == "", " ", ") ")
         ELSEIF (temp := oCtrl:GetProp("Items")) != NIL .AND. !Empty(temp)
            stroka += ";" + _chr(10) + Space(8) + "ITEMS " + cStyle + "{" + '"' + temp[1] + '"'
            j := 2
            DO WHILE j <= Len(temp)
               stroka += ',"' + temp[j] + '"'
               j ++
            ENDDO
            stroka += "}" + IIf(cStyle == "", " ", ") ")
         ELSE
            stroka += " ITEMS {}"
         ENDIF
         IF oCtrl:cClass == "listbox"
            stroka += "INIT " + IIf(varName != NIL, Trim(varname) + " ", "1 ")
         ENDIF
      ENDIF

      IF oCtrl:cClass == "page"
         stroka += "ITEMS {} "
      ENDIF
      // != "Group"
      IF oCtrl:cClass == "bitmap"
         IF (temp := oCtrl:GetProp("Bitmap")) != NIL
            // cImagem += " BACKGROUND BITMAP " + IIf(At(".", temp) != 0, "HBitmap():AddFile('" + temp + "') ", "HBitmap():AddResource('" + temp + "') ")
            stroka += " ;" + _Chr(10) + Space(8) + "SHOW " + IIf(At(".", Trim(temp)) != 0, "HBitmap():AddFile('" + temp + "') ", "'" + temp + "' ")
            IF (temp := oCtrl:GetProp("lResource")) != NIL .AND. temp = "True"
               stroka += " FROM RESOURCE "
            ENDIF
            stroka += " ;" + _Chr(10) + Space(8)
         ENDIF
      ENDIF

      IF oCtrl:oContainer != NIL
         //IF oCtrl:cClass != "group" .OR. (oCtrl:cClass == "group" .AND.(temp := oCtrl:GetProp("NoGroup" )) != NIL .AND. temp == "False") //nando pos condicao do OR->
         IF (oCtrl:cClass != "group" .AND.  Empty(cofGroup)) .OR. Empty(cofGroup) // nando pos
            IF (temp := oCtrl:oContainer:GetProp("Name")) == NIL .OR. Empty(temp)
               IF oCtrl:oContainer:oContainer != NIL
                  temp := oCtrl:oContainer:oContainer:GetProp("Name")
               ENDIF
            ENDIF
            cofGroup := IIf(Empty(cofGroup), temp, cofGroup)
         ELSE
            temp := cofGroup
         ENDIF
         stroka += IIf(lGroup, "OF " + temp + " ", "")
         //ENDIF
      ELSE
         // colocar o group para depois dos demais objetos
         IF !Empty(cGroup)
            FWrite(han, _Chr(10) + cGroup)
         ENDIF
         cofgroup := ""
         cGroup := ""
      ENDIF
      // ANTES DO SIZE
      // BASSO
      IF oCtrl:cClass == "link"
         IF (temp := oCtrl:GetProp("Link")) != NIL .AND. !Empty(temp)
            stroka += " ;" + _Chr(10) + Space(8) + "LINK '" + Trim(temp) + "' "
         ENDIF
      ENDIF
      stroka += IIf(oCtrl:GetProp("Transparent") = "True", " TRANSPARENT ", " ")
      //oCtrl:cClass == "label" .OR.
      //
      IF oCtrl:cClass == "updown"
         stroka += "RANGE "
         temp := oCtrl:GetProp("nLower") //) != NIL
         stroka += LTrim(Str(IIf(temp == NIL, - 2147483647, Val(temp)), 11)) + ","
         temp := oCtrl:GetProp("nUpper") //) != NIL
         stroka += LTrim(Str(IIf(temp == NIL, 2147483647, Val(temp)), 11)) + " "
      ENDIF
      //
      IF oCtrl:cClass == "combobox"
         IF (temp := oCtrl:GetProp("checkEX")) != NIL
            stroka += ";" + _chr(10) + Space(8) + "CHECK {" + '"' + temp[1] + '"'
            j := 2
            DO WHILE j <= Len(temp)
               stroka += ',"' + temp[j] + '"'
               j ++
            ENDDO
            stroka += "} "
         ENDIF
         IF (temp := oCtrl:GetProp("nMaxLines")) != NIL
            nHeight :=  Val(temp)
         ELSE
            nHeight := 4
         ENDIF
         IF oCtrl:GetProp("lEdit") = "True"
            stroka += " EDIT ;" + _CHR(10) + Space(8)
         ENDIF
         IF oCtrl:GetProp("lText") = "True"
            stroka += " TEXT "
         ENDIF
      ENDIF
      //

      IF oCtrl:cClass == "line"
         IF (temp := oCtrl:GetProp("lVertical")) != NIL .AND. temp == "True"
            stroka += "LENGTH " + LTrim(Str(oCtrl:nHeight)) + " VERTICAL "
         ELSE
            stroka += "LENGTH " + LTrim(Str(oCtrl:nWidth)) + " "
         ENDIF
      ELSE
         // aqui que esta o SIZE
         stroka += "SIZE " + LTrim(Str(oCtrl:nWidth)) + "," + LTrim(Str(oCtrl:nHeight * nHeight)) + " "
      ENDIF

      stroka += hwg_CallFunc("Style2Prg", {oCtrl}) + " "
      // barraprogress
      IF (temp := oCtrl:GetProp("BarWidth")) != NIL //.AND. temp == "True"
         stroka += " BARWIDTH " + temp
      ENDIF
      IF (temp := oCtrl:GetProp("Range")) != NIL
         stroka += " QUANTITY " + temp
      ENDIF
      // TRACKBALL
      IF  oCtrl:cClass == "trackbar"
         nLeft   := oCtrl:GetProp("Lower")
         nTop    := oCtrl:GetProp("Upper")
         IF nLeft != NIL .AND. nTop != NIL
            stroka += " ;" + _Chr(10) + Space(8) + "RANGE " + LTrim(nLeft) + ", " + LTrim(nTop)
         ENDIF
         IF (temp := oCtrl:GetProp("lVertical")) != NIL .AND. temp == "True"
            stroka += " VERTICAL "
         ENDIF
      ENDIF
      //
      IF oCtrl:cClass != "ownerbutton" .AND. oCtrl:cClass != "shadebutton"

         stroka += hwg_CallFunc("Color2Prg", {oCtrl}) + " "

      ENDIF
      //
      IF oCtrl:cClass == "ownerbutton" .OR. oCtrl:cClass == "shadebutton"
         IF (temp := oCtrl:GetProp("Flat")) != NIL .AND. temp == "True"
            stroka += " FLAT "
         ENDIF
         IF (temp := oCtrl:GetProp("lCheck")) != NIL .AND. temp == "True"
            stroka += " CHECK "
         ENDIF
         IF (temp := oCtrl:GetProp("enabled")) != NIL .AND. temp == "False"
            stroka += " DISABLED "
         ENDIF

         IF oCtrl:cClass == "shadebutton"
            //temp := ""
            stroka += " ;" + _Chr(10) + Space(8)
            stroka += IIf((temp := oCtrl:GetProp("Effect")) != NIL, " EFFECT " + temp + " ", "")
            stroka += IIf((temp := oCtrl:GetProp("Palette")) != NIL, " PALETTE " + temp + " ", "")
            stroka += IIf((temp := oCtrl:GetProp("Granularity")) != NIL, " GRANULARITY " + temp + " ", "")
            stroka += IIf((temp := oCtrl:GetProp("Highlight")) != NIL, " HIGHLIGHT " + temp + " ", "")
            //stroka += IIf(!Empty(temp), " ;" + _Chr(10) + Space(8), "")
         ENDIF

         IF (temp := oCtrl:GetProp("Caption")) != NIL //.AND. !Empty(caption)
            stroka += " ;" + _Chr(10) + Space(8) + "TEXT '" + Trim(temp) + "' "

            IF oCtrl:GetProp("Textcolor", @j) != NIL .AND. !IsDefault(oCtrl, oCtrl:aProp[j])
               stroka += "COLOR " + LTrim(Str(oCtrl:tcolor)) + " "
            ENDIF
            // VERIFICAR COORDENADAS
            nLeft   := oCtrl:GetProp("TextLeft")
            nTop    := oCtrl:GetProp("TextTop")
            nHeight := '0'
            nWidth  := '0'
            IF nLeft != NIL .AND. nTop != NIL
               stroka += " ;" + _Chr(10) + Space(8) + "COORDINATES " + LTrim(nLeft) + ", " + LTrim(nTop) + ;
                  IIf(oCtrl:cClass != "shadebutton", ", " + LTrim(nHeight) + ", " + LTrim(nWidth) + " ", " ")
            ENDIF
         ENDIF
         // VERIFICAR BMP
         IF (temp := oCtrl:GetProp("BtnBitmap")) != NIL .AND. !Empty(temp)
            nLeft   := oCtrl:GetProp("BmpLeft")
            nTop    := oCtrl:GetProp("BmpTop")
            nHeight := '0'
            nWidth  := '0'
            //IF nLeft != NIL .AND. nTop != NIL
            stroka += " ;" + _Chr(10) + Space(8) + "BITMAP " + "HBitmap():AddFile('" + temp + "') "
            IF oCtrl:GetProp("lResource") = "True"
               stroka += " FROM RESOURCE "
            ENDIF
            stroka +=  IIf(oCtrl:cClass != "shadebutton", " TRANSPARENT ", "")
            stroka += " ;" + _Chr(10) + Space(8) + "COORDINATES " + ;
               LTrim(nLeft) + ", " + LTrim(nTop) + ", " + LTrim(nHeight) + ", " + LTrim(nWidth) + " "
         ENDIF
         //ENDIF
      ENDIF

      IF oCtrl:cClass == "buttonex"
         IF !Empty((temp := oCtrl:GetProp("bitmap")))
            //cImagem += " BACKGROUND BITMAP HBitmap():AddFile('" + temp + "') "
            stroka += " ;" + _Chr(10) + Space(8) + "BITMAP " + "(HBitmap():AddFile('" + temp + "')):handle "
            IF !Empty((temp := oCtrl:GetProp("pictureposition")))
               stroka += " ;" + _Chr(10) + Space(8) + "BSTYLE " + Left(temp, 1)
            ENDIF
         ENDIF
      ENDIF

      IF oCtrl:cClass == "editbox" .OR. oCtrl:cClass == "updown"
         IF (cName := oCtrl:GetProp("cPicture")) != NIL .AND. !Empty(cName)
            stroka += "PICTURE '" + AllTrim(oCtrl:GetProp("cPicture")) + "' "
         ENDIF
         IF (cName := oCtrl:GetProp("nMaxLength")) != NIL
            stroka += "MAXLENGTH " + LTrim(oCtrl:GetProp("nMaxLength")) + " "
         ENDIF
         IF oCtrl:cClass == "editbox"
            stroka += IIf(oCtrl:GetProp("password") = "True", " PASSWORD ", " ")
            stroka += IIf(oCtrl:GetProp("border") = "False", " NOBORDER ", " ")
         ENDIF
      ENDIF
      IF oCtrl:cClass == "browse"
         stroka += IIf(oCtrl:GetProp("Append") = "True", "APPEND ", " ")
         stroka += IIf(oCtrl:GetProp("Autoedit") = "True", "AUTOEDIT ", " ")
         stroka += IIf(oCtrl:GetProp("MultiSelect") = "True", "MULTISELECT ", " ")
         stroka += IIf(oCtrl:GetProp("Descend") = "True", "DESCEND ", " ")
         stroka += IIf(oCtrl:GetProp("NoVScroll") = "True", "NO VSCROLL ", " ")
         stroka += IIf(oCtrl:GetProp("border") = "False", "NOBORDER ", " ")
      ENDIF

      IF (temp := oCtrl:GetProp("Font")) != NIL
         stroka += hwg_CallFunc("FONT2STR", {temp})
      ENDIF

      // tooltip
      IF oCtrl:cClass != "label"
         IF (temp := oCtrl:GetProp("ToolTip")) != NIL .AND. !Empty(temp)
            stroka += "; " + _chr(10) + Space(8) + "TOOLTIP '" + temp + "'"
         ENDIF
      ENDIF

      // BASSO
      IF oCtrl:cClass == "animation"
         stroka += " OF " + cFormName
         //FWrite(han, _Chr(10) + "   ADD STATUS " + cName + " TO " + cFormName + " ")
         IF (temp := oCtrl:GetProp("Filename")) != NIL
            stroka += " ;" + _Chr(10) + Space(8) + "FILE '" + Trim(temp) + "' "
            stroka += " ;" + _Chr(10) + Space(8)
            stroka += IIf(oCtrl:GetProp("autoplay") = "True", "AUTOPLAY ", "")
            stroka += IIf(oCtrl:GetProp("center") = "True", "CENTER ", "")
            stroka += IIf(oCtrl:GetProp("transparent") = "True", "TRANSPARENT ", "")
         ENDIF
      ENDIF
      //
      IF oCtrl:cClass == "status"
         stroka := ""
         cname := oCtrl:GetProp("Name")
         FWrite(han, _Chr(10) + "   ADD STATUS " + cName + " TO " + cFormName + " ")
         IF (temp := oCtrl:GetProp("aParts")) != NIL
            FWrite(han, " ; ")
            stroka += Space(8) + "PARTS " + temp[1]
            j := 2
            DO WHILE j <= Len(temp)
               stroka += ', ' + temp[j]
               j ++
            ENDDO
         ENDIF
      ENDIF
      IF oCtrl:cClass == "group" .AND. oCtrl:oContainer == NIL  //.AND. Empty(oCtrl:aControls)
         // enviar para tras
         cGroup += stroka
      ELSE
         FWrite(han, _Chr(10))
         FWrite(han, stroka)
      ENDIF
      // Methods ( events ) for the control
      i := 1
      DO WHILE i <= Len(oCtrl:aMethods)
         // NANDO POS PARA TIRAR COISAS QUE N�O TEM EM GETS
         IF Upper(SubStr(oCtrl:aMethods[i, 1], 3)) = "INIT" .AND. (oCtrl:cClass == "combobox")
            i ++
            LOOP
         ENDIF
         //
         IF oCtrl:aMethods[i, 2] != NIL .AND. !Empty(oCtrl:aMethods[i, 2])
            IF Lower(Left(oCtrl:aMethods[i, 2], 10)) == "parameters"

               // Note, do we look for a CR or a LF??
               j := At(_Chr(10), oCtrl:aMethods[i, 2])

               temp := SubStr(oCtrl:aMethods[i, 2], 12, j - 13)
            ELSEIF Lower(Left(oCtrl:aMethods[i, 2], 1)) == "("
               // Note, do we look for a CR or a LF??
               j := At(")", oCtrl:aMethods[i, 2])
               cLocalParam := SubStr(oCtrl:aMethods[i, 2], 1, j)
               temp := ""
               lsubParameter := .T.
            ELSE
               temp := ""
            ENDIF

            IF varname != NIL .AND. (Lower(oCtrl:aMethods[i, 1]) == "ongetfocus" ;
                  .OR. Lower(oCtrl:aMethods[i, 1]) == "onlostfocus")

               cMethod := IIf(Lower(oCtrl:aMethods[i, 1]) == "ongetfocus", "WHEN ", "VALID ")

            ELSE

               cMethod := "ON " + Upper(SubStr(oCtrl:aMethods[i, 1], 3))

            ENDIF

            IF hb_IsChar(cName := hwg_Callfunc("FUNC_NAME", {oCtrl, i}))
               //
               IF oCtrl:cClass == "timer"
                  stroka := " {|" + temp + "| " + cName + "( " + temp + " ) }"
                  cname := oCtrl:GetProp("Name")
                  temp := oCtrl:GetProp("interval") //) != NIL
                  stroka := "ON INIT {|| " + cName + " := HTimer():New( " + cFormName + ",," + IIf(temp != NIL, temp, '0') + "," + stroka + " )}"
                  FWrite(han, " ; //OBJECT TIMER " + _Chr(10) + Space(8) + stroka)
               ELSE
                  IF lsubParameter
                     //temp :=  " {|" + temp + "| " + cName + "(" + cFormParameters + ")  }"
                     FWrite(han, " ;" + _Chr(10) + Space(8) + cMethod + "{ ||" + cName + "(" + cFormParameters + ")  }")
                  ELSE

                     FWrite(han, " ; " + _Chr(10) + Space(8) + cMethod + " {|" + temp + "| " + ;
                        cName + "( " + temp + " ) }")
                  ENDIF
               ENDIF
            ELSE
               //
               IF oCtrl:cClass == "timer"
                  stroka := IIf(cName != NIL, " {|" + temp + "| " + ;
                     IIf(Len(cName) == 1, cName[1], cName[2]) + " }", " ")
                  cname := oCtrl:GetProp("Name")
                  temp := oCtrl:GetProp("value") //) != NIL
                  //ON INIT {|| oTimer1 := HTimer():New(otESTE,, 5000, {|| OtIMER1:END(), hwg_MsgInfo('oi'), enddialog() })}
                  stroka := "ON INIT {|| " + cName + " := HTimer():New( " + cFormName + ",," + temp + "," + stroka + " )}"
                  FWrite(han, " ; //OBJECT TIMER " + _Chr(10) + Space(8) + stroka)
               ELSE

                  IF lsubParameter
                     //temp :=  " {|" + temp + "| " + cName + "(" + cFormParameters + ")  }"
                     FWrite(han, " ;" + _Chr(10) + Space(8) + cMethod + "{ ||" + cName + "(" + cFormParameters + ")  }")
                  ELSE
                     FWrite(han, " ;" + _Chr(10) + Space(8) + cMethod + " {|" + temp + "| " +  IIf(Len(cName) == 1, cName[1], cName[2]) + " }")
                  ENDIF

               ENDIF
            ENDIF

         ENDIF
         i ++
      ENDDO

   ENDIF
   // gerar o codigo da TOOLBAR
   IF oCtrl:cClass == "toolbar"
      stroka := hwg_CallFunc("Tool2Prg", {oCtrl})
      FWrite(han, _chr(10) + stroka)
   ENDIF

   // gerar o codigo do browse
   IF oCtrl:cClass == "browse"
      stroka := hwg_CallFunc("Browse2Prg", {oCtrl})
      FWrite(han, _chr(10) + stroka)
   ENDIF

   IF !Empty(oCtrl:aControls)

      IF oCtrl:cClass == "page" .AND. ;
            (temp := oCtrl:GetProp("Tabs")) != NIL .AND. !Empty(temp)
         //stroka := hwg_CallFunc("Style2Prg", {oCtrl}) + " "
         //Fwrite(han, stroka)
         j := 1
         DO WHILE j <= Len(temp)
            FWrite(han, _Chr(10) + "  BEGIN PAGE '" + temp[j] + "' OF " + oCtrl:GetProp("Name"))

            i := 1
            DO WHILE i <= Len(oCtrl:aControls)
               IF oCtrl:aControls[i]:nPage == j
                  hwg_CallFunc("Ctrl2Prg", {oCtrl:aControls[i]})
               ENDIF
               i ++
            ENDDO

            FWrite(han, _Chr(10) + "  END PAGE OF " + oCtrl:GetProp("Name") + _Chr(10))
            j ++
         ENDDO
         RETURN
      ELSEIF oCtrl:cClass == "radiogroup"
         varname := oCtrl:GetProp("varName")
         IF varname == NIL
            FWrite(han, _Chr(10) + "  RADIOGROUP")
         ELSE
            FWrite(han, _Chr(10) + "  GET RADIOGROUP " + varname)
         ENDIF
      ENDIF

      i := 1
      DO WHILE i <= Len(oCtrl:aControls)
         hwg_CallFunc("Ctrl2Prg", {oCtrl:aControls[i]})
         i ++
      ENDDO

      IF oCtrl:cClass == "radiogroup"
         temp := oCtrl:GetProp("nInitValue")
         FWrite(han, _Chr(10) + "  END RADIOGROUP SELECTED " + IIf(temp == NIL, "1", temp) + _Chr(10))
      ENDIF
   ENDIF

   RETURN

   ENDFUNC



   // Entry point into interpreted code ------------------------------------


   PRIVATE han
   PRIVATE fname := oForm:path + oForm:filename
   PRIVATE stroka
   PRIVATE oCtrl

   PRIVATE aControls := oForm:oDlg:aControls
   PRIVATE alen := Len(aControls)
   PRIVATE i
   PRIVATE j
   PRIVATE j1

   PRIVATE cName := oForm:GetProp("Name")
   PRIVATE temp
   PRIVATE cofGroup := ""
   PRIVATE cGroup := ""

   PRIVATE aClass := {"label", "button", "buttonex", "shadebutton", "checkbox", "radiobutton", ;
      "editbox", "group", "datepicker", "updown", "combobox", "line", "panel", ;
      "toolbar", "ownerbutton", "browse", "page", "radiogroup", "bitmap", "animation", ;
      "richedit", "monthcalendar", "tree", "trackbar", "progressbar", "status", ;
      "timer", "listbox", "gridex", "menu", "link"}

   PRIVATE aName :=  {{"SAY"}, {"BUTTON"}, {"BUTTONEX"}, {"SHADEBUTTON"}, {"CHECKBOX", "GET CHECKBOX"}, {"RADIOBUTTON"}, ;
      {"EDITBOX", "GET"}, {"GROUPBOX"}, {"DATEPICKER", "GET DATEPICKER"}, ;
      {"UPDOWN", "GET UPDOWN"}, {"COMBOBOX", "GET COMBOBOX"}, {"LINE"}, ;
      {"PANEL"}, {"TOOLBAR"}, {"OWNERBUTTON"}, {"BROWSE"}, {"TAB"}, {"GROUPBOX"}, {"BITMAP"}, ;
      {"ANIMATION"}, {"RICHEDIT", "RICHEDIT"}, {"MONTHCALENDAR"}, {"TREE"}, {"TRACKBAR"}, ;
      {"PROGRESSBAR"}, {"ADD STATUS"}, {"SAY ''"}, {"LISTBOX", "GET LISTBOX"}, ;
      {"GRIDEX"}, {"MENU"}, {"SAY"}}

   // NANDO POS
   PRIVATE nMaxId := 0
   PRIVATE cFormName := ""
   PRIVATE cStyle := ""
   PRIVATE cFunction
   PRIVATE cTempParameter
   PRIVATE aParameters
   cFunction := StrTran(oForm:filename, ".prg", "")
   //

   cName := IIf(Empty(cName), NIL, Trim(cName))
   han := FCreate(fname)

   //Add the lines to include
   //Fwrite(han,'#include "windows.ch"'+ _Chr(10))
   //Fwrite(han,'#include "guilib.ch"' + _Chr(10)+ _Chr(10))
   FWrite(han, '#include "hwgui.ch"' + _Chr(10))
   FWrite(han, '#include <common.ch>' + _Chr(10))
   FWrite(han, '#ifdef __XHARBOUR__' + _Chr(10))
   FWrite(han, '   #include "ttable.ch"' + _Chr(10))
   FWrite(han, '#endif' + _Chr(10) + _Chr(10))

   //Fwrite(han, "FUNCTION " + "_" + IIf(cName != NIL, cName, "Main") + _Chr(10))
   FWrite(han, "FUNCTION " + "_" + IIf(cName != NIL, cFunction, cFunction) + _Chr(10))

   // Declare 'Private' variables
   IF cName != NIL
      //    FWrite(han, "PRIVATE " + cName + _Chr(10))
      FWrite(han, "Local " + cName + _Chr(10))
   ENDIF

   i := 1
   stroka := ""
   DO WHILE i <= aLen
      IF (temp := aControls[i]:GetProp("Name")) != NIL .AND. !Empty(temp)
         //       stroka += IIf(Empty(stroka), "PRIVATE ", ", ") + temp
         stroka += IIf(Empty(stroka), "LOCAL ", ", ") + temp
      ENDIF
      i ++
   ENDDO

   IF !Empty(stroka)

      //FWrite(han, stroka)
      aParameters := hb_atokens(stroka, ", ")

      stroka := ""
      i := 1
      DO WHILE i <= Len(aParameters)
         IF Len(stroka) < 76
            stroka += aParameters[i] + ", "
         ELSE
            FWrite(han, _Chr(10) + SubStr(stroka, 1, Len(stroka) - 2))
            stroka := "LOCAL "
         ENDIF
         i ++
      ENDDO

      //  stroka := "LOCAL " + stroka
      Stroka += _Chr(10) //+ "PUBLIC oDlg"

      FWrite(han, _Chr(10) + SubStr(stroka, 1, RAt(",", stroka) - 1))

   ENDIF

   stroka := ""
   i := 1
   DO WHILE i <= aLen
      IF (temp := aControls[i]:GetProp("VarName")) != NIL .AND. !Empty(temp)
         stroka += IIf(!Empty(stroka), ", ", "") + temp
      ENDIF
      i ++
   ENDDO

   IF !Empty(stroka)
      //    stroka := " PRIVATE " + stroka
      aParameters := hb_atokens(stroka, ", ")

      stroka := "LOCAL "
      i := 1
      DO WHILE i <= Len(aParameters)
         //      para testar se variavel tem : no nome

         IF Len(stroka) < 76
            IF At(":", aParameters[i]) == 0
               stroka += aParameters[i] + ", "
            ENDIF
         ELSE
            IF Upper(AllTrim(stroka)) == "LOCAL" .AND. Len(Upper(AllTrim(stroka))) > 5
               FWrite(han, _Chr(10) + SubStr(stroka, 1, RAt(",", stroka) - 1))
            ENDIF
            stroka := "LOCAL "
         ENDIF
         i ++
      ENDDO

      //  stroka := " LOCAL " + stroka
      Stroka += _Chr(10) //+ "PUBLIC oDlg"
      IF Upper(SubStr(AllTrim(stroka), 1, 5)) == "LOCAL" .AND. Len(AllTrim(stroka)) > 5
         FWrite(han, _Chr(10) + SubStr(stroka, 1, RAt(",", stroka) - 1))
      ENDIF
   ENDIF

   // DEFINIR AS VARIVEIS DE VARIABLES
   IF (temp := oForm:GetProp("Variables")) != NIL
      j := 1
      stroka :=  _chr(10)
      DO WHILE j <= Len(temp)
         // nando adicionu o PRIVATE PARA EVITAR ERROS NO CODIGO
         stroka += "PRIVATE " + temp[j] + _chr(10)
         //stroka += "LOCAL " + temp[j] + _chr(10)
         j ++
      ENDDO
      FWrite(han, _Chr(10) + stroka)
   ENDIF


   i := 1
   DO WHILE i <= Len(oForm:aMethods)
      IF oForm:aMethods[i, 2] != NIL .AND. !Empty(oForm:aMethods[i, 2])

         IF Lower(oForm:aMethods[i, 1]) == "onforminit"
            FWrite(han, _Chr(10) + _Chr(10))
            FWrite(han, oForm:aMethods[i, 2])
         ENDIF

      ENDIF

      i ++
   ENDDO

   //cName := oForm:GetProp("Name")

   IF "DLG" $ Upper(oForm:GetProp("FormType"))
      // 'INIT DIALOG' command
      IF cName == NIL
         cName := "oDlg"
      ENDIF

      FWrite(han, _Chr(10) + _Chr(10) + "  INIT DIALOG " + cname + ' TITLE "' + oForm:oDlg:title + '" ;' + _Chr(10))

   ELSE
      // 'INIT WINDOW' command
      IF cName == NIL
         cName := "oWin"
      ENDIF
      FWrite(han, _Chr(10) + _Chr(10) + "  INIT WINDOW " + cName + ' TITLE "' + oForm:oDlg:title + '" ;' + _Chr(10))

   ENDIF

   //hwg_CallFunc("Imagem2Prg", {oForm})
   // Imagens
   cStyle := ""
   temp := oForm:GetProp("icon")
   IF !Empty(temp)
      cStyle += IIf(oForm:GetProp("lResource") = "True", "ICON HIcon():AddResource('" + temp + "') ", "ICON HIcon():AddFile('" + temp + "') ")
   ENDIF
   temp := oForm:GetProp("bitmap")
   IF !Empty(temp)
      cStyle += "BACKGROUND BITMAP HBitmap():AddFile('" + temp + "') "
   ENDIF
   IF Len(cStyle) > 0
      FWrite(han, Space(4) + cStyle + " ;" + _CHR(10))
   ENDIF

   cFormName := cName
   //
   // STYLE DO FORM
   //
   cStyle := ""
   IF oForm:GetProp("AlwaysOnTop") = "True"
      cStyle += "+DS_SYSMODAL "
   ENDIF
   IF oForm:GetProp("AutoCenter") = "True"
      cStyle += "+DS_CENTER "
   ENDIF
   //IF oForm:GetProp("FromStyle") = "Popup"
   //  cStyle += "+WS_POPUP"
   //ENDIF
   // IF oForm:GetProp("Modal") = .F.
   // ENDIF
   IF oForm:GetProp("SystemMenu") = "True"
      cStyle += "+WS_SYSMENU"
   ENDIF
   IF oForm:GetProp("Minimizebox") = "True"
      cStyle += "+WS_MINIMIZEBOX"
   ENDIF
   IF oForm:GetProp("Maximizebox") = "True"
      cStyle += "+WS_MAXIMIZEBOX"
   ENDIF
   IF oForm:GetProp("SizeBox") = "True"
      cStyle += "+WS_SIZEBOX"
   ENDIF
   IF oForm:GetProp("Visible") = "True"
      cStyle += "+WS_VISIBLE"
   ENDIF
   IF oForm:GetProp("NoIcon") = "True"
      cStyle += "+MB_USERICON"
   ENDIF

   temp := 0
   IF Len(cStyle) > 6
      temp := 26
      //cStyle := ";" + _CHR(10) + SPACE(8) +  "STYLE " + SubStr(cStyle, 2)
      cStyle :=  Space(1) + "STYLE " + SubStr(cStyle, 2)
   ENDIF
   FWrite(han, Space(4) + "AT " + LTrim(Str(oForm:oDlg:nLeft)) + "," ;
      + LTrim(Str(oForm:oDlg:nTop)) + ;
      " SIZE " + LTrim(Str(oForm:oDlg:nWidth)) + "," + ;
      LTrim(Str(oForm:oDlg:nHeight + temp)))

   IF (temp := oForm:GetProp("Font")) != NIL
      FWrite(han, hwg_CallFunc("FONT2STR", {temp}))
   ENDIF


   // NANDO POS
   IF oForm:GetProp("lClipper") = "True"
      FWrite(han, ' CLIPPER ')
   ENDIF
   IF oForm:GetProp("lExitOnEnter") = "True"
      //-Fwrite(han, ' ;' + _Chr(10) + SPACE(8) + 'NOEXIT')
      FWrite(han, ' NOEXIT ')
   ENDIF
   //

   IF Len(cStyle) > 6
      FWrite(han, " ;" + _Chr(10) + Space(4) + cStyle)
   ENDIF

   i := 1
   DO WHILE i <= Len(oForm:aMethods)

      IF !("ONFORM" $ Upper(oForm:aMethods[i, 1])) .AND. ;
            !("COMMON" $ Upper(oForm:aMethods[i, 1])) .AND. oForm:aMethods[i, 2] != NIL .AND. !Empty(oForm:aMethods[i, 2])

         // NANDO POS faltam os parametros
         IF Lower(Left(oForm:aMethods[i, 2], 10)) == "parameters"

            // Note, do we look for a CR or a LF??
            j := At(_Chr(10), oForm:aMethods[i, 2])

            temp := SubStr(oForm:aMethods[i, 2], 12, j - 13)
         ELSE
            temp := ""
         ENDIF
         // fim
         // all methods are onSomething so, strip leading "on"
         FWrite(han, " ;" + + _Chr(10) + Space(8) + "ON " + ;
            StrTran(StrTran(Upper(SubStr(oForm:aMethods[i, 1], 3)), "DLG", ""), "FORM", "") + ;
            " {|" + temp + "| " + oForm:aMethods[i, 1] + "( " + temp + " ) }" )

         // Dialog and Windows methods can have little different name, should be fixed

      ENDIF

      i ++
   ENDDO
   FWrite(han, _Chr(10) + _Chr(10))

   // Controls initialization
   i := 1
   DO WHILE i <= aLen
      IF aControls[i]:cClass != "menu"
         IF aControls[i]:oContainer == NIL
            hwg_CallFunc("Ctrl2Prg", {aControls[i]})
         ENDIF
      ELSE
         nMaxId := 0
         FWrite(han, _Chr(10) + " MENU OF " + cformname + " ")
         hwg_CallFunc("Menu2Prg", {aControls[i], getmenu()})
         FWrite(han, _Chr(10) + " ENDMENU" + " " + _chr(10) + _chr(10))
      ENDIF
      i ++
   ENDDO
   temp := ""
   IF "DLG" $ Upper(oForm:GetProp("FormType"))
      // colocar uma expressao para retornar na FUNCAO
      IF (temp := oForm:GetProp("ReturnExpr")) != NIL .AND. !Empty(temp)
         temp := "" + TEMP  // nando pos  return
      ELSE
         temp := cname + ":lresult"  // nando pos  return
      ENDIF
      FWrite(han, _Chr(10) + _Chr(10) + "   ACTIVATE DIALOG " + cname + _Chr(10))
   ELSE
      FWrite(han, _Chr(10) + _Chr(10) + "   ACTIVATE WINDOW " + cname + _Chr(10))
   ENDIF

   i := 1
   DO WHILE i <= Len(oForm:aMethods)

      IF oForm:aMethods[i, 2] != NIL .AND. !Empty(oForm:aMethods[i, 2])

         IF Lower(oForm:aMethods[i, 1]) == "onformexit"
            FWrite(han, oForm:aMethods[i, 2])
            FWrite(han, _Chr(10) + _Chr(10))
         ENDIF

      ENDIF
      i ++
   ENDDO


   FWrite(han, "RETURN " + temp + _Chr(10) + _Chr(10))

   // "common" Form/Dialog methods
   i := 1
   DO WHILE i <= Len(oForm:aMethods)

      IF oForm:aMethods[i, 2] != NIL .AND. !Empty(oForm:aMethods[i, 2])

         IF (cName := Lower(oForm:aMethods[i, 1])) == "common"
            j1 := 1
            temp := .F.

            DO WHILE .T.

               stroka := hwg_RdStr(, oForm:aMethods[i, 2], @j1)

               IF Len(stroka) == 0
                  EXIT
               ENDIF

               IF Lower(Left(stroka, 8)) == "function"
                  FWrite(han, "STATIC " + stroka + _Chr(10))
                  temp := .F.

               ELSEIF Lower(Left(stroka, 6)) == "return"
                  FWrite(han, stroka + _Chr(10))
                  temp := .T.

               ELSEIF Lower(Left(stroka, 7)) == "endfunc"
                  IF !temp
                     FWrite(han, "Return NIL" + _Chr(10))
                  ENDIF
                  temp := .F.

               ELSE
                  FWrite(han, stroka + _Chr(10))
                  temp := .F.
               ENDIF

            ENDDO

         ELSEIF cName != "onforminit" .AND. cName != "onformexit"

            FWrite(han, "STATIC FUNCTION " + oForm:aMethods[i, 1] + _Chr(10) + _Chr(13))
            FWrite(han, oForm:aMethods[i, 2])

            j1 := RAt(_Chr(10), oForm:aMethods[i, 2])

            IF j1 == 0 .OR. Lower(Left(LTrim(SubStr(oForm:aMethods[i, 2], j1 + 1)), 6)) != "return"
               FWrite(han, _Chr(10) + "RETURN NIL")
            ENDIF

            FWrite(han, _Chr(10) + _Chr(10))

         ENDIF

      ENDIF
      i ++

   ENDDO

   // Control's methods
   j := 1
   DO WHILE j <= aLen
      oCtrl := aControls[j]

      //hwg_MsgInfo(oCtrl:GetProp("Name"))

      i := 1
      DO WHILE i <= Len(oCtrl:aMethods)

         //hwg_MsgInfo(oCtrl:aMethods[i, 1] + " / " + oCtrl:aMethods[i, 2])

         IF oCtrl:aMethods[i, 2] != NIL .AND. !Empty(oCtrl:aMethods[i, 2])

            IF hb_IsChar(cName := hwg_Callfunc("FUNC_NAME", {oCtrl, i}))

               FWrite(han, "STATIC FUNCTION " + cName + _Chr(10))
               FWrite(han, oCtrl:aMethods[i, 2])

               j1 := RAt(_Chr(10), oCtrl:aMethods[i, 2])

               IF j1 == 0 .OR. ;
                     Lower(Left(LTrim(SubStr(oCtrl:aMethods[i, 2], j1 + 1)), 6)) != "return"

                  FWrite(han, _Chr(10) + "RETURN NIL")

               ENDIF

               FWrite(han, _Chr(10) + _Chr(10))

            ENDIF

         ENDIF

         i ++
      ENDDO

      j ++
   ENDDO
   FClose(han)

#endscript

