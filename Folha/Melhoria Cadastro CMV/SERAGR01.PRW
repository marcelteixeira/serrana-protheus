#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:

DESC:   Agrupamento de CMV

AUTOR:  Maycon Anohleti Bianchine - Totvs Leste
*/

User Function SERAGR01(nOpcao)

	Local aTotais := {}
	Local aSelect := {}
	Local cExpSql := ""
	Local aCampos := {"Z1_NUM","Z1_PARCELA","Z1_EMISSAO","Z1_VENCTO","Z1_FORNECE","Z1_LOJA","Z1_VALOR","Z1_SALDO","Z1_CODDESP","Z1_CODVEI","RECNOSZ1"}
	Local aParBox := {}
	Local aRetBox := {}
	Local dDtDe   := Date()
	Local dDtAte  := Date()
	Local cCodFor := SZ1->Z1_FORNECE
	Local cCodLoj := SZ1->Z1_LOJA
	Local cCodVei := SZ1->Z1_CODVEI
	Local cCodDesp:= SZ1->Z1_CODDESP

	If nOpcao == 3 //Inclusão de um Agrupamento

		aAdd(aParBox, {1, "Emissão De"  , dDtDe   ,"",".T.",   "",".T.", 80,.T.})
		aAdd(aParBox, {1, "Emissão Até" , dDtAte  ,"",".T.",   "",".T.", 80,.T.})
		aAdd(aParBox, {1, "Fornecedor"  , cCodFor ,"",   "","SA2",".T.", 80,.T.})
		aAdd(aParBox, {1, "Loja"        , cCodLoj ,"",   "",   "",".T.", 02,.T.})
		aAdd(aParBox, {1, "Veiculo"     , cCodVei ,"",   "","DA3",".T.", 80,.F.})
		aAdd(aParBox, {1, "Despesa"     , cCodDesp,"",   "","DT7",".T.", 80,.T.})

		If ParamBox(aParBox, "Agrupamento de CMV", aRetBox)

			cExpSql := "SELECT SZ1.Z1_NUM, SZ1.Z1_PARCELA, SZ1.Z1_EMISSAO, SZ1.Z1_VENCTO, " + CRLF
			cExpSql += "SZ1.Z1_FORNECE, SZ1.Z1_LOJA, SZ1.Z1_VALOR,SZ1.Z1_SALDO, SZ1.Z1_CODDESP, SZ1.Z1_CODVEI, " + CRLF
			cExpSql += "SZ1.R_E_C_N_O_ AS RECNOSZ1 " + CRLF
			cExpSql += "FROM " + RetSqlName("SZ1") + " SZ1 " + CRLF
			cExpSql += "WHERE " + CRLF
			cExpSql += "      SZ1.Z1_FILIAL  = '" + xFilial("SZ1") + "' AND " + CRLF
			cExpSql += "      SZ1.Z1_EMISSAO BETWEEN " + ValToSql(aRetBox[1]) + " AND " + ValToSql(aRetBox[2]) + " AND " + CRLF
			cExpSql += "      SZ1.Z1_FORNECE = '" + aRetBox[3] + "' AND " + CRLF
			cExpSql += "      SZ1.Z1_LOJA    = '" + aRetBox[4] + "' AND " + CRLF
			cExpSql += "      SZ1.Z1_CODVEI  = '" + aRetBox[5] + "' AND " + CRLF
			cExpSql += "      SZ1.Z1_CODDESP = '" + aRetBox[6] + "' AND " + CRLF
			cExpSql += "      SZ1.Z1_VALOR   = SZ1.Z1_SALDO AND " + CRLF
			cExpSql += "      SZ1.Z1_PREFIX  = '' AND " + CRLF
			cExpSql += "      SZ1.D_E_L_E_T_ = '' " + CRLF
			cExpSql += "ORDER BY SZ1.Z1_EMISSAO"

			aAdd(aTotais, {"Z1_NUM"  , "COUNT", "Qtd. Registro Selecionado", "@E 999,999"})
			aAdd(aTotais, {"Z1_SALDO", "SUM"  , "Valor Total Selecionado"  , "@E 9,999,999.99"})

			FWMsgRun(, {|| aSelect := u_SERAGR02("SZ1", "", "Agrupamentos de Despesas CMV", cExpSql, aCampos, .T., aTotais, 100)[2]}, "Agrupamento de CMV", "Carregando Informações...")

			If !Empty(aSelect)
				FWMsgRun(, {|| GeraAgr(aSelect)}, "Agrupamento de CMV", "Criando Agrupamento...")
			EndIf

		EndIf

	ElseIf nOpcao == 5 //Estorno

		If SZ1->Z1_PREFIX == "AGR"

			If SZ1->Z1_VALOR == SZ1->Z1_SALDO

				If MsgYesNo("Deseja Realmente Realizar Estorno Deste Agrupamento?", "Atenção")
				
					FWMsgRun(, {|| EstornaAgr()}, "Estorno Agrupamento de CMV", "Estornando Agrupamento...")

				EndIf
			
			Else

				cMsg := "Não Será Possivel Relizar Estorno Deste Agrupamento." + CRLF
				cMsg += "Motivo: Agrupamento Baixado ou Parcialmente Baixado."
				MsgStop(cMsg, "Atenção")

			EndIf

		EndIf

	EndIf

Return


