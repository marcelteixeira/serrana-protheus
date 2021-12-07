#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} SERGPE01
Desconto Cooperado
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
User Function SERGPE01(cCodForn)

	Local aArea   := GetArea()
	Local oBrowse
	Default	cCodForn := ""

	Private aRotina := MenuDef()

	//Instânciando FWMBrowse
	oBrowse := FWMBrowse():New()

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERGPE01")

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZ1")

	If !Empty(cCodForn)
		oBrowse:SetFilterDefault("Z1_FORNECE = '" + cCodForn +"'")
	End iF

	//Setando a descrição da rotina
	oBrowse:SetDescription("Desconto Cooperados")

	// Adiciona legenda
	oBrowse:AddLegend("Z1_SALDO == Z1_VALOR " , "BR_VERDE"	  , "Em aberto")
	oBrowse:AddLegend("Z1_SALDO > 0 "  		  , "BR_AZUL"	  , "Baixado Parcialmente")
	oBrowse:AddLegend("Z1_SALDO == 0 "		  , "BR_VERMELHO" , "Baixado")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return

/*/{Protheus.doc} MenuDef
MenuDef
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

Static Function MenuDef()

	Local aRot := {}
	Local cGeraNF := "FWMsgRun(, {|| StaticCall(SERGPE01,GeraNDF) }, 'Processando', 'Gerando NDF...')"

	//Adicionando opções
	aAdd(aRot,{"Pesquisar"		,"VIEWDEF.SERGPE01"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"		,"VIEWDEF.SERGPE01"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 		,"VIEWDEF.SERGPE01"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 		,"VIEWDEF.SERGPE01"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 		,"VIEWDEF.SERGPE01"	,0,5,0,NIL})
	aAdd(aRot,{"Relatorio" 		,"U_SERR0001()"	,0,6,0,NIL})
	aAdd(aRot,{"Gerar NDF" 		,cGeraNF,0,4,0,NIL})

Return aRot

/*/{Protheus.doc} ModelDef
MenuDef
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

Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel  := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStSZ1   := FWFormStruct(1, "SZ1")
	Local oStSZ2   := FWFormStruct(1, "SZ2")
	Local bVlrMov  := {|oModel, nTotalAtual, xValor, lSomando| ValorMov(oModel, nTotalAtual, xValor, lSomando)}
	Local bVlSaldo := {|| SaldoMov(.t.)}
	Local bCommit  := {|| COMMIT(oModel) }
	Local bPos	   := {|oModel| ModelTOK(oModel)}
	Local bPrelinSZ2 := {|oModel,nLinha,cAcao,cCampo| PreLinSZ2(oModel,nLinha,cAcao,cCampo)}

	// Criando gatilhos da regra de negocio do modelo de dados
	aAux := FwStruTrigger("Z1_VALOR","Z1_SALDO", "StaticCall(SERGPE01,SaldoMov)",.F.,Nil,Nil,Nil)
	oStSZ1:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	// Cria o modelo
	oModel := MPFormModel():New("MSERGPE01",/*bPre*/, bPos,bCommit,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("SZ1MASTER",/*cOwner*/, oStSZ1)

	oStSZ2:AddField("" ,;															// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Z2_YLEGE",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	50,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD, "StaticCall(SERGPE01,Legenda)"),;	                        // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 						 									// [14] Virtual

	oStSZ2:SetProperty("Z2_SEQ", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "StaticCall(SERGPE01,NextSeq)"))

	//A função gera um identificador unico universal-UUID baseado na RFC 4122 versão 4.
	oStSZ2:SetProperty("Z2_IDMOV", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "FWUUIDV4()"))

	// Atribuindo Grid ao modelo
	oModel:AddGrid( "SZ2DETAIL", "SZ1MASTER",oStSZ2, bPrelinSZ2 /*[ bLinePre ]*/, {|oModel| SZ2LinOK(oModel)} /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)

	// Criando Relacionamentos
	oModel:SetRelation("SZ2DETAIL", {{"Z2_FILIAL","FwXFilial('SZ2')"}, {"Z2_FORNECE","Z1_FORNECE"} , {"Z2_LOJA","Z1_LOJA"} , {"Z2_NUM","Z1_NUM"} , {"Z2_PARCELA","Z1_PARCELA"} }, SZ2->( IndexKey( 1 ) ) )

	// Totais
	oModel:AddCalc("CALCTOTAIS","SZ1MASTER" ,"SZ2DETAIL","Z2_VALOR","SZ1_VALOR","FORMULA" ,/*bCondition*/, bVlrMov /*bInitValue*/,"R$ Movimento" 		 ,bVlrMov,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALCTOTAIS","SZ1MASTER" ,"SZ2DETAIL","Z2_VALOR","SZ2_BAIXA","SUM" 	  ,/*bCondition*/, 		   /*bInitValue*/,"R$ Total Baixa"   	 ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALCTOTAIS","SZ1MASTER" ,"SZ2DETAIL","Z2_VALOR","SZ2_SALDO","FORMULA" ,/*bCondition*/, 		   /*bInitValue*/,"R$ Saldo"   			 ,bVlSaldo ,13 /*nTamanho*/,3 /*nDecimal*/)

	// Permite salvar o GRID sem dados.
	oModel:GetModel( "SZ2DETAIL" ):SetOptional( .T. )

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({})

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)

	//Adicionando descrição ao modelo
	oModel:SetDescription("Descontos aos Cooperados")

	//Descricoes dos modelos de dados
	oModel:GetModel("SZ1MASTER"):SetDescription("Informações do descontos")
	oModel:GetModel("SZ2DETAIL"):SetDescription("Baixas realizadas")

	//Verifica se realiza ativição do Modelo
	oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )

