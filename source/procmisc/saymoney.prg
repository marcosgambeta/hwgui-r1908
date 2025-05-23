//
// HWGUI - Harbour Win32 GUI library source code:
// Main prg level functions
//
// Copyright 2008 Richard Roesnadi <roesnadi8@yahoo.co.id>
// www - http://richard-software.com
//

//
// English   :  hwg_SayDollar(nDollar) -> Say in Dollar
// Indonesia :  hwg_SayRupiah(nRupiah) -> Say in Rupiah
//

// English Say Money
FUNCTION hwg_SayDollar(nDollar)

 LOCAL cDollar := Right(LTrim(Str(nDollar, 15)), 11)
 LOCAL nAA := 1
 LOCAL nPJ := Len(cDollar)
 LOCAL xSay := "", xLang2, xLang1, xMuch, xNum, xteen
 LOCAL mm := 0
 LOCAL nTest := 0
 LOCAL nCheck1 := 0
 LOCAL nCheck2 := 0

 DO WHILE nPJ > 0
    xLang2 := ""
    xLang1 := ""
    xMuch := "ONE"
    xNum := Left(cDollar, 1)

    IF nPJ=6.AND.xNum="0" .OR. nPJ=5.AND.xNum="0" .AND. nCheck1=1
        nCheck1 := 1
    ENDIF

    IF nPJ=5.AND.xNum="0"
        nCheck2 := 1
    ENDIF

    IF nPJ=5.AND.xNum != "0"
        mm := 1
        nCheck1 := 0
    ENDIF

    IF xNum != "0" .OR. xNum="0" .AND. nPJ=7.OR.xNum="0" .AND. nPJ=4
        nAA := 1

        DO CASE
            CASE nPJ=8.OR.nPJ=5.OR.nPJ=2
                xLang2 = "TY "
                nAA := 2
            CASE nPJ=7
                IF xMuch ="ONE"
                    xLang2  := " MILLION "
                ELSE
                    xLang2  := " MILLIONS "
                ENDIF
            CASE nPJ=6.OR.nPJ=3.OR.nPJ=9
                nCheck2 := 0
                IF xMuch ="ONE"
                    xLang2  := " HUNDRED "
                ELSE
                    xLang2  := " HUNDREDS "
                ENDIF
                nTest := 0

            CASE nPJ=4
                IF nCheck1=0.OR.xNum != "0"
                    IF xMuch="ONE"
                        xLang2 = " THOUSAND "
                    ELSE
                        xLang2 = " THOUSANDS "
                    ENDIF
                ENDIF
        ENDCASE
    ENDIF

    DO CASE
        CASE xNum="1"
            IF nPJ=7.OR.nPJ=1.OR.nPJ=10
                nCheck1 := 0
                xLang1 = "ONE"
            ELSE
                xLang1 = "ONE"
            ENDIF
            IF nPJ=8.OR.nPJ=5.OR.nPJ=2.OR.nPJ=11
                nTest := 1
            ENDIF
            IF nCheck2=1
                xLang1 = "ONE"
                nCheck2 := 0
            ENDIF
            IF nPJ=4.AND.mm=1
                xLang1 = "ONE"
            ENDIF
            IF nCheck1=1
                xLang1 = "ONE"
            ENDIF
        CASE xNum="2"
            xLang1 = "TWO"
            IF nAA=2
                xLang1 = "TWEEN"
            ENDIF
        CASE xNum="3"
            xLang1 = "THREE"
            IF nAA=2
                xLang1 = "THIR"
            ENDIF
        CASE xNum="4"
            xLang1 = "FOUR"
        CASE xNum="5"
            xLang1 = "FIVE"
            IF nAA=2
                xLang1 = "FIF"
            ENDIF
        CASE xNum="6"
            xLang1 = "SIX"
        CASE xNum="7"
            xLang1 = "SEVEN"
        CASE xNum="8"
            xLang1 = "EIGHT"
        CASE xNum="9"
            xLang1 = "NINE"
    ENDCASE
    cDollar := Right(cDollar,(nPJ - 1))
    xMuch := xLang1

    IF xNum != "0" .OR. xNum="0" .AND. nPJ=7 .OR. xNum="0" .AND. nPJ=4
        nAA := 1
        DO CASE
            CASE nPJ=8 .OR. nPJ=5 .OR. nPJ=2
                xLang2 = "TY "
                nAA := 2
            CASE nPJ=7
                IF xMuch="ONE"
                    xLang2 = " MILLION "
                ELSE
                    xLang2 = " MILLIONS "
                ENDIF
            CASE nPJ=6 .OR. nPJ=3
                nCheck2 := 0
                IF xMuch="ONE"
                    xLang2 = " HUNDRED "
                ELSE
                    xLang2 = " HUNDREDS "
                ENDIF
                nTest := 0
            CASE nPJ=4
                IF nCheck1=0 .OR. xNum != "0"
                    IF xMuch="ONE"
                        xLang2 = " THOUSAND "
                    ELSE
                        xLang2 = " THOUSANDS "
                    ENDIF
                ENDIF
        ENDCASE
    ENDIF
    IF nTest=0
        xSay := xSay + xLang1 + xLang2
    ENDIF

    IF nPJ=1 .OR. nPJ=4 .OR. nPJ=7

        IF nTest=1
            IF xNum<="5"
                IF xNum="0"
                    xteen = "TEN "
                ENDIF
                IF xNum="1"
                    xteen = "ELEVEN "
                ENDIF
                IF xNum="2"
                    xteen = "TWELVE "
                ENDIF
                IF xNum="3"
                    xteen = "THIRTEEN "
                ENDIF
                IF xNum="4"
                    xteen = "FOURTEEN "
                ENDIF
                IF xNum="5"
                    xteen = "FIFTEEN "
                ENDIF
                xSay := xSay + xteen + xLang2
            ELSE
                xteen = "TEEN "
                xSay := xSay + xLang1 + xteen + xLang2
            ENDIF
        ENDIF
        nTest := 0
    ENDIF
    nPJ := Len(cDollar)
