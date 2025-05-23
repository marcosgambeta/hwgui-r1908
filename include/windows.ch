#ifndef _WINDOWS_CH_
#define _WINDOWS_CH_

#define WM_CREATE                       1
#define WM_DESTROY                      2
#define WM_MOVE                         3
#define WM_SIZE                         5
#define WM_ACTIVATE                     6
#define WM_SETFOCUS                     7
#define WM_KILLFOCUS                    8
#define WM_ENABLE                       10
#define WM_SETREDRAW                    11
#define WM_SETTEXT                      12
#define WM_GETTEXT                      13
#define WM_GETTEXTLENGTH                14
#define WM_PAINT                        15
#define WM_CLOSE                        16   // 0x0010

#define WM_ERASEBKGND                   20   // 0x0014
#define WM_ENDSESSION                   22   // 0x0016
#define WM_ACTIVATEAPP                  28
#DEFINE WM_MOUSEACTIVATE                33
#define WM_GETMINMAXINFO                36   // 0x0024
#define WM_NEXTDLGCTL                   40   // 0x0028
#define WM_DRAWITEM                     43   // 0x002B
#define WM_MEASUREITEM                  0x002C
#define WM_SETFONT                      48   // 0x0030

#define WM_WINDOWPOSCHANGING            70   // 0x0046

#define WM_NOTIFY                       78   // 0x004E
#define WM_HELP                         83
#define WM_NOTIFYFORMAT                 85
#define WM_SETICON                      128    // 0x0080

#define WM_NCCREATE                     129
#define WM_NCDESTROY                    130
#define WM_NCCALCSIZE                   131
#define WM_NCHITTEST                    132
#define WM_NCPAINT                      133
#define WM_NCACTIVATE                   134
#define WM_GETDLGCODE                   135

#define WM_KEYDOWN                      256    // 0x0100
#define WM_KEYUP                        257    // 0x0101
#define WM_CHAR                         258    // 0x0102
#define WM_SYSKEYDOWN                   260    // 0x0104
#define WM_SYSKEYUP                     261    // 0x0105
#define WM_SYSCHAR                      262    //= &H106

#define WM_INITDIALOG                   272
#define WM_COMMAND                      273
#define WM_SYSCOMMAND                   274
#define WM_TIMER                        275
#define WM_HSCROLL                      276
#define WM_VSCROLL                      277

#define WM_INITMENU                     278    //= $0116
#define WM_INITMENUPOPUP                279    //= $0117
#define WM_MENUSELECT                   287    //= $011F
#define WM_MENUCHAR                     288    //= $0120

#define WM_ENTERIDLE                    289
#define WM_CHANGEUISTATE                295   //0x127 
#define WM_UPDATEUISTATE                296   //0x128
#define WM_QUERYUISTATE                 297   //0x0129

#define WM_CTLCOLORMSGBOX               306     // 0x0132
#define WM_CTLCOLOREDIT                 307     // 0x0133
#define WM_CTLCOLORLISTBOX              308     // 0x0134
#define WM_CTLCOLORBTN                  309     // 0x0135
#define WM_CTLCOLORDLG                  310     // 0x0136
#define WM_CTLCOLORSCROLLBAR            311     // 0x0137
#define WM_CTLCOLORSTATIC               312     // 0x0138

#define WM_MOUSEMOVE                    512    // 0x0200
#define WM_LBUTTONDOWN                  513    // 0x0201
#define WM_LBUTTONUP                    514    // 0x0202
#define WM_LBUTTONDBLCLK                515    // 0x0203
#define WM_RBUTTONDOWN                  516    // 0x0204
#define WM_RBUTTONUP                    517    // 0x0205
#define WM_MBUTTONUP	                   520    // 0x0208
#define WM_MOUSEWHEEL                   522    // 0x020A
#define WM_PARENTNOTIFY                 528    // 0x0210
#define WM_NEXTMENU                     531    // 0x0213
#define WM_SIZING                       532    // 0x0214
#define WM_CAPTURECHANGED               533     // 0x0215
#define	WM_MOVING                       534     //  0x0216,
#define WM_MDICREATE                    544     // 0x0220
#define WM_MDIDESTROY                   545     // 0x0221
#define WM_MDIACTIVATE                  546     // 0x0222
#define WM_MDIRESTORE                   547     // 0x0223
#define WM_MDINEXT                      548     // 0x0224
#define WM_MDIMAXIMIZE                  549     // 0x0225
#define WM_MDITILE                      550     // 0x0226
#define WM_MDICASCADE                   551     // 0x0227
#define WM_MDIICONARRANGE               552     // 0x0228
#define WM_MDIGETACTIVE                 553     // 0x0229
#define WM_MDISETMENU                   560     // 0x0230
#define WM_ENTERSIZEMOVE                561     // 0x0231
#define WM_EXITSIZEMOVE                 562     // 0x0232

#define WM_CUT                          768     // 0x0300
#define WM_COPY                         769     // 0x0301
#define WM_PASTE                        770     // 0x0302
#define WM_CLEAR                        771     // 0x0303

#DEFINE WM_PRINT                        791
#DEFINE	WM_PRINTCLIENT                  792

#define WM_USER                        1024    // 0x0400

#define SC_SIZE                       61440   // &HF000
#define SC_MINIMIZE                   61472   // 0xF020
#define SC_MAXIMIZE                   61488   // 0xF030
#define SC_MAXIMIZE2                  61490   // 0xF032, Sent when form maximizes because of doubcle click on caption
#define SC_CLOSE                      61536   // 0xF060
#define SC_RESTORE                    61728   // 0xF120
#define SC_RESTORE2                   61730   // 0xF122 Sent when form maximizes because of doubcle click on caption
#define SC_KEYMENU                    61696	  // HF100
#define SC_NEXTWINDOW                 61504   // &HF040
#define SC_PREVWINDOW                 61520   // &HF050
#define SC_HOTKEY                     61776   // &HF150
#define SC_MOUSEMENU                  61584   //  HF090
#define SC_SEPARATOR                  61455  // 0xF00F
#define SC_MENU                       61589   // &HF095


#define GWL_ID                        - 12
#define GWL_STYLE                     - 16

/*
* CONSTANTS TO   WM_CHANGEUISTATE
*/
#define UIS_CLEAR          2
#define UIS_INITIALIZE     3
#define UISF_HIDEACCEL     2
#define UISF_HIDEFOCUS     3

/* CONSTANTS TO   WM_PRINT */
#DEFINE PRF_CHECKVISIBLE         1
#DEFINE PRF_CLIENT               4
#DEFINE PRF_ERASEBKGND           8
#DEFINE PRF_CHILDREN            16
#DEFINE PRF_OWNED               32

/* CONSTANTS TO TRACKMOUSEEVENT */
#DEFINE  TME_CANCEL            0x80000000 
#DEFINE  TME_HOVER             1
#DEFINE  TME_LEAVE             2 



/*
 * Dialog Box Command IDs
 */
#define IDOK                1
#define IDCANCEL            2
#define IDABORT             3
#define IDRETRY             4
#define IDIGNORE            5
#define IDYES               6
#define IDNO                7
#define IDHELP              9

#define DS_ABSALIGN         1        // 0x01L
#define DS_SYSMODAL         2        // 0x02L
#define DS_CENTER           2048     // 0x0800L
#define DS_MODALFRAME       0x80

/*
 * Static Control Notification Codes
 */
#define STN_CLICKED    0
#define STN_DBLCLK     1
#define STN_ENABLE     3

/*
 * User Button Notification Codes
 */
#define BN_CLICKED          0
#define BN_PAINT            1
#define BN_HILITE           2
#define BN_UNHILITE         3
#define BN_DISABLE          4
#define BN_DOUBLECLICKED    5
#define BN_PUSHED           BN_HILITE
#define BN_UNPUSHED         BN_UNHILITE
#define BN_DBLCLK           BN_DOUBLECLICKED
#define BN_SETFOCUS         6
#define BN_KILLFOCUS        7

/*
 * Edit Control Notification Codes
 */
#define EN_SETFOCUS         256    // 0x0100
#define EN_KILLFOCUS        512    // 0x0200
#define EN_CHANGE           768    // 0x0300
#define EN_UPDATE           1024   // 0x0400
#define EN_ERRSPACE         1280   // 0x0500
#define EN_MAXTEXT          1281   // 0x0501
#define EN_HSCROLL          1537   // 0x0601
#define EN_VSCROLL          1538   // 0x0602
#define EN_SELCHANGE        1794   // 0x0702
#define EN_PROTECTED        1796   // 0x0702

/*
 * Combo Box messages
 */
#define CB_GETEDITSEL               320
#define CB_LIMITTEXT                321
#define CB_SETEDITSEL               322
#define CB_ADDSTRING                323
#define CB_DELETESTRING             324
#define CB_DIR                      325
#define CB_GETCOUNT                 326
#define CB_GETCURSEL                327
#define CB_GETLBTEXT                328
#define CB_GETLBTEXTLEN             329
#define CB_INSERTSTRING             330
#define CB_RESETCONTENT             331
#define CB_FINDSTRING               332
#define CB_SELECTSTRING             333
#define CB_SETCURSEL                334
#DEFINE CB_SHOWDROPDOWN             335
#define CB_SETITEMHEIGHT            0x0153
#define CB_GETITEMHEIGHT            0x0154
#define CB_GETDROPPEDSTATE          343
#define CB_FINDSTRINGEXACT          344
#define CB_SETDROPPEDWIDTH          0x0160
#define CB_SETCUEBANNER             5891 // 0x1703


/* Brush Styles */
#define BS_SOLID            0
#define BS_NULL             1
#define BS_HOLLOW           BS_NULL
#define BS_HATCHED          2
#define BS_PATTERN          3
#define BS_INDEXED          4
#define BS_DIBPATTERN       5
#define BS_DIBPATTERNPT     6
#define BS_PATTERN8X8       7
#define BS_DIBPATTERN8X8    8
#define BS_MONOPATTERN      9

