/*
 * DBCHW - DBC ( Harbour + HWGUI )
 * Main file
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
#include <error.ch>
#ifdef RDD_ADS
   #include "ads.ch"
#endif

MEMVAR BrwFont,oBrwFont
MEMVAR msfile, msmode, msexp, lenmsf, improc, mypath
MEMVAR dformat, memownd, prrdonly
MEMVAR lWinChar
MEMVAR nServerType
MEMVAR msdriv, numdriv
MEMVAR nQueryWndHandle

Function Main()
Local aMainWindow, aPanel
Public BrwFont := {"MS Sans Serif", 0, -13}, oBrwFont := Nil
PUBLIC msfile[15], msmode[15, 5], msexp[15], lenmsf := 0, improc := 0, mypath := ""
PUBLIC dformat := "dd/mm/yy", memownd := .F., prrdonly := .F.
PUBLIC lWinChar := .F.
#ifdef RDD_ADS
   PUBLIC nServerType := ADS_LOCAL_SERVER
   PUBLIC msdriv := { "ADS_CDX", "ADS_NTX","ADS_ADT" }, numdriv := 1
#else
   PUBLIC nServerType := ""
   PUBLIC msdriv := "", numdriv := 1

#endif

PUBLIC nQueryWndHandle := 0

#ifdef RDD_ADS
   // REQUEST _ADS
   rddRegister("ADS", 1)
   rddSetdefault("ADS")
#else
   REQUEST DBFCDX
   rddsetdefault("DBFCDX")
   //rddRegister("DBFCDX", 1)
#endif

   SET EXCLUSIVE ON
   SET EPOCH TO 1960
   SET DATE FORMAT dformat

   hwg_Rdini( "dbc.ini" )
   mypath := "\" + CurDir() + IIF( Empty(CurDir()), "", "\" )

#ifdef RDD_ADS
   IF nServerType == ADS_REMOTE_SERVER
      IF !AdsConnect( mypath )
          nServerType := ADS_LOCAL_SERVER
          MsgInfo( "Can't establish connection" )
      ENDIF
   ENDIF
   AdsSetServerType( nServerType )
   AdsRightsCheck( .F. )
   SET CHARTYPE TO OEM
   AdsSetFileType( Iif( numdriv==1, 2,Iif( numdriv==2, 1, 3 ) ) )
#endif

   INIT WINDOW aMainWindow MDI TITLE "Dbc" MENU "APPMENU" MENUPOS 8
   MENU FROM RESOURCE OF aMainWindow        ;
       ON IDM_ABOUT   ACTION  About()       ;
       ON IDM_NEW     ACTION  StruMan(.T.)  ;
       ON IDM_OPEN    ACTION  OpenDlg()     ;
       ON IDM_CLOSE   ACTION  ChildClose()  ;
       ON IDM_FONT    ACTION  oBrwFont:=HFont():Select() ;
       ON IDM_CONFIG  ACTION  OpenConfig()  ;
       ON IDM_INDSEL  ACTION  ListIndex()   ;
       ON IDM_INDNEW  ACTION  NewIndex()    ;
       ON IDM_INDOPEN ACTION  OpenIndex()   ;
       ON IDM_INDCLOSE ACTION CloseIndex()  ;
       ON IDM_FIELMOD  ACTION StruMan(.F.)  ;
       ON IDM_LOCATE  ACTION  Move(1)       ;
       ON IDM_SEEK    ACTION  Move(2)       ;
       ON IDM_FILTER  ACTION  Move(3)       ;
       ON IDM_GOTO    ACTION  Move(4)       ;
       ON IDM_REPLACE ACTION  C_Repl()      ;
       ON IDM_DELETE  ACTION  C_Dele(1)     ;
       ON IDM_RECALL  ACTION  C_Dele(2)     ;
       ON IDM_COUNT   ACTION  C_Dele(3)     ;
       ON IDM_SUM     ACTION  C_Sum()       ;
       ON IDM_APPFROM ACTION  C_Append()    ;
       ON IDM_REINDEX ACTION  C_RPZ(1)      ;
       ON IDM_PACK    ACTION  C_RPZ(2)      ;
       ON IDM_ZAP     ACTION  C_RPZ(3)      ;
       ON IDM_SCRIPT  ACTION  Scripts(1)    ;
       ON IDM_QUENEW  ACTION  Query(.F.)    ;
       ON IDM_QUEOPEN ACTION  OpenQuery()   ;
       ON IDM_QUEEDIT ACTION  Query(.T.)    ;
       ON IDM_CALCUL  ACTION  Calcul()      ;
       ON IDM_DSCRIPT ACTION  Scripts(2)    ;
       ON IDM_EXIT    ACTION  hwg_EndWindow()   ;
       ON IDM_TILE    ACTION  hwg_SendMessage(HWindow():GetMain():handle,WM_MDITILE,MDITILE_HORIZONTAL, 0) ;
       ON IDM_CASCADE ACTION  hwg_SendMessage(HWindow():GetMain():handle,WM_MDICASCADE, 0, 0)

/*
    @ 0, 0 PANEL oPanel  SIZE 0, 28

    @ 2, 3 OWNERBUTTON OF oPanel ON CLICK {||OpenDlg()} ;
        SIZE 22, 22 FLAT ;
        BITMAP "BMP_OPEN" FROM RESOURCE COORDINATES 0, 4, 0, 0
*/

   IF HB_IsArray( BrwFont )
      oBrwFont := HFont():Add( BrwFont[1], BrwFont[2], BrwFont[3] )
   ENDIF

   hwg_EnableMenuItem( , 1, .F., .F. )
   hwg_EnableMenuItem( , 2, .F., .F. )
   hwg_EnableMenuItem( , 3, .F., .F. )
   hwg_EnableMenuItem( , 4, .F., .F. )

   aMainWindow:Activate()

