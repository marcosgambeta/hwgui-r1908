//
// Editor de Codigos Fontes                 xHarbour/HwGUI
//
// Editor.prg           Novembro de  2003
//
// Copyright (c) Rodnei Hernandes Lino <lhr@enetec.com.br>
// By HwGUI for Alexander Kresin
//

#define HB_OS_WIN_32_USED
#define _WIN32_WINNT 0x0400
#define _WIN32_IE    0x0400
#define OEMRESOURCE
#define ID_TEXTO  300

#include "hwgui.ch"
#include <fileio.ch>
#include <common.ch>

#define IDC_STATUS  2001
#define false .F.
#define true  .T.
//
//WM_USER=120
#define EM_SETBKGNDCOLOR 1091
#define FT_MATCHCASE = 4
#define FT_WHOLEWORD = 2
#define EM_FINDTEXT = 199
*****************
FUNCTION Main()
*****************

   LOCAL oPanel
   LOCAL oIcon := HIcon():AddRESOURCE("MAINICON")

   PUBLIC alterado := .F.
   PUBLIC ID_COLORB := 8454143
   PUBLIC ID_COLORF := 0
   PUBLIC ID_FONT := HFont():Add("Courier New", 0, -12)

   Set(_SET_INSERT)

   PRIVATE oMainWindow
   PRIVATE maxi := .F.
   PRIVATE oText
   PRIVATE tExto := ""
   PRIVATE vText
   PRIVATE aTermMetr := {800}
   PRIVATE auto := 5001
   PRIVATE oIconchild := HIcon():AddFile("prg.ico")
   PRIVATE form_panel
   PRIVATE cfontenome := "Courier New"
   PRIVATE texto := ""

   // variaveis para indiomas
   PUBLIC ID_indioma := 8001
   PUBLIC m_arquivo
   PUBLIC m_novo
   PUBLIC m_abrir
   PUBLIC m_salvar
   PUBLIC m_salvarcomo
   PUBLIC m_fechar
   PUBLIC m_sair
   PUBLIC m_config
   PUBLIC m_fonte
   PUBLIC m_color_b
   PUBLIC m_indioma
   PUBLIC reiniciar
   PUBLIC m_janela
   PUBLIC m_lado
   PUBLIC m_ajuda
   PUBLIC m_sobre
   PUBLIC desenvolvimento
   PUBLIC Bnovo
   PUBLIC babrir
   PUBLIC Bsalvar
   PUBLIC m_pesquisa
   PUBLIC m_linha
   PUBLIC m_site

// carregando as variaveis de configuracoes
IF !file("config.dat")
     save all like ID_* to config.dat
ENDIF
restore from config.dat additive
//// efetivando
IF ID_indioma = 8002
   m_arquivo := "File"
   m_novo := "New"
   m_abrir := "Open"
   m_salvar := "Save"
   m_salvarcomo := "Save as.."
   m_fechar := "Close"
   m_sair := "Exit"
   //
   m_config := "Config"
   m_fonte := "Font"
   m_colorb := "Color Background"
   m_colorf := "Color Font"
   m_indioma := "Language"
   //
   reiniciar := "It is necessary To restart " + Chr(13) + Chr(10) + "to be loaded the new configurations "
   //
   m_janela := "Windows"
   m_lado := "Title Vertical"
   //
   m_ajuda := "Help"
   m_sobre := "About"
   m_Site := "Internet"
   //
   desenvolvimento := "In development"
   //
   Bnovo := "New"
   babrir := "Open"
   Bsalvar := "Save"
   //
   m_pesquisa := "Search"
   m_localizar := "Find"
   m_Linha := "Goto Line"
   //
   m_editar := "Edit"
   m_seleciona := "Select all"
   m_pesq := "Find all files"