/* Pen Styles */
#define PS_SOLID            0
#define PS_DASH             1       /* -------  */
#define PS_DOT              2       /* .......  */
#define PS_DASHDOT          3       /* _._._._  */
#define PS_DASHDOTDOT       4       /* _.._.._  */
#define PS_NULL             5
#define PS_INSIDEFRAME      6
#define PS_USERSTYLE        7
#define PS_ALTERNATE        8
#define PS_STYLE_MASK       15

/* SETBKMODE */
#define OPAQUE 2

#define COLOR_SCROLLBAR                 0
#define COLOR_BACKGROUND                1
#define COLOR_ACTIVECAPTION             2
#define COLOR_INACTIVECAPTION           3
#define COLOR_MENU                      4
#define COLOR_WINDOW                    5
#define COLOR_WINDOWFRAME               6
#define COLOR_MENUTEXT                  7
#define COLOR_WINDOWTEXT                8
#define COLOR_CAPTIONTEXT               9
#define COLOR_ACTIVEBORDER              10
#define COLOR_INACTIVEBORDER            11
#define COLOR_APPWORKSPACE              12
#define COLOR_HIGHLIGHT                 13
#define COLOR_HIGHLIGHTTEXT             14
#define COLOR_BTNFACE                   15
#define COLOR_BTNSHADOW                 16
#define COLOR_GRAYTEXT                  17
#define COLOR_BTNTEXT                   18
#define COLOR_INACTIVECAPTIONTEXT       19
#define COLOR_BTNHIGHLIGHT              20

#define COLOR_3DDKSHADOW                21
#define COLOR_3DLIGHT                   22
#define COLOR_INFOTEXT                  23
#define COLOR_INFOBK                    24

#define COLOR_HOTLIGHT                  26
#define COLOR_GRADIENTACTIVECAPTION     27
#define COLOR_GRADIENTINACTIVECAPTION   28

#define COLOR_DESKTOP                   COLOR_BACKGROUND
#define COLOR_3DFACE                    COLOR_BTNFACE
#define COLOR_3DSHADOW                  COLOR_BTNSHADOW
#define COLOR_3DHIGHLIGHT               COLOR_BTNHIGHLIGHT
#define COLOR_3DHILIGHT                 COLOR_BTNHIGHLIGHT
#define COLOR_BTNHILIGHT                COLOR_BTNHIGHLIGHT

/*
 * DrawText() Format Flags
 */
#define DT_TOP                      0
#define DT_LEFT                     0
#define DT_CENTER                   1
#define DT_RIGHT                    2
#define DT_VCENTER                  4
#define DT_BOTTOM                   8
#define DT_WORDBREAK                16
#define DT_SINGLELINE               32
#define DT_EXPANDTABS               64
#define DT_TABSTOP                  128
#define DT_NOCLIP                   256
#define DT_EXTERNALLEADING          512
#define DT_CALCRECT                 1024
#define DT_NOPREFIX                 2048
#define DT_INTERNAL                 4096

#define DT_EDITCONTROL              8192
#define DT_PATH_ELLIPSIS            16384
#define DT_END_ELLIPSIS             32768
#define DT_MODIFYSTRING             65536
#define DT_RTLREADING               131072
#define DT_WORD_ELLIPSIS            262144
#define DT_NOFULLWIDTHCHARBREAK     524288
#define DT_HIDEPREFIX               1048576
#define DT_PREFIXONLY               2097152

/*
 * Scroll Bar Commands
 */
#define SB_HORZ             0
#define SB_VERT             1
#define SB_CTL              2
#define SB_BOTH             3
#define SB_LINEUP           0
#define SB_LINELEFT         0
#define SB_LINEDOWN         1
#define SB_LINERIGHT        1
#define SB_PAGEUP           2
#define SB_PAGELEFT         2
#define SB_PAGEDOWN         3
#define SB_PAGERIGHT        3
#define SB_THUMBPOSITION    4
#define SB_THUMBTRACK       5
#define SB_TOP              6
#define SB_LEFT             6
#define SB_BOTTOM           7
#define SB_RIGHT            7
#define SB_ENDSCROLL        8

/*
 * Edit Control Styles
 */
#define ES_LEFT             0
#define ES_CENTER           1
#define ES_RIGHT            2
#define ES_MULTILINE        4
#define ES_UPPERCASE        8
#define ES_LOWERCASE        16
#define ES_PASSWORD         32
#define ES_AUTOVSCROLL      64
#define ES_AUTOHSCROLL      128
#define ES_NOHIDESEL        256
#define ES_OEMCONVERT       1024
#define ES_READONLY         2048       // 0x0800L
#define ES_WANTRETURN       4096       // 0x1000L
#define ES_NUMBER           8192       // 0x2000L

/*
 * DatePicker Control Styles
*/

#define DTS_SHOWNONE        2          // 0x0002
#define DTS_TIMEFORMAT      9 

/*
 * Window Styles
 */
#define WS_OVERLAPPED       0
#define WS_POPUP            2147483648 // 0x80000000L
#define WS_CHILD            1073741824 // 0x40000000L
#define WS_MINIMIZE         536870912  // 0x20000000L
#define WS_VISIBLE          268435456  // 0x10000000L
#define WS_DISABLED         134217728  // 0x08000000L
#define WS_CLIPSIBLINGS     67108864   // 0x04000000L
#define WS_CLIPCHILDREN     33554432
#define WS_MAXIMIZE         16777216   // 0x01000000L
#define WS_CAPTION          12582912   // 0x00C00000L
#define WS_BORDER           8388608    // 0x00800000L
#define WS_DLGFRAME         4194304    // 0x00400000L
#define WS_EX_STATICEDGE    131072     // 0x00020000L
#define WS_VSCROLL          2097152    // 0x00200000L
#define WS_HSCROLL          1048576    // 0x00100000L
#define WS_SYSMENU          524288     // 0x00080000L
#define WS_THICKFRAME       262144     // 0x00040000L
#define WS_GROUP            131072     // 0x00020000L
#define WS_TABSTOP          65536      // 0x00010000L
#define WS_MINIMIZEBOX      131072     // 0x00020000L
#define WS_MAXIMIZEBOX      65536      // 0x00010000L
#define WS_SIZEBOX          WS_THICKFRAME
#define WS_OVERLAPPEDWINDOW WS_OVERLAPPED + WS_CAPTION + WS_SYSMENU + WS_THICKFRAME + WS_MINIMIZEBOX + WS_MAXIMIZEBOX

#define WS_EX_DLGMODALFRAME     1      // 0x00000001L
#define WS_EX_NOPARENTNOTIFY    4      // 0x00000004L
#define WS_EX_TOPMOST           8      // 0x00000008L
#define WS_EX_ACCEPTFILES      16      // 0x00000010L
#define WS_EX_TRANSPARENT      32      // 0x00000020L
#define WS_EX_TOOLWINDOW      128

#define RDW_INVALIDATE          1      // 0x0001
#define RDW_INTERNALPAINT       2      // 0x0002
#define RDW_ERASE               4      // 0x0004
#define RDW_VALIDATE            8      // 0x0008
#define RDW_NOINTERNALPAINT     16     // 0x0010
#define RDW_NOERASE             32     // 0x0020
#define RDW_NOCHILDREN          64     // 0x0040
#define RDW_ALLCHILDREN         128    // 0x0080
#define RDW_UPDATENOW           256    // 0x0100
#define RDW_ERASENOW            512    // 0x0200
#define RDW_FRAME              1024    // 0x0400
#define RDW_NOFRAME            2048    // 0x0800

/*
 * Window States
 */
#DEFINE WA_INACTIVE               0
#DEFINE WA_ACTIVE                 1
#DEFINE WA_CLICKACTIVE            2

/*
 * Static Control Constants
 */
#define SS_LEFT                   0    // 0x00000000L
#define SS_CENTER                 1    // 0x00000001L
#define SS_RIGHT                  2    // 0x00000002L
#define SS_ICON                   3    // 0x00000003L
#define SS_BLACKRECT              4    // 0x00000004L
#define SS_GRAYRECT               5    // 0x00000005L
#define SS_WHITERECT              6    // 0x00000006L
#define SS_BLACKFRAME             7    // 0x00000007L
#define SS_GRAYFRAME              8    // 0x00000008L
#define SS_WHITEFRAME             9    // 0x00000009L
#define SS_USERITEM              10    // 0x0000000AL
#define SS_SIMPLE                11    // 0x0000000BL
#define SS_LEFTNOWORDWRAP        12    // 0x0000000CL
#define SS_OWNERDRAW             13    // 0x0000000DL
#define SS_BITMAP                14    // 0x0000000EL
#define SS_ENHMETAFILE           15    // 0x0000000FL
#define SS_ETCHEDHORZ            16    // 0x00000010L
#define SS_ETCHEDVERT            17    // 0x00000011L
#define SS_ETCHEDFRAME           18    // 0x00000012L
#define SS_TYPEMASK              31    // 0x0000001FL
#define SS_NOTIFY               256    // 0x00000100L
#define SS_CENTERIMAGE          512    // 0x00000200L
#define SS_RIGHTJUST           1024    // 0x00000400L
#define SS_REALSIZEIMAGE       2048    // 0x00000800L
#define SS_SUNKEN              4096    // 0x00001000L

/*
 * Status bar Constants
 */
#define SB_SETTEXT              (WM_USER+1)
#define SB_GETTEXT              (WM_USER+2)
#define SB_GETTEXTLENGTH        (WM_USER+3)
#define SB_SETPARTS             (WM_USER+4)
#define SB_GETPARTS             (WM_USER+6)
#define SB_GETBORDERS           (WM_USER+7)
#define SB_SETMINHEIGHT         (WM_USER+8)
#define SB_SIMPLE               (WM_USER+9)
#define SB_GETRECT              (WM_USER+10)
#define SB_SETICON              (WM_USER+15)