Return Nil

Function ChildClose
Local nHandle := hwg_SendMessage( HWindow():GetMain():handle, WM_MDIGETACTIVE, 0, 0 )
   if nHandle > 0
      hwg_SendMessage( HWindow():GetMain():handle, WM_MDIDESTROY, nHandle, 0 )
   endif
Return Nil

Function About
Local oModDlg, oFont

   PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -13 ITALIC UNDERLINE

   INIT DIALOG oModDlg FROM RESOURCE "ABOUTDLG"

   REDEFINE BITMAP "BITMAP_1" FROM RESOURCE ID IDC_BMP1
   REDEFINE OWNERBUTTON ID IDC_OWNB1  ;
            ON CLICK {|| EndDialog()} ;
            FLAT TEXT "Close" COLOR hwg_VColor("0000FF") FONT oFont

   oModDlg:Activate()

Return Nil


/* -----------------------  Options --------------------- */

Static Function OpenConfig
Local aModDlg, aDates := { "dd/mm/yy","mm/dd/yy" }

   INIT DIALOG aModDlg FROM RESOURCE "DIALOG_1" ON INIT {|| InitConfig() }
   REDEFINE COMBOBOX aDates OF aModDlg ID IDC_COMBOBOX3
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndConfig()}   ;
        ON BN_CLICKED,IDC_RADIOBUTTON1 ACTION {|| ServerButton(0) } ;
        ON BN_CLICKED,IDC_RADIOBUTTON2 ACTION {|| ServerButton(1) }

   aModDlg:Activate()

Return Nil

Static Function InitConfig
#ifdef RDD_ADS
Local hDlg := hwg_GetModalHandle()
Local st := Iif( nServerType == ADS_REMOTE_SERVER,IDC_RADIOBUTTON2,IDC_RADIOBUTTON1 )
Local nd := Iif( numdriv==1,IDC_RADIOBUTTON3,Iif( numdriv==2,IDC_RADIOBUTTON4,IDC_RADIOBUTTON5 ) )
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON3,IDC_RADIOBUTTON5,nd )
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON1,IDC_RADIOBUTTON2,st )
   hwg_CheckDlgButton( hDlg,IDC_CHECKBOX4,SET( _SET_EXCLUSIVE ) )
   hwg_CheckDlgButton( hDlg,IDC_CHECKBOX5,prrdonly )
   hwg_CheckDlgButton( hDlg,IDC_CHECKBOX6,AdsLocking() )
   ServerButton( nServerType - 1 )