ELSEIF ID_indioma = 8001
   m_arquivo := "Arquivo"
   m_novo := "Novo"
   m_abrir := "Abrir"
   m_salvar := "Salvar"
   m_salvarcomo := "Salvar Como.."
   m_fechar := "Fechar"
   m_sair := "Sair"
   //
   m_config := "Configura��es"
   m_fonte := "Fonte"
   m_colorb := "Cor de Fundo"
   m_colorf := "Cor da Fonte"
   m_indioma := "Idioma"
   //
   reiniciar := "� necess�rio Reiniciar o Editor" + Chr(13) + Chr(10) + "Para ser carregado as novas configura��es"
   //
   m_janela := "Janelas"
   m_lado := "Lado a lado"
   //
   m_ajuda := "Ajuda"
   m_sobre := "Sobre"
   m_Site := "Pagina na Internet"
   //
   desenvolvimento := "Em desenvolvimento"
   //
   Bnovo := "Novo"
   babrir := "Abrir"
   Bsalvar := "Salvar"
   //
   m_pesquisa := "Localizar"
   m_localizar := "Procurar"
   m_Linha := "Linha"
   m_pesq := "Pesquisar em todos os arquivos"
   //
   m_editar := "Editar"
   m_seleciona := "Selecionar tudo"
 ENDIF

SET CENTURY on
PUBLIC funcoes := {}
///
 INIT WINDOW oMainWindow MDI;
        ICON oIcon;
        TITLE "HwEDIT for [x]Harbour/Hwgui" ;
        MENUPOS 4

   MENU OF oMainWindow

    ///
     MENU TITLE  "&" + m_arquivo
        MENUITEM "&" + m_novo + Chr(9) + "CTRL+N" ACTION novo();
                ACCELERATOR FCONTROL, Asc("N")
        MENUITEM "&" + m_abrir ACTION texto()
        MENUITEM "&" + m_salvar + Chr(9) + "CTRL+S" ACTION Salvar_Projeto(1);
              ACCELERATOR FCONTROL, Asc("S")
        SEPARATOR
        MENUITEM "&" + m_salvarcomo ACTION Salvar_Projeto(2)
        MENUITEM "&" + m_fechar ACTION Fecha_texto()
        SEPARATOR
        MENUITEM "&" + m_sair ACTION hwg_EndWindow()

     ENDMENU
     MENU TITLE "&" + m_editar
         MENUITEM "&" + m_seleciona + Chr(9) + "CTRL+A" ACTION {||seleciona()} //;               ACCELERATOR FCONTROL, Asc("A")
     ENDMENU


     MENU TITLE "&" + m_Pesquisa
         MENUITEM "&" + m_localizar + Chr(9) + "CTRL+F" ACTION {|o, m, wp, lp|Pesquisa(o, m, wp, lp)} ;
              ACCELERATOR FCONTROL, Asc("F")
         MENUITEM "&" + m_Linha + Chr(9) + "CTRL+J" ACTION {||vai()} ;
              ACCELERATOR FCONTROL, Asc("J")
         MENUITEM "&" + m_pesq + Chr(9) + "CTRL+G" ACTION {||pesquisaglobal()} ;
              ACCELERATOR FCONTROL, Asc("G")


     ENDMENU

     MENU TITLE "&" + m_config
         MENUITEM "&" + m_fonte ACTION ID_FONT := HFont():Select(ID_FONT);ID_FONT:Release();save all like ID_* to config.dat
         MENUITEM "&" + m_colorb ACTION cor_fundo()
         MENUITEM "&" + m_colorf ACTION cor_fonte()
         MENU TITLE "&" + m_indioma
             MENUITEM "&Portugues Brazil " ID 8001 ACTION indioma(8001)
             MENUITEM "&Ingles " ID 8002  ACTION indioma(8002)
         ENDMENU
     ENDMENU
     MENU TITLE "&" + m_janela
         MENUITEM "&" + m_lado  ;
            ACTION hwg_SendMessage(HWindow():GetMain():handle, WM_MDITILE, MDITILE_HORIZONTAL, 0)
      ENDMENU

     MENU TITLE "&" + m_ajuda
         MENUITEM "&" + m_sobre ACTION aguarde()
         MENUITEM "&" + m_site ACTION ajuda("www.lumainformatica.com.br")
     ENDMENU
   ENDMENU
   //
   painel(oMainWindow)
   SET TIMER tp1 OF oMainWindow ID 1001 VALUE 30 ACTION {||funcao()}
   //
   //ADD STATUS TO oMainWindow ID IDC_STATUS 50, 50, 400, 12, 90, 95, 90
   hwg_CheckMenuItem(, id_indioma, !hwg_IsCheckedMenuItem(, id_indioma))
 ACTIVATE WINDOW oMainWindow