/*
 * Button Control Styles
 */
#define BS_PUSHBUTTON       0       // 0x00000000L
#define BS_DEFPUSHBUTTON    1       // 0x00000001L
#define BS_CHECKBOX         2       // 0x00000002L
#define BS_AUTOCHECKBOX     3       // 0x00000003L
#define BS_RADIOBUTTON      4       // 0x00000004L
#define BS_3STATE           5       // 0x00000005L
#define BS_AUTO3STATE       6       // 0x00000006L
#define BS_GROUPBOX         7       // 0x00000007L
#define BS_USERBUTTON       8       // 0x00000008L
#define BS_AUTORADIOBUTTON  9       // 0x00000009L
#define BS_OWNERDRAW        11      // 0x0000000BL
#define BS_SPLITBUTTON      12        // 0x0000000C
#define BS_COMMANDLINK      14        // 0x0000000E
#define BS_LEFTTEXT         32      // 0x00000020L

#DEFINE BCM_SETNOTE         5641     // 0x00001609

#define IDC_ARROW           32512
#define IDC_IBEAM           32513
#define IDC_WAIT            32514
#define IDC_CROSS           32515
#define IDC_SIZEWE          32644
#define IDC_SIZENS          32645
#define IDC_UPARROW         32516
#define IDC_HAND            32649

/*
 * Key State Masks for Mouse Messages
 */
#define MK_LBUTTON          1       // 0x0001
#define MK_RBUTTON          2       // 0x0002
#define MK_SHIFT            4       // 0x0004
#define MK_CONTROL          8       // 0x0008
#define MK_MBUTTON          16      // 0x0010
#define MK_XBUTTON1         32      // 0x0020
#define MK_XBUTTON2         64      // 0x0040

/* Ternary raster operations */
#define SRCCOPY             13369376   /* 0x00CC0020  dest = source          */
#define SRCPAINT            0          /* 0x00EE0086  dest = source OR dest  */
#define SRCAND              8913094    /* 0x008800C6  dest = source AND dest */
// #define SRCINVERT           0          /* 0x00660046  dest = source XOR dest */
// #define SRCERASE            0x00440328 /* dest = source AND (NOT dest )   */
// #define NOTSRCCOPY          0x00330008 /* dest = (NOT source)             */
// #define NOTSRCERASE         0x001100A6 /* dest = (NOT src) AND (NOT dest) */
#define MERGECOPY           12583114      /* 0x00C000CA dest = (source AND pattern) */
#define MERGEPAINT          12255782      /* 0x00BB0226 dest = (NOT source) OR dest */
// #define PATCOPY             0x00F00021 /* dest = pattern                  */
// #define PATPAINT            0x00FB0A09 /* dest = DPSnoo                   */
// #define PATINVERT           0x005A0049 /* dest = pattern XOR dest         */
// #define DSTINVERT           0x00550009 /* dest = (NOT dest)               */
// #define BLACKNESS           0x00000042 /* dest = BLACK                    */
// #define WHITENESS           0x00FF0062 /* dest = WHITE                    */

#define PSN_SETACTIVE           -200   // (PSN_FIRST-0)
#define PSN_KILLACTIVE          -201   // (PSN_FIRST-1)
#define PSN_APPLY               -202   // (PSN_FIRST-2)
#define PSN_RESET               -203   // (PSN_FIRST-3)
#define PSN_HELP                -205   // (PSN_FIRST-5)
#define PSN_WIZBACK             -206   // (PSN_FIRST-6)
#define PSN_WIZNEXT             -207   // (PSN_FIRST-7)
#define PSN_WIZFINISH           -208   // (PSN_FIRST-8)
#define PSN_QUERYCANCEL         -209   // (PSN_FIRST-9)

#if 0 // disabled - duplications
#define TCN_FIRST               -550       // tab control
#define TCN_CLICK               -2
#define TCN_RCLICK              -5
#define TCN_SETFOCUS            -550
#define TCN_GETFOCUS            -552
#define TCN_KILLFOCUS           -552
#define TCN_KEYDOWN             -550   //(TCN_FIRST - 0)
#define TCN_SELCHANGE           -551   //(TCN_FIRST - 1)
#define TCN_SELCHANGING         -552   //(TCN_FIRST - 2)
#define TCN_GETOBJECT           -553   //(TCN_FIRST - 3)
#define TCN_FOCUSCHANGE         -554   //(TCN_FIRST - 4)
#endif

#define TCN_FIRST       (0-550)
#define TCN_LAST        (0-580)
#define TCN_KEYDOWN     (TCN_FIRST - 0)
#define TCN_SELCHANGE   (TCN_FIRST - 1)
#define TCN_SELCHANGING (TCN_FIRST - 2)
#define TCN_GETOBJECT   (TCN_FIRST - 3)
#define TCN_FOCUSCHANGE (TCN_FIRST - 4)
#define TCN_CLICK       -2
#define TCN_RCLICK      -5
#define TCN_SETFOCUS    -555
#define TCN_KILLFOCUS   -556

#define TCM_FIRST               4864     // Tab control messages
#define TCM_SETIMAGELIST        4867     // (TCM_FIRST + 3)
#define TCM_GETITEMCOUNT        4868     // (TCM_FIRST + 4)
#define TCM_GETITEMRECT         ( TCM_FIRST + 10 )
#define TCM_GETCURSEL           4875		 // TCM_FIRST + 11)
#define TCM_SETCURSEL           4876     // (TCM_FIRST + 12)
#define TCM_HITTEST             ( TCM_FIRST + 13 )
#define TCM_SETITEMSIZE         ( TCM_FIRST + 41 )
#define TCM_SETPADDING          ( TCM_FIRST + 43 )
#define TCM_GETROWCOUNT         4908     // (TCM_FIRST + 44)
#define TCM_GETCURFOCUS         4911     // (TCM_FIRST + 47)
#define TCM_SETCURFOCUS         4912     // (TCM_FIRST + 48)
#define TCM_SETMINTABWIDTH      ( TCM_FIRST + 49 )
#define TCM_DESELECTALL         4914        //(TCM_FIRST + 50)

/*
 * Combo Box styles
 */
#define CBS_SIMPLE            1        // 0x0001L
#define CBS_DROPDOWN          2        // 0x0002L
#define CBS_DROPDOWNLIST      3        // 0x0003L
#define CBS_OWNERDRAWFIXED    0x0010
#define CBS_OWNERDRAWVARIABLE 0x0020
#define CBS_AUTOHSCROLL       0x0040
#define CBS_OEMCONVERT        0x0080
#define CBS_SORT              0x0100
#define CBS_HASSTRINGS        0x0200
#define CBS_NOINTEGRALHEIGHT  0x0400
#define CBS_DISABLENOSCROLL   0x0800
#define CBS_UPPERCASE         8192 //$2000
#define CBS_LOWERCASE         16384 //$4000

/*
 * Tree styles
 */
#define TVS_HASBUTTONS          1   // 0x0001
#define TVS_HASLINES            2   // 0x0002
#define TVS_LINESATROOT         4   // 0x0004
#define TVS_EDITLABELS          8   // 0x0008
#define TVS_DISABLEDRAGDROP    16   // 0x0010
#define TVS_SHOWSELALWAYS      32   // 0x0020
#define TVS_RTLREADING         64   // 0x0040
#define TVS_NOTOOLTIPS        128   // 0x0080
#define TVS_CHECKBOXES        256   // 0x0100
#define TVS_TRACKSELECT       512   // 0x0200
#define TVS_SINGLEEXPAND     1024   // 0x0400
#define TVS_INFOTIP          2048   // 0x0800
#define TVS_FULLROWSELECT    4096   // 0x1000
#define TVS_NOSCROLL         8192   // 0x2000
#define TVS_NONEVENHEIGHT   16384   // 0x4000
#define TVS_NOHSCROLL       32768   // 0x8000  // TVS_NOSCROLL overrides this

/*
 * MessageBox() Flags
 */
#define MB_OK                 0        // 0x00000000L
#define MB_OKCANCEL           1        // 0x00000001L
#define MB_ABORTRETRYIGNORE   2        // 0x00000002L
#define MB_YESNOCANCEL        3        // 0x00000003L
#define MB_YESNO              4        // 0x00000004L
#define MB_RETRYCANCEL        5        // 0x00000005L
#define MB_ICONHAND           16       // 0x00000010L
#define MB_ICONQUESTION       32       // 0x00000020L
#define MB_ICONEXCLAMATION    48       // 0x00000030L
#define MB_ICONASTERISK       64       // 0x00000040L

#define MB_USERICON           128      // 0x00000080L
#define MB_NOFOCUS            32768    // 0x00008000L
#define MB_SETFOREGROUND      65536    // 0x00010000L
#define MB_DEFAULT_DESKTOP_ONLY  131072 // 0x00020000L

#define MB_TOPMOST            262144   // 0x00040000L
#define MB_RIGHT              524288   // 0x00080000L
#define MB_RTLREADING         1048576  // 0x00100000L


#define HKEY_CLASSES_ROOT     2147483648       // 0x80000000
#define HKEY_CURRENT_USER     2147483649       // 0x80000001
#define HKEY_LOCAL_MACHINE    2147483650       // 0x80000002
#define HKEY_USERS            2147483651       // 0x80000003
#define HKEY_PERFORMANCE_DATA 2147483652       // 0x80000004
#define HKEY_CURRENT_CONFIG   2147483653       // 0x80000005
#define HKEY_DYN_DATA         2147483654       // 0x80000006

