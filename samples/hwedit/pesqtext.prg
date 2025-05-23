#include "hwgui.ch"
#include <fileio.ch>
#include <common.ch>

**************************
FUNCTION pesquisaglobal()
**************************

   LOCAL oDlgPesq
   LOCAL getpesq
   LOCAL ocomb
   LOCAL atu := 1
   LOCAL oIcon := HIcon():AddRESOURCE("SEARCHICON")
   LOCAL oDir := directory(DiskName() + ":\*.", "D", .T.) // pegando diretorio

   PRIVATE rd_pesq := ""
   PRIVATE diretorio := {}
   PRIVATE resultado := ""
   PRIVATE get01

   FOR f := 1 TO Len(oDir) // filtrando diretorios
       IF odir[f, 1] != "." .AND. odir[f, 1] != ".."
          AAdd(diretorio, DiskName() + ":\" + oDir[f, 1] + "\")
       ENDIF
   NEXT f

   asort(diretorio)
   FOR g := 1 TO Len(diretorio) // pegando diretorio atual
          IF Upper(diretorio[g]) = DiskName() + ":\" + Upper(CurDir() + "\")
             atu := g
          ENDIF
   NEXT g

 oComb := atu

 INIT DIALOG oDlgPesq TITLE "Pesquisa Gobal" ICON oIcon;
        AT 26, 136 SIZE 694, 456
   @ 20, 10 SAY "Texto a Procurar" SIZE 111, 15
   @ 20, 57 SAY "Pasta" SIZE 80, 14
   @ 20, 30 get getpesq var rd_pesq SIZE 343, 24
   @ 20, 74 GET COMBOBOX oComb ITEMS diretorio SIZE 340, 200
   @ 15, 111 get get01 var  resultado SIZE 657, 280 STYLE ES_MULTILINE + WS_HSCROLL + WS_VSCROLL
   //@ 364, 77 CHECKBOX "Incluir Sub-diretorios" SIZE 147, 22
   @ 605, 395 BUTTON "&O.K." SIZE 80, 32 ID IDOK ON CLICK {||pesq(diretorio[oComb], rd_pesq)}
   //readexit(.T.)
 ACTIVATE DIALOG oDlgPesq

RETURN NIL

*****************************
FUNCTION pesq(rd_dir, rd_text)
*****************************

   LOCAL arquivos := directory(rd_dir + "*.prg", "D", .T.) // pegando arquivos
   LOCAL nom_arq := {}
   LOCAL s_lEof := .F.

   PRIVATE arq_contem := {}
   PRIVATE result := ""

   FOR f := 1 TO Len(arquivos) // filtrando arquivos
       IF arquivos[f, 1] != "." .AND. arquivos[f, 1] != ".."
          AAdd(nom_arq, arquivos[f, 1])
       ENDIF
   NEXT f

   asort(nom_arq)
   resultado := ""
   get01:refresh()

   FOR g := 1 TO Len(nom_arq)
     arq := FT_FUSE(rd_dir + nom_arq[g])
     //
     resultado := resultado + nom_arq[g] + Chr(13) + Chr(10)
     get01:refresh()
     //
     lin := 0
     DO WHILE !FT_FEOF()
        linha := Upper(SubStr(FT_FReadLn(@s_lEof), 1))
        //
        texto := Upper(rd_text)
        //
        //hwg_MsgInfo(linha)
        IF at(texto, linha) != 0
            resultado := resultado + Str(lin, 6) + ":" + linha + Chr(13) + Chr(10)
            get01:refresh()
        ENDIF
        //
        lin++
        FT_FSKIP()
     ENDDO
   NEXT g

RETURN .T.
