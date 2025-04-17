// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> RICHEDIT [ <oEdit> TEXT ] <vari> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lallowtabs: ALLOWTABS>]  ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON CHANGE <bChange>]     ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
          => ;
          [<oEdit> := ] HRichEdit():New( <oWnd>,<nId>,<vari>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bDraw>,<bGfocus>, ;
             <bLfocus>,<cTooltip>,<color>,<bcolor>,<bOther>, <.lallowtabs.>,<bChange> );;
          [ <oEdit>:name := <(oEdit)> ]
