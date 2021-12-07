#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:

DESC:   Transferência de CMV

AUTOR:  Maycon Anohleti Bianchine - Totvs Leste
*/

User Function SERAGR03(nOpcao)

	Local aParBox := {}
	Local aRetBox := {}
	Local cCodFor := SZ1->Z1_FORNECE
	Local cCodLoj := SZ1->Z1_LOJA
	Local cCodVei := SZ1->Z1_CODVEI
	Local cCodDesp:= SZ1->Z1_CODDESP
	Local cMsg

	If nOpcao == 3 //Inclusão de Transferência

		aAdd(aParBox, {1, "Transf. p/ Fornecedor", cCodFor ,"","","SA2",".T.", 80,.T.})
		aAdd(aParBox, {1, "Transf. p/ Loja"      , cCodLoj ,"","",   "",".T.", 02,.T.})
		aAdd(aParBox, {1, "Transf. p/ Veiculo"   , cCodVei ,"","","DA3",".T.", 80,.F.})
		aAdd(aParBox, {1, "Transf. p/ Despesa"   , cCodDesp,"","","DT7",".T.", 80,.T.})

		If ParamBox(aParBox, "Transferência de CMV: " + SZ1->Z1_NUM, aRetBox)

			If SZ1->Z1_VALOR == SZ1->Z1_SALDO

				If SZ1->Z1_PREFIX != "AGR"

					FWMsgRun(, {|| TransCMV(aRetBox)}, "Transferência de CMV", "Transferindo CMV...")

				Else

					cMsg := "Não Será Possivel Relizar a Transferência deste CMV." + CRLF
					cMsg += "Motivo: CMV Agrupado, Favor Desfazer o Agrupamento."
					MsgStop(cMsg, "Atenção")

				EndIf

			Else

				cMsg := "Não Será Possivel Relizar a Transferência deste CMV." + CRLF
				cMsg += "Motivo: CMV ja Baixado ou Parcialmente Baixado."
				MsgStop(cMsg, "Atenção")

			EndIf

		EndIf

	ElseIf nOpcao == 5 //Estorno

		If SZ1->Z1_PREFIX == "TRA"

			If SZ1->Z1_VALOR == SZ1->Z1_SALDO

				If MsgYesNo("Deseja Realmente Realizar Estorno Desta Transferência?", "Atenção")

					FWMsgRun(, {|| EstTrans()}, "Estorno Transferência", "Estornando Transferência...")

				EndIf

			Else

				cMsg := "Não Será Possivel Relizar Estorno Desta Transferência." + CRLF
				cMsg += "Motivo: Agrupamento Baixado ou Parcialmente Baixado."
				MsgStop(cMsg, "Atenção")

			EndIf

		EndIf

	EndIf

Return


