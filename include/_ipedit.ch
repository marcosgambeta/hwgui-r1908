// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> GET IPADDRESS [ <oIp> VAR ] <vari> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <width>, <height> ] ;
             [ BACKCOLOR <bcolor> ]     ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ ON GETFOCUS <bGfocus> ]      ;
             [ ON LOSTFOCUS <bLfocus> ]     ;
          => ;
          [<oIp> := ] HIpEdit():New( <oWnd>,<nId>,<vari>,{|v| iif(v==Nil,<vari>,<vari>:=v)},<nStyle>,<nX>,<nY>,<width>,<height>,<oFont>, <bGfocus>, <bLfocus> );;
          [ <oIp>:name := <(oIp)> ]