#else
   MsgInfo("No config in mode DBFCDX")
#endif
Return .T.

Static Function EndConfig()
Local hDlg := hwg_GetModalHandle()
Local new_numdriv, new_servertype, serverPath
   new_numdriv := Iif( hwg_IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON3 ), 1, ;
                  Iif( hwg_IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON4 ), 2, 3 ) )
   IF new_numdriv != numdriv
      numdriv := new_numdriv
      #ifdef RDD_ADS
         AdsSetFileType( Iif( numdriv==1, 2,Iif( numdriv==2, 1, 3 ) ) )
      #endif
   ENDIF
   IF SET( _SET_EXCLUSIVE ) != hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX4 )
      SET( _SET_EXCLUSIVE, !SET( _SET_EXCLUSIVE ) )
   ENDIF
   IF prrdonly != hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX5 )
      prrdonly := !prrdonly
   ENDIF
#ifdef RDD_ADS
   IF AdsLocking() != hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX6 )
      AdsLocking( !AdsLocking() )
   ENDIF
   dformat := GetDlgItemText( hDlg, IDC_COMBOBOX3, 12 )
   SET DATE FORMAT dformat
   new_servertype := Iif( hwg_IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON1 ), ;
                       ADS_LOCAL_SERVER, ADS_REMOTE_SERVER )
   IF new_servertype != nServerType
      nServerType := new_servertype
      AdsSetServerType( nServerType )
      IF nServerType == ADS_REMOTE_SERVER
         serverPath := GetDlgItemText( hDlg, IDC_EDIT1, 60 )
         IF Right(serverPath) != "/" .AND. Right(serverPath) != "\"
            serverPath += "\"
         ENDIF
         hwg_SetDlgItemText( hDlg, IDC_TEXT1, "Waiting for connection ..." )
         IF Empty(serverPath) .OR. !AdsConnect( serverPath )
             nServerType := 1
             AdsSetServerType( nServerType )
             hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON1,IDC_RADIOBUTTON2,IDC_RADIOBUTTON1 )
             ServerButton( 0 )
             hwg_SetDlgItemText( hDlg, IDC_TEXT1, "Cannot connect to "+serverPath )
             Return .F.
         ELSE
             mypath := serverPath
         ENDIF
      ENDIF
   ENDIF
#endif
   EndDialog( hDlg )
Return .T.

Static Function ServerButton( iEnable )
Local hEdit := GetDlgItem( hwg_GetModalHandle(),IDC_EDIT1 )
   hwg_SendMessage( hEdit, WM_ENABLE, iEnable, 0 )
Return .T.

/* -----------------------  Select Order --------------------- */

Static Function ListIndex
Local oModDlg, oBrw
Local msind := { { "0","None","","" } }, i, ordlen := 0
Local indname

   i := 1
   DO WHILE !Empty(indname := ORDNAME( i ))
      AADD( msind, { Str(i, 1), indname, ORDKEY( i ), ORDBAGNAME( i ) } )
      ordlen := Max( ordlen, Len(OrdKey( i-1 )) )
      i ++
   ENDDO
   INIT DIALOG oModDlg FROM RESOURCE "DLG_SEL_IND"
   REDEFINE BROWSE oBrw ARRAY OF oModDlg ID ID_BROWSE   ;
       ON INIT {|o|o:rowPos:=o:nCurrent:=IndexOrd()+1}       ;
       ON CLICK {|o|SetIndex(o)}

   oBrw:aArray := msind
   oBrw:AddColumn( HColumn():New( ,{|value,o|o:aArray[o:nCurrent, 1] },"C", 1, 0  ) )
   oBrw:AddColumn( HColumn():New( "Tag",{|value,o|o:aArray[o:nCurrent, 2] },"C", 8, 0  ) )
   oBrw:AddColumn( HColumn():New( "Expression",{|value,o|o:aArray[o:nCurrent, 3] },"C",ordlen, 0  ) )
   oBrw:AddColumn( HColumn():New( "File",{|value,o|o:aArray[o:nCurrent, 4] },"C", 8, 0  ) )
  
   oBrw:bColorSel    := hwg_VColor( "800080" )
   oBrw:ofont := oBrwFont

   oModDlg:Activate()
