#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} SERGPE07
Recalcular comissao por tabela.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERGPE07()

	Local aPergs := {}
	Local aRet	 := {}
	
	aAdd( aPergs ,{1,"Data De"    ,FirstDate(ddatabase), PesqPict("SE1", "E1_EMISSAO"),'.T.',"" ,'.T.', 60, .T.})
	aAdd( aPergs ,{1,"Data Ate"   ,LastDate(ddatabase) , PesqPict("SE1", "E1_EMISSAO"),'.T.',"" ,'.T.', 60, .T.})	

	lRet := ParamBox(aPergs ,"Recalcular Comissão por tabela. ",aRet)
	
	If lRet 
		Processa({||u_RefComTab(aRet[1],aRet[2])}, "Realizando o Recálculo Comissão")
	End iF
	
return

/*/{Protheus.doc} RefComTab
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param dDTINI, date, description
@param dDTFIM, date, description
@type function
/*/
User Function RefComTab(dDTINI,dDTFIM)
	
	Local cAliasSE3 := GetNextAlias()
	Local nPComis := 0

	// Localiza os vendedores que possui uma tabela de comissao
	// por faixa.

	BeginSql Alias cAliasSE3

		SELECT 
		
		SE3.E3_VEND
		,SA3.A3_NOME
		,SA3.A3_YTABCOM
		,SUM(SE3.E3_BASE) AS E3_BASE 
		
		FROM %Table:SE3% SE3
		
		JOIN %Table:SA3% SA3 ON SA3.A3_FILIAL =  %Exp:xFilial('SA3')%
		AND SA3.D_E_L_E_T_ =''
		AND SA3.A3_COD = SE3.E3_VEND
		
		WHERE SE3.D_E_L_E_T_ =''
		AND SE3.E3_FILIAL = %Exp:xFilial('SE3')%
		AND SA3.A3_YTABCOM <> ''
		AND SE3.E3_EMISSAO BETWEEN %Exp:DTOS(dDTINI)% AND %Exp:DTOS(dDTFIM)%
		AND SE3.E3_DATA = ''
		
		GROUP BY SE3.E3_VEND,SA3.A3_NOME,SA3.A3_YTABCOM
		
	EndSql
	
	While (cAliasSE3)->(!EOF())
		
		IncProc((cAliasSE3)->A3_NOME)
		
		// Recupera a comissao
		nPComis := RetComis( (cAliasSE3)->E3_BASE,(cAliasSE3)->A3_YTABCOM )
		
		// Atualiza o percentual de comissao para todo SE3	
		AtuComis(nPComis,(cAliasSE3)->E3_VEND,dDTINI,dDTFIM)

		(cAliasSE3)->(DbSkip())
	EndDo

	(cAliasSE3)->(DbCloseArea())

Return

/*/{Protheus.doc} RetComis
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cBase, characters, description
@param cTabela, characters, description
@type function
/*/
Static Function RetComis(cBase,cTabela)
	
	Local nPComis	:= 0
	Local lTabela	:= .f.
	Local aTabela	:= {}
	Local i			:= 0
	
	SZ7->(DbSetOrder(1))
	If SZ7->(DbSeek(xFilial("SZ7") + cTabela))
		
		//Localiza a faixa de comissao
		While SZ7->(!EOF()) .AND. Alltrim(SZ7->Z7_CODTAB) == Alltrim(cTabela)
			AADD(aTabela,{SZ7->Z7_VALOR,SZ7->Z7_PERCCOM})
			SZ7->(DbSkip())
		EndDo
		
		For i:= 1 to len(aTabela)
			If !lTabela
				If cBase <= aTabela[i][1] .or. i = Len(aTabela)
					nPComis := aTabela[i][2]
					lTabela:=.T.
				End If
			End if
		Next
	End if

Return nPComis

/*/{Protheus.doc} AtuComis
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nPComis, numeric, description
@param cCodVend, characters, description
@param dDTINI, date, description
@param dDTFIM, date, description
@type function
/*/
Static Function AtuComis(nPComis,cCodVend,dDTINI,dDTFIM)

	Local cAliasCom	:= GetNextAlias()
	
	If SELECT(cAliasCom) > 0
		(cAliasCom)->(DbCloseArea())
	End if
	
	BeginSql Alias cAliasCom
	
		SELECT 
			SE3.R_E_C_N_O_ AS SE3RECNO
		FROM %Table:SE3% SE3

		WHERE SE3.D_E_L_E_T_ =''
		AND SE3.E3_FILIAL = %Exp:xFilial('SE3')%
		AND SE3.E3_EMISSAO BETWEEN %Exp:DTOS(dDTINI)% AND %Exp:DTOS(dDTFIM)%
		AND SE3.E3_DATA = ''
		AND SE3.E3_VEND = %Exp:cCodVend%
	
	EndSQL
	
	SE3->(DbSetOrder(1))

	While(cAliasCom)->(!EOF())
	
		SE3->(DbGoto((cAliasCom)->SE3RECNO))
		
		Reclock("SE3",.F.)			
			SE3->E3_PORC := nPComis
			SE3->E3_COMIS := (nPComis/100) * SE3->E3_BASE
		
		SE3->(MsUnLock())
		
		(cAliasCom)->(DbSkip())
	EndDO
	
	(cAliasCom)->(DbCloseArea())

Return