Return oModel

Static Function ValidActv(oModel)

	Local lRet := .t.

	If TamSX3("E2_NUM")[1] != TamSX3("Z1_NUM")[1]
		cMsg  := "O campo Z1_NUM está com tamanho diferente do campo E2_NUM"
		cSolu := "Favor verificar os tamanhos dos campos no configurador."
		Help(NIL, NIL, "SERGPE01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.

	ElseIf  TamSX3("E2_PARCELA")[1] != TamSX3("Z1_PARCELA")[1]
		cMsg  := "O campo Z1_PARCELA está com tamanho diferente do campo E2_PARCELA"
		cSolu := "Favor verificar os tamanhos dos campos no configurador."
		Help(NIL, NIL, "SERGPE01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.

	Elseif TamSX3("E2_FORNECE")[1] != TamSX3("Z1_FORNECE")[1]
		cMsg  := "O campo Z1_FORNECE está com tamanho diferente do campo E2_FORNECE"
		cSolu := "Favor verificar os tamanhos dos campos no configurador."
		Help(NIL, NIL, "SERGPE01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	Elseif TamSX3("E2_LOJA")[1] != TamSX3("Z1_LOJA")[1]
		cMsg  := "O campo Z1_LOJA está com tamanho diferente do campo E2_LOJA"
		cSolu := "Favor verificar os tamanhos dos campos no configurador."
		Help(NIL, NIL, "SERGPE01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If


Return lRet

/*/{Protheus.doc} ViewDef
MenuDef
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

Static Function ViewDef()

	// Recupera o modelo de dados
	Local oModel := FWLoadModel("SERGPE01")
	//Criação da estrutura de dados da View
	Local oStSZ1   := FWFormStruct(2, "SZ1")
	Local oStSZ2   := FWFormStruct(2, "SZ2")
	Local oCalculo := FWCalcStruct(oModel:GetModel("CALCTOTAIS"))
	Local oView := Nil

	// Remoção de campos relacionais
	oStSZ2:RemoveField("Z2_FORNECE") ; oStSZ2:RemoveField("Z2_LOJA") ; oStSZ2:RemoveField("Z2_PARCELA") ; oStSZ2:RemoveField("Z2_NUM")

	oStSZ2:AddField("Z2_YLEGE",; //Id do Campo
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
	oView:AddField("VIEW_SZ1"    , oStSZ1   , "SZ1MASTER")
	oView:AddGrid( "VIEW_SZ2"    , oStSZ2	, "SZ2DETAIL")
	oView:AddField("VIEW_CLC"    , oCalculo , "CALCTOTAIS")

	//Criando os paineis
	oView:CreateHorizontalBox("SUPERIOR",050)
	oView:CreateHorizontalBox("INFERIOR",043)
	oView:CreateHorizontalBox("TOTAIS"	,007)

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZ1","SUPERIOR")
	oView:SetOwnerView("VIEW_SZ2","INFERIOR")
	oView:SetOwnerView("VIEW_CLC","TOTAIS")

	//Adicionado Descrições
	oView:EnableTitleView("VIEW_SZ2"    , "Movimentos de Baixas" )

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

Return oView

Static Function ModelTOK(oModel)

	Local aAreaSZ1	:= SZ1->(GetArea())
	Local lRet := .t.
	Local oModelSZ2 := oModel:GetModel("SZ2DETAIL")
	Local oModelSZ1 := oModel:GetModel("SZ1MASTER")
	Local nOperacao := oModel:GetOperation()
	Local cCodCMV	:= oModelSZ1:GetValue("Z1_NUM")
	Local cParCMV	:= oModelSZ1:GetValue("Z1_PARCELA")
	Local cForCMV	:= oModelSZ1:GetValue("Z1_FORNECE")
	Local cLojCMV	:= oModelSZ1:GetValue("Z1_LOJA")

	Local cCond		:= oModelSZ1:GetValue("Z1_COND")
	Local nSaldo	:= oModelSZ1:GetValue("Z1_SALDO")
	Local aVenc := Condicao(nSaldo,cCond,,DDATABASE)

	// Valida exclusão
	If nOperacao == MODEL_OPERATION_DELETE

		// Verifica se possui baixas registradas
		If !oModelSZ2:IsEmpty()
			oModel:SetErrorMessage("",,oModel:GetId(),"","ModelTOK","Existem movimentações de baixas.","Exclua as movimentações primeiro.")
			Return .f.
		End If
	End IF

	// pra nao gerar CMV duplicado
	If  nOperacao == MODEL_OPERATION_INSERT
		SZ1->(DbSetOrder(1))
		If SZ1->(DbSeek(xFilial("SZ1") + cForCMV  + cLojCMV + cCodCMV + cParCMV))
			oModel:SetErrorMessage("",,oModel:GetId(),"","ModelTOK","Ja existe um CMV com essas configurações.","Favor alterar a parcela do CMV.")
			lRet := .f.
		End If

		IF !IsBlind() .AND.  !Empty(cCond) .AND. !MSGYESNO( "Condição de pagamento informada. Deseja gerar " + alltrim(STR(len(aVenc))) + " CMV(s)?", "Gerar CMV" )
			oModel:SetErrorMessage("",,oModel:GetId(),"","ModelTOK","Cancelado a geração de parcelas do CMV com essa condição.","Favor alterar a condição do CMV ou aceitar gerar as parcelas")
			lRet := .f.
		EndIf

	End IF
	RestArea(aAreaSZ1)
Return lRet

/*/{Protheus.doc} COMMIT
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function COMMIT(oModel)

	Local lRet 			:= .t.
	Local nOperacao 	:= oModel:GetOperation()
	Local oModelSZ1 	:= oModel:GetModel("SZ1MASTER")
	Local oModelSZ2 	:= oModel:GetModel("SZ2DETAIL")
	Local cFornece		:= oModelSZ1:GetValue("Z1_FORNECE")
	Local cLoja			:= oModelSZ1:GetValue("Z1_LOJA")
	Local cCodIntegra 	:= SuperGetMV("MV_YCODINT",.F.,"GPE0689") // Despesa de integralizacao
	Local aLinChanged 	:= oModelSZ2:GetLinesChanged()
	Local lIntegraliza 	:= .f.
	Local cErro		 	:= ""
	Local i  			:= 0

	PRIVATE lMsErroAuto := .F.

	//Integralização de capital

	// Verifica se o lançamento é referente a integralização de capital
	IF Alltrim(oModelSZ1:GetValue("Z1_CODDESP")) $ Alltrim(cCodIntegra)

		// Localiza o codigo do autonomo atraves do codigo do fornecedor
		SA2->(DbSetOrder(1))

		If SA2->(Dbseek(xFilial("SA2") + cFornece + cLoja))

			lIntegraliza := .t.

			// Instancia o Modelo de dados do capital Social
			oModelGPE20:= FWLoadModel("SERGPE02")
			oModelGPE20:SetOperation(MODEL_OPERATION_UPDATE)
			oModelGPE20:Activate()

		End if
	End if

	BEGIN TRANSACTION

		// Realiza o commit
		lRet := FWFormCommit(oModel)

		If lRet

			For i:= 1 to len(aLinChanged)

				// Posiciona o Modelo na linha modificada.
				oModelSZ2:GoLine(aLinChanged[i])

				// Realiza a integralização do capital social se possuir
				If lIntegraliza

					FWMsgRun(, {|| lRet := IntCapital(oModel,oModelGPE20) }		, "Processando", "SERGPE01 - Integrando com o Capital Social...")

					If !lRet
						cErro := GetErroModel(oModel,"COMMIT")
						Help(NIL, NIL, "SERGPE01 - COMMIT(IntCapital)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
						DisarmTransaction()
						Return .F.
					End If

				End If
			Next

			// Verifica se houver alguma modificação no modelo de dados.
			IF lIntegraliza .and. oModelGPE20:lModify
				//Validação e Gravação do Modelo
				If oModelGPE20:VldData()
					// Verifica o Commit
					If !oModelGPE20:CommitData()
						cErro:= GetErroModel(oModelGPE20,"Erro na validação CommitData do modelo oModelGPE20")
						oModel:SetErrorMessage("",,oModel:GetId(),"","IntCapital",cErro)
						DisarmTransaction()
						Return .f.
					End if
				Else
					cErro:= GetErroModel(oModelGPE20,"Erro na validação VldData oModelGPE20")
					oModel:SetErrorMessage("",,oModel:GetId(),"","IntCapital",cErro)
					DisarmTransaction()
					Return .f.
				EndIf
			End If

			if oModel:GetOperation() == MODEL_OPERATION_INSERT  .and. !(Empty(oModelSZ1:getValue("Z1_COND")))
				lret := GeraParc(oModel)
			EndIF

			if !(lret)
				DisarmTransaction()
				Return .f.
			endIf
		End if

	END TRANSACTION

Return lRet

Static function alteraParc(oModel)

	Local aAreaSZ1	:= SZ1->(GetArea())
	Local oModelSZ2 := oModel:GetModel("SZ2DETAIL")
	Local oModelSZ1 := oModel:GetModel("SZ1MASTER")
	Local nOperacao := oModel:GetOperation()
	Local cCodCMV	:= oModelSZ1:GetValue("Z1_NUM")
	Local cParCMV	:= oModelSZ1:GetValue("Z1_PARCELA")
	Local cForCMV	:= oModelSZ1:GetValue("Z1_FORNECE")
	Local cLojCMV	:= oModelSZ1:GetValue("Z1_LOJA")
	Local nPosC		:= 1
	Local cCond		:= oModelSZ1:GetValue("Z1_COND")
	Local nSaldo	:= oModelSZ1:GetValue("Z1_SALDO")

	Local aVenc := Condicao(nSaldo,cCond,,DDATABASE)


	SZ1->(DbSetOrder(1))
	If SZ1->(DbSeek(xFilial("SZ1") + cForCMV  + cLojCMV + cCodCMV ))
		while ! SZ1->(eof()) .and.;
				SZ1->Z1_FILIAL  == xfilial("SZ1") .and.;
				SZ1->Z1_FORNECE == cForCMV        .and.;
				SZ1->Z1_LOJA   	== cLojCMV        .and.;
				SZ1->Z1_NUM 	== cCodCMV

			reclock("SZ1",.F.)
			SZ1->Z1_VENCTO := aVenc[nPosC][1]
			SZ1->Z1_VALOR  := aVenc[nPosC][2]
			SZ1->Z1_SALDO  := aVenc[nPosC][2]
			SZ1->Z1_COND   := cCond
			msunlock()
			nPosC++

			SZ1->(dbskip())

		End
	End If

	RestArea(aAreaSZ1)

Return

Static Function GeraParc(oModel)

	Local lRet 			:= .t.
	Local oModelSZ1 	:= oModel:GetModel("SZ1MASTER")
	Local cCond			:= oModelSZ1:GetValue("Z1_COND")
	Local nSaldo		:= oModelSZ1:GetValue("Z1_SALDO")
	Local oModelASZ1		:= NIL
	Local aStrucSZ1		:= NIL
	Local aVenc := Condicao(nSaldo,cCond,,DDATABASE)
	Local np := 0,nx :=0
	Local lMsErroAuto := .f.
	Local cCodCMV	:= oModelSZ1:GetValue("Z1_NUM")
	Local cParCMV	:= oModelSZ1:GetValue("Z1_PARCELA")
	Local cForCMV	:= oModelSZ1:GetValue("Z1_FORNECE")
	Local cLojCMV	:= oModelSZ1:GetValue("Z1_LOJA")

	For np := 1 to len(aVenc)
		if(np == 1 )
			loop
		Endif

		oModelASZ1 := FWLoadModel("SERGPE01")
		oModelASZ1:setOperation(MODEL_OPERATION_INSERT)
		oModelASZ1:activate()
		aStrucSZ1 := oModelSZ1:GetStruct():GetFields()
		lMsErroAuto := .f.
		For nx := 1 to len(aStrucSZ1)

			if(aStrucSZ1[nx][3] $ 'Z1_PARCELA')
				oModelASZ1:SetValue("SZ1MASTER",aStrucSZ1[nx][3],StrZero(np,TAMSX3("Z1_PARCELA")[1]))
			elseif(aStrucSZ1[nx][3] $ 'Z1_VALOR/Z1_SALDO')
				oModelASZ1:SetValue("SZ1MASTER",aStrucSZ1[nx][3],aVenc[np][2])
			elseif(aStrucSZ1[nx][3] $ 'Z1_VENCTO')
				oModelASZ1:SetValue("SZ1MASTER",aStrucSZ1[nx][3],aVenc[np][1])
			elseif(aStrucSZ1[nx][3] $ 'Z1_COND')
				LOOP
			else
				oModelASZ1:SetValue("SZ1MASTER",aStrucSZ1[nx][3],oModelSZ1:getValue(aStrucSZ1[nx][3]))
			EndIF

		Next

		lMsErroAuto:= !oModelASZ1:VldData()

		If lMsErroAuto

			aErro    := oModelASZ1:GetErrorMessage()
			cMsgErro := cValToChar(aErro[06]) + CHR(10)
			cMsgErro += cValToChar(aErro[07])
			oModel:SetErrorMessage("",,oModel:GetId(),"","GeraParc",cMsgErro)
			Return .f.

		else
			lMsErroAuto := !oModelASZ1:CommitData()

			If lMsErroAuto
				aErro    := oModelASZ1:GetErrorMessage()
				cMsgErro := cValToChar(aErro[06]) + CHR(10)
				cMsgErro += cValToChar(aErro[07])
				oModel:SetErrorMessage("",,oModel:GetId(),"","GeraParc",cMsgErro)
				Return .f.
			EndIf
		endif

		oModelASZ1:Destroy()

	Next

	if lret .and. !(Empty(cCond))
		alteraParc(oModel)
	EndIf

Return lRet

/*/{Protheus.doc} GeraNDF
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GeraNDF()

	Local cMsg  := ""
	Local cSolu := ""
	Local cHist := "Gerado NDF no Financeiro por " + cUserName

	// Verifica se existe saldo para gerar uma NDF
	if SZ1->Z1_SALDO == 0
		cMsg  := "Não é possivel gerar uma NDF para este movimento."
		cSolu := "Favor selecionar registro que possui saldo maior que zero."
		Help(NIL, NIL, "SERGPE01 - GeraNDF", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .F.
	End If

	IF MSGYESNO( "Deseja gerar uma NDF para este CMV?", "Gerar NDF" )
		U_BaixaCMV(,,,,cHist)
	End If

Return



/*/{Protheus.doc} IntCapital
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param oModelGPE20, object, description
@type function
/*/
Static Function IntCapital(oModel,oModelGPE20)

	Local oModelSZ1   := oModel:GetModel("SZ1MASTER")
	Local oModelSZ2   := oModel:GetModel("SZ2DETAIL")
	Local oModelSZ3	  := oModelGPE20:GetModel("SZ3DETAIL")
	Local lValid      := .T.
	Local cErro		  := ""
	Local lDelete 	  := .f.
	Local cHistori	  := ""

	// Verifica se houver uma baixa nova
	If oModelSZ2:IsInserted()

		// Verifica se modelo está vazio.
		If !oModelSZ3:IsEmpty()
			// Adiciona uma linha no modelo.
			oModelSZ3:AddLine()
		End If

		// Caso encontra o registro no capital social
	ElseIf oModelSZ2:IsDeleted()

		If oModelSZ3:SeekLine({{"Z3_IDORIG",oModelSZ2:GetValue("Z2_IDMOV")},{"Z3_TABORI","SZ2"}})

			lDelete:= .t.

			// Verifica se modelo está vazio.
			If !oModelSZ3:IsEmpty()
				// Adiciona uma linha no modelo.
				oModelSZ3:AddLine()
			End If
		Else
			Return .t.
		End iF

		// Alteração apenas retornar como verdadeiro
	Else
		Return .t.
	End if

	If lValid
		lValid := oModelSZ3:SetValue( "Z3_FORNECE" , oModelSZ1:GetValue("Z1_FORNECE") )
	End If

	If lValid
		lValid := oModelSZ3:SetValue( "Z3_LOJA"  ,  oModelSZ1:GetValue("Z1_LOJA"))
	End if

	If lValid
		lValid := oModelSZ3:SetValue( "Z3_TIPOLAN" , "A" )
	End if

	If lValid

		// Lancamento a Debito no capital do cooperado para realizar o estorno.
		lValid := oModelSZ3:SetValue( "Z3_TIPMOV"  ,IIF(lDelete,"D","C")  )

	End if

	If lValid
		lValid := oModelSZ3:SetValue( "Z3_VALOR" , oModelSZ2:GetValue("Z2_VALOR")  )
	End if

	If lValid

		If lDelete
			//cHistori := "Estorno realizado pela exclusão da baixa do Movimento:"
			cHistori := SUBSTR("Estorno - " + oModelSZ2:GetValue("Z2_HISTOR"),1,TAMSX3("Z3_HISTOR")[1] )
		Else
			//cHistori := "Integralização realizado pela baixa do Movimento:"
			cHistori := SUBSTR("Integr. - " + oModelSZ2:GetValue("Z2_HISTOR"),1,TAMSX3("Z3_HISTOR")[1] )
		End iF

		//cHistori +=  ALLTRIM(oModelSZ1:GetValue("Z1_NUM")) + " Parc.:" + ALLTRIM(oModelSZ1:GetValue("Z1_PARCELA")) + " Seq.:" + oModelSZ2:GetValue("Z2_SEQ")

		lValid := oModelSZ3:SetValue( "Z3_HISTOR" , cHistori )

	End if

	// Seta o relacionamento
	If lValid
		lValid := oModelSZ3:SetValue( "Z3_IDORIG" , oModelSZ2:GetValue("Z2_IDMOV") )
	End if

	If lValid
		lValid := oModelSZ3:SetValue( "Z3_TABORI" , "SZ2" )
	End if

	// Esta instrução tem que ser por ultimo.
	If lValid
		lValid := oModelSZ3:SetValue( "Z3_ROTINA" , "SERGPE01"  )
	End if

	// Verifica se o modelo ficou com algum erro após atribuição dos valores
	If oModelGPE20:HasErrorMessage()
		cErro:= GetErroModel(oModelGPE20,"Erro na validação SetValue do modelo oModelGPE20")
		oModel:SetErrorMessage("",,oModel:GetId(),"","IntCapital",cErro)
		Return .f.
	End If

Return lValid


/*/{Protheus.doc} Legenda
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function Legenda()

	Local oModel  := FwModelActive()
	Local cRotina := ALLTRIM(SZ2->Z2_ROTINA)
	Local cTipoMov := ALLTRIM(SZ2->Z2_TIPMOV)
	Local cLegenda := "BR_VERDE"

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		Return "BR_VERDE"
	End IF

	IF cTipoMov == "M" .AND. cRotina == Funname()

		Return "BR_VERDE"
	ElseIf cTipoMov == "A" .AND. cRotina == Funname()

		Return "BR_AMARELO"

	ElseIf cTipoMov == "A" .AND. cRotina != Funname()
		Return "BR_VERMELHO"

	Else
		Return "BR_VERDE"

	End if

Return  cLegenda


/*/{Protheus.doc} PreLinSZ2
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param nLinha, numeric, description
@param cAcao, characters, description
@param cCampo, characters, description
@type function
/*/
Static Function PreLinSZ2(oModel,nLinha,cAcao,cCampo)

	Local lRet := .T.
	Local cRotina := ALLTRIM(oModel:GetValue("Z2_ROTINA"))
	Local cTipoMov := ALLTRIM(oModel:GetValue("Z2_TIPMOV"))
	Local cMsg	:= ""
	Local cSolu := ""

	// Verifica se é Alteração
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE

		// Verifica se a linha foi gerada pela propria rotina.
		If cTipoMov == "M"
			Return .T.

			// Geração do NDF
		ElseIF (cTipoMov == "A" .AND. cRotina =="SERGPE01" .and. cAcao $ "UNDELETE/DELETE") .or. oModel:IsInserted()
			Return .t.
		ElseIf cTipoMov == "A" .and. Alltrim(cRotina) == Funname()
			Return .t.
		Else
			cMsg  := "Não é possivel realizar tal ação ("+ cAcao +") neste registro, uma vez que o mesmo foi integrado em outro Modulo/Rotina."
			cSolu := "Favor selecionar outro registro para prestar manutenção ou utilize a rotina geradora. (" + cRotina + ")"
			Help(NIL, NIL, "SERGPE01 - PreLinSZ2", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End If
	End If

Return lRet


/*/{Protheus.doc} SZ2LinOK
Demonstra o valor do desconto
@type  Function
@author Totvs Vitoria
@since 16/09/2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SZ2LinOK(oModel)

	Local cMsg 	 := ""
	Local cSolu  := ""
	Local nSaldo := SaldoMov() // Recalcula o saldo.
	Local lRet   := .T.
	Local cTipMv := oModel:GetValue("Z2_TIPMOV")
	Local cUsrLib:= SuperGetMV("MV_USBXCMV",.F.,"")

	if nSaldo < 0

		cMsg  := "O Saldo ficará negativo com esta ação."
		cSolu := "Favor informar o valor da baixa menor ou igual ao saldo do movimento."
		Help(NIL, NIL, "SERGPE01 - SZ2LinOK", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

	// Verifica qual usuario possui permissao para baixa MANUAL
	If cTipMv == "M"

		// Se for INSERT da linha e ainda nao tiver nada
		// deixa o usuario prosseguir.
		If oModel:IsInserted() .and. oModel:IsEmpty()
			lRet := .t.

			// Verifica se o usuario possui acesso.
		ElseIf RetCodUsr() $ cUsrLib
			lRet := .T.
		Else
			cMsg  := "Usuário sem permissão para realizar baixa manual no CMV."
			cSolu := "Favor incluir no parametro: MV_USBXCMV."
			Help(NIL, NIL, "SERGPE01 - SZ2LinOK", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			lRet := .F.
		End If
	Else
		lRet := .t.
	End if

Return lRet

/*/{Protheus.doc} SaldoMov
Calcula o saldo do movimento

***** ATENCAO *******
O parametro lCalc, deve ser verdadeiro na chamada
da função do modelo de calculo, caso seja falso
ou estiver alguma instrução utilizando o SetValue nos campos
que a função de calculo está atrelada, pode da loop infinito dentro desta função.

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
Static Function SaldoMov(lCalc,oModel)

	Local nRet				:= 0
	Local oModelTotal		:= Nil
	Local oModelSZ1			:= Nil
	Local oModelSZ2			:= Nil
	Local nValorBkp			:= 0
	Local nOper				:= 0

	Default oModel := FwModelActive()
	Default lCalc := .f.

	oModelTotal		:= oModel:GetModel("CALCTOTAIS")
	oModelSZ1		:= oModel:GetModel("SZ1MASTER")
	oModelSZ2		:= oModel:GetModel("SZ2DETAIL")
	nOper  			:= oModel:GetOperation()

	nRet 	  		:=  oModelSZ1:GetValue("Z1_VALOR") - oModelTotal:GetValue("SZ2_BAIXA")
	nValorBkp 		:= oModelSZ2:GetValue("Z2_VALOR")

	If nOper != MODEL_OPERATION_DELETE

		// atualiza o valor do saldo
		oModelSZ1:LoadValue("Z1_SALDO", nRet)

		// Quando chamado essa função for chamada pelo modelo de calculo (CALCTOTAIS),
		// a sintaxe abaixo "SetValue" não pode ser execultada, uma vez que a mesma
		// vai chamar essa função de saldo novamente e cairia no Loop Infinito
		// até que o sistema caia por completo.
		// Foi utiizada desta forma para chamar a função de calculo para atualizar os valores na tela pro usuario.
		if !lCalc
			oModelSZ2:SetValue("Z2_VALOR", nValorBkp)
		End if
	End If

Return nRet

/*/{Protheus.doc} ValorMov
Demonstra o valor do desconto
@type  Function
@author Totvs Vitoria
@since 16/09/2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ValorMov(oModel, nTotAtu, xValor, lSomando)

	Local nRet				:= 0
	Local oModelSZ1			:= oModel:GetModel("SZ1MASTER")

	nRet :=  oModelSZ1:GetValue("Z1_VALOR")

Return nRet

/*/{Protheus.doc} BaixaCMV
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nRecSZ1, numeric, description
@param cNumero, characters, description
@param cPrefixo, characters, description
@param cParcela, characters, description
@param cHist, characters, description
@type function
/*/
User Function BaixaCMV(nRecSZ1,cNumero,cPrefixo,cParcela,cHist)

	Local aArray	 := {}
	Local oModelCMV	 := Nil
	Local cNatuDeb	 := ""
	Local cErro		 := ""
	Local oModelSZ1	 := Nil
	Local oModelSZ2  := Nil
	Local lValid	 := .t.
	Local cIdMov	 := ""
	Local nSaldo	 := 0
	Local lRet		 := .t.

	Default cPrefixo := SuperGetMV("MV_YPRFCMV",.f.,"DEB")
	Default cNumero	 := SZ1->Z1_NUM
	Default cParcela := SZ1->Z1_PARCELA
	Default cHist	 := ""
	Default nRecSZ1	 := SZ1->(RECNO())
	Private lMsErroAuto	:= .f.

	// Posiciona no CMV
	DT7->(DbSetOrder(1))
	SZ1->(DbSetOrder(1))

	SZ1->(DbGoto(nRecSZ1))

	// Instancia o modelo de dados
	oModelCMV:= FwLoadModel("SERGPE01")
	oModelCMV:SetOperation(MODEL_OPERATION_UPDATE)
	oModelCMV:Activate()

	// Verifica se conseguiu ativar o modelo
	if !oModelCMV:Activate()

		// Verifica o motivo de não ativação do modelo
		If oModelCMV:HasErrorMessage()
			// Recupera o erro
			cErro := GetErroModel(oModelCMV)
			cMsg  := cErro
			cSolu := ""
			Help(NIL, NIL, "SERGPE01 - BaixaCMV/Activate", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End If

	End if

	// Recupera o modelos de dados inferiores
	oModelSZ1 := oModelCMV:GetModel("SZ1MASTER")
	oModelSZ2 := oModelCMV:GetModel("SZ2DETAIL")

	// Verifica se o registro possui alguma baixa
	If !oModelSZ2:IsEmpty()
		// Adiciona uma linha no modelo.
		oModelSZ2:AddLine()
	End If

	// Recupera o valor do saldo em aberto
	nSaldo := oModelSZ1:GetValue("Z1_SALDO")

	// Inclua a baixa do CMV
	If lValid
		lValid := oModelSZ2:SetValue("Z2_VALOR"  , oModelSZ1:GetValue("Z1_SALDO") )
	End If

	If lValid
		lValid := oModelSZ2:SetValue("Z2_HISTOR" , cHist)
	End If

	If lValid
		lValid := oModelSZ2:SetValue("Z2_TIPMOV"  , "A" )
	End if

	If lValid
		// Informa que foi integrado no Financeiro CP, sendo assim, somente
		// o financeiro pode excluir tal baixa. Ponto de Entrada FA050DEL
		lValid := oModelSZ2:SetValue("Z2_ROTINA"  , "FINA050" )
	End if

	// Verifica o motivo de não ativação do modelo
	If oModelCMV:HasErrorMessage() .and. !lValid
		// Recupera o erro
		cErro := GetErroModel(oModelCMV)
		cMsg  := cErro
		cSolu := ""
		Help(NIL, NIL, "SERGPE01 - BaixaCMV/ValidCampos", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .F.
	End If

	// Recupera o ID do movimento
	cIdMov := oModelSZ2:GetValue("Z2_IDMOV")

	// Realiza a validação do modelo
	If oModelCMV:VldData()

		// Verifica se realizou o commit
		If !oModelCMV:CommitData()
			// Recupera o erro do modelo
			cErro := GetErroModel(oModelCMV)
			cMsg  := cErro
			cSolu := ""
			Help(NIL, NIL, "SERGPE01 - BaixaCMV/CommitData", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End if
	Else
		// Recupera o erro do modelo
		cErro := GetErroModel(oModelCMV)
		cMsg  := cErro
		cSolu := ""
		Help(NIL, NIL, "SERGPE01 - BaixaCMV/VldData", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .F.
	End if

	// Posicione no cadastro da despesa
	DT7->(DbSeek(xFilial("DT7") + SZ1->Z1_CODDESP))

	// Verifica se na despesa existe uma natureza
	If Empty(DT7->DT7_YNATUR)
		cNatuDeb := Padr(SuperGetMV("MV_NATDEB",.f.,""), Len( SE2->E2_NATUREZ ) )
	Else
		cNatuDeb := Padr(DT7->DT7_YNATUR,Len( SE2->E2_NATUREZ ) )
	EndIf

	cParcela := PADL(cParcela,Len( SE2->E2_PARCELA ), "0")

	// Gerando NDF para o CMV
	aArray := { { "E2_PREFIXO"  , cPrefixo   		, NIL },;
		{ "E2_NUM"      , cNumero   		, NIL },;
		{ "E2_PARCELA"  , cParcela   		, NIL },;
		{ "E2_TIPO"     , "NDF"             , NIL },;
		{ "E2_NATUREZ"  , cNatuDeb          , NIL },;
		{ "E2_FORNECE"  , SZ1->Z1_FORNECE   , NIL },;
		{ "E2_LOJA"  	, SZ1->Z1_LOJA   	, NIL },;
		{ "E2_EMISSAO"  , DDATABASE			, NIL },;
		{ "E2_VENCTO"   , DDATABASE			, NIL },;
		{ "E2_VENCREA"  , DDATABASE			, NIL },;
		{ "E2_HIST"   	, SUBSTR(DT7->DT7_DESCRI,1,LEN(SE2->E2_HIST)), NIL },;
		{ "E2_YTABORI"  ,"SZ2"				, NIL },;
		{ "E2_YIDORIG"  ,cIdMov				, NIL },;
		{ "E2_YCODDES"  ,SZ1->Z1_CODDESP	, NIL },;
		{ "E2_VALOR"    ,nSaldo      		, NIL } }

	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)

	If lMsErroAuto
		MostraErro()
		Return .f.
	End If

Return lRet

/*/{Protheus.doc} GetErroModel
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
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

/*/{Protheus.doc} NextSeq
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function NextSeq()

	Local oModel := FwModelActive()
	Local oModelSZ2 := oModel:GetModel("SZ2DETAIL")
	Local nRegist   := oModelSZ2:Length()
	Local nLinha 	:= oModelSZ2:GetLine()
	Local cProxNum  := ""

	If nRegist == 0
		cProxNum := PadL("1",TamSx3("Z2_SEQ")[1],"0")
	Else
		oModelSZ2:GoLine(nRegist)
		cProxNum := SOMA1(oModelSZ2:GetValue("Z2_SEQ"))
		oModelSZ2:GoLine(nLinha)
	End If

Return cProxNum
