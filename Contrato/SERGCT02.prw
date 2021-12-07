#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*/{Protheus.doc} ModelDef
Encerramento da medicao do contrato com o CMV.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel  := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStCND   := FWFormStruct(1, "CND")
	Local oStCXN   := FWFormStruct(1, "CXN")
	Local oStCNE   := FWFormStruct(1, "CNE")
	Local oStSZ1   := FWFormStruct(1, "SZ1")

	Local bLoadDADOS := {|oFieldModel, lCopy| loadField(oFieldModel, lCopy)}
	Local bCommit  := {|oModel| Commit(oModel)}
	Local bPos	   := {|oModel| TdOkModel(oModel)}

	oStSZ1:AddField(	"",; //Título do campo
	"",; //cToolTip
	"Z1_MARK",;// Id do Campo
	"L",; //cTipo
	1,; //Tamanho do Campo
	0)//Decimal

	oStSZ1:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Z1_YLEGE",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(SZ1->Z1_VENCTO < DDATABASE,'F10_VERM','F10_VERD')"),;	                    // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual

	oStCXN:AddField("" ,;											// [01] Titulo do campo
	"",;														    // [02] ToolTip do campo
	"CXN_YPERSON",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "BMPUSER"},;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual

	oStCXN:AddField("" ,;											// [01] Titulo do campo
	"",;														    // [02] ToolTip do campo
	"CXN_FORNOME",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || POSICIONE('SA2',1,XFILIAL('SA2') + CXN->(CXN_FORNEC + CXN_LJFORN),"A2_NOME")},;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	)


	oStCND:SetProperty( '*' 		, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStCXN:SetProperty( '*' 		, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStCNE:SetProperty( '*' 		, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZ1:SetProperty( '*' 		, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZ1:SetProperty( 'Z1_SALDO'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZ1:SetProperty( 'Z1_MARK'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))

	oStSZ1:SetProperty( 'Z1_SALDO'	, MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'StaticCall(SERGCT02,ValidSaldo)'))

	// Cria o modelo
	oModel := MPFormModel():New("MSERGCT02",/*bPre*/, /*bPos*/,bCommit,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("CNDMASTER",/*cOwner*/, oStCND)
	oModel:AddGrid("CXNDETAIL","CNDMASTER",oStCXN,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("CNEDETAIL","CXNDETAIL",oStCNE,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:AddGrid("SZ1DETAIL","CXNDETAIL",oStSZ1,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetRelation('CXNDETAIL', {{'CXN_FILIAL','xFilial("CXN")'},{'CXN_CONTRA','CND_CONTRA'},{'CXN_REVISA','CND_REVISA'},{'CXN_NUMMED','CND_NUMMED'}},CXN->(IndexKey(1)))
	oModel:SetRelation('CNEDETAIL', {{'CNE_FILIAL','xFilial("CNE")'},{'CNE_CONTRA','CND_CONTRA'},{'CNE_REVISA','CND_REVISA'},{'CNE_NUMERO','CXN_NUMPLA'},{'CNE_NUMMED','CND_NUMMED'}},CNE->(IndexKey(1)))
	oModel:SetRelation("SZ1DETAIL", {{"Z1_FILIAL","xFilial('SZ1')"},{"Z1_FORNECE","CXN_FORNEC"},{"Z1_LOJA","CXN_LJFORN"}},SZ1->(IndexKey(1)))

	oModel:GetModel( "SZ1DETAIL" ):SetLoadFilter( { { "Z1_VENCTO", "'" + DTOS(DDATABASE) + "'", MVC_LOADFILTER_LESS_EQUAL } ,  { "Z1_SALDO", "0", MVC_LOADFILTER_GREATER }} )
	// Apenas planilhas confirmadas na medicao.
	oModel:GetModel( 'CXNDETAIL' ):SetLoadFilter( { { 'CXN_CHECK', "'T'" } } )
	oModel:GetModel( 'CNEDETAIL' ):SetLoadFilter( { { 'CNE_PEDTIT', "'2'" },{ "CNE_QUANT", "0", MVC_LOADFILTER_GREATER } } )

	oModel:GetModel("CXNDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("CXNDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("CNEDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("CNEDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SZ1DETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SZ1DETAIL"):SetNoInsertLine(.T.)

	bSumSel :=  {|| oModel:GetModel("SZ1DETAIL"):Getvalue("Z1_MARK") == .T. }

	bGetLiq	:= {|| GetLiq()}

	oModel:AddCalc("CALC_ITEM"	,"CXNDETAIL" ,"CNEDETAIL","CNE_VLTOT"	,"CNE_VLTOT_T"	,"SUM" 	, /*bCondition*/,  /*bInitValue*/,"Valor Medição (Base Imposto)"   ,/*bFormula*/,TAMSX3("CNE_VLTOT")[1] /*nTamanho*/,TAMSX3("CNE_VLTOT")[2] /*nDecimal*/)

	oModel:AddCalc("CALC_CMV"	,"CXNDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"Z1_SALDO_Q"	,"COUNT" 	, /*bCondition*/,  /*bInitValue*/,"Qtd."   ,/*bFormula*/,TAMSX3("Z1_SALDO")[1] /*nTamanho*/,TAMSX3("Z1_SALDO")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_CMV"	,"CXNDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"Z1_SALDO_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Saldo Total"   ,/*bFormula*/,TAMSX3("Z1_SALDO")[1] /*nTamanho*/,TAMSX3("Z1_SALDO")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_CMV"	,"CXNDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"Z1_SALDO_S"	,"SUM" 		, bSumSel/*bCondition*/,  /*bInitValue*/,"R$ À Descontar"   , /*bFormula*/ ,TAMSX3("Z1_SALDO")[1] /*nTamanho*/,TAMSX3("Z1_SALDO")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_CMV"	,"CXNDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"Z1_SALDO_R"	,"FORMULA" 	, /*bCondition*/, bGetLiq /*bInitValue*/,"R$ Liq. (s/ Imp.)"   ,bGetLiq /*bFormula*/ ,TAMSX3("Z1_SALDO")[1] /*nTamanho*/,TAMSX3("Z1_SALDO")[2] /*nDecimal*/)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({})

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)

	oModel:GetModel("CNDMASTER"):SetOnlyQuery(.T.)
	oModel:GetModel("CXNDETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("CNEDETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("SZ1DETAIL"):SetOnlyQuery(.T.)

	oModel:GetModel( "SZ1DETAIL" ):SetOptional( .T. )

	//Adicionando descrição ao modelo
	oModel:SetDescription("Encerramento Medição")

	oModel:lModify := .t.

	//Descricoes dos modelos de dados
	oModel:GetModel("CNDMASTER"):SetDescription("Dados da Medição")

	oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	// Recupera o modelo de dados
	Local oModel 	:= FWLoadModel("SERGCT02")

	Local cFieSZ1 	:= "Z1_MARK,Z1_YLEGE,Z1_DESPESA,Z1_SALDO,Z1_NUM,Z1_PARCELA,Z1_EMISSAO,Z1_VENCTO,Z1_VALOR,Z1_HISTORI"
	Local aFieSZ1 	:= StrTokArr(cFieSZ1,",")
	Local cFieCND	:= "CND_NUMMED|CND_CONTRA|CND_REVISA|CND_PARCEL|CND_DTFIM|CND_OBS|CND_DTVENC|CND_ZERO|CND_CONDPG|CND_DESCCP|CND_APROV|CND_AUTFRN|CND_PEDIDO|CND_SERVIC|CND_FILCTR|CND_REVGER|CND_MOEDA|CND_COMPET"
	Local cFieCXN 	:= "CXN_YPERSON,CXN_FORNEC,CXN_LJFORN,CXN_FORNOME,CXN_NUMPLA"
	Local aFieCXN 	:= StrTokArr(cFieCXN,",")

	Local cFieCNE 	:= "CNE_ITEM,CNE_PRODUT,CNE_DESCRI,CNE_QUANT,CNE_VLUNIT,CNE_VLTOT"
	Local aFieCNE 	:= StrTokArr(cFieCNE,",")

	//Criação da estrutura de dados da View
	Local oStCND 	:= FWFormStruct(2, "CND",{ |x| ALLTRIM(x) $ cFieCND })
	Local oStCXN 	:= FWFormStruct(2, "CXN",{ |x| ALLTRIM(x) $ cFieCXN })
	Local oStCNE 	:= FWFormStruct(2, "CNE",{ |x| ALLTRIM(x) $ cFieCNE })
	Local oStSZ1 	:= FWFormStruct(2, "SZ1",{ |x| ALLTRIM(x) $ cFieSZ1 })
	Local oCalcCMV 	:= FWCalcStruct(oModel:GetModel("CALC_CMV"))
	Local oCalcITEM := FWCalcStruct(oModel:GetModel("CALC_ITEM"))
	Local oView  	:= Nil
	Local i		 	:= 0

	oStSZ1:AddField("Z1_MARK",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"")//cPicture

	oStSZ1:AddField("Z1_YLEGE",; //Id do Campo
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStCXN:AddField("CXN_YPERSON",; //Id do Campo
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStCXN:AddField("CXN_FORNOME",; //Id do Campo
	"99",; //Ordem
	"Nome",;// Título do Campo
	"Nome",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo
	""  )//cPicture

	// Refaz a ordem
	For i := 1 To Len(aFieSZ1)
		If i < 10
			oStSZ1:SetProperty( aFieSZ1[i], MVC_VIEW_ORDEM, "0" + Alltrim(STR(i)))
		Else
			oStSZ1:SetProperty( aFieSZ1[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	For i := 1 To Len(aFieCXN)
		If i < 10
			oStCXN:SetProperty( aFieCXN[i], MVC_VIEW_ORDEM, "0" + Alltrim(STR(i)))
		Else
			oStCXN:SetProperty( aFieCXN[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	oStSZ1:SetProperty( "Z1_SALDO"  , MVC_VIEW_CANCHANGE ,.T.)
	oStSZ1:SetProperty( "Z1_DESPESA", MVC_VIEW_WIDTH, 200 )
	oStSZ1:SetProperty( "Z1_SALDO"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_NUM"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_PARCELA", MVC_VIEW_WIDTH, 070 )
	oStSZ1:SetProperty( "Z1_VALOR"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_EMISSAO", MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_VENCTO"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_HISTORI", MVC_VIEW_WIDTH, 090 )

	oStCXN:SetProperty( "*"			 , MVC_VIEW_WIDTH, 090 )
	oStCXN:SetProperty( "CXN_FORNOME", MVC_VIEW_WIDTH, 200 )

	oStCNE:SetProperty( "CNE_ITEM"	, MVC_VIEW_WIDTH, 090 )
	oStCNE:SetProperty( "CNE_DESCRI", MVC_VIEW_WIDTH, 300 )
	oStCNE:SetProperty( "CNE_QUANT"	, MVC_VIEW_WIDTH, 090 )
	oStCNE:SetProperty( "CNE_VLUNIT", MVC_VIEW_WIDTH, 090 )
	oStCNE:SetProperty( "CNE_VLTOT"	, MVC_VIEW_WIDTH, 090 )

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Atribuindo fomulários para interface
	oView:AddGrid("VIEW_CXN"  		, oStCXN 	, "CXNDETAIL")
	oView:AddGrid("VIEW_CNE"  		, oStCNE 	, "CNEDETAIL")
	oView:AddGrid("VIEW_SZ1"  		, oStSZ1 	, "SZ1DETAIL")
	oView:AddField("VIEW_CALC_CMV"  , oCalcCMV 	, "CALC_CMV")
	oView:AddField("VIEW_CALC_ITEM" , oCalcITEM , "CALC_ITEM")

	//Criando os paineis

	oView:CreateHorizontalBox("TOTAL",100)

	oView:CreateVerticalBox("ESQUERDA",040,"TOTAL")
	oView:CreateVerticalBox("DIREITA" ,060,"TOTAL")

	oView:CreateHorizontalBox("SUPERIOR",035,"DIREITA")
	oView:CreateHorizontalBox("CALCITEM",010,"DIREITA")
	oView:CreateHorizontalBox("GRIDCMV"	,045,"DIREITA")
	oView:CreateHorizontalBox("INFERIOR",010,"DIREITA")

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_CXN"		,"ESQUERDA")
	oView:SetOwnerView("VIEW_CNE"		,"SUPERIOR")
	oView:SetOwnerView("VIEW_CALC_ITEM" ,"CALCITEM")
	oView:SetOwnerView("VIEW_SZ1"		,"GRIDCMV")
	oView:SetOwnerView("VIEW_CALC_CMV"	,"INFERIOR")

	oView:EnableTitleView("VIEW_CNE" 	, "Itens da Medição" )
	oView:EnableTitleView("VIEW_CXN" 	, "Prestadores de Serviços" )
	oView:EnableTitleView("VIEW_SZ1" 	, "Despesas CMV" )

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

	oView:setUpdateMessage("Encerramento Medição", "Realizada com sucesso!!")

	oView:AddUserButton("F5 - Inverter marcação"		,"MAGIC_BMP",{|| MarkAll()}	,"Comentário do botão")
	oView:AddUserButton("F6 - Atualizar Despesas CMV"	,"MAGIC_BMP",{|| FWMsgRun(, {||AtuaCMV(oModel)}   , "Processando", "Atualizando as informações...")}	,"Comentário do botão")

	SetKey(VK_F5, {|| MarkAll()})
	SetKey(VK_F6, {|| FWMsgRun(, {||AtuaCMV(oModel)}   , "Processando", "Atualizando as informações...")})

	// configura a pintura do acols
	cCSS := " QTableView "
	cCSS += " { "
	cCSS += "	selection-background-color: #1C9DBD "
	cCSS += " } "

	// configura pintura do aHeader
	cCSS += " QHeaderView::section "
	cCSS += " { "
	cCSS += "	background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #AAAAAA, stop: 0.5 #8E8E8E, stop: 0.6 #8D8D8D, stop:1 #7F7F7F); "
	cCSS += " color: white; "
	cCSS += " border: 1px solid #8E8E8E; "
	cCSS += "	padding-left: 4px; "
	cCSS += " padding-right: 4px; "
	cCSS += " padding-top: 4px; "
	cCSS += " padding-bottom: 4px; "
	cCSS += " } "

	oView:SetViewProperty("*", "SETCSS", { cCSS } )

Return oView

/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 15/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function Commit(oModel)

	Local lRet 		:= .T.

	BEGIN TRANSACTION

		If lRet
			// Encerra a medição do contrato
			FWMsgRun(, {|| lRet := EncerMed(oModel) }		, "Processando", "SERGCT02 - Gerando Encerramento da Medição.")
		End if

		If lRet
			// Realiza integracao dos titulos do contrato e imprime o RPC
			FWMsgRun(, {|| lRet := FinEncer(oModel) }		, "Processando", "SERGCT02 - Integrando no Financeiro...")
		End if

		If lRet
			FWMsgRun(, {|| U_RPCGCT() }		, "Processando", "SERGCT02 - Imprimindo RPC...")
		End if

		// Caso encontre algum erro
		If !lRet
			DisarmTransaction()
		End If

	END TRANSACTION

Return lRet

/*/{Protheus.doc} ValidActv
Validacao do modelo de dados
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function ValidActv(oModel)

	Local lRet	:= .t.

	CN9->(DbSetOrder(1))
	//CND_FILIAL, CND_CONTRA, CND_REVISA, CND_NUMERO, CND_NUMMED, R_E_C_N_O_, D_E_L_E_T_
	If CN9->(DbSeek(xFilial("CN9") + CND->(CND_CONTRA + CND_REVISA)))

		CN1->(DbSetOrder(1))
		//CN1_FILIAL, CN1_CODIGO, CN1_ESPCTR, R_E_C_N_O_, D_E_L_E_T_
		If CN1->(DbSeek(xFilial("CN1") + CN9->CN9_TPCTO))

			// Contrato Venda
			If Alltrim(CN1->CN1_ESPCTR) == '2'
				cMsg  := "Apenas contratos do tipo COMPRA pode ser encerrado nesta rotina."
				cSolu := "Favor selecionar outro contrato."
				Help(NIL, NIL, "SERGCT02 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End if

		End If
	End iF

Return lRet

/*/{Protheus.doc} EncerMed
Encerramento da medicao 
@author Totvs Vitoria - Mauricio Silva
@since 15/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function EncerMed(oModel)

	Local lRet := .t.

	// Solicita encerramento do contrato
	lRet := CN121Encerr(.T.)

	If !lRet
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(CN121Encerr)","Não foi possível foi encerrar a medição")
	EndIf

Return lRet

/*/{Protheus.doc} FinEncer
Baixa do CMV, criacao da NDF e compensacao dos titulos
@author Totvs Vitoria - Mauricio Silva
@since 15/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function FinEncer(oModel)

	Local lRet 		:= .t.
	Local oModelCXN := oModel:GetModel("CXNDETAIL")
	Local oModelSZ1	:= oModel:GetModel("SZ1DETAIL")
	Local oModelCNE	:= oModel:GetModel("CNEDETAIL")
	Local nTotReg	:= oModelCXN:Length()
	Local aChanLinh := {}
	Local aRet		:= {}
	Local i			:= 0
	Local w			:= 0
	Local cTextMsg	:= ""
	Local cLog		:= ""
	Local cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),TAMSX3("E2_PREFIXO")[1])
	Local cTpTit	:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),TAMSX3("E2_TIPO")[1])
	Local cParcela	:= StrZero(1,TAMSX3("E2_PARCELA")[1])
	Local aRecSE2	:= {}
	Local aRecCOMP	:= {}
	Local aObs		:= {}

	DT7->(DbSetOrder(1))
	CXJ->(DbSetOrder(1))
	SE2->(DbSetOrder(1))

	For i:= 1 to nTotReg

		oModelCXN:GoLine(i)

		If oModelCXN:IsDeleted()
			Loop
		End If

		aObs 	 := {}
		aRecSE2  := {}
		aRecCOMP := {}

		aChanLinh := oModelSZ1:GetLinesChanged()

		cTextMsg  := oModelCXN:GetValue("CXN_FORNOME")
		cContrato := oModelCNE:GetValue("CNE_CONTRA")
		cPlanilha := oModelCNE:GetValue("CNE_NUMERO")
		cNumMedic := oModelCNE:GetValue("CNE_NUMMED")
		cCodItemP := oModelCNE:GetValue("CNE_ITEM")
		cCodForne := oModelCXN:GetValue("CXN_FORNEC")
		cLojForne := oModelCXN:GetValue("CXN_LJFORN")

		// Posiciona nos documentos criados pelo encerramento da medicao.
		//CXJ_FILIAL, CXJ_CONTRA, CXJ_NUMMED, CXJ_NUMPLA, CXJ_ITEMPL, CXJ_PRTENV, CXJ_ID, R_E_C_N_O_, D_E_L_E_T_
		If !CXJ->(DbSeek(xFilial("CXJ") + cContrato + cNumMedic + cPlanilha + cCodItemP ))
			cErro := "Não foi possível localizar os documentos gerados na tabela CXJ."
			cSolu := "Favor verificar o encerramento da medicao."
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(FinEncer)",cErro,cSolu)
			Return .f.
		End if

		// Verifica o numero do titulo.
		If !Empty(CXJ->CXJ_NUMTIT)
			cTitulo := CXJ->CXJ_NUMTIT
		Else
			cErro := "Este encerramento não gerou titulo a pagar para o fornecedor: " + cCodForne
			cSolu := "Favor validar verificando a tabela CXJ."
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(FinEncer)",cErro,cSolu)
			Return .f.
		End iF

		// Localiza o titulo no financeiro apos o encerramento da medicao.
		//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If !SE2->(DbSeek(xFilial("SE2") + cRetPrf + cTitulo + cParcela + cTpTit + cCodForne + cLojForne ))
			cErro := "Não foi possível localizar o titulo :" + xFilial("SE2") + cRetPrf + cTitulo + cParcela + cTpTit + cCodForne + cLojForne + " no financeiro."
			cSolu := "Favor verificar o contas a pagar."
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(FinEncer)",cErro,cSolu)
			Return .f.
		End if

		// Adicion o titulo principal para ser compensado.
		AADD(aRecSE2,SE2->(RECNO()))

		For w:= 1 to len(aChanLinh)

			//Posiciona na linha da SZ1
			oModelSZ1:GoLine(aChanLinh[w])

			If oModelSZ1:IsDeleted()
				Loop
			End If

			// Verifica se a linha esta' marcada para ser descontada
			If oModelSZ1:GetValue("Z1_MARK")

				// Posiciona no cadastro de despesa
				DT7->(DbSeek(xFilial("DT7") + oModelSZ1:GetValue("Z1_CODDESP")))
				cLog:= "Baixando CMV - Despesa: " + DT7->DT7_DESCRI

				// Chama a baixa do CMV
				MsgRun (cLog  ,cTextMsg , {|| aRet := BaixSZ1(oModel) } )

				If !aRet[1]
					Return .f.
				End if

				// Recupera o codigo do id do movimento da baixa do SZ2.
				cIdMOVSZ1 := aRet[2]

				cLog:= "Criando NDF - Despesa: " + DT7->DT7_DESCRI

				MsgRun (cLog  ,cTextMsg , {|| aRet := GeraNDF(oModel,cIdMOVSZ1) } )

				If !aRet[1]
					Return .f.
				End if

				// Adiciona no array para compensar depois
				AADD(aRecCOMP,aRet[2] )
			End if

		Next

		If len(aRecCOMP) > 0
			MsgRun ("Compensando Títulos no Financeiro...",  cTextMsg , {|| lRet := MaIntBxCP(2,aRecSE2,,aRecCOMP   ,,{.T.,.F.,.F.,.F.,.F.,.F.},{||}) } )

			If !lRet
				oModel:SetErrorMessage("",,oModel:GetId(),"","MaIntBxCP","Nao possivel realizar compensacao dos titulos.")
				Return .f.
			End If
		End IF

		//Validação do encerramento da medição apos geração dos titulos e abates no financeiro
		If lRet
			FWMsgRun(, {|| lRet := ValFinEncer(oModel,cTextMsg) }, cTextMsg, "SERGCT02 - Analisando Recibo de Produção...")

			If !lRet
				Return lRet //encerra o programa e volta tudo
			EndIf
		EndIf

//		// Imprime o RPC, o titulo ja esta posicionado
//		AADD(aObs,"CONTRATO: " + cContrato + " / MEDIÇÃO: " + cNumMedic + " / PLANILHA: " + cPlanilha + " / TITULO: " + SE2->(E2_FILIAL+ E2_PREFIXO+ E2_NUM+ E2_PARCELA+ E2_TIPO+ E2_FORNECE+ E2_LOJA))
//		U_SERR0002(,,,,aObs)

	Next

Return lRet

/*/{Protheus.doc} BaixSZ1
Baixa do CMV
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function BaixSZ1(oModel)

	Local oModelSZ1   := oModel:GetModel("SZ1DETAIL")
	Local oModelCND	  := oModel:GetModel("CNDMASTER")
	Local oModelBXSZ1 := Nil
	Local oModelSZ2   := Nil
	Local cErro		  := ""
	Local lValid	  := .T.
	Local cIdMov 	  := ""
	// Recupera os valores da CMV posicionada para realizar a baixa
	Local cFilial  := oModelSZ1:GetValue("Z1_FILIAL")
	Local cMoviment:= oModelSZ1:GetValue("Z1_NUM")
	Local cParcela := oModelSZ1:GetValue("Z1_PARCELA")
	Local cFornece := oModelSZ1:GetValue("Z1_FORNECE")
	Local cLoja	   := oModelSZ1:GetValue("Z1_LOJA")
	Local cChave   := cFilial + cFornece + cLoja + cMoviment + cParcela

	// Posiciona no registro
	SZ1->(DbGoto( oModelSZ1:GetDataId() ) )

	//Carrega o modelo
	oModelBXSZ1 := FWLoadModel("SERGPE01")
	oModelBXSZ1:SetOperation(MODEL_OPERATION_UPDATE)

	// Verifica se conseguiu ativar o modelo
	if !oModelBXSZ1:Activate()

		// Verifica o motivo de não ativação do modelo
		If oModelBXSZ1:HasErrorMessage()
			// Recupera o erro
			cErro := GetErroModel(oModelBXSZ1)
			// Seta erro dentro do Modelo Principal
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(BaixSZ1-Activate)",cErro)
			Return { .f., cIdMov }
		End If

	End if

	// Recupera o modelo da baixa
	oModelSZ2 := oModelBXSZ1:GetModel("SZ2DETAIL")

	// Verifica se o registro possui alguma baixa
	If !oModelSZ2:IsEmpty()
		// Adiciona uma linha no modelo.
		oModelSZ2:AddLine()
	End If

	If lValid
		lValid := oModelSZ2:SetValue("Z2_VALOR"  , oModelSZ1:GetValue("Z1_SALDO") )
	End If

	If lValid

		cContrato := Alltrim(oModelCND:GetValue("CND_CONTRA"))
		cNumMedic := Alltrim(oModelCND:GetValue("CND_NUMMED"))

		lValid := oModelSZ2:SetValue("Z2_HISTOR" ,"Filial/Contrato/Medicao: " + cFilAnt + "/" + cContrato + "/" + cNumMedic)
	End If

	If lValid
		lValid := oModelSZ2:SetValue("Z2_TIPMOV"  , "A" )
	End if

	If lValid
		// Informa que foi integrado via contrato, uma vez que a exclusao
		// da baixa so deixa excluir pela rotina geradora.
		lValid := oModelSZ2:SetValue("Z2_ROTINA"  , "CNTA121" )
	End if

	// Verifica o motivo de não ativação do modelo
	If oModelBXSZ1:HasErrorMessage() .and. !lValid
		// Recupera o erro
		cErro := GetErroModel(oModelBXSZ1)
		// Seta erro dentro do Modelo Principal
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(BaixSZ1-ValidCampo)",cErro)
		Return { .f., cIdMov }
	End If

	// Recupera o ID do movimento
	cIdMov := oModelSZ2:GetValue("Z2_IDMOV")

	if Empty(cIdMov)
		cErro:= "O Código do movimento da baixa do CMV :" + cChave + " retornou em branco (Z2_IDMOV)"
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(BaixSZ1)",cErro)
		Return { .f., cIdMov }
	End If

	// Realiza a validação do modelo
	If oModelBXSZ1:VldData()

		// Verifica se realizou o commit
		If !oModelBXSZ1:CommitData()
			// Recupera o erro do modelo
			cErro := GetErroModel(oModelBXSZ1)
			// Seta erro dentro do Modelo Principal - Tela de melhor Frete
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(BaixSZ1-CommitData)",cErro)
			Return { .f., cIdMov }
		End if
	Else
		// Recupera o erro do modelo
		cErro := GetErroModel(oModelBXSZ1)
		// Seta erro dentro do Modelo Principal - Tela de melhor Frete
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGCT02 - COMMIT(BaixSZ1-VldData)",cErro)
		Return { .f., cIdMov }
	End if

Return { .T., cIdMov }

/*/{Protheus.doc} GeraNDF
Geracao da NDF
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param cIdBaixa, characters, description
@type function
/*/
Static Function GeraNDF(oModel,cIdBaixa)

	Local aAreaSE2  := SE2->(GetArea())
	Local aArray 	:= {}
	Local cAliasSE2 := GetNextAlias()
	Local oModelSZ1 := oModel:GetModel("SZ1DETAIL")
	Local nValor	:= oModelSZ1:GetValue("Z1_SALDO")
	Local cNatDeb	:= ""
	Local cTipo		:= Padr( "NDF", Len( SE2->E2_TIPO ) )
	Local lRet  	:= .t.
	Local cParcela	:= ""
	Local nRecno	:= 0
	Local cNatuDeb	:= ""

	SE2->(DbSetOrder(1))

	// Verifica se na despesa existe uma natureza
	If Empty(DT7->DT7_YNATUR)
		cNatuDeb := Padr(SuperGetMV("MV_NATDEB",.f.,""), Len( SE2->E2_NATUREZ ) )
	Else
		cNatuDeb := Padr(DT7->DT7_YNATUR,Len( SE2->E2_NATUREZ ) )
	EndIf

	PRIVATE lMsErroAuto := .F.

	BeginSql Alias cAliasSE2

		SELECT MAX(E2_PARCELA) AS E2_PARCELA FROM %Table:SE2% SE2
		WHERE D_E_L_E_T_ ='' 
		AND SE2.E2_FILIAL = %Exp:SE2->E2_FILIAL%
		AND SE2.E2_PREFIXO =%Exp:SE2->E2_PREFIXO%
		AND SE2.E2_NUM =%Exp:SE2->E2_NUM%
		AND SE2.E2_TIPO ='NDF'
		AND SE2.E2_FORNECE =%Exp:SE2->E2_FORNECE%
		AND SE2.E2_LOJA  =%Exp:SE2->E2_LOJA%

	EndSql

	cParcela := SOMA1((cAliasSE2)->E2_PARCELA)

	(cAliasSE2)->(DbCloseArea())

	cParcela := PADL(cParcela,Len( SE2->E2_PARCELA ), "0")

	// Gerando NDF para o contrato
	aArray := { { "E2_PREFIXO"  , SE2->E2_PREFIXO   , NIL },;
		{ "E2_NUM"      , SE2->E2_NUM       , NIL },;
		{ "E2_PARCELA"  , cParcela   		, NIL },;
		{ "E2_TIPO"     , "NDF"             , NIL },;
		{ "E2_NATUREZ"  , cNatuDeb          , NIL },;
		{ "E2_FORNECE"  , SE2->E2_FORNECE   , NIL },;
		{ "E2_LOJA"  	, SE2->E2_LOJA   	, NIL },;
		{ "E2_EMISSAO"  , SE2->E2_EMISSAO	, NIL },;
		{ "E2_VENCTO"   , SE2->E2_VENCTO	, NIL },;
		{ "E2_VENCREA"  , SE2->E2_VENCREA	, NIL },;
		{ "E2_MDCONTR"	, SE2->E2_MDCONTR   , NIL },;
		{ "E2_MDREVIS"	, SE2->E2_MDREVIS	, NIL },;
		{ "E2_MEDNUME"	, SE2->E2_MEDNUME	, NIL },;
		{ "E2_MDPLANI"	, SE2->E2_MDPLANI	, NIL },;
		{ "E2_ORIGEM"   , SE2->E2_ORIGEM	, NIL },;
		{ "E2_MDCRON"	, SE2->E2_MDCRON	, NIL },;
		{ "E2_MDPARCE"	, SE2->E2_MDPARCE	, NIL },;
		{ "E2_HIST"   	, SUBSTR(oModelSZ1:GetValue("Z1_DESPESA"),1,LEN(SE2->E2_HIST)), NIL },;
		{ "E2_YTABORI"  ,"SZ2"				, NIL },;
		{ "E2_YIDORIG"  ,cIdBaixa			, NIL },;
		{ "E2_YCODDES"  ,oModelSZ1:GetValue("Z1_CODDESP"), NIL },;
		{ "E2_VALOR"    , nValor     		, NIL } }

	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)

	If lMsErroAuto
		cMsg := memoread(NomeAutoLog())
		FErase(NomeAutoLog())
		cSolu := ""
		oModel:SetErrorMessage("",,oModel:GetId(),"","GeraNDF",cMsg)
		Return {.f.,0}
	End If

	nRecno := SE2->(RECNO())

	RestArea(aAreaSE2)
Return {lRet,nRecno}

/*/{Protheus.doc} ValidSaldo
Validacao do saldo do CMV
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ValidSaldo()

	Local oModel 	:= FwModelActive()
	Local oModelSZ1 := oModel:GetModel("SZ1DETAIL")
	Local cCodigo	:= oModelSZ1:GetValue("Z1_NUM")
	Local cFilial	:= oModelSZ1:GetValue("Z1_FILIAL")
	Local cParcela	:= oModelSZ1:GetValue("Z1_PARCELA")
	Local cFornece 	:= oModelSZ1:GetValue("Z1_FORNECE")
	Local cLoja		:= oModelSZ1:GetValue("Z1_LOJA")
	Local nSaldo 	:= oModelSZ1:GetValue("Z1_SALDO")
	Local cMsg		:= ""
	Local cSolu		:= ""
	Local lRet		:= .t.

	SZ1->(DbSetOrder(1))

	If SZ1->(DbSeek(cFilial + cFornece + cLoja + cCodigo + cParcela))

		If nSaldo > SZ1->Z1_SALDO

			cMsg  := "O valor não pode ser maior do que o saldo desta despesa - Saldo Atual (R$ " + cvaltochar(SZ1->Z1_SALDO ) + ")"
			cSolu := "Favor informar o saldo igual ou menor do que o saldo atual."
			Help(NIL, NIL, "SERGCT02 - ValidSaldo", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.

		End if

	End If

Return lRet

Static Function GetLiq()

	Local oModel	:= FwModelActive()
	Local oModelCALC:= oModel:GetModel("CALC_CMV")
	Local oModelTOT := oModel:GetModel("CALC_ITEM")
	Local nLiq		:= 0
	Local nTotitem	:= 0
	Local nTotSel	:= 0

	If oModelTOT:IsActive() .and. oModelCALC:IsActive()
		nTotitem	:= oModelTOT:GetValue("CNE_VLTOT_T")
		nTotSel	:= oModelCALC:GetValue("Z1_SALDO_S")
		nLiq := nTotitem - nTotSel
	End If

Return nLiq



/*/{Protheus.doc} GetErroModel
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function GetErroModel(oModel)

	Local aErro := oModel:GetErrorMessage()
	Local cMessage := ""

	cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
	cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
	cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
	cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
	cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
	cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
	cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
	cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
	cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'

	// Informa que o modelo foi alterado para que o sistema realize o committ novamente.
	oModel:lModify := .t.

Return  cMessage

/*/{Protheus.doc} GetErroModel
//Marca todos os itens da Despesa
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function MarkAll()

	Local aSaveLines 	:= FWSaveRows()
	Local oModel 		:= FwModelActive()
	Local oModelSZ1 	:= oModel:GetModel("SZ1DETAIL")
	Local nTotReg		:= oModelSZ1:Length()
	Local oView  		:= FwViewActive()
	Local i				:= 0

	For i := 1 to nTotReg

		oModelSZ1:Goline(i)

		IIf(oModelSZ1:GetValue("Z1_MARK"), oModelSZ1:SetValue("Z1_MARK", .F.), oModelSZ1:SetValue("Z1_MARK", .T.))
		oModelSZ1:GoLine(1)

	Next i

	FWRestRows( aSaveLines )
	oView:Refresh("SZ1DETAIL")

Return


//===================================================
//Validação da Medição								=
//Bloqueio de seleção de saldo zerado ou negativo	=
//===================================================
Static Function ValFinEncer(oModel,cTextMsg)

	Local aVerbas	:= {}

	Local cVerb0218  := POSICIONE("SRV",2,xFilial('SRV') + "0218","RV_COD") //Autonomo
	Local cVerb1565  := POSICIONE("SRV",2,xFilial('SRV') + "1565","RV_COD") //Frete - Sem Incidência
	Local cVerb1564  := POSICIONE("SRV",2,xFilial('SRV') + "1564","RV_COD") //Frete - Incidência IRRF
	Local cVerb1563  := POSICIONE("SRV",2,xFilial('SRV') + "1563","RV_COD") //Frete - Incidência INSS
	Local cVerb0064	 := POSICIONE("SRV",2,xFilial('SRV') + "0064","RV_COD") //Desconto INSS
	Local cVerb0066	 := POSICIONE("SRV",2,xFilial('SRV') + "0066","RV_COD") //Desconto IRRF
	Local cVerb0437	 := POSICIONE("SRV",2,xFilial('SRV') + "0437","RV_COD") //Desconto SEST
	Local cVerb1456	 := POSICIONE("SRV",2,xFilial('SRV') + "1456","RV_COD") //Desconto SENAT
	Local cNatCTCTMS := SuperGetMV("MV_NATCTC",.f.,"")
	Local cNatureza	 := SuperGetMV("MV_YNATFRT",.f.,cNatCTCTMS)
	Local lRndSest   := SuperGetMv("MV_RNDSEST",.F.,.F.)
	Local lDedINS 	 := SuperGetMv("MV_INSIRF",.F.,"2") == "1"
	Local nVlrVenc	 := 0
	Local nVlrDesc	 := 0
	Local nVlrBIRRF	 := 0
	Local nVlrBINSS	 := 0
	Local cDescVerba := ""
	Local nPBASEIRRF := 0
	Local nPIRRF	 := 0

	Local nPos		 := 0
	Local nSemIndi	 := 0
	Local i			 := 0
	Local cFornece 	 := SE2->E2_FORNECE
	Local cLoja 	 := SE2->E2_LOJA
	Local cPrefixo 	 := SE2->E2_PREFIXO
	Local cNumero  	 := SE2->E2_NUM

	Local lRet		 := .T.

	Local cSepAba    := If("|"$MVABATIM,"|",",")
	Local cSepAnt    := If("|"$MVPAGANT,"|",",")
	Local cSepNeg    := If("|"$MV_CRNEG,"|",",")
	Local cSepProv   := If("|"$MVPROVIS,"|",",")
	Local cSepRec    := If("|"$MVRECANT,"|",",")

	Local cFiltAba	 := "%" + FormatIn(MVABATIM,cSepAba) + "%"
	Local cFiltAnt	 := "%" + FormatIn(MVPAGANT,cSepAnt) + "%"
	Local cFiltNeg	 := "%" + FormatIn(MV_CRNEG,cSepNeg) + "%"
	Local cFiltProv  := "%" + FormatIn(MVPROVIS,cSepProv ) + "%"
	Local cFiltRec 	 := "%" + FormatIn(MVRECANT,cSepRec ) + "%"

	Local cAliasSE2  := GetNextAlias()
	Local cMsg
	Local cSolu

	SRV->(DbSetOrder(1))
	SED->(DbSetOrder(1))

	//StaticCall(SERR0002,TrabSE2,cFornece,cLoja,cPrefixo,cNumero)
	BeginSql Alias cAliasSE2

		SELECT SE2.E2_FILIAL 
		,SE2.E2_FORNECE 
		,SE2.E2_LOJA 
		,SA2.A2_NOME
		,SA2.A2_CGC
		,SA2.A2_TIPO
		,SA2.A2_IRPROG
		,SRA.RA_MAT
		,SRA.RA_FICHA
		,SRA.RA_ADMISSA
		,SRA.RA_YPAMCAR
		,SE2.E2_NATUREZ 
		,SED.ED_DESCRIC
		,SE2.E2_PREFIXO 
		,SE2.E2_NUM 
		,SE2.E2_EMISSAO 
		,SE2.E2_PARCELA 
		,SE2.E2_TIPO 
		,SE2.E2_VALOR  + SE2.E2_INSS + SE2.E2_IRRF + SE2.E2_PIS + SE2.E2_COFINS + SE2.E2_CSLL + SE2.E2_SEST AS E2_VALOR
		,SE2.E2_BASEIRF 
		,SE2.E2_IRRF 
		,SE2.E2_BASEINS 
		,SE2.E2_INSS 
		,SE2.E2_SEST 
		,SE2.E2_YPSEST
		,SE2.E2_YPSENAT
		,SE2.E2_MDCONTR
		,SE2.E2_MEDNUME
		,SE2.E2_MDPLANI
		,SE2.E2_MDREVIS
		,DT7.DT7_CODDES 
		,DT7.DT7_DESCRI 
		,SRV.RV_COD 
		,SRV.RV_DESC 

		FROM  %Table:SE2% SE2 

		JOIN  %Table:SA2% SA2 ON SA2.A2_FILIAL =  %Exp:xFilial('SA2')%
		AND SA2.A2_COD = SE2.E2_FORNECE 
		AND SA2.A2_LOJA = SE2.E2_LOJA 
		AND SA2.D_E_L_E_T_ ='' 

		JOIN  %Table:SED% SED ON SED.ED_FILIAL =  %Exp:xFilial('SED')%
		AND SED.ED_CODIGO = SE2.E2_NATUREZ 
		AND SED.D_E_L_E_T_ ='' 

		// A Serrana atualmente cadastra todos seus funcionarios na empresa 01.
		JOIN SRA010 SRA ON SRA.RA_FILIAL =  '1001' //%Exp:xFilial('SRA')%
		AND SRA.RA_YFORN = SE2.E2_FORNECE 
		AND SRA.RA_CATFUNC = 'A' 
		AND SRA.RA_SITFOLH <> 'D'
		AND SRA.D_E_L_E_T_ ='' 

		LEFT JOIN  %Table:DT7% DT7 ON DT7.DT7_FILIAL =  %Exp:xFilial('DT7')%
		AND DT7.DT7_CODDES = SE2.E2_YCODDES 
		AND DT7.D_E_L_E_T_ ='' 

		LEFT JOIN  %Table:SRV% SRV ON SRV.RV_FILIAL =  %Exp:xFilial('SRV')%
		AND SRV.RV_COD = DT7.DT7_YVERBA 
		AND SRV.D_E_L_E_T_ ='' 

		WHERE SE2.D_E_L_E_T_ ='' 
		AND SE2.E2_NUMLIQ = ''
		AND SE2.E2_FATURA <> 'NOTFAT' 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltAba% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltAnt% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltNeg% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltProv% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltRec% 
		AND SE2.E2_FILORIG 	=  %Exp:cFilAnt%
		AND SE2.E2_FORNECE  =  %Exp:cFornece%
		AND SE2.E2_LOJA     =  %Exp:cLoja%
		AND SE2.E2_NUM      =  %Exp:cNumero%
		AND SE2.E2_PREFIXO  =  %Exp:cPrefixo%
		
		ORDER BY SE2.R_E_C_N_O_

	EndSql

	TcSetField(cAliasSE2,'E2_EMISSAO','D')
	TcSetField(cAliasSE2,'RA_ADMISSA','D')

	// Realiza o aglutinado das verbas
	While (cAliasSE2)->(!Eof())

		SED->(DbSeek(xFilial("SED") + (cAliasSE2)->E2_NATUREZ))

		cDescVerba := ""

		If Alltrim((cAliasSE2)->E2_TIPO) $ "NDF"

			SRV->(DbSeek(xFilial("SRV") + (cAliasSE2)->RV_COD))

			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Nota Debito a Fornecedor com as despesas do CMV
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim((cAliasSE2)->RV_COD)})
			If nPos == 0
				AADD(aVerbas, {(cAliasSE2)->RV_COD,(cAliasSE2)->E2_VALOR,cDescVerba,"D",Ctod("//"),0})
			Else
				aVerbas[nPos][2] += (cAliasSE2)->E2_VALOR
			End if


			// Foi solicitado pela Serrana nao desmembrar no recibo, desta forma, coloco como falso este trecho.
			// Verifica se esta natureza ela desmembra em varias verbas
		ElseIf Alltrim((cAliasSE2)->E2_NATUREZ) $ Alltrim(cNatureza) .and. .f.

			SRV->(DbSeek(xFilial("SRV") + cVerb1564))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Frete com indicencia de IRRF - ID 1564
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1564)})
			If nPos == 0
				AADD(aVerbas, {cVerb1564,(cAliasSE2)->E2_BASEIRF,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,0})
			Else
				aVerbas[nPos][2] += (cAliasSE2)->E2_BASEIRF
			End if

			SRV->(DbSeek(xFilial("SRV") + cVerb1563))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Frete com indicencia de INSS - ID 1563
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1563)})
			If nPos == 0
				AADD(aVerbas, {cVerb1563,(cAliasSE2)->E2_BASEINS,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,0})
			ELse
				aVerbas[nPos][2] += (cAliasSE2)->E2_BASEINS
			EndiF

			SRV->(DbSeek(xFilial("SRV") + cVerb1565))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Frete sem indicencia - ID 1565
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1565)})
			nSemIndi := (cAliasSE2)->E2_VALOR - (cAliasSE2)->E2_BASEIRF - (cAliasSE2)->E2_BASEINS
			If nPos == 0
				AADD(aVerbas, {cVerb1565,nSemIndi,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,0})
			Else
				aVerbas[nPos][2] += nSemIndi
			End iF

			// Totalizadores de Bases P/ PROVENTOS
			nVlrBIRRF += (cAliasSE2)->E2_BASEIRF
			nVlrBINSS += (cAliasSE2)->E2_BASEINS

		Else

			// Serrana solicitou que agora o valor da verba do provento seja pego
			// do cadastro da natureza, antes estava pegando tudo do Id de calculo
			// 0218.

			cVerb0218 := SED->ED_YVERBA

			SRV->(DbSeek(xFilial("SRV") + cVerb0218))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Pagamento Autonomo - ID 0218
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0218)})
			If nPos == 0

				// Recupera os numeros de dias trabalhados nos contratos.
				cDiasTrab := StaticCall(SERR0002,GetDiasTrb,(cAliasSE2)->E2_MDCONTR, (cAliasSE2)->E2_MEDNUME, (cAliasSE2)->E2_MDPLANI,(cAliasSE2)->E2_MDREVIS)
				//cDiasTrab := GetDiasTrb((cAliasSE2)->E2_MDCONTR, (cAliasSE2)->E2_MEDNUME, (cAliasSE2)->E2_MDPLANI,(cAliasSE2)->E2_MDREVIS)

				AADD(aVerbas, {cVerb0218,(cAliasSE2)->E2_VALOR,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,cDiasTrab})
			ELse
				aVerbas[nPos][2] += (cAliasSE2)->E2_VALOR
			EndiF

			// Totalizadores de Bases P/ PROVENTOS
			nVlrBIRRF += (cAliasSE2)->E2_BASEIRF
			nVlrBINSS += (cAliasSE2)->E2_BASEINS
		End if


		//============== IMPOSTOS RECOLHIDOS ============================//

		// INSS
		SRV->(DbSeek(xFilial("SRV") + cVerb0064))
		cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

		nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0064)})
		If nPos == 0
			AADD(aVerbas, {cVerb0064,(cAliasSE2)->E2_INSS,cDescVerba,"D",Ctod("//"),SED->ED_BASEINS})
		Else
			aVerbas[nPos][2] += (cAliasSE2)->E2_INSS
		End iF

		// IRRF
		SRV->(DbSeek(xFilial("SRV") + cVerb0066))
		cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

		// Recupera o percentual da faixa do IRRF
		//IRRF Progressivo para pessoas jurídicas, o cálculo deve ser executado igual ao cálculo de pessoa física
		If lDedINS .and. ( Alltrim( (cAliasSE2)->A2_TIPO ) == "F" .or. Alltrim( (cAliasSE2)->A2_IRPROG ) == "1")

			// Retira da base do IRRF o valor do INSS, pois o financeiro guarda essa informacao bruta, porem, existe
			// o parametro que deduz o INSS da base do IRRF.

			If nVlrBIRRF >= (cAliasSE2)->E2_INSS
				nVlrBIRRF -= (cAliasSE2)->E2_INSS
			End IF

			nPIRRF := StaticCall(SERR0002,Fa050TabIr,(cAliasSE2)->E2_BASEIRF - (cAliasSE2)->E2_INSS)
			//nPIRRF := Fa050TabIr( (cAliasSE2)->E2_BASEIRF - (cAliasSE2)->E2_INSS  )

		Else
			nPIRRF := StaticCall(SERR0002,Fa050TabIr,(cAliasSE2)->E2_BASEIRF)
			//nPIRRF := Fa050TabIr( (cAliasSE2)->E2_BASEIRF)
		End If


		// Verifica qual e a base do IR
		If Alltrim(SED->ED_IRRFCAR) == 'S'
			nPBASEIRRF := SED->ED_BASEIRC
		Else
			If SED->ED_BASEIRF == 0
				nPBASEIRRF := 100
			Else
				nPBASEIRRF := SED->ED_BASEIRF
			End iF
		End If

		nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0066)})
		If nPos == 0
			AADD(aVerbas, {cVerb0066,(cAliasSE2)->E2_IRRF,cDescVerba,"D",Ctod("//"),nPIRRF})
		Else
			aVerbas[nPos][2] += (cAliasSE2)->E2_IRRF
		EndIf

		// SEST/SENAT
		nValor 	   := (cAliasSE2)->E2_VALOR
		nPercSEST  := (cAliasSE2)->E2_YPSEST
		nPercSENAT := (cAliasSE2)->E2_YPSENAT

		// Verifica se este titulo calculou SEST/SENAT
		If (cAliasSE2)->E2_SEST > 0

			//SEST
			nBaseSEST := Iif(lRndSest,Round((nValor 	* (SED->ED_BASESES/100)),2),NoRound((nValor    * (SED->ED_BASESES/100)),2))
			nVlrSEST  := Iif(lRndSest,Round((nBaseSEST 	* (nPercSEST/100)),2)  	   ,NoRound((nBaseSEST * (nPercSEST/100)),2))

			// Verifica se ja existe a verba do SEST
			SRV->(DbSeek(xFilial("SRV") + cVerb0437))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0437)})
			If nPos == 0
				AADD(aVerbas, {cVerb0437,nVlrSEST ,cDescVerba,"D",Ctod("//"),nPercSEST})
			Else
				aVerbas[nPos][2] += nVlrSEST
			EndIf

			//SENAT
			SRV->(DbSeek(xFilial("SRV") + cVerb1456))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1456)})
			If nPos == 0
				AADD(aVerbas, {cVerb1456,(cAliasSE2)->E2_SEST - nVlrSEST ,cDescVerba,"D",Ctod("//"),nPercSENAT})
			Else
				// Pega o valor que o financeiro calculou e subtrai o valor do SENAT
				aVerbas[nPos][2] += (cAliasSE2)->E2_SEST - nVlrSEST
			EndIf
		End If

		(cAliasSE2)->(DbSkip())
	EndDo
	(cAliasSE2)->(DbCloseArea())

	// Imprime as verbas
	For i := 1 to Len(aVerbas)
		// Vencimentos
		If aVerbas[i][4] == "V"
			nVlrVenc += aVerbas[i][2]
		Else
			nVlrDesc += aVerbas[i][2]
		EndIf
	Next i

	If (nVlrVenc - nVlrDesc) <= 0
		cMsg := "O Valor dos Vencimentos não supre os valores dos Descontos." + CRLF + CRLF
		cMsg += "Cooperado: " + cTextMsg + CRLF
		cMsg += "Valor Vencimento: R$ " + cValToChar(nVlrVenc) + CRLF + CRLF
		cMsg += "Descontos Detalhados" + CRLF
		For i := 1 to Len(aVerbas)
			If aVerbas[i][4] == "D" .AND. aVerbas[i][2] > 0
				cMsg +=  AllTrim(aVerbas[i][3]) + ": R$ " + cValToChar(aVerbas[i][2]) + CRLF
			EndIf
		Next i
		cMsg +="Valor Total Descontos: R$ " + cValToChar(nVlrDesc) + CRLF + CRLF
		cMsg +=" ** TOTAL LIQUIDO ** R$ " + cValToChar(nVlrVenc - nVlrDesc)
		cSolu := "Vencimentos com Valores Negativados ou Zerados não serão Gerados."
		Help(NIL, NIL, "SERGCT02 - ValFinEncer", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		lRet := .F.
	EndIf

Return lRet


//===================================
//Atualiza do Grid das Despesas CMV	=
//===================================
Static Function AtuaCMV(oModel)

	Local oView 	:= FwViewActive()
	Local oModelSZ1 := oModel:GetModel("SZ1DETAIL")
	Local oModelCXN := oModel:GetModel("CXNDETAIL")
	Local cFornece  := oModelCXN:GetValue("CXN_FORNEC")
	Local cLoja	    := oModelCXN:GetValue("CXN_LJFORN")

	oModel:DeActivate()
	oModel:Activate()
	/*
	DbSelectArea("SZ1")
	SZ1->(DbSetOrder(1))//Z1_FILIAL+Z1_FORNECE+Z1_LOJA+Z1_NUM+Z1_PARCELA
	SZ1->(DbSeek(xFilial("SZ1")+cFornece+cLoja))

	While !SZ1->(Eof()) .AND. ;
			SZ1->Z1_FILIAL == xFilial("SZ1") .AND. ;
			SZ1->(Z1_FORNECE+Z1_LOJA) == (cFornece+cLoja) .AND. ;
			DtoS(SZ1->Z1_VENCTO) <= DtoS(DDATABASE) .AND. ;
			SZ1->Z1_SALDO > 0

		oModelSZ1:AddLine()

		oModelSZ1:SetValue("Z1_FILIAL"	, SZ1->Z1_FILIAL)
		oModelSZ1:SetValue("Z1_NUM"		, SZ1->Z1_NUM)
		oModelSZ1:SetValue("Z1_PARCELA"	, SZ1->Z1_PARCELA)
		oModelSZ1:SetValue("Z1_EMISSAO"	, SZ1->Z1_EMISSAO)
		oModelSZ1:SetValue("Z1_VENCTO"	, SZ1->Z1_VENCTO)
		oModelSZ1:SetValue("Z1_FORNECE"	, SZ1->Z1_FORNECE)
		oModelSZ1:SetValue("Z1_LOJA"	, SZ1->Z1_LOJA)
		oModelSZ1:SetValue("Z1_VALOR"	, SZ1->Z1_VALOR)
		oModelSZ1:SetValue("Z1_SALDO"	, SZ1->Z1_SALDO)
		oModelSZ1:SetValue("Z1_CODDESP"	, SZ1->Z1_CODDESP)
		oModelSZ1:SetValue("Z1_CODVEI"	, SZ1->Z1_CODVEI)
		oModelSZ1:SetValue("Z1_HISTORI"	, SZ1->Z1_HISTORI)
		oModelSZ1:SetValue("Z1_ODOMETR"	, SZ1->Z1_ODOMETR)
		oModelSZ1:SetValue("Z1_NABASTE"	, SZ1->Z1_NABASTE)
		oModelSZ1:SetValue("Z1_COND"	, SZ1->Z1_COND)

		SZ1->(DbSkip())
	EndDo
	*/
	oView:Refresh("SZ1DETAIL")

Return
