#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} SERTMS07
Modelo de dados para importacao dos eventos de cancelamento
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS07()

	Local aArea   := GetArea()
	Local oBrowse := Nil

	Private aRotina := MenuDef()

	//Instânciando FWMBrowse 
	oBrowse := FWMBrowse():New()

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERTMS07")

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZM")

	//Setando a descrição da rotina
	oBrowse:SetDescription("Eventos Importados")

	// Adiciona legenda
	oBrowse:AddLegend("!Empty(ZM_DTTMS)" 					  , "BR_VERMELHO"  , "Integrado")
	oBrowse:AddLegend("Empty(ZM_DTTMS) .AND. !EMPTY(ZM_LOG)"  , "BR_AMARELO"   , "Nao Integrado")
	oBrowse:AddLegend("Empty(ZM_DTTMS) .AND. EMPTY(ZM_LOG)"   , "BR_VERDE"	   , "Disponivel")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)	

return


/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()

	Local aRot := {}

	//Adicionando opções
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERTMS07"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERTMS07"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERTMS07"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERTMS07"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERTMS07"	,0,5,0,NIL})
	aAdd(aRot,{"Canc. TMS" 	,"U_TMS07IMP()"	,0,4,0,NIL})


Return aRot


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel  := Nil
	Local bCommit := {|oModel| Commit(oModel)} 
	Local bPos     := {|oModel| TudoOK(oModel)} 

	// Criação da estrutura de dados utilizada na interface
	Local oStSZM   := FWFormStruct(1, "SZM")

	// Cria o modelo
	oModel := MPFormModel():New("MSERTMS07",/*bPre*/, bPos/*bPos*/,bCommit /*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("SZMMASTER",/*cOwner*/, oStSZM)

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)

	//Adicionando descrição ao modelo
	oModel:SetDescription("Eventos Importados")

	//Descricoes dos modelos de dados
	oModel:GetModel("SZMMASTER"):SetDescription("Eventos de Frete")

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey( {"ZK_FILIAL","ZK_CHVCTE"} )

	//Verifica se realiza ativição do Modelo
	oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )

Return oModel


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	// Recupera o modelo de dados
	Local oModel := FWLoadModel("SERTMS07")

	//Criação da estrutura de dados da View
	Local oStSZM := FWFormStruct(2, "SZM")
	Local oView  := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Atribuindo fomulários para interface
	oView:AddField("VIEW_SZM"    , oStSZM   , "SZMMASTER")

	//Criando os paineis
	oView:CreateHorizontalBox("SUPERIOR",100)

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOK({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZM","SUPERIOR")

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

Return oView


/*/{Protheus.doc} ValidActv
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function ValidActv(oModel)

	Local lRet := .t.
	Local cMsg := ""
	Local cSolu:= ""
	Local nOper:= oModel:GetOperation()

	If nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_VIEW
		Return .t.
	End If

	// Verifica se ja foi integrado no ERP.
	If !Empty(SZM->ZM_DTTMS)
		cMsg  := "Este evento já foi integrado no ERP e não será permitido realizar a Alteração\Exclusão."
		cSolu := "Favor selecionar outro registro"
		Help(NIL, NIL, "SERTMS07 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

Return lRet


/*/{Protheus.doc} TudoOK
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function TudoOK(oModel)

	Local lRet		:= .t.
	Local oModelSZM := oModel:GetModel("SZMMASTER")
	Local nOperacao := oModel:GetOperation()

	If nOperacao == MODEL_OPERATION_DELETE
		lRet := .t.
		Return lRet
	End If

	// Verifica se a empresa logada possui o CNPJ do emitente informado
	If FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2] != oModelSZM:GetValue("ZM_CGC")
		oModel:SetErrorMessage("",,oModel:GetId(),"","TudoOK","A Inclusao deste evento somente pode ser na empresa emissora","Favor alterar o CNPJ do emitente.") 
		Return .f.
	End If

	SZM->(DbSetOrder(2))
	If SZM->(DbSeek(xFilial("SZM") + oModelSZM:GetValue("ZM_ID")))
		oModel:SetErrorMessage("",,oModel:GetId(),"","TudoOK","Este evento ja foi importado anteriormente.","") 
		Return .f.
	End If

Return lRet


/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function Commit(oModel)

	Local nBckpModulo := nModulo
	Local lRet		  := .T.
	Local aErro		  := {}
	Local nOp		  := oModel:GetOperation()

	//TMS
	nModulo := 43 

	If lRet
		// Realiza o commit do modelo da tela
		//FWMsgRun(, {|| lRet := FWFormCommit( oModel ) }	, "Processando", "SERTMS07 - Gravando Cancelamento...")
		lRet := FWFormCommit( oModel )
	End If

	If lRet .and. nOp == MODEL_OPERATION_INSERT
		// Realiza a integracao no SIGATMS
		//FWMsgRun(, {|| aErro := U_TMS07IMP() }		, "Processando", "SERTMS07 - Gerando movimentações no SIGATMS")
		aErro := U_TMS07IMP()
	End if 	

	nModulo := nBckpModulo

Return lRet


/*/{Protheus.doc} TMS07IMP
Cancelamento do CTE e suas movimentacoes no ERP.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TMS07IMP()

	Local cCte		:= ""
	Local cSerie	:= ""
	Local lRet		:= .t. 

	Private aErrMsg := {}

	Private lMsErroAuto := .f.

	// Verifica se a integracao sera realizada na empresa correta
	If Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2]) != Alltrim(SZM->ZM_CGC)
		AAdd(aErrMsg,"A integração deste CANCELAMENTO só é permitida na empresa emitente.") 
		lRet := .f.
	End If

	If lRet
		cCte   := substr(SZM->ZM_CHVCTE,26,9)
		cSerie := cValToChar(Val(substr(SZM->ZM_CHVCTE,23,3)))

		BEGIN TRANSACTION

			SF2->(DbSetOrder(1))
			If SF2->(DbSeek(xFilial("SF2") + cCte + cSerie))

				// Realiza tentativa de exclusao do Transporte.
				If lRet
					lRet := DelSIGATMS()
				End If

				// Realiza tentativa de exlusao do Financeiro. (Contas a Receber)
				If lRet 
					lRet := DelSIGAFIN()
				End if

				// Realiza a atualizacao das informacoes de cancelamento no Fiscal.
				If lRet
					lRet := AtuSIGAFIS()
				End If

				// Realiza tentativa de exlusao do Faturamento/Impostos.
				If lRet 
					lRet := DelSIGAFAT()
				End if	

				// Caso encontre algum erro
				If lRet
					Reclock("SZM",.F.)
					SZM->ZM_LOG	  := ""
					SZM->ZM_DTTMS := DDATABASE
					MsUnLock()
					
					// Reprocessa Cte com a mesma nota fiscal.
					lRet := TMS07SZL()
				Else
					DisarmTransaction()				
				End If		
			Else
				AAdd(aErrMsg,"Não foi possivel encontrar o Ct-e (" + cCte +"/" + cSerie + ") integrado no ERP.") 
			End If

		END TRANSACTION 
	End If

	If Len(aErrMsg) > 0 
		Reclock("SZM",.F.)
		SZM->ZM_LOG := aErrMsg[1]
		MsUnLock()
	End If

Return aErrMsg

/*/{Protheus.doc} TMS07SZL
Verifica se existe outro conhecimento de Frete que ainda nao foi importado
utilizando a mesma nota fiscal do cliente para solicitar o reprocessamento.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMS07SZL()

	Local cAliasCTE := GetNextAlias()
	Local lRet		:= .t.
	Local aArea		:= GetArea()
	Local aAreaSZL  := SZL->(GetArea())
	Local aAreaSZK  := SZK->(GetArea())
	Local aAreaSZM  := SZM->(GetArea())
	Local aAreaSZN  := SZN->(GetArea())
	Local aAreaSZO  := SZO->(GetArea())
	Local aAreaSZP  := SZP->(GetArea())

	SZL->(DbSetOrder(1))
	
	// Localiza a nota fiscal deste conhecimento
	If SZL->(DbSeek(xFilial("SZL") + SZM->ZM_CHVCTE))
		
		// Localiza quais saos os ctes que possuem a mesma nota fiscal
		BeginSQL Alias cAliasCTE

			SELECT * FROM %Table:SZL% SZL
			
			JOIN %Table:SZK% SZK ON SZK.ZK_FILIAL = %Exp:xFilial("SZK")% 
			AND SZK.ZK_CHAVE = SZL.ZL_CHVCTE	
			AND SZK.D_E_L_E_T_ ='' 
			
			WHERE SZL.ZL_FILIAL = %Exp:xFilial("SZL")% 
			AND SZL.ZL_CHVNFE = %Exp:SZL->ZL_CHVNFE%
			AND SZL.D_E_L_E_T_ =''
			AND SZK.ZK_DTTMS = ''
			ORDER BY SZK.ZK_DOC 
		EndSQL
		
		While (cAliasCTE)->(!EOF())
			
			SZK->(DbSetOrder(2))
			// Posicione no Cte importado e solicita o reprocesso.
			If SZK->(DBSeek((cAliasCTE)->ZL_CHVCTE))
				U_TMS06IMP()
			End If
		
			(cAliasCTE)->(DbSkip())
		EndDo
		
		(cAliasCTE)->(DbCloseArea())
	End If
	
	RestArea(aArea)
	RestArea(aAreaSZK)
	RestArea(aAreaSZL)
	RestArea(aAreaSZM)
	RestArea(aAreaSZN)
	RestArea(aAreaSZO)
	RestArea(aAreaSZP)
	
Return lRet

/*/{Protheus.doc} DelSIGAFAT
Estorno das movimentacoes do Faturamento
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function DelSIGAFAT()

	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local aLinha 	:= {}
	Local lRet	 	:= .t.
	Local cErroInt 	:= ""
	Private lMsErroAuto := .f.
	aadd(aCabec,{"F2_TIPO"   	,SF2->F2_TIPO})
	aadd(aCabec,{"F2_FORMUL" 	,SF2->F2_FORMUL})
	aadd(aCabec,{"F2_DOC"    	,SF2->F2_DOC})
	aadd(aCabec,{"F2_SERIE"  	,SF2->F2_SERIE})
	aadd(aCabec,{"F2_EMISSAO"	,SF2->F2_EMISSAO})
	aadd(aCabec,{"F2_CLIENTE"	,SF2->F2_CLIENTE})
	aadd(aCabec,{"F2_LOJA"   	,SF2->F2_LOJA})
	aadd(aCabec,{"F2_ESPECIE"	,SF2->F2_ESPECIE})
	aadd(aCabec,{"F2_DESCONT"	,SF2->F2_DESCONT})
	aadd(aCabec,{"F2_FRETE"		,SF2->F2_FRETE})
	aadd(aCabec,{"F2_SEGURO"	,SF2->F2_SEGURO})
	aadd(aCabec,{"F2_DESPESA"	,SF2->F2_DESPESA})

	SD2->(DbSetOrder(3))
	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM   
	If SD2->(DbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))

		While SD2->(!EOF()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
			aLinha := {}
			aadd(aLinha,{"D2_ITEM"	,SD2->D2_ITEM	,Nil})
			aadd(aLinha,{"D2_COD"	,SD2->D2_COD	,Nil})
			aadd(aLinha,{"D2_QUANT"	,SD2->D2_QUANT	,Nil})
			aadd(aLinha,{"D2_PRCVEN",SD2->D2_PRCVEN	,Nil})
			aadd(aLinha,{"D2_TOTAL"	,SD2->D2_TOTAL	,Nil})
			aadd(aItens,aLinha)

			// Altero para o MATA920 conseguir excluir a nota fiscal
			// se nao ele apresenta o Help que essa nota nao foi realizada
			// via livros fiscais.
			Reclock("SD2",.f.)
			SD2->D2_ORIGLAN := "LF"
			MsUnLock()

			SD2->(DbSkip())
		EndDo

		// MATA920 REALIZA:
		// EXCLUSAO DO SF2, SD2, CD2 
		MATA920(aCabec,aItens,5)

		If lMsErroAuto
			// Pega o retorno do exeauto
			cErroInt := MemoRead(NomeAutoLog())
			// Apaga o arquivo
			FErase(NomeAutoLog())
			AAdd(aErrMsg,cErroInt)	
			Return .f.
		EndIf

	End If	

Return lRet


/*/{Protheus.doc} DelSIGAFIN
Estornar o Contas a Receber gerado pelo CTE
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function DelSIGAFIN()

	Local aVetor	:= {}
	Local cErroInt	:= ""
	Local lRet		:= .t.

	Private lMsErroAuto := .f.

	SE1->(DbSetOrder(2))
	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(DbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC)))

		While SE1->(!EOF()) .and. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC)

			aVetor := { {"E1_PREFIXO" 	,SE1->E1_PREFIXO		,Nil},;
			{"E1_NUM" 		,SE1->E1_NUM 			,Nil},;
			{"E1_PARCELA" 	,SE1->E1_PARCELA		,Nil},;
			{"E1_TIPO" 		,SE1->E1_TIPO 			,Nil},;
			{"E1_FILIAL" 	,SE1->E1_FILIAL 		,Nil},;
			{"E1_NATUREZ" 	,SE1->E1_NATUREZ		,Nil},;
			{"E1_CLIENTE" 	,SE1->E1_CLIENTE		,Nil},;
			{"E1_LOJA" 		,SE1->E1_LOJA 			,Nil},;
			{"E1_EMISSAO" 	,SE1->E1_EMISSAO		,Nil},;
			{"E1_VENCTO" 	,SE1->E1_VENCTO 		,Nil},;
			{"E1_VENCREA" 	,SE1->E1_VENCREA		,Nil},;
			{"E1_VALOR" 	,SE1->E1_VALOR 			,Nil }}

			MSExecAuto({|x, y| FINA040(x, y)}, aVetor, 5)

			If lMsErroAuto
				// Pega o retorno do exeauto
				cErroInt := MemoRead(NomeAutoLog())
				// Apaga o arquivo
				FErase(NomeAutoLog())
				AAdd(aErrMsg,cErroInt)	
				Return .f.
			End If

			SE1->(DbSkip())
		EndDo					

	End If