RETURN NIL

****************
FUNCTION novo(tipo)
****************

   PRIVATE vText := ""

 alterado := .F.
 i := AllTrim(Str(auto))
 oFunc := {}

   PRIVATE vText&i := MemoRead(vText)
   PRIVATE oEdit&i

 //
 INIT  window o&i MDICHILD TITLE "Novo Arquivo-" + i //STYLE WS_VISIBLE + WS_MAXIMIZE
    painel2(o&I, oFunc)
    //
    //@ 650, 2 get COMBOBOX oCombo ITEMS oFunc SIZE 140, 20
    //
    @ 01, 31 richedit oEdit&i TEXT vText&i SIZE 799, 451;
       OF o&I ID ID_TEXTO BACKCOLOR ID_COLORB FONT ID_FONT ;
       STYLE WS_HSCROLL + WS_VSCROLL + ES_LEFT + ES_MULTILINE + ES_AUTOVSCROLL + ES_AUTOHSCROLL
    //
    //
    auto++
    oEdit&i:bOther := {|o, m, wp, lp|richeditProc(o, m, wp, lp)}
    oEdit&i:lChanged := .F.
    //
    ADD STATUS TO o&I ID IDC_STATUS PARTS 50, 50, 400, 12, 90, 95, 90
 o&I:ACTIVATE()
 hwg_WriteStatus(HMainWIndow():GetMdiActive(), 3, "Novo Arquivo")
 hwg_WriteStatus(HMainWIndow():GetMdiActive(), 1, "Lin:      0")
 hwg_WriteStatus(HMainWIndow():GetMdiActive(), 2, "Col:      0")
 hwg_SendMessage(oEdit&i:Handle, WM_ENABLE, 1, 0)
 hwg_SetFocus(oEdit&i:Handle)
 hwg_SendMessage(oEdit&i:Handle, EM_SETBKGNDCOLOR, 0, ID_COLORB)  // cor de fundo
 hwg_RE_SetDefault(oEdit&i:handle, ID_COLORF, ID_FONT,,) // cor e fonte padrao

RETURN .T.