Return Nil

Static Function SetIndex( oBrw )
Local oWindow := HMainWindow():GetMdiActive(), aControls, i

   SET ORDER TO oBrw:nCurrent - 1
   hwg_WriteStatus( oWindow, 2,"Order: "+oBrw:aArray[oBrw:nCurrent, 2] )
   IF oWindow != Nil
      aControls := oWindow:aControls
      IF ( i := Ascan( aControls, {|o|o:classname()=="HBROWSE"} ) ) > 0
         hwg_RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
      ENDIF
   ENDIF
   EndDialog( hwg_GetModalHandle() )
Return Nil

/* -----------------------  Creating New Index --------------------- */

Function NewIndex
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DIALOG_2" ON INIT {|| InitNewIndex() }
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndNewIndex()}   ;
        ON 0,IDCANCEL     ACTION {|| EndDialog( hwg_GetModalHandle() ) }  ;
        ON BN_CLICKED,IDC_CHECKBOX1 ACTION {|| TagName() }
   aModDlg:Activate()

Return Nil

Static Function InitNewIndex
Local hDlg := hwg_GetModalHandle()
   hwg_SetDlgItemText( hDlg, IDC_EDIT2, hwg_CutExten( hwg_CutPath( msfile[improc] ) ) + INDEXEXT() )
   hwg_CheckDlgButton( hDlg,IDC_CHECKBOX1,.T. )
   hwg_SetFocus( GetDlgItem( hDlg, IDC_EDIT2 ) )
Return Nil

Static Function TagName
Local hDlg := hwg_GetModalHandle()
Local hEdit := GetDlgItem( hwg_GetModalHandle(),IDC_EDIT3 )
   IF hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX1 )
      hwg_SendMessage( hEdit, WM_ENABLE, 1, 0 )
   ELSE
      hwg_SendMessage( hEdit, WM_ENABLE, 0, 0 )
   ENDIF
Return Nil

Static Function EndNewIndex()
Local hDlg := hwg_GetModalHandle()
Local indname, isMulti, isUniq, tagname, expkey, expfor
Local oWindow, aControls, i

   indname := GetDlgItemText( hDlg, IDC_EDIT2, 20 )
   IF Empty(indname)
      hwg_SetFocus( GetDlgItem( hDlg, IDC_EDIT2 ) )
      Return Nil
   ENDIF
   isMulti := hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX1 )
   IF isMulti
      tagname := GetDlgItemText( hDlg, IDC_EDIT3, 60 )
      IF Empty(tagname)
         hwg_SetFocus( GetDlgItem( hDlg, IDC_EDIT3 ) )
         Return Nil
      ENDIF
   ENDIF
   isUniq := hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX2 )
   expkey := GetDlgItemText( hDlg, IDC_EDIT4, 60 )
   IF Empty(expkey)
      hwg_SetFocus( GetDlgItem( hDlg, IDC_EDIT4 ) )
      Return Nil
   ENDIF
   expfor := GetDlgItemText( hDlg, IDC_EDIT5, 60 )
   indname := mypath + indname
   hwg_SetDlgItemText( hDlg, IDC_TEXT2, "Indexing ..." )
   IF numdriv = 1 .AND. isMulti
      IF Empty(expfor)
         ORDCREATE( RTrim(indname), RTrim(tagname), RTrim(expkey), &( "{||" + RTrim(expkey) + "}" ), Iif( isUniq,.T.,Nil ) )
      ELSE
         ordCondSet( RTrim(expfor), &( "{||" + RTrim(expfor) + "}" ),,,,, RECNO(),,,, )
         ORDCREATE( RTrim(indname), RTrim(tagname), RTrim(expkey), &( "{||" + RTrim(expkey) + "}" ), Iif( isUniq,.T.,Nil ) )
      ENDIF
   ELSE
      IF Empty(expfor)
         dbCreateIndex( RTrim(indname), RTrim(expkey), &( "{||" + RTrim(expkey) + "}" ), Iif( isUniq,.T.,Nil ) )
      ELSE
         ordCondSet( RTrim(expfor), &( "{||" + RTrim(expfor) + "}" ),,,,, RECNO(),,,, )
         ORDCREATE( RTrim(indname),, RTrim(expkey), &( "{||" + RTrim(expkey) + "}" ), Iif( isUniq,.T.,Nil ) )
      ENDIF
   ENDIF
   oWindow := HMainWindow():GetMdiActive()
   hwg_WriteStatus( oWindow, 2,"Order: "+Iif( isMulti,tagname,hwg_CutPath(indname) ) )

   IF oWindow != Nil
      aControls := oWindow:aControls
      IF ( i := Ascan( aControls, {|o|o:classname()=="HBROWSE"} ) ) > 0
         hwg_RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
      ENDIF
   ENDIF

   EndDialog( hDlg )
