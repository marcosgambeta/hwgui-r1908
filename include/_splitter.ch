// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> SPLITTER [ <oSplit> ] ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <width>, <height> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <lTransp: TRANSPARENT>]  ;
             [ <lScroll: SCROLLING>  ]  ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ DIVIDE <aLeft> FROM <aRight> ] ;
          => ;
          [<oSplit> :=] HSplitter():New( <oWnd>,<nId>,<nX>,<nY>,<width>,<height>,<bSize>,<bDraw>,;
             <color>,<bcolor>,<aLeft>,<aRight>, <.lTransp.>, <.lScroll.> );;
          [ <oSplit>:name := <(oSplit)> ]
