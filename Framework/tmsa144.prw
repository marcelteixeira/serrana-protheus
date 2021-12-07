#Include "TMSA144.CH"
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

//-- Diretivas indicando as colunas dos documentos da viagem Do TMSA141
#Define CTSTATUS		1
#Define CTSTROTA		2
#Define CTMARCA			3
#Define CTSEQUEN		4
#Define CTARMAZE		5
#Define CTLOCALI		6
#Define CTFILDOC		7
#Define CTDOCTO			8 
#Define CTSERIE			9
#Define CTREGDES		10
#Define CTDATEMI		11
#Define CTPRZENT		12
#Define CTNOMREM		13
#Define CTNOMDES		14
#Define CTQTDVOL		15
#Define CTVOLORI		16
#Define CTPLIQUI		17
#Define CTPESOM3		18
#Define CTVALMER		19
#Define CTVIAGEM		20
#Define CTSEQDA7		21
#Define CTSOLICI		22			//-- DUE_NOME
#Define CTENDERE		23			//-- DUE_END
#Define CTBAIRRO		24			//-- DUE_BAIRRO
#Define CTMUNICI		25			//-- DUE_MUN
#Define CTDATSOL		26			//-- DT5_DATSOL
#Define CTHORSOL		27			//-- DT5_HORSOL
#Define CTDATPRV		28			//-- DT5_DATPRV
#Define CTHORPRV		29			//-- DT5_HORPRV
#Define CTDOCROT		30			//-- Codigo que identifica a q rota pertence o documento
#Define CTBLQDOC		31			//-- Tipos de bloqueio do documento
#Define CTNUMAGE		32			//-- Numero do Agendamento( Carga Fechada ).
#Define CTITEAGE		33			//-- Item do Agendamento( Carga Fechada ).
#Define CTSERTMS		34			//-- Tipo do Servico.
#Define CTDESSVT		35			//-- Descricao do Servico.
#Define CTESTADO		36
#Define CTDATENT		37
#Define CTUNITIZ		38			//-- Unitizador
#Define CTCODANA		39			//-- Codigo analitico do unitizador.
/*-- 
Defines abaixo precisam ser ajustados conforme TMSA141 
#Define CT40     		40			
#Define CT41     		41			
#Define CT42     		42			
#Define CT43     		43			
#Define CT44     		44			
#Define CT45       	45			
*/
//--- Estrutura da Integracao TMS x GFe - mesma do TMSA140 e TMSA141
#Define CTUFORI      46        //-- UF Origem (Integracao GFE)
#Define CTCDMUNO     47        //-- Cod.Municipio Origem (Integracao GFE)
#Define CTCEPORI     48        //-- Cep Origem (Integracao GFE)
#Define CTUFDES      49        //-- UF Destino (Integracao GFE)
#Define CTCDMUND     50        //-- Cod.Municipio Destino (Integracao GFE)
#Define CTCEPDES     51        //-- Cep Destino (Integracao GFE)
#Define CTTIPVEI     52        //-- Tipo Veiculo (Integracao GFE)
#Define CTCDCLFR     53        //-- Cod.Classificacao Frete (Integracao GFE)
#Define CTCDTPOP     54        //-- Tipo de Operação (Integracao GFE)

#Define CTORIGEM	 55			//-- Origem Carregamento.
//--Estrutura com o retorno das Informações do Roteiro
#Define ROTESTADO   01
#Define ROTFILDOC   02
#Define ROTDOC		03
#Define ROTSERIE    04
#Define ROTCLIREM   05
#Define ROTLOJREM   06
#Define ROTCLIDES   07
#Define ROTLOJDES   08
#Define ROTTIPOPE	09

Static lSelDoc
Static nPosFilD		:= 0
Static nPosDoc		:= 0
Static nPosSerie	:= 0
Static oNoMarked
Static oMarked
Static lTM144CPO	:= ExistBlock("TM144CPO")	//-- Permite modificar os campos a alterar na enchoice
Static lTM144GOk	:= ExistBlock("TM144GOk")	//-- Inibir a validação padrão do sistema para permitir a criação de novas viagens sem conhecimento emitido.
Static lTM144CDC	:= ExistBlock("TM144CDC")	//-- Permite ao usuario, incluir colunas nos documento.
Static lTM144EEX	:= ExistBlock("TM144EEX")	//-- Permite realizar acoes no momento Estorno da Viagem Express
Static lTM144EXC	:= ExistBlock("TM144EXC")	//-- Confirmnacao da Exclusao da Viagem
Static lTM144CEP	:= ExistBlock("TM144CEP")	//-- Confirmacao do Cep do Cliente
Static lTM144FOPE	:= ExistBlock("TM144FOPE")	//-- Operações de Transporte
Static lTM144LOK	:= ExistBlock("TM144LOK")	//-- Apos a validacao da linha de GetDados
Static lTM144ROK	:= ExistBlock("TM144ROK")	//-- validacao se documento pertence a rota
Static lTM144CLN	:= ExistBlock("TM144CLN")	//-- Permite ao usuario, incluir colunas nos itens.
Static lTM144LOT	:= ExistBlock("TM144Lot")
Static lTM144DOCR	:= ExistBlock('TM144DOCR') //-- Filtra Documentos de Redespacho. 
Static aRetTela	    := {}
Static lAltRom		:= .F.
Static lDigRot      := .F.
Static lTmsRdpU 	 := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA144  ³ Autor ³ Richard Anderson      ³ Data ³26.10.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Viagem  (Mod.2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144(ExpC1, ExpC2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo do Servico                                    ³±±
±±³          ³ ExpC2 = Tipo do Transporte                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144(cServico, cTransp, nInd140, nOpc140)

Local aCores     := {}
Local aRotAdic   := {}
Local cFilMbrow  := ''
Local cFilMbrPE  := ''
Local lTM144ROT  := ExistBlock('TM144ROT')
Local lTM144FIL  := ExistBlock('TM144FIL')
Local aRet       := {}
Local cProgCall  := ''
Local aRentab	 := {}
Local lMapLink   := SuperGetMV("MV_MAPLINK",,.F.)  //Integração Maplink
Local aMaplink   := {}

Private cFiltro    := ''
Private bFiltraBrw
Private cSerTms    := cServico // Tipo do Servico
Private cTipTra    := cTransp  // Tipo do Transporte
Private lLocaliz   := SuperGetMv("MV_LOCALIZ",.F.,"") == 'S'
Private aIndex     := {}

Default nInd140    := 3
Default nOpc140    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROTEÇÃO CONTRA VERSÃO INCOMPATÍVEL NO TMSA141               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistFunc("TMSA141Ver") .Or. TMSA141Ver() < '12.1.17'
	Final("TMSA141.PRW desatualizado! Atualize p/ 10/Out/2017 ou mais recente!")
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROTEÇÃO CONTRA VERSÃO INCOMPATÍVEL NO TMSC080               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistFunc("TMSC080Ver") .Or. TMSC080Ver() < '12.1.17'
	Final("TMSC080.PRW desatualizado! Atualize p/ 10/Out/2017 ou mais recente!")
EndIf

SetKey (VK_F12,{|| Pergunte("TMB144",.T.)})

If Type("aRotina") = "U"
	Private aRotina := MenuD144(cSerTms,cTipTra)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar items no Menu da mBrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTM144ROT
	aRotAdic := ExecBlock("TM144ROT",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

AAdd(aRotina, { STR0014  ,"TMSA140Leg",0,2,0,.F.})  // "Legenda"

//-----------------------------------------------------------------------------
//-- RENTABILIDADE PRÉVIA
//-----------------------------------------------------------------------------
If TableInDic("DL3")
	AAdd(aRentab, { STR0147 ,'A144Rentab',0,3,0 ,.F. }) //-- Simular Rentabilidade
	AAdd(aRentab, { STR0148 ,'A144Rentab',0,5,0,.F. }) 	//-- Excluir Rentabilidade
	
	AAdd(aRotina, { STR0146  , aRentab ,0,6,0,.F.})  	//-- Rentabilidade Prévia
EndIf

If lMaplink .And. TableInDic('DLU') .And. ExistFunc('A144Maplin')
	AAdd(aMaplink, { STR0166 ,'A144Maplin',0,3,0 ,.F. })     //-- Integra maplink
	AAdd(aMaplink, { STR0167 ,'A144Maplin',0,6,0,.F. })   	//-- Consulta maplink
	AAdd(aMaplink, { STR0079 ,'TMSA046Leg',0,6,0,.F. })   	//-- Legenda maplink
	AAdd(aRotina, { STR0165   , aMaplink ,0,6,0,.F. }) 	    //-- Maplink
EndIf

//-- Carrega Pergunta de solicitacao de Coleta
Pergunte("TMB144",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DTQ")
DbSetOrder(nInd140)

AAdd(aCores,{"DTQ_STATUS=='1'",'BR_VERDE'    }) //-- Em Aberto
AAdd(aCores,{"DTQ_STATUS=='5'",'BR_VERMELHO' }) //-- Fechada
AAdd(aCores,{"DTQ_STATUS=='2'",'BR_AMARELO'  }) //-- Em Transito
AAdd(aCores,{"DTQ_STATUS=='4'",'BR_LARANJA'  }) //-- Chegada em Filial.
AAdd(aCores,{"DTQ_STATUS=='3'",'BR_AZUL'     }) //-- Encerrada
AAdd(aCores,{"DTQ_STATUS=='9'",'BR_PRETO'    }) //-- Cancelada

cFilMbrow := "DTQ_FILIAL = '" + xFilial("DTQ") + "' AND DTQ_SERTMS = '" + cSerTms + "' AND DTQ_TIPTRA = '" + cTipTra + "'"

If lTM144FIL
	cFilMbrPE := ExecBlock("TM144FIL",.F.,.F.)
	If(Valtype(cFilMbrPE) = "C") .And. !Empty(cFilMbrPE)
		cFilMbrow+=  " " + cFilMbrPE
	EndIf
EndIf

//Filtra a tela de viagem de acordo com os planejamentos 
//selecionado na gestao de demanda
If IsInCallStack('TMSA153')
	cFilMbrow+=  " " + TMSA153FVG(.F.)[1]
EndIf

If nOpc140 > 0
	//-- Viagem jah deve estar posicionada
	If "TMSA144MNT" $ Upper(AllTrim(aPanAgeTms[2]))
		aRet := TMSA144Mnt( 'DTQ', Recno(), nOpc140 )
	Else
		aRet := &(aPanAgeTms[2])
	EndIf
Else
	//Determina qual a rotina que deve ter a restricao de privilegios validada no menu.
	If 		cServico == StrZero(1,Len(DC5->DC5_SERTMS))	//COLETA
		If 		cTransp == StrZero(1,Len(DC5->DC5_TIPTRA))//RODOVIARIA
				cProgCall := 'TMSA144A'
		ElseIf cTransp == StrZero(2,Len(DC5->DC5_TIPTRA))//AEREA
				cProgCall := 'TMSA144E'
		EndIf
	ElseIf cServico == StrZero(2,Len(DC5->DC5_SERTMS))	//TRANSPORTE
		If 		cTransp == StrZero(1,Len(DC5->DC5_TIPTRA))//RODOVIARIO
				cProgCall := 'TMSA144B'
		ElseIf cTransp == StrZero(2,Len(DC5->DC5_TIPTRA))//AEREO
				cProgCall := 'TMSA144C'
		ElseIf cTransp == StrZero(3,Len(DC5->DC5_TIPTRA))//FLUVIAL
				cProgCall := 'TMSA144G'
		ElseIf cTransp == StrZero(4,Len(DC5->DC5_TIPTRA))//INTERNACIONAL
				cProgCall := 'TMSA144I'				
		EndIf
	ElseIf cServico == StrZero(3,Len(DC5->DC5_SERTMS))	//ENTREGA
		If 		cTransp == StrZero(1,Len(DC5->DC5_TIPTRA))//RODOVIARIA
				cProgCall := 'TMSA144D'
		ElseIf cTransp == StrZero(2,Len(DC5->DC5_TIPTRA))//AEREA
				cProgCall := 'TMSA144F'
		ElseIf cTransp == StrZero(3,Len(DC5->DC5_TIPTRA))//FLUVIAL
				cProgCall := 'TMSA144H'
		ElseIf cTransp == StrZero(4,Len(DC5->DC5_TIPTRA))//INTERNACIONAL
				cProgCall := 'TMSA144J'								
		EndIf
	EndIf
	
	//-- Endereca a funcao de BROWSE
	mBrowse(6,1,22,75,'DTQ',,,,,,aCores,,,,,,,,cFilMbrow,,,,,{|oBrowse| oBrowse:SetMainProc(cProgCall)})
EndIf

SetKey( VK_F12, Nil )

Return Aclone(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144Mnt³ Autor ³ Richard Anderson      ³ Data ³26.10.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua manutencoes no DTQ (Viagem) e DUD (Movto de Viagem) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Mnt()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Mnt( cAlias, nRecno, nOpcx, lConfirma )

Local oDlg, oEnchoice
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaDTA   := DTA->(GetArea())
Local aAreaDT5   := DT5->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDUE   := DUE->(GetArea())
Local aAreaDUL   := DUL->(GetArea())
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local aVisual    := {}
Local aNoFields  := {}
Local aYesFields := {}
Local aAlter     := {}
Local nOpca      := 0
Local nCntFor    := 0
Local cSeekDUD   := ''
Local cSeekDTC   := ''
Local cSeekDUH   := ''
Local cSeek      := ''
Local lExistDUH  := .F.
Local aCpos      := If(aRotina[nOpcx][4] == 3,Nil,{"DTQ_ROTA","DTQ_OBS"}) //Se Nao for Inclusao, Nao Edita campos da enchoice
Local bVerViagem := {|| TmsA144Viag(nOpcx) }
Local bLimite    := {|| TmsA144Lim(nOpcx)  }
Local bAgenda    := {|| TmsA144Age("DF1",0,2,.T.) }
Local bNFiscal   := {|| TmsA144NFC(nOpcx,@nPosDTQ)  }
Local bSeekFor   := {|| .T. }
Local nSeek      := 0
Local aButtons   := {}
Local aUsButtons := {}
Local nTent      := 0
Local nCount     := 0
Local cMay       := ""
Local cFilOri    := ""
Local cViagem    := ""
Local lRet       := .T.
Local lChgViag   := .F.
Local lCpoOK     := .T.
Local lAberto    := .T.
Local aUsrFields := {}
Local lManViag   := GetNewPar("MV_MANVIAG",.F.) //-- Permite configurar se e possível manifestar uma viagem que ainda nao esta disponivel na filial corrente                       
Local cAtivSai   := GetMV('MV_ATIVSAI',,'')     //-- Atividade de Saida de Viagem
Local oPanel
Local lContVei   := GetMv("MV_CONTVEI")
Local lMV_EmViag := GetMV('MV_EMVIAG',,.F.)
Local cStatus    := ''
Local bRedesp    := {|| Tmsa144Rdp( nOpcx ) }
Local lTMA144But := ExistBlock("TMA144BUT") //-- Permite ao usuario, incluir botoes na enchoicebar.
Local lTM144CLN  := ExistBlock( 'TM144CLN' ) //-- Permite ao usuario, incluir colunas nos itens.
Local nCnt       := 0
Local nPosDTQ    := 0
Local aUsHDocto  := {}
Local lDelLinha  := .T.
Local aAlterBKP  := {}
Local bCodBar    := {|| TM210CodBr()} 
//-- Operadoras de Frota/Vale-Pedagio
Local lTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0'
Local cVsRepom  := SuperGetMV( 'MV_VSREPOM',, '1' )  //-- Versao 2- Contempla nova Legislacao (Encerramento viagem no Posto)
Local cAgenRem  := ''
Local cAgenDes  := ''
Local lAgdEntr  := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega. 
Local aTitDT5   := {}
Local cSerPar   := ''
Local cCodUser  := __cUserID
Local oModelUnit:= Nil //unitizadores
Local lContVia  := .T.
Local lLimGrid  := .F.
Local nCntFor1  := 0
Local aDataBase 	:= {}
Local cUF 			:= SuperGetMV("MV_ESTADO",.F.,"")
Local lHVerao    := SuperGetMV("MV_TMSHRVR",,.F.)	//-- Define se encontra-se no periodo de horario de verao.
Local cHVerFil   := SuperGetMV("MV_TMSHRFL",,"")	//-- Define Filiais que nao aderiram ao horario de verao e/ou possuem diferenca de fuso.
Local cMV_TMSRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lPainel    := IsInCallStack("TMSAF76")
Local lTMS3GFE   := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lCONTDOC	:= SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.
Local lBloqEnt   := .F.
Local cChvExt    := ""
Local aFldAux	 := {}
Local aFldAll	 := {}
Local lTipOpVg   := DTQ->(ColumnPos('DTQ_TPOPVG')) > 0
Local lDTAOrigem := DTA->(ColumnPos('DTA_ORIGEM')) > 0

Local aDocsDUA	 := {}

//--Gestão de demandas
Local lMVITMSDMD   := SuperGetMv("MV_ITMSDMD",,.F.)
Local aRetExVgDm   := {}

Private aHeader    := {}
Private aHeaderEXP := {}
Private aCols      := {}
Private aColsEXP   := {}
Private aColsBKP   := {}
Private aTela[0][0],aGets[0]
Private oGetD      := {}
Private aSetKey    := {}
Private __nDelItem := 0
Private cRotAnt    := ''
Private aDocto     := {}
Private aRota      := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do Array aCompViag (Complemento de Viagem):             ³
//³ aCompViag[1] - aHeader Complemento de Viagem                      ³
//³ aCompViag[2] - aCols Complemento de Viagem                        ³
//³ aCompViag[3] - aHeader Auxiliar Getdados de Motoristas da Viagem  ³
//³ aCompViag[4] - Array contendo os Motoristas da Viagem             ³
//³ aCompViag[5] - aHeader Auxiliar Getdados de Ajudantes da Viagem   ³
//³ aCompViag[6] - Array contendo os Ajudantes da Viagem              ³
//³ aCompViag[7] - aHeader Auxiliar Getdados de Lacres de veiculos    ³
//³ aCompViag[8] - Array contendo os Lacres dos veiculos              ³
//³ aCompViag[9] - aHeader Auxiliar Getdados de Adiantamentos         ³
//³ aCompViag[10]- Array contendo os Adiantamentos da Viagem          ³
//³ aCompViag[11]- Data/Hora Inicial e Final da Viagem                ³
//³ aCompViag[12]- Array contendo os componentes com 'Valor Informado'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCompViag  := {}
Private aRetRbq    := {} //-- Retorno de Reboques
Private lColeta    := (cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)))
Private lTmsCFec   := TmsCFec()
Private aDocRot    := {}
//-- Pergunte    -- 
Private nTipVia    := 1 //-- Normal
Private nCarreg    := 1 //-- Manual
Private lPagSald   := .F.
//-- Variaveis do Rodape da Tela (Dados dos Doctos.)
Private nVolumes   := 0
Private nPesReal   := 0
Private nPesCub    := 0
Private nValMerc   := 0
Private nDoctos    := 0
Private oVolumes   := 0
Private oPesReal   := 0
Private oPesCub    := 0
Private oValMerc   := 0
Private oDoctos    := 0
Private lVgeExpr   := .F.
Private cSerAdi    := ""
Private aRedVge    := {}
Private aHeaderDJN := {}
Private cPagGFEAnt := ""
Private cCdTpOPAnt := ""
Private cCdClFrAnt := ""
Private cTipVeiAnt := ""
Private lPrcMerNpr := .F. //-- Indica se é um processo de retirada de mercadoria não prevista
Private lTM144BKP := ExistBlock('TM144BKP')
Private cRotaInf   := ""
Private cTipOpVgAnt:= ""


/*If IsInCallStack("TMSAF76")
	//--Chama Função do TMSAF12 que retornará a rota utilizada
	If Type("__aRotAut") == "U" .OR. Empty(__aRotAut)
		Private __aRotAut := TF12RetRot(2)
	EndIf
EndIf*/

DEFAULT lConfirma  := .T.

If aRotina[nOpcx][4] == 4 .And. DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))  //Viagem em aberto
    If (lTMS3GFE .Or. lTmsRdpU)  
		AAdd( aCpos, 'DTQ_PAGGFE' )
		AAdd( aCpos, 'DTQ_TPFRRD' )
		AAdd( aCpos, 'DTQ_UFORI' )
		AAdd( aCpos, 'DTQ_CDMUNO' )
		AAdd( aCpos, 'DTQ_MUNORI' )
		AAdd( aCpos, 'DTQ_CEPORI' )
		AAdd( aCpos, 'DTQ_UFDES' )
		AAdd( aCpos, 'DTQ_CDMUND' )
		AAdd( aCpos, 'DTQ_MUNDES' )
		AAdd( aCpos, 'DTQ_CEPDES' )
		AAdd( aCpos, 'DTQ_TIPVEI' )
		AAdd( aCpos, 'DTQ_CDTPOP' )
		AAdd( aCpos, 'DTQ_CDCLFR' )
	EndIf
	If lTipOpVg
		AAdd( aCpos, 'DTQ_TPOPVG' )
		AAdd( aCpos, 'DTQ_DESTPO' )
	EndIf
EndIf

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If aRotina[nOpcx][4] != 3
	If !TMSAVerAge("6",,,,,,,,,,,,"2",.T.,.T.,,DTQ->DTQ_VIAGEM,)
		Return .F.
	EndIf
EndIf

Pergunte("TMB144",.F.)
If Type("MV_PAR02") == "C"
	cSerPar := MV_PAR02
EndIf

lConfirma := IiF(ValType(lConfirma) == "L",lConfirma,.T.)

//--PE - Permite modificar os campos a alterar na enchoice
If nOpcx == 4 .And. lTM144CPO
	aCpos := ExecBlock( 'TM144CPO', .F., .F., {aCpos} )
EndIf

/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
If nOpcx == 4 .Or. nOpcx == 5//-- 4=Alteracao ; 5=Exclusao
	If !SoftLock("DTQ")
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf
EndIf

If TmsExp() .And. !lColeta
	If IsInCallStack("TMSA143C") .Or. IsInCallStack("TMSA143B") .Or. IsInCallStack("TMSF76VIA") 
		aButtons := {	{"CARGA"    , bVerViagem	, STR0015 , STR0017 },; //"Complemento de Viagem - <F4>"###"Comp.Via" 
					{"BMPVISUAL" 	, bLimite   	, STR0016 , STR0018 },; //"Limite - <F5>"###"Limite"
					{"CODBAR"	   	, bCodBar	 	, STR0111 , STR0112 }} 	// "Leitura por Cod.Barras <F8>"
	Else
		aButtons := {	{"CARGA"    , bVerViagem	, STR0015 , STR0017 },;  //"Complemento de Viagem - <F4>"###"Comp.Via" 
					{"BMPVISUAL" 	, bLimite   	, STR0016 , STR0018 },;  //"Limite - <F5>"###"Limite"
					{"DESTINOS"  	, bNFiscal  	, STR0047 , STR0048 },;	 //"NF Cliente - <F7>"###"NF Cliente"
					{"CODBAR"	   	, bCodBar	 	, STR0111 , STR0112 }} 	 // "Leitura por Cod.Barras <F8>"
	EndIf						
Else
	aButtons := {	{"CARGA"     	, bVerViagem	, STR0015 , STR0017 },;  //"Complemento de Viagem - <F4>"###"Comp.Via" 
					{"BMPVISUAL" 	, bLimite   	, STR0016 , STR0018 },;  //"Limite - <F5>"###"Limite"
					{"CODBAR"	   	, bCodBar	 	, STR0111 , STR0112 }} 	 // "Leitura por Cod.Barras <F8>"

	If !lColeta .And. FindFunction("A350RetDTW")
		If aRotina[nOpcx][4] == 4 .And.  ( DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) .Or. DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) )
			AAdd(aButtons, {'DESTINOS', bNFiscal, STR0047, STR0048 }) //"NF Cliente - <F7>"###"NF Cliente"
		EndIf
	EndIf

EndIf
AAdd(aButtons, {'DEVOLNF',{||TMSViewDoc(aCols[n][GdFieldPos('DTA_FILDOC')],aCols[n][GdFieldPos('DTA_DOC')],aCols[n][GdFieldPos('DTA_SERIE')]) }, STR0028, STR0029 }) //"Documento"

If nOpcx == 2 .And. AliasInDic('DFM')
	AAdd(aButtons,{'CUSTOS'  ,{|| TM99CViag() } , STR0118 , STR0118 }) // Custo da Viagem
EndIf
//-- unitizador
If AliasIndic('DIZ') .And. (cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) .Or. cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)))   //Entrega  ou Coleta
	AAdd(aButtons, {'UNITIZADOR',{|| A141IncUni(nOpcx) },STR0110		}) 
EndIf

//-- RRE - Check List da Viagem
If "3" $ cMV_TMSRRE .And. nOpcx == 2
	AAdd(aButtons, {'RRE',{|| TMSA144RRE() }, STR0116, STR0116	})  //RRE - Check List
EndIf

If (lTMS3GFE .Or. lTmsRdpU) //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
	AAdd(aButtons, {'DJN',{|| TM144RdVge(aCols[n][GdFieldPos('DTA_FILDOC')],aCols[n][GdFieldPos('DTA_DOC')],aCols[n][GdFieldPos('DTA_SERIE')],Iif(nOpcx == 2, ,aCols[n][GdFieldPos('DUD_STATUS')]),nOpcx)   }, STR0127, STR0127	})  //Redespacho da Viagem
	
	AAdd(aButtons, {'GFE',{|| TM144DcGFE(aCols[n][GdFieldPos('DTA_FILDOC')],aCols[n][GdFieldPos('DTA_DOC')],aCols[n][GdFieldPos('DTA_SERIE')]) }, STR0131, STR0131	})  //Docto de Carga - GFE 
EndIf	 

EndFilBrw("DTQ",aIndex)//Limpa o filtro no DTQ para que o usuario possa trabalhar com viagem de todos os tipos de transporte

//-- Atualiza Dicionario Carga Fechada
If lTmsCFec .And. lColeta	
	//-- Botão para visualizar o Agendamento.
	AAdd(aButtons, {'PEDIDO', bAgenda, STR0019 , STR0020 }) //'Agendamento - <F6>'
EndIf


//-- Controle de permissao de acesso a manut. de doctos
If TmsAcesso(,"TMSA500",cCodUser,,.F.)
	If !lColeta .And. ( nOpcx == 3 .Or. nOpcx == 4 )
		//-- Botao para realizar manutencao nos documentos
		AAdd(aButtons, {'PEDIDO', {||Tm144MntDc()} , STR0053 , STR0105 }) //-- Doctos. , Manut. Doctos.
	EndIf
EndIf

//-- Visualizar Roteiro
If AliasIndic('DJF') .And. nOpcx == 2 .And. F11RotRote(DTQ->DTQ_ROTA)
	AAdd(aButtons, {'ROTEI',{||  A144ExPgRt(nOpcx) },STR0138, STR0138	})  //"Visu. Roteiro"
EndIf

//-- Inclui botoes do usuario
If lTMA144But
	If ValType( aUsButtons := ExecBlock( 'TMA144BUT', .F., .F. ) ) == 'A'
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

//-- Array dos campos que podem ser alterados
If cSerTms <> StrZero(2,Len(DC5->DC5_SERTMS))
	AAdd(aAlter, "DUD_SEQUEN" )
EndIf

AAdd(aAlter, "DTA_LOCAL"  )
AAdd(aAlter, "DTA_LOCALI" )
AAdd(aAlter, "DTA_UNITIZ" )
AAdd(aAlter, "DTA_CODANA" )
AAdd(aAlter, "DTA_FILDOC" )
AAdd(aAlter, "DTA_DOC"    )
AAdd(aAlter, "DTA_SERIE"  )

If lDTAOrigem
	AAdd(aAlter, "DTA_ORIGEM"  )
EndIf

If lTmsCFec .And. lColeta
	AAdd(aAlter, "DF1_NUMAGE" )
	AAdd(aAlter, "DF1_ITEAGE" )
EndIf

If lTMS3GFE .Or. lTmsRdpU
	AAdd( aAlter, 'DUD_UFORI' )
	AAdd( aAlter, 'DUD_CDMUNO' )
	AAdd( aAlter, 'DUD_CEPORI' )
	AAdd( aAlter, 'DUD_UFDES' )
	AAdd( aAlter, 'DUD_CDMUND' )
	AAdd( aAlter, 'DUD_CEPDES' )
	AAdd( aAlter, 'DUD_TIPVEI' )
	AAdd( aAlter, 'DUD_CDTPOP' )
	AAdd( aAlter, 'DUD_CDCLFR' )
	AAdd( aAlter, 'DUD_REDESP' )
EndIf

//-- Define se sera possivel abrir novas linhas no Grid
If ExistBlock("TM144Grd")
	lLimGrid := ExecBlock("TM144Grd",.F.,.F.,{1,nOpcx,cSerTMS,cTipTra})
	If Valtype(lLimGrid) != "L"
		lLimGrid := .T.
	EndIf
EndIf
//- Manipulacao dos elementos do aAlter
If ExistBlock("TM144MEA")
	aAlterBKP := aClone(aAlter)
	aAlter := ExecBlock("TM144MEA",.F.,.F.,{aAlter})
	If ValType(aAlter) != "A" .Or. Len(aAlter) <= 0
		aAlter := aClone(aAlterBKP)
	EndIf
EndIf

//-- Array das Teclas de Atalhos
AAdd(aSetKey, { VK_F4 ,  bVerViagem } )
AAdd(aSetKey, { VK_F5 ,  bLimite    } )
AAdd(aSetKey, { VK_F8 ,  bCodBar	 } )
If TmsExp() .And. cSerTms $ "23" .And. lTmsCFec .And. !IsInCallStack("TMSA143C") .And. !IsInCallStack("TMSF76VIA")
	AAdd(aSetKey, { VK_F7 ,  bNFiscal   } )
EndIf
If lTmsCFec .And. lColeta
	AAdd(aSetKey, { VK_F6 ,  bAgenda } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria ou carregas as variaveis de memoria.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias, nOpcx == 3)

//-- Valida se executa o programa de abertura de viagens
If ExistBlock("TM144Ini")
	lContVia := ExecBlock("TM144Ini",.F.,.F.,{nOpcx})
	If Valtype(lContVia) != "L"
		lContVia := .T.
	EndIf
	If !lContVia
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return Nil
	EndIf
EndIf
If nOpcx == 2

	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		TmsA140Par(.F.,nOpcx)
	Else
		TmsA141Par(.F.,nOpcx)
	EndIf

ElseIf nOpcx == 3 //-- Inclusao

	// Ajusta SXE e SXF caso estejam corrompidos.
	cFilOri := M->DTQ_FILORI
	cViagem := M->DTQ_VIAGEM
	cMay    := AllTrim(xFilial('DTQ'))+cFilOri+cViagem
	FreeUsedCode()
	DTQ->( DbSetOrder( 2 ) )
	While DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem)) .Or. !MayIUseCode(cMay)
		ConfirmSx8()
		cViagem := CriaVar("DTQ_VIAGEM")
		FreeUsedCode()
		cMay := AllTrim(xFilial('DTQ'))+cFilOri+cViagem
	EndDo
	M->DTQ_FILORI := cFilOri
	M->DTQ_VIAGEM := cViagem
		
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		If !TmsA140Par(.T.,nOpcx)
			lRet := .F.
		EndIf
	Else
		If !TmsA141Par(.T.,nOpcx)
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .AND. Left(FunName(),7) == 'TMSA153' 
		Help( ,, 'HELP',, STR0157, 1, 0,,,,,, {STR0158} ) //"A rotina de viagem está sendo acessada pela Gestão de Demandas, desta forma somente é exibido viagem com planejamento de demandas. Portanto, após incluir uma nova viagem não será possível visualizá-la através desta rotina." - "Para visualizar a nova viagem é preciso acessar a rotina padrão de viagem diretamente pelo menu."
	EndIf
	
	//-- RollBack (SXE / SXF)
	If !lRet
		If	__lSX8
			RollBackSX8()
		EndIf
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		RestArea( aAreaDTA )
		RestArea( aAreaDT5 )
		RestArea( aAreaDT6 )
		RestArea( aAreaDUE )
		RestArea( aAreaDUL )

		//-- Finaliza Teclas de Atalhos
		TmsKeyOff(aSetKey)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return
	EndIf

	//-- Botão para visualizar os Doc. de Redespacho.
	If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) .And. MV_PAR03 == 5 
		AAdd(aButtons, {'DEVOLNF', bRedesp,STR0100 ,STR0101 } )
	EndIf
	If lTMS3GFE .Or. lTmsRdpU
		cPagGFEAnt:= M->DTQ_PAGGFE
		cCdTpOPAnt:= M->DTQ_CDTPOP
		cCdClFrAnt:= M->DTQ_CDCLFR
		cTipVeiAnt:= M->DTQ_TIPVEI
	EndIf
	If lTipOpVg
		cTipOpVgAnt:= M->DTQ_TPOPVG
	EndIf

	lAltRom:= .F.

ElseIf nOpcx == 4 //-- Alteracao
	//--Verifica se existe um contrato aberto para a viagem junto a Operadora de Frota
	//--Existindo este contrato tentará fazer a exclusão do mesmo
	DTR->(dbSetOrder(1))	
	If 	DTR->(MsSeek(FwxFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM))  .And. DTR->DTR_CODOPE == '01' .And. ;
		DTR->(ColumnPos('DTR_PRCTRA')) .And. !Empty(DTR->DTR_PRCTRA) .And. ;
		DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) 
		If !TmsVldOper(nOpcX, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_PRCTRA, DTR->DTR_CODOPE)
			Return(.F.)
		EndIf
	EndIf

	//-- Determina se o processo de alteração é de retirada de mercadoria não prevista
	If M->DTQ_SERTMS == StrZero(3,Len(M->DTQ_SERTMS)) .And.; //-- Viagem de Entrega
	   M->DTQ_STATUS == StrZero(2,Len(M->DTQ_STATUS)) .AND.; //-- Em Trânsito
	   !F11RotRote(M->DTQ_ROTA)
		lPrcMerNpr := .T.
	EndIf	

	//Nao permite alteração da viagem de transporte caso nao esteja em aberto
	If M->DTQ_STATUS != StrZero(1,Len(M->DTQ_STATUS)) .And.;
	   M->DTQ_STATUS != StrZero(4,Len(M->DTQ_STATUS)) .And.;
	   M->DTQ_SERTMS == StrZero(2,Len(M->DTQ_SERTMS)) 			
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto					
		Return( .F. )
	ElseIf M->DTQ_SERTMS == StrZero(3,Len(M->DTQ_SERTMS)) .And. M->DTQ_STATUS == StrZero(5,Len(M->DTQ_STATUS)) //-- Viagem de Entrega fechada
		
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		
		Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto	
		Return (.F.)
	EndIf
	//-- Botão para visualizar os Doc. de Redespacho.
	If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) .And. M->DTQ_TIPVIA == StrZero(5, Len(DTQ->(DTQ_TIPVIA))) 
		AAdd(aButtons, {'DEVOLNF', bRedesp, STR0100 , STR0101 } )
	EndIf

	//-- Carrega o complemento da viagem
	aCompViag := TmsA240Mnt(,,nOpcx,M->DTQ_FILORI,M->DTQ_VIAGEM,aCompViag,M->DTQ_ROTA,cSerTms,cTipTra,,,,.F.)
		
	//-- Se o parametro MV_MANVIAG (Permite configurar se e possivel manifestar uma viagem que ainda nao esta disponivel na filial corrente)
	//-- estiver habilitado, permitir manutencoes na viagem com Status 'Em Transito'
	cStatus := StrZero(2,Len(DTQ->DTQ_STATUS)) + ";" + StrZero(4,Len(DTQ->DTQ_STATUS))
	If lManViag .And. Posicione('DTQ',2,xFilial('DTQ')+M->DTQ_FILORI + M->DTQ_VIAGEM, "DTQ_STATUS") $ cStatus
		lAberto := .F.
		DTW->(DbSetOrder(4))
		If DTW->(MsSeek(cSeek := xFilial("DTW") + M->DTQ_FILORI + M->DTQ_VIAGEM + cAtivSai + cFilAnt))
			Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI) == cSeek
				//-- Se for operacao de 'Saida' e o Status da Operacao de Saida da Viagem estiver  'Encerrado'
				If	DTW->DTW_CATOPE == StrZero(1,Len(DTW->DTW_CATOPE)) .And. ;
					DTW->DTW_STATUS == StrZero(2,Len(DTW->DTW_STATUS))
					lAberto := .T. //-- Nao permite alterar a Viagem
					Exit
				EndIf
				DTW->(dbSkip())
			EndDo
		EndIf
	EndIf

	//-- Permite manutencoes em viagens com chegada parcial.
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		lChgViag := .T.
	EndIf
	If !TMSChkViag(M->DTQ_FILORI,M->DTQ_VIAGEM,lAberto,.F.,.F.,.T.,.F.,.F.,.F.,,,,lChgViag)
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		If !TmsA140Par(.T.,nOpcx,IsInCallStack("TMSF76VIA"))
			If Type('bFiltraBrw') <> 'U'
				Eval(bFiltraBrw)
			EndIf
			RestArea( aAreaDTQ )
			MsUnLockAll()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( Nil )
		EndIf
	Else
		If !TmsA141Par(.T.,nOpcx,IsInCallStack("TMSF76VIA"))
			If Type('bFiltraBrw') <> 'U'
				Eval(bFiltraBrw)
			EndIf
			RestArea( aAreaDTQ )
			MsUnLockAll()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( Nil )
		EndIf
	EndIf

	//---- Alteracao de uma viagem
	lAltRom:= .F.
	If (M->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS)) .Or. M->DTQ_STATUS == StrZero(4, Len(DTQ->DTQ_STATUS)) .Or. M->DTQ_STATUS == StrZero(5, Len(DTQ->DTQ_STATUS))  )
		If lTMS3GFE .Or. lTmsRdpU  //-- Integracao Viagem TMS x GFE
			//---- Verifica se existe algum Romaneio em Aberto 
			lRet:= TmsGFEDUD(M->DTQ_FILORI,M->DTQ_VIAGEM,,,,.T.,@cChvExt)
			If !lRet   
				If !MsgYesNo(STR0137) //'Não foi possivel reabrir o Romaneio da Viagem. Na inclusao de novos documentos, será gerado um Novo Romaneio no SIGAGFE. Deseja prosseguir (S/N)') 
					Return .F.		 		 				
				EndIf
			EndIf 
			If !Empty(DTQ->DTQ_CHVEXT) .And. DTQ->DTQ_CHVEXT <> cChvExt
				lAltRom:= .T.
			EndIf 
		EndIf  
	EndIf
	cRotAnt   := DTQ->DTQ_ROTA
	nTipVia   := Val(DTQ->DTQ_TIPVIA)
	If lTMS3GFE .Or. lTmsRdpU
		cPagGFEAnt:= DTQ->DTQ_PAGGFE
		cCdTpOPAnt:= DTQ->DTQ_CDTPOP
		cCdClFrAnt:= M->DTQ_CDCLFR
		cTipVeiAnt:= M->DTQ_TIPVEI
	EndIf	
	If lTipOpVg
		cTipOpVgAnt:= M->DTQ_TPOPVG
	EndIf

ElseIf nOpcx == 5 //-- Exclusao
	//--Verifica se existe um contrato aberto para a viagem junto a Operadora de Frota
	//--Existindo este contrato tentará fazer a exclusão do mesmo
	DTR->(dbSetOrder(1))	
	If 	DTR->(MsSeek(FwxFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM))  .And. DTR->DTR_CODOPE == '01' .And. ;
		DTR->(ColumnPos('DTR_PRCTRA')) .And. !Empty(DTR->DTR_PRCTRA) .And. ;
		DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) 
		If !TmsVldOper(nOpcx, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_PRCTRA, DTR->DTR_CODOPE)
			Return(.F.)
		EndIf
	EndIf
	//Valida a exclusão de uma viagem caso haja outra viagem coligada a ela. 
	dbSelectArea("DTR")
	DTR->(DbSetOrder(2))
	If	DTR->(MsSeek(xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM))
		Help('',1,'TMSA14422',,STR0021 +  DTR->DTR_FILORI + STR0022 + DTR->DTR_VIAGEM,4,1)
		RestArea( aAreaDTQ )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf

	//Valida se existe Movimento de Caixinha
	If TMSDespCx(M->DTQ_FILORI,M->DTQ_VIAGEM)
		Help('',1,'TMSA14419') //-- "Viagem contem despesas lançadas",Favor excluir a(s) operação(ões)","no Movimento do Caixinha"
		RestArea( aAreaDTQ )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf
	//-- Valida se a viagem de coleta esta em transito. As outras validacoes sera executa na TMSChkViag().
	If M->DTQ_STATUS != StrZero(1,Len(DTQ->DTQ_STATUS)) //-- 1=Em Aberto;5=Fechada;2=Em Transito;4=Chegada em Filial / Cliente;3=Encerrada;9=Cancelada
		Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf
	//-- Somente permite manutencoes em viagens em aberto, em transito ou chegada parcial
	If !TMSChkViag(M->DTQ_FILORI,M->DTQ_VIAGEM,,.F.,.T.,,,,,,,,.F.,.T.,,.T.)
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf
	DTA->(DbSetOrder(2))
	If	DTA->(MsSeek(xFilial('DTA') + M->DTQ_FILORI + M->DTQ_VIAGEM))
		Help('',1,'TMSA14009',,STR0021 + M->DTQ_FILORI + STR0022 + M->DTQ_VIAGEM,4,1)	//-- Ha documentos carregados nesta viagem###"Fil.Origem : "### Viagem : 
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		RestArea( aAreaDTA )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf
	
	//-- Tratamento Rentabilidade/Ocorrencia
	//-- Verifica Se Existe Apontamentos Para Fornecedores No DUA
	If AliasInDic('DJM') .And. DUA->(ColumnPos('DUA_CODFOR')) > 0
	
		DbSelectArea("DUA")
		DbSetOrder(2) //-- DUA_FILIAL+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO
		MsSeek( FWxFilial("DUA") + M->DTQ_FILORI + M->DTQ_VIAGEM , .f.)
		
		While DUA->(!Eof()) .And. (DUA->(DUA_FILIAL+DUA_FILORI+DUA_VIAGEM) == FWxFilial("DUA") + M->DTQ_FILORI + M->DTQ_VIAGEM)
		
			If !Empty(DUA->DUA_CODFOR)
				lRet := .f.
				Exit
			EndIf
			DUA->(DbSkip())
		EndDo

		If !(lRet)
			Help('',1,'TMSA14030',,M->DTQ_FILORI + Space(1) + M->DTQ_VIAGEM,4,1)	//-- "Existem Apontamentos De Ocorrencia Para Fornecedores Nesta Viagem: 
		
			If Type('bFiltraBrw') <> 'U'
				Eval(bFiltraBrw)
			EndIf
			RestArea( aAreaDTQ )
			MsUnLockAll()
			Return( Nil )		
		EndIf
	EndIf
	/* Verifica se solicitacao de coleta possui documento cadastrado  */ 
	If M->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_STATUS)) //-- Coleta
		If T144DocCol(M->DTQ_FILORI, M->DTQ_VIAGEM)
			RestArea( aAreaDTQ )
			MsUnLockAll()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( Nil )
		EndIf
	EndIf
	
	//Verifica se há integração com gestão de demandas e se as coletas vinculadas podem ser canceladas.
	DbSelectArea("DF8")
	DF8->( DbSetOrder( 2 ) ) //-- DF8_FILIAL+DF8_FILORI+DF8_VIAGEM
	If DbSeek(xFilial("DF8") + M->DTQ_FILORI + M->DTQ_VIAGEM)
		If lMVITMSDMD .And. DF8->(ColumnPos('DF8_PLNDMD')) > 0 .And. FindFunction('TMExVgDmd') .And. !IsInCallStack("TMSA146EST")
			aRetExVgDm := TMExVgDmd(DF8->DF8_PLNDMD, 1)
			If !aRetExVgDm[1]
				Help(,, 'HELP',, aRetExVgDm[2], 1, 0)	//Coleta XX/XXXXX/XXX não pode ser cancelada.
				Return( Nil )
			EndIf
		EndIf
	EndIf
	
	If lTM144EXC //-- Confirmacao da Exclusao da Viagem
		lRet := ExecBlock("TM144EXC", .F.,.F.,{nOpcx})
		If ValType(lRet) == 'L' .And. !lRet
			If Type('bFiltraBrw') <> 'U'
				Eval(bFiltraBrw)
			EndIf
			RestArea( aAreaDTQ )
			RestArea( aAreaDTA )
			MsUnLockAll()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( Nil )
		EndIf
	EndIf
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

If nCarreg == 1 .And. lDTAOrigem
	nCntFor := aScan(aAlter, {|x| AllTrim(x) == "DTA_ORIGEM"})
	If nCntFor > 0
		aDel(aAlter, nCntFor)
		aSize(aAlter, Len(aAlter)-1)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campo para visualizacao na Enchoice.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aVisual, "DTQ_FILORI")
AAdd(aVisual, "DTQ_VIAGEM")
AAdd(aVisual, "DTQ_DATGER")
AAdd(aVisual, "DTQ_HORGER")
AAdd(aVisual, "DTQ_ROTA"  )
AAdd(aVisual, "DTQ_DESROT")
AAdd(aVisual, "DTQ_OBS"   )
AAdd(aVisual, "DTQ_IDOPE"   )
AAdd(aVisual, "DTQ_IDCLI")

If DTQ->(ColumnPos("DTQ_KMVGE")> 0)
	AAdd(aVisual, "DTQ_KMVGE"   )
EndIf
If DTQ->(ColumnPos("DTQ_ROTEIR")> 0)
	AAdd(aVisual, "DTQ_ROTEIR")
	AAdd(aVisual, "DTQ_CDRORI")
	AAdd(aVisual, "DTQ_CDRDES")
EndIf

If lTMS3GFE .Or. lTmsRdpU   //-- Integracao Viagem TMS x GFE
	AAdd( aVisual, 'DTQ_PAGGFE' )
	AAdd( aVisual, 'DTQ_TPFRRD' )
	AAdd( aVisual, 'DTQ_UFORI' )
	AAdd( aVisual, 'DTQ_CDMUNO' )
	AAdd( aVisual, 'DTQ_MUNORI' )
	AAdd( aVisual, 'DTQ_CEPORI' )
	AAdd( aVisual, 'DTQ_UFDES' )
	AAdd( aVisual, 'DTQ_CDMUND' )
	AAdd( aVisual, 'DTQ_MUNDES' )
	AAdd( aVisual, 'DTQ_CEPDES' )
	AAdd( aVisual, 'DTQ_TIPVEI' )
	AAdd( aVisual, 'DTQ_DESTIP' )
	AAdd( aVisual, 'DTQ_CDTPOP' )
	AAdd( aVisual, 'DTQ_DSTPOP' )
	AAdd( aVisual, 'DTQ_CDCLFR' )
	AAdd( aVisual, 'DTQ_DSCLFR' )
	AAdd( aVisual, 'DTQ_CHVEXT' )
EndIf

If lTipOpVg
	AAdd(aVisual, "DTQ_TPOPVG")
	AAdd(aVisual, "DTQ_DESTPO")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader e aCols.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSerTms == StrZero(1,Len(DC5->DC5_SERTMS))		//-- Coleta
	AAdd( aYesFields, 'DUD_SEQUEN' )				//-- Sequencia
	AAdd( aYesFields, 'DUD_STATUS' )				//-- Status
	If lTmsCFec .And. lColeta
		AAdd( aYesFields, 'DF1_NUMAGE' )			//-- No.Agendamento
		AAdd( aYesFields, 'DF1_ITEAGE' )			//-- Item Agendamento
	EndIf
	AAdd( aYesFields, 'DTA_FILDOC' )				//-- Fil.Docto.
	AAdd( aYesFields, 'DTA_DOC'    )				//-- No.Docto.
	AAdd( aYesFields, 'DTA_SERIE'  )				//-- Serie Docto.
	AAdd( aYesFields, 'DUE_NOME'   )				//-- Solicitante
	AAdd( aYesFields, 'DUE_BAIRRO' )				//-- Bairro
	AAdd( aYesFields, 'DUE_MUN'    )				//-- Municipio
	AAdd( aYesFields, 'DUE_EST'    )				//-- Estado
	AAdd( aYesFields, 'DT5_DATPRV' )				//-- Data Pre.Col
	AAdd( aYesFields, 'DT5_HORPRV' )				//-- Hora Pre.Col
	AAdd( aYesFields, 'DTA_QTDVOL' )				//-- Qtde.Volume
	AAdd( aYesFields, 'DT6_PESO'   )				//-- Peso Real
	AAdd( aYesFields, 'DT6_PESOM3' )				//-- Peso Cubado
	AAdd( aYesFields, 'DT6_VALMER' )				//-- Vlr. Mercadoria

Else
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))	//-- Transporte
		AAdd( aYesFields, 'DUD_STATUS' )			//-- Status
		AAdd( aYesFields, 'DUD_STROTA' )			//-- Status Rota
	ElseIf cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))	//-- Entrega
		AAdd( aYesFields, 'DUD_SEQUEN' )			//-- Sequencia
		AAdd( aYesFields, 'DUD_STATUS' )			//-- Status
	EndIf
	If	lLocaliz
		AAdd( aYesFields, 'DTA_LOCAL' )				//-- Armazem
		AAdd( aYesFields, 'DTA_LOCALI')				//-- Endereco
			AAdd( aYesFields, 'DTA_UNITIZ')			//-- Armazem
			AAdd( aYesFields, 'DTA_CODANA')			//-- Endereco
	EndIf
	AAdd( aYesFields, 'DTA_FILDOC' )				//-- Fil.Docto.
	AAdd( aYesFields, 'DTA_DOC'    )				//-- No.Docto.
	AAdd( aYesFields, 'DTA_SERIE'  )				//-- Serie Docto.
	If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))	//-- Entrega
		AAdd( aYesFields, 'DT6_NOMREM' )			//-- Nome Remet.
		AAdd( aYesFields, 'DT6_NOMDES' )			//-- Nome Dest.
		AAdd( aYesFields, 'DUE_BAIRRO' )			//-- Bairro
		AAdd( aYesFields, 'DUE_MUN'    )			//-- Municipio
		AAdd( aYesFields, 'DUE_EST'    )			//-- Estado
	EndIf
	AAdd( aYesFields, 'DT5_DATENT' )				//-- Prz.Entrega
	AAdd( aYesFields, 'DTA_QTDVOL' )				//-- Qtde.Volume
	AAdd( aYesFields, 'DT6_VOLORI' )				//-- Qtde.Volume
	AAdd( aYesFields, 'DT6_PESO'   )				//-- Peso Real
	AAdd( aYesFields, 'DT6_PESOM3' )				//-- Peso Cubado
	AAdd( aYesFields, 'DT6_VALMER' )				//-- Vlr. Mercadoria
	If lAgdEntr .And. cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))	//-- Entrega
		AAdd( aYesFields, 'DTA_TIPAGD' )			//-- Tipo do Agendamento de Entrega
		AAdd( aYesFields, 'DTA_DATAGD' )			//-- Data do Agendamento de Entrega
		AAdd( aYesFields, 'DTA_PRDAGD' )			//-- Período do Agendamento de Entrega
		AAdd( aYesFields, 'DTA_INIAGD' )			//-- Início do Agendamento de Entrega
		AAdd( aYesFields, 'DTA_FIMAGD' )			//-- Final do Agendamento de Entrega
	EndIf
EndIf

If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) .And. lDTAOrigem
	AAdd(aYesFields, "DTA_ORIGEM"  )
EndIf

If lTMS3GFE .Or. lTmsRdpU   //-- Integracao Viagem TMS x GFE
	AAdd( aYesFields, 'DUD_UFORI' )
	AAdd( aYesFields, 'DUD_CDMUNO' )
	AAdd( aYesFields, 'DUD_MUNORI' )
	AAdd( aYesFields, 'DUD_CEPORI' )
	AAdd( aYesFields, 'DUD_UFDES' )
	AAdd( aYesFields, 'DUD_CDMUND' )
	AAdd( aYesFields, 'DUD_MUNDES' )
	AAdd( aYesFields, 'DUD_CEPDES' )
	AAdd( aYesFields, 'DUD_TIPVEI' )
	AAdd( aYesFields, 'DUD_DESTPV' )
	AAdd( aYesFields, 'DUD_CDTPOP' )
	AAdd( aYesFields, 'DUD_DSTPOP' )
	AAdd( aYesFields, 'DUD_CDCLFR' )
	AAdd( aYesFields, 'DUD_DSCLFR' )
	AAdd( aYesFields, 'DUD_REDESP' )
	AAdd( aYesFields, 'DUD_CHVEXT' )
EndIf
//-- Inclui colunas do usuario
If lTM144CLN
	If ValType( aUsHDocto := ExecBlock( 'TM144CLN', .F., .F. ) ) <> 'A'
		aUsHDocto := {}
	Else
		For nCnt := 1 To Len(aUsHDocto)
			AAdd( aYesFields, aUsHDocto[nCnt,1] )
		Next nCnt
	EndIf
EndIf

//--PE - Permite alterar a ordem dos campos na Getdados da Viagem
If ExistBlock( 'TMA144OFL' )
	lCpoOK := .T.
	aUsrFields := ExecBlock( 'TMA144OFL', .F., .F.,AClone(aYesFields) )
	If Len(aUsrFields) == Len(aYesFields)
		For nCntFor := 1 to Len(aUsrFields)
			If Ascan( aYesFields ,aUsrFields[nCntFor]) == 0
				lCpoOK := .F.
			Endif
		Next nCntFor
	Else
		lCpoOK := .F.
	Endif
	If lCpoOK
		aYesFields := AClone(aUsrFields)
	Endif
Endif

//-- Titulos da tabela DT5 para Serviço adicional de Coleta
Aadd(aTitDT5,RetTitle('DT5_NOME'))      //Solicitante
Aadd(aTitDT5,RetTitle('DT5_DATPRV'))    //Dat. Pre. Col

cSerAdi := DTQ->DTQ_SERADI
If (nOpcx == 4 .Or. nOpcx == 3) .And. (Empty(cSerAdi) .Or. cSerAdi == '0')
	cSerAdi := cSerPar
EndIf

//-- Quando for o processo de retirada de mercadoria não prevista,
//-- independente do parâmetro que indica serviço adicional, "converte"
//-- para viagem de entrega com serviço adicional de coleta
If lPrcMerNpr
	cSerAdi       := StrZero(1, Len(DTQ->DTQ_SERADI))
	cSerPar       := cSerAdi
	M->DTQ_SERADI := cSerAdi
EndIf

//---- Monta Estrutura DJN - Redespacho da viagem
If lTMS3GFE .Or. lTmsRdpU  //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
	aHeaderDJN :=  {}
	aNoFldsDJN := {'DJN_FILORI', 'DJN_VIAGEM', 'DJN_FILDOC', 'DJN_DOC', 'DJN_SERIE'}
	aFldsDJN := ApBuildHeader("DJN", aNoFldsDJN)
	For nCntFor := 1 To Len(aFldsDJN)
		aAdd(aHeaderDJN, aFldsDJN[nCntFor])
	Next

	aSize(aNoFldsDJN, 0)
	aNoFldsDJN := Nil

	aSize(aFldsDJN, 0)
	aFldsDJN := Nil
EndIf                    	

aFldAux := ApBuildHeader("DUD")
For nCnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nCnt])
Next

aFldAux := ApBuildHeader("DTA")
For nCnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nCnt])
Next

aFldAux := ApBuildHeader("DT6")
For nCnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nCnt])
Next

aFldAux := ApBuildHeader("DT5")
For nCnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nCnt])
Next

aFldAux := ApBuildHeader("DUE")
For nCnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nCnt])
Next

aFldAux := ApBuildHeader("DF1")
For nCnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nCnt])
Next

For nCntFor := 1 To Len(aYesFields)
	If (nCnt := aScan(aFldAll, {|x| AllTrim(x[2]) == AllTrim(aYesFields[nCntFor])})) > 0
		aAdd(aHeader, aFldAll[nCnt])
		If AllTrim(aYesFields[nCntFor]) == 'DT6_NOMREM' .And. cSerAdi == "1"
			aHeader[Len(aHeader)][1] := AllTrim(aFldAll[nCnt][1] + '/ ' + aTitDT5[1])
		ElseIf AllTrim(aYesFields[nCntFor]) == 'DT5_DATENT' .And. cSerAdi == "1"
			aHeader[Len(aHeader)][1] := AllTrim(aFldAll[nCnt][1] + '/ ' + aTitDT5[2])
		Else
			aHeader[Len(aHeader)][1] := AllTrim(aFldAll[nCnt][1])
		EndIf
		aHeader[Len(aHeader)][2] := AllTrim(aFldAll[nCnt][2])
	EndIf
Next

aSize(aFldAux, 0)
aFldAux := Nil

aSize(aFldAll, 0)
aFldAll := Nil

If nOpcx == 3
	//-- Inicializa variavies da viagem
	M->DTQ_SERTMS := cSerTms
	M->DTQ_TIPTRA := cTipTra
	M->DTQ_DATGER := dDataBase
	//-- Busca hora de emissao da viagem
	If	!Empty(cHVerFil) .And. cFilAnt $ cHVerFil
		If	FindFunction("FwTimeUF")		
			cUF := IIF(cUF == "BA", "PE", cUF)
			aDataBase := FwTimeUF(cUF,,lHVerao)			
			M->DTQ_HORGER := StrTran(Left(aDataBase[2],5),':','')
		EndIf
	EndIf
	If Empty(M->DTQ_HORGER) 
		M->DTQ_HORGER := Left(StrTran(Time(),":",""),4)
	EndIf
	M->DTQ_DATGER := dDataBase		

	//-- Montagem do aCols
	If lPainel  
		
		If Type("__cSerAdi") != "C"
			cSerAdi := "2"
		Else
			cSerAdi := __cSerAdi
		Endif

		If Type("aVetReg") == "U"
			aVetReg := {}
		EndIf
		For nCntFor := 1 To Len(aVetReg)
			DUD->(DbGoTo(aVetReg[nCntFor]))
			TmsA144Col(aUsHDocto,nOpcx)
		Next nCntFor
	Else
		AAdd(aCols,Array(Len(aHeader)+1))
		DT6->(DbGoTo(0))
		For nCntFor := 1 To Len(aHeader)
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
		If cSerTms != StrZero(2,Len(DC5->DC5_SERTMS)) //-- Nao for Transporte
			aCols[Len(aCols),1] := StrZero(1,Len(DUD->DUD_SEQUEN))
		EndIf
		aCols[Len(aCols),Len(aHeader)+1] := .F.
	EndIf
Else
	//-- Obtem a descricao da rota
	M->DTQ_DESROT := Posicione('DA8',1,xFilial('DA8')+M->DTQ_ROTA,'DA8_DESC')

	//-- Montagem do aCols
	If !lPainel
		DUE->(DbSetOrder(1)) //DUE_FILIAL+DUE_DDD+DUE_TEL
		DUL->(DbSetOrder(1)) //DUL_FILIAL+DUL_DDD+DUL_TEL+DUL_SEQEND
		DT5->(DbSetOrder(4)) //DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
		DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		DTC->(DbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
		DUD->(DbSetOrder(2)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
		DUD->(MsSeek(cSeekDUD := xFilial('DUD')+M->DTQ_FILORI+M->DTQ_VIAGEM))
		While DUD->(!Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeekDUD)
			TmsA144Col(aUsHDocto,nOpcx)
			//-- Posiciona no documento
			DUD->(dbSkip())
		EndDo
	Else
		If nOpcx == 4 //-- Alteracao
			aColsBKP := AClone(aCols)	
		EndIf	
	
		For nCnTFor1 := 1 To Len(aVetReg)
			DUD->(DbGoTo(aVetReg[nCntFor1]))
			TmsA144Col(,nOpcx)
		Next nCntFor1
	EndIf

	If nOpcx == 4 .And. lDTAOrigem .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) // Viagem em trânsito
		A144InitVal(aHeader , aCols ,  DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM )	
	EndIf  	
EndIf
If ExistBlock("TM144Km2")
	ExecBlock("TM144Km2",.F.,.F.,{nKmVia,nOpcx})
EndIf
aHeaderEXP := AClone(aHeader)
aColsEXP   := AClone(aCols)
If lConfirma

	If !lPainel .And. nOpcx == 4 //-- Alteracao
		aColsBKP := AClone(aCols)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula as dimensoes dos objetos.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize   := MsAdvSize()
	AAdd( aObjects, { 100, 050, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100,05,.T.,.T. } )
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	
	//-- Ajuste do Ponteiro da tabela da GetDados para nao 
	//-- preencher indevidamente campos virtuais na adicao de novas linhas, 
	//-- quando a operacao for de alteracao de registro.
	DT6->(DbGoTo(0))
	DT5->(DbGoTo(0))
	DTA->(DbGoTo(0))
	DUE->(DbGoTo(0))
	DUL->(DbGoTo(0))
	
	lDelLinha := (nOpcx==3.OR.nOpcx==4)
	
	oEnchoice := MsMGet():New( cAlias, nRecno, nOpcx,,,, aVisual  , aPosObj[1],aCpos, 3,,,,,,.T.)
	
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		oGetD := MSGetDados():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3], aPosObj[2,4],nOpcx,'TmsA144LOk()', 'TmsA144TOk()',, lDelLinha,,,,,,,,'TMSA144Del')
	Else
		oGetD := MSGetDados():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3], aPosObj[2,4],nOpcx,'TmsA144LOk()', 'TmsA144TOk()','+DUD_SEQUEN', lDelLinha,,,,,,,,'TMSA144Del')
	EndIf
	
	oGetD:oBrowse:aAlter := AClone(aAlter)  //-- Somente altera os campos contidos no ARRAY

	If ( cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)) .Or. cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) .Or. cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) ) .And. (nTipVia == 2 .Or. nTipVia == 4) .And. (nOpcx == 3 .Or. nOpcx == 4)
		oGetD:nMax := 1  //-- Qtde. de Linhas Viagem Vazia
		aCols[1,Len(aHeader)+1] := .T. //Inicializa GD deletada na Viagem Vazia
	Else
		oGetD:nMax := 9999  //-- Qtde. de linhas
	EndIf

	If lLimGrid .And. lPainel
		oGetD:nMax := Len(aCols)
	EndIf
	
	//-- Campos do Rodape
	oPanel := TPanel():New(aPosObj[3,1],aPosObj[3,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[3,4]), (aPosObj[3,3]), .T.)
	
	@ 005,005 SAY STR0049 SIZE 40,9 OF oPanel PIXEL //--Volumes:
	@ 003,030 MSGET oVolumes VAR nVolumes WHEN .F. SIZE 30,9 OF oPanel PIXEL
	
	@ 005,070 SAY STR0050 SIZE 40,9 OF oPanel PIXEL //--Peso Real
	@ 003,100 MSGET oPesReal VAR nPesReal PICTURE PesqPict("DT6","DT6_PESO") WHEN .F. SIZE 50,9 OF oPanel PIXEL
	
	@ 005,160 SAY STR0051 SIZE 40,9 OF oPanel PIXEL //--Peso Cubado
	@ 003,195 MSGET oPesCub VAR nPesCub PICTURE PesqPict("DT6","DT6_PESOM3") WHEN .F. SIZE 50,9 OF oPanel PIXEL
	
	@ 005,255 SAY STR0052 SIZE 40,9 OF oPanel PIXEL //--Vlr. Merc.
	@ 003,285 MSGET oValMerc VAR nValMerc PICTURE PesqPict("DT6","DT6_VALMER") WHEN .F. SIZE 50,9 OF oPanel PIXEL
	
	@ 005,345 SAY STR0053 SIZE 50,9 OF oPanel PIXEL //--Doctos.
	@ 003,365 MSGET oDoctos VAR nDoctos WHEN .F. SIZE 20,9 OF oPanel PIXEL
	
	If nOpcx <> 3 .or. lPainel
		//-- Atualizando o Rodape
		TMSA210Rdp()
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If(oGetD:TudoOk(), oDlg:End(), nOpca := 0)},{|| ;
	If(lVgeExpr, (Help(' ', 1, 'TMSA14424') /*"Viagem já gravada!"*/, oDlg:End()), oDlg:End()) },, aButtons )	
	
Else
	nOpca := 1
EndIf

If nOpcx != 2
	If nOpca == 1
		If nOpcx == 5
			For nCntFor := 1 To Len(aCols)
				aAdd(aDocsDUA, {aCols[nCntFor][GdFieldPos('DTA_FILDOC')], aCols[nCntFor][GdFieldPos('DTA_DOC')], aCols[nCntFor][GdFieldPos('DTA_SERIE')]})
			Next
			//Verifica se existe uma ocorrência apontada para os documentos.
			If ExistFunc("TMSDocOcor") .AND. !TMSDocOcor(aDocsDUA, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
				MsUnLockAll()
				Return .F.
			EndIf
		EndIf

		Processa({|| TmsA144Grv( nOpcx, lVgeExpr, .F., aColsBKP,@nPosDTQ)}, STR0023 ) //"Aguarde...."
		
		If nPosDTQ >0
			aAreaDTQ[3] := nPosDTQ
		EndIf

		If lVgeExpr .And. !lColeta .And. nOpcx != 5

			cCadastro := STR0041 // Fechamento de Viagem

			DTQ->(DbSetOrder(2))
			DTQ->(MsSeek(xFilial('DTQ')+M->DTQ_FILORI+M->DTQ_VIAGEM))

			If DTQ->DTQ_STATUS <> StrZero(2,Len(DTQ->DTQ_STATUS))
				//Fecha a Viagem
				Pergunte("TMB144",.F.)
				TMSA310Mnt('DTQ',0,3,,(mv_par01==1))
			EndIf
		EndIf
	ElseIf nOpca == 0 .And. TmsExp() .And. !lColeta
		If	__lSX8
			RollBackSX8()
		EndIf
	Else
		If	__lSX8
			RollBackSX8()
		EndIf
		
		//Destravar os documentos quando cancelar a operacao
		If Len(aCols) > 0
			For nCntFor := 1 To Len(aCols)
				UnLockByName("VGEDOC" + aCols[nCntFor][GdFieldPos('DTA_FILDOC')] + aCols[nCntFor][GdFieldPos('DTA_DOC')] + aCols[nCntFor][GdFieldPos('DTA_SERIE')],.T.,.F.)
			Next nCntFor
		EndIf
	EndIf
		If Len(aCompViag) > 0 //-- Se foi preenchido o Complemento de Viagem
		If lContVei .Or. lMV_EmViag
				//--Destravar os veiculos e reboques no cancelamento
				If Len(aCompViag[2]) > 0
					For nCntFor := 1 To Len(aCompViag[2])
						UnLockByName("VGEVEI" + aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODVEI'})],.T.,.F.)
						UnLockByName("VGERB1" + aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB1'})],.T.,.F.)
						UnLockByName("VGERB2" + aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB2'})],.T.,.F.)
							UnLockByName("VGERB3" + aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB3'})],.T.,.F.)
					Next nCntFor
				EndIf
				//--Destravar os motoristas no cancelamento
				If Len(aCompViag[4]) > 0
					For nCntFor := 1 To Len(aCompViag[4])
						For nCount := 1 To Len(aCompViag[4][nCntFor][2])
							UnLockByName("VGEMOT" + aCompViag[4][nCntFor][2][nCount][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CODMOT'})],.T.,.F.)
						Next nCount
					Next nCntFor
				EndIf
			EndIf
			//--Destravar os ajudantes no cancelamento
			For nCntFor := 1 To Len(aCompViag[6])
				For nCount := 1 To Len(aCompViag[6][nCntFor][2])
					UnLockByName("VGEAJU" + aCompViag[6][nCntFor][2][nCount][Ascan(aCompViag[5],{|x| x[2] == 'DUQ_CODAJU'})],.T.,.F.)
				Next nCount
			Next nCntFor
		EndIf
	
	//--- Destruir o modelo do Controle de Unitizadores
	If AliasIndic('DIZ')
		If nOpca == 0 .And. nOpcx <> 2
			oModelUnit:=FwModelActive()
			If oModelUnit <> Nil .And. oModelUnit:cID == 'TMSA148'   
				oModelUnit:DeActivate()
				oModelUnit:Destroy()
			EndIf
		EndIf
		If FindFunction("A141LmpMdl")
			A141LmpMdl()
		EndIf	
	EndIf	
	//Limpa modelo de dados DJM - Fornecedores Adicionais
	Iif(AliasIndic('DJM') .And. FindFunction("A141LmpDJM"), A141LmpDJM(), )
	aDocRot := {}
EndIf
If Type('cFilOri76') <> 'U'
	cFilOri76 := M->DTQ_FILORI
EndIf
If Type('cViagem76') <> 'U'
	cViagem76 := M->DTQ_VIAGEM
EndIf
If Type('bFiltraBrw') <> 'U'
	Eval(bFiltraBrw)
EndIf

RestArea( aAreaDTA )
RestArea( aAreaDT5 )
RestArea( aAreaDT6 )
RestArea( aAreaDUE )
RestArea( aAreaDUL )
RestArea( aAreaDTQ )

//-- Nao chama novamente a tela, qd for inclusao
MBRCHGLoop()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return( { nOpca, M->DTQ_FILORI, M->DTQ_VIAGEM } )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144LOk³ Autor ³ Richard Anderson      ³ Data ³18.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha de GetDados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144LOk()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144LOk()

Local lRet     := .T.
Local lPainel:= IsInCallStack("TMSF76Via")
Local lBloqEnt := .F.   //-- Utilizada para validar digitacao de documentos de entrega, quando Servico Adicional de coleta esta ativo
Local lAgdEntr	   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) //-- Agendamento de Entrega
Local cFilDoc	  := GDFieldGet('DTA_FILDOC', n )
Local cDoc		  := GDFieldGet('DTA_DOC'   , n )
Local cSerie	  := GDFieldGet('DTA_SERIE' , n )
Local lMostrouHelp := .F.
Local lTMS3GFE   := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)

//-- Parametro para controle de Transações da Viagem mod2,
//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.     
Local lCONTDOC := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")
Local cQuery	 := ""
Local cAlias	 := ""
Local lDTAOrigem := DTA->(ColumnPos('DTA_ORIGEM')) > 0

//-- Indica se é um processo de retirada de mercadoria não prevista
If Type("lPrcMerNpr") == "U"
	Private lPrcMerNpr := .F.
EndIf

//-- Serviço Adicional
If Type("cSerAdi") == "U"
	Private cSerAdi := ""
EndIf
lBloqEnt := cSerAdi $ ('1/3') .And. (M->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS)) .Or. M->DTQ_STATUS == StrZero(5, Len(DTQ->DTQ_STATUS)) )

If !GDDeleted(n)
	//-- Inibir a validação padrão do sistema para permitir a criação de novas viagens sem conhecimento emitido.
	If lTM144GOk
		lRet := ExecBlock('TM144GOk',.F.,.F.)
	ElseIf !lPainel
		If Empty(GdFieldGet('DTA_FILDOC',n)) .Or. Empty(GdFieldGet('DTA_DOC',n)) .Or. Empty(GdFieldGet('DTA_SERIE',n))
			Help("  ",1,"OBRIGAT2")
			lRet := .F.
		EndIf
		// Valida o Agendamento
		If lRet .AND. lAgdEntr
			DUD->(DbSetOrder(1))
			If DUD->(MsSeek(xFilial("DUD")+GdFieldGet('DTA_FILDOC',n)+GdFieldGet('DTA_DOC',n)+GdFieldGet('DTA_SERIE',n)))
				If DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) )
					aValAgend := TMSAgdVgVl(GdFieldGet('DTA_FILDOC',n),GdFieldGet('DTA_DOC',n),GdFieldGet('DTA_SERIE',n),dDataBase,SubStr(Time(),1,5) )
					If !aValAgend[1] .And. !IsInCallStack ("TmsA144TOk")
						If !MsgNoYes( aValAgend[2] +chr(13)+chr(10)+ STR0107 , STR0108 + GdFieldGet('DTA_FILDOC',n) +"/"+ GdFieldGet('DTA_DOC',n) +"/"+ GdFieldGet('DTA_SERIE',n) )//"Deseja continuar ?" -- "Documento: "
							lRet := .F.
						Endif
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet
			If lLocaliz
					lRet := GDCheckKey( { 'DTA_LOCAL', 'DTA_LOCALI', 'DTA_UNITIZ', 'DTA_CODANA' ,'DTA_FILDOC', 'DTA_DOC', 'DTA_SERIE' }, 4 )
			Else
				lRet := GDCheckKey( { 'DTA_FILDOC', 'DTA_DOC', 'DTA_SERIE' }, 4 )
			EndIf
		EndIf
		If lRet
			DUD->(DbSetOrder(1))
			If DUD->(MsSeek(xFilial("DUD")+GdFieldGet('DTA_FILDOC',n)+GdFieldGet('DTA_DOC',n)+GdFieldGet('DTA_SERIE',n)))
				If !SoftLock("DUD")
					lRet := .F.
				ElseIf lBloqEnt .And. DUD->DUD_SERTMS != StrZero(1, Len (DUD->DUD_SERTMS)) .And. DUD->DUD_STATUS == StrZero(1, Len (DUD->DUD_STATUS)) .And.;
				       ! lPrcMerNpr //-- Não deve bloquear se for processo de retirada de mercadoria não prevista
					Help("  ",1,"TMSA14425")
					lRet := .F.	
				EndIf
			EndIf
		EndIf
		If lRet .And. lPrcMerNpr
			//-- Validações para inclusão de CTRC no processo de retirada de mercadoria não prevista
			If GdFieldGet("DUD_STATUS", n) == StrZero(1, Len(DUD->DUD_STATUS)) //-- Em Aberto
				lRet := TmsA144VMe(M->DTQ_FILORI, M->DTQ_VIAGEM, cFilDoc, cDoc, cSerie, aCols, n)
			EndIf
		EndIf
		If lRet .And. (lTMS3GFE .Or. lTmsRdpU)  //-- Integracao Viagem TMS x GFE
			If M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) .And. !Empty(GdFieldGet('DTA_DOC',n)) .And. cSerTms != "2" //Sim
				If Empty(GdFieldGet('DUD_UFDES',n)) 
					Help('',1,"OBRIGAT2",,RetTitle('DUD_UFDES'),04,01)
					lRet:= .F.
				ElseIf Empty(GdFieldGet('DUD_CDMUND',n))
					Help('',1,"OBRIGAT2",,RetTitle('DUD_CDMUND'),04,01)
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		If lRet .And. lTM144LOK		//-- Apos a validacao da linha de GetDados
			lRet:= ExecBlock("TM144LOK",.F.,.F.)
			If Valtype(lRet) # "L"
				lRet:=.T.
			EndIf
		EndIf		
		If lRet .And. lCONTDOC			
			DT6->(DbSetOrder(1))
			If DT6->(dbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
				If DT6->DT6_STATUS $ "B/C"
					Help("  ",1,"TMSA14438")
					Return( .F. )	
				ElseIf DT6->DT6_STATUS == "D"   
					Help("  ",1,"TMSA14437")
					Return( .F. )	
				ElseIf !TmsConTran(GdFieldGet('DTA_FILDOC',n),GdFieldGet('DTA_DOC',n),GdFieldGet('DTA_SERIE',n), .T.)
					Return( .F. )					
				EndIf					
			EndIf 
		EndIf
		If lRet .AND. lDTAOrigem .And. GdFieldGet('DTA_ORIGEM', n) == "3" //Local de Coleta
			cQuery := "SELECT DTC.DTC_NUMSOL "
			cQuery += "FROM " + RetSqlName("DTC") + " DTC "
			cQuery += "WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery +=	"AND DTC.DTC_FILDOC = '" + GdFieldGet('DTA_FILDOC', n) + "' "
			cQuery += 	"AND DTC.DTC_DOC = '" + GdFieldGet('DTA_DOC', n) + "' "
			cQuery += 	"AND DTC.DTC_SERIE = '" + GdFieldGet('DTA_SERIE', n) + "' "
			cQuery += 	"AND DTC.D_E_L_E_T_ = ' ' "
			cQuery += 	"AND DTC.DTC_NUMSOL <> ''"
			cQuery := ChangeQuery(cQuery)
			cAlias := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
			If (cAlias)->(Eof())
				(cAlias)->(dbCloseArea())
				Help(" ", 1, "TMSA14448") //Esta opção é valida somente para Documentos de Transporte gerados a partir de Notas Fiscais vinculadas a uma Solicitação de Coleta - Selecione outra opção.
				Return .F.
			EndIf
			(cAlias)->(dbCloseArea())
		EndIf
	EndIf	
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144TOk³ Autor ³ Alex Egydio           ³ Data ³25.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144TOk()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144TOk()

Local lRet      := .T.
Local nOpcx     := oGetD:nOpc
Local cSeekDUH  := ""
Local nX, cDoc,cFilDoc,cSerie, nSeek
// Indica se existe ponto de entrada para validar manutencao
Local lPontoVld := ExistBlock("TMS144VLD")
Local lTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0'
Local lMotAux   := lTMSOPdg
Local nCntFor   := 0
Local aCodigos  := {}
Local lSerAdi   := .F.
Local aAreaDTY  := {}
Local aAreaDT6  := DT6->(GetArea())
Local lMostrouHelp := .F.
Local lCONTDOC	:= SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.     
Local aVisErr      := {}

Local aHeaderDTR := {}
Local aColsDTR   := {}

// Roteiro
Local aRetPgRt   := {}
Local aRetPag    := {}
Local nTamRote   := 0
Local nCount     := 0
Local nTotalKM   := 0
Local aRotaRotei := {}
Local aInfRoteir := {} 	//--Estados e documentos do roteiro geral.
Local lAliasDJF  := AliasIndic('DJF')
Local cOriRotei	 := ''
Local lRoteiro   := .F.
Local nCntFor1   := 0
Local aDadRot    := {}

// Percurso da Viagem
Local aCab       := {}
Local aItens     := {}
Local aItmPerc   := {} 
Local aEstados   := {} 
Local lDelDoc    := .F.
Local cUfAtu     := ""
Local cRegOriMDF := ""
Local aRet       := {}
Local nOpcPer    := 3
Local aDelDocs   := {}
Local lExbPerc   := .F.
Local lDifPerc   := .F.
Local lConsEstEx := .F. 													//--Considera estados já incluídos no array, quando o estado está em sequencia diferente.
Local cEstado    := ""
Local cCodMun    := ""
Local cUFOri     := ""
Local cUfAnt     := ""
Local cMunMan    := ""
Local nPosMunic  := 0
Local nPosUfOri  := 0
Local lPrevist   := .F.
Local nPosDelDoc := 0
Local nOld       := 0
Local aAreaDUD   := DUD->(GetArea())
Local nPosReg    := 0 
Local laCodigo   := .F.
Local aAreaDA3   := {}
Local cCodVei    := ''
Local cCodRbq1   := ''
Local cCodRbq2   := ''
Local cCodRbq3   := ''
Local cCodMot    := ''

Private aFilOri := Array(5)

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )
//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := TmsA144LOk()
EndIf


//-- Carregamento automatico
If	lRet .And. ( nCarreg > 1 ) .or. IsInCallStack("TMSF76Via")
	If	nOpcx == 3
		If Len(aCompViag) <= 0
			Help( ' ', 1, 'TMSA24002',, STR0022 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)###" Viagem : "
			lRet := .F.
		EndIf
	Else
		DTR->( DbSetOrder( 1 ) )
		If  DTR->( ! MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) ) .And. Len(aCompViag) <= 0
			Help( ' ', 1, 'TMSA24002',, STR0022 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)###" Viagem : "
			lRet := .F.
		EndIf
	EndIf
EndIf

If IsInCallStack("TMSF76Via")
   If Type('lAutCharge') != 'U'
      lAutCharge := (nCarreg > 1)
   EndIf
EndIf
If lRet 
	For nX := 1 To Len(aCols)
		If GDDeleted( nX )
			Loop
		EndIf
		cFilDoc := GdFieldGet('DTA_FILDOC',nX)
		cDoc    := GdFieldGet('DTA_DOC'   ,nX)
		cSerie  := GdFieldGet('DTA_SERIE' ,nX)
		If lLocaliz .And. (nOpcx == 3 .Or. nOpcx == 4)
			DUH->(DbSetOrder(1))
			DTC->(DbSetOrder(3)) //Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto
			
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc, cDoc, cSerie)
				DTC->(MsSeek(xFilial("DTC")+cFilDoc+cDoc+cSerie))
				Do While DTC->( !Eof() ) .And. DTC->DTC_FILIAL+DTC->DTC_FILDOC+DTC->DTC_DOC+DTC->DTC_SERIE == xFilial("DTC")+cFilDoc+cDoc+cSerie
					If DTC->DTC_SERIE == 'PED' .Or. Empty(DTC->DTC_DOC)
						DTC->(dbSkip())
						Loop
					EndIf
					DUH->(MsSeek(cSeekDUH := xFilial("DUH")+cFilAnt+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
					Do While DUH->( !Eof() .And. DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM == cSeekDUH )
						nSeek := Ascan(aCols,{ |x| x[GdFieldPos('DTA_LOCAL')]+ x[GdFieldPos('DTA_LOCALI')]+x[GdFieldPos('DTA_UNITIZ')]+ x[GdFieldPos('DTA_CODANA')] == DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA} )
						If nSeek == 0
							Help(' ', 1, 'TMSA14401',,DUH->DUH_LOCAL + "/" + AllTrim(DUH->DUH_LOCALI) + STR0035 + AllTrim(cDoc) + "/" + AllTrim(cSerie) + STR0036 ,3,1) //"O Armazem/Endereco "
							Return( .F. )
						EndIf
						DUH->(dbSkip())
					EndDo
					DTC->(dbSkip())
				EndDo
			Else
				DbSelectArea("DY4")
				DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
				If DY4->(MsSeek(xFilial("DY4")+cFilDoc+cDoc+cSerie))
					Do While DY4->( !Eof() ) .And. DY4->DY4_FILIAL+DY4->DY4_FILDOC+DY4->DY4_DOC+DY4->DY4_SERIE == xFilial("DY4")+cFilDoc+cDoc+cSerie
						If DY4->DY4_SERIE == 'PED' .Or. Empty(DY4->DY4_DOC)
							DY4->(dbSkip())
							Loop
						EndIf
						DUH->(MsSeek(cSeekDUH := xFilial("DUH")+cFilAnt+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM))
						Do While DUH->( !Eof() .And. DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM == cSeekDUH )
							nSeek := Ascan(aCols,{ |x| x[GdFieldPos('DTA_LOCAL')]+ x[GdFieldPos('DTA_LOCALI')]+x[GdFieldPos('DTA_UNITIZ')]+ x[GdFieldPos('DTA_CODANA')] == DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA} )
							If nSeek == 0
								Help(' ', 1, 'TMSA14401',,DUH->DUH_LOCAL + "/" + AllTrim(DUH->DUH_LOCALI) + STR0035 + AllTrim(cDoc) + "/" + AllTrim(cSerie) + STR0036 ,3,1) //"O Armazem/Endereco "
								Return( .F. )
							EndIf
							DUH->(dbSkip())
						EndDo
						DY4->(dbSkip())
					EndDo
				Endif	
			Endif	
		EndIf
		If !lSerAdi .And. !Empty(cSerAdi) .And. cSerAdi != '0' .And. (nOpcx == 3 .Or. nOpcx == 4)  
			DUD->(DbSetOrder(1)) 
			If DUD->(DbSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie+cFilAnt)) .And. DUD->DUD_SERTMS == cSerAdi  
				lSerAdi := .T.        //-- Possui Servico adicional
			EndIf
		EndIf
		If lRet
			//--- Docto com criterio de rateio A, devera ser informado a rota em branco ou rota com roteiro.
				If DT6->DT6_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) // Solicitacao de Coleta
					If !Empty(DT6->DT6_CODNEG) .And. !Empty(DT6->DT6_SERVIC) 
						cCriRat:= TMSA144DcR(DT6->DT6_NCONTR,DT6->DT6_CODNEG,DT6->DT6_SERVIC)
							
						If cCriRat == "A" //-- 'A' = Origem/Destino Vge
							If !Empty(M->DTQ_ROTA)  .And. !F11RotRote(M->DTQ_ROTA)
								//Nao é permitido informar Rota por Cep/Cliente.  /  com Criterios de Rateio:
								Aadd(aVisErr,{STR0123 + " - " + STR0028 + ": " + cFilDoc + " - " + cDoc + " - " + cSerie + " " + STR0124 + cCriRat + " = " + TMSValField('cCriRat',.F.) }) 
								lRet:= .F.
							EndIf
						EndIf
					EndIf
				EndIf				
			EndIf				
		If lRet .And. lCONTDOC
			DT6->(DbSetOrder(1))
			If DT6->(dbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
				If DT6->DT6_STATUS $ "B/C"
					Help("  ",1,"TMSA14438")
					Return( .F. )	
				ElseIf DT6->DT6_STATUS == "D"   
					Help("  ",1,"TMSA14437")
					Return( .F. )	
				ElseIf !TmsConTran(GdFieldGet('DTA_FILDOC',n),GdFieldGet('DTA_DOC',n),GdFieldGet('DTA_SERIE',n), .T.).And. !lMostrouHelp
					Return( .F. )	
				ElseIf !TmsConTran(GdFieldGet('DTA_FILDOC',n),GdFieldGet('DTA_DOC',n),GdFieldGet('DTA_SERIE',n), .F.)									
				EndIf					
			EndIf 
		EndIf
	Next nX
	If Len(aVisErr) > 0
		TmsMsgErr(aVisErr)
		Return( .F. )	
	EndIf
EndIf

//-- Quando for ulitizada Operadoras de Frota/Vale-Pedagio,
//-- atualiza os dados da base de dados da Opeardora.
If nOpcx == 3 .Or. nOpcx == 4
	If lRet .And. lTMSOPdg .And. !Empty(aCompViag)
		If Len(aCompViag[11]) >= 7.And. !Empty(aCompViag[11,7])
			aAreaDA3:= DA3->(GetArea())

			For nCntFor := 1 To Len(aCompViag[2])
				If !aCompViag[2][nCntFor][Len(aCompViag[1])+1]
				
					cCodVei  := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODVEI'})]
					cCodMot  := aCompViag[4][nCntFor][2][1][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CODMOT'})]		
					cCodRbq1 := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB1'})]
					cCodRbq2 := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB2'})]
					cCodRbq3 := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB3'})]

					DA3->(DbSetOrder(1))
					If DA3->(MsSeek( xFilial('DA3')+cCodVei ))
						laCodigo := .F.
						If lMotAux .And. aCompViag[4][nCntFor][2][1][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CONDUT'})]  == "1"
							laCodigo := .T.
						ElseIf !lMotAux
							laCodigo := .T.
						EndIf
						If laCodigo
							If ExistFunc('RepRetCod')
								RepRetCod(cCodVei, cCodRbq1, cCodRbq2, cCodRbq3, cCodMot, @aCodigos)
							Else
								lRet:= .F.
								Exit
							EndIf		
						EndIf	
					EndIf
				EndIf
			Next
			RestArea(aAreaDA3)

			If !lRet
				Help( ,, 'HELP',, 'Favor atualizar o Fonte TMSREPOM.PRW !' , 1, 0)	
			Else
				CursorWait()
				MsgRun(	STR0081,; //-- "Atualizando dados na Operadora de Frotas/Vale-Pedagio..."
						STR0023,; //-- "Aguarde..."
						{||  lRet := TMSAtualOp( aCompViag[11, 7], '5', aCodigos )}) 
				CursorArrow()
			EndIf	
		EndIf
	EndIf
EndIf

aAreaDTY := GetArea()
DTY->( DbSetOrder( 2 ) )
If	lRet .And. DTY->(MsSeek(xFilial('DTY') + M->DTQ_FILORI + M->DTQ_VIAGEM)) .And. DTY->DTY_FILORI == cFilAnt
	If F11RotRote(M->DTQ_ROTA) .Or. (M->DTQ_ROTA <> DTQ->DTQ_ROTA)   //Rota com Roteiro nao pode ser alterado
		Help(' ', 1, 'TMSXFUNA06')	//-- Manutencoes nao sao permitidas em viagens que ja tenham contrato de carreteiro
		lRet := .F.
	EndIf	
EndIf
RestArea(aAreaDTY)


If nOpcx == 5  // Excluindo um Viagem , verificar se existe despesas para este documento // caso exista nao excluir viagem
	If TMSDespCx(M->DTQ_FILORI,M->DTQ_VIAGEM)
		Help('',1,'TMSA14419') //-- "Viagem contem despesas lançadas",Favor excluir a(s) operação(ões)","no Movimento do Caixinha"
		lRet := .F.
	EndIf
	If lTMSOPdg .And. cVsRepom == '2'
	//-- Se o titulo ja foi baixado, nao permite a exclusao da viagem. O cancelamento da baixa deverá ser efetuada manualmente.
		DTR->(DbSetOrder(1))
		If  DTR->(MsSeek(xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM)) .And. DTR->DTR_CODOPE == '01'
			SDG->(DbSetOrder(5))
			If SDG->(MsSeek(xFilial('SDG')+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI ))
				While SDG->(!Eof()) .And. SDG->DG_FILIAL + SDG->DG_FILORI + SDG->DG_VIAGEM + SDG->DG_CODVEI == xFilial('SDG')+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI  
					If SDG->DG_ORIGEM == 'DTR'
						If !Empty(SDG->DG_BANCO)
							cPrefixo := TMA250GerPrf(cFilAnt)
							SE2->(DbSetOrder(1))
							If SE2->(MsSeek(xFilial('SE2')+cPrefixo+Padr(M->DTQ_VIAGEM,Len(SE2->E2_NUM))+SDG->DG_PARC))
								If !Empty(SE2->E2_BAIXA)
									Help(" ", 1,"TMSA07010")
									lRet:= .F.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
					SDG->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

If lSerAdi
	M->DTQ_SERADI := cSerAdi
Else
	M->DTQ_SERADI := StrZero(0, Len(DTQ->DTQ_SERADI))

EndIf
If IsInCallStack('TMSF76Via')
	lConfirma:= lRet
EndIf

// Executa ponto de entrada para validacao
If lRet .And. lPontoVld
	lRet:=ExecBlock("TMS144VLD",.F.,.F.,{nOpcx})
	If Valtype(lRet) # "L"
		lRet:=.T.
	EndIf
EndIf

lDigRot := .F.

If lAliasDJF .And. lRet .AND. cSerTms != "2" .AND. (nOpcx == 3 .Or. nOpcx == 4) // Diferente de Transferencia 

	lRoteiro := Empty(M->DTQ_ROTA) .Or. F11RotRote(M->DTQ_ROTA)
	
	// Executa pagadores e Roteiro
	aRetPgRt := A144ExPgRt(nOpcx,AClone(aColsBKP),lRoteiro)

		If nOpcx == 3
			lDigRot := !Empty(M->DTQ_ROTA)
		Else
			lDigRot := M->DTQ_ROTA != DTQ->DTQ_ROTA
		EndIf

	aRetTela := {}
	If Len(aRetPgRt) > 0
		lRet    := aRetPgRt[1]
		aRetPag  := aRetPgRt[2]
		aRetTela := aRetPgRt[3]
		
		If lRoteiro
			//--Chama Função do TMSAF12 que retornará a rota utilizada
			aRotaRotei := {}
			aRotaRotei := TF12RetRot(2)
		EndIf
	Else
		lRet    := .F.
	EndIf
	
	If lRoteiro				
		If !Empty(aRotaRotei) .AND. lRet
			//--Busca a rota do roteiro geral, identificada pelo codigo do devedor em branco
			M->DTQ_ROTA 	:= aRotaRotei[1,1]
			M->DTQ_DESROT := Posicione("DA8",1,xFilial("DA8") + aRotaRotei[1,1],"DA8_DESC")
				M->DTQ_ROTEIR := aRotaRotei[1,2]

				//-- Recalcula pedágio por conta de não existir rota e roteiro na montagem do complemento da viagem
				//-- Salva aHeader e aCols anterior
				aHeaderDTR := Aclone(aHeader)
				aColsDTR   := Aclone(aCols)
				nOld       := n
				//-- Cria variaveis para compatibilizacao das rotinas
				aHeader    := Aclone(aCompViag[1])
				aCols      := Aclone(aCompViag[2])
				lCalPedg   := .T.
				cRota      := M->DTQ_ROTA
				cSerTMSVge := M->DTQ_SERTMS
				cTipTraVge := M->DTQ_TIPTRA
				aFilOri[1] := M->DTQ_FILORI
				aFilOri[2] := M->DTQ_VIAGEM
				aFilOri[3] := M->DTQ_SERTMS
				aFilOri[4] := M->DTQ_TIPTRA
				aFilOri[5] := Val(M->DTQ_TIPVIA)

				n := 1
				M->DTR_VIAGEM := M->DTQ_VIAGEM
				M->DTR_QTDEIX := GdFieldGet("DTR_QTDEIX")
			
				
				//-- Força o Processamento da rotina de complemento para recalcular o pedágio.
				For nCntFor1 := 1 To Len(aCols)
					n := nCntFor1
					If !(GdDeleted(nCntFor1)) 
						TMSA240Vld("M->DTR_QTDEIX")
						aCompViag[2][nCntFor1][GdFieldPos('DTR_VALPDG')] := GdFieldGet("DTR_VALPDG",nCntFor1)
					EndIf
				Next nCntFor1 
			

				//-- Retorna aHeader e aCols anterior
				aHeader := Aclone(aHeaderDTR)
				aCols   := Aclone(aColsDTR)
				n       := nOld

				If DTQ->(ColumnPos('DTQ_RTAORI')) > 0 .And. DTQ->(ColumnPos('DTQ_RTOORI')) > 0
					
					// Grava Rota Original
					If Empty(M->DTQ_RTAORI)
						M->DTQ_RTAORI	 := M->DTQ_ROTA 
					EndIf
					
					// Grava Roteiro Original
					If Empty(M->DTQ_RTOORI)
						M->DTQ_RTOORI := M->DTQ_ROTEIR
					EndIf
				EndIf
				
				aDadRot := TMF10RtVge(M->DTQ_FILORI,M->DTQ_VIAGEM,,,)
				If !Empty(aDadRot)
					DA8->(DbSetOrder(1))
					If DA8->(ColumnPos("DA8_CDRCAL")) > 0 .And. DA8->(DbSeek(xFilial("DA8") + M->DTQ_ROTA)) .And. !Empty(DA8->DA8_CDRCAL)
						M->DTQ_CDRORI := DA8->DA8_CDRORI
						M->DTQ_CDRDES := DA8->DA8_CDRCAL
					Else
						M->DTQ_CDRORI := aDadRot[1,6]
						M->DTQ_CDRDES := aDadRot[1,7]
					EndIf
					M->DTQ_KMVGE  := aDadRot[1,8]
				EndIf
		Else
			Help(' ', 1, 'TMSA144k7') //"Necessário informar a rota, pois os documentos da viagem não foram alterados.
			lRet := .F.
		EndIf
	Else
		TF10GrRote(5,M->DTQ_FILORI, M->DTQ_VIAGEM)
	EndIf

	/*
	If  lRet .AND. cSerTms == "3" .AND. AliasIndic("DL0") .AND. FindFunction("TMSAF16") .AND. lPercurso
		// Rota de Roteiro
		If lAliasDJF .AND. F11RotRote(M->DTQ_ROTA) 
			If .F. .AND. (nOpcx == 3 .Or. nOpcx== 4) //-----------------------------------------> Travado para a primeira entrega da ELLECE
				If nOpcx == 4 .And. M->DTQ_STATUS =='1' //--Se a viagem está aberta, exclui o percurso anterior
					
					If AliasIndic("DL0")
						dbSelectArea("DL0")
						DL0->(dbSetOrder(2))
						If DL0->(MsSeek( FWxFilial("DL0")+M->DTQ_FILORI+M->DTQ_VIAGEM ))
							DL0->(MsSeek( FWxFilial("DL0")+M->DTQ_FILORI+M->DTQ_VIAGEM + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
							DL0->(DbSkip(-1))
							AF16IncPer(5,,,.T.,) // Exclui o Registro.
						EndIf
					EndIf

				EndIf
					
				//--Chama Rotina que retorna todos os estados do roteiro assim como os documentos de cada estado.
				aInfRoteir:= AF11RetInf(M->DTQ_FILORI, M->DTQ_VIAGEM )

				cUfAtu := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_ESTCOB")
				// Ler Documentos e dividir nos estados pelo estado de Destino
				For nCntFor := 1 To Len(aInfRoteir) 
					If nCntFor > 1 
						lConsEstEx := aInfRoteir[nCntFor][ROTESTADO] <> aInfRoteir[nCntFor-1][ROTESTADO]
					EndIf

					If AScan(aEstados, (aInfRoteir[nCntFor][ROTESTADO]) )  <= 0 .Or. lConsEstEx //--Compara com o estado anterior.
						cOriRotei := IIF(aInfRoteir[nCntFor][ROTTIPOPE]<>'1','2','1') //--(1=Apoio;2=Coleta;3=Entrega;4=Col/Ent;5=Transf;6=Filial)
						AAdd( aItens, { {"DL1_SEQUEN"	,	STRZERO(Len(aEstados)+1,2)},;
										{"DL1_UF"	 	,	aInfRoteir[nCntFor][ROTESTADO]} ,;
										{"DL1_UFORIG"	,	cUfAtu } ,;
										{"DL1_ORIGEM"	,	cOriRotei} ,; // Origem - Rota
										{} } ) // Dever ser a ultima posição do Array

						Aadd(aEstados,aInfRoteir[nCntFor][ROTESTADO])		
						nPosEst := Len(aItens)
					ElseIf (aInfRoteir[nCntFor][ROTTIPOPE]) <> '1' 
						aItens[nPosEst][4][2] := '2'					
					EndIf

					nTamEst := Len(aItens[nPosEst])
					aItmPerc := {}
					
					If !Empty(aInfRoteir[nCntFor][ROTFILDOC]+aInfRoteir[nCntFor][ROTDOC]+aInfRoteir[nCntFor][ROTSERIE])

						Aadd(aItmPerc,{"DL2_FILDOC", aInfRoteir[nCntFor,ROTFILDOC]  })
						Aadd(aItmPerc,{"DL2_DOC"   , aInfRoteir[nCntFor,ROTDOC] 	})
						Aadd(aItmPerc,{"DL2_SERIE" , aInfRoteir[nCntFor,ROTSERIE]  	})
						Aadd(aItmPerc,{"DL2_CLIREM", aInfRoteir[nCntFor,ROTCLIREM] 	})
						Aadd(aItmPerc,{"DL2_LOJREM", aInfRoteir[nCntFor,ROTLOJREM] 	})
						Aadd(aItmPerc,{"DL2_CLIDES", aInfRoteir[nCntFor,ROTCLIDES] 	})
						Aadd(aItmPerc,{"DL2_LOJDES", aInfRoteir[nCntFor,ROTLOJDES] 	})																				
		
						Aadd(aItens[nPosEst][nTamEst],aItmPerc)

					EndIf
					
				Next nCntFor
			EndIf			
		EndIf
		
	EndIf
	*/
	
EndIf
RestArea( aAreaDT6 )
RestArea( aAreaDUD )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144Grv³ Autor ³ Richard Anderson      ³ Data ³29.10.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua a gravacao da viagem                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Mnt( ExpN1, ExpL2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do aRotina.                                  ³±±
±±³          ³ ExpL1 = Indica que esta usando o modo de Viagem express.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Grv( nOpcx, lVgeExpr, lGrvSDG, aColsBKP,nPosDTQ,aHeaderEXP)

Local cAliasNew   := GetNextAlias()
Local cAliasLot   := GetNextAlias()
Local cAliasDUD   := GetNextAlias()
Local cQuery      := ''
Local lRet        := .T.
Local aArea       := GetArea()
Local nX          := 0
Local nQtdVol     := 0
Local nPeso       := 0
Local nPesoM3     := 0
Local nValMer     := 0
Local nPosSequen  := 0
Local nPosFilDoc  := 0
Local nPosDocto   := 0
Local nPosSerie   := 0
Local lTMSExp     := SuperGetMv("MV_TMSEXP", .F., .F.)
Local nTamViag	:= TamSx3("DTP_VIAGEM")[1]
Local TOTREG		:= 0
Local lRotAut    := FindFunction("F11RotRote") .AND. F11RotRote(M->DTQ_ROTA)
Local nTotReg    := 0
Local cAliasT    := GetNextAlias()
Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
Local aCposIni   := {}
Local aZeraVlr   := {}
Local aInfDT8    := {}
Local cNumLot    := ""
Local cContr     := ""

Local aTabRec    := {}         // Recebe as Tabelas e recnos dos registros
Local aDelDocs   := {}         // Recebe os documentos deletados
Local nCntPag    := 0          // Recebe o contador de de registros de renos e tabelas 
Local lDTCPag    := .F.        // Recebe se possui DTC
Local lDT5Pag    := .F.        // Recebe se possui DT5
Local cSrvAdc    := ""         // Recebe se tem serviço adicional
Local aRetPag    := {}         // Recebe o retorno do processamento de pagadores
Local aColsOri   := Iif( Type("aCols") == "A", aClone(aCols), {} )
Local aHeaderOri := Iif( Type("aHeader") == "A", aClone(aHeader), {} )
Local aColsOld   := {}
Local aHeaderOld := {}
Local nCntFor1   := 0
Local lAliasDJF  := AliasIndic('DJF')
Local aRecNoDUD	 := {}			// Painel de Agendamento - Armazena as DUD para atualizar a viagem após a geração do cálculo
Local lCarreg	 := .T.

Local aAreaDTP := DTP->(GetArea())
Local aAreaDA8 := DA8->(GetArea())
Local cErro    := ""
Local bError   := ErrorBlock( {|e| lRet := .F. , cErro :=  e:Description + e:ErrorStack } )
Local aRetPELot := {}
Local cNumLotPE := ""
Local lMapLink  	:= SuperGetMV("MV_MAPLINK",,.F.)
Local oMapLink		:= Nil

Private aBkpDocto := {}
Private aMemos    := {	{ 'DTQ_CODOBS', 'DTQ_OBS' }, { 'DTQ_CODCAN', 'DTQ_OBSCAN' } }
Private cGrpProd  := '' //Usada na rotina Tmsa140Adc()
Private lTM141COL := .F. //Usada na rotina Tmsa140Adc()

If Type('lTelaBloq') == 'U'
	Private lTelaBloq := .F.
EndIf

Default lVgeExpr  := .F.
Default lGrvSDG   := .F.
Default aColsBKP  := {}
Default nPosDTQ   := 0
Default aHeaderEXP := {}

Begin Sequence
	//--Cria o vetor aDocto qdo o Modo de Viagem  Express estiver ativo e qdo Selecionado o botão de digitacao de NF'S. 
	If TmsExp() .And. lVgeExpr .And. Len(aRota) > 0
		//Query para verificar as rotas dos  Doctos Vinculados a viagem.
		cQuery := " SELECT DUD_CDRCAL, Sum(DT6_QTDVOL) QTDVOL, Sum(DT6_PESO) PESO, "
		cQuery += "        Sum(DT6_PESOM3) PESOM3, Sum(DT6_VALMER) VALMER ""
		cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
		cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "     ON  DT6_FILIAL    = '"+xFilial("DT6")+"'"
		cQuery += "     AND DT6_FILDOC    = DUD_FILDOC"
		cQuery += "     AND DT6_DOC       = DUD_DOC"
		cQuery += "     AND DT6_SERIE     = DUD_SERIE"
		cQuery += "     AND DT6_BLQDOC    <> '1'"
		cQuery += "     AND DT6.D_E_L_E_T_    = ' '"
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_FILORI = '" + M->DTQ_FILORI  + "' "
		cQuery += "     AND DUD_VIAGEM = '" + M->DTQ_VIAGEM  + "' "
		cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
		cQuery += "     GROUP BY DUD_CDRCAL "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

		TCSetField(cAliasNew,"QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
		TCSetField(cAliasNew,"PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
		TCSetField(cAliasNew,"PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
		TCSetField(cAliasNew,"VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])

		(cAliasNew)->(DbGoTop())
		While (cAliasNew)->(!Eof())
			If Len(aRota[1]) == 9
				AAdd( aRota[1], {})
			EndIf

			If Ascan( aRota[1,10] ,(cAliasNew)->DUD_CDRCAL) == 0
				AAdd( aRota[1,10], (cAliasNew)->DUD_CDRCAL )
			EndIf

			nQtdVol    += (cAliasNew)->QTDVOL
			nPeso      += (cAliasNew)->PESO
			nPesoM3    += (cAliasNew)->PESOM3
			nValMer    += (cAliasNew)->VALMER
			(cAliasNew)->(DbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())
		RestArea( aArea )

		For nX := 1 To Len(aRota)
			aRota[nX,5] := nQtdVol
			aRota[nX,6] := nPeso
			aRota[nX,7] := nPesoM3
			aRota[nX,8] := nValMer
		Next

		If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) .Or. cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))
			TmsA140Adc( 1, 2, "1", .T. )	//o segundo parametro esta sendo passado como 2(visualizacao) para que a query
		EndIf								//do Tmsa140Adc nao selecione outros registros.
	Else
		//-- Cria os vetores aRota e aDocto
		TmsA144Doc( nOpcx )
	EndIf

	// CASO A OPCAO DE EXECUCAO SEJA Alteracao
	// O PROGRAMA CHECARA SE HOUVE A TROCA DE DOCUMENTOS NO aCols, CHECANDO MUDANCAS NO DOCUMENTO, ENTRE OS 2 VETORES
	If nOpcx == 4 .And. Len(aColsBKP) > 0 //-- Alteracao
		nPosSequen := GDFieldPos("DUD_SEQUEN")
		nPosFilDoc := GDFieldPos("DTA_FILDOC")
		nPosDocto  := GDFieldPos("DTA_DOC"   )
		nPosSerie  := GDFieldPos("DTA_SERIE" )
		For nX := 1 To Len(aColsBKP)
			//-- COMPARAR O ITEM ENTRE OS VETORES E SE O MESMO NAO FOI EXCLUIDO NO VETOR aCols //
			If nPosSequen > 0 .And. aColsBKP[nX][nPosSequen] == aCols[nX][nPosSequen] .And. !aCols[nX][Len(aCols[nX])]
				//-- CHECAR SE O DOCUMENTO FOI ALTERADO //
				If	(aColsBKP[nX][nPosFilDoc] != aCols[nX][nPosFilDoc]) .Or.;
					(aColsBKP[nX][nPosDocto ] != aCols[nX][nPosDocto ]) .Or.;
					(aColsBKP[nX][nPosSerie ] != aCols[nX][nPosSerie ])
					TMSA141Del( aColsBKP[nX][nPosFilDoc], aColsBKP[nX][nPosDocto], aColsBKP[nX][nPosSerie], .T. )
				EndIf
			EndIf
		Next
	EndIf


	//Grava Viagem/Complemento/Carrega Doctos na Viagem
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))
		lRet := TmsA140Grv(nOpcx,lVgeExpr, Iif(((lVgeExpr .And. lGrvSDG) .Or. !lVgeExpr), .F., .T.) ,,,@nPosDTQ)
	Else
		If lVgeExpr .And. nOpcx == 4 
			aHeaderEXP := AClone(aHeader)
			aColsBKP   := aClone(aCols)		
			lRet := TmsA141Grv(nOpcx,lVgeExpr, Iif(((lVgeExpr .And. lGrvSDG) .Or. !lVgeExpr), .F., .T.) ,,, @nPosDTQ)
			aHeader := AClone(aHeaderEXP)
			aCols 	 := aClone(aColsBKP)
		Else
			lRet := TmsA141Grv(nOpcx,lVgeExpr, Iif(((lVgeExpr .And. lGrvSDG) .Or. !lVgeExpr), .F., .T.) ,,, @nPosDTQ)
		EndIf
	EndIf

	//Chama Rotina Para Gerar Manifesto e Contrato de Carreteiro
	If lRet
		If ( nOpcx == 3 .Or. nOpcx == 4 )
			If (( cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))) .Or. ( cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))))//Transportes ou Entrega  
				If nCarreg > 1  //Modo de Carregamento nao manual
					If Empty(DUD->DUD_MANIFE) .Or. nCarreg <> 4
						lRet := Tmsa144GMC(lVgeExpr)
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet .And. TmsExp() .And. nOpcx == 4 		
			
			//Query para verificar se Existem Doctos Vinculados a viagem que nao estejam deletados
			//Esta query pega os documentos que foram do Grid.  
			cQuery := " SELECT DTP_FILORI,DTP_LOTNFC, COUNT(DUD_DOC) TOTREG "
			cQuery += " FROM " + RetSqlName("DTP")+" DTP " 		
			cQuery += " LEFT JOIN "+RetSqlName("DUD")+" DUD ON " 
			cQuery += " (DUD.DUD_FILIAL = '"+xFilial("DUD")+"' AND DUD.DUD_FILORI = DTP.DTP_FILORI AND DUD.DUD_VIAGEM = DTP.DTP_VIAGEM AND DUD.D_E_L_E_T_ = '') "		
			cQuery += " WHERE DTP.DTP_FILIAL   = '" + xFilial("DTP") + "' "
			cQuery += " AND DTP.DTP_FILORI = '" + M->DTQ_FILORI  + "' "
			cQuery += " AND DTP.DTP_VIAGEM = '" + M->DTQ_VIAGEM  + "' "		
			cQuery += " AND DTP.D_E_L_E_T_ = ' ' "				
			cQuery += " GROUP BY DTP_FILORI,DTP_LOTNFC "
			cQuery := ChangeQuery( cQuery )			
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasLot, .F., .T. )		
			//--NÃO ENCONTRANDO DUD VINCULADOS A VIAGEM GRAVADA NO LOTE, SERA APRESENTADA MSG AO OPERADOR
			If (cAliasLot)->(!Eof()) .And. (cAliasLot)->TOTREG == 0		
				If MsgYesNo(STR0120 + ' ' + STR0021 + (cAliasLot)->DTP_FILORI + ' ' + STR0119 + (cAliasLot)->DTP_LOTNFC ) //--Deseja Desvincular a viagem do Lote?,+ 'Filial: ' + DTP->DTP_FILORI + ' ' + 'Lote: ' + DTP->DTP_LOTNFC				
					DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
					If DTP->(DbSeek(xFilial("DTP")+(cAliasLot)->DTP_FILORI +(cAliasLot)->DTP_LOTNFC))
						RecLock("DTP",.F.)
						DTP->DTP_VIAGEM := Space(nTamViag) 	
						DTP->(MsUnlock())
					EndIf		
				EndIf
			EndIf		
			(cAliasLot)->(DbCloseArea())
		EndIf		 
	Endif

	If lAliasDJF .And. lRet .AND. cSerTms != "2" .AND. (nOpcx == 3 .Or. nOpcx == 4) .AND.  M->DTQ_STATUS == StrZero(1, Len(DTQ->DTQ_STATUS))// Diferente de Transferencia 

		//-- abre a tela de viagens e confirma sem documentos

		If ValType(aRetTela) == "A" .AND. Len(aRetTela) > 0 .AND. aRetTela[1] == 1

			TMSF79Lot(aRetTela[4],M->DTQ_FILORI,M->DTQ_VIAGEM,.T.,"2")	//-- Chama criação dos lotes de transferência
			TMSF79Lot(aRetTela[4],M->DTQ_FILORI,M->DTQ_VIAGEM,.T.,"3")	//-- Chama criação dos lotes de entrega

			//-- Chama a digitação de notas fiscais			
			TMSF79Nota(Aclone(aRetTela[4]))

			// Chamada de Ponto de entrada 
			If lTM144LOT
				aRetPELot := ExecBlock("TM144Lot",.F.,.F., Aclone(aRetTela[4]))
				If Valtype(aRetPELot) == "A" .AND. Len(aRetPELot) > 0
					aRetTela[4] := Nil
					ACopy(aRetPELot,aRetTela[4])
				EndIf
			EndIf

			//-- Chama o cálculo dos lotes
			aRecNoDUD	 := {}
			For nCntFor1 := 1 To Len(aRetTela[4])
				If !Empty(aRetTela[4,nCntFor1,19])
					DTP->(DbSetOrder(1))
					If DTP->(DbSeek(xFilial("DTP") + aRetTela[4,nCntFor1,19])) .And. DTP->DTP_STATUS $ "2:4"

						// Painel de Agendamento - Atualiza a tabela de veículos da nota fiscal (DVU) com o veículo da viagem
						IF IsInCallStack("TMSF76Via")
							DbSelectArea("DTC")
							DTC->(dbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC
							If dbSeek(xFilial("DTC") + DTP->(DTP_FILORI + DTP_LOTNFC))
								While !DTC->(EoF())                    .And. ;
									DTC->DTC_FILIAL == xFilial("DTC")   .And. ;
									DTC->DTC_FILORI == DTP->DTP_FILORI .And. ;
									DTC->DTC_LOTNFC == DTP->DTP_LOTNFC
									TmsAltVeic(DTC->DTC_NCONTR, DTC->DTC_CODNEG, DTC->DTC_FILORI, DTC->DTC_LOTNFC, DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_CLIREM,;
										DTC->DTC_LOJREM, M->DTQ_FILORI, M->DTQ_VIAGEM, DTC->DTC_SERTMS, DTC->DTC_TIPTRA, DTC->DTC_SERVIC)
									DTC->(DbSkip())
								EndDo
							EndIf
						EndIf

						If DTP->DTP_STATUS == StrZero(4,TamSx3("DTP_STATUS")[1])
							lRet := TMSA200Rec("DTP",DTP->(Recno()),4,.F.,)
						Else
							lRet := TMSA200Mnt("DTP",DTP->(Recno()),2,,.F.)
						EndIf
						
						cQuery := "SELECT DUD.R_E_C_N_O_ AS DUDRECNO FROM " + RetSqlName("DUD") + " DUD " 
						cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 ON DT6_FILIAL = '" + xFilial("DT6") + "' AND DT6_FILORI = '" + DTP->DTP_FILORI + "' AND DT6_LOTNFC = '" + DTP->DTP_LOTNFC + "' AND DT6.D_E_L_E_T_ = ' ' "
						cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' AND DUD_FILDOC = DT6_FILDOC AND DUD_DOC = DT6_DOC AND DUD_SERIE = DT6_SERIE AND DUD.D_E_L_E_T_ = ' '"
						
						cQuery := ChangeQuery(cQuery)
						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDUD, .F., .T. )
						dbSelectArea((cAliasDUD))
						While (cAliasDUD)->(!Eof())
							If AScan(aRecNoDUD, {|x| x == (cAliasDUD)->DUDRECNO}) <= 0
								AAdd(aRecNoDUD, (cAliasDUD)->DUDRECNO)
							EndIf
							(cAliasDUD)->(dbSkip())
						EndDo
						(cAliasDUD)->(DbCloseArea())
					EndIf
				EndIf
			Next nCntFor1
			
			IF IsInCallStack("TMSF76Via")
				// Quando a viagem é criada pelo painel, a DUD é criada após a gravação da viagem e os dados da viagem são gravados antes na tmsa140grv
				// Desta forma, faz-se necessário gravar os dados da viagem na DUD
				lCarreg := .F.
				For nCntFor1 := 1 To Len(aRecNoDUD)
					dbSelectArea("DUD")
					dbGoTo(aRecNoDUD[nCntFor1])
					RecLock('DUD', .F.)
						DUD->DUD_VIAGEM := M->DTQ_VIAGEM
					MsUnLock()
					
				// Verifica se todos os documento estão carregados. Quando a viagem for estornada ou sofreu uma ocorrência de retorna documento
					// a DUD já existe e o carregamento já foi feito pela TMSA141Crr, desta forma não há necessidade de chamar a rotina TMSF76Crg
					// pois poderá duplicar as operações (DTW)
					dbSelectArea("DTA")
					dbSetOrder(1)
				If !dbSeek(xFilial("DTA") + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE + DUD->DUD_FILORI + M->DTQ_VIAGEM)
						lCarreg := .T.
					EndIf
				Next nCntFor1
				

			If Type('lAutCharge') != 'U' .AND. lAutCharge .And. lCarreg
					lRet := TMSF76Crg()
				EndIf
			EndIf 
			
		EndIf
	EndIf

	//-------------------------------------------------------------------------
	//-- Inicio -> Calcula Valorização Da Viagem De Coleta.
	//-------------------------------------------------------------------------
	//-- Alteração e Status = '2' (Em Transito) Ou '5' (Fechada)
	If lRet .And. nOpcx == 4 .And. ( M->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS)) .Or. M->DTQ_STATUS == StrZero(5, Len(DTQ->DTQ_STATUS)) )

		//-- Coleta/Entrega
		If cSerTMS $ '1/3' 
		
			//-- Substitui Variáveis Para Utilização Das Rotinas De Valorização Da Coleta
			aColsOld   := aCols		//-- Back-Up Para Restaurar Ao Final Do Processamento
			aHeaderOld := aHeader	//-- Back-Up Para Restaurar Ao Final Do Processamento
			aCols      := aColsOri
			aHeader    := aHeaderOri

			//-------------------------------------------------------------------------
			//-- EAlberti - INICIO - Recalculo Dos Lotes De Processamento
			//-------------------------------------------------------------------------
			aTabRec:= TMSA144CHK(aClone(aCols),@aDelDocs)
			
			//-- Limpa Referências De Valorização da Coleta ( Neste MOmento Para Os Documentos Excluídos )
			If Len(aDelDocs) > 0
				Tmsa310LVC( M->DTQ_FILORI, M->DTQ_VIAGEM, .f., .f., Nil, .t., aDelDocs ) //-- Sexto Parametro .t. Altera DJI Para "Cancelado"
			EndIf	
				
			// Verifica serviço adicional
			For nCntPag :=1  To Len(aTabRec)

				If aTabRec[nCntPag][1] == "DTC"
					lDTCPag := .T.
				ElseIf aTabRec[nCntPag][1] == "DT5"
					lDT5Pag := .T.
				EndIf
			Next nCntPag
					
			// Possui Serviço adicional
			If lDTCPag .AND. lDT5Pag
				cSrvAdc := "1"
			EndIf	
						
			// Carrega aCols dos pagadores de frete
			aRetPag := TMSF79Cols(aTabRec,cSerTMS,cTipTra,"2",cSrvAdc,M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcx)
							
			// Chama a Função de Tela de Pagadores
			aRetTela := TMSF79Tela(Aclone(aRetPag[1]),Aclone(aRetPag[2]),.f.,M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcx,cSerTMS,cSrvAdc)	
					
			If Len(aRetTela) > 0 .And. ValType(aRetTela[4]) == "A"
				TMSF79Lot(aRetTela[4],M->DTQ_FILORI,M->DTQ_VIAGEM,.T.,"1")	//-- Chama criação dos lotes de Coleta
			EndIf
			//-------------------------------------------------------------------------
			//-- EAlberti -   FIM  - Recalculo Dos Lotes De Processamento
			//-------------------------------------------------------------------------

			//-- Limpa Referências De Valorização da Coleta
			Tmsa310LVC( M->DTQ_FILORI, M->DTQ_VIAGEM, .f., .f., Nil, .t. ) //-- Sexto Parametro .t. Altera DJI Para "Cancelado"

			//-- Loop Por Lote
			cQuery :=	" SELECT      DT5.DT5_FILDOC, DT5.DT5_DOC, DT5.DT5_SERIE, DUD.DUD_LOTE, DT5.DT5_NCONTR, DT5.R_E_C_N_O_ DT5REC, DUD.R_E_C_N_O_ DUDREC "
			cQuery +=	" FROM        " + RetSQLName("DUD") + " DUD "
			cQuery +=	" INNER JOIN  " + RetSQLName("DT5") + " DT5 "
			cQuery +=	" ON          DT5.DT5_FILIAL  =  '" + xFilial("DT5") + "' "
			cQuery +=	" AND         DT5.DT5_FILDOC  =  DUD.DUD_FILDOC "
			cQuery +=	" AND         DT5.DT5_DOC     =  DUD.DUD_DOC "
			cQuery +=	" AND         DT5.DT5_SERIE   =  DUD.DUD_SERIE "
			cQuery +=	" AND         DT5.DT5_SERIE   =  'COL' "
			cQuery +=	" AND         DT5.DT5_CODNEG  <> '" + Space(TamSX3("DT5_CODNEG")[1]) + "' "
			cQuery +=	" AND         DT5.DT5_SERVIC  <> '" + Space(TamSX3("DT5_SERVIC")[1]) + "' "
			cQuery +=	" AND         DT5.D_E_L_E_T_  =  ' ' "
			cQuery +=	" WHERE       DUD.DUD_FILIAL  =  '" + xFilial("DUD") + "' "
			cQuery +=	" AND         DUD.DUD_FILORI  =  '" + M->DTQ_FILORI + "' "
			cQuery +=	" AND         DUD.DUD_VIAGEM  =  '" + M->DTQ_VIAGEM + "' "
			cQuery +=	" AND         DUD.D_E_L_E_T_  =  ' ' "
			cQuery +=	" ORDER BY    DUD.DUD_LOTE "

			cQuery := ChangeQuery(cQuery)
			
			Eval(bQuery)

			//-- Formata Campo DT5.R_E_C_N_O_
			TcSetField(cAliasT,"DT5REC","N",16,0)
			TcSetField(cAliasT,"DUDREC","N",16,0)

			//-- Inicializa Variáveis
			cNumLot := ""
			cContr  := ""

			DbSelectArea(cAliasT)
			(cAliasT)->(DbGoTop())
			While (cAliasT)->( !Eof())
			
				cNumLot := (cAliasT)->DUD_LOTE
				cContr  := (cAliasT)->DT5_NCONTR

				DbSelectArea(cAliasT)
				While (cAliasT)->( !Eof()) .And. (cAliasT)->DUD_LOTE == cNumLot

					//-- Exclui Lotes Vazios Do Tratamento (Tratamento Erro CargoLift)
					If Empty((cAliasT)->DUD_LOTE)
						(cAliasT)->(DbSkip())
						Loop
					EndIf

					//-- Posiciona Nos Movimentos Da Viagem Pelo RECNO
					DbSelectArea("DUD")
					DUD->(DbGoTo((cAliasT)->DUDREC))

					//-- Posiciona No Agendamento Pelo RECNO
					DbSelectArea("DT5")
					DT5->(DbGoTo((cAliasT)->DT5REC))
							
					//-- Valoriza Coleta Não Realizada
					If TmsSobServ('VALCOL',.T.,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"0", Nil ) == '2' //-- 1 = SIM ; 2 = NAO

							//-- Posiciona Nas Ocorrencias da Viagem
						DbSelectArea("DUA")
						DbSetOrder(4) //-- DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM
						If MsSeek( FWxFilial("DUA") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE , .F.)
		
								//-- Procura Por Ocorrencias De Cancelamento
							While DUA->(!Eof()) .And. DUA->DUA_FILIAL + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE == xFilial("DUA") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE
											
									//-- Posiciona No Cad. Ocorrencias
								DbSelectArea("DT2")
								DbSetOrder(1)
								MsSeek( FWxFilial("DT2") + DUA->DUA_CODOCO , .F. )
												
									//-- Verifica Se Trata-se De Cancelamento / Retorno Dcto
								If DT2->DT2_TIPOCO == StrZero(12,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(04,Len(DT2->DT2_TIPOCO))

										//-- Verifica Se Trata-se De Rateio (Se Não Utiliza Rateio, Remove Documento )
									If TmsSobServ('BACRAT',.T.,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"1", Nil ) == '1' //-- '1' = Não Utiliza Rateio
										
											//-- Remove Agendamento Do Lote
										RecLock("DUD",.F.)
										Replace DUD_LOTE With ""
										DUD->(MsUnlock())
											
											//-- Posiciona No Cadastro Do Lote
										DbSelectArea("DTP")
										DbSetOrder(1)	//-- DTP_FILIAL+DTP_LOTNFC
										If MsSeek( FWxFilial("DTP") + cNumLot , .F. )
												
												//-- Ajusta dados Do Lote
											RecLock("DTP", .F. )
													
											If DTP->DTP_QTDLOT == 1
												DTP->(DbDelete())
												cNumLot := "" //-- Se Variável Vazia, Não Processa o Lote
											Else
												Replace DTP->DTP_QTDLOT With	( DTP->DTP_QTDLOT - 1 )
												Replace DTP->DTP_QTDDIG With	( DTP->DTP_QTDDIG - 1 )
											EndIf
													
											DTP->(MsUnlock())
												
											Exit	//-- Sai Do Loop Do DUA
					
										EndIf
									Else
											//-- Se For Rateio e 'Valoriza Coleta Não Realizada' = 'Não' e Só Houver Um Documento No Lote, Não Calcula a valorização No TMSA200
											//-- Posiciona No Cadastro Do Lote
										DbSelectArea("DTP")
										DbSetOrder(1)	//-- DTP_FILIAL+DTP_LOTNFC
										MsSeek( FWxFilial("DTP") + cNumLot , .F. )
										If DTP->DTP_QTDLOT == 1
											cNumLot := "" //-- Se Variável Vazia, Não Processa o Lote
										Else
											aAdd( aZeraVlr, { DUA->DUA_FILDOC,  DUA->DUA_DOC, DUA->DUA_SERIE } )
										EndIf
									EndIf
								EndIf
						
								DUA->(DbSkip())
							EndDo
						EndIf
					EndIf

					(cAliasT)->(DbSkip())
				EndDo

				//-- Executa o Cálculo Do Frete Para a Coleta
				If !Empty(cNumLot)

					// Chamada de Ponto de entrada 
					If lTM144LOT
						cNumLotPE := ExecBlock("TM144Lot",.F.,.F., cNumLot)
						If Valtype(cNumLotPE) == "C" .AND. !Empty(cNumLotPE) 
							cNumLot := cNumLotPE
						EndIf
					EndIf

					//-- Força Reposicionamento No Lote De Coleta
					DbSelectArea("DTP")
					DbSetOrder(1) //-- DTP_FILIAL+DTP_LOTNFC
					If MsSeek( FWxFilial("DTP") + cNumLot , .f. )
								
						//-- Processa o Cálculo Do Frete Para Valorização Dos Documentos Da Viagem
						lRet := TMSA200Mnt("DTP",DTP->(Recno()), 2 , Nil , .f., cContr )
						
						//-- Zera Valores De Componentes (Retorna Documento)
						If !Empty(aZeraVlr)
							Tmsa310LVC( M->DTQ_FILORI, M->DTQ_VIAGEM, .f., .f., @aZeraVlr, .f. )
							Tmsa340Per( M->DTQ_FILORI, M->DTQ_VIAGEM ) //-- Ajusta Percentuais Dos Documentos Removidos Do Calc. De Rateio
						EndIf
					EndIf
				EndIf
			EndDo

			//-- Verifica Se Valorizou Os Documentos Da Coleta
			If !(Tmsa310Vlr( M->DTQ_FILORI , M->DTQ_VIAGEM, .t. ))
				lEncerrar := .f. //-- Se Erro, Estorna Movimento
			Else
			
				//-- Gera Réplica da Tabela DT8
				//-- Posiciona No Movimento Da Viagem
				DbSelectArea("DUD")
				DbSetOrder(2) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
				MsSeek( FWxFilial("DUD") + M->DTQ_FILORI + M->DTQ_VIAGEM , .F. )
			
				While !DUD->(Eof()) .And. (DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == (FWxFilial("DUD") + M->DTQ_FILORI + M->DTQ_VIAGEM))
					
					If DUD->DUD_SERIE == "COL"
					
						aInfDT8 := {} //-- Inicializa Variável
						aAdd( aInfDT8, {'DT8_FILDOC'	, DUD->DUD_FILDOC })
						aAdd( aInfDT8, {'DT8_DOC'		, DUD->DUD_DOC    })
						aAdd( aInfDT8, {'DT8_SERIE'		, DUD->DUD_SERIE  })
						
						//-- Gera Réplica da Tabela DT8
						TmsAtuDJI( M->DTQ_FILORI, M->DTQ_VIAGEM, '1', '1', aInfDT8, .F. )
						
					EndIf
								
					DUD->(DbSkip())
				EndDo
			EndIf
			
			//-- Restaura Variáveis
			aCols   := aColsOld 
			aHeader := aHeaderOld 
			
		EndIf
	EndIf
	//-------------------------------------------------------------------------
	//-- Fim    -> Calcula Valorização Da Viagem De Coleta.
	//-------------------------------------------------------------------------
 
	// Exclui Rota Automatica  em caso de Falha 
	If !lRet .AND. lRotAut
		TF10GrRote(5,M->DTQ_FILORI, M->DTQ_VIAGEM)
	EndIf
	
	// Estorna em caso de Erro
	If !lRet
		break
	EndIf
RECOVER
	If !lRet .And. nOpcx == 3 // Somente na Inclusão 

	    //-- Quando manutencao via Painel posiciona na viagem incluida, pois o alias esta apontando para a ultima viagem selecionada no painel
		If IsInCallStack("TMSAF76")
		     DTQ->(DbSetOrder(2))
		     If DTQ->(MsSeek(xFilial("DTQ") + M->(DTQ_FILORI+DTQ_VIAGEM)))
		     	TmsA144Mnt("DTQ",,5, .F. ) // Exclui a viagem em caso de falha
		     EndIf
		EndIf
	EndIf

End Sequence
ErrorBlock(bError)

If !Empty(cErro)
	AutoGrLog( cErro )
    MostraErro() 
EndIf

//-------------------------------------------------------------------------
//-- MAPLINK
//-------------------------------------------------------------------------
If lRet .And. (nOpcx == 4 .Or. nOpcx == 3 ) .And. lMapLink 
	
	oMapLink    := TMSBCAMapLink():New(,,"POST", M->DTQ_FILORI , M->DTQ_VIAGEM , !IsBlind() )
	If oMapLink:GetTypeCallBack() == "1" //-- Envia callback
		oMapLink:Token()
		oMapLink:PlanningPost()
	EndIf
	oMapLink:Destroy()

EndIf

//-------------------------------------------------------------------------
//-- RENTABILIDADE PRÉVIA
//-------------------------------------------------------------------------
If lRet .And. nOpcx == 4 .And. TableInDic("DL3")
	TMSRentab( 5 , M->DTQ_FILORI , M->DTQ_VIAGEM , .F. )
	
	//-- Exclusão bloqueios
	Tmsa029Blq( 5  				,;	//-- 01 - nOpc
				'TMSA310'		,;	//-- 02 - cRotina
				'RP'  			,;	//-- 03 - cTipBlq
				M->DTQ_FILORI	,;	//-- 04 - cFilOri
				'DTQ'	 		,;	//-- 05 - cTab
				'1' 			,;	//-- 06 - cInd
				M->DTQ_FILIAL + M->DTQ_FILORI + M->DTQ_VIAGEM,; //-- 07 - cChave
				"" 				,;	//-- 08 - cCod
				"" 				,;	//-- 09 - cDetalhe
				5)					//-- 10 - Opcao da Rotina 
	
EndIf

RestArea( aAreaDA8 )
RestArea( aAreaDTP )
RestArea( aArea )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA144Del() ³ Autor ³Patricia A. Salomao ³ Data ³ 23/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os elementos do aCols que tenham o mesmo no. de  ³±±
±±³          ³Documento / Serie                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA144Del()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.F.                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144Del()

Local cStatus := GdFieldGet('DUD_STATUS',n)
Local lRet    := .T.
Local lColeta := (cSerTms == StrZero(1,Len(DUD->DUD_SERTMS)))

Local lITmsDmd := SuperGetMv("MV_ITMSDMD",,.F.) .And. FindFunction("TMA144CVG")
Local aDocsDUA := {}

Local lCONTDOC := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")

//Condicao para nao chamar o delOk duas vezes
If __nDelItem == 1
	__nDelItem := 0
	lRet := .F.
Else
	__nDelItem := 1
EndIf

If lRet
	If !aCols[n,Len(aHeader) + 1] //-- Está deletando a linha
		aAdd(aDocsDUA, {GdFieldGet("DTA_FILDOC",n), GdFieldGet("DTA_DOC",n), GdFieldGet("DTA_SERIE",n)})
		//Verifica se existe uma ocorrência apontada para o documento.
		If ExistFunc("TMSDocOcor") .AND. !TMSDocOcor(aDocsDUA, M->DTQ_FILORI, M->DTQ_VIAGEM)
			Return .F.
		EndIf
		//-- Limpa marcas dos agendamentos
		TMSALimAge(StrZero(ThreadId(),20))

		If lCONTDOC
			TmsConTran(aCols[n,GdFieldPos("DTA_FILDOC")],aCols[n,GdFieldPos("DTA_DOC")],aCols[n,GdFieldPos("DTA_SERIE")],.F.)
		EndIf
	Else //-- Está reativando a linha
		If lCONTDOC .And. !TmsConTran(aCols[n,GdFieldPos("DTA_FILDOC")],aCols[n,GdFieldPos("DTA_DOC")],aCols[n,GdFieldPos("DTA_SERIE")],.T.)
			Return .F.
		EndIf

		//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
		If lColeta
			If !TMSAVerAge("3",,,,,,,,,DT6->DT6_FILDOC,DT6->DT6_DOC,,"2",.T.,.T.,,,StrZero(ThreadId(),20))
				Return .F.
			EndIf
		Else
			If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.,,,StrZero(ThreadId(),20))
				Return .F.
			EndIf
		EndIf
	EndIf

	If cStatus != StrZero(1,Len(DUD->DUD_STATUS)) //-- Em Aberto
		lRet := .F.

		//-- Tratamento que busca a solicitação de coleta do documento que está sendo retirado da viagem. Se todas as coletas de todas as notas do
		//-- documento estiverem na mesma viagem a exclusao do documento será permitida. Tratamento efetuado para a integração com Gestão de Demandas.
		If lITmsDmd .And. GdFieldGet("DTA_SERIE",n) != "COL"
			lRet := TMA144CVg(GdFieldGet("DTA_FILDOC",n),GdFieldGet("DTA_DOC",n),GdFieldGet("DTA_SERIE",n),M->DTQ_VIAGEM)
		EndIf
		//--

		If !lRet
			Help(' ', 1, 'TMSA14402') //"Documento nao esta em aberto"
		EndIf
	EndIf
	//-- Nao permite tirar a marca de deleção em viagens de transporte vazia
	If lRet .And. ( cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) .Or. cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) ) .And. nTipVia == 2
		lRet := .F.
	Endif

	If lRet
		If !Empty(aCols[n,GdFieldPos('DTA_FILDOC')]) .And. !Empty(aCols[n,GdFieldPos('DTA_DOC')]) .And. !Empty(aCols[n,GdFieldPos('DTA_SERIE')])
			If aCols[n,Len(aCols[n])] //--Se estiver deletado
				If !LockByName("VGEDOC" + aCols[n,GdFieldPos('DTA_FILDOC')] + aCols[n,GdFieldPos('DTA_DOC')] + aCols[n,GdFieldPos('DTA_SERIE')],.T.,.F.)
					Help(' ',1,'TMSA14418',,STR0028 + " " + aCols[n,GdFieldPos('DTA_FILDOC')] + " " + aCols[n,GdFieldPos('DTA_DOC')] + "-" + aCols[n,GdFieldPos('DTA_SERIE')],3,1) //--"O documento foi selecionado em outra viagem." ### "Documento"
					lRet := .F.
				EndIf
			Else //--Se nao estiver deletado
				UnLockByName("VGEDOC" + aCols[n,GdFieldPos('DTA_FILDOC')] + aCols[n,GdFieldPos('DTA_DOC')] + aCols[n,GdFieldPos('DTA_SERIE')],.T.,.F.)
			EndIf
		EndIf
	EndIf
EndIf

//-- Atualiza os dados do Rodape
TmsA210Rdp()

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TmsA144Val  ³ Autor ³ Richard Anderson   ³ Data ³ 03/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacoes                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Val()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Val(cCampo)

Local lRet       := .T.
Local cCdrOri    := ""
Local nCntFor    := 0
Local nElem      := 0
Local cFilDoc    := ""
Local cDoc       := ""
Local cSerie     := ""
Local aItemDel   := {}
Local aRegiao    := {}
Local aRegRot    := {}
Local lAchou     := .F.
Local lAllRot    := .F.
Local cNumAge    := ""
Local cIteAge    := ""
Local aSx3Box    := {}
Local nSeek      := 0
Local cSeek      := ""
Local cChave     := ""
Local aFilDca    := {}
Local lAAddACols := .F.
Local nSequen    := 0
Local aAreaDF1   := {}
Local nDel       := 0
Local aVisErr    := {}
Local cBacRat    := ""
Local cTMSOPdg   := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local aAreaDTA	 := DTA->(GetArea())
Local aAreaDTx	 := DTX->(GetArea())
Local lTipOpVg   := DTQ->(ColumnPos('DTQ_TPOPVG')) > 0

Private cCriRat  := ""
Default cCampo   := ReadVar()

If "DTQ_ROTA" $ cCampo
	If cSerTms <> StrZero(2,Len(DC5->DC5_SERTMS)) .And. Empty(M->DTQ_ROTA)
		If lRet
			Return .T.
		EndIf	 
	Else
		lRet := ExistCpo("DA8",M->DTQ_ROTA,1)
	EndIf
	If lRet
		If cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)) //-- Coleta
			lAllRot := (mv_par05 == 2)
		ElseIf cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) //-- Entrega
			lAllRot := (mv_par05 == 2)
		EndIf
		If !lAllRot
			cCdrOri := Padr(GetMv("MV_CDRORI",,""),Len(DA8->DA8_CDRORI))
		EndIf
		DA8->(DbSetOrder(1))
		DA8->(MsSeek(xFilial("DA8")+M->DTQ_ROTA))
		If DA8->DA8_SERTMS != cSerTms .Or. DA8->DA8_TIPTRA != cTipTra
			Help(' ', 1, 'TMSA14403') //"Rota não pertence ao Serviço de Transporte e ou Tipo de Transporte da viagem"
			lRet := .F.
		ElseIf !lAllRot .And. DA8->DA8_CDRORI != cCdrOri
			Help(' ', 1, 'TMSA14404',,cCdrOri,2,1) //"Rota não pertence a região de origem: "
			lRet := .F.
		ElseIf DA8->DA8_ATIVO == StrZero(2,Len(DA8->DA8_ATIVO))
			Help(' ', 1, 'TMSA14405',,DA8->DA8_COD,3,1) //"Rota não está ativa no Cadastro de Rotas: "
			lRet := .F.
		EndIf
		If lRet
			If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
				//-- Alteracoes de rotas sao permitidas somente na filial de origem
				If	M->DTQ_FILORI != cFilAnt
					Help('',1,'TMSA14021')		//-- Alteracao da rota permitida somente na filial de origem da viagem
					Return( .F. )
				EndIf
				//-- Verifica se ha manifesto
				DTX->(DbSetOrder(3))
				If	DTX->(MsSeek(cChave := xFilial('DTX') + M->DTQ_FILORI + M->DTQ_VIAGEM))
					//-- Permite alterar a rota de uma viagem manifestada, somente se essa rota contemplar todas as filiais de 
					//-- descarga do manifesto
					//-- Obtem as filiais de descarga da rota
					aFilDca := TMSRegDca(M->DTQ_ROTA)
					nSeek   := 0
					//-- Avalia todos os manifestos da viagem
					While DTX->(!Eof() .And. DTX->DTX_FILIAL + DTX->DTX_FILORI + DTX->DTX_VIAGEM == cChave)
						nSeek := AScan(aFilDca,{|x|x[3]==DTX->DTX_FILDCA})
						If	nSeek <= 0
							Exit
						EndIf
						DTX->(DbSkip())
					EndDo
					//-- A rota nao atende uma das filiais de descarga do manifesto
					If	nSeek <= 0
						Help('',1,'TMSA14020')		//-- Ha manifesto de carga para esta viagem
						Return( .F. )
					EndIf
				EndIf
			Else
				If Ascan(aCols,{ | e | 	e[GdFieldPos("DUD_STATUS")] <> StrZero(1,Len(DUD->DUD_STATUS)) .And. ;
								  		e[GdFieldPos("DUD_STATUS")] <> StrZero(3,Len(DUD->DUD_STATUS)) }) > 0
					Help(' ', 1, 'TMSA14406') //"Rota não poderá ser alterada devido há existência de documentos em processo"
					lRet := .F.
				Else
					If !Empty(cRotAnt) .And. cRotAnt != M->DTQ_ROTA
						//-- Verifica se ha manifesto
						DTX->(DbSetOrder(3))
						If	DTX->(dbSeek(FwxFilial('DTX') + M->DTQ_FILORI + M->DTQ_VIAGEM))
							Help('',1,'TMSA14020')		//-- Ha manifesto de carga para esta viagem
							lRet := .F.
				EndIf
						If lRet
							DTA->(DbSetOrder(2))
							If	DTA->(dbSeek(FwxFilial('DTA') + M->DTQ_FILORI + M->DTQ_VIAGEM))
								Help(' ', 1, 'TMSA144K8') //"Não é permitido alteração da Rota, pois existe Carregamento para a Viagem
								lRet := .F.
							EndIf	
						EndIf				
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet
		If !Empty(cRotAnt) .And. cRotAnt != M->DTQ_ROTA .And. (Len(aCols) > 1 .Or. !Empty(GdFieldGet("DTA_FILDOC",1)))
			If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
				cRotAnt := M->DTQ_ROTA
				DT6->(DbSetOrder(1))
				For nCntFor := 1 To Len(aCols)
					cFilDoc := GDFieldGet("DTA_FILDOC",nCntFor)
					cDoc    := GDFieldGet("DTA_DOC"   ,nCntFor)
					cSerie  := GDFieldGet("DTA_SERIE" ,nCntFor)
					If !Empty(cFilDoc)
						DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
						aRegiao := TMSNivSup(DT6->DT6_CDRCAL) // Obtem os niveis superiores da regiao de calculo (GILSON)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Retorna as Regioes / Filiais de Destino da Rota                       ³
						//³ Elementos contidos por dimensao:                                      ³
						//³ 1. Regiao Origem da Rota                                              ³
						//³ 2. Regioes de Destino da Rota                                         ³
						//³ 3. Filiais de Destino da Rota                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRegRot := TMSRegDes(M->DTQ_ROTA)   // Obtem as regioes da rota.
						For nElem := 1 To Len(aRegiao)
							/* Verifica se a regiao de destino do CTRC pertence a regiao da rota. */
							lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nElem]}) > 0
							If lAchou
								Exit
							EndIf
						Next nCntFor
						If lAchou
							GDFieldPut('DUD_STROTA','1',nCntFor)
						Else
							GDFieldPut('DUD_STROTA','3',nCntFor)
						EndIf
					EndIf
				Next
				oGetD:oBrowse:nAt := 1
				oGetD:oBrowse:Refresh(.T.)
			Else
				If !F11RotRote(M->DTQ_ROTA)
					//--- Se a Rota anterior é baseado em Roteiro, deve verificar se existem documentos com criterios de rateio
					If F11RotRote(cRotAnt)
						For nCntFor := 1 To Len(aCols)
							cFilDoc := GDFieldGet("DTA_FILDOC",nCntFor)
							cDoc    := GDFieldGet("DTA_DOC"   ,nCntFor)
							cSerie  := GDFieldGet("DTA_SERIE" ,nCntFor)
							If !Empty(cFilDoc) .And. cSerie == "COL" 
								DT5->(DbSetOrder(4)) 
								If DT5->(MsSeek(xFilial("DT5")+cFilDoc+cDoc+cSerie)) .And. !Empty(DT5->DT5_SERVIC)
									cCriRat:= TMSA144DcR(DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC)
									If cCriRat == "A" //-- 'A' = Origem/Destino Vge
										//Nao é permitido informar Rota por Cep/Cliente.  /  com Criterios de Rateio:
										Aadd(aVisErr,{STR0123 + " - " + STR0028 + ": " + cFilDoc + " - " + cDoc + " - " + cSerie + " " + STR0124 + cCriRat + " = " + TMSValField('cCriRat',.F.) })  
									EndIf	
								EndIf
							EndIf
						Next
						If Len(aVisErr) > 0
							TmsMsgErr(aVisErr)
							lRet:= .F.
						EndIf	
					EndIf
												 
					If lRet
						If MsgYesNo(STR0024) //"Alterando a rota, documentos que não sejam atendidos pela nova rota serão excluídos. Confirma ?"
							cRotAnt := M->DTQ_ROTA
							//---- Limpa campos do Roteiro	
							If !Empty(M->DTQ_ROTEIR)  
								M->DTQ_ROTEIR:= CriaVar("DTQ_ROTEIR")
								M->DTQ_CDRORI:= CriaVar("DTQ_CDRORI")
								M->DTQ_CDRDES:= CriaVar("DTQ_CDRDES")
								M->DTQ_KMVGE := CriaVar("DTQ_KMVGE")
							EndIf
							For nCntFor := 1 To Len(aCols)
								cFilDoc := GDFieldGet("DTA_FILDOC",nCntFor)
								cDoc    := GDFieldGet("DTA_DOC"   ,nCntFor)
								cSerie  := GDFieldGet("DTA_SERIE" ,nCntFor)
								If !Empty(cFilDoc)
									//-- Localiza zona e setor da rota a partir do documento
									If !TmsA144DPC(cFilDoc,cDoc,cSerie,,,,.F.) .And. ;
										!TmsA144DA7(cFilDoc,cDoc,cSerie,,,,.F.,.F.)
										AAdd(aItemDel,nCntFor)
									EndIf
								EndIf
							Next
							If Len(aItemDel) > 0
								For nCntFor := 1 To Len(aItemDel)
									aCols := ADel(aCols, aItemDel[nCntFor]-nDel)
									nDel ++
								Next
								aCols := ASize(aCols, Len(aCols) - Len(aItemDel))
								If Empty(aCols)
									AAdd(aCols,Array(Len(aHeader)+1))
									For nCntFor := 1 To Len(aHeader)
										aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
									Next
									GdFieldPut("DUD_SEQUEN",StrZero(1,Len(DUD->DUD_SEQUEN)),Len(aCols))
									aCols[Len(aCols),Len(aHeader)+1] := .F.
								EndIf
								oGetD:oBrowse:nAt := 1
								oGetD:oBrowse:Refresh(.T.)
							EndIf
						Else
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			cRotAnt := M->DTQ_ROTA
			If DTQ->(ColumnPos('DTQ_PAGGFE')) > 0
				cPagGFEAnt:= M->DTQ_PAGGFE
			EndIf			
		EndIf
		//---- Controle para alteração da Rota no momento da inclusao da viagem, 
		//---- apos ter sido informado o Complemento da Viagem para recalculo do frete a pagar
		If Len(aCompViag) == 0 
			cRotaInf := M->DTQ_ROTA
		EndIf
	EndIf
ElseIf "DF1_NUMAGE" $ cCampo .Or. "DF1_ITEAGE" $ cCampo
	If AllTrim(ReadVar()) == "M->DF1_NUMAGE"
		cNumAge := M->DF1_NUMAGE
		cIteAge := GdFieldGet("DF1_ITEAGE",n)
	ElseIf AllTrim(ReadVar()) == "M->DF1_ITEAGE"
		cNumAge := GdFieldGet("DF1_NUMAGE",n)
		cIteAge := M->DF1_ITEAGE
	EndIf
	If Empty(cNumAge)
		Return( .T. )
	EndIf

	If mv_par03 == 1 //-- Marca intens do agendamento
		//-- Validacao da chave de indice
		If AllTrim(DF1->(IndexKey(5))) <> "DF1_FILIAL+DF1_NUMAGE+DF1_SEQUEN"
			Help(' ', 1, 'TMSA14407') //"O Indice 5 do arquivo DF1 devera ter o seguinte conteudo 'DF1_FILIAL+DF1_NUMAGE+DF1_SEQUEN'"
			Return( .T. )
		EndIf
		aAreaDF1 := DF1->(GetArea())
		DF1->(DbSetOrder(5))
		If DF1->(MsSeek(xFilial("DF1")+cNumAge))
			While DF1->(!Eof()) .And. DF1->DF1_FILIAL + DF1->DF1_NUMAGE == xFilial("DF1") + cNumAge
				If DF1->DF1_STACOL == StrZero(2,Len(DF1->DF1_STACOL)) //-- Confirmado
					cSeek := cNumAge + DF1->DF1_ITEAGE + DF1->DF1_FILDOC + DF1->DF1_DOC + DF1->DF1_SERIE
					nSeek := AScan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DF1_NUMAGE')]+  x[GdFieldPos('DF1_ITEAGE')] + x[GdFieldPos('DTA_FILDOC')]+  x[GdFieldPos('DTA_DOC')] +x[GdFieldPos('DTA_SERIE')] == cSeek } )
					If nSeek > 0
						DF1->(DbSkip())
						Loop
					EndIf
					//-- Atualiza a sequencia da viagem
					nSequen := Val(GDFieldGet("DUD_SEQUEN",Len(aCols)))
					If lAAddACols
						nSequen ++
						n := Len(aCols) + 1
						TMSA210Cols()
					Else
						lAAddACols := .T.
					EndIf
					GdFieldPut("DTA_FILDOC",DF1->DF1_FILDOC,n)
					GdFieldPut("DTA_DOC"   ,DF1->DF1_DOC   ,n)
					GdFieldPut("DTA_SERIE" ,DF1->DF1_SERIE ,n)
					GdFieldPut("DUD_SEQUEN",StrZero(nSequen,Len(DUD->DUD_SEQUEN)),n)
					M->DTA_FILDOC := DF1->DF1_FILDOC
					TmsA210Val("M->DTA_FILDOC")
				EndIf
				DF1->(DbSkip())
			EndDo
		Else
			Help(' ', 1, 'TMSA14408') //"Agendamento não Encontrado !"
			lRet := .F.
		EndIf
		RestArea( aAreaDF1 )
	Else
		If Empty(cIteAge)
			Return( .T. )
		EndIf
		DF1->(DbSetOrder(1))
		If DF1->(!MsSeek(xFilial("DF1")+cNumAge+cIteAge))
			Help(' ', 1, 'TMSA14408') //"Agendamento não Encontrado !"
			lRet := .F.
		ElseIf DF1->DF1_STACOL != StrZero(2,Len(DF1->DF1_STACOL)) //-- Confirmado
			aSx3Box := RetSx3Box(Posicione("SX3",2,"DF1_STACOL","X3CBox()"),,,1)
			If	(nSeek := Ascan(aSx3Box,{|x|x[2] == DF1->DF1_STACOL})) > 0
				Help(' ', 1, 'TMSA14410',,AllTrim(aSx3Box[nSeek,3]),1,20) //"Agendamento está "
			Else
				Help(' ', 1, 'TMSA14411') //"Agendamento não está Confirmado"
			EndIf
			lRet := .F.
		EndIf
		If lRet
			GdFieldPut("DTA_FILDOC",DF1->DF1_FILDOC,n)
			GdFieldPut("DTA_DOC"   ,DF1->DF1_DOC   ,n)
			GdFieldPut("DTA_SERIE" ,DF1->DF1_SERIE ,n)
			M->DTA_FILDOC := DF1->DF1_FILDOC
			TmsA210Val("M->DTA_FILDOC")
		EndIf
	EndIf
	//-- Atualizando o Rodape
	TMSA210Rdp()
ElseIf "DJN_CODFOR" $ cCampo
	lRet := ExistCpo("SA2",M->DJN_CODFOR+AllTrim(GdFieldGet("DJN_LOJFOR",n)) ,1)
	If lRet
		If Posicione("SA2",1,xFilial("SA2")+M->DJN_CODFOR+AllTrim(GdFieldGet("DJN_LOJFOR",n)), "A2_PAGGFE") <> StrZero(1,Len(SA2->A2_PAGGFE)) //Sim
			Help(' ', 1, 'TMSA14441') //"Permitido informar somente os Fornecedores configurados com Pagamento pelo SIGAGFE.
			lRet:= .F.
		EndIf
	EndIf
ElseIf "DJN_LOJFOR" $ cCampo
	lRet := ExistCpo("SA2",GdFieldGet("DJN_CODFOR",n)+AllTrim(M->DJN_LOJFOR) ,1)
	If lRet
		If Posicione("SA2",1,xFilial("SA2")+GdFieldGet("DJN_CODFOR",n)+AllTrim(M->DJN_LOJFOR), "A2_PAGGFE") <> StrZero(1,Len(SA2->A2_PAGGFE)) //Sim
			Help(' ', 1, 'TMSA14441') //"Permitido informar somente os Fornecedores configurados com Pagamento pelo SIGAGFE.
			lRet:= .F.
		EndIf	
	EndIf 
ElseIf "DUD_CDMUNO" $ cCampo 
	lRet:= ExistCpo("CC2",GdFieldGet("DUD_UFORI",n)+M->DUD_CDMUNO) 
ElseIf "DUD_CDMUND" $ cCampo
	lRet:= ExistCpo("CC2",GdFieldGet("DUD_UFDES",n)+M->DUD_CDMUND)
ElseIf "DTQ_CDMUNO" $ cCampo 
	lRet:= Vazio() .Or. ExistCpo("CC2",M->DTQ_UFORI+M->DTQ_CDMUNO)  
	If lRet .And. !Empty(M->DTQ_ROTA)
		DUY->(DbSetOrder(1))
		If	DUY->(MsSeek(xFilial('DUY') + DA8->DA8_CDRORI ))
			lRet:= M->DTQ_UFORI == DUY->DUY_EST .And. M->DTQ_CDMUNO == DUY->DUY_CODMUN
			If !lRet
				If MsgYesNo(STR0130) //'O Estado/Municipio de Origem estão diferentes da Rota. Deseja continuar? (S/N) ') 
					lRet:= .T.
				EndIf	
			EndIf
		EndIf
	EndIf 
ElseIf "DUD_REDESP" $ cCampo
	lRet:= TM144RdVge(GdFieldGet('DTA_FILDOC',n),GdFieldGet('DTA_DOC',n),GdFieldGet('DTA_SERIE',n),GdFieldGet('DUD_STATUS',n))
ElseIf "DTQ_PAGGFE" $ cCampo	
	lRet:= .T.
	If cTMSOPdg <> '0' .And. Len(aCompViag) > 0 .And. Len(aCompViag[11]) > 0
		If !Empty(aCompViag[11, 7]) .And. M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
			Help(" ",1,"TMSA24082")   //Pagamento da viagem via SIGAGFE. Não é permitido informar a Operadora de Frotas.  
			lRet:= .F.
		EndIf
	EndIf		
	If lRet
		If !Empty(cPagGFEAnt) .And. cPagGFEAnt != M->DTQ_PAGGFE .And. (Len(aCols) > 1 .Or. !Empty(GdFieldGet("DTA_FILDOC",1)))
			If MsgYesNo(STR0132) //"Alterando o Pagamento pelo SIGAGFE, os dados dos documentos referente a integração serão alterados. Confirma ?
				cPagGFEAnt:= M->DTQ_PAGGFE
				For nCntFor := 1 To Len(aCols)
					If M->DTQ_PAGGFE <> StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Não 
						TM144AtuLi(nCntFor, .T. ,GDFieldGet("DTA_FILDOC",nCntFor), GDFieldGet("DTA_DOC",nCntFor),GDFieldGet("DTA_SERIE" ,nCntFor) )
					Else
						TM144AtuLi(nCntFor, .F. ,GDFieldGet("DTA_FILDOC",nCntFor), GDFieldGet("DTA_DOC",nCntFor),GDFieldGet("DTA_SERIE" ,nCntFor) )
					EndIf 
				Next 
						
				oGetD:oBrowse:nAt := 1
				oGetD:oBrowse:Refresh(.T.)
				
				lRet:= .T.
			Else
				lRet:= .F.	 
			EndIf				
		EndIf
	EndIf
ElseIf "DTQ_TPOPVG" $ cCampo  
	DTY->( DbSetOrder( 2 ) )
    If DTY->(MsSeek(xFilial('DTY') + M->DTQ_FILORI + M->DTQ_VIAGEM)) .And. DTY->DTY_FILORI == cFilAnt
		Help(' ', 1, 'TMSXFUNA06')	//-- Manutencoes nao sao permitidas em viagens que ja tenham contrato de carreteiro
		lRet:= .F.
	EndIf
	If lRet
		If ValType(aCompViag) == "A" .And.  Len(aCompViag) == 0 
			cTipOpVgAnt:= M->DTQ_TPOPVG
		EndIf	
	EndIf
EndIf
RestArea(aAreaDTA)
RestArea(aAreaDTx)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TmsA144Whe  ³ Autor ³ Richard Anderson   ³ Data ³ 03/12/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Condicao de Edicao do campo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Whe()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Viagem modelo2                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Whe(cCampo)

Local   lRet   := .T.
Local lTMS3GFE := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)

Default cCampo := ReadVar()

//-- Somente sera permitido alterar documento com status "Em Aberto".
If "DF1_NUMAGE" $ cCampo
	lRet := GDFieldGet("DUD_STATUS",n) == StrZero(1,Len(DUD->DUD_STATUS))
ElseIf "DF1_ITEAGE" $ cCampo
	If ( lRet := "TMSA144" $ FunName() )
		lRet := GDFieldGet("DUD_STATUS",n) == StrZero(1,Len(DUD->DUD_STATUS))
	EndIf
ElseIf "DUD_REDESP" $ cCampo   //Campo habilitado somente para Servico de Entrega e PagGFE igual a 'NAO'
	If !('TMSA144' $ AllTrim(FunName()))  .Or.; 
		(ValType(cSerTms) == "C" .And. cSerTMs <> StrZero(3,Len(DC5->DC5_SERTMS))) .Or.;   //Entrega
		GDFieldGet("DUD_STATUS",n) <> StrZero(1,Len(DUD->DUD_STATUS))
		lRet:= .F.
	EndIf		
	
ElseIf cCampo $ 'M->DUD_UFORI|M->DUD_CDMUNO|M->DUD_CEPORI|M->DUD_UFDES|M->DUD_CDMUND|M->DUD_CEPDES|M->DUD_TIPVEI|M->DUD_CDCLFR'
	If GDFieldGet("DUD_STATUS",n) <> StrZero(1,Len(DUD->DUD_STATUS)) .Or. ;
		!('TMSA144' $ AllTrim(FunName()) .Or. 'TMSAF76' $ AllTrim(FunName())) .Or. M->DTQ_PAGGFE <> StrZero(1,Len(DTQ->DTQ_PAGGFE)) 
			lRet:= .F.
	EndIf	
	
	If lRet
		//-- Estes campos serao preenchidos automaticamente na gravação da viagem atraves do conteudo do campo DUD_FILDCA
		If cCampo $ 'M->DUD_UFDES|M->DUD_CDMUND|M->DUD_CEPDES'
			If cSerTMs == StrZero(2,Len(DC5->DC5_SERTMS))
				lRet:= .F.
			EndIf 
		End
	EndIf
ElseIf cCampo $ 'M->DTQ_TIPVEI|M->DTQ_CDTPOP|M->DTQ_CDCLFR|M->DTQ_UFORI|M->DTQ_CDMUNO|M->DTQ_CEPORI|M->DTQ_UFDES|M->DTQ_CDMUND|M->DTQ_CEPDES'
	If !('TMSA144' $ AllTrim(FunName()) .Or. 'TMSAF76' $ AllTrim(FunName())) .Or. (!lTMS3GFE .And. !lTmsRdpU) 
			lRet:=.F.
	EndIf
	
ElseIf "DTQ_PAGGFE" $ cCampo
	If !lTMS3GFE .And. !lTmsRdpU
		lRet:= .F. 
	Else
		If !('TMSA144' $ AllTrim(FunName()) .Or. 'TMSAF76' $ AllTrim(FunName()))
			lRet:= .F.
		Else
			If Len(aCompViag) > 1 .And. Len(aCompViag[11]) >= 7 .And. !Empty(aCompViag[11,7]) //Cod.Operadora
				lRet:= .F.
			Endif	  
		EndIf
	EndIf	
ElseIf "DUD_CDTPOP" $ cCampo
	If M->DTQ_PAGGFE <> StrZero(1,Len(DTQ->DTQ_TIPVIA)) .Or. !Empty(GDFieldGet("DUD_CHVEXT",n)) 
		lRet:= .F.
	EndIf	
EndIf

If lRet
	If ExistBlock("TM144Whe")
		lRet := ExecBlock("TM144Whe",.F.,.F.,{cCampo})
		If Valtype(lRet) != "L"
			lRet := .T.
		EndIf
	EndIf
EndIf
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA144Lim³ Autor ³ Patricia A. Salomao   ³ Data ³13.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Analisa as informacoes dos documentos selecionados para a   ³±±
±±³          ³consulta de limites                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA144Lim(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Lim( nOpcx )

Local na,nb
Local aLimite    := {}
Local nCntFor    := 0
Local nPeso      := 0
Local nPesoM3    := 0
Local nValMer    := 0
Local nSeek      := 0
Local nCapaCm    := 0
Local nCapCav    := 0
Local nValFrePag := 0
Local nTotFrePag := 0
Local nTotFreRec := 0
Local aValSeg    := {}
Local cCliente   := Space( Len( DTC->DTC_CLIREM ) )
Local cLoja      := Space( Len( DTC->DTC_LOJREM ) )
Local cProduto   := Space( Len( DTC->DTC_CODPRO ) )
Local aBlqAnoVei := {}
Local aBlqCarPer := {}
Local aBlqFrtCar := {}
Local aVeiculos  := {}
Local aFretCar   := {}
Local cCatVei    := ''
Local cChave     := ''
Local cCodFor    := ''
Local cLojFor    := ''
Local cVeiRas    := ''
Local cCodVei    := ''
Local cCodReb    := ''
Local cCodRb1    := ''
Local cCodRb2    := ''
Local cCodRb3	 := ''
Local aBlqDoctos := {{},{},{}}
Local lTipOpVg   := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aLimite                                              ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ [01] = Codigo do cliente remetente                                    ³
//³ [02] = Loja do cliente remetente                                      ³
//³ [03] = Codigo do produto                                              ³
//³ [04] = Valor da Mercadoria                                            ³
//³ [05] = Peso Real                                                      ³
//³ [06] = Peso Cubado                                                    ³
//³ [07] = Valor do Seguro                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTC->(DbSetOrder(3))
For nCntFor:= 1 To Len( aCols )
	If !(GdDeleted(nCntFor))
		cFilDoc := GDFieldGet('DTA_FILDOC',nCntFor)
		cDoc    := GDFieldGet('DTA_DOC'   ,nCntFor)
		cSerie  := GDFieldGet('DTA_SERIE' ,nCntFor)
		If cSerTms == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .Or. ; //-- Transporte
			cSerTms == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) //-- Entrega
			If FindFunction("TmsPsqDY4") .And. !TmsPsqDY4(cFilDoc,cDoc,cSerie)				
				If DTC->(MsSeek( xFilial('DTC') + cFilDoc + cDoc + cSerie  ))
					While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == xFilial('DTC') + cFilDoc + cDoc + cSerie
						If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0							
								AAdd( aLimite,{ DTC->DTC_CLICAL , DTC->DTC_LOJCAL, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3, Iif(DTC->DTC_VALSEG<> 0, DTC->DTC_VALSEG, DTC->DTC_VALOR)  } )
							Else	
							aLimite[nPos,4] += DTC->DTC_VALOR
							aLimite[nPos,5] += DTC->DTC_PESO
							aLimite[nPos,6] += DTC->DTC_PESOM3
						EndIf
						DTC->(DbSkip())
					EndDo
				EndIf
			Else
				DbSelectArea("DY4")
				DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
				If DY4->(MsSeek( xFilial('DY4') + cFilDoc + cDoc + cSerie  ))
					While DY4->(!Eof()) .And. DY4->DY4_FILIAL + DY4->DY4_FILDOC + DY4->DY4_DOC + DY4->DY4_SERIE == xFilial('DY4') + cFilDoc + cDoc + cSerie						
						DbSelectArea("DTC")
						DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
						If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO+DY4->DY4_FILORI+DY4->DY4_LOTNFC))	
							If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0
								AAdd( aLimite,{ DTC->DTC_CLIREM , DTC->DTC_LOJREM, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
							Else
								aLimite[nPos,4] += DTC->DTC_VALOR
								aLimite[nPos,5] += DTC->DTC_PESO
								aLimite[nPos,6] += DTC->DTC_PESOM3
							EndIf
						Endif							
						DY4->(DbSkip())
					EndDo
				EndIf	
			Endif
		ElseIf cSerTms == StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) //-- Coleta
			DUM->(DbSetOrder(1))
			DT5->(DbSetOrder(4))
			If DT5->(MsSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ))
				If DUM->(MsSeek( xFilial('DUM') + DT5->DT5_FILORI + DT5->DT5_NUMSOL ))
					While DUM->(!Eof()) .And. DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL == xFilial('DUM') + DT5->DT5_FILORI + DT5->DT5_NUMSOL
						If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0
								AAdd( aLimite,{ DT5->DT5_CLIDEV, DT5->DT5_LOJDEV, DUM->DUM_CODPRO, DUM->DUM_VALMER, DUM->DUM_PESO, DUM->DUM_PESOM3, DUM->DUM_VALMER } )
							Else 
							aLimite[nPos,4] += DUM->DUM_VALMER
							aLimite[nPos,5] += DUM->DUM_PESO
							aLimite[nPos,6] += DUM->DUM_PESOM3
								aLimite[nPos,7] += DUM->DUM_VALMER
							EndIf	
						DUM->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		DT6->(DbSetOrder(1))
		If DT6->(MsSeek(xFilial('DT6')+ cFilDoc + cDoc + cSerie ))
			nTotFreRec += DT6->DT6_VALFRE // Total do Frete a Receber dos Documentos da viagem
		EndIf
	EndIf
Next nCntFor

// Verifica se o complemento de viagem foi efetuado. 
If Len(aCompViag) > 0 .And. !Empty(aCompViag[1]) .And. !Empty(aCompViag[2])
	aHeader := AClone(aCompViag[1])  // aHeader DTR(Veiculos da Viagem).
	aCols   := AClone(aCompViag[2])  // aCols DTR(Veiculos da Viagem).

	DA3->(DbSetOrder(1))
	For nA := 1 To Len(aCols)
		If !GDDeleted( nA )
			cCodVei := GdFieldGet( "DTR_CODVEI", nA )
			nValFrePag := GdFieldGet( "DTR_VALFRE", nA )	// Valor do Frete a Pagar informado no Complemento da Viagem		
			nTotFrePag += nValFrePag    // Total do Frete a Pagar (todos os veiculos do complemento)			
			If	DA3->( MsSeek( xFilial('DA3') + cCodVei ) ) .And. DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )
				cChave 	:= DA3->DA3_TIPVEI
				cCodFor	:= DA3->DA3_CODFOR
				cLojFor := DA3->DA3_LOJFOR
				cVeiRas := DA3->DA3_VEIRAS
				AAdd(aVeiculos, {cCodVei, GdFieldGet("DTR_QTDEIX",nA), GdFieldGet("DTR_QTEIXV",nA) } )
				cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') 
				If cCatVei == StrZero(2, Len(DUT->DUT_CATVEI)) //-- Se o Tipo do Veiculo for 'Cavalo'
					nCapCav += DA3->DA3_CAPACM
				Else
					nCapaCm += DA3->DA3_CAPACM
				EndIf
				AAdd( aBlqAnoVei, { DA3->DA3_COD, DA3->DA3_ANOFAB } )
			EndIf
			/* Obtem a capacidade do Reboque 1/Reboque 2. e Reboque3*/
			cCodRb1 := Space(Len(DA3->DA3_COD))
			cCodRb2 := Space(Len(DA3->DA3_COD))
				cCodRb3 := Space(Len(DA3->DA3_COD))
			For nB := 1 To 3
				cCodReb := Space(Len(DA3->DA3_COD))
				If nB == 1 .And. !Empty( GdFieldGet("DTR_CODRB1", nA) )
					cCodRb1 := GdFieldGet("DTR_CODRB1", nA)
					cCodReb := cCodRb1
					AAdd(aVeiculos, {cCodRB1, 0, 0 } )
				ElseIf nB == 2 .And. !Empty( GdFieldGet("DTR_CODRB2", nA) )
					cCodRb2 := GdFieldGet("DTR_CODRB2", nA)
					cCodReb := cCodRb2		 
					AAdd(aVeiculos, {cCodRB2, 0, 0 } )
				ElseIf nB == 3 
					If !Empty( GdFieldGet("DTR_CODRB3", nA) )
						cCodRb3 := GdFieldGet("DTR_CODRB3", nA)
						cCodReb := cCodRb3		 
						AAdd(aVeiculos, {cCodRB3, 0, 0 } )
					EndIf
				EndIf
				If	!Empty(cCodReb) .And. DA3->( MsSeek( xFilial('DA3') + cCodReb ) ) .And. DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )
					nCapaCm += DA3->DA3_CAPACM
					cChave+= DA3->DA3_FROVEI
				Else
					cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
				EndIf
			Next nB
			cChave+=cVeiRas

			If Empty(M->DTQ_ROTA) .And. ( nRota := Ascan( aRota, {|x| x[1] == .T.}) ) > 0
				M->DTQ_ROTA := aRota[nRota][2]
			EndIf

			//-- Verifica se existe a Tabela de Carreteiro por Rota
			aFretCar := TMSFretCar(M->DTQ_ROTA, cCodFor, cLojFor, aVeiculos, cChave, M->DTQ_SERTMS, M->DTQ_TIPTRA,,,,,,Iif(lTipOpVg,M->DTQ_TPOPVG,'') )

			//-- Bloqueia a Viagem se o Valor do Frete a Pagar for Maior que o valor do frete Calculado
			If !Empty(aFretCar) .And. !Empty(aFretCar[2]) .And. nValFrePag > aFretCar[2]
				AAdd(aBlqFrtCar, { nValFrePag, aFretCar[2] })
			EndIf
		EndIf
	Next nA
EndIf

/* Verifica se o complemento de viagem foi efetuado(Motoristas). */
If Len(aCompViag) > 0 .And. Len(aCompViag[4]) > 0 .And. !Empty(aCompViag[3]) .And. !Empty(aCompViag[4][1][2])
	aHeader  := AClone(aCompViag[3]) // aHeader DUP(Motorista da Viagem).
	For nB := 1 To Len(aCompViag[4])
		aCols := AClone(aCompViag[4][nB][2]) // aCols DUP(Motorista da Viagem).
		DA4->( DbSetOrder( 1 ) )
		For nA := 1 To Len(aCols)
			If !GDDeleted( nA )
				If DA4->( MsSeek( xFilial("DA4") + GdFieldGet("DUP_CODMOT", nA), .F. ) ) .And.;
					DA4->DA4_BLQMOT == StrZero( 2, Len( DA4->DA4_BLQMOT ) )
					/* Obtem o valor de marcadoria que o motorista tem permissao para carregar. */
					AAdd(aValSeg,    { DA4->DA4_COD, DA4->DA4_VALSEG })
					AAdd(aBlqCarPer, { DA4->DA4_COD, DA4->DA4_CARPER })
				EndIf
			EndIf
		Next nA
	Next nB
EndIf

/* Tratamento para o Bloqueio - Controle de Documentos */
If Len(aCompViag) > 0 .And. !Empty(aCompViag[1]) .And. !Empty(aCompViag[2])
	aHeader := AClone(aCompViag[1])  // aHeader DTR(Veiculos da Viagem).
	aCols   := AClone(aCompViag[2])  // aCols DTR(Veiculos da Viagem).
	For nA := 1 To Len(aCols)
		If !GDDeleted( nA )
			AAdd(aBlqDoctos[1], GDFieldGet('DTR_CODVEI', nA))
			If !Empty(GDFieldGet('DTR_CODRB1'))
				AAdd( aBlqDoctos[1], GDFieldGet('DTR_CODRB1', nA))
			EndIf
			If !Empty(GDFieldGet('DTR_CODRB2'))
				AAdd(aBlqDoctos[1], GDFieldGet('DTR_CODRB2', nA))
			EndIf
				If !Empty(GDFieldGet('DTR_CODRB3'))
					AAdd( aBlqDoctos[1], GDFieldGet('DTR_CODRB3', nA ) )
				EndIf
			EndIf
	Next
EndIf

If Len(aCompViag) > 0 .And. Len(aCompViag[4]) > 0 .And. !Empty(aCompViag[3]) .And. !Empty(aCompViag[4][1][2])
	aHeader  := AClone(aCompViag[3]) // aHeader DUP(Motorista da Viagem).
	For nB := 1 To Len(aCompViag[4])
		aCols := AClone(aCompViag[4][nB][2]) // aCols DUP(Motorista da Viagem).	
		For nA := 1 To Len(aCols)
			If !GDDeleted( nA )
				AAdd(aBlqDoctos[2], GdFieldGet("DUP_CODMOT", nA))
			EndIf
		Next nA
	Next nB
EndIf

If Len(aCompViag) > 0 .And. Len(aCompViag[6]) > 0 .And. !Empty(aCompViag[5]) .And. !Empty(aCompViag[6][1][2])
	aHeader  := AClone(aCompViag[5]) // aHeader DUP(Motorista da Viagem).
	For nB := 1 To Len(aCompViag[6])
		aCols := AClone(aCompViag[6][nB][2]) // aCols DUP(Motorista da Viagem).	
		For nA := 1 To Len(aCols)
			If !GDDeleted( nA )
				AAdd(aBlqDoctos[3], GdFieldGet("DUQ_CODAJU", nA))
			EndIf
		Next nA
	Next nB
EndIf

TmsBlqViag( M->DTQ_FILORI, M->DTQ_VIAGEM, aLimite, nCapacM, aValSeg, cSerTms, , aBlqAnoVei, aBlqCarPer, nCapCav, aBlqFrtCar, nTotFrePag, nTotFreRec, aBlqDoctos )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as Variaveis da GetDados Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestInter()

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144DUH³ Autor ³ Alex Egydio           ³ Data ³13.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta os enderecos vinculados a viagem                 ³±±
±±³          ³ Utilizado pela consulta F3( DLL ) do campo DTA_LOCAL       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de origem                                   ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144DUH(cFilOri,cViagem)

Local aEnder	:= {}
Local cSeekDUD	:= ''
Local cSeekDUH	:= ''
Local cSeekDTC	:= ''
Local cSeekDY4	:= ''
Local nRet		:= 0
Local nQtdVol   := 0

Default cFilOri := M->DTA_FILORI
Default cViagem := M->DTA_VIAGEM

DUD->(DbSetOrder(2))
If	DUD->(MsSeek(cSeekDUD := xFilial('DUD') + cFilOri + cViagem))
	While DUD->( ! Eof() .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == cSeekDUD )
		If FindFunction("TmsPsqDY4") .And. !TmsPsqDY4(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE)
			DTC->(DbSetOrder(3))
			DTC->(MsSeek(cSeekDTC := xFilial('DTC') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE))
			Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeekDTC
				DUH->(DbSetOrder(1))
				If	DUH->(MsSeek(cSeekDUH := xFilial('DUH') + cFilAnt + DTC->DTC_NUMNFC + DTC->DTC_SERNFC))
					While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC == cSeekDUH )
						nSeek := Ascan( aEnder,{|x| x[1] + x[2] == DUH->DUH_LOCAL + DUH->DUH_LOCALI })
						If nSeek > 0
							aEnder[nSeek][3] += DUH->DUH_QTDVOL // Adiciona a Qtde. de Volumes existentes no Endereco
							DUH->(DbSkip())
							Loop
						EndIf
						//-- Apresenta enderecos em aberto
						If	DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
							nQtdVol := DUH->DUH_QTDVOL
							AAdd(aEnder,{ DUH->DUH_LOCAL, DUH->DUH_LOCALI, nQtdVol, DUH->DUH_FILORI, DUH->DUH_STATUS})
						EndIf
						DUH->(DbSkip())
					EndDo
				EndIf
				DTC->(dbSkip())
			EndDo
		Else
			dbSelectArea("DY4")						
			DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
			If DY4->( MsSeek( cSeekDY4 := xFilial("DY4")+ DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE) )		
			
				Do While !DY4->(Eof()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeekDY4
					DUH->(DbSetOrder(1))
					If	DUH->(MsSeek(cSeekDUH := xFilial('DUH') + cFilAnt + DY4->DY4_NUMNFC + DY4->DY4_SERNFC))
						While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC == cSeekDUH )
							nSeek := Ascan( aEnder,{|x| x[1] + x[2] == DUH->DUH_LOCAL + DUH->DUH_LOCALI })
							If nSeek > 0
								aEnder[nSeek][3] += DUH->DUH_QTDVOL // Adiciona a Qtde. de Volumes existentes no Endereco
								DUH->(DbSkip())
								Loop
							EndIf
							//-- Apresenta enderecos em aberto
							If	DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
								nQtdVol := DUH->DUH_QTDVOL
								AAdd(aEnder,{ DUH->DUH_LOCAL, DUH->DUH_LOCALI, nQtdVol, DUH->DUH_FILORI, DUH->DUH_STATUS})
							EndIf
							DUH->(DbSkip())
						EndDo
					EndIf
					DY4->(dbSkip())
				EndDo											
			Endif
		Endif			
		DUD->(DbSkip())
	EndDo
EndIf

//-- Consulta F3 baseada em vetor apresentando os enderecos da viagem
If ! Empty(aEnder)
	nRet := TmsF3Array( {RetTitle('DUH_LOCAL'),RetTitle('DUH_LOCALI'),RetTitle('DUH_QTDVOL')}, aEnder, 'Endereco' )
	If ! Empty(nRet)
		DbSelectArea('DUH')
		DbSetOrder(2)
		MsSeek(xFilial('DUH') + aEnder[nRet,4] + aEnder[nRet,5] + aEnder[nRet,1] + aEnder[nRet,2])
	EndIf
EndIf

Return IIf(nRet > 0, .T., .F.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA144Viag³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza a viagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Viag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA144Viag(nOpcx,lVgeExpr,lAltTipOpVg)

Local aTipVei    := {}
Local aDoctosMrk := {}
Local aDoctos    := aClone(aCols)
Local lEdita     := .T.
Local lCalcFrt   := .F.
Local lMostra    := .T.
Local nCont      := 0
Local lTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0'
Local lAltRota   := .F.
Local lCONTDOC   := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.     

Default lVgeExpr    := .F.
Default lAltTipOpVg:=  .F.
If ValType(aPosicao) <> 'A'
	Static aPosicao := {}
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

If Empty(M->DTQ_ROTA) .And. (cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) )
	Help(' ', 1, 'TMSA14016')	//-- Nenhuma rota selecionada !
Else
	If Len(aPosicao) = 0
		AAdd( aPosicao, 0 )
		AAdd( aPosicao, GdFieldPos("DTA_FILDOC") )
		AAdd( aPosicao, GdFieldPos("DTA_DOC"   ) )
		AAdd( aPosicao, GdFieldPos("DTA_SERIE" ) )
		AAdd( aPosicao, Len(aHeader)+1 )
	EndIf

	//-- Quando for Carga Fechada, passa dois novos parametros para o Complemento de Viagem( aTipVei e aDoctosMrk ).
	If lColeta .And. lTmsCFec
		TmsA144Doc( nOpcx, .F. ) //-- Cria vetor aDocto para atualizacao do tipo de veiculo e documentos marcados.
		Tmsa141TpVei(@aTipVei,@aDoctosMrk) //-- Tipos de Veiculos
		aHeader   := {}
		aCols     := {}
		aCompViag := TmsA240Mnt(,,nOpcx,M->DTQ_FILORI,M->DTQ_VIAGEM,aCompViag,M->DTQ_ROTA,cSerTms,cTipTra,@M->DTQ_OBS,aTipVei,aDoctosMrk,,nTipVia,,aDoctos,aPosicao) //'Complemento de Viagem... 
	Else
		If lVgeExpr
			lEdita   := .F.
			lCalcFrt := .T.
			
			If !lTMSOPdg .Or. lAltTipOpVg   
				lMostra  := .F.
			EndIf
		EndIf
		aHeader   := {}
		aCols     := {}  
		aCompViag := TmsA240Mnt(,,nOpcx,M->DTQ_FILORI,M->DTQ_VIAGEM,aCompViag,M->DTQ_ROTA,cSerTms,cTipTra,@M->DTQ_OBS,,,lMostra,nTipVia,lEdita,aDoctos,aPosicao,lCalcFrt,,,,lAltRota,,,lAltTipOpVg)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as Variaveis da GetDados Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestInter()

//-- Trava o registro que está sendo usado por outra estação 
If lCONTDOC .And. !Empty(aDoctos)
	For nCont := 1 to Len(aDoctos)
		If !lAltRota			
			TmsConTran(aDoctos[nCont][3],aDoctos[nCont][4],aDoctos[nCont][5], .T.)	
		Else			
			TmsConTran(aDoctos[nCont][7],aDoctos[nCont][8],aDoctos[nCont][9], .T.)	 
		EndIf
	Next
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144DA7³ Autor ³ Richard Anderson      ³ Data ³01.11.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa pontos por zona e setor a partir do documento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor com os ceps obtidos na pesquisa do DA7       ³±±
±±³          ³ ExpC1 = Sequencia obtida na pesquisa do DA7                ³±±
±±³          ³ ExpC2 = Cliente Destinatario somente entrega               ³±±
±±³          ³ ExpC3 = Loja Destinatario somente entrega                  ³±±
±±³          ³ ExpC4 = Zona                                               ³±±
±±³          ³ ExpC5 = Setor                                              ³±±
±±³          ³ ExpC6 = CEP solicitante(Coleta) / Destinatario(Entrega)    ³±±
±±³          ³ ExpC7 = Viagem Modelo 2 de Coleta                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144DA7(cFilDoc,cDoc,cSerie,cRota,cZona,cSetor,lHelp,lVgeColet,cTipTran,cServico,aAgendPend)

Local aAreaDA7  := DA7->(GetArea())
Local aAreaDA9  := DA7->(GetArea())
Local aAreaDUE  := DUE->(GetArea())
Local aAreaDUL  := DUL->(GetArea())
Local aAreaDT6  := DT6->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local lRet      := .F.
Local cCep      := ''
Local cCliente  := ''
Local cLoja     := ''
Local cRotGCol  := Padr(GetMv('MV_ROTGCOL',,''),Len(DTQ->DTQ_ROTA))
Local cRotGEnt  := Padr(GetMv('MV_ROTGENT',,''),Len(DTQ->DTQ_ROTA))
Local cCepUsr   := ''
Local cAliasDT5 := ''
Local cAliasDT6 := ''
Local cAliasDA6 := ''
Local cAliasDA7 := ''
Local cAliasDA9 := ''
Local cQuery    := ''
Local aRetPE    := {}
Local lSolCol   := .F.
Local lDocCol   := .F.
Local lPesqCCli := SuperGetMv("MV_TMSPCLI",,.F.)	//-- Atraves deste parametro é possivel fazer com que o
													//-- Pontos por setor sejam pesquisados por codigo de Cliente.

If	Type('lColeta')=="U"
	Private lColeta := .F.
EndIf

Default cRota     := M->DTQ_ROTA
Default lHelp     := .T.
Default cZona     := Space(Len(DA9->DA9_PERCUR))
Default cSetor    := Space(Len(DA9->DA9_ROTA))
Default lVgeColet := .F.
Default cTipTran  := ''
Default cServico  := Iif(ValType(cSerTms) == 'C', cSerTms, '')
Default aAgendPend := {}

If (Empty(cRota) .And. cServico <> StrZero( 2, Len( DC5->DC5_SERTMS ) )) .Or. F11RotRote(cRota)
	Return .T.
EndIf
Pergunte("TMB144",.F.)
If Type("MV_PAR02") != "U"
	lSolCol := MV_PAR02 == '1' .And. cServico == StrZero( 3, Len( DC5->DC5_SERTMS ) )
Else
	lSolCol := .F.
EndIf

If lSolCol
	DT6->(DbSetOrder(1))
	DT6->(DbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
	If DT6->DT6_SERTMS == StrZero(1, Len(DT6->DT6_SERTMS))
		lDocCol := .T.     //-- Seleção de documentos de coleta em viagem de entrega deve ser validada como coleta
	EndIf
EndIf
If !lColeta .And. !lDocCol
	//-- Se for rota generica
	If cRota == cRotGEnt
		lRet    := .T.
	EndIf

	DT6->(DbSetOrder(1))
	DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))

	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial('SA1')+DT6->(DT6_CLIDES+DT6_LOJDES)))

	cCliente := DT6->DT6_CLIDES
	cLoja    := DT6->DT6_LOJDES
	cCep     := If(Empty(SA1->A1_CEPE),SA1->A1_CEP,SA1->A1_CEPE)

	If lTM144CEP
		cCepUsr := ExecBlock("TM144CEP",.F.,.F.,{cCep,cTipTran})
		If Valtype(cCepUsr) == 'C' .And. !Empty(cCepUsr)
			cCep := cCepUsr
		EndIf
	EndIf

	If !lRet
		cAliasDT6 := GetNextAlias()
		cQuery := "SELECT "
		cQuery += "DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, "
		cQuery += "DT6.DT6_CLIDES, DT6.DT6_LOJDES, SA1.A1_FILIAL, SA1.A1_COD, "
		cQuery += "SA1.A1_LOJA, SA1.A1_CEP, DA7.DA7_ROTA, DA7.DA7_CEPDE, "
		cQuery += "DA7.DA7_CEPATE, DA7.DA7_PERCUR, DA7.DA7_FILIAL, DA6.DA6_ALIANC, "
		cQuery += "DA9.DA9_ROTEIR, DA9.DA9_ROTA, DA9.DA9_PERCUR "
		cQuery += "FROM "+RetSqlName("DT6")+" DT6 " 
		cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON " 
		cQuery += "(SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND DT6.DT6_CLIDES = SA1.A1_COD AND DT6.DT6_LOJDES = SA1.A1_LOJA) AND SA1.D_E_L_E_T_ = '' "  		
		cQuery += "INNER JOIN "+RetSqlName("DA7")+" DA7 ON "
		If !Empty(cCep) .And. (lTM144CEP)
			cQuery += "(DA7.DA7_FILIAL = '"+xFilial("DA7")+"' AND '"+cCep+"' >= DA7.DA7_CEPDE AND '"+cCep+"' <= DA7.DA7_CEPATE) AND DA7.D_E_L_E_T_ = '' "
		Else
			cQuery += "(DA7.DA7_FILIAL  = '"+xFilial("DA7")+"' AND SA1.A1_CEP >= DA7.DA7_CEPDE AND SA1.A1_CEP <= DA7.DA7_CEPATE
			If lPesqCCli
				cQuery += " OR DA7.DA7_CLIENT = SA1.A1_COD AND DA7.DA7_LOJA = SA1.A1_LOJA "
			EndIf	
			cQuery += " )  AND DA7.D_E_L_E_T_ = '' "
		EndIf
		cQuery += "INNER JOIN "+RetSqlName("DA6")+" DA6 ON "
		cQuery += "(DA6.DA6_FILIAL = '"+xFilial("DA6")+"' AND DA6.DA6_ROTA = DA7.DA7_ROTA AND DA6.DA6_PERCUR = DA7.DA7_PERCUR) AND DA6.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN "+RetSqlName("DA9")+" DA9 ON "
		cQuery += "(DA9.DA9_FILIAL = '"+xFilial("DA9")+"' AND DA9.DA9_ROTA = DA6.DA6_ROTA AND DA9.DA9_PERCUR = DA6.DA6_PERCUR AND DA9.DA9_ROTEIR = '"+cRota+"') AND DA9.D_E_L_E_T_ = ''"
		cQuery += "WHERE DT6_FILIAL = '"+xFilial("DT6")+"' "
		cQuery += "AND DT6.DT6_FILDOC = '"+cFilDoc+"' AND DT6.DT6_DOC = '"+cDoc+"' AND DT6.DT6_SERIE = '"+cSerie+"' AND DT6.D_E_L_E_T_ = '' "                                                                                    
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT6,.T.,.T.)
		If(!Empty(Alltrim((cAliasDT6)->DA9_ROTEIR)))
			lRet 	:= .T.
			cZona  	:= (cAliasDT6)->DA9_PERCUR
			cSetor 	:= (cAliasDT6)->DA9_ROTA
		EndIf
		If(cAliasDT6)->(!Eof()) .And. (cAliasDT6)->(!Empty(DA6_ALIANC))
			//--Se alianca estiver preenchida nao analisa o cep e não considera o resultado.
			lRet := .T.
		EndIf
		(cAliasDT6)->(dbCloseArea())
	EndIf
Else

	If cRota == cRotGCol
		lRet    := .T.
	EndIf

	If !lRet
		cAliasDT5 := GetNextAlias()
		cQuery := "SELECT "
		cQuery += "DT5.DT5_SEQEND , DUL.DUL_CEP , DUE.DUE_CODCLI , DUE.DUE_LOJCLI , DUE.DUE_CEP "
		cQuery += "FROM "+RetSqlName("DT5")+" DT5 "
		cQuery += "LEFT JOIN "+RetSqlName("DUE")+" DUE ON "
		cQuery += "(DUE.DUE_FILIAL = '"+xFilial("DUE")+"' AND DUE.DUE_CODSOL = DT5.DT5_CODSOL) "
		cQuery += "LEFT JOIN "+RetSqlName("DUL")+" DUL ON "
		cQuery += "(DUL.DUL_FILIAL = '"+xFilial("DUL")+"' AND DUL.DUL_CODSOL = DT5.DT5_CODSOL AND DUL.DUL_SEQEND = DT5.DT5_SEQEND) "
		cQuery += "WHERE DT5.DT5_FILIAL = '"+xFilial("DT5")+"' "
		cQuery += "AND DT5.DT5_FILDOC = '"+cFilDoc+"' "
		cQuery += "AND DT5.DT5_DOC = '"   +cDoc+"' "
		cQuery += "AND DT5.DT5_SERIE = '" +cSerie+"' "
		cQuery += "AND DT5.D_E_L_E_T_ = '' "
		cQuery += "AND DUE.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT5,.T.,.T.)
		cCliente := (cAliasDT5)->DUE_CODCLI
		cLoja    := (cAliasDT5)->DUE_LOJCLI
		If Empty((cAliasDT5)->DT5_SEQEND)
			cCep  := (cAliasDT5)->DUE_CEP
		Else
			cCep  := (cAliasDT5)->DUL_CEP
		EndIf
		(cAliasDT5)->(dbCloseArea())

		If !Empty(cCliente) .And. !Empty(cLoja)
			cAliasDA7 := GetNextAlias()
			cQuery := "SELECT DA7.DA7_PERCUR, DA7.DA7_ROTA "
			cQuery += "FROM "+RetSqlName("DA7")+" DA7 "
			cQuery += "INNER JOIN "+RetSqlName("DA9")+" DA9 ON "
			cQuery += "(DA9.DA9_FILIAL = '"+xFilial("DA9")+"' AND DA9.DA9_PERCUR = DA7.DA7_PERCUR AND DA9.DA9_ROTA = DA7.DA7_ROTA) "
			cQuery += "WHERE DA7.DA7_FILIAL = '"+xFilial("DA7")+"' "
			cQuery += "AND DA7.DA7_CLIENT = '"+cCliente+"' "
			cQuery += "AND DA7.DA7_LOJA = '"  +cLoja   +"' "
			cQuery += "AND DA9.DA9_ROTEIR = '"+cRota   +"' "
			cQuery += "AND DA7.D_E_L_E_T_ = '' "
			cQuery += "AND DA9.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA7,.T.,.T.)
			If (cAliasDA7)->(!Eof())
				lRet   := .T.
				If lVgeColet .Or. lDocCol
					cZona  := (cAliasDA7)->DA7_PERCUR
					cSetor := (cAliasDA7)->DA7_ROTA
				EndIf
			EndIf
			(cAliasDA7)->(dbCloseArea())
		EndIf

		If !lRet
			cAliasDA6 := GetNextAlias()
			cQuery := "SELECT DA9.DA9_PERCUR, DA9.DA9_ROTA "
			cQuery += "FROM "+RetSqlName("DA9")+" DA9 "
			cQuery += "INNER JOIN "+RetSqlName("DA7")+" DA7 ON "
			cQuery += "(DA7.DA7_FILIAL = '"+xFilial("DA7")+"' AND DA7.DA7_PERCUR = DA9.DA9_PERCUR AND DA7.DA7_ROTA = DA9.DA9_ROTA) "
			cQuery += "INNER JOIN "+RetSqlName("DA6")+" DA6 ON "
			cQuery += "(DA6.DA6_FILIAL = '"+xFilial("DA6")+"' AND DA6.DA6_PERCUR = DA7.DA7_PERCUR AND DA6.DA6_ROTA = DA7.DA7_ROTA) "
			cQuery += "WHERE DA9.DA9_ROTEIR = '"+cRota+"' "
			cQuery += "AND DA6.DA6_ALIANC <> '' "
			cQuery += "AND DA9.D_E_L_E_T_ = '' "
			cQuery += "AND DA7.D_E_L_E_T_ = '' "
			cQuery += "AND DA6.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA6,.T.,.T.)
			If (cAliasDA6)->(!Eof())
				lRet   := .T.
				If lVgeColet .Or. lDocCol
					cZona  := (cAliasDA6)->DA9_PERCUR
					cSetor := (cAliasDA6)->DA9_ROTA
				EndIf
			EndIf
			(cAliasDA6)->(dbCloseArea())

			If !lRet
				cAliasDA9 := GetNextAlias()
				cQuery := "SELECT DA7.DA7_PERCUR, DA7.DA7_ROTA "
				cQuery += "FROM "+RetSqlName("DA7")+" DA7 "
				cQuery += "INNER JOIN "+RetSqlName("DA9")+" DA9 ON "
				cQuery += "(DA9.DA9_FILIAL = '"+xFilial("DA9")+"' AND DA9.DA9_PERCUR = DA7.DA7_PERCUR AND DA9.DA9_ROTA = DA7.DA7_ROTA) "
				cQuery += "WHERE DA7.DA7_FILIAL = '"+xFilial("DA7")+"' "
				cQuery += "AND '"+cCep+"' BETWEEN DA7.DA7_CEPDE AND DA7.DA7_CEPATE "
				cQuery += "AND DA9.DA9_ROTEIR = '"+cRota+"' "
				cQuery += "AND DA7.D_E_L_E_T_ = '' "
				cQuery += "AND DA9.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA9,.T.,.T.)
				If (cAliasDA9)->(!Eof())
					lRet   := .T.
					If lVgeColet .Or. lDocCol
						cZona  := (cAliasDA9)->DA7_PERCUR
						cSetor := (cAliasDA9)->DA7_ROTA
					EndIf
				EndIf
				(cAliasDA9)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
EndIf

//-- validacao se documento pertence a rota
If lTM144ROK
	aRetPE := ExecBlock("TM144ROK",.F.,.F.,{cFilDoc,cDoc,cSerie,cRota,lHelp,lRet})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) == 2 .And. ValType(aRetPE[1]) == "L" .And. ValType(aRetPE[2]) == "L"
		lRet  := aRetPE[1]
		lHelp := aRetPE[2]
		If !lRet
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0129})
				EndIf
			Else
				Help(' ', 1, 'TMSA144K6')	//-- "Validação por rotina de usuário"
			EndIf
		EndIf
	EndIf
EndIf

If !lRet .And. lHelp
	If IsInCallStack("AF76VldAgd")
		If !Empty(aAgendPend)
			Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0128})
		EndIf
	Else
		Help(' ', 1, 'TMSA14409') //"Documento não pertence a esta rota"
		If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))  //Viagem em trânsito exibe o alerta e permite incluir o documento
			lRet   := .T.
		EndIf
	EndIf
EndIf

RestArea( aAreaDA9 )
RestArea( aAreaDA7 )
RestArea( aAreaDUE )
RestArea( aAreaDUL )
RestArea( aAreaDT6 )
RestArea( aAreaSA1 )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSConsDF1³ Autor ³ Richard Anderson      ³ Data ³ 29/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe browse de itens do agendamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSConsDF1()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA144                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsConsDF1()

Local cCadastro  := STR0025 //"Itens de Agendamentos"
Local aRotOld    := AClone(aRotina)
Local aCampos    := {}
Local cFiltraDF1 := ''
Local nRecnoDF1  := 0
Local lAllRot    := .F.
Local lDic       := .F.
Local cCampo     := ""
Local cPicture   := ""
Local cTitulo    := ""
Local nTamanho   := 0, nI := 0
Local lTM144COL  := ExistBlock( 'TM144COL' ) //-- Permite ao usuario, incluir colunas nos itens.
Local aFldsDF1	 := {}

Private nOpcSel := 0

aFldsDF1 := ApBuildHeader("DF1")
For nI := 1 To Len(aFldsDF1)
	If GetSX3Cache(aFldsDF1[nI][2], "X3_BROWSE") == "S"
		If GetSX3Cache(aFldsDF1[nI][2], "X3_CONTEXT") == "V"
			cCampo := &("{||"+GetSX3Cache(aFldsDF1[nI][2], "X3_INIBRW")+"}")
		Else
			cCampo := aFldsDF1[nI][2]
		EndIf
		AAdd(aCampos,{ cCampo,aFldsDF1[nI][3],aFldsDF1[nI][1],aFldsDF1[nI][4] })
	EndIf
Next

aSize(aFldsDF1, 0)
aFldsDF1 := Nil

//-- Inclui colunas do usuario
If lTM144COL
	If ValType( aUsrCol := ExecBlock( 'TM144COL', .F., .F. ) ) <> 'A'
		aUsrCol := {}
	EndIf
	For nI := 1 To Len(aUsrCol)
		cCampo   := &("{||"+aUsrCol[nI,1]+"}")
		cPicture := Iif(ValType(aUsrCol[nI,2]) <> "C","@!",aUsrCol[nI,2])
		cTitulo  := Iif(ValType(aUsrCol[nI,3]) <> "C","Sem Titulo",aUsrCol[nI,3])
		nTamanho := Iif(ValType(aUsrCol[nI,4]) <> "N",10,aUsrCol[nI,4])
		AAdd(aCampos,{ cCampo,cPicture,cTitulo,nTamanho })
	Next
EndIf

aRotina := {}
AAdd( aRotina, {STR0009,"TMSA144Age",0,2,,,.F.} ) //"Visualizar"
AAdd( aRotina, {STR0026,"TMSConfSel",0,2,,,.T.} ) //"Confirmar"

DF1->(DbSetOrder(1))
cFiltraDF1 := "DF1_FILIAL= '"+xFilial("DF1")+"' AND DF1_STACOL= '2'"
DF1->( DbSetFilter({ || .T. }, "@"+cFiltraDF1 ) )

MaWndBrowse(0,0,300,600,cCadastro,"DF1",aCampos,aRotina,,,,.T.,,,,,lDic)

nRecnoDF1 := DF1->(Recno())
aRotina   := AClone(aRotOld)

DF1->( dbClearFilter() )

DF1->(dbGoTo(nRecnoDF1))

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA144Age³ Autor ³ Richard Anderson      ³ Data ³ 29/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Visualiza agendamento                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSConsAge()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA144                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Age(cAlias,nRecno,nOpcx,lButton)

Local lIncAnt := Inclui
Local lAltAnt := Altera
Local cNumAge := ''

Default lButton := .F.

If ValType(lButton) != "L"
	lButton := .F.
EndIf

If lButton
	cNumAge := GdFieldGet("DF1_NUMAGE",n)
	If Empty(cNumAGe)
		Return( Nil )
	EndIf
Else
	cNumAge := DF1->DF1_NUMAGE
EndIf

Inclui := .F.
Altera := .F.

DF0->(DbSetOrder(1))
DF0->(MsSeek(xFilial("DF0")+cNumAge))

TMSF05Mnt("DF0",DF0->(Recno()),nOpcx)

Inclui := lIncAnt
Altera := lAltAnt

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144Doc³ Autor ³ TOTVS S/A             ³ Data ³09/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Preenche os vetores aDocto e aRota                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA144Doc( nOpcx, lDupEnt, lVgeExpr )

Local lHelp   := .F.
Local nCntFor := 0
Local aDocAux := Array(55)
Local aRotAux := Array(09)
Local cFilDoc := ''
Local cDoc    := ''
Local cSerie  := ''
Local cZona   := Space(Len(DA9->DA9_PERCUR))
Local cSetor  := Space(Len(DA9->DA9_ROTA))
Local lTMS3GFE   := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lDTAOrigem := DTA->(ColumnPos('DTA_ORIGEM')) > 0

Default lDupEnt  := .T.
Default lVgeExpr := .F.

aDocto := {}

// aRota[01] = Mark
// aRota[02] = Codigo da Rota
// aRota[09] = Permite ou nao desmarcar a rota da tela
aRotAux[01] := .T.
aRotAux[02] := M->DTQ_ROTA
aRotAux[05] := 0
aRotAux[06] := 0
aRotAux[07] := 0
aRotAux[08] := 0
aRotAux[09] := .F.
AAdd(aRota,AClone(aRotAux))

For nCntFor := 1 To Len(aCols)

	//-- Despreza os excluidos na inclusao
	If nOpcx == 3 .And. GdDeleted(nCntFor)
		Loop
	EndIf
	
	AFill(aDocAux,Nil)
	
	cFilDoc := GdFieldGet('DTA_FILDOC',nCntFor)
	cDoc    := GdFieldGet('DTA_DOC'   ,nCntFor)
	cSerie  := GdFieldGet('DTA_SERIE' ,nCntFor)
	
	aDocAux[CTSTATUS] := GdFieldGet('DUD_STATUS',nCntFor)
	aDocAux[CTMARCA ] := If(GdDeleted(nCntFor),.F.,.T.)
	aDocAux[CTARMAZE] := If(lLocaliz,GdFieldGet('DTA_LOCAL' ,nCntFor),'')
	aDocAux[CTLOCALI] := If(lLocaliz,GdFieldGet('DTA_LOCALI',nCntFor),'')
	aDocAux[CTUNITIZ] := If(lLocaliz,GdFieldGet('DTA_UNITIZ' ,nCntFor),'')
	aDocAux[CTCODANA] := If(lLocaliz,GdFieldGet('DTA_CODANA' ,nCntFor),'')
	aDocAux[CTFILDOC] := cFilDoc
	aDocAux[CTDOCTO ] := cDoc
	aDocAux[CTSERIE ] := cSerie
	If lDTAOrigem 
		aDocAux[CTORIGEM] := GdFieldGet('DTA_ORIGEM',nCntFor)
	EndIf	
	
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte

		aDocAux[CTSTROTA] := GdFieldGet('DUD_STROTA',nCntFor)
		aDocAux[CTSEQUEN] := ''
		aDocAux[CTQTDVOL] := GdFieldGet('DTA_QTDVOL',nCntFor)
		aDocAux[CTPLIQUI] := GdFieldGet('DT6_PESO'  ,nCntFor)
		aDocAux[CTVIAGEM] := .T.
	Else
		If !lVgeExpr // Gravacao da zona e setor sera realizada no calculo do frete.
			If !F11RotRote(M->DTQ_ROTA)
				//-- Localiza zona e setor da rota a partir do documento
				If cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)) //-- Coleta
					TmsA144DA7(cFilDoc,cDoc,cSerie,,@cZona,@cSetor,lHelp,.T.)
				Else
					TmsA144DA7(cFilDoc,cDoc,cSerie,,@cZona,@cSetor,lHelp,.F.)
				EndIf
			EndIf
		EndIf

		aDocAux[CTSTROTA] := ''
		aDocAux[CTSEQUEN] := GdFieldGet('DUD_SEQUEN',nCntFor)
		aDocAux[CTQTDVOL] := GdFieldGet('DTA_QTDVOL',nCntFor)
		aDocAux[CTPLIQUI] := GdFieldGet('DT6_PESO'  ,nCntFor)
		aDocAux[CTVIAGEM] := .T.
		aDocAux[CTDOCROT] := M->DTQ_ROTA+cZona+cSetor
		aDocAux[CTSERTMS] := cSerTms
		If lTmsCFec .And. lColeta
			aDocAux[CTNUMAGE] := GdFieldGet('DF1_NUMAGE',nCntFor)
			aDocAux[CTITEAGE] := GdFieldGet('DF1_ITEAGE',nCntFor)
		EndIf
	EndIf
	If lTMS3GFE .Or. lTmsRdpU
		aDocAux[ CTUFORI  ]:= GdFieldGet('DUD_UFORI',nCntFor)
		aDocAux[ CTCDMUNO ]:= GdFieldGet('DUD_CDMUNO',nCntFor)
		aDocAux[ CTCEPORI ]:= GdFieldGet('DUD_CEPORI',nCntFor)
		aDocAux[ CTUFDES  ]:= GdFieldGet('DUD_UFDES',nCntFor)
		aDocAux[ CTCDMUND ]:= GdFieldGet('DUD_CDMUND',nCntFor)
		aDocAux[ CTCEPDES ]:= GdFieldGet('DUD_CEPDES',nCntFor)
		aDocAux[ CTTIPVEI ]:= GdFieldGet('DUD_TIPVEI',nCntFor)
		aDocAux[ CTCDTPOP ]:= GdFieldGet('DUD_CDTPOP',nCntFor)
		aDocAux[ CTCDCLFR ]:= GdFieldGet('DUD_CDCLFR',nCntFor)
	EndIf
	AAdd(aDocto,AClone(aDocAux))
	//-- Duplica linha quando o destinatario for preenchido atraves do agendamento.
	If lDupEnt .And. lTmsCFec .And. lColeta .And. !Empty(aDocAux[31])
		DT5->(DbSetOrder(4))
		If DT5->(MsSeek(xFilial('DT5')+cFilDoc+cDoc+cSerie))
			If !Empty( DT5->DT5_CLIDES ) .And. !Empty( DT5->DT5_LOJDES )
				AAdd(aDocto,AClone(aDocAux))
				aDocto[Len(aDocto),33] := StrZero(3,Len(DUD->DUD_SERTMS)) //-- Entrega
			EndIf
		EndIf
	EndIf
	
	//Chamada de Ponto de Entrada para Armazenamento de campo específico no aDocto.
	If lTM144BKP
		ExecBlock("TM144BKP",.F.,.F.,{nCntFor})
	EndIf
Next

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA144Ord ³ Autor ³Eduardo de Souza      ³ Data ³ 06/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reordena Itens da coleta/entrega.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Ord()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Ord()

Local aColsTRB	  := AClone( aCols )
Local bBloco
Local cSequencia  := &( ReadVar() )
Local cArmazem	  := ''
Local cEndereco	  := ''
Local cFilDoc	  := GDFieldGet('DTA_FILDOC', n )
Local cDocto	  := GDFieldGet('DTA_DOC'   , n )
Local cSerie	  := GDFieldGet('DTA_SERIE' , n )
Local lBaixo	  := .F.
Local nCntFor	  := 0
Local nNewSequen  := 0
Local nPosSequen  := GDFieldPos('DUD_SEQUEN')
Local nPosArmazem := GDFieldPos('DTA_LOCAL' )
Local nPosLocali  := GDFieldPos('DTA_LOCALI')
Local nPosFilDoc  := GDFieldPos('DTA_FILDOC')
Local nPosDocto   := GDFieldPos('DTA_DOC'   )
Local nPosSerie   := GDFieldPos('DTA_SERIE' )
Local nPosStatus  := GDFieldPos('DUD_STATUS')
Local nSeek       := 0

If	lLocaliz .And. !lColeta
	cArmazem  := GDFieldGet('DTA_LOCAL' , n )
	cEndereco := GDFieldGet('DTA_LOCALI', n )
EndIf

//-- Teclou enter sem alterar a sequencia.
If cSequencia == GDFieldGet('DUD_SEQUEN',n)
	Return( .T. )
EndIf

//-- Procura a sequencia digitada no aCols.
nSeek := Ascan( aCols,{ |x| x[ nPosSequen ] == cSequencia } )

If Empty( nSeek )
	//-- Nao permite informar sequencia que nao exista.
	Help(' ', 1, 'TMSA14007')		//-- Sequencia nao encontrada.
	Return( .F. )
Else
	If	lLocaliz .And. !lColeta
		nSeek := Ascan( aCols,{ | x | x[nPosArmazem]+x[nPosLocali]+x[nPosFilDoc]+x[nPosDocto]+x[nPosSerie] == ;
		GDFieldGet('DTA_LOCAL',nSeek)+GDFieldGet('DTA_LOCALI',nSeek)+GDFieldGet('DTA_FILDOC',nSeek)+GDFieldGet('DTA_DOC',nSeek)+GDFieldGet('DTA_SERIE',nSeek) })
	Else
		nSeek := Ascan( aCols,{ | x | x[nPosFilDoc]+x[nPosDocto]+x[nPosSerie] == ;
		GDFieldGet('DTA_FILDOC',nSeek)+GDFieldGet('DTA_DOC',nSeek)+GDFieldGet('DTA_SERIE',nSeek) })
	EndIf
	If nSeek > 0
		If aCols[nSeek,nPosStatus] == StrZero(3,Len(DUD->DUD_STATUS))
			//-- Nao permite digitar o nr. da sequencia de um documento carregado.
			If	lLocaliz .And. !lColeta
				Help(' ', 1, 'TMSA14008',,STR0037 + GDFieldGet('DTA_LOCAL',nSeek) + ' / '+ GDFieldGet('DTA_LOCALI',nSeek) + ' / '+ GDFieldGet('DTA_DOC',nSeek) + ' / '+ GDFieldGet('DTA_SERIE',nSeek),4,3)		//-- Esta sequencia pertence a um documento carregado !###"Armazem/Endereco/Docto/Serie : "
			Else
				Help(' ', 1, 'TMSA14008',,STR0038 + GDFieldGet('DTA_DOC',nSeek) + ' / '+ GDFieldGet('DTA_SERIE',nSeek),4,3)		//-- Esta sequencia pertence a um documento carregado !###"Docto/Serie : "
			EndIf
			Return( .F. )
		EndIf
	EndIf
EndIf

//-- Ordena o vetor de trabalho pela sequencia.
ASort( aColsTRB,,,{|x,y| x[nPosSequen] < y[nPosSequen] } )
//-- Mover a linha atual para baixo.
lBaixo := cSequencia > aColsTRB[ n, nPosSequen ]
//-- Grava no vetor de trabalho a sequencia digitada.
aColsTRB[ n, nPosSequen ] := cSequencia
ASort( aColsTRB,,,{|x,y| x[nPosSequen] < y[nPosSequen] } )
//-- Altera a sequencia.
For nCntFor := 1 To Len( aColsTRB )
	//-- Desconsidera a linha alterada.
	If lLocaliz .And. !lColeta
		bBloco := {|| aColsTRB[ nCntFor,GDFieldPos('DTA_LOCAL')] + aColsTRB[ nCntFor,GDFieldPos('DTA_LOCALI')] + aColsTRB[ nCntFor,GDFieldPos('DTA_FILDOC')] + aColsTRB[ nCntFor,GDFieldPos('DTA_DOC')] + aColsTRB[nCntFor,GDFieldPos('DTA_SERIE')] != cArmazem + cEndereco + cFilDoc + cDocto + cSerie }
	Else
		bBloco := {|| aColsTRB[ nCntFor,GDFieldPos('DTA_FILDOC')] + aColsTRB[ nCntFor,GDFieldPos('DTA_DOC')] + aColsTRB[nCntFor,GDFieldPos('DTA_SERIE')] != cFilDoc + cDocto + cSerie }
	EndIf

	If Eval( bBloco )
		If	aColsTRB[ nCntFor, nPosSequen ] == cSequencia
			If lBaixo
				aColsTRB[ nCntFor, nPosSequen ] := StrZero( nCntFor, Len( DUD->DUD_SEQUEN ) )
				Exit
			Else
				nNewSequen := Val(cSequencia) + 1
				aColsTRB[ nCntFor, nPosSequen ] := StrZero( nNewSequen, Len( DUD->DUD_SEQUEN ) )
			EndIf
		Else
			aColsTRB[ nCntFor, nPosSequen ] := StrZero( nNewSequen += 1, Len( DUD->DUD_SEQUEN ) )
		EndIf
	EndIf

Next
//-- Ordena o vetor de trabalho pela sequencia.
ASort( aColsTRB,,,{|x,y| x[nPosSequen] < y[nPosSequen] } )

&(ReadVar()):= aColsTRB[n,nPosSequen]

aCols := AClone( aColsTRB )

If lLocaliz .And. ! lColeta
	n := Ascan( aCols,{|x| x[GDFieldPos('DTA_LOCAL')] + x[GDFieldPos('DTA_LOCALI')] + x[GDFieldPos('DTA_FILDOC')] + x[GDFieldPos('DTA_DOC')] + x[GDFieldPos('DTA_SERIE')] == cArmazem + cEndereco + cFilDoc + cDocto + cSerie })
Else
	n := Ascan( aCols,{|x| x[GDFieldPos('DTA_FILDOC')] + x[GDFieldPos('DTA_DOC')] + x[GDFieldPos('DTA_SERIE')] == cFilDoc + cDocto + cSerie })
EndIf

oGetD:oBrowse:Refresh(.T.)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144Dc ³ Autor ³ Eduardo de Souza      ³ Data ³ 03/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta os documentos da rota                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Dc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Dc()

Static lTM144CDC := ExistBlock( 'TM144CDC' ) //-- Permite ao usuario, incluir colunas nos documento.
Local oDlgEsp
Local oLbx
Local cLbx       := ""
Local cAliasNew  := ""
Local cQuery     := ""
Local aButtons   := {}
Local oNoMarked  := LoadBitmap( GetResources(),'LBNO' )
Local oMarked    := LoadBitmap( GetResources(),'LBOK' )
Local nOpca      := 0
Local aOldRota   := aClone(aRota)
Local aHDocto    := {}
Local nCnt       := 0
Local lMarca     := .F.
Local lVazio     := .F.
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local lVgeTran   := .F.
Local cFiltraDUD := ""
Local lCteExp	   := ExistBlock("TMCteExp") //-- Ponto de Entrada(TMCteExp) , retornando valor booleano false(.F.) impedirá a transmissão automática do Cte pela viagem express. 
Local lCtetra    := .T. 		

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Private aUsHDocto := {}
Private aAllZona  := {}
Private lColeta   := (cSerTms == StrZero(1, Len(DC5->DC5_SERTMS)))
Private cRotGen   := Iif(lColeta,GetMv('MV_ROTGCOL',,''),GetMv('MV_ROTGENT',,'')) //Rota generica para coleta //Rota generica para entreg
Private nRotGen   := 1
Private cGrpProd  := ''
Private aAllDocto := {}

If	lVgeExpr == Nil
	lVgeExpr := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem dos parâmetros para criação da tela de exibição     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2}
aPosObj := MsObjSize( aInfo, aObjects,.T.)

If lSelDoc == Nil
	If SuperGetMv("MV_SELDOC",.F.,"2") == "1"
		lSelDoc := .T.
	Else
		lSelDoc := .F.
	EndIf
EndIf

//-- Verifica se os documentos serao selecionados.
If (!lSelDoc .Or. Empty(M->DTQ_ROTA) .Or. Left(FunName(),7) <> "TMSA144") 
	//--Verifica se a funcao foi acionada pelo
	//--processo de geracao de viagem express
	If !(TmsExp() .And. lVgeExpr)
		Return( .F. )
	EndIf
EndIf

If lCteExp .And. lVgeExpr
	lCtetra := ExecBlock("TMCteExp",.F.,.F.)		
	If ValType(lCtetra) <> "L" 
		lCtetra := .T.
	EndIf	
EndIf

//-- Viagem Express, apresentar a consulta somente se o documento já estiver carregado na viagem (aDocRot)
If ExistFunc("TMSC080") .And. (!(TmsExp() .And. lVgeExpr) .Or. !Empty(aDocRot) )
	If M->DTQ_STATUS == '2'
		lVgeTran := .T.
	EndIf
	//-- Quando for o processo de retirada de mercadoria não prevista,
	//-- mesmo que a viagem esteja com status em Trânsito, permite incluir 
	//-- tanto solicitação de coleta quanto CTRC
	If lPrcMerNpr 
		lVgeTran := .F.
	EndIf
	DUD->(dbSetOrder(6))
	cFiltraDUD := "DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD_FILORI = '" + cFilAnt + "'") + " AND DUD_TIPTRA = '" + cTipTra + "' AND DUD_STATUS = '1' AND DUD_VIAGEM = ' ' "
	If cSerTms <> StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. ((! Empty(cSerAdi) .And. cSerAdi <> '0') .Or. lPrcMerNpr)
		If lVgeTran
			cFiltraDUD += " AND DUD_SERTMS = '"+cSerAdi+"'"
		Else				
			cFiltraDUD += " AND (DUD_SERTMS = '"+cSerTMS+"' OR DUD_SERTMS = '"+cSerAdi+"')"
		EndIf				
	Else			
		cFiltraDUD += " AND DUD_SERTMS = '"+cSerTMS+"'"
	EndIf			
	cFiltraDUD += " AND DUD_NUMRED = ' ' "
	
	If lCteTra
		nOpcSel   := TMSC080(cFiltraDUD,.T.)
	EndIf

	//-- Restaura array de Rotas
	aRota := aClone(aOldRota)
	If lCtetra
		Return .T.
	EndIf
EndIf

//-- Inclui colunas do usuario
If lTM144CDC
	If ValType( aUsHDocto := ExecBlock( 'TM144CDC', .F., .F. ) ) <> 'A'
		aUsHDocto := {}
	EndIf
EndIf

AAdd(aButtons,	{'SDUPROP', {|| lMarca := !lMarca, Aeval( aAllDocto, {|aElem| aElem[1] := lMarca }) ,oLbx:Refresh() }, STR0030 , STR0031 }) //"Marca/Desmarca"
AAdd(aButtons,	{'PESQUISA'  , {|| TmsA144Psq(@oLbx) }, STR0027 }) //"Pesquisa"
AAdd(aButtons,	{'DEVOLNF'   , {|| TMSViewDoc(aAllDocto[oLbx:nAT,2],aAllDocto[oLbx:nAT,3],aAllDocto[oLbx:nAT,4]) }, STR0028 , STR0029 }) //"Documento"
//-- Carrega os documentos
If (nPos := Ascan( aDocRot, { |x| x[1] == M->DTQ_ROTA })) > 0 .And. !Empty(aDocRot[nPos,2])
	aAllDocto := aClone(aDocRot[nPos,2])
	Aeval( aAllDocto, {|aElem| aElem[1] := .F.})
Else
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		TMSA144DTp( M->DTQ_ROTA,Iif(Inclui,3,Iif(Altera,4,2)) )
	Else
		TmsA141ZSt( M->DTQ_ROTA, .T. , Iif(Inclui,3,Iif(Altera,4,2)) )
		AAdd( aDocRot, { M->DTQ_ROTA, aClone(aAllDocto) } )
	EndIf
EndIf

//-- Inicializa array vazio qdo nao encontrar documentos na rota
If Empty(aAllDocto)
	AAdd( aAllDocto, { .F., '', '', '', 0, 0, 0, 0, '', '', '', '', CTOD(''), '' } )
	lVazio := .T.
EndIf

//--Verifica se a funcao foi acionada pelo processo de geracao de viagem express
If TmsExp() .And. lVgeExpr
	//-- Nao retornou conhecimentos = bloqueado, valor frete zerado, pertence a uma rota diferente, etc.
	If lVazio
		cAliasNew := GetNextAlias()
		cQuery := "SELECT DUD.DUD_ZONA, DUD.DUD_SETOR, DTP.R_E_C_N_O_ RECDTP"
		cQuery += " FROM " + RetSQLTab("DTP") + ", " + RetSQLTab("DUD") + ", " + RetSQLTab("DT6")
		cQuery += " WHERE DTP.DTP_FILIAL = '" + xFilial("DTP")+ "'"
		cQuery += " AND DTP.DTP_FILORI = '" + M->DTQ_FILORI + "'"
		cQuery += " AND DTP.DTP_VIAGEM = '" + M->DTQ_VIAGEM + "'"
		cQuery += " AND DTP.DTP_STATUS = '3'" //-- 3=Calculado -> Conhecimento gerado
		cQuery += " AND DTP.D_E_L_E_T_ = ' '"
		//-- documento gerado para viagem express
		cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
		cQuery += " AND DT6.DT6_FILORI = DTP.DTP_FILORI"
		cQuery += " AND DT6.DT6_LOTNFC = DTP.DTP_LOTNFC"
		cQuery += " AND DT6.D_E_L_E_T_ = ' '"
		//-- Movimento de Viagem
		cQuery += " AND DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
		cQuery += " AND DUD.DUD_FILORI = DT6.DT6_FILORI"
		cQuery += " AND DUD.DUD_DOC    = DT6.DT6_DOC"
		cQuery += " AND DUD.DUD_SERIE  = DT6.DT6_SERIE"
		cQuery += " AND DUD.DUD_VIAGEM = DTP.DTP_VIAGEM"
		cQuery += " AND DUD.DUD_SERTMS = '" + cSerTms + "'"
		cQuery += " AND DUD.DUD_TIPTRA = '" + cTipTra + "'"
		cQuery += " AND DUD.DUD_STATUS IN ('" + StrZero(1,Len(DUD->DUD_STATUS)) + "','" + StrZero(3,Len(DUD->DUD_STATUS))+ "')"
		cQuery += " AND DUD.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery( cQuery )
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T.)
		While (cAliasNew)->(!Eof())
			If Empty((cAliasNew)->(DUD_ZONA+DUD_SETOR))
				//-- Retornou documentos de rotas sem definicao de Pontos por Setor
				Help(' ', 1, 'TMSA14430') //-- "Não foi possível localizar Pontos por Setor para os documentos."
				Exit
			EndIf
			(cAliasNew)->(DbSkip())
		EndDo
		(cAliasNew)->(DbCloseArea())
	Else
		nOpca := 1
	EndIf
Else
	AAdd( aHDocto, ' '     )
	AAdd( aHDocto, STR0033 ) //"Fil. Docto"
	AAdd( aHDocto, STR0028 ) //"Documento"
	AAdd( aHDocto, STR0034 ) //"Serie"
	//-- Inclui colunas do usuario
	If lTM144CDC
		For nCnt := 1 To Len(aUsHDocto)
			AAdd(aHDocto, aUsHDocto[nCnt,1])
		Next nCnt
	EndIf
	//-- Botoes
	AAdd(aButtons, {'SDUPROP' , {|| lMarca := !lMarca, Aeval( aAllDocto, {|aElem| aElem[1] := lMarca }) ,oLbx:Refresh() }, STR0030 , STR0031 }) //"Marca/Desmarca"
	AAdd(aButtons, {'PESQUISA', {|| TmsA144Psq(@oLbx) }, STR0027 }) //"Pesquisa"
	AAdd(aButtons, {'DEVOLNF' , {|| TMSViewDoc(aAllDocto[oLbx:nAT,2],aAllDocto[oLbx:nAT,3],aAllDocto[oLbx:nAT,4]) }, STR0028 , STR0029 }) //"Documento"
	//-- Tela de selecao de documentos
	DEFINE MSDIALOG oDlgEsp TITLE STR0032 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL //"Documentos"
		oLbx:= TWBrowse():New( (aSize[7]+030), 000, aSize[3], (aSize[4]-030), Nil, aHDocto, Nil, oDlgEsp, Nil, Nil, Nil,,,,,,,,,, "ARRAY", .T. )
		oLbx:SetArray( aAllDocto )
		oLbx:bLDblClick  := { || aAllDocto[oLbx:nAT,1] := !aAllDocto[oLbx:nAT,1] }
		oLbx:bLine := &('{ || TMSA144Line(oLbx:nAT) }')
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpca := 1, oDlgEsp:End()},{||oDlgEsp:End()},,aButtons) CENTERED
EndIf

If nOpca == 1
	Processa({|| TMSA144Atu(.T.)}, STR0023 ) //"Aguarde...."
	
ElseIf nOpca == 0
	nPosFilD := 0
	lVgeExpr := .F.
	For nCnt := 1 To Len(aAllDocto)
		aAllDocto[nCnt,1] := .F.
	Next
	Processa({|| TMSA144Atu(.T.)}, STR0023 ) //"Aguarde...."
EndIf

//-- Restaura array de Rotas
aRota := aClone(aOldRota)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA144Psq³ Autor ³ Eduardo de Souza      ³ Data ³ 03/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa documentos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Psq(ExpO1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - List Box                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Psq(oLbx)

Local aCbx   := {}
Local cCampo := ''
Local cOrd   := ''
Local lSeek  := .F.
Local nOrdem := 1
Local nSeek  := 0
Local oCbx
Local oDlg
Local oPsqGet

//-- (01) Fil.Docto. + No.Docto. + Serie
cCampo := AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
AAdd( aCbx, cCampo )

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0027 //"Pesquisa"

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	//-- (01) Fil.Docto. + No.Docto. + Serie
	cCampo := AllTrim( cCampo )
	ASort(aAllDocto,,,{|x,y| x[2] + x[3] + x[4] < y[2] + y[3] + y[4]})
	nSeek := Ascan(aAllDocto,{ | x | PadR( x[2] + x[3] + x[4], Len(cCampo)) == cCampo})
EndIf

If	nSeek > 0
	oLbx:nAT := nSeek
	oLbx:Refresh()
EndIf

oLbx:SetFocus()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA144Atu³ Autor ³ Eduardo de Souza      ³ Data ³ 03/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza aCols de documentos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Atu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144Atu(lHelpUnq)

Local cSequen    := IIF(GDFieldPos("DUD_SEQUEN")==0,1,GdFieldGet("DUD_SEQUEN",n))
Local nCnt       := 0
Local lAddNew    := .F.
Local aArea      := GetArea()
Local lTMS3GFE	:= Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local aRetGFE		:= {} 
Default lHelpUnq := .F.

If lHelpUnq
	aVisErr := {}
	aBkp := {IIf(Type("lMsErroAuto")!="U",lMsErroAuto,.F.),;
			IIf(Type("lMsHelpAuto")!="U",lMsHelpAuto,.F.),;
			IIf(Type("lAutoErrNoFile")!="U",lAutoErrNoFile,.F.),;
			NomeAutoLog(),;
			aClone(GetAutoGRLog())}
	lMsErroAuto    := .F.	
	lMsHelpAuto    := .T.
	lAutoErrNoFile := .T.	
EndIf

//-- Carrega as posicoes na primeira chamada.
If nPosFilD == 0
	nPosFilD  := GDFieldPos("DTA_FILDOC")
	nPosDoc   := GDFieldPos("DTA_DOC")
	nPosSerie := GDFieldPos("DTA_SERIE")
EndIf
If Len(aAllDocto) > 0
	ASort( aAllDocto,,,{|x,y| x[1] > y[1] })
EndIf

If (lVgeExpr)
	
	If Type("aColsEXP") == "A" .And. Len(aColsEXP) > 0 
		If !Empty(aColsEXP[Len(aColsEXP)][nPosDoc]) .And. !Empty(aColsEXP[Len(aColsEXP)][nPosSerie])
			cSequen := Soma1(aColsEXP[Len(aColsEXP)][1])
			lAddNew := .T.
		Else
			cSequen := aColsEXP[1][1]		
		EndIf		
		aHeader := aClone(aHeaderEXP)
		aCols   := aClone(aColsEXP)

        nPosFilD  := GDFieldPos("DTA_FILDOC")
        nPosDoc   := GDFieldPos("DTA_DOC")
        nPosSerie := GDFieldPos("DTA_SERIE")
	EndIf	
EndIf
For nCnt := 1 To Len(aAllDocto)
	If (!lVgeExpr)
		//-- Somente documentos marcados
		If !aAllDocto[nCnt,1]
			Exit
		EndIf
		//-- Verifica se o documento ja foi informado
		If Ascan( aCols, { |x| x[nPosFilD] + x[nPosDoc] + x[nPosSerie] == aAllDocto[nCnt,2] + aAllDocto[nCnt,3] + aAllDocto[nCnt,4] } ) <> 0
			Loop
		EndIf
		//-- Inclui nova linha na aCols
		If lAddNew
			TMSA210Cols()
			n := Len(aCols)
		Else
			lAddNew := .T.
		EndIf

		GDFieldPut( 'DTA_FILDOC', aAllDocto[nCnt,2] , n )
		GDFieldPut( 'DTA_DOC'   , aAllDocto[nCnt,3] , n )
		GDFieldPut( 'DTA_SERIE' , aAllDocto[nCnt,4] , n )

		//-- Atualiza dados do documento.
		M->DTA_SERIE := aAllDocto[nCnt,4]
		If TmsA210Val('M->DTA_SERIE')
			If cSerTms != StrZero(2,Len(DC5->DC5_SERTMS)) //-- Se não for transporte
				GdFieldPut("DUD_SEQUEN",cSequen,Len(aCols))
				cSequen := Soma1(CVALTOCHAR(cSequen))
			EndIf
		Else
			If (!Empty(GdFieldGet('DTA_FILDOC',n)) .Or. !Empty(GdFieldGet('DTA_DOC',n)) .Or. !Empty(GdFieldGet('DTA_SERIE',n)))
				GdFieldPut('DTA_FILDOC',  (Space(FWGETTAMFILIAL)), n)
				GdFieldPut('DTA_DOC',    Space(Len(DTA->DTA_DOC)), n)
				GdFieldPut('DTA_SERIE',Space(Len(DTA->DTA_SERIE)), n)
			EndIf
			lAddNew:= .F.
		EndIf
	Else
		
		//-- Verifica se o documento ja foi informado
		If Ascan( aCols, { |x| x[nPosFilD] + x[nPosDoc] + x[nPosSerie] == aAllDocto[nCnt,2] + aAllDocto[nCnt,3] + aAllDocto[nCnt,4] } ) <> 0
			Loop
		EndIf
		//-- Inclui nova linha na aCols
		If lAddNew
			TMSA210Cols()
			n := Len(aCols)
		Else
			lAddNew := .T.
		EndIf

		aCols[n][1] := cSequen
		aCols[n][GdFieldPos('DTA_FILDOC')] := aAllDocto[nCnt,2]  //-- 3
		aCols[n][GdFieldPos('DTA_DOC'   )] := aAllDocto[nCnt,3]  //-- 4
		aCols[n][GdFieldPos('DTA_SERIE' )] := aAllDocto[nCnt,4]  //-- 5

		If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) //--Entrega
			aCols[n][GdFieldPos('DT6_NOMREM')] := aAllDocto[nCnt,14] //-- 6
			aCols[n][GdFieldPos('DT6_NOMDES')] := aAllDocto[nCnt,10] //-- 7
			aCols[n][GdFieldPos('DUE_BAIRRO')] := aAllDocto[nCnt,11] //-- 8
			aCols[n][GdFieldPos('DUE_MUN'   )] := aAllDocto[nCnt,12] //-- 9
			aCols[n][GdFieldPos('DUE_EST'   )] := aAllDocto[nCnt,13] //-- 10
			aCols[n][GdFieldPos('DTA_QTDVOL')] := aAllDocto[nCnt,5]  //-- 12
			aCols[n][GdFieldPos('DT6_VOLORI')] := aAllDocto[nCnt,6]  //-- 13
			aCols[n][GdFieldPos('DT6_PESO'  )] := aAllDocto[nCnt,7]  //-- 14
			aCols[n][GdFieldPos('DT6_PESOM3')] := aAllDocto[nCnt,8]  //-- 15
			aCols[n][GdFieldPos('DT6_VALMER')] := aAllDocto[nCnt,9]  //-- 16
			DbSelectArea("DUD")
			DbSetOrder(1)
			If DbSeek(xFilial("DUD")+aAllDocto[nCnt,2]+aAllDocto[nCnt,3]+aAllDocto[nCnt,4]+M->DTQ_FILORI+M->DTQ_VIAGEM)
				aCols[n][GdFieldPos('DUD_STATUS')] := DUD->DUD_STATUS
			EndIf	
			
			//--- Preenche campos para integracao GFE  
			If (lTMS3GFE .Or. lTmsRdpU) .And. M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
				aRetGFE:= Tmsa210GFE(, cSerTMS, M->DTQ_FILORI, M->DTQ_VIAGEM, .F.)
				If Len(aRetGFE) > 0
					aCols[n][GdFieldPos('DUD_UFORI')]  := aRetGFE[1]
					aCols[n][GdFieldPos('DUD_CDMUNO')] := aRetGFE[2]
					aCols[n][GdFieldPos('DUD_MUNORI')] := aRetGFE[3]
					aCols[n][GdFieldPos('DUD_UFDES' )] := aRetGFE[4]
					aCols[n][GdFieldPos('DUD_CDMUND')] := aRetGFE[5]
					aCols[n][GdFieldPos('DUD_MUNDES')] := aRetGFE[6]
					aCols[n][GdFieldPos('DUD_CDTPOP')] := aRetGFE[7]
					aCols[n][GdFieldPos('DUD_DSTPOP')] := aRetGFE[8]   
					aCols[n][GdFieldPos('DUD_CDCLFR')] := aRetGFE[9]
					aCols[n][GdFieldPos('DUD_DSCLFR')] := aRetGFE[10]
					If Len(aRetGFE)>=11  //Incluido depois
						aCols[n][GdFieldPos('DUD_TIPVEI')] := aRetGFE[11]
						aCols[n][GdFieldPos('DUD_DESTPV')] := aRetGFE[12]
					EndIf	
				EndIf
			EndIf
			
		ElseIf cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //--Transferencia
			DbSelectArea("DT6")
			DbSetOrder(1)
			If DbSeek(xFilial("DT6")+aAllDocto[nCnt,2]+aAllDocto[nCnt,3]+aAllDocto[nCnt,4])
				aCols[n][GdFieldPos('DTA_QTDVOL')] := DT6->DT6_QTDVOL
				aCols[n][GdFieldPos('DT6_VOLORI')] := DT6->DT6_VOLORI
				aCols[n][GdFieldPos('DT6_PESO'  )] := DT6->DT6_PESO
				aCols[n][GdFieldPos('DT6_PESOM3')] := DT6->DT6_PESOM3
				aCols[n][GdFieldPos('DT6_VALMER')] := DT6->DT6_VALMER
			EndIf
			DbSelectArea("DUD")
			DbSetOrder(1)
			If DbSeek(xFilial("DUD")+aAllDocto[nCnt,2]+aAllDocto[nCnt,3]+aAllDocto[nCnt,4]+M->DTQ_FILORI+M->DTQ_VIAGEM)
				aCols[n][GdFieldPos('DUD_STATUS')] := DUD->DUD_STATUS
			EndIf
		EndIf
		cSequen := Soma1(cSequen)
	EndIf
	If lHelpUnq .And. lMsErroAuto
		cFileLog := NomeAutoLog()                                  
		aErro    := GetAutoGRLog()   // Le os dados do erro e guarda no vetor

		If Len(aErro) > 0 
			aErro[1] := StrTran(aErro[1], Chr(13) + Chr(10), '')
		EndIf

		aEval(aErro, { |x| Aadd(aVisErr,{  	AllTrim(RetTitle("DUD_DOC")) + " "+;
											aAllDocto[nCnt,2] + "-"  + ;
											aAllDocto[nCnt,3] + "-"  + ;
											aAllDocto[nCnt,4] + ": " + AllTrim(x) }) } )
		lMsErroAuto := .F.
	EndIf
Next nCnt

If lHelpUnq 
	If !Empty(aVisErr)
		TmsMsgErr(aVisErr)
	EndIf
	lMsErroAuto    := aBkp[1]
	lMsHelpAuto    := aBkp[2]
	lAutoErrNoFile := aBkp[3]

	aEval(aBkp[5],{|x| AutoGrLog( x )})
EndIf

RestArea( aArea )

//-- Posiciona no item posicionado para validacao
If lAddNew
	n := oGetD:oBrowse:nAt
	oGetD:Refresh(.T.)
EndIf

DUD->(DbSetOrder(1))
DUD->(MsSeek(xFilial("DUD")+aCols[n,GDFieldPos("DTA_FILDOC")]+aCols[n,GDFieldPos("DTA_DOC")]+aCols[n,GDFieldPos("DTA_SERIE")]+cFilAnt))
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA144DTp³ Autor ³ Eduardo de Souza      ³ Data ³ 06/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta documentos de transporte                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144DTp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144DTp(cRota,nOpcx,cAliasNew,lQuery)

Local cQuery      := ''
Local aItem       := {}
Local nCnt        := 0

Default lQuery    := .T.
Default cAliasNew := GetNextAlias()

Private cAliasDoc := cAliasNew //-- Utilizado no PE (TM144CDC).

If Type("aUsHDocto") != "A"
	aUsHDocto := {}
EndIf

If lQuery
	cQuery := TM141Query(nOpcx,cRota)
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
EndIf

While (cAliasNew)->(!Eof())
	aItem := {}
	AAdd( aItem, .F. )
	AAdd( aItem, (cAliasNew)->DUD_FILDOC )
	AAdd( aItem, (cAliasNew)->DUD_DOC    )
	AAdd( aItem, (cAliasNew)->DUD_SERIE  )
	//-- Inclui colunas do usuario
	If !Empty(aUsHDocto)
		For nCnt := 1 To Len(aUsHDocto)
			AAdd(aItem, &( aUsHDocto[nCnt,2] ) )
		Next nCnt
	EndIf
	AAdd( aAllDocto, aClone(aItem) )
	(cAliasNew)->(DbSkip())
EndDo
If lQuery
	(cAliasNew)->(DbCloseArea())
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA144DPC ³ Autor ³Eduardo de Souza      ³ Data ³ 30/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o documento sera entrege por despachante       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144DPC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Documento                                   ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144DPC(cFilDoc,cDoc,cSerie)

Local cAliasNew := GetNextAlias()
Local cQuery    := ''
Local lRet      := .F.

cQuery := " SELECT COUNT(DT6_FILIAL) CNT "
cQuery += "   FROM " + RetSQLName("DT6")
cQuery += "   WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "     AND DT6_FILDOC = '" + cFilDoc + "' "
cQuery += "     AND DT6_DOC    = '" + cDoc    + "' "
cQuery += "     AND DT6_SERIE  = '" + cSerie  + "' "
cQuery += "     AND DT6_SERIE  <> 'COL' "
cQuery += "     AND (( DT6_CLIDPC <> ' ' AND DT6_LOJDPC <> ' ' ) "
cQuery += "       OR  DT6_CDRCAL <> DT6_CDRDES ) "
cQuery += "     AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

If (cAliasNew)->CNT > 0
	lRet := .T.
EndIf

(cAliasNew)->(DbCloseArea())

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA144Line³ Autor ³ Eduardo de Souza     ³ Data ³ 24/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine do documento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Line(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144Line(nAt)

Local abLine  := {}
Local nPosIni := 0
Local nCnt    := 0

If	oMarked == Nil
	oMarked := LoadBitmap( GetResources(),'LBOK')
EndIf
If	oNoMarked == Nil
	oNoMarked := LoadBitmap( GetResources(),'LBNO' )
EndIf

AAdd( abLine, Iif(aAllDocto[ nAT, 1 ] , oMarked, oNoMarked ) )
AAdd( abLine, aAllDocto[ nAT, 2 ] )
AAdd( abLine, aAllDocto[ nAT, 3 ] )
AAdd( abLine, aAllDocto[ nAT, 4 ] )

//-- Inclui colunas do usuario
//-- Ultima posicao do aDocto padrao para inicializar o bline do usuario.
If lTM144CDC
	nPosIni  := (Len(aAllDocto[nAt]) - Len(aUsHDocto)) + 1
	For nCnt := nPosIni To Len(aAllDocto[nAt])
		AAdd( abLine, aAllDocto[nAt,nCnt] )
	Next nCnt
EndIf

Return( abLine )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA144Nfc ³ Autor ³ Gilson da Silva      ³ Data ³ 20/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a chamada da Rotina P/Entrada da NFiscal do Cliente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Nfc ()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do aRotina.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA144Nfc(nOpcx,nPosDTQ)

Local lRet       := .T.
Local nCont      := 0
Local cCadAux    := cCadastro
Local cFil       := cFiltro
Local lOldInclui := Inclui
Local nOpcEx     := 3
Local aAreaDTP   := {}
Local cSeekDTP   := ""
Local lConfirma  := .T.
Local cSerAnt    := ""
Local lTpOpVg    := DTQ->(ColumnPos('DTQ_TPOPVG')) > 0
Local aAreaAnt   := {}

Private cNumLotUso  := CriaVar('DTC_LOTNFC',.F.)//Variavel utilizada na Rotina de Digitacao de Notas Fiscais
Private cNumSolic   := CriaVar('DTC_NUMSOL',.F.)//Variavel utilizada na Rotina de Digitacao de Notas Fiscais
Private cCliRemUso  := CriaVar('DTC_CLIREM',.F.)//Variavel utilizada na Rotina de Digitacao de Notas Fiscais
Private cLojRemUso  := CriaVar('DTC_LOJREM',.F.)//Variavel utilizada na Rotina de Digitacao de Notas Fiscais
Private aPedBlq     := {} //Vetor usado na rotina de Calculo de frete Tmsa200Prc()

Default nPosDTQ := 0

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
If !Obrigatorio( aGets, aTela )
	lRet := .F.
	Return( lRet )
EndIf

//-- Se o Parametro mv_par03 = Tipo de Viagem Vazia / Socorro nao pode digitar notas Fiscais
If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) // Se Viagem de Transporte e Vazia nao pode digitar notas
	If nTipVia == 2
		Help(' ', 1, 'TMSA14420')	//-- Viagem do tipo vazia, nao pode digitar notas fiscais.
		lRet := .F.
		Return( lRet )
	EndIf
ElseIf cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))
	If nTipVia == 2 .Or. nTipVia == 3 .Or. nTipVia == 4  // Se Viagem de Entrega e Vazia / Socorro nao pode digitar notas
		Help(' ', 1, 'TMSA14420')	//-- Viagem do tipo vazia, nao pode digitar notas fiscais.
		lRet := .F.
		Return( lRet )
	EndIf
EndIf

If Empty(M->DTQ_ROTA) .And. (nOpcx == 3 .Or. nOpcx == 4)
	Help(' ', 1, 'TMSA14016')	//-- Nenhuma rota selecionada !
	lRet := .F.
	Return( lRet )
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

//-- Salva o aCols e aHeader
SaveInter()

//-- Validações
lRet := NfCliBut( M->DTQ_FILORI , M->DTQ_VIAGEM , nOpcx , M->DTQ_STATUS )	

If !lRet
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	//-- Restaura aCols e aHeader.
	RestInter()
	Return( lRet )
EndIf

If Empty(M->DTQ_ROTA) .And. (nOpcx == 3 .Or. nOpcx == 4)
	Help(' ', 1, 'TMSA14016')	//-- Nenhuma rota selecionada !
	lRet := .F.
	Return( lRet )
EndIf

//Existindo o Ponto de Apoio a inclusão de documentos na viagem, somente será permitida qdo a operação da chegada no ponto estiver apontada
If nOpcx == 4 .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //Em Transito
	If ExistFunc('TM350Apoio')  
		aAreaAnt:= GetArea()
		lRet:= Tm350Apoio(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
		RestArea(aAreaAnt)
		If !lRet
			Return( lRet )
		EndIf		
	EndIf
EndIf

If !lRet
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	//-- Restaura aCols e aHeader.
	RestInter()
	Return( lRet )
EndIf

//-- Valida o complemento da Viagem, Veiculo
lRet := Iif(Len(aCompViag) > 0 , Iif(!Empty(aCompViag[1]) .Or. !Empty(aCompViag[2]), .T., .F.), .F.)
If !lRet
	Help( ' ', 1, 'TMSA24002', , STR0022 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao informado (DTR)###" Viagem : "
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	//-- Restaura aCols e aHeader.
	RestInter()
	Return( lRet )
EndIf

//-- Valida o complemento da Viagem, Motorista
lRet := Iif(Len(aCompViag[4]) > 0, Iif(!Empty(aCompViag[4][1][2][1][1]), .T., .F.), .F.)

If !lRet
	Help('',1,'TMSA24041') //"Informe um Motorista para esta viagem ..."
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	//-- Restaura aCols e aHeader.
	RestInter()
	Return( lRet )
EndIf

//-- Cria os vetores aRota e aDocto
TmsA144Doc( nOpcx,, .T. )

//-- Grava Viagem(DTQ) e Complemento da Viagem(DTR), Não faz o carregamento pq ainda nao existem os Ctrc's.
If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))
	TmsA140Grv(nOpcx, .T., .T.,,,@nPosDTQ)   //Controle para não gravar os dados do SDG, pois o mesmo será gravado abaixo no 144Grv    
Else
	TmsA141Grv(nOpcx, .T., .T.,,,@nPosDTQ)   //Controle para não gravar os dados do SDG, pois o mesmo será gravado abaixo no 144Grv
EndIf

cSerAnt  := cSerTms
lVgeExpr := .T.

//-- Valida e executa a  rotina de Inclusao de  nota fiscal
cCadastro := STR0039 //"Notas Fiscais do Cliente" - Variavel utilizada na Rotina de Digitacao de Notas Fiscais
aAreaDTP:= DTP->(GetArea())

While .T.
	Inclui := .T.
	nOpcEx := 3
	//-- Verifica se a Viagem foi estornada Parcial via Estorno Express - Recuperando o lote como Vizualizacao
	If nOpcx == 4
		DTP->(DbSetOrder(3)) //DTP_FILIAL+DTP_FILORI+DTP_VIAGEM
		If DTP->(DbSeek(cSeekDTP := xFilial("DTP")+M->DTQ_FILORI+M->DTQ_VIAGEM))
			Do While DTP->(!Eof() .And. DTP_FILIAL+DTP_FILORI+DTP_VIAGEM == cSeekDTP)
				If DTP->DTP_STATUS == "2" //-- Digitado
					DTC->(DbSetOrder(1))
					If DTC->(DbSeek(xFilial("DTC")+M->DTQ_FILORI+DTP->DTP_LOTNFC))
						Inclui := .F.
						nOpcEx := 2
					EndIf
				ElseIf DTP->DTP_STATUS == "4" //-- Bloqueado
					Help( ' ', 1, 'TMSA14431') //-- "Existe lote bloqueado para esta viagem. Verifique."
					//-- Inicializa Teclas de Atalhos
					TmsKeyOn(aSetKey)
					//-- Restaura aCols e aHeader.
					RestInter()
					RestArea(aAreaDTP)
					Return( .F. )
				EndIf
				DTP->(dbSkip())
			EndDo
		EndIf
	EndIf

	//-- Inclusao documentos clientes p/ transporte
	dbSelectArea("DTC")
	lRet   := TMSA050Mnt('DTC',0,nOpcEx,.T.)
	Inclui := lOldInclui

	If !lRet .AND. Empty(DTP->DTP_LOTNFC)
		Help( ' ', 1, 'TMSA14412') //-- Processo Interrompido pelo usuário! 
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)
		//-- Restaura aCols e aHeader.
		RestInter()
		RestArea(aAreaDTP)
		Return( lRet )
	EndIf

	DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If DTP->(MsSeek(xFilial("DTP")+M->DTQ_FILORI+DTP_LOTNFC))
		If !lRet .AND. DTP->DTP_QTDDIG == 0
			Help( ' ', 1, 'TMSA14412') //-- Processo Interrompido pelo usuário! 
			//-- Inicializa Teclas de Atalhos
			TmsKeyOn(aSetKey)
			//-- Restaura aCols e aHeader.
			RestInter()
			RestArea(aAreaDTP)
			Return( lRet )
		
		ElseIf !lRet .AND. DTP->DTP_QTDDIG < DTP->DTP_QTDLOT
			If MsgNoYes(STR0162) //Deseja fechar o lote e realizar o cálculo?
				RecLock("DTP",.F.)
				DTP->DTP_STATUS := "2"
				DTP->(MsUnLock())
		    EndIf
			Exit

		ElseIf DTP->DTP_STATUS $ "2,4"	//-- Digitado ou Bloqueado
			Exit
		EndIf
	EndIf
EndDo
RestArea(aAreaDTP)

lVgeExpr := .T.
If !Empty(cSerAnt) .And. cSerTms <> cSerAnt
	cSerTms:= cSerAnt
EndIf

//-- Valida e executa a rotina que calcula o frete referente as NFiscais digitadas e gera os Documentos. 
Pergunte("TMB144",.F.)

If lConfirma	
	lConfirma := (mv_par01 == 1)
	RestInter()
	SaveInter()
EndIf

DTP->(DbSetOrder(3)) //DTP_FILIAL+DTP_FILORI+DTP_VIAGEM
If DTP->(dBSeek(cSeekDTP := xFilial("DTP")+M->DTQ_FILORI+M->DTQ_VIAGEM))
	Do While DTP->(!Eof() .And. DTP_FILIAL+DTP_FILORI+DTP_VIAGEM == cSeekDTP)
		If DTP->DTP_STATUS == "2" //-- Digitado
			aAreaDTP := DTP->(GetArea())
			lRet := TMSA200Mnt("DTP",DTP->(Recno()),2,,lConfirma)
			RestArea( aAreaDTP )
		EndIf
		DTP->(dbSkip())
	EndDo
EndIf

If lRet
	//-- Chama novamente a tela de complemento da Viagem  se a opcao de carregamento for sem  manifseto
	If nCarreg == 2 .Or. nCarreg == 5 // Carregamento Sem Manifesto 
		TmsA144Viag(4,lVgeExpr,Iif(lTpOpVg .And. cTipOpVgAnt <> M->DTQ_TPOPVG,.T.,.F.))  //Controle para não mostrar tela quando altera o Tipo de Operação
		If lTpOpVg
			cTipOpVgAnt:= M->DTQ_TPOPVG
		EndIf
	EndIf

	//-- Faz o carregamento, verifica todas as rotas conforme os CTRC'S da viagem , Gera o Manifesto e o Contrato de Carreteiro.
	lRet := TmsA144Grv( nOpcx, .T., .T.)

	If lRet
		//Faz o Pagamento do Saldo
		If lPagSald .And. ( nCarreg == 4 .Or. nCarreg == 5 )
			DTY->(DbSetOrder(2)) //DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
			If DTY->(MsSeek(xFilial("DTY")+M->DTQ_FILORI+M->DTQ_VIAGEM))
				lRet := TMSA250Sld('DTY',DTY->(Recno()),4)
			EndIf
		EndIf
	Else
		Help( ' ', 1, 'TMSA14414') //-- Viagem não Realizada, Verifique!
	EndIf
EndIf
cCadastro := cCadAux
cFiltro   := cFil
If Type('bFiltraBrw') <> 'U'
	Eval(bFiltraBrw)
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Restaura aCols e aHeader.
RestInter()

//-- Atualiza Acols do documento.
TMSCtrc()

//-- Atualiza os dados do rodape.
TmsA210Rdp()

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA144Vge ³ Autor ³ Gilson da Silva      ³ Data ³ 20/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atribui o numero da Viagem para o campo DTP_VIAGEM         ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Vge ()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144Vge()
Local cRet     := ""
Local cFunName := Substr(FunName(),1,7)

If cFunName == "TMSA144" .Or. cFunName == "TMSA145"
	If TmsExp() .And. cSerTms $ "23"
		cRet := M->DTQ_VIAGEM
	EndIf
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144ICh ³ Autor ³ Gilson da Silva     ³ Data ³ 29/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime cheques vinculados ao Contrato                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144ICh()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias da Tabela selecionada                        ³±±
±±³          ³ ExpN2 = Registro posicionado                               ³±±
±±³          ³ ExpN3 = Opcao do aRotina.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144ICh(cAlias, nReg, nOpcx)

Local aArea      := GetArea()
Private lRTMSR13 := ExistBlock("RTMSR13")

If lRTMSR13
	ExecBlock( 'RTMSR13', .F., .F.)
Endif

RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144IMn ³ Autor ³ Gilson da Silva     ³ Data ³ 10/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Manifesto                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144IMn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias da Tabela selecionada                        ³±±
±±³          ³ ExpN2 = Registro posicionado                               ³±±
±±³          ³ ExpN3 = Opcao do aRotina.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144IMn(cAlias, nReg, nOpcx, cTipManif)

Local aArea      := GetArea()
Local aAreaDTX   := DTX->(GetArea())
Local cFil       := cFiltro
Default			 := ''

EndFilBrw("DTQ",aIndex)
DTX->(DbSetOrder(3))
If DTX->(MsSeek(xFilial("DTX")+DTQ->(DTQ_FILORI+DTQ_VIAGEM)))
	TmsA190Imp("DTX",DTX->(Recno()),nOpcx, cTipManif)
Else
	Help(' ', 1, 'TMSXFUNA05')	//-- Manifesto nao Encontrado para a Viagem
EndIf
cFiltro := cFil
If Type('bFiltraBrw') <> 'U'
	Eval(bFiltraBrw)
EndIf

RestArea( aArea )
RestArea( aAreaDTX )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144ICt ³ Autor ³ Gilson da Silva     ³ Data ³ 10/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Contrato de Carreteiro                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144ICt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias da Tabela selecionada                        ³±±
±±³          ³ ExpN2 = Registro posicionado                               ³±±
±±³          ³ ExpN3 = Opcao do aRotina.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144ICt(cAlias, nReg, nOpcx)

Local aArea    := GetArea()
Local cFil     := cFiltro
Local lRTMSR06 := ExistBlock("RTMSR06")

DTY->(DbSetOrder(2))
If	DTY->(!MsSeek(xFilial('DTY')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
	Help(" ",1,"TMSXFUNA08")   // Contrato nao foi encontrado ...
	Return( Nil )
EndIf

If lRTMSR06
	While .T.
		If LockByName("IMPCTC",.T.,.F.)// -- Se a rotina de Impressao do contrato do Carreteiro estiver sendo executada por outro
			                           // -- usuario o sistema nao imprime o manifesto.
            SetMVValue("RTMR06","MV_PAR01",DTQ->DTQ_FILORI) //FILIAL ORIGEM DE
            SetMVValue("RTMR06","MV_PAR02",DTQ->DTQ_FILORI) //FILIAL ORIGEM ATE
            SetMVValue("RTMR06","MV_PAR03",DTQ->DTQ_VIAGEM) //VIAGEM DE
            SetMVValue("RTMR06","MV_PAR04",DTQ->DTQ_VIAGEM) //VIAGEM ATE
		EndIf
		Exit
	EndDo
	UnLockByName("IMPCTC",.T.,.F.) // Libera Lock

	EndFilBrw("DTQ",aIndex)

	Pergunte("RTMSR06",.F.)
	mv_par01 := DTQ->DTQ_FILORI
	mv_par02 := DTQ->DTQ_FILORI
	mv_par03 := DTQ->DTQ_VIAGEM
	mv_par04 := DTQ->DTQ_VIAGEM
	ExecBlock( 'RTMSR06', .F., .F.)
EndIf
cFiltro := cFil
If Type('bFiltraBrw') <> 'U'
	Eval(bFiltraBrw)
EndIf
RestArea( aArea )

Return
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144GMC ³ Autor ³ Gilson da Silva     ³ Data ³ 08/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Manifesto da Viagem e Contrato do Carreteiro          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144GMC(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Viagem Express                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa144GMC(lVgeExpr,nOpcCarreg,lTela,cFilGer)

Local cAliasNew   := GetNextAlias()
Local cQuery      := ''
Local lRet        := .T.
Local aArea       := GetArea()
Local nCnt        := 0
Local lConfirma   := .T.
Local nOpcVge     := 4
Local cObs        := '' //-- Observacao da Viagem
Local cFilBack	 := cFilAnt
Local nCarregOld
Local lMDFEAut    := GetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")
Local aAreaSM0 	:= SM0->(GetArea())
Local aMDFe
Local lUFAtiv     := DTX->(ColumnPos("DTX_UFATIV")) > 0

Default lVgeExpr  := .F.
Default lTela     := .T.
Default cFilGer   := ""

//-- Trata por argumento a opção desejada, mantendo o legado com a Variável private nCarreg
If nOpcCarreg != Nil
	nCarregOld := Iif( Type("nCarreg") != "U", nCarreg, 0)
	nCarreg    := nOpcCarreg

	lConfirma  := lTela 
EndIf

If lVgeExpr
	Pergunte("TMB144",.F.)
	lConfirma := ( mv_par01 == 1 )
EndIf

//-- Gera Manifesto
If nCarreg == 3 .Or. nCarreg == 4   //Modo de Carregamento Com Manifesto
	If lMdfeAut
		//-- Verifica se há manifestos para encerrar
		cQuery := " SELECT DTX_FILMAN, DUD_MANIFE, DTX_SERMAN, DTX_VIAGEM, DTX_TIPMAN, DTX_STFMDF"
		If lUfAtiv 							
			cQuery += ", DTX_UFATIV"	
		EndIf
		cQuery += " FROM " + RetSQLName("DUD") + " DUD "
		cQuery += " JOIN " + RetSQLName("DTX") + " DTX "
		cQuery += " 	 ON DTX_FILIAL = '" + xFilial("DTX") +"'"
		cQuery += "     AND DTX_FILORI = DUD.DUD_FILORI " 
		cQuery += "     AND DTX_VIAGEM = DUD.DUD_VIAGEM "	
		cQuery += "     AND DTX_TIPMAN =  '2'  "
		cQuery += "     AND DTX_IDFMDF <> '132'"	
		If !Empty(cFilger)
			cQuery += "     AND DTX_FILDCA = '" + cFilger +"'"
		EndIf
		cQuery += "     AND DTX.D_E_L_E_T_ =  ' ' "
		cQuery += "	WHERE   DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"	
		cQuery += "     AND DUD.DUD_VIAGEM = '" + M->DTQ_VIAGEM  + "' "
		cQuery += "     AND DUD.DUD_FILORI = '" + M->DTQ_FILORI  + "' "
		cQuery += "     AND DUD.DUD_MANIFE <> ' ' "	
		cQuery += "     AND DUD.DUD_STATUS <> '4' "
		cQuery += "     AND DUD.D_E_L_E_T_ =  ' ' "
		cQuery += "     AND EXISTS "
		cQuery += " (SELECT 1   "
		cQuery += "    FROM " + RetSQLName("DUD") + " AUX " 
		cQuery += "	  WHERE AUX.DUD_FILIAL = '" + xFilial("DUD") +"'"	
		cQuery += "     AND AUX.DUD_VIAGEM = '" + M->DTQ_VIAGEM  + "' "
		cQuery += "     AND AUX.DUD_FILORI = '" + M->DTQ_FILORI  + "' "
		cQuery += "     AND AUX.DUD_STATUS <> '4' "
		cQuery += "     AND AUX.DUD_MANIFE = ' '  "	
		//-- MDF-e Automático: apenas documentos autorizados serão manifestados
		cQuery += "     AND EXISTS (SELECT 1 FROM "+ RetSqlName("DT6") + " DT6AUX "
		cQuery += "	                    WHERE DT6AUX.DT6_FILIAL = '" + xFilial("DT6") +"'"	
		cQuery += "                       AND DT6AUX.DT6_FILDOC =  AUX.DUD_FILDOC "
		cQuery += "                       AND DT6AUX.DT6_DOC    =  AUX.DUD_DOC "
		cQuery += "                       AND DT6AUX.DT6_SERIE  =  AUX.DUD_SERIE "
		cQuery += "                       AND DT6AUX.DT6_IDRCTE =  '100' " 
		cQuery += "                       AND DT6AUX.D_E_L_E_T_ =  ' ' )"
		//-- DOCUMENTOS NÃO-MANIFESTADOS DA VIAGEM, COM ESTADO DE DESTINO OU DESCARGA IGUAIS À DOCTOS JÁ MANIFESTADOS (E NÃO ENCERRADOS) NA VIAGEM
		cQuery += "     AND ( (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DES_SMAN " // estado de Destino - docto SEM manifesto da viagem
		cQuery += "            WHERE DES_SMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
		cQuery += "              AND DES_SMAN.DUY_GRPVEN = AUX.DUD_CDRDES "
		cQuery += "              AND DES_SMAN.D_E_L_E_T_ = ' ')" 
		cQuery += "           = " 
		cQuery += "           (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DES_CMAN " // estado de Destino - docto COM manifesto da viagem
		cQuery += "            WHERE DES_CMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
		cQuery += "              AND DES_CMAN.DUY_GRPVEN = DUD.DUD_CDRDES "
		cQuery += "              AND DES_CMAN.D_E_L_E_T_ = ' ')" 
		cQuery += "           OR " 
		cQuery += "           (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DCA_SMAN " // Estado de descarga - docto SEM manifesto da viagem
		cQuery += "            WHERE DCA_SMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
		cQuery += "              AND DCA_SMAN.DUY_FILDES = AUX.DUD_FILDCA "
		cQuery += "              AND DCA_SMAN.DUY_CATGRP = '" + StrZero(2,Len(DUY->DUY_CATGRP)) + "'"
		cQuery += "              AND DCA_SMAN.D_E_L_E_T_ = ' ')" 
		cQuery += "           = " 
		cQuery += "           (SELECT DUY_EST FROM "+ RetSqlName("DUY") + " DCA_CMAN " // Estado de descarga - docto COM manifesto da viagem
		cQuery += "            WHERE DCA_CMAN.DUY_FILIAL = '" + xFilial("DUY") + "'" 
		cQuery += "              AND DCA_CMAN.DUY_FILDES = DUD.DUD_FILDCA "
		cQuery += "              AND DCA_CMAN.DUY_CATGRP = '" + StrZero(2,Len(DUY->DUY_CATGRP)) + "'"
		cQuery += "              AND DCA_CMAN.D_E_L_E_T_ = ' ')" 
		cQuery += "         )" 
		cQuery += "     AND AUX.D_E_L_E_T_ =  ' '  "				
		cQuery += "  )" 
		cQuery += " GROUP BY DTX_FILMAN, DUD_MANIFE, DTX_SERMAN, DTX_VIAGEM, DTX_TIPMAN, DTX_STFMDF "
		If lUfAtiv 							
			cQuery += ", DTX_UFATIV"	
		EndIf		
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )		
			
		aMDFe := {} //-- só inicializa aqui para não  alocar memória caso não utilize MDFe Automático

		//-- Verifica DUD DIPONIVEL PARA MANIFESTAR		
		Do While (cAliasNew)->(!Eof())
		
		If (cAliasNew)->DTX_TIPMAN  == '2' .And.  (cAliasNew)->DTX_STFMDF <> '2'
			Aadd(aMDFe,{(cAliasNew)->DTX_FILMAN,;
						(cAliasNew)->DUD_MANIFE,;
						(cAliasNew)->DUD_MANIFE,;
						(cAliasNew)->DTX_SERMAN,;
						(cAliasNew)->DTX_VIAGEM,;
						Iif(lUFAtiv, (cAliasNew)->DTX_UFATIV, '')})
		EndIf
			(cAliasNew)->(DbSkip())	
		EndDo
		(cAliasNew)->(DbCloseArea())	

		If !Empty(aMDFe) .And. !Empty(aMDFe[Len(aMDFe),2])
			//-- Alterar o conteudo da variavel cFilAnt													
			cFilAnt := Posicione('SM0',1,cEmpAnt+aMDFe[Len(aMDFe),1],'FWCODFIL()')														
			lContinua := TmsMDFeAut(aMDFe, 2) //--Encerra o Manifesto   
			If lContinua
				TmsLimpDUD(M->DTQ_FILORI,M->DTQ_VIAGEM,aMdfe)	//--Limpar a DUD				
			EndIf 								         
			cFilAnt := Posicione('SM0',1,cEmpAnt+cFilBack,'FWCODFIL()') 
			RestArea(aAreaSM0)
		EndIf
			
	EndIf
	//Query para verificar se Existem Doctos Vinculados a viagem que nao estejam manifestados ou deletados
	//Esta query pega os documentos que foram carregados.  
	cQuery := " SELECT COUNT(DUD.DUD_FILIAL) CNT "
	cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "   WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "     AND DUD.DUD_FILORI = '" + M->DTQ_FILORI  + "' "
	cQuery += "     AND DUD.DUD_VIAGEM = '" + M->DTQ_VIAGEM  + "' "
	cQuery += "     AND DUD.DUD_SERTMS <> '" + StrZero(1,Len(DUD->DUD_SERTMS)) + "' " //--não considera a documentos de Solicitações de Coletas.
	If M->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transferência
		cQuery += "     AND DUD.DUD_FILDCA <> '" + cFilBack +"'"
	EndIf
	cQuery += "     AND DUD.DUD_MANIFE = ' ' "
	cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "

	//-- MDF-e Automático: apenas documentos autorizados serão manifestados
	If lMdfeAut
		cQuery += " AND EXISTS( SELECT 1 FROM " + RetSqlName("DT6") + " DT6 "
		cQuery += "             WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
		cQuery += "               AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
		cQuery += "               AND DT6.DT6_DOC    = DUD.DUD_DOC"
		cQuery += "               AND DT6.DT6_SERIE  = DUD.DUD_SERIE"
		cQuery += "               AND DT6.DT6_IDRCTE = '100' "
		cQuery += "               AND DT6.D_E_L_E_T_ = ' ') "	
	EndIf

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
	(cAliasNew)->(DbGoTop())
	nCnt := (cAliasNew)->CNT
	(cAliasNew)->(DbCloseArea())
	RestArea( aArea )

	If nCnt > 0  //--  Informa se existem doctos para manifestar
        SetMVValue("TMA190","MV_PAR01",M->DTQ_FILORI)	
        SetMVValue("TMA190","MV_PAR02",M->DTQ_VIAGEM)
        Pergunte("TMSA190",.F.)
		mv_par01  := M->DTQ_FILORI
		mv_par02  := M->DTQ_VIAGEM
        
		cCadastro := STR0042 //-- Manifesto de Carga
		lRet      := TmsA190Mnt('DTX',0,3,M->DTQ_FILORI,M->DTQ_VIAGEM,lVgeExpr,lConfirma,.F.,lMdfeAut,cFilGer)//--Geração do manifesto.
		DTX->(DbSetOrder(3))
		DTX->(dbSeek(FwxFilial('DTX') + M->DTQ_FILORI + M->DTQ_VIAGEM))
		If !lRet .And. DTX->DTX_TIPMAN == '2'
			Help(' ', 1, 'TMSA14416')   //-- Nao foi possivel gerar o Manifesto", "processamento interrompido!!!
		EndIf
	Else
		If lTela // Quando é forçado não ter tela, não mostra ERRO por não ter documento para manifestar.
			Help(' ', 1, 'TMSA19005')   //-- "Nenhum Documento foi encontrado para esta Viagem!"
			lRet := .F.
		EndIf
	EndIf
EndIf

//--Gera o Contrato do carreteiro
If lRet .And. (nCarreg == 4 .Or. nCarreg == 5)
	Pergunte("TMA250",.F.)

	If LockByName("GERCTC",.T.,.F.)// -- Se a rotina que Gera o contrato do Carreteiro estiver sendo
									// --  executada por outro usuario o sistema nao gera o contrato.
		//pergunte padrao para gerar Contrato por Viagem
		SetMVValue("TMA250","MV_PAR01",M->DTQ_VIAGEM) //VIAGEM DE
		SetMVValue("TMA250","MV_PAR02",M->DTQ_VIAGEM) //VIAGEM ATE
		SetMVValue("TMA250","MV_PAR03",2) //Mostra lanctos contabeis
		SetMVValue("TMA250","MV_PAR04",2) //Aglutina lanctos
		SetMVValue("TMA250","MV_PAR05",1) //Tipo de Frota
	Else
		lRet := .F.
	EndIf
	UnLockByName("GERCTC",.T.,.F.) // Libera Lock

	cCadastro := STR0043 // Contrato de Carreteiro
	
	DTR->( DbSetOrder( 1 ) )
	DTR->(  MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
	If lRet .And. nCarreg == 5 .And. lVgeExpr .And. !Empty(DTR->DTR_CODOPE)
		cObs := MsMM(Posicione('DTQ',2,xFilial('DTQ')+M->DTQ_FILORI+M->DTQ_VIAGEM,'DTQ_CODOBS'),80) 
		lRet := (TMSA240Mnt( 'DTR', DTR->( Recno() ), nOpcVge, M->DTQ_FILORI, M->DTQ_VIAGEM,,,,,cObs,,,lConfirma,,!lVgeExpr) == 1)	
	EndIf
	If lRet
		lRet := TMSA250Mnt('DTY',0,3,,lConfirma,lVgeExpr,,'1')
	EndIf
	If !lRet
		Help(' ', 1, 'TMSA14417')   //-- "Nao foi possivel gerar o Contrato ", "processamento interrompido!!!"
	EndIf
ElseIf nCarreg == 1 .Or. nCarreg == 2
	DTR->( DbSetOrder( 1 ) )
	DTR->(  MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
	If lVgeExpr .And. !Empty(DTR->DTR_CODOPE)
		cObs := MsMM(Posicione('DTQ',2,xFilial('DTQ')+M->DTQ_FILORI+M->DTQ_VIAGEM,'DTQ_CODOBS'),80) 
		lRet := (TMSA240Mnt( 'DTR', DTR->( Recno() ), nOpcVge, M->DTQ_FILORI, M->DTQ_VIAGEM,,,,,cObs,,,lConfirma,,!lVgeExpr) == 1)	
	EndIf
EndIf

If nOpcCarreg != Nil
	nCarreg := nCarregOld
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144Sub ³ Autor ³ Telso Carneiro      ³ Data ³ 12/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada para o SubRotinas de Manutencao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Sub(cPrgMnt)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144Sub(cMnuSub,nOpcx)

Local aArea 	 := GetArea()
Local cOldFName  := FunName() //-- Utilizado para restaurar o FunName original, pois na chamada das rotinas atraves do submenu sera alterado.
Local cFiltraSub := ""
Local aCampos	 := {}
Local aCores
Local bkpcFiltro := cFiltro
Local lRet		 := .F.
Local cRetPE     := ""
Local oModel215  := Nil
Local oModel151  := Nil //-- Tratamento Rentabilidade/Ocorrencia
Local nOpcView   := 0
Local cVeiCar    := ''
Local cCodVei    := ''
Local aCodVei    := {}
Local lColig     := .F.
Local cAtvChgCli := SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente

Private aIndexSub  := {}
Private bFiltraSub := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas do MBrowse Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

RegToMemory("DTQ",.F.)
EndFilBrw("DTQ",aIndex)

Do Case
	Case cMnuSub == 1		//-- Confirmacao de Viagens de Transporte / Rodoviario
		If cSerTms == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Coleta

			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				lRet := TmsAcesso(,"TMSA142A",,3)
			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				lRet := TmsAcesso(,"TMSA142B",,3)
			EndIf

		ElseIf cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte

			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				lRet := TmsAcesso(,"TMSA142E",,3)
			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				lRet := TmsAcesso(,"TMSA142F",,3)
			EndIf
		
		ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
		
			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				lRet := TmsAcesso(,"TMSA142C",,3)
			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				lRet := TmsAcesso(,"TMSA142D",,3)
			ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
				lRet := TmsAcesso(,"TMSA142G",,3)
			EndIf
			
		EndIf
		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
			//³  aplicados no rpo do                                			|
			//| cliente, assim verificando a necessidade de uma atualizacao     |
			//| nestes fontes. NAO REMOVER !!!							        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(TMSA142_V() >= 20061002)
				Alert(STR0086+"TMSA142.PRW !!!")//"Atualizar "
			Else
				SetFunName("TMSA142")
				TmsA142(cSerTms, cTipTra, .T.)
			EndIf
		EndIf
		
	Case cMnuSub == 2 	//-- Carregamento de transporte.
		
		//-- *** SE UTILIZADO PELA ROTINA TMSAF76 - PAINEL DE AGENDAMENTO ***
		//-- opção Manuteção/Carregamento e a viagem for de coleta, informa
		//-- ao usuário que essa opção não pode ser utilizada para, SOMENTE transporte ou entrega.
		If IsInCallStack("TMSAF76") .And. (cSerTms == StrZero(1,Len(DTQ->DTQ_SERTMS)))
			Help("",1,"TMSAF76CARR",,STR0152,1,2) // So sera permitido Gerar Manifesto para Viagens de Transporte ou Entrega
			lRet := .F.
		EndIf
		
		If cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte

			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210A",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210A",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210A",,4)
				EndIf
				
			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210B",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210B",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210B",,4)
				EndIf

			ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210E",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210E",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210E",,4)
				EndIf

			ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210I",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210I",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210I",,4)
				EndIf

			EndIf
		
		ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
		
			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210C",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210C",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210C",,4)
				EndIf

			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210D",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210D",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210D",,4)
				EndIf

			ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210F",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210F",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210F",,4)
				EndIf
				
			ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional	
				If nOpcX == 2
					lRet := TmsAcesso(,"TMSA210J",,2)
				ElseIf nOpcX == 3
					lRet := TmsAcesso(,"TMSA210J",,3)
				ElseIf nOpcX ==  4
					lRet := TmsAcesso(,"TMSA210J",,4)
				EndIf
			EndIf
			
		EndIf
		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
			//³  aplicados no rpo do                                  			|
			//| cliente, assim verificando a necessidade de uma atualizacao     |
			//| nestes fontes. NAO REMOVER !!!							        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetFunName("TMSA210")
			aRotina := {	{ "","", 0, 1 },;
							{ "","", 0, 2 },;
							{ "","", 0, 3 },;
							{ "","", 0, 4 },;
							{ "","", 0, 5 } }
			If nOpcx == 3
				DTR->( DbSetOrder( 1 ) )
				If  DTR->( ! MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
					Help( ' ', 1, 'TMSA24002', , STR0038 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)###" Viagem : "
					lRet := .F.
				Else
					If !TMSChkViag( M->DTQ_FILORI, M->DTQ_VIAGEM, .T., .F., .F., , .F., .F., , .T., , , , .T. )
						lRet := .F.
					Else
						TmsA210Mnt("DTA", 0, nOpcx, M->DTQ_FILORI, M->DTQ_VIAGEM)
					EndIf
				EndIf
			Else
				DbSelectArea("DTA")
				DbSetOrder(4)

				If DTA->(MsSeek(xFilial("DTA")+cSerTms+cTipTra+M->DTQ_FILORI+M->DTQ_VIAGEM))
					TmsA210Mnt("DTA", DTA->(Recno()), nOpcx, M->DTQ_FILORI, M->DTQ_VIAGEM)
				EndIf
			EndIf
		EndIf
		
	Case cMnuSub == 3		//--  Manifesto de Carga
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
		//³  aplicados no rpo do                                  			|
		//| cliente, assim verificando a necessidade de uma atualizacao     |
		//| nestes fontes. NAO REMOVER !!!							        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DTR->( DbSetOrder( 1 ) )
		DTX->(DbSetOrder(3))
		If DTR->( MsSeek( xFilial("DTR") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) ) .And. !Empty(DTR->DTR_NUMVGE) .And. !Empty(DTR->DTR_FILVGE)
			lColig := .T.
		EndIf
		SetFunName("TMSA190")
		If nOpcx == 3				
				
			If lColig .And. DTX->(MsSeek(xFilial('DTX') + DTR->DTR_FILVGE + DTR->DTR_NUMVGE ))
				Help('',1,'TMSA14435', ,'Manifesto: ' + AllTrim(DTX->DTX_MANIFE) + ' / ' + 'Viagem Principal: ' + AllTrim(DTR->DTR_FILVGE) + '-' + AllTrim(DTR->DTR_NUMVGE) ,03,00)							
				Return( .F. )
			EndIf
				If TmsAcesso(,"TMSA190",,nOpcx)
				aRotina := {	{ "" ,"", 0, 1 },;
								{ "" ,"", 0, 2 },;
								{ "" ,"", 0, 3 },;
								{ "" ,"", 0, 4 },;
								{ "" ,"", 0, 5 } }
					TmsA190Mnt("DTX", 0, nOpcx, M->DTQ_FILORI, M->DTQ_VIAGEM)
			EndIf
		Else
			DbSelectArea("DTX")
			DbSetOrder(1)
			aRotina := {}
			AAdd(aRotina, { STR0078 , "TMSXPesqui",0,1})//"&Pesquisar"
			
			If TmsAcesso(,"TMSA190",,2,.F.)
				AAdd(aRotina, { STR0076 , "TmsA190Mnt",0,2})//"&Visualizar"
				lRet := .T.
			EndIf
			
			If TmsAcesso(,"TMSA190",,5,.F.)
				AAdd(aRotina, { STR0077 , "TmsA190Mnt",0,5})//"&Excluir"
				lRet := .T.
			EndIf
			
			If !lRet
				Help('',1,'SEMPERM',,STR0009+' e/ou '+STR0012,03,00)
			EndIf
			
			AAdd(aRotina, { STR0079 , "TmsA190Leg",0,6})//"&Legenda"
				aIndexSub  := {}
			cFiltraSub := "DTX_FILIAL=='"+xFilial("DTX")+"'.And. DTX_FILORI=='"+M->DTQ_FILORI+"'.And.DTX_VIAGEM=='"+M->DTQ_VIAGEM+"'"
			bFiltraSub := {|| FilBrowse("DTX",@aIndexSub,@cFiltraSub) }
			Eval(bFiltraSub)
			aCores := {}
			AAdd(aCores,{"Empty(DTX->DTX_NUMCTC)",'BR_VERDE'		})	// -- Em Aberto
			AAdd(aCores,{"!Empty(DTX->DTX_NUMCTC)",'BR_VERMELHO'	})	//-- "Contrato Gerado"
			MaWndBrowse(0,0,300,600,STR0058,"DTX",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores) //"Manisfestar"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndFilBrw("DTX",aIndexSub)
		EndIf

	Case cMnuSub == 4		//-- Operacoes de Transporte
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
		//³  aplicados no rpo do                                  			|
		//| cliente, assim verificando a necessidade de uma atualizacao     |
		//| nestes fontes. NAO REMOVER !!!							        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(TMSA350_V() >= 20061002)
			Alert(STR0086+"TMSA350.PRW !!!")//"Atualizar "
		Else
			SetFunName("TMSA350")

			DbSelectArea("DTW")
			DbSetOrder(1)
			
			aRotina	:= {}
			
			AAdd(aRotina, { STR0078 , 'TMSXPesqui',0,1}) //"&Pesquisar"
			
			If cSerTms == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Coleta
		
				If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
					If TmsAcesso(,"TMSA350A",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350A",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350A",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					
				ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
					If TmsAcesso(,"TMSA350E",,2)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350E",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350E",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf

				EndIf

			ElseIf cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte

				If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
					If TmsAcesso(,"TMSA350B",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350B",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350B",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					
				ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
					If TmsAcesso(,"TMSA350C",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350C",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350C",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					
				ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
					If TmsAcesso(,"TMSA350G",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350G",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350G",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					
				ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional
					If TmsAcesso(,"TMSA350I",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350I",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350I",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					
				EndIf
			
			ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
			
				If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
					If TmsAcesso(,"TMSA350D",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350D",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350D",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					If ExistFunc('TMSA351Vis') .And. !Empty(cAtvChgCli)
						AAdd(aRotina, { STR0032 , "TMSA351Vis",0,7 }) //"Documentos"
					EndIf	
					
				ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
					If TmsAcesso(,"TMSA350F",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350F",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350F",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					
				ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial 
					If TmsAcesso(,"TMSA350H",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350H",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350F",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
					
				ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional
					If TmsAcesso(,"TMSA350I",,2,.F.)
						AAdd(aRotina, { STR0076 , 'TmsA350Mnt',0,2}) //"&Visualizar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350I",,3,.F.)
						AAdd(aRotina, { STR0072 , 'TmsA350Mnt',0,3}) //"&Apontar"
						lRet := .T.
					EndIf
					If TmsAcesso(,"TMSA350I",,5,.F.)
						AAdd(aRotina, { STR0055 , 'TmsA350Est',0,5}) //"&Estornar" 
						lRet := .T.
					EndIf
				EndIf
				
			EndIf 

			AAdd(aRotina, { STR0079 , 'TmsA350Leg',0,6}) //"&Legenda"

			If !lRet
				Help('',1,'SEMPERM',,STR0009+' e/ou '+Substr(STR0072,2,7)+' e/ou '+Substr(STR0055,2,8),03,00)
			EndIf

			aIndexSub  := {}
			cFiltraSub := "DTW_FILIAL=='"+xFilial("DTW")+"'.And.DTW_FILORI=='"+M->DTQ_FILORI+"'.And.DTW_VIAGEM=='"+M->DTQ_VIAGEM+"'"

			If lTM144FOPE
				cRetPE:=ExecBlock("TM144FOPE",.F.,.F.)
				If Valtype(cRetPE)=='C'
					cFiltraSub+=cRetPE
				EndIf
			EndIf

			bFiltraSub := {|| FilBrowse("DTW",@aIndexSub,@cFiltraSub) }
			Eval(bFiltraSub)

			aCores := {}
			AAdd(aCores,{"DTW->DTW_STATUS=='1'",'BR_VERDE'		})			//-- Em Aberto
			AAdd(aCores,{"DTW->DTW_STATUS=='2'",'BR_VERMELHO'	})			//-- Encerrado
			AAdd(aCores,{"DTW->DTW_STATUS=='9'",'BR_PRETO'		})			//-- Cancelado

			MaWndBrowse(0,0,300,600,STR0063,"DTW",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores) //"Operacoes"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndFilBrw("DTW",aIndexSub)
		Endif

	Case cMnuSub == 5  		//-- Fechamento de Viagem
		SetFunName("TMSA310")
		aRotina := {	{"","", 0, 1 },;
						{"","", 0, 2 },;
						{"","", 0, 3 },;
						{"","", 0, 4 },;
						{"","", 0, 5 } }

		If cSerTms == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Coleta
		
			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310A",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310A",,4)
				EndIf
				
			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310E",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310E",,4)
				EndIf
				
			EndIf
			
		ElseIf cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte

			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310B",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310B",,4)
				EndIf
				
			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310C",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310C",,4)
				EndIf
				
			ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310G",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310G",,4)
				EndIf
				
			ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310I",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310I",,4)
				EndIf

			EndIf
		
		ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
		
			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310D",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310D",,4)
				EndIf
				
			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310F",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310F",,4)
				EndIf

			ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310H",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310H",,4)
				EndIf
			
			ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA310I",,3)
				ElseIf nOpcX == 5
					lRet := TmsAcesso(,"TMSA310I",,4)
				EndIf
			EndIf
		EndIf		
		
		If lRet
			TMSA310Mnt("DTQ",DTQ->(Recno()),nOpcx,,.T.)
		EndIf
		
	Case cMnuSub == 6    	//--  Registro de Ocorrencias 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
		//³  aplicados no rpo do                                  			|
		//| cliente, assim verificando a necessidade de uma atualizacao     |
		//| nestes fontes. NAO REMOVER !!!							        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(TMSA360_V() >= 20061002)
			Alert(STR0086+"TMSA360.PRW !!!")//"Atualizar "
		Else
			SetFunName("TMSA360")
			TMA360Ini() //-- Inicializa F12 os Ajustes SX, help
			DbSelectArea("DUA")
			DbSetOrder(1)
			aRotina := {}
			
			AAdd( aRotina, { STR0078 , 'TMSXPesqui',0,1}) 	//"&Pesquisar"
			
			If TmsAcesso(,"TMSA360",,2,.F.)
				AAdd( aRotina, { STR0076 , 'TMSA144Oco',0,2}) //"&Visualizar"
				lRet := .T.
			EndIf
			
			If TmsAcesso(,"TMSA360",,3,.F.)
				AAdd( aRotina, { STR0072 , 'TMSA144Oco',0,3}) //"&Apontar"	
				lRet := .T.
			EndIf
			
			If TmsAcesso(,"TMSA360",,4,.F.)
				AAdd( aRotina, { STR0055 , 'TMSA144Oco',0,6}) //"&Estornar"
				lRet := .T.
			EndIf
			
			If TmsAcesso(,"TMSA360",,7,.F.)
				AAdd( aRotina, { STR0163 , 'TMSA144Oco',0,6}) //"&Ajustar"
				lRet := .T.
			EndIf
			

			If !lRet
				Help('',1,'SEMPERM',,STR0009+' e/ou '+Substr(STR0072,2,7)+' e/ou '+Substr(STR0055,2,8),03,00)
			EndIf

			aIndexSub  := {}
			cFiltraSub := "DUA_FILIAL=='"+xFilial("DUA")+"'.And.DUA_FILORI=='"+M->DTQ_FILORI+"'.And.DUA_VIAGEM=='"+M->DTQ_VIAGEM+"'"
			bFiltraSub := {|| FilBrowse("DUA",@aIndexSub,@cFiltraSub) }
			Eval(bFiltraSub)

			MaWndBrowse(0,0,300,600,STR0065,"DUA",aCampos,aRotina,,,,.T.,,,,,,,,.F.) //"Reg.Ocorrencia"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndFilBrw("DUA",aIndexSub)
		EndIf

	Case cMnuSub == 7			//-- Encerramento de Viagem 
		SetFunName("TMSA340")
		aRotina := {	{ "", "", 0, 1 },;
						{ "", "", 0, 2 },;
						{ "", "", 0, 3 },;
						{ "", "", 0, 4 },;
						{ "", "", 0, 5 } }

		If cSerTms == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Coleta

			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340A",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340A",,4)
				EndIf

			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340E",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340E",,4)
				EndIf

			EndIf

		ElseIf cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte

			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340B",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340B",,4)
				EndIf

			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340C",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340C",,4)
				EndIf

			ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340G",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340G",,4)
				EndIf

			ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340I",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340I",,4)
				EndIf
			EndIf

		ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega

			If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340D",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340D",,4)
				EndIf

			ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340F",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340F",,4)
				EndIf

			ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340H",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340H",,4)
				EndIf

			ElseIf cTipTra == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Internacional
				If nOpcX == 3
					lRet := TmsAcesso(,"TMSA340I",,3)
				ElseIf nOpcX == 4
					lRet := TmsAcesso(,"TMSA340I",,4)
				EndIf

			EndIf
		EndIf

		If lRet
			If nOpcx == 3
				TMSA340Mnt( "DTQ", 0, nOpcx )
			Else
				TMSA340Mnt( "DTQ", DTQ->(Recno()), nOpcx )
			EndIf
		EndIf

	Case cMnuSub == 8			//-- Mvto. Caixinha
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
		//³  aplicados no rpo do                                  			|
		//| cliente, assim verificando a necessidade de uma atualizacao     |
		//| nestes fontes. NAO REMOVER !!!							        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(FINA560_V() >= 20061002)
			Alert(STR0086+"FINA560.PRW !!!")//"Atualizar "
		Else
			SetFunName("FINA560")
			aRotina := {}

			AAdd(aRotina, { STR0078 , "AxPesqui"  ,0,1}) //"&Pesquisar" 

			If TmsAcesso(,"FINA560",,2,.F.)
				AAdd(aRotina, { STR0076 , "AxVisual"   ,0,2}) //"&Visualizar"
				lRet := .T.
			EndIf

			If TmsAcesso(,"FINA560",,3,.F.)
				AAdd(aRotina, { STR0080 , "TMSA144Mcx" ,0,3}) //"&Incluir"
				lRet := .T.
			EndIf

			If TmsAcesso(,"FINA560",,4,.F.)
				AAdd(aRotina, { STR0073 , "TMSA144Mcx" ,0,5}) //"&Cancelar"
				lRet := .T.
			EndIf

			If TmsAcesso(,"FINA560",,5,.F.)
				AAdd(aRotina, { STR0074 , "TMSA144Mcx" ,0,4}) //"P&rest. de Contas"
				lRet := .T.
			EndIf

			AAdd(aRotina, { STR0079 , "FA560Legend",0,2})//"&Legenda"

			If !lRet
				Help('',1,'SEMPERM',,STR0009+' e/ou '+STR0010+' e/ou '+Substr(STR0073,2,8)+' e/ou '+Substr(STR0074,1,1)+Substr(STR0074,3,15),03,00)
			EndIf

			aCores := {}
			AAdd(aCores, {'SEU->EU_TIPO="00" .AND. Empty(SEU->EU_BAIXA) .AND. Empty(SEU->EU_NROADIA)'	, 'ENABLE'    }) // Despesas nao baixadas
			AAdd(aCores, {'SEU->EU_TIPO="00" .AND. Empty(SEU->EU_BAIXA) '								, 'BR_AZUL'   }) // Despesas de adiantamento nao baixadas
			AAdd(aCores, {'SEU->EU_TIPO="01" .AND. SEU->EU_SLDADIA>0'	  								, 'BR_AMARELO'}) // Adiantamento com saldo (em aberto)
			AAdd(aCores, {'!Empty(SEU->EU_BAIXA)'														, 'DISABLE'   }) // despesas baixadas e outros movimentos

			aIndexSub  := {}
			cFiltraSub := "EU_FILIAL=='"+xFilial("SEU")+"' .And.EU_FILORI=='"+M->DTQ_FILORI+"'.And.EU_VIAGEM=='"+M->DTQ_VIAGEM+"'"
			bFiltraSub := {|| FilBrowse("SEU",@aIndexSub,@cFiltraSub) }
			Eval(bFiltraSub)

			MaWndBrowse(0,0,300,660,STR0067,"SEU",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores) //"Movto.Caixinha"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndFilBrw("SEU",aIndexSub)

		EndIf
	Case cMnuSub == 9			//-- AWB
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
		//³  aplicados no rpo do                                  			|
		//| cliente, assim verificando a necessidade de uma atualizacao     |
		//| nestes fontes. NAO REMOVER !!!							        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(TMSA320_V() >= 20061002)
			Alert(STR0086+"TMSA320.PRW !!!")//"Atualizar "
		Else
			SetFunName("TMSA320")
			aRotina := {}

			AAdd(aRotina, { STR0078 , "AxPesqui" ,0,1}) //"&Pesquisar"

			If TmsAcesso(,"TMSA320",,2,.F.)
				AAdd(aRotina, { STR0076 ,"TMSA144AWB",0,2})	//"&Visualizar"
				lRet := .T.
			EndIf

			If TmsAcesso(,"TMSA320",,3,.F.)
				AAdd(aRotina, { STR0080 ,"TMSA144AWB",0,3})	//"&Incluir"
				lRet := .T.
			EndIf

			If TmsAcesso(,"TMSA320",,4,.F.)
				AAdd(aRotina, { STR0055 ,"TMSA144AWB",0,5}) 	//"&Estornar"
				lRet := .T.
			EndIf

			If TmsAcesso(,"TMSA320",,5,.F.)
				AAdd(aRotina, { STR0070 ,"U_RTMSR08",0,4}) 	//"Im&primir"
				lRet := .T.	
			EndIf

			If !lRet
				Help('',1,'SEMPERM',,STR0009+' e/ou '+STR0010+' e/ou '+Substr(STR0055,2,8)+' e/ou '+Substr(STR0070,1,2)+Substr(STR0070,4,6),03,00)
			EndIf
			aIndexSub  := {}
			cFiltraSub := "DTV_FILIAL=='"+xFilial("DTV")+"' .And.DTV_FILORI=='"+M->DTQ_FILORI+"'.And.DTV_VIAGEM=='"+M->DTQ_VIAGEM+"'"
			bFiltraSub := {|| FilBrowse("DTV",@aIndexSub,@cFiltraSub) }
			Eval(bFiltraSub)

			MaWndBrowse(0,0,300,660,STR0075,"DTV",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores) //"Geracao AWB"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndFilBrw("DTV",aIndexSub)
		EndIf
	Case cMnuSub == 10	//-- Estorno Express
		TmsA144Exp(cSerTms, cTipTra)

	Case cMnuSub == 11	//--Carregamento Grafico
		If TmsChkVer('11','R7')
			If cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))
				lRet := .T.
				SetFunName("TMSA215")
				DTR->( DbSetOrder( 1 ) )
				If DTR->( ! MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
					Help( ' ', 1, 'TMSA24002', , STR0038 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)###" Viagem : "
					lRet := .F.
				Else
					If nOpcx <> 2 .And. !TMSChkViag( M->DTQ_FILORI, M->DTQ_VIAGEM, .T., .F., .F., , .F., .F., , .T., , , , .T. )
						lRet := .F.
					EndIf
					If lRet
						If nOpcx == 9 //- Se for para verificar o ultimo carregamento grafico
							If FindFunction('TMSA215Ult')
								TMSA215Ult() //--Traz os carregamentos que foram gerados para a viagem.
							EndIf	 							
						ElseIf nOpcx == 2 .Or. nOpcx == 5                              					
							If TA144QtdCG(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,@cCodVei) > 1
								DTR->(dbSetOrder(3))
								DTR->(dbSeek(xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
								While DTR->(!Eof()) .And. xFilial("DTR")+DTR->(DTR_FILORI+DTR_VIAGEM) == DTQ->(DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM)
									If !Empty(DTR->DTR_CODRB1)
										cDesVei := Posicione("DA3",1,xFilial("DA3")+DTR->DTR_CODRB1,"DA3_DESC")
										Aadd( aCodVei, { .F., DTR->DTR_CODVEI, DTR->DTR_CODRB1, cDesVei, '1'})
										If !Empty(DTR->DTR_CODRB2)
											cDesVei := Posicione("DA3",1,xFilial("DA3")+DTR->DTR_CODRB2,"DA3_DESC")
											Aadd( aCodVei, { .F., DTR->DTR_CODVEI, DTR->DTR_CODRB2, cDesVei, '2'})
								   			
												If !Empty(DTR->DTR_CODRB3)                
													cDesVei := Posicione("DA3",1,xFilial("DA3")+DTR->DTR_CODRB3,"DA3_DESC")							
													Aadd( aCodVei, { .F., DTR->DTR_CODVEI, DTR->DTR_CODRB3, cDesVei, '3'})
												EndIf
										
										EndIf
									EndIf
									DTR->(dbSkip())
								EndDo
								lRet := TMSABrowse(aCodVei,STR0048,,,,.T.,{ STR0049, STR0050 }) //-- Veiculos da viagem //"Veículos da viagem"###'Cód.Veículo'###'Modelo'
								cVeiCar := aCodVei[Ascan(aCodVei,{ | e | e[1] == .T. })][5]
								cCodVei := aCodVei[Ascan(aCodVei,{ | e | e[1] == .T. })][2]
								DDK->(dbSetOrder(1))
								If !DDK->(dbSeek(xFilial('DDK')+M->DTQ_FILORI+M->DTQ_VIAGEM+cCodVei+cVeiCar))
									Help("",1,"TMSA14426")//--Não existe carregamento grafico por unitizador para esta viagem!
									lRet := .F.
								EndIf
							Else
								DDK->(dbSetOrder(1))
								If !DDK->(dbSeek(xFilial('DDK')+M->DTQ_FILORI+M->DTQ_VIAGEM+cCodVei+cVeiCar))
									Help("",1,"TMSA14426")//--//--Não existe carregamento grafico por unitizador para esta viagem!
									lRet := .F.
								EndIf
							EndIf
							If lRet
								nOpcView:= IIf(nOpcx == 3,MODEL_OPERATION_INSERT,IIf(nOpcx == 5,MODEL_OPERATION_DELETE,IIf(nOpcx == 4,MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW)))
								oModel215:= FWLoadModel("TMSA215")
								oModel215:SetOperation(nOpcView)
								oModel215:Activate()
								If lRet .And. (nOpcView == MODEL_OPERATION_INSERT)
									oModel215:GetModel( 'MdFieldDDK' ):SetValue( 'DDK_FILORI', M->DTQ_FILORI )
									oModel215:GetModel( 'MdFieldDDK' ):SetValue( 'DDK_VIAGEM', M->DTQ_VIAGEM )
								EndIf
								FWExecView(, "TMSA215" , nOpcView , ,{|| .T. }, , , , , , ,oModel215 )
								oModel215:DeActivate()
							EndIf
						EndIf
					EndIf	
				EndIf
			Else
				Help("",1,"TMSA14427")//--'Rotina habilitada somente para viagens do transporte rodoviário!'
			EndIf
		Else
			Help("",1,"TMSA14428")//--'Funcionalidade disponivel a partir do Release 11.80!'
		EndIf	
	Case cMnuSub == 20	//-- Tratamento Rentabilidade/Ocorrencia -> Fornecedores Adicionais
	
		//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
		If !(AliasInDic("DJM"))
			//-- Mensagem genérica solicitando a atualização do sistema.
			MsgNextRel()
		EndIf
		
		//-- Carrega Modelo Do TMSA151
		If FindFunction("TMSA151")
		
			//-- Fornecedores Adicionais
			DbSelectArea("DJM")
			DbSetOrder(1) //-- DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR
			If MsSeek( xFilial("DJM") + M->DTQ_FILORI + M->DTQ_VIAGEM , .f. )
				nOpcView := MODEL_OPERATION_UPDATE
			Else
				nOpcView := MODEL_OPERATION_INSERT
			EndIf

			oModel151:= FWLoadModel("TMSA151")
			oModel151:SetOperation(nOpcView)
			oModel151:Activate()
			If nOpcView == MODEL_OPERATION_INSERT
				oModel151:GetModel( 'TMSA151_CAB' ):SetValue( 'DJM_FILORI', M->DTQ_FILORI )
				oModel151:GetModel( 'TMSA151_CAB' ):SetValue( 'DJM_VIAGEM', M->DTQ_VIAGEM )
			EndIf
			FWExecView(, "TMSA151" , nOpcView , ,{|| .T. }, , , , , , ,oModel151 )
			oModel151:DeActivate()

		EndIf
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as Variaveis do MBrowse Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetFunName(cOldFName)
RestInter()
RestArea( aArea )

cFiltro:= bkpcFiltro
CursorWait()
If Type('bFiltraBrw') <> 'U'
	Eval(bFiltraBrw)
EndIf
CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144Oco ³ Autor ³ Telso Carneiro      ³ Data ³ 15/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada para o Registros de Ocorrencias                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Oco(cAlias, nTmsRec, nOpcx)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144Sub                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144Oco(cAlias, nTmsRec, nOpc)
Local lRet

If nOpc == 3
	lRet := TMSA360Mnt(cAlias, 0, nOpc, M->DTQ_FILORI, M->DTQ_VIAGEM)
Else
	Inclui := .F.
	lRet := TMSA360Mnt(cAlias, DUA->(Recno()), nOpc )
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144Mcx ³ Autor ³ Telso Carneiro      ³ Data ³ 15/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada para o Registros de Ocorrencias                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144Oco(cAlias, nTmsRec, nOpcx)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144Sub                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144Mcx(cAlias, nTmsRec, nOpc)
Local lRet := .T.

//-- Variaveis usada na integracao com FINANCEIRO (FINA560)
Private aDiario := {}
Private cCodDiario:= ""
Private aAutoCab

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw(cAlias,aIndexSub)

SEU->(DbGOTO(nTmsRec))

Pergunte("FIA550",.F.)

If nOpc == 3
	Inclui := .T.
	lRet := FA560Inclui(cAlias, 0, nOpc, M->DTQ_FILORI, M->DTQ_VIAGEM)
ElseIf nOpc == 4
	lRet := FA560Deleta(cAlias, SEU->(Recno()), nOpc)
ElseIf nOpc == 5
	lRet := FA560Adian(cAlias, SEU->(Recno()), nOpc)
EndIf

Eval(bFiltraSub)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA144AWB ³ Autor ³ Telso Carneiro      ³ Data ³ 29/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada para o Geracao de AWB Somente em Transp Aereo 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA144AWB(cAlias, nTmsRec, nOpcx)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144Sub                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA144AWB(cAlias, nTmsRec, nOpc)
Local lRet

If nOpc == 3
	Inclui := .T.
	lRet   := TMSA320Mnt(cAlias, 0, nOpc, M->DTQ_FILORI, M->DTQ_VIAGEM)
Else
	Inclui := .F.
	lRet   := TMSA320Mnt(cAlias, DTV->(Recno()), nOpc)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuD144  ³ Autor ³ Jefferson Tomaz       ³ Data ³23/12/2008³±±
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
Function MenuD144(cSerTms,cTipTra)

Local aEncRotina := {}
Local aFecRotina := {}
Local aMafRotina := {}
Local aCarRotina := {}
Local aImpRotina := {}
Local aMntRotina := {}
Local aGrfRotina := {}
Local lTMSExp    := SuperGetMv("MV_TMSEXP", .F., .F.)
Local aArea      := GetArea() 
Local cTMSOpDg	 := SuperGetMv("MV_TMSOPDG", .F., .F.)	// Indica se a integração com Operadoras de Frota está ativa. 0=Não utiliza, 1=Somente Vale-Pedágio e 2=Vale Pedágio e Frota.
Local aRotMan	 := {}

Private aRotina    := {}

aEncRotina := {	{ STR0054, "TMSA144Sub(7, 3)",0 ,3 },; //"Encerrar"
				{ STR0055, "TMSA144Sub(7, 4)",0 ,4 } } //"&Estornar"

aFecRotina := {	{ STR0056, "TMSA144Sub(5, 3)",0 ,3 },; //"Fechar"
				{ STR0055, "TMSA144Sub(5, 5)",0 ,4 } } //"&Estornar"


If TableInDic("DLI",.F.) .And. ExistFunc("TMSAE74")
	aMafRotina := {	{ STR0057, "TMSA144Sub(3, 2)",0 ,2 },; //"Visual/Excluir"
					{ STR0058, "TMSA144Sub(3, 3)",0 ,3 },; //"Manifestar"
					{ STR0104, "TMSAE73()",0 ,2 },;	//"MDF-e"
					{ STR0159, "TMSAE74()",0 ,4 } } //"Tracking eventos MDFe"
Else
	aMafRotina := {	{ STR0057, "TMSA144Sub(3, 2)",0 ,2 },; //"Visual/Excluir"
					{ STR0058, "TMSA144Sub(3, 3)",0 ,3 },; //"Manifestar"
					{ STR0104, "TMSAE73()",0 ,2 } } //"MDF-e"
EndIf				
				 
//-- Chamada da tela de histórico do MDF-e
If TableIndic("DLH",.F.) .And. ExistFunc("TMSA190A(2)")
	Aadd(aMafRotina,{ STR0156, "TMSA190A(2)" ,0, 2 }) //"Histórico MDF-e"
EndIf 				

//-- Visualizar Percurso
If AliasInDic("DL0")
	AAdd(aMafRotina, {STR0139,"TMSA144Per(.F.)", 0, 2 	})  //"Visu. Percurso"
	AAdd(aMafRotina, {STR0160,"TMSA144Per(.T.)", 0, 2 	})  //"Editar Percurso"
EndIf

aCarRotina := {	{ STR0009, "TMSA144Sub(2, 2)",0 ,2 },; //"Visualizar"
				{ STR0059, "TMSA144Sub(2, 3)",0 ,3 },; //"Carregar"
				{ STR0055, "TMSA144Sub(2, 4)",0 ,4 } } //"&Estornar"

aGrfRotina := {	{ STR0009, "TMSA144Sub(11,2)",0 ,2 },; //"Visualizar"
				{ STR0059, "TMSA144Sub(11,3)",0 ,3 },; //"Carregar"
				{ STR0011, "TMSA144Sub(11,4)",0 ,4 },; //"Alterar"						 
				{ STR0115, "TMSA144Sub(11,9)", 0, 4},; //"&Ult.car."					 
				{ STR0055, "TMSA144Sub(11,5)",0 ,5 } } //"&Estornar"

If cSerTms $ "23"
	AAdd(aMntRotina, { STR0060, "TMSA144Sub(1, 3)"	,0 ,3 }) //"Confirmacao"
	AAdd(aMntRotina, { STR0061, aCarRotina			,0 ,2 }) //"Carregamento"
	AAdd(aMntRotina, { STR0062 ,aMafRotina			,0 ,2 }) //"Manifesto"
	AAdd(aMntRotina, { STR0113 ,"TMSA144TRM"			,0 ,2 }) //"Inclusao Condutor"
	If cTipTra == '2'
		AAdd(aMntRotina, { STR0075 	, "TMSA144Sub(9, 2)",0 ,2 })  //"Geracao AWB"
	EndIf
	AAdd(aMntRotina, { STR0063, "TMSA144Sub(4, 2)"	,0 ,2 }) //"Operacoes"
	AAdd(aMntRotina, { STR0064, aFecRotina			,0 ,2 }) //"Fechamento"
	AAdd(aMntRotina, { STR0065, "TMSA144Sub(6, 2)"	,0 ,2 }) //"Reg.Ocorrencia"
	AAdd(aMntRotina, { STR0066, aEncRotina			,0 ,2 }) //"Encerramento"
	AAdd(aMntRotina, { STR0067, "TMSA144Sub(8, 2)"	,0 ,2 }) //"Movto.Caixinha"
	If lTMSExp
		AAdd(aMntRotina, { STR0091, "TMSA144Sub(10, 2)"	,0 ,2 }) //"Estorno Express"
	EndIf
	AAdd(aMntRotina, { STR0103, aGrfRotina	,0 ,2 }) //"Carregamento Gráfico

	If cSerTms == '3'
		AAdd(aMntRotina, { STR0114, "TmsA141RU", 0, 2})  //"Retorno de Unitizadores"
	EndIf	

	AAdd(aMntRotina, { STR0126, "TMSA144Sub(20, 2)"	,0 ,2 }) //-- Tratamento Rentabilidade/Ocorrencia ->"Fornecedores Adicionais"
		
	AAdd( aRotina, { STR0008, "AXPesqui"   ,0 ,1,0,.F.}) //"Pesquisar"
	AAdd( aRotina, { STR0009, "TmsA144Mnt" ,0 ,2,0,Nil}) //"Visualizar"
	AAdd( aRotina, { STR0010, "TmsA144Mnt" ,0 ,3,0,Nil}) //"Incluir"
	AAdd( aRotina, { STR0011, "TmsA144Mnt" ,0 ,4,0,Nil}) //"Alterar"
	AAdd( aRotina, { STR0012, "TmsA144Mnt" ,0 ,5,0,Nil}) //"Excluir"
	If lTMSExp
				
		AAdd(aRotMan, {STR0062, "TmSA144IMn(,,,'NORMAL')" , 0, 7 })
		AAdd(aRotMan, {STR0168,"TmSA144IMn(,,,'DAMDFE')" , 0, 7 })
		
		AAdd( aImpRotina,{ STR0068, "TMSA144ICt" ,0 ,7 }) //"Contrato"
		AAdd( aImpRotina,{ STR0069, "TMSA144ICh" ,0 ,7 }) //"Cheque"
		
		AAdd( aImpRotina,   { STR0062, aRotMan   ,0 ,6,0,Nil}) //"Manifesto"
		AAdd( aRotina,   	{ STR0070, aImpRotina,0 ,6,0,Nil}) //"Im&primir"
	EndIf	
	AAdd( aRotina, { STR0071, aMntRotina    ,0 ,6,0,Nil}) //"Manutencao"
	AAdd( aRotina, { STR0013, "TMSA140Fbr"  ,0 ,1,0,Nil}) //"Status"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros      ³
	//³ mv_par01 // Apresenta Telas de Confimacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	AAdd(aMntRotina, { STR0060, "TMSA144Sub(1, 3)"	,0 ,3 }) //"Confirmacao"
	AAdd(aMntRotina, { STR0063, "TMSA144Sub(4, 2)"	,0 ,2 }) //"Operacoes"
	AAdd(aMntRotina, { STR0064, aFecRotina			,0 ,2 }) //"Fechamento"
	AAdd(aMntRotina, { STR0065, "TMSA144Sub(6, 2)"	,0 ,2 }) //"Reg.Ocorrencia"
	AAdd(aMntRotina, { STR0066, aEncRotina			,0 ,2 }) //"Encerramento"
	AAdd(aMntRotina, { STR0067, "TMSA144Sub(8, 2)"	,0 ,2 }) //"Movto.Caixinha"
	If cSerTms == '1'
		AAdd(aMntRotina, { STR0114, "TmsA141RU", 0, 2})  //"Retorno de Unitizadores"
	EndIf

	aRotina	:= {	{ STR0008, "AXPesqui"   ,0 ,1 ,0,.F.},; //"Pesquisar"
					{ STR0009, "TmsA144Mnt"	,0 ,2 ,0, Nil},; //"Visualizar"
					{ STR0010, "TmsA144Mnt"	,0 ,3 ,0, Nil},; //"Incluir"
					{ STR0011, "TmsA144Mnt"	,0 ,4 ,0, Nil},; //"Alterar"
					{ STR0012, "TmsA144Mnt"	,0 ,5 ,0, Nil},; //"Excluir"
					{ STR0071, aMntRotina	,0 ,6 ,0, Nil},; //"Manutencao"
					{ STR0013, 'TMSA140Fbr'	,0 ,1 ,0, Nil} } //"Status"
EndIf

If cTMSOpDg $ "1,2" .And. ExistFunc('TMSA161') // Vale Pedágio e Frota
	AAdd(aMntRotina, { STR0155, "TMSA161", 0, 2})  //"Troca de cartão"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Passagens em Postos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aRotina, {	STR0083, 'TMSA140Psg', 0, 2} ) //-- "Psg.Postos"
If ExistBlock("TMA144MNU")
	ExecBlock("TMA144MNU",.F.,.F.)
EndIf
RestArea(aArea)
Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA144   ºAutor  ³Felipe Barbieri     º Data ³  20/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada da função  TMSA240Mnt para Inclusão de Condutor    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tmsa144                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144TRM()

If DTQ->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS)) //Em trânsito
   RegToMemory('DTQ')
   TmsA240Mnt('DTR',DTR->( Recno() ),4,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,DTQ->DTQ_ROTA,DTQ->DTQ_SERTMS,,,,DTQ->DTQ_TIPVIA,.T.,,.F.,,,.F.,,,,.T.)
Else
  Help(' ', 1, 'TMSXFUNA25')
EndIf
   
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EstornExp ºAutor  ³Telso Carneiro      º Data ³  16/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorno da Viagem Express, Total ou Parcial                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tmsa144Sub                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Exp(cSerTms, cTipTra)

Local aArea     := GetArea()
Local lRet      := .T.
Local cAliasNew
Local cFilOri   := ""
Local cLotNfc   := ""
Local lDocto    := .F.
Local nTamViag	:= TamSx3("DUD_VIAGEM")[1]
Local aCabDTC   := {}
Local aItemDTC  := {}
Local aItem		:= {}
Local aCabDTP   := {}
Local aDelDUD	:= {}
Local nI		:= 1
Local nEstorno  := 1
Local lCTeUnico	:= .F.

Private aDelDocto := {}
Private cMark
Private lTmsCFec  := TmsCFec()

DTP->(DbSetOrder(3)) //DTP_FILIAL+DTP_FILORI+DTP_VIAGEM
If !DTP->(DbSeek(xFilial("DTP")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
	lRet := .F.
	MsgStop(STR0084) //"Viagem nÃo é Express"
Else

	//-- Testa o Acesso as Rotinas Estorno para o Usuario Logado.

	If cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte

		If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))		//-- Rodoviario
			lRet := TmsAcesso(,"TMSA310B",,4,.F.)			//-- Fechamento
			If lRet
				lRet := TmsAcesso(,"TMSA210A",,4,.F.)		//-- Carregamento
			EndIf
		ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Aereo
			lRet := TmsAcesso(,"TMSA310C",,4,.F.)			//-- Fechamento
			If lRet
				lRet:= TmsAcesso(,"TMSA210B",,4,.F.)		//-- Carregamento
			EndIf

		ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA))	//-- Fluvial
			lRet:= TmsAcesso(,"TMSA310G",,4,.F.)			//-- Fechamento
			If lRet
				lRet:= TmsAcesso(,"TMSA210E",,4,.F.)		//-- Carregamento
			EndIf
		EndIf

	ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS))		//-- Entrega

		If DTP->DTP_TIPLOT == '4'    
			lCTeUnico := .T.		
		EndIf
		If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA))		//--Rodoviario
			lRet:= TmsAcesso(,"TMSA310D",,4,.F.)			//-- Fechamento
			If lRet
				lRet:= TmsAcesso(,"TMSA210C",,4,.F.)		//-- Carregamento
			EndIf

		ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Aerea
			lRet:= TmsAcesso(,"TMSA310F",,4,.F.)			//-- Fechamento
			If lRet
				lRet:= TmsAcesso(,"TMSA210D",,4,.F.)		//-- Carregamento
			EndIf

		ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA))	//-- Fluvial
			lRet:= TmsAcesso(,"TMSA310H",,4,.F.)			//-- Fechamento
			If lRet
				lRet:= TmsAcesso(,"TMSA210F",,4,.F.)		//-- Carregamento
			EndIf
		EndIf
	EndIf

	If lRet
		lRet := TmsAcesso(,"TMSA250",,5,.F.)	//-- Contrato Carreteiro
	EndIf
	If lRet
		lRet := TmsAcesso(,"TMSA190",,4,.F.)	//-- Manifesto
	EndIf

	If !lRet
		Help('',1,'SEMPERM',,STR0093+STR0064+' e/ou '+STR0061+' e/ou '+STR0062,03,00) //"Estorno de "###"Fechamento"###"Carregamento"###"Manifesto"
	EndIf
	
	If lRet
		If Pergunte("TMC144",.T.)

			nEstorno := mv_par01

			If (nEstorno == 1)  //-- Total
				//-- Testa o Acesso as Rotinas Estorno para o Usuario Logado.
				lRet := TmsAcesso(,"TMSA200",,3,.F.)  //--Calculo do Frete
				If lRet
					lRet := TmsAcesso(,"TMSA050",,4,.F.)//--  NF
				EndIf
				If lRet
					lRet := TmsAcesso(,"TMSA170",,5,.F.)//-- Lote
				EndIf

				If lRet
					If cSerTms == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte

						If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
							lRet := TmsAcesso(,"TMSA144B",,5,.F.)

						ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
							lRet := TmsAcesso(,"TMSA144C",,5,.F.)

						ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
							lRet := TmsAcesso(,"TMSA144G",,5,.F.)
						EndIf

					ElseIf cSerTms == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
						If cTipTra == StrZero(1,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario
							lRet := TmsAcesso(,"TMSA144D",,5,.F.)

						ElseIf cTipTra == StrZero(2,Len(DTQ->DTQ_TIPTRA)) //-- Aereo
							lRet := TmsAcesso(,"TMSA144F",,5,.F.)

						ElseIf cTipTra == StrZero(3,Len(DTQ->DTQ_TIPTRA)) //-- Fluvial
							lRet := TmsAcesso(,"TMSA144H",,5,.F.)
						EndIf
					EndIf
				EndIf
				If !lRet
					Help('',1,'SEMPERM',,STR0094,03,00)	//'Estorno do Calculo de Frete e/ou Nota Fiscal e/ou Lote e/ou Viagem'
				EndIf

			EndIf

			If lRet
				If lTM144EEX
					ExecBlock("TM144EEX",.F.,.F.,{ DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, nEstorno })
				EndIf

				Begin TransAction

					//-- Fechamento de Viagem
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
					//³  aplicados no rpo do                                			|
					//| cliente, assim verificando a necessidade de uma atualizacao     |
					//| nestes fontes. NAO REMOVER !!!                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SetFunName("TMSA310")
					aRotina := {	{ "", "", 0, 1 },;
									{ "", "", 0, 2 },;
									{ "", "", 0, 3 },;
									{ "", "", 0, 4 },;
									{ "", "", 0, 5 } }

					lRet := TMSA310Mnt("DTQ",DTQ->(Recno()),5,,.F.)

					If lRet
						//-- Contrato de Carreteiro
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
						//³  aplicados no rpo do                                		    |
						//| cliente, assim verificando a necessidade de uma atualizacao     |
						//| nestes fontes. NAO REMOVER !!!                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("DTY")
						DTY->(DbSetOrder(2))
						If DTY->(DbSeek(xFilial("DTY")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
							lRet := TMSA250Mnt("DTY",DTY->(Recno()),5,,.F.)
						EndIf
					EndIf

					If lRet 
						//--  Manifesto de Carga
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
						//³  aplicados no rpo do                                            ³
						//| cliente, assim verificando a necessidade de uma atualizacao     ³
						//³ nestes fontes. NAO REMOVER !!!                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("DTX")
						DTX->(DbSetOrder(3))
						If DTX->(DbSeek(xFilial("DTX")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))

							SetFunName("TMSA190")
							aRotina := {	{ ""  ,"", 0, 1 },;
											{ ""  ,"", 0, 2 },;
											{ ""  ,"", 0, 3 },;
											{ ""  ,"", 0, 4 },;
											{ ""  ,"", 0, 5 } }

							lRet := TmsA190Mnt("DTX", DTX->(Recno()), 5, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,,.F.)
						EndIf
					EndIf

					If lRet
						//-- Carregamento
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Funcao utilizada para verificar a ultima versao dos fontes,     ³
						//³  aplicados no rpo do                                            ³
						//³ cliente, assim verificando a necessidade de uma atualizacao     ³
						//³ nestes fontes. NAO REMOVER !!!                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("DTA")
						DbSetOrder(4) //DTA_FILIAL+DTA_SERTMS+DTA_TIPTRA+DTA_FILORI+DTA_VIAGEM+DTA_FILDOC+DTA_DOC+DTA_SERIE
						If DTA->(DbSeek(xFilial("DTA")+DTQ->DTQ_SERTMS+DTQ->DTQ_TIPTRA+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
							lRet := TmsA210Mnt("DTA", DTA->(Recno()), 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,.F.)
						EndIf
					EndIf

					If lRet
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Estorna o Calculo do Frete³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cAliasNew := CriaTrab(Nil,.F.)
						cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, R_E_C_N_O_ "
						cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
						cQuery += "   WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
						cQuery += "     AND DUD.DUD_FILORI = '" + DTQ->DTQ_FILORI + "'"
						cQuery += "     AND DUD.DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
						cQuery += "     AND DUD.DUD_STATUS <> '" + StrZero(9,Len(DUD->DUD_STATUS)) + "'" //Cancelado
						cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery( cQuery )
						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
						//-- Limpa a Viagem do DUD
						While (cAliasNew)->(!Eof())
							AAdd(aDelDUD,{(cAliasNew)->DUD_FILDOC,(cAliasNew)->DUD_DOC,(cAliasNew)->DUD_SERIE})
							DUD->(DbGoTo((cAliasNew)->R_E_C_N_O_))
							RecLock("DUD",.F.)
							DUD->DUD_VIAGEM := Space(nTamViag)
							MsUnlock()
							DUD->(dbCommit())
							(cAliasNew)->(DbSkip())
						EndDo
						(cAliasNew)->(DbCloseArea())

						For nI:= 1 To Len(aDelDUD)

							DT6->(DbSetOrder(1))
							If DT6->(DbSeek(xFilial("DT6")+aDelDUD[nI,1]+aDelDUD[nI,2]+aDelDUD[nI,3]))

								cFilOri := DT6->DT6_FILORI
								cLotNfc := DT6->DT6_LOTNFC
								cMark   := GetMark()
								TmsA200Cmp(, aDelDocto, .T., .F. )
								Processa( {|lEnd| lRet := TMSA200Exc( aDelDocto, cLotNfc, @lEnd, @lDocto,, .T. ) }, STR0091,STR0092, .F. )//"Estorno Express"####"Estornando conhecimento de frete...	"

								//-- lDocto igual a .F. indica que todos os documentos do lote foram estornados, entao o status do lote passa para digitado.
								//-- lDocto igual a .T. indica que alguns documentos do lote nao foram estornados, entao o status do lote permanece como calculado.
								If lRet .And. ! lDocto
									//-- Atualiza o status do lote para ( 2 - Digitado )
									Processa( {|lEnd| lRet := TMSA200Sta(@lEnd, DTP->DTP_LOTNFC, StrZero(2,Len(DTP->DTP_STATUS)) ) }, cCadastro,STR0085, .F. ) //'Atualizando Status do Lote...'
								EndIf
							EndIf
							If !lRet
								Exit
							EndIf
						Next nI
					EndIf

					If lRet .And. (nEstorno == 1) .And. lCTeUnico // Tratamento para o Estorno quando o CTe for Unico o ExcAuto do TMS050 tem tratamento diferente
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Estorno da Nota FiscaL	 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lMsErroAuto := .F.
						
						aCabDTC   := {}
						aItemDTC  := {}
						cAliasNew := CriaTrab(Nil,.F.)
						
						cQuery := " SELECT * "
						cQuery += "   FROM " + RetSQLName("DTC") + " DTC "
						cQuery += "   WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "'"
						cQuery += "     AND DTC.DTC_FILORI = '" + DTP->DTP_FILORI + "'"
						cQuery += "     AND DTC.DTC_LOTNFC = '" + DTP->DTP_LOTNFC + "'"
						cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery( cQuery )
						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
						
						While (cAliasNew)->(!Eof())
					
							aCabDTC := {{"DTC_FILIAL" ,(cAliasNew)->(DTC_FILIAL), Nil},;
											{"DTC_FILORI" ,(cAliasNew)->(DTC_FILORI), Nil},;
											{"DTC_LOTNFC" ,(cAliasNew)->(DTC_LOTNFC), Nil},;
											{"DTC_CLIREM" ,(cAliasNew)->(DTC_CLIREM), Nil},;
											{"DTC_LOJREM" ,(cAliasNew)->(DTC_LOJREM), Nil},;
											{"DTC_DATENT" ,(cAliasNew)->(DTC_DATENT), Nil},;
											{"DTC_CLIDES" ,(cAliasNew)->(DTC_CLIDES), Nil},;
											{"DTC_LOJDES" ,(cAliasNew)->(DTC_LOJDES), Nil},;
											{"DTC_CLIDEV" ,(cAliasNew)->(DTC_CLIDEV), Nil},;
											{"DTC_LOJDEV" ,(cAliasNew)->(DTC_LOJDEV), Nil},;
											{"DTC_CLICAL" ,(cAliasNew)->(DTC_CLICAL), Nil},;
											{"DTC_LOJCAL" ,(cAliasNew)->(DTC_LOJCAL), Nil},;
											{"DTC_DEVFRE" ,(cAliasNew)->(DTC_DEVFRE), Nil},;
											{"DTC_SERTMS" ,(cAliasNew)->(DTC_SERTMS), Nil},;
											{"DTC_TIPTRA" ,(cAliasNew)->(DTC_TIPTRA), Nil},;
											{"DTC_SERVIC" ,(cAliasNew)->(DTC_SERVIC), Nil},;
											{"DTC_TIPNFC" ,(cAliasNew)->(DTC_TIPNFC), Nil},;
											{"DTC_TIPFRE" ,(cAliasNew)->(DTC_TIPFRE), Nil},;
											{"DTC_SELORI" ,(cAliasNew)->(DTC_SELORI), Nil},;
											{"DTC_CDRORI" ,(cAliasNew)->(DTC_CDRORI), Nil},;
											{"DTC_CDRDES" ,(cAliasNew)->(DTC_CDRDES), Nil},;
											{"DTC_DISTIV" ,(cAliasNew)->(DTC_DISTIV), Nil},;
											{"DTC_CODPRO" ,(cAliasNew)->(DTC_CODPRO), Nil},;
											{"DTC_NUMNFC" ,(cAliasNew)->(DTC_NUMNFC), Nil},;
											{"DTC_SERNFC" ,(cAliasNew)->(DTC_SERNFC), Nil}}
										
							

							aItem := { {"DTC_NUMNFC" ,(cAliasNew)->(DTC_NUMNFC), Nil},;
											{"DTC_SERNFC" ,(cAliasNew)->(DTC_SERNFC), Nil},;
											{"DTC_CODPRO" ,(cAliasNew)->(DTC_CODPRO), Nil},;
											{"DTC_CODEMB" ,(cAliasNew)->(DTC_CODEMB), Nil},;
											{"DTC_EMINFC" ,(cAliasNew)->(DTC_EMINFC), Nil},;
											{"DTC_QTDVOL" ,(cAliasNew)->(DTC_QTDVOL), Nil},;
											{"DTC_PESO"   ,(cAliasNew)->(DTC_PESO)  , Nil},;
											{"DTC_PESOM3" ,(cAliasNew)->(DTC_PESOM3), Nil},;
											{"DTC_VALOR"  ,(cAliasNew)->(DTC_VALOR) , Nil},;
											{"DTC_BASSEG" ,(cAliasNew)->(DTC_BASSEG), Nil},;
											{"DTC_QTDUNI" ,(cAliasNew)->(DTC_QTDUNI), Nil},;
											{"DTC_EDI"    ,(cAliasNew)->(DTC_EDI)   , Nil},;
											{"DTC_ESTORN" ,"1", Nil}}
											
							AAdd(aItemDTC,aClone(aItem))

							If Len(aCabDTC) > 0 .AND. Len(aItemDTC) > 0
								//
								// Parametros da TMSA050 (notas fiscais do cliente)
								// xAutoCab - Cabecalho da nota fiscal
								// xAutoItens - Itens da nota fiscal
								// xIten sPesM3 - acols de Peso Cubado
								// xItensEnder - ac ols de Enderecamento
								// nOpcAuto - Opcao rotina a utomatica
								
								MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,5)
								If lMsErroAuto
									MostraErro()
									lRet := .F.
								EndIf
                            
								aCabDTC		:={}
    	    					aItem		:={}
								aItemDTC	:={}					
							EndIf
							
							(cAliasNew)->(DbSkip())
						EndDo
						(cAliasNew)->(DbCloseArea())
						
						If lRet
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Exclusao do Lote	   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lMsErroAuto := .F.
							aCabDTP := {{"DTP_FILORI" ,DTP->DTP_FILORI, Nil},;
											{"DTP_LOTNFC" ,DTP->DTP_LOTNFC, Nil}}
							
							MSExecAuto({|u,v| TMSA170(u,v)},aCabDTP,5)
							If lMsErroAuto
								MostraErro()
								lRet := .F.
							EndIf
						EndIf
						If lRet
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Exclusao da Viagem  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TmsA144Mnt( "DTQ", DTQ->(Recno()), 5, .F. )
						EndIf
					ElseIf lRet .And. (nEstorno == 1) .And. !lCTeUnico
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Estorno da Nota FiscaL	 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lMsErroAuto := .F.
						
						aCabDTC   := {}
						aItemDTC  := {}
						cAliasNew := CriaTrab(Nil,.F.)
						
						cQuery := " SELECT * "
						cQuery += "   FROM " + RetSQLName("DTC") + " DTC "
						cQuery += "   WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "'"
						cQuery += "     AND DTC.DTC_FILORI = '" + DTP->DTP_FILORI + "'"
						cQuery += "     AND DTC.DTC_LOTNFC = '" + DTP->DTP_LOTNFC + "'"
						cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery( cQuery )
						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
						
						If (cAliasNew)->(!Eof())
							aCabDTC := {{"DTC_FILIAL" ,(cAliasNew)->(DTC_FILIAL), Nil},;
											{"DTC_FILORI" ,(cAliasNew)->(DTC_FILORI), Nil},;
											{"DTC_LOTNFC" ,(cAliasNew)->(DTC_LOTNFC), Nil},;
											{"DTC_CLIREM" ,(cAliasNew)->(DTC_CLIREM), Nil},;
											{"DTC_LOJREM" ,(cAliasNew)->(DTC_LOJREM), Nil},;
											{"DTC_DATENT" ,(cAliasNew)->(DTC_DATENT), Nil},;
											{"DTC_CLIDES" ,(cAliasNew)->(DTC_CLIDES), Nil},;
											{"DTC_LOJDES" ,(cAliasNew)->(DTC_LOJDES), Nil},;
											{"DTC_CLIDEV" ,(cAliasNew)->(DTC_CLIDEV), Nil},;
											{"DTC_LOJDEV" ,(cAliasNew)->(DTC_LOJDEV), Nil},;
											{"DTC_CLICAL" ,(cAliasNew)->(DTC_CLICAL), Nil},;
											{"DTC_LOJCAL" ,(cAliasNew)->(DTC_LOJCAL), Nil},;
											{"DTC_DEVFRE" ,(cAliasNew)->(DTC_DEVFRE), Nil},;
											{"DTC_SERTMS" ,(cAliasNew)->(DTC_SERTMS), Nil},;
											{"DTC_TIPTRA" ,(cAliasNew)->(DTC_TIPTRA), Nil},;
											{"DTC_SERVIC" ,(cAliasNew)->(DTC_SERVIC), Nil},;
											{"DTC_TIPNFC" ,(cAliasNew)->(DTC_TIPNFC), Nil},;
											{"DTC_TIPFRE" ,(cAliasNew)->(DTC_TIPFRE), Nil},;
											{"DTC_SELORI" ,(cAliasNew)->(DTC_SELORI), Nil},;
											{"DTC_CDRORI" ,(cAliasNew)->(DTC_CDRORI), Nil},;
											{"DTC_CDRDES" ,(cAliasNew)->(DTC_CDRDES), Nil},;
											{"DTC_DISTIV" ,(cAliasNew)->(DTC_DISTIV), Nil}}
										
							AAdd(aCabDTC,{"DTC_CODPRO" ,(cAliasNew)->(DTC_CODPRO), Nil})
							AAdd(aCabDTC,{"DTC_NUMNFC" ,(cAliasNew)->(DTC_NUMNFC), Nil})
							AAdd(aCabDTC,{"DTC_SERNFC" ,(cAliasNew)->(DTC_SERNFC), Nil})

						EndIf
						
						While (cAliasNew)->(!Eof())
							aItem := { {"DTC_NUMNFC" ,(cAliasNew)->(DTC_NUMNFC), Nil},;
											{"DTC_SERNFC" ,(cAliasNew)->(DTC_SERNFC), Nil},;
											{"DTC_CODPRO" ,(cAliasNew)->(DTC_CODPRO), Nil},;
											{"DTC_CODEMB" ,(cAliasNew)->(DTC_CODEMB), Nil},;
											{"DTC_EMINFC" ,(cAliasNew)->(DTC_EMINFC), Nil},;
											{"DTC_QTDVOL" ,(cAliasNew)->(DTC_QTDVOL), Nil},;
											{"DTC_PESO"   ,(cAliasNew)->(DTC_PESO)  , Nil},;
											{"DTC_PESOM3" ,(cAliasNew)->(DTC_PESOM3), Nil},;
											{"DTC_VALOR"  ,(cAliasNew)->(DTC_VALOR) , Nil},;
											{"DTC_BASSEG" ,(cAliasNew)->(DTC_BASSEG), Nil},;
											{"DTC_QTDUNI" ,(cAliasNew)->(DTC_QTDUNI), Nil},;
											{"DTC_EDI"    ,(cAliasNew)->(DTC_EDI)   , Nil},;
											{"DTC_ESTORN" ,"1", Nil}}
											
							AAdd(aItemDTC,aClone(aItem))
							
							(cAliasNew)->(DbSkip())
						EndDo
						(cAliasNew)->(DbCloseArea())
						
						If Len(aCabDTC) > 0 .AND. Len(aItemDTC) > 0
							//
							// Parametros da TMSA050 (notas fiscais do cliente)
							// xAutoCab - Cabecalho da nota fiscal
							// xAutoItens - Itens da nota fiscal
							// xIten sPesM3 - acols de Peso Cubado
							// xItensEnder - ac ols de Enderecamento
							// nOpcAuto - Opcao rotina a utomatica
							
							MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,5)
							If lMsErroAuto
								MostraErro()
								lRet := .F.
							EndIf
						EndIf
						If lRet
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Exclusao do Lote	   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lMsErroAuto := .F.
							aCabDTP := {{"DTP_FILORI" ,DTP->DTP_FILORI, Nil},;
											{"DTP_LOTNFC" ,DTP->DTP_LOTNFC, Nil}}
							
							MSExecAuto({|u,v| TMSA170(u,v)},aCabDTP,5)
							If lMsErroAuto
								MostraErro()
								lRet := .F.
							EndIf
						EndIf
						If lRet
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Exclusao da Viagem  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TmsA144Mnt( "DTQ", DTQ->(Recno()), 5, .F. )
						EndIf
					EndIF
					If !lRet
						DisarmTransaction()
					EndIf
				End TransAction
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet
	MsgAlert(STR0087+Iif(nEstorno == 1,STR0088,STR0089)+STR0090)//"Estorno "###"Total"###"Parcial"###" da Viagem realizado com sucesso!"
EndIf

RestArea( aARea )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tmsa144RdpºAutor  ³Andre Godoi         º Data ³  20/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista os Doc. relacionados a Redespachante, gatilhando os  º±±
±±º          ³selecionados na viagem do tipo Redespacho.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tmsa144Mnt                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa144Rdp()
Local oDlgRed, oLbx1, oLbx2
Local aTitCab   := {}
Local aTitIte   := {}
Local aRedesp   := {}
Local aDoctos   := {}
Local aDoc      := {}
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local lFindDoc  := .T.
Local nOpcA     := 0
Local aArea     := GetArea()
Local bClick    := { || Iif(A144VldCk(aRedesp,aRedesp[oLbx1:nAT,1],aRedesp[oLbx1:nAT,2],aRedesp[oLbx1:nAT,3],aRedesp[oLbx1:nAT,8]), aRedesp[oLbx1:nAT,7,oLbx2:nAT,1]:= !aRedesp[oLbx1:nAT,7,oLbx2:nAT,1],.F.), oLbx2:Refresh() }  // Iif(Len(aCompViag)>0,aRedesp[oLbx1:nAT,7,oLbx2:nAT,1]:= !aRedesp[oLbx1:nAT,7,oLbx2:nAT,1],.F.), oLbx2:Refresh() }
Local nA        := 0
Local lNewLine  := .T.
Local nB        := 0
Local lDoc      :=.T.
Local lLocaliz  := SuperGetMv("MV_LOCALIZ",.F.,"") == 'S'
Local nOld      := n
Local oAllMark
Local nX        := 0
Local nY        := 0
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local aColsDJN  := {}
Local cSeekRed  := ""
Local nIndRed   := 1
Local cRedespAnt:= ""
Local lRetInd   := FindFunction("TMSRetInd")

Private lAllMark := .T.   // Usado para o controle da repeticao do campo memo DUA_MOTIVO. NAO TROQUE PARA LOCAL!!!

If	oMarked == Nil
	oMarked := LoadBitmap( GetResources(),'LBOK')
EndIf
If	oNoMarked == Nil
	oNoMarked := LoadBitmap( GetResources(),'LBNO' )
EndIf

//-- Define os titulos do cabecalho.
AAdd( aTitCab, RetTitle( "DFT_NUMRED" ) )
AAdd( aTitCab, RetTitle( "DFT_CODFOR" ) )
AAdd( aTitCab, RetTitle( "DFT_LOJFOR" ) )
AAdd( aTitCab, RetTitle( "DFT_NOMFOR" ) )
AAdd( aTitCab, RetTitle( "DFT_NMREDU" ) )
AAdd( aTitCab, RetTitle( "DFT_QTDDOC" ) )

//-- Define os titulos dos itens.
AAdd( aTitIte, RetTitle( "DFV_NUMRED" ) )
AAdd( aTitIte, RetTitle( "DFV_ITEM"   ) )
AAdd( aTitIte, RetTitle( "DFV_STATUS" ) )
AAdd( aTitIte, RetTitle( "DFV_FILDOC" ) )
AAdd( aTitIte, RetTitle( "DFV_DOC"    ) )
AAdd( aTitIte, RetTitle( "DFV_SERIE"  ) )

If lCmpDFV
	cQuery := "SELECT DISTINCT DFV_FILORI, DFV_NUMRED "
Else
	cQuery := "SELECT DISTINCT DFV_NUMRED "
EndIf	
cQuery += "FROM " + RetSqlName("DFV") + " DFV, " + RetSqlName("DUD") + " DUD "
cQuery += " WHERE DFV.DFV_FILIAL = '" + xFilial("DFV") + "' AND "
cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
cQuery += " DUD.DUD_FILDOC = DFV.DFV_FILDOC AND "
cQuery += " DUD.DUD_DOC    = DFV.DFV_DOC   AND "
cQuery += " DUD.DUD_SERIE  = DFV.DFV_SERIE AND "
cQuery += " DUD.DUD_FILORI ='" + cFilAnt + "' AND "
cQuery += " DUD.DUD_VIAGEM = ' ' AND "
cQuery += " DFV.DFV_STATUS = '1' AND "
cQuery += " DUD.D_E_L_E_T_ = ' ' AND "
cQuery += " DFV.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery ( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F. )
While (cAlias)->(!Eof())
	If lRetInd
		cSeekRed:= TMSRetInd('DFT',(cAlias)->DFV_NUMRED,Iif(lCmpDFV,(cAlias)->DFV_FILORI,''),@nIndRed)
	Else
		cSeekRed:= (cAlias)->DFV_NUMRED
	EndIf	
			
	DFT->(DbSetOrder(nIndRed))			
	If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
		AAdd( aRedesp, {	DFT->DFT_NUMRED,;
							DFT->DFT_CODFOR,;
							DFT->DFT_LOJFOR,;
							Posicione("SA2", 1, xFilial("SA2") + DFT->( DFT_CODFOR + DFT_LOJFOR ), "A2_NOME" ),;
							Posicione("SA2", 1, xFilial("SA2") + DFT->( DFT_CODFOR + DFT_LOJFOR ), "A2_NREDUZ" ),;
							DFT->DFT_QTDDOC,;
							{} ,;
							Iif(lCmpDFV,DFT->DFT_FILORI,''),;
							Posicione("SA2", 1, xFilial("SA2") + DFT->( DFT_CODFOR + DFT_LOJFOR ), "A2_PAGGFE" ),;
							Iif(lCmpDFV,DFT->DFT_CDTPOP,''),;
							Iif(lCmpDFV,DFT->DFT_CDCLFR,''),;
							Iif(lCmpDFV,DFT->DFT_UFORI,''),;
							Iif(lCmpDFV,DFT->DFT_CDMUNO,''),;
							Iif(lCmpDFV,DFT->DFT_CEPORI,''),;
							Iif(lCmpDFV,DFT->DFT_UFDES,''),;
							Iif(lCmpDFV,DFT->DFT_CDMUND,''),;
							Iif(lCmpDFV,DFT->DFT_CEPDES,''),;
							Iif(lCmpDFV,DFT->DFT_TIPVEI,'')	 })
							
	EndIf
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

If Empty( aRedesp )
	Help(' ', 1, 'TMSA14421')	//-- "Não existem documentos em aberto no poder de Redespachantes."
	lFindDoc := .F.
EndIf

If lFindDoc

	ASort( aRedesp,,,{|x,y| x[1] < y[1] } )
	
		DEFINE MSDIALOG oDlgRed FROM 120,072 TO 660,1044 TITLE STR0097 OF oMainWnd PIXEL

		@ 015, 010 SAY STR0098 SIZE 50,7 OF oDlgRed PIXEL

		@ 240,010 CHECKBOX oAllMark VAR lAllMark PROMPT STR0102 SIZE 168, 08;
		ON CLICK(Tmsa144Mak(oLbx1,oLbx2,@aRedesp)) OF oDlgRed PIXEL

		@ 035, 010 LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER;
		aTitCab[1],;
		aTitCab[2],;
		aTitCab[3],;
		aTitCab[4],;
		aTitCab[5],;
		aTitCab[6],;
		SIZE 467,095 OF oDlgRed PIXEL

		oLbx1:SetArray( aRedesp )

		oLbx1:bChange  := { || aDoctos := {}, GatDocto(	aRedesp[oLbx1:nAT,1],;
																		 	aRedesp[oLbx1:nAT,2],;
																		 	aRedesp[oLbx1:nAT,3],;
																		 	@aDoctos,;
																		 	oLbx2,;
																		 	oNoMarked,;
																		 	oMarked,;
																		 	@aRedesp,;
																		 	oLbx1:nAT,;
																		 	aRedesp[oLbx1:nAT,8] ,;
																		 	aRedesp[oLbx1:nAT,9] ) }  

		oLbx1:bLine	   := { || {	aRedesp[oLbx1:nAT,1],;
											aRedesp[oLbx1:nAT,2],;
											aRedesp[oLbx1:nAT,3],;
											aRedesp[oLbx1:nAT,4],;
											aRedesp[oLbx1:nAT,5],;
											aRedesp[oLbx1:nAT,6] } }

		@ 135, 010 SAY STR0099 SIZE 120,7 OF oDlgRed PIXEL
		@ 145, 010 LISTBOX oLbx2 VAR cLbx2 FIELDS HEADER;
		"",;
		aTitIte[1],;
		aTitIte[2],;
		aTitIte[3],;
		aTitIte[4],;
		aTitIte[5],;
		aTitIte[6],;
		SIZE 467,095 OF oDlgRed ON DBLCLICK ( Eval( bClick ) ) PIXEL

		oLbx2:SetArray( aDoctos )
		
		oLbx2:bLine	:= { || { Iif(	aRedesp[oLbx2:nAT,7,oLbx2:nAT,1] , oMarked, oNoMarked ),;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,2],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,3],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,4],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,5],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,6],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,7] } } 											

	ACTIVATE MSDIALOG oDlgRed ON INIT EnchoiceBar(oDlgRed, {|| nOpcA := 1, oDlgRed:End() } , {|| oDlgRed:End()})
EndIf

For nX:=1 To Len(aRedesp)
	For nY:=1 To Len(aRedesp[nX][7]) 
		If aRedesp[nX][7][nY][1]
			AAdd( aDoc, { aRedesp[nX][7][nY][5],;  // Filial Docto 
							aRedesp[nX][7][nY][6],;  // Docto
							aRedesp[nX][7][nY][7] })  // Serie
		EndIf
	Next nY
Next nX

If nOpcA == 1

	DUD->(DbSetOrder( 1 ) )
	DT6->(DbSetOrder( 1 ) )

	For nA := 1 To Len( aDoc )

			cFilDoc  := aDoc[ nA, 1]
			cDoc     := aDoc[ nA, 2]
			cSerie   := aDoc[ nA, 3]

			//-- Verifica se o registro a ser incluido ja esta na aCols da viagem em questao.
			For nB:=1 to Len( aCols )
				If !GDDeleted(nB)
					cRegVia := GdFieldGet('DTA_FILDOC', nB) + GdFieldGet('DTA_DOC', nB) + GdFieldGet('DTA_SERIE', nB)
					cRegRed := cFilDoc + cDoc + cSerie

					If cRegVia == cRegRed
						Aviso(STR0096 , STR0033 + cFilDoc + STR0028 + cDoc + STR0034 + cSerie + STR0150 ,{"OK"})  //Está contido nesta viagem
						lDoc := .F.
						Exit
					EndIf

					If !TmsA144DA7(cFilDoc,cDoc,cSerie)
						lDoc := .F.
					EndIf
				EndIf
			Next nB

			If lDoc

				//-- Cria uma linha nova
				lNewLine := (	!Empty( GdFieldGet( 'DTA_FILDOC', n ) ) .And.;
								!Empty( GdFieldGet( 'DTA_DOC'   , n ) ) .And.;
								!Empty( GdFieldGet( 'DTA_SERIE' , n ) ) .Or.;
								 GDDeleted(n)) .Or.;
							(	 Empty( GdFieldGet( 'DTA_FILDOC', n ) ) .And.;
								 Empty( GdFieldGet( 'DTA_DOC'   , n ) ) .And.;
								 Empty( GdFieldGet( 'DTA_SERIE' , n ) ) .And.;
								 GDDeleted(n))

			EndIf
			
			If lDoc
				cSeekDud := xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt
				If DUD->( MsSeek( cSeekDud ) )

					//-- Posiciona em um DUD <> de cancelado.
					While DUD->(!Eof()) .And. DUD->( DUD_FILIAL + DUD_FILDOC + DUD_DOC + DUD_SERIE + DUD_FILORI )  == cSeekDud
						If DUD->DUD_STATUS == StrZero(1, Len(DUD->DUD_STATUS))
							Exit
						EndIf
						DUD->(dBSkip())
					EndDo
					
					If lTmsRdpU .And. lNewLine .And. DUD->DUD_NUMRED <> cRedespAnt
						If lRetInd
							cSeekRed:= TMSRetInd('DFT',DUD->DUD_NUMRED,DUD->DUD_FILORI,@nIndRed)
						Else
							nIndRed := 1
							cSeekRed:= DUD->DUD_NUMRED
						EndIf	
						DFT->(DbSetOrder(nIndRed))			
						If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
							cRedespAnt:= DUD->DUD_NUMRED
							//--- Verifica se o redespacho selecionado possui as mesmas caracteristicas do primeiro.
							If M->DTQ_CDTPOP <> DFT->DFT_CDTPOP .Or. ; 
								M->DTQ_CDCLFR <> DFT->DFT_CDCLFR .Or. ;
								M->DTQ_UFORI  <> DFT->DFT_UFORI .Or. ;
								M->DTQ_CDMUNO <> DFT->DFT_CDMUNO .Or. ;
								M->DTQ_CEPORI <> DFT->DFT_CEPORI .Or. ;
								M->DTQ_UFDES  <> DFT->DFT_UFDES .Or. ;
								M->DTQ_CDMUND <> DFT->DFT_CDMUND .Or. ;
								M->DTQ_CEPDES <> DFT->DFT_CEPDES .Or. ;
								M->DTQ_TIPVEI <> DFT->DFT_TIPVEI
						 			MsgAlert(STR0151)  //"Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico."  
						 			lDoc:= .F.
						 			Exit
							EndIf	
						EndIf	
					EndIf
					
					If lDoc
						If lNewLine
							AAdd( aCols, Array( Len( aHeader ) + 1 ) )
							AFill( aCols[Len(aCols)], '' )
							aCols[ Len(aCols), Len( aHeader ) + 1 ] := .F.
						EndIf
	
						If DT6->( MsSeek( xFilial('DT6') + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )
							GdFieldPut( 'DUD_SEQUEN', StrZero(Len( aCols ),Len(DUD->DUD_SEQUEN)) , Len( aCols ) )
							GdFieldPut( 'DUD_STATUS', DUD->DUD_STATUS, Len( aCols ) )
							GdFieldPut( 'DTA_FILDOC', DUD->DUD_FILDOC, Len( aCols ) )
							GdFieldPut( 'DTA_DOC'   , DUD->DUD_DOC   , Len( aCols ) )
							GdFieldPut( 'DTA_SERIE' , DUD->DUD_SERIE , Len( aCols ) )
							GdFieldPut( 'DUD_STROTA', DUD->DUD_STROTA, Len( aCols ) )
							GdFieldPut( 'DT5_DATENT', DT6->DT6_PRZENT, Len( aCols ) )
							GdFieldPut( 'DTA_QTDVOL', DT6->DT6_QTDVOL, Len( aCols ) )
							GdFieldPut( 'DT6_VOLORI', DT6->DT6_VOLORI, Len( aCols ) )
							GdFieldPut( 'DT6_PESO'  , DT6->DT6_PESO  , Len( aCols ) )
							GdFieldPut( 'DT6_PESOM3', DT6->DT6_PESOM3, Len( aCols ) )
							GdFieldPut( 'DT6_VALMER', DT6->DT6_VALMER, Len( aCols ) )
							GdFieldPut( 'DT6_NOMREM',Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ'),Len( aCols ))
							GdFieldPut( 'DT6_NOMDES',Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ'),Len( aCols ))
							GdFieldPut( 'DUE_BAIRRO',SA1->A1_BAIRRO	, Len( aCols )	)
							GdFieldPut( 'DUE_MUN'   ,SA1->A1_MUN   	, Len( aCols )	)
							GdFieldPut( 'DUE_EST'   ,SA1->A1_EST   	, Len( aCols )	)
		
							//--- Preenche campos para integracao GFE
							If lTmsRdpU .And. nA == 1    //Somente a primeira vez
								If lRetInd
									cSeekRed:= TMSRetInd('DFT',DUD->DUD_NUMRED,DUD->DUD_FILORI,@nIndRed)
								Else
									nIndRed := 1
									cSeekRed:= DUD->DUD_NUMRED
								EndIf	
								DFT->(DbSetOrder(nIndRed))			
								If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
									
									M->DTQ_TIPVEI:= DFT->DFT_TIPVEI
									M->DTQ_DESTPV:= Posicione("DUT",1,xFilial("DUT")+DFT->DFT_TIPVEI,'DUT_DESCRI ')
									M->DTQ_CDTPOP:= DFT->DFT_CDTPOP
									M->DTQ_DSTPOP:= Posicione("GV4",1,xFilial("GV4")+DFT->DFT_CDTPOP,"GV4_DSTPOP")
									M->DTQ_CDCLFR:= DFT->DFT_CDCLFR
									M->DTQ_DSCLFR:= Posicione("GUB",1,xFilial("GUB")+DFT->DFT_CDCLFR,"GUB_DSCLFR")
									M->DTQ_UFORI := DFT->DFT_UFORI
									M->DTQ_CDMUNO:= DFT->DFT_CDMUNO
									M->DTQ_MUNORI:= Posicione("CC2",1,xFilial("CC2")+DFT->(DFT_UFORI+DFT_CDMUNO),"CC2_MUN")
									M->DTQ_CEPORI:= DFT->DFT_CEPORI
									M->DTQ_UFDES := DFT->DFT_UFDES
									M->DTQ_CDMUND:= DFT->DFT_CDMUND
									M->DTQ_MUNDES:= Posicione("CC2",1,xFilial("CC2")+DFT->(DFT_UFDES+DFT_CDMUND),"CC2_MUN")
									M->DTQ_CEPDES:= DFT->DFT_CEPDES
	
								EndIf	
							EndIf
							DFV->( DbSetOrder ( 2 ) )
							If DFV->( DbSeek( xFilial('DFV') + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE )  ) )
							 	//--- Carrega Dados do Redespacho Adicional (DJO para DJN)
								If Len(aHeaderDJN) > 0
									aColsDJN := aClone(T144CarDJN(aHeaderDJN,@aRedVge,.T.))
								EndIf
							EndIf
									
							//-- Parametro MV_LOCALIZ ligado, carrega o Armazem e Endereco.
							If lLocaliz
								If lNewLine
									n:= Len(acols)
								EndIf
								M->DTA_FILDOC := DUD->DUD_FILDOC
								TmsA210Val( "M->DTA_FILDOC" )
							EndIf
	
						EndIf
					EndIf
				EndIf	
			EndIf
			lDoc :=.T.
	Next nA
	oGetD:oBrowse:nAt := nOld
	oGetD:oBrowse:Refresh()
EndIf

RestArea( aArea )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GatDocto ºAutor  ³ Andre Godoi        º Data ³  20/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GatDocto( cNumRed, cCodFor, cLojFor, aDoctos, oLbx2, oNoMarked, oMarked, aRedesp, nX, cFilOri )
Local cAlias := GetNextAlias()
Local lRetGDoc := .T.
Local lCmpDFV  := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0

Default cFilOri:= ""

cQuery := "SELECT DFV.DFV_NUMRED, DFV.DFV_ITEM, DFV.DFV_STATUS, DFV.DFV_FILDOC, DFV.DFV_DOC, DFV.DFV_SERIE "
If lCmpDFV
	cQuery += ", DFV.DFV_FILORI, DFV.DFV_CDTPOP, DFV.DFV_CDCLFR, DFV.DFV_UFORI, DFV.DFV_CDMUNO, DFV.DFV_CEPORI, DFV.DFV_UFDES, DFV.DFV_CDMUND, DFV.DFV_CEPDES  "
EndIf
cQuery += " FROM " + RetSqlName( "DFV" ) + " DFV," + RetSqlName( "DUD" ) + " DUD "
cQuery += " WHERE DFV.DFV_FILIAL = '" + xFilial("DFV") + "' AND"
cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
cQuery += " DUD.DUD_FILDOC = DFV.DFV_FILDOC AND "
cQuery += " DUD.DUD_DOC    = DFV.DFV_DOC    AND "
cQuery += " DUD.DUD_SERIE  = DFV.DFV_SERIE  AND "
cQuery += " DUD.DUD_STATUS = '" + StrZero(1, Len(DUD->DUD_STATUS)) + "' AND "
If lCmpDFV
	cQuery += " DFV.DFV_FILORI = '" + cFilOri + "' AND "
EndIf
cQuery += " DFV.DFV_NUMRED = '" + cNumRed + "' AND "
cQuery += " DFV.DFV_CODFOR = '" + cCodFor + "' AND "
cQuery += " DFV.DFV_LOJFOR = '" + cLojFor + "' AND "
cQuery += " DFV.DFV_STATUS = '" + StrZero(1, Len(DFV->DFV_STATUS)) + "' AND "
cQuery += " DUD.DUD_VIAGEM = ' ' AND "
cQuery += " DUD.D_E_L_E_T_ = ' ' AND "
cQuery += " DFV.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery ( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F. )
While (cAlias)->(!Eof())
   lRetGDoc := .T.   
   If lTM144DOCR 
	  lRetGDoc:= ExecBlock('TM144DOCR',.F.,.F.,{(cAlias)->DFV_NUMRED, (cAlias)->DFV_FILDOC, (cAlias)->DFV_DOC, (cAlias)->DFV_SERIE }) 
	  
	  If ValType(lRetGDoc) <> "L"
	      lRetGDoc := .T.
      EndIf         							
   EndIf
   
   If lRetGDoc	
	   AAdd( aDoctos, {	.F.,;
						(cAlias)->DFV_NUMRED,;
						(cAlias)->DFV_ITEM,;
						'1',;					//-- Status do documento em aberto.
						(cAlias)->DFV_FILDOC,;
						(cAlias)->DFV_DOC,;
						(cAlias)->DFV_SERIE,;
						Iif(lTmsRdpU,(cAlias)->DFV_CDTPOP ,''),;						
						Iif(lTmsRdpU,(cAlias)->DFV_CDCLFR ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_UFORI  ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CDMUNO ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CEPORI ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_UFDES  ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CDMUND ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CEPDES ,'') })
						
	EndIf						
	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

oLbx2:SetArray(aDoctos)

If Empty(aRedesp[nX,7])
	aRedesp[nX,7] := aDoctos
EndIf

If !Empty( aDoctos )
   oLbx2:bLine	:= { || {	Iif(	aRedesp[nX,7,oLbx2:nAT,1] , oMarked, oNoMarked ),;
								aRedesp[nX,7,oLbx2:nAT,2],;
								aRedesp[nX,7,oLbx2:nAT,3],;
								aRedesp[nX,7,oLbx2:nAT,4],;
								aRedesp[nX,7,oLbx2:nAT,5],;
								aRedesp[nX,7,oLbx2:nAT,6],;
								aRedesp[nX,7,oLbx2:nAT,7] } }
   Else
   oLbx2:bLine	:= { || {	Iif(.F., oNoMarked, oNoMarked ),;
								"",;
								"",;
								"",;
								"",;
								"",;
								"" } } 
EndIf
oLbx2:Refresh()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TmsA144Mak³ Autor ³Andre Godoi            ³ Data ³29/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Mak                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa144Mak(oLbx1, oLbx2, aRedesp)
Local nX  := 1
Local lRet:= .T.

lRet:= A144VldCk(aRedesp,aRedesp[oLbx1:nAt][1],aRedesp[oLbx1:nAt][2],aRedesp[oLbx1:nAt][3],aRedesp[oLbx1:nAt][8])
If lRet
	
	For nX := 1 To Len(aRedesp[oLbx1:nAt][7])
		aRedesp[oLbx1:nAt][7][nX][1] := !aRedesp[oLbx1:nAt][7][nX][1]
	Next nX
	
	oLbx2:Refresh()
EndIf	

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SX1TMBVLD  ³ Autor ³ Guilherme R. Gaiofatto³ Data ³04/02/13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação de pergunte TMB144                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SX1TMBVLD()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SX1TMBVLD(cSeradi)
Local lRet  := .T.
Default cSeradi := ''

M->DTQ_SERADI := cSeradi

lRet := TmsValField("M->DTQ_SERADI")

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TA144QtdCG ³ Autor ³ Leandro Paulino     ³ Data ³ 04/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Quant.de Carregamentos Graficos  por Unitizador    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA144QtdCG()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA144QtdCG(cFilOri, cViagem, cCodVei)
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local nQtdCG    := ''

Default cFilOri := ''
Default cViagem := ''
Default cCodVei := ''

cQuery := " SELECT COUNT(DDK_FILIAL) DDKQTD, DDK_CODVEI "
cQuery += "   FROM " + RetSqlName("DDK")
cQuery += "   WHERE DDK_FILIAL = '" + xFilial("DDK") + "' "
cQuery += "     AND DDK_FILORI = '" + cFilOri        + "' "
cQuery += "     AND DDK_VIAGEM = '" + cViagem        + "' "
cQuery += "     AND D_E_L_E_T_ = ' ' "
cQuery += "     GROUP BY DDK_CODVEI "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )
nQtdCG := (cAliasQry)->DDKQTD
If nQtdCG == 1
	cCodVei:= (cAliasQry)->DDK_CODVEI
EndIf
(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return nQtdCG

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tm144MntDc ³ Autor ³ Rafael Souza        ³ Data ³07/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o Browse do manutencao de Doctos (TMSA500)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm144MntDc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Tm144MntDc()

Local aArea     := GetArea()
Local cOldFName := FunName()

SetFunName("TMSA500")

TmsA500()

SetFunName(cOldFName)
RestArea( aArea )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144Col³ Autor ³ Valdemar Roberto      ³ Data ³15.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche aCols                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Col()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA144Col(aUsHDocto,nOpcx)
Local lExistDUH := .F.
Local lTM144CLN := ExistBlock( 'TM144CLN' ) //-- Permite ao usuario, incluir colunas nos itens.
Local cSeekDUH  := ''
Local nSeek     := 0
Local nCntFor   := 0
Local nCnt      := 0
Local nQtdVol   := 0
Local nVolOri   := 0
Local nPeso     := 0
Local nPesM3    := 0
Local nValMer   := 0
Local lTM144INC := ExistBlock("TM144INC")
Local lPainel   := IsInCallStack('TmsaF76')
Local aColsDJN  := {}
Local nPosDJN   := 0
Local lTMS3GFE  := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cSerTmsDoc:= ""
Local lDTAOrigem:= DTA->(ColumnPos('DTA_ORIGEM')) > 0

Default aUsHDocto	:= {}

//-- Posiciona no documento
DT6->(MsSeek(xFilial('DT6')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))

cSerTmsDoc := DUD->DUD_SERTMS

If Type("lColeta") == "U"
	lColeta := (cSerTmsDoc == StrZero(1,Len(DC5->DC5_SERTMS)))	
EndIf

If lLocaliz .And. !lColeta
	lExistDUH := .F.
	DTC->(MsSeek(cSeekDTC := xFilial('DTC')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
	While DTC->(!Eof() .And. DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE == cSeekDTC)

		//--Caso esteja sendo visualizado um documento em uma filial
		//--diferente da filial de origem do mesmo, considera a filial de origem
		//--para exibir o local/endereco utilizado no documento.
		cSeekDUH := xFilial('DUH')+DUD->DUD_FILDOC+DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO)
		bWhile	:= {|| DUH->(! Eof() .And. DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM+DUH_CODPRO == cSeekDUH) }

		DUH->(DbSetOrder(1)) //DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM+DUH_CODPRO+DUH_LOCAL+DUH_LOCALI
		If DUH->(MsSeek(cSeekDUH))

			AAdd(aCols,Array(Len(aHeader)+1))
			nCntFor := Len(aCols)

			Afill(aCols[nCntFor],'')
			aCols[nCntFor,Len(aHeader)+1] := .F.

			lExistDUH := .T.
			While Eval(bWhile)
				//-- Pesquisa mais de um endereco para o documento ou mais de uma nota para o documento
				nSeek := Ascan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DTA_LOCAL')] + x[GdFieldPos('DTA_LOCALI')] + x[GdFieldPos('DTA_UNITIZ')] + x[GdFieldPos('DTA_CODANA')] +  x[GdFieldPos('DTA_FILDOC')] + ;
							x[GdFieldPos('DTA_DOC')] + x[GdFieldPos('DTA_SERIE')] == DUH->DUH_LOCAL+DUH->DUH_LOCALI+DTC->(DTC_FILDOC+DTC_DOC+DTC_SERIE) })
				If nSeek > 0
					GdFieldPut('DTA_QTDVOL',aCols[nSeek][GdFieldPos('DTA_QTDVOL')]+DUH->DUH_QTDVOL,nSeek)
					GdFieldPut('DT6_VOLORI',DT6->DT6_VOLORI,nSeek)
					aDel(aCols,nCntFor)
					aSize(aCols,Len(aCols)-1)
					DUH->(dbSkip())
					Loop
				EndIf
				GdFieldPut('DUD_STATUS',DUD->DUD_STATUS,nCntFor)
				GdFieldPut('DT5_DATENT',DT6->DT6_PRZENT,nCntFor)
				If cSerTmsDoc == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
					GdFieldPut('DUD_STROTA',DUD->DUD_STROTA,nCntFor)
				Else
					If nOpcx == 4 .And. Empty(DUD->DUD_SEQUEN) .And. lPainel
						GdFieldPut('DUD_SEQUEN',(StrZero(nCntFor,Len(DUD->DUD_SEQUEN))),nCntFor)
					Else
						GdFieldPut('DUD_SEQUEN',DUD->DUD_SEQUEN,nCntFor)
					EndIf
				EndIf
				A210Trigger(.T.,nCntFor)
				DUH->(dbSkip())
			EndDo
		EndIf
		DTC->(dbSkip())
	EndDo
EndIf

If !lLocaliz .Or. !lExistDUH

	//-- Posiciona no CTRC
	DT6->(DbSetOrder(1))
	DT6->(MsSeek(xFilial('DT6')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))

	AAdd(aCols,Array(Len(aHeader)+1))
	nCntFor := Len(aCols)

	Afill(aCols[nCntFor],'')
	aCols[nCntFor,Len(aHeader)+1] := .F.

	GdFieldPut('DUD_STATUS',DUD->DUD_STATUS,nCntFor)
	GdFieldPut('DTA_FILDOC',DUD->DUD_FILDOC,nCntFor)
	GdFieldPut('DTA_DOC'   ,DUD->DUD_DOC   ,nCntFor)
	GdFieldPut('DTA_SERIE' ,DUD->DUD_SERIE ,nCntFor)
	If cSerTmsDoc == StrZero(1,Len(DC5->DC5_SERTMS)) //-- Coleta 
		//-- Posiciona na ordem de coleta
		DT5->(MsSeek(xFilial('DT5')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
		If !lPainel 
			If nOpcx == 3
				M->DTQ_ROTA  := DT5->DT5_ROTPRE
			EndIf
			M->DTQ_DESROT:= Posicione("DA8",1,xFilial("DA8")+M->DTQ_ROTA,"DA8_DESC")
		EndIf
		//-- Posiciona no solicitante
		DUE->(MsSeek(xFilial('DUE')+DT5->DT5_CODSOL))
		//-- Obtem o endereco da coleta
		If Empty(DT5->DT5_SEQEND)
			cBaiCol := DUE->DUE_BAIRRO
			cMunCol := DUE->DUE_MUN
			cEstCol := DUE->DUE_EST
		Else
			DUL->(DbSetOrder(3))
			DUL->(MsSeek(xFilial('DUL')+DT5->(DT5_CODSOL+DT5_SEQEND)))
			cBaiCol := DUL->DUL_BAIRRO
			cMunCol := DUL->DUL_MUN
			cEstCol := DUL->DUL_EST
		EndIf
		If lTmsCFec .And. lColeta
			DF1->(DbSetOrder(3))
			DF1->(MsSeek(xFilial('DF1')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
			GdFieldPut('DF1_NUMAGE',DF1->DF1_NUMAGE,nCntFor)
			GdFieldPut('DF1_ITEAGE',DF1->DF1_ITEAGE,nCntFor)
		EndIf
		If nOpcx == 4 .And. Empty(DUD->DUD_SEQUEN) .And. lPainel
			GdFieldPut('DUD_SEQUEN',(StrZero(nCntFor,Len(DUD->DUD_SEQUEN))),nCntFor)
		Else
			GdFieldPut('DUD_SEQUEN',DUD->DUD_SEQUEN,nCntFor)
		EndIf	

		If cSerTMS == StrZero(1,Len(DC5->DC5_SERTMS)) // Viagem de Coleta
			GdFieldPut('DUE_NOME'  ,DUE->DUE_NOME  ,nCntFor) //-- Solicitante
			
		ElseIf cSerTMS == StrZero(3,Len(DC5->DC5_SERTMS))  // Viagem de Entrega
			If !Empty(DT6->DT6_CLIREM) .And. !Empty(DT6->DT6_LOJREM)
				GdFieldPut('DT6_NOMREM',Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ'),nCntFor)
			Else
				GdFieldPut('DT6_NOMREM',DUE->DUE_NOME  ,nCntFor) //-- Solicitante
			EndIf	

			If !Empty(DT6->DT6_CLIDES) .And. !Empty(DT6->DT6_LOJDES)	
				GdFieldPut('DT6_NOMDES',Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ'),nCntFor)
			EndIf	

		EndIf		
		
		GdFieldPut('DUE_BAIRRO',cBaiCol        ,nCntFor) //-- Bairro
		GdFieldPut('DUE_MUN'   ,cMunCol        ,nCntFor) //-- Municipio
		GdFieldPut('DUE_EST'   ,cEstCol        ,nCntFor) //-- Estado
		GdFieldPut('DT5_DATPRV',DT5->DT5_DATPRV,nCntFor) //-- Data Pre.Col
		GdFieldPut('DT5_HORPRV',DT5->DT5_HORPRV,nCntFor) //-- Hora Pre.Col
		
	ElseIf cSerTmsDoc == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
		GdFieldPut('DUD_STROTA',DUD->DUD_STROTA,nCntFor)
		GdFieldPut('DT5_DATENT',DT6->DT6_PRZENT,nCntFor)

	ElseIf cSerTmsDoc == StrZero(3,Len(DC5->DC5_SERTMS)) //-- Entrega
		If nOpcx == 4 .And. Empty(DUD->DUD_SEQUEN) .And. lPainel
			GdFieldPut('DUD_SEQUEN',(StrZero(nCntFor,Len(DUD->DUD_SEQUEN))),nCntFor)
		Else	
			GdFieldPut('DUD_SEQUEN',DUD->DUD_SEQUEN,nCntFor)
		EndIf	
		GdFieldPut('DT6_NOMREM',Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ'),nCntFor)
		GdFieldPut('DT6_NOMDES',Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ'),nCntFor)
		GdFieldPut('DUE_BAIRRO',SA1->A1_BAIRRO,nCntFor)
		GdFieldPut('DUE_MUN'   ,SA1->A1_MUN   ,nCntFor)
		GdFieldPut('DUE_EST'   ,SA1->A1_EST   ,nCntFor)
		GdFieldPut('DT5_DATENT',DT6->DT6_PRZENT,nCntFor)
		
	EndIf
	If GdFieldPos("DTA_ORIGEM") > 0 .And. lDTAOrigem
		If nOpcx == 4 .And. GdFieldGet("DUD_STATUS",nCntFor) == "1" // Em aberto
			GdFieldPut('DTA_ORIGEM', StrZero(1,Len(DTA->DTA_ORIGEM)), nCntFor)
		Else
			GdFieldPut('DTA_ORIGEM', Posicione("DTA",1, xFilial("DTA") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE ) + DUD->(DUD_FILORI+DUD_VIAGEM) , 'DTA_ORIGEM' ) , nCntFor)
		EndIf
	EndIf

	nQtdVol   := GdFieldGet('DTA_QTDVOL',nCntFor);iIf(Valtype(nQtdVol)!='N',nQtdVol:=0,)
	nVolOri   := GdFieldGet('DT6_VOLORI',nCntFor);iIf(Valtype(nVolOri)!='N',nVolOri:=0,)
	nPeso     := GdFieldGet('DT6_PESO'  ,nCntFor);iIf(Valtype(nPeso  )!='N',nPeso  :=0,)
	nPesM3    := GdFieldGet('DT6_PESOM3',nCntFor);iIf(Valtype(nPesM3 )!='N',nPesM3 :=0,)
	nValMer   := GdFieldGet('DT6_VALMER',nCntFor);iIf(Valtype(nValMer)!='N',nValMer:=0,)

	GdFieldPut('DTA_QTDVOL',DT6->DT6_QTDVOL + nQtdVol,nCntFor)
	GdFieldPut('DT6_VOLORI',DT6->DT6_VOLORI + nVolOri,nCntFor)
	GdFieldPut('DT6_PESO'  ,DT6->DT6_PESO   + nPeso  ,nCntFor)
	GdFieldPut('DT6_PESOM3',DT6->DT6_PESOM3 + nPesM3 ,nCntFor)
	GdFieldPut('DT6_VALMER',DT6->DT6_VALMER + nValMer,nCntFor)

EndIf

//--- Dados Integração TMS x GFE 
If lTMS3GFE   .Or. lTmsRdpU
		GdFieldPut('DUD_UFORI' , DUD->DUD_UFORI, nCntFor)
		GdFieldPut('DUD_CDMUNO', DUD->DUD_CDMUNO, nCntFor )
		GdFieldPut('DUD_MUNORI', Posicione("CC2",1,xFilial("CC2")+DUD->(DUD_UFORI+DUD_CDMUNO),"CC2_MUN"), nCntFor )      
		GdFieldPut('DUD_CEPORI', DUD->DUD_CEPORI, nCntFor )
		GdFieldPut('DUD_UFDES' , DUD->DUD_UFDES, nCntFor)
		GdFieldPut('DUD_CDMUND', DUD->DUD_CDMUND, nCntFor )
		GdFieldPut('DUD_MUNDES', Posicione("CC2",1,xFilial("CC2")+DUD->(DUD_UFDES+DUD_CDMUND),"CC2_MUN"), nCntFor )      
		GdFieldPut('DUD_CEPDES', DUD->DUD_CEPDES, nCntFor )
		GdFieldPut('DUD_TIPVEI', DUD->DUD_TIPVEI, nCntFor )
		GdFieldPut('DUD_DESTPV', Posicione("DUT",1,xFilial("DUT")+DUD->DUD_TIPVEI,'DUT_DESCRI '), nCntFor )
		GdFieldPut('DUD_CDTPOP', DUD->DUD_CDTPOP, nCntFor )
		GdFieldPut('DUD_DSTPOP', Posicione("GV4",1,xFilial("GV4")+DUD->DUD_CDTPOP,"GV4_DSTPOP"), nCntFor )                    
		GdFieldPut('DUD_CDCLFR', DUD->DUD_CDCLFR, nCntFor )
		GdFieldPut('DUD_DSCLFR', Posicione("GUB",1,xFilial("GUB")+DUD->DUD_CDCLFR,"GUB_DSCLFR"), nCntFor )
		GdFieldPut('DUD_CHVEXT', DUD->DUD_CHVEXT, nCntFor )
		GdFieldPut('DUD_REDESP', '<< Enter >>', nCntFor )
		
		//---- Carrega variavel aRedVge - Redespachos da viagem
		If nOpcx <> 3
			aColsDJN := {}
			aColsDJN := aClone(T144CarDJN(aHeaderDJN,@aRedVge,.F.))  
		EndIf
EndIf
If lTM144CLN .AND. nCntFor > 0
	For nCnt := 1 To Len(aUsHDocto)
		GdFieldPut( aUsHDocto[nCnt,1],&(aUsHDocto[nCnt,2]),nCntFor)
	Next nCnt
EndIf

//-- Ponto de entrada apos a insercao dos documentos na viagem
If lTM144INC
	ExecBlock("TM144INC",.F.,.F.,{lCont,cSerTmsDoc,nCntFor})
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA144RRE
Exibe Check List da Viagem - RRE

@author Katia
@since 16/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA144RRE()
Local aArea:= GetArea()
	        
DJ9->(dbSetOrder(1))
If DJ9->(MsSeek(xFilial("DJ9")+M->(DTQ_FILORI+DTQ_VIAGEM)))
	FWExecView (, "TMSA034" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , , )
Else
	Help('',1,'TMSA14436') //Não há Check List para esta Viagem.
EndIf	
	
RestArea(aArea)		
Return		
/*/-----------------------------------------------------------
{Protheus.doc} A144ExPgRt()
Executa as rotinas de Pagadores e Roteiro

Uso: TMSA144

@sample
//A144ExPgRt(nOpc)

@author Paulo Henrique Corrêa Cardoso.
@since 26/09/2016
@version 1.0
-----------------------------------------------------------/*/
	
Static Function A144ExPgRt(nOpc,aColsBkp,lRoteiro)
Local lRet       := .T.         // Recebe o Retorno Logico
Local nCntFor     := 0          // Recebe o Contador
Local aDelDocs    := {}         // Recebe os documentos deletados
Local aRetTel     := {}         // Recebe o retorno da tela de pagadores
Local aRetPag     := {}         // Recebe o retorno do processamento de pagadores
Local aTabRec     := {}         // Recebe as Tabelas e recnos dos registros
Local nCntPag     := 0          // Recebe o contador de de registros de renos e tabelas 
Local lDTCPag     := .F.        // Recebe se possui DTC
Local lDT5Pag     := .F.        // Recebe se possui DT5
Local cSrvAdc     := ""         // Recebe se tem serviço adicional
Local lEdit       := .F.        // Recebe se for Inclusão ou alteração
Local aTabRecBkp  := {}
Local lDifReg     := .F.
Local lFilial     := .T.
Local aAreaSM0    := {}
Local aAreaSA1    := {}

If Type("__aRecPag") == "U" 
	Private __aRecPag := {}
EndIf

Default nOpc := 3               // Recebe a opção
Default aColsBkp:= {}
Default lRoteiro := .T.

If nOpc == 3 .OR. nOpc == 4
	lEdit := .T.
Else
	lEdit := .F.
EndIf

	aTabRec:= TMSA144CHK(aClone(aCols),@aDelDocs)

// Adiciona os novos itens selecionados no Painel
If IsInCallStack("TMSAF76") .AND. cSerTms == "3"
	If Len(__aRecPag) > 0
	
		For nCntFor := 1 To Len(__aRecPag)
			
			If aScan( aTabRec, { |x|  x[1] == __aRecPag[nCntFor][1] .AND.  x[2] == __aRecPag[nCntFor][2]  } ) <= 0
				AADD(aTabRec,{__aRecPag[nCntFor][1],__aRecPag[nCntFor][2]})
			EndIf
		Next nCntFor
	EndIf
EndIf

//----- Verifica se houve alteracoes de documento na viagem aColsBkp x aCols 
aTabRecBkp:= TMSA144CHK(aClone(aColsBkp),@aDelDocs)   

If (Len(aTabRec) > Len(aTabRecBkp)) .Or. !lEdit
	lDifReg:= .T.
ElseIf !Empty(aTabRecBkp)	
	For nCntFor := 1 To Len(aTabRec)
		If aScan( aTabRecBkp, { |x|  x[1] == aTabRec[nCntFor][1] .AND.  x[2] == aTabRec[nCntFor][2]  } ) <= 0
			lDifReg:= .T.
		EndIf
	Next nCntFor
EndIf	
//-------

If (Len(aTabRec) > 0  .And. lDifReg)
	
	// Verifica serviço adicional
	For nCntPag :=1  To Len(aTabRec)
		If aTabRec[nCntPag][1] == "DTC"
			lDTCPag := .T.
		ElseIf aTabRec[nCntPag][1] == "DT5"
			lDT5Pag := .T.
		EndIf
	Next nCntPag
		
	
	// Possui Serviço adicional
	If lDTCPag .AND. lDT5Pag
		cSrvAdc := "1"
	EndIf	
		
	// Carrega aCols dos pagadores de frete
	aRetPag := TMSF79Cols(aTabRec,cSerTMS,cTipTra,"2",cSrvAdc,M->DTQ_FILORI,M->DTQ_VIAGEM,nOpc)
				
	// Chama a Função de Tela de Pagadores
	aRetTel := TMSF79Tela(Aclone(aRetPag[1]),Aclone(aRetPag[2]),lEdit,M->DTQ_FILORI,M->DTQ_VIAGEM,nOpc,cSerTMS,cSrvAdc)
	
	If lRoteiro	 .Or. (Empty(M->DTQ_ROTA) .Or. F11RotRote(M->DTQ_ROTA))			
		//-- Executa a View (Nesta Rotina Não Existe o Browse Inicial Padrão MVC )
		
		//-- Coloca filial de origem no trajeto
		If !Empty(cFilAnt) .And. cSerTms == "3"
			aAreaSM0:= SM0->(GetArea())
			aAreaSA1:= SA1->(GetArea())
			
			SM0->(DbSetOrder(1))
			If SM0->(DbSeek(cEmpAnt + cFilAnt))
				SA1->(DbSetOrder(3))
				lFilial:= SA1->(DbSeek(xFilial("SA1") + SM0->M0_CGC))
			EndIf
			
			RestArea(aAreaSM0)
			RestArea(aAreaSA1)
		EndIf
		
		If (nOpc == 3  .OR. ( nOpc == 4 .AND. Empty(aRetTel[6]))) .AND. !Empty(aRetTel[5]) // Novo roteiro 
			
			If lFilial 
				If TMSAF12Inc(aRetTel[5],cSerTms,M->DTQ_FILORI,M->DTQ_VIAGEM)  == 1
					lRet := .F.
				EndIf
			Else
				Help( ,, 'HELP',, STR0153 , 1, 0,,,,,,{STR0154}) // Para viagens onde a rota será criada automaticamente, é necessário que seja incluído no Cadastro de Clientes (SA1) um registro cujo CNPJ seja o mesmo da filial em que a viagem está sendo gerada.  Efetue o cadastro e reinicie o processo
				lRet:= .F.
			EndIf	
			
		ElseIf nOpc == 4 .AND. !Empty(aRetTel[6]) .AND. ((!Empty(aRetTel[5]) .OR. Len(aDelDocs) > 0) .Or. M->DTQ_ROTA <> DTQ->DTQ_ROTA   ) // Houve alterações no roteiro 
			
			If TMSAF12Alt(aRetTel[5],aRetTel[6],aDelDocs,cSerTms,M->DTQ_FILORI,M->DTQ_VIAGEM)  == 1
				lRet := .F.
			EndIf
			
		ElseIf  nOpc == 4 .AND. !Empty(aRetTel[6]) .AND. Empty(aRetTel[5]) // Não houve alterações no roteiro  
			lRet := .T.
			
		ElseIf  nOpc == 2 // Visualização
			If TMSAF12Vis(aRetTel[5],aRetTel[6],aDelDocs,cSerTms,M->DTQ_FILORI,M->DTQ_VIAGEM)  == 1
				lRet := .T.	
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

Return {lRet,aRetPag,aRetTel}

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA144DcR
Verifica criterio do documento de Rateio 

@author Katia
@since 26/09/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA144DcR(cNrCont,cCodNeg,cServic)
Local cRet     := ""
Local cBacRat  := ""

Default cNrCont:= ""
Default cCodNeg:= ""
Default cServic:= ""

cBacRat:= TmsSobServ('BACRAT',.T.,.T.,cNrCont,cCodNeg,cServic,"1")
If cBacRat <> '1' //Nao Utiliza
	cRet:= TmsSobServ('CRIRAT',.T.,.T.,cNrCont,cCodNeg,cServic,"1")
EndIf	
						
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA144CHK
Checar se houve alteração na viagem, inclusao e ou exclusao de documentos
para executar a Pagadores / Roteiro. 

@author Katia
@since 07/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA144CHK(aGrid,aDelDocs)
Local aAreas    := {DT5->(GetArea()),DUD->(GetArea()),DTC->(GetArea()),GetArea()}
Local nCntFor   := 0
Local lDelDoc   := .F.        // Recebe se o documento esta deletado
Local cFilDoc   := ""         // Recebe a filial do documento
Local cDoc      := ""         // Recebe o documento
Local cSerie    := ""         // Recebe a serie do documento 
Local cAliasQry := ""         // Recebe o Alias da qery
Local cQuery    := ""         // Recebe a query
Local aRet      := {}
Local aTabRec   := {}

Default aGrid    := {}
Default aDelDocs := {}

For nCntFor := 1 To Len(aGrid) 
	
	lDelDoc :=  GDDeleted( nCntFor,,aGrid)
	
	cFilDoc := GdFieldGet('DTA_FILDOC',nCntFor,,,aGrid)
	cDoc    := GdFieldGet('DTA_DOC'   ,nCntFor,,,aGrid)
	cSerie  := GdFieldGet('DTA_SERIE' ,nCntFor,,,aGrid)

	DUD->(DbSetOrder(1)) 
	If DUD->(DbSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie+cFilAnt))
		
		If  DUD->DUD_SERTMS == "1" // Se for Coleta 
			dbSelectArea("DT5")
			DT5->(dbSetOrder(4))	
			If DT5->( dbSeek( FwxFilial("DT5") + cFilDoc+cDoc+cSerie ) )
				If lDelDoc
					AADD (aDelDocs , {"DT5","1",&("DT5->(" + ("DT5")->(IndexKey(1)) + ")")} )
				Else
					If !Empty(DT5->DT5_SERVIC) .Or. !Empty(DT5->DT5_SRVENT)
						AADD( aTabRec,{"DT5",DT5->(Recno())} )
					EndIf
				EndIf
			EndIf
			
		ElseIf DUD->DUD_SERTMS == "3" // Se for entrega
		
			cAliasQry := GetNextAlias() 
			// Buscas as notas a partir do documento
			cQuery := " SELECT  'DTC' TABELA                                  "
			cQuery += " 		  ,DTC.R_E_C_N_O_ RECNO                         "
			cQuery += " FROM " + RetSqlName("DTC") + " DTC  			        "
			
			cQuery += " WHERE DTC.DTC_FILIAL 	  = '"+ FwxFilial("DTC") + "'   "
			cQuery += " 	   AND DTC.DTC_FILDOC = '"+ cFilDoc +"'             "
			cQuery += " 	   AND DTC.DTC_DOC    = '"+ cDoc +"'                "
			cQuery += " 	   AND DTC.DTC_SERIE  = '"+ cSerie +"'              "
			cQuery += " 	   AND DTC.D_E_L_E_T_ = ' '                         "
			
			cQuery += " UNION ALL                                               "
			
			// Buscas as notas a partir do documento considerando DY4
			cQuery += " SELECT  'DTC' TABELA                                    "
			cQuery += " 		,DTC.R_E_C_N_O_ RECNO                           "
			cQuery += " FROM " + RetSqlName("DY4") + " DY4                      "
			cQuery += " INNER JOIN " + RetSqlName("DTC") + " DTC                "
			cQuery += " 	ON  DTC.DTC_FILIAL = '"+ FwxFilial("DTC") + "'      "
			cQuery += " 		AND DTC.DTC_FILORI =  DY4.DY4_FILORI            "
			cQuery += " 		AND DTC.DTC_LOTNFC =  DY4.DY4_LOTNFC            "
			cQuery += " 		AND DTC.DTC_NUMNFC =  DY4.DY4_NUMNFC            "
			cQuery += " 		AND DTC.DTC_SERNFC =  DY4.DY4_SERNFC            "
			cQuery += " 		AND DTC.DTC_CODPRO =  DY4.DY4_CODPRO            "
			cQuery += " 		AND DTC.D_E_L_E_T_ =  ' '             			"
			
			cQuery += " WHERE DY4.DY4_FILIAL = '"+ FwxFilial("DY4") + "'        "
			cQuery += " 	   AND DY4.DY4_FILDOC = '"+ cFilDoc +"'             "
			cQuery += " 	   AND DY4.DY4_DOC    = '"+ cDoc +"'                "
			cQuery += " 	   AND DY4.DY4_SERIE  = '"+ cSerie +"'              "
			cQuery += " 	   AND DY4.D_E_L_E_T_ = ' '                         "	
			
			// Executa a Query para retornar os dados para Rotina de Pagadoes
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			
			// Monta array de registro para pagadores
			While (cAliasQry)->(!Eof())
				 If lDelDoc
					dbSelectArea("DTC")
					DTC->(dbGoto((cAliasQry)->RECNO))
					AADD (aDelDocs , {"DTC","1",&("DTC->(" + ("DTC")->(IndexKey(1)) + ")")})
				 Else
					 AADD(aTabRec,{(cAliasQry)->TABELA,(cAliasQry)->RECNO})
				 EndIf
				 
				(cAliasQry)->(dbSkip())			
			EndDo
			(cAliasQry)->(dbCloseArea())	
					
		EndIf
	EndIf

Next nCntFor

aRet:= aClone(aTabRec)
AEval(aAreas,{|x,y| RestArea(x) })
Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM144RdVge
Redespachos da Viagem - Integração TMS x GFE
@type function
@author Katia
@version 12
@since 30/11/2016
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TM144RdVge(cFilDoc, cDoc, cSerie, cStatus, nOpcx)

Local nAux         := 0
Local nOpc         := 0
Local aLimpCols    := {}
Local aNoFields    := {}
Local aYesFields   := {}
Local nSavN	       := n
Local aSavCols     := aClone(aCols)
Local aSavHeader   := aClone(aHeader)
Local aSavaRotina  := aClone(aRotina)
Local oDlg,oGetD
Local nX           := 0
Local aObjects     := {}
Local nPosFilDoc   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == 'DTA_FILDOC'})
Local nPosDoc      := Ascan(aSavHeader, {|x| AllTrim(x[2]) == 'DTA_DOC'})
Local nPosSerie    := Ascan(aSavHeader, {|x| AllTrim(x[2]) == 'DTA_SERIE'})
Local nPosChvExt   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == 'DUD_CHVEXT'})
Local nRadio       := 1
Local oRadio       := Nil
Local oPanel       := Nil
Local lGravaRed    := .T.

Default cFilDoc    := ""
Default cDoc       := ""
Default cSerie     := ""
Default cStatus    := ""
		
If Empty(cFilDoc+cDoc) 
	Return .T.
EndIf

If nOpcx <> 2 .And. cSerTMS <> StrZero(3,Len(DC5->DC5_SERTMS)) .Or. cSerie == 'COL' //Nao habilita para Coleta e Transferencia
	Help('',1,'TMSA14442') //"Permitido incluir os Redespachos da Viagem somente para Documentos com Serviço de Transporte de ENTREGA.        
	Return .T.
EndIf

SaveInter()
//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

n       := 1
aCols	:= {}
aHeader := {}

RegToMemory( "DJN" , .T. )

AAdd( aNoFields, "DJN_FILIAL" )
AAdd( aNoFields, "DJN_FILORI" )
AAdd( aNoFields, "DJN_VIAGEM" )
AAdd( aNoFields, "DJN_FILDOC" )
AAdd( aNoFields, "DJN_DOC" )
AAdd( aNoFields, "DJN_SERIE" )

nAux := aScan( aRedVge, {|ExpA1| ExpA1[1] == cFilDoc+cDoc+cSerie } )

If nAux <= 0
	TMSFillGetDados( nOpcx, 'DJN', 1,xFilial( 'DJN' ) + M->DTQ_FILORI + M->DTQ_VIAGEM  + cFilDoc + cDoc + cSerie , {|| DJN->DJN_FILIAL + DJN->DJN_FILORI + DJN->DJN_VIAGEM + DJN->DJN_FILDOC + DJN->DJN_DOC + DJN->DJN_SERIE  }, ;
	{|| .T. }, aNoFields,	aYesFields )
	aHeaderDJN := AClone( aHeader )
Else
	aCols := AClone( aRedVge[nAux][2] )
	aHeader := AClone( aHeaderDJN )
EndIf

If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DJN_SEQRDP', 1 ) )
	GDFieldPut( 'DJN_SEQRDP', StrZero(1,Len(DJN->DJN_SEQRDP)), 1 )
EndIf

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 010, .T., .T. } )
AAdd( aObjects, { 100, 070, .T., .T. } )
AAdd( aObjects, { 100, 040,.T.,.T. } )
	
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
DEFINE MSDIALOG oDlg TITLE STR0127 FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL
	
oGetD:=MSGetDados():New(aPosObj[2,1]/2, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, IIf(nOpcx == 2 .Or. cStatus <> StrZero(1,Len(DUD->DUD_STATUS)) .Or. TMA360IDFV(cFilDoc,cDoc,cSerie) ,2 ,3),"TM144RdLOk()",,"+DJN_SEQRDP",.T.,,,.F.)
		
//-- Campos do Rodape
oPanel := TPanel():New(aPosObj[3,1]/2,aPosObj[3,2]/2,"",oDlg,,,,,CLR_WHITE,(aPosObj[3,4]/2), (aPosObj[3,3]/2), .T.)
	
@ 001,005 TO 45, 250 LABEL STR0142 OF oPanel PIXEL   //Repetir o Redespacho Adicional 
		@ 010,010 RADIO oRadio VAR nRadio PROMPT STR0143, STR0144, STR0145 OF oPanel ON CLICK {|| .T.} ;  //-- Somente para o Documento selecionado / Todos os Documentos da Viagem / Todos os Documentos da Viagem SEM Informação do Redesp.Adicional
		PIXEL SIZE 200,10
oRadio:lReadOnly := !IsInCallStack("TmsA144Val") .And. !(nOpcx==3 .Or. nOpcx==4)
ACTIVATE MSDIALOG oDlg    ON INIT (oGetD:Refresh(),EnchoiceBar(oDlg,   {||IIF(oGetD:TudoOk(),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()}) )

If nOpc == 1 .And. nOpcx != 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpando registros deletados                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aCols )
		If !aTail(aCols[nX])
			AAdd(aLimpCols,aCols[nX])
		EndIf
	Next nX
	
	aCols := {}
	aCols := aClone( aLimpCols )
	
	If nAux > 0
		aRedVge[nAux][2] := aClone(aCols)
	Else
		If nRadio == 1
			AAdd(aRedVge,{cFilDoc+cDoc+cSerie, aClone(aCols)})
		EndIf	
	EndIf
	
	//----- Repete o Redespacho Adicional conforme opcao selecionada
	If nRadio <> 1
		For nX:= 1 To Len(aSavCols)
			If !aSavCols[nX][Len(aSavCols[nX])] .And. Empty(aSavCols[nX][nPosChvExt]) //Nao Deletado e Docto nao integrado ao GFE
				lGravaRed:= .T.
				nPos:= Ascan( aRedVge, {|x| x[1] == aSavCols[nX][nPosFilDoc]+aSavCols[nX][nPosDoc]+aSavCols[nX][nPosSerie] })
				If nPos > 0
					If nRadio == 2  //Aplica para Todos Doctos da viagem 
						aDel(aRedVge,nPos)
						aSize(aRedVge,Len(aRedVge)-1)
					ElseIf nRadio == 3 //Aplica para os documentos da viagem sem Redespacho Adicional
						lGravaRed:= .F.
						If Len(aRedVge[nPos][2]) == 0
							aRedVge[nPos][2]:= aClone(aCols)
							lGravaRed:= .T.
						EndIf
							
					EndIf
				EndIf
					
				If lGravaRed
					AAdd(aRedVge,{aSavCols[nX][nPosFilDoc]+aSavCols[nX][nPosDoc]+aSavCols[nX][nPosSerie], aClone(aCols)})
				EndIf
			EndIf		
		Next
	EndIf
	
EndIf

aRotina	:= aClone(aSavaRotina)
aHeader := aClone(aSavHeader)
aCols   := aClone(aSavCols)
n		:= nSavN

RestInter()
//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM144RdLOk
Valida Linha do Redespachos Adicionais da Viagem - Integração TMS x GFE
@type function
@author Katia
@version 12
@since 30/11/2016
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TM144RdLOk()

Local lRet := .T.      
Local nPos := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DJN_CDTPOP'})

If !GDdeleted( n )
	//-- Verifica campos obrigatorios
	lRet := MaCheckCols( aHeader, aCols, n )   
	
	If lRet
	   lRet := GDCheckKey( { 'DJN_CODFOR','DJN_LOJFOR' }, 4 )
	EndIf       
	
	If lRet .And. n > 0
		nSeek :=Ascan(aCols, {|x|  ! x[ Len( x ) ] .And. AllTrim(x[nPos]) <> GDFieldGet('DJN_CDTPOP', n ) })  
		If nSeek > 0 
			//--- Na alteração da viagem, será gerado um novo Romaneio caso o Romaneio principal nao possa ser aberto.
			//--- Na criação deste novo romaneio, o tipo de operação (GWN) será com base do conteudo do campo DUD_TIPOPE. Portanto o conteudo de todas as linhas devem ser iguais	
			If nSeek <> n .And. lAltRom
				Help(' ', 1, 'TMSA14446') //-- O Tipo de Operação deve ser igual para todos os Itens do Redespacho Adicional.
				lRet:= .F.   
			EndIf	
		EndIf 	
	EndIf  
EndIf        

Return( lRet )

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM144DcGFE
Visualiza Documento de Carga do GFE
@type function
@author Katia
@version 12
@since 20/01/17
@return Nil
/*/
//-------------------------------------------------------------------------------------------------
Function TM144DcGFE(cFilDoc, cDoc, cSerie)

Default cFilDoc	:= ""
Default cDoc		:= ""
Default cSerie	:= ""

SaveInter()

DT6->(DbSetOrder(1))
If DT6->(dbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
	If	DT6->DT6_DOCTMS == StrZero( 1, Len( DT6->DT6_DOCTMS ) )				//-- Coleta
		//-- Posiciona na solicitacao de coleta.
		DT5->( DbSetOrder( 4 ) )
		If	DT5->( MsSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie, .F. ) )
			TMSViewGFE('DT5')
		EndIf
	Else
		If !Empty(DT6->DT6_DOCDCO)
			TMSDocXNf(DT6->DT6_FILDCO,DT6->DT6_DOCDCO,DT6->DT6_SERDCO,,,.F.)
		Else
			TMSDocXNf(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,.F.)
		EndIf
	EndIf
EndIf

RestInter()

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM144AtuLi
Atualiza aCols da viagem quando alterado o campo DTQ_PAGGFE
@type function
@author Katia
@version 12
@since 21/02/17
@return Nil
/*/
//-------------------------------------------------------------------------------------------------
Function TM144AtuLi(nLinDUD,lLimpDUD,cFilDoc,cDoc,cSerie,cCampo)

Default nLinDUD := 0
Default lLimpDUD:= .F.
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cCampo  := ""   //Somente determinado campo devera ser atualizado

If lLimpDUD
	GdFieldPut('DUD_UFORI' , '' , nLinDUD ) 
	GdFieldPut('DUD_CDMUNO', '' , nLinDUD ) 
	GdFieldPut('DUD_MUNORI', '' , nLinDUD )       
	GdFieldPut('DUD_CEPORI', '' , nLinDUD ) 
	GdFieldPut('DUD_UFDES' , '' , nLinDUD ) 
	GdFieldPut('DUD_CDMUND', '' , nLinDUD ) 
	GdFieldPut('DUD_MUNDES', '' , nLinDUD )       
	GdFieldPut('DUD_CEPDES', '' , nLinDUD ) 
	GdFieldPut('DUD_TIPVEI', '' , nLinDUD ) 
	GdFieldPut('DUD_DESTPV', '' , nLinDUD ) 
	GdFieldPut('DUD_CDTPOP', '' , nLinDUD ) 
	GdFieldPut('DUD_DSTPOP', '' , nLinDUD )                     
	GdFieldPut('DUD_CDCLFR', '' , nLinDUD ) 
	GdFieldPut('DUD_DSCLFR', '' , nLinDUD ) 
	GdFieldPut('DUD_CHVEXT', '' , nLinDUD )
	GdFieldPut('DUD_REDESP', '<< Enter >>' , nLinDUD )
	
Else
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
		Tmsa210GFE(nLinDUD, DTQ->DTQ_SERTMS, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,,cCampo)
	EndIf	
EndIf
	
Return

/*/{Protheus.doc} A144Rentab
//Calcula a rentabilidade da viagem
@author caio.y
@since 10/05/2017
@version undefined
@type function
/*/
Function A144Rentab( cTab ,nRecno ,nMenu )
Local nOpc		:= 3	

Default cTab	:= "DTQ"
Default nRecno	:= 0
Default nMenu	:= 1 

If nMenu == 1 
	nOpc	:= 3
Else
	nOpc	:= 5
EndIf

//-- Chama a função da rentabilidade prévia
TMSRentab(nOpc,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	
Return .T. 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsA144VMe
Validações para inclusão de CTRC no processo de retirada de mercadoria não prevista
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 05/05/2017
@param [cFilOri], Caracter, Filial origem da viagem
@param [cViagem], Caracter, Viagem
@param [cFilDoc], Caracter, Filial do documento
@param [cDoc], Caracter, Documento
@param [cSerie], Caracter, Série
@param [aCols], Array, Linhas grid
@param [nPos], Numérico, Posição grid
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TmsA144VMe(cFilOri, cViagem, cFilDoc, cDoc, cSerie, aCols, nPos)

	Local aAreaDT6    := DT6->(GetArea())
	Local aArDT6Aux   := {}
	Local aAreaDTW    := DTW->(GetArea())
	Local lRet        := .T.
	Local cSeekDTW    := ""
	Local cAtivSai    := GetMV("MV_ATIVSAI", ,"") //-- Atividade de saída de viagem
    Local cAtvChgCli  := SuperGetMv('MV_ATVCHGC',,'')
    Local cAtvSaiCli  := SuperGetMv('MV_ATVSAIC',,'') 
	Local lOpSaiFil   := .F.
	Local lOpCheCli   := .F.
	Local cCliRem     := ""
	Local cLojRem     := ""
	Local nCount      := 0
	Local aOpChCli    := {}
	Local aOpSaiCli   := {}
	Local nPosCli     := 0
	Local lVgeAtvApo  := .F.

	Default cFilOri := ""
	Default cViagem := ""
	Default cFilDoc := ""
	Default cDoc    := ""
	Default cSerie  := ""
	Default aCols   := {}
	Default nPos    := 0

	//-- Identifica se é CTRC
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))

		cCliRem := DT6->DT6_CLIREM //-- Cliente remetente do CTRC
		cLojRem := DT6->DT6_LOJREM //-- Loja do cliente remetente do CTRC

		DTW->(DbSetOrder(4)) 

		// Verifica se tem saida de viagem
		cSeekDTW := xFilial("DTW") + cFilOri + cViagem + cAtivSai
		If DTW->(MsSeek(cSeekDTW)) .AND.  DTW->DTW_STATUS == StrZero(2,Len(DTW->DTW_STATUS)) 
			lOpSaiFil := .T.
		EndIf

		If lOpSaiFil
			// Busca todas as chegas em clientes apontadas
			If DTW->(dbSeek(cSeekDTW := xFilial("DTW") + cFilOri + cViagem + cAtvChgCli ))
				Do While ! DTW->(Eof()) .And. DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM + DTW_ATIVID ) == cSeekDTW

					If  DTW->DTW_STATUS == StrZero(2,Len(DTW->DTW_STATUS)) 
						lOpCheCli := .T.
						
						If (nPosCli := AScan(aOpChCli,{|a|a[1] + a[2] == DTW->DTW_CODCLI + DTW->DTW_LOJCLI })) > 0
							aOpChCli[nPosCli][3] += 1
						Else
							AADD(aOpChCli,{DTW->DTW_CODCLI , DTW->DTW_LOJCLI,1})
						EndIf

					EndIf

					DTW->(dbSkip())
				EndDo
			EndIf

			// Busca todas as saidas de clientes apontadas
			If lOpCheCli .AND. DTW->(dbSeek(cSeekDTW := xFilial("DTW") + cFilOri + cViagem + cAtvSaiCli ))
				Do While ! DTW->(Eof()) .And. DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM + DTW_ATIVID ) == cSeekDTW

					If  DTW->DTW_STATUS == StrZero(2,Len(DTW->DTW_STATUS)) 
					
						If (nPosCli := AScan(aOpSaiCli,{|a| a[1] + a[2] == DTW->DTW_CODCLI + DTW->DTW_LOJCLI })) > 0
							aOpSaiCli[nPosCli][3] += 1
						Else
							AADD(aOpSaiCli,{DTW->DTW_CODCLI , DTW->DTW_LOJCLI,1})
						EndIf

					EndIf
					DTW->(dbSkip())
				EndDo
			EndIf

			
			If lOpCheCli
				//-- Se existir apontamento de chegada em cliente, então o CTRC que está
				//-- sendo incluído precisa ser do mesmo cliente de chegada

				For nCount := 1 To Len(aOpChCli)
					
					If (nPosCli := AScan(aOpSaiCli,{|a| a[1]+a[2] == aOpChCli[nCount][1] + aOpChCli[nCount][2] } )) > 0
						If  aOpSaiCli[nPosCli][3] < aOpChCli[nCount][3]
							cCliRem  := aOpChCli[nCount][1]
							cLojRem  := aOpChCli[nCount][2]
							Exit
						EndIf
					Else
						cCliRem  := aOpChCli[nCount][1]
						cLojRem  := aOpChCli[nCount][2]
						Exit
					EndIf
				Next nCount

				If !Empty(cCliRem) .AND. !Empty(cLojRem) .AND. DT6->DT6_SERIE <> "COL"
                    If !Empty(DT6->DT6_CLIEXP) .AND. !Empty(DT6->DT6_LOJEXP) 
                        If cCliRem + cLojRem != DT6->DT6_CLIEXP + DT6->DT6_LOJEXP
                            lRet := .F.
                            //-- Não é possível incluir o CTRC na viagem, pois não pertence ao mesmo cliente
                            //-- de chegada informado no apontamento de operação.
                            Help("", 1, "TMSA14443", , " " + STR0133 + ": " + cCliRem         + "/" + cLojRem + ", " +;      //STR0133 "Cliente/Loja do apontamento de chegada ao cliente"
                                                        STR0164 + ": " + DT6->DT6_CLIEXP + "/" + DT6->DT6_LOJEXP, 2, 1) //STR0164 "Cliente/Loja expedidor do CTRC"
                        EndIf
					Else
                        If cCliRem + cLojRem != DT6->DT6_CLIREM + DT6->DT6_LOJREM
                            lRet := .F.
                            //-- Não é possível incluir o CTRC na viagem, pois não pertence ao mesmo cliente
                            //-- de chegada informado no apontamento de operação.
                            Help("", 1, "TMSA14443", , " " + STR0133 + ": " + cCliRem         + "/" + cLojRem + ", " +;      //STR0133 "Cliente/Loja do apontamento de chegada ao cliente"
                                                        STR0134 + ": " + DT6->DT6_CLIREM + "/" + DT6->DT6_LOJREM, 2, 1) //STR0134 "Cliente/Loja remetente do CTRC"
                        EndIf
					EndIf
				EndIf
			EndIf

			If ExistFunc('TM350AtvPA')
				lVgeAtvApo := TM350AtvPA(cFilOri, cViagem )  //Verifica se existe a operação de saida de apoio na Viagem
			EndIf

			If (!lOpCheCli .Or. lRet) .And. !lVgeAtvApo
				//-- Se existir apontamento de saída de cliente ou saída de filial,
				//-- então o CTRC que está sendo incluído pode ser de um cliente diferente,
				//-- porém, do mesmo cliente dos demais CTRC que foram incluídos (se houver)
				If aCols != Nil
					For nCount := 1 To Len(aCols)
						If nCount != nPos      .And.;
						! GDDeleted(nCount) .And.;
						GdFieldGet("DUD_STATUS", nCount) == "1" //-- Status "1 - Em aberto"
							
							//-- Identifica o CTRC da linha posicionada
							aArDT6Aux := DT6->(GetArea())
							DT6->(DbSetOrder(1))
							If DT6->(MsSeek(xFilial("DT6") + GDFieldGet('DTA_FILDOC', nCount) +;
															GDFieldGet('DTA_DOC'   , nCount) +;
															GDFieldGet('DTA_SERIE' , nCount)))
								If DT6->DT6_CLIREM != cCliRem .Or. DT6->DT6_LOJREM != cLojRem .AND. DT6->DT6_SERIE <> "COL"
									lRet := .F.
									//-- Não é possível incluir o CTRC na viagem, pois já existe um CTRC incluído para outro cliente remetente.
									//-- Todos os CTRC incluídos na viagem em trânsito devem pertencer ao mesmo cliente.
									Help("", 1, "TMSA14444", , chr(10) + STR0135 + ": " + cCliRem         + "/" + cLojRem + ", " +;      //STR0135 "Cliente/Loja remetente do CTRC atual"
																		STR0136 + ": " + DT6->DT6_CLIREM + "/" + DT6->DT6_LOJREM, 2, 1) //STR0136 "Cliente/Loja remetente de CTRC já incluído"
									Exit
								EndIf
							EndIf
							RestArea(aArDT6Aux)
						EndIf
					Next nCount
				EndIf
			EndIf
		//-- Se não houver apontamento de saída de filial, então não permite
		//-- incluir um CTRC
		Else
			lRet := .F.
			Help("", 1, "TMSA14445")//  Não é possível incluir o CTRC na viagem em trânsito, pois não há apontamento de saída de viagem.
		EndIf
	Else
		//-- Solicitação de coleta não possui validações diferenciadas
	EndIf

	RestArea(aAreaDT6)
	RestArea(aAreaDTW)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA144Sta³ Autor ³ Valdemar Roberto      ³ Data ³ 06.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recupera variáveis estaticas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA144Sta(cExp01)                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TmsA144Sta(cNomVar)
Local cRet := ""

DEFAULT cNomVar := ""

If !Empty(cNomVar)
	cRet := &(cNomVar)
EndIf

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³T144DocCol³ Autor ³ Valdemar Roberto      ³ Data ³ 30.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe documento para solicitacao de coleta    ³±±  
±±|          | se SIM nao deixa excluir viagem                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function T144DocCol(cFilialCol, cViagemCol)

local lRet    := .F.
local cQuery  := ''
local cDocCol := ''
Local cAliasDoc  := GetNextAlias()

	cQuery +=  " SELECT DUD.DUD_DOC "
	cQuery +=  "   FROM "+RetSqlName('DUD')+" DUD" 
	cQuery +=  "  WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
	cQuery +=  "    AND DUD.DUD_FILORI = '" + cFilialCol + "'" 
	cQuery +=  "    AND DUD.DUD_VIAGEM = '" + cViagemCol + "'"
	cQuery +=  "    AND DUD.DUD_SERIE  = 'COL' "
	cQuery +=  "    AND DUD.D_E_L_E_T_ = ' '  "
	cQuery +=  "    AND EXISTS (SELECT DTC_NUMSOL " 
	cQuery +=  "                  FROM "+RetSqlName('DTC')+" DTC"
	cQuery +=  "                 WHERE DTC.DTC_FILIAL = '"+xFilial("DTC")+"'"
	cQuery +=  "                   AND DTC.DTC_FILCFS = DUD.DUD_FILDOC "
	cQuery +=  "                   AND DTC.DTC_NUMSOL = DUD.DUD_DOC "
	cQuery +=  "                   AND ISNULL(DTC.DTC_DATCOL,'"+Space(TamSX3('DTC_DATCOL')[1])+ "') <> '"+Space(TamSX3('DTC_DATCOL')[1])+"'"
	cQuery +=  "                   AND ISNULL(DTC.DTC_HORCOL,'"+Space(TamSX3('DTC_HORCOL')[1])+ "') <> '"+Space(TamSX3('DTC_HORCOL')[1])+"'"  
	cQuery +=  "                   AND DTC.D_E_L_E_T_ = ' ')"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDoc,.T.,.T.)
		
	If (cAliasDoc)->(!Eof())
		While (cAliasDoc)->(!Eof())
			If cDocCol = '' 
				cDocCol := STR0140 + CHR(13)+CHR(10) + CHR(13)+CHR(10) + (cAliasDoc)->DUD_DOC     // "Viagem não pode ser excluida pois as solicitações de coleta: "
			Else
				cDocCol += CHR(13)+CHR(10) + (cAliasDoc)->DUD_DOC
			EndIf
			(cAliasDoc)->(dbSkip())   
		EndDo
		ApMsgStop (cDocCol + CHR(13)+CHR(10) + CHR(13)+CHR(10) + STR0141)	// "Já estão vinculadas a um Documento de Entrada."
		lRet := .T.
	EndIf
	
return lRet
/*/-----------------------------------------------------------
{Protheus.doc} A144VldCk()
Valida a seleção do lote quando a integração com o TMSxGFE 
está ativo sendo necessario a informação do VeiculoxFornecedor
para atualizar os trechos do GFE 

Uso: TMSA144

@sample
//A144VldCk()

@author Katia Tiemi
@since 06/09/2017
@version 1.0
-----------------------------------------------------------/*/

Function A144VldCk(aRedesp,cNumRed,cCodFor,cLojFor,cFilOri)
Local lRet:= .T.
Local nX  := 0
Local nY  := 0
Local aAreaDFT:= DFT->(GetArea())

If lTmsRdpU 
		//-- Verifica se o Redespacho selecionado possui as mesmas caracteristicas.
		For nX:=1 To Len(aRedesp)
			For nY:=1 To Len(aRedesp[nX][7]) 
				If aRedesp[nX][7][nY][1]
					If aRedesp[nX][1] <> cNumRed
						//--- Verifica se o Redespacho possui as mesmas informações
						
						DFT->(DbSetOrder(2))			
						If DFT->(DbSeek( xFilial("DFT") + cFilOri + cNumRed + cCodFor + cLojFor ))
							If aRedesp[nX][10] <> DFT->DFT_CDTPOP .Or. ; 
								aRedesp[nX][11] <> DFT->DFT_CDCLFR .Or. ;
								aRedesp[nX][12] <> DFT->DFT_UFORI .Or. ;
								aRedesp[nX][13] <> DFT->DFT_CDMUNO .Or. ;
								aRedesp[nX][14] <> DFT->DFT_CEPORI .Or. ;
								aRedesp[nX][15] <> DFT->DFT_UFDES .Or. ;
								aRedesp[nX][16] <> DFT->DFT_CDMUND .Or. ;
								aRedesp[nX][17] <> DFT->DFT_CEPDES .Or. ;
								aRedesp[nX][18] <> DFT->DFT_TIPVEI
								
								MsgAlert(STR0151)  //"Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico."
								lRet:= .F.
								Exit 
							EndIf
						EndIf
							
					EndIf			
				EndIf
			Next nY
		Next nX

EndIf

RestArea(aAreaDFT)
Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} T144CarDJN()
Carrega dados do Redespacho Adicional (DJN)

Uso: TMSA144

@author Katia Tiemi
@since 08/09/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function T144CarDJN(aHeaderDJN,aRedVge,lRedesp)

Local aAreas  := GetArea()
Local cSeekTab:=  ""
Local nPosDJN := 0
Local aColsTab:= {}
Local cSeqDJN := StrZero(1,Len(DJN->DJN_SEQRDP)) 

Default lRedesp   := .F.

If lRedesp   //Viagem do Tipo Redespacho

	//-- Inclusao do Trecho quando o Fornecedor do veiculo é diferente do Fornecedor do Redespacho
	T144CriDJN(aHeaderDJN,@aColsTab,'DFV',cSeqDJN)
	cSeqDJN:= Soma1(cSeqDJN)
										
	//--- Inclusao dos redespachos adicionais (DJO para DJN)
	cSeekTab := xFilial("DJO")+DFV->(DFV_FILORI+DFV_NUMRED+DFV_FILDOC+DFV_DOC+DFV_SERIE)
	DJO->(dbSetOrder(1))
	If DJO->(MsSeek(cSeekTab))
		Do While !DJO->(Eof()) .And. DJO->(DJO_FILIAL+DJO_FILORI+DJO_NUMRED+DJO->DJO_FILDOC+DJO->DJO_DOC+DJO->DJO_SERIE) == cSeekTab
			T144CriDJN(aHeaderDJN,@aColsTab,'DJO',cSeqDJN)
			cSeqDJN:= Soma1(cSeqDJN)
			DJO->(dbSkip())
		EndDo
	EndIf

Else  //Viagem Normal	
	cSeekTab := xFilial("DJN")+M->DTQ_FILORI+M->DTQ_VIAGEM+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE
	DJN->(dbSetOrder(1))
	If DJN->(MsSeek(cSeekTab))
		Do While !DJN->(Eof()) .And. DJN->(DJN_FILIAL+DJN_FILORI+DJN_VIAGEM+DJN_FILDOC+DJN_DOC+DJN_SERIE) == cSeekTab
			T144CriDJN(aHeaderDJN,@aColsTab,'DJN',cSeqDJN)
			cSeqDJN:= Soma1(cSeqDJN)
			DJN->(dbSkip())
		EndDo
	EndIf	
EndIf

//--- Retorna dados do Array aRedVge para carregar na Grid DJN
nPosDJN := Ascan(aRedVge, {|x|  x[1] == DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE})
If nPosDJN > 0
	AAdd(aRedVge[nPosDJN][2], aClone(aColsTab))
Else
	AAdd(aRedVge,{ DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE, aClone(aColsTab)})
EndIf

RestArea(aAreas)
Return aColsTab

/*/-----------------------------------------------------------
{Protheus.doc} T144CriDJN()
Cria estrutura de  dados do Redespacho Adicional (DJN) a partir
das tabelas DJO, DFV e DJN

Uso: TMSA144

@author Katia Tiemi
@since 08/09/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function T144CriDJN(aHeaderDJN,aColsTab,cTabela,cSeqDJN)
Local aAreas := GetArea()
Local cId    := ""
Local cCampo := ""
Local nCntFor:= 0
Local cTabAnt:= ""
Local cCampTab:= ""
Local lCmpDFV := DFV->(ColumnPos('DFV_TIPVEI')) > 0

Default cSeqDJN := StrZero(1,Len(DJN->DJN_SEQRDP))

AAdd(aColsTab,Array(Len(aHeaderDJN)+1))
For nCntFor := 1 To Len(aHeaderDJN)
															
	cCampo:= SubStr( aHeaderDJN[nCntFor,2], At( "_", aHeaderDJN[nCntFor,2] ) + 1  )  //Campo
	cId:= cTabela + "_" + cCampo

	If !lCmpDFV .And. cCampo $ ('TIPVEI|DESTIP')
		Loop
	EndIf
	
	If	aHeaderDJN[nCntFor,10] != "V" .And. (cTabela <> "DFV" .Or. (cTabela == "DFV" .And. !(aHeaderDJN[nCntFor,2] $ 'DJN_TPFRRD') ))
		If cCampo $ "DJN_SEQRDP"
			aColsTab[Len(aColsTab),nCntFor]:= cSeqDJN 
		Else
			cId:= cTabela + "->" + cId
			aColsTab[Len(aColsTab),nCntFor]:= &(cId)
		EndIf
			
	Else
		
		If cCampo $ 'NOMFOR'
			cTabAnt:= Iif(cTabela == 'DFV', 'DFT', cTabela)   //Fornecedor consta na tabela DFT
			aColsTab[Len(aColsTab),nCntFor]:= Posicione("SA2", 1, xFilial("SA2") + &(cTabAnt + "->(" + cTabAnt + "_CODFOR+" + cTabAnt + "_LOJFOR )"), "A2_NOME" )
		ElseIf cCampo $ "MUNORI|MUNDES"
			If cCampo $ "MUNORI"
				cCampTab:= cTabela + "->(" + cTabela + "_UFORI+" + cTabela + "_CDMUNO )"
			Else
				cCampTab:= cTabela + "->(" + cTabela + "_UFDES+" + cTabela + "_CDMUND )"
			EndIf
			aColsTab[Len(aColsTab),nCntFor]:= Posicione("CC2",1,xFilial("CC2")+&(cCampTab),"CC2_MUN") 
		ElseIf cCampo $ "DSTPOP"
			aColsTab[Len(aColsTab),nCntFor]:= Posicione("GV4",1,xFilial("GV4")+ &(cTabela + "->(" + cTabela + "_CDTPOP)") ,"GV4_DSTPOP")	
		ElseIf cCampo $ "DSCLFR"
			aColsTab[Len(aColsTab),nCntFor]:= Posicione("GUB",1,xFilial("GUB")+ &(cTabela + "->(" + cTabela + "_CDCLFR)") ,"GUB_DSCLFR")
		Else	
			aColsTab[Len(aColsTab),nCntFor]:=CriaVar(aHeaderDJN[nCntFor,2])
		EndIf	
	EndIf
Next nCntFor
aColsTab[Len(aColsTab),Len(aHeaderDJN)+1]:=.F.

RestArea(aAreas)
Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} TMA144Gat()
Gatilha os campos DUD_CDTPOP, DUD_CDCLFR, DUD_TIPVEI conforme
dados da viagem DTQ_CDTPOP, DTQ_CDCLFR, DTQ_TIPVEI

Uso: TMSA144

@author Katia 
@since 28/09/2017
@version 1.0
-----------------------------------------------------------/*/
Function TMA144Gat()
Local nCntFor := 0
Local cCampo  := ReadVar()
Local lAtuGrid:= .F.
Local aArea   := GetArea()
Local cRet    := ""
Local aAreaAnt:= {}

If ('TMSA144' $ AllTrim(FunName())) 
	If "DTQ_CDTPOP" $ cCampo 
		If !Empty(cCdTpOPAnt) .And. cCdTpOPAnt != M->DTQ_CDTPOP 
			lAtuGrid:= .T.
		EndIf
		cCdTpOPAnt:= M->DTQ_CDTPOP
		cRet      := Posicione("GV4",1,xFilial("GV4")+M->DTQ_CDTPOP,"GV4_DSTPOP")                                                                        
	ElseIf "DTQ_CDCLFR" $ cCampo  
		If !Empty(cCdClFrAnt) .And. cCdClFrAnt != M->DTQ_CDCLFR 
			lAtuGrid:= .T.
		EndIf
		cCdClFrAnt:= M->DTQ_CDCLFR
		cRet      := Posicione("GUB",1,xFilial("GUB")+M->DTQ_CDCLFR,"GUB_DSCLFR")
	ElseIf "DTQ_TIPVEI" $ cCampo  
		If !Empty(cTipVeiAnt) .And. cTipVeiAnt != M->DTQ_TIPVEI 
			lAtuGrid:= .T.
		EndIf	
		cTipVeiAnt:= M->DTQ_TIPVEI
		cRet      := Posicione("DUT",1,xFilial("DUT")+M->DTQ_TIPVEI,'DUT_DESCRI')
	EndIf
	
	If lAtuGrid .And.  M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  .And. (Len(aCols) > 1 .Or. !Empty(GdFieldGet("DTA_FILDOC",1)) )
		aAreaAnt:= GetArea()
		For nCntFor := 1 To Len(aCols)
			TM144AtuLi(nCntFor, .F. ,GDFieldGet("DTA_FILDOC",nCntFor), GDFieldGet("DTA_DOC",nCntFor),GDFieldGet("DTA_SERIE" ,nCntFor),cCampo)
		Next
		oGetD:oBrowse:nAt := 1
		oGetD:oBrowse:Refresh(.T.)
		RestArea(aAreaAnt)
	EndIf
EndIf
	
RestArea(aArea)
Return cRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROTEÇÃO CONTRA VERSÃO INCOMPATÍVEL - RETIRAR NA 12.1.18     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function TMSA144Ver()
Return '12.1.17'

/*/-----------------------------------------------------------
{Protheus.doc} TMSA144Per()
Função para chamar a visualização/edição do percurso com a viagem posicionada

Uso: TMS

@author Paulo Henrique Corrêa Cardoso 
@since 23/03/2018
@version 1.0
-----------------------------------------------------------/*/
Function TMSA144Per(lEdit)
	Default lEdit := .F.
	
	If lEdit .AND. !(DTQ->DTQ_STATUS $ "1,2,5") //1-Em Aberto; 2-Em Transito; 5-Fechada.
		Help("", 1, "TMSA14447") // Não é possível editar o Percurso com status da viagem diferente de Em Aberto, Em Transito ou Fechada.
	Else
		F16ExbPerc(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,lEdit)   //"Visu./Editar Percurso"
	EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMA144CVg()
Verifica se todas as coletas do documento estão na mesma viagem

Uso: TMSA144

@author Valdemar Roberto Mognon
@since 02/08/2018
@version 1.0
-----------------------------------------------------------/*/

Function TMA144CVg(cFilDoc,cDoc,cSerie,cViagem)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local aAreas    := {GetArea()}

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

cAliasQry := GetNextAlias()
cQuery := "SELECT COUNT(DUD_DOC) QTDREG "

cQuery += "  FROM " + RetSqlName("DUD") + " DUD " 

cQuery += "  JOIN " + RetSqlName("DTC") + " DTC " 
cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "   AND DTC_FILDOC = '" + cFilDoc + "' "
cQuery += "   AND DTC_DOC    = '" + cDoc  + "' "
cQuery += "   AND DTC_SERIE  = '" + cSerie + "' "
cQuery += "   AND DTC_NUMSOL <> '" + Space(Len(DTC->DTC_NUMSOL)) + "' "
cQuery += "   AND DTC.D_E_L_E_T_ = ' '"

cQuery += " WHERE  DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND (DUD_FILDOC = DTC_FILORI OR DUD_FILDOC = DTC_FILCFS) "
cQuery += "   AND  DUD_DOC    = DTC_NUMSOL "
cQuery += "   AND  DUD_SERIE  = 'COL' "
cQuery += "   AND  DUD_VIAGEM <> '" + cViagem + "' "
cQuery += "   AND  DUD.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(!Empty(QTDREG))
	lRet := .F.
EndIf

(cAliasQry)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x)})

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} NfCliBut()
Verifica se exibe botão NF Cliente

Uso: TMSA144

@author Caio Murakami
@since 23/11/2018
@version 1.0
-----------------------------------------------------------/*/
Static Function NfCliBut(cFilOri , cViagem , nOpcx , cStatus )
Local lRet			:= .F. 
Local oViagem		:= Nil
Local aOperDTW		:= {} 
Local cAtvChgCli	:= SuperGetMV('MV_ATVCHGC',,'')
Local nCount		:= 1 
Local nPos			:= 0 
Local lTMSExp    	:= SuperGetMv("MV_TMSEXP", .F., .F.)

Default cFilOri	:= ""
Default cViagem	:= ""
Default nOpcx	:= 3
Default cStatus	:= ""

If lTMSExp
	lRet	:= .T. 
Else

	If nOpcx == 4 .And. ( cStatus == '2' .Or. cStatus == '4' ) //-- 2=Em trânsito;4=Chegada em Filial/Cliente
		
		aOperDTW	:= aClone( A350RetDTW( cFilOri, cViagem , "2" , "2" ) ) 

		If Len(aOperDTW) > 0 

			For nCount := 1 To Len(aOperDTW)

				nPos := aScan(aOperDTW[nCount] , { |x| x[1] == "DTW_ATIVID" })
				If nPos > 0 
					
					If aOperDTW[nCount, nPos][2] == cAtvChgCli
						lRet	:= .T. 
					Else
						lRet	:= .F. 
						Help("", 1, "TMSA144L0") //-- Para habilitar a opção Nf.Cliente para viagens em trânsito, é necessário que exista alguma operação de chegada de cliente apontada e a saída desse mesmo cliente não deve estar apontada
					EndIf
				EndIf

			Next nCount

		EndIf

	ElseIf nOpcx == 4 .And. cStatus == "1" //-- Em aberto
		lRet	:= .T. 
	EndIf

EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A144InitVal()
Inicia os valores do Acols
Uso: TMSA144
@author Rafael Souza
@since 03/04/2019
@version 1.0
-----------------------------------------------------------/*/
Static Function A144InitVal( aHeader , aCols , cFilOri , cViagem  )
Local nCount		:= 1 

Default aHeader		:= {}
Default aCols		:= {}
Default cFilOri		:= ""
Default cViagem		:= ""

For nCount := 1 To Len(aCols)

	If aCols[nCount][DUD->(GdFieldPos('DUD_STATUS'))] == "1"   //-- Em Aberto 
		aCols[nCount][DTA->(GdFieldPos('DTA_ORIGEM'))] := "2"  //-- Cliente / Remetente 
	EndIf

Next nCount

Return
/*/{Protheus.doc} A144Maplin
//Executa a integraçao Maplink  --- Temporario
@author Katia
@since 17/06/2019
@version undefined
@type function
/*/
Function A144Maplin( cTab ,nRecno ,nMenu )

Default cTab	:= "DTQ"
Default nRecno	:= 0
Default nMenu	:= 1 

MapLinkPrc(nMenu)
	
Return .T.