Return lRet

/*/{Protheus.doc} DelSIGATMS
Estorno das movimentacoes no TMS
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function DelSIGATMS()

	Local lRet := .t.

	DT6->(DbSetOrder(1))
	//DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE

	If DT6->(DbSeek(xFilial("DT6") + cFilAnt + SF2->(F2_DOC + F2_SERIE)))

		If lRet
			// Verifica se o CTE se encontra dentro de um contrato de carreteiro
			// Informa ao usuario que o cancelamento nao ira ocorrer.
			// Sendo assim, o mesmo tem que estornar o contrato de carreteiro, visto que, 
			// esta pagando um contrato com um CTE cancelado e retirando um CTE implica nos impostos
			// calculado para o fornecedor INSS/IRRF/SEST/SENAT.
			lRet := TMSContrat()
		End if

		If lRet
			// Documento do Cliente
			TMSEstDTC()
			// Lote
			TMSEstDTP()
			// Componentes de Frete
			TMSEstDT8()
			// Por ultimo, exclui o CT-e
			TMSEstDT6()
		End If
	End If

Return lRet


/*/{Protheus.doc} TMSEstDT6
Estorno do CTE no TMS
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMSEstDT6()

	While DT6->(!EOF()) .AND. DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE) == xFilial("DT6") + cFilAnt + SF2->(F2_DOC + F2_SERIE)
		RecLock("DT6",.F.)
		DT6->(DbDelete())
		DT6->(MsUnlock())
		DT6->(DBSkip())
	EndDo

