// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GRID <oGrid>         ;
             [ OF <oParent> ]               ;
             [ ID <nId> ]                   ;
             [ STYLE <nStyle> ]             ;
             [ SIZE <nWidth>, <nHeight> ]   ;
             [ FONT <oFont> ]               ;
             [ ON INIT <bInit> ]            ;
             [ ON SIZE <bSize> ]            ;
             [ ON PAINT <bPaint> ]          ;
             [ ON CLICK <bEnter> ]          ;
             [ ON GETFOCUS <bGfocus> ]      ;
             [ ON LOSTFOCUS <bLfocus> ]     ;
             [ ON KEYDOWN <bKeyDown> ]      ;
             [ ON POSCHANGE <bPosChg> ]     ;
             [ ON DISPINFO <bDispInfo> ]    ;
             [ ITEMCOUNT <nItemCount> ]     ;
             [ <lNoScroll: NOSCROLL> ]      ;
             [ <lNoBord: NOBORDER> ]        ;
             [ <lNoLines: NOGRIDLINES> ]    ;
             [ COLOR <color> ]              ;
             [ BACKCOLOR <bkcolor> ]        ;
             [ <lNoHeader: NO HEADER> ]     ;
             [ BITMAP <aBit> ]              ;
             [ <class: CLASS> <classname> ] ;
          => ;
          <oGrid> := __IIF(<.class.>, <classname>, HGrid)():New(<oParent>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, ;
             <oFont>, <{bInit}>, <{bSize}>, <{bPaint}>, <{bEnter}>, ;
             <{bGfocus}>, <{bLfocus}>, <.lNoScroll.>, <.lNoBord.>, ;
             <{bKeyDown}>, <{bPosChg}>, <{bDispInfo}>, <nItemCount>, ;
             <.lNoLines.>, <color>, <bkcolor>, <.lNoHeader.>, <aBit>) ;;
          [ <oGrid>:name := <(oGrid)> ]

#xcommand ADD COLUMN TO GRID <oGrid>     ;
             [ HEADER <cHeader> ]        ;
             [ WIDTH <nWidth> ]          ;
             [ JUSTIFY HEAD <nJusHead> ] ;
             [ BITMAP <n> ]              ;
          => ;
          <oGrid>:AddColumn(<cHeader>, <nWidth>, <nJusHead>, <n>)

#xcommand ADDROW TO GRID <oGrid>          ;
             [ HEADER <cHeader> ]         ;
             [ JUSTIFY HEAD <nJusHead> ]  ;
             [ BITMAP <n> ]               ;
             [ HEADER <cHeadern> ]        ;
             [ JUSTIFY HEAD <nJusHeadn> ] ;
             [ BITMAP <nn> ]              ;
          => ;
          <oGrid>:AddRow(<cHeader>, <nJusHead>, <n>) [;<oGrid>:AddRow(<cHeadern>, <nJusHeadn>, <nn>)]

#xcommand ADDROWEX TO GRID <oGrid>       ;
             [ HEADER <cHeader>          ;
               [ BITMAP <n> ]            ;
               [ COLOR <color> ]         ;
               [ BACKCOLOR <bkcolor> ]   ;
             ]                           ;
             [, HEADER <cHeadern>        ;
                [ BITMAP <nn> ]          ;
                [ COLOR <colorn> ]       ;
                [ BACKCOLOR <bkcolorn> ] ;
             ]                           ;
          => ;
          <oGrid>:AddRow(\{<cHeader>, <n>, <color>, <bkcolor> [, <cHeadern>, <nn>, <colorn>, <bkcolorn> ] \})

#xcommand ADDROWEX TO GRID <oGrid>       ;
             [ HEADER <cHeader>          ;
               [ BITMAP <n> ]            ;
               [ COLOR <color> ]         ;
               [ BACKCOLOR <bkcolor> ]   ;
             ]                           ;
             [, HEADER <cHeadern>        ;
                [ BITMAP <nn> ]          ;
                [ COLOR <colorn> ]       ;
                [ BACKCOLOR <bkcolorn> ] ;
             ]                           ;
          => ;
          <oGrid>:AddRow(\{<cHeader>, <n>, <color>, <bkcolor> [, <cHeadern>, <nn>, <colorn>, <bkcolorn> ] \})

#xcommand ADDROWEX <oGrid>            ;
             HEADER <cHeader>         ;
             [ BITMAP <n> ]           ;
             [ COLOR <color> ]        ;
             [ BACKCOLOR <bkcolor> ]  ;
             [ HEADER <cHeadern> ]    ;
             [ BITMAP <nn> ]          ;
             [ COLOR <colorn> ]       ;
             [ BACKCOLOR <bkcolorn> ] ;
          => ;
          <oGrid>:AddRow(\{<cHeader>, <n>, <color>, <bkcolor> [, <cHeadern>, <nn>, <colorn>, <bkcolorn>] \})