*****************
FUNCTION Texto()
*****************

   LOCAL oIcone := HIcon():AddFile("CHILD.ico")
   LOCAL cBuffer := ""
   LOCAL NPOS := 0
   LOCAL nlenpos
   LOCAL oCombo

   m_a001 := {}
   vText := hwg_SelectFile("Arquivos Texto", "*.PRG", CurDir())
   oFunc := {}
   oLinha := {}
   IF Empty(vText)
      RETURN .T.
   ENDIF
   i := AllTrim(Str(auto))
   PRIVATE vText&i := MemoRead(vText)
   PRIVATE oEdit&i
   // pegado funcoes e procedures/////////////////////////////////////
   arq := FT_FUSE(vText)
   s_lEof := .F.
   rd_lin := 0
   oCaracter := 0
   r_linha := 0
   linhas := {}
   DO WHILE !ft_FEOF()
      linha := AllTrim(SubStr(FT_FReadLn(@s_lEof), 1))
      //
      IF Len(linha) != 0
        AAdd(linhas, Len(SubStr(FT_FReadLn(@s_lEof), 1)))
        //
        IF subs(Upper(linha), 1, 4) == "FUNC" .OR. subs(Upper(linha), 1, 4) == "PROC"
           fun := ""
           FOR f := 1 TO Len(linha) + 1
              oCaracter++
             IF subs(linha, f, 1) = " "
                FOR g := f + 1 TO Len(linha)
                       oCaracter++
                    IF subs(linha, g, 1) != " " .AND. subs(linha, g, 1) != "(" .AND. !Empty(subs(linha, g, 1))
                        fun := fun + subs(linha, g, 1)
                    ELSEIF g = Len(linha)
                       AAdd(oFunc, fun)
                       AAdd(funcoes, rd_lin)
                       AAdd(oLinha, {rd_lin, r_linha})
                       EXIT
                    ELSE
                       AAdd(oFunc, fun)
                       AAdd(oLinha, {rd_lin, r_linha})
                       AAdd(funcoes, rd_lin)
                       EXIT
                    ENDIF
                NEXT g
                EXIT
             ENDIF
           NEXT f
         ENDIF
      ENDIF
      rd_lin++
      FT_FSKIP()
   ENDDO

   alterado := .F.

 INIT  WINDOW o&i MDICHILD TITLE vText
      painel2(o&I, oFunc)
      //
      @ 01, 31 RichEdit oEdit&i TEXT vText&i SIZE 799, 451 ; // 481 ;
      OF o&I ID ID_TEXTO;
      STYLE WS_HSCROLL + WS_VSCROLL + ES_LEFT + ES_MULTILINE + ES_AUTOVSCROLL + ES_AUTOHSCROLL
      //
      oEdit&i:bOther := {|o, m, wp, lp|richeditProc(o, m, wp, lp)}
      //
      oEdit&i:lChanged := .F.
      //
      ADD STATUS TO o&I ID IDC_STATUS PARTS 50, 50, 400, 12, 90, 95, 90
      //
      hwg_SetFocus(hwg_GetDlgItem(oEdit&i, ID_TEXTO))
   auto++
 o&I:ACTIVATE()
 hwg_WriteStatus(o&I, 3, vText)
 hwg_WriteStatus(o&I, 1, "Lin:      0")
 hwg_WriteStatus(o&I, 2, "Col:      0")
 hwg_SendMessage(oEdit&i:Handle, WM_ENABLE, 1, 0)
 hwg_SetFocus(oEdit&i:Handle)
 // colocando cores nas funcoes
 hwg_RE_SetDefault(oEdit&i:handle, ID_COLORF, ID_FONT,,) // cor e fonte padrao
 /*
 FOR f := 1 TO Len(linhas)
    FOR g := 0 TO linhas[f]
             hwg_MsgInfo(hwg_RE_GetTextRange(oEdit&i, g, 1))
    NEXT f

   //hwg_RE_SetCharFormat(oEdit&i:handle, 6, olinha[f, 2], 255, , , .T.)
 NEXT f
 */
 hwg_SetFocus(oEdit&i:Handle)
 hwg_SendMessage(oEdit&i:Handle, EM_SETBKGNDCOLOR, 0, ID_COLORB)  // cor de fundo

RETURN NIL

*******************
FUNCTION funcao()
*******************

IF maxi
  //hwg_SendMessage(oMainWindow:handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0)
  oMainWindow:Maximize()
ENDIF
 IF HMainWIndow():GetMdiActive() != NIL
    dats := dtoc(date())
    hwg_WriteStatus(HMainWIndow():GetMdiActive(), 6, "Data: " + dats)
    hwg_WriteStatus(HMainWIndow():GetMdiActive(), 7, "Hora: " + time())
    IF !set(_SET_INSERT)
       strinsert := "INSERT ON "
    ELSE
        strinsert := "INSERT OFF "
    ENDIF
    hwg_WriteStatus(HMainWIndow():GetMdiActive(), 5, strinsert)

 ENDIF

***************************
FUNCTION painel(wmdi)
***************************
   @ 0, 0 PANEL oPanel of wmdi SIZE 150, 30

   //
   @ 2, 3 OWNERBUTTON OF oPanel       ;
       ON CLICK {||novo()} ;
       SIZE 24, 24 FLAT               ;
       BITMAP "BMP_NEW" FROM RESOURCE COORDINATES 0, 4, 0, 0 ;
       TOOLTIP bnovo
   //
   @ 26, 3 OWNERBUTTON OF oPanel       ;
       ON CLICK {||texto()} ;
       SIZE 24, 24 FLAT                ;
       BITMAP "BMP_OPEN" FROM RESOURCE COORDINATES 0, 4, 0, 0 ;
       TOOLTIP babrir
   //
   @ 50, 3 OWNERBUTTON OF oPanel       ;
       ON CLICK {||Salvar_Projeto(1)} ;
       SIZE 24, 24 FLAT                ;
       BITMAP "BMP_SAVE" FROM RESOURCE COORDINATES 0, 4, 0, 0 ;
       TOOLTIP bsalvar

RETURN NIL

