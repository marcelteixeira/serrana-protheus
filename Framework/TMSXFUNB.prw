#Include "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "TMSXFUNB.CH"
#Define OPEN_FILE_ERROR -1

Static aSM0CodFil  := {}
Static lPrcProd    := GetMV('MV_PRCPROD',,.T.)
Static lTMSFREPAG  := Existblock("TMSFREPAG")
Static lTMSPerfil  := Existblock("TMSPERFIL")
Static lTMSVLFRE   := ExistBlock('TMSVLFRE')
Static lTMALTBAS   := ExistBlock('TMALTBAS')
Static lTMSPesfil  := Existblock("TMSPESFIL")
Static lTMSEMVGM   := Existblock("TMSEMVGM")
Static lTMSACESS   := ExistBlock("TMSACESS")
Static lTMBASCAL   := ExistBlock("TMBASCAL")
Static lTMRETSRV   := ExistBlock("TMRETSRV")
Static lTMSCPDOC   := ExistBlock("TMSCPDOC")  //-- Permite manipular o array de campos nao obrigatorios na gravacao automatica do documento de transporte.
Static lTMCALFRE   := ExistBlock("TMCALFRE")
Static lTMBLQDOC   := ExistBlock("TMBLQDOC")
Static lTMDOCVGE   := ExistBlock("TMDOCVGE")
Static a_Posicion  := {}
Static aTempProc
Static lTempProc   := .F.
Static lAjustHelp  := .F.

//-- Tratamento Rentabilidade/Ocorrencia
Static aRecDep     := { '16',; //-- Rec. CTe Complemento
                       '17',; //-- Desp. Compl.
                       '18',; //-- Rec./Desp.
                       '19',; //-- Rec. CTe Reentrega
                       '20',; //-- Rec. CTe Devolução
                       '21' } //-- Trecho GFE

Static _oRegDUG
Static _oRegDV1
Static _oTribDUG
Static _lConsig
Static _lCpoConsig
Static _lAtuFwPrep	:= .F. 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVerMov ³ Autor ³ Antonio C Ferreira    ³ Data ³19.06.2002   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem os Documentos da Viagem.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVerMov()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                      ³±±
±±³          ³ ExpC2 = Viagem                                                ³±±
±±³          ³ ExpC3 = Filial do Documento                                   ³±±
±±³          ³ ExpC4 = Documento                                             ³±±
±±³          ³ ExpC5 = Serie do Documento                                    ³±±
±±³          ³ ExpL6 = Se obtem os Bloqueados ou Liberados.                  ³±±
±±³          ³ ExpA7 = Retorna Matriz com os Documentos selecionados.        ³±±
±±³          ³ ExpL1 = Verifica documentos Bloqueados                        ³±±
±±³          ³ ExpL2 = Verifica documentos finalizados e cancelados          ³±±
±±³          ³ ExpL3 = Verifica filial de Descarga ?                         ³±±
±±³          ³ ExpL4 = Permite informar ocorrencias de doctos de outra filial³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVerMov(cFilOri, cViagem, cFilDoc, cDoc, cSerie, lBloqueado, aDoc, lVerBlq, lDocFinCanc, lFilDca, lTmsOcol, lBlqDoc)

Local aArea    := GetArea()
Local aAreaDT6 := DT6->(GetArea())
Local aAreaDUD := DUD->(GetArea())
Local cBlqDoc  := ""
Local cSerTMS  := ""
Local cQuery,cAliasNew
Local aRegRot  := {}
Local nSeek    := 0
Local nSeek1   := 0
Local lRecDep  := .f. //-- Tratamento Rentabilidade/Ocorrencia

DEFAULT lBloqueado  := .F.
DEFAULT lVerBlq     := .T.
DEFAULT lDocFinCanc := .F.
DEFAULT lFilDca     := .F.
DEFAULT lTmsOcol    := .T.
DEFAULT lBlqDoc     := .F.

If !Empty(cFilOri) .And. !Empty(cViagem)
	cSerTMS := M_Posicione('DTQ',2, xFilial('DTQ')+cFilOri+cViagem,"DTQ_SERTMS")
EndIf

cBlqDoc := If(lBloqueado, "1", "2;3" )
aDoc := {}

If !Empty( cDoc )

	DT6->( MsSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie) )

	DUD->( DbSetOrder(1) )
	DUD->( MsSeek(xFilial("DUD") + cFilDoc + cDoc + cSerie + cFilOri + cViagem) )

	AAdd(aDoc, {cFilDoc, cDoc, cSerie, DUD->DUD_TIPTRA, DT6->DT6_CDRDES, DT6->DT6_FILDES, DUD->DUD_FILDCA, DUD->DUD_SERVIC, DUD->DUD_CDRCAL, DT6->DT6_CLIDES, DT6->DT6_LOJDES })

Else

	//-- Tratamento Rentabilidade/Ocorrencia
	If Type("M->DUA_CODOCO") == "C"
		DbSelectArea("DT2")
		DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
		If MsSeek( FWxFilial("DT2") + M->DUA_CODOCO , .F. ) .And. aScan( aRecDep, DT2->DT2_TIPOCO) > 0
			lRecDep := .t.
		EndIf
	EndIf

	cAliasNew := GetNextAlias()
	cQuery := " SELECT DUD_FILDOC,DUD_DOC,DUD_SERIE,DUD_TIPTRA,DUD_FILDCA,DUD_SERVIC,DUD_FILORI,"
	cQuery += "        DUD_CDRCAL,DT6_CDRDES,DT6_FILDES,DT6_BLQDOC,DT6_CLIDES,DT6_LOJDES, DUD_FILDCA"
	cQuery += " FROM " + RetSqlName("DUD") + " DUD JOIN " + RetSqlName("DT6") + " DT6 ON"
	cQuery += " DUD_FILDOC = DT6_FILDOC AND "
	cQuery += " DUD_DOC    = DT6_DOC    AND "
	cQuery += " DUD_SERIE  = DT6_SERIE  "
	cQuery += " WHERE "
	cQuery += " DUD_FILIAL = '" + xFilial("DUD") + "'"
	If !lTmsOcol .And. !Empty(cFilOri) .And. !Empty(cViagem) //-- Nao Permite informar ocorrencias de doctos de outra filial
		If cSerTMS <> '1' //-- Se for viagem de Coleta, o campo DUD_FILATU nao e' gravado
		 	cQuery += " AND DUD_FILATU = '" + cFilAnt + "'"
		Else
		 	cQuery += " AND DUD_FILORI = '" + cFilAnt + "'"
		EndIf
	Else
		cQuery += " AND DUD_FILORI = '" + cFilOri + "'"
	EndIf
 	cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
	cQuery += " AND DT6_FILIAL     = '" + xFilial("DT6") + "'"
	If lRecDep //-- Tratamento Rentabilidade/Ocorrencia
		cQuery += " AND DUD_STATUS <> '4' "
	Else
		If !lDocFinCanc .And. !lBlqDoc
			cQuery += " AND DUD_STATUS <> '4' AND DUD_STATUS <> '9' "
		EndIf
	EndIf
	If lBlqDoc
		cQuery += " AND ((DUD_STATUS <> '4' AND DUD_STATUS <> '9') OR (DT6_BLQDOC = '1')) "
	EndIf
	cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += " AND DT6.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
   cQuery := ''
   If lFilDca .And. cSerTMS <> '1'
      If !Empty(cViagem)
			DTQ->(DbSetOrder(2))
			If DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem))
				aRegRot := TMSRegDca(DTQ->DTQ_ROTA)
			EndIf
		EndIf
	EndIf

	While (cAliasNew)->( !Eof() )
	   If lFilDca .And. cSerTMS == '2'  .And. Len(aRegRot) > 0
			nSeek   := Ascan(aRegRot, {|x| x[3] == (cAliasNew)->DUD_FILDCA })
			nSeek1  := Ascan(aRegRot, {|x| x[3] == cFilAnt })
			If ((nSeek1 > nSeek)  .Or. (nSeek=0 .And. nSeek1=0)) .And. ((cAliasNew)->DUD_FILDCA <> cFilAnt .Or. (cAliasNew)->DUD_FILORI <> cFilAnt)
				(cAliasNew)->(dbSkip())
				Loop
			EndIf
		EndIf
		If Iif( lVerBlq,(cAliasNew)->DT6_BLQDOC $ cBlqDoc, .T.)
			AAdd(aDoc, { (cAliasNew)->DUD_FILDOC, (cAliasNew)->DUD_DOC, (cAliasNew)->DUD_SERIE, (cAliasNew)->DUD_TIPTRA, ;
			(cAliasNew)->DT6_CDRDES, (cAliasNew)->DT6_FILDES, (cAliasNew)->DUD_FILDCA, (cAliasNew)->DUD_SERVIC,;
			(cAliasNew)->DUD_CDRCAL, (cAliasNew)->DT6_CLIDES, (cAliasNew)->DT6_LOJDES } )
	   EndIf
   	(cAliasNew)->( DbSkip() )
	EndDo
	(cAliasNew)->( DbCloseArea() )
EndIf

RestArea( aAreaDUD )
RestArea( aAreaDT6 )
RestArea( aArea )

Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCalcImp³ Autor ³ Patricia Salomao/Alex ³ Data ³27.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula impostos.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSCalcImp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente/fornecedor                       ³±±
±±³          ³ ExpC2 = Loja                                               ³±±
±±³          ³ ExpC3 = Codigo do produto                                  ³±±
±±³          ³ ExpC4 = Especie do documento                               ³±±
±±³          ³ ExpC5 = Nome do programa                                   ³±±
±±³          ³ ExpC6 = Nome do programa                                   ³±±
±±³          ³ ExpN1 = Quantidade                                         ³±±
±±³          ³ ExpN2 = Preco unitario                                     ³±±
±±³          ³ ExpN3 = Valor                                              ³±±
±±³          ³ ExpN4 = Casas decimais para preco unitario                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Array contendo a Base, o Valor e a Aliquota de ICM         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCalcImp( cCliFor, cLoja, cCodPro, cEspecie, cRotina, cTes, nQtdVol, nPrcUnit, nValMer, nTamanho  )

Local nBasICM	:= 0
Local nValICM	:= 0
Local nAlqICM	:= 0
Local nTotal	:= 0
//-- Inicializa a funcao fiscal.
MaFisSave()
MaFisEnd()
MaFisIni(cCliFor,;	// 1-Codigo Cliente/Fornecedor
			cLoja,;		// 2-Loja do Cliente/Fornecedor
			"C",;			// 3-C:Cliente , F:Fornecedor
			"N",;			// 4-Tipo da NF
			Nil,;			// 5-Tipo do Cliente/Fornecedor
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			cRotina)

//-- Agrega os itens para a funcao fiscal.

MaFisAdd(cCodPro,;   	// 1-Codigo do Produto ( Obrigatorio )
			cTes,;   		// 2-Codigo do TES ( Opcional )
			nQtdVol,;  		// 3-Quantidade ( Obrigatorio )
		  	NoRound( nPrcUnit, nTamanho ),;	// 4-Preco Unitario ( Obrigatorio )
			0,;	 			// 5-Valor do Desconto ( Opcional )
			"",;	   		// 6-Numero da NF Original ( Devolucao/Benef )
			"",;				// 7-Serie da NF Original ( Devolucao/Benef )
			0,;				// 8-RecNo da NF Original no arq SD1/SD2
			0,;				// 9-Valor do Frete do Item ( Opcional )
			0,;				// 10-Valor da Despesa do item ( Opcional )
			0,;				// 11-Valor do Seguro do item ( Opcional )
			0,;				// 12-Valor do Frete Autonomo ( Opcional )
			nValMer,;		// 13-Valor da Mercadoria ( Obrigatorio )
			0)					// 14-Valor da Embalagem ( Opcional )

//-- Indica os valores do cabecalho.

nBasICM	:= MaFisRet(1,"IT_BASEICM")
nValICM	:= MaFisRet(1,"IT_VALICM")
nAlqICM	:= MaFisRet(1,"IT_ALIQICM")
nTotal	:= MaFisRet(1,"IT_TOTAL")

Return( { nBasICM, nValICM, nAlqICM, nTotal } )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGrpProd³ Autor ³ Alex Egydio           ³ Data ³08.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona grupo de produtos.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSGrpProd()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Array contendo os Grupos                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsGrpProd()

Static lTMSFilGrp := Existblock("TMSFILGRP")
Local aGrp        := {}
Local aRet	        := {}
Local nCntFor     := 0
Local cFiltroSBM  := ".T."
Local lRetPE      := .F.

DbSelectArea("SBM")
SBM->(dbClearFilter())

If lTMSFilGrp
	cFiltroSBM := ExecBlock("TMSFILGRP",.F.,.F.)
	If ValType(cFiltroSBM) <> "C" .Or. Empty(cFiltroSBM)
		cFiltroSBM  := ".T."
	EndIf
EndIf

//-- Grupo de produto.
DbSelectArea("SBM")
SBM->( DbSetOrder( 1 ) )
If	SBM->( MsSeek( xFilial('SBM') ) )
	While SBM->( ! Eof() .And. SBM->BM_FILIAL == xFilial('SBM') )
		If &cFiltroSBM
			AAdd( aGrp, { .F., SBM->BM_GRUPO, SBM->BM_DESC } )
		EndIf
		SBM->( DbSkip() )
	EndDo
EndIf

If ! Empty( aGrp )
	If	TMSABrowse( aGrp,STR0013,,,.T.,, {FwX3Titulo('BM_GRUPO'), FwX3Titulo('BM_DESC')} ) //"Grupo de Produto"
		//-- Adiciona no vetor aRet somente os grupos selecionados.
		For nCntFor := 1 To Len( aGrp )
			If	aGrp[ nCntFor, 1 ]
				AAdd( aRet, { aGrp[ nCntFor, 2 ], aGrp[ nCntFor, 3 ] } )
			EndIf
		Next
	Else
		Return( .F. )
	EndIf
EndIf

Return( aRet )


//----------------------------------------------------------------------
/*/{Protheus.doc} TmsMsgErr
//
@author Alex Egydio 
@since 08/07/2002
@version 1.0
@return ${return}, ${return_description}
@param aMsgErr, array, Array das Mensagens de Erro 
	Dentro de cada registro do array, utilizamos o seguinte padrão
	aMsgErr[1][1] -> Mensagem do erro em uma única linha.
		Ex.: Mensagem de erro - Tabela AAA não possui o campo AAA_TESTE - Atualize seu ambiente via UPDDISTR
	aMsgErr[1][2] -> Não utilizado. 
	aMsgErr[1][3] -> Função a ser aberta no "Mais Detalhes".
	aMsgErr[1][4] -> Mensagem do erro tabulada em múltiplas linhas (Ao executar duplo clique sobre a linha de ERRO
					 será aberto uma tela memo com o conteúdo da posição [1][4] do array. Caso a posição [1][4] não seja
					 preenchida, o duplo clique trará o conteudo da posição [1][1]).
					 O objetivo é apresentar a mensagem formatada com o enter.
					 Ex1.: Mensagem de erro
					 	   Tabela AAA não possui o campo AAA_TESTE
					 	   Atualize seu ambiente via UPDDISTR 
			 
@param cMsg, characters, String para o Titulo da Mensagem
@type function
/*/
//----------------------------------------------------------------------
Function TmsMsgErr( aMsgErr, cMsg, lAuto )
//-- Mensagem, codigo, rotina
Local aButtons	:= {}
Local cLbx		:= ''
Local oDlgEsp
Local oLbxEsp
Local nOpcao    := 0
Local nCnt

Default cMsg    := STR0017 //'Mensagem'
Default lAuto   := IsBlind() //-- se não houver interface com o usuário, não montar a Dialog


If !lAuto
	//--Verifica se foi enviada acao para
	//--o botao de "Acoes"
	If Len(aMsgErr) > 0 .And. Len(aMsgErr[1]) >= 3
		AAdd( aButtons, { 'DESTINOS', { || Iif(!Empty(aMsgErr[oLbxEsp:nAT,3]), Iif( TmsAcesso(,aMsgErr[ oLbxEsp:nAT, 3 ]), TMSAvalFun( aMsgErr[ oLbxEsp:nAT, 3 ] ),.F.),.F.) }, STR0011 , STR0012 } ) //"Mais detalhes"
	EndIf
	
	AAdd( aButtons, { 'RELATORIO', { || TMSImpErr( aMsgErr ) }, STR0014 , STR0015 } ) //"Relatorio"
	
	DEFINE MSDIALOG oDlgEsp TITLE STR0016 FROM 00,00 TO 350,769 PIXEL //"Verifique os dados..."
		@ 30,01 LISTBOX oLbxEsp VAR cLbx FIELDS HEADER cMsg SIZE 383,142 OF oDlgEsp PIXEL
		oLbxEsp:SetArray( aMsgErr )
		oLbxEsp:bLine	:= { || { aMsgErr[ oLbxEsp:nAT, 1 ] } }
	ACTIVATE MSDIALOG oDlgEsp CENTERED ON INIT EnchoiceBar( oDlgEsp, {|| oDlgEsp:End(), nOpcao := 1 },{|| oDlgEsp:End() },, aButtons )
Else
	AutoGrLog(cMsg)
	For nCnt := 1 To Len(aMsgErr)
		AutoGrLog('[' + AllToChar( aMsgErr[nCnt][1] ) + ']' )
	Next nCnt
	nOpcao := 1
EndIf

Return( nOpcao == 1 )

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSErrDtl()
Tela de detalhes de erro da função TmsMsgErr()
@author  Gustavo Krug
@since   08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMSErrDtl(cMsgErr) 
Local oDlMemo := nil
Local cDescMemo := ""
Local nX := 0
Local nOpcao    := 0
 
	DEFINE MSDIALOG oDlMemo FROM 000,000 TO 350,769 TITLE STR0016 PIXEL //"Verifique os dados..."
		// @ 30,010 MSGET cDescMemo OF oDlMemo Size 368,127  WHEN .F. PIXEL 
		@ 020,030  GET cDescMemo VAR cMsgErr OF oDlMemo MEMO size 328,135 WHEN .F. PIXEL
		oDlMemo:lEscClose := .T.
    ACTIVATE MSDIALOG oDlMemo CENTERED// ON INIT EnchoiceBar( oDlMemo, {|| oDlMemo:End(), nOpcao := 1 },{|| oDlMemo:End() },, )

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TMSVldCli  ³ Autor ³ Patricia A. Salomao ³ Data ³ 16/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o Codigo do Cliente Informado e' de Cliente Gene-³±±
±±³          ³ rico (MV_CLIGEN)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVldCli(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Cliente                                  ³±±
±±³          ³ ExpC2 - Loja do Cliente                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVldCli(cCodCli, cLojCli)

Local lRet      := .T.
Local cCliGen   := GetMV('MV_CLIGEN')

Default cCodCli := ''
Default cLojCli := ''

If !Empty(cCliGen) .And. cCodCli+cLojCli == cCliGen
	Help("",1,"TMSXFUNB01")  //Codigo Invalido. O Codigo Informado e' de Cliente Generico ...
	lRet := .F.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TMSTbAtiva ³ Autor ³ Richard Anderson    ³ Data ³ 19/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica vigencia da tabela e se a mesma esta ativa        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSTbAtiva(ExpC1,ExpC2,ExpL1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela                                             ³±±
±±³          ³ ExpC2 - Tipo da Tabela                                     ³±±
±±³          ³ ExpL1 - Exibe Help ?                                       ³±±
±±³          ³ ExpL2 - Tabela de Seguro ?                                 ³±±
±±³          ³ ExpC3 - Categoria da Tabela de Frete :1-Frete a Receber    ³±±
±±³          ³                                       2-Frete a Pagar      ³±±
±±³          ³ ExpL3- .T. Considera os LayOuts com Data de Inicio de Vigen³±±
±±³          ³       cia maior que a DataBase.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSTbAtiva( cTabela, cTipTab, lHelp, lTabSeguro, cCatTab, lConsDataDe)

Local   lRet        := .T.
Local   aAreaDTL    := {}
Local   cAliasNew   := ''
Local   cQuery      := ''

Default lHelp       := .T.
Default lTabSeguro  := .F.
Default cCatTab     := StrZero(1,Len(DTL->DTL_CATTAB)) // Categoria da Tabela : Frete a Receber
Default lConsDataDe := .F. // NAO Considera os LayOuts com Data de Inicio de Vigencia maior que a DataBase.

If lTabSeguro
	If !Empty(cTabela) .And. !Empty(cTipTab)
		cAliasNew := GetNextAlias()
		cQuery := " SELECT COUNT(DU4_FILIAL) CNT "
		cQuery += " FROM " + RetSqlName("DU4")
		cQuery += "   WHERE DU4_FILIAL = '" + xFilial("DU4") + "' "
		cQuery += "     AND DU4_TABSEG = '" + cTabela + "' "
		cQuery += "     AND DU4_TPTSEG = '" + cTipTab + "' "
		If lConsDataDe
			cQuery += "     AND DU4_DATDE  <= '" + DtoS(dDataBase) + "' "
		EndIf
		cQuery += "     AND ( DU4_DATATE = ' ' OR DU4_DATATE >= '" + DtoS(dDataBase) + "' ) "
		cQuery += "     AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
		If (cAliasNew)->CNT == 0
			lRet := .F.
			If lHelp
				Help("",1,"TMSXFUNB02" ) // Tabela fora da vigencia ou invativa
			EndIf
		EndIf
		(cAliasNew)->(DbCloseArea())
	EndIf
Else
	If Empty( cTabela ) .Or. Empty( cTipTab )
		lRet := .T.
	Else
		aAreaDTL := DTL->( GetArea() )
		DTL->( DbSetOrder( 1 ) )
		If DTL->( MsSeek( xFilial() + cTabela + cTipTab ) )
			If ( IIf( lConsDataDe, .F., dDataBase < DTL->DTL_DATDE ) .Or. ;
				Iif(!Empty(DTL->DTL_DATATE),dDataBase > DTL->DTL_DATATE,.F.))
				If lHelp
					Help("",1,"TMSXFUNB02" ) // Tabela fora da vigencia ou invativa
				EndIf
				lRet := .F.
			EndIf

			If lRet .And. DTL->DTL_CATTAB <> cCatTab // Categoria da Tabela
			   If cCatTab == StrZero(1,Len(DTL->DTL_CATTAB)) // Categoria da Tabela : Frete a Receber
					Help('',1,'TMSXFUNB31') // Tabela de Frete Invalida ... Informe uma Tabela de Frete com Categoria 'Frete a Receber' ...
				ElseIf cCatTab == StrZero(2,Len(DTL->DTL_CATTAB)) // Categoria da Tabela : Frete a Pagar
					Help('',1,'TMSXFUNB32') // Tabela de Frete Invalida ... Informe uma Tabela de Frete com Categoria 'Frete a Pagar' ...
				EndIf
				lRet := .F.
			EndIf

		Else
			If lHelp
				Help("",1,"TMSXFUNB03" ) // Erro ao verificar vigencia da tabela
			EndIf
			lRet := .F.
		EndIf
		RestArea( aAreaDTL )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSDelBxEs³ Autor ³ Richard Anderson      ³ Data ³27.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancela baixa do estoque dos documentos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSDelBxEst(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Origem da Viagem                         ³±±
±±³          ³ ExpC2 - No. da Viagem                                      ³±±
±±³          ³ ExpC3 - Filial do Documento                                ³±±
±±³          ³ ExpC4 - No. do Documento                                   ³±±
±±³          ³ ExpC5 - Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDelBxEst( cFilOri, cViagem, cFilDoc, cDocto, cSerie )

Local   cDocDT6   := ""
Local   cDocSD2   := ""
Local   cPedido   := ""
Local   cDocBxe   := ""
Local   cSerBxe   := ""
Local   cSeek     := ""
Local   bWhile    := {||.F.}
Local   lRet      := .F.
Local   lExistDoc := .F.
Local   cTes      := GetMV('MV_TESDD',,"")
Local   aAreaDUD  := {}

DEFAULT cFilDoc   := ""
DEFAULT cDocto    := ""
DEFAULT cSerie    := ""

//-- Nao realiza a Atualizacao do Estoque, se o Tes de Saida estiver configurado
//-- para NAO Atualizar Estoque
SF4->( DbSetOrder( 1 ) )
If	SF4->(MsSeek(xFilial('SF4') + cTes, .F.)) .And. SF4->F4_ESTOQUE == "N"
	Return( .T. )
EndIf

SD2->( DbSetOrder( 3 ) )
DT6->( DbSetOrder( 1 ) )

aAreaDUD := DUD->( GetArea() )
If Empty( cFilDoc )
	DUD->( DbSetOrder( 2 ) )
	DUD->( MsSeek( cSeek := xFilial('DUD') + cFilOri + cViagem ) )
	bWhile := { || DUD->( !Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeek ) }
Else
	DUD->( DbSetOrder( 1 ) )
	DUD->( MsSeek( cSeek := xFilial('DUD') + cFilDoc + cDocto + cSerie + cFilOri + cViagem ) )
	bWhile := { || DUD->( !Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM == cSeek ) }
EndIf

While Eval( bWhile )

	If Empty( DUD->DUD_DOCBXE )
		DUD->( DbSkip() )
		Loop
	EndIf

	// Permite o estorno somente dos documentos da filial corrente.
	If DUD->DUD_FILFEC != cFilAnt
		DUD->( DbSkip() )
		Loop
	EndIf

	lExistDoc := .T.

	cDocDT6 := DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE )
	cDocBxe := DUD->DUD_DOCBXE
	cSerBxe := DUD->DUD_SERBXE
	cDocSD2 := cDocBxe+cSerBxe

	If DT6->( !MsSeek( xFilial( 'DT6' ) + cDocDT6 ) )
		Final(STR0018, cDocDT6 ) //"Erro ao Localizar Docto. de Transporte No. "
	EndIf

	If DT6->DT6_BLQDOC == "1" // Bloqueio de Docto
		DUD->( DbSkip() )
		Loop
	EndIf

	If SD2->( !MsSeek( xFilial( 'SD2' ) + cDocSD2 ) )
		Final(STR0019, cDocSD2 ) //"Erro ao Localizar Docto. de Saida No. "
	EndIf

	// Pedido para exclusao
	cPedido := SD2->D2_PEDIDO
	lRet    := .T.

	//-- Estorna Docto. de Saida
	TMSDelNFS( cDocBxe, cSerBxe )

	//-- Estorna pedidos de venda
	aCab := {}
	AAdd( aCab, { 'C5_NUM', cPedido, Nil } )
	TMSPedido( aCab,, 5 )

	//-- Atualiza campos de controle de baixa de estoque
	RecLock( 'DUD', .F. )
	DUD->DUD_DOCBXE := CriaVar( 'DUD_DOCBXE', .F. )
	DUD->DUD_SERBXE := CriaVar( 'DUD_SERBXE', .F. )
	MsUnLock()

	DUD->( DbSkip() )
EndDo
RestArea( aAreaDUD )

// Caso não tenha tido nenhum documento para baixar estoque, retorna verdadeiro para atualizar viagem
If !lRet .And. !lExistDoc
	lRet := .T.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSTipo  ³ Autor ³ Alex Egydio           ³ Data ³08.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3( DLC ) para visualizar os tipos:               ³±±
±±³          ³ Servico de transporte;                                     ³±±
±±³          ³ Tipo de transporte;                                        ³±±
±±³          ³ Documento de transporte;                                   ³±±
±±³          ³ Tipo de ocorrencia.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTipo(cCampo)

Local lTodos    := .F.
Local lRet		  := .T.
Default cCampo  := ReadVar()

If Left(FunName(1),7) == "TMSA950"
	lTodos := .T.
EndIf

If "MV_PAR" $ cCampo
	cCampo := "DOCTMS"
EndIf

lRet := TMSValField(cCampo,,,.T.,,lTodos)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVerDoc ³ Autor ³ Patricia A. Salomao   ³ Data ³22.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica as Ocorrencias do Documento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVerDoc(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpL1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - No. do Documento                                   ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±³          ³ ExpC4 - Servico de Transporte                              ³±±
±±³          ³ ExpC5 - Tipo da Ocorrencia                                 ³±±
±±³          ³ ExpL1 - Verif. se devera/nao mostrar os Helps na Tela      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVerDoc(cFilDoc, cDoc, cSerie, cSerTMS, cTipOco,lHelp)

Local aAreaAnt  := GetArea()
Local lRet      := .T.

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cSerTMS := ""
Default cTipOco := ""
Default lHelp   := .T.

DT2->(DbSetOrder(3))
If !DT2->(MsSeek(xFilial('DT2')+cSerTMS+cTipOco) )
	If lHelp
		Help('',1,'TMSXFUNB04',,STR0020 +  cSerTMS + STR0021 + cTipOco,2,1) // Ocorrencia Nao Encontrada###"Serviço de Transp.: "###" Tipo Ocorrencia : "
	EndIf
	lRet := .F.
EndIf

If lRet

    Do While !DT2->(Eof()) .And. DT2->DT2_FILIAL+DT2->DT2_SERTMS+DT2->DT2_TIPOCO == xFilial('DT2')+cSerTMS+cTipOco

		If DT2->DT2_CATOCO == '1' // Categoria da Ocorrencia por Documento

			DUA->(DbSetOrder(3))
			If !DUA->(MsSeek(xFilial('DUA')+DT2->DT2_CODOCO+cFilDoc+cDoc+cSerie))
				If lHelp
					Help('',1,'TMSXFUNB05',,AllTrim(TmsValField('DT2->DT2_SERTMS',.F.)) + STR0022 + cDoc+cSerie ,2,1) // Nao foi Realizada(o) a(o) ...###" do Documento : "
				EndIf
				lRet := .F.
			Else
				If DT2->DT2_TIPOCO == "06" .And.  DT2->DT2_TIPPND == "04"
					lRet := .F.
				EndIf
			EndIf

		ElseIf DT2->DT2_CATOCO == '2' // Categoria da Ocorrencia por Viagem

		    DUD->(DbSetOrder(1))
			If DUD->(MsSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie))
			 		Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI) == xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilAnt

						DTQ->(DbSetOrder(2))
						If DTQ->(MsSeek(xFilial('DTQ')+DUD->(DUD_FILORI+DUD_VIAGEM) )) .And. DTQ->DTQ_SERTMS == cSerTMS
					    	DUA->(DbSetOrder(4))
					    	If !DUA->(MsSeek(xFilial('DUA')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM) ))
								If lHelp
									Help('',1,'TMSXFUNB05',,AllTrim(TmsValField('DTQ->DTQ_SERTMS',.F.)) + STR0022 + cDoc+cSerie ,2,1) // Nao foi Realizada(o) a(o) ...###" do Documento : "
								EndIf
						      lRet := .F.
						      Exit
							EndIf

						Else
							If lHelp
								Help('',1,'TMSXFUNB05',,AllTrim(TmsValField(DTQ->DTQ_SERTMS,.F.)) + STR0022 + cDoc+cSerie ,2,1) // Nao foi Realizada(o) a(o) ...###" do Documento : "
	        					lRet := .F.
   	    				EndIf
						EndIf

				    	DUD->(dbSkip())
					EndDo
			Else
				If lHelp
				    Help('',1,'TMSXFUNB06') // Documento Nao Encontrado ...
				EndIf
				lRet := .F.

			EndIf
		EndIf

		DT2->(dbSkip())

	EndDo

EndIf
RestArea(aAreaAnt)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsDoc   ³ Autor ³ Patricia A. Salomao   ³ Data ³22.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro dos Documentos de Transporte                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsDoc()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsDoc()
Local aAreaSA1  	:= SA1->(GetArea())
Local cCadastro 	:= STR0023 //"Documentos"
Local aRotOld   	:= aClone(aRotina)
Local aCampos   	:= {}
Local aCamposTRB	:= {}
Local oTempTable   	:= NIL
Local nDias	    := SuperGetMV( 'MV_DIASCET',, 180 ) //-- Qtde de Dias para busca do doc
Local cAliasQry 	:= GetNextAlias()
Local cAliasTRB 	:= GetNextAlias()
Local cFiltro1	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aRotina := {}
Private nOpcSel := 0

AAdd( aRotina, {STR0024,"TMSConfSel",0,2,,,.T.} )  //"Confirmar"

If (IsInCallStack('TMSAF76'))
	AAdd(aCampos, { "DT6_FILDOC", "@!", RetTitle("DT6_FILDOC"), TamSX3("DT6_FILDOC")[1] })
	AAdd(aCampos, { "DT6_DOC"    , "@!", RetTitle("DT6_DOC")   , TamSX3("DT6_DOC")[1] })
	AAdd(aCampos, { "DT6_SERIE"  , "@!", RetTitle("DT6_SERIE"), TamSX3("DT6_SERIE")[1] })
	AAdd(aCampos, { "DT6_DATEMI" , "@!", RetTitle("DT6_DATEMI"), TamSX3("DT6_DATEMI")[1] })
	AAdd(aCampos, { "DT6_CLIREM" , "@!", RetTitle("DT6_CLIREM"), TamSX3("DT6_CLIREM")[1] })
	AAdd(aCampos, { "DT6_LOJREM" , "@!", RetTitle("DT6_LOJREM"), TamSX3("DT6_LOJREM")[1] })
	AAdd(aCampos, { "DT6_NOMREM" , "@!", RetTitle("DT6_NOMREM"), TamSX3("DT6_NOMREM")[1] })
	AAdd(aCampos, { "DT6_CLIDES" , "@!", RetTitle("DT6_CLIDES"), TamSX3("DT6_CLIDES")[1] })
	AAdd(aCampos, { "DT6_LOJDES" , "@!", RetTitle("DT6_LOJDES"), TamSX3("DT6_LOJDES")[1] })
	AAdd(aCampos, { "DT6_NOMDES" , "@!", RetTitle("DT6_NOMDES"), TamSX3("DT6_NOMDES")[1] })

	AAdd(aCamposTRB, { "DT6_FILDOC",  "C",TamSX3("DT6_FILDOC")[1], TamSX3("DT6_FILDOC")[2] })
	AAdd(aCamposTRB, { "DT6_DOC"   ,  "C", TamSX3("DT6_DOC")[1]   , TamSX3("DT6_DOC")[2] })
	AAdd(aCamposTRB, { "DT6_SERIE" ,  "C", TamSX3("DT6_SERIE")[1], TamSX3("DT6_SERIE")[2] })
	AAdd(aCamposTRB, { "DT6_DATEMI" , "D", TamSX3("DT6_DATEMI")[1], TamSX3("DT6_DATEMI")[2] })
	AAdd(aCamposTRB, { "DT6_CLIREM" , "C", TamSX3("DT6_CLIREM")[1], TamSX3("DT6_CLIREM")[2] })
	AAdd(aCamposTRB, { "DT6_LOJREM" , "C", TamSX3("DT6_LOJREM")[1], TamSX3("DT6_LOJREM")[2] })
	AAdd(aCamposTRB, { "DT6_NOMREM" , "C", TamSX3("DT6_NOMREM")[1], TamSX3("DT6_NOMREM")[2] })
	AAdd(aCamposTRB, { "DT6_CLIDES" , "C", TamSX3("DT6_CLIDES")[1], TamSX3("DT6_CLIDES")[2] })
	AAdd(aCamposTRB, { "DT6_LOJDES" , "C", TamSX3("DT6_LOJDES")[1], TamSX3("DT6_LOJDES")[2] })
	AAdd(aCamposTRB, { "DT6_NOMDES" , "C", TamSX3("DT6_NOMDES")[1], TamSX3("DT6_NOMDES")[2] })

	oTempTable := FWTemporaryTable():New(cAliasTRB)
	oTempTable:SetFields( aCamposTRB )
	oTempTable:AddIndex("01", {"DT6_FILDOC"} )
	oTempTable:Create()
	

	cQuery := " 	SELECT  DT6_FILDOC,  "
	cQuery += " 		DT6_DOC, "
	cQuery += " 		DT6_SERIE, "
	cQuery += " 		DT6_DATEMI, "
	cQuery += " 		DT6_FILIAL, "
	cQuery += " 		DT6_CLIREM, "
	cQuery += " 		DT6_LOJREM, "
	cQuery += " 		SA1REM.A1_NOME DT6_NOMREM,  "
	cQuery += " 		DT6_CLIDES, "
	cQuery += " 		DT6_LOJDES, "
	cQuery += " 		SA1DES.A1_NOME DT6_NOMDES "

	cQuery += "	FROM " + RetSqlName("DT6") +  " DT6 "

	cQuery += " 	JOIN " + RetSqlName("SA1") +  " SA1REM ON 	SA1REM.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " 	 AND SA1REM.A1_COD	= DT6.DT6_CLIREM "
	cQuery += " 	 AND SA1REM.A1_LOJA	= DT6.DT6_LOJREM  "
	cQuery += " 	 AND SA1REM.D_E_L_E_T_ = ' ' "

	cQuery += " 	JOIN " + RetSqlName("SA1") +  " SA1DES ON 	SA1DES.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " 	 AND SA1DES.A1_COD	= DT6.DT6_CLIDES "
	cQuery += " 	 AND SA1DES.A1_LOJA	= DT6.DT6_LOJDES  "
	cQuery += " 	 AND SA1DES.D_E_L_E_T_ = ' ' "

	cQuery += " 	WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
	cQuery += " 	  AND DT6.DT6_CLIDEV = '" + SA1->A1_COD  + "'"
	cQuery += " 	  AND DT6.DT6_LOJDEV = '" + SA1->A1_LOJA + "'"
	cQuery += " 	  AND DT6.DT6_LOTCET = ' ' "
	cQuery += " 	  AND DT6.DT6_STATUS = '7' "
	cQuery += " 	  AND DT6.DT6_DOCTMS <> '1' "
	cQuery += " 	  AND DT6.DT6_DATEMI >= '" + Dtos(dDataBase - nDias ) + "' "
	cQuery += " 	  AND DT6.DT6_DATEMI <= '" + Dtos(dDataBase) + "' "
	cQuery += " 	  AND DT6.D_E_L_E_T_ = ' ' "

	cQuery += " 	ORDER BY DT6_FILDOC,DT6_DOC,DT6_SERIE "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	While (cAliasQry)->(!Eof())
		RecLock(cAliasTRB,.T.)
		(cAliasTRB)->DT6_FILDOC 	:= (cAliasQry)->DT6_FILDOC
		(cAliasTRB)->DT6_DOC    	:= (cAliasQry)->DT6_DOC
		(cAliasTRB)->DT6_SERIE 	:= (cAliasQry)->DT6_SERIE
		(cAliasTRB)->DT6_DATEMI 	:= Stod((cAliasQry)->DT6_DATEMI)
		(cAliasTRB)->DT6_CLIREM 	:= (cAliasQry)->DT6_CLIREM
		(cAliasTRB)->DT6_LOJREM  := (cAliasQry)->DT6_LOJREM
		(cAliasTRB)->DT6_NOMREM  := (cAliasQry)->DT6_NOMREM
		(cAliasTRB)->DT6_CLIDES 	:= (cAliasQry)->DT6_CLIDES
		(cAliasTRB)->DT6_LOJDES  := (cAliasQry)->DT6_LOJDES
		(cAliasTRB)->DT6_NOMDES  := (cAliasQry)->DT6_NOMDES
		MsUnlock()
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbGotop())

	MaWndBrowse(0,0,300,600,cCadastro,cAliasTRB,aCampos,aRotina,,,,.T.,,,,,.F.)

	DbSelectArea("DT6")
	DT6->(dbSetOrder(1))
	DT6->(MsSeek(xFilial("DT6")+(cAliasTRB)->DT6_FILDOC+(cAliasTRB)->DT6_DOC+(cAliasTRB)->DT6_SERIE))

	//-- Apaga os arquivos temporarios
	oTempTable:Delete()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os campos do Browse.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aCampos, "DT6_FILDOC")
	AAdd(aCampos, "DT6_DOC")
	AAdd(aCampos, "DT6_SERIE")
	AAdd(aCampos, "DT6_DATEMI")
	AAdd(aCampos, "DT6_CLIREM")
	AAdd(aCampos, "DT6_LOJREM")
	AAdd(aCampos, "DT6_NOMREM")
	AAdd(aCampos, "DT6_CLIDES")
	AAdd(aCampos, "DT6_LOJDES")
	AAdd(aCampos, "DT6_NOMDES")


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DT6->(DbSetOrder(6)) //DT6_FILIAL+DT6_CLIREM+DT6_LOJREM+DT6_LOTCET+DT6_FILDOC+DT6_DOC+DT6_SERIE
	cFiltro1 := '"'+xFilial("DT6")+SA1->A1_COD+SA1->A1_LOJA+Space(Len(DT6->DT6_LOTCET))+'"'

	MaWndBrowse(0,0,300,600,cCadastro,"DT6",aCampos,aRotina,,cFiltro1,cFiltro1,.T.)
EndIf

aRotina := aClone(aRotOld)
RestArea(aAreaSA1)
Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsRetPeso³ Autor ³ Alex Egydio           ³ Data ³25.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa se o calculo do componente sera pelo peso real ou  ³±±
±±³          ³ peso cubado                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do contrato                                 ³±±
±±³          ³ ExpC2 = Codigo do servico                                  ³±±
±±³          ³ ExpC3 = Componente de frete                                ³±±
±±³          ³ ExpL1 = (referencia) .T.=peso real;.F.=Peso cubado         ³±±
±±³          ³ ExpN1 = Peso real                                          ³±±
±±³          ³ ExpN2 = Peso cubado                                        ³±±
±±³          ³ ExpN3 = Metro cubico                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Peso                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsRetPeso( cNContr, cServic, cCodPas, lPesoReal, nPeso, nPesoM3, nMetro3, nRecDT9, nRecDT3, cCodNeg )

Local aAreaDT3
Local aAreaDT9
Local cCalPes  := ''
Local nRet     := 0

DEFAULT cNContr   := ''
DEFAULT cServic   := ''
DEFAULT cCodPas   := ''
DEFAULT lPesoReal := .T.
DEFAULT nPeso     := 0
DEFAULT nPesoM3   := 0
DEFAULT nMetro3   := 0
DEFAULT nRecDT9   := 0
DEFAULT nRecDT3   := 0
DEFAULT cCodNeg   := ""
//-- Defaut peso real
nRet := nPeso
lPesoReal:= .T.

If nRecDT9 == 0 .And. nRecDT3 == 0
	aAreaDT3 := DT3->(GetArea())
	aAreaDT9 := DT9->(GetArea())
	If !Empty(cCodPas)
		If	! Empty(cNContr) .And. ! Empty(cServic)
			//-- Posiciona configuracao de componentes por contrato
			DT9->(DbSetOrder( 1 ))
			If	DT9->(MsSeek( xFilial('DT9') + cNContr + cServic + cCodPas + cCodNeg ))
				cCalPes := DT9->DT9_CALPES
			EndIf
		EndIf
		//-- Posiciona componentes de frete
		DT3->(DbSetOrder( 1 ))
		If Empty(cCalPes) .And. DT3->(MsSeek( xFilial('DT3') + cCodPas ))
			cCalPes := DT3->DT3_CALPES
		EndIf
		//-- Peso cubado
		If cCalPes == StrZero(2,Len(DT9->DT9_CALPES)) .And. ! Empty(nPesoM3)
			nRet := Max(nPesoM3,nPeso)
			lPesoReal:= .F.
		//-- Metro cubico
		ElseIf cCalPes == StrZero(3,Len(DT9->DT9_CALPES)) .And. ! Empty(nMetro3)
			nRet := nMetro3
			lPesoReal:= .F.
		EndIf
	EndIf

	RestArea(aAreaDT9)
	RestArea(aAreaDT3)

Else

	If !Empty(cCodPas)
		If	! Empty(cNContr) .And. ! Empty(cServic) .And. ! Empty(cCodNeg)
			//-- Posiciona configuracao de componentes por contrato
			If nRecDT9 > 0
				DT9->( DbGoto(nRecDT9) )
				cCalPes := DT9->DT9_CALPES
			EndIf
		EndIf
		//-- Posiciona componentes de frete
		DT3->( DbGoto(nRecDT3) )
		If Empty(cCalPes)
			cCalPes := DT3->DT3_CALPES
		EndIf
		//-- Peso cubado
		If cCalPes == StrZero(2,Len(DT9->DT9_CALPES)) .And. ! Empty(nPesoM3)
			nRet := Max(nPesoM3,nPeso)
			lPesoReal:= .F.
		//-- Metro cubico
		ElseIf cCalPes == StrZero(3,Len(DT9->DT9_CALPES)) .And. ! Empty(nMetro3)
			nRet := nMetro3
			lPesoReal:= .F.
		EndIf
	EndIf

Endif

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsRetRota³ Autor ³ Robson Alves          ³ Data ³30.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a rota com base nos parametros recebidos.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Cliente.                                 ³±±
±±³          ³ ExpC2 = Loja do Cliente.                                   ³±±
±±³          ³ ExpC3 = Cep.                                               ³±±
±±³          ³ ExpC4 = Servico de Transporte                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Array[1,1] = Recno do DA7 / Array[1,2] = Rota              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRetRota(cCliente, cLoja, cCep, cSerTms)

Local aAreaDA7   := {}
Local aArea      := {}
Local aRetorno   := {}
Local cAliasTRB  := ""

Default cCliente := ""
Default cLoja    := ""
Default cCep     := ""
Default cSerTMS  := ""

aArea      := GetArea()
aAreaDA7   := DA7->(GetArea())

cAliasTRB := GetNextAlias()

//-- Verifica a rota por cliente
If !Empty(cCliente) .And. !Empty(cLoja)
	cQuery := " SELECT DA7.R_E_C_N_O_, DA9.DA9_ROTEIR "
	cQuery += "   FROM "
	cQuery += RetSqlName("DA7") + " DA7, "
	cQuery += RetSqlName("DA9") + " DA9 "
	If !Empty(cSerTms)
		cQuery += ", " + RetSqlName("DA8") + " DA8 "
	EndIf
	cQuery += "   WHERE DA7.DA7_FILIAL = '" + xFilial("DA7") + "' "
	cQuery += "     AND DA7.DA7_CLIENT = '" + cCliente + "' "
	cQuery += "     AND DA7.DA7_LOJA   = '" + cLoja    + "' "
	cQuery += "     AND DA7.D_E_L_E_T_ = ' ' "
	cQuery += "     AND DA9.DA9_FILIAL = '" + xFilial("DA9") + "' "
	cQuery += "     AND DA9.DA9_PERCUR = DA7.DA7_PERCUR "
	cQuery += "     AND DA9.DA9_ROTA   = DA7.DA7_ROTA "
	cQuery += "     AND DA9.D_E_L_E_T_ = ' ' "
	If !Empty(cSerTms)
		cQuery += "     AND DA8.DA8_FILIAL = '" + xFilial("DA8") + "' "
		cQuery += "     AND DA8.DA8_COD    = DA9.DA9_ROTEIR "
		cQuery += "     AND DA8.DA8_SERTMS = '" + cSerTms + "' "
		cQuery += "     AND DA8.DA8_ATIVO  = '1' "
		cQuery += "     AND DA8.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)

	While (cAliasTRB)->(!Eof())
		AAdd(aRetorno, {(cAliasTRB)->R_E_C_N_O_,(cAliasTRB)->DA9_ROTEIR})
		(cAliasTRB)->(dbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())
	RestArea(aArea)
EndIf

//-- Verifica a rota por faixa de CEP
If Empty(aRetorno)
	If Empty(cCep)
		cCep := M_Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_CEP")
	EndIf
	cQuery := " SELECT DA7.R_E_C_N_O_, DA9.DA9_ROTEIR "
	cQuery += "   FROM "
	cQuery += RetSqlName("DA7") + " DA7, "
	cQuery += RetSqlName("DA9") + " DA9 "
	If !Empty(cSerTms)
		cQuery += ", " + RetSqlName("DA8") + " DA8 "
	EndIf
	cQuery += "   WHERE DA7.DA7_FILIAL = '" + xFilial("DA7") + "' "
	cQuery += "     AND DA7.DA7_CEPDE  <= '" + cCep + "' "
	cQuery += "     AND DA7.DA7_CEPATE >= '" + cCep + "' "
	cQuery += "     AND DA7.D_E_L_E_T_ = ' ' "
	cQuery += "     AND DA9.DA9_FILIAL = '" + xFilial("DA9") + "' "
	cQuery += "     AND DA9.DA9_PERCUR = DA7.DA7_PERCUR "
	cQuery += "     AND DA9.DA9_ROTA   = DA7.DA7_ROTA "
	cQuery += "     AND DA9.D_E_L_E_T_ = ' ' "
	If !Empty(cSerTms)
		cQuery += "     AND DA8.DA8_FILIAL = '" + xFilial("DA8") + "' "
		cQuery += "     AND DA8.DA8_COD    = DA9.DA9_ROTEIR "
		cQuery += "     AND DA8.DA8_SERTMS = '" + cSerTms + "' "
		cQuery += "     AND DA8.DA8_ATIVO  = '1' "
		cQuery += "     AND DA8.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)

	While (cAliasTRB)->(!Eof())
		AAdd(aRetorno, {(cAliasTRB)->R_E_C_N_O_,(cAliasTRB)->DA9_ROTEIR})
		(cAliasTRB)->( DbSkip() )
	EndDo
	(cAliasTRB)->(DbCloseArea())
	RestArea(aArea)
EndIf

If Len( aRetorno ) == 0
	AAdd( aRetorno, { 0, Space( Len( DA9->DA9_ROTEIR ) ) } )
EndIf

Return( aRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsSldDist³ Autor ³ Alex Egydio           ³ Data ³05.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se houve enderecamento para o documento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do documento                                ³±±
±±³          ³ ExpC2 = Documento                                          ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpL1 = Exibe help                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsSldDist(cFilDoc,cDocto,cSerie,lHelp)

Local aAreaAnt	:= GetArea()
Local cSeek		:= ''
Local lRet		:= .T.
Local nSaldoSDA := 0

DEFAULT cFilDoc := ''
DEFAULT cDocto	:= ''
DEFAULT cSerie	:= ''
DEFAULT lHelp	:= .T.

//-- Verifica se o TES informado no Parametro MV_TESDR esta' OK ...
If !TmsChkTES('1')
	Return( .F. )
EndIf

//-- Se o TES informado no Parametro MV_TESDR, NAO atualizar estoque ...
If SF4->F4_ESTOQUE == 'N'
	Return( .T. )
EndIf

DTC->(DbSetOrder(3))
If	DTC->(MsSeek( cSeek := xFilial('DTC') + cFilDoc + cDocto + cSerie ))
	While DTC->( ! Eof() .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == cSeek )
		If	!Empty(DTC->DTC_QTDVOL) .And. Localiza(DTC->DTC_CODPRO)
			SD1->(DbSetOrder(1))
			If	SD1->(MsSeek( xFilial('SD1') + DTC->DTC_NUMNFC + DTC->DTC_SERNFC + DTC->DTC_CLIREM + DTC->DTC_LOJREM + DTC->DTC_CODPRO ))
				SDA->(DbSetOrder(1))
				If	SDA->(MsSeek( xFilial('SDA') + SD1->D1_COD + SD1->D1_LOCAL + SD1->D1_NUMSEQ + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ))
					nSaldoSDA += SDA->DA_SALDO
				Else
					If	lHelp
						Help('',1,'TMSXFUNB09',,STR0025 + SD1->D1_COD +'/'+ SD1->D1_LOCAL +'/'+ SD1->D1_DOC +'/'+ SD1->D1_SERIE ,4,1)		//-- Saldos a distribuir nao encontrado. (SDA)###"Produto/Armazem/Doc./Serie : "
					EndIf
					lRet := .F.
					Exit
				EndIf
			Else
				If	lHelp
					Help('',1,'TMSXFUNB08',,STR0026 + DTC->DTC_NUMNFC +'/'+ DTC->DTC_SERNFC +'/'+ DTC->DTC_CLIREM +'/'+ DTC->DTC_LOJREM +'/'+ DTC->DTC_CODPRO,4,1)		//-- Nota Fiscal do cliente nao encontrada. (SD1)###"Nota/Serie/Cliente/Loja/Produto : "
				EndIf
				lRet := .F.
				Exit
			EndIf
		EndIf
		DTC->(DbSkip())
	EndDo
EndIf

If lRet .And. ! Empty( nSaldoSDA )
	If	lHelp
		Help('',1,'TMSXFUNB10',,STR0027 + cFilDoc +'/'+ cDocto +'/'+ cSerie,4,1)	//-- Documento nao enderecado###"Fil.Doc./Doc./Serie : "
	EndIf
	lRet := .F.
EndIf
RestArea(aAreaAnt)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsRegTrib³ Autor ³ Henry Fila            | Data ³14.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de retorno da regra de tributacao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Documento de transporte                            ³±±
±±³          ³ ExpC2 = Tipo de Frete                                      ³±±
±±³          ³ ExpC3 = Codigo do componente                               ³±±
±±³          ³ ExpC4 = Cliente devedor                                    ³±±
±±³          ³ ExpC5 = Loja devedor                                       ³±±
±±³          ³ ExpC6 = Codigo da regiao de destino                        ³±±
±±³          ³ ExpL7 = Indica se caso nao exista regras exibira um help   ³±±
±±³          ³ ExpC7 = Codigo do Produto definido na Regra de Tributacao  ³±±
±±³          ³         p/ Cliente                                         ³±±
±±³          ³ ExpL8 = Regra por Componente                               ³±±
±±³          ³ ExpC8 = Estado de origem do documento                      ³±±
±±³          ³ ExpC9 = Devedor = Consignatario (1=Sim/2=Nao)              ³±±
±±³          ³ ExpC10= Tipo da NF (0-Normal;1-Devolucao;2-SubContratacao) ³±±
±±³          ³ ExpC11= Sequencia da Inscricao estadual do cliente         ³±±
±±³          ³ ExpC12= Estado do veículo da viagem                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 = Codigo do Tes da Regra                             ³±±
±±³          ³ ExpA2 = Codigo da mensagem (Campo Memo) da nota fiscal     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsRegTrib(cDocTms,cTipFre,cCodPas,cCliDev,cLojDev,cCdrDes,lHelp,cCodPro,lRegPorComp,cEstOri,lConsig,cTipNFC,cSeqIns,cEstVei)
Static lCpoConsig 	:= ( nModulo == 43 )
Local aRetorno    	:= {}
Local aBusca      	:= {}
Local aRegCli     	:= {}
Local cCliGen     	:= Left(GetMv("MV_CLIGEN"),Len(SA1->A1_COD))
Local cLojGen     	:= Right(GetMv("MV_CLIGEN"),Len(SA1->A1_LOJA))
Local cEstDes     	:= Space(Len(SA1->A1_EST))
Local cEstDev     	:= Space(Len(SA1->A1_EST))
Local cAtivid     	:= Space(Len(SA1->A1_SATIV1))
Local cTipCli     	:= ''
Local cVzTipCli   	:= Space(Len(DV1->DV1_TIPCLI))
Local cVzSeqIns   	:= Space(Len(DV1->DV1_SEQINS))
Local nX          	:= 0
Local nQtParam    	:= 5 //-- PARAMETROS QUE DEVEM SER VALIDADOS = 5
Local cQuery      	:= ''
Local cAliasNew   	:= GetNextAlias()
Local cLinha      	:= ''
Local nCount      	:= 0
Local nItemMax    	:= 0
Local aProcOK     	:= {}
Local aResult     	:= {}
Local nRet        	:= 0
Local cExec       	:= ""
Local lRet1       	:=.T.
Local lExecPad    	:=.T.
Local iX          	:= 0
Local cQueryAux	  	:= ""
Local cAliasAux	  	:= ""
Local cAuxSeek	  	:= ""
Local aAuxSeek		:= {}
Local lFoundDV1	  	:= .F.
Local nRecnoDV1		:= 0
Local oHashDV1
Local xValHash
Local nAuxDUG		:= 0

DEFAULT cTipFre     := "3"
DEFAULT cCliDev     := cCliGen
DEFAULT cLojDev     := cLojGen
DEFAULT cCodPas     := Space(Len(DUG->DUG_CODPAS))
DEFAULT lHelp       := .F.
DEFAULT cCodPro     := Space(Len(SB1->B1_COD))
DEFAULT lRegPorComp := .T.
DEFAULT cEstOri     := ''
DEFAULT cEstVei     := ''
DEFAULT lConsig     := .F.
DEFAULT cTipNFC     := ''
DEFAULT cSeqIns     := ''

If	Empty(cEstOri)
	cEstOri := GetMV('MV_ESTADO')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca estado do cliente devedor                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+cCliDev+cLojDev))
	cEstDev := SA1->A1_EST
	cAtivid := SA1->A1_SATIV1
	cTipCli := SA1->A1_TIPO
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca estado da regiao de destino                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCdrDes)
	DUY->(DbSetOrder(1))
	If DUY->(MsSeek(xFilial("DUY")+cCdrDes))
		cEstDes := DUY->DUY_EST
		//-- Se Devedor for o Cliente Generico e o Tipo de Frete for 'FOB'
		If cCliDev+cLojDev == cCliGen+cLojGen .And. cTipFre == '2'
			cEstDev := cEstDes
		EndIf
	EndIf
EndIf

//aRetorno := {}
//aRetorno := GetRegTrib( cCodPas, cEstOri, cEstDev, cEstDes, cAtivid, lConsig, cDocTms, cCodPro, DV1->DV1_REGTRI, cEstVei)

If Len(aRetorno) == 0
	TmsCriaProc() // Cria Procedures dinâmicas  HABILIATAR QDO CHAMAR PELA FORMULA

	If lTempProc .and.aTempProc != Nil
		//      aTempProc[1] -> lRet  - .T. Se criou as procedures
		//      aTempProc[2] -> cProc - Nome da procedure sem a empresa
		//      aTempProc[3] -> aProc - arrauy com todas as procedures
		//      aTempProc[4] -> cArqTemp - Arquivo Temporário
		//aProcOk := TmsRegProc()
		//TMSLogMsg(,'Termino Criação :'+Time())
		If aTempProc[1]
				aResult := TCSPExec( xProcedures(aTempProc[2]), cFilAnt,;
														  If(Len(cCliDev)== 0,' ',  cCliDev),  If(Len(cLojDev)== 0,' ',  cLojDev),;
			                                              If(Len(cDocTms)== 0,' ',  cDocTms),  If(Len(cCodPro)== 0,' ',  cCodPro),;
			                                              If(Len(cTipNFC)== 0,' ',  cTipNFC),  If(Len(cTipCli)== 0,' ',  cTipCli),;
			                                              If(Len(cSeqIns)== 0,' ',  cSeqIns),  If(Len(cVzSeqIns)== 0,' ',cVzSeqIns),;
			                                              If(Len(cVzTipCli)== 0,' ',cVzTipCli),If(Len(cCliGen)== 0,' ',  cCliGen),;
														  If(Len(cLojGen)== 0,' ',  cLojGen),  If(Len(cTipFre)== 0,' ',  cTipFre),;
														  If(lConsig,'1','0'),If(lCpoConsig, '1', '0'),;
														  If(Len(cCodPas)== 0,' ',  cCodPas),  If(Len(cEstOri)== 0,' ',  cEstOri),;
														  If(Len(cEstDev)== 0,' ',  cEstDev),  If(Len(cEstDes)== 0,' ',  cEstDes),;
														  If(Len(cAtivid)== 0,' ',  cAtivid),  If(Len(cEstVei)== 0,' ',  cEstVei), nQtParam)
			If Empty(aResult) //.Or. aResult[1] = "0"
				MsgAlert(tcsqlerror(),"Erro na busca da Regra de Tributaçao! ")
				lExecPad := .T.
			Else
				aRetorno := Aclone( aResult )
				If Len(Alltrim(aREtorno[1]))==0 .and. Len(Alltrim(aRetorno[2]))==0 .and. Len(Alltrim(aRetorno[3]))==0
					aRetorno := {}
					lExecPad := .T.
				Else
					lExecPad := .F.
				EndIf
			EndIf
		EndIf
		/* -------------------------------------------------------------------
			Exclui as procedures criadas e o Temporário
		   ------------------------------------------------------------------- */
	 	TmsDelProc()       //Exclui procedures dinâmicas  HABILIATAR QDO CHAMAR PELA FORMULA
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analise combinatoria para busca da regra de tributacao por Cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExecPad
	//01 - XXXXXXXX
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cTipCli+cSeqIns   })
	//02 - XXXXXXX-
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cTipCli+cVzSeqIns })
	//03 - XXXXXX-X
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cVzTipCli+cSeqIns   })
	//04 - XXXXXX--
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cVzTipCli+cVzSeqIns })
	//05 - XXXX--XX
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })
	//06 - XXXX--X-
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns })
	//07 - XXXX---X
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })
	//08 - XXXX----
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns })
	//09 - XXXXX-XX
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })
	//10 - XXXXX-X-
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns })
	//11 - XXXXX--X
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })
	//12 - XXXXX---
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns })
	//13 - XXXX-XXX
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cSeqIns   })
	//14 - XXXX-XX-
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cVzSeqIns })
	//15 - XXXX-X-X
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cSeqIns   })
	//16 - XXXX-X--
	AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cVzSeqIns })
	//17 - XXXXXXXX
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cTipCli+cSeqIns   })
	//18 - XXXXXXX-
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cTipCli+cVzSeqIns })
	//19 - XXXXXX-X
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cVzTipCli+cSeqIns   })
	//20 - XXXXXX--
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cVzTipCli+cVzSeqIns })
	//21 - XXXX--XX
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })
	//22 - XXXX--X-
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns })
	//23 - XXXX---X
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })
	//24 - XXXX----
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns })
	//25 - XXXXX-XX
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })
	//26 - XXXXX-X-
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns })
	//27 - XXXXX--X
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })
	//28 - XXXXX---
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns })
	//29 - XXXX-XXX
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cSeqIns   })
	//30 - XXXX-XX-
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cVzSeqIns })
	//31 - XXXX-X-X
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cSeqIns   })
	//32 - XXXX-X--
	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cVzSeqIns })

	//-- Tratamento para armazenamento da querie em cache
	If _oRegDV1 == Nil

		_oRegDV1	:= FWPreparedStatement():New()

		cQueryAux 	:= " SELECT DV1_FILIAL, DV1_CODCLI, DV1_LOJCLI, DV1_DOCTMS, DV1_CODPRO, DV1_TIPNFC, DV1_TIPCLI, DV1_SEQINS, R_E_C_N_O_ DV1RECNO "
		cQueryAux	+= " FROM " + RetSQLName("DV1") + " DV1 "
		cQueryAux	+= " WHERE DV1_FILIAL = ? "
		cQueryAux	+= " AND ( ( DV1_CODCLI = ? AND DV1_LOJCLI = ?  )"
		cQueryAux 	+= " OR (  DV1_CODCLI = ? AND DV1_LOJCLI = ?  ) ) "
		cQueryAux	+= " AND DV1_DOCTMS = ? "
		cQueryAux	+= " AND DV1.D_E_L_E_T_ = ' ' "
		cQueryAux	:= ChangeQuery(cQueryAux)

		_oRegDV1:SetQuery(cQueryAux)

	EndIf

	_oRegDV1:SetString(1,xFilial('DV1'))
	_oRegDV1:SetString(2,cCliDev)
	_oRegDV1:SetString(3,cLojDev)
	_oRegDV1:SetString(4,cCliGen)
	_oRegDV1:SetString(5,cLojGen)
	_oRegDV1:SetString(6,cDocTms)

	DV1->(DbSetOrder(1)) //DV1_FILIAL+DV1_CODCLI+DV1_LOJCLI+DV1_DOCTMS+DV1_CODPRO+DV1_TIPNFC+DV1_TIPCLI+DV1_SEQINS+DV1_REGTRI

	cAliasAux	:= GetNextAlias()
	cQueryAux	:= _oRegDV1:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAux),cAliasAux)

	While (cAliasAux)->(!Eof())
		cAuxSeek	:= (cAliasAux)->(DV1_FILIAL+DV1_CODCLI+DV1_LOJCLI+DV1_DOCTMS+DV1_CODPRO+DV1_TIPNFC+DV1_TIPCLI+DV1_SEQINS)
		Aadd( aAuxSeek , { cAuxSeek , (cAliasAux)->(DV1RECNO) })
		(cAliasAux)->(dbSkip())
	EndDo

	(cAliasAux)->(dbCloseArea())

	If Len(aAuxSeek) > 0

		//-- Objeto tabela HASH
		oHashDV1	:= AToHM( aAuxSeek , 1 ,2) //-- ELIMINA ESPAÇOS A DIREITA

		For nX := 1 to Len(aRegCli)

			//-- Busca registro na tabela HASH
			If HMGet(oHashDV1, RTrim(aRegCli[nX][1]) , @xValHash )
				lFoundDV1	:= .T.
				nRecnoDV1	:= xValHash[1,2]
				Exit
			EndIf

		Next

	EndIf

	If lFoundDV1

		//-- Posiciona no Recno da DV1 encontrada
		DV1->(dbGoTo(nRecnoDV1))

		aRetorno := {}
		aRetorno := GetRegTrib( cCodPas, cEstOri, cEstDev, cEstDes, cAtivid, lConsig, cDocTms, cCodPro, DV1->DV1_REGTRI, cEstVei)

		If Len(aRetorno) == 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca regra de tributacao por cliente                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUF->(DbSetOrder(1)) //DUF_FILIAL+DUF_REGTRI+DUF_TIPFRE
			If cTipFre == "1" .Or. cTipFre == "2"
				If	DUF->(!MsSeek(xFilial("DUF")+DV1->DV1_REGTRI+cTipFre))
					DUF->( MsSeek(xFilial("DUF")+DV1->DV1_REGTRI+"3"))
				EndIf
			ElseIf Empty(cTipFre) .Or. cTipFre == "3"
				DUF->(MsSeek(xFilial("DUF")+DV1->DV1_REGTRI+StrZero(3,Len(DUF->DUF_TIPFRE)) ))
			EndIf

			If DUF->(Found())

				/*---------------------------------------------------------------------------
				//-- Analisa a regra de tributacao
				//-- Se Encontrar na Regra algum componente cadastrado, analisa a regra para todos os componentes
				//-- do Frete, caso contrario, executara' a TMSRegTrib() uma unica vez, pois a regra de tributacao
				//-- sera' a mesma para todos os componentes.
				---------------------------------------------------------------------------*/

				DUG->(DbSetOrder(2)) //DUG_FILIAL+DUG_REGTRI+DUG_TIPFRE+DUG_CODPAS+DUG_ESTORI+DUG_ESTDEV+DUG_ESTDES+DUG_SATIV+DUG_CONSIG
				DUG->(MsSeek(xFilial('DUG')+DUF->DUF_REGTRI+DUF->DUF_TIPFRE+Padr( 'z', Len( DT3->DT3_CODPAS ) ) , .T.))
				DUG->(dbSkip(-1))
				If DUG->(DUG_FILIAL+DUG_REGTRI+DUG_TIPFRE) == xFilial('DUG')+DUF->DUF_REGTRI+DUF->DUF_TIPFRE .And.;
					Empty(DUG->DUG_CODPAS)
					lRegPorComp	:= .F.
				EndIf

				//------------------------------------------
				//-- BUSCAR O MAIOR ITEM CADASTRADO NA BASE
				//------------------------------------------
				nItemMax := 0
				cQuery += " SELECT MAX(DUG_ITEM) DUG_ITEM "
				cQuery += "   FROM " + RetSqlName("DUG")
				cQuery += "  WHERE DUG_FILIAL = '" + xFilial("DUG") + "' "
				cQuery += "    AND DUG_REGTRI = '" + DUF->DUF_REGTRI + "' "
				cQuery += "    AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
				nItemMax := Val((cAliasNew)->DUG_ITEM)
				(cAliasNew)->( DbCloseArea() )

				If _oTribDUG == NIl .Or. ( _lConsig <> lConsig .Or. _lCpoConsig <> lCpoConsig )

					_oTribDUG 	:= FWPreparedStatement():New()
					_lConsig	:= lConsig
					_lCpoConsig	:= lCpoConsig
					_lAtuFwPrep	:= .T. 

					If lCpoConsig .And. !lConsig
						cQuery 	:= " SELECT CASE "
						cQuery	+= " DUG_CONSIG WHEN '1'  THEN 99  ELSE 1 END CONSIGDUG , " //-- Prioriza por último o campo DUG_CONSIG = 1=Sim
					Else
						cQuery	:= " SELECT "
					EndIf

					cQuery	+= " DUG_FILIAL, DUG_REGTRI, DUG_TIPFRE, DUG_ITEM, DUG_TES, DUG_CODMSG, DUG_CODPAS, DUG_ESTORI, DUG_ESTDEV, DUG_ESTDES, DUG_SATIV, DUG_ESTVEI"
					cQuery 	+= " FROM " + RetSqlName("DUG")
					cQuery 	+= " WHERE DUG_FILIAL 	= ? "
					cQuery 	+= "  	AND DUG_REGTRI 	= ? "
					cQuery 	+= "   	AND DUG_TIPFRE 	= ? "

					If lCpoConsig
						If lConsig //-- Consignatario
							cQuery += "  AND ( DUG_CONSIG 	= ?  OR DUG_CONSIG = ? )" 	//-- Sim ou Ambos
						Else
							cQuery += "  AND DUG_CONSIG IN ( ? , ? , ? , ? ) " 			//-- Ambos;Não;Vazio;Sim
						EndIf
					EndIf

					cQuery 	+= " AND D_E_L_E_T_ = ' ' "

					If lCpoConsig .And. !lConsig
						cQuery += " ORDER BY 1,  " + SqlOrder(DUG->(IndexKey()))
					Else
						cQuery += " ORDER BY " + SqlOrder(DUG->(IndexKey()))
					EndIf

					cQuery := ChangeQuery( cQuery )

					_oTribDUG:SetQuery(cQuery)

				Else
					_lAtuFwPrep		:= .F. 
				EndIf

				_oTribDUG:SetString(1,xFilial('DUG'))
				_oTribDUG:SetString(2,DUF->DUF_REGTRI )
				_oTribDUG:SetString(3,DUF->DUF_TIPFRE )

				If lCpoConsig
					If lConsig
						_oTribDUG:SetString(4,StrZero(1,Len(DUG->DUG_CONSIG)) ) //-- Sim
						_oTribDUG:SetString(5,StrZero(3,Len(DUG->DUG_CONSIG)) )	//-- Ambos
					Else
						_oTribDUG:SetString(4,StrZero(3,Len(DUG->DUG_CONSIG)) ) //-- Ambos
						_oTribDUG:SetString(5,StrZero(2,Len(DUG->DUG_CONSIG)) ) //-- Não
						_oTribDUG:SetString(6,Space(Len(DUG->DUG_CONSIG)) )		//-- Vazio
						_oTribDUG:SetString(7,StrZero(1,Len(DUG->DUG_CONSIG)) ) //-- Sim
					EndIf
				EndIf

				cAliasNew	:= GetNextAlias()
				cQuery		:= _oTribDUG:GetFixQuery()	//-- Retorna querie do objeto

				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exemplo dos Parametros Fornecidos do Documento                          ³
				//³ Componente	Origem	Devedor			Destino		Atividade	TipoDoc		³
				//³ 01			SP			SP			SP			''			1			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exemplo de Base de Dados                                                                        ³
				//³                                                                                                 ³
				//³            * UTILIZADOS PARA COMPARACAO COM OS PARAMETROS *   *FILTRO*                          ³
				//³ Item	TES	Componente	Origem	Devedor	Destino	Atividade	TipoDoc	Total de Campos = Parametros³
				//³ 01		501	''			''		''		''		''			1			1						³
				//³ 02		502	01			''		''		SP		''			0			3						³
				//³ 03		503	''			SP		''		''		''			1			2						³
				//³ 04		501	''			''		''		''		''			2			1						³
				//³ 05		502	01			SP		SP		SP		''			1			5						³
				//³ 06		503	01			SP		SP		SP		000001		3			4						³
				//³ 07		502	''			SP		''		''		''			0			2						³
				//³ 08		501	''			SP		''		''		''			2			2						³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exemplo de Resultado da Query (Sem considerar a clausula do Consignatario)                      ³
				//³                                                                                                 ³
				//³            * UTILIZADOS PARA COMPARACAO COM OS PARAMETROS *   *FILTRO*                          ³
				//³ Item	TES	Componente	Origem	Devedor	Destino	Atividade	TipoDoc	Total de Campos = Parametros³
				//³ 01		501	''			''		''		''		''			1		1							³
				//³ 03		503	''			SP		''		''		''			1		2							³
				//³ 05		502	01			SP		SP		SP		''			1		5							³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Para o Exemplo acima, sera definida como retorno a TES 502, uma vez que os 5 Campos encontrados ³
				//³ na, pesquisa, sao identicos aos 5 parametros passados a rotina.                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cLinha   := ''
				aRetorno := {}
				aBusca   := {}
				nAuxDUG	 := 0

				While (cAliasNew)->( !Eof() )

					//-- Tratamento realizado para identificar se campo DUG_CONSIG está diferente de 1=Sim, não deverá considerar o que está com 1=Sim
					If lCpoConsig .And. !lConsig
						If nAuxDUG == 0
							nAuxDUG	:= (cAliasNew)->CONSIGDUG
						ElseIf nAuxDUG == 1 .And. nAuxDUG <> (cAliasNew)->CONSIGDUG
                            (cAliasNew)->(DbSkip())
							Loop
						EndIf
					EndIf

					SF4->(dbSetOrder(1))
					If SF4->(MsSeek(xFilial('SF4')+(cAliasNew)->DUG_TES))
						If	SF4->F4_MSBLQL == '1' //TES Bloqueadas nao podem ser utilizadas.
							(cAliasNew)->(DbSkip())
							Loop
						EndIf
					EndIf

					cLinha :=	Iif( Empty((cAliasNew)->DUG_CODPAS),Space(Len((cAliasNew)->DUG_CODPAS)), (cAliasNew)->DUG_CODPAS) + ;
								Iif( Empty((cAliasNew)->DUG_ESTORI),Space(Len((cAliasNew)->DUG_ESTORI)), (cAliasNew)->DUG_ESTORI) + ;
								Iif( Empty((cAliasNew)->DUG_ESTDEV),Space(Len((cAliasNew)->DUG_ESTDEV)), (cAliasNew)->DUG_ESTDEV) + ;
								Iif( Empty((cAliasNew)->DUG_ESTDES),Space(Len((cAliasNew)->DUG_ESTDES)), (cAliasNew)->DUG_ESTDES) + ;
								Iif( Empty((cAliasNew)->DUG_SATIV ),Space(Len((cAliasNew)->DUG_SATIV )), (cAliasNew)->DUG_SATIV) 	+ ;
								Iif( Empty((cAliasNew)->DUG_ESTVEI),Space(Len((cAliasNew)->DUG_ESTVEI)), (cAliasNew)->DUG_ESTVEI)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ CASO EXISTA APENAS UM REGISTRO E ESSE ESTEJA COM TODOS OS CAMPOS³
					//³ EM BRANCO, ESSE SERA CONSIDERADO COMO SENDO A TES DE RETORNO.   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (Empty(cLinha)) .And. Len(aBusca) == 0
						aRetorno := {(cAliasNew)->DUG_TES,(cAliasNew)->DUG_CODMSG,M_Posicione('SF4',1,xFilial('SF4') + (cAliasNew)->DUG_TES,'F4_ISS')}
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ CASO TODOS OS PARAMETROS PASSADOS A FUNCAO SEJAM DIFERENTES DOS VALORES ³
					//³ ENCONTRADOS PELA CONSULTA, NAO PERMITIR QUE ESSE REGISTRO TORNE-SE UM   ³
					//³ ELEMENTO NO VETOR DE COMBINACOES PARA BUSCA DA REGRA DE TRIBUTACAO      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If	((cAliasNew)->DUG_CODPAS != cCodPas) .And.;
						((cAliasNew)->DUG_ESTORI != cEstOri) .And.;
						((cAliasNew)->DUG_ESTDEV != cEstDev) .And.;
						((cAliasNew)->DUG_ESTDES != cEstDes) .And.;
						((cAliasNew)->DUG_SATIV  != cAtivid) .And.;
						((cAliasNew)->DUG_ESTVEI != cEstVei)
						cLinha := ''
					EndIf

					nCount := 0
					If !(Empty(cLinha))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ ADICIONAR AO VETOR UM ELEMENTO INDICANDO A QUANTIDADE DE CAMPOS QUE FORAM INFORMADOS COMO PARAMETROS³
						//³ DE PESQUISA E QUE SEJAM IGUAIS AOS VALORES ENCONTRADOS PELA CONSULTA (SELECT). ESSE ELEMENTO SERVIRA³
						//³ PARA ORDENAR O VETOR E DEFINIR A PRIORIDADE DE LEITURA, LENDO DO QUE CONTEM MAIS CAMPOS A SEREM     ³
						//³ VALIDADOS PARA O MENOR.                                                                             ³
						//³                                                                                                     ³
						//³ CASO TODOS OS PARAMETROS SEJAM = AOS VALORES ENCONTRADOS PELO SELECT, A ROTINA FORCARA A SAIDA DO   ³
						//³ WHILE, SENDO ATUALMENTE 5 PARAMETROS (FIXOS) X 5 CAMPOS + CAMPOS VALIDADOS PELO FieldPos('...') > 0.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nCount :=	Iif( IIf(Empty(cCodPas),.F.,(cAliasNew)->DUG_CODPAS == cCodPas), 1, 0) + ;
									Iif( IIf(Empty(cEstOri),.F.,(cAliasNew)->DUG_ESTORI == cEstOri), 1, 0) + ;
									Iif( IIf(Empty(cEstDev),.F.,(cAliasNew)->DUG_ESTDEV == cEstDev), 1, 0) + ;
									Iif( IIf(Empty(cEstDes),.F.,(cAliasNew)->DUG_ESTDES == cEstDes), 1, 0) + ;
									Iif( IIf(Empty(cAtivid),.F.,(cAliasNew)->DUG_SATIV  == cAtivid), 1, 0) + ;
									Iif( IIf(Empty(cEstVei),.F.,(cAliasNew)->DUG_ESTVEI == cEstVei), 1, 0)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ QUANTIDADE TOTAL DE CAMPOS QUE ATUALMENTE DEVEM SEREM VALIDADOS (5 FIXOS), MAIS OS  ³
						//³ EXISTENTES NA BASE (FIELDPOS > 0), OU SEJA, CASO TODOS SEJAM IGUAIS NA VALIDACAO    ³
						//³ ANTERIOR (nCount := Iif(...)) INDICARA QUE TODOS PARAMETROS ATENDEM A PESQUISA, E   ³
						//³ DESSA FORMA, ESSA SERA A T.E.S DE RETORNO                                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nCount == nQtParam
							aBusca   := {}
							aRetorno := {}
							// DEFININDO A TES DE RETORNO.
							aRetorno := {(cAliasNew)->DUG_TES,(cAliasNew)->DUG_CODMSG,M_Posicione('SF4',1,xFilial('SF4') + (cAliasNew)->DUG_TES,'F4_ISS')}

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ CASO SEJA(M) ENCONTRADO(S) OUTRA(S) POSSIVEL COMBINACAO QUALQUER,            ³
						//³ "ZERAR" O VETOR aRETORNO E ADICIONAR AO VETOR TODAS AS POSSIVEIS COMBINACOES ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ O ULTIMO ITEM DO VETOR aBusca, CONTEM UMA ROTINA (nItemMax - Val((cAliasNew)->DUG_ITEM) CONCATENANDO COM 	³
							//³ A VARIAVEL nCount. A ROTINA (nItemMax - Val((cAliasNew)->DUG_ITEM) FAZ COM QUE O NUMERO DO ITEM, TORNE-SE 	³
							//³ O CONTRARIO, OU SEJA, QUANDO O ITEM FOR 01 E O ULTIMO ITEM ENCONTRADO FOR 100, O ITEM 01 TORNA-SE 99.		³
							//³ ISSO FOI UTILIZADO PORQUE O aSort NAO FAZ ORDENACOES DISTINTAS E ESSA ROTINA PRECISA ORDENAR O VETOR PELO 	³
							//³ MAIOR nCount E PELO MENOR NUMERO DE ITEM, O QUE EH IMPOSSIVEL FAZER COM aSort. A SAIDA FOI "INVERTER" O 	³
							//³ NUMERO DO ITEM, DE FORMA QUE ELE POSSA SER ORDENADO PELO MAIOR VALOR, JUNTAMENTE COM A VARIAVEL nCount.		³
							//³ EXEMPLO:																									³
							//³ 	nItemMax IGUAL A 100.																					³
							//³ 	VETOR ANTES DO aSort																					³
							//³ Val((cAliasNew)->DUG_ITEM))		nItemMax - Val((cAliasNew)->DUG_ITEM))	nCount	StrZero(nCount,...			³
							//³ 01								99										3		0399						³
							//³ 02								98										4		0498						³
							//³ 03								97										5		0597						³
							//³ 04								96										3		0396						³
							//³ 05								95										3		0395						³
							//³ 06								94										5		0594						³
							//³ 07								93										4		0493						³
							//³ 08								92										3		0392						³
							//³                                                                                                             ³
							//³     VETOR APOS O aSort                                                                                      ³
							//³ Val((cAliasNew)->DUG_ITEM))		nItemMax - Val((cAliasNew)->DUG_ITEM))	nCount	StrZero(nCount,...			³
							//³ 03								97										5		0597						³
							//³ 06								94										5		0594						³
							//³ 02								98										4		0498						³
							//³ 07								93										4		0493						³
							//³ 01								99										3		0399						³
							//³ 04								96										3		0396						³
							//³ 05								95										3		0395						³
							//³ 08								92										3		0392						³
							//³                                                                                                             ³
							//³ DESSA MANEIRA A ROTINA VALIDARA A LINHA EM QUE O MAIOR NUMERO DE CAMPO ATENDEM OS PARAMETROS (nCount)       ³
							//³ E O MENOR ITEM CADASTRADO NA ROTINA DE REGRAS DE TRIBUTACAO, AONDE FOI INCLUSA UMA FUNCIONALIDADE           ³
							//³ QUE PERMITE RE-ORDENAR ESSE CADASTRO E ASSIM, DEFINIR A PRIORIDADE DE CADA TES.                             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aRetorno := {}
							Aadd(aBusca,{	DUF->DUF_REGTRI,;
											DUF->DUF_TIPFRE,;
											Iif( Empty((cAliasNew)->DUG_CODPAS),Space(Len((cAliasNew)->DUG_CODPAS)), cCodPas),;
											Iif( Empty((cAliasNew)->DUG_ESTORI),Space(Len((cAliasNew)->DUG_ESTORI)), cEstOri),;
											Iif( Empty((cAliasNew)->DUG_ESTDEV),Space(Len((cAliasNew)->DUG_ESTDEV)), cEstDev),;
											Iif( Empty((cAliasNew)->DUG_ESTDES),Space(Len((cAliasNew)->DUG_ESTDES)), cEstDes),;
											Iif( Empty((cAliasNew)->DUG_SATIV) ,Space(Len((cAliasNew)->DUG_SATIV)) , cAtivid),;
											Iif( Empty((cAliasNew)->DUG_ESTVEI),Space(Len((cAliasNew)->DUG_ESTVEI)), cEstVei)})

							Aadd(aBusca[ Len(abusca) ], Val((cAliasNew)->DUG_ITEM))
							Aadd(aBusca[ Len(abusca) ], nItemMax - Val((cAliasNew)->DUG_ITEM))
							Aadd(aBusca[ Len(abusca) ], nCount)
							Aadd(aBusca[ Len(abusca) ], StrZero(nCount, Len(DUG->DUG_ITEM)) + StrZero(nItemMax - Val((cAliasNew)->DUG_ITEM), Len(DUG->DUG_ITEM)) )  // MANTER SEMPRE ESSE ELEMENTO NA ULTIMA POSICAO PARA QUE FUNCIONE A ROTINA ABAIXO (aSort)
						EndIf
					EndIf

					If nCount == nQtParam
						Exit
					EndIf

					(cAliasNew)->( DbSkip() )

					cLinha := ''
					nCount := 0
				EndDo

				// CASO NAO TENHA SIDO DEFINIDA A TES DE RETORNO
				If Len(aRetorno) == 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ EXECUTAR PROCESSO DE ORDENACAO SOMENTE QUANDO HOUVER³
					//³ MAIS DE UMA COMBINACAO NO VETOR aBUSCA.             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aBusca) > 1
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ ORDENAR O VETOR PELO ELEMENTO DE QUANTIDADE DE CAMPOS   ³
						//³ IDENTICOS AOS PARAMETROS (ULTIMO ELEMENTO -> nCount)    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aSort( aBusca,,, {|x,y| x[Len(aBusca[Len(aBusca)])] > y[Len(aBusca[Len(aBusca)])]})
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ ADICIONAR AO VETOR UMA LINHA CONTENDO TODOS OS ELEMENTOS EM BRANCO. ³
					//³                                                                     ³
					//³ PARA OS CASOS EM QUE TODAS AS COMBINACOES EXISTENTES NO VETOR aBUSCA³
					//³ NAO ATENDAM AS COMBINACOES, SERA DEFINIDA COMO A T.E.S DE RETORNO   ³
					//³ PELA ROTINA TmsaRegra, CUJA T.E.S TIVER CADASTRADA COM TODOS OS     ³
					//³ CAMPOS EM BRANCO.                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Aadd(aBusca,{	DUF->DUF_REGTRI,;
									DUF->DUF_TIPFRE,;
									Space(Len((cAliasNew)->DUG_CODPAS)),;
									Space(Len((cAliasNew)->DUG_ESTORI)),;
									Space(Len((cAliasNew)->DUG_ESTDEV)),;
									Space(Len((cAliasNew)->DUG_ESTDES)),;
									Space(Len((cAliasNew)->DUG_SATIV )),;
									Space(Len((cAliasNew)->DUG_ESTVEI))})

					Aadd(aBusca[ Len(abusca) ], 0)
					Aadd(aBusca[ Len(abusca) ], 0)
					Aadd(aBusca[ Len(abusca) ], 0)
					Aadd(aBusca[ Len(abusca) ], '0000')

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca codigo do tes e da mensagem fiscal               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 to Len(aBusca)
						aRetorno := TmsaRegra(aBusca[nX][1], aBusca[nX][2], aBusca[nX][3], aBusca[nX][4], aBusca[nX][5], aBusca[nX][6], aBusca[nX][7], lConsig, aBusca[nX][8])
						If Len(aRetorno) > 0
							Exit
						Endif
					Next
				EndIf

				(cAliasNew)->( DbCloseArea() )
				// FIM DA ROTINA NOVA //////////////////////////////////////////////////////////////////////////////////////
			Endif
		Endif
	EndIf

	SetRegTrib( cCodPas, cEstOri, cEstDev, cEstDes, cAtivid, lConsig, cDocTms, cCodPro, DV1->DV1_REGTRI, aRetorno, cEstVei )
EndIf

If Len(aRetorno) == 0 .And. lHelp
	Help(' ',1,'TMSXFUNB11',,STR0028 + cDocTms + ' / ' + STR0029 + SA1->A1_COD + ' / ' + SA1->A1_LOJA + ' / ' + STR0030 + cCdrDes + ' / ' + STR0031 + cTipFre + ' / ' + STR0032 + cCodPas,4,1) //"Docto.Transp: "###"Cliente: "###"Destino: "###"Tp.Frete: "###"Componente: "
EndIf

//-- Exclui memória de array
FWFreeObj(aAuxSeek)

Return( aRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsaRegra ³ Autor ³ Henry Fila            | Data ³14.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de retorno da regra de tributacao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Documento de transporte                            ³±±
±±³          ³ ExpC2 = Tipo de Frete                                      ³±±
±±³          ³ ExpC3 = Codigo do componente                               ³±±
±±³          ³ ExpC4 = Cliente devedor                                    ³±±
±±³          ³ ExpC5 = Loja devedor                                       ³±±
±±³          ³ ExpC6 = Cliente Destino                                    ³±±
±±³          ³ ExpC7 = Loja destino                                       ³±±
±±³          ³ ExpC8 = Ramo de Atividade                                  ³±±
±±³          ³ ExpC9 = Consignatario (T=Sim/F=Nao)                        ³±±
±±³          ³ ExpC10= Estado do veículo da viagem                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsaRegra(cRegTri,cTipFre,cCodPas,cEstOri,cEstDev,cEstDes,cAtividade,lConsig, cEstVei )

Static lCpoConsig := ( nModulo == 43 )
Local aRetorno    := {}
Local cQuery      := ''
Local cAliasNew   := GetNextAlias()

Default cEstVei  := ""

If _oRegDUG	== Nil .Or. ( _lAtuFwPrep .Or. _lConsig <> lConsig .Or. _lCpoConsig <> lCpoConsig )

	_oRegDUG	:= FwPreparedStatement():New()

	//-- Busca regra de tributacao por cliente
	cQuery := " SELECT DUG_TES, DUG_CODMSG "
	cQuery += "  FROM " + RetSqlName("DUG")
	cQuery += "  WHERE DUG_FILIAL = ? "
	cQuery += "    AND DUG_REGTRI = ? "
	cQuery += "    AND DUG_TIPFRE = ? "
	cQuery += "    AND DUG_CODPAS = ? "
	cQuery += "    AND DUG_ESTORI = ? "
	cQuery += "    AND DUG_ESTDEV = ? "
	cQuery += "    AND DUG_ESTDES = ? "
	cQuery += "    AND DUG_SATIV  = ? "
	cQuery += "    AND DUG_ESTVEI = ? "

	If lCpoConsig
		If lConsig //-- Consignatario
			cQuery += " AND (DUG_CONSIG = ? " //-- Sim
			cQuery += " OR DUG_CONSIG = ? ) " //-- ambos
		Else
			cQuery += " AND ( DUG_CONSIG IN ( ? , ? , ' ')"
			cQuery += "  OR ( DUG_CONSIG = ? AND NOT EXISTS "
			cQuery += "     ( SELECT 1 FROM " + RetSqlName("DUG")
			cQuery += "         WHERE DUG_FILIAL = ? "
			cQuery += "           AND DUG_REGTRI = ? "
			cQuery += "           AND DUG_TIPFRE = ? "
			cQuery += "           AND DUG_CODPAS = ? "
			cQuery += "           AND DUG_ESTORI = ? "
			cQuery += "           AND DUG_ESTDEV = ? "
			cQuery += "           AND DUG_ESTDES = ? "
			cQuery += "           AND DUG_SATIV  = ? "
			cQuery += "           AND DUG_ESTVEI = ? "
			cQuery += "           AND DUG_CONSIG IN ( ? , ? , ' ')"
			cQuery += "           AND D_E_L_E_T_ = ' ' ))) "
		EndIf
	EndIf
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )

	_oRegDUG:SetQuery(cQuery)

EndIf

_oRegDUG:SetString(1,xFilial("DUG"))
_oRegDUG:SetString(2,cRegTri)
_oRegDUG:SetString(3,cTipFre)
_oRegDUG:SetString(4,cCodPas)
_oRegDUG:SetString(5,cEstOri)
_oRegDUG:SetString(6,cEstDev)
_oRegDUG:SetString(7,cEstDes)
_oRegDUG:SetString(8,cAtividade)
_oRegDUG:SetString(9,cEstVei)

If lCpoConsig
	If lConsig //-- Consignatario
		_oRegDUG:SetString(10,StrZero(1,Len(DUG->DUG_CONSIG)))
		_oRegDUG:SetString(11,StrZero(3,Len(DUG->DUG_CONSIG)))
	Else
		_oRegDUG:SetString(10,StrZero(2,Len(DUG->DUG_CONSIG)) )
		_oRegDUG:SetString(11,StrZero(3,Len(DUG->DUG_CONSIG)) )
		_oRegDUG:SetString(12,StrZero(1,Len(DUG->DUG_CONSIG)) )
		_oRegDUG:SetString(13,xFilial("DUG") )
		_oRegDUG:SetString(14,cRegTri )
		_oRegDUG:SetString(15,cTipFre )
		_oRegDUG:SetString(16,cCodPas )
		_oRegDUG:SetString(17,cEstOri )
		_oRegDUG:SetString(18,cEstDev )
		_oRegDUG:SetString(19,cEstDes )
		_oRegDUG:SetString(20,cAtividade )
		_oRegDUG:SetString(21,cEstVei )
		_oRegDUG:SetString(22,StrZero(2,Len(DUG->DUG_CONSIG)) )
		_oRegDUG:SetString(23,StrZero(3,Len(DUG->DUG_CONSIG)) )
	EndIf
EndIf

cQuery := _oRegDUG:GetFixQuery()

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

If (cAliasNew)->(!Eof())
	SF4->(dbSetOrder(1))
	If SF4->(MsSeek(xFilial('SF4')+(cAliasNew)->DUG_TES))
		If	SF4->F4_MSBLQL <> '1' //Somente TES Desbloqueadas podem ser utilizadas.
			//-- Formato do vetor aRetorno
			//-- [01] = TES
			//-- [02] = Codigo da Mensagem Fiscal
			//-- [03] = TES Incide ISS (S/N)
			aRetorno := { (cAliasNew)->DUG_TES,(cAliasNew)->DUG_CODMSG,M_Posicione('SF4',1,xFilial('SF4') + (cAliasNew)->DUG_TES,'F4_ISS'), (cAliasNew)->DUG_TES }
		EndIf
	EndIf
EndIf

(cAliasNew)->(DbCloseArea())

DbSelectArea("DUG")

Return( aRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetRegTrib³ Autor ³ Adalberto S.M         ³ Data ³12.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes do contrato, funcao TmsRegTrib() ao   ³±±
±±³          ³vetor aTmsRegTrib                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetRegTrib()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do componente                               ³±±
±±³          ³ ExpC2 = Estado origem do documento                         ³±±
±±³          ³ ExpC3 = Estado devedor do documento                        ³±±
±±³          ³ ExpC4 = Estado destino do documento                        ³±±
±±³          ³ ExpC5 = Estado de origem do documento                      ³±±
±±³          ³ ExpC6 = Segmento Atividade do cliente                      ³±±
±±³          ³ ExpL7 = Devedor = Consignatario (1=Sim/2=Nao)              ³±±
±±³          ³ ExpC8 = Documento de transporte                            ³±±
±±³          ³ ExpC9 = Codigo do Produto definido na Regra de Tributacao  ³±±
±±³          ³         p/ Cliente                                         ³±±
±±³          ³ ExpC10= Estado do veiculo da viagem                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetRegTrib( cCodPas, cEstOri, cEstDev, cEstDes, cAtivid, lConsig,  cDocTms, cCodPro, cRegTri, aRegTrib, cEstVei)
Default cCodPas  := ""
Default cEstOri  := ""
Default cEstDev  := ""
Default cEstDes  := ""
Default cEstVei  := ""
Default cAtivid  := ""
Default cDocTms  := ""
Default cCodPro  := ""
Default cRegTri  := ""
Default aRegTrib := {}
If ValType(aTmsRegTrib) <> 'A'
	Static aTmsRegTrib := {}
EndIf

/////////////////////////////////////////////////////////////////////////////
// Manter o vetor aRegTrib sempre na ultima posicao do vetor aTmsRegTrib,  //
// para que a funcao GetRegTrib() funcione corretamente.                   //
/////////////////////////////////////////////////////////////////////////////
If Len(aRegTrib) > 0
	Aadd( aTmsRegTrib, { cCodPas, cEstOri, cEstDev, cEstDes, cAtivid, lConsig, cDocTms, cCodPro, cRegTri, cEstVei, aRegTrib } )
EndIf
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRegTrib³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes da Regra de Tributacao existentes no ³±±
±±³          ³vetor aTmsRegTrib. O intuito dessa rotina eh reaproveitar as³±±
±±³          ³informacoes ja processadas pela funcao TmsRegTrib()         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetRegTrib()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetRegTrib( cCodPas, cEstOri, cEstDev, cEstDes, cAtivid, lConsig, cDocTms, cCodPro, cRegTri, cEstVei)
Local aRetorno  := {}
Local nPosicao  := 0
Local aTrib     := {}

Default cCodPas := ""
Default cEstOri := ""
Default cEstDev := ""
Default cEstDes := ""
Default cEstVei := ""
Default cAtivid := ""
Default cDocTms := ""
Default cCodPro := ""
Default cRegTri := ""

If ValType(aTmsRegTrib) <> 'A'
	Static aTmsRegTrib := {}
EndIf

If Len(aTmsRegTrib) > 0
	aRetorno := {}
	nPosicao := Ascan( aTmsRegTrib, { |x| x[1] + x[2] + x[3] + x[4] + x[5]+ x[7] + x[8] + x[9]+ x[10] == cCodPas + cEstOri + cEstDev + cEstDes + cAtivid + cDocTms + cCodPro + cRegTri + cEstVei .And. x[6] == lConsig } )
	If nPosicao > 0
		aTrib := aTmsRegTrib[ nPosicao, Len(aTmsRegTrib[nPosicao])]
	EndIf

	If !Empty(aTrib) .And. Len(aTrib) > 3
		aRetorno := {aTrib[4], aTrib[2], aTrib[3]}
	ElseIf !Empty(aTrib)
		aRetorno := aTrib
	EndIf
EndIf

Return ( aRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPesqSer³ Autor ³ Patricia A. Salomao   ³ Data ³15.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Tela contendo todos os Servicos contidos no Contrato  ³±±
±±³          ³do Cliente                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSPesqServ(ExpC1, ExpC2, ExpC3, ExpC4, ExpC5, ExpA1, ExpL1)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Codigo do Cliente                                   ³±±
±±³          ³ExpC3 - Loja do Cliente                                     ³±±
±±³          ³ExpC4 - Servico de Transporte                               ³±±
±±³          ³ExpC5 - Tipo de Transporte                                  ³±±
±±³          ³ExpA1 - Array que contera os Servicos                       ³±±
±±³          ³ExpL1 - Valida se Mostra ou Nao a GetDados                  ³±±
±±³          ³ExpC6 - Tipo do Frete                                       ³±±
±±³          ³ExpL2 - Verif. se esta sendo chamada por Rotina Automatica  ³±±
±±³          ³ExpC7 - Preenche o vetor aitcontrat com os servicos do      ³±±
±±³          ³        tipo de documento de transporte contidos em ExpC7   ³±±
±±³          ³ExpL3 - .T. = Verifica contrato do cliente generico         ³±±
±±³          ³ExpC8 - Tabela de frete                                     ³±±
±±³          ³ExpC9 - Tipo da tabela de frete                             ³±±
±±³          ³ExpCA - 1 = Considera a vigencia atual do contrato          ³±±
±±³          ³        2 = Considera a proxima vigencia do contrato        ³±±
±±³          ³ExpL4 - .T. = Apresenta help                                ³±±
±±³          ³ExpCA - Codigo da Regiao de Origem                          ³±±
±±³          ³ExpCB - Codigo da Regiao de Destino                         ³±±
±±³          ³ExpL5 - Verificar se a função é chamada pelo portal TMS     ³±±
±±³          ³ExpCC - Codigo da Negociacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSPesqServ(	cAlias,  cCodCli, cLojCli,  cSerTMS, cTipTra,    aItContrat,;
						lMostra, cTipFre, lRotAuto, cDocTms, lChkCliGen, cTabFre,;
						cTipTab, cVigCon, lHelp,    cCdrOri, cCdrDes,    lPortalTMS,;
						lRateio, cBACRAT, cCRIRAT,  cPRORAT, cTABRAT,    cTIPRAT,;
						cCodNeg, cCampo, lEDI)

Static oOk,oNo,oBr
Static lSelServ   := SuperGetMv("MV_SELSERV",.F.,.T.)

Local aArea       := GetArea()
Local cCadOld     := Iif(Type("cCadastro") <> "U",cCadastro,"")
Local nOpca       := 0
Local cQuery      := ""
Local cAliasQry   := ""
Local cItem       := ""		//-- Variavel utilizada para retorno da string
Local lAddItContr := .T.	//-- Controla se adiciona servicos no vetor aItContrat
Local lSqlResult  := .F.
Local aContrat    := {}
Local lRet        := .T.
Local lRetPE      := .T.
Local oDlgEsp
Local oItem
Local lCamposRat  := AliasIndic('DDA') .And. DDA->(ColumnPos("DDA_TIPTAB")) > 0 
Local cDC5DOCTMS  := ""
Local lProcessa   := .T.
Local oModel
Local oView
Local cVarPesq

Private cTDocTms    := ""

Default cAlias      := ""
Default cCodCli     := ""
Default cLojCli     := ""
Default cSerTMS     := ""
Default cTipTra     := ""
Default aItContrat  := {}
Default lMostra     := .T.
Default cTipFre     := '3'
Default lRotAuto    := .F.
Default cDocTms     := ''
Default lChkCliGen  := .T.
Default cTabFre     := ''
Default cTipTab     := ''
Default cVigCon     := '1'
Default lHelp       := .T.
Default cCdrOri     := ''
Default cCdrDes     := ''
Default lPortalTMS  := .F.
Default lRateio		:= .F.
Default cBACRAT		:= ""
Default cCRIRAT		:= ""
Default cPRORAT		:= ""
Default cTABRAT		:= ""
Default cTIPRAT		:= ""
Default cCodNeg     := ""
Default cCampo		:= ""
Default lEDI        := .F.

If lRateio .And. !lCamposRat
	lRateio := .F.
EndIf

// Limpa o VAR_IXB
VAR_IXB := Space(TamSX3("DDA_SRVCOL")[1])

aItContrat := {}
//-- A variavel private cTDocTms foi criada para uso da funcao TmsValField
cTDocTms   := cDocTms
cCadastro  := STR0033 + Iif(Empty(cDocTms),'',' p/ '+TmsValField('cTDocTms',.F.)) //"Escolha o Servico"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do array que Contem os Servicos do Contrato       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 1 Marcado (.T. ou .F.)
// 2 Titulo("0") ou Item("1")
// 3 Codigo do Servico
// 4 Descricao do Servico

aContrat := TMSContrat(cCodCli,cLojCli,,,lHelp,cTipFre,lChkCliGen,cVigCon,,,,,cTipTra,,,,,,,,,cCodNeg)
If Len(aContrat) > 0
	cAliasQry := GetNextAlias()
	cQuery := "   SELECT "

	cQuery += "DDA_SERVIC, DDA_TABFRE, DDA_TIPTAB, DDA_TABALT, DDA_TIPALT, DDA.R_E_C_N_O_ RECDDA, DDA_CODNEG, "
	If lRateio
		cQuery += " DDA_BACRAT, DDA_CRIRAT, DDA_PRORAT, DDC_BACRAT, DDC_CRIRAT, DDC_PRORAT, "
	EndIf
	cQuery += " DC5_SERTMS, DC5_TIPTRA, DC5_DOCTMS, MAX(DC5.R_E_C_N_O_) RECDC5"
	cQuery += "     FROM " + RetSqlName("DDA") + " DDA, " + RetSqlName("DC5") + " DC5 "
	cQuery += " , " + RetSqlName("DDC") + " DDC "
	cQuery += "    WHERE DDA_FILIAL = '" + xFilial("DDA") + "' "
	cQuery += "      AND DDA_NCONTR = '" + aContrat[1, 1] + "' "
	If !Empty(cCodNeg)
		cQuery += "      AND DDA_CODNEG = '" + cCodNeg + "' "
	EndIf
	If lPortalTMS
		cQuery += "  AND DDA_PORTMS = '1'"
	EndIf
	If lEDI
		cQuery += "  AND DDA_EDITMS = '1'"
	EndIf
	If lRateio
		If !Empty(cTABRAT)
			cQuery += "  AND DDA_TABFRE = '" + cTABRAT + "' "
		EndIf

		If !Empty(cTIPRAT)
			cQuery += "  AND DDA_TIPTAB = '" + cTIPRAT + "' "
		EndIf
	EndIf
	cQuery += "   AND DDA.D_E_L_E_T_ = ' ' "
	cQuery += "   AND DDC.DDC_FILIAL = '" + xFilial('DDC') + "' "
	cQuery += "   AND DDC.DDC_NCONTR = DDA.DDA_NCONTR "
	cQuery += "   AND DDC.DDC_CODNEG = DDA.DDA_CODNEG "
	cQuery += "   AND DDC.D_E_L_E_T_ = ' ' "

	cQuery += "   AND DC5_FILIAL = '" + xFilial("DC5") + "' "
	cQuery += "      AND DC5_SERVIC = DDA_SERVIC"
	cQuery += "      AND DC5_DOCTMS <> '3'" // Tipo de documento diferente de AWB
	If !Empty(cSerTms)
		cQuery += "      AND DC5_SERTMS = '" + cSerTMS + "' "
	EndIf
	If !Empty(cTipTra)
		cQuery += "      AND DC5_TIPTRA = '" + cTipTra + "' "
	EndIf
	cQuery += "      AND DC5.D_E_L_E_T_ = ' ' "
	cQuery += "   GROUP BY DDA_CODNEG,DDA_SERVIC, DDA_TABFRE, DDA_TIPTAB, DDA_TABALT, DDA_TIPALT, DDA.R_E_C_N_O_ ,"
	If lRateio
		cQuery += "            DDA_BACRAT, DDA_CRIRAT, DDA_PRORAT, DDC_BACRAT, DDC_CRIRAT, DDC_PRORAT,DC5_SERTMS, DC5_TIPTRA, DC5_DOCTMS "
	Else
		cQuery += "            DC5_SERTMS, DC5_TIPTRA, DC5_DOCTMS "
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
		lSqlResult := .T. //| Sinaliza que a query trouxe resultado na execução.
		If  lRateio
			lProcessa:= TmsPesqRat(cBACRAT,cCRIRAT,cPRORAT,(cAliasQry)->DDA_BACRAT,(cAliasQry)->DDA_CRIRAT,(cAliasQry)->DDA_PRORAT,(cAliasQry)->DDC_BACRAT,(cAliasQry)->DDC_CRIRAT,(cAliasQry)->DDC_PRORAT)
		EndIf

		If lProcessa
			cDC5DOCTMS := ""

		If DTC->(ColumnPos("DTC_DOCTMS")) > 0 .AND. Empty( (cAliasQry)->DC5_DOCTMS )
				cDC5DOCTMS := TMSTipDoc(cCdrOri,cCdrDes)
			Else
				cDC5DOCTMS := (cAliasQry)->DC5_DOCTMS
			EndIf

			If	Iif(Empty(cDocTms),.T.,cDC5DOCTMS $ cDocTms)
				//-- Obtem o codigo do servico referente a tabela de frete ou tabela de frete alternativa
				If !Empty(cTabFre) .And. !Empty(cTipTab)
					lAddItContr := .F.
					//-- Obtem servicos referente a tabela de frete desejada
					If ( (cAliasQry)->(DDA_TABFRE + DDA_TIPTAB) == cTabFre + cTipTab) 
						lAddItContr := .T.
					//-- Obtem servicos referente a tabela de frete alternativa desejada
					ElseIf ( (cAliasQry)->(DDA_TABALT + DDA_TIPALT) == cTabFre + cTipTab) 
						//-- Verifica se a tabela de frete alternativa esta ativa ou dentro da vigencia
						lAddItContr := TmsTbAtiva( cTabFre, cTipTab, .F. )
					EndIf
				EndIf

				lRet := TmsTbAtiva( (cAliasQry)->DDA_TABFRE , (cAliasQry)->DDA_TIPTAB , .F. )
				DDA->( DbGoto((cAliasQry)->RECDDA) )
	
				DC5->( DbGoto((cAliasQry)->RECDC5) )
				If lTMSPESFIL  .And. lRet
					lRetPE := ExecBlock("TMSPESFIL",.F.,.F.,{Tabela("L4",(cAliasQry)->DDA_SERVIC),.F. } )
					lRet   := IIf( ValType(lRetPE) == "L",lRetPE,lRet)
				EndIf
				If	lRet .AND. lAddItContr

					//--Consiste o servico em relacao a regiao de origem X destino.
					//--Caso as regioes sejam identicas (Mesmo municipio), nao gatilha
					//--um servico de transporte cujo docto.
					//--de transporte seja diferente de (5) - Nota Fiscal Serv. Transp.
					If	lEDI .Or. ;
					    ( (cCdrOri == cCdrDes .Or. TMSTipDoc(cCdrOri,cCdrDes) == StrZero(5,Len(DC5->DC5_DOCTMS)) ) .And. ;
						        (cDC5DOCTMS == StrZero(5,Len(DC5->DC5_DOCTMS))   .OR.; //Nota Fiscal
                                 cDC5DOCTMS == StrZero(2,Len(DC5->DC5_DOCTMS))   .OR.; //CTRC
                                 cDC5DOCTMS == PADR('B',Len(DC5->DC5_DOCTMS))    .OR.; //ACT
                                 cDC5DOCTMS == PADR('C',Len(DC5->DC5_DOCTMS))    .OR.; //Documento de Apoio 2
                                 cDC5DOCTMS == PADR('H',Len(DC5->DC5_DOCTMS))    .OR.; //Documento de Apoio 3
                                 cDC5DOCTMS == PADR('I',Len(DC5->DC5_DOCTMS))    .OR.; //Documento de Apoio 4
                                 cDC5DOCTMS == PADR('N',Len(DC5->DC5_DOCTMS))    .OR.; //Documento de Apoio 5
                                 cDC5DOCTMS == PADR('O',Len(DC5->DC5_DOCTMS)) )) .OR.; //Documento de Apoio 6
						 (cCdrOri <> cCdrDes .And. TMSTipDoc(cCdrOri,cCdrDes) <> StrZero(5,Len(DC5->DC5_DOCTMS)) .And. cDC5DOCTMS <> StrZero(5,Len(DC5->DC5_DOCTMS))) .OR.;
						 (cSerTMS == "1" .And. cDC5DOCTMS == "1") .Or.;
			              IsInCallStack("TMSF79TELA") == .T.      .Or.; //- Para quando a tela de serviços for chamada pela interface de Pagadores permite carregar sem olhar para o tipo de documento ou regiões.
			              IsInCallStack("TMSA040"   ) == .T.

						AAdd(aItContrat,{.F.,"1",(cAliasQry)->DDA_SERVIC, Tabela("L4",(cAliasQry)->DDA_SERVIC,.F.),cDC5DOCTMS,(cAliasQry)->DDA_CODNEG})
						
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)

	//-- Verifica Se Encontrou o Serviço Adequado No Contrato
	If	lRet .And. lAddItContr .And. Len(aItContrat) == 0 .And. !Empty(cCodNeg)	.And. lSqlResult == .T.
		Help("",1,"TMSXFUNB46")	//-- As regiões de origem e destino são incompatíveis com os tipos de documentos disponíveis nos serviços de negociação do cliente
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso exista mais de um Servico                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItContrat) > 0  .And. !lRotAuto
		//--Somente mostra a janela de selecao de servicos quando:
		//--1o) Houver mais de um servico para selecao e o contrato esteja configurado para selecao de servicos igual a "DIGITADO"
		//--2o) Houver mais de um servico para selecao e o contrato esteja configurado para selecao de servicos igual a "AUTOMATICA", porem com o parametro "MV_SELSERV" habilitado
		//--3o) Chamada da selecao de servicos esta sendo realizada atraves do <F3> no campo de servicos
		//--4o) Não for a chamada pela validação de Cód neg no tmsa050 e o serviço já esteja preenchido com um dos servicos selecionados
		If	lMostra .And. Len(aItContrat) > 1 .And. ;
			(aContrat[1,21] == "1" .Or.;
			(aContrat[1,21] == "2" .And. lSelServ)) .And.;
			!(cAlias == "DTC" .And. "DTC_CODNEG"  $ ReadVar() .And. Type("M->DTC_SERVIC") != "U" .And. !Empty(M->DTC_SERVIC)  .And. Ascan(aItContrat,{|x| AllTrim(x[3]) == M->DTC_SERVIC}) > 0)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Le na resource os bitmaps utilizados no Listbox p/ sele‡ao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oOk := If(oOk==Nil,LoadBitmap( GetResources(), "LBOK"),oOk)
			oNo := If(oNo==Nil,LoadBitmap( GetResources(), "LBNO"),oNo)
			oBr := If(oBr==Nil,LoadBitmap( GetResources(), "NADA"),oBr)

			If !Empty(cCampo)
				If cCampo == "M->DF1_SRVCOL"
					cItem	:= M->& (cAlias+"_SRVCOL") //Armazena servico selecionado anteriormente para restaurar caso clicar em cancelar a alteracao
				ElseIf cCampo == "M->DT5_SRVENT"
					cItem	:= M->& (cAlias+"_SRVENT") //Armazena servico selecionado anteriormente para restaurar caso clicar em cancelar a alteracao
				EndIf
			Else
				cItem	:= M->& (cAlias+"_SERVIC") //Armazena servico selecionado anteriormente para restaurar caso clicar em cancelar a alteracao
			EndIf

			DEFINE MSDIALOG oDlgEsp TITLE cCadastro From 150,100 To 600,800 OF oMainWnd PIXEL
				If Empty(cCodNeg) .And. (Empty(cCampo) .Or. "DTC" $ cCampo .Or. cAlias == "DTC")

					//-- Acrescenta a descrição da negociação ao Array
					aEval(aItContrat,{|x| aSize(x,Len(x)+1), x[Len(x)] :=  Posicione("DDB",1,xFilial("DDB") + x[6],"DDB_DESCRI")})

					//-- Ordena o Array por Cod.Neg. + Cod Serv
					aSort(aItContrat,,, {|x,y| x[6] + x[3] < y[6] + y[3]})
					cVarPesq := Space(40)

					@ 06,05 SAY STR0165 SIZE 50,07 OF oDlgEsp PIXEL //-- "Pesquisa"
					@ 05,38 MSGET oPesq VAR cVarPesq SIZE 255,10;
					                    VALID (oItem:nAt := Max(1,aScan(aItContrat,{|xLin| aScan(xLin,{|yCol| ALLTRIM(UPPER(cVarPesq)) $ UPPER(AllToChar(yCol))}) > 0})),;
					                    oItem:Refresh(),oItem:SetFocus(), .T.) OF oDlgEsp PIXEL
					@ 20,05 LISTBOX oItem VAR cOpc ;
					                Fields HEADER "",RetTitle("DTC_CODNEG"),RetTitle("DTC_DESNEG"),STR0034,STR0035 ;
					                COLSIZES 5,40,50,40,50;
					                SIZE 300,200 ON DBLCLICK (aItContrat:=TrocaItCF(oItem:nAt,aItContrat),oItem:Refresh(),(If(ItTudOk(aItContrat,@cItem),(nOpca:=1,oDlgEsp:End()),))) NOSCROLL OF oDlgEsp PIXEL //"Servico"###"Descricao"
					oItem:SetArray(aItContrat)
					oItem:bLine := { || {If(aItContrat[oItem:nAt,2]=="0",oBr,If(aItContrat[oItem:nAt,1],oOk,oNo)),;
											aItContrat[oItem:nAt,6],;
											aTail(aItContrat[oItem:nAt]),;//Posicione("DDB",1,xFilial("DDB") + aItContrat[oItem:nAt,6],"DDB_DESCRI"),;
											aItContrat[oItem:nAt,3],;
											aItContrat[oItem:nAt,4]}}
					oItem:bHeaderClick := {|oObj,nCol|	If(nCol==2,;
					                                        aSort(aItContrat,,, {|x,y| x[6] + x[3] < y[6] + y[3]}),;
														    If(nCol==3,;
														    	aSort(aItContrat,,, {|x,y| aTail(x) < aTail(y)}),;
															    If(nCol==4,;
															       aSort(aItContrat,,, {|x,y| x[3] < y[3]}),;
														 	       If(nCol==5,;
														 	          aSort(aItContrat,,, {|x,y| x[4] < y[4]}),;
													 	          	);
													 	          );
													 	       );
													 	  ),;
														oItem:SetFocus(),oItem:Refresh()}
				Else
					@ 05,10 LISTBOX oItem VAR cOpc Fields HEADER "",STR0034,STR0035 SIZE 300,215 ON DBLCLICK (aItContrat:=TrocaItCF(oItem:nAt,aItContrat),oItem:Refresh(),(If(ItTudOk(aItContrat,@cItem),(nOpca:=1,oDlgEsp:End()),))) NOSCROLL OF oDlgEsp PIXEL //"Servico"###"Descricao"
					oItem:SetArray(aItContrat)
					oItem:bLine := { || {If(aItContrat[oItem:nAt,2]=="0",oBr,If(aItContrat[oItem:nAt,1],oOk,oNo)),;
											aItContrat[oItem:nAt,3],;
											aItContrat[oItem:nAt,4]}}
					oItem:bHeaderClick := {|oObj,nCol|	If(nCol==2,aSort(aItContrat,,, {|x,y| x[3] < y[3]}),;
														If(nCol==3,aSort(aItContrat,,, {|x,y| x[4] < y[4]}),)),;
														oItem:SetFocus(),oItem:Refresh()}
				EndIf
				DEFINE SBUTTON FROM 03,315 TYPE 1 ACTION (If(ItTudOk(aItContrat,@cItem),(nOpca:=1,oDlgEsp:End()),)) ENABLE OF oDlgEsp
				If FunName() == "TMSAF05"
					If !Empty(cCampo)
						If cCampo == "M->DF1_SRVCOL"
							DEFINE SBUTTON FROM 18,315 TYPE 2 ACTION { || GDFieldPut(cAlias+"_SRVCOL",Space(Len(GDFieldGet(cAlias+"_SRVCOL",n))),n) , GDFieldPut(cAlias+"_DESCOL",Space(Len(GDFieldGet(cAlias+"_DESCOL",n))),n) , oDlgEsp:End() } ENABLE OF oDlgEsp
						EndIf
					Else
						DEFINE SBUTTON FROM 18,315 TYPE 2 ACTION { || GDFieldPut(cAlias+"_SERVIC",Space(Len(GDFieldGet(cAlias+"_SERVIC",n))),n) , GDFieldPut(cAlias+"_DESSER",Space(Len(GDFieldGet(cAlias+"_DESSER",n))),n) , oDlgEsp:End() } ENABLE OF oDlgEsp
					EndIf
				ElseIf cCampo == "M->DT5_SRVENT"
				     DEFINE SBUTTON FROM 18,315 TYPE 2 ACTION { || M->& (cAlias+"_SRVENT") := Space(Len(M->& (cAlias+"_SRVENT"))) , M->& (cAlias+"_DESENT") := Space(Len(M->& (cAlias+"_DESENT"))) , oDlgEsp:End() } ENABLE OF oDlgEsp
                ElseIf isInCallStack('TMSF79Tela') == .T.
                     DEFINE SBUTTON FROM 18,315 TYPE 2 ACTION { || oDlgEsp:End() } ENABLE OF oDlgEsp//Botao Cancelar
				Else
				     DEFINE SBUTTON FROM 18,315 TYPE 2 ACTION { || M->& (cAlias+"_SERVIC") := Space(Len(M->& (cAlias+"_SERVIC"))) , M->& (cAlias+"_DESSER") := Space(Len(M->& (cAlias+"_DESSER"))) , oDlgEsp:End() } ENABLE OF oDlgEsp
				EndIf

			ACTIVATE MSDIALOG oDlgEsp


			//Valida se Confirmou algum item ou se Item selecionado anteriormente participa da lista apresentada, quando altera DTC_SERTMS ou DTC_TIPTRA a lista eh modificada
			If nOpcA == 1 .Or. Ascan(aItContrat,{|x| AllTrim(x[3]) == cItem}) > 0
				If !Empty(cCampo)
					If cCampo == "M->DF1_SRVCOL"
						M->&(cAlias+"_SRVCOL") := cItem
						M->&(cAlias+"_DESCOL") := Tabela("L4",cItem,.F.)
					ElseIf cCampo == "M->DT5_SRVENT"
						M->&(cAlias+"_SRVENT") := cItem
						M->&(cAlias+"_DESENT") := Tabela("L4",cItem,.F.)
					ElseIf cCampo == "M->DDD_SRVCOL"
						M->&(cAlias+"_SRVCOL") := cItem
					ElseIf cCampo == "M->DUA_SERVIC"
						M->DUA_SERVIC := cItem
					EndIf
				Else
					If IsInCallStack("TMSA019")
						oModel := FWModelActive() //-- Captura Model Ativa
						oView  := FWViewActive()  //-- Captura View Ativa
						If oModel:cSource == "TMSA019A"
							oModel:LoadValue( 'TMSA019A_CAB' , 'DDD_SERVIC' , cItem )
							oModel:LoadValue( 'TMSA019A_CAB' , 'DDD_DESSER' , Tabela("L4",cItem,.F.) )
							oView:Refresh("TMSA019A_CAB")
						EndIf
					Else
						M->& (cAlias+"_SERVIC") := cItem
						M->& (cAlias+"_DESSER") := Tabela("L4",cItem,.F.)
						If nOpcA == 1 .And. Empty(cCodNeg) .And. (Empty(cCampo) .Or. "DTC" $ cCampo .Or. cAlias == "DTC")
							M->&(cAlias+"_CODNEG") := aItContrat[Ascan(aItContrat,{|x| x[1] }),6]
							M->&(cAlias+"_DESNEG") := Posicione("DDB",1,xFilial("DDB") + M->& (cAlias+"_CODNEG"),"DDB_DESCRI")
						EndIf
					EndIf
				EndIf
				VAR_IXB := cItem
			Endif

		ElseIf Len(aItContrat) == 1  //Se o Contrato tiver apenas 1 servico informado, sugerir o mesmo automatic//e
			If !Empty(cCampo)
				If cCampo == "M->DF1_SRVCOL"
					M->&(cAlias+"_SRVCOL") := aItContrat[1][3]
					M->&(cAlias+"_DESCOL") := aItContrat[1][4]
				ElseIf cCampo == "M->DT5_SRVENT"
					M->&(cAlias+"_SRVENT") := aItContrat[1][3]
					M->&(cAlias+"_DESENT") := aItContrat[1][4]
				ElseIf cCampo == "M->DDD_SRVCOL"
					M->&(cAlias+"_SRVCOL") := aItContrat[1][3]
				ElseIf cCampo == "M->DUA_SERVIC"
					M->DUA_SERVIC := cItem
				EndIf
				VAR_IXB := aItContrat[1][3]
			Else
				If IsInCallStack("TMSA019")
					oModel := FWModelActive() //-- Captura Model Ativa
					oView  := FWViewActive()  //-- Captura View Ativa
					If oModel:cSource == "TMSA019A"
						oModel:LoadValue( 'TMSA019A_CAB' , 'DDD_SERVIC' , aItContrat[1][3] )
						oModel:LoadValue( 'TMSA019A_CAB' , 'DDD_DESSER' , aItContrat[1][4] )
						oView:Refresh("TMSA019A_CAB")
					EndIf
				Else
					M->&(cAlias+"_SERVIC") := aItContrat[1][3]
					M->&(cAlias+"_DESSER") := aItContrat[1][4]
					If Empty(cCodNeg) .And. (Empty(cCampo) .Or. "DTC" $ cCampo .Or. cAlias == "DTC")
						M->&(cAlias+"_CODNEG") := aItContrat[1,6]
						M->&(cAlias+"_DESNEG") := Posicione("DDB",1,xFilial("DDB") + M->& (cAlias+"_CODNEG"),"DDB_DESCRI")
					EndIf
				EndIf
				VAR_IXB := aItContrat[1][3]
			EndIf
		EndIf
	EndIf
Else
	lRet := .F.
EndIf
If (Type("cCadastro") <> "U")
	cCadastro := cCadOld
EndIf
RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsRetServ³ Autor ³ Alex Egydio           ³ Data ³19.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Identifica o servico conforme os parametros                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do contrato                                 ³±±
±±³          ³ ExpC2 = Tipo de servico                                    ³±±
±±³          ³ ExpC3 = Tipo de transporte                                 ³±±
±±³          ³ ExpL1 = .T. Transporte municipal (regioes iguais)          ³±±
±±³          ³ ExpN1 = Volume                                             ³±±
±±³          ³ ExpN2 = Valor                                              ³±±
±±³          ³ ExpN3 = Peso real                                          ³±±
±±³          ³ ExpN4 = Peso cubado                                        ³±±
±±³          ³ ExpC4 = Codigo da Regiao de Origem                         ³±±
±±³          ³ ExpC5 = Codigo da Regiao de Destino (NF)                   ³±±
±±³          ³ ExpC6 = Codigo da Regiao de Calculo                        ³±±
±±³          ³ ExpC7 = Codigo da Negociacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo do servico                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsRetServ( cNContr, cSerTms, cTipTra, lMunicip, nQtdVol, nValor, nPeso, nPesoM3, cCdrOri, cCdrDes, cCdrCal, cCodNeg )

Static aTamCpo := {}

Local   aAreaDDA := {}
Local   aAreaDC5 := DC5->(GetArea())
Local   cRet     := ''
Local   cSeek    := ''
Local	cDocTms  := ''
Default cCdrOri  := ''
Default cCdrDes  := ''
Default cCdrCal  := ''
Default cCodNeg  := ''

If lTMRETSRV
	cRet := ExecBlock('TMRETSRV',.F.,.F.,{ cNContr, cSerTms, cTipTra, lMunicip, nQtdVol, nValor, nPeso, nPesoM3, cCdrOri, cCdrDes, cCdrCal, cCodNeg })
Else
	lQuery := ( TcSrvType() <> "AS/400" )
	If !lQuery
		
		aAreaDDA := DDA->(GetArea())
		aAreaDC5 := DC5->(GetArea())
		DDA->(DbSetOrder(1))
		If	DDA->(MsSeek( cSeek := xFilial('DDA') + cNContr + cCodNeg ))
			While DDA->( ! Eof() .And. DDA->DDA_FILIAL + DDA->DUX_NCONTR + DDA->DDA_CODNEG == cSeek )
				DC5->(DbSetOrder(1))
				DC5->(MsSeek( xFilial('DC5') + DDA->DDA_SERVIC ))
				If DTC->(ColumnPos("DTC_DOCTMS")) > 0 .And. Empty(DC5->DC5_DOCTMS)
					cDocTms := TMSTipDoc(cCdrOri,cCdrCal)
				Else
					cDocTms := DC5->DC5_DOCTMS
				EndIf
				If	DC5->DC5_SERTMS == cSerTms .And.;
					DC5->DC5_TIPTRA == cTipTra .And.;
					(Iif(lMunicip,DC5->DC5_DOCTMS == StrZero(5,Len(DC5->DC5_DOCTMS)), cDocTms <> StrZero(5,Len(DC5->DC5_DOCTMS))).Or. Empty(DC5->DC5_DOCTMS)) .And.;
					Iif(DDA->DDA_QTDVOL	> 0,nQtdVol <= DDA->DDA_QTDVOL	,.T.)	.And.;
					Iif(DDA->DDA_VALMER	> 0,nValor  <= DDA->DDA_VALMER	,.T.)	.And.;
					Iif(DDA->DDA_PESO	> 0,nPeso   <= DDA->DDA_PESO	,.T.)	.And.;
					Iif(DDA->DDA_PESOM3	> 0,nPesoM3 <= DDA->DDA_PESOM3	,.T.)
					cRet := DDA->DDA_SERVIC
					Exit
				EndIf
				DDA->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaDC5)
		RestArea(aAreaDDA)
	
	Else
		If Len(aTamCpo) == 0
			
			aAdd( aTamCpo, TamSX3("DDA_QTDVOL") )
			aAdd( aTamCpo, TamSX3("DDA_VALMER") )
			aAdd( aTamCpo, TamSX3("DDA_PESO"  ) )
			aAdd( aTamCpo, TamSX3("DDA_PESOM3") )

		EndIf
		cAliasQry := GetNextAlias()
		cQuery := ""
		
		cQuery += " SELECT DDA_SERVIC "
		cQuery += "   FROM " + RetSqlName("DDA") + " DDA, "
		cQuery +=              RetSqlName("DC5") + " DC5 "
		cQuery += "  WHERE DDA_FILIAL='" + xFilial( "DDA" ) + "' "
		cQuery += "    AND DDA_NCONTR ='" + cNContr + "' "
		cQuery += "    AND DDA_CODNEG ='" + cCodNeg + "' "
		cQuery += "    AND DDA.D_E_L_E_T_ = ' ' "
		
		//JOIN COM TABELA DC5
		cQuery += "    AND DC5_FILIAL='" + xFilial( "DC5" ) + "' "
		
		cQuery += "    AND DC5_SERVIC = DDA.DDA_SERVIC "
		
		cQuery += "    AND DC5.D_E_L_E_T_ = ' ' "
		//DEMAIS CONDICOES
		cQuery += "    AND DC5_SERTMS  ='" + cSerTms + "' "
		cQuery += "    AND DC5_TIPTRA  ='" + cTipTra + "' "
		If lMunicip
			cQuery += " AND ( DC5_DOCTMS  ='" + StrZero(5,Len(DC5->DC5_DOCTMS)) + "' "
		Else
			cQuery += " AND ( DC5_DOCTMS  !='" + StrZero(5,Len(DC5->DC5_DOCTMS)) + "' "
		EndIf

		If DTC->(ColumnPos("DTC_DOCTMS")) > 0
			cQuery += " OR DC5_DOCTMS  = ' ' "
		Endif

		cQuery += "    ) "
		
		cQuery += "    AND ( DDA_QTDVOL  = 0 OR DDA_QTDVOL >= " + Str(nQtdVol	, aTamCpo[1,1], aTamCpo[1,2]) + " ) "
		cQuery += "    AND ( DDA_VALMER  = 0 OR DDA_VALMER >= " + Str(nValor	, aTamCpo[2,1], aTamCpo[2,2]) + " ) "
		cQuery += "    AND ( DDA_PESO    = 0 OR DDA_PESO   >= " + Str(nPeso		, aTamCpo[3,1], aTamCpo[3,2]) + " ) "
		cQuery += "    AND ( DDA_PESOM3  = 0 OR DDA_PESOM3 >= " + Str(nPesoM3	, aTamCpo[4,1], aTamCpo[4,2]) + " ) "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
		While !(cAliasQry)->(Eof())
			cRet := (cAliasQry)->DDA_SERVIC
			Exit
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TmsNivInf ³ Autor ³Henry Fila             ³ Data ³27/12/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Traz todos os grupos abaixo de um grupo de regioes         ³±±
±±³          ³ ( recursiva )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsaNivInf( ExpC1, @ExpA1, [ ExpN1 ] )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Grupo a pesquisar                                 ³±±
±±³          ³ ExpA1 -> Array contendo os grupos. Deve ser passado por    ³±±
±±³          ³    referencia e alimentado pela funcao                     ³±±
±±³          ³       Estrutura : 1 - Grupo ( C )                          ³±±
±±³          ³                   2 - Nivel do grupo ( N )                 ³±±
±±³          ³ ExpN1 -> Nivel atual. Este parametro nao deve ser passado  ³±±
±±³          ³ na chamada inicial, pois e passado quando a funcao chama   ³±±
±±³          ³ ela mesma ( recursividade )                                ³±±
±±³          ³ ExpL1 -> Verifica as regioes coligadas do Grupo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsNivInf( cGrpSup, aGrupos, nLevel, lVerCdrCol )

Local cAliasQry := ""
Local cQuery    := ""
Local nIndex    := ""

Default lVerCdrCol := .F.

If ValType( nLevel ) <> "N"
	nLevel := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incrementa o contador de niveis                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLevel++

cAliasQry := GetNextAlias()
cQuery := "SELECT DUY_GRPVEN, DUY_GRPSUP, DUY_CDRCOL FROM " + RetSqlName( "DUY" ) + " "
cQuery += "WHERE "
cQuery += "DUY_FILIAL='" + xFilial( "DUY" ) + "' AND "
cQuery += "DUY_GRPSUP='" + cGrpSup          + "' AND "
If lVerCdrCol
	cQuery += "DUY_CDRCOL='" + Space(Len(DUY->DUY_CDRCOL))+ "' AND "
EndIf
cQuery += "D_E_L_E_T_=' '"

//-- Verifica as Regioes Coligadas do Grupo Superior
If lVerCdrCol
	cQuery += "UNION ALL "
	cQuery += "SELECT DUY_GRPVEN, DUY_GRPSUP, DUY_CDRCOL FROM " + RetSqlName( "DUY" ) + " "
	cQuery += "WHERE "
	cQuery += "DUY_FILIAL='" + xFilial( "DUY" ) + "' AND "
	cQuery += "DUY_CDRCOL='" + cGrpSup          + "' AND "
	cQuery += "D_E_L_E_T_=' '"
EndIf
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
If Alias() == cAliasQry
	While !( cAliasQry )->( Eof() )
		If	AScan(aGrupos,{|x|x[1]==( cAliasQry )->DUY_GRPVEN})==0
			AAdd( aGrupos, { ( cAliasQry )->DUY_GRPVEN, nLevel, !Empty(( cAliasQry )->DUY_CDRCOL), ( cAliasQry )->DUY_CDRCOL } )
			TmsNivInf( ( cAliasQry )->DUY_GRPVEN, @aGrupos, @nLevel, lVerCdrCol )
		EndIf
		( cAliasQry )->( dbSkip() )
	EndDo
	( cAliasQry )->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Decrementa o contador de niveis                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLevel--

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSRetCbx ³ Autor ³ Robson Alves          ³ Data ³15/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a descricao do ComboBox(SX3).                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSRetCbx(ExpC1, ExpC2, ExpC3, ExpN1, ExpC4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Campo do ComboBox.                                ³±±
±±³          ³ ExpC2 -> Conteudo do campo.                                ³±±
±±³          ³ ExpC3 -> Alias para pesquisa.                              ³±±
±±³          ³ ExpN1 -> Ordem para pesquisa.                              ³±±
±±³          ³ ExpC4 -> Chave para pesquisa.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRetCbx(cCpoBox, cConteudo, cAlias, nOrder, cChave)

Local cDescCbx := ""
Local aArea    := GetArea()

If Empty(cConteudo)
	cConteudo := M_Posicione(cAlias, nOrder, cChave, cCpoBox)
EndIf

cDescCbx := RetCBox(cCpoBox, cConteudo)
RestArea(aArea)

Return( cDescCbx )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSDTQStatus ³ Autor ³ Marcelo Iuspa      ³ Data ³25.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica ou retorna o status ref. DTQ_STATUS               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Status da Viagem.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDTQStatus(nStatus)

Local cStatus := Nil
Local xRet
Static nLenDTQStatus

If nLenDTQStatus == Nil
	nLenDTQStatus := Len(DTQ->DTQ_STATUS)
EndIf
cStatus := StrZero(Val(DTQ->DTQ_STATUS),nLenDTQStatus)
If nStatus == Nil
	xRet := cStatus
Else
	xRet := cStatus == StrZero(nStatus,	nLenDTQStatus)
EndIf

Return( xRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsSenha ³ Autor ³ Alex Egydio           ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita senha                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsSenha()

Local oFont
Local oDlg
Local oPanel
Local oBmp

Local oUsuario
Local cTmsUsu	:= Space(40)

Local oSenha
Local cSenha	:= Space(10)

Local oOk
Local oCancel

Local lEndDlg	:= .T.
Local lRet		:= .F.

DEFINE FONT oFont NAME 'Arial' SIZE 0, -12 BOLD

DEFINE MSDIALOG oDlg FROM 040,030 TO 190,310 TITLE STR0036 PIXEL OF oMainWnd //'Advanced Protheus - Login'

	@ 000,000 MSPANEL oPanel OF oDlg FONT oFont SIZE 200,200 LOWERED

	@ 000,000 BITMAP oBmp RESNAME 'LOGIN' oF oPanel SIZE 045,076 NOBORDER WHEN .F. PIXEL ADJUST

	@ 005,070 SAY STR0037 SIZE 60,07 OF oPanel PIXEL FONT oFont //'Usuario'
	@ 015,070 MSGET oUsuario VAR cTmsUsu SIZE 60,10 OF oPanel PIXEL FONT oFont

	@ 030,070 SAY STR0038 SIZE 53,07 OF oPanel PIXEL FONT oFont //'Senha'
	@ 040,070 MSGET oSenha VAR cSenha SIZE 60,10 PASSWORD OF oPanel PIXEL FONT oFont

	DEFINE SBUTTON oOk FROM 60,70 TYPE 1 ENABLE OF oPanel PIXEL ACTION (lEndDlg := TmsVldSenh(cTmsUsu,cSenha), lRet := lEndDlg, Iif(lRet,oDlg:End(),.F.))

	DEFINE SBUTTON oCancel FROM 60,100 TYPE 2 ENABLE OF oPanel PIXEL ACTION (lEndDlg := .T.,lRet := .F.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED VALID lEndDlg

Return( {lRet,cTmsUsu,cSenha} )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsVldSenh³ Autor ³ Alex Egydio           ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se usuario e senha sao validos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsVldSenh(cTmsUsu,cSenha)

Local lRet := .F.

cTmsUsu := AllTrim(cTmsUsu)
cSenha	:= AllTrim(cSenha)

PswOrder(2)
If	PswSeek(cTmsUsu)
	If	! PswName(cSenha)
		Help('',1,'USR_EXIST') //"Codigo de usuario nao existe"
		lRet := .F.
	Else
		lRet := .T.
	EndIf
Else
	Help('',1,'USR_EXIST') //"Codigo de usuario nao existe"
	lRet := .F.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsAcesso³ Autor ³ Alex Egydio           ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o usuario tem acesso ao programa               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsAcesso(cTmsUsu,cPrograma,cCodUser,nAcesso,lHelp)

Local lRet    := .F.
Local lRetBlk := .F.
Local nSeek   := At('(',cPrograma)

DEFAULT cTmsUsu   := ''
DEFAULT cPrograma := ''
DEFAULT cCodUser  := ''
DEFAULT nAcesso   := 4
DEFAULT lHelp     := .T.

//-- Retira o parenteses do nome do programa
If	nSeek > 0
	cPrograma := Left(cPrograma,nSeek-1)
EndIf

//-- Verifica se o usuario tem acesso para liberar a cotacao
If ChkUserRules(cPrograma)
	lRet := .T.
Else
	If lHelp
		Help('',1,'TMSXFUNB36') //-- Usuario sem acesso a rotina.
	EndIf
	lRet := .F.
EndIf

If lTMSACESS
	lRetBlk := ExecBlock('TMSACESS',.F.,.F.,{cPrograma,cCodUser})
	lRet    := IIf( ValType(lRetBlk) == 'L',lRetBlk,lRet)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TmsCopyReg³ Autor ³Rodrigo Sartorio       ³ Data ³ 04-04-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que copia um registro do arquivo.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCopyReg(aCampos)

Local nx
Local aArea     := GetArea()
Local aRegistro := {}
Local nPosicao  := 0

DEFAULT aCampos	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le as informacoes do registro corrente                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx:=1 to FCount()
	AAdd(aRegistro,FieldGet(nx))
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a gravacao do novo registro                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock(Alias(),.T.)
For nx := 1 TO FCount()
	FieldPut(nx,aRegistro[nx])
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera o conteudo dos campos passados como referencia           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 to Len(aCampos)
	nPosicao:=FieldPos(aCampos[nx][1])
	If nPosicao > 0
		FieldPut(nPosicao,aCampos[nx][2])
	EndIf
Next nx
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no registro original                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsChkLayOut³ Autor ³ Alex Egydio         ³ Data ³16.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Compara a configuracao entre duas tabelas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabela anterior                                    ³±±
±±³          ³ ExpC2 = Tipo da tabela anterior                            ³±±
±±³          ³ ExpC3 = Produto da tabela anterior                         ³±±
±±³          ³ ExpC4 = Tabela atual                                       ³±±
±±³          ³ ExpC5 = Tipo da tabela atual                               ³±±
±±³          ³ ExpC6 = Produto da tabela atual                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsChkLayOut(cTabOld, cTpTOld, cPrdOld, cTabFre, cTipTab, cCodPro, lChkFai)

Local aAreaAnt	:= GetArea()
Local aAreaDVE	:= DVE->(GetArea())
Local aCompOld	:= {}
Local aCompAtu	:= {}
Local lRet		:= .T.
Local nCntFor	:= 0
Local nSeek		:= 0

DEFAULT cPrdOld := Space(Len(SB1->B1_COD))
DEFAULT cCodPro := Space(Len(SB1->B1_COD))
DEFAULT lChkFai := .F.

If	Empty(cTabFre) .Or. Empty(cTipTab)
	Help(' ',1,'TMSXFUNB18')		//-- A tabela atual nao foi informada
	Return( .F. )
EndIf

If	cTabOld+cTpTOld+cPrdOld == cTabFre+cTipTab+cCodPro
	Help(' ',1,'TMSXFUNB19')		//-- Tabelas identicas
	Return( .F. )
EndIf
//-- Carrega componentes de ambas as tabelas
If	Empty(cTpTOld)
	cTpTOld	:= ''
	bWhile	:= {|| DVE->( ! Eof() .And. DVE->DVE_FILIAL + DVE->DVE_TABFRE == xFilial('DVE') + cTabOld ) }
Else
	bWhile	:= {|| DVE->( ! Eof() .And. DVE->DVE_FILIAL + DVE->DVE_TABFRE + DVE->DVE_TIPTAB == xFilial('DVE') + cTabOld + cTpTOld ) }
EndIf
DVE->(DbSetOrder(1))
If	DVE->(MsSeek(xFilial('DVE') + cTabOld + cTpTOld))
	While Eval(bWhile)
		AAdd(aCompOld,DVE->DVE_CODPAS)
		DVE->(DbSkip())
	EndDo
EndIf

If	Empty(cTipTab)
	cTipTab	:= ''
	bWhile	:= {|| DVE->( ! Eof() .And. DVE->DVE_FILIAL + DVE->DVE_TABFRE == xFilial('DVE') + cTabFre ) }
Else
	bWhile	:= {|| DVE->( ! Eof() .And. DVE->DVE_FILIAL + DVE->DVE_TABFRE + DVE->DVE_TIPTAB == xFilial('DVE') + cTabFre + cTipTab ) }
EndIf
DVE->(DbSetOrder(1))
If	DVE->(MsSeek(xFilial('DVE') + cTabFre + cTipTab))
	While Eval(bWhile)
		AAdd(aCompAtu,DVE->DVE_CODPAS)
		DVE->(DbSkip())
	EndDo
EndIf
//-- Compara a configuracao das tabelas
If	Len(aCompOld) != Len(aCompAtu)
	Help(' ',1,'TMSXFUNB20',,STR0042 + cTabOld + '  ' + cTpTOld + '   -   ' + cTabFre + '  ' + cTipTab,5,1)		//-- A Configuracao das tabelas estao diferentes###"Tabelas: "
	Return( .F. )
EndIf

For nCntFor := 1 To Len(aCompAtu)
	nSeek := AScan(aCompOld,aCompAtu[nCntFor])
	If	nSeek <= 0
		Help(' ',1,'TMSXFUNB20',,STR0042 + cTabOld + '  ' + cTpTOld + '   -   ' + cTabFre + '  ' + cTipTab,5,1)		//-- A Configuracao das tabelas estao diferentes###"Tabelas: "
		lRet := .F.
   	Exit
	EndIf
Next

RestArea(aAreaDVE)
RestArea(aAreaAnt)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVisViag³ Autor ³ Alex Egydio           ³ Data ³14.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza a Viagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVisViag()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±³          ³ ExpC3 = Servico de Transporte                              ³±±
±±³          ³ ExpC4 = Tipo de Transporte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsVisViag(cFilOri,cViagem,cSerTms,cTipTra)

Local aAreaDTQ   := DTQ->(GetArea())
Local cSavFilter := DTQ->(DbFilter())
Local cExpress   := DTQ->(IndexKey())
Local cModViag   := SuperGetMV('MV_MODVIAG',,'1')
Local lPainel    := IsInCallStack("TMSAF76")  //Painel sempre Modelo 2

Private aIndex  := {}
Private lLocaliz   := GetMv('MV_LOCALIZ') == 'S'
Default cSerTms  := ''
Default cTipTra  := ''

//-- limpa o filtro do arquivo de viagens
DTQ->(dbClearFilter())
Inclui := .F.

DTQ->(DbSetOrder(2))
If	DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))

	cSerTms := IIf(Empty(cSerTms),DTQ->DTQ_SERTMS,cSerTms)
	cTipTra := IIf(Empty(cTipTra),DTQ->DTQ_TIPTRA,cTipTra)

	 If (cModViag == '1' .Or. Empty(cModViag)) .And. !lPainel
     	If	cSerTms == StrZero(2,Len(cSerTms))
		  TmsA140(cSerTms,cTipTra,,2)
	    Else
		  TmsA141(cSerTms,cTipTra, ,2,.T.)      //.T. == Viagem Modelo 1
	    EndIf
     Elseif cModViag == '2' .Or. lPainel
	    TmsA144Mnt('DTQ',DTQ->(Recno()),2,)
     EndIf
EndIf

If !Empty(cSavFilter) .And. !Empty(cExpress)
	cSavFilter += " .AND.ORDERBY("+ClearKey(StrTran(cExpress,"+",","))+")"
EndIf
//-- Restaura filtro
If !Empty(cSavFilter)
	DbSelectArea("DTQ")
	DbSetFilter({||&(cSavFilter)},cSavFilter)
Else
	DTQ->(dbClearFilter())
EndIf

RestArea(aAreaDTQ)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsVisManif³ Autor ³ Alex Egydio          ³ Data ³14.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta uma lista com todos os manifestos da viagem      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de origem da viagem                         ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsVisManif(cFilOri,cViagem)

Local cCampo	:= ''
Local nCntFor	:= 0
Local nItem		:= 0
//-- Dialog
Local aBtnManif := {}
Local oDlgEsp

SaveInter()

//-- GetDados
Private aHeader	:= {}
Private aCols	:= {}
Private oGetD

DTX->(DbSetOrder(3))
If	DTX->(MsSeek(xFilial('DTX') + cFilOri + cViagem))

	//-- Preenche aHeader
    aHeader := ApBuildHeader("DTX")

	//-- Preenche aCols
	While DTX->( ! Eof() .And. DTX->DTX_FILIAL + DTX->DTX_FILORI + DTX->DTX_VIAGEM == xFilial('DTX') + cFilOri + cViagem )

		AAdd( aCols, Array( Len( aHeader ) + 1 ) )
		nItem := Len(aCols)
		RegToMemory('DTX',.F.)

		For nCntFor := 1 To Len(aHeader)
			cCampo := aHeader[nCntFor,2]
			GDFieldPut( cCampo, M->&(cCampo), nItem )
		Next

		aCols[ nItem, Len( aHeader ) + 1 ] := .F.

		DTX->(DbSkip())
	EndDo

	cCadastro := STR0043 //"Manifesto"

	AAdd(aBtnManif,{'RELATORIO',{|| DTX->(DbSetOrder(1)),Iif(DTX->(MsSeek(xFilial('DTX')+GDFieldGet('DTX_MANIFE',n)+GDFieldGet('DTX_SERMAN',n))),AxVisual('DTX',DTX->(Recno()),2),.F.) } ,STR0009 , STR0010 }) //"Visualiza Manifesto"

	DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM 9,0 TO 27.5,80 OF oMainWnd

		oGetD := MSGetDados():New(35,3,138,314,2,'AllwaysTrue()','AllwaysTrue()')

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()},, aBtnManif ) CENTERED
EndIf

RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSTipoVei³ Autor ³ Richard Anderson      ³ Data ³05.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o descricao do tipo do veiculo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do veiculo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSTipoVei( cCodVei )

Local cTipVei := M_Posicione( 'DA3', 1, xFilial( 'DA3' ) + cCodVei, 'DA3_TIPVEI' )
Local cDesTip := ''

DUT->( DbSetOrder( 1 ) )
If DUT->( MsSeek( xFilial( 'DUT' ) + cTipVei ) )
	cDesTip := DUT->DUT_DESCRI
EndIf

Return( cDesTip )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TMSRegDes  ³ Autor ³ Patricia A. Salomao ³ Data ³30.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar as Regioes de Destino da Rota                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSRegDes(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Rota                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Array contendo:                                            ³±±
±±³          ³ aRet[1] - Regiao Origem da Rota                            ³±±
±±³          ³ aRet[2] - Regioes de Destino da Rota                       ³±±
±±³          ³ aRet[3] - Filiais de Destino da Rota                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRegDes(cRota)
Local aAreaAnt := GetArea()
Local aAreaDA8 := DA8->( GetArea() )
Local aAreaDUN := DUN->( GetArea() )
Local aAreaDUY := DUY->( GetArea() )
Local aRegs    := {}
Local cCdrOri  := ""
Local cQuery   := ""
Local cAliasQry:= ""
Default cRota  := ""

aRegs := GetRegDes( cRota )

If Len(aRegs) == 0
	DA8->( DbSetOrder( 1 ) )
	DA8->( MsSeek( xFilial() + cRota ) )
	cCdrOri := DA8->DA8_CDRORI

	DUN->(DbSetOrder(1))

	cAliasQry := GetNextAlias()
	cQuery := "   SELECT DUN_CDRDES, DUN_FILDES "
	cQuery += "     FROM " + RetSqlName("DUN")
	cQuery += "    WHERE DUN_FILIAL = '" + xFilial('DUN') + "' "
	cQuery += "      AND DUN_ROTEIR	 = '" + cRota + "' "
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + SqlOrder(DUN->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	While (cAliasQry)->(!Eof())
		AAdd(aRegs, {cCdrOri, (cAliasQry)->DUN_CDRDES, (cAliasQry)->DUN_FILDES })
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	SetRegDes( cRota, aRegs)

	RestArea( aAreaDA8 )
	RestArea( aAreaDUN )
	RestArea( aAreaDUY )
	RestArea( aAreaAnt )
EndIf

Return( aRegs  )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetRegDes ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes das regioes de destino da rota, funcao³±±
±±³          ³TMSRegDes() ao vetor aTMSRegDes                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetRegDes()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Rota                                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetRegDes( cRota, aRegiao)
	Default aRegiao	:= {}
	Default cRota	:= ""

	If ValType(aTMSRegDes) <> 'A'
		Static aTMSRegDes := {}
	EndIf

	//////////////////////////////////////////////////////////////////////////
	// Manter o vetor aRegiao sempre na ultima posicao do vetor aTMSRegDes, //
	// para que a funcao GetRegDes() funcione corretamente.                 //
	//////////////////////////////////////////////////////////////////////////
	If Len(aRegiao) > 0
		Aadd( aTMSRegDes, { cRota, aRegiao } )
	EndIf
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRegDes ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes das regioes de destino da rota exis- ³±±
±±³          ³tentes no vetor aTMSRegDes. O intuito dessa rotina eh rea-  ³±±
±±³          ³proveitar as informacoes ja processadas pela funcao         ³±±
±±³          ³TMSRegDes()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetRegDes()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Rota                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Array contendo:                                            ³±±
±±³          ³ aRet[1] - Regiao Origem da Rota                            ³±±
±±³          ³ aRet[2] - Regioes de Destino da Rota                       ³±±
±±³          ³ aRet[3] - Filiais de Destino da Rota                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetRegDes( cRota )
	Local aRetorno	:= {}
	Local nPosicao	:= 0
	Default cRota	:= ""

	If ValType(aTMSRegDes) <> 'A'
		Static aTMSRegDes := {}
	EndIf

	If Len(aTMSRegDes) > 0
		aRetorno := {}
		nPosicao := Ascan( aTMSRegDes, { |x| x[1] == cRota } )

		If nPosicao > 0
			aRetorno := aTMSRegDes[ nPosicao, Len(aTMSRegDes[ nPosicao] ) ]
		EndIf
	EndIf
Return ( aRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsRegDCA ³ Autor ³ Richard Anderson      ³ Data ³17.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar as filiais de descarga da viagem                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsRegDCA ( ExpC1, ExpC2 )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1   = Rota                                             ³±±
±±³          ³ ExpC2   = Regial de Destino                                ³±±
±±³          ³ ExpL1   = Considera Regiao de Origem ?                     ³±±
±±³          ³ ExpL1   = Verifica se obtem a Regiao de Origem da Rota ou  ³±±
±±³          ³           da Filial (MV_CDRORI)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Array contendo:                                            ³±±
±±³          ³ aRet[1] - Regiao Origem da Rota                            ³±±
±±³          ³ aRet[2] - Regioes de Descarga da Rota                      ³±±
±±³          ³ aRet[3] - Filiais de Descarga da Rota                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsRegDCA( cRota, cRegiao, lConsOri, lRegOriRot )

Local aAreaDUY  := DUY->( GetArea() )
Local aAreaDA8  := DA8->( GetArea() )
Local aAreaDUN  := DUN->( GetArea() )
Local cSeek     := ""
Local cFilDca   := ""
Local cCdrOri   := ""
Local aFilDCA   := {}
Local aRegiao   := {}
Local nA        := 0
Local cAliasQry := GetNextAlias()

Default cRota      := ""
Default cRegiao    := ""
Default lConsOri   := .T.
Default lRegOriRot := .T.

DA8->( DbSetOrder( 1 ) ) //DA8_FILIAL+DA8_COD
DUN->( DbSetOrder( 1 ) ) //DUN_FILIAL+DUN_ROTEIR+DUN_CDRDES
DUY->( DbSetOrder( 1 ) ) //DUY_FILIAL+DUY_GRPVEN

DA8->( MsSeek( xFilial('DA8') + cRota ) )
//-- Obtem a Regiao de Origem da Rota
If lRegOriRot .And. !Empty(DA8->DA8_CDRORI)
	cCdrOri := DA8->DA8_CDRORI
Else
	cCdrOri := GetMV('MV_CDRORI',,'')
EndIf

DUY->( MsSeek( xFilial( 'DUY' ) + cCdrOri ) )
If Empty(DUY->DUY_FILDES)
	cCdrOri := GetMV('MV_CDRORI',,'')
EndIf
If !Empty( cRegiao ) .And. DA8->DA8_SERTMS == StrZero( 2, Len( DA8->DA8_SERTMS ) )
	If DUN->( MsSeek( xFilial( 'DUN' ) + cRota + cRegiao ) )
		aFilDCA := { { cCdrOri, DUN->DUN_CDRDCA, DUN->DUN_FILDCA, DUN->DUN_SEQUEN } }
	Else
		// Retorna a regiao e as regioes dos niveis superiores.
		aRegiao := TmsNivSup( cRegiao )
		For nA := 1 To Len( aRegiao )
			If DUN->( MsSeek( xFilial("DUN") + cRota + aRegiao[nA] ) )
				aFilDCA := { { cCdrOri, DUN->DUN_CDRDCA, DUN->DUN_FILDCA, DUN->DUN_SEQUEN } }
				Exit
			EndIf
		Next nA
	EndIf
Else
	If DUY->( MsSeek( xFilial( 'DUY' ) + cCdrOri ) )

		//Considera Regiao de Origem
		If lConsOri
			AAdd( aFilDCA, { cCdrOri, cCdrOri, DUY->DUY_FILDES, '', M_Posicione('DUY',1,xFilial('DUY')+cCdrOri,'DUY_PAIS') })
		EndIf

		If DA8->DA8_SERTMS == StrZero(2,Len(DA8->DA8_SERTMS)) // Transporte
			If DA8->DA8_TIPTRA == StrZero(4,Len(DA8->DA8_TIPTRA)) //-- Região de fronteira para o Transporte Internacional
				cQuery := " SELECT DI5_FILDCA, MIN(DI5_CDRFRO) DI5_CDRFRO , MIN(DUY_PAIS) DUY_PAIS FROM "
				cQuery += RetSqlName("DI5")+" DI5, "
				cQuery += RetSqlName("DUY")+" DUY  "
				cQuery += " WHERE DI5.DI5_FILIAL  = '"+xFilial("DI5")+"'"
				cQuery += "   AND DI5.DI5_ROTA    = '"+cRota+"'"
				cQuery += "   AND DI5.DI5_FILDCA <> ' '"
				cQuery += "   AND DI5.D_E_L_E_T_  = ' '"
				cQuery += "   AND DUY.DUY_FILIAL  = '"+xFilial("DUY")+"'"
				cQuery += "   AND DUY.DUY_GRPVEN  = DI5_CDRFRO"
				cQuery += "   AND DUY.D_E_L_E_T_  = ' '"
				cQuery += " GROUP BY DI5_FILDCA"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
				While (cAliasQry)->(!Eof())
					AAdd( aFilDCA, { cCdrOri, (cAliasQry)->DI5_CDRFRO, (cAliasQry)->DI5_FILDCA, StrZero(0,Len(DUN->DUN_SEQUEN)), (cAliasQry)->DUY_PAIS })
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
			EndIf
			cQuery := " SELECT DUN_FILDCA, MIN(DUN_CDRDCA) DUN_CDRDCA, MIN(DUN_SEQUEN) DUN_SEQUEN , MIN(DUY_PAIS) DUY_PAIS FROM "
			cQuery += RetSqlName("DUN")+" DUN, "
			cQuery += RetSqlName("DUY")+" DUY  "
			cQuery += " WHERE DUN.DUN_FILIAL = '"+xFilial("DUN")+"'"
			cQuery += "   AND DUN.DUN_ROTEIR = '"+cRota+"'"
			cQuery += "   AND DUN.D_E_L_E_T_ = ' '"
			cQuery += "   AND DUY.DUY_FILIAL = '"+xFilial("DUY")+"'"
			cQuery += "   AND DUY.DUY_GRPVEN = DUN_CDRDCA"
			cQuery += "   AND DUY.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY DUN_FILDCA "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
			While (cAliasQry)->(!Eof())
				AAdd( aFilDCA, { cCdrOri, (cAliasQry)->DUN_CDRDCA, (cAliasQry)->DUN_FILDCA, (cAliasQry)->DUN_SEQUEN, (cAliasQry)->DUY_PAIS })
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf
EndIf

If !Empty( aFilDCA )
	ASort( aFilDCA,,, { | x, y | x[4] < y[4] } )
EndIf

RestArea( aAreaDA8 )
RestArea( aAreaDUN )
RestArea( aAreaDUY )

Return( aFilDCA )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsVisTbFre³ Autor ³ Alex Egydio          ³ Data ³14.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta a tabela de frete                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabela de Frete                                    ³±±
±±³          ³ ExpC2 = Tipo da Tabela                                     ³±±
±±³          ³ ExpC3 = Sequencia da Tabela                                ³±±
±±³          ³ ExpC4 = Regiao Origem                                      ³±±
±±³          ³ ExpC5 = Regiao Destino                                     ³±±
±±³          ³ ExpC6 = Servico                                            ³±±
±±³          ³ ExpC7 = Codigo do Produto                                  ³±±
±±³          ³ ExpC8 = Cliente                                            ³±±
±±³          ³ ExpC9 = Loja Cliente                                       ³±±
±±³          ³ ExpCA = Codigo de Negociacao                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsVisTbFre(cTabFre,cTipTab,cSeqTab,cCdrOri,cCdrDes,cServic,cCodPro,cCodCli,cLojCli,cCodNeg)

Local aAreaAnt := GetArea()
Local aAreaDT0 := DT0->(GetArea())
Local aAreaDVC := DVC->(GetArea())
Local lInclui  := Inclui
Local lRet     := .F.

Local cCodNegVaz := Space(Len(DVC->DVC_CODNEG))
Local lUsaTabOld := SuperGetMv( "MV_TMSTFO",  .F., .F. )
Private aFolder  := {}

DEFAULT cCodNeg := ""

Inclui := .F. //-- Visualizacao da Tabela de Frete / Ajuste


If cSeqTab <> StrZero(0,Len(DT6->DT6_SEQTAB))
	DVC->(DbSetOrder(7))
	If !DVC->( MsSeek(xFilial('DVC') + cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes + cCodPro + cCodNeg + cServic + cSeqTab))
		If !DVC->( MsSeek(xFilial('DVC') + cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes +  cCodPro + cCodNegVaz + cServic + cSeqTab ))
			If !DVC->( MsSeek(xFilial('DVC') + cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes +  Space( Len( DVC->DVC_CODPRO ) ) + cCodNeg + cServic  + cSeqTab ))
				If !DVC->( MsSeek(xFilial('DVC') + cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes +  Space( Len( DVC->DVC_CODPRO ) ) + cCodNegVaz + cServic  + cSeqTab ))
					If !DVC->( MsSeek(xFilial('DVC') + cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes +  cCodPro + cCodNeg + Space( Len( DVC->DVC_SERVIC ) ) + cSeqTab ))
						If !DVC->( MsSeek(xFilial('DVC') + cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes +  cCodPro + cCodNegVaz + Space( Len( DVC->DVC_SERVIC ) ) + cSeqTab ))
							lRet := DVC->( MsSeek(xFilial('DVC') + cCodCli + cLojCli + cTabFre + cTipTab + cCdrOri + cCdrDes + Space( Len( DVC->DVC_CODPRO ) ) + cCodNegVaz + Space( Len( DVC->DVC_SERVIC ) ) + cSeqTab ))
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			lRet := .T.
		EndIf
	Else
		lRet := .T.
	EndIf
	If lRet
		TmsA011(2)
	EndIf
EndIf

If cSeqTab == StrZero(0,Len(DT6->DT6_SEQTAB)) .Or. !lRet
	DbSelectArea("DT0")
	DT0->(DbSetOrder(1))
	If	!DT0->(DbSeek(xFilial('DT0') + cTabFre + cTipTab + cCdrOri + cCdrDes + cCodPro))
		DT0->(DbSeek(xFilial('DT0') + cTabFre + cTipTab + cCdrOri + cCdrDes + Space(Len(DTC->DTC_CODPRO)) ))
	EndIf
	If lUsaTabOld
		RegToMemory('DT0',.F.)
		TMSA010Mnt('DT0',DT0->(Recno()),1,.F.)
	Else
		FWExecView (, "TMSA010A" , 1 , ,{|| .T. }, , , , , , , ) //Visualizar
	EndIf
EndIf

Inclui := lInclui

RestArea(aAreaDVC)
RestArea(aAreaDT0)
RestArea(aAreaAnt)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsPerfil ³ Autor ³ Alex Egydio          ³ Data ³14.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informacoes do perfil do cliente ou cliente generico       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente                                  ³±±
±±³          ³ ExpC2 = Loja                                               ³±±
±±³          ³ ExpL1 = .T. Procura o perfil do cliente generico           ³±±
±±³          ³ ExpL2 = .T. Apresenta help                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsPerfil(cCliente,cLoja,lCliGen,lHelp,cCliRem,cLojRem,cCliDes,cLojDes)


Local aAreaAnt	:= GetArea()
Local aAreaDUO	:= DUO->(GetArea())
Local aAreaDTI  := DTI->(GetArea())
Local aRet      := {}
Local aAltera   := {}
Local cCliGen   := ""
Local cPrcProd  := ""
Local nCount    := 0
Local lAchou    := .T.
Local lRet      := .T.
Local cCodGen   := ""
Local cLojGen   := ""
Local lDUOTPCALC := DUO->(FieldPos("DUO_TPCALC")) > 0
Local lDUOPreFat := DUO->(ColumnPos("DUO_PREFAT") > 0 .And.;
						  ColumnPos("DUO_FATAUT") > 0 .And.;
						  ColumnPos("DUO_VALFAT") > 0 .And.;
						  ColumnPos("DUO_TIPTOL") > 0 .And.;
						  ColumnPos("DUO_VALTOL") > 0 .And.;
						  ColumnPos("DUO_QBRPRF") > 0 .And.;
						  ColumnPos("DUO_TPVENC") > 0) 

DEFAULT lCliGen := .T.
DEFAULT lHelp   := .T.
DEFAULT cCliRem := ''
DEFAULT cLojRem := ''
DEFAULT cCliDes := ''
DEFAULT cLojDes := ''

//-- Verifica o tipo de perfil utilizado no cadastro de consignatarios
If	!Empty(cCliRem) .And. !Empty(cLojRem) .And. ;
	!Empty(cCliDes) .And. !Empty(cLojDes)
	cCliGen := SuperGetMV('MV_CLIGEN')

    cCodGen := Left(Alltrim(cCliGen),Len(DTC->DTC_CLIREM))
    cLojGen := Right(Alltrim(cCliGen),Len(DTC->DTC_LOJREM))

	If !TmsConsig(cCliRem,cLojRem,cCliDes,cLojDes)
		If !TmsConsig(cCliRem,cLojRem,cCodGen,cLojGen)
			If !TmsConsig(cCodGen,cLojGen,cCliDes,cLojDes)
				lAchou:= .F.
			EndIf
		EndIf
	EndIf
	If lAchou
		If DTI->DTI_TIPPER == StrZero(1,Len(DTI->DTI_TIPPER)) //-- Remetente
			cCliente := DTI->DTI_CLIREM
			cLoja    := DTI->DTI_LOJREM
		ElseIf DTI->DTI_TIPPER == StrZero(2,Len(DTI->DTI_TIPPER)) //-- Destinatario
			cCliente := DTI->DTI_CLIDES
			cLoja    := DTI->DTI_LOJDES
		ElseIf DTI->DTI_TIPPER == StrZero(3,Len(DTI->DTI_TIPPER)) //-- Consignatario
			cCliente := DTI->DTI_CLICON
			cLoja    := DTI->DTI_LOJCON
		EndIf
	EndIf
	RestArea( aAreaDTI )
EndIf

aRet := {}
aRet := GetPerfil( cCliente, cLoja)

If Len(aRet) == 0
	DUO->(DbSetOrder( 1 ))
	If	DUO->(!MsSeek(xFilial('DUO') + cCliente + cLoja))
		If	lCliGen
			cCliente	:= Left(AllTrim(GetMV('MV_CLIGEN')),Len(AAM->AAM_CODCLI))
			cLoja		:= Right(AllTrim(GetMV('MV_CLIGEN')),Len(AAM->AAM_LOJA))
			DUO->(MsSeek(xFilial('DUO') + cCliente + cLoja))
		EndIf
	EndIf
	If DUO->(Eof())
		If	lHelp
			Help('', 1, 'TMSXFUNB25',,STR0029 + cCliente + ' / ' + cLoja,4,1)	//-- Perfil do cliente nao encontrado. (DUO)###"Cliente: "
		EndIf
	Else
		//-- Verifica se o cliente utiliza produto para o calculo do frete
		If !Empty(DUO->DUO_PRCPRD)
			cPrcProd := DUO->DUO_PRCPRD
		Else
			cPrcProd := Iif(lPrcProd,"1","2")
		EndIf
		//-- Formato do vetor aRet
		AAdd(aRet,DUO->DUO_CLIAGR)		//--[01] = Cliente agrupamento
		AAdd(aRet,DUO->DUO_LOJAGR)		//--[02] = Loja do cliente agrupamento
		AAdd(aRet,DUO->DUO_CNDFRE)		//--[03] = Condicao de frete
		AAdd(aRet,DUO->DUO_FOBDIR)		//--[04] = FOB Dirigido
		AAdd(aRet,DUO->DUO_CUBAGE)		//--[05] = Cubagem
		AAdd(aRet,DUO->DUO_BASFAT)		//--[06] = Base faturamento
		AAdd(aRet,DUO->DUO_TIPFAT)		//--[07] = Tipo de faturamento
		AAdd(aRet,DUO->DUO_CPVENT)		//--[08] = Comprovante de entrega
		AAdd(aRet,DUO->DUO_RESCPV)		//--[09] = Responsavel comprovante
		AAdd(aRet,DUO->DUO_VALMAX)		//--[10] = Valor maximo da fatura
		AAdd(aRet,DUO->DUO_QTDCTR)		//--[11] = Qtde.CTRC por fatura
		AAdd(aRet,DUO->DUO_SEPPRO)		//--[12] = Separa grupos de produto
		AAdd(aRet,DUO->DUO_SEPEST)		//--[13] = Separa estados
		AAdd(aRet,DUO->DUO_SEPTRA)		//--[14] = Separa tipo de transporte
		AAdd(aRet,DUO->DUO_SEPFRE)		//--[15] = Separa CIF / FOB
		AAdd(aRet,DUO->DUO_TAXCTR)		//--[16] = Taxa por CTRC
		AAdd(aRet,DUO->DUO_SEPDOC)		//--[17] = Separa tipo de documento
		AAdd(aRet,DUO->DUO_NFCTR )		//--[18] = Qtde. NFs por CTRC
		AAdd(aRet,DUO->DUO_AJUOBR)		//--[19] = Ajuste Obrigatorio
		AAdd(aRet,DUO->DUO_PESCTR)		//--[20] = Peso Maximo CTRC
		AAdd(aRet,DUO->DUO_SEPREM)		//--[21] = Separa FOB + Cliente Remetente
		AAdd(aRet,DUO->DUO_AGRNFC)		//--[22] = Determina se a geracao de documentos ira ou nao, considerar as quebras por numero de notas fiscais por CTRC e peso maximo por CTRC
		AAdd(aRet,DUO->DUO_SEPENT)		//--[23] = Separa CTRC Entregue / CTRC Nao Entregue
		AAdd(aRet,DUO->DUO_RECFRE)		//--[24] = Determina se recalcula o valor do frete caso as informacoes da nota fiscal seja diferente da cotacao de frete
		AAdd(aRet,DUO->DUO_PGREEN)		//--[25] = Paga Reentrega
		AAdd(aRet,DUO->DUO_REENT1)		//--[26] = % Relativo a 1a Reentrega
		AAdd(aRet,DUO->DUO_REENT2)		//--[27] = % Relativo a 2a Reentrega
		AAdd(aRet,DUO->DUO_REENT3)		//--[28] = % Relativo a 3a Reentrega
		AAdd(aRet,DUO->DUO_REENT9)		//--[29] = % Relativo as demais Reentregas
		AAdd(aRet,DUO->DUO_MAXREE)		//--[30] = Valor Maximo de Cobranca
		AAdd(aRet,DUO->DUO_VLRFIX)		//--[31] = Valor Fixo por Reentrega
		AAdd(aRet,DUO->DUO_PRIREE)		//--[32] = Primeira Tentativa de Cobranca de Reentrega
		AAdd(aRet,DUO->DUO_MDCREE)		//--[33] = Valor Minimo do Documento Original
		AAdd(aRet,DUO->DUO_PGREFA)		//--[34] = Paga Refaturamento
		AAdd(aRet,DUO->DUO_REFAT1)		//--[35] = % Refaturamento
		AAdd(aRet,DUO->DUO_MDCREF)		//--[36] = Valor Minimo do Documento Original para Refaturamento
		AAdd(aRet,DUO->DUO_TPDIAS)		//--[37] = Tipo de dias "1"=Dias uteis;"2"=Dias corridos
		AAdd(aRet,DUO->DUO_PGARMZ)		//--[38] = Paga Amazenagem
		AAdd(aRet,DUO->DUO_PERCOB)		//--[39] = Minimo de Dias para Armazenagem
		AAdd(aRet,DUO->DUO_PERMAX)		//--[40] = Maximo de Dias para Armazenagem
		AAdd(aRet,DUO->DUO_MINARM)		//--[41] = Valor Minimo de Armazenagem
		AAdd(aRet,DUO->DUO_MAXARM)		//--[42] = Valor Maximo de Armazenagem
		AAdd(aRet,DUO->DUO_MDCARM)		//--[43] = Valor Minimo do Documento Original para Armazenagem
		AAdd(aRet,DUO->DUO_CODCLI)		//--[44] = Cliente
		AAdd(aRet,DUO->DUO_LOJCLI)		//--[45] = Loja Cliente
		AAdd(aRet,cPrcProd)				//--[46] = Utiliza produto para calculo do frete
		AAdd(aRet,DUO->DUO_DOCFAT)		//--[47] = Documentos para tratamento diferenciado no faturamento a partir do DT6 (MV_TMSMFAT)
		AAdd(aRet,DUO->DUO_MINREE)		//--[48] = Valor Minimo de Cobranca
		AAdd(aRet,DUO->DUO_PAGTDA)		//--[49] = Paga TDA (1-Coleta, 2-Entrega, 3-Ambas, 4- Coleta ou Entrega)
		AAdd(aRet,DUO->DUO_EDIAUT)		//--[50] = EDI Automatico
		AAdd(aRet,DUO->DUO_EDILOT)		//--[51] = Lote de EDI Automatico
		AAdd(aRet,DUO->DUO_EDIFRT)		//--[52] = Frete de EDI Automatico
		AAdd(aRet,DUO->DUO_BASREE)		//--[53] = Base Reentrega (1-Com Imposto, 2-Sem Imposto)
		AAdd(aRet,Iif(lDUOTPCALC,DUO->DUO_TPCALC,'0'))	//--[54] = Tipo de Cálculo da Reentrega (1-Por Percentual, 2-Por Trecho)
		AAdd(aRet,Iif(DUO->(ColumnPos('DUO_AGEAUT'))>0,DUO->DUO_AGEAUT,'0'))	//--[55] = Gera Agendamento Automatico a partir do EDI de Agendamento? (POSICAO UTILIZADA PELA FUNCAO "TMSAgAUT" EXISTENTE NO TMSXFUNc
		AAdd(aRet,Iif(DUO->(ColumnPos('DUO_AGECON'))>0,DUO->DUO_AGECON,'0'))	//--[56] = Gera Solicitação De Coleta Automaticamente a partir do EDI de Agendamento? (POSICAO UTILIZADA PELA FUNCAO "TMSAgAUT" EXISTENTE NO TMSXFUNc
		AAdd(aRet,Iif(DUO->(ColumnPos('DUO_ESTAGR'))>0,DUO->DUO_ESTAGR,'1'))	//--[57] = Estorno Frete Agrupado
		AAdd(aRet,Iif(DUO->(ColumnPos('DUO_SEPSRV'))>0,DUO->DUO_SEPSRV,'1'))	//--[58] = Separa Serviço TMS
		AAdd(aRet,Iif(DUO->(ColumnPos('DUO_SEPNEG'))>0,DUO->DUO_SEPNEG,'1'))	//--[59] = Separa Código de Negociação
		AAdd(aRet,Iif(DUO->(ColumnPos('DUO_MULTFA'))>0,DUO->DUO_MULTFA,'2'))	//--[60] = Permite multi faturamento do cliente na rotina fatura por documento
		
		AAdd(aRet,{}) //--[61] = Pré-Fatura - array
		If lDUOPreFat
			AAdd(aRet[61],DUO->DUO_PREFAT) //-- [61][1] Emite Fatura apenas com Pré-Fatura
			AAdd(aRet[61],DUO->DUO_FATAUT) //-- [61][2] Gera Fatura após a importação da Pré-Fatura
			AAdd(aRet[61],DUO->DUO_VALFAT) //-- [61][3] Valor faturado pela pré-fatura ou calculo TMS
			AAdd(aRet[61],DUO->DUO_TIPTOL) //-- [61][4] Tolerância Percentual, Valor ou "não-utiliza"
			AAdd(aRet[61],DUO->DUO_VALTOL) //-- [61][5] Valor Tolerância
			AAdd(aRet[61],DUO->DUO_QBRPRF) //-- [61][6] Permite "quebrar" uma pré-fatura em "n" faturas
			AAdd(aRet[61],DUO->DUO_TPVENC) //-- [61][7] Cond.Pagto Cliente ou Dt.Pré-Fatura
			If DUO->(ColumnPos("DUO_PRFEDI")) > 0
				AAdd(aRet[61],DUO->DUO_PRFEDI) //-- [61][8] Envio automático do EDI financeiro (DOCCOB) após gerar fatura via pré-fatura
			EndIf
		EndIf
	EndIf

	If lTMSPerfil
		aAltera := Execblock("TMSPERFIL",.F.,.F.,aRet)
		If ValType(aAltera) == "A" .And. Len(aAltera) == Len(aRet)
			For nCount := 1 To Len(aRet)
				If ValType(aRet[nCount]) <> ValType(aAltera[nCount])
					lRet := .F.
					Exit
				EndIf
			Next nCount
			If lRet
				aAreaSA1 := SA1->( GetArea() )
				SA1->( DbSetOrder(1) )
				 // pesquisa se os clientes retornados no ponto de entrada existem na base de dados
				If aAltera[1] + aAltera[2] <> aRet[1] + aRet[2]
					If !SA1->( MsSeek( xFilial("SA1") + aAltera[1] + aAltera[2] ) )
						lRet := .F.
					EndIf
				EndIf
				If lRet .And. aAltera[44] + aAltera[45] <> aRet[44] + aRet[45]
					If !SA1->( MsSeek( xFilial("SA1") + aAltera[44] + aAltera[45] ) )
						lRet := .F.
					EndIf
				EndIf
				RestArea(aAreaDUO)
			EndIf
			If lRet
				aRet := {}
				aRet := aClone(aAltera)
			EndIf
		EndIf
	EndIf

	SetPerfil( cCliente, cLoja, aRet)
	RestArea(aAreaDUO)
EndIf

RestArea(aAreaAnt)

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetPerfil ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adicionar informacoes do perfil, funcao TmsPerfil() ao      ³±±
±±³          ³vetor aTmsPerfil                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SetPerfil()                                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente                                  ³±±
±±³          ³ ExpC2 = Loja                                               ³±±
±±³          ³ ExpA1 - Vetor contendo todas as informacoes do Perfil.     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetPerfil( cCliente, cLoja, aPerfil)
	Default aPerfil  := {}
	Default cCliente := ""
	Default cLoja    := ""

	If ValType(aTmsPerfil) <> 'A'
		Static aTmsPerfil := {}
	EndIf

	//////////////////////////////////////////////////////////////////////////
	// Manter o vetor aPerfil sempre na ultima posicao do vetor aTmsPerfil, //
	// para que a funcao GetPerfil() funcione corretamente.                 //
	//////////////////////////////////////////////////////////////////////////
	If Len(aPerfil) > 0
		Aadd( aTmsPerfil, { cCliente, cLoja, aPerfil } )
	EndIf
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetPerfil ³ Autor ³ Adalberto S.M         ³ Data ³13.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Requisitar informacoes do perfil existentes no vetor        ³±±
±±³          ³aTmsPerfil. O intuito dessa rotina eh reaproveitar as infor-³±±
±±³          ³macoes ja processadas pela funcao TmsPerfil().              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetPerfil()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente                                  ³±±
±±³          ³ ExpC2 = Loja                                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo dados do Perfil.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetPerfil( cCliente, cLoja)
	Local aRetorno   := {}
	Local nPosicao   := 0
	Default cCliente := ""
	Default cLoja    := ""

	If ValType(aTmsPerfil) <> 'A'
		Static aTmsPerfil := {}
	EndIf

	If Len(aTmsPerfil) > 0
		aRetorno := {}
		nPosicao := Ascan( aTmsPerfil, { |x| x[1] + x[2] == cCliente + cLoja } )

		If nPosicao > 0
			aRetorno := aTmsPerfil[ nPosicao, Len(aTmsPerfil[ nPosicao] ) ]
		EndIf
	EndIf
Return ( aRetorno )

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} TMSLimpaPerfil
Limpa os perfis armazenados em memória no array aTmsPerfil
Uso Interno.

@protected
@author Israel A Possoli
@since 28/04/2016
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function TMSLimpaPerfil()
	If ValType(aTmsPerfil) <> 'A'
		Static aTmsPerfil := {}
		Return (Nil)
	EndIf

	aTmsPerfil := {}
	aSize(aTmsPerfil, 0)
Return (Nil)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsChkTES  ³ Autor  ³ Alex Egydio              ³ Data  ³ 14.05.2003   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o TES esta configurado corretamente para o tipo           ³±±
±±³          ³ de movimento                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo do movimento                                             ³±±
±±³          ³         1 = Entrada de nota fiscal do cliente                         ³±±
±±³          ³         2 = Geracao de documentos                                     ³±±
±±³          ³         3 = Baixa de estoque                                          ³±±
±±³          ³         4 = Regra de Tributacao                                       ³±±
±±³          ³         5 = AWB                                                       ³±±
±±³          ³ ExpC2 = Tes (Obrigatorio qd tipo do movimento igual a 2)              ³±±
±±³          ³ ExpC3 = Tipo do documento (Obrigatorio qd tipo do movimento igual a 2)³±±
±±³          ³ ExpL1 = .T. Apresenta help                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsChkTES(cAcao,cTes,cDocTms,lHelp)

Local cEntEstoq  := ''
Local cEntPoder3 := ''
Local cTesEnt    := ''

DEFAULT cTes  := ''
DEFAULT lHelp := .T.

//-- Entrada de Nota Fiscal do Cliente
If	cAcao == '1'

	cTes := GetMV('MV_TESDR',,'')

	If !Empty(cTes)

		SF4->(DbSetOrder(1))
		If	! SF4->(MsSeek(xFilial('SF4') + cTes))
			If	lHelp
				Help(' ',1,'TMSXFUNB26',,STR0044 + cTesEnt,5,11)	//-- O Tes Informado no parametro MV_TESDR nao foi encontrado (SF4)###" TES : "
			EndIf
			Return( .F. )
		EndIf

		If	SF4->F4_TIPO != 'E'
			If	lHelp
				Help(' ',1,'TMSA20016',,STR0044 + cTes,5,11)	//-- Tipo de entrada/saida informado no parametro MV_TESDR nao e' um TES de entrada (SF4)###" TES : "
			EndIf
			Return( .F. )
		EndIf

		If	SF4->F4_DUPLIC == 'S'
			If	lHelp
				Help(' ',1,'TMSXFUNA31',,STR0044 + cTes,5,11)	//-- O TES Informado no parametro MV_TESDR Nao pode estar configurado para gerar Duplicata !###" TES : "
			EndIf
			Return( .F. )
		EndIf

		If	SF4->F4_ESTOQUE == "S" .And. SF4->F4_PODER3 <> 'R'
			If	lHelp
				Help(' ',1,'TMSXFUNA32',,STR0044 + cTes,5,11)	//-- O Tes Informado no parametro MV_TESDR, tem que ser de "Remessa" de Poder de Terceiros###" TES : "
			EndIf
			Return( .F. )
		EndIf
	Else
		Help(' ',1,'HELP',,STR0151,5,11) //--O Parametro MV_TESDR, não existe do Dicionário de Dados
		Return( .F. )
	EndIf

//-- Geracao de documentos
ElseIf cAcao == '2'

	SF4->(DbSetOrder(1))
	If	! SF4->(MsSeek(xFilial('SF4') + cTes))
		If	lHelp
			Help(' ',1,'TMSXFUNB27',,STR0044 + cTes,5,11)	//-- Tes nao encontrado (SF4)###" TES : "
		EndIf
		Return( .F. )
	EndIf

	If SF4->F4_ESTOQUE == 'S'
		If	lHelp
			Help(' ',1,'TMSXFUNB28',,STR0044 + cTes,5,11)	//-- O TES nao pode estar configurado para atualizar estoque###" TES : "
		EndIf
		Return( .F. )
	EndIf
	//-- Se nao for CTRC de cortesia devera gerar duplicata
	If	cDocTms != Replicate('A',Len(DC5->DC5_DOCTMS))
		If	SF4->F4_PODER3 != 'N'
			If	lHelp
				Help(' ',1,'TMSXFUNB29',,STR0044 + cTes,5,11)	//-- O TES nao pode estar configurado para controlar poder de terceiros###" TES : "
			EndIf
			Return( .F. )
		EndIf

		If	SF4->F4_DUPLIC == 'N'
			If	lHelp
				Help(' ',1,'TMSXFUNB30',,STR0044 + cTes,5,11)	//-- O TES deve estar configurado para gerar duplicatas###" TES : "
			EndIf
			Return( .F. )
		EndIf
	EndIf

//-- Baixa de estoque
ElseIf cAcao == '3'

	cTesEnt	:= GetMV('MV_TESDR',,'')
	cTes	:= GetMV('MV_TESDD',,'')

	If	! SF4->(MsSeek(xFilial('SF4') + cTesEnt))
		If	lHelp
			Help(' ',1,'TMSXFUNB26',,STR0044 + cTesEnt,5,11)	//-- O Tes Informado no parametro MV_TESDR nao foi encontrado (SF4)###" TES : "
		EndIf
		Return( .F. )
	EndIf
	cEntEstoq  := SF4->F4_ESTOQUE
	cEntPoder3 := SF4->F4_PODER3

	If	! SF4->(MsSeek(xFilial('SF4') + cTes))
		If	lHelp
			Help(' ',1,'TMSXFUNB21',,STR0044 + cTes,5,11)	//-- O Tes Informado no parametro MV_TESDD nao foi encontrado (SF4)###" TES : "
		EndIf
		Return( .F. )
	EndIf

	If	SF4->F4_TIPO <> 'S'
		If	lHelp
			Help(' ',1,'TMSXFUNB22',,STR0044 + cTes,5,11)	//-- O Tes Informado no parametro MV_TESDD Nao e' de Saida###" TES : "
		EndIf
		Return( .F. )
	EndIf

	If	SF4->F4_ESTOQUE <> cEntEstoq
		If	lHelp
			Help(' ',1,'TMSXFUNB23',,STR0044 + cTes,5,11)	//-- Existe divergencia entre o TES informado no parametro MV_TESDD e o TES informado no parametro MV_TESDR###" TES : "
		EndIf
		Return( .F. )
	EndIf

	If	cEntPoder3 == 'R' .And. SF4->F4_PODER3 <> 'D'
		If	lHelp
			Help(' ',1,'TMSXFUNB24',,STR0044 + cTes,5,11)	//-- O Tes informado no parametro MV_TESDD, tem que ser de devolucao de poder de terceiros###" TES : "
		EndIf
		Return( .F. )
	EndIf

	If	SF4->F4_DUPLIC == 'S'
		If	lHelp
			Help(' ',1,'TMSXFUNB14',,STR0044 + cTes,5,11)	//-- O TES Informado no parametro MV_TESDD Nao pode estar configurado para gerar Duplicata...###" TES : "
		EndIf
		Return( .F. )
	EndIf

//-- Regra de Tributacao
ElseIf cAcao == '4'

	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(xFilial('SF4')+cTes))
		If	SF4->F4_MSBLQL == '1' .And. lHelp //TES Bloqueadas nao podem ser utilizadas.
			Help(' ',1,'TMSXFUNB46',,STR0159 + STR0044 + cTes,5,11)	//-- TES Bloqueadas não podem ser utilizadas. "
			Return( .F. )
		EndIf
	EndIf
	If	! SF4->(MsSeek(xFilial('SF4') + cTes))
		If	lHelp
			Help(' ',1,'TMSXFUNB27',,STR0044 + cTes,5,11)	//-- Tes nao encontrado (SF4)###" TES : "
		EndIf
		Return( .F. )
	EndIf

	If	SF4->F4_TIPO <> 'S'
		If	lHelp
			Help(' ',1,'TMSXFUNB37',,STR0044 + cTes,5,11)		//-- Informe um TES de saida###" TES : "
		EndIf
		Return( .F. )
	EndIf

//-- AWB
ElseIf cAcao == '5'

	cTes := GetMV('MV_TESAWB',,'')

	SF4->(DbSetOrder(1))
	If	Empty(cTes) .Or. ! SF4->(MsSeek(xFilial('SF4') + cTes))
		If	lHelp
			Help(' ',1,'TMSXFUNB35',,STR0044 + cTes,5,11)	//-- O Tes Informado no parametro MV_TESAWB nao foi encontrado (SF4)###" TES : "
		EndIf
		Return( .F. )
	EndIf

EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsIncForn³ Autor ³ Eduardo de Souza      ³ Data ³ 20/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusao do Fornecedor filtrado atraves do SXB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsIncForn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsIncForn()

Local cFiltro := SA2->(DBFilter())

DbSelectArea("SA2")
DbClearFilter()

AxInclui("SA2",0,3)

Set Filter To &(cFiltro)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAlianca³ Autor ³ Eduardo de Souza      ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se utiliza Filial Alianca                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAlianca()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAlianca()
Return( GetMv("MV_ALIANCA",.F.,.F.) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSDocAli ³ Autor ³ Eduardo de Souza      ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Ctrc eh Alianca                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSDocAli(ExpC1,ExpC2,ExpC3,ExpN1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±³          ³ ExpN1 - Tipo de Percurso                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDocAli(cFilDoc, cDoc, cSerie, nPercurso)

Local lRet     := .F.
Local aAreaDTC := DTC->(GetArea())

Default nPercurso := 0

DTC->(DbSetOrder(3))
If DTC->(MsSeek(xFilial("DTC")+cFilDoc+cDoc+cSerie))
	If !Empty(DTC->DTC_ALIANC) .And. Empty(DTC->DTC_FILDPC) .And. Empty(DTC->DTC_CTRDPC) //-- 1o. percurso
		nPercurso := 1
		lRet      := .T.
	ElseIf !Empty(DTC->DTC_FILDPC) .And. !Empty(DTC->DTC_CTRDPC) //-- 2o. percurso
		nPercurso := 2
		lRet      := .T.
	EndIf
EndIf

RestArea( aAreaDTC )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSTipViag³ Autor ³ Eduardo de Souza      ³ Data ³ 18/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a Viagem contem doctos Alianca\Normais\Ambos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSTipViag(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSTipViag( cFilOri, cViagem )

Local nTpViag  := 0
Local aAreaDUD := DUD->(GetArea())

// 1 = Somente Doctos Aliancas
// 2 = Somente Doctos Normais
// 3 = Os dois tipos

DUD->(DbSetOrder(2))
If DUD->(MsSeek(xFilial("DUD")+cFilOri+cViagem))
	While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == xFilial("DUD") + cFilOri + cViagem
		If TMSDocAli( DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
  			nTpViag := Iif(nTpViag == 1,3,2)
		Else
			nTpViag := Iif(nTpViag == 2,3,1)
		EndIf
		//-- Sai ao encontrar os dois tipos de doctos
		If nTpViag == 3
			Exit
		EndIf
		DUD->(DbSkip())
	EndDo
EndIf

RestArea( aAreaDUD )

Return( nTpViag )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsPercAli³ Autor ³ Eduardo de Souza      ³ Data ³ 18/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica qual o percurso alianca do docto / viagem         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsPercAli(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Documento                                   ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±³          ³ ExpC4 - Filial Origem                                      ³±±
±±³          ³ ExpC5 - Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsPercAli( cFilDoc, cDoc, cSerie, cFilOri, cViagem )

Local nTpPerc   := 0
Local nPercurso := 0
Local aAreaDUD  := DUD->(GetArea())

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cFilOri := ""
Default cViagem := ""


// 1 = Primeiro Percurso
// 2 = Segundo Percurso
// 3 = Ambos

If !Empty(cDoc)
	If TMSDocAli( cFilDoc, cDoc, cSerie, @nPercurso )
		nTpPerc := nPercurso
	EndIf
Else
	DUD->(DbSetOrder(2))
	If DUD->(MsSeek(xFilial("DUD")+cFilOri+cViagem))
		While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == xFilial("DUD") + cFilOri + cViagem
			If TMSDocAli( DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, @nPercurso )
				If (nTpPerc == 1 .And. nPercurso == 2) .Or. (nTpPerc == 2 .And. nPercurso == 1)
					nTpPerc := 3
				Else
					nTpPerc := nPercurso
				EndIf
			EndIf
			//-- Sai ao encontrar os dois tipos de doctos
			If nTpPerc == 3
				Exit
			EndIf
			DUD->(DbSkip())
		EndDo
	EndIf
EndIf

RestArea( aAreaDUD )

Return( nTpPerc )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsInfSinc³ Autor ³ Eduardo de Souza      ³ Data ³ 22/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa ponto de entrada p/ gerar ocorr. sincronizador     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsInfSinc(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Dados p/ geracao da ocorrencia                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsInfSinc(aDados)

Local lSinc      := TmsSinc() //-- verifica se a chamada foi efetuada pelo sincronizador
Local lBlockSinc := Existblock("SZDINFSINC")
//Estrutura adados
//[1] Arquivo
//[2] Campo
//[3] Validacao
//[4] Conteudo

// Executa P.E. para gerar ocorrencia do sincronizador
If lSinc .And. lBlockSinc
	Execblock("SZDINFSINC",.F.,.F.,aDados)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsSinc  ³ Autor ³ Eduardo de Souza      ³ Data ³ 23/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a chamada esta sendo via sincronizador         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsSinc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsSinc()

Local lRet := .F.

If Type("__cInternet") <> "U" .And. __cInternet <> Nil
	lRet := .T.
Else
	lRet := SubStr(FunName(1),1,3) == "SZD"
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAllViag³ Autor ³ Alex Egydio           ³ Data ³12.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta todas as viagens do documento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Documento                                ³±±
±±³          ³ ExpC2 = Documento                                          ³±±
±±³          ³ ExpC3 = Serie do Documento                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsAllViag(cFilDoc,cDocto,cSerie)

Local aAreaDTQ	:= DTQ->(GetArea())
Local aAreaDUD	:= DUD->(GetArea())
Local aAllViag	:= {}
Local cAliasNew	:= ''
Local cAliasDUD	:= 'DUD'
Local cAliasDTQ	:= 'DTQ'
Local cIndDUD	:= ''
Local cQuery	:= ''
Local cViagem	:= Space(Len(DUD->DUD_VIAGEM))
Local lQuery	:= .F.
Local nIndex	:= 0
//-- Controle de dimensoes de objetos
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aSize		:= {}
//-- MsDialog
Local oDlgEsp
//-- EnchoiceBar
Local aButtons	:= {}
//-- ListBox
Local cLbx		:= ''
Local oLbx
Local nCntFor	:= 0

Private cVSerTms:= ''
Private cVTipTra:= ''

DEFAULT cFilDoc := ''
DEFAULT cDocto  := ''
DEFAULT cSerie  := ''

lQuery	:= .T.
cAliasNew:= GetNextAlias()
cQuery := " SELECT DUD.DUD_FILIAL,DUD.DUD_FILORI,DUD.DUD_VIAGEM,DUD.DUD_SERTMS,DUD.DUD_TIPTRA,DUD.DUD_FILDOC,DUD.DUD_DOC,DUD.DUD_SERIE,"
cQuery += " DTQ.DTQ_FILIAL,DTQ.DTQ_FILORI,DTQ.DTQ_VIAGEM,DTQ.DTQ_DATGER,DTQ.DTQ_HORGER,DTQ.DTQ_FILDES,"
cQuery += " ' ' DTCFILDOC, ' ' DTCDOC, ' ' DTCSERIE,"
cQuery += " ' ' DTCFILORI, ' ' DTCNUMSOL, ' ' DT5FILORI, ' ' DT5NUMSOL, ' ' DT5FILDOC, ' ' DT5DOC, ' ' DT5SERIE"
cQuery += " FROM"
cQuery += " "+RetSqlName('DUD')+" DUD,"
cQuery += " "+RetSqlName('DTQ')+" DTQ"
cQuery += " WHERE"
cQuery += " DUD.D_E_L_E_T_      = ' '"
cQuery += " AND DUD.DUD_FILIAL  = '"+xFilial("DUD")+"'"
cQuery += " AND DUD.DUD_FILDOC  = '"+cFilDoc+"'"
cQuery += " AND DUD.DUD_DOC     = '"+cDocto+"'"
cQuery += " AND DUD.DUD_SERIE   = '"+cSerie+"'"
cQuery += " AND DTQ.DTQ_FILIAL  = '"+xFilial("DTQ")+"'"
cQuery += " AND DTQ.DTQ_FILORI  = DUD.DUD_FILORI"
cQuery += " AND DTQ.DTQ_VIAGEM  = DUD.DUD_VIAGEM"

cQuery += " UNION ALL "

cQuery += " SELECT DISTINCT DUD.DUD_FILIAL,DUD.DUD_FILORI,DUD.DUD_VIAGEM,DUD.DUD_SERTMS,DUD.DUD_TIPTRA,DUD.DUD_FILDOC,DUD.DUD_DOC,DUD.DUD_SERIE,"
cQuery += " DTQ.DTQ_FILIAL,DTQ.DTQ_FILORI,DTQ.DTQ_VIAGEM,DTQ.DTQ_DATGER,DTQ.DTQ_HORGER,DTQ.DTQ_FILDES,"
cQuery += " DTC.DTC_FILDOC,DTC.DTC_DOC,DTC.DTC_SERIE,"
cQuery += " DTC.DTC_FILORI,DTC.DTC_NUMSOL,DT5.DT5_FILORI,DT5.DT5_NUMSOL,DT5.DT5_FILDOC,DT5.DT5_DOC,DT5.DT5_SERIE"
cQuery += " FROM"
cQuery += " "+RetSqlName('DT5')+" DT5,"
cQuery += " "+RetSqlName('DTC')+" DTC,"
cQuery += " "+RetSqlName('DUD')+" DUD,"
cQuery += " "+RetSqlName('DTQ')+" DTQ"
cQuery += " WHERE"
cQuery += " DUD.D_E_L_E_T_      = ' '"
cQuery += " AND DTC.DTC_FILIAL  = '"+xFilial("DTC")+"'"
cQuery += " AND DTC.DTC_FILDOC  = '"+cFilDoc+"'"
cQuery += " AND DTC.DTC_DOC     = '"+cDocto+"'"
cQuery += " AND DTC.DTC_SERIE   = '"+cSerie+"'"
If Empty(xFilial("DT5"))
	cQuery += " AND DT5.DT5_FILIAL  = '"+xFilial("DT5")+"'"
Else
	cQuery += " AND DT5.DT5_FILIAL  = DTC.DTC_FILORI"
EndIf
cQuery += " AND DT5.DT5_FILORI  = DTC.DTC_FILORI"
cQuery += " AND DT5.DT5_NUMSOL  = DTC.DTC_NUMSOL"
cQuery += " AND DUD.DUD_FILIAL  = '"+xFilial("DUD")+"'"
cQuery += " AND DUD.DUD_FILDOC  = DT5.DT5_FILDOC"
cQuery += " AND DUD.DUD_DOC     = DT5.DT5_DOC"
cQuery += " AND DUD.DUD_SERIE   = DT5.DT5_SERIE"
cQuery += " AND DTQ.DTQ_FILIAL  = '"+xFilial("DTQ")+"'"
cQuery += " AND DTQ.DTQ_FILORI  = DUD.DUD_FILORI"
cQuery += " AND DTQ.DTQ_VIAGEM  = DUD.DUD_VIAGEM"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
cQuery	:= ''
cAliasDUD:= cAliasNew
cAliasDTQ:= cAliasNew
TcSetField(cAliasNew,"DTQ_DATGER","D",8,0)

//-- Carrega vetor aAllViag com todas as viagens do documento
While (cAliasDUD)->(!Eof())
	If	!lQuery
		DTQ->(DbSetOrder(2))
		DTQ->(MsSeek(xFilial('DTQ')+(cAliasDUD)->DUD_FILORI+(cAliasDUD)->DUD_VIAGEM))
	EndIf
	cVSerTms := (cAliasDUD)->DUD_SERTMS
	cVTipTra := (cAliasDUD)->DUD_TIPTRA
	AAdd(aAllViag,{(cAliasDUD)->DUD_FILORI,;
	               (cAliasDUD)->DUD_VIAGEM,;
	               TmsValField('cVSerTms',.F.),;
	               TmsValField('cVTipTra',.F.),;
	               (cAliasDTQ)->DTQ_DATGER,;
	               Transform(Val((cAliasDTQ)->DTQ_HORGER),PesqPict('DTQ','DTQ_HORGER')),;
  	               (cAliasDTQ)->DTQ_FILDES})
	(cAliasDUD)->(DbSkip())
EndDo
ASort(aAllViag,,,{|x,y| Dtos(x[5]) + x[6] < Dtos(y[5]) + y[6] })
//--
If	lQuery
	DbSelectArea(cAliasNew)
	DbCloseArea()
Else
	If	File(cIndDUD+OrdBagExt())
		Ferase(cIndDUD+OrdBagExt())
	EndIf
EndIf
RestArea(aAreaDUD)
RestArea(aAreaDTQ)

If Empty(aAllViag)
	Help(' ', 1, 'TMSXFUNA07') 	//-- Viagem nao encontrada (DTQ)
	Return( Nil )
EndIf

//-- ListBox aAllViag
//-- Calcula as dimensoes dos objetos
aSize  := MsAdvSize( .T. )

AAdd( aObjects, { 100, 60,.T.,.T. } )

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj:= MsObjSize( aInfo, aObjects,.T. )

AAdd(aButtons,	{'CARGA',{||TmsVisViag(aAllViag[oLbx:nAT,01],aAllViag[oLbx:nAT,02])}, STR0008, STR0008 }) //"Viagem"
AAdd(aButtons,	{'CARGRF',{||TmsVisCGrf(aAllViag[oLbx:nAT,01],aAllViag[oLbx:nAT,02])}, STR0153, STR0153 }) //"'Carreg.Grf'//"Carreg. Grf."

DEFINE MSDIALOG oDlgEsp TITLE STR0045 + cDocto + '/' + cSerie FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //"Viagens do Documento: "

	@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbx VAR cLbx FIELDS HEADER ;
												FwX3Titulo('DUD_FILORI') ,;
												FwX3Titulo('DUD_VIAGEM') ,;
												FwX3Titulo('DUD_SERTMS') ,;
												FwX3Titulo('DUD_TIPTRA') ,;
												FwX3Titulo('DTQ_DATGER') ,;
												FwX3Titulo('DTQ_HORGER') ,;
												FwX3Titulo('DTQ_FILDES') ;
												SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp PIXEL
	oLbx:SetArray(aAllViag)
	oLbx:bLine	:= { || {	aAllViag[oLbx:nAT,01]	,;
									aAllViag[oLbx:nAT,02]	,;
									aAllViag[oLbx:nAT,03]	,;
									aAllViag[oLbx:nAT,04]	,;
									aAllViag[oLbx:nAT,05]	,;
									aAllViag[oLbx:nAT,06]	,;
									aAllViag[oLbx:nAT,07]	} }

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()},,aButtons)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSelOri  ³ Autor ³ Patricia A. Salomao   ³ Data ³ 18/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Seleciona a Regiao de Origem.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSelOri(ExpC1, ExpC2, ExpC3, ExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1- Alias do campo que esta chamando a funcao            ³±±
±±³          ³ExpC2- Opcao Selecionada (1=Transportadora;2=Cliente Remet.)³±±
±±³          ³ExpC3- Cliente Remetente                                    ³±±
±±³          ³ExpC4- Loja Remetente                                       ³±±
±±³          ³ExpC5- Sequencia do endereco                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Campos DTC_SELORI                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSSelOri(cAlias,cOpc,cCliRem,cLojRem,cSeqEnd,cFilOri,cNumSol)

Local cCdrOri   := ''
Local cRegOri   := ''

Default cOpc    := StrZero(1,Len(DTC->DTC_SELORI))
Default cCliRem := ''
Default cLojRem := ''
Default cSeqEnd := ''
Default cFilOri := ''
Default cNumSol := ''

If !lAjustHelp
	lAjustHelp := .T. //Para indicar que a funcao AjustaHelp jah foi executada para nao executar novamente
EndIf

If cOpc == StrZero(1,Len(DTC->DTC_SELORI)) // Seleciona Regiao Origem 'Transportadora'
  if UPPER(FunName()) == 'TMSA040'
      cCdrOri := PadR(SuperGetMV('MV_CDRORI',,'',cFilOri),Len(DUY->DUY_GRPVEN))
  Else
      cCdrOri := PadR(GetMV('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN))
  EndIf
ElseIf cOpc == StrZero(2,Len(DTC->DTC_SELORI)) // Seleciona Regiao Origem 'Cliente Remetente'
	If Empty(cCliRem) .Or. Empty(cLojRem)
		Help('',1,'TMSXFUNB33') // Informe o Codigo / Loja do Cliente Remetente ...
		Return( .F. )
	EndIf
	SA1->(DbSetOrder(1))
	If !SA1->(MsSeek(xFilial("SA1")+cCliRem+cLojRem))
		Help('',1,'TMSXFUNB34') // Cliente Remetente nao Encontrado ...
		Return( .F. )
	EndIf
	cCdrOri := SA1->A1_CDRDES
	//-- Obtem a regiao destino do endereco do cliente
	If !Empty(cSeqEnd)
		cCdrOri := M_Posicione("DUL",2,xFilial("DUL")+cCliRem+cLojRem+cSeqEnd,"DUL_CDRDES")
	EndIf
ElseIf cOpc == StrZero(3,Len(DTC->DTC_SELORI)) // Local de Coleta

    //-- Valida e define a origem como sendo o Expedidor DTC_CLIEXP / DTC_LOJEXP
	If DTC->(ColumnPos("DTC_CLIEXP")) > 0
		If !Empty(M->DTC_CLIEXP)
			cCdrOri := M_Posicione("SA1",1,xFilial("SA1")+ M->DTC_CLIEXP + M->DTC_LOJEXP,"A1_CDRDES")
		EndIf
	EndIf
    //-- Considera Regiao da Coleta quando não informado o Expedidor.
    If Empty(cCdrOri)
        If Empty(cFilOri) .Or. Empty(cNumSol)
            Help('',1,'TMSXFUNB44') // Solicitacao nao Encontrada ...
            Return( .F. )
        Else
            DT5->(DbSetOrder(1))
            If DT5->(MsSeek(xFilial("DT5")+cFilOri+cNumSol))
                If !Empty(DT5->DT5_SEQEND)
                    cCdrOri := M_Posicione("DUL",3,xFilial("DUL")+DT5->DT5_CODSOL+DT5->DT5_SEQEND,"DUL_CDRDES")
                Else
                    cCdrOri := M_Posicione("DUE",1,xFilial("DUE")+DT5->DT5_CODSOL,"DUE_CDRSOL")
                EndIf
            EndIf
        EndIf
    EndIf

EndIf

If !Empty( cCdrOri )
	DUY->(DbSetOrder(1))
	If DUY->(MsSeek(xFilial("DUY")+cCdrOri))
		cRegOri := DUY->DUY_DESCRI
	EndIf
EndIf

//-- Verifica se atualiza GetDados ou Enchoice
If GDFieldPos(cAlias+"_CDRORI") > 0
	GDFieldPut( cAlias+"_CDRORI", cCdrOri, n )
Else
	M->&(cAlias+"_CDRORI") := cCdrOri
EndIf
If GDFieldPos(cAlias+"_REGORI") > 0
	GDFieldPut( cAlias+"_REGORI", cRegOri, n )
Else
	M->&(cAlias+"_REGORI") := cRegOri
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsNomFav ºAutor  ³ Eduardo de Souza   º Data ³  14/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o nome do Favorecido                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ TmsNomFav(ExpC1,ExpC2)                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Codigo Favorecido                                  º±±
±±º          ³ ExpC2 - Loja Favorecido                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sincronizador - SigaTMS                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsNomFav(cCodFav,cLojFav)

Local aAreaSA2 := SA2->(GetArea())
Local cRet     := ""

SA2->(DbSetOrder(1))
If SA2->(MsSeek(xFilial("SA2")+cCodFav+cLojFav))
	cRet := SA2->A2_NOME
EndIf

RestArea( aAreaSA2 )
DbSelectArea("SX7")

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSVldChav³ Rev.  ³Rodrigo de A Sartorio  ³ Data ³13.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de chave unica para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo a ser pesquisado                    ³±±
±±³          ³ExpC2: Campo origem da chave utilizada como pesquisa        ³±±
±±³          ³       Se for mais de um campo deve ser passado como NIL ou ³±±
±±³          ³       branco                                               ³±±
±±³          ³ExpC3: Prefixo da pesquisa para verificar duplicidade (deve ³±±
±±³          ³ ser utilizado quando o campo principal não é o primeiro    ³±±
±±³          ³ do indice utilizado para a pesquisa ).                     ³±±
±±³          ³ExpC4: Campo principal da chave (caso seja encontrada       ³±±
±±³          ³ duplicidade é esse o valor que sera incrementado).         ³±±
±±³          ³ExpC5: Complemento da pesquisa para verificar duplicidade   ³±±
±±³          ³ (deve ser utilizado quando o campo principal não é a unica ³±±
±±³          ³ informação do indice utilizado para a pesquisa ).          ³±±
±±³          ³ExpN1: Ordem de pesquisa                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cChave := Conteudo atualizado do campo principal da Chave  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVldChav(cAlias,cCampo,cPrefixo,cChave,cComplemento,nOrder)

Local aAreaAnt			:= GetArea()
Local aAreaAlias		:= {}
Local cMay				:= cAlias+Alltrim(xFilial(cAlias))

DEFAULT nOrder  		:= 1
DEFAULT cPrefixo		:= ''
DEFAULT cComplemento	:= ''

If ValType(cAlias)=='C' .And. !Empty(cAlias)
	DbSelectArea(cAlias)
	aAreaAlias:=GetArea()
	DbSetOrder(nOrder)
	While (MsSeek(xFilial(cAlias)+cPrefixo+cChave+cComplemento) .Or. !LockByName(cMay+cPrefixo+cChave+cComplemento))
		cChave:=CriaVar(cCampo)
		If __lSX8
			ConfirmSX8()
		EndIf
	EndDo
	FreeUsedCode()
	RestArea(aAreaAlias)
EndIf
RestArea(aAreaAnt)

Return( cChave )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AaddMsgErr ³ Autor ³ Patricia A. Salomao ³ Data ³10.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria Array com as Mensagens de Erro que ocorreram durante o ³±±
±±³          ³processamento.Estas Mensagens serao mostradas para o usuario³±±
±±³          ³no Final do Processamento.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AaddMsgErr(ExpA1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array contendo a Mensagem de Erro                   ³±±
±±³          ³ExpA2 - Array que contem todas as Mensagens de Erro que     ³±±
±±³          ³        serao mostradas na Tela                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AaddMsgErr( aMsgErr, aVisErr)

Local nItem   := Len(aVisErr)
Local nX, nY

Default aMsgErr := {}

If !Empty( aMsgErr )
	For nX := 1 To Len(aMsgErr)
		AAdd( aVisErr, {})
		nItem++
		For nY:=1 To Len(aMsgErr[nX])
			AAdd( aVisErr[nItem], aMsgErr[nX][nY] )
		Next
	Next
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSEmViag ³ Autor ³ Richard Anderson      ³ Data ³28.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se um veiculo, motorista ou ajudante ja estao     ³±±
±±³          ³ sendo utilizados em uma viagem                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA430Ent(ExpC1,ExpC2,ExpC3,ExpN1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  = Filial de Origem                                  ³±±
±±³          ³ ExpC2  = Numero da viagem                                  ³±±
±±³          ³ ExpC3  = Codigo do Veiculo,Motorista ou Ajudante           ³±±
±±³          ³ ExpN1  = 1 - Veiculo                                       ³±±
±±³          ³        = 2 - Motorista                                     ³±±
±±³          ³        = 3 - Ajudante                                      ³±±
±±³          ³ ExpL1  = .T. Apresenta help                                ³±±
±±³          ³ @ExpC4 = Retorna com a Filial de Origem a qual o           ³±±
±±³          ³          Veiculo/Motorista/Ajudante esta em uso            ³±±
±±³          ³ @ExpC5 = Retorna com o Numero da Viagem a qual o           ³±±
±±³          ³          Veiculo/Motorista/Ajudante esta em uso            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSEmViag(cFilOri,cViagem,cConteudo,nOpcao,lHelp,cFilUsado,cVgeUsado,cFilVge,cNumVge)
Local lContinua := .T.
Local aAreaDTQ  := DTQ->(GetArea())
Local aAreaDTR  := DTR->(GetArea())
Local aAreaDUP  := DUP->(GetArea())
Local aAreaDUQ  := DUQ->(GetArea())
Local cAliasDTQ := "DTQ"
Local cAtivChg  := SuperGetMv("MV_ATIVCHG") // Atividade de Chegada.
Local nRecno    := 0
Local cVeiGen   := GetMV('MV_VEIGEN') //Veiculo generico
Local cQuery    := ''
Local cRetQry   := ''

Default cFilOri := Space(Len(DTQ->DTQ_FILORI))
Default cViagem := Space(Len(DTQ->DTQ_VIAGEM))
Default nOpcao  := 1 //-- Veiculo
Default lHelp   := .T.
Default cFilVge := ""
Default cNumVge := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le todas as viagens com status :                                             ³
//³ 1 - Em aberto / 2 - Em transito                                              ³
//³ 4 - Chegada em Filial                                                        ³
//³ 5 - Fechada                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasDTQ := GetNextAlias()
cQuery := " SELECT R_E_C_N_O_ "
cQuery += " 	FROM " + RetSqlName("DTQ")
cQuery += " 	WHERE DTQ_FILIAL =  '" + xFilial("DTQ") + "'"
cQuery += " 		AND DTQ_FILORI = '" + cFilOri + "' "
cQuery += " 		AND DTQ_VIAGEM = '" + cViagem + "' "
cQuery += " 		AND D_E_L_E_T_ = ' '
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTQ)
nRecno := (cAliasDTQ)->R_E_C_N_O_
(cAliasDTQ)->(DbCloseArea())

cQuery := " SELECT DTQ_FILORI,DTQ_VIAGEM "
cQuery += " 	FROM " + RetSqlName("DTQ") + " DTQ "
cQuery += " 	JOIN " + RetSqlName("DTR") + " DTR "
cQuery += " 		ON DTR_FILIAL = '" + xFilial("DTR") + "' "
cQuery += " 		AND DTR_FILORI = DTQ_FILORI"
cQuery += " 		AND DTR_VIAGEM = DTQ_VIAGEM "
If !Empty(cFilOri) .And. !Empty(cViagem)
	cQuery += " 	AND DTR_FILVGE <> '" + cFilOri + "'"
	cQuery += " 	AND DTR_NUMVGE <> '" + cViagem + "'"
EndIf
cQuery += " 		AND DTR.D_E_L_E_T_ = ' ' "
If nOpcao == 1 //-- Veiculos
	cQuery += " 		AND ( DTR_CODVEI = '"+cConteudo+"' "
	cQuery += " 		   OR DTR_CODRB1 = '"+cConteudo+"' "
	cQuery += " 		   OR DTR_CODRB2 = '"+cConteudo+"' "
	cQuery += "		       OR DTR_CODRB3 = '"+cConteudo+"')"
EndIf
cQuery += " 	JOIN " + RetSqlName("DA3") + " DA3 "
cQuery += " 		ON DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " 		AND DA3_COD = DTR_CODVEI "
cQuery += " 		AND DA3.D_E_L_E_T_ = ' ' "
cQuery += " 	JOIN " + RetSqlName("DUT") + " DUT "
cQuery += " 		ON DUT_FILIAL = '" + xFilial("DUT") + "' "
cQuery += " 		AND DUT_TIPVEI = DA3_TIPVEI "
cQuery += " 		AND DUT.D_E_L_E_T_ = ' ' "
If nOpcao == 2 //-- Motoristas
	cQuery += "	JOIN " + RetSqlName("DUP") + " DUP "
	cQuery += "		ON DUP_FILIAL = '" + xFilial("DUP") + "' "
	cQuery += "		AND DUP_FILORI = DTR_FILORI "
	cQuery += "		AND DUP_VIAGEM = DTR_VIAGEM "
	cQuery += "		AND DUP_CODVEI = DTR_CODVEI "
	cQuery += "		AND DUP_CODMOT  = '"+cConteudo+"'"
	cQuery += "   	AND DUP.D_E_L_E_T_ = ' ' "
	If DUP->(ColumnPos('DUP_EMVIAG')) > 0
		cQuery += "   	AND DUP_EMVIAG <> '1' "
	EndIf
EndIf
If nOpcao == 3 //-- Ajudantes
	cQuery += "	JOIN " + RetSqlName("DUQ") + " DUQ "
	cQuery += "		ON DUQ_FILIAL = '" + xFilial("DUQ") + "' "
	cQuery += "		AND DUQ_FILORI = DTR_FILORI "
	cQuery += "		AND DUQ_VIAGEM = DTR_VIAGEM "
	cQuery += "		AND DUQ_CODVEI = DTR_CODVEI "
	cQuery += " 	AND DUQ_CODAJU  = '"+cConteudo+"'"
	cQuery += "   	AND DUQ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE DTQ_FILIAL = '" + xFilial("DTQ") + "' "
cQuery += "		AND DTQ_STATUS <> '3' AND DTQ_STATUS <> '9' "
cQuery += "		AND DTQ_TIPVIA <> '3' "
cQuery += "		AND DTQ.D_E_L_E_T_ = ' ' "
If nRecno > 0
	cQuery += "		AND DTQ.R_E_C_N_O_ <> " + AllTrim(Str(nRecno))
EndIf
cQuery += "		AND ( DTQ_SERTMS <> '2' "
cQuery += "			OR DUT_CATVEI <> '2' "
cQuery += "			OR ( "
If nOpcao == 1 //-- Veiculos
	cQuery += "				DTR_CODVEI = '"+cConteudo+"' AND "
EndIf
cQuery += " 			   DTQ_SERTMS = '2' "
cQuery += " 		 AND DTQ_FILDES <> ( "
cQuery += "				SELECT DTW_FILATI "
cQuery += " 				FROM " + RetSqlName("DTW")
cQuery += " 				WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery += " 					AND DTW_FILORI = '" + cFilOri  + "' "
cQuery += " 					AND DTW_VIAGEM = '" + cViagem  + "' "
cQuery += " 					AND DTW_ATIVID = '" + cAtivChg + "' "
cQuery += " 					AND D_E_L_E_T_ = ' ' "
cQuery += " 					AND DTW_SEQUEN = ( "
cQuery += "		 					SELECT MAX(DTW_SEQUEN) "
cQuery += " 							FROM " + RetSqlName("DTW")
cQuery += " 							WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery += " 								AND DTW_FILORI = '" + cFilOri  + "' "
cQuery += " 								AND DTW_VIAGEM = '" + cViagem  + "' "
cQuery += " 								AND DTW_ATIVID = '" + cAtivChg + "' "
cQuery += " 								AND D_E_L_E_T_ = ' ' )))) "
cQuery += "          AND NOT EXISTS ( "
cQuery += "             SELECT DF7_FILORI,DF7_VIAGEM "
cQuery += "                 FROM " + RetSQLName('DF7') + " DF7 "
cQuery += "                 WHERE DF7.DF7_FILIAL = '" + xFilial('DF7') + "' "
cQuery += "                     AND ((DF7.DF7_FILORI = DTQ_FILORI AND DF7.DF7_VIAGEM = DTQ_VIAGEM) "
cQuery += "                     OR (DF7.DF7_FILDTR = DTQ_FILORI AND DF7.DF7_VGEDTR = DTQ_VIAGEM)) "
cQuery += "                     AND DF7.D_E_L_E_T_  = ' ')

//-- Verifica se diferente da viagem interligada
If !Empty(cFilVge+cNumVge)
	cQuery += " AND DTQ_FILORI <> '" + cFilVge + "' "
	cQuery += " AND DTQ_VIAGEM <> '" + cNumVge + "' "
EndIf

If lTMSEMVGM
   cRetQry := ExecBlock("TMSEMVGM",.F.,.F.,{ cQuery } )
    cQuery := If( Valtype(cRetQry) == "C", cRetQry, cQuery )
EndIf

cQuery += "ORDER BY "+SqlOrder(DTQ->(IndexKey()))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTQ)
(cAliasDTQ)->(DbGotop())
If nOpcao <> 1 .Or. (nOpcao == 1 .And. cConteudo <> cVeiGen) //Nao validar o veiculo generico.
	If (cAliasDTQ)->(!Eof())
		lContinua := .F.
		If	lHelp .And. !lContinua
			If nOpcao == 1
				Help(" ",1,"TMSXFUNB15",, (cAliasDTQ)->DTQ_FILORI + " - " + (cAliasDTQ)->DTQ_VIAGEM, 2, 12) // O Veiculo informado esta sendo utilizado na viagem :
			ElseIf nOpcao == 2
				Help(" ",1,"TMSXFUNB16",, (cAliasDTQ)->DTQ_FILORI + " - " + (cAliasDTQ)->DTQ_VIAGEM, 2, 22) // O Motorista informado esta sendo utilizado na viagem :
			ElseIf nOpcao == 3
				Help(" ",1,"TMSXFUNB17",, (cAliasDTQ)->DTQ_FILORI + " - " + (cAliasDTQ)->DTQ_VIAGEM, 2, 22) // O Ajudante informado esta sendo utilizado na viagem :
			EndIf
		EndIf
		cFilUsado := (cAliasDTQ)->DTQ_FILORI
		cVgeUsado := (cAliasDTQ)->DTQ_VIAGEM
	EndIf
EndIf
(cAliasDTQ)-> ( dbCloseArea() )

RestArea(aAreaDTQ)
RestArea(aAreaDTR)
RestArea(aAreaDUP)
RestArea(aAreaDUQ)

Return( lContinua )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSBxEstoq³ Autor ³ Patricia A. Salomao   ³ Data ³06.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Baixa Estoque                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSBxEstoq(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Origem da Viagem                         ³±±
±±³          ³ ExpC2 - No. da Viagem                                      ³±±
±±³          ³ ExpC3 - Filial do Documento                                ³±±
±±³          ³ ExpC4 - No. do Documento                                   ³±±
±±³          ³ ExpC5 - Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSBxEstoq( cFilOri, cViagem, cFilDoc, cDocto, cSerie )

Local aCab
Local aItens
Local cIdentB6
Local cTesEnt	:= GetMV("MV_TESDR",,"") // Tes de Entrada
Local cTesSai	:= GetMV("MV_TESDD",,"") // Tes de Saida
Local cDocBxe
Local cSerBxe
Local cItem		:= Replicate("0", Len( SC6->C6_ITEM ) )
Local cSeek		:= ''
Local cSeekDUH	:= ''
Local bWhile	:= {||.F.}
Local bWhiDUH	:= {||.F.}
Local lRet		:= .F.
Local lExistDoc	:= .F.
Local cSeekDoc  := ''

DEFAULT cFilDoc	:= ""
DEFAULT cDocto	:= ""
DEFAULT cSerie	:= ""

DTQ->(DbSetOrder(2))
DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem))
If !DTQ->DTQ_SERTMS $ "2;3" // Transporte;Entrega
	Return( .T. )
EndIf

//-- Nao realiza a Baixa do Estoque, se o Tes de Entrada estiver configurado para NAO Atualizar Estoque
SF4->( DbSetOrder( 1 ) )
If	SF4->(MsSeek(xFilial('SF4') + cTesEnt, .F.)) .And. SF4->F4_ESTOQUE == "N"
	Return( .T. )
EndIf
//-- Verifica a configuracao do TES
If	! TmsChkTES('3')
	Return( .F. )
EndIf

DT6->( DbSetOrder( 1 ) )
DTC->( DbSetOrder( 3 ) )
SA1->( DbSetOrder( 1 ) )
AAM->( DbSetOrder( 1 ) )
DUI->( DbSetOrder( 1 ) )

If Empty( cFilDoc )
	DUD->( DbSetOrder( 2 ) )
	DUD->( MsSeek( cSeek := xFilial('DUD') + cFilOri + cViagem ) )
	bWhile := { || DUD->( !Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeek ) }
Else
	DUD->( DbSetOrder( 1 ) )
	DUD->( MsSeek( cSeek := xFilial('DUD') + cFilDoc + cDocto + cSerie + cFilOri + cViagem ) )
	bWhile := { || DUD->( !Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM == cSeek ) }
EndIf

While Eval( bWhile )

	// Baixa estoque somente dos documentos carregados (DUD_STATUS == 3).
	If DUD->DUD_STATUS != StrZero(3, Len(DUD->DUD_STATUS))
		DUD->( DbSkip() )
		Loop
	EndIf

	DT6->( MsSeek( xFilial("DT6") + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )

	If DT6->DT6_BLQDOC == "1" // Bloqueio de Docto
		DUD->( DbSkip() )
		Loop
	EndIf

	//-- Verifica se existe nota fiscal para o documento
	cSeekDoc:= ""
	If !Empty(DT6->DT6_DOCDCO) .And. DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) //Devolucao
		If DTC->( MsSeek( xFilial("DTC") + DT6->( DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO ) ) )
			cSeekDoc  := xFilial("DT6") + DT6->( DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO )
			lExistDoc := .T.
		EndIf
	Else
		If DTC->( MsSeek( xFilial("DTC") + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )
			cSeekDoc  := xFilial("DUD") + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE )
			lExistDoc := .T.
		EndIf
	EndIf


	SA1->( MsSeek( xFilial("SA1") + DTC->( DTC_CLIDEV + DTC_LOJDEV ) ) )

	AAM->( MsSeek( xFilial("AAM") + DT6->DT6_NCONTR ) )

	If DUI->( !MsSeek( xFilial("DUI") + StrZero(4,Len( DC5->DC5_DOCTMS )) ) )
		Help("", 1, "TMSXFUNB13" ) //Nao Existe série cadastrada para o documento 4
		Return( .F. )
	EndIf

	cSerBxe := DUI->DUI_SERIE

	aCab   := {}
	aItens := {}

	AAdd( aCab, { 'C5_CLIENTE'		, SA1->A1_COD		, Nil } )
	AAdd( aCab, { 'C5_LOJAENT'		, SA1->A1_LOJA		, Nil } )
	AAdd( aCab, { 'C5_LOJACLI'		, SA1->A1_LOJA		, Nil } )
	AAdd( aCab, { 'C5_TIPOCLI'		, SA1->A1_TIPO		, Nil } )
	AAdd( aCab, { 'C5_EMISSAO'		, dDataBase     	, Nil } )
	AAdd( aCab, { 'C5_TIPO'			, 'N'					, Nil } )
	AAdd( aCab, { 'C5_TABELA'		, '1'					, Nil } )
	AAdd( aCab, { 'C5_DESC1'		, 0					, Nil } )
	AAdd( aCab, { 'C5_DESC2'		, 0					, Nil } )
	AAdd( aCab, { 'C5_DESC3'		, 0					, Nil } )
	AAdd( aCab, { 'C5_DESC4'		, 0					, Nil } )
	AAdd( aCab, { 'C5_TPCARGA'		, '1'					, Nil } )
	AAdd( aCab, { 'C5_CONDPAG'		, AAM->AAM_CPAGPV	, Nil } )
	AAdd( aCab, { 'C5_VOLUME1'		, 0					, Nil } )
	AAdd( aCab, { 'C5_PESOL'		, 0					, Nil } )
	AAdd( aCab, { 'C5_PBRUTO'		, 0					, Nil } )

	SB1->( DbSetOrder( 1 ) )
	SD1->( DbSetOrder( 1 ) )

	While DTC->( !Eof() .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeekDoc )

		If Empty(DTC->DTC_QTDVOL)
		   DTC->(dbSkip())
		   Loop
		EndIf

		If SB1->( !MsSeek( xFilial("SB1") + DTC->DTC_CODPRO ) )
			Final(STR0049, DTC->DTC_CODPRO) // Se ocorrer erro, executa transacao estornando todos os movimentos efetuados //"Erro ao Localizar o Produto (SB1) :"
		EndIf

		If SD1->( !MsSeek( xFilial("SD1") + DTC->(DTC_NUMNFC + DTC_SERNFC + DTC_CLIREM + DTC_LOJREM + DTC_CODPRO) ) )
			Final(STR0050,DTC->(DTC_NUMNFC+"/"+DTC_SERNFC)) // Se ocorrer erro, executa transacao estornando todos os movimentos efetuados //Erro ao Localizar Nota Fiscal de Entrada (SD1) :
		EndIf

		cSeekDUH := xFilial('DUH') + DTC->DTC_FILORI+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CODPRO
		bWhiDUH := {|| DUH->(! Eof() .And. DUH->DUH_FILIAL+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM+DUH->DUH_CODPRO == cSeekDUH) }

		cIdentB6 := SD1->D1_IDENTB6

		DUH->(DbSetOrder( 1 ))
		If DUH->(MsSeek( cSeekDUH ))
			While Eval(bWhiDUH)
				aLinha	:= {}
				cItem	:= SomaIt( cItem )
				AAdd( aLinha, { 'C6_ITEM'		, cItem									   , Nil	} )		// Item
				AAdd( aLinha, { 'C6_PRODUTO'	, SB1->B1_COD							   , Nil	} )		// Material
				AAdd( aLinha, { 'C6_UM'			, SB1->B1_UM							   , Nil	} )		// Unidade de medida
				AAdd( aLinha, { 'C6_SEGUM'		, SB1->B1_SEGUM							, Nil	} )		// Segunda unidade de medida
				AAdd( aLinha, { 'C6_DESCRI' 	, SB1->B1_DESC							   , Nil	} )		// Descricao do material
				AAdd( aLinha, { 'C6_VALOR'		, DTC->DTC_VALOR        	  			, Nil	} )		// Valor total do item
				AAdd( aLinha, { 'C6_ENTREG'	, dDataBase								   , Nil	} )		// Data da entrega
				AAdd( aLinha, { 'C6_QTDVEN'	, DUH->DUH_QTDVOL            			, Nil	} )		// Quantidade
				AAdd( aLinha, { 'C6_PRCVEN'	, DTC->DTC_VALOR / DUH->DUH_QTDVOL , Nil	} )		// Preco unitario
				AAdd( aLinha, { 'C6_QTDLIB'	, DUH->DUH_QTDVOL            			, Nil	} )		// Quantidade liberada
				AAdd( aLinha, { 'C6_TES'		, cTesSai								   , Nil	} )		// TES
				AAdd( aLinha, { 'C6_NFORI'		, DTC->DTC_NUMNFC            			, Nil	} )		// N.F.Original
				AAdd( aLinha, { 'C6_SERIORI'	, DTC->DTC_SERNFC            			, Nil	} )		// Serie da N.F.Original
				AAdd( aLinha, { 'C6_IDENTB6'	, cIdentB6			           			, Nil	} )		// Identificador SB6
				AAdd( aLinha, { 'C6_LOCAL'		, DUH->DUH_LOCAL             			, Nil } )     	// Armazem padrao
				AAdd( aLinha, { 'C6_LOCALIZ'	, DUH->DUH_LOCALI            			, Nil	} )		// Endereco
				AAdd( aItens , AClone( aLinha ) )
				DUH->( DbSkip() )
			EndDo
		Else
			aLinha	:= {}
			cItem	:= SomaIt( cItem )
			AAdd( aLinha, { 'C6_ITEM'		, cItem								     , Nil	} )  // Item
			AAdd( aLinha, { 'C6_PRODUTO'	, SB1->B1_COD						     , Nil	} )  // Material
			AAdd( aLinha, { 'C6_UM'			, SB1->B1_UM						     , Nil	} )  // Unidade de medida
			AAdd( aLinha, { 'C6_SEGUM'		, SB1->B1_SEGUM	 					  , Nil	} )  // Segunda unidade de medida
			AAdd( aLinha, { 'C6_DESCRI'	, SB1->B1_DESC						     , Nil	} )  // Descricao do material
			AAdd( aLinha, { 'C6_VALOR'		, DTC->DTC_VALOR                   , Nil	} )  // Valor total do item
			AAdd( aLinha, { 'C6_ENTREG'	, dDataBase							     , Nil	} )  // Data da entrega
			AAdd( aLinha, { 'C6_QTDVEN'	, DTC->DTC_QTDVOL           	     , Nil	} )  // Quantidade
			AAdd( aLinha, { 'C6_PRCVEN'	, DTC->DTC_VALOR / DTC->DTC_QTDVOL, Nil	} )  // Preco unitario
			AAdd( aLinha, { 'C6_QTDLIB'	, DTC->DTC_QTDVOL                  , Nil	} )  // Quantidade liberada
			AAdd( aLinha, { 'C6_TES'		, cTesSai 							     , Nil	} )  // TES
			AAdd( aLinha, { 'C6_NFORI'		, DTC->DTC_NUMNFC           	     , Nil	} )  // N.F.Original
			AAdd( aLinha, { 'C6_SERIORI'	, DTC->DTC_SERNFC           	     , Nil	} )  // Serie da N.F.Original
			AAdd( aLinha, { 'C6_LOCAL'		, RetFldProd(SB1->B1_COD,"B1_LOCPAD"), Nil  } )  // Armazem padrao
			AAdd( aLinha, { 'C6_IDENTB6'	, cIdentB6			                 , Nil	} )  // Identificador SB6
			AAdd( aItens , AClone( aLinha ) )
		EndIf

		DTC->( DbSkip() )

	EndDo

	If Len( aItens ) > 0
		// Gera pedido de venda e documento de saida para baixar estoque através do manifesto
		TMSPedido( aCab, aItens, 3, , { | cNumPed | cDocBxe := TMSGeraNFS( cNumPed, cSerBxe, SA1->A1_COD, SA1->A1_LOJA ) }, .F. )

		If Empty(cDocBxe)
			Help("",1,"TMSXFUNB07") // Problemas na baixa de estoque...
			lRet := .F.
			Exit
		Else
			RecLock("DUD",.F.)
			DUD->DUD_DOCBXE := cDocBxe
			DUD->DUD_SERBXE := cSerBxe
			DUD->DUD_FILFEC := cFilAnt
			MsUnLock()
			lRet := .T.
		EndIf

	EndIf

	DUD->( DbSkip() )

EndDo

// Caso não tenha tido nenhum documento para baixar estoque, retorna verdadeiro para atualizar viagem para
// Em Transito
If !lRet .And. !lExistDoc
	lRet := .T.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsVisTabel³ Autor ³ Alex Egydio          ³ Data ³14.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta uma lista com as tabelas utilizadas para calcular³±±
±±³          ³ cada componente de frete                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do documento                                ³±±
±±³          ³ ExpC2 = Documento                                          ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Determina o tipo do documento                      ³±±
±±³          ³ ExpC5 = Produto                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsVisTabel(cFilDoc,cDocto,cSerie,cDocTMS,cCodPro,cCodCia,cLojCia,cDigAwb)

Local bWhile	:= {||.F.}
Local cSeek		:= ''
Local cDscTab	:= ''
Local cTabFre	:= ''
Local cTipTab	:= ''
Local cSeqTab	:= ''
Local cCdrOri	:= ''
Local cCdrDes	:= ''
Local cServic  := ''
Local cCodCli  := ''
Local cLojCli  := ''
Local nItem		:= 0
Local nPos     := 0
Local nCnt     := 0
Local aFretAux := {}
Local aField   := {}
//-- Dialog
Local aBtnTabel:= {}
Local oDlgEsp
Local aAreaSIX   := SIX->(GetArea())

Local cCodNeg := ''

Default cFilDoc := ''
Default cDocto  := ''
Default cSerie  := ''
Default cCodPro := ''
Default cDocTMS := ''
Default cCodCia := ''
Default cLojCia := ''
Default cDigAwb := ''

SaveInter()

//-- GetDados
Private aHeader:= {}
Private aCols	:= {}
Private oGetD

AAdd(aBtnTabel,{'DESTINOS',{|| cCdrOri := GDFieldGet('DT4_CDRORI',n), cCdrDes := GDFieldGet('DT4_CDRDES',n), TmsVisTbFre(cTabFre,cTipTab,cSeqTab,cCdrOri,cCdrDes,cServic,cCodPro,cCodCli,cLojCli,cCodNeg)},STR0011 , STR0012 } ) //"Mais Detalhes"

//-- Preenche aHeader
AEval(ApBuildHeader("DT3"), {|DT3Field| AAdd(aField, DT3Field) })

AEval(ApBuildHeader("DT4"), {|DT4Field| AAdd(aField, DT4Field) })

For nCnt := 1 to Len(aField)
    cCampo := AllTrim(aField[nCnt][2])
    If cCampo $ 'DT3_DESCRI.DT4_CDRORI.DT4_REGORI.DT4_CDRDES.DT4_REGDES'
        AAdd( aHeader, aField[nCnt])
    EndIf
Next

//-- Cotacao de Frete ou Solicitação de Coleta
If	cDocTMS == '1'

	If cSerie <> 'COL'
       DT4->(DbSetOrder(1))
	   DT4->(MsSeek(xFilial('DT4') + cFilDoc + cDocto))
	   cTabFre := M->DT4_TABFRE
	   cTipTab := M->DT4_TIPTAB
	   cSeqTab := M->DT4_SEQTAB
	   cServic := M->DT4_SERVIC
	   cCodNeg:= M->DT4_CODNEG
	   
	   //-- Define quem sera o devedor do Frete na Cotacao
	   TMSA040Cli(@cCodCli, @cLojCli)
	   DT8->(DbSetOrder(1))
	   DT8->(MsSeek( cSeek := xFilial('DT8') + cFilDoc + cDocto + cCodPro ))
	   bWhile := {|| DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILORI + DT8->DT8_NUMCOT + DT8->DT8_CODPRO == cSeek }

    Else //- Se não achou cotação assume solicitação de coleta...
	   DT6->(DbSetOrder(1))
	   DT6->(MsSeek(xFilial('DT6') + cFilDoc + cDocto + cSerie))
	   cTabFre := DT6->DT6_TABFRE
	   cTipTab := DT6->DT6_TIPTAB
	   cSeqTab := DT6->DT6_SEQTAB
	   cServic := DT6->DT6_SERVIC
	   cCodCli := DT6->DT6_CLICAL
	   cLojCli := DT6->DT6_LOJCAL
	   cCodNeg:= M->DT6_CODNEG
	   
	   DT8->(DbSetOrder(2))
	   DT8->(MsSeek( cSeek := xFilial('DT8') + cFilDoc + cDocto + cSerie ))
       bWhile := {|| DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILDOC + DT8->DT8_DOC + DT8->DT8_SERIE == cSeek }

    Endif

//-- CTRC
ElseIf cDocTMS == '2'
	DTC->(DbSetOrder(3))
	DTC->(MsSeek(xFilial('DTC') + cFilDoc + cDocto + cSerie))
	DT6->(DbSetOrder(1))
	DT6->(MsSeek(xFilial('DT6') + cFilDoc + cDocto + cSerie))
	cTabFre := DT6->DT6_TABFRE
	cTipTab := DT6->DT6_TIPTAB
	cSeqTab := DT6->DT6_SEQTAB
	cCodPro := DTC->DTC_CODPRO
	cServic := DTC->DTC_SERVIC
	cCodCli := DTC->DTC_CLICAL
	cLojCli := DTC->DTC_LOJCAL
	cCodNeg:= DTC->DTC_CODNEG
	
	DT8->(DbSetOrder(2))
	If !DT8->(MsSeek( cSeek := xFilial('DT8') + cFilDoc + cDocto + cSerie + cCodPro ))
		DT8->(MsSeek( cSeek := xFilial('DT8') + cFilDoc + cDocto + cSerie + Space(Len(DTC->DTC_CODPRO)) ))
	EndIf
	bWhile := {|| DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILDOC + DT8->DT8_DOC + DT8->DT8_SERIE + DT8->DT8_CODPRO == cSeek }
//-- AWB
ElseIf cDocTMS == '3'
	DTV->(DbSetOrder(1))
	DTV->(MsSeek(xFilial('DTV') + cDocto + cDigAwb + cCodCia + cLojCia))
	cTabFre := DTV->DTV_TABFRE
	cTipTab := DTV->DTV_TIPTAB
	cSeqTab := '00'
	cCodPro := DTV->DTV_CODPRO

	If SIX->(MsSeek("DT85"))
		DT8->(DbSetOrder(5))
		If !DT8->(MsSeek( cSeek := xFilial('DT8') + cDocto + cCodCia + cLojCia + cCodPro ))
			DT8->(MsSeek( cSeek := xFilial('DT8') + cDocto + cCodCia + cLojCia + Space(Len(DTV->DTV_CODPRO)) ))
		EndIf
		bWhile := {|| DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_NUMAWB + DT8->DT8_CODCIA + DT8->DT8_LOJCIA + DT8->DT8_CODPRO == cSeek }
		If !DT8->(MsSeek( cSeek := xFilial('DT8') + cDocto + cDigAwb + cCodCia + cLojCia + cCodPro ))
			DT8->(MsSeek( cSeek := xFilial('DT8') + cDocto + cDigAwb + cCodCia + cLojCia + Space(Len(DTV->DTV_CODPRO)) ))
		EndIf
		bWhile := {|| DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_NUMAWB + DT8->DT8_DIGAWB + DT8->DT8_CODCIA + DT8->DT8_LOJCIA + DT8->DT8_CODPRO == cSeek }
	Else
		DT8->(DbSetOrder(3))
		DT8->(MsSeek( cSeek := xFilial('DT8') + cDocto + cCodCia + cLojCia ))
		bWhile := {|| DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_NUMAWB + DT8->DT8_CODCIA + DT8->DT8_LOJCIA == cSeek }
		DT8->(MsSeek( cSeek := xFilial('DT8') + cDocto + cDigAwb + cCodCia + cLojCia ))
		bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_NUMAWB + DT8->DT8_DIGAWB + DT8->DT8_CODCIA + DT8->DT8_LOJCIA == cSeek ) }
	EndIf
   RestArea(aAreaSIX)
EndIf

//-- Preenche aCols
If Inclui
	If ( nPos := Ascan(aFrete, { |x| x[1] == cCodPro })) > 0
		aFretAux := AClone(aFrete[nPos,2])
	EndIf

	For nCnt := 1 To Len(aFretAux)
		If aFretAux[nCnt,3] != 'TF'
			AAdd( aCols, Array( Len( aHeader ) + 1 ) )
			nItem := Len(aCols)
			GDFieldPut('DT3_DESCRI',M_Posicione('DT3',1,xFilial('DT3') + aFretAux[nCnt,3],'DT3_DESCRI'), nItem )
			GDFieldPut('DT4_CDRORI',aFretAux[nCnt,7], nItem )
			GDFieldPut('DT4_REGORI',M_Posicione('DUY',1,xFilial('DUY') + aFretAux[nCnt,7],'DUY_DESCRI'), nItem )
			GDFieldPut('DT4_CDRDES',aFretAux[nCnt,8], nItem )
			GDFieldPut('DT4_REGDES',M_Posicione('DUY',1,xFilial('DUY') + aFretAux[nCnt,8],'DUY_DESCRI'), nItem )
			aCols[ nItem, Len( aHeader ) + 1 ] := .F.
		EndIf
	Next nCnt

Else
	While Eval(bWhile)
		If	( DT8->DT8_CODPAS != 'TF' )
			AAdd( aCols, Array( Len( aHeader ) + 1 ) )
			nItem := Len(aCols)
			GDFieldPut('DT3_DESCRI',M_Posicione('DT3',1,xFilial('DT3') + DT8->DT8_CODPAS,'DT3_DESCRI'), nItem )
			GDFieldPut('DT4_CDRORI',DT8->DT8_CDRORI, nItem )
			GDFieldPut('DT4_REGORI',M_Posicione('DUY',1,xFilial('DUY') + DT8->DT8_CDRORI,'DUY_DESCRI'), nItem )
			GDFieldPut('DT4_CDRDES',DT8->DT8_CDRDES, nItem )
			GDFieldPut('DT4_REGDES',M_Posicione('DUY',1,xFilial('DUY') + DT8->DT8_CDRDES,'DUY_DESCRI'), nItem )
			aCols[ nItem, Len( aHeader ) + 1 ] := .F.
		EndIf
		DT8->(DbSkip())
	EndDo
EndIf

cDscTab := cTabFre + ' - ' + cTipTab + ' ' + Tabela('M5',cTipTab,.F.) + ' - ' + cSeqTab + Iif(Empty(cCodPro),'','   ' + STR0051 + AllTrim(cCodPro) + ' - ' + AllTrim(Posicione('SB1',1,xFilial('SB1')+cCodPro,'B1_DESC'))) //"Produto: "

If Empty(aCols) .Or. Empty(GDFieldGet('DT3_DESCRI',1))
	Help('',1,'REGNOIS')
Else
	DEFINE MSDIALOG oDlgEsp TITLE STR0052 + cDscTab FROM 9,0 TO 27.5,80 OF oMainWnd //"Tabela de frete: "

		oGetD := MSGetDados():New(32,3,138,314,2,'AllwaysTrue()','AllwaysTrue()')

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()},, aBtnTabel ) CENTERED
EndIf

RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCalFret³ Autor ³ Alex Egydio           ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o total do frete baseado na tabela de frete.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSCalFret()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da tabela de frete                          ³±±
±±³          ³ ExpC2 = Tipo da tabela de frete                            ³±±
±±³          ³ ExpC3 = Sequencia da tabela de frete                       ³±±
±±³          ³ ExpC4 = Regiao origem                                      ³±±
±±³          ³ ExpC5 = Regiao destino                                     ³±±
±±³          ³ ExpC6 = Codigo do cliente                                  ³±±
±±³          ³ ExpC7 = Loja do cliente                                    ³±±
±±³          ³ ExpC8 = Produto                                            ³±±
±±³          ³ ExpC9 = Servico                                            ³±±
±±³          ³ ExpCA = Tipo de servico                                    ³±±
±±³          ³ ExpCB = Tipo de transporte                                 ³±±
±±³          ³ ExpCC = Numero do contrato                                 ³±±
±±³          ³ ExpA1 = Vetor indicando onde ocorreu erros no calculo      ³±±
±±³          ³ ExpA2 = Vetor com as notas fiscais por conhecimento        ³±±
±±³          ³ ExpN1 = Valor da Mercadoria                                ³±±
±±³          ³ ExpN2 = Peso Real                                          ³±±
±±³          ³ ExpN2 = Peso Cubado                                        ³±±
±±³          ³ ExpN2 = Peso Cobrado                                       ³±±
±±³          ³ ExpN3 = Volume                                             ³±±
±±³          ³ ExpN4 = Desconto                                           ³±±
±±³          ³ ExpN5 = Seguro                                             ³±±
±±³          ³ ExpN6 = Metro cubico                                       ³±±
±±³          ³ ExpN7 = Qtde de documentos (frete a pagar)                 ³±±
±±³          ³ ExpN8 = Diarias Semana     (frete a pagar)                 ³±±
±±³          ³ ExpN9 = Km                 (frete a pagar)                 ³±±
±±³          ³ ExpNA = Pernoite           (frete a pagar)                 ³±±
±±³          ³ ExpL1 = .T. Estabelece o valor minimo do componente        ³±±
±±³          ³ ExpL2 = .T. Indica que o contrato eh de um cliente generico³±±
±±³          ³ ExpL3 = .T. Ajuste automatico, envia msg se nao encontrar  ³±±
±±³          ³ ExpNB = Qtde. de Entregas  (frete a pagar)                 ³±±
±±³          ³ ExpNC = Quantidade de unitizadores         (811)           ³±±
±±³          ³ ExpND = Valor do frete do despachante      (811)           ³±±
±±³          ³ ExpNE = Docto sem imposto  (frete a pagar) (811)           ³±±
±±³          ³ ExpNF = Docto com imposto  (frete a pagar) (811)           ³±±
±±³          ³ ExpA3 = Valores informados                                 ³±±
±±³          ³ ExpA4 = Tipo do Veiculo    (811)                           ³±±
±±³          ³ ExpCD = Documento de transporte (Devolucao doctms)         ³±±
±±³          ³ ExpNF = Diarias Fim de Semana (frete a pagar)              ³±±
±±³          ³ ExpA5 = Altura / Largura / Comprimento (811)               ³±±
±±³          ³ nSeqDoc = Sequencia/Ordem de Calculo do Documento          ³±±
±±³          ³ lRateio = Indica se o Calculo vem de Lote com Rateio       ³±±
±±³          ³ aBaseRat = Base de Rateio                                  ³±±
±±³          ³ aCompCalc= Componentes para Calculo                        ³±±
±±³          ³ cCodNeg  = Codigo da Negociação                            ³±±
±±³          ³ aTaxDev  = Taxa de Devedor por Cliente                     ³±±
±±³          ³ aFreteCol= Array das Coletas com componente de Herda Valor ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Vetor com total do frete e impostos. Consulte o vetor aRet ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSCalFret( cTabFre,cTipTab,cSeqTab,cCdrOri,cCdrDes,cCodCli,cLojCli,cCodPro,cServic,cSerTms,cTipTra,cNContr,;
aMsgErr,aNfCTRC,nValMer,nPeso,nPesoM3,nPesoCob,nQtdVol,nDesconto,nSeguro,nMetro3,nQtdDco,nDiaSem,nKm,nPerNoi,lMinimo,;
lCliGen,lAjuAut,nQtdEnt,nQtdUni,nValDpc,nDocSImp,nDocCImp,aValInf,aTipVei,cDocTms,nDiaFimSem,nPesoVge,nPesoM3Vge,;
nMetro3Vge,nValMerVge,nQtdVolVge,nDiaArm,aFaixaTab,cLotNfc,aPesCub,lPrcPdg,cCliDev,cLojDev,nMoeda, cExcTDA, cDEVTDA,;
cRemTDA, cDesTDA, nQtdCol, cCliDes, cLojDes,cSeqDes, nSeqDoc, lRateio, aBaseRat, aCompCalc, cCodNeg, aTaxDev, aFreteCol,;
lCbrCol, lBlqCol, lInvOri)


Static aDT3Calc   := {}
Static cPesCob    := SuperGetMV('MV_PESCOB',,Space(Len(DT3->DT3_CODPAS)))
Static lTMSPVOC   := SuperGetMV('MV_TMSPVOC',,.F.)

Local aAreaAnt  := GetArea()
Local aAreaDYA  := DYA->(GetArea())
Local aRegiao   := {}
Local aRet      := {}
Local aInfoAnt  := {}
Local aTmCalFr  := {}	//-- Retorno do ponto de entrada TMCALFRE

Local cTabTar   := ''

Local lMsgErr    := .F.
Local lPesoReal  := .T.

Local nBaseCal   := 0	//-- Base para calculo do frete
Local nBaseSobre := 0
Local nCntFor    := 0
Local n1Cnt      := 0
Local nPos       := 0
Local nLenTpFai  := Len( DT3->DT3_TIPFAI )
Local nSeek      := 0
Local nVlrComp   := 0	//-- Valor do componente
Local nPesComp   := 0	//-- Componente de frete que determina o peso cobrado
Local nPerCob    := 0	//-- Percentual de cobranca definido na configuracao de componentes
Local nValMin    := 0	//-- Estabelece o valor minimo do componente
Local nValMax    := 9999999999.99
Local lExistAju  := .F.	//-- Verifica se Existe Ajuste para o componente
Local lPsqTab    := .F.	//-- lPsqTab := .T. -> Se nao encontrar componente no ajuste, pequisa o componente na Tabela de Frete (Mae)
Local cRgOTab    := Space(Len(DVD->DVD_RGOTAB))
Local cRgDTab    := Space(Len(DVD->DVD_RGDTAB))
Local cPrdTab    := Space(Len(DVD->DVD_PRDTAB))
Local nPesoCal   := 0
Local nQtdTipVei := 0
Local cCdrAux    := ''
Local nVlrBase   := 0
Local nVlrSobre  := 0
Local cMsg       := ""
Local cOriAux    := ""
Local cDesAux    := ""
Local nBaseCalFx2:= 0
Local nVlrBaseFx2:= 0
Local cFaixa2    :=""
Local nPesoOld   := 0
Local nPesoM3Old := 0
Local nMetro3Old := 0
Local nValMerOld := 0
Local nQtdVolOld := 0
Local lAltInfo   := .F.
Local lExistCmp  := .F. //-- Verifica se o componente esta configurado na tabela.
Local aTmAltBs   := {}
Local nQtdTDA    := 1
Local cSeekTab   :=""
Local cSeekTar   :=""
Local cSeekAju   :=""
Local cBsComp    := ""	//-- Alteracao da base de calculo
Local nValMerAux := nValMer
Local nPesoAux   := nPeso
Local nPesoM3Aux := nPesoM3
Local nQtdVolAux := nQtdVol
Local nSeguroAux := nSeguro
Local nMetro3Aux := nMetro3
Local nQtdUniAux := nQtdUni
Local nValDpcAux := nValDpc
Local nKmAux     := nKm
Local nMoedaTb   := 1
Local cQuery     := ""
Local cAliasQry  := ""
Local aCpDT9     := {}
Local cQueryDT9  := ""
Local nPosDT9    := 0
Local nRecDT3, nRecDT9
Local cAliasDTL  := ""
Local cCliGen    := SuperGetMv('MV_CLIGEN',,.F.)
Local cLojGen    := ""
Local lOk        := .F.
Local aRetD      := {}
Local nMinDYA	 := 0
Local nADIDOC    := 0
Local lCmpRat    := .F. // Indica se o Componente Rateia
Local cCompCalc  := ""
Local lCamposRat  := AliasIndic('DDA') .And. DDA->(ColumnPos("DDA_TIPTAB")) > 0
Local aCodCli    := {}
Local lSobSrv    := .T.
Local nPosx      := 0
Local lTaxDev    := .F.
Local lCmpHerda  := .F.
Local cDT3_TAXA  := ""
Local cDT3_PSQTXA := ""
Local lTabHerda  := .F.	// Verifica se existe tabela com Origem e Destino para o componente de herda valor.
Local lMVCompDes := SuperGetMv("MV_COMPDES",.F.,.F.) //Quando for .T., indica que o cálculo do componente de frete será baseado em função do cliente destinatário.

Local cRecDT1 := ""
Local cRecDTG := ""

If Type("lCmpDiaria") = "U"
	Private lCmpDiaria:= .F.
EndIf

DEFAULT cTabFre   := Space(Len(DT0->DT0_TABFRE))
DEFAULT cTipTab   := Space(Len(DT0->DT0_TIPTAB))
DEFAULT cSeqTab   := StrZero(0,Len(DVC->DVC_SEQTAB))
DEFAULT cCdrOri   := Space(Len(DUY->DUY_GRPVEN))
DEFAULT cCdrDes   := Space(Len(DUY->DUY_GRPVEN))
DEFAULT cCodCli   := Space(Len(SA1->A1_COD))
DEFAULT cLojCli   := Space(Len(SA1->A1_LOJA))
DEFAULT cCodPro   := Space(Len(SB1->B1_COD))
DEFAULT cServic   := Space(Len(DC5->DC5_SERVIC))
DEFAULT cSerTms   := Space(Len(DC5->DC5_SERTMS))
DEFAULT cTipTra   := Space(Len(DC5->DC5_TIPTRA))
DEFAULT cNContr   := Space(Len(AAM->AAM_CONTRT))
DEFAULT aMsgErr   := {}
DEFAULT aNfCTRC   := {}
DEFAULT nValMer   := 0
DEFAULT nPeso     := 0
DEFAULT nPesoM3   := 0
DEFAULT nPesoCob  := 0
DEFAULT nQtdVol   := 0
DEFAULT nDesconto := 0
DEFAULT nSeguro   := 0
DEFAULT nMetro3   := 0
DEFAULT nQtdDco   := 0
DEFAULT nDiaSem   := 0
DEFAULT nDiaFimSem:= 0
DEFAULT nKm       := 0
DEFAULT nPerNoi   := 0
DEFAULT nQtdEnt   := 0
DEFAULT nQtdUni   := 0
DEFAULT nValDpc   := 0
DEFAULT nDocSImp  := 0
DEFAULT nDocCImp  := 0
DEFAULT aTipVei   := {}
DEFAULT cDocTms   := ''
DEFAULT aPesCub   := {}
DEFAULT cCliDev   := cCodCli
DEFAULT cLojDev   := cLojCli
DEFAULT cExcTDA   := ""
DEFAULT cDEVTDA   := ""
DEFAULT cRemTDA   := ""
DEFAULT cDesTDA   := ""
DEFAULT nQtdCol   := 0
DEFAULT cCliDes   := ""
DEFAULT cLojDes   := ""
DEFAULT cSeqDes   := ""
//-- lMinimo eh um parametro que possibilita efetuar testes na rotina de calculo.
//-- Se .T. sempre sera estabelecido os valores minimos dos componentes.
//-- Se .F. os valores minimos nao serao estabelecidos, isto permite saber se os componentes nao foram calculados por
//-- alguma falha.
DEFAULT lMinimo:= .T.
//-- Quando o contrato pertencer a um cliente generico, utilizar a tabela cheia para o calculo.
DEFAULT lCliGen    := .F.
DEFAULT lAjuAut    := .F.
DEFAULT aValInf    := {}
DEFAULT nPesoVge   := 0
DEFAULT nPesoM3Vge := 0
DEFAULT nMetro3Vge := 0
DEFAULT nValMerVge := 0
DEFAULT nQtdVolVge := 0
DEFAULT nDiaArm    := 0
DEFAULT aFaixaTab  := {}
DEFAULT cLotNfc    := ""
DEFAULT lPrcPdg    := .T.
DEFAULT nMoeda     := 1
Default nSeqDoc    := 0
Default lRateio    := .F.
Default aBaseRat   := {}
Default aCompCalc  := {}
DEFAULT cCodNeg   :=  ""
DEFAULT aTaxDev    := {}
DEFAULT aFreteCol  := {}
DEFAULT lCbrCol    := .T.
DEFAULT lBlqCol    := .F.
DEFAULT lInvOri    := .F.

// Para os casos em que for informado(s) de forma especifica //
// codigo(s) de componente(s) que deseja calcula, obtem os   //
// coddigos e monta a clausula AND.                          //
If Len(aCompCalc) > 0
	For nCntFor := 1 To (Len(aCompCalc) - 1) // Ignorar a ultima posicao do Vetor

		If ValType(aCompCalc[nCntFor]) == 'C'
			If nCntFor == 1
				cCompCalc := " AND (DVE_CODPAS = '" + aCompCalc[nCntFor] + "'"
			Else
				cCompCalc += " OR DVE_CODPAS = '" + aCompCalc[nCntFor] + "'"
			EndIf
		EndIf
	Next nCntFor

	If !Empty(cCompCalc)
		cCompCalc += ")"
	EndIf

	aRet := aClone(aCompCalc[ len(aCompCalc) ])
EndIf

//-- Mensagens de erro, vetor aMsgErr:
//-- 01 - TMSA130 - Tabela fora da data de vigencia ou desativada. (DTL).
//-- A mensagem acima 01 foi excluida pois as funcoes TmsContr e TmsContrFor ja fazem esta verificacao
//-- 02 - TMSA030 - Componente de frete nao encontrado. (DT3)
//-- 03 - TMSA030 - Componente de frete. Informe o campo agrupa valor. (DT3)
//-- 04 - TMSA380 - Regiao nao habilitada para o tipo de servico, tipo de transporte. (DTN)
//-- 05 - TMSA010 - Nao encontrou tabela p/regiao
//-- 06 - TECA250 - Ajuste nao encontrado. Ajuste obrigatorio definido no contrato.
//-- 07 - TECA250 - Tabela de frete nao especificada no contrato do cliente generico.
//-- 08 - TMSA130 - Configuracao da tabela de frete Tipo Tab. nao encontrado. (DTL)
//-- 09 - TMSA010 - Base de calculo maior que as faixas do componente (DT1).  Tabela:  Reg.Ori:  Reg.Des:  Material:
//-- 10 - TMSA080 - Base de calculo maior que as faixas do componente (DTG).  Tab.Frete:  Tab.Tarifa:
//-- 11 - TMSA080 - Item da tarifa nao encontrado  (DTG).  Tab.Frete:  Tab.Tarifa:  Componente:
//-- 12 - TMSA080 - Nao encontrou a tabela de tarifa  Tab.Frete  Tipo Tab. (DTF)
//-- 13 - TMSA010 - Item da tabela mae nao encontrado  (DT1).  Tabela:  Reg.Ori:  Reg.Des:  Material:  Compon:
//-- 14 - TMSA011 - Base de calculo maior que as faixas do componente (DVD).  Tabela:  Reg.Ori:  Reg.Des:  Cliente:  Material:  Servico:
//-- 15 - TMSA010 - Tabela mae nao encontrada para calculo do ajuste (DT0).  Tabela:  Reg.Ori: cRgOTab  Reg.Des: cRgDTab  Material:  cPrdTab
//-- 16 - TMSA010 - Item da tabela mae nao encontrado para calculo do ajuste (DT1).  Tabela:  Reg.Ori: cRgOTab   Reg.Des: cRgDTab  Material: cPrdTab  Compo: cCodPas
//-- 17 - TECA250 - Contrato : Componente: . Percentual de cobranca igual a zero na conf.de componentes  (DT9)
//-- 18 - TECA250 - Contrato : Componente: . Nao atingiu o minimo para cobranca na conf.de componentes (DT9)
//-- 19 - TMSA011 - Ajuste nao encontrado (DVC).
//-- 20 - TMSA011 - Item do ajuste nao encontrado  (DVD).  Tabela:  Reg.Ori:  Reg.Des:  Material:  Compon:
//-- 21 - TMSA010 - Nao encontrou valores na tabela: p/o componente obrigatorio:
//-- 22 - TMSA410 - Nao encontrou Regra de Tributacao
//-- 23 - TMSA010 - Nao encontrou Complemento da Tabela de Frete

//-- verifica a necessidade de atualizacao do campo "DT3_FAIXA".
If Len(DT3->DT3_FAIXA) == 1
	cMsg := STR0054 + Chr(13) //"A Estrutura do Campo DT3_FAIXA devera ter 2 posicoes."
	cMsg += STR0055 //"Inclua no menu o programa 'AcertaDT3', execute a rotina e reinicialize o servico do TOPCONNECT."
	MsgInfo(cMsg)
	Final("")
EndIf

If lTMALTBAS
	aTmAltBs := ExecBlock("TMALTBAS",.F.,.F.,{nValMer,nPeso,nPesoM3,nPesoCob,nQtdVol,nSeguro,nMetro3,nQtdUni,nValDpc,cCliDev,cLojDev,cLotNfc,cTabFre,cTipTab,nKm,aNfCTRC,nPesoVge,nPesoM3Vge,nMetro3Vge,nValMerVge,nQtdVolVge,nDiaArm,cCdrOri})
	If ValType(aTmAltBs) == "A" .And. Len(aTmAltBs) >= 10
		//-- Se a base for alterada por componente, não alimenta variaveis gerais do cálculo de frete
		If Len(aTmAltBs) >= 11 .And. ValType(aTmAltBs[11]) == "C"
			cBsComp := aTmAltBs[11]
		EndIf

		//--Permite trocar o codigo da região para cálculo
		If Len(aTmAltBs) >= 12 .And. !Empty(aTmAltBs[12]) .And. ValType(aTmAltBs[12]) == "C"
			cCdrDes := aTmAltBs[12]
		EndIf
		
		If Len(aTmAltBs) >= 19 .And. !Empty(aTmAltBs[19]) .And. ValType(aTmAltBs[19]) == "C"
			cCdrOri	:= aTmAltBs[19]
		EndIf

		If Empty(cBsComp)
			nValMer  := aTmAltBs[01]
			nPeso    := aTmAltBs[02]
			nPesoM3  := aTmAltBs[03]
			nPesoCob := aTmAltBs[04]
			nQtdVol  := aTmAltBs[05]
			nSeguro  := aTmAltBs[06]
			nMetro3  := aTmAltBs[07]
			nQtdUni  := aTmAltBs[08]
			nValDpc  := aTmAltBs[09]
			nKm      := aTmAltBs[10]
			If Len(aTmAltBs) >= 13
				nMetro3Vge := aTmAltBs[13]
			EndIf
			If Len(aTmAltBs) >= 14
				nValMerVge := aTmAltBs[14]
			EndIf
			If Len(aTmAltBs) >= 15
				nQtdVolVge := aTmAltBs[15]
			EndIf
			If Len(aTmAltBs) >= 16
				nDiaArm := aTmAltBs[16]
			EndIf
			If Len(aTmAltBs) >= 17
				nPesoVge := aTmAltBs[17]    //-- antigo "11", que estava em duplicidade
			EndIf
			If Len(aTmAltBs) >= 18
			 	nPesom3Vge := aTmAltBs[18]  //-- antigo "12", que estava em duplicidade
			EndIf
		EndIf
	EndIf
EndIf
If lInvOri .Or. (DDA->(ColumnPos('DDA_DEVTRE')) > 0 .And. TmsSobServ('DEVTRE',.T.,.T.,cNContr,cCodNeg,cServic,"0", Nil ) $ '01' .And. cDocTms == StrZero(6,Len(DC5->DC5_DOCTMS))) //-- 1= Conforme o documento original
	//-- Na devolucao inverte as regioes origem e destino, para encontrar a tabela de frete do documento original
	cCdrAux := cCdrOri
	cCdrOri := cCdrDes
	cCdrDes := cCdrAux
ElseIf cDocTms == StrZero(6,Len(DC5->DC5_DOCTMS)) .And. !DDA->(ColumnPos('DDA_DEVTRE')) > 0
	cCdrAux := cCdrOri
	cCdrOri := cCdrDes
	cCdrDes := cCdrAux
EndIf

cOriAux  := cCdrOri
cDesAux  := cCdrDes
aInfoAnt := {StrZero(0,Len( DVC->DVC_SEQTAB )),cCodPro,cServic,cCodCli,cLojCli,cCdrOri,cCdrDes}
//-- .T. monta vetor com mensagem onde ocorreu erro no calculo.
lMsgErr := .T.
//-- Se Nao for Regiao Coligada, adiciono os niveis superiores no vetor aRegiao
//-- Esta regiao pode ser a encontrada no destino de calculo ou a regiao recebida no parametro
AADD(aCodCli, {cCodCli,cLojCli})
aRegiao := TmsNivSup( cCdrDes,,.T.,,aCodCli)

//CARREGA O RECNO DA TABELA DTL na variavel nRecDTL
DTL->(DbSetOrder( 1 ))
cAliasDTL := GetNextAlias()

cQueryDTL := "   SELECT DTL_CATTAB , DTL_MOEDA "
cQueryDTL += "     FROM " + RetSqlName("DTL") + " DTL "
cQueryDTL += "    WHERE DTL_FILIAL = '" + xFilial('DTL') + "' "
cQueryDTL += "      AND DTL_TABFRE = '" + cTabFre + "' "
cQueryDTL += "      AND DTL_TIPTAB = '" + cTipTab + "' "
cQueryDTL += "      AND DTL.D_E_L_E_T_ = ' ' "
cQueryDTL += " ORDER BY " + SqlOrder(DTL->(IndexKey()))
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDTL),cAliasDTL)
cQueryDTL := ChangeQuery(cQueryDTL)
If (cAliasDTL)->(!Eof())
	cCatTabAux := (cAliasDTL)->DTL_CATTAB
	nMoedaTb := (cAliasDTL)->DTL_MOEDA
EndIf
(cAliasDTL)->(DbCloseArea())

//CARREGA DT9 EM ARRAY CONTENDO CODIGO COMPONENTE E RECNO
DT9->(DbSetOrder( 1 ))
cAliasDT9 := GetNextAlias()

cQueryDT9 := "   SELECT DT9_CODPAS, DT9.R_E_C_N_O_ RECDT9"
cQueryDT9 += "     FROM " + RetSqlName("DT9") + " DT9 "
cQueryDT9 += "    WHERE DT9_FILIAL = '" + xFilial('DT9') + "' "
cQueryDT9 += "      AND DT9_NCONTR = '" + cNContr + "' "
cQueryDT9 += "      AND DT9_SERVIC = '" + cServic + "' "
cQueryDT9 += "      AND DT9_CODNEG = '" + cCodNeg + "' "
cQueryDT9 += "      AND DT9.D_E_L_E_T_ = ' ' "
cQueryDT9 += " ORDER BY " + SqlOrder(DT9->(IndexKey()))
cQueryDT9 := ChangeQuery(cQueryDT9)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDT9),cAliasDT9)

While (cAliasDT9)->(!Eof())
	aAdd( aCpDT9, { (cAliasDT9)->DT9_CODPAS, (cAliasDT9)->RECDT9 } )
	(cAliasDT9)->( dbSkip() )
EndDo
(cAliasDT9)->( DbCloseArea() )

// Buscar a Linha do Serviço no Contrato Comercial //
If lCamposRat 
	cAliasQry := GetNextAlias()

	cQuery := " SELECT DUX.DUX_ADIDOC" + CRLF
	cQuery += "   FROM " + RetSqlName("DUX") + " DUX "  + CRLF
	cQuery += "  WHERE DUX.DUX_FILIAL = '" + xFilial('DUX') + "' " + CRLF
	cQuery += "    AND DUX.DUX_NCONTR = '" + cNContr + "' " + CRLF
	cQuery += "    AND DUX.DUX_SERVIC = '" + cServic + "' "	 + CRLF
	cQuery += "    AND DUX.D_E_L_E_T_ = ' ' " + CRLF
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	If (cAliasQry)->(!Eof())
		nADIDOC := (cAliasQry)->DUX_ADIDOC
	Else
		nADIDOC := 0
	EndIf
	(cAliasQry)->( DbCloseArea() )
Else
	TmsSobServ('BACRAT',.T.,lSobSrv,cNContr,cCodNeg,cServic,"1",@nAdiDoc)
EndIf

//-- Analisa a Configuracao da tabela de frete
DVE->( DbSetOrder( 1 ) ) //-- DVE_FILIAL + DVE_TABFRE + DVE_TIPTAB + DVE_ITEM
cAliasQry := GetNextAlias()

cQuery := "   SELECT DVE_CODPAS, DVE_COMOBR, DT3.R_E_C_N_O_ RECDT3"
If lCamposRat
	cQuery += "     ,DVE_RATEIO "
EndIf
cQuery += "     FROM " + RetSqlName("DVE") + " DVE, "
cQuery += RetSqlName("DT3") + " DT3 "
cQuery += "    WHERE DVE_FILIAL = '" + xFilial('DVE') + "' "
cQuery += "      AND DVE_TABFRE = '" + cTabFre + "' "
cQuery += "      AND DVE_TIPTAB = '" + cTipTab + "' "
If !Empty(cCompCalc)
	cQuery += cCompCalc
EndIf
cQuery += "      AND DVE.D_E_L_E_T_ = ' ' "
cQuery += "      AND DT3_FILIAL = '" + xFilial('DT3') + "' "
cQuery += "      AND DVE_CODPAS = DT3_CODPAS "
cQuery += "      AND DT3.D_E_L_E_T_ = ' ' "
cQuery += "      ORDER BY CASE WHEN DT3_TIPFAI = '14' "
cQuery += "      	THEN '99' ELSE DVE_ITEM END "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

If (cAliasQry)->(!Eof())
	nPesoCob := 0
	While (cAliasQry)->(!Eof())
		lCmpRat    := lCamposRat .And. lRateio .And. (cAliasQry)->DVE_RATEIO == StrZero(1,Len(DVE->DVE_RATEIO))
		cCodPro    := aInfoAnt[ 2 ]
		cServic    := aInfoAnt[ 3 ]
		cCodCli    := aInfoAnt[ 4 ]
		cLojCli    := aInfoAnt[ 5 ]
		If	lCmpRat .And.; // Componente com Rateio = SIM
			(aBaseRat[08][01] == StrZero(2, Len(DTP->DTP_BACRAT))) .And.;	// Base Calc.Ra : 2=Ponto a Ponto
			(aBaseRat[08][02] == StrZero(2, Len(DTP->DTP_CRIRAT)) .Or. aBaseRat[08][02] == 'A' )	// Criterio Calc.Rat.: 2=Orig/Dest; A=Orig/Dest Vge

			cCdrOri := aBaseRat[08][04]
			cCdrDes := aBaseRat[08][05]
		Else
			cCdrOri := aInfoAnt[ 6 ]
			cCdrDes := aInfoAnt[ 7 ]
		EndIf
		cTabTar    := Space(Len(DTF->DTF_TABTAR))
		nValMin    := 0
		nValMax    := 9999999999.99
		nBaseCal   := 0
		nBaseSobre := 0
		nPerCob    := 0
		nVlrComp   := 0
		nPesComp   := 0
		nBaseCalFx2:= 0
		nVlrBaseFx2:= 0
		cFaixa2    := ""

		//-- Restaura valores de componentes a pagar
		If lAltInfo
			nPeso   := nPesoOld
			nPesoM3 := nPesoM3Old
			nMetro3 := nMetro3Old
			nValMer := nValMerOld
			nQtdVol := nQtdVolOld
			lAltInfo:= .F.
		EndIf

		//-- Obtem informacoes basicas do componente de frete
		nRecDT3 := (cAliasQry)->RECDT3
		DT3->(dbGoto(nRecDT3))

		// Sendo um Componente Baseado em PRACA DE PEDAGIO ( 09 ), e um processo de  //
		// Rateio de Frete a Receber (lRateio) e estando o Componente Configurado    //
		// para ser Rateado (DVE_RATEIO = 1):                                        //
		//                                                                           //
		// A variavel lPrcPdg será forçada a conter .T. de forma a forçar o Calculo  //
		// do pedagio para todo e qualquer Pagador de Frete e Documento. Dessa forma //
		// garantimos que esse componente será calculado e existira na Composicao de //
		// Frete e posteriormente, possa vir a ser Rateado conforme configuração de  //
		// Rateio.                                                                   //
		If DT3->DT3_FAIXA == StrZero(9,Len(DT3->DT3_FAIXA))
			If lCmpRat
				lPrcPdg := .T.
			EndIf

			//-- Verifica se deverá calcular o valor do componente praca por pedagio
			If !lPrcPdg
				(cAliasQry)->(DbSkip())
				Loop
			EndIf
		EndIf

		If DT3->DT3_FAIXA == StrZero(17,Len(DT3->DT3_FAIXA))
			lTaxDev:= .F.
			If lCmpRat
				lTaxDev := .T.
			Else
				nPosx := Ascan( aTaxDev, { |x| x[1] + x[2] == cCliDev + cLojDev } )
				If nPosx == 0
					AAdd( aTaxDev, { cCliDev, cLojDev, {DT3->DT3_CODPAS} } )
					lTaxDev:= .T.
				EndIf

				If !lTaxDev   //Verifica se existe o componente para o Cliente + Loja
					If nPosx > 0
						If Ascan(aTaxDev[nPosx][3], {|x| x == DT3->DT3_CODPAS }) == 0
							aAdd(aTaxDev[nPosx][3],  DT3->DT3_CODPAS )
							lTaxDev:= .T.
						EndIf
					EndIf
				EndIf
			EndIf

			//-- Verifica se deverá calcular o valor do componente Taxa por devedor
			If !lTaxDev
				(cAliasQry)->(DbSkip())
				Loop
			EndIf
		EndIf


		//-- Verifica o conteudo de agrupa valor
		If	DT3->DT3_AGRVAL != StrZero(0,Len(DT3->DT3_AGRVAL)) .And. DT3->DT3_AGRVAL != StrZero(1,Len(DT3->DT3_AGRVAL)) .And. DT3->DT3_AGRVAL != StrZero(2,Len(DT3->DT3_AGRVAL))
			If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '03' } ) == 0
				AAdd( aMsgErr, {STR0056 + AllTrim( DT3->DT3_DESCRI ) + STR0058, '03', 'TMSA030()' } ) //"Componente de frete "###". Informe o campo agrupa valor. (DT3) "
			EndIf
			(cAliasQry)->( DbSkip() )
			Loop
		EndIf

		// Valida se deve ou nao Considerar a cobrança da Taxa Adicional por Docto (DT3_TXADIC) //
		If lCamposRat
			// 1=Sim;2=Nao
			If DT3->DT3_TXADIC == StrZero(1,Len(DT3->DT3_TXADIC))
				// Taxa Nao Sera Cobrada quando Calculo originar-se da Cotacao de Frete.    //
				// Ou quando a Quantidade de Adicional Informada (DUX_ADIDOC)estiver Zerada.//
				If (IsInCallStack('TMSA040MNT')) .Or. (nADIDOC == 0)
					(cAliasQry)->( DbSkip() )
					Loop

				// Sendo a Sequencia/Ordem do Documento Calculado menor/igual ao //
				// Configurado no campo DUX_ADIDOC, nao sera cobrado o componente//
				ElseIf nADIDOC > nSeqDoc
					(cAliasQry)->( DbSkip() )
					Loop
				EndIf
			EndIf
		EndIf

		//-- Formato do vetor aTipVei
		//-- aTipVei[01] = Tipo do Veiculo informado na Nota Fiscal / Cotacao / Solicitacao de Coleta
		//-- aTipVei[02] = Quantidade do Tipo de Veiculo

		//-- Nao considera o componente, se o Tipo do Veiculo informado no cadastro deste Componente
		//-- NAO tiver sido informado na Tela de Tipos de Veiculo da Nota Fiscal
		nQtdTipVei := 1
		If !Empty(DT3->DT3_TIPVEI)
			//-- Se o array aTipVei estiver vazio OU o Tipo do Veiculo informado no cadastro deste Componente
			//-- nao estiver contido no array aTipVei
			nSeek:= IIf(Len(aTipVei) > 0 , Ascan(aTipVei, {|x| x[1] == DT3->DT3_TIPVEI } ), 0)
			If nSeek <= 0
				If (cAliasQry)->DVE_COMOBR == StrZero(1,Len((cAliasQry)->DVE_COMOBR))	 //-- Componente Obrigatorio
					If Ascan( aMsgErr, { |x| x[ 2 ] == '21' } ) == 0
						AAdd( aMsgErr, {STR0059 + AllTrim(DT3->DT3_DESCRI), '21', 'TMSA010()' } ) //"Nao encontrou valores p/ o componente obrigatorio: "
					EndIf
				EndIf
				(cAliasQry)->( DbSkip() )
				Loop
			EndIf
			nQtdTipVei := aTipVei[nSeek][2]
		EndIf

		//-- Posiciona na configuracao de componentes por contrato
		//DT9->(DbSetOrder( 1 ))
		//If	DT9->(MsSeek( xFilial('DT9') + cNContr + cServic + (cAliasQry)->DVE_CODPAS ))
		nPosDT9 := Ascan(aCpDT9, {|x| x[1] == (cAliasQry)->DVE_CODPAS } )
		If nPosDT9 > 0
			nRecDT9 := aCpDT9[nPosDT9, 2]
			DT9->( dbGoto(nRecDT9) )
			nPerCob := DT9->DT9_PERCOB
		Else
			DT9->( dbGoBottom() )  //vai para ultimo registro da DT9
			DT9->( dbSkip() )   //avancar um para ficar em EOF() da DT9
			nRecDT9 := -5000
			nPerCob := 100
		EndIf
		//-- Se o percentual de cobranca igual a zero, nao calcula o componente
		If nPerCob <= 0
			If	lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '17' } ) == 0 .And. (cAliasQry)->DVE_COMOBR == StrZero(1,Len((cAliasQry)->DVE_COMOBR))
				AAdd( aMsgErr, {STR0060 + cNContr + ' / ' + STR0061 + AllTrim( DT3->DT3_DESCRI ) + STR0062, '17', 'TECA250()' } ) //"Contrato : "###"Componente Obrigatorio: "###". Percentual de cobranca igual a zero na conf.de componentes (DT9)"
			EndIf
			(cAliasQry)->( DbSkip() )
			Loop
		EndIf

		//-- Atualiza valores de componentes a pagar
		If ( DT3->DT3_TIPFAI == StrZero(62,Len(DT3->DT3_TIPFAI)) .Or. ;
			 DT3->DT3_FAIXA  == StrZero(62,Len(DT3->DT3_FAIXA )) .Or. ;	//-- Peso Mercadoria
			 DT3->DT3_TIPFAI == StrZero(63,Len(DT3->DT3_TIPFAI)) .Or. ;
			 DT3->DT3_FAIXA  == StrZero(63,Len(DT3->DT3_FAIXA )) .Or. ;	//-- Valor Mercadoria
			 DT3->DT3_TIPFAI == StrZero(64,Len(DT3->DT3_TIPFAI)) .Or. ;
			 DT3->DT3_FAIXA  == StrZero(64,Len(DT3->DT3_FAIXA )) )			//-- Qtde. Volumes
			nPesoOld   := nPeso
			nPesoM3Old := nPesoM3
			nMetro3Old := nMetro3
			nValMerOld := nValMer
			nQtdVolOld := nQtdVol
			nPesoM3    := nPesoM3Vge
			nMetro3    := nMetro3Vge
			nValMer    := nValMerVge
			If !lTMSPVOC
				nPeso      := nPesoVge
				nQtdVol    := nQtdVolVge
			EndIf
			lAltInfo   := .T.
		EndIf

		//-- Verifica se a Tabela possui componente Diaria
		If ( DT3->DT3_TIPFAI == StrZero(54,Len(DT3->DT3_TIPFAI)) .Or. ;
			 DT3->DT3_FAIXA  == StrZero(54,Len(DT3->DT3_FAIXA )) .Or. ;	//-- Diaria Semana
			 DT3->DT3_TIPFAI == StrZero(60,Len(DT3->DT3_TIPFAI)) .Or. ;
			 DT3->DT3_FAIXA  == StrZero(60,Len(DT3->DT3_FAIXA )) )			//-- Diaria Fim Semana
				lCmpDiaria:= .T.
		EndIf
		//-- Verifica alteracao de base pelo ponto de entrada TMALTBAS
		If !Empty(cBsComp)
			nValMer	:= nValMerAux
			nPeso	:= nPesoAux
			nPesoM3	:= nPesoM3Aux
			nQtdVol	:= nQtdVolAux
			nSeguro	:= nSeguroAux
			nMetro3	:= nMetro3Aux
			nQtdUni	:= nQtdUniAux
			nValDpc	:= nValDpcAux
			nKm		:= nKmAux
			If (cAliasQry)->DVE_CODPAS $ cBsComp
				If DT3->DT3_TIPFAI == '01' //-- Peso Mercadoria
					nPeso   := aTmAltBs[02]
					nPesoM3 := aTmAltBs[03]
					nMetro3 := aTmAltBs[07]
				ElseIf DT3->DT3_TIPFAI == '02' //-- Valor Mercadoria
					nValMer := aTmAltBs[01]
				ElseIf DT3->DT3_TIPFAI == '03' //-- Qtde. de volumes
					nQtdVol := aTmAltBs[05]
				ElseIf DT3->DT3_TIPFAI == '04' //-- Base RR
					nSeguro := aTmAltBs[06]
				ElseIf DT3->DT3_TIPFAI == '05' //-- Qtde.Unitizador
					nQtdUni := aTmAltBs[08]
				ElseIf DT3->DT3_TIPFAI == '06' //-- Valor Despachante
					nValDpc := aTmAltBs[09]
				ElseIf DT3->DT3_TIPFAI == '08' //-- Km
					nKm     := aTmAltBs[10]
				EndIf
				If !Empty(DT3->DT3_FAIXA2)
					If DT3->DT3_FAIXA2 == '01' //-- Peso Mercadoria
						nPeso   := aTmAltBs[02]
						nPesoM3 := aTmAltBs[03]
						nMetro3 := aTmAltBs[07]
					ElseIf DT3->DT3_FAIXA2 == '02' //-- Valor Mercadoria
						nValMer := aTmAltBs[01]
					ElseIf DT3->DT3_FAIXA2 == '03' //-- Qtde. de volumes
						nQtdVol := aTmAltBs[05]
					ElseIf DT3->DT3_FAIXA2 == '04' //-- Base RR
						nSeguro := aTmAltBs[06]
					ElseIf DT3->DT3_FAIXA2 == '05' //-- Qtde.Unitizador
						nQtdUni := aTmAltBs[08]
					ElseIf DT3->DT3_FAIXA2 == '06' //-- Valor Despachante
						nValDpc := aTmAltBs[09]
					ElseIf DT3->DT3_FAIXA2 == '08' //-- Km
						nKm     := aTmAltBs[10]
					EndIf
				EndIf
			EndIf
		EndIf
		nPesoCal := TmsRetPeso( cNContr, cServic, DT3->DT3_CODPAS, @lPesoReal, nPeso, nPesoM3, nMetro3,,, cCodNeg )
		//-- Se o volume, peso ou valor nao atingir o minimo para cobranca, nao calcula o componente
		If	lMinimo
			If	(DT9->DT9_QTDVOL > 0 .And. DT9->DT9_QTDVOL > nQtdVol)  .Or.;
				(DT9->DT9_PESO   > 0 .And. DT9->DT9_PESO   > nPesoCal) .Or.;
				(DT9->DT9_VALOR  > 0 .And. DT9->DT9_VALOR  > nValMer)
				If	lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '18' } ) == 0 .And. (cAliasQry)->DVE_COMOBR == StrZero(1,Len((cAliasQry)->DVE_COMOBR))
					AAdd( aMsgErr, {STR0060 + cNContr + ' / ' + STR0061 + AllTrim( DT3->DT3_DESCRI ) + STR0063, '18', 'TECA250()' } ) //"Contrato : "###"Componente Obrigatorio: "###". Nao atingiu o minimo para cobranca na conf.de componentes (DT9)"
				EndIf
				(cAliasQry)->( DbSkip() )
				Loop
			EndIf
		EndIf

		If DT3->DT3_TIPFAI == StrZero(9,Len(DT3->DT3_TIPFAI)) .Or. DT3->DT3_TIPFAI == StrZero(16,Len(DT3->DT3_TIPFAI)) ;
			.Or. DT3->DT3_TIPFAI == StrZero(17,Len(DT3->DT3_TIPFAI)) //-- Praca de Pedagio ou Herda Valor ou Taxa Devedor
			If !lTaxDev
				nBaseCal   := 0
			Else
				nBaseCal   := 1
			EndIf
			nBaseSobre := nBaseCal
		Else
			//-- Obtem o valor base para o calculo, conforme o tipo da faixa do componente
			nBaseCal   := TmsBaseCal(aValInf,DT3->DT3_CODPAS,cNContr,cServic,@lPesoReal,nQtdVol,nValMer,nPeso,nPesoM3,nMetro3,nSeguro,nQtdDco,nDiaSem,nKm,nPerNoi,nQtdEnt,nQtdUni,nValDpc,nDocSImp,nDocCImp,cCdrOri,cCdrDes,cTipTra,nDiaFimSem,"DT3_FAIXA",cCodCli,cLojCli,aPesCub,aRet,nQtdCol, /*nRecDT3*/, lCmpRat, aBaseRat, cCodNeg , cTabFre , cTipTab , cCodPro )
			nBaseSobre := nBaseCal
			//-- Obtem o valor base para o calculo da sub-faixa, conforme o tipo da faixa do componente
			If !Empty(DT3->DT3_FAIXA2)
				nBaseCalFx2 := TmsBaseCal(aValInf,DT3->DT3_CODPAS,cNContr,cServic,@lPesoReal,nQtdVol,nValMer,nPeso,nPesoM3,nMetro3,nSeguro,nQtdDco,nDiaSem,nKm,nPerNoi,nQtdEnt,nQtdUni,nValDpc,nDocSImp,nDocCImp,cCdrOri,cCdrDes,cTipTra,nDiaFimSem,"DT3_FAIXA2",cCodCli,cLojCli,aPesCub,aRet,nQtdCol, /*nRecDT3*/, lCmpRat, aBaseRat, cCodNeg , cTabFre , cTipTab , cCodPro )
				nBaseSobre  := nBaseCalFx2
				cFaixa2     := DT3->DT3_FAIXA2
			ElseIf DT3->DT3_FAIXA <> DT3->DT3_TIPFAI
				nBaseSobre := TmsBaseCal(aValInf,DT3->DT3_CODPAS,cNContr,cServic,lPesoReal,nQtdVol,nValMer,nPeso,nPesoM3,nMetro3,nSeguro,nQtdDco,nDiaSem,nKm,nPerNoi,nQtdEnt,nQtdUni,nValDpc,nDocSImp,nDocCImp,cCdrOri,cCdrDes,cTipTra,nDiaFimSem,"DT3_TIPFAI",cCodCli,cLojCli,aPesCub,aRet,nQtdCol, /*nRecDT3*/, lCmpRat, aBaseRat, cCodNeg , cTabFre , cTipTab , cCodPro  )
			EndIf
			If	nBaseCal <= 0 .And. DT3->DT3_TIPFAI <> '15' //-- Cliente Destinatario
				If (cAliasQry)->DVE_COMOBR == StrZero(1,Len((cAliasQry)->DVE_COMOBR))	 //-- Componente Obrigatorio
						AAdd( aMsgErr, {STR0059 + AllTrim(DT3->DT3_DESCRI), '21', 'TMSA010()' } ) //"Nao encontrou valores p/ o componente obrigatorio: "
				EndIf
				(cAliasQry)->( DbSkip() )
				Loop
			EndIf
		EndIf

		//-- Ponto de entrada responsavel pela alteracao da base de cálculo por componente.
		If lTMBASCAL
       	nBaseCalPE := ExecBlock("TMBASCAL",.F.,.F.,{cTabFre, cTipTab, cSeqTab, cCdrOri,;
       	cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cSerTms, cTipTra, cNContr, nBaseCal,;
       	nBaseSobre, aNfCTRC, aRet, cCodNeg})
       	If ValType(nBaseCalPE) == "N"
       		nBaseCal := nBaseSobre := nBaseCalPE
       	ElseIf ValType(nBaseCalPE) == "A" .And. Len(nBaseCalPE) = 2
				nBaseCal := nBaseCalPE[1]
				nBaseSobre := nBaseCalPE[2]
			EndIf
		EndIf

		lPsqTab := DT3->DT3_PSQTAB == StrZero(1,Len(DT3->DT3_PSQTAB))

		//-- Formato do vetor aRet
		//
		//-- aRet[01] = Descricao do componente
		//-- aRet[02] = Valor do componente
		//-- aRet[03] = Codigo do componente
		//-- aRet[04] = Item SD2. Atualizado pelas funcoes que geram o SD2
		//-- aRet[05] = Na cotacao eh gravado o valor do imposto do componente
		//-- aRet[06] = Total do componente ( valor + imposto )
		//-- aRet[07] = Codigo da regiao origem
		//-- aRet[08] = Codigo da regiao destino
		//-- aRet[09] = Tabela de Frete
		//-- aRet[10] = Tipo da Tabela de Frete
		//-- aRet[11] = Sequencia da Tabela de Frete
		//-- aRet[12] = Forca a linha totalizadora para a ultima linha
		//-- aRet[13] = Desconto dado ao valor do componente
		//-- aRet[14] = Acrescimo dado ao valor do componente
		//-- aRet[15] = Indica se o componente foi calculado com o valor minimo. "1"= Sim, "2"= Nao
		//-- aRet[16] = Indica o criterio de calculo do componente - Peso, Volume, Quantidade
		//-- aRet[17] = Produto
		//-- aRet[18] = Codigo do Serviço
		//-- aRet[19] = Codigo do Cliente
		//-- aRet[20] = Loja do cliente
		//-- aRet[21] = Percentual de Rateio do Componente
		//-- aRet[22] = Codigo Negociacao
		//-- aRet[23] = Indica se o componente é obrigatorio
		If DT3->DT3_TIPFAI == "13"
			nQtdTDA   := 1

			If Empty(cDevTDA) .Or. cExcTDA == "3"
				(cAliasQry)->(DbSkip())
				Loop

			ElseIf cDevTDA == "1" .And. (cExcTDA $ "1/3" .Or. cRemTDA == "2") //-- 1-Coleta
				(cAliasQry)->(DbSkip())
				Loop
			ElseIf cDevTDA == "2" .And. (cExcTDA $ "2/3" .Or. cDesTDA == "2") //-- 2-Entrega
				(cAliasQry)->(DbSkip())
				Loop

			ElseIf cDevTDA == "3" //-- Coleta e entrega
				If Empty(cExcTDA) .And. (cRemTDA == "1" .And. cDesTDA == "1")
					nQtdTDA := 2
				Else
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
			ElseIf cDevTDA == "4" //-- Coleta ou entrega
				If	(cRemTDA <> "1" .Or. cExcTDA $ "1/3") .And. (cDesTDA <> "1" .Or. cExcTDA $ "2/3")
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		If Empty(aRet)
			aRet := {}
		EndIf

		AAdd( aRet, { AllTrim(DT3->DT3_DESCRI), 0, DT3->DT3_CODPAS, '', 0, 0, Space(Len(cCdrOri)), Space(Len(cCdrDes)), '', '', '','00', 0, 0 , StrZero(2,Len(DT8->DT8_CALMIN)),DT3->DT3_FAIXA, '', '', '', '', 0, '','' } )

		lExistAju  := .F.
		lExistCmp  := .F. //-- Verifica se o componente esta configurado na tabela.
		lTabHerda  := .F.
		lCmpHerda := .F.
		cDT3_TAXA   := DT3->DT3_TAXA
		cDT3_PSQTXA := DT3->DT3_PSQTXA

		// Componentes de Herda Valor, não precisam estar vinculados na tabela, porém precisam ter tabela origem e destino
		// Desta forma é forçado que pesquise as regiões acima, independente de como está configurado no componente, para evitar que falhe quando os outros componentes tenham tabela para outras regiões
		If DT3->DT3_TIPFAI == StrZero(16,Len(DT3->DT3_TIPFAI))
			lCmpHerda := .T.
			cDT3_TAXA   := "1"
			cDT3_PSQTXA := "1"
		EndIf

		If DT3->DT3_TIPFAI == '15' //-- Calculo pelo cliente destinatario
			If lCliGen
				SA1->(DbSetOrder(1))
				If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
					cCliGen := SA1->A1_COD
					cLojGen := SA1->A1_LOJA
				EndIf
			EndIf
			lOk := .T.
			If lMVCompDes // lMVCompDes é .T. quando o parametro MV_COMPDES for verdadeiro
				lOk   := .F.
				aRetD := TMSTabDest(cCliDes,cLojDes,DT3->DT3_CODPAS)
				//-- Descricao do ARRAY aRetD
				//-- aRetD[1] - Cliente trabalha com tabela de frete por destinatario
				//-- aRetD[2] - Exige agendamento de entrega
				//-- aRetD[3] - Documentos que podem efetuar a cobrança do componente
				If aRetD[1] .And. cDocTms $ aRetD[3]
					lOk := .T.
				EndIf
			EndIf

			nMinDYA := 0
			If lOk
				If DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+cCliDes+cLojDes))
					If !Empty(nBaseSobre)
						nVlrComp += TmsVlFaixa( @aMsgErr, cTabFre, cTipTab, cTabTar, cCdrOri, cCdrDes, cCodCli, cLojCli, cSeqTab,;
						cCodPro, cServic, DT3->DT3_CODPAS, DT3->DT3_FAIXA, cPesCob, DT3->DT3_FRACAO, (cAliasQry)->DVE_COMOBR, lMsgErr, lPesoReal,;
						@nValMin, @nPesoCob, nLenTpFai, nVlrBase, nPerCob, nValMer, cRgOTab, cRgDTab, cPrdTab, nQtdDco, nVlrSobre, nVlrBaseFx2, cFaixa2,;
						@aFaixaTab, , @nValMax, cCliDes, cLojDes, nRecDT3, , @cRecDT1, @cRecDTG )

						nPesComp += nPesoCob
					Else
						nVlrComp := DYA->DYA_VALOR
					EndIf
					nMinDYA  := DYA->DYA_VALMIN
				ElseIf lCliGen .And. DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+cCliGen+cLojGen))
					nVlrComp := DYA->DYA_VALOR
					nMinDYA	 := DYA->DYA_VALMIN
				EndIf
			EndIf
		Else
			//-- ---------------------------------------------------------------------------------------------------------- --//
			//-- ---------------------------------------------------------------------------------------------------------- --//
			//-- ---------------------------------------------------------------------------------------------------------- --//
			//-- ---------------------------------------------------------------------------------------------------------- --//
			cCodCli := aInfoAnt[ 4 ]
			cLojCli := aInfoAnt[ 5 ]
			If (nPos := aScan(aDT3Calc, {|x| x[1]+x[2]+x[4]+x[5]+x[12]+x[21]+x[22]+x[8]== cTabFre+cTipTab+cCdrOri+cCdrDes+DT3->DT3_CODPAS+cCodCli+cLojCli+cCodPro} )) > 0
				cCdrOri   := aDT3Calc[nPos,  4]
				cCdrDes   := aDT3Calc[nPos,  5]
				cSeqTab   := aDT3Calc[nPos,  3]
				cCodPro   := aDT3Calc[nPos,  8]
				cServic   := aDT3Calc[nPos,  9]
				cCodCli   := aDT3Calc[nPos,  6]
				cLojCli   := aDT3Calc[nPos,  7]
				cTabTar   := aDT3Calc[nPos, 10]
				lExistAju := aDT3Calc[nPos, 14]
				cRgOTab   := aDT3Calc[nPos, 15]
				cRgDTab   := aDT3Calc[nPos, 16]
				cPrdTab   := aDT3Calc[nPos, 17]
				lExistCmp := aDT3Calc[nPos, 20]
				nVlrComp  := 0
			Else

				//-- ---------------------------------------------------------------------------------------------------------- --//
				//-- Posiciona na tabela de frete da regiao, se nao encontrar, posiciona na tabela de frete do nivel superior.  --//
				//-- O resultado do valor do componente pode variar entre a regiao e os niveis superiores, isto acontece pq ha  --//
				//-- impostos especificos para determinadas regioes.                                                            --//
				//-- ---------------------------------------------------------------------------------------------------------- --//
				For nCntFor := 1 To Len( aRegiao )
					cCodPro  := aInfoAnt[ 2 ]
					cServic  := aInfoAnt[ 3 ]
					cCodCli  := aInfoAnt[ 4 ]
					cLojCli  := aInfoAnt[ 5 ]
					cCdrDes  := aRegiao[ nCntFor ]
					nVlrComp := 0

					If nCntFor > 1 .And. cDT3_PSQTXA == "2"
						Exit
					EndIf

					//-- Posiciona no ultimo Ajuste, se nao for um cliente generico
					If	! lCliGen .And.	TmsTabela( @aMsgErr, @cTabFre, @cTipTab, @cSeqTab, @cCdrOri, @cCdrDes, cCodCli, cLojCli, @cCodPro, @cServic, @cTabTar, cDT3_TAXA, DT3->DT3_CODPAS, cDT3_PSQTXA, @lExistAju, @cRgOTab, @cRgDTab, @cPrdTab, cCatTabAux, DT3->DT3_TIPFAI, cCodNeg)
						lExistCmp := .T.

						If lCmpHerda
							lTabHerda := .T.
						EndIf
						//-- Posiciona na tabela mae
					ElseIf (!lExistAju .Or. lPsqTab) .And. ;
										TmsTabela( @aMsgErr, @cTabFre, @cTipTab, @cSeqTab, @cCdrOri, @cCdrDes,         ,       , @cCodPro, @cServic, @cTabTar, cDT3_TAXA, DT3->DT3_CODPAS, cDT3_PSQTXA,        .F.,      Nil,      Nil,      Nil, cCatTabAux, DT3->DT3_TIPFAI, cCodNeg)
						cCodCli   := Space( Len( DVC->DVC_CODCLI ) )
						cLojCli   := Space( Len( DVC->DVC_LOJCLI ) )
						cSeqTab   := StrZero(0, Len(DVC->DVC_SEQTAB) )
						lExistCmp := .T.

						If lCmpHerda
							lTabHerda := .T.
						EndIf
					Else
						Loop
					EndIf

					//-- Valida se a regiao de destino esta habilitada para o tipo de servico e tipo de transporte do servico digitado
					If	! TmsChkDTN( cSerTms, cTipTra, cCdrDes, .F. , aRegiao )
						If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '04' } ) == 0
							AAdd( aMsgErr, { STR0064 + cCdrDes + STR0065 + cSerTms + STR0066 + cTipTra + '. (DTN)', '04', 'TMSA380()' } ) //"Regiao "###" nao habilitada para o tipo de servico "###", tipo de transporte "
						EndIf
						Loop
					EndIf

					//-- Determina se o ajuste e' obrigatorio
					If	! lCliGen .And. lAjuAut .And. !lExistAju //cSeqTab == StrZero(0,Len(DVC->DVC_SEQTAB))
						If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '06' } ) == 0
							AAdd( aMsgErr, {STR0067, '06', 'TMSA480()' } ) //"Ajuste não encontrado. Ajuste obrigatório definido no Perfil do Cliente"
						EndIf
						Loop
					EndIf

					//-- Encontrou tabela para esta regiao, calculou o componente, sai do laco de regioes para calcular
					//-- vetor de calculo
					//--            1        2        3 !      4 !      5 !      6        7        8 !      9 !      10 !     11             12               13               14 !       15 !     16 !     17 !     18          19       20         21             22
					Aadd(aDT3Calc, {cTabFre, cTipTab, cSeqTab, cCdrOri, cCdrDes, cCodCli, cLojCli, cCodPro, cServic, cTabTar, cDT3_TAXA, DT3->DT3_CODPAS, cDT3_PSQTXA, lExistAju, cRgOTab, cRgDTab, cPrdTab, cCatTabAux, lPsqTab, lExistCmp, aInfoAnt[ 4 ], aInfoAnt[ 5 ]} )
					Exit
				Next nCntFor
			EndIf
		EndIf

		//-- Se não localizou tabela em nenhum nível do gurpo de regioes, volta a origem e destino para o conteúdo inicial
		//-- Isso foi feito para que seja exibida a informações de Help com a origem e destino corretos para o usuario nao
		//-- fazer confusao, já que ele pode cadastrar na tabela apenas.
		If !(Len(aDT3Calc) > 0)
               cCdrOri := aInfoAnt[ 6 ]
               cCdrDes := aInfoAnt[ 7 ]
		EndIf

		aRet[Len(aRet), 7] := cCdrOri
		aRet[Len(aRet), 8] := cCdrDes
		aRet[Len(aRet), 9] := cTabFre
		aRet[Len(aRet),10] := cTipTab
		aRet[Len(aRet),11] := cSeqTab
		aRet[Len(aRet),17] := cCodPro
		aRet[Len(aRet),18] := cServic
		aRet[Len(aRet),19] := cCodCli
		aRet[Len(aRet),20] := cLojCli
		aRet[Len(aRet),22] := cCodNeg
		aRet[Len(aRet),23] := (cAliasQry)->DVE_COMOBR

		nVlrComp := 0

		//-- Componente de frete que determina o peso cobrado.
		If	DT3->DT3_CODPAS $ cPesCob
			nPesoCob	:= 0
			nPesComp	:= 0
		EndIf

		If	DT3->DT3_TIPFAI <> StrZero(16,Len(DT3->DT3_TIPFAI))//Para o Tipo de faixa Herda Valor nao analisa.
			//-- Analisa a faixa de valores, usando como base o total de notas fiscais de cliente.
			If	DT3->DT3_AGRVAL == StrZero(1,Len(DT3->DT3_AGRVAL)) .Or. DT3->DT3_AGRVAL == StrZero(0,Len(DT3->DT3_AGRVAL)) .Or. Empty(aNfCTRC) .Or. ! lMinimo .Or. ;
				DT3->DT3_TIPFAI == StrZero(9,Len(DT3->DT3_TIPFAI)) .Or. DT3->DT3_TIPFAI == StrZero(17,Len(DT3->DT3_TIPFAI))
				nVlrComp := TmsVlFaixa( @aMsgErr, cTabFre, cTipTab, cTabTar, cCdrOri, cCdrDes, cCodCli, cLojCli, cSeqTab,;
				cCodPro, cServic, DT3->DT3_CODPAS, DT3->DT3_FAIXA, cPesCob, DT3->DT3_FRACAO, (cAliasQry)->DVE_COMOBR, lMsgErr, lPesoReal,;
				@nValMin, @nPesoCob, nLenTpFai, nBaseCal, nPerCob, nValMer, cRgOTab, cRgDTab, cPrdTab, nQtdDco, nBaseSobre, nBaseCalFx2, cFaixa2,;
				@aFaixaTab, cLotNfc, @nValMax, cCliDes, cLojDes, nRecDT3, cCodNeg, @cRecDT1, @cRecDTG )

				nPesComp := nPesoCob

			//-- Analisa a faixa de valores, usando como base o valor de cada nota fiscal do cliente.
			ElseIf DT3->DT3_AGRVAL == StrZero(2,Len(DT3->DT3_AGRVAL))

				For n1Cnt := 1 To Len( aNfCTRC )

					//-- Obtem o valor base para o calculo, conforme o tipo da faixa do componente
					nVlrBase  := TmsBaseCal(aValInf,DT3->DT3_CODPAS,cNContr,aInfoAnt[ 3 ],@lPesoReal,aNfCTRC[n1Cnt,5],aNfCTRC[n1Cnt,6],aNfCTRC[n1Cnt,7],aNfCTRC[n1Cnt,8],aNfCTRC[n1Cnt,9],aNfCTRC[n1Cnt,10],nQtdDco,nDiaSem,nKm,nPerNoi,nQtdEnt,aNfCTRC[n1Cnt,27],aNfCTRC[n1Cnt,28],nDocSImp,nDocCImp,aNfCTRC[n1Cnt,14],aNfCTRC[n1Cnt,15],aNfCTRC[n1Cnt,13],nDiaFimSem,"DT3_FAIXA",cCodCli,cLojCli,aPesCub,aRet,nQtdCol,nRecDT3, lCmpRat, aBaseRat, cCodNeg)
					nVlrSobre := nVlrBase
					//-- Obtem o valor base para o calculo da sub-faixa, conforme o tipo da faixa do componente
					If !Empty(DT3->DT3_FAIXA2)
						nVlrBaseFx2 := TmsBaseCal(aValInf,DT3->DT3_CODPAS,cNContr,aInfoAnt[ 3 ],@lPesoReal,aNfCTRC[n1Cnt,5],aNfCTRC[n1Cnt,6],aNfCTRC[n1Cnt,7],aNfCTRC[n1Cnt,8],aNfCTRC[n1Cnt,9],aNfCTRC[n1Cnt,10],nQtdDco,nDiaSem,nKm,nPerNoi,nQtdEnt,aNfCTRC[n1Cnt,27],aNfCTRC[n1Cnt,28],nDocSImp,nDocCImp,aNfCTRC[n1Cnt,14],aNfCTRC[n1Cnt,15],aNfCTRC[n1Cnt,13],nDiaFimSem,"DT3_FAIXA2",cCodCli,cLojCli,aPesCub,aRet,nQtdCol,nRecDT3, lCmpRat, aBaseRat, cCodNeg, cTabFre , cTipTab , cCodPro )
						nVlrSobre   := nVlrBaseFx2
						cFaixa2     := DT3->DT3_FAIXA2
					EndIf
					If DT3->DT3_FAIXA <> DT3->DT3_TIPFAI .Or. (!Empty(cFaixa2) .And. cFaixa2 <> DT3->DT3_TIPFAI)
						nVlrSobre := TmsBaseCal(aValInf,DT3->DT3_CODPAS,cNContr,aInfoAnt[ 3 ],lPesoReal,aNfCTRC[n1Cnt,5],aNfCTRC[n1Cnt,6],aNfCTRC[n1Cnt,7],aNfCTRC[n1Cnt,8],aNfCTRC[n1Cnt,9],aNfCTRC[n1Cnt,10],nQtdDco,nDiaSem,nKm,nPerNoi,nQtdEnt,aNfCTRC[n1Cnt,27],aNfCTRC[n1Cnt,28],nDocSImp,nDocCImp,aNfCTRC[n1Cnt,14],aNfCTRC[n1Cnt,15],aNfCTRC[n1Cnt,13],nDiaFimSem,"DT3_TIPFAI",cCodCli,cLojCli,aPesCub,aRet,nQtdCol,nRecDT3, lCmpRat, aBaseRat, cCodNeg, cTabFre , cTipTab , cCodPro )
					EndIf

					nVlrComp += TmsVlFaixa( @aMsgErr, cTabFre, cTipTab, cTabTar, cCdrOri, cCdrDes, cCodCli, cLojCli, cSeqTab,;
					cCodPro, cServic, DT3->DT3_CODPAS, DT3->DT3_FAIXA, cPesCob, DT3->DT3_FRACAO, (cAliasQry)->DVE_COMOBR, lMsgErr, lPesoReal,;
					@nValMin, @nPesoCob, nLenTpFai, nVlrBase, nPerCob, nValMer, cRgOTab, cRgDTab, cPrdTab, nQtdDco, nVlrSobre, nVlrBaseFx2, cFaixa2,;
					@aFaixaTab, , @nValMax, cCliDes, cLojDes, nRecDT3, cCodNeg, @cRecDT1, @cRecDTG )

					nPesComp += nPesoCob
				Next n1Cnt

			EndIf
		EndIf
		//-- ---------------------------------------------------------------------------------------------------------- --//
		//-- ---------------------------------------------------------------------------------------------------------- --//
		//-- ---------------------------------------------------------------------------------------------------------- --//
		//-- ---------------------------------------------------------------------------------------------------------- --//

		// Ajusta o valor de o campo DYA_TIPVAL for "Percentual s/ frete"
		If DT3->DT3_TIPFAI == "15"
			nTotAtu := 0
		  	nValMin := nMinDYA

			SA1->(DbSetOrder(1))
			If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
				cCliGen := SA1->A1_COD
				cLojGen := SA1->A1_LOJA
			EndIf
			lOk := .T.
			If lMVCompDes // lMVCompDes é .T. quando o parametro MV_COMPDES for verdadeiro
				lOk   := .F.
				aRetD := TMSTabDest(cCliDes,cLojDes,DT3->DT3_CODPAS)
				//-- Descricao do ARRAY aRetD
				//-- aRetD[1] - Cliente trabalha com tabela de frete por destinatario
				//-- aRetD[2] - Exige agendamento de entrega
				//-- aRetD[3] - Documentos que podem efetuar a cobrança do componente
				If aRetD[1] .And. cDocTms $ aRetD[3]
					lOk := .T.
				EndIf
				//Procura Cliente Generico
				If !lOk
					aRetD := TMSTabDest(cCliGen,cLojGen,DT3->DT3_CODPAS)
					//-- Descricao do ARRAY aRetD
					//-- aRetD[1] - Cliente trabalha com tabela de frete por destinatario
					//-- aRetD[2] - Exige agendamento de entrega
					//-- aRetD[3] - Documentos que podem efetuar a cobrança do componente
					If aRetD[1] .And. cDocTms $ aRetD[3]
						lOk := .T.
					EndIf
				EndIf
			EndIf

			nMinDYA := 0
			DUL->(DbSetOrder(2))
			If Empty(cSeqDes) .Or. Empty(DUL->DUL_CODRED) .And. Empty(DUL->DUL_LOJRED)
				If lOk
					If DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+cCliDes+cLojDes))
						If !Empty(nBaseSobre)
							nVlrComp += TmsVlFaixa( @aMsgErr, cTabFre, cTipTab, cTabTar, cCdrOri, cCdrDes, cCodCli, cLojCli, cSeqTab,;
							cCodPro, cServic, DT3->DT3_CODPAS, DT3->DT3_FAIXA, cPesCob, DT3->DT3_FRACAO, (cAliasQry)->DVE_COMOBR, lMsgErr, lPesoReal,;
							@nValMin, @nPesoCob, nLenTpFai, nVlrBase, nPerCob, nValMer, cRgOTab, cRgDTab, cPrdTab, nQtdDco, nVlrSobre, nVlrBaseFx2, cFaixa2,;
							@aFaixaTab, , @nValMax, cCliDes, cLojDes, nRecDT3, , @cRecDT1, @cRecDTG )

							nPesComp += nPesoCob
						Else
							nVlrComp := DYA->DYA_VALOR
						EndIf
						nMinDYA  := DYA->DYA_VALMIN
					ElseIf DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+cCliGen+cLojGen))
						nVlrComp := DYA->DYA_VALOR
						nMinDYA	 := DYA->DYA_VALMIN
					EndIf
				EndIf
			ElseIf DUL->(MsSeek( xFilial('DUL') + cCliDes + cLojDes + cSeqDes ))
				   If !Empty(DUL->DUL_CODRED) .And. !Empty(DUL->DUL_LOJRED)
						If DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+DUL->DUL_CODRED+DUL->DUL_LOJRED))
							cCliDes := DUL->DUL_CODRED
							cLojDes := DUL->DUL_LOJRED
							If !Empty(nBaseSobre)
								nVlrComp += TmsVlFaixa( @aMsgErr, cTabFre, cTipTab, cTabTar, cCdrOri, cCdrDes, cCodCli, cLojCli, cSeqTab,;
								cCodPro, cServic, DT3->DT3_CODPAS, DT3->DT3_FAIXA, cPesCob, DT3->DT3_FRACAO, (cAliasQry)->DVE_COMOBR, lMsgErr, lPesoReal,;
								@nValMin, @nPesoCob, nLenTpFai, nVlrBase, nPerCob, nValMer, cRgOTab, cRgDTab, cPrdTab, nQtdDco, nVlrSobre, nVlrBaseFx2, cFaixa2,;
								@aFaixaTab, , @nValMax, cCliDes, cLojDes, nRecDT3, , @cRecDT1, @cRecDTG )

								nPesComp += nPesoCob
							Else
								nVlrComp := DYA->DYA_VALOR
							EndIf
							nMinDYA  := DYA->DYA_VALMIN
						ElseIf lCliGen .And. DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+cCliGen+cLojGen))
							nVlrComp := DYA->DYA_VALOR
							nMinDYA	 := DYA->DYA_VALMIN
						EndIf
					EndIf
			EndIf
			// Ajusta o valor se o campo DYA_TIPVAL for "Percentual s/ frete"
			DYA->(dbSetOrder(1))
			If DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+cCliDes+cLojDes))
				If DYA->DYA_TIPVAL == "2"
					AEval( aRet, { |x| nTotAtu += x[2] } )
					nVlrComp := (DYA->DYA_VALOR * nTotAtu) / 100
				EndIf
			ElseIf DYA->(dbSeek(xFilial('DYA')+cTabFre+cTipTab+DT3->DT3_CODPAS+cCliGen+cLojGen))
				If DYA->DYA_TIPVAL == "2"
					AEval( aRet, { |x| nTotAtu += x[2] } )
					nVlrComp := (DYA->DYA_VALOR * nTotAtu) / 100
				EndIf
			EndIf
		EndIf
		// Ajusta valor do TDA
		If DT3->DT3_TIPFAI == "13" .And. nQtdTDA > 1
			nVlrComp := (nVlrComp * nQtdTDA)
		EndIf

		//---- Componente 16-Herda Valor
		// Apenas calcula se encontrou tabela de origem e destino para os outros componentes
		lCmpHerda:= .F.
		
		If DT3->DT3_TIPFAI == '16' .AND. lTabHerda .And. lCbrCol
			lCmpHerda:= .T.
			If Len(aNfCTRC) > 0
			   //--- Monta o vetor aFreteCol com as Solicitaçoes de Coleta e com
			   //--- seus respectivos componentes de Herda valor e Nota Fiscal que estao no vetor aNfCTRC
				TmsFrtCol(aNfCTRC,cLotNfc, DT3->DT3_CODPAS,@aFreteCol)
				If Len(aFreteCol) > 0
					//--- Valor total do componente com base em todas as SCs que estao no vetor aNfCTRC
					//--- Este valor será rateado posteriormente caso a SC estiver vinculada a mais de uma NF
					//--- gerando mais de um CTRC. (TMSA200Agr)
					nVlrComp := TmsVlrCmp(aFreteCol,DT3->DT3_CODPAS)
				EndIf
			EndIf
		EndIf
		

		//-- Nao Encontrou valores e o componente Nao e' obrigatorio
		If (nVlrComp <= 0  .And. nValmin <=0) .And. (cAliasQry)->DVE_COMOBR == StrZero(2,Len((cAliasQry)->DVE_COMOBR))
			If !lExistCmp
				aRet:= ADel(aRet,Len(aRet))
				aRet:= ASize(aRet,Len(aRet)-1)
			EndIf
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		//-- CargoLift Fase 2
		//-- Verifica Se o Valor Do Componente é Obrigatorio Campo DDA_CMPOBR ou DDC_CMPOBR
		If lCmpRat .And. AliasIndic("DDA")

			//-- Verifica Se é Obrigatório Componentes Valorizados
			If TmsSobServ('CMPOBR',.T.,lSobSrv,cNContr,cCodNeg,cServic,"0",@nAdiDoc,.f.) == '1' //-- SIM

				//-- Verifica Se Componente Está Valorizado
				If nVlrComp <= 0
					If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '21' } ) == 0
						AAdd( aMsgErr, {	STR0059 + AllTrim(DT3->DT3_DESCRI)+ " " +;    //-- "Não encontrou valores p/ o componente obrigatório: "
											STR0140 + Alltrim(cNContr) + " " +;           //-- "Contrato do cliente "
											STR0157 + cCodNeg + " " +;                    //-- "Cód. Negociação: "
											STR0158 + cServic  ,;                         //-- "Serviço: "
											'21', 'TMSA010()' } )
						aRet := {}
						AAdd( aRet, { AllTrim(DT3->DT3_DESCRI), 0, DT3->DT3_CODPAS, '', 0, 0, Space(Len(cCdrOri)), Space(Len(cCdrDes)), '', '', '', '00', 0, 0 , StrZero(2,Len(DT8->DT8_CALMIN)),DT3->DT3_FAIXA, '', '', '', '', 0, '','' } )
					EndIf
					Exit

				EndIf
			EndIf
		EndIf

		//--- Componentes que calcula sobre Herda Valor validar obrigatoriedade somente se for pela rotina de Calculo de Frete
		If !lCmpHerda .Or. (lCmpHerda .And. Len(aNfCTRC) > 0)
			//-- Nao Encontrou valores e o componente e' obrigatorio
			If	nVlrComp <= 0 .And. nValmin <=0 .And. (cAliasQry)->DVE_COMOBR == StrZero(1,Len((cAliasQry)->DVE_COMOBR))
				If cSerTMS != "1" .Or. lBlqCol
					If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '21' } ) == 0
						AAdd( aMsgErr, {STR0068 + cTabFre + '/' + cTipTab + STR0069 + AllTrim(DT3->DT3_DESCRI), '21', 'TMSA010()' } ) //"Não encontrou valores na tabela: "###" p/o componente obrigatório: "
						aRet := {}
						AAdd( aRet, { AllTrim(DT3->DT3_DESCRI), 0, DT3->DT3_CODPAS, '', 0, 0, Space(Len(cCdrOri)), Space(Len(cCdrDes)), '', '', '', '00', 0, 0 , StrZero(2,Len(DT8->DT8_CALMIN)),DT3->DT3_FAIXA, '', '', '', '', 0, '','' } )
					EndIf
					Exit
				EndIf
			Else
				If	!Empty(aMsgErr)
					Exit
				EndIf
			EndIf
		EndIf

		//-- Componente de frete que determina o peso cobrado
		If	DT3->DT3_CODPAS $ cPesCob
			nPesoCob := nPesComp
		EndIf

		//-- Aplica o desconto
		If	nDesconto > 0 .And. DT3->DT3_APLDES == StrZero( 1, Len( DT3->DT3_APLDES ) )
			nVlrComp := nVlrComp - ( nVlrComp * nDesconto / 100 )
		EndIf

		//-- Estabelece o Valor Minimo e Maximo do Componente.
		If	lMinimo .Or. nVlrComp < 0 .Or. nVlrComp > nValMax
			nVlrComp := Max( nVlrComp, nValMin )
			If nMinDYA > 0
				nVlrComp := Max( nVlrComp, nMinDYA )
			EndIf
			If	nVlrComp > nValMax
				nVlrComp := nValMax
			EndIf
			If (nVlrComp == nValMin  .Or. nVlrComp == nValMax)
				aRet[ Len(aRet), 15 ] := StrZero(1,Len(DT8->DT8_CALMIN))
			EndIf
		EndIf

		//-- Multiplicar o Valor do componente pela Quantidade informada para este Tipo de Veiculo
		//-- na Nota Fiscal / Cotacao / Solicitacao de Coleta
		If !Empty(DT3->DT3_TIPVEI) // Tipo do Veiculo
			nVlrComp *= nQtdTipVei
		EndIf

		If nMoedaTb == 0
			nMoedaTb := 1
		EndIf
		If nMoedaTb <> 1
			nVlrComp := xMoeda( nVlrComp, nMoedaTb, nMoeda )
		EndIf

		// Calculo de Excedente por subfaixa
		If Empty(aMsgErr) .And. !Empty(DT3->DT3_FAIXA2)
			cSeekTab := xFilial('DW1') + cTabFre + cTipTab + cCdrOri + cCdrDes + cCodPro + DT3->DT3_CODPAS + cRecDT1
			cSeekAju := xFilial('DW2') + cTabFre + cTipTab + cCdrOri + cCdrDes + cCodCli + cLojCli + cSeqTab + cCodPro + cServic + DT3->DT3_CODPAS + cRecDT1
			If ! Empty(cTabTar)
				cSeekTar := xFilial('DW0') + cTabFre + cTipTab + cTabTar + DT3->DT3_CODPAS + cRecDTG
				cSeekAju := xFilial('DW2') + cTabFre + cTipTab + cCdrOri + cCdrDes + cCodCli + cLojCli + cSeqTab + cCodPro + cServic + DT3->DT3_CODPAS + cRecDTG
			EndIf
			If Empty(aMsgErr)
				nVlrComp := TMSEx2Calc("DY1", cSeekTab, cSeekTar, cSeekAju, nBaseSobre, nVlrComp)
			EndIf
		EndIf

		aRet[ Len(aRet), 2 ] := nVlrComp

		//-- Verifica se deverá calcular o valor do componente praca por pedagio
		If nVlrComp > 0 .And. lPrcPdg .And. DT3->DT3_FAIXA == StrZero(9,Len(DT3->DT3_FAIXA))
			lPrcPdg := .F.
		EndIf


		(cAliasQry)->( DbSkip() )
	EndDo

	//-- Retorna o valor base dos componentes
	If !Empty(cBsComp)
		nValMer := nValMerAux
		nPeso   := nPesoAux
		nPesoM3 := nPesoM3Aux
		nQtdVol := nQtdVolAux
		nSeguro := nSeguroAux
		nMetro3 := nMetro3Aux
		nQtdUni := nQtdUniAux
		nValDpc := nValDpcAux
		nKm     := nKmAux
	EndIf
	//-- Ponto de entrada para calcular componentes com valores especificos
	If	lTMCALFRE
		//-- Parametros passados para o ponto de entrada
		//-- [01]			= Vetor com a composicao do frete
		//-- [02 ate 17]	= Base de calculo
		//-- [18]			= Codigo do cliente devedor (pode estar em branco quando calculado pelo generico ou sem ajuste)
		//-- [19]			= Loja do cliente devedor (pode estar em branco quando calculado pelo generico ou sem ajuste)
		//-- [20]			= Codigo da regiao de origem
		//-- [21]			= Codigo da regiao de destino
		//-- [22]			= Codigo do produto
		//-- [23]			= Codigo do servico de negociacao
		//-- [24]			= Tabela de Frete
		//-- [25]			= Tipo da Tabela de Frete
		//-- [26]			= Sequencia da Tabela de Frete
		//-- [27]			= Dias de Armazenagem
		//-- [28]			= Notas Fiscais (aNfCTRC)
		//-- [29]			= Numero do Lote
		//-- [30]			= Codigo do cliente devedor original
		//-- [31]			= Loja do cliente devedor original
		aTmCalFr := ExecBlock('TMCALFRE',.F.,.F.,{aRet,nQtdVol,nValMer,nPeso,nPesoM3,nMetro3,nSeguro,nQtdDco,nDiaSem,nKm,nPerNoi,nQtdEnt,nQtdUni,nValDpc,nDocSImp,nDocCImp,nDiaFimSem,cCodCli,cLojCli,cOriAux,cDesAux,cCodPro,cServic,cTabFre,cTipTab,cSeqTab,nDiaArm,aNfCTRC,cLotNfc,aInfoAnt[4],aInfoAnt[5],cCodNeg})
		If	ValType(aTmCalFr)=='A'
			//-- Formato do vetor aTmCalFr. Retorno do ponto de entrada TMCALFRE
			//-- [01] = Codigo do componente
			//-- [02] = Valor do componente

			//-- Preenche o vetor aret com o retorno do ponto de entrada
			DT3->(DbSetOrder( 1 ))
			For nCntFor := 1 To Len(aTmCalFr)
				If	ValType(aTmCalFr[nCntFor,1])=='C' .And. ValType(aTmCalFr[nCntFor,2])=='N'
					//-- Posiciona o componente de frete
					If DT3->(MsSeek(xFilial('DT3') + aTmCalFr[nCntFor,1]))
						//-- Pesquisa o componente no vetor aret
						nSeek := AScan(aRet,{|x|x[3]==aTmCalFr[nCntFor,1]})
						If	nSeek <= 0
							AAdd( aRet, { '', 0, '', '', 0, 0, Space(Len(cCdrOri)), Space(Len(cCdrDes)), '', '', '','00', 0, 0 , StrZero(2,Len(DT8->DT8_CALMIN)),DT3->DT3_FAIXA, '', '', '', '', 0, '','' } )
							nSeek := Len(aRet)
						EndIf
						aRet[nSeek,01] := AllTrim(DT3->DT3_DESCRI)
						aRet[nSeek,02] := aTmCalFr[nCntFor,2]
						aRet[nSeek,03] := aTmCalFr[nCntFor,1]
						aRet[nSeek,07] := '(*)' //-- Uma marca apenas para identificar q este componente foi calculado atraves do ponto de entrada
						aRet[nSeek,08] := ''
						aRet[nSeek,09] := ''
						aRet[nSeek,10] := ''
						aRet[nSeek,11] := ''
						aRet[nSeek,13] := 0
						aRet[nSeek,14] := 0
					Else
						If lMsgErr
							AAdd( aMsgErr, { STR0056 + aTmCalFr[nCntFor,1] + STR0057, '02', 'TMSA030()' } ) //"Componente de frete "###" não encontrado. (DT3) "
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	nCntFor := 0
	//-- Obtem o total do frete, somando todos os itens do vetor aRet
	AEval( aRet, {|x| nCntFor += x[ 2 ] })
	//-- Cria a linha de total do frete
	AAdd( aRet, {STR0070, nCntFor, 'TF', '', 0, 0, Space(Len(cCdrOri)), Space(Len(cCdrDes)),'','','', 'ZZ', 0, 0 , StrZero(2,Len(DT8->DT8_CALMIN)),0, '', '', '', '', 0, '','' } ) //"Total do Frete"

	ASort(aRet,,,{|x,y| x[12] + x[3] < y[12] + y[3] })
Else
	If Empty( cTabFre )
		If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '07' } ) == 0
			AAdd( aMsgErr, {STR0071 + Iif( lCliGen, STR0072, STR0073 + cCodCli + '/' + cLojCli ) + STR0074 + cServic, '07', 'TECA250()' } ) //"Tabela de frete não especificada no contrato do "###"cliente generico "###"cliente/loja: "###" para o servico: "
		EndIf
	Else
		If lMsgErr .And. Ascan( aMsgErr, { |x| x[ 2 ] == '08' } ) == 0
			AAdd( aMsgErr, {STR0075 + cTabFre + STR0076 + cTipTab + STR0077, '08', 'TMSA130()' } ) //"Configuração da tabela de frete "###" Tipo Tab. "###" não encontrado. (DTL)"
		EndIf
	EndIf

EndIf

(cAliasQry)->( DbCloseArea() )

RestArea(aAreaAnt)
RestArea(aAreaDYA)

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsBaseCal³ Autor ³ Alex Egydio           ³ Data ³05.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem o valor base p/o calculo, conforme o tipo da faixa   ³±±
±±³          ³ do componente                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Valores informados                                 ³±±
±±³          ³ ExpC1 = Componente de frete                                ³±±
±±³          ³ ExpC2 = Contrato                                           ³±±
±±³          ³ ExpC3 = Servico                                            ³±±
±±³          ³ ExpL1 = .T. = Calculado pelo peso real                     ³±±
±±³          ³ ExpN1 = Volume                                             ³±±
±±³          ³ ExpN2 = Valor                                              ³±±
±±³          ³ ExpN3 = Peso real                                          ³±±
±±³          ³ ExpN4 = Peso cubado                                        ³±±
±±³          ³ ExpN5 = Metro cubico                                       ³±±
±±³          ³ ExpN6 = Seguro                                             ³±±
±±³          ³ ExpN7 = Qtde. de Documentos                                ³±±
±±³          ³ ExpN8 = No. de Diarias ( Semana )                          ³±±
±±³          ³ ExpN9 = Kms Percorridos                                    ³±±
±±³          ³ ExpNA = Qtde. de Pernoites                                 ³±±
±±³          ³ ExpNB = Qtde. de Entregas                                  ³±±
±±³          ³ ExpNC = Quantidade de unitizadores                         ³±±
±±³          ³ ExpND = Valor CTRC Despachante                             ³±±
±±³          ³ ExpNE = Valor Docto. sem Imposto                           ³±±
±±³          ³ ExpNF = Valor Docto. com Imposto                           ³±±
±±³          ³ ExpC4 = Regiao Origem                                      ³±±
±±³          ³ ExpC5 = Regiao Destino                                     ³±±
±±³          ³ ExpC6 = Tipo de Transporte                                 ³±±
±±³          ³ ExpNG = No. de Diarias ( Fim de Semana )                   ³±±
±±³          ³ ExpC7 = Campo a ser verificado (DT3_TIPFAI / DT3_FAIXA)    ³±±
±±³          ³ ExpA2 = Altura / Largura / Comprimento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Valor base                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsBaseCal(aValInf,cCodPas,cNContr,cServic,lPesoReal,nQtdVol,nValor,nPeso,nPesoM3,nMetro3,nSeguro,nQtdDco,;
					nDiaSem,nKm,nPerNoi,nQtdEnt,nQtdUni,nValDpc,nDocSImp,nDocCImp,cCdrOri,cCdrDes,cTipTra,nDiaFimSem,;
                    cCampo,cCodCli,cLojCli,aPesCub,aRet,nQtdCol,nRecDT3, lCmpRat, aBaseRat, cCodNeg, cTabFre , cTipTab , cCodPro )
Local aAreaAnt  := GetArea()
Local aAreaDT3  := DT3->(GetArea())
Local nLenFaixa := 0
Local nRet      := 0
Local nSeek     := 0
Local nX        := 0
Local cSeekDVY  := ""
Local cSeekDWZ  := ""
Local lContinua := .T.

DEFAULT aValInf    := {}
DEFAULT nMetro3    := 0
DEFAULT nSeguro    := 0
DEFAULT nQtdDco    := 0
DEFAULT nDiaSem    := 0
DEFAULT nKm        := 0
DEFAULT nPerNoi    := 0
DEFAULT nQtdEnt    := 0
DEFAULT nQtdUni    := 0
DEFAULT nValDpc    := 0
DEFAULT nDocSImp   := 0
DEFAULT nDocCImp   := 0
DEFAULT cCdrOri    := ''
DEFAULT cCdrDes    := ''
DEFAULT cTipTra    := ''
DEFAULT nDiaFimSem := 0
DEFAULT cCampo     := "DT3_TIPFAI"
DEFAULT aPesCub    := {}
DEFAULT aRet       := {}
DEFAULT nQtdCol    := 0
DEFAULT nRecDT3    := 0
Default lCmpRat    := .F.
Default aBaseRat   := {}
Default cCodNeg    := ""
Default cTabFre	   := ""
Default cTipTab	   := ""
Default cCodPro	   := ""

If lCmpRat .And. ( Len(aBaseRat) > 0 )
	// Base Calc.Ra : 3=Consolidado
	// E
	// 1=Nao Utiliza;2=Orig/Dest;3=Maior Vlr.Comp;4=Maior Peso Real		 //
	// 5=Maior Peso M3;6=Maior Vlr.Merc;7=Maior Vol;8=Maior KM;9=Maior M3//
	// A=Orig/Dest Vge;B=Maior Peso Previsto;C=Maior Peso Previsto x Realizado
	If	(aBaseRat[08][01] == StrZero(3, Len(DTP->DTP_BACRAT))) .And.;
		(	aBaseRat[08][02] $ '4/5/6/7/8/9/B/C' )

		Do Case
			Case aBaseRat[08][02] == StrZero(4, Len(DTP->DTP_CRIRAT)) // Maior Peso Real
				nPeso := aBaseRat[03]
			Case aBaseRat[08][02] == StrZero(5, Len(DTP->DTP_CRIRAT)) // Maior Peso M3
				nPesoM3 := aBaseRat[04]
			Case aBaseRat[08][02] == StrZero(6, Len(DTP->DTP_CRIRAT)) // Maior Vlr.Merc
				nValor := aBaseRat[05]
			Case aBaseRat[08][02] == StrZero(7, Len(DTP->DTP_CRIRAT)) // Maior Vol
				nQtdVol := aBaseRat[02]
			Case aBaseRat[08][02] == StrZero(8, Len(DTP->DTP_CRIRAT)) // Maior KM
				nKm := aBaseRat[07]
			Case aBaseRat[08][02] == StrZero(9, Len(DTP->DTP_CRIRAT)) // Maior M3
				nMetro3 := aBaseRat[06]
			//------------ verificar com Adalberto se ok ----------------
			Case aBaseRat[08][02] == 'B' // Maior Peso Previsto
				nPeso := aBaseRat[09]
			Case aBaseRat[08][02] == 'C' // Maior Peso Previsto x Realizado
				nPeso := aBaseRat[10]
		EndCase
	EndIf
EndIf

cCampo    := "DT3->"+cCampo
nLenFaixa := Len(&cCampo)

//-- Posiciona no componente de frete
DT3->( DbSetOrder( 1 ) )
If nRecDT3 > 0
	DT3->( dbGoto(nRecDT3) )
Else
	lContinua := DT3->( MsSeek( xFilial('DT3') + cCodPas ) )
EndIf

If	lContinua
	If	&cCampo == StrZero( 1 , nLenFaixa ) .Or. ;	//-- Faixa Por Peso
		&cCampo == StrZero( 51, nLenFaixa ) .Or. ;	//-- Faixa Por Peso Transportado (frete a pagar)
		&cCampo == StrZero( 62, nLenFaixa )			//-- Faixa Por Peso Mercadoria (frete a pagar)

		//-- Verifica se o componente sera calculado pelo peso real ou peso cubado ou metro cubico
		nRet := TmsRetPeso( cNContr, cServic, cCodPas, @lPesoReal, nPeso, nPesoM3, nMetro3,,, cCodNeg )
	ElseIf	&cCampo == StrZero( 2, nLenFaixa ) .Or. ;		//-- Valor
		&cCampo == StrZero( 63, nLenFaixa ) 		//-- Valor Mercadoria (frete a pagar)
		nRet := nValor
	ElseIf	&cCampo == StrZero( 3, nLenFaixa ) .Or. ;		//-- Volume
		&cCampo == StrZero( 64, nLenFaixa )			//-- Volume Mercadoria (frete a pagar)
		nRet := nQtdVol
	ElseIf	&cCampo == StrZero( 4, nLenFaixa )				//-- Seguro
		nRet := nSeguro
	ElseIf	&cCampo == StrZero( 5, nLenFaixa ) .Or. ;		//-- Quantidade de unitizadores
		&cCampo == StrZero( 65, nLenFaixa )			//-- Quantidade de Unitizador
		nRet := nQtdUni
	ElseIf	&cCampo == StrZero( 6, nLenFaixa )				//-- Frete despachante
		nRet := nValDpc
	ElseIf	&cCampo == StrZero( 7, nLenFaixa )				//-- Valor informado
		nSeek := AScan(aValInf,{|x|x[1]==cCodPas})
		If	nSeek > 0 .And. !aValInf[nSeek,3]
			nRet := aValInf[nSeek,2]
		EndIf
	ElseIf	&cCampo == StrZero( 8, nLenFaixa )				//-- Km (Frete a Receber)
		If nKm > 0
			nRet := nKm
		Else
			nRet := TMSDistRot(, .F., cCdrOri, cCdrDes, cTipTra,cCodCli,cLojCli)
		EndIf
	ElseIf	&cCampo == StrZero( 10, nLenFaixa ) .And. !Empty(aPesCub) //-- Altura
		For nX := 1 To Len(aPesCub)
			nRet += aPesCub[nX][7]
		Next
	ElseIf	&cCampo == StrZero( 11, nLenFaixa )				//-- Largura
		For nX := 1 To Len(aPesCub)
			nRet += aPesCub[nX][8]
		Next
	ElseIf	&cCampo == StrZero( 12, nLenFaixa )				//-- Comprimento
		For nX := 1 To Len(aPesCub)
			nRet += aPesCub[nX][9]
		Next
	ElseIf	&cCampo == StrZero( 13, nLenFaixa )				//-- TDA
		For nX := 1 To Len(aRet)
			If !(aRet[nX,16] $ "13/14")
				//-- Base Componente TDA
				DVY->(DbSetOrder(1)) //DVY_FILIAL+DVY_TABFRE+DVY_TIPTAB+DVY_CDRORI+DVY_CDRDES+DVY_CODPRO+DVY_CODPAS
				If aRet[nX,11] == StrZero(0,Len(DWZ->DWZ_SEQTAB))
				    If Empty(aRet[nX,17])
				        aRet[nX,17] := space(len(DVY->DVY_CODPRO))
				    EndIf
					cSeekDVY := xFilial('DVY') + aRet[nX,09] + aRet[nX,10] + aRet[nX,07] + aRet[nX,08] + aRet[nX,17] + aRet[nX,03]
					If	DVY->( MsSeek( cSeekDVY ) )
						//-- Valor Base TDA
						nRet += (aRet[nX,2] * DVY->DVY_VLBASE / 100)
					EndIf
				Else
					//-- Base Componente TDA (Ajustes)
					DWZ->(DbSetOrder(1)) //DWZ_FILIAL+DWZ_CODCLI+DWZ_LOJCLI+DWZ_TABFRE+DWZ_TIPTAB+DWZ_CDRORI+DWZ_CDRDES+DWZ_SEQTAB+DWZ_CODPRO+DWZ_SERVIC+DWZ_CODPAS+DWZ_CODNEG(quando utilizar )
					cSeekDWZ := xFilial('DWZ') + aRet[nX,19] + aRet[nX,20] + aRet[nX,09] + aRet[nX,10] + aRet[nX,07] + aRet[nX,08] + aRet[nX,11] + aRet[nX,17] + aRet[nX,18] + aRet[nX,03] + aRet[nX,22]
					If DWZ->( MsSeek( cSeekDWZ ) )
						cSeekDVY := xFilial('DVY') + aRet[nX,09] + aRet[nX,10] + aRet[nX,07] + aRet[nX,08] + aRet[nX,17] + aRet[nX,03]
						If DVY->( MsSeek( cSeekDVY ) )
							//-- Valor Base TDA Ajustado
							nRet += (aRet[nX,2] * (DVY->DVY_VLBASE * (DWZ->DWZ_VLAJUS / 100 ) / 100))
						EndIf
					EndIf
				EndIf
			EndIf
		Next

	ElseIf	&cCampo == StrZero( 14, nLenFaixa )					//-- Sobre o % por componente

		For nX := 1 To Len(aRet)
			If aRet[nX,16] <> "14"
				nRet += RetBaseTRT(cTabFre, cTipTab, cCdROri , cCdRDes , cCodPro , DT3->DT3_CODPAS , aRet[nX,3] , aRet[nX,2] ,  aRet[nX,19],  aRet[nX,20] , aRet[nX,11] , aRet[nX,18] , aRet[nX,22]  )
			EndIf
		Next

	ElseIf	&cCampo == StrZero( 52, nLenFaixa )					//-- Qtde. Doctos.
		nRet := nQtdDco
	ElseIf	&cCampo == StrZero( 53, nLenFaixa )					//-- Volume Transportado
		nRet := nQtdVol
	ElseIf	&cCampo == StrZero( 54, nLenFaixa )					//-- No. de Diarias ( Semana )
		nRet := nDiaSem
	ElseIf	&cCampo == StrZero( 55, nLenFaixa )					//-- Km (Frete a Pagar)
		nRet := nKm
	ElseIf	&cCampo == StrZero( 56, nLenFaixa )					//-- Pernoite
		nRet := nPerNoi
	ElseIf	&cCampo == StrZero( 57, nLenFaixa )					//-- Documento sem imposto
		nRet := nDocSImp
	ElseIf	&cCampo == StrZero( 58, nLenFaixa )					//-- Documento com imposto
		nRet := nDocCImp
	ElseIf	&cCampo == StrZero( 59, nLenFaixa )					//-- Qtde. de Entregas
		nRet := nQtdEnt
	ElseIf	&cCampo == StrZero( 60, nLenFaixa )					//-- No. de Diarias ( Fim de Semana )
		nRet := nDiaFimSem
	ElseIf	&cCampo == StrZero( 61, nLenFaixa )					//-- Valor informado
		nSeek := AScan(aValInf,{|x|x[1]==cCodPas})
		If	nSeek > 0 .And. !aValInf[nSeek,3]
			nRet := aValInf[nSeek,2]
		EndIf
	ElseIf	&cCampo == StrZero( 66, nLenFaixa )					//-- Qtde. de Coletas
		nRet := nQtdCol
	EndIf
EndIf

RestArea(aAreaDT3)
RestArea(aAreaAnt)

Return( nRet )


/*/{Protheus.doc} RetBaseTRT
//Retorna a base de cálculo do TRT
@author Caio Murakami
@since 01/03/2017
@version undefined

@type function
/*/
Static Function RetBaseTRT(cTabFre, cTipTab, cCdROri , cCdRDes , cCodPro , cCodTRT , cCodPas , nValBase, cCodCli, cLojCli, cSeqTab, cServic, cCodNeg )
Local aArea		:= GetArea()
Local cSeekDJT	:= ""

Default cTabFre		:= ""
Default cTipTab		:= ""
Default cCdROri		:= ""
Default cCdRDes		:= ""
Default cCodPro		:= ""
Default cCodTRT		:= ""
Default cCodPas		:= ""
Default nValBase	:= 0
Default cCodCli		:= ""
Default cLojCli		:= ""
Default cSeqTab		:= ""
Default cServic		:= ""
Default cCodNeg		:= ""

If AliasInDic("DJS")

	If cSeqTab == StrZero(0,Len(DJT->DJT_SEQTAB))
		If DJS->( MsSeek( xFilial("DJS") + cTabFre + cTipTab + cCdROri + cCdRDes + cCodPro + cCodTRT + cCodPas ))
			nValBase 	:= Round( ( nValBase * DJS->DJS_PERCEN ) / 100 , 2 )
		Else
			If DJS->( MsSeek( xFilial("DJS") + cTabFre + cTipTab + cCdROri + cCdRDes + Space(Len(SB1->B1_COD)) + cCodTRT + cCodPas ))
				nValBase 	:= Round( ( nValBase * DJS->DJS_PERCEN ) / 100 , 2 )
			EndIf
		EndIf

	Else
		//--DJT_FILIAL+DJT_CODCLI+DJT_LOJCLI+DJT_TABFRE+DJT_TIPTAB+DJT_CDRORI+DJT_CDRDES+DJT_SEQTAB+DJT_CODPRO+DJT_SERVIC+DJT_CODTRT+DJT_CODPAS+DJT_CODNEG
		DJT->(dbSetOrder(1))
		cSeekDJT	:= xFilial('DJT') + cCodCli + cLojCli + cTabFre + cTipTab + cCdROri + cCdRDes + cSeqTab + cCodPro + cServic + cCodTRT + cCodPas + cCodNeg
		If DJT->( MsSeek(cSeekDJT ))
			nValBase	:= Round(( nValBase * DJT->DJT_VLBAJU ) / 100 , 2 )
		Else
			cSeekDJT	:= xFilial('DJT') + cCodCli + cLojCli + cTabFre + cTipTab + cCdROri + cCdRDes + cSeqTab + Space(Len(SB1->B1_COD))  + cServic + cCodTRT + cCodPas + cCodNeg
			If DJT->( MsSeek(cSeekDJT ))
				nValBase	:= Round(( nValBase * DJT->DJT_VLBAJU ) / 100 , 2 )
			EndIf
		EndIf
	EndIf

EndIf

RestArea(aArea)
Return nValBase

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ TmsKeyOff ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Zera Teclas de Atalhos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsKeyOff(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo as teclas de atalhos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsKeyOff( aSetKey )

Local nCnt

For nCnt := 1 To Len( aSetKey )
	SetKey ( aSetKey[nCnt,1], Nil )
Next nCnt

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ TmsKeyOn  ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Zera Teclas de Atalhos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsKeyOn(ExpA1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo as teclas de atalhos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsKeyOn( aSetKey )

Local nCnt

For nCnt := 1 To Len( aSetKey )
	SetKey ( aSetKey[nCnt,1], aSetKey[nCnt,2] )
Next nCnt

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsTabUso³ Autor ³ Alex Egydio            ³ Data ³29.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a tabela de frete esta em uso por um CTRC, AWB ³±±
±±³          ³ ou cotacao de frete nao cancelada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabela de frete                                    ³±±
±±³          ³ ExpC2 = Tipo da tabela de frete                            ³±±
±±³          ³ ExpC3 = Codigo da regiao de origem                         ³±±
±±³          ³ ExpC4 = Codigo da regiao de destino                        ³±±
±±³          ³ ExpL1 = .T. = Envia help                                   ³±±
±±³          ³ ExpC5 = Categ. da Tabela: 1-Frete a Receber/2-Frete a Pagar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se a tabela estiver em uso por algum documento         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTabUso(cTabFre,cTipTab,cCdrOri,cCdrDes,lHelp,cCatTab)

Local aAreaAnt	:= GetArea()
Local aAreaDT4	:= DT4->(GetArea())
Local aAreaDT8	:= DT8->(GetArea())
Local aAreaDTR	:= DTR->(GetArea())
Local cAliasNew := ''
Local cNumCot	:= Space(Len(DT8->DT8_NUMCOT))
Local cQuery	:= ''
Local cSeqTab	:= StrZero(0,Len(DT8->DT8_SEQTAB))
Local lRet		:= .F.

DEFAULT lHelp	:= .T.
DEFAULT cCatTab:= StrZero(1, Len(DTL->DTL_CATTAB)) // Frete a Receber

//-- Verifica se ha CTRC ou AWB utilizando a tabela de frete( mae ou ajuste )
cAliasNew:=GetNextAlias()
cQuery := " SELECT COUNT(*) DT8_COUNT"
cQuery += " FROM"
cQuery += " "+RetSqlName('DT8')
cQuery += " WHERE"
cQuery += " D_E_L_E_T_     = ' '"
cQuery += " AND DT8_FILIAL = '"+xFilial("DT8")+"'"
cQuery += " AND DT8_TABFRE = '"+cTabFre+"'"
cQuery += " AND DT8_TIPTAB = '"+cTipTab+"'"
If !Empty(cCdrOri)
	cQuery += " AND DT8_CDRORI = '"+cCdrOri+"'"
EndIf
If !Empty(cCdrDes)
	cQuery += " AND DT8_CDRDES = '"+cCdrDes+"'"
EndIf
cQuery += " AND DT8_NUMCOT = '"+cNumCot+"'"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
If	(cAliasNew)->DT8_COUNT > 0
	lRet := .T.
	If	lHelp
	   If cCatTab == StrZero(1, Len(DTL->DTL_CATTAB)) // Frete a Receber
			Help('',1,'TMSA01002')	//-- Existe CTRC utilizando esta tabela
		ElseIf cCatTab == StrZero(2, Len(DTL->DTL_CATTAB)) // Frete a Pagar
			Help('',1,'TMSXFUNB38')	//-- Existe AWB utilizando esta tabela
		EndIf
	EndIf
EndIf
DbSelectArea(cAliasNew)
DbCloseArea()
If ! lRet
   If cCatTab == StrZero(1, Len(DTL->DTL_CATTAB)) // Frete a Receber
		//-- Verifica se ha Cotacoes nao canceladas utilizando a tabela de frete
		cAliasNew:=GetNextAlias()
		cQuery := " SELECT COUNT(*) DT4_COUNT"
		cQuery += " FROM"
		cQuery += " "+RetSqlName('DT4')
		cQuery += " WHERE"
		cQuery += " D_E_L_E_T_     = ' '"
		cQuery += " AND DT4_FILIAL = '"+xFilial("DT4")+"'"
		cQuery += " AND DT4_TABFRE = '"+cTabFre+"'"
		cQuery += " AND DT4_TIPTAB = '"+cTipTab+"'"
		cQuery += " AND DT4_SEQTAB = '"+cSeqTab+"'"
		If !Empty(cCdrOri)
			cQuery += " AND DT4_CDRORI = '"+cCdrOri+"'"
		EndIf
		If !Empty(cCdrDes)
			cQuery += " AND DT4_CDRDES = '"+cCdrDes+"'"
		EndIf
		cQuery += " AND DT4_STATUS <> '9'"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
		If	(cAliasNew)->DT4_COUNT > 0
			lRet := .T.
			If	lHelp
				Help('',1,'TMSA01003')	//-- Existe Cotacao de Frete utilizando esta tabela
			EndIf
		EndIf
	ElseIf cCatTab == StrZero(2, Len(DTL->DTL_CATTAB)) // Frete a Pagar
		cAliasNew:=GetNextAlias()
		cQuery := " SELECT COUNT(*) DTR_COUNT"
		cQuery += " FROM"
		cQuery += " "+RetSqlName('DTR') + " DTR"
		If !Empty(cCdrOri) .And. !Empty(cCdrDes)
			cQuery += " JOIN " +RetSqlName('DUD') + " DUD "
			cQuery += " ON DUD.DUD_FILIAL = '"+xFilial("DUD")+"' "
			cQuery += " AND DUD.DUD_FILORI = DTR.DTR_FILORI "
			cQuery += " AND DUD.DUD_VIAGEM = DTR.DTR_VIAGEM "
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += " JOIN " +RetSqlName('DT6') + " DT6 "
			cQuery += " ON DT6.DT6_FILIAL = '"+xFilial("DT6")+"' "
			cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
			cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
			cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
			cQuery += " AND DT6.DT6_CDRORI = '" +cCdrOri+ "'"
			cQuery += " AND DT6.DT6_CDRDES = '" +cCdrDes+ "'"
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += " WHERE"
		cQuery += " DTR.D_E_L_E_T_     = ' '"
		cQuery += " AND DTR.DTR_FILIAL = '"+xFilial("DTR")+"'"
		cQuery += " AND DTR.DTR_TABFRE = '"+cTabFre+"'"
		cQuery += " AND DTR.DTR_TIPTAB = '"+cTipTab+"'"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
		If	(cAliasNew)->DTR_COUNT > 0
			lRet := .T.
			If	lHelp
				Help('',1,'TMSXFUNB39')	//-- Existe Complemento de Viagem utilizando esta Tabela de Frete ...
			EndIf
		EndIf
	EndIf
	DbSelectArea(cAliasNew)
	DbCloseArea()
EndIf

RestArea(aAreaDT4)
RestArea(aAreaDT8)
RestArea(aAreaDTR)
RestArea(aAreaAnt)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsValInf³ Autor ³ Alex Egydio            ³ Data ³12.05.2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digitacao do valor informado                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor contendo os componentes de frete do tipo       ³±±
±±³          ³ (valor informado), com o valor base digitado na cotacao ou   ³±±
±±³          ³ na entrada de nf do cliente                                  ³±±
±±³          ³ ExpC1 = '1' = Digitacao pela cotacao de frete                ³±±
±±³          ³         '2' = Digitacao pela entrada de nf do cliente        ³±±
±±³          ³         '3' = Inicializa aValInf na alteracao da cotacao     ³±±
±±³          ³               de frete(tmsa040)                              ³±±
±±³          ³         '4' = Inicializa aValInf na visualizacao da entrada  ³±±
±±³          ³               de notas fiscais do cliente(tmsa050)           ³±±
±±³          ³         '5' = Inicializa aValInf no calculo do frete(tmsa200)³±±
±±³          ³         '6' = Digitacao pelo docto de complemento(tmsa500)   ³±±
±±³          ³         '7' = Inicializa aValInf na visualizacao do docto    ³±±
±±³          ³               de complemento(tmsa500)                        ³±±
±±³          ³ ExpC2 = Filial de origem                                     ³±±
±±³          ³ ExpC3 = Numero da cotacao de frete                           ³±±
±±³          ³ ExpC4 = Nr. do lote de digitacao de nf do cliente            ³±±
±±³          ³ ExpC5 = Cliente remetente                                    ³±±
±±³          ³ ExpC6 = Loja remetente                                       ³±±
±±³          ³ ExpC7 = Cliente destinatario                                 ³±±
±±³          ³ ExpC8 = Loja destinatario                                    ³±±
±±³          ³ ExpC9 = Codigo do servico                                    ³±±
±±³          ³ ExpCA = Nota fiscal do cliente                               ³±±
±±³          ³ ExpCB = Serie nf do cliente                                  ³±±
±±³          ³ ExpCC = Produto                                              ³±±
±±³          ³ ExpN1 = Opcao de manutencao                                  ³±±
±±³          ³ ExpCD = Viagem                                               ³±±
±±³          ³ ExpCE = Tabela de Frete                                      ³±±
±±³          ³ ExpCF = Tipo da Tabela de Frete                              ³±±
±±³          ³ ExpA2 = Vetor para Get Dados Automatica                      ³±±
±±³          ³ ExpCG = Codigo da Negociacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ vetor aValInf com a digitacao do valor informado             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsValInf(aValInf,cAcao,cFilOri,cNumCot,cLotNfc,cCliRem,cLojRem,cCliDes,;
					 cLojDes,cServic,cNumNfc,cSerNfc,cCodPro,nOpcx,cViagem,cTabFre,cTipTab,aAutoVInf,cCodNeg)
Local aCmpInf      := {}
Local aDelInf      := {}
Local cCampo       := ""
Local cSeek        := ""
Local nCntFor      := 0
Local nItem        := 0
Local nOpcA        := 0
Local nSeek        := 0
Local oDlgCmp
Local aSomaButtons := {}
Local lTabDFI      := nModulo<>43
Local cIdent       := ""

Local aNoFields    := {}
Local aBkpCols     := {}
Local cQuery       := ""
Local cAliasQry    := ""
Local lAutoDVT     := .F.
Local cRotOri      := ""  //-- Tratamento Rentabilidade/Ocorrencia
Local lCpoOri      := .f. //-- Tratamento Rentabilidade/Ocorrencia
SaveInter()

//-- GetDados
Private aKeyCmp  := {}
Private aHeader  := {}
Private aCols    := {}
Private aColsAux := {}
Private oGetCmp

DEFAULT aValInf   := {}
DEFAULT cCodPro   := Space(Len(SB1->B1_COD))
DEFAULT cTabFre   := ''
DEFAULT cTipTab   := ''
DEFAULT aAutoVInf := {}
DEFAULT cServic   := ""
DEFAULT cCodNeg   := ""

// -- P.E. para Adicionar Botoes na Enchoice do Valor Informado.
If ExistBlock('TMSXFBUT')
	aSomaButtons:=ExecBlock('TMSXFBUT',.F.,.F.,{cAcao})
	// Caso o retorno nao seja em array zera o retorno com array vazio
	If ValType(aSomaButtons) # 'A'
		aSomaButtons := {}
	EndIf
EndIf

//-- Valor informado x cotacao de frete
If cAcao == '1'
	//-- Preenche aHeader
	aDVQFields := ApBuildHeader("DVQ")

    For nCntFor := 1 to Len(aDVQFields)
        cCampo := AllTrim(aDVQFields[nCntFor][2])
        If cCampo $ 'DVQ_CODPAS.DVQ_DESPAS.DVQ_VALOR'
            AAdd( aHeader, aDVQFields[nCntFor])
        EndIf
    Next

	lAutoDVT := Len(aAutoVInf) > 0
	aCols := {}
	If !lAutoDVT
		//-- Preenche aCols baseado na digitacao de valor informado x cotacao de frete
		nSeek := AScan(aValInf,{|x|x[4]+x[6]==cNumCot+cCodPro})
		If	Empty(nSeek)
			DVQ->(DbSetOrder(1))
			If	DVQ->(MsSeek(cSeek:=xFilial('DVQ')+cFilOri+cNumCot))
				While DVQ->(!Eof() .And. DVQ->DVQ_FILIAL + DVQ->DVQ_FILORI + DVQ->DVQ_NUMCOT == cSeek)
					If	AScan(aValInf,{|x|x[4]+x[6]+x[1]==DVQ->DVQ_NUMCOT + DVQ->DVQ_CODPRO + DVQ->DVQ_CODPAS })==0
						AAdd(aValInf,{DVQ->DVQ_CODPAS,DVQ->DVQ_VALOR,.F.,DVQ->DVQ_NUMCOT,'',DVQ->DVQ_CODPRO})
					EndIf
					If	DVQ->DVQ_NUMCOT + DVQ->DVQ_CODPRO == cNumCot + cCodPro
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
						nItem := Len(aCols)
						GDFieldPut('DVQ_CODPAS',DVQ->DVQ_CODPAS,nItem)
						GDFieldPut('DVQ_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+DVQ->DVQ_CODPAS,'DT3_DESCRI'),nItem)
						GDFieldPut('DVQ_VALOR' ,DVQ->DVQ_VALOR,nItem)
						aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					EndIf
					DVQ->(DbSkip())
				EndDo
			Else
				//-- Obtem todos os componentes do tipo valor informado
				aCmpInf := TmsCompFre(StrZero(7,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab)
				If	! Empty(aCmpInf)
					For nCntFor := 1 To Len(aCmpInf)
						//-- Monta uma linha em branco
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
						nItem := Len(aCols)
						GDFieldPut('DVQ_CODPAS',aCmpInf[nCntFor,1],nItem)
						GDFieldPut('DVQ_DESPAS',aCmpInf[nCntFor,2],nItem)
						GDFieldPut('DVQ_VALOR' ,0,nItem)
						aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					Next
				EndIf
			EndIf
		//-- Preenche aCols baseado no vetor aValInf (antes de confirmar a cotacao)
		Else
			//-- Ha uma falha na apresentacao dos itens deletados na msgetdados, entao criamos a funcao tmsa011ajumin que
			//-- trabalha em conjunto com o vetor aColsAux para corrigir a falha.
			//-- A funcao tmsa011ajumin tem que receber:
			//-- Um aCols, onde todas as linhas estao com a coluna de deletado igual a .F.
			//-- Um aColsAux, indicando quais linhas estao deletadas.
			aColsAux := {}
			For nCntFor := 1 To Len(aValInf)
				If	aValInf[nCntFor,4]+aValInf[nCntFor,6]==cNumCot+cCodPro
					//-- Monta uma linha em branco
					AAdd( aCols, Array( Len( aHeader ) + 1 ) )
					nItem := Len(aCols)
					GDFieldPut('DVQ_CODPAS',aValInf[nCntFor,1],nItem)
					GDFieldPut('DVQ_DESPAS',Posicione('DT3',1,xFilial('DT3')+aValInf[nCntFor,1],'DT3_DESCRI'),nItem)
					GDFieldPut('DVQ_VALOR' ,aValInf[nCntFor,2],nItem)
					aCols[nItem,Len(aHeader)+1] := aValInf[nCntFor,3]
				EndIf
			Next
			aColsAux := AClone(aCols)
			For nCntFor := 1 To Len(aCols)
				aCols[ nCntFor, Len( aHeader ) + 1 ] := .F.
			Next
		EndIf
		//-- Monta uma linha em branco
		If	Empty(aCols)
			AAdd(aCols,Array(Len(aHeader)+1))
			For nCntFor := 1 To Len(aHeader)
				aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
			Next
			aCols[1,Len(aHeader)+1] := .F.
		EndIf
		aKeyCmp	 := {'DVQ_CODPAS'}					//-- Variavel utilizada pela funcao TmsLOkCmp()
		cCadastro := STR0078 //"Valor Informado"
		DEFINE MSDIALOG oDlgCmp TITLE cCadastro FROM 094,104 TO 310,590 PIXEL
			@ 018, 003 SAY FwX3Titulo('DT4_NUMCOT') SIZE 56 ,9 OF oDlgCmp PIXEL
			@ 018, 036 SAY cNumCot SIZE 56 ,9 OF oDlgCmp PIXEL

			@ 018, 090 SAY FwX3Titulo('DTC_CODPRO') SIZE 56 ,9 OF oDlgCmp PIXEL
			@ 018, 130 SAY cCodPro SIZE 100 ,9 OF oDlgCmp PIXEL
			//               MsGetDados(nT , nL,  nB,  nR,                 nOpc,   cLinhaOk,    cTudoOk,cIniCpos,lDeleta,    aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
			oGetCmp := MSGetDados():New( 30, 02, 105, 243, Iif(nOpcx>4,2,nOpcx),'TmsLOkCmp','TmsTOkCmp',,.T.)
			TMSA011AjuMin(aColsAux, aCols)
			oGetCmp:Refresh(.T.)
			//- Este tratamento eh utilizado pela relacionamento Agendamento X Cotacao (Carga Fechada)
			If nOpcx == 2 .Or. nOpcx == 5
				oGetCmp:oBrowse:bDelete := { || .f. }     // Nao Permite a deletar Linhas
			EndIf

			//-- Ajuste do Ponteiro da tabela da GetDados para nao
			//-- preencher indevidamente campos virtuais na adicao de novas linhas,
			//-- quando a operacao for de alteracao de registro.
			DVQ->(MsGoto(0))

		ACTIVATE MSDIALOG oDlgCmp ON INIT EnchoiceBar(oDlgCmp,{||Iif( oGetCmp:TudoOk(), (nOpca := 1,oDlgCmp:End()), nOpca :=0 )},{||nOpca:=0,oDlgCmp:End()},,aSomaButtons)
	Else
		aKeyCmp	 := {'DVQ_CODPAS'}					//-- Variavel utilizada pela funcao TmsLOkCmp()
		If MsGetDAuto(aAutoVInf,"TmsLOkCmp",Nil,/*aAutoCab*/,nOpcx)
			nOpca := 1
		EndIf
	EndIf
	If	nOpca == 1
		For nCntFor := 1 To Len(aCols)
			nSeek := AScan(aValInf,{|x|x[4]+x[6]+x[1]==cNumCot+cCodPro+GdFieldGet('DVQ_CODPAS',nCntFor)})
			If	nSeek > 0
				aValInf[nSeek,2]:= GdFieldGet('DVQ_VALOR',nCntFor)
				aValInf[nSeek,3]:= aCols[nCntFor,Len(aHeader)+1]
			Else
				AAdd(aValInf,{GdFieldGet('DVQ_CODPAS',nCntFor),GdFieldGet('DVQ_VALOR',nCntFor),aCols[nCntFor,Len(aHeader)+1],cNumCot,'',cCodPro})
			EndIf
		Next
	EndIf
//-- Valor informado x documento
ElseIf cAcao == '2'
	//Query passada na FillGetDados para preencher o aCols
	cQuery := "SELECT *"
	cQuery += " FROM " + RetSqlName("DVR")+ " DVR "
	cQuery += " WHERE DVR_FILIAL = '" + xFilial("DVR") + "'"
	cQuery += "   AND DVR_FILORI = '" + cFilOri + "'"
	cQuery += "   AND DVR_LOTNFC = '" + cNumNfc + "'"
	cQuery += "   AND DVR_CLIREM = '" + cCliRem + "'"
	cQuery += "   AND DVR_LOJREM = '" + cLojRem + "'"
	cQuery += "   AND DVR_CLIDES = '" + cCliDes + "'"
	cQuery += "   AND DVR_LOJDES = '" + cLojDes + "'"
	cQuery += "   AND DVR_CODNEG = '" + cCodNeg + "'"
	cQuery += "   AND DVR_SERVIC = '" + cServic + "'"
	cQuery += "   AND DVR_NUMNFC = '" + cNumNfc + "'"
	cQuery += "   AND DVR_SERNFC = '" + cSerNfc + "'"
	cQuery += "   AND DVR_CODPRO = '" + cCodPro + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"

	aNoFields := {"DVR_FILORI","DVR_LOTNFC","DVR_CLIREM","DVR_LOJREM","DVR_CLIDES","DVR_LOJDES","DVR_SERVIC","DVR_NUMNFC","DVR_SERNFC","DVR_CODPRO"}
	Aadd(aNoFields,"DVR_CODNEG")
	
	//-- Preenche aHeader

	FillGetDados(nOpcx,"DVR",1, /*cSeek*/, /*{|| &cWhile }*/, {||.T.}, aNoFields, /*aYesFields*/, /*lOnlyYes*/, cQuery, /*bMontCols*/)

	aBkpCols := aClone(aCols)
	aCols := {}

	//-- Preenche aCols baseado na digitacao de valor informado x documento
	nSeek := AScan(aValInf,{|x|x[4]+x[5]+x[6]==cNumNfc+cSerNfc+cCodPro})
	If	Empty(nSeek)
		DVR->(DbSetOrder(2)) //DVR_FILIAL+DVR_FILORI+DVR_LOTNFC+DVR_CLIREM+DVR_LOJREM+DVR_CLIDES+DVR_LOJDES+DVR_SERVIC+DVR_NUMNFC+DVR_SERNFC+DVR_CODPRO+DVR_CODPAS
		If	DVR->(MsSeek(cSeek:=xFilial('DVR')+cFilOri+cLotNfc+cCliRem+cLojRem+cCliDes+cLojDes+cCodNeg+cServic))
			While DVR->( ! Eof() .And. DVR->DVR_FILIAL+DVR->DVR_FILORI+DVR->DVR_LOTNFC+DVR->DVR_CLIREM+DVR->DVR_LOJREM+DVR->DVR_CLIDES+DVR->DVR_LOJDES+DVR->DVR_CODNEG+DVR->DVR_SERVIC == cSeek )
				If	AScan(aValInf,{|x|x[4]+x[5]+x[6]+x[1]==DVR->DVR_NUMNFC + DVR->DVR_SERNFC + DVR->DVR_CODPRO + DVR->DVR_CODPAS})==0
					AAdd(aValInf,{DVR->DVR_CODPAS,DVR->DVR_VALOR,.F.,DVR->DVR_NUMNFC,DVR->DVR_SERNFC,DVR->DVR_CODPRO})
				EndIf
				If	DVR->DVR_NUMNFC + DVR->DVR_SERNFC + DVR->DVR_CODPRO == cNumNfc + cSerNfc + cCodPro
					AAdd( aCols, Array( Len( aHeader ) + 1 ) )
					nItem := Len(aCols)
					GDFieldPut('DVR_CODPAS',DVR->DVR_CODPAS,nItem)
					GDFieldPut('DVR_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+DVR->DVR_CODPAS,'DT3_DESCRI'),nItem)
					GDFieldPut('DVR_VALOR' ,DVR->DVR_VALOR,nItem)
					GDFieldPut('DVR_ALI_WT',"DVR",nItem)
					GDFieldPut('DVR_REC_WT',DVR->(Recno()),nItem)
					aCols[ nItem, Len( aHeader ) + 1 ] := .F.
				EndIf
				DVR->(DbSkip())
			EndDo
		EndIf

		If	Empty(aCols) .And. nOpcx <> 2 .And. nOpcx <> 5
			//-- Obtem todos os componentes do tipo valor informado
			aCmpInf := TmsCompFre(StrZero(7,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab)
			If	! Empty(aCmpInf)
				For nCntFor := 1 To Len(aCmpInf)
					//-- Monta uma linha em branco
					AAdd( aCols, Array( Len( aHeader ) + 1 ) )
					nItem := Len(aCols)
					GDFieldPut('DVR_CODPAS',aCmpInf[nCntFor,1],nItem)
					GDFieldPut('DVR_DESPAS',aCmpInf[nCntFor,2],nItem)
					GDFieldPut('DVR_VALOR' ,0,nItem)
					GDFieldPut('DVR_ALI_WT',"DVR",nItem)
					GDFieldPut('DVR_REC_WT',0,nItem)
					aCols[ nItem, Len( aHeader ) + 1 ] := .F.
				Next
			EndIf
		EndIf
	//-- Preenche aCols baseado no vetor aValInf (antes de confirmar a entrada de nota fiscal do cliente)
	Else
		//-- Ha uma falha na apresentacao dos itens deletados na msgetdados, entao criamos a funcao tmsa011ajumin que
		//-- trabalha em conjunto com o vetor aColsAux para corrigir a falha.
		//-- A funcao tmsa011ajumin tem que receber:
		//-- Um aCols, onde todas as linhas estao com a coluna de deletado igual a .F.
		//-- Um aColsAux, indicando quais linhas estao deletadas.
		aColsAux := {}
		For nCntFor := 1 To Len(aValInf)
			If	aValInf[nCntFor,4]+aValInf[nCntFor,5]+aValInf[nCntFor,6]==cNumNfc+cSerNfc+cCodPro
				//-- Monta uma linha em branco
				AAdd( aCols, Array( Len( aHeader ) + 1 ) )
				nItem := Len(aCols)
				GDFieldPut('DVR_CODPAS',aValInf[nCntFor,1],nItem)
				GDFieldPut('DVR_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+aValInf[nCntFor,1],'DT3_DESCRI'),nItem)
				GDFieldPut('DVR_VALOR' ,aValInf[nCntFor,2],nItem)
				If Inclui
					GDFieldPut('DVR_ALI_WT',aValInf[nCntFor,7],nItem)
					GDFieldPut('DVR_REC_WT',aValInf[nCntFor,8],nItem)
				EndIf
				aCols[nItem,Len(aHeader)+1] := aValInf[nCntFor,3]
			EndIf
		Next

		//-- Exibir todos componentes de valor informado - Nao fazer para Visualziar e Estornar
		If	nOpcx <> 2 .And. nOpcx <> 5
			aCmpInf := TmsCompFre(StrZero(7,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab) // ASM 23/01/2012
		EndIf

		aColsAux := AClone(aCols)
		For nCntFor := 1 To Len(aCols)
			If	nOpcx <> 2 .And. !Empty(aCmpInf)
				nSeek := Ascan( aCmpInf, { |x| x[1] == aCols[nCntFor][1] } )
				If nSeek > 0
					aDel(aCmpInf, nSeek)
					aSize(aCmpInf,Len(aCmpInf)-1)
				EndIf
			EndIf
			aCols[ nCntFor, Len( aHeader ) + 1 ] := .F.
		Next

		If	nOpcx <> 2 .And. ! Empty(aCmpInf)
			For nCntFor := 1 To Len(aCmpInf)
				//-- Monta uma linha em branco
				AAdd( aCols, Array( Len( aHeader ) + 1 ) )
				nItem := Len(aCols)
				GDFieldPut('DVR_CODPAS',aCmpInf[nCntFor,1],nItem)
				GDFieldPut('DVR_DESPAS',aCmpInf[nCntFor,2],nItem)
				GDFieldPut('DVR_VALOR' ,0,nItem)
				GDFieldPut('DVR_ALI_WT',"DVR",nItem)
				GDFieldPut('DVR_REC_WT',0,nItem)
				aCols[ nItem, Len( aHeader ) + 1 ] := .F.
			Next
		EndIf
	EndIf
	//Se o aCols esta vazio, retorno o aCols(aBkpCols) que foi criado pela fillgetdados, que contem
	//o alias e o recno
	If	Empty(aCols)
		aCols := aClone(aBkpCols)
	EndIf

	aKeyCmp	 := {'DVR_CODPAS'}					//-- Variavel utilizada pela funcao TmsLOkCmp()
	cCadastro := STR0078 //'Valor Informado'
	DEFINE MSDIALOG oDlgCmp TITLE cCadastro FROM 094,104 TO 310,590 PIXEL
		@ 018, 003 SAY AllTrim(FwX3Titulo('DTC_NUMNFC')+' / '+ FwX3Titulo('DTC_SERNFC')) SIZE 56 ,9 OF oDlgCmp PIXEL
		@ 018, 056 SAY cNumNfc+' / '+cSerNfc SIZE 56 ,9 OF oDlgCmp PIXEL

		@ 018, 100 SAY FwX3Titulo('DTC_CODPRO') SIZE 56 ,9 OF oDlgCmp PIXEL
		@ 018, 140 SAY cCodPro SIZE 100 ,9 OF oDlgCmp PIXEL
		//               MsGetDados(nT , nL,  nB,  nR,                 nOpc,   cLinhaOk,    cTudoOk,cIniCpos,lDeleta,    aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
		oGetCmp := MSGetDados():New( 30, 02, 105, 243, Iif(nOpcx>4,2,nOpcx),'TmsLOkCmp','TmsTOkCmp',,.T.,,,,)
		TMSA011AjuMin(aColsAux, aCols)
		oGetCmp:Refresh(.T.)

	ACTIVATE MSDIALOG oDlgCmp ON INIT EnchoiceBar(oDlgCmp,{||Iif( oGetCmp:TudoOk(), (nOpca := 1,oDlgCmp:End()), nOpca :=0 )},{||nOpca:=0,oDlgCmp:End()},,aSomaButtons)

	If	nOpca == 1
		For nCntFor := 1 To Len(aCols)
			nSeek := AScan(aValInf,{|x|x[4]+x[5]+x[6]+x[1]==cNumNfc+cSerNfc+cCodPro+GdFieldGet('DVR_CODPAS',nCntFor)})
			If	nSeek > 0
				aValInf[nSeek,2]:= GdFieldGet('DVR_VALOR',nCntFor)
				aValInf[nSeek,3]:= aCols[nCntFor,Len(aHeader)+1]
			Else
				AAdd(aValInf,{GdFieldGet('DVR_CODPAS',nCntFor),GdFieldGet('DVR_VALOR',nCntFor),aCols[nCntFor,Len(aHeader)+1],cNumNfc,cSerNfc,cCodPro,GdFieldGet('DVR_ALI_WT',nCntFor),GdFieldGet('DVR_REC_WT',nCntFor)})
			EndIf
		Next
	EndIf
//-- Inicializa aValInf na alteracao da cotacao de frete(tmsa040)
ElseIf cAcao == '3'
	DVQ->(DbSetOrder(1))
	If	DVQ->(MsSeek(cSeek:=xFilial('DVQ')+cFilOri+cNumCot))
		While DVQ->(!Eof() .And. DVQ->DVQ_FILIAL + DVQ->DVQ_FILORI + DVQ->DVQ_NUMCOT == cSeek)
			AAdd(aValInf,{DVQ->DVQ_CODPAS,DVQ->DVQ_VALOR,.F.,DVQ->DVQ_NUMCOT,'',DVQ->DVQ_CODPRO,"DVQ",DVQ->(Recno())})
			DVQ->(DbSkip())
		EndDo
	EndIf
//-- Inicializa aValInf na visualizacao da entrada de notas fiscais do cliente(tmsa050)
ElseIf cAcao == '4'
	DVR->(DbSetOrder(2)) //DVR_FILIAL+DVR_FILORI+DVR_LOTNFC+DVR_CLIREM+DVR_LOJREM+DVR_CLIDES+DVR_LOJDES+DVR_SERVIC+DVR_NUMNFC+DVR_SERNFC+DVR_CODPRO+DVR_CODPAS
	If	DVR->(MsSeek(cSeek:=xFilial('DVR')+cFilOri+cLotNfc+cCliRem+cLojRem+cCliDes+cLojDes+cCodNeg+cServic))
		While DVR->( ! Eof() .And. DVR->DVR_FILIAL+DVR->DVR_FILORI+DVR->DVR_LOTNFC+DVR->DVR_CLIREM+DVR->DVR_LOJREM+DVR->DVR_CLIDES+DVR->DVR_LOJDES+DVR->DVR_CODNEG+DVR->DVR_SERVIC == cSeek )
			AAdd(aValInf,{DVR->DVR_CODPAS,DVR->DVR_VALOR,.F.,DVR->DVR_NUMNFC,DVR->DVR_SERNFC,DVR->DVR_CODPRO,"DVR",DVR->(Recno())})
			DVR->(DbSkip())
		EndDo
	EndIf
//-- Inicializa aValInf no calculo do frete(tmsa200)
ElseIf cAcao == '5'
	DVR->(DbSetOrder(2)) //DVR_FILIAL+DVR_FILORI+DVR_LOTNFC+DVR_CLIREM+DVR_LOJREM+DVR_CLIDES+DVR_LOJDES+DVR_SERVIC+DVR_NUMNFC+DVR_SERNFC+DVR_CODPRO+DVR_CODPAS
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DVR_CODPAS,DVR_VALOR,DVR_NUMNFC,DVR_SERNFC,DVR_CODPRO "
	cQuery += " FROM " + RetSqlName("DVR")+ " DVR "
	cQuery += " WHERE DVR_FILIAL = '" + xFilial("DVR") + "'"
	cQuery += "   AND DVR_FILORI = '" + cFilOri + "'"
	cQuery += "   AND DVR_LOTNFC = '" + cLotNfc + "'"
	cQuery += "   AND DVR_CLIREM = '" + cCliRem + "'"
	cQuery += "   AND DVR_LOJREM = '" + cLojRem + "'"
	cQuery += "   AND DVR_CLIDES = '" + cCliDes + "'"
	cQuery += "   AND DVR_LOJDES = '" + cLojDes + "'"
	cQuery += "   AND DVR_CODNEG = '" + cCodNeg + "'"
	cQuery += "   AND DVR_SERVIC = '" + cServic + "'"
	cQuery += "   AND DVR_NUMNFC = '" + cNumNfc + "'"
	cQuery += "   AND DVR_SERNFC = '" + cSerNfc + "'"
	cQuery += "   AND DVR_CODPRO = '" + cCodPro + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	While (cAliasQry)->(!Eof())
		AAdd(aValInf,{(cAliasQry)->DVR_CODPAS,(cAliasQry)->DVR_VALOR,.F.,(cAliasQry)->DVR_NUMNFC,(cAliasQry)->DVR_SERNFC,(cAliasQry)->DVR_CODPRO})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
//-- Valor informado x documento de complemento
ElseIf cAcao == '6'
	//-- Preenche aHeader
    aDVSFields := ApBuildHeader("DVS")

    For nCntFor := 1 to Len(aDVSFields)
        cCampo := AllTrim(aDVSFields[nCntFor][2])
        If cCampo $ 'DVS_CODPAS.DVS_DESPAS.DVS_VALOR'
            AAdd( aHeader, aDVSFields[nCntFor])
        EndIf
    Next

	aCols := {}
	If	Empty(aValInf)
		//-- Obtem todos os componentes do tipo valor informado
		aCmpInf := TmsCompFre(StrZero(7,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab)
		If	! Empty(aCmpInf)
			For nCntFor := 1 To Len(aCmpInf)
				//-- Monta uma linha em branco
				AAdd( aCols, Array( Len( aHeader ) + 1 ) )
				nItem := Len(aCols)
				GDFieldPut('DVS_CODPAS',aCmpInf[nCntFor,1],nItem)
				GDFieldPut('DVS_DESPAS',aCmpInf[nCntFor,2],nItem)
				GDFieldPut('DVS_VALOR' ,0,nItem)
  				aCols[ nItem, Len( aHeader ) + 1 ] := .F.
			Next
		EndIf
	Else
		//-- Ha uma falha na apresentacao dos itens deletados na msgetdados, entao criamos a funcao tmsa011ajumin que
		//-- trabalha em conjunto com o vetor aColsAux para corrigir a falha.
		//-- A funcao tmsa011ajumin tem que receber:
		//-- Um aCols, onde todas as linhas estao com a coluna de deletado igual a .F.
		//-- Um aColsAux, indicando quais linhas estao deletadas.
		aColsAux := {}
		For nCntFor := 1 To Len(aValInf)
			//-- Monta uma linha em branco
			AAdd( aCols, Array( Len( aHeader ) + 1 ) )
			nItem := Len(aCols)
			GDFieldPut('DVS_CODPAS',aValInf[nCntFor,1],nItem)
			GDFieldPut('DVS_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+aValInf[nCntFor,1],'DT3_DESCRI'),nItem)
			GDFieldPut('DVS_VALOR' ,aValInf[nCntFor,2],nItem)
			aCols[nItem,Len(aHeader)+1] := aValInf[nCntFor,3]
		Next
		aColsAux := AClone(aCols)
		For nCntFor := 1 To Len(aCols)
			aCols[ nCntFor, Len( aHeader ) + 1 ] := .F.
		Next
	EndIf
	//-- Monta uma linha em branco
	If	Empty(aCols)
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
		aCols[1,Len(aHeader)+1] := .F.
	EndIf

	aKeyCmp	 := {'DVS_CODPAS'}					//-- Variavel utilizada pela funcao TmsLOkCmp()
	cCadastro := STR0079 //'Valor Informado x Complemento'
	DEFINE MSDIALOG oDlgCmp TITLE cCadastro FROM 094,104 TO 310,590 PIXEL
		If	nOpcx == 2 .And. ! Empty(aValInf)
			@ 018, 003 SAY FwX3Titulo('DVS_DOC') SIZE 56 ,9 OF oDlgCmp PIXEL
			@ 018, 036 SAY aValInf[1,4]+' / '+aValInf[1,5] SIZE 56 ,9 OF oDlgCmp PIXEL
		EndIf
		//               MsGetDados(nT , nL,  nB,  nR, nOpc,   cLinhaOk,    cTudoOk,cIniCpos,lDeleta,    aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
		oGetCmp := MSGetDados():New( 30, 02, 105, 243,Iif(nOpcx!=2,3,2),'TmsLOkCmp','TmsTOkCmp',        ,.T.    ,          ,       ,      ,Len(aCols))
		TMSA011AjuMin(aColsAux, aCols)
		oGetCmp:Refresh(.T.)

		//-- Ajuste do Ponteiro da tabela da GetDados para nao
		//-- preencher indevidamente campos virtuais na adicao de novas linhas,
		//-- quando a operacao for de alteracao de registro.
		DVS->(MsGoto(0))

	ACTIVATE MSDIALOG oDlgCmp ON INIT EnchoiceBar(oDlgCmp,{||Iif( oGetCmp:TudoOk(), (nOpca := 1,oDlgCmp:End()), nOpca :=0 )},{||nOpca:=0,oDlgCmp:End()},,aSomaButtons)
	If	nOpca == 1 .And. nOpcx!=2
		For nCntFor := 1 To Len(aCols)
			nSeek := AScan(aValInf,{|x|x[1]==GdFieldGet('DVS_CODPAS',nCntFor)})
			If	nSeek > 0
				aValInf[nSeek,2]:=GdFieldGet('DVS_VALOR',nCntFor)
				aValInf[nSeek,3]:=aCols[nCntFor,Len(aHeader)+1]
			Else
				AAdd(aValInf,{GdFieldGet('DVS_CODPAS',nCntFor),GdFieldGet('DVS_VALOR',nCntFor),aCols[nCntFor,Len(aHeader)+1],'','',''})
			EndIf
		Next
	EndIf
//-- Inicializa aValInf na visualizacao do documento de complemento(tmsa500)
ElseIf cAcao == '7'
	DVS->(DbSetOrder(1))
	If	DVS->(MsSeek(cSeek:=xFilial('DVS') + cFilOri + cNumNfc + cSerNfc))
		While DVS->( ! Eof() .And. DVS->DVS_FILIAL + DVS->DVS_FILDOC + DVS->DVS_DOC + DVS->DVS_SERIE == cSeek)
			AAdd(aValInf,{DVS->DVS_CODPAS,DVS->DVS_VALOR,.F.,DVS->DVS_DOC,DVS->DVS_SERIE,''})
			DVS->(DbSkip())
		EndDo
	EndIf
//-- Deleta valor informado x documento do vetor aValInf ocorre uma Alteracao ou Delecao
ElseIf cAcao == '8'
	If	!Empty(cNumNfc) .And. !Empty(cSerNfc) .And. !Empty(cCodPro)
		aDelInf := AClone(aValInf)
		nItem   := 0
		For nCntFor := 1 To Len(aDelInf)
			If	aDelInf[nCntFor,4]+aDelInf[nCntFor,5]+aDelInf[nCntFor,6]==cNumNfc+cSerNfc+cCodPro
				nSeek := AScan(aValInf,{|x|x[4]+x[5]+x[6]==cNumNfc+cSerNfc+cCodPro})
				If	nSeek > 0
					ADel(aValInf,nSeek)
					nItem++
				EndIf
			EndIf
		Next
		ASize(aValInf,Len(aValInf)-nItem)
	EndIf
//-- Valor informado x viagem
ElseIf cAcao == '9'

    lCpoOri      := Iif( DVW->(ColumnPos("DVW_ORIGEM")) > 0 , .t., .f. ) //-- Tratamento Rentabilidade/Ocorrencia
	cRotOri      := Iif( IsInCallStack("TMSA240MNT"),"TMSA240",Iif(IsInCallStack("TMSA340MNT"),"TMSA340",""))  //-- Tratamento Rentabilidade/Ocorrencia

    //-- Preenche aHeader
    aDVWFields := ApBuildHeader("DVW")

    For nCntFor := 1 to Len(aDVWFields)
        cCampo := AllTrim(aDVWFields[nCntFor][2])
        If cCampo $ 'DVW_CODPAS.DVW_DESPAS.DVW_VALOR'
            AAdd( aHeader, aDVWFields[nCntFor])
        EndIf
    Next

	aCols := {}
	//-- Preenche aCols baseado na digitacao de valor informado x viagem
	nSeek := AScan(aValInf,{|x|x[4]==cFilOri+cViagem})
	If	Empty(nSeek)
		DVW->(DbSetOrder(1))
		If lTabDFI
			cIdent := M_Posicione("DTQ",1,xFilial("DTQ")+cViagem,"DTQ_IDENT")
			If	DVW->(MsSeek(cSeek:=xFilial('DVW')+cIdent))
				While DVW->(!Eof() .And. DVW->DVW_FILIAL + DVW->DVW_IDENT == cSeek)
					If	AScan(aValInf,{|x|x[4]+x[1]== DVW->DVW_FILORI + DVW->DVW_VIAGEM + DVW->DVW_CODPAS })==0
						AAdd(aValInf,{DVW->DVW_CODPAS,DVW->DVW_VALOR,.F.,DVW->DVW_FILORI+DVW->DVW_VIAGEM,'','',Iif(lCpoOri,cRotOri,"")})
					EndIf
					AAdd( aCols, Array( Len( aHeader ) + 1 ) )
					nItem := Len(aCols)
					GDFieldPut('DVW_CODPAS',DVW->DVW_CODPAS,nItem)
					GDFieldPut('DVW_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+DVW->DVW_CODPAS,'DT3_DESCRI'),nItem)
					GDFieldPut('DVW_VALOR' ,DVW->DVW_VALOR,nItem)
					aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					DVW->(DbSkip())
				EndDo
			Else
				//-- Obtem todos os componentes do tipo valor informado
				aCmpInf := TmsCompFre(StrZero(61,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab)
				If	! Empty(aCmpInf)
					For nCntFor := 1 To Len(aCmpInf)
						//-- Monta uma linha em branco
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
						nItem := Len(aCols)
						GDFieldPut('DVW_CODPAS',aCmpInf[nCntFor,1],nItem)
						GDFieldPut('DVW_DESPAS',aCmpInf[nCntFor,2],nItem)
						GDFieldPut('DVW_VALOR' ,0,nItem)
						aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					Next
				EndIf
			EndIf
		Else //--Pesquisa DVW com indice antigo, com viagem
			If	DVW->(MsSeek(cSeek:=xFilial('DVW')+cFilOri+cViagem))
				While DVW->(!Eof() .And. DVW->DVW_FILIAL + DVW->DVW_FILORI + DVW->DVW_VIAGEM == cSeek)
					If	AScan(aValInf,{|x|x[4]+x[1]== DVW->DVW_FILORI + DVW->DVW_VIAGEM + DVW->DVW_CODPAS })==0
						AAdd(aValInf,{DVW->DVW_CODPAS,DVW->DVW_VALOR,.F.,DVW->DVW_FILORI+DVW->DVW_VIAGEM,'','',Iif(lCpoOri,cRotOri,"")})
					EndIf
					AAdd( aCols, Array( Len( aHeader ) + 1 ) )
					nItem := Len(aCols)
					GDFieldPut('DVW_CODPAS',DVW->DVW_CODPAS,nItem)
					GDFieldPut('DVW_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+DVW->DVW_CODPAS,'DT3_DESCRI'),nItem)
					GDFieldPut('DVW_VALOR' ,DVW->DVW_VALOR,nItem)
					aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					DVW->(DbSkip())
				EndDo
			Else
				//-- Obtem todos os componentes do tipo valor informado
				aCmpInf := TmsCompFre(StrZero(61,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab)
				If	! Empty(aCmpInf)
					For nCntFor := 1 To Len(aCmpInf)
						//-- Monta uma linha em branco
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
						nItem := Len(aCols)
						GDFieldPut('DVW_CODPAS',aCmpInf[nCntFor,1],nItem)
						GDFieldPut('DVW_DESPAS',aCmpInf[nCntFor,2],nItem)
						GDFieldPut('DVW_VALOR' ,0,nItem)
						aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					Next
				EndIf
			EndIf
		EndIf
	//-- Preenche aCols baseado no vetor aValInf (antes de confirmar a cotacao)
	Else
		//-- Ha uma falha na apresentacao dos itens deletados na msgetdados, entao criamos a funcao tmsa011ajumin que
		//-- trabalha em conjunto com o vetor aColsAux para corrigir a falha.
		//-- A funcao tmsa011ajumin tem que receber:
		//-- Um aCols, onde todas as linhas estao com a coluna de deletado igual a .F.
		//-- Um aColsAux, indicando quais linhas estao deletadas.
		aColsAux := {}
		For nCntFor := 1 To Len(aValInf)
			If	aValInf[nCntFor,4] == cFilOri+cViagem
				//-- Monta uma linha em branco
				AAdd( aCols, Array( Len( aHeader ) + 1 ) )
				nItem := Len(aCols)
				GDFieldPut('DVW_CODPAS',aValInf[nCntFor,1],nItem)
				GDFieldPut('DVW_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+aValInf[nCntFor,1],'DT3_DESCRI'),nItem)
				GDFieldPut('DVW_VALOR' ,aValInf[nCntFor,2],nItem)
				aCols[nItem,Len(aHeader)+1] := aValInf[nCntFor,3]
			EndIf
		Next
		aColsAux := AClone(aCols)
		For nCntFor := 1 To Len(aCols)
			aCols[ nCntFor, Len( aHeader ) + 1 ] := .F.
		Next
	EndIf
	//-- Monta uma linha em branco
	If	Empty(aCols)
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
		aCols[1,Len(aHeader)+1] := .F.
	EndIf

	aKeyCmp   := {'DVW_CODPAS'}					//-- Variavel utilizada pela funcao TmsLOkCmp()
	cCadastro := STR0080 //'Valor Informado x Viagem'
	DEFINE MSDIALOG oDlgCmp TITLE cCadastro FROM 094,104 TO 310,590 PIXEL
		@ 018, 003 SAY FwX3Titulo('DTR_VIAGEM') SIZE 56 ,9 OF oDlgCmp PIXEL
		@ 018, 023 SAY cFilOri + ' / ' + cViagem SIZE 56 ,9 OF oDlgCmp PIXEL
		//               MsGetDados(nT , nL,  nB,  nR,                 nOpc,   cLinhaOk,    cTudoOk,cIniCpos,lDeleta,    aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
		oGetCmp := MSGetDados():New( 30, 02, 105, 243, Iif(nOpcx>4,2,nOpcx),'TmsLOkCmp','TmsTOkCmp',,.T.)
		TMSA011AjuMin(aColsAux, aCols)
		oGetCmp:Refresh(.T.)
		//- Este tratamento eh utilizado pela relacionamento Agendamento X Cotacao (Carga Fechada)
		If nOpcx == 2 .Or. nOpcx == 5
			oGetCmp:oBrowse:bDelete := { || .f. }     // Nao Permite a deletar Linhas
		EndIf

		//-- Ajuste do Ponteiro da tabela da GetDados para nao
		//-- preencher indevidamente campos virtuais na adicao de novas linhas,
		//-- quando a operacao for de alteracao de registro.
		DVW->(MsGoto(0))

	ACTIVATE MSDIALOG oDlgCmp ON INIT EnchoiceBar(oDlgCmp,{||Iif( oGetCmp:TudoOk(), (nOpca := 1,oDlgCmp:End()), nOpca :=0 )},{||nOpca:=0,oDlgCmp:End()},,aSomaButtons)
	If	nOpca == 1
		For nCntFor := 1 To Len(aCols)
			nSeek := AScan(aValInf,{|x|x[4]+x[1]==cFilOri+cViagem+GdFieldGet('DVW_CODPAS',nCntFor)})
			If	nSeek > 0
				aValInf[nSeek,2]:= GdFieldGet('DVW_VALOR',nCntFor)
				aValInf[nSeek,3]:= aCols[nCntFor,Len(aHeader)+1]
			Else
				AAdd(aValInf,{GdFieldGet('DVW_CODPAS',nCntFor),GdFieldGet('DVW_VALOR',nCntFor),aCols[nCntFor,Len(aHeader)+1],cFilOri+cViagem,'','',Iif(lCpoOri,cRotOri,"")})
			EndIf
		Next
	EndIf
//-- Inicializa aValInf na alteracao do complemento/encerramento da viagem.
ElseIf cAcao == '10'

    lCpoOri      := Iif( DVW->(ColumnPos("DVW_ORIGEM")) > 0 , .t., .f. ) //-- Tratamento Rentabilidade/Ocorrencia
	cRotOri      := Iif( IsInCallStack("TMSA240MNT"),"TMSA240",Iif(IsInCallStack("TMSA340MNT"),"TMSA340",""))  //-- Tratamento Rentabilidade/Ocorrencia

	DVW->(DbSetOrder(1))
	If lTabDFI
		cIdent := M_Posicione("DTQ",1,xFilial("DTQ")+cViagem,"DTQ_IDENT")
		If	DVW->(MsSeek(cSeek:=xFilial('DVW')+cIdent))
			While DVW->(!Eof() .And. DVW->DVW_FILIAL + DVW->DVW_IDENT == cSeek)
				AAdd(aValInf,{DVW->DVW_CODPAS,DVW->DVW_VALOR,.F.,cFilOri+cViagem,'','',Iif(lCpoOri,cRotOri,"")})
				DVW->(DbSkip())
			EndDo
		EndIf
	Else
		If	DVW->(MsSeek(cSeek:=xFilial('DVW')+cFilOri+cViagem))
			While DVW->(!Eof() .And. DVW->DVW_FILIAL + DVW->DVW_FILORI + DVW->DVW_VIAGEM == cSeek)
				AAdd(aValInf,{DVW->DVW_CODPAS,DVW->DVW_VALOR,.F.,DVW->DVW_FILORI+DVW->DVW_VIAGEM,'','',Iif(lCpoOri,cRotOri,"")})
				DVW->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsLOkCmp³ Autor ³ Alex Egydio            ³ Data ³12.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Linha Ok da digitacao do valor informado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsLOkCmp()

	Local lRet    := .T.
	Local lCmpDVW := .F.

	//-- Nao avalia linhas deletadas
	If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados
		lRet := GDCheckKey( aKeyCmp, 4 )
	EndIf

	If lRet .And. Type("aKeyCmp") == "A" .And. Len(aKeyCmp) > 0
		lCmpDVW:= aScan( aKeyCmp, "DVW_CODPAS") > 0
	EndIf

	If lCmpDVW
		//-- Tratamento Rentabilidade/Ocorrencia
		//-- Verifica Mesmo Se Deletado
		If lRet .And. DVW->(ColumnPos("DVW_ORIGEM")) > 0 .And. !Empty(aValInf) .And. Len(aValInf) >= n .And. Len(aValInf[n]) >= 7

			//-- Verifica Se Existem Gravações Anteriores
			DbSelectArea("DVW")
			DbSetOrder(1) //-- DVW_FILIAL+DVW_FILORI+DVW_VIAGEM+DVW_CODPAS
			If MsSeek( FWxFilial("DVW") + aValInf[n,4] + GdFieldGet("DVW_CODPAS",n) , .f. )

				If !Empty(DVW->DVW_ORIGEM) .And. !Alltrim(DVW->DVW_ORIGEM) $ "TMSA240|TMSA340"
					Help('',1,'TMSXFUNB47')	//-- "Informações Geradas Fora Do TMS Não Podem Ser Alteradas Ou Deletadas!"
					lRet := .f.
				EndIf
			EndIf
		EndIf
	EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsTOkCmp³ Autor ³ Alex Egydio            ³ Data ³12.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok da digitacao do valor informado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTOkCmp()

Local lRet		:= .T.
//-- Analisa se os campos obrigatorios da GetDados foram informados
If	lRet
	lRet := oGetCmp:ChkObrigat( n )
EndIf
//-- Analisa o linha ok
If lRet
	lRet := TmsLOkCmp()
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsCompFre³ Autor ³ Alex Egydio           ³ Data ³12.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem componentes de frete do tipo 'calcula sobre' desejado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do tipo 'Calcula Sobre DT3_TIPFAI'          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCompFre(cTipFai,cTabFre,cTipTab)

Local aAreaAnt  := GetArea()
Local aRet      := {}
Local aRetPE	:= {}
Local cQuery    := ''
Local cAliasQry := GetNextAlias()

Default cTabFre := ''
Default cTipTab := ''

If !Empty(cTabFre) .And. !Empty(cTipTab)
	cQuery := " SELECT DT3_CODPAS,DT3_DESCRI,DT3_TIPFAI "
	cQuery += "  FROM " + RetSqlName("DVE") + " DVE, " + RetSqlName("DT3") + " DT3 "
	cQuery += "  WHERE DVE_FILIAL = '" + xFilial('DVE') + "' "
	cQuery += "    AND DVE_TABFRE = '" + cTabFre + "' "
	cQuery += "    AND DVE_TIPTAB = '" + cTipTab + "' "
	cQuery += "    AND DVE.D_E_L_E_T_ = ' '"
	cQuery += "    AND DT3_FILIAL = '" + xFilial('DT3') + "' "
	cQuery += "    AND DT3_CODPAS = DVE_CODPAS "
	cQuery += "    AND ( DT3_TIPFAI = '" + cTipFai + "' "
	cQuery += "       OR DT3_FAIXA2 = '" + cTipFai + "') "
	cQuery += "    AND DT3.D_E_L_E_T_ = ' ' "
	cQuery += "  ORDER BY DT3_DESCRI "
Else
	cQuery := " SELECT DT3_CODPAS,DT3_DESCRI,DT3_TIPFAI "
	cQuery += "  FROM " + RetSqlName("DT3") + " DT3 "
	cQuery += "  WHERE DT3_FILIAL = '" + xFilial('DT3') + "' "
	cQuery += "    AND ( DT3_TIPFAI = '" + cTipFai + "' "
	cQuery += "       OR DT3_FAIXA2 = '" + cTipFai + "') "
	cQuery += "    AND DT3.D_E_L_E_T_ = ' ' "
	cQuery += "  ORDER BY DT3_DESCRI "
EndIf
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
While (cAliasQry)->(!Eof())
	AAdd(aRet,{(cAliasQry)->DT3_CODPAS,(cAliasQry)->DT3_DESCRI,(cAliasQry)->DT3_TIPFAI})
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(dbCloseArea())
RestArea(aAreaAnt)

//- Manipulacao do vetor de retorno
If ExistBlock("TMSMANVET")
	aRetPE := ExecBlock("TMSMANVET",.F.,.F.,{aRet})
	If ValType(aRetPE) == "A"
		aRet := aRetPE
	EndIf
EndIf

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsGrvInf³ Autor ³ Alex Egydio            ³ Data ³12.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a digitacao do valor informado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor contendo os componentes de frete do tipo     ³±±
±±³          ³ (valor informado), com o valor base digitado na cotacao ou ³±±
±±³          ³ na entrada de nf do cliente                                ³±±
±±³          ³ ExpC1 = '1' = Digitacao pela cotacao de frete              ³±±
±±³          ³         '2' = Digitacao pela entrada de nf do cliente      ³±±
±±³          ³         '3' = Digitacao pela manutencao de documentos      ³±±
±±³          ³         '4' = Digitacao pelo compl. viagem / encerramento  ³±±
±±³          ³ ExpC2 = Filial de origem                                   ³±±
±±³          ³ ExpC3 = Numero da cotacao de frete                         ³±±
±±³          ³ ExpC4 = Nr. do lote de digitacao de nf do cliente          ³±±
±±³          ³ ExpC5 = Cliente remetente                                  ³±±
±±³          ³ ExpC6 = Loja remetente                                     ³±±
±±³          ³ ExpC7 = Cliente destinatario                               ³±±
±±³          ³ ExpC8 = Loja destinatario                                  ³±±
±±³          ³ ExpC9 = Codigo do servico                                  ³±±
±±³          ³ ExpN1 = Opcao de manutencao                                ³±±
±±³          ³ ExpCA = Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsGrvInf(aValInf, cAcao, cFilDco, cNumCot, cLotNfc, cCliRem, cLojRem, cCliDes, cLojDes, cServic, nOpcx, cViagem, aCopValInf, cServicOld, cCodneg)

Local nCntFor	:= 0
Local lTabDFI   := nModulo<>43
Local cSeek     := ""
Local cIdent    := ""

DEFAULT aCopValInf := {}
Default cServicOld := ""
DEFAULT cCodneg    := ""

//-- Grava valor informado x cotacao de frete
If	cAcao == '1'
	Begin Transaction
		DVQ->(DbSetOrder(1))
		For nCntFor := 1 To Len(aValInf)
			If	! aValInf[nCntFor,3] .And. aValInf[nCntFor,2] > 0
				If	DVQ->(MsSeek(xFilial('DVQ') + cFilDco + cNumCot + aValInf[nCntFor,6] + aValInf[nCntFor,1]))
					RecLock('DVQ',.F.)
				Else
					RecLock('DVQ',.T.)
					DVQ->DVQ_FILIAL := xFilial('DVQ')
					DVQ->DVQ_FILORI := cFilDco
					DVQ->DVQ_NUMCOT := cNumCot
					DVQ->DVQ_CODPRO := aValInf[nCntFor,6]
					DVQ->DVQ_CODPAS := aValInf[nCntFor,1]
				EndIf
				DVQ->DVQ_VALOR := aValInf[nCntFor,2]
				MsUnLock()
			Else
				If	DVQ->(MsSeek(xFilial('DVQ') + cFilDco + cNumCot + aValInf[nCntFor,6] + aValInf[nCntFor,1]))
					RecLock('DVQ',.F.,.T.)
					DVQ->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next
	End Transaction
//-- Grava valor informado x documento
ElseIf cAcao == '2'
	Begin Transaction
		DVR->(DbSetOrder(1)) //DVR_FILIAL+DVR_FILORI+DVR_LOTNFC+DVR_CLIREM+DVR_LOJREM+DVR_CLIDES+DVR_LOJDES+DVR_SERVIC+DVR_NUMNFC+DVR_SERNFC+DVR_CODPRO+DVR_CODPAS
		// CASO SEJA ALTERACAO E
		// O VETOR ESTEJA ZERADO (O QUE INDICA QUE HOUVE ALTERACAO NO SERVICO
		If nOpcx == 4 .And. Len(aValInf) == 0
			For nCntFor := 1 To Len(aCopValInf)
				If DVR->(MsSeek(xFilial('DVR') + cFilDco + cLotNfc + cCliRem + cLojRem + cCliDes+cLojDes + cServicOld + aCopValInf[nCntFor,4] + aCopValInf[nCntFor,5] + aCopValInf[nCntFor,6] + aCopValInf[nCntFor,1] + cCodneg))
					RecLock('DVR',.F.,.T.)
					DVR->(DbDelete())
					MsUnLock()
				EndIf
			Next
		EndIf

		For nCntFor := 1 To Len(aValInf)
			If	(nOpcx==3 .Or. nOpcx==4) .And. !aValInf[nCntFor,3] .And. aValInf[nCntFor,2] > 0
				If	nCntFor <= Len(aCopValInf) .And. DVR->(MsSeek(xFilial('DVR') + cFilDco + cLotNfc + cCliRem + cLojRem + cCliDes+cLojDes + cServicOld + aCopValInf[nCntFor,4] + aCopValInf[nCntFor,5] + aCopValInf[nCntFor,6] + aCopValInf[nCntFor,1]))
					RecLock('DVR',.F.) //Alteracao
					DVR->DVR_SERVIC := cServic
					DVR->DVR_NUMNFC := aValInf[nCntFor,4]
					DVR->DVR_SERNFC := aValInf[nCntFor,5]
					DVR->DVR_CODPRO := aValInf[nCntFor,6]
					DVR->DVR_CODPAS := aValInf[nCntFor,1]
					DVR->DVR_CODNEG := cCodneg
					
				Else
					RecLock('DVR',.T.) //Inclusao
					DVR->DVR_FILIAL := xFilial('DVR')
					DVR->DVR_FILORI := cFilDco
					DVR->DVR_LOTNFC := cLotNfc
					DVR->DVR_CLIREM := cCliRem
					DVR->DVR_LOJREM := cLojRem
					DVR->DVR_CLIDES := cCliDes
					DVR->DVR_LOJDES := cLojDes
					DVR->DVR_SERVIC := cServic
					DVR->DVR_NUMNFC := aValInf[nCntFor,4]
					DVR->DVR_SERNFC := aValInf[nCntFor,5]
					DVR->DVR_CODPRO := aValInf[nCntFor,6]
					DVR->DVR_CODPAS := aValInf[nCntFor,1]
					DVR->DVR_CODNEG := cCodneg
					
				EndIf
				DVR->DVR_VALOR := aValInf[nCntFor,2]
				MsUnLock()
			ElseIf nCntFor <= Len(aCopValInf)
				If DVR->(MsSeek(xFilial('DVR')+cFilDco+cLotNfc+cCliRem+cLojRem+cCliDes+cLojDes+cServic+aCopValInf[nCntFor,4]+aCopValInf[nCntFor,5]+aCopValInf[nCntFor,6]+aCopValInf[nCntFor,1]))
					RecLock('DVR',.F.,.T.)
					DVR->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next
	End Transaction

//-- Grava valor informado x documento de complemento
ElseIf cAcao == '3'
	Begin Transaction
		DVS->(DbSetOrder(1))
		For nCntFor := 1 To Len(aValInf)
			If	! aValInf[nCntFor,3] .And. aValInf[nCntFor,2] > 0
				If	DVS->(MsSeek(xFilial('DVS') + cFilDco + aValInf[1,4] + aValInf[1,5] + aValInf[nCntFor,1]))
					RecLock('DVS',.F.)
				Else
					RecLock('DVS',.T.)
					DVS->DVS_FILIAL := xFilial('DVS')
					DVS->DVS_FILDOC := cFilDco
					DVS->DVS_DOC    := aValInf[1,4]
					DVS->DVS_SERIE  := aValInf[1,5]
					DVS->DVS_CODPAS := aValInf[nCntFor,1]
				EndIf
				DVS->DVS_VALOR := aValInf[nCntFor,2]
				MsUnLock()
			Else
				If	DVS->(MsSeek(xFilial('DVS') + cFilDco + aValInf[1,4] + aValInf[1,5] + aValInf[nCntFor,1]))
					RecLock('DVS',.F.,.T.)
					DVS->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next
	End Transaction
//-- Grava valor informado x viagem
ElseIf cAcao == '4'
	Begin Transaction
		For nCntFor := 1 To Len(aValInf)
			If lTabDFI
				DVW->(DbSetOrder(2))
			Else
				DVW->(DbSetOrder(1))
			EndIf
			If !lTabDFI
				cSeek := xFilial('DVW') + cFilDco + cViagem + aValInf[nCntFor,1]
			EndIf
			If	nOpcx <> 5 .And. !aValInf[nCntFor,3] .And. aValInf[nCntFor,2] > 0
				If	DVW->(MsSeek(cSeek))
					RecLock('DVW',.F.)
				Else
					RecLock('DVW',.T.)
					DVW->DVW_FILIAL := xFilial('DVW')
					DVW->DVW_CODPAS := aValInf[nCntFor,1]
					If lTabDFI
						DVW->DVW_IDENT := cIdent
					Else //--So gravo estes campos se o indice do DVW tiver viagem na chave
						DVW->DVW_FILORI := cFilDco
						DVW->DVW_VIAGEM := cViagem
						DVW->DVW_CODPAS := aValInf[nCntFor,1]
					EndIf
				EndIf
				DVW->DVW_VALOR := aValInf[nCntFor,2]

				//-- Tratamento Rentabilidade/Ocorrencia
				If DVW->(ColumnPos("DVW_ORIGEM")) > 0 .And. Len(aValInf[nCntFor]) >= 7
					DVW->DVW_ORIGEM := aValInf[nCntFor,7]
				EndIf

				MsUnLock()
			Else
				If DVW->(MsSeek(cSeek))
					RecLock('DVW',.F.,.T.)
					DVW->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next
	End Transaction
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsBlqDoc³ Autor ³ Alex Egydio            ³ Data ³24.06.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bloqueio de Transporte                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Informacoes do documento para bloqueio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo do bloqueio de transporte                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsBlqDoc(aBlqDoc)

Local cCliGen	:= GetMV('MV_CLIGEN')
Local cRet		:= ""
Local cLojGen	:= ""
Local cCliDev	:= ""
Local cLojDev	:= ""
Local lRet		:= .F.

DEFAULT aBlqDoc:= {}

If !Empty(aBlqDoc) .And. IntTMS()
	cCliDev := aBlqDoc[2]
	cLojDev := aBlqDoc[3]
	//-- Obtem o cliente generico
	SA1->(DbSetOrder(1))
	If	SA1->(MsSeek(xFilial("SA1")+cCliGen))
		cCliGen := SA1->A1_COD
		cLojGen := SA1->A1_LOJA
	EndIf
	//-- Verifica se ha bloqueio de transporte para o cliente ou cliente generico
	DV5->(DbSetOrder(1)) //DV5_FILIAL+DV5_CODCLI+DV5_LOJCLI+DV5_CODBLQ
	If    !DV5->(MsSeek(xFilial("DV5") + cCliDev + cLojDev))
		If DV5->(MsSeek(xFilial("DV5") + cCliGen + cLojGen))
			aBlqDoc[4] := cCliGen
			aBlqDoc[5] := cLojGen
		EndIf
	EndIf
	If	DV5->(!Eof()) .And. !Empty(DV5->DV5_CODBLQ)
		aBlqDoc[1] := cRet := DV5->DV5_CODBLQ
	EndIf
	//-- Ponto de entrada com regras definidas pelo cliente, determinando se havera bloqueio de transporte
	If	lTMBLQDOC
		//-- O retorno do ponto de entrada sera desconsiderado se diferente de logico
		lRet := ExecBlock("TMBLQDOC",.F.,.F.,aBlqDoc)
		//-- Se o ponto de entrada retornar .F., cRet fica branco determinando que nao havera bloqueio
		If	ValType(lRet)=="L" .And. !lRet
			cRet := ""
		EndIf
	EndIf
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsSomaImp³ Autor ³ Alex Egydio           ³ Data ³24.06.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Determina se o imposto sera somado no valor total do frete ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = TES                                                ³±±
±±³          ³ ExpC2 = ISS no preco                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsSomaImp(cTes,cIncIss,lSolidario)

Local aAreaAnt := GetArea()
Local aAreaSF4 := SF4->(GetArea())

Default cIncIss    := "N"
Default lSolidario := .F.

SF4->(DbSetOrder(1))
SF4->(MsSeek(xFilial('SF4') + cTes))
If	SF4->F4_ISS == 'S'
	If !Empty(SF4->F4_AGRISS) .And. SF4->F4_AGRISS == '2'
		Return( .F. )
	EndIf
	If !Empty(SF4->F4_AGRISS) .And. SF4->F4_AGRISS == '1'
		Return( .T. )
	EndIf
EndIf
//-- TES Incide ISS e o valor do ISS nao esta incluso no valor do frete
If	SF4->F4_ISS == 'S' .And. !GetMV('MV_INCISS',,.T.) .And. cIncIss == "N"
	Return( .T. )
EndIf
//-- TES calcula o ICMS e agrega valor ICMS e mercadoria
If	SF4->F4_ICM == 'S' .And. SF4->F4_AGREG == 'I'
	Return( .T. )
EndIf
//-- TES Solidario
If	lSolidario
	Return( .T. )
EndIf
//-- TES Agrega PIS
If SF4->F4_AGRPIS == "P"
	Return( .T. )
EndIf
//-- TES Agrega COFINS
If SF4->F4_AGRCOF == "C"
	Return( .T. )
EndIf

RestArea(aAreaSF4)
RestArea(aAreaAnt)

Return( .F. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsTotHor³ Autor ³ Robson Alves          ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o total de horas entre duas datas e duas horas.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Mnt( ExpD1, ExpC1, ExpD2, ExpC2 )                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpD1 = Data Inicial                                       ³±±
±±³          ³ ExpC1 = Hora Inicial                                       ³±±
±±³          ³ ExpD2 = Data Final                                         ³±±
±±³          ³ ExpC2 = Hora Final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC3 = Total de horas.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTotHora( dDtIni, cHrIni, dDtFim, cHrFim )

Local nHoras   := Val(SubStr(cHrFim,1,2)) - Val(SubStr(cHrIni,1,2))
Local nMinutos := Val(SubStr(cHrFim,3,2)) - Val(SubStr(cHrIni,3,2))
Local nDias    := dDtFim - dDtIni
Local cTotHora := ""

If ( nMinutos < 0 )
	nHoras--
	nMinutos += 60
EndIf
If ( nHoras < 0 )
	nDias --
	nHoras += 24
EndIf

If nDias >= 0
	cTotHora += StrZero( ( ( 24 * nDias ) + nHoras ), 3 )
	cTotHora += StrZero( nMinutos, 2 )
EndIf

Return( cTotHora )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCalFreP³ Autor³Richard/Patricia Salomao³ Data ³02/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o Frete a Pagar                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial de Origem                                    ³±±
±±³          ³ExpC2 - Viagem                                              ³±±
±±³          ³ExpC3 - Codigo do Veiculo                                   ³±±
±±³          ³ExpA1 - Array que ira' conter as Mensagens de Erro          ³±±
±±³          ³ExpL1 - Controla se adiciona as mensagens de erro no array  ³±±
±±³          ³        aMsgErr                                             ³±±
±±³          ³ExpA2 - Array que ira' conter a composicao do Frete         ³±±
±±³          ³ExpN3 - Tipo do Veiculo 0=Veiculo 1=1oReboque 2=2oReboque   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array: [01] - Tabela de Frete                               ³±±
±±³          ³       [02] - Tipo da Tabela de Frete                       ³±±
±±³          ³       [03] - Valor do Frete                                ³±±
±±³          ³       [04] - Qtde de Volumes                               ³±±
±±³          ³       [05] - Peso                                          ³±±
±±³          ³       [06] - Qtde. de Documentos                           ³±±
±±³          ³       [07] - Qtde. Dias da Semana                          ³±±
±±³          ³       [08] - Quilometragem                                 ³±±
±±³          ³       [09] - Qtde. Dias Fim de Semana                      ³±±
±±³          ³       [10] - Gera Titulo de Pedagio (1=Sim / 2=Nao)        ³±±
±±³          ³       [11] - Deduz Valor do Pdg. do Frete (1=Sim / 2=Nao)  ³±±
±±³          ³       [12] - Base de Calculo dos Impostos                  ³±±
±±³          ³       [13] - Codigo da Tabela de Carreteiro                ³±±
±±³          ³       [14] - Gerar Pedido de Compra (1=Sim / 2=Nao)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSR400                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSCalFrePag( cFilOri, cViagem, cCodVei, aMsgErr, lMsgErr, aFrete, nTipVei, cCodForn, cLojForn, aDiaHist, cSerTms, cTabFre, cTipTab, cTabCar, lTabPag, nMaxCus, lPreview, aDocNPrev )

Local aAreaDUD    := DUD->(GetArea())
Local aAreaDTR	  := DTR->(GetArea())
Local aAreaDTQ	  := DTQ->(GetArea())
Local cTipTra     := ''
Local cRota       := ''
Local lPrdDiv     := GetMV('MV_PRDDIV',,.F.) //-- Verifica se permitira a inclusao de um ou mais produtos
Local cCodPro     := If( lPrdDiv, STR0081, '' ) //-- "FRETE A PAGAR"
Local cPrdCal     := ''
Local lPrdCal     := .F.
Local cChave      := ''
Local cVeiRas     := ''
Local cSeek       := ''
Local cSeekDUA    := ''
Local cSeekDUD    := ''
Local cCdrOri     := ''
Local cCdrDes     := ''
Local aFretCar    := {}
Local aQtdEnt     := {}
Local aDiaSem     := {}
Local aDiaFimSem  := {}
Local aRegInf     := {}
Local aRegDCA     := {}
Local aDocVge     := {}
Local aRet        := {}
Local aTipVei     := {}
Local aTab        := {}
Local nSeek       := 0
Local nCntFor     := 0
Local nValFre     := 0
Local nQtdVol     := 0
Local nPesOco     := 0
Local nPesoDoc    := 0
Local nPesoM3Doc  := 0
Local nQtdOco     := 0
Local nQtdDoc     := 0
Local nQtdEnt     := 0
Local nDiaSem     := 0
Local nDiaFimSem  := 0
Local nQtdKm      := 0
Local dDatIni     := Ctod('')
Local dDatFim     := Ctod('')
Local bWhile      := {}
Local nPesAux     := 0
Local nQtdAux     := 0
Local lGerCont    := GetMV('MV_GERCONT',,.F.) // Gera Contrato de Carreteiro para Entregas e Coletas Nao Efetuadas ?
Local lEntSOco    := GetMV('MV_ENTSOCO',,.F.) // Gera Contrato de Carreteiro para Viagens de Entrega sem Registro de Ocorrencia (DUA) ?
Local lColSOco    := GetMV('MV_COLSOCO',,.F.) // Gera Contrato de Carreteiro para Viagens de Coleta sem Registro de Ocorrencia (DUA) ?
Local nX
Local aValInf     := {}
Local lKmDist     := SuperGetMv('MV_KMDIST',,.F.)  // Define que o calculo do Km será sempre pelo cadastro de Distancia para os calculos do frete a pagar.
Local cAliasNew   := ''
Local cQuery      := ''
Local lTMTABCAR   := ExistBlock("TMTABCAR")
Local lTMTABFRE   := ExistBlock("TMTABFRE")
Local lTMTABVGE   := ExistBlock("TMTABVGE")
Local lTMPRDCAL   := ExistBlock("TMPRDCAL")
Local lTMALTREG   := ExistBlock("TMALTREG")
Local aRetVal     := {}
Local aReg        := {}
Local nPesoVge    := 0
Local nPesoM3Vge  := 0
Local nMetro3Vge  := 0
Local nValMerVge  := 0
Local nQtdVolVge  := 0
Local nBasImp     := 0
Local cGerTitPDG  := "1" //-- Gera Titulo de Pedagio :Sim
Local cGerTitCont := "1" //-- Gera Titulo de Contrato :Sim
Local cDedPDG     := "2" //-- Deduz Pedagio do Valor do Frete : Nao
Local aDoctos     := {}
Local nDtrValFre  := 0
Local cGerPC      := IIF(GetMV('MV_TMSGRPC',,.F.), '1', '2')
Local cTMSOPdg    := SuperGetMV( 'MV_TMSOPDG',, '0' ) //-- Operadoras de Frota/Vale-Pedagio
Local lTmsRvol    := SuperGetMV('MV_TMSRVOL',,.T.) //-- Efetua rateio de volumes coletados e ou entregues
Local lTipCont    := !Empty( cCodForn ) .And. !Empty( cLojForn )
Local lLibVgBlq   := SuperGetMV('MV_LIBVGBL',,.F.)  //-- Libera Encerramento de viagens com ocorrencia do tipo
Local lChPesq     := .F.
Local cSeqDes     := ""
Local lRetSemDoc  := .F.
Local nQtdCol     := 0
Local aQtdCol     := {}
Local aDiaBkp     := {}
Local lTmsDiaV    := SuperGetMV( 'MV_TMSDIAV',, .F. )
Local lProdDiv    := .F.
Local lRet        := .T.
Local aCompTot    := {}
Local aVetAux     := {}
Local nCnt        := 0
Local nCont       := 0
Local nTotal      := 0

Local aDocCnt 	  := {} //-- Documentos da Viagem
Local cTitFrete	  := '' //--Gera o Titulo de Frete após a geraçao do contrato, independente do parametro MV_LIBCTC.
Local cBxTitPdg	  := '' //--Baixa Automaticamente o titulo do pedágio
Local cMomGerAdi  := '' //--Momento da geração do título de adiantamento.
Local lPaMovBco   := .F.
Local cTitNDF	  := '2' //--(1=Sim;2=Não) - Controla se gera NDF no momento da geração do contrato mesmo que a lliberação do contrato esteja habilitada (MV_LIBCTC == .T.)
Local cMomGerPDG  := '1'//--Momento que o título e despesas de pedágio será gerado TMSCalFrePag (1=Contrato Carreteiro;2=Fechamento da Viagem)
Local lPETipDoc   := ExistBlock("TMTIPDOC") //Permite filtrar os tipos de documentos que poderam pertencer ao contrato de carreteiro
Local lPESemDoc   := ExistBlock("TMSSEMDOC") //Calcula Frete a pagar em Vigens sem Documentos ( [ aDocVge ] ) --> lRet
Local lTipOpVg    := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local cTipOpVg    := ""
Local lOcorDoc    := .T.
Local cAbrCal     := ""
Local aDocAbrCal  := {}

Private lCmpDiaria:= .F.

Default cCodForn  := ''
Default cLojForn  := ''
Default cFilOri   := ''
Default cViagem   := ''
Default cCodVei   := ''
Default aMsgErr   := {}
Default lMsgErr   := .F.
Default aFrete    := {}
Default nTipVei   := 0 //-- Veiculo
Default aDiaHist  := {}
Default cSerTms   := ''
Default cTabFre   := ''
Default cTipTab   := ''
Default cTabCar   := ''
Default lTabPag	  := .F.
Default nMaxCus	  := 0
Default lPreview  := .F.
Default aDocNPrev := {}

//-- Manipula o produto para calculo do frete
If lTMPRDCAL
	cPrdCal := ExecBlock("TMPRDCAL",.F.,.F., { cFilOri , cViagem } )
	If ValType(cPrdCal) == "C" .And. !Empty(cPrdCal)
		cCodPro := cPrdCal
		lPrdCal := .T.
	EndIf
EndIf

DTQ->(DbSetOrder(2))
DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem))

If Empty(cSerTms)
	cSerTms  := DTQ->DTQ_SERTMS
EndIf
If Empty(cTipTra)
	cTipTra  := DTQ->DTQ_TIPTRA
EndIf
If lTipOpVg
	cTipOpVg:= DTQ->DTQ_TPOPVG
EndIf

//Pega o fornecedor do veículo
DA3->(DbSetOrder(1))
If nTipVei == 0 //-- Veiculo
	nDtrValFre := DTR->DTR_VALFRE
	DA3->(MsSeek(xFilial('DA3')+cCodVei))
ElseIf nTipVei == 1 //-- 1o.Reboque
	nDtrValFre := DTR->DTR_VALRB1
	DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB1))
ElseIf nTipVei == 2 //-- 2o.Reboque
	nDtrValFre := DTR->DTR_VALRB2
	DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB2))
ElseIf nTipVei == 3
	nDtrValFre := DTR->DTR_VALRB3
	DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB3))
EndIf

//-- Posiciona na Rota
DA8->(DbSetOrder(1))
If Empty(cCodForn) .And. Empty(cLojForn)
	cCodForn := DA3->DA3_CODFOR
	cLojForn := DA3->DA3_LOJFOR
	DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA))
Else
	DA8->(MsSeek(xFilial("DA8")+PadR( GetMv('MV_ROTGENT'), Len( DA8->DA8_COD ) ) ) )
EndIf

aRet := TMSContrFor(cCodForn, cLojForn,,cSerTms,cTipTra,.F.,DA3->DA3_TIPVEI,cTipOpVg)

If Empty(aRet)
	//-- Pesquisa Contrato com o Tipo de Veiculo Vazio
	aRet := TMSContrFor(cCodForn, cLojForn,,cSerTms,cTipTra,.F., ,cTipOpVg)
EndIf

If Empty(aRet)
	If lMsgErr
		AAdd( aMsgErr, {STR0083 + cCodForn + cLojForn, '03', "TMSA800()" } ) //'Contrato Nao Encontrado para o Fornecedor '
	EndIf
	Return( aRet )
EndIf

If Len(aRet[1]) >= 18
	cAbrCal:= aRet[1][18]
EndIf	

//-- Verifica o Registro de Ocorrencias (DUA) para Viagens de Entrega/Coleta
If	(cSerTms == StrZero(1, Len(DTQ->DTQ_SERTMS))) .Or.;
	(cSerTms == StrZero(3, Len(DTQ->DTQ_SERTMS)))
	
	//--- Controle para exibir a mensagem quando nao houver ocorrencias apontadas para o documento com o parametro .F.
	If 	(cSerTms == StrZero(1, Len(DTQ->DTQ_SERTMS)) .And. !lColSOco) .Or. ;
		(cSerTms == StrZero(3, Len(DTQ->DTQ_SERTMS)) .And. !lEntSOco) 
			lOcorDoc:= .F.
	EndIf

	DUA->(DbSetOrder(2))
	DT2->(DbSetOrder(1))
	If DUA->(MsSeek(cSeekDUA := xFilial('DUA')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
		Do While DUA->( !Eof() .And. DUA_FILIAL+DUA_FILORI+DUA_VIAGEM == cSeekDUA )

			DT2->(MsSeek(xFilial('DT2')+DUA->DUA_CODOCO))
		

			//-- Sera considerado Coleta e Entrega Efetuada se :
			//-- 1) A Ocorrencia for de 'Encerra Processo'.
			//-- 2) A Ocorrencia for de 'Retorno de Docto.', NAO sendo culpa do Motorista e o parametro MV_GERCONT == .T.
			//-- 3) Doc. do tipo "Indicado p/ Entrega" no parametro MV_OCORRDP que esteja no DFV (Redespacho)
			//-- 4) A Ocorrencia for de 'Gera Pendencia' do tipo 'Retorna Doc. Cliente', NAO sendo culpa do Motorista e o parametro MV_GERCONT == .T.

			//-- NAO sera considerado Coleta e Entrega efetuada se :
			//-- 1) A Ocorrencia for de 'Retorno de Docto.' sendo culpa do Motorista
			//-- 2) A Ocorrencia for de 'Retorno de Docto.', NAO sendo culpa do Motorista e o parametro MV_GERCONT == .F.
			//-- 3) A Ocorrencia for de 'Gera Pendencia' do tipo "Retorna Doc.Cliente', sendo culpa do Motorista

			If lLibVgBlq
				lChPesq := DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .Or. ;
								DT2->DT2_TIPOCO == StrZero(2,Len(DT2->DT2_TIPOCO)) .Or. ;
								(DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .And.;
								DT2->DT2_RESOCO <> '3' .And. lGerCont) .Or.;
								(DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And.;
								DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)) .And. DT2->DT2_RESOCO <> '3' .And. lGerCont) .Or.;
								( TmsVldDoc() )

			Else
				lChPesq := DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .Or. ;
								(DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .And.;
								DT2->DT2_RESOCO <> '3' .And. lGerCont) .Or.;
								(DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And.;
								DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)) .And. DT2->DT2_RESOCO <> '3' .And. lGerCont) .Or.;
								( TmsVldDoc() )
			EndIf

			If lChPesq
				lOcorDoc:= .T.
				
				If Empty(DUA->DUA_DOC)
					DUD->(DbSetOrder(2))
					DUD->(MsSeek(cSeekDUD := xFilial('DUD')+DUA->(DUA_FILORI+DUA_VIAGEM)))
					bWhile := { || DUD->(!Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeekDUD .And. TmsDocAPG(DUD->(RECNO()),aDocNPrev)) }
				Else
					DUD->(DbSetOrder(1))
					DUD->(MsSeek(cSeekDUD := xFilial('DUD')+DUA->(DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM)))
					bWhile := { || DUD->(!Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM == cSeekDUD .And. TmsDocAPG(DUD->(RECNO()),aDocNPrev) ) }
				EndIf

				Do While Eval(bWhile)
					
					DT6->(DbSetOrder(1))
					DT6->(MsSeek(xFilial('DT6')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))

					If cAbrCal $ "12"  //Coleta ou Entrega verifica se o CTe esta vinculado a uma SC ou vice-versa
						lRet:= .T.
						If TmsVAbrCal(aDocNPrev)	
							If DUD->DUD_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. cAbrCal == '2'  //Entrega
								lRet:= .F.
								aAdd(aDocAbrCal,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE})
							ElseIf DUD->DUD_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. cAbrCal == '1' //Coleta
								lRet:= .F.
								aAdd(aDocAbrCal,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE})
							EndIf
						EndIf	
					EndIf

					If lPETipDoc //lPETipDoc é .T. quando Ponto de Entrada TMTIPDOC existir
						lRet := Execblock("TMTIPDOC",.F.,.F.)
					EndIf

					If lRet
						//--Obtem o Produto Transportado quando o parametro
						//--MV_PRDDIV estiver desabilitado.
						If !lPrdDiv .And. !lTMPRDCAL
							If cSerTms == StrZero(1, Len(DTQ->DTQ_SERTMS)) .Or.;
							   (DT6->DT6_SERTMS == StrZero(1, Len(DT6->DT6_SERTMS)) .And. DTQ->DTQ_SERADI == '1')
								//--Coleta
								DUM->( DbSetOrder(1) ) //--DUM_FILIAL+DUM_FILORI+DUM_NUMSOL+DUM_ITEM
								If DUM->( MsSeek( xFilial('DUM') + DT6->( DT6_FILDOC + DT6_DOC ) ) )
									If Empty(cCodPro)
										cCodPro := DUM->DUM_CODPRO
									EndIf
									//Lote com produtos diversos, considera como MV_PRDDIV=.T.
									If DUM->DUM_CODPRO <> cCodPro
										lProdDiv:= .T.
									EndIf
								EndIf
							ElseIf cSerTms == StrZero(3, Len(DTQ->DTQ_SERTMS))
								//--Entrega
								DTC->( DbSetOrder(3) ) //--DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
								If DTC->( MsSeek( xFilial('DTC') + DT6->( DT6_FILDOC + DT6_DOC + DT6_SERIE ) ) )
									If Empty(cCodPro)
										cCodPro := DTC->DTC_CODPRO
									EndIf
									//Lote com produtos diversos, considera como MV_PRDDIV=.T.
									If DTC->DTC_CODPRO <> cCodPro
										lProdDiv:= .T.
									EndIf
								EndIf
							EndIf
						EndIf

						//-- Armazena a qtde. de volumes original para verificar com a qtde. de volumes da ocorrencia
						nQtdVol += DT6->DT6_QTDVOL

						//-- Obtem peso e volume dependendo do apontamento da ocorrencia se for por viagem ou docto.
						nPesAux := Iif(Empty(DUA->DUA_PESOCO),DT6->DT6_PESO  ,DUA->DUA_PESOCO)
						nQtdAux := Iif(Empty(DUA->DUA_QTDOCO),DT6->DT6_QTDVOL,DUA->DUA_QTDOCO)

						If cSertms <> StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transferência
							If DT6->DT6_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
								//-- A Quantidade de Entregas da viagem sera controlada de acordo com o Destinatario.
								//-- Ex: Se na mesma viagem, tiver varias entregas para o mesmo destinatario,
								//--     sera considerada 1 Entrega e sera' pago ao carreteiro o valor relativo
								//--     a 1 Entrega.
								cSeqDes := Space(Len(DTC->DTC_SQEDES))
								DTC->(DbSetOrder(3)) //--DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
								If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
									cSeqDes := DTC->DTC_SQEDES
								EndIf
								nSeek := Ascan(aQtdEnt, { |x| x[1]+x[2]+x[3] == DT6->DT6_CLIDES+DT6->DT6_LOJDES+cSeqDes})
								If nSeek == 0
									AAdd(aQtdEnt, {DT6->DT6_CLIDES,DT6->DT6_LOJDES,cSeqDes} )
									nQtdEnt += 1
									//-- Documentos cFilOri, cViagem, cCodVei,
									aAdd(aDocCnt,{1,cFilOri, cViagem, cCodVei,DT6->DT6_SERTMS,DT6->DT6_CLIDES,DT6->DT6_LOJDES,cSeqDes,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE} )
								Else
									//-- Documentos cFilOri, cViagem, cCodVei,
									aAdd(aDocCnt,{2,cFilOri, cViagem, cCodVei,DT6->DT6_SERTMS,DT6->DT6_CLIDES,DT6->DT6_LOJDES,cSeqDes,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE} )
								EndIf
							ElseIf DT6->DT6_SERTMS  == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Coleta
								//-- A Quantidade de Coletas da viagem sera controlada de acordo com o Solicitante/Local da Coleta
								//-- Ex: Se na mesma viagem, tiver varias coletas para o mesmo solicitante,
								//--     sera considerada 1 Coleta e sera' pago ao carreteiro o valor relativo
								//--     a 1 Coleta.
								DT5->(DbSetOrder( 4 ))
								If DT5->(MsSeek(xFilial('DT5')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
									nSeek := Ascan(aQtdCol, { |x| x[1]+x[2] == DT5->DT5_CODSOL+DT5->DT5_SEQEND})
									If nSeek == 0
										AAdd(aQtdCol, {DT5->DT5_CODSOL,DT5->DT5_SEQEND} )
										nQtdCol += 1
										//-- Documentos cFilOri, cViagem, cCodVei,
										aAdd(aDocCnt,{1,cFilOri, cViagem, cCodVei,DT6->DT6_SERTMS,DT5->DT5_CODSOL,,DT5->DT5_SEQEND,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE} )
									Else
										//-- Documentos cFilOri, cViagem, cCodVei,
										aAdd(aDocCnt,{2,cFilOri, cViagem, cCodVei,DT6->DT6_SERTMS,DT5->DT5_CODSOL,,DT5->DT5_SEQEND,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE} )
									EndIf
								EndIf
							EndIf
						EndIf

						//-- Verifica se o calculo devera ser efetuado por servico.
						If lTMTABFRE .And. !IsInCallStack("TMSAF76")
							nSeek := Ascan(aDocVge, { |x| x[1] + x[13] == cCodPro + DT6->DT6_SERVIC })
						ElseIf DTQ->DTQ_SERADI == '1' .And. !IsInCallStack("TMSAF76")
							nSeek := Ascan(aDocVge, { |x| x[1] + x[16] == cCodPro + DT6->DT6_SERTMS })
						Else
							nSeek := Ascan(aDocVge, { |x| x[1] == cCodPro })
						EndIf

						//Adiciona os documentos no array quando achou ocorrencia,
						//para considerar o valor informado na ocorrencia e nao o valor do DT6
						AAdd( aDoctos, {DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE} )

						//--  1 - Codigo Produto
						//--  2 - Qtde. de Volumes do Docto
						//--  3 - Peso Real do Docto
						//--  4 - Qtde. de Doctos
						//--  5 - No. de Diarias ( Semana )
						//--  6 - Pernoites
						//--  7 - Km percorridos
						//--  8 - CTRC com Impostos
						//--  9 - Valor Informado
						//-- 10 - Qtde.de Entregas
						//-- 11 - No. de Diarias ( Fim de Semana )
						//-- 12 - Qtde. de Unitizadores
						//-- 13 - Codigo Servico de Transporte
						//-- 14 - Qtde. de Coletas
						//-- 15 - Peso Cubado
						//-- 16 - Serviço de Transporte
						If nSeek == 0
							AAdd(aDocVge, {cCodPro, nQtdAux, nPesAux, 0, 0, 0, 0, DT6->DT6_VALFRE, DT6->DT6_VALTOT, 0, 0, DT6->DT6_QTDUNI, DT6->DT6_SERVIC, 0, DT6->DT6_PESOM3,DT6->DT6_SERTMS})
						Else
							aDocVge[nSeek][2]  += nQtdAux
							aDocVge[nSeek][3]  += nPesAux
							aDocVge[nSeek][8]  += DT6->DT6_VALFRE
							aDocVge[nSeek][9]  += DT6->DT6_VALTOT
							aDocVge[nSeek][12] += DT6->DT6_QTDUNI
							aDocVge[nSeek][15] += DT6->DT6_PESOM3
						EndIf
						nQtdOco    += nQtdAux
						nPesOco    += nPesAux
						nPesoDoc   += DT6->DT6_PESO
						nPesoM3Doc += DT6->DT6_PESOM3
						nQtdDoc    += 1
					EndIf
					DUD->(dbSkip())
				EndDo
			Else
				//-- Documentos cFilOri, cViagem, cCodVei,
				//--Verifica Docs sem ocorrencias
				If TmsDocAPG(DUD->(RECNO()),aDocNPrev)
					aAdd(aDocCnt,{2,cFilOri, cViagem, cCodVei,,,,,DUA->DUA_FILDOC,DUA->DUA_DOC,DUA->DUA_SERIE} )
				EndIf
			EndIf
			DUA->(dbSkip())
		EndDo
	EndIf
EndIf

//Viagem de Coleta ou Entrega sem Ocorrencias ou Viagens de Transporte
If	(cSerTms == StrZero(1, Len(DTQ->DTQ_SERTMS)) .And. lColSOco) .Or. ;
	(cSerTms == StrZero(3, Len(DTQ->DTQ_SERTMS)) .And. lEntSOco) .Or. ;
	 cSerTms == StrZero(2, Len(DTQ->DTQ_SERTMS)) .Or. lTipCont .Or. lPreview	//-- Viagem de Transporte ou Contrato de Redespachante


	DT6->(DbSetOrder(1))
	DUD->(DbSetOrder(2))
	DUD->( MsSeek(cSeekDUD := xFilial('DUD')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
	Do While DUD->(!Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeekDUD) .And. TmsDocAPG(DUD->(RECNO()),aDocNPrev)

		//Se o documento esta no array considerar este valor, nao verificar novamente o DT6
		If Ascan(aDoctos, { |x| x[1]+x[2]+x[3] == DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE) }) <> 0
			DUD->(DbSkip())
			Loop
		EndIf

		DT6->(DbSetOrder(1))
		DT6->(MsSeek(xFilial('DT6')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))

		If cAbrCal $ "12"   //Coleta ou Entrega verifica se o CTe esta vinculado a uma SC ou vice-versa
			lRet:= .T.
			If TmsVAbrCal(aDocNPrev)	  
				If DUD->DUD_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. cAbrCal == '2'  //Entrega
					lRet:= .F.
					If Ascan(aDocAbrCal, {|x| x[1]+x[2]+x[3] == DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE}) == 0
						aAdd(aDocAbrCal,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE})
					EndIf	
				ElseIf DUD->DUD_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. cAbrCal == '1' //Coleta
					lRet:= .F.
					If Ascan(aDocAbrCal, {|x| x[1]+x[2]+x[3] == DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE}) == 0
						aAdd(aDocAbrCal,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE})
					EndIf	
				EndIf
			EndIf	
		EndIf

		If lPETipDoc .And. cSeekDUD <> '' //lPETipDoc é .T. quando Ponto de Entrada TMTIPDOC existir.
			lRet := Execblock("TMTIPDOC",.F.,.F.)
		EndIf

		If lRet
			//--Obtem o Produto Transportado quando o parametro
			//--MV_PRDDIV estiver desabilitado.
			If !lPrdDiv .And. !lTMPRDCAL
				If cSerTms == StrZero(1, Len(DTQ->DTQ_SERTMS))
					//--Coleta
					DUM->( DbSetOrder(1) ) //--DUM_FILIAL+DUM_FILORI+DUM_NUMSOL+DUM_ITEM
					If DUM->( MsSeek( xFilial('DUM') + DT6->( DT6_FILDOC + DT6_DOC ) ) )
						If Empty(cCodPro)
							cCodPro := DUM->DUM_CODPRO
						EndIf
						//Lote com produtos diversos, considera como MV_PRDDIV=.T.
						If DUM->DUM_CODPRO <> cCodPro
							lProdDiv:= .T.
						EndIf
					EndIf
				ElseIf (cSerTms == StrZero(2, Len(DTQ->DTQ_SERTMS))) .Or.;
					   	cSerTms == StrZero(3, Len(DTQ->DTQ_SERTMS))

					//--Transporte ou Entrega
					DTC->( DbSetOrder(3) ) //--DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
					If DTC->( MsSeek( xFilial('DTC') + DT6->( DT6_FILDOC + DT6_DOC + DT6_SERIE ) ) )
						If Empty(cCodPro)
							cCodPro := DTC->DTC_CODPRO
						EndIf
						//Lote com produtos diversos, considera como MV_PRDDIV=.T.
						If DTC->DTC_CODPRO <> cCodPro
							lProdDiv:= .T.
						EndIf
					EndIf
				EndIf
			EndIf

			//-- A Quantidade de Entregas da viagem sera controlada de acordo com o Destinatario.
			//-- Ex: Se na mesma viagem, tiver varias entregas para o mesmo destinatario,
			//--     sera considerada 1 Entrega e sera' pago ao carreteiro o valor relativo
			//--     a 1 Entrega.
			If cSerTms <> StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transferencia
				If DT6->DT6_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
					cSeqDes := Space(Len(DTC->DTC_SQEDES))
					DTC->(DbSetOrder(3)) //--DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
					If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
						cSeqDes := DTC->DTC_SQEDES
					EndIf
					nSeek := Ascan(aQtdEnt, { |x| x[1]+x[2]+x[3] == DT6->DT6_CLIDES+DT6->DT6_LOJDES+cSeqDes})
					If nSeek == 0
						AAdd(aQtdEnt, {DT6->DT6_CLIDES,DT6->DT6_LOJDES,cSeqDes} )
						nQtdEnt += 1
					EndIf
				ElseIf DT6->DT6_SERTMS  == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Coleta
					DT5->(DbSetOrder( 4 ))
					If DT5->(MsSeek(xFilial('DT5')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
						nSeek := Ascan(aQtdCol, { |x| x[1]+x[2] == DT5->DT5_CODSOL+DT5->DT5_SEQEND})
						If nSeek == 0
							AAdd(aQtdCol, {DT5->DT5_CODSOL,DT5->DT5_SEQEND} )
							nQtdCol += 1
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Verifica se o calculo devera ser efetuado por servico.
			If lTMTABFRE .And. !IsInCallStack("TMSAF76")
				nSeek := Ascan(aDocVge, { |x| x[1] + x[13] == cCodPro + DT6->DT6_SERVIC })
			ElseIf DTQ->DTQ_SERADI == '1' .And. !IsInCallStack("TMSAF76")
				nSeek := Ascan(aDocVge, { |x| x[1] + x[16] == cCodPro + DT6->DT6_SERTMS })
			Else
				nSeek := Ascan(aDocVge, { |x| x[1] == cCodPro })
			EndIf

			If nSeek == 0
				AAdd(aDocVge, {cCodPro, DT6->DT6_QTDVOL, DT6->DT6_PESO, 0, 0, 0, 0, DT6->DT6_VALFRE, DT6->DT6_VALTOT, 0, 0, DT6->DT6_QTDUNI, DT6->DT6_SERVIC, 0, DT6->DT6_PESOM3, DT6->DT6_SERTMS } )
			Else
				aDocVge[nSeek][2]  += DT6->DT6_QTDVOL
				aDocVge[nSeek][3]  += DT6->DT6_PESO
				aDocVge[nSeek][8]  += DT6->DT6_VALFRE
				aDocVge[nSeek][9]  += DT6->DT6_VALTOT
				aDocVge[nSeek][12] += DT6->DT6_QTDUNI
				aDocVge[nSeek][15] += DT6->DT6_PESOM3
			EndIf
			nQtdOco    += DT6->DT6_QTDVOL
			nPesOco    += DT6->DT6_PESO
			nPesoM3Doc += DT6->DT6_PESOM3
			nQtdDoc    += 1
		EndIf
		DUD->(dbSkip())
	EndDo
	nPesoDoc := nPesOco
EndIf

DTR->(DbSetOrder(3))
DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem+cCodVei))

If lTabPag
	If DTR->DTR_TABCAR != cTabCar
		RecLock( "DTR", .F. )
		DTR->DTR_TABCAR := Space(Len(DTR->DTR_TABCAR))
		DTR->DTR_VALFRE := 0
		MsUnlock()
	EndIf
EndIf

aTipVei  := {}
cTipTra  := DTQ->DTQ_TIPTRA
cRota    := DTQ->DTQ_ROTA



If !lTabPag
	cTabFre    := aRet[1][2] //-- Tabela de Frete
	cTipTab    := aRet[1][3] //-- Tipo da Tabela de Frete
	cTabCar    := aRet[1][4] //-- Tabela de Carreteiro
	nMaxCus	 := aRet[1][9] //-- Percentual Rentabilidade x Custo
EndIf
cGerTitPDG := aRet[1][5] //-- Gera Titulo do Pedagio ?
cDedPDG    := aRet[1][6] //-- Deduz Valor do Pedagio do Valor do Frete ?
cGerPC     := aRet[1][7] //-- Gera Pedido de Compra para o Fornecedor (1=Sim / 2=Nao)
cGerTitCont:= aRet[1][8] //-- Gera Titulo do Contrato (1=Sim / 2=Nao)
cTitFrete  := aRet[1][10] //--Gera o Titulo de Frete após a geraçao do contrato, independente do parametro MV_LIBCTC.
cBxTitPdg  := aRet[1][11] //--Efetua a baixa automatica do titulo de pedágio.
lPaMovBco  := aRet[1][12] <> '2' //--Informa se o PA será gerado com movimentação bancária (Baixado ou não -- 1=Sim/Não)
If Len(aRet[1])> 12
	cMomGerAdi := aRet[1][13] //--Momento da geração do título de adiantamento "PA" (0=Geração da Viagem;1=Fechamento da viagem;2=Geração do CTC)
EndIf
If Len(aRet[1])>13
	cTitNDF	   := aRet[1][14] //--Gera o Título de NDF após a geração do contrato, independente do parâmetro MV_LIBCTC.
EndIf
If Len(aRet[1]) > 14
	cMomGerPDG := aRet[1][15]
EndIf
// -- Ponto de Entrada que possibilita a manipulacao do valor do Frete.
If Empty(nDtrValFre) .And. lTMSVLFRE
	nDtrValFre := ExecBlock('TMSVLFRE',.F.,.F.,{ cFilOri, cViagem, cCodVei, cCodForn, cLojForn, cSerTms, cTipTra })
	If ValType(nDtrValFre) <> 'N'
		nDtrValFre := 0
	EndIf
EndIf

If Empty(nDtrValFre)
	If lTMTABCAR
		aTab := ExecBlock("TMTABCAR",.F.,.F., {cTabFre,cTipTab,cTabCar,cCodForn,cLojForn,cSerTms,cTipTra} )
		If ValType(aTab) == "A" .And. Len(aTab) == 3
			cTabFre := IIf( ValType(aTab[1]) == "C" , aTab[1] , cTabFre )
			cTipTab := IIf( ValType(aTab[2]) == "C" , aTab[2] , cTipTab )
			cTabCar := IIf( ValType(aTab[3]) == "C" , aTab[3] , cTabCar )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aTipVei :                                              ³
	//³ aTipVei[n,1] - Tipo do Veiculo                                            ³
	//³ aTipVei[n,2] - Quantidade (no Frete a Pagar sera' sempre 1 /  No Frete a  ³
	//³                            Receber sera a qtde informada na NF do Cliente)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(DTR->DTR_CODCPO)
		DA3->(MsSeek(xFilial('DA3')+cCodVei))
		AAdd(aTipVei, {DA3->DA3_TIPVEI , 1 })

		cChave  := DA3->DA3_TIPVEI
		cVeiRas := DA3->DA3_VEIRAS
		If DA3->(MsSeek(xFilial('DA3')+ DTR->DTR_CODRB1))
			AAdd(aTipVei, {DA3->DA3_TIPVEI , 1 })
			cChave += DA3->DA3_FROVEI
		Else
			cChave += StrZero(0, Len(DA3->DA3_FROVEI))
		EndIf

		If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB2))
			AAdd(aTipVei, {DA3->DA3_TIPVEI , 1 })
			cChave += DA3->DA3_FROVEI
		Else
			cChave += StrZero(0, Len(DA3->DA3_FROVEI))
		EndIf

		If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB3))
			AAdd(aTipVei, {DA3->DA3_TIPVEI , 1 })
			cChave += DA3->DA3_FROVEI
		Else
			cChave += StrZero(0, Len(DA3->DA3_FROVEI))
		EndIf
	Else
		DA3->(MsSeek(xFilial('DA3')+cCodVei))
		AAdd(aTipVei, {DTR->DTR_CODCPO , 1 })
		cChave  := DTR->DTR_CODCPO + StrZero(0, Len(DA3->DA3_FROVEI) * 3)
		cVeiRas := DA3->DA3_VEIRAS
	EndIf
	cChave += cVeiRas

	cChave += DTQ->DTQ_TIPVIA

	aRet    := {}
	//-- Se no Contrato do Fornecedor estiver informado Tabela de Carreteiro, chamar a funcao
	//-- TMSFretCar(), para calcular o Frete.
	If !Empty(cTabCar)

		aFretCar := TMSFretCar(cRota, cCodForn, cLojForn,,cChave,cSerTms,cTipTra,;
					nPesoDoc,nPesoM3Doc,IIF(cTMSOPdg <> '0', DTR->DTR_CODOPE, ''),,cTabCar,Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))

		If !Empty(aFretCar)
			nValFre := aFretCar[2]
		EndIf

		If Len(aFretCar) > 4 .And. !Empty(aFretCar[5])
			Aadd(aFrete,aFretCar[5])
		EndIf

		If Len(aFrete) > 0
			For nCont := 1 to Len(aFrete)
				For nCnt := 1 To Len(aFrete[nCont][2])
					nTotal += aFrete[nCont][2][nCnt][2]
				Next
			Next
			If Len(aFrete) >= 2
				aVetAux := {}
				Aadd(aVetAux,{"",nTotal,'TF',0,0,nTotal}) //-- Total a ser exibido no aFrete
				AAdd(aFrete, {"",aVetAux,""})
			EndIf
		EndIf

		If Empty(nValFre)
			If	lMsgErr
				If !lOcorDoc   //Parametro MV_ENTSOCO = .F. e sem ocorrencias
					AAdd( aMsgErr, {STR0173 + STR0008 + " : " + AllTrim(DTQ->DTQ_FILORI) + ' - ' + AllTrim(DTQ->DTQ_VIAGEM)  } )  //"Verifique se as Ocorrencias para os Documentos da viagem foram apontadas: Viagem : "					
				EndIf

				AAdd( aMsgErr, {STR0084 + cTabCar , '02', "TMSA220()" } ) //"Verifique a Tabela de Carreteiro "
			EndIf
			aSize(aDocAbrCal, 0)
			RestArea(aAreaDUD)
			RestArea(aAreaDTR)
			RestArea(aAreaDTQ)
			Return( aRet )
		EndIf

	ElseIf !Empty(cTabFre)

		//-- Calcula a qtde. de diarias
		dDatIni    := DTQ->DTQ_DATFEC
		dDatFim    := DTQ->DTQ_DATENC
		aDiaSem    := {}	//-- Diarias ( Semana )
		aDiaFimSem := {}	//-- Diarias ( Fim de Semana )
		aDiaBkp    := aClone(aDiaHist)
		Do While dDatIni <= dDatFim
			//-- Se for Sabado ou Domingo
			If Dow(dDatIni) == 7 .Or. Dow(dDatIni) == 1
				If Ascan( aDiaFimSem, { |x| x[1]+x[2] == Dtos(dDatIni) + Iif(lTmsDiaV,cCodVei,"") } ) == 0 ;
					.And. Ascan( aDiaHist, { |x| x[1]+x[2]+x[3] == Dtos(dDatIni) + Iif(lTmsDiaV,cCodVei,"") + "F" } ) == 0
					AAdd( aDiaFimSem, {Dtos(dDatIni), Iif(lTmsDiaV,cCodVei,"") } )
					AAdd( aDiaHist,   {Dtos(dDatIni), Iif(lTmsDiaV,cCodVei,""), "F" } )   //F= Fim de Semana
				EndIf
			Else
				If Ascan( aDiaSem, { |x| x[1]+x[2] == Dtos(dDatIni) + Iif(lTmsDiaV,cCodVei,"") } ) == 0 ;
					.And. Ascan( aDiaHist, { |x| x[1]+x[2]+x[3] == Dtos(dDatIni) + Iif(lTmsDiaV,cCodVei,"") + "S" } ) == 0
					AAdd( aDiaSem,  {Dtos(dDatIni), Iif(lTmsDiaV,cCodVei,"") } )
					AAdd( aDiaHist, {Dtos(dDatIni), Iif(lTmsDiaV,cCodVei,""), "S" } )     //S= Semana
				EndIf
			EndIf
			dDatIni += 1
		EndDo

		nDiaSem    := Len(aDiaSem)      //-- No. de Diarias ( Semana )
		nDiaFimSem := Len(aDiaFimSem)   //-- No. de Diarias ( Fim de Semana )
		cCdrOri    := DA8->DA8_CDRORI   //-- Regiao de Origem
		cCdrDes    := TMSRetRegD(cSerTms,cFilOri,cViagem) //--Região de Destino

		If lTMALTREG
			aReg := ExecBlock('TMALTREG',.F.,.F.,{cCdrOri, cCdrDes})
			If ValType(aReg) == 'A' .And. !Empty(aReg)
				cCdrOri := aReg[1]
				cCdrDes := aReg[2]
			EndIf
		EndIf

		If !Empty(DTQ->DTQ_KMVGE) .And. !Empty(DTQ->DTQ_CDRORI) .And. !Empty(DTQ->DTQ_CDRDES) .And. !Empty(DTQ->DTQ_ROTEIR)
			nQtdKM  := DTQ->DTQ_KMVGE
			cCdrOri := DTQ->DTQ_CDRORI
			cCdrDes := DTQ->DTQ_CDRDES
		ElseIf DTQ->DTQ_STATUS == StrZero(3,Len(DTQ->DTQ_STATUS)) .And. !lKmDist //-- Se a Viagem Encerrada e o parametro MV_KMDIST não habilitado
			DUV->(DbSetOrder(2)) // Tabela de Registros Entradas/Saidas de Veiculos
			DUV->(MsSeek(xFilial('DUV')+ DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI ))
			Do While !DUV->(Eof()) .And. xFilial('DUV')+DUV->DUV_FILORI+DUV->DUV_VIAGEM+;
				DUV->DUV_CODVEI == DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI

				If (DUV->DUV_ODOENT == 0)
					nQtdKM := DUV->DUV_ODOSAI //Quantidade de KM rodado
				ElseIf (DUV->DUV_ODOENT - DUV->DUV_ODOSAI) < 0 // Se odometro de saida maior que o de Entrada virou odometro
					nQtdKM += (Val(Replicate('9',TamSX3("DUV_ODOSAI")[1]))-DUV->DUV_ODOSAI)+DUV->DUV_ODOENT //Quantidade de KM rodado
				Else
					nQtdKM += (DUV->DUV_ODOENT - DUV->DUV_ODOSAI) //Quantidade de KM rodado
				EndIf
				DUV->(dbSkip())
			EndDo
		Else
			// Por Viagem
			If cSerTms <> StrZero(2, Len(DTQ->DTQ_SERTMS))
				nQtdKm := TMSDistRot(,.F.,cCdrOri,cCdrDes)
			Else
				nQtdKm := TMSDistRot(DTQ->DTQ_ROTA,.F.)
			EndIf
		EndIf

		//-- Verifica se existe valor informado para a viagem
		TmsValInf(aValInf,'10',DTQ->DTQ_FILORI,,,,,,,,,,,2,DTQ->DTQ_VIAGEM)

		AAdd(aDocVge, {cCodPro, 0, 0, nQtdDoc, nDiaSem, DTQ->DTQ_QTDPER, nQtdKm, 0, 0, nQtdEnt, nDiaFimSem, 0, Space(Len(DT6->DT6_SERVIC)), nQtdCol, 0,  Space(Len(DT6->DT6_SERTMS)) })

		aFrete := {}

		For nCntFor := 1 To Len(aDocVge)
			//-- Ponto de entrada "TMSSEMDOC" criado para permitir
			//-- calcular o frete a pagar em viagens sem documentos.
			If lPESemDoc //lPESemDoc é .T. quando Ponto de Entrada TMSSEMDOC existir.
				lRetSemDoc := ExecBlock("TMSSEMDOC",.F.,.F., {aDocVge})
				If ( ValType(lRetSemDoc)!= "L")
					lRetSemDoc := .F.
				EndIf
			EndIf
			If ( nCntFor == Len(aDocVge) .And. !lRetSemDoc)
				Exit
			EndIf

			//-- Retorna valores dos componentes 'Peso Mercadoria', 'Valor Mercadoria' e 'Qtde. Volumes'
			If nCntFor == Len(aDocVge)
				nPesoVge   := 0
				nPesoM3Vge := 0
				nMetro3Vge := 0
				nValMerVge := 0
				nQtdVolVge := 0
			Else
				aRetVal := TmsCmpPag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,aDocAbrCal,aDocNPrev,aDocVge[nCntFor][16])
				If !Empty(aRetVal)
					nPesoVge   := aRetVal[1]
					nPesoM3Vge := aRetVal[2]
					nMetro3Vge := aRetVal[3]
					nValMerVge := aRetVal[4]
					nQtdVolVge := aRetVal[5]
				EndIf
			EndIf

			//-- Ponto de entrada TMTABFRE utilizado para trocar a tabela de frete por servico.
			//-- Ponto de entrada TMTABVGE utilizado para trocar a tabela de frete por viagem.
			If lTMTABFRE .Or. lTMTABVGE
				If lTMTABFRE
					aTab := ExecBlock("TMTABFRE",.F.,.F., {cTabFre,cTipTab,cCodForn,cLojForn,cSerTms,cTipTra,aDocVge[nCntFor][13]} )
				Else
					aTab := ExecBlock("TMTABVGE",.F.,.F., {cTabFre,cTipTab,cCodForn,cLojForn,cSerTms,cTipTra,aDocVge[nCntFor][13]} )
				EndIf
				If ValType(aTab) == "A" .And. Len(aTab) == 2
					cTabFre := If (!Empty( aTab[1] ) .And. ValType(aTab[1]) == "C" , aTab[1] , cTabFre )
					cTipTab := If (!Empty( aTab[2] ) .And. ValType(aTab[2]) == "C" , aTab[2] , cTipTab )
					If Empty(cTabFre) .Or. Empty(cTipTab)
						Loop
					EndIf
				EndIf
			EndIf

			//-- Calcula a composicao do frete, baseado na tabela de frete especificada no contrato
			aFreteCol:= {}
			aFretAux := TmsCalFret(	cTabFre,;											// Tabela de Frete
									cTipTab,;											// Tipo da Tabela
									Nil,;												// Seq. Tabela
									cCdrOri,;											// Origem
									cCdrDes,;											// Destino
									Nil,;												// Cod. Cliente
									Nil,;												// Loja Cliente
									Iif(lProdDiv,,aDocVge[nCntFor][1]),;				// Produto
									Nil,;												// Servico
									DTQ->DTQ_SERTMS,;									// Serv. de Transp.
									DTQ->DTQ_TIPTRA,;									// Tipo Transp.
									Nil,;												// No. Contrato
									@aMsgErr,;											// Array Mensagens de Erro
									Nil,;												// NF's por Conhecimento
									0,;													// Valor da Mercadoria
									aDocVge[nCntFor][3],;								// Peso Real do Docto.
									aDocVge[nCntFor][15],;								// Peso Cubado do Docto.
									0,;													// Peso Cobrado
									aDocVge[nCntFor][2],;								// Qtde. de Volumes do Docto.
									0,;													// Desconto
									0,;													// Seguro
									0,;													// Metro Cubico
									IIf(nCntFor==1, aDocVge[Len(aDocVge)][4], 0 ),;	// Qtde. de Doctos
									IIf(nCntFor==1, aDocVge[Len(aDocVge)][5], 0 ),;	// No. de Diarias ( Semana )
									IIf(nCntFor==1, aDocVge[Len(aDocVge)][7], 0 ),;	// Km percorridos
									IIf(nCntFor==1, aDocVge[Len(aDocVge)][6], 0 ),;	// Pernoites
									.T.,; 												// Estabelece o valor minimo do componente
									.F.,;												// Indica que o contrato e' de um cliente generico
									.F.,;												// Ajuste automatico, envia msg se nao encontrar
									IIf(nCntFor==1, aDocVge[Len(aDocVge)][10], 0 ),;	// Qtde.de Entregas
									aDocVge[nCntFor][12],;								// Quantidade de Unitizadores
									0,;													// Valor do Frete do Despachante
									aDocVge[nCntFor][8],;								// CTRC sem Impostos
									aDocVge[nCntFor][9],;								// CTRC com Impostos
									aValInf,;											// Valor Informado
									aTipVei,;											// Tipo de Veiculo
									'',;												// Documento de Transporte
									IIf(nCntFor==1, aDocVge[Len(aDocVge)][11], 0 ),;	// No. de Diarias ( Fim de Semana )
									nPesoVge,;
									nPesoM3Vge,;
									nMetro3Vge,;
									nValMerVge,;
									nQtdVolVge,;
									,;													// No. de Dias Armazenagem
									,;													// Faixa
									,;													// Lote NFC
									,;													// Peso Cubado
									,;													// Praca Pedagio
									,;													// Cliente Devedor
									,;													// Loja Devedor
									,;													// Moeda
									,;													// Excedente TDA
									,;													// Devedor TDA
									,;													// Remetente TDA
									,;													// Destinatario TDA
									IIf(nCntFor==1, aDocVge[Len(aDocVge)][14], 0 ),;	// Qtde.de Coletas
									,;													// Codigo Destinatario
									,;													// Loja Destinatario
									,;													// Sequencia Destinatario
									,;													// Sequencia do Documento
									,;													// Rateio? .T. ou .F.
									,;													// Vetor com as bases do rateio
									,;													// Vetor com a composição do cálculo
									"",;												// Codigo Negociacao
									{},;												// Taxa Devedor
									@aFreteCol )                                  		// Frete Coleta

			DVE->(DbSetOrder(2))
			For nX := 1 To Len(aFretAux)
				If aFretAux[nX,3] <> 'TF'
					aFretAux[nX,6] := aFretAux[nX,2]
					nValFre += aFretAux[nX,2]
					If DVE->(MsSeek(xFilial('DVE') + aFretAux[nX,3] + cTabFre + cTipTab)) .And. DVE->DVE_BASIMP <> '2'
						nBasImp += aFretAux[nX,2]
					EndIf
				Else
					aFretAux[nX,6] := aFretAux[nX,2]
				EndIf
			Next

			If Len(aFretAux) > 0 .And.	aFretAux[Len(aFretAux),3]=='TF'
				AAdd(aFrete,{aDocVge[nCntFor][1],aFretAux,aDocVge[nCntFor][16]})
			EndIf

		Next nCntFor

		If DTQ->DTQ_SERADI == '1'
			For nCntFor := 1 to Len(aFrete)
				If aFrete[nCntFor, 2, Len(aFrete[nCntFor, 2]),3 ]== 'TF'   //Reune os dados de cada componente TF
					If Empty(aCompTot)
						Aadd(aCompTot,Aclone(aFrete[nCntFor, 2, Len(aFrete[nCntFor, 2])]))
					Else
						aCompTot[1][2] += aFrete[nCntFor, 2, Len(aFrete[nCntFor, 2]),2 ]   //-- Valor
						aCompTot[1][5] += aFrete[nCntFor, 2, Len(aFrete[nCntFor, 2]),5 ]   //-- Impostos
						aCompTot[1][6] += aFrete[nCntFor, 2, Len(aFrete[nCntFor, 2]),6 ]   //-- Total (Valor + Impostos)
					EndIf
				EndIf
			Next
			If !(Empty(aCompTot))
				AAdd(aFrete,{"",aCompTot})
			EndIf
		EndIf

		If Empty(nValFre)
			If lMsgErr
				If !lOcorDoc   //Parametro MV_ENTSOCO = .F. e sem ocorrencias
					AAdd( aMsgErr, {STR0173 + STR0008 + " : " + AllTrim(DTQ->DTQ_FILORI) + ' - ' + AllTrim(DTQ->DTQ_VIAGEM)  } )  //"Verifique se as Ocorrencias para os Documentos da viagem foram apontadas: Viagem : "					
				EndIf

				If lCmpDiaria .And. !Empty(aDiaHist) .And. (nDiaSem == 0 .And. nDiaFimSem == 0)
					dDatIni -= 1
					If Ascan( aDiaHist, { |x| x[1]+x[2] == Dtos(dDatFim) + Iif(lTmsDiaV,cCodVei,"") } ) > 0
						AAdd( aMsgErr, {STR0152 + ' ' + Dtoc(dDatIni) + ' - ' + Dtoc(dDatFim) ,'02',} ) //"O Componente
					Else
						AAdd( aMsgErr, {STR0085 + cTabFre + '/' + cTipTab, '02',"TMSA010(, " + STR0003 + ", '2')" } ) //"Verifique a Tabela de Frete "###"Tabela de Frete a Pagar"
					EndIf
				Else
					AAdd( aMsgErr, {STR0085 + cTabFre + '/' + cTipTab, '02',"TMSA010(, " + STR0003 + ", '2')" } ) //"Verifique a Tabela de Frete "###"Tabela de Frete a Pagar"
				EndIf
			EndIf
			aDiaHist := aClone(aDiaBkp) 
			RestArea(aAreaDUD)
			RestArea(aAreaDTR)
			RestArea(aAreaDTQ)
			aSize(aDocAbrCal, 0)
			Return( aRet )
		EndIf
	EndIf
Else
	//-- NAO deve gerar Contrato de Carreteiro para Entregas e Coletas Nao Efetuadas
	If lTmsRvol .And. nQtdOco > 0 .And. nQtdOco < nQtdVol .And. ( DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) .Or. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) )
		nValFre := ( nDtrValFre / nQtdVol ) * nQtdOco
	Else
		nValFre := nDtrValFre
	EndIf
EndIf

//-- Soma no Valor do Frete o valor do Retorno de Reboque
DF7->(DbSetOrder(3)) //-- DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
If DF7->(MsSeek(xFilial('DF7') + cFilOri+cViagem))
	nValFre += DF7->DF7_VALFRE
EndIf

aRet := {}

AAdd(aRet, {cTabFre, cTipTab, nValFre, nQtdOco, nPesOco, nQtdDoc, nDiaSem, nQtdKm, nDiaFimSem, cGerTitPDG, cDedPDG, nBasImp, cTabCar, cGerPC, cGerTitCont, nMaxCus, cTitFrete, cBxTitPdg,cTitNDF , cMomGerAdi,lPaMovBco,cMomGerPDG 	})

//-- Permite a manipulação das informaçoes do array aRet
If lTMSFREPAG
	aRetUsr := ExecBlock("TMSFREPAG",.F.,.F., {aRet, cFilOri, cViagem})
	If ValType(aRetUsr) == "A"
		aRet := aClone(aRetUsr)
	EndIf
EndIf

RestArea(aAreaDUD)
RestArea(aAreaDTR)
RestArea(aAreaDTQ)

//--Ponto de entrada para lista os documentos utilizados na geração do contrato do carreteiro.
If lTMDOCVGE
	ExecBlock("TMDOCVGE",.F.,.F., {aDocCnt, cFilOri, cViagem})
EndIf

aSize(aDocAbrCal, 0)
Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSImpErr ³ Autor³ Eduardo de Souza       ³ Data ³ 05/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao das mensagens encontradas na geracao da informac.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSImpErr( ExpA1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo as mensagens                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSImpErr( aMsgErr )

Local wnrel      := Left(FunName(1),7)
Local Titulo     := STR0001 + " - " + Left(FunName(1),7) // "Mensagens"
Local cDesc1     := STR0002 // "Emite a relacao de mensagens encontradas na geracao da informacao."
Local cDesc2     := ""
Local cDesc3     := ""
Local cString    := ""
Local cPerg      := ""
Local Tamanho    := "G"
Local lEnd       := .F.
Local cNomeProg  := wnrel

Private nLastKey  := 0
Private aReturn   := { STR0005, 1, STR0006, 1, 2, 1, "", 1 } // "Zebrado" ### "Administracao"

// Envia para a SetPrinter
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.F.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

// Chamada da rotina de impressao do relat¢rio...
RptStatus({|lEnd| TMSImpPrc(@lEnd,wnrel,cString,cNomeProg,Titulo,Tamanho,aMsgErr)},Titulo)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSImpPrc ³ Autor³ Eduardo de Souza       ³ Data ³ 05/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao das mensagens                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSImpPrc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSImpPrc(lEnd,wnrel,cString,cNomeProg,Titulo,Tamanho,aMsgErr)

Local nCnt
Local CbCont := 00
Local CbTxt	 := Space( 10 )

m_pag := 1
li    := 80

SetRegua(Len(aMsgErr))
For nCnt := 1 To Len(aMsgErr)
	IncRegua()
	If lEnd
		li++
		@ PROW()+1,001 PSAY STR0007 // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If li > 55
		Cabec(titulo,"","",cNomeProg,Tamanho,IIF(aReturn[4]==1,15,18))
	EndIf
	@ li,000 PSAY aMsgErr[nCnt,1]
	li++
	@ li,000 PSAY __PrtThinLine()
	li++
Next

If Li != 80
	roda(CbCont,CbTxt,Tamanho)
EndIf

//-- Se impressao em disco, chama o gerenciador de impressao...
If aReturn[5] == 1
	SET PRINTER TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsTabFre ³ Autor ³ Eduardo de Souza      ³ Data ³ 31/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a tabela de frete do cliente                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsTabFre(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Cliente                                             ³±±
±±³          ³ExpC2 - Loja                                                ³±±
±±³          ³ExpC3 - Servico                                             ³±±
±±³          ³ExpC4 - Tipo de Frete                                       ³±±
±±³          ³ExpC5 - Codigo de Negociacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTabFre(cCliente, cLoja, cServic, cTipFre, cCodNeg)

Local aContrato := {}
Local aRet      := {}
Local lSelServ  := SuperGetMv("MV_SELSERV",.F.,.F.)

DEFAULT cCodNeg := ""

If Empty(cCliente) .Or. Empty(cLoja)
	Help('',1,'TMSXFUNB40') //"Informe o cliente de calculo da nota fiscal"
	Return( aRet )
ElseIf Empty(cTipFre)
	Help('',1,'TMSXFUNB41') //"Informe o tipo de frete (1=CIF/2=FOB)"
	Return( aRet )
EndIf

aContrato := TMSContrat(cCliente,cLoja,,AllTrim(cServic),,cTipFre,,,,,,,,,,,,,,,,cCodNeg)
If !Empty(aContrato) .And. ( aContrato [1][21] <> StrZero(2,Len(AAM->AAM_SELSER)) .Or. lSelServ .Or. TmsCmpInf(aContrato[1,3], aContrato[1,4]))
	If Empty(cServic)
		Help('',1,'TMSXFUNB42') //"Informe o servico"
	Else
		aRet := { aContrato[1,3], aContrato[1,4] } //-- TabFre ### TipTab
	EndIf
EndIf

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSViewDoc³ Autor ³ Eduardo de Souza      ³ Data ³ 19/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Visualizacao do Docto                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA050Doc(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSViewDoc(cFilDoc,cDocto,cSerie)

Local aAreaDT6 := DT6->(GetArea())
SaveInter() //-- Salva Area

DT6->(DbSetOrder(1))
If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDocto+cSerie))
	cCadastro := STR0004 //"Manutencao de Documentos - Visualizar"
	TMSA500Mnt("DT6",DT6->(Recno()),2)
EndIf

RestInter() //-- Restaura Area
RestArea( aAreaDT6 )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSBIndDV1³ Autor ³ Patricia A. Salomao   ³ Data ³31.05.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a alteracao do indice 1 do arquivo DV1 (Regras de  ³±±
±±³          ³Tributacao por Cliente)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSBIndDV1()

Local cSixChave := ""
Local aArea     := GetArea()
Local aAreaSIX  := SIX->(GetArea())
Local lRet      := .F.

DbSelectArea("SIX")
MsSeek("DV1")
Do While INDICE == "DV1" .And. !Eof()
	cSixChave := AllTrim(CHAVE)
	If SIX->ORDEM == "1"
		If cSixChave == "DV1_FILIAL+DV1_CODCLI+DV1_LOJCLI+DV1_DOCTMS+DV1_CODPRO+DV1_TIPNFC+DV1_TIPCLI+DV1_SEQINS+DV1_REGTRI"
			lRet:=.T.
			Exit
		EndIf
	EndIf
	dbSkip()
EndDo
RestArea(aAreaSIX)
If !lRet
	Help('',1,'TMSXFUNB43') //"Para utilizar esta opcao, favor Alterar o indice 1 do Arquivo DV1 para : DV1_FILIAL+DV1_CODCLI+DV1_LOJCLI+DV1_DOCTMS+DV1_CODPRO+DV1_TIPNFC+DV1_REGTRI"
EndIf
RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsCmpPag ³ Autor ³ Eduardo de Souza      ³ Data ³ 31/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza valores de componente a pagar                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsCmpPag(ExpC1,ExpC2,ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1, ³±±
±±³          ³           ExpC3,ExpC4)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Calcula Sobre                                      ³±±
±±³          ³ ExpC2 - Faixa                                              ³±±
±±³          ³ ExpN1 - Peso                                               ³±±
±±³          ³ ExpN2 - Peso M3                                            ³±±
±±³          ³ ExpN3 - Metro Cubico                                       ³±±
±±³          ³ ExpN4 - Valor Mercadoria                                   ³±±
±±³          ³ ExpN5 - Volumes                                            ³±±
±±³          ³ ExpL1 - Verifica se alterou dados                          ³±±
±±³          ³ ExpC3 - Filial Origem                                      ³±±
±±³          ³ ExpC4 - Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsCmpPag(cFilOri,cViagem,aDocAbrCal,aDocNPrev,cSertms)  

Local cQuery    := ""
Local cAliasNew := GetNextAlias()
Local aRet      := {}
Local lVerAbrCal:= .F.
Local nPESO     := 0 
Local nPESOM3   := 0
Local nMETRO3   := 0 
Local nVALMER   := 0
Local nQTDVOL   := 0
Local lRet      := .T.
Local aAreaDUD  := DUD->(GetArea())

Default cFilOri    := ""
Default cViagem    := ""
Default cSertms    := ""
Default aDocAbrCal := {}
Default aDocNPrev  := {}

lVerAbrCal:= Len(aDocAbrCal) > 0 

cQuery := " SELECT "
If !lVerAbrCal .And. Empty(aDocNPrev)
	cQuery += "   SUM(DT6_VALMER) VALMER, SUM(DT6_PESO)   PESO   , SUM(DT6_PESOM3) PESOM3, "
	cQuery += "   SUM(DT6_METRO3) METRO3, SUM(DT6_VOLORI) QTDVOL "
Else
	cQuery += "   DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_VALMER VALMER, DT6_PESO   PESO   , DT6_PESOM3 PESOM3, "
	cQuery += "   DT6_METRO3 METRO3, DT6_VOLORI QTDVOL, DUD.R_E_C_N_O_ NRECDUD "
EndIf	
cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
cQuery += "   JOIN " + RetSQLName("DT6") + " DT6 "
cQuery += "     ON  DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "     AND DT6_FILDOC = DUD_FILDOC "
cQuery += "     AND DT6_DOC    = DUD_DOC "
cQuery += "     AND DT6_SERIE  = DUD_SERIE "
cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "     AND DUD_FILORI = '" + cFilOri + "' "
cQuery += "     AND DUD_VIAGEM = '" + cViagem + "' "
cQuery += "     AND DUD_SERTMS = '" + cSertms + "' "
If Empty(aDocNPrev) .And. DUD->(ColumnPos('DUD_DTRNPR')) > 0
	cQuery += "     AND DUD_DTRNPR = ' ' "
EndIf
cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
While (cAliasNew)->( !Eof() )
	
	lRet:=.T.
	If !Empty(aDocNPrev)   //Verifica se o Documento não Previsto foi selecionado
		DUD->( DbGoto( (cAliasNew)->NRECDUD ) )
		lRet:= TmsDocAPG((cAliasNew)->NRECDUD,aDocNPrev)
	EndIf	
	
	If lRet .And. lVerAbrCal  //Verifica se o Documento faz parte da Abrangencia de Calculo
		lRet:= Ascan(aDocAbrCal, {|x| x[1]+x[2]+x[3] == (cAliasNew)->DT6_FILDOC + (cAliasNew)->DT6_DOC + (cAliasNew)->DT6_SERIE}) == 0
	EndIf

	If lRet
		nPESO   += (cAliasNew)->PESO   
		nPESOM3 += (cAliasNew)->PESOM3 
		nMETRO3 += (cAliasNew)->METRO3 
		nVALMER += (cAliasNew)->VALMER 
		nQTDVOL += (cAliasNew)->QTDVOL 
	EndIf

	If !lVerAbrCal .And. Empty(aDocNPrev)
		Exit
	EndIf

	(cAliasNew)->(dbSkip())
EndDo

If nPESO > 0 .Or. nPESOM3 > 0 .Or. nMETRO3 > 0 .Or. nVALMER > 0 .Or. nQTDVOL > 0
	AAdd( aRet, nPESO   )
	AAdd( aRet, nPESOM3 )
	AAdd( aRet, nMETRO3 )
	AAdd( aRet, nVALMER )
	AAdd( aRet, nQTDVOL )
EndIf

(cAliasNew)->(DbCloseArea())

RestArea(DUD->(GetArea()))
Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsCEPEnt ³ Autor ³ Eduardo de Souza     ³ Data ³ 11/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o CEP de coleta/entrega                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsCEPEnt(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente                                            ³±±
±±³          ³ ExpC2 - Loja                                               ³±±
±±³          ³ ExpC3 - Codigo do Solicitante                              ³±±
±±³          ³ ExpC4 - Sequencia Endereco                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA200 / TMSA460 / TMSXFUNC                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCEPEnt(cCliente,cLoja,cCodSol,cSeqEnd, cCodRegiao)

Local cCEP 			:= ''

Default cCliente	:= ''
Default cLoja	 	:= ''	
Default cCodSol		:= ''
Default cSeqEnd		:= ''
Default cCodRegiao	:= ''

If !Empty(cCliente) .And. !Empty(cLoja) //-- Cep do Cliente
	cCEP := M_Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_CEPE")
	If Empty(cCEP)
		cCEP := SA1->A1_CEP
		cCodRegiao := SA1->A1_CDRDES		
	EndIf
	If !Empty(cSeqEnd)
		If !Empty(cSeqEnd)
			cCEP := M_Posicione("DUL",2,xFilial("DUL")+cCliente+cLoja+cSeqEnd,"DUL_CEP")
			cCodRegiao := DUL->DUL_CDRDES
		EndIf
	EndIf
ElseIf !Empty(cCodSol) .Or. !Empty(cSeqEnd) //-- Codigo do Solicitante
	If !Empty(cSeqEnd) //-- Sequencia de endereco
		cCEP 		:= M_Posicione("DUL",3,xFilial("DUL")+cCodSol+cSeqEnd,"DUL_CEP")
		cCodRegiao 	:= DUL->DUL_CDRDES
	Else
		cCEP 		:= M_Posicione("DUE",1,xFilial("DUE")+cCodSol,"DUE_CEP")
		cCodRegiao 	:= DUE->DUE_CDRSOL
	EndIf
EndIf

Return( cCEP )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsCEPDUD ³ Autor ³ Eduardo de Souza     ³ Data ³ 11/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o CEP dos movimentos de viagens.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsCEPDUD(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - CEP                                                ³±±
±±³          ³ ExpC2 - Cliente                                            ³±±
±±³          ³ ExpC3 - Loja                                               ³±±
±±³          ³ ExpC4 - Codigo do Solicitante                              ³±±
±±³          ³ ExpC5 - Sequencia Endereco                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCEPDUD(cCEP,cCliente,cLoja,cCodsol,cSeqEnd)

Local cAliasQry := GetNextAlias()
Local aAreaSM0  := {}
Local nCnt      := 0
Local lAtuFil   := .F.
Local aArea     := GetArea()
Default cSeqEnd := CriaVar("DT5_SEQEND",.F.)

If Empty(aSM0CodFil)
	aAreaSM0  := SM0->(GetArea())
	DbSelectArea("SM0")
	DbGoTop()
	While !Eof()
		If SM0->M0_CODIGO == cEmpAnt
			AAdd(aSM0CodFil, SM0->M0_CODFIL)
		EndIf
		DbSkip()
	EndDo
	RestArea( aAreaSM0 )
EndIf

If cCliente <> Nil .And. cLoja <> Nil //-- CEP do Cliente
	cQuery := " SELECT DUD.R_E_C_N_O_ R_E_C_N_O_ "
	cQuery += "   FROM " + RetSQLName("DT6") + " DT6 "
	cQuery += "   JOIN " + RetSQLName("DUD") + " DUD "
	cQuery += "     ON DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "     AND DUD_FILDOC = DT6_FILDOC "
	cQuery += "     AND DUD_DOC    = DT6_DOC "
	cQuery += "     AND DUD_SERIE  = DT6_SERIE "
	cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "   WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "     AND DT6_CLIDES = '" + cCliente + "' "
	cQuery += "     AND DT6_LOJDES = '" + cLoja    + "' "
	cQuery += "     AND DUD_STATUS = '1' "
	cQuery += "     AND DT6.D_E_L_E_T_ = ' '"
ElseIf cCodsol <> Nil  //-- Codigo do Solicitante
	If Empty(xFilial("DT5"))
		cQuery := " SELECT DUD.R_E_C_N_O_ R_E_C_N_O_ "
		cQuery += "   FROM " + RetSQLName("DT5") + " DT5 "
		cQuery += "   JOIN " + RetSQLName("DUD") + " DUD "
		cQuery += "     ON DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_FILDOC = DT5_FILDOC "
		cQuery += "     AND DUD_DOC    = DT5_DOC "
		cQuery += "     AND DUD_SERIE  = DT5_SERIE "
		cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
		cQuery += "   WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
		cQuery += "     AND DT5_CODSOL    = '" + cCodsol + "' "
		cQuery += "     AND DT5_SEQEND = '" + cSeqEnd + "' "
		cQuery += "     AND DUD_STATUS = '1' "
		cQuery += "     AND DT5.D_E_L_E_T_ = ' '"
	Else
		//-- Atualizacao por filial
		lAtuFil := .T.
		For nCnt := 1 To Len(aSM0CodFil)
			cQuery := " SELECT DUD.R_E_C_N_O_ R_E_C_N_O_ "
			cQuery += "   FROM " + RetSQLName("DT5") + " DT5 "
			cQuery += "   JOIN " + RetSQLName("DUD") + " DUD "
			cQuery += "     ON DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "     AND DUD_FILDOC = DT5_FILDOC "
			cQuery += "     AND DUD_DOC    = DT5_DOC "
			cQuery += "     AND DUD_SERIE  = DT5_SERIE "
			cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += "   WHERE DT5_FILIAL = '" + aSM0CodFil[nCnt] + "' "
			cQuery += "     AND DT5_CODSOL    = '" + cCodsol + "' "
			cQuery += "     AND DT5_SEQEND = '" + cSeqEnd + "' "
			cQuery += "     AND DUD_STATUS = '1' "
			cQuery += "     AND DT5.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			While (cAliasQry)->(!Eof())
				cQuery := " UPDATE " + RetSqlName("DUD") + " SET DUD_CEPENT = '" + cCEP + "' "
				cQuery += "   WHERE R_E_C_N_O_  = '" + AllTrim(Str(R_E_C_N_O_)) + "' "
				TCSqlExec( cQuery )
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		Next nCnt
	EndIf
EndIf

//-- Verifica se a atualizacao ja foi efetuada por filial.
If !lAtuFil
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())
		cQuery := " UPDATE " + RetSqlName("DUD") + " SET DUD_CEPENT = '" + cCEP + "' "
		cQuery += "   WHERE R_E_C_N_O_  = '" + AllTrim(Str(R_E_C_N_O_)) + "' "
		TCSqlExec( cQuery )
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
EndIf

RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsTELDUL ³ Autor ³ Leandro Paulino     ³ Data ³ 02/03/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o DDD/Telefone na Sequencia de Endereco           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsTELDUL(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - DDD                                                ³±±
±±³          ³ ExpC2 - Telefone                                           ³±±
±±³          ³ ExpC3 - Cliente                                            ³±±
±±³          ³ ExpC4 - Loja					                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTELDUL(cDDD,cTel,cCliente,cLoja,cDDDAnt,cTelAnt,cCodSol)

Local   cAliasQry := GetNextAlias()
Local   aArea     := GetArea()
Local   aQtdFil	:= FWAllFilial(,,SM0->M0_CODIGO)
Local   nQtdFil   := Len(aQtdFil)
Local   nCnt		:= 0

If cCliente <> Nil .And. cLoja <> Nil .And. !Empty(cCodSol)//-- Telefone do Cliente
	For nCnt := 1 To nQtdFil
		cQuery := " SELECT DUL.R_E_C_N_O_ DULRECNO "
		cQuery += "   FROM " + RetSQLName("DUL") + " DUL "
		cQuery += "   WHERE DUL_FILIAL = '" + Iif(Empty(FWFilial('DUL')),xFilial('DUL'),aQtdFil[nCnt]) +"'"
		cQuery += "     AND DUL_CODCLI = '" + cCliente + "' "
		cQuery += "     AND DUL_LOJCLI = '" + cLoja    + "' "
		cQuery += "     AND CODSOL    = '" + cCodSol  + "' "
		cQuery += "     AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		While (cAliasQry)->(!Eof())
			DUL->(dbGoTo((cAliasQry)->DULRECNO))
			RecLock('DUL',.F.)
			DUL->DUL_DDD 	:= cDDD
			DUL->DUL_TEL 	:= cTel
			DUL->DUL_CODSOL	:= cCodSol
			MsUnLock()
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		If Empty(FWFilial('DUL'))
			Exit
		EndIf
	Next nCnt
EndIf

RestArea( aArea )

Return ( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSSeqIns ³ Autor ³ Eduardo de Souza     ³ Data ³ 28/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a sequencia da inscricao estadual do devedor       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSSeqIns(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Documento                                   ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSSeqIns(cFilDoc,cDocto,cSerie)

Local cSeqIns  := ''
Local cSeekDTC := ''
Local aAreaDTC := DTC->(GetArea())
Local aAreaDT6 := DT6->(GetArea())

DT6->(DbSetOrder(1))
If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDocto+cSerie))
	If Empty(DT6->DT6_FILDCO)
		cSeekDTC := xFilial("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE
	Else
		cSeekDTC := xFilial("DTC")+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO
	EndIf
	DTC->(DbSetOrder(3))
	If DTC->(MsSeek(cSeekDTC))
		cSeqIns := ""
		Do Case
			Case DTC->DTC_DEVFRE == "1" .And. !Empty(DTC->DTC_SQIREM)
				cSeqIns := DTC->DTC_SQIREM
			Case DTC->DTC_DEVFRE == "2" .And. !Empty(DTC->DTC_SQIDES)
				cSeqIns := DTC->DTC_SQIDES
			Case DTC->DTC_DEVFRE == "3" .And. !Empty(DTC->DTC_SQICON)
				cSeqIns := DTC->DTC_SQICON
			Case DTC->DTC_DEVFRE == "4" .And. !Empty(DTC->DTC_SQIDPC)
				cSeqIns := DTC->DTC_SQIDPC
		EndCase
	EndIf
EndIf

RestArea( aAreaDTC )
RestArea( aAreaDT6 )

Return( cSeqIns )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSOperad³ Autor ³ Vitor Raspa           ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3( DEG ) para obter os Operadores (Gestores) de  ³±±
±±³          ³ Frota                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSOperad(cCampo)
TMSValField(cCampo,,,.T.)
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAvalFun  ³ Autor ³ Rodolfo K. Rosseto ³ Data ³13.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia se a funcao digitada e valida                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAvalFun(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Funcao que sera avaliada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAvalFun(cFor)

Local lRet  := .T.
Local bErro := ErrorBlock( { |e| TMSERRFORM( e ) } )

cFor := AllTrim(cFor)

If Len(cFor) > 0
	lRet := TMSExecFun(cFor)
	ErrorBlock( bErro )
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSExecFun  ³ Autor ³ Rodolfo K. Rosseto ³ Data ³13.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a Funcao e retorna o resultado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSExecFun(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Funcao que sera executada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSExecFun(cFor)

Local lRet := .T.

Begin Sequence
	cFor := &(cFor)
	lRet := If(!(cFor==Nil).And.ValType(cFor)=='L',cFor,.T.)
	Recover
	lRet := .F.
End Sequence

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSErrForm| Autor ³ Rodolfo K. Rosseto       ³Data³13.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se houve erro                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto error                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSErrForm( oError )

If ( oError:gencode > 0 )
	Break
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSDespCx ºAutor  ³Helio Novais        º Data ³  05/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisar se existe algum movimento no caixinha para        º±±
±±º          ³uma viagem especifica                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ TMSDespCx(cFilOri,cViagem)                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Filial Origem                                      º±±
±±º          ³ ExpC2 - Numeracao da Viagem                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA144,TMSA141,TMSA140                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDespCx(cFilOri,cViagem)
Local aAreaAnt	:= GetArea()
Local cQuery    := ''
Local cAliasTop := ''
Local lRet      := .F.

cAliasTop := GetNextAlias()
cQuery    := "SELECT Count(*) QTDE FROM "
cQuery    += RetSqlName("SEU")+" SEU "
cQuery    += " WHERE  SEU.EU_FILIAL  = '"+xFilial("SEU")+"'"
cQuery    += "   AND  SEU.EU_FILORI  = '"+cFilOri+"'"
cQuery    += "   AND  SEU.EU_VIAGEM  = '"+cViagem+"'"
cQuery    += "   AND  SEU.EU_TIPO   <> '02'"
cQuery    += "   AND  NOT EXISTS (SELECT 1 FROM "
cQuery    +=                               RetSqlName("SEU")+" SEU2"
cQuery    += "                             WHERE SEU2.EU_FILIAL  = SEU.EU_FILIAL "
cQuery    += "                               AND SEU2.EU_NROADIA = SEU.EU_NUM "
cQuery    += "                               AND SEU2.EU_TIPO   = '02' "
cQuery    += "                               AND SEU2.D_E_L_E_T_ = ' ')"
cQuery    += "  AND  SEU.D_E_L_E_T_ = ' '"
cQuery    := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)

If (cAliasTop)->(!Eof()) .And. (cAliasTop)->QTDE > 0
	lRet := .T.
EndIf
(cAliasTop)->(DbcloseArea())
RestArea(aAreaAnt)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMCalFrtPg³ Autor³Rodolfo K. Rosseto      ³ Data ³14/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o Frete a Pagar do OMS e TMS                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tipo de Uso 1=Viagem 2=Carga                        ³±±
±±³          ³ExpC2 - Identificador de Carga e Viagem                     ³±±
±±³          ³ExpC3 - Codigo do Veiculo                                   ³±±
±±³          ³ExpA4 - Array que ira' conter as Mensagens de Erro          ³±±
±±³          ³ExpL5 - Controla se adiciona as mensagens de erro no array  ³±±
±±³          ³        aMsgErr                                             ³±±
±±³          ³ExpA6 - Array que ira' conter a composicao do Frete         ³±±
±±³          ³ExpN7 - Tipo do Veiculo 0=Veic. 1=1oReb. 2=2oReb. 3=3oReb.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array: [01] - Tabela de Frete                               ³±±
±±³          ³       [02] - Tipo da Tabela de Frete                       ³±±
±±³          ³       [03] - Valor do Frete                                ³±±
±±³          ³       [04] - Qtde de Volumes                               ³±±
±±³          ³       [05] - Peso                                          ³±±
±±³          ³       [06] - Qtde. de Documentos                           ³±±
±±³          ³       [07] - Qtde. Dias da Semana                          ³±±
±±³          ³       [08] - Quilometragem                                 ³±±
±±³          ³       [09] - Qtde. Dias Fim de Semana                      ³±±
±±³          ³       [10] - Gera Titulo de Pedagio (1=Sim / 2=Nao)        ³±±
±±³          ³       [11] - Deduz Valor do Pdg. do Frete (1=Sim / 2=Nao)  ³±±
±±³          ³       [12] - Base de Calculo dos Impostos                  ³±±
±±³          ³       [13] - Codigo da Tabela de Carreteiro                ³±±
±±³          ³       [14] - Gerar Pedido de Compra (1=Sim / 2=Nao)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMCalFrtPg( cTipUso, cIdent, cCodVei, aMsgErr, lMsgErr, aFrete, nTipVei )

Local cSerTms     := ''
Local cTipTra     := ''
Local cRota       := ''
Local cCodForn    := ''
Local cLojForn    := ''
Local cTabFre     := ''
Local cTipTab     := ''
Local cTabCar     := ''
Local cCodPro     := STR0081 //"FRETE A PAGAR"
Local cPrdCal     := ''
Local lPrdCal     := .F.
Local cChave      := ''
Local cVeiRas     := ''
Local cCdrOri     := ''
Local cCdrDes     := ''
Local aFretCar    := {}
Local aDocVge     := {}
Local aRet        := {}
Local aTipVei     := {}
Local aTab        := {}
Local nCntFor     := 0
Local nValFre     := 0
Local nQtdVol     := 0
Local nPesoDoc    := 0
Local nPesoM3Doc  := 0
Local nQtdOco     := 0
Local nX
Local aValInf     := {}
Local lTMTABCAR   := ExistBlock("TMTABCAR")
Local lTMTABFRE   := ExistBlock("TMTABFRE")
Local lTMPRDCAL   := ExistBlock("TMPRDCAL")
Local lTMALTREG   := ExistBlock("TMALTREG")
Local aReg        := {}
Local nMetro3Vge  := 0
Local nBasImp     := 0
Local cGerTitPDG  := "1" //-- Gera Titulo de Pedagio :Sim
Local cGerTitCont := "1" //-- Gera Titulo do Contrato de Carreteiro :Sim
Local cDedPDG     := "2" //-- Deduz Pedagio do Valor do Frete : Nao
Local nValFreInf  := 0
Local cGerPC      := IIF(GetMV('MV_TMSGRPC',,.F.), '1', '2')
Local cTMSOPdg    := SuperGetMV( 'MV_TMSOPDG',, '0' ) //-- Operadoras de Frota/Vale-Pedagio
Local lTmsRvol    := SuperGetMV('MV_TMSRVOL',,.T.) //-- Efetua rateio de volumes coletados e ou entregues
Local cTitFrete	:= '' 	//--Gera o Titulo de Frete após a geraçao do contrato, independente do parametro MV_LIBCTC.
Local cBxTitPdg	:= ''	//--Efetua a baixa automatica do titulo de pedágio.
Local cTitNDF	:= '2' //--(1=Sim;2=Não) - Controla se gera NDF no momento da geração do contrato mesmo que a lliberação do contrato esteja habilitada (MV_LIBCTC == .T.)
Local lTipOpVg  := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local cTipOpVg  := ""

Default cCodVei    := ''
Default aMsgErr    := {}
Default lMsgErr    := .F.
Default aFrete     := {}
Default nTipVei    := 0 //-- Veiculo

//-- Posiciona na tabela de totais de viagem e carga

DFI->(DbSetOrder(1))
DFI->(MsSeek(xFilial('DFI')+cTipUso+cIdent))

If cTipUso == '1' //-- Viagem
	DTQ->(DbSetOrder(6)) //DTQ_FILIAL+DTQ_IDENT
	DTQ->(MsSeek(xFilial('DTQ')+cIdent))
	DTR->(DbSetOrder(3))
	DTR->(MsSeek(xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+cCodVei))
	If nTipVei == 0
		nValFreInf := DTR->DTR_VALFRE
	ElseIf nTipVei == 1
		nValFreInf := DTR->DTR_VALRB1
	ElseIf nTipVei == 2
		nValFreInf := DTR->DTR_VALRB2
	ElseIf nTipVei == 3
		nValFreInf := DTR->DTR_VALRB3
	EndIf
	If lTipOpVg
		cTipOpVg := DTQ->DTQ_TPOPVG
	EndIf
ElseIf cTipUso == '2' //-- Carga
	DAK->(DbSetOrder(4))
	If DAK->(MsSeek(xFilial('DAK')+cIdent))
		nValFreInf := M_Posicione('DAS',1,xFilial('DAS')+DAK->(DAK_COD+DAK_SEQCAR),"DAS_VALFRE")
	EndIf
EndIf

//-- Manipula o produto para calculo do frete
If lTMPRDCAL
	If cTipUso == '1' //-- Viagem
		cPrdCal := ExecBlock("TMPRDCAL",.F.,.F., { DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM } )
	Else
		cPrdCal := ExecBlock("TMPRDCAL",.F.,.F., { DAK->DAK_COD   , DAK->DAK_SEQCAR } )
	EndIf
	If ValType(cPrdCal) == "C" .And. !Empty(cPrdCal)
		cCodPro := cPrdCal
		lPrdCal := .T.
	EndIf
EndIf

//-- REVER PONTO TMTABFRE

aTipVei  := {}
cSerTms  := DFI->DFI_SERTMS
cTipTra  := DFI->DFI_TIPTRA
If cTipUso == '1' //-- Viagem
	cRota := DTQ->DTQ_ROTA
ElseIf cTipUso == '2' //-- Carga
	cRota := M_Posicione("DAI",1,xFilial("DAI")+DAK->(DAK_COD+DAK_SEQCAR),"DAI->DAI_ROTEIR")
EndIf
DA3->(DbSetOrder(1))
If cTipUso == '1' //-- Viagem
	If nTipVei == 0 //-- Veiculo
		DA3->(MsSeek(xFilial('DA3')+cCodVei))
	ElseIf nTipVei == 1 //-- 1o.Reboque
		DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB1))
	ElseIf nTipVei == 2 //-- 2o.Reboque
		DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB2))
	ElseIf nTipVei == 3
		DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB3))
	EndIf
ElseIf cTipUso == '2' //-- Carga
	DA3->(MsSeek(xFilial('DA3')+cCodVei))
EndIf

cCodForn := DA3->DA3_CODFOR
cLojForn := DA3->DA3_LOJFOR

aRet := TMSContrFor(cCodForn, cLojForn,,cSerTms,cTipTra,.F.,DA3->DA3_TIPVEI,cTipOpVg)

If Empty(aRet)
	//-- Pesquisa Contrato com o Tipo de Veiculo Vazio
	aRet := TMSContrFor(cCodForn, cLojForn,,cSerTms,cTipTra,.F., ,cTipOpVg)
EndIf

If !Empty(aRet)
	cGerTitCont := aRet[1][8] //--Gera Titulo para o Contrato?
	cGerTitPDG  := aRet[1][5] //-- Gera Titulo do Pedagio ?
EndIf

If Empty(nValFreInf)
	If Empty(aRet)
		If lMsgErr
			AAdd( aMsgErr, {STR0083 + cCodForn + cLojForn, '03', "TMSA800()" } ) //'Contrato Nao Encontrado para o Fornecedor '
		EndIf
		Return( aRet )
	EndIf

	cTabFre    := aRet[1][2] //-- Tabela de Frete
	cTipTab    := aRet[1][3] //-- Tipo da Tabela de Frete
	cTabCar    := aRet[1][4] //-- Tabela de Carreteiro
	cGerTitPDG := aRet[1][5] //-- Gera Titulo do Pedagio ?
	cDedPDG    := aRet[1][6] //-- Deduz Valor do Pedagio do Valor do Frete ?
	cGerPC     := aRet[1][7] //-- Gera Pedido de Compra para o Fornecedor (1=Sim / 2=Nao)
	cGerTitCont:= aRet[1][8] //-- Gera Titulo do Contrato de Carreteiro ? (1=Sim / 2=Nao)
	cTitFrete  := aRet[1][10] //--Gera o Titulo de Frete após a geraçao do contrato, independente do parametro MV_LIBCTC.
	cBxTitPdg  := aRet[1][11] //--Efetua a baixa automatica do titulo de pedágio.
	cTitNDF    := aRet[1][13] //--(1=Sim;2=Não) - Controla se gera NDF no momento da geração do contrato mesmo que a lliberação do contrato esteja habilitada (MV_LIBCTC == .T.)

	If lTMTABCAR
		aTab := ExecBlock("TMTABCAR",.F.,.F., {cTabFre,cTipTab,cTabCar,cCodForn,cLojForn,cSerTms,cTipTra} )
		If ValType(aTab) == "A" .And. Len(aTab) == 3
			cTabFre := If (!Empty( aTab[1] ) .And. ValType(aTab[1]) == "C" , aTab[1] , cTabFre )
			cTipTab := If (!Empty( aTab[2] ) .And. ValType(aTab[2]) == "C" , aTab[2] , cTipTab )
			cTabCar := If (!Empty( aTab[3] ) .And. ValType(aTab[3]) == "C" , aTab[3] , cTabCar )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aTipVei :                                              ³
	//³ aTipVei[n,1] - Tipo do Veiculo                            						³
	//³ aTipVei[n,2] - Quantidade (no Frete a Pagar sera' sempre 1 /  No Frete a  ³
	//³                            Receber sera a qtde informada na NF do Cliente)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DA3->(MsSeek(xFilial('DA3')+cCodVei))
	cVeiRas := DA3->DA3_VEIRAS

	If Empty(DTR->DTR_CODCPO)
		AAdd(aTipVei, {DA3->DA3_TIPVEI, 1 })
		cChave  := DA3->DA3_TIPVEI

		If cTipUso == '1' //-- Viagem
			If DA3->(MsSeek(xFilial('DA3') + DTR->DTR_CODRB1))
				AAdd(aTipVei, {DA3->DA3_TIPVEI, 1 })
				cChave += DA3->DA3_FROVEI
			Else
				cChave += StrZero(0, Len(DA3->DA3_FROVEI))
			EndIf

			If DA3->(MsSeek(xFilial('DA3') + DTR->DTR_CODRB2))
				AAdd(aTipVei, {DA3->DA3_TIPVEI, 1 })
				cChave += DA3->DA3_FROVEI
			Else
				cChave += StrZero(0, Len(DA3->DA3_FROVEI))
			EndIf

			If DA3->(MsSeek(xFilial('DA3') + DTR->DTR_CODRB3))
				AAdd(aTipVei, {DA3->DA3_TIPVEI, 1 })
				cChave += DA3->DA3_FROVEI
			Else
				cChave += StrZero(0, Len(DA3->DA3_FROVEI))
			EndIf
		ElseIf cTipUso == '2' //-- Carga
			cChave += '00'
		EndIf
	Else
		AAdd(aTipVei, {DA3->DTR_CODCPO, 1 })
		cChave := DTR->DTR_CODCPO
		cChave += StrZero(0, Len(DA3->DA3_FROVEI) * 3)
	EndIf

	cChave += cVeiRas

	If cTipUso == '1' //-- Viagem
		cChave += DTQ->DTQ_TIPVIA
	ElseIf cTipUso == '2' //-- Carga
		cChave += '0'
	EndIf

	aRet := {}
	//-- Se no Contrato do Fornecedor estiver informado Tabela de Carreteiro, chamar a funcao
	//-- TMSFretCar(), para calcular o Frete.
	If !Empty(cTabCar)
		If cTipUso == '1' //-- Viagem
			aFretCar := TMSFretCar(cRota, cCodForn, cLojForn,,cChave,cSerTms,cTipTra,;
						nPesoDoc,nPesoM3Doc,IIF(cTMSOPdg <> '0', DTR->DTR_CODOPE, ''),,,cTipOpVg)
		ElseIf cTipUso == '2' //-- Carga
			aFretCar := TMSFretCar(cRota, cCodForn, cLojForn,,cChave,cSerTms,cTipTra,;
						nPesoDoc,nPesoM3Doc,IIF(cTMSOPdg <> '0', DAK->DAK_CODOPE, ''),,,cTipOpVg)
		EndIf

		If !Empty(aFretCar)
			nValFre := aFretCar[2]
		EndIf

		If Empty(nValFre)
			If	lMsgErr
				AAdd( aMsgErr, {STR0084 + cTabCar , '02', "TMSA220()" } ) //"Verifique a Tabela de Carreteiro "
			EndIf
			Return( aRet )
		EndIf

	ElseIf !Empty(cTabFre)

		If lTMALTREG
			aReg := ExecBlock('TMALTREG',.F.,.F.,{DFI->DFI_CDRORI, DFI->DFI_CDRDES})
			If ValType(aReg) == 'A'	.And. !Empty(aReg)
				cCdrOri := aReg[1]
				cCdrDes := aReg[2]
			EndIf
		EndIf

		//-- Verifica se existe valor informado para a viagem
		If cTipUso == '1' //-- Viagem
			TmsValInf(aValInf,'10',DTQ->DTQ_FILORI,,,,,,,,,,,2,DTQ->DTQ_VIAGEM)
		ElseIf cTipUso == '2' //-- Carga
			OM320ValInf(4,@aValInf,DAK->DAK_COD)
		EndIf

		AAdd(aDocVge, {cCodPro, 0, 0, DFI->DFI_QTDDOC, DFI->DFI_QTDIAS, DFI->DFI_QTDPER, DFI->DFI_QTDKM, 0, 0, DFI->DFI_QTDENT, DFI->DFI_QTFIMS, 0, Space(Len(DT6->DT6_SERVIC)), 0, 0 })

		aFrete := {}

		For nCntFor := 1 To Len(aDocVge)

			//-- Ponto de entrada utilizado para trocar a tabela de frete por servico.
			If lTMTABFRE
				aTab := ExecBlock("TMTABFRE",.F.,.F., {cTabFre,cTipTab,cCodForn,cLojForn,cSerTms,cTipTra,aDocVge[nCntFor][13]} )
				If ValType(aTab) == "A" .And. Len(aTab) == 2
					cTabFre := If (!Empty( aTab[1] ) .And. ValType(aTab[1]) == "C" , aTab[1] , cTabFre )
					cTipTab := If (!Empty( aTab[2] ) .And. ValType(aTab[2]) == "C" , aTab[2] , cTipTab )
					If Empty(cTabFre) .Or. Empty(cTipTab)
						Loop
					EndIf
				EndIf
			EndIf

			//-- Calcula a composicao do frete, baseado na tabela de frete especificada no contrato
			aFretAux:=TmsCalFret(	cTabFre					,; // Tabela de Frete
									cTipTab					,; // Tipo da Tabela
															,; // Seq. Tabela
									DFI->DFI_CDRORI			,; // Origem
									DFI->DFI_CDRDES			,; // Destino
															,; // Cod. Cliente
															,; // Loja Cliente
									If(lPrdCal,cCodPro,)	,; // Produto
															,; // Servico
									DFI->DFI_SERTMS			,;	// Serv. de Transp.
									DFI->DFI_TIPTRA			,;	// Tipo Transp.
															,;	// No. Contrato
									@aMsgErr				,;	// Array Mensagens de Erro
															,;	// NF's por Conhecimento
									0						,;	// Valor da Mercadoria
									aDocVge[nCntFor][3]		,;	// Peso Real do Docto.
									aDocVge[nCntFor][15]	,;	// Peso Cubado do Docto.
									0						,;	// Peso Cobrado
									DFI->DFI_QTDVOL			,;	// Qtde. de Volumes do Docto.
									0						,;	// Desconto
									0						,;	// Seguro
									0						,;	// Metro Cubico
									DFI->DFI_QTDDOC			,;	// Qtde. de Doctos
									DFI->DFI_QTDIAS			,;	// No. de Diarias ( Semana )
									DFI->DFI_QTDKM			,;	// Km percorridos
									DFI->DFI_QTDPER			,;	// Pernoites
									.T.						,;	// Estabelece o valor minimo do componente
									.F.						,;	// Indica que o contrato e' de um cliente generico
									.F.						,;	// Ajuste automatico, envia msg se nao encontrar
									DFI->DFI_QTDENT			,;	// Qtde.de Entregas )
									DFI->DFI_QTDUNI			,;	// Quantidade de Unitizadores
									0						,;	// Valor do Frete do Despachante
									DFI->DFI_VALFRE			,;	// CTRC sem Impostos
									DFI->DFI_VALTOT			,;	// CTRC com Impostos
									aValInf					,;	// Valor Informado
									aTipVei					,;	// Tipo de Veiculo
									''						,;	// Documento de Transporte
									DFI->DFI_QTFIMS			,;	// No. de Diarias ( Fim de Semana )
									DFI->DFI_PESO			,;	// Peso da Viagem
									DFI->DFI_PESOM3			,;	// Peso M3 da Viagem
									nMetro3Vge				,;	//Metro Cubico da Viagem
									DFI->DFI_VALMER			,;	//Valor da Mercadoria da Viagem
									DFI->DFI_QTDVOL			,;	// Quantidade de Volumes da Viagem
															,;	// No. de Dias Armazenagem
															,;	// Faixa
															,;	// Lote NFC
															,;	// Peso Cubado
															,;	// Praca Pedagio
															,;	// Cliente Devedor
															,;	// Loja Devedor
															,;	// Moeda
															,;	// Excedente TDA
															,;	// Devedor TDA
															,;	// Remetente TDA
															,;	// Destinatario TDA
															,;	// Qtde.de Coletas
															,;	// Codigo Destinatario
															,;	// Loja Destinatario
															,;	// Sequencia Destinatario
															,;	// Sequencia do Documento
															,;	// Rateio? .T. ou .F.
															,;	// Vetor com as bases do rateio
															,;	// Vetor com a composição do cálculo
															"",; // Codigo Negociacao
															,;   // Taxa Devedor
															)	  //aFreteCol

			DVE->(DbSetOrder(2))
			For nX := 1 To Len(aFretAux)
				If aFretAux[nX,3] <> 'TF'
					aFretAux[nX,6] := aFretAux[nX,2]
					nValFre += aFretAux[nX,2]
					If DVE->(MsSeek(xFilial('DVE') + aFretAux[nX,3] + cTabFre + cTipTab)) .And. DVE->DVE_BASIMP <> '2'
						nBasImp += aFretAux[nX,2]
					EndIf
				EndIf
			Next

			If	aFretAux[Len(aFretAux),3]=='TF'
				AAdd(aFrete,{aDocVge[nCntFor][1],aFretAux})
			EndIf

		Next nCntFor

		If Empty(nValFre)
			If lMsgErr
				AAdd( aMsgErr, {STR0085 + cTabFre + '/' + cTipTab, '02',"TMSA010(, " + STR0003 + ", '2')" } ) //"Verifique a Tabela de Frete "###"Tabela de Frete a Pagar"
			EndIf
			Return( aRet )
		EndIf
	EndIf
Else
	//-- NAO deve gerar Contrato de Carreteiro para Entregas e Coletas Nao Efetuadas
	If cTipUso == "1" //--Viagem
		If lTmsRvol .And. nQtdOco > 0 .And. nQtdOco < nQtdVol .And. ( DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) .Or. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) )
			nValFre := ( nValFreInf / nQtdVol ) * nQtdOco
		Else
			nValFre := nValFreInf
		EndIf
	ElseIf cTipUso == "2" //--Carga
		nValFre := nValFreInf
	EndIf
EndIf

aRet := {}

AAdd(aRet, {cTabFre, cTipTab, nValFre, DFI->DFI_VOLOCO, DFI->DFI_PESOCO, DFI->DFI_QTDDOC, DFI->DFI_QTDIAS, DFI->DFI_QTDKM, DFI->DFI_QTFIMS, cGerTitPDG, cDedPDG, nBasImp, cTabCar, cGerPC, cGerTitCont, ,cTitFrete,cBxTitPdg, cTitNDF})

//-- Permite a manipulação das informaçoes do array aRet
If lTMSFREPAG
	aRetUsr := ExecBlock("TMSFREPAG",.F.,.F., { aRet })
	If ValType(aRetUsr) == "A"
		aRet := aClone(aRetUsr)
	EndIf
EndIf

Return( aRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSVldDoc ºAutor  ³Andre Godoi         º Data ³  26/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o Doc. esta em Redespacho e podera ser pago.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ TMSVldDoc()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGATMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVldDoc()
Local lRet     := .F.
Local lAchou   := .T.
Local aArea    := GetArea()
Local aAreaDUA := DUA->(GetArea())
Local aAreaDT2 := DT2->(GetArea())
Local aAreaDFV := DFV->(GetArea())
Local cFilOri  := DUA->DUA_FILORI
Local cViagem  := DUA->DUA_VIAGEM

DFV->( DbSetOrder ( 2 ) )
DUA->( DbSetOrder ( 4 ) )
DT2->( DbSetOrder ( 1 ) )

//-- Ocorrencia "Indicado p/ Entrega" do Redespacho.
If DUA->DUA_CODOCO $ GetMV("MV_OCORRDP",,"")
	//-- Documento de Redespacho.
	If DFV->( MsSeek( xFilial('DFV') + DUA->(DUA_FILDOC + DUA_DOC + DUA_SERIE) ) )
		cSeek := DFV->(DFV_FILDOC + DFV_DOC + DFV_SERIE + cFilOri + cViagem)

		If DUA->( MsSeek( xFilial('DUA') + cSeek ) )
			//-- Caso tenha alguma ocorrencia de encerra processo, desconsiderar o registro.
			While DUA->( !EOF() ) .And. ( DUA->(DUA_FILDOC + DUA_DOC + DUA_SERIE + DUA_FILORI + DUA_VIAGEM ) == cSeek )
				If (DT2->( MsSeek (xFilial('DT2') + DUA->DUA_CODOCO ) ) .And.;
					DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) )
					lRet   := .F.
					lAchou := .F.
					Exit
				EndIf
				DUA->( DbSkip() )
			EndDo

			//-- Se nao tem encerra processo e for do tipo "Indicado p/ Entrega", considerar p/ gerar o contrato.
			If DUA->( MsSeek( xFilial('DUA') + cSeek ) ) .And. lAchou
				If (DT2->( MsSeek (xFilial('DT2') + DUA->DUA_CODOCO ) ) .And.;
					DT2->DT2_TIPOCO == StrZero(5,Len(DT2->DT2_TIPOCO)) )
					lRet := .T.
				EndIf
			EndIf

		EndIf
	EndIf
EndIf

RestArea( aAreaDFV )
RestArea( aAreaDT2 )
RestArea( aAreaDUA )
RestArea( aArea )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSEx2Calc³ Autor ³Aldo Barbosa dos Santos³ Data ³ 20/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a valores de Excedente da Sub-Faixa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSEx2Aju()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Seek tabela de frete                                ³±±
±±³          ³ExpC3 - Seek tarifa                                         ³±±
±±³          ³ExpC4 - Seek ajuste                                         ³±±
±±³          ³ExpN5 - Base Sub-Faixa                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSEx2Calc(cAlias, cSeekTab, cSeekTar, cSeekAju, nBaseCalFx2, nVlrComp)

Local nFaixa   := 0
Local nRet     := 0  // valor do excedente por subfaixa
Local nValor   := 0  // valor do componente excedente
Local nValMin  := 0  // valor minimo cobrado de excedente
Local nValMax  := 0  // valor maximo cobrado de excedente
Local nInterv  := 0  // fracao

Local nPerAju  := 100  // percentual do ajuste sobre o valor
Local nPerMin  := 100  // percentual do ajuste sobre o minimo
Local nPerMax  := 100  // percentual do ajuste sobre o maximo

Local lTemAjuste := .F.
Local lTemTarifa := .F.
Local lTemTabela := .F.

Local aArea := { GetArea(), DY0->( GetArea("DY0")), DY1->( GetArea("DY1")), DY2->( GetArea("DY2")) }
Local nA

// pesquisa o ajuste
DY2->(DbSetOrder(1)) // DY2_FILIAL+DY2_TABFRE+DY2_TIPTAB+DY2_CDRORI+DY2_CDRDES+DY2_CODCLI+DY2_LOJCLI+DY2_SEQTAB+DY2_CODPRO+DY2_SERVIC+DY2_CODPAS+DY2_ITEDVD+DY2_ITEM
lTemAjuste := DY2->( MsSeek(cSeekAju))

// nao achou ajuste, pesquisa na tabela de frete se nao encontrar pesquisa na tarifa
DY1->(DbSetOrder(1))
If	(lTemTabela := DY1->( MsSeek(cSeekTab)))
	If ! Empty(cSeekTar)
		cAlias := "DY0"  // excedente na subfaixa da tarifa
		DY0->( DbSetOrder(1))
		lTemTarifa := DY0->( MsSeek(cSeekTar))
	EndIf
EndIf

If lTemAjuste .Or. lTemTabela .Or. lTemTarifa
	If lTemAjuste
		nFaixa  := DY2->DY2_EXCMIN
	ElseIf lTemTarifa
		nFaixa  := DY0->DY0_EXCMIN
	Else
		nFaixa  := DY1->DY1_EXCMIN
	EndIf

	//-- Analisa a faixa para obter o valor.
	If nBaseCalFx2 > nFaixa
		// recupera os valores cheios da tarifa ou tabela de frete
		nValor  := (cAlias)->&(cAlias+"_VALOR" )
		nValMin := (cAlias)->&(cAlias+"_VALMIN" )
		nValMax := (cAlias)->&(cAlias+"_VALMAX" )
		nInterv := (cAlias)->&(cAlias+"_INTERV" )

		// recupera os percentuais de ajuste (se houver)
		If lTemAjuste
			nPerAju := DY2->DY2_PERAJU
			nPerMin := DY2->DY2_PERMIN
			nPerMax := DY2->DY2_PERMAX
			nInterv := DY2->DY2_INTERV

			// aplica os percentuais de ajuste
			nValMin := nValMin * nPerMin / 100
			nValMax := nValMax * nPerMax / 100
		EndIf

		// base de calculo = quantidade que excede a faixa (excedente)
		nQtdCalc := (nBaseCalFx2 - nFaixa)

		// calcula o valor do excedente
		// se a Fracao for zero, o calculo retorna o valor fixo ignorando o restante do calculo
		If nInterv <= 0
			If lTemAjuste
				nRet := nValor * (nPerAju / 100)
			Else
				nRet := nValor
			EndIf
		Else
			If lTemAjuste
				nRet := ((nQtdCalc * nValor) / nInterv ) * (nPerAju / 100)
			Else
				nRet := ((nQtdCalc * nValor) / nInterv )
			EndIf
		EndIf

		nRet := nRet + nVlrComp

		// verifica se se aplica o minimo
		If nValMin > 0 .And. nRet < nValMin
			nRet := nValMin
		EndIf

		// verifica se se aplica o maximo
		If nValMax > 0 .And. nRet > nValMax
			nRet := nValMax
		EndIf
	Else
		nRet := nVlrComp
	EndIf
Else
	nRet := nVlrComp
EndIf

For nA := Len(aArea) to 1 Step -1
	RestArea(aArea[nA])
Next

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSImpDoc  ³ Autor ³ Valdemar R Mognon    ³ Data ³ 09/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao automatica do documento de transporte              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsImpDoc(Expa1,Expa2,Expa3,Expc1,Expl1,Expn1,Expn2,Expl2  ³±±
±±³          ³           Expl3,Expl4,Expl5)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Vetor com os campos do documento de transporte     ³±±
±±³          ³ ExpA2 - Vetor com os campos da composicao do frete         ³±±
±±³          ³ ExpA3 - Vetor com as notas fiscais do documento            ³±±
±±³          ³ Expc1 - Numero do lote                                     ³±±
±±³          ³ Expl1 - Indica se calcula impostos                         ³±±
±±³          ³ Expn1 - Percentual de impostos                             ³±±
±±³          ³ Expn2 - Tipo de imposto (1-ICMS,2-ISS)                     ³±±
±±³          ³ Expl2 - Indica se exibe mensagem de erros                  ³±±
±±³          ³ Expl3 - Indica se verifica integridade DT6/DTC             ³±±
±±³          ³ Expl4 - Indica se verifica integridade DT6/DT8             ³±±
±±³          ³ Expl5 - Indica se verifica integridade DT6/Demais Tabelas  ³±±
±±³          ³ ExpA4 - Array contendo dados do documento original         ³±±
±±³          ³ //-- Array aDocOri                                         ³±±
±±³          ³ //-- [1] - Filial Docto Original  (caracter)               ³±±
±±³          ³ //-- [2] - No. Docto Original     (caracter)               ³±±
±±³          ³ //-- [3] - Serie Docto Original   (caracter)               ³±±
±±³          ³ //-- [4] - % Docto. Orignal       (numerico)               ³±±
±±³          ³ //-- [5] - Complemento de Imposto (lógico)                 ³±±
±±³          ³ //-- [6] - nOpcx - TMSA500        (numerico)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSImpDoc(aVetDoc, aVetVlr, aVetNFc, cLotNFc, lCalImp, nPerImp, nTipImp, lExbHlp, lIntDTC, lIntDT8, lIntTab, aDocOri)
Local aArea      := GetArea()
Local aAreaDUI   := DUI->(GetArea())
Local aAreaDTC   := DTC->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aAreaSM0   := {}
Local aAreaDUY   := {}
Local aAreaSA1   := {}
Local aAreaDT3   := {}
Local aVetSol    := {}
Local aVetErr    := {}
Local aVetWrk    := {}
Local aContrt    := {}
Local aFrete     := {}
Local aMsgErr    := {}
Local aNfs       := {}
Local aCpoNOb    := {"DT6_FILIAL","DT8_FILIAL","VLR_ICMSOL"}
Local aCpoPE     := {}
Local aNfCTRC    := {}
Local aCpoInt    := {"CLIREM","LOJREM","CLIDES","LOJDES","CLICON","LOJCON","CLIDPC","LOJDPC","CLIDEV","LOJDEV","CLICAL","LOJCAL","SERVIC"}
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nQtdDoc    := 0
Local cAlias     := ""
Local cFilWrk    := ""
Local cTabFre    := ""
Local cTipTab    := ""
Local cSeqTab    := ""
Local lCpoObr    := .T.
Local lCont      := .T.
Local lGrava     := .T.
Local aProdNfs   := {}
Local nProdNfs   := 0
Local nCntTF     := 0
Local cTipNfc    := '0'

Local nValPas    := 0
Local nValImp    := 0
Local nValTot    := 0
Local nUniPas    := 0
Local nUniImp    := 0
Local nUniTot    := 0
Local aTmsA500   := {}

Local cCampo     := 0
Local cTipo      := 0
Local xValor     := 0
Local cCodCli    := 0
Local cLojCli    := 0

Local nPosCliRem := 0
Local nPosLojRem := 0
Local nPosNumNFc := 0
Local nPosSerNFc := 0
Local nPosProCli := 0
Local nPosQtdVol := 0
Local nPosPeso   := 0
Local nPosPesoM3 := 0
Local nPosValMer := 0
Local nPosMetro3 := 0
Local nPosQtdUni := 0
Local nPosBasSeg := 0
Local nPosTipNfc := 0

Local nPosFilDoc := GetKeyPos("DT6_FILDOC", aVetDoc)
Local nPosDoc    := GetKeyPos("DT6_DOC"   , aVetDoc)
Local nPosSerie  := GetKeyPos("DT6_SERIE" , aVetDoc)
Local nPosCodNeg := GetKeyPos("DT6_CODNEG", aVetDoc)

Local nTotQtdVol := 0
Local nTotPeso   := 0
Local nTotPeM3   := 0
Local nTotValor  := 0
Local nTotMetro3 := 0
Local nTotBasSeg := 0
Local nTotQtdUni := 0

Local nTotValFre := 0
Local nTotValImp := 0
Local nTotValTot := 0

Local nTFValFre  := 0
Local nTFValImp  := 0
Local nTFValTot  := 0

Local dDatAnt    := dDataBase
Local cRecIss    := ""
Local cCPAGPV    := ''
Local lTM200Cpg  := ExistBlock("TM200CPG")

Private aLote    := {}
Private aDocto   := {}
Private aPedBlq  := {}
Private lTmsImpDc:= .T.

//-- Variavel requerida pela funcao TMSA200ATU
Private lTmsCFec := TmsCFec()

DEFAULT aVetDoc := {}
DEFAULT aVetVlr := {}
DEFAULT aVetNFc := {}
DEFAULT lCalImp := .T.
DEFAULT nPerImp := 0
DEFAULT nTipImp := 1
DEFAULT lExbHlp := .F.
DEFAULT lIntDTC := .T.
DEFAULT lIntDT8 := .T.
DEFAULT lIntTab := .T.
DEFAULT aDocOri := {}

If Len(aDocOri) > 0
	//-- Se os dados do documento original forem informados
	//-- não verifica DTC
	lIntDTC := .F.
	aVetDTC := {}
Else
	nPosCliRem := GetKeyPos("DTC_CLIREM", aVetNFc[1])
	nPosLojRem := GetKeyPos("DTC_LOJREM", aVetNFc[1])
	nPosNumNFc := GetKeyPos("DTC_NUMNFC", aVetNFc[1])
	nPosSerNFc := GetKeyPos("DTC_SERNFC", aVetNFc[1])
	nPosProCli := GetKeyPos("DTC_CODPRO", aVetNFc[1])
	nPosQtdVol := GetKeyPos("DTC_QTDVOL", aVetNFc[1])
	nPosPeso   := GetKeyPos("DTC_PESO"  , aVetNFc[1])
	nPosPesoM3 := GetKeyPos("DTC_PESOM3", aVetNFc[1])
	nPosValMer := GetKeyPos("DTC_VALOR" , aVetNFc[1])
	nPosMetro3 := GetKeyPos("DTC_METRO3", aVetNFc[1])
	nPosQtdUni := GetKeyPos("DTC_QTDUNI", aVetNFc[1])
	nPosBasSeg := GetKeyPos("DTC_BASSEG", aVetNFc[1])
	nPosTipNfc := GetKeyPos("DTC_TIPNFC", aVetNFc[1])
	nPosRecIss := GetKeyPos("DTC_RECISS", aVetNFc[1])

	//-- Campos chave
	If nPosCliRem == 0 .Or. nPosLojRem == 0
		AAdd(aVetErr,{STR0090,"00",""}) //"Campo remetente da nota fiscal não informado."
		lCont := .F.
	EndIf

	If nPosNumNFc == 0
		AAdd(aVetErr,{STR0091,"00",""}) //"Campo número da nota fiscal não informado."
		lCont := .F.
	EndIf

	If nPosSerNFc == 0
		AAdd(aVetErr,{STR0092,"00",""}) //"Campo série da nota fiscal não informado."
		lCont := .F.
	EndIf

	If nPosProCli == 0
		AAdd(aVetErr,{STR0096,"00",""}) //"Campo produto do documento não informado."
		lCont := .F.
	EndIf
EndIf

//-- PE que permite manipular o array de campos nao obrigatorios na gravacao automatica do documento de transporte
If lTMSCPDOC
	aCpoPE := Execblock("TMSCPDOC",.F.,.F.,{aCpoNOb})
	If ValType(aCpoPE) == "A"
		aCpoNOb := Aclone(aCpoPE)
	EndIf
EndIf

//-- Verifica validade dos vetores de documentos de transporte e composicao do frete
For nCntFor1 := 1 To 2
    If nCntFor1 == 1 //-- Documentos de transporte
        cAlias  := "DT6"
        aVetWrk := AClone(aVetDoc)
    Else //-- Composicao do frete
        cAlias  := "DT8"
        aVetWrk := AClone(aVetVlr[1])
    EndIf

    If AliasIndic(cAlias)
        aFields := ApBuildHeader(cAlias)

        For nCntFor2 := 1 to Len(aFields)
            cCampo  := Rtrim(aFields[nCntFor2][2])
            cTipo   := aFields[nCntFor2][8]
            lCpoObr := x3Obrigat(cCampo) .And. AScan(aCpoNOb,{|x| AllTrim(x) == cCampo }) == 0

            If ExistKey(cCampo, aVetWrk, @xValor)
                If cTipo != ValType(xValor)
                    AAdd( aVetErr, { STR0088 + cCampo + STR0089, "00", ""} ) //"Campo "###" com conteúdo inválido."
                    lCont := .F.
                EndIf
            Else
                If lCpoObr
                    AAdd( aVetErr, { STR0086 + cCampo + STR0087, "00", ""} ) //"Campo obrigatório "###" não informado."
                    lCont := .F.
                EndIf
            EndIf
        Next
    EndIf

Next nCntFor1

If nPosFilDoc == 0
	AAdd(aVetErr,{STR0093,"00",""}) //"Campo filial do documento não informado."
	lCont := .F.
EndIf

If nPosDoc == 0
	AAdd(aVetErr,{STR0094,"00",""}) //"Campo número do documento não informado."
	lCont := .F.
EndIf

If nPosSerie == 0
	AAdd(aVetErr,{STR0095,"00",""}) //"Campo série do documento não informado."
	lCont := .F.
EndIf

//-- Tipo do documento
If lCont
	If ExistKey("DT6_DOCTMS", aVetDoc, @xValor)
		DUI->(DbSetOrder(1))
		If !DUI->(MsSeek(xFilial("DUI") + xValor,.F.))
			AAdd(aVetErr,{STR0098,"00",""}) //"Campo tipo de documento inválido."
			lCont := .F.
		EndIf
	Else
		AAdd(aVetErr,{STR0097,"00",""}) //"Campo tipo de documento não informado."
		lCont := .F.
	EndIf
EndIf

//-- Total do documento
If lCont

	If ExistKey("DT6_VALFRE", aVetDoc, @xValor) .And. xValor == 0
		AAdd(aVetErr,{STR0099,"00",""}) //"Valor do frete do documento está zerado."
		lCont := .F.
	EndIf

    If ExistKey("DT6_VALTOT", aVetDoc, @xValor) .And. xValor == 0
		AAdd(aVetErr,{STR0100,"00",""}) //"Frete total do documento está zerado."
		lCont := .F.
	EndIf
EndIf

//-- Verifica se documento já existe
If lCont
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6") + aVetDoc[nPosFilDoc,2] + aVetDoc[nPosDoc,2] + aVetDoc[nPosSerie,2]))
		AAdd(aVetErr,{STR0101,"00",""}) //"Documento Já existe."
	EndIf
EndIf

If lCont
	//-- Verifica Integridade DT6/DTC
	If lIntDTC
		//-- Acumuladores
		DTC->(DbSetOrder(2))
		For nCntFor1 := 1 To Len(aVetNFc)
			If !DTC->(MsSeek(xFilial("DTC") + aVetNFc[nCntFor1,nPosNumNFc,2] + aVetNFc[nCntFor1,nPosSerNFc,2] + aVetNFc[nCntFor1,nPosCliRem,2] + aVetNFc[nCntFor1,nPosLojRem,2] + aVetNFc[nCntFor1,nPosProCli,2] ))
				AAdd(aVetErr,{STR0102 + aVetNFc[nCntFor1,nPosCliRem,2] + " " + aVetNFc[nCntFor1,nPosLojRem,2] + "/" + aVetNFc[nCntFor1,nPosNumNFc,2] + "/" + aVetNFc[nCntFor1,nPosSerNFc,2] + " " + Alltrim(aVetNFc[nCntFor1,nPosProCli,2]) + STR0103,"00",""}) //"Nota fiscal "###" não localizada."
			ElseIf !Empty(DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE)
				AAdd(aVetErr,{"Doc. Cliente " + aVetNFc[nCntFor1,nPosNumNFc,2] + " ja possui vinculo com um Documento de Transporte. ","00",""}) //"Doc. Cliente #### já possui vínculo com um Documento de Transporte."
			Else
				nTotQtdVol += DTC->DTC_QTDVOL
				nTotPeso   += DTC->DTC_PESO
				nTotPeM3   += DTC->DTC_PESOM3
				nTotValor  += DTC->DTC_VALOR
				nTotMetro3 += DTC->DTC_METRO3
				nTotBasSeg += DTC->DTC_BASSEG
				nTotQtdUni += DTC->DTC_QTDUNI
			EndIf
		Next nCntFor1

        If ExistKey("DT6_QTDVOL", aVetDoc, @xValor) .And. xValor != nTotQtdVol
			AAdd(aVetErr,{STR0104,"00",""}) //"Total de volumes das notas fiscais não confere com documento."
		EndIf

        If ExistKey("DT6_PESO", aVetDoc, @xValor) .And. xValor != nTotPeso
			AAdd(aVetErr,{STR0105,"00",""}) //"Total de peso das notas fiscais não confere com documento."
		EndIf

        If ExistKey("DT6_PESOM3", aVetDoc, @xValor) .And. xValor != nTotPeM3 .And. Empty(nTotMetro3)
			AAdd(aVetErr,{STR0106,"00",""}) //"Total de peso cubado das notas fiscais não confere com documento."
		EndIf

        If ExistKey("DT6_VALMER", aVetDoc, @xValor) .And. xValor != nTotValor
			AAdd(aVetErr,{STR0107,"00",""}) //"Total de Valor das mercadorias das notas fiscais não confere com documento."
		EndIf

        If ExistKey("DT6_METRO3", aVetDoc, @xValor) .And. xValor != nTotMetro3
			AAdd(aVetErr,{STR0108,"00",""}) //"Total de metragem cubica das notas fiscais não confere com documento."
		EndIf

        If ExistKey("DT6_BASSEG", aVetDoc, @xValor) .And. xValor != nTotBasSeg
			AAdd(aVetErr,{STR0109,"00",""}) //"Total da base de seguro das notas fiscais não confere com documento."
		EndIf

        If ExistKey("DT6_QTDUNI", aVetDoc, @xValor) .And. xValor != nTotQtdUni
			AAdd(aVetErr,{STR0110,"00",""}) //"Total de unitizadores das notas fiscais não confere com documento."
		EndIf

		//-- Campos documento x nota fiscal
		For nCntFor1 := 1 To Len(aCpoInt)
            If ExistKey("DT6_" + aCpoInt[nCntFor1], aVetDoc, xValor) .And. !Empty(xValor)
                If xValor != &("DTC->DTC_" + aCpoInt[nCntFor1])
                    AAdd(aVetErr,{STR0111 + aCpoInt[nCntFor1] + STR0112 + aCpoInt[nCntFor1] + ".","00",""}) //"Campo DT6_"###" incompatível com o campo DTC_"
                EndIf
            EndIf
        Next nCntFor1
    EndIf

	//-- Composicao do frete
	If lIntDT8
		//-- Acumuladores
		For nCntFor1 := 1 To Len(aVetVlr)
            If ExistKey("DT8_CODPAS", aVetVlr[nCntFor1], @xValor)
				If xValor != "TF"
					If lIntTab
						If !DT3->(MsSeek(xFilial("DT3") + xValor))
							AAdd(aVetErr,{STR0113 + xValor + STR0114,"00",""}) //"Componente de frete "###" não existe."
						EndIf
					EndIf

                    If ExistKey("DT8_VALPAS", aVetVlr[nCntFor1], @xValor)
						nTotValFre += xValor
					EndIf

                    If ExistKey("DT8_VALIMP", aVetVlr[nCntFor1], @xValor)
						nTotValImp += xValor
					EndIf

                    If ExistKey("DT8_VALTOT", aVetVlr[nCntFor1], @xValor)
						nTotValTot += xValor
					EndIf
				Else
                    If ExistKey("DT8_VALPAS", aVetVlr[nCntFor1], @xValor)
						nTFValFre := xValor
					EndIf

                    If ExistKey("DT8_VALIMP", aVetVlr[nCntFor1], @xValor)
						nTFValImp := xValor
					EndIf

                    If ExistKey("DT8_VALTOT", aVetVlr[nCntFor1], @xValor)
						nTFValTot := xValor
					EndIf
				EndIf
			EndIf
		Next nCntFor1

		If nTFValFre == 0
			AAdd(aVetErr,{STR0115,"00",""}) //"Total do frete na composição não informado."
		ElseIf nTFValFre != nTotValFre
			AAdd(aVetErr,{STR0116,"00",""}) //"Total do frete na composição não confere com sua totalização."
		EndIf

		If nTFValImp != nTotValImp
			AAdd(aVetErr,{STR0117,"00",""}) //"Total dos impostos na composição não confere com sua totalização."
		EndIf

		If nTFValTot == 0
			AAdd(aVetErr,{STR0118,"00",""}) //"Frete total na composição não informado."
		ElseIf nTFValTot != nTotValTot
			AAdd(aVetErr,{STR0119,"00",""}) //"Frete total na composição não confere com sua totalização."
		EndIf

        If ExistKey("DT6_VALFRE", aVetDoc, @xValor) .And. xValor != nTotValFre
			AAdd(aVetErr,{STR0120,"00",""}) //"Total da composição do frete não confere com documento."
		EndIf

        If ExistKey("DT6_VALIMP", aVetDoc, @xValor) .And. xValor != nTotValImp
			AAdd(aVetErr,{STR0121,"00",""}) //"Total da composição dos impostos não confere com documento."
		EndIf

        If ExistKey("DT6_VALTOT", aVetDoc, @xValor) .And. xValor != nTotValTot
			AAdd(aVetErr,{STR0122,"00",""}) //"Total da composição do frete total não confere com documento."
		EndIf
	EndIf

	If lIntTab
		cFilWrk  := cFilAnt
		aAreaSM0 := SM0->(GetArea())
		aAreaDUY := DUY->(GetArea())
		aAreaSA1 := SA1->(GetArea())
		aAreaDT3 := DT3->(GetArea())
		SM0->(DbSetOrder(1))
		DUY->(DbSetOrder(1))
		SA1->(DbSetOrder(1))
		DT3->(DbSetOrder(1))

        If ExistKey("DT6_FILDOC", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0123 + xValor + STR0114,"00",""}) //"Filial do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_FILORI", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0124 + xValor + STR0114,"00",""}) //"Filial de origem do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_FILDES", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0125 + xValor + STR0114,"00",""}) //"Filial de destino do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_FILDCO", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0126 + xValor + STR0114,"00",""}) //"Filial do documento original"###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_FILVGA", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0127 + xValor + STR0114,"00",""}) //"Filial da viagem do documento "###" não existe."
			EndIf
        EndIf

        If ExistKey("DT6_FILDEB", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0128 + xValor + STR0114,"00",""}) //"Filial de débito do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_FILNEG", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0129 + xValor + STR0114,"00",""}) //"Filial de negociação do documento "###" não existe."
			EndIf
		EndIf

		If ExistKey("DT6_FLOREF", aVetDoc, @xValor) .And. !Empty(xValor)
			If !SM0->(MsSeek(cEmpAnt + xValor))
				AAdd(aVetErr,{STR0130 + xValor + STR0114,"00",""}) //"Filial do lote de refaturamento do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CDRORI", aVetDoc, @xValor) .And. !Empty(xValor)
			If !DUY->(MsSeek(xFilial("DUY") + xValor))
				AAdd(aVetErr,{STR0131 + xValor + STR0114,"00",""}) //"Região de origem do documento "###" não existe."
		    EndIf
		EndIf

        If ExistKey("DT6_CDRDES", aVetDoc, @xValor) .And. !Empty(xValor)
			If !DUY->(MsSeek(xFilial("DUY") + xValor))
				AAdd(aVetErr,{STR0132 + xValor + STR0114,"00",""}) //"Região de destino do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CDRCAL", aVetDoc, @xValor) .And. !Empty(xValor)
			If !DUY->(MsSeek(xFilial("DUY") + xValor))
				AAdd(aVetErr,{STR0133 + xValor + STR0114,"00",""}) //"Região de cálculo do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CLIREM", aVetDoc, @cCodCli) .And. ExistKey("DT6_LOJREM", aVetDoc, @cLojCli)
			If !Empty(cCodCli) .And. !Empty(cLojCli) .And. !SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
				AAdd(aVetErr,{STR0134 + cCodCli + "/" + cLojCli + STR0114,"00",""}) //"Cliente remetente do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CLIDES", aVetDoc, @cCodCli) .And. ExistKey("DT6_LOJDES", aVetDoc, @cLojCli)
			If !Empty(cCodCli) .And. !Empty(cLojCli) .And. !SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
				AAdd(aVetErr,{STR0135 + cCodCli + "/" + cLojCli + STR0114,"00",""}) //"Cliente destinatario do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CLICON", aVetDoc, @cCodCli) .And. ExistKey("DT6_LOJCON", aVetDoc, @cLojCli)
			If !Empty(cCodCli) .And. !Empty(cLojCli) .And. !SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
				AAdd(aVetErr,{STR0136 + cCodCli + "/" + cLojCli + STR0114,"00",""}) //"Cliente consignatário do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CLIDPC", aVetDoc, @cCodCli) .And. ExistKey("DT6_LOJDPC", aVetDoc, @cLojCli)
			If !Empty(cCodCli) .And. !Empty(cLojCli) .And. !SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
				AAdd(aVetErr,{STR0137 + cCodCli + "/" + cLojCli + STR0114,"00",""}) //"Cliente despachante do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CLIDEV", aVetDoc, @cCodCli) .And. ExistKey("DT6_LOJDEV", aVetDoc, @cLojCli)
			If !Empty(cCodCli) .And. !Empty(cLojCli) .And. !SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
				AAdd(aVetErr,{STR0138 + cCodCli + "/" + cLojCli + STR0114,"00",""}) //"Cliente devedor do documento "###" não existe."
			EndIf
		EndIf

        If ExistKey("DT6_CLICAL", aVetDoc, @cCodCli) .And. ExistKey("DT6_LOJCAL", aVetDoc, @cLojCli)
			If !Empty(cCodCli) .And. !Empty(cLojCli) .And. !SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
				AAdd(aVetErr,{STR0139 + cCodCli + "/" + cLojCli + STR0114,"00",""}) //"Cliente de cálculo do documento "###" não existe."
			EndIf
		EndIf

        DT3->(RestArea(aAreaDT3))
		SA1->(RestArea(aAreaSA1))
		DUY->(RestArea(aAreaDUY))
		SM0->(RestArea(aAreaSM0))
		cFilAnt := cFilWrk
	EndIf

EndIf

lGrava := Empty(aVetErr)

//-- Grava registros
If lGrava

	//-- Le contrato do cliente
	aContrt := TMSContrat(GetKeyVal("DT6_CLICAL", aVetDoc),;
						  GetKeyVal("DT6_LOJCAL", aVetDoc),;
						  ,;
						  GetKeyVal("DT6_SERVIC", aVetDoc),;
						  .F.,;
						  GetKeyVal("DT6_TIPFRE", aVetDoc),;
						  ,,,,,,,,,,,,,,,Iif((nPosCodNeg > 0) ,aVetDoc[nPosCodNeg,2],''))
	If Empty(aContrt)
		AAdd(aVetErr,{STR0140 + GetKeyVal("DT6_CLICAL", aVetDoc) + "/" + GetKeyVal("DT6_LOJCAL", aVetDoc) + STR0141,"00",""}) //"Contrato do cliente "###" não localizado."
	Else
		If Empty(aDocOri)
			//-- Formato do vetor aNfCTRC
			//-- [01] = Numero da nota fiscal do cliente
			//-- [02] = Serie da nota fiscal do cliente
			//-- [03] = Codigo Produto
			For nCntFor1 := 1 To Len(aVetNFc)

				nProdNfs := Ascan(aProdNfs, { | e | e[1] == aVetNFc[nCntFor1,nPosProCli,2] })

				If nProdNfs == 0 .And. Len(aProdNfs) == 0
					AAdd(aProdNfs, { aVetNFc[nCntFor1,nPosProCli,2], 0, 0, 0, 0, 0 } )
					nProdNfs := Len(aProdNfs)
				Else
					nProdNfs := 1
				EndIf

				aProdNfs[nProdNfs,2] += Iif(nPosQtdVol > 0,aVetNFc[nCntFor1,nPosQtdVol,2],0)
				aProdNfs[nProdNfs,3] += Iif(nPosValMer > 0,aVetNFc[nCntFor1,nPosValMer,2],0)
				aProdNfs[nProdNfs,4] += Iif(nPosPeso   > 0,aVetNFc[nCntFor1,nPosPeso  ,2],0)
				aProdNfs[nProdNfs,5] += Iif(nPosPesoM3 > 0,aVetNFc[nCntFor1,nPosPesoM3,2],0)
				aProdNfs[nProdNfs,6] += Iif(nPosBasSeg > 0,aVetNFc[nCntFor1,nPosBasSeg,2],0)

				cTipNfc := Iif(nPosTipNfc > 0,aVetNFc[nCntFor1,nPosTipNfc,2],'0')
				AAdd( aNfCTRC, {aVetNFc[nCntFor1,nPosNumNFc][2], aVetNFc[nCntFor1,nPosSerNFc][2], aVetNFc[nCntFor1,nPosProCli][2] })

				//-- Recolhe ISS
				If nPosRecIss > 0 .And. !Empty(aVetNFc[nCntFor1,nPosRecIss,2])
					cRecIss:= aVetNFc[nCntFor1,nPosRecIss,2]
				EndIf
				If Empty(cRecIss)
					cRecISS := Posicione('SA1',1,xFilial('SA1')+GetKeyVal("DT6_CLIDEV", aVetDoc)+GetKeyVal("DT6_LOJDEV", aVetDoc),'A1_RECISS')
				EndIf

				//-- Define tabela de frete
				If ExistKey("DT6_TABFRE", aVetDoc)
					cTabFre := GetKeyVal("DT6_TABFRE", aVetDoc)
				Else
					cTabFre := aContrt[1,3]
				EndIf
				//-- Define tipo da tabela de frete
				If ExistKey("DT6_TIPTAB", aVetDoc)
					cTipTab := GetKeyVal("DT6_TIPTAB", aVetDoc)
				Else
					cTipTab := aContrt[1,4]
				EndIf
				//-- Define sequencia da tabela de frete
				If ExistKey("DT6_SEQTAB", aVetDoc)
					cSeqTab := GetKeyVal("DT6_SEQTAB", aVetDoc)
				Else
					cSeqTab := Space(Len(DT6->DT6_SEQTAB))
				EndIf

				cCPAGPV:= ''
				cCPAGPV:= aContrt[ 1, 9 ]

				If lTM200Cpg //PE permite alterar a condicao de pagamento
					cCPAGPV:= ExecBlock("TM200CPG",.F.,.F.,{GetKeyVal("DT6_CLICAL", aVetDoc),GetKeyVal("DT6_LOJCAL", aVetDoc),cCPAGPV,GetKeyVal("DT6_SERVIC", aVetDoc),GetKeyVal("DT6_CODNEG", aVetDoc)})
					SE4->( DbSetOrder( 1 ) )
					If ValType(cCPAGPV) <> "C" .Or. SE4->( ! MsSeek( xFilial('SE4') + cCPAGPV, .F. ) )
						cCPAGPV := aContrt[ 1, 9 ]
					Endif
				Endif
				//-- Monta vetor aLote
				TmsA200Lot(aContrt,;
							,;
							GetKeyVal("DT6_CLICAL", aVetDoc),;
							GetKeyVal("DT6_LOJCAL", aVetDoc),;
							"",;
							"",;
							GetKeyVal("DT6_DOCTMS", aVetDoc),;
							aVetDoc[nPosSerie,2],;
							GetKeyVal("DT6_SERTMS", aVetDoc),;
							GetKeyVal("DT6_TIPTRA", aVetDoc),;
							cCPAGPV,;			//-- Condicao Pagamento
							DUI->DUI_CODPRO,;
							"2",;
							,;
							9999,;				//-- nNfCTRC
							,;					//-- cAliasDTC
							cTipNfc)			//-- cTipNfc

				nQtdDoc := Len(aLote)
				aLote[nQtdDoc,01] := GetKeyVal("DT6_CLIREM", aVetDoc)
				aLote[nQtdDoc,02] := GetKeyVal("DT6_LOJREM", aVetDoc)
				aLote[nQtdDoc,03] := GetKeyVal("DT6_CLIDES", aVetDoc)
				aLote[nQtdDoc,04] := GetKeyVal("DT6_LOJDES", aVetDoc)
				aLote[nQtdDoc,05] := GetKeyVal("DT6_CLIDEV", aVetDoc)
				aLote[nQtdDoc,06] := GetKeyVal("DT6_LOJDEV", aVetDoc)
				aLote[nQtdDoc,07] := GetKeyVal("DT6_CLICAL", aVetDoc)
				aLote[nQtdDoc,08] := GetKeyVal("DT6_LOJCAL", aVetDoc)
				aLote[nQtdDoc,12] := aVetNFc[nCntFor1,nPosProCli,2]
				aLote[nQtdDoc,20] := Iif(nPosQtdVol > 0,aVetNFc[nCntFor1,nPosQtdVol,2],0)
				aLote[nQtdDoc,21] := Iif(nPosValMer > 0,aVetNFc[nCntFor1,nPosValMer,2],0)
				aLote[nQtdDoc,22] := Iif(nPosPeso   > 0,aVetNFc[nCntFor1,nPosPeso  ,2],0)
				aLote[nQtdDoc,23] := Iif(nPosPesoM3 > 0,aVetNFc[nCntFor1,nPosPesoM3,2],0)
				aLote[nQtdDoc,24] := Iif(nPosBasSeg > 0,aVetNFc[nCntFor1,nPosBasSeg,2],0)
				aLote[nQtdDoc,25] := GetKeyVal("DT6_CDRORI", aVetDoc)
				aLote[nQtdDoc,26] := GetKeyVal("DT6_CDRDES", aVetDoc)
				aLote[nQtdDoc,27] := GetKeyVal("DT6_CDRCAL", aVetDoc)
				aLote[nQtdDoc,28] := GetKeyVal("DT6_TIPFRE", aVetDoc)
				aLote[nQtdDoc,29] := GetKeyVal("DT6_SERVIC", aVetDoc)
				aLote[nQtdDoc,33] := GetKeyVal("DT6_TIPTRA", aVetDoc)
				aLote[nQtdDoc,54] := GetKeyVal("DT6_DEVFRE", aVetDoc)
				aLote[nQtdDoc,55] := Iif(nPosMetro3 > 0,aVetNFc[nCntFor1,nPosMetro3,2],0)
				aLote[nQtdDoc,56] := Iif(nPosQtdUni > 0,aVetNFc[nCntFor1,nPosQtdUni,2],0)
				If ExistKey("DT6_CLICON", aVetDoc) .And. ExistKey("DT6_LOJCON", aVetDoc)
					aLote[nQtdDoc,58] := GetKeyVal("DT6_CLICON", aVetDoc)
					aLote[nQtdDoc,59] := GetKeyVal("DT6_LOJCON", aVetDoc)
				Else
					aLote[nQtdDoc,58] := Space(Len(DT6->DT6_CLICON))
					aLote[nQtdDoc,59] := Space(Len(DT6->DT6_LOJCON))
				EndIf
				If ExistKey("DT6_CLIDPC", aVetDoc) .And. ExistKey("DT6_LOJDPC", aVetDoc)
					aLote[nQtdDoc,60] := GetKeyVal("DT6_CLIDPC", aVetDoc)
					aLote[nQtdDoc,61] := GetKeyVal("DT6_LOJDPC", aVetDoc)
				Else
					aLote[nQtdDoc,60] := Space(Len(DT6->DT6_CLIDPC))
					aLote[nQtdDoc,61] := Space(Len(DT6->DT6_LOJDPC))
				EndIf
				aLote[nQtdDoc,85] := cRecIss
			Next nCntFor1
		Else
			M_Posicione('DTC',3,xFilial('DTC')+aDocOri[1]+aDocOri[2]+aDocOri[3],'DTC_TIPNFC')
			cCPAGPV:= ''
			cCPAGPV:= aContrt[ 1, 9 ]

			If lTM200Cpg //PE permite alterar a condicao de pagamento
				cCPAGPV:= ExecBlock("TM200CPG",.F.,.F.,{GetKeyVal("DT6_CLICAL", aVetDoc),GetKeyVal("DT6_LOJCAL", aVetDoc),cCPAGPV,GetKeyVal("DT6_SERVIC", aVetDoc),GetKeyVal("DT6_CODNEG", aVetDoc)})
				SE4->( DbSetOrder( 1 ) )
				If ValType(cCPAGPV) <> "C" .Or. SE4->( ! MsSeek( xFilial('SE4') + cCPAGPV, .F. ) )
					cCPAGPV := aContrt[ 1, 9 ]
				Endif
			Endif

			//-- Monta vetor aLote
			TmsA200Lot(aContrt,;
						,;
						GetKeyVal("DT6_CLICAL", aVetDoc),;
						GetKeyVal("DT6_LOJCAL", aVetDoc),;
						"",;
						"",;
						GetKeyVal("DT6_DOCTMS", aVetDoc),;
						aVetDoc[nPosSerie,2],;
						GetKeyVal("DT6_SERTMS", aVetDoc),;
						GetKeyVal("DT6_TIPTRA", aVetDoc),;
						cCPAGPV,;
						DUI->DUI_CODPRO,;
						"2",;
						,;
						9999,;				//-- nNfCTRC
						,;					//-- cAliasDTC
						DTC->DTC_TIPNFC)	//-- cTipNfc

			nQtdDoc := Len(aLote)
			aLote[nQtdDoc,01] := GetKeyVal("DT6_CLIREM", aVetDoc)
			aLote[nQtdDoc,02] := GetKeyVal("DT6_LOJREM", aVetDoc)
			aLote[nQtdDoc,03] := GetKeyVal("DT6_CLIDES", aVetDoc)
			aLote[nQtdDoc,04] := GetKeyVal("DT6_LOJDES", aVetDoc)
			aLote[nQtdDoc,05] := GetKeyVal("DT6_CLIDEV", aVetDoc)
			aLote[nQtdDoc,06] := GetKeyVal("DT6_LOJDEV", aVetDoc)
			aLote[nQtdDoc,07] := GetKeyVal("DT6_CLICAL", aVetDoc)
			aLote[nQtdDoc,08] := GetKeyVal("DT6_LOJCAL", aVetDoc)
			aLote[nQtdDoc,12] := DTC->DTC_CODPRO
			aLote[nQtdDoc,20] := GetKeyVal("DT6_QTDVOL", aVetDoc)
			aLote[nQtdDoc,21] := GetKeyVal("DT6_VALMER", aVetDoc)
			aLote[nQtdDoc,22] := GetKeyVal("DT6_PESO"  , aVetDoc)
			aLote[nQtdDoc,23] := GetKeyVal("DT6_PESOM3", aVetDoc)
			If ExistKey("DT6_BASSEG", aVetDoc)
				aLote[nQtdDoc,24] := GetKeyVal("DT6_BASSEG", aVetDoc)
			Else
				aLote[nQtdDoc,24] := 0
			EndIf
			aLote[nQtdDoc,25] := GetKeyVal("DT6_CDRORI", aVetDoc)
			aLote[nQtdDoc,26] := GetKeyVal("DT6_CDRDES", aVetDoc)
			aLote[nQtdDoc,27] := GetKeyVal("DT6_CDRCAL", aVetDoc)
			aLote[nQtdDoc,28] := GetKeyVal("DT6_TIPFRE", aVetDoc)
			aLote[nQtdDoc,29] := GetKeyVal("DT6_SERVIC", aVetDoc)
			aLote[nQtdDoc,33] := GetKeyVal("DT6_TIPTRA", aVetDoc)
			aLote[nQtdDoc,54] := GetKeyVal("DT6_DEVFRE", aVetDoc)
			aLote[nQtdDoc,55] := GetKeyVal("DT6_METRO3", aVetDoc)
			If ExistKey("DT6_QTDUNI", aVetDoc)
				aLote[nQtdDoc,56] := GetKeyVal("DT6_QTDUNI", aVetDoc)
			Else
				aLote[nQtdDoc,56] := 0
			EndIf
			If ExistKey("DT6_CLICON", aVetDoc) .And. ExistKey("DT6_LOJCON", aVetDoc)
				aLote[nQtdDoc,58] := GetKeyVal("DT6_CLICON", aVetDoc)
				aLote[nQtdDoc,59] := GetKeyVal("DT6_LOJCON", aVetDoc)
			Else
				aLote[nQtdDoc,58] := Space(Len(DT6->DT6_CLICON))
				aLote[nQtdDoc,59] := Space(Len(DT6->DT6_LOJCON))
			EndIf
			If ExistKey("DT6_CLIDPC", aVetDoc) .And. ExistKey("DT6_LOJDPC", aVetDoc)
				aLote[nQtdDoc,60] := GetKeyVal("DT6_CLIDPC", aVetDoc)
				aLote[nQtdDoc,61] := GetKeyVal("DT6_LOJDPC", aVetDoc)
			Else
				aLote[nQtdDoc,60] := Space(Len(DT6->DT6_CLIDPC))
				aLote[nQtdDoc,61] := Space(Len(DT6->DT6_LOJDPC))
			EndIf

			//-- Recolhe ISS
			cRecIss:= M_Posicione('DTC',3,xFilial('DTC')+aDocOri[1]+aDocOri[2]+aDocOri[3],'DTC_RECISS')
			If Empty(cRecIss)
				cRecISS := M_Posicione('SA1',1,xFilial('SA1')+GetKeyVal("DT6_CLIDEV", aVetDoc)+GetKeyVal("DT6_LOJDEV", aVetDoc),'A1_RECISS')
			EndIf
			aLote[nQtdDoc,85] := cRecISS

			nProdNfs := 1
			AAdd(aProdNfs, { DTC->DTC_CODPRO, 0, 0, 0, 0, 0 } )
			aProdNfs[nProdNfs,2] := GetKeyVal("DT6_QTDVOL", aVetDoc)
			aProdNfs[nProdNfs,3] := GetKeyVal("DT6_VALMER", aVetDoc)
			aProdNfs[nProdNfs,4] := GetKeyVal("DT6_PESO"  , aVetDoc)
			aProdNfs[nProdNfs,5] := GetKeyVal("DT6_PESOM3", aVetDoc)
			If ExistKey("DT6_BASSEG", aVetDoc)
				aProdNfs[nProdNfs,6] := GetKeyVal("DT6_BASSEG", aVetDoc)
			Else
				aProdNfs[nProdNfs,6] := 0
			EndIf
		EndIf

		If Empty(cLotNfc)
			cLotNFc := TmsA500Lot(cLotNFc)
		EndIf

		//-- Gera documento
		For nCntFor2 := 1 To Len(aVetVlr)

			If GetKeyVal("DT8_CODPAS", aVetVlr[nCntFor2]) <> "TF"

				nValPas += GetKeyVal("DT8_VALPAS", aVetVlr[nCntFor2])
				nValImp += GetKeyVal("DT8_VALIMP", aVetVlr[nCntFor2])
				nValTot += GetKeyVal("DT8_VALTOT", aVetVlr[nCntFor2])

				nUniPas := GetKeyVal("DT8_VALPAS", aVetVlr[nCntFor2])
				nUniImp := GetKeyVal("DT8_VALIMP", aVetVlr[nCntFor2])
				nUniTot := GetKeyVal("DT8_VALTOT", aVetVlr[nCntFor2])
			Else
				nCntTF := nCntFor2
				Loop
			EndIf

			AAdd(aFrete,{AllTrim(M_Posicione("DT3",1,xFilial("DT3") + GetKeyVal("DT8_CODPAS", aVetVlr[nCntFor2]),"DT3_DESCRI")),;
							 nUniPas,;
							 GetKeyVal("DT8_CODPAS", aVetVlr[nCntFor2]),;
							 "",;
							 nUniImp,;
							 nUniTot,;
							 Space(Len(DT6->DT6_CDRORI)),;
							 Space(Len(DT6->DT6_CDRDES)),;
							 "",;
							 "",;
							 "",;
							 "00",;
							 0,;
							 0,;
							 "2"})
			AAdd(aVetSol,{GetKeyVal("DT8_CODPAS", aVetVlr[nCntFor2]),;
							 Iif(ExistKey("VLR_ICMSOL", aVetVlr[nCntFor2]),GetKeyVal("VLR_ICMSOL", aVetVlr[nCntFor2]),0)})
		Next nCntFor2

		//-- Atualiza o registro "TF" Totalizador.
		If nCntTF > 0
			AAdd(aFrete,{AllTrim(M_Posicione("DT3",1,xFilial("DT3") + GetKeyVal("DT8_CODPAS", aVetVlr[nCntTF]),"DT3_DESCRI")),;
							 nValPas,;
							 GetKeyVal("DT8_CODPAS", aVetVlr[nCntTF]),;
							 "",;
							 nValImp,;
							 nValTot,;
							 Space(Len(DT6->DT6_CDRORI)),;
							 Space(Len(DT6->DT6_CDRDES)),;
							 "",;
							 "",;
							 "",;
							 "00",;
							 0,;
							 0,;
							 "2"})
			AAdd(aVetSol,{GetKeyVal("DT8_CODPAS", aVetVlr[nCntTF]),;
							 Iif(ExistKey("VLR_ICMSOL", aVetVlr[nCntTF]),GetKeyVal("VLR_ICMSOL", aVetVlr[nCntTF]),0)})
		EndIf

		If !Empty(aDocOri)
			Aadd(aTmsA500,'7')							 		//-- [01] = Status do documento DT6_STATUS
			Aadd(aTmsA500,dDataBase)							//-- [02] = Data de entrega
			Aadd(aTmsA500,aDocOri[4])							//-- [03] = % do documento original
			Aadd(aTmsA500,aDocOri[1])							//-- [04] = Filial do documento original
			Aadd(aTmsA500,aDocOri[2])							//-- [05] = Documento original
			Aadd(aTmsA500,aDocOri[3])							//-- [06] = Serie do documento original
			Aadd(aTmsA500,{})						 			//-- [07] = Valor informado x documento de complemento
			Aadd(aTmsA500,aContrt[1,9])						    //-- [08] = Condicao de Pagamento
			//-- [09] = Tipo da Nota (F2_TIPO] / Tipo do Pedido [C5_TIPO] : 'I'
			//-- 14/Nov/2019: Novo argumento, 6ª posição no aDocOri, para validar pela nOpcx, que deve ser igual à nOpcx do TMSA500
			If Len(aDocOri) > 5 
				Aadd(aTmsA500,Iif(aDocOri[6]==10,'I',Iif(aDocOri[6]==6,'C','N')))	
			Else
				Aadd(aTmsA500,IIf(aDocOri[5],'I','N'))			//-- [09] = Tipo da Nota (F2_TIPO] / Tipo do Pedido [C5_TIPO] : 'I'
			EndIf
			Aadd(aTmsA500,'0')    								//-- [10] = Tipo de Manutencao
			Aadd(aTmsA500,'' )       							//-- [11] = Observacao do Documento
			Aadd(aTmsA500,M_Posicione('DT6',1,xFilial('DT6')+aDocOri[1]+aDocOri[2]+aDocOri[3],'DT6_FILDEB'))	//-- [12] = Filial de Debito
		EndIf

		TmsA200Doc( aFrete,;
					aNfCTRC,;
					aTmsA500,;
					cLotNfc,;
					cTabFre,;
					cTipTab,;
					cSeqTab,;
					.F.,;
					aProdNfs[1,2],;
					aProdNfs[1,3],;
					aProdNfs[1,4],;
					aProdNfs[1,5],;
					0,;
					aProdNfs[1,6],;
					0,;
					0,;
					1,;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					Nil )

		//-- Grava documento
		If ExistKey("DT6_DATEMI", aVetDoc)
			dDataBase := GetKeyVal("DT6_DATEMI", aVetDoc)
		EndIf

		TmsA200Grv(@aMsgErr,,@aNfs,.F.,lCalImp,nPerImp,nTipImp,{aVetDoc[nPosDoc,2],aVetDoc[nPosSerie,2]},aVetSol)

		dDataBase := dDatAnt

		If !Empty(aMsgErr)
			AaddMsgErr(aMsgErr,@aVetErr)
		Else
			//-- Atualiza o status do lote
			TMSA200Sta( Nil, cLotNFc, "3" )
		EndIf
	EndIf
EndIf

If lExbHlp .And. !Empty(aVetErr)
	TmsMsgErr(aVetErr)
EndIf

DT6->(RestArea(aAreaDT6))
DTC->(RestArea(aAreaDTC))
DUI->(RestArea(aAreaDUI))
RestArea(aArea)

Return( aVetErr )

/*/{Protheus.doc} GetKeyPos
Retorna a posição de uma chave (posição 1) em um array

@param   cKey   - Chave pesquisada
@param   aKeys  - Array a ser pesquisado

@return  numérico - Retorna a posição da chave
@author  Izac Silvério Ciszevski
/*/
Static Function GetKeyPos(cKey, aKeys)

    Return Ascan(aKeys, {|x| AllTrim( Upper(x[1] ) ) == cKey })

/*/{Protheus.doc} GetKeyVal
Retorna o valor de uma chave (posição 1) em um array

@param   cKey   - Chave pesquisada
@param   aKeys  - Array a ser pesquisado

@return  variável - Retorna o conteúdo da chave
@author  Izac Silvério Ciszevski
/*/
Static Function GetKeyVal(cKey, aKeys)

    Return aKeys[Ascan(aKeys, {|x| AllTrim( Upper(x[1] ) ) == cKey }),2]

/*/{Protheus.doc} ExistKey
Retorna se uma chave(posição 1) existe em um array

@param   cKey     - Chave pesquisada
@param   aKeys    - Array a ser pesquisado
@param   [xValor] - [Opcional] - Se encontrar a chave, preenche seu conteúdo.
                    Deve ser passado por referência.

@return  lógico - Retorna .T. se encontrou a chave
@author  Izac Silvério Ciszevski
/*/
Static Function ExistKey(cKey, aKeys, xValor)
    Local nPos := 0

    nPos := Ascan(aKeys,{|x| AllTrim(Upper(x[1])) == cKey})

    If nPos > 0
        xValor := aKeys[nPos, 2]
    EndIf

    Return nPos > 0

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exemplo de utilização da função TMSImpDoc()³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function ImpDcTst()

Local aVetDoc  := {}
Local aVetVlr  := {}
Local aVetNFc  := {}

Local aItemDTC := {}
Local aCabDTC  := {}
Local aItem    := {}
Local lCont    := .T.
Local cLotNfc  := ''
Local cRet     := ''
Local aCab     := {}
Local aErrMsg  := {}

lMsErroAuto := .F.
nModulo     := 43

AAdd(aCab,{'DTP_QTDLOT',1,NIL})
AAdd(aCab,{'DTP_QTDDIG',0,NIL})
AAdd(aCab,{'DTP_STATUS','1',NIL})	//-- Em aberto
MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCab,3)
If lMsErroAuto
	MostraErro()
	lCont   := .F.
Else
	cLotNfc := cRet
EndIf

If lCont
	lMsErroAuto := .F.

	aCabDTC := { {"DTC_FILORI" ,"01"  , Nil},;
                 {"DTC_LOTNFC" ,cLotNfc, Nil},;
	             {"DTC_CLIREM" ,Padr("000002",Len(DTC->DTC_CLIREM)), Nil},;
	             {"DTC_LOJREM" ,Padr("01"    ,Len(DTC->DTC_LOJREM)), Nil},;
	             {"DTC_DATENT" ,Ctod('31/08/11'), Nil},;
	             {"DTC_CLIDES" ,Padr("000001",Len(DTC->DTC_CLIREM)), Nil},;
	             {"DTC_LOJDES" ,Padr("01"    ,Len(DTC->DTC_LOJREM)), Nil},;
	             {"DTC_CLIDEV" ,Padr("000002",Len(DTC->DTC_CLIREM)), Nil},;
	             {"DTC_LOJDEV" ,Padr("01"    ,Len(DTC->DTC_LOJREM)), Nil},;
	             {"DTC_CLICAL" ,Padr("000002",Len(DTC->DTC_CLIREM)), Nil},;
	             {"DTC_LOJCAL" ,Padr("01"    ,Len(DTC->DTC_LOJREM)), Nil},;
	             {"DTC_DEVFRE" ,"1"       , Nil},;
	             {"DTC_SERTMS" ,"3"       , Nil},;
	             {"DTC_TIPTRA" ,"1"       , Nil},;
                 {"DTC_SERVIC" ,"030"     , Nil},;
                 {"DTC_CODNEG" ,"01"      , Nil},;
	             {"DTC_TIPNFC" ,"0"       , Nil},;
	             {"DTC_TIPFRE" ,"1"       , Nil},;
	             {"DTC_SELORI" ,"1"       , Nil},;
	             {"DTC_CDRORI" ,'B06200', Nil},;
	             {"DTC_CDRDES" ,'Q50308', Nil},;
	             {"DTC_CDRCAL" ,'Q50308', Nil},;
	             {"DTC_DISTIV" ,'2', Nil}}

	   aItem := {{"DTC_NUMNFC" ,"010" , Nil},;
		          {"DTC_SERNFC" ,"UNI"  , Nil},;
				    {"DTC_CODPRO" ,"000001", Nil},;
				    {"DTC_CODEMB" ,"CX" , Nil},;
				    {"DTC_EMINFC" ,Ctod('01/01/11') , Nil},;
			   	 {"DTC_QTDVOL" ,10, Nil},;
				    {"DTC_PESO"   ,100.0000, Nil},;
				    {"DTC_PESOM3" ,0.0000, Nil},;
			    	 {"DTC_VALOR"  ,1000.00, Nil},;
			       {"DTC_BASSEG" ,0.00 , Nil},;
			       {"DTC_METRO3" ,0.0000, Nil},;
			    	 {"DTC_QTDUNI" ,0 , Nil},;
			   	 {"DTC_EDI"    ,"2" , Nil}}

	AAdd(aItemDTC,aClone(aItem))
	//
	// Parametros da TMSA050 (notas fiscais do cliente)
	// xAutoCab - Cabecalho da nota fiscal
	// xAutoItens - Itens da nota fiscal
	// xItensPesM3 - acols de Peso Cubado
	// xItensEnder - acols de Enderecamento
	// nOpcAuto - Opcao rotina automatica
	MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)
	If lMsErroAuto
		MostraErro()
		lCont := .F.
	Else
		DTC->(dbCommit())
	EndIf
EndIf

If lCont
	AAdd(aVetDoc,{"DT6_FILORI","01"})
	AAdd(aVetDoc,{"DT6_LOTNFC",cLotNfc})
	AAdd(aVetDoc,{"DT6_FILDOC","01"})
	AAdd(aVetDoc,{"DT6_DOC"   ,"000007"})
	AAdd(aVetDoc,{"DT6_SERIE" ,"UNI"})
	AAdd(aVetDoc,{"DT6_DATEMI",dDataBase})
	AAdd(aVetDoc,{"DT6_HOREMI","0934"})
	AAdd(aVetDoc,{"DT6_VOLORI", 10})
	AAdd(aVetDoc,{"DT6_QTDVOL", 10})
	AAdd(aVetDoc,{"DT6_PESO"  , 100.0000})
	AAdd(aVetDoc,{"DT6_PESOM3", 0.0000})
	AAdd(aVetDoc,{"DT6_PESCOB", 0.0000})
	AAdd(aVetDoc,{"DT6_METRO3", 0.0000})
	AAdd(aVetDoc,{"DT6_VALMER", 1000.00})
	AAdd(aVetDoc,{"DT6_QTDUNI", 0})
	AAdd(aVetDoc,{"DT6_VALFRE", 1050.00})
	AAdd(aVetDoc,{"DT6_VALIMP", 230.49})
	AAdd(aVetDoc,{"DT6_VALTOT", 1280.49})
	AAdd(aVetDoc,{"DT6_BASSEG", 0.00})
	AAdd(aVetDoc,{"DT6_SERTMS","2"})
	AAdd(aVetDoc,{"DT6_TIPTRA","1"})
	AAdd(aVetDoc,{"DT6_DOCTMS","2"})
	AAdd(aVetDoc,{"DT6_CDRORI","B06200"})
	AAdd(aVetDoc,{"DT6_CDRDES","Q50308"})
	AAdd(aVetDoc,{"DT6_CDRCAL","Q50308"})
	AAdd(aVetDoc,{"DT6_TABFRE","R007"})
	AAdd(aVetDoc,{"DT6_TIPTAB","01"})
	AAdd(aVetDoc,{"DT6_SEQTAB","00"})
	AAdd(aVetDoc,{"DT6_TIPFRE","1"})
	AAdd(aVetDoc,{"DT6_FILDES","01"})
	AAdd(aVetDoc,{"DT6_BLQDOC","2"})
	AAdd(aVetDoc,{"DT6_PRIPER","2"})
	AAdd(aVetDoc,{"DT6_PERDCO", 0.00000})
	AAdd(aVetDoc,{"DT6_FILDCO",""})
	AAdd(aVetDoc,{"DT6_DOCDCO",""})
	AAdd(aVetDoc,{"DT6_SERDCO",""})
	AAdd(aVetDoc,{"DT6_CLIREM",Padr("000002",Len(DTC->DTC_CLIREM))})
	AAdd(aVetDoc,{"DT6_LOJREM",Padr("01"    ,Len(DTC->DTC_LOJREM))})
	AAdd(aVetDoc,{"DT6_CLIDES",Padr("000001",Len(DTC->DTC_CLIREM))})
	AAdd(aVetDoc,{"DT6_LOJDES",Padr("01"    ,Len(DTC->DTC_LOJREM))})
	AAdd(aVetDoc,{"DT6_CLIDEV",Padr("000002",Len(DTC->DTC_CLIREM))})
	AAdd(aVetDoc,{"DT6_LOJDEV",Padr("01"    ,Len(DTC->DTC_LOJREM))})
	AAdd(aVetDoc,{"DT6_CLICAL",Padr("000002",Len(DTC->DTC_CLIREM))})
	AAdd(aVetDoc,{"DT6_LOJCAL",Padr("01"    ,Len(DTC->DTC_LOJREM))})
	AAdd(aVetDoc,{"DT6_DEVFRE","1"})
	AAdd(aVetDoc,{"DT6_FATURA",""})
	AAdd(aVetDoc,{"DT6_SERVIC","030"})
	AAdd(aVetDoc,{"DT6_CODNEG","01"})
	AAdd(aVetDoc,{"DT6_CODMSG",""})
	AAdd(aVetDoc,{"DT6_STATUS","1"})
	AAdd(aVetDoc,{"DT6_DATEDI",CToD("  /  /  ")})
	AAdd(aVetDoc,{"DT6_NUMSOL",""})
	AAdd(aVetDoc,{"DT6_VENCTO",CToD("  /  /  ")})
	AAdd(aVetDoc,{"DT6_FILDEB","01"})
	AAdd(aVetDoc,{"DT6_PREFIX",""})
	AAdd(aVetDoc,{"DT6_NUM"   ,""})
	AAdd(aVetDoc,{"DT6_TIPO"  ,""})
	AAdd(aVetDoc,{"DT6_MOEDA" , 1})
	AAdd(aVetDoc,{"DT6_BAIXA" ,CToD("  /  /  ")})
	AAdd(aVetDoc,{"DT6_FILNEG","01"})
	AAdd(aVetDoc,{"DT6_ALIANC",""})
	AAdd(aVetDoc,{"DT6_REENTR", 0})
	AAdd(aVetDoc,{"DT6_TIPMAN",""})
	AAdd(aVetDoc,{"DT6_PRZENT",Ctod('31/08/18')})
	AAdd(aVetDoc,{"DT6_FIMP"  ,"1"})

	AAdd(aVetVlr,{{"DT8_CODPAS","01"},;
				     {"DT8_VALPAS", 50.00},;
				     {"DT8_VALIMP", 10.98},;
	              {"DT8_VALTOT", 60.98},;
					  {"DT8_FILORI",""},;
					  {"DT8_TABFRE","R007"},;
					  {"DT8_TIPTAB","01"},;
				     {"DT8_FILDOC","01"},;
					  {"DT8_CODPRO","000001"},;
				  	  {"DT8_DOC"   ,"000007"},;
				     {"DT8_SERIE" ,"UNI"},;
				     {"VLR_ICMSOL",0}})
	AAdd(aVetVlr,{{"DT8_CODPAS","02"},;
				     {"DT8_VALPAS",  1000.00},;
				     {"DT8_VALIMP",  219.51},;
				     {"DT8_VALTOT",  1219.51},;
				     {"DT8_FILORI",""},;
				     {"DT8_TABFRE","R007"},;
				     {"DT8_TIPTAB","01"},;
				     {"DT8_FILDOC","01"},;
				     {"DT8_CODPRO","000001"},;
				     {"DT8_DOC"   ,"000007"},;
				     {"DT8_SERIE" ,"UNI"},;
	  			     {"VLR_ICMSOL",0}})
	AAdd(aVetVlr,{{"DT8_CODPAS","TF"},;
				     {"DT8_VALPAS", 1050.00},;
				     {"DT8_VALIMP", 230.49},;
				     {"DT8_VALTOT", 1280.49},;
				     {"DT8_FILORI",""},;
				     {"DT8_TABFRE",""},;
				     {"DT8_TIPTAB",""},;
				     {"DT8_FILDOC","01"},;
				     {"DT8_CODPRO","000001"},;
				     {"DT8_DOC"   ,"000007"},;
			    	  {"DT8_SERIE" ,"UNI"},;
	  		   	  {"VLR_ICMSOL",0}})

	AAdd(aVetNFc,{{"DTC_CLIREM",Padr("000002",Len(DTC->DTC_CLIREM))},;
				     {"DTC_LOJREM",Padr("01"    ,Len(DTC->DTC_LOJREM))},;
				     {"DTC_NUMNFC",Padr("010",Len(DTC->DTC_NUMNFC))},;
				     {"DTC_SERNFC",Padr("UNI"     ,Len(DTC->DTC_SERNFC))},;
				     {"DTC_CODPRO","000001"},;
				     {"DTC_QTDVOL", 10},;
				     {"DTC_PESO"  , 100.0000},;
				     {"DTC_PESOM3", 0.0000},;
				     {"DTC_METRO3", 0.0000},;
				     {"DTC_VALOR" , 1000.00}})

	aErrMsg := TMSImpDoc(aVetDoc,aVetVlr,aVetNFc,cLotNfc,.F.,0,1,.T.,.T.,.T.,.T.)

EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSTipoCTE  ³ Autor ³ Jefferson Tomaz    ³ Data ³22.01.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3( DLC1) para visualizar os Status para o        ³±±
±±³          ³ Conhecimento de Transporte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTipoCTE()
Local aRet := {}

AAdd( aRet, {'0', STR0142 })	//-- 'Nao Se Aplica'
AAdd( aRet, {'1', STR0143 })	//-- "Aguardando"
AAdd( aRet, {'2', STR0144 })	//-- 'Autorizado'
AAdd( aRet, {'3', STR0145 })	//-- 'Nao Autorizado'
AAdd( aRet, {'4', STR0146 })	//-- 'Em Contingencia'
AAdd( aRet, {'5', STR0147 })	//-- 'Falha Comunicacao'
AAdd( aRet, {'6', STR0148 })	//-- 'Nao Transmitido'


//-- Apresenta a tela para selecao do item.
nTmsItem := TmsF3Array( {STR0149, STR0035}, aRet, STR0150 ) //"Codigo"###"Descricao"###"Status do Ct-e"

If	nTmsItem > 0
	//-- VAR_IXB eh utilizada como retorno da consulta F3 DLC.
	VAR_IXB := aRet[ nTmsItem, 1 ]
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSSITCTE   ³ Autor ³ Jefferson Tomaz    ³ Data ³22.01.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funçao para retornar o Combo do DTP_SITCTE				  ³±±
±±³          ³ esta funcao so foi criada pois no campo do                 ³±±
±±³          ³ x3_inibrw nao cabe o comando todo. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 						                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSSITCTE(cLote)
Local cX3_Combo := ''
Default clote   := ''

cX3_Combo := X3COMBO('DTP_SITCTE',POSICIONE('DTP',1,XFILIAL('DTP')+cLote,'DTP_SITCTE'))

Return( cX3_Combo )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSTipoPAE  ³ Autor ³ Marcelo Coutinho   ³ Data ³08.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3( DLC ) para visualizar os tipos:               ³±±
±±³          ³ Prioridade de Agendamento de Entrega;                      ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTipoPAE(cCampo)

Default cCampo  := ReadVar()

TMSValField(cCampo,,,.T.,,.F.)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CteIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

RestArea(aArea)

Return( cIdEnt )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSTabDest³ Autor ³Marcelo Coutinho       ³ Data ³ 07/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³			 ³Verifica se o Cliente/Loja possui Agendamento de Entrega    ³±±
±±³			 ³Descricao do ARRAY aReT:                                	  ³±±
±±³			 ³ aRet[1] - Cliente trabalha com tabela de frete por         ³±±
±±³	Descri‡…o³ destinatario                                               ³±±
±±³			 ³ aRet[2] - Exige agendamento de entrega                     ³±±
±±³			 ³ aRet[3] - Documentos que podem efetuar a cobrança do       ³±±
±±³			 ³ componente 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSTabDest(cCliDes,cLojDes,cCodPas)

Local   cQuery    := ""
Local   cAliasQry := ""
Local   aGetArea  := GetArea()
Local   aRet      := { .F., "2", "" }
Default cCliDes   := ""
Default cLojDes   := ""
Default cCodPas   := ""

cAliasQry := GetNextAlias()

cQuery := "SELECT DYF_AGDENT "+Iif(!Empty(cCodPas),",DYE.DYE_DOCCOB ","")
cQuery += "  FROM "
cQuery += RetSqlName("DYF") + " DYF, "
If !Empty(cCodPas)
	cQuery += RetSqlName("DYE") + " DYE "
	cQuery += " WHERE DYE.DYE_FILIAL  = '"  + xFilial("DYE")  + "'"
	cQuery += "   AND DYE.DYE_CODPAS  = '"  + cCodPas         + "'"
	cQuery += "   AND DYF.DYF_FILIAL  = '"  + xFilial("DYF")  + "'"
	cQuery += "   AND DYF.DYF_CODPAS  = DYE.DYE_CODPAS"
Else
	cQuery += " WHERE DYF.DYF_FILIAL  = '"  + xFilial("DYF")  + "'"
EndIf
cQuery += "       AND DYF.DYF_CLIDES  = '"  + cCliDes         + "'"
cQuery += "       AND DYF.DYF_LOJDES  = '"  + cLojDes         + "'"
cQuery += "       AND DYF.DYF_DATDE  <= '"  + Dtos(dDataBase) + "'"
cQuery += "       AND (DYF.DYF_DATATE  = ' '"
cQuery += "        OR DYF.DYF_DATATE >= '"  + Dtos(dDataBase) + "')"
cQuery += "       AND DYF.D_E_L_E_T_  = ' '"
If !Empty(cCodPas)
	cQuery += "       AND DYE.D_E_L_E_T_  = ' '"
EndIf
If Empty(cCodPas)
	cQuery += " ORDER BY DYF_AGDENT"
EndIf
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof())
	aRet[1] := .T.
	aRet[2] := (cAliasQry)->DYF_AGDENT
	aRet[3] := Iif(!Empty(cCodPas),(cAliasQry)->DYE_DOCCOB,"")
EndIf

(cAliasQry)->(DbCloseArea())

RestArea(aGetArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M_Posicione  ºAutor  ³Microsiga        º Data ³  24/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para manter em cache os recnos utilizadas para       º±±
±±º          ³substituir a funcao posicione originalmente chamada         º±±
±±º          ³o cache sera mantido no array STATIC a_Posicion             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function M_Posicione(cAlias,nOrdem,cChave,cCampoRet)
Local nPos := 0
Local cAuxFil := cEmpAnt+cFilAnt+xFilial(cAlias)
Local nOrdAux := StrZero(nOrdem,2)
Local xRetorno

(cAlias)->( dbSetOrder(nOrdem) )

If ( nPos := aScan(a_Posicion,{|x|x[1]+x[2]+x[3]+x[4]==cAuxFil+cAlias+nOrdAux+cChave}) ) > 0
    (cAlias)->( dbGoto(a_Posicion[nPos, 5]) )
    xRetorno := &(cAlias+"->("+cCampoRet+")")
Else
	If	(cAlias)->(MsSeek(cChave))
		aAdd(a_Posicion, { cAuxFil, cAlias, nOrdAux, cChave, (cAlias)->(Recno()) } )
	EndIf
	xRetorno := &(cAlias+"->("+cCampoRet+")")
EndIf

Return(xRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerIDProc ³ Autor ³ Marcelo Pimentel      ³ Data ³24.07.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±±
±±³          ³stored procedure, qualquer alteracao que envolva diretamente³±±
±±³          ³a stored procedure a variavel sera incrementada.            ³±±
±±³          ³Procedure CTB001                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*Static Function VerIDProc()
Return "010"*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsRegProc -  Autor -                       - Data :00.05.2012|
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o Traz a Regra de tributaçao  via procedure                      |
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TmsRegProc()
Local lRet      := .t.
Local cArqTemp  := ""
Local nProx     := 0
Local aProc     := {}
Local cProc     := ""
Local aRet      := {}
Local aCampos   := {}
Local aSaveArea := GetArea()

/* -------------------------------------------------------------------
   Cria Tabela e índice temporários para substituir o array  aBusca
   DUG_ITEM1 ,DUG_ITEM2, NCOUNT, DUG_ITEMCO.
   Cria um índice DESCENDENTE com o campo DUG_ITEMCO
   ------------------------------------------------------------------- */
cArqTrb := CriaTrab(,.F.)                  //-> nome do temporario
											//--cArq    := cArqTRB+StrZero(nProx,2)
AADD( acampos,{'DUG_REGTRI', 'C',TamSX3("DUG_REGTRI")[1]})
AADD( acampos,{'DUG_TIPFRE', 'C',TamSX3("DUG_TIPFRE")[1]})
AADD( acampos,{'DUG_CODPAS', 'C',TamSX3("DUG_CODPAS")[1]})
AADD( acampos,{'DUG_ESTORI', 'C',TamSX3("DUG_ESTORI")[1]})
AADD( acampos,{'DUG_ESTDEV', 'C',TamSX3("DUG_ESTDEV")[1]})
AADD( acampos,{'DUG_ESTDES', 'C',TamSX3("DUG_ESTDES")[1]})
AADD( acampos,{'DUG_SATIV',  'C',TamSX3("DUG_SATIV")[1]})
AADD( acampos,{'DUG_ESTVEI', 'C',TamSX3("DUG_ESTVEI")[1]})
AADD( acampos,{'DUG_ITEM1',  'N',TamSX3("DUG_ITEM")[1]})
AADD( acampos,{'DUG_ITEM2',  'N',TamSX3("DUG_ITEM")[1]})
AADD( acampos,{'NCOUNT',     'N',TamSX3("DUG_ITEM")[1]})
AADD( acampos,{'DUG_ITEMCO', 'C',TamSX3("DUG_ITEM")[1]*2})

cArqTemp := cArqTrb
MsErase(cArqTemp)
MsCreate(cArqTemp,aCampos, "TOPCONN")       //--> cria o arquivo temporario
Sleep(500)
dbUseArea(.T., "TOPCONN",cArqTemp,cArqTemp/*cAlias*/,.T.,.F.)
dbSelectArea(cArqTemp)
dbClosearea()

/* ----------------------------------------------------------------------------------------------------------
	Inicio da criação das PROCEDURES DINâMICAS
	PROC001 - xFilial   - > Retorna filial corrente  .................................................. aProc[1]
	PROC002 - MSSTRZERO - > mSSTRZERO ..................................................................aProc[2]
	PROC003 - TMS012    - > Percorre o Temporário e busca no SF4 se existe o Reg de tributação..........aProc[3]
				TmsaRegra(cRegTri,cTipFre,cCodPas,cEstOri,cEstDev,cEstDes,cAtividade,lConsig)
	PROC004 - TMS011    - > Retorna o recno do DV1 e o RegTri -> AAdd( aRegCli,      ...................aProc[4]
			  { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cTipCli+cSeqIns   })
	PROC005 - TMS010    -> Chamadora ...................................................................aProc[5]
	---------------------------------------------------------------------------------------------------------- */
If lRet
	/* ---------------------------------------------------------
	   Cria a procedure SCNNNNN01_EE ( Xfilial )-> aProc[1]
	   --------------------------------------------------------- */
	nProx:= nProx+1
	cProc := cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)
	lRet  := TmsxProc01(cProc)        // TmsxProc01 -> xfilial -> aProc[1]
EndIf
If lRet
	/* ---------------------------------------------------------
	   Cria a procedure SCNNNNN02_EE ( MSSTRZERO )-> aProc[2]
	   --------------------------------------------------------- */
	nProx:= nProx+1
	cProc := cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)
	lRet  := TmsxProc02(cProc)        // TmsxProc02 -> Msstrzero -> aProc[2]
EndIf
If lRet
	/* ---------------------------------------------------------
	   Cria a procedure SCNNNNN03_EE (TMS012)  -> aProc[3]
	   --------------------------------------------------------- */
	nProx:= nProx+1
	cProc := cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)
	lRet  := TmsxProc03(cProc,aProc, cArqTemp)        // TmsxProc03-> TMS012 -> aProc[3]
EndIf
If lRet
	/*  ---------------------------------------------------------
	   Cria a procedure SCNNNNN04_EE (TMS011)  -> aProc[4]
	   REcno e Regtri do DV! queries
	    --------------------------------------------------------- */
	nProx:= nProx+1
	cProc := cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)
	lRet  := TmsxProc04(cProc)        // TmsxProc04-> TMS011 -> aProc[4]
EndIf
If lRet
	/*  ---------------------------------------------------------
	   Cria a procedure SCNNNNN04_EE (TMS010)  -> aProc[4]
	    --------------------------------------------------------- */
	nProx:= nProx+1
	cProc := cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)
	lRet  := TmsxProc05(cProc, aProc, cArqTemp)        // TmsxProc05-> TMS010 -> aProc[5]
EndIf
//      lRet  - .T. Se criou as procedures
//      cProc - Nome da procedure sem a empresa
//      aProc - arrauy com todas as procedures
//      cArqTemp - Arquivo Temporário
aRet:= {lRet, cProc, aProc, cArqTemp}

RestArea(aSaveArea)
Return(aRet)
/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³TmsxProc1 -  Autor -                       -  Data :00.05.2012|
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o Cria a procedre xfilial                                        |
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsxProc01(cProc)
Local aSaveArea := GetArea()
Local cProc   := cProc+"_"+cEmpAnt
Local cQuery  := ""
Local lRet    := .T.
Local aCampos := DUG->(DbStruct())
Local nPos    := 0
Local cTipo   := ""

cQuery :="Create procedure "+cProc+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_ALIAS        Char(03),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery +="  @IN_FILIALCOR    "+cTipo+","+CRLF
cQuery +="  @OUT_FILIAL      "+cTipo+" OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF

/* -------------------------------------------------------------------
    Versão      -  <v> Genérica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>

   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de Negócio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa

   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possíveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */
cQuery +="Declare @cModo    Char( 01 )"+CRLF
cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
cQuery +="Declare @iTamFil  Integer"+CRLF
cQuery +="Declare @iTamUn   Integer"+CRLF
cQuery +="Declare @iTamEmp  Integer"+CRLF

cQuery +="begin"+CRLF

cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF

cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
cQuery +="    From SX2"+cEmpAnt+"0 "+CRLF
cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
cQuery +="     and D_E_L_E_T_ = ' '"+CRLF

  /*   SITUACAO -> 1 somente FILIAL */
cQuery +="  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2 ) begin"+CRLF   //  -- so tem filial tam 2
cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery +="  end else begin"+CRLF
    /*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
cQuery +="    If @iTamEmp = 0 begin"+CRLF
cQuery +="      If @cModoUn = 'E' begin"+CRLF
cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end else begin"+CRLF
      /* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
cQuery +="      If @iTamUn > 0 begin"+CRLF
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModoUn = 'E' begin"+CRLF
cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
cQuery +="          end else begin"+CRLF
cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="          end"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end else begin"+CRLF
        /*  SITUACAO -> 3 EMPRESA e FILIAL */
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end"+CRLF
cQuery +="  end"+CRLF
cQuery +="end"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query da filial nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da proc filial: "+cProc)
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)
/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³TmsxProc2 -  Autor -                       -  Data :00.05.2012|
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o Cria a procedre MSSTRZERO                                      |
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsxProc02(cProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cQuery    := ''
Local nRet      := 0

cQuery := ProcSTRZERO(cProc)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0
		MsgAlert("Erro na criacao da procedure TmsxProc02 "+cProc)
		lRet:= .F.
	EndIf
EndIf
RestArea(aSaveArea)
Return(lRet)
/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³TmsxProc3 -  Autor -                       -  Data :00.05.2012|
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o Percorre o Temporário e busca no SF4 se existe o Reg
	 de tributação..........aProc[3]                                            |
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsxProc03(cProc, aProc, cArqTemp)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cProcNome := cProc+"_"+cEmpAnt
Local cQuery    := ''
Local aCampos   := DUG->(dbStruct())
Local aCampos1  := SF4->(dbStruct())
Local cTipo     := ''
Local nRet      := 0
Local nPos      := 0
Local nPTratRec	:= 0

cQuery:="Create Procedure "+cProcNome+"("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL        "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_REGTRI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CREGTRI       "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_TIPFRE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CTIPFRE       "+cTipo+CRLF
cQuery+="   @IN_LCONSIG       char( 01 ),"+CRLF
cQuery+="   @IN_LCPOCONSIG    char( 01 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_TES" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="   @OUT_DUG_TES      "+cTipo+" OutPut,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_CODMSG" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="   @OUT_DUG_CODMSG   "+cTipo+" OutPut,"+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "F4_ISS" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" )"
cQuery+="   @OUT_F4_ISS       "+cTipo+" OutPut"+CRLF
cQuery+="   )"+CRLF
cQuery+="as"+CRLF
/* ------------------------------------------------------------------------------------
   Versão          - <v>  Protheus 9.12 </v>
   Assinatura      - <a>  001 </a>
   Fonte Microsiga - <s>  Tmsxfunb </s>
   Descricao       - <d>  Retorna regra de Tributação </d>
   Funcao do Siga  -      TmsaRegra
   Entrada         - <ri> @IN_LCONSIG    - '1' se cosidera consignatario e '0' se não considera.
                          @IN_LCPOCONSIG - '1' se nModulo = 43 .And. DUG->(FieldPos("DUG_CONSIG")) > 0, e '0' caso contrario
                   - </ri>
   Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>

   TMS012 - Retorna regra de Tributação
            Le a tabela ABUSCA e retorna o primerio valor encontrado
   Function TmsaRegra(cRegTri,cTipFre,cCodPas,cEstOri,cEstDev,cEstDes,cAtividade,lConsig)
   -------------------------------------------------------------------------------------- */
cQuery+="Declare @cAux          char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cFilial_SF4   "+cTipo+CRLF
cQuery+="Declare @cFilial_DUG   "+cTipo+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "F4_ISS" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" )"
cQuery+="Declare @cF4_ISSXX     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_REGTRI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_REGTRI   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_TIPFRE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_TIPFRE   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_CODPAS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_CODPAS   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_ESTORI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_ESTORI   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_ESTDEV" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_ESTDEV   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_ESTDES" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_ESTDES   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_SATIV" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_SATIV    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_ESTVEI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_ESTVEI    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_CODMSG" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_CODMSG   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_TES" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_TESXX    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUG_CODMSG" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUG_CODMSGXX "+cTipo+CRLF

cQuery+="Declare @cDUG_ITEMCO   char( 04 )"+CRLF        //   --> criado para ordenaçao descendente para ficar igual ao padrao
cQuery+="Declare @iRecnoDUGXX   integer"+CRLF

cQuery+="begin"+CRLF

cQuery+="   select @OUT_DUG_TES    = ' '"+CRLF
cQuery+="   select @OUT_DUG_CODMSG = ' '"+CRLF
cQuery+="   select @OUT_F4_ISS     = ' '"+CRLF
cQuery+="   select @cF4_ISSXX      = ' '"+CRLF
cQuery+="   select @iRecnoDUGXX    = 0"+CRLF

cQuery+="   select @cAux = 'SF4'"+CRLF
cQuery+="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFilial_SF4 OutPut"+CRLF
cQuery+="   select @cAux = 'DUG'"+CRLF
cQuery+="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFilial_DUG OutPut"+CRLF
cQuery+="   "+CRLF
cQuery+="   Declare CUR_ABUSCA insensitive cursor for"+CRLF
cQuery+="    select DUG_REGTRI, DUG_TIPFRE, DUG_CODPAS, DUG_ESTORI, DUG_ESTDEV, DUG_ESTDES, DUG_SATIV, DUG_ITEMCO"+CRLF
cQuery+="   ,DUG_ESTVEI"+CRLF
cQuery+="      From "+cArqTemp+CRLF
cQuery+="     where DUG_REGTRI = @IN_CREGTRI"+CRLF
cQuery+="       and DUG_TIPFRE = @IN_CTIPFRE"+CRLF
cQuery+="       and D_E_L_E_T_ = ' '"+CRLF
cQuery+="    order by DUG_ITEMCO desc"+CRLF
cQuery+="   for read only"+CRLF
cQuery+="   Open CUR_ABUSCA"+CRLF
cQuery+="   Fetch CUR_ABUSCA into @cDUG_REGTRI, @cDUG_TIPFRE, @cDUG_CODPAS, @cDUG_ESTORI, @cDUG_ESTDEV, @cDUG_ESTDES, @cDUG_SATIV, @cDUG_ITEMCO"+CRLF
cQuery+=", @cDUG_ESTVEI"+CRLF

cQuery+="   While (@@Fetch_status = 0 ) begin"+CRLF

cQuery+="      select @iRecnoDUGXX = R_E_C_N_O_, @cDUG_CODMSGXX = DUG_CODMSG, @cDUG_TESXX = DUG_TES"+CRLF
cQuery+="        from "+RetSqlName("DUG")+CRLF
cQuery+="       where DUG_FILIAL = @cFilial_DUG"+CRLF
cQuery+="         and DUG_REGTRI = @cDUG_REGTRI"+CRLF
cQuery+="         and DUG_TIPFRE = @cDUG_TIPFRE"+CRLF
cQuery+="         and DUG_CODPAS = @cDUG_CODPAS"+CRLF
cQuery+="         and DUG_ESTORI = @cDUG_ESTORI"+CRLF
cQuery+="         and DUG_ESTDEV = @cDUG_ESTDEV"+CRLF
cQuery+="         and DUG_ESTDES = @cDUG_ESTDES"+CRLF
cQuery+="         and DUG_SATIV  = @cDUG_SATIV" +CRLF
cQuery+="     and DUG_ESTVEI = @cDUG_ESTVEI"+CRLF
cQuery+="         ##FIELDP01( 'DUG.DUG_CONSIG' )"+CRLF
cQuery+="         and ((DUG_CONSIG IN ('1','3','') and (@IN_LCONSIG = '1' and @IN_LCPOCONSIG = '1')) OR"+CRLF
cQuery+="             ((DUG_CONSIG  IN ('2','3') and (@IN_LCONSIG = '0' and @IN_LCPOCONSIG = '1')) OR "+CRLF
cQuery+="              (DUG_CONSIG  = '1' AND NOT EXISTS "+CRLF
cQuery+="                                        ( SELECT 1 FROM "+RetSqlName("DUG")+CRLF
cQuery+="                                            WHERE DUG_FILIAL = @cFilial_DUG"+CRLF
cQuery+="                                              and DUG_REGTRI = @cDUG_REGTRI"+CRLF
cQuery+="                                              and DUG_TIPFRE = @cDUG_TIPFRE"+CRLF
cQuery+="                                              and DUG_CODPAS = @cDUG_CODPAS"+CRLF
cQuery+="                                              and DUG_ESTORI = @cDUG_ESTORI"+CRLF
cQuery+="                                              and DUG_ESTDEV = @cDUG_ESTDEV"+CRLF
cQuery+="                                              and DUG_ESTDES = @cDUG_ESTDES"+CRLF
cQuery+="                                              and DUG_SATIV  = @cDUG_SATIV" +CRLF
cQuery+="                                          and DUG_ESTVEI = @cDUG_ESTVEI"+CRLF
cQuery+="                                              and DUG_CONSIG IN ('2','3','')"+CRLF
cQuery+="                                              and D_E_L_E_T_ = ' ' ))))"+CRLF
cQuery+="         ##ENDFIELDP01"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF

cQuery+="         If ( @iRecnoDUGXX > 0 and @iRecnoDUGXX is not null ) begin"+CRLF

cQuery+="            select @cF4_ISSXX = IsNull( F4_ISS, ' ' )"+CRLF
cQuery+="              From "+RetSqlName("SF4")+CRLF
cQuery+="             Where F4_FILIAL = @cFilial_SF4"+CRLF
cQuery+="               and F4_CODIGO = @cDUG_TESXX"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF
cQuery+="            Break"+CRLF
cQuery+="         End"+CRLF

cQuery+="      Fetch CUR_ABUSCA into @cDUG_REGTRI, @cDUG_TIPFRE, @cDUG_CODPAS, @cDUG_ESTORI, @cDUG_ESTDEV, @cDUG_ESTDES, @cDUG_SATIV, @cDUG_ITEMCO"+CRLF
cQuery+=", @cDUG_ESTVEI"+CRLF

cQuery+="   End"+CRLF
cQuery+="   Close CUR_ABUSCA"+CRLF
cQuery+="   Deallocate CUR_ABUSCA"+CRLF

cQuery+="   If @cDUG_TESXX    is null or @cDUG_TESXX = ''    select @OUT_DUG_TES    = ' ' else select @OUT_DUG_TES    = @cDUG_TESXX"+CRLF
cQuery+="   If @cDUG_CODMSGXX is null or @cDUG_CODMSGXX = '' select @OUT_DUG_CODMSG = ' ' else select @OUT_DUG_CODMSG = @cDUG_CODMSGXX"+CRLF
cQuery+="   If @cF4_ISSXX     is null or @cF4_ISSXX = ''     select @OUT_F4_ISS     = ' ' else select @OUT_F4_ISS     = @cF4_ISSXX"+CRLF
cQuery+="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery,nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query do TmsxProc03 nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		nRet := TcSqlExec(cQuery)
		If nRet != 0
			MsgAlert("Erro na criacao da procedure TmsxProc03 "+cProc)
			lRet:= .F.
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)
Return(lRet)
/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³TmsxProc4 -  Autor -                       -  Data :00.05.2012|
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	   Cria a procedure SCNNNNN03_EE (TMS011)  -> aProc[4]
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsxProc04(cProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cProcNome := cProc+"_"+cEmpAnt
Local cQuery    := ''
Local aCampos   := DV1->(dbStruct())
Local aCampos1  := DUF->(dbStruct())
Local cTipo     := ''
Local nRet      := 0
Local nPos      := 0
Local nPTratRec	:= 0

cQuery:="Create Procedure "+cProcNome+"("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILDV1    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_CODCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CCLIDEV   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_LOJCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CLOJDEV   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_DOCTMS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CDOCTMS   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_CODPRO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CCODPRO   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_TIPNFC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CTIPNFC   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_TIPCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CTIPCLI   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_SEQINS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CSEQINS   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_SEQINS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CVZSEQINS "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_TIPCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CVZTIPCLI "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_CODCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CCLIGEN   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_LOJCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CLOJGEN   "+cTipo+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "DUF_REGTRI" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" )"
cQuery+="   @OUT_REGTRI   "+cTipo+" OutPut,"+CRLF
cQuery+="   @OUT_RECNO    Integer OutPut"+CRLF
cQuery+=" )"+CRLF

cQuery+="as"+CRLF
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Fonte Microsiga - <s>  TmsRegTrib </s>
    Descricao       - <d>  Retorna regra de Tributação </d>
    Funcao do Siga  -      TmsRegTrib()
    Entrada         - <ri>              - </ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
   -------------------------------------------------------------------------------------- */
cQuery+="declare @lCpoDv1  char( 01 )"+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "DUF_REGTRI" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" )"
cQuery+="declare @cREGTRI  "+cTipo+CRLF
cQuery+="declare @iRecno   integer"+CRLF

cQuery+="begin"+CRLF
cQuery+="   select @OUT_RECNO  = 0"+CRLF
cQuery+="   select @OUT_REGTRI = ' '"+CRLF
cQuery+="   select @cREGTRI    = ' '"+CRLF
cQuery+="   select @lCpoDv1    = '0'"+CRLF
cQuery+="   select @iRecno     = null"+CRLF

cQuery+="   ##FIELDP01( 'DV1.DV1_TIPNFC' )"+CRLF
cQuery+="      select @lCpoDv1 = '1'"+CRLF
      /*  01 - XXXXXXXX   -- AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cTipCli+cSeqIns   }) */
cQuery+="      Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="        From "+RetSqlName("DV1")+CRLF
cQuery+="       Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="         and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="         and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="         and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="         and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="         and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="         and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="         and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF

cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  02 - XXXXXXX- AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  03 - XXXXXX-X  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI" +CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  04 - XXXXXX--  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+cTipNFC+cVzTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI" +CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /* 05 - XXXX--XX  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF

cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  06 - XXXX--X-  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns }) */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  07 - XXXX---X  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  08 - XXXX --  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns }) */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  09 - XXXXX-XX  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  10 - XXXXX-X-  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  11 - XXXXX--X  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  12 - XXXXX---  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  13 - XXXX-XXX  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  14 - XXXX-XX-  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
	   	/*  15 - XXXX-X-X  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  16 - XXXX-X--  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  17 - XXXXXXXX  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
	   	/*  18 - XXXXXXX-  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  19 - XXXXXX-X  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  20 - XXXXXX--  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+cTipNFC+cVzTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1 "+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
	   	/*  21 - XXXX--XX  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  22 - XXXX--X-  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  23 - XXXX---X  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
	   	/*  24 - XXXX---- AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns }) --  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  25 - XXXXX-XX  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  26 - XXXXX-X-  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
	   	/*  27 - XXXXX--X  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  28 - XXXXX---  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro+Space(Len(DV1->DV1_TIPNFC))+cVzTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and DV1_TIPNFC = ' '"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  29 - XXXX-XXX 	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
	   	/*  30 - XXXX-XX-  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  31 - XXXX-X-X  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cSeqIns   })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  32 - XXXX-X-- 	AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD))+cTipNFC+cVzTipCli+cVzSeqIns })--  */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and DV1_TIPNFC = @IN_CTIPNFC"+CRLF
cQuery+="            and DV1_TIPCLI = @IN_CVZTIPCLI"+CRLF
cQuery+="            and DV1_SEQINS = @IN_CVZSEQINS"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      end"+CRLF
cQuery+="   ##ENDFIELDP01"+CRLF
   /* ------------------------------------
      Se o campo DV1_TIPNFC NÃO existir
      ------------------------------------ */
cQuery+="   If @lCpoDv1 = '0' begin	"+CRLF
		/*  01 - XXXXX  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+cCodPro}) */
cQuery+="      Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="        From "+RetSqlName("DV1")+CRLF
cQuery+="       Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="         and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="         and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="         and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="         and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF

cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  02 - XXXX-  AAdd( aRegCli, { xFilial("DV1")+cCliDev+cLojDev+cDocTms+Space(Len(SB1->B1_COD)) }) */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIDEV"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJDEV"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      End"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
		   /*  03 - XXXXX  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+cCodPro }) */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = @IN_CCODPRO"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      End"+CRLF
cQuery+="      If @iRecno is null or @iRecno = 0 begin"+CRLF
   		/*  04 - XXXX-  AAdd( aRegCli, { xFilial("DV1")+cCliGen+cLojGen+cDocTms+Space(Len(SB1->B1_COD)) }) */
cQuery+="         Select @iRecno = R_E_C_N_O_, @cREGTRI = DV1_REGTRI"+CRLF
cQuery+="           From "+RetSqlName("DV1")+CRLF
cQuery+="          Where DV1_FILIAL = @IN_FILDV1"+CRLF
cQuery+="            and DV1_CODCLI = @IN_CCLIGEN"+CRLF
cQuery+="            and DV1_LOJCLI = @IN_CLOJGEN"+CRLF
cQuery+="            and DV1_DOCTMS = @IN_CDOCTMS"+CRLF
cQuery+="            and DV1_CODPRO = ' '"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF
cQuery+="      End"+CRLF
cQuery+="	End"+CRLF

cQuery+="   If @iRecno is null  select @OUT_RECNO  = 0   else select @OUT_RECNO = @iRecno"+CRLF
cQuery+="   If @cREGTRI is null select @OUT_REGTRI = ' ' else select @OUT_REGTRI = @cREGTRI"+CRLF
cQuery+="end"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery,nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query do TmsxProc04 nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		nRet := TcSqlExec(cQuery)
		If nRet != 0
			MsgAlert("Erro na criacao da procedure TmsxProc04 "+cProc)
			lRet:= .F.
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)
Return(lRet)
/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³TmsxProc5 -  Autor -                       -  Data :00.05.2012|
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	   Cria a procedure SCNNNNN04_EE (TMS010)  -> aProc[5] -> procedure - pai
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsxProc05(cProc, aProc, cArqTemp)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cProcNome := cProc+"_"+cEmpAnt
Local cQuery    := ''
Local aCampos   := DV1->(dbStruct())
Local aCampos1  := DUF->(dbStruct())
Local aCampos2  := DUG->(dbStruct())
Local aCampos3  := SF4->(dbStruct())
Local cTipo     := ''
Local nRet      := 0
Local nPos      := 0
Local nPTratRec	:= 0
Local nTamLinha := 0
Local cOperador := IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+") 

cQuery:="Create Procedure "+cProcNome+"("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_CODCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CCLIDEV     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_LOJCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CLOJDEV     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_DOCTMS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CDOCTMS     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_CODPRO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CCODPRO     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_TIPNFC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CTIPNFC     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_TIPCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CTIPCLI     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_SEQINS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CSEQINS     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_SEQINS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CVZSEQINS   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_TIPCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CVZTIPCLI   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_CODCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CCLIGEN     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_LOJCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CLOJGEN     "+cTipo+CRLF
nPos := Ascan( aCampos1, {|x| Alltrim(x[1]) == "DUF_TIPFRE" } )
cTipo := " Char( "+StrZero(aCampos1[nPos][3],3)+" ),"
cQuery+="   @IN_CTIPFRE     "+cTipo+CRLF
cQuery+="   @IN_LCONSIG     Char( 01 ),"+CRLF
cQuery+="   @IN_LCPOCONSIG  Char( 01 ),"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_CODPAS" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" ),"
cQuery+="   @IN_CCODPAS     "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTORI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" ),"
cQuery+="   @IN_CESTORI     "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTDEV" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" ),"
cQuery+="   @IN_CESTDEV     "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTDES" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" ),"
cQuery+="   @IN_CESTDES     "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_SATIV" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" ),"
cQuery+="   @IN_CATIVID     "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTVEI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" ),"
cQuery+="   @IN_CESTVEI     "+cTipo+CRLF
cQuery+="   @IN_NQTPARAM    integer,"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_TES" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="   @OUT_DUG_TES    "+cTipo+" OutPut,"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_CODMSG" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="   @OUT_DUG_CODMSG "+cTipo+" OutPut,"+CRLF
nPos := Ascan( aCampos3, {|x| Alltrim(x[1]) == "F4_ISS" } )
cTipo := " Char( "+StrZero(aCampos3[nPos][3],3)+" )"
cQuery+="   @OUT_F4_ISS     "+cTipo+" OUtput"+CRLF
cQuery+=" )"+CRLF
cQuery+="as"+CRLF
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Fonte Microsiga - <s>  TmsRegTrib </s>
    Descricao       - <d>  Retorna regra de Tributação </d>
    Funcao do Siga  -      TmsRegTrib()
    Entrada         - <ri> @IN_FILIAL      - Filial a ser processada
                           @IN_CCLIDEV     - Cliente
                           @IN_CLOJDEV     - Loja do cliente
                           @IN_CDOCTMS     - documento
                           @IN_CCODPRO     - codigo
                           @IN_CTIPNFC     - tipo nf
                           @IN_CTIPCLI     - tipo cliente
                           @IN_CSEQINS     -
                           @IN_CVZSEQINS   -
                           @IN_CVZTIPCLI   -
                           @IN_CCLIGEN     -
                           @IN_CLOJGEN     -
                           @IN_CTIPFRE     -
                           @IN_LCONSIG     - '1' se cosidera consignatario e '0' se não considera.
                           @IN_LCPOCONSIG  - '1' se nModulo == 43 .And. DUG->(FieldPos("DUG_CONSIG")) > 0, e '0' caso contrario
                           @IN_CCODPAS     -
                           @IN_CESTORI     -
                           @IN_CESTDEV     -
                           @IN_CESTDES     -
                           @IN_CATIVID     -
                           @IN_CESTVEI     -
                           @IN_NQTPARAM    - </ri>
    Saida           - <o>  @OUT_DUG_TES    -
                           @OUT_DUG_CODMSG -
                           @OUT_F4_ISS     - </ro>

    TMS010 - Retorna regra de Tributação
      +--> TMS011 - Retorna recno da regra de tributação valido
      +--> TMS012 - Percorre tmporario para procurar pela regra de trib
   -------------------------------------------------------------------------------------- */
cQuery+="declare @cAux           char(03)"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DV1_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="declare @cFilial_DV1    "+cTipo+CRLF
cQuery+="declare @cFilial_DUF    "+cTipo+CRLF
cQuery+="declare @cFilial_DUG    "+cTipo+CRLF
cQuery+="declare @cFilial_SF4    "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_REGTRI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cREGTRI        "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ITEM" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cMaxItem       "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_FILIAL    "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_REGTRI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_REGTRI    "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_TIPFRE" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_TIPFRE    "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ITEM" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ITEM      "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_TES" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_TES       "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_CODMSG" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_CODMSG    "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_CODPAS" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_CODPAS    "+cTipo+CRLF
nTamLinha := nTamLinha + aCampos2[nPos][3]
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTORI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTORI    "+cTipo+CRLF
nTamLinha := nTamLinha + aCampos2[nPos][3]
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTDEV" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTDEV    "+cTipo+CRLF
nTamLinha := nTamLinha + aCampos2[nPos][3]
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTDES" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTDES    "+cTipo+CRLF
nTamLinha := nTamLinha + aCampos2[nPos][3]
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_SATIV" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_SATIV     "+cTipo+CRLF
nTamLinha := nTamLinha + aCampos2[nPos][3]
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTVEI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTVEI    "+cTipo+CRLF
nTamLinha := nTamLinha + aCampos2[nPos][3]
cQuery+="declare @iDUG_ITEM1     integer"+CRLF
cQuery+="declare @iDUG_ITEM2     integer"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ITEM" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ITEMCOMP1 "+cTipo+CRLF
cQuery+="declare @cDUG_ITEMCOMP2 "+cTipo+CRLF
cTipo := " Char( "+StrZero(aCampos2[nPos][3]*2,3)+" )"
cQuery+="declare @cDUG_ITEMCO    char( 04 )"+CRLF  //-- @cDUG_ITEMCOMP1||@cDUG_ITEMCOMP2
nPos := Ascan( aCampos3, {|x| Alltrim(x[1]) == "F4_ISS" } )
cTipo := " Char( "+StrZero(aCampos3[nPos][3],3)+" )"
cQuery+="declare @cF4_ISS        "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_CONSIG" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_CONSIG    "+cTipo+CRLF
cTipo := " Char( "+StrZero(nTamLinha,3)+" )"
cQuery+="declare @cLinha         "+cTipo+CRLF  //   --@cDUG_CODPAS||@cDUG_ESTORI||@cDUG_ESTDEV||@cDUG_ESTDES||@cDUG_SATIV ->nTamLinha
nPos := Ascan( aCampos3, {|x| Alltrim(x[1]) == "F4_ISS" } )
cTipo := " Char( "+StrZero(aCampos3[nPos][3],3)+" )"
cQuery+="declare @cF4_ISSXX      "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_TES" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_TESXX     "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_CODMSG" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_CODMSGXX  "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_CODPAS" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_CODPASGR  "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTORI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTORIGR  "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTDEV" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTDEVGR  "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTDES" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTDESGR  "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_SATIV" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_SATIVGR   "+cTipo+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "DUG_ESTVEI" } )
cTipo := " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery+="declare @cDUG_ESTVEIGR  "+cTipo+CRLF
cQuery+="declare @iRecnoDV1      integer"+CRLF
cQuery+="declare @iRecnoDUF      integer"+CRLF
cQuery+="declare @iRecnoTemp     integer"+CRLF
cQuery+="declare @nCount         integer"+CRLF
cQuery+="declare @iTamItem       integer"+CRLF
cQuery+="declare @cDUFTipFre     char(1)"+CRLF
cQuery+="begin"+CRLF
   /*  ------------------------------------------------------------------------------------
       Tem os campos do array aBusca
       ------------------------------------------------------------------------------------ */
cQuery+="   select @OUT_DUG_TES    = ' '"+CRLF
cQuery+="   select @OUT_DUG_CODMSG = ' '"+CRLF
cQuery+="   select @OUT_F4_ISS     = ' '"+CRLF
cQuery+="   select @cREGTRI   = ' '"+CRLF
cQuery+="   select @cMaxItem  = ' '"+CRLF
cQuery+="   select @cLinha    = ' '"+CRLF
cQuery+="   select @iRecnoDV1 = 0"+CRLF
cQuery+="   select @iRecnoDUF = 0"+CRLF
cQuery+="   select @iRecnoTemp = 0"+CRLF
cQuery+="   select @nCount    = 0"+CRLF
cQuery+="   select @cDUG_CODPASGR = ' '"+CRLF
cQuery+="   select @cDUG_ESTORIGR = ' '"+CRLF
cQuery+="   select @cDUG_ESTDEVGR = ' '"+CRLF
cQuery+="   select @cDUG_ESTDESGR = ' '"+CRLF
cQuery+="   select @cDUG_SATIVGR  = ' '"+CRLF
cQuery+="   select @cDUG_ESTVEIGR = ' '"+CRLF
cQuery+="   select @cDUG_REGTRI   = ' '"+CRLF
cQuery+="   select @cDUG_TIPFRE   = ' '"+CRLF
cQuery+="   select @cDUG_ITEM     = ' '"+CRLF
cQuery+="   select @cDUG_TES      = ' '"+CRLF
cQuery+="   select @cDUG_CODMSG   = ' '"+CRLF
cQuery+="   select @cDUG_CODPAS   = ' '"+CRLF
cQuery+="   select @cDUG_ESTORI   = ' '"+CRLF
cQuery+="   select @cDUG_ESTDEV   = ' '"+CRLF
cQuery+="   select @cDUG_ESTDES   = ' '"+CRLF
cQuery+="   select @cDUG_SATIV    = ' '"+CRLF
cQuery+="   select @cDUG_ESTVEI   = ' '"+CRLF
cQuery+="   select @cDUG_CONSIG   = ' '"+CRLF

cQuery+="   select @cAux = 'DV1'"+CRLF
cQuery+="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFilial_DV1 OutPut"+CRLF
cQuery+="   select @cAux = 'DUF'"+CRLF
cQuery+="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFilial_DUF OutPut"+CRLF
cQuery+="   select @cAux = 'DUG'"+CRLF
cQuery+="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFilial_DUG OutPut"+CRLF
cQuery+="   select @cAux = 'SF4'"+CRLF
cQuery+="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFilial_SF4 OutPut"+CRLF
cQuery+="   delete from "+cArqTemp+CRLF  //ABUSCA
   /*  ------------------------------------------------------------------------------------
       Busca recno no DV1 Query no DV1
       ------------------------------------------------------------------------------------ */
cQuery+="   exec "+aProc[4]+" @cFilial_DV1,  @IN_CCLIDEV,   @IN_CLOJDEV, @IN_CDOCTMS, @IN_CCODPRO, @IN_CTIPNFC, @IN_CTIPCLI, @IN_CSEQINS,"+CRLF
cQuery+="                  @IN_CVZSEQINS, @IN_CVZTIPCLI, @IN_CCLIGEN, @IN_CLOJGEN, @cREGTRI OutPut, @iRecnoDV1 OutPut"+CRLF
   /*  ------------------------------------------------------------------------------------
       Busca recno no DUF
       ------------------------------------------------------------------------------------ */
cQuery+="   If @iRecnoDV1 != 0 and @cREGTRI != ' ' begin"+CRLF
cQuery+="      if @IN_CTIPFRE = '1' or @IN_CTIPFRE = '2' begin"+CRLF
cQuery+="         Select @iRecnoDUF = IsNull(R_E_C_N_O_, 0), @cDUFTipFre = DUF_TIPFRE"+CRLF
cQuery+="           From "+RetSqlName("DUF")+CRLF
cQuery+="          Where DUF_FILIAL = @cFilial_DUF"+CRLF
cQuery+="            and DUF_REGTRI = @cREGTRI"+CRLF
cQuery+="            and DUF_TIPFRE = @IN_CTIPFRE"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF

cQuery+="         If @iRecnoDUF = 0 begin"+CRLF
cQuery+="            Select @iRecnoDUF = IsNull(R_E_C_N_O_, 0), @cDUFTipFre = DUF_TIPFRE"+CRLF
cQuery+="              From "+RetSqlName("DUF")+CRLF
cQuery+="             Where DUF_FILIAL = @cFilial_DUF"+CRLF
cQuery+="               and DUF_REGTRI = @cREGTRI"+CRLF
cQuery+="               and DUF_TIPFRE = '3'"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF
cQuery+="         end"+CRLF

cQuery+="      end else begin"+CRLF
            /* -----------------------------------------------------
               Se não achar tipo de frete '1' ou '2'
               ----------------------------------------------------- */

cQuery+="         If @IN_CTIPFRE = ' ' or @IN_CTIPFRE = '3' begin"+CRLF
cQuery+="            Select @iRecnoDUF = IsNull(R_E_C_N_O_, 0), @cDUFTipFre = DUF_TIPFRE"+CRLF
cQuery+="              From "+RetSqlName("DUF")+CRLF
cQuery+="             Where DUF_FILIAL = @cFilial_DUF"+CRLF
cQuery+="               and DUF_REGTRI = @cREGTRI"+CRLF
cQuery+="               and DUF_TIPFRE = '3'"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF
cQuery+="         End"+CRLF
cQuery+="      End"+CRLF
      /*  ---------------------------------------
          Busca recno no DUF
			 Analisa a regra de tributacao
			 Se Encontrar na Regra algum componente cadastrado, analisa a regra para todos os componentes
			 do Frete, caso contrario, executara' a TMSRegTrib() uma unica vez, pois a regra de tributacao
			 sera' a mesma para todos os componentes.
          --------------------------------------- */
cQuery+="      If @iRecnoDUF != 0 begin"+CRLF
cQuery+="         Select @cMaxItem = IsNull(MAX(DUG_ITEM), ' ')"+CRLF
cQuery+="          From "+RetSqlname("DUG")+CRLF
cQuery+="         Where DUG_FILIAL = @cFilial_DUG"+CRLF
cQuery+="           and DUG_REGTRI = @cREGTRI"+CRLF
cQuery+="           and DUG_TIPFRE = @cDUFTipFre"+CRLF
cQuery+="           and D_E_L_E_T_ = ' ' "+CRLF

cQuery+="         select @cF4_ISSXX     = ' '"+CRLF
cQuery+="         Select @cDUG_TESXX    = ' '"+CRLF
cQuery+="         select @cDUG_CODMSGXX = ' '"+CRLF

cQuery+="         Declare CUR_TMS010 insensitive cursor for"+CRLF
cQuery+="  			Select DUG_FILIAL, DUG_REGTRI, DUG_TIPFRE, DUG_ITEM, DUG_TES, DUG_CODMSG, DUG_CODPAS, DUG_ESTORI,"+CRLF
cQuery+="                DUG_ESTDEV, DUG_ESTDES, DUG_SATIV"+CRLF
cQuery+=", DUG_ESTVEI"+CRLF
cQuery+="                ##FIELDP02( 'DUG.DUG_CONSIG' )"+CRLF
cQuery+="                  , DUG_CONSIG"+CRLF
cQuery+="                ##ENDFIELDP02"+CRLF
cQuery+="			  From "+RetSqlname("DUG")+CRLF
cQuery+="			 Where DUG_FILIAL = @cFilial_DUG"+CRLF
cQuery+="			   and DUG_REGTRI = @cREGTRI"+CRLF
cQuery+="              and DUG_TIPFRE = @cDUFTipFre"+CRLF
cQuery+="            ##FIELDP03( 'DUG.DUG_CONSIG' )"+CRLF
cQuery+="    		   and ( @IN_LCPOCONSIG = '1' and ((DUG_CONSIG IN ('1','3') and @IN_LCONSIG = '1') or "+CRLF
cQuery+="    		                                   (DUG_CONSIG IN ('2','3','') and @IN_LCONSIG = '0') or "+CRLF
cQuery+="    		                                   (DUG_CONSIG  = '1' and @IN_LCONSIG = '0')))"+CRLF
cQuery+="            ##ENDFIELDP03"+CRLF
cQuery+="			   and D_E_L_E_T_ = ' '"+CRLF
cQuery+="         order by DUG_FILIAL, DUG_REGTRI, DUG_TIPFRE, DUG_CODPAS, DUG_ESTORI, DUG_ESTDEV, DUG_ESTDES, DUG_SATIV"+CRLF
cQuery+=", DUG_ESTVEI"
cQuery+="                  ##FIELDP04( 'DUG.DUG_CONSIG' )"+CRLF
cQuery+="                  ,DUG_CONSIG"+CRLF
cQuery+="                  ##ENDFIELDP04"+CRLF
cQuery+="         for read only"+CRLF
cQuery+="         Open CUR_TMS010"+CRLF

cQuery+="         Fetch CUR_TMS010 into @cDUG_FILIAL, @cDUG_REGTRI, @cDUG_TIPFRE, @cDUG_ITEM, @cDUG_TES, @cDUG_CODMSG, @cDUG_CODPAS, @cDUG_ESTORI,"+CRLF
cQuery+="                               @cDUG_ESTDEV, @cDUG_ESTDES, @cDUG_SATIV"+CRLF
cQuery+=", @cDUG_ESTVEI"+CRLF
cQuery+="                               ##FIELDP05( 'DUG.DUG_CONSIG' )"+CRLF
cQuery+="                                 , @cDUG_CONSIG"+CRLF
cQuery+="                               ##ENDFIELDP05"+CRLF

cQuery+="         While (@@Fetch_status = 0 ) begin"+CRLF
cQuery+="            select @cLinha = @cDUG_CODPAS" + cOperador + "@cDUG_ESTORI" + cOperador + "@cDUG_ESTDEV" + cOperador + "@cDUG_ESTDES" + cOperador + "@cDUG_SATIV"+CRLF
cQuery+=			cOperador+"@cDUG_ESTVEI"+CRLF
                     /* -----------------------------------------------------------------------
                        Verifica se existe linhas no ABUSCA
                     ----------------------------------------------------------------------- */
cQuery+="            Select @iRecnoTemp = ISNULL(MIN( R_E_C_N_O_), 0)"+CRLF
cQuery+="              from "+cArqTemp+CRLF   //ABUSCA
cQuery+="             Where D_E_L_E_T_ = ' '"+CRLF

cQuery+="            If ( @cLinha = ' ' and @iRecnoTemp = 0 ) begin"+CRLF
                        /* ---------------------------------------------------------------------------------
                           array aRetorno -> carrego nas variáveis @cDUG_TESXX, @cDUG_CODMSGXX, @cF4_ISSXX
                        --------------------------------------------------------------------------------- */
cQuery+="               select @cF4_ISSXX = Isnull(F4_ISS, ' ')"+CRLF
cQuery+="                 From "+REtSqlName("SF4")+CRLF
cQuery+="                Where F4_FILIAL = @cFilial_SF4"+CRLF
cQuery+="                  and F4_CODIGO = @cDUG_TES"+CRLF
cQuery+="                  and D_E_L_E_T_ = ' '"+CRLF

cQuery+="               Select @cDUG_TESXX    = @cDUG_TES"+CRLF
cQuery+="               select @cDUG_CODMSGXX = @cDUG_CODMSG"+CRLF
cQuery+="            end"+CRLF

cQuery+="            If @cDUG_CODPAS = @IN_CCODPAS and @cDUG_ESTORI = @IN_CESTORI and @cDUG_ESTDEV = @IN_CESTDEV and"+CRLF
cQuery+="               @cDUG_ESTDES = @IN_CESTDES and @cDUG_SATIV  = @IN_CATIVID "
cQuery+="           and @cDUG_ESTVEI = @IN_CESTVEI"
cQuery+=" begin"+CRLF
cQuery+="               select @cLinha = ' '"+CRLF
cQuery+="            End"+CRLF

cQuery+="			select @nCount = 0"+CRLF
cQuery+="			If @cLinha != ' ' begin"+CRLF

cQuery+="               If @cDUG_CODPAS = @IN_CCODPAS select @nCount = 1"+CRLF
cQuery+="               If @cDUG_ESTORI = @IN_CESTORI select @nCount = @nCount + 1"+CRLF
cQuery+="               If @cDUG_ESTDEV = @IN_CESTDEV select @nCount = @nCount + 1"+CRLF
cQuery+="               If @cDUG_ESTDES = @IN_CESTDES select @nCount = @nCount + 1"+CRLF
cQuery+="               If @cDUG_SATIV  = @IN_CATIVID select @nCount = @nCount + 1"+CRLF
cQuery+="           If @cDUG_ESTVEI = @IN_CESTVEI select @nCount = @nCount + 1"+CRLF
cQuery+="				If @nCount = @IN_NQTPARAM begin"+CRLF

cQuery+="                  select @cF4_ISSXX     = ' '"+CRLF
cQuery+="                  Select @cDUG_TESXX    = ' '"+CRLF
cQuery+="                  select @cDUG_CODMSGXX = ' '"+CRLF

cQuery+="                  delete from "+cArqTemp+CRLF  //ABUSCA

cQuery+="                  select @cF4_ISSXX = IsNull(F4_ISS, ' ')"+CRLF
cQuery+="                    From "+RetSqlName("SF4")+CRLF
cQuery+="                   Where F4_FILIAL = @cFilial_SF4"+CRLF
cQuery+="                     and F4_CODIGO = @cDUG_TES"+CRLF
cQuery+="                     and D_E_L_E_T_ = ' '"+CRLF

cQuery+="                  Select @cDUG_TESXX    = @cDUG_TES"+CRLF
cQuery+="                  select @cDUG_CODMSGXX = @cDUG_CODMSG"+CRLF
					    /* ----------------------------------------------------------------------------
					      Caso seja(m) encontrado(s) outra(s) possivel combinacao qualquer,
					      "zerar" o vetor aretorno e adicionar ao vetor todas as possiveis combinacoes
					      ---------------------------------------------------------------------------- */
cQuery+="				end else begin"+CRLF
                        /* ----------------------------------------------------------------------------------------
                           @cLinha = '' -> vazio  Zero aRetorno @cF4_ISSXX ,@cDUG_TESXX    = '',@cDUG_CODMSGXX = ''
                         ---------------------------------------------------------------------------------------- */
cQuery+="                  select @cF4_ISSXX     = ' '"+CRLF
cQuery+="                  Select @cDUG_TESXX    = ' '"+CRLF
cQuery+="                  select @cDUG_CODMSGXX = ' '"+CRLF

cQuery+="                  select @iDUG_ITEM1  = Convert( integer, @cDUG_ITEM )"+CRLF
cQuery+="                  select @iDUG_ITEM2  = Convert( integer, @cMaxItem ) - @iDUG_ITEM1"+CRLF

cQuery+="                  select @iTamItem  = Len(@cDUG_ITEM)"+CRLF
cQuery+="                  select @cDUG_ITEMCOMP1 = ' '"+CRLF
cQuery+="                  select @cDUG_ITEMCOMP2 = ' '"+CRLF
cQuery+="                  exec "+aProc[2]+" @nCount,     @iTamItem, @cDUG_ITEMCOMP1 OutPut"+CRLF  //msstrzero
cQuery+="                  exec "+aProc[2]+" @iDUG_ITEM2, @iTamItem, @cDUG_ITEMCOMP2 OutPut"+CRLF
cQuery+="                  select @cDUG_ITEMCO  = @cDUG_ITEMCOMP1" + cOperador + "@cDUG_ITEMCOMP2"+CRLF

cQuery+="                  select @cDUG_CODPASGR = @cDUG_CODPAS"+CRLF
cQuery+="                  select @cDUG_ESTORIGR = @cDUG_ESTORI"+CRLF
cQuery+="                  select @cDUG_ESTDEVGR = @cDUG_ESTDEV"+CRLF
cQuery+="                  select @cDUG_ESTDESGR = @cDUG_ESTDES"+CRLF
cQuery+="                  select @cDUG_SATIVGR  = @cDUG_SATIV" +CRLF
cQuery+="              select @cDUG_ESTVEIGR = @cDUG_ESTVEI"+CRLF
cQuery+="                  If @cDUG_CODPAS != ' ' select @cDUG_CODPASGR = @IN_CCODPAS"+CRLF
cQuery+="                  If @cDUG_ESTORI != ' ' select @cDUG_ESTORIGR = @IN_CESTORI"+CRLF
cQuery+="                  If @cDUG_ESTDEV != ' ' select @cDUG_ESTDEVGR = @IN_CESTDEV"+CRLF
cQuery+="                  If @cDUG_ESTDES != ' ' select @cDUG_ESTDESGR = @IN_CESTDES"+CRLF
cQuery+="                  If @cDUG_SATIV  != ' ' select @cDUG_SATIVGR  = @IN_CATIVID"+CRLF
cQuery+="              If @cDUG_ESTVEI != ' ' select @cDUG_ESTVEIGR = @IN_CESTVEI"+CRLF
cQuery+="                  Select @iRecnoTemp = IsNull(Max( R_E_C_N_O_), 0) from "+cArqTemp+CRLF  //ABUSCA
cQuery+="                  Select @iRecnoTemp = @iRecnoTemp + 1"+CRLF

cQuery+="                  begin tran"+CRLF
cQuery+="                  insert into "+cArqTemp+"( DUG_REGTRI,   DUG_TIPFRE,   DUG_CODPAS,     DUG_ESTORI,     DUG_ESTDEV,     DUG_ESTDES,    DUG_SATIV,"+CRLF   //ABUSCA
cQuery+="DUG_ESTVEI, "
cQuery+="                                      DUG_ITEM1,    DUG_ITEM2,    NCOUNT,         DUG_ITEMCO,   R_E_C_N_O_ )"+CRLF
cQuery+="                              values( @cDUG_REGTRI, @cDUG_TIPFRE, @cDUG_CODPASGR, @cDUG_ESTORIGR, @cDUG_ESTDEVGR, @cDUG_ESTDESGR, @cDUG_SATIVGR,"+CRLF
cQuery+=" @cDUG_ESTVEIGR,"+CRLF
cQuery+="                                      @iDUG_ITEM1,  @iDUG_ITEM2,  @nCount,        @cDUG_ITEMCO, @iRecnoTemp )"+CRLF
cQuery+="                  Commit Tran"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="            If @nCount = @IN_NQTPARAM 	break"+CRLF

cQuery+="            Fetch CUR_TMS010 into @cDUG_FILIAL, @cDUG_REGTRI, @cDUG_TIPFRE, @cDUG_ITEM, @cDUG_TES, @cDUG_CODMSG, @cDUG_CODPAS, @cDUG_ESTORI,"+CRLF
cQuery+="                                  @cDUG_ESTDEV, @cDUG_ESTDES, @cDUG_SATIV"+CRLF
cQuery+=", @cDUG_ESTVEIGR "+CRLF
cQuery+="                                     ##FIELDP06( 'DUG.DUG_CONSIG' )"+CRLF
cQuery+="                                       , @cDUG_CONSIG"+CRLF
cQuery+="                                     ##ENDFIELDP06"+CRLF
cQuery+="            select @cLinha = ' '"+CRLF
cQuery+="            select @nCount = 0"+CRLF
cQuery+="         End"+CRLF
cQuery+="         close CUR_TMS010"+CRLF
cQuery+="         deallocate CUR_TMS010"+CRLF
                     /* -------------------------------------------------------------------------------------------
                     SE nâo tiver nada no aretorno ->@cF4_ISSXX = '' and @cDUG_TESXX = '' and @cDUG_CODMSGXX = ''
                     --------------------------------------------------------------------------------------------- */
cQuery+="         If @cF4_ISSXX = ' ' and @cDUG_TESXX = ' ' and @cDUG_CODMSGXX = ' ' begin"+CRLF
                     /* -------------------------------------------------------------------------------------------
		     		   adicionar ao vetor uma linha com todos os elementos em branco para os casos em que todas as
			    	   combinacoes existentes no vetor abusca nao atendam as combinacoes, sera definida como a TES
				       de retorno pela rotina tmsaregra, cuja t.e.s tiver cadastrada com todos os campos em branco
                     ------------------------------------------------------------------------------------------- */

cQuery+="			 select @cDUG_CODPASGR = ' ', @cDUG_ESTORIGR = ' ', @cDUG_ESTDEVGR = ' '"+CRLF
cQuery+="			 select @cDUG_ESTDESGR = ' ', @cDUG_SATIVGR  = ' ', @cDUG_ITEMCO = '0000'"+CRLF
cQuery+=", @cDUG_ESTVEIGR = ' '"+CRLF
cQuery+="            select @iDUG_ITEM1 = 0,    @iDUG_ITEM2 = 0,  @nCount = 0"+CRLF

cQuery+="            Select @iRecnoTemp = IsNull(Max( R_E_C_N_O_), 0) from "+cArqTemp+CRLF  //ABUSCA
cQuery+="            Select @iRecnoTemp = @iRecnoTemp + 1"+CRLF
cQuery+="            begin tran"+CRLF
cQuery+="            insert into "+cArqTemp+"( DUG_REGTRI,   DUG_TIPFRE,   DUG_CODPAS,     DUG_ESTORI,      DUG_ESTDEV,     DUG_ESTDES,     DUG_SATIV,"+CRLF  //ABUSCA
cQuery+="DUG_ESTVEI,  "
cQuery+="                                DUG_ITEM1,    DUG_ITEM2,    NCOUNT,         DUG_ITEMCO,    R_E_C_N_O_ )"+CRLF
cQuery+="                        values( @cDUG_REGTRI, @cDUG_TIPFRE, @cDUG_CODPASGR, @cDUG_ESTORIGR,  @cDUG_ESTDEVGR, @cDUG_ESTDESGR, @cDUG_SATIVGR,"+CRLF
cQuery+="@cDUG_ESTVEIGR,  "
cQuery+="                                @iDUG_ITEM1,  @iDUG_ITEM2,  @nCount,        @cDUG_ITEMCO,  @iRecnoTemp )"+CRLF
cQuery+="            commit tran"+CRLF
			         /* -----------------------------------------------------------------------------
			            Busca codigo do tes e da mensagem fiscal
			            TmsaRegra(cRegTri,cTipFre,cCodPas,cEstOri,cEstDev,cEstDes,cAtividade,lConsig)
     			      ----------------------------------------------------------------------------- */
cQuery+="			 Exec "+aProc[3]+" @IN_FILIAL,  @cDUG_REGTRI, @cDUG_TIPFRE, @IN_LCONSIG, @IN_LCPOCONSIG, "+CRLF
cQuery+="			                  @cDUG_TESXX OutPut, @cDUG_CODMSGXX OutPut, @cF4_ISSXX OUtput"+CRLF
cQuery+="         End"+CRLF
cQuery+="      End"+CRLF
cQuery+="   End"+CRLF
cQuery+="   If @cDUG_TESXX    is null or @cDUG_TESXX = ''    select @OUT_DUG_TES    = ' ' else select @OUT_DUG_TES    = @cDUG_TESXX"+CRLF
cQuery+="   If @cDUG_CODMSGXX is null or @cDUG_CODMSGXX = '' select @OUT_DUG_CODMSG = ' ' else select @OUT_DUG_CODMSG = @cDUG_CODMSGXX"+CRLF
cQuery+="   If @cF4_ISSXX     is null or @cF4_ISSXX = ''     select @OUT_F4_ISS     = ' ' else select @OUT_F4_ISS     = @cF4_ISSXX"+CRLF
cQuery+="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery,nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query do TmsxProc05 nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		nRet := TcSqlExec(cQuery)
		If nRet != 0
			MsgAlert("Erro na criacao da procedure TmsxProc05 "+cProc)
			lRet:= .F.
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)
Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³TMSDelProc  ³ Autor ³                     ³ Data             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusão de procedures dinamicas criadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSDelProc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aProc - Array com as procedures a serem excluídas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsDelDin()
Local iX    := 1
Local cExec := ""
Local nRet  := 0
Local lRet1  := .T.

If aTempProc != NIL
	For iX = 1 to Len(aTempProc[3])   // exclusao de procedure
		If TCSPExist(aTempProc[3][iX])
			cExec := "Drop procedure "+aTempProc[3][iX]
			nRet := TcSqlExec(cExec)
			If nRet != 0
				MsgAlert("Erro na exclusao da Procedure: "+aTempProc[3][iX] +". Excluir manualmente no banco")
			Endif
		EndIf
	Next iX
	If TcCanOpen(aTempProc[4])   // exclusao de arq temporario
		lRet1 := TcDelFile(aTempProc[4])
		If !lRet1
			MsgAlert("Erro na exclusao da Tabela: "+aProcOK[4]+". Excluir manualmente")
		Endif
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsCriaProc       ºAutor ³                º Data ³   /05/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria procedures dinamicas                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsCriaProc()
Local lProcedure:= If(Alltrim(Upper(TcGetDb())) $ "MSSQL|MSSQL7|ORACLE", .T., .F.)
Local lProcTMS		:= GetMV('MV_PROCTMS',,.T.)

If lProcTMS
	If lProcedure
		If aTempProc == NIL
			TMSLogMsg(,"Inicio Cria: "+Time())
			aTempProc := TmsRegProc()
			lTempProc := .T.
			TMSLogMsg(,"Termino Cria: "+Time())
			TMSLogMsg(,aTempProc[4])
		EndIf
	EndIf
EndIf

Return

Function TmsDelProc()
Local lProcTMS		:= GetMV('MV_PROCTMS',,.T.)

If lProcTMS
	If aTempProc != NIL
		TMSLogMsg(,"Excluindo Inicio: "+Time())
		TmsDelDin()
		TMSLogMsg(,"Excluindo Final: "+Time())
		aTempProc := NIL
		lTempProc := .F.
	EndIf
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TmsConsig ³ Autor ³Katia                  ³ Data ³03.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o Cliente/Loja possui cadastro no Consignatario ³±±
±±³          ³considerando a Abrangencia do Remetente e Destinatario      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cliente Rem., Loja Rem., Cliente Dest., Loja Dest.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSConsig(cCliRem,cLojRem,cCliDes,cLojDes,aRet,lInvertid)

Local   cQuery    := ""
Local   cAliasDTI := ""
Local   aGetArea  := GetArea()
Local   cDTIRecno := ""
Local   lRet      := .T.

Default cCliRem   := ""
Default cLojRem   := ""
Default cCliDes   := ""
Default cLojDes   := ""
Default lInvertid := .F.

If (Empty(cCliRem+cLojRem)) .Or. (Empty(cCliDes+cLojDes)) .Or. (lInvertid .And. DTI->(ColumnPos("DTI_INVPSQ")) == 0 )
	lRet:= .F.
EndIf

If lRet
	//-- Pesquisa pelo Codigo+Loja
	cAliasDTI := GetNextAlias()
	cQuery := "SELECT DTI_CLIREM, DTI_LOJREM, DTI_CLIDES, DTI_LOJDES, DTI.R_E_C_N_O_ RECNODTI"
	cQuery += " FROM "+RetSqlName("DTI")+ " DTI "
	cQuery += " WHERE DTI_FILIAL = '"+xFilial("DTI")+"'"
	cQuery += "   AND DTI_CLIREM = '"+cCliRem+"'"
	cQuery += "   AND DTI_LOJREM = '"+cLojRem+"'"
	cQuery += "   AND DTI_CLIDES = '"+cCliDes+"'"
	cQuery += "   AND DTI_LOJDES = '"+cLojDes+"'"
	If lInvertid
		cQuery += "   AND DTI_INVPSQ = '1'"
	EndIf
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTI, .F., .T.)
	If (cAliasDTI)->(Eof())
		lRet:= .F.
		//-- Nao encontrou o consignatario, procura pela Abrangencia
		(cAliasDTI)->(DbCloseArea())

		cQuery := "SELECT DTI_CLIREM, DTI_LOJREM, DTI_ABRREM, DTI_CLIDES, DTI_LOJDES, DTI_ABRDES, DTI.R_E_C_N_O_ RECNODTI"
		cQuery += " FROM "+RetSqlName("DTI")+ " DTI "
		cQuery += " WHERE DTI_FILIAL = '"+xFilial("DTI")+"'"
		cQuery += "   AND DTI_CLIREM = '"+cCliRem+"'"
		cQuery += "   AND DTI_CLIDES = '"+cCliDes+"'"
		If lInvertid
			cQuery += "   AND DTI_INVPSQ = '1'"
		EndIf
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += "   ORDER BY DTI_ABRREM, DTI_LOJREM, DTI_ABRDES, DTI_LOJDES "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTI, .F., .T.)
		While (cAliasDTI)->( !Eof() )
			If (cAliasDTI)->DTI_ABRREM == '2'   //Cliente
				If (cAliasDTI)->DTI_ABRDES <> '2'    //Destinatario Cliente+Loja
					If (cAliasDTI)->DTI_LOJDES == cLojDes
						lRet:= .T.
						Exit
					EndIf
				Else
					lRet:= .T.
					Exit
				EndIf
			Else
				If (cAliasDTI)->DTI_LOJREM == cLojRem
					If (cAliasDTI)->DTI_ABRDES <> '2'    //Destinatario Cliente+Loja
						If (cAliasDTI)->DTI_LOJDES == cLojDes
							lRet:= .T.
							Exit
						EndIf
					Else
						lRet:= .T.
						Exit
					EndIf
				EndIf
			EndIf
		   	(cAliasDTI)->( DbSkip() )
		EndDo

	   	If lRet
		   	cDTIRecno:= (cAliasDTI)->RECNODTI
		EndIf

		(cAliasDTI)->( DbCloseArea() )
	Else
		lRet:= .T.
	   	cDTIRecno:= (cAliasDTI)->RECNODTI
	   	(cAliasDTI)->(DbCloseArea())
	EndIf
EndIf
RestArea(aGetArea)

If lRet
	DTI->(dbGoTo(cDTIRecno)	)   //Posiciona no registro DTI
	If aRet <> Nil
		aRet := {DTI->DTI_CALFRE,; //-- [01] DTI_CALFRE "Calcula Frete"
				DTI->DTI_TIPFRE,;  //-- [02] DTI_TIPFRE "Tipo de Frete"
				DTI->DTI_CALPRZ,;  //-- [03] DTI_CALPRZ "Calcula Prazo"
				DTI->DTI_TIPPER }  //-- [04] DTI_TIPPER "Tipo Perfil"
		
		//-- Se localizou o registro, mediante à inversão da chamada, invertem-se os conteúdos dos campos
		If lInvertid
			aRet[01] := Iif(DTI->DTI_CALFRE == "1","2", Iif(DTI->DTI_CALFRE == "2","1",DTI->DTI_CALFRE))  //-- [01] DTI_CALFRE "Calcula Frete"
			aRet[02] := Iif(DTI->DTI_TIPFRE == "1","2", Iif(DTI->DTI_TIPFRE == "2","1",DTI->DTI_TIPFRE))  //-- [02] DTI_TIPFRE "Tipo de Frete"
			aRet[03] := Iif(DTI->DTI_CALPRZ == "1","2", Iif(DTI->DTI_CALPRZ == "2","1",DTI->DTI_CALPRZ))  //-- [03] DTI_CALPRZ "Calcula Prazo"
			aRet[04] := Iif(DTI->DTI_TIPPER == "1","2", Iif(DTI->DTI_TIPPER == "2","1",DTI->DTI_TIPPER))  //-- [04] DTI_TIPPER "Tipo Perfil"
		EndIf
	EndIf
//-- Se ainda não tentou a busca invertida, chama a função, invertendo os devedores
ElseIf !lInvertid .And. aRet <> Nil
	lRet := TMSConsig(cCliDes,cLojDes,cCliRem,cLojRem,@aRet,.T.)
EndIf

Return lRet
//=================================================================
/* Visualiza o carregamento grafico a partir da viagem selecionada
@author  	Leandro Paulino
@version 	P11 R11.80
@build		700120420A
@since 	09/06/2015
@return 	NIL */
//=================================================================

Static Function TmsVisCGrf(cFilOri,cViagem)

Local aAreaDDK := DDK->(GetArea())

Private N:= 1

Default cFilOri := ''
Default cViagem := ''


DDK->(dbSetOrder(1))
If DDK->(MsSeek(xfilial('DDK')+cFilOri+cViagem))
	FWExecView(STR0154,'VIEWDEF.TMSA215',MODEL_OPERATION_VIEW,, { || .T. },{ || .T. },,,{ || .T. })  // "Carregar"
EndIf

RestArea(aAreaDDK)

Return Nil
//------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsCmpInf
Esta função verifica se a tabela de frete, retornada no array aContrato
contém um ou mais componentes de frete cujo tipo é "Valor informado".

@param   cTabela - Código da tabela de frete contida na 1a posição do array aContrato
@param   cTipTab - Tipo da tabela de frete contida na 1a posição do array aContrato

@return  lRet    - Retorna .T. caso a tabela contenha ao menos 1 componente de frete
                   tipo é "Valor informado", e .F. caso não contenha.
@author  Aluizio Fernando Habizenreuter
@since   12/05/2016
@version MP12
/*/
//------------------------------------------------------------------------------------
Function TmsCmpInf(cTabela,cTipTab)

Local lRet      := .F.
Local cQuery,cAliasNew

	cAliasNew := GetNextAlias()
	cQuery := " SELECT COUNT(DT1_FILIAL) CNT "
	cQuery += " FROM " + RetSqlName("DT1") + "," + RetSqlName("DT3")
	cQuery += "   WHERE DT1_FILIAL = '" + xFilial("DT1") + "' "
	cQuery += "     AND DT1_TABFRE = '" + cTabela + "' "
	cQuery += "     AND DT1_TIPTAB = '" + cTipTab + "' "
	cQuery += "     AND " + RetSqlName("DT1") + ".D_E_L_E_T_ = ' ' "
	cQuery += "     AND DT3_FILIAL = DT1_FILIAL "
	cQuery += "     AND DT3_CODPAS = DT1_CODPAS "
	cQuery += "     AND DT3_TIPFAI = '07' "
	cQuery += "     AND " + RetSqlName("DT3") + ".D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
	If (cAliasNew)->CNT > 0
		lRet := .T.
	EndIf
	(cAliasNew)->(DbCloseArea())

Return( lRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSPesqNeg
Pesquisa as negociações ativas no contrato do cliente
Função utilizada para uma consulta especifica, DDB1, sendo chamada nos campos DF1, DTC, DT4 e DT5_CODNEG
@type function
@author Gianni Furlan
@version 12
@since 04/02/2016
@param [cCampo], Caracter, Campo
@return lRet True ou False
@obs Alterado por Guilherme Eduardo Bittencourt em 22/05/2017 (Reestruturação)
/*/
//-------------------------------------------------------------------------------------------------
Function TMSPesqNeg(cCampo)

	Local aArea     := GetArea()
	Local aItensNeg	:= {}
	Local aButtons  := {}
	Local bConfir   := {|| }
	Local bCancel   := {|| }
	Local lRet      := .T.
	Local cQuery    := ""
	Local cAliasQry := ""
	Local cCodNeg   := ""
	Local cDesNeg   := ""
	Local nContrat  := ""
	Local cCliDev   := ""
	Local cLojDev   := ""
	Local oPnlModal, oFWLayer, oPnlObj, oDlgNeg, oBrowse, oColumn
	Local oModel, oView

	Default cCampo := ""

	If Empty(cCampo)
		cCampo := ReadVar()
	EndIf

	Do Case
	//-- Entrada da nota
	Case cCampo == "M->DTC_CODNEG"
		If ! Empty(M->DTC_NCONTR)
			nContrat := M->DTC_NCONTR
		Else
			aContrat := TMSContrat(M->DTC_CLIDEV, M->DTC_LOJDEV, , ,.F., M->DTC_TIPFRE,,,,,,,,,,,,,,,,M->DTC_CODNEG)
			nContrat := aContrat[1,1]
		EndIf

	//-- Cotação de frete
	Case cCampo == "M->DT4_CODNEG"
		TMSA040Cli(@cCliDev,@cLojDev)
		aContrat := TMSContrat(cCliDev, cLojDev, , ,.F., M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG)
		If !Empty(aContrat)
			nContrat := aContrat[1,1]
		Endif
		//-- Solicitação de coleta
	Case cCampo == "M->DT5_CODNEG"
		nContrat := M->DT5_NCONTR
		//-- Agendamento
	Case cCampo == "M->DF1_CODNEG"
		nContrat := GDFieldGet("DF1_NCONTR")
		//-- CRT - Conhecimento Internacional
	Case cCampo == "M->DIK_CODNEG"
		aContrat := TMSContrat( M->DIK_CLIDEV, M->DIK_LOJDEV,, M->DIK_SERVIC,, M->DIK_TIPFRE,,,,,,,,,,,,,,,,M->DIK_CODNEG)
		If !Empty(aContrat)
			nContrat := aContrat[1,1]
		Endif
		//-- Ajustes de Tabela
	Case cCampo == "M->DVC_CODNEG"
		aContrat := TMSContrat( M->DVC_CODCLI, M->DVC_LOJCLI,, M->DVC_SERVIC,, M->DVC_TIPFRE,,M->DVC_VIGCON,,,,,,,,,,,,,,M->DIK_CODNEG)
		If !Empty(aContrat)
			nContrat := aContrat[1,1]
		Endif
		//-- Contrato de cliente
	Case cCampo == "M->DDD_CODNEG"
		If !Empty(M->DDD_NCONTR)
			nContrat := M->DDD_NCONTR
		Else
			aContrat := TMSContrat( M->DDD_CLICAL, M->DDD_LOJCAL,, M->DDD_SERVIC,, M->DDD_TIPFRE,,,,,,,,,,,,,,,,M->DDD_CODNEG)
			If !Empty(aContrat)
				nContrat := aContrat[1,1]
				If IsInCallStack("TMSA019") .Or. IsInCallStack("TMSA019A")
					oModel := FWModelActive()	//-- Captura Model Ativa
					oView  := FWViewActive()	//-- Captura View Ativa
					If oModel:cSource == "TMSA019A"
						oModel:SetValue( 'TMSA019A_CAB' , 'DDD_NCONTR' , aContrat[1,1] )
						oView:Refresh('TMSA019A_CAB')
					EndIf
				EndIf
			Endif
		EndIf

	//-- 2016-07-01 : tiago.dsantos
	//-- Para busca do Cod.de Negociação pela tela de Pagadores do Frete
	//-- disparado pelo campo DDC_CODNEG que chama a consulta Padrão DDB
	Case cCampo == "M->DDC_CODNEG" .And. FunName() <> "TECA250"
		nContrat := GDFieldGet("AAM_CONTRT", n)
		//Contrato de Demandas
	Case cCampo == "M->DL7_CODNEG"
		If !Empty(M->DL7_CRTCLI)
			nContrat := M->DL7_CRTCLI
		EndIf
	Case cCampo == "M->DL8_CODNEG"
		If !Empty(M->DL8_CRTCLI)
			nContrat := M->DL8_CRTCLI
		EndIf
	EndCase

	cAliasQry := GetNextAlias()
	cQuery    := ""

	If FunName() <> "TECA250"

		cQuery += " SELECT DDB_CODNEG, DDB_DESCRI "
		cQuery += "   FROM "      + RetSqlName("DDB") + " DDB "
		cQuery += "  INNER JOIN " + RetSqlName("DDC") + " DDC "
		cQuery += "     ON DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
		cQuery += "    AND DDB.DDB_CODNEG = DDC.DDC_CODNEG "
		cQuery += "    AND DDB.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE DDC.DDC_FILIAL = '" + xFilial("DDC") + "' "
		cQuery += "    AND DDC.DDC_NCONTR = '" + nContrat + "' "
		cQuery += "    AND ( DDC.DDC_FIMVIG = ' ' OR DDC.DDC_FIMVIG >= '" + DtoS(Date()) + "')"
		cQuery += "    AND DDC.D_E_L_E_T_ = ' ' "

	Else

		cQuery += " SELECT DDB_CODNEG, DDB_DESCRI "
		cQuery += "   FROM " + RetSqlName("DDB") + " DDB "
		cQuery += "  WHERE DDB.DDB_FILIAL = '" + xFilial("DDB") + "' "
		cQuery += "    AND DDB.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	While (cAliasQry)->(!Eof())
		AAdd(aItensNeg, {(cAliasQry)->DDB_CODNEG,;
		                 (cAliasQry)->DDB_DESCRI})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If Len(aItensNeg) > 0

		oDlgNeg := FWDialogModal():New()
		oDlgNeg:SetBackground(.F.)
		oDlgNeg:SetTitle(STR0155) //STR0155 'Negociações por Cliente'
		oDlgNeg:SetEscClose(.T.)
		oDlgNeg:SetSize(150, 250)
		oDlgNeg:CreateDialog()

		oPnlModal := oDlgNeg:GetPanelMain()

		oFWLayer := FWLayer():New() //-- Container
		oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container

		oFWLayer:AddLine('LIN', 100, .F.) //-- Linha
		oFWLayer:AddCollumn('COL', 100, .F., 'LIN') //-- Coluna

		oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')

		bConfir := {|| cCodNeg:= aItensNeg[oBrowse:At(), 1],;
		               cDesNeg:= aItensNeg[oBrowse:At(), 2],;
					   oDlgNeg:DeActivate(),;
					   lRet    := .T.}

		bCancel := {|| cCodNeg := "",;
		               cDesNeg := "",;
					   oDlgNeg:DeActivate(),;
					   lRet    := .F.}

		oBrowse := FWBrowse():New()
		oBrowse:SetOwner(oPnlObj)
		oBrowse:SetDescription(STR0155) //STR0155 'Negociações por Cliente'
		oBrowse:SetDataArray()
		oBrowse:DisableFilter()
		oBrowse:DisableConfig()
		oBrowse:DisableReport()
		oBrowse:SetArray(aItensNeg)
		oBrowse:SetDoubleClick(bConfir)

		oColumn := FWBrwColumn():New()
		oColumn:SetData({|| aItensNeg[oBrowse:At(), 1]})
		oColumn:SetTitle(STR0149) //STR0149 "Código"
		oBrowse:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({|| aItensNeg[oBrowse:At(), 2]})
		oColumn:SetTitle(STR0035) //STR0035 "Descrição"
		oBrowse:SetColumns({oColumn})

		oBrowse:Activate() //-- Ativação do Browse

		//-- Cria botoes de operacao
		Aadd(aButtons, {"", STR0024, bConfir, , , .T., .F.}) //STR0024 'Confirmar'
		Aadd(aButtons, {"", STR0164, bCancel, , , .T., .F.}) //STR0164 'Cancelar'
		oDlgNeg:AddButtons(aButtons)

		oDlgNeg:Activate()

	Else
		Help("", 1, "TMSXFUNB48") //-- Não existem negociações ativas para este cliente.
	Endif

	VAR_IXB := cCodNeg

	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsPesqRat ³ Autor ³ Katia             ³ Data ³ 29.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para validar campos de Criterio Rateio (DDA e DDC)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsPesqRat(cEpx01,cExp02....cExp09 )							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ cExp01 = Base de Rateio                                    ³±±
±±³          ³ cExp02 = Criterio de Rateio                                ³±±
±±³          ³ cExp03 = Criterio de Calculo de Rateio                     ³±±
±±³          ³ cExp04 = Base de Rateio DDA                                ³±±
±±³          ³ cExp05 = Criterio de Rateio DDA                            ³±±
±±³          ³ cExp06 = Criterio de Calculo de Rateio DDA                 ³±±
±±³          ³ cExp07 = Base de Rateio DDC                                ³±±
±±³          ³ cExp08 = Criterio de Rateio DDC                            ³±±
±±³          ³ cExp09 = Criterio de Calculo de Rateio DDC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsPesqRat(cBACRAT,cCRIRAT,cPRORAT,cBAC_DDA,cCRI_DDA,cPRO_DDA,cBAC_DDC,cCRI_DDC,cPRO_DDC)
Local lRet         := .F.
Local lTabDDA      := .T.

Default cBACRAT  := ""
Default cCRIRAT  := ""
Default cPRORAT  := ""
Default cBAC_DDA := ""
Default cCRI_DDA  := ""
Default cPRO_DDA  := ""
Default cBAC_DDC  := ""
Default cCRI_DDC  := ""
Default cPRO_DDC  := ""

//--- BACRAT, primeiro verifica conteudo do campo na Tabela DDA e caso nao atenda verifica na Tabela DDC.
If !Empty(cBACRAT)
	lRet:= cBAC_DDA == cBACRAT
	If !lRet
		If cBAC_DDA == '1' .Or. cBAC_DDA == ""
			lRet:= cBAC_DDC == cBACRAT
			If lRet
				lTabDDA:= .F.
			EndIf
		EndIf
	EndIf
Else
	 lRet:= cBAC_DDA <> '1' .And. cBAC_DDA <> ''
	 If !lRet
	 	lRet:= cBAC_DDC <> '1' .And. cBAC_DDC <> ''
	 	If lRet
	 		lTabDDA:= .F.
	 	EndIf
	 EndIf
EndIf

If lRet
	If lTabDDA
		//-- CRIRAT
		If !Empty(cCRIRAT)
			lRet:= cCRI_DDA == cCRIRAT
		Else
			 lRet:= cCRI_DDA <> '1' .And. cCRI_DDA <> ''
	 	EndIf

	 	//-- PRORAT
	 	If lRet
			If !Empty(cPRORAT)
				lRet:= cPRO_DDA == cPRORAT
		 	Else
		 		lRet:= cPRO_DDA <> ''
			EndIf
	 	EndIf
	Else
		//-- CRIRAT
		If !Empty(cCRIRAT)
			lRet:= cCRI_DDC == cCRIRAT
		Else
			lRet:= cCRI_DDC <> '1' .And. cCRI_DDC <> ''
	 	EndIf

	 	//-- PRORAT
	 	If lRet
			If !Empty(cPRORAT)
				lRet:= cPRO_DDC == cPRORAT
		 	Else
		 		lRet:= cPRO_DDC <> ''
			EndIf
	 	EndIf
	 EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsFrtCol
@autor		: Katia
@descricao	: Retorna o array aFreteCol contendo as Solicitacoes de Coleta e seus respectivos
			: componentes de Herda Valor e Notas Fiscais. Este vetor é criado com base nos dados do aNfCtrc
			: e será utilizado posteriormente na funçao TMSa200Agr para ratear o valor do componente
			: 16-Herda Valor. Ou seja quando uma SC estiver vinculada a mais de uma NF gerando mais de um
			: Documento de Transporte o valor do componente 16 será rateado entre os Documentos.
@since		: 08/Maio/2016
@using		:
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsFrtCol(aNfCTRC, cLotNfc, cCmpHerda, aFreteCol)

Local nValor   := 0
Local nCntFor1 := 0
Local cQuery   := ""
Local cAliasTmp:= ""
Local aArea    := GetArea()
Local cComp    := ""
Local nPos     := 0
Local nPos2    := 0
Local cQuery1  := ""
Local cAliasDTC:= ""
Local cPrdGener:= Padr(SuperGetMV('MV_PROGEN',,''),Len(SB1->B1_COD))

Default aNfCTRC  := {}
Default cCmpHerda:= ""
Default aFreteCol:= {}

//----------- Estrutura do vetor aFreteCol ------
//[01]- Filial Coleta
//[02]- Numero Sol.Coleta
//[03]- Array com os componentes de Frete
//[03][01]- Componente
//[03][02]- Valor do componente
//[04]- Array com as Notas Fiscais
//[04][01]- Numero da Nota
//[04][02]- Serie da Nota
//[04][03]- Cliente Remetente
//[04][04]- Loja Remetente
//[04][05]- Volumes
//[04][06]- Vlr.Mercadoria
//[04][07]- Peso
//[04][08]- Peso Cubado
//[04][09]- M3
//------------------------------------------------

//--- Verificar quais os componentes estao relacionados ao componente de 'Herda Valor'
cAliasTmp:= GetNextAlias()
cQuery := " SELECT DJE_CMPREL "
cQuery += "   FROM "
cQuery += RetSqlName("DJE") + " DJE "
cQuery += "   WHERE DJE.DJE_FILIAL = '" + xFilial("DJE") + "' "
cQuery += "     AND DJE.DJE_CODPAS = '" + cCmpHerda + "' "
cQuery += "     AND DJE.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTmp, .F., .T.)
While (cAliasTmp)->(!Eof())
	cComp += "'" + (cAliasTmp)->DJE_CMPREL +"',"
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(DbCloseArea())
cComp := Substr(cComp,1,Len(cComp) - 1)

//--- Monta o vetor aFreteCol
If !Empty(cComp)

	For nCntFor1 := 1 To Len(aNfCTRC)
		If aNfCTRC[nCntFor1,32] <> '' //Somente Notas com Numero de Solicitacao
			cAliasTmp:= GetNextAlias()
			cQuery := " SELECT DTC_FILORI, DTC_FILCFS, DTC_NUMSOL, DTC_CODPRO, SUM(DT8_VALPAS) VALPAS "
			cQuery += "   FROM "
			cQuery += RetSqlName("DTC") + " DTC "
			cQuery += " INNER JOIN " + RetSqlName("DT8") + " DT8 "
			cQuery += "   ON  DT8.DT8_FILIAL  = '" + xFilial("DT8") + "' "
			cQuery += "   AND DT8.DT8_FILDOC = DTC.DTC_FILCFS "
			cQuery += "   AND DT8.DT8_DOC    = DTC.DTC_NUMSOL "
			cQuery += "   AND DT8.DT8_SERIE  = 'COL'  "
			cQuery += "   AND DT8.DT8_CODPRO  = '" + cPrdGener + "' "
			If At(",",cComp) > 0
				cQuery += "  AND DT8.DT8_CODPAS IN ( "+cComp+" )"
			Else
				cQuery += "  AND DT8.DT8_CODPAS = "+cComp
			EndIf
			cQuery += "   AND DT8.D_E_L_E_T_ = ' ' "

			cQuery += "   WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += "     AND DTC.DTC_LOTNFC = '" + cLotNfc + "' "
			cQuery += "     AND DTC.DTC_NUMNFC = '" + aNfCTRC[nCntFor1,01] + "' "
			cQuery += "     AND DTC.DTC_SERNFC = '" + aNfCTRC[nCntFor1,02] + "' "
			cQuery += "     AND DTC.DTC_CLIREM = '" + aNfCTRC[nCntFor1,03] + "' "
			cQuery += "     AND DTC.DTC_LOJREM = '" + aNfCTRC[nCntFor1,04] + "' "
			cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
			cQuery += "     GROUP BY DTC_FILORI, DTC_FILCFS, DTC_NUMSOL, DTC_CODPRO "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTmp, .F., .T.)
			While (cAliasTmp)->(!Eof())

				nPos:= aScan(aFreteCol, {|x|x[1]+x[2] == (cAliasTmp)->DTC_FILCFS + (cAliasTmp)->DTC_NUMSOL })
				If nPos == 0
					AAdd(aFreteCol, {(cAliasTmp)->DTC_FILCFS,(cAliasTmp)->DTC_NUMSOL, {{ cCmpHerda,(cAliasTmp)->VALPAS }}, {} })
					nPos:= Len(aFreteCol)
				Else
					//--- Verifica se existe o componente
					nPos2:= aScan(aFreteCol[nPos][3], {|x| x[1] == cCmpHerda} )
					If nPos2 == 0
						AAdd(aFreteCol[nPos][3], { cCmpHerda,(cAliasTmp)->VALPAS } )
					EndIf
				EndIf

				//-------- Notas fiscais vinculadas a Solicitacao de Coleta -------------
				cAliasDTC:= GetNextAlias()
				cQuery1 := " SELECT DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM, DTC_PESO, DTC_PESOM3, DTC_VALOR, DTC_QTDVOL, DTC_METRO3 "
				cQuery1 += "   FROM "
				cQuery1 += RetSqlName("DTC") + " DTC "
				cQuery1 += "   WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
				cQuery1 += "     AND DTC.DTC_FILORI = '" + (cAliasTmp)->DTC_FILORI + "' "   //Incuido o DTC_FILORI por estar no indice 8
				cQuery1 += "     AND DTC.DTC_NUMSOL = '" + (cAliasTmp)->DTC_NUMSOL + "' "
				cQuery1 += "     AND DTC.DTC_FILCFS = '" + (cAliasTmp)->DTC_FILCFS + "' "
				cQuery1 += "     AND DTC.D_E_L_E_T_ = ' ' "
				cQuery1 := ChangeQuery(cQuery1)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1),cAliasDTC, .F., .T.)
				While (cAliasDTC)->(!Eof())
					//-- Verifica se existe a Nota
					nPos3:= aScan(aFreteCol[nPos][4], {|x| x[1]+x[2]+x[3]+x[4] == (cAliasDTC)->DTC_NUMNFC + (cAliasDTC)->DTC_SERNFC + (cAliasDTC)->DTC_CLIREM + (cAliasDTC)->DTC_LOJREM } )
					If nPos3 == 0
						AAdd(aFreteCol[nPos][4],{	(cAliasDTC)->DTC_NUMNFC,;  	 //--Numero da Nota
							                  (cAliasDTC)->DTC_SERNFC,;  	 //--Serie da Nota
							                  (cAliasDTC)->DTC_CLIREM,;  	 //--Cliente Remetente
							                  (cAliasDTC)->DTC_LOJREM,;  	 //--Loja Remetente
							                  (cAliasDTC)->DTC_QTDVOL,;    //--Volumes
							                  (cAliasDTC)->DTC_VALOR,;     //--Vlr Merc
							                  (cAliasDTC)->DTC_PESO,;      //--Peso
							                  (cAliasDTC)->DTC_PESOM3,;    //--Peso Cubado
							                  (cAliasDTC)->DTC_METRO3 } )  //--M3
					EndIf
					(cAliasDTC)->(dbSkip())
				EndDo
				(cAliasDTC)->(DbCloseArea())
				//--------------


				(cAliasTmp)->(dbSkip())
			EndDo
			(cAliasTmp)->(DbCloseArea())
		EndIf
	Next nCntFor1
EndIf

RestArea(aArea)
Return Nil
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSRetRegD
@autor		: Rafael Souza
@descricao	: Retorna a Região de Destino para o calculo
@since		: Abril/2016
@using		:
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSRetRegD(cSerTms,cFilOri,cViagem, cFilDoc, cDoc, cSerie)

Local cCdrDes	:= ''
Local aAreaDUD	:= DUD->(GetArea())
Local aRegInf 	:= {}
Local cAliasNew := ''
Local cQuery 	:= ''
Local lUltDest  := SuperGetMv('MV_ULTDEST',,.F.) // Define se utiliza o ultimo destino da coleta/entrega.

Default cSerTms := ''
Default cFilOri := ''
Default cViagem := ''
Default cFilDoc := ''
Default cDoc	:= ''
Default cSerie  := ''

//-- Se for Viagem de Transporte, determinar a Regiao de Destino que contera'
//-- a Tabela de Frete
If cSerTms == StrZero(2, Len(DTQ->DTQ_SERTMS))
	//-- Obter a ultima Regiao de Descarga
	aRegDCA  := TMSRegDca(DTQ->DTQ_ROTA)
	If !Empty(aRegDCA)
		//-- A Ultima Regiao da TMSNivInf() sera' a Regiao Destino.
		aRegInf := {}
		TMSNivInf( aRegDCA[Len(aRegDCA)][2],@aRegInf )
		If !Empty(aRegInf)
			cCdrDes := aRegInf[Len(aRegInf)][1]
		Else
			cCdrDes := aRegDCA[Len(aRegDCA)][2]
		EndIf
	EndIf
Else
	If !Empty(DTQ->DTQ_ROTEIR) .And. DA8->(ColumnPos("DA8_CDRCAL")) > 0
		cCdrDes := Iif(!Empty(DA8->DA8_CDRCAL),DA8->DA8_CDRCAL,DTQ->DTQ_CDRDES)
	ElseIf !lUltDest .And. !IsInCallStack('TMSCEOrDes')
		//-- Posiciona na Rota
		DA8->(DbSetOrder(1))
		DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA))
		cCdrDes := DA8->DA8_CDRORI
	Else
		cAliasNew := GetNextAlias()
		cQuery := " SELECT DUD_CDRCAL, DT6_CDRCAL, DUD_FILDOC, DUD_DOC, DUD_SERIE "
		cQuery += "   FROM "
		cQuery += RetSqlName("DUD") + " DUD, "
		cQuery += RetSqlName("DT6") + " DT6 "
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
		cQuery += "     AND DUD_FILORI = '" + cFilOri + "'"
		cQuery += "     AND DUD_VIAGEM = '" + cViagem + "'"
		cQuery += "     AND DUD_SEQUEN = ( "
		cQuery += "         SELECT Max(DUD_SEQUEN) "
		cQuery += "         FROM " + RetSqlName("DUD")
		cQuery += "         WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
		cQuery += "           AND DUD_FILORI = '" + cFilOri + "'"
		cQuery += "           AND DUD_VIAGEM = '" + cViagem + "'"
		cQuery += "           AND D_E_L_E_T_ = ' ' ) "
		cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
		cQuery += "     AND DT6_FILIAL = '" + xFilial("DT6") + "'"
		cQuery += "     AND DT6_FILDOC = DUD_FILDOC "
		cQuery += "     AND DT6_DOC    = DUD_DOC "
		cQuery += "     AND DT6_SERIE  = DUD_SERIE "
		cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
		//-- Armazena a regiao destino da ultima sequencia da viagem.
		If (cAliasNew)->( !Eof() )
			If !Empty((cAliasNew)->DUD_CDRCAL)
				cCdrDes := (cAliasNew)->DUD_CDRCAL
			ElseIf !Empty((cAliasNew)->DT6_CDRCAL)
				cCdrDes := (cAliasNew)->DT6_CDRCAL
			Else
				cCdrDes := DA8->DA8_CDRORI
			EndIf
			cFilDoc 	:= (cAliasNew)->DUD_FILDOC
			cDoc 		:= (cAliasNew)->DUD_DOC
			cSerie 		:= (cAliasNew)->DUD_SERIE
		EndIf
		(cAliasNew)->(DbCloseArea())
	EndIf
EndIf

RestArea(aAreaDUD)

Return (cCdrDes)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsVlrCmp
@autor		: Katia
@descricao	: Retorna o valor do componente Herda valor do vetor aFreteCol
@since		: 17/Maio/2016
@using		:
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsVlrCmp(aFreteCol,cComp,cNota,cSerie,cCliRmt,cLojRmt)
Local nRet   := 0
Local nCount1:= 0
Local nSeek  := 0

Default aFreteCol:= {}
Default cComp    := ""
Default cNota    := ""
Default cSerie   := ""
Default cCliRmt  := ""
Default cLojRmt  := ""

For nCount1:= 1 To Len(aFreteCol)
	//--- Retorna o valor total do componente
	If Empty(cNota)
		nSeek:= Ascan(aFreteCol[nCount1][3], {|x| x[1] == cComp })
		If nSeek > 0
			nRet+= aFreteCol[nCount1][3][nSeek][2]
		EndIf
	Else
		nSeek:= Ascan(aFreteCol[nCount1][4], {|x| x[1]+x[2]+x[3]+x[4] == cNota + cSerie + cCliRmt + cLojRmt })
		If nSeek > 0
			nRet+= aFreteCol[nCount1][4][nSeek][2]
		EndIf
	EndIf
Next nCount1

Return nRet

//===========================================================================================================
/* PRE Validação Verifica o controle de Transações.
@author  	Alex Amaral
@version 	P11
@build
@since 	10/02/2017
@return 	 */
//===========================================================================================================

Function TmsConTran(cFilDoc,cDoc,cSerie,lBloqueia)

Local lRet := .F.

Default cFilDoc   := ""
Default cDoc      := ""
Default cSerie    := ""
Default lBloqueia := .F.

DT6->(DbSetOrder(1))
If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
	If lBloqueia
		lRet := SoftLock("DT6")
	Else
		lRet := DT6->(MsUnlock())
	EndIf
EndIf

Return(lRet)


//===========================================================================================================
/* TmsDocAPG()
   Considera se os documentos posicionados serão considerados na pela função TMSCALFREPAG()
@author  	Leandro Paulino
@version 	P12
@build
@param		1 - aDocs: Documentos que goram marcados pela rotina de Itens não previstos.
@since 	04/05/2017
@return 	 */
//===========================================================================================================
Static Function TmsDocAPG(nRecno,aDoctos)

Local lRet := .T.

Default nRecno  := DUD->(RECNO())
Default aDoctos := {}
//--Verifica se o documento posicionado é um documento não previsto e se for verifica se o mesmo foi selecionado para
//--ser utilizado na geração do contrato de carreteiro
If DUD->(ColumnPos('DUD_DTRNPR')) > 0
	If !Empty(DUD->DUD_DTRNPR) .And. AScan(aDoctos,nRecno) == 0
		lRet := .F.
	EndIf
EndIf


Return lRet

/*/{Protheus.doc} TMSFUNBClr
//TODO Função que zera cache de memória das varíaveis estáticas
@author caio.y
@since 17/04/2018
@version 1.0
@return ${return}, ${return_description}
@param xNomeVar, , Nome da Variavel
@param lKill, logical, Indica se será atribuido Nil
@type function
/*/
Function TMSFUNBClr( cNomeVar , lKill )

Default cNomeVar	:= ""
Default lKill		:= .F.

If ValType(&cNomeVar) == "A"

	&cNomeVar	:=	aSize(&cNomeVar,0)

	If lKill
		&cNomeVar	:= NIl
	Else
		&cNomeVar	:= {}
	EndIf

EndIf

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsVAbrCal
@autor		: Katia 
@descricao	: Verifica se a Nota está vinculada a uma SC e a SC está na mesma viagem 
@since		: 07/11/2018
@using		: TMSXFUNB 
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function TmsVAbrCal(aDocNPrev)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasDTC := GetNextAlias()
Local cAliasDUD := ""
Local aArea     := GetArea()
Local cRecnoDUD := DUD->(Recno())

Default aDocNPrev := {}

cQuery := " SELECT DTC.DTC_FILCFS, DTC.DTC_NUMSOL, DTC.DTC_FILDOC, DTC.DTC_DOC, DTC.DTC_SERIE "
cQuery += " FROM " + RetSqlName("DTC") + " DTC "
cQuery += " WHERE DTC.DTC_FILIAL = '"  + xFilial("DTC")  + "' "
If DUD->DUD_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))    //--- Documento de Coleta, verifica se existe NF vinculada na mesma viagem
	cQuery += " AND	DTC.DTC_FILORI	=  '" + DUD->DUD_FILORI + "' "
	cQuery += " AND	DTC.DTC_NUMSOL	=  '" + DUD->DUD_DOC + "' "
Else	
	cQuery += " AND	DTC.DTC_FILDOC	= '" + DT6->DT6_FILDOC + "' "
	cQuery += " AND	DTC.DTC_DOC	= '" + DT6->DT6_DOC + "' "
	cQuery += " AND	DTC.DTC_SERIE = '" + DT6->DT6_SERIE + "' "
	cQuery += " AND	DTC.DTC_CLIREM = '" + DT6->DT6_CLIREM + "' "
	cQuery += " AND	DTC.DTC_LOJREM = '" + DT6->DT6_LOJREM + "' "
	cQuery += " AND	DTC.DTC_NUMSOL	<>  ' ' "
EndIf	
cQuery += " AND	DTC.D_E_L_E_T_ 	= ' ' "
cQuery += " GROUP BY  DTC.DTC_FILCFS, DTC.DTC_NUMSOL, DTC.DTC_FILDOC, DTC.DTC_DOC, DTC.DTC_SERIE "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

If (cAliasDTC)->(!Eof())
	//---- Verificar se o Documento está na mesma viagem
	cAliasDUD := GetNextAlias()

	cQuery := " SELECT MAX(DUD.R_E_C_N_O_) NREDUD "
	cQuery += " FROM " + RetSqlName("DUD") + " DUD "
	cQuery += " WHERE "
	cQuery += " DUD.DUD_FILIAL = '"  + xFilial("DUD")  + "' "
	cQuery += " AND	DUD.DUD_FILORI 	= '" + DTQ->DTQ_FILORI + "' "
	cQuery += " AND	DUD.DUD_VIAGEM	= '" + DTQ->DTQ_VIAGEM + "' "
	If DUD->DUD_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))  
		cQuery += " AND	DUD.DUD_FILDOC 	= '" + (cAliasDTC)->DTC_FILDOC + "' "
		cQuery += " AND	DUD.DUD_DOC	= '" +  (cAliasDTC)->DTC_DOC  + "' "
		cQuery += " AND	DUD.DUD_SERIE = '" +  (cAliasDTC)->DTC_SERIE  + "' "
	Else
		cQuery += " AND	DUD.DUD_FILDOC 	= '" + (cAliasDTC)->DTC_FILCFS + "' "
		cQuery += " AND	DUD.DUD_DOC	= '" +  (cAliasDTC)->DTC_NUMSOL  + "' "
		cQuery += " AND	DUD.DUD_SERIE = 'COL' "
	EndIf
	cQuery += " AND	DUD.DUD_STATUS	!= '9' "
	cQuery += " AND	DUD.D_E_L_E_T_ 	= ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD)
	If (cAliasDUD)->(!Eof())
		
		//---- Verifica se é um Documento não Previsto e se o mesmo foi selecionado para gerar o contrato
		If (cAliasDUD)->NREDUD > 0
			DUD->( DbGoto( (cAliasDUD)->NREDUD ) )
			If TmsDocAPG(DUD->(RECNO()),aDocNPrev) 
				lRet:= .T.
			EndIf
		EndIf	

	EndIf
	(cAliasDUD)->(DbCloseArea())
EndIf	
(cAliasDTC)->(dbCloseArea())

DUD->( DbGoto(cRecnoDUD) )		

RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSLoteCli()
Verifica se todos os remetentes do lote sejam iguais ao remetente DTC-CLIREM/DTC_LOJREM.

@author arume.alexandre
@since 28/02/2019
@version 1.0
-----------------------------------------------------------/*/
Function TMSLoteCli(cFilOri, cLotNfc, cCliLojRem)

	Local lRet			:= .T.
	Local aAreaDTC		:= {}
	Default cCliLojRem	:= ""

	aAreaDTC := DTC->(GetArea())
	DTC->(dbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
	DTC->(MsSeek(xFilial("DTC")+cFilOri+cLotNfc))
	While DTC->(!Eof()) .AND. xFilial("DTC")+cFilOri+cLotNfc == xFilial("DTC")+DTC->(DTC_FILORI+DTC_LOTNFC)
		If Empty(cCliLojRem)
			cCliLojRem := DTC->(DTC_CLIREM+DTC_LOJREM)
		ElseIf cCliLojRem <> DTC->(DTC_CLIREM+DTC_LOJREM)
			Help("", 1, "TMSA17020") // Para que seja possível selecionar uma viagem com status Em Trânsito, todas as notas fiscais deste lote devem ser do mesmo remetente e neste lote constam vários remetentes. 
			lRet := .F.
			Exit
		EndIf
		DTC->(dbSkip())
	EndDo
	RestArea(aAreaDTC)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSLoteOpe()
Verifica se o remetente do lote é o mesmo da operação de transporte ou se a viagem esta totalmente em transito.

@author arume.alexandre
@since 28/02/2019
@version 1.0
-----------------------------------------------------------/*/
Function TMSLoteOpe(cFilOri, cViagem, cCliLojRem)

	Local lRet			:= .T.
	Local aRet			:= {}
	Local nPAtivid		:= 0
	Local nPCodCli		:= 0
	Local nPLojCli		:= 0
	Local cAtvChgCli	:= SuperGetMV('MV_ATVCHGC',,'')
	Local cAtivSai		:= SuperGetMV('MV_ATIVSAI',,'') // Atividade de Saída de viagem.
	Local cAtvSaiC 		:= SuperGetMV('MV_ATVSAIC',,'') // Atividade de Saída de viagem no cliente.

	Default cCliLojRem	:= ""

	If !Empty(cCliLojRem)
		aRet := A350RetDTW(cFilOri, cViagem, "3", "2")
		If Len(aRet) > 0
			nPAtivid := aScan(aRet[1], { |x| x[1] == "DTW_ATIVID" })
			nPCodCli := aScan(aRet[1], { |x| x[1] == "DTW_CODCLI" })
			nPLojCli := aScan(aRet[1], { |x| x[1] == "DTW_LOJCLI" })
			If nPAtivid > 0 .AND. nPCodCli > 0 .AND. nPLojCli > 0
				If aRet[1, nPAtivid][2] == cAtvChgCli
					If cCliLojRem <> aRet[1, nPCodCli][2]+aRet[1, nPLojCli][2]
						Help("", 1, "TMSA050T2") // O Cliente/Loja remetente deve ser o mesmo Cliente/Loja da operação de transporte, da viagem vinculada ao lote.
						lRet := .F.
					EndIf
				ElseIf aRet[1, nPAtivid][2] == cAtivSai .OR. aRet[1, nPAtivid][2] == cAtvSaiC
					lRet := .T.
				EndIf
			EndIf
			aRet := {}
			aSize(aRet, 0)
		EndIf
	EndIf
	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSVgTotTr()
Verifica se a viagem esta totalmente em transito, ou seja, a ultima operação apontada é saída de viagem ou saída de cliente.

@author arume.alexandre
@since 28/02/2019
@version 1.0
-----------------------------------------------------------/*/
Function TMSVgTotTr(cFilOri, cViagem)

	Local lRet		:= .T.
	Local aRet		:= {}
	Local nPAtivid	:= 0
	Local nPCodCli	:= 0
	Local nPLojCli	:= 0
    Local cAtvCheC 	:= SuperGetMV('MV_ATVCHGC',,'') // Atividade de Chegada de viagem no cliente.
	Local cAtvCheApo:= SuperGetMv('MV_ATVCHPA',,'') // Atividade de Chegada do Ponto de Apoio
    
	aRet := A350RetDTW(cFilOri, cViagem, "3", "2")
	If Len(aRet) > 0
		nPAtivid := aScan(aRet[1], { |x| x[1] == "DTW_ATIVID" })
		nPCodCli := aScan(aRet[1], { |x| x[1] == "DTW_CODCLI" })
		nPLojCli := aScan(aRet[1], { |x| x[1] == "DTW_LOJCLI" })
		If nPAtivid > 0 .AND. nPCodCli > 0 .AND. nPLojCli > 0
			If aRet[1, nPAtivid][2] == cAtvCheC .OR. aRet[1, nPAtivid][2] == cAtvCheApo
				lRet := .F.
			EndIf
		EndIf
		aRet := {}
		aSize(aRet, 0)
	EndIf
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSOperUlt()
Verifica se é a última operação apontada.

@author arume.alexandre
@since 19/03/2019
@version 1.0
-----------------------------------------------------------/*/
Function TMSOperUlt(cFilOri, cViagem)

	Local lRet		:= .F.
	Local aRet		:= {}
	Local nPSequen	:= 0

	aRet := A350RetDTW(cFilOri, cViagem, "4", "2")
	If Len(aRet) > 0
		nPSequen := aScan(aRet[1], { |x| x[1] == "DTW_SEQUEN" })
		If nPSequen > 0
			If aRet[1, nPSequen][2] == DTW->DTW_SEQUEN
				lRet := .T.
			EndIf
		EndIf
		aRet := {}
		aSize(aRet, 0)
	EndIf
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSCEOrDes()
Retorna CEP de origem e destino da viagem além da KM da mesma

@author Leandro Paulino
@since 12/07/2019
@version 1.0
-----------------------------------------------------------/*/
Function TMSCEOrDes(cFilOri, cViagem, cSerTms, cRota, aDoctoVge)

Local cCepOri		:= ''
Local cCepDes		:= ''
Local aFilDCA		:= ''
Local nUltPto		:= 0
Local cDoc			:= ''
Local cSerie		:= ''
Local cFilDoc		:= ''
Local lUltDest  	:= SuperGetMv('MV_ULTDEST',,.F.) // Define se utiliza o ultimo destino da coleta/entrega.
Local nDist			:= 0
Local cCdrFilial	:= SuperGetMV('MV_CDRORI',,'')
Local aAreas    	:= {SA1->(GetArea()),DT5->(GetArea()),DUD->(GetArea()),SA8->(GetArea()),DTQ->(GetArea()),SM0->(GetArea()),DT6->(GetArea())}
Local cCdrCli		:= ''//Região do Cliente retornado pela Função TMSCEPENT		
Local lContinua		:= .T.
Local nPOsUltDoc	:= 0
Local cTipTra		:= ''
Local cChaveDUD		:= ''

Default cFilOri		:= ''
Default cViagem		:= ''
Default cSerTms		:= ''
Default cRota		:= ''
Default aDoctoVge	:= {}

If !Empty(cFilOri) .And. !Empty(cViagem)
	If Empty(cRota)
		DTQ->(dbSetOrder(2))
		If DTQ->(MsSeek(FwxFilial('DTQ')+cFilOri+cViagem))
			cRota := DTQ->DTQ_ROTA
		Else
			lContinua := .F.
		EndIf
	EndIf
	If lContinua
		cTipTra := Posicione('DA8', 1, xFilial('DA8')+cRota, "DA8_TIPTRA")

		//Retorna os dados do último documento da viagem
		If cSerTms == '2'
			//--CEP de ORIGEM
			cCepOri := Posicione("SM0", 1, cEmpAnt  + cFilOri, "M0_CEPENT") 
			
			//--CEP de DESTINO
			aFilDCA := TMSRegDca(cRota)
			If Len(aFilDCA) > 0
				nUltPto := Len(aFilDCA)					
				cCepDes := Posicione("SM0", 1, cEmpAnt  + aFilDCA[nUltPto,3], "M0_CEPENT") 
			EndIf
			
			nDist := TmsTotDis(,,aFilDCA[1,1],aFilDCA[nUltPto,2],cTipTra)		
		Else			
			If Empty(aDoctoVge)
				TMSRetRegD(cSerTms,cFilOri,cViagem,@cFilDoc,@cDoc,@cSerie)	
				DUD->(dbSetOrder(1))
				lContinua := DUD->(MsSeek(FwxFilial('DUD')+cFilDoc+cDoc+cSerie+cFilOri+cViagem))
			Else
				DUD->(dbSetOrder(1))
				nPOsUltDoc := Len(aDoctoVge)
				If cSertms == '1'
					lContinua := DUD->(MsSeek(FwxFilial('DUD')+aDoctoVge[nPOsUltDoc,5]+aDoctoVge[nPOsUltDoc,6]+aDoctoVge[nPOsUltDoc,7]))
					cChaveDUD := FwxFilial('DUD')+aDoctoVge[nPOsUltDoc,5]+aDoctoVge[nPOsUltDoc,6]+aDoctoVge[nPOsUltDoc,7]
				ElseIf cSertms == '3'
					lContinua := DUD->(MsSeek(FwxFilial('DUD')+aDoctoVge[nPOsUltDoc,7]+aDoctoVge[nPOsUltDoc,8]+aDoctoVge[nPOsUltDoc,9]))
					cChaveDUD := FwxFilial('DUD')+aDoctoVge[nPOsUltDoc,7]+aDoctoVge[nPOsUltDoc,8]+aDoctoVge[nPOsUltDoc,9]
				EndIf
				
				While DUD->(!Eof()) .And. FwxFilial('DUD')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE) == cChaveDUD 
					If DUD->DUD_STATUS == '1'					
						Exit
					EndIf
				EndDo
				
			EndIf	
			If lContinua
				If cSerTms == '1' //--Coleta
					
					//--Se for considerado o ultimo documento da viagem de coleta a origem será o ultimo documento do DUD
					//--e o destino será a filial			
					DT5->(dbSetOrder(1))					
					If DT5->(MsSeek(FwxFilial('DT5')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
						If DT5->DT5_LOCCOL == '1' 
							//--Posiciona na sequencia de Endereço
							cCepOri := TmsCEPEnt( , ,DT5->DT5_CODSOL,DT5->DT5_SEQEND,@cCdrCli)
						Else					
							cCepOri := TmsCEPEnt(DT5->DT5_CLIREM, DT5->DT5_LOJREM,,,@cCdrCli)								
						EndIf
						
					EndIf			
						
					If !lUltDest 
						//--Se não for considerado o ultimo documento da viagem de coleta, a origem e destino será a Filial...
						cCepOri := Posicione("SM0", 1, cEmpAnt  + cFilOri, "M0_CEPENT") 						
					EndIf
					
					cCepDes := Posicione("SM0", 1, cEmpAnt  + cFilOri, "M0_CEPENT") 					
					
					//--Na viagem de Coleta a Origem da Viagem será a região do Remente ou do Local de Entrega ou da Filial(MV_ULTDEST = .F.)
					nDist := TmsTotDis(,,cCdrCli,cCdrFilial,cTipTra)		
				
				ElseIf cSerTms == '3' //--Entrega
					
					//--CEP de ORIGEM
					cCepOri := Posicione("SM0", 1, cEmpAnt  + cFilOri, "M0_CEPENT") 
					
					//--Se for considerado o ultimo documento da vfiagem, o destino será o CEP do destinatário deste documento.					
					If lUltDest
						//CEP de Destino
						cCepDes := DUD->DUD_CEPENT
					Else
						//--Se não for considerado o ultimo documento da viagem, o destino será o CEP o mesmo CEP da ORIGEM (FILIAL)
						cCepDes := cCepOri		
					EndIf	
					
					cCdrCli := Posicione('DT6',1,FwxFilial('DT6')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE),'DT6_CDRDES')
					
					//--Na viagem de eNTREGA a Origem da Viagem será a REGIÃO DA Filial e o destino será a região do último documento da viagem(MV_ULTDEST= .T.), ou a própria Filial(MV_ULTDEST = .F.)
					nDist := TmsTotDis(,,cCdrFilial,cCdrCli,cTipTra)		
				EndIf
				
				If !lUltDest
					nDist := nDist * 2					
				EndIf
			EndIf
		EndIf				
		
	EndIf	

EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return {cCepOri, cCepDes,nDist}

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSManEnc
Verifica se existe(m) manifesto(s) encerrado(s) para a viagem.

Uso: TMSManEnc

@author arume.alexandre
@since 14/08/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TMSManEnc(cFilOri, cViagem, aDocs, cFilDoc, cDoc, cSerie)

    Local lRet      := .F.
    Local aAreaDTX  := DTX->(GetArea())
    Local aAreaDLH  := {}
    
    Default cFilOri := ""
    Default cViagem := ""
    Default aDocs   := {}
    // Estas variaveis são preenchidas no estorno do carregamento de documento.
    Default cFilDoc := ""
    Default cDoc    := ""
    Default cSerie  := ""
    
    DTX->(dbSetOrder(5)) //DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI
    DTX->(MsSeek(xFilial("DTX")+cFilOri+cViagem))
    While DTX->(!Eof()) .AND. xFilial("DTX")+cFilOri+cViagem == xFilial("DTX")+DTX->(DTX_FILORI+DTX_VIAGEM)
        If DTX->DTX_STFMDF == "2" // Encerramento autorizado
            If TableInDic("DLH")
                aAreaDLH := DLH->(GetArea())
                DLH->(dbSetOrder(2)) //DLH_FILIAL+DLH_FILMAN+DLH_MANIFE+DLH_SERMAN
                DLH->(MsSeek(xFilial("DLH")+DTX->(DTX_FILMAN+DTX_MANIFE+DTX_SERMAN)))
                While DLH->(!Eof()) .AND. xFilial("DLH")+DTX->(DTX_FILMAN+DTX_MANIFE+DTX_SERMAN) == xFilial("DLH")+DLH->(DLH_FILMAN+DLH_MANIFE+DLH_SERMAN)
                    // Estorno do carregamento de documento.
                    If !Empty(cFilDoc) .AND. !Empty(cDoc) .AND. !Empty(cSerie)
                        If cFilDoc+cDoc+cSerie == DLH->(DLH_FILDOC+DLH_DOC+DLH_SERIE)
                            aAdd(aDocs, {DLH->DLH_FILDOC, DLH->DLH_DOC, DLH->DLH_SERIE})
                            Return .T.
                        EndIf
                    // Estorno do fechamento de viagem.
                    Else
                        aAdd(aDocs, {DLH->DLH_FILDOC, DLH->DLH_DOC, DLH->DLH_SERIE})
                        lRet := .T.
                    EndIf
                    DLH->(dbSkip())
                End
                RestArea(aAreaDLH)
            Else
                lRet := .T.
            EndIf
        EndIf
        DTX->(dbSkip())
    End
    RestArea(aAreaDTX)

Return lRet