//===============================
//Realiza Agrupamento dos CMV	=
//===============================
Static Function GeraAgr(aCMV)

	Local aArea     := GetArea()
	Local aAreaSZ1  := SZ1->(GetArea())
	Local i
	Local nRecnoSZ1
	Local lOk       := .T.
	Local nNewSaldo := 0
	Local cNewCodFor
	Local cNewLojFor
	Local cNewCodVei
	Local cNewCodDes
	Local cHist     := ""
	Local oModelCMV
	Local oModelSZ1
	Local oModelSZ2
	Local cIdMov
	Local lValid
	Local cErro
	Local cMsg
	Local cSolu

	BEGIN TRANSACTION

		For i := 1 To Len(aCMV)

			nRecnoSZ1 := aCMV[i,Len(aCMV[i]),2]

			SZ1->(DbGoTo(nRecnoSZ1))

			cNewCodFor := SZ1->Z1_FORNECE
			cNewLojFor := SZ1->Z1_LOJA
			cNewCodVei := SZ1->Z1_CODVEI
			cNewCodDes := SZ1->Z1_CODDESP

			nNewSaldo += SZ1->Z1_SALDO

			//AllTrim(SZ1->Z1_HISTORI)
			cHist += "CMV Origem: " + SZ1->Z1_NUM + "/" + SZ1->Z1_PARCELA + CRLF

			//RecLock("SZ1", .F.)
			//SZ1->(MsUnLock())

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
				lValid := oModelSZ2:SetValue("Z2_HISTOR", "Baixa por Agrupamento")
			EndIf

			If lValid
				lValid := oModelSZ2:SetValue("Z2_TIPMOV", "A")
			EndIf

			If lValid
				// Informa que foi integrado no Financeiro CP, sendo assim, somente
				// o financeiro pode excluir tal baixa. Ponto de Entrada FA050DEL
				lValid := oModelSZ2:SetValue("Z2_ROTINA", "SERAGR01")
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

			//Erro
			If !lOk

				DisarmTransaction()

				Return .F.

			EndIf

		Next i

		cZ1_NUM := GETSXENUM("SZ1","Z1_NUM")

		RecLock("SZ1", .T.)

		SZ1->Z1_FILIAL	:= xFilial("SZ1")
		SZ1->Z1_NUM		:= cZ1_NUM
		SZ1->Z1_PARCELA	:= "0001"
		SZ1->Z1_EMISSAO	:= dDataBase
		SZ1->Z1_VENCTO	:= dDataBase + 30
		SZ1->Z1_FORNECE	:= cNewCodFor
		SZ1->Z1_LOJA	:= cNewLojFor
		SZ1->Z1_VALOR	:= nNewSaldo
		SZ1->Z1_SALDO	:= nNewSaldo
		SZ1->Z1_CODDESP	:= cNewCodDes
		SZ1->Z1_CODVEI	:= cNewCodVei
		SZ1->Z1_HISTORI	:= cHist
		SZ1->Z1_PREFIX  := "AGR"

		SZ1->(MsUnLock())

		ConfirmSX8()

		//Preenchendo o campo Z1_NUMAGR dos CMV Origem
		For i := 1 To Len(aCMV)

			nRecnoSZ1 := aCMV[i,Len(aCMV[i]),2]

			SZ1->(DbGoTo(nRecnoSZ1))

			RecLock("SZ1", .F.)
			SZ1->Z1_NUMAGR := cZ1_NUM
			SZ1->(MsUnLock())

		Next i

	END TRANSACTION

	cMsg := "Agrupamento Reaizado com Sucesso" + CRLF
	cMsg += "Novo CMV AGR Gerado: " + cZ1_NUM
	MsgInfo(cMsg, "Agrupamento de CMV")

	RestArea(aArea)
	RestArea(aAreaSZ1)

Return


//================================
//Realiza Estorno do Agrupamento =
//================================
Static Function EstornaAgr()

	Local aArea 	:= GetArea()
	Local aCMV  	:= {}
	Local aRecnoAgr	:= SZ1->(Recno()) //por segurança
	Local i

	aCMV := GetCMVAgr(SZ1->Z1_FILIAL,SZ1->Z1_NUM) //aCMV[i,1] -> Recno SZ1 / aCMV[i,2] -> Recno SZ2

	If !Empty(aCMV)

		BEGIN TRANSACTION

			For i := 1 To Len(aCMV)

				//Volta o CMV Origem
				SZ1->(DbGoTo(aCMV[i,1]))

				RecLock("SZ1", .F.)
				SZ1->Z1_NUMAGR  := CriaVar("Z1_NUMAGR")
				SZ1->Z1_SALDO   := SZ1->Z1_VALOR
				SZ1->(MsUnLock())

				//Deleta a Baixa do CMV Origem
				SZ2->(DbGoTo(aCMV[i,2]))

				RecLock("SZ2", .F.)
				SZ2->(DbDelete())
				SZ2->(MsUnLock())

			Next i

			//Deleta o CMV AGR
			SZ1->(DbGoTo(aRecnoAgr))

			RecLock("SZ1", .F.)
			SZ1->(DbDelete())
			SZ1->(MsUnLock())

		END TRANSACTION

		MsgInfo("Estorno Realizado com Sucesso.", "Atenção")

	Else

		MsgStop("Não Foi Encontrado Nenhum CMV para Este Agrupamento.", "Atenção")

	EndIf

	RestArea(aArea)

Return

Static Function GetCMVAgr(cFilAgr,cNumAgr)

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
	cSqlCmv += "      SZ1.Z1_NUMAGR  = '" + cNumAgr + "' AND " + CRLF
	cSqlCmv += "      SZ1.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlCmv),cAlaisCmv,.T.,.F.)

	(cAlaisCmv)->(DbGoTop())

	While !(cAlaisCmv)->(Eof())

		aAdd(aRet, {(cAlaisCmv)->RECNOSZ1, (cAlaisCmv)->RECNOSZ2})

		(cAlaisCmv)->(DbSkip())
	EndDo
	(cAlaisCmv)->(DbCloseArea())

Return aRet //aCMV[i,1] -> Recno SZ1 / aCMV[i,2] -> Recno SZ2
