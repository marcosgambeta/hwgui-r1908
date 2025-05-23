// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand INIT WINDOW <oWnd>                   ;
             [ MAIN ]                          ;
             [ <lMdi: MDI> ]                   ;
             [ APPNAME <appname> ]             ;
             [ TITLE <cTitle> ]                ;
             [ AT <nX>, <nY> ]                 ;
             [ SIZE <nWidth>, <nHeight> ]      ;
             [ ICON <ico> ]                    ;
             [ COLOR <clr> ]                   ;
             [ BACKGROUND BITMAP <oBmp> ]      ;
             [ STYLE <nStyle> ]                ;
             [ FONT <oFont> ]                  ;
             [ MENU <cMenu> ]                  ;
             [ MENUPOS <nPos> ]                ;
             [ ON MENU <bMdiMenu> ]            ;
             [ ON INIT <bInit> ]               ;
             [ ON SIZE <bSize> ]               ;
             [ ON PAINT <bPaint> ]             ;
             [ ON GETFOCUS <bGfocus> ]         ;
             [ ON LOSTFOCUS <bLfocus> ]        ;
             [                                 ;
                [ ON OTHER MESSAGES <bOther> ] ;
                [ ON OTHERMESSAGES <bOther> ]  ;
             ]                                 ;
             [ ON REFRESH <bRefresh> ]         ;
             [ ON CLOSEQUERY <bCloseQuery> ]   ;
             [ ON EXIT <bExit> ]               ;
             [ HELP <cHelp> ]                  ;
             [ HELPID <nHelpId> ]              ;
             [ <class: CLASS> <classname> ]    ;
          => ;
          <oWnd> := __IIF(<.class.>, <classname>, HMainWindow)():New(IIf(<.lMdi.>, WND_MDI, WND_MAIN), ;
             <ico>, <clr>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <cTitle>, ;
             <cMenu>, <nPos>, <oFont>, <bInit>, <bExit>, <bSize>, <bPaint>, ;
             <bGfocus>, <bLfocus>, <bOther>, <appname>, <oBmp>, <cHelp>, <nHelpId>, <bCloseQuery>, <bRefresh>, <bMdiMenu>)

#xcommand INIT WINDOW <oWnd> MDICHILD [ VAR <vari> ] ;
             [ APPNAME <appname> ]                   ;
             [ OF <oParent> ]                        ;
             [ TITLE <cTitle> ]                      ;
             [ AT <nX>, <nY> ]                       ;
             [ SIZE <nWidth>, <nHeight> ]            ;
             [ ICON <ico> ]                          ;
             [ COLOR <clr> ]                         ;
             [ BACKGROUND BITMAP <oBmp> ]            ;
             [ STYLE <nStyle> ]                      ;
             [ FONT <oFont> ]                        ;
             [ MENU <cMenu> ]                        ;
             [ ON INIT <bInit> ]                     ;
             [ ON SIZE <bSize> ]                     ;
             [ ON PAINT <bPaint> ]                   ;
             [ ON GETFOCUS <bGfocus> ]               ;
             [ ON LOSTFOCUS <bLfocus> ]              ;
             [                                       ;
                [ ON OTHER MESSAGES <bOther> ]       ;
                [ ON OTHERMESSAGES <bOther> ]        ;
             ]                                       ;
             [ ON REFRESH <bRefresh> ]               ;
             [ ON EXIT <bExit> ]                     ;
             [ HELP <cHelp> ]                        ;
             [ HELPID <nHelpId> ]                    ;
             [ <lChild: CHILD> ]                     ;
             [ <lClipper: CLIPPER> ]                 ;
             [ <lnoClosable: NOCLOSABLE> ]           ;
             [ <class: CLASS> <classname> ]          ;
          => ;
          <oWnd> := __IIF(<.class.>, <classname>, HMdiChildWindow)():New( ;
                   <ico>, <clr>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <cTitle>, ;
                   <cMenu>, <oFont>, <bInit>, <bExit>, <bSize>, <bPaint>, ;
                   <bGfocus>, <bLfocus>, <bOther>, <appname>, <oBmp>, <cHelp>, <nHelpId>, , ;
									 <bRefresh>, <.lChild.>, <.lClipper.>, <.lnoClosable.>,[{|v|IIf(v == NIL, <vari>, <vari> := v)}]) ;;
        [ <oWnd>:SetParent(<oParent>) ]

#xcommand INIT WINDOW <oWnd> CHILD             ;
             APPNAME <appname>                 ;
             [ TITLE <cTitle> ]                ;
             [ AT <nX>, <nY> ]                 ;
             [ SIZE <nWidth>, <nHeight> ]      ;
             [ ICON <ico> ]                    ;
             [ COLOR <clr> ]                   ;
             [ BACKGROUND BITMAP <oBmp> ]      ;
             [ STYLE <nStyle> ]                ;
             [ FONT <oFont> ]                  ;
             [ MENU <cMenu> ]                  ;
             [ ON INIT <bInit> ]               ;
             [ ON SIZE <bSize> ]               ;
             [ ON PAINT <bPaint> ]             ;
             [ ON GETFOCUS <bGfocus> ]         ;
             [ ON LOSTFOCUS <bLfocus> ]        ;
             [                                 ;
                [ ON OTHER MESSAGES <bOther> ] ;
                [ ON OTHERMESSAGES <bOther> ]  ;
             ]                                 ;
             [ ON REFRESH <bRefresh> ]         ;
             [ ON EXIT <bExit> ]               ;
             [ HELP <cHelp> ]                  ;
             [ HELPID <nHelpId> ]              ;
             [ <class: CLASS> <classname> ]    ;
          => ;
          <oWnd> := __IIF(<.class.>, <classname>, HChildWindow)():New( ;
             <ico>, <clr>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <cTitle>, ;
             <cMenu>, <oFont>, <bInit>, <bExit>, <bSize>, <bPaint>, ;
             <bGfocus>, <bLfocus>, <bOther>, <appname>, <oBmp>, <cHelp>, <nHelpId>, <bRefresh>)

#xcommand ACTIVATE WINDOW <oWnd>             ;
             [ <lNoShow: NOSHOW> ]           ;
             [ <lMaximized: MAXIMIZED> ]     ;
             [ <lMinimized: MINIMIZED> ]     ;
             [ <lCentered: CENTER, CENTERED> ] ;
             [ <lModal: MODAL> ]             ;
             [ ON ACTIVATE <bInit> ]         ;
          => ;
          <oWnd>:Activate(!<.lNoShow.>, <.lMaximized.>, <.lMinimized.>, <.lCentered.>, <bInit>, <.lModal.>)

#xcommand CENTER WINDOW <oWnd> => <oWnd>:Center()

#xcommand MAXIMIZE WINDOW <oWnd> => <oWnd>:Maximize()

#xcommand MINIMIZE WINDOW <oWnd> => <oWnd>:Minimize()

#xcommand RESTORE WINDOW <oWnd> => <oWnd>:Restore()

#xcommand SHOW WINDOW <oWnd> => <oWnd>:Show()

#xcommand HIDE WINDOW <oWnd> => <oWnd>:Hide()
