#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} CNTA121
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CNTA121()

	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid := .F.
	Local nLinha := 0
	Local nQtdLinhas := 0
	Local cMsg := ""

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "MODELVLDACTIVE"
			
		ElseIf cIdPonto == "MODELPOS"			

			xRet := .T.

		ElseIf cIdPonto == "FORMPOS"
			cMsg := "Chamada na validação total do formulário." + CRLF
			cMsg += "ID " + cIdModel + CRLF

			If lIsGrid
				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
			Else
				cMsg += "É um FORMFIELD" + CRLF
			EndIf

			xRet := .T.

		ElseIf cIdPonto == "FORMLINEPRE"
			If aParam[5] == "DELETE"
				cMsg := "Chamada na pré validação da linha do formulário. " + CRLF
				cMsg += "Onde esta se tentando deletar a linha" + CRLF
				cMsg += "ID " + cIdModel + CRLF
				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
				xRet := .T. //ApMsgYesNo(cMsg + " Continua?")
			EndIf

		ElseIf cIdPonto == "FORMLINEPOS"
			cMsg := "Chamada na validação da linha do formulário." + CRLF
			cMsg += "ID " + cIdModel + CRLF
			cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
			cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
			xRet := .T.
			
		ElseIf cIdPonto == "MODELCOMMITTTS"
			//ApMsgInfo("Chamada após a gravação total do modelo e dentro da transação.")
			// Trata o numero do pedido de venda. 
			xRet:= AtuCXJ()

		ElseIf cIdPonto == "MODELCOMMITNTTS"
			//ApMsgInfo("Chamada após a gravação total do modelo e fora da transação.")

		ElseIf cIdPonto == "FORMCOMMITTTSPRE"
			//ApMsgInfo("Chamada após a gravação da tabela do formulário.")

		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			//ApMsgInfo("Chamada após a gravação da tabela do formulário.")

		ElseIf cIdPonto == "MODELCANCEL"
			cMsg := "Deseja realmente sair?"
			xRet := .T.

		ElseIf cIdPonto == "BUTTONBAR"
			xRet := {} //{{"Salvar", "SALVAR", {||u_TSMT030()}}}

			aAdd(xRet,{"Preencher Qtd.", "" , {|| u_ModfCNE()} } )

		EndIf
	EndIf
Return xRet

