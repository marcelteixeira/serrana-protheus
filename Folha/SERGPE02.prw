#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*/{Protheus.doc} SERGPE02
Capital Social
@type  Function
@author Totvs Vitoria - Mauricio Silva
@since 16/09/2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/ 
User Function SERGPE02(cCodigo)

	Local aArea   := GetArea()
	Local oBrowse
	Local cRotina := Funname()
	Local oModel  := Nil
	Default cCodigo	:= SA2->A2_COD

	SA2->(DbSetOrder(1))
	If SA2->(DbSeek(xFilial("SA2") + cCodigo))

		oModel := FWLoadModel("SERGPE02")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		FWExecView("Capital Cooperado.",'SERGPE02', MODEL_OPERATION_UPDATE, , { || .T. } ,,,,,,,oModel)
	Else
		cMsg := "Não foi possivel localizar o fornecedor:" + cCodigo
		cSolu:= "Favor verificar o código no cadastro."
		Help(NIL, NIL, "SERGPE02", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End iF

Return

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel  := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStSA2     := FWFormStruct(1, "SA2",{ |x| ALLTRIM(x) $ "A2_COD,A2_LOJA,A2_NOME" } )
	Local oStSZ3     := FWFormStruct(1, "SZ3")
	Local oStSZ1     := FWFormStruct(1, "SZ1")
	Local oStCMV     := FWFormStruct(1, "SZ1")
	Local bVlSaldo   := {|| SaldoMov()}
	Local bPrelinSZ3 := {|oModel,nLinha,cAcao,cCampo| PreLinSZ3(oModel,nLinha,cAcao,cCampo)}
	Local cCodIntegra := SuperGetMV("MV_YCODINT",.F.,"GPE0689") // Despesa de integralizacao

	// Apenas para visualização.
	oStSA2:SetProperty("*",MODEL_FIELD_VALID,{||.T.})
	oStSA2:SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
	oStSA2:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oStSZ3:AddField("" ,;															// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Z3_YLEGE",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	50,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD, "StaticCall(SERGPE02,Legenda)"),;	                        // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 						 									// [14] Virtual

	oStSZ1:AddField("" ,;															// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Z1_YLEGE",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	50,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(SZ1->Z1_SALDO == SZ1->Z1_VALOR, 'BR_VERDE','BR_AZUL')"),;	                        // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 						 									// [14] Virtual

	aAuxGat := FwStruTrigger("Z3_TIPMOV","Z3_TIPMOV","StaticCall(SERGPE02,TrocLeg)",.F.,Nil,Nil,Nil)
	oStSZ3:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	// Cria o modelo
	oModel := MPFormModel():New("MSERGPE02",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("SA2MASTER",/*cOwner*/, oStSA2)

	// Atribuindo Grid ao modelo
	oModel:AddGrid( "SZ3DETAIL", "SA2MASTER",oStSZ3, bPrelinSZ3/*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "SZ1DETAIL", "SA2MASTER",oStSZ1,/*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "CMVDETAIL", "SA2MASTER",oStCMV,/*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)

	// Criando Relacionamentos
	oModel:SetRelation("SZ3DETAIL", {{"Z3_FILIAL","FwXFilial('SZ3')"}, {"Z3_FORNECE","A2_COD"} , {"Z3_LOJA","A2_LOJA"} }, "R_E_C_N_O_" )
	oModel:SetRelation("SZ1DETAIL", {{"Z1_FILIAL","FwXFilial('SZ1')"}, {"Z1_FORNECE","A2_COD"} , {"Z1_LOJA","A2_LOJA"} }, SZ1->( IndexKey( 1 ) ) )
	oModel:SetRelation("CMVDETAIL", {{"Z1_FILIAL","FwXFilial('SZ1')"}, {"Z1_FORNECE","A2_COD"} , {"Z1_LOJA","A2_LOJA"} }, SZ1->( IndexKey( 1 ) ) )

	// Realiza o filtro da grid para aparecer somente a despesa de integralização de capital.
	oModel:GetModel( "SZ1DETAIL" ):SetLoadFilter( { { "Z1_CODDESP", "'" + cCodIntegra + "'", MVC_LOADFILTER_EQUAL } , { "Z1_SALDO", "'0'", MVC_LOADFILTER_GREATER } } )
	oModel:GetModel( "CMVDETAIL" ):SetLoadFilter( { { "Z1_SALDO", "'0'", MVC_LOADFILTER_GREATER } } )

	// Permite salvar o GRID sem dados.
	oModel:GetModel( "SZ3DETAIL" ):SetOptional( .T. )
	oModel:GetModel( "SZ1DETAIL" ):SetOptional( .T. )
	oModel:GetModel( "CMVDETAIL" ):SetOptional( .T. )

	// Totais
	oModel:AddCalc("CAPINTTOTAIS","SA2MASTER" ,"SZ3DETAIL","Z3_VALOR","Z3_VALOR_C","SUM" , {|| oModel:GetModel("SZ3DETAIL"):Getvalue("Z3_TIPMOV") == "C" } /*bCondition*/,  /*bInitValue*/,"R$ Entrada"   ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CAPINTTOTAIS","SA2MASTER" ,"SZ3DETAIL","Z3_VALOR","Z3_VALOR_D","SUM" , {|| oModel:GetModel("SZ3DETAIL"):Getvalue("Z3_TIPMOV") == "D" } /*bCondition*/,  /*bInitValue*/,"R$ Saida"    ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CAPINTTOTAIS","SA2MASTER" ,"SZ3DETAIL","Z3_VALOR","Z3_VALOR_S","FORMULA" , /*bCondition*/,  /*bInitValue*/,"R$ Saldo" ,bVlSaldo/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)

	oModel:AddCalc("CAPSUBTOTAIS","SA2MASTER" ,"SZ1DETAIL","Z1_NUM","Z1_NUM_T","COUNT" , /*bCondition*/,  /*bInitValue*/,"Qtd."    ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CAPSUBTOTAIS","SA2MASTER" ,"SZ1DETAIL","Z1_SALDO","Z1_SALDO_T","SUM" , /*bCondition*/,  /*bInitValue*/,"R$ Saldo"    ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)

	oModel:AddCalc("CMVTOTAIS"  ,"SA2MASTER" ,"CMVDETAIL","Z1_SALDO","Z1_SALDO_T","SUM" , /*bCondition*/,  /*bInitValue*/,"R$ Total Saldo"    ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({})

	// ********* ATENÇÃO ***********
	// É de extrema importancia marcar o SetOnlyQuery para a tabela SA2.
	// Uma vez que a mesma NÃO PODE receber manutenção pois este modelo não possui a regra
	// de negocio que a rotina principal.
	oModel:GetModel("SA2MASTER"):SetOnlyQuery(.T.)
	oModel:GetModel("SZ1DETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("CMVDETAIL"):SetOnlyQuery(.T.)

	//Adicionando descrição ao modelo
	oModel:SetDescription("Conta Capital")

	//Descricoes dos modelos de dados
	oModel:GetModel("SA2MASTER"):SetDescription("Dados do Cooperado")
	oModel:GetModel("SZ3DETAIL"):SetDescription("Capital Integralizado")
	oModel:GetModel("SZ1DETAIL"):SetDescription("Capital Subscrito")
	oModel:GetModel("CMVDETAIL"):SetDescription("CMV Cooperado")

	// Muda a estrutura para Inserção/Alteração ou Deletação
	oModel:GetModel("SZ1DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SZ1DETAIL"):SetNoInsertLine(.T.); oModel:GetModel("SZ1DETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("CMVDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("CMVDETAIL"):SetNoInsertLine(.T.); oModel:GetModel("CMVDETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("SZ1DETAIL" ):SetMaxLine(999999999)
	oModel:GetModel("CMVDETAIL" ):SetMaxLine(999999999)
	oModel:GetModel("SZ3DETAIL" ):SetMaxLine(999999999)

	//Verifica se realiza ativição do Modelo
	oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )

Return oModel


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	// Recupera o modelo de dados
	Local oModel := FWLoadModel("SERGPE02")

	//Criação da estrutura de dados da View
	Local oStSA2   := FWFormStruct(2, "SA2",{ |x| ALLTRIM(x) $ "A2_COD,A2_NOME" } )
	Local oStSZ3   := FWFormStruct(2, "SZ3")
	Local oStSZ1   := FWFormStruct(2, "SZ1",{ |x| ALLTRIM(x) $ "Z1_NUM/Z1_PARCELA/Z1_EMISSAO/Z1_VENCTO/Z1_VALOR/Z1_SALDO/Z1_HISTORI" } )
	Local oStCMV   := FWFormStruct(2, "SZ1", { |cCampo| GetStrSZ1(cCampo) }/*bAvalCampo*/,/*lViewUsado*/ )
	Local oCalculo := FWCalcStruct(oModel:GetModel("CAPINTTOTAIS"))
	Local oCalcCapSub := FWCalcStruct(oModel:GetModel("CAPSUBTOTAIS"))
	Local oCalcCMV := FWCalcStruct(oModel:GetModel("CMVTOTAIS"))

	oStSA2:SetNoFolder()

	// Remove os campos de ligação
	oStSZ3:RemoveField("Z3_FORNECE") ; oStSZ3:RemoveField("Z3_LOJA")
	//oStSZ1:RemoveField("Z3_NOME") ; oStSZ1:RemoveField("Z1_LOJA")

	oStSZ3:AddField("Z3_YLEGE",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStSZ1:AddField("Z1_YLEGE",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Atribuindo fomulários para interface
	oView:AddField("VIEW_SRA"     , oStSA2      , "SA2MASTER")
	oView:AddGrid( "VIEW_SZ3"     , oStSZ3	    , "SZ3DETAIL")
	oView:AddGrid( "VIEW_SZ1"     , oStSZ1	    , "SZ1DETAIL")
	oView:AddGrid( "VIEW_CMV"     , oStCMV	    , "CMVDETAIL")
	oView:AddField("VIEW_CLC_INT" , oCalculo    , "CAPINTTOTAIS")
	oView:AddField("VIEW_CLC_SUB" , oCalcCapSub , "CAPSUBTOTAIS")
	oView:AddField("VIEW_CLC_CMV" , oCalcCMV 	, "CMVTOTAIS")

	//Criando os paineis
	oView:CreateHorizontalBox("SUPERIOR",020)
	oView:CreateHorizontalBox("INFERIOR",080)

	// Pasta que conterá cada uma das guias
	oView:CreateFolder("FOLDER","INFERIOR")

	// Adiciona pastas
	oView:AddSheet("FOLDER", "ABA_CAPITAL_I" , "Capital Integralizado" )
	oView:AddSheet("FOLDER", "ABA_CAPITAL_S" , "Capital Subscrito" )
	oView:AddSheet("FOLDER", "ABA_CAPITAL_C" , "CMV Cooperado" )

	// Cria os paineis
	oView:CreateHorizontalBox("BOX1_CAPITAL_I" , 085 ,,, "FOLDER", 'ABA_CAPITAL_I')
	oView:CreateHorizontalBox("BOX2_CAPITAL_I" , 015 ,,, "FOLDER", 'ABA_CAPITAL_I')
	oView:CreateHorizontalBox("BOX1_CAPITAL_S" , 085 ,,, "FOLDER", 'ABA_CAPITAL_S')
	oView:CreateHorizontalBox("BOX2_CAPITAL_S" , 015 ,,, "FOLDER", 'ABA_CAPITAL_S')
	oView:CreateHorizontalBox("BOX1_CAPITAL_C" , 085 ,,, "FOLDER", 'ABA_CAPITAL_C')
	oView:CreateHorizontalBox("BOX2_CAPITAL_C" , 015 ,,, "FOLDER", 'ABA_CAPITAL_C')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SRA","SUPERIOR")
	oView:SetOwnerView("VIEW_SZ3","BOX1_CAPITAL_I")
	oView:SetOwnerView("VIEW_SZ1","BOX1_CAPITAL_S")
	oView:SetOwnerView("VIEW_CMV","BOX1_CAPITAL_C")

	oView:SetOwnerView("VIEW_CLC_SUB","BOX2_CAPITAL_S")
	oView:SetOwnerView("VIEW_CLC_INT","BOX2_CAPITAL_I")
	oView:SetOwnerView("VIEW_CLC_CMV","BOX2_CAPITAL_C")

	//Adicionado Descrições
	oView:EnableTitleView("VIEW_SRA", "Dados do Cooperado" )
	//oView:EnableTitleView("VIEW_SZ1", "Capital Subscrito" )
	//oView:EnableTitleView("VIEW_SZ3", "Capital Integralizado" )

	oView:SetViewProperty("*", "GRIDFILTER", {.T.})
	oView:SetViewProperty("*", "GRIDSEEK"  , {.T.})

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

Return oView

/*/{Protheus.doc} GetStrSZ1
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cCampo, characters, description
@type function
/*/
Static Function GetStrSZ1(cCampo)

	Local cStrCampos := SuperGetMv("MV_YSTRSZ1",.F.,"Z1_NUM/Z1_PARCELA/Z1_EMISSAO/Z1_VENCTO/Z1_VALOR/Z1_SALDO/Z1_CODDESP/Z1_DESPESA/Z1_HISTORI")
	Local lRet := .t.

	If Alltrim(cCampo) $ Alltrim(cStrCampos)
		lRet := .t.
	Else
		lRet := .F.
	End If

Return lRet


/*/{Protheus.doc} ValidActv
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function ValidActv(oModel)

	Local nOper  := oModel:GetOperation()
	Local lRet   := .t.
	Local cMsg   := ""
	Local cSolu  := ""

	// Verifica se a operação é de INCLUSÃO
	If  nOper == MODEL_OPERATION_INSERT

		lRet  := .F.
		cMsg  := "Operação INCLUSÃO não disponivel para este modelo de dados"
		cSolu := "Apenas operação de ALTERAÇÃO ou VISUALIZAÇÃO permitida"
		Help(NIL, NIL, "SERGEPE20 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})

		// Verifica se a operação é de ALTERAÇÃO
	ElseIf nOper == MODEL_OPERATION_UPDATE

		lRet  := .T.

		// Verifica se a operação é de VISUALIZACAO
	ElseIf nOper == MODEL_OPERATION_VIEW

		lRet  := .T.

		// Verifica se a operação é de EXCLUSÃO
	ElseIf nOper == MODEL_OPERATION_DELETE

		lRet  := .F.
		cMsg  := "Operação INCLUSÃO não disponivel para este modelo de dados"
		cSolu := "Apenas operação de ALTERAÇÃO ou VISUALIZAÇÃO permitida"
		Help(NIL, NIL, "SERGEPE20 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})

	End If


Return lRet


/*/{Protheus.doc} GeraCapSub
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GeraCapSub(cCodForn)

	Local aPergs    := {}
	Local nValor	:= Space(TAMSX3("Z1_VALOR")[1])
	Local cCondPag	:= Space(TAMSX3("E4_CODIGO")[1])
	Local aRet      := {}
	Local lRet      := .t.
	Local cMsg		:= ""
	Local cSolu		:= ""

	Default cCodForn := ""

	If Empty(cCodForn)
		cMsg  := "Código do fornecedor não foi informado."
		cSolu := "Favor informar o código do fornecedor para geração do capital subscrito."
		Help(NIL, NIL, "GeraCapSub", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return
	Else
		SA2->(DbSetOrder(1))
		If !SA2->(DbSeek(xFilial("SA2") + cCodForn))
			cMsg  := "Não foi possível localizar o fornecedor para este código:"
			cSolu := "Favor verificar o cadastro do fornecedor"
			Help(NIL, NIL, "GeraCapSub", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return
		End If
	End if

	aAdd( aPergs ,{1,"Vlr. Subscrito",nValor  ,'','.T.','','.T.',TAMSX3("Z1_VALOR")[1] * 5,.t.})
	aAdd( aPergs ,{1,"Cond. Pag."    ,cCondPag,'','.T.','SE4','.T.',TAMSX3("E4_CODIGO")[1]* 5,.t.})


	lRet := ParamBox(aPergs ,"Gerar Capital Subscrito",aRet)

	If lRet

		FWMsgRun(, {|| ProcCapSub(aRet) }, "Processando", "Processando a atualização...")

	End If

Return


/*/{Protheus.doc} Desfiliar
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function Desfiliar(cCodForn)

	Local cMsg  		:= ""
	Local cSolu 		:= ""
	Local lRet			:= .T.
	Local aRecNDF		:= {}
	Local aRecSE2		:= {}
	Local aRecSZ1		:= {}
	Local aRecSZ2		:= {}
	Local aRecSZ3		:= {}

	Private lMsErroAuto	:= .f.

	Default cCodForn := ""

	If Empty(cCodForn)
		cMsg  := "Código do fornecedor não foi informado."
		cSolu := "Favor informar o código do fornecedor para geração do capital subscrito."
		Help(NIL, NIL, "GeraCapSub", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return
	Else
		SA2->(DbSetOrder(1))
		If !SA2->(DbSeek(xFilial("SA2") + cCodForn))
			cMsg  := "Não foi possível localizar o fornecedor para este código:"
			cSolu := "Favor verificar o cadastro do fornecedor"
			Help(NIL, NIL, "GeraCapSub", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return
		End If
	End if

	IF !MSGYESNO( "Deseja realizar a desfiliação deste cooperado?", "Desfiliar" )
		Return .f.
	End If

	SZ1->(DbSetOrder(1))

	// Realiza a criacao das NDF dos CMV em aberto
	// Cria um titulo a pagar do saldo do capital
	// Realiza a compensao entre os valores se possuirem

	BEGIN TRANSACTION

		// Cria as NDF e recupera os RECNO para realizar a compensacao posteriomente
		Processa({|| lRet := CriaNDF(@aRecNDF,@aRecSZ1,@aRecSZ2)}, "Criando NDF dos saldos do CMV em aberto...")

		// Verifica se conseguiu crias as NDF
		If !lRet
			DisarmTransaction()
			Return .f.
		End IF

		Processa({|| lRet := SaqueCap(@aRecSE2,@aRecSZ3)}, "Criando contas a pagar do capital integralizado...")

		// Verifica se conseguiu crias as NDF
		If !lRet
			DisarmTransaction()
			Return .f.
		End IF

		// Verifica se o cooperado tem titulos para compensar
		if Len(aRecSE2) > 0 .and. len(aRecNDF) > 0

			MsgRun ("Compensando Títulos no Financeiro...",  "" , {|| lRet := MaIntBxCP(2,aRecSE2,,aRecNDF   ,,{.T.,.F.,.F.,.F.,.F.,.F.},/*{||}*/ ) } )

			If !lRet
				cMsg  := "Não foi possível compensar o titulo do capital social com as NDF criadas."
				cSolu := ""
				Help(NIL, NIL, "SERGPE02 - MaIntBxCP", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				DisarmTransaction()
				Return .f.
			End If

		End If

		//If lRet
		//	AVISO( "Desfiliação", "Concluida com sucesso!! Favor verificar os titulos no financeiro",, 2)
		//Endif

	END TRANSACTION

	If lRet

		//Grava na Tabela de Controle de Estorno de Desfiliação - SZ9
		GravaSZ9(aRecSE2,aRecNDF,aRecSZ1,aRecSZ2,aRecSZ3)

		Aviso("Desfiliação", "Concluida com sucesso!! Favor verificar os titulos no financeiro",,2)

	EndIf

Return lRet

Static Function SaqueCap(aRecSE2,aRecSZ3)

	Local oModelScl	:= Nil
	Local oModelCal := Nil
	Local oModelSA2	:= Nil
	Local oModelSZ3	:= Nil
	Local cErro	    := ""
	Local cMsg		:= ""
	Local cSolu		:= ""
	Local nSaldo	:= 0
	Local lValid	:= .T.
	Local aArray	:= {}
	Local cPrefixo	:= SuperGetMV("MV_YDPRF" ,.F.,"BOL")
	local cTipo		:= SuperGetMV("MV_YDTIPO",.F.,"RC")
	Local cNatureza	:= SuperGetMV("MV_YDNATU",.F.,"201036")
	Local cNumero	:= DTOS(DDATABASE)
	Local lRet		:= .t.
	Local cIdMov	:= ""

	Default aRecSE2 := {}
	Default aRecSZ3 := {}

	Private lMsErroAuto	:= .f.

	ProcRegua(1)

	// Instancia o modelo do capital social
	oModelScl:= FwLoadModel("SERGPE02")
	oModelScl:SetOperation(MODEL_OPERATION_UPDATE)
	oModelScl:Activate()

	// Verifica se conseguiu ativar o modelo
	if !oModelScl:Activate()

		// Verifica o motivo de não ativação do modelo
		If oModelScl:HasErrorMessage()
			// Recupera o erro
			cErro := GetErroModel(oModelScl)
			cMsg  := cErro
			cSolu := ""
			Help(NIL, NIL, "SERGPE02 - SaqueCap/Activate", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End If
	End if

	// Recupera os modelos do Capital Social
	oModelCal 	:= oModelScl:GetModel("CAPINTTOTAIS")
	oModelSA2	:= oModelScl:GetModel("SA2MASTER")
	oModelSZ3	:= oModelScl:GetModel("SZ3DETAIL")

	// Recupera o saldo do Capital
	nSaldo	 := oModelCal:GetValue("Z3_VALOR_S")

	If nSaldo > 0

		If !oModelSZ3:IsEmpty()
			// Adiciona uma linha no modelo.
			oModelSZ3:AddLine()
		End If

		If lValid
			lValid := oModelSZ3:SetValue( "Z3_FORNECE" , oModelSA2:GetValue("A2_COD") )
		End If

		If lValid
			lValid := oModelSZ3:SetValue( "Z3_LOJA"  ,  "01")
		End if

		If lValid
			lValid := oModelSZ3:SetValue( "Z3_TIPOLAN" , "A" )
		End if

		If lValid
			lValid := oModelSZ3:SetValue( "Z3_TIPMOV"  ,"D" )
		End if

		If lValid
			lValid := oModelSZ3:SetValue( "Z3_VALOR" , oModelCal:GetValue("Z3_VALOR_S"))
		End if

		If lValid
			lValid := oModelSZ3:SetValue( "Z3_HISTOR" , "Desfiliação do Cooperado" )
		End if

		If lValid
			// Informa que foi integrado no Financeiro CP, sendo assim, somente
			// o financeiro pode excluir tal baixa. Ponto de Entrada FA050DEL
			lValid := oModelSZ3:SetValue( "Z3_ROTINA" , "FINA050" )
		End if

		If oModelScl:HasErrorMessage()
			cErro := GetErroModel(oModelScl)
			cMsg  := cErro
			cSolu := ""
			Help(NIL, NIL, "SERGPE02 - SaqueCap/ActivateCampos", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End If

		// Recupera o ID de movimento
		cIdMov := oModelSZ3:GetValue("Z3_IDMOV")

		//Validação e Gravação do Modelo
		If oModelScl:VldData()
			// Verifica o Commit
			If !oModelScl:CommitData()
				cErro := GetErroModel(oModelScl)
				Help(NIL, NIL, "SERGPE02 - SaqueCap/CommitData", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End if
		Else
			cErro := GetErroModel(oModelScl)
			Help(NIL, NIL, "SERGPE02 - SaqueCap/VldData", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		EndIf

		// Cria um contas a pagar para o cooperado do saldo do capital
		aArray := { { "E2_PREFIXO"  , cPrefixo   		, NIL },;
			{ "E2_NUM"      , cNumero       	, NIL },;
			{ "E2_PARCELA"  , "01" 		  		, NIL },;
			{ "E2_TIPO"     , cTipo             , NIL },;
			{ "E2_NATUREZ"  , cNatureza         , NIL },;
			{ "E2_FORNECE"  , SA2->A2_COD    	, NIL },;
			{ "E2_LOJA"  	, SA2->A2_LOJA 	  	, NIL },;
			{ "E2_EMISSAO"  , DDATABASE			, NIL },;
			{ "E2_VENCTO"   , DDATABASE			, NIL },;
			{ "E2_VENCREA"  , DDATABASE			, NIL },;
			{ "E2_HIST"   	, "SALDO DO CAPITAL INTEGRALIZADO", NIL },;
			{ "E2_YTABORI"  , "SZ3"				, NIL },;
			{ "E2_YIDORIG"  , cIdMov			, NIL },;
			{ "E2_VALOR"    , nSaldo     		, NIL } }

		lMsErroAuto := .f.

		// Alimenta a regua de progresso
		IncProc("SALDO DO CAPITAL INTEGRALIZADO: R$ " + cvaltochar(nSaldo))

		// Chama o exeauto
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)

		// Verifica a criacao do contas a pagar
		If lMsErroAuto
			MostraErro()
			Return .f.
		End If

		// Recupera o RECNO do titulo do capital integralizado
		AADD(aRecSE2,SE2->(RECNO()))

		// Guarda os Recno da SZ1 para controle de estorno da desfiliação
		AADD(aRecSZ3,SZ3->(Recno()))

	EndIf

Return lRet


Static Function CriaNDF(aRecNDF,aRecSZ1,aRecSZ2)

	Local cAliasCMV := GetNextAlias()
	Local nTotSZ1	:= 0
	Local lRet		:= .t.
	Local cParcela	:= PADL("00",Len( SE2->E2_PARCELA ), "0")
	Local cNumero	:= DTOS(DDATABASE)
	Local cPrefixo	:= SuperGetMV("MV_YPRFCMV",.f.,"DEB")
	Local cHist		:= "DESFILIAÇÃO DO COOPERADO"

	Default aRecNDF	:= {}
	Default aRecSZ1 := {}
	Default aRecSZ2 := {}

	SZ1->(DbSetOrder(1))
	DT7->(DbSetOrder(1))

	// Recupera os CMV em aberto
	BeginSql Alias cAliasCMV

		SELECT SZ1.R_E_C_N_O_ AS SZ1REC, SZ1.Z1_SALDO FROM %Table:SZ1% SZ1
		WHERE SZ1.D_E_L_E_T_ =''
		AND SZ1.Z1_SALDO > 0 
		AND SZ1.Z1_FORNECE = %Exp:SA2->A2_COD%
		AND SZ1.Z1_LOJA ='01'
		AND SZ1.Z1_FILIAL =%Exp:xFilial("SZ1")%

	EndSQL

	Count To nTotSZ1

	ProcRegua(nTotSZ1)

	(cAliasCMV)->(DbGotop())

	While(cAliasCMV)->(!EOF())

		// Posiciona no CMV
		SZ1->(DbGoto((cAliasCMV)->SZ1REC))

		// Posicione no cadastro da despesa
		DT7->(DbSeek(xFilial("DT7") + SZ1->Z1_CODDESP))

		// Alimenta a regua de progresso
		IncProc("Despesa: " + DT7->DT7_DESCRI)

		// soma parcela
		cParcela := soma1(cParcela)

		// Cria a NDF
		lRet := U_BaixaCMV((cAliasCMV)->SZ1REC,cNumero,cPrefixo,cParcela,cHist)

		// Verifica se deu tudo ok
		If !lRet
			Return .f.
		End If

		// Guarda os Recno para compensacao com SE2 posicionado.
		AADD(aRecNDF,SE2->(RECNO()))

		// Guarda os Recno da SZ1 para controle de estorno da desfiliação
		AADD(aRecSZ1, {(cAliasCMV)->SZ1REC,(cAliasCMV)->Z1_SALDO})

		// Guarda os Recno da SZ2 para controle de estorno da desfiliação
		AADD(aRecSZ2, SZ2->(Recno()))

		(cAliasCMV)->(DbSkip())
	EndDo

Return lRet


/*/{Protheus.doc} ProcCapSub
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param aRet, array, description
@type function
/*/
Static Function ProcCapSub(aRet)

	Local oModel      := Nil
	Local nValor      := val(aRet[1])
	Local cCondPag    := aRet[2]
	Local lValid      := .t.
	Local cErro       := ""
	Local cCodIntegra := SuperGetMV("MV_YCODINT",.F.,"") // Despesa de integralizacao
	Local i           := 0
	Local cCodigo     := ""
	Local cCodForn	  := SA2->A2_COD
	Local cLojForn	  := SA2->A2_LOJA


	If Empty(cCodIntegra)
		Help(NIL, NIL, "SERGPE02 - ProcCapSub", NIL, "MV_YCODINT se encontra vazio." ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
		Return .f.
	End If

	SZ1->(DbSetOrder(1))

	aVenc := Condicao(nValor,cCondPag,,DDATABASE)

	BEGIN TRANSACTION

		For i:=1 to Len(aVenc)

			//Carrega o modelo
			oModel := FWLoadModel("SERGPE01")

			// Realiza alteração do movimento.
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()

			// Pega o código do primeiro movimento para levar para as demais parcelas.
			If Empty(cCodigo)
				cCodigo := oModel:GetModel("SZ1MASTER"):GetValue("Z1_NUM")
			End iF

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_NUM"  , cCodigo )
			End If

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_PARCELA"  , PadL(i,TAMSX3("Z1_PARCELA")[1],"0") )
			End If

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_EMISSAO" , DDATABASE )
			End If

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_VENCTO"  , aVenc[i][1])
			End if

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_FORNECE" , cCodForn )
			End if

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_LOJA"  , cLojForn  )
			End if

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_VALOR" , aVenc[i][2]  )
			End if

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_CODDESP" , cCodIntegra  )
			End if

			If lValid
				lValid := oModel:SetValue( "SZ1MASTER"    , "Z1_HISTORI" , "Gerado pela rotina (" + Funname()+ ") pelo usuario:" + cUserName )
			End if

			// Verifica se o modelo ficou com algum erro após atribuição dos valores
			If oModel:HasErrorMessage()
				cErro:= GetErroModel(oModel,"Erro na validação SetValue do modelo oModel")
				Help(NIL, NIL, "SERGPE02 - ProcCapSub", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
				DisarmTransaction()
				Return .f.
			End If

			//Validação e Gravação do Modelo
			If oModel:VldData()
				// Verifica o Commit
				If !oModel:CommitData()
					cErro:= GetErroModel(oModel,"Erro na validação CommitData do modelo oModel")
					Help(NIL, NIL, "SERGPE02 - ProcCapSub", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					DisarmTransaction()
					Return .f.
				End if
			Else
				cErro:= GetErroModel(oModel,"Erro na validação VldData oModel")
				Help(NIL, NIL, "SERGPE02 - ProcCapSub", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
				DisarmTransaction()
				Return .f.
			EndIf

			// Destroi o modelo, uma vez que está dentro de um loop
			oModel:Destroy()
		Next

	END TRANSACTION

Return


/*/{Protheus.doc} Legenda
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function Legenda()

	Local cTipoMov := ALLTRIM(SZ3->Z3_TIPMOV)
	Local cLegenda := "BR_VERDE"

	IF cTipoMov == "C"
		Return "BR_VERDE"
	ElseIf cTipoMov == "D"
		Return "BR_VERMELHO"
	End If

Return  cLegenda


/*/{Protheus.doc} PreLinSZ3
//TODO Descrição auto-gerada.
@author kenny.roger
@author Totvs Vitoria - Mauricio Silva
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param nLinha, numeric, description
@param cAcao, characters, description
@param cCampo, characters, description
@type function
/*/
Static Function PreLinSZ3(oModel,nLinha,cAcao,cCampo)

	Local lRet := .T.
	Local cRotina := ALLTRIM(oModel:GetValue("Z3_ROTINA"))
	Local cTipoLAN := ALLTRIM(oModel:GetValue("Z3_TIPOLAN"))
	Local cMsg	:= ""
	Local cSolu := ""

	// Verifica se é Alteração
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE

		// Manual pode realizar alteração
		If cTipoLAN == "M"
			Return .T.

			// Automatico, apenas a rotina geradora
		Else

			if Funname() != cRotina
				cMsg  := "Não é possivel realizar tal ação ("+ cAcao +") neste registro, uma vez que o mesmo foi integrado em outro Modulo/Rotina."
				cSolu := "Favor selecionar outro registro para prestar manutenção ou utilize a rotina geradora. (" + cRotina + ")"
				Help(NIL, NIL, "SERGPE02 - PreLinSZ3", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End If
		End If
	End If

Return lRet

/*/{Protheus.doc} TrocLeg
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TrocLeg()

	Local oModel  := FwModelActive()
	Local oModelSZ3 := oModel:GetModel("SZ3DETAIL")

	Local cTipoMov := oModelSZ3:Getvalue("Z3_TIPMOV")

	IF cTipoMov == "C"
		oModel:LoadValue( "SZ3DETAIL"    , "Z3_YLEGE"  , "BR_VERDE" )
	ElseIf cTipoMov == "D"
		oModel:LoadValue( "SZ3DETAIL"    , "Z3_YLEGE"  , "BR_VERMELHO" )
	End If

Return

/*/{Protheus.doc} SaldoMov
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SaldoMov()


	Local oModel := FwModelActive()
	Local oModelCALC := oModel:GetModel("CAPINTTOTAIS")
	Local nValorC := oModelCALC:Getvalue("Z3_VALOR_C")
	Local nValorD := oModelCALC:Getvalue("Z3_VALOR_D")
	Local nRet    := nValorC - nValorD

Return nRet


/*/{Protheus.doc} GetErroModel
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param cId, characters, description
@type function
/*/
Static Function GetErroModel(oModel,cId)

	Local aErro := oModel:GetErrorMessage()
	Local cMessage := ""
	Default cId := ""

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


//=======================================================
//Gravando SZ9 para controle de estorno do Desfiliado	=
//=======================================================
Static Function GravaSZ9(aRecSE2,aRecNDF,aRecSZ1,aRecSZ2,aRecSZ3)

	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSZ1 := SZ1->(GetArea())
	Local aAreaSZ3 := SZ3->(GetArea())
	Local cSqlSZ3
	Local cAliasSZ3
	Local i

	//grava os dados do titulo gerado
	For i := 1 To Len(aRecSE2)

		DbSelectArea("SE2")
		SE2->(DbGoTo(aRecSE2[i]))

		RecLock("SZ9", .T.)
		SZ9->Z9_FILIAL 	:= SRA->RA_FILIAL
		SZ9->Z9_MAT		:= SRA->RA_MAT
		SZ9->Z9_TABELA	:= "SE2"
		SZ9->Z9_CHAVE	:= SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		SZ9->Z9_SALDO	:= 0
		SZ9->(MsUnLock())

	Next i

	//grava os dados das NDF geradas
	For i := 1 To Len(aRecNDF)

		DbSelectArea("SE2")
		SE2->(DbGoTo(aRecNDF[i]))

		RecLock("SZ9", .T.)
		SZ9->Z9_FILIAL 	:= SRA->RA_FILIAL
		SZ9->Z9_MAT		:= SRA->RA_MAT
		SZ9->Z9_TABELA	:= "SE2"
		SZ9->Z9_CHAVE	:= SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		SZ9->Z9_SALDO	:= 0
		SZ9->(MsUnLock())

	Next i

	//grava os dados das SZ1 envolvida
	For i := 1 To Len(aRecSZ1)

		DbSelectArea("SZ1")
		SZ1->(DbGoTo(aRecSZ1[i,1]))

		RecLock("SZ9", .T.)
		SZ9->Z9_FILIAL 	:= SRA->RA_FILIAL
		SZ9->Z9_MAT		:= SRA->RA_MAT
		SZ9->Z9_TABELA	:= "SZ1"
		SZ9->Z9_CHAVE	:= SZ1->(Z1_FILIAL+Z1_FORNECE+Z1_LOJA+Z1_NUM+Z1_PARCELA)
		SZ9->Z9_SALDO	:= aRecSZ1[i,2]
		SZ9->(MsUnLock())

	Next i

	//grava os dados das SZ2 envolvida
	For i := 1 To Len(aRecSZ2)

		DbSelectArea("SZ2")
		SZ2->(DbGoTo(aRecSZ2[i]))

		RecLock("SZ9", .T.)
		SZ9->Z9_FILIAL 	:= SRA->RA_FILIAL
		SZ9->Z9_MAT		:= SRA->RA_MAT
		SZ9->Z9_TABELA	:= "SZ2"
		SZ9->Z9_CHAVE	:= SZ2->(Z2_FILIAL+Z2_IDMOV)
		SZ9->Z9_SALDO	:= 0
		SZ9->(MsUnLock())

	Next i

	//grava os dados das SZ3 envolvida
	For i := 1 To Len(aRecSZ3)

		DbSelectArea("SZ3")
		SZ3->(DbGoTo(aRecSZ3[i]))

		If Len(aRecSZ3) == 1

			cAliasSZ3 := GetNextAlias()
			cSqlSZ3 := "SELECT SZ3.Z3_IDMOV " + CRLF
			cSqlSZ3 += "FROM "+RetSqlName("SZ3")+" SZ3 " + CRLF
			cSqlSZ3 += "WHERE " + CRLF
			cSqlSZ3 += "	  SZ3.Z3_FORNECE = '"+SZ3->Z3_FORNECE+"' AND " + CRLF
			cSqlSZ3 += "	  SZ3.Z3_LOJA    = '"+SZ3->Z3_LOJA+"' AND " + CRLF
			cSqlSZ3 += "	  SZ3.Z3_TIPOLAN = 'A' AND " + CRLF
			cSqlSZ3 += "	  SZ3.Z3_DATA    = "+ValToSql(SZ3->Z3_DATA)+" AND " + CRLF
			cSqlSZ3 += "	  SZ3.Z3_HISTOR  = 'Integr. - DESFILIAÇÃO DO COOPERADO' AND " + CRLF
			cSqlSZ3 += "	  SZ3.Z3_TIPMOV  = 'C' AND " + CRLF
			cSqlSZ3 += "	  SZ3.D_E_L_E_T_ = ' ' " + CRLF
			cSqlSZ3 += "ORDER BY SZ3.R_E_C_N_O_"
			cSqlSZ3 := ChangeQuery(cSqlSZ3)
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,cSqlSZ3),cAliasSZ3,.F.,.T.)

			(cAliasSZ3)->(DbGoTop())

			While !(cAliasSZ3)->(Eof())

				RecLock("SZ9", .T.)
				SZ9->Z9_FILIAL 	:= SRA->RA_FILIAL
				SZ9->Z9_MAT		:= SRA->RA_MAT
				SZ9->Z9_TABELA	:= "SZ3"
				SZ9->Z9_CHAVE	:= (cAliasSZ3)->Z3_IDMOV
				SZ9->Z9_SALDO	:= 0
				SZ9->(MsUnLock())

				(cAliasSZ3)->(DbSkip())
			EndDo
			(cAliasSZ3)->(DbCloseArea())

		EndIf

		RecLock("SZ9", .T.)
		SZ9->Z9_FILIAL 	:= SRA->RA_FILIAL
		SZ9->Z9_MAT		:= SRA->RA_MAT
		SZ9->Z9_TABELA	:= "SZ3"
		SZ9->Z9_CHAVE	:= SZ3->Z3_IDMOV
		SZ9->Z9_SALDO	:= 0
		SZ9->(MsUnLock())

	Next i

	RestArea(aAreaSE2)
	RestArea(aAreaSZ1)
	RestArea(aAreaSZ3)

Return


//===================================
//PROGRAMA DE ESTORNO DO DESAFILIAR	=
//===================================
Static Function EstDesf(cMatricula)

	Local cSqlSZ9
	Local cAliasSZ9 := GetNextAlias()
	Local nQtqReg	:= 0

	Private oProcess

	If !MsgYesNo("Realmente Deseja executar o Estorno da Desfiliação?")
		Return
	EndIf

	cSqlSZ9 := "SELECT SZ9.Z9_TABELA, SZ9.Z9_CHAVE, SZ9.Z9_SALDO, SZ9.R_E_C_N_O_ AS RECNOSZ9 " + CRLF
	cSqlSZ9 += "FROM "+RetSqlName("SZ9")+" SZ9 " + CRLF
	cSqlSZ9 += "WHERE " + CRLF
	cSqlSZ9 += "      SZ9.Z9_FILIAL	 = '"+SRA->RA_FILIAL+"' AND " + CRLF
	cSqlSZ9 += "      SZ9.Z9_MAT	 = '"+SRA->RA_MAT+"'    AND " + CRLF
	cSqlSZ9 += "      SZ9.D_E_L_E_T_ = ' ' " + CRLF
	cSqlSZ9 += "ORDER BY SZ9.R_E_C_N_O_"
	cSqlSZ9 := ChangeQuery(cSqlSZ9)
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cSqlSZ9),cAliasSZ9,.F.,.T.)

	Count To nQtqReg

	If nQtqReg > 0
		oProcess := MsNewProcess():New({|| FEstDesf(cAliasSZ9,nQtqReg)},"Estorno da Desfiliação","Gerando Estorno da Desfiliação...",.F.)
		oProcess:Activate()
	Else
		MsgAlert("Nenhuma Desfiliação encontrada para este Cooperado.")
	EndIf

Return
Static Function FEstDesf(cAliasSZ9,nQtqReg)

	Local lContinua := .T.
	Local nPosFor	:= 0
	Local aFor		:= {}
	Local aRecSE2	:= {}
	Local aRecNDF	:= {}
	Local aRetorno  := {{}}
	Local cChave
	Local i
	Local cMsg
	Local cSolu

	(cAliasSZ9)->(DbGoTop())

	oProcess:SetRegua1(0)
	oProcess:IncRegua1(SRA->RA_NOME)

	oProcess:SetRegua2(nQtqReg)

	BEGIN TRANSACTION

		While (cAliasSZ9)->(!Eof())

			If (cAliasSZ9)->Z9_TABELA == "SE2"

				DbSelectArea("SE2")
				SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				SE2->(DbSeek(AllTrim((cAliasSZ9)->Z9_CHAVE)))

				nPosFor := Ascan(aFor,{|x|Alltrim(x[1]) == Alltrim(SE2->E2_FORNECE)})

				If nPosFor == 0
					AADD(aFor,{SE2->E2_FORNECE,{{},{},{}}})
					nPosFor := len(aFor)
				End if

				If Alltrim(SE2->E2_TIPO) == "NDF"
					AADD(aFor[nPosFor][2][2],SE2->(Recno()))

					cChave  := SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO +  E2_FORNECE + E2_LOJA)
					cChave	:= PadR(cChave,TamSX3("E5_DOCUMEN")[1])
					AADD(aFor[nPosFor][2][3],{cChave})
				Else
					AADD(aFor[nPosFor][2][1],SE2->(Recno()))
				Endif
			EndIf

			(cAliasSZ9)->(DbSkip())
		EndDo

		For i := 1 to Len(aFor)

			aRecSE2 := aClone(aFor[i][2][1])
			aRecNDF := aClone(aFor[i][2][2])
			aRetorno:= aClone(aFor[i][2][3])

			If Len(aRecNDF) > 0
				//MaIntBxCP(2,aRecSE2,,aRecCOMP   ,,{.T.,.F.,.F.,.F.,.F.,.F.},{||})
				//MaIntBxCP(2,aRecSE2,{0,0,0},aRecNDF,Nil,Nil,Nil, aRetorno)
				FWMsgRun(, {|| lContinua := MaIntBxCP(2,aRecSE2,,aRecNDF,,{.T.,.F.,.F.,.F.,.F.,.F.},,aRetorno) }	, "Processando", "Estornando as Compensações.")

				if !lContinua
					cMsg  := "Não foi possível descompensar os titulos."
					cSolu := "Favor verificar o estorno no financeiro."
					Help(NIL, NIL, "SERGP02 - EstDesf ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
					DisarmTransaction()
					Return .f.
				EndIf
			Endif
		Next i

		DbSelectArea("SZ9")
		SZ9->(DbSetOrder(1))

		//Excluindo os titulos estornados
		(cAliasSZ9)->(DbGoTop())
		While !(cAliasSZ9)->(Eof())

			If (cAliasSZ9)->Z9_TABELA == "SE2" .AND. lContinua

				oProcess:IncRegua2("Excluindo Títulos do Financeiro...")

				lContinua := EstSE2(AllTrim((cAliasSZ9)->Z9_CHAVE))

				If !lContinua
					DisarmTransaction()
					(cAliasSZ9)->(DbCloseArea())
					Return .F.
				Else

					//DELETE A SZ9
					SZ9->(DbGoTo((cAliasSZ9)->RECNOSZ9))
					RecLock("SZ9", .F.)
					DbDelete()
					SZ9->(MsUnLock())

				EndIf

			ElseIf (cAliasSZ9)->Z9_TABELA == "SZ1" .AND. lContinua

				oProcess:IncRegua2("Atualizando Despesas...")

				DbSelectArea("SZ1")
				SZ1->(DbSetOrder(1))//Z1_FILIAL+Z1_FORNECE+Z1_LOJA+Z1_NUM+Z1_PARCELA
				If SZ1->(DbSeek(RTRIM((cAliasSZ9)->Z9_CHAVE)))

					RecLock("SZ1", .F.)
					SZ1->Z1_SALDO := (cAliasSZ9)->Z9_SALDO
					SZ1->(MsUnLock())

					//DELETE A SZ9
					SZ9->(DbGoTo((cAliasSZ9)->RECNOSZ9))
					RecLock("SZ9", .F.)
					DbDelete()
					SZ9->(MsUnLock())

					lContinua := .T.
				Else
					lContinua := .F.
				EndIf

				If !lContinua
					DisarmTransaction()
					(cAliasSZ9)->(DbCloseArea())
					Return .F.
				EndIf

			ElseIf (cAliasSZ9)->Z9_TABELA == "SZ2" .AND. lContinua

				oProcess:IncRegua2("Atualizando Capital Cooperado...")

				DbSelectArea("SZ2")
				SZ2->(DbSetOrder(2))//Z2_FILIAL+Z2_IDMOV
				If SZ2->(DbSeek(RTRIM((cAliasSZ9)->Z9_CHAVE)))

					RecLock("SZ2", .F.)
					DbDelete()
					SZ2->(MsUnLock())

					//DELETE A SZ9
					SZ9->(DbGoTo((cAliasSZ9)->RECNOSZ9))
					RecLock("SZ9", .F.)
					DbDelete()
					SZ9->(MsUnLock())

					lContinua := .T.
				Else
					lContinua := .F.
				EndIf

				If !lContinua
					DisarmTransaction()
					(cAliasSZ9)->(DbCloseArea())
					Return .F.
				EndIf

			ElseIf (cAliasSZ9)->Z9_TABELA == "SZ3" .AND. lContinua

				oProcess:IncRegua2("Atualizando Capital Cooperado...")

				DbSelectArea("SZ3")
				SZ3->(DbSetOrder(3))//Z3_IDMOV
				If SZ3->(DbSeek(RTRIM((cAliasSZ9)->Z9_CHAVE)))

					RecLock("SZ3", .F.)
					DbDelete()
					SZ3->(MsUnLock())

					//DELETE A SZ9
					SZ9->(DbGoTo((cAliasSZ9)->RECNOSZ9))
					RecLock("SZ9", .F.)
					DbDelete()
					SZ9->(MsUnLock())

					lContinua := .T.
				Else
					lContinua := .F.
				EndIf

				If !lContinua
					DisarmTransaction()
					(cAliasSZ9)->(DbCloseArea())
					Return .F.
				EndIf

			EndIf

			(cAliasSZ9)->(DbSkip())
		EndDo
		(cAliasSZ9)->(DbCloseArea())

	END TRANSACTION

	If lContinua
		MsgInfo("Estorno Desafiliação Realizado Com Sucesso!")
	EndIf

Return
Static Function EstSE2(cChave)

	Local lRet 	  := .F.
	Local aTitulo := {}

	Private lMsErroAuto := .F.

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If SE2->(DbSeek(cChave))

		//aAdd(aTitulo, {"E2_FILIAL"	, SE2->E2_FILIAL	,NIL})
		//aAdd(aTitulo, {"E2_PREFIXO"	, SE2->E2_PREFIXO	,NIL})
		//aAdd(aTitulo, {"E2_NUM"		, SE2->E2_NUM	  	,NIL})
		//aAdd(aTitulo, {"E2_TIPO"		, SE2->E2_TIPO		,NIL})
		//aAdd(aTitulo, {"E2_ORIGEM"	, "GPEA265"			,NIL})

		aTitulo := {;
			{ "E2_FILIAL" 	, SE2->E2_FILIAL 	, NIL },;
			{ "E2_PREFIXO" 	, SE2->E2_PREFIXO 	, NIL },;
			{ "E2_NUM"     	, SE2->E2_NUM     	, NIL },;
			{ "E2_PARCELA" 	, SE2->E2_PARCELA  	, NIL },;
			{ "E2_TIPO"		, SE2->E2_TIPO		, NIL }}

		lMsErroAuto := .F.
		//MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5) //Exclui títulos à pagar

		RecLock("SE2", .F.)
		DbDelete()
		SE2->(MsUnLock())

		If lMsErroAuto
			MostraErro()
			lRet := .F.
		Else
			lRet := .T.
		EndIf

	EndIf

Return lRet