Return Nil

/* -----------------------  Open Index file --------------------- */

Function OpenIndex()
Local mask := Iif( numdriv == 1,"*.cdx;*.idx",Iif( numdriv == 2,"*ntx","*.adi" ) )
Local fname
Local oWindow, aControls, i

   IF !Empty(fname := hwg_SelectFile( "Index files", mask, mypath ))
      mypath := "\" + CurDir() + IIF( Empty(CurDir()), "", "\" )
      ORDLISTADD( fname )
      oWindow := HMainWindow():GetMdiActive()
      IF oWindow != Nil
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:classname()=="HBROWSE"} ) ) > 0
            hwg_RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
         ENDIF
      ENDIF
   ENDIF
Return Nil

/* -----------------------  Close Index files --------------------- */

Function CloseIndex()
Local oldOrder := Indexord()
Local oWindow, aControls, i

   ORDLISTCLEAR()
   IF Indexord() != oldOrder
      oWindow := HMainWindow():GetMdiActive()
      IF oWindow != Nil
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:classname()=="HBROWSE"} ) ) > 0
            hwg_RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
         ENDIF
      ENDIF
   ENDIF
Return Nil

/* -----------------------  Open Database file --------------------- */

Function OpenDlg()
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_OPEN" ON INIT {|| InitOpen() }
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndOpen()}  ;
        ON BN_CLICKED,IDC_BUTTONBRW ACTION {||hwg_SetDlgItemText( hwg_GetModalHandle(), IDC_EDIT7, hwg_SelectFile( "xBase files( *.dbf )", "*.dbf", mypath ) ) }
   aModDlg:Activate()

Return Nil

Static Function InitOpen
Local hDlg := hwg_GetModalHandle()
Local nd := Iif( numdriv==1,IDC_RADIOBUTTON3,Iif( numdriv==2,IDC_RADIOBUTTON4,IDC_RADIOBUTTON5 ) )
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON3,IDC_RADIOBUTTON5,nd )
   hwg_CheckDlgButton( hDlg,IDC_CHECKBOX4,SET( _SET_EXCLUSIVE ) )
   hwg_CheckDlgButton( hDlg,IDC_CHECKBOX5,prrdonly )
#ifdef RDD_ADS
   hwg_CheckDlgButton( hDlg,IDC_CHECKBOX6,AdsLocking() )
#endif
   hwg_SetFocus( GetDlgItem( hDlg, IDC_EDIT7 ) )
Return .T.

Static Function EndOpen()
Local hDlg := hwg_GetModalHandle()
Local new_numdriv, old_numdriv := numdriv, alsName, fname, pass
Local oldExcl := SET( _SET_EXCLUSIVE ), oldRdonly := prrdonly
#ifdef RDD_ADS
Local oldLock := AdsLocking()
#endif

   fname := GetEditText( hDlg, IDC_EDIT7 )
   IF !Empty(fname)
      alsName := GetEditText( hDlg, IDC_EDIT3 )
      pass := GetEditText( hDlg, IDC_EDIT4 )
      new_numdriv := Iif( hwg_IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON3 ), 1, ;
                     Iif( hwg_IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON4 ), 2, 3 ) )
      IF new_numdriv != numdriv
         numdriv := new_numdriv
         #ifdef RDD_ADS
            AdsSetFileType( Iif( numdriv==1, 2,Iif( numdriv==2, 1, 3 ) ) )
         #endif
      ENDIF
      IF SET( _SET_EXCLUSIVE ) != hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX4 )
         SET( _SET_EXCLUSIVE, !SET( _SET_EXCLUSIVE ) )
      ENDIF
      IF prrdonly != hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX5 )
         prrdonly := !prrdonly
      ENDIF