#define MDITILE_VERTICAL       0
#define MDITILE_HORIZONTAL     1

/*
 * OEM Resource Ordinal Numbers
 */
#define OBM_CLOSE           32754
#define OBM_UPARROW         32753
#define OBM_DNARROW         32752
#define OBM_RGARROW         32751
#define OBM_LFARROW         32750
#define OBM_REDUCE          32749
#define OBM_ZOOM            32748
#define OBM_RESTORE         32747
#define OBM_REDUCED         32746
#define OBM_ZOOMD           32745
#define OBM_RESTORED        32744
#define OBM_UPARROWD        32743
#define OBM_DNARROWD        32742
#define OBM_RGARROWD        32741
#define OBM_LFARROWD        32740
#define OBM_MNARROW         32739
#define OBM_COMBO           32738
#define OBM_UPARROWI        32737
#define OBM_DNARROWI        32736
#define OBM_RGARROWI        32735
#define OBM_LFARROWI        32734

#define OBM_OLD_CLOSE       32767
#define OBM_SIZE            32766
#define OBM_OLD_UPARROW     32765
#define OBM_OLD_DNARROW     32764
#define OBM_OLD_RGARROW     32763
#define OBM_OLD_LFARROW     32762
#define OBM_BTSIZE          32761
#define OBM_CHECK           32760
#define OBM_CHECKBOXES      32759
#define OBM_BTNCORNERS      32758
#define OBM_OLD_REDUCE      32757
#define OBM_OLD_ZOOM        32756
#define OBM_OLD_RESTORE     32755

#define TCS_SCROLLOPPOSITE      1       // 0x0001   // assumes multiline tab
#define TCS_BOTTOM              2       // 0x0002
#define TCS_RIGHT               2       // 0x0002
#define TCS_MULTISELECT         4       // 0x0004  // allow multi-select in button mode
#define TCS_FLATBUTTONS         8       // 0x0008
#define TCS_FORCEICONLEFT       16      // 0x0010
#define TCS_FORCELABELLEFT      32      // 0x0020
#define TCS_HOTTRACK            64      // 0x0040
#define TCS_VERTICAL            128     // 0x0080
#define TCS_TABS                0       // 0x0000
#define TCS_BUTTONS             256     // 0x0100
#define TCS_SINGLELINE          0       // 0x0000
#define TCS_MULTILINE           512     // 0x0200
#define TCS_RIGHTJUSTIFY        0       // 0x0000
#define TCS_FIXEDWIDTH          1024    // 0x0400
#define TCS_RAGGEDRIGHT         2048    // 0x0800
#define TCS_FOCUSONBUTTONDOWN   4096    // 0x1000
#define TCS_OWNERDRAWFIXED      8192    // 0x2000
#define TCS_TOOLTIPS            16384   // 0x4000
#define TCS_FOCUSNEVER          32768   // 0x8000

#define EM_GETSEL               176     // 0x00B0
#define EM_SETSEL               177     // 0x00B1
#define EM_GETRECT              178     // 0x00B2
#define EM_SETRECT              179     // 0x00B3
#define EM_SETRECTNP            180     // 0x00B4
#define EM_SCROLL               181     // 0x00B5
#define EM_LINESCROLL           182     // 0x00B6
#define EM_SCROLLCARET          183     // 0x00B7
#define EM_GETMODIFY            184     // 0x00B8
#define EM_SETMODIFY            185     // 0x00B9
#define EM_GETLINECOUNT         186     // 0x00BA
#define EM_LINEINDEX            187     // 0x00BB
#define EM_SETHANDLE            188     // 0x00BC
#define EM_GETHANDLE            189     // 0x00BD
#define EM_GETTHUMB             190     // 0x00BE
#define EM_LINELENGTH           193     // 0x00C1
#define EM_REPLACESEL           194     // 0x00C2
#define EM_GETLINE              196     // 0x00C4
#define EM_LIMITTEXT            197     // 0x00C5
#define EM_CANUNDO              198     // 0x00C6
#define EM_UNDO                 199     // 0x00C7
#define EM_CANREDO   EM_CANUNDO      // 0x00C6
#define EM_REDO      EM_UNDO         // 0x00C7

#define EM_FMTLINES             200     // 0x00C8
#define EM_LINEFROMCHAR         201     // 0x00C9
#define EM_SETTABSTOPS          203     // 0x00CB
#define EM_SETPASSWORDCHAR      204     // 0x00CC
#define EM_EMPTYUNDOBUFFER      205     // 0x00CD
#define EM_GETFIRSTVISIBLELINE  206     // 0x00CE
#define EM_SETREADONLY          207     // 0x00CF
#define EM_SETWORDBREAKPROC     208     // 0x00D0
#define EM_GETWORDBREAKPROC     209     // 0x00D1
#define EM_GETPASSWORDCHAR      210     // 0x00D2
#define EM_SETMARGINS           211     // 0x00D3
#define EM_GETMARGINS           212     // 0x00D4
#define EM_SETLIMITTEXT         EM_LIMITTEXT
#define EM_GETLIMITTEXT         213     // 0x00D5
#define EM_POSFROMCHAR          214     // 0x00D6
#define EM_CHARFROMPOS          215     // 0x00D7
#define EM_HIDESELECTION        1087
#define EM_SETBKGNDCOLOR        1091
#define EM_SETCHARFORMAT        1092     // (WM_USER + 68)
#define EM_SETEVENTMASK         1093     // (WM_USER + 69)


#define ENM_CHANGE             1        // 0x00000001
#define ENM_SELCHANGE          524288   // 0x00080000
#define ENM_PROTECTED          0x00200000

#define IMAGE_BITMAP        0
#define IMAGE_ICON          1
#define IMAGE_CURSOR        2

#define LR_DEFAULTCOLOR         0
#define LR_MONOCHROME           1
#define LR_COLOR                2
#define LR_COPYRETURNORG        4
#define LR_COPYDELETEORG        8
#define LR_LOADFROMFILE        16       // 0x0010
#define LR_LOADTRANSPARENT     32       // 0x0020
#define LR_DEFAULTSIZE         64       // 0x0040
#define LR_VGACOLOR           128       // 0x0080
#define LR_LOADMAP3DCOLORS   4096       // 0x1000
#define LR_CREATEDIBSECTION  8192       // 0x2000
#define LR_COPYFROMRESOURCE 16384       // 0x4000
#define LR_SHARED           32768       // 0x8000

/* Stock Logical Objects */
#define WHITE_BRUSH         0
#define LTGRAY_BRUSH        1
#define GRAY_BRUSH          2
#define DKGRAY_BRUSH        3
#define BLACK_BRUSH         4
#define NULL_BRUSH          5
#define WHITE_PEN           6
#define BLACK_PEN           7
#define NULL_PEN            8
#define OEM_FIXED_FONT      10
#define ANSI_FIXED_FONT     11
#define ANSI_VAR_FONT       12
#define SYSTEM_FONT         13
#define DEVICE_DEFAULT_FONT 14
#define DEFAULT_PALETTE     15
#define SYSTEM_FIXED_FONT   16
#define DEFAULT_GUI_FONT    17

/* 3D border styles */
#define BDR_RAISEDOUTER     1           // 0x0001
#define BDR_SUNKENOUTER     2           // 0x0002
#define BDR_RAISEDINNER     4           // 0x0004
#define BDR_SUNKENINNER     8           // 0x0008

#define BDR_OUTER       (BDR_RAISEDOUTER + BDR_SUNKENOUTER)
#define BDR_INNER       (BDR_RAISEDINNER + BDR_SUNKENINNER)
#define BDR_RAISED      (BDR_RAISEDOUTER + BDR_RAISEDINNER)
#define BDR_SUNKEN      (BDR_SUNKENOUTER + BDR_SUNKENINNER)


#define EDGE_RAISED     (BDR_RAISEDOUTER + BDR_RAISEDINNER)
#define EDGE_SUNKEN     (BDR_SUNKENOUTER + BDR_SUNKENINNER)
#define EDGE_ETCHED     (BDR_SUNKENOUTER + BDR_RAISEDINNER)
#define EDGE_BUMP       (BDR_RAISEDOUTER + BDR_SUNKENINNER)

/* Border flags */
#define BF_LEFT             1           // 0x0001
#define BF_TOP              2           // 0x0002
#define BF_RIGHT            4           // 0x0004
#define BF_BOTTOM           8           // 0x0008

#define BF_TOPLEFT      (BF_TOP + BF_LEFT)
#define BF_TOPRIGHT     (BF_TOP + BF_RIGHT)
#define BF_BOTTOMLEFT   (BF_BOTTOM + BF_LEFT)
#define BF_BOTTOMRIGHT  (BF_BOTTOM + BF_RIGHT)
#define BF_RECT         (BF_LEFT + BF_TOP + BF_RIGHT + BF_BOTTOM)

#define BF_DIAGONAL        16           // 0x0010

// For diagonal lines, the BF_RECT flags specify the end point of the
// vector bounded by the rectangle parameter.
#define BF_DIAGONAL_ENDTOPRIGHT     (BF_DIAGONAL + BF_TOP + BF_RIGHT)
#define BF_DIAGONAL_ENDTOPLEFT      (BF_DIAGONAL + BF_TOP + BF_LEFT)
#define BF_DIAGONAL_ENDBOTTOMLEFT   (BF_DIAGONAL + BF_BOTTOM + BF_LEFT)
#define BF_DIAGONAL_ENDBOTTOMRIGHT  (BF_DIAGONAL + BF_BOTTOM + BF_RIGHT)


#define BF_MIDDLE        2048           // 0x0800  /* Fill in the middle */
#define BF_SOFT          4096           // 0x1000  /* For softer buttons */
#define BF_ADJUST        8192           // 0x2000  /* Calculate the space left over */
#define BF_FLAT         16384           // 0x4000  /* For flat rather than 3D borders */
#define BF_MONO         32768           // 0x8000  /* For monochrome borders */


