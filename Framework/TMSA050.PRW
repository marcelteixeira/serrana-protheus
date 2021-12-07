#INCLUDE "TMSA050.CH" 
#INCLUDE "PROTHEUS.CH"

#DEFINE DADOSCOT  1
#DEFINE PRODCOT   2
#DEFINE FRTINFCOT 6
#DEFINE FRTCMPCOT 7
#DEFINE FRTVALINF 3

#DEFINE CODPASCMP 1
#DEFINE VALPASCMP 2
#DEFINE TIPVALCMP 3
#DEFINE LOTEDICMP 4
#DEFINE TIPVEICOT 5
 
Static lTMA050PCO := ExistBlock("TMA050PCO")
Static lTMA050FIM := ExistBlock("TMA050FIM")
Static lTMA050EXC := ExistBlock("TMA050EXC")
Static lTMA050END := ExistBlock("TMA050END")
Static TM050Col   := ExistBlock('TM050COL')
Static lTM050DEV  := ExistBlock('TM050DEV')
Static lTMA050FOB := ExistBlock('TMA050FOB')
Static lTMA050Msg := ExistBlock('TMA050MSG')
Static lTMA050Grv := ExistBlock("TMA050Grv")
Static l050EnderOk
Static lPeTm050TOk:= ExistBlock('TM050TOK')
Static lTMA050COT := ExistBlock("TMA050COT")
Static lTM050VCT  := ExistBlock("TM050VCT")
Static lTM050PES  := ExistBlock('TM050PES')
Static lSrvDev    := NIL
Static lTMA050NFC := ExistBlock("TMA050NFC")
Static cCliDesEDI := ''
Static cLojDesEDI := ''
Static lTM050DE5  := ExistBlock ("TMS050DE5")
Static aCotFrete  := {}
Static lRateio    := .F.
Static cTABRAT    := ""
Static cTIPRAT    := ""
Static cBACRAT    := ""
Static cCRIRAT    := ""
Static cPRORAT    := ""
Static cORIRAT    := ""
Static cCALRAT    := ""
Static cTBARAT    := ""
Static cTPARAT    := ""
Static cNumSolDif := ""
Static cSerTmsDif := ""
Static aEndProd   := {}  // aCols de Enderecamento
Static aRatPesM3  := {}  // aCols Peso Cubado
Static cCRDVFA    := ""
Static cCRDVDC    := ""
Static lPainel    := .F.
Static lEdita     := .T.
Static lEditaServ := .T.
Static lSemCtr    := .F. //-- Indica Que Contrato Do DF1 Não é Mais Válido
Static cOrigem    := ""
Static lTM050DF1  := ExistBlock("TM050DF1") //permite manipular campos específicos do agendamento gerado
Static a050Whe
Static lTMA050Fil := ExistBlock("TMA050Fil")
Static lTMViaCol  := ExistBlock("TMVIACOL")
Static lTM050Sol  := ExistBlock('TM050SOL')
Static nVerSubCon := 0	//-- Verifica se é sub contratação DECRETO Nº 46.591 UF de MG (0=Definir / 1=Sim / 2=Não)
Static aSX3DTC     := {}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA050
Notas Fiscais do Cliente
@type function
@author Patricia A. Salomao
@version 12
@since 04/02/2002
@param [xAutoCab], Array, Cabecalho da Nota Fiscal (DTC)
@param [xAutoItens], Array, Itens da Nota Fiscal (DTC)
@param [xItensPesM3], Array, aCols de Peso Cubado (DTE)
@param [xItensEnder], Array, aCols de Enderecamento (DUH)
@param [nOpcAuto], Numérico, Opcao Rotina Automatica (Inclusão/Estorno)
@param [lTela], Lógico, Exibe a tela da operação da rotina (Inclusão/Alteração/Estorno)
@return Nil Não há retorno
@obs Uso SIGATMS - Gestão de Transporte
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA050(xAutoCab, xAutoItens, xItensPesM3, xItensEnder, nOpcAuto, lTela)
Local nX
Local cFilMbrPE := ""
Local cFiltro   := ""
Local aCores 	:= {}
Local aRet      := {}

Private lRETCDTC := .F.

If Type("aPanAgeTms") == "U"
	aPanAgeTms := Array(7)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTms)

//-- Verifica Se Existem Registros No Grid Do Painel De Agendamento
If lPainel //-- Painel Agendamento
	If (Type("aPanAgeTms[3]") <> "U" .And. aPanAgeTms[3] <> 3 ) //-- Diferente De "Incluir"
		If Type("aPanAgeTms[2]") <> "U" .And. Empty(aPanAgeTms[2]) //-- Verifica Se Tem RECNO Informado
			Return(Nil)
		EndIf
	EndIf
EndIf

If (DTC->(ColumnPos("DTC_CLIREC")) > 0 .And. DTC->(ColumnPos("DTC_LOJREC")) > 0 )
	lRETCDTC := .T.
Endif
//--Forca a criacao da tabela DTE que sera utilizada na
//Inclusao de Nota Fiscal do Cliente
DbSelectArea("DTE")

Private cCadastro   := STR0001 //"Doctos. do Cliente para Transporte"
Private cNumLotUso  := CriaVar('DTC_LOTNFC',.F.)
Private cNumSolic   := CriaVar('DTC_NUMSOL',.F.)
Private cCliRemUso  := CriaVar('DTC_CLIREM',.F.)
Private cLojRemUso  := CriaVar('DTC_LOJREM',.F.)
Private l050Auto    := .F.
Private aAutoCab    := {}  // Cabecalho da Nota Fiscal (Rotina Automatica)
Private aAutoItens  := {}  // Itens da NF (Rotina Automatica)
Private aRotina     := MenuDef()
Private lTmsCFec    := TmsCFec()
Private lNfcEDI     := .F.
Private lExb050Mnt  := .F.
Private lCotacao    := .F. //Verifica se a tela de cotação ja foi chamada.

Default xAutoCab    := {}
Default xAutoItens  := {}
Default xItensPesM3 := {}
Default xItensEnder := {}
Default nOpcAuto    := {}
Default lTela       := lPainel
If lTela .And. aPanAgeTms[3] == 3
	aRet := TMS050AFIL(aPanAgeTms[4],aPanAgeTms[5],aPanAgeTms[7])
	If !Empty(aRet) .And. Len(aRet) >= 3
		If !aRet[3]
			Return NIL
		ElseIf !Empty(aRet[1]) .And. !Empty(aRet[2])
			xAutoCab   := Aclone(aRet[1])
			xAutoItens := Aclone(aRet[2])
			nOpcAuto   := aPanAgeTms[3]
		EndIf
	EndIf
EndIf
l050Auto := xAutoCab <> Nil .And. xAutoItens <> Nil .And. !Empty(xAutoCab) .And. !Empty(xAutoItens)

lExb050Mnt  := lTela .And. l050Auto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICA A COMPATIBILIDADE DO FONTE TMSXFUNA x TMSA050³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !FindFunction("TMSXFUNA_V")
	Final( STR0083 ) //--"TMSA050 e TMSXFUNA incompatives. Atualize o fonte TMSXFUNA!"
ElseIf TMSXFUNA_V() < 20090605
	Final( STR0083 ) //--"TMSA050 e TMSXFUNA incompatives. Atualize o fonte TMSXFUNA!"
EndIf

aCores:= TMSA050Cor()

If lPainel   //Limpa as variaveis
	cTABRAT    := ""
	cTIPRAT    := ""
	cBACRAT    := ""
	cCRIRAT    := ""
	cPRORAT    := ""
	cORIRAT    := ""
	cCALRAT    := ""
	cTBARAT    := ""
	cTPARAT    := ""
	cCRDVFA    := ""
	cCRDVDC    := ""
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l050Auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para pre-validar os dados a serem  ³
	//³ exibidos.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("TM050BROW")
		ExecBlock("TM050BROW",.F.,.F.)
	EndIf
	dbSelectArea("DTC")
	dbSetOrder(1)

	If ExistBlock("TM050FBR") //-- PE - Permite ao usuario filtrar a mbrowse
		cFilMbrPE := ExecBlock("TM050FBR",.F.,.F.)
		If ValType(cFilMbrPE) == "C" .And. !Empty(cFilMbrPE)
			cFiltro += cFilMbrPE
		EndIf
	EndIf

	If !lPainel
		mBrowse(6,1,22,75,"DTC",,,,,,aCores,,,,,,,,cFiltro)
	Else
		If Type('aPanAgeTms[6]') <> "U" .And.  (at("(",aPanAgeTms[6])>0)
			&(aPanAgeTms[6])
		Else
			&(aPanAgeTms[6] + "('" + aPanAgeTms[1] + "'," + StrZero(aPanAgeTms[2],10) + "," + StrZero(aPanAgeTms[3],2) + ")")
		Endif
	EndIf
Else
	lMsHelpAuto := .T.

	aAutoCab := aClone(xAutoCab)
	For nX := 1 To Len(xAutoItens)
		AAdd(aAutoItens,DTC->(MSArrayXDB(xAutoItens[nX])))
	Next

	aRatPesM3   := xItensPesM3
	aEndProd    := xItensEnder
	If Type("n") == "U"
		n := 1
	EndIf

	//Verifica se a Estrutura do Array de Peso Cubado esta' correta
	If Len(aRatPesM3) > 0 .And. !TMA050VerArr(aRatPesM3)
		Return( .F. )
	EndIf

	//Verifica se a Estrutura do Array de Enderecamento esta' correta
	If Len(aEndProd) > 0 .And. !TMA050VerArr(aEndProd)
		Return( .F. )
	EndIf

	If lExb050Mnt .And. nOpcAuto == 3
		l050Auto := .F.
		INCLUI := .T.
		ALTERA := .F.
		lMsHelpAuto := .F.
		TMSA050Mnt("DTC",0,3)
	Else
		MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"DTC")
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Mnt  ³ Autor ³ Patricia A. Salomao ³ Data ³04.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao das Notas Fiscais do Cliente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Mnt( cAlias, nReg, nOpcx )

Local aSomaButtons  := {}
Local oEnchoice, nCntFor, cCampo, cCdrOri
Local nOpca         := 0
Local aAreaAnt      := GetArea("DTC")
Local aAreaDUL      := DUL->(GetArea("DUL"))
Local aObjects      := {}
Local aPosObj       := {}
Local aInfo         := {}
Local aSize         := {}
Local aButtons      := {}
Local aVisual       := {}
Local lLocaliz      := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
Local aAlter        := {}
Local aAltEnc
Local lRet          := .T.
Local lGetCpy       := .F.
Local lAlianca      := TMSAlianca() //-- Utiliza Alianca
Local oDlg
Local lGrava        := .F.
Local nCnt          := 0
Local cSerNfc       := CriaVar("DTC_SERNFC",.F.)
Local cCodPro       := CriaVar("DTC_CODPRO",.F.)
Local lTmA050Cpo    := ExistBlock('TMA050CPO') //-- Permite ao usuario, incluir campos na getdados
Local aCpos         := {}
Local cCpoRepAgd    := "DTC_TIPAGD/DTC_DATAGD/DTC_PRDAGD/DTC_INIAGD/DTC_FIMAGD/DTC_MOTAGD/DTC_USUAGD"
Local cCpoRep       := "" //String cujo conteudo sera retornado pelo ponto de entrada TM050REP, que contera os campos que serao repetidos na proxima linha da GetDados.
Local lTM050REP     := ExistBlock('TM050REP')
Local lTM050GRD     := ExistBlock('TM050GRD')
Local aYesFields    := {}
Local aNoFields     := {}
Local aNoEnch       := {}
Local nPosDTC       := 0
Local aAreaAnt1     := GetArea()
Local lTm050Cop     := ExistBlock('TM050COP')
Local aColsCop      := {}
Local aCopEndProd   := {}
Local aCopValInf    := {}
Local lTMSCTe       := SuperGetMv( "MV_TMSCTE", .F., .F. )
Local cServicOld    := ""
Local nSeek         := 0
Local aNFDigAnt     := {}
Local lLibLtSc      := SuperGetMv( "MV_LIBLTSC", , .F. )
Local lAgdEntr      := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local lCamposRat    := DTP->(ColumnPos("DTP_RATEIO")) > 0
Local lViaCol       := DTP->(ColumnPos("DTP_VIACOL")) > 0
Local lCmpRatNew    := DTP->(ColumnPos("DTP_CRDVFA")) > 0
Local lDTCRee 		:= DTC->(ColumnPos("DTC_DOCREE")) > 0
Local lTMS3GFE		:= Iif(FindFunction('TmsIntGFE'),TmsIntGFE('01') .Or. TmsIntGFE('02'),.F.)
Local nContDTC      := 0
Local cCadastro   	:= STR0001 //"Doctos. do Cliente para Transporte"
Local aAreaDTC		:= {}
Local lAptPend		:= IsInCallStack("A540RetMER")

Private lRedespInt  := .F.
Private aHeader     := {}
Private aCols       := {}
Private aHeaderDTE  := {}
Private aHeaderDUH  := {}
Private aNFDig      := {}
Private l050Inclui  := .F.
Private l050Altera  := .F.
Private l050Exclui  := .F.
Private l050Visual  := .F.
Private lAutomatic  := .F.
Private aItContrat  := {}
Private aTela[0][0],aGets[0]
Private o1Get
Private cRemetEDI  := ""
Private nOpcAnt    := 0
Private aHeaderDVU := {}  // aHeader de Tipos de Veiculo da Nota Fiscal
Private aColsDVU   := {}  // aCols de Tipos de Veiculo da Nota Fiscal
Private aSetKey    := {}
Private aValInf    := {}
Private lTmsVInf   := GetMv("MV_TMSVINF",,.F.)
Private lTmsGRem   := SuperGetMv('MV_TMSGREM',,.F.) //-- Indica se os campos DTC_CODREM e DTC_LOJREM serao mantidos em tela e validados automaticamente
Private cOcorCol   := "" //conteudo do parametro MV_OCORCOL quando do tipo "Encerra Processo" ou "Cancelamento".
Private lCopiar    := .F.
Private nQtdNfAnt  := 0
Private lPsqAgdEnt := .T. // Executa pesquisa para validar lançamento de agendamento de entrega no lançamento do documento.
Private cTipAgdEnt := '2' // Retorna o tipo de lançamento de agendamento de entrega no lançamento do documento (1=Sim, 2=Não, 3=Obrigatório).

SaveInter()

//+--------------------------------------------------------------------------------------
//| Inclusão de Redespacho Intermediario
//|          Quando Redespacho Intermediário nOPCX terá o conteúdo numérico 8, 
//|          nOPCX é alternado para o valor original 3-Inclusao e a variavel lRedespInt
//|          muda o seu valor de .F. para .T.
//+--------------------------------------------------------------------------------------
If nOpcx == 8
	nOpcx      := 3
	lRedespInt := .T.
EndIf
If nOpcx <> 3 //--Visualizar|Alterar|Excluir
    lRedespInt := (DTC->DTC_TIPNFC == '9')
EndIf

If Type( "lExb050Mnt" ) <> "L"
	Private lExb050Mnt  := .F.
EndIf
If Type( "lTmsCFec" ) <> "L" .Or. (Substr(FunName(),1,7) == "TMSA500" .And. nOpcx == 2) //No TMSA500, desabilita nas funcoes do tmsa200 o tratamento de carga fechada
	Private lTmsCFec:= TmsCFec()
EndIf

If nOpcx == 4
	If !A050EfeAlt()
		Return( .F. )
	EndIf
EndIf

If !lAptPend
	nOpcx    := aRotina[nOpcx][4]
Else

	//Força a posição do rotina para ser 3 e fazer a abertura da MSMGET do 050 como inclusão.
	aRotina[nOpcx][4] := nOpcx
	cCadastro:= STR0001
EndIf
nOpcAnt  := nOpcx
l050Auto := If (Type("l050Auto") == "U",.F.,l050Auto)

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If nOpcx <> 2 .And. nOpcx <> 3
	If !TMSAVerAge("2",,,,DTC->DTC_CLIREM,DTC->DTC_LOJREM,DTC->DTC_NUMNFC,DTC->DTC_SERNFC,DTC->DTC_CODPRO,,,,"2",.T.,.T.,,StrZero(ThreadId(),20))
		Return .F.
	EndIf
EndIf

If nOpcx <> 3
	cNumLotUso  := CriaVar('DTC_LOTNFC',.F.)
	cNumSolic   := CriaVar('DTC_NUMSOL',.F.)
	cCliRemUso  := CriaVar('DTC_CLIREM',.F.)
	cLojRemUso  := CriaVar('DTC_LOJREM',.F.)
	If ExistBlock('TM050INI')
		lRet := ExecBlock('TM050INI',.F.,.F.,{nOpcx})
		If ValType(lRet) == 'L' .And. !lRet
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return .F.
		EndIf
	EndIf
EndIf

If !l050Auto
	AAdd(aSetKey, { VK_F4 , { || A050PesoM3() } } )
	AAdd(aButtons	, {'BALANCA',{||A050PesoM3()}, STR0018 , STR0034 }) //"Peso cubado - <f4> "###"Peso Cub."

	If lLocaliz .And. ( nOpcx == 2 .Or. nOpcx == 5 )
		AAdd(aSetKey, { VK_F5 , { || A050EndTms() } } )
		AAdd(aButtons	, {'EMPILHADEIRA',{||A050EndTMS()}, STR0019 , STR0037}) //"Endereçamento - <f5> "###"Ender."
	EndIf

	If !IsInCallStack("TMSF76Via")// A adição de valor informado é por fora
		AAdd(aSetKey , { VK_F6    ,{|| A050ValInf(nOpcx,GdFieldGet('DTC_NUMNFC',n),GdFieldGet('DTC_SERNFC',n),GdFieldGet('DTC_CODPRO',n)) } } )
		AAdd(aButtons, {'COMPTITL',{|| A050ValInf(nOpcx,GdFieldGet('DTC_NUMNFC',n),GdFieldGet('DTC_SERNFC',n),GdFieldGet('DTC_CODPRO',n)) }, STR0038 , STR0039 }) //"Valor Informado - <F6>"###"Val.Inf."
	EndIf

	//-- Verifica se o Parametro MV_TMSCFEC (Carga Fechada) esta' habilitado
	If lTMSCFec
		AAdd(aSetKey , { VK_F7  , {|| A050TipVei(nOpcx,M->DTC_FILORI,M->DTC_NUMSOL,M->DTC_NUMCOT,GdFieldGet('DTC_NUMNFC',n),GdFieldGet('DTC_SERNFC',n),M->DTC_CLIREM,M->DTC_LOJREM, .T. ) } } )
		AAdd(aButtons, {'RPMNEW', {|| A050TipVei(nOpcx,M->DTC_FILORI,M->DTC_NUMSOL,M->DTC_NUMCOT,GdFieldGet('DTC_NUMNFC',n),GdFieldGet('DTC_SERNFC',n),M->DTC_CLIREM,M->DTC_LOJREM, .T. ) } , STR0040 , STR0041 }) //"Tipos de Veículo - <F7>"###"Tip.Vei."
	EndIf

	//-- Documento
	If nOpcx == 2
		AAdd(aSetKey , { VK_F8   ,{||TMSA050Doc(GdFieldGet('DTC_CODPRO',n),GdFieldGet('DTC_NUMNFC',n),GdFieldGet('DTC_SERNFC',n)) } }  )
		AAdd(aButtons, {'DEVOLNF',{||TMSA050Doc(GdFieldGet('DTC_CODPRO',n),GdFieldGet('DTC_NUMNFC',n),GdFieldGet('DTC_SERNFC',n))}, STR0035 , STR0036 }) //"Documento"###"Docum."
	EndIf

	//-- Apresenta as cotacoes aprovadas na inclusao
	If nOpcx == 3
		AAdd(aSetKey , { VK_F9   ,{|| TMSA050Cot(2) } }  )
		AAdd(aButtons, {'SDUPROP',{|| TMSA050Cot(2) }, STR0042 , STR0043 }) //"Cotacoes Realizadas - <F9>"###"Cot.Real."
	EndIf

	If lTmsVInf
		AAdd(aSetKey , { VK_F10  ,{|| A050FrtInf(nOpcx,Iif(nOpcx <> 2,.T.,.F.),STR0108) } }  )
		AAdd(aButtons, {'SDUPROP',{|| A050FrtInf(nOpcx,Iif(nOpcx <> 2,.T.,.F.),STR0108) }, STR0108, STR0111 }) //"Frete Informado - <F10>"###"Frete Inf."
	EndIf

   If ( (nOpcx == 3 .OR. nOpcx == 6) .Or. (Empty(DTC->DTC_FILDOC+DTC->DTC_DOC)) )   //Somente Notas nao calculados
  		AAdd(aSetKey , { VK_F11  , {|| A050FrtInf(nOpcx,.F.,STR0109) } }  )
  		AAdd(aButtons, {'SDUPROP', {|| A050FrtInf(nOpcx,.F.,STR0109) }, STR0109, STR0110  }) //"Visualiza Frete - <F11>"###"Vis.Frete"
	EndIf

	If lTMS3GFE
  		AAdd(aButtons, {'SDUPROP', {|| TmsViewGFE('DTC',,,GdFieldGet('DTC_NUMNFC',n),GdFieldGet('DTC_SERNFC',n),M->DTC_CLIREM,M->DTC_LOJREM,;
  											GdFieldGet('DTC_CODPRO',n), M->DTC_FILORI,M->DTC_LOTNFC ) }, STR0159, STR0159 }) //Docto de Carga (SIGAGFE)
	EndIf

	//-- Ponto de entrada para incluir botoes na enchoicebar
	If	ExistBlock('TM050BUT')
		aSomaButtons:=ExecBlock('TM050BUT',.F.,.F.,{nOpcx})
		If	ValType(aSomaButtons) == 'A'
			For nCntFor:=1 To Len(aSomaButtons)
				AAdd(aButtons,aSomaButtons[nCntFor])
			Next
		EndIf
	EndIf
EndIf

AAdd(aSetKey , { VK_F2  , {|| TMS050CEDI() } }  )
AAdd(aButtons, {'CODBR' , {|| TMS050CEDI() },STR0150,STR0150 }  )

cCdrOri   := GetMv("MV_CDRORI")
If Empty(cCdrOri)
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help("",1,"TMSA05009")  //-- O Parametro MV_CDRORI esta vazio
	Return( .F. )
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada:( Incl./Alt./Visual./Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 2 // Visualizar
	l050Visual := .T.
ElseIf nOpcx == 3  // Incluir
	l050Inclui := .T.
ElseIf nOpcx == 4  // Alterar
	l050Altera := .T.
ElseIf nOpcx == 5  // Excluir
	l050Exclui := .T.
	l050Visual := .T.
	aAltEnc    := {}
	AAdd(aAlter, "DTC_ESTORN")
EndIf


If l050Visual
	dbSelectArea("DTP")
	dbSetOrder(2)
	If DTP->(MsSeek(xFilial("DTP")+DTC->DTC_FILORI+DTC->DTC_LOTNFC))
		If lCamposRat
			lRateio:= Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
		EndIf
	EndIf
EndIf

If l050Exclui
	dbSelectArea("DTP")
	dbSetOrder(2)
	If DTP->(MsSeek(xFilial("DTP")+DTC->DTC_FILORI+DTC->DTC_LOTNFC))
		If lCamposRat
			lRateio:= Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
		EndIf
		If DTP->DTP_STATUS == '3'
			Help("",1,"TMSA05007") //O Lote utilizado nesta Nota Fiscal ja foi Calculado. A exclusao não sera efetuada.
			//-- Finaliza Teclas de Atalhos
			TmsKeyOff(aSetKey)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return ( .F. )
		ElseIf DTP->DTP_STATUS == '4' .And. !Empty(DTC->DTC_DOC)
			Help("",1,"TMSA05051") // Lote Bloqueado ... A Exclusao nao sera efetuada ...
			//-- Finaliza Teclas de Atalhos
			TmsKeyOff(aSetKey)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return ( .F. )
		EndIf
	EndIf
	If lViaCol .And. !Empty(DTP->DTP_VIACOL) .And. !IsInCallStack("TMSAF76")
		Help("",1,"TMSA050A8") // Não é permitido estornar um lote gerado pelo painel de agendamentos, por esta rotina.
		//-- Finaliza Teclas de Atalhos
		TmsKeyOff(aSetKey)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return ( .F. )
	EndIf
	If DTC->DTC_FILORI <> cFilAnt
		Help("",1,"TMSA05070",,STR0071 + DTC->DTC_FILORI + " / " + STR0072 + DTC->DTC_LOTNFC,4,0) //--"Nao e permitido estornar uma Nota Fiscal de outra Filial"###"Filial Origem: "###"Lote: "
		//-- Finaliza Teclas de Atalhos
		TmsKeyOff(aSetKey)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return ( .F. )
	EndIf

	If !Empty(DTC->DTC_DOC)
		Help("",1,"TMSA05093",,STR0117 + DTC->DTC_FILDOC + " / " + STR0035 + DTC->DTC_DOC + " / " + STR0118 + DTC->DTC_SERIE + " / " + STR0071 + DTC->DTC_FILORI + " / " + STR0072 + DTC->DTC_LOTNFC,4,0) //-- " Não é permitido estornar o lote com documento preenchido."
		//-- Finaliza Teclas de Atalhos
		TmsKeyOff(aSetKey)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return ( .F. )
	EndIf

EndIf

//--Campos que deverao
//--aparecer na GetDados
AAdd( aYesFields, "DTC_NUMNFC" )
AAdd( aYesFields, "DTC_SERNFC" )
AAdd( aYesFields, "DTC_CODPRO" )
AAdd( aYesFields, "DTC_DESPRO" )
AAdd( aYesFields, "DTC_CODEMB" )
AAdd( aYesFields, "DTC_DESEMB" )
AAdd( aYesFields, "DTC_QTDVOL" )
AAdd( aYesFields, "DTC_PESO"   )
AAdd( aYesFields, "DTC_PESOM3" )
AAdd( aYesFields, "DTC_VALOR"  )
AAdd( aYesFields, "DTC_EMINFC" )
AAdd( aYesFields, "DTC_BASSEG" )
AAdd( aYesFields, "DTC_QTDUNI" )
AAdd( aYesFields, "DTC_METRO3" )
AAdd( aYesFields, "DTC_EDI"    )
AAdd( aYesFields, "DTC_CF"     )
AAdd( aYesFields, "DTC_PRVENT" )

If DTC->(ColumnPos("DTR_PRHENT"))
	AAdd( aYesFields, "DTC_PRHENT" )
EndIf

//--Documentos de Redespacho
AAdd( aYesFields, "DTC_FILDPC" )
AAdd( aYesFields, "DTC_CTRDPC" )
AAdd( aYesFields, "DTC_TIPANT" )
AAdd( aYesFields, "DTC_DPCEMI" )
AAdd( aYesFields, "DTC_CTEANT" )
AAdd( aYesFields, "DTC_SERDPC" )
AAdd( aYesFields, "DTC_VALDPC" )
AAdd( aYesFields, "DTC_FRTSUB" )
AAdd( aYesFields, "DTC_PESLIQ" )

//-- Nota fiscal eletronica
AAdd(aYesFields,"DTC_NFEID")
AAdd(aYesFields,"DTC_NFELET")
AAdd(aYesFields,"DTC_EMINFE")
AAdd(aYesFields,"DTC_CODNFE")
AAdd(aYesFields,"DTC_BASICM")

//-- Inicio dos campos do Cte

//-- Valor do ICMS da NF do Cliente
AAdd(aYesFields,"DTC_VALICM")

//-- Base da substituicao tributaria, NF do cliente
AAdd(aYesFields,"DTC_BASESU")

//-- Valor da substituicao tributaria, Nf do cliente
AAdd(aYesFields,"DTC_VALIST")

// Status da Nota ( Entregue / Nao Entregue / Bloqueada)
AAdd(aYesFields,"DTC_NFENTR")
AAdd(aYesFields,"DTC_FILOCO")
AAdd(aYesFields,"DTC_NUMOCO")

If lDTCRee
	AAdd(aYesFields,"DTC_DOCREE")
EndIf

//-- Campos para agendamento de entrega
If lAgdEntr .And. DTC->(ColumnPos("DTC_NUMAGD")) > 0
	AAdd(aYesFields,"DTC_DATAGD")
	AAdd(aYesFields,"DTC_INIAGD")
	AAdd(aYesFields,"DTC_FIMAGD")
	AAdd(aYesFields,"DTC_TIPAGD")
	AAdd(aYesFields,"DTC_PRDAGD")
	AAdd(aYesFields,"DTC_MOTAGD")
	AAdd(aYesFields,"DTC_USUAGD")
	AAdd(aYesFields,"DTC_NUMAGD")
	AAdd(aYesFields,"DTC_ITEAGD")
EndIf

AAdd(aYesFields,"DTC_IDREM")
//-- Ponto de Entrada que permite a inclusao de campos na GetDados
If lTmA050Cpo
	aCpos := ExecBlock("TMA050CPO",.F.,.F. )
	For nCntFor := 1 To Len( aCpos )
		AAdd(aYesFields,aCpos[nCntFor])
	Next nCntFor
EndIf

//Campos que nao devem aparecer na Enchoice,
//irao aparecer na GetDados
aNoEnch := aClone(aYesFields)
AAdd( aNoEnch, "DTC_ESTORN" )
AAdd( aNoEnch, "DTC_ENDTMS" )
//Campos que nao devem aparecer na GetDados
AAdd( aNoFields, "DTC_FILDOC" )
AAdd( aNoFields, "DTC_DOC"    )
AAdd( aNoFields, "DTC_SERIE"  )
AAdd( aNoFields, "DTC_DOCPER" )

//-- Carga Fechada
If !lTmsCFec
	AAdd( aNoFields, "DTC_DATCOL" )
	AAdd( aNoFields, "DTC_HORCOL" )
	AAdd( aNoFields, "DTC_DTENTR" )
	AAdd( aNoFields, "DTC_HORENT" )
	AAdd( aNoFields, "DTC_RECEBE" )
ElseIf Type("lVgeExpr") <> "U" .And. lVgeExpr
	//-- Somente sera permitido informar a data e hora entrega se inclusao fora do TMS Express
	AAdd( aNoFields, "DTC_DTENTR" )
	AAdd( aNoFields, "DTC_HORENT" )
EndIf

If !lTmsVInf
	AAdd(aNoFields,"DTC_VLRINF")
EndIf

If nOpcx == 3
	aAreaDTC := DTC->(GetArea())
	If !Empty(DTC->DTC_DOC)
		DTC->(dbGoTop())
	EndIf
EndIf

TMSA050DTC(aNoEnch, aNoFields)
For nContDTC := 1 to Len(aSx3DTC)
	//-- Nao apresentam os campos utilizados pela Alianca
	If lAlianca .Or. (!lAlianca .And. !(aSx3DTC[nContDTC, 1] $ "DTC_FILDPC,DTC_ALIANC,DTC_DESALI,DTC_DPCLOC"))
		cCampo := aSx3DTC[nContDTC, 1]
		If	( aSx3DTC[nContDTC, 2] == "V"  .Or. Inclui )
			M->&(cCampo) := CriaVar(aSx3DTC[nContDTC, 1])
			If lExb050Mnt
				If (npos:=aScan(aAutoCab, {|x| PadR(x[1],10) == cCampo})) > 0
					M->&(cCampo) := aAutoCab[npos][2]
				EndIf
			EndIf
		Else
			M->&(cCampo) := DTC->(FieldGet(FieldPos(aSx3DTC[nContDTC, 1])))
		EndIf
		//-- Quando Redespacho Intermediário os campos abaixo não serão exibidos em tela, mas as variáveis de memoria permanecem
		If lRedespInt == .T.
			If valtype(aAltEnc) == "U"
				aAltEnc := {}
			EndIf
			If !(aSx3DTC[nContDTC, 1] $ "DTC_CLIREM|DTC_LOJREM|DTC_NOMREM|DTC_INSREM|DTC_SQIREM|DTC_CLIDES|DTC_LOJDES|DTC_NOMDES|DTC_INSDES|DTC_SQIDES|DTC_SQEDES|DTC_TIPNFC")
				AAdd( aVisual, aSx3DTC[nContDTC, 1] )
				//-- Campos DTC_SELORI, DTC_FILCFS e DTC_NUMSOL são bloqueados para Redespacho Intermediario
				If !(aSx3DTC[nContDTC, 1] $ "DTC_FILCFS|DTC_NUMSOL|DTC_SELORI")
					AAdd( aAltEnc, aSx3DTC[nContDTC, 1] )
				EndIf
			EndIf
		Else
			AAdd( aVisual, aSx3DTC[nContDTC, 1] )
		EndIf

	EndIf
Next nContDTC

If nOpcx == 3
	RestArea(aAreaDTC)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura variaveis da Enchoice                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpcx <> 3 //-- 3=Inclusao
	TmsValInf(aValInf,'4',M->DTC_FILORI,,M->DTC_LOTNFC,M->DTC_CLIREM,M->DTC_LOJREM,M->DTC_CLIDES,M->DTC_LOJDES,M->DTC_SERVIC,,,,,,,,,M->DTC_CODNEG)
	aCopValInf := aClone(aValInf)
EndIf

DTP->(dbSetOrder(2))
If (nOpcx == 3 .Or. nOpcx == 4) .And. DTP->(MsSeek(xFilial("DTP")+cFilAnt+cNumLotUso)) .And. DTP->DTP_QTDDIG < DTP->DTP_QTDLOT
	M->DTC_LOTNFC := cNumLotUso
	If lCamposRat
		lRateio := Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
	EndIf

	If lRateio
		cTABRAT := DTP->DTP_TABRAT
		cTIPRAT := DTP->DTP_TIPRAT
		cTBARAT := DTP->DTP_TBARAT
		cTPARAT := DTP->DTP_TPARAT
		cBACRAT := Iif( DTP->DTP_BACRAT == StrZero(1, Len(DTP->DTP_BACRAT)), "", DTP->DTP_BACRAT) // 1=Nao Utiliza
		cCRIRAT := Iif( DTP->DTP_CRIRAT == StrZero(1, Len(DTP->DTP_CRIRAT)), "", DTP->DTP_CRIRAT) // 1=Nao Utiliza
		cPRORAT := Iif( DTP->DTP_PRORAT == StrZero(1, Len(DTP->DTP_PRORAT)), "", DTP->DTP_PRORAT) // 1=Nao Utiliza
		If lCmpRatNew
			cCRDVFA := Iif( DTP->DTP_CRDVFA == StrZero(0, Len(DTP->DTP_CRDVFA)), "", DTP->DTP_CRDVFA) // 0=Nao Utiliza
			cCRDVDC := Iif( DTP->DTP_CRDVDC == StrZero(0, Len(DTP->DTP_CRDVDC)), "", DTP->DTP_CRDVDC) // 0=Nao Utiliza
		EndIf
		cORIRAT := DTP->DTP_ORIRAT
		cCALRAT := DTP->DTP_CALRAT

		M->DTC_ORIRAT:= cORIRAT
		M->DTC_RORRAT:= Posicione("DUY",1,xFilial("DUY")+cORIRAT,"DUY_DESCRI")
		M->DTC_UORRAT:= Posicione("DUY",1,xFilial("DUY")+cORIRAT,"DUY_EST")
		M->DTC_CALRAT:= cCALRAT
		M->DTC_RCARAT:= Posicione("DUY",1,xFilial("DUY")+cCALRAT,"DUY_DESCRI")
		M->DTC_UCARAT:= Posicione("DUY",1,xFilial("DUY")+cCALRAT,"DUY_EST")
	EndIf
	If lTmsGRem
		M->DTC_CLIREM := cCliRemUso
		M->DTC_LOJREM := cLojRemUso
		M->DTC_NOMREM := Posicione('SA1',1,xFilial('SA1')+M->(DTC_CLIREM+DTC_LOJREM),'A1_NOME')
	EndIf
	// Se o no. da Solicitacao ja estiver preenchido, NAO executar o gatilho no campo
	If Empty(M->DTC_NUMSOL)
		RunTrigger(1,Nil,Nil,,"DTC_LOTNFC")
	EndIf
EndIf

If l050Exclui
	AAdd(aYesFields,"DTC_ESTORN")
EndIf

//--Cria o aHeader e aCols
lRet:= TMS050IniVar(	"DTC",;
						xFilial("DTC")+M->DTC_FILORI+M->DTC_LOTNFC+M->DTC_CLIREM+M->DTC_LOJREM+M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SERVIC,;
						"DTC->DTC_FILIAL+DTC->DTC_FILORI+DTC->DTC_LOTNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CLIDES+DTC->DTC_LOJDES+DTC->DTC_SERVIC",;
						"DTC->DTC_NUMSOL+DTC->DTC_CLICON+DTC->DTC_LOJCON+DTC->DTC_CLIDPC+DTC->DTC_LOJDPC+DTC->DTC_CLIDEV+DTC->DTC_LOJDEV+DTC->DTC_SQEDES+"+;
						"DTC->DTC_SQIDES+DTC->DTC_SQICON+DTC->DTC_SQIDPC+DTC->DTC_SQIREM+DTC->DTC_SERTMS+DTC->DTC_TIPTRA+DTC->DTC_TIPNFC+DTC->DTC_CDRORI+"+;
						"DTC->DTC_CDRDES+DTC->DTC_CDRCAL+DTC->DTC_CDRPER+DTC->DTC_NUMCOT+AllTrim(Str(DTC->DTC_KM))+DTC->DTC_DISTIV+DTC->DTC_RECISS+"+;
						"DTC->DTC_EXCTDA == M->DTC_NUMSOL+M->DTC_CLICON+M->DTC_LOJCON+M->DTC_CLIDPC+"+;
						"M->DTC_LOJDPC+M->DTC_CLIDEV+M->DTC_LOJDEV+M->DTC_SQEDES+M->DTC_SQIDES+M->DTC_SQICON+M->DTC_SQIDPC+M->DTC_SQIREM+M->DTC_SERTMS+M->DTC_TIPTRA+"+;
						"M->DTC_TIPNFC+M->DTC_CDRORI+M->DTC_CDRDES+M->DTC_CDRCAL+M->DTC_CDRPER+M->DTC_NUMCOT+AllTrim(Str(M->DTC_KM))+M->DTC_DISTIV+"+;
						"M->DTC_RECISS+M->DTC_EXCTDA",;
						1,;
						aYesFields,;
						aNoFields,;
						nOpcAnt )
// Preenchimento automático do GetDados
If lExb050Mnt
	For nCnt:= 1 To Len(aAutoItens[1])
		If (nPos:= aScan( aHeader,{|x| x[2]== aAutoItens[1][nCnt][1]}))>0
			aCols[1][nPos]:= aAutoItens[1][nCnt][2]
			__readvar := "M->"+aAutoItens[1][nCnt][1]
		EndIf
	Next
EndIf
If !INCLUI
	aColsCop    := aClone(aCols)
	aCopEndProd := aClone(aEndProd)
	cServicOld  := M->DTC_SERVIC
EndIf

If l050Altera
	//-- Guarda a Quantidade de Notas digitadas
	For nCntFor := 1 to Len(aCols)
		nSeek := AScan(aNFDigAnt,{|x|x[1] == GdFieldGet('DTC_NUMNFC',nCntFor)+GdFieldGet('DTC_SERNFC',nCntFor)})
		If nSeek == 0
			AAdd(aNFDigAnt,{GdFieldGet('DTC_NUMNFC',nCntFor)+GdFieldGet('DTC_SERNFC',nCntFor)} )
		EndIf
	Next
	nQtdNfAnt:= Len(aNFDigAnt)
EndIf

If nOpcx == 6  // Copiar
	//-- Verificacao da integridade do cadastro de clientes.
	If !Empty(M->DTC_CLIREM) .And. !ExistCpo('SA1',M->DTC_CLIREM+M->DTC_LOJREM,1)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return(.F.)
	EndIf
	If !Empty(M->DTC_CLIDES) .And. !ExistCpo('SA1',M->DTC_CLIDES+M->DTC_LOJDES,1)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return(.F.)
	EndIf
	If !Empty(M->DTC_CLICON) .And. !ExistCpo('SA1',M->DTC_CLICON+M->DTC_LOJCON,1)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return(.F.)
	EndIf
	If !Empty(M->DTC_CLIDPC) .And. !ExistCpo('SA1',M->DTC_CLIDPC+M->DTC_LOJDPC,1)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return(.F.)
	EndIf
	l050Inclui    := .T.
	Inclui        := .T.
	lCopiar       := .T. //-- Variavel utilizada para realizar a copia do aCols para o botao "Tipo de Veiculos"
	lGetCpy       := .T.
	nOpcx         := 3
	M->DTC_FILORI := cFilAnt
	M->DTC_DATENT := dDataBase
	M->DTC_LOTNFC := CriaVar("DTC_LOTNFC",.F.)
	M->DTC_NUMSOL := CriaVar("DTC_NUMSOL",.F.)
	M->DTC_NUMCOT := CriaVar("DTC_NUMCOT",.F.)
	M->DTC_FILDOC := CriaVar("DTC_FILDOC",.F.)
	M->DTC_DOC    := CriaVar("DTC_DOC"   ,.F.)
	M->DTC_SERIE  := CriaVar("DTC_SERIE" ,.F.)

	If IsInCallStack("TMSAF76")
		M->DTC_LOTNFC := TMS050Lot()
	EndIf

	If lTmsCFec
		M->DTC_DATCOL := CriaVar("DTC_DATCOL",.F.)
		M->DTC_HORCOL := CriaVar("DTC_HORCOL",.F.)
		M->DTC_DTENTR := CriaVar("DTC_DTENTR",.F.)
		M->DTC_HORENT := CriaVar("DTC_HORENT",.F.)
		M->DTC_RECEBE := CriaVar("DTC_RECEBE",.F.)
	EndIf

	If lTm050Cop
		ExecBlock("TM050COP",.F.,.F. )
	EndIf

	DTP->(DbSetOrder(2))
	If DTP->(MsSeek(xFilial("DTP") + M->DTC_FILORI + M->DTC_LOTNFC))
		If lCamposRat
			lRateio	  := Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
		EndIf
	EndIf

	If lRateio
		cTABRAT := DTP->DTP_TABRAT
		cTIPRAT := DTP->DTP_TIPRAT
		cTBARAT := DTP->DTP_TBARAT
		cTPARAT := DTP->DTP_TPARAT
		cBACRAT := Iif( DTP->DTP_BACRAT == StrZero(1, Len(DTP->DTP_BACRAT)), "", DTP->DTP_BACRAT) // 1=Nao Utiliza
		cCRIRAT := Iif( DTP->DTP_CRIRAT == StrZero(1, Len(DTP->DTP_CRIRAT)), "", DTP->DTP_CRIRAT) // 1=Nao Utiliza
		cPRORAT := Iif( DTP->DTP_PRORAT == StrZero(1, Len(DTP->DTP_PRORAT)), "", DTP->DTP_PRORAT) // 1=Nao Utiliza
		If lCmpRatNew
			cCRDVFA := Iif( DTP->DTP_CRDVFA == StrZero(0, Len(DTP->DTP_CRDVFA)), "", DTP->DTP_CRDVFA) // 0=Nao Utiliza
			cCRDVDC := Iif( DTP->DTP_CRDVDC == StrZero(0, Len(DTP->DTP_CRDVDC)), "", DTP->DTP_CRDVDC) // 0=Nao Utiliza
		EndIf

		cORIRAT := DTP->DTP_ORIRAT
		cCALRAT := DTP->DTP_CALRAT
	EndIf
	//-- Limpa Serie das Notas Fiscais, alimenta o alias e o recno na copia
	For nCnt := 1 To Len(aCols)
		GdFieldPut("DTC_ALI_WT","DTC",nCnt)
		GdFieldPut("DTC_REC_WT",0,nCnt)

		GdFieldPut("DTC_NFENTR","2",nCnt)
		GdFieldPut("DTC_FILOCO","",nCnt)
		GdFieldPut("DTC_NUMOCO","",nCnt)

		If lDTCRee
			GdFieldPut("DTC_DOCREE","2",nCnt)
		EndIf

		//--Atualiza os dados dos tipos de veiculos selecionados
		//--no documento que esta sendo copiado...
		If lTMSCFec
			n := 1
			cNumNFC := GDFieldGet('DTC_NUMNFC', nCnt)
			cSerNFC := GDFieldGet('DTC_SERNFC', nCnt)
			cCodPro := GDFieldGet('DTC_CODPRO', nCnt)
			A050TipVei(nOpcx, M->DTC_FILORI,M->DTC_NUMSOL,M->DTC_NUMCOT, cNumNFC,cSerNFC,M->DTC_CLIREM,M->DTC_LOJREM, .F.)
		EndIf

		If lAgdEntr
			GdFieldPut("DTC_NUMAGD","",nCnt)
			GdFieldPut("DTC_ITEAGD","",nCnt)
		EndIf

	Next nCnt

EndIf

//--Quando Redespacho Intermediario o Tipo da Nota Fiscal deve ser '9'
//--O campo DTC_SELORI "Selecao de Origem" fica travado com '2'-Cliente Remetente já que o Remetente e Expedidor serao iguais
If lRedespInt == .T.
	M->DTC_TIPNFC := "9"
	M->DTC_SELORI := "2" //--1=Transportadora;2=Cliente Remetente;3=Local Coleta ou Exped
EndIf

//- Guarda os valores iniciais dos campos para validação posteriormente
If nOpcx == 4 //Alteração
   TMSA050VAtu()
EndIf

//-- Incializa variaveis referente a ocorrência de retorno da mercadoria
If nOpcx == 3 .And. lAptPend .And. ( Type("M->DUU_CODCLI") <> "U" .And. Type("M->DUU_LOJCLI") <> "U"  ) 
	M->DTC_CLIREM	:= M->DUU_CODCLI
	M->DTC_LOJREM	:= M->DUU_LOJCLI
EndIf

//-- Inicializa variavel DECRETO Nº 46.591 UF de MG
nVerSubCon := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os dados foram iniciados.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o Campo "Estorno" com o conteudo igual a "Sim"                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l050Exclui
		aEval(aCols,{|x| x[GdFieldPos("DTC_ESTORN")] := "1"})
	EndIf
	If !l050Auto
		aSize := MsAdvSize()
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T.} )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj := MsObjSize( aInfo, aObjects,.T.)
		While .T.
			If lTM050GRD  //-- Permite ao usuario efetuar manipulacao de GETDADOS e aCols
				ExecBlock('TM050GRD',.F.,.F.,{nOpcx})
			EndIf

			If lTM050REP	//-- Retorna uma string com os campos que terão os valores repetidos na proxima linha do acols.
				cCpoRep := ExecBlock('TM050REP',.F.,.F.)
			EndIf

			If lAgdEntr
				If !Empty(cCpoRep)
				   cCpoRep += "/"
				EndIf
				cCpoRep += cCpoRepAgd
			EndIf

			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		nOpca := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Enchoice                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oEnchoice:= MsMGet():New("DTC", nReg, nOpcx,,,,aVisual,aPosObj[1],aAltEnc,nOpcx,,,,,,.T. )
		o1Get:= MSGetDados():New( aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpcx,"TMSA050LinOk",'AllWaysTrue' ,cCpoRep,If(l050Inclui .Or. l050Altera,.T.,Nil),If(nOpcx==5,aAlter,Nil),,,If(nOpcx==5,Len(aCols),999),,,,'TmsA050DLi')
    	o1Get:oBrowse:bChange := { || TMSA050Chg() }  //--Se for Redespacho,repetir item do grid.

		If lExb050Mnt
			TMS050Trig(aVisual)
		Endif

		If lGetCpy
			TMSAGetCpy()
		EndIf

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(TMSA050TudOk(nOpcx,oDlg),oDlg:End(),nOpca := 0)},{||oDlg:End()},, aButtons ),;
			  IIf(lTmsGRem .And. nOpcx == 3 .And. DTP->(MsSeek(xFilial("DTP")+cFilAnt+cNumLotUso)) .And. DTP->DTP_QTDDIG < DTP->DTP_QTDLOT,TMSA050SX3(),.T.))

			If	nOpca == 1 .And. nOpcx != 2
				Processa({|| lGrava := TMSA050Grava(nOpcx,@nPosDTC,aColsCop,aCopEndProd,cServicOld)},cCadastro)
				If	lGrava
					TmsGrvInf(aValInf, '2', M->DTC_FILORI, , M->DTC_LOTNFC, M->DTC_CLIREM, M->DTC_LOJREM, M->DTC_CLIDES, M->DTC_LOJDES, M->DTC_SERVIC, nOpcx, , IIf(nOpcx == 3, aValInf, aCopValInf), M->DTC_SERVIC, M->DTC_CODNEG)
					//-- Caso Existam Bloqueios Antigos, Limpa Referencia (DDU)
					If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA200")
						//--      (nOpc,cRotina  ,cTipBlq,cFilOri      ,cTab   ,cInd ,cChave                        ,cCod,cDetalhe)
						Tmsa029Blq( 5  ,'TMSA200', ''    ,M->DTC_FILORI, 'DTP' , '1' ,xFilial("DTP") + M->DTC_LOTNFC, "" , "" )
					EndIf
				EndIf

				If lGrava .And. nPosDTC > 0
					//-- O mbrowse sera posicionado no registro gravado no DTC
					aAreaAnt[3]:=nPosDTC
				EndIf
			EndIf
			If lGrava .Or. nOpca == 0 .Or. nOpcx == 2
				DTP->(dbSetOrder(2))
				If DTP->(MsSeek(xFilial("DTP") + M->DTC_FILORI + M->DTC_LOTNFC))
					If lViaCol .And. !IsInCallStack("TMSF76VIA") .And. IsInCallStack("TMSAF76") .And. nOpca == 0 .And. Empty(DTP->DTP_VIACOL)
						TMS050Fecl(nOpcx)
					EndIf
				EndIf
				Exit
			EndIf
		EndDo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validando dados para rotina automatica                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If EnchAuto(cAlias,aAutoCab,,nOpcx,aVisual,{|| Obrigatorio(aGets,aTela)}) .and. MsGetDAuto(aAutoItens,,{|| TMSA050TudOk()},aAutoCab,nOpcx)
			nOpca := 1
		EndIf
		If	nOpca == 1 .And. nOpcx != 2
			Processa({|| TMSA050Grava(nOpcx,@nPosDTC,aColsCop,aCopEndProd,cServicOld)},cCadastro)
		EndIf
	EndIf
EndIf

If (Substr(FunName(),1,7) == "TMSA500" .And. nOpcx == 2) //No TMSA500, desabilita nas funcoes do tmsa200 o tratamento de carga fechada
	lTmsCFec  := .F.
EndIf

If !lLibLtSc .And. !Empty(M->DTC_NUMSOL)
	FreeUsedCode(.T.)
EndIf

aEndProd  :={}
aCotFrete :={}
aRatPesM3 :={}
lCotacao  := .F.
cOrigem   := ""  //-- Esvazia a Variável De Validação De Campos
lSemCtr   := .F.
cNumSolDif := ''
cSerTmsDif := ''

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf
RestInter()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)
RestArea(aAreaDUL)
RestArea(aAreaAnt1)
RestArea(aAreaAnt)

Return( nOpca == 1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA050Chg ³Autor  ³ Alex Amaral        ³Data  ³ 18.junho.15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Repetir conteudo do grid no proximo item -Redespacho       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA050Chg(aYesFields)
Local nPosFILDPC := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_FILDPC' })
Local nPosCTRDPC := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_CTRDPC' })
Local nPosTIPANT := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_TIPANT' })
Local nPosDPCEMI := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_DPCEMI' })
Local nPosCTEANT := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_CTEANT' })
Local nPosSERDPC := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_SERDPC' })
Local nPosVALDPC := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_VALDPC' })
Local nPosFRTSUB := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_FRTSUB' })

//--Repetir conteudo da grid quando for Redespacho
If M->DTC_TIPNFC $ '2|5' .And. (l050Inclui .Or. l050Altera)
	If n = Len(aCols)
		If Empty(aCols[n,nPosCTEANT]) .And. n > 1
			aCols[n,nPosFILDPC] := aCols[Len(aCols)-1,nPosFILDPC]
			aCols[n,nPosCTRDPC] := aCols[Len(aCols)-1,nPosCTRDPC]
			aCols[n,nPosTIPANT] := aCols[Len(aCols)-1,nPosTIPANT]
			aCols[n,nPosDPCEMI] := aCols[Len(aCols)-1,nPosDPCEMI]
			aCols[n,nPosCTEANT] := aCols[Len(aCols)-1,nPosCTEANT]
			aCols[n,nPosSERDPC] := aCols[Len(aCols)-1,nPosSERDPC]
			aCols[n,nPosVALDPC] := aCols[Len(aCols)-1,nPosVALDPC]
			aCols[n,nPosFRTSUB] := aCols[Len(aCols)-1,nPosFRTSUB]
		EndIf
	EndIf
	o1Get:Refresh()
EndIf

Return (.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Grava  ³ Autor ³ Patricia A. Salomao  ³ Data ³05.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava a Nota Fiscal                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050Grava(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1- Opcao Selecionada                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA050Grava(nOpcx,nPosDTC,aColsCop,aCopEndProd,cServicOld)

Local i
Local nX, nY, nCnt, nI, nPos
Local nValDTP    := 0
Local nNumNFC    := 0
Local nPosNumNF  := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_NUMNFC' })
Local nPosSerNF  := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_SERNFC' })
Local nPosCodPro := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_CODPRO' })
Local nPosEDI    := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_EDI' })
Local aAreaSA1   := SA1->(GetArea())
Local aAreaDE5   := DE5->(GetArea())
Local aAreaDTC   := DTC->(GetArea())
Local lPrdDiv    := GetMV("MV_PRDDIV",,.F.) // Verifica se permitira a inclusao de um ou mais produtos
Local nSeekNF    := 0
Local aNFs       := {}
Local aNFsExc    := {}
Local nQtdVol    := 0
Local nPeso      := 0
Local cFilVga    := ''
Local cViagem    := ''
Local nRecnoDUD  := 0
Local aDados     := {}
Local nItem      := 0
Local cCodProd   := ""
Local aCotacao   := { {}, {}, {}, {}, {}, {}, {} }
Local aProdutos  := {}
Local aTelSol    := {}
Local nQtdeNota  := 0
Local nQtdeCalc  := 0
Local cSeek      := ""
Local cAliasDTC  := "DTC"
Local cFilDT5    := xFilial('DT5')
Local cFilDT4    := xFilial('DT4')
Local lAtualDT5  := .T.
Local lRet       := .T.
Local lFoundDF6  := .F.
Local dDatCol    := Nil
Local cHorCol    := Nil
Local nOdoChg    := 0
Local dDatChg    := CtoD(Space(08))
Local cHorChg    := ''
Local dDatSai    := CtoD(Space(08))
Local cHorSai    := ''
Local aAreaDT5   := {}
Local lVgPlane   := .F.
Local cSeekDVU   := ''
Local cSeekDUH   := ''
Local lCancSol   := .F.
Local cAliasQry  := GetNextAlias()
Local lLoteAuto  := SuperGetMv("MV_LOTAUT",.F.,.T.)
Local aVInfCot   := {}
Local aFrtCmp    :={}
Local aDadosVei	 :={}
Local nCnt1      := 0
Local lVgeExpr1  := Iif(Type("lVgeExpr") <> "U", lVgeExpr, .F.)
Local aContrat	:= TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL, , M->DTC_SERVIC, .F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
Local lCamposRat	:= DTP->(ColumnPos("DTP_RATEIO")) > 0
Local lViaCol	 	:= DTP->(ColumnPos("DTP_VIACOL")) > 0
Local lIdentDoc	:= DTC->(ColumnPos("DTC_DOCTMS")) > 0
Local lCmpRatNew 	:= DTP->(ColumnPos("DTP_CRDVFA")) > 0 .And. DTP->(ColumnPos('DTP_CODNEG')) > 0
Local lGerAge  	:= .F.
Local cSrvCol  	:= ""
Local cSrv		 	:= ""
Local cNumSolDig	:= M->DTC_NUMSOL
Local lPainelAgd	:= IsInCallStack("TMSAF76") .And. lLoteAuto
Local cContrat	:= ""
Local cCodNeg		:= ""
Local cRetSobSer	:= ""
Local cServic		:= ""
Local lTMS3GFE	:= Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lContCan := .T.
Local lRetTran := .T.

Default nPosDTC 	:= 0
Default cServicOld := ''

Private lInclCot := .T.
Private cNumCot  := ''
Private l040Auto := .F.

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTms)

If lTM050Sol
	lContCan := ExecBlock("TM050SOL",.F.,.F.)
	If ValType(lContCan) != "L"
		lContCan := .T.
	EndIf
EndIf

If	((nOpcx == 3  .Or. nOpcx == 4) .And. !IsInCallStack("TM050GrVag"))	// Inclusao ou Alteracao
	//-- Gera Coleta e Agendamento quando nao informada a solicitacao de coleta na nota - Novo conceito de Carga Fechada
	If Empty(M->DTC_NUMSOL)
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,Iif(!Empty(M->DTC_SERVIC),M->DTC_SERVIC, Nil),, M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If !Empty(aContrat)
			lGerAge := ((aContrat[1,43,1,19] == "1") .Or. (aContrat[1,43,1,19] == "0" .And. aContrat[1,44,1,7] == "1"))
			cSrv	 := M->DTC_SERVIC

			If !lPainel

				If lGerAge
				    If !Empty(aContrat[1,43])
				        If aContrat[1,43,1,19] == "1"          // DDA_AGEVIR = "Sim"
					       cSrvCol := aContrat[1][43][1][18]      // DDA_SRVCOL

				        ElseIf aContrat[1,43,1,19] == "0"
				             If !Empty(aContrat[1,44])
				                 If aContrat[1,44,1,7] == "1"     // DDA_AGEVIR = "Nao Utiliza" E DDC_AGEVIR = "Sim"
					                cSrvCol := aContrat[1,44,1,8] // DDC_SRVCOL
					             EndIf
					         EndIf
					    EndIf //| Fim do If aContrat[1,43,1,19] == "1"
					EndIf // Fim do If !Empty(aContrat[1,43])

				Else
				    If lGerAge .And. aContrat[1,49] == "1"
					   cSrvCol := aContrat[1,50] //DUX_SRVCOL
					EndIf
				EndIf

			ElseIf lPainel .And. !Empty(aContrat[1,43])
				cSrvCol := aContrat[1,43,1,18] //DDA_SRVCOL
			ElseIf lPainel .And. !Empty(aContrat[1,44])
				cSrvCol := aContrat[1,44,1,8] //DDC_SRVCOL
			EndIf

		EndIf
		If IsInCallStack("TMSAF76") .Or. (!IsInCallStack("TMSAF76") .And. lGerAge)
			If !Empty(cSrv) .And. !TM050GerAg(cSrv,cSrvCol)
				Return .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o Lote                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DTP")
	dbSetOrder(2)
	If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC)) .And. RecLock("DTP",.F.)
		If lCamposRat
			If !lPainelAgd .Or. (lPainelAgd .And. !lRateio)   //Via Painel de Agendamento - Nota Balcao, o Lote é criado automaticamente como Rateio=Nao
				lRateio := Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
			EndIf
		EndIf

		If lRateio .And. Empty(cBACRAT)
			// Obter posicao do Serviço Selecionado, para obter suas Regras de Rateio //
			nCnt1 := Ascan(aContrat, { |x| x[27] == M->DTC_SERVIC })

			If nCnt1 > 0
				cTABRAT := aContrat[nCnt1][03]
				cTIPRAT := aContrat[nCnt1][04]
				cTBARAT := aContrat[nCnt1][15]
				cTPARAT := aContrat[nCnt1][16]
				cBACRAT := aContrat[nCnt1][42]
				cCRIRAT := aContrat[nCnt1][41]
				cPRORAT := aContrat[nCnt1][40]
				If lCmpRatNew
					cCRDVFA := aContrat[nCnt1][46]
					cCRDVDC := aContrat[nCnt1][47]
				EndIf

				cORIRAT := M->DTC_ORIRAT
				cCALRAT := M->DTC_CALRAT
				DTP->DTP_TABRAT := cTABRAT
				DTP->DTP_TIPRAT := cTIPRAT
				DTP->DTP_TBARAT := cTBARAT
				DTP->DTP_TPARAT := cTPARAT
				DTP->DTP_BACRAT := cBACRAT
				DTP->DTP_CRIRAT := cCRIRAT
				DTP->DTP_PRORAT := cPRORAT
				DTP->DTP_ORIRAT := cORIRAT
				DTP->DTP_CALRAT := cCALRAT
				If lPainelAgd .And. DTP->DTP_RATEIO <> '1' //Pela Nota Balcao via Painel de Agendamento, nao grava dados do Rateio
					DTP->DTP_RATEIO:= StrZero(1, Len(DTP->DTP_RATEIO))
				EndIf

				If lCmpRatNew
					DTP->DTP_CRDVFA := cCRDVFA
					DTP->DTP_CRDVDC := cCRDVDC
					If cPRORAT == "A"  //% Fixo
						DTP->DTP_NCONTR := aContrat[nCnt1][01]		//-- Grava Número Do Contrato
						DTP->DTP_CODNEG := M->DTC_CODNEG
						DTP->DTP_SERVIC := M->DTC_SERVIC
					EndIf
				EndIf
			EndIf
		EndIf
		If DTP->DTP_QTDDIG+Len(aNFDig)-nQtdNfAnt <= DTP_QTDLOT
			nValDTP := DTP_QTDDIG + Len(aNFDig) - nQtdNfAnt//-- Soma  a Qtd. Atual de  NF
			DTP->DTP_QTDDIG := nValDTP
				DTP->DTP_STATUS := If(DTP_QTDDIG==DTP_QTDLOT,"2","1")
		ElseIf IsInCallStack('TMSAF76')
			Tmsa050RLt(DTP->DTP_FILORI,DTP->DTP_LOTNFC) //--Reabertura do lote.
		Else
			Help("",1,"TMSA05004")  //-- O No. de Notas Informadas ultrapassou a qtde. de Notas permitidas para o Lote
			Return( .F. )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a Conferencia de Coleta                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->DTC_NUMSOL)
		lAtualDT5 := .F.
		DT5->(dbSetOrder(1))
		If !Empty(M->DTC_FILCFS)
			cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
			cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
		Else
			cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
		EndIf
		If DT5->(MsSeek(cSeek))
			DF6->(DbSetOrder(2))
			If DF6->(MsSeek(xFilial('DF6')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
				RecLock('DF6',.F.)
				DF6->DF6_QTDDIG += Len(aNFDig) - nQtdNfAnt
				MsUnLock()
				If DF6->DF6_QTDENF == DF6->DF6_QTDDIG
					lAtualDT5 := .T.
					M->DTC_DATCOL := DF6->DF6_DATCOL
					M->DTC_HORCOL := DF6->DF6_HORCOL
				EndIf
			Else
				lAtualDT5 := .T.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza cliente do solicitante - (Portal - TMS)                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DUE->(DbSetOrder(1))
		If DUE->(dbSeek(xFilial('DUE')+DT5->DT5_CODSOL)) .And. Empty(DUE->DUE_CODCLI)
			SA1->(DbSetOrder(3))
			If SA1->(dbSeek(xFilial('SA1')+DUE->DUE_CGC))
				RecLock('DUE',.F.)
				DUE->DUE_CODCLI := SA1->A1_COD
				DUE->DUE_LOJCLI := SA1->A1_LOJA
				MsUnLock()
			EndIf
		EndIf

	Else
		lAtualDT5 := .T.
	EndIf

	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de valor informado, cria cotacao com o valor informado no 1o.compo-³
		//³nente e associa a cotacao as notas                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTmsVInf .And. M->DTC_VLRINF > 0
			aTelSol := TMSAF05DUE(M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_TIPTRA,.T.)
			//-- Cabecalho da Cotacao
			AAdd( aDados, M->DTC_FILORI ) //-- Filial Origem
			AAdd( aDados, aTelSol[1]    ) //-- Cod.Solicitante
			AAdd( aDados, M->DTC_TIPFRE ) //-- Tipo Frete
			AAdd( aDados, M->DTC_SELORI ) //-- Seleciona Regiao
			AAdd( aDados, M->DTC_CDRORI ) //-- Regiao Origem
			AAdd( aDados, M->DTC_CDRCAL ) //-- Regiao de Calculo
			AAdd( aDados, M->DTC_SERTMS ) //-- Entrega
			AAdd( aDados, M->DTC_TIPTRA ) //-- Tipo Transporte
			AAdd( aDados, M->DTC_SERVIC ) //-- Servico
			AAdd( aDados, M->DTC_CLIREM ) //-- Remetente
			AAdd( aDados, M->DTC_LOJREM ) //-- Loja Remetente
			AAdd( aDados, M->DTC_CLIDES ) //-- Destinatario
			AAdd( aDados, M->DTC_LOJDES ) //-- Loja Destinatario
			AAdd( aDados, M->DTC_CLIDEV ) //-- Devedor
			AAdd( aDados, M->DTC_LOJDEV ) //-- Loja Devedor
			AAdd( aDados, M->DTC_NUMSOL ) //-- Solicitacao
			AAdd( aDados, M->DTC_KM )     //-- KM
			If lIdentDoc
				AAdd(aDados, M->DTC_DOCTMS) //-- Tipo documento transporte
			EndIf

			aCotacao[DADOSCOT] := AClone(aDados) //-- Dados do cabecalho da cotacao

			aColsAux := {}
			nItem    := 0

			For nCnt := 1 To Len(aColsDVU)
				For nCnt1 := 1 To Len(aColsDVU[nCnt][2])
					AAdd(aDadosVei, { aColsDVU[nCnt][2][nCnt1][1], aColsDVU[nCnt][2][nCnt1][2],aColsDVU[nCnt][2][nCnt1][4], aColsDVU[nCnt][2][nCnt1][7]})
				Next nCnt1
			Next nCnt

			For nCnt := 1 To Len(aCols)
				cCodProd := GdFieldGet("DTC_CODPRO",nCnt)
				If (nPos := Ascan(aColsAux,{ | e | e[1] == cCodProd })) == 0
					AAdd(aColsAux,Array(8))
					nPos := Len(aColsAux)
					Afill(aColsAux[nPos],0)
					aColsAux[nPos,1] := cCodProd
					aColsAux[nPos,2] := GdFieldGet("DTC_CODEMB",nCnt)
				EndIf
				aColsAux[nPos,3] += GDFieldGet("DTC_QTDVOL",nCnt)
				aColsAux[nPos,4] += GDFieldGet("DTC_QTDUNI",nCnt)
				aColsAux[nPos,5] += GDFieldGet("DTC_PESO"  ,nCnt)
				aColsAux[nPos,6] += GDFieldGet("DTC_PESOM3",nCnt)
				aColsAux[nPos,7] += GDFieldGet("DTC_METRO3",nCnt)
				aColsAux[nPos,8] += GDFieldGet("DTC_VALOR" ,nCnt)
			Next nCnt

			// Soma produtos e valores (volume, unitizadores, peso real, peso cubado, vlr mercadoria)
			For nCnt := 1 To Len(aColsAux)
				aDados := {}
				nItem  += 1
				AAdd(aDados,StrZero(nItem,Len(DVF->DVF_ITEM))) // Item da cotacao
				AAdd(aDados,aColsAux[nCnt,1]) // Codigo Produto
				AAdd(aDados,aColsAux[nCnt,2]) // Cod.Embalagem
				AAdd(aDados,aColsAux[nCnt,3]) // Volumes
				AAdd(aDados,aColsAux[nCnt,4]) // Unitizadores
				AAdd(aDados,aColsAux[nCnt,5]) // Peso Real
				AAdd(aDados,aColsAux[nCnt,6]) // Peso Cubado
				AAdd(aDados,aColsAux[nCnt,7]) // Metro Cubico
				AAdd(aDados,aColsAux[nCnt,8]) // Valor da Mercadoria
				AAdd(aDados,.F. ) // Item deletado ou nao
				AAdd(aProdutos, AClone(aDados) )
			Next nCnt

			aCotacao[PRODCOT]   := AClone(aProdutos) //-- Produtos da cotacao
			aCotacao[FRTINFCOT] := {M->DTC_VLRINF,M->DTC_VLRINF} //-- Valor Informado de frete [1] Vlr Total [2] Saldo Para evitar sobra
			aCotacao[TIPVEICOT] := AClone(aDadosVei)

			//---------------------------------------------------------------------------------
			//--Se o valor informado foi apenas digitado deve-se realizar o rateio proporcional
			//--do frete.
			If Empty(aCotFrete)
			   A050FrtInf(nOpcx,.T.,,.F.)
			Endif

			For nCnt := 1 To Len(aCotFrete)
				aFrtCmp := Array(4)
				aFrtCmp[CODPASCMP]  := aCotFrete[nCnt,3]
				aFrtCmp[VALPASCMP]  := aCotFrete[nCnt,2]
				aFrtCmp[TIPVALCMP]  := '2' // Sem Imposto
				aFrtCmp[LOTEDICMP]  := ''
				aAdd( aCotacao[FRTCMPCOT], AClone(aFrtCmp) )
			Next

			If !Empty(aValInf)
				aVInfCot := AClone(aValInf)

				For nCnt := 1 To Len (aVInfCot)
					If (aVInfCot[nCnt][2] > 0) .And. !(aVInfCot[nCnt][3])
						AAdd(aVInfCot[nCnt],.F. )
						AAdd(aCotacao[FRTVALINF], { aVInfCot[nCnt][6], AClone(aVInfCot) } )
					EndIf
				Next nCnt
			EndIf

			l040Auto := .T.
			TMSA040Mnt( "DT4", 0, 3 , , aCotacao, M->DTC_NUMSOL, CriaVar("DT4_NUMCOT",.F.), .F.)
			l040Auto := .F.

			If Empty(cNumCot) //-- Variavel atualizada na TMSA040Mnt()
				M->DTC_VLRINF := CriaVar("DTC_VLRINF",.F.)
			Else
				M->DTC_NUMCOT := cNumCot
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os Dados da Nota Fiscal                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DTC->(DbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERIVC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC

        dbSelectArea("SA1")
        dbSetOrder(1)
        MsSeek(xFilial("SA1")+M->DTC_CLIREM+M->DTC_LOJREM)
        dbSelectArea("DE5")
        dbSetOrder(1) //--DE5_FILIAL+DE5_CGCREM+DE5_DOC+DE5_SERIE

		For nX := 1 to Len(aCols)

			cAliasQry  := GetNextAlias()
			cQuery := "SELECT DE5.R_E_C_N_O_ nRecDE5"
			cQuery += "  FROM " + RetSQLTab('DE5')
			cQuery += " WHERE DE5.DE5_FILIAL     = '" + xFilial('DE5')       + "' AND "
			cQuery += "       DE5.DE5_CGCREM     = '" + SA1->A1_CGC          + "' AND "
			cQuery += "       DE5.DE5_DOC    	 = '" + aCols[nX][nPosNumNF]  + "' AND "
			cQuery += "       DE5.DE5_SERIE 	 = '" + aCols[nX][nPosSerNF]  + "' AND "
			cQuery += "       DE5.DE5_CODPRO	 = '" + aCols[nX][nPosCodPro] + "' AND "
			cQuery += "       DE5.D_E_L_E_T_	 = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

			If (cAliasQry)->(!Eof())
				DE5->(DbGoto((cAliasQry)->nRecDE5))
				RecLock("DE5",.F.)

				If !GdDeleted(nX)
					If DE5->DE5_STATUS == "1"
					   DE5->DE5_STATUS := '2'		//Encerrado
					EndIf

					aCols[nX][nPosEDI]	:=	'1'	//Sim

				ElseIf nOpcx == 4 //-- Alteracao (Linha Deletada)
					DE5->DE5_STATUS    := '1'	//Em Aberto
					aCols[nX][nPosEDI] := '2'	//Nao
				EndIf

				DE5->(MsUnLock())
			Else
				aCols[nX][nPosEDI]	 :=	 '2'	//Nao
			EndIf

		   (cAliasQry)->(DbCloseArea())

			If !GdDeleted(nX)
				nQtdVol += GDFieldGet("DTC_QTDVOL",nX)
				nPeso   += GDFieldGet("DTC_PESO"  ,nX)

				If !INCLUI .And. nX <= Len(aColsCop) .And. ;
					DTC->(dbSeek(xFilial("DTC")+M->(DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+cServicOld)+;
					aColsCop[nX][nPosCodPro]+aColsCop[nX][nPosNumNF]+aColsCop[nX][nPosSerNF]))
					RecLock( "DTC", .F. ) //Alteracao
				Else
					RecLock( "DTC", .T. ) //Inclusao
				EndIf

				For i := 1 To FCount()
					If "FILIAL"$Field(i)
						FieldPut(i,xFilial("DTC"))
					Else
						If Type("M->"+FieldName(i)) <> "U"
							FieldPut(i,M->&(FieldName(i)))
						EndIf
					EndIf
				Next i

				For nY := 1 to Len(aHeader)
					If aHeader[nY][10] # "V"
						DTC->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
					EndIf
				Next
				DTC->(MsUnLock())
				nPosDTC := DTC->(RecNo())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o campo MEMO                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MSMM(DTC->DTC_CODOBS,,,M->DTC_OBS,1,,,"DTC","DTC_CODOBS")

				If !Empty(DTC->DTC_INCOTE)
					MSMM(DTC->DTC_CODDCA,,,M->DTC_DOCANE,1,,,"DTC","DTC_CODDCA")
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o arquivo de Peso Cubado (DTE)                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(DTC_PESOM3)
					A050AtuDTE(1,aRatPesM3,aHeaderDTE,aColsCop,nOpcx,nX)
				Else
					//Caso tenha sido deletado atraves da alteracao, o mesmo deve ser excluido.
					DTE->(DbSetOrder(1))
					If nOpcx == 4 .And. DTE->(MsSeek(xFilial("DTE")+DTC->DTC_FILORI+aCols[nX][nPosNumNF]+aCols[nX][nPosSerNF]+DTC->(DTC_CLIREM+DTC_LOJREM)+aCols[nX][nPosCodPro]))
						RecLock("DTE",.F.)
						DbDelete()
						MsUnlock()
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o arquivo de Enderecamento de Nota Fiscal (DUH) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Localiza(GdFieldGet('DTC_CODPRO', nX) )
					A050AtuDUH(1,aEndProd,aHeaderDUH,aCopEndProd,nOpcx,nX)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o arquivo DVU (Tipos de Veiculo da Nota Fiscal)                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aColsDVU) > 0
					a050AtuDVU(DTC->DTC_FILORI,DTC->DTC_NUMNFC,DTC->DTC_SERNFC,DTC->DTC_CLIREM,DTC->DTC_LOJREM,"1",aColsCop,nX,nOpcx,DTC->DTC_LOTNFC)
				EndIf

				nSeekNF := Ascan(aNFs, {|x| x[1]+X[2]+X[3]+X[4] == DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) })
				If nSeekNF == 0
					AAdd(aNFs, {DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_CLIREM, DTC->DTC_LOJREM})
				EndIf

				nNumNFC++

				//-- Ponto de Entrada apos gravacao DTC
				If lTMA050Grv
					ExecBlock("TMA050GRV")
				EndIf
			ElseIf nOpcx == 4 //-- Alteracao (Linha Deletada)

				//-- Exclui Cubagem de Mercadorias
				DTE->(DbSetOrder(1))
				If DTE->(MsSeek(xFilial("DTE")+M->DTC_FILORI+GDFieldGet("DTC_NUMNFC",nX)+GDFieldGet("DTC_SERNFC",nX)+M->(DTC_CLIREM+DTC_LOJREM)+GDFieldGet("DTC_CODPRO",nX)))
					RecLock("DTE",.F.)
					DbDelete()
					MsUnlock()
				EndIf
				nCnt := 0
				If lPrdDiv
					//-- Excluir somete se nao existir outros itens do mesmo documento/serie e nao deletados.
					aEval(aCols,{|x|If(x[nPosNumNF]+X[nPosSerNF]==GDFieldGet("DTC_NUMNFC",nX)+GDFieldGet("DTC_SERNFC",nX) .And. !x[Len(x)], nCnt++,)})
				EndIf
				If nCnt == 0
					//-- Exclui Tipo VeIculo Nota Fiscal
					DVU->(DbSetOrder(1)) //DVU_FILIAL+DVU_FILORI+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM+DVU_ITEM
					If DVU->(MsSeek( cSeekDVU := xFilial("DVU")+M->DTC_FILORI+GDFieldGet("DTC_NUMNFC",nX)+GDFieldGet("DTC_SERNFC",nX)+M->(DTC_CLIREM+DTC_LOJREM)))
						While DVU->(!Eof() .And. DVU_FILIAL+DVU_FILORI+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM == cSeekDVU)
							RecLock("DVU",.F.)
							DbDelete()
							MsUnlock()
							DVU->(DbSkip())
						EndDo
					EndIf
				EndIf
				//-- Exclui Enderecamento
				DUH->(DbSetOrder(1))
				If DUH->(MsSeek( cSeekDUH := xFilial("DVU")+M->DTC_FILORI+GDFieldGet("DTC_NUMNFC",nX)+GDFieldGet("DTC_SERNFC",nX)+M->(DTC_CLIREM+DTC_LOJREM)+GDFieldGet("DTC_CODPRO",nX)))
					While DUH->(!Eof() .And. DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM+DUH_CODPRO == cSeekDUH)
						RecLock("DUH",.F.)
						DbDelete()
						MsUnlock()
						DUH->(DbSkip())
					EndDo
				EndIf

				If GdFieldPos("DTC_NUMAGD") > 0
                	nSeek := Ascan(aCols,{|x| x[GdFieldPos("DTC_NUMAGD")] == GDFieldGet("DTC_NUMAGD", nX) ;
  					   		.And. x[GdFieldPos("DTC_ITEAGD")] == GDFieldGet("DTC_ITEAGD", nX) .And. !x[Len(x)] })

                    If nSeek <= 0 .And. nSeek != n
                        DbSelectArea("DYD")
					    DbSetOrder(1)
					    If DYD->(DbSeek(xFilial("DYD")+GDFieldGet("DTC_NUMAGD", nX)+GDFieldGet("DTC_ITEAGD", nX)))
					         Reclock("DYD",.F.)
						     DbDelete()
						     MsUnlock()
					    EndIf
                    EndIf
                EndIf

				//-- Exclui Nota Fiscal
				If nX <= Len(aColsCop) .And. ;
					DTC->(dbSeek(xFilial("DTC")+M->(DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+cServicOld)+;
					aColsCop[nX][nPosCodPro]+aColsCop[nX][nPosNumNF]+aColsCop[nX][nPosSerNF]))
					RecLock("DTC",.F.)
					DbDelete()
					MsUnlock()
				EndIf
			EndIf

		Next nX

		For nX :=1 To Len(aNFs)
			//-- Se a Qtde. de Volumes foi informada, gera Nota Fiscal de Entrada
			If !TMSGerNFEnt(3, .T., , , ,aNFs[nx][1], aNFs[nX][2], aNFs[nX][3], aNFs[nX][4] )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o Lote                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("DTP")
				dbSetOrder(2)
				If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC)) .And. ;
					DTP->DTP_QTDDIG+Len(aNFDig)-nQtdNfAnt  <= DTP_QTDLOT
					RecLock("DTP",.F.)
					DTP->DTP_QTDDIG := nNumNFC
					DTP->DTP_STATUS := "5" //Erro de Gravacao
					MsUnLock()
					lRetTran := .F.
					Break
				EndIf
			EndIf
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza Status da Cotacao de Frete                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("DT4")
		dbSetOrder(1)
		If !Empty(M->DTC_FILCFS)
			cFilDT4 := TMSA050CFS("DT4",M->DTC_FILCFS)
			cSeek   := cFilDT4+M->DTC_FILCFS+M->DTC_NUMCOT
		Else
			cSeek   := cFilDT4+M->DTC_FILORI+M->DTC_NUMCOT
		EndIf
		If MsSeek(cSeek)
			RecLock("DT4",.F.)
			DT4->DT4_STATUS := '4'  //-- Cotacao de Frete Encerrada
			MsUnLock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza cliente do solicitante - (Portal - TMS)                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUE->(DbSetOrder(1))
			If DUE->(dbSeek(xFilial('DUE')+DT4->DT4_CODSOL)) .And. Empty(DUE->DUE_CODCLI)
				SA1->(DbSetOrder(3))
				If SA1->(dbSeek(xFilial('SA1')+DUE->DUE_CGC))
					RecLock('DUE',.F.)
					DUE->DUE_CODCLI := SA1->A1_COD
					DUE->DUE_LOJCLI := SA1->A1_LOJA
					MsUnLock()
				EndIf
			EndIf

		EndIf

		If lAtualDT5
			//-- Atualiza o Status da Solicitacao de Coleta
			DT5->(dbSetOrder(1))
			If !Empty(M->DTC_FILCFS)
				cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
				cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
			Else
				cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
			EndIf
			If DT5->(MsSeek(cSeek))
				aAreaDT5 := DT5->(GetArea())

				//-- Retorna a viagem da Solicitacao de coleta
				DUD->(DbSetOrder(1))
				If DUD->(MsSeek(xFilial("DUD")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
					While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE == ;
						xFilial("DUD") + DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE
						If	DUD->DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS)) .And.;	//-- Cancelado
							DUD->DUD_STATUS <> StrZero(4, Len(DUD->DUD_STATUS)) 		//-- Encerrado
								cFilVga := DUD->DUD_FILORI
								cViagem := DUD->DUD_VIAGEM
								Exit
						EndIf
						DUD->(DbSkip())
					EndDo
				EndIf

				//-- Se Viagem Planejada de Coleta, a Viagem de Coleta e solicitacao
				//-- de coleta serao canceladas no cálculo do frete.
				lVgPlane:= .F.
				DTQ->(DbSetOrder(2))
				If DTQ->(MsSeek(xFilial("DTQ")+cFilVga+cViagem))
					If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .And.;  //Viagem com Status em aberto
						DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) .And.;  //Serviço Coleta
						DTQ->DTQ_TIPVIA == StrZero(3,Len(DTQ->DTQ_TIPVIA))         //Planejada
							lVgPlane:= .T.
					EndIf
				EndIf

				If !lVgPlane
					//-- Verifica se devera ser gerada ocorrencia
					If lTmsCFec .And. !Empty(M->DTC_HORCOL) .And. !Empty(M->DTC_DATCOL)
						If !Empty(M->DTC_NUMSOL)
							DF6->(DbSetOrder(2))
							If DF6->(MsSeek(xFilial('DF6')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
								dDatCol := DF6->DF6_DATCOL
								cHorCol := DF6->DF6_HORCOL
								nOdoChg := DF6->DF6_ODOCHG
								dDatChg := DF6->DF6_DATCHG
								cHorChg := DF6->DF6_HORCHG
								dDatSai := DF6->DF6_DATSAI
								cHorSai := DF6->DF6_HORSAI
							EndIf
						EndIf
						TMSA050CFec(DT5->DT5_FILDOC, DT5->DT5_DOC, DT5->DT5_SERIE, nQtdVol, nPeso,;
									dDatCol, cHorCol,'',nOdoChg, dDatChg, cHorChg, dDatSai, cHorSai,@lCancSol)
					EndIf
				EndIf
				RestArea(aAreaDT5)
				RecLock("DT5",.F.)
				If lCancSol .And. lContCan
					DT5->DT5_STATUS := StrZero(9,Len(DT5->DT5_STATUS)) //-- Solicitacao Cancelada
					If Empty(DT5->DT5_DATCAN)
						DT5->DT5_DATCAN := dDataBase
						DT5->DT5_CODOBC := MSMM(DT5->DT5_CODOBC,,,STR0156,1,,,"DT5","DT5_CODOBC") //COLETA CANCELADA
					EndIf
					If IsIncallStack('TmsaF76')
						aAreaDF1 := DF1->(GetArea())
						DF1->(DbSetOrder(3))
						If DF1->(DbSeek(xFilial("DF1") + DT5->(DT5_FILORI + DT5_NUMSOL) + "COL"))
							Reclock("DF1",.F.)
								DF1->DF1_STACOL := StrZero(9,Len(DF1->DF1_STACOL))
								DF1->DF1_DATCAN := dDataBase
							DF1->(MsUnlock())
						EndIf
						RestArea(aAreaDF1)
					EndIf
				Elseif ((IsInCallStack("TMSAF76") .And. Empty(cNumSolDig)) .Or. (!IsInCallStack("TMSAF76") .And. lGerAge .And. Empty(cNumSolDig))) // .And. lContCan

					DT5->DT5_STATUS := StrZero(9,Len(DT5->DT5_STATUS)) //-- Solicitacao Cancelada - geracao por agend virtual
					DT5->DT5_DATCAN := dDataBase //-- Cancelamento por geração de agd virtual

                         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                         //³ Grava o campo MEMO                                           ³
                         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                         MSMM(DT5_CODOBC,,,STR0157,1,,,"DT5","DT5_CODOBC") //"Cancelamento automático, conforme agendamento virtual."

					//--Desbloqueia solicitação de coleta e gera documento de coleta(DT6), implementação realizada para Cargolift.
                         TMSA050GDC(DTP->DTP_FILORI,DTP->DTP_LOTNFC)

				ElseIf lContCan
					DT5->DT5_STATUS := StrZero(5,Len(DT5->DT5_STATUS)) //-- Documento Informado
				EndIf
				MsUnlock()
			EndIf
		EndIf

		//-- Ponto de Entrada Gravação Adicional da NF Clientes DTC
		If lTMA050FIM
			ExecBlock("TMA050FIM",.F.,.F., {nOpcx})
		EndIf

		DTP->(MsUnLock())

	End Transaction

	If !lRetTran
		Return(.T.)
	EndIf

	If lViaCol .And. !IsInCallStack("TMSF76VIA") .And. IsInCallStack("TMSAF76")
		TMS050Fecl(nOpcx)
	EndIf

	//-- Atualiza o Documento de Origem - Integração TMS x GFE
	If lTMS3GFE .And. !Empty(M->DTC_NUMSOL)

		TMsAtuGXP(aHeader,aCols,aColsCop,nOpcx,.F.)

	EndIf
Else // Exclusao

	Begin Transaction

		For nX:= 1 To Len(aCols)
			dbSelectArea('DTC')
			dbSetOrder(1)
			If GdFieldGet("DTC_ESTORN",nX)== "1" .And.;
				MsSeek(xFilial('DTC')+M->DTC_FILORI+M->DTC_LOTNFC+M->DTC_CLIREM+M->DTC_LOJREM+;
				M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SERVIC+aCols[nX][nPosCodPro]+aCols[nX][nPosNumNF]+aCols[nX][nPosSerNF])

				If Empty(DTC->DTC_DOC) //--So estorna se a nota nao possuir documento
					nSeekNF := Ascan(aNFs, {|x| x[1]+X[2]+X[3]+X[4] == DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) })
					If nSeekNF == 0
						AAdd(aNFs, {DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_CLIREM, DTC->DTC_LOJREM})
					EndIf
					//-- Vetor contendo doctos excluidos usado no PE TMA050EXC
					AAdd(aNFsExc, {DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO, DTC->DTC_FILORI, DTC->DTC_LOTNFC, DTC->DTC_NFEID})

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna a Nota Fiscal de Entrada                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nSeekNF == 0 .And. !TMSGerNFEnt(5, , , , ,DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_CLIREM, DTC->DTC_LOJREM )
						lRetTran := .F.
						Break
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna o Enderecamento da Nota Fiscal                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DUH->( dbSetOrder( 1 ) )
					If DUH->( MsSeek( cSeek := xFilial("DUH") + cFilAnt + DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM)) )
						Do While !DUH->(Eof()) .And. DUH->(DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM) == cSeek
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza Status do Unitizador(DCO)                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(DUH->DUH_UNITIZ)
								DLGA010Sta(1,DUH->DUH_UNITIZ,DUH->DUH_CODANA,DUH->DUH_LOCAL,DUH->DUH_LOCALI,,,,,.T.)
							EndIf
							RecLock("DUH", .F.)
							DUH->(DbDelete())
							DUH->(MsUnLock())
							DUH->(DbSkip())
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna registro de Peso Cubado (DTE)                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					A050AtuDTE(2,aRatPesM3,aHeaderDTE)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Exclui os registros do DVU (Tipo de Veiculo da Nota Fiscal)                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aColsDVU) > 0
						a050AtuDVU(DTC->DTC_FILORI,DTC->DTC_NUMNFC,DTC->DTC_SERNFC,DTC->DTC_CLIREM,DTC->DTC_LOJREM,"2",aColsCop,nX,nOpcx,DTC->DTC_LOTNFC)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna o campo MEMO                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MSMM(DTC->DTC_CODOBS,,,M->DTC_OBS,2,,,"DTC","DTC_CODOBS")

					MSMM(DTC->DTC_CODDCA,,,M->DTC_DOCANE,2,,,"DTC","DTC_CODDCA")

					RecLock('DTC',.F.,.T.)
					DTC->(dbDelete())
					DTC->(MsUnlock())

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza Status da Cotacao de Frete                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("DT4")
					DbSetOrder(1)
					If !Empty(DTC->DTC_FILCFS)
						cFilDT4 := TMSA050CFS("DT4",DTC->DTC_FILCFS)
						cSeek   := cFilDT4+DTC->DTC_FILCFS+DTC->DTC_NUMCOT
					Else
						cSeek   := cFilDT4+DTC->DTC_FILORI+DTC->DTC_NUMCOT
					EndIf
					If Len(aNFs) > 0 .And. MsSeek(cSeek)
						If DTC->DTC_VLRINF > 0
							//Cancela cotacao
							TmsA040Can(DTC->DTC_FILORI,DTC->DTC_NUMCOT,dDataBase)
							RecLock("DT4",.F.)
							DT4->DT4_CODOBS := MSMM(DT4->DT4_CODOBS,,,STR0158,1,,,"DT4","DT4_CODOBS") //ORDEM DE COTAÇÃO CANCELADA
							MsUnLock()
						Else
							RecLock("DT4",.F.)
							DT4->DT4_STATUS := '3'  //-- Cotacao de Frete Aprovada
							MsUnLock()
						EndIf
					EndIf
				EndIf
			EndIf

		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica Quantidade de Notas Fiscais                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdeNota := 0
		nQtdeCalc := 0
		DTC->(DbSetOrder(1))
		cSeek := xFilial('DTC')+M->DTC_FILORI+M->DTC_LOTNFC

		cAliasDTC := GetNextAlias()
		cQuery := "SELECT DTC_FILIAL,DTC_FILORI,DTC_LOTNFC,DTC_DOC"
		cQuery += " FROM "+RetSqlName("DTC")+ " DTC "
		cQuery += " WHERE DTC_FILIAL = '"+xFilial("DTC")+"'"
		cQuery += "   AND DTC_FILORI = '"+M->DTC_FILORI+"'"
		cQuery += "   AND DTC_LOTNFC = '"+M->DTC_LOTNFC+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)
		While (cAliasDTC)->(!Eof()) .And. (cAliasDTC)->(DTC_FILIAL+DTC_FILORI+DTC_LOTNFC) == cSeek
			nQtdeNota++
			If !Empty((cAliasDTC)->DTC_DOC)
				nQtdeCalc++
			EndIf
			(cAliasDTC)->(DbSkip())
		EndDo
		(cAliasDTC)->(dbCloseArea())
		dbSelectArea("DTC")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o Lote                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("DTP")
		dbSetOrder(2)
		If Len(aNFs) > 0 .And. DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
			RecLock("DTP",.F.)
			DTP->DTP_QTDDIG -= Len(aNFs)
			If DTP->DTP_STATUS == '4' .And. nQtdeNota <> 0
				If nQtdeNota == nQtdeCalc
					DTP->DTP_QTDLOT := nQtdeCalc
					DTP->DTP_STATUS := '3'   //-- Calculado
				Else
					DTP->DTP_QTDLOT -= Len(aNFs)
				EndIf
			Else
				DTP->DTP_STATUS := '1'   //-- Aberto
				If lCamposRat .And. DTP->DTP_QTDDIG == 0
					DTP->DTP_BACRAT := StrZero(1, Len(DTP->DTP_BACRAT)) // 1=Nao Utiliza
					DTP->DTP_CRIRAT := StrZero(1, Len(DTP->DTP_CRIRAT)) // 1=Nao Utiliza
					DTP->DTP_PRORAT := StrZero(1, Len(DTP->DTP_PRORAT)) // 1=Nao Utiliza
					DTP->DTP_ORIRAT := ""
					DTP->DTP_CALRAT := ""
					DTP->DTP_TABRAT := ""
					DTP->DTP_TIPRAT := ""
					DTP->DTP_TBARAT := ""
					DTP->DTP_TPARAT := ""
					If lViaCol .And. !Empty(DTP->DTP_VIACOL)
						DTP->DTP_QTDLOT := 999
					EndIf
					If lCmpRatNew
						DTP->DTP_CRDVFA := ""
						DTP->DTP_CRDVDC := ""
						DTP->DTP_NCONTR := ""
						DTP->DTP_CODNEG := ""
						DTP->DTP_SERVIC := ""
					EndIf
				EndIf
			EndIf
			MsUnLock()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a Conferencia de Coleta                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->DTC_NUMSOL)
			DT5->(dbSetOrder(1))
			If !Empty(M->DTC_FILCFS)
				cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
				cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
			Else
				cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
			EndIf
			If DT5->(MsSeek(cSeek))
				DF6->(DbSetOrder(2))
				If DF6->(MsSeek(xFilial('DF6')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
					lFoundDF6 := .T.
					RecLock('DF6',.F.)
					DF6->DF6_QTDDIG -= Len(aNFs)
					MsUnLock()
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza Nota Fiscal EDI                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSetOrder(1)
		MsSeek(xFilial("SA1")+M->DTC_CLIREM+M->DTC_LOJREM)
		For nX:= 1 To Len(aCols)
			dbSelectArea('DTC')
			dbSetOrder(1)
			If GdFieldGet("DTC_ESTORN",nX)== "1" .And. ;
					!(DbSeek(xFilial('DTC')+M->DTC_FILORI+M->DTC_LOTNFC+M->DTC_CLIREM+M->DTC_LOJREM+;
					M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SERVIC+aCols[nX][nPosCodPro]+aCols[nX][nPosNumNF]+aCols[nX][nPosSerNF]) )
				dbSelectArea("DE5")
				dbSetOrder(2)
				If MsSeek(xFilial("DE5")+"2"+SA1->A1_CGC+aCols[nX][nPosNumNF]+aCols[nX][nPosSerNF])
					RecLock("DE5",.F.)
					DE5->DE5_STATUS := '1'	//Em Aberto
					MsUnLock()
					//-- ponto de entrada de exclusao da nota fiscal EDI
					If lTM050DE5
						ExecBlock("TMS050DE5",.F.,.F.)
					EndIf
				EndIf
			EndIf
		Next nX

		//-- Atualiza o Status da Solicitacao de Coleta
		DT5->(dbSetOrder(1))
		If !Empty(M->DTC_FILCFS)
			cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
			cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
		Else
			cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
		EndIf
		If DT5->(MsSeek(cSeek))
			//-- Retorna o Status do Documento
			cAliasQry  := GetNextAlias()
			cQuery := "SELECT MAX(DUD.R_E_C_N_O_) nRecDUD"
			cQuery += "  FROM " + RetSQLTab('DUD')
			cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial('DUD')  + "' AND "
			cQuery += "       DUD.DUD_FILDOC = '" + DT5->DT5_FILDOC + "' AND "
			cQuery += "       DUD.DUD_DOC    = '" + DT5->DT5_DOC    + "' AND "
			cQuery += "       DUD.DUD_SERIE  = '" + DT5->DT5_SERIE  + "' AND "
			cQuery += "       DUD.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

			If (cAliasQry)->nRecDUD > 0
				DUD->(DbGoto((cAliasQry)->nRecDUD))
				If DUD->DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS)) .Or. lTmsCFec  // Cancelada
					cFilVga    := DUD->DUD_FILORI
					cViagem    := DUD->DUD_VIAGEM
					nRecnoDUD  := (cAliasQry)->nRecDUD
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())

			//-- Verifica se devera ser estornada ocorrencia de coleta automatica
			If lTmsCFec .And. ((!Empty(M->DTC_HORCOL) .And. !Empty(M->DTC_DATCOL) .And. !Empty(cFilVga) .And. !Empty(cViagem)) .Or. (lFoundDF6 .And. DT5->DT5_STATUS == StrZero(5,Len(DT5->DT5_STATUS))))
				lRet := A050EstCFec(DT5->DT5_FILDOC,DT5->DT5_DOC,DT5->DT5_SERIE,cFilVga,cViagem)
			EndIf

			If lRet
				//-- Atualiza o status da Solicitacao.
				DUD->(DbGoto(nRecnoDUD))
				RecLock("DT5",.F.)
				//-- Verifica o Status da Viagem
				If !lFoundDF6
					If Posicione("DTQ",2,xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM,"DTQ_STATUS") == StrZero(1,Len(DTQ->DTQ_STATUS)) //-- Em Aberto
						DT5->DT5_STATUS := StrZero(2,Len(DT5->DT5_STATUS)) //-- Indicado para Coleta
					ElseIf ( DT5->DT5_STATUS <> StrZero(9,Len(DT5->DT5_STATUS)) .And. (DUD->DUD_STATUS == StrZero(1,Len(DUD->DUD_STATUS)) .Or. DUD->DUD_STATUS == StrZero(3,Len(DUD->DUD_STATUS)))) //-- Em Aberto ## Carregado
						DT5->DT5_STATUS := StrZero(2,Len(DT5->DT5_STATUS)) //-- Indicado para Coleta
					ElseIf DUD->DUD_STATUS == StrZero(2,Len(DUD->DUD_STATUS)) //-- Em Transito
						DT5->DT5_STATUS := StrZero(3,Len(DT5->DT5_STATUS)) //-- Em Transito
					ElseIf DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) //-- Encerrado
						DT5->DT5_STATUS := StrZero(4,Len(DT5->DT5_STATUS)) //-- Encerrada
					EndIf
				Else
					DT5->DT5_STATUS := StrZero(7,Len(DT5->DT5_STATUS)) //-- Em Conferencia
				EndIf
				MsUnlock()
			EndIf

			cContrat := Iif(DT5->(ColumnPos('DT5_NCONTR')) > 0, DT5->DT5_NCONTR,'')
			cCodNeg  := DT5->DT5_CODNEG
			cServic  := Iif(DT5->(ColumnPos('DT5_SRVENT')) > 0, DT5->DT5_SRVENT,'')

            cRetSobSer := TmsSobServ('AGEVIR',,.T.,cContrat,cCodNeg,cServic,"0",,.F.)
            If cRetSobSer == "1"
                A050EstDF0(DT5->DT5_FILDOC,DT5->DT5_DOC,DT5->DT5_SERIE)
            EndIf
		EndIf

		//-- Exclui o Documento de Origem - Integração TMS x GFE
		If lTMS3GFE .And. !Empty(M->DTC_NUMSOL)
			TMsAtuGXP(aHeader,aCols,,nOpcx,.T.)
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf

	End Transaction

	If !lRetTran
		Return(.T.)
	EndIf

	//-- Ponto de entrada no estorno dos documentos transporte clientes
	If lTMA050EXC
		ExecBlock("TMA050EXC",.F.,.F., {aNFsExc,lRet})
	EndIf

	If lTMA050END
		ExecBlock("TMA050END",.F.,.F., {nOpcx})
	EndIf
EndIf

RestArea(aAreaDTC)
RestArea(aAreaSA1)
RestArea(aAreaDE5)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050LinOK ³ Autor ³Patricia A. Salomao    ³ Data ³05.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia da Linha digitada.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050LinOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050LinOK()

Local lRet       := .T.
Local nSeek      := 0
Local nCont      := 0
Local cOptPesCub := ''
Local cNumNFC    := GDFieldGet('DTC_NUMNFC', n)
Local cSerNFC    := GDFieldGet('DTC_SERNFC', n)
Local cCodPro    := GDFieldGet('DTC_CODPRO', n)
Local cTipAgd	   := GDFieldGet('DTC_TIPAGD', n)
Local dDatAgd	   := GDFieldGet('DTC_DATAGD', n)
Local cPrdAgd	   := GDFieldGet('DTC_PRDAGD', n)
Local cIniAgd	   := GDFieldGet('DTC_INIAGD', n)
Local cFimAgd	   := GDFieldGet('DTC_FIMAGD', n)

Local lPrdDiv    := GetMV("MV_PRDDIV",,.F.) // Verifica se permitira a inclusao de um ou mais produtos
Local lCamposRat := DTP->(ColumnPos("DTP_RATEIO")) > 0
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local lVlzero    := .F.
l050Auto := If (Type("l050Auto") == "U",.F.,l050Auto)

If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))

	If nVerSubCon == 0	//-- Verifica se a nota é de sub-contratação DECRETO Nº 46.591 UF de MG
		nVerSubCon := 2	//-- Não é sub-contratação DECRETO Nº 46.591 UF de MG (Inicialização)
		If M->DTC_TIPNFC == StrZero(2,Len(DTC->DTC_TIPNFC))
			If Posicione("DUY",1,xFilial("DUY") + M->DTC_CDRORI, "DUY_EST") == "MG" .And. ;
			   Posicione("SA1",1,xFilial("SA1") + M->DTC_CLICON + M->DTC_LOJCON,"A1_CONTRIB") == "1"
				nVerSubCon := 1	//-- É sub-contratação DECRETO Nº 46.591 UF de MG
			EndIf
		EndIf
	EndIf

	nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DTC_NUMNFC')] == cNumNFC ;
	.And. x[GdFieldPos('DTC_SERNFC')] == cSerNFC .And. x[GdFieldPos('DTC_CODPRO')] == cCodPro })
	If	nSeek > 0 .And. nSeek != n
		Help(" ",1,"TMSA05006") //-- Ja foi informado este Numero de Nota Fiscal / Serie / Produto ...
		Return( .F. )
	EndIf

	// Se o parametro estiver configurado para informar 1 produto na Nota Fiscal
	If !lPrdDiv
		nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DTC_CODPRO')] <> cCodPro })
		If nSeek>0 .And. nSeek<>n
			Help('',1,'TMSA05054') //O parametro MV_PRDDIV esta  configurado para informar 1 produto por Nota Fiscal, sendo assim, sera permitido informar sempre o MESMO PRODUTO, para as Notas Fiscais.
			Return( .F. )
		EndIf
	EndIf

	If lAgdEntr .And. ( !Empty(M->DTC_NUMCOT) .Or. IsInCallStack("TMSA144B") .Or. IsInCallStack("TMSA144D"))
		If GdFieldPos('DTC_FIMAGD') .And. GdFieldPos('DTC_INIAGD') .And. GdFieldPos('DTC_PRDAGD')
			nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DTC_TIPAGD')] <> cTipAgd .Or. x[GdFieldPos('DTC_DATAGD')] <> dDatAgd ;
			.Or. x[GdFieldPos('DTC_PRDAGD')] <> cPrdAgd .Or. x[GdFieldPos('DTC_INIAGD')] <> cIniAgd .Or. x[GdFieldPos('DTC_FIMAGD')] <> cFimAgd })
			If nSeek > 0 .And. nSeek != n
				If !Empty(M->DTC_NUMCOT) //--// Se possuir cotação as datas de agendamento de entregas não poderão ser diferentes
					Help('',1,'TMSA05098') // Para NFs associadas a uma cotação não poderá haver dados de agendamento de entregas diferentes.
				Else
					Help('',1,'TMSA05099') // Não é permitido digitar dados de agendamento de entregas diferentes para carga fechada.
				EndIf
				Return( .F. )
			EndIf
		EndIf
	EndIf

	If lAgdEntr .And. (DTP->(ColumnPos("DTP_RATEIO")) > 0)
		DTP->(DbSetOrder(2))
		If DTP->(MsSeek(xFilial("DTP") + M->DTC_FILORI + M->DTC_LOTNFC))
			cRateio := DTP->DTP_RATEIO
			If cRateio == "1"
                If GdFieldPos('DTC_FIMAGD') .And. GdFieldPos('DTC_INIAGD') .And. GdFieldPos('DTC_PRDAGD')
					nSeek := Ascan(aCols,{|x| !x[Len(x)] .And.x[GdFieldPos('DTC_TIPAGD')] <> cTipAgd .Or. x[GdFieldPos('DTC_DATAGD')] <> dDatAgd ;
					.Or. x[GdFieldPos('DTC_PRDAGD')] <> cPrdAgd .Or. x[GdFieldPos('DTC_INIAGD')] <> cIniAgd .Or. x[GdFieldPos('DTC_FIMAGD')] <> cFimAgd })
					If nSeek > 0 .And. nSeek != n
						Help('',1,'TMSA050B4') // Para NFs associadas a um lote de rateio não poderá haver dados de agendamentos de entregas diferentes.
						Return( .F. )
					EndIf
				EndIf
            EndIf
		EndIf
	EndIf
    If GdFieldPos("DTC_NUMAGD") > 0
		For nCont := 1 to Len(aCols)  //-- valida se existem documentos e serie iguais no acols
			If nCont != n .And. cNumNFC == GDFieldGet('DTC_NUMNFC', nCont) .And. cSerNFC == GDFieldGet('DTC_SERNFC', nCont)
				If !Empty(GDFieldGet("DTC_NUMAGD", nCont)) .And. !Empty(GDFieldGet("DTC_ITEAGD", nCont))
					GdFieldPut( "DTC_NUMAGD", GDFieldGet("DTC_NUMAGD", nCont) , n )
					GdFieldPut( "DTC_ITEAGD", GDFieldGet("DTC_ITEAGD", nCont) , n )
				Else
		   			GdFieldPut( "DTC_DATAGD", GDFieldGet("DTC_DATAGD", nCont) , n )
					GdFieldPut( "DTC_INIAGD", GDFieldGet("DTC_INIAGD", nCont) , n )
					GdFieldPut( "DTC_FIMAGD", GDFieldGet("DTC_FIMAGD", nCont) , n )
					GdFieldPut( "DTC_TIPAGD", GDFieldGet("DTC_TIPAGD", nCont) , n )
					GdFieldPut( "DTC_PRDAGD", GDFieldGet("DTC_PRDAGD", nCont) , n )
					GdFieldPut( "DTC_MOTAGD", GDFieldGet("DTC_MOTAGD", nCont) , n )
	           EndIf
			EndIf
		Next

	EndIf
	If Localiza(cCodPro) .And. !Empty(GDFieldGet('DTC_QTDVOL', n)) .And. M->DTC_TIPTRA != '4' //-- Rodoviario Internacional
		nSeek := Ascan(aEndProd,{|x| x[1] == cNumNFC + cSerNFC + cCodPro})
		If nSeek == 0
			Help("",1,"TMSA05010") //-- O Enderecamento da Nota Fiscal nao foi Efetuado ...
			Return( .F. )
		EndIf
	EndIf

	cOptPesCub := A050PesCub(.F.)
	If cOptPesCub == '3' .And. Empty( GdFieldGet('DTC_PESOM3',n) )  // Peso Cubado == Obrigatorio
		Help("",1,'TMSA05037') // E' Obrigatorio Informar o Peso Cubado ... Esta Regra Foi definida no Perfil do Cliente de Calculo
		Return( .F. )
	EndIf

	If cOptPesCub == '4' .And. Empty( GdFieldGet('DTC_METRO3',n) )  // M3 == Obrigatorio
		Help("",1,'TMSA050D3') // Obrigatorio Informar o M3 ... Esta Regra Foi definida no Perfil do Cliente de Calculo
		Return( .F. )
	EndIf

	//--Validação para verificar se o Campo DTC_VALOR está vazio e se é eletronico.
	SB5->(dbSetOrder(1))
	If SB5->(FieldPos('B5_VLZERO')) > 0 .And. DTP->DTP_TIPLOT == '3' .And. SB5->(MsSeek(xFilial("SB5")+GdFieldGet('DTC_CODPRO',n))) .And. ;
		 SB5->B5_VLZERO == StrZero(1,Len(SB5->B5_VLZERO)) .And. !Empty(GdFieldGet('DTC_NFEID',n)) //-- VLZERO = Sim e Contem Chave
		lVlzero := .T. //--Permite Valor Zerado no Cte.
	EndIf

	//--Validação para Documento
	If !Empty(GdFieldGet('DTC_QTDVOL',n)) .And. Empty( GdFieldGet('DTC_VALOR',n) ) .And. !lVlzero
		Help('',1,'TMSA05053') // O Campo Valor esta Vazio
		Return( .F. )
	EndIf

	//-- Validação de campos para Agendamento de Entrega
	If lAgdEntr .And. cTipAgdEnt == '3' .And. GdFieldGet( "DTC_TIPAGD", n ) <> "4"
		If Empty(GdFieldGet('DTC_DATAGD',n))
		   Help('',1,'TMSA05079') // O Campo Data do Agendamento de Entrega esta Vazio
			Return( .F. )
		EndIf
		If Empty(GdFieldGet('DTC_INIAGD',n)) .And. GdFieldGet('DTC_PRDAGD',n) # '2'
		   Help('',1,'TMSA05080') // O Campo Hora do Agendamento de Entrega esta Vazio
			Return( .F. )
		EndIf
		If Empty(GdFieldGet('DTC_FIMAGD',n)) .And. !(GdFieldGet('DTC_PRDAGD',n) $ '1.4')
		   Help('',1,'TMSA05080') // O Campo Hora do Agendamento de Entrega esta Vazio
			Return( .F. )
		EndIf
		If Empty(GdFieldGet('DTC_TIPAGD',n))
		   Help('',1,'TMSA05081') // O Campo Tipo de Agendamento de Entrega esta Vazio
			Return( .F. )
		EndIf
	EndIf

	//-- Se For Rotina Automatica, executar as Funcoes de Peso Cubado e Enderecamento, para avaliar
	//-- se os Dados Passados pela Rotina Automatica estao OK...
	If l050Auto
		If Len(aRatPesM3) > 0 .And. !A050PesoM3()
			Return( .F. )
		EndIf
		If Len(aEndProd) > 0 .And. !A050EndTMS()
			Return( .F. )
		EndIf
	EndIf

	// Validação para DECRETO Nº 46.591 UF de MG
	If nVerSubCon = 1 .And. Empty(GdFieldGet("DTC_FRTSUB",n))
		Help(' ',1,'TMSA05094')	//-- Favor preencher o campo Frete Subcontratação com o valor da subContratação.
		lRet := .F.
	EndIf

	// Validacao para Redespacho Intermediario a chave do CT-e referente a operação anterior deve ser informada.
	If M->DTC_TIPNFC == "9" //--Redespacho Intermediário
		//-- Valida chave do CT-e anterior
		If Empty(GdFieldGet("DTC_CTEANT",n)) .And. Len(AllTrim(GdFieldGet("DTC_CTEANT",n))) < 44
			Help(' ',1,'TMSA05RI02',,STR0173,4,1)	//-- O campo CTe Doc.Ant. é obrigatorio para o tipo de nota fiscal 9-Redespacho Intermediario
			lRet := .F.
		EndIf
		//-- Valida data de emissão do CT-e anterior
		If Empty(GdFieldGet("DTC_DPCEMI",n))
			Help(' ',1,'TMSA05RI03',,STR0174,4,1)	//-- O campo Dt. Doc. Ant é obrigatorio para o tipo de nota fiscal 9-Redespacho Intermediario
			lRet := .F.
		EndIf
		//-- Valida Tipo do Documento Anterior
		If Empty(GdFieldGet("DTC_TIPANT",n))
			Help(' ',1,'TMSA05RI04',,STR0175,4,1)	//-- O campo Tp. Doc.Ant. é obrigatorio para o tipo de nota fiscal 9-Redespacho Intermediario
			lRet := .F.
		EndIf
		
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050TudOK ³ Autor ³Patricia A. Salomao    ³ Data ³05.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia Geral.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050TudOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA050TudOK(nOpcx,oDlg)

Local lRet       := .T.
Local aArea      := GetArea()
Local nTotVolCF  := nTotValCF:=nTotPesCF:=nTotPM3CF:=nTotVolNF:=nTotValNF:=nTotPesNF:=nTotPM3NF:=0
Local nTotPMt3CF := 0
Local nTotPMt3NF := 0
Local aContrat   := {}
Local cDocTMS
Local lOk, nX
Local lAlianca     := TMSAlianca() //-- Utiliza Alianca
Local cOptPesCub   := ''
Local nTotPesM3    := 0
Local cSeek        := ""
Local nOld         := n
Local nKmCF        := 0
Local nKmNF        := 0
Local cFilDT5      := xFilial('DT5')
Local cFilDT4      := xFilial('DT4')
Local cFilDVF      := xFilial('DVF')
Local cCotLot      := ''
Local lVldCot      := .T.
Local lFoundDF6    := .F.
Local lPrdDiv      := GetMV("MV_PRDDIV",,.F.) // Verifica se permitira a inclusao de um ou mais produtos
Local cAliasDTC    := "DTC"
Local cAliasAtu    := ""
Local nTOTAGR      := 0
Local cSeekDTC     := ''
Local cTpFreCsg    := ''
Local cOcorCan     := SuperGetMv('MV_OCORCAN',,'') //-- Ocorrencia de Cancelamento para viagem planejada em aberto
Local lAgdEntr     := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local lConChv 	   := SuperGetMv("MV_CHVNFE",,.F.)
Local lMvTmsCle    := SuperGetMv("MV_TMSCLE",,.F.)
Local cNumNFCAnt   := ""
Local cSerNFCAnt   := ""
Local cOriLotRat   := ""
Local cCalLotRat   := ""
Local nPeso		   := 0
Local lCamposRat   := DTP->(ColumnPos("DTP_RATEIO")) > 0
Local lIdentDoc	  	:= DTC->(ColumnPos("DTC_DOCTMS")) > 0
Local cTABRAT 		:= ""
Local cTIPRAT 		:= ""
Local cTBARAT 		:= ""
Local cTPARAT 		:= ""
Local cBACRAT 		:= ""
Local cCRIRAT 		:= ""
Local cPRORAT 		:= ""
Local lCmpRatNew	:= DTP->(ColumnPos("DTP_CRDVFA")) > 0
Local nAdiDoc		:= 0
Local nCnt1			:= 0
Local cRetSobSer	:= ""
Local cServAnt		:= ""
Local lLoteAuto		:= SuperGetMv("MV_LOTAUT",.F.,.T.)
Local cSerTms		:= ""
Local lAchou		:= .F.
Local lGdItensOk	:= (Type("o1Get") <> "U")
Local aAreaDF1 		:= DF1->(GetArea())

l050Auto := If (Type("l050Auto") == "U",.F.,l050Auto)

lRet:= Obrigatorio(aGets,aTela)

If !lCamposRat
	lRateio:= .F.
EndIf


//-- Valida todas as linhas do aCols e os campos obrigatórios
If lRet .And. (l050Inclui .Or. l050Altera)
	For nX := 1 To Len(aCols)
		n := nX
		If !( lRet := TMSA050LinOK() .And. Iif(lGdItensOk,o1Get:ChkObrigat(n),.T.) )
			Exit
		EndIf
	Next nX
	n := nOld
EndIf

If	lRet .And. (l050Inclui .Or. l050Altera)
	//Validação para verificar se na inclusão da nota via painel de agendamento, no ato da confirmação da nota,
	//verificaremos no contrato do cliente devedor se os campos "bacrat" estão preenchidos, se estiverem, os dados do lote serão atualizados.
	If IsInCallStack("TMSAF76") .And. lLoteAuto .And. DTC->(ColumnPos('DTC_NCONTR')) > 0
		//-- Verifica Se Trata-se De Rateio
		cRetSobSer := TmsSobServ('BACRAT',,.T.,M->DTC_NCONTR,M->DTC_CODNEG,M->DTC_SERVIC,"1",@nAdiDoc)
		If !Empty(cRetSobSer) .And. cRetSobSer <> '1'  //-- '1' = Não Utiliza
			lRateio:= .T.
		EndIf
	EndIf	

	If Empty(M->DTC_NUMSOL) .And. Empty(M->DTC_CLIEXP) .And. M->DTC_SELORI == '3'
		CheckHLP('PTMSA050T3', {'Quando seleção de origem for Local ',' de Coleta, Núm. Solicitação / Expedidor ',' deve ser preenchido. '},{''},{''},.T.)
		Help("",1,"TMSA050T3") //Quando seleção de origem for Local de Coleta, o Núm. da Solicitação / Expedidor deve ser preenchido.
		Return( .F. )
	EndIf

	If lRateio .And. lCopiar
		cServAnt:= M->DTC_SERVIC

		DTP->(DbSetOrder(2))
		If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC)) .And. DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)) //Rateio=Sim
			cTABRAT := DTP->DTP_TABRAT
			cTIPRAT := DTP->DTP_TIPRAT
			cTBARAT := DTP->DTP_TBARAT
			cTPARAT := DTP->DTP_TPARAT
			cBACRAT := Iif( DTP->DTP_BACRAT == StrZero(1, Len(DTP->DTP_BACRAT)), "", DTP->DTP_BACRAT) // 1=Nao Utiliza
			cCRIRAT := Iif( DTP->DTP_CRIRAT == StrZero(1, Len(DTP->DTP_CRIRAT)), "", DTP->DTP_CRIRAT) // 1=Nao Utiliza
			cPRORAT := Iif( DTP->DTP_PRORAT == StrZero(1, Len(DTP->DTP_PRORAT)), "", DTP->DTP_PRORAT) // 1=Nao Utiliza
			If lCmpRatNew
				cCRDVFA := Iif( DTP->DTP_CRDVFA == StrZero(0, Len(DTP->DTP_CRDVFA)), "", DTP->DTP_CRDVFA) // 0=Nao Utiliza
				cCRDVDC := Iif( DTP->DTP_CRDVDC == StrZero(0, Len(DTP->DTP_CRDVDC)), "", DTP->DTP_CRDVDC) // 0=Nao Utiliza
			EndIf
			cORIRAT := DTP->DTP_ORIRAT
			cCALRAT := DTP->DTP_CALRAT
		EndIf
	EndIf

	If Empty(M->DTC_SERVIC)
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,, M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If Len(aContrat) > 0  .And. aContrat[ 1, 21 ]  == StrZero(1, Len(AAM->AAM_SELSER))   // Seleciona Servico == Digitado
			Help("",1,"TMSA05041")  // Informe o Servico ...
			Return( .F. )
		EndIf
	Else
		If Empty(M->DTC_NUMCOT)
			//-- Caso o tipo do servico for 'transporte', tipo de frete 'FOB' e houver contrato 'CIF' para o cliente destinatario,
			//-- perguntar ao usuario se eh uma devolucao parcial.
			If ValType( lSrvDev ) == "U"
				lSrvDev := TmsA050SDv(M->DTC_TIPFRE,M->DTC_CLIDES,M->DTC_LOJDES,M->DTC_SERTMS,M->DTC_TIPTRA,.F.,M->DTC_CLIREM,M->DTC_LOJREM,,M->DTC_CLICAL,M->DTC_LOJCAL,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_CLIDPC,M->DTC_LOJDPC,M->DTC_CODNEG)
			EndIf
			If	lSrvDev
				//-- A entrada de nota fiscal do cliente se refere a uma Devolucao Parcial
				//-- O calculo do frete ira gerar documentos de devolucao das NFC cujo DTC_TIPNFC igual a '1'
				TMSPesqServ( 'DTC', M->DTC_CLIDES, M->DTC_LOJDES, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,;
								.F., StrZero(1,Len(M->DTC_TIPFRE)), .F.,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
								/*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

			Else
				If M->DTC_TIPNFC == StrZero(1,len(DTC->DTC_TIPNFC))

					If M->DTC_DEVFRE == StrZero(1,Len(DTC->DTC_DEVFRE))
						TMSPesqServ('DTC', M->DTC_CLIREM, M->DTC_LOJREM, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,.F.,;
										StrZero(2,Len(M->DTC_TIPFRE)),.F.,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
										/*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

					ElseIf M->DTC_DEVFRE == StrZero(2,Len(DTC->DTC_DEVFRE))
						TMSPesqServ('DTC', M->DTC_CLIDES, M->DTC_LOJDES, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,.F.,;
										StrZero(1,Len(M->DTC_TIPFRE)),.F.,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
										/*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

					ElseIf M->DTC_DEVFRE == StrZero(3,Len(DTC->DTC_DEVFRE))
						TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,.F.,;
										StrZero(1,Len(M->DTC_TIPFRE)),.F.,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
										/*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

					EndIf

				Else
					//--Se for EDI Automático
					If M->DTC_EDI == StrZero(1,len(DTC->DTC_EDI))
						//-- Normal
						TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,.F.,;
										M->DTC_TIPFRE,.F.,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL, /*lPortalTMS*/, lRateio,;
										cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG,,.T./*lEDI*/ )
					Else
						//-- Normal
						TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,.F.,;
										M->DTC_TIPFRE,.F.,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL, /*lPortalTMS*/, lRateio,;
										cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG)
					EndIf
				EndIf
			EndIf

			If Empty(aItContrat)
				Help("",1,"TMSA05042") //Nao foi encontrado servico no contrato do cliente para o servico de transporte e tipo de transporte informados na Nota.
				Return( .F. )
			EndIf

			If lCopiar .And. lRateio .And. DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)) .And. !Empty(cServAnt)  //Rateio
				If Len(aItContrat) == 1 .And. !Empty(M->DTC_SERVIC) .And.  M->DTC_SERVIC <> cServAnt
					M->DTC_SERVIC:= ""
					M->DTC_DESSER:= ""
					Help("",1,"TMSA050D1") //O servico encontrado no contrato do cliente não está configurada para a mesma Tabela de Frete e Criterios de Rateio do Lote.
					Return( .F. )
				EndIf
			EndIf

			nSeek := Ascan(aItContrat, { |x| x[3] == M->DTC_SERVIC })  //Valida novamente se o servico é valido
			If nSeek == 0
				Help("",1,"TMSA05042") //Nao foi encontrado servico no contrato do cliente para o servico de transporte e tipo de transporte informados na Nota.
				Return( .F. )
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando for informado um servico com o campo DC5_SEGPER igual a "1 - Sim", ³
	//³deve-se obrigatoriamente habilitar a digitacao do campo DTC_CDRPER (Cod.  ³
	//³Regiao do 1o percurso).                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DC5->(dbSetOrder(1))
	DC5->(MsSeek(xFilial('DC5') + M->DTC_SERVIC))
	If DC5->DC5_SEGPER == '1' .And. Empty(M->DTC_CDRPER)
		Help('',1,"OBRIGAT2",,RetTitle('DTC_CDRPER'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
		Return( .F. )
	EndIf
EndIf

If	lRet .And. (l050Inclui .Or. l050Altera)
	DVF->(dbSetOrder(1))
	DTC->(dbSetOrder(2))

	//-- Verifica se utiliza cotacao no lote e retorna os valores ja digitados.
	DTP->(DbSetOrder(2))
	If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
		cCotLot := DTP->DTP_NUMCOT
		If lCamposRat
			cOriLotRat := DTP->DTP_ORIRAT
			cCalLotRat := DTP->DTP_CALRAT
		EndIf
	EndIf

	aNFDig := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array que ira conter as Notas Fiscais Informadas.        ³
	//³ Este Array sera utilizado para controlar o no. de Notas  ³
	//³ Fiscais digitadas e a nao conformidade entre os valores  ³
	//³ das Notas fiscais informadas e os valores da Cotacao     ³
	//³ de Frete                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aNFDig :                              ³
	//³ aNFDig[n,1] - No. da Nota / Serie                        ³
	//³ aNFDig[n,2] - Volume                                     ³
	//³ aNFDig[n,3] - Peso                                       ³
	//³ aNFDig[n,4] - Valor                                      ³
	//³ aNFDig[n,5] - Peso Cubado                                ³
	//³ aNFDig[n,6] - Metro Cubico                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOptPesCub := A050PesCub(.F.)

	If !Empty(M->DTC_FILCFS)
		cFilDVF := TMSA050CFS("DVF",M->DTC_FILCFS)
		cSeek   := cFilDVF+M->DTC_FILCFS+M->DTC_NUMCOT
	Else
		cSeek   := cFilDVF+M->DTC_FILORI+M->DTC_NUMCOT
	EndIf

	For nX := 1 To Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			cNumNFC := GdFieldGet('DTC_NUMNFC',nX)
			cSerNFC := GdFieldGet('DTC_SERNFC',nX)
			cCodPro := GdFieldGet('DTC_CODPRO',nX)
			nPeso	 += GDFieldGet('DTC_PESO'  ,nX)
			If lTMA050NFC
				lRet := ExecBlock('TMA050NFC',.F.,.F.,{ M->DTC_FILORI, cNumNFC, cSerNFC, M->DTC_CLIREM, M->DTC_LOJREM, cCodPro })
				If ValType(lRet) == 'L' .And. !lRet
					Return( .F. )
				EndIf
			Else
				If DTC->( MsSeek( cSeekDTC := xFilial('DTC')+ cNumNFC + cSerNFC + M->DTC_CLIREM+M->DTC_LOJREM ))
					Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM ) == cSeekDTC
						If DTC->DTC_FILORI == cFilAnt
							If DTC->DTC_CODPRO == cCodPro
								If GetNewPar( 'MV_TM050NF',.T.) // Verifica se executa a verificação da nota fiscal
									If !l050Altera .Or. (l050Altera .And. DTC->DTC_LOTNFC <> M->DTC_LOTNFC)
										Help("",1,"TMSA05008",,STR0020+ AllTrim(Str(nX)),3,01 ) //-- Nota Fiscal ja Cadastrada ... //'Linha : '
										Return( .F. )
									EndIf
								EndIf
							Else
								If !lPrdDiv
									nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DTC_CODPRO')] <> cCodPro })
									If nSeek>0 .And. nSeek<>n
										Help('',1,'TMSA05054') //O parametro MV_PRDDIV esta  configurado para informar 1 produto por Nota Fiscal, sendo assim, sera permitido informar sempre o MESMO PRODUTO, para as Notas Fiscais.
										Return( .F. )
									EndIf
								EndIf
							EndIf
						EndIf
						DTC->(dbSkip())
					EndDo
				EndIf
                // Verifica o Status da Nota na SEFAZ
				If lMvTmsCle .And. lConChv .And. !Empty(GdFieldGet('DTC_NFEID',nX))
					If cNumNFC+cSerNFC <> cNumNFCAnt+cSerNFCAnt
						lRet:= TMA050SEF(GdFieldGet('DTC_NFEID',nX),cNumNFC,cSerNFC)
						If !lRet
							Return( .F. )
						EndIf
					EndIf
					cNumNFCAnt:= cNumNFC
					cSerNFCAnt:= cSerNFC
				EndIf
			EndIf
			// Se o parametro estiver configurado para informar 1 produto na Nota Fiscal
			If !lPrdDiv .And. nOpcx <> 4
				cAliasAtu := Alias()
				cAliasDTC := GetNextAlias()
				cQuery := "SELECT Count(*) nPrdDiv "
				cQuery += " FROM "+RetSqlName("DTC")+ " DTC "
				cQuery += " WHERE DTC_FILIAL = '"+xFilial("DTC")+"'"
				cQuery += "   AND DTC_FILORI = '"+M->DTC_FILORI+"'"
				cQuery += "   AND DTC_LOTNFC = '"+M->DTC_LOTNFC+"'"
				cQuery += "   AND DTC_CLIREM = '"+M->DTC_CLIREM+"'"
				cQuery += "   AND DTC_LOJREM = '"+M->DTC_LOJREM+"'"
				cQuery += "   AND DTC_CLIDES = '"+M->DTC_CLIDES+"'"
				cQuery += "   AND DTC_LOJDES = '"+M->DTC_LOJDES+"'"
				cQuery += "   AND DTC_FILORI = '"+M->DTC_FILORI+"'"
				cQuery += "   AND DTC_LOTNFC = '"+M->DTC_LOTNFC+"'"
				cQuery += "   AND DTC_CODPRO <>'"+cCodPro+"'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

				If (cAliasDTC)->nPrdDiv > 0
					Help('',1,'TMSA05054') //O parametro MV_PRDDIV esta  configurado para informar 1 produto por Nota Fiscal, sendo assim, sera permitido informar sempre o MESMO PRODUTO, para as Notas Fiscais.
					(cAliasDTC)->(dbCloseArea())
					dbSelectArea(cAliasAtu)
					Return( .F. )
				EndIf

				(cAliasDTC)->(dbCloseArea())
				dbSelectArea(cAliasAtu)
			EndIf

			// Se o parametro estiver configurado para informar 1 produto na Nota Fiscal
			If !lPrdDiv .And. nOpcx = 4
				cAliasAtu := Alias()
				cAliasDTC := GetNextAlias()
				cQuery := "SELECT Count(*) nPrdDiv "
				cQuery += " FROM "+RetSqlName("DTC")+ " DTC "
				cQuery += " WHERE DTC_FILIAL = '"+xFilial("DTC")+"'"
				cQuery += "   AND DTC_FILORI = '"+M->DTC_FILORI+"'"
				cQuery += "   AND DTC_LOTNFC = '"+M->DTC_LOTNFC+"'"
				cQuery += "   AND DTC_CLIREM = '"+M->DTC_CLIREM+"'"
				cQuery += "   AND DTC_LOJREM = '"+M->DTC_LOJREM+"'"
				cQuery += "   AND DTC_CLIDES = '"+M->DTC_CLIDES+"'"
				cQuery += "   AND DTC_LOJDES = '"+M->DTC_LOJDES+"'"
				cQuery += "   AND DTC_FILORI = '"+M->DTC_FILORI+"'"
				cQuery += "   AND DTC_LOTNFC = '"+M->DTC_LOTNFC+"'"
				cQuery += "   AND DTC_CODPRO = '"+cCodPro+"'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

				If (cAliasDTC)->nPrdDiv > 0
					nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DTC_CODPRO')] <> cCodPro })
					If nSeek>0 .And. nSeek<>n
						Help('',1,'TMSA05054') //O parametro MV_PRDDIV esta  configurado para informar 1 produto por Nota Fiscal, sendo assim, sera permitido informar sempre o MESMO PRODUTO, para as Notas Fiscais.
						(cAliasDTC)->(dbCloseArea())
						dbSelectArea(cAliasAtu)
						Return( .F. )
					EndIf
	             EndIf
				(cAliasDTC)->(dbCloseArea())
				dbSelectArea(cAliasAtu)
			EndIf
			If M->DTC_TIPTRA == '4' //-- Rodoviario Internacional
				cAliasAtu := Alias()
				cAliasDTC := GetNextAlias()
				cSeekDTC  := xFilial('DTC')+M->DTC_FILORI+M->DTC_LOTNFC

				cQuery := "SELECT DTC_FILIAL,DTC_FILORI,DTC_LOTNFC,DTC_DOC, DTC_CLIDEV, DTC_LOJDEV"
				cQuery += " FROM "+RetSqlName("DTC")+ " DTC "
				cQuery += "                     WHERE DTC_FILIAL = '"+xFilial("DTC")+"'"
				cQuery += "                       AND DTC_FILORI = '"+M->DTC_FILORI+"'"
				cQuery += "                       AND DTC_LOTNFC = '"+M->DTC_LOTNFC+"'"
				cQuery += "                       AND DTC_CLIREM = '"+M->DTC_CLIREM+"'"
				cQuery += "                       AND DTC_LOJREM = '"+M->DTC_LOJREM+"'"
				cQuery += "                       AND DTC_CLIDES = '"+M->DTC_CLIDES+"'"
				cQuery += "                       AND DTC_LOJDES = '"+M->DTC_LOJDES+"'"
				cQuery += "                       AND DTC_MOEDA  =  "+Str(M->DTC_MOEDA,TamSX3('DTC_MOEDA')[1])
				cQuery += "                       AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

				While (cAliasDTC)->(!Eof()) .And. (cAliasDTC)->(DTC_FILIAL+DTC_FILORI+DTC_LOTNFC) == cSeekDTC
					If (cAliasDTC)->DTC_CLIDEV == M->DTC_CLIDEV .And. (cAliasDTC)->DTC_LOJDEV == M->DTC_LOJDEV
						nTOTAGR++
					EndIf
					(cAliasDTC)->(DbSkip())
				EndDo

				If nTOTAGR > 0
					MsgAlert(STR0077) //"No transporte internacional não é possível informar documentos com remetentes, destinatários, devedores e moedas diferentes!"
					(cAliasDTC)->(dbCloseArea())
					dbSelectArea(cAliasAtu)
					Return( .F. )
				EndIf

				(cAliasDTC)->(dbCloseArea())
				dbSelectArea(cAliasAtu)
			EndIf

			If !Empty(M->DTC_NUMCOT) .And. DVF->(MsSeek(cSeek))
				lRet := .F.
				Do While !DVF->(Eof()) .And. DVF->DVF_FILIAL+DVF->DVF_FILORI+DVF->DVF_NUMCOT==cSeek
					If DVF->DVF_CODPRO == cCodPro
						lRet:=.T.
						Exit
					EndIf
					DVF->(dbSkip())
				EndDo
				If !lRet
					//-- Ponto de entrada para Validar Produto da Cotacao x Produto da NF
					If lTMA050PCO
						lRet := ExecBlock("TMA050PCO",.F.,.F., {M->DTC_CLIREM, M->DTC_LOJREM, cNumNFC, cSerNFC, cCodPro, M->DTC_NUMCOT, "2" }) // "2" - Indica Execucao do P.E pela funcao TMSA050TudOK

						If ValType(lRet) != 'L'
							lRet := .F.
						EndIf
					EndIf

					If !lRet
						Help('',1,'TMSA05055',,cCodPro + '(' + STR0020 + AllTrim(Str(nX)) + ')' ,3,01) // Este Produto nao pertence a Cotacao de Frete Informada" ### "Linha:
						Return( .F. )
					EndIf
				EndIf
			EndIf

			nSeek := Ascan(aNFDig, {|x| x[1] == cNumNFC + cSerNFC } )
			If nSeek == 0
				AAdd(aNFDig,{cNumNFC+cSerNFC,GDFieldGet('DTC_QTDVOL',nX),;
				GDFieldGet('DTC_PESO',nX), GDFieldGet('DTC_VALOR',nX), GDFieldGet('DTC_PESOM3',nX), GDFieldGet('DTC_METRO3',nX) } )
			Else
				aNFDig[nSeek][2] += GDFieldGet('DTC_QTDVOL',nX)
				aNFDig[nSeek][3] += GDFieldGet('DTC_PESO'  ,nX)
				aNFDig[nSeek][4] += GDFieldGet('DTC_VALOR' ,nX)
				aNFDig[nSeek][5] += GDFieldGet('DTC_PESOM3',nX)
				aNFDig[nSeek][6] += GDFieldGet('DTC_METRO3',nX)
			EndIf
		EndIf
		If cOptPesCub == '4' // Metro Cubico
			nTotPesM3 += GdFieldGet('DTC_METRO3',nX)
		EndIf
		//-- Valida Agendamento de Entrega
		If lRet
			If lAgdEntr .And. DTC->(ColumnPos("DTC_NUMAGD"))>0  //Verifica se existem os campos para Agendamento de Entrega
				DUL->(DbSetOrder(2))
				If !Empty(M->DTC_SQEDES)	.And. DUL->(MsSeek( xFilial('DUL') + M->DTC_CLIDES + M->DTC_LOJDES + M->DTC_SQEDES ));
					.And. !Empty(DUL->DUL_CODRED) .And. !Empty(DUL->DUL_LOJRED)
					cTipAgdEnt := TMS050AGD( DUL->DUL_CODRED, DUL->DUL_LOJRED)
				Else
					cTipAgdEnt := TMS050AGD( M->DTC_CLIDES, M->DTC_LOJDES)
				EndIf

				If cTipAgdEnt == "3" .And. GdFieldGet( "DTC_TIPAGD", n ) <> "4"
					If Empty( GdFieldGet( "DTC_DATAGD", nX ) ) .Or.;
					  ( Empty( GdFieldGet( "DTC_INIAGD", nX ) ) .AND. Empty( GdFieldGet( "DTC_FIMAGD", nX ) ) ).Or.;
					   Empty( GdFieldGet( "DTC_TIPAGD", nX ) ) .Or.;
					   Empty( GdFieldGet( "DTC_PRDAGD", nX ) )

						Help("",1,'TMSA05082') // Preenchimento Obrigatório para Agendamento de Entrega
						Return( .F. )
					EndIf
				ElseIf cTipAgdEnt == "2"
					GdFieldPut( "DTC_DATAGD", Ctod( "" )                    , nX )
					GdFieldPut( "DTC_INIAGD", Space(TamSX3("DTC_INIAGD")[1]), nX )
					GdFieldPut( "DTC_FIMAGD", Space(TamSX3("DTC_FIMAGD")[1]), nX )
					GdFieldPut( "DTC_TIPAGD", "1"                           , nX )
					GdFieldPut( "DTC_PRDAGD", Space(TamSX3("DTC_PRDAGD")[1]), nX )
					GdFieldPut( "DTC_MOTAGD", ""                            , nX )
					GdFieldPut( "DTC_MOTAGD", ""                            , nX )
				EndIf
			EndIf
		EndIf
	Next nX

	If lRet .And. lTmsCFec .And. !Empty(M->DTC_HORCOL) .And. !Empty(M->DTC_DATCOL) .And. nPeso = 0
		Help("",1,'TMSA050A2') // Para o apontamento de ocorrência da coleta, e obrigatório informar o peso !!
		Return( .F. )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa se existe ajuste para o remetente, se nao existir ajuste utiliza    ³
	//³o consignatario como calculo portanto precisa ser preechido obrigatoriamente ³
	//|Alianca (de segundo percurso)                                                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lAlianca .And. TmsA050Dpc()
		aContrat := TMSContrat(M->DTC_CLIREM,M->DTC_LOJREM,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If Len(aContrat) > 0
			DVC->(DbSetOrder(2))
			If DVC->(!MsSeek(xFilial("DVC")+M->DTC_CLIREM+M->DTC_LOJREM+aContrat[1,3]+aContrat[1,4]))
				If Empty(M->DTC_CLIDPC + M->DTC_LOJDPC)
					Help("",1,"TMSA05057") //Para Conhecimento de alianca segundo percurso o despachante e usado para calculo
					Return( .F. )
				EndIf
			EndIf
		EndIf
	EndIf

	If M->DTC_CDRDES == M->DTC_CDRPER
		Help("",1,"TMSA05032") // A Regiao Destino Nao pode Ser Igual a Regiao de 1o. Percurso
		Return( .F. )
	EndIf

	//--Devedor Outros so pode ser utilizado para o Transporte Internacional
	If M->DTC_DEVFRE == '5' .And. M->DTC_TIPTRA != '4'
		MsgAlert(STR0078) //--"Nao e permitido utilizar o devedor outros para este tipo de transporte"
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a regiao informada e' de Origem /Destino /Ambas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TmsTipReg( M->DTC_CDRDES, StrZero( 2, Len( DTN->DTN_TIPREG ) ) )
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Origem esta habilitada para o Servico de Transporte ³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRORI )
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRDES )
		Return( .F. )
	EndIf

	If M->DTC_CDRDES == M->DTC_CDRPER
		Help("",1,"TMSA05032") // A Regiao Destino Nao pode Ser Igual a Regiao de 1o. Percurso
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao Gravar a Nota Fiscal se Encontrar Regra para Pagadores do Frete e o   ³
	//³Pagador do Frete (DTJ_PAGFRE)  for igual a "6" (Bloqueada Digitacao)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TMSA050Dev(,.T.,.T.)
		Return( .F. )
	EndIf

	If M->DTC_TIPNFC == StrZero(1,Len(DTC->DTC_TIPNFC)) .And. DC5->DC5_SEGPER == StrZero(1,Len(DC5->DC5_SEGPER))
		Help(' ',1,'TMSA05062',,'Servico: '+M->DTC_SERVIC,4,11)		//-- Na devolucao Seg.Percurso deve estar igual a 'Nao'
		Return( .F. )
	EndIf

	DTP->(dbSetOrder(2))
	If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC)) .And. DTP->DTP_QTDDIG+Len(aNFDig)-nQtdNfAnt > DTP->DTP_QTDLOT
		If !IsIncallStack('TMSAF76')
			Help("",1,"TMSA05004") //--  O No. de Notas Informadas ultrapassou a qtde. de Notas permitidas para o Lote
			Return( .F. )
		Else
			Tmsa050RLt(DTP->DTP_FILORI,DTP->DTP_LOTNFC)
		EndIf

	EndIf

	If !IsInCallStack("TMSAE75") .And. M->DTC_CDRDES != M->DTC_CDRCAL .And. Empty(M->DTC_OBS)
		Help("",1,"TMSA05044") // Quando a regiao de destino for diferente da regiao de calculo a observacao deve ser informada.
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³As Variaveis cNumLotUso, cCliRemUso, cLojRemUso e cNumSolic, possibilitam       ³
	//³manter o numero do ultimo Lote, o Cliente e Loja do Remetente e o numero da     ³
	//³Solicitacao de Coleta que o usuario informou na entrada de nota fiscal,         ³
	//³enquanto o Lote estiver com Status em aberto.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l050Inclui
		cNumLotUso := M->DTC_LOTNFC
		cNumSolic  := M->DTC_NUMSOL
		If lTmsGRem
			cCliRemUso := M->DTC_CLIREM
			cLojRemUso := M->DTC_LOJREM
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totaliza o Volume, Peso, Valor e PesoM3 informados nas Notas Fiscais  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aNFDig)
		nTotVolNF  += aNFDig[nX][2] //-- Volume
		nTotPesNF  += aNFDig[nX][3] //-- Peso
		nTotValNF  += aNFDig[nX][4] //-- Valor
		nTotPM3NF  += aNFDig[nX][5] //-- Peso Cubado
		nTotPMt3NF += aNFDig[nX][6] //-- Metro Cubico
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna a quilometragem informada na cotacao.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DT4")
	DbSetOrder(1)
	If !Empty(M->DTC_FILCFS)
		cFilDT4 := TMSA050CFS("DT4",M->DTC_FILCFS)
		cSeek   := cFilDT4+M->DTC_FILCFS+Iif(!Empty(cCotLot),cCotLot,M->DTC_NUMCOT)
	Else
		cSeek   := cFilDT4+M->DTC_FILORI+Iif(!Empty(cCotLot),cCotLot,M->DTC_NUMCOT)
	EndIf
	If DT4->(MsSeek(cSeek))
		nKmCF := DT4->DT4_KM
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se foi informada Cotacao de Frete, verifica se os        ³
	//³ valores informados na Nota Fiscal sao iguais aos da CF.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DVF")
	DbSetOrder(1)
	If !Empty(M->DTC_FILCFS)
		cFilDVF := TMSA050CFS("DVF",M->DTC_FILCFS)
		cSeek   := cFilDVF+M->DTC_FILCFS+Iif(!Empty(cCotLot),cCotLot,M->DTC_NUMCOT)
	Else
		cSeek   := cFilDVF+M->DTC_FILORI+Iif(!Empty(cCotLot),cCotLot,M->DTC_NUMCOT)
	EndIf
	If DVF->(MsSeek(cSeek))
		Do While !DVF->(Eof()) .And. DVF->(DVF_FILIAL+DVF_FILORI+DVF_NUMCOT) == cSeek
			If Empty(cCotLot)
				If Ascan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DTC_CODPRO')] == DVF->DVF_CODPRO }) == 0
					If !MsgYesNo( STR0044 + AllTrim(DVF->DVF_CODPRO) + STR0045 + DVF->DVF_NUMCOT + STR0046) //"O Produto" ### "da Cotacao de Frete" ### "nao foi informado nesta Nota Fiscal. Continua ?"
						Return( .F. )
					EndIf
				EndIf
			EndIf
			nTotVolCF += DVF->DVF_QTDVOL
			nTotValCF += DVF->DVF_VALMER
			nTotPesCF += DVF->DVF_PESO
			nTotPM3CF += DVF->DVF_PESOM3
			nTotPMt3CF += DVF->DVF_METRO3
			DVF->(dbSkip())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna a quilometragem informada na cotacao.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nKmNF := M->DTC_KM
		//-- Verifica se utiliza cotacao no lote e retorna os valores ja digitados.
		If !Empty(cCotLot)
			DTP->(DbSetOrder(2))
			If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
				nQtdDig := Len(aNFDig) + DTP->DTP_QTDDIG - nQtdNfAnt
				lVldCot := .F.
				If nQtdDig == DTP->DTP_QTDLOT
					lVldCot := .T.
					TM050ValNF(@nTotVolNF,@nTotPesNF,@nTotValNF,@nTotPM3NF,@nTotPMt3NF,@nKmNF,M->DTC_FILORI,M->DTC_LOTNFC)
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³antes da comparação da cotação com as informações dos documentos do cliente informados no lote,	³
		//³permitindo definir se executa comparação e exibe mensagem em seguida								³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	lVldCot .And. lTM050VCT
			lVldCot := ExecBlock("TM050VCT",.F.,.F.,{nTotVolNF, nTotValNF, nTotPesNF, nTotPM3NF, nKmNF, nTotPMt3NF, cSeek})
			If ValType(lVldCot) <> "L"
				lVldCot := .T.
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a Totalizacao dos Valores da NF nao bater com a Totalizacao³
		//³dos Valores da Cotacao de Frete                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lVldCot .And. (	nTotVolCF<>nTotVolNF .Or. nTotValCF<>nTotValNF .Or. nTotPesCF<>nTotPesNF .Or. ;
							nTotPM3CF<>nTotPM3NF .Or. nKmCF <> nKmNF       .Or. nTotPMt3CF<>nTotPMt3NF )
			If lTMA050COT
				lRet := ExecBlock("TMA050COT",.F.,.F.,{lRet,nTotVolCF,nTotVolNF,nTotValCF,nTotValNF,nTotPesCF,nTotPesNF,nTotPM3CF,nTotPM3NF,nKmCF,nKmNF})
				If Valtype(lRet) <> "L"
					If l050Auto
						Help("",1,"TMSA05085") //"A somatoria dos valores de volume, peso, quilometragem ou valor do documento estão diferentes dos valores informados na cotação de Frete"
					Else
						lRet := Aviso( STR0009 , STR0047 ,{STR0048,STR0049}, 2) == 1 //"Atencao"###"A somatoria dos valores de volume, peso, quilometragem ou valor do documento estão diferentes dos valores informados na cotação de Frete"###"Confirma"###"Redigita"
					EndIf
				EndIf
			Else
				If l050Auto
					Help("",1,"TMSA05085") //"A somatoria dos valores de volume, peso, quilometragem ou valor do documento estão diferentes dos valores informados na cotação de Frete"
				Else
					lRet := Aviso( STR0009 , STR0047 ,{STR0048,STR0049}, 2) == 1 //"Atencao"###"A somatoria dos valores de volume, peso, quilometragem ou valor do documento estão diferentes dos valores informados na cotação de Frete"###"Confirma"###"Redigita"
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Verifica se o destino eh alianca e torna o preenchimento do campo Alianca Obrigatorio
	If lRet .And. lAlianca
		If Empty(M->DTC_ALIANC)
			cFilDes := Posicione("DUY",1,xFilial("DUY")+M->DTC_CDRDES,"DUY_FILDES")
			If !Empty(cFilDes)
				DVL->(DbSetOrder(1))
				If DVL->(MsSeek(xFilial("DVL")+cFilDes))
					Help(" ",1,"TMSA05031") //-- Para regiao destino atendida somente pelos parceiros, devera ser preenchido o campo Alianca.
					lRet := .F.
				EndIf
			Else
				DVK->(DbSetOrder(1))
				If DVK->(MsSeek(xFilial("DVK")+M->DTC_CDRDES))
					Help(" ",1,"TMSA05031") //-- Para regiao destino atendida somente pelos parceiros, devera ser preenchido o campo Alianca.
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Qdo a Solicitacao nao estiver encerrada, obriga o preenchimento dos campos Data e Hora da Coleta.
	DT5->(dbSetOrder(1))
	If !Empty(M->DTC_FILCFS)
		cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
		cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
	Else
		cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
	EndIf
	If DT5->(MsSeek(cSeek))
		DF6->(DbSetOrder(2))
		If DF6->(MsSeek(xFilial('DF6')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
			lFoundDF6 := .T.
		Else
			lFoundDF6 := .F.
		EndIf
	EndIf

	//-- Qdo a Solicitacao nao estiver encerrada, obriga o preenchimento dos campos Data e Hora da Coleta.
	DT5->(dbSetOrder(1))
	If !Empty(M->DTC_FILCFS)
		cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
		cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
	Else
		cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
	EndIf
	If lRet .And. lTmsCFec .And. DT5->(MsSeek(cSeek)) .And. DT5->DT5_STATUS <> StrZero(4, Len(DT5->DT5_STATUS)) .And. DT5->DT5_STATUS <> StrZero(5, Len(DT5->DT5_STATUS)) //-- Encerrada ou documento informado.
		If !lFoundDF6
			If Empty(M->DTC_DATCOL)
				Help('',1,"OBRIGAT2",,RetTitle('DTC_DATCOL'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
				lRet := .F.
			EndIf
			If Empty(M->DTC_HORCOL)
				Help('',1,"OBRIGAT2",,RetTitle('DTC_HORCOL'),04,01) ////Um ou alguns campos obrigatorios nao foram preenchidos no Browse
				lRet := .F.
			EndIf
			If lRet
				If (Dtos(M->DTC_DATCOL)+M->DTC_HORCOL) > (Dtos(dDataBase)+Substr(strtran(time(), ":",""),1,4)) .Or. ;
				  (!Empty(M->DTC_DTENTR) .And. (Dtos(M->DTC_DTENTR)+M->DTC_HORENT) > (Dtos(dDataBase)+Substr(strtran(time(), ":",""),1,4)) )
					Aviso("Atenção","A data e hora informada da coleta/entrega não podem ser maior que a data e hora atual.",{"Ok"})
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If (lRet .And. lTmsCFec .And. !Empty(M->DTC_NUMSOL) .And. !Empty(M->DTC_DATCOL) .And. Empty(cOcorCol)) .Or. ;
		(lRet .And. lFoundDF6)
		lRet := A050ApoCol() //Determina o codigo da ocorrencia para o apontamento automatico da coleta.
	EndIf

	If lRet .And. Empty(M->DTC_NUMSOL) .And. Empty(M->DTC_NUMCOT)
		M->DTC_FILCFS := Space(Len(DTC->DTC_FILCFS))
	EndIf

	//-- Verificar informacoes do transporte internacional
	If lRet .And. M->DTC_TIPTRA == StrZero(4,Len(DTC->DTC_TIPTRA)) //-- Rodoviario Internacional
		If Empty(M->DTC_INCOTE)
			MsgAlert(STR0074) //-- "Informe o Incoterm..."
			lRet := .F.
		ElseIf Empty(M->DTC_ROTA)
			MsgAlert(STR0075) //-- "Informe a Rota..."
			lRet := .F.
		EndIf
	EndIf

	//--Se existir veiculos informados na cotacao/agendamento e
	//--nao for confirmados na nota fiscal, informar ao usuario
	If lRet .And. !Empty(M->DTC_NUMSOL)
		If !Empty(M->DTC_FILCFS)
			cSeek:=TMSA050CFS("DVT",M->DTC_FILCFS)+M->DTC_FILCFS+M->DTC_NUMSOL+M->DTC_NUMCOT+StrZero(1,Len(DVT->DVT_ORIGEM))
		Else
			cSeek:=xFilial("DVT")+M->DTC_FILORI+M->DTC_NUMSOL+M->DTC_NUMCOT+StrZero(1,Len(DVT->DVT_ORIGEM))
		EndIf
		DVT->(DbSetOrder(1))
		If DVT->(DbSeek(cSeek)) .And. Len(aColsDVU) == 0
			lRet := MsgYesNo(STR0073) //--"Existem veículos associados a solicitação de coleta que não foram confirmados na digitação do documento do cliente para transporte. Continua?"
		EndIf
	EndIf

	If lRet .And. !Empty(DTP->DTP_NUMCOT)
		DT4->(DbSetOrder(1))
		If DT4->(MsSeek(xFilial('DT4')+DTP->DTP_FILORI+DTP->DTP_NUMCOT))
			If DT4->DT4_SELORI <> M->DTC_SELORI
				If !MsgNoYes(STR0081) //A Seleção de Origem está diferente diferente da Cotação de Frete. Confirma ?
					lRet:=.F.
				Else
					MsgAlert(STR0082)
				EndIf
			EndIf
		EndIf
	EndIf
	//-- Nao permitir informar ocorrencias de Encerra Processo para viagens em Aberto
	If lRet .And. !Empty(M->DTC_NUMSOL)

		DT2->(dbSetOrder(1))
		DT2->(MsSeek(xFilial('DT2')+cOcorCol))

		DT5->(dbSetOrder(1))

        cFilDT5 := XFilial("DT5")
				
        If !Empty(M->DTC_FILCFS)
			cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
			cSeek := cFilDT5 + M->DTC_FILCFS + M->DTC_NUMSOL
		Else
			cSeek := cFilDT5 + M->DTC_FILORI + M->DTC_NUMSOL
		EndIf

		DT5->(MsSeek(cSeek))

		DUD->(dbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
		DUD->(MsSeek(xFilial('DUD')+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))

		DTQ->(dbSetOrder(1))
		DTQ->(MsSeek(xFilial('DTQ')+DUD->DUD_VIAGEM))

		If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .Or. ; //-- Em Aberto
			DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS)) .And.; //-- Fechada
			DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))

				//Verifica dados da Ocorrencia do parametro MV_OCORCAN
				lRet:= .F.
				DT2->(dbSetOrder(1))
				If DT2->(MsSeek(xFilial('DT2')+cOcorCan))
					If !Empty(DT2->DT2_SERTMS)
						If	DT2->DT2_SERTMS == StrZero(1, Len(DT2->DT2_SERTMS)) .And. ; //Servico Coleta
							DT2->DT2_TIPOCO == StrZero(12,Len(DT2->DT2_TIPOCO))         //Ocorrencia tipo Cancelamento
							lOcorCan:= .T.
							lRet    := .T.
						EndIf
					Else
						//O serviço adicional permite DT2_SERTMS em branco
						DbSelectArea("DT6")
						DbSetOrder(1) //Filial+Fil.Doc+Num.Doc+Serie Doc
						If MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE)
							cSerTms := DT6->DT6_SERTMS
							lAchou := .T.
						Endif
						If	lAchou .AND. cSerTms == StrZero(1, Len(DT2->DT2_SERTMS)) .And. ; //Servico Coleta
							DT2->DT2_TIPOCO == StrZero(12,Len(DT2->DT2_TIPOCO))         //Ocorrencia tipo Cancelamento
							lOcorCan:= .T.
							lRet    := .T.
						EndIf
					Endif
				EndIf

				If !lRet
					Help(' ', 1, 'TMSA360A6')  //Viagem de coleta está com status em aberto ou fechada, ajuste o status da coleta ou preencha o parâmetro MV_OCORCAN.
					Return( lRet )
				EndIf
		EndIf

		If !lRet
			If Empty(DT2->DT2_SERTMS) //O serviço adicional permite DT2_SERTMS em branco
					DbSelectArea("DT6")
					DbSetOrder(1) //Filial+Fil.Doc+Num.Doc+Serie Doc
					If MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE)
						cSerTms := DT6->DT6_SERTMS
						lAchou := .T.
					Endif
			Else
				cSerTms := DT2->DT2_SERTMS
			Endif
			If	 DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))   .And. ;  //Viagem com Status em aberto
				(cSerTms == StrZero(3, Len(DT2->DT2_SERTMS))  .Or. ;  //servico entrega
				 cSerTms == StrZero(1, Len(DT2->DT2_SERTMS))) .And. ;  //servico Coleta
				 DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO ))           //Ocorrencia tipo encerra processo
				Help(' ', 1, 'TMSA36098')  //-- Para o tipo de ocorrencia encerra processo a viagem nao podera estar em aberto
				lRet := .F.
			EndIf
		EndIf
	EndIf

	// Obriga que o campo DTC_FILCFS seja informado caso o campo DTC_NUMSOL esteja preenchido.
	If lRet .And. !Empty(M->DTC_NUMSOL)
	   If Empty(M->DTC_FILCFS)
			Help("",1,"TMSA050D0")  //"Filial de emissão da Solicitação de Coleta não informado."
 			Return( .F. )
	   EndIf
	EndIf

EndIf
If lRet .And. (l050Inclui .Or. l050Altera)
	aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)

	// Sendo um Lote de Rateio e Base de Rateio do tipo CONSOLIDADO ou PONTO A PONTO com criteio "Origem/Destino" a Origem e Destino do Consolidado devem estar preenchidos //
	If lRateio .And. ((aContrat[Len(aContrat)][42] == "3" .And. aContrat[Len(aContrat)][41] != "A") .Or. (aContrat[Len(aContrat)][42] == "2" .And. aContrat[Len(aContrat)][41] == "2" ))
		If ( Empty(M->DTC_ORIRAT) .Or. Empty(M->DTC_CALRAT) )
			Help("",1,"TMSA05095")//-- Obrigatorio o informe da Origem e Destino de Rateio !
			lRet := .F.
		Else
			If !Empty(cOriLotRat) .And. (M->DTC_ORIRAT <> cOriLotRat .Or. M->DTC_CALRAT <> cCalLotRat)
				Help("",1,"TMSA050A0",,RetTitle('DTC_ORIRAT') + ': ' + M->DTC_ORIRAT + ' / ' + RetTitle('DTC_CALRAT') + ': ' + M->DTC_CALRAT,4,0)		//--Obrigatorio informar mesma Origem e Destino de Rateio do Lote
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. (l050Inclui .Or. l050Altera)
	//-- Verifica se o Tipo de Frete foi informado
	If Empty(M->DTC_TIPFRE)
		Help(' ',1,'TMSA050A4')	//-- Não é permitido que o tipo de frete fique em branco.
		lRet := .T.
	EndIf
	//-- Verifica se o codigo da negociacao foi informado
	If lRet .And. Empty(M->DTC_CODNEG)
		Help(' ',1,'TMSA050A3')	//-- Não é permitido que o código da negociação fique em branco.
		lRet := .F.
	EndIf
	//-- Verifica se o servico foi informado
	If lRet .And. Empty(M->DTC_SERVIC)
		If Len(aContrat) > 0  .And. aContrat[ 1, 21 ]  == StrZero(1, Len(AAM->AAM_SELSER))   // Seleciona Servico == Digitado
			Help(' ',1,'TMSA050A5')	//-- Não é permitido que o serviço fique em branco.
			lRet := .F.
		EndIf
	EndIf
EndIf

//-- Valida se o campo DTC_SERTMS possui o mesmo conteúdo de DTQ_SERTMS
If lRet
	lRet	:= A050VldDTP('M->DTC_SERTMS')
EndIf

If	lRet
	//-- Executa ponto de entrada
	If	lPeTm050TOk
		lRet := ExecBlock('TM050TOK',.F.,.F.,{nOpcx,oDlg, aRatPesM3, aValInf})
	EndIf
EndIf

If lRet
	If lTM050PES
		lRet := ExecBlock('TM050PES',.F.,.F.,{nTotPesNF})
	EndIf
EndIf

If lRet .And. lIdentDoc .And. (lCopiar .Or. l050Altera)
	aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
	If Len(aContrat) > 0  .And. aContrat[ 1, 21 ]  != StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
		// Verifica novamente o tipo do documento caso a região de calculo seja alterada
		DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
		DC5->(MsSeek(xFilial("DC5")+ M->DTC_SERVIC))
		If lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
			M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
			If !Empty(M->DTC_DOCTMS)
				M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
			EndIf
		EndIf
		If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
			DUI->( DbSetOrder( 1 ) )
			If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
				Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
				lRet := .F.
				M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
				M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
			EndIf
		EndIf
	EndIf
EndIf
//Validação para não permitir incluir Notas Fiscais vinculadas a solicitação de coleta onde a viagem de coleta nao estiver encerrada.
// desde que no serviço do contrato do cliente, possuir uma tabela de frete com o componente de frete do tipo herda valor.
If lRet .And. (isInCallStack("tmsa144d") .Or. isInCallStack("tmsaf76")) .And. M->DTC_SERTMS == StrZero(3, Len(DTC->DTC_SERTMS)) .And. !Empty(M->DTC_NUMSOL) .And. DUX->(ColumnPos("DUX_CRDVDC")) > 0 ;
    .And. DTC->(ColumnPos('DTC_NCONTR')) > 0
	If FindFunction('TmsRetViag')
		lRet := TmsRetViag(M->DTC_NUMSOL,M->DTC_NCONTR,M->DTC_SERVIC,M->DTC_CODNEG)
	EndIf
EndIf

/*// Reavaliar essa validação, pois obriga informa a data de entrega sem ter documento entregue.
If lRet
	DF1->(DbSetOrder(3))
	If DF1->(DbSeek(xFilial("DF1") + M->(DTC_FILCFS + DTC_NUMSOL + "COL")))
		If TmsSobServ("TIPOPE",,.T.,DF1->DF1_NCONTR,DF1->DF1_CODNEG,DF1->DF1_SRVCOL,"0") == "2"
			If Empty(M->DTC_DTENTR)
				Help("",1,"OBRIGAT2",,RetTitle("DTC_DTENTR"),04,01)
				lRet := .F.
			ElseIf Empty(M->DTC_HORENT)
				Help("",1,"OBRIGAT2",,RetTitle("DTC_HORENT"),04,01)
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
*/

If lRet
	lSrvDev := Nil
EndIf

RestArea(aAreaDF1)
RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SeleItCF  ³ Autor ³Patricia A. Salomao    ³ Data ³04.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Permite Selecao da Cotacao de Frete.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SeleItCF()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial de Origem                                    ³±±
±±³          ³ExpC2 - Numero da Cotacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleItCF(cFilOri,cNumCot)

Local aArea    		:= GetArea()
Local cSertms  		:= ""
Local cSeek    		:= ""
Local cFilDT5  		:= xFilial('DT5')
Local lSinc    		:= TmsSinc() //-- Chamada do Sincroizador
Local lRet     		:= .T.
Local lTmA050Cta	:= ExistBlock("TMA050CTA")
Local lTmA050SEL	:= ExistBlock("TMA050SEL")
Local lRetCot		:= .F.
Local lIdentDoc  	:= DTC->(ColumnPos("DTC_DOCTMS")) > 0

Default cFilOri:= ""
Default cNumCot:= ""

l050Auto := If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

lRetCot  := !l050Auto

If lRetCot
	If lRateio
		lRetCot := .F.
	EndIf
EndIf
//-- Limpa variaveis de memoria, preenchidas pela Cotacao
If !l050Auto .And. !Empty(M->DTC_NUMCOT) .And. !lCotacao
	TMSA050Clear()
EndIf

//-- Apresenta Tela contendo as Cotacoes de Frete Aprovadas
If lRetCot
	lRetCot := .F.

	If !Empty(cFilOri) .And. !Empty(cNumCot)
		lRet := .F.
		DT4->(DbSetOrder(1))
		If DT4->(MsSeek(xFilial('DT4')+cFilOri+cNumCot))
			If DT4->DT4_STATUS <> StrZero(3, Len(DT4->DT4_STATUS))
				M->DTC_NUMSOL := CriaVar('DTC_NUMSOL',.F.)
				Help('',1,'TMSA05059') 	// A Cotacao de Frete vinculada a esta solicitacao de Coleta, nao esta aprovada.
				Return( .F. )
			EndIf
			lRet := .T.
		EndIf
	Else
		//-- Ponto de entrada para inibir a tela de "Cotações Realizadas"
		If lTmA050Cta
			lRetCot := ExecBlock("TMA050CTA",.F.,.F.,)
			If (ValType(lRetCot)=="L")
				lRet := lRetCot
			EndIf
		EndIf
		If lRet
			lRet := TMSA050Cot()
		EndIf
	EndIf

	If lRet
		M->DTC_NUMCOT := DT4->DT4_NUMCOT
		cSertms := Posicione('DC5',1,xFilial('DC5') + DT4->DT4_SERVIC,'DC5_SERTMS')
		If	cSertms <> StrZero( 2, Len(DC5->DC5_SERTMS) ) .And. ;
			cSertms <> StrZero( 3, Len(DC5->DC5_SERTMS) )
			Help("",1,"TMSA05017") //A Cotacao de Frete informada nao possue servico de Transporte / servico de Entrega
			M->DTC_NUMCOT := CriaVar('DTC_NUMCOT',.F.)
			SeleItCF()
		Else
			M->DTC_SERTMS := DT4->DT4_SERTMS
			M->DTC_DESTPT := TMSValField("DT4->DT4_TIPTRA",.F.,"DC5_DESTPT")
			M->DTC_CDRORI := DT4->DT4_CDRORI
			M->DTC_CDRDES := DT4->DT4_CDRDES
			M->DTC_REGORI := Posicione("DUY",1,xFilial("DUY")+DT4->DT4_CDRORI, "DUY_DESCRI")
			M->DTC_REGDES := Posicione("DUY",1,xFilial("DUY")+DT4->DT4_CDRDES, "DUY_DESCRI")
			M->DTC_CLIREM := DT4->DT4_CLIREM
			M->DTC_LOJREM := DT4->DT4_LOJREM
			M->DTC_NOMREM := Posicione("SA1",1,xFilial("SA1")+DT4->DT4_CLIREM+DT4->DT4_LOJREM, "A1_NOME")
			M->DTC_CLIDES := DT4->DT4_CLIDES
			M->DTC_LOJDES := DT4->DT4_LOJDES
			M->DTC_NOMDES := Posicione("SA1",1,xFilial("SA1")+DT4->DT4_CLIDES+DT4->DT4_LOJDES, "A1_NOME")
			M->DTC_CLIDEV := DT4->DT4_CLIDEV
			M->DTC_LOJDEV := DT4->DT4_LOJDEV
			M->DTC_NOMDEV := Posicione("SA1",1,xFilial("SA1")+DT4->DT4_CLIDEV+DT4->DT4_LOJDEV, "A1_NOME")
			M->DTC_TIPTRA := DT4->DT4_TIPTRA
			M->DTC_SERVIC := DT4->DT4_SERVIC
			M->DTC_DESSER := Tabela("L4",DT4->DT4_SERVIC,.F.)
			M->DTC_SELORI := DT4->DT4_SELORI
			If lIdentDoc
				M->DTC_DOCTMS := DT4->DT4_DOCTMS
				M->DTC_DESDOC	:= TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
			EndIf

			//-- Carrega o array aItContrat com o servico da Nota Fiscal
			aItContrat:={}
			AAdd(aItContrat,{.F.,"1",M->DTC_SERVIC,M->DTC_DESSER})

			If !Empty(DT4->DT4_TIPNFC)
				M->DTC_TIPNFC := DT4->DT4_TIPNFC
			Else
				If	Posicione('DC5',1,xFilial('DC5')+M->DTC_SERVIC,'DC5_DOCTMS')==StrZero(6,Len(DC5->DC5_DOCTMS)) .Or. (lIdentDoc .And. M->DTC_DOCTMS ==StrZero(6,Len(DTC->DTC_DOCTMS)))
					M->DTC_TIPNFC := StrZero(1,Len(DTC->DTC_TIPNFC))
				Else
					M->DTC_TIPNFC := StrZero(0,Len(DTC->DTC_TIPNFC))
				EndIf
			EndIf

			DT5->(dbSetOrder(5))
			If !Empty(M->DTC_FILCFS)
				cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
				cSeek := cFilDT5+M->DTC_FILCFS+M->DTC_NUMCOT
			Else
				cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMCOT
			EndIf
			If DT5->(MsSeek(cSeek))
				M->DTC_NUMSOL := DT5->DT5_NUMSOL
			EndIf

			M->DTC_NOMDEV := Posicione("SA1",1,xFilial("SA1")+DT4->DT4_CLIDEV+DT4->DT4_LOJDEV, "A1_NOME")
			M->DTC_CLICON := CriaVar('DTC_CLICON', .F.)
			M->DTC_LOJCON := CriaVar('DTC_LOJCON', .F.)
			M->DTC_NOMCON := CriaVar('DTC_NOMCON', .F.)
			If M->DTC_CLIDEV+M->DTC_LOJDEV == DT4->DT4_CLIREM + DT4->DT4_LOJREM
				M->DTC_DEVFRE := '1' // Devedor do Frete sera o Remetente
			ElseIf M->DTC_CLIDEV+M->DTC_LOJDEV == DT4->DT4_CLIDES + DT4->DT4_LOJDES
				M->DTC_DEVFRE := '2' // Devedor do Frete sera o Destinatario
			Else
				M->DTC_DEVFRE := '3' // Devedor do Frete sera o Consignatario
				M->DTC_CLICON := M->DTC_CLIDEV
				M->DTC_LOJCON := M->DTC_LOJDEV
				M->DTC_NOMCON := M->DTC_NOMDEV
			EndIf
			M->DTC_CLICAL := M->DTC_CLIDEV
			M->DTC_LOJCAL := M->DTC_LOJDEV
			M->DTC_NOMCAL := M->DTC_NOMDEV
			M->DTC_TIPFRE := DT4->DT4_TIPFRE
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se Nao Existir Destino de Calculo definido para o Cliente Devedor e a Re- ³
			//³giao de Destino, sugerir no Campo Destino de Calculo o Codigo da Regiao   ³
			//³Destino.                                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(M->DTC_SQEDES)
				M->DTC_REGCAL := Posicione('DUY',1,xFilial('DUY') + M->DTC_CDRCAL,'DUY_DESCRI')
			Else
				M->DTC_CDRCAL := TMSDestCal( M->DTC_CLIDEV, M->DTC_LOJDEV, M->DTC_CDRDES )
				If Empty(M->DTC_CDRCAL)
					M->DTC_CDRCAL := M->DTC_CDRDES
				EndIf
				M->DTC_REGCAL := Posicione('DUY',1,xFilial('DUY') + M->DTC_CDRCAL,'DUY_DESCRI')
			EndIf
			//-- Executa Gatilho do campo DTC_CLIDES (Destinatario)
			If !(ReadVar() $ 'M->DTC_CLIDES;M->DTC_LOJDES')
				RunTrigger(1,Nil,Nil,,"DTC_CLIDES")
			EndIf
			If lTmsVInf
				M->DTC_VLRINF := CriaVar("DTC_VLRINF",.F.)
			EndIf
			//-- Quilometragem da cotacao
			M->DTC_KM := DT4->DT4_KM
			M->DTC_DISTIV := DT4->DT4_DISTIV
			M->DTC_INCOTE := DT4->DT4_INCOTE
			M->DTC_MOEDA  := DT4->DT4_MOEDA
			M->DTC_MOENFC := DT4->DT4_MOEDA
			M->DTC_ROTA   := DT4->DT4_ROTA
			M->DTC_DESROT := Posicione('DA8',1,xFilial('DA8')+DT4->DT4_ROTA,'DA8_DESC')
            M->DTC_NCONTR := DT4->DT4_NCONTR
			M->DTC_CODNEG := DT4->DT4_CODNEG
			M->DTC_DESNEG := Posicione("DDB",1,xFilial("DDB") + DT4->DT4_CODNEG,"DDB_DESCRI")
			M->DTC_SERVIC := DT4->DT4_SERVIC

			lAutomatic := .T.
		EndIf
	EndIf

	If lTmA050SEL
		ExecBlock("TMA050SEL",.F.,.F.,{lRet})
	EndIf

EndIf

RestArea(aArea)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ItTudOk() ³ Autor ³Patricia A. Salomao    ³ Data ³05.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a Digitacao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ItTudOk(ExpA1,ExpC1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array contendo as Cotacoes de Frete                 ³±±
±±³          ³ExpC1 - CF Selecionada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ItTudOk(aArray,cItem)

Local nAcho:=0,nI
Local lRet:=.T.

For nI:=1 to Len(aArray)
	nAcho:=Ascan(aArray,{|x| x[1]})
	If nAcho == 0
		Help ("",1,"TMSA05001") //-- Escolha um Item ...
		lRet:=.F.
		Exit
	EndIf
Next nI
If lRet
	For nI:=1 to Len(aArray)
		If aArray[nI,1]
			cItem:=aArray[nI][3] //-- CF Selecionada
			Exit
		EndIf
	Next nI
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TrocaItCF ³ Autor ³Patricia A. Salomao    ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a Troca da Cotacao de Frete.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TrocaItCF(ExpN1,ExpA1,ExpL1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - CF                                                  ³±±
±±³          ³ExpA1 - Array contendo as CF's                              ³±±
±±³          ³ExpL1 - Indica se a funcao foi chamada do TMSA320(AWB).     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo as CF's                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrocaItCF(nIt,aArray,lAWB)

Local nAcho  :=0

Default lAWB := .F.

If aArray[nIt,2] == "1"
	//-- Varre o array para verificar se marcou outro Item
	nAcho:=Ascan(aArray,{|x| x[1]})
	If nAcho > 0 .And. nAcho # nIt .And. !lAWB
		//-- Desmarca Item
		aArray[nAcho,1]:= .F.
	EndIf
	aArray[nIt,1] := !aArray[nIt,1]
EndIf

Return( aArray )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050PESOM3³ Autor ³Patricia A. Salomao    ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche os Campos da Enchoice com os dados da CF informada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050PesoM3()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050PESOM3()

Local nPosNota     := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NUMNFC"})
Local nPosSerie    := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_SERNFC"})
Local nPosPesoM3   := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PESOM3"})
Local nPosQtdVol   := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_QTDVOL"})
Local nPosProd     := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODPRO"})
Local nPosRat      := IIf(Type("aRatPesM3[1]") == "A", Ascan(aRatPesM3,{|x| x[1] == aCols[n][nPosNota]+aCols[n,nPosSerie]+aCols[n,nPosProd]}), 0)
Local cCodPro      := GdFieldGet('DTC_CODPRO',n)
Local nOpc         := 0
Local cCampo       := ReadVar()
Local cOptPesCub   := ''
Local aContrat     := {}
Local lRet         := .T.
Local oDlgEsp,oGetDados,nY,nX
Local lSinc        := TmsSinc() //-- Chamada do Sincroizador
Local nPerCub      := 0
Local cQuery       := ""
Local aNoFields	   := {"DTE_FILORI","DTE_CLIREM","DTE_LOJREM", "DTE_CODPRO", "DTE_ITESOL" , "DTE_NUMCOT", "DTE_NUMNFC", "DTE_SERNFC" , "DTE_NUMSOL"  }

//-- Controle de dimensoes de objetos
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}

Private nTotQtdVol := 0
Private nTotPesoM3 := 0
Private aSavHeader := aClone(aHeader)
Private aSavCols   := aClone(aCols)
Private nSavN      := n

l050Auto := If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

If GdDeleted(n)
	Return( .T. )
EndIf

If Empty(cCodPro)
	Help("",1,"TMSA05025") //-- Informe o Produto ...
	Return( .F. )
EndIf

If Empty(GdFieldGet("DTC_NUMNFC",n)) .Or. Empty(GdFieldGet("DTC_QTDVOL",n))
	Help("",1,"TMSA05021") //-- Informe a Nota Fiscal / Serie / Volumes  ...
	Return( .F. )
EndIf

cOptPesCub := A050PesCub()
If Empty(cOptPesCub)
	Return( .F. )
EndIf

//-- Peso Cubado == Nao   OU   Peso Cubado == M3
If cOptPesCub == '2' .Or. cOptPesCub == '4'
	If !Empty(M->DTC_CLICAL)
		Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado ... Esta Regra Foi definida no Perfil do Cliente de Calculo
	EndIf
	Return( .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o campo A7_PERCUB/B5_PERCUB esteja preenchido, calcular o percentual  ³
//³a partir do peso digitado e armazenar o valor obtido no campo DTC_PESOM3.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l050Inclui
	nPerCub := TmsPerCub(cCodPro,M->DTC_CLIDEV,M->DTC_LOJDEV)
	If !Empty(nPerCub)
		Help("",1,"TMSA05026") //-- O Peso Cubado será calculado automaticamente, de acordo com o percentual de cubagem (A7_PERCUB/B5_PERCUB) informado no complemento do Produto.
		Return( .F. )
	EndIf
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

//--Query para montar o aCols
cQuery := "SELECT *"
cQuery += " FROM " + RetSqlName("DTE")+ " DTE "
cQuery += " WHERE DTE_FILIAL = '" + xFilial("DTE") + "'"
cQuery += "   AND DTE_FILORI = '" + M->DTC_FILORI + "'"
cQuery += "   AND DTE_NUMNFC = '" + aCols[n,nPosNota] + "'"
cQuery += "   AND DTE_SERNFC = '" + aCols[n,nPosSerie] + "'"
cQuery += "   AND DTE_CLIREM = '" + M->DTC_CLIREM + "'"
cQuery += "   AND DTE_LOJREM = '" + M->DTC_LOJREM + "'"
cQuery += "   AND DTE_CODPRO = '" + aCols[n,nPosProd] + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"

n       := 1
aCols   := {}
aHeader := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDTE) == 0 .Or. nPosRat == 0
	FillGetDados(nOpcAnt,"DTE",1,/*cSeek*/,/*{|| &cWhile}*/,{||.T.},aNoFields,,/*lOnlyYes*/,cQuery,/*bMontCols*/)
	aHeaderDTE := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDTE)
EndIf

If nPosRat > 0
	aCols := aClone(aRatPesM3[nPosRat][2])
EndIf

If !l050Auto
	//-- Calcula as dimensoes dos objetos
	AAdd( aObjects, { 100, 040, .T., .T. } ) //--
	AAdd( aObjects, { 100, 060, .T., .T. } ) //-- GetDados

	aSize   := MsAdvSize( )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlgEsp FROM  aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2  TITLE STR0015 Of oMainWnd PIXEL //"Peso Cubado"
		@ aPosObj[1,1]  , 003 SAY STR0016 + "     : " Of oDlgEsp PIXEL SIZE 56 ,9 //"Nota Fiscal"
		@ aPosObj[1,1]  , 040 SAY aSavCols[nSavN][nPosNota]+" / "+aSavCols[nSavN][nPosSerie] Of oDlgEsp PIXEL SIZE 50 ,9

		@ aPosObj[1,1]  , 090 SAY STR0014 + " : " Of oDlgEsp PIXEL SIZE 56 ,9 //"Produto"
		@ aPosObj[1,1]  , 115 SAY alltrim(aSavCols[nSavN][nPosprod])+" / "+ Posicione("SB1",1,xFilial('SB1')+aSavCols[nSavN][nPosprod],"B1_DESC") Of oDlgEsp PIXEL SIZE 105 ,9

		@ aPosObj[1,1] + 8 , 003 SAY STR0021 + " : " Of oDlgEsp PIXEL SIZE 66 ,9 //"Qtd. Volumes"
		@ aPosObj[1,1] + 8 , 040 SAY aSavCols[nSavN][nPosQtdVol] Of oDlgEsp PIXEL SIZE 29 ,9

		oGetDados := MSGetDados():New(aPosObj[2,1]/2 , aPosObj[2,2]/2 + 5, aPosObj[2,3]/2, aPosObj[2,4]/2 - 5 , IIF(l050Visual,2,3),'PESOM3LOK()','PESOM3OK()',,.T.,,,,100,,,,If(l050Visual,"AlwaysFalse",NIL))

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||IIF(oGetDados:TudoOk(),(nOpc:=1,oDlgEsp:End()),(nOpc:=0))},{||oDlgEsp:End()} )
Else
	//-- Se For Rotina Automatica, executa a Funcao de TudoOK() do Peso Cubado, para validar os dados
	//-- passados pela Rotina Automatica
	lRet := PesoM3Ok()
	If lRet
		nOpc := 1
	EndIf
EndIf

If nOpc == 1 .And. !l050Visual
	If nPosRat > 0
		aRatPesM3[nPosRat][2] := aClone(aCols)
	Else
		AAdd(aRatPesM3,{aSavCols[nSavN][nPosNota]+aSavCols[nSavN][nPosSerie]+aSavCols[nSavN][nPosProd],aClone(aCols)})
	EndIf
EndIf

aHeader := aClone(aSavHeader)
aCols	:= aClone(aSavCols)
n		:= nSavN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Peso Cubado do Item                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	nOpc ==1 .And. !l050Visual
	aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
	nFatCub  := If(Len(aContrat)>0,aContrat[1][2],0)
	If nFatCub > 0
		aCols[ n, nPosPesoM3 ] := Round((nTotPesoM3) * nFatCub,TAMSX3("DTC_PESOM3")[2])
	Else
		Help("",1,"TMSA05027") // Nao foi informado Fator de Cubagem no Contrato do Cliente de Calculo ...
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)
		Return( .F. )
	EndIf
EndIf

//-- Refresh no Browse para preencher o valor do peso cubado quando se faz pelo menu não pelo atalho.
If !IsInCallStack('MsExecAuto')
	o1Get:oBrowse:Refresh(.T.)
EndIf
//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PesoM3LOk ³ Autor ³Patricia A. Salomao    ³ Data ³16.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³LinhaOk da GetDados de Peso Cubado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesoM3LOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA040 / TMSA460 / TMSA050                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PESOM3LOK()

Local lRet := .T.

If !GdDeleted(n)
	lRet := MaCheckCols(aHeader,aCols,n)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PesoM3Ok  ³ Autor ³Patricia A. Salomao    ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tudo Ok da GetDados de Peso Cubado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesoM3Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PesoM3Ok()

Local nx
Local lRet := .T.
Local nOpc
Local nPosQtdVol  := Ascan(aSavHeader,{|x| AllTrim(x[2]) == "DTC_QTDVOL"})

nTotQtdVol := 0
nTotPesoM3 := 0
For nx	:= 1 to Len(aCols)
	If !GdDeleted(nX)
		nTotQtdVol += GdFieldGet('DTE_QTDVOL',nX)
		nTotPesoM3 += GdFieldGet('DTE_QTDVOL',nX) * ( GdFieldGet('DTE_ALTURA',nX) * GdFieldGet('DTE_COMPRI',nX) * GdFieldGet('DTE_LARGUR',nX) )
	EndIf
Next

If nTotQtdVol > 0 .And. nTotQtdVol <> aSavCols[nSavN][nPosQtdVol]
	If !MsgYesNo( STR0050 ) //O Total de Volumes do Peso Cubado esta diferente da Quantidade de Volumes informada na Nota Fiscal. Confirma ?"
		lRet := .F.
	EndIf
EndIf

Return( lRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A050EndTMS
GetDados para informar o armazém, endereço, unitizador, cod.analit. dos produtos com
Controle de Endereçamento
@type function
@author Patricia A. Salomao
@version 12
@since 17/05/2002
@return lRet True ou False
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 05/06/2017: reestruturação da função
/*/
//-------------------------------------------------------------------------------------------------
Static Function A050EndTMS()

	Local lRet       := .T.
	Local cNumNFC    := GdFieldGet('DTC_NUMNFC', n)
	Local cSerNFC    := GdFieldGet('DTC_SERNFC', n)
	Local cCodPro    := GdFieldGet('DTC_CODPRO', n)
	Local nQtdVol    := GdFieldGet('DTC_QTDVOL', n)
	Local cTitDlg    := ""
	Local lLocaliz   := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
	Local lMultEnd   := GetMv("MV_MULTEND",,.T.)
	Local nX         := 0
	Local nPosEndNF  := 0
	Local nOpc       := 0
	Local nSeek      := 0
	Local nMaxLin    := 0
	Local lSinc      := TmsSinc() //-- Chamada do Sincronizador
	Local aButtons   := {}
	Local oDlgEsp, oGetDados, oPnlModal, oFWLayer, oPnl01, oSize

	//-- Declaradas como variáveis private pois são utilizadas também
	//-- nas funções EnderLOk e EnderTOk do MSGetDados
	Private nTotQtdVol := 0
	Private aSavHeader := aClone(aHeader)
	Private aSavCols   := aClone(aCols)
	Private nSavN      := n

	If ValType(aEndProd) == "U"
		Private aEndProd := {}
	EndIf

	If ValType(lMultEnd) != "L"
		lMultEnd := .F.
	EndIf

	l050Auto := If (! lSinc .And. Type("l050Auto") == "U", .F., lSinc .Or. l050Auto)

	//-- VALIDAÇÕES

	//-- Linha da nota deletada
	If GdDeleted(n)
		Return .T.
	EndIf

	//-- Produto não informado
	//-- Um ou alguns campos obrigatórios não foram preenchidos no Browse
	If Empty(cCodPro)
		Help(" ", 1, "OBRIGAT2", , RetTitle("DTC_CODPRO"), 4, 1 )
		Return .F.
	EndIf

	//-- Doc.Cliente não informado
	//-- Informe a Nota Fiscal / Serie / Volumes ...
	If Empty(cNumNFC) .Or. Empty(GdFieldGet("DTC_QTDVOL", n))
		Help("", 1, "TMSA05021")
		Return .F.
	EndIf

	//-- Este Produto não possui Controle de Endereçamento...
	If (! lLocaliz) .Or. (lLocaliz .And. SB1->(MsSeek(xFilial("SB1") + cCodPro)) .And. ! (RetFldProd(cCodPro, "B1_LOCALIZ") == "S"))
		Help("", 1, "TMSA05014")
		Return .F.
	EndIf

	//-- Já foi informado este Número de Nota Fiscal / Serie / Produto ...
	nSeek := Ascan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DTC_NUMNFC')] == cNumNFC .And.;
	                                            x[GdFieldPos('DTC_SERNFC')] == cSerNFC .And.;
												x[GdFieldPos('DTC_CODPRO')] == cCodPro})
	If nSeek > 0 .And. nSeek != n
		Help(" ", 1, "TMSA05006")
		Return .F.
	EndIf

	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)

	//-- Obtém aHeader
	aHeader := aClone(GetaHeaDUH())

	//-- Montagem do aCols caso exista registro DUH para a nota
	nPosEndNF := AScan(aEndProd, {|x| x[1] == cNumNFC + cSerNFC + cCodPro})
	If nPosEndNF > 0
		aCols := aClone(aEndProd[nPosEndNF][2])
	Else
		aCols := {}
	EndIf

	n := 1 //-- Atualiza variável n

	If ! l050Auto

		cTitDlg := STR0022 //STR0022 'Endereçamento'
		cTitDlg += " - " + STR0016 + ": " + AllTrim(cNumNFC) + " / " + AllTrim(cSerNFC)
		cTitDlg += ", "  + STR0021 + ": " + AllTrim(cValToChar(nQtdVol))

		//-- Modal que serão apresentadas as informações de Endereçamento
		oDlgEsp := FWDialogModal():New()
		oDlgEsp:SetBackground(.F.)
		oDlgEsp:SetTitle(cTitDlg)
		oDlgEsp:SetEscClose(.T.)
		oDlgEsp:SetSize(200, 400)
		oDlgEsp:CreateDialog()

		oPnlModal := oDlgEsp:GetPanelMain()

		oFWLayer := FWLayer():New() //-- Container
		oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container

		//-- Linhas e colunas
		oFWLayer:AddLine('LIN01', 100, .F.)
		oFWLayer:AddCollumn('COL01', 100, .F., 'LIN01')

		oPnl01 := oFWLayer:GetColPanel('COL01', 'LIN01')

		oSize := FwDefSize():New(.F., , , oPnlModal)
		oSize:AddObject("GETDADOS", 100, 100, .T., .T.)
		oSize:lProp := .T.
		oSize:Process()

		//-- Permite múltiplos endereços para uma NF
		If lMultEnd
			nMaxLin := 100
		Else
			nMaxLin := 1
		EndIf

		oGetDados := MSGetDados():New(oSize:GetDimension("GETDADOS", "LININI"),;
		                              oSize:GetDimension("GETDADOS", "COLINI"),;
									  oSize:GetDimension("GETDADOS", "LINEND"),;
									  oSize:GetDimension("GETDADOS", "COLEND"),;
									  Iif(l050Visual, 2, 3),;
									  'EnderLOk',;
									  'EnderTOk',;
									  /* cIniCpos */,;
									  .T.,;
									  /* aAlter */,;
									  /* nFreeze */,;
									  /* lEmpty */,;
									  nMaxLin,;
									  /* cFieldOk */,;
									  /* cSuperDel */,;
									  /* uPar */,;
									  If(l050Visual, "AlwaysFalse", Nil),;
									  oPnl01)

		//-- Cria botões de operação
		Aadd(aButtons, {"", STR0032, {|| Iif(oGetDados:TudoOk(), (nOpc := 1, oDlgEsp:DeActivate()), (nOpc := 0))}, , , .T., .F.}) //STR0032 'Confirmar'
		Aadd(aButtons, {"", STR0012, {|| oDlgEsp:DeActivate()}, , , .T., .F.}) //STR0012 'Cancelar'
		oDlgEsp:AddButtons(aButtons)

		oDlgEsp:Activate()

	Else
		//-- Se For Rotina Automatica, executa a Funcao de LinhaOk() e TudoOK() do Enderecamento,
		//-- para validar os dados passados pela Rotina Automatica
		For nX := 1 To Len(aCols)
			lRet := EnderLOk(nX) .And. EnderTOk()
			If ! lRet
				Exit
			EndIf
		Next nX
		If lRet
			nOpc := 1
		EndIf
	EndIf

	If nOpc == 1 .And. ! l050Visual
		If nPosEndNF > 0
			aEndProd[nPosEndNF][2] := aClone(aCols)
		Else
			AAdd(aEndProd, {cNumNFC + cSerNFC + cCodPro, aClone(aCols)})
		EndIf
	EndIf

	aHeader := aClone(aSavHeader)
	aCols   := aClone(aSavCols)
	n       := nSavN

	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³EnderLOk  ³ Autor ³Patricia A. Salomao    ³ Data ³17.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da Linha digitada.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³EnderLOk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EnderLOk(nx)

Local nSeek 	:= 0
Local lRet  	:= .T.

If nx == Nil .Or. Empty(nx) .Or. Valtype(nx)<>"N"
	nx := n
EndIf
If !GDdeleted(nx) .And. (lRet:=MaCheckCols(aHeader,aCols,nx))
	nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. (Empty(x[GdFieldPos('DUH_LOCAL')]) .Or. Empty(x[GdFieldPos('DUH_LOCALI')])) })
	If nSeek > 0
		Help("",1,"TMSA05043") //-- Informe os Campos Armazem e Endereco ...
		Return( .F. )
	EndIf
	If TMSChkVer('11','R7')
		nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DUH_LOCAL')]+x[GdFieldPos('DUH_LOCALI')]+x[GdFieldPos('DUH_UNITIZ')]+x[GdFieldPos('DUH_CODANA')] == GDFieldGet('DUH_LOCAL', nx) + ;
		GDFieldGet('DUH_LOCALI', nx) + GDFieldGet('DUH_UNITIZ', nx) + GDFieldGet('DUH_CODANA', nx)})
	Else
		nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DUH_LOCAL')]+x[GdFieldPos('DUH_LOCALI')] == GDFieldGet('DUH_LOCAL', nx) + ;
		GDFieldGet('DUH_LOCALI', nx) })
	EndIf
	/*Verifica se está informado apenas um dos dados (unitizador ou codigo analitico*/
	If (Empty(GDFieldGet('DUH_UNITIZ', nx)) .And. !Empty(GDFieldGet('DUH_CODANA', nx)))
		Help(" ",1,"TMSA05087") //-- Unitizador não informado.
		lRet := .F.
	ElseIf (!Empty(GDFieldGet('DUH_UNITIZ', nx)) .And. Empty(GDFieldGet('DUH_CODANA', nx)))
		Help(" ",1,"TMSA05088") //-- Codigo Analitico não informado.
		lRet := .F.
	EndIf

	If	nSeek > 0 .And. nSeek != nX
		Help(" ",1,"TMSA05023") //-- Endereco ja Informado ...
		Return( .F. )
	EndIf

EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³EnderTOk  ³ Autor ³Patricia A. Salomao    ³ Data ³17.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tudo Ok da GetDados de Enderecamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³EnderTOk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EnderTOk()

Local nx
Local lRet := .T.
Local nPosQtdVol  := Ascan(aSavHeader,{|x| AllTrim(x[2]) == "DTC_QTDVOL"})

nTotQtdVol := 0

For nX := 1 to Len(aCols)
	If !aCols[nX][Len(aCols[nX])] .And. GdFieldPos("DUH_QTDVOL") > 0 .And. GdFieldGet("DUH_QTDVOL", nX) > 0
		nTotQtdVol +=  GdFieldGet("DUH_QTDVOL", nX)
	EndIf
Next

If nTotQtdVol > 0 .And. nTotQtdVol <> aSavCols[nSavN][nPosQtdVol]
	Help("",1,"TMSA05020")//-- A somatoria da Qtd. de Volumes esta Diferente da Qtd. de Volumes informada na Nota Fiscal.
	lRet := .F.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050AtuDTE³ Autor ³Patricia A. Salomao    ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DTE (Cubagem de Mercadorias)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050AtuDTE(ExpN1,ExpA1,ExpA2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Opcao selecionada                                   ³±±
±±³          ³ExpA1 : Array contendo Altura/Largura/Comprimento dos Itens ³±±
±±³          ³        da NF.                                              ³±±
±±³          ³ExpA2 : aHeader da GetDados de Peso Cubado.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050AtuDTE(nOpc,aRatPesM3,aHeaderDTE,aColsDTC,nOpcx,nPosDTC)

Local aArea := GetArea()
Local cSeek := ''
Local nX    := 0
Local nZ    := 0
Local nL    := 0
Local nY    := 0
Local nRecDTE    := 0
Local nPosProd   := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODPRO"})
Local nPosNumNFC := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NUMNFC"})
Local nPosSerNFC := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_SERNFC"})
Local nPosRecDTE := Ascan(aHeaderDTE,{|x| AllTrim(x[2]) == "DTE_REC_WT"})

Default aRatPesM3  := {}
Default aHeaderDTE := {}
Default aColsDTC   := {}
Default nOpc       := 1

dbSelectArea("DTE")
dbSetOrder(1)
If nOpc == 2  .And. MsSeek(cSeek:=xFilial("DTE")+DTC->DTC_FILORI+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CODPRO)
	Do While !Eof() .And. DTE->DTE_FILIAL+DTE->DTE_FILORI+DTE_NUMNFC+DTE_SERNFC+DTE_CLIREM+DTE_LOJREM+DTE_CODPRO == cSeek
		RecLock("DTE",.F.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
	Return( .T. )
EndIf

If nOpc <> 2
	nX := Ascan(aRatPesM3,{|x| x[1] == aCols[nPosDTC][nPosNumNFC]+aCols[nPosDTC][nPosSerNFC]+aCols[nPosDTC][nPosProd]}) //-- Verifica se foi informado Peso Cubado para a Nota
EndIf

If nX > 0
	For nZ := 1 to Len(aRatPesM3[nX][2])
		nRecDTE := aRatPesM3[nX][2][nZ][nPosRecDTE]
		If !aRatPesM3[nX][2][nZ][Len(aRatPesM3[nX][2][nZ])] //-- Verifica se a linha esta deletada
			If nOpcx == 4 .And. nX <= Len(aColsDTC) .And. nRecDTE > 0
				dbGoto(nRecDTE)
				RecLock("DTE",.F.)
			Else
				RecLock("DTE",.T.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os dados contidos na GetDados                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY := 1 to Len(aHeaderDTE)
				If aHeaderDTE[nY][10] # "V"
					DTE->(FieldPut(FieldPos(Trim(aHeaderDTE[nY][2])),aRatPesM3[nX][2][nZ][nY]))
				EndIf
			Next
			DTE->DTE_FILIAL := xFilial('DTE')
			DTE->DTE_CLIREM := M->DTC_CLIREM
			DTE->DTE_LOJREM := M->DTC_LOJREM
			DTE->DTE_FILORI := M->DTC_FILORI
			DTE->DTE_NUMNFC := aCols[nPosDTC][nPosNumNFC]
			DTE->DTE_SERNFC := aCols[nPosDTC][nPosSerNFC]
			DTE->DTE_CODPRO := aCols[nPosDTC][nPosProd]
			MsUnlock()
		ElseIf nOpcx == 4 .And. nRecDTE <> 0
			dbGoto(nRecDTE)
			RecLock("DTE",.F.)
			DbDelete()
			MsUnlock()
		EndIf
	Next
EndIf
RestArea(aArea)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050AtuDUH³ Autor ³Patricia A. Salomao    ³ Data ³17.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DUH (Enderecamento de Notas)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050AtuDUH(ExpN1,ExpA1,ExpA2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Opcao selecionada                                   ³±±
±±³          ³ExpA1 : Array contendo Qtd.Volumes/Armazem/Local            ³±±
±±³          ³ExpA2 : aHeader da GetDados de Enderecamento.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050AtuDUH(nOpc,aEndProd,aHeaderDUH,aCopEndProd,nOpcx,nPosDTC)

Local aArea := GetArea()
Local cSeek := ''
Local nX,nZ,nL,nY
Local nPosProd   := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODPRO"})
Local nPosNumNFC := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NUMNFC"})
Local nPosSerNFC := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_SERNFC"})
Local cLocal 	:= ''
Local cLocali 	:= ''
Local cCodAna 	:= ''
LOcal cUnitiz 	:= ''
Local cSeekDUH  := ""

DEFAULT aEndProd   := {}
DEFAULT aHeaderDUH := {}
DEFAULT nOpc       := 1
DEFAULT nOpcx      := 0

//-- Verifica se foi informado endereçamento para a Nota
nX := Ascan(aEndProd, {|x| x[1] == DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CODPRO})
If nX > 0
	For nZ := 1 To Len(aEndProd[nX][2]) //-- Percorre os registros de endereçamento da nota
		If ! aEndProd[nX][2][nZ][Len(aEndProd[nX][2][nZ])] //-- Apenas considera registros não deletados do aCols

			DUH->(DbSetOrder(1))

			//-- Chave para posicionamento na DUH, caso exista
			cSeekDUH := xFilial("DUH")  +;
			            DTC->DTC_FILORI +;
						SubStr(aEndProd[nX][1], 1, Len(DTC->DTC_NUMNFC) + Len(DTC->DTC_SERNFC)) +;
						DTC->(DTC_CLIREM+DTC_LOJREM) +;
						SubStr(aEndProd[nX][1], Len(DTC->DTC_NUMNFC) + Len(DTC->DTC_SERNFC) + 1, Len(aEndProd[nX][1])) +;
						aEndProd[nX][2][nZ][1] +;
						aEndProd[nX][2][nZ][2]

			If nOpcx == 4 .And. nX <= Len(aCols) .And. ! Empty(aCopEndProd) .And. DUH->(MsSeek(cSeekDUH))
				RecLock("DUH", .F.)
			Else
				RecLock("DUH", .T.)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os dados contidos na GetDados                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY := 1 to Len(aHeaderDUH)
				If aHeaderDUH[nY][10] # "V"
					DUH->(FieldPut(FieldPos(Trim(aHeaderDUH[nY][2])),aEndProd[nX][2][nZ][nY]))
					If AllTrim(aHeaderDUH[nY][2]) == 'DUH_LOCAL'
						cLocal := aEndProd[nX][2][nZ][nY]
					ElseIf aHeaderDUH[nY][2] == 'DUH_LOCALI'
						cLocali := aEndProd[nX][2][nZ][nY]
					ElseIf aHeaderDUH[nY][2] == 'DUH_UNITIZ'
						cUnitiz := aEndProd[nX][2][nZ][nY]
					ElseIf  aHeaderDUH[nY][2] == 'DUH_CODANA'
						cCodAna := aEndProd[nX][2][nZ][nY]
					EndIf
				EndIf
			Next
			DUH->DUH_FILIAL := xFilial('DUH')
			DUH->DUH_CLIREM := M->DTC_CLIREM
			DUH->DUH_LOJREM := M->DTC_LOJREM
			DUH->DUH_FILORI := M->DTC_FILORI
			DUH->DUH_SERNFC := DTC->DTC_SERNFC
			DUH->DUH_NUMNFC := DTC->DTC_NUMNFC
			DUH->DUH_CODPRO := DTC->DTC_CODPRO
			DUH->DUH_FILDES := Posicione("DUY",1,xFilial("DUY")+M->DTC_CDRCAL,"DUY_FILDES")
			DUH->DUH_STATUS := "1"
			MsUnlock()
		ElseIf nOpcx == 4 .And. DUH->(MsSeek(xFilial("DUH")+DTC->DTC_FILORI+aCols[nPosDTC][nPosNumNFC]+aCols[nPosDTC][nPosSerNFC]+;
			DTC->(DTC_CLIREM+DTC_LOJREM)+aCols[nPosDTC][nPosProd]+aEndProd[nX][2][nZ][1]+aEndProd[nX][2][nZ][2]))
			RecLock("DUH",.F.)
			dbDelete()
			MsUnlock()
		EndIf
		If !Empty(cUnitiz) .And. !Empty(cCodAna)
			Dlga010Sta(1,cUnitiz,cCodAna,cLocal,cLocali)
		EndIf
	Next
EndIf
RestArea(aArea)
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050IniVar³ Autor ³Patricia A. Salomao ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configura aCols e aHeader                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050IniVar(ExpC1,ExpC2,ExpC3,ExpN1,ExpN2,ExpC4)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpC2 = Chave para posicionar o registro                   ³±±
±±³          ³ ExpC3 = Expressao do While                                 ³±±
±±³          ³ ExpN1 = Numero do Indice                                   ³±±
±±³          ³ ExpN2 = Numero da Pasta                                    ³±±
±±³          ³ ExpC5 = Campos que serao mostrados na GetDados             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS050IniVar( cAlias, cSeek, cWhile, cSeekFor, nIndex, aYesFields, aNoFields, nOpcAnt )

Local cItemDTE   := ''
Local cItemDUH   := ''
Local cItemDVU   := ''
Local cSeekDTE   := ''
Local cDesTipVei := ''
Local aAreaAnt	  := GetArea()
Local nItDTE     := 0
Local nItDTEAux  := 0
Local nItDUH     := 0
Local nItDVU     := 0
Local nX         := 0
Local cTes	     := GetMV("MV_TESDR",,"")
Local lLocaliz   := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
Local cWhileDVU  := ''
Local cSeekDVU   := ''
Local cSeekOld   := '' //-- Ajustado para registro existentes antes do Upd 123
Local nOrder     := 1
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local aAreaDVU   := DVU->(GetArea())
Local aAreaDTC   := DTC->(GetArea())
Local aNoFldsDTE := {"DTE_FILORI","DTE_CLIREM","DTE_LOJREM", "DTE_CODPRO", "DTE_ITESOL" , "DTE_NUMCOT", "DTE_NUMNFC", "DTE_SERNFC" , "DTE_NUMSOL"  }

Default cSeekFor := ".T."

SF4->( DbSetOrder( 1 ) )
If	!SF4->( MsSeek( xFilial('SF4') + cTes, .F. ) )
	Help( ' ', 1, 'TMSA20015',, " TES : "+ cTes,5,11)
	Return( .F. )
EndIf

If lLocaliz
	AAdd(aYesFields,"DTC_ENDTMS")
EndIf

//Cria o aHeader e aCols
FillGetDados(nOpcAnt,cAlias,nIndex,cSeek,{|| &cWhile },{|| &cSeekFor}, aNoFields, aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)
SaveInter()

dbSelectArea(cAlias)
DbSetOrder(nIndex)
MsSeek( cSeek )

Do While !Eof() .And. &( cWhile ) == cSeek

	//-- Quebra por Solicitacao
	If DTC->DTC_NUMSOL == M->DTC_NUMSOL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi informado peso cubado para a Nota Fiscal/Serie            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cAlias == "DTC"
			//Carrega aHeaderDTE
			aHeader := {}
			aCols   := {}
			cWhileDTE := "DTE->(DTE_FILORI+DTE_NUMNFC+DTE_SERNFC+DTE_CLIREM+DTE_LOJREM+DTE_CODPRO)"
			cSeekDTE  := xFilial("DTE")+DTC->DTC_FILORI+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CODPRO
			FillGetDados(/*nOpcx*/4,"DTE",1,cSeekDTE,{|| &cWhileDTE },{||.T.},aNoFldsDTE,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)
			aHeaderDTE := aClone(aHeader)

			dbSelectArea("DTE")
			dbSetOrder(1) //DTE_FILIAL+DTE_FILORI+DTE_NUMNFC+DTE_SERNFC+DTE_CLIREM+DTE_LOJREM+DTE_CODPRO
			If MsSeek(cSeekDTE)
				If	cItemDTE <> DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CODPRO
					cItemDTE := DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CODPRO
					AAdd(aRatPesM3,{cItemDTE,{}})
					nItDTE++
					nItDTEAux := 1
				EndIf
				Do While !Eof() .And. xFilial("DTE")+DTE->DTE_FILORI+DTE_NUMNFC+DTE_SERNFC+DTE_CLIREM+DTE_LOJREM+DTE_CODPRO == cSeekDTE
					//-- CAMPOS OBRIGATORIOS: DTE_QTDVOL,DTE->DTE_ALTURA,DTE->DTE_LARGUR,DTE->DTE_COMPRI,"DTE",DTE->(Recno()
					AAdd(aRatPesM3[nItDTE][2],Array(Len(aHeaderDTE)+1))
					For nX := 1 To Len(aHeaderDTE)-2
						aRatPesM3[nItDTE][2,nItDTEAux,nX] := &(aHeaderDTE[nX,2])
					Next nX
					aRatPesM3[nItDTE][2,nItDTEAux,nX++] := "DTE"
					aRatPesM3[nItDTE][2,nItDTEAux,nX++] := DTE->(Recno())
					aRatPesM3[nItDTE][2,nItDTEAux,nX++] := .F.
					nItDTEAux++
					dbSkip()
				EndDo
			EndIf

			If nOpcAnt != 6  //-- Copia

				//-- Carregar informações DUH para montagem do aCols na abertura da tela de endereços
				SetInfoDUH()

			EndIf

			//Carrega aHeaderDVU
			aHeader := {}
			aCols   := {}
			nOrder 	  := 2
			cWhileDVU := "DVU->(DVU_FILIAL+DVU_FILORI+DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM)"
			cSeekDVU  := xFilial("DVU")+cFilAnt+DTC->DTC_LOTNFC+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
			cSeekOld  := xFilial("DVU")+cFilAnt+'      '+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
			FillGetDados(/*nOpcx*/4,"DVU",1,cSeekDVU,{|| &cWhileDVU },{||.T.},/*aNoFields*/{"DVU_LOTNFC"},/*aYesFields*/{"DVU_ITEM","DVU_TIPVEI","DVU_DESVEI","DVU_QTDVEI","DVU_ALI_WT","DVU_REC_WT"},/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)

			aHeaderDVU := aClone(aHeader)

			dbSelectArea("DVU")
			dbSetOrder(nOrder)
			If MsSeek(cSeekDVU)
				If	cItemDVU <> DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
					cItemDVU := DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
					AAdd(aColsDVU,{cItemDVU,{}})
					nItDVU++
				EndIf
				Do While !Eof() .And. DVU_FILIAL+DVU_FILORI+DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM == cSeekDVU
					cDesTipVei := Posicione('DUT',1,xFilial('DUT')+DVU->DVU_TIPVEI,'DUT_DESCRI')
					If Ascan(aColsDVU[nItDVU,2],{|x| x[1]+x[2]==DVU->DVU_ITEM+DVU->DVU_TIPVEI}) == 0
						AAdd(aColsDVU[nItDVU][2],{DVU->DVU_ITEM,DVU->DVU_TIPVEI,cDesTipVei,DVU->DVU_QTDVEI,"DVU",DVU->(Recno()),.F.})
					EndIf
					dbSkip()
				EndDo
			ElseIf MsSeek(cSeekOld)  //-- Ajustado para registro existentes antes do Upd 123
				If	cItemDVU <> DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
					cItemDVU := DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
					AAdd(aColsDVU,{cItemDVU,{}})
					nItDVU++
				EndIf
				Do While !Eof() .And. DVU_FILIAL+DVU_FILORI+DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM == cSeekOld
					cDesTipVei := Posicione('DUT',1,xFilial('DUT')+DVU->DVU_TIPVEI,'DUT_DESCRI')
					If Ascan(aColsDVU[nItDVU,2],{|x| x[1]+x[2]==DVU->DVU_ITEM+DVU->DVU_TIPVEI}) == 0
						AAdd(aColsDVU[nItDVU][2],{DVU->DVU_ITEM,DVU->DVU_TIPVEI,cDesTipVei,DVU->DVU_QTDVEI,"DVU",DVU->(Recno()),.F.})
					EndIf
					dbSkip()
				EndDo
			EndIf

		EndIf
	EndIf
	dbSelectArea(cAlias)
	dbSkip()
EndDo

RestInter()
RestArea(aAreaAnt)
RestArea(aAreaDVU)
RestArea(aAreaDTC)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Whe³ Autor ³Patricia A. Salomao    ³ Data ³16.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes antes de editar o campo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Whe(cCampo)

Local lRet       := .T.
Local cOptPesCub := ""
Local aContrat   := {}
Local cCliGen    := GetMV('MV_CLIGEN')
Local nPosEDI    := AScan( aHeader, {|x| AllTrim(x[2]) == "DTC_EDI"} )
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local cClGen     := ""
Local cLjGen     := ""
Local aAreas     := {DF1->(GetArea()),DTQ->(GetArea()),DUD->(GetArea()),DT5->(GetArea()),GetArea()}
Local lExped 	   := DTC->(ColumnPos('DTC_CLIEXP')) > 0
Local cFilDT5		:= FwxFilial('DT5')
Local lLibLtSc      := SuperGetMv( "MV_LIBLTSC", , .F. )

Default cCampo   := ReadVar()
Default a050Whe := {}

//-- Cache do When dos campos, por questões de performance, pois (principalmente o campo DTC_SERVIC) apresentava grande lentidão
If !Empty(a050Whe) .And. cCampo == a050Whe[1] .And. (Seconds() - a050Whe[2]) < 1.5
 	a050Whe[2] := Seconds()
	Return a050Whe[3]
Else
	a050Whe := {"",0,.T.}
EndIf

If cCampo $ "M->DTC_CDRDES.M->DTC_TIPNFC"
	lRet := Empty(M->DTC_NUMCOT)

ElseIf cCampo $ "M->DTC_CLICON.M->DTC_LOJCON"
	If lAutomatic //-- Se o Devedor foi selecionado 'automaticamente'
		If Empty(M->DTC_NUMCOT)
			cClGen := Left(Alltrim(cCliGen),Len(DTC->DTC_CLIREM))
			cLjGen := Right(Alltrim(cCliGen),Len(DTC->DTC_LOJREM))

			If TmsConsig(M->DTC_CLIREM, M->DTC_LOJREM, M->DTC_CLIDES, M->DTC_LOJDES)
				lRet := .F.
			ElseIf TmsConsig(M->DTC_CLIREM, M->DTC_LOJREM, cClGen,cLjGen )
				lRet := .F.
			ElseIf TmsConsig(cClGen, cLjGen, M->DTC_CLIDES, M->DTC_LOJDES)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet .And. lPainel .And. !lEdita .And. cOrigem == "DF1"
		lRet := .F.
	EndIf
ElseIf cCampo == "M->DTC_PESOM3"
	//-- Este campo somente sera' editavel quando o campo A7_PERCUB/B5_PERCUB for branco.
	If Empty(GdFieldGet('DTC_CODPRO',n))
		Help("",1,"TMSA05025") //-- Informe o Produto ...
		lRet :=.F.
	Else
		cOptPesCub := A050PesCub(,cCampo)
		//-- Caso o perfil do cliente de calculo esteja configurado com a opcao "4 - M3"
		//-- habilitar o campo DTC_METRO3 e desabilitar o campo DTC_PESOM3
		If Empty(cOptPesCub) .Or. cOptPesCub == '4'  // Peso Cubado M3
			lRet :=.F.
		EndIf
		If lRet .And. cOptPesCub == '2'
			If !Empty(M->DTC_CLICAL)   // Peso Cubado == Nao
				Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado ... Esta Regra Foi definida no Perfil do Cliente de Calculo Informado
			EndIf
			lRet :=.F.
		EndIf
		lRet := lRet .And. Empty(TmsPerCub(GdFieldGet('DTC_CODPRO',n),M->DTC_CLIDEV,M->DTC_LOJDEV))
	EndIf

ElseIf cCampo == 'M->DTC_METRO3'
	cOptPesCub := A050PesCub(,cCampo)
	//-- Caso o perfil do cliente de calculo esteja configurado com a opcao "4 - M3"
	//-- habilitar o campo DTC_METRO3 e desabilitar o campo DTC_PESOM3
	If cOptPesCub <> '4'  // Peso Cubado M3
		lRet := .F.
	EndIf

ElseIf cCampo == "M->DTC_ENDTMS"
	A050EndTMS()
	lRet := .F.

ElseIf cCampo == "M->DTC_CDRPER"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando for informado um servico com o campo DC5_SEGPER igual a "1 - Sim", ³
	//³deve-se obrigatoriamente habilitar a digitacao do campo DTC_CDRPER (Cod.  ³
	//³Regiao do 1o percurso).                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := IIf(!Empty(M->DTC_SERVIC), (DC5->DC5_SEGPER == '1'), .F.)

ElseIf cCampo == 'M->DTC_CDRCAL'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao Permite Alterar o Campo se Existir Destino de Calculo definido para o ³
	//³Cliente Devedor e a Regiao de Destino.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DTH->( DbSetOrder( 1 ) )
	If DTH->( MsSeek( xFilial('DTH') + M->DTC_CLIDEV + M->DTC_LOJDEV + M->DTC_CDRDES) ) .Or. ;
		DTH->( MsSeek( xFilial('DTH') + cCliGen +  M->DTC_CDRDES) )
		lRet := .F.
	EndIf
	If lRet .And. lPainel .And. !lEdita .And. cOrigem == "DF1"
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DTC_TIPTRA'
	lRet := Empty(M->DTC_NUMCOT)
	If lRet .And. lPainel .And. !lEdita
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DTC_SERVIC'

	If lRet .And. Empty(M->DTC_CLICAL) .Or. Empty(M->DTC_LOJCAL) .Or. Empty(M->DTC_TIPTRA)
		lRet := .F.
	ElseIf lRet .And. !Empty(M->DTC_CLICAL) .And. !Empty(M->DTC_LOJCAL)
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If Len(aContrat) > 0  .And. aContrat[ 1, 21 ]  == StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
			lRet := .F.
		EndIf
		//-- Verifica a Abragencia do Contrato quando nao e cliente generico
		If lRet .And. Len(aContrat) > 0 .AND. !aContrat[ 1,17 ]
			If Posicione("AAM",1,xFilial("AAM")+aContrat[ 1, 1 ],"AAM_ABRANG") == "2"
				M->DTC_LOJCAL:=AAM->AAM_LOJA
			EndIf
		EndIf

		//-- Valida Contrato De Rateio Com Percentual Fixo
		If Len(aContrat) > 0 .And. !Empty(M->DTC_SERVIC) .And. !Empty(M->DTC_CODNEG)
			If !Tmsa050Per( M->DTC_FILORI , M->DTC_LOTNFC , M->DTC_CODNEG , M->DTC_SERVIC , aContrat )
				lRet := .f.
			EndIf
		EndIf
	EndIf

	If !Empty(M->DTC_SERVIC)
		If (lPainel .And. !lEditaServ .And. cOrigem == "DF1")
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo $ 'M->DTC_NUMSOL'
	If !Inclui .Or. IsInCallStack('TMSAF76')
		lRet := Empty(M->DTC_NUMSOL)
	EndIf
	If lRet .And. lPainel .And. !lEdita .And. cOrigem == "DF1"
		lRet := .F.
	EndIf
	If Vazio() .And. lExped .And. !Empty(M->DTC_CLIEXP)
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DTC_DPCLOC'
	lRet := (!Empty(M->DTC_ALIANC) .And. TmsA050Dpc())
ElseIf cCampo $ 'M->DTC_CLIEXP.M->DTC_LOJEXP'
	If Vazio() .And. lExped .And. !Empty(M->DTC_NUMSOL)
		DT5->(DBSetOrder(1))
		DT5->(MsSeek(xFilial("DT5")+M->(DTC_FILCFS+DTC_NUMSOL)))
		If !Empty(DT5->DT5_SQEREM)
			lRet := .F.
		EndIf
	EndIf
ElseIf cCampo $ 'M->DTC_SERTMS'
	lRet := Empty(M->DTC_NUMCOT)
	If lRet .And. lPainel .And. !lEdita .And. cOrigem == "DF1" .And. !lSemCtr .And. !Empty(M->DTC_SERTMS)
		lRet := .F.
	EndIf

ElseIf cCampo $ 'M->DTC_ALIANC'
	//-- Informa parceiro de alianca somente no primeiro percurso
	lRet := !TmsA050Dpc()
ElseIf cCampo $ 'M->DTC_VLRINF'
	//-- Somente habilita digitacao do valor informado se a cotacao nao foi selecionada
	lRet := Empty(M->DTC_NUMCOT)

ElseIf AllTrim(cCampo) $ 'M->DTC_INCOTE;M->DTC_MOEDA;M->DTC_ROTA;M->DTC_CLINOT;M->DTC_LOJNOT;M->DTC_DOCANE;M->DTC_VALSEG;M->DTC_MOENFC'
	//-- Rodoviario Internacional
	lRet := (M->DTC_TIPTRA == StrZero(4,Len(DTC->DTC_TIPTRA)))

ElseIf	cCampo $ 'M->DTC_CLIDES.M->DTC_LOJDES'
	If nPosEDI > 0 .And. AScan( aCols, {|x| x[nPosEDI] == '1' .And. x[Len(aHeader)+1] == .F.} ) <> 0
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	If lRet .And. lPainel .And. !lEdita .And. cOrigem == "DF1"
		lRet := .F.
	EndIf
ElseIf	cCampo $ 'M->DTC_DATAGD.M->DTC_INIAGD.M->DTC_FIMAGD.M->DTC_TIPAGD.M->DTC_PRDAGD.M->DTC_MOTAGD'
	//-- Agendamento de Entrega
	If lAgdEntr
		If Empty(M->DTC_SQEDES)
			lRet := (TMS050AGD( M->DTC_CLIDES, M->DTC_LOJDES ) <> "2")
	  	Else
			aArea := DUL->(GetArea())
			DUL->(DbSetOrder(2))
			If DUL->(MsSeek( xFilial('DUL') + M->DTC_CLIDES + M->DTC_LOJDES + DTC_SQEDES ))
				If !Empty(DUL->DUL_CODRED) .And. !Empty(DUL->DUL_LOJRED)
					lRet := (TMS050AGD( DUL->DUL_CODRED, DUL->DUL_LOJRED ) <> "2")
				Else
					lRet := (TMS050AGD( M->DTC_CLIDES, M->DTC_LOJDES ) <> "2")
				EndIf
			EndIf
			RestArea( aArea )
		EndIf
		If lRet
			If cCampo == 'M->DTC_INIAGD'
				lRet := (GdFieldGet('DTC_PRDAGD',n)<>'2')
			ElseIf cCampo == 'M->DTC_FIMAGD'
				lRet := (GdFieldGet('DTC_PRDAGD',n)$'2.3')
			EndIf
		EndIf
	EndIf
ElseIf cCampo $ 'M->DUH_CODANA'
	lRet := !Empty(GdFieldGet('DUH_UNITIZ',n))
ElseIf cCampo $ 'M->DTC_CODNEG:M->DTC_NCONTR:M->DTC_SERVIC'
	If (lPainel .And. !lEdita .And. cOrigem == "DF1" .And. !lSemCtr)
		lRet := .F.
	EndIf

ElseIf cCampo $ "M->DTC_FILCFS.M->DTC_CLIREM.M->DTC_LOJREM.M->DTC_CLIDPC.M->DTC_LOJDPC" + ;
				"M->DTC_DEVFRE.M->DTC_SERTMS.M->DTC_TIPTRA.M->DTC_CDRCAL"

	If lPainel .And. !lEdita .And. cOrigem == "DF1"
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DTC_LOTNFC'
	If IsIncallStack('TMSAF76')
		lRet := .F.
	EndIf

ElseIf cCampo $ 'M->DTC_ESTORN'
	If IsIncallStack('TMSAF76')
		lRet := .F.
	EndIf
ElseIf	cCampo $ 'M->DTC_HORCOL'
	If lRet
		If Empty(M->DTC_NUMSOL)
			lRet := .F.
		EndIf
	EndIf
ElseIf	cCampo $ 'M->DTC_DTENTR'
	If lRet
		If Empty(M->DTC_NUMSOL)
			lRet := .F.
		Else
			DF1->(DbSetOrder(3))
			If DF1->(DbSeek(xFilial("DF1") + M->(DTC_FILCFS + DTC_NUMSOL + "COL")))
				If TmsSobServ("TIPOPE",,.T.,DF1->DF1_NCONTR,DF1->DF1_CODNEG,DF1->DF1_SRVCOL,"0") == "1"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf	cCampo $ 'M->DTC_HORENT'
	If lRet
		If Empty(M->DTC_NUMSOL)
			lRet := .F.
		Else
			DF1->(DbSetOrder(3))
			If DF1->(DbSeek(xFilial("DF1") + M->(DTC_FILCFS + DTC_NUMSOL + "COL")))
				If TmsSobServ("TIPOPE",,.T.,DF1->DF1_NCONTR,DF1->DF1_CODNEG,DF1->DF1_SRVCOL,"0") == "1"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf	cCampo $ 'M->DTC_DATCOL'
	If lRet
		If Empty(M->DTC_NUMSOL)
			lRet := .F.
		Else
			DUD->(DbSetOrder(1))
			If DUD->(DbSeek(xFilial("DUD") + M->(DTC_FILCFS + DTC_NUMSOL) + "COL")) .And. !Empty(DUD->DUD_VIAGEM)
				DTQ->(DbSetOrder(1))
				If DTQ->(DbSeek(xFilial("DTQ") + DUD->DUD_VIAGEM))
					If DTQ->DTQ_DATGER < M->DTC_DATCOL
						lRet := .F.
					ElseIf DTQ->DTQ_DATGER == M->DTC_DATCOL .And. DTQ->DTQ_HORGER < M->DTC_HORCOL
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//-- Cache do When dos campos, por questões de performance, pois (principalmente o campo DTC_SERVIC) apresentava grande lentidão
a050Whe := {cCampo,seconds(),lRet}

AEval(aAreas,{|x| RestArea(x) })

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Vld³ Autor ³ Patricia A. Salomao   ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Vld(cCampo)

Local aAreaAnt   := GetArea()
Local aAreaSA1   := SA1->(GetArea())
Local aAreaDTC   := DTC->(GetArea())
Local aAreaDC5   := DC5->(GetArea())
Local aAreaDT5   := DT5->(GetArea())
Local lRet       := .T.
Local nCntFor    := 0
Local nSeek      := 0
Local nValMetro3 := 0
Local nKm        := 0
Local cOptPesCub := ''
Local cNumNFC    := ''
Local cSerNFC    := ''
Local cCodPro    := ''
Local cSeek      := ''
Local cStatus    := ''
Local cFilCol    := ''
Local cViaCol    := ''
Local cFilDT5    := xFilial('DT5')
Local cFilDVF    := xFilial('DVF')
Local lLocaliz   := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
Local cCliGen    := GetMV("MV_CLIGEN")

Local aContrat   := {}
Local lSinc      := TmsSinc() //-- Chamada do Sincroizador

Local lTmsCFec   := TMSCFec() //-- Carga Fechada
Local nOld       := n
Local nPerCub    := 0
Local cAliasQry  := ''
Local lCotLot    := .F.
Local lClrCot    := .T.
Local lVerifica  := .T.
Local cFilDT4    := xFilial('DT4')
Local cSeekDT4   := ''
Local lInscrito  := .F.
Local lAgend     := .F.
Local aAreaDF1   := {}
Local cStatusPE  := ''
Local cVeiEnt    := ''
Local cMotEnt    := ''
Local aAreaDTQ   := {}
Local aAreaDTR   := {}
Local aAreaDUP   := {}
Local nPosEDI    := AScan( aHeader, {|x| AllTrim(x[2]) == "DTC_EDI"} )
Local lLoteAuto  := SuperGetMv("MV_LOTAUT",.F.,.T.)
Local lLibLtSc   := SuperGetMv("MV_LIBLTSC", , .F. )
Local lTM050CCC  := ExistBlock("TM050CCC")
Local lViaCol	 := DTP->(ColumnPos("DTP_VIACOL")) > 0
Local lExped 	 := DTC->(ColumnPos("DTC_CLIEXP")) > 0
Local lIdentDoc  := DTC->(ColumnPos("DTC_DOCTMS")) > 0
Local oError     := ErrorBlock({|e|,,break(e)})
Local lSolicServ := .T.
Local cChave     := ""
Local cIsenSub	 := GetMV("MV_ISENSUB",,"")
Local cUfOri	 := ""
Local cCNPJSub	 := ""
Local cCNPJFil	 := ""
Local aFilSM0	 := {}
Local lServic    := DT5->(ColumnPos("DT5_SERVIC")) > 0

Private lMsErroAuto := .F.

Default cCampo   := ''

If Empty(cCampo)
	cCampo := ReadVar()
	nKm    := M->DTC_KM
EndIf

l050Auto := Iif (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

If	cCampo $ 'M->DTC_CLIREM.M->DTC_LOJREM'
	If !Empty( M->DTC_CLIREM ) .And. !Empty( M->DTC_LOJREM )
		If !TMSVldCli(M->DTC_CLIREM,M->DTC_LOJREM) // Valida se o Codigo Informado e' de Cliente Generico
			Return( .F. )
		EndIf
		If M->DTC_CLIREM+M->DTC_LOJREM==M->DTC_CLIDES+M->DTC_LOJDES
			If !l050Auto .And. !MsgYesNo(STR0023 )   //"O Cliente Remetente e Destinario estao Iguais ... Confirma ? "###"Sim"###"Nao"
				Return( .F. )
			EndIf
		EndIf
		lCotacao := .F.
		If (lRet := ExistCpo('SA1',M->DTC_CLIREM+M->DTC_LOJREM,1))
			SA1->(DbSetOrder(1))
			If SA1->( MsSeek( xFilial('SA1') + M->DTC_CLIREM + M->DTC_LOJREM) )
				If Empty( SA1->A1_CDRDES )
					Help( "", 1, "CDRDES",, RetTitle('A1_COD') + ': ' + M->(DTC_CLIREM + '/' + DTC_LOJREM), 4, 1 ) //--"Informe um código de região válida para este cliente."
					lRet := .F.
				Else
					M->DTC_NOMREM := SA1->A1_NOME
					M->DTC_INSREM := SA1->A1_INSCR
					//-- Verifica se utiliza cotacao no lote
					DTP->(DbSetOrder(2))
					If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
						lVerifica := Empty(DTP->DTP_NUMCOT)
					EndIf
					lRet := TMSA050Dev(cCliGen,lVerifica,,cCampo)
				EndIf
			EndIf
			
			//-- Validação que não permite trocar o cliente remetente, caso a viagem do lote tenha operações DTW vinculadas DLOGTMS03-5404
			If lRet
				lRet	:= A050VldDTP(cCampo)
			EndIf
			
			If lRet .And. !Empty(DTP->DTP_VIAGEM) .And. ExistFunc("VldLoteVge")
				DTQ->(DbSetOrder(2))
				If DTQ->(MsSeek(xFilial("DTQ") + DTP->DTP_FILORI + DTP->DTP_VIAGEM))  
					If DTQ->DTQ_STATUS ==  StrZero(2,Len(DTQ->DTQ_STATUS)) //-- Viagem em trânsito
						lRet := VldLoteVge(DTP->DTP_FILORI , DTP->DTP_VIAGEM, , M->DTC_CLIREM, M->DTC_LOJREM )
					EndIf 
				EndIf
			EndIf 

			If lRet
				//-- Exibe as observacoes do cliente.
				TMSA050ObsCli(M->DTC_CLIREM, M->DTC_LOJREM)
				//-- Exibe as inscricoes do cliente.
				TMSA050InscCli(M->DTC_CLIREM, M->DTC_LOJREM, cCampo)
			EndIf

			//-- Alterou Regiao Remetente e Seleciona Regiao Origem 'Cliente Remetente'
			If lRet .And. SA1->A1_CDRDES <> M->DTC_CDRDES .And. M->DTC_SELORI == StrZero(2,Len(DTC->DTC_SELORI))
				lRet := TMSSelOri("DTC",M->DTC_SELORI,M->DTC_CLIREM,M->DTC_LOJREM,,M->DTC_FILORI,M->DTC_NUMSOL)
				If !Empty(M->DTC_CDRDES)
					If lRet
						nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
						M->DTC_KM := nKm
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If ( Empty(M->DTC_LOTNFC) .And. lLoteAuto ) .Or. ( lViaCol .And. Empty(M->DTC_LOTNFC) .And. IsInCallStack("TMSAF76") )
		M->DTC_LOTNFC := TMS050Lot()
		//Verifica se o lote esta fechado e se havera necessidade de reabri-lo
		Tmsa050RLt(M->DTC_FILORI,M->DTC_LOTNFC)
	EndIf

ElseIf	cCampo $ 'M->DTC_CLIDES.M->DTC_LOJDES'
	//-- Este HELP TMSA050075 foi removido pois a USIFAST em alguns casos necessita alterar
	//-- o campo de destinatário na nota.


	If !Empty( M->DTC_CLIDES ) .And. !Empty( M->DTC_LOJDES )
		If !TMSVldCli(M->DTC_CLIDES,M->DTC_LOJDES) // Valida se o Codigo Informado e' de Cliente Generico
			Return( .F. )
		EndIf
		If M->DTC_CLIDES+M->DTC_LOJDES==M->DTC_CLIREM+M->DTC_LOJREM
			If !l050Auto .And. !MsgYesNo(STR0023) //"O Cliente Remetente e Destinario estao Iguais ... Confirma ? "###"Sim"###"Nao"
				Return( .F. )
			EndIf
		EndIf
		If (lRet := ExistCpo('SA1',M->DTC_CLIDES+M->DTC_LOJDES,1))
			SA1->(DbSetOrder(1))
			If	SA1->( MsSeek( xFilial('SA1') + M->DTC_CLIDES + M->DTC_LOJDES) )
				If Empty( SA1->A1_CDRDES )
					Help( "", 1, "CDRDES",, RetTitle('A1_COD') + ': ' + M->(DTC_CLIDES + '/' + DTC_LOJDES), 4, 1 ) //--"Informe um código de região válida para este cliente."
					lRet := .F.
				Else
					M->DTC_NOMDES := SA1->A1_NOME
					M->DTC_INSDES := SA1->A1_INSCR
					//-- Verifica se utiliza cotacao no lote
					DTP->(DbSetOrder(2))
					If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
						lVerifica := Empty(DTP->DTP_NUMCOT)

						If !lVerifica
							//----- Verifica se na cotação de frete foi informado o Contribuinte
							dbSelectArea("DT4")
							dbSetOrder(1)
							If !Empty(M->DTC_FILCFS)
								cFilDT4  := TMSA050CFS("DT4",M->DTC_FILCFS)
								cSeekDT4 := cFilDT4+M->DTC_FILCFS+DTP->DTP_NUMCOT
							Else
								cSeekDT4 := cFilDT4+M->DTC_FILORI+DTP->DTP_NUMCOT
							EndIf
							If dBSeek(cSeekDT4) .And. !Empty(DT4->DT4_CONTRI) .And. DT4->DT4_CONTRI <> StrZero(0,Len(DT4->DT4_CONTRI))
								lInscrito := IIf(Empty(SA1->A1_INSCR) .Or. "ISENT" $ SA1->A1_INSCR .Or. "RG" $ SA1->A1_INSCR .Or. SA1->A1_CONTRIB == "2",.T.,.F.)
								//Se a variavel lInscr retornar True, o cliente nao e inscrito, ao contrario e considerado inscrito
								If lInscrito
									lRet:= DT4->DT4_CONTRI == StrZero(2,Len(DT4->DT4_CONTRI)) //Nao Contribuinte
								Else
									lRet:= DT4->DT4_CONTRI == StrZero(1,Len(DT4->DT4_CONTRI)) //Contribuinte
								EndIf

								If !lRet
									Help( " ", 1, "TMSA05072",, (Iif(DT4->DT4_CONTRI == '1',STR0079,STR0080)),3,0) //"Contribuinte"###"Não Contribuinte"
									Return( .F. )
								EndIf
							EndIf
						EndIf
					EndIf

					If (lRet := TMSA050Dev(cCliGen,lVerifica,,cCampo)) // Verifica quem sera o Devedor do Frete
						A050AvalSer()// Valida se o Servico e' de 2o. Percurso
					EndIf
				EndIf
			EndIf
			If lRet
				//-- Exibe as observacoes do cliente.
				TMSA050ObsCli(M->DTC_CLIDES, M->DTC_LOJDES)
				//-- Exibe as inscricoes do cliente.
				TMSA050InscCli(M->DTC_CLIDES, M->DTC_LOJDES, cCampo)
			EndIf
		EndIf
		If lRet
			lRet := TMSA050Ali()
		EndIf
		If lRet
			If !Empty(M->DTC_SQEDES)
				aArea := DUL->(GetArea())
				DUL->(DbSetOrder(2))
				If ! DUL->(MsSeek(xFilial("DUL") + M->DTC_CLIDES + M->DTC_LOJDES + M->DTC_SQEDES))
					M->DTC_SQEDES := CriaVar('DTC_SQEDES', .F.)
					If DTC->(ColumnPos("DTC_CLIREC")) > 0 //-- Limpa o recebedor e loja...
						M->DTC_CLIREC := CriaVar("DTC_CLIREC",.F.)
						M->DTC_LOJREC := CriaVar("DTC_LOJREC",.F.)
					EndIf
				EndIf
				RestArea(aArea)
			EndIf
		EndIf
	EndIf

ElseIf cCampo $ 'M->DTC_CLICON.M->DTC_LOJCON'
	If !Empty( M->DTC_CLICON ) .And. !Empty( M->DTC_LOJCON )
		If !TMSVldCli(M->DTC_CLICON,M->DTC_LOJCON) //-- Valida se o Codigo Informado e' de Cliente Generico
			Return( .F. )
		EndIf
		If (lRet := ExistCpo('SA1',M->DTC_CLICON+M->DTC_LOJCON,1))
			SA1->(DbSetOrder(1))
			If	SA1->( MsSeek( xFilial('SA1') + M->DTC_CLICON + M->DTC_LOJCON) )
				If Empty( SA1->A1_CDRDES )
					Help( "", 1, "CDRDES",, RetTitle('A1_COD') + ': ' + M->(DTC_CLICON + '/' + DTC_LOJCON), 4, 1 ) //--"Informe um código de região válida para este cliente."
					lRet := .F.
				Else
					M->DTC_NOMCON := SA1->A1_NOME
					M->DTC_INSCON := SA1->A1_INSCR
					//-- Verifica se utiliza cotacao no lote
					DTP->(DbSetOrder(2))
					If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
						lVerifica := Empty(DTP->DTP_NUMCOT)
					EndIf
					If (lRet := TMSA050Dev(cCliGen,lVerifica,,cCampo)) //-- Verifica quem sera o Devedor do Frete
						A050AvalSer()       //-- Valida se o Servico e' de 2o. Percurso
					EndIf
				EndIf
			EndIf
			If lRet
				TMSA050ObsCli(M->DTC_CLICON, M->DTC_LOJCON)
				//-- Exibe as inscricoes do cliente.
				TMSA050InscCli(M->DTC_CLICON, M->DTC_LOJCON, cCampo)
			EndIf
		EndIf
	Else
		M->DTC_NOMCON := CriaVar('DTC_NOMCON', .F.)
	EndIf

ElseIf cCampo $ 'M->DTC_CLIDPC.M->DTC_LOJDPC'
	If !Empty( M->DTC_CLIDPC ) .And. !Empty( M->DTC_LOJDPC )
		If !TMSVldCli(M->DTC_CLIDPC,M->DTC_LOJDPC) // Valida se o Codigo Informado e' de Cliente Generico
			Return( .F. )
		EndIf
		If (lRet := ExistCpo('SA1',M->DTC_CLIDPC+M->DTC_LOJDPC,1))
			SA1->(DbSetOrder(1))
			If	SA1->( MsSeek( xFilial('SA1') + M->DTC_CLIDPC + M->DTC_LOJDPC) )
				If Empty( SA1->A1_CDRDES )
					Help( "", 1, "CDRDES",, RetTitle('A1_COD') + ': ' + M->(DTC_CLIDPC + '/' + DTC_LOJDPC), 4, 1 ) //--"Informe um código de região válida para este cliente."
					lRet := .F.
				Else
					M->DTC_NOMDPC := SA1->A1_NOME
					M->DTC_INSDPC := SA1->A1_INSCR
				EndIf
			EndIf
			TMSA050ObsCli(M->DTC_CLIDPC, M->DTC_LOJDPC)
			//-- Exibe as inscricoes do cliente.
			TMSA050InscCli(M->DTC_CLIDPC, M->DTC_LOJDPC, cCampo)
		EndIf
	ElseIf Empty( M->DTC_CLIDPC ) .Or. Empty( M->DTC_LOJDPC )
		M->DTC_CTRDPC := CriaVar('DTC_CTRDPC',.F.)
	EndIf
ElseIf cCampo $ 'M->DTC_CLIEXP.M->DTC_LOJEXP'

	aAreaDT5 := DT5->(GetArea())
	If !Empty( M->DTC_CLIEXP ) .And. !Empty( M->DTC_LOJEXP )
		If !TMSVldCli(M->DTC_CLIEXP,M->DTC_LOJEXP) // Valida se o Codigo Informado e' de Cliente Generico
			Return( .F. )
		EndIf

		//-- Se na solicitacao de coleta não tiver informado a seq.endereco do remetente permite que o campo DTC_CLIEXP seja editado.
		DT5->(DbSetOrder(1))
		DT5->(MsSeek(xFilial("DT5")+M->(DTC_FILCFS+DTC_NUMSOL)))

		If !Empty(M->DTC_NUMSOL) .And. !Empty(DT5->DT5_SQEREM)
		 	//[ uPar1 ] [ uPar2 ] [ cCampo ] [ cNome ] [ cMensagem ] [ nLinha1 ] [ nColuna ] [ lPop ] [ uPar9 ] [ uPar10 ] [ uPar11 ] [ lGravaLog ][aSoluc] )
			Help('',1,'DTC_CLIEXP',,'O Campo Expedidor não pode ser alterado quando a solicitação de coleta estiver informado com seq.endereço para o Cliente Remetente.',01,04)
			Return (.F.)
		EndIf

		If (lRet := ExistCpo('SA1',M->DTC_CLIEXP+M->DTC_LOJEXP,1))
			SA1->(DbSetOrder(1))
			If	SA1->( MsSeek( xFilial('SA1') + M->DTC_CLIEXP + M->DTC_LOJEXP) )
				If Empty( SA1->A1_CDRDES )
					Help( "", 1, "CDRDES",, RetTitle('A1_COD') + ': ' + M->(DTC_CLIDPC + '/' + DTC_LOJDPC), 4, 1 ) //--"Informe um código de região válida para este cliente."
					lRet := .F.
				Else
					M->DTC_NOMEXP := SA1->A1_NOME
					M->DTC_NUMSOL := Space(Len(DTC->DTC_NUMSOL))
					M->DTC_DATCOL := CtoD(Space(08))
					M->DTC_HORCOL := Space(Len(DTC->DTC_HORCOL))
					M->DTC_DTENTR := CtoD(Space(08))
					M->DTC_HORENT := Space(Len(DTC->DTC_HORENT))
					M->DTC_RECEBE := Space(Len(DTC->DTC_RECEBE))
					If DTC->(ColumnPos('DTC_EXCTDA')) > 0
						M->DTC_EXCTDA := Space(Len(DTC->DTC_EXCTDA))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Para DTC_TIPNFC = '9-Redespacho Intermediario' o campo M->DTC_CLIREM e M->DTC_LOJREM recebem o mesmo valor do Expedidor
	If M->DTC_TIPNFC == '9'
		M->DTC_CLIREM := M->DTC_CLIEXP
		M->DTC_LOJREM := M->DTC_LOJEXP
		TMSA050Vld('DTC_CLIREM')
	EndIf
	RestArea(aAreaDT5)
//-- validacao para o campo de Recebedor da Carga...
ElseIf cCampo $ 'M->DTC_CLIREC.M->DTC_LOJREC'

	If !Empty( M->DTC_CLIREC ) .And. !Empty( M->DTC_LOJREC )
		If !TMSVldCli(M->DTC_CLIREC,M->DTC_LOJREC) // Valida se o Codigo Informado e' de Cliente Generico
			Return( .F. )
		EndIf

		If(lRet := ExistCPO("SA1",M->DTC_CLIREC+M->DTC_LOJREC,1))
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1") + M->DTC_CLIREC+M->DTC_LOJREC))
				If Empty(SA1->A1_CDRDES)
					Help("",1,"CDRDES",,RetTitle("A1COD") + ": " + M->(DTC_CLIREC+"/"+DTC_LOJREC),4,1) //-- Informe um codigo de regiao valida para este cliente.
					lRet := .F.
				Else
					M->DTC_CDRCAL := SA1->A1_CDRDES
					M->DTC_REGCAL := Posicione("DUY",1,xFilial("SA1")+SA1->A1_CDRDES,"DUY_DESCRI")
					M->DTC_NOMREC := SA1->A1_NOME
				EndIf

			EndIf
		EndIf
	Else
		//-- Executa Gatilho do campo DTC_CLIDES (Destinatario)
		RunTrigger(1,Nil,Nil,,"DTC_CLIDES")
		If DTC->(ColumnPos("DTC_CLIREC")) > 0 .And. Empty(M->DTC_CLIREC) .And. Empty(M->DTC_LOJREC)
			M->DTC_CLIREC := CriaVar("DTC_CLIREC",.F.)
			M->DTC_LOJREC := CriaVar("DTC_LOJREC",.F.)
			M->DTC_NOMREC := CriaVar("DTC_NOMREC",.F.)
		EndIf
	EndIf
	
	//-- Para DTC_TIPNFC = '9-Redespacho Intermediario' o campo M->DTC_CLIREM e M->DTC_LOJREM recebem o mesmo valor do Expedidor
	If M->DTC_TIPNFC == '9'
		M->DTC_CLIDES := M->DTC_CLIREC
		M->DTC_LOJDES := M->DTC_LOJREC
		M->DTC_CDRDES := SA1->A1_CDRDES
		TMSA050Vld('DTC_CLIDES')
		//-- Executa Gatilho do campo DTC_CLIDES (Destinatario)
		RunTrigger(1,Nil,Nil,,"DTC_CLIDES")
	EndIf

ElseIf cCampo $ 'M->DTC_CLINOT.M->DTC_LOJNOT'
	If !Empty(M->DTC_CLINOT) .And. !Empty(M->DTC_LOJNOT)
		If !TMSVldCli(M->DTC_CLINOT,M->DTC_LOJNOT) // Valida se o Codigo Informado e' de Cliente Generico
			Return( .F. )
		EndIf
		SA1->(dbSetOrder(1))
		If	SA1->(dbSeek(xFilial('SA1')+M->DTC_CLINOT+M->DTC_LOJNOT))
			If Empty( SA1->A1_CDRDES )
				Help( "", 1, "CDRDES",, RetTitle('A1_COD') + ': ' + M->(DTC_CLINOT + '/' + DTC_LOJNOT), 4, 1 ) //--"Informe um código de região válida para este cliente."
				lRet := .F.
			Else
				M->DTC_NOMNOT := SA1->A1_NOME
			EndIf
		Else
			Help("",1,"REGNOIS") //Nao existe registro relacionado a este codigo
			Return( .F. )
		EndIf
	Else
		M->DTC_NOMNOT := CriaVar('DTC_NOMNOT')
	EndIf
ElseIf cCampo == 'M->DTC_ROTA'
	DA8->(dbSetOrder(1))
	If DA8->(!dbSeek(xFilial("DA8")+M->DTC_ROTA))
		Help(" ",1,"REGNOIS")
		Return( .F. )
	EndIf
	If DA8->DA8_SERTMS != M->DTC_SERTMS .Or. DA8->DA8_TIPTRA != M->DTC_TIPTRA
		MsgAlert(STR0076) //-- "Rota inválida para o serviço e ou tipo de transporte informado"
		Return( .F. )
	EndIf
	If TMSRotDes(M->DTC_CDRCAL,M->DTC_ROTA)
		M->DTC_DESROT := DA8->DA8_DESC
	EndIf
ElseIf cCampo == 'M->DTC_INCOTE'
	If Empty(M->DTC_INCOTE)
		M->DTC_TIPFRE := CriaVar("DTC_TIPFRE")
	Else
		lRet := ExistCpo('SX5','MP'+M->DTC_INCOTE,1)
		If lRet
			If (M->DTC_INCOTE == "DAF" .Or. M->DTC_INCOTE == "DDU") //Se nao for estes tipos, respeita o que esta no DTC
				M->DTC_TIPFRE := StrZero(3,Len(DTC->DTC_TIPFRE))
			EndIf
		EndIf
	EndIf
ElseIf cCampo == 'M->DTC_CODPRO'
	If !l050Auto
		cCodPro := M->DTC_CODPRO
		If cCodPro <> GdFieldGet('DTC_CODPRO',n)
			cNumNFC := GdFieldGet('DTC_NUMNFC',n)
			cSerNFC := GdFieldGet('DTC_SERNFC',n)

			//-- Nao deleta as informacoes do produto qdo atualizado via EDI
			If GdFieldGet('DTC_EDI',n) <> "1"
				nSeek := Ascan( aEndProd,{|x| x[1] == cNumNFC + cSerNFC + cCodPro})
				If nSeek > 0
					aDel(aEndProd,nSeek)
					aSize(aEndProd,Len(aEndProd)-1)
				EndIf
				nSeek := Ascan( aRatPesM3,{|x| x[1] == cNumNFC + cSerNFC + cCodPro})
				If nSeek > 0
					aDel(aRatPesM3,nSeek)
					aSize(aRatPesM3,Len(aRatPesM3)-1)
				EndIf
			EndIf
		EndIf

		If !Empty(M->DTC_NUMCOT)
			DVF->(dbSetOrder(1))
			If !Empty(M->DTC_FILCFS)
				cFilDVF := TMSA050CFS("DVF",M->DTC_FILCFS)
				cSeek   := cFilDVF+M->DTC_FILCFS+M->DTC_NUMCOT
			Else
				cSeek   := cFilDVF+M->DTC_FILORI+M->DTC_NUMCOT
			EndIf
			If DVF->(MsSeek(cSeek))
				lRet := .F.
				Do While !DVF->(Eof()) .And. DVF->DVF_FILIAL+DVF->DVF_FILORI+DVF->DVF_NUMCOT==cSeek
					If DVF->DVF_CODPRO==cCodPro
						lRet := .T.
						Exit
					EndIf
					DVF->(dbSkip())
				EndDo
				If !lRet
					//-- Ponto de entrada para Validar Produto da Cotacao x Produto da NF
					If lTMA050PCO
						lRet := ExecBlock("TMA050PCO",.F.,.F., {M->DTC_CLIREM, M->DTC_LOJREM, cNumNFC, cSerNFC, cCodPro, M->DTC_NUMCOT, "1" }) // "1" - Indica Execucao do P.E pela funcao TMSA050Vld

						If ValType(lRet) != 'L'
							lRet := .F.
						EndIf
					EndIf

					If !lRet
						Help('',1,'TMSA05055',,M->DTC_CODPRO,3,01) // Este Produto nao pertence a Cotacao de Frete Informada.
						Return( .F. )
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf

ElseIf cCampo == 'M->DTC_CDRDES'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a regiao informada e' de Origem /Destino /Ambas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TmsTipReg( M->DTC_CDRDES, StrZero( 2, Len( DTN->DTN_TIPREG ) ) )
		If Empty(M->DTC_SERVIC)
			Help("",1,"TMSA05018") //Informe o Servico
			Return( .F. )
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
			//³e Tipo de Transporte Informados.                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRDES )
				Return( .F. )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se Nao Existir Destino de Calculo definido para o Cliente Devedor e a Re- ³
			//³giao de Destino, sugerir no Campo Destino de Calculo o Codigo da Regiao   ³
			//³Destino.                                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If !Empty(M->DTC_SQEDES)
					M->DTC_REGCAL := Posicione('DUY',1,xFilial('DUY') + M->DTC_CDRCAL,'DUY_DESCRI')
				Else
					M->DTC_CDRCAL := TMSDestCal( M->DTC_CLIDEV, M->DTC_LOJDEV, M->DTC_CDRDES )
					If Empty(M->DTC_CDRCAL)
						M->DTC_CDRCAL := M->DTC_CDRDES
					EndIf
					M->DTC_REGCAL := Posicione('DUY',1,xFilial('DUY') + M->DTC_CDRCAL,'DUY_DESCRI')
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Retorna a distancia por cliente / regiao.
	If nKm == 0 .And. !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CLIDEV) .And. !Empty(M->DTC_LOJDEV)
		nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
		M->DTC_KM := nKm
	EndIf

ElseIf cCampo == 'M->DTC_CDRCAL'

	//--Recalcula a distancia, mesmo que ja tenha um conteudo no campo DTC_KM
	If !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CLIDEV) .And. !Empty(M->DTC_LOJDEV)
		nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
		M->DTC_KM := nKm
	EndIf

	// Verifica novamente o tipo do documento caso a região de calculo seja alterada
	DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
	DC5->(MsSeek(xFilial("DC5")+ M->DTC_SERVIC))
	If lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
		M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
		If !Empty(M->DTC_DOCTMS)
			M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
		EndIf
	EndIf
	If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F.
			M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
			M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
		EndIf
	EndIf
ElseIf cCampo $ 'M->DTC_DATENT.M->DTC_EMINFC'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nao permitir digitacao de datas maiores que a atual.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If &(ReadVar()) > dDataBase
		lRet := .F.
	EndIf

ElseIf cCampo == 'M->DTC_PESO'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o campo A7_PERCUB/B5_PERCUB esteja preenchido, calcular o percentual  ³
	//³a partir do peso digitado e armazenar o valor obtido no campo DTC_PESOM3.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOptPesCub := A050PesCub(.F.)
	If !Empty(cOptPesCub) .And. cOptPesCub <> '2'
		nPerCub := TmsPerCub(GdFieldGet('DTC_CODPRO',n),M->DTC_CLIDEV,M->DTC_LOJDEV)
		If !Empty(nPerCub)
			GdFieldPut('DTC_PESOM3',M->DTC_PESO + (M->DTC_PESO * (nPerCub/100)), n)
		EndIf
	EndIf
	GdFieldPut('DTC_PESLIQ',0)

ElseIf cCampo == 'M->DTC_PESLIQ'
	lRet := (M->DTC_PESLIQ <= GDFieldGet('DTC_PESO'))

ElseIf cCampo == 'M->DTC_PESOM3'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o campo A7_PERCUB/B5_PERCUB esteja preenchido, calcular o percentual  ³
	//³a partir do peso digitado e armazenar o valor obtido no campo DTC_PESOM3.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOptPesCub := A050PesCub()
	If Empty(cOptPesCub)
		Return( .F. )
	EndIf

	SB5->(dbSetOrder(1))
	If cOptPesCub == '4'  // Peso cubado por M3
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		nFatCub  := Iif(Len(aContrat)>0,aContrat[1][2],0)
		If nFatCub > 0
			nValMetro3 :=  GdFieldGet('DTC_METRO3',n) * nFatCub
			GdFieldPut('DTC_PESOM3', nValMetro3, n)
		EndIf
	ElseIf cOptPesCub == '2'
		If !Empty(M->DTC_CLICAL) // Peso Cubado == Nao
			Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado ... Esta Regra Foi definida no Perfil do Cliente de Calculo Informado
		EndIf
		Return( .F. )
	EndIf

ElseIf cCampo == 'M->DTC_METRO3'
	//-- Apos o preenchimento do campo DTC_METRO3, multiplicar o valor informado pelo fator de cubagem
	//-- do servico e gatilhar o resultado no campo DTC_PESOM3.
	cOptPesCub := A050PesCub()
	If cOptPesCub == '4'  // Peso cubado por M3
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		nFatCub  := Iif(Len(aContrat)>0,aContrat[1][2],0)
		If nFatCub > 0
			nValMetro3 :=  M->DTC_METRO3 * nFatCub
			GdFieldPut('DTC_PESOM3', nValMetro3, n)
		EndIf
	EndIf

ElseIf cCampo== 'M->DTC_VALOR'
	If !l050Auto
		GdFieldPut('DTC_BASSEG',0,n) // Se o Valor da NF for Alterado, Zerar o Valor da Base de Seguro
	EndIf

ElseIf cCampo == 'M->DTC_CDRPER'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a regiao informada e' de Origem /Destino /Ambas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := TmsTipReg( M->DTC_CDRPER, StrZero( 2, Len( DTN->DTN_TIPREG ) ) )

	If lRet

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
		//³e Tipo de Transporte Informados.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRDES )
			Return( .F. )
		EndIf

	EndIf

ElseIf cCampo == 'M->DTC_SERTMS'
	If M->DTC_SERTMS == StrZero( 1, Len(DTC->DTC_SERTMS))
		Help("",1, "TMSA05002") //Nesta Opcao não sera possivel utilizar um servico do tipo "Coleta".
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Origem esta habilitada para o Servico de Transporte ³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRORI )
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRDES )
		Return( .F. )
	EndIf

	If lRet .And.  !Empty(M->DTC_NUMSOL) .And. !TMSA050Vld('DTC_NUMSOL') .And. cSertms == StrZero( 2, Len(DC5->DC5_SERTMS) )
		Help('',1,'TMSA05074',, STR0033 + ': ' + M->DTC_NUMSOL,4,1) //"Solicitacao de Coleta"
		M->DTC_NUMSOL := CriaVar("DTC_NUMSOL")
		Return( .F. )
	EndIf

	//Valida servico
	If !Empty(M->DTC_TIPTRA)
		If FindFunction('TMSLimpaContr')
			TMSLimpaContr()
		EndIf
		TMSA050Srv(1, .T.)
	EndIf

	If lCopiar .Or. l050Altera .Or. !Empty(M->DTC_SERVIC)
		//-- Valida o codigo do servico digitado.
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If Len(aContrat) > 0  .And. aContrat[ 1, 21 ]  != StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
			DC5->( DbSetOrder( 1 ) )
			If DC5->( ! MsSeek( xFilial('DC5') + M->DTC_SERVIC, .F. ) )
				Help(' ', 1, 'TMSA04013')	//-- Codigo do servico nao encontrado (DC5).
				Return( .F. )
			ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' .Or. DC5->DC5_DOCTMS == 'D' .Or. DC5->DC5_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"
				Help("",1,"TMSA05040") // Servico Invalido ...
				Return( .F. )
			ElseIf lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
				M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
				If !Empty(M->DTC_DOCTMS)
					M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
				EndIf
			ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS)
				M->DTC_DOCTMS := DC5->DC5_DOCTMS
				If !Empty(M->DTC_DOCTMS)
					M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
				EndIf
			ElseIf !lIdentDoc .And. DC5->DC5_DOCTMS <> '2' .And. DTP->DTP_TIPLOT == '4'
				Help("",1,"TMSA05092")//Servico Inválido para o Tipo de Lote CT-e Único.
				Return( .F. )
			EndIf
			If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
				DUI->( DbSetOrder( 1 ) )
				If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
					Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
					lRet := .F.
					M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
					M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
				EndIf
			EndIf
		EndIf
	EndIf
	//Validação para não permitir incluir no "Viagem Express Mod. 2 Entrega" Notas Fiscais com Serviço diferente de "3" - Entrega
	If isInCallStack("tmsa144d") .AND. M->DTC_SERTMS != "3"
		lRet := .F.
		Help("",1,"TMSA05090") //O serviço de transporte digitado é diferente do tipo '3' - Entrega
	EndIf

	//Validação para não permitir incluir no "Viagem Express Mod. 2 Transporte" Notas Fiscais com Serviço diferente de "2" - Transporte
	If isInCallStack("tmsa144b") .AND. M->DTC_SERTMS != "2"
		lRet := .F.
		Help("",1,"TMSA05091") //O serviço de transporte digitado é diferente do tipo '2' - Transporte
	EndIf

	//-- Validação para lote
	If lRet
		lRet	:= A050VldDTP(cCampo)
	EndIf

ElseIf cCampo == 'M->DTC_TIPTRA' .And. !Empty(M->DTC_TIPTRA)
	If FindFunction('TMSLimpaContr')
		TMSLimpaContr()
	EndIf

	lSolicServ := .T.
	BEGIN SEQUENCE
		If GdFieldGet('DTC_EDI',n) == '1'//Se for nota EDI e o servico estiver preenchido, nao abre a tela de servico novamente.
			If !Empty(M->DTC_SERVIC)
				lSolicServ := .F.
			EndIf
		EndIF
	END SEQUENCE
	ErrorBlock(oError)

	If IsInCallStack('A050AtuEDI') .OR. !lSolicServ
		TMSA050Srv(1, .F.)
	Else
		TMSA050Srv(1, .T.)
	EndIf
	If lCopiar .Or. l050Altera .Or. !Empty(M->DTC_SERVIC)
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If Len(aContrat) > 0  .And. aContrat[ 1, 21 ]  != StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
			//-- Valida o codigo do servico digitado.
			DC5->( DbSetOrder( 1 ) )
			If DC5->( ! MsSeek( xFilial('DC5') + M->DTC_SERVIC, .F. ) )
				Help(' ', 1, 'TMSA04013')	//-- Codigo do servico nao encontrado (DC5).
				Return( .F. )
			ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' .Or. DC5->DC5_DOCTMS == 'D' .Or. DC5->DC5_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"
				Help("",1,"TMSA05040") // Servico Invalido ...
				Return( .F. )
			ElseIf lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
				M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
				If !Empty(M->DTC_DOCTMS)
					M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
				EndIf
			ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS)
				M->DTC_DOCTMS := DC5->DC5_DOCTMS
				If !Empty(M->DTC_DOCTMS)
					M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
				EndIf
			ElseIf !lIdentDoc .And. DC5->DC5_DOCTMS <> '2' .And. DTP->DTP_TIPLOT == '4'
				Help("",1,"TMSA05092")//Servico Inválido para o Tipo de Lote CT-e Único.
				Return( .F. )
			EndIf
			If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
				DUI->( DbSetOrder( 1 ) )
				If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
					Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
					lRet := .F.
					M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
					M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet
		If Empty(aItContrat) .And. !Empty(M->DTC_CLICAL) .And. !Empty(M->DTC_LOJCAL) .And. !Empty(M->DTC_CODNEG)
			aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
			If Len(aContrat) > 0 .And. aContrat[ 1, 21 ]  <> StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
				Help("",1,"TMSA05042") //Nao foi encontrado servico no contrato do cliente para o servico de transporte e tipo de transporte informados na Nota.
				lRet := .F.
			EndIf
		Else
			//-- Qdo mudar o servico, zera valor informado.
			If !Empty(aValInf) .And. MsgYesNo( STR0052 ) //'Existe valor informado para a nota fiscal, deseja limpar o valor informado na mudanca do servico ?'
				aValInf := {}
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Origem esta habilitada para o Servico de Transporte ³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRORI )
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRDES )
		lRet := .F.
	EndIf

	If lRet
		//-- Retorna a distancia por cliente / regiao.
		If nKm == 0 .And. !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CLIDEV) .And. !Empty(M->DTC_LOJDEV)
			nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
			M->DTC_KM := nKm
		EndIf
	Else
		M->DTC_TIPTRA := CriaVar('DTC_TIPTRA', .F.)
		M->DTC_SERVIC := CriaVar('DTC_SERVIC', .F.)
	EndIf

	If lRet
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If !Empty(aContrat)
			M->DTC_NCONTR := aContrat[1,1]
		EndIf
	EndIf

	If lRet
		If Empty(aItContrat) .And. !Empty(M->DTC_CLICAL) .And. !Empty(M->DTC_LOJCAL) .And. !Empty(M->DTC_CODNEG)
			aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)

			If Len(aContrat) > 0 .And. aContrat[ 1, 21 ]  <> StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
				Help("",1,"TMSA05042") //Nao foi encontrado servico no contrato do cliente para o servico de transporte e tipo de transporte informados na Nota.
				lRet := .F.
			EndIf
		Else
			//-- Qdo mudar o servico, zera valor informado.
			If !Empty(aValInf) .And. MsgYesNo( STR0052 ) //'Existe valor informado para a nota fiscal, deseja limpar o valor informado na mudanca do servico ?'
				aValInf := {}
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Origem esta habilitada para o Servico de Transporte ³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRORI )
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !TmsChkDTN( M->DTC_SERTMS, M->DTC_TIPTRA, M->DTC_CDRDES )
		lRet := .F.
	EndIf

	If lRet
		//-- Retorna a distancia por cliente / regiao.
		If nKm == 0 .And. !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CLIDEV) .And. !Empty(M->DTC_LOJDEV)
			nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
			M->DTC_KM := nKm
		EndIf
	Else
		M->DTC_SERVIC := CriaVar('DTC_SERVIC', .F.)
	EndIf

ElseIf cCampo == 'M->DTC_SERVIC'

	If IsInCallStack("TMSF79Tela")
		lRet := TMSF79VCpo()
	Else
		If Empty(M->DTC_SERVIC) .Or. Len(aItContrat) = 0
			TMSA050Srv(1, .F.)
		EndIf

		If !Empty(M->DTC_SERVIC)
			//-- Valida o codigo do servico digitado.
			DC5->( DbSetOrder( 1 ) )
			If DC5->( ! MsSeek( xFilial('DC5') + M->DTC_SERVIC, .F. ) )
				Help(' ', 1, 'TMSA04013')	//-- Codigo do servico nao encontrado (DC5).
				Return( .F. )
			ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' .Or. DC5->DC5_DOCTMS == 'D' .Or. DC5->DC5_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"
				Help("",1,"TMSA05040") // Servico Invalido ...
				Return( .F. )
			ElseIf DC5->DC5_DOCTMS <> '2' .And. DTP->DTP_TIPLOT == '4'
				Help("",1,"TMSA05092")//Servico Inválido para o Tipo de Lote CT-e Único.
				Return( .F. )
			ElseIf lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
				M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
				If !Empty(M->DTC_DOCTMS)
					M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
				EndIf
			ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS)
				M->DTC_DOCTMS := DC5->DC5_DOCTMS
				If !Empty(M->DTC_DOCTMS)
					M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
				EndIf
			ElseIf !lIdentDoc .And. DC5->DC5_DOCTMS <> '2' .And. DTP->DTP_TIPLOT == '4'
				Help("",1,"TMSA05092")//Servico Inválido para o Tipo de Lote CT-e Único.
				Return( .F. )
			EndIf
			If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
				DUI->( DbSetOrder( 1 ) )
				If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
					Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
					lRet := .F.
					M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
					M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
				EndIf
			EndIf

			nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })
			If nSeek == 0
				Help("",1,"TMSA05040") // Servico Invalido ...
				lRet := .F.
			Else
				//-- Qdo mudar o servico, zera valor informado.
				If !Empty(aValInf) .And. MsgYesNo( STR0052 ) //'Existe valor informado para a nota fiscal, deseja limpar o valor informado na mudanca do servico ?'
					aValInf := {}
				EndIf
			EndIf

		ElseIf lIdentDoc
			M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
			M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
		EndIf
	EndIf

	//-- Valida Contrato De Rateio Com Percentual Fixo
	If lViaCol
		If Len(aContrat) > 0 .And. !Empty(M->DTC_CODNEG) .And. !Empty(M->DTC_SERVIC)
			If !Tmsa050Per( M->DTC_FILORI , M->DTC_LOTNFC , M->DTC_CODNEG , M->DTC_SERVIC , aContrat )
				lRet := .f.
			EndIf
		EndIf
	EndIf
ElseIf cCampo $ "M->DTC_NUMSOL"

    //- Se não houve alteração no campo devolve com valor .T.
    If !TMSA050VAtu(cCampo)
       Return .T.
    EndiF

	If Vazio()
		M->DTC_DATCOL := CtoD(Space(08))
		M->DTC_HORCOL := Space(Len(DTC->DTC_HORCOL))
		M->DTC_DTENTR := CtoD(Space(08))
		M->DTC_HORENT := Space(Len(DTC->DTC_HORENT))
		M->DTC_RECEBE := Space(Len(DTC->DTC_RECEBE))
		M->DTC_EXCTDA := Space(Len(DTC->DTC_EXCTDA))
        M->DTC_NCONTR := Space(Len(DTC->DTC_NCONTR))
		M->DTC_CODNEG := Space(Len(DTC->DTC_CODNEG))
		M->DTC_SERVIC := Space(Len(DTC->DTC_SERVIC))
	Else
		If !Empty(M->DTC_FILCFS)
			cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
			cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
		Else
			cSeek   := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
		EndIf

		If lExped
			M->DTC_CLIEXP := Space(Len(DTC->DTC_CLIEXP))
			M->DTC_LOJEXP := Space(Len(DTC->DTC_LOJEXP))
		EndIf
		If !lLibLtSc .And. !Empty(cSeek)
			lRet := FreeForUse('DTC',cSeek)

			If !lRet
				M->DTC_NUMSOL := Space(Len(DTC->DTC_NUMSOL))
			EndIf
		EndIf

		If lRet
			DTP->(DbSetOrder(2))
			If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
				lCotLot := !Empty(DTP->DTP_NUMCOT)
			EndIf

			If !lCotLot
				If lTM050CCC
					lClrCot := ExecBlock("TM050CCC",.F.,.F.)
					If ValType(lClrCot) != "L"
						lClrCot := .T.
					EndIf
				EndIf
				If lClrCot
					M->DTC_NUMCOT := CriaVar('DTC_NUMCOT', .F.)
				EndIf

				DT5->(dbSetOrder(1))
				If DT5->(MsSeek(cSeek))
					//-- Verifica a filial atual da coleta
					aAreaDT5 := DT5->(GetArea())
					aAreaDTQ := DTQ->(GetArea())
					aAreaDUD := DUD->(GetArea())

					cFilCol := Space(TamSX3("DTQ_FILORI")[1])
					cViaCol := Space(TamSX3("DTQ_VIAGEM")[1])

					//-- Retorna a viagem da Solicitacao de coleta
					DUD->(DbSetOrder(1))
					If DUD->(MsSeek(xFilial("DUD")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
						While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE == ;
							xFilial("DUD") + DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE
							If	DUD->DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS)) .And.;	//-- Cancelado
								DUD->DUD_STATUS <> StrZero(4, Len(DUD->DUD_STATUS)) 		//-- Encerrado
									cFilCol := DUD->DUD_FILORI
									cViaCol := DUD->DUD_VIAGEM
									Exit
							EndIf
							DUD->(DbSkip())
						EndDo
					EndIf

					DbSelectArea("DTQ")
					DTQ->(DbSetOrder(2))
					If DTQ->(DbSeek(xFilial("DTQ")+cFilCol+cViaCol))
						If DTQ->DTQ_FILATU <> cFilAnt
							Help("",1,"TMSA05089",,DTQ->DTQ_FILATU,3,01 ) //-- Manutencoes nesta solicitação de coleta, somente serao permitidas na filial
							lRet := .F.
						EndIf
					EndIf

					RestArea(aAreaDT5)
					RestArea(aAreaDTQ)
					RestArea(aAreaDUD)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³STATUS DAS SOLICITACOES DE COLETA:                                        ³
					//³1-EM ABERTO | 2-INDICADA PARA COLETA | 3-EM TRANSITO | 4-ENCERRADA        ³
					//³5-DOCUMENTO INFORMADO | 6-BLOQUEADA 9-CANCELADA                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet

						// Valida o Status da Coleta
						lRet := VldStsCol(lTmsCFec,M->DTC_SERTMS,0,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)

						If lRet .AND. lTmsCFec
							DUD->(DbSetOrder(1))
							If DUD->(MsSeek(xFilial("DUD")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
								While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE == ;
										xFilial("DUD") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE
									If DUD->DUD_STATUS <> StrZero(9,Len(DUD->DUD_STATUS)) //-- Cancelado
										cFilCol := DUD->DUD_FILORI
										cVgeCol := DUD->DUD_VIAGEM
										Exit
									EndIf
									DUD->(DbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
				Else
					Help("",1,"REGNOIS")
					lRet := .F.
				EndIf

				If lRet
					If !Empty(DT5->DT5_NUMCOT)
						SeleItCF(DT5->DT5_FILORI,DT5->DT5_NUMCOT) //-- Preenche os campos da Enchoice com os dados da Cotacao de Frete
					EndIf

					//-- Preenche os campos Remetente e Sequencia Endereco(se existir), Destinatario e Seq.Endereco(Se Existir)
					If SubStr(FunName(),1,7) == "TMSA050" .And. TMSA050VAtu(cCampo)
						TM050SCFil(M->DTC_FILCFS,M->DTC_NUMSOL)

					//-- Se validacao provem da Rotina de Viagem usando o Express
					ElseIf TmsExp() .And. Substr(FunName(),1,7) == "TMSA144"
						cVeiEnt:= ''
						cMotEnt:= ''

						If lTMSCFec
							aAreaDTQ:= GetArea("DTQ")
							aAreaDTR:= GetArea("DTR")
							aAreaDUP:= GetArea("DUP")

							DTR->(DbSetOrder(1))
							If DTR->(MsSeek(xFilial("DTR")+M->DTQ_FILORI+M->DTQ_VIAGEM))
								cVeiEnt:= DTR->DTR_CODVEI

								DUP->(dbSetOrder(1))
								If DUP->(MsSeek(xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM))
									cMotEnt:= DUP->DUP_CODMOT
								EndIf
							EndIf

							DTQ->(DbSetOrder(2))
							If DTQ->(MsSeek(xFilial("DTQ")+cFilCol+cVgeCol))
								If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .And.;  //Viagem com Status em aberto
									DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) .And.;  //Serviço Coleta
									DTQ->DTQ_TIPVIA == StrZero(3,Len(DTQ->DTQ_TIPVIA))         //Planejada

									DTR->(DbSetOrder(1))
									If DTR->(MsSeek(xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
										DUP->(dbSetOrder(1))
										If DUP->(MsSeek(xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM))
											If DTR->DTR_CODVEI <> cVeiEnt .Or. DUP->DUP_CODMOT <> cMotEnt
												MsgAlert(STR0084) //"Veiculo / Motorista diferente da Viagem Planejada de Coleta"
											EndIf
										EndIf
									EndIf
								EndIf
								If lServic .And. !Empty(DT5->DT5_SERVIC) .And.DTQ->DTQ_STATUS != StrZero(3, Len(DTQ->DTQ_STATUS)) // Rateio de coleta: não permitir informar solicitações de coleta para viagens de coletas não encerradas.
									Help(" ",1,"TMSA050B3") // Somente sera permitido informar Solicitações de Coleta que estiverem em Viagem de Coleta Encerrada.
									lRet := .F.
								Endif
							EndIf

							RestArea(aAreaDTQ)
							RestArea(aAreaDTR)
							RestArea(aAreaDUP)
						EndIf
					EndIf
				EndIf

				//-- Limpa as variaveis para validar novamente a solicitacao de coleta
				If !lRet
					cNumSolDif := ''
	    			cSerTmsDif := ''
				EndIf

			EndIf
		EndIf

	EndIf
ElseIf cCampo $ 'M->DTC_QTDVOL'
	If M->DTC_QTDVOL <> GdFieldGet('DTC_QTDVOL',n)
		cNumNFC := GdFieldGet('DTC_NUMNFC',n)
		cSerNFC := GdFieldGet('DTC_SERNFC',n)
		cCodPro := GdFieldGet('DTC_CODPRO',n)
		If !l050Auto
			nSeek := Ascan( aEndProd,{|x| x[1] == cNumNFC + cSerNFC + cCodPro})
			If nSeek > 0
				aDel(aEndProd,nSeek)
				aSize(aEndProd,Len(aEndProd)-1)
			EndIf

			nSeek := Ascan( aRatPesM3,{|x| x[1] == cNumNFC + cSerNFC + cCodPro})
			If nSeek > 0
				aDel(aRatPesM3,nSeek)
				aSize(aRatPesM3,Len(aRatPesM3)-1)
			EndIf
		EndIf
	EndIf

ElseIf cCampo $ 'M->DTC_ALIANC;M->DTC_FILDPC'
	//-- Atualiza o Redespacho Local
	If Empty(M->DTC_ALIANC)
		M->DTC_DPCLOC := "2" //-- Nao e Redespacho Local
	EndIf

	//-- Validacao para 1o. percurso de alianca
	If !Empty(M->DTC_ALIANC) .And. TmsA050Dpc()
		DVL->(DbSetOrder(1))
		DVK->(DbSetOrder(1))
		lRet := .F.
		If DVK->(MsSeek(cSeekDVK := xFilial("DVK")+M->DTC_CDRCAL))
			While DVK->( !Eof() .And. DVK->(DVK_FILIAL+DVK_GRPVEN) == cSeekDVK )
				If M->DTC_ALIANC == Posicione("DVL",1,xFilial("DVL")+DVK->DVK_FILALI,"DVL_ALIANC")
					lRet := .T.
				EndIf
				DVK->(dbSkip())
			EndDo
		Else
			lRet := .F.
		EndIf

		If !lRet
			cFilDes := Posicione("DUY",1,xFilial("DUY")+M->DTC_CDRCAL,"DUY_FILDES")
			If DVL->(MsSeek(xFilial("DVL")+cFilDes)) .And. DVL->DVL_ALIANC == M->DTC_ALIANC
				lRet := .T.
			EndIf
		EndIf

		If !lRet
			Help(" ",1,"TMSA05029") //-- A Filial Alianca informada nao esta configurada para a regiao destino
		EndIf
	EndIf

//-- Carga Fechada
ElseIf cCampo $ 'M->DTC_DATCOL,M->DTC_HORCOL,M->DTC_DTENTR,M->DTC_HORENT'
	If At("M->",cCampo) == 0
		cCampo := "M->" + cCampo
	EndIf

	If !Empty(&(cCampo))
		If Empty(M->DTC_NUMSOL)
			Help(" ",1,"TMSA05061") // Somente sera permitido informar a data e hora da coleta quando o campo numero da solicitacao de coleta estiver preenchido.
			lRet := .F.
		EndIf

		If lRet
			DT5->(dbSetOrder(1))
			If !Empty(M->DTC_FILCFS)
				cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
				cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
			Else
				cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
			EndIf
			If DT5->(MsSeek(cSeek))
				DF6->(DbSetOrder(2))
				If DF6->(MsSeek(xFilial('DF6')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
					Help('',1,'TMSA05071') //-- 'Existe conferencia de coleta lancada para esta solicitacao de coleta. A digitacao da data/hora de coleta nao sera permitida.'
					lRet := .F.
				EndIf
			EndIf
		EndIf

		//-- Nao permite informar data/hora de coleta para solicitacao de coleta encerrada.
		If cCampo $ 'M->DTC_DATCOL,M->DTC_HORCOL'
			DT5->(dbSetOrder(1))
			If !Empty(M->DTC_FILCFS)
				cFilDT5 := TMSA050CFS("DT5",M->DTC_FILCFS)
				cSeek   := cFilDT5+M->DTC_FILCFS+M->DTC_NUMSOL
			Else
				cSeek := cFilDT5+M->DTC_FILORI+M->DTC_NUMSOL
			EndIf
			If lRet .And. DT5->(MsSeek(cSeek))
				If DT5->DT5_STATUS == StrZero(4,Len(DT5->DT5_STATUS)) .Or. DT5->DT5_STATUS == StrZero(5,Len(DT5->DT5_STATUS)) //-- Encerrada ou Documento Informado
					Help(" ",1,"TMSA05064") // Nao sera permitido informar a data e hora da coleta quando solicitacao de coleta estiver encerrada ou com documento informado.
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(M->DTC_DATCOL) .And. !Empty(M->DTC_HORCOL)
					lRet := A050ApoCol() //Determina o codigo da ocorrencia para apontamento automatico da coleta.
				EndIf
			EndIf
			If lRet .And. DT5->(MsSeek(cSeek)) .And. !Empty(M->DTC_DATCOL)
				cAliasQry := GetNextAlias()
				cQuery := " SELECT MIN(DTQ_DATGER) DATGER "
				cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
				cQuery += "   JOIN " + RetSqlName("DTQ") + " DTQ "
				cQuery += "     ON  DTQ_FILIAL = '" + xFilial("DTQ") + "' "
				cQuery += "     AND DTQ_FILORI = DUD_FILORI "
				cQuery += "     AND DTQ_VIAGEM = DUD_VIAGEM "
				cQuery += "     AND DTQ.D_E_L_E_T_ = ' ' "
				cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
				cQuery += "     AND DUD_FILDOC = '" + DT5->DT5_FILDOC + "' "
				cQuery += "     AND DUD_DOC    = '" + DT5->DT5_DOC    + "' "
				cQuery += "     AND DUD_SERIE  = '" + DT5->DT5_SERIE  + "' "
				cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				TcSetField(cAliasQry,"DATGER","D",8,0)
				If (cAliasQry)->(!Eof()) .And. (cAliasQry)->DATGER > M->DTC_DATCOL
					Help("",1,"TMSA05068")  //-- Data da Coleta inferior a data da viagem
					lRet := .F.
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
		EndIf

		If lRet .And. cCampo $ 'M->DTC_HORCOL'
			lRet := AtVldHora(M->DTC_HORCOL)
		EndIf

		If lRet .And. cCampo $ 'M->DTC_HORENT'
			lRet := AtVldHora(M->DTC_HORENT)
		EndIf
	EndIf

ElseIf cCampo $ 'M->DTC_FILCFS'
	If !Empty(M->DTC_NUMCOT)
		TMSA050Clear()
	ElseIf !Empty(M->DTC_NUMSOL) .And. IsInCallStack('TMSAF76')
		TMSA050Clear()
	EndIf
//-- Sequencia Destinatario
ElseIf cCampo $ 'M->DTC_SQEDES'

	If !Empty(M->DTC_SQEDES)
		aArea := DUL->(GetArea())
		DUL->(DbSetOrder(2))
		If !DUL->(MsSeek(xFilial("DUL")+M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SQEDES))
			Help(" ",1,"TMSAF0504") //-- Sequencia de endereco nao encontrada para o Cliente.
			lRet := .F.
		Else
			M->DTC_CDRCAL := DUL->DUL_CDRDES
			M->DTC_REGCAL := Posicione("DUY",1,xFilial("DUY")+DUL->DUL_CDRDES,"DUY_DESCRI")
			If DTC->(ColumnPos("DTC_CLIREC")) > 0
				M->DTC_CLIREC := DUL->DUL_CODRED
				M->DTC_LOJREC := DUL->DUL_LOJRED
				M->DTC_NOMREC := Posicione("SA1",1,xFilial("SA1")+DUL->DUL_CODRED+DUL->DUL_LOJRED,"A1_NOME")
			EndIf
		EndIf
		RestArea( aArea )
		//-- redefine o tipo de documento
		aAreaDC5 := DC5->(GetArea())
		DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
		DC5->(MsSeek(xFilial("DC5") + M->DTC_SERVIC))
		If lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
			M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
			If !Empty(M->DTC_DOCTMS)
				M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
			EndIf
		EndIf
		RestArea( aAreaDC5)
	Else
		//-- Executa Gatilho do campo DTC_CLIDES (Destinatario)
		RunTrigger(1,Nil,Nil,,"DTC_CLIDES")
		If DTC->(ColumnPos("DTC_CLIREC")) > 0
			M->DTC_CLIREC := CriaVar("DTC_CLIREC",.F.)
			M->DTC_LOJREC := CriaVar("DTC_LOJREC",.F.)
			M->DTC_NOMREC := CriaVar("DTC_NOMREC",.F.)
		EndIf
	EndIf

//-- Distancia Ida/Volta
ElseIf cCampo $ 'M->DTC_DISTIV,M->DTC_SELORI'
	If cCampo $ 'M->DTC_SELORI'
		lRet := TMSSelOri("DTC",M->DTC_SELORI,M->DTC_CLIREM,M->DTC_LOJREM,,M->DTC_FILORI,M->DTC_NUMSOL)
		If lRet
			If  !Empty(DTP->DTP_NUMCOT)
				DT4->(DbSetOrder(1))
				If DT4->(MsSeek(xFilial('DT4')+DTP->DTP_FILORI+DTP->DTP_NUMCOT))
					If DT4->DT4_SELORI <> 	M->DTC_SELORI
						If !MsgNoYes(STR0081) //"A seleção de origem está diferente da cotação de frete. Confirma ?"
							lRet:=.F.
						Else
							MsgAlert(STR0082) //"Poderá ocorrer divergências de valores entre cotação e cálculo de frete !"
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
		M->DTC_KM := nKm
	EndIf

	DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
	DC5->(MsSeek(xFilial("DC5")+ M->DTC_SERVIC))
	If lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
		M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
		If !Empty(M->DTC_DOCTMS)
			M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
		EndIf
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F.
			M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
			M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
		EndIf
	EndIf
ElseIf cCampo $ 'M->DTC_VALSEG'
	lRet := Positivo()

ElseIf cCampo $ 'M->DTC_DEVFRE'

	//-- Quando o campo DTC_TIPNFC = '9-Redespacho Intermediario' as seguintes opcoes do campo DTC_DEVFRE serao invalidadas:
	//--	1=Remitente;2=Destinatario; 
	//--    e serao aceitas somente:
	//--    3=Consignatario;4=Despachante;6=Expedidor;7=Receptor;
	If M->DTC_TIPNFC == "9"
		If M->DTC_DEVFRE $ "1|2"
			Help(" ",1,"TMSA050RI01",,"Para o Tipo de Nota Fiscal de Redespacho Intermediario, somente os tipos 3=Consignatario,4=Despachante,6=Expedidor e 7=Recebedor serão aceitos como devedor de frete.",5,1)
			Return .F.
		EndIf
	EndIf

	//--Ao trocar o devedor, precisamos validar novamente se o servico e valido
	//--Se o tipo de transporte esta vazio nao precisa validar, pois o valid do campo tiptra na primeira vez
	//--ja faz esta validacao
	If !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CODNEG)
		TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,,;
						M->DTC_TIPFRE,l050Auto,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL, /*lPortalTMS*/,;
						lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

		If lRet
			If Empty(aItContrat) .And. !Empty(M->DTC_CLICAL) .And. !Empty(M->DTC_LOJCAL)
				aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
				If Len(aContrat) > 0 .And. aContrat[ 1, 21 ]  <> StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
					Help("",1,"TMSA05042") //Nao foi encontrado servico no contrato do cliente para o servico de transporte e tipo de transporte informados na Nota.
					lRet := .F.
				EndIf
			Else
				//-- Qdo mudar o servico, zera valor informado.
				If !Empty(aValInf) .And. MsgYesNo( STR0052 ) //"Existe valor informado para a nota fiscal, deseja limpar o valor informado na mudanca do servico ?"
					aValInf := {}
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet
		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If !Empty(aContrat)
			M->DTC_NCONTR := aContrat[1,1]
			//-- Valida Contrato De Rateio Com Percentual Fixo
			If !Empty(M->DTC_CODNEG) .And. !Empty(M->DTC_SERVIC)
				If !Tmsa050Per( M->DTC_FILORI , M->DTC_LOTNFC , M->DTC_CODNEG , M->DTC_SERVIC , aContrat )
					lRet := .f.
				EndIf
			EndIf
		EndIf
	EndIf


	//-- Ponto de entrada no get da nota
	If ExistBlock('TM050GET')
		ExecBlock('TM050GET',.F.,.F.)
	EndIf

	// Limpa o perfil que está em cache
	If FindFunction('TMSLimpaPerfil')
		TMSLimpaPerfil()
	EndIf

ElseIf cCampo $ 'M->DTC_DATAGD.M->DTC_INIAGD.M->DTC_FIMAGD.M->DTC_TIPAGD.M->DTC_PRDAGD.M->DTC_MOTAGD'
	//-- Agendamento de Entrega
	If cTipAgdEnt == "3"  .AND. !Empty(&cCampo)  //-- Digitação OBRIGATÓRIA de Agendamento de Entrega
		If cCampo == "M->DTC_DATAGD"
			If &cCampo < dDataBase .OR. !TMSA018Vld(,&cCampo,GdFieldGet('DTC_INIAGD',n),GdFieldGet('DTC_FIMAGD',n))
				lRet := .F.
			EndIf
		ElseIf cCampo == "M->DTC_INIAGD"
			If (GdFieldGet('DTC_PRDAGD',n) <> '2' .And. !AtVldHora(M->DTC_INIAGD)) .OR. !TMSA018Vld(,GdFieldGet('DTC_DATAGD',n),,GdFieldGet('DTC_FIMAGD',n))
				lRet := .F.
			EndIf
		ElseIf cCampo == "M->DTC_FIMAGD"
		   If (!(GdFieldGet('DTC_PRDAGD',n) $ '1,4') .And. !AtVldHora(M->DTC_FIMAGD)) .OR. !TMSA018Vld(,GdFieldGet('DTC_DATAGD',n),GdFieldGet('DTC_INIAGD',n))
				lRet := .F.
			EndIf
		ElseIf cCampo == "M->DTC_PRDAGD"
			If !Pertence("1234")
				lRet := .F.
			Else
				GdFieldPut('DTC_FIMAGD',Space(TamSX3('DTC_FIMAGD')[1]),n)
				GdFieldPut('DTC_INIAGD',Space(TamSX3('DTC_INIAGD')[1]),n)
				GdFieldPut('DTC_PRDAGD',&cCampo,n)
			EndIf
	 	EndIf
 	EndIf
ElseIf cCampo $ 'M->DTC_ORIRAT'
	If !Empty(M->DTC_ORIRAT)
		//aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		//lRet := Iif(lRateio .And. ( (aContrat[Len(aContrat)][42] == "3") .Or. ((aContrat[Len(aContrat)][42] == "2") .And. (aContrat[Len(aContrat)][41] == "2"))  ) , .T., .F.)

		//If !lRet
		//	Help("",1,"TMSA05096") //-- O campo só poderá ser preenchido para quando o lote e serviço estiverem configurados para rateio.
		//Else
			lRet := ExistCpo("DUY", M->DTC_ORIRAT, 1)
		//EndIf
	EndIf

ElseIf cCampo $ 'M->DTC_CALRAT'
	If !Empty(M->DTC_CALRAT)
		//aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
		//lRet := Iif(lRateio .And. ( (aContrat[Len(aContrat)][42] == "3") .Or. ((aContrat[Len(aContrat)][42] == "2") .And. (aContrat[Len(aContrat)][41] == "2")) ) ;
		//.And. Empty(cORIRAT) .And. Empty(cCALRAT), .T., .F.)

		//If !lRet
		//	Help("",1,"TMSA05096") //-- // Informe Permido Apenas para Rateios Consolidados !
		//Else
			lRet := ExistCpo("DUY", M->DTC_CALRAT, 1)
		//EndIf
	EndIf
ElseIf cCampo == "M->DTC_CODNEG"
    If IsInCallStack("TMSF79Tela")
        lRet := TMSF79VCpo()
    Else
        If !Empty(M->DTC_CODNEG) .And. !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CLICAL) .And. !Empty(M->DTC_LOJCAL)
            lRet := TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,,;
                            M->DTC_TIPFRE,l050Auto,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,,;
                            lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG)
            If lRet
                If Empty(aItContrat) .And. !Empty(M->DTC_CLICAL) .And. !Empty(M->DTC_LOJCAL)
                    aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
                    If Len(aContrat) > 0 .And. aContrat[ 1, 21 ]  <> StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
                        Help("",1,"TMSA05042") //Nao foi encontrado servico no contrato do cliente para o servico de transporte e tipo de transporte informados na Nota.
                        M->DTC_SERVIC := Space(TamSx3('DTC_SERVIC')[1]) //-- limpa o conteúdo do campo Serviço ao apresentar este help().
                        lRet := .F.
                        M->DTC_CODNEG := CriaVar("DTC_CODNEG" , .F. )
                    EndIf
                Else
                    //-- Qdo mudar o servico, zera valor informado.
                    If !Empty(aValInf) .And. MsgYesNo( STR0052 ) //"Existe valor informado para a nota fiscal, deseja limpar o valor informado na mudanca do servico ?"
                        aValInf := {}
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

	If lRet

		aContrat := TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)

		If !Empty(aContrat)

			M->DTC_NCONTR := aContrat[1,1]

			If !Empty(M->DTC_CODNEG)
				DDC->(DbSetOrder(2))//DDC_FILIAL+DDC_NCONTR+DDC_CODNEG
				If !DDC->( MsSeek( xFilial('DDC') + M->DTC_NCONTR + M->DTC_CODNEG) )
					Help("",1,"TMSA050B0") //Verifique negociação no contrato do cliente.
					lRet := .F.
			   Endif
			Endif

			//-- Valida Contrato De Rateio Com Percentual Fixo
			If !Tmsa050Per( M->DTC_FILORI , M->DTC_LOTNFC , M->DTC_CODNEG , M->DTC_SERVIC , aContrat )
				Return(.f.)
			EndIf
		EndIf
	EndIf
	If lRet
		//-- Identificação do Tipo de Documento
		//-- Com o Item de contrato habilitado.
		DC5->( DbSetOrder( 1 ) )
		If DC5->( ! MsSeek( xFilial('DC5') + M->DTC_SERVIC, .F. ) ) .And. !Empty(M->DTC_SERVIC)
			Help(' ', 1, 'TMSA04013')	//-- Codigo do servico nao encontrado (DC5).
			Return( .F. )
		ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' .Or. DC5->DC5_DOCTMS == 'D' .Or. DC5->DC5_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"
			Help("",1,"TMSA05040") // Servico Invalido ...
			Return( .F. )
		ElseIf lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
			M->DTC_DOCTMS := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
			If !Empty(M->DTC_DOCTMS)
				M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
			EndIf
		ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS)
			M->DTC_DOCTMS := DC5->DC5_DOCTMS
			If !Empty(M->DTC_DOCTMS)
				M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
			EndIf
		ElseIf !lIdentDoc .And. DC5->DC5_DOCTMS <> '2' .And. DTP->DTP_TIPLOT == '4'
			Help("",1,"TMSA05092")//Servico Inválido para o Tipo de Lote CT-e Único.
			Return( .F. )
		EndIf
		If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
			DUI->( DbSetOrder( 1 ) )
			If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
				Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
				lRet := .F.
				M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
				M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
			EndIf
		EndIf
	EndIf

ElseIf cCampo $ 'M->DTC_DOCTMS'
	If M->DTC_DOCTMS == '7' .Or. M->DTC_DOCTMS == '8' .Or. M->DTC_DOCTMS == 'D' .Or. M->DTC_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"
		Help("",1,"TMSA050A10") // Tipo de Documento inválido.
		Return( .F. )
	EndIf
	If M->DTC_DOCTMS <> '2' .And. DTP->DTP_TIPLOT == '4'
		Help("",1,"TMSA05092") //Servico Inválido para o Tipo de Lote CT-e Único.
		Return( .F. )
	EndIf
	If lIdentDoc .And. M->DTC_DOCTMS == StrZero(6,Len(DTC->DTC_DOCTMS))
		M->DTC_TIPNFC := StrZero(1,Len(DTC->DTC_TIPNFC))
	EndIf

	If lIdentDoc .And. Len(aContrat) > 0  .And. aContrat[ 1, 21 ]  == StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
		lRet := .F.
	EndIf
	If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F.
			M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
			M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
		EndIf
	EndIf
ElseIf cCampo $ 'M->DTC_TIPNFC'
	If lIdentDoc .And. M->DTC_TIPNFC == StrZero(1,Len(DTC->DTC_TIPNFC))
		M->DTC_DOCTMS := StrZero(6,Len(DTC->DTC_DOCTMS))
		M->DTC_DESDOC := TMSValField("M->DTC_DOCTMS",.F.,"DTC_DESDOC")
	EndIf
	If lIdentDoc .And. !Empty(M->DTC_DOCTMS)
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + M->DTC_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0035 + M->DTC_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F.
			M->DTC_DOCTMS := CriaVar('DTC_DOCTMS', .F.)
			M->DTC_DESDOC := CriaVar('DTC_DESDOC', .F.)
		EndIf
	EndIf
	
ElseIf cCampo $ 'M->DTC_CTEANT'
    cChave := M->DTC_CTEANT
	If M->DTC_TIPNFC == '9' .And. !Empty(cChave) .And. Len(cChave) == 44
		GdFieldPut( "DTC_CTRDPC", SubStr(cChave, 26, 9), n ) // Documento
		GdFieldPut( "DTC_SERDPC", SubStr(cChave, 23, 3), n ) // Serie
		GdFieldPut( "DTC_NUMNFC", SubStr(cChave, 26, 9), n ) // Numero da NF
		GdFieldPut( "DTC_SERNFC", SubStr(cChave, 23, 3), n ) // Serie  da NF
		lRet := .T.
	ElseIf M->DTC_TIPNFC == '9' .And. Empty(cChave)
		CheckHLP('PTMSA050D5', {'Chave do documento obrigatória ao ',' utilizar Redespacho Intermediário.',''},{''},{''},.T.)
		HELP(" ",1,"TMSA050D5") //Chave do documento obrigatória ao utilizar Redespacho Intermediário.
		lRet := .F.
	ElseIf M->DTC_TIPNFC == '2' .And. !Empty(cChave) .And. !Empty(cIsenSub)
		cUfOri		:= Posicione("DUY",1, xFilial('DUY')+ M->DTC_CDRORI ,"DUY_EST")
		cCNPJSub 	:= SubStr(cChave, 7, 14) //-CNPJ do subcontratado
		aFilSM0		:= FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_CGC"} )
		cCNPJFil	:= aFilSM0[1][2]
		If cCNPJSub == cCNPJFil .And. cUfOri $ cIsenSub 
			HELP(" ",1,"TMSA050D8") // Devido a configuração do parâmetro MV_ISENSUB, a chave eletrônica a ser relacionada neste campo deve ser a do CTE da contratante. 
			lRet := .F.
		EndIf 
	EndIf
EndIf
RestArea(aAreaDTC)
RestArea(aAreaSA1)
RestArea(aAreaAnt)

If !IsInCallStack("TMSF79Tela") .And. !l050Auto
	o1Get:oBrowse:Refresh( .T. )
	n := nOld
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Dev³ Autor ³ Patricia A. Salomao   ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica quem sera o devedor do frete                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Dev(ExpC1, ExpL1, ExpL2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo/Loja do Cliente Generico (MV_CLIGEN)        ³±±
±±³          ³ ExpL1 - Valida se Verifica ou Nao as Cotacoes de Frete e   ³±±
±±³          ³         se mostra na Tela a Obs. dos Pagadores do Frete    ³±±
±±³          ³ ExpL2 - Verifica se a chamada foi na TudoOk()              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Dev(cCliGen,lVerifica,lTudoOk,cCampo)

Local lContinua   := .T.
Local aArea       := GetArea()
Local lDevFrete   := .F.
Local lRet        := .T.
Local lAlianca    := TMSAlianca() //-- Utiliza Alianca
Local cClGen, cLjGen

Default cCliGen   := GetMV("MV_CLIGEN")
Default lVerifica := .T.
Default lTudoOk   := .F.
Default cCampo    := ''

If Empty(cCampo)
	cCampo := ReadVar()
EndIf

//-- Nao executar esta funcao se ela estiver sendo chamada pela TudoOK() e for 2o. Percurso (Alianca)
If lTudoOk .And. lAlianca .And. TmsA050Dpc()
	Return( .T. )
EndIf

cClGen := Left(Alltrim(cCliGen),Len(DTC->DTC_CLIREM))
cLjGen := Right(Alltrim(cCliGen),Len(DTC->DTC_LOJREM))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Cotacoes  de Frete Aprovadas para o Remetente e Des-   ³
//³ tinatario informados.                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVerifica .And. !lTudoOk .And. cCampo $ 'M->DTC_CLIREM.M->DTC_LOJREM.M->DTC_CLIDES.M->DTC_LOJDES'
	SeleItCF()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Tiver Cotacao de Frete ou Consignatario Nao devera checar a Regra dos  ³
//³Pagadores de Frete.                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!Empty(M->DTC_NUMCOT))
	RestArea(aArea)
	Return( .T. )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ainda nao determinou o devedor do frete, continua verificando          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lDevFrete
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica na tabela DTI (Consignatarios) quem sera' o Devedor do Frete:    ³
	//³ 1- Remetente + Destinatario                                               ³
	//³ 2- Remetente + Cliente Generico                                           ³
	//³ 1- Cliente Generico + Destinatario                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TmsConsig( M->DTC_CLIREM,M->DTC_LOJREM,M->DTC_CLIDES,M->DTC_LOJDES)
		lContinua := .F.
	ElseIf TmsConsig(M->DTC_CLIREM,M->DTC_LOJREM,cClGen,cLjGen)
		lContinua := .F.
	ElseIf TmsConsig(cClGen,cLjGen,M->DTC_CLIDES,M->DTC_LOJDES)
		lContinua := .F.
	EndIf
	If !lContinua .And. !'TMSAI70' $ FunName()
		M->DTC_DEVFRE := "3" // Consignatario
		M->DTC_TIPFRE := DTI->DTI_TIPFRE
		M->DTC_CLICON := DTI->DTI_CLICON
		M->DTC_LOJCON := DTI->DTI_LOJCON
		M->DTC_NOMCON := Posicione( "SA1", 1, xFilial( "SA1" ) + M->DTC_CLICON + M->DTC_LOJCON, "A1_NOME" )
		//-- Sugere Incoterm
		TMA050Inc()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao encontrar Devedor do Frete na tabela DTI (Consignatarios),verificar³
		//³ quem sera' o Devedor do Frete na Tabela DTJ (Pagadores do Frete):         ³
		//³ 1- Verificar a Condicao do Frete (DUO_CNDFRE) de todos os Clientes.       ³
		//³ 2- O Resultado da pesquisa, sera' a chave de pesquisa na tabela DTJ.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := TMSA050PagFre(lVerifica,lTudoOk)
	EndIf

	If !lContinua
		lAutomatic := .T.
	EndIf
EndIf

// Se a Funcao TMSA050Dev() estiver sendo chamada pela TudoOk(), a funcao TMSA050Fre() nao podera
// ser executada, pois os campos ja informados poderiam ter seus valores alterados ...
If !lTudoOk
	//-- Valida Cliente Devedor
	lRet := TMSA050Fre()

	//-- Se for 2o. Percurso, o devedor do frete podera ser alterado 'manualmente' (lAutomatic := .F.)
	If lAlianca .And. TmsA050Dpc()
		lAutomatic := .F.
		//-- Executa o Ponto de Entrada TM050DEV para que o usuario possa alterar o conteudo
		//-- das variaveis de memoria
		If lTM050DEV // Se existe o Ponto de Entrada TM050DEV
			lRet := ExecBlock('TM050DEV',.F.,.F.)
			If	ValType(lRet) <> 'L'
				lRet := .T.
			EndIf
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Fre³ Autor ³ Patricia A. Salomao   ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o Tipo de Frete                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Fre()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function  TMSA050Fre()

Local aPerfil  := {}
Local aContrat := {}
Local lRet     := .T.
Local lOk      := .T.
Local cCodCli  := ""
Local cLojCli  := ""
//-- Variaveis utilizadas na verificacao do cliente de calculo
Local aCliCalc   := {}
Local cOptPesCub := ''
Local nPosPeso   := Ascan(aHeader, { |x| Alltrim(x[2]) == 'DTC_PESO'})
Local nX
Local lSinc      := TmsSinc() //-- Chamada do Sincroizador
Local lAlianca   := TmsAlianca() //-- Utiliza Alianca
Local nKm        := M->DTC_KM
Local lMV_TMSFOB := SuperGetMv("MV_TMSFOB",.F.,.T.) //-- Define se o frete devera ser FOB para consignatario ou despachante

l050Auto := If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

If lSinc
	lAutomatic := .T.
ElseIf Type("lAutomatic") == "U"
	lAutomatic := .F.
EndIf

If !Empty(M->DTC_NUMCOT)
	Return( .T. )
EndIf


//-- Quando o campo DTC_TIPNFC = '9-Redespacho Intermediario' as seguintes opcoes do campo DTC_DEVFRE serao invalidadas:
//--	1=Remitente;2=Destinatario; 
//--    e serao aceitas somente:
//--    3=Consignatario;4=Despachante;6=Expedidor;7=Receptor;
If M->DTC_TIPNFC == "9"
	If M->DTC_DEVFRE $ "1|2"
		//--"Para o Tipo de Nota Fiscal de Redespacho Intermediario, somente os tipos 3=Consignatario,4=Despachante,6=Expedidor e 7=Recebedor serão aceitos como devedor do frete."
		Help(" ",1,"TMSA050RI01",,STR0172,4,1)
		Return .F.
	EndIf
EndIf

If !Empty(M->DTC_DEVFRE)
	If M->DTC_DEVFRE == '1'  //Remetente
		cCodCli := M->DTC_CLIREM
		cLojCli := M->DTC_LOJREM
	ElseIf M->DTC_DEVFRE == '2' //Destinatario
		cCodCli := M->DTC_CLIDES
		cLojCli := M->DTC_LOJDES
	ElseIf M->DTC_DEVFRE == '3' //Consignatario
		cCodCli := M->DTC_CLICON
		cLojCli := M->DTC_LOJCON
	ElseIf M->DTC_DEVFRE == '4' //Despachante
		cCodCli := M->DTC_CLIDPC
		cLojCli := M->DTC_LOJDPC
	ElseIf M->DTC_DEVFRE == '6' //Expedidor
		cCodCli := M->DTC_CLIEXP
		cLojCli := M->DTC_LOJEXP
	ElseIf M->DTC_DEVFRE == '7' //Recebedor
		cCodCli := Iif(DTC->(ColumnPos("DTC_CLIREC")) > 0,M->DTC_CLIREC,'')
		cLojCli := Iif(DTC->(ColumnPos("DTC_LOJREC")) > 0,M->DTC_LOJREC,'')
	Else
		//--Tipo de frete exclusivo para o Transporte Internacional
		If M->DTC_DEVFRE == '5' .And. lAutomatic //--Outros
			cCodCli := M->DIK_CLIDEV
			cLojCli := M->DIK_LOJDEV
		EndIf
	EndIf

	If !Empty( cCodCli + cLojCli )
		SA1->(DbSetOrder(1))
		If SA1->( MsSeek( xFilial('SA1') + cCodCli + cLojCli) )
			M->DTC_CLIDEV  :=  SA1->A1_COD
			M->DTC_LOJDEV  :=  SA1->A1_LOJA
			M->DTC_NOMDEV  :=  SA1->A1_NOME
			If !lAutomatic
				If M->DTC_DEVFRE $ "1,2" .Or. lMV_TMSFOB
					M->DTC_TIPFRE := Iif(M->DTC_DEVFRE $ '1|6','1','2')
				Else
					M->DTC_TIPFRE := '1'
				EndIf
			Else
				If 'TMSAI70' $ FunName() //--Internacional
					M->DTC_TIPFRE := M->DIK_TIPFRE
					M->DTC_DEVFRE := M->DIK_DEVFRE
					M->DTC_SERVIC := M->DIK_SERVIC
				EndIf
			EndIf

			If !Empty(M->DTC_SQEDES) .Or. (!Empty(M->DTC_CLIREC) .And. !Empty(M->DTC_LOJREC))
				M->DTC_REGCAL := Posicione('DUY',1,xFilial('DUY') + M->DTC_CDRCAL,'DUY_DESCRI')

			Else
				M->DTC_CDRCAL := TMSDestCal( M->DTC_CLIDEV, M->DTC_LOJDEV, M->DTC_CDRCAL )
				If Empty(M->DTC_CDRCAL)
					M->DTC_CDRCAL := M->DTC_CDRDES
				EndIf
				M->DTC_REGCAL := Posicione('DUY',1,xFilial('DUY') + M->DTC_CDRCAL,'DUY_DESCRI')
			EndIf
			//-- Sugere Incoterm
			TMA050Inc()
		Else
			Help("",1,"TMSA05022") //-- Cliente Devedor nao encontrado ...
			Return( .F. )
		EndIf
	Else
		If !lSinc
			Help("",1,"TMSA05022") //-- Cliente Devedor nao encontrado ...
			Return( .F. )
		EndIf
	EndIf


	DC5->(dbSetOrder(1))
	DC5->(MsSeek(xFilial("DC5")+M->DTC_SERVIC))
	If DC5->DC5_SEGPER == '1' // Servico tem 2o. Percurso
		//--Para segundo percurso, o Cliente de Calculo sera' o Remetente.
		M->DTC_CLICAL := M->DTC_CLIREM
		M->DTC_LOJCAL := M->DTC_LOJREM
		M->DTC_NOMCAL := M->DTC_NOMREM
	Else
		//-- Preenche os campos Cliente de Calculo e Loja do cliente de calculo.

		//-- Analisa a tabela de consignatarios.
		cCodCli  := ''
		cLojCli  := ''
		aCliCalc := {}
		//-- Se for 2o. Percurso, nao verificar a tabela de consignatarios
		If (lAlianca .And. TmsA050Dpc()) .Or. !lAlianca
			aCliCalc := TmsCliCalc( M->DTC_CLIREM, M->DTC_LOJREM, M->DTC_CLIDES, M->DTC_LOJDES )
		EndIf
		If Empty( aCliCalc )
			cCodCli := M->DTC_CLIDEV
			cLojCli := M->DTC_LOJDEV
		Else
			cCodCli := aCliCalc[ 1 ]
			cLojCli := aCliCalc[ 2 ]
		EndIf

		//-- Quando o tipo do frete for FOB ( DTC_TIPFRE == 2 ) e o remetente for FOB dirigido ( DUO_FOBDIR == 1 ), a
		//-- tabela de frete do cliente remetente sera utilizada para o calculo.
		If	M->DTC_TIPFRE == StrZero( 2, Len( DTC->DTC_TIPFRE ) )
			aPerfil := TmsPerfil(M->DTC_CLIREM,M->DTC_LOJREM,.F.,.F.)
			If	! Empty(aPerfil) .And. aPerfil[4] == StrZero( 1, Len( DUO->DUO_FOBDIR ) )
				lOk  := .T.
				If lTMA050FOB
					lOk := ExecBlock('TMA050FOB',.F.,.F.,{M->DTC_CLIDES, M->DTC_LOJDES, M->DTC_CLIREM, M->DTC_LOJREM})
					If ValType(lOk) <> 'L'
						lOk := .T.
					EndIf
				EndIf
				If lOk
					aContrat := {}
					//-- Considera o cliente remetente somente se nao houver contrato para o cliente destinatario
					aContrat:=TMSContrat(M->DTC_CLIDEV,M->DTC_LOJDEV,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE, .F.,,,,,,,,,,,,,,,M->DTC_CODNEG)
					If	Empty(aContrat)
						cCodCli := M->DTC_CLIREM
						cLojCli := M->DTC_LOJREM
					EndIf
				EndIf
			EndIf
		EndIf

		//-- Verifica a Abragencia do Contrato quando nao e cliente generico
		If !Empty(M->DTC_TIPFRE) .And. !Empty(M->DTC_SERVIC)
			aContrat:=TMSContrat(cCodCli,cLojCli,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE, .F.,,,,,,,,,,,,,,,M->DTC_CODNEG)
			If	!Empty( aContrat ) .And. !aContrat[ 1,17 ]
				If Posicione("AAM",1,xFilial("AAM")+aContrat[ 1, 1 ],"AAM_ABRANG") == "2"
					cLojCli:=AAM->AAM_LOJA
				EndIf
			EndIf
		EndIf

		SA1->( DbSetOrder( 1 ) )
		If	Empty( cCodCli + cLojCli ) .Or. SA1->( ! MsSeek( xFilial('SA1') + cCodCli + cLojCli, .F. ) )
			Help('',1,'TMSA05033')	//-- Cliente para calculo nao encontrado.
			Return( .F. )
		Else
			M->DTC_CLICAL := SA1->A1_COD
			M->DTC_LOJCAL := SA1->A1_LOJA
			M->DTC_NOMCAL := SA1->A1_NOME
		EndIf
	EndIf

	//--Internacional nao deve ter esta validacao, nao existe mais aCols nesta chamada para o CRT
	//--Devido ao programa ser executado por rotina automatica
	If Len(aCols) > 0 .And. !('TMSAI70' $ FunName())
		cOptPesCub := A050PesCub(.F.)
		If cOptPesCub == '2'  // Peso Cubado == Nao
			For nX := 1 to Len(aCols)
				GdFieldPut('DTC_PESOM3',0, nX)
			Next
		ElseIf !IsInCallStack('TMSAF76')
			nPerCub := TmsPerCub(GdFieldGet('DTC_CODPRO',n),M->DTC_CLIDEV,M->DTC_LOJDEV)
			If !Empty(nPerCub)
				For nX := 1 to Len(aCols)
					GdFieldPut('DTC_PESOM3',aCols[nX][nPosPeso] + (aCols[nX][nPosPeso] * (nPerCub/100)), nX)
				Next
			EndIf
		EndIf
	EndIf
EndIf
//-- Se for filial alianca (2o Percurso), o Cliente de Calculo sera' o Cliente Remetente
If lAlianca .And. TmsA050Dpc() .And. !Empty(M->DTC_CLIREM) .And. !Empty(M->DTC_LOJREM)  .And. !Empty(M->DTC_TIPFRE) .And. !Empty(M->DTC_SERVIC)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa se existe ajuste para o remetente, se nao existir ajuste utiliza ³
	//³o consignatario como cliente de calculo para pegar a tabela de frete da   ³
	//|Alianca (de segundo percurso)                                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aContrat := TMSContrat(M->DTC_CLIREM, M->DTC_LOJREM,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
	If !Empty(aContrat) .And. !Empty(M->DTC_CDRORI+M->DTC_CDRDES)
		DVC->(DbSetOrder(2))
		If DVC->(MsSeek( xFilial("DVC")+M->DTC_CLIREM+M->DTC_LOJREM+aContrat[1,3]+aContrat[1,4] ) )
			M->DTC_CLICAL := M->DTC_CLIREM
			M->DTC_LOJCAL := M->DTC_LOJREM
			M->DTC_NOMCAL := M->DTC_NOMREM
		EndIf
	EndIf
EndIf

//-- Retorna a distancia por cliente / regiao.
If nKm == 0 .And. !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CLIDEV) .And. !Empty(M->DTC_LOJDEV)
	nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
	M->DTC_KM := nKm
EndIf

//-- Executa a funcao de validacao do campo DTC_TIPTRA
If !Empty(M->DTC_SERTMS) .And. !Empty(M->DTC_TIPTRA) .And. Alltrim(ReadVar()) <> "M->DTC_CTRDPC"
	TMSA050Vld("M->DTC_TIPTRA")
Endif
If !l050Auto .And. Type("o1Get") <> "U"
	o1Get:oBrowse:Refresh(.T.)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Lot³ Autor ³Patricia A. Salomao    ³ Data ³04.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Lote Digitado                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050Lote()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Lote()

Local lLoteAuto  := SuperGetMv("MV_LOTAUT",.F.,.T.)
Local lExecFunc  := .T.
Local aArea      := GetArea()
Local lRet       := .T.
Local lCamposRat := DTP->(ColumnPos("DTP_RATEIO")) > 0
Local lCmpRatNew := DTP->(ColumnPos("DTP_CRDVFA")) > 0

If lLoteAuto .And. Empty(M->DTC_LOTNFC)
	lExecFunc := .F.
	If Empty(M->DTC_CLIREM) == .F.
		TMSA050Vld("DTC_CLIREM")
	EndIf
EndIf

If lExecFunc
	dbSelectArea("DTP")
	dbSetOrder(2)
	If MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC)
		If l050Inclui .And. DTP->DTP_STATUS <> '1'
			Help(" ",1,"TMSA05003") //Informe um Lote que esteja com Status em Aberto.
			lRet := .F.
		EndIf
		If lRet .And. TmsExp() .And. Substr(FunName(),1,7) == "TMSA144"
			If DTP->DTP_VIAGEM <> M->DTQ_VIAGEM
				Help(" ",1,"TMSA14415") //Lote não vinculado a esta viagem.
				lRet := .F.
			EndIf
		EndIf
		If lRet
			If lCamposRat
				lRateio := Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
			EndIf
		EndIf

		If lRateio
			cTABRAT := DTP->DTP_TABRAT
			cTIPRAT := DTP->DTP_TIPRAT
			cTBARAT := DTP->DTP_TBARAT
			cTPARAT := DTP->DTP_TPARAT
			cBACRAT := Iif( DTP->DTP_BACRAT == StrZero(1, Len(DTP->DTP_BACRAT)), "", DTP->DTP_BACRAT) // 1=Nao Utiliza
			cCRIRAT := Iif( DTP->DTP_CRIRAT == StrZero(1, Len(DTP->DTP_CRIRAT)), "", DTP->DTP_CRIRAT) // 1=Nao Utiliza
			cPRORAT := Iif( DTP->DTP_PRORAT == StrZero(1, Len(DTP->DTP_PRORAT)), "", DTP->DTP_PRORAT) // 1=Nao Utiliza
			If lCmpRatNew
				cCRDVFA := Iif( DTP->DTP_CRDVFA == StrZero(0, Len(DTP->DTP_CRDVFA)), "", DTP->DTP_CRDVFA) // 0=Nao Utiliza
				cCRDVDC := Iif( DTP->DTP_CRDVDC == StrZero(0, Len(DTP->DTP_CRDVDC)), "", DTP->DTP_CRDVDC) // 0=Nao Utiliza
			EndIf

			cORIRAT := DTP->DTP_ORIRAT
			cCALRAT := DTP->DTP_CALRAT
			M->DTC_ORIRAT := cORIRAT

			If !Empty(M->DTC_ORIRAT)
				RunTrigger(1,Nil,Nil,,"DTC_ORIRAT")
			EndIf
			M->DTC_CALRAT := cCALRAT

			If !Empty(M->DTC_CALRAT)
				RunTrigger(1,Nil,Nil,,"DTC_CALRAT")
			EndIf
		Else
			If lCamposRat
				M->DTC_ORIRAT := CriaVar("DTC_ORIRAT",.F.)
				M->DTC_RORRAT := CriaVar("DTC_RORRAT",.F.)
				M->DTC_UORRAT := CriaVar("DTC_UORRAT",.F.)
				M->DTC_CALRAT := CriaVar("DTC_CALRAT",.F.)
				M->DTC_RCARAT := CriaVar("DTC_RCARAT",.F.)
				M->DTC_UCARAT := CriaVar("DTC_UCARAT",.F.)
			EndIf
		EndIf
		//-- Gatilha campos de remetente e destinatario e suas sequencias de endereços
		If FunName() == "TMSA050"
			TM050SCFil(M->DTC_FILCFS,DTP->DTP_NUMSOL)
		EndIf
	Else
		Help(" ",1,"REGNOIS") //Nao existe registro relacionado a este codigo.
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050NF ³ Autor ³Patricia A. Salomao    ³ Data ³04.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se a Nota Fiscal/Serie ja existe.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050NF()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050NF()
Local lRet    		:= .T.
Local aAreaDTC		:= DTC->(GetArea())
Local cCampo 		:= ReadVar()
Local cChave 		:= ""
Local cSeek   		:= ""
Local cNfcNew 		:= ""
Local cSerNew		:= ""
Local cChaveOld 	:= ""
Local nPos      	:= 0
Local nTamChave 	:= 0
Local cProdNew      := ""
Local nValInf		:= 0
Local aValInfCop	:= {}
Local nSeek         := 0

//--Se for chamada Internacional, nao podemos validar desta forma
//--Sera validado no proprio fonte de inclusao do CRT
If !('TMSAI70' $ FunName())
	If cCampo $ "M->DTC_CLIREM.M->DTC_LOJREM"
		cChave  := GDFieldGet('DTC_NUMNFC',n)+GDFieldGet('DTC_SERNFC',n)+M->DTC_CLIREM+M->DTC_LOJREM+GdFieldGet('DTC_CODPRO',n)
		cChave2 := GDFieldGet('DTC_NUMNFC',n)+GDFieldGet('DTC_SERNFC',n)+GDFieldGet('DTC_CODPRO',n)

		//--Variaveis para o Ponto de Entrada "TMA050NFC"
		cNumNfc := GDFieldGet('DTC_NUMNFC',n)
		cSerNfc := GDFieldGet('DTC_SERNFC',n)
		cCodPro := GdFieldGet('DTC_CODPRO',n)

	ElseIf cCampo == "M->DTC_NUMNFC"
		If !GdDeleted(n) .And. IIf(ALTERA,GDFieldGet('DTC_NUMNFC', n) <> M->DTC_NUMNFC,.T.)
			cChave  := &(ReadVar())+GDFieldGet('DTC_SERNFC',n)+M->DTC_CLIREM+M->DTC_LOJREM+GdFieldGet('DTC_CODPRO',n)
			cChave2 := &(ReadVar())+GDFieldGet('DTC_SERNFC',n)+GDFieldGet('DTC_CODPRO',n)

			//--Guarda novo valor para verificar
			//--se foi alterada a informacao
			cNfcNew := &(ReadVar())

			//--Variaveis para o Ponto de Entrada "TMA050NFC"
			cNumNfc := &(ReadVar())
			cSerNfc := GDFieldGet('DTC_SERNFC',n)
			cCodPro := GdFieldGet('DTC_CODPRO',n)

		EndIf
	ElseIf cCampo == "M->DTC_SERNFC"
		If !GdDeleted(n) .And. IIf(ALTERA,GDFieldGet('DTC_SERNFC', n) <> M->DTC_SERNFC,.T.)
			cChave  := GDFieldGet('DTC_NUMNFC', n)+&(ReadVar())+M->DTC_CLIREM+M->DTC_LOJREM+GdFieldGet('DTC_CODPRO',n)
			cChave2 := GDFieldGet('DTC_NUMNFC', n)+&(ReadVar())+GDFieldGet('DTC_CODPRO',n)

			//--Guarda novo valor para verificar
			//--se foi alterada a informacao
			cSerNew := &(ReadVar())

			//--Variaveis para o Ponto de Entrada "TMA050NFC"
			cNumNfc := GDFieldGet('DTC_NUMNFC',n)
			cSerNfc := &(ReadVar())
			cCodPro := GdFieldGet('DTC_CODPRO',n)
		EndIf
	ElseIf cCampo == "M->DTC_CODPRO"
		If !GdDeleted(n) .And. IIf(ALTERA,GDFieldGet('DTC_CODPRO', n) <> M->DTC_CODPRO,.T.)
			cChave  := GDFieldGet('DTC_NUMNFC', n)+GDFieldGet('DTC_SERNFC', n)+M->DTC_CLIREM+M->DTC_LOJREM+&(ReadVar())
			cChave2 := GDFieldGet('DTC_NUMNFC', n)+GDFieldGet('DTC_SERNFC', n)+&(ReadVar())

			//--Guarda novo valor para verificar
			//--se foi alterada a informacao
			cProdNew := &(ReadVar())

			//--Variaveis para o Ponto de Entrada "TMA050NFC"
			cNumNfc  := GDFieldGet('DTC_NUMNFC',n)
			cSerNfc  := GDFieldGet('DTC_SERNFC',n)
			cCodPro  := &(ReadVar())
		EndIf
	EndIf

	If !Empty(cChave)

		nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DTC_NUMNFC')] == cNumNFC ;
		.And. x[GdFieldPos('DTC_SERNFC')] == cSerNFC .And. x[GdFieldPos('DTC_CODPRO')] == cCodPro })
		If	nSeek > 0 .And. nSeek != n
			Help(" ",1,"TMSA05006") //-- Ja foi informado este Numero de Nota Fiscal / Serie / Produto ...
			Return( .F. )
		EndIf

		If GetNewPar('MV_TM050NF',.T.) // Verifica se executa a verificação da nota fiscal
			DTC->(dbSetOrder(2))
			If DTC->( MsSeek( cSeek := xFilial('DTC')+ cChave))
				Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO) == cSeek
					If  DTC->DTC_FILORI == cFilAnt
						Help("",1,"TMSA05008" ) //Nota Fiscal ja Cadastrada
						RestArea(aAreaDTC)
						Return( .F. )
					EndIf
					DTC->(dbSkip())
				EndDo
			EndIf
		EndIf
		RestArea(aAreaDTC)

		//
		//--Ponto de Entrada para validar as informacoes:
		//
		If lRet .And. lTMA050NFC
			lRet := ExecBlock('TMA050NFC',.F.,.F.,{ M->DTC_FILORI, cNumNFC, cSerNFC, M->DTC_CLIREM, M->DTC_LOJREM, cCodPro })
			RestArea(aAreaDTC)
			If ValType(lRet) == 'L' .And. !lRet
				Return( .F. )
			EndIf
		EndIf

		If lRet .And. ( !Empty( cNfcNew ) .Or. !Empty( cSerNew ) .Or. !Empty( cProdNew) )
			cChaveOld  := GDFieldGet('DTC_NUMNFC', n)+GDFieldGet('DTC_SERNFC', n)+M->DTC_CLIREM+M->DTC_LOJREM
			cChaveOld2 := GDFieldGet('DTC_NUMNFC', n)+GDFieldGet('DTC_SERNFC', n)+GDFieldGet('DTC_CODPRO', n)

			//-- Ajusta o aCols dos tipos de veiculos
			//-- considerando a nova nota informada.
			If Type( "aColsDVU" ) == "A"
				nPos := ASCan( aColsDVU, {|x| x[1] == cChaveOld} )
				If nPos > 0
					nTamChave := DTC->(Len(DTC_NUMNFC) + Len(DTC_SERNFC) + Len(DTC_CLIREM) + Len(DTC_LOJREM))
					aColsDVU[nPos,1] := Left( cChave, nTamChave )
				EndIf
			EndIf

			//-- Ajusta o aCols referente as informacoes
			//-- do peso cubado
			If Type("aRatPesM3") == "A"
				nPos := ASCan( aRatPesM3, {|x| x[1] == cChaveOld2} )
				If nPos > 0
					aRatPesM3[nPos,1] := cChave2
				EndIf
			EndIf


			//-- Ajusta o aCols referente ao valor informado
			If !Empty(aValInf)
				For nValInf := 1 To Len(aValInf)
					nPos := ASCan( aValInfCop , {|x| x[1] == aValInf[nValInf][4]+aValInf[nValInf][5]+aValInf[nValInf][6] })
					If Empty(aValInfCop) .Or. nPos == 0
						AAdd( aValInfCop, { aValInf[nValInf][4]+aValInf[nValInf][5]+aValInf[nValInf][6] , aClone(aValInf[nValInf]) })
						AAdd( aValInfCop[Len(aValInfCop)][2] , nValInf )
					Else
						AAdd( aValInfCop[nPos], aClone(aValInf[nValInf]) )
						AAdd( aValInfCop[nPos,Len(aValInfCop[nPos])], nValInf )
					EndIf
				Next nValInf
			EndIf

			If Type("aValInf") == "A"
				nPos := ASCan( aValInfCop, {|x| x[1] == cChaveOld2} )
				If nPos > 0
					For nValInf := 1 To Len(aValInfCop[nPos])-1
						aValInf[aValInfCop[nPos,nValInf+1,9]][4] := SubStr(cChave2,1,Len(DTC_NUMNFC))
						aValInf[aValInfCop[nPos,nValInf+1,9]][5] := SubStr(cChave2,Len(DTC_NUMNFC)+1,Len(DTC_SERNFC))
						aValInf[aValInfCop[nPos,nValInf+1,9]][6] := SubStr(cChave2,Len(DTC_NUMNFC)+Len(DTC_SERNFC)+1,Len(DTC_CODPRO))
					Next nValInf
				EndIf
			EndIf

			//Ajusta o aCols referente ao Enderecamento
			If ValType("aEndProd") != "U"
				nPos := ASCan( aEndProd, {|x| x[1] == cChaveOld2} )
				If nPos > 0
					aEndProd[nPos,1] := cChave2
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050End³ Autor ³Patricia A. Salomao    ³ Data ³22.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Endereco Fisico informado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050End()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050End()

Local lRet   := .T.
Local cCampo := ReadVar()

If cCampo == 'M->DUH_LOCAL' .And. !Empty(GDFieldGet( 'DUH_LOCALI', n ))
	lRet := A050VldSBE( &(ReadVar()), GDFieldGet( 'DUH_LOCALI', n ) )
ElseIf cCampo == 'M->DUH_LOCALI'
	If Empty(GDFieldGet( 'DUH_LOCAL', n ))
		Help("",1,"TMSA05015") //Informe o Codigo Armazem
		lRet := .F.
	ElseIf !Empty(M->DUH_LOCALI)
		lRet := A050VldSBE( GDFieldGet( 'DUH_LOCAL', n ), &(ReadVar()) )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Uni³ Autor ³Leandro Paulino        ³ Data ³07.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Unitizador Analitico Informado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050Uni()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Uni()

Local lRet   := .T.
Local cCampo := ReadVar()
Local cUnitiz:= ""
Local cCodAna:= ""

If cCampo == 'M->DUH_UNITIZ' .And. !Empty(GDFieldGet( 'DUH_CODANA', n ))
	If ExistCpo('DCO',&(ReadVar())+GDFieldGet( 'DUH_CODANA', n ))
		cUnitiz := &(ReadVar())
		cCodAna :=  GDFieldGet( 'DUH_CODANA', n )
	Else
	   lRet := .F.
	EndIf
ElseIf cCampo == 'M->DUH_CODANA'
	If ExistCpo('DCO',GDFieldGet( 'DUH_UNITIZ', n )+&(ReadVar()))
		cUnitiz :=  GDFieldGet( 'DUH_UNITIZ', n )
		cCodAna := &(ReadVar())
	Else
		lRet := .F.
	EndIf
ElseIf cCampo == 'M->DTA_UNITIZ' .And. !Empty(GDFieldGet( 'DTA_CODANA', n ))
	cUnitiz := &(ReadVar())
	cCodAna :=  GDFieldGet( 'DTA_CODANA', n )
ElseIf cCampo == 'M->DTA_CODANA'
	If Empty(GDFieldGet( 'DTA_UNITIZ', n ))
		Help("",1,"TMSA05083") //Informe o Unitizador Sintetico
		lRet := .F.
	Else
		cUnitiz :=  GDFieldGet( 'DTA_UNITIZ', n )
		cCodAna := &(ReadVar())
	EndIf
EndIf
If lRet .And. !Empty(GDFieldGet( 'DUH_UNITIZ', n )) .And. !Empty(GDFieldGet( 'DUH_CODANA', n ))
	If Posicione('DCO',1,xFilial("DCO")+cUnitiz+cCodAna,"DCO_STATUS") == '3'
		Help("",1,"TMSA05084")//Unitizador nao esta disponivel.
		lRet := .F.
	EndIf
EndIf

Return( lRet )




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Ser³ Autor ³Patricia A. Salomao    ³ Data ³04.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Servico Informado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050Ser()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Ser()

Local aArea := GetArea()
Local lRet  := .T.
Local lSinc := TmsSinc() //-- Chamada do Sincroizador

l050Auto := If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

DC5->(dbSetOrder(1))
If DC5->(MsSeek(xFilial('DC5')+AllTrim(&(ReadVar()) )))
	If DC5->DC5_SERTMS == '1' .And. !IsInCallStack("TMSAF76") .AND. !IsInCallStack("TMSF79TELA") .And. !Vazio()
		Help("",1, "TMSA05002") //Nesta Opcao não sera possivel utilizar um servico do tipo "Coleta".
		lRet := .F.
	ElseIf !l050Auto
		dbSelectArea("SX5")
		GDFieldPut( 'DTC_DESSER', Tabela("L4",DC5->DC5_SERVIC,.F.),  n )
	EndIf
	If	DC5->DC5_DOCTMS==StrZero(6,Len(DC5->DC5_DOCTMS))
		M->DTC_TIPNFC := StrZero(1,Len(DTC->DTC_TIPNFC))
	EndIf
	A050AvalSer()// Valida se o Servico e' de 2o. Percurso
Else
	Help("",1,"REGNOIS") //Nao existe registro relacionado a este codigo
	lRet := .F.
EndIf
RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050DTP³ Autor ³Patricia A. Salomao    ³ Data ³02.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Descricao do campo DTP_STATUS                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050DTP()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050DTP()

Return IIF(DTP->(!Eof()),RetSx3Box( GetSX3Cache("DTP_STATUS","X3_CBOX"),,, 1 )[Val(DTP->DTP_STATUS)][3], .T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050DT5³ Autor ³Patricia A. Salomao    ³ Data ³30.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a Descricao do campo DT5_STATUS (Status Sol.Coleta) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050DT5()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Descricao do Status da Solicitacao de Coleta                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050DT5()

Local cDescri := ""
Local aSx3Box := {}
Local nSeek   := 0

aSx3Box	:= RetSx3Box( GetSX3Cache("DT5_STATUS","X3_CBOX"),,, 1 )
If	( nSeek := Ascan( aSx3Box, { |x| x[ 2 ] == DT5->DT5_STATUS } ) ) > 0
	cDescri :=  aSx3Box[ nSeek, 3 ]
EndIf

Return( cDescri )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050AvalSe³ Autor ³Patricia A. Salomao    ³ Data ³16.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Avalia se o Servico tem 2o.Percurso                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050AvalSer()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050AvalSer()

Local nKm        := M->DTC_KM

If Empty(M->DTC_SERVIC) .Or. !Empty(M->DTC_NUMCOT)
	Return( .T. )
EndIf

DC5->(dbSetOrder(1))
DC5->(MsSeek(xFilial("DC5")+M->DTC_SERVIC))
If DC5->DC5_SEGPER == '1' // Servico tem 2o. Percurso
	If Empty(M->DTC_NUMCOT)
		M->DTC_CLICON := CriaVar("DTC_CLICON")
		M->DTC_LOJCON := CriaVar("DTC_LOJCON")
		M->DTC_NOMCON := CriaVar("DTC_NOMCON")
		M->DTC_CLIDEV := M->DTC_CLIDES  // O Devedor passa a ser o Destinatario
		M->DTC_LOJDEV := M->DTC_LOJDES
		M->DTC_NOMDEV := Posicione("SA1",1,xFilial("SA1")+ M->DTC_CLIDES + M->DTC_LOJDES,"A1_NOME")
		M->DTC_DEVFRE := "2" // Destinatario
		M->DTC_TIPFRE := "2" // FOB
		M->DTC_CLICAL := M->DTC_CLIREM
		M->DTC_LOJCAL := M->DTC_LOJREM
		M->DTC_NOMCAL := M->DTC_NOMREM
		//-- Retorna a distancia por cliente / regiao.
		If nKm == 0 .And. !Empty(M->DTC_TIPTRA) .And. !Empty(M->DTC_CLIDEV) .And. !Empty(M->DTC_LOJDEV)
			nKm := TMSDistRot(,.F.,M->DTC_CDRORI,M->DTC_CDRCAL,M->DTC_TIPTRA,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_DISTIV == '1')
			M->DTC_KM := nKm
		EndIf
		//-- Sugere Incoterm
		TMA050Inc()
		lAutomatic := .T.
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Cle³ Autor ³Patricia A. Salomao    ³ Data ³13.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Limpa as Variaveis de memoria preenchidas pela Cotacao Frete³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050Clear()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA050Clear()

M->DTC_NUMCOT := Space(Len(M->DTC_NUMCOT))
M->DTC_NUMSOL := Space(Len(M->DTC_NUMSOL))
M->DTC_SERVIC := Space(Len(M->DTC_SERVIC))
If !lTmsCFec
	M->DTC_SERTMS := StrZero(2,Len(DTC->DTC_SERTMS)) // Transporte
Else
	M->DTC_SERTMS := Space(Len(M->DTC_SERTMS))
EndIf
M->DTC_TIPTRA := Space(Len(M->DTC_TIPTRA))
M->DTC_DESTPT := Space(Len(M->DTC_DESTPT))
M->DTC_DESSER := Space(Len(M->DTC_DESSER))
M->DTC_CDRDES := Space(Len(M->DTC_CDRDES))
M->DTC_REGDES := Space(Len(M->DTC_REGDES))
M->DTC_CDRCAL := Space(Len(M->DTC_CDRCAL))
M->DTC_REGCAL := Space(Len(M->DTC_REGCAL))
M->DTC_CLIDEV := Space(Len(M->DTC_CLIDEV))
M->DTC_LOJDEV := Space(Len(M->DTC_LOJDEV))
M->DTC_NOMDEV := Space(Len(M->DTC_NOMDEV))
M->DTC_CLICON := Space(Len(M->DTC_CLICON))
M->DTC_LOJCON := Space(Len(M->DTC_LOJCON))
M->DTC_NOMCON := Space(Len(M->DTC_NOMCON))
M->DTC_CLICAL := Space(Len(M->DTC_CLICAL))
M->DTC_LOJCAL := Space(Len(M->DTC_LOJCAL))
M->DTC_NOMCAL := Space(Len(M->DTC_NOMCAL))
M->DTC_DEVFRE := Space(Len(M->DTC_DEVFRE))
M->DTC_TIPFRE := Space(Len(M->DTC_TIPFRE))
M->DTC_KM := CriaVar("DTC_KM",.F.)
M->DTC_TIPNFC := Space(Len(M->DTC_TIPNFC))
lAutomatic := .F.

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Pag³ Autor ³ Patricia A. Salomao   ³ Data ³24.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica quem sera' o Devedor do Frete na Tabela DTJ (Paga- ³±±
±±³          ³dores do Frete).                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050PagFre(ExpL1,ExpL2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1-Valida se mostra na Tela a Obs. dos Pagadores do Frete³±±
±±³          ³ExpL2-Verif. se a Tela esta sendo chamada pela TudoOK()     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  TMSA050PagFre(lMostra, lTudoOk)

Local aPerfil  := {}
Local cCondFre := ""
Local cString  := ""
Local nOpca    := 0
Local lRet     := .T.
Local cCliGen  := GetMV("MV_CLIGEN")
Local oGet, oDlg
Local lSinc    := TmsSinc() //-- Chamada do Sincroizador

Default lMostra := .T.
Default lTudoOk := .F.

l050Auto := If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se Tiver Cotacao de Frete ou Consignatario Nao devera checar a Regra dos   ³
//³Pagadores de Frete.                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!Empty(M->DTC_NUMCOT))
	Return( .T. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente verificar pagadores do frete quando o remetente e o destinatario  ³
//³ estiverem preenchidos.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->DTC_CLIREM) .And. !Empty(M->DTC_LOJREM) .And. !Empty(M->DTC_CLIDES) .And. !Empty(M->DTC_LOJDES)
	//-- Obtem perfil do cliente remetente ou cliente generico
	aPerfil := TmsPerfil(M->DTC_CLIREM,M->DTC_LOJREM,,.F.)
	If	! Empty(aPerfil)
		cCondFre += aPerfil[3]
	Else
		cCondFre += Space(Len(DUO->DUO_CNDFRE))
	EndIf
	//-- Obtem perfil do cliente destinatario ou cliente generico
	aPerfil := TmsPerfil(M->DTC_CLIDES,M->DTC_LOJDES,,.F.)
	If	! Empty(aPerfil)
		cCondFre += aPerfil[3]
	Else
		cCondFre += Space(Len(DUO->DUO_CNDFRE))
	EndIf

	If !Empty(M->DTC_CLICON) .And. !Empty(M->DTC_LOJCON)
		//-- Obtem perfil do cliente consignatario ou cliente generico
		aPerfil := TmsPerfil(M->DTC_CLICON,M->DTC_LOJCON,,.F.)
		If	! Empty(aPerfil)
			cCondFre += aPerfil[3]
		Else
			cCondFre += Space(Len(DUO->DUO_CNDFRE))
		EndIf
	Else
		cCondFre += Space(Len(DUO->DUO_CNDFRE))
	EndIf

	If !Empty(M->DTC_CLIDPC) .And. !Empty(M->DTC_LOJDPC)
		//-- Obtem perfil do cliente despachante ou cliente generico
		aPerfil := TmsPerfil(M->DTC_CLIDPC,M->DTC_LOJDPC,,.F.)
		If	! Empty(aPerfil)
			cCondFre += aPerfil[3]
		Else
			cCondFre += Space(Len(DUO->DUO_CNDFRE))
		EndIf
	Else
		cCondFre += Space(Len(DUO->DUO_CNDFRE))
	EndIf

	DTJ->(dbSetORder(1))
	If DTJ->(MsSeek(xFilial("DTJ")+cCondFre))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica na tabela DTJ (Pagadores do Frete), se o devedor do frete devera'³
		//³ ou nao ser digitado:                                                      ³
		//³ 1- Sim                                                                    ³
		//³ 2- Nao                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DTJ->DTJ_PAGFRE <> "5"  .And. DTJ->DTJ_PAGFRE <> "6" //(Bloqueada Digitacao)
			M->DTC_DEVFRE := DTJ->DTJ_PAGFRE
			M->DTC_TIPFRE := Iif(DTJ->DTJ_PAGFRE=='1','1','2')
			//-- Sugere Incoterm
			TMA050Inc()
			lAutomatic := .T.
		ElseIf DTJ->DTJ_PAGFRE == "5" //(Digitado)
			lAutomatic := .F.
		ElseIf DTJ->DTJ_PAGFRE == "6" //(Bloqueada Digitacao)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ A Mensagem nao devera ser mostrada qdo. o Servico for informado           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lAutomatic := .F.
			lRet       := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ A mensagem de pagadores do frete so' devera' ser mostrada na TudoOk(), se ³
		//³ o campo DTJ_PAGFRE == 6 (Bloqueada Digitacao)                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTudoOk .And. DTJ->DTJ_PAGFRE <> "6" //(Bloqueada Digitacao)
			lMostra := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o campo DTJ_CODOBS esteja preenchido, deve-se exibir uma mensagem com³
		//³ o conteudo da observacao.                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !l050Auto .And. Inclui .And. lMostra .And. !Empty(DTJ->DTJ_CODOBS) .And. SYP->(MsSeek(xfilial('SYP')+DTJ->DTJ_CODOBS))
			cString := MsMM(DTJ->DTJ_CODOBS,80)
			DEFINE MSDIALOG oDlg TITLE STR0017 FROM 15,20 to 25,62  //"Observacao"
			DEFINE SBUTTON FROM 52, 101.8 TYPE 1  ENABLE OF oDlg ACTION (nOpca := 1,oDlg:End())
			DEFINE SBUTTON FROM 52, 128.9 TYPE 2  ENABLE OF oDlg ACTION (nOpca := 2,oDlg:End())
			@ 0.5,0.7  GET oGet VAR cString OF oDlg MEMO size 150,40 READONLY
			oGet:bRClicked := {||AllwaysTrue()}
			ACTIVATE MSDIALOG oDlg
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A05OPesCub³ Autor ³ Patricia A. Salomao   ³ Data ³02.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica no perfil do Cliente de Calculo se o Peso Cubado   ³±±
±±³          ³devera nao ser informado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050PesCub(EXPL1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - Valida se Exibe ou nao Help                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Conteudo do Campo DUO_CUBAGE                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050PesCub(lHelp,cCampo)

Local aPerfil	  := {}
Local cOptPesCub := ''
Default lHelp    := .T.
Default cCampo   := ReadVar()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O Campo DUO_CUBAGE, controla se devera ou nao informar o Peso Cubado na NF³
//³ 1- Sim                                                                    ³
//³ 2- Nao                                                                    ³
//³ 3- Obrigatorio                                                            ³
//³ 4- M3 (Metro Cubico)                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->DTC_SERVIC) .And. Posicione('DC5',1,xFilial('DC5')+M->DTC_SERVIC,'DC5_DOCTMS') == 'J' //-- CRT
	//-- Se for documento do transporte internacional habilita sempre
	If cCampo == "M->DTC_PESOM3"
		cOptPesCub := '1' //-- Sim
	ElseIf cCampo == "M->DTC_METRO3"
		cOptPesCub := '4' //-- Metro Cubico
	EndIf
Else
	aPerfil := TmsPerfil(M->DTC_CLIDEV,M->DTC_LOJDEV,,.F.,M->DTC_CLIREM,M->DTC_LOJREM,M->DTC_CLIDES,M->DTC_LOJDES)
	If	Empty(aPerfil)
		aPerfil := TmsPerfil(M->DTC_CLICAL,M->DTC_LOJCAL,,.F.,M->DTC_CLIREM,M->DTC_LOJREM,M->DTC_CLIDES,M->DTC_LOJDES)
		If	!Empty(aPerfil)
			cOptPesCub := aPerfil[5]
		EndIf
	Else
		cOptPesCub := aPerfil[5]
	EndIf

	If Inclui .And. lHelp .And. Empty(cOptPesCub)
		Help(1,'','TMSA05038') // Perfil do Cliente de Calculo Nao Encontrado ... O Peso Cubado nao podera ser calculado ...
	EndIf
EndIf
Return( cOptPesCub )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Obs³ Autor ³ Robson Alves          ³ Data ³15.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra as observacoes do cliente.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050ObsCli(ExpC1, ExpC2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Cliente.                                 ³±±
±±³          ³ ExpC2 = Loja do Cliente.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050 / TMSAF05                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050ObsCli(cCodCli, cLojCli)

Local cString := ""
Local nOpcA   := 0
Local aArea   := GetArea()
Local oDlgObs, oGetObs
Local lSinc   := TmsSinc() //-- Chamada do Sincroizador
Local cQuery  	:= ""
Local cAliasDV2	:= ""

l050Auto := If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

If !l050Auto
	cAliasDV2 := GetNextAlias()
	cQuery := "SELECT DV2.DV2_FILUSO, DV2.DV2_CODOBS"
	cQuery += " FROM "+RetSqlName("DV2")+ " DV2 "
	cQuery += " WHERE DV2.DV2_FILIAL = '"+xFilial("DV2")+"'"
	cQuery += "   AND DV2.DV2_CODCLI = '"+cCodCli+"'"
	cQuery += "   AND DV2.DV2_LOJCLI = '"+cLojCli+"'"
	cQuery += "   AND DV2.DV2_ABRANG <> '2' "
	cQuery += "   AND DV2.D_E_L_E_T_ = ' '"
	cQuery += " UNION ALL "
	cQuery += "SELECT DV2.DV2_FILUSO, DV2.DV2_CODOBS"
	cQuery += " FROM "+RetSqlName("DV2")+ " DV2 "
	cQuery += " WHERE DV2.DV2_FILIAL = '"+xFilial("DV2")+"'"
	cQuery += "   AND DV2.DV2_CODCLI = '"+cCodCli+"'"
	cQuery += "   AND DV2.DV2_ABRANG = '2' "
	cQuery += "   AND DV2.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDV2)

	While (cAliasDV2)->(!Eof())
		If Empty((cAliasDV2)->DV2_FILUSO) .Or. (cAliasDV2)->DV2_FILUSO == cFilAnt
			cString += MsMM((cAliasDV2)->DV2_CODOBS, 80) + CHR(13)
		EndIf

		(cAliasDV2)->(DbSkip())
	EndDo
	(cAliasDV2)->(dbCloseArea())
	If  !Empty(StrTran(cString,CHR(13),""))
		DEFINE MSDIALOG oDlgObs TITLE STR0026 FROM 15,20 TO 25,62 //"Observacao do Cliente"
		DEFINE SBUTTON FROM 52, 101.8 TYPE 1  ENABLE OF oDlgObs ACTION (nOpca := 1,oDlgObs:End())
		DEFINE SBUTTON FROM 52, 128.9 TYPE 2  ENABLE OF oDlgObs ACTION (nOpca := 2,oDlgObs:End())
		@ 0.5,0.7  GET oGetObs VAR cString OF oDlgObs MEMO size 150,40 READONLY
		oGetObs:bRClicked := {||AllwaysTrue()}
		If ExistBlock("TM050OBS")
			ExecBlock("TM050OBS",.F.,.F.,{@oDlgObs,@oGetObs})
		EndIf
		ACTIVATE MSDIALOG oDlgObs
	EndIf
EndIf
RestArea(aArea)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Ins³ Autor ³ Robson Alves          ³ Data ³19.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe as inscricoes do cliente para selecao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050InscCli(ExpC1, ExpC2, ExpC3)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Cliente.                                 ³±±
±±³          ³ ExpC2 = Loja do Cliente.                                   ³±±
±±³          ³ ExpC3 = Campo posicionado.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050InscCli(cCodCli, cLojCli, cCampo)
Local oDlgInsc, oItem
Local nA
Local nOpcA	:= 0
Local aArea	:= GetArea()
Local aInscr:= {}
/* Le na resource os bitmaps utilizados no Listbox para sele‡ao. */
Local oOk	:= LoadBitmap( GetResources(), "LBOK")
Local oNo	:= LoadBitmap( GetResources(), "LBNO")
Local lSinc	:= TmsSinc() //-- Chamada do Sincroizador
Local lEDI  := IsInCallStack('TMSAE55Vld')
l050Auto 	:= If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)
lNfcEDI     := If (Type("lNfcEDI") == "U",.F.,lNfcEDI)

If  (!l050Auto .And. Inclui .And. !lNfcEDI) .Or. lEDI
	/* Obtem as inscricoes dos clientes. */
	DV3->(dbSetOrder(1))
	DV3->(MsSeek(xFilial("DV3") + cCodCli + cLojCli))
	DV3->(DbEval({|| AAdd(aInscr, {.F., "1", DV3_SEQUEN, DV3_INSCR})},,;
	{|| DV3_FILIAL == xFilial("DV3") .And. DV3_CODCLI == cCodCli .And. DV3_LOJCLI == cLojCli }))

	If Len(aInscr) > 0
		DEFINE MSDIALOG oDlgInsc TITLE STR0027 From 150,200 To 305,600 OF oMainWnd PIXEL //"Escolha a Inscricao"
		@ 05,10 LISTBOX oItem VAR cOpc Fields HEADER "",STR0028, STR0029 SIZE 140,65 ON DBLCLICK (aInscr:=TrocaItCF(oItem:nAt,aInscr),oItem:Refresh()) NOSCROLL OF oDlgInsc PIXEL //""Sequencia" ### "Inscricao"
		oItem:SetArray(aInscr)
		oItem:bLine := { || {If(aInscr[oItem:nAt,1],oOk,oNo), aInscr[oItem:nAt,3], Transform(aInscr[oItem:nAt,4], PesqPict("DV3", "DV3_INSCR"))}}
		DEFINE SBUTTON FROM 03,160 TYPE 1 ACTION (If(ItTudOk(aInscr),(nOpca:=1,oDlgInsc:End()),)) ENABLE OF oDlgInsc
		DEFINE SBUTTON FROM 18,160 TYPE 2 ACTION (oDlgInsc:End()) ENABLE OF oDlgInsc
		ACTIVATE MSDIALOG oDlgInsc
	EndIf
EndIf

If nOpca == 1
	For nA := 1 To Len(aInscr)
		If aInscr[nA, 1]
			/* Se o item estiver marcado, gatilha a sequencia e inscricao do cliente posicionado. */
			If cCampo $ "M->DTC_CLIREM.M->DTC_LOJREM"
				M->DTC_INSREM := aInscr[nA, 4]
				M->DTC_SQIREM := aInscr[nA, 3]
			ElseIf cCampo $ "M->DTC_CLIDES.M->DTC_LOJDES"
				M->DTC_INSDES := aInscr[nA, 4]
				M->DTC_SQIDES := aInscr[nA, 3]
			ElseIf cCampo $ "M->DTC_CLICON.M->DTC_LOJCON"
				M->DTC_INSCON := aInscr[nA, 4]
				M->DTC_SQICON := aInscr[nA, 3]
			ElseIf cCampo $ "M->DTC_CLIDPC.M->DTC_LOJDPC"
				M->DTC_INSDPC := aInscr[nA, 4]
				M->DTC_SQIDPC := aInscr[nA, 3]
			ElseIf cCampo $ "M->DE5_CGCDES"
				M->DE5_INSDES := aInscr[nA, 4]
				M->DE5_SQIDES := aInscr[nA, 3]
			EndIf
		EndIf
	Next nA
EndIf
RestArea(aArea)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050WheDev³ Autor ³Patricia A. Salomao    ³ Data ³05.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes antes de editar o campo DTC_DEVFRE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050WheDev()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050WheDev()

lRet := !lAutomatic

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA050VerA³ Autor ³Patricia A. Salomao    ³ Data ³16.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida as estruturas dos arrays de Peso Cubado e Endereca- ³±±
±±³          ³ mento, passados pela Rotina Automatica                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA050VerArr(ExpA1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array de Peso Cubado / Enderecamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA050VerArr(aArray)

Local nCntFor, nY

For nCntFor:=1 To Len(aArray)
	If Len(aArray[nCntFor]) < 2
		Help("",1,"TMSA05050") // Erro na Estrutura de Array de Peso Cubado ou Enderecamento
		Return( .F. )
	EndIf
	If ValType(aArray[nCntFor][1]) <> "C"
		Help("",1,"TMSA05050") // Erro na Estrutura de Array de Peso Cubado ou Enderecamento
		Return( .F. )
	EndIf
	If ValType(aArray[nCntFor][2]) <> "A"	.Or. Empty(aArray[nCntFor][2])
		Help("",1,"TMSA05050") // Erro na Estrutura de Array de Peso Cubado ou Enderecamento
		Return( .F. )
	EndIf
	For nY:=1 To Len(aArray[nCntFor][2])
		If ValType(aArray[nCntFor][2][nY]) <> "A"
			Help("",1,"TMSA05050") // Erro na Estrutura de Array de Peso Cubado ou Enderecamento
			Return( .F. )
		EndIf
	Next nY
Next nCntFor

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050VldSBE³ Autor ³Patricia A. Salomao    ³ Data ³18.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria automaticamente o Endereco informado, se o mesmo nao   ³±±
±±³          ³existir.Nao permite que o mesmo Endereco seja utilizado para³±±
±±³          ³Filiais Destino Diferentes.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050VldSBE(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Local                                              ³±±
±±³          ³ ExpC2 - Endereco                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050VldSBE(cLocal, cLocaliz)

Local lRet       := .T.
Local cFilDes    := ""

Default cLocal   := ""
Default cLocaliz := ""

If l050EnderOk == Nil
	l050EnderOk := If(ValType(l050EnderOk)=="L",l050EnderOk,ExistBlock("TMA050END"))
EndIf

SBE->(dbSetOrder(1))
If !SBE->(MsSeek(xFilial("SBE")+ cLocal + cLocaliz ) )
	If MsgYesNo( STR0053 ) //"O Local/Endereco informado nao esta cadastrado. Deseja Cadastrar ?"
		RegToMemory('SBE',.T.)
		M->BE_LOCAL   := cLocal
		M->BE_LOCALIZ := cLocaliz
		AxIncluiAuto("SBE",'A015TOK(3)',,3,SBE->(Recno()), )
		RecLock("SBE", .F.)
		SBE->BE_DATGER := dDataBase
		SBE->BE_HORGER := Left(StrTran(Time(),":",""),4)
		SBE->(MsUnLock())
	Else
		Return( .F. )
	EndIf
Else
	//-- Validar se o Endereco informado esta sendo utilizado para outra Filial
	cFilDes := Posicione("DUY",1,xFilial("DUY")+M->DTC_CDRCAL,"DUY_FILDES")
	DUH->(dbSetOrder(2))
	If DUH->(MsSeek(xFilial("DUH")+cFilAnt+StrZero(1,Len(DUH->DUH_STATUS))+cLocal+cLocaliz)) .And. ;
		DUH->DUH_FILDES <> cFilDes
		Help("",1,"TMSA05049",,DUH->DUH_FILDES,3,01) //Este Endereco ja esta sendo utilizado para a Filial Destino :"
		Return( .F. )
	EndIf

	If l050EnderOk
		lRet := ExecBlock("TMA050END",.F.,.F., {cLocal, cLocaliz} )
		If ValType(lRet) # "L"
			lRet:=.F.
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050EDI³ Autor ³Kleber Dias Gomes      ³ Data ³13.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta todas notas importadas do EDI.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050EDI()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050EDI(cCampo)

Local oDlgEDI
Local oItemEDI
Local oDest1
Local oDest2
Local lDest1     := .F.
Local lDest2     := .F.
Local cCadastro  := ""
Local cOpc       := ""
Local aItEDI     := {}
Local aNfEDI     := {}
Local aTitEDI    := {}
Local aButtons   := {}
Local aDestinNF  := {}
Local cCGCRem    := ""
Local lRemetente := .F.
Local aAreaSA1   := SA1->(GetArea())
Local lSinc      := TmsSinc() //-- Chamada do Sincroizador
Local lPrdDiv    := GetMV("MV_PRDDIV",,.F.) // Verifica se permitira a inclusao de um ou mais produtos
Local lTmCpoEdi  := ExistBlock('TMCPOEDI')  //-- Permite ao usuario, incluir campos nO lISTbOX.
Local lTms050Fil := ExistBlock('TMS050FIL') //-- Permite ao usuario, filtrar as notas importadas do EDI.
Local nCntFor    := 0
Local cTitulo    := ""
//-- Controle de dimensoes de objetos
Local aSize      := MsAdvSize( )
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local nPosFILDPC := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_FILDPC' })
Local nPosCTRDPC := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTC_CTRDPC' })
Local lDE5PESLIQ := DE5->(ColumnPos("DE5_PESLIQ")) > 0

Default cCampo   := ''

If Empty(cCampo)
	cCampo := ReadVar()
EndIf

//-- Calcula as dimensoes dos objetos
AAdd( aObjects, { 100, 100,.T.,.T. } )
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj:= MsObjSize( aInfo, aObjects,.T. )

l050Auto := If (!lSinc .And. Type("l050Auto") == "U",.F.,lSinc .Or. l050Auto)

If !l050Auto
	If cCampo $ "M->DTC_CLIREM,M->DTC_LOJREM"

		lRemetente := .T.

		If !Empty(M->DTC_CLIREM) .And. !Empty(M->DTC_LOJREM)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona no Cliente Remetente.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")
			dbSetOrder(1)
			MSSeek(xFilial("SA1")+M->DTC_CLIREM+M->DTC_LOJREM)
			cCGCRem := SA1->A1_CGC

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena todas notas fiscais importadas.         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("DE5")
			dbSetOrder(2)
			If MSSeek(xFilial("DE5")+"1"+SA1->A1_CGC)
				While !Eof() .And. DE5->DE5_FILIAL+DE5->DE5_STATUS+DE5->DE5_CGCREM == xFilial("DE5")+"1"+SA1->A1_CGC

					If Empty(DE5->DE5_FILDPC) .And. Empty(DE5->DE5_CTRDPC)
						If lDE5PESLIQ
							AAdd(aItEDI,{.F.,DE5->DE5_CGCDES,DE5->DE5_DOC,DE5->DE5_SERIE,DE5->DE5_EMINFC,DE5->DE5_CODPRO,DE5->DE5_QTDVOL,DE5->DE5_PESO,DE5->DE5_PESOM3,DE5->DE5_PESLIQ,DE5->DE5_VALOR,DE5->DE5_METRO3})
						Else
							AAdd(aItEDI,{.F.,DE5->DE5_CGCDES,DE5->DE5_DOC,DE5->DE5_SERIE,DE5->DE5_EMINFC,DE5->DE5_CODPRO,DE5->DE5_QTDVOL,DE5->DE5_PESO,DE5->DE5_PESOM3,DE5->DE5_VALOR,DE5->DE5_METRO3})
						EndIf

						AAdd(aItEDI[ Len(aItEDI)], DE5->DE5_SQIDES)

							AAdd(aItEDI[ Len(aItEDI)], DE5->DE5_SEQEND)
						//-- Inclui colunas do usuario
						If lTmCpoEdi
							aCpos := Execblock("TMCPOEDI",.F.,.F.)
							If Valtype(aCpos) = 'A'
								For nCntFor := 1 To Len(aCpos[2])
									AAdd( aItEDI[Len(aItEDI)], aCpos[2,nCntFor] )
								Next nCntFor
							EndIf
						EndIf
					EndIf

					dbSkip()
				EndDo
			EndIf
		EndIf

	ElseIf cCampo $ "M->DTC_FILDPC,M->DTC_CTRDPC"

		If Len(aCols) > 0 .And. n > 0

			If !Empty(aCols[n, nPosFILDPC]) .And. !Empty(aCols[n, nPosCTRDPC])

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena todas notas fiscais importadas.         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("DE5")
				dbSetOrder(3)
				If MSSeek(xFilial("DE5")+aCols[n, nPosFILDPC]+Left(aCols[n, nPosCTRDPC]+Space(Len(DE5->DE5_CTRDPC)),Len(DE5->DE5_CTRDPC))+"1")

					//-- Atualiza Remetente
					SA1->(DbSetOrder(3))
					If SA1->(MsSeek(xFilial("SA1")+DE5->DE5_CGCREM))
						M->DTC_CLIREM := SA1->A1_COD
						M->DTC_LOJREM := SA1->A1_LOJA
						cCGCRem       := SA1->A1_CGC
					EndIf

					//-- Atualiza Destinatario
					If SA1->(MsSeek(xFilial("SA1")+DE5->DE5_CGCDES))
						M->DTC_CLIDES := SA1->A1_COD
						M->DTC_LOJDES := SA1->A1_LOJA

						DV3->(dbSetOrder(1))
						If DV3->(MsSeek(xFilial("DV3") + SA1->A1_COD + SA1->A1_LOJA))
							M->DTC_INSDES := DV3->DV3_INSCR
							M->DTC_SQIDES := DV3->DV3_SEQUEN
						EndIf
					EndIf

					While !Eof() .And. DE5->DE5_FILIAL + DE5->DE5_FILDPC + DE5->DE5_CTRDPC + DE5->DE5_STATUS == xFilial("DE5") + aCols[n, nPosFILDPC] + Left(aCols[n, nPosCTRDPC]+Space(Len(DE5->DE5_CTRDPC)),Len(DE5->DE5_CTRDPC)) + "1"

						If lDE5PESLIQ
							AAdd(aItEDI,{.F.,DE5->DE5_CGCDES,DE5->DE5_DOC,DE5->DE5_SERIE,DE5->DE5_EMINFC,DE5->DE5_CODPRO,DE5->DE5_QTDVOL,DE5->DE5_PESO,DE5->DE5_PESOM3,DE5->DE5_PESLIQ,DE5->DE5_VALOR,DE5->DE5_METRO3})
						Else
							AAdd(aItEDI,{.F.,DE5->DE5_CGCDES,DE5->DE5_DOC,DE5->DE5_SERIE,DE5->DE5_EMINFC,DE5->DE5_CODPRO,DE5->DE5_QTDVOL,DE5->DE5_PESO,DE5->DE5_PESOM3,DE5->DE5_VALOR,DE5->DE5_METRO3})
						EndIf

						//-- Inclui colunas do usuario
						If lTmCpoEdi
							aCpos := Execblock("TMCPOEDI",.F.,.F.)
							If Valtype(aCpos) = 'A'
								For nCntFor := 1 To Len(aCpos[2])
									AAdd( aItEDI[Len(aItEDI)], aCpos[2,nCntFor] )
								Next nCntFor
							EndIf
						EndIf
						dbSkip()
					EndDo

				EndIf
			Else
				o1Get:nMax := 999
				o1Get:oBrowse:nOpc := nOpcAnt
				o1Get:oBrowse:Refresh(.T.)
			EndIf
		EndIf
	EndIf

	If lTms050Fil
		aNfEDI := Execblock("TMS050FIL",.F.,.F.,{aItEDI})
		If ValType(aNfEDI) == "A"
			aItEDI := aNfEDI
		EndIf
	EndIf

	If !Empty(aItEDI)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Cabecalho                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aTitEDI,' ')

			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_CGCDES","X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_DOC"   ,"X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_SERIE" ,"X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_EMINFC","X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_CODPRO","X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_QTDVOL","X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_PESO"  ,"X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_PESOM3","X3_Titulo")))
			If lDE5PESLIQ
				AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_PESLIQ","X3_Titulo")))
			EndIf
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_VALOR" ,"X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_METRO3","X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_SQIDES","X3_Titulo")))
			AAdd(aTitEDI,TRIM(GetSX3Cache("DE5_SEQEND","X3_Titulo")))

		//-- Inclui colunas do usuario
		If lTmCpoEdi
			If Len(aCpos[1]) > 0
				For nCntFor:=1 To Len(aCpos[1])
					dbSeek(aCpos[1,nCntFor])
					AAdd(aTitEDI,TRIM(X3Titulo()))
				Next
			EndIf
		EndIf

		dbSelectArea("DE5")
		dbSetOrder(2)

		AAdd(aButtons,{"RELATORIO",{||A050VisEDI(cCGCRem,aItEDI[oItemEDI:nAt,3],aItEDI[oItemEDI:nAt,4])}, STR0003 , STR0054 }) //"Visualisar"###"Visual."
		AAdd(aButtons,{"PESQUISA", {||A050PesEDI(oItemEDI,aItEDI)}, STR0002 , STR0055 }) //"Pesquisar"###"Pesq."
		cCadastro	:= STR0030+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME //"Notas Fiscais do EDI de Cliente: "

		DEFINE MSDIALOG oDlgEDI TITLE cCadastro From aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		oItemEDI := TWBrowse():New( aPosObj[1,1], aPosObj[1,2], aPosObj[1,4] - 3, aPosObj[1,3] - 50, Nil, ;
	                                   aTitEDI, Nil, oDlgEDI, Nil, Nil, Nil,,,,,,,,,, "ARRAY", .T. )
		oItemEDI:bLDblClick  := { || { A050EDICl(@oItemEDI,@aItEDI,@aDestinNF,lPrdDiv,lDest2,lDest1) }}
		oItemEDI:SetArray(aItEDI)
		oItemEDI:bLine := &('{ || A050bLin(oItemEDI:nAT,aItEDI) }')


		//-- Seleciona todos destinatarios
		@ aPosObj[1,3] -15, 005 CHECKBOX oDest1 VAR lDest1 PROMPT  "Marca todos itens do documento" SIZE 100,010 OF oDlgEDI PIXEL //
		@ aPosObj[1,3] - 5, 005 CHECKBOX oDest2 VAR lDest2 PROMPT STR0068 SIZE 100,010 OF oDlgEDI PIXEL //"Marca todos destinatarios iguais"

		ACTIVATE MSDIALOG oDlgEDI ON INIT EnchoiceBar(oDlgEDI,{|| (lNfcEDI:= .T., A050AtuEDI(cCGCRem,aItEDI,lRemetente)),oDlgEDI:End()},{||oDlgEDI:End()},,aButtons)
		o1Get:Refresh()
	EndIf

	RestArea( aAreaSA1 )
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050VisEDI³ Autor ³Kleber Dias Gomes      ³ Data ³13.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Visualizacao das notas fiscais - EDI.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050VisEDI()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050VisEDI(cCGCREM,cDOC,cSerie)

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())

dbSelectArea("DE5")
dbSetOrder(2)
dbSeek(xFilial("DE5")+"1"+cCGCREM+cDOC+cSerie)
AxVisual("DE5",Recno(),2)

RestArea(aArea)
RestArea(aAreaSA1)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050PesEDI³ Autor ³Kleber Dias Gomes      ³ Data ³13.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pesquisa notas fiscais - EDI.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050PesEDI()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050PesEDI(oItemEDI,aItEDI)

Local oDlg
Local oCbx
Local oBigGet
Local cOrd	 :=""
Local aOrd	 :={}
Local cCampo :=Space(14)
Local aArea	 :=GetArea()
Local lSeek	 :=.F.
Local nSeek	 := 0
Local nOrdem := 1

AAdd(aOrd,AllTrim(GetSX3Cache("DE5_DOC","X3_Titulo"))+"+"+AllTrim(GetSX3Cache("DE5_SERIE","X3_Titulo")))
AAdd(aOrd,AllTrim(GetSX3Cache("DE5_EMINFC","X3_Titulo")))
AAdd(aOrd,AllTrim(GetSX3Cache("DE5_CGCDES","X3_Titulo")))

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0056 //"Pesquisa"

@05,05 COMBOBOX oCbx VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont ON CHANGE nOrdem := oCbx:nAt
@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek:=.T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	If nOrdem == 1
		aItEDI := aSort( aItEDI,,,{ |x,y| x[3]+x[4] < y[3]+y[4] } )
		If Len(AllTrim(cCampo)) > Len(DE5->DE5_DOC)
			nSeek  := Ascan(aItEDI, {|x| AllTrim(x[3]+x[4]) == AllTrim(cCampo)})
		Else
			nSeek  := Ascan(aItEDI, {|x| AllTrim(x[3]) == AllTrim(cCampo)})
		EndIf
	ElseIf nOrdem == 2
		aItEDI := aSort( aItEDI,,,{ |x,y| x[5] < y[5] } )
		cCampo := CToD(SubStr(cCampo,1,2) + "/" + SubStr(cCampo,3,2) + "/" + SubStr(cCampo,5,2))
		nSeek  := Ascan(aItEDI, {|x| x[5] == cCampo })
	ElseIf nOrdem == 3
		aItEDI := aSort( aItEDI,,,{ |x,y| x[2] < y[2] } )
		nSeek  := Ascan(aItEDI, {|x| AllTrim(x[2]) == AllTrim(cCampo) })
	EndIf
	If nSeek > 0
		oItemEDI:nAt := nSeek
		oItemEDI:Refresh()
	EndIf
EndIf

RestArea(aArea)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050AtuEDI³ Autor ³Kleber Dias Gomes      ³ Data ³13.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Notas Fiscais - EDI Selecionadas para o Cliente.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050AtuEDI()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050AtuEDI(cCGCREM,aItEDI,lRemetente)

Local nI         := 0
Local aArea      := GetArea()
Local aAreaSA1   := SA1->(GetArea())
Local nPos       := 0
Local lAtuCabec  := .T.
Local nCnt       := 0
Local lRet       := .T.
Local nMaxGD     := 0
Local cCGCCon    := ""
Local cCGCDpc    := ""
Local cCGCDev    := ""
Local lAlianca   := TMSAlianca() //-- Utiliza Alianca
Local lTm050EDI  := ExistBlock('TM050EDI')
Local nOld       := n
Local lVldCab    := .T.
Local lVldItem   := .T.
Local aYesFields := {"DTC_NUMNFC","DTC_SERNFC","DTC_QTDVOL","DTC_PESO","DTC_PESOM3","DTC_VALOR","DTC_EMINFC","DTC_ENDTMS","DTC_BASSEG","DTC_METRO3","DTC_EDI","DTC_IDREM","DTC_BASICM"}
Local nRecDE5    := ""
Local cAliasQry  := ""
Local cSeekDEU		:= ""
Local cItemDEU		:= ""
Local nItDVU		:= 0
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local lDE5PESLIQ := DE5->(ColumnPos("DE5_PESLIQ")) > 0
Local aHeaderOld := aClone(aHeader)

If !Empty(cRemetEDI) .And. cRemetEDI <> cCGCREM
	cRemetEDI := cCGCREM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa AHeader e ACols                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TMS050IniVar(	"DTC",;
					xFilial("DTC")+M->DTC_FILORI+M->DTC_LOTNFC+M->DTC_CLIREM+M->DTC_LOJREM+M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SERVIC,;
					"DTC->DTC_FILIAL+DTC->DTC_FILORI+DTC->DTC_LOTNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CLIDES+DTC->DTC_LOJDES+DTC->DTC_CODPRO+DTC->DTC_SERVIC",;
					"DTC->DTC_NUMSOL == M->DTC_NUMSOL",;
					1,;
					aYesFields,;
					/*aNoFields*/,;
					nOpcAnt )
	aHeader := aClone(aHeaderOld)
EndIf

//-- Zera vetor de Tipos de Veiculos para assumir o que foi informado na Nota Fiscal - EDI
aColsDVU := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena o Array para permanecer os selecionados em primeiro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItEDI := aSort( aItEDI,,,{ |x,y| x[1] > y[1] } )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Notas Fiscais - EDI.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt:= 1 To Len(aItEDI)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe item selecionado p/ destinatario e produto.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aItEDI[nCnt,1]
		Exit
	Else

		nMaxGD ++
		lRet:= .F.

		cAliasQry := GetNextAlias()
		cQuery := "SELECT  DE5.R_E_C_N_O_ nRecDE5 "
		cQuery += "  FROM " + RetSQLTab('DE5')
		cQuery += " WHERE DE5.DE5_FILIAL = '" + xFilial('DE5') + "'  AND "
		If lRemetente
			cQuery += "	DE5.DE5_CGCREM = '" + cCGCREM + "' AND "
		Else
			cQuery += "	DE5.DE5_FILDPC = '" + M->DTC_FILDPC + "' AND "
			cQuery += " DE5.DE5_CTRDPC = '" + Left(M->DTC_CTRDPC+Space(Len(DE5->DE5_CTRDPC)),Len(DE5->DE5_CTRDPC)) + "' AND "
		EndIf
		cQuery += " DE5.DE5_STATUS = '1'  AND "
		cQuery += " DE5.DE5_DOC = '" + aItEDI[nCnt,3] + "' AND "
		cQuery += " DE5.DE5_SERIE = '" + aItEDI[nCnt,4] + "' AND "
		cQuery += " DE5.DE5_CODPRO = '" + aItEDI[nCnt,6] + "' AND "
		cQuery += " DE5.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

		If (cAliasQry)->nRecDE5 > 0
			DE5->(DbGoTo( (cAliasQry)->nRecDE5 ))
			lRet:= .T.
		EndIf
		(cAliasQry)->(DbCloseArea())

		If !lRemetente
			lAlianca := .T.
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se Atualiza Cabecalho das Notas Fiscais do Cliente.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAtuCabec

				N := 1
				aCols:= {}
				lVldCab := .T.

				dbSelectArea("SA1")
				dbSetOrder(3)
				If Empty(M->DTC_CLIREM) .And. !Empty(AllTrim(DE5->DE5_CGCREM))
					If MsSeek(xFilial("SA1")+DE5->DE5_CGCREM)
						M->DTC_CLIREM := SA1->A1_COD
						M->DTC_LOJREM := SA1->A1_LOJA
						M->DTC_NOMREM := SA1->A1_NOME
						__readvar := "M->DTC_CLIREM"
					EndIf
				EndIf

				If !Empty(AllTrim(DE5->DE5_CGCDES))
					If dbSeek(xFilial("SA1")+DE5->DE5_CGCDES)
						M->DTC_CLIDES	:= SA1->A1_COD
						M->DTC_LOJDES	:= SA1->A1_LOJA
						M->DTC_CDRDES	:= SA1->A1_CDRDES
						__readvar := "M->DTC_CLIDES"
						If !CheckSX3("DTC_CLIDES",M->DTC_CLIDES) .And. lVldCab
							lVldCab := .F.
						EndIf

						M->DTC_SQIDES := DE5->DE5_SQIDES

						DV3->(dbSetOrder(1))
						If DV3->(MsSeek(xFilial("DV3") + SA1->A1_COD + SA1->A1_LOJA + DE5->DE5_SQIDES ))
							M->DTC_INSDES:= DV3->DV3_INSCR
						EndIf

						cCliDesEDI := M->DTC_CLIDES
						cLojDesEDI := M->DTC_LOJDES
					EndIf
				EndIf
				If lAlianca
					cCGCDpc := AllTrim(Posicione("SM0",1,cEmpAnt+M->DTC_FILDPC,"M0_CGC"))
					cCGCDev := cCGCDpc
				Else
					If !Empty(AllTrim(DE5->DE5_CGCCON))
						cCGCCon := AllTrim(DE5->DE5_CGCCON)
					EndIf
					If !Empty(AllTrim(DE5->DE5_CGCDPC))
						cCGCDpc := AllTrim(DE5->DE5_CGCDPC)
					EndIf
					If !Empty(AllTrim(DE5->DE5_CGCDEV))
						cCGCDev := AllTrim(DE5->DE5_CGCDEV)
					EndIf
				EndIf

				dbSelectArea("SA1")
				dbSetOrder(3)
				If !Empty(cCGCCon)
					If dbSeek(xFilial("SA1")+cCGCCon)
						M->DTC_CLICON	:= SA1->A1_COD
						M->DTC_LOJCON	:= SA1->A1_LOJA
						__readvar := "M->DTC_CLICON"
						If !CheckSX3("DTC_CLICON",M->DTC_CLICON) .And. lVldCab
							lVldCab := .F.
						EndIf
					EndIf
				EndIf

				dbSelectArea("SA1")
				dbSetOrder(3)
				If !Empty(cCGCDpc)
					If dbSeek(xFilial("SA1")+cCGCDpc)
						M->DTC_CLIDPC	:= SA1->A1_COD
						M->DTC_LOJDPC	:= SA1->A1_LOJA
						__readvar := "M->DTC_CLIDPC"
						If !CheckSX3("DTC_CLIDPC",M->DTC_CLIDPC) .And. lVldCab
							lVldCab := .F.
						EndIf
					EndIf
				EndIf

				dbSelectArea("SA1")
				dbSetOrder(3)
				If !Empty(cCGCDev)
					If dbSeek(xFilial("SA1")+cCGCDev)
						M->DTC_CLIDEV	:= SA1->A1_COD
						M->DTC_LOJDEV	:= SA1->A1_LOJA
						__readvar := "M->DTC_CLIDEV"
						If !CheckSX3("DTC_CLIDEV",M->DTC_CLIDEV) .And. lVldCab
							lVldCab := .F.
						EndIf
					EndIf
				EndIf

				//-- Inclusao do campos expedidor quando informados no EDI de NF-e
				If DE5->(ColumnPos("DE5_CGCEXP")) > 0
					If !Empty(DE5->DE5_CGCEXP) .And. MsSeek(xFilial("SA1")+DE5->DE5_CGCEXP)
						M->DTC_CLIEXP := SA1->A1_COD
						M->DTC_LOJEXP := SA1->A1_LOJA
						M->DTC_NOMEXP := SA1->A1_NOME
						__readvar 	  := "M->DTC_CLIEXP"
					EndIf
				EndIf
				//-- Inclusao do campos recebedor
				If DE5->(ColumnPos("DE5_CGCREC")) > 0
					If !Empty(DE5->DE5_CGCREC) .And. MsSeek(xFilial("SA1")+DE5->DE5_CGCREC)
						M->DTC_CLIREC := SA1->A1_COD
						M->DTC_LOJREC := SA1->A1_LOJA
						M->DTC_NOMREC := SA1->A1_NOME
						__readvar := "M->DTC_CLIREC"
					EndIf
				EndIf

				If !Empty(cCGCDev)
					Do Case
						Case cCGCDev == DE5->DE5_CGCREM
							M->DTC_DEVFRE	:=	"1"
						Case cCGCDev == DE5->DE5_CGCDES
							M->DTC_DEVFRE	:=	"2"
						Case cCGCDev == cCGCCon
							M->DTC_DEVFRE	:=	"3"
						Case cCGCDev == cCGCDpc
							M->DTC_DEVFRE	:=	"4"
					EndCase
					If DE5->(ColumnPos("DE5_CGCEXP")) > 0 //--devedor é o expedidor
						If cCGCDev == DE5->DE5_CGCEXP
							M->DTC_DEVFRE := "6"
						EndIf
					Endif
					If DE5->(ColumnPos("DE5_CGCREC")) > 0 //--devedor é o recebedor
						If cCGCDev == DE5->DE5_CGCREC
							M->DTC_DEVFRE := "7"
						EndIf
					EndIf
				Else
					M->DTC_DEVFRE	:=	"1"
				EndIf
				__readvar := "M->DTC_DEVFRE"
				If !CheckSX3("DTC_DEVFRE",M->DTC_DEVFRE) .And. lVldCab
					lVldCab := .F.
				EndIf
				If	(Empty(Left(DE5->DE5_CODNEG,Len(DTC->DTC_CODNEG))))  .Or.;
						Empty(Left(DE5->DE5_SERTMS,Len(DTC->DTC_SERTMS))) .Or.;
						Empty(Left(DE5->DE5_TIPFRE,Len(DTC->DTC_TIPFRE))) .Or.;
						Empty(Left(DE5->DE5_TIPTRA,Len(DTC->DTC_TIPTRA))) .Or.;
						Empty(Left(DE5->DE5_SERVIC,Len(DTC->DTC_SERVIC)))
                    M->DTC_CODNEG := Left(DE5->DE5_CODNEG,Len(DTC->DTC_CODNEG))
					M->DTC_SERTMS := Left(DE5->DE5_SERTMS,Len(DTC->DTC_SERTMS))
					M->DTC_TIPFRE	:= Left(DE5->DE5_TIPFRE,Len(DTC->DTC_TIPFRE))
					M->DTC_TIPTRA	:= Left(DE5->DE5_TIPTRA,Len(DTC->DTC_TIPTRA))
					M->DTC_SERVIC := Left(DE5->DE5_SERVIC,Len(DTC->DTC_SERVIC))
				EndIf


                M->DTC_CODNEG := Left(DE5->DE5_CODNEG,Len(DTC->DTC_CODNEG))
                __readvar := "M->DTC_CODNEG"
                If !CheckSX3("DTC_CODNEG",M->DTC_CODNEG,.T.) .And. lVldCab // CheckSX3: o terceiro parametro como T, permite que seja visualizado o help TMSA050A3.
                    lVldCab := .F.
                    M->DTC_CODNEG := CriaVar("DTC_CODNEG" , .F. )
                    M->DTC_DESNEG := CriaVar("DTC_DESNEG" , .F. )
                EndIf
                RunTrigger(1,Nil,Nil,,"DTC_CODNEG")

				M->DTC_SERTMS := Left(DE5->DE5_SERTMS,Len(DTC->DTC_SERTMS))
				__readvar := "M->DTC_SERTMS"
				If lVldCab .And. !CheckSX3("DTC_SERTMS",M->DTC_SERTMS,.T.)
					lVldCab := .F.
					M->DTC_SERTMS := CriaVar("DTC_SERTMS" , .F. )
				EndIf

				M->DTC_TIPTRA	:= Left(DE5->DE5_TIPTRA,Len(DTC->DTC_TIPTRA))
				__readvar := "M->DTC_TIPTRA"
				If lVldCab .And. !CheckSX3("DTC_TIPTRA",M->DTC_TIPTRA,.T.)
					lVldCab := .F.
					M->DTC_TIPTRA := CriaVar("DTC_TIPTRA" , .F. )
					M->DTC_DESTPT := CriaVar("DTC_DESTPT" , .F. )
				EndIf

			 	If Empty(M->DTC_SERVIC)
					M->DTC_SERVIC := Left(DE5->DE5_SERVIC,Len(DTC->DTC_SERVIC))
				EndIF
				__readvar := "M->DTC_SERVIC"
				If !CheckSX3("DTC_SERVIC",M->DTC_SERVIC,.T.) .And. lVldCab
					lVldCab := .F.
				EndIf

				M->DTC_TIPFRE	:= Left(DE5->DE5_TIPFRE,Len(DTC->DTC_TIPFRE))
				__readvar := "M->DTC_TIPFRE"
				If !CheckSX3("DTC_TIPFRE",M->DTC_TIPFRE) .And. lVldCab
					lVldCab := .F.
				EndIf

				M->DTC_SQEDES	:= Left(DE5->DE5_SEQEND,Len(DTC->DTC_SQEDES))
				__readvar := "M->DTC_SQEDES"
				If !CheckSX3("DTC_SQEDES",M->DTC_SQEDES) .And. lVldCab
					lVldCab := .F.
				EndIf

				//-- Sugere Incoterm
				TMA050Inc()

				If lAlianca
					M->DTC_FILDPC	:= Left(DE5->DE5_FILDPC,Len(DTC->DTC_FILDPC))
					__readvar := "M->DTC_FILDPC"
					M->DTC_CTRDPC	:= Left(DE5->DE5_CTRDPC,Len(DTC->DTC_CTRDPC))
					__readvar := "M->DTC_CTRDPC"

					M->DTC_ALIANC := CriaVar('DTC_ALIANC', .F.)
					If !Empty(M->DTC_FILDPC) .And. !Empty(M->DTC_CTRDPC)
						M->DTC_ALIANC := Posicione("DVL",1,xFilial("DVL")+M->DTC_FILDPC,"DVL_ALIANC")
						__readvar := "M->DTC_ALIANC"
						If !CheckSX3("DTC_ALIANC",M->DTC_ALIANC) .And. lVldCab
							lVldCab := .F.
						EndIf
					EndIf
				EndIf
				lAtuCabec := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza aCols com as notas fiscais do cliente.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd(aCols,Array(Len(aHeader)+1))
			n := Len(aCols)
			lVldItem := .T.
			For nI:= 1 To Len(aHeader)
				If aHeader[nI,10] != "V"
					aCols[Len(aCols),nI]:= CriaVar(aHeader[nI,2])
				Else
					If aHeader[nI,2] == "DTC_ALI_WT"
						aCols[Len(aCols),nI]:= "DTC"
					ElseIf aHeader[nI,2] == "DTC_REC_WT"
						aCols[Len(aCols),nI]:= 0
					Else
						aCols[Len(aCols),nI]:= CriaVar(aHeader[nI,2])
					EndIf
				EndIf
			Next nI
			aCols[Len(aCols),Len(aHeader)+1] := .F.

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NUMNFC"})
			aCols[nCnt,nPos]	:=	Left(DE5->DE5_DOC,Len(DTC->DTC_NUMNFC))
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_SERNFC"})
			aCols[nCnt,nPos]	:=	Left(DE5->DE5_SERIE,Len(DTC->DTC_SERNFC))
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODPRO"})
			aCols[nCnt,nPos]	:=	Left(DE5->DE5_CODPRO,Len(DTC->DTC_CODPRO))
			M->&( aHeader[nPos][2] ) := CriaVar( aHeader[nPos][2] )
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf
			If ExistTrigger("DTC_CODPRO")
				RunTrigger(2,nCnt,,o1Get,"DTC_CODPRO")
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODEMB"})
			aCols[nCnt,nPos]	:=	Left(DE5->DE5_CODEMB,Len(DTC->DTC_CODEMB))
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf
			If ExistTrigger("DTC_CODEMB")
				RunTrigger(2,nCnt,,o1Get,"DTC_CODEMB")
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_EMINFC"})
			aCols[nCnt,nPos]	:=	DE5->DE5_EMINFC
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_QTDVOL"})
			aCols[nCnt,nPos]	:=	DE5->DE5_QTDVOL
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PESO"})
			aCols[nCnt,nPos]	:=	DE5->DE5_PESO
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PESOM3"})
			aCols[nCnt,nPos]	:=	DE5->DE5_PESOM3
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			If lDE5PESLIQ
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PESLIQ"})
				aCols[nCnt,nPos]	:=	DE5->DE5_PESLIQ
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_VALOR"})
			aCols[nCnt,nPos]	:=	DE5->DE5_VALOR
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_EDI"})
			aCols[nCnt,nPos]	:=	"1"
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_METRO3"})
			aCols[nCnt,nPos]	:=	DE5->DE5_METRO3
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			//-- Campo da NF-e
			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NFEID"})
			aCols[nCnt,nPos]	:=	DE5->DE5_NFEID
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_EMINFE"})
			aCols[nCnt,nPos]	:=	DE5->DE5_EMINFE
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODNFE"})
			aCols[nCnt,nPos]	:=	DE5->DE5_CODNFE
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NFELET"})
			aCols[nCnt,nPos]	:=	DE5->DE5_NFELET
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			//-- Campo do Cod.Fiscal
			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CF"})
			aCols[nCnt,nPos]	:= DE5->DE5_CFOPNF
			__readvar:="M->"+aHeader[nPos][2]
			If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
				lVldItem := .F.
			EndIf

			// - Campos Agendamento de Entrega
			If DE5->(ColumnPos("DE5_TIPAGD")) > 0 .And. lAgdEntr
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_TIPAGD"})
				aCols[nCnt,nPos]	:= DE5->DE5_TIPAGD
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			If DE5->(ColumnPos("DE5_DATAGD")) > 0 .And. lAgdEntr
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_DATAGD"})
				aCols[nCnt,nPos]	:= DE5->DE5_DATAGD
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			If DE5->(ColumnPos("DE5_PRDAGD")) > 0 .And. lAgdEntr
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PRDAGD"})
				aCols[nCnt,nPos]	:= DE5->DE5_PRDAGD
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			If DE5->(ColumnPos("DE5_INIAGD")) > 0 .And. lAgdEntr
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_INIAGD"})
				aCols[nCnt,nPos]	:= DE5->DE5_INIAGD
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			If DE5->(ColumnPos("DE5_FIMAGD")) > 0 .And. lAgdEntr
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_FIMAGD"})
				aCols[nCnt,nPos]	:= DE5->DE5_FIMAGD
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			If DE5->(ColumnPos("DE5_MOTAGD")) > 0 .And. lAgdEntr
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_MOTAGD"})
				aCols[nCnt,nPos]	:= DE5->DE5_MOTAGD
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf
			If !lVldCab .Or. !lVldItem
				aCols[nCnt,Len(aHeader)+1] := .T.
			EndIf

			If DE5->(ColumnPos("DE5_BASEIC")) > 0 .And. X3Usado("DTC_BASICM")
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_BASICM"})
				aCols[nCnt,nPos]	:=	DE5->DE5_BASEIC
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			If DE5->(ColumnPos("DE5_VALICM")) > 0 .And. X3Usado("DTC_VALICM")
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_VALICM"})
				aCols[nCnt,nPos]	:=	DE5->DE5_VALICM
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			If DE5->(ColumnPos("DE5_BASIST")) > 0 .And. X3Usado("DTC_BASESU")
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_BASESU"})
				aCols[nCnt,nPos]	:=	DE5->DE5_BASIST
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
					EndIf
			EndIf

			If DE5->(ColumnPos("DE5_VALIST")) > 0 .And. X3Usado("DTC_VALIST")
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_VALIST"})
				aCols[nCnt,nPos]	:=	DE5->DE5_VALIST
				__readvar:="M->"+aHeader[nPos][2]
				If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
					lVldItem := .F.
				EndIf
			EndIf

			//-- Atualiza campos DVU - Tipo Veiculo Nota Fiscal
			cSeekDEU := xFilial("DEU") + DE5->DE5_CGCREM + DE5->DE5_DOC + DE5->DE5_SERIE
			dbSelectArea("DEU")
			dbSetOrder(1)
			If dbSeek(cSeekDEU)
				cItemDEU := DE5->DE5_DOC + DE5->DE5_SERIE + M->DTC_CLIREM + M->DTC_LOJREM
				If !Empty(cItemDEU)
					AAdd(aColsDVU, {cItemDEU, {}})
					nItDVU++
				EndIf
				Do While !DEU->(Eof()) .And. DEU->(DEU_FILIAL+DEU_CGCREM+DEU_DOC+DEU_SERIE) == cSeekDEU
					cDesTipVei := Posicione('DUT', 1, xFilial('DUT')+ DEU->DEU_TIPVEI, 'DUT_DESCRI')
					If Ascan(aColsDVU[nItDVU, 2],{|x| x[1] + x[2] == DEU->DEU_ITEM + DEU->DEU_TIPVEI}) == 0
						AAdd(aColsDVU[nItDVU][2],{DEU->DEU_ITEM, DEU->DEU_TIPVEI, cDesTipVei, DEU->DEU_QTDVEI, "DVU", 0, .F.})
					EndIf
					DEU->(dbSkip())
				EndDo
			EndIf

			//-- Ponto de entrada para atualizacao de campos de usuario
			If	lTm050EDI
				ExecBlock('TM050EDI',.F.,.F.)
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa AHeader e ACols                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TMS050IniVar(	"DTC",;
							xFilial("DTC")+M->DTC_FILORI+M->DTC_LOTNFC+M->DTC_CLIREM+M->DTC_LOJREM+M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SERVIC,;
							"DTC->DTC_FILIAL+DTC->DTC_FILORI+DTC->DTC_LOTNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CLIDES+DTC->DTC_LOJDES+DTC->DTC_SERVIC",;
							"DTC->DTC_NUMSOL == M->DTC_NUMSOL",;
							1,;
							aYesFields,;
							/*aNoFields*/,;
							nOpcAnt )
			aHeader := aClone(aHeaderOld)
			Help('',1,'TMSA050D4',,STR0035 + ": " + aItEDI[nCnt,3] ,3,01) // Documento ja utilizado ou excluido. Documento: numero do doc.
			Exit
		EndIf
	EndIf
Next nCnt
n := nOld
//-- Verifica se a Filial/CTRC Despachante eh Alianca e nao permite alterar as Notas Fiscais
If lAlianca .And. TmsA050Dpc() .And. DVL->(MsSeek(xFilial("DVL")+M->DTC_FILDPC))
	o1Get:nMax := nMaxGD
	o1Get:oBrowse:aAlter := { "DTC_ENDTMS" }
	o1Get:oBrowse:Refresh(.T.)
EndIf

RestArea(aArea)
RestArea(aAreaSA1)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A050EDICl ³ Autor ³ Eduardo de Souza      ³ Data ³ 18/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tratar o click da pergunte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050EDICl(ExpO1,ExpA1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto                                             ³±±
±±³          ³ ExpA1 - Array contendo dados do EDI                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050EDICl(oItemEDI,aItEDI,aDestinNF,lPrdDiv,lMarcDest,lMarcDoc)

Default lMarcDest := .F.
Default lMarcDoc  := .F.

aItEDI[oItemEDI:nAt,1] := !aItEDI[oItemEDI:nAt,1]

If aItEDI[oItemEDI:nAt,1]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena Destinatario e Produto para validar a Selecao.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aDestinNF) == 0
		AAdd(aDestinNF,aItEDI[oItemEDI:nAt,2]) // Destinatario
		AAdd(aDestinNF,aItEDI[oItemEDI:nAt,6]) // Produto
		AAdd(aDestinNF,aItEDI[oItemEDI:nAt,3]) // Documento
		AAdd(aDestinNF,aItEDI[oItemEDI:nAt, Len(aItEDI[oItemEDI:nAt]) ]) // Sequencia Ins.Destino
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se esta selecionando o mesmo destinatario e produto. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPrdDiv
		lRet:= .T.
		If !(aDestinNF[1] == aItEDI[oItemEDI:nAt,2] .And. aDestinNF[2] == aItEDI[oItemEDI:nAt,6] .And. aDestinNF[4] == aItEDI[oItemEDI:nAt, Len(aItEDI[oItemEDI:nAt]) ])
			lRet:= .F.
		EndIf
		If !lRet
			Help(" ",1,"TMSA05052") // Somente sera possivel a selecao de notas fiscais do mesmo destinatario e produto.
			aItEDI[oItemEDI:nAt,1] := .F.
		EndIf
	Else
		lRet:= .T.
		If (aDestinNF[1] <> aItEDI[oItemEDI:nAt,2]) .Or. (aDestinNF[4] <> aItEDI[oItemEDI:nAt, Len(aItEDI[oItemEDI:nAt])] )
			lRet:= .F.
		EndIf
		If !lRet
			Help(" ",1,"TMSA05058") // Somente sera possivel a selecao de notas fiscais do mesmo destinatario.
			aItEDI[oItemEDI:nAt,1] := .F.
		EndIf
	EndIf

	//-- Marca todos destinatarios iguais.
	If lMarcDest .Or. lMarcDoc
		// 2 - CNPJ  *
		// 3 - Docto *
		// 4 - Serie
		// 5 - Dt.Emissao
		// 6 - Produto
		//12 - Sequencia
		If !lPrdDiv
			Aeval( aItEDI, { |x|  IIF( x[2]+x[6]+IIF(lMarcDoc,x[3],"")+x[Len(aItEDI[oItemEDI:nAt])] == aDestinNF[1]+aDestinNF[2]+IIF(lMarcDoc,aDestinNF[3],"")+aDestinNF[4],x[1]:=.T.,.T.) })
		Else
			Aeval( aItEDI, { |x|  IIF( x[2]+IIF(lMarcDoc,x[3],"")+x[Len(aItEDI[oItemEDI:nAt])] == aDestinNF[1]+IIF(lMarcDoc,aDestinNF[3],"")+aDestinNF[4],x[1]:=.T.,.T.) })
		EndIf
	EndIf

Else
	//-- Marca todos destinatarios iguais.
	If lMarcDest .Or. lMarcDoc
		If !lPrdDiv
			Aeval( aItEDI, { |x|  IIF( x[2]+x[6]+IIF(lMarcDoc,x[3],"")+x[Len(aItEDI[oItemEDI:nAt])] == aDestinNF[1]+aDestinNF[2]+IIF(lMarcDoc,aDestinNF[3],"")+aDestinNF[4],x[1]:=.F.,.T.) })
		Else
			Aeval( aItEDI, { |x|  IIF( x[2]+IIF(lMarcDoc,x[3],"")+x[Len(aItEDI[oItemEDI:nAt])] == aDestinNF[1]+IIF(lMarcDoc,aDestinNF[3],"")+aDestinNF[4],x[1]:=.F.,.T.) })
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe item selecionado p/ destinatario e produto.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Ascan(aItEDI, { |x| x[1] == .T. }) == 0
		aDestinNF := {}
	EndIf
EndIf

oItemEDI:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA050Prd³ Autor ³ Patricia A. Salomao   ³ Data ³ 16/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Chamada pela Consulta DVJ (SXB ; Se a Nota Fiscal   ³±±
±±³          ³ tiver Cotacao de Frete informada, sera apresentada uma Tela³±±
±±³          ³ contendo os Produtos da Cotacao; Caso Contrario, sera apre-³±±
±±³          ³ sentado a consulta ao arquivo SB1 (Produtos)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Prd()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Prd()

Local cCodPro  := ''
Local cSeekDVF := ''
Local cSeekSA7 := ''
Local cTitle   := ''
Local cFilDVF  := xFilial('DVF')
Local aProds   := {}
Local oDlg, oBox
Local aCampos  := {"B1_CODIGO", "B1_DESC"}
Local aHeadSB1 := {}
Local lOk      := .F.
Local nLine    := 1

AAdd(aHeadSB1, RetTitle('B1_CODIGO'))
AAdd(aHeadSB1, RetTitle('B1_DESC'))

SA7->(dbSetOrder(1))
If !Empty(M->DTC_NUMCOT)  .Or. SA7->(MsSeek(cSeekSA7 := xFilial('SA7')+M->DTC_CLIREM+M->DTC_LOJREM))
	SB1->(dbSetOrder(1))
	If !Empty(M->DTC_NUMCOT) //-- Apresenta uma Tela contendo os produtos da Cotacao
		cTitle := STR0057 + M->DTC_NUMCOT //"Produtos da Cotacao de Frete No.: "
		If !Empty(M->DTC_FILCFS)
			cSeekDVF := TMSA050CFS("DVF",M->DTC_FILCFS)
			cSeekDVF := cFilDVF+M->DTC_FILCFS+M->DTC_NUMCOT
		Else
			cSeekDVF := cFilDVF+M->DTC_FILORI+M->DTC_NUMCOT
		EndIf
		DVF->(dbSetOrder(1))
		DVF->(MsSeek(cSeekDVF))
		Do While !DVF->(Eof()) .And. DVF->(DVF_FILIAL+DVF_FILORI+DVF_NUMCOT) == cSeekDVF
			AAdd(aProds,  {.F.,"1", DVF->DVF_CODPRO, Posicione('SB1',1,xFilial('SB1')+DVF->DVF_CODPRO,'B1_DESC') })
			DVF->(dbSkip())
		EndDo
	Else  //-- Apresenta uma Tela contendo os ProdutosxCliente
		cTitle := STR0058 + M->DTC_CLIREM + '/'+M->DTC_LOJREM //"Produtos x Cliente Remetente: "
		Do While !SA7->(Eof()) .And. SA7->(A7_FILIAL+A7_CLIENTE+A7_LOJA) == cSeekSA7
			AAdd(aProds,  {.F.,"1", SA7->A7_PRODUTO, Posicione('SB1',1,xFilial('SB1')+SA7->A7_PRODUTO,'B1_DESC') })
			SA7->(dbSkip())
		EndDo
	EndIf

	If Len(aProds) > 0
		DEFINE MSDIALOG oDlg TITLE cTitle FROM 00,00 TO 250,500 PIXEL OF oMainWnd
			@ 01,02 TO 122,211 LABEL "" PIXEL OF oDlg
			If Len(aProds) > 0
				oBox:= TWBrowse():New( 05, 04, 205, 115,, { STR0059 , STR0060 },, oDlg,,,,{|| nLine:= oBox:nAt},{|| lOk := .T., oDlg:End()},,,,,,,.F.,,.T.,,.F.,,,) //"Codigo"###"Descricao"
				oBox:SetArray(aProds)
				oBox:bLine:={|| {	aProds[oBox:nAt,3] ,;
									aProds[oBox:nAt,4] }}

				oBox:bLDblClick := { || lOk:=.T.,oDlg:End() }

			EndIf
			DEFINE SBUTTON FROM 05,215 TYPE 1 ENABLE OF oDlg ACTION (lOk:=.T.,oDlg:End())
			DEFINE SBUTTON FROM 25,215 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
		ACTIVATE MSDIALOG oDlg CENTERED

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Na confirmacao posiciona no produto selecionado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOk
			SB1->(MsSeek(xFilial("SB1") + aProds[nLine, 3]))
			GDFieldPut('DTC_CODPRO',SB1->B1_COD,n)
		EndIf

	EndIf

	Return( lOk )

Else

	If SuperGetMv("MV_TMSERP",,"0") == "1"
		ConPad1(,,,'TMSB1',,,.F.)
	Else
		ConPad1(,,,'SB1',,,.F.)
	EndIf

EndIf

Return( .T. )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM050CPROD
//TODO Rotina utilizada para chamada do cadastro de produtos essa function deve ser informada
       na consulta padrão.
@author  tiago.dsantos
@since   16/01/2017
@version undefined

@type    function / acesso exclusivo para consulta padrão utilizado no campo DTC_CODPRO
/*/
//-------------------------------------------------------------------------------------------------
Function TM050CPad()
Local lRet      := .F.
Local aAreaDTC  := DTC->(GetArea())

Default cAlias  := "DTC"

     VAR_IXB := ""

     If (lRet:= TMSA050GUI())
          VAR_IXB := SB1->B1_COD
     EndIf

     RestArea( aAreaDTC )


Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA050PRD
//TODO Rotina para abrir a tela de cadatro de produtos utilizado na consulta padrão TMSB1
@author  tiago.dsantos
@since   16/01/2017
@version undefined
@param   cAlias, characters, descricao
@type    function
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSA050GUI()
Local aRotOld   := aClone(aRotina)
Local cFiltro   := ""
Local aCampos   := {}
Local aRotina   := {}
Local cAlias  := "SB1"

Private cCadastro := STR0001 //"Endereco de Solicitante e Cliente"
Private nOpcSel := 0

     //+---------------------------------------------------
     //| Montagem do Filtro aqui
     //+---------------------------------------------------
     cFiltro := ""

     //+---------------------------------------------------
     //| Define os campos do Browse.
     //+---------------------------------------------------
     AAdd(aCampos, "B1_COD")
     AAdd(aCampos, "B1_DESC")
     AAdd(aCampos, "B1_TIPO")
     AAdd(aCampos, "B1_LOCPAD")
     AAdd(aCampos, "B1_GRUPO")
     AAdd(aCampos, "B1_TIPO")

     aRotina := { { STR0032 ,"TMSConfSel",0,2,,,.T.},; //"Confirmar"
                  { STR0003 ,"A010Visul" ,0,2},;       //"Visualizar"
                  { STR0004 ,"A010Inclui",0,3},;       //"Incluir"
                  { STR0005 ,"A010Altera",0,4} }       //"Alterar"

     MaWndBrowse(0,0,300,662,cCadastro,"SB1",aCampos,aRotina,,cFiltro,cFiltro,.T.)

     aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA050Est³ Autor ³ Patricia A. Salomao   ³ Data ³ 30/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Ao marcar uma Nota Fiscal para delecao, marca automaticamen³±±
±±³          ³ te todas as outras notas com o mesmo numero/serie          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Est()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Est()

Aeval( aCols, { |x|  IIF( x[GdFieldPos('DTC_NUMNFC')]+x[GdFieldPos('DTC_SERNFC')] == ;
	GdFieldGet('DTC_NUMNFC',n) + GdFieldGet('DTC_SERNFC',n), x[GdFieldPos('DTC_ESTORN')] := M->DTC_ESTORN, .T.) })

o1Get:oBrowse:Refresh(.T.)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA050Srv³ Autor ³ Patricia A. Salomao   ³ Data ³ 01/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Apresenta servicos do contrato, consulta SXB(DLR)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Srv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Srv(nRotina, lExib)
Local lAlianca   := TmsAlianca() //-- Utiliza Alianca
Local lRet       := .T.
Local aContrat   := {}
Local cSrvAli    := AllTrim(GetMv("MV_SRVALI",,""))
Local cTpFreCsg  := ''
Local lCamposRat := DTP->(ColumnPos("DTP_RATEIO")) > 0

If Type("aItContrat") == "U"
	Private aItContrat := {}
EndIf

Default nRotina	 := 0
Default lExib    := .F.

If nRotina = 0
	If	Left(FunName(),7) == 'TMSA050'
		//-- Consulta SXB(DLR) do campo DTC_SERVIC
		If M->DTC_TIPNFC == StrZero(1,Len(DTC->DTC_TIPNFC))
			TMSPesqServ('DTC', M->DTC_CLIDES, M->DTC_LOJDES, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,,;
							StrZero(1,Len(DTC->DTC_TIPFRE)),l050Auto,,.F.,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
							/*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )
		Else
			TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat,,;
							M->DTC_TIPFRE, l050Auto,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
							/*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )
		EndIf
	ElseIf Left(FunName(),7) == 'TMSA011'
		//-- Consulta SXB(DLR) do campo DVC_SERVIC
		If Empty(M->DVC_CODNEG)
			Help(' ',1,'TMSA050A3')	//-- Não é permitido que o código da negociação fique em branco.
		Else
			TMSPesqServ('DVC',M->DVC_CODCLI,M->DVC_LOJCLI,,,@aItContrat,,;
							M->DVC_TIPFRE,,,.F.,M->DVC_TABFRE,M->DVC_TIPTAB,M->DVC_VIGCON,.F.,M->DVC_CDRORI, M->DVC_CDRDES,;
							,,,,,,, M->DTC_CODNEG)
		EndIf
	ElseIf Left(FunName(),7) == 'TMSAI70'
		//-- Consulta SXB(DLR) do campo DVC_SERVIC
		cTipTra := '4' //-- Rodoviario Internacional
		TMSPesqServ('DIK',M->DIK_CLIDEV,M->DIK_LOJDEV,M->DIK_SERTMS,cTipTra,@aItContrat,,;
						M->DIK_TIPFRE,,,,,,,,M->DIK_CDRORI, M->DIK_CDRDES,;
						,,,,,,, M->DTC_CODNEG)

	ElseIf Left(FunName(),7) == 'TMSA019'

		TMSPesqServ('DDD',	M->DDD_CLIDEV,                                      ;
								M->DDD_LOJDEV,                                      ;
								StrZero(1,TamSx3("DTC_SERTMS")[1]),                 ;
								M->DDD_TIPTRA	,                                   ;
								@aItContrat,,                                       ;
								M->DDD_TIPFRE	,,,,,,,,                            ;
								M->DDD_CDRORI,                                      ;
								M->DDD_CDRDES ,,,,,,,,                              ;
								M->DDD_CODNEG	                    )

	//Contrato de Demandas
	ElseIf Left(FunName(),7) == 'TMSA153' .And. DL7->(ColumnPos("DL7_CLIDEV")) > 0
		If 	!Empty(M->DL7_CLIDEV)
			TMSPesqServ('DL7',	M->DL7_CLIDEV,           ;
									M->DL7_LOJDEV,,,     ;
									@aItContrat          ;
									,,,,,,,,,,,,,,,,,,,)
		ElseIf !Empty(M->DL8_CLIDEV)
			TMSPesqServ('DL8',	M->DL8_CLIDEV,           ;
									M->DL8_LOJDEV,,,     ;
									@aItContrat          ;
									,,,,,,,,,,,,,,,,,,,)
		EndIf
     //- Chama pesquisa de serviço de negociação do contrato de cliente
     ElseIf IsInCallStack("TMSF79Tela")
                      TMSPesqServ('DTC',GDFieldGet('DF1_CLIDEV',n) ,;
							            GDFieldGet('DF1_LOJDEV',n) ,;
								        GDFieldGet('DTC_SERTMS',n) ,;
							            GDFieldGet('DTC_TIPTRA',n) ,;
								        @aItContrat,,;
							            GDFieldGet('AAM_TIPFRE',n)	,,,,,,,,;
							            ,;
								        ,,,,,,,,;
								        GDFieldGet('DDC_CODNEG',n))

	 EndIf

Else
	DTP->(DbSetOrder(2))
	If DTP->(MsSeek(xFilial("DTP") + M->DTC_FILORI + M->DTC_LOTNFC))
		If lCamposRat
			lRateio := Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
		EndIf
	EndIf

	//-- Verifica se eh alianca de 2o percurso
	If lAlianca .And. TmsA050Dpc()
		If !Empty(cSrvAli)

			//-- Seleciona os servicos contidos no cotrato
			If TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat, lExib,;
								M->DTC_TIPFRE,l050Auto,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL, /*lPortalTMS*/, lRateio,;
								cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

				//-- Verifica se o servico selecionado no contrato eh um servico de alianca
				If	! ( AllTrim(M->DTC_SERVIC) $ cSrvAli )
					Help('',1,'TMSA05063',, STR0051 + cSrvAli,4,1)	//-- "Informe um dos servicos de transporte alianca de segundo percurso, contido no parametro MV_SRVALI"###"Serviços: "
					lRet := .F.
				Else
					If !Empty(M->DTC_CLIREM) .And. !Empty(M->DTC_LOJREM)  .And. !Empty(M->DTC_TIPFRE)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa se existe ajuste para o remetente, se nao existir ajuste utiliza ³
						//³o consignatario como cliente de calculo para pegar a tabela de frete da   ³
						//|Alianca (de segundo percurso)                                             |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aContrat := TMSContrat(M->DTC_CLIREM, M->DTC_LOJREM,,M->DTC_SERVIC,.F.,M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
						If !Empty(aContrat) .And. !Empty(M->DTC_CDRORI+M->DTC_CDRDES)
							DVC->(DbSetOrder(2))
							If DVC->(MsSeek(xFilial("DVC")+M->DTC_CLIREM+M->DTC_LOJREM+aContrat[1,3]+aContrat[1,4]))
								M->DTC_CLICAL := M->DTC_CLIREM
								M->DTC_LOJCAL := M->DTC_LOJREM
								M->DTC_NOMCAL := Iif(Type("M->DTC_NOMREM") == "C" , M->DTC_NOMREM , Space( Len(SA1->A1_NOME ) ) )
							EndIf
						EndIf
					EndIf
					If ExistTrigger("DTC_SERVIC")
						RunTrigger(2,,Nil,"DTC_SERVIC")
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o usuario preencher os campos de filial de alianca de segundo percurso  |
			//|avisa que o parametro MV_SRVALI (Servico de alianca padrao) esta em branco ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			Help("",1,"TMSA05056") //O parametro MV_SRVALI (Servico de alianca padrao) precisa ser informado para Nf de alianca
			lRet := .F.
		EndIf
	Else
		//-- A entrada de nota fiscal do cliente sera '0 Normal' ou '1 Devolucao Parcial' conforme o campo DTC_TIPNFC
		//-- Caso o tipo do servico for 'transporte', tipo de frete 'FOB' e houver contrato 'CIF' para o cliente destinatario,
		//-- perguntar ao usuario se eh uma devolucao parcial.
		lSrvDev := TmsA050SDv(M->DTC_TIPFRE,M->DTC_CLIDES,M->DTC_LOJDES,M->DTC_SERTMS,M->DTC_TIPTRA,.T.,;
							M->DTC_CLIREM,M->DTC_LOJREM, @cTpFreCsg,M->DTC_CLICAL,M->DTC_LOJCAL,M->DTC_CLIDEV,;
							M->DTC_LOJDEV,M->DTC_CLIDPC,M->DTC_LOJDPC,M->DTC_CODNEG)
		If	lSrvDev
			//-- A entrada de nota fiscal do cliente se refere a uma Devolucao Parcial
			//-- O calculo do frete ira gerar documentos de devolucao das NFC cujo DTC_TIPNFC igual a '1'
			M->DTC_TIPNFC := StrZero(1,Len(DTC->DTC_TIPNFC))

			If M->DTC_DEVFRE == StrZero(1,Len(DTC->DTC_DEVFRE))
				lRet := TMSPesqServ('DTC', M->DTC_CLIREM, M->DTC_LOJREM, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat, lExib,;
								        StrZero(2,Len(DTC->DTC_TIPFRE)),l050Auto,,.F.,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
								        /*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

			ElseIf M->DTC_DEVFRE == StrZero(2,Len(DTC->DTC_DEVFRE))
				lRet := TMSPesqServ('DTC', M->DTC_CLIDES, M->DTC_LOJDES, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat, lExib,;
								        StrZero(1,Len(DTC->DTC_TIPFRE)),l050Auto,,.F.,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
								        /*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

			ElseIf M->DTC_DEVFRE == StrZero(3,Len(DTC->DTC_DEVFRE))
				lRet := TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat, lExib,;
								        PadR( cTpFreCsg, Len(DTC->DTC_TIPFRE)),l050Auto,,.F.,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
								        /*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

			EndIf

		Else
			//-- Normal
			//-- Mas se redespacho intermediario mantem o tipo da nf como '9'
			If lRedespInt != .T.
				M->DTC_TIPNFC := StrZero(0,Len(DTC->DTC_TIPNFC))
			EndIf
			lRet := TMSPesqServ('DTC', M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_SERTMS, M->DTC_TIPTRA, @aItContrat, lExib,;
							        M->DTC_TIPFRE,l050Auto,,,,,,,M->DTC_CDRORI, M->DTC_CDRCAL,;
							        /*lPortalTMS*/, lRateio, cBACRAT, cCRIRAT, cPRORAT, cTABRAT, cTIPRAT, M->DTC_CODNEG )

		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Cot³ Autor ³ Patricia A. Salomao   ³ Data ³21.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apresenta Tela contendo as Cotacoes de Frete Aprovadas para ³±±
±±³          ³o Remetente/Destinatario informados na Nota.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050Cot()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA050Cot(nAt)

Local cCadastro  := STR0061 //"Cotacoes de Frete Aprovadas"
Local aRotOld    := aClone(aRotina)
Local cFiltro1   := ""
Local cSeek      := ""
Local cFilDT4    := xFilial("DT4")
Local lIncOld    := Inclui
Local lRet       := .T.
Local cFiltraSub := ""
Local cAliasDT4  := ""
Local cQuery     := ""

Default nAt      := 1

Private nOpcSel  := 0
Private l040Auto := .F. //-- Variavel utilizada pelo TMSA040 na Visualizacao da Cotacao
Private aIndexSub  := {}
Private bFiltraSub := {}

If Type("lCotacao") == "U"
   Private lCotacao  := .F.
EndIf
//-- Verifica se utiliza cotacao no lote
DTP->(DbSetOrder(2))
If DTP->(MsSeek(xFilial("DTP")+M->DTC_FILORI+M->DTC_LOTNFC))
	If !Empty(DTP->DTP_NUMCOT)
		Help("",1,"TMSA05069") // "Não será possível acessar a cotação quando utilizado a cotação no lote."
		lRet := .F.
	EndIf
EndIf

If lCotacao
	lRet := .F.
EndIf
If lRet
	Inclui := .F.
	aRotina	:= {}
	AAdd( aRotina, { STR0003 ,"TMSA040Mnt"	, 0, 2} ) //Visualizar
	//-- Controle de permissao de alteracao da cotacao
	If FWChkFuncAccess('TMSA040', 4, .F.)
		AAdd( aRotina, { STR0005 ,"TMSA040Mnt" , 0, 4} ) //Alterar
	EndIf

	If nAt == 1
		AAdd( aRotina, { STR0032 ,"TMSConfSel"	, 0, 2,,,.T.} ) //Confirmar
		//-- Apresenta todas as cotacoes aprovadas do remetente / destinatario
		DT4->(dbSetOrder(3))
		If !Empty(M->DTC_FILCFS)
			cFilDT4 := TMSA050CFS("DT4",M->DTC_FILCFS)
			cSeek   := cFilDT4+'3'+M->DTC_FILCFS+M->DTC_CLIREM+M->DTC_LOJREM+M->DTC_CLIDES+M->DTC_LOJDES
		Else
			cSeek   := cFilDT4+'3'+cFilAnt+M->DTC_CLIREM+M->DTC_LOJREM+M->DTC_CLIDES+M->DTC_LOJDES
		EndIf
		//Verifia se há cotações
		cAliasDT4 := GetNextAlias()
		cQuery := " SELECT DT4_NUMCOT" + CRLF
		cQuery += "   FROM " +	RetSqlName("DT4")  + CRLF
		cQuery += "  WHERE DT4_FILIAL = '"  + cFilDT4 + "'" + CRLF
		cQuery += "    AND DT4_FILORI = '" + IIf(!Empty(M->DTC_FILCFS), M->DTC_FILCFS, cFilAnt) + "'" + CRLF
		cQuery += "    AND DT4_CLIREM = '" + M->DTC_CLIREM + "'" + CRLF
		cQuery += "    AND DT4_LOJREM = '" + M->DTC_LOJREM + "'" + CRLF
		cQuery += "    AND DT4_CLIDES = '" + M->DTC_CLIDES + "'" + CRLF
		cQuery += "    AND DT4_LOJDES = '" + M->DTC_LOJDES + "'" + CRLF
		cQuery += "    AND DT4_STATUS = '3'" + CRLF
		cQuery += "    AND DT4_PRZVAL >= '" + DTOS(dDatabase) + "'"
		cQuery += "    AND D_E_L_E_T_<>'*'"
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDT4, .F., .T.)

		If !(cAliasDT4)->(Eof())
			aIndexSub  := {}
			cFiltraSub := "DT4_FILIAL=='" + cFilDT4 + "' .And. DT4_FILORI=='" + TMSA050CFS("DT4",M->DTC_FILCFS) + "'.And. DT4_STATUS == '3'" +;
				" .And. DT4_CLIREM=='" + M->DTC_CLIREM + "' .And. DT4_LOJREM=='" + M->DTC_LOJREM + "'" +;
				" .And. DT4_CLIDES=='" + M->DTC_CLIDES + "' .And. DT4_LOJDES=='" + M->DTC_LOJDES + "'" +;
				" .And. DTOS(DT4_PRZVAL) >= '" + DTOS(dDatabase) + "'"

			bFiltraSub := {|| FilBrowse("DT4",@aIndexSub,@cFiltraSub) }
			Eval(bFiltraSub)
			MaWndBrowse(0,0,300,600,cCadastro,"DT4",,aRotina,,,,.T.)
			EndFilBrw("DT4",aIndexSub)
			If nOpcSel == 1
				lCotacao := .T.
			EndIf
		EndIf
		(cAliasDT4)->(DbCloseArea())
	Else
		//-- Apresenta todas as cotacoes aprovadas
		DT4->(dbSetOrder(3))
		If !Empty(M->DTC_FILCFS)
			cFilDT4  := TMSA050CFS("DT4",M->DTC_FILCFS)
			cFiltro1 := '"'+cFilDT4+'3'+M->DTC_FILCFS+'"'
		Else
			cFiltro1 := '"'+cFilDT4+'3'+cFilAnt+'"'
		EndIf
		If DT4->(MsSeek(cSeek))
			MaWndBrowse(0,0,300,600,cCadastro,"DT4",,aRotina,,cFiltro1,cFiltro1,.T.)
		EndIf
	EndIf
EndIf

aRotina := aClone(aRotOld)
Inclui := lIncOld

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Ali³ Autor ³ Patricia A. Salomao   ³ Data ³02.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se a Nota Fiscal for de 1o. Percurso, gatilhar automaticamen³±±
±±³          ³te qual Filial de Alianca ira' realizar o Transporte , quan-³±±
±±³          ³do tiver mais que uma, sera' exibida uma tela possibilitando³±±
±±³          ³a escolha.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050Ali()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico/Filial de Alianca                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050Ali()

Local aFilAli   	:= {}
Local cSeekDVK  	:= ''
Local cFilDes   	:= ''
Local nOpcao    	:= 0
Local cCampo    	:= ReadVar()
Local lAlianca  	:= TMSAlianca() //-- Utiliza Alianca
Local lSinc     	:= TmsSinc() //-- Chamada do Sincroizador
Local lRet      	:= .T.
Local cCdrDes   	:= Space(Len(SA1->A1_CDRDES))
Local lTmA050Par	:= ExistBlock("TMA050PAR")
Local aRet			:= {}

//-- 1o. Percurso
If !lSinc .And. lAlianca .And. TmsA050Dpc()
	If cCampo == "M->DTC_CDRCAL"
		cCdrDes := M->DTC_CDRCAL
	Else
		If !Empty(M->DTC_CLIDES) .And. !Empty(M->DTC_LOJDES)
			cCdrDes := Posicione("SA1",1,xFilial("SA1") + M->DTC_CLIDES + M->DTC_LOJDES,"A1_CDRDES")
		Else
			Return( lRet )
		EndIf
	EndIf
	DVL->(dbSetOrder(1))
	DVK->(dbSetOrder(1))
	If DVK->(MsSeek(cSeekDVK:=xFilial('DVK')+ cCdrDes))
		Do While DVK->( ! Eof() .And. DVK->DVK_FILIAL + DVK->DVK_GRPVEN == cSeekDVK )
			If DVL->(MsSeek(xFilial('DVL')+DVK->DVK_FILALI))
				AAdd(aFilAli,{.F.,DVL->DVL_ALIANC,Posicione('SX5',1,xFilial('SX5')+'MI'+DVL->DVL_ALIANC, "X5DESCRI()")} )
			EndIf
			DVK->(DbSkip())
		EndDo
	EndIf
	//-- Se Nao Existir Alianca para a Filial da Regiao de Calculo, adicionar
	//-- no Array o nome da Filial Atual
	cFilDes := Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_FILDES")
	If DVL->(MsSeek(xFilial('DVL')+cFilDes))
		If Ascan(aFilAli, { |x| x[2] == DVL->DVL_ALIANC }) == 0
			AAdd(aFilAli,{.F.,DVL->DVL_ALIANC,Posicione('SX5',1,xFilial('SX5')+'MI'+DVL->DVL_ALIANC, "X5DESCRI()")} )
		EndIf
	ElseIf !Empty(aFilAli)
		SM0->(MsSeek(cEmpAnt + cFilAnt))
		AAdd(aFilAli,{.F.,Space(Len(DVL->DVL_ALIANC)),Capital(SM0->M0_NOME) })
	EndIf
	If !Empty(aFilAli)
		If Len(aFilAli) > 1
			//-- Ordenar por Ordem de Filial Alianca
			aSort(aFilAli,,,{|x,y| x[1] < y [1] })
			//-- Ponto de entrada antes de apresentar a tela "Tabela de Parceiros "
			//-- seu objetivo é marcar uma das opções a fim de que, quando a
			//-- tela fosse apresentada ao usuário ele precisasse apenas clicar OK.
			If lTmA050Par
				aRet := ExecBlock("TMA050PAR",.F.,.F., {cCdrDes,aFilAli} )
				If (ValType(aRet)=="A")
					aFilAli := AClone(aRet)
				EndIf
			EndIf
			//-- Mostra Tela com as Filiais de Alianca
			If !TMSABrowse( aFilAli, STR0062,,,,.T., {STR0063,STR0060} ) //"Tabela de Parceiros"###"Aliança"###"Descrição"
				lRet := .F.
			EndIf
			nOpcao := Ascan(aFilAli, { |x| x[1] == .T. })
		Else
			nOpcao := 1
		EndIf
		If nOpcao > 0 .And. !Empty(aFilAli[nOpcao][2])
			M->DTC_ALIANC := aFilAli[nOpcao][2]
			M->DTC_DESALI := aFilAli[nOpcao][3]
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tms050Col³ Autor ³ Eduardo de Souza      ³ Data ³ 22/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao no Cadastro de Solicitacao de Coletas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tms050Col()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigatms                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms050Col()

Local cTitulo  := STR0033 // "Solicitacao de Coleta"
Local cFiltro1 := ''
Local cFilBac  := ''
Local aCampos  := {}
Local aOldRot  := aRotina
Local aRotina  := {}
Local lTmsCFec := TmsCFec()
Local nX       := 0
Local aDT5Stru  := FwFormStruct(2,"DT5")

Private nOpcSel := 0

//-- Define os campos que não devem ser usados...
For nX:= 1 To Len(aDT5Stru:aFields)
	If GetSx3Cache(aDT5Stru:aFields[nX][2],"X3_BROWSE") == "S"
		Aadd(aCampos,aDT5Stru:aFields[nX][2])
	EndIf
Next nX

aRotina := {	{ STR0003,"TMSA460Mnt",0,2},;		// "Visualizar"
				{ STR0032,"TMSConfSel",0,2,,,.T.}}	// "Confirmar"

If lTmsCFec
	If Type("M->DTC_FILORI") == "U"
		RegToMemory('DTC',.T.)
	EndIf
    If !Empty(M->DTC_FILCFS)
        cFiltro1 := 'DT5_FILORI = "' + M->DTC_FILCFS + '" .And. '
    Else
        cFiltro1 := 'DT5_FILORI = "' + M->DTC_FILORI + '" .And. '
    EndIf
	cFiltro1 += 'DT5->DT5_STATUS <> "' + StrZero(1,Len(DT5->DT5_STATUS)) + '" .And. ' //-- Em Aberto
	cFiltro1 += 'DT5->DT5_STATUS <> "' + StrZero(5,Len(DT5->DT5_STATUS)) + '" .And. ' //-- Documento Informado
	cFiltro1 += 'DT5->DT5_STATUS <> "' + StrZero(6,Len(DT5->DT5_STATUS)) + '" .And. ' //-- Bloqueada
	cFiltro1 += 'DT5->DT5_STATUS <> "' + StrZero(9,Len(DT5->DT5_STATUS)) + '"'  //-- Cancelada
Else
	cFiltro1 += 'DT5->DT5_STATUS == "' + StrZero(4,Len(DT5->DT5_STATUS)) + '"'  //-- Encerrada
EndIf

cFilBac := cFiltro1

If ExistBlock('TM050FSC')	//-- Filtro da Solicitacao de Coleta
	cFiltro1 := ExecBlock('TM050FSC',.F.,.F.)
	If ValType(cFiltro1) <> 'C'
		cFiltro1:= cFilBac
	EndIf
EndIf

dbSelectArea("DT5")
DbSetOrder(1)
Set Filter To &(cFiltro1)

MaWndBrowse(0,0,300,600,cTitulo,"DT5",aCampos,aRotina,,,,.T.)

DbClearFilter()
aRotina := aOldRot

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA050Dpc³ Autor ³ Alex Egydio           ³ Data ³02.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se eh CTRC de alianca de 2o. Percurso             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. = CTRC de alianca de 2o. Percurso                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA050Dpc()

Local lRet := .F.
Local nPosFIL := 0
Local nPosCTR := 0
//-- Executado somente se lAlianca igual a .T.
//-- Verifica se preencheu a filial do despachante e CTRC do despachante
nPosFIL := aScan( aHeader,{|x| x[2]== 'DTC_FILDPC'})
nPosCTR := aScan( aHeader,{|x| x[2]== 'DTC_CTRDPC'})

If Len(aCols) > 0
	lRet := ( ! Empty(aCols[n][nPosFIL]) .And. ! Empty(aCols[n][nPosCTR]) )
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA050Dli³ Autor ³ Alex Egydio           ³ Data ³06.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca como deletado o vetor avalinf                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA050DLi()

Local cNumNfc	:= GdFieldGet('DTC_NUMNFC',n)
Local cSerNfc	:= GdFieldGet('DTC_SERNFC',n)
Local cCodPro	:= GdFieldGet('DTC_CODPRO',n)
Local lDelete	:= GdDeleted(n)
Local nCntFor	:= 0

For nCntFor := 1 To Len(aValInf)
	If	aValInf[nCntFor,4]+aValInf[nCntFor,5]+aValInf[nCntFor,6]==cNumNfc+cSerNfc+cCodPro
		aValInf[nCntFor,3]:=lDelete
	EndIf
Next

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050CFec³ Autor ³ Eduardo de Souza     ³ Data ³ 04/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Ocorrencias / Cancela Viagem em Aberto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050CFec()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Documento                                   ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie Documento                                    ³±±
±±³          ³ ExpN1 - Volume                                             ³±±
±±³          ³ ExpN2 - Peso                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigatms                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA050CFec(cFilDoc,cDocto,cSerie,nQtdVol,nPeso, dDatCol, cHorCol, cRecebe, nOdoChg, dDatChg, cHorChg, dDatSai, cHorSai, lCancSol)
Local cFilVga       := ''
Local cViagem       := ''
Local aCab          := {}
Local aItens        := {}
Local lCancViag     := .T.
Local cSeekDTW      := ""
Local lContVei      := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local cFilDT5       := xFilial('DT5')
Local cSeek         := ''
Local aArea         := GetArea()
Local aAreaDTC      := DTC->(GetArea())
Local cOcorCan      := SuperGetMv('MV_OCORCAN',,'') //-- Ocorrencia de Cancelamento para viagem planejada em aberto
Local cQuery        := ''
Local cAliasQry     := GetNextAlias()
Local nVlrOco       := 0
Local nPm3Oco       := 0
Local nMt3Oco       := 0
Local nQtuOco       := 0
Local nBasOco       := 0
Local lITmsDmd    := SuperGetMv("MV_ITMSDMD",,.F.)

Private lMsErroAuto := .F.

Default dDatCol     := M->DTC_DATCOL
Default cHorCol     := M->DTC_HORCOL
Default cRecebe     := M->DTC_RECEBE
Default nOdoChg     := 0
Default dDatChg     := CtoD(Space(08))
Default cHorChg     := ''
Default dDatSai     := CtoD(Space(08))
Default cHorSai     := ''
Default lCancSol    := .F.

//-- Retorna a viagem da Solicitacao de coleta
DUD->(DbSetOrder(1))
If DUD->(MsSeek(xFilial("DUD")+cFilDoc+cDocto+cSerie))
	While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE == ;
		xFilial("DUD") + cFilDoc + cDocto + cSerie
		If	DUD->DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS)) .And.;	//-- Cancelado
			DUD->DUD_STATUS <> StrZero(4, Len(DUD->DUD_STATUS)) 		//-- Encerrado
			cFilVga := DUD->DUD_FILORI
			cViagem := DUD->DUD_VIAGEM
			Exit
		EndIf
		DUD->(DbSkip())
	EndDo
EndIf

If !Empty(cFilVga) .And. !Empty(cViagem) .And. !Empty(cOcorCol)
	DTC->(DbSetOrder(8))
	If DTC->(MsSeek(xFilial('DTC') + cFilVga + cDocto))
		nQtdVol := 0
		nPeso   := 0
		nVlrOco := 0
		nPm3Oco := 0
		nMt3Oco := 0
		nQtuOco := 0
		nBasOco := 0

		DT5->(DbSetOrder(1))
		If !Empty(DTC->DTC_FILCFS)
			cFilDT5 := TMSA050CFS("DT5",DTC->DTC_FILCFS)
			cSeek   := cFilDT5+DTC->DTC_FILCFS+DTC->DTC_NUMSOL
		Else
			cSeek := cFilDT5+DTC->DTC_FILORI+DTC->DTC_NUMSOL
		EndIf
		If DT5->(MsSeek(cSeek))
			While DTC->(DTC_FILIAL+DTC_FILORI+DTC_NUMSOL) == xFilial('DTC') + DT5->(DT5_FILORI + DT5_NUMSOL)

				nQtdVol += DTC->DTC_QTDVOL
				nPeso   += DTC->DTC_PESO

				//-- Componentes Para Valorização Da Coleta
				If DUA->(ColumnPos("DUA_BASOCO")) > 0
					nVlrOco += DTC->DTC_VALOR
					nPm3Oco += DTC->DTC_PESOM3
					nMt3Oco += DTC->DTC_METRO3
					nQtuOco += DTC->DTC_QTDUNI
					nBasOco += DTC->DTC_BASSEG
				EndIf

				DTC->(DbSkip())
			EndDo
		EndIf
	EndIf

	//-- Cabecalho da Ocorrencia
	AAdd(aCab,{"DUA_FILORI",cFilVga,Nil})
	AAdd(aCab,{"DUA_VIAGEM",cViagem,Nil})
	//-- Itens da Ocorrencia
	AAdd(aItens, {	{"DUA_SEQOCO", StrZero(1,Len(DUA->DUA_SEQOCO)) , Nil},;
					{"DUA_DATOCO", dDatCol                          , Nil},;
					{"DUA_HOROCO", cHorCol                          , Nil},;
					{"DUA_CODOCO", cOcorCol                         , Nil},;
					{"DUA_RECEBE", cRecebe                          , Nil},;
					{"DUA_SERTMS", StrZero(1,Len(DUA->DUA_SERTMS)) , Nil},;
					{"DUA_FILDOC", cFilDoc                          , Nil},;
					{"DUA_DOC"   , cDocto                           , Nil},;
					{"DUA_SERIE" , cSerie                           , Nil},;
					{"DUA_QTDOCO", nQtdVol                          , Nil},;
					{"DUA_PESOCO", nPeso                            , Nil}})

	//-- Componentes Para Valorização Da Coleta
	If DUA->(ColumnPos("DUA_BASOCO")) > 0
		AAdd( aItens[1], {"DUA_VLROCO", nVlrOco  , Nil})
		AAdd( aItens[1], {"DUA_PM3OCO", nPm3Oco  , Nil})
		AAdd( aItens[1], {"DUA_MT3OCO", nMt3Oco  , Nil})
		AAdd( aItens[1], {"DUA_QTUOCO", nQtuOco  , Nil})
		AAdd( aItens[1], {"DUA_BASOCO", nBasOco  , Nil})
	EndIf

	If !Empty(nOdoChg)
		AAdd( aItens[1], {"DUA_ODOCHG", nOdoChg , Nil})
	EndIf

	If !Empty(dDatChg) .And. !Empty(cHorChg)
		AAdd( aItens[1], {"DUA_DATCHG", dDatChg , Nil})
		AAdd( aItens[1], {"DUA_HORCHG", cHorChg , Nil})
	EndIf

	If !Empty(dDatSai) .And. !Empty(cHorSai)
		AAdd( aItens[1], {"DUA_DATSAI", dDatChg	 , Nil})
		AAdd( aItens[1], {"DUA_HORSAI", cHorChg	 , Nil})
	EndIf

	//-- Verifica se a viagem devera ser cancelada
	DTQ->(DbSetOrder(2))
	If DTQ->(MsSeek(xFilial("DTQ")+cFilVga+cViagem))
		If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .Or. ; //-- Em Aberto
			DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS)) //-- Fechada

			DUD->(DbSetOrder(1))
			If DUD->(MsSeek(xFilial("DUD")+cFilDoc+cDocto+cSerie+cFilVga+cViagem)) .And. DUD->DUD_STATUS == StrZero(1,Len(DUD->DUD_STATUS))
				lCancSol := .T.
				aItens[1][4][2] := cOcorCan
				//-- Inclusao da Ocorrencia
				MsExecAuto({|w,x,y,z|Tmsa360(w,x,y,z)},aCab,aItens,{},3)
			EndIf

			//--Status DUD:
			//-- 1=Em Aberto
			//-- 2=Em Transito
			//-- 3=Carregado
			//-- 4=Encerrado
			//-- 9=Cancelado

			cQuery := "SELECT COUNT(*) nDoctos"
			cQuery += "  FROM " + RetSQLTab('DUD')
			cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial('DUD') + "' AND "
			cQuery += "       DUD.DUD_FILORI = '" + cFilVga + "' AND "
			cQuery += "       DUD.DUD_VIAGEM = '" + cViagem + "' AND "
			cQuery += "       DUD.DUD_STATUS <> '" + StrZero(9,Len(DUD->DUD_STATUS)) + "' AND "
			cQuery += "       DUD.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

			//--Se houverem documentos com o status
			//--diferentes de "CANCELADOS" não pode
			//--cancelar a viagem.
			lCancViag := (cAliasQry)->nDoctos == 0

			(cAliasQry)->(DbCloseArea())

			If !lCancSol
				//-- Inclusao da Ocorrencia
				MsExecAuto({|w,x,y,z|Tmsa360(w,x,y,z)},aCab,aItens,{},3)
			EndIf

			//-- Cancelamento de Viagem
			If lCancViag
				//-- Cancela viagem de coleta, qdo a viagem estiver em aberto ou fechada.
				RecLock("DTQ",.F.)
				DTQ->DTQ_STATUS := StrZero(9,Len(DTQ->DTQ_STATUS))
				MsUnLock()
				
				//Cancela planejamento de demandas
				If lITmsDmd .And. FindFunction("TMSCanPln") .And. TableInDic("DL9")
					TMSCanPln(DTQ->DTQ_VIAGEM, "8")
				EndIf
				
				//-- Exclui todas operacoes da viagem
				DTW->(dbSetOrder(3))
				DTW->(MsSeek(cSeekDTW := xFilial("DTW")+DTQ->(DTQ_FILORI+DTQ_VIAGEM)))
				While DTW->(!Eof() .And. DTW_FILIAL+DTW_FILORI+DTW_VIAGEM == cSeekDTW)
					RecLock("DTW",.F.)
					DTW->(DbDelete())
					MsUnLock()
					DTW->(DbSkip())
				EndDo
				//-- Deixa veiculo/motorista em aberto caso o controle de veiculo esteja ativo
				If lContVei
					TMSA340Sta(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '3', '1')
				EndIf

				Aviso( STR0009, STR0087 + DTQ->DTQ_FILORI + "/" + DTQ->DTQ_VIAGEM + STR0088, {"Ok"} ) //"Atencao" ### "A viagem xxxx, na qual a solicitação de coleta informada na entrada da Nota Fiscal de Cliente está amarrada, será cancelada, pois a viagem encontra-se em aberto. "

			EndIf

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Rotina Permitir que seja apontada ocorrencia de Encerra Coleta com a viagem estando EM TRANSITO e CHEGADA EM FILIAL //
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Status do DTQ         //
		// 1 - Em Aberto         //
		// 2 - Em Transito       //
		// 3 - Encerrada         //
		// 4 - Chegada em Filial //
		// 5 - Fechada           //
		// 9 - Cancelada         //
		///////////////////////////
		ElseIf DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) .Or. DTQ->DTQ_STATUS == StrZero(4,Len(DTQ->DTQ_STATUS))
			//-- Inclusao da Ocorrencia de Coleta Efetuada
			MsExecAuto({|w,x,y,z|Tmsa360(w,x,y,z)},aCab,aItens,{},3)
		EndIf
	EndIf
	//-- Se houve problemas apresenta o motivo do erro.
	If lMsErroAuto
		MostraErro()
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDTC)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050EstCFec³ Autor ³ Eduardo de Souza     ³ Data ³ 04/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorna Ocorrencias / Atualiza Status de viagem cancelada. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050EstCFec()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Documento                                   ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie Documento                                    ³±±
±±³          ³ ExpN1 - Filial Origem                                      ³±±
±±³          ³ ExpN2 - Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigatms                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050EstCFec(cFilDoc,cDocto,cSerie,cFilVga,cViagem)

Local aCab      := {}
Local aItens    := {}
Local lContVei  := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local lRet      := .T.
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local aAreaDT5  := DT5->(GetArea())

Private lMsErroAuto := .F.

//--Obtem a ocorrencia de cancelamento
//--para o estorno:

//--A ocorrencia de cancelamento deve ser
//--a ultima ocorrencia apontada para o
//--documento.
cQuery := "SELECT MAX(DUA.R_E_C_N_O_) nRecDUA"
cQuery += "  FROM " + RetSQLTab('DUA')
cQuery += " WHERE DUA.DUA_FILIAL  = '" + xFilial('DUA') + "'  AND "
cQuery += "       DUA.DUA_FILDOC  = '" + cFilDoc + "' AND "
cQuery += "       DUA.DUA_DOC     = '" + cDocto  + "' AND "
cQuery += "       DUA.DUA_SERIE   = '" + cSerie  + "' AND "
cQuery += "       DUA.DUA_FILORI  = '" + cFilVga + "' AND "
cQuery += "       DUA.DUA_VIAGEM  = '" + cViagem + "' AND "
cQuery += "       DUA.D_E_L_E_T_  = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

If (cAliasQry)->nRecDUA > 0
	DUA->(DbGoto((cAliasQry)->nRecDUA))

	//-- Cabecalho da Ocorrencia
	AAdd( aCab, {"DUA_FILOCO", DUA->DUA_FILOCO, Nil} )
	AAdd( aCab, {"DUA_NUMOCO", DUA->DUA_NUMOCO, Nil} )
	AAdd( aCab, {"DUA_FILORI", DUA->DUA_FILORI, Nil} )
	AAdd( aCab, {"DUA_VIAGEM", DUA->DUA_VIAGEM, Nil} )

	//-- Itens da Ocorrencia
	AAdd(aItens,{	{"DUA_SEQOCO", DUA->DUA_SEQOCO , Nil},;
					{"DUA_ESTOCO", StrZero( 1, TamSX3('DUA_ESTOCO')[1]), Nil},;
					{"DUA_DATOCO", DUA->DUA_DATOCO , Nil},;
					{"DUA_HOROCO", DUA->DUA_HOROCO , Nil},;
					{"DUA_CODOCO", DUA->DUA_CODOCO , Nil},;
					{"DUA_SERTMS", DUA->DUA_SERTMS , Nil},;
					{"DUA_FILDOC", DUA->DUA_FILDOC , Nil},;
					{"DUA_DOC"   , DUA->DUA_DOC    , Nil},;
					{"DUA_SERIE" , DUA->DUA_SERIE  , Nil},;
					{"DUA_QTDOCO", DUA->DUA_QTDOCO , Nil},;
					{"DUA_PESOCO", DUA->DUA_PESOCO , Nil}})

	//-- Estorno da Ocorrencia
	MsExecAuto({|w,x,y,z| Tmsa360(w,x,y,z)},aCab,aItens,{},6)

	//-- Se houve problemas apresenta o motivo do erro.

	If lMsErroAuto
		lRet := .F.
		MostraErro()
	EndIf

	(cAliasQry)->(DbCloseArea())
EndIf

RestArea(aArea)
RestArea(aAreaDT5)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA050SDv³ Autor ³ Alex Egydio           ³ Data ³30.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informa que o cliente destinatario tem contrato CIF e      ³±±
±±³          ³ pergunta se a entrada de nota fiscal do cliente se refere a³±±
±±³          ³ uma devolucao parcial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo do frete                                      ³±±
±±³          ³ ExpC2 - Codigo do cliente                                  ³±±
±±³          ³ ExpC3 - Loja                                               ³±±
±±³          ³ ExpC4 - Tipo de servico                                    ³±±
±±³          ³ ExpC5 - Tipo de transporte                                 ³±±
±±³          ³ ExpL1 - Mostra Mensagem na Tela ?                          ³±±
±±³          ³ ExpC6 - Codigo do cliente remetente                        ³±±
±±³          ³ ExpL1 - Loja do cliente remetente                          ³±±
±±³          ³ ExpC1 - Tipo do frete - Consignatario                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA050SDv( cTipFre, cCliDes, cLojDes, cSerTms, cTipTra, lMostraMsg, cCliRem, cLojRem, cTpFreCsg ,;
					 cCliCal, cLojCal, cCliDev, cLojDev, cCliDpc, cLojDpc, cCodNeg)
Local aContrat	  := {}
Local nTipFre	  := Len(DTC->DTC_TIPFRE)
Local lRet		  := .F.
Local lExistDTI	  := .F.
Local cClGen	  := ''
Local cLjGen	  := ''
Local cCliGen	  := GetMV("MV_CLIGEN",,'')
Local lDTIDev	  := .F.   //Verifica se DTI e para devolucao
Local cConsig     := ''
Local cLojConsig  := ''
Local aAreaDTI    := DTI->( GetArea() )

Default lMostraMsg := .T.
Default cCliRem	   := ""
Default cLojRem    := ""
Default cCliCal	   := ""
Default cLojCal    := ""
Default cCliDev	   := ""
Default cLojDev	   := ""
Default cCliDpc	   := ""
Default cLojDpc	   := ""
Default cCodNeg    := ""

Begin Sequence
//-- Rodoviario Internacional
If !('TMSA050' $ FunName()) .And. cTipTra == '4'
	Break
EndIf

cClGen := Left(Alltrim(cCliGen),Len(cCliRem))
cLjGen := Right(Alltrim(cCliGen),Len(cLojRem))

//-- Verifica se existe cadastro de consignatarios
If !Empty(cCliRem)
	If TmsConsig(cCliRem,cLojRem,cCliDes,cLojDes)
		lExistDTI := .T.
	ElseIf TmsConsig(cCliRem,cLojRem,cClGen,cLjGen)
		lExistDTI := .T.
	ElseIf TmsConsig(cClGen,cLjGen,cCliDes,cLojDes)
		lExistDTI := .T.
	EndIf

	If lExistDTI
		cConsig    := DTI->DTI_CLICON
		cLojConsig := DTI->DTI_LOJCON
		cTpFreCsg  := DTI->DTI_TIPFRE
	EndIf

EndIf

//-- Verifica se existe cadastro de consignatarios (Inverso) = Destinatairo/Remetente
If !lExistDTI
	If TmsConsig(cCliDes,cLojDes,cCliRem,cLojRem)
		lDTIDev := .T.
	ElseIf TmsConsig(cCliDes,cLojDes,cClGen,cLjGen)
		lDTIDev := .T.
	ElseIf TmsConsig(cClGen,cLjGen,cCliRem,cLojRem)
		lDTIDev := .T.
	EndIf

	If lDTIDev
		cConsig    := DTI->DTI_CLICON
		cLojConsig := DTI->DTI_LOJCON
		cTpFreCsg  := DTI->DTI_TIPFRE
	EndIf

EndIf

//-- Caso o tipo do servico for 'transporte'
//-- perguntar ao usuario se eh uma devolucao parcial.
If	cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))

	If cTipFre == StrZero(2,nTipFre) .And. !lDTIDev //--cTipFre == 2 --> FOB (Destinatario = Devedor do Frete)

		//--Procura o contrato (FOB) para o destinatario
		aContrat:= TMSContrat(cCliDes,cLojDes,,,.F.,StrZero(2,nTipFre),.F.,,,,,,,,,,,,,,,M->DTC_CODNEG)
		If Empty(aContrat)
			//--Procura o contrato invertido (CIF)
			aContrat:= TMSContrat(cCliDes,cLojDes,,,.F.,StrZero(1,nTipFre),.F.,,,,,,,,,,,,,,,cCodNeg)
			If !Empty(aContrat) .And. aContrat[1,30] == StrZero( 2, nTipFre )  //-- Se o contrato encontrado for FOB mostra mensagem de devolução
				lMostraMsg := .F.
				lRet       := .F.
			ElseIf !Empty(aContrat) .And. aContrat[1,30] != StrZero( 2, nTipFre )
				lMostraMsg := .T.
			EndIf
		Else
			lMostraMsg := .F.
			lRet       := .F.
		EndIf

	ElseIf cTipFre == StrZero(1,nTipFre) .And. !lDTIDev //--cTipFre == 1 --> CIF (Remente = Devedor do Frete)

		//--Procura o contrato (CIF) para o remetente
		aContrat:= TMSContrat(cCliRem,cLojRem,,,.F.,StrZero(1,nTipFre),.F.,,,,,,,,,,,,,,,cCodNeg)
		If Empty(aContrat)
			//--Procura o contrato invertido (FOB)
			aContrat:= TMSContrat(cCliRem,cLojRem,,,.F.,StrZero(2,nTipFre),.F.,,,,,,,,,,,,,,,cCodNeg)
			If !Empty(aContrat) .And. aContrat[1,30] == StrZero( 1, nTipFre )  //-- Se o contrato encontrado for CIF mostra mensagem de devolução
				lMostraMsg := .F.
				lRet       := .F.
			ElseIf !Empty(aContrat) .And. aContrat[1,30] != StrZero( 1, nTipFre )
				lMostraMsg := .T.
			EndIf
		Else
			lMostraMsg := .F.
			lRet       := .F.
		EndIf

	EndIf

	If lDTIDev
		aContrat:= TMSContrat(cConsig,cLojConsig,,,.F.,cTpFreCsg,.F.,,,,,,,,,,,,,,,cCodNeg)
	EndIf

	If lExistDTI
		aContrat:= TMSContrat(cConsig,cLojConsig,,,.F.,cTpFreCsg,.F.,,,,,,,,,,,,,,,cCodNeg)
		If !Empty(aContrat)
			lMostraMsg := .F.
		EndIf
	EndIf

	If	!Empty(aContrat)

		//--Ponto de entrada para determinar se a mensagem referente
		//--a devolucao deve ser exibida ou nao:
		If lTMA050Msg
			lMostraMsg := ExecBlock('TMA050MSG',.F.,.F.,{cCliRem,cLojRem,cCliDes,cLojDes,cCliDev,cLojDev,;
										cCliCal,cLojCal,cConsig,cLojConsig,cCliDpc,cLojDpc,cTipTra,cSerTms,cTipFre,lMostraMsg})
			If ValType(lMostraMsg) <> 'L'
				lMostraMsg := .T.
			EndIf
		EndIf

		If lMostraMsg
			lRet := Aviso(STR0009,STR0064,{STR0024,STR0025},2,'')==1 //"Atencao" ### "A entrada de nota fiscal do cliente se refere a uma devolucao parcial ?" ### "Sim" ### "Nao"
		EndIf

	EndIf
EndIf

If lRet .And. ( !lExistDTI .And. !lDTIDev )
	M->DTC_CLICON := CriaVar('DTC_CLICON',.F.)
	M->DTC_LOJCON := CriaVar('DTC_LOJCON',.F.)
	M->DTC_NOMCON := CriaVar('DTC_NOMCON',.F.)
EndIf

End Sequence

RestArea( aAreaDTI )
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050WhTpNf³ Autor ³ Alex Egydio           ³ Data ³25.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se o doctms do servico igual a 6 - devolucao, nao permite  ³±±
±±³          ³ alterar o conteudo de DTC_TIPNFC                           ³±±
±±³          ³ Utilizado no X3_WHEN do campo DTC_TIPNFC                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050WhTpNf()

Local lRet := .T.
Local lIdentDoc  := DTC->(ColumnPos("DTC_DOCTMS")) > 0
If	Posicione('DC5',1,xFilial('DC5')+M->DTC_SERVIC,'DC5_DOCTMS')==StrZero(6,Len(DC5->DC5_DOCTMS))
	lRet := .F.
ElseIf lIdentDoc .And. M->DTC_DOCTMS == StrZero(6,Len(DTC->DTC_DOCTMS))
	lRet := .F.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050TipVei³ Autor ³Patricia A. Salomao    ³ Data ³29.11.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Informar os Tipos de Veiculo que serao utilizados na Nota   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050TipVei()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpC1 - Filial de Origem                                    ³±±
±±³          ³ExpC2 - No. Solicitacao de Coleta                           ³±±
±±³          ³ExpC3 - No. Cotacao de Frete                                ³±±
±±³          ³ExpC4 - No. da Nota Fiscal                                  ³±±
±±³          ³ExpC5 - Serie da Nota Fiscal                                ³±±
±±³          ³ExpC6 - Cliente Remetente                                   ³±±
±±³          ³ExpC7 - Loja Cliente Remetente                              ³±±
±±³          ³ExpC8 - Apresenta Tela dos Tipos de Veiculo (.T. / .F.)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050TipVei(nOpcx, cFilOri, cNumSol, cNumCot,cNumNFC,cSerNFC,cCliRem,cLojRem, lTela)

Local nOpc         := 0
Local nCntFor      := 0
Local nSavN        := n
Local nPosNota     := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NUMNFC"})
Local nPosSerie    := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_SERNFC"})
Local nPosTipVeiNF := IIf(Type("aColsDVU") == "A" ,Ascan(aColsDVU,{|x| x[1] == aCols[n][nPosNota]+aCols[n,nPosSerie]+M->DTC_CLIREM+M->DTC_LOJREM}),0)
Local oDlgEsp      := Nil
Local aButtons     := {}
Local aSavCols     := AClone(aCols)
Local cItem        := "+DVU_ITEM"
Local cSeek        := ""
Local cWhile       := "DVU->(DVU_FILIAL+DVU_FILORI+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM)"
Local lIncOld      := Inclui
Private oGetD
Default nOpcx      := 3
Default cFilOri    := ''
Default cNumSol    := ''
Default cNumCot    := ''
Default cNumNFC    := ''
Default cSerNFC    := ''
Default cCliRem    := ''
Default cLojRem    := ''
Default lTela      := .T.

If (Empty(M->DTC_CLIREM) .or. Empty(M->DTC_LOJREM) .or. Empty(cNumNFC)) .And. lTela
	Help('',1,'TMSA05065')   //-- Informe o Codigo / Loja do Cliente Remetente e Numero/Serie da Nota Fiscal ...
	Return( .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

cSeek   := TMSA050CFS("DVU",M->DTC_FILCFS)+IIf(Empty(M->DTC_FILCFS),M->DTC_FILCFS,M->DTC_FILORI)+aCols[n,nPosNota]+aCols[n,nPosSerie]+M->DTC_CLIREM+M->DTC_LOJREM+StrZero(1,Len(DVU->DVU_ITEM))
n       := 1
aCols   := {}
aHeader := {}

If Len(aHeaderDVU) == 0
	FillGetDados(/*nOpcx*/4,"DVU",1,cSeek,{|| &cWhile },{||.T.},/*aNoFields*/{"DVU_LOTNFC"},/*aYesFields*/{"DVU_ITEM","DVU_TIPVEI","DVU_DESVEI","DVU_QTDVEI","DVU_ALI_WT","DVU_REC_WT"},/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)
	aCols[1][Ascan(aHeader,{|x| AllTrim(x[2]) == "DVU_ITEM"})] := StrZero(1,Len(DVU->DVU_ITEM)) //Preenche o Item
	aHeaderDVU := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDVU)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPosTipVeiNF > 0
	aCols := aClone(aColsDVU[nPosTipVeiNF][2])
	If nOpcx <> 4  //Caso seja alteracao o campo DVU_ITEM sera preenchido com o valor gravado na base.
		aCols[1][Ascan(aHeader,{|x| AllTrim(x[2]) == "DVU_ITEM"})] := StrZero(1,Len(DVU->DVU_ITEM)) //Preenche o Item
	EndIf
	cItem := "+DVU_ITEM"
ElseIf nOpcx <> 2 .And. !Empty(M->DTC_NUMSOL)
	//Na visualizacao nao exibir os veiculos informados na solicitacao/cotacao
	//-- Verifica se existem tipos de veiculos para a solicitacao/cotacao.
	aTipVeiSolCF(M->DTC_FILORI, M->DTC_NUMSOL, M->DTC_NUMCOT)
	cItem := "+DVT_ITEM"
EndIf

If Empty(aCols)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aCols,Array(Len(aHeaderDVU)+1))
	For nCntFor := 1 to Len(aHeaderDVU)
		If aHeader[nCntFor,10] != "V"
			aCols[1][nCntFor] := CriaVar(aHeaderDVU[nCntFor][2])
		Else
			If aHeader[nCntFor,2] == "DVU_ALI_WT"
				aCols[Len(aCols),nCntFor]:= "DVU"
			ElseIf aHeader[nCntFor,2] == "DVU_REC_WT"
				aCols[Len(aCols),nCntFor]:= 0
			Else
				aCols[Len(aCols),nCntFor]:=CriaVar(aHeader[nCntFor,2])
			EndIf
		EndIf
	Next nCntFor
	aCols[1][Ascan(aHeaderDVU, {|x| AllTrim(x[2]) == 'DVU_ITEM' })] := StrZero(1,Len(DVU->DVU_ITEM))
	aCols[1][Len(aHeaderDVU)+1] := .F.
EndIf

If lTela
	Inclui := .T.
	DEFINE MSDIALOG oDlgEsp FROM 94 ,104 TO 310,590 TITLE STR0065 Of oMainWnd PIXEL //"Tipos de veículo do documento"

		oGetD := MSGetDados():New(30,2,105,243,IIf(l050Visual,2,3),'A050TipLOk()','AllwaysTrue()',cItem,IIf(nOpcx==3 .Or. nOpcx==4,.T.,Nil),,,,100)
		@ 6  ,116 SAY '' Of oDlgEsp PIXEL SIZE 26 ,9
		@ 18 ,3   SAY STR0016 + ': ' Of oDlgEsp PIXEL SIZE 56 ,9 //"Nota Fiscal"
		@ 18 ,45  SAY cNumNFC+' / '+cSerNFC Of oDlgEsp PIXEL SIZE 50 ,9

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||IIF(oGetD:TudoOk(),(nOpc:=1,oDlgEsp:End()),(nOpc:=0))},{||oDlgEsp:End()},, aButtons )

Else
	nOpc := 1
EndIf

If nOpc == 1
	If nPosTipVeiNF > 0
		aColsDVU[nPosTipVeiNF][2]	:= aClone(aCols)
	Else
		AAdd(aColsDVU,{aSavCols[nSavN][nPosNota]+aSavCols[nSavN][nPosSerie]+M->DTC_CLIREM+M->DTC_LOJREM,aClone(aCols)})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as Variaveis da GetDados Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestInter()

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)
Inclui := lIncOld
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050TipLOk³ Autor ³Patricia A. Salomao    ³ Data ³29.11.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao das linhas digitadas na GetDados de Tp. de Veiculo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050TipLOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050TipLOk()

Local lRet    := .T.
//--Este tratamento no cTipVei e para diferenciar quando a tabela e DVT ou DVU,
//--de acordo com a rotina que vem os veiculos, solicitacao ou nota fiscal
Local cTipVei := Substring(aHeader[1][2],1,3) + "_TIPVEI"

//-- Analisa se ha itens duplicados na GetDados
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	lRet := GDCheckKey( { cTipVei } , 4 )
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aTipVeiSol³ Autor ³Patricia A. Salomao    ³ Data ³29.11.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche o Acols de Tipos de Veiculo da Nota Fiscal com os  ³±±
±±³          ³Tipos de Veiculo informados na Solicitacao de Coleta /      ³±±
±±³          ³Cotacao de Frete                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aTipVeiSolCF()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial de Origem                                    ³±±
±±³          ³ExpC2 - No. da Solicitacao                                  ³±±
±±³          ³ExpC3 - No. da Cotacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function aTipVeiSolCF(cFilOri,cNumSol,cNumCot)

Local cSeek     := ''
Local cWhile    := "DVT->(DVT_FILIAL+DVT_FILORI+DVT_NUMSOL+DVT_NUMCOT+DVT_ORIGEM)"

If !Empty(M->DTC_FILCFS)
	cSeek:=TMSA050CFS("DVT",M->DTC_FILCFS)+M->DTC_FILCFS+cNumSol+cNumCot+StrZero(1,Len(DVT->DVT_ORIGEM))
Else
	cSeek:=xFilial("DVT")+cFilOri+cNumSol+cNumCot+StrZero(1,Len(DVT->DVT_ORIGEM))
EndIf

aCols   := {}
aHeader := {}
Inclui := .F.

//--Passamos 4 no nOpcx senao a FillgetDados traz apenas um registro entendendo que e inclusao
FillGetDados(/*nOpcAnt*/4,"DVT",1,cSeek,{|| &cWhile},{||.T.},,{"DVT_ITEM","DVT_TIPVEI","DVT_DESVEI","DVT_QTDVEI","DVT_ALI_WT","DVT_REC_WT"} ,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)

//--Preenhe o Item
aCols[1][Ascan(aHeader,{|x| AllTrim(x[2]) == "DVT_ITEM"})] := StrZero(1,Len(DVT->DVT_ITEM))

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050AtuDVU³ Autor ³Patricia A. Salomao    ³ Data ³29.11.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava / Exclui Arquivo DVU (Tipos de Veiculo da Nota Fiscal)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A050AtuDVU()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Opcao Selecionada                                   ³±±
±±³          ³ExpC2 - Filial de Origem                                    ³±±
±±³          ³ExpC3 - No. da Nota Fiscal                                  ³±±
±±³          ³ExpC4 - Serie da Nota Fiscal                                ³±±
±±³          ³ExpC5 - Cliente Remetente                                   ³±±
±±³          ³ExpC6 - Loja Cliente Remetente                              ³±±
±±³          ³ExpC8 - Acao : 1=Inclusao / 2=Exclusao                      ³±±
±±³          ³ExpC9 - Numero do Lote                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Os Arrays aHeaderDVU e aColsDVU ja deverao estar preenchidos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a050AtuDVU(cFilOri, cNumNFC, cSerNFC, cCliRem, cLojRem, cAcao, aColsDTC, nPosDTC, nOpcx, cLotDTC)

Local nPosItem    := 0
Local nY          := 0
Local nX          := 0
Local nCntFor     := 0
Local cSeek       := ''
Local cSeekDVU    := ''
Local cWhileDVU   := ''
Local nPosNota    := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NUMNFC"})
Local nPosSerie   := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_SERNFC"})
Local aRestCols   := {}
Local aRestHeader := {}
Local lAltera     := .F.
Local nOrder      := 1
Local lGravaDVU   := .T.
Local lTM050DVU   := ExistBlock("TM050DVU")

Default cFilOri := ''
Default cNumNFC := ''
Default cSerNFC := ''
Default cCliRem := ''
Default cLojRem := ''
Default cAcao   := '1'
Default cLotDTC := ''

aRestCols := aClone(aCols)
aRestHeader := aClone(aHeader)

//Caso seja alteracao, monta aHeaderDVU
If nOpcx == 4
	nOrder    := 2
	cWhileDVU := "DVU->(DVU_FILIAL+DVU_FILORI+DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM)"
	cSeekDVU  := TMSA050CFS("DVU",M->DTC_FILCFS)+IIf(Empty(M->DTC_FILCFS),M->DTC_FILCFS,M->DTC_FILORI)+M->DTC_LOTNFC+aCols[1,nPosNota]+aCols[1,nPosSerie]+M->DTC_CLIREM+M->DTC_LOJREM+StrZero(1,Len(DVU->DVU_ITEM))
	aHeader := {}
	FillGetDados(nOpcx,"DVU",1,cSeekDVU,{|| &cWhileDVU },{||.T.},/*aNoFields*/{"DVU_LOTNFC"},/*aYesFields*/{"DVU_ITEM","DVU_TIPVEI","DVU_DESVEI","DVU_QTDVEI","DVU_ALI_WT","DVU_REC_WT"},/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)
	aHeaderDVU := aHeader
	aCols := aRestCols
	aHeader := aRestHeader
EndIf

nX := Ascan(aColsDVU,{|x| x[1] == aCols[nPosDTC][nPosNota]+aCols[nPosDTC][nPosSerie]+DTC->(DTC_CLIREM+DTC_LOJREM)}) //-- Verifica se foi informado Peso Cubado para a Nota

If TMSCFec()
	If cAcao == '1' //-- Inclusao

		If nX > 0

			nPosItem := Ascan(aHeaderDVU, {|x| AllTrim(x[2]) == 'DVU_ITEM' } )
			nCntFor  := Ascan(aColsDVU, {|x| x[1] == cNumNFC+cSerNFC+cCliRem+cLojRem })

			If nCntFor > 0 .And. nPosItem > 0
				For nX := 1 To Len(aColsDVU[nCntFor][2])
					lGravaDVU := .T.
					If !aColsDVU[nCntFor][2][nX][Len(aColsDVU[nCntFor][2][nX])] //-- Se a linha nao estiver deletada
						lAltera:= .F.
						DVU->(dbSetOrder(nOrder))
						If nOpcx == 4 .And. nOrder == 1
							If nPosDTC <= Len(aColsDTC) .And. DVU->(MsSeek(xFilial("DVU")+cFilOri+aColsDTC[nPosDTC][nPosNota]+aCols[nPosDTC][nPosSerie]+cCliRem+cLojRem+aColsDVU[nCntFor][2][nX][nPosItem]))
								lAltera:= .T.
							EndIf
						ElseIf nOrder == 2
							lAltera:= DVU->(MsSeek(xFilial("DVU") + cFilOri + cLotDTC + cNumNFC + cSerNFC + cCliRem + cLojRem + aColsDVU[nCntFor][2][nX][nPosItem]))
						Else
							lAltera:= DVU->(MsSeek(xFilial("DVU") + cFilOri + cNumNFC + cSerNFC + cCliRem + cLojRem + aColsDVU[nCntFor][2][nX][nPosItem]))
						EndIf

						If lCopiar
							lAltera := .F.
						EndIf
						For nY:= 1 To Len(aHeaderDVU)     //-- Evitar gravação quando há registros vazios (Opção - Copiar)
							If Empty(aColsDVU[nCntFor][2][nX][nY]) .And. nY < 5 //-- Recno
								lGravaDVU := .F.
								Exit
							EndIf
						Next

						If lGravaDVU
							If lAltera
								RecLock("DVU", .F.)
							Else
								RecLock("DVU", .T.)
							EndIf

							For nY:= 1 To Len(aHeaderDVU)
								If aHeaderDVU[nY][10] # "V"
									DVU->(FieldPut(FieldPos(Trim(aHeaderDVU[nY][2])),aColsDVU[nCntFor][2][nX][nY]))
								EndIf
							Next
							DVU->DVU_FILIAL := xFilial('DVU')
							DVU->DVU_FILORI := cFilOri
							DVU->DVU_NUMNFC := cNumNFC
							DVU->DVU_SERNFC := cSerNFC
							DVU->DVU_CLIREM := cCliRem
							DVU->DVU_LOJREM := cLojRem
							DVU->DVU_LOTNFC := cLotDTC
							DVU->(MsUnLock())
						EndIf
					ElseIf nOpcx == 4
						dbSelectArea("DVU")
						dbSetOrder(1)
						If DVU->(MsSeek(xFilial("DVU")+cFilOri+aColsDTC[nPosDTC][nPosNota]+aColsDTC[nPosDTC][nPosSerie]+cCliRem+cLojRem+aColsDVU[nCntFor][2][nX][nPosItem]))
							RecLock("DVU", .F.)
							dbDelete()
							DVU->(MsUnLock())
						EndIf
					EndIf
					If lTM050DVU
						ExecBlock("TM050DVU",.F.,.F.,{nX})
					EndIf
				Next
				//-- Excluir veiculo processado
				aColsDVU[nCntFor][2] := {}
			EndIf
		EndIf
	ElseIf cAcao != '1'      //-- Deletar por busca com Lote
		DVU->(dbSetOrder(2))
		DVU->(MsSeek(cSeek:=xFilial('DVU')+ cFilOri+cLotDTC+cNumNFC+cSerNFC+cCliRem+cLojRem))
		Do While !DVU->(Eof()) .And. DVU->(DVU_FILIAL+DVU_FILORI+DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM) == cSeek
			RecLock("DVU", .F.)
			dbDelete()
			DVU->(MsUnLock())
			DVU->(dbSkip())
		EndDo
	Else
		DVU->(dbSetOrder(1))
		DVU->(MsSeek(cSeek:=xFilial('DVU')+ cFilOri+cNumNFC+cSerNFC+cCliRem+cLojRem))
		Do While !DVU->(Eof()) .And. DVU->(DVU_FILIAL+DVU_FILORI+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM) == cSeek
			RecLock("DVU", .F.)
			dbDelete()
			DVU->(MsUnLock())
			DVU->(dbSkip())
		EndDo
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A050ValInf³ Autor ³ Eduardo de Souza      ³ Data ³ 31/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valor Informado da nota fiscal / cotacao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050ValInf(ExpN1,ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpC1 - Nota Fiscal                                        ³±±
±±³          ³ ExpC2 - Serie                                              ³±±
±±³          ³ ExpC3 - Produto                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050ValInf(nOpcx,cNumNfc,cSerNfc,cCodPro)

Local nCnt      := 0
Local aTabFre   := {}
Local cTabFre   := ''
Local cTipTab   := ''
Local lContinua := .T.
Local cFilOri   := M->DTC_FILORI

If Empty(cNumNfc) .Or. Empty(cCodPro)
	Help("",1,"TMSA05066") //Para apresentar o valor informado, devera ser digitada a nota fiscal e o produto
Else

	//-- Na inclusao, verifica se existe valor informado na cotacao.
	If nOpcx == 3
		If !Empty(M->DTC_NUMCOT) .And. Empty(aValInf)
			If !Empty(M->DTC_FILCFS)
				cFilOri := M->DTC_FILCFS
			EndIf
			TmsValInf(aValInf,'3',cFilOri,M->DTC_NUMCOT,,,,,,,,,,nOpcx,,,,,M->DTC_CODNEG)
			For nCnt := 1 To Len(aValInf)
				//-- Atualiza a nota fiscal do valor informado para o produto atual.
				If aValInf[nCnt,6] == cCodPro
					aValInf[nCnt,4] := cNumNfc
					aValInf[nCnt,5] := cSerNfc
				Else
					//-- Inicializa deletado o valor informado de outros produtos.
					//-- Qdo executar a rotina para o produto referente ao valor informado o mesmo sera reativado.
					aValInf[nCnt,3] := .T.
				EndIf
			Next nCnt
		Else
			For nCnt := 1 To Len(aValInf)
				//-- Atualiza a nota fiscal do valor informado para o produto atual.
				If	aValInf[nCnt,6] == cCodPro .And. aValInf[nCnt,4] <> cNumNfc .And. aValInf[nCnt,5] <> cSerNfc
					aValInf[nCnt,4] := cNumNfc
					aValInf[nCnt,5] := cSerNfc
					aValInf[nCnt,3] := .F.
				EndIf
			Next nCnt
		EndIf
	EndIf

	//-- Pesquisa a tabela de frete do cliente
	If (nOpcx == 3 .Or. nOpcx == 4)
		lContinua := .F.
		aTabFre := TmsTabFre(M->DTC_CLICAL,M->DTC_LOJCAL,M->DTC_SERVIC,M->DTC_TIPFRE,M->DTC_CODNEG)
		If !Empty(aTabFre)
			cTabFre   := aTabFre[1]
			cTipTab   := aTabFre[2]
			lContinua := .T.
		EndIf

		If !lContinua .And. (Empty(cTabFre) .Or. Empty(cTipTab))
			If MsgYesNo( STR0067 ) //"Tabela de Frete não localizada, deseja apresentar todos componentes do tipo valor informado ?"
				lContinua := .T.
			EndIf
		EndIf
	EndIf

	//-- Valor Informado da nota fiscal
	If lContinua
		TmsValInf(aValInf,'2',M->DTC_FILORI,,M->DTC_LOTNFC,M->DTC_CLIREM,M->DTC_LOJREM,M->DTC_CLIDES,M->DTC_LOJDES,M->DTC_SERVIC,cNumNfc,cSerNfc,cCodPro,nOpcx,,cTabFre,cTipTab,,M->DTC_CODNEG)
	EndIf

EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Doc³ Autor ³ Eduardo de Souza      ³ Data ³ 18/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Visualizacao do Docto atraves da Nota Fiscal       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Doc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA050Doc(cCodPro,cNumNfc,cSerNfc)

Local aAreaDTC := DTC->(GetArea())
Local aAreaDT6 := DT6->(GetArea())

//-- Salva Area
SaveInter()

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

DTC->(DbSetOrder(1))
If DTC->(MsSeek(xFilial("DTC")+M->DTC_FILORI+M->DTC_LOTNFC+M->DTC_CLIREM+M->DTC_LOJREM+M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SERVIC+cCodPro+cNumNfc+cSerNfc)) .And. ;
	!Empty(DTC->DTC_FILDOC) .And. !Empty(DTC->DTC_DOC) .And. !Empty(DTC->DTC_SERIE)
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+DTC->DTC_FILDOC+DTC->DTC_DOC+DTC->DTC_SERIE))
		cCadastro := STR0066 //"Manutencao de Documentos - Visualizar"
		TMSA500Mnt("DT6",DT6->(Recno()),2)
	EndIf
EndIf

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)
RestInter() //-- Restaura Area
RestArea( aAreaDTC )
RestArea( aAreaDT6 )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050SX3³ Autor ³ Valdemar Roberto      ³ Data ³ 30/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a chamada do CHECKSX3                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050SX3()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA050SX3()

__readvar := "M->DTC_CLIREM"
CheckSX3("DTC_CLIREM",M->DTC_CLIREM)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A050ApoCol³ Autor ³ Gilson da Silva          ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Determina o Codigo de Ocorrencia para Apontamento da  Coleta. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050ApoCol()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050ApoCol()

Local aArea     := GetArea()
Local aOcorCol  := {}   //Vetor com as Ocorrencias contidas no parametro MV_OCORCOL
Local aCopOcor  := {}   //Vetor com todas as linhas do vetor aocorCol contendo o "Tipo de Ocorrencia", isto por causa do limite da função TMSABROWSE que nao comporta mais de 3 colunas.
Local cVar      := ""   //Variavel com o Tipo de Ocorrência contida no parametro MV_OCORCOL
Local nCnt      := 0
Local lRet      := .F.
Local cOcor     := GetMV("MV_OCORCOL")   //Armazena a(s) ocorrencia(s) contida(s) no parametro MV_OCORCOL, para apontamento da coleta.
Local cSerTms		:= ""
Local lAchou		:= .F.

//Preenche o vetor aOcorCol com as ocorrencias contidas no parametro MV_OCORCOL separadas por '/', cujo
//tipo de servico seja igual a coleta e o tipo da ocorrencia seja "Encerra Processo" ou "Cancelamento"
//(DT2_TIPOCO igual a '01' ou DT2_TIPOCO igual a  '12').
For nCnt:=1 To Len(cOcor)
	If !(Subs(cOcor,nCnt,1)=="/") .And. nCnt!= Len(cOcor)
		cVar+= Subs(cOcor,nCnt,1)
	Else
		If nCnt==Len(cOcor)
			cVar+=Subs(cOcor,nCnt,1)
		EndIf
		DT2->(dbSetOrder(1))
		If DT2->(MsSeek(xFilial("DT2") + cVar))
			If !Empty(DT2->DT2_SERTMS)
				If DT2->DT2_SERTMS == '1'  .And. (DT2->DT2_TIPOCO == '01' .Or. DT2->DT2_TIPOCO == '12')
					AAdd(aOcorCol, {.F., DT2->DT2_CODOCO, DT2->DT2_DESCRI})
					AAdd(aCopOcor, {DT2->DT2_TIPOCO})
				EndIf
			Else
				//O serviço adicional permite DT2_SERTMS em branco
				DbSelectArea("DT6")
				DbSetOrder(1) //Filial+Fil.Doc+Num.Doc+Serie Doc
				If MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE)
					cSerTms := DT6->DT6_SERTMS
					lAchou := .T.
				Endif
				If lAchou .AND. cSerTms == '1'  .And. (DT2->DT2_TIPOCO == '01' .Or. DT2->DT2_TIPOCO == '12')
					AAdd(aOcorCol, {.F., DT2->DT2_CODOCO, DT2->DT2_DESCRI})
					AAdd(aCopOcor, {DT2->DT2_TIPOCO})
				Endif
			Endif
		EndIf
		cVar:=""
	EndIf
Next

//Se exitir mais de um tipo de ocorrencia, monta o listbox para o usuario selecionar a ocorrencia desejada.
If Len(aOcorCol) > 1
	If TMSABrowse(aOcorCol, STR0069,,,,.T., {STR0070, STR0060}) //"Selecione a Ocorrência"###"Cod. Ocorrencia"###"Descricao"
		For nCnt := 1 To Len(aOcorCol)
			If aOcorCol[nCnt, 1]
				// Se o tipo de ocorrencia for "Cancelamento", Gatilha automaticamente a Data e Hora da coleta como data e hora da entrega.
				If aCopOcor[nCnt, 1] == '12' //Verifica se o Tipo da Ocorrencia eh "Cancelamento" no vetor aCopOcor.
					M->DTC_DTENTR  := M->DTC_DATCOL
					M->DTC_HORENT  := M->DTC_HORCOL
				EndIf
				cOcorCol := aOcorCol[nCnt,2]
				lRet := .T.
				Exit
			EndIf
		Next
	EndIf
ElseIf Len(aOcorCol) == 1
	cOcorCol := aOcorCol[1,2]
	lRet := .T.
	If aCopOcor[1, 1] == '12' //Verifica se o Tipo da Ocorrencia eh "Cancelamento" no vetor aCopOcor.
		M->DTC_DTENTR  := M->DTC_DATCOL
		M->DTC_HORENT  := M->DTC_HORCOL
	EndIf
Else
	Help("",1,"TMSA05067")  //-- "Não encontrado ocorrência do tipo, "'Encerra processo' ou 'Cancelamento' ","no parâmetro MV_OCORCOL.","Separe com '/', os codigos de ocorrência ","informados no parâmetro MV_OCORCOL."
	lRet := .F.
EndIf

RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050bLin   ³ Autor ³ Gilson da Silva      ³ Data ³ 21/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine do Docto.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050bLin(ExpN1,ExpA1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±³          ³ ExpA1 - Lista de Itens                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050bLin(nAt,aItens)

Local nX        := 0
Local abLine    := {}
Local oNoMarked := LoadBitmap( GetResources(),'LBNO' )
Local oMarked   := LoadBitmap( GetResources(),'LBOK' )

If Len(aItens) > 0
	AAdd( abLine, Iif(aItens[nAt,1], oMarked, oNoMarked ) )
	For nX := 2 To Len(aItens[nAt])
		AAdd( abLine, aItens[nAt,nX])
	Next
EndIf

Return( abLine )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TM050ValNF³ Autor ³ Eduardo de Souza         ³ Data ³ 21/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna valors ja digitados para o lote                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM050ValNF()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Volumes                                               ³±±
±±³          ³ ExpN2 - Peso                                                  ³±±
±±³          ³ ExpN3 - Valor                                                 ³±±
±±³          ³ ExpN4 - Peso Cubado                                           ³±±
±±³          ³ ExpN5 - Metro Cubico                                          ³±±
±±³          ³ ExpN6 - Kilometragem                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TM050ValNF(nTotVolNF,nTotPesNF,nTotValNF,nTotPM3NF,nTotPMt3NF,nKmNF,cFilOri,cLotNfc)

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()

cQuery := " SELECT SUM(DTC_QTDVOL) QTDVOL, SUM(DTC_PESO) PESO, SUM(DTC_VALOR) VALOR, SUM(DTC_PESOM3) PESOM3, SUM(DTC_METRO3) METRO3 "
cQuery += ", SUM(DTC_KM) KM "
cQuery += "		FROM " + RetSqlName("DTC")
cQuery += "		WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "			AND DTC_FILORI = '" + cFilOri + "' "
cQuery += "			AND DTC_LOTNFC = '" + cLotNfc + "' "
cQuery += "			AND D_E_L_E_T_ =  ' ' "
cQuery += "	GROUP BY DTC_FILIAL, DTC_FILORI, DTC_LOTNFC "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

TCSetField(cAliasQry,"QTDVOL","N",TamSx3("DTC_QTDVOL")[1],TamSx3("DTC_QTDVOL")[2])
TCSetField(cAliasQry,"PESO"  ,"N",TamSx3("DTC_PESO"  )[1],TamSx3("DTC_PESO"  )[2])
TCSetField(cAliasQry,"VALOR" ,"N",TamSx3("DTC_VALOR" )[1],TamSx3("DTC_VALOR" )[2])
TCSetField(cAliasQry,"PESOM3","N",TamSx3("DTC_PESOM3")[1],TamSx3("DTC_PESOM3")[2])
TCSetField(cAliasQry,"METRO3","N",TamSx3("DTC_METRO3")[1],TamSx3("DTC_METRO3")[2])
TCSetField(cAliasQry,"KM"    ,"N",TamSx3("DTC_KM"    )[1],TamSx3("DTC_KM"    )[2])

nTotVolNF  += (cAliasQry)->QTDVOL
nTotPesNF  += (cAliasQry)->PESO
nTotValNF  += (cAliasQry)->VALOR
nTotPM3NF  += (cAliasQry)->PESOM3
nTotPMt3NF += (cAliasQry)->METRO3
nKmNF      += (cAliasQry)->KM

(cAliasQry)->(DbCloseArea())
RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA050Inc    ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere Incoterms                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA050Inc()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA050Inc()
If M->DTC_TIPTRA == StrZero(4,Len(DTC->DTC_TIPTRA))
	If M->DTC_TIPFRE == StrZero(1,Len(DTC->DTC_TIPFRE))
		M->DTC_INCOTE := "CIF"
	Else
		M->DTC_INCOTE := "FOB"
	EndIf
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA050Ini    ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador de campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA050Ini(cCampo)                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA050Ini(cCampo)
Local aAreaSav := GetArea()
Local aAreaDI3 := {}
Local xRet     := ""
Local cPais    := ""

Default cCampo := ""

If cCampo == "M->DTC_DOCANE"
	aAreaDI3 := DI3->(GetArea())
	cPais := Posicione('DUY',1,xFilial('DUY')+GetMv('MV_CDRORI',,''),'DUY_PAIS')
	DI3->(dbSetOrder(1))
	If DI3->(dbSeek(xFilial('DI3')+cPais))
		xRet := MSMM(DI3->DI3_CODDCA,80)
	EndIf
	RestArea(aAreaDI3)
ElseIf cCampo == "DTC_INSREM"
	xRet := IIF(Inclui,"",IIF(Empty(DTC->DTC_SQIREM),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLIREM+DTC_LOJREM),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLIREM+DTC_LOJREM+DTC_SQIREM),"DV3_INSCR")))
ElseIf cCampo == "DTC_INSDES"
	xRet := IIF(Inclui,"",IIF(Empty(DTC->DTC_SQIDES),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLIDES+DTC_LOJDES),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLIDES+DTC_LOJDES+DTC_SQIDES),"DV3_INSCR")))
ElseIf cCampo == "DTC_INSCON"
	xRet := IIF(Inclui,"",IIF(Empty(DTC->DTC_SQICON),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLICON+DTC_LOJCON),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLICON+DTC_LOJCON+DTC_SQICON),"DV3_INSCR")))
ElseIf cCampo == "DTC_INSDPC"
	xRet := IIF(Inclui,"",IIF(Empty(DTC->DTC_SQIDPC),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLIDPC+DTC_LOJDPC),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLIDPC+DTC_LOJDPC+DTC_SQIDPC),"DV3_INSCR")))
EndIf

RestArea(aAreaSav)
Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Local lRTMSR01 := ExistBlock("RTMSR01")
Local lTMSCTe  := SuperGetMv( "MV_TMSCTE", .F., .F. ) //-- Parametro do CT-e ativo.
Local aOpcMenu := {}
Local aOpcCalc := {}
// - Controle de Versao
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus

Private aRotina := {}

If Type("lRETCDTC") == "U"
	lRETCDTC := .F.
EndIf

If (nVersao == 11 .And. lR5) .Or. nVersao > 11

	If (lTMSCTe)
		If lRTMSR01
			AADD(aOpcMenu, { STR0102, 'TMSA200Imp' ,0 ,2}) //-- "CTR"
			If FindFunction("TmsVerCTe")
				AADD(aOpcMenu, { STR0103, 'TmsVerCTe'  ,0 ,2}) //-- "DACTE"
			Else
				AADD(aOpcMenu, { STR0103, 'U_RTMSR27'  ,0 ,2}) //-- "DACTE"
			EndIf
			AADD(aOpcMenu, { STR0104, 'TMSR625'    ,0 ,2}) //-- "LOG REJ"

			aOpcCalc	:= {	{ STR0093	 ,'TMSA050Sub( 6 )',0,2} ,; //"Fechar Lote"
								{ STR0094 	 ,'TMSA050Sub( 1 )',0,2} ,; //"Calcular"
								{ STR0095 	 ,'TMSA050Sub( 2 )',0,2} ,; //"Estornar"
								{ STR0096	 ,'TMSA050Sub( 3 )',0,2} ,; //"Recalculo"
								{ STR0097	 ,'TMSA050Sub( 4 )',0,2} ,; //"Cons.Doc"
								{ STR0098 	 ,'TMSA050Sub( 5 )',0,2} ,; //"Refaturar"
								{ STR0099	 , aOpcMenu   ,0,6,0,NIL},; //"Impressao"
								{ STR0100 	 ,'TMSA170Leg',0,4,0,.F.},; //"Legenda"
								{ STR0101 	 ,'TMSAE70(1)' ,0,2}}			// 'Ct-e'
		Else

			aOpcCalc	:= {	{ STR0093	 ,'TMSA050Sub( 6 )' ,0,2},; //"Fechar Lote"
								{ STR0094	 ,'TMSA050Sub( 1 )' ,0,2},; //"Calcular"
								{ STR0095 	 ,'TMSA050Sub( 2 )' ,0,2},; //"Estornar"
								{ STR0096 	 ,'TMSA050Sub( 3 )' ,0,2},; //"Recalculo"
								{ STR0097 	 ,'TMSA050Sub( 4 )' ,0,2},; //"Cons.Doc"
								{ STR0098 	 ,'TMSA050Sub( 5 )' ,0,2},; //"Refaturar"
								{ STR0100 	 ,'TMSA170Leg',0,4,0,.F.},; //"Legenda"
								{ STR0101 	 ,'TMSAE70(1)' ,0,2}}			// 'Ct-e'
		EndIf
	Else
		If lRTMSR01


			aOpcCalc	:= {	{ STR0093    ,'TMSA050Sub( 6 )' ,0,2},; //"Fechar Lote"
								{ STR0094	 ,'TMSA050Sub( 1 )' ,0,2},; //"Calcular"
								{ STR0095 	 ,'TMSA050Sub( 2 )' ,0,2},; //"Estornar"
								{ STR0096    ,'TMSA050Sub( 3 )' ,0,2},; //"Recalculo"
								{ STR0097	 ,'TMSA050Sub( 4 )' ,0,2},; //"Cons.Doc"
								{ STR0098 	 ,'TMSA050Sub( 5 )' ,0,2},; //"Refaturar"
								{ STR0099 	 ,'TMSA200Imp',0,6,0,NIL},; //"Impressao"
								{ STR0100	 ,'TMSA170Leg',0,4,0,.F.}}
		Else

			aOpcCalc	:= {	{ STR0093	 ,'TMSA050Sub( 6 )' ,0,2},; //"Fechar Lote"
								{ STR0094 	 ,'TMSA050Sub( 1 )' ,0,2},; //"Calcular"
								{ STR0095 	 ,'TMSA050Sub( 2 )' ,0,2},; //"Estornar"
								{ STR0096    ,'TMSA050Sub( 3 )' ,0,2},; //"Recalculo"
								{ STR0097	 ,'TMSA050Sub( 4 )' ,0,2},; //"Cons.Doc"
								{ STR0098 	 ,'TMSA050Sub( 5 )' ,0,2},; //"Refaturar"
								{ STR0100	 ,'TMSA170Leg',0,4,0,.F.}}
		EndIf
	EndIf

	AAdd(aOpcCalc, { STR0114, 'TMSA200A'    ,0 ,2})	// ''Selecionar Lotes'

	If lRETCDTC 
	aRotina	:= {	{STR0002 ,"AxPesqui"  ,0,1,0,.F.},; //"Pesquisar"
					{STR0003 ,"TMSA050Mnt",0,2,0,Nil},; //"Visualizar"
					{STR0004 ,"TMSA050Mnt",0,3,0,Nil},; //"Incluir"
					{STR0005 ,"TMSA050Mnt",0,4,0,Nil},; //"Alterar"
					{STR0031 ,"TMSA050Mnt",0,6,0,NIL},; //"Copiar"
					{STR0006 ,"TMSA050Mnt",0,5,0,NIL},; //"Excluir"
					{STR0107 ,aOpcCalc    ,0,7,0,nil},; //"Calculo Frete"
					{STR0171 ,"TMSA050Mnt",0,3,0,Nil} } //8-"Inclusao Redesp.Inter."
	Else
		aRotina	:= {	{STR0002 ,"AxPesqui"  ,0,1,0,.F.},; //"Pesquisar"
						{STR0003 ,"TMSA050Mnt",0,2,0,Nil},; //"Visualizar"
						{STR0004 ,"TMSA050Mnt",0,3,0,Nil},; //"Incluir"
						{STR0005 ,"TMSA050Mnt",0,4,0,Nil},; //"Alterar"
						{STR0031 ,"TMSA050Mnt",0,6,0,NIL},; //"Copiar"
						{STR0006 ,"TMSA050Mnt",0,5,0,NIL},; //"Excluir"
						{STR0107 ,aOpcCalc    ,0,7,0,nil} } //"Calculo Frete"
						
	Endif					
		
Else

	aRotina	:= {	{STR0002 ,"AxPesqui"  ,0,1,0,.F.},; //"Pesquisar"
					{STR0003 ,"TMSA050Mnt",0,2,0,Nil},; //"Visualizar"
					{STR0004 ,"TMSA050Mnt",0,3,0,Nil},; //"Incluir"
					{STR0005 ,"TMSA050Mnt",0,4,0,Nil},; //"Alterar"
					{STR0031 ,"TMSA050Mnt",0,6,0,NIL},; //"Copiar"
					{STR0006 ,"TMSA050Mnt",0,5,0,NIL} } //"Excluir"

EndIf



If ExistBlock("TMA050MN")
	ExecBlock("TMA050MN",.F.,.F.)
EndIf

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |A050EfeAlt³ Autor ³ Raphael Zampieri      ³ Data ³ 04/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se permite alteracao para o lote                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050EfeAlt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050EfeAlt()
Local lRet := .T.
Local cTes := GetMV("MV_TESDR",,"")
Local cAliasDTC := GetNextAlias()
Local cQuery    := ""
Local aAreaDTC  := DTC->(GetArea())

dbSelectArea("SF4")
SF4->(DbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+cTes))
If SF4->F4_ESTOQUE == "S"
	Help("",1,"TMSA05077")    //-- Apenas Lotes com status aberto ou digitado, podem ser alterados.
	lRet := .F.
EndIf

dbSelectArea("DTP")
DTP->(DbSetOrder(2))
DTP->(DbSeek(xFilial("DTP")+DTC->(DTC_FILORI+DTC_LOTNFC)))
If DTP->DTP_STATUS <> '1' .And. DTP->DTP_STATUS <> '2'
	Help("",1,"TMSA05076")    //-- Apenas Lotes com status aberto ou digitado, podem ser alterados.
	lRet := .F.
EndIf

If lRet .And. !Empty(DTC->DTC_VLRINF)
	lRet := Aviso(STR0009,STR0089,{STR0024,STR0025},2,'')==1 //"Atencao" ### "Este lote possui valor de Frete Informado. A alteração deste lote irá implicar no cancelamento da cotação de frete, deseja continuar?" ### "Sim" ### "Nao"

	If lRet
		//Cancela cotacao
		TmsA040Can(DTC->DTC_FILORI,DTC->DTC_NUMCOT,dDataBase)

		//Limpa campos
		cAliasDTC := GetNextAlias()
		cQuery := "SELECT R_E_C_N_O_ RECNO "
		cQuery += " FROM "+RetSqlName("DTC")+ " DTC "
		cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "'"
		cQuery += "   AND DTC_FILORI = '" + DTC->DTC_FILORI + "'"
		cQuery += "   AND DTC_NUMCOT = '" + DTC->DTC_NUMCOT + "'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

		While (cAliasDTC)->(!Eof())
			DTC->(MsGoto((cAliasDTC)->RECNO))
			RecLock("DTC",.F.)
			DTC->DTC_VLRINF := 0
			DTC->DTC_NUMCOT := ''
			MsUnlock()
			(cAliasDTC)->(DbSkip())
		EndDo
		(cAliasDTC)->(dbCloseArea())
	EndIf
EndIf

RestArea( aAreaDTC )

Return( lRet )

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exemplo de Inclusao do MsExecAuto³
//@type User Function
//@author Marlon Augusto Heiber
//@version 12
//@since 17/01/2018
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function ExAut050()

Local aCabDTC  := {}
Local aItemDTC := {}
Local aItemEnd := {}
Local aItemCub := {}
Local aItem    := {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

// Dados da Nota Fiscal
aCabDTC:= {{"DTC_FILORI" ,"04"			 , Nil},; //Filial de Origem
       	 {"DTC_LOTNFC" ,"12345"  	 , Nil},; //Número Lote
       	 {"DTC_DATENT" ,dDataBase    , Nil},; //Data da Entrada
       	 {"DTC_CLIREM" ,"SP0001"   	 , Nil},; //Cod. Remetente
	        {"DTC_LOJREM" ,"01"       	 , Nil},; //Loja Remetente
     		 {"DTC_CLIDES" ,"SP0002"   	 , Nil},; //Cod. Destinatário
       	 {"DTC_LOJDES" ,"01"  		 , Nil},; //Loja Destinatário
       	 {"DTC_DEVFRE" ,"1"     		 , Nil},; //Devedor do Frete - 1=Remetente;2=Destinatario;3=Consignatario;4=Despachante
      		 {"DTC_CLIDEV" ,"SP0001" 	 , Nil},; //Devedor - Cliente Devedor do Frete
       	 {"DTC_LOJDEV" ,"01"		 	 , Nil},; //Loja Devedor - Loja Cliente Devedor do Frete
       	 {"DTC_CLICAL" ,"SP0001" 	 , Nil},; //Cliente para Calculo
       	 {"DTC_LOJCAL" ,"01"       	 , Nil},; //Loja Cliente para Calculo
       	 {"DTC_TIPFRE" ,"1"    		 , Nil},; //Tipo do Frete - 1=CIF;2=FOB
       	 {"DTC_SERTMS" ,"3"          , Nil},; //Servico de Transporte - 1=Rodoviario / 2=Aereo / 3=Fluvial.
       	 {"DTC_TIPTRA" ,"1" 			 , Nil},; //Tipo Transporte
       	 {"DTC_SERVIC" ,"015"        , Nil},; //Serviço
       	 {"DTC_TIPNFC" ,"0"          , Nil},; //Tipo Nf Cli. - 0=Normal;1=Devolucao;2=SubContratacao;3=Nao Fiscal;4=Exportacao;5=Redesp;6=Nao Fiscal 1;7=Nao Fiscal 2;8=Serv Vincul.Multimodal
       	 {"DTC_CDRORI" ,"2GUARU"     , Nil},; //Cod.Regiao Origem
       	 {"DTC_CDRDES" ,"2RGUA"      , Nil},; //Cod.Regiao Destino
       	 {"DTC_CDRCAL" ,"2RGUA "     , Nil},; //Cod.Regiao Calculo
       	 {"DTC_NCONTR" ,"000000000000014"     , Nil},;  //Número do Contrato do Cliente.
       	 {"DTC_CODNEG" ,"01"	        , Nil},;  //Código da Negociação do Contrato do Cliente.
       	 {"DTC_DOCTMS" ,"2"	        , Nil},;  //Documento de Transporte
       	 {"DTC_SELORI" ,"1"          , Nil}}  //Seleciona Origem - 1=Transportadora;2=Cliente Remetente;3=Local Coleta

// Itens da NF
Aadd(aItemDTC,{ {"DTC_FILORI" ,"04"       , Nil},; //Filial de Origem
         		  {"DTC_LOTNFC" ,"12345"    , Nil},; //Número Lote
      			  {"DTC_NUMNFC" ,"12345" 	, Nil},; //Doc.Cliente
        		  {"DTC_SERNFC" ,"329"      , Nil},; //Serie Docto. Cliente
        		  {"DTC_CODPRO" ,"P01   "   , Nil},; //Codigo do Produto
 				  {"DTC_CODEMB" ,"CX"  		, Nil},; //Codigo da Embalagem
        		  {"DTC_EMINFC" ,dDataBase  , Nil},; //Dt.Emissao Nf Cliente
        		  {"DTC_QTDVOL" ,2	       , Nil},; //Quantidade de Volumes da Nota Fiscal do Cliente
        		  {"DTC_PESO"   ,1	       , Nil},; //Peso da Nota Fiscal do Cliente.
                {"DTC_VALOR"  ,1          , Nil},; //Valor da Nota Fiscal do Cliente
        		  {"DTC_CF"	  ,5932 		, Nil},; //CFOP
       	 	  {"DTC_USUAGD" ,__cUserID  , Nil},;  //Codigo do Usuario Responsável pelo Agendamento de Entrega
       	 	  {"DTC_DOCREE" ,"2"	       , Nil},;  //Documento de Transporte
       	 	  {"DTC_PRVENT" ,dDataBase+1, Nil},;  //Hora Previsao de Entrega
       	 	  {"DTC_NFENTR" ,"2"	       , Nil},;  //Nome Expedidor
        		  {"DTC_EDI"    ,'2'        , Nil}}) //Nota Fiscal do EDI Indica se a Nota Fiscal é de EDI (Electronic Data Interchange).

//Endereçamento de Notas Fiscais - DUH (Caso não utilizar Endereçamento, esta parte pode ser comentada no programa e a variável "aItemEnd" apagada do MSExecAuto.
Aadd(aItemEnd,{cLoteAuto+"   329P01            ",; //Numero da Nota + Serie + Produto
     			{{"01","END01          ",1,"000001","012345","1",,,},; //1 Array contendo o endereçamento (Local + Armazém + Quantidade + Unitizador Sintético + Cod Analitico Unitizador + Versao de Inclusao)
      		   	 {"01","END02          ",1,"000001","012345","1",,,}}})//2 Array contendo o endereçamento (Local + Armazém + Quantidade + Unitizador Sintético + Cod Analitico Unitizador + Versao de Inclusao)

//Peso Cubado - DTE (Caso não utilizar Peso Cubado, esta parte pode ser comentada no programa e a variável "aItemCub" apagada do MSExecAuto.
Aadd(aItemCub,{cLoteAuto+"   329P01            ",; //Numero da Nota + Serie + Produto
     			{{2,2,3,4,"DTE",,}}}) //1 Array contendo o Peso Cubado(Quantidade de Volumes + Altura + Largura + Comprimento )

/ Executa rotina TMSA050
MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,aItemCub,aItemEnd,3)

// Retorna Resultado do Processo
If lMsErroAuto
	MostraErro()
Else
	MsgInfo("Nota gravada com sucesso!")
EndIf
Return
*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS050Stlt    ³ Autor ³ Jefferson Tomaz      ³ Data ³23.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o status do lote cadastrado na tabela DTP              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS050Stlt(cFilOri, cLotNfc)
Local cRet		 := ""
Local lExclusivo := Iif(FWModeAccess ("DTP",3)=="E",.T.,.F.)

Default cFilOri := ""
Default cLotNfc := ""

DTP->(DbSetOrder(2))
If DTP->(MsSeek(Iif(lExclusivo,cFilOri,xFilial("DTP"))+cFilOri+cLotNfc))
	cRet := DTP->DTP_STATUS
EndIf
Return(cRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Sub    ³ Autor ³ Jefferson Tomaz      ³ Data ³23.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua chamadas para a rotina de calculo de frete              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSA050Sub(nOpc, cFilOri, cLotNfc)

Local aArea 	 := GetArea()
Local cOldFName  := FunName() //-- Utilizado para restaurar o FunName original, pois na chamada das rotinas atraves do submenu sera alterado.

Private aIndexSub  := {}
Private bFiltraSub := {}
Private cCadastro  := ""

Default cFilOri	:= DTC->DTC_FILORI
Default cLotNfc	:= DTC->DTC_LOTNFC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas do MBrowse Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("5",,,,,,,,,,,,"2",.T.,.T.,cLotNfc,,StrZero(ThreadId(),20))
	Return .F.
EndIf
DTP->(DbSetOrder(2))
If DTP->(MsSeek(xFilial("DTP")+cFilOri+cLotNfc))

	SetFunName("TMSA200")
	aRotina := { { "", "", 0, 1 },;
				 	 { "", "", 0, 2 },;
				 	 { "", "", 0, 3 },;
			 		 { "", "", 0, 4 },;
			 		 { "", "", 0, 5 },;
			 		 { "", "", 0, 6 }}

	Do Case
		Case nOpc == 1 .And. TmsAcesso(,"TMSA200" ,,2) //'Calcular'
			TmsA200Mnt("DTP", DTP->(RecNo()), 2)
		Case nOpc == 2 .And. TmsAcesso(,"TMSA200" ,,6) //'Estornar'
			TmsA200Est("DTP", DTP->(RecNo()), 6)
		Case nOpc == 3 .And. TmsAcesso(,"TMSA200" ,,6) //'Recalculo'
			TmsA200Rec("DTP", DTP->(RecNo()), 6)
		Case nOpc == 4 .And. TmsAcesso(,"TMSA200" ,,6) //'Cons.Doc'
			TmsA200Vis("DTP", DTP->(RecNo()), 6)
		Case nOpc == 5 .And. TmsAcesso(,"TMSA200" ,,5) //'Refaturar'
			TmsA200Mnt("DTP", DTP->(RecNo()), 5)
		Case nOpc == 6
			TMS050FLot(cFilOri, cLotNfc) //'Fechar lote'
	EndCase
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as Variaveis do MBrowse Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetFunName(cOldFName)
RestInter()
RestArea( aArea )

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf
Return  Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS050FLot ³ Autor ³Jefferson Tomaz       ³ Data ³ 23/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Localiza o lote e efetua o fechamento do mesmo              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS050FLot(cFilOri, cLotNfc)

Local   aAreaAtu   := GetArea()
Local	lViaCol	   := DTP->(ColumnPos("DTP_VIACOL")) > 0
Local   lFechaLote := .T.

Default cFilOri := DTP->DTP_FILORI
Default cLotNfc := DTP->DTP_LOTNFC

DTP->(DbSetOrder(2))
If DTP->(MsSeek(xFilial("DTP")+cFilOri+cLotNfc)) .And. DTP->DTP_QTDDIG > 0 .And. DTP->DTP_STATUS = '1'
	If lViaCol .And. !Empty(DTP->DTP_VIACOL) .And.  !IsInCallStack("TMSAF76")
		Help("",1,"TMSA050A9",,"") //-- Lote gerado pela rotina de Painel de Agendamentos. Seu fechamento não pode ocorrer por esta rotina.
        lFechaLote := .F.
	EndIf
	If lFechaLote
		If MsgYesNo(STR0106 + AllTrim(cLotNfc)+'?')
						RecLock('DTP',.F.)
						DTP->DTP_QTDLOT := DTP->DTP_QTDDIG
						DTP->DTP_STATUS := '2' //-- Digitado
						MsUnLock()
		EndIf
	EndIf
EndIf

RestArea(aAreaAtu)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS050Lot ³ Autor ³Jefferson Tomaz        ³ Data ³ 23/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Localiza lote em aberto por Filial                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS050Lot(cFilCfs, cNumSol, cNumLot, cCliDev, cLojDev)
Local aGetArea  := GetArea()
Local cRet      := ''
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cAliasDTP := GetNextAlias()
Local aItens    := {}
Local cCadastro := STR0105 //--Escolha o Lote
Local lCancel   := .T.
Local nRet      := 0
Local lTMSCTe   := SuperGetMv( "MV_TMSCTE", .F., .F. )
Local aCab		:= {}
Local lViaCol	   := DTP->(ColumnPos("DTP_VIACOL")) > 0
Local lCmpRatNew := DTP->(ColumnPos("DTP_CRDVFA")) > 0
Local lCamposRat := DTP->(ColumnPos("DTP_RATEIO")) > 0

Default cFilCfs	:= ""
Default cNumSol	:= ""
Default cNumLot := ""
Default cCliDev := ""
Default cLojDev := ""

Private   aTitulo	:= {}
Private lMsErroAuto := .F.

If lViaCol .AND. IsInCallStack("TMSAF76")
	If IsInCallStack("TMSF76VIA")
		cRet := cNumLot
	Else
		If !Empty(cFilCfs) .And. !Empty(cNumSol)
			//-- Busca o ultimo registro na movimentacao de documentos para a solicitacao de coleta atual
			cQuery := " SELECT MAX(DUD.R_E_C_N_O_) AS DUDRECNO "
			cQuery += " FROM "+RetSqlName("DUD")+ " DUD "
			cQuery += " WHERE	DUD.DUD_FILIAL 	= '"+xFilial("DUD")+"' "
			cQuery += " AND	DUD.D_E_L_E_T_ 	= ' ' "
			cQuery += " AND	DUD.DUD_FILDOC 	= '"+cFilCfs+"' "
			cQuery += " AND	DUD.DUD_DOC		= '"+cNumSol+"' "
			cQuery += " AND	DUD.DUD_SERIE		= 'COL' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

			If (cAliasQry)->(!Eof())
				DUD->(DbGoTo((cAliasQry)->DUDRECNO))

				If !Empty(DUD->DUD_VIAGEM)
					//-- Verifica se existe lote para a viagem atual e se o mesmo encontra-se em aberto
					cQuery := "SELECT DTP.DTP_LOTNFC,DTP.DTP_STATUS "
					cQuery += " FROM " + RetSqlName("DTP") + " DTP "
					cQuery += " JOIN " + RetSqlName("DTC") + " DTC ON "
					cQuery += " DTC.DTC_FILIAL = DTP.DTP_FILIAL "
					cQuery += " AND DTC.DTC_FILORI = DTP.DTP_FILORI "
					cQuery += " AND DTC.DTC_LOTNFC = DTP.DTP_LOTNFC "
					cQuery += " AND DTC.DTC_CLIDEV = '" + cCliDev + "' "
					cQuery += " AND DTC.DTC_LOJDEV = '" + cLojDev + "' "
					cQuery += " WHERE	DTP.DTP_FILIAL 	= '" + xFilial("DTP") + "' "
					cQuery += " AND	DTP.D_E_L_E_T_ 	= ' ' "
					cQuery += " AND	DTP.DTP_FILORI 	= '" + DUD->DUD_FILORI + "' "
					cQuery += " AND	DTP.DTP_VIACOL 	= '" + DUD->DUD_VIAGEM + "' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasDTP)

					If (cAliasDTP)->(!Eof()) .And. (cAliasDTP)->DTP_STATUS <> '3'
						cRet := (cAliasDTP)->DTP_LOTNFC
						cNumLotUso := (cAliasDTP)->DTP_LOTNFC
					Else
						lMsErroAuto := .F.
						AAdd(aCab,{'DTP_QTDLOT',Val(Replicate('9',TamSX3('DTP_QTDLOT')[1])),Nil})
						AAdd(aCab,{'DTP_VIACOL',DUD->DUD_VIAGEM,Nil})
						AAdd(aCab,{'DTP_QTDDIG',0,Nil})
						AAdd(aCab,{'DTP_STATUS','1',Nil})	//-- Em aberto

						If lTMSCTe
							AAdd(aCab,{'DTP_TIPLOT','3',Nil})	//-- Lote Eletronico
						EndIf
						MSExecAuto({|x,y| cRet := TMSA170(x,y)},aCab,3)

						If DTP->(DbSeek(xFilial("DTP")+cRet)) .And. !Empty(DUD->DUD_VIAGEM)
							RecLock("DTP",.F.)
							DTP->DTP_VIACOL	:= DUD->DUD_VIAGEM
							DTP->(MsUnLock())
							cNumLotUso := (cAliasDTP)->DTP_LOTNFC
						EndIf
					EndIf
					(cAliasDTP)->(DbCloseArea())
				Else
					lMsErroAuto := .F.
					AAdd(aCab,{'DTP_QTDLOT',Val(Replicate('9',TamSX3('DTP_QTDLOT')[1])),Nil})
					AAdd(aCab,{'DTP_QTDDIG',0,Nil})
					AAdd(aCab,{'DTP_STATUS','1',Nil})	//-- Em aberto

					If lTMSCTe
						AAdd(aCab,{'DTP_TIPLOT','3',Nil})	//-- Lote Eletronico
					EndIf
					MSExecAuto({|x,y| cRet := TMSA170(x,y)},aCab,3)

					cRet := DTP->DTP_LOTNFC
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
		ElseIf Empty(cNumSol)
			lMsErroAuto := .F.
			AAdd(aCab,{'DTP_QTDLOT',Val(Replicate('9',TamSX3('DTP_QTDLOT')[1])),Nil})
			AAdd(aCab,{'DTP_VIACOL',DUD->DUD_VIAGEM,Nil})
			AAdd(aCab,{'DTP_QTDDIG',0,Nil})
			AAdd(aCab,{'DTP_STATUS','1',Nil})	//-- Em aberto

			If lTMSCTe
				AAdd(aCab,{'DTP_TIPLOT','3',Nil})	//-- Lote Eletronico
			EndIf
			MSExecAuto({|x,y| cRet := TMSA170(x,y)},aCab,3)

			If DTP->(DbSeek(xFilial("DTP")+cRet)) .And. !Empty(DUD->DUD_VIAGEM)
				RecLock("DTP",.F.)
				DTP->DTP_VIACOL	:= ""
				DTP->(MsUnLock())
			EndIf
		EndIf
	EndIf
Else
	cQuery := "SELECT DTP_LOTNFC, DTP_DATLOT, DTP_HORLOT, DTP_QTDDIG, R_E_C_N_O_ DTPRECNO FROM "+RetSqlName("DTP")
	cQuery += " WHERE DTP_FILIAL  = '"+xFilial("DTP")+"'"
	cQuery += "   AND DTP_FILORI = '"+cFilAnt+"'"
	cQuery += "   AND DTP_STATUS = '1' "
	cQuery += "   AND D_E_L_E_T_  = ' ' ORDER BY DTP_LOTNFC "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
	TcSetField(cAliasQry,"DTP_DATLOT","D",8,0)
	While (cAliasQry)->(!Eof())
		Aadd(aItens,{ (cAliasQry)->DTP_LOTNFC, dtoc((cAliasQry)->DTP_DATLOT), TransForm( (cAliasQry)->DTP_HORLOT, PesqPict('DTP','DTP_HORLOT') ), AllTrim(str((cAliasQry)->DTP_QTDDIG)), (cAliasQry)->DTPRECNO })
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
	dbSelectArea("DTP")

	If Len(aItens) > 0
		Aadd( aTitulo, RetTitle('DTP_LOTNFC') )
		Aadd( aTitulo, RetTitle('DTP_DATLOT') )
		Aadd( aTitulo, RetTitle('DTP_HORLOT') )
		Aadd( aTitulo, RetTitle('DTP_QTDDIG') )

		aCabec := aClone(aTitulo)
		If isBlind() .Or. IsInCallStack("FwMyTestRunner")
			nRet := AScan(aItens,{|x| x[4] == "0" })
		Else
			nRet := TmsF3Array( aTitulo, aItens, cCadastro, lCancel, /*aNewButton*/ , aCabec )
		EndIf

		If !Empty(nRet)
			DTP->(dbGoTo(aItens[nRet,Len(aTitulo)+1]))
			cRet := DTP->DTP_LOTNFC
			If lCamposRat
				lRateio := Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
			Endif
			If lRateio
				cTABRAT := DTP->DTP_TABRAT
				cTIPRAT := DTP->DTP_TIPRAT
				cTBARAT := DTP->DTP_TBARAT
				cTPARAT := DTP->DTP_TPARAT
				cBACRAT := Iif( DTP->DTP_BACRAT == StrZero(1, Len(DTP->DTP_BACRAT)), "", DTP->DTP_BACRAT) // 1=Nao Utiliza
				cCRIRAT := Iif( DTP->DTP_CRIRAT == StrZero(1, Len(DTP->DTP_CRIRAT)), "", DTP->DTP_CRIRAT) // 1=Nao Utiliza
				cPRORAT := Iif( DTP->DTP_PRORAT == StrZero(1, Len(DTP->DTP_PRORAT)), "", DTP->DTP_PRORAT) // 1=Nao Utiliza
				If lCmpRatNew
					cCRDVFA := Iif( DTP->DTP_CRDVFA == StrZero(0, Len(DTP->DTP_CRDVFA)), "", DTP->DTP_CRDVFA) // 0=Nao Utiliza
					cCRDVDC := Iif( DTP->DTP_CRDVDC == StrZero(0, Len(DTP->DTP_CRDVDC)), "", DTP->DTP_CRDVDC) // 0=Nao Utiliza
				EndIf
				cORIRAT := DTP->DTP_ORIRAT
				cCALRAT := DTP->DTP_CALRAT
				M->DTC_ORIRAT := cORIRAT

				If !Empty(M->DTC_ORIRAT)
					RunTrigger(1,Nil,Nil,,"DTC_ORIRAT")
				EndIf

				M->DTC_CALRAT := cCALRAT

				If !Empty(M->DTC_CALRAT)
					RunTrigger(1,Nil,Nil,,"DTC_CALRAT")
				EndIf

			Else
				M->DTC_ORIRAT := CriaVar("DTC_ORIRAT",.F.)
				M->DTC_RORRAT := CriaVar("DTC_RORRAT",.F.)
				M->DTC_UORRAT := CriaVar("DTC_UORRAT",.F.)
				M->DTC_CALRAT := CriaVar("DTC_CALRAT",.F.)
				M->DTC_RCARAT := CriaVar("DTC_RCARAT",.F.)
				M->DTC_UCARAT := CriaVar("DTC_UCARAT",.F.)
			EndIf
		EndIf
	EndIf

	If Len(aItens) == 0 .Or. Empty(nRet)
		AAdd(aCab,{'DTP_QTDLOT',Val(Replicate('9',TamSX3('DTP_QTDLOT')[1])),Nil})
		AAdd(aCab,{'DTP_QTDDIG',0,Nil})
		AAdd(aCab,{'DTP_STATUS','1',Nil})	//-- Em aberto

		If lTMSCTe
			AAdd(aCab,{'DTP_TIPLOT','3',Nil})	//-- Lote Eletronico
		EndIf

		MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCab,3)
		If lMsErroAuto
			MostraErro()
			cRet := Space(TamSX3('DTP_LOTNFC')[1])
		EndIf
	EndIf
EndIf

RestArea(aGetArea)

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS050Agd ³ Autor ³Marcelo Coutinho       ³ Data ³ 07/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Agendamento de Entrega no Lançamento do Documento           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS050Agd(cCliAgd,cLojAgd)

Local cRet      := cTipAgdEnt

If lPsqAgdEnt .And. !Empty(cCliAgd) .And. !Empty(cLojAgd)

	cRet := cTipAgdEnt := TMS050Cpt(cCliAgd,cLojAgd)

	lPsqAgdEnt := .F.
Else

	If !Empty(cCliAgd) .And. !Empty(cLojAgd)

	 	lPsqAgdEnt := .T.
	Else

		cRet := cTipAgdEnt := "2"
	EndIf
EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS050Cpt ³ Autor ³Marcelo Coutinho       ³ Data ³ 07/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o Cliente/Loja possui Agendamento de Entrega    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Caracter 1=Sim, 2=Nao, 3=Obrigatorio.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS050Cpt(cCliAgd,cLojAgd,cCodPas)
Local cRet      := ""
Local cQuery    := ""
Local cAliasQry := ""
Local aGetArea  := GetArea()

If	AliasInDic("DYF")
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DYF.DYF_AGDENT FROM " + RetSqlName("DYF") + " DYF"
	If	cCodPas <> Nil .And. AliasInDic("DYE")
		cQuery += ", " + RetSqlName("DYE") + " DYE"
		cQuery += " WHERE DYE.DYE_FILIAL  = '" + xFilial("DYE") + "'"
		cQuery += "   AND DYE.DYE_CODPAS  = '" + cCodPas        + "'"
		cQuery += "   AND DYF.DYF_FILIAL  = '" + xFilial("DYF") + "'"
		cQuery += "   AND DYF.DYF_CODPAS  = DYE.DYE_CODPAS"
	Else
		cQuery += " WHERE DYF.DYF_FILIAL  = '" + xFilial("DYF") + "'"
	EndIf
	cQuery += "   AND DYF.DYF_CLIDES  = '" + cCliAgd         + "'"
	cQuery += "   AND DYF.DYF_LOJDES  = '" + cLojAgd         + "'"
	cQuery += "   AND DYF.DYF_DATDE  <= '" + Dtos(dDataBase) + "'"
	cQuery += "   AND ( DYF.DYF_DATATE >= '" + Dtos(dDataBase) + "' OR DYF.DYF_DATATE = ' ' ) "
	cQuery += "   AND DYF.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY DYF.DYF_AGDENT DESC "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
	cRet := (cAliasQry)->DYF_AGDENT
	(cAliasQry)->(DbCloseArea())
	RestArea(aGetArea)
EndIf

If cCodPas <> Nil
	Return !Empty(cRet)
EndIf

cRet := Iif(!Empty(cRet), cRet, "2")

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMA050SEF      ºAutor  ³TOTVS          º Data ³  10/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta a chave da NFe digitada na Sefaz                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mesma Funcao A103ConsNfeSef                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA050SEF(cChaveNFe,cDocDTC,cSerDTC)

Local lRet	  	:= .F.
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt   	:= ""
Local cCodRet	:= "Codigo de retorno: "
Local cMensRet  := "Mensagem de retorno: "
Local cProt		:= "Protocolo: "

Default cChaveNFe:= ""
Default cDocDTC  := ""
Default cSerDTC  := ""

Private oWS

If TMSIsReady()  //(cURL)
   	//Obtem o codigo da entidade
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	EndIf

	oWs:= WsNFeSBra():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cID_ENT      := cIdEnt
	oWs:cCHVNFE		 := cChaveNFe
	oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

	If oWs:ConsultaChaveNFE()
		If Type ("oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO") == "U" .OR. Empty (oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
		  	Aviso(STR0009,'A chave digitada nao foi encontrada na SEFAZ ' + STR0035 + ': ' + cDocDTC + ' /' + cSerDTC,{'Ok'}) //"Atencao"###"A Somatoria dos Valores de Volume, Peso, Quilometragem ou Valor da Nota Fiscal estao diferentes dos Valores Informados na Cotacao de Frete"
			lRet := .F.
		ElseIf AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"
	   		If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
	   		         	cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
		             	cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF+;
		             	STR0035+ ": " + cDocDTC + ' /' + cSerDTC+CRLF+CRLF+;
		             	"Deseja inserir a chave mesmo assim?")
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Else
			lRet := .T.
		EndIf
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) +CRLF+STR0035 + ': ' + cDocDTC + ' /' + cSerDTC,{"OK"},3)
	EndIf
Else
	Help(" ",1,"TSSINATIVO")
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A050FrtInf     ºAutor  ³Rafael Souza   º Data ³  12/09/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Frete Informado                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050FrtInf(nOpcx, lEdita, cOpcReal, lTela)

Local aAreas    := {DTP->(GetArea()),GetArea()}
Local aErrCal   := {}
Local aFrtAux   := {}
Local aTipVei   := {}
Local aFrtIni   := {}
Local aCalFre   := {}
Local aFrtBkp   := AClone(aFrtAux)
Local cSeqIns   := ""
Local cQuery    := ""
Local cLotNfc   := ""
Local cTipNFC   := M->DTC_TIPNFC
Local cCodPro   := Space(Len(SB1->B1_COD))
Local cSerTms   := M->DTC_SERTMS
Local cTipTra   := M->DTC_TIPTRA
Local cServic   := M->DTC_SERVIC
Local cAliasDT8 := GetNextAlias()
Local lCliGen   := .F.
Local lAjuAut   := .F.
Local lPrcPdg   := .T.
Local lPrcProd  := SuperGetMV('MV_PRCPROD',,.T.)
Local lIdentDoc := DTC->(ColumnPos("DTC_DOCTMS")) > 0
Local nSeek     := 0
Local nValMer   := 0
Local nPeso     := 0
Local nMetro3   := 0
Local nQtdVol   := 0
Local nQtdUni   := 0
Local nPesoM3   := 0
Local nKm       := 0
Local nPOsVei   := 0
Local nPOsQtd   := 0
Local nX        := 0
Local nY        := 0
Local nPosFrt   := 0
Local nCntFor   := 0
Local lFechado  := GetMv("MV_COTVFEC",,.F.)  //-- Permite a digitacao de Valor Fechado por componente
Local lTmsFrInf := GetMv("MV_TMSVINF",,.F.)
Local cNumNfc	:= ""
Local cSerNfc   := ""
Local lCamposRat:= DTP->(ColumnPos("DTP_RATEIO")) > 0

Private cOpcao  := AllTrim( Iif(lEdita, STR0108, STR0109) ) //Frete Informado / Visualiza Frete
Private aFrete  := {}

Default cOpcReal := ""
Default lTela   := .T.

If lTmsFrInf
	If cOpcReal == "Visualiza Frete" .And. M->DTC_VLRINF > 0 .And. nOpcx <> 2
		If !MsgYesNo(STR0170) //"Este documento possui valor de frete informado. Esta opção irá efetuar o recálculo do frete, com base na tabela de frete, e o valor de frete informado será desconsiderado. Deseja continuar?"
			aEval(aAreas,{|xArea| RestArea(xArea) } )
			Return( .T. )
		EndIf
	EndIf
EndIf

nOpcx:= 15  //Utilizado no TMSA500
If lIdentDoc
	cDocTms := M->DTC_DOCTMS
Else
	cDocTms := Posicione('DC5',1,xFilial('DC5') + M->DTC_SERVIC,'DC5_DOCTMS')
EndIf

Default lEdita  := .F.
// Essa variável será carregada somente, quando for chamado via TMS Express,
//pois para o cálculo do componente 09 praça de pedágio, e necessário informar o número do lote para a função TMSCalFre()
If  TmsExp() .And. Substr(FunName(),1,7) == "TMSA144"
	cLotNfc := M->DTC_LOTNFC
	If Empty(cLotNfc)
		Help("",1,"TMSA050A8") //-- Nao é Possivel Pre-Visualizacao de Calculos, informe o numero do lote !
		Return( .F. )
	EndIf
EndIf
// Sendo Rateio, a Visualizacao dos Componentes nao devera sera Apresentada //
DTP->(DbSetOrder(2))
If DTP->(MsSeek(xFilial("DTP") + M->DTC_FILORI + M->DTC_LOTNFC))
	If lCamposRat
		lRateio	  := Iif( DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
	EndIf
EndIf
If lRateio .And. !lEdita
	Help("",1,"TMSA05097") //-- Nao é Possivel Pre-Visualizacao de Calculos com base em Rateio !
	Return( .F. )
EndIf

If !Empty(aColsDVU)
	nPOsVei := Ascan(aHeaderDVU, { |x| AllTrim(x[2]) == 'DVU_TIPVEI' })
	nPOsQtd := Ascan(aHeaderDVU, { |x| AllTrim(x[2]) == 'DVU_QTDVEI' })

	For nX := 1 to Len(aColsDVU)
		For nY := 1 to Len(aColsDVU[nX][2])
			If !GdDeleted(nY,aHeaderDVU,aColsDVU[nX][2])
				nSeek := AScan(aTipVei,{|x|x[1]==aColsDVU[ nX, 2, nY, 2 ] })
				If	nSeek > 0
					aTipVei[nSeek,2]+=aColsDVU[ nX, 2, 1, 4 ]
				Else
				   AAdd(aTipVei, {aColsDVU[nX][2][nY][nPOsVei], aColsDVU[nX][2][nY][nPOsQtd]})
				EndIf
			EndIf
		Next nY
	Next nX
EndIf

nKm := M->DTC_KM

If	!( cDocTms $ "7;D" )

	aFrete := {}

	//-- Acumulado dos documentos (DTC) - considerando todos os produtos
	For nX := 1 to Len(aCols)
		If !GdDeleted(nX)
			nQtdVol += GDFieldGet( "DTC_QTDVOL" ,nX )
			nPeso   += GDFieldGet( "DTC_PESO"   ,nX )
			nValMer += GDFieldGet( "DTC_VALOR"  ,nX )
			nQtdUni += GDFieldGet( "DTC_QTDUNI" ,nX )
			nPesoM3 += GDFieldGet( "DTC_PESOM3" ,nX )
			nMetro3 += GDFieldGet( "DTC_METRO3" ,nX )
			cCodPro := IIf(Empty(cCodPro), GDFieldGet( "DTC_CODPRO" ,nX ), cCodPro)
		EndIf
	Next nX

	//-- Calcula composicao do frete e impostos
	aCalFre := {}
	aCalFre := A050CalFrt("1"          , M->DTC_CLIREM, M->DTC_LOJREM, M->DTC_CDRORI, M->DTC_CLICAL, M->DTC_LOJCAL, M->DTC_CDRCAL, M->DTC_CLIDES, M->DTC_LOJDES,;
							M->DTC_CDRDES, M->DTC_SQEDES, M->DTC_CLIDEV, M->DTC_LOJDEV, cCodPro      , M->DTC_SERVIC, M->DTC_CODNEG, cSerTms      , cTipTra      ,;
							cDocTms      , cLotNfc      , M->DTC_TIPFRE, cTipNFC      , cSeqIns      , nValMer      , nPeso        , nPesoM3      , nQtdVol      ,;
							nMetro3      , nKm          , nQtdUni      , 0            , lPrcPdg      , lCliGen      , lAjuAut      , aValInf      , aTipVei)

	If ! Empty(aCalFre) .And. Len(aCalFre) > 0
		aFrete := aClone(aCalFre[1])
	EndIf


	//-- Forca a linha totalizadora para a ultima posicao do vetor aFrete
	ASort(aFrete,,,{|x,y| x[12] + x[3] < y[12] + y[3] })

	nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })

	If	nSeek <= 0 .Or. aFrete[nSeek,2] <= 0 .Or. nSeek != Len(aFrete) .Or. ! Empty(aErrCal)
		If	nSeek <= 0 .Or. aFrete[nSeek,2] <= 0
			AAdd(aErrCal,{STR0112,'00',''}) //"Valor do frete zerado"
		ElseIf nSeek != Len(aFrete)
			AAdd(aErrCal,{STR0113,'00',''}) //'Falha na linha totalizadora da composicao do frete'
		EndIf

		If	! Empty( aErrCal )
			TmsMsgErr( aErrCal )
		EndIf

		aFrete := AClone(aFrtBkp)
		Return( .F. )
	EndIf
EndIf

If	Type('oLbxEsp') == 'O'
	oLbxEsp:Refresh()
EndIf
If Type('oLbx') == 'O'
	//-- Apresenta a composicao do frete
	TmsViewFrt('9')
	oLbx:Refresh()
EndIf

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

If nOpcAnt == 2 .And. !Empty(M->DTC_NUMCOT)
	cQuery := "SELECT DT8_CODPAS, SUM(DT8_VALPAS) DT8_VALPAS, "
	cQuery += 	" SUM(DT8_VALIMP) DT8_VALIMP, SUM(DT8_VALTOT) DT8_VALTOT"
	cQuery += "  FROM " + RetSqlName("DT8")
	cQuery += " WHERE DT8_FILIAL = '" + xFilial("DT8") + "' "
	cQuery += "   AND DT8_FILORI = '" + M->DTC_FILORI + "' "
	cQuery += "   AND DT8_NUMCOT = '" + M->DTC_NUMCOT + "' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY DT8_CODPAS"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT8,.T.,.T.)

   	While (cAliasDT8)->(!Eof())
   		nPosFrt := aScan(aFrete,{|x|x[3]==(cAliasDT8)->DT8_CODPAS})
   		If nPosFrt > 0
	  	   	aFrete[nPosFrt, 2] := (cAliasDT8)->DT8_VALPAS
			aFrete[nPosFrt, 5] := (cAliasDT8)->DT8_VALIMP
		   	aFrete[nPosFrt, 6] := (cAliasDT8)->DT8_VALTOT
		EndIf
  		(cAliasDT8)->(dbSkip())
   	EndDo
   	(cAliasDT8)->(DbCloseArea())
EndIf

aFrtIni := aClone(aFrete)

TmsA500Dsc( 15,,,,,lEdita,.T.,Iif(lEdita,M->DTC_VLRINF,0),nOpcAnt,lTela, cCodPro)

If lEdita
	M->DTC_VLRINF := aFrete[Len(aFrete)][2]
	aCotFrete     := aClone(aFrete)
EndIf

nOpcx:= nOpcAnt

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

aEval(aAreas,{|xArea| RestArea(xArea) } )
Return( .T. )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A050CalFrt
Efetua o cálculo da composição de frete (componentes e impostos).
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/01/2017
@param [cTipCal], Caracter, Indica a função como deve ser realizado o cálculo da composição
@param [cCliRem], Caracter, Cliente remetente
@param [cLojRem], Caracter, Loja do cliente remetente
@param [cCdrOri], Caracter, Região de origem
@param [cCliCal], Caracter, Cliente de cálculo
@param [cLojCal], Caracter, Loja do cliente de cálculo
@param [cCdrCal], Caracter, Região do cliente de cálculo
@param [cCliDes], Caracter, Cliente destinatário
@param [cLojDes], Caracter, Loja do cliente destinatário
@param [cCdrDes], Caracter, Região do cliente destinatário
@param [cSqeDes], Caracter, Sequência do cliente destinatário
@param [cCliDev], Caracter, Cliente devedor
@param [cLojDev], Caracter, Loja do cliente devedor
@param [cCodPro], Caracter, Produto
@param [cServic], Caracter, Serviço negociação
@param [cCodNeg], Caracter, Negociação
@param [cSerTms], Caracter, Serviço TMS
@param [cTipTra], Caracter, Tipo de transporte
@param [cDocTms], Caracter, Documento TMS
@param [cLotNfc], Caracter, Lote da nota
@param [cTipFre], Caracter, Tipo de frete
@param [cTipNFC], Caracter, Tipo de NFC
@param [cSeqIns], Caracter, Sequência inscrição
@param [nValMer], Numérico, Valor acumulado da mercadoria
@param [nPeso], Numérico, Peso acumulado
@param [nPesoM3], Numérico, Peso M3 acumulado
@param [nQtdVol], Numérico, Quantitade acumulada de volume
@param [nMetro3], Numérico, Metro acumulado
@param [nKm], Numérico, KM
@param [nQtdUni], Numérico, Quantidade acumulada
@param [nBasSeg], Numérico, Base Seguro acumulada
@param [lPrcPdg], Lógico, Praça de pedágio?
@param [lCliGen], Lógico, Cliente genérico?
@param [lAjuAut], Lógico, Ajusta automaticamente?
@param [aValInf], Array, Valores informados
@param [aTipVei], Array, Tipos de veículos
@param [aFrtCom], Array, Composição de frete (obrigatório apenas quando cTipCal = 3)
@param [aCtrCli], Array, Contrato do cliente (se não informado, busca o contrato)
@return aRet Array que contém a composição de frete calculada e outras informações
@obs cTipCal = '1' - Calcular os componentes e impostos
@obs cTipCal = '2' - Calcular apenas os componentes
@obs cTipCal = '3' - Calcular apenas os impostos
@obs aRet[1]    - aFrtCal (Composição de frete calculada)
@obs aRet[2, 1] - aFrtPri (Composição de frete principal)
@obs aRet[2, 2] - aErrPri (Erro no calculo da composição de frete)
@obs aRet[2, 3] - cSeqPri (Sequencia da tabela de frete utilizada)
@obs aRet[3, 1] - aFrtAlt (Composição de frete alternativa)
@obs aRet[3, 2] - aErrAlt (Erro no calculo da composição de frete)
@obs aRet[3, 3] - cSeqAlt (Sequencia da tabela de frete utilizada)
@param [lCobSrvAd], Lógico, Executado pela rotina TMSA853
/*/
//-------------------------------------------------------------------------------------------------
Function A050CalFrt(cTipCal, cCliRem, cLojRem, cCdrOri, cCliCal, cLojCal, cCdrCal, cCliDes, cLojDes,;
                    cCdrDes, cSqeDes, cCliDev, cLojDev, cCodPro, cServic, cCodNeg, cSerTms, cTipTra,;
                    cDocTms, cLotNfc, cTipFre, cTipNFC, cSeqIns, nValMer, nPeso  , nPesoM3, nQtdVol,;
                    nMetro3, nKm    , nQtdUni, nBasSeg, lPrcPdg, lCliGen, lAjuAut, aValInf, aTipVei,;
                    aFrtCom, aCtrCli, lCobSrvAd)

	Local aArea   := GetArea()
	Local aRet    := {} //-- Retorno da funcao
	Local aFrtCal := {}
	Local aFrtPri := {}
	Local aErrPri := {} //-- Armazena o retorno de erros da funcao TMSCalFret
	Local aFrtAlt := {}
	Local aErrAlt := {} //-- Armazena o retorno de erros da funcao TMSCalFret

	Local cSeqPri := StrZero(0, Len(DVC->DVC_SEQTAB)) //-- Armazena o retorno da sequencia utilizada pela funcao TMSCalFret
	Local cSeqAlt := StrZero(0, Len(DVC->DVC_SEQTAB)) //-- Armazena o retorno da sequencia utilizada pela funcao TMSCalFret
	Local cNContr := "" //-- Nr Contrato cliente
	Local cTabFre := "" //-- Tabela de frete
	Local cTipTab := "" //-- Tipo tabela de frete
	Local cTabAlt := "" //-- Tabela alternativa
	Local cTipAlt := "" //-- Tipo tabela alternativa

	Local nSeek   := 0
	Local nTotFre := 0  //-- Valor total dos componentes da tabela de frete principal
	Local nTotAlt := 0  //-- Valor total dos componentes da tabela de frete alternativa

	Local cExcTDA   := ""
	Local cDEVTDA   := ""
	Local cRemTDA   := ""
	Local cDesTDA   := ""
	Local lFoundSA1 := .F.
	Local nX        := 0
	Local nY        := 0
	Local aNfCTRC   := {}

	Default cTipCal  := "1"
	Default cCliRem  := ""
	Default cLojRem  := ""
	Default cCdrOri  := ""
	Default cCliCal  := ""
	Default cLojCal  := ""
	Default cCdrCal  := ""
	Default cCliDes  := ""
	Default cLojDes  := ""
	Default cCdrDes  := ""
	Default cSqeDes  := ""
	Default cCliDev  := ""
	Default cLojDev  := ""
	Default cCodPro  := ""
	Default cServic  := ""
	Default cCodNeg  := ""
	Default cSerTms  := ""
	Default cTipTra  := ""
	Default cDocTms  := ""
	Default cLotNfc  := ""
	Default cTipFre  := ""
	Default cTipNFC  := ""
	Default cSeqIns  := ""
	Default nValMer  := 0
	Default nPeso    := 0
	Default nPesoM3  := 0
	Default nQtdVol  := 0
	Default nMetro3  := 0
	Default nKm      := 0
	Default nQtdUni  := 0
	Default nBasSeg  := 0
	Default lPrcPdg  := .F.
	Default lCliGen  := .F.
	Default lAjuAut  := .F.
	Default aValInf  := {}
	Default aTipVei  := {}
	Default aFrtCom  := {}
	Default lCobSrvAd:= .F.   //Executado pela rotina TMSA853 - Cobrança Servico Adicional

	//-- Montagem do retorno padrao
	aRet := {}
	Aadd(aRet, aFrtCal)                     //-- aRet[1] - aFrtCal
	Aadd(aRet, {aFrtPri, aErrPri, cSeqPri}) //-- aRet[2, 1] - aFrtPri | aRet[2, 2] - aErrPri | aRet[2, 3] - cSeqPri
	Aadd(aRet, {aFrtAlt, aErrAlt, cSeqAlt}) //-- aRet[3, 1] - aFrtAlt | aRet[3, 2] - aErrAlt | aRet[3, 3] - cSeqAlt

	//-- Calcular componentes e impostos ou componentes
	If cTipCal == "1" .Or. cTipCal == "2"

		//-- Identifica contrato do cliente
		If Empty(aCtrCli)
			aCtrCli := TMSContrat(cCliCal, cLojCal, , cServic, , cTipFre,,,,,,,,,,,,,,,, cCodNeg )
			If Len(aCtrCli) > 0
				cDEVTDA := aCtrCli[1,28]					    //-- 80 Devedor Paga TDA
			EndIf
		EndIf
		If Len(aCtrCli) > 0
			cNContr := aCtrCli[1,1]
			cTabFre := aCtrCli[1,3]
			cTipTab := aCtrCli[1,4]
			cTabAlt := aCtrCli[1,15]
			cTipAlt := aCtrCli[1,16]
		
		//-- Nao achou o contrato do cliente cadastrado ou ativo...
		Else
			Return aRet
		EndIf

		If !lCobSrvAd
			cExcTDA := M->DTC_EXCTDA
		EndIf
		dbSelectArea("SA1")
		lFoundSA1 := StaticCall(TMSA200, TMSA200Cli, Iif(lCobSrvAd, cCliRem, M->DTC_CLIREM), Iif(lCobSrvAd, cLojRem, M->DTC_LOJREM) )
		If lFoundSA1    //posiciona na tabela SA1
			cRemTDA := SA1->A1_TDA	                    //-- 81 Rementente TEM TDA
		Else
			cRemTDA := ""  			                    //-- 81 Rementente TEM TDA
		EndIf
		dbSelectArea("DUL")
		If !Empty(M->DTC_SQEDES)
			DUL->(dbSetOrder(2))
			If DUL->(MsSeek(xFilial("DUL") + Iif(lCobSrvAd, cCliDes+cLojDes+cSqeDes, M->DTC_CLIDES + M->DTC_LOJDES + M->DTC_SQEDES)) )
				cDesTDA := DUL->DUL_TDA	                //-- 82 Destinatario TEM TDA - Sequencia
			Else
				cDesTDA := ""                           //-- 82 Destinatario TEM TDA - Sequencia
			EndIf
		Else
		    cDesTDA := "1"

		    lFoundSA1 := StaticCall(TMSA200, TMSA200Cli, Iif(lCobSrvAd, cCliDes, M->DTC_CLIDES), Iif(lCobSrvAd, cLojDes, M->DTC_LOJDES) )
		    //
			If lFoundSA1 //posiciona na tabela SA1
				cDesTDA := SA1->A1_TDA                  //-- 82 Destinatario TEM TDA - Sequencia
			Else
				cDesTDA := ""                           //-- 82 Destinatario TEM TDA - Sequencia
			EndIf
		EndIf
		RESTAREA(aArea)

		//-- Acumulado dos documentos (DTC) - considerando todos os produtos
		If !lCobSrvAd
			For nX := 1 to Len(aCols)
				If !GdDeleted(nX)
					AAdd( aNfCTRC, {	GdFieldGet( "DTC_NUMNFC", nX) , GDFieldGet( "DTC_SERNFC" ,nX ), M->DTC_CLIREM,;
										M->DTC_LOJREM                 , GDFieldGet( "DTC_QTDVOL",nX ) , GDFieldGet( "DTC_VALOR"  ,nX ),;
										GDFieldGet( "DTC_PESO"   ,nX ), GDFieldGet( "DTC_PESOM3",nX ) , GDFieldGet( "DTC_METRO3" ,nX ),;
										nBasSeg                       , cNContr                       , cSerTms ,;
										cTipTra                       , M->DTC_CDRORI                 , M->DTC_CDRDES ,;
										M->DTC_SERVIC                 , aCtrCli[ 1, 6 ]               , aCtrCli[ 1, 7 ],;
										M->DTC_CLIDES                 , M->DTC_LOJDES                 , M->DTC_CLIDEV,;
										M->DTC_LOJDEV                 , GDFieldGet( "DTC_CODPRO",nX ) , M->DTC_NUMCOT,;
										aCtrCli[ 1, 8 ]               , aCtrCli[ 1, 20 ]              , GDFieldGet( "DTC_QTDUNI" ,nX ),;
										M->DTC_VALDPC                 , M->DTC_FILDPC                 , M->DTC_CTRDPC,;
										aCtrCli[ 1, 22 ]              , M->DTC_NUMSOL                 , M->DTC_TIPNFC,;
										If(Empty(GDFieldGet("DTC_PESO",nX)),"0","1"),;
										aCtrCli[ 1, 9 ]               , cSqeDes                       , cSeqIns,;
										GDFieldGet("DTC_PESLIQ",nX )  , M->DTC_MOEDA                  , cExcTDA,;
										cDEVTDA                       , cRemTDA                       , cDesTDA,;
										M->DTC_SQIDES                 , M->DTC_CDRCAL                 , aCtrCli[ 1, 23 ],;
										nX                            , "" /* LTQBRCALC */            , CtoD('')/* LTDATAGD */ ,;
										cCodNeg    , "" /* LTQBRDIVG */            , nKm,;
										0 /* LTPESCOL */              , If(Len(aCtrCli[1])>=51,aCtrCli[ 1, 51 ],'0'), "" /* cNumCmp */, M->DTC_LOTNFC /* cLotNfc */} )

				EndIf
			Next nX
		EndIf

		//-- Calcula componentes de frete com base na tabela de frete principal
		aFrtPri := {}
		aFrtPri := TMSCalFret(cTabFre, cTipTab, @cSeqPri, cCdrOri, cCdrCal , cCliCal, cLojCal, cCodPro,;
		                      cServic, cSerTms, cTipTra , cNContr, @aErrPri,@aNfCTRC, nValMer, nPeso  ,;
		                      nPesoM3,        , nQtdVol ,        , nBasSeg , nMetro3,        ,        ,;
		                      nKm    ,        ,         , lCliGen, lAjuAut ,        , nQtdUni,        ,;
		                             ,        , aValInf , aTipVei, cDocTms ,        ,        ,        ,;
		                             ,        ,         ,        ,         , cLotNfc,        , lPrcPdg,;
		                             ,        ,         , cExcTDA, cDEVTDA , cRemTDA, cDesTDA,        ,;
		                      cCliDes, cLojDes, cSqeDes ,        ,         ,        ,        , cCodNeg)

		//-- Total do frete, obtido com a tabela de frete principal
		nSeek := Ascan(aFrtPri,{|x| x[3] == 'TF'})
		If nSeek > 0
			nTotFre := aFrtPri[nSeek, 2]
		EndIf

		aRet[2, 1] := aFrtPri
		aRet[2, 2] := aErrPri
		aRet[2, 3] := cSeqPri

		//-- Calcula componentes de frete com base na tabela de frete alternativa
		If !Empty(cTabAlt) .And. !Empty(cTipAlt)
			aFrtAlt := {}
			aFrtAlt := TMSCalFret(cTabAlt, cTipAlt, @cSeqAlt, cCdrOri, cCdrCal , cCliCal, cLojCal, cCodPro,;
			                      cServic, cSerTms, cTipTra , cNContr, @aErrAlt,        , nValMer, nPeso  ,;
			                      nPesoM3,        , nQtdVol ,        , nBasSeg , nMetro3,        ,        ,;
			                      nKm    ,        ,         , lCliGen, lAjuAut ,        , nQtdUni,        ,;
			                             ,        , aValInf , aTipVei, cDocTms ,        ,        ,        ,;
			                             ,        ,         ,        ,         , cLotNfc,        , lPrcPdg,;
			                             ,        ,         , cExcTDA, cDEVTDA , cRemTDA, cDesTDA,        ,;
			                      cCliDes, cLojDes, cSqeDes ,        ,         ,        ,        , cCodNeg)
		EndIf

		//-- Total do frete, obtido com a tabela de frete alternativa
		nSeek := Ascan(aFrtAlt, {|x| x[3] == 'TF'})
		If nSeek > 0
			nTotAlt := aFrtAlt[nSeek, 2]
		EndIf

		aRet[3, 1] := aFrtAlt
		aRet[3, 2] := aErrAlt
		aRet[3, 3] := cSeqAlt

		//-- Caso o total da tabela de frete alternativa seja maior
		//-- que da tabela principal, assume a tabela alternativa
		aFrtCal := {}
		If nTotAlt > nTotFre
			aFrtCal := aClone(aFrtAlt)
		Else
			aFrtCal := aClone(aFrtPri)
		EndIf

		aRet[1] := aFrtCal

	EndIf

	//-- Calcular componentes e impostos ou impostos
	If cTipCal == "1" .Or. cTipCal == "3"

		//-- Quando for apenas para calcular impostos eh necessario passar a composicao do frete
		If cTipCal == "3" .And. ! Empty(aFrtCom) .And. Len(aFrtCom) > 0
			aFrtCal := {}
			aFrtCal := aClone(aFrtCom)
		EndIf

		cTipo := Posicione("SA1", 1, xFilial("SA1") + cCliDes + cLojDes, "A1_TIPO")

		//-- Realiza o calculo de impostos da composicao de frete
		TmsA040Imp(@aFrtCal, cCliDev, cLojDev, cDocTms, cTipFre, cCdrDes, .T.    ,        ,;
		                   , cTipo  ,        , cCdrOri,        ,        , cCliRem, cLojRem,;
		           cCliDes , cLojDes,        ,   .F.     , cTipNFC, cCodPro, cSeqIns)

		aRet[1] := aFrtCal

	EndIf

	RestArea(aArea)

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A050VlrInf     ºAutor  ³Rafael Souza   º Data ³  15/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o valor do array aCotFrete e diferente do campoº±±
±±º			 ³ DTC_VLRINF                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A050VlrInf()
If len(aCotFrete) > 0
	If aCotFrete[Len(aCotFrete),2] <> M->DTC_VLRINF
		aCotFrete := {}
	EndIf
EndIf

Return ( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS050Trig ³Autor ³Izac Silvério Ciszevski  Data ³ 01/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega e executa os gatilhos da tela                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³ ExpA1 - Array com Campos da rotina 		                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA050                                                    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS050Trig( aVisual , cCpoOrig , cCpoDest ) 
    Local nX:=0
Local xRet			:= Nil
Local aArea			:= GetArea()

Default aVisual		:= {} 
Default cCpoOrig	:= ReadVar()
Default cCpoDest	:= ""

If Len(aVisual) > 0 
    For nX:= 1 to Len(aHeader)
        cCampo := aHeader[nX][2]
        If ExistTrigger(cCampo)
            If !Empty(GdFieldGet(cCampo , 1 ))
                __readvar := "M->" + cCampo
                RunTrigger(2, 1, nil, o1Get, cCampo)
            EndIf
        EndIf
    Next

    For nX:= 1 to Len(aVisual)
        cCampo := aVisual[nX]
        If ExistTrigger(cCampo)
            If !Empty(&("M->" + cCampo))
                __readvar := "M->" + cCampo
                RunTrigger(1, nil, nil, , cCampo)
            EndIf
        Endif
    Next

Else

	If cCpoOrig == "M->DTC_LOTNFC" .Or. cCpoOrig == "DTC->DTC_LOTNFC"
		xRet	:= RetInfoDTW( cCpoOrig , cCpoDest )
	EndIf

EndIf

RestArea(aArea)
Return xRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS050AFil³ Autor ³Izac Silvério Ciszevski³ Data ³ 01/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega a tela baseado no numero e item de agendamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS050AFil()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Expc1 - Numero do Agendamento                               ³±±
±±³          ³Expc2 - Item  do Agendamento	                             ³±±
±±³          ³Expc3 - Numero do Lote     	                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMS050AFIL(cNumAge,cIteAge,cNumLot)
Local aAreas	:= {DUL->(GetArea()),DC5->(GetArea()),DTC->(GetArea()),DF1->(GetArea()),DF2->(GetArea()),DE5->(GetArea()),DT6->(GetArea()),SA1->(GetArea()),DT5->(GetArea()),GetArea()}
Local aCabDTC	:= {}
Local aItem	    := {}
Local aItemDTC  := {}
Local aRet      := {}
Local lPos		:= !Empty(cNumAge) .And. !Empty(cIteAge)
Local lRet		:= .T.
Local lCont     := .T.
Local cCodBar	:= ""
Local cQuery    := ""
Local cAliasDE5 := ""
Local cAliasDUA := ""
Local cCodEmb   := ""
Local cCodPro   := ""
Local cSeekDF2  := ""
//--Local cOrigem   := "" //--> EAlberti -> Removido já que a variável está sendo usada como static
Local cDevFre   := ""
Local cSerTMS   := Space(Len(DTC->DTC_SERTMS))
Local nQtdVol   := 0
Local nPeso	    := 0
Local nPesoM3	:= 0
Local nValMer	:= 0
Local nBasSeg	:= 0
Local nQtdUni	:= 0
Local dDatCol   := ctod("")
Local cHorCol   := ""
Local cFilCfs	:= ""
Local cNumSol	:= ""
Local cCliDev   := ""
Local cLojDev   := ""
Local cCodNeg   := ""
Local cServico  := ""

Local nPosServic := 0
Local nPosNeg		:= 0
Local oGet,oDlg
Local nPosDevFre := 0
Local nPosCliRem := 0
Local nPosLojRem := 0
Local nPosCliDev := 0
Local nPosLojDev := 0
Local nPosCliCon := 0
Local nPosLojCon := 0
Local nPosCliCal := 0
Local nPosLojCal := 0
Local nPosCliDes := 0
Local nPosLojDes := 0
Local nPosTipFre := 0
Local nPosNumSol := 0
Local nPosFilCfs := 0
Local nPosNomCal := 0
Local nPosLotnfc := 0
Local cCdrOri 	:= ""
Local cCdrCal		:= ""
Local cLojCal		:= ""
Local lIdentDoc	:= DTC->(ColumnPos("DTC_DOCTMS")) > 0
Local cFilDT5    := xFilial('DT5')
Local lTmsCFec   := TMSCFec() 		// Verifica se é Carga Fechada
Local aContrat	:= {}
Local aCliCalc	:= {}
Local cCliRem		:= ""
Local cLojRem		:= ""
Local cCliDes		:= ""
Local cLojDes		:= ""
Local cSqEDes		:= ""
Local cSelOri		:= ""
Local lAlianca      := TMSAlianca() //-- Utiliza Alianca
Local cContrat      := ""
Local cTipFre       := ""

Local aFilUsu       := {}

Local cCliCon       := ""
Local cLojCon       := ""
Local dDtEntr       := CToD(Space(08))
Local cHorEnt       := Space(Len(DTC->DTC_HORCOL))

Default cNumLot := ""

If lPos
	If !Empty(DF1->DF1_DOC)
		cOrigem := "DF1"
		DT5->(dbSetOrder(1))
		If DT5->(dbSeek(xFilial("DT5")+DF1->DF1_FILDOC+DF1->DF1_DOC))
    		dDatCol:= DF1->DF1_DATPRC
    		cHorCol:= DF1->DF1_HORPRC
		EndIf

          //-- não permite digitar nota fiscal, se coleta não realizada ou se ocorrência não informada
          /*
          DUA->(DbSetOrder(4)) //-- 4-DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM
          If DUA->(MsSeek( xFilial("DUA") + DT5->(DT5_FILDOC + DT5_DOC + DT5_SERIE) ))
               DT2->(DbSetOrder(1))
               If DT2->(MsSeek(xFilial("DT2") + DUA->DUA_CODOCO)) .And. DT2->DT2_SERTMS == "1"
                   If DT2->DT2_TIPOCO $ "04|05|12"; //-- 12-Cancela
                      .Or. DT2->DT2_ATIVO <> "1" //--Ocorrencia desativada
                       //-- ( [ uPar1 ] [ uPar2 ] [ cCampo ] [ cNome ] [ cMensagem ] [ nLinha1 ] [ nColuna ] [ lPop ] [ uPar9 ] [ uPar10 ] [ uPar11 ] [ lGravaLog ][aSoluc] )
                       Help("",1,"TMSA050OCO-01","COLNREALIZ",STR0160 + DUA->DUA_FILORI + " / " + DUA->DUA_VIAGEM + ". ",; //-- "STR0160 - Não é permitido digitar Nota Fiscal criando vinculo com uma ocorrência de coleta não realizada. Viagem "
                                 2,3,.F.,,,,{{STR0161}}) //-- "STR0161 - Verifique a ocorrencia informado para a viagem citada neste aviso."
                       lRet := .F.
                   EndIf
               EndIf
          EndIf
          */
	Else
		Help("",1,"TMSA05086")  //-- Este agendamento não possui solicitação de coleta gerada.
		lRet := .F.
	EndIf
Else
	cQuery  := ""
	cOrigem := ""
	cCodBar := TMS050CBar()
	If !Empty(cCodBar)
		cAliasDT6 := GetNextAlias()
		cQuery := "SELECT DF1.R_E_C_N_O_ REGISTRO "

		cQuery += "  FROM " + RetSqlName("DT6") + " DT6 "

		cQuery += "  JOIN " + RetSqlName("DF1") + " DF1 "
		cQuery += "    ON DF1_FILIAL = '" + xFilial("DF1") + "' "
		cQuery += "   AND DF1_FILDOC = DT6_FILDOC "
		cQuery += "   AND DF1_DOC    = DT6_DOC "
		cQuery += "   AND DF1_SERIE  = DT6_SERIE "
		cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
		cQuery += "   AND DT6_CHVCTE = '" + PadR(cCodBar,Len(DT6->DT6_CHVCTE)) + "' "
		cQuery += "   AND DT6_SERIE  = 'COL' "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT6,.T.,.T.)

		If (cAliasDT6)->(!Eof())
			cOrigem := "DF1"
			DF1->(DbGoTo((cAliasDT6)->REGISTRO))
			cNumAge := "'" + DF1->DF1_NUMAGE + "'"
			cIteAge := "'" + DF1->DF1_ITEAGE + "'"
			lCont   := .F.
		EndIF
		(cAliasDT6)->(DbCloseArea())
		DbSelectArea("DTC")
		If lCont
			cAliasDE5 := GetNextAlias()
			cQuery := "SELECT DE5.R_E_C_N_O_ REGISTRO "

			cQuery += "  FROM " + RetSqlName("DE5") + " DE5 "

			cQuery += " WHERE DE5_FILIAL = '" + xFilial("DE5") + "' "
			cQuery += "   AND DE5_NFEID  = '" + PadR(cCodBar,Len(DE5->DE5_NFEID)) + "' "
			cQuery += "   AND DE5_STATUS = '1'		 "
			cQuery += "   AND DE5.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDE5,.T.,.T.)

			If (cAliasDE5)->(!Eof())
				cOrigem  := "DE5"
				DE5->(DbGoTo((cAliasDE5)->REGISTRO))
				If !Empty(DE5->DE5_CGCDEV)
					If DE5->DE5_CGCDEV == DE5->DE5_CGCREM
						cDevFre := "1"
					ElseIf DE5->DE5_CGCDEV == DE5->DE5_CGCDES
						cDevFre := "2"
					ElseIf DE5->DE5_CGCDEV == DE5->DE5_CGCCON
						cDevFre := "3"
					ElseIf DE5->DE5_CGCDEV == DE5->DE5_CGCDPC
						cDevFre := "4"
					EndIf
				Else
				  cDevFre := DE5->DE5_TIPFRE
				EndIf
			EndIf
			(cAliasDE5)->(DbCloseArea())
			DbSelectArea("DTC")
		Endif
	EndIf
EndIf

If lRet .And. !Empty(cOrigem)
	//Através do Serviço de Negociação DC5 Procura o DC5_SERTMS e verifica o
	If cOrigem == "DE5" .AND. Empty(DE5->DE5_SERTMS)
		If !Empty(DE5->DE5_SERVIC)
			If DC5->(dbSeek(xFilial('DC5')+DE5->DE5_SERVIC))
				cSerTms := DC5->DC5_SERTMS
			EndIf
		EndIf
	ElseIf cOrigem == "DF1"
		If DC5->(dbSeek(xFilial('DC5')+DF1->DF1_SERVIC))
			cSerTms := DC5->DC5_SERTMS
		EndIf
	EndIf

	If !Empty(DF1->DF1_FILDOC)
		cFilDT5 := IIf(Empty(cFilDT5), cFilDT5, DF1->DF1_FILDOC)
		cSeek   := cFilDT5+DF1->DF1_FILDOC+DF1->DF1_DOC
	Else
		cSeek   := cFilDT5+DF1->DF1_FILDOC+DF1->DF1_DOC
	EndIf

	If cOrigem == "DF1"
		// Valida o Status da Coleta
		DT5->(dbSetOrder(1))
		If DT5->(MsSeek(cSeek))
			lRet := VldStsCol(lTmsCFec,DC5->DC5_SERTMS,0,"","")
		EndIf
	EndIf

EndIf

If lRet .And. !Empty(cOrigem)

	If cOrigem == "DF1" .And. !Empty(DF1->DF1_CLIDEV)
		If DF1->DF1_CLIDEV == DF1->DF1_CLIREM
			cDevFre := '1'
		ElseIf DF1->DF1_CLIDEV == DF1->DF1_CLIDES
			cDevFre := '2'
		EndIf
	EndIf

	//preenchimento do cliente e loja remetente
	cCliRem  := Iif(cOrigem == "DF1",DF1->DF1_CLIREM,Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCREM,"A1_COD"))
	cLojRem  := Iif(cOrigem == "DF1",DF1->DF1_LOJREM,Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCREM,"A1_LOJA"))
	cCliDes  := Iif(cOrigem == "DF1",DF1->DF1_CLIDES,Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCDES,"A1_COD"))
	cLojDes  := Iif(cOrigem == "DF1",DF1->DF1_LOJDES,Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCDES,"A1_LOJA"))
	cSqEDes  := Iif(cOrigem == "DF1",DF1->DF1_SQEDES,Space(TamSX3("DF1_SQEDES")[1]))
	cServico := Iif(cOrigem == "DF1",DF1->DF1_SERVIC,DE5->DE5_SERVIC)
	cCodNeg  := Iif(cOrigem == "DF1",DF1->DF1_CODNEG,DE5->DE5_CODNEG)
	//utilizada logica do padrao para o preenchimento da regiao de calculo
	If cOrigem == "DE5"
		If !Empty(DE5->DE5_CGCDEV)
			cCliDev := Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCDEV,"A1_COD")
			cLojDev := Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCDEV,"A1_LOJA")
		Else
			cCliDev  := Posicione("SA1",3,xFilial("SA1") + IIf(cDevFre=='1',DE5->DE5_CGCREM,DE5->DE5_CGCDES),"A1_COD")
			cLojDev  := Posicione("SA1",3,xFilial("SA1") + IIf(cDevFre=='1',DE5->DE5_CGCREM,DE5->DE5_CGCDES),"A1_LOJA")
		EndIf
		cCdrDes := Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCDES,"A1_CDRDES")
		cCdrCal := TMSDestCal( cCliDev, cLojDev, cCdrDes )
		If Empty(cCdrCal)
			cCdrCal := cCdrDes
		EndIf
	ElseIf cOrigem == "DF1"
		cCdrDes := DF1->DF1_CDRDES
		cCliDev := DF1->DF1_CLIDEV
		cLojDev := DF1->DF1_LOJDEV
		If (DF1->DF1_CLIDEV + DF1->DF1_LOJDEV) != (DF1->DF1_CLIREM + DF1->DF1_LOJREM) .And. ;
		   (DF1->DF1_CLIDEV + DF1->DF1_LOJDEV) != (DF1->DF1_CLIDES + DF1->DF1_LOJDES)
			cCliCon := DF1->DF1_CLIDEV
			cLojCon := DF1->DF1_LOJDEV
			cDevFre := "3"
		EndIf
		cCdrCal := TMSDestCal( cCliDev, cLojDev, cCdrDes )
		If !Empty(cSqEDes)
			DUL->(DbSetOrder(2))
			If DUL->(DbSeek(xFilial("DUL") + DF1->DF1_CLIDES + DF1->DF1_LOJDES + cSqEDes))
				cCdrCal := DUL->DUL_CDRDES
			EndIf
		EndIf
		If Empty(cCdrCal)
			cCdrCal := cCdrDes
		EndIf
	EndIf

	If cOrigem == "DE5" .And. !Empty(cCliDev) .And. !Empty(cLojDev) .And. !Empty(DE5->DE5_CODNEG)
		aContrat := TMSContrat(cCliDev, cLojDev,,,.F., Iif(DE5->DE5_CGCDEV == DE5->DE5_CGCDES,'2','1'),,,,,,,,,,,,,,,,cCodNeg)
		If Len(aContrat) > 0
			cContrat := aContrat[1][1]
		EndIf
	EndIf

	cFilCfs := Iif(cOrigem == "DF1",DF1->DF1_FILDOC,cFilAnt)
	cNumSol := Iif(cOrigem == "DF1",DF1->DF1_DOC,"")

	If cOrigem == "DE5"
		If DE5->DE5_SELORI == "1" /*remetente*/
			cCdrOri := SuperGetMV("MV_CDRORI",.F.,.F.)
		ElseIf DE5->DE5_SELORI == "2"
			cCdrOri := Posicione("SA1",3,xFilial("SA1") + DE5->DE5_CGCREM,"A1_CDRDES")
		ElseIf DE5->DE5_SELORI == "3"
			Help("",1,"TMSA050T0",,"Seleção de Origem 'Local de Origem'. Porém, solicitação de coleta não encontrada. Será selecionada a Região de Origem da transportadora",5,1)
			cCdrOri := SuperGetMV("MV_CDRORI",.F.,.F.)
			cSelOri := "1"
		EndIf
	Else
		cCdrOri := DF1->DF1_CDRORI
	EndIf
	cServic := IIf(cOrigem == "DE5", DE5->DE5_SERVIC, DF1->DF1_SERVIC)

	//Preenche Cliente de Calculo
	DC5->(dbSetOrder(1))
	DC5->(MsSeek(xFilial("DC5")+cServic))
	If DC5->DC5_SEGPER == '1' // Servico tem 2o. Percurso
		//--Para segundo percurso, o Cliente de Calculo sera' o Remetente.
		cCdrCal := Iif(cOrigem == "DE5", DE5->DE5_CLIREM,DF1->DF1_CLIREM)
		cLojCal := Iif(cOrigem == "DE5", DE5->DE5_LOJREM,DF1->DF1_LOJREM)
	Else
		//-- Preenche os campos Cliente de Calculo e Loja do cliente de calculo.

		//-- Analisa a tabela de consignatarios.
		aCliCalc := {}
		//-- Se for 2o. Percurso, nao verificar a tabela de consignatarios
		If (lAlianca .And. TmsA050Dpc()) .Or. !lAlianca
			aCliCalc := TmsCliCalc( cCliRem, cLojRem, cCliDes, cLojDes )
		EndIf
		If Empty( aCliCalc )
			cCliCal := cCliDev
			cLojCal := cLojDev
		Else
			cCliCal := aCliCalc[ 1 ]
			cLojCal := aCliCalc[ 2 ]
		EndIf
	EndIf

	//------------------------------------------------------------------------------------------------
	//-- Início -> Valida A Vigência Do Contrato
	//------------------------------------------------------------------------------------------------
	If cOrigem == "DF1" .and. IsInCallStack("TMSAF76")

		cTipFre  := Iif(cOrigem == "DF1",DF1->DF1_TIPFRE,Iif(DE5->DE5_CGCDEV == DE5->DE5_CGCDES,'2','1'))
		cContrat := DF1->DF1_NCONTR

		//-- Utiliza Item De Contrato
        //-- Recalcula Contrato Pois Se estiver Inativo e/ou Fora Da Vigência Ele Não Retornará No Array
        aContrat := TMSContrat( cCliCal, cLojCal,,,.F., cTipFre,,,,,,,,,,,,,,,,cCodNeg )

        If Len(aContrat) > 0

            //-- Se Não For Mesmo Contrato Do DF1
            If aContrat[1][1] <> cContrat
                cContrat := aContrat[1][1]
                cCodNeg  := Space(TamSx3("DTC_CODNEG")[1])
                cServico := Space(TamSx3("DTC_SERVIC")[1])
            EndIf
        Else
            lSemCtr  := .T.
            cContrat := Space(TamSx3("DTC_NCONTR")[1])
            cCodNeg  := Space(TamSx3("DTC_CODNEG")[1])
            cServico := Space(TamSx3("DTC_SERVIC")[1])
        EndIf
	EndIf
	//------------------------------------------------------------------------------------------------
	//-- Fim    -> Valida A Vigência Do Contrato
	//------------------------------------------------------------------------------------------------

	//-- Carrega data e hora de entrega
	If cOrigem == "DF1" .And. TmsSobServ("TIPOPE",,.T.,DF1->DF1_NCONTR,DF1->DF1_CODNEG,DF1->DF1_SRVCOL,"0") $ "23"
		dDtEntr := dDataBase
		cHorEnt := SubStr(Time(),1,2) +  SubStr(Time(),4,2)
	EndIf

	aCabDTC := {{"DTC_FILIAL",xFilial("DTC"),Nil},;
				{"DTC_LOTNFC",TMS050Lot(cFilCfs,cNumSol,cNumLot, cCliDev, cLojDev),Nil},;
				{"DTC_FILORI",cFilAnt,Nil},;
				{"DTC_FILCFS",cFilCfs,Nil},;
				{"DTC_NUMSOL",cNumSol,Nil},;
				{"DTC_CLIREM",cCliRem,Nil},;
				{"DTC_LOJREM",cLojRem,Nil},;
				{"DTC_DATENT",dDataBase,Nil},;
				{"DTC_CLIDES",cCliDes,Nil},;
				{"DTC_LOJDES",cLojDes,Nil},;
				{"DTC_SQEDES",cSqEDes,Nil},;
				{"DTC_CLICON",cCliCon,Nil},;
				{"DTC_LOJCON",cLojCon,Nil},;
				{"DTC_CLIDEV",cCliDev,Nil},;
				{"DTC_LOJDEV",cLojDev,Nil},;
				{"DTC_NOMDEV",Posicione("SA1",1,xFilial("SA1") + cCliDev+cLojDev,"A1_NOME"),Nil},;
				{"DTC_DEVFRE",cDevFre,Nil},;
				{"DTC_CLICAL",cCliCal,Nil},;
				{"DTC_LOJCAL",cLojCal,Nil},;
				{"DTC_NOMCAL",Posicione("SA1",1,xFilial("SA1") + cCliCal+cLojCal,"A1_NOME"),Nil},;
				{"DTC_SERTMS",Iif(cOrigem == "DF1",cSerTMS, Iif(!Empty(DE5->DE5_SERTMS),DE5->DE5_SERTMS,cSerTms)),Nil},;
				{"DTC_CODNEG",cCodNeg,Nil},;
				{"DTC_SERVIC",cServico,Nil},;
				{"DTC_DESSER",(Posicione("SX5",1,xFilial('SX5')+'L4'+Iif(cOrigem == "DF1",DF1->DF1_SERVIC,DE5->DE5_SERVIC),"X5DESCRI()")),Nil},;
				{"DTC_TIPTRA",Iif(cOrigem == "DF1",DF1->DF1_TIPTRA,DE5->DE5_TIPTRA),Nil},;
				{"DTC_DESTPT",(TMSValField(IIf(cOrigem=='DF1',"DF1->DF1_TIPTRA","DE5->DE5_TIPTRA"),.F.,"DTC_DESTPT")),Nil},;
				{"DTC_TIPNFC",'0',Nil},;
				{"DTC_TIPFRE",Iif(cOrigem == "DF1",DF1->DF1_TIPFRE,Iif(DE5->DE5_CGCDEV == DE5->DE5_CGCDES,'2','1')),Nil},;
				{"DTC_SELORI",Iif(cOrigem == "DF1",DF1->DF1_SELORI,Iif(!Empty(cSelOri),cSelOri,DE5->DE5_SELORI)),Nil},;
				{"DTC_CDRORI",Iif(cOrigem == "DF1",cCdrOri,cCdrOri),Nil},;
				{"DTC_CDRDES",Iif(cOrigem == "DF1",cCdrDes,cCdrDes),Nil},;
				{"DTC_CDRCAL",Iif(cOrigem == "DF1",cCdrCal,cCdrCal),Nil},; //utilizada logica do padrao para o preenchimento da regiao de calculo
				{"DTC_DISTIV",Iif(cOrigem == "DF1",DF1->DF1_DISTIV,"3"),Nil},;
				Iif(DTC->(ColumnPos('DTC_NCONTR')) > 0 ,{"DTC_NCONTR",cContrat,Nil},),;
				{"DTC_PRVENT",Iif(cOrigem == "DF1",DF1->DF1_DATPRE,M->DTC_PRVENT),Nil},;
				{"DTC_PRHENT",Iif(cOrigem == "DF1",DF1->DF1_HORPRE,M->DTC_PRHENT),Nil},;
				{"DTC_KM"    ,Iif(cOrigem == "DF1",DF1->DF1_DISTAN,0),Nil},;
				{"DTC_DTENTR",dDtEntr,Nil},;
				{"DTC_HORENT",cHorEnt,Nil}}

	//-- Ponto de entrada para alterar os dados que serao herdados
	If lTMA050Fil
		aFilUsu := ExecBlock("TMA050Fil",.F.,.F.,{aCabDTC[18,2],aCabDTC[20,2],aCabDTC[22,2]})	//-- SERTMS / SERVIC / TIPTRA
		If ValType(aFilUsu) == "A" .And. Len(aFilUsu) == 4
			aCabDTC[18,2] := aFilUsu[1]
			aCabDTC[20,2] := aFilUsu[2]
			aCabDTC[22,2] := aFilUsu[3]
		EndIf
	EndIf

	If  !Empty(M->DTC_LOTNFC) .And. IsInCallStack("TMSAF76")
		Tmsa050RLt(M->DTC_FILORI,M->DTC_LOTNFC)
	EndIf

	If lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
		cDocTms := TmsTipDoc(cCdrOri,cCdrCal)
		AAdd(aCabDTC,{"DTC_DOCTMS", cDocTms, Nil}) // Adiciona o tipo do documento na DTC.
		AAdd(aCabDTC,{"DTC_DESDOC",TMSValField('cDocTms',.F.,"DTC_DESDOC",.F.,.F.),Nil})

	ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS)
		cDocTms := DC5->DC5_DOCTMS
		AAdd(aCabDTC,{"DTC_DOCTMS", cDocTms, Nil}) // Adiciona o tipo do documento na DTC.
		AAdd(aCabDTC,{"DTC_DESDOC",TMSValField('cDocTms',.F.,"DTC_DESDOC",.F.,.F.),Nil})
	EndIf

	If cOrigem == "DF1"
		DF2->(DbSetOrder(1))
		If DF2->(DbSeek(cSeekDF2 := xFilial("DF2") + DF1->(DF1_NUMAGE + DF1_ITEAGE)))
			cCodEmb := DF2->DF2_CODEMB
			cCodPro := DF2->DF2_CODPRO
			While (DF2->(!Eof())) .And. DF2->(DF2_FILIAL + DF2_NUMAGE + DF2_ITEAGE) == cSeekDF2
				nQtdVol += DF2->DF2_QTDVOL
				nPeso   += DF2->DF2_PESO
				nPesoM3 += DF2->DF2_PESOM3
				nValMer += DF2->DF2_VALMER
				nBasSeg += DF2->DF2_BASSEG
				nQtdUni += DF2->DF2_QTDUNI
				DF2->(DbSkip())
			EndDo
		EndIf
	ElseIf cOrigem == "DE5"
		nQtdVol := DE5->DE5_QTDVOL
		nPeso   := DE5->DE5_PESO
		nPesoM3 := DE5->DE5_PESOM3
		nValMer := DE5->DE5_VALOR
		nBasSeg := DE5->DE5_VALSEG
		cCodPro := DE5->DE5_CODPRO
		cCodEmb := DE5->DE5_CODEMB
	EndIf

	cAliasDUA := GetNextAlias()
	cQuery := "SELECT DUA_QTDOCO,DUA_PESOCO,DUA_VLROCO,DUA_PM3OCO,DUA_QTUOCO,DUA_BASOCO "
	cQuery += "  FROM " + RetSqlName("DUA") + " DUA "
	cQuery += "  JOIN " + RetSqlName("DT2") + " DT2 "
	cQuery += "    ON DT2_FILIAL = '" + xFilial("DT2") + "' "
	cQuery += "   AND DT2_CODOCO = DUA_CODOCO "
	cQuery += "   AND DT2_TIPOCO = '" + StrZero(1,TamSX3("DT2_TIPOCO")[1]) + "' "
	cquery += "   AND DT2_SERTMS = '1' "
	cQuery += "   AND DT2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
	cQuery += "   AND DUA_FILDOC = '" + cFilCfs + "' "
	cQuery += "   AND DUA_DOC    = '" + cNumSol + "' "
	cQuery += "   AND DUA_SERIE  = 'COL' "
	cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUA,.T.,.T.)
	TCSetField(cAliasDUA,"DUA_QTDOCO","N",TamSx3("DUA_QTDOCO")[1],TamSx3("DUA_QTDOCO")[2])
	TCSetField(cAliasDUA,"DUA_PESOCO","N",TamSx3("DUA_PESOCO")[1],TamSx3("DUA_PESOCO")[2])
	TCSetField(cAliasDUA,"DUA_VLROCO","N",TamSx3("DUA_VLROCO")[1],TamSx3("DUA_VLROCO")[2])
	TCSetField(cAliasDUA,"DUA_PM3OCO","N",TamSx3("DUA_PM3OCO")[1],TamSx3("DUA_PM3OCO")[2])
	TCSetField(cAliasDUA,"DUA_QTUOCO","N",TamSx3("DUA_QTUOCO")[1],TamSx3("DUA_QTUOCO")[2])
	TCSetField(cAliasDUA,"DUA_BASOCO","N",TamSx3("DUA_BASOCO")[1],TamSx3("DUA_BASOCO")[2])
	If (cAliasDUA)->(!Eof())
		Iif((cAliasDUA)->DUA_QTDOCO > 0,nQtdVol := (cAliasDUA)->DUA_QTDOCO,)
		Iif((cAliasDUA)->DUA_PESOCO > 0,nPeso   := (cAliasDUA)->DUA_PESOCO,)
		Iif((cAliasDUA)->DUA_PM3OCO > 0,nPesoM3 := (cAliasDUA)->DUA_PM3OCO,)
		Iif((cAliasDUA)->DUA_VLROCO > 0,nValMer := (cAliasDUA)->DUA_VLROCO,)
		Iif((cAliasDUA)->DUA_BASOCO > 0,nBasSeg := (cAliasDUA)->DUA_BASOCO,)
		Iif((cAliasDUA)->DUA_QTUOCO > 0,nQtdUni := (cAliasDUA)->DUA_QTUOCO,)
	EndIF
	(cAliasDUA)->(DbCloseArea())
	DbSelectArea("DTC")

	aItem :=   {{"DTC_NUMNFC",Iif(cOrigem == "DE5",DE5->DE5_DOC,''),Nil},;
				{"DTC_SERNFC",Iif(cOrigem == "DE5",DE5->DE5_SERIE,''),Nil},;
				{"DTC_CODPRO",cCodPro,Nil},;
				{"DTC_CODEMB",cCodEmb,Nil},;
				{"DTC_EMINFC",Iif(cOrigem == "DE5",DE5->DE5_EMINFC,CToD('')),Nil},;
				{"DTC_QTDVOL",nQtdVol,Nil},;
				{"DTC_PESO"  ,nPeso,Nil},;
				{"DTC_PESOM3",nPesoM3,Nil},;
				{"DTC_VALOR" ,nValMer,Nil},;
				{"DTC_BASSEG",nBasSeg,Nil},;
				{"DTC_QTDUNI",nQtdUni,Nil},;
				{"DTC_EDI"   ,'',Nil},;
				{"DTC_NFEID",If (cOrigem == "DE5",DE5->DE5_NFEID,''), Nil}}

	AAdd(aItemDTC,aClone(aItem))

	If !Empty(aCabDTC)
		aHeader := AClone(aCabDTC)
		aCols	  := AClone(aItemDTC)
		//Inicializa Variveis para retornar o Cliente de Calculo
		RegToMemory('DTC',.T.)
		M->DTC_KM     := 0
		nPosDevFre := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_DEVFRE"})
		nPosCliRem := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_CLIREM"})
		nPosLojRem := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_LOJREM"})
		nPosCliDev := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_CLIDEV"})
		nPosLojDev := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_LOJDEV"})
		nPosCliCon := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_CLICON"})
		nPosLojCon := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_LOJCON"})
		nPosCliCal := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_CLICAL"})
		nPosLojCal := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_LOJCAL"})
		nPosNomCal := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_NOMCAL"})
		nPosCliDes := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_CLIDES"})
		nPosLojDes := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_LOJDES"})
		nPosTipFre := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_TIPFRE"})
		nPosServic := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_SERVIC"})
		nPosNeg	 := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_CODNEG"})
		nPosNumSol := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_NUMSOL"})
		nPosFilCfs := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_FILCFS"})
		nPosLotnfc := Ascan(aHeader,{|x| AllTrim(Upper(x[1])) == "DTC_LOTNFC"})
		M->DTC_DEVFRE := aHeader[nPosDevFre,2]
		M->DTC_CLIREM := aHeader[nPosCliRem,2]
		M->DTC_LOJREM := aHeader[nPosLojRem,2]
		M->DTC_CLIDEV := aHeader[nPosCliDev,2]
		M->DTC_LOJDEV := aHeader[nPosLojDev,2]
		M->DTC_CLICON := aHeader[nPosCliCon,2]
		M->DTC_LOJCON := aHeader[nPosLojCon,2]
		M->DTC_CLIDES := aHeader[nPosCliDes,2]
		M->DTC_LOJDES := aHeader[nPosLojDes,2]
		M->DTC_TIPFRE := aHeader[nPosTipFre,2]
		M->DTC_SERVIC := aHeader[nPosServic,2]
		M->DTC_NUMSOL := aHeader[nPosNumSol,2]
		M->DTC_FILCFS := aHeader[nPosFilCfs,2]
		M->DTC_LOTNFC := aHeader[nPosLotnfc,2]
        M->DTC_CODNEG := aHeader[nPosNeg,2]
		TMSA050Fre()
		aCabDTC[nPosCliCal,2] := cCliCal
		aCabDTC[nPosLojCal,2] := cLojCal
		aCabDTC[nPosNomCal,2] := Posicione('SA1',1,xFilial('SA1')+M->DTC_CLICAL+M->DTC_LOJCAL,'A1_NOME')
		aRet := {aCabDTC,aItemDTC,lRet}
		lEdita := .F.
		If Empty(M->DTC_SERVIC)
			lEditaServ := .T.
		EndIf
	Else
		lEdita := .T.
		lEditaServ := .T.
	EndIf
ElseIf !Empty(cCodBar)
	If Empty(cOrigem)
		Help("",1,"TMSA050B2")  //--  Código de Barras não encontrado nas tabelas  de Documentos de Transporte(DT6)  e EDI - Notas Fiscais(DE5).
	EndIf
	aRet := TMS050AFIL()
Else
	lEdita := .T.
	lEditaServ := .T.
	aRet := {,,lRet}
EndIf

AEval(aAreas,{|x| RestArea(x) })

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS050CBar³ Autor ³Izac Silvério Ciszevski³ Data ³ 01/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abre interface para codigo de barras da DANFE/Coleta        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMS050CBar()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMS050CBar()
Local cCodbar := Space(TamSX3("DTC_NFEID")[1])
Local oGetBar
Local oDlgBar

DEFINE DIALOG oDlgBar FROM 0,0 TO 120,400 TITLE STR0115 Of oMainWnd PIXEL       //Leitura do Codigo de Barras

@ 16,10 SAY STR0116 Of oDlgBar PIXEL SIZE 100,10 //--"Informe o código de barras"
@ 26,10 MSGET oGetBar VAR cCodbar SIZE 140,10 Picture '@!' VALID (oDlgBar:End()) PIXEL
@ 25,11 MSGET oGetBar VAR cCodbar SIZE 1,1 //-- campo para mudança de foco e execução do valid

ACTIVATE DIALOG oDlgBar CENTERED VALID(Iif(oDlgBar:WindowState() == 2,(cCodbar == '',.T.),.T.))

cCodbar:= Upper(AllTrim(cCodBar))

Return cCodBar

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM050GerAg ³ Autor ³Valdemar Roberto       ³ Data ³ 21/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Agendamento e Solicitacao de Coleta                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMS050Ger()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TM050GerAg(cSrv,cSrvCol)
Local aAreas   := {SA1->(GetArea()),DUE->(GetArea()),GetArea()}
Local aCab     := {}
Local aItens   := {}
Local aProds   := {}
Local aRotBak  := {}
Local cCodCli  := ""
Local cLojCli  := ""
Local cUltSeq  := ""
Local cSeqEnd  := ""
Local cCodEmb  := GdFieldGet("DTC_CODEMB",1)
Local nCntFor1 := 0
Local nPos     := 0
Local lIncBak  := .T.
Local lAltBak  := .T.
Local lContinua:= .T.
Local cCodSol  := ""
Local lTemDUE  := .F.
Local lRet     := .T.
Local lIdentDoc := DTC->(ColumnPos("DTC_DOCTMS")) > 0
Private aPanAgeTms := Array(6)
Default cSrv		:= ""
Default cSrvCol	:= ""

//-- Acumula Totais por Nota/Serie/Produto
For nCntFor1 := 1 To Len(aCols)
	If (nPos := Ascan(aProds, {|x| x[1] + x[2] + x[3] == GdFieldGet("DTC_NUMNFC",1) + GdFieldGet("DTC_SERNFC",1) + GdFieldGet("DTC_CODPRO",1) })) == 0
		Aadd(aProds,{"","","",0,0,0,0,0,0,0})
		nPos := Len(aProds)
	EndIf
	aProds[nPos, 1] := GdFieldGet("DTC_NUMNFC",nCntFor1)
	aProds[nPos, 2] := GdFieldGet("DTC_SERNFC",nCntFor1)
	aProds[nPos, 3] := GdFieldGet("DTC_CODPRO",nCntFor1)
	aProds[nPos, 4] += GdFieldGet("DTC_QTDVOL",nCntFor1)
	aProds[nPos, 5] += GdFieldGet("DTC_QTDUNI",nCntFor1)
	aProds[nPos, 6] += GdFieldGet("DTC_PESO",nCntFor1)
	aProds[nPos, 7] += GdFieldGet("DTC_PESOM3",nCntFor1)
	aProds[nPos, 8] += GdFieldGet("DTC_VALOR",nCntFor1)
	aProds[nPos, 9] += GdFieldGet("DTC_BASSEG",nCntFor1)
	aProds[nPos,10] += GdFieldGet("DTC_METRO3",nCntFor1)
Next nCntFor1

//-- Verifica/Gera Solicitante
cCodCli := M->DTC_CLIDEV
cLojCli := M->DTC_LOJDEV

DUE->(DbSetOrder(3))
If !DUE->(DbSeek(xFilial("DUE") + cCodCli + cLojCli))
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojCli))
		//-- Le proximo codigo de solicitante disponivel
		cCodSol := GETSXENUM("DUE","DUE_CODSOL")
		ConfirmSX8()
		//-- Cabecalho do Solicitante
		RecLock("DUE",.T.)
		DUE->DUE_FILIAL := xFilial("DUE")
		DUE->DUE_DDD    := SA1->A1_DDD
		DUE->DUE_TEL    := SA1->A1_TEL
		DUE->DUE_CODCLI := SA1->A1_COD
		DUE->DUE_LOJCLI := SA1->A1_LOJA
		DUE->DUE_NOME   := SA1->A1_NOME
		DUE->DUE_NREDUZ := SA1->A1_NREDUZ
		DUE->DUE_END    := SA1->A1_END
		DUE->DUE_EST    := SA1->A1_EST
		DUE->DUE_CODMUN := SA1->A1_COD_MUN
		DUE->DUE_MUN    := SA1->A1_MUN
		DUE->DUE_BAIRRO := SA1->A1_BAIRRO
		DUE->DUE_CEP    := SA1->A1_CEP
		DUE->DUE_CGC    := SA1->A1_CGC
		DUE->DUE_INSCR  := SA1->A1_INSCR
		DUE->DUE_CONTAT := SA1->A1_CONTATO
		DUE->DUE_EMAIL  := SA1->A1_EMAIL
		DUE->DUE_DATCAD := dDataBase
		DUE->DUE_TIPTRA := StrZero(1,Len(DUE->DUE_TIPTRA))
		DUE->DUE_TIPCOL := StrZero(1,Len(DUE->DUE_TIPCOL))
		DUE->DUE_COLSEG := StrZero(2,Len(DUE->DUE_COLSEG))
		DUE->DUE_COLTER := StrZero(2,Len(DUE->DUE_COLTER))
		DUE->DUE_COLQUA := StrZero(2,Len(DUE->DUE_COLQUA))
		DUE->DUE_COLQUI := StrZero(2,Len(DUE->DUE_COLQUI))
		DUE->DUE_COLSEX := StrZero(2,Len(DUE->DUE_COLSEX))
		DUE->DUE_COLSAB := StrZero(2,Len(DUE->DUE_COLSAB))
		DUE->DUE_COLDOM := StrZero(2,Len(DUE->DUE_COLDOM))
		DUE->DUE_CDRSOL := SA1->A1_CDRDES
		DUE->DUE_CADPOR := StrZero(2,Len(DUE->DUE_CADPOR))
		DUE->DUE_CODSOL := cCodSol
		DUE->(MsUnlock())
		lTemDUE := .T.
		//-- Itens do Solicitante
		RecLock("DVJ",.T.)
		DVJ->DVJ_FILIAL := xFilial("DVJ")
		DVJ->DVJ_DDD    := SA1->A1_DDD
		DVJ->DVJ_TEL    := SA1->A1_TEL
		DVJ->DVJ_CODPRO := aProds[1,3]
		DVJ->DVJ_CODEMB := cCodEmb
		DVJ->DVJ_CODSOL := cCodSol
		DVJ->(MsUnlock())
	EndIf
Else
	cCodSol := DUE->DUE_CODSOL
	lTemDUE := .T.
EndIf

If lTemDUE
	If !Empty(M->DTC_SQEDES)
		//-- Verifica/Gera Endereco do Solicitante
		cUltSeq := "00"
		DUL->(DbSetOrder(3))
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojCli))
		If DUL->(DbSeek(xFilial("DUL") + DUE->DUE_CODSOL))
			Do While xFilial("DUL") + DUE->DUE_CODSOL == DUL->(DUL_FILIAL + DUL_CODSOL)
				If AllTrim(DUL->DUL_END) == AllTrim(SA1->A1_END) .And. AllTrim(DUL->DUL_BAIRRO) == AllTrim(SA1->A1_BAIRRO) .And. ;
					AllTrim(DUL->DUL_MUN) == AllTrim(SA1->A1_MUN) .And. AllTrim(DUL->DUL_EST) == AllTrim(SA1->A1_EST) .And. ;
					AllTrim(DUL->DUL_CEP) == AllTrim(SA1->A1_CEP) .And. AllTrim(DUL->DUL_CDRDES) == AllTrim(SA1->A1_CDRDES) .And. ;
					AllTrim(DUL->DUL_CODMUN) == AllTrim(SA1->A1_COD_MUN)
					cSeqEnd := DUL->DUL_SEQEND
					Exit
				EndIf
			DUL->(DbSkip())
			EndDo
		EndIf

		If Empty(cSeqEnd) .And. !Empty(M->DTC_SQEDES)
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojCli))
				RecLock("DUL",.T.)
				DUL->DUL_FILIAL := xFilial("DUL")
				DUL->DUL_DDD    := SA1->A1_DDD
				DUL->DUL_TEL    := SA1->A1_TEL
				DUL->DUL_CODCLI := SA1->A1_COD
				DUL->DUL_LOJCLI := SA1->A1_LOJA
				DUL->DUL_SEQEND := GETSXENUM("DUL","DUL_SEQEND")
				DUL->DUL_END    := SA1->A1_END
				DUL->DUL_BAIRRO := SA1->A1_BAIRRO
				DUL->DUL_MUN    := SA1->A1_MUN
				DUL->DUL_EST    := SA1->A1_EST
				DUL->DUL_CEP    := SA1->A1_CEP
				DUL->DUL_CODMUN := SA1->A1_COD_MUN
				DUL->DUL_CDRDES := SA1->A1_CDRDES
				DUL->DUL_TDA    := StrZero(2,Len(DUL->DUL_TDA))
				DUL_INSCR       := SA1->A1_INSCR
				DUL->DUL_CGC    := SA1->A1_CGC
				DUL->DUL_CODSOL := cCodSol
				DUL->(MsUnlock())
				cSeqEnd := DUL->DUL_SEQEND
			EndIf
		EndIf
	EndIf

	//-- Confirma Agendamento Gerando DT5, DUM e DT6
	aPanAgeTms[1] := "DF0"
	aPanAgeTms[2] := DF0->(Recno())
	aPanAgeTms[3] := 6
	aPanAgeTms[6] := "TMSF05Mnt"



	//-- Cria agendamento
	aVetDF0 := {DUE->DUE_DDD,DUE->DUE_TEL,DUE->DUE_CODSOL}
	aVetDF1 := {M->DTC_CLIREM,M->DTC_LOJREM,M->DTC_TIPTRA,M->DTC_SELORI,M->DTC_CDRORI,M->DTC_CLIDES,M->DTC_LOJDES,M->DTC_CDRDES,M->DTC_TIPFRE,;
				M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_NCONTR,M->DTC_CODNEG,cSrv,cSrvCol,,M->DTC_SQEDES,M->DTC_DOCTMS}
	TM050GrvAg(@aPanAgeTms,aProds,aVetDF0,aVetDF1,cCodEmb,cSeqEnd,.T.)

	//-- Confirma Agendamento Gerando DT5, DUM e DT6
	aRotBak := Aclone(aRotina)
	lIncBak := INCLUI
	lAltBak := ALTERA

	INCLUI  := .F.
	ALTERA  := .F.



Else
	Help("",1,"TMSA050A6")  //-- Está configurado que seja gerado agendamento para nota fiscal balcão, e não foi possível definir o solicitante. A nota fiscal não será gravada.
	lRet := .F.
EndIf

aRotina := Aclone(aRotBak)
INCLUI := lIncBak
ALTERA := lAltBak

AEval(aAreas,{|x,y| RestArea(x) })

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050Cor ³ Autor ³Leandro Paulino       ³ Data ³ 24/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cores disponíveis no Browse da Rotina Entrada.Dc.Cliente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMS050Cor()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSA050Cor()

Local aCores := {}

	Aadd(aCores,{"TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='1'",'BR_AMARELO'	})		// Aberto
	Aadd(aCores,{"TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='2'",'BR_VERDE'	})		// Digitado
	Aadd(aCores,{"TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='3'",'BR_AZUL'		})		// Calculado
	Aadd(aCores,{"TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='4'",'BR_VERMELHO'})		// Bloqueado
	Aadd(aCores,{"TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='5'",'BR_LARANJA' })		// Erro de Gravacao

	If ExistBlock("TMA050COR")
	aRet := ExecBlock("TMA050COR",.F.,.F., {aCores})
		If ValType(aRet) == "A" .And. !Empty(aRet)
			aCores := aClone(aRet)
		EndIf
	EndIf

Return aCores
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM050GrvAg ³ Autor ³Valdemar Roberto      ³ Data ³ 23/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava o Agendamento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM050GrvAg(aExp01,aExp02,aExp03,aExp04,cExp01,cExp02,lExp01)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor utilizado no inicio das funcionalidades    ³±±
±±³          ³           que estao nas abas do agendamento                ³±±
±±³          ³ aExp02 := Vetor com os produtos da solicitacao de coletas  ³±±
±±³          ³ aExp03 := Vetor com os dados da DF0                        ³±±
±±³          ³ aExp04 := Vetor com os dados da DF1                        ³±±
±±³          ³ cExp01 := Codigo da embalagem                              ³±±
±±³          ³ cExp02 := Sequencia de endereco                            ³±±
±±³          ³ lExp01 := Indica se eh nota balcao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TM050GrvAg(aPanAgeTms,aProds,aVetDF0,aVetDF1,cCodEmb,cSeqEnd,lBalcao,cTipNFC,cDocTMS)
Local lContinua 	:= .T.
Local cNumAge   	:= ""
Local nCntFor1  	:= 0
Local aAreas		:= {DC5->(GetArea()),DTC->(GetArea()),DF1->(GetArea()),DF2->(GetArea()),DE5->(GetArea()),DT6->(GetArea()),SA1->(GetArea()),DT5->(GetArea()),GetArea()}
Local lSolColMan	:= DF1->(ColumnPos("DF1_SCOMAN")) > 0
Local lServCol		:= DF1->(ColumnPos("DF1_SRVCOL")) > 0
Local aCabec		:= {}
Local aItens		:= {}
Local cNumSol		:= ""
Local lIdentDoc		:= DF1->(ColumnPos("DF1_DOCTMS")) > 0

Private lMsErroAuto := .F.

DEFAULT aPanAgeTms 	:= Array(6)
DEFAULT aProds     	:= {}
DEFAULT aVetDF0    	:= Array(3)
DEFAULT aVetDF1    	:= Array(11)
DEFAULT cCodEmb    	:= ""
DEFAULT cSeqEnd    	:= ""
DEFAULT lBalcao    	:= .F.

//-- Gera DF0
dbSelectArea("DF0")
dbSetOrder(1)

While lContinua
	cNumAge := CriaVar("DF0_NUMAGE",.T.)
	If DF0->( MsSeek(xFilial("DF0") + cNumage) )
		If __lSX8
			ConfirmSX8()
			lContinua := .T.
		EndIf
	Else
		lContinua := .F.
	EndIf
EndDo

RecLock("DF0",.T.)
DF0->DF0_FILIAL := xFilial("DF0")
DF0->DF0_NUMAGE := cNumAge
M->DF0_NUMAGE := cNumAge
DF0->DF0_DDD    := aVetDF0[1]
DF0->DF0_TEL    := aVetDF0[2]
DF0->DF0_SEQEND := cSeqEnd
DF0->DF0_QTDITE := 1
DF0->DF0_QTDCON := 1
DF0->DF0_DATCAD := dDataBase
DF0->DF0_DATCAN := CToD("  /  /  ")
DF0->DF0_STATUS := StrZero(3,Len(DF0->DF0_STATUS))
DF0->DF0_TIPDIS := StrZero(1,Len(DF0->DF0_TIPDIS))
DF0->DF0_INIDIS := StrZero(1,Len(DF0->DF0_INIDIS))
DF0->DF0_DISTIV := StrZero(2,Len(DF0->DF0_DISTIV))
DF0->DF0_CODSOL := aVetDF0[3]
DF0->(MsUnlock())

//-- Confirma numero do agendamento
If __lSX8
	ConfirmSX8()
EndIf

//-- Confirma Agendamento Gerando DT5, DUM e DT6
aPanAgeTms[1] := "DF0"
aPanAgeTms[2] := DF0->(Recno())
aPanAgeTms[3] := 6
aPanAgeTms[6] := "TMSF05Mnt"

RecLock("DF1",.T.)
DF1->DF1_FILIAL := xFilial("DF1")
DF1->DF1_NUMAGE := DF0->DF0_NUMAGE
DF1->DF1_ITEAGE := StrZero(1,Len(DF1->DF1_ITEAGE))
DF1->DF1_STACOL := StrZero(2,Len(DF1->DF1_STACOL))
DF1->DF1_STAENT := StrZero(1,Len(DF1->DF1_STAENT))
DF1->DF1_LOCCOL := StrZero(2,Len(DF1->DF1_LOCCOL))
DF1->DF1_FILORI := cFilAnt
DF1->DF1_CLIREM := aVetDF1[01]
DF1->DF1_LOJREM := aVetDF1[02]
DF1->DF1_SQEREM := Iif(Len(aVetDF1) >= 16,aVetDF1[16],"") //| Seq.Endereço - Remetente
DF1->DF1_TIPTRA := aVetDF1[03]
DF1->DF1_SELORI := aVetDF1[04]
DF1->DF1_CDRORI := aVetDF1[05]
DF1->DF1_CLIDES := aVetDF1[06]
DF1->DF1_LOJDES := aVetDF1[07]
DF1->DF1_SQEDES := Iif(Len(aVetDF1) >= 17,aVetDF1[17],"") //| Seq.Endereço - Destinatario
DF1->DF1_CDRDES := aVetDF1[08]
DF1->DF1_TIPFRE := aVetDF1[09]
DF1->DF1_CLIDEV := aVetDF1[10]
DF1->DF1_LOJDEV := aVetDF1[11]
DF1->DF1_NCONTR := aVetDF1[12]
DF1->DF1_CODNEG := aVetDF1[13]
DF1->DF1_SERVIC := If(!Empty(aVetDF1[14]),aVetDF1[14],"")
If lServCol
	DF1->DF1_SRVCOL := aVetDF1[15]
EndIf

If lIdentDoc .And. Len(aVetDF1) > 17
	DF1->DF1_DOCTMS := aVetDF1[18]
EndIf
DF1->DF1_SEQUEN := StrZero(1,Len(DF1->DF1_SEQUEN))
DF1->DF1_DISTIV := StrZero(2,Len(DF1->DF1_DISTIV))
DF1->DF1_DATPRC := dDataBase
DF1->DF1_HORPRC := SubStr(Time(),1,2) + SubStr(Time(),4,2)
DF1->DF1_NFBALC := Iif(lBalcao,"1","2")
If lSolColMan
	If IsInCallStack("TMSA460Grava")
		DF1->DF1_SCOMAN := "1"
	Else
		DF1->DF1_SCOMAN := "2"
	EndIf
EndIf
If IsInCallStack("TMSAF76")
	DF1->DF1_MRKPAN := cNumThread
EndIf
DF1->DF1_TIPNFC := cTipNFC
DF1->DF1_DOCTMS := cDocTms
DF1->(MsUnlock())

//permite manipular campos específicos do agendamento gerado
	If lTM050DF1

		ExecBlock("TM050DF1",.F.,.F.,{DF1->DF1_NUMAGE,DF1->DF1_ITEAGE})

	Endif
//-- Gera DF2
For nCntFor1 := 1 To Len(aProds)
	RecLock("DF2",.T.)
	DF2->DF2_FILIAL := xFilial("DF2")
	DF2->DF2_NUMAGE := DF1->DF1_NUMAGE
	DF2->DF2_ITEAGE := DF1->DF1_ITEAGE
	DF2->DF2_CODPRO := aProds[nCntFor1,3]
	DF2->DF2_CODEMB := cCodEmb
	DF2->DF2_QTDVOL := aProds[nCntFor1,4]
	DF2->DF2_QTDUNI := aProds[nCntFor1,5]
	DF2->DF2_PESO   := aProds[nCntFor1,6]
	DF2->DF2_PESOM3 := aProds[nCntFor1,7]
	DF2->DF2_VALMER := aProds[nCntFor1,8]
	DF2->DF2_BASSEG := aProds[nCntFor1,9]
	DF2->DF2_METRO3 := aProds[nCntFor1,10]
	DF2->(MsUnlock())
Next nCntFor1

If !(Type("aRotina") == "A")
	aRotina := {}
EndIf
If !(Type("ALTERA") == "L")
	ALTERA := .F.
EndIf

aRotBak := Aclone(aRotina)
lIncBak := INCLUI
lAltBak := ALTERA

INCLUI  := .F.
ALTERA  := .F.

If !IsInCallStack("Tmsaf05grv")
	TMSF05Mnt("DF0",DF0->(RECNO()),6,.F.)
EndIf

M->DTC_FILCFS := DF1->DF1_FILDOC
M->DTC_NUMSOL := DF1->DF1_DOC
M->DTC_NUMAGD := DF1->DF1_NUMAGE
M->DTC_ITEAGD := DF1->DF1_ITEAGE
If !Empty(DF1->DF1_DOC)
	M->DTC_DATCOL := dDataBase
	M->DTC_HORCOL := SubStr(Time(),1,2) + SubStr(Time(),4,2)
EndIf

//Deixa o Status da coleta no agendamento como cancelado.
RecLock("DF1",.F.)
DF1->DF1_FILIAL := xFilial("DF1")
If lBalcao
   DF1->DF1_STACOL := StrZero(9,Len(DF1->DF1_STACOL))
EndIf
DF1->DF1_FILDOC := DT5->DT5_FILORI
DF1->DF1_DOC    := DT5->DT5_NUMSOL
DF1->DF1_SERIE  := "COL"
DF1->(MsUnLock())

aRotina := Aclone(aRotBak)
INCLUI := lIncBak
ALTERA := lAltBak

AEval(aAreas,{|x,y| RestArea(x) })

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMS050FecL()
Verifica se deve realizar o fechamento do lote
de agendamento.
Uso: TMSA050

@sample

@author Rafael dos Santos Souza
@since 07/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMS050Fecl(nOpcx)

Local aAreas		:= {DTC->(GetArea()),DUD->(GetArea()),DTQ->(GetArea()),DTP->(GetArea()),GetArea()}
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()
Local cAliasDTC		:= GetNextAlias()
Local lAbort		:= .F.
Local nQtdLot		:= 0
Local cTipoOper		:= "0"	// DDA_TIPOPE ou DDC_TIPOPE
Local lPergCalc		:= .F.	// Pergunta se faz o cálculo automático (F12 do TMSA200)
Local aContrat	    	:= TMSContrat(M->DTC_CLICAL, M->DTC_LOJCAL,,,, M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)

Pergunte('TMB200', .F.)
lPergCalc := mv_par07 == 1

If nOpcx == 3 .And. !IsInCallStack("TMSF76VIA") .And. IsInCallStack("TMSAF76") .And. !Empty(DTP->DTP_VIACOL)
	DTQ->(DbSelectArea("DTQ"))
	DTQ->(DbSetOrder(2))
	DTQ->(DbSeek(xFilial("DTQ") + DTP->DTP_FILORI + DTP->DTP_VIACOL))

	//| Se a Viagem foi cancelada durante a digitação da NF sera considerado apenas a quantidade
	//| digitada para que o lote fique com o STATUS = 'DIGITADO'.
	If DTQ->DTQ_STATUS == StrZero(9,TamSx3('DTQ_STATUS')[1])
		nQtdLot := Len(aCols)
	EndIF

	//-- Pega toda movimentação dos documentos da viagem de Coleta
	cQuery := " SELECT DUD.R_E_C_N_O_ AS DUDRECNO "
	cQuery += " FROM " + RetSqlName("DUD") + " DUD "
	cQuery += " INNER JOIN " + RetSqlName("DT5") + " DT5 "
	cQuery += " ON  DT5_FILIAL = '" + xFilial("DT5") + "'"
	cQuery += " AND DT5_FILORI = DUD_FILDOC "
	cQuery += " AND DT5_NUMSOL = DUD_DOC "
	cQuery += " AND DT5.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " DUD.DUD_FILIAL = '"      + xFilial("DUD")  + "' "
	cQuery += " AND	DUD.DUD_FILORI 	= '" + DTP->DTP_FILORI + "' "
	cQuery += " AND	DUD.DUD_VIAGEM	= '" + DTP->DTP_VIACOL + "' "
	cQuery += " AND	DUD.DUD_SERIE	= 'COL' "
	cQuery += " AND	DUD.DUD_STATUS	!= '9' "
	cQuery += " AND	DUD.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND	DT5.DT5_CLIDEV = '"	+ M->DTC_CLIDEV + "' "
	cQuery += " AND	DT5.DT5_LOJDEV = '"	+ M->DTC_LOJDEV + "' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	If (cAliasQry)->(!Eof())
		While !lAbort .And. (cAliasQry)->(!Eof())
			DUD->(DbGoTo((cAliasQry)->DUDRECNO))

			cQuery := " SELECT DTC_SERVIC SERVICO, DTC_CLIDEV, DTC_LOJDEV"
			cQuery += " FROM "+RetSqlName("DTC")+ " DTC "
			cQuery += " WHERE "
			cQuery += " DTC.DTC_FILIAL = '"+xFilial("DTC")+"' "
			cQuery += " AND DTC.D_E_L_E_T_ = ' ' "
			cQuery += " AND DTC.DTC_FILCFS = '" + DUD->DUD_FILDOC + "' "
			cQuery += " AND DTC.DTC_NUMSOL = '" + DUD->DUD_DOC    + "' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

			If (cAliasDTC)->(!Eof())
				While (cAliasDTC)->(!Eof())
					nQtdLot ++
					(cAliasDTC)->(DbSkip())
				EndDo
			Else
				lAbort := .T.
			EndIf
			(cAliasDTC)->(DbCloseArea())

			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasQry)->(DbCloseArea())

	DTP->(dbSetOrder(2))
	If DTP->(MsSeek(xFilial("DTP") + M->DTC_FILORI + M->DTC_LOTNFC))
		RecLock("DTP",.F.)
		DTP->DTP_QTDDIG	:= nQtdLot
		DTP->(MsUnLock())

		If !lAbort .And. nQtdLot > 0

			RecLock("DTP",.F.)
			DTP->DTP_QTDLOT := nQtdLot
			DTP->DTP_STATUS := "2"
			DTP->(MsUnLock())

			cTipoOper := aContrat[1][43][1][20]	// DDA_TIPOPE
			If cTipoOper == "0"
				cTipoOper := aContrat[1][44][1][8]	// DDC_TIPOPE
			EndIf

			// Cálculo automático - Desconsidera o rateio do lote se o tipo de operação for "Coleta c/ Entrega"
			If nQtdLot != 0 .And. (DTP->DTP_RATEIO != "1" .OR. cTipoOper == "2")
				If lPergCalc
					If MsgYesNo(STR0151) // O lote de digitação de notas fiscais foi fechado automaticamente. Deseja calculá-lo agora?
						TMSA200Mnt("DTP",DTP->(Recno()),2,,.F.)
					EndIf
				Else
					TMSA200Mnt("DTP",DTP->(Recno()),2,,.F.)
				EndIf
			Endif
		EndIf
	EndIf
ElseIf nOpcx == 3
	//-- Lote para Nota Fiscal Balcão
	cQuery := " SELECT SUM(1) AS QTDLOT"
	cQuery += " FROM "+RetSqlName("DTC")+ " DTC "
	cQuery += " WHERE "
	cQuery += " DTC.DTC_FILIAL = '"+xFilial("DTC")+"' "
	cQuery += " AND DTC.D_E_L_E_T_ = ' ' "
	cQuery += " AND DTC.DTC_FILORI = '" + M->DTC_FILORI + "' "
	cQuery += " AND DTC.DTC_LOTNFC = '" + M->DTC_LOTNFC + "' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

	If (cAliasDTC)->(!Eof())
		While (cAliasDTC)->(!Eof())
			nQtdLot += (cAliasDTC)->QTDLOT
			(cAliasDTC)->(DbSkip())
		EndDo
	EndIf
	(cAliasDTC)->(DbCloseArea())

	DTP->(dbSetOrder(2))
	If DTP->(MsSeek(xFilial("DTP") + M->DTC_FILORI + M->DTC_LOTNFC))
		RecLock("DTP",.F.)
		If nQtdLot != 0
			DTP->DTP_QTDLOT	:= nQtdLot
			DTP->DTP_STATUS	:= "2"
		Else
		//-- Se a quantidade estiver zerada, deleta a o lote.
			DTP->(DbDelete())
		EndIf
		DTP->(MsUnLock())
	EndIf

	// Cálculo automático
	If nQtdLot != 0 .AND. DTP->DTP_RATEIO != "1"
		If lPergCalc
			If MsgYesNo(STR0151) // O lote de digitação de notas fiscais foi fechado automaticamente.Deseja calculá-lo agora?
				TMSA200Mnt("DTP",DTP->(Recno()),2,,.F.)
			EndIf
		Else
			TMSA200Mnt("DTP",DTP->(Recno()),2,,.F.)
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} T050VldNFE
Validação para os dados inseridos na Grid1.

@author rodrigo.pirolo

@since 08/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function T050VldNFE(cCodBar)

Local nCount		:= 0
Local nPos			:= 0
Local cQuery		:= ""
Local cAliasDE5	:= GetNextAlias()
Local cCGCRem		:= ""
Local lMetros3	:= .F.
Local lRemetente	:= .F.
Local lRet			:= .T.
Local lVldItem	:= .T.
Local aItEDI		:= {}
Local aAreaAnt	:= GetArea()
Local aAuxEDI		:= {}
Local nX			:= 0
Local lDE5PESLIQ := DE5->(ColumnPos("DE5_PESLIQ")) > 0

Default cCodBar   := ""

If !Empty(cCodBar)

	DbSelectArea("DE5")

	If DE5->(ColumnPos("DE5_METRO3")) > 0
		lMetros3	:= .T.
	EndIf

	cQuery := "SELECT DE5_CGCREM,DE5_NFEID,"
	cQuery += 		" DE5_CGCDES,DE5_CGCDEV,DE5_CGCCON, DE5_CGCDPC,"
	cQuery += 		" DE5_SERIE, DE5_EMINFC,DE5_DOC,DE5_SERTMS,DE5_TIPTRA,"
	cQuery += 		" DE5_CODPRO, DE5_QTDVOL,"
	If lDE5PESLIQ
		cQuery += 		" DE5_PESO, DE5_PESOM3,DE5_PESLIQ,"
	Else
		cQuery += 		" DE5_PESO, DE5_PESOM3,"
	EndIf
	cQuery += 		" DE5_VALOR,DE5_CODEMB,"
	cQuery += 		" DE5_EMINFE,DE5_CODNFE,"
	cQuery += 		" DE5_NFELET,DE5_CFOPNF"

	If lMetros3
		cQuery += 		", DE5_METRO3"
	EndIf

	cQuery += "  FROM " + RetSqlName("DE5") + " DE5 "

	cQuery += " WHERE DE5_FILIAL = '" + xFilial("DE5") + "' "
	cQuery += "   AND DE5_NFEID  = '" + cCodBar + "' "
	cQuery += "   AND DE5_STATUS = '1' "
	cQuery += "   AND DE5.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDE5,.T.,.T.)
	While (cAliasDE5)->(!Eof())

		nCount ++

		If !Empty( (cAliasDE5)->DE5_CGCREM ).AND. !Empty( (cAliasDE5)->DE5_NFEID )
			If ( Empty(aCols[1][1]) ) .OR. !Empty((cAliasDE5)->(DE5_SERTMS)) .OR. (Empty((cAliasDE5)->(DE5_SERTMS)) .And. !Empty(M->DTC_SERTMS))
				If ( Empty(aCols[1][1]) ) .OR. !Empty((cAliasDE5)->(DE5_SERTMS)) .OR. (Empty((cAliasDE5)->(DE5_SERTMS)) .And. !Empty(M->DTC_SERTMS))
					If ( Empty(aCols[1][1]) ) .OR. !Empty((cAliasDE5)->(DE5_SERTMS)) .OR. MsgYesNo(STR0152)//O Serv. Transp(SerTms) está em branco. Confirma o Serv. Transp(SerTms) igual ao do documento anterior?
						If ( Empty( (cAliasDE5)->(DE5_TIPTRA) ) .OR. Empty(M->DTC_TIPTRA) ) .OR. ((cAliasDE5)->(DE5_TIPTRA) == M->DTC_TIPTRA)
							cCGCRem	:= (cAliasDE5)->DE5_CGCREM
							lRemetente	:= .T.

							If lMetros3
								If lDE5PESLIQ
									AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
													(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
													(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
													(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,(cAliasDE5)->DE5_PESLIQ,;
													(cAliasDE5)->DE5_VALOR,(cAliasDE5)->DE5_METRO3	} )
								Else
									AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
													(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
													(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
													(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,;
													(cAliasDE5)->DE5_VALOR,(cAliasDE5)->DE5_METRO3	} )
								EndIf
							Else
								If lDE5PESLIQ
									AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
													(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
													(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
													(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,(cAliasDE5)->DE5_PESLIQ,;
													(cAliasDE5)->DE5_VALOR	} )
								Else
									AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
													(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
													(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
													(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,;
													(cAliasDE5)->DE5_VALOR	} )
								EndIf
							EndIf

							If Len(aItEDI) > 0

								If (Len(aCols) == 1 .AND. Empty(aCols[Len(aCols)][1]) .AND. Empty(M->DTC_CLIREM))

									A050AtuEDI(cCGCRem,aItEDI,lRemetente)
									lRet := TMSA050LinOK()

								ElseIf Len(aCols) >= 1

									If !Empty(M->DTC_CLIREM)
										DbSelectArea("SA1")
										SA1->( DbSetOrder(3) ) // A1_FILIAL + A1_CGC

										If SA1->(dbSeek(xFilial("SA1")+(cAliasDE5)->DE5_CGCREM ))
											If M->DTC_CLIREM == SA1->A1_COD
												If SA1->(dbSeek(xFilial("SA1")+(cAliasDE5)->DE5_CGCDES ))
													If M->DTC_CLIDES == SA1->A1_COD
														If !Empty( (cAliasDE5)->DE5_CGCDEV )
															If SA1->(dbSeek(xFilial("SA1")+(cAliasDE5)->DE5_CGCDEV ))
																If !Empty( M->DTC_CLIDEV ) .AND. M->DTC_CLIDEV == SA1->A1_COD
																	If !Empty( (cAliasDE5)->DE5_CGCDPC )
																		If SA1->(dbSeek(xFilial("SA1")+(cAliasDE5)->DE5_CGCDPC ))
																			If !Empty(M->DTC_CLIDPC) .AND. M->DTC_CLIDPC != SA1->A1_COD
																				Help("",1,"TMSA050A1",,STR0139+SA1->A1_COD+" "+STR0133+" "+STR0135+M->DTC_CLIDPC,5,1) //"Os seguintes dados são incompatíveis com o documento anterior: "
																				lRet := .F.
																			Else
																				If Empty(M->DTC_CLIDPC) .AND. !Empty( (cAliasDE5)->DE5_CGCDPC )
																					If !MsgYesNo(STR0142)	//"O cliente Despachante do documento anterior não foi informado. Confirma o despachante permanecer em branco assim como no documento anterior?"
																						lRet := .F.
																					Endif
																				Endif
																			Endif
																		Endif
																	Else
																		If !Empty(M->DTC_CLIDPC)
																			If !MsgYesNo(STR0145)	//"O cliente Despachante não foi informado. Confirma o despachante igual ao do documento anterior?"
																				lRet := .F.
																			Endif
																		Endif
																	Endif
																	If !Empty( (cAliasDE5)->DE5_CGCCON )
																		If SA1->(dbSeek(xFilial("SA1")+(cAliasDE5)->DE5_CGCCON ))
																			If !Empty(M->DTC_CLICON) .AND. M->DTC_CLICON != SA1->A1_COD
																				Help("",1,"TMSA050A1",,STR0138+SA1->A1_COD+" "+STR0133+" "+STR0135+M->DTC_CLICON,5,1) //"Os seguintes dados são incompatíveis com o documento anterior: "
																				lRet := .F.
																			Else
																				If Empty(M->DTC_CLICON) .AND. !Empty( (cAliasDE5)->DE5_CGCCON )
																					If !MsgYesNo(STR0143)	//"O cliente Consignatário do documento anterior não foi informado. Confirma o consignatário permanecer em branco assim como no documento anterior?"
																						lRet := .F.
																					Endif
																				Endif
																			Endif
																		Endif
																	Else
																		If !Empty(M->DTC_CLICON)
																			If !MsgYesNo(STR0144)	//"O cliente Consignatário não foi informado. Confirma o consignatário igual ao do documento anterior?"
																				lRet := .F.
																			Endif
																		Endif
																	Endif
																Else
																	If !Empty( M->DTC_CLIDEV )
																		Help("",1,"TMSA050A1",,STR0134+SA1->A1_COD+" "+STR0133+" "+STR0135+M->DTC_CLIDEV,5,1) //"Os seguintes dados são incompatíveis com o documento anterior: "
																		lRet := .F.
																	Endif
																Endif
															Endif
														Else
															If !Empty(M->DTC_CLIDEV)
																If !MsgYesNo( STR0140) //"O cliente Devedor está em branco. Confirma o devedor igual ao do documento anterior?"
																	lRet := .F.
																Endif
															Endif
														Endif
													Else
														Help("",1,"TMSA050A1",,STR0136+SA1->A1_COD+" "+STR0133+" "+STR0135+M->DTC_CLIDES,5,1) //"Os seguintes dados são incompatíveis com o documento anterior: "
														lRet := .F.
													EndIf
												EndIf
											Else
												Help("",1,"TMSA050A1",,STR0137+SA1->A1_COD+" "+STR0133+" "+STR0135+M->DTC_CLIREM,5,1) //"Os seguintes dados são incompatíveis com o documento anterior: "
												lRet := .F.
											EndIf
										EndIf

										If lRet .AND. !Empty(aCols[Len(aCols)][2]) .AND. !Empty(M->DTC_CLIREM) .And. ((cAliasDE5)->DE5_SERTMS == M->DTC_SERTMS .OR. (Empty((cAliasDE5)->DE5_SERTMS) .AND. !Empty(M->DTC_SERTMS)))
											T050AddLine() //Add linha e atualiza o o1Get
										EndIf

										If lRet .AND. Empty((cAliasDE5)->DE5_SERTMS) .OR. ((cAliasDE5)->DE5_SERTMS == M->DTC_SERTMS ) //validação ok
											lRet := T050AtuaCols(cAliasDE5,lMetros3) //inclusão de dados no aCols
											If lRet
												lRet := TMSA050LinOK()
											EndIf
										Else
											If lRet .And. ((cAliasDE5)->DE5_SERTMS <> M->DTC_SERTMS )
												aAuxEDI := aClone(aCols)

												aItEDI := {}

												For nX := 1 to Len(aAuxEDI)
													If lMetros3
														If lDE5PESLIQ
															AAdd( aItEDI, {	.T.,""/*(cAliasDE5)->DE5_CGCDES*/,aCols[nX][1],;
															aCols[nX][2],""/*(cAliasDE5)->DE5_EMINFC*/,;
															aCols[nX][3],""/*(cAliasDE5)->DE5_QTDVOL*/,;
															""/*(cAliasDE5)->DE5_PESO*/,""/*(cAliasDE5)->DE5_PESOM3*/,""/*(cAliasDE5)->DE5_PESLIQ*/,;
															""/*(cAliasDE5)->DE5_VALOR*/,""/*(cAliasDE5)->DE5_METRO3*/	} )
														Else
															AAdd( aItEDI, {	.T.,""/*(cAliasDE5)->DE5_CGCDES*/,aCols[nX][1],;
															aCols[nX][2],""/*(cAliasDE5)->DE5_EMINFC*/,;
															aCols[nX][3],""/*(cAliasDE5)->DE5_QTDVOL*/,;
															""/*(cAliasDE5)->DE5_PESO*/,""/*(cAliasDE5)->DE5_PESOM3*/,;
															""/*(cAliasDE5)->DE5_VALOR*/,""/*(cAliasDE5)->DE5_METRO3*/	} )
														EndIf
													Else
														If lDE5PESLIQ
															AAdd( aItEDI, {	.T.,""/*(cAliasDE5)->DE5_CGCDES*/,aCols[nX][1],;
															aCols[nX][2],""/*(cAliasDE5)->DE5_EMINFC*/,;
															aCols[nX][3],""/*(cAliasDE5)->DE5_QTDVOL*/,;
															""/*(cAliasDE5)->DE5_PESO*/,""/*(cAliasDE5)->DE5_PESOM3*/,""/*(cAliasDE5)->DE5_PESLIQ*/,;
															""/*(cAliasDE5)->DE5_VALOR*/	} )
														Else
															AAdd( aItEDI, {	.T.,""/*(cAliasDE5)->DE5_CGCDES*/,aCols[nX][1],;
															aCols[nX][2],""/*(cAliasDE5)->DE5_EMINFC*/,;
															aCols[nX][3],""/*(cAliasDE5)->DE5_QTDVOL*/,;
															""/*(cAliasDE5)->DE5_PESO*/,""/*(cAliasDE5)->DE5_PESOM3*/,;
															""/*(cAliasDE5)->DE5_VALOR*/	} )
														EndIf
													EndIf
												next nX

												If lMetros3
													If lDE5PESLIQ
														AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
															(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
															(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
															(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,(cAliasDE5)->DE5_PESLIQ,;
															(cAliasDE5)->DE5_VALOR,(cAliasDE5)->DE5_METRO3	} )
													Else
														AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
															(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
															(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
															(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,;
															(cAliasDE5)->DE5_VALOR,(cAliasDE5)->DE5_METRO3	} )
													EndIf
												Else
													If lDE5PESLIQ
														AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
															(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
															(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
															(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,(cAliasDE5)->DE5_PESLIQ,;
															(cAliasDE5)->DE5_VALOR	} )
													Else
														AAdd( aItEDI, {	.T.,(cAliasDE5)->DE5_CGCDES,(cAliasDE5)->DE5_DOC,;
															(cAliasDE5)->DE5_SERIE,(cAliasDE5)->DE5_EMINFC,;
															(cAliasDE5)->DE5_CODPRO,(cAliasDE5)->DE5_QTDVOL,;
															(cAliasDE5)->DE5_PESO,(cAliasDE5)->DE5_PESOM3,;
															(cAliasDE5)->DE5_VALOR	} )
													EndIf
												EndIf

												A050AtuEDI(cCGCRem,aItEDI,lRemetente)
												lRet := TMSA050LinOK()
											EndIf
										EndIf

									EndIf

								EndIf
							EndIf
						Else
							Help("",1,"TMSA050B1",,) //O Tipo de Transporte está em branco ou diferente do documento anterior
							lRet := .F.
						Endif
					Else
						lRet := .F.
					EndIf
				EndIf
			Else
				Help("",1,"TMSA050B0",,) //Serviço de Transporte diferente do documento anterior
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			Exit
		EndIf

		(cAliasDE5)->(DbSkip())
	EndDo
	(cAliasDE5)->(dbCloseArea())

	If nCount == 0
		Aviso( STR0009, STR0120, {"Ok"} )//STR0009 "Atenção" STR0120 "Numero de Documento não encontrado ou já digitado."
	EndIf

	o1Get:oBrowse:Refresh(.T.)
EndIf

cCodBar:= Space(TamSx3("DTC_NFEID")[1])
RestArea(aAreaAnt)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T050AddLine
Função para adicão de linha na Grid

@author rodrigo.pirolo

@since 12/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function T050AddLine()

o1Get:AddLine()				//Adiciona uma linha nova
o1Get:oBrowse:nColPos := 1   //Muda a coluna para a 1
o1Get:Refresh() //Atualiza a Getdados
o1Get:oBrowse:Refresh(.T.)	//Atualiza a Getdados do browse em tela.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} T050AtuaCols
Função para Atualização do aCols

@author rodrigo.pirolo

@since 12/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function T050AtuaCols(cAliasDE5,lMetros3)

Local dEminFc	:= dDataBase

Local nCnt		:= Len(aCols)
Local nPos		:= 0

Local lVldItem	:= .T.
Local lDE5PESLIQ := DE5->(ColumnPos("DE5_PESLIQ")) > 0

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NUMNFC"})
aCols[nCnt,nPos]	:=	Left((cAliasDE5)->DE5_DOC,Len(DTC->DTC_NUMNFC))
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_SERNFC"})
aCols[nCnt,nPos]	:=	Left((cAliasDE5)->DE5_SERIE,Len(DTC->DTC_SERNFC))
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODPRO"})
aCols[nCnt,nPos]	:=	Left((cAliasDE5)->DE5_CODPRO,Len(DTC->DTC_CODPRO))
&( "M->"+aHeader[nPos][2] ) := aCols[nCnt,nPos]
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos],.T.) .And. lVldItem
	lVldItem := .F.
EndIf

If ExistTrigger("DTC_CODPRO")
	RunTrigger(2,nCnt,,o1Get,"DTC_CODPRO")
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODEMB"})
aCols[nCnt,nPos]	:=	Left((cAliasDE5)->DE5_CODEMB,Len(DTC->DTC_CODEMB))
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

If ExistTrigger("DTC_CODEMB")
	RunTrigger(2,nCnt,,o1Get,"DTC_CODEMB")
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_EMINFC"})
If ValType( (cAliasDE5)->DE5_EMINFC ) == "C"
	dEminFc := SToD((cAliasDE5)->DE5_EMINFC)
Else
	dEminFc := (cAliasDE5)->DE5_EMINFC
EndIf
aCols[nCnt,nPos] := dEminFc
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_QTDVOL"})
aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_QTDVOL
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PESO"})
aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_PESO
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PESOM3"})
aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_PESOM3
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

If lDE5PESLIQ
	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_PESLIQ"})
	aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_PESLIQ
	__readvar:="M->"+aHeader[nPos][2]
	If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
		lVldItem := .F.
	EndIf
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_VALOR"})
aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_VALOR
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_EDI"})
aCols[nCnt,nPos]	:=	"1"
__readvar:="M->"+aHeader[nPos][2]
If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
	lVldItem := .F.
EndIf

If lMetros3
	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_METRO3"})
	aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_METRO3
	__readvar:="M->"+aHeader[nPos][2]
	If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
		lVldItem := .F.
	EndIf
EndIf

//-- Campo da NF-e
If DE5->(ColumnPos("DE5_NFEID")) > 0
	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NFEID"})
	aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_NFEID
	__readvar:="M->"+aHeader[nPos][2]
	If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
		lVldItem := .F.
	EndIf
EndIf

If DE5->(ColumnPos("DE5_EMINFE")) > 0
	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_EMINFE"})
	aCols[nCnt,nPos]	:=	IIf( ValType( (cAliasDE5)->DE5_EMINFE ) == "C" , CToD((cAliasDE5)->DE5_EMINFE ) , (cAliasDE5)->DE5_EMINFE )
	__readvar:="M->"+aHeader[nPos][2]
	If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
		lVldItem := .F.
	EndIf
EndIf

If DE5->(ColumnPos("DE5_CODNFE")) > 0
	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CODNFE"})
	aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_CODNFE
	__readvar:="M->"+aHeader[nPos][2]
	If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
		lVldItem := .F.
	EndIf
EndIf

If DE5->(ColumnPos("DE5_NFELET")) > 0
	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_NFELET"})
	aCols[nCnt,nPos]	:=	(cAliasDE5)->DE5_NFELET
	__readvar:="M->"+aHeader[nPos][2]
	If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
		lVldItem := .F.
	EndIf
EndIf

//-- Campo do Cod.Fiscal
If DE5->(ColumnPos("DE5_CFOPNF")) > 0
	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTC_CF"})
	aCols[nCnt,nPos]	:= (cAliasDE5)->DE5_CFOPNF
	__readvar:="M->"+aHeader[nPos][2]
	If !CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos]) .And. lVldItem
		lVldItem := .F.
	EndIf
EndIf

If !lVldItem
	aCols[nCnt,Len(aHeader)+1] := .T.
EndIf

Return lVldItem

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS050CEDI
Função para Leitura do Codigo de Barras - EDI

@author Katia

@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMS050CEDI()
Local cCodbar := Space(TamSX3("DTC_NFEID")[1]+1)
Local oGetBar
Local oButton
Local oDlg

DEFINE MSDIALOG oDlg FROM 200, 001 TO 320, 320 TITLE STR0115 Of oMainWnd PIXEL      //"Leitura do Codigo de Barras"
@ 018 , 013 MSGET oGetBar  VAR cCodbar Of oDlg PIXEL SIZE 140, 009 VALID(Iif(T050VldNFE(@cCodbar),(cCodbar == '',.T.),.T.))
oButton := TButton():New( -150, -150, "FAKE", oDlg,{|| oDlg:End()	},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
oButton:bGotFocus := {|| oGetBar:SetFocus() }

ACTIVATE DIALOG oDlg CENTERED

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldStsCol
Função para validar o Status da coleta

@author paulo.henrique
@since 27/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldStsCol(lTmsCFec,cSerTMS,nRecDt5,cFilVia,cViagem)
Local lRet		:= .T.					// Recebe o Retorno
Local aAreaDF1	:= {}					// Recebe a Area da DF1
Local cStatus	:= ""					// Recebe o Status
Local cStatusPE	:= ""					// Recebe o Status do Ponto de Entrada
Local lAgend	:= .F.					// Recebe de possui agendamento
Local aAreaAtu  := GetArea()			// Recebe a Area Atual
Local aAreaDT5  := DT5->( GetArea() )	// Recebe a Area da DT5

Local lRetPE    := .T.

Default lTmsCFec	:= TMSCFec() 		// Verifica se é Carga Fechada
Default nRecDt5 	:= 0		 		// Recebe o Recno do DT5
Default cSerTMS 	:= ""				// Recebe o Serviço de Transporte
Default cFilVia     := ""
Default cViagem     := ""

// Posiciona na DT5
If nRecDt5 > 0
	dbSelectArea("DT5")
	DT5->(dbGoto(nRecDt5))
EndIf

If !lTmsCFec
	//-- Ponto de entrada para desligar a validação da viagem de coleta em transito
	If lTMViaCol
		lRetPE := ExecBlock("TMVIACOL",.F.,.F.,{cFilVia,cViagem,M->DTC_FILCFS,M->DTC_NUMSOL})
		If ValType(lRetPE) != "L"
			lRetPE := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite Solicitacao de Coleta com Status diferente de 'Encerrada'    ³
	//³ Processo - Carga Fracionada                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRetPE
		If DT5->DT5_STATUS <> StrZero(4, Len(DT5->DT5_STATUS)) // Encerrada
			Help("",1,"TMSA05045") // So' serao aceitas Solicitacoes de Coleta Encerradas !!!
			lRet := .F.
		EndIf
	EndIf
Else

	//--Caso a solicitacao de coleta esteja amarrada a um
	//--agendamento, significa que a coleta fez parte de um processo
	//--de carga fechada.

	//--OU

	//--Caso a solicitacao de coleta tenha sido realizada sem um
	//--agendamento e a entrada do documento do cliente corresponda a
	//--um servico de transporte de ENTREGA, tambem considera que
	//--trata-se do processo de carga fechada.

	//--Caso contrario, o processo realizado foi o processo de carga
	//--fracionada.

	aAreaDF1 := DF1->( GetArea() )
	DF1->( DbSetOrder(3) )
	If DF1->( DbSeek( xFilial('DF1') + DT5->( DT5_FILORI + DT5_NUMSOL + DT5_SERIE ) ) )
		If	( cSerTMS == StrZero(2,Len(DTC->DTC_SERTMS)) .Or. cSerTMS == StrZero(3,Len(DTC->DTC_SERTMS)) ) .Or.;
			Empty(cSerTMS)
			cStatus := '2;3;4;7'
			lAgend  := .T.
		Else
			cStatus := StrZero( 4, Len(DT5->DT5_STATUS) )
		EndIf
	Else
		If	( cSerTMS == StrZero(2,Len(DTC->DTC_SERTMS)) .Or. cSerTMS == StrZero(3,Len(DTC->DTC_SERTMS)) ) .Or.;
			( Empty(cSerTMS) )
			cStatus := '2;3;4;7'
			lAgend  := .T.
		Else
			cStatus := '4;7'
		EndIf
	EndIf
	RestArea( aAreaDF1 )

	//--Ponto de entrada para Validar o Status da
	//--Solicitacao de Coleta que nao podera ser utilizado na NF
	If lAgend .And. TM050COL
		cStatusPE := ExecBlock('TM050COL',.F.,.F.)
		If ValType(cStatusPE) <> 'C'
			cStatusPE := '1;5;6;9'
		EndIf
	EndIf

	lRet:= .T.
	If TM050COL .And. lAgend
		If DT5->DT5_STATUS $ cStatusPE
			lRet:= .F.
		EndIf
	Else
		If !( DT5->DT5_STATUS $ cStatus )
			lRet:= .F.
		EndIf
	EndIf

	//-- Ponto de entrada para desligar a validação da viagem de coleta em transito
	If lTMViaCol
		lRetPE := ExecBlock("TMVIACOL",.F.,.F.,{cFilVia,cViagem,M->DTC_FILCFS,M->DTC_NUMSOL})
		If ValType(lRetPE) != "L"
			lRetPE := .F.
		EndIf
		lRet := lRetPE
	EndIf

	If !lRet
		If lAgend
			Help("",1,"TMSA05060") // So' serao aceitas Solicitacoes de Coleta com status diferente de 'Em Aberto', 'Documento informado' e 'Cancelado' !!!
		Else
			Help("",1,"TMSA05045") // So' serao aceitas Solicitacoes de Coleta Encerradas !!!
		EndIf
	EndIf
EndIf

RestArea(aAreaDT5)
RestArea(aAreaAtu)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa050Per
Valida Digitação Da NF Do Cliente Utilizando Rateio Com Contrato De Percentual Fixo
@author Eduardo Alberti
@since	May./2016
@obs Tmsa050
@param	[cFilOri], Caracter, Filial Origem
@param	[cViagem], Caracter, Número Do Lote Na Tabela DTP
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa050Per( cFilOri , cLotNfc , cCodNeg , cServic, aContrat )

	Local aArea   := GetArea()
	Local aArDTP  := DTP->(GetArea())
	Local lRet    := .t.

	Default cFilOri := M->DTC_FILORI
	Default cLotNfc := M->DTC_LOTNFC
	Default cCodNeg := M->DTC_CODNEG
	Default cServic := M->DTC_SERVIC

	DbSelectArea("DTP")
	DbSetOrder(2) //-- DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If MsSeek( FWxFilial("DTP") + cFilOri + cLotNfc , .F. )

		//-- Verifica Se é Rateio e Se o Contrato Está Gravado No Lote
		If DTP->(ColumnPos('DTP_NCONTR')) > 0
		   If DTP->DTP_RATEIO == '1' .And. !Empty(DTP->DTP_NCONTR)
			    If DTP->DTP_PRORAT == 'A'
		    		If !Empty(aContrat) .And. aContrat[1,1] <> DTP->DTP_NCONTR
	    				Help("",1,"TMSA050B2") //-- Este Devedor Não Pode Ser Utilizado Para Este Lote ou Contrato Informado. Selecione Um Devedor Que Corresponda Ao Contrato.
     					lRet := .f.
				    EndIf

				    //--- Para criterio de %Fixo, nao podera ter no lote negociacao e ou servico diferentes devido ao Percentual Fixo de Rateio
				    If lRet .And. !Empty(DTP->DTP_CODNEG) .AND. DTP->(ColumnPos('DTP_SERVIC')) > 0
					    lRet:= cCodNeg == DTP->DTP_CODNEG .And. cServic == DTP->DTP_SERVIC
					    If !lRet
				    		Help("",1,"TMSA050C9") //Não é permitido digitar Negociações e ou Serviços diferentes no mesmo lote quando o criterio de rateio é por Percentual Fixo.
			    		EndIf
		    		EndIf
      			EndIf
		    EndIf
		EndIf
	EndIf

	//-- Verifica Se Não Está No Painel De Agendamento
	If lRet .And. !lPainel

		//-- Verifica Se Existe Contrato Informado
		If Len(aContrat) > 0
			//-- Se Estiver Fora Do painel De Agendamento Não Permite Utilizar Serviço Com Campo CRIRAT = 'A' (Origem Destino Vge).
			If TmsSobServ("CRIRAT",,.T.,aContrat[1,1],cCodNeg,cServic,"1") == "A"
   				Help("",1,"TMSA050D2") //-- "Código De Serviço Informado Só Pode Ser Utilizado No Painel de Agendamento"
				lRet := .f.
			EndIf
		EndIf
	EndIf

	RestArea( aArDTP )
	RestArea( aArea )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050RLt³ Autor ³Leandro Paulino        ³ Data ³ 17/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o lote sera reaberto                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050RLt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa050RLt(cFilOri, cNumLote)
Default cFilOri	:= ''
Default cNumLote	:= ''

If Posicione('DTP',2,FwxFilial('DTP')+cFilOri+cNumLote,'DTP_STATUS') == '2'
	RecLock('DTP',.F.)
	DTP->DTP_QTDLOT := 99
	DTP->DTP_STATUS := '1'
	MsUnLock()
EndIf
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A050EstDF0³ Autor ³Ramon Prado		       ³ Data ³ 01/07/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ao estornar nota balcao Status do agendamento gerado virtual ±±
±± fica como cancelado															´±±
±±³Sintaxe   ³A050EstDF0()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050EstDF0(cFilDoc, cDoc, cSerie)
Local aArea := GetArea()
Local lSolColMan	:= DF1->(ColumnPos("DF1_SCOMAN")) > 0

dbSelectArea("DF1")
DF1->(dbSetOrder(3)) //Filial + Fil.Docto. + No.Docto. + Serie Docto.
If MsSeek(xFilial("DF1")+cFilDoc+cDoc+cSerie)
	dbSelectArea("DF0")
	DF0->(dbSetOrder(1)) //Filial + Agendamento
	If MsSeek(xFilial("DF0")+DF1->DF1_NUMAGE) .And. IIf(lSolColMan,DF1->DF1_SCOMAN == StrZero(2,Len(DF1->DF1_SCOMAN)),.T. ) //Posiciona no agendamento e verifica se é automatico
		RecLock("DF0",.F.)
		DF0->DF0_STATUS	:= 	StrZero(9,Len(DF0->DF0_STATUS)) //cancelado
		DF0->(MsUnlock())
	EndIf
EndIf

RestArea(aArea)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA050VAtu³ Autor ³Tiago dos Santos      ³ Data ³ 08/09/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se algum campo foi alterada pelo usuário            ³±±
±±³          ³  retorna .T. se houve alteração.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA050VAtu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA050VAtu(cCampo)
Local   lResult := .F.
default cCampo  := ""

//-- Número da Solicitação de Coleta
If cCampo $ "M->DTC_NUMSOL"

      If M->DTC_NUMSOL <> cNumSolDif
         lResult := .T.
      EndIf

//-- Servico de Transporte
ElseIf cCampo $ "M->DTC_SERTMS"
      If !Empty(cSerTMSDif) .And. M->DTC_SERTMS <> cSerTMSDif
         lResult := .T.
      EndIf
EndIf

    cNumSolDif := M->DTC_NUMSOL
    cSerTMSDif := M->DTC_SERTMS

Return lResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetaHeaDUH
Efetua a montagem do aHeader da tela de Endereços
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 05/06/2017
@param [cSeek], Caracter, Chave utilizada no posicionamento da area para preencher o aCols
@param [cWhile], Caracter, Expressão a ser comparada com cSeekKey na condição do While
@param [aNoFldsDUH], Array, Array com nome dos campos que serão excluídos na montagem do aHeader
@return aRet Array que contém o aHeader
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetaHeaDUH(cSeek, cWhile, aNoFldsDUH)

	Local aArea     := GetArea()
	Local aRet      := {}
	Local aColsBkp  := {}
	Local aHeadBkp  := {}
	Local nPosNota  := Ascan(aHeader, {|x| AllTrim(x[2]) == "DTC_NUMNFC"})
	Local nPosSerie := Ascan(aHeader, {|x| AllTrim(x[2]) == "DTC_SERNFC"})
	Local nPosProd  := Ascan(aHeader, {|x| AllTrim(x[2]) == "DTC_CODPRO"})

	Default cSeek      := ""
	Default cWhile     := ""
	Default aNoFldsDUH := {}

	If ValType("aHeaderDUH") == "U"
		Private aHeaderDUH := {}
	EndIf

	If ValType("aHeader") == "U"
		Private aHeader := {}
	EndIf

	If ValType("aCols") == "U"
		Private aCols := {}
	EndIf

	aColsBkp := AClone(aCols)
	aHeadBkp := AClone(aHeader)

	If Empty(cSeek)
		cSeek := TMSA050CFS("DUH",M->DTC_FILCFS)
		cSeek += IIf(Empty(M->DTC_FILCFS), M->DTC_FILCFS, M->DTC_FILORI)
		cSeek += aColsBkp[n, nPosNota] + aColsBkp[n, nPosSerie] + M->DTC_CLIREM + M->DTC_LOJREM + aColsBkp[n, nPosProd]
	EndIf

	If Empty(cWhile)
		cWhile := "DUH->(DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM+DUH_CODPRO)"
	EndIf

	If Empty(aNoFldsDUH)
		AAdd(aNoFldsDUH, "DUH_FILIAL")
		AAdd(aNoFldsDUH, "DUH_FILORI")
		AAdd(aNoFldsDUH, "DUH_NUMNFC")
		AAdd(aNoFldsDUH, "DUH_SERNFC")
		AAdd(aNoFldsDUH, "DUH_CLIREM")
		AAdd(aNoFldsDUH, "DUH_LOJREM")
		AAdd(aNoFldsDUH, "DUH_CODPRO")
		AAdd(aNoFldsDUH, "DUH_FILDES")
		AAdd(aNoFldsDUH, "DUH_STATUS")
	EndIf

	aHeader := {}
	aCols   := {}

	FillGetDados(4 /* nOpc */,;
					"DUH" /* cAlias */,;
					1 /* nOrder */,;
					cSeek/* cSeekKey */,;
					{|| &cWhile } /* bSeekWhile */,;
					{|| .T.} /* uSeekFor */,;
					aNoFldsDUH /* aNoFields */,;
					/* aYesFields */,;
					/* lOnlyYes */,;
					/* cQuery */,;
					/* bMontCols */)

	aHeaderDUH := AClone(aHeader)
	aRet       := AClone(aHeader)
	aCols      := AClone(aColsBkp)
	aHeader    := AClone(aHeadBkp)

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetInfoDUH
Cria registros DUH conforme lote selecionado
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 05/06/2017
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function SetInfoDUH()

	Local lRet       := .T.
	Local cSeekDUH   := ""
	Local cItemDUH   := ""
	Local nItDUH     := 0
	Local aItDUH     := {}
	Local uValor     := Nil
	Local nX         := 0
	Local aHeaderDUH := {}

	If ValType("aEndProd") == "U"
		Private aEndProd := {}
	EndIf

	cSeekDUH := xFilial("DUH")  +;
				cFilAnt         +;
				DTC->DTC_NUMNFC +;
				DTC->DTC_SERNFC +;
				DTC->DTC_CLIREM +;
				DTC->DTC_LOJREM +;
				DTC->DTC_CODPRO

	cItemDUH := DTC->(DTC_NUMNFC + DTC_SERNFC + DTC_CODPRO)

	dbSelectArea("DUH")
	DUH->(dbSetOrder(1))
	If DUH->(MsSeek(cSeekDUH))

		AAdd(aEndProd, {cItemDUH, {}})
		nItDUH     := Len(aEndProd)
		aHeaderDUH := AClone(GetaHeaDUH(cSeekDUH))

		Do While DUH->(! Eof()) .And.;
		         DUH->(DUH_FILIAL + DUH_FILORI + DUH_NUMNFC + DUH_SERNFC + DUH_CLIREM + DUH_LOJREM + DUH_CODPRO) == cSeekDUH

		    aItDUH := {}

			For nX := 1 To Len(aHeaderDUH)

				If GetSx3Cache(aHeaderDUH[nX][2],"X3_CONTEXT") == "R" .Or. Empty(GetSx3Cache(aHeaderDUH[nX][2],"X3_CONTEXT"))
					IF !(AllTrim(aHeaderDUH[nX,2]) $ "DUH_ALI_WT|DUH_REC_WT") //-- Estes campos não existem no dicionário, são incluídos na grid apenas a nivel informativo.
						uValor := &("DUH->" + aHeaderDUH[nX][2])
					EndIf
				EndIf

				Do Case
					Case AllTrim(aHeaderDUH[nX][2]) == "DUH_ALI_WT"
						uValor := "DUH"
					Case AllTrim(aHeaderDUH[nX][2]) == "DUH_REC_WT"
						uValor := DUH->(Recno())
				End Case

				AAdd(aItDUH, uValor)
			Next nX

			AAdd(aItDUH, .F.) //-- Linha excluída?

			//-- AHeader sempre será menor que o aCols, pois a última linha do
			//-- aCols determinada se o registro está ou não excluído
			If Len(aHeaderDUH) + 1 == Len(aItDUH)
				AAdd(aEndProd[nItDUH][2], aItDUH)
			EndIf

			DUH->(dbSkip())
		EndDo
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAGetCpy
Gatilha as informacoes do doc original para doc copia
@class
@author	Ruan Salvador
@version	1.0
@since		16/06/2017
@return	Nil
@sample	TMSAGetCpy()
/*/
//-------------------------------------------------------------------
Function TMSAGetCpy()

	M->DTC_NOMREM := POSICIONE("SA1",1,XFILIAL("SA1")+M->DTC_CLIREM+M->DTC_LOJREM,"A1_NOME")
	M->DTC_INSREM := IIF(Empty(DTC->DTC_SQIREM),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLIREM+DTC_LOJREM),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLIREM+DTC_LOJREM+DTC_SQIREM),"DV3_INSCR"))

	M->DTC_NOMDES := POSICIONE("SA1",1,XFILIAL("SA1")+DTC->DTC_CLIDES+DTC->DTC_LOJDES,"A1_NOME")
	M->DTC_INSDES := IIF(Empty(DTC->DTC_SQIDES),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLIDES+DTC_LOJDES),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLIDES+DTC_LOJDES+DTC_SQIDES),"DV3_INSCR"))

	M->DTC_NOMCON := POSICIONE("SA1",1,XFILIAL("SA1")+DTC->DTC_CLICON+DTC->DTC_LOJCON,"A1_NOME")
	M->DTC_INSCON := IIF(Empty(DTC->DTC_SQICON),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLICON+DTC_LOJCON),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLICON+DTC_LOJCON+DTC_SQICON),"DV3_INSCR"))

	M->DTC_NOMDPC := POSICIONE("SA1",1,XFILIAL("SA1")+DTC->DTC_CLIDPC+DTC->DTC_LOJDPC,"A1_NOME")
	M->DTC_INSDPC := IIF(Empty(DTC->DTC_SQIDPC),Posicione("SA1",1,xFilial("SA1")+DTC->(DTC_CLIDPC+DTC_LOJDPC),"A1_INSCR"), Posicione("DV3",1,xFilial("DV3")+DTC->(DTC_CLIDPC+DTC_LOJDPC+DTC_SQIDPC),"DV3_INSCR"))

	M->DTC_NOMDEV := POSICIONE("SA1",1,XFILIAL("SA1")+DTC->DTC_CLIDEV+DTC->DTC_LOJDEV,"A1_NOME")
	M->DTC_NOMCAL := POSICIONE("SA1",1,XFILIAL("SA1")+DTC->DTC_CLICAL+DTC->DTC_LOJCAL,"A1_NOME")
	M->DTC_DESTPT := TMSVALFIELD("DTC->DTC_TIPTRA",.F.,"DC5_DESTPT")
	M->DTC_DESSER := TABELA("L4",DTC->DTC_SERVIC,.F.)
	M->DTC_REGDES := POSICIONE("DUY",1,XFILIAL("DUY")+DTC->DTC_CDRDES,"DUY_DESCRI")
	M->DTC_REGCAL := POSICIONE("DUY",1,XFILIAL("DUY")+DTC->DTC_CDRCAL,"DUY_DESCRI")
	M->DTC_REGPER := POSICIONE("DUY",1,XFILIAL("DUY")+DTC->DTC_CDRPER,"DUY_DESCRI")
	M->DTC_NOMEXP := Posicione("SA1",1,xFilial("SA1")+DTC->DTC_CLIEXP+DTC->DTC_LOJEXP,"A1_NOME")
	M->DTC_RORRAT := Posicione("DUY",1,xFilial("DUY")+DTC->DTC_ORIRAT,"DUY_DESCRI")
	M->DTC_RCARAT := Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CALRAT,"DUY_DESCRI")
    If DTC->(ColumnPos("DTC_CLIREC")) > 0
		M->DTC_NOMREC := Posicione("SA1",1,xFilial("SA1")+DTC->DTC_CLIREC+DTC->DTC_LOJREC,"A1_NOME")
	EndIf

Return

/*/{Protheus.doc} TMSA050GDC
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 02/08/2017
@version undefined
@param cFilori, characters, descricao
@param cLote, characters, descricao
@type function
/*/
Static Function TMSA050GDC(cFilori,cLote)
Local lRet     := .T.
Local aAreas   := { DT5->(GetArea()), DT6->(GetArea()) }

     aDUMVlrs := {0,0,0,0,0,0}

     DUM->(dbSetOrder(1))
     If DUM->(MsSeek(xFilial('DUM')+DT5->DT5_FILORI+DT5->DT5_NUMSOL))
          While DUM->(!Eof()) .And. DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL == xFilial('DUM')+DT5->DT5_FILORI+DT5->DT5_NUMSOL
               aDUMVlrs[1] += DUM->DUM_QTDVOL
               aDUMVlrs[2] += DUM->DUM_PESO
               aDUMVlrs[3] += DUM->DUM_PESOM3
               aDUMVlrs[4] += DUM->DUM_VALMER
               aDUMVlrs[5] += Iif(DUM->(ColumnPos("DUM_METRO3")) > 0,DUM->DUM_METRO3,0)
			   aDUMVlrs[6] += DUM->DUM_QTDUNI
               DUM->(DbSkip())
          EndDo
     EndIf
     
	 TMSA460GDc(aDUMVlrs[1], aDUMVlrs[2], aDUMVlrs[3], aDUMVlrs[4], aDUMVlrs[5],aDUMVlrs[6])

     //-- Ajusta o Status do DT6 relacionado ao DT5 para 9-Cancelado
     DT6->(DbSetOrder(1))//--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
     If DT6->(MSSeek(xFilial("DT6") + DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
          DT6->(RecLock("DT6",.F.))
          DT6->DT6_STATUS := "9"
          DT6->(MSUnlock())
     EndIf

     AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

/*/{Protheus.doc} TM050SCFil
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return returno,return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function TM050SCFil(cFilCFS,cNumSol)
Local cSeekDT5 := xFilial("DT5") + cFilCFS + cNumSol
Local aAreas   := {DT5->(GetArea()),DF1->(GetArea()),DUY->(GetArea()),SA1->(GetArea()),DUL->(GetArea()),DUE->(GetArea()),GetArea()}
Local cCliRem  := CriaVar('DT5_CLIREM',.F.)
Local cLojRem  := CriaVar('DT5_LOJREM',.F.)
Local cSeqRem  := CriaVar('DT5_SQEREM',.F.)

DbSelectArea("DT5")
DbSetOrder(1)
IF MsSeek(cSeekDT5)

	If Empty(DT5->DT5_CLIREM)
		//-- Se não preenchido Seq.Endereco do Remetente, usa o solicitante
		DUL->(DBSetOrder(3))
		If DUL->(MsSeek(xFilial("DUL") + DT5->DT5_CODSOL + DT5->DT5_SEQEND))
			If DTC->(ColumnPos("DTC_CLIEXP")) > 0
				cCliRem := DUL->DUL_CODCLI
				cLojRem := DUL->DUL_LOJCLI
				cSeqRem := DT5->DT5_SEQEND
			EndIf
		EndIf
	Else
		cCliRem := DT5->DT5_CLIREM
		cLojRem := DT5->DT5_LOJREM
		cSeqRem := DT5->DT5_SQEREM

	EndIf
	//-- Remetente
	M->DTC_CLIREM := cCliRem
	M->DTC_LOJREM := cLojRem
	SA1->(DbSetOrder(1))
	If SA1->( MsSeek( xFilial('SA1') + cCliRem+ cLojRem) )
		M->DTC_NOMREM := SA1->A1_NOME
		M->DTC_CDRORI := SA1->A1_CDRDES
		M->DTC_REGORI := Posicione("DUY",1,xFilial("DUY")+SA1->A1_CDRDES, "DUY_DESCRI")
	EndIf
	TMSA050Vld("DTC_CLIREM") //-- Valida o Remetente

	//-- Expedidor
	If !Empty(cSeqRem)

		DUL->(DbSetOrder(2))
		If DUL->(MsSeek(xFilial("DUL") + M->DTC_CLIREM + M->DTC_LOJREM + cSeqRem))
			M->DTC_CDRCAL := DUL->DUL_CDRDES
			M->DTC_REGCAL := Posicione("DUY",1,xFilial("DUY")+DUL->DUL_CDRDES,"DUY_DESCRI")
			If DTC->(ColumnPos("DTC_CLIEXP")) > 0
				M->DTC_CLIEXP := DUL->DUL_CODRED
				M->DTC_LOJEXP := DUL->DUL_LOJRED
				M->DTC_NOMEXP := Posicione("SA1",1,xFilial("SA1")+M->DTC_CLIEXP+M->DTC_LOJEXP,"A1_NOME")
			EndIf
		EndIf
	ElseIf !Empty(M->DTC_NUMSOL) .And. !Empty(cCliRem + cLojRem) .And. DTC->(ColumnPos("DTC_CLIEXP")) > 0
		DUE->(DbSetOrder(1)) //-- DUE_FILIAL+DUE_CODSOL
		If DUE->(DbSeek(xFilial("DUE")+DT5->DT5_CODSOL)) .And. !Empty(DUE->(DUE_CODCLI+DUE_LOJCLI)) .And. cCliRem + cLojRem <> DUE->(DUE_CODCLI+DUE_LOJCLI)
			M->DTC_CLIEXP := DUE->DUE_CODCLI
			M->DTC_LOJEXP := DUE->DUE_LOJCLI
			M->DTC_NOMEXP := Posicione("SA1",1,xFilial("SA1")+M->DTC_CLIEXP+M->DTC_LOJEXP,"A1_NOME")
		EndIf
	EndIf

	//-- Destinatario
	M->DTC_CLIDES := DT5->DT5_CLIDES
	M->DTC_LOJDES := DT5->DT5_LOJDES
	SA1->(DbSetOrder(1))
	If SA1->( MsSeek( xFilial('SA1') + DT5->DT5_CLIDES+ DT5->DT5_LOJDES) )
		M->DTC_NOMDES := SA1->A1_NOME
		M->DTC_CDRDES := SA1->A1_CDRDES
		M->DTC_REGDES := Posicione("DUY",1,xFilial("DUY")+M->DTC_CDRDES, "DUY_DESCRI")
	EndIf
	M->DTC_SQEDES := DT5->DT5_SQEDES

	If !Empty(M->DTC_CLIDES)//-- Valida o Destinatario
		TMSA050Vld("DTC_CLIDES")
	EndIf

	//-- Recebedor
	If !Empty(DT5->DT5_SQEDES)

		DUL->(DbSetOrder(2))
		If DUL->(MsSeek(xFilial("DUL")+M->DTC_CLIDES+M->DTC_LOJDES+M->DTC_SQEDES))
			M->DTC_CDRCAL := DUL->DUL_CDRDES
			M->DTC_REGCAL := Posicione("DUY",1,xFilial("DUY")+DUL->DUL_CDRDES,"DUY_DESCRI")
			If DTC->(ColumnPos("DTC_CLIREC")) > 0
				M->DTC_CLIREC := DUL->DUL_CODRED
				M->DTC_LOJREC := DUL->DUL_LOJRED
				M->DTC_NOMREC := Posicione("SA1",1,xFilial("SA1")+DUL->DUL_CODRED+DUL->DUL_LOJRED,"A1_NOME")
			EndIf
		EndIf
	EndIf
EndIf
AEval(aAreas,{|x| RestArea(x) })
Return Nil


/*/{Protheus.doc} TMSA050DTC
//TODO Função para carregamento dos campos da DTC no array para performance.
@author felipe.barbieri
@since 09/03/2018
@param aNoEnch, aNoFields
@type function
/*/
Static Function TMSA050DTC(aNoEnch, aNoFields)
Local nCont     := 0
Local aDTCStru  := FwFormStruct(2,"DTC")

Default aNoFields := {}
Default aNoEnch   := {}

If Len(aSx3DTC) == 0

	For nCont := 1 to Len(aDTCStru:aFields)
		If	Ascan(aNoEnch, { |x| x == AllTrim(aDTCStru:aFields[nCont][1]) } ) == 0 .And. Ascan(aNoFields, { |x| x == AllTrim(aDTCStru:aFields[nCont][1]) } ) == 0
				aAdd(aSx3DTC, { aDTCStru:aFields[nCont][1], GetSX3Cache(aDTCStru:aFields[nCont][1], "X3_CONTEXT") } )
		EndIf
	Next nCont
EndIf

Return aSx3DTC

/*/{Protheus.doc} TMSA050CFS
//TODO Função que retorna a Filial de Solicitação de Coleta ou Cotação quando utilizada
@author Valdemar Roberto Mognon
@since 31/07/2018
@param cAlias
@type function
/*/

Function TMSA050CFS(cAliasComp,cFilTab)
Local cRet    := xFilial(cAliasComp)
Local cFilBak := cFilAnt
Local aAreas  := {SM0->(GetArea()),GetArea()}

If cFilTab != cFilAnt
	SM0->(DbSetOrder(1))
	If SM0->(DbSeek(cEmpAnt + cFilTab))
		cFilAnt := cFilTab
		cRet    := xFilial(cAliasComp)
	EndIf
EndIf

cFilAnt := cFilBak
AEval(aAreas,{|x| RestArea(x)})

Return cRet

/*/{Protheus.doc} A050VldDTP
//TODO Função que realiza validações referentes a tabela DTP - Lote
@author Caio Murakami
@since 11/11/2018
@param cCampo
@type function
/*/
Static Function A050VldDTP(cCampo)
Local aArea			:= GetArea()
Local aAreaDTP		:= DTP->(GetArea())
Local aAreaDTQ		:= DTQ->(GetArea())
Local lRet			:= .T. 
Local cRet			:= ""

Default cCampo		:= ""

If cCampo == "M->DTC_SERTMS"
	
	If !Empty(M->DTC_LOTNFC)
		
		// ***************************************************/
		//-- DTC_SERTMS não pode ser diferente de DTQ_SERTMS
		// ***************************************************/
		DTP->(dbSetOrder(1))
		If DTP->( MsSeek( xFilial("DTP") + M->DTC_LOTNFC )) .And. !Empty(DTP->DTP_VIAGEM)
			cFilOri	:= DTP->DTP_FILORI
			cViagem	:= DTP->DTP_VIAGEM

			DTQ->(dbSetOrder(2)) //-- FILIAL + FILORI + VIAGEM
			If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem )) .And. DTQ->DTQ_SERTMS <> M->DTC_SERTMS
				lRet	:= .F. 
				Help("",1,"TMSA050T1") //-- O Serviço de Transporte deve ser o mesmo Serviço de Transporte da viagem.        
			EndIf

		EndIf	 
	EndIf

ElseIf cCampo $ 'M->DTC_CLIREM.M->DTC_LOJREM'
	
	cRet	:= RetInfoDTW( "M->DTC_LOTNFC" , cCampo  )

	If !Empty(cRet)
		If &cCampo <> cRet
			lRet	:= .F. 
			Help("",1,"TMSA050T2") //-- O Cliente/Loja remetente deve ser o mesmo Cliente/Loja da operação de transporte, da viagem vinculada ao lote.
		EndIf

	EndIf

EndIf

RestArea( aAreaDTQ )
RestArea( aAreaDTP )
RestArea( aArea )
Return lRet

/*/{Protheus.doc} RetInfoDTW
//TODO Função que retorna o cliente remetente da operação DTW da viagem vinculada ao lote 
@author Caio Murakami
@since 30/11/2018
@param cCpoOrig
@type function
/*/
Static Function RetInfoDTW( cCpoOrig , cCpoDest )
Local cFilOri		:= ""
Local cViagem		:= ""
Local aOperDTW		:= {}
Local nCount		:= 1 
Local nPos			:= 0
Local xRet			:= ""

Default cCpoOrig	:= ""
Default cCpoDest	:= ""

If !Empty(cCpoDest)
	xRet := &cCpoDest
EndIf

If cCpoOrig == "M->DTC_LOTNFC" .Or. cCpoOrig == "DTC->DTC_LOTNFC"
		
	If !Empty( &cCpoOrig )
		DTP->( dbSetOrder(1) )
		If DTP->( MsSeek( xFilial("DTP") + &cCpoOrig  )) .And. !Empty(DTP->DTP_VIAGEM)
			cFilOri		:= DTP->DTP_FILORI
			cViagem		:= DTP->DTP_VIAGEM

			aOperDTW	:= aClone( A350RetDTW( cFilOri, cViagem , "2" , "2" ) ) 	

			For nCount := 1 To Len(aOperDTW)
				nPos := aScan(aOperDTW[nCount] , { |x| x[1] == "DTW_ATIVID" })
				If nPos > 0 
					
					cAtvChgCli	:= SuperGetMV('MV_ATVCHGC',,'')

					If aOperDTW[nCount, nPos][2] == cAtvChgCli
						nPos	:= 0 
						If "DTC_CLIREM" $ cCpoDest
							nPos := aScan(aOperDTW[nCount] , { |x| x[1] == "DTW_CODCLI" })
						ElseIf "DTC_LOJREM" $ cCpoDest
							nPos := aScan(aOperDTW[nCount] , { |x| x[1] == "DTW_LOJCLI" })
						EndIf
						If nPos > 0 
							xRet	:= aOperDTW[nCount, nPos][2]

							If "DTC_LOJREM" $ cCpoDest
								SA1->( dbSetOrder(1) )
								If SA1->( MsSeek( xFilial("SA1") + M->DTC_CLIREM + xRet ))
									M->DTC_NOMREM 	:= SA1->A1_NOME
									M->DTC_INSREM 	:= SA1->A1_INSCR
								EndIf
							EndIf
							
						EndIf

					EndIf 
				EndIf
			Next nCount

		EndIf
	EndIf
EndIf

Return xRet
