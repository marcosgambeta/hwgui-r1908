// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand TOOLBUTTON <O>         ;
             ID <nId>            ;
             [ BITMAP <nBitIp> ] ;
             [ STYLE <bstyle> ]  ;
             [ STATE <bstate> ]  ;
             [ TEXT <ctext> ]    ;
             [ TOOLTIP <c> ]     ;
             [ MENU <d> ]        ;
             ON CLICK <bclick>   ;
          => ;
          <O>:AddButton(<nBitIp>, <nId>, <bstate>, <bstyle>, <ctext>, <bclick>, <c>, <d>)

#xcommand @ <nX>, <nY> TOOLBAR [ <oTool> ] ;
            [ OF <oParent> ]               ;
            [ ID <nId> ]                   ;
            [ SIZE <nWidth>, <nHeight> ]   ;
            [ BUTTONWIDTH <btnwidth> ]     ;
            [ INDENT <nIndent> ]           ;
            [ BITMAPSIZE <bmpwidth>        ;
               [, <bmpheight> ]            ;
            ]                              ;
            [ FONT <oFont> ]               ;
            [ ON INIT <bInit> ]            ;
            [ ON SIZE <bSize> ]            ;
            [ <lTransp: TRANSPARENT> ]     ;
            [ <lVertical: VERTICAL> ]      ;
            [ STYLE <nStyle> ]             ;
            [ LOADSTANDARDIMAGE <nIDB> ]   ;
            [ ITEMS <aItems> ]             ;
            [ <class: CLASS> <classname> ] ;
          => ;
          [ <oTool> := ] __IIF(<.class.>, <classname>, Htoolbar)():New(<oParent>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <btnwidth>, <oFont>, ;
             <bInit>, <bSize>, , , , , <.lTransp.>, <.lVertical.>, <aItems>, <bmpwidth>, <bmpheight>, <nIndent>, <nIDB>) ;;
          [ <oTool>:name := <(oTool)> ]

#xcommand REDEFINE TOOLBAR <oSay>  ;
             [ OF <oParent> ]      ;
             ID <nId>              ;
             [ ON INIT <bInit> ]   ;
             [ ON SIZE <bSize> ]   ;
             [ ON PAINT <bPaint> ] ;
             [ ITEM <aitem>]       ;
          => ;
          [ <oSay> := ] Htoolbar():Redefine(<oParent>, <nId>, , , <bInit>, <bSize>, <bPaint>, , , , , <aitem>)

#xcommand ADD TOOLBUTTON <O>     ;
             ID <nId>            ;
             [ BITMAP <nBitIp> ] ;
             [ STYLE <bstyle> ]  ;
             [ STATE <bstate> ]  ;
             [ TEXT <ctext> ]    ;
             [ TOOLTIP <c> ]     ;
             [ MENU <d> ]        ;
             ON CLICK <bclick>   ;
          => ;
          AAdd(<O>,\{<nBitIp>, <nId>, <bstate>, <bstyle>, , <ctext>, <bclick>, <c>, <d>, ,\})

#xcommand ADDTOOLBUTTON <oTool>  ;
             [ ID <nId> ]        ;
             [ BITMAP <nBitIp> ] ;
             [ STYLE <bstyle> ]  ;
             [ STATE <bstate> ]  ;
             [ TEXT <ctext> ]    ;
             [ TOOLTIP <c> ]     ;
             [ MENU <d> ]        ;
             [ NAME <cButton> ]  ;
             ON CLICK <bclick>   ;
          => ;
          <oTool>:AddButton(<nBitIp>, <nId>, <bstate>, <bstyle>, <ctext>, <bclick>, <c>, <d>, <cButton>)
