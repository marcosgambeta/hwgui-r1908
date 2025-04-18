// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SPLITTER [ <oSplit> ] ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <lTransp: TRANSPARENT>]  ;
             [ <lScroll: SCROLLING>  ]  ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ DIVIDE <aLeft> FROM <aRight> ] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oSplit> :=] __IIF(<.class.>, <classname>, HSplitter)():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>,<nHeight>,<bSize>,<bDraw>,;
             <color>,<bcolor>,<aLeft>,<aRight>, <.lTransp.>, <.lScroll.> );;
          [ <oSplit>:name := <(oSplit)> ]