*******************************
FUNCTION fecha_texto()
*******************************
   
   LOCAL h := HMainWIndow():GetMdiActive():handle

    IF alterado
        hwg_MsgYesNo("Deseja Salvar o arquivo")
    ENDIF
    hwg_SendMessage(h, WM_CLOSE, 0, 0)

RETURN .T.

*******************************
FUNCTION richeditProc(oEdit, msg, wParam, lParam)
*******************************

   LOCAL nVirtCode
   LOCAL strinsert := ""
   LOCAL oParent
   LOCAL nPos

 IF msg == WM_KEYDOWN
 ENDIF
 IF msg == WM_KEYUP
     nVirtCode := wParam
     IF wParam == 45
          Set(_SET_INSERT, !Set(_SET_INSERT))
     ENDIF
     IF !set(_SET_INSERT)
        strinsert := "INSERT ON "
     ELSE
        strinsert := "INSERT OFF "
     ENDIF
    // pega linha e coluna
     coluna := hwg_LOWORD(hwg_SendMessage(oEdit:Handle, EM_GETSEL, 0, 0))
     Linha := hwg_SendMessage(oEdit:Handle, EM_LINEFROMCHAR, coluna, 0)
     coluna := coluna - hwg_SendMessage(oEdit:Handle, EM_LINEINDEX, -1, 0)
     //
     hwg_WriteStatus(HMainWIndow():GetMdiActive(), 5, strinsert)
     hwg_WriteStatus(HMainWIndow():GetMdiActive(), 1, "Lin:" + Str(linha, 6))
     hwg_WriteStatus(HMainWIndow():GetMdiActive(), 2, "Col:" + Str(coluna, 6))
      //
     IF oEdit:lChanged
          hwg_WriteStatus(HMainWIndow():GetMdiActive(), 4, "*")
          alterado := .T.
     ELSE
         hwg_WriteStatus(HMainWIndow():GetMdiActive(), 4, " ")
     ENDIF
     //
     IF nvirtCode = 27
         IF oEdit:lChanged
           hwg_MsgYesNo("Deseja Salvar o arquivo")
         ENDIF
         h := HMainWIndow():GetMdiActive():handle
         hwg_SendMessage(h, WM_CLOSE, 0, 0)
     ENDIF
     //
     IF nvirtCode = 32 .OR. nvirtCode = 13 .OR. nvirtCode = 8
         hWnd := AScan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
         oWindow := HMainWIndow():GetMdiActive():aControls
         IF oWindow != NIL

            aControls := oWindow

            hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0) // focando janela
            hwg_SetFocus(aControls[hWnd]:Handle)
             //
             pos := hwg_SendMessage(oEdit:handle, EM_GETSEL, 0, 0)
             pos1 := hwg_LOWORD(pos)
             //
             //hwg_MsgInfo(Str(pos1))
             //hwg_MsgInfo(Str(Len(texto)))
             IF sintaxe(texto)

                hwg_RE_SetCharFormat(aControls[hWnd]:Handle, {{,,,,,,}, {(pos1-Len(texto)), Len(texto), 255,,, .T.}})
             ELSE
                hwg_RE_SetCharFormat(aControls[hWnd]:Handle, pos1, pos1, 0, , , .T.)
             ENDIF
            //
            hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0) // focando janela
            hwg_SetFocus(aControls[hWnd]:Handle)
         ENDIF
         texto := ""
     ELSE
        texto := texto + Chr(nvirtCode)
     ENDIF
ENDIF

RETURN -1

***********************
FUNCTION indioma(rd_ID)
***********************
FOR f := 8001 TO 8002
  IF hwg_IsCheckedMenuItem(, f)
    hwg_CheckMenuItem(, f, !hwg_IsCheckedMenuItem(, f))
  ENDIF
NEXT f
hwg_CheckMenuItem(, rd_ID, !hwg_IsCheckedMenuItem(, rd_ID))
 ID_indioma := rd_id
 save all like ID_* to config.dat
hwg_MsgInfo(reiniciar)

RETURN .T.

***********************
FUNCTION aguarde()
***********************
hwg_MsgInfo(desenvolvimento)

RETURN .T.

