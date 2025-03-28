/*
 * DBCHW - DBC ( Harbour + HWGUI )
 * SQL queries
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
#ifdef RDD_ADS
#include "ads.ch"
#endif

memvar mypath, numdriv
Static cQuery := ""

Function OpenQuery
Local fname := hwg_SelectFile("Query files( *.que )", "*.que", mypath)

   IF !Empty(fname)
      mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
      cQuery := MemoRead(fname)
      Query( .T. )
   ENDIF

Return Nil

Function Query( lEdit )
Local aModDlg

   IF !lEdit
      cQuery := ""
   ENDIF

   INIT DIALOG aModDlg FROM RESOURCE "DLG_QUERY" ON INIT {|| InitQuery() }
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDCANCEL     ACTION {|| EndQuery(.F.) }  ;
        ON BN_CLICKED,IDC_BTNEXEC ACTION {|| EndQuery(.T.) } ;
        ON BN_CLICKED,IDC_BTNSAVE ACTION {|| QuerySave() }
   aModDlg:Activate()

Return Nil

Static Function InitQuery()
Local hDlg := hwg_GetModalHandle()
   hwg_SetDlgItemText( hDlg, IDC_EDITQUERY, cQuery )
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDITQUERY ) )
Return Nil

Static Function EndQuery( lOk )
Local hDlg := hwg_GetModalHandle()
Local oldArea := Alias(), tmpdriv, tmprdonly
Local id1
Local aChildWnd, hChild
Static lConnected := .F.

   IF lOk
      cQuery := hwg_GetEditText( hDlg, IDC_EDITQUERY )
      IF Empty(cQuery)
         hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDITQUERY ) )
         Return Nil
      ENDIF

      IF numdriv == 2
         hwg_MsgStop( "You shoud switch to ADS_CDX or ADS_ADT to run query" )
         Return .F.
      ENDIF
#ifdef RDD_ADS
      IF !lConnected
         IF Empty(mypath)
            AdsConnect( "\" + CurDir() + IIf(Empty(CurDir()), "", "\") )
         ELSE
            AdsConnect( mypath )
         ENDIF
         lConnected := .T.
      ENDIF
      IF Select( "ADSSQL" ) > 0
         Select ADSSQL
         USE
      ELSE
         SELECT 0
      ENDIF
      IF !AdsCreateSqlStatement( ,IIf(numdriv == 1, 2, 3) )
         hwg_MsgStop( "Cannot create SQL statement" )
         IF !Empty(oldArea)
            Select( oldArea )
         ENDIF
         Return .F.
      ENDIF
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      IF !AdsExecuteSqlDirect( cQuery )
         hwg_MsgStop( "SQL execution failed" )
         IF !Empty(oldArea)
            Select( oldArea )
         ENDIF
         Return .F.
      ELSE
         IF Alias() == "ADSSQL"
            improc := Select( "ADSSQL" )
            tmpdriv := numdriv; tmprdonly := prrdonly
            numdriv := 3; prrdonly := .T.
            // Fiopen()
            nQueryWndHandle := OpenDbf(, "ADSSQL", nQueryWndHandle)
            numdriv := tmpdriv; prrdonly := tmprdonly
            /*
            SET CHARTYPE TO ANSI
            __dbCopy( mypath+"_dbc_que.dbf",,,,,, .F. )
            SET CHARTYPE TO OEM
            FiClose()
            nQueryWndHandle := OpenDbf(mypath + "_dbc_que.dbf", "ADSSQL", nQueryWndHandle)
            */
         ELSE
            IF !Empty(oldArea)
               Select( oldArea )
            ENDIF
            hwg_MsgStop( "Statement doesn't returns cursor" )
            Return .F.
         ENDIF
      ENDIF
#endif
   ENDIF

   EndDialog( hDlg )
Return .T.

Function QuerySave
Local fname := hwg_SaveFile("*.que","Query files( *.que )", "*.que", mypath)
   cQuery := hwg_GetDlgItemText( hwg_GetModalHandle(), IDC_EDITQUERY, 400 )
   IF !Empty(fname)
      MemoWrit( fname,cQuery )
   ENDIF
Return Nil