#define FSHIFT    4   // 0x04
#define FCONTROL  8   // 0x08
#define FALT     16   // 0x10

#define VK_BACK           0x08
#define VK_TAB            0x09
#define VK_RETURN         0x0D
#define VK_SHIFT          0x10
#define VK_CONTROL        0x11
#define VK_MENU           0x12
#define VK_PAUSE          0x13
#define VK_CAPITAL        0x14
#define VK_ESCAPE         0x1B

#define VK_SPACE          0x20
#define VK_PRIOR          0x21
#define VK_NEXT           0x22
#define VK_END            0x23
#define VK_HOME           0x24
#define VK_LEFT           0x25
#define VK_UP             0x26
#define VK_RIGHT          0x27
#define VK_DOWN           0x28
#define VK_SELECT         0x29
#define VK_PRINT          0x2A
#define VK_EXECUTE        0x2B
#define VK_SNAPSHOT       0x2C
#define VK_INSERT         0x2D
#define VK_DELETE         0x2E
#define VK_HELP           0x2F

/*
 * VK_0 - VK_9 are the same as ASCII '0' - '9' (0x30 - 0x39)
 * 0x40 : unassigned
 * VK_A - VK_Z are the same as ASCII 'A' - 'Z' (0x41 - 0x5A)
 */

#define VK_LWIN           0x5B
#define VK_RWIN           0x5C
#define VK_APPS           0x5D

/*
 * 0x5E : reserved
 */

#define VK_SLEEP          0x5F

#define VK_NUMPAD0        0x60
#define VK_NUMPAD1        0x61
#define VK_NUMPAD2        0x62
#define VK_NUMPAD3        0x63
#define VK_NUMPAD4        0x64
#define VK_NUMPAD5        0x65
#define VK_NUMPAD6        0x66
#define VK_NUMPAD7        0x67
#define VK_NUMPAD8        0x68
#define VK_NUMPAD9        0x69
#define VK_MULTIPLY       0x6A
#define VK_ADD            0x6B
#define VK_SEPARATOR      0x6C
#define VK_SUBTRACT       0x6D
#define VK_DECIMAL        0x6E
#define VK_DIVIDE         0x6F
#define VK_F1             0x70
#define VK_F2             0x71
#define VK_F3             0x72
#define VK_F4             0x73
#define VK_F5             0x74
#define VK_F6             0x75
#define VK_F7             0x76
#define VK_F8             0x77
#define VK_F9             0x78
#define VK_F10            0x79
#define VK_F11            0x7A
#define VK_F12            0x7B
#define VK_F13            0x7C
#define VK_F14            0x7D
#define VK_F15            0x7E
#define VK_F16            0x7F
#define VK_F17            0x80
#define VK_F18            0x81
#define VK_F19            0x82
#define VK_F20            0x83
#define VK_F21            0x84
#define VK_F22            0x85
#define VK_F23            0x86
#define VK_F24            0x87

#define VK_NUMLOCK        0x90
#define VK_SCROLL         0x91

#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10

#define TVHT_NOWHERE            1       // 0x0001
#define TVHT_ONITEMICON         2       // 0x0002
#define TVHT_ONITEMLABEL        4       // 0x0004
#define TVHT_ONITEM             (TVHT_ONITEMICON + TVHT_ONITEMLABEL + TVHT_ONITEMSTATEICON)
#define TVHT_ONITEMINDENT       8       // 0x0008
#define TVHT_ONITEMBUTTON       16      // 0x0010
#define TVHT_ONITEMRIGHT        32      // 0x0020
#define TVHT_ONITEMSTATEICON    64      // 0x0040

#define TVHT_ABOVE              256     // 0x0100
#define TVHT_BELOW              512     // 0x0200
#define TVHT_TORIGHT            1024    // 0x0400
#define TVHT_TOLEFT             2048    // 0x0800

/* For video controls */
#define WIN_CHARPIX_H   16
#define WIN_CHARPIX_W    8
#define VID_CHARPIX_H   14
#define VID_CHARPIX_W    8
#define CS_VREDRAW                 1  // 0x0001
#define CS_HREDRAW                 2  // 0x0002

/* By Vitor McLung */
/*
 * Listbox Styles
 */
#define LBS_NOTIFY            0x0001
#define LBS_SORT              0x0002
#define LBS_NOREDRAW          0x0004
#define LBS_MULTIPLESEL       0x0008
#define LBS_OWNERDRAWFIXED    0x0010
#define LBS_OWNERDRAWVARIABLE 0x0020
#define LBS_HASSTRINGS        0x0040
#define LBS_USETABSTOPS       0x0080
#define LBS_NOINTEGRALHEIGHT  0x0100
#define LBS_MULTICOLUMN       0x0200
#define LBS_WANTKEYBOARDINPUT 0x0400
#define LBS_EXTENDEDSEL       0x0800
#define LBS_DISABLENOSCROLL   0x1000
#define LBS_NODATA            0x2000
#define LBS_NOSEL             0x4000
#define LBS_STANDARD          (LBS_NOTIFY+LBS_SORT+WS_VSCROLL+WS_BORDER)


/*
 * Listbox messages
 */
#define LB_ADDSTRING            0x0180
#define LB_INSERTSTRING         0x0181
#define LB_DELETESTRING         0x0182
#define LB_SELITEMRANGEEX       0x0183
#define LB_RESETCONTENT         0x0184
#define LB_SETSEL               0x0185
#define LB_SETCURSEL            0x0186
#define LB_GETSEL               0x0187
#define LB_GETCURSEL            0x0188
#define LB_GETTEXT              0x0189
#define LB_GETTEXTLEN           0x018A
#define LB_GETCOUNT             0x018B
#define LB_SELECTSTRING         0x018C
#define LB_DIR                  0x018D
#define LB_GETTOPINDEX          0x018E
#define LB_FINDSTRING           0x018F
#define LB_GETSELCOUNT          0x0190
#define LB_GETSELITEMS          0x0191
#define LB_SETTABSTOPS          0x0192
#define LB_GETHORIZONTALEXTENT  0x0193
#define LB_SETHORIZONTALEXTENT  0x0194
#define LB_SETCOLUMNWIDTH       0x0195
#define LB_ADDFILE              0x0196
#define LB_SETTOPINDEX          0x0197
#define LB_GETITEMRECT          0x0198
#define LB_GETITEMDATA          0x0199
#define LB_SETITEMDATA          0x019A
#define LB_SELITEMRANGE         0x019B
#define LB_SETANCHORINDEX       0x019C
#define LB_GETANCHORINDEX       0x019D
#define LB_SETCARETINDEX        0x019E
#define LB_GETCARETINDEX        0x019F
#define LB_SETITEMHEIGHT        0x01A0
#define LB_GETITEMHEIGHT        0x01A1
#define LB_FINDSTRINGEXACT      0x01A2
#define LB_SETLOCALE            0x01A5
#define LB_GETLOCALE            0x01A6
#define LB_SETCOUNT             0x01A7


#define DS_3DLOOK               4       // 0x4L
// #define BS_NOTIFY               16384   // 0x00004000L

// more messages

#define TB_LINEUP               0
#define TB_LINEDOWN             1
#define TB_PAGEUP               2
#define TB_PAGEDOWN             3
#define TB_THUMBPOSITION        4
#define TB_THUMBTRACK           5
#define TB_TOP                  6
#define TB_BOTTOM               7
#define TB_ENDTRACK             8

#define TBM_GETPOS              (WM_USER)
#define TBM_GETTIC              (WM_USER+3)
#define TBM_SETPOS              (WM_USER+5)
#define TBM_GETTICPOS           (WM_USER+15)
#define TBM_GETNUMTICS          (WM_USER+16)

#define CW_USEDEFAULT           2147483648          // 0x80000000
#define CCM_FIRST               0x2000      // Common control shared messages
#define CCM_LAST                (CCM_FIRST + 0x200)


#define CCM_SETBKCOLOR          (CCM_FIRST + 1) // lParam is bkColor
#define PBM_SETBARCOLOR         (WM_USER+9)             // lParam = bar color
#define PBM_SETBKCOLOR          CCM_SETBKCOLOR  // lParam = bkColor
#define DEFAULT_QUALITY         0
#define DRAFT_QUALITY           1
#define PROOF_QUALITY           2
#define WM_SETCURSOR                    0x0020

#define WM_REFLECT_BASE 0xBC00
#define WM_CTLCOLOR     0x0019
#define WM_CTLCOLOR_REFLECT  WM_CTLCOLOR+WM_REFLECT_BASE

#define MM_TEXT             1
#define MM_LOMETRIC         2
#define MM_HIMETRIC         3
#define MM_LOENGLISH        4
#define MM_HIENGLISH        5
#define MM_TWIPS            6
#define MM_ISOTROPIC        7
#define MM_ANISOTROPIC      8
#define AD_COUNTERCLOCKWISE 1
#define AD_CLOCKWISE        2
#define PS_COSMETIC         0x00000000
#define PS_GEOMETRIC        0x00010000
#define PS_TYPE_MASK        0x000F0000
#define R2_BLACK            1   /*  0       */
#define R2_NOTMERGEPEN      2   /* DPon     */
#define R2_MASKNOTPEN       3   /* DPna     */
#define R2_NOTCOPYPEN       4   /* PN       */
#define R2_MASKPENNOT       5   /* PDna     */
#define R2_NOT              6   /* Dn       */
#define R2_XORPEN           7   /* DPx      */
#define R2_NOTMASKPEN       8   /* DPan     */
#define R2_MASKPEN          9   /* DPa      */
#define R2_NOTXORPEN        10  /* DPxn     */
#define R2_NOP              11  /* D        */
#define R2_MERGENOTPEN      12  /* DPno     */
#define R2_COPYPEN          13  /* P        */
#define R2_MERGEPENNOT      14  /* PDno     */
#define R2_MERGEPEN         15  /* DPo      */
#define R2_WHITE            16  /*  1       */
#define R2_LAST             16