//===============================
//Realiza Transferência do CMV	=
//===============================
Static Function TransCMV(aRetBox)

	Local aFields   := {}
	Local aCopia	:= {}
	Local i
	Local nRecnoOri := SZ1->(Recno())
	Local lOK 		:= .T.
	Local cHist     := ""
	Local oModelCMV
	Local oModelSZ1
	Local oModelSZ2
	Local cIdMov
	Local lValid
	Local cErro
	Local cMsg
	Local cSolu
	Local cZ1_NUM
	Local nRecnoNew

	aEval(ApBuildHeader("SZ1", Nil), {|x| aAdd(aFields, AllTrim(x[2]) )})

	For i := 1 To Len(aFields)

		If !(aFields[i] $ "Z1_NOMFORN/Z1_DESPESA/Z1_DESVEI")

			aAdd(aCopia, {"SZ1->" + aFields[i], &("SZ1->" + aFields[i])})

		EndIf

	Next i

	BEGIN TRANSACTION

		//Baixa o CMV Origem - Transferência
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

				Return

			EndIf

		EndIf

		// Recupera o modelos de dados inferiores
		oModelSZ1 := oModelCMV:GetModel("SZ1MASTER")
		oModelSZ2 := oModelCMV:GetModel("SZ2DETAIL")

		// Verifica se o registro possui alguma baixa
		If !oModelSZ2:IsEmpty()
			// Adiciona uma linha no modelo.
			oModelSZ2:AddLine()
		EndIf

		// Recupera o valor do saldo em aberto
		nSaldo := oModelSZ1:GetValue("Z1_SALDO")

		// Inclua a baixa do CMV
		lValid := .T.
		If lValid
			lValid := oModelSZ2:SetValue("Z2_VALOR", oModelSZ1:GetValue("Z1_SALDO"))
		EndIf

		If lValid
			lValid := oModelSZ2:SetValue("Z2_HISTOR", "Baixa por Transferência")
		EndIf

		If lValid
			lValid := oModelSZ2:SetValue("Z2_TIPMOV", "A")
		EndIf

		If lValid
			// Informa que foi integrado no Financeiro CP, sendo assim, somente
			// o financeiro pode excluir tal baixa. Ponto de Entrada FA050DEL
			lValid := oModelSZ2:SetValue("Z2_ROTINA", "SERAGR03")
		EndIf

		// Verifica o motivo de não ativação do modelo
		If oModelCMV:HasErrorMessage() .AND. !lValid

			// Recupera o erro
			cErro := GetErroModel(oModelCMV)
			cMsg  := cErro
			cSolu := ""
			Help(NIL, NIL, "SERGPE01 - BaixaCMV/ValidCampos", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})

			lOk := .F.

		EndIf

		If lOk

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

					lOk := .F.

				EndIf

			Else

				// Recupera o erro do modelo
				cErro := GetErroModel(oModelCMV)

				cMsg  := cErro
				cSolu := ""
				Help(NIL, NIL, "SERGPE01 - BaixaCMV/VldData", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})

				lOk := .F.

			EndIf

		EndIf

		FreeObj(oModelCMV)
		FreeObj(oModelSZ1)
		FreeObj(oModelSZ2)

		//Cria novo CMV - Transferência
		If lOk

			cZ1_NUM := GETSXENUM("SZ1","Z1_NUM")

			RecLock("SZ1", .T.)

			For i := 1 To Len(aCopia)

				If aCopia[i,1] == "SZ1->Z1_NUM"

					SZ1->Z1_NUM := cZ1_NUM

					cHist := "Transferência -> CMV Origem: " + aCopia[i,2]

				ElseIf aCopia[i,1] == "SZ1->Z1_PREFIX"

					SZ1->Z1_PREFIX := "TRA"

				ElseIf aCopia[i,1] == "SZ1->Z1_FORNECE"

					SZ1->Z1_FORNECE := aRetBox[1]

				ElseIf aCopia[i,1] == "SZ1->Z1_LOJA"

					SZ1->Z1_LOJA := aRetBox[2]

				ElseIf aCopia[i,1] == "SZ1->Z1_CODVEI"

					SZ1->Z1_CODVEI := aRetBox[3]

				ElseIf aCopia[i,1] == "SZ1->Z1_CODDESP"

					SZ1->Z1_CODDESP := aRetBox[4]

				ElseIf aCopia[i,1] == "SZ1->Z1_HISTORI"

					SZ1->Z1_HISTORI := cHist

				Else

					&(aCopia[i,1]) := aCopia[i,2]

				EndIf

			Next i

			ConfirmSX8()

			SZ1->(MsUnLock())
			nRecnoNew := SZ1->(Recno())

			//Gravando o numero da Transferência na origem
			SZ1->(DbGoTo(nRecnoOri))

			RecLock("SZ1", .F.)
			SZ1->Z1_NUMTRA := cZ1_NUM
			SZ1->(MsUnLock())

		Else

			DisarmTransaction()
			Return

		EndIf

	END TRANSACTION

	SZ1->(DbGoTo(nRecnoNew))
	cMsg := "Novo CMV Gerado: " + SZ1->Z1_NUM + CRLF
	cMsg += "Parcela: " + SZ1->Z1_PARCELA + CRLF
	cMsg += "Transferido p/ Fornecedor: " + SZ1->Z1_FORNECE + CRLF
	cMsg += "Transferido p/ Loja: " + SZ1->Z1_LOJA + CRLF
	cMsg += "Transferido p/ Veiculo: " + SZ1->Z1_CODVEI + CRLF
	cMsg += "Transferido p/ Despesa: " + SZ1->Z1_CODDESP

	MsgInfo(cMsg, "Transferência Realizada com Sucesso" )

