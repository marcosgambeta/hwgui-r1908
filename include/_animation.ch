// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY>  ANIMATION [ <oAnimation> ] ;
             [ OF <oParent> ]                      ;
             [ ID <nId> ]                          ;
             [ FROM RESOURCE <xResID> ]            ;
             [ STYLE <nStyle> ]                    ;
             [ SIZE <nWidth>, <nHeight> ]          ;
             [ FILE <cFile> ]                      ;
             [ <autoplay: AUTOPLAY> ]              ;
             [ <center : CENTER> ]                 ;
             [ <transparent: TRANSPARENT> ]        ;
             [ <class: CLASS> <classname> ]        ;
          => ;
          [ <oAnimation> := ] __IIF(<.class.>, <classname>, HAnimation)():New(<oParent>,<nId>,<nStyle>,<nX>,<nY>, ;
             <nWidth>,<nHeight>,<cFile>,<.autoplay.>,<.center.>,<.transparent.>,<xResID>) ;;
          [ <oAnimation>:name := <(oAnimation)> ]