****************************
FUNCTION Pesquisa()

   LOCAL pesq
   LOCAL get01
   LOCAL flags := 1
   LOCAL hWnd
   LOCAL oWindow
   LOCAL aControls
   LOCAL i

 IF HMainWIndow():GetMdiActive() != NIL
     hWnd := AScan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
     oWindow := HMainWIndow():GetMdiActive():aControls
     //
     INIT DIALOG pesq clipper TITLE  "Pesquisar" ;
          AT 113, 214 SIZE 345, 103 STYLE DS_CENTER
     @ 80, 17 SAY "Insira o Texto a Pesquisar" SIZE 173, 30
     @ 13, 39 get get01 SIZE 319, 24
     readexit(.T.)
     ACTIVATE DIALOG pesq
     IF pesq:lResult
         IF oWindow != NIL
             aControls := oWindow
             hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
             hwg_SetFocus(aControls[hWnd]:Handle)
             //
             hwg_SendMessage(aControls[hWnd]:Handle, 176, 2, AllTrim(get01))
             //
             hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
             hwg_SetFocus(aControls[hWnd]:Handle)
         ENDIF
     ENDIF
 ENDIF

RETURN .T.

***************************
FUNCTION painel2(wmdi, array)
***************************

   LOCAL oCombo

   @ 0, 0 PANEL oPanel of wmdi SIZE 150, 30
   @ 650, 2 GET COMBOBOX oCombo ITEMS oFunc SIZE 140, 200 of oPanel ON CHANGE {||buscafunc(oCombo)}

RETURN NIL

***************************
FUNCTION Ajuda(rArq)
***************************

   LOCAL vpasta := CurDir()

   oIE := TOleAuto():GetActiveObject("InternetExplorer.Application")
   
   IF Ole2TxtError() != "S_OK"
         oIE := TOleAuto():New("InternetExplorer.Application")
   ENDIF
   
   IF Ole2TxtError() != "S_OK"
       hwg_MsgInfo("ERRO! IExplorer nao Localizado")
       RETURN
   ENDIF
   
   oIE:Visible := .T.

   oIE:Navigate(rArq)

RETURN NIL

****************************
FUNCTION Vai(oEdit)
****************************

   LOCAL pesq
   LOCAL get01
   LOCAL flags := 1
   LOCAL hWnd
   LOCAL oWindow
   LOCAL aControls
   LOCAL i

 IF HMainWIndow():GetMdiActive() != NIL
     hWnd := AScan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
     oWindow := HMainWIndow():GetMdiActive():aControls
     INIT DIALOG pesq clipper TITLE  "Linha" ;
          AT 113, 214 SIZE 345, 103 STYLE DS_CENTER
     @ 80, 17 SAY "Digite a linha " SIZE 173, 30
     @ 13, 39 get get01 SIZE 319, 24
     readexit(.T.)
     ACTIVATE DIALOG pesq
     IF pesq:lResult
         IF oWindow != NIL
             pos_y := val(get01)
             aControls := oWindow
             hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
             hwg_SetFocus(aControls[hWnd]:Handle)
             //
             hwg_SendMessage(aControls[hWnd]:Handle, EM_SCROLLCARET, 0, 0)
             hwg_Sendmessage(aControls[hWnd]:Handle, EM_LINESCROLL, 0, pos_y - 1)
             //
             hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
             hwg_SetFocus(aControls[hWnd]:Handle)
             //
         ENDIF
     ENDIF
 ENDIF

RETURN .T.

**********************
FUNCTION seleciona()
**********************

   LOCAL hWnd
   LOCAL oWindow
   LOCAL aControls
   LOCAL i

 hWnd := AScan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
 oWindow := HMainWIndow():GetMdiActive():aControls
 IF oWindow != NIL
    aControls := oWindow
    hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
    hwg_SetFocus(aControls[hWnd]:Handle)
    hwg_SendMessage(aControls[hWnd]:handle, EM_SETSEL, 0, 0)
    hwg_SendMessage(aControls[hWnd]:handle, EM_SETSEL, 100000, 0)
 ENDIF

RETURN .T.