// States for tool Buttons
#define TBSTATE_CHECKED         0x01
#define TBSTATE_PRESSED         0x02
#define TBSTATE_ENABLED         0x04
#define TBSTATE_HIDDEN          0x08
#define TBSTATE_INDETERMINATE   0x10
#define TBSTATE_WRAP            0x20

// Styles for button
#define TBSTYLE_BUTTON          0x0000
#define TBSTYLE_SEP             0x0001
#define TBSTYLE_CHECK           0x0002
#define TBSTYLE_GROUP           0x0004
#define TBSTYLE_CHECKGROUP      0x0006
#define TBSTYLE_EX_MIXEDBUTTONS 0x00000008

#define BTNS_BUTTON     TBSTYLE_BUTTON      // 0x0000
#define BTNS_SEP        TBSTYLE_SEP         // 0x0001
#define BTNS_CHECK      TBSTYLE_CHECK       // 0x0002
#define BTNS_GROUP      TBSTYLE_GROUP       // 0x0004
#define BTNS_CHECKGROUP TBSTYLE_CHECKGROUP  // (TBSTYLE_GROUP | TBSTYLE_CHECK)
#define BTNS_WHOLEDROPDOWN      0x0080

#define TB_ENABLEBUTTON         (WM_USER + 1)
#define TB_HIDEBUTTON           (WM_USER + 4)
#define TB_SETBUTTONSIZE        (WM_USER + 31)
#define TB_SETSTATE             (WM_USER + 17)
#define TB_SETSTYLE             (WM_USER + 56)
#define TB_GETSTYLE             (WM_USER + 57)
#define TB_GETSTATE             (WM_USER + 18)
#define TB_SETBITMAPSIZE        (WM_USER + 32)
#define TB_SETINDENT            (WM_USER + 47)
#define TB_GETBUTTONSIZE        (WM_USER + 58)
#define TB_SETBUTTONWIDTH       (WM_USER + 59)

#define TTN_FIRST -520
#define TTN_LAST  -549
#define TTN_GETDISPINFOA        (TTN_FIRST - 0)
#define TTN_GETDISPINFOW        (TTN_FIRST - 10)
#define TTN_SHOW                (TTN_FIRST - 1)
#define TTN_POP                 (TTN_FIRST - 2)
#define TTN_GETDISPINFO         TTN_GETDISPINFOA
#define TB_SETTOOLTIPS          (WM_USER + 36)
#define TBSTYLE_DROPDOWN        0x0008
#define BTNS_DROPDOWN           TBSTYLE_DROPDOWN
#define TBSTYLE_EX_DRAWDDARROWS 0x00000001
#define TB_SETEXTENDEDSTYLE     (WM_USER + 84)  // For TBSTYLE_EX_*
#define TB_GETEXTENDEDSTYLE     (WM_USER + 85)  // For TBSTYLE_EX_*
#define TBN_FIRST               (-700)       // toolbar
#define TBN_LAST                (-720)

#define TBN_DROPDOWN            (TBN_FIRST - 10)
#define TBN_GETINFOTIPA         (TBN_FIRST - 18)
#define TBN_HOTITEMCHANGE       (TBN_FIRST - 13)
#define TBN_GETINFOTIP          TBN_GETINFOTIPA
#define NM_FIRST                0
#define NM_TOOLTIPSCREATED      (NM_FIRST-19)   // notify of when the tooltips window is create
#define NM_CUSTOMDRAW           (NM_FIRST-12)
#define ILC_MASK                0x0001
#define ILC_COLOR               0x0000
#define ILC_COLORDDB            0x00FE
#define ILC_COLOR4              0x0004
#define ILC_COLOR8              0x0008
#define ILC_COLOR16             0x0010
#define ILC_COLOR24             0x0018
#define ILC_COLOR32             0x0020
#define TB_SETIMAGELIST         (WM_USER + 48)
#define TB_GETIMAGELIST         (WM_USER + 49)
#define TB_LOADIMAGES           (WM_USER + 50)
#define TB_GETRECT              (WM_USER + 51) // wParam is the Cmd instead of index
#define TB_SETHOTIMAGELIST      (WM_USER + 52)
#define TB_GETHOTIMAGELIST      (WM_USER + 53)

// GETSYSTEMMETRICS constants
//--------------------------

#define SM_CXSCREEN 0
#define SM_CYSCREEN 1
#define SM_CXVSCROLL 2
#define SM_CYHSCROLL 3
#define SM_CYCAPTION 4
#define SM_CXBORDER 5
#define SM_CYBORDER 6
#define SM_CXDLGFRAME 7
#define SM_CXFIXEDFRAME 7
#define SM_CYDLGFRAME 8
#define SM_CYFIXEDFRAME 8
#define SM_CYVTHUMB 9
#define SM_CXHTHUMB 10
#define SM_CXICON 11
#define SM_CYICON 12
#define SM_CXCURSOR 13
#define SM_CYCURSOR 14
#define SM_CYMENU 15
#define SM_CXFULLSCREEN 16
#define SM_CYFULLSCREEN 17
#define SM_CYKANJIWINDOW 18
#define SM_MOUSEPRESENT 19
#define SM_CYVSCROLL 20
#define SM_CXHSCROLL 21
#define SM_DEBUG 22
#define SM_SWAPBUTTON 23
#define SM_RESERVED1 24
#define SM_RESERVED2 25
#define SM_RESERVED3 26
#define SM_RESERVED4 27
#define SM_CXMIN 28
#define SM_CYMIN 29
#define SM_CXSIZE 30
#define SM_CYSIZE 31
#define SM_CXSIZEFRAME 32
#define SM_CXFRAME 32
#define SM_CYSIZEFRAME 33
#define SM_CYFRAME 33
#define SM_CXMINTRACK 34
#define SM_CYMINTRACK 35
#define SM_CXDOUBLECLK 36
#define SM_CYDOUBLECLK 37
#define SM_CXICONSPACING 38
#define SM_CYICONSPACING 39
#define SM_MENUDROPALIGNMENT 40
#define SM_PENWINDOWS 41
#define SM_DBCSENABLED 42
#define SM_CMOUSEBUTTONS 43
#define SM_SECURE 44
#define SM_CXEDGE 45
#define SM_CYEDGE 46
#define SM_CXMINSPACING 47
#define SM_CYMINSPACING 48
#define SM_CXSMICON 49
#define SM_CYSMICON 50
#define SM_CYSMCAPTION 51
#define SM_CXSMSIZE 52
#define SM_CYSMSIZE 53
#define SM_CXMENUSIZE 54
#define SM_CYMENUSIZE 55
#define SM_ARRANGE 56
#define SM_CXMINIMIZED 57
#define SM_CYMINIMIZED 58
#define SM_CXMAXTRACK 59
#define SM_CYMAXTRACK 60
#define SM_CXMAXIMIZED 61
#define SM_CYMAXIMIZED 62
#define SM_NETWORK 63
#define SM_CLEANBOOT 67
#define SM_CXDRAG 68
#define SM_CYDRAG 69
#define SM_SHOWSOUNDS 70
#define SM_CXMENUCHECK 71
#define SM_CYMENUCHECK 72
#define SM_SLOWMACHINE 73
#define SM_MIDEASTENABLED 74
#define SM_MOUSEWHEELPRESENT 75
#define SM_XVIRTUALSCREEN 76
#define SM_YVIRTUALSCREEN 77
#define SM_CXVIRTUALSCREEN 78
#define SM_CYVIRTUALSCREEN 79
#define SM_CMONITORS 80
#define SM_SAMEDISPLAYFORMAT 81
#define SM_IMMENABLED 82
#define SM_CXFOCUSBORDER 83
#define SM_CYFOCUSBORDER 84
#define SM_TABLETPC 86
#define SM_MEDIACENTER 87
#define SM_STARTER 88
#define SM_SERVERR2 89




//--------------
// Font Weights
//--------------
#define FW_DONTCARE    0
#define FW_THIN        100
#define FW_EXTRALIGHT  200
#define FW_LIGHT       300
#define FW_NORMAL      400
#define FW_MEDIUM      500
#define FW_SEMIBOLD    600
#define FW_BOLD        700
#define FW_EXTRABOLD   800
#define FW_HEAVY       900
#define FW_ULTRALIGHT  FW_EXTRALIGHT
#define FW_REGULAR     FW_NORMAL
#define FW_DEMIBOLD    FW_SEMIBOLD
#define FW_ULTRABOLD   FW_EXTRABOLD
#define FW_BLACK       FW_HEAVY

#define PGN_FIRST               -900       // Pager Control
#define PGN_LAST                -950

#define PGN_CALCSIZE            (PGN_FIRST-2)
#define PGS_VERT                0x00000000
#define PGS_HORZ                0x00000001
#define PGS_AUTOSCROLL          0x00000002
#define PGS_DRAGNDROP           0x00000004
#define PGN_SCROLL              (PGN_FIRST-1)

#define PGF_SCROLLUP        1
#define PGF_SCROLLDOWN      2
#define PGF_SCROLLLEFT      4
#define PGF_SCROLLRIGHT     8


#define CCS_TOP                 0x00000001
#define CCS_NOMOVEY             0x00000002
#define CCS_BOTTOM              0x00000003
#define CCS_NORESIZE            0x00000004
#define CCS_NOPARENTALIGN       0x00000008
#define CCS_ADJUSTABLE          0x00000020
#define CCS_NODIVIDER           0x00000040