#ifdef RDD_ADS
      IF AdsLocking() != hwg_IsDlgButtonChecked( hDlg,IDC_CHECKBOX6 )
         AdsLocking( !AdsLocking() )
      ENDIF
#endif
      mypath := "\" + CurDir() + IIF( Empty(CurDir()), "", "\" )
      OpenDbf( fname, Iif(Empty(alsName),Nil,alsName),,Iif(Empty(pass),Nil,pass) )
      IF numdriv != old_numdriv
         numdriv := old_numdriv
         #ifdef RDD_ADS
            AdsSetFileType( Iif( numdriv==1, 2,Iif( numdriv==2, 1, 3 ) ) )
         #endif
      ENDIF
      prrdonly := oldRdonly
#ifdef RDD_ADS
      AdsLocking( oldLock )
#endif
      EndDialog( hDlg )
   ELSE
      hwg_SetFocus( GetDlgItem( hDlg, IDC_EDIT7 ) )
   ENDIF
Return .T.

Function OpenDbf( fname, alsname, hChild, pass )
Local oWindow, aControls, oBrowse, i

   IF !FiOpen( fname, alsname,, pass )
      Return 0
   ENDIF

   IF Len(HWindow():aWindows) == 2
      hwg_EnableMenuItem( , 1, .T., .F. )
      hwg_EnableMenuItem( , 2, .T., .F. )
      hwg_EnableMenuItem( , 3, .T., .F. )
      hwg_EnableMenuItem( , 4, .T., .F. )
   ENDIF
   IF hChild == Nil .OR. hChild == 0
      INIT WINDOW oWindow MDICHILD TITLE fname ;
           AT 0, 0                              ;
           ON GETFOCUS {|o|ChildGetFocus(o)}   ;
           ON EXIT {|o|ChildKill(o)}

      ADD STATUS PARTS 180, 200, 0
      @ 0, 0 BROWSE oBrowse DATABASE  ;
           ON SIZE {|o,x,y|ResizeBrwQ(o,x,y)}

      oBrowse:bcolorSel  := hwg_VColor( "800080" )
      oBrowse:ofont := oBrwFont
      oBrowse:cargo := improc
      hwg_CreateList( oBrowse,.T. )
      oBrowse:lAppable := .T.

      oWindow:Activate()
   ELSE
      oWindow := HWindow():FindWindow( hChild )
      IF oWindow != Nil
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:classname()=="HBROWSE"} ) ) > 0
            oBrowse := aControls[i]
            oBrowse:InitBrw()
            oBrowse:bcolorSel  := hwg_VColor( "800080" )
            oBrowse:ofont := oBrwFont
            oBrowse:cargo := improc
            hwg_SendMessage( HWindow():GetMain():handle, WM_MDIACTIVATE, hChild, 0 )
            oBrowse:Refresh()
         ENDIF
      ENDIF
   ENDIF
   hwg_WriteStatus( oWindow, 1,Ltrim(Str(Reccount(), 10))+" records" )
   hwg_WriteStatus( oWindow, 2,"Order: None",.T. )
Return oWindow:handle

/* -----------------------  Calculator  --------------------- */

Function Calcul()
Local oModDlg

   INIT DIALOG oModDlg FROM RESOURCE "DLG_CALC" ON INIT {|| InitCalc() }
   DIALOG ACTIONS OF oModDlg ;
        ON 0,IDOK         ACTION {|| EndCalc()}
   oModDlg:Activate()

Return Nil

Static Function InitCalc()
Local hDlg := hwg_GetModalHandle()
   hwg_SetFocus( GetDlgItem( hDlg, IDC_EDITCALC ) )
Return Nil

Static Function EndCalc()
Local hDlg := hwg_GetModalHandle()
Local cExpr, res

   cExpr := GetDlgItemText( hDlg, IDC_EDITCALC, 80 )
   IF Empty(cExpr)
      hwg_SetFocus( GetDlgItem( hDlg, IDC_EDITCALC ) )
      Return Nil
   ENDIF
   IF TYPE( Trim(cExpr) ) $ "UEUI"
      hwg_MsgStop( "Wrong expression" )
   ELSE
      res := &( Trim(cExpr) )
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, TRANSFORM( res, "@B" ) )
   ENDIF

