// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> COMBOBOX [ <oCombo> ITEMS ] <aItems> ;
             [ OF <oParent> ]                               ;
             [ ID <nId> ]                                   ;
             [ INIT <nInit> ]                               ;
             [ SIZE <nWidth>, <nHeight> ]                   ;
             [ DISPLAYCOUNT <nDisplay>]                     ;
             [ ITEMHEIGHT <nhItem> ]                        ;
             [ COLUMNWIDTH <ncWidth> ]                      ;
             [ MAXLENGTH <nMaxLength> ]                     ;
             [ COLOR <color> ]                              ;
             [ BACKCOLOR <bcolor> ]                         ;
             [ ON INIT <bInit> ]                            ;
             [ ON SIZE <bSize> ]                            ;
             [ ON PAINT <bPaint> ]                          ;
             [ ON CHANGE <bChange> ]                        ;
             [ STYLE <nStyle> ]                             ;
             [ FONT <oFont> ]                               ;
             [ TOOLTIP <cTooltip> ]                         ;
             [ <edit: EDIT> ]                               ;
             [ <text: TEXT> ]                               ;
             [ ON GETFOCUS <bGfocus> ]                      ;
             [ ON LOSTFOCUS <bLfocus> ]                     ;
             [ ON INTERACTIVECHANGE <bIChange> ]            ;
             [ <class: CLASS> <classname> ]                 ;
          => ;
          [ <oCombo> := ] __IIF(<.class.>, <classname>, HComboBox)():New(<oParent>, <nId>, <nInit>, , <nStyle>, <nX>, <nY>, <nWidth>, ;
             <nHeight>, <aItems>, <oFont>, <bInit>, <bSize>, <bPaint>, <bChange>, <cTooltip>, ;
             <.edit.>, <.text.>, <bGfocus>, <color>, <bcolor>, <bLfocus>, <bIChange>, ;
						 <nDisplay>, <nhItem>, <ncWidth>, <nMaxLength>) ;;
          [ <oCombo>:name := <(oCombo)> ]

#xcommand REDEFINE COMBOBOX [ <oCombo> ITEMS ] <aItems> ;
            [ OF <oParent> ]                            ;
            ID <nId>                                    ;
            [ INIT <nInit> ]                            ;
            [ DISPLAYCOUNT <nDisplay>]                  ;
            [ MAXLENGTH <nMaxLength> ]                  ;
            [ ON INIT <bInit> ]                         ;
            [ ON SIZE <bSize> ]                         ;
            [ ON PAINT <bPaint> ]                       ;
            [ ON CHANGE <bChange> ]                     ;
            [ FONT <oFont> ]                            ;
            [ TOOLTIP <cTooltip> ]                      ;
            [ ON GETFOCUS <bGfocus> ]                   ;
            [ ON LOSTFOCUS <bLfocus> ]                  ;
            [ ON INTERACTIVECHANGE <bIChange> ]         ;
          => ;
    [ <oCombo> := ] HComboBox():Redefine(<oParent>, <nId>, <nInit>, , <aItems>, <oFont>, <bInit>, ;
             <bSize>, <bPaint>, <bChange>, <cTooltip>, <bGfocus>, <bLfocus>, <bIChange>, <nDisplay>, <nMaxLength>)

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET COMBOBOX [ <oCombo> VAR ] <vari> ;
            ITEMS <aItems>                                  ;
            [ OF <oParent> ]                                ;
            [ ID <nId> ]                                    ;
            [ SIZE <nWidth>, <nHeight> ]                    ;
            [ DISPLAYCOUNT <nDisplay>]                      ;
            [ ITEMHEIGHT <nhItem> ]                         ;
            [ COLUMNWIDTH <ncWidth> ]                       ;
            [ MAXLENGTH <nMaxLength> ]                      ;
            [ COLOR <color> ]                               ;
            [ BACKCOLOR <bcolor> ]                          ;
            [ ON INIT <bInit> ]                             ;
            [ ON CHANGE <bChange> ]                         ;
            [ STYLE <nStyle> ]                              ;
            [ FONT <oFont> ]                                ;
            [ TOOLTIP <cTooltip> ]                          ;
            [ <edit: EDIT> ]                                ;
            [ <text: TEXT> ]                                ;
            [ <focusin: WHEN, ON GETFOCUS> <bGfocus> ]      ;
            [ <focusout: VALID, ON LOSTFOCUS> <bLfocus> ]   ;
            [ ON INTERACTIVECHANGE <bIChange> ]             ;
            [ <class: CLASS> <classname> ]                  ;
          => ;
    [ <oCombo> := ] __IIF(<.class.>, <classname>, HComboBox)():New(<oParent>, <nId>, <vari>,    ;
                    {|v|IIf(v == NIL, <vari>, <vari> := v)},      ;
                    <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>,      ;
                    <aItems>, <oFont>, <bInit>, , , <bChange>, <cTooltip>, ;
                    <.edit.>, <.text.>, <bGfocus>, <color>, <bcolor>, ;
                    <bLfocus>, <bIChange>, <nDisplay>, <nhItem>, <ncWidth>, <nMaxLength>) ;;
    [ <oCombo>:name := <(oCombo)> ]


#xcommand REDEFINE GET COMBOBOX [ <oCombo> VAR ] <vari>   ;
            ITEMS <aItems>                                ;
            [ OF <oParent> ]                              ;
            ID <nId>                                      ;
            [ DISPLAYCOUNT <nDisplay>]                    ;
            [ MAXLENGTH <nMaxLength> ]                    ;
            [ ON CHANGE <bChange> ]                       ;
            [ FONT <oFont> ]                              ;
            [ TOOLTIP <cTooltip> ]                        ;
            [ <focusin: WHEN, ON GETFOCUS> <bGfocus> ]    ;
            [ <focusout: VALID, ON LOSTFOCUS> <bLfocus> ] ;
            [ ON INTERACTIVECHANGE <bIChange> ]           ;
            [ <edit: EDIT> ]                              ;
            [ <text: TEXT> ]                              ;
          => ;
    [ <oCombo> := ] HComboBox():Redefine(<oParent>, <nId>, <vari>, ;
                    {|v|IIf(v == NIL, <vari>, <vari> := v)},        ;
                    <aItems>, <oFont>, , , , <bChange>, <cTooltip>, <bGfocus>, <bLfocus>, <bIChange>, <nDisplay>, <nMaxLength>, <.edit.>, <.text.>)

#xcommand REDEFINE GET COMBOBOXEX [ <oCombo> VAR ] <vari> ;
             ITEMS  <aItems>                              ;
             [ OF <oParent> ]                             ;
             ID <nId>                                     ;
             [ ON CHANGE <bChange> ]                      ;
             [ FONT <oFont> ]                             ;
             [ TOOLTIP <cTooltip> ]                       ;
             [ WHEN <bWhen> ]                             ;
             [ CHECK <acheck>]                            ;
          => ;
          [ <oCombo> := ] HComboBox():Redefine(<oParent>, <nId>, <vari>, ;
             {|v|IIf(v == NIL, <vari>, <vari> := v)},        ;
             <aItems>, <oFont>, , , , <bChange>, <cTooltip>, <bWhen>, <acheck>)
