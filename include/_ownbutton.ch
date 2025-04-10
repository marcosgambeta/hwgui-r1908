// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> OWNERBUTTON [ <oOwnBtn> ]  ;
             [ OF <oWnd> ]             ;
             [ ID <nId> ]              ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]     ;
             [ ON SIZE <bSize> ]     ;
             [ ON DRAW <bDraw> ]     ;
             [ ON CLICK <bClick> ]   ;
             [ ON GETFOCUS <bGfocus> ]   ;
             [ ON LOSTFOCUS <bLfocus> ]  ;
             [ STYLE <nStyle> ]      ;
             [ <flat: FLAT> ]        ;
             [ <enable: DISABLED> ]        ;
             [ TEXT <cText>          ;
             [ COLOR <color>] [ FONT <font> ] ;
             [ COORDINATES  <xt>, <yt>, <widtht>, <heightt> ] ;
             ] ;
             [ BITMAP <bmp>  [<res: FROM RESOURCE>] [<ltr: TRANSPARENT> [COLOR  <trcolor> ]] ;
             [ COORDINATES  <xb>, <yb>, <widthb>, <heightb> ] ;
             ] ;
             [ TOOLTIP <cTooltip> ]    ;
             [ <lCheck: CHECK> ]     ;
             [ <lThemed: THEMED> ]     ;             
          => ;
          [<oOwnBtn> :=] HOWNBUTTON():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<bInit>,<bSize>,<bDraw>,<bClick>,<.flat.>,<cText>,<color>, ;
             <font>,<xt>,<yt>,<widtht>,<heightt>,<bmp>,<.res.>,<xb>,<yb>,<widthb>, ;
             <heightb>,<.ltr.>,<trcolor>,<cTooltip>,!<.enable.>,<.lCheck.>,<bcolor>, <bGfocus>, <bLfocus>,<.lThemed.> );;
          [ <oOwnBtn>:name := <(oOwnBtn)> ]

#xcommand REDEFINE OWNERBUTTON [ <oOwnBtn> ]  ;
             [ OF <oWnd> ]                     ;
             ID <nId>                          ;
             [ ON INIT <bInit> ]     ;
             [ ON SIZE <bSize> ]     ;
             [ ON DRAW <bDraw> ]     ;
             [ ON CLICK <bClick> ]   ;
             [ <flat: FLAT> ]        ;
             [ TEXT <cText>          ;
             [ COLOR <color>] [ FONT <font> ] ;
             [ COORDINATES  <xt>, <yt>, <widtht>, <heightt> ] ;
             ] ;
             [ BITMAP <bmp>  [<res: FROM RESOURCE>] [<ltr: TRANSPARENT>] ;
             [ COORDINATES  <xb>, <yb>, <widthb>, <heightb> ] ;
             ] ;
             [ TOOLTIP <cTooltip> ]    ;
             [ <enable: DISABLED> ]  ;
             [ <lCheck: CHECK> ]      ;
          => ;
          [<oOwnBtn> :=] HOWNBUTTON():Redefine( <oWnd>,<nId>,<bInit>,<bSize>,;
             <bDraw>,<bClick>,<.flat.>,<cText>,<color>,<font>,<xt>,<yt>,;
             <widtht>,<heightt>,<bmp>,<.res.>,<xb>,<yb>,<widthb>,<heightb>,;
             <.ltr.>,<cTooltip>,!<.enable.>,<.lCheck.> )

