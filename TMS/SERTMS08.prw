#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} SERTMS08
Modelo de dados para importacao da MDFE
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS08()

	Local aArea   := GetArea()
	Local oBrowse := Nil

	Private aRotina := MenuDef()

	//Instânciando FWMBrowse 
	oBrowse := FWMBrowse():New()

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERTMS08")

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZN")

	//Setando a descrição da rotina
	oBrowse:SetDescription("MDf-e Importados")

	// Adiciona legenda
	oBrowse:AddLegend("!Empty(ZN_DTTMS)" 					  , "BR_VERMELHO"  , "Integrado")
	oBrowse:AddLegend("Empty(ZN_DTTMS) .AND. !EMPTY(ZN_LOG)"  , "BR_AMARELO"   , "Nao Integrado")
	oBrowse:AddLegend("Empty(ZN_DTTMS) .AND. EMPTY(ZN_LOG)"   , "BR_VERDE"	   , "Disponivel")

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
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERTMS08"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERTMS08"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERTMS08"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERTMS08"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERTMS08"	,0,5,0,NIL})
	aAdd(aRot,{"Imp. MDF-e" ,"u_TMS08IMP()"		,0,4,0,NIL})


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
	Local bPos    := {|oModel| TudoOK(oModel)} 
	Local bCommit := {|oModel| Commit(oModel)} 

	// Criação da estrutura de dados utilizada na interface
	Local oStSZN   := FWFormStruct(1, "SZN")
	Local oStSZO   := FWFormStruct(1, "SZO")

	// Cria o modelo
	oModel := MPFormModel():New("MSERTMS08",/*bPre*/,bPos /*bPos*/,bCommit/*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("SZNMASTER",/*cOwner*/, oStSZN)
	oModel:AddGrid( "SZODETAIL", "SZNMASTER",oStSZO, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)

	// Atribui o relacionamento
	oModel:SetRelation("SZODETAIL", {{"ZO_FILIAL","FwXFilial('SZO')"}, {"ZO_CHVMDFE","ZN_CHVMDFE"} }, SZO->( IndexKey( 1 ) ) )

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)

	//Adicionando descrição ao modelo
	oModel:SetDescription("MDF-e Importados")

	//Descricoes dos modelos de dados
	oModel:GetModel("SZNMASTER"):SetDescription("MDF-e Importados")
	oModel:GetModel("SZODETAIL"):SetDescription("Ct-e do MDF-e")

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey( {""} )

	oModel:GetModel("SZODETAIL"):SetOptional( .T. )

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
	Local oModel := FWLoadModel("SERTMS08")

	//Criação da estrutura de dados da View
	Local oStSZN := FWFormStruct(2, "SZN")
	Local oStSZO := FWFormStruct(2, "SZO")
	Local oView  := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Remocao do campo de vinculo
	oStSZO:RemoveField("ZO_CHVMDFE")

	//Atribuindo fomulários para interface
	oView:AddField("VIEW_SZN"    , oStSZN   , "SZNMASTER")
	oView:AddGrid("VIEW_SZO"     , oStSZO  	, "SZODETAIL") 

	//Criando os paineis
	oView:CreateHorizontalBox("SUPERIOR",050)
	oView:CreateHorizontalBox("INFERIOR",050)

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOK({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZN","SUPERIOR")
	oView:SetOwnerView("VIEW_SZO","INFERIOR")

	//Atribui descricao
	oView:EnableTitleView("VIEW_SZO", "Ct-e por MDF-e" )

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

	If nOper != MODEL_OPERATION_DELETE
		Return .t.
	End If

	// Verifica se ja foi integrado no ERP.
	If !Empty(SZN->ZN_DTTMS)
		cMsg  := "Este MDF-e já foi integrado no ERP e não será permitido realizar a Exclusão."
		cSolu := "Favor selecionar outro registro"
		Help(NIL, NIL, "SERTMS08 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
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
	Local oModelSZN := oModel:GetModel("SZNMASTER")
	Local nOperacao := oModel:GetOperation()

	// Verifica se a empresa logada possui o CNPJ do emitente informado
	If FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2] != oModelSZN:GetValue("ZN_CGCEMIT")
		oModel:SetErrorMessage("",,oModel:GetId(),"","TudoOK","A Inclusao deste MDF-E somente pode ser na empresa emissora","Favor alterar o CNPJ do emitente.") 
		Return .f.
	End If

	If nOperacao == MODEL_OPERATION_DELETE
		lRet := .t.
		Return lRet
	ElseIf nOperacao == MODEL_OPERATION_INSERT
		SZN->(DbSetOrder(1))
		If SZN->(DbSeek(xFilial("SZN") + oModelSZN:GetValue("ZN_CHVMDFE")))
			oModel:SetErrorMessage("",,oModel:GetId(),"","TudoOK","Este MDF-E ja foi importado anteriormente.","") 
			Return .f.
		End If
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
		//FWMsgRun(, {|| lRet := FWFormCommit( oModel ) }	, "Processando", "SERTMS08 - Gravando MDF-e...")
		lRet := FWFormCommit( oModel )
	End If

	If lRet .and. nOp == MODEL_OPERATION_INSERT
		// Realiza a integracao no SIGATMS
		//FWMsgRun(, {|| aErro := U_TMS08IMP() }		, "Processando", "SERTMS08 - Gerando movimentações no SIGATMS")
		aErro := U_TMS08IMP()
	End if 	

	nModulo := nBckpModulo
Return lRet


/*/{Protheus.doc} TMS08IMP
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TMS08IMP()

	Local lRet 		:= .t.
	Local i			:= 0
	Private aErrMsg := {}
	Private aVetDoc := {0,0,0,0,0,0}
	

	BEGIN TRANSACTION

		lRet := MDFEValid()

		If lRet
			// Cria Viagem
			If lRet
				lRet := MDFEDTQ()
			End IF

			// Relacionando Veiculo a Viagem
			If lRet
				lRet := MDFEDTR()
			End if

			// Relacionando Motorista a Viagem
			If lRet
				lRet := MDFEDUP()
			End if

			// Relacionando os CTEs emitidos a Viagem
			If lRet
				lRet := MDFEDTA()
			End if

			// Cria o percurso e atualiza informacoes do Manifesto
			If lRet
				lRet := MDFEPER()
			End If

			// Integrando o Mdf-e
			If lRet
				lRet := MDFEDTX()
			End if
			
			// Verifica se existe eventos para este MDf-e prontos
			// para serem importados.
			If lRet 
				lRet := MDFECANC()
			EndIf

			// Caso encontre algum erro
			If lRet
				Reclock("SZN",.F.)
				SZN->ZN_LOG	  := ""
				SZN->ZN_DTTMS := DDATABASE
				MsUnLock()
			Else
				DisarmTransaction()				
			End If	

		End If	

	END TRANSACTION 

	If Len(aErrMsg) > 0 
		For i := 1 to len(aErrMsg)
			Reclock("SZN",.F.)
			SZN->ZN_LOG := SZN->ZN_LOG + aErrMsg[i] + Chr(13) + Chr(10)
			MsUnLock()
		Next
	End If

Return aErrMsg

/*/{Protheus.doc} MDFECANC
Verifica se existe enventos de cancelamento/Encerramentos
@author mauricio.santos
@since 14/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFECANC()
	
	Local lRet := .t.
	Local aArea		:= GetArea()
	Local aAreaSZL  := SZL->(GetArea())
	Local aAreaSZK  := SZK->(GetArea())
	Local aAreaSZM  := SZM->(GetArea())
	Local aAreaSZN  := SZN->(GetArea())
	Local aAreaSZO  := SZO->(GetArea())
	Local aAreaSZP  := SZP->(GetArea())

	SZP->(DbSetOrder(1))
	//ZP_FILIAL+ZP_CHVMDFE
	
	If SZP->(DbSeek(xFilial("SZP") + SZN->ZN_CHVMDFE))
		
		While SZP->(!EOF()) .AND. SZP->(ZP_FILIAL+ZP_CHVMDFE) == xFilial("SZP") + SZN->ZN_CHVMDFE
			
			If Empty(SZP->ZP_DTTMS)
				U_TMS09IMP()
			End If
			SZP->(DbSkip())
		EndDO
	End if
	
	RestArea(aArea)
	RestArea(aAreaSZK)
	RestArea(aAreaSZL)
	RestArea(aAreaSZM)
	RestArea(aAreaSZN)
	RestArea(aAreaSZO)
	RestArea(aAreaSZP)
Return lRet

/*/{Protheus.doc} MDFEPER
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEPER()

	Local lRet := .t. 
	Local aAreaDUD := DUD->(GetArea())
	// Cria os percursos 
	Pergunte("TMB144",.f.) 
	SetMVValue("TMB144","MV_PAR05",2) 
	F16LdVia(cFilAnt,DTQ->DTQ_VIAGEM,{})
	SetMVValue("TMB144","MV_PAR05",1) 

	DUD->(DbSetOrder(2))
	If DUD->(DbSeek(xFilial("DUD") +DTQ->(DTQ_FILORI + DTQ_VIAGEM)))

		While DUD->(!EOF()) .AND. DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == xFilial("DUD") +DTQ->(DTQ_FILORI + DTQ_VIAGEM)
			If AliasInDic("DL0")
				dbSelectArea("DL0")
				DL0->(dbSetOrder(2))
				If DL0->(MsSeek( FWxFilial("DL0")+ DUD->(DUD_FILORI + DUD_VIAGEM)))
					DL0->(MsSeek( FWxFilial("DL0")+ DUD->(DUD_FILORI + DUD_VIAGEM) + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
					DL0->(DbSkip(-1))

					DL2->(dbSetOrder(2))
					If DL2->(MsSeek(xFilial("DL2")+DUD->(DUD_FILORI+DUD_VIAGEM+DUD_FILDOC+DUD_DOC+DUD_SERIE)+DL0->DL0_PERCUR))
						DL1->(dbSetOrder(1))
						If DL1->(MsSeek(xFilial("DL1")+DL2->(DL2_PERCUR+DL2_IDLIN)))
							// Atualiza o manifesto nas tabelas de percurso.
							AF16AtuMan(DL0->DL0_PERCUR,DL1->DL1_UFORIG, DL1->DL1_UF,cFilAnt,DUD->DUD_MANIFE,SZN->ZN_SERIE)
						EndIf
					EndIf
				EndIf
			EndIf
			DUD->(DBSkip())
		EndDo
	End If
	RestArea(aAreaDUD)
Return lRet

/*/{Protheus.doc} MDFEDTX
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDTX()

	Local lRet := .t.

	DA3->(DbSetOrder(3))
	//DA3_FILIAL+DA3_PLACA
	DA3->(DbSeek(xFilial("DA3") + SZN->ZN_PLACA))

	RecLock("DTX", .T.)

	DTX->DTX_FILIAL := xFilial("DTX")
	DTX->DTX_FILMAN := cFilAnt
	DTX->DTX_MANIFE := SZN->ZN_MDFE
	DTX->DTX_SERMAN := SZN->ZN_SERIE
	DTX->DTX_FILORI := cFilAnt
	DTX->DTX_VIAGEM := DTQ->DTQ_VIAGEM
	DTX->DTX_DATMAN := SZN->ZN_DTEMISS
	DTX->DTX_HORMAN := STRTRAN(SUBSTR(SZN->ZN_HREMISS,1,5),":","")
	DTX->DTX_QTDDOC := aVetDoc[1]
	DTX->DTX_QTDVOL := aVetDoc[2]
	DTX->DTX_PESO	:= aVetDoc[3]
	DTX->DTX_PESOM3 := aVetDoc[4]
	DTX->DTX_PESCOB := aVetDoc[5]
	DTX->DTX_VALMER := aVetDoc[6]
	DTX->DTX_FILDCA := cFilAnt
	DTX->DTX_CDRDES := ""
	DTX->DTX_CODVEI := DA3->DA3_COD
	DTX->DTX_TIPMAN := "2"
	DTX->DTX_CHVMDF := SZN->ZN_CHVMDFE
	DTX->DTX_PRIMDF := SZN->ZN_PROTOCO
	DTX->DTX_STIMDF := "2"
	DTX->DTX_STATUS := "2"
	DTX->DTX_QTDCTE := aVetDoc[1]
	DTX->DTX_IDIMDF := "100"
	DTX->DTX_RTIMDF := "100 - Autorizado o uso do MDF-e"
	DTX->DTX_AMBIEN := VAL(SZN->ZN_TPAMB)
	DTX->DTX_UFATIV := Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_EST')

	MsUnLock()

Return lRet

/*/{Protheus.doc} MDFEDTQ
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDTQ()

	Local cTime 	:= SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2)
	Local cRota		:= SuperGetMV("MV_YROTXML",.f.,"BRASIL")
	Local lRet		:= .t.
	Local cViagem  	:= NextNumero("DTQ",1,"DTQ_VIAGEM",.T.)

	RecLock("DTQ", .T.)
	DTQ->DTQ_FILIAL := xFilial("DTQ")
	DTQ->DTQ_FILORI := cFilAnt
	DTQ->DTQ_VIAGEM := cViagem
	DTQ->DTQ_TIPVIA := "1"
	DTQ->DTQ_ROTA 	:= cRota
	DTQ->DTQ_DATGER := DDATABASE
	DTQ->DTQ_HORGER := cTime
	DTQ->DTQ_SERTMS := "3"
	DTQ->DTQ_TIPTRA := "1"
	DTQ->DTQ_FILATU := cFilAnt
	DTQ->DTQ_FILDES := cFilAnt
	DTQ->DTQ_STATUS := "1"
	DTQ->DTQ_CUSTO1 := 0
	DTQ->DTQ_CUSTO2 := 0
	DTQ->DTQ_CUSTO3 := 0
	DTQ->DTQ_CUSTO4 := 0
	DTQ->DTQ_CUSTO5 := 0
	DTQ->DTQ_QTDPER := 0
	MsUnlock()

Return lRet

/*/{Protheus.doc} MDFEDTR
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDTR()

	Local cPlaca	 := SZN->ZN_PLACA
	Local cRebo1	 := SZN->ZN_PLARB1
	Local cRebo2	 := SZN->ZN_PLARB2
	Local cRebo3	 := SZN->ZN_PLARB3
	Local lRet		 := .t.

	DA3->(DbSetOrder(3))
	// Posiciona no cadastro do veiculo
	DA3->(DbSeek(xFilial("DA3") + cPlaca))

	DTR->(dbSetOrder(3) )

	If !DTR->( dbseek(xFilial("DTR") + cFilAnt + DTQ->DTQ_VIAGEM + DA3->DA3_COD) )

		RecLock("DTR", .T.)

		DTR->DTR_FILIAL	:=	xFilial("DTR")
		DTR->DTR_FILORI	:=	cFilAnt
		DTR->DTR_VIAGEM	:=	DTQ->DTQ_VIAGEM
		DTR->DTR_ITEM	:=	"01"
		DTR->DTR_CODVEI	:=	DA3->DA3_COD
		DTR->DTR_QTDEIX	:=	DA3->DA3_QTDEIX
		DTR->DTR_INSRET	:=	0
		DTR->DTR_VALFRE	:=	0
		DTR->DTR_VALPDG	:=	0
		DTR->DTR_CREADI	:=	DA3->DA3_CODFOR
		DTR->DTR_LOJCRE	:=	DA3->DA3_LOJFOR
		DTR->DTR_NOMCRE	:=	Posicione("SA2", 1, xFilial("SA2")+DTR->DTR_CREADI+DTR->DTR_LOJCRE, "A2_NOME")
		DTR->DTR_ADIFRE	:=	0
		DTR->DTR_FRECAL	:=	"2"
		DTR->DTR_REBTRF	:=	"2"
		DTR->DTR_CODFOR	:=	DA3->DA3_CODFOR
		DTR->DTR_LOJFOR	:=	DA3->DA3_LOJFOR
		DTR->DTR_QTEIXV	:=	DA3->DA3_QTDEIX
		DTR->DTR_VALRB1	:=	0
		DTR->DTR_VALRB2	:=	0
		DTR->DTR_CALRB1	:=	"2"
		DTR->DTR_CALRB2	:=	"2"
		DTR->DTR_CALRB3	:=	"2"
		DTR->DTR_PERADI	:=	0
		DTR->DTR_TIPCRG	:=	"2"
		DTR->DTR_CODRB1	:=	Alltrim(Posicione("DA3", 3, xFilial("SA2")+cRebo1, "DA3_COD"))
		DTR->DTR_CODRB2	:=	Alltrim(Posicione("DA3", 3, xFilial("SA2")+cRebo2, "DA3_COD"))
		DTR->DTR_CODRB3	:=	Alltrim(Posicione("DA3", 3, xFilial("SA2")+cRebo3, "DA3_COD"))
		MsUnlock()

	EndIf

Return lRet 

/*/{Protheus.doc} MDFEDUP
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDUP()

	Local lRet := .t.

	DA4->(DbSetOrder(3))
	//DA4_FILIAL+DA4_CGC
	DA4->(DbSeek(xFilial("DA4") + SZN->ZN_CGCMOTO))
	
	DA3->(DbSetOrder(3))
	//DA3_FILIAL+DA3_PLACA
	DA3->(DbSeek(xFilial("DA3") + SZN->ZN_PLACA))

	DUP->( dbSetOrder(2))
	//DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_CODMOT
	If !DUP->( dbseek(xFilial("DUP")+cFilAnt+DTQ->DTQ_VIAGEM+DA4->DA4_COD) )

		RecLock("DUP", .T.)
		DUP->DUP_FILIAL	:=	xFilial("DUP")
		DUP->DUP_FILORI	:=	cFilAnt
		DUP->DUP_VIAGEM	:=	DTQ->DTQ_VIAGEM
		DUP->DUP_ITEDTR	:=	"01"
		DUP->DUP_CODVEI	:=	DA3->DA3_COD
		DUP->DUP_CODMOT	:=	DA4->DA4_COD
		DUP->DUP_VALSEG	:=	0
		DUP->DUP_CONDUT	:=	"1"
		MsUnlock()

	EndIf

Return lRet

/*/{Protheus.doc} MDFEDTA
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEDTA()

	Local lAdd 		 := .T.	
	Local cZona		 := ""
	Local cSetor	 := ""
	Local cSequen	 := Padl("0",TamSX3("DUD_SEQUEN")[1],"0")
	Local lRet 	     := .t.
	Local cSerie	 := ""

	DA3->(DbSetOrder(3))
	//DA3_FILIAL+DA3_PLACA
	DA3->(DbSeek(xFilial("DA3") + SZN->ZN_PLACA))

	SZO->(DbSetOrder(1))
	If SZO->(DbSeek(xFilial("SZO") + SZN->ZN_CHVMDFE))

		While SZO->(!EOF()) .AND. SZO->(ZO_FILIAL + ZO_CHVMDFE) == xFilial("SZO") + SZN->ZN_CHVMDFE

			lAdd   := .t. 
			cSerie := cValToChar(Val(SZO->ZO_SERIE))

			DT6->(DbSetOrder(1))
			If DT6->(DBSeek(xFilial("DT6") + cFilAnt +  SZO->(ZO_NUMCTE ) + cSerie))

				// Realiza o carregamento
				DTA->( dbSetOrder(1) )
				If DTA->( dbSeek(xFilial("DTA")+DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
					lAdd := .F.
				EndIf

				RecLock("DTA", lAdd)
				DTA->DTA_FILIAL	:=  xFilial("DTA")
				DTA->DTA_FILORI	:=	cFilAnt
				DTA->DTA_VIAGEM	:=	DTQ->DTQ_VIAGEM
				DTA->DTA_FILDOC	:=	DT6->DT6_FILDOC
				DTA->DTA_DOC	:=	DT6->DT6_DOC
				DTA->DTA_SERIE	:=	DT6->DT6_SERIE
				DTA->DTA_QTDVOL	:=	DT6->DT6_QTDVOL
				DTA->DTA_SERTMS	:=	DT6->DT6_SERTMS
				DTA->DTA_TIPTRA	:=	DT6->DT6_TIPTRA
				DTA->DTA_FILATU	:=	cFilAnt
				DTA->DTA_TIPCAR	:=	"2"
				DTA->DTA_FILDCA	:=	cFilAnt
				DTA->DTA_VALFRE	:=	0
				DTA->DTA_CODVEI :=  DA3->DA3_COD

				MsUnlock()

				lAdd := .T. 

				// Cria o Movimento de Viagem
				DUD->( dbSetOrder(1) )
				If DUD->( dbSeek(xFilial("DUD")+DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
					lAdd := .F.
				EndIf

				private  cSerTms := DT6->DT6_SERTMS
				TmsA144DA7(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,DTQ->DTQ_ROTA,@cZona,@cSetor,.F.)

				cSequen := SOMA1(cSequen)

				RecLock("DUD", lAdd)
				DUD->DUD_FILIAL	:= xFilial("DUD")
				DUD->DUD_FILORI	:= cFilAnt
				DUD->DUD_FILDOC	:= DT6->DT6_FILDOC
				DUD->DUD_DOC	:= DT6->DT6_DOC
				DUD->DUD_SERIE	:= DT6->DT6_SERIE
				DUD->DUD_SERTMS	:= DT6->DT6_SERTMS
				DUD->DUD_TIPTRA	:= DT6->DT6_TIPTRA
				DUD->DUD_CDRDES	:= DT6->DT6_CDRDES
				DUD->DUD_VIAGEM	:= DTQ->DTQ_VIAGEM
				DUD->DUD_FILDCA	:= cFilAnt
				DUD->DUD_SEQUEN	:= cSequen
				DUD->DUD_GERROM	:= "1"
				DUD->DUD_SERVIC	:= "018"//DT6->DT6_SERVIC //"018"
				DUD->DUD_CDRCAL	:= DT6->DT6_CDRCAL
				DUD->DUD_ENDERE	:= "0"
				DUD->DUD_STROTA	:= "3"
				DUD->DUD_DOCTRF	:= "2"
				DUD->DUD_ZONA	:= cZona
				DUD->DUD_SETOR	:= cSetor
				DUD->DUD_FILATU	:= cFilAnt
				DUD->DUD_CEPENT	:= Posicione("SA1", 1, xFilial("SA1")+DT6->(DT6_CLIDES + DT6_LOJDES), "A1_CEP")
				DUD->DUD_STATUS	:= "3"
				DUD->DUD_SEQENT := "001"
				DUD->DUD_FILMAN := cFilAnt
				// Informacao do manisfesto
				DUD->DUD_MANIFE := SZN->ZN_MDFE
				DUD->DUD_SERMAN := SZN->ZN_SERIE
				MsUnlock()

				// Historico do Manifesto
				RecLock("DLH", .T.)
				DLH->DLH_FILIAL := xFilial('DLH')
				DLH->DLH_VIAGEM := DUD->DUD_VIAGEM
				DLH->DLH_FILDOC := DUD->DUD_FILDOC
				DLH->DLH_DOC    := DUD->DUD_DOC
				DLH->DLH_SERIE  := DUD->DUD_SERIE
				DLH->DLH_FILMAN := DUD->DUD_FILMAN
				DLH->DLH_MANIFE := DUD->DUD_MANIFE
				DLH->DLH_SERMAN := DUD->DUD_SERMAN
				DLH->DLH_FILORI := DUD->DUD_FILORI
				MsUnlock()

				//Totalizadores para o MDF-e (DTX)
				aVetDoc[1] ++
				aVetDoc[2] += DT6->DT6_VOLORI
				aVetDoc[3] += DT6->DT6_PESO
				aVetDoc[4] += DT6->DT6_PESOM3
				aVetDoc[5] += Max(DT6->DT6_PESO,DT6->DT6_PESOM3)
				aVetDoc[6] += DT6->DT6_VALMER

			Else
				AAdd(aErrMsg,"Não encontrado o CTE na DT6 (" + SZO->ZO_NUMCTE + "/" + SZO->ZO_SERIE + ")") 
				lRet := .f.	
				Return lRet

			End if
			SZO->(DbSkip())
		EndDo
	End If

Return lRet

/*/{Protheus.doc} MDFEValid
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFEValid()	

	Local lRet := .t.

	// Verifica se a integracao sera realizada na empresa correta
	If Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2]) != Alltrim(SZN->ZN_CGCEMIT)
		AAdd(aErrMsg,"A integração deste MDF-e só é permitida na empresa emitente.") 
		lRet := .f.
	End If

	// Verifica se o MDF-e ja foi importado anteriomente.
	If lRet 
		DTX->(DbSetOrder(2))
		//DTX_FILIAL+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN
		If DTX->(DbSeek(xFilial("DTX") + cFilAnt + SZN->(ZN_MDFE + ZN_SERIE)))
			AAdd(aErrMsg,"Este MDF-e ja se encontra integrado no SIGATMS.") 
			lRet := .f.
		End If
	End If

	If lRet 
		DA3->(DbSetOrder(3))
		//DA3_FILIAL+DA3_PLACA
		If !DA3->(DbSeek(xFilial("DA3") + SZN->ZN_PLACA))
			AAdd(aErrMsg,"Não existe Veiculo com a placa: " + SZN->ZN_PLACA + " cadastrado.") 
			lRet := .f.	
		End If

		If !Empty(SZN->ZN_PLARB1) .AND. !DA3->(DbSeek(xFilial("DA3") + SZN->ZN_PLARB1))
			AAdd(aErrMsg,"Não existe Veiculo (reboque) com a placa: " + SZN->ZN_PLARB1 + " cadastrado.") 
			lRet := .f.	
		End If

		If !Empty(SZN->ZN_PLARB2) .AND. !DA3->(DbSeek(xFilial("DA3") + SZN->ZN_PLARB2))
			AAdd(aErrMsg,"Não existe Veiculo (reboque) com a placa: " + SZN->ZN_PLARB2 + " cadastrado.") 
			lRet := .f.	
		End If

		If !Empty(SZN->ZN_PLARB3) .AND. !DA3->(DbSeek(xFilial("DA3") + SZN->ZN_PLARB3))
			AAdd(aErrMsg,"Não existe Veiculo (reboque) com a placa: " + SZN->ZN_PLARB3 + " cadastrado.") 
			lRet := .f.	
		End If

	End IF

	If lRet
		SA2->(DbSetOrder(3))
		//A2_FILIAL+A2_CGC
		If !SA2->(DbSeek(xFilial("SA2") + SZN->ZN_CGCPROP))
			AAdd(aErrMsg,"Não existe Fornecedor(proprietario) cadastrado para este CPF/CNPJ: " + SZN->ZN_CGCPROP + " - " + Alltrim(SZN->ZN_NOMEPRO)) 
			lRet := .f.
		End If
	End If

	If lRet 
		DA4->(DbSetOrder(3))
		//DA4_FILIAL+DA4_CGC
		If !DA4->(DbSeek(xFilial("DA4") + SZN->ZN_CGCMOTO))
			AAdd(aErrMsg,"Não existe Motorista cadastrado para este CPF: " + SZN->ZN_CGCMOTO + " - " + Alltrim(SZN->ZN_NOMEMOT)) 
			lRet := .f.		
		End If
	End If

	SZO->(DbSetOrder(1))
	//ZO_FILIAL+ZO_CHVMDFE
	// Verifica se os conheciimentos de fretes ja foram integrados no ERP.
	If SZO->(DbSeek(xFilial("SZO") + SZN->ZN_CHVMDFE))

		WHILE SZO->(!EOF()) .AND. SZO->(ZO_FILIAL + ZO_CHVMDFE) == xFilial("SZO") + SZN->ZN_CHVMDFE

			cSerie := cValToChar(Val(SZO->ZO_SERIE))

			SFT->(DbSetOrder(6))
			//FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE
			If !SFT->(DbSeek(xFilial("SFT") + "S" + SZO->(ZO_NUMCTE) + cSerie))
				AAdd(aErrMsg,"O Ct-e (" +SZO->ZO_CHVCTE + ") ainda não foi integrado para o SIGATMS.") 
				lRet := .f.
			End If

			SZO->(DbSkip())
		EndDo
	End If

Return lRet


/*/{Protheus.doc} F16LdVia
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cFilOri, characters, description
@param cViagem, characters, description
@param aViagCol, array, description
@type function
/*/
Static Function  F16LdVia(cFilOri,cViagem,aViagCol)
	Local aRet        := {}                 // Recebe o array de retorno 
	Local lRet        := .F.                // Recebe a vaiavel lógca de retorno
	Local aArea       := GetArea()          // Recebe a area atual
	Local aAreaDTQ    := DTQ->(GetArea())   // Recebe a area do DTQ
	Local lExbPerc    := .F.				// Verifica se sempre exibe a tela de percurso
	Local cRegOriMDF  := ""                 // Recebe a Região de Origem do MDF-e existente no cadastro de Rotas
	Local cUfAtu      := ""                 // Recebe o estado de Inicio do percurso
	Local cUFOri      := ""                 // Recebe o estado de origem 
	Local cUfDes      := ""                 // Recebe o estado de destino
	Local cMunAtu     := ""                 // Recebe o municipio de Inicio do percurso
	Local cMunMan     := ""                 //  Recebe o municipio do manifesto 
	Local lPerc       := .F.				// Recebe se a Viagem já possui percurso.
	Local aItens      := {}                 // Recebe os dados do Estado
	Local aEstados    := {}                 // Recebe os Estados
	Local cUfAnt      := ""					// Recebe o Estado anterior
	Local lPrevist    := .F.                // Recebe se é um documento não previsto
	Local nPosEst     := 0                  // Recebe a posição dos estados no Array aEstados
	Local nPosMunic   := 0                  // Recebe a posição dos municipios no array aItens
	Local nPosUfOri   := 0                  // Recebe a posição dos estados de origem no array aIten
	Local nTamEst     := 0                  // Recebe o tamanho do do array de itens
	Local aItmPerc    := {}                 // Recebe os documentos dos trechos do percurso
	Local aCab        := {}                 // Recebe o cabeçalho do percurso de viagem
	Local nOpcPer     := 0                  // Recebe a opção de execução da rotina de percurso
	Local aDelDocs    := {}                 // Recebe os documentos deletados
	Local nCount      := 0                  // Recebe o contador
	Local cRota       := ""                 // Recebe o codigo da rota
	Local lRoteiro    := .F.                // Recebe se a rota é de roteiro
	Local nSequen	  :=  1 
	Local lPercurso	  := SuperGetMv("MV_TMSPERC",.F.,.F.)

	Default cFilOri   := ""                 // Recebe a Filial de Origem da Viagem
	Default cViagem   := ""					// Recebe o código da viagem
	Default aViagCol  := {}                 // Recebe as viagens coligadas

	If !Empty(cFilOri) .AND. !Empty(cViagem)

		// Busca a viagem
		dbSelectArea("DTQ")
		DTQ->(dbSetOrder(2)) //DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA

		If DTQ->( dbSeek( FWxFilial("DTQ") + cFilOri + cViagem  ) )

			// Busca se ja possui percurso pra viagem
			dbSelectArea("DL0")
			DL0->(dbSetOrder(2))//DL0_FILIAL+DL0_FILORI+DL0_VIAGEM+DL0_PERCUR
			lPerc :=  DL0->(dbSeek( FWxFilial("DL0")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))

			If lRoteiro := F11RotRote(DTQ->DTQ_ROTA) //Rota Roteiro
				//......
			Else  // Rota Cep

				//  Verifica se exibe a tela de Percurso com a viagem em Filial de origem.
				Pergunte("TMB144",.F.) 
				If Type("MV_PAR05") != "U"
					lExbPerc  :=  MV_PAR05 == 1
				Else
					lExbPerc := .T.
				EndIf	

				// Pega o Estado de Origem da Rota para geração do MDF-e
				If DTQ->DTQ_STATUS ==  '5' .AND. DA8->(ColumnPos('DA8_CDOMDF')) > 0
					cRegOriMDF := Posicione("DA8",1,xFilial("DA8") + DTQ->DTQ_ROTA ,"DA8_CDOMDF")
					If !Empty(cRegOriMDF)
						cUfAtu   := Posicione("DUY",1,xFilial("DUY") + cRegOriMDF ,"DUY_EST")  
						cMunAtu  := Posicione("DUY",1,xFilial("DUY") + cRegOriMDF ,"DUY_CODMUN")  
					EndIf
				EndIf

				// Caso Estado do MDF-e esteja vazio, pega o Estado da Filial 
				If Empty(cUfAtu)
					cUfAtu  := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_ESTENT") 
					cMunAtu := Substr(Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_CODMUN"),3,5)
				EndIf

				// Prepara o Preenchimento dos Estados
				If !lPerc  // Não Possui Percurso
					// Adiciona o estado de Origem da Filial.	
					AAdd( aItens, { {"DL1_SEQUEN", StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] ) },;
					{"DL1_UF",cUfAtu} ,;
					{"DL1_UFORIG",cUfAtu} ,;
					{"DL1_ORIGEM",Iif( DTQ->DTQ_STATUS == '5',"2","3")} ,; // Caso viagem em aberto ou fechada Origem = 2 -Rota | caso em transito Origem = 3 - Não previsto
					{"DL1_MUNMAN",cMunAtu},;
					{} } ) // Dever ser a ultima posição do Array
					Aadd(aEstados,{cUfAtu,cUfAtu, StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] ) })	
					nSequen++
					cUfAnt := cUfAtu

					//-- Busca Estados da DIQ
					dbSelectArea("DIQ")
					DIQ->(dbSetOrder(1))

					For nCount := 0 To Len(aViagCol)

						If nCount == 0
							cRota := DTQ->DTQ_ROTA
						Else

							If DTQ->( dbSeek( FWxFilial("DTQ") + aViagCol[nCount][1] + aViagCol[nCount][2]  ) ) .AND. cRota != DTQ->DTQ_ROTA
								cRota :=  DTQ->DTQ_ROTA
							Else
								Loop
							EndIf
						EndIf

						DIQ->(dbSeek(FWxFilial("DIQ") + cRota ))
						While DIQ->(!Eof()) .And. DIQ->( DIQ_FILIAL + DIQ_ROTA ) == FWxFilial("DIQ") + cRota
							If  Iif( nCount == 1 , DIQ->DIQ_EST != cUfAnt,  AScan(aEstados, { |a| a[1] == DIQ->DIQ_EST  } ) <= 0 )

								AAdd( aItens, { {"DL1_SEQUEN", 	StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] )  },;
								{"DL1_UF",		DIQ->DIQ_EST} 	,;
								{"DL1_UFORIG",	cUfAtu} 		,;
								{"DL1_ORIGEM",	"4"} 			,; 	//-- 4=Percurso MDF-e
								{"DL1_MUNMAN", 	cMunAtu}		,;
								{} } ) 								//-- Dever ser a ultima posição do Array

								Aadd(aEstados,{DIQ->DIQ_EST,cUfAtu,  StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] ) })				
								cUfAnt := DIQ->DIQ_EST
								nSequen++

							EndIf	
							DIQ->(dbSkip())
						EndDo
					Next nCount

					// Reposiciona na viagem principal
					DTQ->( dbSeek( FWxFilial("DTQ") + cFilOri + cViagem  ) )

				Else  // Já Possui percurso.
					dbSelectArea("DL0")
					DL0->(dbSetOrder(2))
					If DL0->(MsSeek( FWxFilial("DL0")+ cFilOri + cViagem ))
						DL0->(MsSeek( FWxFilial("DL0")+ cFilOri + cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
						DL0->(DbSkip(-1))

						dbSelectArea("DL1")
						DL1->(dbSetOrder(5))
						DL1->(dbSeek(FWxFilial("DL1") + DL0->DL0_PERCUR))
						While DL1->(!Eof()) .And. DL1->DL1_FILIAL + DL1->DL1_PERCUR == FWxFilial("DL1") + DL0->DL0_PERCUR 
							AAdd( aItens, { {"DL1_SEQUEN", DL1->DL1_SEQUEN},;
							{"DL1_UF",		DL1->DL1_UF} ,;
							{"DL1_UFORIG",	DL1->DL1_UFORIG} ,;
							{"DL1_ORIGEM",	DL1->DL1_ORIGEM} ,; // Origem - Rota
							{"DL1_MUNMAN", 	DL1->DL1_MUNMAN },;
							{} } ) // Dever ser a ultima posição do Array

							Aadd(aEstados,{DL1->DL1_UF,DL1->DL1_UFORIG,DL1->DL1_SEQUEN})		
							DL1->(dbSkip())		
						EndDo

						// Busca diferenças de documentos do percurso
						aDelDocs := F16DocDel(cFilOri, cViagem, DL0->DL0_PERCUR)

					EndIf
				EndIf

				dbSelectArea("DT6")
				DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE

				dbSelectArea("DUE")
				DUE->(dbSetOrder(1)) //DUE_FILIAL+DUE_CODSOL

				dbSelectArea("DUL")
				DUL->(dbSetOrder(3)) //DUL_FILIAL+DUL_CODSOL+DUL_SEQEND

				dbSelectArea("DT5")
				DT5->(dbSetOrder(4)) //DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE

				For nCount := 0 To Len(aViagCol)

					If nCount > 0
						If DTQ->( dbSeek( FWxFilial("DTQ") + aViagCol[nCount][1] + aViagCol[nCount][2]  ) ) .AND. cFilOri + cViagem == DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
							Loop
						EndIf
					EndIf

					// Busca os documentos da viagem
					dbSelectArea("DUD") 
					DUD->(dbSetOrder(2)) //DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
					If DUD->( dbSeek( FWxFilial("DUD")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ) )

						While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM  == FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM 

							If DT6->(dbSeek( FWxFilial("DT6") + DUD->DUD_FIlDOC + DUD->DUD_DOC + DUD->DUD_SERIE ))

								If Empty(DUD->DUD_DTRNPR) // Documento previsto
									cUFOri  := cUfAtu

									If DT6->DT6_SERTMS == '2'
										cUfDes	:=  Posicione("SM0",1,cEmpAnt+DUD->DUD_FILDCA,"M0_ESTENT")
									Else
										cUfDes  := Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_EST')
									EndIf

									If Empty(cUfDes)

										If DT6->DT6_SERTMS == '1' //Coleta 

											If DT5->(dbSeek(FwxFilial('DT5')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))

												If Empty(DT5->DT5_SEQEND) //Sem Sequencia de endereço
													//-- Posiciona no solicitante
													If DUE->(dbSeek(FwxFilial('DUE')+DT5->DT5_CODSOL))
														cUfDes := DUE->DUE_EST
													EndIf
												Else //Com Sequencia de endereço
													// Posiciona na sequencia
													If DUL->(MsSeek(FwxFilial('DUL')+DT5->(DT5_CODSOL+DT5_SEQEND)))
														cUfDes := DUL->DUL_EST
													EndIf
												EndIf
											EndIf
										EndIf

									EndIf

									cMunMan  := cMunAtu

									lPrevist := .T. // Marca como documento Previsto

								Else // Documento não previsto

									lPrevist := .F.	 // Marca como documento Não Previsto

									If DT6->DT6_SERTMS == '2'
										cUfDes	:=  Posicione("SM0",1,cEmpAnt+DUD->DUD_FILDCA,"M0_ESTENT")
									Else
										cUfDes  := Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_EST')
									EndIf

									cUFOri  := Posicione("DUY",1,xFilial("DUY") + DT6->DT6_CDRORI ,"DUY_EST")
									cMunMan := Posicione("DUY",1,xFilial("DUY") + DT6->DT6_CDRORI ,"DUY_CODMUN")
								EndIf

								// Adiciona o estado no array, caso o mesmo não exita
								If (nPosEst := AScan(aEstados, { |a| a[1] == cUfDes .AND. Iif( !lPrevist, a[3] > STRZERO(1,2),.T.) } ) ) <= 0

									AAdd( aItens, { {"DL1_SEQUEN",STRZERO(Len(aEstados)+1,2)},;
									{"DL1_UF",cUfDes} ,;
									{"DL1_UFORIG",cUFOri} ,;
									{"DL1_ORIGEM",Iif( DTQ->DTQ_STATUS == '5',"2","3")} ,; // Caso viagem em aberto ou fechada  Origem = 2 -Rota | caso em transito Origem = 3 - Não previsto
									{"DL1_MUNMAN", cMunMan },;
									{} } ) // Dever ser a ultima posição do Array

									Aadd(aEstados,{cUfDes,cUFOri,STRZERO(Len(aEstados)+1,2)})		
									nPosEst := AScan(aEstados, { |a| a[1] == cUfDes .AND. Iif(!lPrevist,  a[3] > STRZERO(1,2),.T.) } ) 
									lExbPerc := .f.
								Else // Caso ja exista manipula o estado de origem e o municipio
									nPosMunic := aScan(aItens[nPosEst],{|x| AllTrim(x[1]) == "DL1_MUNMAN"}) 
									nPosUfOri := aScan(aItens[nPosEst],{|x| AllTrim(x[1]) == "DL1_UFORIG"})  
									aItens[nPosEst][nPosMunic][2] := cMunMan
									aItens[nPosEst][nPosUfOri][2] := cUFOri
								EndIf

								nTamEst := Len(aItens[nPosEst])
								aItmPerc := {}

								// Preenche o array de documentos validos.
								Aadd(aItmPerc,{"DL2_FILORI", DTQ->DTQ_FILORI })
								Aadd(aItmPerc,{"DL2_VIAGEM", DTQ->DTQ_VIAGEM })
								Aadd(aItmPerc,{"DL2_FILDOC", DT6->DT6_FILDOC })
								Aadd(aItmPerc,{"DL2_DOC"   , DT6->DT6_DOC    })
								Aadd(aItmPerc,{"DL2_SERIE" , DT6->DT6_SERIE  })
								Aadd(aItmPerc,{"DL2_CLIREM", DT6->DT6_CLIREM })
								Aadd(aItmPerc,{"DL2_LOJREM", DT6->DT6_LOJREM })
								Aadd(aItmPerc,{"DL2_CLIDES", DT6->DT6_CLIDES })
								Aadd(aItmPerc,{"DL2_LOJDES", DT6->DT6_LOJDES })
								Aadd(aItmPerc,{"DL2_MUNMAN", cMunMan })


								Aadd(aItens[nPosEst][nTamEst],aItmPerc)

							EndIf

							DUD->(dbSkip())		
						EndDo

					EndIf
				Next nCount
			EndIf

			If Len(aItens) > 0
				Aadd(aCab,{"DL0_FILORI",cFilOri})
				Aadd(aCab,{"DL0_VIAGEM",cViagem})

				// Montar Tela
				dbSelectArea("DL0")
				DL0->(dbSetOrder(2))
				If lRoteiro
					nOpcPer := 3
					// Não exibe a tela de Percurso quando for rota de Roteiro.
					lExbPerc := .F.
				ElseIf lPerc
					DL0->(MsSeek( FWxFilial("DL0")+cFilOri+cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
					DL0->(DbSkip(-1))
					If DTQ->DTQ_STATUS == '5' // Status fechado
						nOpcPer := 4
						Aadd(aCab,{"DL0_PERCUR",DL0->DL0_PERCUR})
					Else
						nOpcPer := 4
						lExbPerc := .T.
					EndIf
				Else	
					nOpcPer := 3
				EndIf

				If !lPercurso .AND. DTQ->DTQ_STATUS $ "1,5" //1-Em Aberto; 5-Fechada.
					lExbPerc := .F.
				EndIf

				//-- Chama a rotina de processamento de percurso
				aRet := AF16IncPer(nOpcPer,aCab,aItens,!lExbPerc,aDelDocs)
				lRet := aRet[1]
			EndIf

		EndIf

	EndIf

	RestArea(aAreaDTQ)
	RestArea(aArea)
Return lRet