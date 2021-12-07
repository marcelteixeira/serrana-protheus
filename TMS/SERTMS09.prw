#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} SERTMS09
Modelo de dados para importacao dos eventos de cancelamento do MDFE
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS09()

	Local aArea   := GetArea()
	Local oBrowse := Nil

	Private aRotina := MenuDef()

	//Instânciando FWMBrowse 
	oBrowse := FWMBrowse():New()

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERTMS09")

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZP")

	//Setando a descrição da rotina
	oBrowse:SetDescription("Eventos Importados de MDfe")

	// Adiciona legenda
	oBrowse:AddLegend("!Empty(ZP_DTTMS)" 					  , "BR_VERMELHO"  , "Integrado")
	oBrowse:AddLegend("Empty(ZP_DTTMS) .AND. !EMPTY(ZP_LOG)"  , "BR_AMARELO"   , "Nao Integrado")
	oBrowse:AddLegend("Empty(ZP_DTTMS) .AND. EMPTY(ZP_LOG)"   , "BR_VERDE"	   , "Disponivel")

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
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERTMS09"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERTMS09"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERTMS09"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERTMS09"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERTMS09"	,0,5,0,NIL})
	aAdd(aRot,{"Canc. MDFe" ,"U_TMS09IMP()"	,0,4,0,NIL})


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
	Local oStSZP   := FWFormStruct(1, "SZP")

	// Cria o modelo
	oModel := MPFormModel():New("MSERTMS09",/*bPre*/, bPos /*bPos*/, bCommit/*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("SZPMASTER",/*cOwner*/, oStSZP)

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)

	//Adicionando descrição ao modelo
	oModel:SetDescription("Eventos Importados")

	//Descricoes dos modelos de dados
	oModel:GetModel("SZPMASTER"):SetDescription("Eventos Mdfe")

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
	Local oModel := FWLoadModel("SERTMS09")

	//Criação da estrutura de dados da View
	Local oStSZP := FWFormStruct(2, "SZP")
	Local oView  := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Atribuindo fomulários para interface
	oView:AddField("VIEW_SZP"    , oStSZP   , "SZPMASTER")

	//Criando os paineis
	oView:CreateHorizontalBox("SUPERIOR",100)

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOK({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZP","SUPERIOR")

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
	If !Empty(SZP->ZP_DTTMS)
		cMsg  := "Este evento já foi integrado no ERP e não será permitido realizar a Alteração\Exclusão."
		cSolu := "Favor selecionar outro registro"
		Help(NIL, NIL, "SERTMS09 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
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
	Local oModelSZP := oModel:GetModel("SZPMASTER")
	Local nOperacao := oModel:GetOperation()

	If nOperacao == MODEL_OPERATION_DELETE
		lRet := .t.
		Return lRet
	End If

	// Verifica se a empresa logada possui o CNPJ do emitente informado
	If FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2] != oModelSZP:GetValue("ZP_CGC")
		oModel:SetErrorMessage("",,oModel:GetId(),"","TudoOK","A Inclusao deste evento somente pode ser na empresa emissora","Favor alterar o CNPJ do emitente.") 
		Return .f.
	End If

	SZP->(DbSetOrder(2))
	If SZP->(DbSeek(xFilial("SZP") + oModelSZP:GetValue("ZP_ID")))
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
		//FWMsgRun(, {|| lRet := FWFormCommit( oModel ) }	, "Processando", "SERTMS09 - Gravando Cancelamento...")
		lRet := FWFormCommit( oModel )
	End If

	If lRet .and. nOp == MODEL_OPERATION_INSERT
		// Realiza a integracao no SIGATMS
		//FWMsgRun(, {|| aErro := U_TMS09IMP() }		, "Processando", "SERTMS09 - Gerando movimentações no SIGATMS")
		aErro := U_TMS09IMP()
	End if 	

	nModulo := nBckpModulo

Return lRet

/*/{Protheus.doc} TMS09IMP
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TMS09IMP()

	Local lRet 		:= .t.
	Private aErrMsg	:= {}

	// Verifica se a integracao sera realizada na empresa correta
	If Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2]) != Alltrim(SZP->ZP_CGC)
		AAdd(aErrMsg,"A integração deste CANCELAMENTO só é permitida na empresa emitente.") 
		lRet := .f.
	End If

	If lRet

		BEGIN TRANSACTION

			DTX->(DbSetOrder(7))
			//DTX_FILIAL+DTX_FILMAN+DTX_CHVMDF

			If !DTX->(DbSeek(xFilial("DTX") + cFilAnt + SZP->ZP_CHVMDFE))
				AAdd(aErrMsg,"Nao encontrado o MDFe (" + SZP->ZP_CHVMDFE + ") na tabela DTX.") 
				lRet := .f.
			End if

			// Verifica se o evento e de cancelamento
			If lRet .and. Alltrim(SZP->ZP_TPEVENT) == "110111"
				
				// Verifica se existe  contrato de carreteiro ja vinculado
				If !Empty(DTX->DTX_NUMCTC)
					AAdd(aErrMsg,"O Manifesto se encontra com contrato carreteiro vinculado: " + DTX->DTX_NUMCTC) 
					lRet := .f.	
				Else
					lRet := MDFECANC()
				End If
				
				// Verifica se o evento e de Encerramento
			ElseIf lRet .and. Alltrim(SZP->ZP_TPEVENT) == "110112"
				lRet := MDFEENC()
			End If

			// Caso encontre algum erro
			If lRet
				Reclock("SZP",.F.)
				SZP->ZP_LOG	  := ""
				SZP->ZP_DTTMS := DDATABASE
				MsUnLock()
			Else
				DisarmTransaction()				
			End If	

		END TRANSACTION 

	End If

	If Len(aErrMsg) > 0 
		Reclock("SZP",.F.)
		SZP->ZP_LOG := aErrMsg[1]
		MsUnLock()
	End If

Return aErrMsg

/*/{Protheus.doc} MDFEENC
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEENC()

	Local lRet := .t.

	Reclock("DTX",.F.)
	DTX->DTX_PRFMDF	:= SZP->ZP_PROCRET
	DTX->DTX_STFMDF  := "2"
	DTX->DTX_STATUS  := "3"
	DTX->DTX_RTFMDF  := "132 - Encerramento de MDF-e homologado"
	DTX->DTX_IDFMDF  := "132"
	DTX->DTX_CODEVE	 := "3"
	MsUnLock()

Return lRet


/*/{Protheus.doc} MDFECANC
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFECANC()

	Local cViagem := ""
	Local lRet := .t.

	// Obtem a viagem
	cViagem := DTX->DTX_VIAGEM

	// Cria registro de cancelamento
	If lRet 
		lRet := MDFEDYN()
	End If

	// Limpa o Mdfe dos movimento de viagem
	If lRet
		lRet := MDFEDUD()
	End if

	// Limpa o Mdfe dos percursos
	If lRet
		lRet := MDFEPER()
	End if

	// Exclui o Manifesto
	If lRet
		lRet := MDFEDTX()
	End if

	// Exclui percursos
	If lRet
		lRet := MDFEDL012(cViagem)
	End if

	// Exclui a Viagem
	If lRet
		lRet := MDFEVGM(cViagem)
	End if

Return lRet 

/*/{Protheus.doc} MDFEVGM
Exclusao da viagem 
@author mauricio.santos
@since 14/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEVGM(cViagem)

	Local lRet := .t.

	DTQ->(DbSetOrder(1))

	If DTQ->(DbSeek(xFilial("DTQ") + cViagem))

		If lRet
			// Exclui o carregamento
			lRet := MDFEDTA()
		End If

		If lRet 
			// Exclui o complemento da viagem
			lRet := MDFEDTR()
		End If

		If lRet 
			// Exclui o Movimento da viagem
			lRet := MDFEDUDE()
		End If

		// Exclui Motorista da Viagem
		If lRet
			lRet := MDFEDUP()
		End if

		If lRet 
			// Exclui a Viagem
			RecLock("DTQ", .F.)
			dbDelete()
			MsUnLock()
		End If

	End If

Return lRet

/*/{Protheus.doc} MDFEDTA
Exclusao do carregamento
@author mauricio.santos
@since 14/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDTA()

	Local lRet := .t. 

	DTA->(DbSetOrder(2))
	//DTA_FILIAL+DTA_FILORI+DTA_VIAGEM+DTA_FILDOC+DTA_DOC+DTA_SERIE
	If DTA->(DbSeek(xFilial("DTA") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))

		While DTA->(!EOF()) .and. DTA->(DTA_FILIAL+DTA_FILORI+DTA_VIAGEM) == xFilial("DTA") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)

			RecLock("DTA", .F.)
			dbDelete()
			MsUnLock()

			DTA->(DbSkip())
		EndDo
	End If

Return lRet

/*/{Protheus.doc} MDFEDUP
Exclui o motorista da viagem
@author mauricio.santos
@since 14/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDUP()

	Local lRet := .t.

	DUP->(DbSetOrder(1))
	//DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR+DUP_CODMOT

	If DUP->(DbSeek(xFilial("DUP") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))

		While DUP->(!EOF()) .and. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM) == xFilial("DUP") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)

			RecLock("DUP", .F.)
			dbDelete()
			MsUnLock()

			DUP->(DbSkip())
		EndDo
	End If	