#define CCS_VERT                0x00000080
#define CCS_LEFT                (CCS_VERT + CCS_TOP)
#define CCS_RIGHT               (CCS_VERT + CCS_BOTTOM)
#define CCS_NOMOVEX             (CCS_VERT + CCS_NOMOVEY)

#define TBSTYLE_AUTOSIZE        0x0010  // obsolete; use BTNS_AUTOSIZE instead
#define TBSTYLE_NOPREFIX        0x0020  // obsolete; use BTNS_NOPREFIX instead

#define TBSTYLE_TOOLTIPS        0x0100
#define TBSTYLE_WRAPABLE        0x0200
#define TBSTYLE_ALTDRAG         0x0400

#define TBSTYLE_FLAT            0x0800
#define TBSTYLE_LIST            0x1000
#define TBSTYLE_CUSTOMERASE     0x2000
#define TBSTYLE_REGISTERDROP    0x4000
#define TBSTYLE_TRANSPARENT     0x8000
#define NM_CLICK                (NM_FIRST-2)    // uses NMCLICK struct
#define LVM_FIRST               0x1000      // ListView messages
#define LVM_DELETEITEM          (LVM_FIRST + 8)
#define LVM_DELETEALLITEMS      (LVM_FIRST + 9)
#define LVM_GETNEXTITEM         (LVM_FIRST + 12)
#define LVNI_ALL                0x0000
#define LVNI_FOCUSED            0x0001
#define LVNI_SELECTED           0x0002
#define LVNI_CUT                0x0004
#define LVNI_DROPHILITED        0x0008

#define LVNI_ABOVE              0x0100
#define LVNI_BELOW              0x0200
#define LVNI_TOLEFT             0x0400
#define LVNI_TORIGHT            0x0800

#define HWND_TOP                  0
#define HWND_BOTTOM               1
#define HWND_TOPMOST             -1
#define HWND_NOTOPMOST           -2

#define SWP_NOSIZE          0x0001
#define SWP_NOMOVE          0x0002
#define SWP_NOZORDER        0x0004
#define SWP_NOREDRAW        0x0008
#define SWP_NOACTIVATE      0x0010
#define SWP_FRAMECHANGED    0x0020  /* The frame changed: send WM_NCCALCSIZE */
#define SWP_SHOWWINDOW      0x0040
#define SWP_HIDEWINDOW      0x0080
#define SWP_NOCOPYBITS      0x0100
#define SWP_NOOWNERZORDER   0x0200  /* Don't do owner Z ordering */
#define SWP_NOSENDCHANGING  0x0400  /* Don't send WM_WINDOWPOSCHANGING */

#define SWP_DRAWFRAME       SWP_FRAMECHANGED
#define SWP_NOREPOSITION    SWP_NOOWNERZORDER

#define MCN_FIRST (-750)
#define MCN_SELCHANGE (MCN_FIRST + 1)
#define MCN_SELECT (MCN_FIRST + 4)
#define RBS_TOOLTIPS        0x0100
#define RBS_VARHEIGHT       0x0200
#define RBS_BANDBORDERS     0x0400
#define RBS_FIXEDORDER      0x0800
#define RBS_REGISTERDROP    0x1000
#define RBS_AUTOSIZE        0x2000
#define RBS_VERTICALGRIPPER 0x4000  // this always has the vertical gripper (default for horizontal mode)
#define RBS_DBLCLKTOGGLE    0x8000

#define RBBS_BREAK          0x00000001  // break to new line
#define RBBS_FIXEDSIZE      0x00000002  // band can't be sized
#define RBBS_CHILDEDGE      0x00000004  // edge around top & bottom of child window
#define RBBS_HIDDEN         0x00000008  // don't show
#define RBBS_NOVERT         0x00000010  // don't show when vertical
#define RBBS_FIXEDBMP       0x00000020  // bitmap doesn't move during band resize
#define RBBS_VARIABLEHEIGHT 0x00000040  // allow autosizing of this child vertically
#define RBBS_GRIPPERALWAYS  0x00000080  // always show the gripper
#define RBBS_NOGRIPPER      0x00000100  // never show the gripper
#define RBBS_USECHEVRON     0x00000200  // display drop-down button for this band if it's sized smaller than ideal width
#define RBBS_HIDETITLE      0x00000400  // keep band title hidden


#define ODS_SELECTED        0x0001
#define ODS_GRAYED          0x0002
#define ODS_DISABLED        0x0004
#define ODS_CHECKED         0x0008
#define ODS_FOCUS           0x0010
#define ODS_NOFOCUSRECT     0x0200
#define BM_CLICK            0x00F5
#define BM_GETIMAGE         0x00F6
#define BM_SETIMAGE         0x00F7
#define BM_GETCHECK         0x00F0
#define BM_SETCHECK         0x00F1
#define BM_GETSTATE         0x00F2
#define BM_SETSTATE         0x00F3
#define BM_SETSTYLE         0x00F4

#define BS_TEXT             0x00000000
#define BS_ICON             0x00000040
#define BS_BITMAP           0x00000080
#define BS_LEFT             0x00000100
#define BS_RIGHT            0x00000200
#define BS_CENTER           0x00000300
#define BS_TOP              0x00000400
#define BS_BOTTOM           0x00000800
#define BS_VCENTER          0x00000C00
#define BS_PUSHLIKE         0x00001000
#define BS_MULTILINE        0x00002000
#define BS_NOTIFY           0x00004000
#define BS_FLAT             0x00008000
#define BS_RIGHTBUTTON      BS_LEFTTEXT

#define BP_PUSHBUTTON 1
#define PBS_NORMAL    1
#define PBS_HOT       2
#define PBS_PRESSED   3
#define PBS_DISABLED  4
#define PBS_DEFAULTED 5
#DEFINE PBS_SMOOTH       1
#DEFINE PBS_VERTICAL     4
#DEFINE PBS_MARQUEE      8

#DEFINE PBM_SETRANGE     WM_USER+1
#DEFINE PBM_SETPOS       WM_USER+2
#define PBM_DELTAPOS     WM_USER+3
#DEFINE PBM_SETSTEP      WM_USER+4
#DEFINE PBM_SETRANGE32   WM_USER+6
#DEFINE PBM_SETMARQUEE   WM_USER+10

#define TMT_CONTENTMARGINS 3602


#define DFC_CAPTION             1
#define DFC_MENU                2
#define DFC_SCROLL              3
#define DFC_BUTTON              4

#define DFC_POPUPMENU           5


#define DFCS_CAPTIONCLOSE        0x0000
#define DFCS_CAPTIONMIN          0x0001
#define DFCS_CAPTIONMAX          0x0002
#define DFCS_CAPTIONRESTORE      0x0003
#define DFCS_CAPTIONHELP         0x0004

#define DFCS_MENUARROW           0x0000
#define DFCS_MENUCHECK           0x0001
#define DFCS_MENUBULLET          0x0002
#define DFCS_MENUARROWRIGHT      0x0004
#define DFCS_SCROLLUP            0x0000
#define DFCS_SCROLLDOWN          0x0001
#define DFCS_SCROLLLEFT          0x0002
#define DFCS_SCROLLRIGHT         0x0003
#define DFCS_SCROLLCOMBOBOX      0x0005
#define DFCS_SCROLLSIZEGRIP      0x0008
#define DFCS_SCROLLSIZEGRIPRIGHT 0x0010

#define DFCS_BUTTONCHECK         0x0000
#define DFCS_BUTTONRADIOIMAGE    0x0001
#define DFCS_BUTTONRADIOMASK     0x0002
#define DFCS_BUTTONRADIO         0x0004
#define DFCS_BUTTON3STATE        0x0008
#define DFCS_BUTTONPUSH          0x0010

#define DFCS_INACTIVE            0x0100
#define DFCS_PUSHED              0x0200
#define DFCS_CHECKED             0x0400


#define DFCS_TRANSPARENT         0x0800
#define DFCS_HOT                 0x1000


#define DFCS_ADJUSTRECT          0x2000
#define DFCS_FLAT                0x4000
#define DFCS_MONO                0x8000

// Defines for the new buttons
#define ST_ALIGN_HORIZ       0           // Icon/bitmap on the left, text on the right
#define ST_ALIGN_VERT        1           // Icon/bitmap on the top, text on the bottom
#define ST_ALIGN_HORIZ_RIGHT 2           // Icon/bitmap on the right, text on the left
#define ST_ALIGN_OVERLAP     3           // Icon/bitmap on the same space as text

#define WM_THEMECHANGED     0x031A 

#define TPM_LEFTALIGN       0x0000
#define TPM_CENTERALIGN     0x0004
#define TPM_RIGHTALIGN      0x0008
#define DS_CONTROL          0x0400

#define BUTTON_UNCHECKED       0x00
#define BUTTON_CHECKED         0x01
#define BUTTON_3STATE          0x02
#define BUTTON_HIGHLIGHTED     0x04
#define BUTTON_HASFOCUS        0x08
#define BUTTON_NSTATES         0x0F
#define BUTTON_BTNPRESSED      0x40
#define BUTTON_UNKNOWN2        0x20
#define BUTTON_UNKNOWN3        0x10


#define ODA_DRAWENTIRE  0x0001
#define ODA_SELECT      0x0002
#define ODA_FOCUS       0x0004

#define WM_NCMOUSEMOVE                  0x00A0
#define WM_NCLBUTTONDOWN                0x00A1
#define WM_NCLBUTTONUP                  0x00A2
#define WM_NCLBUTTONDBLCLK              0x00A3
#define WM_NCRBUTTONDOWN                0x00A4
#define WM_NCRBUTTONUP                  0x00A5
#define WM_NCRBUTTONDBLCLK              0x00A6
#define WM_NCMBUTTONDOWN                0x00A7
#define WM_NCMBUTTONUP                  0x00A8
#define WM_NCMBUTTONDBLCLK              0x00A9
#define WM_MOUSEHOVER                   0x02A1
#define WM_MOUSELEAVE                   0x02A3
#define WM_NCMOUSEHOVER                 0x02A0
#define WM_NCMOUSELEAVE                 0x02A2