Return

/*/{Protheus.doc} TMSEstDT8
Estorno dos componentes de Frete do TMS
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMSEstDT8()

	DT8->(DbSetOrder(2))
	//DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
	If DT8->(DbSeek(xFilial("DT8") + DT6->(DT6_FILORI + DT6_DOC + DT6_SERIE)))

		While DT8->(!EOF()) .AND. DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == xFilial("DT8") + DT6->(DT6_FILORI + DT6_DOC + DT6_SERIE)
			RecLock("DT8",.F.)
			DT8->(DbDelete())
			DT8->(MsUnlock())
			DT8->(DBSkip())
		EndDo
	End If
Return


/*/{Protheus.doc} TMSEstDTC
Estorno do documento do cliente que gerou o CTE
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMSEstDTC()

	DTC->(DbSetOrder(3))
	//DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
	If DTC->(DbSeek(xFilial("DTC") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))

		While DTC->(!EOF()) .AND. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == xFilial("DTC") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)
			RecLock("DTC",.F.)
			DTC->(DbDelete())
			DTC->(MsUnlock())
			DTC->(DBSkip())
		EndDo
	End If
Return


/*/{Protheus.doc} TMSEstDTP
Estorno do Lote do CTE
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMSEstDTP()

	DTP->(DbSetOrder(2))
	//DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If DTP->(DbSeek(xFilial("DTP") + DT6->(DT6_FILORI + DT6_LOTNFC)))

		While DTP->(!EOF()) .AND. DTP->(DTP_FILIAL+DTP_FILORI+DTP_LOTNFC) == xFilial("DTP") + DT6->(DT6_FILORI + DT6_LOTNFC)
			RecLock("DTP",.F.)
			DTP->(DbDelete())
			DTP->(MsUnlock())
			DTP->(DBSkip())
		EndDo
	End If
Return


/*/{Protheus.doc} TMSContrat
Verificao se existe contrato de carreteiro gerado com esse CTE
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMSContrat()

	Local lRet 		:= .t.
	Local cErroInt 	:= ""

	DTA->(DbSetOrder(1))
	DTY->(DbSetOrder(2))

	// Verifica se existe carregamento
	If DTA->(DbSeek(xFilial("DTA") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))

		// Verifica se existe um contrato de carreteiro
		If DTY->(DbSeek(xFilial("DTY") + DTA->(DTA_FILORI + DTA_VIAGEM)))

			cErroInt := "Este CT-e se encontra ja com contrato de carreteiro gerado: " + DTY->DTY_NUMCTC + " para viagem: " + DTA->DTA_VIAGEM
			AAdd(aErrMsg,cErroInt)	
			lRet := .f.
		Else
			cErroInt := "Este CT-e se encontra-se em viagem: " + DTA->DTA_VIAGEM
			AAdd(aErrMsg,cErroInt)	
			lRet := .f.		
		End If
	End If