Return Nil


/* -----------------------  Scripts  --------------------- */

Function Scripts( nAct )
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_SCRI" ON INIT {||hwg_SetFocus(GetDlgItem(hwg_GetModalHandle(),IDC_EDIT8))}
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndScri(nAct)}   ;
        ON 0,IDCANCEL     ACTION {|| EndDialog( hwg_GetModalHandle() ) }  ;
        ON BN_CLICKED,IDC_PUSHBUTTON1 ACTION {||hwg_SetDlgItemText( hwg_GetModalHandle(), IDC_EDIT8, hwg_SelectFile( "Script files( *.scr )", "*.scr", mypath ) ) }
   aModDlg:Activate()

Return Nil

Static Function EndScri( lOk, nAct )
Local hDlg := hwg_GetModalHandle()
Local fname, arScr, nError, nLineEr, obl

   fname := GetDlgItemText( hDlg, IDC_EDIT8, 80 )
   IF Empty(fname)
      hwg_SetFocus( GetDlgItem( hDlg, IDC_EDIT8 ) )
      Return Nil
   ENDIF
   hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
   IF ( arScr := hwg_RdScript( fname ) ) != Nil
      IF nAct == 1
         obl := SELECT()
         GO TOP
         DO WHILE !EOF()
            hwg_DoScript( arScr )
            SELECT( obl )
            SKIP
         ENDDO
      ELSE
         hwg_DoScript( arScr )
      ENDIF
      MsgInfo( "Script executed" )
   ELSE
      nError := hwg_CompileErr( @nLineEr )
      hwg_MsgStop( "Script error ("+Ltrim(Str(nError))+"), line "+Ltrim(Str(nLineEr)) )
   ENDIF
   EndDialog( hDlg )

Return Nil

Function ChildGetFocus( oWindow )
Local i, aControls, oBrw
   IF oWindow != Nil
      aControls := oWindow:aControls
      IF ( i := Ascan( aControls, {|o|o:classname()=="HBROWSE"} ) ) > 0
         oBrw := aControls[i]
         IF HB_IsNumeric( oBrw:cargo )
            Select( oBrw:cargo )
            improc := oBrw:cargo
            hwg_SetFocus( oBrw:handle )
         ENDIF
      ENDIF
   ENDIF
Return Nil

Function ChildKill( oWindow )
Local i, aControls, oBrw
   IF oWindow != Nil
      aControls := oWindow:aControls
      IF ( i := Ascan( aControls, {|o|o:classname()=="HBROWSE"} ) ) > 0
         oBrw := aControls[i]
         IF HB_IsNumeric( oBrw:cargo )
            Select( oBrw:cargo )
            improc := oBrw:cargo
            IF Alias() == "ADSSQL"
               nQueryWndHandle := 0
            ENDIF
            FiClose()
            IF Len(HWindow():aWindows) == 3
               hwg_EnableMenuItem( , 1, .F., .F. )
               hwg_EnableMenuItem( , 2, .F., .F. )
               hwg_EnableMenuItem( , 3, .F., .F. )
               hwg_EnableMenuItem( , 4, .F., .F. )
            ENDIF
         ENDIF
      ENDIF
   ENDIF
Return Nil

Function ResizeBrwQ( oBrw, nWidth, nHeight )
Local hWndStatus, aControls := oBrw:oParent:aControls
Local aRect, i, nHbusy := 0

   FOR i := 1 TO Len(aControls)
      IF aControls[i]:classname() == "HSTATUS"
         hWndStatus := aControls[i]:handle
         aRect := hwg_GetClientRect( hWndStatus )
         nHbusy += aRect[4]
      ENDIF
   NEXT
   hwg_MoveWindow( oBrw:handle, 0, 0, nWidth, nHeight-nHBusy )
Return Nil

FUNCTION Fiopen( fname, alsname, prend, pass )