ENDDO

RETURN xSay
// eof hwg_SayDollar


// Indonesian Say Money

#define PECAHAN {"TRILIUN ", "MILYAR ", "JUTA ", "RIBU ", "RUPIAH"}

FUNCTION hwg_SayRupiah(nAngka)

   LOCAL n, kata, kalimat := IIf(nAngka < 0, "Minus ", "")
   LOCAL char := strtran(Str(ABS(INT(nAngka)), 15), " ", "0")

   FOR n := 1 TO 5
      kalimat += tigades(subs(char, n * 3 - 2, 3), n)
      kata := IIf(subs(char, n * 3 - 2, 3) == "000", "", PECAHAN[n])
      kalimat += kata
   NEXT

   char := "0" + Right(Str(nAngka, 18, 2), 2)

   kalimat += IIf(char != "000", " koma " + tigades(char, 1) + "sen", "")

RETURN kalimat



//
STATIC FUNCTION tigades(mvc, n)    // created: 28 mei 1993
 LOCAL say := "", x1 := left(mvc, 1), x2 := subs(mvc, 2, 1), x3 := right(mvc, 1)

 IF n == 4 .AND. mvc == "001"
    RETURN "se"
 ENDIF
 IF mvc == "000"
    RETURN ""
 ENDIF

       IF x1 == "0"   // do nothing
       ELSEIF x1 == "1";  say += "SERATUS "
       ELSE;            say += bil(x1)+ "RATUS "
       ENDIF

       IF x2 == "0";  say += bil(x3)
       ELSEIF x2 == "1"
                 IF x3 == "0";  say += "SEPULUH "
                 ELSEIF x3 == "1";  say += "SEBELAS "
                 ELSE;              say += bil(x3) + "BELAS "
                 ENDIF
       ELSE;     say += bil(x2) + "PULUH " + bil(x3)
       ENDIF

 RETURN say


#define bil_asli {"SATU", "DUA", "TIGA", "EMPAT", "LIMA", "ENAM", "TUJUH", "DELAPAN", "SEMBILAN"}

STATIC FUNCTION bil(x)
RETURN IIf(x != "0", bil_asli[val(x)] + " ", "")

// eof hwg_SayRupiah
