#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"
#include "TOTVS.CH"


/*/{Protheus.doc} FA050DEL
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function FA050DEL()

	Local lRet := .t.
	Local cBkpFuname := Funname()

	// Verifica se este titulo possui integracao
	If !Empty(SE2->E2_YTABORI) .and. !Empty(SE2->E2_YIDORIG)

		// Muda o nome da funcao para excluir
		// a baixa do CMV - Contas a Pagar ou Funcoes contas a pagar
		If Alltrim(cBkpFuname) $ "FINA050/FINA750"
			SetFunname("FINA050")
		End If

		// Verifica se veio do CMV
		If SE2->E2_YTABORI == "SZ2"

			// Verifica se consegue excluir a baixa do CMV.	
			FWMsgRun(, {|| lRet := SZ2DEL() }		, "Processando", "FA050DEL - Estornando Baixa do CMV....")

			IF !lRet
				Return .f.
				SetFunname(cBkpFuname)
			End If

			// Verifica se veio do capital social
		ElseIf 	SE2->E2_YTABORI == "SZ3"

			// Verifica se consegue excluir a baixa do CMV.	
			FWMsgRun(, {|| lRet := SZ3DEL() }		, "Processando", "FA050DEL - Estornando Capital Social....")

			IF !lRet
				Return .f.
				SetFunname(cBkpFuname)
			End If

		End If

		// Devolve 
		SetFunname(cBkpFuname)
	End If

return lRet


/*/{Protheus.doc} SZ3DEL
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SZ3DEL()

	Local oModel	:= Nil
	Local oModelSZ3 := Nil
	Local cErro		:= ""
	Local lRet		:= .t.

	//Z3_IDMOV
	SZ3->(DbSetOrder(3))
	SA2->(DbSetOrder(1))

	// Localiza baixa do CMV
	If SZ3->(DbSeek(SE2->E2_YIDORIG))
	
		// Localiza o codigo do autonomo atraves do codigo do fornecedor	
		SA2->(Dbseek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
		
		// Instancia o modelo de dados
		oModel := FWLoadModel("SERGPE02") 

		// Realiza alteração do movimento.
		oModel:SetOperation(MODEL_OPERATION_UPDATE)

		// Verifica se conseguiu ativar o modelo
		if !oModel:Activate()
			// Verifica o motivo de não ativação do modelo
			If oModel:HasErrorMessage() 
				// Recupera o erro
				cErro := GetErroModel(oModel)
				Help(NIL, NIL, "FA050DEL - SZ3DEL(Activate)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
				Return .f. 
			End If 
		End if 

		// Recupera o modelo de baixa
		oModelSZ3:= oModel:GetModel("SZ3DETAIL")

		// Busca o registro
		If oModelSZ3:SeekLine({{"Z3_IDMOV",SE2->E2_YIDORIG}})

			// Verifica se consegue deletar o registro
			If oModelSZ3:DeleteLine()

				// Verifica validacao
				If oModel:VldData()

					// Verifica o Commit
					If !oModel:CommitData()
						cErro:= GetErroModel(oModel)
						Help(NIL, NIL, "FA050DEL - SZ3DEL(CommitData)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})		
						Return .f. 
					End if 

				Else 
					cErro:= GetErroModel(oModel)
					Help(NIL, NIL, "FA050DEL - SZ3DEL(VldData)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})		
					Return .f. 
				EndIf

			Else
				// Verifica o motivo de nao conseguir deletar a baixa
				If oModel:HasErrorMessage() 
					// Recupera o erro
					cErro := GetErroModel(oModel)
					Help(NIL, NIL, "FA050DEL - SZ3DEL(DeleteLine)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					Return .f. 
				End If 
			End If
		End IF
	Else
		cErro:= "Nao foi possivel localizar a baixa na tabela SZ2."
		Help(NIL, NIL, "FA050DEL - DbSeek", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
		Return .f.
	End iF
	
Return lRet


/*/{Protheus.doc} SZ2DEL
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SZ2DEL()

	Local oModel	:= Nil
	Local oModelSZ2 := Nil
	Local cErro		:= ""
	Local lRet		:= .t.

	SZ2->(DbSetOrder(2))

	// Localiza baixa do CMV
	If SZ2->(DbSeek(xFilial("SZ2") + SE2->E2_YIDORIG))

		// Posiciona no Cabecalho Z1_FILIAL, Z1_FORNECE, Z1_LOJA, Z1_NUM, Z1_PARCELA, R_E_C_N_O_, D_E_L_E_T_
		SZ1->(DbSetOrder(1))
		If !SZ1->(DbSeek(xFilial("SZ1") + SZ2->(Z2_FORNECE + Z2_LOJA + Z2_NUM + Z2_PARCELA)))
			cErro := "Não foi possível localizar o CMV na SZ1 com esta chave: " + xFilial("SZ1") + SZ2->(Z2_FORNECE + Z2_LOJA + Z2_NUM + Z2_PARCELA)
			Help(NIL, NIL, "FA050DEL - SZ2DEL(Activate)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
			Return .f. 
		End If
		
		// Instancia o modelo de dados
		oModel := FWLoadModel("SERGPE01") 

		// Realiza alteração do movimento.
		oModel:SetOperation(MODEL_OPERATION_UPDATE)

		// Verifica se conseguiu ativar o modelo
		if !oModel:Activate()

			// Verifica o motivo de não ativação do modelo
			If oModel:HasErrorMessage() 
				// Recupera o erro
				cErro := GetErroModel(oModel)
				Help(NIL, NIL, "FA050DEL - SZ2DEL(Activate)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
				Return .f. 
			End If 

		End if 

		// Recupera o modelo de baixa
		oModelSZ2:= oModel:GetModel("SZ2DETAIL")

		// Busca a baixa do CMV
		If oModelSZ2:SeekLine({{"Z2_IDMOV",SE2->E2_YIDORIG}})

			// Verifica se consegue deletar a baixa do CMV
			If oModelSZ2:DeleteLine()

				// Verifica validacao
				If oModel:VldData()

					// Verifica o Commit
					If !oModel:CommitData()
						cErro:= GetErroModel(oModel)
						Help(NIL, NIL, "FA050DEL - SZ2DEL(CommitData)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})		
						Return .f. 
					End if 

				Else 
					cErro:= GetErroModel(oModel)
					Help(NIL, NIL, "FA050DEL - SZ2DEL(VldData)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})		
					Return .f. 
				EndIf

			Else
				// Verifica o motivo de nao conseguir deletar a baixa
				If oModel:HasErrorMessage() 
					// Recupera o erro
					cErro := GetErroModel(oModel)
					Help(NIL, NIL, "FA050DEL - SZ2DEL(DeleteLine)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					Return .f. 
				End If 

			End If
		Else
			cErro:= "Nao foi possivel localizar a baixa no modelo de dados."
			Help(NIL, NIL, "FA050DEL - SZ2DEL(SeekLine)", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
			Return .f.
		End If 

	Else
		cErro:= "Nao foi possivel localizar a baixa na tabela SZ2."
		Help(NIL, NIL, "FA050DEL - DbSeek", NIL, cErro ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
		Return .f.
	End If

Return lRet

/*/{Protheus.doc} GetErroModel
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
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