Return lRet


/*/{Protheus.doc} AtuSIGAFIS
Atualizacao dos Livros Fiscais
@author mauricio.santos
@since 02/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AtuSIGAFIS()

	Local lRet := .t.

	SFT->(DbSetOrder(1))
	//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
	If SFT->(DbSeek(xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA)))

		While SFT->(!eof()) .AND. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA)
			Reclock("SFT",.f.)
			SFT->FT_OBSERV := "NF CANCELADA"
			SFT->FT_DTCANC := SZM->ZM_DTEVENT
			MsUnLock()		
			SFT->(DbSkip())
		EndDo
	EndIf

	SF3->(DbSetOrder(6))

	If SF3->(DbSeek(xFilial("SF3") + SF2->(F2_DOC + F2_SERIE)))

		While SF3->(!EOF()) .and. SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE) == xFilial("SF3") + SF2->(F2_DOC + F2_SERIE)

			Reclock("SF3",.F.)
			SF3->F3_OBSERV := "CTE CANCELADO"
			SF3->F3_DTCANC := SZM->ZM_DTEVENT
			SF3->F3_DESCRET:= 'Cancelamento autorizado'
			SF3->F3_CODRSEF:= '101'
			MsUnLock()

			SF3->(DbSkip())
		EndDo
	End If
Return lRet