*******************************
FUNCTION Salvar_Projeto(oOpcao)
*******************************

   LOCAL fName
   LOCAL fTexto
   LOCAL fSalve
   LOCAL hWnd
   LOCAL oWindow
   LOCAL aControls
   LOCAL i
   LOCAL cfile := "temp"

 IF HMainWIndow():GetMdiActive() != NIL
     hWnd := AScan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
     oWindow := HMainWIndow():GetMdiActive():aControls
     //

    nHandle := FCreate(cFile, FC_NORMAL)
    IF (nHandle > 0)
//      FWrite(nHandle, EditorGetText(oEdit))

        FClose(nHandle)

     IF oWindow != NIL
        aControls := oWindow
        IF Empty(vText) .OR. oOpcao=2
            fName := hwg_SaveFile("*.prg", "Arquivos de Programa (*.prg)", "*.prg", CurDir())
        ELSE
            fName := vText
        ENDIF

        fSalve := FCreate(fName) //Cria o arquivo
        FWrite(fSalve, aControls[hWnd]:vari)
        FClose(fSalve) //fecha o arquivo e grava
     ENDIF

   ENDIF
 ELSE
   hwg_MsgInfo("Nada para salvar")
 ENDIF

RETURN NIL

*********************
FUNCTION buscafunc(linha)
*********************

   LOCAL hWnd
   LOCAL oWindow
   LOCAL aControls
   LOCAL i

 IF HMainWIndow():GetMdiActive() != NIL
     hWnd := Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
     oWindow := HMainWIndow():GetMdiActive():aControls
     IF oWindow != NIL
         pos_y := funcoes[linha]
         aControls := oWindow
         hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
         hwg_SetFocus(aControls[hWnd]:Handle)
         //
         hwg_SendMessage(aControls[hWnd]:Handle, EM_SCROLLCARET, 0, 0)
         hwg_Sendmessage(aControls[hWnd]:Handle, EM_LINESCROLL, 0, pos_y - 1)
         //
         hwg_SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
         hwg_SetFocus(aControls[hWnd]:Handle)
         //
      ENDIF
  ENDIF

RETURN .T.

*************************
FUNCTION cor_fundo()
*************************

   LOCAL hWnd
   LOCAL oWindow
   LOCAL aControls
   LOCAL i

 IF HMainWIndow():GetMdiActive() != NIL
     hWnd := AScan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
     oWindow := HMainWIndow():GetMdiActive():aControls
     aControls := oWindow
     ID_COLORB := hwg_ChooseColor(ID_COLORB, .T.)
     hwg_SendMessage(aControls[hWnd]:Handle, EM_SETBKGNDCOLOR, 0, ID_COLORB)  // cor de fundo
     save all like ID_* to config.dat
 ELSE
   hwg_MsgInfo("Abra um documento Primeiro")
 ENDIF
 hwg_SetFocus(aControls[hWnd]:Handle)

RETURN .T.

*************************
FUNCTION cor_Fonte()
*************************

   LOCAL hWnd
   LOCAL oWindow
   LOCAL aControls
   LOCAL i

 IF HMainWIndow():GetMdiActive() != NIL
     hWnd := AScan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass == "RichEdit20A"})
     oWindow := HMainWIndow():GetMdiActive():aControls
     aControls := oWindow
     ID_COLORF := hwg_ChooseColor(ID_COLORF, .T.)
     hwg_RE_SetDefault(aControls[hWnd]:Handle, ID_COLORF, ID_FONT,,) // cor e fonte padrao
     save all like ID_* to config.dat
 ELSE
   hwg_MsgInfo("Abra um documento Primeiro")
 ENDIF
 hwg_SetFocus(aControls[hWnd]:Handle)

RETURN .T.

*************************
FUNCTION sintaxe(comando)
*************************

   LOCAL comand := Upper(AllTrim(comando))
   LOCAL ret := .T.

   //hwg_MsgInfo(comand)
   IF comand == "FOR"
      ret := .T.
   ELSEIF comand == "NEXT"
      ret := .T.
   ELSEIF comand == "IF"
      ret := .T.
   ELSEIF comand == "ENDIF"
      ret := .T.
   ELSEIF comand == "WHILE"
      ret := .T.
   ELSEIF comand == "ENDDO"
      ret := .T.
   ELSEIF comand == "ELSEIF"
      ret := .T.
   ELSE
      ret := .F.
   ENDIF

RETURN RET