/*/{Protheus.doc} AtuCXJ
Tratamento para preencher o numero do pedido, alguns produtos da medicao do contrato
estao ficando sem o numero do pedido, devido que quando passa no ponto de entrada
CN121PED o sistema aglutina em um unico produto para emitir a nota fscal. E para realizar
o estorno do encerramento deve possui o numero do pedido em todos os itens.
@author Totvs Vitoria - Mauricio Silva
@since 13/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AtuCXJ()

	Local lRet	:= .t.
	Local cAliasCXJ := GetNextAlias()

	// Verifica se aglutina os produtos do pedido de venda
	If CND->CND_YAGLUT != "S"
		Return .t.
	End If

	// Busca o encerramento que possui item do pedido mas nao possui o numero.
	BeginSQL Alias cAliasCXJ

		SELECT CXJ_NUMPED,CXJ_CONTRA,CXJ_NUMMED,CXJ_NUMPLA FROM %Table:CXJ% CXJ (NOLOCK)
		WHERE CXJ.D_E_L_E_T_ =''
		AND CXJ.CXJ_CONTRA = %Exp:CND->CND_CONTRA%
		AND CXJ.CXJ_NUMMED = %Exp:CND->CND_NUMMED%
		AND CXJ_ITEMPE <> ''
		AND CXJ_NUMPED <> ''

		GROUP BY CXJ_NUMPED,CXJ_CONTRA,CXJ_NUMMED,CXJ_NUMPLA
	EndSql

	While(cAliasCXJ)->(!EOF())

		CXJ->(DbsetOrder(1))
		//CXJ_FILIAL, CXJ_CONTRA, CXJ_NUMMED, CXJ_NUMPLA, CXJ_ITEMPL, CXJ_PRTENV, CXJ_ID, R_E_C_N_O_, D_E_L_E_T_
		If CXJ->(DbSeek(xFilial("CXJ") + (cAliasCXJ)->(CXJ_CONTRA + CXJ_NUMMED + CXJ_NUMPLA)))

			While CXJ->(!EOF()) .AND. CXJ->(CXJ_FILIAL + CXJ_CONTRA + CXJ_NUMMED + CXJ_NUMPLA) == xFilial("CXJ") + (cAliasCXJ)->(CXJ_CONTRA + CXJ_NUMMED + CXJ_NUMPLA)

				If Empty(CXJ->CXJ_NUMPED) .and. !Empty(CXJ->CXJ_ITEMPE)

					RecLock("CXJ", .F.)	
					CXJ->CXJ_NUMPED := (cAliasCXJ)->CXJ_NUMPED
					MsUnLock()	

				End If

				CXJ->(DbSkip())
			EndDo
		End IF

		(cAliasCXJ)->(DbSkip())
	EndDo

Return lRet

/*/{Protheus.doc} ModfCNE
Atualiza a quantidade padroa para todas
as planilha da medicao de contrato
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ModfCNE()

	Local oModel := FwModelActive()
	Local oModelCND	:= oModel:GetModel("CNDMASTER")
	Local nQtd		:= 0.00
	Local aPergs	:= {}
	Local lRet		:= .t.
	Local aRet		:= {}
	Local cMasc		:=  X3Picture("CNE_QUANT")

	// Verifica se existe contrato informado.
	If Empty(oModelCND:GetValue("CND_CONTRA"))
		cMsg  := "Favor escolher o contrato p/ medição primeiro."
		cSolu := ""
		Help(NIL, NIL, "VldVlr", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End if

	aAdd( aPergs ,{1,"Quantidade",nQtd,cMasc,'.T.','','.T.',TAMSX3("CNE_QUANT")[1] * 5,.t.})

	lRet := ParamBox(aPergs ,"Quant. padrão",aRet)

	If !lRet
		Return
	End if

	FWMsgRun(, {|| AtuzCNE(aRet[1]) }, "Processando", "Processando a atualização...")

Return

/*/{Protheus.doc} AtuzCNE
Atualiza o model de daods com a quantidade
escolhida.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param nQtd, numeric, description
@type function
/*/
Static Function AtuzCNE(nQtd)

	Local oModel := FwModelActive()
	Local oView	 := FwViewActive()
	Local oModelCXN	:= oModel:GetModel("CXNDETAIL")
	Local oModelCNE	:= oModel:GetModel("CNEDETAIL")
	Local nTotReg	:= oModelCXN:Length()
	Local nTotCNE	:= 0
	Local i			:= 0
	Local y			:= 0

	// Verifica se existe planilha no modelo
	If !oModelCXN:IsEmpty()

		For i:= 1 to nTotReg

			oModelCXN:Goline(i)

			If oModelCXN:SetValue("CXN_CHECK",.T.)

				nTotCNE := oModelCNE:Length()

				For y:= 1 to nTotCNE

					oModelCNE:Goline(y)
					oModelCNE:SetValue("CNE_QUANT",nQtd)
				Next

			End iF
		Next
	End If

	oView:Refresh()
Return


/*/{Protheus.doc} CNTAGAT
Funcao utilizada no gatilho do campo CNE_PRODUT
@author mauricio.santos
@since 13/05/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CNTAGAT1()

	Local oModel 	:= FwModelActive()
	Local oModelCXN	:= oModel:GetModel("CXNDETAIL")
	Local oModelCND	:= oModel:GetModel("CNDMASTER")
	Local oModelCNE	:= oModel:GetModel("CNEDETAIL")
	Local cAliasCNB := GetNextAlias()

	Local cContrato := oModelCND:GetValue("CND_CONTRA")
	Local cPlanilha := oModelCXN:GetValue("CXN_NUMPLA")
	Local cItem		:= oModelCNE:GetValue("CNE_ITEM")
	Local cProduto	:= oModelCNE:GetValue("CNE_PRODUT") 
	Local cObs		:= ""

	BEGINSQL Alias cAliasCNB

		SELECT CNB.CNB_YOBS FROM %Table:CNB% CNB
		WHERE CNB.CNB_CONTRA = %Exp:cContrato%
		AND  CNB.CNB_NUMERO = %Exp:cPlanilha%
		AND CNB.CNB_ITEM = %Exp:cItem%
		AND CNB.CNB_PRODUT = %Exp:cProduto%
		AND CNB.CNB_FILIAL = %Exp:xFilial("CNB")%
		AND CNB.D_E_L_E_T_ =''

	ENDSQL

	cObs := SUBSTR((cAliasCNB)->CNB_YOBS,1,TamSx3("CNE_YOBS")[1])

	(cAliasCNB)->(DbCloseArea())

Return cObs


User Function GetNomMed()

	Local oModel 	:= FwModelActive()
	Local oModelCXN	:= oModel:GetModel("CXNDETAIL")
	Local nTotRef	:= oModelCXN:Length()
	Local i			:= 0
	
	For i:= 1 to nTotRef
		
		oModelCXN:GoLine(i)
		oModelCXN:LoadValue("CXN_NOME",U_CNTAGAT2())
		
		If i == nTotRef
			oModelCXN:GoLine(1)
		End If
	Next
	
Return

/*/{Protheus.doc} CNTAGAT2
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/05/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CNTAGAT2()

	Local oModel 	:= FwModelActive()
	Local oModelCXN	:= oModel:GetModel("CXNDETAIL")
	Local oModelCND	:= oModel:GetModel("CNDMASTER")
	Local oModelCNE	:= oModel:GetModel("CNEDETAIL")
	Local cAliasCNA := GetNextAlias()

	Local cContrato := oModelCND:GetValue("CND_CONTRA")
	Local cPlanilha := oModelCXN:GetValue("CXN_NUMPLA")
	Local cNome		:= ""

	BEGINSQL Alias cAliasCNA

		SELECT ISNULL(SA1.A1_NOME,SA2.A2_NOME) AS NOME FROM %Table:CNA% CNA

		LEFT JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %Exp:xFilial("SA1")%
		AND SA1.A1_COD = CNA.CNA_CLIENT
		AND SA1.A1_LOJA = CNA.CNA_LOJACL
		AND SA1.D_E_L_E_T_ = ''


		LEFT JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:%xFilial("SA2")%
		AND SA2.A2_COD = CNA.CNA_FORNEC
		AND SA2.A2_LOJA = CNA.CNA_LJFORN
		AND SA2.D_E_L_E_T_ = ''

		WHERE CNA.CNA_CONTRA = %Exp:cContrato%
		AND CNA.CNA_NUMERO = %Exp:cPlanilha%
		AND CNA.CNA_FILIAL = %Exp:xFilial("CNA")%
		AND CNA.D_E_L_E_T_=''
		

	ENDSQL

	cNome := (cAliasCNA)->NOME
	(cAliasCNA)->(DbCloseArea())

Return cNome