Return


//===========================
//Estorno da Transferencia	=
//===========================
Static Function EstTrans()

	Local aArea 	:= GetArea()
	Local aCMV  	:= {}
	Local aRecnoTra	:= SZ1->(Recno()) //por segurança
	Local i

	aCMV := GetCMVOri(SZ1->Z1_FILIAL,SZ1->Z1_NUM) //aCMV[i,1] -> Recno SZ1 / aCMV[i,2] -> Recno SZ2

	If !Empty(aCMV)

		BEGIN TRANSACTION

			For i := 1 To Len(aCMV)

				//Volta o CMV Origem
				SZ1->(DbGoTo(aCMV[i,1]))

				RecLock("SZ1", .F.)
				SZ1->Z1_NUMTRA := CriaVar("Z1_NUMTRA")
				SZ1->Z1_SALDO  := SZ1->Z1_VALOR
				SZ1->(MsUnLock())

				//Deleta a Baixa do CMV Origem
				SZ2->(DbGoTo(aCMV[i,2]))

				RecLock("SZ2", .F.)
				SZ2->(DbDelete())
				SZ2->(MsUnLock())

			Next i

			//Deleta o CMV Transferencia
			SZ1->(DbGoTo(aRecnoTra))

			RecLock("SZ1", .F.)
			SZ1->(DbDelete())
			SZ1->(MsUnLock())

		END TRANSACTION

		MsgInfo("Estorno Realizado com Sucesso.", "Atenção")

	Else

		MsgStop("Não Foi Encontrado Nenhum CMV para Esta Transferência.", "Atenção")

	EndIf

	RestArea(aArea)

Return

Static Function GetCMVOri(cFilAgr,cNumTra)

	Local cSqlCmv
	Local cAlaisCmv := GetNextAlias()
	Local aRet 		:= {}

	cSqlCmv := "SELECT SZ1.R_E_C_N_O_ AS RECNOSZ1, SZ2.R_E_C_N_O_ AS RECNOSZ2 " + CRLF
	cSqlCmv += "FROM " + RetSqlName("SZ1") + " SZ1 " + CRLF
	cSqlCmv += "LEFT JOIN " + RetSqlName("SZ2") + " SZ2 " + CRLF
	cSqlCmv += "ON " + CRLF
	cSqlCmv += "   SZ2.Z2_FORNECE = SZ1.Z1_FORNECE AND " + CRLF
	cSqlCmv += "   SZ2.Z2_LOJA	  = SZ1.Z1_LOJA    AND " + CRLF
	cSqlCmv += "   SZ2.Z2_NUM	  = SZ1.Z1_NUM     AND " + CRLF
	cSqlCmv += "   SZ2.Z2_PARCELA = SZ1.Z1_PARCELA AND " + CRLF
	cSqlCmv += "   SZ2.D_E_L_E_T_ = '' " + CRLF
	cSqlCmv += "WHERE " + CRLF
	cSqlCmv += "      SZ1.Z1_FILIAL  = '" + cFilAgr + "' AND " + CRLF
	cSqlCmv += "      SZ1.Z1_NUMTRA  = '" + cNumTra + "' AND " + CRLF
	cSqlCmv += "      SZ1.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlCmv),cAlaisCmv,.T.,.F.)

	(cAlaisCmv)->(DbGoTop())

	While !(cAlaisCmv)->(Eof())

		aAdd(aRet, {(cAlaisCmv)->RECNOSZ1, (cAlaisCmv)->RECNOSZ2})

		(cAlaisCmv)->(DbSkip())
	EndDo
	(cAlaisCmv)->(DbCloseArea())

Return aRet //aCMV[i,1] -> Recno SZ1 / aCMV[i,2] -> Recno SZ2