LOCAL i, oldimp := improc, res := .T.
LOCAL strerr := "Can't open file " + Iif( fname != Nil, fname, Alias() )
LOCAL bOldError, oError
   IF fname != Nil
      prend := IIF( prend = Nil, .F., prend )
      IF prend
         improc := lenmsf + 1
      ELSE
         FOR i := 1 TO 15
            IF msfile[i] = Nil
               improc := i
               EXIT
            ENDIF
         NEXT
      ENDIF
      IF improc > 15
         improc := oldimp
         hwg_MsgStop( "Too many opened files!" )
         RETURN .F.
      ENDIF
      SELECT( improc )
      alsname := IIF( alsname = Nil, hwg_CutExten( hwg_CutPath( fname ) ), Trim(hwg_CutExten( hwg_CutPath( alsname ) )) )
      IF ( i := AT( '~', alsname ) ) != 0
         alsname := Stufmy( alsname, i, 1, '_' )
      ENDIF
      bOldError := ERRORBLOCK( { | e | OpenError( e ) } )
      DO WHILE .T.
         BEGIN SEQUENCE
            DBUSEAREA(,, fname, alsname,, prrdonly )
         RECOVER USING oError
            IF oError:genCode == EG_BADALIAS .OR. oError:genCode == EG_DUPALIAS
               IF Empty(alsname := hwg_MsgGet( "","Bad alias name, input other:" ))
                  res := .F.
               ELSE
                  LOOP
               ENDIF
            ELSE
               Eval(bOldError, oError)
            ENDIF
         END SEQUENCE
         EXIT
      ENDDO
      ERRORBLOCK( bOldError )
      IF !res
         improc := oldimp
         RETURN .F.
      ENDIF
      IF NETERR()
         IF SET( _SET_EXCLUSIVE )
            SET( _SET_EXCLUSIVE, .F. )
            DBUSEAREA(,, fname, hwg_CutExten( IIF( alsname = Nil, fname, alsname ) ),, prrdonly )
            IF NETERR()
               hwg_MsgStop( strerr )
               improc := oldimp
               RETURN .F.
            ENDIF
         ELSE
            hwg_MsgStop( strerr )
            improc := oldimp
            RETURN .F.
         ENDIF
      ENDIF
   ENDIF
   IF improc > lenmsf
      lenmsf := improc
   ENDIF
#ifdef RDD_ADS
   IF pass != Nil
      AdsEnableEncryption( pass )
   ENDIF
#ENDIF
   msfile[improc] := Iif( fname != Nil, Upper(fname), Alias() )
   msmode[improc, 1] = SET( _SET_EXCLUSIVE )
   msmode[improc, 2] = prrdonly
   msmode[improc, 3] = numdriv
   msmode[improc, 4] = pass
   msmode[improc, 5] = alsname
RETURN .T.

STATIC FUNCTION OpenError( e )

   BREAK e
RETURN NIL

FUNCTION FiClose

LOCAL i
   IF improc > 0
      SELECT( improc )
      USE
      msfile[improc] = Nil
      IF improc = lenmsf
         FOR i := lenmsf - 1 TO 1 STEP - 1
            IF msfile[i] != Nil
               EXIT
            ENDIF
         NEXT
         lenmsf := i
      ENDIF
      improc := 0
/*
      FOR i := 1 TO lenmsf
         IF msfile[i] != Nil
            EXIT
         ENDIF
      NEXT
      improc := IIF( i <= lenmsf, i, 0 )
      prkorf := .T.
*/
   ENDIF
RETURN Nil

FUNCTION Stufmy( stsou, pozs, ellen, elzn )
RETURN SubStr(stsou, 1, pozs - 1) + elzn + SubStr(stsou, pozs + ellen)

FUNCTION FileLock()
LOCAL fname := msfile[improc]
   IF !msmode[improc, 1]
      USE &fname EXCLUSIVE
      IF NETERR()
         hwg_MsgStop( "File cannot be opened in exclusive mode" )
         USE &fname SHARED
         RETURN .F.
      ELSE
         msmode[improc, 1] = .T.
      ENDIF
   ENDIF
RETURN .T.

Function hwg_WndOut()
Return Nil

Function MsgSay( cText )
   hwg_MsgStop( cText )
Return Nil
