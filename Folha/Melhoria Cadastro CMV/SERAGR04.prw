#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:

DESC:   Baixa NDF em Lote

AUTOR:  Maycon Anohleti Bianchine - Totvs Leste
*/

User Function SERAGR04()

	Local cHist       := "Gerado NDF no Financeiro por " + cUserName
	Local aTotais     := {}
	Local aSelect     := {}
	Local cExpSql     := ""
	Local aCampos     := {"Z1_NUM","Z1_PARCELA","Z1_EMISSAO","Z1_VENCTO","Z1_FORNECE","Z1_LOJA","Z1_VALOR","Z1_SALDO","Z1_CODDESP","Z1_CODVEI","RECNOSZ1"}
	Local aParBox     := {}
	Local dDtDe       := Date()
	Local dDtAte      := Date()
	Local cCodForDe   := Space(TamSX3("Z1_FORNECE")[1])
	Local cCodForAte  := Space(TamSX3("Z1_FORNECE")[1])
	Local cCodLojDe   := Space(TamSX3("Z1_LOJA")[1])
	Local cCodLojAte  := Space(TamSX3("Z1_LOJA")[1])
	Local cCodVeiDe   := Space(TamSX3("Z1_CODVEI")[1])
	Local cCodVeiAte  := Space(TamSX3("Z1_CODVEI")[1])
	Local cCodDespDe  := Space(TamSX3("Z1_CODDESP")[1])
	Local cCodDespAte := Space(TamSX3("Z1_CODDESP")[1])
	Local aRetBox     := {}
	Local aArea       := GetArea()
	Local aAreaSZ1    := SZ1->(GetArea())
	Local cMsgRum
	Local i
	Local lBaixou     := .F.

	Private lLoteCMV  := .T.
	Private oProxCC	  := Nil
	Private lProxCC	  := .F.
	Private cCCCMV    := ""

	aAdd(aParBox, {1, "Emissão De"    , dDtDe      ,"",".T.",   "",".T.", 80,.T.})
	aAdd(aParBox, {1, "Emissão Até"   , dDtAte     ,"",".T.",   "",".T.", 80,.T.})
	aAdd(aParBox, {1, "Fornecedor De" , cCodForDe  ,"",   "","SA2",".T.", 80,.F.})
	aAdd(aParBox, {1, "Fornecedor Até", cCodForAte ,"",   "","SA2",".T.", 80,.F.})
	aAdd(aParBox, {1, "Loja De"       , cCodLojDe  ,"",   "",   "",".T.", 02,.F.})
	aAdd(aParBox, {1, "Loja Até"      , cCodLojAte ,"",   "",   "",".T.", 02,.F.})
	aAdd(aParBox, {1, "Veiculo De"    , cCodVeiDe  ,"",   "","DA3",".T.", 80,.F.})
	aAdd(aParBox, {1, "Veiculo Até"   , cCodVeiAte ,"",   "","DA3",".T.", 80,.F.})
	aAdd(aParBox, {1, "Despesa De"    , cCodDespDe ,"",   "","DT7",".T.", 80,.F.})
	aAdd(aParBox, {1, "Despesa Até"   , cCodDespAte,"",   "","DT7",".T.", 80,.F.})

	If ParamBox(aParBox, "Geração de NDF em Lote", aRetBox)

		cExpSql := "SELECT SZ1.Z1_NUM, SZ1.Z1_PARCELA, SZ1.Z1_EMISSAO, SZ1.Z1_VENCTO, " + CRLF
		cExpSql += "SZ1.Z1_FORNECE, SZ1.Z1_LOJA, SZ1.Z1_VALOR,SZ1.Z1_SALDO, SZ1.Z1_CODDESP, SZ1.Z1_CODVEI, " + CRLF
		cExpSql += "SZ1.R_E_C_N_O_ AS RECNOSZ1 " + CRLF
		cExpSql += "FROM " + RetSqlName("SZ1") + " SZ1 " + CRLF
		cExpSql += "WHERE " + CRLF
		cExpSql += "      SZ1.Z1_FILIAL  = '" + xFilial("SZ1") + "' AND " + CRLF
		cExpSql += "      SZ1.Z1_EMISSAO BETWEEN " + ValToSql(aRetBox[1]) + " AND " + ValToSql(aRetBox[2]) + " AND " + CRLF
		cExpSql += "      SZ1.Z1_FORNECE BETWEEN '" + aRetBox[3] + "' AND '" + aRetBox[4]  + "' AND " + CRLF
		cExpSql += "      SZ1.Z1_LOJA    BETWEEN '" + aRetBox[5] + "' AND '" + aRetBox[6]  + "' AND " + CRLF
		cExpSql += "      SZ1.Z1_CODVEI  BETWEEN '" + aRetBox[7] + "' AND '" + aRetBox[8]  + "' AND " + CRLF
		cExpSql += "      SZ1.Z1_CODDESP BETWEEN '" + aRetBox[9] + "' AND '" + aRetBox[10] + "' AND " + CRLF
		cExpSql += "      SZ1.Z1_SALDO   > 0 AND " + CRLF
		cExpSql += "      SZ1.D_E_L_E_T_ = '' " + CRLF
		cExpSql += "ORDER BY SZ1.Z1_EMISSAO"

		aAdd(aTotais, {"Z1_NUM"  , "COUNT", "Qtd. Registro Selecionado", "@E 999,999"})
		aAdd(aTotais, {"Z1_SALDO", "SUM"  , "Valor Total Selecionado"  , "@E 9,999,999.99"})

		FWMsgRun(, {|| aSelect := u_SERAGR02("SZ1", "", "Geração de NDF em Lote", cExpSql, aCampos, .T., aTotais, 100)[2]}, "Geração de NDF em Lote", "Carregando Informações...")

		BEGIN TRANSACTION

			For i := 1 To Len(aSelect)

				SZ1->(DbGoTo(aSelect[i,Len(aSelect[i]),2]))

				cMsgRum := "Gerando NDF (" + cValToChar(i) + "/" + cValToChar(Len(aSelect)) + ") " + SZ1->Z1_NUM + "/" + SZ1->Z1_PARCELA + "... "

				FWMsgRun(, {|| lBaixou := u_BaixaCMV(,,,,cHist)}, "Geração de NDF em Lote", cMsgRum)

				If !lBaixou

					DisarmTransaction()

					RestArea(aArea)
					RestArea(aAreaSZ1)

					Return

				EndIf

			Next i

			If lBaixou
			
				MsgInfo("Geração de NDF em Lote Finalizado com Sucesso.", "Geração de NDF em Lote")

			EndIf

		END TRANSACTION

	EndIf

	RestArea(aArea)
	RestArea(aAreaSZ1)

Return