Return lRet

/*/{Protheus.doc} MDFEDUDE
Exclusao do Movimento da Viagem
@author mauricio.santos
@since 14/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDUDE()

	Local lRet := .t. 

	DUD->(DbSetOrder(2))
	//DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
	If DUD->(DbSeek(xFilial("DUD") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))

		While DUD->(!EOF()) .and. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial("DUD") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)

			RecLock("DUD", .F.)
			dbDelete()
			MsUnLock()

			DUD->(DbSkip())
		EndDo
	End If

Return lRet


/*/{Protheus.doc} MDFEDTR
Exclusao do Movimento da Viagem
@author mauricio.santos
@since 14/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDTR()

	Local lRet := .t. 

	DTR->(DbSetOrder(1))
	//DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
	If DTR->(DbSeek(xFilial("DTR") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))

		While DTR->(!EOF()) .and. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial("DTR") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)

			RecLock("DTR", .F.)
			dbDelete()
			MsUnLock()

			DTR->(DbSkip())
		EndDo
	End If

Return lRet


/*/{Protheus.doc} MDFEDTX
Deleta o Manifesto
@author mauricio.santos
@since 09/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDTX()

	Local lRet := .t.

	RecLock("DTX", .F.)
	dbDelete()
	MsUnLock()

Return lRet

/*/{Protheus.doc} MDFEDL012
Deleta o percurso se a viagem nao possuir MDFe
@author mauricio.santos
@since 09/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cViagem, characters, description
@type function
/*/
Static Function MDFEDL012(cViagem)

	Local lRet := .t. 

	dbSelectArea("DTX")
	DTX->(dbSetOrder(5))
	If !DTX->(MsSeek(xFilial("DTX") + cFilAnt + cViagem))
		dbSelectArea("DL0")
		DL0->(dbSetOrder(2))
		If DL0->(MsSeek( FWxFilial("DL0") + cFilAnt + cViagem ))
			DL0->(MsSeek( FWxFilial("DL0") + cFilAnt + cViagem + Replicate("Z", Len(DL0->DL0_PERCUR)), .T.))
			DL0->(DbSkip(-1))

			dbSelectArea("DL1")
			DL1->(dbSetOrder(5))
			DL1->(dbSeek(FWxFilial("DL1") + DL0->DL0_PERCUR))
			While DL1->(!Eof()) .AND. DL1->DL1_FILIAL + DL1->DL1_PERCUR == FWxFilial("DL1") + DL0->DL0_PERCUR
				RecLock("DL1", .F.)
				dbDelete()
				MsUnLock()
				DL1->(dbSkip())
			End

			dbSelectArea("DL2")
			DL2->(dbSetOrder(1))
			DL2->(dbSeek(FWxFilial("DL2") + DL0->DL0_PERCUR))
			While DL2->(!Eof()) .AND. DL2->DL2_FILIAL + DL2->DL2_PERCUR == FWxFilial("DL2") + DL0->DL0_PERCUR
				RecLock("DL2", .F.)
				dbDelete()
				MsUnLock()
				DL2->(dbSkip())
			End

			RecLock("DL0", .F.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} MDFEPER
Limpa o MDFe dos percursos
@author mauricio.santos
@since 09/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEPER()

	Local lRet 			:= .t.
	Local lLimpaDL0 	:= .f.
	Local lDTX_PRMACO 	:= DTX->(FieldPos("DTX_PRMACO")) > 0

	// Limpa o Manifesto do Percurso
	If AliasInDic("DL0")
		DL0->( DbSetOrder( 2 ) )
		If DL0->(MsSeek( FWxFilial("DL0")+DTX->DTX_FILORI+DTX->DTX_VIAGEM ))
			lLimpaDL0:= .T.
		Else
			// Verifica se a viagem é coligada
			DTR->( DbSetOrder( 1 ) )
			If DTR->(MsSeek(xFilial("DTR")+ DTX->DTX_FILORI + DTX->DTX_VIAGEM)) .And. !Empty(DTR->DTR_NUMVGE)
				DL0->( DbSetOrder( 2 ) )
				If DL0->(MsSeek( FWxFilial("DL0")+DTR->DTR_FILVGE+DTR->DTR_NUMVGE ))   //Posiciona na viagem Principal
					lLimpaDL0:= .T.
				EndIf
			EndIf
		EndIf

		If lLimpaDL0
			DL0->( DbSetOrder( 2 ) )
			DL0->(MsSeek( FWxFilial("DL0")+DTX->DTX_FILORI+DTX->DTX_VIAGEM + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
			DL0->(DbSkip(-1))

			If lDTX_PRMACO
				AF16AtuMan(DL0->DL0_PERCUR,,,DTX->DTX_FILMAN,IIf(!Empty(DTX->DTX_PRMACO),DTX->DTX_PRMACO,DTX->DTX_MANIFE),DTX->DTX_SERMAN,.T.)
			Else
				AF16AtuMan(DL0->DL0_PERCUR,,,DTX->DTX_FILMAN,DTX->DTX_MANIFE,DTX->DTX_SERMAN,.T.)
			EndIf
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} MDFEDUD
Retira o relacionamento do MDfe com o movimento da viagem
@author mauricio.santos
@since 09/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDUD()

	Local cQuery := ""
	Local lRet   := .t.
	Local lDTX_PRMACO := DTX->(FieldPos("DTX_PRMACO")) > 0
	Local cAliasTop := GetNextAlias()

	cQuery :=  " SELECT DUD_FILIAL, DUD_FILORI, DUD_VIAGEM, DUD_FILMAN, DUD_MANIFE, DUD_SERMAN FROM "
	cQuery +=  RetSqlName('DUD')+" DUD, "
	cQuery +=  RetSqlName('DTX')+" DTX  "
	cQuery +=  " WHERE  DUD_FILIAL = '" + xFilial("DUD") + "' AND DTX_FILIAL = '" + xFilial("DTX") + "'"

	If lDTX_PRMACO
		cQuery += " AND DUD.DUD_FILMAN = '" + DTX->DTX_FILMAN + "' AND DUD.DUD_MANIFE = '" + Iif(!Empty(DTX->DTX_PRMACO),DTX->DTX_PRMACO,DTX->DTX_MANIFE) + "'"
	Else
		cQuery += " AND DUD.DUD_FILMAN = '" + DTX->DTX_FILMAN + "' AND DUD.DUD_MANIFE = '" + DTX->DTX_MANIFE + "'"
	EndIf
	cQuery += " AND DTX.DTX_FILMAN = '" + DTX->DTX_FILMAN + "' AND DTX.DTX_MANIFE = '" + DTX->DTX_MANIFE + "'"
	cQuery += " AND DUD.DUD_SERMAN = '"+ DTX->DTX_SERMAN+"' AND DTX.DTX_SERMAN = '" + DTX->DTX_SERMAN + "'"

	cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += " AND DTX.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)

	While (cAliasTop)->(!Eof())
		IncProc()

		DUD->( dbSetOrder(5) ) 
		//DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILMAN+DUD_MANIFE+DUD_SERMAN
		If DUD->(MsSeek( xFilial("DUD") + (cAliasTop)->DUD_FILORI+(cAliasTop)->DUD_VIAGEM+(cAliasTop)->DUD_FILMAN+(cAliasTop)->DUD_MANIFE+(cAliasTop)->DUD_SERMAN) )

			lChave := DUD->(DUD_FILMAN + DUD_MANIFE + DUD_SERMAN) == DTX->(DTX_FILMAN + DTX_MANIFE + DTX_SERMAN)
			If  lChave
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Limpa Seq. Carregamento e Documento do Manifesto                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("DUD", .F.)
				DUD->DUD_FILMAN := Space( Len( DUD->DUD_FILMAN ) )
				DUD->DUD_MANIFE := Space( Len( DUD->DUD_MANIFE ) )
				DUD->DUD_SERMAN := Space( Len( DUD->DUD_SERMAN ) )
				MsUnLock()
			EndIf
		EndIf
		(cAliasTop)->(dbSkip())
	EndDo	
	(cAliasTop)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} MDFEDYN
Cria registro de cancelamento na DYN
@author mauricio.santos
@since 09/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDYN()

	Local lRet := .t.
	Local lDTX_CODVEI := DTX->(FieldPos("DTX_CODVEI")) > 0

	DYN->(DbSetOrder(3)) 
	//DYN_FILIAL+DYN_FILMAN+DYN_MANIFE+DYN_SERMAN+DYN_STCMDF

	If !DYN->(DbSeek(DTX->(xFilial("DYN") + DTX_FILMAN + DTX_MANIFE + DTX_SERMAN)))
		RecLock("DYN", .T.)
		DYN->DYN_FILIAL:= xFilial('DYN')
		DYN->DYN_FILMAN:= DTX->DTX_FILMAN
		DYN->DYN_MANIFE:= DTX->DTX_MANIFE
		DYN->DYN_SERMAN:= DTX->DTX_SERMAN
		DYN->DYN_FILORI:= DTX->DTX_FILORI
		DYN->DYN_VIAGEM:= DTX->DTX_VIAGEM
		DYN->DYN_DATMAN:= DTX->DTX_DATMAN
		DYN->DYN_HORMAN:= DTX->DTX_HORMAN
		DYN->DYN_FILDCA:= DTX->DTX_FILDCA
		DYN->DYN_CDRDES:= DTX->DTX_CDRDES
		If lDTX_CODVEI
			DYN->DYN_CODVEI:= DTX->DTX_CODVEI
		EndIf
		DYN->DYN_CHVMDF:= DTX->DTX_CHVMDF
		DYN->DYN_PRIMDF:= DTX->DTX_PRIMDF
		DYN->DYN_STIMDF:= DTX->DTX_STIMDF
		DYN->DYN_RTIMDF:= DTX->DTX_RTIMDF
		DYN->DYN_IDIMDF:= DTX->DTX_IDIMDF
		DYN->DYN_CTGMDF:= DTX->DTX_CTGMDF

		DYN->DYN_STCMDF:= '2' //Autorizado
		DYN->DYN_RTCMDF:= '101 - Cancelamento de MDF-e homologado'
		DYN->DYN_IDCMDF:= '101'
		DYN->DYN_PRCMDF:= SZP->ZP_PROCRET

		MSMM(DYN->DYN_CODOBS,,,SZP->ZP_MOTIVO,1,,,"DYN","DYN_CODOBS")

		MsUnLock()
	EndIf

Return lRet