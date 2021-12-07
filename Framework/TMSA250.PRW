#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TMSA250.ch'

//-- Inicio Redespacho
//-- Diretivas indicando as colunas dos documentos da viagem Do TMSA141
#define CTSTATUS		1
#define CTSTROTA		2
#define CTMARCA	   		3
#define CTSEQUEN		4
#define CTARMAZE		5
#define CTLOCALI		6
#define CTFILDOC		7
#define CTDOCTO			8
#define CTSERIE			9
#define CTREGDES		10
#define CTDATEMI		11
#define CTPRZENT		12
#define CTNOMREM		13
#define CTNOMDES		14
#define CTQTDVOL		15
#define CTVOLORI		16
#define CTPLIQUI		17
#define CTPESOM3		18
#define CTVALMER		19
#define CTVIAGEM		20
#define CTSEQDA7		21
#define CTSOLICI		22			//-- DUE_NOME
#define CTENDERE		23			//-- DUE_END
#define CTBAIRRO		24			//-- DUE_BAIRRO
#define CTMUNICI		25			//-- DUE_MUN
#define CTDATSOL		26			//-- DT5_DATSOL
#define CTHORSOL		27			//-- DT5_HORSOL
#define CTDATPRV		28			//-- DT5_DATPRV
#define CTHORPRV		29			//-- DT5_HORPRV
#define CTDOCROT		30			//-- Codigo que identifica a q rota pertence o documento
#define CTBLQDOC		31			//-- Tipos de bloqueio do documento
#define CTNUMAGE		32			//-- Numero do Agendamento( Carga Fechada ).
#define CTITEAGE		33			//-- Item do Agendamento( Carga Fechada ).
#define CTSERTMS		34			//-- Tipo do Servico.
#define CTDESSVT		35			//-- Descricao do Servico.
//-- Fim Redespacho
#DEFINE DDCODFOR		01			//-- Codigo do Fornecedor
#DEFINE DDLOJFOR		02			//-- Loja do Fornecedor
#DEFINE DDTIPFOR		03			//-- Tipo Fornec. (Pessoa Fisica, Juridica, ...)
#DEFINE DDCONTAT		04			//-- Contato do Fornecedor
#DEFINE DDFILDEB		05			//-- Filial de Debito Fornecedor
#DEFINE DDCONDPG		06  		//-- Condicao de Pagamento do Fornecedor
#DEFINE DDFILORI		07			//-- Filial de Origem
#DEFINE DDNUMVIA		08			//-- No. da Viagem
#DEFINE DDNUMCTC		09 			//-- No. do Contrato
#DEFINE DDVLRFRT		10			//-- Valor do Frete informado na viagem / Calculado
#DEFINE DDVLRADI		11			//-- Valor dos Adiantamentos
#DEFINE DDCRDADO		12			//-- Credor dos Adiantamentos
#DEFINE DDLOJCRD		13			//-- Loja do Credor
#DEFINE DDPREFIX		14			//-- Prefixo do Titulo
#DEFINE DDCODVEI		15			//-- Codigo do Veiculo
#DEFINE DDVLRPDG		16			//-- Valor do Pedagio
#DEFINE DDTIPTIT		17			//-- Tipo do Titulo
#DEFINE DDCODFAV		18			//-- Codigo do Favorecido
#DEFINE DDLOJFAV		19			//-- Loja do Favorecido
#DEFINE DDVLRISS		20			//-- Valor do ISS
#DEFINE DDNATTIT		21			//-- Natureza do Titulo
#DEFINE DDGERPDG		22			//-- Gera Titulo do Pedagio ? (1=Sim/2=Nao)
#DEFINE DDDEDFRT		23 			//-- Deduz Pedagio do Valor do Frete? (1=Sim/2=Nao)
#DEFINE DDBASIMP		24			//-- Valor Base para Calculo dos Impostos
#DEFINE DDLIBCTC		25			//-- Controla a Liberacao do Contrato de Carreteiro?
#DEFINE DDOPEFRT		26			//-- Contrato vinculado a Operadora de Frotas?
#DEFINE DDINSRET		27 			//-- Valor do INSS Retido
#DEFINE DDTIPUSO		28			//-- Tipo de Uso - 1=Viagem;2=Carga - Frete Embarcador
#DEFINE DDVIACAR		29			//-- Indentificador de Viagem ou Carga - Frt.Embarcador
#DEFINE DDGERTIT		30			//-- Gera Titulo do Contrato ?(1=Sim/2=Nao)
#DEFINE DDROTMUN		31			//-- Rota Municipal ?(1=Sim/2=Nao)
#DEFINE DDPEDVEN		32			//-- Gera Pedido Venda ?(1=Sim/2=Nao)
#DEFINE DDIMPREP		33			//-- Array de Impostos pela Repom(IRRF, SEST, INSS)
#DEFINE DDCODOPE		34			//-- Codigo da Operadora de Frete e Pedagio
#DEFINE DDLIBERA		35			//-- Foi executada a liberacao do contrato?
#DEFINE DDGERFRT		36			//-- Quando chamado pelo TMSA250 Gera titulo do frete, independente do MV_LIBCTC?//--Quando Chamado pelo TMSA251, informa se o titulo já foi gerado
#DEFINE DDBXAPDG		37			//-- Baixa Titulo de Pedagio Automaticamente
#DEFINE DDGERNDF		38			//-- Gera o Titulo de NDF na geracao do conrato independente do MV_LIBCTC?
#DEFINE DDNDFGER		39			//-- Informa se o titulo de NDF ja foi gerado
#DEFINE DDMOMPDG		40			//-- Informa o momento que o tit.de pdg. deve ser gerado
#DEFINE DDMOMADI		41			//-- Informa o momento que o tit.de adiantamento deve ser gerado
#DEFINE DDPAMOVB		42			//-- Informa se o Pa deverá movimentar banco. (PA já baixado)
#DEFINE DDVLRREE		43			//-- Valor do Reembolso
#DEFINE DDCIOTPE		44			//-- Ciot por Periodo
#DEFINE DDCOMPL 		45			//-- Contrato Complementar

Static lTM250Par  := ExistBlock('TM250PAR')
Static lTMA250Grv := ExistBlock('TMA250Grv')
Static lTMA250Fil := ExistBlock('TMA250FIL')
Static lTM250COND := ExistBlock('TM250COND')
Static lTM250MNU  := ExistBlock('TM250MNU')
Static lTM250NfOp := ExistBlock('TM250NfOp')
Static lTM250Desp := ExistBlock('TM250Desp')
Static lTM250Prc  := ExistBlock('TM250Prc')
Static lTM250FIM  := ExistBlock('TM250FIM')
Static lTM250BUT  := ExistBlock('TM250BUT')	//-- Inclui Botao na Enchoice, somente de visualizacao.
Static lTM250SLD  := ExistBlock('TM250SLD')
Static lTM250XML  := ExistBlock('TM250XML')
Static lTM250CMP  := ExistBlock('TM250CMP')
Static lTM250PER  := ExistBlock("TM250PER")	//-- Ponto de entrada utilizado para trocar o conteudo dos perguntes, criado p/ o Redespacho.
Static lTM250IND  := ExistBlock("TM250IND")	//-- permite alterar filtro padrao na geracao de contrato carreteiro por periodo
Static cFilDeb    := ""
Static lExcSched250 := IsBlind()   //--> Variável que será utilizada para definir se a execução é via Schedule.
Static lTM250PCp  := ExistBlock('TM250PCp') //-- PE utilizado para acrescentar campos que devem apkesentados no preview
Static lTM250PEd  := ExistBlock('TM250PEd') //-- PE utilizado para acrescentar campos que podem ser editados no preview
Static lTM250PBt  := ExistBlock('TM250PBt') //-- PE utilizado para adicionar opções no Ações Relacionadas do preview
Static lTM250Gr1  := ExistBlock('TM250Gr1') //-- PE utilizado para complementar a gravação da tabela DTY
Static lTM250POk  := ExistBlock('TM250POk') //-- PE utilizado para validar a confirmação da tela do preview
Static lTM250CT1  := ExistBlock('TM250CT1')	//-- PE utilizado para validar se processa o contrato de carreteiro após o retorno do preview
Static aHeaderAeD := {}
Static aColsAeD   := {}
Static lExceCst   := .F.
Static lEAIFunOK  := (FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI") .And. (Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0))
Static cTmsErp    := SuperGetMV("MV_TMSERP",,'0') //  Verifica se o TMS está integrado com o Protheus ou Outro ERP
Static cGerFreEvt := "1" //| Define o Evento de geração do Titulo de Frete de Carreteiro, sendo: 1-Inclusão do Contrato;2-Fechamento da Viagem;
Static cNatuDeb   := ''
Static cNatuPDG   := ''
Static lAuto250   := .f.
Static lImpRecalc := .f. // imposto Recalculado sim(.T.) ou não(.F.)
Static cDes250    := ""
Static cNat250    := ""
Static lTM250Cus  := ExistBlock('TM250Cus') //-- PE utilizado para desligar a validação do custo x receita
Static lTabDFI    := Iif(FindFunction("TmsUniNeg"),TmsUniNeg("DFI_FILIAL"),.F.)	// Tabela DFI existente no dicionário
Static lTM250Blq  := ExistBlock("TM250BLQ")	//-- PE que permite trocar a condição de bloqueio do titulo no financeiro
Static lContGerado:= .F.
Static lRepTrace  := SuperGetMv("MV_REPTRAC",,.T.) .And.  GetMV( 'MV_TMSXML',, .F. ) .And. ExistFunc('TmsRepTrac') //--ExistFunc("STBHomolPaf")
Static lObsDTY    := Iif(FindFunction("TmsUniNeg"),TmsUniNeg("DTY_CODOBS"),.F.)
Static lTM250BRW  := ExistBlock("TM250BRW")	//-- PE que permite ao usuario filtrar a mbrowse

#xtranslate Trace250(<uVar>) => Iif(lRepTrace, TmsRepTrac(<uVar>), Nil)

/*Função Dummy apenas para o Translate. */
Static Function Trace250()

Return Nil


//--------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa250

Funcao de BROWSE

Rotina de Contrato de Carreteiro com opção de integração nativa Protheus ou envio ao EAI

@author leandro.paulino

@since 12/09/2016
@version 1.0
/*/
//--------------------------------------------------------------------------------------
Function TMSA250()
Local oMBrowse	:= Nil
Local aAutoCab	:= {}

Local lLibCTC     	:= SuperGetMV( 'MV_LIBCTC',, .F. )
Local aCores      	:= NIL
Local lTMSOPdg    	:= SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local lPainel     	:= .F.
Local cFilMbrow     := ""
Local cFilMbrPE     := ""

Private cCadastro	:= STR0001 //"Contrato de Carreteiro"
Private aRotina	  	:= MenuDef(lLibCTC,lTMSOPdg)
Private aSetKey		:= {}
Private nDTYValFre  := 1   // Guarda o ultimo valor do DTY_VALFRE digitado...

If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)

If lLibCTC .Or. lTMSOPdg
	aCores := Tmsa250Cor()
EndIf

//--> Verifica se a rotina está sendo executada via SCHEDULE.
If !IsBlind() .And. !lAuto250
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPainel
	If aPanAgeTMS[6] == "TMSA250Sub(3)" .Or. aPanAgeTMS[6] == "TMSA250Sub(4)"
		aRotina := {}
	EndIf
		If (at("(",aPanAgeTMS[6])>0)
			&(aPanAgeTMS[6])
		Else
			&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
		Endif
	Else
		oMBrowse:= FWMBrowse():New()
		oMBrowse:SetAlias("DTY")
		oMBrowse:SetDescription( OemToAnsi( STR0001 ) ) //--"Contrato de Carreteiro"
		oMBrowse:AddLegend("DTY_STATUS=='1'",'BR_VERDE' 	, STR0090   )		//-- "Em Aberto"
		oMBrowse:AddLegend("DTY_STATUS=='2'",'BR_AMARELO'	, STR0091  )		//-- "Aguardando Liberacao p/ Pagamento"
		oMBrowse:AddLegend("DTY_STATUS=='3' .Or. (Empty(DTY_STATUS) .And. Empty(DTY_NUMPC))",'BR_LARANJA', STR0092	)	//-- "Liberado para Pagamento"
		oMBrowse:AddLegend("DTY_STATUS=='4' .Or. (Empty(DTY_STATUS) .And. !Empty(DTY_NUMPC))",'BR_AZUL'	, STR0094)	//-- "Contrato Quitado com Ped. Compra"
		oMBrowse:AddLegend("DTY_STATUS=='5'",'BR_VERMELHO' 	, STR0093 )		//-- "Contrato Quitado/Pagamento Realizado"
        oMBrowse:AddLegend("DTY_STATUS=='A'",'BR_VERDE_ESCURO' , STR0246 )    //-- "Contr. Parcial/Pagto. Parcial"
		oMBrowse:AddLegend("DTY_STATUS=='6'",'BR_CINZA'		, STR0148 )		//-- "Titulo em fatura"
		oMBrowse:AddLegend("DTY_STATUS=='7'",'BR_BRANCO'	, STR0157 )  	//-- 'Aguardando Confirm. Webserver'
		oMBrowse:AddLegend("DTY_STATUS=='8'",'BR_MARRON'	, STR0158 )  	//-- Alterado de 'Aguardando autoriz pagto' para 'Contrato Pago Pela Operadora. Aguard. Baixa Financeira.'
		oMBrowse:AddLegend("DTY_STATUS=='9'",'BR_PRETO'		, STR0159 )  	//-- 'Pagamento Bloqueado
		oMBrowse:AddLegend("DTY_STATUS=='B'",'F12_MARR'		, STR0281 )  	//-- "Contrato Quitado/Aguardando autorização Operadora"

		If lTM250BRW //-- PE - Permite ao usuario filtrar a mbrowse
			cFilMbrPE := ExecBlock("TM250BRW",.F.,.F.)
			If ValType(cFilMbrPE) == "C" .And. !Empty(cFilMbrPE)
				cFilMbrow += " " + cFilMbrPE
			EndIf
		EndIf
		If !Empty(cFilMbrow)
			oMBrowse:SetFilterDefault( cFilMbrow ) 
		EndIf	
		
		oMBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
		oMBrowse:Activate()

		//-- Finaliza as Teclas de Atalhos
		TmsKeyOff(aSetKey)

	EndIf
Else

	RpcSetType(3)
	RpcSetEnv( cEmpAnt, cFilAnt,,,'TMS')

	TmsLogMsg(,STR0190+" - " + STR0214 +": " +cFilAnt+" - " +STR0213 +": "+cEmpAnt+ " - "+Dtoc(Date())+" "+Time()) //--> STR0190 = >> TMSA250 INICIADO GERAÇÃO DE CONTRATO CARRETEIRO - (POR PERIODO)  //--> STR0214 = Empresa //--> STR0214 = Filial

	TMSA250Mnt("DTY",0, 4,Nil,Nil,Nil)
	//Limpa o ambiente, liberando a licença e fechando as conexões
	RpcClearEnv()

EndIf


Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author leandro.paulino

@since 12/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil
Local lTabDDN   	:= AliasInDic("DDN")
Local lTabDJC		:= AliasInDic("DJC")
Local lTabDUA		:= DUA->(ColumnPos("DUA_NUMCTC")) > 0
Local oStrDTY		:= FWFormStruct(1,'DTY')
Local oStrDVP		:= FwFormStruct(1,'DVP')
Local oStrSC7		:= FwFormStruct(1,'SC7')
Local oStrSE2		:= FwFormStruct(1,'SE2', { |cCampo|  AllTrim( cCampo ) + "|" $ "|E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_NATUREZ|E2_PORTADO|E2_FORNECE|E2_LOJA|E2_NOMFOR|E2_EMISSAO|E2_VENCTO|E2_VENCREA|E2_VALOR|E2_ISS|E2_IRRF|E2_NUMBCO|E2_INDICE|E2_BAIXA|E2_SALDO|E2_ORIGEM|E2_NUMBOR|" } )
Local oStrDJC		:= FwFormStruct(1,'DJC')
Local oStrSDG		:= FwFormStruct(1,'SDG')
Local oStrCompl		:= FwFormStruct(1,'DTY')
Local oStrPeriodo	:= FwFormStruct(1,'DTY')
Local oStrDT8		:= FwFormStruct(1,'DT8')
Local oStrDDN		:= Iif(lTabDDN , FwFormStruct(1,'DDN') , Nil )
Local oStrDUA		:= Iif(lTabDUA , FwFormStruct(1,'DUA') , Nil )
Local cIniDVP		:= ""
Local cIniDT8		:= ""
Local cIniDTY		:= ""
Local lComplemento	:= IsInCallStack("TMSA250COM")
Local lTMSOPdg    	:= SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local cCodDesCTC 	:= TMSA250Var("DES") // Codigo de Despesa de contrato de carreteiro
Local cCodDesPDG 	:= Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio
Local cCodDesPRE 	:= Padr( GetMV("MV_DESPRE"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Premio
Local bLoadCompl

//--------------------------------------------------------------------
//-- DVP - Manipulação campos estrutura
//--------------------------------------------------------------------
cIniDVP	:= "IIF(!INCLUI,POSICIONE('DT3',1,xFilial('DT3')+DVP->DVP_CODPAS,'DT3_DESCRI'),'') "

oStrDVP:AddField( ; 						// Ord. Tipo Desc.
          STR0239	, ; 					// [01] C Titulo do campo	//-- Descrição componente
          STR0239	, ; 					// [02] C ToolTip do campo	//-- Descrição componente
          'DVP_DESCOM' , ; 					// [03] C identificador (ID) do	Field
          'C' , ; 							// [04] C Tipo do campo
          30 , ; 							// [05] N Tamanho do campo
          0 , ; 							// [06] N Decimal do campo
          NIL, ;	 						// [07] B Code-block de validação do campo
          NIL , ; 							// [08] B Code-block de	validação When do campo
          NIL , ; 							// [09] A Lista de valores permitido do campo
          NIL , ; 							// [10] L Indica se o campo tem preenchimento obrigatório
          FwBuildFeature( STRUCT_FEATURE_INIPAD, cIniDVP )  ,; // [11] B Code-block de inicializacao do campo
          NIL , ; 							// [12] L Indica se trata de um campo chave
          NIL , ; 							// [13] L Indica se o campo pode receber valor em uma operação de update.
          .T. ) 							// [14] L Indica se o campo é virtual

//--------------------------------------------------------------------
//-- SE2 - Manipulação campos estrutura
//--------------------------------------------------------------------
oStrSE2:AddField(;
				"Status"	,;
				""			,;
				"LOG_BTSTA"	,;
				"BT"		,;
				1			,;
				0			,;
				/*bValid*/	,;
				/*bWhen*/	,;
				NIL			,;
				.F.			,;
				{||TMSA250StTit( SE2->(Recno()) )},;
				/*lKey*/	,;
				/*lNoUpd*/	,;
				.T.			,;
				/*cValid*/	)


//--------------------------------------------------------------------
//-- DT8 - Manipulação campos estrutura
//--------------------------------------------------------------------
cIniDT8	:= "IIF(!INCLUI,POSICIONE('DT3',1,xFilial('DT3')+DT8->DT8_CODPAS,'DT3_DESCRI'),'') "

oStrDT8:AddField( ; 						// Ord. Tipo Desc.
          STR0239 , ; 						// [01] C Titulo do campo //-- Descrição componente
          STR0239 , ; 						// [02] C ToolTip do campo //-- Descrição componente
          'DT8_DESCOM' , ; 					// [03] C identificador (ID) do	Field
          'C' , ; 							// [04] C Tipo do campo
          30 , ; 							// [05] N Tamanho do campo
          0 , ; 							// [06] N Decimal do campo
          NIL, ;	 						// [07] B Code-block de validação do campo
          NIL , ; 							// [08] B Code-block de	validação When do campo
          NIL , ; 							// [09] A Lista de valores permitido do campo
          NIL , ; 							// [10] L Indica se o campo tem preenchimento obrigatório
          FwBuildFeature( STRUCT_FEATURE_INIPAD, cIniDT8 )  ,; // [11] B Code-block de inicializacao do campo
          NIL , ; 							// [12] L Indica se trata de um campo chave
          NIL , ; 							// [13] L Indica se o campo pode receber valor em uma operação de update.
          .T. ) 							// [14] L Indica se o campo é virtual


//--------------------------------------------------------------------
//-- DTY - Manipulação campos estrutura
//--------------------------------------------------------------------
cIniDTY	:= " " + AllTrim(Str(DTYValLiq())) + " "

oStrDTY:AddField( ; 						// Ord. Tipo Desc.
          STR0272 , ;						// [01] C Titulo do campo //-- "Valor Líquido"
          STR0272 , ; 						// [02] C ToolTip do campo //-- "Valor Líquido"
          'DTY_VALLIQ' , ; 					// [03] C identificador (ID) do	Field
          'N' , ; 							// [04] C Tipo do campo
          14 , ; 							// [05] N Tamanho do campo
          2 , ; 							// [06] N Decimal do campo
          NIL, ;	 						// [07] B Code-block de validação do campo
          NIL , ; 							// [08] B Code-block de	validação When do campo
          NIL , ; 							// [09] A Lista de valores permitido do campo
          NIL , ; 							// [10] L Indica se o campo tem preenchimento obrigatório
         FwBuildFeature( STRUCT_FEATURE_INIPAD, cIniDTY )  ,; // [11] B Code-block de inicializacao do campo
          NIL , ; 							// [12] L Indica se trata de um campo chave
          .T. , ; 							// [13] L Indica se o campo pode receber valor em uma operação de update.
          .T. ) 							// [14] L Indica se o campo é virtual
//--------------------------------------------------------------------
//-- Tratamento especifico para chamada a partir do complemento de contrato
//--------------------------------------------------------------------
If lComplemento .And. !IsBlind() .And. !lAuto250

	oStrDTY:SetProperty('*', MODEL_FIELD_WHEN, {||.F.} )
	If lTMSOPdg
		oStrDTY:SetProperty( 'DTY_VALFRE' , MODEL_FIELD_WHEN, {||.T.} )
		oStrDTY:SetProperty( 'DTY_CODMOV' , MODEL_FIELD_WHEN, {||.T.} )
	Else
		oStrDTY:SetProperty( 'DTY_VALFRE' , MODEL_FIELD_WHEN, {||.T.} )
		oStrDTY:SetProperty( 'DTY_TIPUSO' , MODEL_FIELD_WHEN, {||.T.} )
	EndIf

EndIf

If lComplemento
	oStrDTY:SetProperty('DTY_NUMCTC', MODEL_FIELD_INIT , {||GetSx8Num('DTY','DTY_NUMCTC')})
EndIf

//--------------------------------------------------------------------
//-- DTY - Contrato Carreteiro
//--------------------------------------------------------------------
oModel := MPFormModel():New('TMSA250',/*bPreValid*/ , { |oModel| PosVldmdl(oModel) } , { | oModel | CommitMdl(oModel)},  )

oModel:AddFields('MdFieldDTY',Nil,oStrDTY,,,{|oModel,lCopy|LoadField(oModel,lCopy)} )

oModel:SetDescription( OemToAnsi( STR0001 ) ) //--"Contrato de Carreteiro"
oModel:SetPrimaryKey({"DTY_FILIAL", "DTY_FILORI", "DTY_NUMCTC"})

//--------------------------------------------------------------------
//-- DVP - Composição do frete
//--------------------------------------------------------------------
oModel:AddGrid('MdGridDVP','MdFieldDTY',oStrDVP,,,,, )
oModel:GetModel('MdGridDVP'):SetDescription(STR0045) //-- Comp. Frete
oModel:GetModel( 'MdGridDVP' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDVP' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridDVP' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridDVP' ):SetOptional( .T. )
oModel:GetModel( 'MdGridDVP' ):SetOnlyQuery( .T. )
oModel:GetModel( 'MdGridDVP' ):SetLoadFilter( { { 'DVP_CODPAS', "'TF'", MVC_LOADFILTER_NOT_EQUAL } } )

oModel:SetRelation('MdGridDVP', { {'DVP_FILIAL','xFilial("DVP")' },{'DVP_FILORI','MdFieldDTY.DTY_FILORI'},{'DVP_NUMCTC','MdFieldDTY.DTY_NUMCTC'},{'DVP_VIAGEM','MdFieldDTY.DTY_VIAGEM'} } , DVP->(IndexKey(1) ) )

//--------------------------------------------------------------------
//-- DVP - Contadores
//--------------------------------------------------------------------
oModel:AddCalc( "MdCalcDVP", "MdFieldDTY", "MdGridDVP", "DVP_VALPAS"  , STR0279, "SUM" , {||.T.}  ) //-- Valor do Componente
oModel:GetModel( 'MdCalcDVP' ):SetDescription(STR0045) //-- Comp. Frete

//--------------------------------------------------------------------
//-- SC7 - Pedidos de Compra
//--------------------------------------------------------------------
oModel:AddGrid('MdGridSC7','MdFieldDTY',oStrSC7,,,,,)
oModel:GetModel('MdGridSC7'):SetDescription(STR0047) //-- Ped.Comp.
oModel:GetModel( 'MdGridSC7' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridSC7' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridSC7' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridSC7' ):SetOptional( .T. )
oModel:GetModel( 'MdGridSC7' ):SetOnlyQuery( .T. )

oModel:SetRelation('MdGridSC7', { {'C7_FILIAL','xFilial("SC7")' },{'C7_NUM','MdFieldDTY.DTY_NUMPC'} } , SC7->(IndexKey(1) ) )

//--------------------------------------------------------------------
//-- SE2 - Títulos a pagar
//--------------------------------------------------------------------
oModel:AddGrid('MdGridSE2','MdFieldDTY',oStrSE2,,,,,{|oModel,lCopy|LoadGrid(oModel,lCopy,'SE2')} )
oModel:GetModel('MdGridSE2'):SetDescription(STR0134) //-- Títulos
oModel:GetModel( 'MdGridSE2' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridSE2' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridSE2' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridSE2' ):SetOptional( .T. )
oModel:GetModel( 'MdGridSE2' ):SetOnlyQuery( .T. )

oModel:SetRelation('MdGridSE2', { 	{'E2_FILIAL','xFilial("SE2",TMA010AGet("MdFieldDTY","DTY_FILORI"))' }	,;
									{'E2_PREFIXO', 'TMA250GerPrf( cFilAnt )' }	,;
									{'E2_NUM','MdFieldDTY.DTY_NUMCTC'}} ,;
									SE2->(IndexKey(1) ) )

//--------------------------------------------------------------------
//-- DDN - Histórico Acrescimos/Decrescimos
//--------------------------------------------------------------------
If lTabDDN

	oModel:AddGrid('MdGridDDN','MdFieldDTY',oStrDDN,,,,,)
	oModel:GetModel('MdGridDDN'):SetDescription(STR0223) //-- Hist Acr/Decr
	oModel:GetModel( 'MdGridDDN' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridDDN' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridDDN' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MdGridDDN' ):SetOptional( .T. )
	oModel:GetModel( 'MdGridDDN' ):SetOnlyQuery( .T. )

	oModel:SetRelation('MdGridDDN',{{'DDN_FILIAL','xFilial("DDN")'},{'DDN_FILORI','MdFieldDTY.DTY_FILORI'},{'DDN_VIAGEM','MdFieldDTY.DTY_VIAGEM'}},DDN->(IndexKey(1)))

	//--------------------------------------------------------------------
	//-- DDN - Contadores
	//--------------------------------------------------------------------
	oModel:AddCalc( "MdCalcDDN", "MdFieldDTY", "MdGridDDN", "DDN_VALOR"  , "Valor Acréscimo" , "SUM", {|| FwFldGet("DDN_TIPAED") == "1" }  )
	oModel:AddCalc( "MdCalcDDN", "MdFieldDTY", "MdGridDDN", "DDN_VALOR"  , "Valor Decréscimo", "SUM", {|| FwFldGet("DDN_TIPAED") == "2"}  )
	oModel:GetModel( 'MdCalcDDN' ):SetDescription(STR0270) //-- "Totais Acrescimo/Decrescimo"

EndIf

//--------------------------------------------------------------------
//-- DJC - Historico Custo do Documento
//--------------------------------------------------------------------
If lTabDJC
	oModel:AddGrid('MdGridDJC','MdFieldDTY',oStrDJC,,,,,)
	oModel:GetModel('MdGridDJC'):SetDescription(STR0234) //-- Cons Custo Doc.
	oModel:GetModel( 'MdGridDJC' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridDJC' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridDJC' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MdGridDJC' ):SetOptional( .T. )
	oModel:GetModel( "MdGridDJC" ):SetOnlyQuery( .T. )

	oModel:SetRelation("MdGridDJC",{{"DJC_FILIAL","xFilial('DJC')"},;
									 {"DJC_FILORI","MdFieldDTY.DTY_FILORI"},;
									 {"DJC_VIAGEM","MdFieldDTY.DTY_VIAGEM"},;
									 {"DJC_NUMCTC","MdFieldDTY.DTY_NUMCTC"}},;
									 DJC->(IndexKey(1)))

	oModel:GetModel("MdGridDJC"):SetUseOldGrid(.F.)

	//--------------------------------------------------------------------
	//-- DT8 - Componentes de frete
	//--------------------------------------------------------------------
	oModel:AddGrid('MdGridDT8','MdGridDJC',oStrDT8,,,,,{|oModel,lCopy|LoadGrid(oModel,lCopy,'DT8')} )
	oModel:GetModel('MdGridDT8'):SetDescription(STR0278) //-- Componentes de frete a Receber
	oModel:GetModel( 'MdGridDT8' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridDT8' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridDT8' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MdGridDT8' ):SetOptional( .T. )
	oModel:GetModel( 'MdGridDT8' ):SetOnlyQuery( .T. )

	oModel:SetRelation("MdGridDT8",{{"DT8_FILIAL","xFilial('DT8')"},;
									 {"DT8_FILDOC","DJC_FILDOC"},;
									 {"DT8_DOC","DJC_DOC"},;
									 {"DT8_SERIE","DJC_SERIE"}},;
									 DT8->(IndexKey(2)))

	oModel:AddCalc( "MdCalcDT8", "MdFieldDTY", "MdGridDT8", "DT8_VALPAS"  , STR0281, "SUM" , {||.T.}  ) //-- Valor Total

EndIf

//--------------------------------------------------------------------
//-- SDG - Movimento Custo de Transporte
//--------------------------------------------------------------------
oModel:AddGrid('MdGridSDG','MdFieldDTY',oStrSDG,,,,,)
oModel:GetModel('MdGridSDG'):SetDescription(STR0122) //-- Movimento Custo de Transporte
oModel:GetModel( 'MdGridSDG' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridSDG' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridSDG' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridSDG' ):SetOptional( .T. )
oModel:GetModel( 'MdGridSDG' ):SetOnlyQuery( .T. )

oModel:SetRelation('MdGridSDG',{ {'DG_FILIAL','xFilial("SDG")'},{'DG_FILORI','MdFieldDTY.DTY_FILORI'},{'DG_VIAGEM','MdFieldDTY.DTY_VIAGEM'},{'DG_CODVEI','MdFieldDTY.DTY_CODVEI'} }, SDG->(IndexKey(5) ) )

//--------------------------------------------------------------------
//-- DTY - Complemento do contrato
//--------------------------------------------------------------------
If DTY->DTY_TIPCTC == "5"
	bLoadCompl := {|oModel,lCopy| {} }
EndIf
oModel:AddGrid('MdGridDTY','MdFieldDTY',oStrCompl,,,,,bLoadCompl)
oModel:GetModel('MdGridDTY'):SetDescription(STR0068) //-- Complemento
oModel:GetModel( 'MdGridDTY' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDTY' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridDTY' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGridDTY' ):SetOptional( .T. )
oModel:GetModel( 'MdGridDTY' ):SetOnlyQuery( .T. )
If DTY->DTY_TIPCTC <> "5"
	oModel:GetModel( 'MdGridDTY' ):SetLoadFilter( { { 'DTY_NUMCTC',"'" + DTY->DTY_NUMCTC + "'" , MVC_LOADFILTER_NOT_EQUAL } } )
EndIf

oModel:SetRelation('MdGridDTY', { {'DTY_FILIAL','xFilial("DTY")' },;
									{'DTY_FILORI','MdFieldDTY.DTY_FILORI'},;
									{'DTY_VIAGEM','MdFieldDTY.DTY_VIAGEM'},;
									{'DTY_TIPCTC','"5"'} } , DTY->(IndexKey(2) ) )

//--------------------------------------------------------------------
//-- DUA - Ocorrências
//--------------------------------------------------------------------
If lTabDUA
	oModel:AddGrid('MdGridDUA','MdFieldDTY',oStrDUA,,,,,)
	oModel:GetModel('MdGridDUA'):SetDescription(STR0275) //-- Ocorrencias do contrato
	oModel:GetModel('MdGridDUA'):SetNoInsertLine( .T. )
	oModel:GetModel('MdGridDUA'):SetNoDeleteLine( .T. )
	oModel:GetModel('MdGridDUA'):SetNoUpdateLine( .T. )
	oModel:GetModel('MdGridDUA'):SetOptional( .T. )
	oModel:GetModel('MdGridDUA'):SetOnlyQuery( .T. )

	oModel:SetRelation('MdGridDUA',{ {'DUA_FILIAL','xFilial("DUA")'},{'DUA_FLOCTC','MdFieldDTY.DTY_FILORI'},{'DUA_NUMCTC','MdFieldDTY.DTY_NUMCTC'} }, DUA->(IndexKey(1) ) )
EndIf

//--------------------------------------------------------------------
//-- DTY - Contratos do período
//--------------------------------------------------------------------
oModel:AddGrid('MdGrid2DTY','MdFieldDTY',oStrPeriodo,,,,,)
oModel:GetModel( 'MdGrid2DTY' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGrid2DTY' ):SetNoDeleteLine( .F. )
oModel:GetModel( 'MdGrid2DTY' ):SetNoUpdateLine( .T. )
oModel:GetModel( 'MdGrid2DTY' ):SetOptional( .T. )
oModel:GetModel( 'MdGrid2DTY' ):SetOnlyQuery( .T. )
oModel:GetModel( 'MdGrid2DTY' ):SetLoadFilter( { { 'DTY_VIAGEM', "'" + DTY->DTY_VIAGEM + "'" , MVC_LOADFILTER_NOT_EQUAL } } )

oModel:SetRelation('MdGrid2DTY', { {'DTY_FILIAL','xFilial("DTY")' },{'DTY_NUMCTC','MdFieldDTY.DTY_NUMCTC'},{'DTY_TIPCTC','"2"'}  } , DTY->(IndexKey(1) ) )

//-- Carrega as informações sob demanda
oModel:SetOnDemand(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author leandro.paulino

@since 12/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel 	:= FWLoadModel("TMSA250")
Local lTabDDN   := AliasInDic("DDN")
Local lTabDJC	:= AliasInDic("DJC")
Local lTabDUA	:= DUA->(ColumnPos("DUA_NUMCTC")) > 0
Local oStrDTY	:= FWFormStruct(2,'DTY')
Local oStrDVP	:= FwFormStruct(2,'DVP')
Local oStrSC7	:= FwFormStruct(2,'SC7')
Local oStrSE2	:= FwFormStruct(2,'SE2', { |cCampo|  AllTrim( cCampo ) + "|" $ "|E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_NATUREZ|E2_PORTADO|E2_FORNECE|E2_LOJA|E2_NOMFOR|E2_EMISSAO|E2_VENCTO|E2_VENCREA|E2_VALOR|E2_ISS|E2_IRRF|E2_NUMBCO|E2_INDICE|E2_BAIXA|E2_SALDO|E2_ORIGEM|E2_NUMBOR|" } )
Local oStrDJC	:= FwFormStruct(2,'DJC')
Local oStrSDG	:= FwFormStruct(2,'SDG')
Local oStrCompl	:= FwFormStruct(2,'DTY')
Local oStrDT8	:= FwFormStruct(2,'DT8')
Local oStrDDN	:= Iif(lTabDDN,FwFormStruct(2,'DDN'),Nil)
Local oStrDUA	:= Iif(lTabDUA,FwFormStruct(2,'DUA'),Nil)
Local oCalcDVP	:= FWCalcStruct( oModel:GetModel( "MdCalcDVP" ) )
Local oCalcDDN	:= FwCalcStruct( oModel:GetModel( "MdCalcDDN" ) )
Local oCalcDT8	:= Iif( lTabDJC , FwCalcStruct( oModel:GetModel( "MdCalcDT8" ) ) , Nil )
Local nCont		:= 1
Local lTM250BUT := ExistBlock('TM250BUT')
Local aButTmp	:= {}
Local nCount	:= 1
Local aButtons	:= {}
Local cResource	:= ""
Local bBloco	:= {||}
Local cTitle	:= ""
Local lComplemento	:= IsInCallStack("TMSA250COM")

Private aSetKey		:= {}

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VwFieldDTY' , oStrDTY, "MdFieldDTY" )

//-- Se a rotina for acionada a partir do complemento de contrato
If lComplemento
	Aadd(aSetKey, { VK_F6 , {|| lImpRecalc := TMSA250Imp()} } )
	oView:AddUserButton( STR0131 , 'PARAMETROS', {||TMSA250Imp() } ) //-- Calcula imposto
EndIf

//-- Ponto de Entrada para adicionar botoes na Enchoice
If lTM250BUT
	aButTmp := ExecBlock('TM250BUT',.F.,.F.,{oModel:GetOperation()})
	If Len(aButTmp) > 0
		AEval(aButTmp,{|x,y| AAdd(aButtons,AClone(x)) })
	EndIf
EndIf

For nCount := 1 To Len(aButtons)
	cResource:= aButtons[nCount,1]
	bBloco   := aButtons[nCount,2]
	cTitle   := aButtons[nCount,3]
	oView:AddUserButton(cTitle,cResource,bBloco)
Next nCount

//--------------------------------------------------------------------
//-- DVP - Manipulação campos estrutura
//--------------------------------------------------------------------
oStrDVP:RemoveField("DVP_FILIAL")
oStrDVP:RemoveField("DVP_NUMCTC")
oStrDVP:RemoveField("DVP_IDENT")
oStrDVP:RemoveField("DVP_SERTMS")
oStrDVP:RemoveField("DVP_TIPUSO")
oStrDVP:RemoveField("DVP_FILORI")
oStrDVP:RemoveField("DVP_VIAGEM")

//--------------------------------------------------------------------
//-- DT8 - Composição Frete a Receber
//--------------------------------------------------------------------
oStrDT8:RemoveField("DT8_VALIMP")
oStrDT8:RemoveField("DT8_VALTOT")
oStrDT8:RemoveField("DT8_FILDOC")
oStrDT8:RemoveField("DT8_DOC")
oStrDT8:RemoveField("DT8_SERIE")
oStrDT8:RemoveField("DT8_ITEMD2")
oStrDT8:RemoveField("DT8_FILORI")
oStrDT8:RemoveField("DT8_NUMCOT")
oStrDT8:RemoveField("DT8_NUMAWB")
oStrDT8:RemoveField("DT8_CDRORI")
oStrDT8:RemoveField("DT8_CDRDES")
oStrDT8:RemoveField("DT8_CODPRO")
oStrDT8:RemoveField("DT8_TABFRE")
oStrDT8:RemoveField("DT8_TIPTAB")
oStrDT8:RemoveField("DT8_SEQTAB")
oStrDT8:RemoveField("DT8_DESC")
oStrDT8:RemoveField("DT8_ACRESC")
oStrDT8:RemoveField("DT8_CALMIN")
oStrDT8:RemoveField("DT8_CODCIA")
oStrDT8:RemoveField("DT8_LOJCIA")
oStrDT8:RemoveField("DT8_DIGAWB")
oStrDT8:RemoveField("DT8_PERRAT")

//--------------------------------------------------------------------
//-- DVP - Composição Frete Contrato
//--------------------------------------------------------------------
oStrDVP:RemoveField("DVP_VALIMP")
oStrDVP:RemoveField("DVP_VALTOT")

oStrDVP:AddField( ; 							// Ord. Tipo Desc.
          'DVP_DESCOM' , ; 						// [01] C Nome do Campo
          RetOrdSX3("DVP_CODPAS") , ; 			// [02] C Ordem
          STR0239 , ;				 			// [03] C Titulo do campo - Descrição componente
          STR0239 , ;				 			// [04] C Descrição do campo - Descrição componente
          Nil , ; 								// [05] A Array com Help
          'C', ; 								// [06] C Tipo do campo
          NIL , ; 								// [07] C Picture
          NIL , ; 								// [08] B Bloco de Picture Var
          '' 	, ; 							// [09] C Consulta F3
          .T. , ; 								// [10] L Indica se o campo é evitável
          NIL , ; 								// [11] C Pasta do campo
          NIL , ; 								// [12] C Agrupamento do campo
          NIL , ; 								// [13] A Lista de valores permitido do campo (Combo)
          NIL , ; 								// [14] N Tamanho Máximo da maior opção do combo
          NIL , ; 								// [15] C Inicializador de Browse
          .T. , ; 								// [16] L Indica se o campo é virtual
          NIL , ; 								// [17] cPictVar		Picture Variável
          NIL	, ; 							// [18] lInsertLine	Indica pulo de linha após o campo
          ) 									// [19] nWidth Indica a largura fixa da coluna do grid

//--------------------------------------------------------------------
//-- DT8 - Manipulação campos estrutura
//--------------------------------------------------------------------
oStrDT8:AddField( ; 							// Ord. Tipo Desc.
          'DT8_DESCOM' , ; 						// [01] C Nome do Campo
          RetOrdSX3("DT8_CODPAS") , ; 			// [02] C Ordem
          STR0239 , ;				 			// [03] C Titulo do campo - Descrição componente
          STR0239 , ;				 			// [04] C Descrição do campo - Descrição componente
          Nil , ; 								// [05] A Array com Help
          'C', ; 								// [06] C Tipo do campo
          NIL , ; 								// [07] C Picture
          NIL , ; 								// [08] B Bloco de Picture Var
          '' 	, ; 							// [09] C Consulta F3
          .T. , ; 								// [10] L Indica se o campo é evitável
          NIL , ; 								// [11] C Pasta do campo
          NIL , ; 								// [12] C Agrupamento do campo
          NIL , ; 								// [13] A Lista de valores permitido do campo (Combo)
          NIL , ; 								// [14] N Tamanho Máximo da maior opção do combo
          NIL , ; 								// [15] C Inicializador de Browse
          .T. , ; 								// [16] L Indica se o campo é virtual
          NIL , ; 								// [17] cPictVar		Picture Variável
          NIL	, ; 							// [18] lInsertLine	Indica pulo de linha após o campo
          ) 									// [19] nWidth Indica a largura fixa da coluna do grid

//--------------------------------------------------------------------
//-- SE2 - Manipulação campos estrutura
//--------------------------------------------------------------------
oStrSE2:AddField( ; 									// Ord. Tipo Desc.
				'LOG_BTSTA' , ; 						// [01] C Nome do Campo
				'02' , ; 								// [02] C Ordem
				STR0124 , ;			 					// [03] C Titulo do campo - Status financeiro
				STR0124 , ; 							// [04] C Descrição do campo - Status financeiro
				Nil , ; 								// [05] A Array com Help
				'C' , ; 								// [06] C Tipo do campo
				NIL , ; 								// [07] C Picture
				NIL , ; 								// [08] B Bloco de Picture Var
				'' , ; 									// [09] C Consulta F3
				.T. , ; 								// [10] L Indica se o campo é evitável
				NIL , ; 								// [11] C Pasta do campo
				NIL , ; 								// [12] C Agrupamento do campo
				NIL , ; 								// [13] A Lista de valores permitido do campo (Combo)
				NIL , ; 								// [14] N Tamanho Máximo da maior opção do combo
				NIL , ; 								// [15] C Inicializador de Browse
				.T. , ; 								// [16] L Indica se o campo é virtual
				NIL ) 									// [17] C Picture Variável

//--------------------------------------------------------------------
//-- DTY - Manipulação campos estrutura
//--------------------------------------------------------------------
oStrDTY:AddField( ; 									// Ord. Tipo Desc.
				'DTY_VALLIQ' , ; 						// [01] C Nome do Campo
				'99' , ; 								// [02] C Ordem
				STR0272 , 		;	 					// [03] C Titulo do campo - "Valor Líquido"
				STR0272 , ; 							// [04] C Descrição do campo - "Valor Líquido"
				Nil , ; 								// [05] A Array com Help
				'N' , ; 								// [06] C Tipo do campo
				"@E 99,999,999,999.99 ", ;				// [07] C Picture
				NIL , ; 								// [08] B Bloco de Picture Var
				'' , ; 									// [09] C Consulta F3
				.T. , ; 								// [10] L Indica se o campo é evitável
				NIL , ; 								// [11] C Pasta do campo
				NIL , ; 								// [12] C Agrupamento do campo
				NIL , ; 								// [13] A Lista de valores permitido do campo (Combo)
				NIL , ; 								// [14] N Tamanho Máximo da maior opção do combo
				NIL , ; 								// [15] C Inicializador de Browse
				.T. , ; 								// [16] L Indica se o campo é virtual
				NIL ) 									// [17] C Picture Variável


//--------------------------------------------------------------------
//-- DVP - Composição do frete
//--------------------------------------------------------------------
oView:AddGrid('VwGridDVP', oStrDVP , 'MdGridDVP')
oView:EnableTitleView('VwGridDVP',STR0045) //-- Comp. Frete

//--------------------------------------------------------------------
//-- DVP - Contadores
//--------------------------------------------------------------------
oView:AddField('VwCalcDVP' , oCalcDVP , "MdCalcDVP")
oView:EnableTitleView('VwCalcDVP', STR0271 ) //--"Totais da Composição"

//--------------------------------------------------------------------
//-- SC7 - Pedido de Compra
//--------------------------------------------------------------------
oView:AddGrid('VwGridSC7', oStrSC7 , 'MdGridSC7')
oView:EnableTitleView('VwGridSC7',STR0047 ) //-- Ped. Comp.

//--------------------------------------------------------------------
//-- SE2 - Títulos a pagar
//--------------------------------------------------------------------
If cTmsErp == "0"
	oView:AddGrid('VwGridSE2', oStrSE2 , 'MdGridSE2')
	oView:EnableTitleView('VwGridSE2',STR0134 ) //-- Títulos

     //-- Adiciona objetos na interface
     oView:AddOtherObject("OTHER_PANEL", {|oPanel| a250BUTTON(oPanel)})
EndIf

//--------------------------------------------------------------------
//-- DDN - Histórico Acrescimos/Decrescimos
//--------------------------------------------------------------------
If lTabDDN
	oView:AddGrid('VwGridDDN', oStrDDN , 'MdGridDDN')
	oView:EnableTitleView('VwGridDDN',STR0223 ) //-- Hist Acr/Decr

	//--------------------------------------------------------------------
	//-- DDN - Contadores
	//--------------------------------------------------------------------
	oView:AddField('VwCalcDDN' , oCalcDDN , "MdCalcDDN")
	oView:EnableTitleView('VwCalcDDN',STR0270) //--"Totais Acrescimo/Decrescimo"
EndIf

//--------------------------------------------------------------------
//-- DJC - Histórico Custo do Documento
//--------------------------------------------------------------------
If lTabDJC
	oView:AddGrid('VwGridDJC', oStrDJC , 'MdGridDJC')
	oView:EnableTitleView('VwGridDJC',STR0234 ) //-- Hist Custo Doc
	oView:SetViewProperty("VwGridDJC", "ENABLENEWGRID")

	//--------------------------------------------------------------------
	//-- DT8 - Componentes de frete
	//--------------------------------------------------------------------
	oView:AddGrid('VwGridDT8', oStrDT8 , 'MdGridDT8')
	oView:EnableTitleView('VwGridDT8',STR0278 ) //--"Componentes de Frete a Receber"

	//--------------------------------------------------------------------
	//-- DT8 - Contadores
	//--------------------------------------------------------------------
	oView:AddField('VwCalcDT8' , oCalcDT8 , "MdCalcDT8")
EndIf

//--------------------------------------------------------------------
//-- SDG - Movimento custo de transporte
//--------------------------------------------------------------------
oView:AddGrid('VwGridSDG', oStrSDG , 'MdGridSDG')
oView:EnableTitleView('VwGridSDG',STR0122 ) //-- Movimento custo de transporte

//--------------------------------------------------------------------
//-- DTY - Complemento de contrato
//--------------------------------------------------------------------
oView:AddGrid('VwGridDTY', oStrCompl , 'MdGridDTY')
oView:EnableTitleView('VwGridDTY',STR0068 ) //-- Complemento

//--------------------------------------------------------------------
//-- DUA - Registro de ocorrencias
//--------------------------------------------------------------------
If lTabDUA
	oView:AddGrid('VwGridDUA', oStrDUA , 'MdGridDUA')
	oView:EnableTitleView('VwGridDUA',STR0275 ) //-- Ocorrencias do contrato
EndIf

oview:showInsertMsg(.F.)

//--------------------------------------------------------------------
//-- Boxes de tela
//--------------------------------------------------------------------
oView:CreateHorizontalBox('CABECALHO', 45 )
oView:CreateHorizontalBox('GRID', 55)

//-- Folders
oView:CreateFolder('PASTAS','GRID')

//-- Pastas nos folders
oView:AddSheet('PASTAS','ABA01', STR0045) //-- Comp. Frete
oView:AddSheet('PASTAS','ABA02', STR0047) //-- Ped.Comp.
If cTmsErp == "0"
	oView:AddSheet('PASTAS','ABA03', STR0134) //-- Títulos
EndIf
If lTabDDN
	oView:AddSheet('PASTAS','ABA04', STR0223) //-- Hist Acr/Decr
EndIf
oView:AddSheet('PASTAS','ABA05', STR0234) //-- Hist Custo Doc
oView:AddSheet('PASTAS','ABA07', STR0122) //-- Movimento do custo de transporte
oView:AddSheet('PASTAS','ABA08', STR0068) //-- Complemento

If lTabDUA
	oView:AddSheet('PASTAS','ABA09',STR0275 ) //-- Ocorrencias do Contrato
EndIf

//-- Composição do frete
oView:CreateHorizontalBox('BOX01',65,,,'PASTAS','ABA01')
oView:CreateHorizontalBox('BOX02',35,,,'PASTAS','ABA01')

//-- Ped. Compra
oView:CreateHorizontalBox('BOX03',100,,,'PASTAS','ABA02')

//-- Títulos
If cTmsErp == "0"
	oView:CreateVerticalBox('BOX04',90,,,'PASTAS','ABA03')
	oView:CreateVerticalBox('BOX05',10,,,'PASTAS','ABA03')
EndIf

//-- Hist Acr/Decr
If lTabDDN
	oView:CreateHorizontalBox('BOX06',60,,,'PASTAS','ABA04')
	oView:CreateHorizontalBox('BOX07',40,,,'PASTAS','ABA04')
EndIf

//-- Hist Custo Doc
If lTabDJC
	oView:CreateVerticalBox('BOX08',60,,,'PASTAS','ABA05')

	//-- Componentes de Frete e Totalizadores
	oView:CreateVerticalBox('BOX12',40,,,'PASTAS','ABA05')

	oView:CreateHorizontalBox('BOX14',70,"BOX12",,'PASTAS','ABA05')
	oView:CreateHorizontalBox('BOX15',30,"BOX12",,'PASTAS','ABA05')
EndIf

//-- Movimento do custo de transporte
oView:CreateHorizontalBox('BOX10',100,,,'PASTAS','ABA07')

//-- Complemento
oView:CreateHorizontalBox('BOX11',100,,,'PASTAS','ABA08')

//-- Registro de ocorrencias
If lTabDUA
	oView:CreateHorizontalBox('BOX13',100,,,'PASTAS','ABA09')
EndIf

//--------------------------------------------------------------------
//-- Define visões
//--------------------------------------------------------------------
oView:SetOwnerView('VwFieldDTY','CABECALHO')
oView:SetOwnerView('VwGridDVP','BOX01')
oView:SetOwnerView('VwCalcDVP','BOX02')
oView:SetOwnerView('VwGridSC7','BOX03')
If cTmsErp == "0"
	oView:SetOwnerView('VwGridSE2','BOX04')
	oView:SetOwnerView('OTHER_PANEL','BOX05')
EndIf
If lTabDDN
	oView:SetOwnerView('VwGridDDN','BOX06')
	oView:SetOwnerView('VwCalcDDN','BOX07')
EndIf
If lTabDJC
	oView:SetOwnerView('VwGridDJC','BOX08')
	oView:SetOwnerView('VwGridDT8','BOX14')
	oView:SetOwnerView('VwCalcDT8','BOX15')
EndIf
oView:SetOwnerView('VwGridSDG','BOX10')
oView:SetOwnerView('VwGridDTY','BOX11')
If lTabDUA
	oView:SetOwnerView('VwGridDUA','BOX13')
EndIf

// ---------------------------------------------------------------
// Action para DTY
// ---------------------------------------------------------------
oView:SetFieldAction( 'DTY_VALFRE', { |oView,cIdForm,cIdCampo,cValue| TMA250Action(oView,cIdForm,cIdCampo,cValue) } )

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return oView

/*
================================================================================================================
/{Protheus.doc} DTYVFields
//TODO : Validação de Campos do DTY para a opção de complemento de frete.
@author  tiago.dsantos
@since   22/02/2017
@version 1.0
@param   oModel: Model do MVC do TMSA250
@type function
================================================================================================================
/*/
Static Function TMA250Action(oView,cIdForm,cIdCampo,cValue)
Local lRet := .T.

     //| Controla a chamada da Integração que recupera o imposto
     //| a variável private lImpRecalc funciona como um sinalizador
     //| que indica se deve ou não chamar a integração pelo commit do MVC, se houver mudança do valor do frete sem recalcular
     //| o imposto o recalculo será realizado na confirmação do complemento.
     If cIdCampo == "DTY_VALFRE"
          If cValue > 0
               If nDTYValFre <> cValue
                    lImpRecalc := .F.
                    nDTYValFre := cValue //| guarda o valor digitado...
               EndIf
          EndIf
     EndIf

Return lRet

//-----------------------------------------------------------------
/* Retorna as operações disponiveis para a Identificacao de Produto
@author  	Leandro Paulino
@version 	P12 R12.1.16
@Param		Parametros do array artoina
				1. Nome a aparecer no cabecalho
				2. Nome da Rotina associada
				3. Reservado
				4. Tipo de Transacao a ser efetuada:
					1 - Pesquisa e Posiciona em um Banco de Dados
					2 - Simplesmente Mostra os Campos
					3 - Inclui registros no Bancos de Dados
					4 - Altera o registro corrente
					5 - Remove o registro corrente do Banco de Dados
				5. Nivel de acesso
				6. Habilita Menu Funcional
@since 		12/09/2016
@return 	aRotina - Array com as opçoes de Menu */
//-----------------------------------------------------------------
Static Function MenuDef(lLibCTC,lTMSOPdg)
Local cFiltro     := ""
Local aCheque     := {}
Local aGereCTC    := {}
Local aPgtSld     := {}
Local cTMSOpDg	  := SuperGetMv("MV_TMSOPDG", .F., .F.)	// Indica se a integração com Operadoras de Frota está ativa. 0=Não utiliza, 1=Somente Vale-Pedágio e 2=Vale Pedágio e Frota.

Private cCadastro := STR0001 //"Contrato de Carreteiro"
Private aRotina   := {}

Default lLibCTC   :=.F.
Default lTMSOPdg  :=.F.

ADD OPTION aRotina Title STR0002 		Action 'AxPesqui' 			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0003  		Action 'VIEWDEF.TMSA250'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0008   		Action 'Tmsa250Mnt' 		OPERATION 3 ACCESS 0 //"Por Viagem"
ADD OPTION aRotina Title STR0009 		Action 'Tmsa250Mnt' 		OPERATION 3 ACCESS 0 //"Por Período"
ADD OPTION aRotina Title STR0005 		Action 'A250ExcCtc'			OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title STR0068		Action 'TMSA250Com' 		OPERATION 4 ACCESS 0 //"Complemento"
If lObsDTY
	ADD OPTION aRotina Title STR0137		Action 'TMSA250Obs(3)' 		OPERATION 4 ACCESS 0 //"Observação"
EndIf
If cTmsErp == '0'
	Aadd(aPgtSld,{STR0180,'TMSA250Sub(3)' ,0,4,0,NIL})		//-- "Confirmar"
	Aadd(aPgtSld,{STR0179,'TMSA250Sub(4)' ,0,5,0,NIL})		//-- "Estornar"
	AAdd(aRotina, {STR0069 ,aPgtSld,0,9})					//"Pagto Saldo"
ElseIf cTmsErp == '1'
	AAdd(aRotina, {STR0069 ,"TMSA250Sub(3)",0,4})			//"Pagto Saldo"
EndIf

If cTmsErp == '0'
	AAdd(aCheque, {STR0070 ,"TMSA250Sub(1)",0,2})			//"Informa Cheque"
	AAdd(aCheque, {STR0071 ,"TMSA250Sub(2)",0,7})			//"Imprime Cheque"
	AAdd(aRotina, {STR0139 ,aCheque,0,7})  					//"Cheque"
EndIf

If lLibCTC .Or. lTMSOPdg								//-- Operadora de Frota por enquanto, so TMS
	Aadd(aRotina,{STR0088,'TMSA250Leg',0,6})			//-- "Legenda"

	If lTMSOPdg
		Aadd(aGereCTC,{STR0089,'TMARepRast',0,3,0,NIL})	//-- "Rastrear"
	EndIf
	Aadd(aGereCTC,{STR0124,'TMSA250VBx'		,0,1,0,NIL})//-- "Status Financeiro"

	Aadd(aGereCTC,{STR0160,'A250BlqPg' ,0,1,0,NIL})		//-- "Bloqueio o Pagamento do Contrato"
	Aadd(aGereCTC,{STR0161,'A250LibPg' ,0,1,0,NIL})		//-- "Libera Pagto."
	Aadd(aGereCTC,{STR0162,'A250HisBlq',0,1,0,NIL})		//-- ""Histórico Blq."

	AAdd(aRotina, {STR0140, aGereCTC,0,8}) 				//"Gerir CTC"
EndIf
If ExistFunc("TMSA256")
	Aadd(aRotina,{STR0237,'TMSA256()',0,12,0,.F.}) //-- "Encerra Ciot"
EndIf
If cTMSOpDg $ "1,2" .AND. ExistFunc("TMSA161") // Vale Pedágio e Frota
	AAdd(aRotina, {STR0301, "TMSA161", 0, 12, 0, .F.})  //"Troca de cartão"
EndIf

If lTM250MNU
	ExecBlock("TM250MNU",.F.,.F.)
EndIf

Return(aRotina)


//-----------------------------------------------------------------
/* PosVldMdl()
	Efetua a validação do modelo assim como inclusão e exclusão de
	  registros nas tabelas relacionadas ao contrato de carreteiro.
@author  	Leandro Paulino
@version 	P12 R12.1.16
@since 		12/09/2016
@return 	aRotina - Array com as opçoes de Menu */
//-----------------------------------------------------------------
Static Function PosVldMdl(oModel)
Local lRet			:= .T.
Local nOpcx			:= 0
Local lTM250VIS		:= ExistBlock('TM250VIS')
Local lTM250TOK		:= ExistBlock('TM250TOK')
Local lRetPE		:= .T.
Local lComplemento	:= IsInCallStack("TMSA250Com")
Local oMdlPeriodo	:= Nil
Local oMdlComplem	:= Nil
Local oMdlField		:= Nil
Local nCount		:= 1
Local lContinua		:= .T.
Local aSaveLines 	:= FWSaveRows()
Local aArea			:= GetArea()
Local aAreaDTY		:= DTY->(GetArea())
Local cTmsErp 	   	:= SuperGetMV("MV_TMSERP",,'0') //  Verifica se o TMS está integrado com o Protheus ou Outro ERP
Local cFilOri		:= ""
Local cViagem		:= ""
Local cNumCTC		:= ""

Private cTimeIni	:= Time()

Default oModel := FwModelActive()

nOPcX := oModel:GetOperation()
Begin Transaction

If nOPcX == MODEL_OPERATION_DELETE

	oMdlField	:= oModel:GetModel("MdFieldDTY")

	//-- Tratamento para contratos gerados por periodo
	oMdlPeriodo		:= oModel:GetModel("MdGrid2DTY")
	oMdlPeriodo:SetOnlyQuery( .F. )

	oMdlComplem		:= oModel:GetModel("MdGridDTY")

	If oMdlField:GetValue("DTY_TIPCTC") <> "5"
		oMdlComplem:SetOnlyQuery( .F. )
	EndIf

	//-- Se o Contrato fora gerado em um CIOT por Periodo, não poderá estorná-lo se houver outro em aberto.
	DTR->(DbSetOrder(1))
	If AliasInDic("DJL") .And. DTR->(MsSeek(xFilial('DTR')+ oMdlField:GetValue("DTY_FILORI")+oMdlField:GetValue("DTY_VIAGEM") )) .And. ;
	   DTR->(ColumnPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2" .And. DTR->(ColumnPos('DTR_CIOT'))> 0 .And. !Empty(DTR->DTR_CIOT)

		cQuery := " SELECT DJL_CIOT,"
		cQuery += "        DJL_CODVEI, "
		cQuery += "        DJL_DATINI, "
		cQuery += "        DJL_DATFIM, "
		cQuery += "        DJL_STATUS  "
		cQuery += " FROM " + RetSqlName("DJL")
		cQuery += " WHERE  DJL_CODVEI = '"+oMdlField:GetValue("DTY_CODVEI")+"'"
		cQuery += " AND    DJL_CIOT  <> '"+DTR->DTR_CIOT  +"'"
		cQuery += " AND    DJL_STATUS = '"+StrZero(1,Len(DJL->DJL_STATUS))+"'"
		cQuery += " AND    DJL_FILIAL = '" +xFilial("DJL") +"'"
		cQuery += " AND    D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		cAliasQry := GetNextAlias()
		aAreaAux := GetArea()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof() .And. !Empty(DJL_CIOT))
			Help('',1,'TMSA250K7') //-- "Não é possível estornar contrato gerado com CIOT por período. Existe um CIOT por período em aberto para o veiculo"
			lRet:= .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
		RestArea(aAreaAux)
	EndIf
	If lTM250TOK
		lRet := ExecBlock('TM250TOK',.F.,.F.)
		If ValType(lRet) <> 'L'
			lRet := .T.
		EndIf
	EndIf

	If lRet

		//************************************************
		//-- Valida contrato principal
		//************************************************
		cFilOri	:= oMdlField:GetValue("DTY_FILORI")
		cViagem	:= oMdlField:GetValue("DTY_VIAGEM")
		cNumCTC	:= oMdlField:GetValue("DTY_NUMCTC")

		DTY->(dbSetOrder(2)) //-- FILIAL + FILORI + VIAGEM + NUMCTC
		If DTY->(MsSeek( xFilial("DTY") + cFilOri + cViagem + cNumCTC ))
			lRet	:= A250VldDel()
		Else
			lRet	:= .F.
		EndIf

		//************************************************
		//-- Valida contratos complementares
		//************************************************
		For nCount := 1 To oMdlComplem:Length()

			If lRet .And. !Empty( oMdlComplem:GetValue("DTY_NUMCTC") )

				cFilOri	:= oMdlComplem:GetValue("DTY_FILORI")
				cViagem	:= oMdlComplem:GetValue("DTY_VIAGEM")
				cNumCTC	:= oMdlComplem:GetValue("DTY_NUMCTC")

				If DTY->(MsSeek( xFilial("DTY") + cFilOri + cViagem + cNumCTC ))
					lRet	:= .F.
					Help('',1,'TMSA25052') //-- Contrato não será excluído pois possui contrato complementar vinculado a ele.
					Exit
				EndIf

			EndIf

		Next nCount

		//************************************************
		//-- Valida contratos do mesmo periodo
		//************************************************
		For nCount := 1 To oMdlPeriodo:Length()

			If lRet .And. !Empty( oMdlPeriodo:GetValue("DTY_NUMCTC") )

				cFilOri	:= oMdlPeriodo:GetValue("DTY_FILORI")
				cViagem	:= oMdlPeriodo:GetValue("DTY_VIAGEM")
				cNumCTC	:= oMdlPeriodo:GetValue("DTY_NUMCTC")

				If DTY->(MsSeek( xFilial("DTY") + cFilOri + cViagem + cNumCTC ))
					lRet	:= A250VldDel()
				EndIf
			EndIf

		Next nCount
		//--Excluir a Observacao do Contrato
		If DTY->(ColumnPos("DTY_CODOBS")) > 0 .And. !Empty(DTY->DTY_CODOBS)
			MSMM(DTY->DTY_CODOBS,,,,2,,,"DTY","DTY_CODOBS")
		EndIf
	EndIf
Else

	//-- Complemento de contrato
	If lComplemento
		lRet	:= A250ComVld(oModel,nOpcX)
	EndIf

Endif

If lTM250VIS .And. lRet
	lRetPE:= ExecBlock('TM250VIS',.F.,.F.,{nOPcX})
	If ValType(lRetPE) == 'L'
		If !lRetPE
			lRet	:= .F.
		EndIf
	EndIf
EndIf

If !lRet
	DisarmTransaction()
EndIf

End Transaction

FWRestRows( aSaveLines )
RestArea(aAreaDTY)
RestArea(aArea)

lContGerado := .F.

Return lRet

/*/{Protheus.doc} A250VldDel
//TODO Valida a deleção do contrato posicionado
@author caio.y
@since 10/01/2017
@version undefined

@type function
/*/
Static Function A250VldDel()
Local lRet			:= .T.
Local cTmsErp 	   	:= SuperGetMV("MV_TMSERP",,'0') //  Verifica se o TMS está integrado com o Protheus ou Outro ERP
Local aArea			:= GetArea()
Local cFilOri		:= ""
Local cViagem		:= ""
Local cContrat		:= ""
Local cCodForn		:= ""
Local cLojForn		:= ""
Local lF12			:= .F.
Local aAreaDTY		:= DTY->(GetArea())
Local lLibCTC     	:= SuperGetMV('MV_LIBCTC',, .F.)
Local lTMSOPdg      := SuperGetMV('MV_TMSOPDG' ,,'0') == '2'
Local aMsgErr    	:= {}
Local aVisErr    	:= {}
Local cPrefixo 		:= TMA250GerPrf(cFilAnt)


cFilOri  	:= DTY->DTY_FILORI
cContrat 	:= DTY->DTY_NUMCTC
cViagem 	:= DTY->DTY_VIAGEM

If !TMSChkViag( cFilOri, cViagem, .F., .F., .F., , , , , .F., .T., , .F., .F., , , , ,)
	RestArea(aAreaDTY)
	Return .F.
EndIf

//-- Checa o Status do Contrato de Carreteiro
If lLibCTC .Or. lTMSOPdg
	If DTY->DTY_STATUS == '5' .Or. DTY->DTY_STATUS == 'A' .Or.;
	   (lLibCTC .And. DTY->DTY_CODOPE == '02' .And. DTY->DTY_STATUS == '3') .Or.; //-- Contrato Quitado ou Contrato Pamcard já liberado para pagamento.
	   (DTY->DTY_CODOPE == '01' .And. DTY->DTY_STATUS $ '8|B')    //-- Contrato Quitado (filial ou posto) ou Contrato Repom já liberado para pagamento.
		Help('',1,'TMSA25025') // 'Contrato nao podera ser excluido, pois ja foi Quitado'
		lRet	:= .F.
	EndIf
EndIf

If lRet

	//-- Se o Contrato de Carreteiro tem Pedido de Compra vinculado, verificar se o Ped. de compra
	//-- foi baixado; Se sim, nao permitir a exclusao do contrato de carreteiro
	If cTmsERP == "0"
		If !Empty(DTY->DTY_NUMPC)
			SC7->(dbSetOrder(1))
			If SC7->(MsSeek(xFilial('SC7')+ DTY->DTY_NUMPC)) .And. SC7->C7_QUJE > 0
				AAdd( aMsgErr, { STR0018 + DTY->DTY_NUMPC + STR0019 + cContrat + STR0020, '01', "MATA121()" } ) //"Pedido de Compra no. : " ### " ja foi baixado. O Contrato de Carreteiro no.: " ### ", nao sera excluido."
				Return .F.
			EndIf
		EndIf
	EndIf

	//-- Se for Contrato de Premio de Motorista Proprio, verificamos se o periodo da folha esta em aberto,
	// se estiver,  subtraimos o valor do premio do arquivo de Movimento Mensal da Folha de Pagamento (RGB)
	If !A250DelCPR( DTY->DTY_TIPCTC , DTY->DTY_CODMOT , DTY->DTY_VALPRE , @aMsgErr) //--Função para substrair o valor do prêmio para o motorista próprio
		Return .F.
	EndIf

	If cTmsERP == "0" .And. lRet

		If TMSA250VerBai(cPrefixo, DTY->DTY_NUMCTC, DTY->DTY_CODFOR, DTY->DTY_LOJFOR)
			lRet	:= .T.
		Else
			lRet	:= .F.
			AAdd( aMsgErr, { STR0021 +cPrefixo+"/"+cContrat, '01', "FINA080()" } ) //"Titulo Baixado ... No. do  Titulo : "
		EndIf

	EndIf

EndIf


//-- Carrega o Array com as mensagens de Erro
AaddMsgErr( aMsgErr, aVisErr )
If !Empty( aVisErr )
	TmsMsgErr( aVisErr )
	lRet := .F.
EndIf

RestArea(aAreaDTY)
RestArea(aArea)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250DelSDG³ Autor ³Guilherme R. Gaiofatto ³ Data ³19.12.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta SDG Gerada por DTY e pelo DTR que não movta. banco.  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250DelSDG(ExpC1,ExpC2,ExpC3,ExpC4,Expc5,Expc6,Expc7,Expc8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial de Origem da Viagem                          ³±±
±±³          ³ExpC2 - Codigo da Viagem       			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function A250DelSDG(cFilori,cViagem,cCodVei, cPrefixo, cCodFor, cLojFor, cCodFav, cLojFav)

Local aArea		:= {}
Local aAreaSDG	:= {}
Local cSeek		:= ''
Local lRet			:= .F.
Local cAlias		:= Iif(IsInCallStack('TMSA310Est'),'DTR','DTY')

Default cFilOri  := ''
Default cViagem  := ''
Default cCodVei  := ''
Default cPrefixo := ''
Default cCodFor  := ''
Default cLojFor  := ''
Default cCodFav  := ''
Default cLojFav  := ''

	aArea	  := GetArea()
	aAreaSDG := SDG->(GetArea())

	SDG->(DbSetOrder(5))
	If SDG->( DbSeek(cSeek := xFilial('SDG')+cFilori+cViagem+cCodVei) )
		Do While SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeek
			lRet := .F.
			If SDG->DG_ORIGEM == 'DTY' .And. cAlias == 'DTY'
				If !Empty(SDG->DG_BANCO)
					lRet := TMA250DelTit(cPrefixo, cViagem,,cCodFor, cLojFor, cCodFav, cLojFav, '', 1)
				Else
					lRet := .T.
				EndIf
			ElseIf SDG->DG_ORIGEM == 'DTR' .And. cAlias == 'DTR' .And. IIf(cTmsErp<>'1',EMPTY(SDG->DG_BANCO),Posicione('DT7',1,FwxFilial('DT7')+SDG->DG_CODDES,"DT7_MOVBCO") <> '1')
				lRet := .T.
			EndIf
			If lRet
				RecLock('SDG',.F.)
				SDG->(dbDelete())
				MsUnLock()
			EndIf
			SDG->(dbSkip())
		Enddo
	EndIf

	RestArea(aArea)
	RestArea(aAreaSDG)

Return Nil

//-----------------------------------------------------------------
/* {Protheus.doc}TMsa250Mnt
Manutenção do contrato de carreteiro
@author  	Patricia A. Salomao
@version 	P12 R12.1.16
@Param		Parametros do array artoina
				ExcpC1 	= Alias dno Arquivo
				Expn1 	= Numero do registro
				Expn2 	= Opção Selecionada
				ExpL1 	= lReserv
				Expl2 	= Verifica se devera confirmar antes da geração do contrato
				Expl3	= Viagem Express
@since 		12/09/2016
@return 	aRotina - Array com as opçoes de Menu */
//-----------------------------------------------------------------
Function TMSA250Mnt(cAlias,nReg, nOpcx,lReserv,lConfirma,lVgeExpr,lIntegra,cGerar)

Local oDlg
Local aSays      := {}
Local aButtons   := {}
Local aRet       := {}
Local aMsgErr    := {}
Local nOpca      := 0
Local lRet       := .T.
Local cPrefixo   := ""
Local cCodForn   := ""
Local cLojForn   := ""
Local cFilOri    := ""
Local cViagem    := ""
Local aArea      := GetArea()
Local aAreaDTY   := DTY->(GetArea())
Local nIndex
Local cSeek
Local aVisErr    := {}
Local aSetKey    := {}
Local lAglutina
Local lDigita
Local nCntFor
Local lTM250Est  := ExistBlock('TM250EST')
Local lTM250Peri := ExistBlock('T250PER')
Local cQuery     := ''
Local lLibCTC    := SuperGetMV( 'MV_LIBCTC',, .F. )
Local lTMSOPdg   := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local lRepom     := SuperGetMV('MV_VSREPOM',,'1') == '2'
Local aMovtos    := {}
Local cRetPE     := ""
Local cFiltro    := ""
Local cTabCTC    := ""
Local cArqCTC    := ""
Local cFilSav    := cFilAnt // Salvando a Filial Original
Local aCabec     := {}
Local lTpFrota   := DTY->(ColumnPos("DTY_TIPFRO")) > 0
// Inicio Redespacho
Local lTabDDH	 	:= AliasIndic("DDH")
// Fim Redespacho
Local cTXTLG250   	:= ""
Local _nX			:= 0
Local lPreview    	:= .F.
Local cTipCTC    	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Local cTipPdg    	:= Padr( GetMV("MV_TPTPDG"), Len( SE2->E2_TIPO ) )    // Tipo Pedagio
Local lFrotaProp    := .F.
Local lTms152       := .f.
Local aCTCGer	 	:= {}

Default cAlias	  	:= ""
Default nReg		:= 0
Default lReserv   	:= .T.
Default lConfirma 	:= .T.
Default lVgeExpr  	:= .F.
Default lIntegra  	:= .T. //| Contrato por periodo precisa deste controle, devido o mvc chamar no posvalid varias vezes a rotina a 250mnt na exclusão.
Default cGerar 	  	:= ''
// Inicio Redespacho
Private aRota     := {}
Private aDocto    := {}
// Fim Redespacho

Private lExibeLanc := .F.
Private lOnline    := .F.
Private cContrat
Private aTela[0][0]
Private aGets[0]
Private nHdlPrv				// Endereco do arquivo de contra prova dos lanctos cont.
Private cLoteCTC			// Numero do lote para lancamentos do TMS
Private cArquivo			// Nome do arquivo contra prova
Private nTotal      := 0	// Total dos lancamentos contabeis
Private aRecSDGBai  := {}	// Contabiliza a partir da Baixa da Despesa
Private aRecSDGEmi  := {}	// Contabiliza a partir da Emissao da Despesa
Private lCriaHeader := .T.	// Para criar o header do arquivo Contra Prova
Private lMsErroAuto := .F.
Private aMsgErPa    := {} //--> Array com mensagem de LOG de Processamento.
Private oDTClass    := NIL

Private aMsgErPa	:= {} //--> Array com mensagem de LOG de Processamento.

If cGerar == '1'
	lContGerado := .F.
EndIf

If !lContGerado
	//|
	//| Valida se existe a classe de integração EAI Contas Pagar
	If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
		oDTClass := TransportDocumentClass():New()
	EndIf

	If cTmsErp == '0' //--Faz validações necessárias para geração de títulos no SIGAFIN
		A250VldNat(@cTipCTC,@cNatuPDG,@cNatuDeb)

		If lExcSched250
			GerLogPerg("TM250A")
		EndIf

		If !TMA250Param(.F.,cNatuPDG,cNatuDEB,cTipPdg,cTipCTC)
			TMS250LOG(aMsgErPa) //--> Grava Log de processamento.
			Return( .F. )
		EndIf

	EndIf

	If nOpcx == 3  // Gerar Contrato Por Viagem ou Carga
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as perguntas selecionadas                            ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ mv_par01 - Viagem De ? ou Carga de ?                         ³
		//³ mv_par02 - Viagem Ate ? ou Carga Ate ?                       ³
		//³ mv_par03 - Mostra lancamentos contabeis    ?                 ³
		//³ mv_par04 - Aglutina lancamentos contabeis  ?                 ³
		//³ mv_par05 - Tipo da Frota      ?                              ³
		//³ mv_par06 - Contabiliza on Line ?                             ³
		//³ mv_par07 - Gera Contratos para ?                             ³
		//³ mv_par08 - Filial Origem       ?                             ³
		//³ mv_par09 - Exibe Preview Calculo ?                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        If ValType(cFilAnt) == 'C'
			SetMvValue("TMA250", "MV_PAR08", cFilAnt)
        EndIf

		Pergunte("TMA250",.F.,,,,,.F.)

		//-- Ponto de entrada utilizado para trocar o conteudo dos perguntes, criado p/ o Redespacho.
		If lTM250PER
			ExecBlock('TM250PER',.F.,.F.)
		EndIf

		If cTmsErp == '0'
			lExibeLanc := Iif(mv_par03 == 2,.F.,.T.)
			lOnline    := Iif(mv_par06 == 2,.F.,.T.)
		EndIf
		If lTabDDH .And. Type('mv_par09') == 'N'
			lPreview   := Iif(mv_par09 == 1,.T.,.F.)
		EndIf

		If lConfirma //-- Verifica se devera confirmar tela

			Aadd( aSays, STR0006 ) //"Este programa tem como finalidade gerar os Contratos de Carreteiro"
			Aadd( aSays, STR0010 ) //"levando-se em consideracao o Intervalo de Viagem Informado ..."
			Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
			Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
			Aadd( aButtons, { 5, .T., {|| Pergunte("TMA250",.T.) } } )

			FormBatch( cCadastro, aSays, aButtons )
		Else
			nOpca := 1
		EndIf

		If nOpca == 1

			//----------------------------------------------------------------
			//-- Tratamento Ocorrencias Receita/Despesa
			//-- Gera Contratos Complementares Conforme Ocorrencias DUA
			//----------------------------------------------------------------
			If lConfirma .And. DUA->(ColumnPos("DUA_CODFOR")) > 0 .And. FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA360")
				//-- Verifica Se Existem Registros Disponíveis Para Processamento No TMSA152
				lTms152 := Tm250To152()
			EndIf

			If !lTms152
				Processa({|lEnd| lRet := TMSA250Prc(cAlias, nOpcx, , , , , aVisErr, mv_par07,,,,lVgeExpr, lPreview,cTipCTC,@aCTCGer)},STR0001,STR0007,.F.) //"Contrato de Carreteiro"###"Gerando os Contratos de Carreteiros ..."]
			EndIf
		Else
			lRet := .F.
		EndIf

	ElseIf nOpcx == 4 // Gerar Contrato Por Periodo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as perguntas selecionadas                            ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ mv_par01 - Servico de Transp. ? Coleta/Transp./Entrega/Todos ³
		//³ mv_par02 - Periodo De         ?                              ³
		//³ mv_par03 - Periodo Ate        ?                              ³
		//³ mv_par04 - Fornecedor De      ?                              ³
		//³ mv_par05 - Loja De            ?                              ³
		//³ mv_par06 - Fornecedor Ate     ?                              ³
		//³ mv_par07 - Loja Ate           ?                              ³
		//³ mv_par08 - Quebra por Veiculo ?                              ³
		//³ mv_par09 - Mostra lancamentos contabeis    ?                 ³
		//³ mv_par10 - Aglutina lancamentos contabeis  ?                 ³
		//³ mv_par11 - Gera Contrato      ?                              ³
		//³ mv_par12 - Tipo da Frota      ?                              ³
		//³ mv_par13 - Contabiliza on Line ?                             ³
		//³ mv_par14 - Gera Contratos para ?                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//--> Caso a execução seja via SCHEDULE, não seta a pergunta TM250A.
		If !lExcSched250
			Pergunte("TM250A",.F.)
		EndIf

		//--> Gera no LOG de processamento os parametros definidos na configuração do SCHEDULE TMSA250()
		If lExcSched250
			MV_PAR09 := 2 //--> Força o parametro MV_PAR09 (Mostra Lançamento Contábeis)  estar sempre como 2 = NÃO.
		EndIf

		//-- Ponto de entrada utilizado para trocar o conteudo dos perguntes, criado p/ o Redespacho.
		If lTM250PER
			ExecBlock('TM250PER',.F.,.F.)
		EndIf
		If cTmsErp == '0'
			lExibeLanc := Iif(mv_par09 == 2,.F.,.T.)
			lOnline    := Iif(mv_par13 == 2,.F.,.T.)
		EndIf
		Aadd( aSays, STR0006 ) //"Este programa tem como finalidade gerar os Contratos de Carreteiro"

		lConfirma := IIf(lExcSched250,.F.,.T.)	//--> Caso a rotina seja SCHEDULE não será necessário confirmar tela.I
		If lConfirma //-- Verifica se devera confirmar tela
			Aadd( aSays, STR0011 ) //"das Viagens Encerradas levando-se em consideracao o periodo"
			Aadd( aSays, STR0012 ) //"Informado."

			Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
			Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
			Aadd( aButtons, { 5, .T., {|| Pergunte("TM250A",.T.) } } )

			FormBatch( cCadastro, aSays, aButtons )
		Else
			nOpca := 1
		EndIf

		If nOpca == 1

			cTabCTC := "DTQ"
			cFiltro := "DTQ_FILIAL == '"+xFilial( "DTQ" )+"' .And. DTQ_STATUS == '"+'3'+ "' .And. DTQ_FILORI == '" +cFilAnt+ ;
					"'.And. DTOS(DTQ_DATENC) >= '"+DTOS(mv_par02)+"' .And. DTOS(DTQ_DATENC) <= '"+DTOS(mv_par03)

			dbSelectArea(cTabCTC)

			DTQ->(dbSetOrder(2)) //DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA

			cArqCTC := CriaTrab(Nil,.F.)

			If mv_par01 == 1  //-- Coleta
				cFiltro += "' .And. " +cTabCTC+ "_SERTMS=='1'"
			ElseIf mv_par01 == 2  //-- Transporte
				cFiltro += "' .And. " +cTabCTC+ "_SERTMS=='2'"
			ElseIf mv_par01 == 3  //-- Entrega
				cFiltro += "' .And. " +cTabCTC+ "_SERTMS=='3'"
			Else  //-- Todos
				cFiltro += "' .And. (" +cTabCTC+ "_SERTMS=='1' .Or. " +cTabCTC+ "_SERTMS=='2' .Or. " +cTabCTC+ "_SERTMS=='3')"
			EndIf

			//-- PE permite alterar filtro padrao na geracao de contrato carreteiro por periodo
			If lTM250IND
				cRetPE := ExecBlock("TM250IND",.F.,.F.,{cFiltro})
				If ValType(cRetPE) == "C"
					cFiltro := cRetPE
				EndIf
			EndIf

			//	IndRegua(cTabCTC,cArqCTC,IndexKey(),,cFiltro,STR0013) //"Selecionando Documentos ..."

			//--> Caso a rotina esteja sendo executada via SCHEDULE, não será apresentada a regua de processamento.
			IndRegua(cTabCTC,cArqCTC,IndexKey(),,cFiltro,STR0013,IIf(lExcSched250,.F.,.T.)) //"Selecionando Documentos ..."

			nIndex := RetIndex(cTabCTC)+1
			#IFNDEF TOP
				dbSetIndex(cArqCTC+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndex+1)
			dbGoTop()
			If Eof()
				If lExcSched250
					cTXTLG250 		:= STR0191 //--> Nao existe registro relacionado a este codigo
					A250MsgAdd(cTXTLG250,"TMSA250")
				Else
					Help("",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
				EndIf
				TMS250LOG(aMsgErPa)
				Return ( .F. )
			EndIf

			If lExcSched250
				//--> VERIFICAR QUAIS SÃO OS PARAMETROS DO BATCHPROCESS
				BatchProcess(STR0001, STR0007 , "TMA490" , { || TMSA250Prc(cAlias, nOpcx, , , , , aVisErr, mv_par14, , , ,lVgeExpr, lPreview,cTipCTC,@aCTCGer) } )  //"Contrato de Carreteiro"###"Gerando os Contratos de Carreteiros ..."
			Else

				Processa({|lEnd| lRet := TMSA250Prc(cAlias, nOpcx, , , , , aVisErr, mv_par14, , , ,lVgeExpr, lPreview,cTipCTC ,@aCTCGer)},STR0001,STR0007,.F.) //"Contrato de Carreteiro"###"Gerando os Contratos de Carreteiros ..."

			EndIf

			If lExcSched250	//--> Se execução não for via SCHEDULE apresenta tela de com erros, caso seja SCHEDULE gera log.
				If Len(aVisErr) > 0
					For _nX := 1 To Len(aVisErr)
						AADD(aMsgErPa, {aVisErr[_nX,1],aVisErr[_nX,2],aVisErr[_nX,3]})
					Next
				EndIf
				TMS250LOG(aMsgErPa)
			Else
				If ! Empty( aVisErr )
					TmsMsgErr( aVisErr )
					lRet := .F.
				EndIf
			EndIf

			DbSelectArea( cTabCTC )
			RetIndex( cTabCTC )
			If File(cArqCTC+OrdBagExt())
				FErase(cArqCTC+OrdBagExt())
			EndIf
		Else
			lRet := .F.
		EndIf
		DbClearFilter()

	ElseIf nOpcx == 5 // Deletar

		//Verifica se o TMS estiver vinculado ao ERP Protheus
		If cTmsErp == '0'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega as perguntas selecionadas                            ³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³ mv_par01 - Mostra lancamentos contabeis    ?                 ³
			//³ mv_par02 - Aglutina lancamentos contabeis  ?                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Pergunte("TM250D",.F.)
			lExibeLanc := Iif(mv_par01 == 2,.F.,.T.)
			lOnline    := Iif(mv_par03 == 2,.F.,.T.)
			Aadd(aSetKey, { VK_F12 , { || Pergunte("TM250D",.T.), lF12 := .T. ,;
												lExibeLanc := Iif(mv_par01 == 2,.F.,.T.),;
												lOnline    := Iif(mv_par03 == 2,.F.,.T.) } } )
			//-- Inicializa Teclas de Atalhos
			TmsKeyOn(aSetKey)

		EndIf

		DTY->( DbSetOrder( 1 ) )
		If nReg	> 0 .And. DTY->( DbGoTo(nReg) )

			oModel := FWLoadModel( 'TMSA250' )
			oModel:SetOperation( MODEL_OPERATION_DELETE )
			oModel:Activate()

			lRet := oModel:VldData()

			If lRet
				lRet := oModel:CommitData()
			EndIf

			oModel:DeActivate()
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o custo medio e' calculado On Line se            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTmsErp == '0' .And. lOnline .And. nTotal > 0
		If nOpcx == 3 //-- Gera contrato 'Por Viagem'
			lDigita   := Iif(mv_par03 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
			lAglutina := Iif(mv_par04 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
		ElseIf nOpcx == 4  //-- Gera contrato 'Por Periodo'
			lDigita   := Iif(mv_par09 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
			lAglutina := Iif(mv_par10 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
		ElseIf nOpcx == 5 //-- Exclui Contrato
			lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
			lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se ele criou o arquivo de prova ele deve gravar o rodape'    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RodaProva(nHdlPrv,nTotal)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para Lan‡amento Cont bil                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cA100Incl(cArquivo,nHdlPrv,3,cLoteCTC,lDigita,lAglutina)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a Data da Contabilizacao no SDG            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To Len(aRecSDGBai)
		SDG->(dbGoTo(aRecSDGBai[nCntFor]))
		RecLock('SDG',.F.)
		If nOpcx == 5
			SDG->DG_DTLANC := Ctod("")
		Else
			SDG->DG_DTLANC := dDataBase
		EndIf
		MsUnLock()
	Next

	For nCntFor := 1 To Len(aRecSDGEmi)
		SDG->(dbGoTo(aRecSDGEmi[nCntFor]))
		RecLock('SDG',.F.)
		If nOpcx == 5
			SDG->DG_DTLAEMI := Ctod("")
		EndIf
		MsUnLock()
	Next

	If !lRet .And. lTM250FIM // Se houver msg de erro por qq eventualidade
		ExecBlock('TM250FIM',.F.,.F.,{}) //vetor é passado sem conteúdo devido a execução do ponto de entrada em duplicidade
	EndIf

	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
	//Em Codebase esta dando erro estes RestAreas
	#IFDEF TOP
		RestArea(aArea)
		RestArea(aAreaDTY)
	#ENDIF
	cFilAnt := cFilSav // Retornando a Filial Original

Else
    lContGerado := .F.
EndIf
Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} TMA250Param
					Verifica o preenchimento de alguns parametros necessarios para gerar o
					contrato de carreteiro
@Parametros			ExpL1 - Verifica qual programa está chamando a rotina
							.T. - a funcao esta sendo chamada pelo prog. TMSA740
 				        	.F. - a funcao esta sendo chamada pelo prog. TMSA250
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Function TMA250Param(lCtrPremio,cNatuPDG,cNatuDEB,cTipPdg,cTipCTC)

Local ny
Local aEmptyCpo  := {}
Local aCpSED	 := {}
Local aMsgJob    := {}
Local cTXTLG250  := ""
Local cTipPre    := Padr( GetMV("MV_TPTPRE"), Len( SE2->E2_TIPO ) )    // Tipo Premio
Local cUniao     := GetMV("MV_UNIAO")	// Cod. para Pagto. do Imposto de Renda
Local cCodDesCTC := TMSA250Var("DES") // Codigo de Despesa de contrato de carreteiro
Local cCodDesPDG := Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio
Local cCodDesPRE := Padr( GetMV("MV_DESPRE"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Premio

//-- Preenche array 'aMsgJob' com as mensagens que estarão no log de processamento.
TMSMSGPARAN(@aMsgJob)

Default lCtrPremio := .F.
Default cNatuPDG   := ''
Default cNatuDEB   := ''
Default cTipPdg	   := ''
Default cTipCTC	   := ''
If Empty(cNatuPDG)
    AADD(aEmptyCpo,"MV_NATPDG")
EndIf
If Empty(cNatuDEB)
    AADD(aEmptyCpo,"MV_NATDEB")
EndIf
If Empty(cTipPdg)
    AADD(aEmptyCpo,"MV_TPTPDG")
EndIf
If lCtrPremio .And. Empty(cTipPRE)
    AADD(aEmptyCpo,"MV_TPTPRE")
EndIf
If Empty(cUniao)
    AADD(aEmptyCpo,"MV_UNIAO")
EndIf
If Empty(cCodDesCTC)
    AADD(aEmptyCpo,"MV_DESCTC")
EndIf
If Empty(cCodDesPDG)
    AADD(aEmptyCpo,"MV_DESPDG")
EndIf
If lCtrPremio .And.Empty(cCodDesPRE)
    AADD(aEmptyCpo,"MV_DESPRE")
EndIf

For nY:=1 To Len(aEmptyCpo)
	If !lExcSched250
   		Help("",1,"TMSA25003",,aEmptyCpo[nY],5,5) // Este Parametro esta vazio ... E Obrigatorio preenche-lo para geracao do Contrato de Carreteiro
   	Else
   	   	cTXTLG250 := "O parametro "+aEmptyCpo[nY]+ aMsgJob[1]
   	   	A250MsgAdd(cTXTLG250,"TMA250Param")
   	EndIf
Next

If Len(aEmptyCpo) > 0
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o Conteudo de alguns Parametros                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !SED->(MsSeek(xFilial('SED')+cNatuPDG) )
	If !lExcSched250
		Help(" ",1,"TMSA25004",,"MV_NATPDG" + " : " + cNatuPDG,04,01) // Conteudo do parametro invalido MV_NATPDG
	Else
		cTXTLG250 := aMsgJob[2] + cNatuPDG
		A250MsgAdd(cTXTLG250,"TMA250Param" )
	EndIf
	Return .F.
EndIf
If !SED->(MsSeek(xFilial('SED')+cNatuDeb) )
	If !lExcSched250
		Help(" ",1,"TMSA25004",,"MV_NATDEB" + " : " + cNatuDeb,04,01) // Conteudo do parametro invalido MV_NATDEB
	Else
		cTXTLG250 := aMsgJob[3] + cNatuDeb
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
Else
	//--A Natureza de Debito nao deve calcular impostos para nao gerar duplicidade nos titulos.
	AAdd(aCpSED,"ED_CALCIRF")
	AAdd(aCpSED,"ED_CALCISS")
	AAdd(aCpSED,"ED_CALCINS")
	AAdd(aCpSED,"ED_CALCCSL")
	AAdd(aCpSED,"ED_CALCCOF")
	AAdd(aCpSED,"ED_CALCPIS")
	AAdd(aCpSED,"ED_CALCSES")
	AAdd(aCpSED,"ED_IRRFCAR")
	AAdd(aCpSED,"ED_INSSCAR")

	For ny:=1 To Len(aCpSED)
	    If SED->(FieldGet(FieldPos(aCpSED[ny]))) == "S"
        	If !lExcSched250
        		Help(" ",1,"TMSA25027",,"MV_NATDEB" + " : " + cNatuDeb,05,01) // Conteudo do parametro invalido MV_NATDEB, a Natureza de Debito não deve calcular impostos para não gerar titulos indevidos.
			Else
				cTXTLG250 := aMsgJob[4] + cNatuDeb
				A250MsgAdd(cTXTLG250,"TMA250Param")
			EndIf
			Return .F.
		EndIf
	Next
EndIf

If Empty(Tabela("05",cTipCTC,.F.))
	If !lExcSched250
		Help(" ",1,"TMSA25009",,STR0079 + " :" + cTipCTC,05,00) // 'Nao encontrou na Tabela "05", o tipo do Titulo que sera utilizado para esta Filial. Tipo do Titulo a ser cadastrado:'
	Else
		cTXTLG250 := aMsgJob[5] + cTipCTC
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf
If Empty(Tabela("05",cTipPdg,.F.))
	If !lExcSched250
		Help(" ",1,"TMSA25005",,"MV_TPTPDG" + " : " + cTipPdg,04,01) // Conteudo do parametro invalido MV_TPTPDG
	Else
		cTXTLG250 := aMsgJob[6] + cTipPdg
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf
If lCtrPremio .And. Empty(Tabela("05",cTipPRE,.F.))
	If !lExcSched250
		Help(" ",1,"TMSA25005",,"MV_TPTPRE" + " : " + cTipPRE,04,01) // Conteudo do parametro invalido MV_TPTPRE
	Else
		cTXTLG250 := aMsgJob[7] + cTipPRE
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf
DT7->(dbSetOrder(1))
If !DT7->(MsSeek(xFilial('DT7')+cCodDesCTC))
	If !lExcSched250
		Help(" ",1,"TMSA25006",,"MV_DESCTC" + " : " + cCodDesCTC,04,01) // Conteudo do parametro invalido MV_DESCTC
	Else
		cTXTLG250 := aMsgJob[8] + cCodDesCTC
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf
If !DT7->(MsSeek(xFilial('DT7')+cCodDesPDG))
	If !lExcSched250
		Help(" ",1,"TMSA25006",,"MV_DESPDG" + " : " + cCodDesPDG,04,01) // Conteudo do parametro invalido MV_DESPDG
	Else
		cTXTLG250 := aMsgJob[9] + cCodDesPDG
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf
If lCtrPremio .And. !DT7->(MsSeek(xFilial('DT7')+cCodDesPRE))
	If !lExcSched250
		Help(" ",1,"TMSA25006",,"MV_DESPRE" + " : " + cCodDesPRE,04,01) // Conteudo do parametro invalido MV_DESPRE
	Else
		cTXTLG250 := aMsgJob[10] + cCodDesPRE
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf

If cTipCTC == cTipPdg
	If !lExcSched250
		Help("",1,"TMSA25008")   //O Tipo de Contrato de Carreteiro e o Tipo de Contrato de Pedagio estao iguais ...
	Else
		cTXTLG250 := aMsgJob[11]
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf

If cTipPre == cTipCTC
	If !lExcSched250
		Help("",1,"TMSA25007")   // O Tipo de Contrato de Premio de Carreteiro esta' igual ao Tipo de Contrato de Carreteiro ...
	Else
		cTXTLG250 := aMsgJob[12]
		A250MsgAdd(cTXTLG250,"TMA250Param")
	EndIf
	Return .F.
EndIf

Return .T.

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} A250VldNat()
					Verifica o preenchimento de alguns parametros necessarios para gerar o
					contrato de carreteiro
@Parametros			ExpL1 - Verifica qual programa está chamando a rotina
							.T. - a funcao esta sendo chamada pelo prog. TMSA740
 				        	.F. - a funcao esta sendo chamada pelo prog. TMSA250
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//-----------------------------------------------------------------------------------------

Static Function A250VldNat(cTipCTC,cNatuPDG,cNatuDeb)
Local aSX5	 := {}

Default cTipCTC := ''
Default cNatuPDG := ''
Default cNatuDEb := ''

//--Valida os parâmetros necessários para geração de títulos no ERP Protheus
If lTM250Par
	cNatuPDG := ExecBlock('TM250PAR',.F.,.F.,{2})
	cNatuDeb := ExecBlock('TM250PAR',.F.,.F.,{3})
	If ValType(cNatuPDG) <> 'C'
		cNatuPDG := Padr( GetMV("MV_NATPDG"), Len( SE2->E2_NATUREZ ) ) // Natureza Pedagio
	EndIf
	If ValType(cNatuDeb) <> 'C'
		cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
	EndIf
Else
	cNatuPDG := Padr( GetMV("MV_NATPDG"), Len( SE2->E2_NATUREZ ) ) // Natureza Pedagio
	cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
EndIf

//-- Se o parametro MV_TPTCTC nao estiver preenchido
If Empty(cTipCTC)
	If Len(cFilAnt) > 2
		Final(STR0186,STR0187)//--'O parametro MV_TPTCTC deve ser preenchido quando a Gestão Corporativa','estiver ativa.'
	Else
		cTipCTC := Padr( "C"+FWFilial(),Len(SE2->E2_TIPO)) // Tipo Contrato de Carreteiro
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSX5 := FWGetSX5("09","TMS")
cLoteCTC:=IIF(!Empty(aSX5),aSX5[1][4],"TMS ")

Return Nil

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250FinPrt()
					Verifica se o contrato pode ser excluído com base nos títulos fo financeiro do
					Protheus
@Parametros			ExpC1 - Prefixo do título que foi gerado pelo Contrato de Carreteiro
					Expc2 - Alias da query com o contarato a ser excluído
 				    ExpC3 - Rotina que originou o contrato de carreiro(Viagem "TMS" ou Carga"OMS")
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function A250FinPrt(cPrefixo,cCodForn,cLojForn,cContrat,lRepom,aMsgErr,cFilOri,cViagem)
Local lRet 		:= .T.
Local cPrefDeb  := ""
Local cFilOld   := ""
Local aAreaDTY	:= DTY->(GetArea())

Default cPrefixo := ""
Default cCodForn := ""
Default cLojForn := ""
Default cContrat := ""
Default lRepom 	 := .F.
Default aMsgErr	 := {}
Default cFilOri	 := ""
Default cViagem	 := ""

DTY->(dbSetOrder(2))//--FILIAL+FILORI+VIAGEM+NUMCTC

If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem + cContrat ))

	//--Deleta título de Adiantamento
	If DTR->DTR_CREADI+DTR->DTR_LOJCRE <> cCodForn+cLojForn
		lRet := TMA250DelTit(cPrefixo, DTY->DTY_NUMCTC,, DTR->DTR_CREADI, DTR->DTR_LOJCRE, DTY->DTY_CODFAV, DTY->DTY_LOJFAV,'')
	EndIf

	If lRet := TMA250DelTit(cPrefixo, DTY->DTY_NUMCTC,,DTY->DTY_CODFOR, DTY->DTY_LOJFOR, DTY->DTY_CODFAV, DTY->DTY_LOJFAV, '', 1)
		A250DelSDG(DTY->DTY_FILORI,DTY->DTY_VIAGEM,DTY->DTY_CODVEI,cPrefixo,DTY->DTY_CODFOR,DTY->DTY_LOJFOR,DTY->DTY_CODFAV, DTY->DTY_LOJFAV)
		//-- Verifica a Filial de Debito
		cFilDeb := TMSA250FilDeb(DTY->DTY_CODFOR,DTY->DTY_LOJFOR,DTY->DTY_CODFAV,DTY->DTY_LOJFAV,DTY->DTY_TIPCTC<>StrZero(2,Len(DTY->DTY_TIPCTC)),DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,Iif(DTY->DTY_FILDEB <> cFilAnt,.T.,.F.),DTY->DTY_CODVEI)

		//-- Deletar Contas a Pagar da Filial de Debito
		If cFilDeb <> cFilAnt
			cFilOld  := cFilAnt
			cPrefDeb := TMA250GerPrf(cFilDeb)
			cFilAnt  := cFilDeb
			lRet     := TMA250DelTit(cPrefDeb, DTY->DTY_NUMCTC, cFilDeb, DTY->DTY_CODFOR, DTY->DTY_LOJFOR, DTY->DTY_CODFAV, DTY->DTY_LOJFAV, '', 1)
			cFilAnt  := cFilOld
		EndIf

	EndIf

EndIf

RestArea(aAreaDTY)
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250FinDTS()
					Verifica se o contrato pode ser excluído com base nos títulos do financeiro do
					DATASUL
@Parametros			ExpC1 - Prefixo do tíutulo que foi gerado pelo Contrato de Carreteiro
					Expc2 - Alias da query com o contarato a ser excluído
 				    ExpC3 - Rotina que originou o contrato de carreiro(Viagem "TMS" ou Carga"OMS")
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------

Static Function A250FinDTS(cPrefixo,cCodForn,cLojForn,cContrat,lRepom,aMsgErr,lExcluir,cFilOri, cViagem,lIntegra )

Local lRet          := .T.
Local cPrefDeb      := ""
Local cFilOld       := ""
Local aEAIRet       := {}
Local lGerTitulo    := GetMV('MV_GERTIT' ,,.T.)
Local cStatusPag    := SuperGetMv("MV_LIBCTC",,.F.)
Local cSubTipMsg    := "201"
Local cTipoMsg	     := "2"
Local cEntyName     := 'TRANSPORTDOCUMENT'
Local cEventType    := IIf(lExcluir,"delete","upsert")
Local cCNPJForn     := ""
Local aAreaDTY      := DTY->(GetArea())
Local lLibCTC       := SuperGetMV('MV_LIBCTC',, .F.)

Default cPrefixo    := ""
Default cCodForn    := ""
Default cLojForn    := ""
Default cContrat    := ""
Default lRepom      := .F.
Default aMsgErr     := {}
Default lExcluir 	:= .F.
Default cFilOri     := ""
Default cViagem     := ""
Default lIntegra    := .T.  // Infoma se deverá chamar a integração EAI, por meio de um controlador determina se Integra ou não. Motivo: Exclusão de um contrato por periodo, não deve integrar todas as exclusões necessário apenas uma.

Begin Transaction

    DTY->(DbSetOrder(1)) //-- DTY_FILIAL+DTY_NUMCTC
    If DTY->(MsSeek(xFilial("DTY") + cContrat ))

		A250DelSDG(DTY->DTY_FILORI,DTY->DTY_VIAGEM,DTY->DTY_CODVEI,cPrefixo,DTY->DTY_CODFOR,DTY->DTY_LOJFOR,DTY->DTY_CODFAV, DTY->DTY_LOJFAV)

		If lEAIFunOK .And. lIntegra .And. (!lLibCTC .Or. DTY->DTY_TITFRE == '1')
			SA2->(dbSetOrder(1))

			If SA2->(dbSeek(FwxFilial('SA2')+cCodForn+cLojForn))
				cCNPJForn := SA2->A2_CGC
			EndIf

		    //Instância classe para envio da mensagem ao ERP Datasul
		    aEAIRet := TmA250Clas(DTY->DTY_FILORI,DTY->DTY_VIAGEM,cContrat, 0, 0, 0, 0, 0, 0, 0, cCodForn , cLojForn , cCnpjForn , cFilDeb, ;
		                       dDatabase, Date(), "", cEventType , cEntyName, cTIPOMSG , cSubTipMsg, .F./*lBlqTit*/ , .F., cStatusPag,lExcluir )

		    If !(lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1]))
			   	DisarmTransaction()
		    EndIf

		EndIf

	EndIf

End Transaction

RestArea(aAreaDTY)
Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef()
					IntegDef da Rotina TMsa250
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion )
Local aRet := {}

aRet:= TMSI250( cXml, nType, cTypeMsg, cVersion )

Return aRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250ExcRpm()
					Efetua as exclusões necessárias quando o contrato de carreteiro estiver inte-
					grado com a REPOM Operadora de Frete e Pedágio.
@Parametros			ExpA1 - Array com mensagem de erro a ser apresentada
 				    ExpC3 - Rotina que originou o contrato de carreiro(Viagem "TMS" ou Carga"OMS")
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------

Function A250ExcRpm(aMsgErr, lExclui, aBkDTY, nBkValLiq)
Local aMovtos := {}
LOcal lRet	  := .T.
Local nOPcx	  := 5
Local cImpCTC := SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
Local lLibCTC := SuperGetMV( 'MV_LIBCTC' ,,.F.)
Local cFILDTY := ""
Local cNUMCTC := ""
Local cTIPCTC := ""
Local cCODOPE := ""
Local cFILORI := ""
Local cVIAGEM := ""
Local cCODVEI := ""
Local cTITFRE := ""
Local cSTATUS := ""
Local nVALFRE := 0
Local nVLREEM := 0
Local nValLiq := 0

Default aMsgErr   := {}
Default	lExclui	  := .F. //--Força a exclusão do movimento na REPOM, mesmo que o título financeiro não tenha sido gerado.
Default aBkDTY    := {}
Default nBkValLiq := 0

//-- Inicializa as variáveis, conforme parâmetros - o array aBkDTY é utilizado quando o registro foi "apagado" por um desarme da transação pelo EAI (ERP DataSul)
If Empty(aBkDTY)
	cFILDTY := DTY->DTY_FILIAL
	cNUMCTC := DTY->DTY_NUMCTC
	cTIPCTC := DTY->DTY_TIPCTC
	cCODOPE := DTY->DTY_CODOPE
	cFILORI := DTY->DTY_FILORI
	cVIAGEM := DTY->DTY_VIAGEM
	cCODVEI := DTY->DTY_CODVEI
	cTITFRE := DTY->DTY_TITFRE
	cSTATUS := DTY->DTY_STATUS
	nVALFRE := DTY->DTY_VALFRE
	nVLREEM := DTY->DTY_VLREEM
	nValLiq := DTYValLiq(.F.)
Else
	cFILDTY := aBkDTY[DTY->(FieldPos("DTY_FILIAL"))]
	cNUMCTC := aBkDTY[DTY->(FieldPos("DTY_NUMCTC"))]
	cTIPCTC := aBkDTY[DTY->(FieldPos("DTY_TIPCTC"))]
	cCODOPE := aBkDTY[DTY->(FieldPos("DTY_CODOPE"))]
	cFILORI := aBkDTY[DTY->(FieldPos("DTY_FILORI"))]
	cVIAGEM := aBkDTY[DTY->(FieldPos("DTY_VIAGEM"))]
	cCODVEI := aBkDTY[DTY->(FieldPos("DTY_CODVEI"))]
	cTITFRE := aBkDTY[DTY->(FieldPos("DTY_TITFRE"))]
	cSTATUS := aBkDTY[DTY->(FieldPos("DTY_STATUS"))]
	nVALFRE := aBkDTY[DTY->(FieldPos("DTY_VALFRE"))]
	If DTY->(ColumnPos("DTY_VLREEM")) > 0
		nVLREEM := aBkDTY[DTY->(FieldPos("DTY_VLREEM"))]
	EndIf
	nValLiq := nBkValLiq
EndIf

Trace250("A250ExcRpm INICIO " + cTIPCTC + "/" + SuperGetMV('MV_ENREPOM',,"1") )

If cTIPCTC <> '5'
	If SuperGetMV('MV_ENREPOM',,"1") $ "1;2"  //-- Encerra Repom por: Pagto Saldo = 3 / Ocorrencia = 2 / Rotina de Encerramento = 1
		Trace250("Chamando RepContrat ")
		MsgRun( STR0100,; //-- "Realizando comunicacao com a Operadora...
		STR0083,; //-- "Aguarde..."
		{|| lRet := RepContrat(cCODOPE, cFILORI, cVIAGEM,,,,,,nOpcX,@aMsgErr)})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Elimina os Movimentos gerados a partir da integracao com a Operadora de Frotas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Trace250("Voltando RepContrat " + AllToChar(lRet))
		If lRet
			Trace250("Chamando TmsMovVal " + AllToChar(lRet))
			TMSMovVal( cCODOPE, cFILORI, cVIAGEM, {}, nOpcx )
			Trace250("Voltando TmsMovVal " + AllToChar(lRet))
		EndIf
	ElseIf SuperGetMV('MV_ENREPOM',,"1") $ "3;4" //-- Encerra Repom por: Pagto Saldo = 4/Conf.LibCTC = 3 / Ocorrencia = 2 / Rotina de Encerramento = 1
		lFrotaProp := Posicione('DA3',1,xFilial('DA3')+cCODVEI,'DA3_FROVEI') == '1'

		If !lFrotaProp .And. (!lLibCTC .Or. SuperGetMV('MV_ENREPOM',,"1") == "4" .Or. cSTATUS $ "8|B" .Or.;  //| 8-'Aguardando Autoriz. Pagto'
		                     (lLibCTC .And. cTITFRE == "1"  ) .Or. ; //-- libCTC mas com o contrato dizendo que gera título na geração do contrato
							 (lExclui))

			Trace250("Iniciando estorno ")
			DTR->(DbSetOrder(1))
			If DTR->(MsSeek(xFilial('DTR')+ cFILORI + cVIAGEM))
				Trace250("Chamando TMA340Oper "+ AllToChar(lFrotaProp))
				CursorWait()
				MsgRun( STR0266 ,; //-- "Estornando a quitação junto a Operadora de Frotas..."
						STR0267,; //-- "Estorno da Quitação do Contrato"
						{|| lRet := TMA340Oper( cCODOPE, cFILORI, cVIAGEM, @aMsgErr, .F., 5 )} )
				CursorArrow()
				Trace250("Chamando TMA340Oper "+ AllToChar(lRet))
			EndIf

			//-- Avalia Estorno do movimento de Reembolso
			If DTY->(ColumnPos("DTY_VLREEM")) > 0 .And. nVLREEM > 0
				Trace250("Apurando DTY_VLREEM " + AllToChar(nVLREEM) )
				AAdd(aMovtos, {	DTR->(DTR_FILORI+DTR_VIAGEM) ,;
					AllTrim('20'),; //-- default 146-Acrescimo/ 06-Desconto
					Abs(nVLREEM),;
					'00',; //-- NENHUMA ACAO NO PROTHEUS
					'1'} )//-- '1' Exclui movimento
			EndIf

			//-- Avalia Estorno do movimento da diferença entre previsto x realizado
			DTR->(DbSetOrder(1))
			If lRet .And. !lFrotaProp .And. ;
			   DTR->(MsSeek(xFilial('DTR') + cFILORI + cVIAGEM)) .And. ;
			   Iif(cImpCTC == "0",nValLiq, nVALFRE) <> DTR->(Iif(DTR->DTR_FRECAL == '1', DTR_PRVFRE, DTR_VALFRE))
				nValMov := Iif(cImpCTC == "0",nValLiq, nVALFRE) - DTR->(Iif(DTR->DTR_FRECAL == '1', DTR_PRVFRE, DTR_VALFRE))
				Trace250("Apurando nValMov " + AllToChar(nValMov))
				aMovtos := {}
				AAdd(aMovtos, {	DTR->(DTR_FILORI+DTR_VIAGEM) ,;
						Iif(nValMov > 0,AllTrim(GetMv('MV_REPACRE',,'146')),AllTrim(GetMv('MV_REPDECR',,'06'))),; //-- default 146-Acrescimo/ 06-Desconto
						Abs(nValMov),;
						'00',; //-- NENHUMA ACAO
						'1'} )//-- '1' Exclui movimento
			EndIf

			//-- Efetiva estorno de movimentos
			Trace250("Antes da TmsIncMov "+ AllToChar(lRet) + "/" + VarInfo("aMovtos",aMovtos))
			If lRet .And. !Empty(aMovtos)
				MsgRun( STR0268,; //-- "Estornando Movimentos para o Contrato..."
						STR0100,; //-- "Realizando Comunicação com a Operadora..."
						{|| lRet := TMSIncMov( DTR->DTR_CODOPE, DTR->DTR_FILORI, DTR->DTR_VIAGEM, aMovtos)})
				Trace250("Voltando da TmsIncMov "+ AllToChar(lRet))
			EndIf
		Else
			Trace250("Não Apto ao estorno lLibCTC/lExclui/cTITFRE/cSTATUS " + AllToChar(lLibCTC)  + "/" + AllToChar(lExclui)  + "/" + cTITFRE + "/" + cSTATUS)
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata a Exclusao de Contratos Complementares amarrados com Operadora de Frotas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Trace250("Iniciando estorno Contrato Complementar ")
	DTR->(DbSetOrder(1))
	If DTR->(MsSeek(xFilial('DTR')+cFILORI+cVIAGEM)) .And. DTR->DTR_CODOPE== '01'
		DEN->(DbSetOrder(1))
		If DEN->(MsSeek(xFilial('DEN')+cFILORI+cVIAGEM))
			While DEN->(DEN_FILIAL+DEN_FILORI+DEN_VIAGEM) == xFilial('DEN')+cFILORI+cVIAGEM
				If RTrim(DEN->DEN_IDREG) == cFILDTY+cNUMCTC .And. DEN->DEN_RECENV == 'E'
					AAdd(aMovtos, {	cFILDTY+cNUMCTC,;
						DEN->DEN_CODMOV,;
						DEN->DEN_VALOR,;
						DEN->DEN_ACAO,;
						'1'} )
				EndIf
				DEN->(DbSkip())
			EndDo
			If !Empty(aMovtos)
				Trace250("Chamando TmsIncMov " + VarInfo("aMovtos",aMovtos))
				MsgRun( STR0109,; //-- "Gerando Movimentos para o Contrato...
				STR0100,; //-- "Realizando Comunicação com a Operadora..."
				{|| lRet := TMSIncMov( DTR->DTR_CODOPE, cFILORI, cVIAGEM, aMovtos)})
				Trace250("Voltando TmsIncMov " + AllToChar(lRet))
			EndIf
		EndIf
	EndIf
EndIf

Trace250("A250ExcRpm FIM " + AllToChar(lRet))

Return lRet

/*/{Protheus.doc} A250DelDVP
//TODO Efetua as exclusões necessárias quando o contrato de carreteiro estiver integrado com a REPOM Operadora de Frete e Pedágio.
@author leandro.paulino
@since 12/09/2016
@version 1.0
@param cFilOri, characters, descricao
@param cViagem, characters, descricao
@param cNumCtc, characters, descricao
@type function
/*/
Static Function A250DelDVP( cFilOri , cViagem, cNumCtc )

Local cSeekDVP	:= ""
Local bWhileDVP := {||.T.}

Default cFilOri 	:= ""
Default cViagem		:= ""
Default cNumCtc		:= ""


DVP->(dbSetOrder(1))
cSeekDVP  := xFilial("DVP")+ cFilOri +cNumCtc + cViagem
bWhileDVP := {|| DVP->(!Eof()) .And. DVP->(DVP_FILIAL+DVP_FILORI+DVP_NUMCTC+DVP_VIAGEM) == cSeekDVP }

DVP->(dbSeek(cSeekDVP))
While Eval(bWhileDVP)
	RecLock("DVP",.F.)
	DVP->(dbDelete())
	DVP->(MsUnLock())
	DVP->(dbSkip())
EndDo

Return Nil

/*/{Protheus.doc} A250DelDDN
//TODO Efetua as exclusões necessárias para o histórico de acrescimo/decrescimo

@author caio.y
@since 12/09/2016
@version 1.0
@param cFilOri, characters, descricao
@param cViagem, characters, descricao
@param cNumCTC, characters, descricao
@type function
/*/
Static Function A250DelDDN( cFilOri , cViagem, cNumCTC )

Local cSeekDVP	:= ""
Local bWhileDVP := {||.T.}

Default cFilOri 	:= ""
Default cViagem		:= ""
Default cNumCTC		:= ""

//-- Deleta Acrescimos e Decrescimos
DDN->(DbSetOrder(2))
If DDN->(DbSeek(xFilial("DDN") +  cNumCTC ))
	While DDN->(!Eof()) .And. DDN->(DDN_FILIAL + DDN_NUMCTC) == xFilial("DDN") + cNumCTC
		RecLock("DDN",.F.)
		DDN->(DbDelete())
		DDN->(DbSkip())
	EndDo
EndIf

Return Nil

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250DelCPR()
					Atualiza as informações do RH Ref. ao Contrato de premio do motorista próprio

@Parametros			ExpC1 - Alias com resultado da Query do DTY
 				    ExpC3 - Rotina que originou o contrato de carreiro(Viagem "TMS" ou Carga"OMS")
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function A250DelCPR( cTipCTC , cCodMot , nValPre ,aMsgErr)

Local nIndRgb    := 0 //Integração TMS x GPE
Local nIndRch    := 0 //Integração TMS x GPE
Local cVerbMot   := GetMV('MV_VERBMOT',,'') // Codigo da Verba do Motorista
Local lRet 		 := .T.

Default cTipCTC 	:= ""
Default cCodMot	  	:= {}
Default nValPre		:= 0
Default aMsgErr		:= {}

If cTipCTC == StrZero(3, Len(DTY->DTY_TIPCTC))
	DA4->(dbSetOrder(1))
	If DA4->(MsSeek(xFilial('DA4')+ cCodMot ) )  .And. DA4->DA4_COMISS == StrZero(1, Len(DA4->DA4_COMISS))
		SRA->(dbSetOrder(1))
		SRA->(MsSeek(xFilial('SRA') + DA4->DA4_MAT))
		nIndRgb:= RetOrder("RGB", "RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEMANA+RGB_SEQ")
		RGB->(DbSetOrder(nIndRgb))
		If RGB->(MsSeek(xFilial('RGB') + DA4->DA4_MAT+cVerbMot+SRA->RA_CC))
			nIndRch:= RetOrder("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG")
			RCH->(DbSetOrder(nIndRch))
			If RCH->(MsSeek(xFilial('RCH') + RGB->RGB_PROCES + RGB->RGB_ROTEIR + RGB->RGB_PERIOD))	.And. RCH->RCH_PERSEL == "1"// encontra o periodo e verifica se esta ativo
				RecLock('RGB', .F.)
				RGB->RGB_VALOR -= nValPre
				If RGB->RGB_VALOR == 0
					RGB->(dbDelete())
				Endif
				RGB->(MsUnLock())
			Else
				AAdd( aMsgErr, {STR0230} ) //"Contrato Prêmio integrado a folha de pagamento. Contrato não pode ser estornado!"
				lRet := .F.
			Endif
		EndIf
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250AtuDTR()
					Atualiza as informações referente ao complemento da viagem
@author leandro.paulino
@since 12/09/2016
@version 1.0

@param nOpcX, numeric, Número da operação
@param cTabFre, characters, Código Tabela de Frete
@param cTipTab, characters, Tipo da Tabela
@param nValFrete, numeric, Valor do frete
@param cTabCar, characters, Código tabela de carreteiro
@param nGrupVei, numeric, Grupo do veículo
@param cFilOri, characters, Filial de Origem da Viagem
@param cViagem, characters, Código da viagem
@param cNumCTC, characters, Número do contrato do carreteiro
@type function
/*/
//------------------------------------------------------------------------------------------------

Static Function A250AtuDTR(nOpcX, cTabFre, cTipTab, nValFrete, cTabCar, nGrupVei, cFilOri, cViagem, cNumCTC )

Local cSeek 	:= ""
Local lRet		:= .T.
Local lTMSOPdg  := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local aAreaDTY	:= {}
Local cOriPDG	:= ""

Default nOpcX	  	:= 3
Default cTabFre	  	:= ""
Default cTipTab   	:= ""
Default nValFrete 	:= 0
Default cTabCar	  	:= ""
Default nGrupVei  	:= 0
Default cFilOri		:= ""
Default cViagem		:= ""
Default cNumCTC		:= ""

If nOpcx == 3 .Or. nOpcX == 4

	//-- Se o Valor do Frete do Complemento de Viagem estiver zerado,
	//-- gravar o valor do frete calculado pela TMSCalFrePag()
	RecLock("DTR", .F.)
	If nGrupVei == 0 .And. Empty(DTR->DTR_VALFRE)
		DTR->DTR_FRECAL := '1'         //-- Frete Calculado
		DTR->DTR_TABFRE := cTabFre     //-- Tabela de Frete a Pagar utilizada para Calculo do Frete
		DTR->DTR_TIPTAB := cTipTab     //-- Tipo da Tabela de Frete
		DTR->DTR_VALFRE := nValFrete   //-- Valor do Frete Calculado
		DTR->DTR_TABCAR := cTabCar     //-- Tabela de Carreteiro
	ElseIf nGrupVei == 1 .And. Empty(DTR->DTR_VALRB1)
		DTR->DTR_CALRB1 := '1'         //-- Frete Calculado
		DTR->DTR_VALRB1 := nValFrete   //-- Valor do Frete Calculado 1º Reboque
	ElseIf nGrupVei == 2 .And. Empty(DTR->DTR_VALRB2)
		DTR->DTR_CALRB2 := '1'         //-- Frete Calculado
		DTR->DTR_VALRB2 := nValFrete   //-- Valor do Frete Calculado 2º Reboque
	ElseIf nGrupVei == 3 .And. lTercRbq .And. Empty(DTR->DTR_VALRB3)
		DTR->DTR_CALRB3 := '1'         //-- Frete Calculado
		DTR->DTR_VALRB3 := nValFrete   //-- Valor do Frete Calculado 3º Reboque
	EndIf
	DTR->(MsUnLock())

ElseIf nOpcx == 5

	aAreaDTY	:= DTY->(GetArea())
	DTY->(dbSetOrder(2)) //-- FILIAL+FILORI+VIAGEM+NUMCTC
	If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem + cNumCTC))

		DTR->(dbSetOrder(1))
		DTR->(MsSeek(cSeek:=xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
		Do While !DTR->(Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM == cSeek
			RecLock('DTR', .F.)
			If DTY->DTY_CODVEI == DTR->DTR_CODVEI
				aAreaBkp := GetArea()
				dbSelectArea("DVW")
				DVW->(dBSetOrder(1))
				DVW->(dBSeek(xFilial("DVW")+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
				RestArea (aAreaBkp)
				If DTR->DTR_FRECAL == '1' .Or. DVW->DVW_VIAGEM == DTR->DTR_VIAGEM
					//-- Frete Calculado pelo Contrato de Carreteiro (Por Periodo) ou tem algum valor informado
					DTR->DTR_VALFRE := 0
					DTR->DTR_FRECAL := '2' //-- O Valor do Frete nao foi Calculado
					DTR->DTR_TABFRE := CriaVar('DTR_TABFRE', .F.)
					DTR->DTR_TIPTAB := CriaVar('DTR_TIPTAB', .F.)
					DTR->DTR_TABCAR := CriaVar('DTR_TABCAR', .F.)
				EndIf
			ElseIf DTY->DTY_CODVEI == DTR->DTR_CODRB1
				If DTR->DTR_CALRB1 == '1' //-- Frete Calculado pelo Contrato de Carreteiro (Por Periodo)
					DTR->DTR_VALRB1 := 0
					DTR->DTR_CALRB1 := '2' //-- O Valor do Frete nao foi Calculado
				EndIf
			ElseIf DTY->DTY_CODVEI == DTR->DTR_CODRB2
				If DTR->DTR_CALRB2 == '1' //-- Frete Calculado pelo Contrato de Carreteiro (Por Periodo)
					DTR->DTR_VALRB2 := 0
					DTR->DTR_CALRB2 := '2' //-- O Valor do Frete nao foi Calculado
				EndIf
			ElseIf lTercRbq .And. DTY->DTY_CODVEI == DTR->DTR_CODRB3
				If DTR->DTR_CALRB3 == '1' //-- Frete Calculado pelo Contrato de Carreteiro (Por Periodo)
				   DTR->DTR_VALRB3 := 0
				   DTR->DTR_CALBR3 := '2' //-- O Valor do Frete nao foi Calculado
				EndIf
			EndIf
			If DTR->(ColumnPos('DTR_ORIPDG')) > 0
				cOriPDG := AllTrim(DTR->DTR_ORIPDG)
				If cOriPDG == 'TMSA250'
					DTR->DTR_ORIPDG := CriaVar('DTR_ORIPDG', .F.)
					If DTR->(ColumnPos('DTR_TITPDG')) > 0
						DTR->DTR_TITPDG := '2'
					EndIf
				EndIf
			EndIf
			DTR->(MsUnLock())
			DTR->(dbSkip())
		EndDo

	EndIf

	RestArea(aAreaDTY)
EndIf

Return Nil

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250EstSDG()
					Atualiza as informações referente ao movimento custo da viagem

@Parametros			ExpC1 - Numero do contrato de carreteiro que está sendo excluído
					ExpC2 - Filial de Origem da Viagem
					ExpC3 - Número da Viagem

@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function A250EstSDG(cContrat, cFilOri, cViagem)

Local cSeekSDG   	:= ""
Local bWhileSDG  	:= {||.T.}
Local aAreaDTY		:= DTY->(GetArea())

Default cContrat  	:= ""
Default cFilOri		:= ""
Default cViagem		:= ""


DTY->(dbSetOrder(2))
If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem + cContrat ))

	SDG->(dbSetOrder(5))
	cSeekSDG  := xFilial("SDG")+ DTY->DTY_FILORI+DTY->DTY_VIAGEM
	bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == cSeekSDG }

	SDG->(dbSeek(cSeekSDG))
	While Eval(bWhileSDG)
		If SDG->DG_DOC <> AllTrim( DTY->DTY_DOCSDG )
			If SDG->DG_ORIGEM <> 'DTY' .And. SDG->DG_ORIGEM <> 'DTR'
				If SDG->(ColumnPos('DG_NUMCTC'))>0
					If SDG->DG_NUMCTC == cContrat
						Reclock("SDG",.F.)
						SDG->DG_NUMCTC := ""
						SDG->( MsUnlock() )
					EndIf
				EndIf
				//Estorna Baixa
				TMSA070Bx("2",SDG->DG_NUMSEQ)
			EndIf
			SDG->(dbSkip())
			Loop
		EndIf

		If cTmsErp == '0' //Protheus
			If SDG->DG_STATUS == StrZero(3, Len(SDG->DG_STATUS)) .And. !Empty(SDG->DG_DTLANC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for Contabilizacao On Line, considera todos os SDG's da Viagem       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lOnline
					nTotal += DetProva(nHdlPrv,"902","TMSA250",cLoteCTC)
					AAdd(aRecSDGBai, SDG->(Recno()) )
				EndIf
			EndIf

			If !Empty(SDG->DG_DTLAEMI)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for Contabilizacao On Line, considera todos os SDG's da Viagem       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lOnline
					nTotal+=DetProva(nHdlPrv,"904","TMSA250",cLoteCTC)
					AAdd(aRecSDGEmi, SDG->(Recno()) )
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estorna somente os SDG's gerados no contrato de carreteiro              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SDG->DG_ORIGEM <> 'DTY'
			If SDG->(ColumnPos('DG_NUMCTC'))>0
				If SDG->DG_NUMCTC == cContrat
					Reclock("SDG",.F.)
					SDG->DG_NUMCTC := ""
					SDG->( MsUnlock() )
				EndIf
			EndIf
			SDG->(dbSkip())
			Loop
		EndIf

		RecLock('SDG',.F.)
		SDG->(dbDelete())
		SDG->(MsUnLock())
		SDG->(dbSkip())
	EndDo

EndIf

RestArea(aAreaDTY)
Return Nil


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250EstVia()
					Atualiza as informações referente a viagem

@author leandro.paulino
@since 12/09/2016
@version 1.0

@param cNumCTC, characters, Número do Contrato
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
/*/

Static Function A250EstVia(cNumCTC, cFilOri, cViagem)

Local cQuery 	 	:= ""
Local cAliasDFV  	:= ""
Local cAliasDUD  	:= ""
// Inicio Redespacho
Local lDelVRdp   	:= .F.
Local cRota		 	:= ""
Local cPercur	 	:= ""
Local aDocAux    	:= Array( 34 )
Local aDocDfv    	:= {}
Local aAreaDTQ   	:= ""
Local nA         	:= 0
Local lTpFrota   	:= DTY->(ColumnPos("DTY_TIPFRO")) > 0
//Fim Redespacho
Local aAreaDTY		:= DTY->(GetArea())
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0

Default cNumCTC		:= ""
Default cFilOri 	:= ""
Default cViagem		:= ""

#IFDEF TOP
	DTY->(dbSetOrder(2))
	If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem + cNumCTC ))
		If DTY->DTY_TIPCTC == StrZero(7, Len(DTY->DTY_TIPCTC))

			cAliasDFV :=GetNextAlias()
			//-- Seleciona todos os Doc. da DUD, do mesmo CTT e que sao Redespacho.
			cQuery := " SELECT DFV.DFV_FILDOC, DFV.DFV_DOC, DFV.DFV_SERIE, DFV.DFV_NUMRED, "
			If lCmpDFV
				cQuery += " DFV.DFV_FILORI, "
			EndIf
			cQuery += "   		 DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.R_E_C_N_O_ "
			cQuery += "   FROM "	+ RetSqlName("DFV") + " DFV, "
			cQuery += "		    "	+ RetSqlName("DUD") + " DUD "
			cQuery += "  WHERE	DFV.DFV_FILIAL	='" + xFilial('DFV') + "' "
			cQuery += "    AND	DFV.DFV_FILDOC	= DUD.DUD_FILDOC "
			cQuery += "    AND	DFV.DFV_DOC		= DUD.DUD_DOC "
			cQuery += "    AND	DFV.DFV_SERIE	= DUD.DUD_SERIE "
			If lCmpDFV //Por se tratar de um campo novo, considerar caso o campo esteja com conteudo vazio
				cQuery += "    AND (DFV.DFV_FILORI	= DUD.DUD_FILORI OR DFV.DFV_FILORI	= ' ') "
			EndIf
			cQuery += "    AND	DFV.DFV_NUMRED	= DUD.DUD_NUMRED "
			cQuery += "    AND	DFV.DFV_NUMCTC	='" + DTY->DTY_NUMCTC + "' "
			cQuery += "    AND	DFV.D_E_L_E_T_ <> '*' "
			cQuery += "    AND	DUD.D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasDFV, .T., .F. )

			//-- Adiciona a Rota
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Formato do vetor aRota                                                ³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³ aRota[01] = Mark                                                      ³
			//³ aRota[02] = Codigo da Rota                                            ³
			//³ aRota[03] = Descricao da Rota                                         ³
			//| aRota[04] = Descricao do Tipo da Rota                                 ³
			//| aRota[05] = Status da viagem                                          ³
			//| aRota[06] = Peso total dos documentos em aberto desta rota            ³
			//| aRota[07] = Peso cubado total dos documentos em aberto desta rota     ³
			//| aRota[08] = Quantidade total de viagens                               ³
			//| aRota[09] = Permite ou nao desmarcar a rota da tela                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			DA8->( DbSetOrder( 1 ) )
			DA9->( dbSetOrder( 1 ) )

			If !DA8->( MsSeek( xFilial("DA8") + PadR( GetMv('MV_ROTGENT'), Len( DA8->DA8_COD ) ) ) )
				Return Nil
			EndIf

			//-- Posiciona em Zonas por Rota para obter zona e setor
			If DA9->( MsSeek( xFilial("DA9") + DA8->DA8_COD ) )
				cPercur := DA9->DA9_PERCUR
				cRota   := DA9->DA9_ROTA
			EndIf

			Aadd( aRota, { .T.,DA8->DA8_COD,,,,,,,.F. } )

			//-- Monta o Array com os Doc. que serão excluidos.
			While (cAliasDFV)->( !Eof() )

				aDocAux := Array( 34 )

				Afill( aDocAux, NIL )

				aDocAux[CTSTATUS]	:= '4'
				aDocAux[CTSTROTA]	:= ''
				aDocAux[CTMARCA] 	:= .T.
				aDocAux[CTARMAZE]	:= ''
				aDocAux[CTLOCALI]	:= ''
				aDocAux[CTFILDOC]	:= (cAliasDFV)->DFV_FILDOC
				aDocAux[CTDOCTO ]	:= (cAliasDFV)->DFV_DOC
				aDocAux[CTSERIE ]	:= (cAliasDFV)->DFV_SERIE
				aDocAux[CTVIAGEM]	:= .T.
				aDocAux[CTDOCROT]	:= DA8->DA8_COD + cPercur + cRota

				Aadd( aDocto, AClone( aDocAux ) )

				Aadd( aDocDfv,{ (cAliasDFV)->DFV_FILDOC, (cAliasDFV)->DFV_DOC, (cAliasDFV)->DFV_SERIE,(cAliasDFV)->DFV_NUMRED,;
					(cAliasDFV)->R_E_C_N_O_, (cAliasDFV)->DUD_FILORI, (cAliasDFV)->DUD_VIAGEM, Iif(lCmpDFV,(cAliasDFV)->DFV_FILORI,'') })

				(cAliasDFV)->( dbSkip() )
			EndDo

			aAreaDTQ  := DTQ->( GetArea() )

			//-- Exclui a Viagem e os Doc. relacionadas a ela.
			DTQ->( dbSetOrder( 2 ) )
			If DTQ->( MsSeek( xFilial("DTQ") + DTY->DTY_FILORI + DTY->DTY_VIAGEM ) )
				RegToMemory( 'DTQ', .F. )
				cSerTms       	:= StrZero( 3, Len( DUD->DUD_SERTMS ) )
				cTipTra       	:= StrZero( 1, Len( DUD->DUD_TIPTRA ) )
				nTipVia       	:= 1
				lTmsCFec      	:= TmsCFec()
				lColeta       	:= .F.
				M->DTQ_SERTMS	:= cSerTms
				M->DTQ_TIPTRA 	:= cTipTra
				MsgRun( "Excluíndo víagem relacionada ao contrato " , "Aguarde" , {|| CursorWait(), lDelVRdp := TmsA141Grv( 5 ), CursorArrow()})
			EndIf

			//-- Apaga o relacionamento da tabela de redespacho, numero do CTC.
			cQuery := " UPDATE " + RetSqlName("DFV") + " SET DFV_NUMCTC ='" + Space(Len(DFV->DFV_NUMCTC)) + "' "
			cQuery += " WHERE	DFV_NUMCTC ='" + (DTY)->DTY_NUMCTC + "' "
			cQuery += "   AND DFV_FILIAL ='" + xFilial('DFV') + "' "
			cQuery += "   AND D_E_L_E_T_ <> '*' "
			TCSqlExec( cQuery )

			//-- Se existir mais de um DUD p/ o documento, o mesmo foi gerado p/ viagem Redespacho, e sera apagado na
			//-- exclusao do contrato, caso contrario sera apenas limpado a viagem.

			For nA :=1 To Len(aDocDfv)
				//-- Verifica qtos DUD existe p/ este Doc., pois em caso de redespacho pode haver mais de um DUD.
				cAliasDUD :=GetNextAlias()
				cQuery := " SELECT COUNT(*) DUD_TOTAL FROM " + RetSqlName('DUD')
				cQuery += " WHERE DUD_FILIAL ='" + xFilial('DUD')		+ "' "
				cQuery += "   AND DUD_FILDOC ='" + aDocDfv[nA , 1]		+ "' "
				cQuery += "   AND DUD_DOC    ='" + aDocDfv[nA , 2]		+ "' "
				cQuery += "   AND DUD_SERIE  ='" + aDocDfv[nA , 3]		+ "' "
				cQuery += "   AND DUD_SERTMS ='" + StrZero(3, Len(DUD->DUD_SERTMS)) + "' "
				cQuery += "   AND DUD_STATUS <>'" + StrZero(9, Len(DUD->DUD_STATUS)) + "'"
				cQuery += "   AND D_E_L_E_T_ <> '*' "

				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasDUD, .T., .F. )

				//-- Em caso de mais de um DUD, deletar o DUD da viagem de redespacho OU apenas apagar o numero do Redespacho.
				If (cAliasDUD)->DUD_TOTAL > 1
					If DTY->( DTY_FILORI + DTY_VIAGEM ) == aDocDfv[nA , 6] + aDocDfv[nA , 7]
						cQuery := " UPDATE " + RetSqlName("DUD") + " SET D_E_L_E_T_ = '*' "
						cQuery += " WHERE	R_E_C_N_O_ =" + AllTrim(Str(aDocDfv[nA , 5]))
						TCSqlExec( cQuery )
					EndIf
				Else
					cQuery := " UPDATE " + RetSqlName("DUD") + " SET DUD_VIAGEM='" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += " WHERE	R_E_C_N_O_ =" + AllTrim(Str(aDocDfv[nA , 5]))
					TCSqlExec( cQuery )
				EndIf

				(cAliasDUD)->( DbCloseArea() )
			Next nA
			RestArea( aAreaDTQ )
			(cAliasDFV)->( dbCloseArea() )
		EndIf

	EndIf

#ENDIF

RestArea(aAreaDTY)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSMSGPARAN³ Autor ³ Clovis Nunes do Nascimento    ³21/10/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria cria vetor com mesagens que será utilizado na rotina   ³±±
±±³           TMA250Param, para geração do LOG de processamento    		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSMSGPARAN(aMsgJob)

AADD(aMsgJob,STR0200) 			//--> esta vazio ... E Obrigatorio preenche-lo para geracao do Contrato de Carreteiro
AADD(aMsgJob,STR0201)		 	//--> Conteudo do parametro invalido MV_NATPDG:
AADD(aMsgJob,STR0202)			//--> Conteudo do parametro invalido MV_NATDEB:
AADD(aMsgJob,STR0203)			//--> A Natureza de Debito não deve calcular impostos para não gerar titulos indevidos, conteudo do parametro invalido MV_NATDEB:
AADD(aMsgJob,STR0204)			//--> Nao encontrou na Tabela '05', o tipo do Titulo que sera utilizado para esta Filial. Tipo do Titulo a ser cadastrado:
AADD(aMsgJob,STR0205) 			//-->Conteudo do parametro invalido MV_TPTPDG:
AADD(aMsgJob,STR0206) 			//--> Conteudo do parametro invalido MV_TPTPRE:
AADD(aMsgJob,STR0207) 			//--> Conteudo do parametro invalido MV_DESCTC:
AADD(aMsgJob,STR0208) 			//--> Conteudo do parametro invalido MV_DESPDG:
AADD(aMsgJob,STR0209) 			//--> Conteudo do parametro invalido MV_DESPRE:
AADD(aMsgJob,STR0210) 			//--> O Tipo de Contrato de Carreteiro e o Tipo de Contrato de Pedagio estao iguais ...
AADD(aMsgJob,STR0211) 			//--> O Tipo de Contrato de Premio de Carreteiro esta' igual ao Tipo de Contrato de Carreteiro ...
AADD(aMsgJob,STR0212) 			//--> Favor alterar no configurador, o tamanho do campo E2_PARCELA para 2

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS250LOG³   Autor ³ Clovis Nunes do Nascimento    ³21/10/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava log de processamento em local pre definido pelo para- ³±±
±±³           metro MV_TMS250LG.                                     		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS250LOG(a250Msg)

Local cBarra		:= If(issrvunix(), "/", "\")
Local cStartPath	:= cStartPath := GetSrvProfString("StartPath","") + If(Right(GetSrvProfString("StartPath",""),1) == cBarra,"",cBarra) // GetSrvProfString("Startpath","")
Local cPastLog    := GetNewPar("MV_TMS250LG",cStartPath)	//--> Diretório onde será gravado o arquivo de processamento da rotina TMSA250 executada via SCHEDULE.
Local x 			:= 0
Local cTXTLog 	:= ""
Local cNomArq 	:= "LOG_TMSA250_"+STR0213+" "+cEmpAnt+"_"+STR0214+" "+ cFilAnt +"_"+DtoS(Date())+"_"+SubStr(Time(),1,2)+SubStr(Time(),4,2)+".TXT" //--> STR0213 - EMPRESA | STR0214= FILIAL

If Len(a250Msg) == 0
	AADD(a250Msg,{"", "","TMSA250"})
EndIf

//--> Caso o parametro esteja vazio, o log será gerado na pasta /SYSTEM/
If Empty(cPastLog)
	cPastLog := cStartPath
EndIf

cLocLog := cPastLog+cNomArq

For x:= 1 to Len(a250Msg)
	cTXTLog += a250Msg[x,1] + " - " + a250Msg[x,3] + Chr(13) + Chr(10)
Next

If MemoWrite(cLocLog, cTXTLog)
	//--> STR0217 = LOG DE PROCESSAMENTO TMSA250() GERADO COM SUCESSO. ARQUIVO:
	//--> STR0218 = DIRETORIO:
	TmsLogMsg(,STR0217+" "+cNomArq+STR0216+" "+cPastLog)
Else
	//--> STR0218 = ERRO:
	//--> STR0219 = NAO FOI POSSIVEL GERAR O LOG DE PROCESSAMENTO TMSA250() NO DIRETORIO:
	TmsLogMsg(,STR0219+" "+cPastLog+" "+STR0218+" "+Str(FError(),4) )
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS250LOG³   Autor ³ Clovis Nunes do Nascimento    ³21/10/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona mensagens que serão gerados no log de processame   ³±±
±±³            nto.                                                   		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A250MsgAdd(cTMS250MSG,cTMS250FU)

AADD(aMsgErPa,{cTMS250MSG,'', cTMS250FU})

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GerLogPerg³  Autor ³ Clovis Nunes do Nascimento    ³23/10/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava as perguntas definidas na configuração o do SCHEDULE  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GerLogPerg(cNomPerg)

Local cLogPerg  := ""
Local nY        := 0
Local cX1Def	:= ""
Local oObj 		:= FWSX1Util():New()

oObj:AddGroup(cNomPerg)
oObj:SearchGroup()

If Len(oObj:aGrupo[1][2]) > 0
	cLogPerg += "PARAMETROS DEFINIDO NO SCHEDULE TMSA250()"
	For nY := 1 To Len(oObj:aGrupo[1][2])
		If oObj:aGrupo[1][2][nY]:CX1_GSC == "G" .And. oObj:aGrupo[1][2][nY]:CX1_TIPO == "C"
			cLogPerg += oObj:aGrupo[1][2][nY]:CX1_ORDEM + " - " + PadR(oObj:aGrupo[1][2][nY]:CX1_PERGUNT,30) + " " + &(oObj:aGrupo[1][2][nY]:CX1_VAR01) + CHR(13) + CHR(10)
		ElseIf oObj:aGrupo[1][2][nY]:CX1_GSC == "G" .And. oObj:aGrupo[1][2][nY]:CX1_TIPO == "N"
			cLogPerg += oObj:aGrupo[1][2][nY]:CX1_ORDEM + " - " + PadR(oObj:aGrupo[1][2][nY]:CX1_PERGUNT,30) + " " + cValToChar(&(oObj:aGrupo[1][2][nY]:CX1_VAR01))	+ CHR(13) + CHR(10)
		ElseIf oObj:aGrupo[1][2][nY]:CX1_GSC == "C" .And. oObj:aGrupo[1][2][nY]:CX1_TIPO == "N"
			cX1Def := "SX1->X1_DEF"+StrZero(&(oObj:aGrupo[1][2][nY]:CX1_VAR01),2)
			cLogPerg += oObj:aGrupo[1][2][nY]:CX1_ORDEM + " - " + PadR(oObj:aGrupo[1][2][nY]:CX1_PERGUNT,30) + " " + &(cX1Def) + CHR(13) + CHR(10)
		ElseIf oObj:aGrupo[1][2][nY]:CX1_GSC == "G" .And. oObj:aGrupo[1][2][nY]:CX1_TIPO == "D"
			cLogPerg += oObj:aGrupo[1][2][nY]:CX1_ORDEM + " - " + PadR(oObj:aGrupo[1][2][nY]:CX1_PERGUNT,30) + DtoC(&(oObj:aGrupo[1][2][nY]:CX1_VAR01))	+ CHR(13) + CHR(10)
		EndIf
	Next
	cLogPerg += Repl("-",100)
	A250MsgAdd(cLogPerg,"")
EndIf

FreeObj(oObj)

Return Nil

/*/

/*----------------------------------------------------------------------
{Protheus.doc} Tmsa250Prc()
Gera os Contratos de Carreteiro

@Parametros ExpC1 - Alias do Arquivo
			ExpN1 - Opcao Selecionada (3-Por Viagem / 4-Por Periodo)
			ExpC2 - Filial de Origem
			ExpC3 - Viagem
			ExpL1 - Gera Contrato de Premio p/ Motorista. Esta variavel
        			passada pelo programa de Pagto de Premio (TMSA740)
			ExpN2 - Valor do Premio do Motorista calculado pelo TMSA740
			ExpA1 - Array contendo as mensagens de erro
			ExpN3 - Informa para qual(is) do(s) veículo(s) deve gerar
        			contrato.  1=Veiculo; 2=Reboque;  3=Ambos.
					Isto para quando os fornecedores sejam diferentes.
			ExpC4 - Tipo do Contrato a ser gerado:
					1=Por Viagem;
					2=Por Periodo;
					3=Por Premio;
					4=Adiantamento;
					5=Complemento;
					6=Carga;
					7=Redespacho)
			ExpC5 - Codigo do Fornecedor
			Expc6 - Loja do Fornecedor
			ExpL2 - Informa se a viagem é Express
			ExpL3 - Informa se será exibido o preview do frete a pagar
			ExpC7 - Informa o tipo do título a ser gerado no Financeiro.

@Retorno   NIL

Uso: TMSA250 / TMSA740

@sample
//Tmsa250Prc()

@author Patricia A. Salomao
@since 22.02.2002
@version 1.0
----------------------------------------------------------------------/*/
Function TMSA250Prc(cAlias, nOpcx, cFilOri, cViagem, lCtrPremio, nValPremio, aVisErr, nGerContr, cTipCont, cForn, cLoj, lVgeExpr, lPreview,cTipCTC,aCTCGer)
Local nCnt         := 0
Local cVeiGen      := GetMv( 'MV_VEIGEN',, '' ) // Veiculo generico.
Local cMotGen      := GetMv( 'MV_MOTGEN',, '' ) // Motorista generico.
Local cVeiRede     := GetMv( 'MV_VEIREDE',, '' ) // Veiculo generico do Redespacho.
Local cMotRede	   := GetMv( 'MV_MOTREDE',, '' ) // Motorista generico do Redespacho.
Local cEnRepom     := SuperGetMV('MV_ENREPOM',,"1")
Local nTotRegs     := nValFrete  := nTotValAdi:= nBasImp := 0
Local nValIRRF     := nValINSS   := nValSEST  := nValISS := nValRetPIS := nValRetCOF  := nValRetCSL := nValSestId := nValSenat := 0
Local nQtdOco      := nPesOco    := nQtdDoc   := 0
Local nDiaSem      := nDiaFimSem := nQtdKm    := nSeek   := nSeekFor  :=0
Local nItem        := nTotAdiNDF := nSalFre   := 0
Local cCondPag     := cTabFre    := cTipTab   := cTabCar := ''
Local cPrefAnt     := cFilDeb    := ''
Local cPrefDeb     := cSeek      := ''
Local cCodForn     := cLojForn   := cTipVei   := ''
Local cCodFav      := cLojFav    := ''
Local cDocSDG      := cTipDeb    := ''
Local bWhile       := {||.T.}
Local bWhile2      := {||.T.}
Local aAreaDTQ     := DTQ->( GetArea() )
Local aAreaDTY     := DTY->( GetArea() )
Local aArrayFor    := {}
Local aRet         := {}
Local aDadosCTC    := {}
Local aFrete       := {}
Local aMsgErr      := {}
Local aFornec      := {}
Local aSX5		   := {}
Local aRotOld      := AClone(aRotina)
Local lAberto      := .F.
Local lManifesto   := .F.
Local lTransito    := .F.
Local lVazia       := .F.
Local lBloqueio    := .T.
Local lChgParc     := .F.
Local lFechada     := .F.
Local lEncerrada   := .F.
Local lContrato    := .T.
Local lContinua    := .T.
Local lGerAdtPro   := GetMV('MV_ADTPRO' ,,.F.)			// Gera Adiantamento para Motorista Proprio ?
Local lEmptyTptCTC := Empty(GetMV('MV_TPTCTC' ,,''))	// Verifica se o parametro de Tipo do Contrato de Carreteiro esta vazio
Local lAglutina
Local lDigita
Local cGerTitPDG   := "1"
Local cGerTitCont  := "1"
Local cDedPDG      := "2"
Local aPropriet    := {}
Local cMay         := ""
Local cQuery       := ""
Local cAliasQry    := GetNextAlias()
Local lRet         := .T.
Local cCodVei      := ""
Local cFroVei      := ""
Local nValPedag    := 0
Local cTpVeiculo   := ""
Local cCodMot      := ""
Local nGrupVei     := 0
Local nRec         := 0
Local cGerPC       := ''
Local lLibCTC      := SuperGetMV( 'MV_LIBCTC' ,,.F.) //Habilita o controle de Liberação de Contratos de Carreteiro? (T = Habilita / F = Desabilita)
Local lTmsDiaV     := SuperGetMV( 'MV_TMSDIAV',,.F.) //Calcula a quantidade do compoenente Diaria (54 e 60) por Fornecedor e Veículo
Local lTMSOPdg     := SuperGetMV('MV_TMSOPDG' ,,'0') == '2'
Local aDadOperad   := {}
Local cSeekVei     := ""
Local bWhileVei    := {|| .T. }
Local cAliasVei    := ""
Local cAliasCTC    := ""
Local cSeekSDG     := ""
Local bWhileSDG    := {|| .T. }
Local lCpoInsR     := SE2->(ColumnPos('E2_INSSRET')) > 0
Local nMoeda       := 1
Local lCpoMoeda    := DTY->(ColumnPos("DTY_VLMOED")) > 0 .And. DTY->(ColumnPos("DTY_MOEDA")) > 0
Local lQbrVei      := .T.
Local aDiaHist     := {}
Local aDiaRet      := {}
Local aVenctos     := {}
Local cRotMun      := ""
Local cFilAtu      := cFilAnt
Local cVsRepom     := SuperGetMV( 'MV_VSREPOM',, '0' )
Local cTMSOPdg     := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local cCodOpe      := ''
Local lPerAdi      := .F. // Campo de percentual de adiantamento existe e tem valor?  | Repom
Local aAreaSDG 	   := {}
Local cSerOld	   := ''
Local nCount	   := ''
Local cFroCar      := ''
Local lTMA250Vei   := ExistBlock("TMA250VEI")
Local lTercRbq     := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local aTabPag	   := {}
Local nTab		   := 0
Local aTabPagCar   := {}
Local nLinha	   := 0
Local lTpFrota     := DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local nMaxCus      := 0
Local lTela        := .T.
Local cTitFrete    := ''
Local cbxTitPDG    := ''
Local cTitNDF      := '2' //--(1=Sim;2=Não) - Controla se gera NDF no momento da geração do contrato mesmo que a lliberação do contrato esteja habilitada (MV_LIBCTC == .T.)
Local cMomTitPDG   := '1'
Local lPaMovBco	   := .F.
Local lPerCus      := DTY->(ColumnPos("DTY_PERCUS")) > 0
//-- Variavéis que serão utilizadas quando a rotina TMSA250 for executada via SCHEDULE.
Local cTXTLG250    := ""
Local _nY          := 0
Local lRetPvw      := .T.
Local lTabDDH      := AliasIndic("DDH")
Local aParam       := {}
Local cNatuCTC     := ""
Local cCodDesCTC   := TMSA250Var("DES")
Local cMomTitAdi   := ""
Local nAcresc	   := 0
Local nDecresc	   := 0
Local cPerg		   := ''
Local nVlrReem	   := 0
/*
Variáveis utilizadas para query através da função a250QryCTC()
*/
Local cSerTransp:= ""
Local dDataDe	:= CtoD(Space(08))
Local dDataAte	:= CtoD(Space(08))
Local cFornDe	:= ""
Local cLojaDe	:= ""
Local cFornAte	:= ""
LOcal cLojaAte	:= ""
Local cCTCKey   := ""
Local cImpCTC   := SuperGetMv("MV_IMPCTC",,"0")
Local aDocNPrev := {}
Local lCiotPer  := DTR->(ColumnPos("DTR_CIOT")) > 0 .And. DTR->(ColumnPos("DTR_TPCIOT")) > 0
Local cNumCiot	:= ''
Local aDadosPeCP := {}
Local lCmOnLine  := .F. //Custo médio online. Criado para tratar inconsistência do projeto SonarQube
Local cFilAntBkp := cFilAnt //--Variável de backup da cfilAnt, já que a mesma pode ser alterada, devido ao parâmetro mv_par08 na geração de CTc por viagem.
//-- Variaveis utilizadas pela funcao FA050NAT2 (Fina050)
Private lF050Auto  := .F.
Private lAltera    := .F.
Private nOldValor  := 0
Private nOldIrr    := 0
Private nOldIss    := 0
Private nOldInss   := 0
Private nOldSEST   := 0
Private lGerTit    := GetMV('MV_GERTIT' ,,.T.) // Verifica se devera gerar ou nao contas a pagar (SE2). Esta variavel e' Private, pois pode ser manipulada em algum PE. NAO RETIRAR !!!
//--As variaveis cNumCTC, cFilVge, cNumVge, cCodCar e cSeqCar sao utilizadas em validacoes
//da rota municipal pela funcao FA050NAT2
//Quando a rota e municipal geramos titulos de ISS
Private cNumCTC   := ''
Private cFilVge   := ''
Private cNumVge   := ''
Private cCodCar   := ''
Private cSeqCar   := ''
Private nValDig   := 0

lContGerado       := .F.  //Contrato ainda não foi gerado
lCmOnLine         := Type("lOnline") == "L" .And. lOnline

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a rotina estiver sendo chamada pelo programa TMSA740 e o custo medio for     ³
//³ calculado On Line, criar as variaveis para contabilizacao.                      ³
//³ Isto porque, nao existe no TMSA740 a declaracao destas variaveis                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(lCtrPremio) == "L" .And. lCmOnLine .And. cTmsErp == '0'
	Private nHdlPrv				// Endereco do arquivo de contra prova dos lanctos cont.
	Private lCriaHeader := .T.	// Para criar o header do arquivo Contra Prova
	Private cLoteCTC			// Numero do lote para lancamentos do TMS
	Private nTotal      := 0	// Total dos lancamentos contabeis
	Private cArquivo			// Nome do arquivo contra prova
	Private aRecSDGBai  := {}	// Contabiliza a partir da Baixa da Despesa
	Private aRecSDGEmi  := {}	// Contabiliza a partir da Emissao da Despesa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSX5 := FWGetSX5("09","TMS")
	cLoteCTC:=IIF(!Empty(aSX5),aSX5[1][4],"TMS ")
EndIf

Default cTipCont   := ''
Default cFilOri    := ""
Default cViagem    := ""
Default lCtrPremio := .F.
Default nValPremio := 0
Default aVisErr    := {}
Default nGerContr  := 1 //Informa para quem deve ser gerado o contrato. 1= Veiculo;  2 = Reboque;  3= Ambos
Default cForn      := ''
Default cLoj       := ''
Default lVgeExpr   := .F.
Default lPreview   := .F.
Default cTipCTC	   := ""
Default aCTCGer    := {}

If nOpcx == 3  // Gera Contrato por Viagem ou Carga

	//-- Se a Rotina NAO estiver sendo chamada pelo programa de Pagamento de Premio (TMSA740)
	If !Empty(mv_par08) .And. FunName() <> "TMSA740"
		cFilAnt  := mv_par08 // Filial Origem ( Parametro ) //--Não é necessário efetuar o PADL, pois o Frame já trata o recebimento do conteúdo na varíavle cFilAnt
	EndIf
	cTipCont := "1" // por viagem
	cAliasCTC:= "DTQ"
	cPerg    := "TMA250"
	If !lCtrPremio
		bWhile   := {|| DTQ->(!Eof()) .And. DTQ->DTQ_FILIAL == xFilial("DTQ") .And. DTQ->DTQ_FILORI == cFilAnt .And. DTQ->DTQ_VIAGEM <= MV_PAR02 }
		lRet := A250VldPrc(nOPcx,lVgeExpr)
		If lRet

			cTipVei := A250RtTpVe(MV_PAR05,lGerAdtPro,lTpFrota)

			If lTabDDH .And. Type('Mv_par09') == 'N'
				If MV_PAR09 == 1
					lPreview := .T.
				Else
					lPreview := .F.
				EndIf
			EndIf
	     Else
		 	cFilAnt := cFilAntBkp
	        Return .F. //| Se não integração com repom cancela envio
		EndIf
	Else
		cAliasCTC:= "DTQ"
		DTQ->(dbSetOrder(2))
		DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem))
		bWhile     := { || DTQ->(!Eof()) .And. DTQ->DTQ_FILIAL == xFilial("DTQ") .And. DTQ->DTQ_FILORI == cFilOri .And. DTQ->DTQ_VIAGEM == cViagem}
		cTipCont   := If(cTipCont=='7',cTipCont,'3') //-- Gera Contrato de Premio
		lContrato  := .F.
		lGerTit    := .T.
		If lGerAdtPro //-- Se Gera Adiantamento para Motorista Proprio (MV_ADTPRO)
			cTipVei := '1;2;3'
		Else
			cTipVei := '2;3'
		EndIf
	EndIf

	bWhile2 := {|| cCTCKey == DTQ->(DTQ_FILORI + DTQ_VIAGEM) }
	If FindFunction('TMSA250A') .And. DUD->(ColumnPos('DUD_DTRNPR')) > 0 .And. !TMSA250A(Nopcx, MV_PAR01, MV_PAR02, MV_PAR08, ,aDocNPrev )
		cFilAnt := cFilAntBkp
		Return Nil
	EndIf


Else // Gera Contrato Por Periodo

	lRet := A250VldPrc(nOpcx,lVgeExpr)
	If lRet
		lQbrVei := (mv_par08 == 1)

		cTipCont   	:= '2'
		cPerg      	:= "TM250A"

		bWhile    	:= { || (cAliasCTC)->(!Eof()) }
		cSerTransp 	:= MV_PAR01
		dDataDe		:= MV_PAR02
		dDataAte	:= MV_PAR03
		cFornDe		:= MV_PAR04
		cLojaDe		:= MV_PAR05
		cFornAte	:= MV_PAR06
		cLojaAte	:= Mv_PAR07
		/*Gerar Função que retorne resultado da Query, com as viagens do período selecionado*/
		cAliasCTC 	:= a250QryDTQ (cSerTransp,dDataDe,dDataAte,cFornDe,cLojaDe,cFornAte,cLojaAte)
		If FindFunction('TMSA250A') .And. DUD->(ColumnPos('DUD_DTRNPR')) > 0 .And. !TMSA250A(nOpcx, , , cFilAnt , cAliasCTC, aDocNPrev)
			Return Nil
		EndIf
		cTipVei 	:= A250RtTpVe(mv_par12,lGerAdtPro,lTpFrota)
		(cAliasCTC)->(DbGoTop())
    Else
          Return .F.
	EndIf

	If lCpoMoeda
		nMoeda := IIf(Empty(mv_par15),1,mv_par15)
	EndIf

	If ExistBlock('TMA250PAR')
		aParam := ExecBlock('TMA250PAR',.F.,.F.,{nOpcx})
		If ValType(aParam) == "A" .And. Len(aParam) == 8
			lAberto    := aParam[1]
			lManifesto := aParam[2]
			lTransito  := aParam[3]
			lVazia     := aParam[4]
			lBloqueio  := aParam[5]
			lChgParc   := aParam[6]
			lEncerrada := aParam[7]
			lFechada   := aParam[8]
		EndIf
	EndIf

	bWhile2 := { || cCTCKey == (cAliasCTC)->(DTR_CODFOR + DTR_LOJFOR + DA8_ROTMUN) + IIF(lQbrVei,(cAliasCTC)->DTR_CODVEI,"") + IIF(lCiotPer,(cAliasCTC)->DTR_CIOT,"") }
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCmOnLine
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se necessario cria o cabecalho do arquivo de prova           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCriaHeader
		lCriaHeader := .F.
		nHdlPrv := HeadProva(cLoteCTC,"TMSA250",cUserName,@cArquivo)
		If nHdlPrv < 0
			If !lExcSched250
				Help(" ",1,"SEM_LANC") //"Nao foi possivel abrir o arquivo de Contra Prova"
				cFilAnt := cFilAntBkp
				Return .F.
			Else
				cTXTLG250 :=  STR0192 //--> Nao foi possivel abrir o arquivo de Contra Prova.
				AADMsgTMS250(cTXTLG250,"TMSA250" )
				cFilAnt := cFilAntBkp
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf

//+--------------------------------------------------------------
//| Main Looping
//+--------------------------------------------------------------
While Eval(bWhile)

Begin Transaction

     //| Monta chave para quebra do looping abaixo.
     If nOpcx == 3
          cCTCKey := DTQ->(DTQ_FILORI + DTQ_VIAGEM)
     Else
          cCTCKey := (cAliasCTC)->(DTR_CODFOR + DTR_LOJFOR + DA8_ROTMUN) + IIF(lQbrVei,(cAliasCTC)->DTR_CODVEI,"") + IIF(lCiotPer,(cAliasCTC)->DTR_CIOT,"")
     EndIf
     //+------------------------------------------------------------------------------------
     //| Looping de geração do contrato carreteiro
     //| Foi realizado alterações para tratar a integração de contrato por período
     //| Inicio da transação
     //| Quando por periodo Gera 'n' DTY's com mesmo número de contrato.
     //| Quebra será realizada observando a matriz aDadosCTC, quando o próximo registro
     //| for diferente da chave Cod.For + Loj.For + Tipo Rota, chama a rotina 250QBR
     //| efetiva o commit e reseta a matriz aDadosCTC
     //+------------------------------------------------------------------------------------
     While Eval(bWhile2)

		//--FORCA POSICIONAMENTO NO DTQ CONFORME
		//--PROCESSAMENTO DA QUERY:
		If nOpcx == 4
			DTQ->( DbGoTo( (cAliasCTC)->DTQRec ) )
		EndIf

		//-- A Finalidade deste Ponto de Entrada e' validar se devera' Gerar OU Nao Contrato de Carreteiro
		//-- para a viagem posicionada
		If lTMA250Fil
			lContinua := ExecBlock('TMA250FIL',.F.,.F., {DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, nOpcx} )
			If	ValType(lContinua) <> 'L'
				lContinua := .T.
			EndIf
			If !lContinua
				(cAliasCTC)->(dbSkip())
				Loop
			EndIf
		EndIf

		lRet     := .T.
		aMsgErr  := {}

		aAreaDTQ := DTQ->(GetArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros da TMSChkViag :                         ³
		//³                                                   ³
		//³01- Filial de Origem                               ³
		//³02- No. da Viagem                                  ³
		//³03- Verifica se a viagem esta em aberto            ³
		//³04- Verifica se ha manifesto                       ³
		//³05- Verifica se ha contrato de carreteiro          ³
		//³06- Emite help se houver restricoes                ³
		//³07- Travar o registro da viagem                    ³
		//³08- Verifica se ha complemento de viagem           ³
		//³09- Verifica se a viagem esta em transito          ³
		//³10- Verifica se viagem vazia                       ³
		//³11- Verifica se a viagem esta bloqueada            ³
		//³12- Vetor contendo as mensagens do Help            ³
		//³13- Chegada Parcial ?                              ³
		//³14- Verifica Viagem Encerrada                      ³
		//³15- Verifica Viagem Fechada                        ³
		//³16- Verifica se ha operacoes encerradas            ³
		//³17- Verifica se a viagem esta cancelada            ³
		//³18- Verifica se a viagem e planejada.              ³
		//³19- Filial Atual                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := TMSChkViag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, lAberto, lManifesto, .F., .F., .F., .T., lTransito, lVazia, lBloqueio, @aMsgErr, lChgParc, lEncerrada, lFechada, , , , cFilAtu)
		If lRet
			nTotRegs := (cAliasCTC)->(RecCount())
			If !lExcSched250
				ProcRegua(nTotRegs,16,4)
			EndIf

			cCodFav := ""
			cLojFav := ""
			//-- Complemento de Viagem
			DTR->(dbSetOrder(1))
			cSeekVei  := xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
			bWhileVei := {|| DTR->(! Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM == cSeekVei }
			cAliasVei := 'DTR'

			If (cAliasVei)->(MsSeek(cSeekVei))

				While Eval(bWhileVei) .And. lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Preenche Array com todos os Fornecedores dos veículos da viagem³
					//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
					//³Parametros da aFornec:                                         ³
					//³01- Codigo do Fornecedor                                       ³
					//³02- Loja do fornecedor                                         ³
					//³03- Codigo do Veiculo ou do Reboque                            ³
					//³04- Tipo da frota  1=Própria; 2=Terceiro; 3=Agregado           ³
					//³05- Tipo do Veiculo                                            ³
					//|06- Grupo de Veiculo  0=Veiculo  1=1o Reb.  2=2oReb. 3=3oReb.  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aFornec	:= TMA250Forn(nGerContr,cTipCont,"DTR")
					If !lVgeExpr
						If nOpcx <> 5 .And. !Empty(DTR->DTR_CODOPE) .And. DTQ->DTQ_STATUS $ ('1|9')  //nao permitir gerar contrato se administrado pela Repom
							If !lExcSched250
								Aviso( STR0085 , STR0151 + " " + DTQ->(DTQ_FILORI + "/ " + DTQ_VIAGEM) ,{STR0086}) //--"Aviso"###"Contrato não poderá ser gerado porque a viagem está integrada junto a operadora de Frota e está com o status em aberto ou cancelada."
							Else
								cTXTLG250 := STR0151
								AADMsgTMS250(cTXTLG250,"TMSA250")
							EndIf
							lRet := .F.
							EXIT
						EndIf
					EndIf
					//--- Nao gerar contrato para Pagamento via SIGAGFE
					If DTQ->(ColumnPos('DTQ_PAGGFE')) > 0 .And. DTQ->DTQ_PAGGFE == StrZero(1, Len(DTQ->DTQ_PAGGFE))  //Sim
						AAdd( aMsgErr, { STR0264 + DTR->DTR_FILORI + '/' + DTR->DTR_VIAGEM + "." + STR0265 } )  // "Contrato não poderá ser gerado para a viagem: #  Pagamento será efetuado pelo SIGAGFE"
						lRet := .F.
						Exit
					EndIf
					For nCnt := 1 To Len(aFornec)
						cTabFre    := ''
						cTipTab    := ''
						cTabCar    := ''
						nValFrete  := 0
						nBasImp    := 0
						nQtdOco    := 0
						nPesOco    := 0
						nQtdDoc    := 0
						nDiaSem    := 0
						nDiaFimSem := 0
						nQtdKm     := 0
						lRet       := .T.
						cGerTitPDG := "1"
						cDedPDG    := "2"

						If cTipCont =='7' //-- Tipo '7', Redespacho
							cCodForn   := cForn
							cLojForn   := cLoj
							cCodVei    := cVeiRede // Veiculo generico do Redespacho.
							cMotGen    := cMotRede // Motorista generico do Redespacho.
							DA3->(dbSetOrder(1))
							If DA3->(MsSeek(xFilial('DA3')+cCodVei))
								cFrovei    := DA3->DA3_FROVEI
								cTpVeiculo := DA3->DA3_TIPVEI
								nGrupVei   := 0
							EndIf
						Else
							cCodForn   := aFornec[nCnt,1]
							cLojForn   := aFornec[nCnt,2]
							cCodVei    := aFornec[nCnt,3]
							cFrovei    := aFornec[nCnt,4]
							cTpVeiculo := aFornec[nCnt,5]
							nGrupVei   := aFornec[nCnt,6]
							If lCiotPer
								cNumCiot   := DTR->DTR_CIOT
							EndIf
						EndIf
						nRec := 0
						If lContrato
							cQuery := " SELECT Count(*) nCount "
							cQuery += "	  FROM " + RetSqlName("DTY")
							cQuery += "	  WHERE DTY_FILIAL = '" + xFilial("DTY") + "' "
							cQuery += "	    AND DTY_FILORI = '" + DTQ->DTQ_FILORI	+ "' "
							cQuery += "	    AND DTY_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
							cQuery +=    " AND ((DTY_CODFOR = '" + cCodForn + "' AND DTY_LOJFOR = '" + cLojForn + "') "
							If (!Empty(DTR->DTR_CREADI) .And. !Empty(DTR->DTR_LOJCRE) ) .And.  ( DTR->DTR_CREADI <> cCodForn .Or. DTR->DTR_LOJCRE <> cLojForn )
							   cQuery +=  " OR (DTY_CODFOR = '" + DTR->DTR_CREADI + "' AND DTY_LOJFOR = '" + DTR->DTR_LOJCRE + "') "
							EndIf
							cQuery +=    ")"
							If lQbrVei .And. !Empty(cCodVei)
								cQuery += "	    AND DTY_CODVEI = '" + cCodVei + "' "
							EndIf
							cQuery += "	    AND D_E_L_E_T_ = ' ' "

							cQuery := ChangeQuery(cQuery)
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
							nRec := (cAliasQry)->nCount
							(cAliasQry)->( DbCloseArea() )
						EndIf

						If nRec == 0
							If nOpcx == 4 .And. mv_par11 == 1 //-- Somente Viagens OK
								//-- Verifica se devera gerar contrato para o proprietario.
								If Ascan( aPropriet, { |x| x[1]+x[2] == cCodForn + cLojForn } ) > 0
									Exit
								EndIf
							EndIf

							If cCodVei == cVeiGen .And. cTipCont <> '7'
								AAdd( aMsgErr, { STR0024 +  DTR->DTR_FILORI + '/' + DTR->DTR_VIAGEM + STR0025 + cCodVei + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim(Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NREDUZ"))+ ' )' , '01', "TMSA240()" } ) //"Nao pode ser informado veiculo generico para a Viagem " ### "Veiculo " ### "Proprietario "
								lRet := .F.
								Exit
							EndIf

							SA2->(dbSetOrder(1))
							SA2->(MsSeek(xFilial("SA2")+cCodForn+cLojForn) )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Nao Gerar contrato, se foi informado Motorista generico para a viagem    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DUP->(dbSetOrder(2))
							If !Empty(cMotGen) .And. DUP->(MsSeek(xFilial('DUP')+DTR->DTR_FILORI+DTR->DTR_VIAGEM+cMotGen)) .And. cTipCont <>'7'
								AAdd( aMsgErr, { STR0027 + DTR->DTR_FILORI + '/' + DTR->DTR_VIAGEM + STR0025 + cCodVei + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim(Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NREDUZ"))+ ' )' , '01', "TMSA240()" } ) //"Nao pode ser informado motorista generico para a Viagem " ### "Veiculo" ### "Proprietario "
								lRet := .F.
								Exit
							EndIf
							//-- Motorista da Viagem
							DUP->(dbSetOrder(1))
							If DUP->(!dbSeek(xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM)) .Or. Empty(DUP->DUP_CODMOT)
								DUT->(dbSetOrder(1))
								If DUT->(MsSeek(xFilial("DUT")+cTpVeiculo))
									If DUT->DUT_CATVEI <> '4' //Não checa se tem motorista para veiculos especiais.
										AAdd( aMsgErr, { STR0028 +  DTR->DTR_FILORI + '/' + DTR->DTR_VIAGEM + STR0025 + cCodVei + ' - ( ' + STR0026 + ' - ' + AllTrim(Posicione("SA2",1,xFilial("SA2")+cCodForn+"/"+cLojForn,"A2_NREDUZ"))+ ' )' , '01', "TMSA240()" } ) //"Nao foi Informado motorista para a Viagem " ### "Veiculo" ### "
										lRet := .F.
										Exit
									EndIf
								EndIf
							EndIf

							cCodMot := Iif(Empty(DUP->DUP_CODMOT), cMotGen, DUP->DUP_CODMOT)
							If lTMA250Vei
								cFroCar := 	ExecBlock('TMA250VEI',.F.,.F.,{cFroVei})
								If ValType(cFroCar) <> 'C'
									cFroCar := ""
								EndIf
							EndIf

							If !Empty(cTipVei) .And. cFroVei $ cTipVei
								If cFrovei == "2" .Or. cFrovei == "3" .Or. ( cFroVei == "1" .And. lTpFrota ) .Or. cFroCar == "1" // Tipo da Frota : Terceiro ou Agregado

									If Empty(cCodForn) .Or. Empty(cLojForn)
										AAdd( aMsgErr, { STR0031 +  DTQ->DTQ_FILORI+'/'+DTQ->DTQ_VIAGEM + ', ' + STR0032 + cCodVei , '02', "OMSA060()" } ) //"Para Calcular o Contrato da Viagem " ### "informe o Proprietario do Veiculo :"
										lRet := .F.
										Exit
									EndIf

									//-- Verifica a Filial de Debito (posiciona no arquivo SA2)
									cFilDeb := TMSA250FilDeb(cCodForn,cLojForn,@cCodFav,@cLojFav,nOpcx<>4,,,Iif(nOpcx == 3 .And. cFilAtu <> cFilAnt,.T.,.F.),cCodVei)

									If lEmptyTptCTC
										cTipDeb := Padr( "C"+cFilDeb, Len( SE2->E2_TIPO ) )
									Else
										cTipDeb := cTipCTC //--Se esta preenchido utilizo o conteudo do MV_TPTCTC
									EndIf

									If Empty(Tabela("05",cTipDeb,.F.))
										AAdd( aMsgErr, { STR0029 +  cFilDeb + '. ' + STR0030 + cFilDeb , '01', "" } ) //"Nao encontrou na Tabela "05", o tipo do Titulo que sera utilizado para a Filial de Debito : " ### "Tipo do Titulo a ser cadastrado : C"
										lRet := .F.
										Exit
									EndIf

									If !Empty(SA2->A2_NATUREZ)
										cNatuCTC := SA2->A2_NATUREZ
									Else
										If lTM250Par
											cNatuCTC := ExecBlock('TM250PAR',.F.,.F.,{1})
											If ValType(cNatuCTC) <> 'C'
												cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
											EndIf
										Else
											cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
										EndIf
									EndIf

									If cTMSERP == "0" //-- Validação de Natureza é realizado apenas quando houver a integração com SigaFin (com Datasul, cTMSERP = '1', não é validado)
										If Empty(cNatuCTC)
											AAdd( aMsgErr, { STR0014 + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim(Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NREDUZ"))+ ' ) ' + Alltrim(FWX3Titulo('DTY_VIAGEM')) + ': ' + DTQ->(DTQ_FILORI + '/' + DTQ_VIAGEM), '03', "FINA010()" } ) //"Natureza do Contrato de Carreteiro Nao encontrada" ### "Proprietario"
											lRet := .F.
											Exit
										Else
											SED->(dbSetOrder(1))
											If !SED->(MsSeek(xFilial('SED')+cNatuCTC) )
													AAdd( aMsgErr, { STR0014 + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim(Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NREDUZ"))+ ' ) ' + Alltrim(FWX3Titulo('DTY_VIAGEM')) + ': ' + DTQ->(DTQ_FILORI + '/' + DTQ_VIAGEM), '03', "FINA010()" } ) //"Natureza do Contrato de Carreteiro Nao encontrada" ### "Proprietario"
													lRet := .F.
													Exit
											EndIf
										EndIf
									EndIf


                                    If !A250VldDUA( DTR->DTR_FILORI , DTR->DTR_VIAGEM , @aMsgErr  )
										lRet	:= .F.
										Exit
									EndIf

									//-- Ao gerar contrato de carreteiro de Viagem de Coleta/Entrega por periodo, gerar
									//-- o mesmo numero de contrato para todas as viagens (do mesmo fornecedor e mesmo tipo de Rota -
									//-- Municipal ou Nao Municipal)

									//-- Ao gerar contrato de carreteiro de Viagem de Transferencia, gerar um novo
									//-- numero de contrato para cada viagem.

									//-- Ao gerar contrato de Premio, gerar o mesmo numero de contrato
									//-- para todas as viagens (do mesmo fornecedor).

									cRotMun:=''
									DA8->(DbSetOrder(1))
									If DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA)) .And. DA8->(ColumnPos("DA8_ROTMUN")) > 0
										cRotMun:= DA8->DA8_ROTMUN
									EndIf

									If nOpcx == 4 .And. lQbrVei
										nSeek := Ascan(aArrayFor, {|x| x[1]+x[2]+x[4]+x[6]+x[5] == cCodForn+cLojForn+cCodVei+cNumCiot+cRotMun } )
									Else
										//Quebra por Fornecedor + Rota Municipal
										nSeek := Ascan(aArrayFor, {|x| x[1]+x[2]+x[5] == cCodForn+cLojForn+cRotMun } )
									EndIf

									If (nOpcx == 3 .And. !lCtrPremio) .Or. (nSeek == 0 .And. (lCtrPremio .Or. nOpcx == 4))
										aContrat := {}
										// Ajusta SXE e SXF caso estejam corrompidos.
										cContrat := GetSx8Num("DTY","DTY_NUMCTC")
										cMay     := AllTrim(xFilial('DTY'))+cContrat
										FreeUsedCode()

										DTY->( DbSetOrder( 1 ) )
										While !MayIUseCode(cMay) .Or. DTY->(MsSeek(xFilial('DTY') + cContrat ))
											ConfirmSx8()
											cContrat := GetSx8Num("DTY","DTY_NUMCTC")
											FreeUsedCode()
											cMay     := AllTrim(xFilial('DTY'))+cContrat
										EndDo

										RestArea( aAreaDTY )

										cNumCTC := cContrat
									EndIf

									//Variaveis alimentadas para a utilizacao na FA050NAT2()
									cFilVge 	:= DTR->DTR_FILORI
									cNumVge 	:= DTR->DTR_VIAGEM
									nTotValAdi 	:= DTR->DTR_ADIFRE

									//-- Se Contrato Por Periodo ou Contrato de Premio
									If (nOpcx == 4 .Or. lCtrPremio)
										If nSeek == 0
											AADD(aArrayFor, {cCodForn, cLojForn, cContrat, cCodVei, cRotMun, cNumCiot} )
										Else
											cContrat := aArrayFor[nSeek][3]
										EndIf
									EndIf

									If cTmsErp == '0'

										//-- Se Contrato por Periodo verifica quantidade de diarias geradas
										If nOpcx == 4
											nSeekFor := Ascan(aArrayFor, {|x| x[1]+x[2]+Iif(lTmsDiaV,X[4],"") == cCodForn+cLojForn+Iif(lTmsDiaV,cCodVei,"") } )
											If nSeekFor == 0
												aDiaRet := TM250ClDia(cCodForn,cLojForn,cCodVei)
												AEval(aDiaRet,{|x| AAdd(aDiaHist,x)})
											EndIf
										EndIf

										If !A250VlCoPg(@cCondPag,@aMsgErr)
											lRet	:= .F.
											Exit
										EndIf

									EndIf

									If nGrupVei == 0 //Veiculo
										nValPedag := DTR->DTR_VALPDG
										cCodOpe   := DTR->DTR_CODOPE
									Else //1o e 2o Reboque
										nValPedag := 0
									EndIf

									//-- Chamada da TMSCalFrePag
									aRet	:= A250FrePag( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM , cCodVei,  @aMsgErr , .T. , @aFrete , nGrupVei, cCodForn, cLojForn, @aDiaHist ,  @aTabPag, cTipCont, , @nLinha, , , aDocNPrev )

									//--Retorno do cancelamento da Seleção da tabela de frete caso o usuário pressione o botão cancelar,
									//-- não apresenta o preview e cancela a geração do contrato.
									If nLinha == 0 .And. Len(aTabpag) > 1
										(cAliasCTC)->(dbSkip())
										Loop
									EndIf

									If Len(aRet) > 0
										cTabFre     := aRet[1][1]  //-- Tabela de Frete a Pagar
										cTipTab     := aRet[1][2]  //-- Tipo da Tab. de Frete a Pagar
										nValFrete   := aRet[1][3]  //-- Valor do Frete a Pagar
										nQtdOco     := aRet[1][4]  //-- Qtd. de Volumes
										nPesOco     := aRet[1][5]  //-- Peso
										nQtdDoc     := aRet[1][6]  //-- Qtd. de Documentos
										nDiaSem     := aRet[1][7]  //-- No. de Diarias ( Semana )
										nQtdKm      := aRet[1][8]  //-- Quilometragem Percorrida na Viagem
										nDiaFimSem  := aRet[1][9]  //-- No. de Diarias ( Fim de Semana )
										cGerTitPDG  := aRet[1][10] //-- Gera Titulo de Pedagio ?
										cDedPDG     := aRet[1][11] //-- Deduz Valor do Pedagio do Valor do Frete ?
										nBasImp     := aRet[1][12] //-- Valor da Base para calculo dos impostos
										cTabCar     := aRet[1][13] //-- Tabela de Carreteiro
										//| Se calculo de frete estiver parametrizado por operadora a base de imposto deverá ser igual ao frete.
										If cImpCTC == "1" .And. !Empty(cCodOpe)
										     nBasImp := nValFrete
										EndIf
										cGerPC := aRet[1][14] //-- Gera Pedido de Compra ? (1=Sim/2=Nao/3=MV_TMSGRPC)

										cGerTitCont := aRet[1][15] //-- Gera Titulo do Contrato de Carreteiro ?
										If nMaxCus == 0
											nMaxCus := aRet[1][16] //-- Percentual da Rentabilidade x Custo
										EndIf
										If Len(aRet[1]) > 16
											cTitFrete   := aRet[1][17] //-- Gera Titulo do frete a pagar na geração do contrato, mesmo que o MV_LIBCTC esteja habilitado.
											If Len(aRet[1]) > 17
												cbxTitPDG   := aRet[1][18] //-- Efetua a baixa do titulo de pedágio automaticamente?
												If Len(aRet[1]) > 18
													cTitNDF  := aRet[1][19] //-- Gera o Titulo de NDF na geração do contrato de carreteiro, mesmo que o MV_LIBCTC esteja habilitado.
													If Len(aRet[1]) > 19
														cMomTitAdi  := aRet[1][20] //-- Momento da geração do título do adiantamento.
													EndIf
													If Len(aRet[1]) > 20
														lPaMovBco	:= aRet[1][21] //-- Informa se o PA deve movimentar banco.
														If Len(aRet[1]) > 21
															cMomTitPDG	:= aRet[1][22] //-- Momento da geração do título de pedágio.
														EndIf
													EndIf
												EndIf
											EndIf
										EndIf
										If lTM250Prc
											ExecBlock('TM250PRC',.F.,.F.,{cCodForn,cLojForn,cCodVei,nValFrete,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,cCodMot})
										EndIf
									EndIf
									//-- Calcula Acréscimos/Decréscimos
									A250AedVlr( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM , @nAcresc , @nDecresc , @nBasImp , @nValFrete /*, aOcorr*/ , @nVlrReem )

									If cTmsErp == '0' .Or. lPreview

										//-- Calcula os impostos somente se Integração com Operadora de Frete estiver desligada e se imposto estiver parametrizado pelo ERP pelo MV_IMPCTC.
										If Empty(cCodOpe) .Or. cImpCTC == "0" //0=ERP;1=Operadora de frete.
       										TM250CIMP(SA2->A2_TIPO,cAlias,lCtrPremio,cTipCont,cGerPC,cDedPDG,nValFrete,nTotValAdi,;
	      										nValPedag,nBasImp,@nValIRRF,@nValINSS,@nValSEST,@nValISS,@nValRetPIS,@nValRetCOF,;
		     									nValPremio,nValRetCSL,nOpcx,cFilDeb,cTipDeb,cPrefAnt,cCondPag,@aMsgErr,cContrat,cCodForn,;
			      								cLojForn,lEmptyTptCtc,cCodOpe,cNatuCTC,,cCodFav,cLojFav,cGerTitPDG)
										EndIf

										//-- Preview do Contrato Carreteiro
										If (nOpcx == 3 .Or. nOpcx == 4)
											lTela := lPreview
											If Empty(aMsgErr) .And. lTela
												aHeaderAeD := {}
												aColsAeD   := {}
												lRetPvw := TMSA250Pvw( cCodForn		, cLojForn		, cTipCont		, cCodMot	, DTQ->DTQ_FILORI 	, DTQ->DTQ_VIAGEM	, cDedPDG	,;
																	   cCodVei		, cTabFre		, cTipTab		, cTabCar	, aFrete			, lCtrPremio		, cGerPC	,;
																	   @nValFrete	, @nTotValAdi	, @nValPedag	, @nBasImp	, @nValIRRF 		, @nValINSS			, @nValSEST	,;
																	   @nValISS		, @nValRetPIS	, @nValRetCOF	, nMaxCus	, lTela				, cNumCTC 			, @nAcresc	,;
																	   @nDecresc 	, cNatuCTC		, cCodOpe		, /*nValSe*/, /*nValSenat*/		, @nVlrReem )

													If !lRetPvw
														lRet	:= .F.
														If nOpcx == 3
															(cAliasCTC)->(DbSkip())
														EndIf
														Loop
													EndIf

													If !lLibCTC .And. lExceCst
														lLibCTC := .T.
													EndIf
											ElseIf !Empty(aMsgErr)
												lRet	:= .F.
												AAdd( aMsgErr, { FWX3Titulo("DTQ_FILORI") + ": " + DTQ->DTQ_FILORI + " " + FWX3Titulo("DTQ_VIAGEM") + ": " + DTQ->DTQ_VIAGEM,, } )
												If nOpcx == 3
													(cAliasCTC)->(DbSkip())
												EndIf
												Loop
											EndIf
										EndIf
										//-- Somente Fornecedor do Tipo Juridico para Contrato configurado para gerar Pedido de Compra.
										If cGerPC == "1"
											SA2->(dbSetOrder(1))
											If SA2->(MsSeek(xFilial("SA2")+cCodForn+cLojForn).And. !(A2_TIPO $ "J/F"))
												AAdd( aMsgErr, { STR0031 +  DTQ->DTQ_FILORI+'/'+DTQ->DTQ_VIAGEM + STR0142 + cCodVei + STR0143,, "TMSA800()" } ) //"Para Calcular o Contrato da Viagem " ### " configurado para gerar Pedido de Compra, o Proprietario do Veiculo :" ### " deve ser do Tipo Juridico."
												lRet := .F.
												Exit
											EndIf
										EndIf

									EndIf
									lPerAdi := .F.
									//-- Trata o Adto. de Frete
									If lPreview
										If DTR->DTR_ADIFRE != nTotValAdi
											//-- Ajusta valor do adiantamento na DTR
											RecLock("DTR",.F.)
											DTR->DTR_ADIFRE := nTotValAdi
											DTR->(MsUnlock())
											//-- Ajusta valor do adiantamento na SDG
											aAreaSDG := Getarea("SDG")
											SDG->(DbSetOrder(5))
											SDG->(DbSeek(cSeekSDG := xFilial("SDG") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + cCodVei))
											While SDG->(!Eof()) .And. SDG->(DG_FILIAL + DG_FILORI + DG_VIAGEM + DG_CODVEI) == cSeekSDG
												If (cTmsErp == "1" .And. Posicione("DT7",1,FwxFilial("DT7") + SDG->DG_CODDES,"DT7_MOVBCO") == "1") .Or. ;
												   (cTmsErp != "1" .And. !Empty(SDG->DG_BANCO))
													RecLock("SDG",.F.)
													SDG->DG_VALCOB := nTotValAdi
													SDG->(MsUnlock())
													Exit
												EndIf
												SDG->(DbSkip())
											EndDo
											RestArea(aAreaSDG)
										EndIf
									Else
										If lTMSOPdg .And. DTR->DTR_CODOPE == '01' .And. nOpcx == 3  //-- Repom
											If DTR->DTR_PERADI > 0
												lPerAdi := .T.    // Campo de percentual existe e tem valor
											EndIf
											If lPerAdi
											     If DTR->DTR_ADIFRE <= 0
												     nTotValAdi := ((nValFrete * DTR->DTR_PERADI) / 100)
												Else
												     nTotValAdi := DTR->DTR_ADIFRE
												EndIf
											Else

												nTotValAdi	:= 0

												cQuery := ""
												cQuery += "SELECT DG_TOTAL "
												cQuery += " FROM " + RetSqlName("SDG") + " SDG, "
												cQuery += RetSqlName("DT7") + " DT7 "
												cQuery += " WHERE "
												cQuery += " SDG.DG_FILIAL = '" + xFilial("SDG")  + "' AND "
												cQuery += " SDG.DG_FILORI = '" + DTQ->DTQ_FILORI + "' AND "
												cQuery += " SDG.DG_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' AND "
												cQuery += " SDG.DG_ORIGEM <> 'DTY' AND "
												cQuery += " SDG.D_E_L_E_T_ = ' ' AND "
												cQuery += " DT7.DT7_FILIAL = '" + xFilial("DT7") + "' AND "
												cQuery += " DT7.DT7_CODDES = SDG.DG_CODDES AND "
												cQuery += " DT7.DT7_MOVBCO = '1' AND"
												cQuery += " DT7.D_E_L_E_T_ = ' '  "
												cAliasQry := GetNextAlias()
												cQuery := ChangeQuery(cQuery)
												dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

												While (cAliasQry)->(!Eof())
													nTotValAdi += (cAliasQry)->DG_TOTAL     //-- Apenas valores que movimentem banco
													(cAliasQry)->(DbSkip())
												EndDo
												(cAliasQry)->( dbCloseArea() )
											EndIf
										Else
											nTotValAdi := DTR->DTR_ADIFRE
										EndIf
									EndIf
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Veriica se existe Mov. Custo aberto antes do contrato   ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

									aAreaSDG := Getarea("SDG")
									//-- Acrescentado o looping abaixo para tratar parcelas, já que no SDG pode existir 'n' parcelas vinculadas numa única viagem
									SDG->(Dbsetorder(5))
									If !lLibCTC .And. SDG->(MsSeek(xFilial("SDG")+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
									     While SDG->(!EOF()) .And. SDG->(DG_FILORI+DG_VIAGEM) == DTR->(DTR_FILORI+DTR_VIAGEM)
										    TMSA070Bx("1",SDG->DG_SEQORI,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,DATE(),"01",SDG->DG_VALCOB,,,,)
										    SDG->(DbSkip())
										EndDo
									EndIf
									RestArea(aAreaSDG)

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Geracao do Contrato na Operadora de Frotas/Vale-Pedagio ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If cEnRepom $ "1;2"  //-- Encerra Repom por: Pagto Saldo = 4/ Conf.Libctc = 3 / Ocorrencia = 2 / Rotina de Encerramento = 1
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Geracao do Contrato na Operadora de Frotas/Vale-Pedagio ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If lRet .And. lTMSOPdg .And. DTR->DTR_CODOPE == '01' .And. nOpcx == 3
											If DTQ->DTQ_STATUS <> StrZero(3, Len(DTQ->DTQ_STATUS))
												If !lExcSched250
													MsgRun( STR0084,STR0083,; //-- "Gerando Contrato X Operadora de Frotas"###"Aguarde..."
															{|| lRet := RepContrat(	DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cCodForn, cLojForn,;
																                     nValFrete, nTotValAdi, @aDadOperad, nOpcx,@aMsgErr, cContrat, DTR->DTR_CODVEI)})
												Else
													lRet := RepContrat(	DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cCodForn, cLojForn,;
																           nValFrete, nTotValAdi, @aDadOperad, nOpcx,@aMsgErr, cContrat, DTR->DTR_CODVEI)
												EndIf
											Else
												AAdd( aMsgErr, { STR0135 } ) //-- "A viagem esta encerrada. Esta viagem foi configurada para ser integrada junto a Operadora de Frotas."
												AAdd( aMsgErr, { STR0136 } ) //-- "Como a viagem esta encerrada, a geracao do contrato nao podera ser concluida, pois desta maneira a quitacao do contrato nao podera ser realizada."
												lRet := .F.
											EndIf

											If !lRet
												DisarmTransaction()
												Exit
											EndIf
										EndIf
									EndIf

									If !Empty(nValFrete)
										//-- Grava composicao do frete do contrato
										//-- Verificar se vamos deixar o campo viagem como Virtual
										If Len(aFrete) > 0 //So gravo o DVP para Tabela de Frete a Pagar
											TmsGrvDVP( DTQ->DTQ_FILORI, cContrat, DTQ->DTQ_VIAGEM, aFrete )
										EndIf
									Else
										AAdd( aMsgErr, { STR0034 + DTQ->DTQ_FILORI + '-' + DTQ->DTQ_VIAGEM + ' /' + STR0025 + ':' + cCodVei + ' , ' + STR0035 + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim(Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NREDUZ"))+' )', '02', "TMSA240()" } ) //"O Valor do Frete da Viagem " ### "Veiculo :" ### "esta zerado" ### "Proprietario"
										lRet := .F.
										Exit
									EndIf

									//-- Verifica o Prefixo do Titulo
									cPrefAnt   := TMA250GerPrf(cFilAnt)

									If cTMSERP == "0" .And. (!(SA2->A2_TIPO $ 'J/F') .Or. cGerPC == '2')
										If lCtrPremio .And. !cTipCont =='7'
											//-- Se for Contrato de Premio, gera Titulo a Pagar
											lRet := TMSA250se2(cAlias,nOpcx,lCtrPremio,nValPremio,nValFrete,nValPedag,nTotValAdi,cFilDeb,cTipDeb,cPrefAnt,cCondPag,aMsgErr,;
												DTR->DTR_FILORI,DTR->DTR_VIAGEM,cContrat,DTR->DTR_CREADI,DTR->DTR_LOJCRE,cCodForn,cLojForn,cCodFav,cLojFav,;
												@nValIRRF,@nValINSS,@nValSEST,@nValISS,,lEmptyTptCtc,cNatuCTC,@nValRetPIS,@nValRetCOF,@nValRetCSL,cGerTitPDG,cDedPDG, nBasImp,,,,cCodOpe)
											TMA250Perg("TMA740", .F.)	//--Recarrega as perguntas da rotina
										Else
											//-- Nao for Contrato de Premio, Calcula o ISS que sera gravado
											nValISS	  := 0

                                            RegToMemory("SE2",.T.)
											SED->(dbSetOrder(1))
											SED->(MsSeek(xFilial('SED')+cNatuCTC))
											M->E2_NATUREZ := SED->ED_CODIGO
											M->E2_VALOR   := IIf(nBasImp > 0, nBasImp, nValFrete)

											If lCpoInsR
												M->E2_INSSRET := DTR->DTR_INSRET
											EndIf

											TM250ClISS(cDedPDG, nValPedag)
											TM250ClINS()
											nValISS  := Max(0,M->E2_ISS)
											nValINSS := Max(0,M->E2_INSS)
											nValSEST := Max(0,M->E2_SEST)

										EndIf
									EndIf

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Estrutura do Array aDadosCTC:                                        ³
									//³ aDadosCTC[n,01] - Codigo do Fornecedor                               ³
									//³ aDadosCTC[n,02] - Loja do Fornecedor                                 ³
									//³ aDadosCTC[n,03] - Tipo Fornec. (Pessoa Fisica, Juridica, ...)        ³
									//³ aDadosCTC[n,04] - Contato do Fornecedor                              ³
									//³ aDadosCTC[n,05] - Filial de Debito Fornecedor                        ³
									//³ aDadosCTC[n,06] - Condicao de Pagamento do Fornecedor                ³
									//³ aDadosCTC[n,07] - Filial de Origem                                   ³
									//³ aDadosCTC[n,08] - No. da Viagem                                      ³
									//³ aDadosCTC[n,09] - No. do Contrato                                    ³
									//³ aDadosCTC[n,10] - Valor do Frete informado na viagem / Calculado     ³
									//³ aDadosCTC[n,11] - Valor dos Adiantamentos                            ³
									//³ aDadosCTC[n,12] - Credor dos Adiantamentos                           ³
									//³ aDadosCTC[n,13] - Loja do Credor                                     ³
									//³ aDadosCTC[n,14] - Prefixo do Titulo                                  ³
									//³ aDadosCTC[n,15] - Codigo do Veiculo                                  ³
									//³ aDadosCTC[n,16] - Valor do Pedagio                                   ³
									//³ aDadosCTC[n,17] - Tipo do Titulo                                     ³
									//³ aDadosCTC[n,18] - Codigo do Favorecido                               ³
									//³ aDadosCTC[n,19] - Loja do Favorecido                                 ³
									//³ aDadosCTC[n,20] - Valor do ISS                                       ³
									//³ aDadosCTC[n,21] - Natureza do Titulo                                 ³
									//³ aDadosCTC[n,22] - Gera Titulo do Pedagio ? (1=Sim/2=Nao)             ³
									//³ aDadosCTC[n,23] - Deduz Pedagio do Valor do Frete? (1=Sim/2=Nao)     ³
									//³ aDadosCTC[n,24] - Valor Base para Calculo dos Impostos               ³
									//³ aDadosCTC[n,25] - Controla a Liberacao do Contrato de Carreteiro?    ³
									//³ aDadosCTC[n,26] - Contrato vinculado a Operadora de Frotas?          ³
									//³ aDadosCTC[n,27] - Valor do INSS Retido                               ³
									//³ aDadosCTC[n,28] - Tipo de Uso - 1=Viagem;2=Carga - Frete Embarcador  ³
									//³ aDadosCTC[n,29] - Indentificador de Viagem ou Carga - Frt.Embarcador ³
									//³ aDadosCTC[n,30] - Gera Titulo do Contrato ?(1=Sim/2=Nao)             ³
									//³ aDadosCTC[n,31] - Rota Municipal ?(1=Sim/2=Nao)                      ³
									//³ aDadosCTC[n,32] - Gera Pedido Compra ?(1=Sim/2=Nao)                   ³
									//³ aDadosCTC[n,33] - Array de Impostos pela Repom(IRRF, SEST, INSS)   	 ³
									//³ aDadosCTC[n,34] - Codigo da Operadora de Frete e Pedagio   	     	 ³
									//³ aDadosCTC[n,35] - Foi executada a liberacao do contrato?        	 ³
									//³ aDadosCTC[n,36] - Gera titulo do frete, independente do MV_LIBCTC?   ³
									//³ aDadosCTC[n,37] - Baixa Titulo de Pedagio Automaticamente	     	 ³
									//³ aDadosCTC[n,38] - Gera o Titulo de NDF na geracao do conrato  		 ³
									//³                   independente do MV_LIBCTC?						 ³
									//³ aDadosCTC[n,39] - Informa se o titulo de NDF ja foi gerado    	   	 ³
									//³ aDadosCTC[n,40] - Informa o momento que o tit.de pdg. deve ser gerado³
									//³ aDadosCTC[n,41] - Informa o momento que o tit.de adi. deve ser gerado³
									//³ aDadosCTC[n,42] - Informa se o PA deverá movimentar banco.           ³
									//³ aDadosCTC[n,43] - Valor do reembolso						         ³
									//³ aDadosCTC[n,44] - CIOT (somente por periodo)                           ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									AADD( aDadosCTC, {/*01*/cCodForn  ,/*02*/cLojForn       ,/*03*/SA2->A2_TIPO    ,/*04*/SA2->A2_CONTATO,/*05*/cFilDeb  ,;
										             /*06*/cCondPag  ,/*07*/DTR->DTR_FILORI,/*08*/DTR->DTR_VIAGEM ,/*09*/cContrat       ,/*10*/nValFrete,;
										             /*11*/nTotValAdi,/*12*/DTR->DTR_CREADI,/*13*/DTR->DTR_LOJCRE ,/*14*/cPrefAnt       ,/*15*/cCodVei  ,;
										             /*16*/nValPedag ,/*17*/cTipDeb        ,/*18*/cCodFav         ,/*19*/cLojFav        ,/*20*/nValISS  ,;
										             /*21*/cNatuCTC  ,/*22*/cGerTitPDG     ,/*23*/cDedPDG         ,/*24*/nBasImp        ,/*25*/lLibCTC  ,;
										             /*26*/lTMSOPdg .And. !Empty(DTR->DTR_CODOPE) .And. nOpcx == 3,/*27*/DTR->DTR_INSRET,/*28*/""       ,;
										             /*29*/""        ,/*30*/cGerTitCont    ,/*31*/cRotMun         ,/*32*/cGerPC         ,/*33*/         ,;
										             /*34*/cCodOpe   ,/*35*/.F.            ,/*36*/cTitFrete       ,/*37*/cbxTitPDG      ,/*38*/cTitNDF  ,;
										             /*39*/.F.       ,/*40*/cMomTitPDG     ,/*41*/cMomTitAdi      ,/*42*/lPaMovBco 		,/*43*/nVlrReem,;
										             /*44*/ Iif(lCiotPer .And. DTR->DTR_TPCIOT == "2", DTR->DTR_CIOT,"" ) })

									// Caso possua o ponto de entrada compilado, adiciona os contratos no array de utilização do PE
									If lTM250CMP
										Aadd(aDadosPeCP,aDadosCTC[Len(aDadosCTC)])
									EndIf

									//|
									//| Redefine a chave com os dados coletados em aDadosCTC
									//|
									If nOpcx == 3
										cCTCKey := DTR->DTR_FILORI + DTR->DTR_VIAGEM
									Else
										cCTCKey := cCodForn + cLojForn + cRotMun + IIF(lQbrVei,(cAliasCTC)->DTR_CODVEI,"") + IIF(lCiotPer,(cAliasCTC)->DTR_CIOT,"")
									EndIf

									//-- Ponto de Entrada para trocar o codigo da despesa:
									If lTM250Desp
										cCodDesCTC := ExecBlock('TM250Desp',.F.,.F.,{nOpcx})
										DT7->(DbSetOrder(1))
										If !DT7->(MsSeek(xFilial('DT7') + cCodDesCTC))
											cCodDesCTC  := TMSA250Var("DES")
										EndIf
									EndIf

									If lRet
										cDocSDG := ''
										//-- Se nao for contrato de Premio
										If !lCtrPremio
											//-- Grava Mov. de Custo (SDG) do Saldo do Frete
											nItem   := 1
											If nValFrete > 0
												nSalFre := nValFrete - If( lTMSOPdg .And. !Empty(DTR->DTR_CODOPE) .And. nOpcx == 3, 0, nTotValAdi)
												If nSalFre > 0 .And. cFroVei != "1"
													cDocSDG := NextNumero("SDG",1,"DG_DOC",.T.)
													TMA250GrvSDG(cAlias,DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cCodDesCTC, nSalFre, nItem, cCodVei, cDocSDG )
													nItem++
												EndIf
											EndIf

											If nVlrReem > 0
												cDocSDG := NextNumero("SDG",1,"DG_DOC",.T.)
												TMA250GrvSDG(cAlias,DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cCodDesCTC, nVlrReem, nItem, cCodVei, cDocSDG )
												nItem++
											EndIf

											//--Grava SDG para os acrescimos do TIpo Reembolso.

											aRotina := AClone(aRotOld)

											//-- Manifesto de Carga
											DTX->(dbSetOrder(3))
											DTX->(MsSeek(cSeek:=xFilial('DTX')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
												Do While !DTX->(Eof()) .And. DTX->DTX_FILIAL+DTX->DTX_FILORI+DTX->DTX_VIAGEM == cSeek
												If Empty(DTX->DTX_NUMCTC)
													RecLock("DTX",.F.)
													DTX->DTX_NUMCTC := cContrat
													DTX->(MsUnLock())
												EndIf
												DTX->(dbSkip())
											EndDo

											//-- Se o Valor do Frete do Complemento de Viagem estiver zerado,
											//-- gravar o valor do frete calculado pela TMSCalFrePag()
											A250AtuDTR(nOpcx,cTabFre,cTipTab, nValFrete, cTabCar, nGrupVei )

										EndIf
										//--Se a liberação do contrato (MV_LIBCTC) está desabilitada, gera o contrato já informando que o título do frete será gerado.
										If !lLibCTC .And. cGerTitCont == '1'
											cTitFrete := '1'
										EndIf
										//-- Gerar Contrato de Carreteiro
										T250GerDTY(	cContrat		, cCodForn	, cLojForn	, nValPremio		, nValIRRF			, nValINSS	,nValSEST	, cTipCont	, ;
													nQtdOco			, nPesOco	, nQtdDoc	, nDiaSem			, nQtdKm			, nValFrete	, nTotValAdi, cDocSDG	, ;
													DTQ->DTQ_QTDPER	, nValPedag	, cCodMot	, DTQ->DTQ_FILORI	, DTQ->DTQ_VIAGEM	, cCodFav	, cLojFav	, cFilDeb	, ;
													nValISS			, nDiaFimSem, nValRetPIS, nValRetCOF		, nValRetCSL		, cDedPDG	, nBasImp	, cCodVei	, ;
													cTabFre			, cTipTab	, cTabCar	, cGerPC			,aDadOperad			, nMoeda	,			,			, ;
													cCondPag		, lPreview	, nMaxCus	, cTitFrete			, cTitNDF			, nAcresc	,nDecresc	,/*cFilDoc*/, ;
													/*cDocNum*/		,/*cDocSer*/, nValSestId, nValSenat			, nVlrReem)

										If lPreview .And. lRetPvw
											GravaDDN(DTY->DTY_NUMCTC,DTY->DTY_FILORI,DTY->DTY_VIAGEM,aColsAeD)
										EndIf

										If lExcSched250
											cContr250 := cContrat
											If !Empty(cContr250)
												//--> STR0193 = Contrato:
												//--> STR0194 = Viagem:
												//--> STR0195 = gerado com sucesso
												AADMsgTMS250( STR0193+" "+cValToChar(cContr250)+" ( "+ STR0194 + DTQ->DTQ_VIAGEM + ") " +STR0195, "TMSA250" )
												cContr250 := ""
											EndIf
										ElseIf !Empty(cContrat)
											AAdd( aCTCGer, {   DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cContrat } )
										EndIf


										//-- Se o Credor do Adiantamento NAO for o proprietario do Veiculo
										//--Nao existe esta funcionalidade para o OMS, atraves da Carga
										If !lCtrPremio .And. DTR->DTR_CREADI+DTR->DTR_LOJCRE <> cCodForn+cLojForn .And. DTR->DTR_ADIFRE <> 0 .And. cFroVei != '1'
											cContrat := GetSx8Num("DTY","DTY_NUMCTC")

											//-- Sera' gerado na funcao TMA250Qbr(), contas a Pagar com o valor do Adiantamento de frete para o Credor
											//-- Gera Contrato de Carreteiro
											If DTR->DTR_CREADI+DTR->DTR_LOJCRE <> cCodForn+cLojForn .And. DTR->DTR_ADIFRE <> 0 //--Viagem
												T250GerDTY(cContrat, DTR->DTR_CREADI, DTR->DTR_LOJCRE, 0, 0, 0, 0,;
													"4", nQtdOco , nPesOco, nQtdDoc, nDiaSem, nQtdKm, 0, DTR->DTR_ADIFRE,'',;
													0, nValPedag, cCodMot, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,;
													cCodFav, cLojFav, cFilAnt, 0, 0, 0, 0, 0, cDedPDG, 0, cCodVei, cTabFre, cTipTab,;
													cTabCar, cGerPC, ,nMoeda,,,cCondPag,lPreview,nMaxCus,cTitFrete,cTitNDF,/*nAcresc*/;
													/*nDecresc*/, /*cDocFil*/, /*cDocNum*/, /*cDocSer*/, nValSestId, nValSenat)
												If lExcSched250
													cContr250 := cContrat
													If !Empty(cContr250)
														//--> STR0193 = Contrato:
														//--> STR0194 = Viagem:
														//--> STR0195 = gerado com sucesso
														AADMsgTMS250( STR0193+" "+cValToChar(cContr250)+" ( "+ STR0194 + DTQ->DTQ_VIAGEM + ") " +STR0195, "TMSA250" )
														cContr250 := ""
													EndIf
												ElseIf !Empty(cContrat)
													AAdd( aCTCGer, {   DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cContrat } )
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
								//--Tipo da Frota : 'Propria' - Contrato do Tipo Adiantamento
								//-- Gerar Contrato de Carreteiro
								If lGerAdtPro //-- Viagem
									If DTR->DTR_CREADI+DTR->DTR_LOJCRE <> cCodForn+cLojForn .And. DTR->DTR_ADIFRE <> 0
										cContrat := GetSx8Num("DTY","DTY_NUMCTC")

										If lGerTit
											cCondPag := Posicione('SA2',1,xFilial('SA2')+DTR->DTR_CREADI+DTR->DTR_LOJCRE, 'A2_COND')
											If lTM250COND
												cCondPag := ExecBlock('TM250COND',.F.,.F.)
												If ValType(cCondPag) <> 'C'
													cCondPag:=Space(Len(SA2->A2_COND))
												EndIf
											EndIf
											//-- Quando integração Datasul ligada não necessita validar condição de pagamento.
                                            If cTMSERP == "0"
                                               If Empty(cCondPag)
                                                   AAdd( aMsgErr, { STR0036 + SA2->A2_COD + "/" + SA2->A2_LOJA + ' - ' + AllTrim(SA2->A2_NREDUZ), '03', "MATA020()" } ) //"Cadastrar Condicao de Pagto. no Cadastro de Fornecedor "
                                                   lRet := .F.
                                                   Exit
                                               Else
                                                   SE4->(DbSetOrder(1))
                                                   If !SE4->(DbSeek(xFilial('SE4')+cCondPag))
                                                        AAdd( aMsgErr, {STR0150, '03', "MATA360()"} ) //--"A condição de pagamento informada no cadastro do fornecedor não está cadastrada para esta filial. Cadastrar a condição de pagamento nesta filial."
                                                        lRet := .F.
                                                        Exit
                                                   EndIf
                                               EndIf
                                           EndIf

											cPrefAnt := TMA250GerPrf(cFilAnt)

											//-- Se o Credor do Adiantamento NAO for o proprietario do Veiculo, gerar contas a Pagar
											//-- do Adiantamento para o Credor
											TMSA250Adto(nOpcx,DTR->DTR_FILORI,DTR->DTR_VIAGEM,cPrefAnt,,DTR->DTR_CREADI,DTR->DTR_LOJCRE,;
												cCodForn,cLojForn,cNatuDeb,cCondPag,@nTotAdiNDF,cCodVei,cContrat,,,cCodOpe)
											If lExcSched250
												If cPerg <> "TM250A"
													TMA250Perg(cPerg, .F.)		//-- Recarrega as perguntas da rotina
												EndIf
											Else
												TMA250Perg(cPerg, .F.)		//-- Recarrega as perguntas da rotina
											EndIf
										EndIf

										//-- Gera Contrato de Carreteiro
										T250GerDTY(cContrat, DTR->DTR_CREADI, DTR->DTR_LOJCRE, 0, nValIRRF, nValINSS, nValSEST,;
											"4", nQtdOco, nPesOco, nQtdDoc, nDiaSem, nQtdKm, 0, DTR->DTR_ADIFRE,'',;
											0, DTR->DTR_VALPDG, cCodMot, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,;
											cCodFav, cLojFav, cFilAnt, nValISS, nDiaFimSem, nValRetPIS, nValRetCOF,;
											nValRetCSL, cDedPDG, nBasImp, cCodVei, cTabFre, cTipTab, cTabCar,,,,,, ;
											cCondPag,lPreview,nMaxCus,cTitFrete,cTitNDF,,,,,,nValSestId,nValSenat )


										If lExcSched250
											cContr250 := cContrat
											If !Empty(cContr250)
												//--> STR0193 = Contrato:
												//--> STR0194 = Viagem:
												//--> STR0195 = gerado com sucesso
												AADMsgTMS250( STR0193+" "+cValToChar(cContr250)+" ( "+ STR0194 + DTQ->DTQ_VIAGEM + ") " +STR0195, "TMSA250" )
												cContr250 := ""
											EndIf
										ElseIf !Empty(cContrat)
											AAdd( aCTCGer, {   DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cContrat } )
										EndIf
									EndIf
								EndIf

								//-- Executa Ponto de Entrada apos a gravacao do Contrato de Carreteiro
								If lTMA250Grv
									ExecBlock('TMA250Grv',.F.,.F.)
								EndIf
								//-- Realiza a chamada do Calculo do Custo a pagar
								If lPerCus .And. !lPreview
									TMSA250POk(nMaxCus,DTY->DTY_NUMCTC,.F., .F. )
								EndIf
							EndIf
						Else
							DTY->(dbSetOrder(2))
							If DTY->( MsSeek( xFilial("DTY") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ))
								lRet	:= .F.
								AAdd( aMsgErr, {  STR0155 + " " + DTY->DTY_NUMCTC + " " +  STR0256 + ": " + DTQ->DTQ_FILORI + '/' + DTQ->DTQ_VIAGEM  ; //-- O Contrato - já existe para a viagem:
												,'02', "TMSA250()" } )
							EndIf
						EndIf
					Next nCnt
					//-- Verifica outros veiculos na viagem
					(cAliasVei)->(dbSetOrder(1))
					(cAliasVei)->(dbSkip())

				EndDo
			Else
				AAdd( aMsgErr, { STR0037 + DTQ->DTQ_FILORI + '/' + DTQ->DTQ_VIAGEM , '02', "TMSA240()" } ) //"Nao Existe Complemento de Viagem para a Viagem "
				lRet := .F.
			EndIf

		EndIf //[ FIM SubWhile ] lRet := TMSChkViag...If lRet

		//-- Carrega o Array com as mensagens de Erro
		AaddMsgErr( aMsgErr, aVisErr )

		RestArea(aAreaDTQ)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o custo medio e' calculado On Line               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. cTMSERP == "0" .And. lCmOnLine

			SDG->(dbSetOrder(5))
			cSeekSDG  := xFilial('SDG')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
			bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == cSeekSDG }
			SDG->(dbSeek(cSeekSDG))
			While Eval(bWhileSDG)
				If SDG->(ColumnPos('DG_DTLANC')) > 0 .And. SDG->DG_STATUS == StrZero(3, Len(SDG->DG_STATUS)) .And. Empty(SDG->DG_DTLANC)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera o lancamento no arquivo de prova           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTotal+=DetProva(nHdlPrv,"901","TMSA250",cLoteCTC)
					AAdd(aRecSDGBai, SDG->(Recno()) )
				EndIf
				SDG->(dbSkip())
			EndDo
		EndIf
		(cAliasCTC)->(dbSkip())
		If nOpcX <> 4
			TMA250Perg("TMA250", .F.)
		EndIf

	EndDo // [Fecha] While Eval(bWhile) .And. (cCTCKey == (cAliasCTC)->(DTR_CODFOR+DTR.DTR_LOJFOR +DA8_ROTMUN))

	//If nOpcx <> 3 .And. (cAliasCTC)->(EOF())
	//	(cAliasCTC)->(DbCloseArea())
	//EndIf

	//-- Chama a rotina do TMS250Qbr() //--Para fazer a quebra e gerar os títulos financeiros do contrato de carreteiro
	If (!lCtrPremio .And. !Empty(aDadosCTC)) .Or. (cTipCont =='7' .And. lCtrPremio)// Contrato de Redespacho.

		If ! (lRet := TMSA250QBR(nOpcx,aDadosCTC,aMsgErr,aVisErr,cPerg,cDocSDG,nItem,,,cTipCTC))
			DisarmTransaction()
		EndIf

	EndIf

	If lRet
		aMsgErr  := {}
		cCodForn := ""
		cLojForn := ""
		ASort(aPropriet,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
		For nCnt := 1 To Len(aPropriet)
			If cCodForn + cLojForn <> aPropriet[nCnt,1] + aPropriet[nCnt,2]
				cCodForn := aPropriet[nCnt,1]
				cLojForn := aPropriet[nCnt,2]
				AAdd( aMsgErr, { STR0038 + aPropriet[nCnt,1] + "/" + aPropriet[nCnt,2] + ' - ' + AllTrim(Posicione("SA2",1,xFilial("SA2")+aPropriet[nCnt,1]+aPropriet[nCnt,2],"A2_NREDUZ"))+ ' )' , '01', "" } ) //"Nao foram gerados contratos para o Proprietario: "
			EndIf
		Next nCnt
		AaddMsgErr( aMsgErr, aVisErr )

		//----------------------------------------------------------------
		//-- Tratamento Ocorrencias Receita/Despesa
		//-- Gera Contratos Complementares Conforme Ocorrencias DUA
		//----------------------------------------------------------------
		If nOpcx == 3 .And. DUA->(ColumnPos("DUA_CODFOR")) > 0 .And. !Empty(aDadosCTC)

			//-- Verifica Se Existem Registros Disponíveis Para Processamento No TMSA152
			Tm250To152()

		EndIf
	EndIf

	TMA250Perg(cPerg, .F.)		//-- Recarrega as perguntas da rotina
     //| Reset do aDadosCTC
     aDadosCTC := NIL
     aDadosCTC := {}

     If __lSx8
     	If lRet
     		ConfirmSX8()
     	Else
     		RollBackSX8()
     	EndIf
     EndIf

End Transaction

EndDo // [Fecha] While Eval(bWhile)

If nOpcx <> 3 .And. (cAliasCTC)->(EOF())
	(cAliasCTC)->(DbCloseArea())
EndIf

//-- zera o total se ocorrer algum problema
If !lRet .And. lCmOnLine
	nTotal := 0
EndIf

If lTM250FIM
	ExecBlock('TM250FIM',.F.,.F.,aCTCGer)
EndIf

If lTM250CMP .And. !Empty(aDadosPeCP)
	ExecBlock('TM250CMP',.F.,.F.,{aDadosPeCP})
EndIf
If nOpcx == 3 .And. !lCtrPremio .And.  !Empty( aVisErr )
	TmsMsgErr( aVisErr )
	lRet := .F.
EndIf
cFilAnt	 := cFilAntBkp
If lRet
    lContGerado := .T. //Contrato Gerado
EndIf
Return lRet

/*/{Protheus.doc} A250VldPrc
//TODO Descrição auto-gerada.
@author Leandro Paulino
@since 10/12/2016
@version undefined
@param   oModel
@type function
/*/
Static Function A250VldPrc(nOPcx,LVGEEXPR)

Local cTipCont 	:= ''
Local cAliasCTC := ""
Local bWhile	:= {||}
Local lRet		:= .T.
Local cFilAtu   := cFilAnt
Local cTXTLG250	:= ''

Default nOpcx	:= 3
Default lVgeExpr:= .F.

If Nopcx == MODEL_OPERATION_INSERT

	DTQ->(dbSetOrder(2))
	DTQ->(dbSeek(xFilial('DTQ')+cFilAnt+MV_PAR01,.T.))

	//Posiciona na tabela de Complemento da viagem.
	DTR->(DbSetOrder(1))
	DTR->(MsSeek(xFilial('DTR')+cFilAnt+DTQ->DTQ_VIAGEM))

	//--TMS
	cTipCont := '1' //--Por Viagem

	If !lVgeExpr
		If (nOpcx <> 5 .And. DTR->DTR_CODOPE == '02' .And. DTQ->DTQ_STATUS $ ('1|9'))  //nao permitir gerar contrato se administrado pela Pamcard e a viagem estiver com o status em aberto ou cancelada. - pamcard
			Aviso( STR0085 , STR0152 + " " + DTR->DTR_FILORI + "/ " + DTR->DTR_VIAGEM + "." ,{'Ok'}) //--"Aviso"###"Contrato não poderá ser gerado porque a viagem está integrada junto a operadora Pamcard e está com o status em aberto ou cancelada."
			lRet := .F.
		EndIf
	EndIf

ElseIf nOpcx == MODEL_OPERATION_UPDATE

	//Posiciona na tabela de Complemento da viagem.
	DTR->(DbSetOrder(1))
	DTR->(MsSeek(xFilial('DTR')+cFilAnt+DTQ->DTQ_VIAGEM))

	If DTR->DTR_CODOPE == '01'   //nao permitir gerar contrato se administrado pela Repom Por periodo
		If !lExcSched250
			Aviso( STR0085 , STR0151 + " " + DTR->DTR_FILORI + "/ " + DTR->DTR_VIAGEM + "." ,{STR0086}) //--"Aviso"###"Contrato não poderá ser gerado porque a viagem está integrada junto a operadora de Frota e está com o status em aberto ou cancelada."
		Else
			cTXTLG250 := STR0151
			AADMsgTMS250(cTXTLG250,"TMSA250")
		EndIf
		lRet := .F.
	EndIf

	If mv_par11 == 1
		//--Antes de gerar os contratos, verifica a situacao das
		//--viagens envolvidas. Caso exista algum problema em relacao
		//--as viagens/proprietarios, o vetor "aPropriet" vira preenchido
		//--com o codigo do proprietario que apresenta a irregularidade.
		aPropriet := TMA250VerCal(nOpcx, cFilAtu)
		If Len( aPropriet ) > 0
			lRet := .F.
		EndIf
	EndIf

EndIf


Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250Forn³ Autor ³Gilson da Silva        ³ Data ³07.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verificar todos os fornecedores dos veículos da viagem.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA250Det(cFilOri, cViagem, nGerContr)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Indica para quem deve ser gerado contrato          ³±±
±±³          ³         1 = Veiculo;  2 = Reboque;  3 = Ambos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tma250Forn(nGerContr, cTipCont ,cAliasDTR)

Local aArea    := GetArea()
Local aAreaDA3 := DA3->(GetArea())
Local aForn    := {}
Local nPos     := 0
Local cCodForn := 0
Local cLojForn := 0
Local cCodVei  := 0
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0

Default nGerContr	:= 1
Default cTipCont	:= "1"
Default cAliasDTR	:= "DTR"

If nGerContr == 1 .Or. nGerContr == 3  //Gera Contrato para o Veiculo.
	DA3->(dbSetOrder(1))
	If DA3->(MsSeek(xFilial('DA3')+ (cAliasDTR)->DTR_CODVEI))
		If !Empty((cAliasDTR)->DTR_CODFOR) .And. !Empty((cAliasDTR)->DTR_LOJFOR)
			cCodForn := (cAliasDTR)->DTR_CODFOR
			cLojForn := (cAliasDTR)->DTR_LOJFOR
		Else
			cCodForn := DA3->DA3_CODFOR
			cLojForn := DA3->DA3_LOJFOR
		EndIf
		If Ascan( aForn, { |x| x[1]+x[2] == cCodForn + cLojForn } ) == 0
			Aadd( aForn, { cCodForn, cLojForn, DA3->DA3_COD, DA3->DA3_FROVEI, DA3->DA3_TIPVEI, 0 })
		EndIf
	EndIf
EndIf

If (nGerContr == 2 .Or. nGerContr == 3) //Gera Contrato para o Reboque.
	If !Empty((cAliasDTR)->DTR_CODRB1)
		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial('DA3')+(cAliasDTR)->DTR_CODRB1))
			cCodForn := DA3->DA3_CODFOR
			cLojForn := DA3->DA3_LOJFOR
			If Ascan( aForn, { |x| x[1]+x[2] == cCodForn + cLojForn } ) == 0
				Aadd( aForn, { cCodForn, cLojForn, DA3->DA3_COD, DA3->DA3_FROVEI, DA3->DA3_TIPVEI, 1 })
			EndIf
		EndIf
	EndIf

	If !Empty((cAliasDTR)->DTR_CODRB2)
		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial('DA3')+(cAliasDTR)->DTR_CODRB2))
			cCodForn := DA3->DA3_CODFOR
			cLojForn := DA3->DA3_LOJFOR
			If Ascan( aForn, { |x| x[1]+x[2] == cCodForn + cLojForn } ) == 0
				Aadd( aForn, { cCodForn, cLojForn, DA3->DA3_COD, DA3->DA3_FROVEI, DA3->DA3_TIPVEI, 2 })
			EndIf
		EndIf
	EndIf
	If lTercRbq .And. !Empty((cAliasDTR)->DTR_CODRB3)
		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial('DA3')+(cAliasDTR)->DTR_CODRB3))
			cCodForn := DA3->DA3_CODFOR
			cLojForn := DA3->DA3_LOJFOR
			If Ascan( aForn, { |x| x[1]+x[2] == cCodForn + cLojForn } ) == 0
				Aadd( aForn, { cCodForn, cLojForn, DA3->DA3_COD, DA3->DA3_FROVEI, DA3->DA3_TIPVEI, 3 })
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDA3)
Return aForn


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS250Qbr³ Autor ³ Patricia A. Salomao   ³ Data ³ 17/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a Quebra do vetor aDadosCTC:                            ³±±
±±³          ³**Se o Tipo do Fornecedor for 'Pessoa Juridica': Aglutina o ³±±
±±³          ³  valor do frete de todas as Viagens realizadas por ele no  ³±±
±±³          ³  periodo e gera um Pedido de Compra com este Valor.        ³±±
±±³          ³**Se o Tipo do Fornecedor for 'Pessoa Fisica' : Aglutina o  ³±±
±±³          ³  valor do frete de todas as Viagens realizadas por ele no  ³±±
±±³          ³  periodo e gera um Titulo a Pagar com este Valor.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada (3-Por Viagem / 4-Por Periodo)    ³±±
±±³          ³ExpA1 - Vetor contendo os dados da Viagem/Fornecedor        ³±±
±±³          ³ExpA2 - Vetor para adicionar mensagem de erro               ³±±
±±³          ³ExpA3 - Vetor contendo todas as mensagens de erro           ³±±
±±³          ³ExpC1 - Tipo do fornec. a ser considerado (Fisica/Juridica) ³±±
±±³          ³ExpC2 - Acao : 1 -  Gera Pedido de Compras                  ³±±
±±³          ³               2 -  Gera Titulo a Pagar Aglutinado          ³±±
±±³          ³ExpC3 - Grupo de Perguntas do TMSA250                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA250QBR(nOpcx,aDadosCTC,aMsgErr,aVisErr,cPerg,cDocSDG,nItem,cNatPDG,cNatDeb,cTipCTC)

Local nSeek        := 0
Local nSeekNDF     := 0
Local nCntFor      := 1
Local nX           := 0
Local nValFrete    := 0
Local nValPedag    := 0
Local nTotValAdi   := 0
Local nValIRRF     := 0
Local nValINSS     := 0
Local nValSEST     := 0
Local nValISS      := 0
Local nAliqISS     := 0
Local nValRetPIS   := 0
Local nValRetCOF   := 0
Local nTotAdiNDF   := 0
Local nBasImp      := 0
Local cFilOri      := ''
Local cViagem      := ''
Local cContrat     := ''
Local cCodForn     := ''
Local cLojForn     := ''
Local cCreAdi      := ''
Local cLojCre      := ''
Local cCodFav      := ''
Local cLojFav      := ''
Local cCodVei      := ''
Local cParc        := ''
Local cPrefAnt     := ''
Local cFilDeb      := ''
Local cTipDeb      := ''
Local cNatuCTC     := ''
Local cCondPag     := ''
Local cParcela     := StrZero(1, Len(SE2->E2_PARCELA))
Local cTipAdtoNDF  := Padr( "NDF", Len( SE2->E2_TIPO ) ) // Gera Titulo de Adiantamento do Tipo "NDF"
Local lEmptyTptCtc := Empty(GetMV('MV_TPTCTC' ,,''))  // Verifica se o parametro de Tipo do Contrato de Carreteiro esta vazio
Local lQbrVei      := .F.
Local lGerTitAdi   := .F.
Local cGerTitPDG   := "1"
Local cDedPDG      := "2"
Local aAdtoNDF     := {}
Local lRet         := .T.
Local lTMSOPdg     := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local nRetINSS     := 0
Local cIdent       := ""
Local cSeekSDG     := ""
Local bWhileSDG    := {||.T.}
Local cGerTitCont  := "1"
Local cRotMun      := ""
Local aImposto     := {}
Local cCodOpe	   := ""
Local aRecSe2	   := {}
Local cAliasTRB	   := ''
Local aRecAdiNDF   := {}
Local cPrefOri	   := ''
Local _nZ		   := 0
Local cBxTitPdg    := ''
Local cFroVei	   := ""
Local lTpFrota 	   := DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local cTitNDF      := '2' //--(1=Sim;2=Não) - Controla se gera NDF no momento da geração do contrato mesmo que a lliberação do contrato esteja habilitada (MV_LIBCTC == .T.)
Local lNDFJaGer    := .F. //--Informa se o título de NDF já foi gerado na geração do contrato de carreteiro
Local cMomTitPDG   := '1' //--Momento que o título de pedágio deverá ser gerado (1=Geração COntrato CArreteiro;2=Fechamento da Viagem)
Local aAreaDTR     := DTR->(GetArea())
Local nDadosCTC    := Len(aDadosCTC)
Local cAcao        := ''
Local cCNPJForn    := ''
Local nTotalPA     := 0	//--Valor Total do Título de Adiantamento a ser gerado.
Local cMomTitAdi   := ''
Local lGeraTitPa   := .F.
Local aAdtoPA	   := {}
Local cTipAdtoPA   := Padr( "PA", Len( SE2->E2_TIPO ) )  // Titulo de Adiantamento do Tipo "PA"
Local lPaMovBco	   := .F.
Local lAdto		   := .F.
Local nVlrReem	   := 0
Local nParcPDG	   := 0

//--Vairáveis para Integração TMS x ERP Datasul
Local lExcluir 	   := nOpcx==5
Local dDataTrans   := dDataBase //--Data do envio do arquivo ao ERP Datasul
Local dDataEmi	   := dDataBase //--Data de geração do contrato DTY_DATCTC
Local cHistory	   := ""
Local cEventType   := IIf(lExcluir,"delete","upsert")
Local cEntyName	   := 'TRANSPORTDOCUMENT'
Local cTipoMsg 	   := '2'
Local cSubTipMsg   := '201'
Local lPreview	   := .F.
Local lBloqPagto   := .F.
Local lComplemento := IsInCallStack("TMSA250COM")
Local cCodDesPDG   := Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio
Local cImpCTC 	   := SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
Local aAreaDUY	   := DUY->(GetArea())
Local aImpostos	   := {}
Local aDadosBco	   := {}
Local aBkDTY       := {} //-- este array salva informações do DTY para quando o EAI desfizer a transação e houver necessidade de desfazer outras integrações (Pamcard/Repom, por exemplo)
Local nBkValLiq    := 0  //-- mesmo princípio da variável aBkDTY, mas com o resultado de uma função.
Local cCIOTPer     := ""
Local cEnRepom     := SuperGetMV('MV_ENREPOM',,"1")
Local lODtClass    := Type("oDTClass") == "O"
Local lTmsa251     := IsInCallStack('TMSA251')
Local lComplemento := .F.

Default cNatPDG	:= ''
Default cNatDeb := ''
Default cTipCTC := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )

If !Empty(cTipCTC)
	lEmptyTptCtc := .F.
EndIf

If !Empty(cNatPDG)
	cNatuPDG := cNatPDG
EndIf

If !Empty(cNatDeb)
	cNatuDeb := cNatDeb
EndIf

If lComplemento
	cTipoMsg 	 := '6'
	cSubTipMsg   := '601'
EndIf

Trace250("250QBR INICIO")


If Type('mv_par09') == 'N'
	lPreview   := Iif(mv_par09 == 1,.T.,.F.)
EndIf

If Type('lGerTit') == 'U'
	lGerTit := GetMV('MV_GERTIT' ,,.T.) // Verifica se devera gerar ou nao contas a pagar (SE2)
EndIf

If lExcSched250
	If cPerg <> "TM250A"
		Pergunte(cPerg, .F.)		//-- Recarrega as perguntas da rotina
	EndIf
Else
	Pergunte(cPerg, .F.)		//-- Recarrega as perguntas da rotina
EndIf

If nOpcx == 4 .And. cPerg =="TM250A"
	lQbrVei := (mv_par08 == 1) //-- Gera Contrato Por Periodo ->Quebra por Veiculo
EndIf

//Se existir a implementacao do Frete Embarcador recebo Identificador e Tipo de Uso,
//-- e nao preciso mais receber viagem
//-- Ordena o Vetor por Tipo do Fornec. + Cod. do Fornec. + Loja do Fornec. + Rota Municipal + Filial de Origem + Viagem
If lQbrVei
	If Len(aDadosCTC[1]) > 43
		aSort( aDadosCTC,,,{ |x,y,z| x[3]+x[1]+x[2]+x[15]+x[44]+x[31]+x[7]+x[8] < y[3]+y[1]+y[2]+y[15]+y[44]+y[31]+y[7]+y[8] } )
	Else
		aSort( aDadosCTC,,,{ |x,y,z| x[3]+x[1]+x[2]+x[15]+x[31]+x[7]+x[8] < y[3]+y[1]+y[2]+y[15]+y[31]+y[7]+y[8] } )
	EndIf
Else
	aSort( aDadosCTC,,,{ |x,y,z| x[3]+x[1]+x[2]+x[31]+x[7]+x[8] < y[3]+y[1]+y[2]+y[31]+y[7]+y[8] } )
EndIf
DTR->(dbSetOrder(3)) //--DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_CODVEI
For nCntFor:= 1 To nDadosCTC
	Trace250("For nCntFor " + AllToChar(nCntFor))
    If cTmsErp = '1' .And. IsInCallStack('TMSA250Com')
		IncProc()
	EndIf
	IIf( Len(aDadosCTC[nCntFor]) >= 33 .And. !Empty(aDadosCTC[nCntFor][33]) , aImposto := aDadosCTC[nCntFor][33], )
	cAcao := Iif( cTMSERP == "1","2",aDadosCTC[nCntFor][32]) //| Se integração ligada não considera a geração do pedido de venda.
	aMsgErr    := {}
	cCodForn   := aDadosCTC[nCntFor][DDCODFOR]
	cLojForn   := aDadosCTC[nCntFor][DDLOJFOR]
	cFilDeb    := aDadosCTC[nCntFor][DDFILDEB]
	cCondPag   := aDadosCTC[nCntFor][DDCONDPG]
	cRotMun    := aDadosCTC[nCntFor][DDROTMUN]
	cFilOri    := aDadosCTC[nCntFor][DDFILORI]
	cViagem    := aDadosCTC[nCntFor][DDNUMVIA]
	cCreAdi    := aDadosCTC[nCntFor][DDCRDADO]
	cLojCre    := aDadosCTC[nCntFor][DDLOJCRD]
	cGerTitCont:= aDadosCTC[nCntFor][DDGERTIT]
	cContrat   := aDadosCTC[nCntFor][DDNUMCTC]
	cNumCtc    := cContrat //--Utilizada no FINA050
	cPrefAnt   := aDadosCTC[nCntFor][DDPREFIX]
	cCodVei    := aDadosCTC[nCntFor][DDCODVEI]
	cTipDeb    := aDadosCTC[nCntFor][DDTIPTIT]
	cCodFav    := aDadosCTC[nCntFor][DDCODFAV]
	cLojFav    := aDadosCTC[nCntFor][DDLOJFAV]
	cNatuCTC   := aDadosCTC[nCntFor][DDNATTIT]
	cGerTitPDG := aDadosCTC[nCntFor][DDGERPDG]
	cDedPDG    := aDadosCTC[nCntFor][DDDEDFRT]
	nRetINSS   := aDadosCTC[nCntFor][DDINSRET]
	cCodOpe    := aDadosCTC[nCntFor][DDCODOPE]
	cBxTitPdg  := aDadosCTC[nCntFor][DDBXAPDG]
	lPaMovBco  := aDadosCTC[nCntFor][DDPAMOVB]
	If Len(aDadosCTC[nCntFor]) > 37
		cTitNDF := aDadosCTC[nCntFor][DDGERNDF]
	EndIf
	If Len(aDadosCTC[nCNtFor]) > 38
		lNDFJaGer := aDadosCTC[ncNtFor][DDNDFGER]
	EndIf
	If Len(aDadosCTC[nCNtFor]) > 39
		cMomTitPDG := aDadosCTC[ncNtFor][DDMOMPDG]
	EndIf
	If Len(aDadosCTC[nCntFor]) > 40
		cMomTitAdi := aDadosCTC[ncNtFor][DDMOMADI]
		If cMomTitAdi == '2' .And. DTR->(ColumnPos('DTR_TITADI')) > 0
			//--Verifica se o título do adiantamento não foi gerado pela rotina TMSA310 ou TMSA240
			lGeraTitPa:=  DTR->(dbSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei)) .And. AllTrim(DTR->DTR_TITADI) == '2'
		EndIf
	EndIf
	If Len(aDadosCTC[nCntFor]) >= 44
		cCIOTPer   := aDadosCTC[nCntFor][DDCIOTPE]
	EndIf
	If Len(aDadosCTC[nCntFor]) >= 45
		lComplemento := aDadosCTC[nCntFor][DDCOMPL]
	EndIf
	If lTpFrota
		DA3->(MsSeek(xFilial('DA3')+ aDadosCTC[nCntFor,15]))
		cFroVei := DA3->DA3_FROVEI
		If cFroVei == "1"
			cGerTitCont := "2"
			cGerTitPDG 	:= "2"
		EndIf
	EndIf
	//-- Varre o SDG da Viagem para gerar Titulos das despesas tipo 'NDF' (que NAO movimentam Financeiro)
	//-- PS: Os Titulos das Despesas do Tipo 'PA' sao gerados no Complemento de Viagem
	If cTmsERP <> '1'
		nTotAdiNDF := 0
	EndIf
	SDG->(dbSetOrder(5))
	cSeekSDG  := xFilial("SDG")+cFilOri+cViagem+cCodVei
	bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeekSDG }

	SDG->(dbSeek(cSeekSDG))
	While Eval(bWhileSDG)

		lAdto := Iif(cTmsErp=='1',Posicione('DT7',1,FwxFilial('DT7')+SDG->DG_CODDES,'DT7_MOVBCO')=='1',!Empty(SDG->DG_BANCO))
		If !lAdto .And. SDG->DG_ORIGEM <> 'DTY'
			If SDG->DG_TITGER <> '1'
				nTotAdiNDF += SDG->DG_VALCOB
			EndIf
		ElseIf lAdto .And. SDG->DG_ORIGEM == 'DTR' .And. Len(aDadosCtc[nCntFor]) > 41 .And. aDadosCTC[nCntFor,DDMOMADI] == '2' .And. SDG->DG_TITGER <> '1'
			nTotalPA += SDG->DG_VALCOB
			//-- A Quebra na geracao dos titulos sera' por Dados Bancarios; Motivo: Geracao do SE5
			If (nSeek := Ascan(aDadosBco, {|x| x[1]+x[2]+x[3]+x[4] == SDG->(DG_BANCO+DG_AGENCIA+DG_NUMCON+DG_NUMCHEQ) })) == 0
				//-- Parcela do Titulo que sera' gerado
				If Empty(aDadosBco)
					cParc := cParcela
				Else
					cParc := Soma1(cParc)
				EndIf
				If !Empty(cCodFav) .And. !Empty(cLojFav) .And. cCodForn == cCreAdi .And. cLojForn == cLojCre
					AADD(aAdtoPA, {cCodFav,  cLojFav,  cCodFav, cLojFav, SDG->DG_VALCOB,cContrat,cPrefAnt,{SDG->DG_BANCO, SDG->DG_AGENCIA, SDG->DG_NUMCON, SDG->DG_NUMCHEQ, SDG->DG_VALCOB, cParc, /*lMovBcoChq*/.T., SDG->DG_TITGER}})
				Else
					AADD(aAdtoPA, {cCodForn, cLojForn, cCreAdi, cLojCre, SDG->DG_VALCOB,cContrat,cPrefAnt,{SDG->DG_BANCO, SDG->DG_AGENCIA, SDG->DG_NUMCON, SDG->DG_NUMCHEQ, SDG->DG_VALCOB, cParc, /*lMovBcoChq*/.T., SDG->DG_TITGER}})
				EndIf
			Else
				aAdtoPA[nSeek][5] := aDadosBco[nSeek][5] += SDG->DG_VALCOB
			EndIf
		EndIf
		SDG->(dbSkip())
	EndDo

     //+------------------------------------------------------------------
     //| Carrega Lista contendo a(s) viagem(ns) do Contrato.
     //+------------------------------------------------------------------
     If lODtClass .And. cTmsERP == "1"//-- DataSul
		  Trace250("AddTrip " + cFilOri + cViagem)
          oDTClass:AddTrip(cFilOri,cViagem)
		  Trace250("AddTrip OK" )
     EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aAdtoNDF:                                    ³
	//³ aAdtoNDF[n,01] - Codigo do Fornecedor                           ³
	//³ aAdtoNDF[n,02] - Loja do Fornecedor                             ³
	//³ aAdtoNDF[n,03] - Credor dos Adiantamentos                       ³
	//³ aAdtoNDF[n,04] - Loja do Credor                                 ³
	//³ aAdtoNDF[n,05] - Valor dos Adiantamentos tipo 'NDF'             ³
	//³ aAdtoNDF[n,06] - No. do Contrato                                ³
	//³ aAdtoNDF[n,07] - Prefixo do Titulo                              ³
	//³ aAdtoNDF[n,08] - Condicao de Pagamento                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotAdiNDF > 0 .And. !lNDFJaGer .And. (!aDadosCTC[nCntFor][DDLIBCTC] .Or. cTitNDF == '1' .Or. cAcao == '1')
		nSeekNDF:= Ascan(aAdtoNDF, { |x|  x[1]+x[2]+x[3]+x[4] == cCodForn+cLojForn+cCreAdi+cLojCre})
		If nSeekNDF ==0
			If !Empty(cCodFav) .And. !Empty(cLojFav) .And. cCodForn == cCreAdi .And. cLojForn == cLojCre
				AADD(aAdtoNDF, {cCodFav, cLojFav, cCodFav, cLojFav, nTotAdiNDF,cContrat,cPrefAnt,cCondPag})
			Else
				AADD(aAdtoNDF, {cCodForn, cLojForn, cCreAdi, cLojCre, nTotAdiNDF,cContrat,cPrefAnt,cCondPag})
			EndIf
		Else
			aAdtoNDF[nSeekNDF][5] += nTotAdiNDF
		EndIf
	EndIf
	//--Verifica se o adiantamento deve ser gerado na geração do CTC e se o mesmo não foi gerado

	nTotValAdi += nTotalPA

	//-- Se o Fornecedor for Pessoa Juridica e deve-se gerar Pedido de Compra,
	//-- gera pedido de compra para o fornecedor, aglutinando o valor do frete das Viagens
	If cAcao == '1' .And. cTmsErp == '0'
		//-- Acumula o Valor do Frete das viagens feitas pelo fornecedor
		If Len(aDadosCtc[nCntFor]) > 42
			nVlrReem  += aDADOSCTC[nCntFor][DDVLRREE]
		EndIf
		nValFrete += aDadosCTC[nCntFor][DDVLRFRT]
		nValPedag += aDadosCTC[nCntFor][DDVLRPDG]

		//--* Se o Contrato for gerado 'Por Periodo', gera 1 pedido de compra com valor
		//--  TOTAL do frete (acumulado) de todas as viagens feitas pelo Fornecedor por Rota Municipal
		//--* Se o Contrato for gerado 'Por Viagem', gera 1 pedido de compra para cada viagem

		If  nCntFor == Len(aDadosCTC) .Or. (nCntFor <> Len(aDadosCTC) .And.;
			(IIf(nOpcx == 4, aDadosCTC[nCntFor+1][DDCODFOR]+aDadosCTC[nCntFor+1][DDLOJFOR] <> cCodForn+cLojForn, .T. ) .Or.;
			IIf(lQbrVei, IIf(Len(aDadosCTC[nCntFor])>43,aDadosCTC[nCntFor+1][DDCIOTPE],'')+aDadosCTC[nCntFor+1][DDCODVEI] <> cCIOTPer + cCodVei,.F.)))
			//-- Posiciona no SA2 e verifica a Filial de Debito do Fornecedor
			lRet := TMSA250SC7(cCodForn,cLojForn,aDadosCTC[nCntFor][DDCONTAT],aDadosCTC[nCntFor][DDFILDEB],aDadosCTC[nCntFor][DDCONDPG],aDadosCTC[nCntFor][DDNUMCTC],aMsgErr,aVisErr,nValFrete)

			//-- Gera os Titulos de Adiantamento tipo 'NDF'; Os Titulos de Adiantamento tipo 'PA' serao gerados
			//-- pelo Complemento de Viagem
			If !lComplemento .And. lGerTit .And. lRet
				For nX := 1 To Len(aAdtoNDF)
					If !TM250SE2AD(nOpcx,	aAdtoNDF[nX][6],aAdtoNDF[nX][7],cParcela,aAdtoNDF[nX][3],aAdtoNDF[nX][4],;
											aAdtoNDF[nX][1],aAdtoNDF[nX][2],cNatuDeb,aAdtoNDF[nX][8],cTipAdtoNDF,aAdtoNDF[nX][5], cSeekSDG)
                        lRet := .F.
                        Exit
                    EndIf
				Next
			EndIf

			If !lComplemento .And. lGeraTitPa .And. lRet
				For nX := 1 To Len(aAdtoPA)
					If !TM250SE2AD(nOpcx,	aAdtoPA[nX][6],aAdtoPA[nX][7],cParcela,aAdtoPA[nX][3],aAdtoPA[nX][4],;
												aAdtoPA[nX][1],aAdtoPA[nX][2],cNatuDeb,,cTipAdtoPA,aAdtoPA[nX][5], cSeekSDG, , , lPaMovBco, aAdtoPA[nX][8] )
                        lRet := .F.
                        Exit
                    EndIf
				Next
			EndIf

			aAdtoNDF   := {}
			nTotValAdi := 0
			nValFrete  := 0

			//-- Carrega o Array com as mensagens de Erro
			AaddMsgErr( aMsgErr, aVisErr )

		EndIf

	//-- Se o Fornecedor for Pessoa Fisica ou nao se deve gerar Ped. Compra, gerar UM unico titulo a pagar,
	//-- aglutinando o valor do frete das Viagens
	ElseIf cAcao == '2'
		//-- Acumula o Valor do Frete das viagens feitas pelo fornecedor
		If Len(aDadosCTC[nCntFor])  > 42
			nVlrReem  += aDADOSCTC[nCntFor][DDVLRREE]
		EndIf
		nValFrete += aDadosCTC[nCntFor][DDVLRFRT]
		nValPedag += aDadosCTC[nCntFor][DDVLRPDG]
		nValISS   += aDadosCTC[nCntFor][DDVLRISS]
		If aDadosCTC[nCntFor][24] <> 0 .And. Empty(cCodOpe)
			nBasImp += aDadosCTC[nCntFor][DDBASIMP]
		Else
			nBasImp += aDadosCTC[nCntFor][DDVLRFRT]
		EndIf

		If nCntFor == Len(aDadosCTC) .Or. ;
		  (nCntFor <> Len(aDadosCTC) .And.;
		   IIf(nOpcx == 4, ;
			   (aDadosCTC[nCntFor+1][DDCODFOR]+aDadosCTC[nCntFor+1][DDLOJFOR] <> cCodForn+cLojForn ;
			   .Or. aDadosCTC[nCntFor+1][DDROTMUN] <> cRotMun ;
			   .Or. IIf(lQbrVei, IIf(Len(aDadosCTC)>43,aDadosCTC[nCntFor+1][DDCIOTPE],'') + aDadosCTC[nCntFor+1][DDCODVEI] <> cCIOTPer + cCodVei,.F.) ),;
			   .T. ))

			//--Se o controle de Liberacao estiver desabilitado ou a rotina a executar for a liberacao. Gera o Titulo a Pagar do Frete.

			If !aDadosCTC[nCntFor][DDLIBCTC] .Or. aDadosCTC[nCntFor][DDGERFRT] == '1'

				//-- Acumula o Valor do Frete das viagens feitas pelo fornecedor
				//-- Gera o Titulo a Pagar do Frete
				//-- Se o Contrato for gerado 'Por Periodo', a funcao TMSA250se2() nao deve gerar titulo de Adiantamento,
				//-- pois os credores dos adiantamentos das viagens (DTR_CREADI) podem ser diferentes. Sendo assim, os Titulos de
				//-- Adiantamento serao gerados atraves da 'varredura' do array aAdtoNDF, que chama a funcao TM250SE2AD().

				If cGerTitCont == "1"

				 	//-- Envia quitação antes do título, pois pode haver cálculo de impostos pela operadora
					If lRet .And. cCodOpe == "01" .And. cImpCTC == "1" //-- 0-Impostos ERP;1-Impostos pela operadora
						Trace250("Qbr IntRep INICIO")
						//-- Encerra Repom por Pagto Saldo = 3 e LIBCTC está ligado, ou Pagto Saldo = 4, quita o contrato na operadora no momento da emissão
						DTR->(dbSetOrder(3)) //--DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_CODVEI
						DTY->(dbSetOrder(4)) //-- DTY_FILIAL+DTY_FILORI+DTY_NUMCTC
						If cEnRepom $ "3;4" .And.;
						   DTR->(dbSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei)) .And.;
						   DTY->(dbSeek(FwxFilial("DTY")+cFilOri+cContrat)) .And. DTY->DTY_TIPCTC <> '5'
							//-- Inclui o movimento a diferença entre previsto x realizado
							If  Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_FROVEI') <> '1'
								nValMov := DTY->DTY_VALFRE - DTR->(Iif(DTR->DTR_FRECAL == '1', DTR_PRVFRE, DTR_VALFRE))
								lRet := A250IntRep(nValMov,lTMSOPdg,@aMsgErr, IIf(nVlrReem>0,DTY->DTY_VLREEM,0))
								nValIRRF := DTY->DTY_IRRF
								nValINSS := DTY->DTY_INSS
								nValSEST := DTY->DTY_SEST
							EndIf
						EndIf
						Trace250("Qbr IntRep FIM")
					EndIf

					If cTmsErp == '0'
						Trace250("TmsERP Zero")
						If lRet .And. !A250ExiTit( cPrefAnt , cContrat, cCodForn, cLojForn, cTipCTC ) //--Gera Titulo a Pagar
							If cCodOpe == "01" .And. cImpCTC == "1" //-- 0-Impostos ERP;1-Impostos pela operadora
								AAdd(aImposto, nValIRRF)
								AAdd(aImposto, nValSEST)
								AAdd(aImposto, nValINSS)
							EndIf
							lRet := TMSA250se2(	'DTY',nOpcx,.F.,0,nValFrete,nValPedag,nTotValAdi,cFilDeb,cTipDeb,cPrefAnt,;
														cCondPag,aMsgErr,cFilOri,cViagem,cContrat,cCreAdi,cLojCre,cCodForn,cLojForn,cCodFav,cLojFav,;
														@nValIRRF,@nValINSS,@nValSEST,nValISS,lGerTitAdi,lEmptyTptCtc,cNatuCTC,0,0,0,cGerTitPDG,cDedPDG, nBasImp,nRetINSS, ,aImposto,cCodOpe, cTipCTC)

							//--Grava Recno do Saldo do Contrato (Titulo Principal)
							If lRet .And. !Empty(cCodOpe)
								Aadd(aRecSe2,SE2->(Recno()))
							EndIf

							//-- Recarrega as Perguntas da Rotina...
							If lExcSched250
								If cPerg <> "TM250A"
									TMA250Perg(cPerg, .F.)		//-- Recarrega as perguntas da rotina
								EndIf
							Else
								TMA250Perg(cPerg, .F.)		//-- Recarrega as perguntas da rotina
							EndIf

							If lRet .And. !lComplemento
								//-- Gera os Titulos de Adiantamento tipo 'NDF'; Os Titulos de Adiantamento tipo 'PA' serao gerados
								//-- pelo Complemento de Viagem
                                For nX := 1 To Len(aAdtoNDF)
                                    If !TM250SE2AD(nOPcx,aAdtoNDF[nX][6],aAdtoNDF[nX][7],cParcela,aAdtoNDF[nX][3],aAdtoNDF[nX][4],;
                                                        aAdtoNDF[nX][1],aAdtoNDF[nX][2],cNatuDeb,aAdtoNDF[nX][8],cTipAdtoNDF, aAdtoNDF[nX][5],cSeekSDG)
                                        lRet := .F.
                                        Exit
                                    EndIf
                                Next

                                If lGeraTitPa .And. lRet
                                    For nX := 1 To Len(aAdtoPA)
                                        If !TM250SE2AD(nOPcx,	aAdtoPA[nX][6],aAdtoPA[nX][7],cParcela,aAdtoPA[nX][3],aAdtoPA[nX][4],;
															aAdtoPA[nX][1],aAdtoPA[nX][2],cNatuDeb, ,cTipAdtoPA,aAdtoPA[nX][5], cSeekSDG, , , lPaMovBco, aAdtoPA[nX][8] )
                                            lRet := .F.
                                            Exit
                                        EndIf
                                    Next
                                EndIf

								//--Para Adiantamentos e NDF na Liberacao de Contratos, o titulo sera compensado com o saldo do contrato
								If lRet
									DTY->(dbSetOrder(4))
									DTY->(dbSeek(xFilial("DTY")+cFilOri+cContrat))
									If aDadosCTC[nCntFor][DDLIBERA]
										If cFilOri <> cFilAnt
											cPrefOri  := TMA250GerPrf(cFilOri)
										EndIf
										//--CHAMA NOVA FUNCAO QUE TRARA TODOS OS PA'S E NDF'S
										aRecAdiNDF := A250PsqAdi(cCodForn,cLojForn,cPrefAnt,cFilOri,cContrat,cViagem,cPrefOri,,,,DTY->DTY_TIPCTC)
										//--Efetua a compensacao do titulo de PA, exceto para contrato de complemento porque a compensação já foi realizada na geração do contrato.
										If DTY->DTY_TIPCTC <> '5' .And. !Empty(aRecAdiNDF) .And. !Empty(aRecSE2)
											MaIntBxCP(2,aRecSE2,,aRecAdiNDF,,{.T.,.F.,.F.,.F.,.F.,.F.},{ | nRecSE2, cRetorno | A250SeqBx(nRecSE2,cRetorno,DTY->DTY_FILORI,DTY->DTY_NUMCTC) })
										EndIf
									EndIf
								EndIf
							EndIf


							//|
							//| Retorna Mensagem de Erro para a referencia do QBR
							//|
							If !lRet .And. cCodOpe == "01" .And. cImpCTC == "1" //-- 0-Impostos ERP;1-Impostos pela operadora
								 Aadd( aMsgErr,{ STR0282 + cFilOri + "/ " + cViagem ,"01",""}) //--"Ref. Filial/ Viagem: "
								 Trace250("Chamando A250ExcRpm "+AllToChar(InTransact()) )
								 If !A250ExcRpm(aMsgErr, .T.)
								 	Trace250("Falhou A250ExcRpm "+AllToChar(InTransact()) )
									Aadd( aMsgErr,{STR0292 ,"01",""}) //--Contrato Quitado na REPOM e com ERRO no Financeiro, entre em contato com a REPOM pois não foi possível efetuar o estorno da Quitação!"
								 Else
								 	Trace250("Sucesso A250ExcRpm "+AllToChar(InTransact()) )
								 EndIf
							EndIf
						EndIf

					ElseIf cTmsErp == '1' //--Integração com o ERP Datasul, fará chamada do método para geração do título do contrato PEdágio e Taxas;
						Trace250("TmsERP Um")
						SA2->(dbSetOrder(1))
						If SA2->(MsSeek(FwxFilial('SA2')+cCodForn+cLojForn))
							cCNPJForn := SA2->A2_CGC
						EndIf
						Trace250("Seek SA2")

						//--Pedagio sera gerado na geracao do contrato independente se o MV_LIBCTC estiver ativo.
						//--Será verifica se o pedágio não está configurado para ser gerado no Fechamento da Viagem - TMSA310
						If lRet .And. cGerTitPDG <> '2' .And. nValPedag > 0

							Trace250("Gera SDG PDG")
							DTR->(dbSetOrder(3)) //--DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_CODVEI
							//--Verifica se o pedágio não foi gerado pela rotina TMSA310
							If DTR->(dbSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei))
								If DTR->DTR_TITPDG == '1'
									Trace250("Gera SDG PDG - Zerou")
									nValPedag := 0
								ElseIf !("TMSA251" $ FunName())
									Trace250("Gera SDG PDG - TMA250GrvSDG")
									TMA250GrvSDG("DTY",cFilOri, cViagem, cCodDesPDG, nValPedag,nItem,cCodVei,cDocSDG,,,,,,,.T.)   // tms
								EndIf
							EndIf

						EndIf


						//--Verifica se o NDF já foi gerado
						//--O NDF deve ser gerado a partir da geração do contrato de carreteiro, porém se o mesmo já estiver sido gerado por alguma outra rotina, não gera novamente no Datasul.
						If lNDFJaGer
							nTotAdiNDF := 0
						EndIf
						DTY->(dbSetOrder(4))

						Trace250("Continua "+ AllToChar( lRet .And. lEAIFunOK .And. DTY->(dbSeek(FwxFilial("DTY")+cFilOri+cContrat))  ) )
						If lRet .And. lEAIFunOK .And. DTY->(dbSeek(FwxFilial("DTY")+cFilOri+cContrat))
							dDataEmi := DTY->DTY_DATCTC
							//--Monta array com os Impostos
							If cCodOpe == "01" .And. cImpCTC == "1" //-- 0-Impostos ERP;1-Impostos pela operadora
								//--Atualiza o array aImpostos
								aImpostos := A250RetImp()
								Trace250(VarInfo("aImpostos",aImpostos))
							EndIf
							cHistory := STR0287 + cFilOri + '/' + STR0288 + cViagem + '/' + STR0289 + DTY->DTY_NUMCTC //--'Filial Origem //--Viagem//--'Numero Contrato: '
							Trace250("Chamando TmA250Clas "+AllToChar(InTransact()) + "/" + cHistory )
							//-- Salva o DTY antes da integração com o EAI, pois em caso de falha, será desarmada a transação.
							aEval(DTY->(DbStruct()), {|x,y| aAdd(aBkDTY, DTY->(FieldGet(y))) })
							nBkValLiq := DTYValLiq(.F.)
							//--Gerar Título ref. ao saldo do frete, adiantamento e pedágio de uma única vez.
							aEAIRet := TmA250Clas( cFilOri  			, cViagem   , cContrat	, nValFrete , nBasImp	, nValPedag , nTotalPA 	, nTotAdiNDF, DTR->DTR_INSRET	,;
					 							   nAliqISS				, cCodForn 	, cLojForn  , cCnpjForn	, cFilDeb	, dDataBase , dDataBase	, cHistory	, "upsert"			,;
												   "TRANSPORTDOCUMENT"	,  cTipoMsg	, cSubTipMsg, .T.		,  .F. 		,  .F. 		, .F. 		, aImpostos , nVlrReem	)
							lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1])
							Trace250("Voltando TmA250Clas "+AllToChar(InTransact()) + "/" + AllToChar(lRet) )

							//|
							//| Retorna Mensagem de Erro para a referencia do QBR
							//|
							If !lRet .And. cCodOpe == "01" .And. cImpCTC == "1" //-- 0-Impostos ERP;1-Impostos pela operadora
							     Aadd( aMsgErr,{ Iif( Len(aEAIRet) > 1, aEAIRet[2] , STR0249 + ": Datasul") ,"01",""})
							     Aadd( aMsgErr,{ STR0282 + cFilOri + "/ " + cViagem ,"01",""}) //--"Ref. Filial/ Viagem: "
								 Trace250("Chamando A250ExcRpm "+AllToChar(InTransact()) )
								 If !A250ExcRpm(aMsgErr, .T., @aBkDTY, nBkValLiq)
								 	Trace250("Falhou A250ExcRpm "+AllToChar(InTransact()) )
									Aadd( aMsgErr,{STR0292 ,"01",""}) //--Contrato Quitado na REPOM e com ERRO no Financeiro, entre em contato com a REPOM pois não foi possível efetuar o estorno da Quitação!"
								 Else
								 	Trace250("Sucesso A250ExcRpm "+AllToChar(InTransact()) )
								 EndIf
							EndIf
							aSize(aBkDTY,0) // Libera memória do array do DTY salvo.
							//|
							//| Update DTY TAXES
							//|
							//Se o Adapter do TMSA250 estiver como Assíncrono joga a informação para a Tabela DJQ e DJR.
							If lRet .And. cImpCTC == '1' .And. cCodOpe == "01"
								Trace250("Verifica XX4")
								dbSelectArea('XX4')
								aAreaXX4 := XX4->(GetArea())

								//| Consulta a versao cadastrada no Adapter EAI
								XX4->(dbSetOrder(1))
								If XX4->(dbSeek(Xfilial('XX4') + PADR('TMSA250', Len(XX4->XX4_ROTINA)) + PADR("TRANSPORTDOCUMENT", Len(XX4->XX4_MODEL)))) .And. XX4->XX4_METODO == '2'

									Trace250("Chamada TMSIE76GRV" +AllToChar(InTransact()))
									//Chama Rotina responsável pela gravação DJR e DJQ, responsáveis pelo reenvio da mensagem única ao ERp PROTHEUS.
									TMSIE76GRV('DTY','2',DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC),'Geracao')
									Trace250("Voltando TMSIE76GRV" +AllToChar(InTransact()))

								EndIf

								RestArea(aAreaXX4)


							ElseIf lRet .And. (cImpCTC == '0' .Or. Empty(cCodOpe)) //--Indica que o Imposto é calculado pelo ERP.//-- Atualiza os valores dos impostos
								Trace250("TM250CIMP")
								TM250CIMP(SA2->A2_TIPO,"DTY",.F.,"1"/*cTipCont*/,"2"/*cGerPC*/,"2"/*cDedPDG*/,nValFrete,nTotAdiNDF,;
											nValPedag,nBasImp,@nValIRRF,@nValINSS,@nValSEST,@nValISS,@nValRetPIS,@nValRetCOF,;
											,,nOpcx,,,,,@aMsgErr,cContrat,M->DTY_CODFOR,M->DTY_LOJFOR,,,cNatuCTC,.F.,cCodFav,cLojFav,cGerTitPDG)

								DTY->(RecLock("DTY",.F.))
								//-- Atualiza os impostos
								DTY->DTY_VALFRE := nValFrete
								DTY->DTY_BASIMP := nBasImp
								DTY->DTY_IRRF   := nValIRRF
								DTY->DTY_INSS   := nValINSS
								DTY->DTY_SEST   := nValSEST
								DTY->DTY_ISS    := nValISS
								DTY->DTY_PIS    := nValRetPIS
								DTY->DTY_COFINS := nValRetCOF
								DTY->(MsUnlock())

							EndIf

						EndIf
					EndIf

					Trace250("Continua 2 "+ AllToChar( lRet .And. cCodOpe == "01" .And. cImpCTC == "0"   ) )
					//-- Integra com a Repom APÓS a geração do título quando o impostos são pelo ERP, e envia VALOR LÍQUIDO
					If lRet .And. cCodOpe == "01" .And. cImpCTC == "0" //-- 0-Impostos ERP;1-Impostos pela operadora
						//-- Encerra Repom por Pagto Saldo = 3 e LIBCTC está ligado, ou Pagto Saldo = 4, quita o contrato na operadora no momento da emissão
						DTR->(dbSetOrder(3)) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_CODVEI
						DTY->(dbSetOrder(4)) //-- DTY_FILIAL+DTY_FILORI+DTY_NUMCTC
						If cEnRepom $ "3;4" .And.;
						   DTR->(MsSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei)) .And. ;
						   DTY->(dbSeek(FwxFilial("DTY")+cFilOri+cContrat)) .And. DTY->DTY_TIPCTC <> '5'
						   If Posicione('DA3',1,xFilial('DA3')+DTY->DTY_CODVEI,'DA3_FROVEI') <> '1'
						   		nValMov := DTYValLiq(.F.) - DTR->(Iif(DTR->DTR_FRECAL == '1', DTR_PRVFRE, DTR_VALFRE))
								lRet := A250IntRep(nValMov,lTMSOPdg,@aMsgErr,IIf(nVlrReem>0,DTY->DTY_VLREEM,0))
						   EndIf
						EndIf

					EndIf

					nValFrete  := 0
					nTotValAdi := 0
					nValISS    := 0
					nBasImp    := 0
					nTotalPA   := 0
                    nTotAdiNDF := 0

					aAdtoNDF   := {}
					aRecSE2    := {}
					aRecAdiNDF := {}

					//-- Carrega o Array com as mensagens de Erro
					AaddMsgErr( aMsgErr, aVisErr )
				EndIf
			EndIf

		EndIf


		If !lRet
			aVisErr := {}
			If !lTmsa251
				Aadd( aVisErr, { STR0073, '', '' } ) // "Nenhum contrato foi gerado. "
				Aadd( aVisErr, { STR0074, '', '' } ) // "Foi localizado um problema na geração de contrato do carreteiro, favor corrigir o problema e executar a rotina novamente."
				Aadd( aVisErr, { STR0075, '', '' } ) // "Para os fornecedores que não apresentaram mensagens de erro, o contrato poderá ser gerado por viagem. "
				AaddMsgErr( aMsgErr, aVisErr )  //-- Carrega o Array com as mensagens de Erro
				If ! Empty( aVisErr )
					If lExcSched250	//--> Se execução não for via SCHEDULE apresenta tela de com erros, caso seja SCHEDULE gera log.
						For _nZ := 1 To Len(aVisErr)
							AADD(aMsgErPa, {aVisErr[_nX,1],aVisErr[_nX,2],aVisErr[_nX,3]})
						Next
				Else
						TmsMsgErr( aVisErr )
						aVisErr := {}
					EndIf
				EndIf
				Exit
			EndIf
		EndIf
	EndIf

	//--Pedagio sera gerado na geracao do contrato independente se o MV_LIBCTC estiver ativo.
	//--Será verificado se o pedágio não está configurado para ser gerado no Fechamento da Viagem - TMSA310
	If lRet .And. cGerTitPDG <> '2' .And. nValPedag > 0 .And. cMomTitPDG=='2' .And. cTmsErp == '0'

		DTR->(dbSetOrder(3)) //--DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_CODVEI
		//--Verifica se o pedágio não foi gerado pela rotina TMSA310
		If DTR->(dbSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei)) .And. DTR->DTR_TITPDG <> '1'
			nParcPDG++
			A250TitPdg(cFilOri, cViagem, cCodVei, cCodForn, cLojForn, nValPedag, cContrat, nRetINSS, cCodOpe, nOpcX, cDocSDG,nItem,cBxTitPdg,,nParcPDG)
			nItem++
		EndIf

	EndIf
	//--Taxa tambem será gerada na geração do contrato independente se o MV_LIBCTC estiver ativo.
	If lRet .And. DTY->DTY_TAXBAN > 0 .And. !lTmsa251
		A250TitTax(cFilOri, cViagem, cCodVei, cCodForn, cLojForn, DTY->DTY_TAXBAN, cContrat, nRetINSS, cCodOpe, nOpcX, cDocSDG,nItem)
		nItem++
	EndIf

	nValPedag  := 0

	Trace250("Next nCntFor "+ AllToChar(nCntFor))
Next nCntFor

Trace250("250QBR FINAL  "+ AllToChar(lRet) + VarInfo("aMsgErr",aMsgErr))

RestArea(aAreaDTR)
RestArea(aAreaDUY)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Com  ³ Autor ³ Patricia A. Salomao ³ Data ³17.11.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Contrato de Carreteiro Tipo "Complemento"              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias do arquivo                                    ³±±
±±³          ³ExpN1 = Numero do registro                                  ³±±
±±³          ³ExpN2 = Opcao selecionada                                   ³±±
±±³          ³ExpL1 = Chamada automática?                                 ³±±
±±³          ³ExpA1 = Array com campos a serem incluidos {"CAMPO",VALOR,Nil}±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA250Com(cAlias, nReg, nOpcx, aStruct,  lAuto , aCabDTY, cFilDoc, cDocto, cDocSer )

Local lTM250COND  	:= ExistBlock('TM250COND')
Local aMsgErr     	:= {}
Local aVisErr     	:= {}
Local aDadosCTC   	:= {}
Local cDocSDG     	:= ''
Local cFilDeb     	:= ''
Local cTipDeb     	:= ''
Local cCondPag    	:= ''
Local cTipo       	:= ''
Local cContato    	:= ''
Local cMay        	:= ''
Local cContrat    	:= ''
Local cGerTitPDG  	:= "1"
Local cGerTitCont 	:= "1"
Local cDedPDG     	:= "2"
Local cPrefAnt    	:= TMA250GerPrf(cFilAnt)
Local nValISS     	:= 0
Local lOnline     	:= .F.
Local nItem       	:= 1

Local nBasImp     	:= 0
Local cGerPC      	:= IIF(GetMV('MV_TMSGRPC',,.F.), '1', '2')
Local lLibCTC     	:= SuperGetMV( 'MV_LIBCTC',, .F. )
Local lTMSOPdg    	:= SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local aDadOperad  	:= {}
Local aMovtos     	:= {}
Local cTipUso     	:= IIf(!lTabDFI .Or. nModulo==43,"1","2")
Local cIdent      	:= ""
Local lTM250CNT   	:= ExistBlock('TM250CNT')
Local lTM250DTY   	:= ExistBlock('TM250DTY')
Local cRotMun     	:= ""
Local lEmptyTptCTC	:= Empty(GetMV('MV_TPTCTC' ,,''))	// Verifica se o parametro de Tipo do Contrato de Carreteiro esta vazio
Local nMaxCus	  	:= 0
Local lPerCus     	:= DTY->(ColumnPos("DTY_PERCUS")) > 0
Local cTitFrete   	:= ''
Local cbxTitPDG   	:= ''
Local nCount	  	:= 1
Local lRet		  	:= .T.
Local nValFrete		:= 0
Local cTitNDF      	:= '2' //--(1=Sim;2=Não) - Controla se gera NDF no momento da geração do contrato mesmo que a lliberação do contrato esteja habilitada (MV_LIBCTC == .T.)
Local cMomTitPDG   	:= '1' //--Momento que o título de pedágio deverá ser gerado (1=Geração COntrato CArreteiro;2=Fechamento da Viagem)
Local cMomTitAdi   	:= ""
Local lPaMovBco		:= .F.
Local cStatusDTY	:= '1'
Local nPos          := 0
Local lTmsa152      := IsInCallStack("TMSA152Ger")
Local c250CodFor    := ""
Local c250LojFor    := ""
Local c250NumCtc    := ""
Local c250TipCtc    := ""
Local c250CodVei    := ""
Local c250CodMot    := ""
Local c250CodFav    := ""
Local c250LojFav    := ""
Local c250TabFre    := ""
Local c250TipTab    := ""
Local c250TabCar    := ""
Local cAliasDUA     := ""
Local aParSX1       := {}
Local aSX5          := {}
Local nValSestId	:= 0
Local nValSenat		:= 0
Local lTipOpVg      := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Static aCamposDTY	:= {}

Private cTipCTC     := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Private cUniao      := GetMV("MV_UNIAO")									// Cod. para Pagto. do Imposto de Renda
Private cNatuCTC    := ''

Private nTotal      := 0	// Total dos lancamentos contabeis
Private aRecSDGBai  := {}	// Contabiliza a partir da Baixa da Despesa
Private aRecSDGEmi  := {}	// Contabiliza a partir da Emissao da Despesa
Private nHdlPrv				// Endereco do arquivo de contra prova dos lanctos cont.
Private cLoteCTC			// Numero do lote para lancamentos do TMS
Private cArquivo			// Nome do arquivo contra prova
Private lGerTit   	:= GetMV('MV_GERTIT' ,,.T.) // Verifica se devera gerar ou nao contas a pagar (SE2). Esta variavel e' Private, pois pode ser manipulada em algum PE. NAO RETIRAR !!!
Private lExcSched250:= IsBlind()   //--> Variável que será utilizada para definir se a execução é via Schedule.

Private oDTClass    := NIL

//|
//| Valida se existe a classe de integração EAI Contas Pagar
If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
   oDTClass := TransportDocumentClass():New()
EndIf

Default cAlias		:= "DTY"
Default nReg		:= 0
Default nOpcx		:= 4
Default	aStruct		:= {}
Default lAuto		:= .F.
Default aCabDTY		:= {}
Default cFilDoc     := ""
Default cDocto      := ""
Default cDocSer     := ""

lAuto250    := lAuto //-- Controle Para ExecAuto
aCamposDTY	:= {}

If lAuto
	DTY->( dbGoTo(nReg) )
EndIf

If lTM250CNT
	lRet := ExecBlock('TM250CNT',.F.,.F.,{DTY->DTY_FILORI})
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
	If !lRet
		Return( .F. )
	EndIf
EndIf

//----------------------------------------------------------------
//-- Tratamento Ocorrencias Receita/Despesa
//-- Gera Contratos Complementares Conforme Ocorrencias DUA
//----------------------------------------------------------------
If !(lAuto) .And. DUA->(ColumnPos("DUA_CODFOR")) > 0 .And. FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA360")
	//-- Verifica Se Existem Registros Disponíveis Para Processamento No TMSA152
	If Tm250To152(DTY->(Recno()))
		Return( .t. )
	EndIf
EndIf

If lTM250Par
	cNatuDeb := ExecBlock('TM250PAR',.F.,.F.,{3})
	If ValType(cNatuDeb) <> 'C'
		cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
	EndIf
Else
	cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
EndIf

//-- Se o parametro MV_TPTCTC nao estiver preenchido
If Empty(cTipCTC)
	If Len(cFilAnt) > 2
		Final(STR0186,STR0187)//--'O parametro MV_TPTCTC deve ser preenchido quando a Gestão Corporativa','estiver ativa.'
	Else
		cTipCTC := Padr( "C"+cFilAnt, Len( SE2->E2_TIPO ) ) // Tipo Contrato de Carreteiro
	EndIf
EndIf

nOpcx     := 4
//-- Validar se o imposto é calculado na operadora REPOM, não permitir Complemento
If DTY->DTY_CODOPE == "01" .And. SuperGetMv("MV_IMPCTC",,"0") == "1"  //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
	Help('',1,'TMSA25048') //-- Quando o cálculo de impostos é realizado pela operadora Repom, não é permitido Contrato complementar. Utilize Acréscimos/Decréscimos
	Return .F.
EndIf

//-- Valida parametrização Repom - Contrato complementar APENAS: se o contrato principal estiver aguardando liberação (STATUS 1 2 ou 3*) sem ter gerado o título
If DTY->DTY_CODOPE == "01" .And. SuperGetMV('MV_ENREPOM',,"1") $ "3;4" .And. ;
   (!lLibCTC .Or. DTY->DTY_TITFRE == "1" .Or. ; //-- Diferente de LIBCTC ou titulo gerado na geração do contrato
		( DTY->DTY_STATUS !='1' .And.;	//-- Diferente de "Em Aberto"
		  DTY->DTY_STATUS !='2' .And.;	//-- Diferente de "Aguardando Liberacao p/ Pagamento"
		 !(DTY->DTY_STATUS =='3' .Or. (Empty(DTY->DTY_STATUS) .And. Empty(DTY->DTY_NUMPC))) ; //-- Diferente "Liberado para Pagamento"
		);
	)

	Help('',1,'TMSA25051') //-- Quando utiliza operadora Repom o contrato deve estar com Status "Em Aberto"  ou "Aguardando Liberacao p/ Pagamento" ou "Liberado para Pagamento"
	Return .F.
EndIf

//--Obtém o percentual de rentabilidade do Contrato Original
nMaxCus := Iif(lPerCus,DTY->DTY_PERCUS,0)

//--------------------------------------------------------------------------------------------------------
//-- Passo 01 -> Carrega Valores Padrão Do DTY (Principal)
//--------------------------------------------------------------------------------------------------------
Aadd( aCamposDTY , { "DTY_FILIAL" , xFilial("DTY")	, Nil})
Aadd( aCamposDTY , { "DTY_TIPCTC" , "5" 			, Nil})
Aadd( aCamposDTY , { "DTY_FILORI" , DTY->DTY_FILORI , Nil})
Aadd( aCamposDTY , { "DTY_VIAGEM" , DTY->DTY_VIAGEM	, Nil})
Aadd( aCamposDTY , { "DTY_CODFOR" , DTY->DTY_CODFOR	, Nil})
Aadd( aCamposDTY , { "DTY_LOJFOR" , DTY->DTY_LOJFOR	, Nil})
Aadd( aCamposDTY , { "DTY_CODMOT" , DTY->DTY_CODMOT	, Nil})
Aadd( aCamposDTY , { "DTY_DATCTC" , dDataBase 		, Nil})
Aadd( aCamposDTY , { "DTY_HORCTC" , StrTran(Left(Time(),5),':','') 	, Nil})
Aadd( aCamposDTY , { "DTY_CODFAV" , DTY->DTY_CODFAV	, Nil})
Aadd( aCamposDTY , { "DTY_LOJFAV" , DTY->DTY_LOJFAV	, Nil})
Aadd( aCamposDTY , { "DTY_CODVEI" , DTY->DTY_CODVEI , Nil})
Aadd( aCamposDTY , { "DTY_CODOPE" , DTY->DTY_CODOPE	, Nil})
Aadd( aCamposDTY , { "DTY_FILDEB" , cFilDeb			, Nil})
Aadd( aCamposDTY , { "DTY_PERCUS" , nMaxCus			, Nil})

DTQ->(DbSetOrder(2)) //--DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
If DTQ->(MsSeek(xFilial('DTQ') +DTY->DTY_FILORI + DTY->DTY_VIAGEM ))

	//-- Verifica os Dados do Contrato do Fornecedor
	aContrFor := TMSContrFor( 	DTY->DTY_CODFOR,;
								DTY->DTY_LOJFOR,;
								,;
								DTQ->DTQ_SERTMS,;
								DTQ->DTQ_TIPTRA,;
								.F.,;
								Iif( lTmsa152 .And. !Empty(DUA->DUA_TIPVEI),DUA->DUA_TIPVEI,Posicione('DA3',1,xFilial('DA3') + c250CodVei ,'DA3_TIPVEI')),;
								Iif(lTipOpVg,DTQ->DTQ_TPOPVG,'') )

	If Empty(aContrFor)

		//-- Pesquisa Contrato com o Tipo de Veiculo Vazio
		If cTipUso == "1" //--Viagem

			aContrFor := TMSContrFor(	DTY->DTY_CODFOR,;
										DTY->DTY_LOJFOR,;
										,;
										DTQ->DTQ_SERTMS,;
										DTQ->DTQ_TIPTRA,;
										.F.,;
										,;
										Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))

		ElseIf cTipUso == "2" .And. lTabDFI //--OMS com Frete Embarcador

			aContrFor := TMSContrFor(	DTY->DTY_CODFOR,;
										DTY->DTY_LOJFOR,;
										,;
										"3",;
										"1",;
										.F.)
		EndIf
	EndIf

	If !Empty(aContrFor)
		cGerPC      := aContrFor[1][7]  //-- Gera Pedido de Compra para o Fornecedor (1=Sim / 2=Nao)
		cGerTitCont := aContrFor[1][8] //-- Gera Título de Contrato de Carreteiro
		cBxTitPdg	:= aContrFor[1][11] //-- Baixa o título de pedágio
		cTitFrete	:= aContrFor[1][10] //-- Gera Título de Contrato de Carreteiro
	Else
		cGerPC	:= IIF(GetMV('MV_TMSGRPC',,.F.), '1', '2')
	EndIf

EndIf

If lLibCTC  .Or. lTMSOPdg
	//-- Posiciona na tabela de Complemento da viagem.
	DTR->(DbSetOrder(3))
	DTR->(MsSeek(xFilial('DTR') + DTY->DTY_FILORI + DTY->DTY_VIAGEM + DTY->DTY_CODVEI ))

	If !lLibCTC
		//-- Verifica se a Viagem jah foi encerrada.
		DTQ->(DbSetOrder(2)) //--DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		DTQ->(MsSeek(xFilial('DTQ') +DTY->DTY_FILORI + DTY->DTY_VIAGEM ))
		If	DTQ->DTQ_STATUS == '3' //-- Encerrada
			cStatusDTY := '3' //-- Aguardando Liberacao para Pagamento
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o Status do Contrato de Carreteiro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cGerPC == '1'
			cStatusDTY := '4' //-- Contrato Quitado com Ped. Compra
		Else
			//-- Verifica se a Viagem jah foi encerrada.
			DTQ->(DbSetOrder(2)) //--DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
			DTQ->(MsSeek(xFilial('DTQ') +DTY->DTY_FILORI + DTY->DTY_VIAGEM ))
			If	DTQ->DTQ_STATUS == '3' //-- Encerrada
				cStatusDTY := '2' //-- Aguardando Liberacao para Pagamento
			Else
				If lExceCst //-- Redespacho ou Exceder o Percentual Maximo do Custo
					cStatusDTY := '2' //-- Aguardando Liberacao para Pagamento
				Else
					cStatusDTY := '1' //-- Em Aberto
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf	!lLibCTC
	//-- Verifica se a Viagem jah foi encerrada.
	DTQ->(DbSetOrder(2)) //--DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
	DTQ->(MsSeek(xFilial('DTQ') +DTY->DTY_FILORI + DTY->DTY_VIAGEM ))
	If	DTQ->DTQ_STATUS == '3' //-- Encerrada
		cStatusDTY := '3' //-- Aguardando Liberacao para Pagamento
	EndIf
			
EndIf

Aadd( aCabDTY, {"DTY_STATUS"	, cStatusDTY	, Nil } )

//--------------------------------------------------------------------------------------------------------
//-- Passo 02 -> Substitui Campos Da Tabela DTY Pelos Campos Passados Por Parametro Da Variável aCabDTY
//--------------------------------------------------------------------------------------------------------
For nCount := 1 To Len(aCabDTY)

	//-- Substitui Campos Passados Por Parametro
	nPos := aScan( aCamposDTY , {|x| AllTrim(x[1]) == Alltrim(aCabDTY[nCount,1]) })

	If nPos > 0
		aCamposDTY[nPos,2] := aCabDTY[nCount,2]
	Else
		Aadd( aCamposDTY , { aCabDTY[nCount,1] , aCabDTY[nCount,2] 	, Nil})
	EndIf

	If RTrim(Upper(aCabDTY[nCount,1])) == "DTY_VALFRE"
		nValFrete	:= aCabDTY[nCount,2]
	EndIf

Next nCount

//-- Carrega Variáveis Conforme Regra
c250CodFor := T250Meta('DTY_CODFOR','DTY',aCamposDTY)
c250LojFor := T250Meta('DTY_LOJFOR','DTY',aCamposDTY)
c250NumCtc := T250Meta('DTY_NUMCTC','DTY',aCamposDTY)
c250TipCtc := T250Meta('DTY_TIPCTC','DTY',aCamposDTY)
c250CodVei := T250Meta('DTY_CODVEI','DTY',aCamposDTY)
c250CodMot := T250Meta('DTY_CODMOT','DTY',aCamposDTY)
c250CodFav := T250Meta('DTY_CODFAV','DTY',aCamposDTY)
c250LojFav := T250Meta('DTY_LOJFAV','DTY',aCamposDTY)
c250TabFre := T250Meta('DTY_TABFRE','DTY',aCamposDTY)
c250TipTab := T250Meta('DTY_TIPTAB','DTY',aCamposDTY)
c250TabCar := T250Meta('DTY_TABCAR','DTY',aCamposDTY)

//-- Determina a Natureza Financeira Para Gravação Do Título a Pagar
cNatuCTC := A250DetNat(c250CodFor, c250LojFor, Iif( lTmsa152 ,DUA->(Recno()),0) )

//-- Verifica Tipo Do Contrato Principal
If DTY->DTY_TIPCTC == '3' .Or.  DTY->DTY_TIPCTC == '5'  //-- Contrato de Premio OU Contrato de Complemento
	Return .T.
EndIf

//--Contrato de Complemento, gravo o ident do contrato original posicionado
If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
	cTipUso := DTY->DTY_TIPUSO
	cIdent  := DTY->DTY_IDENT
	cFilDeb := TMSA250FilDeb( c250CodFor,;
							  c250LojFor,;
							  ,;
							  ,;
							  c250TipCtc <> StrZero(2,Len(DTY->DTY_TIPCTC)),;
							  ,;
							  ,;
							  .F.,;
							  c250CodVei)
ElseIf cTipUso == "1" //--TMS
	cFilDeb := TMSA250FilDeb( c250CodFor,;
							  c250LojFor,;
							  ,;
							  ,;
							  c250TipCtc <> StrZero(2,Len(DTY->DTY_TIPCTC)),;
							  DTY->DTY_FILORI,;
							  DTY->DTY_VIAGEM,;
							  .F.,;
							  c250CodVei)
EndIf

//-- Verifica a Filial de Debito (posiciona no arquivo SA2)
If lEmptyTptCTC
	cTipDeb  := Padr( "C"+cFilDeb, Len( SE2->E2_TIPO ) )
Else
	cTipDeb  := cTipCTC
EndIf

cCondPag := Posicione('SA2',1,FWxFilial('SA2')+c250CodFor+c250LojFor,'SA2->A2_COND')
cTipo    := SA2->A2_TIPO
cContato := SA2->A2_CONTATO

If lTM250COND
	cCondPag := ExecBlock('TM250COND',.F.,.F.)
	If ValType(cCondPag) <> 'C'
		cCondPag:=Space(Len(SA2->A2_COND))
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipUso == '1' //--TMS
	aSX5 := FWGetSX5("09","TMS")
	cLoteCTC:=IIF(!Empty(aSX5),aSX5[1][4],"TMS ")
ElseIf cTipUso == "2" .And. lTabDFI ////--OMS com Frete Embarcador
	aSX5 := FWGetSX5("09","OMS")
	cLoteCTC:=IIF(!Empty(aSX5),aSX5[1][4],"OMS ")
EndIf

BEGIN TRANSACTION

If lAuto

	lRet	:= T250GerDTY( 	"" ,;
							c250CodFor,;
							c250LojFor,;
							0,;
							0,;
							0,;
							0,;
							'5',;
							0,;
							0,;
							0,;
							0,;
							0,;
							nValFrete,;
							0,;
							Nil,;
							0,;
							0,;
							c250CodMot,;
							DTY->DTY_FILORI,;
							DTY->DTY_VIAGEM,;
							c250CodFav,;
							c250LojFav,;
							cFilDeb,;
							0,;
							0,;
							0,;
							0,;
							0,;
							cDedPDG,;
							Nil,;
							c250CodVei,;
							c250TabFre,;
							c250TipTab,;
							c250TabCar,;
							cGerPC,;
							aDadOperad,;
							Nil,;
							Nil,;
							Nil,;
							cCondPag,;
							Nil,;
							nMaxCus,,;
                            cTitNDF,,,;
							cFilDoc,;
							cDocto,;
							cDocSer,;
							nValSestId,;
							nValSenat)


Else
	//-- "Contrato de Carreteiro - Complemento" , "Aguarde"
 	nOpca	:= FWExecView(STR0001 + "-" + STR0068 ,'TMSA250', 9 , , {||.T.} )
	If !(lRet:= Iif(nOpca == 0 , .T. , .F. ) )
		RollBackSX8()
	EndIf

EndIf


If lRet

	cRotMun := ''
	DTQ->(DbSetOrder(2)) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
	If DTQ->(MsSeek(xFilial('DTQ') + DTY->DTY_FILORI + DTY->DTY_VIAGEM))
		DA8->(DbSetOrder(1))
		If DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA)) .And. DA8->(ColumnPos("DA8_ROTMUN")) > 0
			cRotMun:= DA8->DA8_ROTMUN
		EndIf
	EndIf

	AADD(aDadosCTC, {	DTY->DTY_CODFOR,;   //-- aDadosCTC[n,01] - Codigo do Fornecedor
						DTY->DTY_LOJFOR,;	//-- aDadosCTC[n,02] - Loja do Fornecedor
						cTipo,;				//-- aDadosCTC[n,03] - Tipo Fornec. (Pessoa Fisica, Juridica, ...)
						cContato,;			//-- aDadosCTC[n,04] - Contato do Fornecedor
						cFilDeb,;			//-- aDadosCTC[n,05] - Filial de Debito Fornecedor
						cCondPag,;			//-- aDadosCTC[n,06] - Condicao de Pagamento do Fornecedor
						DTY->DTY_FILORI,;	//-- aDadosCTC[n,07] - Filial de Origem
						DTY->DTY_VIAGEM,;	//-- aDadosCTC[n,08] - No. da Viagem
						DTY->DTY_NUMCTC,;	//-- aDadosCTC[n,09] - No. do Contrato
						DTY->DTY_VALFRE,;	//-- aDadosCTC[n,10] - Valor do Frete informado na viagem / Calculado
						0,;					//-- aDadosCTC[n,11] - Valor dos Adiantamentos
						'',;				//-- aDadosCTC[n,12] - Credor dos Adiantamentos
						'',;				//-- aDadosCTC[n,13] - Loja do Credor
						cPrefAnt,;			//-- aDadosCTC[n,14] - Prefixo do Titulo
						DTY->DTY_CODVEI,;	//-- aDadosCTC[n,15] - Codigo do Veiculo
						0,;					//-- aDadosCTC[n,16] - Valor do Pedagio
						cTipDeb,;			//-- aDadosCTC[n,17] - Tipo do Titulo
						'',;				//-- aDadosCTC[n,18] - Codigo do Favorecido
						'',;				//-- aDadosCTC[n,19] - Loja do Favorecido
						nValISS,;			//-- aDadosCTC[n,20] - Valor do ISS
						cNatuCTC,;			//-- aDadosCTC[n,21] - Natureza do Titulo
						cGerTitPDG,;		//-- aDadosCTC[n,22] - Gera Titulo do Pedagio ?
						cDedPDG,;			//-- aDadosCTC[n,23] - Deduz Valor do Pedagio do Valor do Frete ?
						nBasImp,;			//-- aDadosCTC[n,24] - Valor Base para Calculo dos Impostos
						lLibCTC,;			//-- aDadosCTC[n,25] - Controla a Liberacao do Contrato de Carretiro?
						lTMSOPdg .And. !Empty(DTY->DTY_CODOPE) .And. nOpcx == 3,;	 //-- aDadosCTC[n,26] - Contrato vinculado a Operadora de Frotas?
						0,;					//-- aDadosCTC[n,27] - Valor do INSS Retido
						Nil,;				//-- aDadosCTC[n,28] - Tipo de Uso - 1=Viagem;2=Carga
						Nil,;				//-- aDadosCTC[n,29] - Identificador de Carga ou Viagem
						cGerTitCont,;		//-- aDadosCTC[n,30] - Gera Titulo do Contrato ?(1=Sim/2=Nao)
						cRotMun,;			//-- aDadosCTC[n,31] - Rota Municipal ?(1=Sim/2=Nao)
						cGerPC,;			//-- aDadosCTC[n,32] - Gera Pedido Compra ?(1=Sim/2=Nao)
						Nil,;				//-- aDadosCTC[n,33] - Array de Impostos pela Repom(IRRF, SEST, INSS)
						DTY->DTY_CODOPE,;	//-- aDadosCTC[n,34] - Codigo da Operadora de Frete e Pedagio
						.F.,;				//-- aDadosCTC[n,35] - Foi executada a liberacao do contrato?        ³
						cTitFrete,;			//-- aDadosCTC[n,36] - Gera titulo do frete, independente do MV_LIBCTC?³
						cbxTitPDG,;			//-- aDadosCTC[n,37] - Baixa Titulo de Pedagio Automaticamente	     ³
						cTitNDF,;			//-- aDadosCTC[n,38] - Gera o Titulo de NDF na geracao do conrato independente do MV_LIBCTC?
						.F.,;				//-- aDadosCTC[n,39] - Informa se o titulo de NDF ja foi gerado
						cMomTitPDG,;		//-- aDadosCTC[n,40] - Informa o momento que o tit.de pdg. deve ser gerado
						cMomTitAdi,;		//-- aDadosCTC[n,41] - Informa o momento que o tit.de adi. deve ser gerado
						lPaMovBco,;         //-- aDadosCTC[n,42] - Informa se o PA deverá movimentar banco.
						0,;                 //-- aDadosCTC[n,43] - Valor do reembolso
						"",;    		    //-- aDadosCTC[n,44] - CIOT (somente por periodo)
						.T. })		        //-- aDadosCTC[n,45] - Informa se é um contrato complementar

	If lPerCus
		//Realiza a chamada do Rateio a Pagar
		lRet := TMSA250POk(nMaxCus,DTY->DTY_NUMCTC,.F., .F. )
	EndIf

	//-- Executa Ponto de Entrada apos a gravacao do Complemento do Contrato de Carreteiro
	If lTM250DTY
		ExecBlock('TM250DTY',.F.,.F.)
	EndIf

	If lRet
		//-- Se Pessoa Juridica e o Contrato estiver configurado para gerar Pedido de Compra,
		//-- faz a Quebra no Vetor aDadosCTC (Por Tipo do Fornecedor + Fornecedor) , gerando Pedido de Compra
		If cTmsErp == '0'
			If !TMSA250QBR(nOpcx,aDadosCTC,@aMsgErr,aVisErr,"TM250A",,,,,cTipCTC)
				DisarmTransaction()
			ElseIf __lSX8
				ConfirmSX8()
			EndIf
		ElseIf cTmsERP == '1'
			Processa({ || lRet := A250PrcInt(nOpcx,aDadosCTC,@aMsgErr,aVisErr,"TM250A")},"INTEGRAÇÃO COM ERP DATASUL" , "Por favor Aguarde..." ) //"Integrando CTC com ERP DATASUL"
			If lRet
				If __lSX8
					ConfirmSX8()
				EndIf
			Else
				DisarmTransaction()
			EndIf

		EndIf
	Else
		DisarmTransaction()
	EndIf
Else
	DisarmTransaction()
EndIf

END TRANSACTION

Return( lRet )

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250PrcInt()
					Cria ProcRegua e chama função para criação de títulos no DAtasul
@Parametros			ExpN1 - Nopcx
 				    ExpA1 - Array do AdadosCTC
					ExpA2 - Array com a Mensagem de Erro
					ExpA3 - Array aVisErr
					ExpC1 - Rotina que está gerado o título.

@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function A250PrcInt(nOpcx,aDadosCTC,aMsgErr,aVisErr,cRotina)

Local lRet := .T.

Default nOPcx	  := 1
Default aDadosCTC := {}
Default aMsgErr	  := {}
Default aVisErr	  := {}
Default cRotina	  := {}

ProcRegua(Len(aDadosCTC))

If !(lRet := TMSA250QBR(nOpcx,aDadosCTC,@aMsgErr,aVisErr,cRotina))
	DisarmTransaction()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TM250CIMP³ Autor ³ Valdemar Roberto     ³ Data ³ 28/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula impostos                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM250CIMP()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Tipo do Fornecedor                                 ³±±
±±³			 ³ cExp02 - Alias                                              ³±±
±±³			 ³ lExp01 - Indica se veio da rotina de Contrato de Premio     ³±±
±±³			 ³ cExp03 - Tipo do Contrato                                   ³±±
±±³			 ³ cExp04 - Gera Pedido de Compra ? (1=Sim/2=Nao/3=MV_TMSGRPC) ³±±
±±³			 ³ lExp02 - Indica se existe a tabela DFI                      ³±±
±±³			 ³ cExp05 - Indica o tipo de uso do sistema (1=TMS / 2=OMS)    ³±±
±±³			 ³ cExp06 - Indica se deduz pedagio do frete (1=Sim / 2=Nao)   ³±±
±±³			 ³ nExp01 - Valor do Frete                                     ³±±
±±³			 ³ nExp02 - Valor do Adiantamento                              ³±±
±±³			 ³ nExp03 - Valor do Pedagio                                   ³±±
±±³			 ³ nExp04 - Valor da Base de Impostos                          ³±±
±±³			 ³ nExp05 - Valor do IRRF                                      ³±±
±±³			 ³ nExp06 - Valor do INSS                                      ³±±
±±³			 ³ nExp07 - Valor do SEST                                      ³±±
±±³			 ³ nExp08 - Valor do ISS                                       ³±±
±±³			 ³ nExp09 - Valor do PIS                                       ³±±
±±³			 ³ nExp10 - Valor do COFINS                                    ³±±
±±³			 ³ nExp11 - Valor do Premio                                    ³±±
±±³			 ³ nExp12 - Valor da CSLL                                      ³±±
±±³			 ³ nExp13 - Opcao                                              ³±±
±±³			 ³ cExp07 - Filial de Debito                                   ³±±
±±³			 ³ cExp08 - Tipo de Debito                                     ³±±
±±³			 ³ cExp09 - Prefixo Anterior                                   ³±±
±±³			 ³ cExp10 - Condicao de Pagamento                              ³±±
±±³			 ³ aExp01 - Mensagens de Erro                                  ³±±
±±³			 ³ cExp11 - Numero do Contrato                                 ³±±
±±³			 ³ cExp12 - Codigo do Fornecedor                               ³±±
±±³			 ³ cExp13 - Loja do Fornecedor                                 ³±±
±±³			 ³ lExp03 - Indica se Parametro de Tipo do Contrato esta Vazio ³±±
±±³			 ³ cExp14 - Codigo da Operadora de Frotas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function TM250CIMP(cA2TIPO,cAlias,lCtrPremio,cTipCont,cGerPC,cDedPDG,;
		nValFrete,nTotValAdi,nValPedag,nBasImp,nValIRRF,nValINSS,nValSEST,nValISS,nValRetPIS,nValRetCOF,;
		nValPremio,nValRetCSL,nOpcx,cFilDeb,cTipDeb,cPrefAnt,cCondPag,aMsgErr,cContrat,cCodForn,cLojForn,lEmptyTptCtc,cCodOpe,cNatuCTC,lCallInt,cCodFav,cLojFav,cGerTitPDG)

Local cRota 		:= ""
Local aRet  		:= {}
Local cCnpjForn		:= ""
Local cEventType   	:= Iif( StrZero(nOpcx,2) $ "03;04","upsert","delete")
Local cEntyName    	:= "TRANSPORTDOCUMENT"
Local cTIPOMSG     	:= "2"  // Tipo Contrato Carreteiro.
Local cSubTipMsg   	:= "201" // Sub Tipo Frete Normal
Local oXML		   	:= Nil
Local cHistory		:= ""
Local lRet          := .T.
Local aEAIRet       := {}
Local aAreaDTQ      := DTQ->(GetArea())
Private nValDig     := 0
Private aAutoCab    := {}

Default cNatuCTC	:= ""
Default lCallInt	:= .T.
Default cCodFav	:= ""
Default cLojFav	:= ""
Default cGerTitPDG:= "1"

	If cTmsERP == '1'

	   //| Não chama a integração se não existir a classe compilada de integração CP, isso é feito devido a chamada
	   //| pela rotina TMSA251
	   If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
			//ENVIO MENSAGEM PARA CALCULO DOS IMPOSTOS
			If lEAIFunOK == .T. .And. lCallInt
				If FwHasEAI("TMSA250",.T.,,.T.) == .T. //| Valida se o cadastro do Adapter par Mensagem única existe
					SA2->(dbSetOrder(1))
					If SA2->(dbSeek(FwxFilial('SA2')+cCodForn+cLojForn))
						cCnpjForn := SA2->A2_CGC
					EndIf
					cHistory := STR0287 + DTQ->DTQ_FILORI + '/' + STR0288 + DTQ->DTQ_VIAGEM + '/' + STR0289 + cContrat //--'Filial Origem //--Viagem//--'Numero Contrato: '
					//Instância classe para envio da mensagem ao ERP Datasul
					//Aqui queremos apenas o valor dos impostos e por isso o campo lPreview é setado como True(.T.)
					Processa({|lEnd|;
									aEAIRet := TmA250Clas(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM, cContrat, nValFrete, nBasImp, nValPedag/*Vlr PDG*/, nTotValAdi/*Vlr Adto*/,0/*ValorNDF*/, 0/*Inss Retido*/, 0/*Aliq.ISS*/, cCodForn, cLojForn,cCnpjForn, cFilDeb, ;
									dDatabase, dDatabase, cHistory, cEventType ,cEntyName, cTIPOMSG , cSubTipMsg, .F./*lBlqTit*/, .T./*lPreview*/, .F./*lBloqPagto*/, .F./*lExcluir*/ ) },;
									STR0257,STR0258)

					lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1])

				Else //| Se não existir o cadastro avisa o usuário para realizar o cadastro
					Aviso(STR0085,STR0067,{STR0086},2)//|"Atençao; Nao Foi localizada a configuração da Mensagem Unica para a Rotina TMSA310,...;Fechar
					lRet      := .F.
				EndIf

			EndIf //|[Fecha o If lEAIFunOK == .T.

			If lRet
				// RETORNO DOS IMPOSTOS CALCULADOS PELO DATASUL
				// oXML := TXmlManager():New() //| *** Solução provisória até correção
				// cTaxPath := "/TOTVSMessage/ResponseMessage/ReturnContent/ListOfAccountPayableDocument/AccountPayableDocument/ListOfTaxes/Tax/"
				// oXml := XmlParser(aEAIRet[2],"_",@cErrorXml, @cWarnXml)

				nValIRRF   := oDTClass:oImpostos:nIRRF   //| IRRF
				nValINSS   := oDTClass:oImpostos:nINSS   //| INSS
				nValSEST   := oDTClass:oImpostos:nSEST   //| SEST
				nValISS    := oDTClass:oImpostos:nISS    //| ISS

				nValFrete  := nValFrete - (nValIRRF + nValINSS + nValSEST + nValISS)

				nValRetPIS := oDTClass:oImpostos:nPIS    //| VRETPIS
				nValRetCOF := oDTClass:oImpostos:nCOFINS //| VRETCOF
				nValRetCSL := oDTClass:oImpostos:nCSLL   //| VRETCSL

			EndIf   //|[FECHA If lRet]
	  EndIf
	ElseIf cA2TIPO <> "J" .Or. cGerPC == "2"
		If lCtrPremio .And. !cTipCont == "7"
			//-- Se for Contrato de Premio, gera Titulo a Pagar cCodFav cLojFav
			lRet := TMSA250se2(cAlias,nOpcx,lCtrPremio,nValPremio,nValFrete,nValPedag,nTotValAdi,cFilDeb,cTipDeb,cPrefAnt,cCondPag,aMsgErr,;
				DTR->DTR_FILORI,DTR->DTR_VIAGEM,cContrat,DTR->DTR_CREADI,DTR->DTR_LOJCRE,cCodForn,cLojForn,cCodFav,cLojFav,;
				@nValIRRF,@nValINSS,@nValSEST,@nValISS,,lEmptyTptCtc,cNatuCTC,@nValRetPIS,@nValRetCOF,@nValRetCSL,cGerTitPDG,cDedPDG,nBasImp,,,,cCodOpe)
			Pergunte("TMA740",.F.)	//--Recarrega as perguntas da rotina
		Else
			//-- Nao for Contrato de Premio, Calcula o ISS que sera gravado
			RegToMemory("SE2",.T.)
			SED->(dbSetOrder(1))
			SED->(MsSeek(xFilial("SED")+cNatuCTC))
			M->E2_NATUREZ := SED->ED_CODIGO
			M->E2_VALOR   := nValDig := IIf(nBasImp > 0, nBasImp, nValFrete)

			M->E2_INSSRET := DTR->DTR_INSRET

			TM250ClISS(cDedPDG,nValPedag)
			TM250ClINS()

			If lGerTit
				//-- Calcula o IRRF
				SA2->(dbSetOrder(1))
				SA2->(MsSeek(xFilial('SA2')+cCodForn+cLojForn))
				M->E2_FORNECE := SA2->A2_COD
				M->E2_LOJA    := SA2->A2_LOJA

				FA050NAT2()
				nValIRRF := Max(0,M->E2_IRRF)
			Else
				aRet := Tm250IrCar(cCodForn,cLojForn,nBasImp,nValFrete,cCondPag)
				nValIRRF := aRet[1][1]
			EndIf
			//-- O ISS somente devera ser cobrado nas viagens que utilizam Rotas Municipais.
			//-- Portanto, se a Rota da Viagem NAO for Municipal (DA8_ROTMUN == 2), zerar o ISS
			//-- calculado pelo financeiro
			cRota := Posicione("DTQ",2,xFilial('DTQ') + DTR->DTR_FILORI + DTR->DTR_VIAGEM,"DTQ_ROTA")
			DA8->(DbSetOrder(1))
			If DA8->(MsSeek(xFilial("DA8")+cRota))
				If DA8->DA8_ROTMUN == StrZero(2,Len(DA8->DA8_ROTMUN))
					M->E2_ISS := 0
				EndIf
			EndIf

			nValINSS   := M->E2_INSS
			nValSEST   := M->E2_SEST
			nValISS    := M->E2_ISS
			nValRetPIS := M->E2_PIS
			nValRetCOF := M->E2_COFINS
		EndIf
	EndIf

RestArea(aAreaDTQ)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Imp    ³ Autor ³ Patricia A. Salomao  ³ Data ³17.11.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula os impostos e mostra os valores na tela de Complemento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA250Imp()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA250Imp()
Local lRet     	:= .T.
Local nValIRRF 	:= 0
Local nValINSS 	:= 0
Local nValSEST 	:= 0
Local nValISS  	:= 0
Local nBasImp       := 0
Local cRota    	:= ""
Local cCarga   	:= ""
Local cTipUso  	:= IIf(!lTabDFI .Or. nModulo==43,"1","2")
Local oModel	:= FwModelActive()
Local oView		:= Nil
Local oMdlDTY	:= oModel:GetModel("MdFieldDTY")
Local lBlind	:= IsBlind()
Local cCodFor	:= ""
Local cLojFor	:= ""
Local cCnpjFor	:= ""
Local aEAIRet	:= {}
Local cFilOri	:= ""
Local cViagem	:= ""
Local cNumCTC	:= ""
Local cNatuCTC	:= ""
Local cFilDeb	:= ""
Local cCodFav	:= ""
Local cLojFav	:= ""
Local cTpCTC	:= ""
Local cCodVei	:= ""
Local nValFre	:= 0
Local nValPDG	:= 0
Local nValAdto	:= 0
Local cHistory	:= ""
Local cEventType	:= "upsert"
Local cEntyName		:= 'TRANSPORTDOCUMENT'
Local cTipoMsg 		:= '6'
Local cSubTipMsg	:= '601'
Local lPreview		:= .F.
Local lBloqPagto	:= .F.

//-- Variaveis utilizadas pela funcao FA050NAT2 (Fina050)
Private lF050Auto := .F.
Private lAltera   := .F.
Private nOldValor := 0
Private nOldIrr   := 0
Private nOldIss   := 0
Private nOldInss  := 0
Private nOldSEST  := 0
Private nValDig   := 0
Private aAutoCab  := {}

nValFre		:= oMdlDTY:GetValue("DTY_VALFRE")
cFilOri		:= oMdlDTY:GetValue("DTY_FILORI")
cViagem		:= oMdlDTY:GetValue("DTY_VIAGEM")
cCodFor		:= oMdlDTY:GetValue("DTY_CODFOR")
cLojFor		:= oMdlDTY:GetValue("DTY_LOJFOR")
cNumCTC		:= oMdlDTY:GetValue("DTY_NUMCTC")
nValPDG		:= oMdlDTY:GetValue("DTY_VALPDG")
nValAdto	:= oMdlDTY:GetValue("DTY_ADIFRE")
cCodFav		:= oMdlDTY:GetValue("DTY_CODFAV")
cLojFav		:= oMdlDTY:GetValue("DTY_LOJFAV")
cTpCTC		:= oMdlDTY:GetValue("DTY_TIPCTC")
cFilDeb		:= oMdlDTY:GetValue("DTY_FILDEB")
cCodVei		:= oMdlDTY:GetValue("DTY_CODVEI")
nBasImp        := oMdlDTY:GetValue("DTY_BASIMP")

SA2->(dbSetOrder(1))
If SA2->(MsSeek(xFilial('SA2')+ cCodFor +  cLojFor ))
	cCodFor		:= SA2->A2_COD
	cLojFor		:= SA2->A2_LOJA
	cCnpjFor 	:= SA2->A2_CGC

	If !Empty(SA2->A2_NATUREZ)
		cNatuCTC := SA2->A2_NATUREZ
	Else
		If lTM250Par
			cNatuCTC := ExecBlock('TM250PAR',.F.,.F.,{1})
			If ValType(cNatuCTC) <> 'C'
				cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
			EndIf
		Else
			cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
		EndIf
	EndIf

EndIf

//-- Verifica a Filial de Debito
cFilDeb := TMSA250FilDeb( cCodFor , cLojFor , cCodFav , cLojFav , cTpCTC <> StrZero(2,Len(DTY->DTY_TIPCTC)) , cFilOri , cViagem ,Iif( cFilDeb <> cFilAnt,.T.,.F.), cCodVei )

cRota := Posicione("DTQ",2,xFilial('DTQ')+ cFilOri + cViagem ,"DTQ_ROTA")

//-- O ISS so' devera' ser cobrado nas viagens que utilizam Rotas Municipais.
//-- Portanto, se a Rota da Viagem NAO for Municipal (DA8_ROTMUN == 2), zerar o ISS
//-- calculado pelo financeiro
DA8->(DbSetOrder(1))
If DA8->(MsSeek(xFilial("DA8")+cRota)) .And. DA8->(ColumnPos("DA8_ROTMUN")) > 0
	If DA8->DA8_ROTMUN == StrZero(2,Len(DA8->DA8_ROTMUN))
		nValISS := 0
	EndIf
EndIf


If cTmsERP == '0'

	RegToMemory("SE2",.T.)

	SED->(dbSetOrder(1))
	If SED->(MsSeek(xFilial('SED')+cNatuCTC))
		M->E2_NATUREZ := SED->ED_CODIGO
	EndIf

	M->E2_VALOR   := nValFre
	M->E2_FORNECE := cCodFor
	M->E2_LOJA    := cLojFor

	//-- Calcula impostos de acordo com M->SE2
	FA050NAT2()

	nValIRRF	:= M->E2_IRRF
	nValINSS 	:= M->E2_INSS
	nValSEST 	:= M->E2_SEST
	nValISS  	:= M->E2_ISS


ElseIf cTmsERP == '1' //-- Integração habilitada

   If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0

		//-- ENVIO MENSAGEM PARA CALCULO DOS IMPOSTOS
		If lEAIFunOK

			If FwHasEAI("TMSA250",.T.,,.T.) //-- Valida se o cadastro do Adapter par Mensagem única existe
				cHistory := STR0287 + cFilOri + '/' + STR0288 + cViagem + '/' + STR0289 + cNumCTC //--'Filial Origem //--Viagem//--'Numero Contrato: '
				Processa({|lEnd|;
						aEAIRet := TmA250Clas( cFilOri 			, cViagem 		, cNumCTC	, nValFre 	, nBasImp	, nValPDG		, nValAdto 			, 0/*ValorNDF*/		, ;
												0/*Inss Retido*/, 0/*Aliq.ISS*/	,  cCodFor	, cLojFor 	, cCnpjFor	, cFilDeb		, dDatabase			, dDatabase			, ;
												cHistory		, cEventType	, cEntyName	, cTIPOMSG	, cSubTipMsg, .F./*lBlqTit*/, .T./*lPreview*/	, .F./*lBloqPagto*/	, ;
												.F./*lExcluir*/ ) },;
						STR0257,STR0258)

				lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1])

			Else //| Se não existir o cadastro avisa o usuário para realizar o cadastro
				Aviso(STR0085,STR0067,{STR0086},2)//|"Atençao; Nao Foi localizada a configuração da Mensagem Unica para a Rotina TMSA310,...;Fechar
				lRet      := .F.
			EndIf

		EndIf

		If lRet

			nValIRRF   := oDTClass:oImpostos:nIRRF
			nValINSS   := oDTClass:oImpostos:nINSS
			nValSEST   := oDTClass:oImpostos:nSEST
			nValISS    := oDTClass:oImpostos:nISS

		EndIf
  EndIf
EndIf

//-- Atualiza ModelDEF
oMdlDTY:LoadValue("DTY_IRRF", nValIRRF )
oMdlDTY:LoadValue("DTY_INSS", nValINSS )
oMdlDTY:LoadValue("DTY_SEST", nValSEST )
oMdlDTY:LoadValue("DTY_ISS" , nValISS  )

//-- Atualiza ViewDEF
If !lBlind .And. !lAuto250
	oView	:= FwViewActive()
	oView:Refresh()
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA250GCH ³ Autor ³ Gilson da Silva     ³ Data ³ 28/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera cheques de despesas vinculados ao Contrato            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA250GCH()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA250GCH (cAlias, nReg, nOpcx)

Local lRet        := .T.
Local lOk         := .T.

Local aFieldsSDG  := {}
Local aNoFields   := {}
Local aYesFields  := {}
Local aColsSDG    := {}

Local nCont       := 0
Local nCntFor     := 0
Local nPosValBai  := 0
Local nPosAdto    := 0
Local nPosCodDes  := 0
Local nPosDoc     := 0
Local nPosBanco   := 0
Local nPosAgencia := 0
Local nPosConta   := 0
Local nPosCheque  := 0
Local nPosItem    := 0
Local nPosTotal   := 0

Local aArea       := GetArea()

Local cBanco      := ' '
Local cAgencia    := ' '
Local cConta      := ' '
Local cCheque     := ' '
Local cPrefixo    := TMA250GerPrf(cFilAnt)
Local cParcela    := ''
Local cTipAdtoPA  := Padr( "PA", Len( SE2->E2_TIPO ) )    // Gera Titulo de Adiantamento do Tipo "PA"
Local cHistor     := ''
Local aAltCpo     := {'DG_BANCO','DG_AGENCIA','DG_NUMCON','DG_NUMCHEQ'} //Vetor usado na rotina TA240ADTO
Local cTipUso     := IIf(!lTabDFI .Or. nModulo==43,"1","2")
Local cSeek       := ""
Local cViagem     := ""
Local cCarga      := ""
Local cNum        := ""
Local cSeekCTC    := ""
Local bWhileCTC   := {||.T.}
Local cTabCTC     := ""
Local cSeekSDG    := ""
Local bWhileSDG   := {||.T.}
Local cViagemDTY  := ""

Private aHeader    := {} //Vetor usado na rotina TA240ADTO
Private aCols      := {} //Vetor usado na rotina TA240ADTO
Private aHeaderSDG := {} //Vetor usado na rotina TA240ADTO
Private aAdtoViag  := {} //Vetor usado na rotina TA240ADTO
Private aSetKey    := {} //Vetor usado na rotina TA240ADTO
Private n          := 1  //Variavel usada na rotina TA240ADTO

If DTY->DTY_CODOPE == '01'
	Help('',1,'TMSA25032') // O Pagamento do saldo do contrato será realizado pela Operadora de Frota.
	Return .F.
EndIf
//Carrega o vetor aAdtoViag, com todos os adiantamentos da viagem que nao tem cheque informado.
aFieldsSDG := APBuildHeader("SDG")

For nCont := 1 to Len(aFieldsSDG)
    If AllTrim(aFieldsSDG[nCont][2]) $'DG_DOC.DG_CODDES.DG_DESCRI.DG_TOTAL.DG_VALCOB.DG_VALBAI.DG_SALDO.DG_DATVENC.DG_NUMSEQ.DG_TIPDES.DG_BANCO.DG_AGENCIA.DG_NUMCON.DG_NUMCHEQ.DG_ITEM'
        AAdd(aHeaderSDG, aFieldsSDG[nCont])
    EndIf
Next

//Posiciona os campos na GetDados
nPosDoc     := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_DOC' })
nPosCodDes  := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_CODDES' })
nPosValBai  := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_VALBAI' })
nPosBanco   := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_BANCO' })
nPosAgencia := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_AGENCIA' })
nPosConta   := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_NUMCON' })
nPosCheque  := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_NUMCHEQ' })
nPosItem    := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_ITEM' })
nPosTotal   := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == 'DG_TOTAL' })
aAdtoViag   := {}
aColsSDG    := {}

If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
	cCarga    := Posicione("DAK",4,xFilial("DAK")+DTY->DTY_IDENT,"DAK_COD")
	cNum      := cCarga //Na pesquisa que usa a variavel cNum e utilizado o numero da viagem
	cTabCTC   := "DAK"
	cSeekCTC  := xFilial("DAK")+cCarga+DAK->DAK_SEQCAR
	bWhileCTC := {|| DAK->(!Eof()) .And. DAK->(DAK_FILIAL+DAK_COD+DAK_SEQCAR) == cSeekCTC }
	SDG->(dbSetOrder(8))
	cSeekSDG  := xFilial("SDG")+DTY->(DTY_TIPUSO + DTY_IDENT + DTY_CODVEI)
	bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_TIPUSO+DG_IDENT+DG_CODVEI) == cSeekSDG }
ElseIf cTipUso == "1" //--TMS
	cTabCTC   := "DTR"
	cNum      := DTY->DTY_VIAGEM //Na pesquisa que usa a variavel cNum e utilizado o numero da viagem
	cSeekCTC  := xFilial("DTR")+DTY->(DTY_FILORI + DTY_VIAGEM)
	bWhileCTC := {|| DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == cSeekCTC }
	SDG->(dbSetOrder(5))
	cSeekSDG  := xFilial("SDG")+DTY->(DTY_FILORI + DTY_VIAGEM + DTY_CODVEI)
	bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeekSDG }
EndIf
//Verifica se existe complemento de Viagem para esse contrato
(cTabCTC)->(dbSetOrder(1)) //Todas as tabelas usam a mesma ordem -> DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
If (cTabCTC)->(dbSeek(cSeekCTC))
	While Eval(bWhileCTC)
		RegToMemory(cTabCTC)

		//Verifica se Existe  despesa para o complemento
		If SDG->(dbSeek(cSeekSDG))
			While Eval(bWhileSDG)
				//Pegar despesas originadas do complemento da viagem e tambem a do contrato de carreteiro
				If (SDG->DG_ORIGEM != "DTR") .AND. (SDG->DG_ORIGEM != "DTY")
					SDG->(dbSkip())
					Loop
				EndIf

				DT7->(dbSetOrder(1)) //DT7_FILIAL+DT7_CODDES
				If DT7->(MsSeek(xFilial("DT7")+SDG->DG_CODDES))
					If DT7->DT7_MOVBCO <> '1' .Or. !Empty(SDG->DG_NUMCHEQ)//Verifica se a despesa movimenta o financeiro
						SDG->(dbSkip()) //e se o cheque ja foi informado, nesses casos o registro nao sera mostrado.
						Loop
					EndIf
				EndIf

				AAdd(aColsSDG,Array(Len(aHeaderSDG)+1))
				For nCntFor := 1 To Len(aHeaderSDG)
					If	aHeaderSDG[nCntFor,10] != "V"
						aColsSDG[Len(aColsSDG),nCntFor]:=SDG->(FieldGet(FieldPos(aHeaderSDG[nCntFor,2])))
					Else
						aColsSDG[Len(aColsSDG),nCntFor]:=CriaVar(aHeaderSDG[nCntFor,2])
					EndIf
				Next
				aColsSDG[Len(AColsSDG),nPosValBai]       := SDG->DG_VALCOB - SDG->DG_SALDO  //-- Valor baixado
				aColsSDG[Len(aColsSDG),Len(aHeaderSDG)+1]:=.F.

				SDG->(dbSkip())
			EndDo
		EndIf

		If Len(aColsSDG) >= 1
			nPosAdto := Ascan(aAdtoViag, {|x|  x[1] == DTY->DTY_CODVEI })

			If nPosAdto > 0
				AAdd(aAdtoViag[nPosAdto][2], aClone(aColsSDG))
			Else
				AAdd(aAdtoViag,{ DTY->DTY_CODVEI, aClone(aColsSDG)})
			EndIf
		Else
			Help(' ', 1, 'TMSA24040') //"Nao existem despesas em aberto para serem selecionadas"
			lRet := .F.
		EndIf
		If cTipUso == "1" //--Viagem
			(cTabCTC)->(dbSkip())
		ElseIf cTipUso == "2" .And. lTabDFI //--OMS com Frete Embarcador
			Exit
		EndIf
	EndDo
Else
	If cTipUso == "1" //Viagem
		Help( ' ', 1, 'TMSA24002') //-- Complemento de viagem nao encontrado (DTR).
	ElseIf cTipUso == "2" .And. lTabDFI //--OMS com Frete Embarcador
		MsgAlert("Veiculo nao encontrado")
	EndIf
	lRet := .F.
EndIf

If lRet
	//--REVER, preciso ver como ficara isso no OMS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pela funcao TMSFillGetDados()                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNoFields  := {"DTR_FILORI","DTR_VIAGEM","DTR_FILVGE","DTR_NUMVGE","DTR_OBS"} //Campos que Nao Deverao aparecer na Getdados

	Aadd( aNoFields, "DTR_DATINI" )
	Aadd( aNoFields, "DTR_HORINI" )
	Aadd( aNoFields, "DTR_DATFIM" )
	Aadd( aNoFields, "DTR_HORFIM" )
	Aadd( aNoFields, "DTR_TMPVGE" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader e aCols Do Complemento da Viagem                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TMSFillGetDados( nOpcx, 'DTR', 1,xFilial( 'DTR' ) + DTY->DTY_FILORI + DTY->DTY_VIAGEM , { ||	DTR->DTR_FILIAL + DTR->DTR_FILORI + DTR->DTR_VIAGEM}, ;
	{ || .T. }, aNoFields,	aYesFields )

	TA240Adto( nOpcx,DTY->DTY_FILORI, DTY->DTY_VIAGEM, DTY->DTY_CODVEI, aAltCpo, Len(aCols))

	nPosAdto := Ascan(aAdtoViag, {|x|  x[1] == DTY->DTY_CODVEI })

	Begin Transaction
	If !Empty(aAdtoViag[nPosAdto,2,1,nPosCheque])
		For nCont := 1  To Len(aAdtoViag[nPosAdto][2])
			cBanco   :=  aAdtoViag[nPosAdto,2,nCont,nPosBanco]
			cAgencia :=  aAdtoViag[nPosAdto,2,nCont,nPosAgencia]
			cConta   :=  aAdtoViag[nPosAdto,2,nCont,nPosConta]
			cCheque  :=  aAdtoViag[nPosAdto,2,nCont,nPosCheque]

			SDG->(dbSetOrder(1)) //DG_FILIAL+DG_DOC+DG_CODDES+DG_ITEM
			If SDG->(MsSeek(cSeek:=xFilial("SDG")+aAdtoViag[nPosAdto,2,nCont,nPosDoc]+;
				aAdtoViag[nPosAdto,2,nCont,nPosCodDes]+aAdtoViag[nPosAdto,2,nCont,nPosItem]))
				cParcela := SDG->DG_PARC
				cParcela := Iif(cParcela == "00", "01", cParcela)
				cHistor  := "PARCELA TITULO = " + cParcela

				cViagemDTY := PadR(DTY->DTY_VIAGEM,Len(SE2->E2_NUM))
				SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If SE2->(dBSeek(xFilial("SE2")+cPrefixo+cViagemDTY+cParcela+cTipAdtoPA+DTY->DTY_CODFAV+DTY->DTY_LOJFAV))
					Reclock("SE2",.F.)
					SE2->E2_BCOPAG  := cBanco
					SE2->E2_NUMBCO  := cCheque
					SE2->E2_IMPCHEQ := "S"
					If Empty(SE2->E2_HIST)
						SE2->E2_HIST := cHistor
					EndIf
					MsUnlock()
				EndIf

				cViagemDTY := PadR(DTY->DTY_VIAGEM,Len(SE5->E5_NUMERO))
				SE5->(dbSetOrder(3)) //E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)
				If SE5->(dBSeek(xFilial("SE5")+cBanco+cAgencia+cConta+cPrefixo+cViagemDTY+cParcela+cTipAdtoPA))
					Reclock("SE5",.F.)
					SE5->E5_BANCO 	:= cBanco
					SE5->E5_AGENCIA	:= cAgencia
					SE5->E5_CONTA	:= cConta
					SE5->E5_NUMCHEQ	:= cCheque
					MsUnlock()
				EndIf

				cViagemDTY := PadR(DTY->DTY_VIAGEM,Len(SEF->EF_TITULO))
				SEF->(dbSetOrder(3)) //EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
				If !SEF->(dBSeek(xFilial("SEF")+cPrefixo+cViagemDTY+cParcela+cTipAdtoPA))
					Reclock("SEF",.T.)
					SEF->EF_FILIAL  := xFilial()
					SEF->EF_NUM     := cCheque
					SEF->EF_BANCO   := cBanco
					SEF->EF_AGENCIA := cAgencia
					SEF->EF_CONTA   := cConta
					SEF->EF_DATA    := dDataBase
					SEF->EF_VALOR   := SE2->E2_VALOR
					SEF->EF_BENEF   := SE2->E2_NOMFOR
					SEF->EF_PREFIXO := SE2->E2_PREFIXO
					SEF->EF_TITULO  := SE2->E2_NUM
					SEF->EF_PARCELA := SE2->E2_PARCELA
					SEF->EF_TIPO    := SE2->E2_TIPO
					SEF->EF_FORNECE := SE2->E2_FORNECE
					SEF->EF_LOJA    := SE2->E2_LOJA
					SEF->EF_HIST    := SE2->E2_HIST
					SEF->EF_LIBER   := "S"
					SEF->EF_ORIGEM  := "TMSA250"
					SEF->EF_SEQUENC := ""
					SEF->EF_TERCEIR := .F.
					MsUnlock()
				Else
					Reclock("SEF",.F.)
					SEF->EF_BANCO   := cBanco
					SEF->EF_AGENCIA := cAgencia
					SEF->EF_CONTA   := cConta
					SEF->EF_NUM     := cCheque
					MsUnlock()
				EndIf

				Reclock("SDG",.F.)
				SDG->DG_BANCO   := cBanco
				SDG->DG_AGENCIA := cAgencia
				SDG->DG_NUMCON  := cConta
				SDG->DG_NUMCHEQ := cCheque
				MsUnlock()
			EndIf
		Next
	Else
		Help('',1,'TMSA25057') //-- Informe o numero do cheque...
		lRet := .F.
	EndIf
	End Transaction
EndIf

RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSA250SLD³ Autor ³ Rodrigo Gomes         ³ Data ³04/10/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua o pagamento de saldo para o contrato de carreteiro  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA250SLD(cAlias, nReg, nOpc)

Local cAliasE    := "DTY"
Local aCpoEnch   := {"DTY_FILIAL","DTY_VIAGEM","DTY_NUMCTC","DTY_CODFOR","DTY_LOJFOR","DTY_NOMFOR",""}
Local aAlterEnch := {""}
Local aPos       := {C(025),C(002),C(075),C(228)}
Local nModelo    := 3	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
Local lF3        := .F.	// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
Local lMemoria   := .T.	// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
Local lColumn    := .F.	// Indica se a apresentacao dos campos sera em forma de coluna
Local caTela     := ""	// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
Local lNoFolder  := .F.	// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
Local lProperty  := .T.	// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
Local aButtons   := {}
Local oDlg       := NIL
Local aArea      := GetArea()
Local nOpcA      := 0
Local INCLUI     := .F.
Local cPrefixo   := TMA250GerPrf(cFilAnt)
Local cParcela   := StrZero(1, Len(SE2->E2_PARCELA))
Local cTipCTC    := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Local cFilContr  := DTY->DTY_FILIAL
Local cNrContr   := DTY->DTY_NUMCTC
Local cFilOriDTY := DTY->DTY_FILORI
Local cCodOpe    := DTY->DTY_CODOPE
Local cCtrComp   := DTY->DTY_TIPCTC
Local cFornec    := Iif(!Empty(DTY->DTY_CODFAV),DTY->DTY_CODFAV,DTY->DTY_CODFOR)
Local cLoja      := Iif(!Empty(DTY->DTY_LOJFAV),DTY->DTY_LOJFAV,DTY->DTY_LOJFOR)
Local nVlBxE2    := 0
Local nVlrSld    := CriaVar("E2_ISS",.F.)
Local nVlrAdiant := CriaVar("E2_ISS",.F.) //Valor que já foi pago mesmo o que ja foi compensado
Local nVlrCtr    := CriaVar("E2_ISS",.F.) //Valor do Frete a pagar (Contrato do Carreteiro)
Local nVlrAdia   := CriaVar("E2_ISS",.F.) //Valor demosntrado na tela (Valor do titulo - Saldo)
Local oVlrSld    := NIL
Local aRecNDF    := {} // Array contendo os Recnos dos titulos NDF/PA
Local aRecSE2    := {} // Array contendo os Recnos do titulo principal NFF
Local cSeek      := ""
Local cFil       := ""
Local cFilDeb    := ""
Local cTipDeb    := ""
Local aAreaDTQ   := DTQ->(GetArea())
Local cViagem    := ""
Local lLibCTC    := SuperGetMV( 'MV_LIBCTC',, .F. )
Local cTipUso    := Iif(!lTabDFI .Or. nModulo==43,"1","2")
Local cCarga     := ""
Local bWhile     := {||.T.}
Local cFiltro    := ""
Local nIndex     := 0
Local cArqCTC    := ""
Local aParam     := {}
Local lDigita    := .T.
Local lDigVlr    := .T.
Local lRet		   := .T.
Local cPrefContr := TMA250GerPrf(cFilOriDTY)
Local cVsRepom   := SuperGetMV('MV_VSREPOM',,'1')
Local cTMSOPdg   := SuperGetMV('MV_TMSOPDG',,'0')
Local aRetorno   := {{}}
Local lEmptyTptCTC := .F. // Verifica se o parametro de Tipo do Contrato de Carreteiro esta vazio
Local aAreaPam
Local cQuery      := ""
Local cAliasQry   := ""
Local cParc
Local cIdOpe		:= ""
Local cIdOpePri	:= ""
Local aRetorn   	:= {}
Local nTaxBan		:= 0
Local lTpFrota  	:= DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local cEncRepom     := SuperGetMV("MV_ENREPOM",,"1") //-- Encerra Repom pela 1=Ocorrencia / 2=Encerramento  / 3= Lib.Contrato (novo!!!!)
Local aMsgErr       := {}
Local aDadosQuit    := {}
Local aConsCard     := {}
Local cStatus       := ""

//--Variaveis Private da Funcao
Private nVlrPagto := CriaVar("E2_ISS",.F.)
Private cBanco    := CriaVar("DG_BANCO",.F.)
Private cAgencia  := CriaVar("DG_AGENCIA",.F.)
Private cConta    := CriaVar("DG_NUMCON",.F.)
Private cCheque   := CriaVar("DG_NUMCHEQ",.F.)
Private dDtEmis   := dDataBase
Private nSaldo    := 0
Private oVlrCtr
Private oVlrAdia
Private oVlrImp
Private oVlrPagto
Private oBanco
Private oAgenc
Private oConta
Private oCheque
Private oDtEmis

//-- Ajuste de Help
CheckHLP("PTMSA25054", {"O contrato possui valor baixado ",;
                        "superior à(s) parcela(s) final de Saldo ",;
                        ""},{''},{''},.T.)

If lTpFrota .And. DTY->DTY_TIPFRO == '1'
	Help("",1,"TMSA25043") //-- Opção não disponível para contratos de frota própria
	Return .F.
EndIf
If lLibCTC .And. ((DTY->DTY_CODOPE == '01' .And. cEncRepom $ "1;2;3") .Or. DTY->DTY_CODOPE  == '02')
	Help("",1,"TMSA25032")  // O Pagamento do saldo do contrato será realizado pela Operadora de Frota.
	Return .F.
ElseIf DTY->DTY_STATUS == '9'
	MsgAlert(STR0155 + ": " + DTY->DTY_NUMCTC + " " + STR0156) //--"O Contrato "..."esta bloqueado para pagamento!"
	Return .F.
ElseIf (DTY->DTY_STATUS == '5' .Or. DTY->DTY_STATUS == '4' .Or. DTY->DTY_STATUS == '8' .Or. DTY->DTY_STATUS == 'B' ) .And. aRotina[nOpc,4] == 4
	MsgAlert(STR0155 + ": " + DTY->DTY_NUMCTC + " " + STR0178) //--"O Contrato "..."ja foi quitado!"
	Return .F.
ElseIf lLibCTC .And. DTY->DTY_STATUS == '2'
	Help("",1,"TMSA25034") //--"Pagamento de Saldo nao permitido para contratos com Status:'Aguard.Lib.Pagto.'")
	Return .F.
ElseIf DTY->DTY_CODOPE == '01' .And. aRotina[nOpc,4] == 5
	MsgAlert(STR0155 + ": " + DTY->DTY_NUMCTC + " " + " não permite o estorno pela Operadora!") //--"O Contrato "...
	Return .F.
ElseIf ExistBlock('TM250VLD')
	If !ExecBlock("TM250VLD",.F.,.F.,{ DTY->DTY_FILORI, DTY->DTY_VIAGEM}) //--POnto de Entrada que verifica se o pagamento pode ser efetuado.
		Help("",1,"TMSA25038") //--Pagamento de Saldo nao permitido para contratos em que a viagem nao esteja encerrada.
		Return .F.
	EndIf
ElseIf DTY->DTY_CODOPE  == '02' .And. !FindFunction('TMSIDPAM')  //verificar protecao do novo fonte
	Help("",1,"TMSA25012",," TMSXFUNP.PRW",1,28) //"Atualizar patch do programa TMSXFUNP.PRW"
	Return .F.
EndIf

SA2->(dbSetOrder(1))
If SA2->(MsSeek(xFilial('SA2')+cFornec+cLoja)) .And. !Empty(SA2->A2_FILDEB)
	If !Empty(DTY->DTY_FILDEB) .And. cFilAnt <> DTY->DTY_FILDEB
		Help("",1,"TMSA25031",,DTY->DTY_FILDEB,02,40) // Pagamento do saldo do contrato deve ser efetuado na Filial de Debito.
		RestArea(aAreaDTQ)
		RestArea(aArea)
		Return .F.
	EndIf
EndIf

If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
	aCpoEnch := {"DTY_FILIAL",""          ,"DTY_NUMCTC","DTY_CODFOR","DTY_LOJFOR","DTY_NOMFOR",""}
ElseIf cTipUso == "1" //--TMS
	aCpoEnch := {"DTY_FILIAL","DTY_VIAGEM","DTY_NUMCTC","DTY_CODFOR","DTY_LOJFOR","DTY_NOMFOR",""}
EndIf

If cTmsErp != '1'
	//-- REVER PARA CODEBASE
	If (lLibCTC .And. (IIf(aRotina[nOpc,4]==4,DTY->DTY_STATUS $ '3|B',DTY->DTY_STATUS $ '3|4|5') .Or. (Empty(DTY->DTY_STATUS) .And. Empty(DTY->DTY_NUMPC)))) .Or. ;
		!lLibCTC

		nOpc := aRotina[nOpc,4]

		//-- Se o parametro MV_TPTCTC nao estiver preenchido
		If Empty(cTipCTC)
			If Len(cFilAnt) > 2
				Final(STR0186,STR0187)//--'O parametro MV_TPTCTC deve ser preenchido quando a Gestão Corporativa','estiver ativa.'
			Else
				cTipCTC := Padr( "C"+cFilAnt, Len( SE2->E2_TIPO ) ) // Tipo Contrato de Carreteiro
			EndIf
			lEmptyTptCTC:= .T.// Verifica se o parametro de Tipo do Contrato de Carreteiro esta vazio
		EndIf

		Aadd(aButtons,{"S4WB005N", {|| Fc050Con()}, STR0055})  //"Histórico de títulos a pagar"
		SE2->(DbSetOrder(1))

		// Retorna todas viagens do contrato
		#IFDEF TOP
			cAliasQry := GetNextAlias()
			If lTabDFI .And. cTipUso=="2"
				cQuery := " SELECT DTY_FILIAL, DTY_IDENT "
			Else
				cQuery := " SELECT DTY_FILIAL, DTY_VIAGEM "
			EndIf
			cQuery += "  FROM " + RetSqlName("DTY") + " DTY "
			cQuery += "  WHERE DTY_FILIAL = '" + cFilContr + "' "
			cQuery += "    AND DTY_FILORI = '" + cFilOriDTY + "' "
			cQuery += "    AND DTY_NUMCTC = '" + cNrContr + "' "
			cQuery += "    AND DTY.D_E_L_E_T_ = ' ' "
			If lTabDFI .And. cTipUso=="2"
				cQuery += "  GROUP BY DTY_FILIAL, DTY_IDENT "
			Else
				cQuery += "  GROUP BY DTY_FILIAL, DTY_VIAGEM "
			EndIf
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			bWhile := {|| (cAliasQry)->(!Eof()) }
		#ELSE
			cAliasQry := "DTY"
			DTY->(dbSetOrder(4))
			If DTY->(MsSeek(cSeek := xFilial("DTY")+cFilOriDTY+cNrContr))
				bWhile := {|| DTY->(!Eof()) .And. DTY->DTY_FILIAL+DTY->DTY_FILORI+DTY->DTY_NUMCTC == cSeek }
			EndIf
		#ENDIF

		While Eval(bWhile)
			If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
				cCarga += Posicione("DAK",4,xFilial("DAK")+(cAliasQry)->DTY_IDENT,"DAK_COD") + "|"
			ElseIf cTipUso == "1" //--TMS
				cViagem += (cAliasQry)->DTY_VIAGEM + "|"
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo

		If !Empty(cViagem) .Or. !Empty(cCarga)
			If !Empty(cViagem)
				cViagem := SubStr(cViagem,1,Len(cViagem)-1)
			EndIf
			If !Empty(cCarga)
				cCarga := SubStr(cCarga,1,Len(cCarga)-1)
			EndIf
		Else
			If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
				cCarga := Posicione("DAK",4,xFilial("DAK")+(cAliasQry)->DTY_IDENT,"DAK_COD")
			ElseIf cTipUso == "1" //--TMS
				cViagem := DTY->DTY_VIAGEM
			EndIf
		EndIf

		#IFDEF TOP
			(cAliasQry)->(DbCloseArea())
		#ENDIF

		// Valor Total do frete a pagar(Valor do Contrato).
		#IFDEF TOP
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DTY_FILDEB, SUM(DTY_VALFRE) DTY_VALFRE, MAX(DTY_CODFAV) DTY_CODFAV,MAX(DTY_LOJFAV) DTY_LOJFAV "
			cQuery += "  FROM " + RetSqlName("DTY") + " DTY "
			cQuery += "  WHERE DTY_FILIAL = '" + cFilContr + "' "
			cQuery += "    AND DTY_FILORI = '" + cFilOriDTY + "' "
			cQuery += "    AND DTY_NUMCTC = '" + cNrContr + "' "
			cQuery += "    AND DTY.D_E_L_E_T_ = ' ' "
			cQuery += "  GROUP BY DTY_FILIAL, DTY_FILDEB "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			bWhile := {|| (cAliasQry)->(!Eof()) }
		#ELSE
			cAliasQry := "DTY"
			DTY->(dbSetOrder(4))
			If DTY->(MsSeek(cSeek := xFilial("DTY")+cFilOriDTY+cNrContr))
				bWhile := {|| DTY->(!Eof()) .And. DTY->DTY_FILIAL+DTY->DTY_FILORI+DTY->DTY_NUMCTC == cSeek }
			EndIf
		#ENDIF

		While Eval(bWhile)
			//-- Verifica a Filial de Debito
			cFilDeb  := (cAliasQry)->DTY_FILDEB
			If lEmptyTptCTC
				cTipDeb := Padr( "C"+cFilDeb, Len( SE2->E2_TIPO ) )
				cTipCTC := If(cFilDeb <> cFilAnt, cTipDeb, cTipCTC)
			EndIf
			//-- Verifica se existe favorecido para o fornecedor
			If !Empty((cAliasQry)->DTY_CODFAV)
				cFornec := (cAliasQry)->DTY_CODFAV
				cLoja   := (cAliasQry)->DTY_LOJFAV
			EndIf
			If DTY->(ColumnPos('DTY_TAXBAN')>0)
				nTaxBan := DTY->DTY_TAXBAN
			EndIf
			cPrefixo := TMA250GerPrf(cFilDeb)
			nVlrCtr  += (cAliasQry)->DTY_VALFRE
			//Saldo a pagar do contrato
			// -- Posiciona no titulo principal para a enchoice
			// -- Adiciona no aRecSE2 o titulo principal para utilizacao na rotina de Compensacao automatica
			If !Empty(cFil:=FwFilial("SE2"))
				cFil := If(cFilDeb <> cFilAnt .And. lEmptyTptCTC, cFilDeb, cFilAnt)
			Else
				cFil:=xFilial("SE2")
			EndIf
			If SE2->(MsSeek(cFil+cPrefixo+cNrContr+cParcela+cTipCTC+cFornec+cLoja))
				Aadd(aRecSE2,SE2->(RecNo()))
				nSaldo  += SE2->E2_SALDO
				nVlBxE2 += SE2->(E2_VALOR - E2_SALDO) //-- Se houver baixa financeira (ou compensação), deve tratar esta diferença nas operadoras de frota
			Else
				//Help de erro
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		#IFDEF TOP
			(cAliasQry)->(DbCloseArea())
		#ENDIF
		RestArea(aArea)

		cPrefContr := TMA250GerPrf(cFilOriDTY)
		If DTY->DTY_TIPCTC <> '5'
			// -- Procura pelos adiantamentos gerados no contrato de carreteiro (NDF/PA)
			aRecNDF    := A250PsqAdi(cFornec,cLoja,cPrefixo,cFilContr,cNrContr,cViagem,cCarga,@nVlrAdiant,,cPrefContr,cCtrComp,nOpc)

			//Verifica se existe abatimento
			nVlrAdiant += SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE)

			//Adiantamento = Pagamentos antecipados+Abatimento+Impostos+Taxas+Pagamentos parciais
			If nSaldo > 0
				nSaldo := nSaldo - nVlrAdiant
			EndIf
		EndIf
		nVlrSld  := nSaldo
		nVlrAdia := nVlrCtr - nSaldo

		If ExistBlock('TM250BCO')
			aParam := ExecBlock('TM250BCO',.F.,.F.)
			If ValType(aParam) == "A"
				cBanco   := aParam[1]
				cAgencia := aParam[2]
				cConta   := aParam[3]
				lDigita  := aParam[4]
				Iif(len(aParam) == 5 .and. Valtype(aParam[5]) == "C",cCheque := aParam[5],)
			EndIf
		EndIf

		DEFINE MSDIALOG oDlg TITLE STR0056 + Iif(nOpc==5,' - '  + STR0179,'') FROM C(171),C(167) TO C(492),C(624) PIXEL //Estorno//Pagamento de Saldo

		// Cria as Groups do Sistema
		@ C(075),C(003) TO C(105),C(212) LABEL STR0057 PIXEL OF oDlg
		@ C(113),C(003) TO C(145),C(212) LABEL STR0058 PIXEL OF oDlg

		// Chamadas da Enchoice do Sistema
		// INCLUI = True  --> Traz Enchoice vazia pronta para Inclusao
		// INCLUI = False --> Traz Enchoice com o Registro definido pela variavel nReg
		RegToMemory(cAliasE, INCLUI, .F.)
		M->DTY_NOMFOR := Posicione("SA2",1,xFilial("SA2")+M->DTY_CODFOR+M->DTY_LOJFOR,"A2_NOME")
		Enchoice(	cAliasE,nReg,nOpc,,,,aCpoEnch,aPos, aAlterEnch,nModelo,,,,oDlg,lF3,;
		lMemoria,lColumn,caTela,lNoFolder,lProperty)

		If cTMSOPdg == '2' .And. ((cVsRepom == '2' .And. cCodOpe == '01') .Or. cCodOpe == '02')
			lDigita:= .F.
			lDigVlr:= .F.
			nVlrPagto := nVlrSld
			DEG->(DbSetOrder(1))
			If DEG->(MsSeek(xFilial('DEG')+cCodOpe))
				cBanco 	:= DEG->DEG_BANCO
				cAgencia := DEG->DEG_AGENCI
				cConta  	:= DEG->DEG_NUMCON
			EndIf
		ElseIf nOpc == 5
			lDigita := .F.
			lDigVlr := .F.
		EndIf
		// Cria Componentes Padroes do Sistema
		@ C(083),C(006) Say STR0059 Size C(029),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(083),C(057) Say STR0060 Size C(034),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(083),C(107) Say STR0061 Size C(029),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(083),C(158) Say STR0062 Size C(015),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(092),C(006) MsGet oVlrCtr		Var nVlrCtr   PICTURE  PesqPict("SE2","E2_ISS") When .F. Size C(050),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(092),C(057) MsGet oVlrAdia	Var nVlrAdia  PICTURE  PesqPict("SE2","E2_ISS") When .F. Size C(050),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(092),C(107) MsGet oVlrPagto	Var nVlrPagto Valid TMSA250Cal(@nVlrSld,@oVlrSld,nVlrAdia,nVlrCtr) When lDigVlr PICTURE  PesqPict("SE2","E2_ISS") Size C(050),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(092),C(158) MsGet oVlrSld		Var nVlrSld   PICTURE  PesqPict("SE2","E2_ISS") When .F. Size C(050),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(121),C(007) Say STR0063 Size C(017),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(121),C(036) Say STR0064 Size C(021),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(121),C(067) Say STR0065 Size C(028),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(121),C(106) Say STR0066 Size C(027),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(121),C(161) Say STR0067 Size C(030),C(008) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(130),C(007) MsGet oBanco  Var cBanco	F3 "SA6"	Valid CarregaSa6(@cBanco,,,.T.)						When lDigita Size C(023),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(130),C(036) MsGet oAgenc  Var cAgencia			Valid CarregaSa6(@cBanco,@cAgencia,,.T.)				When lDigita Size C(023),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(130),C(067) MsGet oConta  Var cConta				Valid CarregaSa6(@cBanco,@cAgencia,@cConta,.T.,,.T.)	When lDigita Size C(037),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(130),C(106) MsGet oCheque Var cCheque				Valid fa080Cheq() When lDigita Size C(051),C(009) COLOR CLR_BLACK OF oDlg PIXEL
		@ C(130),C(161) MsGet oDtEmis Var dDtEmis Size C(032),C(009) COLOR CLR_BLACK OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1, oDlg:End()},{||oDlg:End()},, aButtons )

		// -- Se confirmou a operacao efetua gravacao
		If nOpcA == 1
			Begin Transaction
				If nOpc == 4
					If cCodOpe == '02'	//--Pamcard
						//--- Retorna o Cartao do Motorista
						cIdOpe    := TMSIDPAM(DTY->DTY_FILORI, DTY->DTY_VIAGEM, '2' ) //2-Tipo Parcela do Pagamento da Viagem (DLD)

						// Se cartao Cancelado --> Validar a parcela na Pamcardy: Parcela Efetivada --> Libera pagamento, sem liberar o pagto na Pamcardy.
						// Se Cartao <> Cancelado --> Libera processo normal inclusive liberar pagto na Pamcardy.
						//--Consulta para saber se o Status do cartão está bloqueado..
						aRetCNPJ   := PamCNPJEmp(DTR->DTR_CODOPE, DTR->DTR_FILORI) //Função para obter CNPJ da contrante e filial de origem

						If !Empty(cIdOpe)
							AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
							AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
							AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]})
							AAdd(aConsCard,{'viagem.cartao.numero'               ,AllTrim(cIdOpe) })

							lRet := PamFindCar(aConsCard, .T., ,@cStatus)
						Endif

						If lRet .And. !Empty(cStatus) //Verifica o retorno do status do cartão
							lRet:= TMSIDPAMST(aRetCNPJ,DTY->DTY_FILORI,DTY->DTY_VIAGEM,cIdOpe,aConsCard,cStatus)
						EndIf

					EndIf

					//--Parcela Efetivada
					If lRet
						If TMSA250Grv(cPrefixo,cNrContr,cParcela,cTipCTC,cFornec,cLoja,aRecNDF,aRecSE2,cFil,cCodOpe,nOpc, ,nTaxBan)

							If lTM250SLD
								ExecBlock("TM250SLD",.F.,.F.,{ DTY->DTY_FILIAL, DTY->DTY_VIAGEM, cNrContr })
							EndIf

							If cTMSOPdg == '2' .And. cCodOpe == '02'
								aRetCNPJ   := PamCNPJEmp(cCodOpe, DTY->DTY_FILORI) //Função para obter CNPJ da contrante e filial de origem
								//--Gerar Contrato na PAMCARD com Status Liberado
								aAreaPam := GetArea()
								DTY->(DbSetOrder(1)) //
								If DTY->(MsSeek(xFilial('DTY')+DTY->DTY_NUMCTC))
									While DTY->(!Eof()) .And. DTY->DTY_NUMCTC = cNrContr
										lRet:= PamLibPaCt(DTY->DTY_FILORI, DTY->DTY_VIAGEM, aRetCNPJ, cNrContr, dDtEmis, @nVlBxE2 )
										If lRet
											DTY->(dbSkip())
										Else
											Exit
										EndIf
									EndDo
									//-- Se o valor das parcelas for inferior ao valor já baixado, retorna erro
									If nVlBxE2 > 0
										Help('',1,'TMSA25054') //-- "O contrato possui valor baixado superior à(s) parcela(s) final de Saldo "
										lRet := .F.
									EndIf

								EndIf
								RestArea(aAreaPam)
							ElseIf cTMSOPdg == '2' .And. cVsRepom == '2' .And. cCodOpe == '01'	.And. cEncRepom == "4" //-- Encerra Repom pela 1=Ocorrencia / 2=Encerramento  / 3= Lib.Contrato / 4- Pagto Saldo (novo!!!!)//-- Repom
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DTR->(DbSetOrder(1))
								If DTR->(MsSeek(xFilial('DTR')+ DTY->DTY_FILORI + DTY->DTY_VIAGEM)) .And. !Empty(DTR->DTR_CODOPE) .And. !Empty(DTR->DTR_PRCTRA)
									lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
									If !lFrotaProp
										CursorWait()
										MsgRun( STR0269,; //-- "Autorização do Pagamento do Contrato..."
												STR0083,; //-- 'Aguarde...'
												{|| lRet := TMA251Aut(  DTR->DTR_CODOPE, DTY->DTY_FILORI, DTY->DTY_VIAGEM, @aMsgErr, @aDadosQuit, DTY->DTY_NUMCTC, DTR->DTR_CODVEI, .F.)} )
										CursorArrow()
										If lRet
											RecLock('DTY',.F.)
											DTY->DTY_STATUS := "5"
											MsUnLock()
										EndIf
									EndIf
								EndIf
							EndIf

							If lRet
								Processa({|lEnd| TMSA250PBx(cFilOriDTY,cNrContr)},STR0124,STR0129,.T.) //-- "Verificando baixas. Por favor, aguarde...."
							Else
								DisarmTransaction()
							EndIf
						Else
							DisarmTransaction()
						EndIf
					Else
						DisarmTransaction()
					EndIf
				ElseIf nOpc == 5 //--Estorno Pagamento de Saldo
					If nVlrAdiant > 0 //--Se Existir Adiantamento tenta estornar o DYI
						If AliasIndic('DYI')
							If DYI->(dbSeek(cSeekDYI:= xFilial('DYI')+DTY->(DTY_FILORI+DTY_NUMCTC)))
								While DYI->(!Eof()) .And.  DYI->(DYI_FILIAL+DYI_FILORI+DYI_NUMCTC) == cSeekDYI
									Aadd( aRetorno[1], DYI->DYI_SEQBX )
									DYI->(dbSkip())
								EndDo
							Else
								Help('',1,'TMSA25039') //-- "Contrato de Carreteiro não foi encontrado na Tabela de Acerto Financeiro de Contratos." //--Exclua a baixa no Financeiro e Estorne o Contrato de Carreteiro no SIGATMS
								lRet := .F.
							EndIf
						Else
							Help('',1,'TMSA25040') //-- "Para utilizar o Estorno do Pagamento de Saldo é necessário que exista a tabela DYI." //--Rode o Update ('TMS11R114')
						EndIf
					EndIf

					If lRet .And. TMSA250Grv(cPrefixo,cNrContr,cParcela,cTipCTC,cFornec,cLoja,aRecNDF,aRecSE2,cFil,cCodOpe,nOpc,aRetorno, nTaxBan)

						If lTM250SLD
							ExecBlock("TM250SLD",.F.,.F.,{ DTY->DTY_FILIAL, DTY->DTY_VIAGEM, cNrContr })
						EndIf

						If cTMSOPdg == '2' .And. cCodOpe == '02'
							aRetCNPJ   := PamCNPJEmp(cCodOpe, DTY->DTY_FILORI) //Função para obter CNPJ da contrante e filial de origem
							//--Gerar Contrato na PAMCARD com Status Liberado
							aAreaPam := GetArea()
							DTY->(DbSetOrder(1)) //
							If DTY->(MsSeek(xFilial('DTY')+DTY->DTY_NUMCTC))
								While DTY->(!Eof()) .And. DTY->DTY_NUMCTC = cNrContr
									lRet:= PamEstPaCt(DTY->DTY_FILORI, DTY->DTY_VIAGEM, aRetCNPJ, cNrContr )
									If lRet
										DTY->(dbSkip())
									Else
										Exit
									EndIf
								EndDo
							EndIf
							RestArea(aAreaPam)
						EndIf
						If lRet
							Begin Transaction
								Processa({|lEnd| TMSA250PBx(cFilOriDTY,cNrContr)},STR0124,STR0129,.T.) //-- "Verificando baixas. Por favor, aguarde...."
							End Transaction
						Else
							DisarmTransaction()
						EndIf
					Else
						DisarmTransaction()
					EndIf
				EndIf
			End Transaction

			If !lRet .And. !Empty( aMsgErr )
				TmsMsgErr( aMsgErr )
			EndIf

		EndIf
	Else
		Help('',1,'TMSA25026') //-- 'Pagamento do saldo do contrato não autorizado.'
	EndIf
ElseIf cTmsERP == '1' .And. cCodOpe == "01" //-- DataSul + Repom
	If nOpc == 4 //-- Pagamento de Saldo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DTR->(DbSetOrder(1))
		If DTR->(MsSeek(xFilial('DTR')+ DTY->DTY_FILORI + DTY->DTY_VIAGEM)) .And. !Empty(DTR->DTR_CODOPE) .And. !Empty(DTR->DTR_PRCTRA)
			lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
			If !lFrotaProp
				CursorWait()
				MsgRun( STR0269,; //-- "Autorização do Pagamento do Contrato..."
						STR0083,; //-- 'Aguarde...'
						{|| lRet := TMA251Aut(  DTR->DTR_CODOPE, DTY->DTY_FILORI, DTY->DTY_VIAGEM, @aMsgErr, @aDadosQuit, DTY->DTY_NUMCTC, DTR->DTR_CODVEI, .F.)} )
				CursorArrow()
			EndIf
			If lRet
				RecLock('DTY',.F.)
				DTY->DTY_STATUS := "8"
				MsUnLock()
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDTQ)
RestArea(aArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Cal  ³ Autor ³ Rodrigo Gomes       ³ Data ³04/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula saldo do contrato                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Valor do saldo                                     ³±±
±±³          ³ ExpO2 - Objeto do saldo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250SLD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMSA250Cal(nVlrSld,oVlrSld,nVlrAdia,nVlrCtr)

Local   lRet    := .T.
Default nVlrSld := 0

lRet := Positivo()


// -- Valor do pagamento nao pode ser maior que o saldo
If lRet .And. nVlrPagto > nSaldo .And. !(nSaldo < 0 .And. nVlrPagto == nVlrCtr)
	lRet := .F.
	Help("",1,"TMSA25015") // -- O valor de pagamento não pode ser maior que o saldo
ElseIf lRet .And. nVlrPagto == 0
	lRet := .F.
	Help("",1,"TMSA25016") // -- O valor de pagamento deve ser maior que zero.
Else
	If nSaldo > 0
		nVlrSld := nSaldo
		nVlrSld -= nVlrPagto
		oVlrSld:Refresh()
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Grv  ³ Autor ³ Rodrigo Gomes       ³ Data ³ 04/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua a gravacao de pagamento de saldo para o contrato     ³±±
±±³          ³de carreteiro                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Prefixo do titulo                                  ³±±
±±³          ³ ExpC2 - Numero do Contrato                                 ³±±
±±³          ³ ExpC3 - Parcela do titulo                                  ³±±
±±³          ³ ExpC4 - Tipo do titulo                                     ³±±
±±³          ³ ExpC5 - Fornecedor                                         ³±±
±±³          ³ ExpC6 - Loja                                               ³±±
±±³          ³ ExpA1 - Array com os Recnos dos titulos tipo "PA" e "NDF"  ³±±
±±³          ³ ExpA2 - Array com o Recno do Titulo principal "NFF".       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250His                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSA250Grv(cPrefixo,cNContr,cParcela,cTipo,cFornece,cLoja,aRecNDF,aRecSE2,cFil,cCodOper,nOpc,aRetorno, nTaxBan)

Local cVsRepom  := SuperGetMV('MV_VSREPOM',,'1')
Local cTMSOPdg  := SuperGetMV('MV_TMSOPDG',,'0')

Local lRet      := .T.

Default aRecNDF := {}
Default aRecSE2 := {}
Default cCodOper:= ''
Default nOPc	 := 4
Default aRetorno:= {}
Default nTaxBan	:= 0

If nOpc == 4
	If cVsRepom == '2' .And. cTMSOPdg == '2' .And. cCodOper == '01' .And. SuperGetMV('MV_ENREPOM',,"1") $ "1;2"  //-- Encerra Repom por: Pagto Saldo = 3 / Ocorrencia = 2 / Rotina de Encerramento = 1
		TMA250BXCP(cPrefixo,cParcela,cTipo,cNContr,cFornece,cLoja,cFil,cCodOper)
		Return .F.
	EndIf

	// -- Chama a Rotina de Compensacao automatica
	If	MaIntBxCP(2,aRecSE2,,aRecNDF   ,,{.T.,.F.,.F.,.F.,.F.,.F.},{ | nRecSE2, cRetorno | A250SeqBx(nRecSE2,cRetorno,DTY->DTY_FILORI,DTY->DTY_NUMCTC) })
		// -- Apos a compensacao automatica chama a rotina de baixa automatica
		lRet := TMA250BXCP(cPrefixo,cParcela,cTipo,cNContr,cFornece,cLoja,cFil,cCodOper,,nTaxBan)
	EndIf
ElseIf nOpc == 5
	// -- Chama a rotina de compensacao automatica para efetuar o estorno.
	If MaIntBxCP(2,aRecSE2,{0,0,0},aRecNDF,Nil,Nil,{ | nRecSE2, cRetorno | A250SeqBx(nRecSE2,cRetorno,DTY->DTY_FILORI,DTY->DTY_NUMCTC,2) }, aRetorno)
		// -- Apos a compensacao automatica chama para cancelar a baixa.
		lRet := TMA250BXCP(cPrefixo,cParcela,cTipo,cNContr,cFornece,cLoja,cFil,cCodOper,nOpc,nTaxBan)
	EndIf
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250BXCP  ³ Autor ³ Rodrigo Gomes 		  ³ Data ³04/11/05³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Baixa Automatica do Titulo do Contas a Pagar	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Prefixo do Titulo                                   ³±±
±±³          ³ExpC2 - Parcela do Titulo                                   ³±±
±±³          ³ExpC3 - Tipo do Titulo                                      ³±±
±±³          ³ExpC4 - No. do Titulo                                       ³±±
±±³          ³ExpC5 - Proprietario do Veiculo (Fornecedor)                ³±±
±±³          ³ExpC6 - Loja do Proprietario do Veiculo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function TMA250BXCP(cPrefixo, cParcela, cTipo, cNum, cCodForn, cLojForn, cFil, cCodOper,nOpc,nTaxBan)

Local aBaixa	  		:= {}
Local lRet       		:= .T.
Local cMot				:= "NORMAL"
Local cHisto			:= 'Baixa Automatica'
Local	cVsRepom 		:= SuperGetMV('MV_VSREPOM',,'1')
Local cTMSOPdg  		:= SuperGetMV('MV_TMSOPDG',,'0')
Local cTpTitTax			:= SuperGetMV('MV_TPTTAX',,"")

Private lMsHelpAuto 	:= .T.
Private lMsErroAuto 	:= .F.
Default cCodOper		:= ''
Default nOpc 			:= 3
Default nTaxBan			:= 0

If cTMSOPdg == '2' .And. ((cVsRepom == '2' .And. cCodOper == '01') .Or. cCodOper == '02')
	cMot		:= "DEB"
	cHisto	:= "Pagto pela Operadora"
EndIf

DbSelectArea("SE2")
AADD(aBaixa , {"E2_FILIAL"  , cFil               	,Nil})
AADD(aBaixa , {"E2_PREFIXO" , cPrefixo           	,Nil})
AADD(aBaixa , {"E2_NUM"     , cNum               	,Nil})
AADD(aBaixa , {"E2_PARCELA" , cParcela           	,Nil})
AADD(aBaixa , {"E2_TIPO"    , cTipo              	,Nil})
AADD(aBaixa , {"E2_FORNECE" , cCodForn           	,Nil})
AADD(aBaixa , {"E2_LOJA"    , cLojForn           	,Nil})
AADD(aBaixa , {"AUTBANCO"	 , cBanco             	,Nil})
AADD(aBaixa , {"AUTAGENCIA" , cAgencia           	,Nil})
AADD(aBaixa , {"AUTCONTA"	 , cConta             	,Nil})
AADD(aBaixa , {"AUTCHEQUE"	 , cCheque            	,Nil})
AADD(aBaixa , {"AUTMOTBX"	 , cMot      	     	,Nil})
AADD(aBaixa , {"AUTDTBAIXA" , dDtEmis             	,Nil})
AADD(aBaixa , {"AUTHIST"	 , cHisto			 	,Nil})
AADD(aBaixa , {"AUTDESCONT" , 0                   	,Nil})
AADD(aBaixa , {"AUTMULTA"   , 0                   	,Nil})
AADD(aBaixa , {"AUTJUROS"   , 0                   	,Nil})
AADD(aBaixa , {"AUTVLRPG"   , nVlrPagto           	,Nil})
AADD(aBaixa , {"AUTVLRME"   , 0                   	,Nil})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a Baixa ou Estorno da Baixa do Titulo							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSExecAuto({|x, y| FINA080(x, y)}, aBaixa, nOpc)

//-- Se houve problemas apresenta o motivo do erro.
If lMsErroAuto
	MostraErro()
	lRet := .F.
EndIf

//-- Desde que não seja complemento
If nTaxBan > 0 .And. DTY->DTY_TIPCTC <> '5'
	aBaixa	  		:= {}
	DbSelectArea("SE2")
	AADD(aBaixa , {"E2_FILIAL"  , cFil               	,Nil})
	AADD(aBaixa , {"E2_PREFIXO" , cPrefixo           	,Nil})
	AADD(aBaixa , {"E2_NUM"     , cNum               	,Nil})
	AADD(aBaixa , {"E2_PARCELA" , cParcela           	,Nil})
	AADD(aBaixa , {"E2_TIPO"    , cTpTitTax           	,Nil})
	AADD(aBaixa , {"E2_FORNECE" , cCodForn           	,Nil})
	AADD(aBaixa , {"E2_LOJA"    , cLojForn           	,Nil})
	AADD(aBaixa , {"AUTBANCO"	, cBanco             	,Nil})
	AADD(aBaixa , {"AUTAGENCIA" , cAgencia           	,Nil})
	AADD(aBaixa , {"AUTCONTA"	, cConta             	,Nil})
	AADD(aBaixa , {"AUTCHEQUE"	, cCheque            	,Nil})
	AADD(aBaixa , {"AUTMOTBX"	, cMot 	     	     	,Nil})
	AADD(aBaixa , {"AUTDTBAIXA" , dDtEmis             	,Nil})
	AADD(aBaixa , {"AUTHIST"	 	, cHisto				 	,Nil})
	AADD(aBaixa , {"AUTDESCONT" , 0                   	,Nil})
	AADD(aBaixa , {"AUTMULTA"   , 0                   	,Nil})
	AADD(aBaixa , {"AUTJUROS"   , 0                   	,Nil})
	AADD(aBaixa , {"AUTVLRPG"   , nTaxBan 		          	,Nil})
	AADD(aBaixa , {"AUTVLRME"   , 0                   	,Nil})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a Baixa ou Estorno da Baixa do Titulo							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSExecAuto({|x, y| FINA080(x, y)}, aBaixa, nOpc)

	//-- Se houve problemas apresenta o motivo do erro.
	If lMsErroAuto
		MostraErro()
		lRet := .F.
	EndIf
EndIf
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsGrvDVP³ Autor ³ Eduardo de Souza       ³ Data ³ 23/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a composicao do frete do contrato                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Numrto do Contrato                                 ³±±
±±³          ³ ExpC3 = Viagem                                             ³±±
±±³          ³ ExpA4 = Composicao de Frete                                ³±±
±±³          ³ ExpC5 = Tipo de Uso 1=Viagem;2=Carga                       ³±±
±±³          ³ ExpC6 = Identificador de Viagem ou Carga                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsGrvDVP( cFilOri, cNumCtc, cViagem, aFrete, cTipUso, cIdent )

Local aAreaAnt := GetArea()
Local nCntFor  := 0
Local nValPas  := 0
Local nValImp  := 0
Local nValTot  := 0
Local n1Cnt    := 0
Local n2Cnt    := 0
Local bCampo   := {|x| FieldName(x) }
Local nCampos  := 0
Local aCompTot := {}
Local lGrava   := .T.
Local lDVP_SERTMS := DVP->(ColumnPos("DVP_SERTMS")) > 0

Default cFilOri := ""
Default cViagem := ""
Default cTipUso := IIf(!lTabDFI .Or. nModulo==43,"1","2")
Default cIdent  := ""

//-- Cria variaveis de memoria
nCampos := DVP->( FCount() )
RegToMemory('DVP',.T.)

Aadd(aCompTot,{0,0,0})
If Len(aFrete) > 0
	For nCntFor := 1 To Len( aFrete )
		For n2Cnt := 1 To Len( aFrete[ nCntFor, 2 ] )
			//-- Somente componentes diferente de zero
			If	aFrete[ nCntFor, 2, n2Cnt, 2 ] > 0
				lGrava := .T.
				M->DVP_FILIAL := xFilial("DVP")
				M->DVP_FILORI := cFilOri
				If cTipUso == "1" //--TMS
					M->DVP_VIAGEM := cViagem
				ElseIf cTipUso == "2" .And. lTabDFI .And. !Empty(cTipUso) //--OMS com Frete Embarcador
					M->DVP_TIPUSO := cTipUso
					M->DVP_IDENT  := cIdent
				EndIf
				If aFrete[ nCntFor, 2, n2Cnt, 3 ] != 'TF' .And. Len(aFrete[nCntFor]) >= 3 .And. !Empty(aFrete[nCntFor][3]) .And. lDVP_SERTMS
				   M->DVP_SERTMS := aFrete[nCntFor][3] //-- Serviço de transporte
				EndIf
				M->DVP_NUMCTC := cNumCtc
				M->DVP_CODPAS := aFrete[ nCntFor, 2, n2Cnt, 03 ]
				M->DVP_VALPAS := aFrete[ nCntFor, 2, n2Cnt, 02 ]
				M->DVP_VALIMP := aFrete[ nCntFor, 2, n2Cnt, 05 ]
				M->DVP_VALTOT := aFrete[ nCntFor, 2, n2Cnt, 06 ]
				//-- Atualiza a linha totalizadora do frete
				If aFrete[ nCntFor, 2, n2Cnt, 3 ] == 'TF' .And. Len(aFrete[nCntFor, 2]) >= 2  .And. Iif(lDVP_SERTMS,!Empty(M->DVP_SERTMS),.F.)
				    aCompTot[1][1] +=  nValPas
				    aCompTot[1][2] +=  nValImp
				    aCompTot[1][3] +=  nValTot
				    If lDVP_SERTMS
				    	M->DVP_SERTMS := ''
				    EndIf
				    nValPas := 0
				    nValImp := 0
					 nValTot := 0
				//-- Preenche a Linha totalizadora com os valores de total acumulados
				ElseIf aFrete[ nCntFor, 2, n2Cnt, 3 ] == 'TF' .And. Len(aFrete[nCntFor, 2]) < 2
					M->DVP_VALPAS := aCompTot[1][1]
					M->DVP_VALIMP := aCompTot[1][2]
					M->DVP_VALTOT := aCompTot[1][3]
					nValPas := 0
					nValImp := 0
					nValTot := 0
					If lDVP_SERTMS
				   	M->DVP_SERTMS := ''
				 	EndIf
				ElseIf aFrete[ nCntFor, 2, n2Cnt, 3 ] == 'TF' .And. Len(aFrete[nCntFor]) < 2
					nValPas := 0
					nValImp := 0
					nValTot := 0
					If lDVP_SERTMS
				   	M->DVP_SERTMS := ''
				 	EndIf
				Else
					nValPas += M->DVP_VALPAS
					nValImp += M->DVP_VALIMP
					nValTot += M->DVP_VALTOT
				EndIf
				//-- Efetua a gravacao
				If lGrava
					RecLock('DVP',.T.)
					For n1Cnt := 1 To nCampos
						FieldPut( n1Cnt, M->&( Eval( bCampo,n1Cnt ) ) )
					Next
				EndIf
				MsUnLock()
			EndIf
		Next
	Next
EndIf

RestArea(aAreaAnt)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA250Frt³ Autor ³ Eduardo de Souza      ³ Data ³ 23/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem a composicao de frete do contrato                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Determina como a funcao obtem a composicao de frete³±±
±±³          ³         1 = Atualiza o listbox que apresenta a composicao  ³±±
±±³          ³         2 = Obtem a composicao de frete do contrato        ³±±
±±³          ³ ExpC2 = Filial de Origem                                   ³±±
±±³          ³ ExpC3 = Numero do Contrato                                 ³±±
±±³          ³ ExpC4 = Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA250Frt(cAcao,cFilOri,cNumCtc,cViagem,aCmpFrt,cTipUso,cIdent)

Local cDscComp	:= ''
Local cOrdem	:= '00'
Local cSeek		:= ''
Local lRet		:= .T.
Local bWhile	:= {||.F.}
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aSize		:= {}
Local oDlgEsp
Local cLbx		:= ''
Local oLbxComp
Local aCompos	:= {}
Local nCntFor	:= 0
Local n1Cnt		:= 0
Local lComp     := .F.
Local lTabCar   := .T.
Local lDVP_SERTMS := DVP->(ColumnPos("DVP_SERTMS")) > 0
Local lDVP_DESSVT := .F.

Default cAcao   := '1'
Default cTipUso := IIf(!lTabDFI .Or. nModulo==43,"1","2")
Default cIdent  := ''

If DTQ->(ColumnPos('DTQ_SERADI')) > 0
	SX3->(DbSetOrder(2))
	If SX3->(MsSeek("DVP_DESSVT"))
		lDVP_DESSVT := .T.
	EndIf
EndIf

If ValType(aCmpFrt) == 'A'
	aFrete := AClone(aCmpFrt)
	If DTQ->(ColumnPos('DTQ_SERADI')) > 0
		RegToMemory("DVP",.T.)
	EndIf
EndIf

//-- Atualiza o listbox que apresenta a composicao do frete
If	cAcao == '1'
	If  !Empty(DTY->DTY_TABCAR) .And. Empty(DTY->DTY_TABFRE)
		lTabCar := .F.
	EndIf
	For nCntFor := 1 To Len(aFrete)
		If Len(aFrete[nCntFor]) >= 3 .And. lDVP_SERTMS
		    M->DVP_SERTMS := aFrete[nCntFor][3]
		EndIf
		If ValType(aFrete[nCntFor,2]) == 'A' .And. !Empty(aFrete[nCntFor,1])
			lComp := .T.
			For n1Cnt := 1 To Len(aFrete[nCntFor,2])
				AAdd(aCompos,{aFrete[nCntFor,2,n1Cnt,1],; //| Descrição do Componente
				              aFrete[nCntFor,2,n1Cnt,2],; //| Valor     do Componente
				              aFrete[nCntFor,2,n1Cnt,5],; //| Valor do Imposto / Quando Solicitação de Coleta
				              aFrete[nCntFor,2,n1Cnt,6]}) //| Na cotacao eh gravado o valor do imposto do componente
				If lDVP_SERTMS
					AAdd(aCompos[Len(aCompos)], TmsValField("M->DVP_SERTMS",.F.))
				EndIf
			Next
		EndIf
	Next

	If lComp
		//-- Calcula as dimensoes dos objetos
		aSize  := MsAdvSize( .T. )

		AAdd( aObjects, { 100, 60,.T.,.T. } )

		aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
		aPosObj:= MsObjSize( aInfo, aObjects,.T. )
		DEFINE MSDIALOG oDlgEsp TITLE STR0043 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //"Composicao do frete"
			If !lDVP_DESSVT
				@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbxComp VAR cLbx FIELDS HEADER STR0048 , STR0049 , STR0050 , STR0049 + ' + ' + STR0050 SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp ON DBLCLICK (.T.) PIXEL //'Composicao','Valor','Imposto','Valor + Imposto'
				oLbxComp:SetArray( aCompos )
		   		oLbxComp:bLine	:= { || {	aCompos[ oLbxComp:nAT, 1 ],;
											TransForm( aCompos[ oLbxComp:nAT, 2 ], PesqPict('DVP','DVP_VALPAS') ),;
											TransForm( aCompos[ oLbxComp:nAT, 3 ], PesqPict('DVP','DVP_VALIMP') ),;
											TransForm( aCompos[ oLbxComp:nAT, 4 ], PesqPict('DVP','DVP_VALTOT') ) } }
			ElseIf lTabCar
				@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbxComp VAR cLbx FIELDS HEADER STR0048 , STR0049 , STR0050 , STR0049 + ' + ' + STR0050, STR0188 SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp ON DBLCLICK (.T.) PIXEL //'Composicao','Valor','Imposto','Valor + Imposto'
		    	oLbxComp:SetArray( aCompos )
				oLbxComp:bLine	:= { || {	aCompos[ oLbxComp:nAT, 1 ],;
												TransForm( aCompos[ oLbxComp:nAT, 2 ], PesqPict('DVP','DVP_VALPAS') ),;
												TransForm( aCompos[ oLbxComp:nAT, 3 ], PesqPict('DVP','DVP_VALIMP') ),;
												TransForm( aCompos[ oLbxComp:nAT, 4 ], PesqPict('DVP','DVP_VALTOT') ),;
												TransForm( aCompos[ oLbxComp:nAT, 5 ], PesqPict('DVP','DVP_DESSVT') ) } }
		    Else
		    	@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbxComp VAR cLbx FIELDS HEADER STR0048 , STR0049 , STR0188 SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp ON DBLCLICK (.T.) PIXEL //'Composicao','Valor','Imposto','Valor + Imposto'
		    	oLbxComp:SetArray( aCompos )
		   		oLbxComp:bLine	:= { || {	aCompos[ oLbxComp:nAT, 1 ],;
											TransForm( aCompos[ oLbxComp:nAT, 2 ], PesqPict('DVP','DVP_VALPAS') ),;
											TransForm( aCompos[ oLbxComp:nAT, 5 ], PesqPict('DVP','DVP_DESSVT') ) } }
		    EndIf


		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()})
	EndIf
Else
	If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
		DVP->(DbSetOrder( 2 ))
		DVP->(MsSeek(cSeek := xFilial('DVP') + cFilOri + cNumCtc + cTipUso + cIdent ))
		bWhile := {|| DVP->( ! Eof() .And. DVP->DVP_FILIAL + DVP->DVP_FILORI + DVP->DVP_NUMCTC + DVP->DVP_TIPUSO + DVP->DVP_IDENT == cSeek ) }
	ElseIf cTipUso == "1" //--TMS
		DVP->(DbSetOrder( 1 ))
		DVP->(MsSeek(cSeek := xFilial('DVP') + cFilOri + cNumCtc + cViagem ))
		bWhile := {|| DVP->( ! Eof() .And. DVP->DVP_FILIAL + DVP->DVP_FILORI + DVP->DVP_NUMCTC + DVP->DVP_VIAGEM == cSeek ) }
	EndIf
	While Eval( bWhile )

		If	DVP->DVP_CODPAS == 'TF'
			cDscComp := STR0051 //'Total do Frete'
			cOrdem	:= 'ZZ'
		Else
			cDscComp := Posicione('DT3', 1, xFilial('DT3') + DVP->DVP_CODPAS, 'DT3_DESCRI')
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Formato do vetor aFrete                                               ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ aFrete[01] = Descricao do componente                                  ³
		//³ aFrete[02] = Valor do componente                                      ³
		//³ aFrete[03] = Codigo do componente                                     ³
		//³ aFrete[04] = Valor do imposto do componente                           ³
		//³ aFrete[05] = Total do componente ( valor + imposto )                  ³
		//³ aFrete[06] = Ordem (Inicio '00' / Fim 'ZZ')                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDVP_SERTMS
	   		AAdd( aFrete,{"",{{cDscComp,DVP->DVP_VALPAS,DVP->DVP_CODPAS,DVP->DVP_VALIMP,DVP->DVP_VALTOT,cOrdem}},DVP->DVP_SERTMS})
	 	Else
	 		AAdd( aFrete,{"",{{cDscComp,DVP->DVP_VALPAS,DVP->DVP_CODPAS,DVP->DVP_VALIMP,DVP->DVP_VALTOT,cOrdem}}})
	 	EndIf
		DVP->(DbSkip())
	EndDo

	If	Empty( aFrete )
		AAdd(aFrete,{Space(Len(DT3->DT3_DESCRI)),0,'','',0,0,'','','00'})
		ASort(aFrete,,,{|x,y| x[6] + x[3] < y[6] + y[3] })
	Else
		For nCntFor := 1 To Len(aFrete)
			ASort(aFrete[nCntFor,2],,,{|x,y| x[9] + x[3] < y[9] + y[3] })
		Next
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250se2 ³ Autor ³ Patricia A. Salomao     ³ Data ³ 17/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera SE2 (Contas a Pagar)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1  - Alias                                                ³±±
±±³          ³ExpN2  - Opcao Selecionada (3-Por Viagem / 4-Por Periodo)     ³±±
±±³          ³ExpL3  - Gera Contrato de Premio p/ Motorista. Esta variavel  ³±±
±±³          ³        e' passada pelo programa de Pagto de Premio (TMSA740) ³±±
±±³          ³ExpN4  - Valor do Premio do Motorista calculado pelo TMSA740  ³±±
±±³          ³ExpN5  - Valor do Frete do Carreteiro                         ³±±
±±³          ³ExpN6  - Valor do Pedagio                                     ³±±
±±³          ³ExpN7  - Total dos Adiantamentos                              ³±±
±±³          ³ExpC8  - Filial de Debito                                     ³±±
±±³          ³ExpC9  - Tipo do Titulo gerado para a Filial de Debito        ³±±
±±³          ³ExpC10 - Prefixo do Titulo                                    ³±±
±±³          ³ExpC11 - Condicao de Pagamento                                ³±±
±±³          ³ExpA12 - Array contendo as mensagens de erro                  ³±±
±±³          ³ExpC13 - Filial de Origem                                     ³±±
±±³          ³ExpC14 - No. da Viagem                                        ³±±
±±³          ³ExpC15 - No. do Contrato                                      ³±±
±±³          ³ExpC16 - Credor do Adiantamento                               ³±±
±±³          ³ExpC17 - Loja do Credor do Adiantamento                       ³±±
±±³          ³ExpC18 - Proprietario do Veiculo  (Fornecedor)                ³±±
±±³          ³ExpC19 - Loja do Proprietado do Veiculo                       ³±±
±±³          ³ExpC20 - Codigo do Favorecido                                 ³±±
±±³          ³ExpC21 - Loja do Favorecido                                   ³±±
±±³          ³ExpN22 - Valor do IRRF (@)                                    ³±±
±±³          ³ExpN23 - Valor do INSS (@)                                    ³±±
±±³          ³ExpN24 - Valor do SEST (@)                                    ³±±
±±³          ³ExpN25 - Valor do ISS  (@)                                    ³±±
±±³          ³ExpL26 - Gera Titulo de Adiantamento ?                        ³±±
±±³          ³ExpL27 - Valida se o parametro MV_TPTCTC esta vazio           ³±±
±±³          ³ExpC28 - Natureza do Titulo                                   ³±±
±±³          ³ExpN29 - Valor Retido de PIS                                  ³±±
±±³          ³ExpN30 - Valor Retido de COFINS                               ³±±
±±³          ³ExpN31 - Valor Retido de CSLL                          	    ³±±
±±³          ³ExpC32 - Gera Titulo do Pedagio ? (1=Sim/2=Nao)               ³±±
±±³          ³ExpC33 - Deduz Pedagio do Valor do Frete ? (1=Sim/2=Nao)      ³±±
±±³          ³ExpN34 - Valor Base para Calculo dos Impostos                 ³±±
±±³          ³ExpN35 - Valor do INSS Retido               					³±±
±±³          ³ExpC36 - Tipo de Uso 1=Viagem;2=Carga				  			³±±
±±³          ³ExpC37 - Identificador de Viagem ou Carga			  			³±±
±±³          ³ExpC38 - Gera Titulo do Contrato ? (1=Sim/2=Nao)              ³±±
±±³          ³ExpC39 - Operadora de Frete                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA250se2(cAlias,nOpcx,lCtrPremio,nValPremio,nValFrete,nValPedag,nTotValAdi,;
  			        cFilDeb,cTipDeb,cPrefAnt,cCondPag,aMsgErr,cFilOri,cViagem,cContrat,;
			        cCreAdi,cLojCre,cCodForn,cLojForn,cCodFav,cLojFav,nValIRRF,nValINSS,;
			        nValSEST,nValISS,lGerTitAdto,lEmptyTptCtc,cNatuCTC,nValRetPIS,nValRetCOF,;
					nValRetCSL,cGerTitPDG,cDedPDG,nBasImp,nInssRet,cIdent,aImposto,cCodOpe,cTipCTC)

Local lRet        := .T.
Local nItem       := 0
Local nSalFre     := 0
Local nSalDTY     := 0
Local nTotAdiNDF  := 0
Local nValor      := 0
Local nValINSSDTY := 0
Local nValIRRFDTY := 0
Local nValISSDTY  := 0
Local nAliqISS    := 0
Local nValSESTDTY := 0
Local nDifINSS    := 0
Local nDifIRRF    := 0
Local nDifSEST    := 0
Local nDifISS     := 0
Local lGerFavorec := .F.
Local cCodigo     := ''
Local cLoja       := ''
Local cTipTit     := ''
Local cFil        := ''
Local cSeek       := ''
Local cParcela    := StrZero(1, Len(SE2->E2_PARCELA))
Local cTipISS     := Alltrim(&(GetMv("MV_ISS",,'')))
Local cFornISS    := Padr( GetMV("MV_MUNIC",,''), Len(SE2->E2_FORNECE))
Local cCodRet     := Alltrim(&(GetMv("MV_TMSCRET",,''))) //-- Codigo de Retencao da DIRF
Local cForINSS    := GetMV("MV_FORINSS",,"")  // Fornecedor padrao para Titulos de INSS
Local lGerAdf     := GetMV("MV_GERADF",,.F.)  // Gera Titulo de Adiantamento de Frete com valor superior ao Valor do Frete+Pedagio
Local aDados      := {}  //-- Array utilizado para informacoes de rotina automatica
Local aAreaSE2    := SE2->(GetArea())
Local lExibeLanc  := .F.
Local lOnline     := .F.
Local cLojUniao   := StrZero(0,Len(SE2->E2_LOJA))
Local cPagamen	  := Nil
Local aAreaDTQ    := DTQ->(GetArea())
Local cTmsRIns    := GetMV("MV_TMSRINS",,"")
Local lCodIns     := SE2->(ColumnPos("E2_CODINS")) > 0
Local cMv_par01   := ""
Local cMv_par02   := ""
Local cMv_par03   := ""
Local cMv_par04   := ""
Local cMv_par05   := ""
Local cMv_par06   := ""
Local cMv_par07   := ""
Local lTmsCdPg    := SuperGetMV( 'MV_TMSCDPG',, .F. ) //Considera a condição de pagamento para contrato gerado "por viagem"
Local cDirf       := ""
Local aAreaDTY    := {}
Local aAreaSED    := SED->(GetArea())
Local lFreteBase  := SuperGetMV('MV_TMSOPDG',,'1') != '2'
Local lMsBlQl	  := .F.
Local cHistory	  := ""
Local lMostraErro := .F.
Local cSeekSE2	  := ""
Local cUniao      := GetMV("MV_UNIAO")	// Cod. para Pagto. do Imposto de Renda
Local nValDoc 	  := 0
Local cEventType  := Iif( StrZero(nOpcx,2) $ "03;04","upsert","delete")
Local cEntyName   := 'TRANSPORTDOCUMENT'
Local cTipoMsg	  := "2"
Local cSubTipMsg  := "201" // Sub Tipo Frete Normal
Local lGerTitulo  := GetMV('MV_GERTIT' ,,.T.)
Local cStatusPag  := Iif(SuperGetMv("MV_LIBCTC",,.F.)==.T.,"1","2") // Quando .T. a mensagem é enviada com o status do pagamento bloqueado 1=bloqueia;2=não bloqueia
Local aEAIRet     := {}
Local oXML        := NIL
Local lBlqUsu     := .F.
Local cAliasSE2	  := GetNextAlias()
Local nSldFav	  := 0
Local aAreaSA2    := {}

Private lMsHelpAuto := .T.
Private xCodOpe 	:= NIl

Default lCtrPremio	 := .F.
Default lGerTitAdto  := .T.
Default lEmptyTptCtc := .T. // Parametro MV_TPTCTC esta vazio
Default cNatuCTC     := ""
Default nValRetPIS   := 0
Default nValRetCOF   := 0
Default nValRetCSL   := 0
Default nValFrete	 := 0
Default cGerTitPDG   := "1"
Default cDedPDG      := "2"
Default nBasImp      := 0
Default nInssRet     := 0
Default cIdent       := ""
Default aImposto     := {}
Default cCodOpe      := ""
Default aMsgErr      := {}
Default cTipCTC 	 := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )

nValDoc := Iif(lCtrPremio == .T.,nValPremio,nValFrete)
cHistory := STR0287 + cFilOri + '/' + STR0288 + cViagem + '/' + STR0289 + cContrat //--'Filial Origem //--Viagem//--'Numero Contrato: '
If !Empty(cCodOpe)
	xCodOpe  := cCodOpe
	lMsBlQl  := .T.
	cHistory += " / " + STR0290 + TmsValField("xCodOpe",.F.,"DTR_NOMOPE") //--"Operadora de Frete:"
EndIf

If lTM250Blq
	lBlqUsu := ExecBlock("TM250BLQ",.F.,.F.,{lMsBlQl,3})
	If ValType(lBlqUsu) != "L"
		lBlqUsu := lMsBlQl
	EndIf
	lMsBlQl := lBlqUsu
EndIf
If Empty(cNatuCTC) .And. lTM250Par
	cNatuCTC := ExecBlock('TM250PAR',.F.,.F.,{1})
	If ValType(cNatuCTC) <> 'C'
		cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
	EndIf
ElseIf Empty(cNatuCTC)
	cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
EndIf

//|Acha a aliquota do ISS
nAliqISS := 0

//-- Se o contrato for gerado por Periodo:
//-- Gerar os titulos conforme a Condicao de Pagto. (Cadastro do Fornecedor)
//-- Nao fazer a Baixa por Dacao e os Controles de Filial de Debito

//-- Se o contrato for gerado por Viagem :
//-- Gerar os Titulos a Vista (Nao Verificar Condicao de Pagto do Fornecedor)

//+------------------------------------------------------------------------
//| Quando Integração com outra marca estiver habilitada é enviado os dados
//| para a(s) Marca(s) cadastrada(s) no Adapter EAI, o retorno é gravado no
//| vetor aEAIRet que contém as posições:
//|               [1]: Se a integração teve sucesso = .T. ou não = .F.
//|               [2]: XML Retornado com os impostos se houver
//|               [3]: Nome de Identificação da Mensagem Unica.
//+------------------------------------------------------------------------

If cTMSERP == "1" .And. nOpcx == 3

	If lEAIFunOK
		//Instância classe para envio da mensagem ao ERP Datasul
		aEAIRet := TmA250Clas(cFILORI,cVIAGEM,cContrat, nValDoc, nBasImp,Iif(cGerTitPDG=="1",nValPedag,0),nTotValAdi,0/*Valor NDF*/,nINSSRet,nAliqISS,cCodForn,cLojForn,""/*cCnpjForn*/, cFilDeb, ;
					dDatabase, dDatabase, "", cEventType , cEntyName, cTIPOMSG , cSubTipMsg, /*lBlqTit*/, .F./*lPreview*/, cStatusPag, .F./*lExcluir*/ )

		lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1])
	EndIf

EndIf

If lCtrPremio .And. nValPremio > 0 .And. cTmsErp == '0'
	//--Tratamento para determinar se o titulo deve
	//--compor a DIRF
	SED->(DbSetOrder(1)) //--ED_FILIAL+ED_CODIGO
	If SED->(DbSeek(xFilial("SED")+cNatuCTC))
		If (SED->(ColumnPos("ED_IRRFCAR")) > 0 .And. SED->ED_IRRFCAR == "S") .Or. SED->ED_CALCIRF == "S"
			cDirf := '1' //--SIM
		EndIf
	EndIf

    //+--------------------------------------------------------------------
    //| Quando Integração Desligada
    //+--------------------------------------------------------------------
	lRet := A050ManSE2(NIL, cContrat, cPrefAnt, cTipPre, cParcela, nValPremio, 0, cCodForn, cLojForn,;
			     			cNatuCTC, 1, NIL, "SIGATMS", dDataBase, cHistory , dDataBase, NIL, cFilAnt, {}, NIL,;
				     		NIL, NIL, nInssRet, cDirf, cCodRet, , ,lMsBlQl, cCodOpe)

	If !lRet
		lMostraErro := .T.
	EndIf
	TMA250GrvSDG(cAlias,DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cCodDesCTC, nValPremio, nItem)


 //| Quando não há premio envolvido...
Else
	If !lGerAdf .And. nValFrete+nValPedag < nTotValAdi
		AAdd( aMsgErr, { STR0042 + cFilOri + '/' + cViagem, '06', "TMSA240()" } ) //"A somatoria do Valor do Frete+Valor do Pedagio e' menor que o Total dos Adiantamentos. No. da Viagem : "
		Return( .F. )
	Else
		If lFreteBase // Considera a base de imposto como valor do frete
			nValor := IIf(nBasImp > 0, nBasImp, nValFrete)
		Else
			nValor := nValFrete
		EndIf

		If cDedPDG == "1" //-- Deduz valor do Pedagio do valor da Base de Impostos (Somente para "CALCULO DOS IMPOSTOS")
			nValor :=  nValor - nValPedag
		EndIf
		If nOpcx == 3 //Por Viagem ou Carga
			//-- Tipo de contrato de Redespacho, troca os parametros do TMA250 para o TMA252
			If DTY->DTY_TIPCTC == StrZero(7, Len(DTY->DTY_TIPCTC))
				//-- Carrega o pergunte com o sexto parametro como .F., para nao carregar o profile ( perguntas do usurario),
				//-- pois a fabrica fez customizacoes onde e' gravado o conteudo de perguntes no SX1.
				Pergunte("TMA252",.F.,,,,.F.)
				cMv_par01 := mv_par01
				cMv_par02 := mv_par02
				cMv_par03 := mv_par03
				cMv_par04 := mv_par04
				cMv_par05 := mv_par05
				cMv_par06 := mv_par06
				cMv_par07 := mv_par07

				Pergunte("TMA250",.F.)
				Mv_par01 := DTY->DTY_VIAGEM
				Mv_par02 := DTY->DTY_VIAGEM
				Mv_par03 := cMv_par05
				Mv_par04 := cMv_par06
				Mv_par05 := 2
				Mv_par06 := cMv_par07
				Mv_par07 := 1
			EndIf
			lExibeLanc := Iif(mv_par03 == 2,.F.,.T.)
			lOnline    := Iif(mv_par06 == 2,.F.,.T.)
		ElseIf nOpcx == 4 //Por Periodo
			Pergunte("TM250A",.F.)
			lExibeLanc := Iif(mv_par09 == 2,.F.,.T.)
			lOnline    := Iif(mv_par13 == 2,.F.,.T.)
		Endif

		//--Quando o contrato de carreteiro for por viagem, atualizo com o numero da viagem atual, pois
		//esta rotina e chamada n vezes de acordo com o numero de viagens, quando for por periodo
		//alimento com Nil pois nao pode verificar novamente a rota municipal, nao tenho mais uma viagem
		//estou fazendo apenas a ultima checagem para gerar os titulos de ISS
		If nOpcx == 3
			cFilVge := cFilOri
			cNumVge := cViagem
		Else
			cFilVge  := NIL
			cNumVge  := NIL
		EndIf

		//--Tratamento para determinar se o titulo deve
		//--compor a DIRF
		SED->(DbSetOrder(1)) //--ED_FILIAL+ED_CODIGO
		If SED->(DbSeek(xFilial("SED")+cNatuCTC))
			If (SED->(ColumnPos("ED_IRRFCAR")) > 0 .And. SED->ED_IRRFCAR == "S") .Or. SED->ED_CALCIRF == "S"
				cDirf := '1' //--SIM
			EndIf
		EndIf

		aAreaDTY := DTY->( GetArea() )

		If cTmsErp == '0'
			cFil    := If(cFilDeb <> cFilAnt,cFilDeb,cFilAnt)
			lRet := A050ManSE2(NIL, cContrat, cPrefAnt, cTipCTC, cParcela, nValor, 0, cCodForn, cLojForn,;
				     				cNatuCTC, 1, cCondPag , "SIGATMS", dDataBase, cHistory , IIf(nOpcx<>3 .Or. lTmsCdPg, NIL, dDataBase),,;
					        		cFil, {}, lExibeLanc, lOnline, NIL, nInssRet, cDirf, cCodRet,aImposto, nBasImp,lMsBLQL,cCodOpe)
			If !lRet
				lMostraErro := .T.
			EndIf
			RestArea( aAreaDTY )
		EndIf
	EndIf
EndIf

//-- Se Nao for Contrato de Premio
//-- Trata o retorno dos impostos gerando anteriormente ...
If !lCtrPremio .And. lRet
	//| Se integração com outra marca estiver ativa...
	If cTmsErp == "1"
	    If nOpcx == 3 .And. lEAIFunOK == .T.
            If aEAIRet[1] == .T.

                 nValIRRF   := oDTClass:oImpostos:nIRRF   //| IRRF
                 nValINSS   := oDTClass:oImpostos:nINSS   //| INSS
                 nValSEST   := oDTClass:oImpostos:nSEST   //| SEST
                 nValISS    := oDTClass:oImpostos:nISS    //| ISS

                 nValFrete  := nValFrete - (nValIRRF + nValINSS + nValSEST + nValISS)

                 nValRetPIS := oDTClass:oImpostos:nPIS    //| VRETPIS
                 nValRetCOF := oDTClass:oImpostos:nCOFINS //| VRETCOF
                 nValRetCSL := oDTClass:oImpostos:nCSLL   //| VRETCSL

             Else //| Não libera gravação se não existir o retorno de impostos ou ok.

             EndIf
        EndIf
	Else
		A250AtuSE2(cCodForn,cLojForn,cPrefAnt,cContrat,cParcela,cTipCTC,nValPedag, @nSalFre, @nValIRRF, @nValINSS, @nValSEST, @nValISS , @nValRetPIS, @nValRetCOF, @nValRetCSL, nValor,cDedPDG , nValFrete )
	EndIf

	//-- Verifica se houve diferenca de arredondamento entre os impostos gravados no SE2 e no DTY
	If nOpcx == 3
		//--Por viagem: Replica o valores dos impostos no DTY
		aAreaDTY := DTY->( GetArea() )
		DTY->( DbSetOrder(4) )
		If DTY->(DbSeek(cSeek:=xFilial('DTY')+cFilOri+cContrat))
			RecLock("DTY",.F.)
			DTY->DTY_IRRF := nValIRRF
			DTY->DTY_INSS := nValINSS
			DTY->DTY_SEST := nValSEST
			DTY->DTY_ISS  := nValISS
			DTY->( MsUnLock() )
		EndIf
		RestArea( aAreaDTY )
	ElseIf nOpcx == 4

		//| Envia a Integração para o contrato acumulado.
		If cTMSERP == "1"
			   // No momento o adiantamento será gerado ao Fechar a Viagem de acordo com a configuração no contrato de fornecedores tabela DUJ
			   // Se contrato por periodo envia as mensagens de acordo com os contratos gerados.
			   //+------------------------------------------------------------------------
                  //| Quando Integração com outra marca estiver habilitada é enviado os dados
                  //| para a(s) Marca(s) cadastrada(s) no Adapter EAI, o retorno é gravado no
                  //| vetor aEAIRet que contém as posições:
                  //|               [1]: Se a integração teve sucesso = .T. ou não = .F.
                  //|               [2]: XML Retornado com os impostos se houver
                  //|               [3]: Nome de Identificação da Mensagem Unica.
                  //+------------------------------------------------------------------------
                  If lEAIFunOK
                      //Instância classe para envio da mensagem ao ERP Datasul
                      aEAIRet := TmA250Clas(cFILORI,cVIAGEM,cContrat, nValFrete, nBasImp,Iif(cGerTitPDG=="1",nValPedag,0),nTotValAdi,0/*Valor NDF*/,nINSSRet,nAliqISS,cCodForn,cLojForn,"", cFilDeb, ;
                                            dDatabase, dDatabase, "", cEventType , cEntyName, cTIPOMSG , cSubTipMsg, /*lBlqTit*/, .F., cStatusPag, .F. )
                      lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1])

                      If lRet == .T.
                             nValIRRF   := oDTClass:oImpostos:nIRRF   //| IRRF
                             nValINSS   := oDTClass:oImpostos:nINSS   //| INSS
                             nValSEST   := oDTClass:oImpostos:nSEST   //| SEST
                             nValISS    := oDTClass:oImpostos:nISS    //| ISS

                             nValFrete  := nValFrete - (nValIRRF + nValINSS + nValSEST + nValISS)

                             nValRetPIS := oDTClass:oImpostos:nPIS    //| VRETPIS
                             nValRetCOF := oDTClass:oImpostos:nCOFINS //| VRETCOF
                             nValRetCSL := oDTClass:oImpostos:nCSLL   //| VRETCSL
                      EndIf
                  EndIf

        EndIf
		aAreaDTY := DTY->( GetArea() )

		DTY->(dbSetOrder(4))
		If DTY->(DbSeek(cSeek:=xFilial('DTY')+cFilOri+cContrat))
			//-- Por Periodo: Rateia o valor o IRRF em Todas as viagens
			Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_NUMCTC) == cSeek
				RecLock("DTY",.F.)
				If nValIRRF > 0
					DTY->DTY_IRRF := ((DTY->DTY_VALFRE * nValIRRF)/nValFrete)
				EndIf
				If nValINSS > 0
					DTY->DTY_INSS := ((DTY->DTY_VALFRE * nValINSS)/nValFrete)
				EndIf
				If nValSEST > 0
					DTY->DTY_SEST := ((DTY->DTY_VALFRE * nValSEST)/nValFrete)
				EndIf
				If nValISS > 0
					DTY->DTY_ISS := ((DTY->DTY_VALFRE * nValISS)/nValFrete)
				EndIf
				DTY->( MsUnlock() )

				nValINSSDTY += DTY->DTY_INSS
				nValIRRFDTY += DTY->DTY_IRRF
				nValSESTDTY += DTY->DTY_SEST
				nValISSDTY  += DTY->DTY_ISS
				DTY->(dbSkip())
			EndDo
		EndIf

		RestArea( aAreaDTY )

		//-- Diferenca do valor do INSS do SE2 com relacao ao DTY
		If nValINSS <> nValINSSDTY
			nDifINSS := nValINSS - nValINSSDTY
		EndIf

		//-- Diferenca do valor do IRRF do SE2 com relacao ao DTY
		If nValIRRF <> nValIRRFDTY
			nDifIRRF := nValIRRF - nValIRRFDTY
		EndIf

		//-- Diferenca do valor do SEST do SE2 com relacao ao DTY
		If nValSEST <> nValSESTDTY
			nDifSEST := nValSEST - nValSESTDTY
		EndIf

		//-- Diferenca do valor do ISS do SE2 com relacao ao DTY
		If nValISS <> nValISSDTY
			nDifISS := nValISS - nValISSDTY
		EndIf

		//-- Soma nos impostos do contrato de carreteiro a diferenca de arredondamento
		//-- no primeiro contrato que tenha o valor do imposto
		If ( nDifINSS <> 0 .Or. nDifIRRF <> 0 .Or. nDifSEST <> 0 .Or. nDifISS <> 0 ) .Or. ;
				( nValRetPIS + nValRetCof + nValRetCSL ) > 0

			DTY->(dbSetOrder(4))
			DTY->(MsSeek(cSeek:=xFilial('DTY')+cFilOri+cContrat))
			Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_NUMCTC) == cSeek
				RecLock('DTY',.F.)
				If nDifINSS <> 0 .And. DTY->DTY_INSS > 0
					DTY->DTY_INSS += nDifINSS
					nDifINSS := 0
				EndIf
				If nDifIRRF <> 0 .And. DTY->DTY_IRRF > 0
					DTY->DTY_IRRF += nDifIRRF
					nDifIRRF := 0
				EndIf
				If nDifSEST <> 0 .And. DTY->DTY_SEST > 0
					DTY->DTY_SEST += nDifSEST
					nDifSEST := 0
				EndIf
				If nDifISS <> 0 .And. DTY->DTY_ISS > 0
					DTY->DTY_ISS  += nDifISS
					nDifISS := 0
				EndIf

				nSalDTY := DTY->(DTY_VALFRE - DTY_IRRF - DTY_SEST - DTY_INSS - DTY_ISS)
				If nValRetPIS > 0 .And. nSalDTY > 0
					If nSalDTY > nValRetPIS
						DTY->DTY_PIS += nValRetPIS
						nValRetPIS   := 0
					Else
						DTY->DTY_PIS += nSalDTY
						nValRetPIS   -= nSalDTY
					EndIf
				EndIf

				nSalDTY := DTY->(DTY_VALFRE - DTY_IRRF - DTY_SEST - DTY_INSS - DTY_ISS - DTY_PIS)
				If nValRetCOF > 0 .And. nSalDTY > 0
					If nSalDTY > nValRetCOF
						DTY->DTY_COFINS += nValRetCOF
						nValRetCOF      := 0
					Else
						DTY->DTY_COFINS += nSalDTY
						nValRetCOF      -= nSalDTY
					EndIf
				EndIf

				nSalDTY := DTY->(DTY_VALFRE - DTY_IRRF - DTY_SEST - DTY_INSS - DTY_ISS - DTY_PIS - DTY_COFINS)
				If nValRetCSL > 0 .And. nSalDTY > 0
					If nSalDTY > nValRetCSL
						DTY->DTY_CSLL += nValRetCSL
						nValRetCSL    := 0
					Else
						DTY->DTY_CSLL += nSalDTY
						nValRetCSL    -= nSalDTY
					EndIf
				EndIf
				DTY->( MsUnLock() )

				If (nDifINSS+nDifIRRF+nDifSEST+nDifISS) <> 0 .Or. (nValRetPIS+nValRetCof+nValRetCSL) > 0
					DTY->(dbSkip())
				Else
					Exit
				EndIf
			EndDo
		EndIf
	EndIf


	If lRet
		//-- Gera Contas a Pagar dos Adiantamentos
		If lGerTitAdto
			TMSA250Adto(nOpcx,cFilOri,cViagem,cPrefAnt,,cCreAdi,cLojCre,cCodForn,cLojForn,cNatuDeb,cCondPag,@nTotAdiNDF,DTR->DTR_CODVEI,cContrat,,,cCodOpe)
		EndIf

		//-- Localiza Titulos de Taxa (IR / PIS/ COFINS / ...)
		SE2->(dbSetOrder(6))
		If SE2->(MsSeek(cSeek:=xFilial('SE2')+Padr(cUniao,Len(SE2->E2_FORNECE))+cLojUniao+cPrefAnt+cContrat) )
			Do While !SE2->(Eof()) .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cSeek
				If SE2->E2_TIPO == Padr( "TX", Len( SE2->E2_TIPO ) )
					RecLock("SE2",.F.)
					SE2->E2_CODRET := cCodRet
					SE2->E2_DIRF := '1' // Altera o Valor do campo, para que a rotina de geracao de DIRF localize este titulo.
					SE2->(MsUnLock())
				EndIf
				SE2->(dbSkip())
			EndDo
		EndIf

		//-- Localiza Titulo de INSS
		If SE2->(MsSeek(cSeek:=xFilial('SE2')+Padr(cForINSS,Len(SE2->E2_FORNECE))+cLojUniao+cPrefAnt+cContrat) )
			Do While !SE2->(Eof()) .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cSeek
				If SE2->E2_TIPO == Padr( "INS", Len( SE2->E2_TIPO ) )
					RecLock("SE2",.F.)
					IF lCodIns .And. !Empty(cTmsRIns)
						SE2->E2_CODINS := cTmsRIns
					EndIf
					SE2->E2_CODRET	:= cCodRet
					SE2->E2_DIRF	:= '1' // Altera o Valor do campo, para que a rotina de geracao de DIRF localize este titulo.
					SE2->(MsUnLock())
				EndIf
				SE2->(dbSkip())
			EndDo
		EndIf

		RestArea(aAreaSE2)

	EndIf //|[Fecha]  If cTmsErp == "1" .And. nOpcx == 4

	//-- Se o codigo do Favorecido for diferente do codigo do proprietario do veiculo,
	//-- Gerar o titulo do saldo para o Favorecido.
	If !Empty(cCodFav+cLojFav) .And. (cCodFav+cLojFav != cCodForn+cLojForn)
		lGerFavorec := .T.
		cCodigo     := cCodFav
		cLoja       := cLojFav
	Else
		cCodigo     := cCodForn
		cLoja       := cLojForn
	EndIf

	cTipTit := If(cFilDeb <> cFilAnt .And. lEmptyTptCTC, cTipDeb, cTipCTC)
	cFil    := If(cFilDeb <> cFilAnt,cFilDeb,cFilAnt)
	//-- Se o parametro MV_TPTCTC estiver preenchido e a filial corrente for diferente da filial de debito nao permitira a geracao do titulo e do contrato
	//-- para evitar que o titulo fique 'perdido' no finaceiro.
	//-- Se o parametro MV_TPTCTC estiver preenchido, o programa nao ira' gerar Titulo para a Filial de Debito.
	//-- Isto e' feito para evitar duplicidade de Titulos na Base ... Se o usuario quiser utilizar o conceito
	//-- de Filial de Debito, devera' deixar o sistema gerar o Tipo do Titulo, ou seja, o tipo do Titulo devera'
	//-- ser : 'C'+cFilAnt
	If lRet .And. (( lEmptyTptCTC .And. cFilDeb <> cFilAnt ) .Or. lGerFavorec)
		SED->(dbSetOrder(1))
		If SED->(MsSeek(xFilial("SED")+cNatuDeb)) .And. SED->ED_CALCIRF == 'S'
			AAdd( aMsgErr, { STR0041 + cPrefAnt + '/' + cContrat + STR0017 + cNatuDeb, '07', "" } ) //"Nao foi gerado Titulo a Pagar para a Filial de Debito. A Natureza do Titulo " ### "esta configurada para gerar IRRF. Natureza"
		ElseIf nSalFre > 0
			If nOpcx == 3 //Por Viagem
				lExibeLanc := Iif(mv_par03 == 2,.F.,.T.)
				lOnline    := Iif(mv_par06 == 2,.F.,.T.)
			ElseIf nOpcx == 4 //Por Periodo
				lExibeLanc := Iif(mv_par09 == 2,.F.,.T.)
				lOnline    := Iif(mv_par13 == 2,.F.,.T.)
			Endif

			aAReaSA2  := SA2->(GetArea())

			SA2->(dbSetOrder(1))
			SA2->(MsSeek(xFilial("SA2")+cCodigo+cLoja) )
			cPagamen := SA2->A2_COND

			If lTM250COND
				cPagamen := ExecBlock('TM250COND',.F.,.F.)
				If ValType(cPagamen) <> 'C'
					cPagamen:=Space(Len(SA2->A2_COND))
				EndIf
			EndIf

			If Empty(cPagamen)
				AAdd( aMsgErr, { STR0033 + SA2->A2_COD + "/" + SA2->A2_LOJA + ' - ' + AllTrim(SA2->A2_NREDUZ), '03', "MATA020()" } ) //"Cadastrar Condicao de Pagto. no Cadastro de Fornecedor "
				lRet := .F.
			Else
				SE4->(DbSetOrder(1))
				If !SE4->(DbSeek(xFilial('SE4')+cPagamen))
					AAdd( aMsgErr, {STR0150, '03', "MATA360()"} ) //--"A condição de pagamento informada no cadastro do fornecedor não está cadastrada para esta filial. Cadastrar a condição de pagamento nesta filial."
					lRet := .F.
				EndIf
			EndIf
			//-- Baixar o Titulo do Frete como Dacao
			//+-------------------------------------------------------------------------------------------------------
			//| Envia Integração de Baixa do Titulo à Pagar do Frete Carreteiro. (DACAO) ** Revisar a necessidade.
			//| A baixa de Titulo não será realizada por aqui, pois é de responsabilidade
			//| da marca receptora da integração Financeira - CP.
			//+-------------------------------------------------------------------------------------------------------

			If lRet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seleciona as parcelas do contrato no SE2³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				aAReaSE2  := SE2->(GetArea())
				cQuery := " SELECT E2_PARCELA, E2_VALOR, E2_VENCTO "	
				cQuery += "   FROM " + RetSqlName("SE2") + " SE2 "
				cQuery += "   WHERE SE2.E2_FILIAL       = '" + xFilial("SE2") 	+ "'"
				cQuery += "     AND SE2.E2_PREFIXO      = '" + cPrefAnt 			+ "'"
				cQuery += "     AND SE2.E2_NUM          = '" + cContrat 			+ "'"            
				cQuery += "     AND SE2.E2_TIPO         = '" + cTipCTC			+ "'"
				cQuery += "     AND SE2.E2_FORNECE      = '" + cCodForn 			+ "'" 
				cQuery += "     AND SE2.E2_LOJA         = '" + cLojForn 			+ "'" 
				cQuery += "     AND SE2.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSE2, .F., .T.)

				While (cAliasSE2)->(!Eof())
					//-- Baixar o Titulo do Frete como Dacao - NAO USA INTEGRACAO COM OUTRA MARCA
					If lRet .And. TMA250BaiTit(cPrefAnt, (cAliasSE2)->E2_PARCELA, cTipCTC, cContrat, cCodForn, cLojForn, lExibeLanc, lOnline)
						nSldFav += (cAliasSE2)->E2_VALOR
					Else
						lRet := .F.
						lMostraErro := .T.
					EndIf
				(cAliasSE2)->(DbSkip())
				EndDo 

				If lRet
					//-- Verifica o Prefixo do Titulo
						cPrefDeb := TMA250GerPrf(cFil)

						//-- Gerar o Titulo para a Filial de Debito com o Saldo do Frete
						If A050ManSE2(,cContrat,cPrefDeb,cTipTit,cParcela,nSldFav,0,cCodigo,cLoja,cNatuDeb,1, cPagamen ,"SIGATMS",dDataBase, cHistory , dDataBase, , cFil , {},lExibeLanc,lOnline,,nInssRet,,,,,lMsBLQL,cCodOpe)
							//-- Atualiza o Campo E2_FILIAL com o conteudo da Filial de Debito
							//-- Não Atualiza a filial de Débito se usou integração com Datasul ou outra marca...
							TMA250AtuFil(cCodigo,cLoja,cPrefDeb,cContrat,cFil)

						Else
							lRet := .F.
							lMostraErro := .T.
						EndIf
				EndIf

				(cAliasSE2)->( dbCloseArea() )
				RestArea(aAReaSE2)
				RestArea(aAReaSA2)
			EndIf
		EndIf

	EndIf

EndIf

If !lRet
	If lMostraErro
		If cTmsErp == '1' //| Se integração ligada - Mensagem Unica

		Else              //| Se desliado...
			MostraErro()
		EndIf
	EndIf
	DisarmTransaction()
EndIf

RestArea(aAreaDTQ)
RestArea(aAreaSED)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Adt³ Autor ³ Patricia A. Salomao   ³ Data ³ 20/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Varre todas despesas de adiantamento da Viagem gerando Titu ³±±
±±³          ³lo a Pagar para as despesas Tipo 'NDF' (que NAO movimentam  ³±±
±±³          ³financeiro)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada (3-Por Viagem/4-Por Periodo)      ³±±
±±³          ³ExpC2 - Filial de Origem                                    ³±±
±±³          ³ExpC3 - Viagem                                              ³±±
±±³          ³ExpC4 - Prefixo do Titulo                                   ³±±
±±³          ³ExpC5 - Parcela do Titulo                                   ³±±
±±³          ³ExpC6 - Credor do Adiantamento                              ³±±
±±³          ³ExpC7 - Loja do Credo                                       ³±±
±±³          ³ExpC8 - Fornecedor                                          ³±±
±±³          ³ExpC9 - Loja do Fornecedor                                  ³±±
±±³          ³ExpC10- Natureza do Titulo                                  ³±±
±±³          ³ExpC11- Condicao de Pagamento                               ³±±
±±³          ³ExpN12 - Valor Total dos Adiantamentos tipo 'NDF' (@)       ³±±
±±³          ³ExpC13- Codigo do Veiculo                                   ³±±
±±³          ³ExpC14- Numero do Contrato                                  ³±±
±±³          ³ExpC15- Tipo de Uso - 1=Viagem;2=Carga                      ³±±
±±³          ³ExpC16- Identificador de Viagem                             ³±±
±±³          ³ExpC17- Codigo do Operador                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA250Adto(nOpcx,cFilOri,cViagem,cPrefAnt,cParcela,cCreAdi,cLojCre,;
cCodForn,cLojForn,cNatuDeb,cCondPag,nTotAdiNDF,;
								 	 cCodVei,cContrat,cTipUso,cIdent,cCodOpe)

Local cTipAdtoNDF := Padr( "NDF", Len( SE2->E2_TIPO ) ) // Gera Titulo de Adiantamento do Tipo "NDF"
Local cSeekSDG    := ""
Local bWhileSDG   := {||.T.}

Default cParcela  := StrZero(1, Len(SE2->E2_PARCELA))
Default cCodVei   := ''
Default cFilOri   := ''
Default cViagem   := ''
Default cTipUso   := IIf(!lTabDFI .Or. nModulo==43,"1","2")
Default cIdent    := ''
Default cCodOpe   := ''

//-- Varre o SDG da Viagem para gerar Titulos das despesas tipo 'NDF' (que NAO movimentam Financeiro)
//-- Os Titulos das Despesas do Tipo 'PA' sao gerados no Complemento de Viagem
nTotAdiNDF := 0
SDG->(dbSetOrder(5))
cSeekSDG  := xFilial("SDG")+cFilOri+cViagem+cCodVei
bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeekSDG }

If SDG->(dbSeek(cSeekSDG))
	While Eval(bWhileSDG)
		If Empty(SDG->DG_BANCO) .And. SDG->DG_ORIGEM <> 'DTY'

			If  SDG->(ColumnPos('DG_TITGER')> 0)
				If SDG->DG_TITGER <> '1'
					nTotAdiNDF += SDG->DG_VALCOB
				EndIf
			ElseIf SDG->(ColumnPos('DG_NUMCTC')>0 )
				If Empty(SDG->DG_NUMCTC)
					nTotAdiNDF += SDG->DG_VALCOB
				EndIf
			Else
				nTotAdiNDF += SDG->DG_VALCOB
			EndIf
		EndIf
		SDG->(dbSkip())
	EndDo
EndIf

//-- Gera Titulos a Pagar de Adiantamento Tipo 'NDF'
If nTotAdiNDF > 0
	TM250SE2AD(nOpcx,cContrat,cPrefAnt,cParcela,;
	cCreAdi,cLojCre,cCodForn,cLojForn,cNatuDeb,cCondPag,;
					cTipAdtoNDF, nTotAdiNDF, cSeekSDG,cCodOpe)
EndIf

Return .T.

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250AtuSE2()
					Atualiza as informações do título a pagar de acordo com configurações do TMS

@Parametros			ExpC1 - Codigo do Fornecedor
 				    ExpC2 - Codigo da Loja do Fornecedor
					Expc3 - Prefixo do Título gerado
					Expc4 - Numero do Contrato do título gerado
					Expc5 - NUmero da Parcelo do título
					Expc6 - Tipo do título gerado para o valor do frete.
					Expn1 - Valor do Pedágio do contrato de carreteiro.
@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function A250AtuSE2(cCodForn, cLojForn, cPrefAnt, cContrat, cParcela, cTipCTC   , nValPedag , nSalFre,;
									 nValIRRF, nValINSS, nValSEST, nValISS , nValRetPIS, nValRetCOF, nValRetCSL,;
									 nValor  , cDedPDG , nValFrete )

Local lRepom	 	:= SuperGetMV('MV_VSREPOM',,'1') == '2' .And. SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local cSeekSE2	 	:= ""
Local aAreaSE2		:= {}
Local cTipISS     	:= Alltrim(&(GetMv("MV_ISS",,'')))
Local cFornISS    	:= Padr( GetMV("MV_MUNIC",,''), Len(SE2->E2_FORNECE))
Local cLojISS     	:= StrZero(0,Len(SE2->E2_LOJA))
Local cCodRet     	:= Alltrim(&(GetMv("MV_TMSCRET",,''))) //-- Codigo de Retencao da DIRF
Local cForINSS    	:= GetMV("MV_FORINSS",,"")  // Fornecedor padrao para Titulos de INSS
Local cAliasSE2	    := GetNextAlias()
Local cQuery		:= ""


Default cCodForn 	:= ""
Default cLojForn 	:= ""
Default cPrefAnt 	:= ""
Default cContrat 	:= ""
Default cParcela 	:= ""
Default cTipCTC	 	:= ""
Default nValPedag	:= ""
Default nSalFre	 	:= 0
Default nValIRRF 	:= 0
Default nValINSS 	:= 0
Default nValSEST 	:= 0
Default nValISS  	:= 0
Default nValRetPIS	:= 0
Default nValRetCOF	:= 0
Default nValRetCSL	:= 0
Default nValor		:= 0
Default cDedPDG		:= ""

If !lRepom
	cSeekSE2 := xFilial('SE2')+cCodForn+cLojForn+cPrefAnt+cContrat
Else
	cSeekSE2 := xFilial('SE2')+cCodForn+cLojForn+cPrefAnt+cContrat+cParcela+cTipCTC
EndIf

//-- Posiciona no Titulo Principal
SE2->(dbSetOrder(6))
If SE2->( DbSeeK( cSeekSE2 ) )
	aAreaSE2 := SE2->(GetArea())
	RecLock("SE2", .F.)
	If cDedPDG == "1" //-- Deduz valor do Pedagio do valor do frete Somente para "CALCULO DOS IMPOSTOS"
		SE2->E2_VALOR  += nValPedag
		SE2->E2_SALDO  += nValPedag
		SE2->E2_VLCRUZ += nValPedag
	EndIf
	SE2->( MsUnlock() )
	//-- Se o Financeiro calculou ISS e existir no Contrato gerado, somente Viagens com documentos diferentes
	//-- de 'NF de Servico', o ISS do Titulo Principal sera' zerado e o Titulo de ISS sera' deletado,
	//-- caracterizando assim, que o ISS somente sera'  cobrado em transportes municipais
	If nValISS == 0 .And. SE2->E2_ISS > 0
		//-- Zera o Valor do ISS do Titulo Principal
		RecLock('SE2',.F.)
		SE2->E2_VALOR  += SE2->E2_ISS
		SE2->E2_SALDO  += SE2->E2_ISS
		SE2->E2_VLCRUZ += SE2->E2_ISS
		SE2->E2_ISS    := 0
		MsUnLock()
	ElseIf nValIss > 0
		RecLock('SE2',.F.)
		nValor := SE2->E2_VALOR
		//-- Subtrai do Titulo Principal o Valor do ISS calculado pelo Contrato de Carreteiro e soma o Valor do ISS
		//-- calculado pelo financeiro; Isto porque, um unico contrato pode conter viagens que geraram ISS
		//-- e viagens que nao geraram ISS; Neste caso, o valor do ISS do Contrato, nao vai bater com o Valor do
		//-- ISS calculado pelo financeiro
		If SE2->E2_ISS > 0
			//-- Devolve ao Valor/Saldo do Titulo o valor do ISS calculado pelo financeiro, e subtrai o valor do ISS
			//-- calculado pelo Contrato
			SE2->E2_VALOR  := (nValor + SE2->E2_ISS) - nValISS
			SE2->E2_SALDO  := (nValor + SE2->E2_ISS) - nValISS
			SE2->E2_VLCRUZ := (nValor + SE2->E2_ISS) - nValISS
			SE2->E2_ISS    := nValIss
			SE2->(MsUnLock())
		EndIf
		//-- Atualiza o Valor do Titulo de ISS com o Valor do ISS do Contrato
		If SE2->(MsSeek(xFilial('SE2')+cFornISS+cLojISS+cPrefAnt+cContrat+cParcela+cTipISS))
			RecLock("SE2", .F.)
			SE2->E2_VALOR  := nValISS
			SE2->E2_SALDO  := nValISS
			SE2->E2_VLCRUZ := nValISS
			MsUnLock()
		EndIf
	EndIf
	//-- Atualiza o valor do SEST, somente se o valor do titulo for igual ao valor do contrato no TMS, sem os demais impostos.
	nValSEST :=  SE2->E2_SEST
	If nValSEST > 0 .AND. SE2->E2_VALOR == nValFrete - (SE2->E2_IRRF+SE2->E2_INSS+SE2->E2_ISS)
		RecLock("SE2", .F.)
		SE2->E2_VALOR  -= nValSEST
		SE2->E2_SALDO  -= nValSEST
		SE2->E2_VLCRUZ -= nValSEST
		MsUnLock()
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona as parcelas do contrato no SE2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nSalFre     := 0
	nValIRRF 	:= 0
	nValINSS 	:= 0
	nValSEST 	:= 0
	nValISS  	:= 0
	nValRetPIS 	:= 0
	nValRetCOF 	:= 0
	nValRetCSL 	:= 0

	cQuery := " SELECT E2_IRRF, E2_INSS, E2_SEST,E2_ISS,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL"	
	cQuery += "   FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += "   WHERE SE2.E2_FILIAL       = '" + xFilial("SE2") 	+ "'"
	cQuery += "     AND SE2.E2_PREFIXO      = '" + cPrefAnt 			+ "'"
	cQuery += "     AND SE2.E2_NUM          = '" + cContrat 			+ "'"            
	cQuery += "     AND SE2.E2_TIPO         = '" + cTipCTC			+ "'"
	cQuery += "     AND SE2.E2_FORNECE      = '" + cCodForn 			+ "'" 
	cQuery += "     AND SE2.E2_LOJA         = '" + cLojForn 			+ "'" 
	cQuery += "     AND SE2.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSE2, .F., .T.)

	While (cAliasSE2)->(!Eof())

		nSalFre  	+= nValFrete - ((cAliasSE2)->E2_IRRF+(cAliasSE2)->E2_INSS+(cAliasSE2)->E2_SEST+(cAliasSE2)->E2_ISS)
		nValIRRF 	+= (cAliasSE2)->E2_IRRF
		nValINSS 	+= (cAliasSE2)->E2_INSS
		nValSEST 	+= (cAliasSE2)->E2_SEST
		nValISS  	+= (cAliasSE2)->E2_ISS
		nValRetPIS 	+= (cAliasSE2)->E2_VRETPIS
		nValRetCOF 	+= (cAliasSE2)->E2_VRETCOF
		nValRetCSL 	+= (cAliasSE2)->E2_VRETCSL
		
	(cAliasSE2)->(DbSkip())
	EndDo 

	(cAliasSE2)->( dbCloseArea() )
	RestArea(aAreaSE2)
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM250SE2AD³ Autor ³ Patricia A. Salomao   ³ Data ³ 20/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os Titulos de Adiantamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada (3-Por Viagem/4-Por Periodo)      ³±±
±±³          ³ExpC1 - No. Contrato                                        ³±±
±±³          ³ExpC2 - Prefixo do Titulo                                   ³±±
±±³          ³ExpC3 - Parcela do Titulo                                   ³±±
±±³          ³ExpC4 - Credor do Adiantamento                              ³±±
±±³          ³ExpC5 - Loja do Credor                                      ³±±
±±³          ³ExpC6 - Fornecedor                                          ³±±
±±³          ³ExpC7 - Loja do Fornecedor                                  ³±±
±±³          ³ExpC8 - Natureza do Titulo                                  ³±±
±±³          ³ExpC9 - Condicao de Pagamento                               ³±±
±±³          ³ExpC10- Tipo do Adiantamento (PA / NDF)                     ³±±
±±³          ³ExpN2 - Valor do Adiantamento                               ³±±
±±³          ³ExpC2 - Chave de pesquisa da tabela de Adiantamentos        ³±±
±±³          ³ExpC11- Codigo do Operador	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TM250SE2AD(	nOpcx,cContrat,cPrefAnt,cParcela,;
							cCreAdi,cLojCre,cCodForn,cLojForn,cNatuDeb,cCondPag,;
							cTipAdto,nTotValAdi,cSeekSDG,cCodOpe,cNatuCTC, lPaMovBco, aDadosBco )
Local lExibeLanc := .F.
Local lOnline    := .F.
Local lRet       := .T.
Local aAreaDTY   := DTY->(GetArea())
Local bWhileSDG  := {||.T.}
Local lTmsCdPg   := SuperGetMV( 'MV_TMSCDPG',, .F. ) //Considera a condição de pagamento para contrato gerado "por viagem"
Local cCodRet    := Alltrim(&(GetMv("MV_TMSCRET",,''))) //-- Codigo de Retencao da DIRF
Local cDirf      := ''
Local aAreaSED   := SED->(GetArea())
Local lMsBlQl	 := .F.
Local cHistory	 := ""
Local cFornTit	 := ""
Local cLojaTit 	 := ""
Local cEventType := Iif( StrZero(nOpcx,2) $ "03;04","upsert","delete")
Local cCnpjForn	 := ""
Local lStatusPgt  := SuperGetMv("MV_LIBCTC",,.F.)
Local cTIPOMSG      := "2"  // Tipo Contrato Carreteiro.
Local cEntyName		:= "TRANSPORTDOCUMENT"
Local cSubTipMsg	:= "202" //201-Carreteiro Normal;202-Carreteiro NDF;
Local lGerTitulo 	:= GetMV('MV_GERTIT' ,,.T.)
Local aEAIRet       := {}

Default nOpcx	 	:= 0
Default cContrat 	:= ""
Default cPrefAnt 	:= ""
Default cParcela 	:= ""
Default cCreAdi  	:= ""
Default cLojCre	 	:= ""
Default cCodForn 	:= ""
Default cLojForn 	:= ""
Default cNatuDeb 	:= ""
Default cCondPag 	:= ""
Default cTipAdto 	:= ""
Default nTotValAdi	:= ""
Default cSeekSDG 	:= ""
Default cCodOpe	 	:= ""
Default cNatuCTC    := ""
Default aDadosBco	:= {}
//-- Se o Credor do Adiantamento nao for o proprietario do veiculo
If !Empty(cCreAdi+cLojCre) .And. cCreAdi+cLojCre <> cCodForn+cLojForn
	cFornTit := cCreAdi
	cLojaTit := cLojCre
Else
	cFornTit := cCodForn
	cLojaTit := cLojForn
EndIf
cHistory := STR0287 + DTQ->DTQ_FILORI + '/' + STR0288 + DTQ->DTQ_VIAGEM + '/' + STR0289 + cContrat //--'Filial Origem //--Viagem//--'Numero Contrato: '

If !Empty(cCodOpe)
	xCodOpe  := cCodOpe
	lMsBlQl  := .T.
	cHistory += " / " + STR0290 + TmsValField("xCodOpe",.F.,"DTR_NOMOPE") //--"Operadora de Frota:"
EndIf

If nOpcx == 3 //Por Viagem
	Pergunte("TMA250",.F.)
	lExibeLanc := Iif(mv_par03 == 2,.F.,.T.)
	lOnline    := Iif(mv_par06 == 2,.F.,.T.)
ElseIf nOpcx == 4 //Por Periodo
	If !lExcSched250
		Pergunte("TM250A",.F.)
	EndIf
	lExibeLanc := Iif(mv_par09 == 2,.F.,.T.)
	lOnline    := Iif(mv_par13 == 2,.F.,.T.)
Endif

//--Tratamento para determinar se o titulo deve
//--compor a DIRF
SED->(DbSetOrder(1)) //--ED_FILIAL+ED_CODIGO
If SED->(DbSeek(xFilial("SED")+cNatuCTC))
	If (SED->(ColumnPos("ED_IRRFCAR")) > 0 .And. SED->ED_IRRFCAR == "S") .Or. SED->ED_CALCIRF == "S"
		cDirf := '1' //--SIM
	EndIf
EndIf

//-- Se o Credor do Adiantamento nao for o proprietario do veiculo
If cTMSERP == "1"

	cSubTipMsg      := "202" //| Gera NDF

	If lEAIFunOK == .T.
		If FwHasEAI("TMSA250",.T.,,.T.) == .T. //| Valida se o cadastro do Adapter par Mensagem única existe

			If !Empty(cCreAdi+cLojCre) .And. cCreAdi+cLojCre <> cCodForn+cLojForn// Troca o código do fornecedor pelo do Credor
				cCodForn := cCreAdi
				cLojForn := cLojCre
			EndIf

			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(FwxFilial('SA2')+cCodForn+cLojForn))
			cCnpjForn := (SA2->A2_CGC)
			EndIf
			aEAIRet := TmA250Clas(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,cContrat, nTotValAdi, 0, 0, 0, 0, 0, 0, cCodForn,cLojForn,cCnpjForn, cFilDeb, ;
					dDatabase, dDatabase, cHistory, cEventType, cEntyName, cTIPOMSG , cSubTipMsg,/*lBlqTit*/, .F., lStatusPgt, .F. )
			lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1])

		Else //| Se não existir o cadastro avisa o usuário para realizar o cadastro
			Aviso(STR0085,STR0067,{STR0086},2)//|"Atençao; Nao Foi localizada a configuração da Mensagem Unica para a Rotina TMSA310,...;Fechar
			lRet      := .F.
			Return lRet
		EndIf

	EndIf

//| Integração desligada...
Else
	lRet := A050ManSE2(NIL, cContrat, cPrefAnt, cTipAdto, cParcela, nTotValAdi, 0, cFornTit, cLojaTit,;
							cNatuDeb, 1, IIf(nOpcx<>3 .Or. lTmsCdPg, IIf(Empty(cCondPag), '', cCondPag), ''), "SIGATMS", dDataBase,;
							cHistory, IIf(nOpcx<>3 .Or. lTmsCdPg, Nil, dDataBase), NIL, cFilAnt, aDadosBco, lExibeLanc,;
							lOnline, NIL, NIL, cDirf, cCodRet,,,lMsBLQL,cCodOpe, lPaMovBco)
EndIf

If lRet .And. nTotValAdi > 0

	DTY->(DbSetOrder(1))
	DTY->(MsSeek(xFilial("DTY")+cContrat))

	SDG->(dbSetOrder(5))
	cSeekSDG  := xFilial("SDG")+DTY->DTY_FILORI+DTY->DTY_VIAGEM+DTY->DTY_CODVEI
	bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeekSDG }

	If SDG->(dbSeek(cSeekSDG))
		While Eval(bWhileSDG)
			If Empty(SDG->DG_BANCO) .And. (SDG->DG_ORIGEM <> 'DTY' .Or. Left(FunName(),7) == "TMSA251")
				If SDG->(ColumnPos('DG_NUMCTC')) > 0
					If Empty(SDG->DG_NUMCTC)
						Reclock("SDG",.F.)
						SDG->DG_NUMCTC := cContrat
						SDG->( MsUnlock() )
					EndIf
		   		EndIf

				//| Efetua baixa do movimento de transporte.
				//| Baixa somente se integração nativa do protheus estiver ligada.
				If cTMSERP == "0"
				   TMSA070Bx("1",SDG->DG_NUMSEQ,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,,,SDG->DG_VALCOB,,"")
				EndIf

			EndIf
			SDG->(dbSkip())

		EndDo
	EndIf
EndIf

RestArea(aAreaDTY)
Return lRet

/*------------------------------------------------------------------------------------------------
//{Protheus.doc} ³A250TitPdg³()
					Atualiza as informações do título a pagar de acordo com configurações do TMS

@Parametros			ExpC1 - Filial de Origem da Viagem
					ExpC2 - No. da Viagem
					ExpC3 - Codigo do Veiculo
					ExpC4 - Codigo do Fornecedor
					ExpC5 - Loja do Fornecedor
					ExpN1 - Valor do Pedágio do contrato de carreteiro.
					ExpC6 - Numero do Contrato de Carreteiro
					ExpN2 - Valor do Inss Retido
					ExpC7 - Codigo da Operadora de Frete
					ExpN3 - Opção Selecionada
					ExpC8 - Numero do movimento de custo no SDG
					ExpN4 - NUmero do Item a ser gravado na SDG
					ExpC9 - Informa se a baixa do título de pedágio será automática.
					Expl1 - INforma se o SDG será gerado.
@author Guilherme Gaiofatto
@since 10/11/2011
@version 1.0
------------------------------------------------------------------------------------------------*/
Function A250TitPdg(cFilOri, cViagem, cCodVei, cCodForn, cLojForn, nValPDG, cContrat, nInssRet, cCodOpe, nOpcX,cDocSDG,nItem, cBaixaAuto, lGeraSDG, nParcPDG )
Local aArea      := GetArea()
Local aAreaDTR   := DTR->(GetArea())
Local aAreaDTA   := DTA->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDUO   := DUO->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local cParcela   := StrZero(1, Len(SE2->E2_PARCELA))
Local cParc      := StrZero(1, Len(SE2->E2_PARCELA))
Local cTipoDoc   := Padr( "", Len( SE5->E5_TIPODOC ) )
Local cCodDesPDG := Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio
Local cPrefixo   := TMA250GerPrf(cFilAnt)
Local aDocViag   := {}		//-- Documentos por viagem
Local aCliDev    := {}      //-- Cliente devedor
Local aVeic	     := {}		//-- array aVeiculos
Local aDadosBco  := {}
Local aBaixaPdg	 := {}
Local nCont      := 0
Local nSeek      := 0
Local lCalcPdg   := .T.
Local lRet 		 := .T.
Local cCodRet    := Alltrim(&(GetMv("MV_TMSCRET",,''))) //-- Codigo de Retencao da DIRF
Local lMsBlQl	 := .F.
Local cDirf		 := ''
Local cParcPDG   := ""
Local cEnRepom   := SuperGetMV('MV_ENREPOM',,"1")

If !Empty(cCodOpe)
	lMsBlQl  := .T.
EndIf

Private lMSErroAuto 	:= .F. // inicializa como falso, se voltar verdadeiro e' que deu erro
Private l050MSErroAuto  := .F.

Default cCodVei		:= ''
Default nValPDG    	:=  0 //-- valor pedagio DTR
Default nINSSRet	:=  0 //-- valor do INSS Retido
Default cCodOpe 	:= "" //-- Codigo da Operadora de Frete
Default nOpcX	 	:=  3
Default cBaixaAuto	:= '1'
Default lGeraSDG   	:= .T.
Default nParcPDG   	:= 1
Default	cContrat	:= ""

cParcPDG := StrZero(nParcPDG, Len(SE2->E2_PARCELA))

If cTmsErp == '0' //--Faz validações necessárias para geração de títulos no SIGAFIN
	A250VldNat(SuperGetMv("MV_TPTCTC",,""),@cNatuPDG,@cNatuDeb)
EndIf

If cCodOpe == '01' .And. AllTrim(cEnRepom) $ "1|2" //--Repom
	lRet:= TMSA250PGR(cFilAnt,cViagem,DTY->DTY_CODVEI,DTY->DTY_CODOPE)
EndIf
If lRet
	SE5->(dbSetOrder(2))
	If SE5->(MsSeek(cSeek:=xFilial('SE5')+cTipoDoc+cPrefixo+cViagem))
		Do While !SE5->(Eof()) .And. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO) == cSeek
			cParcela:=Soma1(SE5->E5_PARCELA)
			SE5->(dbSkip())
		EndDo
	EndIf
	DUD->(DbSetOrder(4)) //-- Posiciona no Movimento de Viagem para obter codigo dos Documentos da viagem
	If DUD->(DbSeek(cSeek:=xFilial("DUD")+cFilOri+'3'+cViagem))
		Do While DUD->(!EoF()) .And.	DUD->(DUD_FILIAL+DUD_FILORI+DUD_STATUS+DUD_VIAGEM) == cSeek
			Aadd(aDocViag,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE})
			DUD->(dbSkip())
		EndDo
	EndIf

	DT6->(DbSetOrder(1)) //-- Posiciona no Doc. de Viagem para obter os Devedores
	If !Empty(aDocViag)
		For nCont := 1 to Len(aDocViag)
			If DT6->(DbSeek(xFilial("DT6")+aDocViag[nCont][1]+aDocViag[nCont][2]+aDocViag[nCont][3]))
				Aadd(aCliDev,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV})
			EndIf
		next
	EndIf

	DUO->(DbSetOrder(1)) //-- Posiciona no Perfil do Cliente
	If !Empty(aCliDev)
		For nCont := 1 to Len(aCliDev)
			If DUO->(DbSeek(xFilial("DUO")+aCliDev[nCont][1]+aCliDev[nCont][2]))
				If DUO->DUO_PGPEDG = '1' //-- Se algum cliente pagar pedagio
					lRet := lCalcPdg := .F.      //-- ele nao sera pago pela Repom
				EndIf
			EndIf
		Next
	EndIf

	If lCalcPdg
		//-- Recebe informacoes do banco do fornecedor
		DEG->(dbSetOrder(1))
		If DEG->(MsSeek(xFilial("DEG")+cCodOpe))
			If !Empty(DEG->DEG_BANCO) .And. !Empty(DEG->DEG_AGENCI) .And. !Empty(DEG->DEG_NUMCON)
				AAdd(aDadosBco, DEG->DEG_BANCO)
				AAdd(aDadosBco, DEG->DEG_AGENCI)
				AAdd(aDadosBco, DEG->DEG_NUMCON )
				AAdd(aDadosBco, '')  // cheque
			EndIf
		EndIf
		If !IsInCallStack('TMSA310Grv')
			If nOpcx == 3 //Por Viagem
				lExibeLanc := Iif(mv_par03 == 2,.F.,.T.)
				lOnline    := Iif(mv_par06 == 2,.F.,.T.)
			ElseIf nOpcx == 4 //Por Periodo
				lExibeLanc := Iif(mv_par09 == 2,.F.,.T.)
				lOnline    := Iif(mv_par13 == 2,.F.,.T.)
			EndIf
		Else
			lExibeLanc	:= .F.
			lOnLine	:= .F.
		EndIf

		//--Tratamento para determinar se o titulo deve
		//--compor a DIRF
		SED->(DbSetOrder(1)) //--ED_FILIAL+ED_CODIGO
		If SED->(DbSeek(xFilial("SED")+cNatuPdg))
			If (SED->(ColumnPos("ED_IRRFCAR")) > 0 .And. SED->ED_IRRFCAR == "S") .Or. SED->ED_CALCIRF == "S"
				cDirf := '1' //--SIM
			EndIf
		EndIf

		If !IsInCallStack('Tmsa310Grv') //--So verifica o favorecido se não for chamada do fechamento da viagem, já que o fechamento da viagem já verifica o favorecido
			aCodFav := T250BscFav(cCodVei,cCodForn,cLojForn,cFilOri,cViagem)	// retorna o codigo do Favorecido
			If !Empty(aCodFav)
				cCodForn := aCodFav[1][1]
				cLojForn := aCodFav[1][2]
			EndIf
		EndIf

		//-- Grava SDG  --
		If lGeraSDG //--TMS
			TMA250GrvSDG("DTY",cFilOri, cViagem, cCodDesPDG, nValPDG,nItem,cCodVei,cDocSDG,,,,,,,.T.,IIf(!Empty(aDadosBco),aDadosBco[1],),;
				IIf(!Empty(aDadosBco),aDadosBco[2],),IIf(!Empty(aDadosBco),aDadosBco[3],))   // tms
		Endif


		//-- Gera SE2
		lRet := A050ManSe2(3, cContrat, cPrefixo, 'PDG', cParcPDG, nValPDG,0, cCodForn,;
			cLojForn, cNatuPdg, 1,,'SIGATMS',dDatabase, 'Pedagio',;
			dDatabase, , cFilOri, aDadosBco,lExibeLanc,lOnLine,,nInssRet,cDirf,cCodret,,,lMsBLQL,cCodOpe)

		If !lRet
			DisarmTransaction()
			Mostraerro()
		ElseIf  !Empty(aDadosBco) .And. cBaixaAuto <> '2'
			DbSelectArea("SE2")
			cContrat := Pad(cContrat, TamSX3("E2_NUM")[1]," ")  
			AADD(aBaixaPdg , {"E2_FILIAL"  , If(!Empty(FwFilial("SE2")),cFilOri,xFilial("SE2"))              ,Nil})
			AADD(aBaixaPdg , {"E2_PREFIXO" , cPrefixo           		,Nil})
			AADD(aBaixaPdg , {"E2_NUM"     , cContrat			 		,Nil})
			AADD(aBaixaPdg , {"E2_PARCELA" , cParcela           		,Nil})
			AADD(aBaixaPdg , {"E2_TIPO"    , "PDG"		           		,Nil})
			AADD(aBaixaPdg , {"E2_FORNECE" , cCodForn           		,Nil})
			AADD(aBaixaPdg , {"E2_LOJA"    , cLojForn           		,Nil})
			AADD(aBaixaPdg , {"AUTBANCO"   , aDadosBco[1]         		,Nil})
			AADD(aBaixaPdg , {"AUTAGENCIA" , aDadosBco[2]         		,Nil})
 			AADD(aBaixaPdg , {"AUTCONTA"	 , aDadosBco[3]         	,Nil})
			AADD(aBaixaPdg , {"AUTCHEQUE"  , aDadosBco[4]        		,Nil})
			AADD(aBaixaPdg , {"AUTMOTBX"   , "DEBITO"           		,Nil})
			AADD(aBaixaPdg , {"AUTDTBAIXA" , dDataBase            		,Nil})
			AADD(aBaixaPdg , {"AUTHIST"	   , 'Pedagio' 					,Nil})
			AADD(aBaixaPdg , {"AUTDESCONT" , 0                   		,Nil})
			AADD(aBaixaPdg , {"AUTMULTA"   , 0                   		,Nil})
			AADD(aBaixaPdg , {"AUTJUROS"   , 0                   		,Nil})
			AADD(aBaixaPdg , {"AUTVLRPG"   , nValPDG      	     		,Nil})
			AADD(aBaixaPdg , {"AUTVLRME"   , 0                   		,Nil})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa a Baixa do Titulo                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MSExecAuto({|x, y| FINA080(x, y)}, aBaixaPdg, 3)
			If lMsErroAuto
				MostraErro()
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//-- Apresenta as Mensagens de Erro ocorridas durante o processamento da Rotina Automatica
	If !lRet
		If lCalcPdg
			MostraErro()
		EndIf
	ElseIf DTR->(ColumnPos('DTR_TITPDG'))> 0 .And. DTR->(ColumnPos('DTR_ORIPDG'))> 0
		//--GRAVA NA DTR A INFORMAÇÃO QUE O TÍTULO DO PEDÁGIO JÁ FOI GERADO
		DTR->(dbSetOrder(3))
		If DTR->(dbSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei))
			RecLock('DTR',.F.)
			DTR->DTR_TITPDG := '1'
			DTR->DTR_ORIPDG := 'TMSA250'
			MsUnLock()
		EndIf
	EndIf
EndIf

RestArea( aArea )
RestArea( aAreaDTR )
RestArea( aAreaDTA )
RestArea( aAreaDT6 )
RestArea( aAreaDUO )
RestArea( aAreaSA2 )

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250TitTax³ Autor ³Fabio Marchiori Sampaio³ Data ³23.12.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gerar Titulo de Taxas Bancarias (Exclusivo Pamcard )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250TitTax(ExpA1,ExpC1,ExpC2,ExpC3,ExpN1)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpC1 - Filial de Origem da Viagem                          ³±±
±±³          ³ExpC2 - No. da Viagem                                       ³±±
±±³          ³ExpC3 - Codigo do Veiculo                                   ³±±
±±³          ³ExpC6 - Proprietario do Veiculo                             ³±±
±±³          ³ExpC7 - Loja do Proprietario                                ³±±
±±³          ³ExpN2 - Valor de pedagio informado no DTR                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A250TitTax(cFilOri, cViagem, cCodVei, cCodForn, cLojForn, nValTax, cContrat,nInssRet, cCodOpe, nOpcX, cDocSDG,nItem  )

Local aArea      := GetArea()
Local aAreaDTR   := DTR->(GetArea())
Local aAreaDTA   := DTA->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDUO   := DUO->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local cParcela   := StrZero(1, Len(SE2->E2_PARCELA))
Local cParc      := StrZero(1, Len(SE2->E2_PARCELA))
Local cTipoDoc   := Padr( "", Len( SE5->E5_TIPODOC ) )
Local cNatTax    := SuperGetMV( 'MV_NATTXBA',, '0' )
Local cCodDesTAX := Padr( GetMV("MV_DESTXBA"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio
Local cPrefixo   := TMA250GerPrf(cFilAnt)
Local aDocViag   := {}		//-- Documentos por viagem
Local aCliDev    := {}      //-- Cliente devedor
Local aVeic	   	 := {}		//-- array aVeiculos
Local aDadosBco  := {}
Local nCont      := 0
Local nSeek      := 0
Local lRet       := .T.
Local cCodRet    := Alltrim(&(GetMv("MV_TMSCRET",,''))) //-- Codigo de Retencao da DIRF
Local lMsBlQl	 := .F.
Local cDirf      := ''
Local cTpTitTax	 := SuperGetMv('MV_TPTTAX',,"")

If !Empty(cCodOpe)
	lMsBlQl  := .T.
EndIf

Private lMSErroAuto 	:= .F. // inicializa como falso, se voltar verdadeiro e' que deu erro
Private l050MSErroAuto  := .F.

Default nINSSRet:=  0 //-- valor do INSS Retido
Default cCodOpe := "" //-- Codigo da Operadora de Frete
Default nOpcX	 :=  3

SE5->(dbSetOrder(2))
If SE5->(MsSeek(cSeek:=xFilial('SE5')+cTipoDoc+cPrefixo+cViagem))
	Do While !SE5->(Eof()) .And. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO) == cSeek
		cParcela:=Soma1(SE5->E5_PARCELA)
		SE5->(dbSkip())
	EndDo
EndIf
DUD->(DbSetOrder(4)) //-- Posiciona no Movimento de Viagem para obter codigo dos Documentos da viagem
If DUD->(DbSeek(cSeek:=xFilial("DUD")+cFilOri+'3'+cViagem))
	Do While DUD->(!EoF()) .And.	DUD->(DUD_FILIAL+DUD_FILORI+DUD_STATUS+DUD_VIAGEM) == cSeek
		Aadd(aDocViag,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE})
		DUD->(dbSkip())
	EndDo
EndIf

DT6->(DbSetOrder(1)) //-- Posiciona no Doc. de Viagem para obter os Devedores
If !Empty(aDocViag)
	For nCont := 1 to Len(aDocViag)
		If DT6->(DbSeek(xFilial("DT6")+aDocViag[nCont][1]+aDocViag[nCont][2]+aDocViag[nCont][3]))
			Aadd(aCliDev,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV})
		EndIf
	next
EndIf

//-- Recebe informacoes do banco do fornecedor
DEG->(dbSetOrder(1))
If DEG->(MsSeek(xFilial("DEG")+cCodOpe))
	If !Empty(DEG->DEG_BANCO) .And. !Empty(DEG->DEG_AGENCI) .And. !Empty(DEG->DEG_NUMCON)
		AAdd(aDadosBco, DEG->DEG_BANCO)
		AAdd(aDadosBco, DEG->DEG_AGENCI)
		AAdd(aDadosBco, DEG->DEG_NUMCON )
		AAdd(aDadosBco, '')  // cheque
	EndIf
EndIf

If nOpcx == 3 //Por Viagem
	lExibeLanc := Iif(mv_par03 == 2,.F.,.T.)
	lOnline    := Iif(mv_par06 == 2,.F.,.T.)
ElseIf nOpcx == 4 //Por Periodo
	lExibeLanc := Iif(mv_par09 == 2,.F.,.T.)
	lOnline    := Iif(mv_par13 == 2,.F.,.T.)
Endif

//--Tratamento para determinar se o titulo deve
//--compor a DIRF
SED->(DbSetOrder(1)) //--ED_FILIAL+ED_CODIGO
If SED->(DbSeek(xFilial("SED")+cNatuPDG))
	If (SED->(ColumnPos("ED_IRRFCAR")) > 0 .And. SED->ED_IRRFCAR == "S") .Or. SED->ED_CALCIRF == "S"
		cDirf := '1' //--SIM
	EndIf
EndIf

aCodFav := T250BscFav(cCodVei,cCodForn,cLojForn,cFilOri,cViagem)	// retorna o codigo do Favorecido
If !Empty(aCodFav)
	cCodForn := aCodFav[1][1]
	cLojForn := aCodFav[1][2]
EndIf

//-- Grava SDG  --

TMA250GrvSDG("DTY",cFilOri, cViagem, cCodDesTAX, nValTax,nItem,cCodVei,cDocSDG,,,,,,,.T.,IIf(!Empty(aDadosBco),aDadosBco[1],),;
					IIf(!Empty(aDadosBco),aDadosBco[2],),IIf(!Empty(aDadosBco),aDadosBco[3],))   // tms


If Empty(cTpTitTax)
	Help("",1,"TMSA25003",,"MV_TPTTAX",5,5) // Este Parametro esta vazio ... E Obrigatorio preenche-lo para geracao do Contrato de Carreteiro
	DisarmTransaction()
Else  
	//-- Gera SE2
	lRet := A050ManSe2(3, cContrat, cPrefixo, cTpTitTax , cParcela, nValTax,0, cCodForn,;
					cLojForn, cNatTax, 1,,'SIGATMS',dDatabase, 'TX Saque Transf',;
					dDatabase, , cFilOri, aDadosBco,lExibeLanc,lOnLine,,nInssRet,cDirf,cCodret,,,lMsBLQL,cCodOpe)

EndIf 

If !lRet
	DisarmTransaction()
	Mostraerro()
EndIf


RestArea( aArea )
RestArea( aAreaDTR )
RestArea( aAreaDTA )
RestArea( aAreaDT6 )
RestArea( aAreaDUO )
RestArea( aAreaSA2 )

Return .T.
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250VlCoPg()
					VAlidação da condição de pagamento informada no fornecedor ou pelo ponto de
					entrada TM250COND
@Parametros			ExpC1 - Condição de pagamento
 				    ExpA1 - Mensagem de Erro a ser apresentada ao usuário.

@author leandro.paulino
@since 12/09/2016
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function A250VlCoPg(cCondPag,aMsgErr)

Local lRet		 := .T.

Default cCondPag := ""
Default aMsgErr	 := ""

//-- Condicao de Pagamento do Proprietario do Veiculo
cCondPag := SA2->A2_COND
If lTM250COND
	cCondPag := ExecBlock('TM250COND',.F.,.F.)
	If ValType(cCondPag) <> 'C'
		cCondPag:=Space(Len(SA2->A2_COND))
	EndIf
EndIf

If Empty(cCondPag)
	AAdd( aMsgErr, { STR0033 + SA2->A2_COD + "/" + SA2->A2_LOJA + ' - ' + AllTrim(SA2->A2_NREDUZ), '03', "MATA020()" } ) //"Cadastrar Condicao de Pagto. no Cadastro de Fornecedor "
	lRet := .F.
Else
	SE4->(DbSetOrder(1))
	If !SE4->(DbSeek(xFilial('SE4')+cCondPag))
		AAdd( aMsgErr, {STR0150, '03', "MATA360()"} ) //--"A condição de pagamento informada no cadastro do fornecedor não está cadastrada para esta filial. Cadastrar a condição de pagamento nesta filial."
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³T250GerDTY³ Autor ³ Patricia A. Salomao ³ Data ³23.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Contrato de Carreteiro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC01 - No. do Contrato                                     ³±±
±±³          ³ExpC02 - Codigo do Fornecedor                                ³±±
±±³          ³ExpC03 - Loja do Fornecedor                                  ³±±
±±³          ³ExpN04 - Valor do Premio do Carreteiro                       ³±±
±±³          ³ExpN05 - Valor do IR do Carreteiro                           ³±±
±±³          ³ExpN06 - Valor do INSS do Carreteiro                         ³±±
±±³          ³ExpN07 - Valor do SEST                                       ³±±
±±³          ³ExpC08 - Tipo do Contrato(1-Viagem;2-Periodo;3-Premio;4-Adto)³±±
±±³          ³ExpN09 - Quantidade de Ocorrencias                           ³±±
±±³          ³ExpN10 - Peso                                                ³±±
±±³          ³ExpN11 - Quantidade de Documentos                            ³±±
±±³          ³ExpN12 - No. de Diarias (Semana)                             ³±±
±±³          ³ExpN13 - Kms Rodados                                         ³±±
±±³          ³ExpN14 - Valor do Frete                                      ³±±
±±³          ³ExpN15 - Valor Total dos Adiantamentos                       ³±±
±±³          ³ExpC16 - No. do Documento gerado para o Custo de Transporte  ³±±
±±³          ³ExpN17 - Qtde. de Pernoites do Carreteiro                    ³±±
±±³          ³ExpN18 - Valor do Pedagio                                    ³±±
±±³          ³ExpC19 - Motorista                                           ³±±
±±³          ³ExpC20 - Filial de Origem da Viagem                          ³±±
±±³          ³ExpC21 - Numero da Viagem                                    ³±±
±±³          ³ExpC22 - Codigo do Favorecido                                ³±±
±±³          ³ExpC23 - Loja do Favorecido                                  ³±±
±±³          ³ExpC24 - Filial de Debito                                    ³±±
±±³          ³ExpN25 - Valor do ISS                                        ³±±
±±³          ³ExpN26 - No. de Diarias (Fim de Semana)                      ³±±
±±³          ³ExpN27 - Valor Retido do PIS                                 ³±±
±±³          ³ExpN28 - Valor Retido do COFINS                              ³±±
±±³          ³ExpN29 - Valor Retido do CSLL                                ³±±
±±³          ³ExpC30 - Deduz Pedagio do Valor do Frete ? (1=Sim;2=Nao)     ³±±
±±³          ³ExpN31 - Valor Base para Calculo dos Impostos                ³±±
±±³          ³ExpN32 - Codigo do Veiculo                                   ³±±
±±³          ³ExpC33 - Tabela de Frete a pagar                             ³±±
±±³          ³ExpC34 - Tipo da Tabela de Frete a pagar                     ³±±
±±³          ³ExpC35 - Tabela de Carreteiro                                ³±±
±±³          ³ExpC36 - Gera Pedido de Compra? (1=SIM/2=NAO/3=MV_TMSGRPC)   ³±±
±±³          ³ExpC37 - Dados da Operadora                                  ³±±
±±³          ³ExpC38 - Tipo de Moeda (Contratos em Outra Moeda)            ³±±
±±³          ³ExpC39 - Tipo de Uso 1=Viagem;2=Carga                        ³±±
±±³          ³ExpC40 - Identificador de Viagem ou Carga                    ³±±
±±³          ³ExpC41 - Condicao de Pagamento                               ³±±
±±³          ³ExpC42 - Indica se exibe preview                             ³±±
±±³          ³ExpC43 - Percentual Maximo Custo                             ³±±
±±³          ³ExpC44 - Título de Frete gerado junto com a geração do CTC   ³±±
±±³          ³ExpC45 - Título de NDF gerado junto com a geração do CTC     ³±±
±±³          ³Expn46 - Valor do acréscimo realizado no Preview do Frete    ³±±
±±³          ³Expn47 - Valor do decréscimo realizado no Preview do Frete   ³±±
±±³          ³Expn48 - Valor do Reembolso informado para a viagem		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250/TMSA740                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T250GerDTY( 	cContrat	, cCodForn	, cLojForn	, nValPremio, nValIRRF	, nValINSS	, nValSEST	, cTipCont	, nQtdOco	, nPesOco	, nQtdDoc	, nDiaSem	,;
						nQtdKm		, nValFrete	, nTotValAdi, cDoc		, nQtdPer	, nValPDG	, cCodMot	, cFilOri	, cViagem	, cCodFav	, cLojFav	, cFilDeb	,;
						nValISS		, nDiaFimSem, nValRetPIS, nValRetCOF, nValRetCSL, cDedPDG	, nBasImp	, cCodVei	, cTabFre	, cTipTab	, cTabCar	, cGerPC	,;
						aDadOperad	, nMoeda	, cTipUso	, cIdent	, cCondPag	, lPreview	, nMaxCus	, cTitFrete	, cTitNDF	, nAcresc	, nDecresc	, cDocFil	,;
						cDocNum		, cDocSer	, nValSESTId, nValSenat	, nVlrReem	)

Local aArea    	 	:= GetArea()
Local aAreaDTQ 	 	:= DTQ->(GetArea())
Local aAreaDTR 	 	:= DTR->(GetArea())
Local aAreaSA2 	 	:= SA2->(GetArea())
Local lLibCTC  	 	:= SuperGetMV( 'MV_LIBCTC',, .F. )
Local lTMSOPdg   	:= SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local cNATCTC    	:= Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NATUREZ")
Local lIRRFCAR   	:= .F.
Local lGerTit    	:= GetMV('MV_GERTIT' ,,.T.) // Verifica se devera gerar ou nao contas a pagar (SE2)
Local cCodBan    	:= ""
Local nTxAdBan   	:= 0
Local nCntFor1   	:= 0
Local nCntFor2   	:= 0
Local nVlAcre    	:= 0
Local nVlDecr    	:= 0
Local cTipAeD    	:= ""
Local lTpFrota   	:= DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local aRet		   	:= {}
Local aCabDTY		:= {}
Local aItemDES		:= {}
Local aItens		:= {}
Local cStatusDTY	:= "1"
Local oModel		:= Nil
Local oAux			:= Nil
Local lRet			:= .T.
Local cCodAeD		:= ""
Local cIdOpe        := ""
Local nQtdSaq       := 0
Local nQtdTra       := 0
Local lDTRQtdSaq    := DTR->(ColumnPos("DTR_QTDSAQ")) > 0

Private cFilDocto   := ""
Private cNumDocto   := ""
Private cSerDocto   := ""

If Type('cCadastro') == 'U'
	Private cCadastro	:= STR0001 //"Contrato de Carreteiro"
EndIf

Default cContrat	:= ""
Default cCodForn	:= ""
Default cLojForn	:= ""
Default nValPremio	:= 0
Default nValIRRF	:= 0
Default nValINSS	:= 0
Default nValSEST	:= 0
Default nValSESTId  := 0 //-Valor do SEST Separado do SENAT - Campo só será gravado quando o TMS estiver integrado com o ERP Datasul.
Default nValSenat   := 0 //--Valor do SENAT separado do SEST- Campo só será gravado quando o TMS estiver integrado com o ERP Datasul.
Default cTipCont	:= ""
Default nQtdOco		:= 0
Default nPesOco		:= 0
Default nQtdDoc		:= 0
Default nDiaSem		:= 0
Default nQtdKm		:= 0
Default nValFrete	:= 0
Default nTotValAdi	:= 0
Default	cDoc		:= ""
Default nQtdPer		:= 0
Default nValPDG		:= 0
Default cCodMot		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodFav		:= ""
Default cLojFav		:= ""
Default cFilDeb		:= ""
Default nValISS    	:= 0
Default nDiaFimSem	:= 0
Default nValRetPIS 	:= 0
Default nValRetCOF 	:= 0
Default nValRetCSL 	:= 0
Default cDedPDG    	:= "2"
Default nBasImp    	:= 0
Default cTabFre    	:= ""
Default cTipTab    	:= ""
Default cTabCar    	:= ""
Default cGerPC     	:= IIF(GetMV('MV_TMSGRPC',,.F.), '1', '2')
Default aDadOperad 	:= {}
Default nMoeda     	:= 1
Default cTipUso    	:= IIf(!lTabDFI .Or. nModulo==43,"1","2")
Default cCodVei    	:= Iif(cTipUso=='1',DTR->DTR_CODVEI,DAK->DAK_CAMINH)
Default cIdent     	:= ""
Default cCondPag   	:= ""
Default lPreview   	:= .F.
Default nMaxCus    	:= 0
Default cTitFrete	:= "2"
Default cTitNDF		:= "2"
Default nAcresc		:= 0
Default nDecresc	:= 0
Default cDocFil     := ""
Default cDocNum     := ""
Default cDocSer     := ""
Default nVlrReem	:= 0

 //-- Usado para levar o numero do documento para a gravação do SDG campos DG_FILFRT, DG_DOCFRT e DG_SERFRT
 cFilDocto   := cDocFil
 cNumDocto   := cDocNum
 cSerDocto   := cDocSer

If !lLibCTC .And. lExceCst
	lLibCTC := .T.
EndIf

IIf(Empty(cTitFrete),cTitFrete := '2',)
IIf(Empty(cTitNDF),cTitNDF := '2',)
cNATCTC  := IIf( Empty(cNATCTC) , TMSA250Var("NAT") , cNATCTC )
lIRRFCAR := Posicione("SED",1,xFilial("SED")+cNATCTC,"ED_IRRFCAR") == "S"

//-- Gerar Contrato de Carreteiro
If !lGerTit
	If lIRRFCAR
		aRet := Tm250IrCar(cCodForn,cLojForn,nBasImp,nValFrete,cCondPag)
		nValIRRF := aRet[1][1]
		nValINSS := aRet[1][2]
	Else
		nValIRRF := 0
		nValINSS := 0
	EndIf
EndIf

If !Empty(cContrat)
	Aadd( aCabDTY, {"DTY_NUMCTC", cContrat 			, Nil } )
Else
	Aadd( aCabDTY, {"DTY_NUMCTC", GetSX8Num("DTY","DTY_NUMCTC") , Nil } )
EndIf

Aadd( aCabDTY, {"DTY_FILORI", cFilOri 			, Nil } )

If cTipUso == "2" //--OMS com Frete Embarcador
	Aadd( aCabDTY, {"DTY_TIPUSO", cTipUso 			, Nil } )
	Aadd( aCabDTY, {"DTY_IDENT"	, cIdent 			, Nil } )
ElseIf cTipUso == "1" //--TMS
	Aadd( aCabDTY, {"DTY_VIAGEM", cViagem 			, Nil } )
EndIf

Aadd( aCabDTY, {"DTY_DATCTC", dDataBase			, Nil } )
Aadd( aCabDTY, {"DTY_HORCTC", StrTran(Left(Time(),5),':','')	, Nil } )
Aadd( aCabDTY, {"DTY_CODMOT", cCodMot 			, Nil } )
Aadd( aCabDTY, {"DTY_CODFOR", cCodForn 			, Nil } )
Aadd( aCabDTY, {"DTY_LOJFOR", cLojForn 			, Nil } )
Aadd( aCabDTY, {"DTY_VALPRE", nValPremio		, Nil } )
Aadd( aCabDTY, {"DTY_IRRF"	, nValIRRF 			, Nil } )
Aadd( aCabDTY, {"DTY_INSS"	, nValINSS 			, Nil } )
Aadd( aCabDTY, {"DTY_SEST"	, nValSEST 			, Nil } )

If cTmsErp == '1'
	If DTY->(ColumnPos('DTY_VLSEST')) > 0 .And. DTY->(ColumnPos('DTY_VLSENA')) > 0
		Aadd( aCabDTY, {"DTY_VLSEST"	, nValSESTId 			, Nil } )
		Aadd( aCabDTY, {"DTY_VLSENA"	, nValSenat 			, Nil } )
	EndIf
EndIf
Aadd( aCabDTY, {"DTY_TIPCTC", cTipCont 			, Nil } )
Aadd( aCabDTY, {"DTY_DOCSDG", cDoc	 			, Nil } )
Aadd( aCabDTY, {"DTY_CODVEI", cCodVei 			, Nil } )
Aadd( aCabDTY, {"DTY_QTDPER", nQtdPer 			, Nil } )
Aadd( aCabDTY, {"DTY_QTDDOC", nQtdDoc 			, Nil } )
Aadd( aCabDTY, {"DTY_QTDDIA", nDiaSem 			, Nil } )
Aadd( aCabDTY, {"DTY_QTDKM"	, nQtdKm 			, Nil } )
Aadd( aCabDTY, {"DTY_DIAFIM", nDiaFimSem		, Nil } )

If !Empty(cCodFav+cLojFav)
	Aadd( aCabDTY, {"DTY_CODFAV", cCodFav 			, Nil } )
	Aadd( aCabDTY, {"DTY_LOJFAV", cLojFav 			, Nil } )
EndIf

//-- Se nao for contrato de Premio
If cTipCont <> '3'
	Aadd( aCabDTY, {"DTY_VALFRE", nValFrete			, Nil } )
	Aadd( aCabDTY, {"DTY_VALPDG", nValPDG 			, Nil } )
	Aadd( aCabDTY, {"DTY_ADIFRE", nTotValAdi		, Nil } )
	Aadd( aCabDTY, {"DTY_QTDVOL", nQtdOco 			, Nil } )
	Aadd( aCabDTY, {"DTY_PESO"	, nPesOco 			, Nil } )
	Aadd( aCabDTY, {"DTY_VLREEM", nVlrReem 			, Nil } )
EndIf

//--Se a liberacao de contrato estiver ativa a filial de debito so sera preenchida na liberacao do contrato.
If lLibCTC .And. !(IsInCallStack("TMSA740"))
	Aadd( aCabDTY, {"DTY_FILDEB"	, ""			, Nil } )
Else
	Aadd( aCabDTY, {"DTY_FILDEB"	, cFilDeb		, Nil } )
EndIf

Aadd( aCabDTY, {"DTY_ISS"	, nValISS		, Nil } )
Aadd( aCabDTY, {"DTY_PIS"	, nValRetPIS	, Nil } )
Aadd( aCabDTY, {"DTY_COFINS", nValRetCOF	, Nil } )
Aadd( aCabDTY, {"DTY_CSLL"	, nValRetCSL	, Nil } )

If cTipCont <> '3'
	If cDedPDG == '1' //-- Deduz valor do pedagio no calculo dos impostos
		Aadd( aCabDTY, {"DTY_BASIMP"	, IIf(nBasImp > 0, nBasImp, nValFrete) - nValPDG	, Nil } ) //-- Base utilizada para calculo dos impostos
	Else
		Aadd( aCabDTY, {"DTY_BASIMP"	, IIf(nBasImp > 0, nBasImp, nValFrete)	, Nil } )
	EndIf
EndIf

If	DTY->(ColumnPos("DTY_TABCAR")) > 0
	Aadd( aCabDTY, {"DTY_TABCAR"	, cTabCar	, Nil } ) //-- Tabela de Carreteiro
EndIf
If	DTY->(ColumnPos("DTY_TABFRE")) > 0
	Aadd( aCabDTY, {"DTY_TABFRE"	, cTabFre	, Nil } ) //-- Tabela de Frete
EndIf
If	DTY->(ColumnPos("DTY_TIPTAB")) > 0
	Aadd( aCabDTY, {"DTY_TIPTAB"	, cTipTab	, Nil } ) //-- Tipo da Tabela de Frete
EndIf

If lTpFrota
	DA3->(dbSetOrder(1))
	If DA3->(MsSeek(xFilial('DA3')+cCodVei))
		Aadd( aCabDTY, {"DTY_TIPFRO", DA3->DA3_FROVEI	, Nil } )
	EndIf
	If nMaxCus > 0
		Aadd( aCabDTY, {"DTY_PERCUS", nMaxCus	, Nil } )
	EndIf
EndIf

If DTY->(ColumnPos('DTY_TITFRE')) > 0
	Aadd( aCabDTY, {"DTY_TITFRE", cTitFrete	, Nil } )
EndIf
If DTY->(ColumnPos('DTY_TITNDF')) > 0
	Aadd( aCabDTY, {"DTY_TITNDF", cTitNDF	, Nil } )
EndIf
If ((lLibCTC .And. !(IsInCallStack("TMSA740"))) .Or. lTMSOPdg) .And. cTipUso == "1" //--Viagem -- Se estiver integrado com o SIGAGPE sera desconsiderado o libctc.
     //-- Posiciona na Viagem
     DTQ->(DbSetOrder(2)) //--DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
     DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))

	//-- Posiciona na tabela de Complemento da viagem.
	DTR->(DbSetOrder(3))
	DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem + cCodVei ))

	//--Gravação do número do contrato na operadora de frete.
	If DTR->DTR_CODOPE == '01'//--REPOM
		Aadd( aCabDTY, {"DTY_IDOPE "	, DTR->DTR_PRCTRA	, Nil } )
	ElseIf DTR->DTR_CODOPE == '02'//--PAMCARD.
		Aadd( aCabDTY, {"DTY_IDOPE "	, DTQ->DTQ_IDOPE	, Nil } )
	EndIf

	If !lLibCTC
		Aadd( aCabDTY, {"DTY_CSLL"	, nValRetCSL	, Nil } )

		If DTQ->DTQ_STATUS == "3"
		    cStatusDTY := '3' //-- "Liberado para Pagamento"
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o Status do Contrato de Carreteiro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cGerPC == '1'
			cStatusDTY := '4' //-- Contrato Quitado com Ped. Compra
		Else
			If cTipCont == '2' //-- Contrato por Periodo. A viagem jah esta Encerrada!
				cStatusDTY := '2' //-- Aguardando Liberacao para Pagamento
			Else
				//-- Verifica se a Viagem jah foi encerrada.
				If	DTQ->DTQ_STATUS == '3' //-- Encerrada
					cStatusDTY := '2' //-- Aguardando Liberacao para Pagamento
				Else
					If cTipCont =='7' .Or. lExceCst //-- Redespacho ou Exceder o Percentual Maximo do Custo
						cStatusDTY := '2' //-- Aguardando Liberacao para Pagamento
					Else
						cStatusDTY := '1' //-- Em Aberto
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	Aadd( aCabDTY, {"DTY_STATUS"	, cStatusDTY	, Nil } )

	cIdOpe:= DUP->DUP_IDOPE
	nQtdSaq:= DUP->DUP_QTDSAQ
	nQtdTra:= DUP->DUP_QTDTRA

	If lDTRQtdSaq
		cIdOpe := TMSIDPAM(DTR->DTR_FILORI,DTR->DTR_VIAGEM,'2')  //Tipo Parcela do Pagamento da Viagem
		If DTR->DTR_QTDSAQ > 0 .And.  DTR->DTR_QTDTRA > 0  //Tratamento caso os campos criados recentemente estejam com conteudo vazio
			nQtdSaq:= DTR->DTR_QTDSAQ
			nQtdTra:= DTR->DTR_QTDTRA
		EndIf
	EndIf

	cCodBan		:= PamCodBan(DUP->DUP_CODMOT, AllTrim(cIdOpe), cFilori, cViagem)
	nTxAdBan	:= PamTaxTot(cCodBan, nQtdSaq, nQtdTra )

	If DTR->DTR_CODOPE = '02'
		If DTY->(ColumnPos('DTY_TAXBAN')>0)
			Aadd( aCabDTY, {"DTY_TAXBAN"	, nTxAdBan	, Nil } )
		EndIf
	EndIf

	Aadd( aCabDTY, {"DTY_CODOPE"	, RTrim( DTR->DTR_CODOPE )	, Nil } )


EndIf

Aadd( aCabDTY, {"DTY_VLACRE"	, nAcresc		, Nil } )
Aadd( aCabDTY, {"DTY_VLDECR"	, nDecresc		, Nil } )


aCabDTY		:= FwVetByDic( aCabDTY , "DTY" )

//-------------------------------------------------------------
// Realiza inclusão automática no Modelo de Dados
//-------------------------------------------------------------
If lRet := TMSMdlAuto( aCabDTY , Iif( Len(aItemDES) > 0 , aItemDES, Nil) , MODEL_OPERATION_INSERT , "TMSA250" , "MdFieldDTY" ,/* "MdGridDES" */, "DTY" , /*"DES"*/ , .T. , cCadastro )

	//-- PE utilizado para complementar a gravacao da tabela DTY
	If lTM250Gr1
		ExecBlock("TM250Gr1",.F.,.F.,{aHeaderAeD,aColsAeD})
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDTQ)
RestArea(aAreaDTR)
RestArea(aAreaSA2)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250SC7³ Autor ³ Patricia A. Salomao   ³ Data ³ 17/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Pedido de Compra                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1-Cod. do Fornecedor                                    ³±±
±±³          ³ExpC2-Loja do Fornecedor                                    ³±±
±±³          ³ExpC3-Contato do Fornecedor                                 ³±±
±±³          ³ExpC4-Filial de Debito do Fornecedor                        ³±±
±±³          ³ExpC5-Cond. de Pagamento do Fornecedor                      ³±±
±±³          ³ExpC6-Numero do Contrato                                    ³±±
±±³          ³ExpA1-Vetor para adicionar mensagens de erro                ³±±
±±³          ³ExpA2-Vetor contendo todas as mensagens de erro             ³±±
±±³          ³ExpC7-Valor Total do Frete de todas as viagens do Fornecedor³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA250SC7(cCodForn,cLojForn,cContato,cFilDeb,cCondPag,cNumCTC,aMsgErr,aVisErr,nValFrete)

Local aCab    := {}
Local aItem   := {}
Local aArea   := GetArea()
Local cCodPro := '' //--Pessoa Fisica(MV_PRDCTF),Juridica(MV_PRDCTC).
Local cSeek   := ''
Local cNumPC  := ''
Local nQuant  := 1
Local cTXTLG250 := ""
Local lSucesso := .F.

Private lMsErroAuto := .F.
SaveInter()

SA2->(DbSetOrder(1))
If SA2->(MsSeek(xFilial('SA2')+cCodForn+cLojForn))
	If SA2->A2_TIPO == 'F'
		cCodPro := GetMV('MV_PRDCTF',,'') //--Parametro (Produto utilizado para gerar pedido de compras e contrato de carreteiro pessoa fisica)
	Else
		cCodPro := GetMV('MV_PRDCTC',,'') //--Parametro (Produto utilizado para gerar pedido de compras e contrato de carreteiro pessoa Juridica).
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
	If !lExcSched250
		Help("",1,"TMSA25012",," SIGACUS.PRW",1,28) //"Atualizar patch do programa SIGACUS.PRW"
	Else
		cTXTLG250 	:= STR0196 //--> "Atualizar patch do programa SIGACUS.PRW"
		AADMsgTMS250(cTXTLG250,"TMSA250")
	EndIf
	Return .F.
EndIf
If !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
	If !lExcSched250
		Help("",1,"TMSA25012",," SIGACUSA.PRX",1,28) //"Atualizar patch do programa SIGACUSA.PRX"
	Else
		cTXTLG250 	:= STR0197 //-->  "Atualizar patch do programa SIGACUSA.PRX"
		AADMsgTMS250(cTXTLG250,"TMSA250")
	EndIf
	Return .F.
EndIf
If !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
	If !lExcSched250
		Help("",1,"TMSA25012",," SIGACUSB.PRX",1,28) //"Atualizar patch do programa SIGACUSB.PRX"
	Else
		cTXTLG250 	:= STR0198 //--> "Atualizar patch do programa SIGACUSB.PRX"
		AADMsgTMS250(cTXTLG250,"TMSA250")
	EndIf
	Return .F.
EndIf
SB1->(DbSetOrder(1))
If SB1->(MsSeek(xFilial('SB1')+cCodPro)).And. !IsProdMod(SB1->B1_COD) .And.;
	(SB1->B1_TIPO != "BN" .Or. (SB1->B1_TIPO == "BN" .And. MatBuyBN())) //-- Nao gera para mao de obra e tipo = "BN" (Beneficiamento)

	cNumPC := Criavar("C7_NUM",.T.)
	aCab:={{"C7_NUM"   ,cNumPC			,NIL},;  // Numero do Pedido
	{"C7_EMISSAO",dDataBase		,NIL},;  // Data de Emissao
	{"C7_FORNECE",cCodForn		,NIL},;  // Fornecedor
	{"C7_LOJA"   ,cLojForn		,NIL},;  // Loja do Fornecedor
	{"C7_CONTATO",cContato		,NIL},;  // Contato
	{"C7_COND"   ,cCondPag		,NIL},;  // Condicao de Pagamento
	{"C7_TIPO"   ,1				,NIL},;  // Pedido de Compra
	{"C7_FILENT" ,cFilDeb		,NIL}}   // Filial de Entrega

	aItem:={{"C7_ITEM"  ,StrZero(1,Len(SC7->C7_ITEM))			,NIL},; // Item
	{"C7_PRODUTO",cCodPro								,NIL},; // Produto
	{"C7_QUANT"  ,nQuant								,NIL},; // Quantidade
	{"C7_UM"     ,SB1->B1_UM							,NIL},; // Unidade de Medida Produto
	{"C7_PRECO"  ,nValFrete								,NIL},; // Valor do Frete (Unitario)
	{"C7_TOTAL"  ,nValFrete								,NIL},; // Valor do Frete (Total)
	{"C7_DATPRF" ,dDataBase								,NIL},; // DataBase
	{"C7_LOCAL"  ,RetFldProd(SB1->B1_COD,"B1_LOCPAD")	,NIL},; // Almoxarifado
	{"C7_TPFRETE","C"									,NIL},; // Tipo do Frete
	{"C7_ORIGEM", "SIGATMS"								,Nil} } // Origem

	MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCab,{aItem},3,.F.)

	//-- Mostra Erro na geracao de Rotinas automaticas
	If lMsErroAuto
		MostraErro()
        AAdd( aMsgErr, { STR0016 + cNumCTC + '.', '01', "" } ) //"Nao foi gerado Pedido de Compra para o Contrato No. : " ### "Informe um Produto no Parâmetro MV_PRDCTC / MV_PRDCTF " //-- Carrega o Array com as mensagens de Erro
        //-- Carrega o Array com as mensagens de Erro
        AaddMsgErr( aMsgErr, aVisErr )
	Else
        lSucesso := .T.
        //-- Grava no Contrato de Carreteiro, o numero do Pedido de Compra gerado
		DTY->(dbSetOrder(4))
		If DTY->(MsSeek(cSeek:=xFilial('DTY')+cFilAnt+cNumCTC))
			//-- Atualiza o no. do pedido de compra em todos os contratos de carreteiro com mesmo no.
			Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_NUMCTC) == cSeek
				RecLock('DTY',.F.)
				DTY->DTY_NUMPC := cNumPC
				MsUnLock()
				DTY->(dbSkip())
			EndDo
		EndIf
	EndIf
Else
	AAdd( aMsgErr, { STR0016 + cNumCTC + '. ' + STR0015 , '01', "" } ) //"Nao foi gerado Pedido de Compra para o Contrato No. : " ### "Informe um Produto no Parâmetro MV_PRDCTC / MV_PRDCTF " //-- Carrega o Array com as mensagens de Erro
	//-- Carrega o Array com as mensagens de Erro
	AaddMsgErr( aMsgErr, aVisErr )
EndIf

//-- Restaura area original
RestArea(aArea)
RestInter()

Return lSucesso
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250VerCal³ Autor ³ Eduardo de Souza    ³ Data ³ 09/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a geracao do contrato por periodo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array (Retorna os proprietarios com problema na geracao.)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250 - So TMS no primeiro momento                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA250VerCal(nOpcx, cFilAtu)
Local cQuery     	:= ""
Local cAliasTRB  	:= GetNextAlias()
Local aPropriet  	:= {}
Local aMsgErr    	:= {}
Local aVisErr    	:= {}
Local lGerAdtPro 	:= GetMV('MV_ADTPRO',,.F.)  // Gera Adiantamento para Motorista Proprio ?
Local cFilDeb    	:= ""
Local cTipDeb    	:= ""
Local cNatuCTC   	:= ""
Local cCodForn   	:= ""
Local cLojForn   	:= ""
Local nValFrete  	:= 0
Local aCampos    	:= {}
Local aAreaDTY   	:= DTY->(GetArea())
Local aAreaDTQ   	:= DTQ->(GetArea())
Local lEmptyTptCTC 	:= Empty(GetMV('MV_TPTCTC' ,,''))	// Verifica se o parametro de Tipo do Contrato de Carreteiro esta vazio
Local _nY        	:= 0
Local cTipCTC    	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )
Default nOpcx   := 0
Default cFilAtu := cFilAnt
//
//-- Verifica se existem viagens sem complemento de viagem.
//
cQuery := " SELECT DTQ_FILORI, DTQ_VIAGEM "
cQuery += "   FROM " + RetSqlName("DTQ")
cQuery += "   WHERE DTQ_FILIAL = '" + xFilial("DTQ") + "' "
cQuery += "     AND DTQ_FILORI = '" + cFilAnt + "' "
If mv_par01 <> 4
	cQuery += "  AND DTQ_SERTMS = '" + StrZero(mv_par01,Len(DTQ->DTQ_SERTMS)) + "' "
EndIf
cQuery += "     AND DTQ_DATENC BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "' "
cQuery += "     AND DTQ_STATUS = '3' "
cQuery += "     AND D_E_L_E_T_ = ' ' "
cQuery += "     AND NOT EXISTS ( "
cQuery += "     	SELECT 1 "
cQuery += "     		FROM " + RetSqlName("DTR")
cQuery += "     		WHERE DTR_FILIAL = '" + xFilial("DTR") + "' "
cQuery += "     		  AND DTR_FILORI = DTQ_FILORI "
cQuery += "     		  AND DTR_VIAGEM = DTQ_VIAGEM "
cQuery += "     		  AND D_E_L_E_T_ = ' ' ) "
cQuery += " GROUP BY DTQ_FILORI, DTQ_VIAGEM "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
While (cAliasTRB)->(!Eof())
	If lTMA250Fil
		lContinua := ExecBlock('TMA250FIL',.F.,.F., {(cAliasTRB)->DTQ_FILORI, (cAliasTRB)->DTQ_VIAGEM, nOpcx} )
		If	ValType(lContinua) <> 'L'
			lContinua := .T.
		EndIf
		If !lContinua
			(cAliasTRB)->(dbSkip())
			Loop
		EndIf
	EndIf
	AAdd( aMsgErr, { STR0037 + (cAliasTRB)->DTQ_FILORI+'/'+(cAliasTRB)->DTQ_VIAGEM , '02', "TMSA240()" } ) //"Nao Existe Complemento de Viagem para a Viagem "
	(cAliasTRB)->(DbSkip())
EndDo
AaddMsgErr( aMsgErr, aVisErr )
(cAliasTRB)->(DbCloseArea())

//
//-- Validacao das viagens com complemento de viagem.
//
cAliasTRB := GetNextAlias()
cQuery := " SELECT "
cQuery += "   DTQ_FILORI, DTQ_VIAGEM, DTQ_SERTMS, DA3_CODFOR, "
cQuery += "   DA3_LOJFOR, DA3_FROVEI, DTR_CODVEI, DTR_ITEM  , "
cQuery += "   A2_NREDUZ , A2_COND   , A2_NATUREZ            , "
cQuery += "   DTR_CODFOR, DTR_LOJFOR "
cQuery += "   FROM " + RetSqlName("DTQ") + " DTQ "
cQuery += "   JOIN " + RetSqlName("DTR") + " DTR "
cQuery += "     ON  DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
cQuery += "     AND DTR.DTR_FILORI = DTQ.DTQ_FILORI "
cQuery += "     AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM "
cQuery += "   LEFT JOIN " + RetSqlName("DA3") + " DA3 "
cQuery += "     ON  DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += "     AND DA3.DA3_COD    = DTR.DTR_CODVEI "
cQuery += "     AND DTR.DTR_CODFOR BETWEEN '" + mv_par04 + "' AND '" + mv_par06 + "' "
cQuery += "     AND DTR.DTR_LOJFOR BETWEEN '" + mv_par05 + "' AND '" + mv_par07 + "' "
cQuery += "     AND DA3.D_E_L_E_T_ = ' ' "
cQuery += "   LEFT JOIN " + RetSqlName("SA2") + " SA2 "
cQuery += "     ON  SA2.A2_FILIAL  = '" + xFilial("SA2") + "' "
cQuery += "     AND SA2.A2_COD     = DTR.DTR_CODFOR "
cQuery += "     AND SA2.A2_LOJA    = DTR.DTR_LOJFOR "
cQuery += "     AND SA2.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
cQuery += "     AND DTQ.DTQ_FILORI = '" + cFilAnt + "' "
If mv_par01 <> 4
	cQuery += "  AND DTQ.DTQ_SERTMS = '" + StrZero(mv_par01,Len(DTQ->DTQ_SERTMS)) + "' "
EndIf
cQuery += "     AND DTQ.DTQ_DATENC BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "' "
cQuery += "     AND DTQ.DTQ_STATUS = '" + StrZero(3,Len(DTQ->DTQ_STATUS)) + "' "
cQuery += "     AND DTQ.D_E_L_E_T_ = ' ' "
cQuery += "     AND DTR.D_E_L_E_T_ = ' ' "
cQuery += "     AND NOT EXISTS ( "
cQuery += "     SELECT 1 FROM " + RetSqlName("DTY") + " DTY "
cQuery += "     	WHERE DTY.DTY_FILIAL = '" + xFilial("DTY") + "' "
cQuery += "     		AND DTY.DTY_FILORI = DTQ.DTQ_FILORI "
cQuery += "     		AND DTY.DTY_VIAGEM = DTQ.DTQ_VIAGEM "
cQuery += "     		AND DTY.D_E_L_E_T_ = ' ' ) "
cQuery += " ORDER BY DTR_CODFOR, DTR_LOJFOR, DTQ_FILORI, DTQ_VIAGEM "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)

(cAliasTRB)->(DbGotop())
While (cAliasTRB)->(!Eof())
	If lTMA250Fil
		lContinua := ExecBlock('TMA250FIL',.F.,.F., {(cAliasTRB)->DTQ_FILORI, (cAliasTRB)->DTQ_VIAGEM, nOpcx} )
		If	ValType(lContinua) <> 'L'
			lContinua := .T.
		EndIf
		If !lContinua
			(cAliasTRB)->(dbSkip())
			Loop
		EndIf
	EndIf
	If !Empty((cAliasTRB)->DTR_CODFOR) .And. !Empty((cAliasTRB)->DTR_LOJFOR)
		cCodForn := (cAliasTRB)->DTR_CODFOR
		cLojForn := (cAliasTRB)->DTR_LOJFOR
	Else
		cCodForn := (cAliasTRB)->DA3_CODFOR
		cLojForn := (cAliasTRB)->DA3_CODFOR
	EndIf

	aMsgErr   := {}
	nValFrete := 0

	If (cAliasTRB)->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte
		TMSChkViag( (cAliasTRB)->DTQ_FILORI, (cAliasTRB)->DTQ_VIAGEM, .F. , .T., .F. , .F. , .F., , , .F., .F., @aMsgErr, .F., .F., , , , , cFilAtu)
	EndIf

	//-- Valida se foi informado motorista para o complemento da viagem.
	If !DUP->(MsSeek(xFilial("DUP")+(cAliasTRB)->DTQ_FILORI+(cAliasTRB)->DTQ_VIAGEM+(cAliasTRB)->DTR_ITEM))
		If Ascan( aPropriet, { |x| x[1]+x[2]+x[3] == cCodForn+cLojForn+"1" }) == 0
			Aadd( aPropriet, { cCodForn,cLojForn, "1", "" })
			AAdd( aMsgErr, { STR0028 + (cAliasTRB)->DTQ_FILORI + '/' +(cAliasTRB)->DTQ_VIAGEM + STR0025 +(cAliasTRB)->DTR_CODVEI + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim((cAliasTRB)->A2_NREDUZ)+ ' )' , '01', "TMSA240()" } ) //"Nao foi Informado motorista para a Viagem " ### "Veiculo" ### "Proprietario"
		EndIf
	EndIf

	//-- Verifica o calculo do frete para Terceiro ou Agregado.
	If (cAliasTRB)->DA3_FROVEI == StrZero(2,Len(DA3->DA3_FROVEI)) .Or. (cAliasTRB)->DA3_FROVEI == StrZero(3,Len(DA3->DA3_FROVEI))

		//-- Verifica se o proprietario do veiculo esta preenchido.
		If Empty(cCodForn) .Or. Empty(cLojForn)
			AAdd( aMsgErr, { STR0031 +  (cAliasTRB)->DTQ_FILORI + '/' +(cAliasTRB)->DTQ_VIAGEM + ', ' + STR0032 + (cAliasTRB)->DTR_CODVEI , '02', "OMSA060()" } ) //"Não foi Informado motorista para a Viagem " ### "Não foi Informado motorista para a Viagem "
			AaddMsgErr( aMsgErr, aVisErr )
			(cAliasTRB)->(dbSkip())
			Loop
		EndIf

		//-- Condicao de Pagamento do Proprietario do Veiculo
		If Empty((cAliasTRB)->A2_COND)
			If Ascan( aPropriet, { |x| x[1]+x[2]+x[3] == cCodForn+cLojForn+"3" }) == 0
				Aadd( aPropriet, { cCodForn, cLojForn, "3", "" })
				AAdd( aMsgErr, { STR0033 + cCodForn + "/" + cLojForn + ' - ' + AllTrim((cAliasTRB)->A2_NREDUZ), '03', "MATA020()" } ) //"Cadastrar Condicao de Pagto. no Cadastro de Fornecedor "
			EndIf
		Else
			SE4->(DbSetOrder(1))
			If !SE4->(DbSeek(xFilial('SE4')+(cAliasTRB)->A2_COND))
				AAdd( aMsgErr, {STR0150, '03', "MATA360()"} ) //--"A condição de pagamento informada no cadastro do fornecedor não está cadastrada para esta filial. Cadastrar a condição de pagamento nesta filial."
				lRet := .F.
				Exit
			EndIf
		EndIf

		//-- Verifica a Filial de Debito (posiciona no arquivo SA2)
		If lEmptyTptCTC
			cFilDeb := TMSA250FilDeb(cCodForn,cLojForn)
			cTipDeb := Padr( "C"+cFilDeb, Len( SE2->E2_TIPO ) )
			If Tabela("05",cTipDeb,.F.)
				If Ascan( aPropriet, { |x| x[1]+x[2]+x[3] == cCodForn+cLojForn+"4" }) == 0
					Aadd( aPropriet, { cCodForn, cLojForn, "4", "" })
					AAdd( aMsgErr, { STR0029 +  cFilDeb + '. ' + STR0030 + cFilDeb + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim((cAliasTRB)->A2_NREDUZ)+' )', '01', "" } ) //"Não encontrou na Tabela '05', o tipo do Título que será utilizado para a Filial de Debito : " ### "Tipo do Título a ser cadastrado : C" ### "Proprietario"
				EndIf
			EndIf
		Else
			cTipDeb := cTipCTC
		EndIf

		//-- Natureza Contrato de Carreteiro
		If !Empty((cAliasTRB)->A2_NATUREZ)
			cNatuCTC := (cAliasTRB)->A2_NATUREZ
		Else
			If lTM250Par
				cNatuCTC := ExecBlock('TM250PAR',.F.,.F.,{1})
				If ValType(cNatuCTC) <> 'C'
					cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
				EndIf
			Else
				cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
			EndIf
		EndIf

		If Empty(cNatuCTC)
			If Ascan( aPropriet, { |x| x[1]+x[2]+x[3] == cCodForn+cLojForn+"5" }) == 0
				Aadd( aPropriet, { cCodForn, cLojForn, "5", "" })
				AAdd( aMsgErr, { STR0014 + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim((cAliasTRB)->A2_NREDUZ)+ ' )', '01', "" } ) //"Natureza do Contrato de Carreteiro Nao encontrada" ### "Proprietario"
			EndIf
		Else
			SED->(dbSetOrder(1))
			If !SED->(MsSeek(xFilial('SED')+cNatuCTC) )
				Aadd( aPropriet, { cCodForn, cLojForn, "5", "" })
				AAdd( aMsgErr, { STR0014 + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim((cAliasTRB)->A2_NREDUZ)+ ' )', '01', "" } ) //"Natureza do Contrato de Carreteiro Nao encontrada" ### "Proprietario"
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura do Array aRet                              ³
		//³ [1] - Tabela de Frete a Pagar                        ³
		//³ [2] - Tipo da Tabela de Frete                        ³
		//³ [3] - Valor do Frete                                 ³
		//³ [4] - Qtd. de Volumes informada no Reg. de Ocorrencia³
		//³ [5] - Peso informado no Reg. de Ocorrencia           ³
		//³ [6] - Qtd. de Documentos                             ³
		//³ [7] - No. de Diarias (Semana)                        ³
		//³ [8] - Kms Percorridos                                ³
		//³ [9] - No. de Diarias (Fim de Semana)                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := TMSCalFrePag( (cAliasTRB)->DTQ_FILORI, (cAliasTRB)->DTQ_VIAGEM, (cAliasTRB)->DTR_CODVEI, aMsgErr, .T.)
		If Len(aRet) > 0
			nValFrete := aRet[1][3] //-- Valor do Frete a Pagar
		EndIf
		If Empty(nValFrete)
			If Ascan( aPropriet, { |x| x[1]+x[2]+x[3]+x[4] == cCodForn+cLojForn+"6"+(cAliasTRB)->DTR_CODVEI }) == 0
				Aadd( aPropriet, { cCodForn, cLojForn, "6", (cAliasTRB)->DTR_CODVEI })
				AAdd( aMsgErr, { STR0034 +(cAliasTRB)->DTQ_FILORI + '-' +(cAliasTRB)->DTQ_VIAGEM + ' /' + STR0025 + ':' + (cAliasTRB)->DTR_CODVEI + ' , ' + STR0035 + ' - ( ' + STR0026 + cCodForn + "/" + cLojForn + ' - ' + AllTrim((cAliasTRB)->A2_NREDUZ)+' )', '02', "TMSA240()" } ) //"O Valor do Frete da Viagem " ### "  Veiculo " ### "esta Zerado" ### "Proprietario"
			EndIf
		EndIf
	EndIf
	//-- Armazena as mensagens
	AaddMsgErr( aMsgErr, aVisErr )
	(cAliasTRB)->(DbSkip())
EndDo
(cAliasTRB)->(DbCloseArea())

//-- Apresentam as mensagens encontradas.
If !Empty(aVisErr)
	If lExcSched250	//--> Se execução não for via SCHEDULE apresenta tela de com erros, caso seja SCHEDULE gera log.
		For _nY := 1 To Len(aVisErr)
			AADD(aMsgErPa, {aVisErr[_nY,1],aVisErr[_nY,2],aVisErr[_nY,3]})
		Next
	Else
		TmsMsgErr( aVisErr )
	EndIf
EndIf


RestArea( aAreaDTQ )
RestArea( aAreaDTY )
Return( aPropriet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA250Pvw ³ Autor ³ Valdemar Roberto   ³ Data ³25.05.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preview do frete a pagar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do Fornecedor                              ³±±
±±³			 ³ cExp02 - Loja do Fornecedor                                ³±±
±±³			 ³ cExp03 - Tipo de Uso (1=TMS / 2= OMS)                      ³±±
±±³			 ³ cExp04 - Tipo de Contrato                                  ³±±
±±³			 ³ cExp05 - Codigo do Motorista                               ³±±
±±³			 ³ cExp06 - Filial de Origem                                  ³±±
±±³			 ³ cExp07 - Viagem                                            ³±±
±±³			 ³ cExp08 - Indica se Deduz Pedagio do Frete (1=Sim / 2=Nao)  ³±±
±±³			 ³ cExp09 - Codigo do Veiculo                                 ³±±
±±³			 ³ cExp10 - Tabela de Frete                                   ³±±
±±³			 ³ cExp11 - Tipo da Tabela de Frete                           ³±±
±±³			 ³ cExp12 - Tabela de Carreteiro                              ³±±
±±³			 ³ aExp01 - Vetor com a Composição do Frete                   ³±±
±±³			 ³ lExp01 - Indica se Veio de Rotina de Contrato de Premio    ³±±
±±³			 ³ cExp13 - Gera Pedido de Compra ? (1=Sim/2=Nao/3=MV_TMSGRPC)³±±
±±³			 ³ lExp02 - Indica se Existe a Tabela DFI                     ³±±
±±³			 ³ cExp14 - Indica se deduz pedagio do frete (1=Sim / 2=Nao)  ³±±
±±³			 ³ nExp01 - Valor do Frete                                    ³±±
±±³			 ³ nExp02 - Valor do Adiantamento                             ³±±
±±³			 ³ nExp03 - Valor do Pedagio                                  ³±±
±±³			 ³ nExp04 - Valor da Base de Impostos                         ³±±
±±³			 ³ nExp05 - Valor do IRRF                                     ³±±
±±³			 ³ nExp06 - Valor do INSS                                     ³±±
±±³			 ³ nExp07 - Valor do SEST                                     ³±±
±±³			 ³ nExp08 - Valor do ISS                                      ³±±
±±³			 ³ nExp09 - Valor do PIS                                      ³±±
±±³			 ³ nExp10 - Valor do COFINS                                   ³±±
±±³			 ³ nExp11 - Percencual máximo de custo da viagem              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Opcao selecionada                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function TMSA250Pvw(cCodForn, cLojForn	, cTipCont	, cCodMot	, cFilOri	, cViagem	, cDedPDG	, cCodVei	, cTabFre,;
					cTipTab	, cTabCar	, aRetFrt	, lCtrPremio, cGerPC	, nValFrete	, nTotValAdi, nValPDG	, nBasImp,;
					nValIRRF, nValINSS	, nValSEST	, nValISS	, nValRetPIS, nValRetCOF, nMaxCus	, lTela		,cNumCTC ,;
					nAcresc	, nDecresc	, cNatuCTC	, cCodOpe	, nValSestId, nValSenat , nVlrReem)

Local aAreas := {DTQ->(GetArea()),DTR->(GetArea()),SA2->(GetArea()),DA3->(GetArea()),GetArea()}
Local aAlter   := {}
Local aButtons := {}
Local aSetKey  := {}
Local aTemp    := {}
Local aCampos  := {"DTY_FILORI","DTY_VIAGEM","DTY_DATCTC","DTY_HORCTC","DTY_VALFRE","DTY_VALPDG","DTY_ADIFRE","DTY_VLREEM","DTY_BASIMP", ;
				   "DTY_IRRF"  ,"DTY_INSS" 	,"DTY_SEST"  ,"DTY_ISS"   ,"DTY_PIS"   ,"DTY_COFINS","DTY_CODFOR","DTY_LOJFOR","DTY_NOMFOR",;
				   "DTY_CODMOT","DTY_NOMMOT","DTY_CODVEI","DTY_TABCAR","DTY_TABFRE","DTY_TIPTAB"}
Local nOpca    := 0
Local lRet     := .T.
Local oEncPvw
Local oDlgPvw
Local nCount       := 0
Local lCont        := .T.

DEFAULT cCodForn   := ""
DEFAULT cLojForn   := ""
DEFAULT cTipCont   := ""
DEFAULT cCodMot    := ""
DEFAULT cFilOri    := ""
DEFAULT cViagem    := ""
DEFAULT nValIRRF   := 0
DEFAULT nValINSS   := 0
DEFAULT nValSEST   := 0
DEFAULT nValFrete  := 0
DEFAULT nTotValAdi := 0

DEFAULT nValISS    := 0
DEFAULT nValRetPIS := 0
DEFAULT nValRetCOF := 0
DEFAULT cDedPDG    := "2"
DEFAULT nBasImp    := 0
DEFAULT cCodVei    := DTR->DTR_CODVEI
DEFAULT cTabFre    := ""
DEFAULT cTipTab    := ""
DEFAULT cTabCar    := ""
DEFAULT aRetFrt    := {}
DEFAULT lCtrPremio := .F.
DEFAULT cGerPC     := "2"
DEFAULT nValPDG    := 0
DEFAULT nValISS    := 0
DEFAULT nValRetPIS := 0
DEFAULT nValRetCOF := 0
DEFAULT nMaxCus    := 0
DEFAULT lTela	   := .T.
DEFAULT cNumCTC	   := ""
DEFAULT nAcresc	   := 0
DEFAULT nDecresc   := 0
DEFAULT cNatuCTC   := ""
DEFAULT cCodOpe	   := ""
DEFAULT nValSestId := 0
DEFAULT nValSenat  := 0
DEFAULT nVlrReem   := 0

//-- PE utilizado para acrescentar campos que devem apresentados no preview
If lTM250PCp
	aTemp := ExecBlock("TM250PCp",.F.,.F.,{Aclone(aCampos)})
	If ValType(aTemp) == "A"
		For nCount := 1 To Len(aTemp)
			If Ascan(aCampos, {|x| x == AllTrim(aTemp[nCount])}) == 0 .And. DTY->(ColumnPos(aTemp[nCount]))
				Aadd(aCampos, aTemp[nCount])
			EndIf
		Next nCount
	Endif
EndIf

//-- Inicializa variaveis
For nCount := 1 To Len(aCampos)
    M->&(aCampos[nCount]) := CriaVar(aCampos[nCount])
Next nCntFor1

//-- PE utilizado para acrescentar campos que podem ser editados no preview
If lTM250PEd
	aTemp := ExecBlock('TM250PEd',.F.,.F.,{Aclone(aAlter)})
	If ValType(aTemp) == "A"
		For nCount := 1 To Len(aTemp)
			If Ascan(aCampos,{|x| x == AllTrim(aTemp[nCount])}) > 0
				Aadd(aAlter,aTemp[nCount])
			EndIf
		Next nCount
	Endif
EndIf

M->DTY_FILORI := cFilOri
M->DTY_DATCTC := dDataBase
M->DTY_HORCTC := StrTran(Left(Time(),5),':','')
M->DTY_IRRF   := nValIRRF
M->DTY_INSS   := nValINSS
M->DTY_SEST   := nValSEST
M->DTY_ISS    := nValISS
M->DTY_PIS    := nValRetPIS
M->DTY_COFINS := nValRetCOF
M->DTY_CODFOR := cCodForn
M->DTY_LOJFOR := cLojForn
M->DTY_NOMFOR := Posicione("SA2",1,xFilial("SA2") + M->DTY_CODFOR + M->DTY_LOJFOR,"A2_NOME")
M->DTY_VIAGEM := DTQ->DTQ_VIAGEM
M->DTY_CODMOT := cCodMot
M->DTY_NOMMOT := Posicione("DA4",1,xFilial("DA4") + M->DTY_CODMOT,"DA4_NOME")
M->DTY_CODVEI := cCodVei
M->DTY_TABCAR := cTabCar
M->DTY_TABFRE := cTabFre
M->DTY_TIPTAB := cTipTab
If DTY->(ColumnPos('DTY_VLSEST'))> 0 .And. DTY->(ColumnPos('DTY_VLSENA')) > 0
	M->DTY_VLSEST := nValSestId
	M->DTY_VLSENA := nValSenat
EndIf
If DTY->(ColumnPos('DTY_VLREEM')) > 0
	M->DTY_VLREEM := nVlrReem
EndIf
//-- Se nao for contrato de Premio
If cTipCont <> "3"
	M->DTY_VALFRE := nValFrete
	M->DTY_VALPDG := nValPDG
	M->DTY_ADIFRE := nTotValAdi
	M->DTY_BASIMP := nBasImp
EndIf

M->DTY_VLACR	:= nAcresc
M->DTY_VLDECR	:= nDecresc
aButtons := {}
Aadd(aSetKey,{VK_F4,{|| TmsA250Frt("1",,,,aRetFrt,,,1)}})
Aadd(aButtons,{"BUDGET",{|| TmsA250Frt("1",,,,aRetFrt,,,1)},STR0044,STR0045}) //-- "Composicao do Frete - <F4>"

Aadd(aSetKey,{VK_F5,{|| TmsA250AeD(3,lCtrPremio,cGerPC,cDedPDG,nValPDG,cTipCont,oDlgPvw,;
						nValFrete,nTotValAdi,nValPDG,nBasImp,nValIRRF,nValINSS,nValSEST,nValISS,nValRetPIS,;
						nValRetCOF,@nAcresc,@nDecresc, cNatuCTC, cCodOpe, nValSestId, nValSenat	, @nVlrReem )}})
Aadd(aButtons,{'SDUPROPR',{|| TmsA250AeD(3,lCtrPremio,cGerPC,cDedPDG,nValPDG,cTipCont,oDlgPvw,;
						nValFrete,nTotValAdi,nValPDG,nBasImp,nValIRRF,nValINSS,nValSEST,nValISS,nValRetPIS,;
						nValRetCOF,@nAcresc,@nDecresc, cNatuCTC, cCodOpe, nValSestId, nValSenat	, @nVlrReem )},STR0226,STR0227}) //-- "Lanc Acres/Descres - F5" # "Lanc Acr/Decr"

//-- PE utilizado para adicionar opcoes no Acoes Relacionadas do preview
If lTM250PBt
	aTemp := ExecBlock("TM250PBt",.F.,.F.,{aButtons,aRetFrt})
	If ValType(aTemp) == "A"
		For nCount := 1 To Len(aTemp)
			Aadd(aButtons,aClone(aTemp[nCount]))
		Next nCount
	Endif
EndIf

If lTela
	DEFINE MSDIALOG oDlgPvw TITLE STR0225 + cCadastro FROM 50,50 TO 650,985 PIXEL //-- "Preview: "
		oEncPvw := MsMGet():New("DTY",,4,,,, aCampos,{035,004,295,465},aAlter,3,,,, oDlgPvw,,,.T.,,,,,,,,, .T.)
	ACTIVATE MSDIALOG oDlgPvw CENTERED ON INIT EnchoiceBar(oDlgPvw,{|| nOpca := 1, lCont:= TMSA250POk(nMaxCus,cNumCTC,lTela),oDlgPvw:End()},{||nOpca := 0,oDlgPvw:End()},,aButtons)
Else
	nOpca := 1
	lCont  := TMSA250POk(nMaxCus,cNumCTC,lTela)
EndIf

If nOpca == 1 .And. lCont
	//-- PE utilizado para validar se processa o contrato de carreteiro após o retorno do preview
	If lTM250CT1
		lRet := ExecBlock("TM250CT1",.F.,.F.,{cCodForn,cLojForn,cCodMot,cFilOri,cViagem,cCodVei,cTabFre,cTipTab,cTabCar,nValFrete,nTotValAdi,;
											  nValPDG,nBasImp,nValIRRF,nValINSS,nValSEST,nValISS,nValRetPIS,nValRetCOF, nValSESTId, nValSenat})
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf
	EndIf

	If lRet
		nValFrete  := M->DTY_VALFRE
		nTotValAdi := M->DTY_ADIFRE
		nValPDG    := M->DTY_VALPDG
		nBasImp    := M->DTY_BASIMP
		nValIRRF   := M->DTY_IRRF
		nValINSS   := M->DTY_INSS
		nValSEST   := M->DTY_SEST
		nValISS    := M->DTY_ISS
		nValRetPIS := M->DTY_PIS
		nValRetCOF := M->DTY_COFINS
		If DTY->(ColumnPos('DTY_VLSEST')) > 0 .And. DTY->(ColumnPos('DTY_VLSENA'))
			nValSESTId := M->DTY_VLSEST
			nValSenat  := M->DTY_VLSENA
		EndIf
	Else
		nOpca := 0
	EndIf
Else
	lRet := .F.
EndIf

aEval(aAreas,{|x| RestArea(x)})

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA250POk ³ Autor ³ Valdemar Roberto   ³ Data ³14.11.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a tela do preview                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA250POk(nExp01,cExp02,lExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Limite máximo de custo do serviço                 ³±±
±±³Parametros³ cExp02 := Número do contrato				                  ³±±
±±³Parametros³ lExp03 := Indica se exibe tela                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function TMSA250POk(nMaxCus,cNumCTC,lTela,lMemoria)
Local lRet     := .T.
Local aRecDoc  := {}
Local aCusVia  := {}
Local nRecVia  := 0
Local nDesVia  := 0
Local nPerCus  := 0
Local lDT3Rec  := DT3->(ColumnPos("DT3_RECEIT")) > 0
Local aTM250Cus:= { .T., '1', 0, 0, 0, 0} //-- [1]:Desliga Validação do Custo x Receita; [2]:Tipo de Geração do Contrato, sendo '1'=Gera Bloqueado;'2'=Não Gera o Contrato;[3]-Custo;[4]-Receita;[5]-perc.custo atingido em relação a receita
Local lValida  := .T.
Local lGeraCTC := .T.

DEFAULT nMaxCus 	:= 0
DEFAULT cNumCTC 	:=""
DEFAULT lTela	  	:= .T.
DEFAULT lMemoria	:= .T.

If  ( lMemoria .And. M->DTY_VALFRE == 0 ) .Or. ( !lMemoria .And. DTY->DTY_VALFRE == 0 )
	Help('',1,'TMSA25040') //-- O Valor do frete está zerado e o contrato não será gerado.
	lRet := .F.
EndIf

If lRet .And. lDT3Rec
	//-- Busca os documentos da viagem, seus valores a receber e a receita total da viagem
	//-- Mapa do vetor aRecDoc
	//-- 01 - FilDoc
	//-- 02 - Doc
	//-- 03 - Serie
	//-- 04 - Somatória dos valores dos componentes de frete do documento que seja base para receita - DT3_RECEIT = "1"
	aRecDoc := Tmsa253RDc(,,,DTQ->DTQ_VIAGEM,.F.) //-- lTela foi removido do ultimo parâmetro e informado .F. para não exibir mensagem. Será revisto a necessidade da mensagem.
	AEval(aRecDoc,{|x| nRecVia += x[4]})

	//-- Apura a despesa da viagem
	//-- Mapa do vetor aCusVia
	//-- 01 - Valor a pagar da viagem - Somatória DTY_VALFRE com DTY_VALPDG
	//-- 02 - Total dos custos anteriores dos documentos da viagem - Tabela DJC
	//-- 03 - Vetor com os custos anteriores dos documentos
	//--      01 - FilDoc
	//--      02 - Doc
	//--      03 - Serie
	//--      04 - Valor dos custos anteriores do documento - Tabela DJC
	aCusVia := Tmsa253Cus(DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS,lMemoria)
	nDesVia := aCusVia[1,1]	+ aCusVia[1,2]

	//-- Verifica se a viagem está dentro de uma lucratividade mínima
	nPerCus  := ((nDesVia * 100) / nRecVia)
	lExceCst := .F.


	// verifica se Valida a geraçãodo contrato com receita zerada dependendo do Serviço da viagem
	If nRecVia == 0
		If DTQ->DTQ_SERTMS == "1" // Coleta
			lValida := .F.  // Não valida
		Else
			lGeraCTC := .F.  // Não gera o contrato
		EndIf
	EndIf

	//-- PE utilizado para desligar a validação do custo x receita
	//-- Adicionado nova configuração que informa se deve bloquear ou não gerar o contrato.
	If lTM250Cus
	      aTM250Cus[1] := lValida //-- 1-Desliga Validação do Custo x Receita;
	      aTM250Cus[2] := Iif(lGeraCTC,'1','2')     //-- 2-Tipo de Geração do Contrato, sendo '1'=Gera Bloqueado;'2'=Não Gera o Contrato;
	      aTM250Cus[3] := nDesVia //-- 3-Custo da Viagem;
	      aTM250Cus[4] := nRecVia //-- 4-Receita da Viagem;
	      aTM250Cus[5] := nPerCus //-- 5-perc.custo atingido em relação a receita
           aTM250Cus[6] := nMaxCus
           If ValType( aTM250Cus := ExecBlock("TM250Cus",.F., .F., aTM250Cus) ) == "A"
                lValida  :=  aTM250Cus[1]
                lGeraCTC := (aTM250Cus[2] == '1') //-- Se igual a '1' mantem legado gerando o contrato bloqueado; se igual a '2'-não gera o contrato carreteiro.
                If ValType(lValida) <> "L"
                      lValida := .T.
                EndIf
           EndIf
	EndIf

	If lValida .And. nMaxCus > 0 .And. nPerCus > nMaxCus

		If lGeraCTC
		   Help("",1,"TMSA25044") //-- "O custo da viagem excedeu o limite máximo. O contrato será bloqueado."
             lExceCst := .T.

		Else
		    lRet := .F.
		    Help("",1,"TMSA25044B",,STR0286,4,15) //--O custo da viagem excedeu o limite máximo. O contrato não será gerado.

		EndIf

	EndIf
EndIf

//-- PE utilizado para validar a confirmação da tela do preview
If lRet .And. lTM250POk
	lRet := ExecBlock("TM250POk",.F.,.F.)
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
EndIf

//-- Grava historico de custo dos documentos
If lRet .And. lDT3Rec
	Tmsa253Grv(nRecVia,aCusVia[1,1],aRecDoc,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,cNumCTC)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250MTGE³ Autor ³Gilson da Silva             ³ Data ³10.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se o parametro MV_MOTGEN está preenchido.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA250MTGE(nOpcx)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Informa o grupo de veículos que será gerado o contrato  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA250MTGE(cGrupo)

Local aArea     := GetArea()
Local lRet      := .T.
Local cMotGen   := GetMv( 'MV_MOTGEN',, '' ) // Motorista generico.
Local nPagaVei  := Iif(cGrupo == 'TMA250', If(lTabDFI .And. nModulo==39,'1',mv_par07), mv_par14)  //Determina para qual(is) tipo(s) de Veiculo(s) sera(ão) gerado(s) contrato(s).
//1= Veiculo;  2= Reboque;  3=Ambos
If nPagaVei <> 1
	If Empty(cMotGen)
		Help("",1,"TMSA25003",,"MV_MOTGEN",5,5) // Este Parametro esta vazio ... E Obrigatorio preenche-lo para geracao do Contrato de Carreteiro
		lRet := .F.
	Endif

	If lRet
		DA4->(dbSetOrder(1))
		If !DA4->(MsSeek(xFilial('DA4')+cMotGen))
			Help("",1,"TMSA25020") // O motorista informado no parametro MV_MOTGEN, não está cadastrado na tabela de Motorista.
			lRet := .F.
		EndIf
	Endif
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250VBx³ Autor ³ Vitor Raspa           ³ Data ³ 27.Set.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Status dos Contratos baseado na baixa dos Titulos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA250VBx()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA250VBx()
Local aSays    := {}
Local aButtons := {}
Local lOk      := .F.

Aadd( aSays, STR0125 ) //-- "Esta opção irá checar todos os contratos com o status - Liberados para Pagamento e seus"
Aadd( aSays, STR0126 ) //-- "respectivos títulos financeiros. Caso o titulo esteja baixado em sua totalidade, o"
Aadd( aSays, STR0127 ) //-- "status do contrato de carreteiro será modificado para - Contrato Quitado/Pagamento"
Aadd( aSays, STR0128 ) //-- "realizado."
Aadd( aButtons, { 1, .T., {|o| lOk := .T., o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
FormBatch( STR0124, aSays, aButtons ) //-- "Status Financeiro"

If lOk
	Begin Transaction
	Processa({|lEnd| TMSA250PBx()},STR0124,STR0129,.T.) //-- "Verificando baixas. Por favor, aguarde...."
	End Transaction
EndIf

Return

/*/{Protheus.doc} TMSA250PBx
Processa a atualizacao dos Status dos Contratos
//TODO Descrição auto-gerada.
@author Vitor Raspa
@since 27/07/2006
@version undefined
@param cFilOriDTY, characters, Filial de Origem do Contrato
@param cNUmCTC, characters, Número do Contrato
@type function
/*/
Function TMSA250PBx( cFilOriDTY, cNUmCTC )
Local aArea     	:= GetArea()
Local aAreaDTY  	:= DTY->(GetArea())
Local cQuery    	:= ''
Local cAliasQry 	:= GetNextAlias()
Local cPrefixo  	:= ""
Local cTipCTC   	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Local cParcela  	:= StrZero(1, Len(SE2->E2_PARCELA))
Local cChave		:= ""
Local cFilDeb   	:= ""
Local lTipCTC		:= .F.
Local nCtn       	:= 0
Local nSaldo		:= 0
Local lLibCTC     	:= SuperGetMV('MV_LIBCTC',, .F.)
Local lTMSOPdg      := SuperGetMV('MV_TMSOPDG' ,,'0') == '2'
Local cTmsERP    	:= SuperGetMV("MV_TMSERP",,'0')
Local cStatus		:= ""

Default cNumCTC 	:= ""
Default cFilOriDTY	:= ""


//-- Se o parametro MV_TPTCTC nao estiver preenchido
If Empty(cTipCTC)
	If Len(cFilAnt) > 2
		Final(STR0186,STR0187)//--'O parametro MV_TPTCTC deve ser preenchido quando a Gestão Corporativa','estiver ativa.'
	Else
		lTipCTC := .T.
	EndIf
EndIf

cQuery := "SELECT DTY_FILIAL, DTY_CODFOR, DTY_LOJFOR, DTY_STATUS, DTY_NUMCTC, DTY_CODFAV, DTY_LOJFAV, DTY_TIPCTC, DTY_FILORI, DTY_VIAGEM, DTY_CODOPE, DTY_CODVEI, R_E_C_N_O_ DTYRecNo "
cQuery += "FROM " + RetSQLName('DTY') + " DTY "
cQuery += "WHERE DTY.DTY_FILIAL = '" + xFilial('DTY') + "' AND "
If !Empty(cFilOriDTY) .And. !Empty(cNumCTC)
	cQuery += "DTY.DTY_FILORI = '" + cFilOriDTY  + "' AND "
	cQuery += "DTY.DTY_NUMCTC = '" + cNumCTC  	+ "' AND "
EndIf
If !lLibCTC .And. lTMSOPdg // Caso seja liberado pela PAMCARD considera contratos em aberto.
	cQuery += "(DTY.DTY_STATUS = '1' OR DTY.DTY_STATUS = '2' OR DTY.DTY_STATUS = '3' OR DTY.DTY_STATUS = ' ' OR DTY.DTY_STATUS = '6' OR DTY.DTY_STATUS = '5' OR DTY.DTY_STATUS ='A' ) AND "
Else
	cQuery += "(DTY.DTY_STATUS = '3' OR DTY.DTY_STATUS = ' ' OR DTY.DTY_STATUS = '6' OR DTY.DTY_STATUS = '5' OR DTY.DTY_STATUS ='A'  OR DTY.DTY_STATUS ='8' ) AND "
EndIf
cQuery += "DTY.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While !(cAliasQry)->(EoF())

	For nCtn := 1 To 2
		If nCtn == 2
			cFilDeb  := TMSA250FilDeb((cAliasQry)->DTY_CODFOR,(cAliasQry)->DTY_LOJFOR,(cAliasQry)->DTY_CODFAV,(cAliasQry)->DTY_LOJFAV,(cAliasQry)->DTY_TIPCTC<>StrZero(2,Len((cAliasQry)->DTY_TIPCTC)),(cAliasQry)->DTY_FILORI,(cAliasQry)->DTY_VIAGEM,.F.,(cAliasQry)->DTY_CODVEI)
		EndIf
		cPrefixo := TMA250GerPrf(Iif(nCtn==1,cFilAnt,cFilDeb))    // Prefixo do Titulo
		//-- Se o parametro MV_TPTCTC nao estiver preenchido
		If lTipCTC
			cTipCTC := Padr( "C"+Iif(nCtn==1,cFilAnt,cFilDeb), Len( SE2->E2_TIPO ) )
		EndIf

		If !Empty((cAliasQry)->DTY_CODFAV)
			cChave := If(!Empty(FwFilial("SE2")),Iif(nCtn==1,cFilAnt,cFilDeb), xFilial("SE2"))+(cAliasQry)->(DTY_CODFAV+DTY_LOJFAV+cPrefixo+DTY_NUMCTC+cParcela+cTipCTC)
		Else
			cChave := If(!Empty(FwFilial("SE2")),Iif(nCtn==1,cFilAnt,cFilDeb), xFilial("SE2"))+(cAliasQry)->(DTY_CODFOR+DTY_LOJFOR+cPrefixo+DTY_NUMCTC+cParcela+cTipCTC)
		EndIf

		SE2->(dbSetOrder(6)) //-- E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If SE2->(MsSeek(cChave))
			If AllTrim(SE2->E2_ORIGEM) == 'SIGATMS'
				If Empty(SE2->E2_FATURA)
					If SE2->E2_SALDO <= 0
						cStatus	:= '5'
					ElseIf SE2->E2_SALDO > 0 .And. SE2->E2_SALDO <> SE2->E2_VALOR
						cStatus	:= 'A'
					ElseIf SE2->E2_SALDO > 0 .And. SE2->E2_SALDO == SE2->E2_VALOR
						If lLibCTC
							If (cAliasQry)->DTY_CODOPE == '01' .And. (cAliasQry)->DTY_STATUS $ "5|8"
								cStatus	:= "8" //-- 'Contrato Pago Pela Operadora. Aguard. Baixa Financeira.'
							Else
								If !IsInCallStack('TMSA250SLD')
									cStatus	:= "2" //-- Aguardando lib. pagamento
								Else
									cStatus	:= "3" //-- Liberado para pagamento
								EndIf
							EndIf
						Else
							cStatus	:= "3" //-- Liberado para pagamento
						EndIf

						DTQ->(dbSetOrder(2)) //-- FILIAL+FILORI+VIAGEM
						If DTQ->( MsSeek( xFilial("DTQ") + (cAliasQry)->DTY_FILORI + (cAliasQry)->DTY_VIAGEM ))
							If DTQ->DTQ_STATUS == "1" //-- Em aberto
								cStatus	:= "1" //-- Em aberto
							EndIf
						EndIf

					EndIf

					If !Empty(cStatus)
						DTY->(DbGoTo( (cAliasQry)->(DTYRecNo) ))
						RecLock('DTY',.F.)
						DTY->DTY_STATUS := cStatus
						MsUnLock()
					EndIf
				ElseIf !Empty(SE2->E2_FATURA) // Verifica se existe fatura gerada pelo financeiro
					If SE2->(DbSeek(cSeek := xFilial("SE2")+E2_FORNECE+E2_LOJA+E2_FATPREF+E2_FATURA))
						nSaldo := 0
						While SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == cSeek
							nSaldo += SE2->E2_SALDO
							SE2->(DbSkip())
						EndDo
						If nSaldo <=0
							DTY->(DbGoTo( (cAliasQry)->(DTYRecNo) ))
							RecLock('DTY',.F.)
							DTY->DTY_STATUS := '5'
							MsUnLock()
						Else
							DTY->(DbGoTo( (cAliasQry)->(DTYRecNo) ))
							RecLock('DTY',.F.)
							DTY->DTY_STATUS := '6'
							MsUnLock()
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

//-- Atualiza o status dos contratos cancelados baixa.

For nCtn := 1 To 2

	cFilSeek  := If(!Empty(FwFilial("SE2")),Iif(nCtn==1,cFilAnt,cFilDeb), xFilial("SE2"))
	cPrefixo  := TMA250GerPrf(Iif(nCtn==1,cFilAnt,cFilDeb))    // Prefixo do Titulo
	//-- Se o parametro MV_TPTCTC nao estiver preenchido
	If lTipCTC
		cTipCTC := Padr( "C"+Iif(nCtn==1,cFilAnt,cFilDeb), Len( SE2->E2_TIPO ) )
	EndIf

	cAliasQry := GetNextAlias()

	cQuery := "SELECT DTY.R_E_C_N_O_ DTYRECNO FROM " + RetSqlName("SE2") + " SE2, " + RetSqlName("DTY") + " DTY "
	cQuery += "WHERE E2_FILIAL = '" + cFilSeek + "' AND "
	cQuery += "( E2_FORNECE = DTY_CODFOR OR E2_FORNECE = DTY_CODFAV ) AND "
	cQuery += "( E2_LOJA = DTY_LOJFOR OR E2_LOJA = DTY_LOJFAV ) AND "
	cQuery += "E2_PREFIXO = '" + cPrefixo + "' AND "
	cQuery += "E2_NUM = DTY_NUMCTC AND "
	cQuery += "E2_PARCELA = '" + cParcela + "' AND "
	cQuery += "E2_TIPO = '" + cTipCTC + "' AND "
	cQuery += "E2_SALDO > 0 AND "
	cQuery += "E2_ORIGEM = 'SIGATMS' AND "
	cQuery += "DTY_STATUS = '5' AND "
	cQuery += "SE2.D_E_L_E_T_ = ' ' AND "
	cQuery += "DTY.D_E_L_E_T_ = ' '
	cQuery := ChangeQuery( cQuery )
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	While !(cAliasQry)->(Eof())

		DTY->( DbGoTo( (cAliasQry)->(DTYRECNO) ) )
		RecLock('DTY',.F.)
		DTY->DTY_STATUS := '3'
		MsUnLock()

		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->(DbCloseArea())

Next nCtn

RestArea(aArea)
RestArea(aAreaDTY)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Leg³ Autor ³ Vitor Raspa           ³ Data ³ 06.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status dos Contratos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA250Leg()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA250Leg(cAliasLeg)
Local aCores
Local cCadOld     := cCadastro
Default cAliasLeg := 'DTY'

If !Empty(cAliasLeg)
	If cAliasLeg == 'DTY' //-- Contrato de Carreteiro
		aCores := {	{ 'BR_VERDE'	, STR0090	},;		// 'Em Aberto'
					{ 'BR_AMARELO'	, STR0091	},;		// 'Aguardando Lib. Pagamento'
					{ 'BR_LARANJA'	, STR0092	},;		// 'Liberado para Pagamento'
					{ 'BR_AZUL'		, STR0094	},;		// 'Contrato Quitado com Ped. Compra'
					{ 'BR_VERMELHO'     , STR0093 },;       // 'Contrato Quitado/Pag. Realizado'
					{ 'BR_VERDE_ESCURO' , STR0246 },;       // 'Contr. Parcial/Pagto. Parcial'
					{ 'BR_CINZA'   	, STR0148	},;		// 'Titulo em Fatura'
					{ 'BR_BRANCO'  	, STR0157	},;		// 'Aguardando Confrm. Webserver'
					{ 'BR_MARRON'  	, STR0158	},;		// 'Aguardando Autoriz. Pagto'
					{ 'BR_PRETO'   	, STR0159	} }		// 'Pagamento bloqueado'

	ElseIf cAliasLeg == 'DEN' //-- Movimentacao de Valores
		aCores := {	{ 'BR_VERDE'	, STR0115	},;		// 'Movimento nao Executado'
					{ 'BR_VERMELHO'	, STR0116	}}		// 'Movimento Executado'

	ElseIf cAliasLeg == 'DEP' //-- Passagem em Postos
			aCores := {	{ 'BR_VERDE'	, STR0113	},;		// 'Passagem em Aberto'
						{ 'BR_VERMELHO'	, STR0114	}}		// 'Passagem Realizada'

	ElseIf cAliasLeg == 'DES' //-- Dados de Quitacao
			aCores := {	{ 'BR_VERDE'	, STR0117	},;		// 'Quitacao nao Realizada'
						{ 'BR_VERMELHO'	, STR0118	}}		// 'Contrato Quitado'

	ElseIf cAliasLeg == 'SDG' //-- Movimento de Custo de Transporte
		cCadastro := STR0122 //-- "Movimento de Custo de Transporte"
		TMSA070Leg( STR0116 ) //-- "Movimento Executado"

	ElseIf cAliasLeg == 'DTW' //-- Operacoes de Transporte
		cCadastro :=  STR0123 //-- Operacoes de Transporte
		TMSA350Leg(cCadastro)

	ElseIf cAliasLeg == 'DTQ' //-- Viagens
		TMSA140Leg()

	EndIf

	If !Empty( aCores ) .And. cAliasLeg <> 'SDG'
		BrwLegenda( cCadastro, STR0088, aCores) //'Legenda'
	EndIf

EndIf

cCadastro := cCadOld
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250VerBai³ Autor ³ Patricia A. Salomao ³ Data ³30.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se houve Baixa dos Titulos                         ³±±
±±            11/10/2016 - Adicionado chamada da integração via mensagem  ³±±
±±                         unica.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Prefixo do Titulo                                   ³±±
±±³          ³ExpC2 - Numero do  Titulo                                   ³±±
±±³          ³ExpC3 - Codigo do Fornecedor                                ³±±
±±³          ³ExpC4 - Loja do Fornecedor                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA250VerBai(cPrefixo, cContrat, cCodForn, cLojForn, cTipUso)

Local aAreas     := { DTY->(GetArea()), DTR->(GetArea()), DTQ->(GetArea()) }
Local lRet       := .T.
Local cChave     := ""
Local cTipAdtoPA := Padr( "PA", Len( SE2->E2_TIPO ) )  // Titulo de Adiantamento do Tipo "PA"
Local cTipPdg	 := Padr( "PDG", Len( SE2->E2_TIPO ) )
Local cTipNfc	 := Padr( "NCF", Len( SE2->E2_TIPO ) )
Local lRepom	 := SuperGetMV('MV_VSREPOM',,'1') == '2' .And. SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local aEAIRet    := {}

Default cPrefixo := ""
Default cContrat := ""
Default cCodForn := ""
Default cLojForn := ""
Default cTipUso  := IIf(!lTabDFI .Or. nModulo==43,"1","2")

//-- Verifica a Filial de Debito
If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
	cFilDeb := TMSA250FilDeb(DTY->DTY_CODFOR, DTY->DTY_LOJFOR, DTY->DTY_CODFAV, DTY->DTY_LOJFAV,, /*DTY->DTY_FILORI*/, /*DTY->DTY_VIAGEM*/, /*F*/,DTY->DTY_CODVEI )
ElseIf cTipUso == "1" //--TMS
	cFilDeb := TMSA250FilDeb(DTY->DTY_CODFOR, DTY->DTY_LOJFOR, DTY->DTY_CODFAV, DTY->DTY_LOJFAV,, DTY->DTY_FILORI, DTY->DTY_VIAGEM, .F.,DTY->DTY_CODVEI)
EndIf
If cFilDeb <> cFilAnt
	cPrefDeb := TMA250GerPrf(cFilDeb)
Else
	cPrefDeb := TMA250GerPrf(cFilAnt)
EndIf

cChave := xFilial('SE2')+cCodForn+cLojForn+cPrefixo+cContrat

If cTmsErp == '0'

	dbSelectArea('SE2')
	dbSetOrder(6)
	If MsSeek(xFilial('SE2')+cCodForn+cLojForn+cPrefixo+cContrat)
		Do While !Eof() .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM==cChave
			If ( (SE2->(ColumnPos('E2_CODOPE')) > 0 .And. !Empty(SE2->E2_CODOPE)) .Or. lRepom) .And. (SE2->E2_TIPO == cTipPdg .Or. SE2->E2_TIPO == cTipNfc)
				lRet := .T.
			ElseIf !Empty(SE2->E2_BAIXA) .And. SE2->E2_TIPO <> cTipAdtoPA
				SE5->(dbSetOrder(7))
				If SE5->(MsSeek(xFilial('SE5')+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )) .And. ;
					SE5->E5_MOTBX <> ('DAC') .And. SE5->E5_MOTBX <> ('CMP')
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				Exit
			Endif
			SE2->(dbSkip())
		EndDo
	EndIf

	//-- Verifica se o Titulo da Filial de Debito foi Baixada
	//-- Se estiver baixado e o titulo de Operadora de Frete devera ser estornada a baixa
	If lRet
		cChave :=  If(!Empty(FwFilial("SE2")), cFilDeb, xFilial("SE2"))+cCodForn+cLojForn+cPrefDeb+cContrat
		//-- Deletar Contas a Pagar da Filial de Debito
		If cFilDeb <> cFilAnt .And. MsSeek(cChave)
			Do While !Eof() .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM==cChave
				If !Empty(SE2->E2_BAIXA) .And. SE2->E2_TIPO <> Padr( "PA", Len( SE2->E2_TIPO ) )
					SE5->(dbSetOrder(7))
					If SE5->(MsSeek(xFilial('SE5')+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )) .And.;
						SE5->E5_MOTBX <> ('DAC') .And. SE5->E5_MOTBX <> ('CMP')
						If (SE2->(ColumnPos('E2_CODOPE')) <= 0 .Or. Empty(SE2->E2_CODOPE))
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If !lRet
					Exit
				EndIf
				SE2->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x| RestArea(x) })

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250FilDeb³ Autor ³ Patricia A. Salomao ³ Data ³30.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a Filial de Debito                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Fornecedor                                ³±±
±±³          ³ExpC2 - Loja do Fornecedor                                  ³±±
±±³          ³ExpC3 - Codigo do Favorecido (@)                            ³±±
±±³          ³ExpC4 - Loja do Favorecido (@)                              ³±±
±±³          ³ExpL1 - Verifica Rota                                       ³±±
±±³          ³ExpC5 - Filial de Origem                                    ³±±
±±³          ³ExpC6 - Viagem                                              ³±±
±±³          ³ExpL2 - Verifica se utilizara a Filial de Destino           ³±±
±±³          ³ExpC7 - Codigo do Veiculo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Filial de Debito                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function TMSA250FilDeb(cCodForn,cLojForn,cCodFav,cLojFav,lVerRota,cFilOri,cViagem,lFilDest,cCodVei)

Local aRet       := {}
Local aCodFav
Local aArea      := getArea()

Default cCodForn := ""
Default cLojForn := ""
Default cCodFav  := ""
Default cLojFav  := ""
Default lVerRota := .T.
Default cFilOri  := IIf(!lTabDFI .Or. nModulo==43,DTQ->DTQ_FILORI,"")
Default cViagem  := IIf(!lTabDFI .Or. nModulo==43,DTQ->DTQ_VIAGEM,"")
Default lFilDest := .F.
Default cCodVei	 := ""

aCodFav := T250BscFav(cCodVei,cCodForn,cLojForn,cFilOri,cViagem)	// retorna o codigo do Favorecido

If !Empty(aCodFav)
	cCodFav := aCodFav[1][1]
	cLojFav := aCodFav[1][2]
	cFilDeb := aCodFav[1][3]
EndIf

If Empty(cFilDeb)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna as Filiais / Regioes de Descarga da Rota                      ³
	//³ Elementos contidos por dimensao:                                      ³
	//³ 1. Regiao Origem da Rota                                              ³
	//³ 2. Regioes de Descarga da Rota                                        ³
	//³ 3. Filiais de Descarga da Rota                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//No Frete Embarcador nao deixo fazer esta checagem para o OMS
	If lVerRota
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTQ")+cFilOri+cViagem))
			aRet := TMSRegDca(DTQ->DTQ_ROTA)
			cFilDeb := If(Len(aRet)>0,aRet[Len(aRet)][3],"") //O motorista recebera o debito restante na ultima filial de descarga
		EndIf

		//-- Chegada eventual de uma viagem de Entrega e o contrato é emitido na filial destino, configurando o parametro mv_par08 - Filial de Origem
		If DTQ->DTQ_SERTMS <> StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. lFilDest
			cFilDeb := DTQ->DTQ_FILDES
		EndIf

	EndIf
	If Empty(cFilDeb)
		cFilDeb := cFilAnt
	EndIf
EndIf

If ExistBlock('TM250DEB')
	ExecBlock('TM250DEB',.F.,.F.)
EndIf

RestArea(aArea)

Return cFilDeb

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250GrvSDG³ Autor ³ Patricia A. Salomao ³ Data ³28.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Custo da Viagem                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Arquivo                                   ³±±
±±³          ³ ExpC2 - Filial Origem                                      ³±±
±±³          ³ ExpC3 - Viagem                                             ³±±
±±³          ³ ExpC4 - Codigo Despesa                                     ³±±
±±³          ³ ExpN1 - Valor                                              ³±±
±±³          ³ ExpN2 - Item                                               ³±±
±±³          ³ ExpC5 - Codigo do Veiculo                                  ³±±
±±³          ³ ExpC6 - No. do Documento                                   ³±±
±±³          ³ ExpC7 - Tipo Uso                                           ³±±
±±³          ³ ExpC8 - Ide Vge/Carga                                      ³±±
±±³          ³ ExpC9 - cIdCTMS                                            ³±±
±±³          ³ ExpD1 - Historico                                          ³±±
±±³          ³ ExpC10- Data Emissao                                       ³±±
±±³          ³ ExpC11- Numero Interno Movimento Caixinha (EU_NUM)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ No. do Documento                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMA250GrvSDG(cAlias, cFilOri, cViagem, cCodDes, nValor, nItem, cCodVei, cDoc, cTipUso,;
					  cIdent, cIdCTMS, cHistor, dDatEmis, cIntMov, lMovVal, cBanco, cAgencia, cNumCon,lCusto, cCodFor, cLojFor )

Local aCotacao   := {1,RecMoeda(Date(),2),RecMoeda(Date(),3),RecMoeda(Date(),4),RecMoeda(Date(),5)}
Local cNumSeq    := ""
Local lLibCTC    := DTY->(ColumnPos('DTY_STATUS')) > 0 .And. SuperGetMV( 'MV_LIBCTC',, .F. )
Local lForn     := SDG->(ColumnPos("DG_CODFOR") > 0 )

Default cFilOri  := ""
Default cViagem  := ""
Default cCodDes  := ""
Default cTipUso  := IIf(lTabDFI .AND. nModulo==39,"2","1")
Default cIdent   := ""
Default nValor   := 0
Default nItem    := 1
Default cCodVei  := CriaVar( "DG_CODVEI", .F. )
Default cDoc     := NextNumero("SDG",1,"DG_DOC",.T.)
Default cIdCTMS	 := ''
Default cHistor	 := ''
Default dDatEmis := dDataBase
Default cIntMov  := ''
Default lMovVal	 := .F.
Default cBanco	 := ''
Default cAgencia := ''
Default cNumCon	 := ''
Default lCusto	 := .F.
Default cCodFor	 := Posicione("DA3",1,FwxFilial("DA3") + cCodVei, "DA3_CODFOR" )
Default cLojFor  := DA3->DA3_LOJFOR

	If !lLibCTC .And. lExceCst
		lLibCTC := .T.
	EndIf
	DT7->(dbSetOrder(1))
	DT7->(MsSeek(xFilial('DT7')+cCodDes))

	RecLock("SDG",.T.)
	cNumSeq          := ProxNum()
	SDG->DG_FILIAL   := xFilial("SDG")
	SDG->DG_DOC      := cDoc
	SDG->DG_EMISSAO  := dDatEmis
	SDG->DG_NUMSEQ   := cNumSeq
	If cTipUso == "1" //--TMS
		SDG->DG_FILORI := cFilOri
		SDG->DG_VIAGEM := cViagem
	ElseIf cTipUso == "2" .And. !Empty(cTipUso) //--OMS com Frete Embarcador
		SDG->DG_TIPUSO := cTipUso
		SDG->DG_IDENT  := cIdent
	EndIf
	SDG->DG_CODVEI  := cCodVei
	SDG->DG_CODDES  := cCodDes
	SDG->DG_TOTAL   := nValor
	SDG->DG_ITEM    := StrZero( nItem, Len( SDG->DG_ITEM ) )
	SDG->DG_TOTAL   := nValor
	SDG->DG_CUSTO1  := nValor
	SDG->DG_CUSTO2  := If(aCotacao[2]>0,nValor/aCotacao[2],0)
	SDG->DG_CUSTO3  := If(aCotacao[3]>0,nValor/aCotacao[3],0)
	SDG->DG_CUSTO4  := If(aCotacao[4]>0,nValor/aCotacao[4],0)
	SDG->DG_CUSTO5  := If(aCotacao[5]>0,nValor/aCotacao[5],0)
	SDG->DG_ORIGEM  := cAlias
	SDG->DG_HISTOR  := cHistor
	SDG->DG_DATBAI  := dDatEmis
	SDG->DG_MOTBAI  := StrZero(1,Len(SDG->DG_MOTBAI)) //-- Normal
	SDG->DG_VALCOB  := nValor
	SDG->DG_DATVENC := dDatEmis
	If lLibCTC .And. !lMovVal .And. !lCusto
		SDG->DG_STATUS  := StrZero(1,Len(SDG->DG_STATUS)) //-- Aberto
	Else
		SDG->DG_STATUS  := StrZero(3,Len(SDG->DG_STATUS)) //-- Baixa Total
			//-- preencher dados do banco na baixa automatica
		SDG->DG_BANCO   := cBanco
		SDG->DG_AGENCIA := cAgencia
		SDG->DG_NUMCON  := cNumCon
	EndIf
	SDG->DG_SEQORI  := cNumSeq
	SDG->DG_CLVL    := DT7->DT7_CLVL
	SDG->DG_ITEMCTA := DT7->DT7_ITEMCT
	SDG->DG_CONTA   := DT7->DT7_CONTA
	SDG->DG_CC      := DT7->DT7_CC
	If SDG->(ColumnPos('DG_IDCTMS')) > 0
		SDG->DG_IDCTMS  := cIdCTMS
	EndIf
	If SDG->(ColumnPos('DG_INTMOV')) > 0
		SDG->DG_INTMOV  := cIntMov
	EndIf

	If lForn
		SDG->DG_CODFOR := cCodFor
		SDG->DG_LOJFOR := cLojFor
	EndIf

     If SDG->(ColumnPos("DG_DOCFRT")) > 0
         If ((type("cFilDocto") != "U") .And. (type("cNumDocto") != "U") .And. (type("cSerDocto") != "U"))
              SDG->DG_FILFRT := cFilDocto
              SDG->DG_DOCFRT := cNumDocto
              SDG->DG_SERFRT := cSerDocto
         EndIf
     EndIf
	MsUnLock()

Return cDoc


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250BaiTit³ Autor ³ Patricia A. Salomao ³ Data ³07.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Baixa Automatica do Titulo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Prefixo do Titulo                                   ³±±
±±³          ³ExpC2 - Parcela do Titulo                                   ³±±
±±³          ³ExpC3 - Tipo do Titulo                                      ³±±
±±³          ³ExpC4 - No. do Titulo                                       ³±±
±±³          ³ExpC5 - Proprietario do Veiculo (Fornecedor)                ³±±
±±³          ³ExpC6 - Loja do Proprietario do Veiculo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Static Function TMA250BaiTit(cPrefixo,cParcela,cTipo,cNum,cCodForn,cLojForn,lExibeLanc,lOnline)

Local   aBaixa		:= {}
Local   lRet        := .T.
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

DbSelectArea("SE2")

AADD(aBaixa,{"E2_PREFIXO" , cPrefixo	,Nil})
AADD(aBaixa,{"E2_NUM"     , cNum		,Nil})
AADD(aBaixa,{"E2_PARCELA" , cParcela	,Nil})
AADD(aBaixa,{"E2_TIPO"    , cTipo		,Nil})
AADD(aBaixa,{"E2_FORNECE" , cCodForn	,Nil})
AADD(aBaixa,{"E2_LOJA"    , cLojForn	,Nil})
AADD(aBaixa,{"AUTMOTBX"   , STR0039		,Nil})	//"DACAO"
AADD(aBaixa,{"AUTHIST"    , STR0040		,Nil})	//"Baixa Automatica"
AADD(aBaixa,{"AUTDESCONT" , 0			,Nil})
AADD(aBaixa,{"AUTMULTA"   , 0			,Nil})
AADD(aBaixa,{"AUTJUROS"   , 0			,Nil})
AADD(aBaixa,{"AUTVLRPG"   , 0			,Nil})
AADD(aBaixa,{"AUTVLRME"   , 0			,Nil})

MSExecAuto({| a,b,c,d,e,f | FINA080(a,b,c,d,e,f)} ,aBaixa,3,,,lExibeLanc,lOnline)//3 para baixar ou 5 para cancelar a baixa.

//-- Se houve problemas apresenta o motivo do erro.
If lMsErroAuto
	MostraErro()
	lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250GerPrf³ Autor ³ Patricia A. Salomao ³ Data ³07.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Prefixo do Titulo de acordo com a filial.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Prefixo do Titulo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMA250GerPrf(cFil)

Local cPrefix := ""
Local cRet    := ""
Local cFilAux := cFilAnt
Local cTXTLG250 := ""

If !Empty(cFil)
	cFilAnt := cFil
EndIf

//--Quando o conteudo do parametro esta preenchido retorna como macro o conteudo do parametro
cPrefix := SuperGetMv("MV_CTCPREF",.F.,'')
If !Empty(cPrefix)
	If (!(Padr(cPRefix,1) $ "'" .Or. Padl(cPRefix,Len(cPRefix)) $ "'")  .And.  !(Padr(cPRefix,1) $ '"'  .Or. Padl(cPRefix,Len(cPRefix)) $ '"'))
		cRet := cPRefix
	Else
		cRet := &cPrefix
	EndIf
Else
	//--Quando nao existe o parametro e necessario o tratamento pois o cliente pode estar com o DTY e o SE2 Compartilhado,
	//--senao a rotina nao encontraria o titulo no momento do pagamento do saldo em outras filiais
	//--cFil e a Filial de Debito do Titulo que e passada por parametro
	If Len(cFilAnt) == 2
		cRet := 'C' + cFilAnt
	Else
		cRet := Padr( 'C' + Alltrim(FWFilial()), TamSX3('E2_PREFIXO')[1] )
	EndIf
EndIf

If ValType(cRet) == 'C' .And. (Len(cRet) > TamSX3("E2_PREFIXO")[1])
	If !lExcSched250
		Final(STR0183,STR0184) //--"O tamanho do prefixo nao pode exceder o tamanho do campo:"//-- Prefixo na tabela SE2.
	Else
		cTXTLG250 := STR0183 + CHR (13) + CHR(10)
		cTXTLG250 += STR0184
		AADMsgTMS250(cTXTLG250,"TMSA250")
	EndIf
ElseIf ValType(cRet) <> 'C'
	If !lExcSched250
		Final(STR0185) //--O parametro MV_CTCPREF nao pode ter o conteudo numerico.
	Else
		cTXTLG250 := STR0185
		AADMsgTMS250(cTXTLG250,"TMSA250")
	EndIf
EndIf

cFilAnt := cFilAux

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250AtuFil³ Autor ³ Patricia A. Salomao ³ Data ³08.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o Campo E2_FILIAL com o conteudo da Fil. de Debito ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Fornecedor                                ³±±
±±³          ³ExpC2 - Loja do Fornecedor                                  ³±±
±±³          ³ExpC3 - Prefixo do Titulo                                   ³±±
±±³          ³ExpC4 - No. do Titulo                                       ³±±
±±³          ³ExpC5 - Filial de Debito                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Static Function TMA250AtuFil(cCodForn,cLojForn,cPrefixo,cContrat,cFilDeb)

Local aAreaSE2 := SE2->(GetArea())

If !Empty(FwFilial("SE2")) //-- Se nao for compartilhado
	aAreaSE2 := SE2->(GetArea())
	SE2->(dbSetOrder(6))
	SE2->(MsSeek(xFilial('SE2')+cCodForn+cLojForn+cPrefixo+cContrat))
	Do While SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == xFilial('SE2')+cCodForn+cLojForn+cPrefixo+cContrat
		If SE2->E2_FILDEB == cFilDeb
			RecLock('SE2', .F.)
			SE2->E2_FILIAL := cFilDeb
			SE2->(MsUnLock())
		EndIf
		SE2->(dbSkip())
	EndDo
	RestArea(aAreaSE2)
EndIf

Return .T.

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcão    ³ T250BSCFAV      ³ Autor ³FSW               ³ Data ³  26.03.2013   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o favorecido do fornecedor ou veiculo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ T250BscFav(CodVeiculo,CodFornecedor,LojaFornecedor,cFilOri,cViagem)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³									                                 ³±±
±±³			 ³Exp1 - Codigo do veiculo (DA3)	                                 ³±±
±±³			 ³Exp2 - Codigo do Fornecedor		                                 ³±±
±±³			 ³Exp3 - Loja do Fornecedor			                                 ³±±
±±³			 ³Exp4 - Filial de Origem da Viagem                                  ³±±
±±³			 ³Exp5 - Viagem                                                      ³±±
±±³			 ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array duas posições 1a. Codigo 2a loja                            ³±±
±±³Retorno   ³ Retorna o codigo ou loja do favorecido, caso nao exista retorna o ³±±
±±³Retorno   ³ proprio codigo do fornecedor e loja enviado na chamada da função  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function T250BscFav(cCodVei,cCodForn,cLojForn,cFilOri,cViagem)

// necessita da criação dos campos DA3_CODFAV c 6 ,DA3_LOJFAV c 2 e DA3_NOMFAV c 40 e um gatilho para alimentar o DA3_NOMFAV
Local aAreaDTR	:= DTR->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaDA3	:= DA3->(GetArea())
Local cCodFv	:= ""
Local cLojFv	:= ""
Local aRet		:= {}
Local lDTRCodFav:= DTR->(ColumnPos("DTR_CODFAV")) > 0
Local lContinua := .T.

Default cCodVei  := ""
Default cCodForn := ""
Default cLojForn := ""   
Default cFilOri  := ""   
Default cViagem  := ""   

If lDTRCodFav  .And. !Empty(cViagem) 
	DTR->(dbSetOrder(3)) //--DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_CODVEI
	If DTR->(dbSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei)) .And. !Empty(DTR->DTR_CODFAV)
		Aadd(aRet,{DTR->DTR_CODFAV,DTR->DTR_LOJFAV,Posicione('SA2',1,FwxFilial('SA2')+DTR->DTR_CODFAV+DTR->DTR_LOJFAV,"A2_FILDEB")})	
		lContinua:= .F.
	EndIf
EndIf

If lContinua
	DA3->(dbSetOrder(1))
	SA2->(dbSetOrder(1))
	If !Empty(cCodVei) .And. DA3->(dbSeek(FwxFilial('DA3')+cCodVei))
		cCodFv := DA3->DA3_CODFAV
		cLojFv := DA3->DA3_LOJFAV	
		If SA2->(dbSeek(FwxFilial('SA2')+cCodFv+cLojFv))
			cFilDeb := SA2->A2_FILDEB
		EndIf
		
		If !Empty(cCodFv) .And. !Empty(cLojFv)
			Aadd(aRet,{cCodFv,cLojFv,cFilDeb})		
		EndIf	
	EndIf

	//-- Se nao encontrou favorecido no veiculo, procura no cadastro do proprietario (fornecedor)
	If Empty(aRet) .And. !Empty(cCodForn+cLojForn) .And. SA2->(dbSeek(FwxFilial('SA2')+cCodForn+cLojForn))
		cCodFv := SA2->A2_CODFAV
		cLojFv := SA2->A2_LOJFAV
		If SA2->(dbSeek(FwxFilial('SA2')+cCodFv+cLojFv))
			cFilDeb := SA2->A2_FILDEB
		EndIf	
		
		If !Empty(cCodFv) .And. !Empty(cLojFv)
			Aadd(aRet,{cCodFv,cLojFv, cFilDeb})		
		EndIf	
	EndIf
EndIf

RestArea(aAreaSA2)
RestArea(aAreaDTR)
RestArea(aAreaDA3)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TM250ClISS³Autor  ³Raphael Zampieri       ³ Data ³13/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Efetua calculo do ISS que sera gravado na tabela DTY.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Uso: 1- TMS / 2- OMS com Frete Embarcador           ³±±
±±³          ³ExpC2 - Deduz Valor do Pedagio do Valor do Frete            ³±±
±±³          ³ExpN3 - Valor do Pedagio                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TM250ClISS(cDedPDG, nValPDG)
Local aArea      := GetArea()
Local lRndVlIss  := SuperGetMv("MV_RNDISS",.F.,.F.)
Local cForMinISS := SuperGetMv("MV_FMINISS",.F.,"1")
Local lVerMinIss := .T.
Local nPercIss   := 0
Local nBasImp    := 0
Local nRetPE     := 0

Default cDedPDG  := "2"
Default nValPDG  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Natureza pede calculo do ISS (FORNECEDOR NAO RECOLHE) ³
//³ e se nao ‚ titulo Provisorio ou Adiantamento ou Abatimento        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SA2->A2_RECISS == "S" .OR. ;
	M->E2_TIPO $ MVABATIM+"/"+MVPROVIS+"/"+MVTAXA+"/"+MVINSS+"/"+MVISS+"/"+MVTXA +"/"+"SES"+"/"+MV_CPNEG .or. ;
	(M->E2_TIPO $ MVPAGANT .And. SuperGetMv("MV_IMPADT", .F., "S") <> "S")

	If lRndVlIss
		M->E2_VALOR +=   Round(M->E2_ISS,2)
	Else
		M->E2_VALOR += NoRound(M->E2_ISS,2)
	Endif
	M->E2_ISS := 0

Else
	If SED->ED_CALCISS == "S" .And. SA2->A2_RECISS <> "S"
		nPercIss := SuperGetMv("MV_ALIQISS",.F., 5)
		//-- Ponto de entrada para informar aliquota de ISS
		If ExistBlock("F050PISS")
			nRetPE := ExecBlock("F050PISS",.F.,.F.)
			If ValType(nRetPE) == "N"
				nPercIss := nRetPE
			EndIf
		EndIf

		If cDedPDG == '1' //-- Deduz valor do pedagio no calculo dos impostos
			nBasImp := M->E2_VALOR - nValPDG //-- Base utilizada para calculo dos impostos
		Else
			nBasImp := M->E2_VALOR
		EndIf

		If lRndVlIss
			M->E2_ISS :=   Round(((nBasImp) * nPercIss / 100),2)
		Else
			M->E2_ISS := NoRound(((nBasImp) * nPercIss / 100),2)
		EndIf

		//-- Ajusta o ISS qdo a chamada for efetuada atraves do contrato de carreteiro.
		If Left(FunName(),7) == 'TMSA250'
			If Type("cNumCTC") <> "U"
				TMA250ISS()
			EndIf
			//-- Verifica se a rota e municipal, se nao for nao gera titulo de ISS, zerando o campo
			If Type("cFilVge") <> "U" .And. Type("cNumVge") <> "U"
				DTQ->(DbSetOrder(2))
				If DTQ->(MsSeek(xFilial("DTQ")+cFilVge+cNumVge))
					DA8->(DbSetOrder(1))
					If DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA)) .And. DA8->(ColumnPos("DA8_ROTMUN")) > 0
						If DA8->DA8_ROTMUN == StrZero(2,Len(DA8->DA8_ROTMUN)) //Rota Municipal = Nao
							M->E2_ISS := 0
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !Empty( SE2->(ColumnPos("E2_FRETISS"))) .And. M->E2_FRETISS == "2" // Nao verificar minimo do ISS
	lVerMinIss := .F.
Endif

If lVerMinIss .And. (;
	(cForMinISS == "1" .And. M->E2_ISS <= SuperGetMv("MV_VRETISS", .F., 0)) .Or. ;
	(cForMinISS == "2" .And. nBasImp   <= SuperGetMv("MV_VBASISS", .F., 0)) )
	M->E2_ISS := 0
EndIf

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TM250ClINS³Autor  ³Raphael Zampieri       ³ Data ³13/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Efetua calculo do INSS que sera gravado na tabela DTY.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TM250ClINS()
Local aArea     := GetArea()
Local nValInss  := 0
Local nCalcInss := 0
Local nValSEST  := 0
Local nValCIDE  := 0
Local nINSSTot  := 0
Local nRetPE    := 0
Local lRndSest  := SuperGetMv("MV_RNDSEST",.F.,.F.)

//-- Verifica se os campos utilizados para o imposto CIDE.
Local lCIDE     :=	SE2->(ColumnPos('E2_CIDE'))    > 0 .And. SE2->(ColumnPos('E2_PARCCID')) > 0 .And.;
SED->(ColumnPos('ED_CALCCID')) > 0 .And. SED->(ColumnPos('ED_BASECID')) > 0 .And.;
SED->(ColumnPos('ED_PERCCID')) > 0 .And. SA2->(ColumnPos('A2_RECCIDE')) > 0
//-- Verifica se os campos da cumulatividade de INSS existem na base
Local lTCpsINSS :=	SE2->(ColumnPos("E2_VRETINS")) > 0 .And. SE2->(ColumnPos("E2_PRETINS")) > 0 .And.;
SFQ->(ColumnPos("FQ_TPIMP"))   > 0

If M->E2_TIPO $ MVPAGANT+"/"+MVPROVIS+"/"+MVTAXA+"/"+MVINSS+"/"+MVTAXA+"/"+MV_CPNEG+"/"+MVABATIM+"/"+"SES"
	If SED->(ColumnPos("ED_DEDINSS")) > 0
		If SED->ED_DEDINSS $ "1 "
			M->E2_VALOR += NoRound(M->E2_INSS,2)
		EndIf
	Else
		M->E2_VALOR += NoRound(M->E2_INSS,2)
	EndIf
	M->E2_INSS  := 0
	M->E2_VALOR += Iif(lRndSest,Round(M->E2_SEST,2), NoRound(M->E2_SEST,2))
	M->E2_SEST  := 0
Else
	If SED->ED_CALCINS == "S" .And. SA2->A2_RECINSS == "S"
		If !Empty(SED->ED_BASEINS)
			nValInss := NoRound((M->E2_VALOR * (SED->ED_BASEINS/100)),2)
		Else
			nValInss := M->E2_VALOR
		EndIf

		//-- Para pessoa fisica verifico o limite de deducao no mes
		If SA2->A2_TIPO == "F"
			nValInss := FCalcInsPF(nValInss, @nCalcInss,@nINSSTot)
		Else
			nValInss := FCalcInsPJ(nValInss, @nCalcInss,@nINSSTot)
		Endif
		M->E2_INSS := Max(nINSSTot,nValInss)

		//-- Se os campos da cumulatividade de INSS tiverem sido criados
		If lTCpsINSS
			M->E2_VRETINS := nCalcInss
			M->E2_PRETINS := "1"
		EndIf

		//-- Valor do titulo nao pode ser menor que o valor do INSS
		If M->E2_VALOR < M->E2_INSS
			M->E2_INSS := M->E2_VALOR - 0.01
		EndIf

		//-- Ponto de entrada para calculo de INSS com base reduzida.
		If ExistBlock("F050INBR")
			nRetPE := ExecBlock("F050INBR",.f.,.f.,M->E2_VALOR)
			If ValType(nRetPE) == "N"
				M->E2_INSS := nRetPE
			EndIf

		EndIf
	EndIf

	If Left(FunName(),7) <> 'TMSA250'
		//-- Tratamento de Dispensa de Ret. de Inss. caso nao seja Pessoa Fisica
		If (M->E2_INSS < SuperGetMV("MV_VLRETIN",.F.,0)) .And. SA2->A2_TIPO <> "F"
			M->E2_INSS := 0
		EndIf
	EndIf

	//SEST
	If SED->ED_CALCSES == 'S' .And. SA2->A2_RECSEST == "1"
		If !Empty(SED->ED_BASESES)
			nValSEST := Iif(lRndSest,Round((M->E2_VALOR * (SED->ED_BASESES/100)),2),NoRound((M->E2_VALOR * (SED->ED_BASESES/100)),2))
		Else
			nValSEST := M->E2_VALOR
		EndIf
		M->E2_SEST := Iif(lRndSest,Round((nValSEST * (SED->ED_PERCSES/100)),2),NoRound((nValSEST * (SED->ED_PERCSES/100)),2))
		nValSEST := M->E2_SEST
	EndIf

	//CIDE
	If lCIDE
		If SED->ED_CALCCID == 'S' .And. SA2->A2_RECCIDE == "1"
			If !Empty(SED->ED_BASECID)
				nValCIDE := Round((M->E2_VALOR * (SED->ED_BASECID/100)),2)
			Else
				nValCIDE := M->E2_VALOR
			EndIf
			M->E2_CIDE := Round((nValCIDE * (SED->ED_PERCCID/100)),2)
			nValCIDE := M->E2_CIDE
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA250ISS  ³ Autor ³ Eduardo de Souza    ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta ISS do carreteiro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA250ISS()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Funcao utilizaa pela FA050NAT2, no FINA050                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA250ISS()

Local cQuery    := ""
Local cAliasTRB := ""
Local nValISS   := 0
Local nValSEST  := 0
Local nValFre   := 0
Local aArea     := GetArea()

//Forcamos o commit neste ponto da rotina pois como estamos em uma transacao, em alguns
//casos este select nao lia todos as informacoes o que causava divergencia nos valores,
//como este comando apenas forca um Flush, nao grava informacoes no banco a nao ser
//quando a transacao e efetivada (End Transaction), nao tem nenhum problema utilizar este comando
//no meio de uma transacao, caso a transacao seja abortada os dados nao serao gravados.
DTY->(dbCommit())

cAliasTRB := GetNextAlias()
cQuery := " SELECT SUM(DTY_VALFRE) VALFRE, SUM(DTY_ISS) VALISS,SUM(DTY_SEST) SEST "
cQuery += "   FROM "
cQuery += RetSqlName("DTY")
cQuery += "   WHERE DTY_FILIAL = '" + xFilial("DTY") + "' "
cQuery += "     AND DTY_FILORI = '" + cFilAnt + "' "
cQuery += "     AND DTY_NUMCTC = '" + cNumCTC + "' "
cQuery += "     AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
If (cAliasTRB)->(!Eof())
	If !Empty((cAliasTRB)->VALFRE)
		nValFre := (cAliasTRB)->VALFRE
	EndIf
	If !Empty((cAliasTRB)->VALISS)
		nValISS := (cAliasTRB)->VALISS
	EndIf
	If !Empty((cAliasTRB)->SEST)
		nValSEST := (cAliasTRB)->SEST
		M->E2_SEST := nValSEST
	EndIf
EndIf
(cAliasTRB)->(DbCloseArea())

//-- Verifica se eh o titulo principal e ajusto o ISS.
If nValFre == M->E2_VALOR .And. nValIss <> M->E2_ISS
	M->E2_ISS := nValIss
EndIf

RestArea(aArea)

Return

/*±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcão    ³ Tmsa250Cor      ³ Autor ³Leandro Paulino   ³ Data ³  28.10.2013   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna as cores disponiveis no Browser da rotina                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa250Cor()													               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                                 		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array duas posições 1a. Condicao e 2a. LEGENDA		               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Tmsa250Cor()

Local aCores := {}

	Aadd(aCores,{"DTY_STATUS=='1'",'BR_VERDE'    })		//-- "Em Aberto"
	Aadd(aCores,{"DTY_STATUS=='2'",'BR_AMARELO'  })		//-- "Aguardando Liberacao p/ Pagamento"
	Aadd(aCores,{"DTY_STATUS=='3' .Or. (Empty(DTY_STATUS) .And. Empty(DTY_NUMPC))",'BR_LARANJA'	})	//-- "Liberado para Pagamento"
	Aadd(aCores,{"DTY_STATUS=='4' .Or. (Empty(DTY_STATUS) .And. !Empty(DTY_NUMPC))",'BR_AZUL'	})	//-- "Contrato Quitado com Ped. Compra"
	Aadd(aCores,{"DTY_STATUS=='5'",'BR_VERMELHO' })	//-- "Contrato Quitado/Pagamento Realizado"
	Aadd(aCores,{"DTY_STATUS=='6'",'BR_CINZA' })	//-- "Titulo em fatura"
	Aadd(aCores,{"DTY_STATUS=='7'",'BR_BRANCO' })  //-- 'Aguardando Confirm. Webserver'
	Aadd(aCores,{"DTY_STATUS=='8'",'BR_MARRON' })  //-- 'Aguardando autoriz. pagto'
	Aadd(aCores,{"DTY_STATUS=='9'",'BR_PRETO' })  //-- 'Pagamento Bloqueado '
	Aadd(aCores,{"DTY_STATUS=='B'",'F12_MARR' })  //-- Contrato Quitado/Aguardando autorização Operadora

Return aCores

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250AeD  ³ Autor ³ Valdemar Roberto   ³ Data ³22.05.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acrescimes e Decrescimos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao                                             ³±±
±±³			 ³ lExp01 - Indica se veio de rotina de contrato de premio    ³±±
±±³			 ³ cExp01 - Gera Pedido de Compra ? (1=Sim/2=Nao/3=MV_TMSGRPC)³±±
±±³			 ³ lExp02 - Indica se existe a tabela DFI                     ³±±
±±³			 ³ cExp02 - Indica o tipo de uso do sistema (1=TMS / 2=OMS)   ³±±
±±³			 ³ cExp03 - Indica se deduz pedagio do frete (1=Sim / 2=Nao)  ³±±
±±³			 ³ nExp02 - Valor do pedagio                                  ³±±
±±³			 ³ cExp04 - Tipo do contrato                                  ³±±
±±³			 ³ oExp01 - Objeto da dialog do preview                       ³±±
±±³			 ³ nExp01 - Valor do Frete                                     ³±±
±±³			 ³ nExp02 - Valor do Adiantamento                              ³±±
±±³			 ³ nExp03 - Valor do Pedagio                                   ³±±
±±³			 ³ nExp04 - Valor da Base de Impostos                          ³±±
±±³			 ³ nExp05 - Valor do IRRF                                      ³±±
±±³			 ³ nExp06 - Valor do INSS                                      ³±±
±±³			 ³ nExp07 - Valor do SEST                                      ³±±
±±³			 ³ nExp08 - Valor do ISS                                       ³±±
±±³			 ³ nExp09 - Valor do PIS                                       ³±±
±±³			 ³ nExp10 - Valor do COFINS                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Opcao selecionada                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function TMSA250AeD( nOpcx		, lCtrPremio, cGerPC	, cDedPDG	, nValPDG	, cTipCont	, oDlgPvw	, nValFrete	, nTotValAdi,;
					 nValPedag	, nBasImp	, nValIRRF	, nValINSS	, nValSEST  , nValISS	, nValRetPIS, nValRetCOF, nAcresc	,;
					 nDecresc	, cNatuCTC	, cCodOpe	, nValSestId, nValSenat	, nVlrReem )
Local aAreas     := {DTY->(GetArea()),GetArea()}
Local aAlter     := {}
Local aNoFields  := {}
Local aColsBak   := {}
Local aHeaderBak := {}
Local aMsgErr    := {}
Local nCntFor1   := 0
Local nOpca      := 0
Local nPosValor  := 0
Local cFilOri    := ""
Local cNumCtc    := ""
Local cViagem	 := ""
Local lBak       := .F.
Local lBasImp    := .T.
Local lCont      := .T.
Local oDlgHis
Local oGetHis
Local nPosCod	 := 0
Local cCodAeD	 := ""
Local nAux		 := 0
Local nPosDesc	 := ""
Local nPosTipo	 := ""
Local nPosNumOco := 0
Local lCalcFrete := .F. //-- Variavel que indica se deve efetuar o cálculo do frete e base de impostos - Se o valor for gerado por ocorrencias, o valor já foi calculado na função A250AedVlr
Local cImpCTC 	:= SuperGetMv("MV_IMPCTC",,"0")
Local cTipUso	:= IIf(!lTabDFI .Or. nModulo==43,"1","2")
Local lReemb  	:= DDI->(ColumnPos('DDI_TPREEM')) > 0

DEFAULT nOpcx      := 2
DEFAULT lCtrPremio := .F.
DEFAULT cGerPC     := "2"
DEFAULT cTipUso    := "1"
DEFAULT cDedPDG    := "2"
DEFAULT nValPDG    := 0
DEFAULT cTipCont   := "1"
DEFAULT nValFrete  := 0
DEFAULT nTotValAdi := 0
DEFAULT nValPedag  := 0
DEFAULT nBasImp    := 0
DEFAULT nValIRRF   := 0
DEFAULT nValINSS   := 0
DEFAULT nValSEST   := 0
DEFAULT nValISS    := 0
DEFAULT nValRetPIS := 0
DEFAULT nValRetCOF := 0
DEFAULT nAcresc	   := 0
DEFAULT nDecresc   := 0
DEFAULT cNatuCTC   := ""
DEFAULT nValSestId := 0
DEFAULT nValSenat  := 0
DEFAULT nVlrReem   := 0

lBasImp := (nBasImp > 0)

cFilOri := M->DTY_FILORI
cNumCtc := M->DTY_NUMCTC
cViagem	:= M->DTY_VIAGEM

If nOpcx <> 2
	Aadd(aAlter,"DDN_CODAED")
	Aadd(aAlter,"DDN_VALOR")

	Aadd(aNoFields,"DDN_FILORI")
	Aadd(aNoFields,"DDN_VIAGEM")
	Aadd(aNoFields,"DDN_NUMCTC")
	Aadd(aNoFields,"DDN_CODUSU")
	Aadd(aNoFields,"DDN_NOMUSU")

EndIf

If nOpcx == 3 .And. !Empty(aHeaderAeD)
	//-- Salva vetores
	If Type("aHeader") == "A" .And. Type("aCols") == "A"
		lBak       := .T.
		aHeaderBak := Aclone(aHeader)
		aColsBak   := Aclone(aCols)
	EndIf
	aHeader := Aclone(aHeaderAeD)
	aCols   := Aclone(aColsAeD)

ElseIf nOpcx == 3
	aHeader    := {}
	aCols      := {}

	TMSFillGetDados(2,"DDN",1,xFilial("DDN") + cFilOri + cViagem,{|| DDN->DDN_FILIAL + DDN->DDN_FILORI + DDN->DDN_VIAGEM},,aNoFields,,)
	nPosCodAeD 	:= AScan(aHeader,{|x| AllTrim(x[2]) == "DDN_CODAED"})
	nPosDesc 	:= AScan(aHeader,{|x| AllTrim(x[2]) == "DDN_DESAED"})
	nPosTipo	:= AScan(aHeader,{|x| AllTrim(x[2]) == "DDN_TIPAED"})

	If Len(aCols) > 0

		DDI->(dbSetOrder(1))
		For nAux := 1 To Len(aCols)

			If DDI->( MsSeek( xFilial("DDI") + aCols[nAux,nPosCodAeD]))
				aCols[nAux,nPosDesc]	:= RTrim(DDI->DDI_DESCRI)
				aCols[nAux,nPosTipo]	:= DDI->DDI_TIPAED
			EndIf

		Next nAux
	EndIf

ElseIf nOpcx == 2
	aHeader    := {}
	aCols      := {}

	DDN->(DbSetOrder(1)) //--DDN_FILIAL+DDN_FILORI+DDN_VIAGEM+DDN_SEQUEN
	If DDN->(DbSeek(xFilial("DDN")+cFilOri+cViagem))
		TMSFillGetDados(nOpcx,"DDN",1,xFilial("DDN") + cFilOri + cViagem ,{|| DDN->DDN_FILIAL + DDN->DDN_FILORI + DDN->DDN_VIAGEM },,aNoFields,,)
		nPosCodAeD := Ascan(aHeader,{|x| AllTrim(x[2]) == "DDN_CODAED"})
		If nOpcx == 2 .And. Len(aCols) == 1 .And. nPosCodAeD > 0 .And. Empty(aCols[1,nPosCodAeD])
			Help(' ',1,'TMSA25042') //-- Não existem lançamentos de acréscimos ou decréscimos para exibir.
			lCont := .F.
		EndIf
	Else
		Help(' ',1,'TMSA25042') //-- Não existem lançamentos de acréscimos ou decréscimos para exibir.
		lCont := .F.
	EndIf
EndIf

If nOpcx == 3
	GdFieldPut("DDN_SEQUEN",StrZero(1,Len(DDN->DDN_SEQUEN)),1)
EndIf

If lCont
	DEFINE MSDIALOG oDlgHis FROM 94,104 TO 315,1100 TITLE Iif (nOpcx == 3,STR0228,STR0229) + STR0224 Of oMainWnd PIXEL // "Historico " # "Lancamento " # " de Acrescimos e Descrescimos"

		oGetHis := MSGetDados():New(36,2,111,500,nOpcx,"TM250ADLOk()","TM250ADTOk()","+DDN_SEQUEN",nOpcx != 2,aAlter,,,999,,,,,oDlgHis,,)

	ACTIVATE MSDIALOG oDlgHis ON INIT EnchoiceBar(oDlgHis,{||Iif(TM250ADTOk(nValFrete),(nOpca := 1,oDlgHis:End()),nOpca := 0)},{||(nOpca := 0,oDlgHis:End())})
EndIf

If nOpca == 1 .And. nOpcx == 3
	DDI->(dbSetOrder(1))
	nAcresc		:= 0
	nDecresc	:= 0

	//-- Apura novo valor do frete
	If (nPosCod := Ascan(aHeader,{|x| AllTrim(x[2]) == "DDN_CODAED"}) ) > 0  .And. (nPosValor := Ascan(aHeader,{|x| AllTrim(x[2]) == "DDN_VALOR"})) > 0

		nPosNumOco	:= AScan(aHeader,{|x|AllTrim(x[2]) == "DDN_NUMOCO"})

		For nCntFor1 := 1 To Len(aCols)
			If !GdDeleted(nCntFor1)
				lCalcFrete	:= Iif (nPosNumOco > 0, Empty(aCols[nCntFor1,nPosNumOco]) , .T. )
				cCodAeD		:= aCols[nCntFor1,nPosCod]
				If DDI->( MsSeek( xFilial("DDI") + cCodAeD ))
					If DDI->DDI_TIPAED == StrZero(1,TamSx3("DDN_TIPAED")[1])	//-- Acrescimo

						If lCalcFrete
							If !lReemb .Or.  DDI->DDI_TPREEM == Str(2,Len(DDI->DDI_TPREEM))
								nValFrete += aCols[nCntFor1,nPosValor]
								If lBasImp
									nBasImp += aCols[nCntFor1,nPosValor]
								EndIf
							Else
								nVlrReem += aCols[nCntFor1,nPosValor]
							EndIf
						EndIf

						nAcresc	  += aCols[nCntFor1,nPosValor]
					Else

						If lCalcFrete
							nValFrete -= aCols[nCntFor1,nPosValor]	//-- Decrescimo
							If lBasImp
								nBasImp -= aCols[nCntFor1,nPosValor]
							EndIf
						EndIf

						nDecresc  += aCols[nCntFor1,nPosValor]
					EndIf
				EndIf
			EndIf
		Next nCntFor1
	EndIf

	//-- Apura novo valor do adiantamento
	nTotValAdi := Round(nValFrete * DTR->DTR_PERADI / 100,2)

	//| Recalcula impostos, somente se integração utilizada for nativa o Protheus com outra marca será utilizado
	//| os impostos retornados pela integração.
	If Empty(cCodOpe) .Or. cImpCTC == "0"
               If cTmsERP == "0"
                    //-- Calcula os impostos
                    TM250CIMP(SA2->A2_TIPO,"DTY",lCtrPremio,cTipCont,cGerPC,cDedPDG,nValFrete,nTotValAdi,;
                    nValPedag,nBasImp,@nValIRRF,@nValINSS,@nValSEST,@nValISS,@nValRetPIS,@nValRetCOF,;
                    ,,nOpcx,,,,,@aMsgErr,cContrat,M->DTY_CODFOR,;
                    M->DTY_LOJFOR,,,cNatuCTC)
               EndIf
     EndIf
     If Empty(aMsgErr)
          //-- Atualiza os impostos
          M->DTY_VALFRE := nValFrete
		  M->DTY_ADIFRE := nTotValAdi
          M->DTY_BASIMP := nBasImp
          M->DTY_IRRF   := nValIRRF
          M->DTY_INSS   := nValINSS
          M->DTY_SEST   := nValSEST
          M->DTY_ISS    := nValISS
          M->DTY_PIS    := nValRetPIS
          M->DTY_COFINS := nValRetCOF
          M->DTY_VLACRE := nAcresc
          M->DTY_VLDECR := nDecresc
		  If DTY->(ColumnPos('DTY_VLREEM')) > 0
		  	M->DTY_VLREEM := nVlrReem
		  EndIf
          oDlgPvw:Refresh()

          //-- Retorna vetores
          aHeaderAeD := Aclone(aHeader)
          aColsAeD   := Aclone(aCols)
          If lBak
               aHeader := Aclone(aHeaderBak)
               aCols   := Aclone(aColsBak)
          ElseIf !Empty(aMsgErr)
               TmsMsgErr(aMsgErr)
          EndIf

      EndIf
EndIf

aEval(aAreas,{|x| RestArea(x)})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TM250ADLOk³ Autor ³ Valdemar Roberto     ³ Data ³26.05.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a linha dos acrescimos e decrescimos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TM250ADLOk()
Local lRet    	:= .T.
Local nSeek   	:= 0
Local cCodAeD 	:= GDFieldGet("DDN_CODAED",n)
Local dDatLan 	:= GDFieldGet("DDN_DATLAN",n)
Local cHorLan 	:= GDFieldGet("DDN_HORLAN",n)
Local cNumOco	:= GDFieldGet("DDN_NUMOCO",n)
Local cFilOco	:= GdFieldGet("DDN_FILOCO",n)
Local cSeqOco	:= GdFieldGet("DDN_SEQOCO",n)
Local nValor	:= GdFieldGet("DDN_VALOR",n)

Local cPrefixo  := TMA250GerPrf(cFilAnt)

If !GDdeleted(n) .And. (lRet := MaCheckCols(aHeader,aCols,n))
	nSeek := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos("DDN_CODAED")] + DToS(x[GdFieldPos("DDN_DATLAN")]) + x[GdFieldPos("DDN_HORLAN")] == ;
												cCodAeD + DToS(dDatLan) + cHorLan})
	If	nSeek > 0 .And. nSeek != n
		Help('',1,'TMSA25041') //-- Lançamento já efetuado.
		lRet := .F.
	EndIf

EndIf

If lRet
	lRet := TMSA250VerBai(cPrefixo,M->DTY_VIAGEM,M->DTY_CODFOR,M->DTY_LOJFOR)
EndIf

If lRet
	//-- Realiza validações para não permitir alteração/exclusão de acrescimos/decrescimos gerados no apontamento de ocorrencias
	If !Empty(cNumOco)
		If GDdeleted(n)
			lRet	:= .F.
			Help('',1,'TMSA25047')//Não é permitido realizar a exclusão de acréscimos/decréscimo que foram gerados a partir da rotina de registro de ocorrências na viagem.
		Else
			DDN->(dbSetOrder(3)) //-- FILIAL+FILOCO+NUMOCO+SEQOCO
			If DDN->( MsSeek( xFilial("DDN") + cFilOco + cNumOco + cSeqOco ))

				If nValor <> DDN->DDN_VALOR
					Help('',1,'TMSA25046') //--Lançamentos de Acréscimo/Decréscimo gerados a partir do registro de ocorrências na viagem não podem ter seus valores alterados.
					lRet := .F.
				EndIf

			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TM250ADTOk³ Autor ³ Valdemar Roberto     ³ Data ³26.05.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a tela dos acrescimos e decrescimos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TM250ADTOk(nValFrete)
Local lRet := .T.

Default nValFrete	:= 0

lRet := TM250ADLOk()

If lRet
	lRet	:= ADVldVlr(nValFrete)
EndIf

Return lRet

/*/{Protheus.doc} ADVldVlr
//TODO Validação dos valroes lançados
@author caio.y
@since 16/01/2017
@version undefined

@type function
/*/
Static Function ADVldVlr(nValFrete)
Local lRet		:= .T.
Local nCount	:= 1
Local nValor	:= 0

Default nValFrete	:= M->DTY_VALFRE

nValor	:= nValFrete

For nCount := 1 To Len(aCols)

	If aCols[nCount][GdFieldPos("DDN_TIPAED")] == "1" //-- Acrescimo
		nValor	+= aCols[nCount][GdFieldPos("DDN_VALOR")]
	ElseIf aCols[nCount][GdFieldPos("DDN_TIPAED")] == "2" //-- Decrescimo
		nValor	-= aCols[nCount][GdFieldPos("DDN_VALOR")]
	EndIf

Next

If nValor < 0
	lRet	:= .F.
	Help('',1,'TMSA25045',,,05,01) //-- "O Valor do frete deve ser maior que zero"
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Det³ Autor ³Patricia A. Salomao    ³ Data ³20.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe todos os Dados do Titulo Posicionado                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA250Det()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA250Det()
Local aArea     	:= GetArea()
Local cFilOld  		:= cFilAnt
Local oModel		:= FwModelActive()
Local oModelSE2		:= Nil
Local cFil     		:= ''
Local cPrefixo 		:= ''
Local cNum			:= ""
Local cParcela 		:= ''
Local cTipo    		:= ''
Local cCodFor  		:= ''
Local cLojFor  		:= ''

oModelSE2	:= oModel:GetModel("MdGridSE2")

cFil		:= oModelSE2:GetValue("E2_FILIAL")
cPrefixo	:= oModelSE2:GetValue("E2_PREFIXO")
cNum		:= oModelSE2:GetValue("E2_NUM")
cParcela	:= oModelSE2:GetValue("E2_PARCELA")
cTipo		:= oModelSE2:GetValue("E2_TIPO")
cCodFor		:= oModelSE2:GetValue("E2_FORNECE")
cLojFor		:= oModelSE2:GetValue("E2_LOJA")

If cFilAnt <> cFil
	cFilAnt  := cFil
EndIf

SE2->(dbSetOrder(1))
If SE2->(MsSeek(cFil+cPrefixo+cNum+cParcela+cTipo+cCodFor+cLojFor))
	FA050Visua("SE2",SE2->(Recno()),2)
EndIf

If cFilAnt <> cFilOld
	cFilAnt:= cFilOld
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250When³ Autor ³ Vitor Raspa          ³ Data ³ 27.Mar.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador padrao de Campos		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA250    												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA250When( cCampo )
Local xRet     := ''

If "DES_NOMQTC" $ Upper( cCampo )
	If DES->DES_LOCQTC == '0' //-- Local de Quitacao no Posto Conveniado
		xRet := Posicione('SA2', 1, xFilial('SA2') + DES->(DES_FORQTC+DES_LOJQTC), 'A2_NOME')
	ElseIf DES->DES_LOCQTC == '1' //-- Local de Quitacao na Filial
		xRet := Posicione('SM0',1,cEmpAnt + DES->DES_FILQTC,'M0_NOMECOM')
	EndIf
EndIf

Return(xRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA250SubºAutor  ³Raphael Z.          º Data ³  13/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada para o SubRotinas de Cheque                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA250Sub(cMnuSub)

Local lTpFrota   := DTY->(ColumnPos("DTY_TIPFRO")) > 0

If lTpFrota .And. DTY->DTY_TIPFRO == '1'
	Help("",1,"TMSA25043") //-- Opção não disponível para contratos de frota própria
	Return .F.
EndIf
Do Case
	Case cMnuSub == 1	//-- Informa Cheque
		aRotina := {	{ "", "", 0, 1 },;
		{ "", "", 0, 2 },;
		{ "", "", 0, 3 },;
		{ "", "", 0, 4 },;
		{ "", "", 0, 5 } }

		TMSA250GCH()
	Case cMnuSub == 2	//-- Imprime Cheque
		TMSA144ICH()

	Case cMnuSub == 3 //-- Confirma Pagto Saldo
		aRotina := {	{ "", "", 0, 1 },;
		{ "", "", 0, 2 },;
		{ "", "", 0, 3 },;
		{ "", "", 0, 4 },;
		{ "", "", 0, 5 } }

		TMSA250SLD(,,4)

	Case cMnuSub == 4 //-- Estorna Pgto Saldo
		aRotina := {	{ "", "", 0, 1 },;
		{ "", "", 0, 2 },;
		{ "", "", 0, 3 },;
		{ "", "", 0, 4 },;
		{ "", "", 0, 5 } }

		TMSA250SLD(,,5)

EndCase

Return



//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsTabPag
@autor		: Rafael Souza
@descricao	: Retorna as tabelas contrato comercial x a pagar
@since		: Abril/2016
@using		:
@review	:
/*/
//-------------------------------------------------------------------------------------------------

Static Function TmsTabPag(cFilOri,cViagem,aDocNPrev,cCodVei)
    Local aArea 		:= GetArea()
    Local cAliasDUD		:= ''
    Local cQuery		:= ''
    Local aTabPag		:= {}
    Local lItNPrev	    := DUD->(ColumnPos('DUD_DTRNPR')) > 0
    Local nDocto		:= 0
    Local nTamDCNPRv	:= 0
    Local cResult		:= ""


    Default cFilOri		:= ''
    Default cViagem		:= ''
    Default aDocNPRev 	:= {}
    Default cCodVei		:= ""

    nTamDCNPRv := Len(aDocNPrev)

	//Monta Variável que buscará todos os recnos dos documentos não previstos
	If nTamDCNPRv > 0
		cResult := "("
		For nDocto:= 1 To nTamDCNPRv
			cResult +=  AllTrim(Str(aDocNPrev[nDocto]) )
			If nDocto < nTamDCNPRv
				cResult +=","
			EndIf
		Next nDocto
		cResult += ")"
	EndIf

	cAliasDUD := GetNextAlias()
	cQuery := "SELECT DISTINCT DDH_TABFPG, "
	cQuery += "	    DDH_TIPTPG, "
	cQuery += "	    DDH_TABCPG, "
	cQuery += "	    CASE WHEN ISNULL(DDA_PERCUS, 0) > 0 THEN DDA_PERCUS  ELSE  ISNULL(DDC_PERCUS,0)  END PERCENTUAL, "
	cQuery += "		DDH_CODNEG, "
	cQuery += "     DDH_SERVIC "
	cQuery += "  FROM " + RetSqlName("DUD") + " DUD "

	cQuery += "  INNER JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += "    ON DT6_FILIAL     = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6_FILDOC     = DUD_FILDOC "
	cQuery += "   AND DT6_DOC        = DUD_DOC "
	cQuery += "   AND DT6_SERIE      = DUD_SERIE "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

	cQuery += "  INNER JOIN " + RetSqlName("DDH") + " DDH "
	cQuery += "    ON DDH_FILIAL     = '" + xFilial("DDH") + "' "
	cQuery += "   AND DDH_NCONTR     = DT6_NCONTR "
	cQuery += "   AND DDH_CODNEG     = DT6_CODNEG "
	cQuery += "   AND DDH_SERVIC     = DT6_SERVIC "
	cQuery += "   AND DDH_FROVEI     IN ('" + Posicione("DA3",1,xFilial("DA3") + cCodVei , "DA3_FROVEI") + "','4') "
	cQuery += "   AND DDH.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName("DDA") + "  DDA "
	cQuery += "	ON  DDA_FILIAL      = '" + xFilial("DDA") + "' "
	cQuery += "	AND DDA_NCONTR      = DDH_NCONTR "
	cQuery += "	AND DDA_CODNEG      = DDH_CODNEG "
	cQuery += "	AND DDA_SERVIC      = DDH_SERVIC "
	cQuery += "	AND DDA.D_E_L_E_T_  = ' '     "

	cQuery += "  INNER JOIN " + RetSqlName("DDC") + "  DDC "
	cQuery += "	ON  DDC_FILIAL     = '" + xFilial("DDC") + "' "
	cQuery += "	AND DDC_NCONTR     = DDA_NCONTR "
	cQuery += "	AND DDC_CODNEG     = DDA_CODNEG "
	cQuery += "	AND DDC.D_E_L_E_T_ = ' '  "

	cQuery += " WHERE DUD_FILIAL     = '" + xFilial("DUD") + "' "
	cQuery += "   AND DUD_FILORI     = '" + cFilOri + "' "
	cQuery += "   AND DUD_VIAGEM     = '" + cViagem + "' "
	If lItNPrev	  := DUD->(ColumnPos('DUD_DTRNPR')) > 0
		cQuery+=" AND (DUD_DTRNPR     = ' ' "
		If 	!Empty(cResult)
			cQuery+= "OR DUD.R_E_C_N_O_ IN " + cResult
		EndIf
		cQuery+=" ) "
	ENDIF
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "

	cQuery += " ORDER BY PERCENTUAL "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD,.F.,.T.)

	While (cAliasDUD)->(!Eof())
		AAdd(aTabPag, { (cAliasDUD)->DDH_TABFPG, (cAliasDUD)->DDH_TIPTPG,(cAliasDUD)->DDH_TABCPG, (cAliasDUD)->PERCENTUAL , (cAliasDUD)->DDH_CODNEG , (cAliasDUD)->DDH_SERVIC })
		(cAliasDUD)->(DbSkip())
	EndDo

	(cAliasDUD)->(DbCloseArea())
	RestArea(aArea)

Return (aTabPag)

/*/{Protheus.doc} TmsTabFpg
//Exib tela para seleção da tabela de frete a pagar a ser gerado o contrato de carreteiro
@author Rafael Souza
@since Abril/2016
@version undefined
@param aTabPag, array, Array com informações
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Static Function TmsTabFpg(aTabPag , cFilOri , cViagem  )
Local nRet		 	:= 0
Local aTitulo   	:= {}
Local aNewButton 	:= {}
Local aCabec     	:= Aclone(aTitulo)
Local lCancel    	:= .T.
Local nCntFor    	:= 0
Local oVerde		:= LoadBitmap( GetResources() ,"BR_VERDE"  )
Local oLaranja		:= LoadBitmap( GetResources() ,"BR_LARANJA" )
Local oAux			:= Nil
Local aDados		:= {}
Local cQuery		:= ""
Local cAliasQry		:= ""
Local cTabRent		:= "" //-- Tabela de Frete escolhida na rentabilidade
Local cTipTabRent	:= "" //-- Tipo da tabela de frete escolhida na rentabilidade
Local cTabCarRent	:= "" //-- Tabela de Carreteiro escolhida na rentabilidade
Local cNumRent		:= "" //-- Numeração Rentabilidade Prévia
Local cAux			:= ""
Local aArea			:= GetArea()
Local lRentab		:= .F. //-- Define se encontrou histório da rentabilidade prévia
Local aCores		:= {}

Default aTabPag  	:= {}
Default cFilOri		:= ""
Default cViagem		:= ""

If Len(aTabPag) > 0
	Aadd(aTitulo,"")	//-- Status
	Aadd(aTitulo,FWX3Titulo('DDH_TABFPG'))
	Aadd(aTitulo,FWX3Titulo('DDH_TIPTPG'))
	Aadd(aTitulo,FWX3Titulo('DDH_TABCPG'))
	Aadd(aTitulo,STR0232) //-- Valor do Frete
	Aadd(aTitulo, FWX3Titulo('DDA_PERCUS'))
	Aadd(aTitulo,STR0231)	 //-- Descrição
	Aadd(aTitulo,STR0285)	 //-- "Número da Rentabilidade Prévia"
EndIf


//-- Rentabilidade Prévia
If TableInDic("DL3")
	DL3->(dbSetOrder(2)) //-- FILIAL+FILORI+VIAGEM+SIMULADO
	If DL3->(MsSeek(xFilial("DL3") + cFiLOri + cViagem ))
		cTabRent	:= DL3->DL3_TABFRE
		cTipTabRent	:= DL3->DL3_TIPTAB
		cTabCarRent	:= DL3->DL3_TABCAR
		cNumRent	:= DL3->DL3_NUMSIM
		lRentab		:= .T.
	EndIf
EndIf

For nCntFor:= 1 to Len(aTabPag)

	oAux	:= oLaranja
	cAux	:= ""

	//--------------------------------------------------------------------------
	//-- Verifica qual foi a tabela de frete escolhida na rentabilidade prévia
	//--------------------------------------------------------------------------
	If lRentab
		If !Empty(aTabPag[nCntFor][1]) //-- Tabela de Frete
			If cTabRent == aTabPag[nCntFor][1] .And. cTipTabRent == aTabPag[nCntFor][2]
				oAux	:= oVerde
				cAux	:= cNumRent
			EndIf
		ElseIf !Empty(aTabPag[nCntFor][3]) //-- Tabela de Carreteiro
			If cTabCarRent == aTabPag[nCntFor][3]
				oAux	:= oVerde
				cAux	:= cNumRent
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	//-- Encontra a descrição das tabelas
	//--------------------------------------------------------------------------
	If !Empty(aTabPag[nCntFor][1])
		aAdd(aTabPag[nCntFor],Alltrim(Posicione( 'DTL', 1,xFilial('DTL')+aTabPag[nCntFor][1]+aTabPag[nCntFor][2], 'DTL_DESCRI' ))) // Descrição da tabela de frete a pagar
	Else
		aAdd(aTabPag[nCntFor],Alltrim(Posicione( 'DUS', 1,xFilial('DUS')+aTabPag[nCntFor][3], 'DUS_DESCRI' ))) // Descrição da tabela de Frete Carreteiro
	EndIf

	//--------------------------------------------------------------------------
	//-- Adiciona o status para as tabelas apresentadas
	//--------------------------------------------------------------------------
	Aadd( aDados , { oAux , aTabPag[nCntFor][1], aTabPag[nCntFor][2], aTabPag[nCntFor][3], aTabPag[nCntFor][4], aTabPag[nCntFor][5], aTabPag[nCntFor][6] , cAux  } )

Next nCntFor

//--------------------------------------------------------------------------
//-- Adiciona botão contendo legenda
//--------------------------------------------------------------------------
aCores := {	{ 'BR_VERDE'	, STR0283	},;		// "Tabela de Frete escolhida durante a exibição da Rentabilidade Prévia"
			{ 'BR_LARANJA'	, STR0284	}}		// "Não selecionado na Rentabilidade Prévia"

AAdd(aNewButton, {9,{|| BrwLegenda("",STR0088,aCores) ,STR0088} } ) //-- Legenda

nRet := TmsF3Array( aTitulo, aDados, STR0233, lCancel, aNewButton , aCabec ) // Escolha a Tabela de Frete a Pagar

RestArea(aArea)
Return nRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tm250IrCar
@autor		: Rafael Souza
@descricao	: Realiza o calculo do IR quando GERTIT = .F.
@since		: Junho/2016
@using		: Preview do Frete a Pagar
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tm250IrCar(cCodForn,cLojForn,nBasImp,nValFrete,cCondPag,cTipUso)

Local aArea      	:= GetArea()
Local aAreaDTQ   	:= DTQ->(GetArea())
Local aAreaDTR   	:= DTR->(GetArea())
Local aAreaSA2   	:= SA2->(GetArea())
Local lLibCTC    	:= SuperGetMV( 'MV_LIBCTC',, .F. )
Local cNATCTC    	:= Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NATUREZ")
Local lGerTit    	:= GetMV('MV_GERTIT' ,,.T.) // Verifica se devera gerar ou nao contas a pagar (SE2)
Local lCpoInsR   	:= SE2->(ColumnPos('E2_INSSRET')) > 0
Local lIRRFCAR   	:= .F.
Local cCarIR     	:= GetNextAlias()
Local nTotIR     	:= 0
Local nTotINSS   	:= 0
Local nValFre    	:= 0
Local aRet			:= {}
Local aVenctos   	:= {}
Local nValIRRF		:= 0
Local nValINSS		:= 0
Local cTipCTC    	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Private nValDig     := 0
Private aAutoCab    := {}

Default cCodForn := ""
Default cLojForn := ""
Default nBasImp  := 0
Default cCondPag := ""
Default cTipUso  := IIf(!lTabDFI .Or. nModulo==43,"1","2")
Default nValFrete := 0

cNATCTC  := IIf( Empty(cNATCTC) , TMSA250Var("NAT"), cNATCTC )
lIRRFCAR := Posicione("SED",1,xFilial("SED")+cNATCTC,"ED_IRRFCAR") == "S"

//-- Gerar Contrato de Carreteiro
If !lGerTit
	If lIRRFCAR // (lGerTit = Falso) Nao gera titulo no financeiro
		cQuery := "SELECT SUM(DTY.DTY_IRRF)   nTotIR, SUM(DTY.DTY_INSS) nTotINSS, "	//Somo IR e INSS do periodo
		cQuery += "       SUM(DTR.DTR_VALFRE) nValFre "								// Somo o os valores de frete do periodo
		cQuery += "FROM " + RetSqlName("DTY") + " DTY "
		//-- SED - Naturezas
		cQuery += "JOIN " + RetSqlName("SED") +" SED "
		cQuery += "  ON SED.ED_FILIAL  = '" + xFilial("SED") + "' "
		cQuery += " AND SED.ED_CODIGO  = '" + cNATCTC + "' "
		cQuery += " AND SED.ED_CALCIRF = 'S' AND SED.ED_IRRFCAR = 'S' AND SED.D_E_L_E_T_ = ' ' "
		//-- DTR - Veiculos da viagem onde ha o valor do frete
		cQuery += " LEFT JOIN " + RetSqlName("DTR") + " DTR "
		cQuery += "   ON DTY.DTY_FILORI = DTR.DTR_FILORI "
		cQuery += "  AND DTY.DTY_VIAGEM = DTR.DTR_VIAGEM "
		cQuery += "  AND DTR.D_E_L_E_T_ = ' ' "
		//-- DTY - Contrato de carreteiro
		cQuery += "WHERE DTY_FILIAL = '" + xFilial("DTY") + "' "
		cQuery += "  AND DTY.DTY_CODFOR = '"+ cCodForn + "' AND DTY.DTY_LOJFOR = '" + cLojForn + "' "
		cQuery += "  AND DTY.DTY_DATCTC BETWEEN '" + Dtos(FirstDay(dDataBase)) + "' AND '" + Dtos(LastDay(dDataBase)) + "' "
		cQuery += "  AND DTY.D_E_L_E_T_ = ' ' AND "
		//-- SE2 - Contas a Pagar - se ainda nao gerou titulo no financeiro
		cQuery += "(SELECT COUNT(*) FROM " + RetSqlName("SE2") + " SE2 "
		cQuery += "WHERE E2_FILIAL  = '" + xFilial("SE2") + "' "
		cQuery += "  AND E2_NUM     = DTY_NUMCTC "
		cQuery += "  AND E2_TIPO    IN ('"+cTipCTC+"', 'RPA' ) " // Tipo especifico do cliente.
		cQuery += "  AND E2_FORNECE = DTY_CODFOR "
		cQuery += "  AND E2_LOJA    = DTY_LOJFOR "
		cQuery += "  AND E2_EMISSAO BETWEEN '" + Dtos(FirstDay(dDataBase)) + "' AND '" + Dtos(LastDay(dDataBase))+ "' "
		cQuery += "  AND SE2.D_E_L_E_T_ = ' ') = 0 "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cCarIR, .F., .T.)
		TcSetField(cCarIR,"nTotIR",  "N", TamSX3("DTY_IRRF")[1],  TamSX3("DTY_IRRF")[2])
		TcSetField(cCarIR,"nTotINSS","N", TamSX3("DTY_INSS")[1],  TamSX3("DTY_INSS")[2])
		TcSetField(cCarIR,"nValFre", "N", TamSX3("DTR_VALFRE")[1],TamSX3("DTR_VALFRE")[2])
		nTotIR   := (cCarIR)->nTotIR	//Total de IR do periodo
		nTotINSS := (cCarIR)->nTotINSS	//Total de INSS do periodo
		nValFre  := (cCarIR)->nValFre	//Total de frete do periodo
		(cCarIR)->(DbCloseArea())

		//-- Nao for Contrato de Premio, Calcula os impostos que serao gravados no DTY
		If !lLibCTC
			lF050Auto := .T.
			lAltera   := .F.
			nOldValor := 0
			nOldIrr   := 0
			nOldIss   := 0
			nOldInss  := 0
			nOldSEST  := 0
			nValIRRF  := 0
			nValINSS  := 0

			RegToMemory("SE2",.T.)
			SED->(dbSetOrder(1))
			SED->(MsSeek(xFilial('SED')+cNatCTC))
			M->E2_NATUREZ := SED->ED_CODIGO
			M->E2_VALOR   := nValDig := IIf(nBasImp > 0, nBasImp, nValFrete) + nValFre
			M->E2_FORNECE := SA2->A2_COD
			M->E2_LOJA    := SA2->A2_LOJA

			If lCpoInsR
				If lTabDFI .And. cTipUso == "2" //--Carga
					M->E2_INSSRET := DAS->DAS_INSRET
				ElseIf cTipUso == "1" //--Viagem
					M->E2_INSSRET := DTR->DTR_INSRET
				EndIf
			EndIf

			//--Obtem o 1.o Vencimento do titulo para calculo do IRRF
			aVenctos := Condicao( nValFrete, cCondPag,, dDataBase )
			If Len(aVenctos) > 0
				M->E2_VENCREA := aVenctos[1,1]
			Else
				M->E2_VENCREA := dDataBase
			EndIf

			//-- Calcula os Impostos
			FA050NAT2()
			nValIRRF := Max(0,M->E2_IRRF)
			nValINSS := Max(0,M->E2_INSS)
			nValIRRF := nValIRRF - nTotIR
			nValINSS := nValINSS - nTotINSS
		EndIf
	Else
		nValIRRF := 0
		nValINSS := 0
	EndIf
EndIf

AAdd(aRet,{nValIRRF,nValINSS})

RestArea(aArea)
RestArea(aAreaDTQ)
RestArea(aAreaDTR)
RestArea(aAreaSA2)

Return (aRet)
/*/-----------------------------------------------------------
{Protheus.doc} TmA250Clas()
Seta os atributos do método para comnicação com o EAI

Uso: TMSA250

@sample
//TmA250Clas()

@author Leandro Paulino
@since 26/10/2016
@version 1.0
-----------------------------------------------------------/*/
Function TmA250Clas(cFilOri	, cViagem   , cTitulo  , nValorDoc, nBaseImp  , nValorPdg, nValorAdto, nValorNDF, nINSSRet , nAliqISS  , cCodForn,;
					cLojForn, cCnpjForn , cFilDeb  , dDataEmi , dDataTrans, cHistory , cEventType, cEntyName, cTipoMsg , cSubTipMsg, lBlqTit ,;
						lPreview, lBloqPagto, lExcluir , aImpostos, nVlrReem	)
Local oXML          := NIL
Local lRet			:= .T.
Local aEAIRet		:= {}
Local aAreaDTQ      := DTQ->(GetArea())
Local aAreaDTR      := DTR->(GetArea())
Local aAreaDA8      := DA8->(GetArea())
Local aArea         := GetArea()
Local cCodOper      := ""
Local aAreaSA2      := SA2->(GetArea())

Default cFilori		:= ""
Default cViagem		:= ""
Default cTitulo	:= ""
Default nValorDoc	:= 0
Default nBaseImp    := 0
Default nValorPdg	:= 0
Default nValorAdto	:= 0
Default nINSSRet    := 0
Default nAliqISS    := 0
Default nValorNDF   := 0
Default cCodForn	:= ""
Default cLojForn	:= ""
Default cCNPJForn	:= ""
Default cFilDeb		:= ""
Default dDataEmi	:= ddatabase
Default dDataTrans  := ddatabase
Default cHistory 	:= ""
Default cEntyName	:= ""
Default cTipoMsg	:= "2"
Default cSubTipMsg	:= "201"
Default lBlqTit     := GetMV('MV_LIBCTC' ,,.T.)
Default lPreview    := .F.
Default lBloqPagto	:= .F. // Bloqueia Pagamento? .T.=SIM;.F.=NÃO
Default lExcluir    := .F.
Default aImpostos	:= {}
Default nVlrReem	:= 0

If Type('oDTClass') == 'O'
	oDTClass:reset()
Else
	//| Valida se existe a classe de integração EAI Contas Pagar
	If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
		oDTClass := TransportDocumentClass():New()
	EndIf

EndIf

If Type('oDTClass') == 'O'
     //| Quando Exclusão do Fechamento da Viagem o Tipo e SubTipo devem ir de acordo com a
     //| definição da viagem.
     If lExcluir .And. IsInCallStack("TMSA310MNT")
         cTipoMsg   := "1"   // Tipo   : Viagem
         cSubTipMsg := "102" // SubTipo: Momento de exclusão - Fechamento da Viagem.
     EndIf
     //+--------------------------------------------------------------------
     //| Define Aliquota ISS para quando rota municipal
     //+--------------------------------------------------------------------
     If cTipoMsg != "7"
	     DTQ->(DbSetOrder(2)) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
	     If DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem)) .And. nAliqIss == 0
	          DA8->(DbSetOrder(1))
	          If DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA)) .And. DA8->(ColumnPos("DA8_ROTMUN")) > 0
	             cRotMun := DA8->DA8_ROTMUN
	             If cRotMun == "1"
	                 nAliqIss := SuperGetMv("MV_ALIQISS",,0)
	             EndIf
	          EndIf
	     EndIf
     EndIf

     //| Posiciona no Complemento da Viagem
     DTR->(dbSetOrder(3))
     If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem) )
          If nINSSRet == 0      //|Obtém o INSS Retido
             nINSSRet := DTR->DTR_INSRET
          EndIf
          cCodOper := DTR->DTR_CODOPE
     EndIf

	oDTClass:cVIAGEM          := AllTrim(cViagem)
	oDTClass:cFILORI          := AllTrim(cFilori)
	oDTClass:cTITULO          := AllTrim(cTitulo)
	oDTClass:nVALORDOC        := nValorDoc
	oDTClass:nBaseImp         := nBaseImp
	oDTClass:nVALORPDG        := nValorPdg
	oDTClass:nVALORADTO       := nValorAdto
	oDTClass:nValorNDF        := nValorNDF
	oDTClass:nAliqISS         := nAliqISS
	oDTClass:nINSSRetido      := nINSSRet
	oDTClass:cCODCLIENTE      := cCodForn
	oDTClass:cLOJCLIENTE      := cLojForn
	oDTClass:cDSCCLIENTE      := Iif(cTipoMsg == "7",Posicione("SA2",1,xFilial("SA2") + PadR(cCodForn,TamSX3("A2_COD")[1]) + PadR(cLojForn,TamSX3("A2_LOJA")[1]),"A2_NOME"),"")
	oDTClass:cCNPJCPFCLI      := cCnpjForn
	oDTClass:cFILDEBITO       := cFilDeb
	oDTClass:dEMISSAO         := dDataEmi
	oDTClass:dTRANSACAO       := dDataTrans
	oDTClass:dVENCIMENTO      := CTOD("")
	oDTClass:cHISTORICO       := cHistory
	oDTClass:cEventType       := Iif(lExcluir == .F.,"upsert","delete")
	oDTClass:cTIPOMSG         := cTipoMsg   //| Tipo Contrato Carreteiro.
	oDTClass:cSUBTIPOMSG      := cSubTipMsg //| Sub Tipo Frete Normal
	oDTClass:cLiberaTitulo    := "1" //Iif(!lBlqTit   ,"1","2") // "1" Liberado ou "2" Bloqueado - Aguarda Liberação de CTC
	oDTClass:lPreview         := lPreview // default .F.
	oDTClass:cStatusPag       := Iif(SuperGetMv("MV_LIBCTC",,.F.)==.T.,"1","2") // Quando .T. a mensagem é enviada com o status do pagamento bloqueado
    oDTClass:cOperatorCode    := cCodOper
	oDTClass:nValorReem		  := nVlrReem

	oDTClass:AddTrip(cFilOri,cViagem)
	oDTClass:AddTaxes(aImpostos)

	If cTipoMsg != "7"
		SetRotInteg("TMSA250")
		aEAIRet := FwIntegDef("TMSA250",,,,"TMSA250") //| Chamada da rotina de integração.
		If ValType(aEAIRet) == "U"
			Help('',1,'TM250EAI-00',,STR0249,01,05)
			lRet := .F.

		Else

			If aEAIRet[1]
				oDTClass:lPreview := .F. //| define lPreview como falso para desligar a integração do tipo previsão.
			EndIf

		EndIf
	EndIf
EndIf

//| reset da lista de viagens
oDTClass:aTrips := Nil
oDTClass:aTrips := {}

RestArea(aAreaSA2)
RestArea(aAreaDA8)
RestArea(aAreaDTQ)
RestArea(aAreaDTR)
RestArea(aArea   )

Return aEAIRet

/*/-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Commit do Modelo.

Uso: TMSA250

@sample
//CommitMdl()

@author Leandro Ferreira Paulino
@since 26/10/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function CommitMdl(oModel)

Local aAreaDTY      := DTY->(GetArea())
Local bIntegEAI 	:= Nil
Local lRet			:= .T.
Local lComplemento	:= IsInCallStack("TMSA250Com")
Local cDocSDG		:= ""
Local oMdlField		:= Nil
Local oMdlAux		:= Nil
Local lTM250Desp	:= ExistBlock("TM250Desp")
Local cCodDesCTC	:= TMSA250Var("DES")	// Codigo de Despesa de contrato de carreteiro
Local lDigita		:= .F.
Local lAglutina		:= .F.
Local nCntFor		:= 1
Local nCount		:= 1
Local lTpFrota   	:= DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local nBasImp		:= 0
Local nValFrete		:= 0
Local lLibCTC    	:= DTY->(ColumnPos('DTY_STATUS')) > 0 .And. SuperGetMV( 'MV_LIBCTC',, .F. )
Local cCodFav		:= ""
Local cLojFav		:= ""
Local nOpc			:= 0
Local cFilOri		:= ""
Local cViagem		:= ""
Local cNumCTC		:= ""
Local cNumPC		:= ""
Local cCodForn		:= ""
Local cLojForn		:= ""
Local cCodVei		:= ""
Local lPrincipal	:= .T. //-- Contrato principal
Local cTipoCTC		:= ""
Local cQuery        := ""
Local nCodRet       := 0
Local cSeekSDG      := ""
Local aAreaSDG      := {}
Local cTmsERP    	:= SuperGetMV("MV_TMSERP",,'0')
Local aAreaDTR      := {}
Local aSX5			:= {}
Local cTitFrete		:= ""	//--Define se o Titulo de Frete foi gerado na geração do contrato de carreteiro.
Local lConLineCTB		:= .F.

Private lCriaHeader := .T.	// Para criar o header do arquivo Contra Prova
Private cLoteCTC	:= ""
Private cArquivo	:= ""
Private nHdlPrv     := 0 // Endereco do arquivo de contra prova dos lanctos cont.
Private nTotal      := 0	// Total dos lancamentos contabeis
Private aRecSDGBai  := {}	// Contabiliza a partir da Baixa da Despesa
Private aRecSDGEmi  := {}	// Contabiliza a partir da Emissao da Despesa
Private lExibeLanc  := .F.
Private lOnline     := .F.
Private lMsErroAuto := .F.
Private oDTClass    := Nil

//|
//| Valida se existe a classe de integração EAI Contas Pagar
If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
   oDTClass := TransportDocumentClass():New()
EndIf

Default oModel := FwModelActive()

nOpc	:= oModel:GetOperation()


//--- Prepara arquivo para Lançamento Contabil
If cTmsErp == "0" .And. (nOpc == MODEL_OPERATION_DELETE  .Or. lComplemento)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSX5 := FWGetSX5("09","TMS")
	cLoteCTC:=IIF(!Empty(aSX5),aSX5[1][4],"TMS ")

	Pergunte("TM250D",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as perguntas selecionadas                            ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ mv_par01 - Mostra lancamentos contabeis    ?                 ³
	//³ mv_par02 - Aglutina lancamentos contabeis  ?                 ³
	//³ mv_par03 - Contabiliza on-line?                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
	lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
	lOnline   := Iif(mv_par03 == 2,.F.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o custo medio e' calculado On Line               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOnline
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se necessario cria o cabecalho do arquivo de prova           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCriaHeader
			lCriaHeader := .F.
			nHdlPrv := HeadProva(cLoteCTC,"TMSA250",cUserName,@cArquivo)
			If nHdlPrv < 0
				Help(" ",1,"SEM_LANC") //"Nao foi possivel abrir o arquivo de Contra Prova"
                        RestArea(aAreaDTY)
				Return .F.
			EndIf
			lCriaHeader  := .F.
		EndIf
		lConLineCTB:= .T.
	EndIf
EndIf


//-- Acionado pela rotina de complemento de contrato
If nOpc <> MODEL_OPERATION_DELETE

	If lComplemento

		oMdlField	:= oModel:GetModel("MdFieldDTY")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula os impostos do DTY                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If .Not. lImpRecalc
		     lRet := TMSA250Imp()
		EndIf

		nBasImp		:= oMdlField:GetValue("DTY_BASIMP")
		nValFrete	:= oMdlField:GetValue("DTY_VALFRE")
		cCodFav		:= oMdlField:GetValue("DTY_CODFAV")
		cLojFav		:= oMdlField:GetValue("DTY_LOJFAV")
		oMdlField:LoadValue("DTY_BASIMP", IIf(nBasImp > 0, nBasImp, nValFrete) )

		//--Se a liberacao de contrato estiver ativa a filial de debito so sera preenchida na liberacao do contrato.
		If lLibCTC .And. !(IsInCallStack("TMSA740"))
			oMdlField:LoadValue("DTY_FILDEB", "" )
		Else
			oMdlField:LoadValue("DTY_FILDEB", cFilDeb )
		EndIf

		If !Empty(cCodFav+cLojFav)
			oMdlField:LoadValue("DTY_CODFAV", cCodFav )
			oMdlField:LoadValue("DTY_LOJFAV", cLojFav )
		EndIf

		If lTpFrota
			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial('DA3')+ oMdlField:GetValue("DTY_CODVEI") ))
				oMdlField:LoadValue("DTY_TIPFRO", DA3->DA3_FROVEI )
			EndIf
		EndIf

		//-- Ponto de Entrada para trocar o codigo da despesa:
		If lTM250Desp
			cCodDesCTC := ExecBlock('TM250Desp',.F.,.F.,{5})
			DT7->(DbSetOrder(1))
			If !DT7->(MsSeek(xFilial('DT7') + cCodDesCTC))
				cCodDesCTC  := TMSA250Var("DES")
			EndIf
		EndIf

		//-- Gerar Custo de Transporte
		cDocSDG := NextNumero("SDG",1,"DG_DOC",.T.)
		cDocSDG	:= TMA250GrvSDG("DTY",;
								oMdlField:GetValue("DTY_FILORI"),;
								oMdlField:GetValue("DTY_VIAGEM"),;
								cCodDesCTC,;
								oMdlField:GetValue("DTY_VALFRE"),;
								1,;
								oMdlField:GetValue("DTY_CODVEI"),;
								cDocSDG,;
								,;
					  			,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
								oMdlField:GetValue("DTY_CODFOR"),;
								oMdlField:GetValue("DTY_LOJFOR"))

		oMdlField:LoadValue("DTY_DOCSDG", cDocSDG )



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o custo medio e' calculado On Line               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type('lConLine') == 'U'
			lOnLine:= lConLineCTB
		EndIf
		If lOnline
			If SDG->DG_STATUS == StrZero(3, Len(SDG->DG_STATUS)) .And. Empty(SDG->DG_DTLANC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera o lancamento no arquivo de prova           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotal+=DetProva(nHdlPrv,"901","TMSA250",cLoteCTC)
				AAdd(aRecSDGBai, SDG->(Recno()) )
			EndIf
		EndIf

	Else

		oMdlField	:= oModel:GetModel("MdFieldDTY")

		cFilOri    := oMdlField:GetValue("DTY_FILORI")
		cViagem    := oMdlField:GetValue("DTY_VIAGEM")
		cNumCTC    := oMdlField:GetValue("DTY_NUMCTC")

		//-- Gravação DUA
		lRet	:= A250VldDUA( cFilOri , cViagem , {} , .T. , cNumCTC )

	EndIf

Else

	oMdlField	:= oModel:GetModel("MdFieldDTY")

	cFilOri    	:= oMdlField:GetValue("DTY_FILORI")
	cViagem    	:= oMdlField:GetValue("DTY_VIAGEM")
	cNumCTC    	:= oMdlField:GetValue("DTY_NUMCTC")
	cCodForn   	:= oMdlField:GetValue("DTY_CODFOR")
	cLojForn   	:= oMdlField:GetValue("DTY_LOJFOR")
	cCodVei    	:= oMdlField:GetValue("DTY_CODVEI")
	cNumPC	    	:= oMdlField:GetValue("DTY_NUMPC")

	lPrincipal 	:= .T.
	cTipoCTC   	:= oMdlField:GetValue("DTY_TIPCTC") //--Posicione('DTY',2,FwxFilial('DTY')+cFilOri+cViagem+cNumCTC,'DTY_TIPCTC')
	cTitFrete	:= oMdlField:GetValue("DTY_TITFRE")
    lRet       	:= A250DelDTY( cFilOri ,  cViagem , cNumCTC , cNumPC , cCodForn , cLojForn , cCodVei , lPrincipal , , cTitFrete )

	If lRet .And. cTipoCTC <> '5'

		//-- Verifica relacionamentos de contratos complementares
		oMdlAux		:= oModel:GetModel("MdGridDTY")
		If !oMdlAux:IsEmpty()
			For nCount := 1 To oMdlAux:Length()
				oMdlAux:GoLine(nCount)

				cFilOri		:= oMdlAux:GetValue("DTY_FILORI")
				cViagem		:= oMdlAux:GetValue("DTY_VIAGEM")
				cNumCTC		:= oMdlAux:GetValue("DTY_NUMCTC")
				cCodForn	:= oMdlAux:GetValue("DTY_CODFOR")
				cLojForn	:= oMdlAux:GetValue("DTY_LOJFOR")
				cCodVei		:= oMdlAux:GetValue("DTY_CODVEI")
				cTitFrete	:= oMdlAux:GetValue("DTY_TITFRE")
				lPrincipal	:= .F.

				If lRet	.And. !Empty(cNumCTC)
					lRet	:= A250DelDTY( cFilOri ,  cViagem , cNumCTC , cNumPC , cCodForn , cLojForn , cCodVei , lPrincipal , , cTitFrete )
				EndIf

			Next nCount
		EndIf

		//-- Verifica relacionamentos dos contratos por periodo
		oMdlAux		:= oModel:GetModel("MdGrid2DTY")
		If !oMdlAux:IsEmpty()
			For nCount := 1 To oMdlAux:Length()
				oMdlAux:GoLine(nCount)
				cFilOri        := oMdlAux:GetValue("DTY_FILORI")
				cViagem        := oMdlAux:GetValue("DTY_VIAGEM")
				cNumCTC        := oMdlAux:GetValue("DTY_NUMCTC")
				cCodForn       := oMdlAux:GetValue("DTY_CODFOR")
				cLojForn       := oMdlAux:GetValue("DTY_LOJFOR")
				cCodVei        := oMdlAux:GetValue("DTY_CODVEI")
				cTitFrete	:= oMdlAux:GetValue("DTY_TITFRE")
				lPrincipal     := .F.

				If lRet	.And. !Empty(cNumCTC)
				     //| Quando por período libera o envio da integração de exclusão do titulo ao atingir o ultimo registro.
				     //| lIntegra ultimo parâmetro do A250DelDTY == .T.
				     //| ** 2017-01-17 : Alterado para enviar a integração somente se for o titulo principal, para isso foi definido
				     //|    o ultimo parâmetro(lIntegra) de A250DelDTY com o conteúdo de lPrincipal que aqui será definido com .F.
					lRet      := A250DelDTY( cFilOri ,  cViagem , cNumCTC , cNumPC , cCodForn , cLojForn , cCodVei , lPrincipal , , cTitFrete )
				EndIf

			Next nCount
		EndIf
	EndIf

	//-- Ocorrencias Receita/Despesa
	//-- Remove Referencias Da Tabela DUA Quando a Geração Do Contrato Foi Pelo Tmsa152
	If lRet .And. !Empty(cNumCTC)

		//-- Atualiza Tabela De Ocorrencias DUA
		cQuery := ""
		cQuery += " UPDATE	" + RetSqlName("DUA") + " "
		cQuery += " SET		DUA_FLOCTC =  '" + Space(Len(cFilOri))  + "', "
		cQuery += "         DUA_NUMCTC =  '" + Space(Len(cNumCTC))  + "', "
		cQuery += "         DUA_RECDEP =  '1' "
		cQuery += " WHERE   DUA_FILIAL =  '" + FWxFilial("DUA")     + "'  "
		cQuery += " AND		DUA_FLOCTC =  '" + cFilOri              + "'  "
		cQuery += " AND		DUA_NUMCTC =  '" + cNumCTC              + "'  "
		cQuery += " 	AND     DUA_NUMCTE =  ' ' "
		cQuery += " AND		D_E_L_E_T_ =  ' ' "

		//-- Executa Script
		nCodRet:= TcSqlExec(cQuery)

		//-- Inclui Log De Erro
		If nCodRet < 0
			Help( ,, ProcName(),, TcSqlError() , 1, 0)
		Else
			//-- Atualiza Tabela De Ocorrencias DUA
			cQuery := ""
			cQuery += " UPDATE	" + RetSqlName("DUA") + " "
			cQuery += " SET		DUA_FLOCTC =  '" + Space(Len(cFilOri))  + "', "
			cQuery += "         DUA_NUMCTC =  '" + Space(Len(cNumCTC))  + "', "
			cQuery += "         DUA_RECDEP =  '4' "	//-- Pendente
			cQuery += " WHERE   DUA_FILIAL =  '" + FWxFilial("DUA")     + "'  "
			cQuery += " 	AND		DUA_FLOCTC =  '" + cFilOri              + "'  "
			cQuery += " 	AND		DUA_NUMCTC =  '" + cNumCTC              + "'  "
			cQuery += " 	AND     DUA_NUMCTE <>  ' ' "
			cQuery += " 	AND		D_E_L_E_T_ =  ' ' "

			//-- Executa Script
			nCodRet:= TcSqlExec(cQuery)

			//-- Inclui Log De Erro
			If nCodRet < 0
				Help( ,, ProcName(),, TcSqlError() , 1, 0)
			EndIf
		EndIf
	EndIf
EndIf


// Verifica se a chamada é feita pelas funções de inclusão ou exclusão.
// ** Mudar quando a Inclusão/Alteração estiver como MVC
If oModel <> Nil //.And. oModel:GetOperation() == MODEL_OPERATION_DELETE
	bIntegEAI := {|oModel| 0  }
EndIf

// Realiza o Commit
If lRet
	lRet := FWFormCommit(oModel,,,,,,bIntegEAI)
EndIf

//----- Contabilição OnLine
If lRet .And. cTmsErp == "0"
	If nOpc ==  MODEL_OPERATION_DELETE .Or. lComplemento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o custo medio e' calculado On Line se            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOnline .And. nTotal > 0
			Pergunte("TM250D",.F.)
			If nOpc ==  MODEL_OPERATION_DELETE //-- Exclui Contrato
				lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
				lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se ele criou o arquivo de prova ele deve gravar o rodape'    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RodaProva(nHdlPrv,nTotal)
			SaveInter()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lan‡amento Cont bil                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cA100Incl(cArquivo,nHdlPrv,3,cLoteCTC,lDigita,lAglutina)
			RestInter()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a Data da Contabilizacao no SDG            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aRecSDGBai)
			SDG->(dbGoTo(aRecSDGBai[nCntFor]))
			RecLock('SDG',.F.)
			If nOpc ==  MODEL_OPERATION_DELETE
				SDG->DG_DTLANC := Ctod("")
			Else
				SDG->DG_DTLANC := dDataBase
			EndIf
			MsUnLock()
		Next

		For nCntFor := 1 To Len(aRecSDGEmi)
			SDG->(dbGoTo(aRecSDGEmi[nCntFor]))
			RecLock('SDG',.F.)
			If nOpc ==  MODEL_OPERATION_DELETE
				SDG->DG_DTLAEMI := Ctod("")
			Else
				SDG->DG_DTLAEMI := dDataBase
			EndIf
			MsUnLock()
		Next
	EndIf
EndIf


//--RestArea(aAreaDTY) //-- Removido Por Eduardo Alberti -> Deve Retornar Posicionado No Novo Registro Criado! (Necessidade TMSA152).

Return lRet


/*/{Protheus.doc} A250DelDTY
//TODO Descrição auto-gerada.
@author caio.y
@since 10/01/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function A250DelDTY( cFilOri ,  cViagem , cNumCTC , cNumPC , cCodFor , cLojFor , cCodVei , lPrincipal, lIntegra, cTitFrete)

Local nCount             := 1
Local cPrefixo           := ""
Local lTMSOPdg           := SuperGetMV('MV_TMSOPDG' ,,'0') == '2'
Local cTmsERP            := SuperGetMV("MV_TMSERP",,'0')
Local lRepom             := SuperGetMV('MV_TMSOPDG',,'0') == '2' .And. SuperGetMV('MV_VSREPOM',,'1') == '2'
Local lTM250Peri         := ExistBlock('T250PER')
Local lTM250Est          := ExistBlock('TM250EST')
Local lRet               := .T.
Local nOpcx              := 5
Local aArea              := GetArea()
Local aAreaDTY           := DTY->(GetArea())
Local cSeek              := ""
Local aMsgErr            := {}
Local lTpFrota           := DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local aSetKey            := {}

DEFAULT cFilOri          := ""
DEFAULT cViagem          := ""
DEFAULT cNumCTC          := ""
DEFAULT cNumPC           := ""
DEFAULT cCodFor          := ""
DEFAULT cLojFor          := ""
DEFAULT cCodVei          := ""
DEFAULT lPrincipal       := .F. 	//-- Alguns relacionamentos o próprio MVC trata a exclusão
DEFAULT lIntegra         := .T.

DEFAULT cTitFrete		 := ""

//Verifica se o TMS estiver vinculado ao ERP Protheus
If cTmsErp == '0'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as perguntas selecionadas                            ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ mv_par01 - Mostra lancamentos contabeis    ?                 ³
	//³ mv_par02 - Aglutina lancamentos contabeis  ?                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("TM250D",.F.)
	lExibeLanc := Iif(mv_par01 == 2,.F.,.T.)
	lOnline    := Iif(mv_par03 == 2,.F.,.T.)
	Aadd(aSetKey, { VK_F12 , { || Pergunte("TM250D",.T.), lF12 := .T. ,;
										lExibeLanc := Iif(mv_par01 == 2,.F.,.T.),;
										lOnline    := Iif(mv_par03 == 2,.F.,.T.) } } )
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

//-- Verifica o Prefixo do Titulo
cPrefixo := TMA250GerPrf(cFilAnt)

//-- Deletar Composicao do Frete
A250DelDVP( cFilOri , cViagem, cNumCTC )

//-- Deletar histórico acrescimo/decrescimo
A250DelDDN( cFilOri , cViagem, cNumCTC )

//-- Se o Contrato de Carreteiro tem Pedido de Compra vinculado, verificar se o Ped. de compra
//-- foi baixado; Se sim, nao permitir a exclusao do contrato de carreteiro
If cTmsERP == "0"
	//-- Deletar pedidos de compra vinculados
	lRet	:= A250DelSC7( cCodFor, cLojFor , cNumPC )
	DTQ->(dbSetOrder(2))

	If lRet .And. DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ))
		DTR->(dbSetOrder(3))

		If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem + cCodVei ) )
			//-- Se o Credor do Adiantamento nao for o proprietario do veiculo, deletar
			//-- o titulo de Adiantamento gerado
			DA3->(dbSetOrder(1))
			DA3->(MsSeek(xFilial('DA3')+ cCodVei ))

			If !Empty(DTR->DTR_CODFOR) .And. !Empty(DTR->DTR_LOJFOR)
				cCodFor 	:= DTR->DTR_CODFOR
				cLojFor 	:= DTR->DTR_LOJFOR
			Else
				cCodFor 	:= DA3->DA3_CODFOR
				cLojFor	 	:= DA3->DA3_LOJFOR
			EndIf

		EndIf

		//--Chama rotina de exclusão de títulos do ERP Protheus
		lRet := A250FinPrt(cPrefixo, cCodFor ,cLojFor, cNumCTC , lRepom, @aMsgErr, cFilOri, cViagem )
	EndIf

ElseIf cTmsERP == '1'

    DTY->(DbSetOrder(1)) //-- DTY_FILIAL+DTY_NUMCTC
    If DTY->(MsSeek(xFilial("DTY") + cNumCTC ))
		If lIntegra
			lRet := A250FinDTS(cPrefixo, cCodFor, cLojFor, cNumCTC, lRepom,@aMsgErr,(nOpcx==5), cFilOri, cViagem  )
		EndIf
	Else
		lRet := .F.
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o contrato possua integracao com REPOM, verifica se pode continuar com a exclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTY->(DbSetOrder(1)) //-- DTY_FILIAL+DTY_NUMCTC
If DTY->(MsSeek(xFilial("DTY") + cNumCTC ))
	If lRet .And. lTMSOPdg .And. DTY->DTY_CODOPE == '01'
		lRet := A250ExcRpm(@aMsgErr)
	EndIf
Else
	lRet := .F.
EndIf

If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualização do Complemento de Viagem                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A250AtuDTR(nOpcX,,,,,, cFilOri, cViagem, cNumCTC )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manifesto de Carga                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DTX->(dbSetOrder(3))
	DTX->(MsSeek(cSeek:=xFilial('DTX')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
	Do While !DTX->(Eof()) .And. DTX->DTX_FILIAL+DTX->DTX_FILORI+DTX->DTX_VIAGEM == cSeek
		RecLock("DTX",.F.)
		DTX->DTX_NUMCTC := CriaVar('DTX_NUMCTC',.F.)
		DTX->(MsUnLock())
		DTX->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estorna o Movim. de Custo de Transporte                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A250EstSDG(cNumCTC, cFilOri, cViagem)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estorna as viagens geradas a partir do contrato de carreteiro           ³
	//³Estorna contrato de carreteiro           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A250EstVia(cNumCTC, cFilOri, cViagem)

	If lTpFrota .And. cTmsErp == '0'
		Tmsa253Exc(DTY->DTY_NUMCTC,DTY->DTY_FILORI,DTY->DTY_VIAGEM)
	EndIf

	If nOpcx == 5 .And. DTY->DTY_TIPCTC == "2"//--Verficação de tipo de contrato para constar a geracao por período.
		//-- Ponto de entrada dentro do loop em caso de geração por período, apos a exclusão do DTY.
		If lTM250Peri
			ExecBlock('T250PER',.F.,.F.,{ cFilOri , cViagem , cNumCTC })
		EndIf
	EndIf

Else

	#IFDEF TOP
		DisarmTransaction()
	#ENDIF

EndIf

If lTM250Est
	ExecBlock('TM250EST',.F.,.F.,{cNumCTC, lRet})
EndIf

RestArea(aAreaDTY)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} A250DelSC7
//TODO Deleta os pedidos de compra
@author caio.y
@since 10/01/2017
@version undefined

@type function
/*/
Static Function A250DelSC7(cCodFor, cLojFor , cNumPC )
Local lRet		:= .T.

Private	lMsErroAuto	:= .F.

Default cCodFor		:= ""
Default cLojFor		:= ""
Default cNumPC		:= ""

If !Empty(cNumPC)
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial('SA2')+ cCodFor + cLojFor ))
		//-- Se o fornecedor for Pessoa Juridica, excluir o Pedido de Compra Gerado
		If SA2->A2_TIPO $ 'J/F'
			SC7->(dbSetOrder(1))
			If SC7->(MsSeek(xFilial('SC7') + cNumPC ))

				aCabec := {}
				aadd(aCabec,{"C7_NUM"  , SC7->C7_NUM  })

				MATA120(1,aCabec,{},5)

				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					lRet	:= .F.
				Else
					lRet	:= .T.
				EndIf

			EndIf
		EndIf
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} LoadField
//TODO Carrega o cabeçalho da DTY
@author caio.y
@since 05/12/2016
@version undefined
@param oModel, object, descricao
@param lCopy, logical, descricao
@type function
/*/
Static Function LoadField(oModel,lCopy)
Local aRet		:= FormLoadField(oModel,lCopy)
Local aStruct	:= {}
Local nPos		:= 0
Local nCount	:= 0
Local cCampo	:= ""
Local lComplemento	:= IsInCallStack("TMSA250COM")

Default oModel	:= FwModelActive()
Default lCopy	:= .F.

If lComplemento

	If Len(aCamposDTY) > 0

		aStruct 	:= FwFormStruct(1,"DTY")
		aStruct		:= aStruct:aFields

		For nCount := 1 To Len(aStruct)
			cCampo	:= Upper( RTrim(aStruct[nCount,3]) )
			nPos	:= aScan( aCamposDTY , {|x|x[1] == cCampo } )

			If Upper( cCampo ) <> "DTY_NUMCTC"
				If nPos > 0
					aRet[1,nCount]	:= aCamposDTY[nPos,2]
				Else
					aRet[1,nCount]	:= CriaVar(cCampo,.T.)
				EndIf
			EndIf

		Next nCount

	EndIf

EndIf

Return aRet

/*/{Protheus.doc} LoadGrid

//TODO Carrega o grid
@author caio.y
@since 16/11/2016
@version 1.0
@param oModel, object, descricao
@param lLoad, logical, descricao
@param cTabela, characters, descricao
@type function
@obs A função TMSA250Fin que carrega os títulos foi alterada para o grid de títulos ser carregado em conjunto com o modelo de dados
/*/
Static Function LoadGrid( oModel , lCopy , cTabela )
Local aRet			:= {}
Local cAliasQry		:= ""
Local cQuery		:= ""
Local nOpc      	:= oModel:GetOperation()
Local cTptCtc   	:= GetMV('MV_TPTCTC' ,,'')								//-- Verifica o parametro referente ao Tipo do Contrato de Carreteiro
Local cUniao    	:= PadR( GetMV("MV_UNIAO",,""), Len(SA2->A2_COD) )		//-- Codigo para pagamento do Imposto de Renda
Local cMunic    	:= PadR( GetMV("MV_MUNIC",,""), Len(SA2->A2_COD) )		//-- Codigo para Recolher o ISS
Local cForINSS  	:= PadR( GetMV("MV_FORINSS",,""), Len(SA2->A2_COD) )	//-- Fornecedor padrao para Titulos de INSS
Local cForSEST  	:= PadR( GetMV("MV_FORSEST",,""), Len(SA2->A2_COD) )	//-- Fornecedor padrao para Titulos de SEST
Local cPrefDeb		:= ""
Local cFilCTC		:= ""
Local cPrefCTC		:= ""
Local cCodDesCTC 	:= TMSA250Var("DES") // Codigo de Despesa de contrato de carreteiro
Local cCodDesPDG 	:= Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio
Local cCodDesPRE 	:= Padr( GetMV("MV_DESPRE"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Premio
Local aArea			:= GetArea()
Local aAreaDTY		:= DTY->( GetArea() )
Local cFilOri		:= DTY->DTY_FILORI
Local cViagem		:= DTY->DTY_VIAGEM
Local cNumCTC		:= DTY->DTY_NUMCTC

Default oModel		:= FwModelActive()
Default lCopy		:= .F.
Default cTabela		:= "SE2" //-- Títulos

If !lCopy

	If cTabela == "SE2"

		//--Verifica a filial do contrato de
		//--carreteiro X filial do titulo SE2:
		cFilCTC := xFilial('SE2', DTY->DTY_FILORI)

		//--Prefixo dos titulos:
		cPrefCTC 	:= TMA250GerPrf( cFilAnt )

		cAliasQry 	:= GetNextAlias()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OBTEM OS DADOS DO TITULO PRINCIPAL E OS³
		//³DADOS DOS TITULOS DE IMPOSTOS          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cQuery 	:= " SELECT  * "
		cQuery 	+= "  	FROM  " + RetSqlName("SE2") + " SE2 "
		cQuery	+= "   	WHERE E2_FILIAL 	= '" + IIf( Empty( FwFilial("SE2") ), xFilial("SE2") , DTY_FILORI ) + "' "
		cQuery	+= "    AND E2_FORNECE	 	IN ('" + DTY->DTY_CODFOR + "' , '" + cUniao + "' ,  '" + cMunic + "' , '" + cForINSS + "' ,  '" + cForSEST + "') "
		cQuery	+= "    AND E2_LOJA 	 	IN ('" + DTY->DTY_LOJFOR + "', '" + StrZero(0,Len(SE2->E2_LOJA)) + "') "
		cQuery	+= "    AND E2_PREFIXO 		= '" + cPrefCTC + "' "
		cQuery	+= "    AND E2_NUM 			= '" + DTY->DTY_NUMCTC + "' "
		cQuery	+= "   	AND SE2.D_E_L_E_T_ 	= ' ' "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VERIFICA SE HOUVE A GERACAO DE TITULOS ³
		//³NA FILIAL DE DEBITO                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( cTptCtc ) .And. DTY->DTY_FILDEB <> cFilAnt

			cPrefDeb := TMA250GerPrf( DTY->DTY_FILDEB )

			cQuery	+= " UNION ( "
			cQuery	+= " SELECT * "
			cQuery 	+= "  	FROM  " + RetSqlName("SE2") + " SE2FILDEB "
			cQuery	+= "   	WHERE E2_FILIAL 	= '" 	+ DTY->DTY_FILDEB + "' "
			cQuery	+= "    AND E2_FORNECE	 	= '" 	+ DTY->DTY_CODFOR + "'  "
			cQuery	+= "    AND E2_LOJA 	 	= '" 	+ DTY->DTY_LOJFOR + "' "
			cQuery	+= "    AND E2_PREFIXO 		= '" 	+ cPrefDeb + "' "
			cQuery	+= "    AND E2_NUM 			= '" 	+ DTY->DTY_NUMCTC + "' "
			cQuery	+= "   	AND SE2FILDEB.D_E_L_E_T_ 	= ' ' ) "

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OBTEM OS DADOS DO TITULO GERADO CONTRA ³
		//³O FAVORECIDO (SE HOUVER)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( DTY->DTY_CODFAV ) .And. !Empty( DTY->DTY_LOJFAV )

			cQuery	+= " UNION ( "
			cQuery	+= " SELECT * "
			cQuery 	+= "  	FROM  " + RetSqlName("SE2") + " SE2CONTRA "
			cQuery	+= "   	WHERE E2_FILIAL 	= '" 	+ cFilCTC		  + "' "
			cQuery	+= "    AND E2_FORNECE	 	= '" 	+ DTY->DTY_CODFAV + "'  "
			cQuery	+= "    AND E2_LOJA 	 	= '" 	+ DTY->DTY_LOJFAV + "' "
			cQuery	+= "    AND E2_PREFIXO 		= '" 	+ cPrefCTC + "' "
			cQuery	+= "    AND E2_NUM 			= '" 	+ DTY->DTY_NUMCTC + "' "
			cQuery	+= "   	AND SE2CONTRA.D_E_L_E_T_ 	= ' ' ) "

		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OBTEM OS DADOS DOS TITULOS DE ADTO OU PEDÁGIO    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DTY->DTY_ADIFRE > 0 .Or. DTY->DTY_VALPDG > 0

			cQuery	+= " UNION ( "
			cQuery	+= " SELECT * "
			cQuery 	+= "  	FROM  " + RetSqlName("SE2") + " SE2ADTO "
			cQuery	+= "   	WHERE E2_FILIAL 	= '" 	+ xFilial('SE2')  + "' "
			cQuery	+= "    AND E2_FORNECE	 	= '" 	+ Iif( !Empty( DTY->DTY_CODFAV ) .And. !Empty( DTY->DTY_LOJFAV ), DTY->DTY_CODFAV, DTY->DTY_CODFOR ) + "'  "
			cQuery	+= "    AND E2_LOJA 	 	= '" 	+ Iif( !Empty( DTY->DTY_CODFAV ) .And. !Empty( DTY->DTY_LOJFAV ), DTY->DTY_LOJFAV, DTY->DTY_LOJFOR ) + "' "
			cQuery	+= "    AND E2_PREFIXO 		= '" 	+ cPrefCTC + "' "
			cQuery	+= "    AND E2_NUM 			= '" 	+ DTY->DTY_VIAGEM + "' "
			cQuery	+= "   	AND SE2ADTO.D_E_L_E_T_ 	= ' ' ) "

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OBTEM OS DADOS DOS TITULOS NDF         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery	+= " UNION ( "
		cQuery	+= " SELECT * "
		cQuery 	+= "  	FROM  " + RetSqlName("SE2") + " SE2ADTO "
		cQuery	+= "   	WHERE E2_FILIAL 	= '" 	+ xFilial('SE2')  + "' "
		cQuery	+= "    AND E2_FORNECE	 	= '" 	+ DTY->DTY_CODFOR + "'  "
		cQuery	+= "    AND E2_LOJA 	 	= '" 	+ DTY->DTY_LOJFOR + "' "
		cQuery	+= "    AND E2_PREFIXO 		= '" 	+ cPrefCTC + "' "
		cQuery	+= "    AND E2_NUM 			= '" 	+ DTY->DTY_VIAGEM + "' "
		cQuery	+= "    AND E2_TIPO         = '"	+ Padr( "NDF", Len( SE2->E2_TIPO ) ) + "' "
		cQuery	+= "   	AND SE2ADTO.D_E_L_E_T_ 	= ' ' ) "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OBTEM OS DADOS DOS TITULOS TAX         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery	+= " UNION ( "
		cQuery	+= " SELECT *  "
		cQuery 	+= "  	FROM  " + RetSqlName("SE2") + " SE2ADTO "
		cQuery	+= "   	WHERE E2_FILIAL 	= '" 	+ xFilial('SE2')  + "' "
		cQuery	+= "    AND E2_FORNECE	 	= '" 	+ DTY->DTY_CODFOR + "'  "
		cQuery	+= "    AND E2_LOJA 	 	= '" 	+ DTY->DTY_LOJFOR + "' "
		cQuery	+= "    AND E2_PREFIXO 		= '" 	+ cPrefCTC + "' "
		cQuery	+= "    AND E2_NUM 			= '" 	+ DTY->DTY_VIAGEM + "' "
		cQuery	+= "    AND E2_TIPO         = '"	+ Padr( "TAX", Len( SE2->E2_TIPO ) ) + "' "
		cQuery	+= "   	AND SE2ADTO.D_E_L_E_T_ 	= ' ' ) "
		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

		aRet := FWLoadByAlias( oModel, cAliasQry )

	ElseIf cTabela == "DT8"


		cAliasQry 	:= GetNextAlias()

		cQuery := "SELECT *  "
		cQuery += "  FROM " + RetSqlName("DT8") + " DT8 "
		cQuery += "  	INNER JOIN " + RetSqlName("DT3") + " DT3 "
		cQuery += "   		ON DT3_FILIAL = '" + xFilial("DT3") + "' "
		cQuery += "   		AND DT3_CODPAS = DT8_CODPAS "
		cQuery += "   		AND DT3_RECEIT = '1' "
		cQuery += "   		AND DT3.D_E_L_E_T_ = ' ' "
		cQuery += "   WHERE DT8_FILIAL = '" + xFilial("DT8") + "' "
		cQuery += "   	AND DT8_FILDOC = '" 	+ FwFldGet("DJC_FILDOC") + "'  "
		cQuery += "   	AND DT8_DOC    = '" 	+ FwFldGet("DJC_DOC") + "'  "
		cQuery += "   	AND DT8_SERIE  = '" 	+ FwFldGet("DJC_SERIE") + "'  "
		cQuery += "   	AND DT8_CODPAS <> 'TF' "
		cQuery += "   	AND DT8.D_E_L_E_T_ = ' ' "
		If Empty( FwFldGet("DJC_DOC") )
			cQuery += "   	AND DT8.D_E_L_E_T_ = '*' " //condição para retorno vazio da query
		EndIf

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

		aRet 	:= FWLoadByAlias( oModel, cAliasQry )


	EndIf

EndIf

RestArea(aAreaDTY)
RestArea(aArea)
Return aRet


/*/{Protheus.doc} TMSA250StTit
//TODO Descrição auto-gerada.
@author caio.y
@since 16/11/2016
@version undefined
@param nRegSE2, numeric, descricao
@param cTipoRet, characters, descricao
@type function
/*/
Static Function TMSA250StTit( nRegSE2 )
Local cRet     	:= NIL
Local aLegenda 	:= {}
Local nCount   	:= 0
Local aArea    	:= GetArea()
Local aAreaSE2 	:= SE2->( GetArea() )
Local lSdAcres  := .F.

Default nRegSE2		:= 0

SE2->( MsGoTo( nRegSE2 ) )
lSdAcres := Type('SE2->E2_SDACRES') == 'N'

aLegenda := Fa040Legenda("SE2")
For nCount := 1 To Len( aLegenda )
	If !('E2_SDACRES' $ aLegenda[nCount,1] ) .Or. lSdAcres //--Tratamento realizado devido a erro no campo E2_SDACRES.
		If SE2->( &(aLegenda[nCount,1]) )
			cRet	:= aLegenda[nCount,2]
			Exit
		EndIf
	EndIf
Next

RestArea( aArea )
RestArea( aAreaSE2 )
Return( cRet )

//-------------------------------------------------------------------
/* {Protheus.doc} a250BUTTON

@author  Caio Murakami
@since   28/09/2015
@version 1.0
*/
//-------------------------------------------------------------------
Static Function a250BUTTON( oPanel )
Local cFil		:= ""
Local cPrefixo	:= ""
Local cNum		:= ""

//-- Ancoramos os objetos no oPanel passado
@ 17 , 10 Button STR0088 Size 35, 10 Pixel Of oPanel Action( FA040Legenda('SE2',0) ) 	//--"Legenda"
DEFINE SBUTTON FROM 30, 10 TYPE 15 ACTION TMSA250Det() ENABLE  OF oPanel 				//-- Visualizar

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA250DelTit³ Autor ³ Patricia A. Salomao ³ Data ³07.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deleta os Titulos a Pagar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA250DelTit()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Prefixo do Titulo                                   ³±±
±±³          ³ExpC2 - Numero do  Titulo                                   ³±±
±±³          ³ExpC3 - Filial de Debito                                    ³±±
±±³          ³ExpC4 - Codigo do Proprietario do Veiculo  (Fornecedor)     ³±±
±±³          ³ExpC5 - Loja do Proprietario                                ³±±
±±³          ³ExpC6 - Codigo do Favorecido                                ³±±
±±³          ³ExpC7 - Loja do Favorecido                                  ³±±
±±³          ³ExpC8 - Parcela do Titulo                                   ³±±
±±³          ³ExpN9 - Rotina de Origem 0=Default;1=Contrato de Carreteiro ³±±
±±³          ³	     - 2=Liberacao de Contrato Carreteiro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240 / TMSA250                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMA250DelTit(cPrefixo, cContrat, cFilDeb, cCodForn, cLojForn, cCodFav, cLojFav, cParcela, nAcao, cTypeMsg, cSubTipMsg,cMsgError, nAcaoDel)

Local aArea      := GetArea()
Local lRet       := .T.
Local cChave     := ""
Local cMunic     := GetMV("MV_MUNIC",,"")    // Codigo para Recolher o ISS
Local cUniao     := GetMV("MV_UNIAO",,"")    // Codigo para pagamento do Imposto de Renda
Local cForINSS   := GetMV("MV_FORINSS",,"")  // Fornecedor padrao para Titulos de INSS
Local cForSEST   := GetMV("MV_FORSEST",,"")  // Fornecedor padrao para Titulos de SEST
Local aDados     := {}
Local bWhile     := {|| .T. }
Local aAreaSE2   := SE2->(GetArea())
Local lExibeLanc := .F.
Local lOnline    := .F.
Local cTituloPA  := Padr("PA",Len( SE2->E2_TIPO ) ) //--Titulo do Tipo "PA"
Local lCond      := .T.
Local cTipUso    := IIf(!lTabDFI .Or. nModulo==43,"1","2")
Local lMsBlQl    := .F. //-- Verifica se o titulo está bloqueado
Local cTipPdg    := Padr( "PDG", Len( SE2->E2_TIPO ) )
Local cTpTitTax	 := SuperGetMv('MV_TPTTAX',,"")
Local lLibCTC    := SuperGetMv("MV_LIBCTC",,.F.)
Local lBlqUsu    := .F.
Local cQuery     := ""
Local cAliasSE2  := ""
Local lPA_No_CTC := .F.
Local cFilOri 		:= Iif(IsInCallStack('TMSA310EST') .Or. IsInCallStack('TMSA240DelTit'), DTR->DTR_FILORI,DTY->DTY_FILORI)
Local cViagem		:= Iif(IsInCallStack('TMSA310EST') .Or. IsInCallStack('TMSA240DelTit'), DTR->DTR_VIAGEM,DTY->DTY_VIAGEM)

Default cPrefixo 	:= ""
Default cContrat 	:= ""
Default cFilDeb  	:= ""
Default cCodForn 	:= ""
Default cLojForn 	:= ""
Default cCodFav  	:= ""
Default cLojFav  	:= ""
Default cParcela 	:= ""
Default nAcao    	:= 0
Default cTypeMsg 	:= '2'
Default cSubTipMsg 	:= '201'
Default cMsgError   := ""
Default nAcaoDel	:= 1
Private lMsErroAuto := .F.


     //+----------------------------------------------------------------
     //| Exclusão do Titulo gerado via Integração EAI
     //+----------------------------------------------------------------
     If cTMSERP == "1"
          If lEAIFunOK .And. (!lLibCTC .Or. IsInCallStack("TMSA310EST") .Or. nAcao == 2)
               //Instância classe para envio da mensagem ao ERP Datasul
			If !Empty(cCodFav+cLojFav) .And. cCodFav+cLojFav <> cCodForn + cLojForn
				cCodForn := cCodFav
				cLojForn := cLojFav
			EndIf
			aEAIRet := TmA250Clas( cFilOri,cViagem,cContrat,0 /*nValDoc Frete*/, 0/*base imp.*/,0/*Vlr Pdg*/,0/*nTotValAdi*/,0/*Valor NDF*/,0/*nINSSRet*/,0/*nAliqISS*/,cCodForn,cLojForn,""/*cCnpjForn*/, cFilDeb, ;
			dDatabase, dDatabase, "", /*delete or upsert*/ ,/*TransctionName EAI*/,cTypeMsg,cSubTipMsg, .F./*lGerTitulo*/, .F., /*cStatusPag*/, .T. )
			lRet := IIf(ValType(aEAIRet) == "U",.F.,aEAIRet[1])

			If lRet == .F.
			     If ValType(aEAIRet) != "U" .And. Len(aEAIRet) > 1
			          cMsgError := aEAIRet[2]
			     Else
			          cMsgError := STR0249
			     EndIf
			EndIf
          EndIf

     //+----------------------------------------------------------------
     //| Integração Financeira Protheus
     //+----------------------------------------------------------------
     ELSE

     	  If !Empty(cFilDeb)
               cChave := If(!Empty(FwFilial("SE2")), cFilDeb, xFilial("SE2"))+cPrefixo+Padr(cContrat,Len(SE2->E2_NUM))+cParcela
          Else
               cChave := xFilial('SE2')+cPrefixo+Padr(cContrat,Len(SE2->E2_NUM))+cParcela
          EndIf

          If Empty(cParcela)
               bWhile   := {|| SE2->(!Eof()) .And. SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM==cChave}
          Else
               bWhile   := {|| SE2->(!Eof()) .And. SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA==cChave}
          EndIf

          Pergunte("TM250D",.F.)
          lExibeLanc := Iif(mv_par01 == 2,.F.,.T.)
          lOnline    := Iif(mv_par03 == 2,.F.,.T.)

          Pergunte("FIN080",.F.)

          SE2->( dbSetOrder(1) )
          If SE2->( DbSeek(cChave) )

				//-- Pesquisa PA gerado a posterior (na geração da carta frete).
				//-- Se encontrar exclui o PA tambem.
				cAliasSE2 := GetNextAlias()
				cQuery := "SELECT 1 "
				cQuery += "  FROM " + RetSqlName("SE2") + " SE2 "
				cQuery += " WHERE E2_FILIAL  = '" + xFilial("SE2") + "' "
				cQuery += "   AND E2_FORNECE = '" + SE2->E2_FORNECE + "' "
				cQuery += "   AND E2_LOJA    = '" + SE2->E2_LOJA + "' "
				cQuery += "   AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "
				cQuery += "   AND E2_NUM     = '" + SE2->E2_NUM + "' "
				If nAcaoDel == 1
					cQuery += "   AND E2_TIPO    = '" + Padr("PA",Len(SE2->E2_TIPO)) + "' "
				Else
					cQuery += "   AND E2_TIPO    <> '" + Padr("PA",Len(SE2->E2_TIPO)) + "' "
				EndIf
				cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSE2,.T.,.T.)
				If (cAliasSE2)->(!Eof())
					lPA_No_CTC := .T.
				EndIf
				(cAliasSE2)->(DbCloseArea())
				RestArea(aArea)

               While Eval(bWhile)
                    //-- Tem que posicionar no Titulo Principal (Gerador), pois ao deleta-lo, automaticamente
                    //-- serao deletados todos os Titulos de impostos
                    //--Se nAcao == 1, chamada pelo Contrato de Carreteiro, nao pode ser excluido o titulo do tipo 'PA', se existir
                    //--Se nAcao == 2, chamada pela Liberacao do Contrato de Carreteiro não pode ser excluido o titulo do PDG, se existir.
                    If	AllTrim(SE2->E2_FORNECE)$cUniao   .Or. AllTrim(SE2->E2_FORNECE)$cMunic   .Or. ;
                    AllTrim(SE2->E2_FORNECE)$cForINSS .Or. AllTrim(SE2->E2_FORNECE)$cForSEST .Or. ;
                    (nAcao == 0 .AND. nAcaoDel == 2 .AND. AllTrim(SE2->E2_TIPO) == AllTrim(cTituloPA)) .OR.;
                    ((nAcao == 1 .Or. nAcaoDel == 2 ) .And. !lPA_No_CTC .And. AllTrim(SE2->E2_TIPO) == AllTrim(cTituloPA)) .Or. ;
					(nAcao == 2 .And. ( AllTrim(SE2->E2_TIPO) == cTipPdg .Or. AllTrim(SE2->E2_TIPO) == cTpTitTax) )
                         SE2->(dbSkip())
                         Loop
                    EndIf
                    aAreaSE2 := SE2->(GetArea())
                    If cTipUso == "1" //--Viagem
                         lCond :=	SE2->E2_FORNECE+SE2->E2_LOJA == cCodForn+cLojForn .Or. ;
                         SE2->E2_FORNECE+SE2->E2_LOJA == cCodFav+cLojFav   .Or. ;
                         SE2->E2_FORNECE+SE2->E2_LOJA == DTR->DTR_CREADI+DTR->DTR_LOJCRE
                    ElseIf cTipUso == "2" .And. lTabDFI //--OMS com Frete Embarcador
                         lCond :=	SE2->E2_FORNECE+SE2->E2_LOJA == cCodForn+cLojForn .Or. ;
                         SE2->E2_FORNECE+SE2->E2_LOJA == cCodFav+cLojFav
                    EndIf

                    If lCond
                         lF050Auto := .T.
                         //-- Cancela a Baixa
                         If !Empty(SE2->E2_BAIXA)
                              lF080Auto := .T.
                              aDados := {}
                              AADD(aDados,{"E2_FILIAL" ,  SE2->E2_FILIAL 	,Nil})
                              AADD(aDados,{"E2_PREFIXO" , SE2->E2_PREFIXO	,Nil})
                              AADD(aDados,{"E2_NUM"     , SE2->E2_NUM   	,Nil})
                              AADD(aDados,{"E2_PARCELA" , SE2->E2_PARCELA	,Nil})
                              AADD(aDados,{"E2_TIPO"    , SE2->E2_TIPO   	,Nil})
                              AADD(aDados,{"E2_FORNECE" , SE2->E2_FORNECE	,Nil})
                              AADD(aDados,{"E2_LOJA"    , SE2->E2_LOJA   	,Nil})

                              MSExecAuto({| a,b,c,d,e,f | FINA080(a,b,c,d,e,f)} ,aDados,5,,,lExibeLanc,lOnline)//3 para baixar ou 5 para cancelar a baixa.
                              If lMsErroAuto
                                   MostraErro()
                                   lRet := .F.
                              EndIf
                         EndIf
                         If lRet
                              //-- Apagar titulo
                              aDados := {}
                              AADD(aDados,{"E2_FILIAL" ,  SE2->E2_FILIAL 	,Nil})
                              AADD(aDados,{"E2_PREFIXO" , SE2->E2_PREFIXO	,Nil})
                              AADD(aDados,{"E2_NUM"     , SE2->E2_NUM    	,Nil})
                              AADD(aDados,{"E2_PARCELA" , SE2->E2_PARCELA	,Nil})
                              AADD(aDados,{"E2_TIPO"    , SE2->E2_TIPO   	,Nil})
                              AADD(aDados,{"E2_FORNECE" , SE2->E2_FORNECE	,Nil})
                              AADD(aDados,{"E2_LOJA"    , SE2->E2_LOJA   	,Nil})

								If lTM250Blq
									lBlqUsu := ExecBlock("TM250BLQ",.F.,.F.,{lMsBlQl,5})
									If ValType(lBlqUsu) != "L"
										lBlqUsu := lMsBlQl
									EndIf
									lMsBlQl := lBlqUsu
								EndIf

                              MsExecAuto({| a,b,c,d,e,f,g,h,i,j| FINA050(a,b,c,d,e,f,g,h,i,j) },aDados,,5,,, lExibeLanc, lOnline,,,lMsBlQl) //Na exclusao nao mostra a tela de Lancamentos
                              If lMsErroAuto
                                   MostraErro()
                                   lRet := .F.
                              EndIf
                         EndIf
                    EndIf
                    RestArea(aAreaSE2)
                    If !lRet
                         Exit
                    EndIf
                    SE2->(dbSkip())
               EndDo
          EndIf
     EndIf //| Fecha a tag If cTMSERP == "1"
Pergunte("TM250D",.F.)

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A250PsqAdiºAutor  ³Leandro Paulino     º Data ³  19/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa todos NDF e PA da viagem do contrato              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA25/TMSA251                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A250PsqAdi(cFornec,cLoja,cPrefixo,cFilContr,cNrContr,cViagem,cCarga,nVlrAdiant,cTipUso,cPrefContr,cCtrComp,nOpc)

Local   cSepNeg    := If("|"$MV_CPNEG,"|",",")
Local   cSepRec    := If("|"$MVPAGANT,"|",",")
Local   cAliasQry  := GetNextAlias()
Local   aRecNDF    := {}
Local   aArea      := GetArea()
Local   lTMSCTCA   := .F.
Local   cQuery	   := ''
Local   bWhile	   := {||}

Default cFornec    := ''
Default cLoja      := ''
Default cPrefixo   := ''
Default cPrefContr := ''
Default cFilContr  := ''
Default cNrContr   := ''
Default cViagem    := ''
Default cCarga     := ''
Default nVlrAdiant := 0
Default cTipUso    := '1'
Default cCtrComp   := ''
Default nOpc	   := 4

If cCtrComp == '5'   //Contrato Complementar
	lTMSCTCA:= SuperGetMV( 'MV_TMSCTCA',, .F. )  //Considera somente os valores de abatimentos especificos do contrato complementar.
EndIf

#IFDEF TOP
	cQuery := " SELECT E2_VALOR,E2_SALDO, R_E_C_N_O_ E2_RECNO "
	cQuery += "   FROM " + RetSqlName("SE2")
	If FWModeAccess('SE2') == 'E'
		cQuery += "      WHERE E2_FILIAL       IN ('" + cFilAnt + "','" +cFilContr + "') "
	Else
		//--Se estiver compartilhada olha xFilial("SE2")
		cQuery += "      WHERE E2_FILIAL       = '" + xFilial("SE2") 	+ "' "
	EndIf
	cQuery += "     AND E2_FORNECE = '" + cFornec  + "' "
	cQuery += "     AND E2_LOJA    = '" + cLoja    + "' "
	cQuery += "     AND E2_PREFIXO = '" + cPrefixo + "' "
	cQuery += "     AND (( E2_NUM     = '" + cNrContr + "' "
	cQuery += "     AND E2_TIPO IN " + FormatIn(MV_CPNEG,cSepNeg) + ")"
	If lTMSCTCA
		cQuery += ") "
	Else
		cQuery += "     OR (E2_NUM  IN " + FormatIn(IIf(cTipUso=="1",cViagem,cCarga),"|")
		cQuery += "     AND E2_TIPO IN " + FormatIn(MVPAGANT,cSepRec)  + " )) "
	EndIf
	If nOpc <> 5
		cQuery += "     AND E2_SALDO   > 0 "
	EndIf
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	If cPrefContr <> cPrefixo
		cQuery += "     UNION ALL "
		cQuery += " SELECT E2_VALOR,E2_SALDO, R_E_C_N_O_ E2_RECNO "
		cQuery += "   FROM " + RetSqlName("SE2")
		If FWModeAccess('SE2') == 'E'
			cQuery += "      WHERE E2_FILIAL       IN ('" + cFilAnt + "','" +cFilContr + "') "
		Else
			//--Se estiver compartilhada olha xFilial("SE2")
			cQuery += "      WHERE E2_FILIAL       = '" + xFilial("SE2") + "' "
		EndIf
		cQuery += "     AND E2_FORNECE = '" + cFornec  + "' "
		cQuery += "     AND E2_LOJA    = '" + cLoja    + "' "
		cQuery += "     AND E2_PREFIXO = '" + cPrefContr + "' "
		cQuery += "     AND (( E2_NUM     = '" + cNrContr + "' "
		cQuery += "     AND E2_TIPO IN " + FormatIn(MV_CPNEG,cSepNeg) + ")"
		If lTMSCTCA
			cQuery += ") "
		Else
			cQuery += "     OR (E2_NUM  IN " + FormatIn(IIf(cTipUso=="1",cViagem,cCarga),"|")
			cQuery += "     AND E2_TIPO IN " + FormatIn(MVPAGANT,cSepRec)  + " )) "
		EndIf
		If nOpc <> 5
			cQuery += "     AND E2_SALDO   > 0 "
		EndIf
		cQuery += "     AND D_E_L_E_T_ = ' ' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	bWhile := {|| (cAliasQry)->(!Eof()) }
#ELSE
	cAliasQry := "SE2"
	cFiltro := 	"(E2_FILIAL == '"+xFilial( "SE2" )+"' .And. E2_FORNECE == '"+cFornec+ ;
					"' .And. E2_LOJA == '"+cLoja+ "' .And. E2_PREFIXO == '"+cPrefixo+ ;
					"' .And. (E2_NUM == '"+cNrContr+"' .And. E2_TIPO IN  "+FormatIn(MV_CPNEG,cSepNeg)+ ;
					" .Or. (E2_NUM IN '"+cViagem+"' .And. E2_TIPO IN "+FormatIn(MVPAGANT,cSepRec)+ ;
					" .And. E2_SALDO > 0)  .Or. (E2_FILIAL == '"+cFilContr+"' .And. E2_FORNECE == '"+cFornec+ ;
					"' .And. E2_LOJA == '"+cLoja+ "' .And. E2_PREFIXO == '"+cPrefContr+ ;
					"' .And. (E2_NUM == '"+cNrContr+"' .And. E2_TIPO IN  "+FormatIn(MV_CPNEG,cSepNeg)+ ;
					" .Or. (E2_NUM IN '"+cViagem+"' .And. E2_TIPO IN "+FormatIn(MVPAGANT,cSepRec)+ ;
					" .And. E2_SALDO > 0)"
	bWhile := {|| (cAliasQry)->(!Eof()) }
	cArqCTC := CriaTrab(Nil,.F.)
	IndRegua("SE2",cArqCTC,IndexKey(),,cFiltro,STR0013) //"Selecionando Documentos ..."
	nIndex := RetIndex("SE2")
	dbSetIndex(cArqCTC+OrdBagExt())
	dbSetOrder(nIndex+1)
	dbGoTop()
#ENDIF
While (cAliasQry)->(!Eof())
	// -- Adiciona no aRecNDF o titulo  para utilizacao na rotina de Compensacao automatica
	Aadd(aRecNDF, (cAliasQry)->E2_RECNO )
	If nOpc <> 5
		nVlrAdiant += (cAliasQry)->E2_SALDO
	Else
		nVlrAdiant += (cAliasQry)->E2_VALOR
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
#IFDEF TOP
	(cAliasQry)->(DbCloseArea())
#ELSE
	dbSelectArea("SE2")
	dbClearFilter()
	RetIndex("SE2")
	If File(cAliasQry+OrdBagExt())
		FErase(cAliasQry+OrdBagExt())
	EndIf
#ENDIF

RestArea(aArea)

Return aRecNDF

/*/{Protheus.doc} A250DTYFIELD
Valida o campo Informado
@author caio.y
@since 01/12/2016
@version undefined
@param cCampo, characters, descricao
@param lValid, logical, descricao
@param cCpoDes, characters, descricao
@param lConsF3, logical, descricao
@param lArray, logical, descricao
@param lTodos, logical, descricao
@param lAllSERTMS, logical, descricao
@type function
/*/
Function A250DTYFIELD(cCampo,lValid,cCpoDes,lConsF3,lArray,lTodos, lAllSERTMS)
Local aRet       := {}
Local cDesc      := ""
Local cTitulo    := ''
Local lRet       := .F.
Local nTmsItem   := 0
Local xRet       := NIL
Local nA         := 0

DEFAULT cCampo := ReadVar()
DEFAULT lValid := .T.
DEFAULT lConsF3:= .F.
DEFAULT lArray := .F.
DEFAULT lTodos := .F.
DEFAULT lAllSERTMS 	:= .F.

If 'DTY_STATUS' $ Upper(cCampo)  //-- Status contrato carreteiro

	lRet := .T.

	AAdd( aRet, {'1', STR0090 }) //-- Em aberto
	AAdd( aRet, {'2', STR0091 }) //-- Aguard. Lib. p/ Pagto
	AAdd( aRet, {'3', STR0092 }) //-- Lib. p/ Pagto
	AAdd( aRet, {'4', STR0094 }) //-- Contr. Quit. com Ped. Compras
	AAdd( aRet, {'5', STR0093 }) //-- Contr. Quitado/Pagto. Realiz
	AAdd( aRet, {'6', STR0148 }) //-- Tit. Fatura
	AAdd( aRet, {'7', STR0157 }) //-- 'Aguardando Confirm. Webserver'
	AAdd( aRet, {'8', STR0158 }) //-- 'Aguardando autoriz pagto'
	Aadd( aRet, {'9', STR0159 }) //-- 'Pagamento Bloqueado
	Aadd( aRet, {'A', STR0246 }) //-- "Contr. Parcial/Pagto. Parcial"
	Aadd( aRet, {'B', STR0291 }) //-- "Contrato Quitado/Aguardando autorização Operadora"

	If !lArray
		If	lConsF3
			cTitulo := FWX3Titulo('DTY_STATUS')
		Else
			If lValid .And. Ascan( aRet, { |x| x[1] ==  AllTrim(M->&(cCampo)) }) == 0
				lRet := .F.
			Else
				nX := Ascan( aRet, { |x| x[1] ==  AllTrim(M->&(cCampo)) })
				If nX > 0
					If cCpoDes !=  NIL
						M->&(cCpoDes) := aRet[ nX, 2 ]
					EndIf
					cDesc := aRet[ nX, 2 ]
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//-- Apresenta a tela para selecao do item.
If	lConsF3 .And. lRet
	nTmsItem := TmsF3Array( {STR0013,STR0014}, aRet, cTitulo ) //"Codigo"###"Descricao"
	If	nTmsItem > 0
		//-- VAR_IXB eh utilizada como retorno da consulta F3 DLC.
		VAR_IXB := aRet[ nTmsItem, 1 ]
	Else
		lRet := .F.
		//-- Se variavel nao estiver inicializada e retornar NIL ocorre erro
		//-- Tratamento para retornar espaço em branco ao invés de NIL
		If VAR_IXB == NIL
			VAR_IXB := ""
		EndIf
	EndIf
EndIf

//-- Tipo do retorno da funcao
If lArray
	xRet := aRet
ElseIf lValid
	xRet := lRet
Else
	xRet := cDesc
EndIf

Return( xRet )

/*/{Protheus.doc} A250ComVld
//TODO Validações para inclusão de complemento
@author caio.y
@since 02/12/2016
@version undefined
@param oModel, object, descricao
@param nOpc, numeric, descricao
@type function
/*/
Static Function A250ComVld(oModel, nOpc)
Local lRet			:= .T.
Local lTMSOPdg    	:= SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local aMovtos		:= {}
Local oMdlDTY		:= Nil

Default oModel		:= FwModelActive()
Default nOpc		:= oModel:GetOperation()

oMdlDTY		:= oModel:GetModel("MdFieldDTY")

If oMdlDTY:GetValue("DTY_VALFRE") <= 0
	lRet	:= .F.
	Help('',1,'TMSA25043',,,05,01) //-- "O Valor do frete deve ser maior que zero"
EndIf

If lRet .And. lTMSOPdg .And. oMdlDTY:GetValue("DTY_CODOPE") == '01'
	If Empty( oMdlDTY:GetValue("DTY_CODMOV") )
		lRet := .F.
		Help('',1,'TMSA25022') //-- 'Codigo do Movimento de Envio nao Informado O Contrato de Carreteiro nao sera gerado'
	Else

		DTQ->(DbSetOrder(2)) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		If DTQ->(MsSeek(xFilial('DTQ') + oMdlDTY:GetValue("DTY_FILORI") + oMdlDTY:GetValue("DTY_VIAGEM") ))

			DEM->(DbSetOrder(2)) //-- DEM_FILIAL+DEM_CODOPE+DEM_CODMOV+DEM_SERTMS+DEM_TIPTRA
			If DEM->(MsSeek(xFilial('DEM') + oMdlDTY:GetValue("DTY_CODOPE") + oMdlDTY:GetValue("DTY_CODMOV") + DTQ->DTQ_SERTMS + DTQ->DTQ_TIPTRA ))

				AAdd(aMovtos, {	xFilial('DTY') + oMdlDTY:GetValue("DTY_NUMCTC") ,;
								oMdlDTY:GetValue("DTY_CODMOV"),;
								oMdlDTY:GetValue("DTY_VALFRE"),;
								DEM->DEM_ACAO,;
								'0'} )

				MsgRun( STR0109,; //-- "Gerando Movimentos para o Contrato...
						STR0100,; //-- "Realizando Comunicação com a Operadora..."
						{||lRet:= TMSIncMov( oMdlDTY:GetValue("DTY_CODOPE"), oMdlDTY:GetValue("DTY_FILORI"), oMdlDTY:GetValue("DTY_VIAGEM"), aMovtos)})


			Else
				Help('',1,'TMSA25024',, oMdlDTY:GetValue("DTY_CODMOV") + ' / ' + DTQ->DTQ_SERTMS + ' / ' + DTQ->DTQ_TIPTRA ,05,01) //-- 'O Movimento informado nao existe para este Servico / Tipo de Transporte. Movto./Serv.Transp./Tp.Transp.'
				lRet := .F.
			EndIf

		Else
			lRet := .F.
		EndIf

		If !lRet
			Help('',1,'TMSA25023') //-- 'Ocorreu um problema na Inclusao do Movimento na base de dados da Operadora de Frotas.'
		EndIf

	EndIf
EndIf


Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250PGR³ Autor ³ Guilherme R. Gaiofatto³ Data ³ 22/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se cliente paga pedagio, usando Operadora X Frota  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial Origem                                       ³±±
±±³          ³ExpC2 - Codigo da Viagem                                    ³±±
±±³          ³ExpC3 - Codigo do Veiculo                                   ³±±
±±³          ³ExpC2 - Codigo da Operadora                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMSA250PGR(cFilOri,cViagem,cCodVei,cCodOper)

Local aArea 	:= GetArea()
Local aAreaDUD	:= DUD->(GetArea())
Local aAreaDT6	:= DT6->(GetArea())
Local aAreaDUO	:= DUO->(GetArea())
Local aAreaSDG	:= SDG->(GetArea())
Local nCont     := 0
Local lCalPdg 	:= .T.
Local aDocViag	:= {}
Local aCliDev	:= {}
Local cDesPdg	:= SuperGetMV('MV_DESPDG',,'')
Local lRepom 	:= SuperGetMV('MV_TMSOPDG',,'0') == '2' .And. SuperGetMV('MV_VSREPOM',,'1') == '2'
Local cEnRepom  := SuperGetMV('MV_ENREPOM',,"1")

Default cFilOri	:= cFilAnt
Default cViagem	:= ''
Default cCodVei	:= ''
Default cCodOper := ''

If lRepom .And. cCodOper == '01' // Verificação valida apenas para a versao 2 da Repom e se possui uma operadora.
	DUD->(DbSetOrder(2)) //-- Posiciona no Movimento de Viagem paradmina obter codigo dos Documentos da viagem
	If DUD->(DbSeek(cSeek:=xFilial("DUD")+cFilOri+cViagem))
		Do While DUD->(!EoF()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == cSeek
	   	   If DUD->DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS))
	   	   		Aadd(aDocViag,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE})
	   	   	EndIf
	   	   	DUD->(dbSkip())
	 	EndDo
	EndIf

	DT6->(DbSetOrder(1)) //-- Posiciona no Doc. de Viagem para obter os Devedores
	If !Empty(aDocViag)
	   For nCont := 1 to Len(aDocViag)
	   	   If DT6->(DbSeek(xFilial("DT6")+aDocViag[nCont][1]+aDocViag[nCont][2]+aDocViag[nCont][3]))
	   	   		Aadd(aCliDev,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV})
	   	   EndIF
	   next
	EndIf

	DUO->(DbSetOrder(1)) //-- Posiciona no Perfil do Cliente
	If !Empty(aCliDev)
	   For nCont := 1 to Len(aCliDev)
	   	  	If DUO->(DbSeek(xFilial("DUO")+aCliDev[nCont][1]+aCliDev[nCont][2])) .And. DUO->(ColumnPos("DUO_PGPEDG")) > 0
	   	    	If DUO->DUO_PGPEDG = '1' //-- Se algum cliente pagar pedagio
	   	    		lCalPdg := .F.      //-- ele nao sera pago pela Repom
	   	    	EndIF
	   	    EndIF
	   Next
	EndIf

    If AllTrim(cEnRepom) $ "1|2"
        SDG->(DbSetOrder(5))  //-- se ja existe uma movimentacao de custo para ele, significa que ja foi gerado e baixado no SE2
        SDG->(DbSeek(xFilial("SDG")+cFilOri+cViagem+cCodVei))
        While SDG->(!Eof()) .And. SDG->DG_FILIAL == xFilial('SDG') .And. SDG->DG_FILORI == cFilOri .And. SDG->DG_VIAGEM == cViagem .And.  SDG->DG_CODVEI == cCodVei
            If AllTrim(SDG->DG_CODDES) == AllTrim(cDesPdg)
                lCalPdg := .F.
                EXIT
            EndIF
            SDG->(dbSkip())
        Enddo
    EndIf
EndIf

RestArea( aArea )
RestArea( aAreaDUD )
RestArea( aAreaDT6 )
RestArea( aAreaDUO )
RestArea( aAreaSDG )

Return lCalPdg

/*/{Protheus.doc} A250RtTpVe
//TODO Descrição auto-gerada.
@author Leandro Paulino
@since 12/12/2016
@version undefined
@param cTipFrota, lGerAdtPro, lTpFrota
@type function
/*/
Static Function A250RtTpVe(cTipFrota,lGerAdtPro,lTpFrota)

Local cTipVei		:= ''

Default cTipFrota 	:= ''
Default lGerAdtPro	:= .F.
Default lTpFrota  	:= .F.

If cTipFrota == 1 //-- Tipo da Frota : Todas
	If lGerAdtPro .Or. lTpFrota //-- Se Gera Adiantamento para Motorista Proprio (MV_ADTPRO)
		cTipVei := '1;2;3'
	Else
		cTipVei := '2;3'
	EndIf

ElseIf cTipFrota == 2 .And. ( lGerAdtPro .Or. lTpFrota ) //-- Se Tipo da Frota : Propria e Gerar Adiantamento para Motorista Proprio (MV_ADTPRO)
	cTipVei := '1'

ElseIf cTipFrota == 3 //-- Tipo da Frota : Terceiro
	cTipVei := '2'

ElseIf cTipFrota == 4 //-- Tipo da Frota : Agregado
	cTipVei := '3'

EndIf

Return cTipVei

/*/{Protheus.doc} a250QryDTQ
//Query utilziada pela TMSA250Prc quando for gerar contrato por período
@author Leandro Paulino
@since 12/12/2016
@version undefined
@param cSerTransp,dDataDe,dDataAte,cFornDe,cLojaDe,cFornAte,cLojaAte
@type function
/*/
Static Function a250QryDTQ (cSerTransp,dDataDe,dDataAte,cFornDe,cLojaDe,cFornAte,cLojaAte)

Local cAliasCTC := ""
Local cQuery	:= ""
Default cSerTransp	:= ""
Default dDataDe		:= CtoD(Space(08))
Default dDataAte	:= CtoD(Space(08))
Default cFornDe		:= ""
Default cLojaDe		:= ""
Default cFornAte	:= ""
Default cLojaAte	:= ""

cAliasCTC := GetNextAlias() //Filtro para limitar a quantidade de registros a processar.

cQuery := "SELECT DTR.DTR_CODFOR,DTR.DTR_LOJFOR,DA8.DA8_ROTMUN,DTR.DTR_CODVEI, "
If DTR->(ColumnPos('DTR_CIOT')) > 0
	cQuery += "DTR.DTR_CIOT, "
EndIf
cQuery += " DTQ_FILIAL,DTQ_FILORI,DTQ_STATUS,DTQ_DATENC,DTQ.R_E_C_N_O_ DTQREC "
cQuery += "FROM " + RetSqlName("DTQ") + " DTQ "

cQuery += "JOIN " + RetSqlName("DTR") + " DTR ON "
cQuery += " DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
cQuery += " AND DTR.DTR_FILORI = DTQ.DTQ_FILORI "
cQuery += " AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM "
cQuery += " AND DTR.DTR_CODFOR BETWEEN '" + cFornDe + "' AND '" + cFornAte + "' "
cQuery += " AND DTR.DTR_LOJFOR BETWEEN '" + cLojaDe + "' AND '" + cLojaAte + "' "
cQuery += " AND DTR.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 ON "
cQuery += " SA2.A2_FILIAL  = '" + xFilial("SA2") + "' "
cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " AND SA2.A2_COD     = DTR.DTR_CODFOR "
cQuery += " AND SA2.A2_LOJA    = DTR.DTR_LOJFOR "

cQuery += " LEFT JOIN " + RetSqlName("DA8") + " DA8 ON "
cQuery += " DA8.DA8_FILIAL = '" + xFilial("DA8") + "' "
cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
cQuery += " AND DA8.DA8_COD    = DTQ.DTQ_ROTA "

cQuery += " WHERE DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
cQuery += " AND DTQ.DTQ_FILORI   = '" + cFilAnt + "' "
cQuery += " AND DTQ.DTQ_STATUS   = '" + StrZero(3,Len(DTQ->DTQ_STATUS)) + "' "
cQuery += " AND DTQ.DTQ_DATENC BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
If (StrZero( cSerTransp, Len( DUD->DUD_TIPTRA ) ) !="4" )
     cQuery += " AND DTQ.DTQ_SERTMS = '" + StrZero( cSerTransp, Len( DUD->DUD_TIPTRA ) ) + "' "
EndIf

cQuery += " AND DTQ.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY DTR.DTR_CODFOR,DTR.DTR_LOJFOR,SA2.A2_TIPO,DTR.DTR_CODVEI,DA8.DA8_ROTMUN,DTQ.DTQ_FILORI,DTQ.DTQ_VIAGEM,DTQ.DTQ_STATUS, DTQ.DTQ_DATENC "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasCTC, .F., .T.)
(cAliasCTC)->( DbGoTop() )

Return cAliasCTC

/*/{Protheus.doc} GravaDDN
//TODO Grava DDN
@author caio.y
@since 12/12/2016
@version undefined
@param aColsAeD, array, descricao
@type function
/*/
Static Function GravaDDN(cContrat,cFilOri,cViagem,aColsAeD)
Local nCntFor1   	:= 0
Local nCntFor2   	:= 0
Local nVlAcre		:= 0
Local nVlDecr		:= 0
Local cTipAeD		:= ""
Local lRet			:= .T.
Local aArea			:= GetArea()
Local lGrava		:= .T. //-- Variavel utilizada para controle, pois Acr/Decr gerados pelo apt. de ocorrencia não devme ser gravados novamente
Local nPosNumOco	:= 0

Default cContrat	:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default aColsAeD	:= {}

//-- Atualiza a tabela de acrescimos/decrescimos quando exibido o preview
If !Empty(aColsAeD)
	For nCntFor1 := 1 To Len(aColsAeD)
		nPosNumOco	:= AScan(aHeaderAeD,{|x|AllTrim(x[2]) == "DDN_NUMOCO"})

		lGrava		:= Iif(nPosNumOco > 0 , Empty(aColsAeD[nCntFor1,nPosNumOco]) , .T. )

		If !aColsAeD[nCntFor1,Len(aHeaderAeD) + 1] .And. lGrava
			RecLock("DDN",.T.)
			DDN->DDN_FILIAL	:= xFilial("DDN")
			DDN->DDN_FILORI := cFilOri
			DDN->DDN_VIAGEM	:= cViagem
			DDN->DDN_NUMCTC := cContrat
			For nCntFor2 := 1 To Len(aHeaderAeD)
				If AllTrim(aHeaderAeD[nCntFor2,2]) == "DDN_CODAED"
					cCodAeD := aColsAeD[nCntFor1,nCntFor2]
					DDI->(dbSetOrder(1))
					If DDI->(MsSeek(xFilial("DDI") + cCodAeD ))
						cTipAeD		:= DDI->DDI_TIPAED
					EndIf
				EndIf

				If aHeaderAeD[nCntFor2,10] != "V"
					&(aHeaderAeD[nCntFor2,2]) := aColsAeD[nCntFor1,nCntFor2]
					If AllTrim(aHeaderAeD[nCntFor2,2]) == "DDN_VALOR"
						If cTipAeD == "1"
							nVlAcre += aColsAeD[nCntFor1,nCntFor2]
						ElseIf cTipAeD == "2"
							nVlDecr += aColsAeD[nCntFor1,nCntFor2]
						EndIf
					EndIf
				EndIf
			Next nCntFor2
			DDN->DDN_CODUSU := __cUserID
			DDN->(MsUnlock())
		EndIf
	Next nCntFor1
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} A250ExiTit
//Verifica se título existe na base de dados
@author caio.y
@since 23/12/2016
@version undefined
@param cPrefixo, characters, descricao
@param cContrato, characters, descricao
@type function
/*/
Static Function A250ExiTit(cPrefixo, cContrato, cCodForn, cLojForn, cTipCTC )
Local aAreaSE2		:= SE2->(GetArea())
Local lRet			:= .F.

Default cTipCTC		:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )
Default cPrefixo	:= ""
Default cContrato	:= ""
Default cCodForn	:= ""
Default cLojForn	:= ""

SE2->(dbSetOrder(6))
If SE2->(dbSeek(xFilial("SE2") + cCodForn + cLojForn + cPrefixo + cContrato + cTipCTC ))
	lRet	:= .T.
EndIf

RestArea(aAreaSE2)
Return lRet

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250SeqBx³ Autor ³Leandro Paulino        ³ Data ³29.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche a tabela de Acertos Financeiros de Contratos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a250SeqBx( )											 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³												                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A250SeqBx(nRecSE2,cRetIntBx,cFilOri,cNumCTC,nAcao)

Local cSeekDYI    := ''

Default cRetIntBx := ''
Default nAcao     := 1

If AliasIndic('DYI')
	DYI->(DbSetOrder(1))
	If nAcao == 1
		If DYI->(!dbSeek(xFilial('DYI')+cFilOri+cNumCTC+cRetIntBx))
			RecLock ('DYI',.T.)
			DYI->DYI_FILIAL:= xFilial('DYI')
			DYI->DYI_FILORI:= DTY->DTY_FILORI
			DYI->DYI_NUMCTC:= DTY->DTY_NUMCTC
			DYI->DYI_SEQBX := cRetIntBx
			DYI->DYI_DATBX := ddatabase
			DYI->DYI_HORBX := StrTran(Left(Time(),5),':','')
			DYI->DYI_USRBX := RetCodUsr()
			MsUnLock()
		EndIf
	ElseIf nAcao == 2
		If DYI->(dbSeek(cSeekDYI := xFilial('DYI')+cFilOri+cNumCTC))
			While DYI->(!Eof()) .And. DYI->(DYI_FILIAL+DYI_FILORI+DYI_NUMCTC) == cSeekDYI
				RecLock("DYI",.F.)
				DYI->(dbDelete())
				DYI->(MsUnLock())
				DYI->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AdicionaMsg³ Autor ³ Clovis Nunes do Nascimento    ³21/10/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona Mensagem no vetor do schedule                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Scheddef()

Local aParam

aParam := { 	"P"			,;  	//Tipo R para relatorio P para processo
				"TM250A"	,;		// Pergunte do relatorio, caso nao use passar ParamDef
				"DTY"		,;  	// Alias
							,;   	//Array de ordens
				STR0199} //--> Schedule - Contrato Carreteiro ( Por Período)

Return aParam

/*/{Protheus.doc} A250AedVlr
//TODO Calcula valores de Acrescimo/Decrescimo
@author caio.y
@since 23/01/2017
@version undefined
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Numero da Viagem
@param nAcresc, numeric, Valor de acrescimo
@param nDecresc, numeric, Valor de Decrescimo
@type function
/*/
Static Function A250AedVlr( cFilOri, cViagem , nAcresc , nDecresc, nBasImp , nValFrete , nVlrReem )
Local aArea		:= GetArea()
Local aAreaDDN	:= DDN->(GetArea())
Local aAreaDDI	:= DDI->(GetArea())
Local aAreaDT2	:= DT2->(GetArea())
Local lBasImp	:= .T.
Local lReemb 	:= DDI->(ColumnPos('DDI_TPREEM')) > 0
Local lValFrete	:= .T.

Default cFilOri		:= ""
Default cViagem		:= ""
Default nAcresc		:= 0
Default nDecresc	:= 0
Default nBasImp		:= 0
Default nValFrete	:= 0
Default nVlrReem	:= 0
lBasImp	:= Iif(nBasImp > 0, .T. , .F. )

DDN->(dbSetOrder(1)) //-- FILIAL+FILORIGEM+VIAGEM+SEQUEN
DDI->(dbSetOrder(1)) //-- FILIAL+CODAED
If DDN->( MsSeek( xFilial("DDN") + cFilOri + cViagem ))

	While DDN->( !Eof() ) .And. xFilial("DDN") + cFilOri + cViagem  == DDN->(DDN_FILIAL + DDN_FILORI + DDN_VIAGEM)

		If DDI->( MsSeek( xFilial("DDI") + DDN->DDN_CODAED ))
			If lReemb .And. lBasImp .And. DDI->DDI_TPREEM == '1'
				lValFrete 	:= .F. 
				lBasImp 	:= .F. //--Se o Tipo do acréscimo/decréscimo for do Tipo Reembolso não será alterada a base de Imposto com o valor desta ocorrência.
			EndIf
			If DDI->DDI_TIPAED == "1" //-- Acrescimo
				nAcresc		+= DDN->DDN_VALOR
				If lValFrete
					nValFrete	+= DDN->DDN_VALOR
				EndIf

				If lBasImp
					nBasImp	+= DDN->DDN_VALOR
				Else
					nVlrReem += DDN->DDN_VALOR
				EndIf

			Else //-- Decrescimo
				nDecresc	-= DDN->DDN_VALOR
				nValFrete	-= DDN->DDN_VALOR

				If lBasImp
					nBasImp	-= DDN->DDN_VALOR
				EndIf

			EndIf
		EndIf
		lBasImp 	:= Iif(nBasImp > 0, .T. , .F. )
		lValFrete 	:= .T.

		DDN->( dbSkip() )
	EndDo

EndIf

RestArea( aArea )
RestArea( aAreaDDN )
RestArea( aAreaDT2 )
RestArea( aAreaDDI )
Return


/*/{Protheus.doc} A250VldDUA
//Valida ocorrencias de viagem
@author caio.y
@since 25/01/2017
@version 1.0
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@param aMsgErr, array, Array contendo mensagens de erro
@type function
/*/
Static Function A250VldDUA( cFilOri , cViagem , aMsgErr , lGrava , cNumCTC )
Local aAreaDUA		:= DUA->(GetArea())
Local lRet			:= .T.
Local aOcorr		:= {}

Default cFilOri		:= DTR->DTR_FILORI
Default cViagem		:= DTR->DTR_VIAGEM
Default aMsgErr		:= {}
Default lGrava		:= .F.
Default cNumCTC		:= ""

DUA->( dbSetOrder(2))//-- FILIAL+FILORI+VIAGEM+SEQUEN
DT2->( dbSetOrder(1))//-- FILIAL+COD
If DUA->( MsSeek( xFilial("DUA") + cFilOri + cViagem )) .And.  DT2->(ColumnPos("DT2_CODAED")) > 0 .And. DUA->(ColumnPos("DUA_RECDEP")) > 0

	While DUA->(!Eof()) .And. DUA->(DUA_FILIAL+DUA_FILORI+DUA_VIAGEM) == xFilial("DUA") + cFilOri + cViagem

		If DT2->( MsSeek( xFilial("DT2") + DUA->DUA_CODOCO )) .And. !Empty( DT2->DT2_CODAED )

			If !lGrava
				If DUA->DUA_RECDEP <> '2'

					Aadd( aOcorr , { 	FWX3Titulo("DUA_NUMOCO") + ": " + DUA->DUA_NUMOCO + " / " + FWX3Titulo("DUA_CODOCO") + ": " + DUA->DUA_CODOCO + " - " + RTrim( Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI") ) } )
					Aadd( aOcorr , { 	FWX3Titulo("DUA_DATOCO") + ": " + DToC(DUA->DUA_DATOCO) + " / " + FWX3Titulo("DUA_HOROCO") + ": " + DUA->DUA_HOROCO } )
					Aadd( aOcorr , { 	FWX3Titulo("DT2_CODAED") + ": " + DT2->DT2_CODAED + " - " + RTrim( Posicione("DDI",1,xFilial("DDI") +DT2->DT2_CODAED ,"DDI_DESCRI") )  } )
					Aadd( aOcorr , { 	FWX3Titulo("DUA_VLRDSP") + ": " + cValToChar(DUA->DUA_VLRDSP) } )
					Aadd( aOcorr , { 	"   " } )

				Else

					AAdd( aMsgErr, { STR0259 } ) //-- "O contrato possui ocorrências que geram acréscimo/decréscimo bloqueadas.
					AAdd( aMsgErr, { STR0260 } ) //-- "É necessário realizar a liberação através da rotina Manut. Bloqueios"
					AAdd( aMsgErr, { FWX3Titulo("DTQ_VIAGEM") + ": " + cViagem  } )
					AAdd( aMsgErr, { FWX3Titulo("DUA_NUMOCO") + ": " + DUA->DUA_NUMOCO } )
					AAdd( aMsgErr, { FWX3Titulo("DUA_CODOCO") + ": " + DUA->DUA_CODOCO } )
					AAdd( aMsgErr, { FWX3Titulo("DUA_DESOCO") + ": " + RTrim( Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI") ) } )
					AAdd( aMsgErr, { FWX3Titulo("DUA_SEQOCO") + ": " + DUA->DUA_SEQOCO } )
					AAdd( aMsgErr, { FWX3Titulo("DUA_HOROCO") + ": " + DUA->DUA_HOROCO } )
					AAdd( aMsgErr, { FWX3Titulo("DT2_CODAED") + ": " + DT2->DT2_CODAED } )
					AAdd( aMsgErr, { FWX3Titulo("DDI_DESCRI") + ": " + RTrim( Posicione("DDI",1,xFilial("DDI") +DT2->DT2_CODAED ,"DDI_DESCRI") ) } )
					AAdd( aMsgErr, { FWX3Titulo("DUA_VLRDSP") + ": " + cValToChar(DUA->DUA_VLRDSP) } )

					lRet	:= .F.
					Exit
				EndIf
			Else

				dbSelectArea("DUA")
				RecLock("DUA",.F.)
				DUA->DUA_FLOCTC		:= cFilOri
				DUA->DUA_NUMCTC		:= cNumCTC
				MsUnlock()

			EndIf
		EndIf
		DUA->(dbSkip())
	EndDo
EndIf

If lRet .And. Len(aOcorr) > 0 .And. !lGrava
	lRet	:= TmsMsgErr( aOcorr, STR0262 + " - " + STR0261 + " / " +  FWX3Titulo("DTQ_VIAGEM") + ": " + cViagem  ) //-- "Acréscimos/Decréscimos gerados pela rotina Registro Ocorrências" + "Deseja prosseguir?"

	If lRet
		aMsgErr	:= {}
	EndIf

EndIf

RestArea(aAreaDUA)
Return lRet

/*/{Protheus.doc} RetOrdSX3
Retorna ordem do campo do SX3
@author caio.y
@since 22/02/2017
@version undefined
@param cCampo, characters, Campo do dicionÃ¡rio de dados
@type function
/*/
Static Function RetOrdSX3(cCampo)
    Local aArea  := GetArea()
    Local cOrdem := ""

    Default cCampo	:= ""

    cOrdem := X3Ordem(cCampo)

    If Empty(cOrdem)
        cOrdem := "01"
    Else
        cOrdem += "1"
    EndIf

    RestArea(aArea)

Return cOrdem


/*================================================================================================================
/{Protheus.doc} DTYValLiq
//TODO Função estática para compor o valor liquido do frete.
@author tiago.dsantos
@since 01/03/2017
@version 1.0

@type function

@Observacao: Avaliar se o valor do pedagio fará parte da composição do frete.
================================================================================================================
/*/
Static Function DTYValLiq(lDescAdto)
Local aAreaDVG := DVG->(GetArea())
Local nRValliq := 0
Local cCodFor  := DTY->DTY_CODFOR
Local cLojFor  := DTY->DTY_LOJFOR
Local cDedPdg  := "0"

Default lDescAdto := .T.

      nRValliq := DTY->( DTY_VALFRE - Iif(lDescAdto, DTY_ADIFRE, 0) - DTY_IRRF  - DTY_SEST  - DTY_INSS  - DTY_ISS   - DTY_VALPRE  )

      //aContrFor := TMSContrFor(DTY->DTY_CODFOR,DTY->DTY_LOJFOR,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,Posicione('DA3',1,xFilial('DA3') + DTY->DTY_CODVEI,'DA3_TIPVEI'))
      If cDedPdg == "1"
           nRValLiq -= DTY->DTY_VALPDG
      EndIf

RestArea(aAreaDVG)

Return nRValliq

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T250Meta
                  Pesquisa Valor Solicitado No Vetor Caso Não Encontre Retorna Valor Padrão Da Tabela

@author           Eduardo Alberti
@since            Feb./2017
@version          MP12
@sample           T250Meta( DTY_CODFOR , 'DTY' , aVetor )
@see              TMSA250
@obs              Uso Genérico
@param            cCampo : Nome Do Campo Pesquisado
                  cTab   : Tabela Para Buscar Valor Caso Não Encontre No Vetor aVetor
                  aVetor : Vetor Para Busca Do Valor Do Campo Informado na Variável cCampo
@return           Retorna Valor Encontrado Ou No Vetor Ou Va Tabela De Dados
/*/
//-------------------------------------------------------------------------------------------------
Static Function T250Meta( cCampo , cTab , aVetor )

	Local aArea   := {GetArea()}
	Local nX      := 0
	Local xValue  := Nil
	Local nPos    := 0

	Default cCampo := ""
	Default cTab   := ""
	Default aVetor := {}

	//-- Inicializa Controle De Sequence
	Begin Sequence

	//-- Pesquisa Posição Do Campo Solicitado No Vetor De Parametros
	nPos := aScan( aVetor , { |x| Alltrim(x[1]) == Alltrim(cCampo) })

	//-- Se Encontrou Posição, Retorna Valor
	If nPos > 0
		xValue := aVetor[ nPos , 02 ]
		Break
	Else

		DbSelectArea( cTab )
		If (cTab)->(ColumnPos(cCampo)) > 0
			xValue := &((cTab)->(cCampo))
			Break
		EndIf
	EndIf

	//-- Finaliza Controle De Sequence
	End Sequence

	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX

Return(xValue)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250DetNat
                  Determina a Natureza Financeira Para Gravação Do Título a Pagar
@author           Eduardo Alberti
@since            Mar./2017
@version          MP12
@sample           A250DetNat(c250CodFor, c250LojFor, DUA->(Recno())
@see              TMSA152,TMSA250
@param            Caracter - cCodFor -> Código Do Fornecedor
                  Caracter - cLojFor -> Loja  Do Fornecedor
                  Númerico - Recno Da Tabela DUA ( Se Não Estiver Posicionado Informar Zero Ou Nil )
@return           Caracter cNaturez
/*/
//-------------------------------------------------------------------------------------------------
Function A250DetNat( cCodFor, cLojFor, nRecDUA )

	Local aArea    := {DUA->(GetArea()),DT2->(GetArea()),SA2->(GetArea()),GetArea()}
	Local nX       := 0
	Local cNaturez := ""

	Default cCodFor := ""
	Default cLojFor := ""
	Default nRecDUA := 0

	//-- Verifica Se Posiciona No DUA
	If nRecDUA > 0

		DbSelectArea("DUA")
		DUA->(DbGoTo(nRecDUA))

		//-- Posiciona Na Tabela De Ocorrencias
		If !Empty(DUA->DUA_CODOCO)

			DbSelectArea("DT2")
			DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
			MsSeek( FWxFilial("DT2") + DUA->DUA_CODOCO ,.F.)

			cNaturez := DT2->DT2_CODNAT

		EndIf
	EndIf

	If Empty(cNaturez)

		SA2->(dbSetOrder(1))
		If SA2->(MsSeek( FWxFilial('SA2') + cCodFor + cLojFor)) .And. !Empty(SA2->A2_NATUREZ)
			cNaturez := SA2->A2_NATUREZ
		Else
			If lTM250Par
				cNaturez := ExecBlock('TM250PAR',.F.,.F.,{1})
				If ValType(cNaturez) <> 'C'
					cNaturez := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
				EndIf
			Else
				cNaturez := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
			EndIf
		EndIf
	EndIf

	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX

Return(cNaturez)
/*================================================================================================================
/{Protheus.doc} A250RetImp
//TODO Função para preencher o array com os valores dos impostos já calulados no Contrato de Carreteiro
@author leandro.paulino
@since 01/03/2017
@version 1.0

@type function

@Observacao: Atualmente utilizada apenas para a Integração com REPOM
================================================================================================================*/
Function A250RetImp(cPais,cEstado)

Local aImpostos 	:= {}
Local aAreas		:= {DTQ->(GetArea()),DA8->(GetArea()),DUY->(GetArea()),GetArea()}

Default cPais   	:= ''
Default cEstado 	:= ''

If Empty(cPais)
	DTQ->(DbSetOrder(2)) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
	If DTQ->(MsSeek(xFilial('DTQ') + DTY->DTY_FILORI + DTY->DTY_VIAGEM))
		DA8->(DbSetOrder(1))
		If DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA)) .And. DA8->(ColumnPos("DA8_ROTMUN")) > 0

			DUY->(dbSetOrder(1))
			If DUY->(MsSeek(FwxFilial('DUY')+DA8->DA8_CDRORI))
				cEstado := DUY->DUY_EST
				cPais	:= DUY->DUY_PAIS
			EndIf
		EndIf
	EndIf
EndIf
cPais := IIf(Empty(cPais),'105',cPais)

	If DTY->DTY_IRRF > 0
		AADD(aImpostos,{"IRRF-PF"    , DTY->DTY_IRRF	 , cPais, cEstado, DTY->DTY_BASIMP})
	EndIf
	If cTmsErp == '1' .And. DTY->(ColumnPos('DTY_VLSEST')) > 0 .And. DTY->(ColumnPos('DTY_VLSENA')) > 0
		If DTY->DTY_VLSEST > 0
			AADD(aImpostos,{"SEST/SENAT" 	 , DTY->DTY_VLSEST  , cPais, cEstado, DTY->DTY_BASIMP})
		EndIf
		If DTY->DTY_VLSENA > 0
			AADD(aImpostos,{"SENAT" 	 , DTY->DTY_VLSENA  , cPais, cEstado, DTY->DTY_BASIMP})
		EndIf
	Else
		If 	DTY->DTY_SEST > 0
			AADD(aImpostos,{"SEST" , DTY->DTY_SEST  , cPais, cEstado, DTY->DTY_BASIMP})
		EndIf
	EndIf
	If 	DTY->DTY_INSS > 0
		AADD(aImpostos,{"INSS-PF"    , DTY->DTY_INSS	 , cPais, cEstado, DTY->DTY_BASIMP})
	EndIf
	If DTY->DTY_ISS > 0
		AADD(aImpostos,{"ISS"        , DTY->DTY_ISS	 , cPais, cEstado, DTY->DTY_BASIMP})
	EndIf
	If DTY->DTY_COFINS > 0
		AADD(aImpostos,{"COFINS"     , DTY->DTY_COFINS, cPais, cEstado, DTY->DTY_BASIMP})
	EndIf
	If 	DTY->DTY_CSLL > 0
		AADD(aImpostos,{"CSLL"       , DTY->DTY_CSLL	 , cPais, cEstado, DTY->DTY_BASIMP})
	EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})
Return aImpostos


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM250ClDiaºKatia                       º Data ³ 18/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento para Calcular a quantidade de diárias.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function TM250ClDia(cCodForn,cLojForn,cCodVei)

Local aArea      := GetArea()
Local dDatFec    := StoD('')
Local dDatEnc    := StoD('')
Local cAliasDTQ  := GetNextAlias()
Local aDiaHist   := {}
Local lTmsDiaV   := SuperGetMV( 'MV_TMSDIAV',, .F. ) //Calcula a quantidade do compoenente Diaria (54 e 60) por Fornecedor e Veículo

Default cCodForn := ""
Default cLojForn := ""
Default cCodVei  := ""


cQuery := "SELECT DTQ.DTQ_FILIAL, DTQ.DTQ_FILORI, DTQ.DTQ_STATUS, DTQ.DTQ_DATENC, DTQ.R_E_C_N_O_ DTQRec, DTQ.DTQ_DATFEC FROM "
cQuery += RetSqlName("DTQ") + " DTQ, "
If lTmsDiaV
	cQuery += RetSqlName("DTR") + " DTR, "
EndIf
cQuery += RetSqlName("DTY") + " DTY "
cQuery += " WHERE DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
cQuery += " AND DTQ.DTQ_FILORI = '" + cFilAnt + "' "
cQuery += " AND DTQ.DTQ_STATUS = '" + StrZero(3, Len(DTQ->DTQ_STATUS)) + "' "
cQuery += " AND DTQ.DTQ_DATENC BETWEEN '"+DTOS(mv_par02)+"' AND '"+DTOS(mv_par03)+"' "
If(StrZero( MV_PAR01, Len( DUD->DUD_TIPTRA ) )!="4")
	cQuery += " AND DTQ.DTQ_SERTMS = '" + StrZero( MV_PAR01, Len( DUD->DUD_TIPTRA ) ) + "' "
EndIf
cQuery += " AND DTQ.D_E_L_E_T_ = '  '"
If lTmsDiaV
	//-- Complemento Viagem
	cQuery += " AND DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
	cQuery += " AND DTR.DTR_FILORI = DTQ.DTQ_FILORI "
	cQuery += " AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM "
	cQuery += " AND DTR.DTR_CODVEI = '" + cCodVei + "' "
	cQuery += " AND DTR.D_E_L_E_T_ = ' ' "
EndIf
//-- Contrato Carreteiro
cQuery += " AND DTY.DTY_FILIAL = '" + xFilial("DTY") + "' "
cQuery += " AND DTY.DTY_FILORI = DTQ.DTQ_FILORI "
cQuery += " AND DTY.DTY_VIAGEM = DTQ.DTQ_VIAGEM "
cQuery += "	AND DTY_CODFOR = '" + cCodForn + "' "
cQuery += "	AND DTY_LOJFOR = '" + cLojForn + "' "
cQuery += "	AND DTY_TIPCTC <> '5' "
cQuery += "	AND DTY_QTDDIA <> 0 "
cQuery += " AND DTY.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY DTQ.DTQ_FILIAL, DTQ.DTQ_FILORI, DTQ.DTQ_STATUS, DTQ.DTQ_DATENC"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTQ, .F., .T.)
While (cAliasDTQ)->(!Eof())

	dDatFec    := StoD((cAliasDTQ)->DTQ_DATFEC)
	dDatEnc    := StoD((cAliasDTQ)->DTQ_DATENC)

	Do While dDatFec <= dDatEnc
		//-- Se for Sabado ou Domingo
		If Dow(dDatFec) == 7 .Or. Dow(dDatFec) == 1
			If Ascan( aDiaHist, { |x| x[1]+x[2]+x[3] == Dtos(dDatFec) + Iif(lTmsDiaV,cCodVei,"") + "F" } ) == 0    //F= Fim de Semana
				AAdd( aDiaHist,   {Dtos(dDatFec), Iif(lTmsDiaV,cCodVei,""), "F" } )
			EndIf
		Else
			If Ascan( aDiaHist, { |x| x[1]+x[2]+x[3] == Dtos(dDatFec) + Iif(lTmsDiaV,cCodVei,"") + "S" } ) == 0    //S= Semana
				AAdd( aDiaHist, {Dtos(dDatFec), Iif(lTmsDiaV,cCodVei,""), "S" } )
			EndIf
		EndIf
		dDatFec += 1
	EndDo
	dbSkip()
EndDo

(cAliasDTQ)->(DbCloseArea())

RestArea(aArea)

Return aDiaHist

/*================================================================================================================
/{Protheus.doc} A250IntRep
//TODO Função que unifica os pontos de integração com a REPOM
@author leandro.paulino
@since 01/03/2017
@version 1.0

@type function

@Observacao: Integração com REPOM
================================================================================================================*/
Static Function A250IntRep( nValMov, lTMSOPdg, aMsgErr, nVlrReem, aDadosOpe)
Local aMovtos 	:= {}
Local lRet    	:= .T.
Local lLibCTC 	:= SuperGetMV( 'MV_LIBCTC',, .F. )
Local cCodReemb := AllTrim(GetMV('MV_REPREEM',,'20'))
Local cCodAcres	:= AllTrim(GetMv('MV_REPACRE',,'146'))
Local cCodDecre	:= AllTrim(GetMv('MV_REPDECR',,'06'))

Default nValMov 	:= 0
Default lTMSOPdg    := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Default aMsgErr		:= {}
Default nVlrReem	:= 0
Default aDadosOpe   := {}

Trace250("a250IntRep - Inicio Função")

//-- Valida informações da Operadora para não ocorrer reenvio.
If !IsInCallStack("TMSA251Prc") .And. AllTrim(FunName()) <> "TMSA251"
	Trace250("Chamando A250ChkOpe - intran " + AllToChar(InTransact()) )
	lRet := A250ChkOpe(DTY->DTY_CODOPE,DTY->DTY_FILORI,DTY->DTY_VIAGEM,@aDadosOpe,aMsgErr)
	Trace250("Chamando A250ChkOpe - lRet/ intran " + AllToChar(lRet) + "/" + AllToChar(InTransact()) )
EndIf

//-- Inclui o movimento a diferença entre previsto x realizado
If !Empty(nValMov)
     AAdd(aMovtos, {	DTR->(DTR_FILORI+DTR_VIAGEM) ,;
                   Iif(nValMov > 0,cCodAcres,cCodDecre),; //-- default 146-Acrescimo/ 06-Desconto
                   Abs(nValMov),;
                   '00',; //-- NENHUMA ACAO NO PROTHEUS
                   '0'} )//-- '0' Inclui movimento
EndIf
If nVlrReem > 0
	AAdd(aMovtos, {	DTR->(DTR_FILORI+DTR_VIAGEM) ,;
                  AllTrim(cCodReemb),; //-- default 146-Acrescimo/ 06-Desconto
                  Abs(nVlrReem),;
                  '00',; //-- NENHUMA ACAO NO PROTHEUS
                  '0'} )//-- '0' Inclui movimento
EndIf
If lRet .And. !Empty(aMovtos)
	Trace250("Chamando TmsIncMov " + VarInfo("aMovtos",aMovtos))

     MsgRun( STR0109,; //-- "Gerando Movimentos para o Contrato..."
             STR0100,; //-- "Realizando Comunicação com a Operadora..."
             {|| lRet := TMSIncMov( DTR->DTR_CODOPE, DTR->DTR_FILORI, DTR->DTR_VIAGEM, aMovtos)})

	Trace250("Retornando TmsIncMov")
    If !lRet
       Aadd( aMsgErr,{STR0274 + " " + DTR->(DTR_FILORI + "/ " + DTR_VIAGEM) ,"01",""})
    EndIf
EndIf

//-- Quita contrato!
If lRet .And. lTMSOPdg .And. DTR->DTR_CODOPE == '01'
	Trace250("Chamando TMA340Oper")
   CursorWait()

   MsgRun( STR0238 ,;    //-- "Quitação de Contrato"
   STR0100,;             //-- "Realizando Comunicação com a Operadora..."
   {|| lRet := TMA340Oper( DTR->DTR_CODOPE, DTR->DTR_FILORI, DTR->DTR_VIAGEM, @aMsgErr, , 3,, DTYValLiq())} )

   If !lRet
   		Aadd( aMsgErr,{STR0273 + " " + DTR->(DTR_FILORI + "/ " + DTR_VIAGEM) ,"01",""})
		//-- Se falhou a quitação, estorna os movimentos
		If !Empty(aMovtos)
			//-- Altera o código de ação de '0' (Inclui movimento) para "1" (Exclui Movimento)
			aEval(aMovtos,{|x| x[5] := "1"})
			Trace250("Estornando Movtos TmsIncMov " + VarInfo("aMovtos",aMovtos))
			If !TMSIncMov( DTR->DTR_CODOPE, DTR->DTR_FILORI, DTR->DTR_VIAGEM, aMovtos)
				Aadd( aMsgErr,{STR0274 + " " + DTR->(DTR_FILORI + "/ " + DTR_VIAGEM) ,"01",""})
				Trace250("Retornando estorno .F." )
			Else
				Trace250("Retornando estorno .T." )
			EndIf
		EndIf
   EndIf

   CursorArrow()
	Trace250("Retornando TMA340Oper")
EndIf
Trace250("a250IntRep - Fim Função")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA250Var
@descricao	: Carrega Variáveis Da Função TMSA250 (TMSA250Var("DES"))
@author Eduardo Alberti
@since  Mar/2017
@version 12
/*/
//-------------------------------------------------------------------
Function TMSA250Var(cTip)

Local aArea := GetArea()
Local cRet  := ""

Default cTip    := "DES" //-- Despesa MV_DESCTC
Default cDes250 := ""
Default cNat250 := ""

If Upper(Alltrim(cTip)) == "DES"

	DbSelectArea("DT7")

	If Empty(cDes250)

		If Type("cDes152") == "C" .And. !Empty(cDes152)
			cRet := cDes152 //-- Pega Da TMSA152 Quando Ativa
		Else
			cRet := Padr( GetMV("MV_DESCTC"), Len( DT7->DT7_CODDES ) ) //-- Pega Do Parâmetro
		EndIf
	Else
		cRet := cDes250 //-- Variável Já Carregada Anteriormente
	EndIf
ElseIf Upper(Alltrim(cTip)) == "NAT"

	DbSelectArea("SE2")

	If Empty(cNat250)

		If Type("cNat152") == "C" .And. !Empty(cNat152)
			cRet := cNat152 //-- Pega Da TMSA152 Quando Ativa
		Else
			cRet := Padr( GetMV("MV_NATCTC"), Len( SE2->E2_NATUREZ ) ) //-- Pega Do Parâmetro
		EndIf
	Else
		cRet := cNat250 //-- Variável Já Carregada Anteriormente
	EndIf

EndIf

RestArea(aArea)

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA250Vld
@descricao	: Validação de Campo
@author Katia
@since  Mar/2017
@version 12
/*/
//-------------------------------------------------------------------
Function TMA250Vld()
Local lRet     := .T.
Local cCampo   := ReadVar()
Local lTMSOPdg := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local aArea    := GetArea()

If  cCampo $ 'M->DTY_CODMOV'
	If lTMSOPdg .And. M->DTY_CODOPE == '01'   //Repom
		DTQ->(DbSetOrder(2)) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		If DTQ->(MsSeek(xFilial('DTQ') + M->DTY_FILORI + M->DTY_VIAGEM ))
			DEM->(DbSetOrder(2)) //-- DEM_FILIAL+DEM_CODOPE+DEM_CODMOV+DEM_SERTMS+DEM_TIPTRA
			If !DEM->(DbSeek(xFilial('DEM') + M->DTY_CODOPE + M->DTY_CODMOV + DTQ->DTQ_SERTMS + DTQ->DTQ_TIPTRA ))
				Help('',1,'TMSA25024',, M->DTY_CODMOV + ' / ' + DTQ->DTQ_SERTMS + ' / ' + DTQ->DTQ_TIPTRA ,05,01) //-- 'O Movimento informado nao existe para este Servico / Tipo de Transporte. Movto./Serv.Transp./Tp.Transp.'
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Tm250To152
                  Tratamento Ocorrencias Receita/Despesa
                  Verifica Se Existem Registros Disponíveis Para Processamento No TMSA152
                  e Gera Contratos Complementares Conforme Ocorrencias DUA

@author Eduardo Alberti
@since  Mar/2017
@version 12
/*/
//-------------------------------------------------------------------
Function Tm250To152(nRecDTY)

	Local aArea     := GetArea()
	Local cAliasDUA := ""
	Local cQuery    := ""
	Local lAbriu    := .f.

	Default nRecDTY := 0

	If nRecDTY > 0
		DTY->(DbGoTo(nRecDTY))

		MV_PAR01 := DTY->DTY_VIAGEM
		MV_PAR02 := DTY->DTY_VIAGEM
		MV_PAR08 := DTY->DTY_FILORI
	Else
		TMA250Perg("TMA250", .F.)
	EndIf

	cAliasDUA := GetNextAlias()
	cQuery := " SELECT      DUA.R_E_C_N_O_ RECNO "
	cQuery += " FROM        " + RetSqlName("DUA") + " DUA "
	cQuery += " INNER JOIN  " + RetSqlName("DT2") + " DT2 "
	cQuery += " ON          DT2.DT2_FILIAL =  '" + FWxFilial("DT2") + "' "
	cQuery += " AND         DT2.DT2_CODOCO =  DUA.DUA_CODOCO "
	cQuery += " AND         DT2.DT2_TIPOCO IN ('17','18') " //-- Ocorrencias Despesa
	cQuery += " AND         DT2.D_E_L_E_T_ =  ' ' "
	cQuery += " INNER JOIN  " + RetSqlName("DTY") + " DTY "
	cQuery += " ON          DTY.DTY_FILIAL = '" + FWxFilial("DTY") + "' "
	cQuery += " AND         DTY.DTY_FILORI = DUA.DUA_FILORI "
	cQuery += " AND         DTY.DTY_VIAGEM = DUA.DUA_VIAGEM "
	//--cQuery += " AND         DTY.DTY_DATCTC = '" + DtoS(dDataBase) + "' "
	cQuery += " AND         DTY.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE       DUA.DUA_FILIAL =  '" + FWxFilial("DUA") + "' "
	cQuery += " AND         DUA.DUA_FILORI =  '" + MV_PAR08 + "' "
	cQuery += " AND         DUA.DUA_VIAGEM BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += " AND         DUA.DUA_NUMCTC =  '" + Space(TamSX3("DUA_NUMCTC")[1]) + "' "
	cQuery += "	AND         DUA.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUA, .F., .T.)

	DbSelectArea(cAliasDUA)
	(cAliasDUA)->(DbGoTop())
	If (cAliasDUA)->RECNO > 0

		//-- Pergunta Se Quer Executar TMSA152
		If MsgYesNo(STR0277) //-- "Existem Ocorrências Disponíveis Para Geração Do Contrato Carreteiro. Deseja Visualizar?"

			lAbriu  := .t.
			aParSX1 := {}
			aAdd( aParSX1 , MV_PAR01        ) //-- 01 Viagem De
			aAdd( aParSX1 , MV_PAR02        ) //-- 02 Viagem Até
			aAdd( aParSX1 , dDataBase - 090 ) //-- 03 Data De:
			aAdd( aParSX1 , dDataBase       ) //-- 04 Data Até
			aAdd( aParSX1 , MV_PAR08        ) //-- 05 Filial De
			aAdd( aParSX1 , MV_PAR08        ) //-- 06 Filial Até
			aAdd( aParSX1 , '         '     ) //-- 07 Documento De:
			aAdd( aParSX1 , 'ZZZZZZZZZ'     ) //-- 08 Documento Até
			aAdd( aParSX1 , '   '           ) //-- 09 Série De:
			aAdd( aParSX1 , 'ZZZ'           ) //-- 10 Série Até
			aAdd( aParSX1 , 4               ) //-- 11 Status Registro
			aAdd( aParSX1 , '17'            ) //-- 12 Tipo Ocorr. De
			aAdd( aParSX1 , '18'            ) //-- 13 Tipo Ocorr. Até

			//-- Mostra Browse De Documentos Complementares
			Tmsa152(aParSX1)

		EndIf
	EndIf

	If Select(cAliasDUA) > 0
		(cAliasDUA)->(DbCloseArea())
	EndIf

	//-- Reposiciona Na Pergunta Original
	Pergunte("TMA250",.F.)

	RestArea(aArea)

Return(lAbriu)

/*/{Protheus.doc} A250FrePag
// Realiza o cálculo do frete a pagar, de acordo com as tabelas de frete cadastradas no contrato de cliente e/ou fornecedor
@author caio.y
@since 10/05/2017
@version undefined
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@param cCodVei, characters, Código do Veículo
@param aMsgErr, array, Array com Mensagem de Erro
@param lMsgErr, logical, Exibe Mensagem de Erro?
@param aFrete, array, Array composição de Frete
@param nGrupVei, numeric, Grupo do veículo
@param cCodForn, characters, Código do Fornecedor
@param cLojForn, characters, Loja do Fornecedor
@param aDiaHist, array, Histórico dos dias
@param aTabPag, array, Tabela a pagar
@param cTipCont, characters, Tipo do Contrato
@param lTMSItCt, logical, TmsUniNeg()
@param nLinha, numeric, linha
@param lSimula, boolean, Simulação
@param aSimula,array,tabelas para simulação
@param aDocNPrev,array,documentos não previstos
@type function
/*/
Function A250FrePag( cFilOri , cViagem , cCodVei,  aMsgErr , lMsgErr , aFrete , nGrupVei, cCodForn, cLojForn, aDiaHist ,  aTabPag, cTipCont , lTMSItCt, nLinha , lSimula , aSimula, aDocNPrev )
Local aArea			:= GetArea()
Local aAreaDTQ		:= DTQ->(GetArea())
Local aRet			:= {}
Local cSerOld		:= ""
Local cTabFre		:= ""
Local cTipTab		:= ""
Local cTabCar		:= ""
Local nMaxCus		:= 0
Local nCount		:= 1
Local nTab			:= 1
Local nSeek			:= 0
Local aTabPagCar	:= {}
Local aAux			:= {}
Local cCodNeg		:= ""
Local cServic		:= ""
Local cQuery		:= ""
Local lColeta 		:= .T.

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodVei		:= ""
Default aMSgErr		:= {}
Default lMsgErr		:= .T.
Default aFrete		:= {}
Default nGrupVei	:= 0
Default cCodForn	:= ""
Default cLojForn	:= ""
Default aDiaHist	:= {}
Default aTabPag		:= {}
Default cTipCont	:= "1" //-- Por Viagem
Default lTMSItCt	:= Iif(FindFunction("TmsUniNeg"),TmsUniNeg(),.F.)
Default nLinha		:= 0
Default lSimula		:= .F.
Default aSimula		:= {}
Default aDocNPrev   := {}

DTQ->(dbSetOrder(2))//-- FILIAL+FILORI+VIAGEM
If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aRet                               ³
	//³ [01] - Tabela de Frete a Pagar                        ³
	//³ [02] - Tipo da Tabela de Frete                        ³
	//³ [03] - Valor do Frete                                 ³
	//³ [04] - Qtd. de Volumes informada no Reg. de Ocorrencia³
	//³ [05] - Peso informado no Reg. de Ocorrencia           ³
	//³ [06] - Qtd. de Documentos                             ³
	//³ [07] - No. de Diarias (Semana)                        ³
	//³ [08] - Kms Percorridos                                ³
	//³ [09] - No. de Diarias (Fim de Semana)                 ³
	//³ [10] - Gera Titulo de Pedagio ?                       ³
	//³ [11] - Deduz valor do Pedagio do Valor do Frete ?     ³
	//³ [12] - Valor Base para calculo dos impostos           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCount := 1 to 2
		If nCount == 1
			cSerOld := DTQ->DTQ_SERTMS
		ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_SERADI == '1' .And. Len(aFrete) < 2
			cSerOld := DTQ->DTQ_SERADI

			cQuery := " SELECT DUD_VIAGEM"
			cQuery += " FROM " + RetSqlName("DUD")
			cQuery += " WHERE  DUD_FILORI = '"+ DTQ->DTQ_FILORI +"'"
			cQuery += " AND    DUD_VIAGEM = '"+ DTQ->DTQ_VIAGEM  +"'"
			cQuery += " AND    DUD_SERTMS = '" +StrZero( 1, Len( DUD->DUD_SERTMS) )  +"'"
			cQuery += " AND    DUD_FILIAL = '" +xFilial("DUD") +"'"
			cQuery += " AND    D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			aAreaAux := GetArea()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(Eof() )
				lColeta := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
			RestArea(aAreaAux)

			If !lColeta
				Exit
			EndIf

		Else
			Exit
		EndIf

		//--Localiza a Tabela de frete a pagar x o contrato do cliente quando utilizar novo conceito de negociação de frete
        Begin Sequence
            aTabPag := TmsTabPag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,cCodVei)
            If Len(aTabPag) > 1
                For nTab := 1  to Len(aTabPag)
                    cTabFre := aTabPag[nTab][1]
                    cTipTab := aTabPag[nTab][2]
                    cTabCar := aTabPag[nTab][3]
                    nMaxCus := aTabPag[nTab][4]
                    cCodNeg	:= aTabPag[nTab][5]
                    cServic	:= aTabPag[nTab][6]

                    aRet	:= TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., @aFrete, nGrupVei,,,@aDiaHist, cSerOld,cTabFre,cTipTab,cTabCar,.T., nMaxCus,,aDocNPrev)

                    If Len(aTabPag) > 0 .And. Empty(aMsgErr)
                        AAdd(aTabPagCar,{aRet[1,1], aRet[1,2], aRet[1][13], Transform(aRet[1,3],PesqPict('DTY','DTY_VALFRE')), aRet[1,16]})

                        aAux	:= RetArrSimula(aRet, lSimula, cTabFre , cTipTab , cTabCar , nMaxCus, cCodNeg, cServic)
                        If Len(aAux) > 0
                            Aadd(aSimula,aAux)
                        EndIf

                    Else
                        Break
                    EndIf
                Next nTab

                nSeek := Ascan(aTabPagCar, {|x| x[1] + x[2] + x[3] == aRet[1,1] + aRet[1,2] + aRet[1,13] })
                If nSeek == 0
                    AAdd(aTabPagCar,{aRet[1,2], aRet[1,3], aRet[1,13], aRet[1,3]})

                    aAux	:= RetArrSimula(aRet, lSimula, cTabFre , cTipTab , cTabCar , nMaxCus ,cCodNeg, cServic)
                    If Len(aAux) > 0
                        Aadd(aSimula,aAux)
                    EndIf

                EndIf

                If Len(aTabPagCar) > 1 .And. !lSimula
                    nLinha := TmsTabFpg( aTabPagCar , DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
                    If nLinha > 0
                        cTabFre := aTabPag[nlinha,1] //-- Tabela de Frete a Pagar
                        cTipTab := aTabPag[nlinha,2] //-- Tipo da Tabela de Frete
                        cTabCar := aTabPag[nlinha,3] //-- Tabela de Carreteiro
                        nMaxCus := aTabPag[nLinha,4] //-- Percentual da Rentabilidade x Custo
                        cCodNeg	:= aTabPag[nLinha,5] //-- Código negociação
                        cServic	:= aTabPag[nLinha,6] //-- Código serviço

                        aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., @aFrete, nGrupVei,,,@aDiaHist, cSerOld,cTabFre,cTipTab,cTabCar,.T., nMaxCus,,aDocNPrev)

                    EndIf
                EndIf
            ElseIf Len(aTabpag) == 1
                cTabFre := aTabPag[1][1]
                cTipTab := aTabPag[1][2]
                cTabCar := aTabPag[1][3]
                nMaxCus := aTabPag[1][4]
                cCodNeg	:= aTabPag[1][5]
                cServic	:= aTabPag[1][6]

                aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., @aFrete, nGrupVei,,,@aDiaHist, cSerOld,cTabFre,cTipTab, cTabCar,.T., nMaxCus,,aDocNPrev)

                aAux	:= RetArrSimula(aRet, lSimula, cTabFre , cTipTab , cTabCar , nMaxCus ,cCodNeg, cServic)
                If Len(aAux) > 0
                    Aadd(aSimula,aAux)
                EndIf
            Else
                aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., @aFrete, nGrupVei,,,@aDiaHist, cSerOld,,,,,@nMaxCus,,aDocNPrev)

                aAux	:= RetArrSimula(aRet, lSimula, cTabFre , cTipTab , cTabCar , nMaxCus ,cCodNeg, cServic)
                If Len(aAux) > 0
                    Aadd(aSimula,aAux)
                EndIf

            EndIf

        End Sequence
	Next nCount

EndIf

RestArea(aAreaDTQ)
RestArea(aArea)
Return aRet

/*/{Protheus.doc} RetArrSimula
// Retorna o array que é utilizado pela Rentabilidade Prévia, contendo informações sobre os fretes calculados
@author caio.y
@since 12/07/2017
@version undefined
@param aRet, array, Array com cálculo a pagar
@param lSimula, logical, Indica se é uma simulação
@param cTabFre, character, Tabela de Frete
@param cTipTab, character, Tipo da Tabela
@param cTabCar, character, Tabela de Carreteiro
@param nMaxCus, numerical, PERCUS
@param cCodNeg, character, Código da Negociação
@param cServic, character, Código do Serviço
@type function
/*/
Static Function RetArrSimula(aRet, lSimula, cTabFre , cTipTab , cTabCar , nMaxCus ,cCodNeg, cServic)
Local aSimula	:= {}
Local aAux		:= {}

Default aRet	:= {}
Default lSimula	:= .F.
Default cTabFre	:= ""
Default cTipTab	:= ""
Default cTabCar	:= ""
Default nMaxCus	:= 0
Default cCodNeg	:= ""
Default cServic	:= ""

If lSimula
	aAux	:= aClone(aRet)

	If Len(aAux) > 0
		Aadd(aAux[Len(aAux)],cCodNeg)
		Aadd(aAux[Len(aAux)],cServic)
	EndIf

EndIf

Return aAux

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250BlqPg³ Autor ³Leandro Paulino        ³ Data ³04.10.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloqueia o pagamento do contrato de carreteiro              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250BlqPg( )											 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³												                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function A250BlqPg()

Local cAlias     := "DYH"
Local nField     := 0
Local nOpc       := 3
Local aDYH       := {}
Local aCamposDYH := {}
Local aNoFields  := {'DYH_DATLIB', 'DYH_HORLIB', 'DYH_HORLIB', 'DYH_USRLIB', 'DYH_NOMLIB', 'DYH_MOTLIB'}
Local aRetBox    := {}
Local cStatus    := ''
Local lRet       := .T.
Local lTpFrota   := DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local aRotBkp    := {}

If Type("aRotina") == "A"
    aRotina := Nil
    aRotBkp := aClone(aRotina)
EndIf

If lTpFrota .And. DTY->DTY_TIPFRO == '1'
	Help("",1,"TMSA25043") //-- Opção não disponível para contratos de frota própria
	Return .F.
EndIf

If AliasIndic("DYH")

    aDYH := APBuildHeader("DYH", aNoFields)

    For nField := 1 to Len(aDYH)
        AAdd(aCamposDYH, aDYH[nField][2])
    Next

    If !DTY->DTY_STATUS $ ('1|2')
        cStatus := RetCBox('DTY_STATUS', DTY->DTY_STATUS)
        MsgAlert(STR0170 + CRLF + STR0171 + cStatus) //--"Bloqueio de pagamento inválido para este contrato."//--"Status do Contrato: "
        lRet := .F.
    Else
        AxInclui( cAlias, 0, nOpc, aCamposDYH, "a250PreCpo()", , "a250BlqOk()")
    EndIf
EndIf

If aRotBkp != Nil
	aRotina := aClone(aRotBkp)
EndIf
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250LibPg³ Autor ³Leandro Paulino        ³ Data ³04.10.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Libera   o pagamento do contrato de carreteiro              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250LibPg( )											 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³												                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function A250LibPg()

Local cAlias 	:= "DYH"
Local nOpc	 	:= 4
Local aRetBox  := {}
Local cStatus  := ''
Local lRet		:= .T.
Local nRecDYH  := 0
Local cSeekDYH := ""
Local lTpFrota := DTY->(ColumnPos("DTY_TIPFRO")) > 0
Local aRotBkp    := {}

If Type("aRotina") == "A"
    aRotBkp := aClone(aRotina)
    aRotina := Nil
EndIf

If lTpFrota .And. DTY->DTY_TIPFRO == '1'
	Help("",1,"TMSA25043") //-- Opção não disponível para contratos de frota própria
	Return .F.
EndIf

DYH->(dbSetOrder(1))

If DTY->DTY_STATUS <> '9'
	cStatus := RetCBox('DTY_STATUS', DTY->DTY_STATUS)
	MsgAlert(STR0163 + CRLF + STR0164 + cStatus) //--"Liberacao de pagamento inválida para este contrato."... "Status do Contrato: "
	lRet := .F.
Else
	DYH->(dbSeek(cSeekDYH := xFilial("DYH")+DTY->(DTY_FILORI+DTY_NUMCTC)))
	While DYH->(!Eof()) .And. DYH->(DYH_FILIAL+DYH_FILORI+DYH_NUMCTC) == cSeekDYH
		nRecDYH := DYH->(Recno())
		DYH->(dbSkip())
	EndDo
	DYH->(dbGoTo(nRecDYH))
	AxAltera( cAlias, nRecDYH, nOpc,,{"DYH_MOTLIB"},,,"a250BlqOk()",,"a250PreCpo()")
EndIf

If aRotBkp != Nil
	aRotina := aClone(aRotBkp)
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250HisBlq³ Autor ³Leandro Paulino       ³ Data ³04.10.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloqueia o pagamento do contrato de carreteiro              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250HisBlq( )											 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³												                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A250HisBlq()

Local cSeekDYH   := ""
Local aItens     := {}
Local aTitulo    := {}
Local aNewButton := {}

Aadd(aTitulo,FWX3Titulo('DYH_SEQBLQ'))
Aadd(aTitulo,FWX3Titulo('DYH_DATBLQ'))
Aadd(aTitulo,FWX3Titulo('DYH_HORBLQ'))
Aadd(aTitulo,FWX3Titulo('DYH_DATLIB'))
Aadd(aTitulo,FWX3Titulo('DYH_HORLIB'))

DYH->(dbSetOrder(1))
If DYH->(dbSeek(cSeekDYH := xFilial('DYH')+DTY->(DTY_FILORI+DTY_NUMCTC)))
	While DYH->(!Eof()) .And. DYH->(DYH_FILIAL+DYH_FILORI+DYH_NUMCTC) == cSeekDYH
		Aadd(aItens, { DYH->DYH_SEQBLQ, DYH->DYH_DATBLQ, Transform(DYH->DYH_HORBLQ,PesqPict('DYH','DYH_HORBLQ')), DYH->DYH_DATLIB, Transform(DYH->DYH_HORLIB,PesqPict('DYH','DYH_HORLIB'	)), DYH->(Recno()) } )
		DYH->(dbSkip())
	EndDo
	AAdd(aNewButton, {15,{|nAt| A250VisBlq(aItens[nAt,Len(aTitulo)+1]) } } )
	TmsF3Array( aTitulo, aItens, STR0165,, aNewButton ) //--'Histórico de Bloqueios de Pagamento'
Else
	MsgAlert(STR0166) //--'Não existem bloqueios de pagamento para este contrato!'
EndIf

Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250VisPg³ Autor ³Leandro Paulino        ³ Data ³04.10.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloqueia o pagamento do contrato de carreteiro              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250VisBlq( )											 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³												                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A250VisBlq(nRecDYH)

Default nRecDYH := 0

If nRecDYH > 0
	DYH->(dbGoTo(nRecDYH))
	AxVisual('DYH',DYH->(Recno()),2)
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a250PreCpo³ Autor ³Leandro Paulino        ³ Data ³04.10.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche campos com os dados do contrato de carreteiro      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a250PreCpo( )											 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³												                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function A250PreCpo()

Local cSeqBlq  := StrZero(0,Len(DYH->DYH_SEQBLQ))
Local cSeekDYH := ""

If Empty(M->DYH_NUMCTC) //--Bloqueio
	DYH->(dbSetOrder(1))
	DYH->(dbSeek(cSeekDYH := xFilial("DYH")+DTY->(DTY_FILORI+DTY_NUMCTC)))
	While DYH->(!Eof()) .And. DYH->(DYH_FILIAL+DYH_FILORI+DYH_NUMCTC) == cSeekDYH
	   cSeqBlq := DYH->DYH_SEQBLQ
		DYH->(dbSkip())
	EndDo
	M->DYH_FILIAL := xFilial("DYH")
	M->DYH_FILORI := DTY->DTY_FILORI
	M->DYH_NUMCTC := DTY->DTY_NUMCTC
	M->DYH_SEQBLQ := Soma1(cSeqBlq)
	M->DYH_DATBLQ := ddataBase
	M->DYH_HORBLQ := StrTran(Left(Time(),5),':','')
	M->DYH_NOMBLQ := UsrFullName(M->DYH_USRBLQ)
Else                                //--Liberacao
	M->DYH_DATLIB := ddataBase
	M->DYH_HORLIB := Time()
	M->DYH_NOMLIB := UsrFullName(M->DYH_USRLIB)
	M->DYH_DATLIB := ddataBase
	M->DYH_HORLIB := StrTran(Left(Time(),5),':','')
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a250BlqOk³ Autor ³Leandro Paulino       	  ³ Data ³04.10.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche campos com os dados do contrato de carreteiro      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a250BlqOk( )												 		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³												                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function a250BlqOk()

Local lRet 		:= .T.
Local cFilOri  := DTY->DTY_FILORI
Local cNumCTC  := DTY->DTY_NUMCTC
Local cSeekDTY := ''
Local cStaViag := ''
Local cAcao 	:= IIf(Empty(M->DYH_DATLIB),'1','2')
Local lLibCTC  := SuperGetMV( 'MV_LIBCTC',, .F. )

If (Iif(cAcao == '1', !Empty(M->DYH_MOTBLQ), !Empty(M->DYH_MOTLIB)))

	DTY->(dbSetOrder(4))
	If DTY->(dbSeek(cSeekDTY := xFilial('DTY')+cFilOri+cNumCTC ))
		cStaViag := Posicione('DTQ',2,xFilial('DTQ')+DTY->DTY_FILORI+DTY->DTY_VIAGEM,'DTQ_STATUS')
		While DTY->(!Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_NUMCTC) == cSeekDTY
			RecLock("DTY",.F.)
			DTY->DTY_STATUS := IIf (cAcao =='1','9',IIf(lLibCTC .And. cStaViag == '3','2','1'))
			MsUnLock()
			DTY->(dbSkip())
		EndDo
	EndIf
Else
	MsgAlert (STR0167 + IIf(cAcao=='1', STR0168,STR0169) ) //--"Informe o Motivo "..'do bloqueio'..'da liberacao'
	lRet := .F.
EndIf

Return lRet
/*/-----------------------------------------------------------
{Protheus.doc} A250ExcCtc()
Exclusão de registro no Modelo

Uso: TMSA250

@sample
//A250ExcCtc()

@author Paulo Henrique Corrêa Cardoso.
@since 01/09/2017
@version 1.0
-----------------------------------------------------------/*/
Function A250ExcCtc()
	FWExecView( STR0005 ,'TMSA250',MODEL_OPERATION_DELETE,, { || .T. },{ || .T. },,,{ || .T. })  //"Excluir"
Return

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} A250ChkOpe(cCodOpe,cFilOri,cViagem,aRetOpe)

Funcao de Checagem da viagem junto à operadora

Rotina de consulta de status e valores junto à operadora para verificação na geração/liberação do contrato (TMSA251 e 250Qbr)

@author daniel.leme

@since 28/09/2017
@version 1.0
/*/
//--------------------------------------------------------------------------------------
Function A250ChkOpe(cCodOpe,cFilOri,cViagem,aRetOpe, aMsgErr)
Local lRet := .F.
Local cImpostos := "|103|1|116|100|108|2|109|3|"
Local cAdiantam := "|131|"
Local cMovCompl := "|"
Local cMovTxCar := "|118|" //-- Taxa de desconto por troca de cartão pelo motorista
Local nValCompl := 0
Local lOtherMov := .F.
Local nValMov   := 0
Local aAux,nAux
Local cMovDescon:= '6'
Default cCodOpe := ''
Default cFilori := ''
Default cViagem := ''
Default aRetOpe := {}
Default aMsgErr := {}

oXmlChk := Nil
If cCodOpe == "01" //-- Repom
	DEG->(DbSetOrder(1))
	DTR->(DbSetOrder(1)) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
	If DEG->(MsSeek(xFilial('DEG')+cCodOpe)) .And. DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
		oXmlChk := TmsConsRep( DEG->DEG_IDOPE, DEG->DEG_CODACE, DEG->DEG_URLWS, cFilOri, DTR->DTR_PRCTRA, cFilOri+cViagem )
		If ValType( oXmlChk ) == 'O'

			aRetOpe    := Array(4)
			aRetOpe[1] := AllTrim(oXmlChk:_Processo_Transporte:_status_codigo:Text)	//-- [1] Status Repom
			aRetOpe[2] := {}														//-- [2] Array Movtos
			aRetOpe[3] := 0															//-- [3] Valor Saldo Repom
			aRetOpe[4] := 0															//-- [4] Valor Complementares Repom

			If Type("oXmlChk:_Processo_Transporte:_Movimentos:_Movimento") <> "U"
				If Valtype(oXmlChk:_Processo_Transporte:_Movimentos:_Movimento) == "A"
					aAux := oXmlChk:_Processo_Transporte:_Movimentos:_Movimento
					For nAux := 1 to Len(aAux)
						aAdd(aRetOpe[2],{ aAux[nAux]:_Movimento_Codigo:Text, Val(aAux[nAux]:_Valor:Text) })
					Next
				ElseIf Valtype(oXmlChk:_Processo_Transporte:_Movimentos:_Movimento) == "O"
					aAdd(aRetOpe[2],{ oXmlChk:_Processo_Transporte:_Movimentos:_Movimento:_Movimento_Codigo:Text, Val(oXmlChk:_Processo_Transporte:_Movimentos:_Movimento:_Valor:Text) })
				EndIf
			EndIf

			//-- Verifica se há movimentos gerados por contratos complementares
			DEN->(DbSetOrder(1)) //-- DEN_FILIAL+DEN_FILORI+DEN_VIAGEM+DTOS(DEN_DTMOV)+DEN_HRMOV
			DEN->(MsSeek(xFilial('DEN')+DTY->(DTY_FILORI+DTY_VIAGEM)))
			While DEN->(DEN_FILIAL+DEN_FILORI+DEN_VIAGEM) == xFilial('DEN')+DTY->(DTY_FILORI+DTY_VIAGEM)
				If DEN->DEN_RECENV == 'E'
					cMovCompl += AllTrim(DEN->DEN_CODMOV) + "|"
					nValCompl += DEN->DEN_VALOR
				EndIf
				DEN->(DbSkip())
			EndDo

			aAux := aRetOpe[2]
			For nAux := 1 to Len(aAux)
				//-- Soma os valores de movimento por: adiantamento e Impostos
				If cMovDescon <> AllTrim(aAux[nAux][1])
					If "|"+AllTrim(aAux[nAux][1])+"|" $ cAdiantam + cImpostos
						aRetOpe[3] += aAux[nAux][2]
					//-- Valida o Valor dos Complementos, subtraindo-os do saldo do contrato ativo.
					ElseIf "|"+AllTrim(aAux[nAux][1])+"|" $ cMovCompl
						aRetOpe[3] -= aAux[nAux][2]
						aRetOpe[4] += aAux[nAux][2]
					//-- Caso tenha taxa de desconto por troca de cartão pelo motorista, considera o valor como fret
					ElseIf "|"+AllTrim(aAux[nAux][1])+"|" $ cMovTxCar
						aRetOpe[3] += aAux[nAux][2]
					Else
						lOtherMov := .T.
					EndIf
				EndIf
			Next

			//-- Soma o valor do saldo disponível na Repom
			If Type("oXmlChk:_Processo_Transporte:_valor_saldo") <> "U"
				aRetOpe[3] += Val(StrTran(oXmlChk:_Processo_Transporte:_valor_saldo:Text,",",""))
			EndIf

			//-- Calcula o Valor total de Movimentos para o Contrato
			nValMov := DTY->DTY_VALFRE - DTR->(Iif(DTR->DTR_FRECAL == '1', DTR_PRVFRE, DTR_VALFRE))
			If DTY->(ColumnPos('DTY_VLREEM')) > 0
				nValMov += DTY->DTY_VLREEM
			EndIf

			If !("|"+aRetOpe[1]+"|" $ "|1|10|") .Or. ; //-- diferente de "Em Transito/Pendente"  ou
			   aRetOpe[4] <> nValCompl .Or. ; //-- Valor de Complemento maior que o previsto
			   DTR->(aRetOpe[3] <> Iif(DTR_FRECAL=='1',DTR_PRVFRE,DTR_VALFRE))  .Or. ;//-- Valor diferente do enviado originalmente ou
			   lOtherMov   //-- Com movimentação
			   Aadd( aMsgErr,{STR0288 + cFilOri+"/"+cViagem + STR0293 ,"01",""})//--"Viagem "//--" possui integração com a Repom e encontra-se em divergência de valores ou status entre o TMS e a Operadora!"
			   Aadd( aMsgErr,{STR0294,"01",""})//--"Entre em contato com a operadora Repom e corrija os valores e movimentos. "
			   Aadd( aMsgErr,{STR0295+ AllToChar(aRetOpe[1])  ,"01",""}) //--"Status Esperado: 1 ou 10, Status Repom:"
			   Aadd( aMsgErr,{STR0297 + AllTrim(Transform( DTR->(Iif(DTR_FRECAL=='1',DTR_PRVFRE,DTR_VALFRE)), PesqPict("DTR","DTR_VALFRE") )) + ;//--"Valor Esperado: "
			   				  ", " + STR0298 + AllTrim(Transform( aRetOpe[3], PesqPict("DTR","DTR_VALFRE"))),"01",""} )//--" Valor na Repom: "
			   Aadd( aMsgErr,{STR0299 + AllTrim(Transform( nValCompl, PesqPict("DTR","DTR_VALFRE") )) + ; //--"Valor Complementar Esperado: "
			                  ", " + STR0300 + AllTrim(Transform( aRetOpe[4], PesqPict("DTR","DTR_VALFRE"))),"01",""}) //--", Valor Complementar na Repom: "
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		EndIf

	EndIf
EndIf
oXmlChk := Nil
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA250Obs³ Autor ³ Rodolfo K Rosseto     ³ Data ³17.02.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Observacao do Contrato                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA250Obs(nOpc)

Local oDlgObs
Local nOpcao   := 0
Local cObsMsg  := ""

Default nOpc := 2

If !Empty(DTY->DTY_CODOBS)
	cObsMsg := MSMM(DTY->DTY_CODOBS,80)
EndIf

DEFINE MSDIALOG oDlgObs TITLE STR0137 FROM 15,20 TO 25,62 //--"Observacao"

@ 0.5,0.7  GET oGet VAR cObsMsg OF oDlgObs MEMO size 150,40

If nOpc == 2 //--Visualizacao
	oGet :lReadOnly:= .T.
EndIf

DEFINE SBUTTON FROM 52,100 TYPE 1 OF oDlgObs ENABLE ACTION (nOpcao := 1,oDlgObs:End())
DEFINE SBUTTON FROM 52,128 TYPE 2 OF oDlgObs ENABLE ACTION (nOpcao := 0,oDlgObs:End())

ACTIVATE MSDIALOG oDlgObs CENTERED

If nOpcao == 1 .And. nOpc != 2 //So grava se nao for visualizacao
	MSMM(,,,cObsMsg,1,,,"DTY","DTY_CODOBS")
EndIf
Return NIL

/*/{Protheus.doc} TMA250Perg(cGroup, lAsk)

Efetua a chamada do pergunte.
Funcao criada para tratar a não conformidade criada no SonarQube referente a chamadas de pergunte dentro de loop.

@author Wander Horongoso

@since 28/02/2018
@version 1.0
/*/

Static Function TMA250Perg(cGroup, lAsk)

  Pergunte (cGroup, lAsk)

 Return

 /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS250LOG³   Autor ³ Clovis Nunes do Nascimento    ³21/10/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona mensagens que serão gerados no log de processame   ³±±
±±³            nto.                                                   		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AADMsgTMS250(cTMS250MSG,cTMS250FU)

AADD(aMsgErPa,{cTMS250MSG,'', cTMS250FU})

 Return