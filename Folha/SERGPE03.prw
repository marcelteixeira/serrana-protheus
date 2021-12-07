#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"

Static cAliasTrab := GetNextAlias()


/*/{Protheus.doc} SERGPE03
Rotina que envia Plano de saude/Lancamentos Fixos e Lancamentos Futuros
para criar o CMV.
@author Totvs Vitoria - Mauricio Silva
@since 25/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function SERGPE03()

	Local oView  	 := FWLoadView("SERGPE03")
	Local oModel 	 := FWLoadModel("SERGPE03")

	Local aButtons := { {.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL}	,;
						  {.F.,NIL},{.t.,"Gerar CMV"},{.T.,"Fechar"},{.F.,NIL}		,;
						  {.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL} }

	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()

	oView:SetModel(oModel)
	oView:SetOperation(MODEL_OPERATION_UPDATE)  
	oView:SetProgressBar(.t.)
						
	oExecView := FWViewExec():New()
	oExecView:SetButtons(aButtons)
	oExecView:setTitle(".")
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:OpenView(.F.)

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


	//Adicionando opções
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERGPE03"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERGPE03"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERGPE03"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERGPE03"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERGPE03"	,0,5,0,NIL})


Return aRot


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
    Local oStRHR  := Nil
    Local oStSRA  := Nil
    Local oStRG1  := Nil
    Local oStSRK  := Nil
    Local oStCAB  := Nil

    //Cargas
    Local bCarga  := {|| {xFilial("SRA")}}
    Local bLoadSRA:= {|oGridModel, lCopy| LoadSRA(oGridModel, lCopy,oModel)}
    Local bLoadRG1:= {|oGridModel, lCopy| LoadRG1(oGridModel, lCopy,oModel)}
    Local bLoadSRK:= {|oGridModel, lCopy| LoadSRK(oGridModel, lCopy,oModel)}
    Local bLoadRHR:= {|oGridModel, lCopy| LoadRHR(oGridModel, lCopy,oModel)}
    Local bCommit := {|| Commit(oModel)}

    // Apenas para criar a estrura do MVC
    AreaTrab()

    // Monta o cabeçalho Fake
    oStCAB	   := FWFormModelStruct():New()
    oStCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)

    // Monta Estrutura baseado na Area de Trabalho da query
    oStSRA := FWFormModelStruct():New()
    oStSRA:AddTable(cAliasTrab,{"",""},"",{|| })
    StrMVC(1,cAliasTrab, oStSRA)

    oStRHR := FWFormModelStruct():New()
    oStRHR:AddTable(cAliasTrab,{"",""},"",{|| })
    StrMVC(1,cAliasTrab, oStRHR)

    oStRG1 := FWFormModelStruct():New()
    oStRG1:AddTable(cAliasTrab,{"",""},"",{|| })
    StrMVC(1,cAliasTrab, oStRG1)

    oStSRK := FWFormModelStruct():New()
    oStSRK:AddTable(cAliasTrab,{"",""},"",{|| })
    StrMVC(1,cAliasTrab, oStSRK)

    oModel := MPFormModel():New("MSERGPE03",/*bPre*/,/*bPos*/,bCommit,/*bCancel*/) 
    
    // Bloqueios todos os campos
    oStSRA:SetProperty( '*', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
    oStRHR:SetProperty( '*', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
    oStRG1:SetProperty( '*', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
    oStSRK:SetProperty( '*', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))

    // Libera alguns campos para edicao
    oStSRA:SetProperty( 'STATUS', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
    oStRHR:SetProperty( 'STATUS', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
    oStRG1:SetProperty( 'STATUS', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
    oStSRK:SetProperty( 'STATUS', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))

    oStSRA:SetProperty( 'RETORNO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
    oStRHR:SetProperty( 'RETORNO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
    oStRG1:SetProperty( 'RETORNO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
    oStSRK:SetProperty( 'RETORNO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))

    oStSRA:SetProperty( 'STATUS', MODEL_FIELD_TAMANHO ,50)
    oStRHR:SetProperty( 'STATUS', MODEL_FIELD_TAMANHO ,50)
    oStRG1:SetProperty( 'STATUS', MODEL_FIELD_TAMANHO ,50)
    oStSRK:SetProperty( 'STATUS', MODEL_FIELD_TAMANHO ,50)

    oStSRA:SetProperty( 'RETORNO', MODEL_FIELD_TAMANHO ,10000)
    oStRHR:SetProperty( 'RETORNO', MODEL_FIELD_TAMANHO ,10000)
    oStRG1:SetProperty( 'RETORNO', MODEL_FIELD_TAMANHO ,10000)
    oStSRK:SetProperty( 'RETORNO', MODEL_FIELD_TAMANHO ,10000)


    // Cria o modelo
    oModel:AddFields("CABMASTER",/*cOwner*/,oStCAB,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
    oModel:SetPrimaryKey({""})

    oModel:AddGrid( "SRADETAIL" , "CABMASTER"  , oStSRA ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadSRA)
    oModel:AddGrid( "RHRDETAIL" , "SRADETAIL"  , oStRHR ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadRHR)
    oModel:AddGrid( "RG1DETAIL" , "SRADETAIL"  , oStRG1 ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadRG1)
    oModel:AddGrid( "SRKDETAIL" , "SRADETAIL"  , oStSRK ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadSRK)

    oModel:SetRelation("SRADETAIL" ,{{"RA_FILIAL","xFilial('SRA')"}},SRA->(IndexKey(1)))
    oModel:SetRelation("RHRDETAIL" ,{{"RHR_FILIAL","xFilial('RHR')"}, {"RHR_MAT","RA_MAT"}},RHR->(IndexKey(1)))
    oModel:SetRelation("SRKDETAIL" ,{{"RG1_FILIAL","xFilial('RG1')"}, {"RG1_MAT","RA_MAT"}},RG1->(IndexKey(1)))
    oModel:SetRelation("RG1DETAIL" ,{{"SRK_FILIAL","xFilial('SRK')"}, {"SRK_MAT","RA_MAT"}},SRK->(IndexKey(1)))

    // Preenchimento Opcional
    oModel:GetModel("SRADETAIL"):SetOptional( .T. )
    oModel:GetModel("RHRDETAIL"):SetOptional( .T. )
    oModel:GetModel("RG1DETAIL"):SetOptional( .T. )
    oModel:GetModel("SRKDETAIL"):SetOptional( .T. )

    // Muda a estrutura para Inserção/Alteração ou Deletação
    oModel:GetModel("SRADETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SRADETAIL"):SetNoInsertLine(.T.)
    oModel:GetModel("RHRDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("RHRDETAIL"):SetNoInsertLine(.T.)
    oModel:GetModel("RG1DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("RG1DETAIL"):SetNoInsertLine(.T.)
    oModel:GetModel("SRKDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SRKDETAIL"):SetNoInsertLine(.T.)

    // Calculos
    oModel:AddCalc("CALC_TOTAL","SRADETAIL" ,"RHRDETAIL","RHR_VLRFUN","RHR_VLRFUN_RHR"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Plano S./O."  ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_TOTAL","SRADETAIL" ,"SRKDETAIL","RHR_VLRFUN","RHR_VLRFUN_SRK"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Lançamentos Futuros"  ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)	
    oModel:AddCalc("CALC_TOTAL","SRADETAIL" ,"RG1DETAIL","RHR_VLRFUN","RHR_VLRFUN_RG1"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Lançamentos Fixos"  ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)

    //Descricoes dos modelos de dados
    oModel:GetModel("SRADETAIL"):SetDescription("Cooperados")
    oModel:GetModel("RHRDETAIL"):SetDescription("Plano de Saúde")
    oModel:GetModel("RG1DETAIL"):SetDescription("Lançamentos Fixos")
    oModel:GetModel("SRKDETAIL"):SetDescription("Lançamentos Futuros")
    oModel:GetModel("CABMASTER"):SetDescription("Cabeçalho")
    oModel:SetDescription("Integração GPE x CMV") 
    
    oModel:lModify := .t. 

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
    Local oModel := FWLoadModel("SERGPE03")

    //Criação da estrutura de dados da View
    Local oStSRA := FWFormViewStruct():New()
    Local oStRHR := FWFormViewStruct():New()
    Local oStRG1 := FWFormViewStruct():New()
    Local oStSRK := FWFormViewStruct():New()
    Local oCalcTOT := FWCalcStruct(oModel:GetModel("CALC_TOTAL"))

	//Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()

    StrMVC(2,cAliasTrab  , oStSRA, {{"STATUS"},{"RHR_MAT"},{"RA_NOME"}})
    StrMVC(2,cAliasTrab  , oStRHR, {{"STATUS"},{"RHR_PD"},{"DT7_CODDES"},{'DT7_DESCRI'},{"RV_DESC"},{"RHR_VLRFUN"},{"OBS"}})
    StrMVC(2,cAliasTrab  , oStRG1, {{"STATUS"},{"RHR_PD"},{"DT7_CODDES"},{'DT7_DESCRI'},{"RV_DESC"},{"RHR_VLRFUN"},{"OBS"}})
    StrMVC(2,cAliasTrab  , oStSRK, {{"STATUS"},{"RHR_PD"},{"DT7_CODDES"},{'DT7_DESCRI'},{"RV_DESC"},{"RHR_VLRFUN"},{"OBS"}})


    oStSRA:SetProperty( "STATUS"	, MVC_VIEW_CANCHANGE, .f. )
	oStRHR:SetProperty( "STATUS"	, MVC_VIEW_CANCHANGE, .f. )
	oStRG1:SetProperty( "STATUS"	, MVC_VIEW_CANCHANGE, .f. )
	oStSRK:SetProperty( "STATUS"	, MVC_VIEW_CANCHANGE, .f. )

	oStSRA:SetProperty( "RA_NOME"	, MVC_VIEW_WIDTH, 150 )
	oStRHR:SetProperty( "OBS"		, MVC_VIEW_WIDTH, 150 )
	oStRG1:SetProperty( "OBS"		, MVC_VIEW_WIDTH, 150 )
	oStSRK:SetProperty( "OBS"		, MVC_VIEW_WIDTH, 150 )
	oStSRA:SetProperty( "STATUS"	, MVC_VIEW_PICT, "@BMP" )
	oStRHR:SetProperty( "STATUS"	, MVC_VIEW_PICT, "@BMP" )
	oStRG1:SetProperty( "STATUS"	, MVC_VIEW_PICT, "@BMP" )
	oStSRK:SetProperty( "STATUS"	, MVC_VIEW_PICT, "@BMP" )

	//Seta o modelo
    oView:SetModel(oModel)

    //Atribuindo fomulários para interface
    oView:AddGrid("VIEW_SRA" , oStSRA  , "SRADETAIL")
    oView:AddGrid("VIEW_RHR" , oStRHR  , "RHRDETAIL") 
    oView:AddGrid("VIEW_RG1" , oStRG1  , "RG1DETAIL") 
    oView:AddGrid("VIEW_SRK" , oStSRK  , "SRKDETAIL")

    oView:AddField("VIEW_CALC_TOT"  , oCalcTOT  , "CALC_TOTAL") 

	//Criando os paineis
    oView:CreateHorizontalBox("TOTAL",100)

    oView:CreateVerticalBox( "ESQUERDA", 30, "TOTAL" )
    oView:CreateVerticalBox( "DIREITA" , 70, "TOTAL" )

    oView:CreateHorizontalBox("BOX_RHR",40,"DIREITA")
    oView:CreateHorizontalBox("BOX_SRK",25,"DIREITA")
    oView:CreateHorizontalBox("BOX_RG1",25,"DIREITA")
    oView:CreateHorizontalBox("CAL_TOT",10,"DIREITA")

	//Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SRA","ESQUERDA")
    oView:SetOwnerView("VIEW_RHR","BOX_RHR")
    oView:SetOwnerView("VIEW_RG1","BOX_RG1")
    oView:SetOwnerView("VIEW_SRK","BOX_SRK")

    oView:SetOwnerView("VIEW_CALC_TOT","CAL_TOT")

	//Adicionado Descrições
	oView:EnableTitleView("VIEW_SRA", "Cooperados" )
    oView:EnableTitleView("VIEW_RHR", "Plano de Saúde" )
    oView:EnableTitleView("VIEW_RG1", "Lançamentos Fixos" )
    oView:EnableTitleView("VIEW_SRK", "Lançamentos Futuros" )    

    oView:SetViewProperty("*", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| ExibErro(oFormulario,cFieldName,nLineGrid,nLineModel)}})

    //Remover campos
	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

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

/*/{Protheus.doc} ExibErro
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oFormulario, object, description
@param cFieldName, characters, description
@param nLineGrid, numeric, description
@param nLineModel, numeric, description
@type function
/*/
Static Function ExibErro(oFormulario,cFieldName,nLineGrid,nLineModel)
	
	AVISO("Erro Integracao", oFormulario:GetModel():GetValue("RETORNO"), {}, 3)
		
Return .f.

/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function Commit(oModel)
	
	Local aSaveLines := FWSaveRows()
	Local oModelSRA := oModel:GetModel("SRADETAIL")
	Local oModelRHR := oModel:GetModel("RHRDETAIL")
	Local oModelSRK := oModel:GetModel("SRKDETAIL")
	Local oModelRG1 := oModel:GetModel("RG1DETAIL")
	Local nTotReg 	:= oModelSRA:Length()
	Local oView		:= FwViewActive()
	Local nTotRHR   := 0
	Local nTotRG1	:= 0 
	Local nTotSRK	:= 0
	Local lRet		:= .T.
	Local lValidRHR := .T. 
	Local lValidRG1 := .T.
	Local lValidSRK := .T.
	Local y			:= 0
	Local i			:= 0 
	Local w			:= 0
	Private lErro   := .f.
	
	RHR->(DbSetOrder(1))
	RG1->(DbSetOrder(1))
	
	IF !MSGYESNO( "Deseja realizar a integração?", "Integração - GPE x CMV" )
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE03","Cancelado pelo usuario","") 
		Return .f.
	End If 
	
	BEGIN TRANSACTION
	
	For i:= 1 to nTotReg
		
		// Posiciona no primeiro Fornecedor
		oModelSRA:Goline(i)
	
		lValidRHR := .T. 
		lValidRG1 := .T.
		lValidSRK := .T. 
		
		nTotSRK	  := 0 
		nTotRHR	  := 0 
		nTotSRK	  := 0 
	
		// Verifica se existe plano de saude
		If oModelRHR:IsEmpty()
			lValidRHR := .T. 
		Else
			nTotRHR := oModelRHR:Length()
		End if
		
		For y := 1 to nTotRHR
		
			// Posiciona no Primeiro registro do Plano
			oModelRHR:Goline(y)
			
			// Para aqueles que ja foram integrado, nao roda novamente.
			If Alltrim(oModelRHR:GetValue("STATUS")) == "BR_VERDE"
				Loop
			End If
		
			// Cria as despesa do contrato
			FWMsgRun(, {|| lRet := CriaCMV(oModel,oModelRHR)}, oModelSRA:GetValue("RA_NOME"), "Gerando CMV -  Plano de Saúde " + cvaltochar(y) + "/" + cvaltochar(nTotRHR))
		
			If lRet 
				
				// Posiciona na tabela RHR e informar que foi integrado
				// como na folha e no CMV.
				RHR->(DbGoto(oModelRHR:GetValue("RECNO")))
				
				RecLock("RHR", .F.)		
					RHR->RHR_INTFOL := "1" // Integrado na Folha
					//RHR->RHR_YDTCMV := DDATABASE // Integrado no CMV
				MsUnLock()
			Else
				lValidRHR  := .F. 
			End If 
	
		Next
		
		// Verifica se existe lancamento Fixo
		If oModelRG1:IsEmpty()
			lValidRG1 := .T. 
		Else
			nTotRG1 := oModelRHR:Length()
		End if

		For y := 1 to nTotRG1
		
			// Posiciona no Primeiro registro do lANCAMENTO FIXO
			oModelRG1:Goline(y)
			
			// Para aqueles que ja foram integrado, nao roda novamente.
			If Alltrim(oModelRG1:GetValue("STATUS")) == "BR_VERDE"
				Loop
			End If	
				
			// Cria as despesa do contrato
			FWMsgRun(, {|| lRet := CriaCMV(oModel,oModelRG1) }, oModelSRA:GetValue("RA_NOME"), "Gerando CMV -  Lançamentos Fixos " + cvaltochar(y) + "/" + cvaltochar(nTotRG1))
		
			If lRet
				
				// Posiciona na tabela RG1 e informar que foi integrado no CMV.
				RG1->(DbGoto(oModelRG1:GetValue("RECNO")))
				
				RecLock("RG1", .F.)		
					RG1->RG1_YDTCMV := DDATABASE // Informa a data da integracao
				MsUnLock()
			Else
				lValidRG1 := .F.
			End If

		Next

		// Verifica se existe lancamentos futuros
		If oModelSRK:IsEmpty()
			lValidSRK := .T. 
		else
			nTotSRK := oModelSRK:Length()
		End if

		For w := 1 to nTotSRK
		
			// Posiciona no Primeiro registro do lANCAMENTO FUTUROS
			oModelSRK:Goline(w)
		
			// Para aqueles que ja foram integrado, nao roda novamente.
			If Alltrim(oModelSRK:GetValue("STATUS")) == "BR_VERDE"
				Loop
			End If			
		
			// Cria as despesa do contrato
			FWMsgRun(, {|| lRet := CriaCMV(oModel,oModelSRK) }, oModelSRA:GetValue("RA_NOME"), "Gerando CMV -  Lançamentos Futuros " + cvaltochar(w) + "/" + cvaltochar(nTotSRK))
		
			If lRet
				// Posiciona na tabela RG1 e informar que foi integrado no CMV.
				SRK->(DbGoto(oModelSRK:GetValue("RECNO")))
				
				RecLock("SRK", .F.)	
					
					// Soma uma parcela
					SRK->RK_PARCPAG := SRK->RK_PARCPAG + 1					
					
					// Verifica se foi a ultima parcela
					If SRK->RK_PARCPAG == SRK->RK_PARCELA
						SRK->RK_STATUS := '3' //Pago
					Else	
					// Muda o vencimento para o proximo mes
						SRK->RK_DTVENC  := 	MonthSum(SRK->RK_DTVENC,1) 
					End If
					
				MsUnLock()
				
			Else
				lValidSRK := .F.
			End If
		Next	


		// Atualiza o status da integracao 
		// AMARELO - Integrado parcial
		// VERDE - Integrado total
		// VERMELHO - Nao integrado
		
		if nTotRHR > 0 		
			If lValidRHR
				oModelSRA:LoadValue("STATUS","BR_VERDE")
			Else
				oModelSRA:LoadValue("STATUS","BR_VERMELHO")
			End if
		Else
			oModelSRA:LoadValue("STATUS","BR_VERDE")
		End if 
		
		If nTotRG1 > 0 
			If lValidRG1
				If Alltrim(oModelSRA:GetValue("STATUS")) == "BR_VERMELHO"
					oModelSRA:LoadValue("STATUS","BR_AZUL")
				End If	

			Else
			 	If Alltrim(oModelSRA:GetValue("STATUS")) == "BR_VERDE"
			 		oModelSRA:LoadValue("STATUS","BR_AZUL")
			 	End if
			End iF 
		End iF
		
		If nTotSRK > 0 
			If lValidSRK
				If Alltrim(oModelSRA:GetValue("STATUS")) == "BR_VERMELHO"
					oModelSRA:LoadValue("STATUS","BR_AZUL")
				End If	
			Else
				If Alltrim(oModelSRA:GetValue("STATUS")) == "BR_VERDE"
			 		oModelSRA:LoadValue("STATUS","BR_AZUL")
			 	End if
			End iF 
		End iF	
		

	Next

	END TRANSACTION 
	
	FWRestRows( aSaveLines )

	If lErro
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE03","Existem registros nao integrados.","Favor verificar nas legendas vermelhas e tentar novamente.") 
	End IF 

	oView:Refresh()

Return !lErro

/*/{Protheus.doc} CriaCMV
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param oModelActv, object, description
@type function
/*/
Static Function CriaCMV(oModel,oModelActv)

	Local oModelCMV := Nil
	Local oModelSZ1 := Nil
	Local lValid	:= .T.
	Local cErro     := ""
	Local lRet 		:= .T. 
	

	oModelCMV := FWLoadModel("SERGPE01")
	oModelCMV:SetOperation( MODEL_OPERATION_INSERT )
	oModelCMV:Activate()
	
	// Cadastro da Despesa
	oModelSZ1 := oModelCMV:GetModel("SZ1MASTER")
	
	If lValid
		lValid := oModelSZ1:SetValue("Z1_EMISSAO", DDATABASE )
	End If 	
	
	If lValid
		lValid := oModelSZ1:SetValue("Z1_VENCTO", DDATABASE )
	End If 		
	
	If lValid
		lValid := oModelSZ1:SetValue("Z1_FORNECE", oModelActv:GetValue("A2_COD") )
	End If 		

	If lValid
		lValid := oModelSZ1:SetValue("Z1_LOJA", "01" )
	End If 

	If lValid
		lValid := oModelSZ1:SetValue("Z1_VALOR",oModelActv:GetValue("RHR_VLRFUN"))
	End If 

	If lValid
		lValid := oModelSZ1:SetValue("Z1_CODDESP", oModelActv:GetValue("DT7_CODDES") )
	End If 

	If lValid
		lValid := oModelSZ1:SetValue("Z1_HISTORI", oModelActv:GetValue("OBS") )
	End If 	
	
	
	// Verifica se o modelo ficou com algum erro após atribuição dos valores
	If oModelCMV:HasErrorMessage() .and. !lValid
		// Recupera o erro do modelo da Despesa
		cErro := GetErroModel(oModelCMV,oModelActv)
		Return .f.
	End If 	
	
	If oModelCMV:VldData()

		If oModelCMV:CommitData()
	
		Else
			// Recupera o erro do modelo da Despesa
			cErro := GetErroModel(oModelCMV,oModelActv)
			Return .f. 
		End if 

	Else 
		// Recupera o erro do modelo da Despesa
		cErro := GetErroModel(oModelCMV,oModelActv)
		Return .f. 
	End if 	
	
	// Informa que este registro foi com sucesso
	oModelActv:LoadValue("STATUS","BR_VERDE") 
	oModelActv:LoadValue("RETORNO","Integrado com sucesso")
	
Return lRet

/*/{Protheus.doc} LoadSRA
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadSRA(oGridModel, lCopy,oModel)

    Local aLoad     := {}
    Local aNewLoad  := {}
    Local i       := 0 
	Local oStr    := oGridModel:GetStruct()
	Local nPosMat := oStr:GetArrayPos({"RHR_MAT"})[1]
	Local nPos 	  := 0     
 
    aLoad := FwLoadByAlias( oGridModel,cAliasTrab, NIL , Nil , Nil , .t. ) 

	For i:= 1 to len(aLoad)
		
		nPos := ASCAN(aNewLoad, { |x| Alltrim(x[2][nPosMat]) == Alltrim(aLoad[i][2][nPosMat]) }) 
		
		If nPos == 0
			AADD(aNewLoad,aLoad[i])
		End If 
	
	Next

Return aNewLoad


/*/{Protheus.doc} LoadRHR
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadRHR(oGridModel, lCopy,oModel)

    Local aLoad := {}
    Local cMatr  := oModel:GetModel("SRADETAIL"):GetValue("RHR_MAT")
 
    (cAliasTrab)->(DBClearFilter())
    (cAliasTrab)->(DBGoTop())

    (cAliasTrab)->(DbSetFilter({|| Alltrim(TABELA) == "RHR" .and. Alltrim(RHR_MAT) == cMatr }, "ALLTRIM(TABELA) == 'RHR' .AND. ALLTRIM(RHR_MAT) == '" + cMatr + "'"))

    aLoad := FwLoadByAlias( oGridModel,cAliasTrab, NIL , Nil , Nil , .t. ) 

    (cAliasTrab)->(DBClearFilter())

Return aLoad


/*/{Protheus.doc} LoadSRK
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadSRK(oGridModel, lCopy,oModel)

    Local aLoad := {}
    Local cMatr  := oModel:GetModel("SRADETAIL"):GetValue("RHR_MAT")
 
    (cAliasTrab)->(DBClearFilter())
    (cAliasTrab)->(DBGoTop())

    (cAliasTrab)->(DbSetFilter({|| Alltrim(TABELA) == "SRK" .and. Alltrim(RHR_MAT) == cMatr }, "ALLTRIM(TABELA) == 'SRK' .AND. ALLTRIM(RHR_MAT) == '" + cMatr + "'"))

    aLoad := FwLoadByAlias( oGridModel,cAliasTrab, NIL , Nil , Nil , .t. ) 

    (cAliasTrab)->(DBClearFilter())

Return aLoad

/*/{Protheus.doc} LoadRG1
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadRG1(oGridModel, lCopy,oModel)

    Local aLoad := {}
    Local cMatr  := oModel:GetModel("SRADETAIL"):GetValue("RHR_MAT")
 
    (cAliasTrab)->(DBClearFilter())
    (cAliasTrab)->(DBGoTop())

    (cAliasTrab)->(DbSetFilter({|| Alltrim(TABELA) == "RG1" .and. Alltrim(RHR_MAT) == cMatr }, "ALLTRIM(TABELA) == 'RG1' .AND. ALLTRIM(RHR_MAT) == '" + cMatr + "'"))

    aLoad := FwLoadByAlias( oGridModel,cAliasTrab, NIL , Nil , Nil , .t. ) 

    (cAliasTrab)->(DBClearFilter())

Return aLoad


/*/{Protheus.doc} AreaTrab
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param lDados, logical, description
@type function
/*/
Static Function AreaTrab(lDados)

    Local cFilter  := ""
    Default lDados := .T. 

    If select (cAliasTrab) > 0 
        (cAliasTrab)->(DbCloseArea())
    End If

    // Verifica se retornas os dados ou nao
    // utilizado para criar a estrutura do MVC
    if lDados
        cFilter := "% 1 = 1 %"
    Else 
        cFilter := "% 1 <> 1 %
    End if

    BeginSql Alias cAliasTrab

    SELECT 
    	'BR_BRANCO' AS STATUS
        ,A.TABELA
        ,A.INDICE
        ,A.RECNO
        ,A.RHR_FILIAL
        ,SA2.A2_COD
        ,A.RHR_MAT
        ,SRA.RA_NOME
        ,DT7.DT7_CODDES
        ,A.RHR_PD
        ,SRV.RV_DESC
        ,A.RHR_VLRFUN
        ,RTRIM(LTRIM(A.OBS)) AS OBS
        ,'' AS RETORNO

    FROM ( SELECT
            'RHR' AS TABELA
            , RHR_FILIAL + RHR_MAT + RHR_COMPPG + RHR_ORIGEM + RHR_CODIGO +  RHR_TPLAN + RHR_TPFORN + RHR_CODFOR +  RHR_TPPLAN +  RHR_PLANO +  RHR_PD AS INDICE
            , RHR.R_E_C_N_O_ AS RECNO 
            ,RHR.RHR_FILIAL
            ,RHR.RHR_MAT
            ,RHR.RHR_PD
            ,RHR.RHR_VLRFUN
			,SUBSTRING(CONVERT(varchar, CONVERT(datetime, RHR_COMPPG + '01'), 103),4,10)  + ' - ' + CASE RHR.RHR_ORIGEM 
			WHEN '1' THEN 'PROPRIO TITULAR'  
			
			WHEN '2' THEN (SELECT SRB.RB_NOME FROM %Table:SRB% SRB 
						   WHERE SRB.RB_FILIAL =%Exp:xFilial("SRB")%
						   AND SRB.RB_MAT = RHR.RHR_MAT 
						   AND SRB.RB_COD = RHR.RHR_CODIGO 
						   AND SRB.D_E_L_E_T_ ='')
						   
			WHEN '3' THEN (SELECT RHM.RHM_NOME FROM %Table:RHM% RHM 
							WHERE RHM_FILIAL =%Exp:xFilial("RHM")%
							AND RHM.RHM_MAT    = RHR.RHR_MAT 
							AND RHM.RHM_CODIGO = RHR.RHR_CODIGO 
							AND RHM.RHM_TPPLAN = RHR.RHR_TPPLAN 
							AND RHR.RHR_TPFORN = RHM.RHM_TPFORN 
							AND RHR.RHR_PLANO  = RHM.RHM_PLANO 
							AND RHR.RHR_CODFOR = RHM.RHM_CODFOR 
							AND RHR.RHR_TPFORN = RHM.RHM_TPFORN 
							AND RHM.D_E_L_E_T_ ='' )
			END AS 'OBS'           
			 
            FROM %Table:RHR%  RHR

            WHERE RHR.D_E_L_E_T_ =''
            AND RHR.RHR_VLRFUN > 0
            AND RHR.RHR_INTFOL <> '1' 
            AND RHR.RHR_FILIAL = %xFilial:RHR%

            UNION ALL

            SELECT 
            'SRK' AS TABELA
            , RK_FILIAL + RK_MAT + RK_PD + RK_CC + RK_PROCES AS INDICE
            , SRK.R_E_C_N_O_ AS RECNO 
            ,SRK.RK_FILIAL
            ,SRK.RK_MAT
            ,SRK.RK_PD
            ,SRK.RK_VALORPA
            , '' AS OBS

            FROM %Table:SRK%  SRK 

            WHERE SRK.D_E_L_E_T_ =''
            AND SRK.RK_FILIAL = %xFilial:SRK%
            AND SRK.RK_STATUS = '2'
            AND SRK.RK_PARCPAG < SRK.RK_PARCELA
            AND SRK.RK_DTVENC <= %Exp:dDataBase%    

            UNION ALL

            SELECT 
            'RG1' AS TABELA
            , RG1_FILIAL + RG1_MAT + RG1_ORDEM + RG1_PD + RG1_DINIPG AS INDICE
            , RG1.R_E_C_N_O_ AS RECNO 
            , RG1.RG1_FILIAL
            , RG1.RG1_MAT
            , RG1.RG1_PD
            , RG1.RG1_VALOR
            , '' AS OBS
            FROM %Table:RG1%  RG1

            WHERE(RG1.RG1_DFIMPG = '' OR RG1.RG1_DFIMPG >= %Exp:dDataBase%)
            AND RG1.D_E_L_E_T_ =''
            AND RG1.RG1_FILIAL = %xFilial:RG1%
            AND RG1.RG1_YDTCMV < %Exp:AnoMes(dDataBase)% )A
        
            JOIN %Table:SRV%  SRV ON SRV.RV_FILIAL = %xFilial:SRV%
            AND SRV.RV_COD = A.RHR_PD
            AND SRV.RV_TIPOCOD ='2' // DESCONTOS
            AND SRV.D_E_L_E_T_ =''

            JOIN %Table:SRA% SRA ON SRA.RA_FILIAL =%xFilial:SRA%
            AND SRA.RA_MAT = A.RHR_MAT
            AND SRA.D_E_L_E_T_ =''

            JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SRA.RA_YFORN
			AND SA2.D_E_L_E_T_ =''

            LEFT JOIN %Table:DT7% DT7 ON DT7.DT7_FILIAL =%xFilial:DT7%
            AND DT7.DT7_YVERBA = SRV.RV_COD 
            AND DT7.D_E_L_E_T_ =''
           
            WHERE  %Exp:cFilter%

    EndSql

Return 



/*/{Protheus.doc} StrMVC
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, description
@param cAlias, characters, description
@param oStr, object, description
@param aCampos, array, description
@type function
/*/
Static Function StrMVC(nTipo,cAlias,oStr,aCampos)

    // Recupera a estrutra da query
    Local aStru := (cAlias)->(dbStruct())
    Local i		:= 0
    Default aCampos := aStru

    // Cria estrutura do modelo de dados e da view
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))

    For i:= 1 to Len(aStru)
        
        // Verifica os campos para aparecer.
        If Ascan(aCampos,{|x| Alltrim(x[1]) == Alltrim(aStru[i][1]) }) == 0 
            Loop
        End if


        if nTipo == 1 

            If DbSeek(aStru[i][1])

                oStr:AddField(;
                    SX3->X3_TITULO,;                                                        // [01]  C   Titulo do campo
                    SX3->X3_DESCRIC,;                                                       // [02]  C   ToolTip do campo
                    Alltrim(SX3->X3_CAMPO),;                                                // [03]  C   Id do Field
                    SX3->X3_TIPO,;                                                          // [04]  C   Tipo do campo
                    SX3->X3_TAMANHO,;                                                       // [05]  N   Tamanho do campo
                    SX3->X3_DECIMAL,;                                                       // [06]  N   Decimal do campo
                    FwBuildFeature( STRUCT_FEATURE_VALID, ".T." ),;                         // [07]  B   Code-block de validação do campo
                    FwBuildFeature( STRUCT_FEATURE_WHEN, ".T." ),;                          // [08]  B   Code-block de validação When do campo
                    {},;                                                                    // [09]  A   Lista de valores permitido do campo
                    .F.,;                                                                   // [10]  L   Indica se o campo tem preenchimento obrigatório
                    FwBuildFeature( STRUCT_FEATURE_INIPAD, "" ),;                           // [11]  B   Code-block de inicializacao do campo
                    ,; 																		// [12] 
                    ,; 																		// [13] 
                    .F.)                                                                    // [14]  L   Indica se o campo é virtual
            
            Else

                oStr:AddField(aStru[i][1] ,;												// [01] Titulo do campo 		"Descrição"
                    aStru[i][1],;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
                    aStru[i][1],;															// [03] Id do Field
                    aStru[i][2]	,;															// [04] Tipo do campo
                    aStru[i][3],;															 // [05] Tamanho do campo
                    aStru[i][4],;																		// [06] Decimal do campo
                    FwBuildFeature( STRUCT_FEATURE_VALID, ".F." ),;                         // [07]  B   Code-block de validação do campo
                    FwBuildFeature( STRUCT_FEATURE_WHEN, ".F." ),;                          // [08]  B   Code-block de validação When do campo
                    ,;																		// [09] Lista de valores permitido do campo
                    .F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
                    FwBuildFeature( STRUCT_FEATURE_INIPAD, "" ),;                           // [11]  B   Code-block de inicializacao do campo
                    ,; 																		// [12] 
                    ,; 																		// [13] 
                    .T.	) 																	// [14] Virtual    
            End If

        Else

            If DbSeek(aStru[i][1])
                oStr:AddField(;
                    Alltrim(SX3->X3_CAMPO),;                                                // [01]  C   Nome do Campo
                    PADL(cvaltochar(i),2,"0"),;                                             // [02]  C   Ordem
                    SX3->X3_TITULO,;                                                        // [03]  C   Titulo do campo
                    SX3->X3_DESCRIC,;                                                       // [04]  C   Descricao do campo
                    Nil,;                                                                   // [05]  A   Array com Help
                    SX3->X3_TIPO,;                                                          // [06]  C   Tipo do campo
                    SX3->X3_PICTURE,;                                                       // [07]  C   Picture
                    Nil,;                                                                   // [08]  B   Bloco de PictTre Var
                    SX3->X3_F3,;                                                            // [09]  C   Consulta F3
                    .t.,;                                                        			// [10]  L   Indica se o campo é alteravel
                    SX3->X3_FOLDER,;                                                        // [11]  C   Pasta do campo
                    SX3->X3_GRPSXG,;                                                        // [12]  C   Agrupamento do campo
                    Nil,;                                                         // [13]  A   Lista de valores permitido do campo (Combo)
                    Nil,;                                                                   // [14]  N   Tamanho maximo da maior opção do combo
                    SX3->X3_INIBRW,;                                                        // [15]  C   Inicializador de Browse
                    NIL,;                                                        			// [16]  L   Indica se o campo é virtual
                    Nil,;                                                                   // [17]  C   Picture Variavel
                    Nil)                                                                    // [18]  L   Indica pulo de linha após o campo

            Else
                
                oStr:AddField(	aStru[i][1],; //Id do Campo
                        PADL(cvaltochar(i),2,"0"),; //Ordem
                        aStru[i][1],;// Título do Campo
                        aStru[i][1],; //Descrição do Campo
                        {},; //aHelp
                        aStru[i][2],; //Tipo do Campo	
                        "")//cPicture
            End If
        End If    
    Next
    
    
 
Return  oStr


/*/{Protheus.doc} GetErroModel
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param oModelActv, object, description
@type function
/*/
Static Function GetErroModel(oModel,oModelActv)

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
	
	// Muda o status para de nao integrado
	oModelActv:LoadValue("STATUS","BR_VERMELHO")
	
	oModelActv:LoadValue("RETORNO",Substr(cMessage,1,1000))
	
	lErro := .T.

Return  cMessage