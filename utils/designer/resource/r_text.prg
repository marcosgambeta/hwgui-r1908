#SCRIPT READ
FUNCTION STR2FONT
   
   PARAMETERS cFont
   PRIVATE oFont
  
  IF !Empty(cFont)
    oFont := HFont():Add(hwg_NextItem(cFont, .T., ","), ;
       Val(hwg_NextItem(cFont,, ",")), Val(hwg_NextItem(cFont,, ",")), ;
       Val(hwg_NextItem(cFont,, ",")), Val(hwg_NextItem(cFont,, ",")), ;
       Val(hwg_NextItem(cFont,, ",")), Val(hwg_NextItem(cFont,, ",")), ;
       Val(hwg_NextItem(cFont,, ",")))
  ENDIF
RETURN oFont
ENDFUNC

   PRIVATE strbuf := Space(512)
   PRIVATE poz := 513
   PRIVATE stroka
   PRIVATE nMode := 0
   PRIVATE itemName
   PRIVATE i
   PRIVATE j
   PRIVATE han := FOPEN(oForm:path + oForm:filename)
   PRIVATE arr := {}
   PRIVATE oArea
   PRIVATE oCtrl
   PRIVATE cCaption
   PRIVATE x
   PRIVATE y
   PRIVATE nWidth
   PRIVATE nHeight
   PRIVATE x2
   PRIVATE y2
   PRIVATE nAlign
   PRIVATE oFont
   PRIVATE cFont
   PRIVATE nVar
   PRIVATE xKoef
   PRIVATE cm
   PRIVATE cWidth
   PRIVATE aVars

  IF han == - 1
    hwg_MsgStop("Can't open " + oForm:path + oForm:filename)
    RETURN
  ENDIF
  DO WHILE .T.
    stroka := hwg_RDSTR(han, @strbuf, @poz, 512)
    IF Len(stroka) == 0
      EXIT
    ENDIF
    IF Left(stroka, 1) == ";"
      LOOP
    ENDIF
    stroka := LTrim(stroka)
    IF nMode == 0
      IF Left(stroka, 1) == "#"
        IF Upper(SubStr(stroka, 2, 6)) == "REPORT"
          stroka := LTrim(SubStr(stroka, 9))
          IF Empty(oForm:name) .OR. Upper(stroka) == Upper(oForm:name)
            nMode := 1
          ENDIF
        ENDIF
      ENDIF
    ELSEIF nMode == 1
      IF Left(stroka, 1) == "#"
        IF Upper(SubStr(stroka, 2, 6)) == "ENDREP"
          Exit
        ELSEIF Upper(SubStr(stroka, 2, 6)) == "SCRIPT"
          nMode := 2
          cCaption := ""
          IF itemName == "FORM"
            aVars := {}
          ENDIF
        ENDIF
      ELSE
        IF (itemName := hwg_NextItem(stroka, .T.)) == "FORM"
          cWidth := hwg_NextItem(stroka)
          nWidth := Val(cWidth)
          nHeight := Val(hwg_NextItem(stroka))
          xKoef := nWidth / Val(hwg_NextItem(stroka))
          oForm:CreateDialog({{"Left", "300"}, {"Top", "120"}, ;
              {"Width", "500"}, {"Height", "400"}, {"Caption", itemName}, ;
              {"Paper Size", "A4"}, {"Orientation", IIf(nWidth>nHeight, "Landscape", "Portrait")}})
        ELSEIF itemName == "TEXT"
          itemName := "label"
          cCaption := hwg_NextItem(stroka)
          x := Val(hwg_NextItem(stroka))
          y := Val(hwg_NextItem(stroka))
          nWidth := Val(hwg_NextItem(stroka))
          nHeight := Val(hwg_NextItem(stroka))
          nAlign := Val(hwg_NextItem(stroka))
          cFont := hwg_NextItem(stroka)
          nVar := Val(hwg_NextItem(stroka))

          oFont := hwg_CallFunc("Str2Font", {cFont})
          AAdd(arr, {itemName, x, y, nWidth, nHeight, NIL, cCaption, oFont, nAlign, nVar})

        ELSEIF itemName == "HLINE" .OR. itemName == "VLINE" .OR. itemName == "BOX"
          itemName := Lower(itemName)
          x := Val(hwg_NextItem(stroka))
          y := Val(hwg_NextItem(stroka))
          nWidth := Val(hwg_NextItem(stroka))
          nHeight := Val(hwg_NextItem(stroka))
          cFont  := hwg_NextItem(stroka)
          nAlign := Val(hwg_NextItem(cFont, .T., ",")) + 1
          nVar   := Val(hwg_NextItem(cFont,, ","))

          AAdd(arr, {itemName, x, y, nWidth, nHeight, NIL, nAlign, nVar})

        ELSEIF itemName == "BITMAP"
          itemName := Lower(itemName)
          cCaption := hwg_NextItem(stroka)
          x := Val(hwg_NextItem(stroka))
          y := Val(hwg_NextItem(stroka))
          nWidth := Val(hwg_NextItem(stroka))
          nHeight := Val(hwg_NextItem(stroka))

          AAdd(arr, {itemName, x, y, nWidth, nHeight, NIL, cCaption})

        ELSEIF itemName == "MARKER"
          itemName := "area"
          cm := cCaption := hwg_NextItem(stroka)
          x := Val(hwg_NextItem(stroka))
          y := Val(hwg_NextItem(stroka))
          nHeight := 0
          IF cCaption == "EPF"
            IF (i := AScan(arr, {|a|a[1] == "area" .AND. a[7] == "PF"})) != 0
              arr[i, 5] := y - arr[i, 3]
            ENDIF
          ELSEIF cCaption == "EL"
          ELSE
            IF cCaption == "SL"
              IF (i := AScan(arr, {|a|a[1] == "area" .AND. a[7] == "PH"})) != 0
                arr[i, 5] := y - arr[i, 3]
              ENDIF
            ELSEIF cCaption == "PF"
              IF (i := AScan(arr, {|a|a[1] == "area" .AND. a[7] == "SL"})) != 0
                arr[i, 5] := y - arr[i, 3]
              ENDIF
            ELSEIF cCaption == "DF"
              IF (i := AScan(arr, {|a|a[1] == "area" .AND. a[7] == "SL"})) != 0 .AND. arr[i, 5] == 0
                arr[i, 5] := y - arr[i, 3]
              ENDIF
              nHeight := Round(oForm:nPHeight * oForm:nKoeff, 0) - y
            ENDIF
            AAdd(arr, {itemName, 0, y, 9999, nHeight, NIL, cCaption, NIL})
          ENDIF
        ENDIF
      ENDIF
    ELSEIF nMode == 2
      IF Left(stroka, 1) == "#" .AND. Upper(SubStr(stroka, 2, 6)) == "ENDSCR"
         nMode := 1
         IF itemName == "area"
           IF cm == "SL"
             arr[Len(arr), 6] := cCaption
           ELSE
             IF (i := AScan(arr, {|a|a[1] == "area" .AND. a[7] == "SL"})) != 0
               arr[i, 8] := cCaption
             ENDIF
           ENDIF
         ELSEIF itemName == "label"
           arr[Len(arr), 6] := cCaption
         ELSE
           IF (j := AScan(oForm:aMethods, {|a|a[1] == "onRepInit"})) != 0
              oForm:aMethods[j, 2] := cCaption
           ENDIF
         ENDIF
      ELSE
        cCaption += stroka + Chr(13) + chr(10)
        IF itemName == "FORM"
          DO WHILE !Empty(cFont := hwg_getNextVar(@stroka))
            AAdd(aVars, cFont)
          ENDDO
        ENDIF
      ENDIF
    ENDIF
  ENDDO
  FClose(han)
  arr := ASort(arr, , , {|z, y|z[3] < y[3] .OR. (z[3] == y[3] .AND. z[2] < y[2]) .OR. (z[3] == y[3] .AND. z[2] == y[2] .AND. (z[4] > y[4] .OR. z[5] > y[5]))})
  IF (j := AScan(arr, {|a|a[1] == "area" .AND. a[7] == "PH"})) > 1
    AAdd(arr, NIL)
    AIns(arr, 1)
    arr[1] := {"area", 0, 0, 9999, arr[j + 1, 3] - 1, NIL, "DH", NIL}
  ENDIF
  i := 1
  DO WHILE i <= Len(arr)
    oArea := NIL
    j := i - 1
    DO WHILE j > 0      
       IF arr[i, 2] >= arr[j, 2] .AND. arr[i, 2] + arr[i, 4] <= arr[j, 2] + arr[j, 4] .AND. ;
          arr[i, 3] >= arr[j, 3] .AND. arr[i, 3] + arr[i, 5] <= arr[j, 3] + arr[j, 5]
         oArea := oForm:oDlg:aControls[1]:aControls[1]:aControls[j]
         EXIT
       ENDIF
       j --
    ENDDO
    x       := Round(arr[i, 2] * xKoef, 2)
    y       := Round(arr[i, 3] * xKoef, 2)
    nWidth  := Round(arr[i, 4] * xKoef, 2)
    nHeight := Round(arr[i, 5] * xKoef, 2)
    x2      := Round((arr[i, 2] + arr[i, 4] - 1) * xKoef, 2)
    y2      := Round((arr[i, 3] + arr[i, 5] - 1) * xKoef, 2)
    IF arr[i, 1] == "area"
      cCaption := IIf(arr[i, 7] == "PH", "PageHeader", IIf(arr[i, 7] == "SL", ;
          "Table", IIf(arr[i, 7] == "PF", "PageFooter", IIf(arr[i, 7] == "DH", "DocHeader", "DocFooter"))))
      oArea := HControlGen():New(oForm:oDlg:aControls[1]:aControls[1], "area", ;
       {{"Left", "0"}, {"Top", LTrim(Str(y))}, {"Width", cWidth}, ;
       {"Height", LTrim(Str(nHeight))}, {"Right", cWidth}, {"Bottom", LTrim(Str(y2))}, {"AreaType", cCaption}})
      IF arr[i, 6] != NIL
        j := AScan(oArea:aMethods, {|a|a[1] == "onBegin"})
        oArea:aMethods[j, 2] := arr[i, 6]
      ENDIF
      IF arr[i, 8] != NIL
        j := AScan(oArea:aMethods, {|a|a[1] == "onNextLine"})
        oArea:aMethods[j, 2] := arr[i, 8]
      ENDIF
    ELSEIF arr[i, 1] == "label"
      oCtrl := HControlGen():New(oForm:oDlg:aControls[1]:aControls[1], arr[i, 1], ;
       {{"Left", LTrim(Str(x))}, {"Top", LTrim(Str(y))}, {"Width", LTrim(Str(nWidth))}, ;
       {"Height", LTrim(Str(nHeight))}, {"Right", LTrim(Str(x2))}, {"Bottom", LTrim(Str(y2))}, ;
       {"Caption", IIf(arr[i, 10] == 1, "", arr[i, 7])}, ;
       {"Justify", IIf(arr[i, 9]=0, "Left", IIf(arr[i, 9]=2, "Center", "Right"))}, ;
       {"Font", arr[i, 8]}})
      IF oArea != NIL
        oArea:AddControl(oCtrl)
        oCtrl:oContainer := oArea
      ENDIF
      IF arr[i, 10] == 1
        j := AScan(oCtrl:aMethods, {|a|a[1] == "Expression"})
        oCtrl:aMethods[j, 2] := "Return " + arr[i, 7]
      ENDIF
      IF arr[i, 6] != NIL
        j := AScan(oCtrl:aMethods, {|a|a[1] == "onBegin"})
        oCtrl:aMethods[j, 2] := arr[i, 6]
      ENDIF
    ELSEIF arr[i, 1] == "bitmap"
      oCtrl := HControlGen():New(oForm:oDlg:aControls[1]:aControls[1], arr[i, 1], ;
       {{"Left", LTrim(Str(x))}, {"Top", LTrim(Str(y))}, {"Width", LTrim(Str(nWidth))}, ;
       {"Height", LTrim(Str(nHeight))}, {"Right", LTrim(Str(x2))}, {"Bottom", LTrim(Str(y2))}, {"Bitmap", arr[i, 7]}})
      IF oArea != NIL
        oArea:AddControl(oCtrl)
        oCtrl:oContainer := oArea
      ENDIF
    ELSE
      oCtrl := HControlGen():New(oForm:oDlg:aControls[1]:aControls[1], arr[i, 1], ;
       {{"Left", LTrim(Str(x))}, {"Top", LTrim(Str(y))}, {"Width", LTrim(Str(nWidth))}, ;
       {"Height", LTrim(Str(nHeight))}, {"Right", LTrim(Str(x2))}, {"Bottom", LTrim(Str(y2))}, ;
       {"PenType", {"SOLID", "DASH", "DOT", "DASHDOT", "DASHDOTDOT"}[arr[i, 7]]}, ;
       {"PenWidth", LTrim(Str(arr[i, 8]))}})
      IF oArea != NIL
        oArea:AddControl(oCtrl)
        oCtrl:oContainer := oArea
      ENDIF
    ENDIF
    i ++
  ENDDO
  IF aVars != NIL .AND. !Empty(aVars)
    oForm:SetProp("Variables", aVars)
  ENDIF

RETURN
#ENDSCRIPT