#define LVM_COLUMNCLICK         (LVM_FIRST-8)
#define LVN_FIRST               -100       // listview

#define LVN_COLUMNCLICK         (LVN_FIRST-8)
#define HOLLOW_BRUSH            NULL_BRUSH
#define TTM_SETMAXTIPWIDTH      (WM_USER + 24)

#define _SRCCOPY                0x00CC0020 /* dest = source                   */
#define _SRCPAINT               0x00EE0086 /* dest = source OR dest           */


#define DLGC_WANTARROWS      0x0001      /* Control wants arrow keys         */
#define DLGC_WANTTAB         0x0002      /* Control wants tab keys           */
#define DLGC_WANTALLKEYS     0x0004      /* Control wants all keys           */
#define DLGC_WANTMESSAGE     0x0004      /* Pass message to control          */
#define DLGC_HASSETSEL       0x0008      /* Understands EM_SETSEL message    */
#define DLGC_DEFPUSHBUTTON   0x0010      /* Default pushbutton               */
#define DLGC_UNDEFPUSHBUTTON 0x0020      /* Non-default pushbutton           */
#define DLGC_RADIOBUTTON     0x0040      /* Radio button                     */
#define DLGC_WANTCHARS       0x0080      /* Want WM_CHAR messages            */
#define DLGC_STATIC          0x0100      /* Static item: don't include       */
#define DLGC_BUTTON          0x2000      /* Button item: can be checked      */

/*
Animation class defines
*/
#define ACS_CENTER              1
#define ACS_TRANSPARENT         2
#define ACS_AUTOPLAY            4

/*
Ancestor() const defines
*/
#define     GA_PARENT       1
#define     GA_ROOT         2
#define     GA_ROOTOWNER    3

/*
Brush fill Styles
*/
#DEFINE HS_HORIZONTAL    0
#DEFINE HS_VERTICAL      1
#DEFINE HS_BDIAGONAL     2
#DEFINE HS_FDIAGONAL     3
#DEFINE HS_CROSS         4
#DEFINE HS_DIAGCROSS     5
#DEFINE HS_SOLID         8
#DEFINE BS_TRANSPARENT  10

/*
Up-Down const defines
*/
#define UDS_WRAP                0x0001
#define UDS_SETBUDDYINT         0x0002
#define UDS_ALIGNRIGHT          0x0004
#define UDS_ALIGNLEFT           0x0008
#define UDS_AUTOBUDDY           0x0010
#define UDS_ARROWKEYS           0x0020
#define UDS_HORZ                0x0040
#define UDS_NOTHOUSANDS         0x0080
#define UDS_HOTTRACK            0x0100

/*
Check button
*/
#define BST_UNCHECKED      0x0000
#define BST_CHECKED        0x0001
#define BST_INDETERMINATE  0x0002
#define BST_PUSHED         0x0004
#define BST_FOCUS          0x0008

/*
ListBox
*/
#define LBN_SELCHANGE        1
#define LBN_DBLCLK           2
#define LBN_SELCANCEL        3
#define LBN_SETFOCUS         4
#define LBN_KILLFOCUS        5
#define LBN_CLICKCHECKMARK   6
#define LBN_CLICKED          7
#define LBN_ENTER            8
#define LBN_ERRSPACE       255

/*
ComboBox
*/
#define CBN_SELCHANGE       1
#define CBN_DBLCLK          2
#define CBN_SETFOCUS        3
#define CBN_KILLFOCUS       4
#define CBN_EDITCHANGE      5
#define CBN_EDITUPDATE      6
#define CBN_DROPDOWN        7
#define CBN_CLOSEUP         8
#define CBN_SELENDOK        9
#define CBN_SELENDCANCEL   10

// Month Calendar Control Styles
#define MCS_DAYSTATE             1
#define MCS_MULTISELECT          2
#define MCS_WEEKNUMBERS          4
#define MCS_NOTODAYCIRCLE        8
#define MCS_NOTODAY             16

#define DTN_DATETIMECHANGE -759
#define DTN_CLOSEUP -753
#define DTM_GETMONTHCAL 4104 // 0x1008
#define DTM_CLOSEMONTHCAL 4109
#define NM_KILLFOCUS -8
#define NM_SETFOCUS -7

#define LVS_REPORT              1
#define LVS_SINGLESEL           4
#define LVS_SHOWSELALWAYS       8
#define LVS_OWNERDATA        4096

#define LVN_ITEMCHANGED      - 101
#define LVN_KEYDOWN          - 155
#define LVN_GETDISPINFO      - 150
#define NM_DBLCLK              - 3 // TODO: (NM_FIRST-3)

#define NM_RETURN              - 4  // (NM_FIRST-4)

// from hstatus.prg
//#define NM_FIRST                 (0 - 0)
//#define NM_CLICK                (NM_FIRST-2)    // uses NMCLICK struct
//#define NM_DBLCLK               (NM_FIRST-3) // defined in windows.ch
#define NM_RCLICK               (NM_FIRST-5)    // uses NMCLICK struct
#define NM_RDBLCLK              (NM_FIRST-6)

// from htrackbr.prg
#define TBS_AUTOTICKS                1
#define TBS_VERT                     2
#define TBS_TOP                      4
#define TBS_LEFT                     4
#define TBS_BOTH                     8
#define TBS_NOTICKS                 16

// from htree.prg
#define TVM_DELETEITEM       4353   // (TV_FIRST + 1) 0x1101
#define TVM_EXPAND           4354   // (TV_FIRST + 2)
#define TVM_SETIMAGELIST     4361   // (TV_FIRST + 9)
#define TVM_GETNEXTITEM      4362   // (TV_FIRST + 10)
#define TVM_SELECTITEM       4363   // (TV_FIRST + 11)
#define TVM_EDITLABEL        4366   // (TV_FIRST + 14)
#define TVM_GETEDITCONTROL   4367   // (TV_FIRST + 15)
#define TVM_ENDEDITLABELNOW  4374   //(TV_FIRST + 22)
#define TVM_GETITEMSTATE     4391   // (TV_FIRST + 39)
#define TVM_SETITEM          4426   // (TV_FIRST + 63)
#define TVM_SETITEMHEIGHT    4379   // (TV_FIRST + 27)
#define TVM_GETITEMHEIGHT    4380
#define TVM_SETLINECOLOR     4392

#define TVE_COLLAPSE            0x0001
#define TVE_EXPAND              0x0002
#define TVE_TOGGLE              0x0003

#define TVSIL_NORMAL            0

#define TVGN_ROOT               0   // 0x0000
#define TVGN_NEXT               1   // 0x0001
#define TVGN_PREVIOUS           2   // 0x0002
#define TVGN_PARENT             3   // 0x0003
#define TVGN_CHILD              4   // 0x0004
#define TVGN_FIRSTVISIBLE       5   // 0x0005
#define TVGN_NEXTVISIBLE        6   // 0x0006
#define TVGN_PREVIOUSVISIBLE    7   // 0x0007
#define TVGN_DROPHILITE         8   // 0x0008
#define TVGN_CARET              9   // 0x0009
#define TVGN_LASTVISIBLE       10   // 0x000A

#define TVIS_STATEIMAGEMASK    61440

#define TVN_SELCHANGING      (-401) // (TVN_FIRST-1)
#define TVN_SELCHANGED       (-402)
#define TVN_GETDISPINFO      (-403)
#define TVN_SETDISPINFO      (-404)
#define TVN_ITEMEXPANDING    (-405)
#define TVN_ITEMEXPANDED     (-406)
#define TVN_BEGINDRAG        (-407)
#define TVN_BEGINRDRAG       (-408)
#define TVN_DELETEITEM       (-409)
#define TVN_BEGINLABELEDIT   (-410)
#define TVN_ENDLABELEDIT     (-411)
#define TVN_KEYDOWN          (-412)
#define TVN_ITEMCHANGINGA    (-416)
#define TVN_ITEMCHANGINGW    (-417)
#define TVN_ITEMCHANGEDA     (-418)
#define TVN_ITEMCHANGEDW     (-419)

#define TVN_SELCHANGEDW       (-451)
#define TVN_ITEMEXPANDINGW    (-454)
#define TVN_BEGINLABELEDITW   (-459)
#define TVN_ENDLABELEDITW     (-460)

#define TVI_ROOT              (-65536)

#define TREE_GETNOTIFY_HANDLE       1
#define TREE_GETNOTIFY_PARAM        2
#define TREE_GETNOTIFY_EDIT         3
#define TREE_GETNOTIFY_EDITPARAM    4
#define TREE_GETNOTIFY_ACTION       5
#define TREE_GETNOTIFY_OLDPARAM     6

#define TREE_SETITEM_TEXT           1
#define TREE_SETITEM_CHECK          2

//#define NM_CLICK                -2
//#define NM_DBLCLK               -3 // defined in windows.ch
//#define NM_RCLICK               -5 // defined in windows.ch
//#define NM_KILLFOCUS            -8 // defined in windows.ch
#define NM_SETCURSOR            -17    // uses NMMOUSE struct
#define NM_CHAR                 -18   // uses NMCHAR struct

// from hupdown.prg
#define UDN_FIRST               (-721)        // updown
#define UDN_DELTAPOS            (UDN_FIRST - 1)
#define UDM_SETBUDDY            (WM_USER + 105)
#define UDM_GETBUDDY            (WM_USER + 106)

#define WINAPI_TRANSPARENT 1

#define WM_SYSCOLORCHANGE 0x0015
#define WM_NOTIFYICON (WM_USER + 1000)

#endif // _WINDOWS_CH_
