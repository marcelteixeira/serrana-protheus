#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:   22/09/2021

DESC:   INTEGRAÇÃO COM CTA SMART PLUS - GERAÇÃO DE CMV AUTOMATICO

AUTOR:  MAYCON ANHOLETI BIANCHINE - TOTVS LESTE
*/

User Function SERCTA01()

	Local lOkOpenEmp := .F.
	Local aHeader    := {}
	Local cUrlSmart
	Local cToken
	Local cParUrl
	Local dDtInicio
	Local dDtFim
	Local cFormato
	Local oSmart
	Local nDias
	Local i
	Local cNumCMV	:= ""
	Local cCodProd
	Local cDesc
	Local cCodErro  := ""
	Local cDescErro := ""
	Local lExistSZQ := .F.
	Local cStatus   := "P"
	Local nRecnoSZQ := 0
	Local cPlaca    := ""
	Local cCGC		:= ""
	Local cNomeFor  := ""

	Private oObj 	:= Nil
	Private aBastece
	Private cJson 	:= ""

	RPCSetType(3)  //Nao consome licensas

	lOkOpenEmp := RpcSetEnv("01","01",,,,GetEnvServer(),{}) //Abertura do ambiente em rotinas automÃƒÂ¡ticas

	If lOkOpenEmp

		//http://ctasmart.com.br:8080/SvWebSincronizaAbastecimentos?token=SRJyNOPimt&max_linhas=100&data_inicio=05/09/2021&data_fim=06/09/2021&formato=json
		cUrlSmart := GetMv("MV_URLCTA", .F., "http://ctasmart.com.br:8080/SvWebSincronizaAbastecimentos") //URL base de acesso da API da Smart
		cToken    := GetMv("MV_TOKCTA", .F., "SRJyNOPimt") //Token de acesso - fornecido pela CTA Smart
		nDias     := GetMv("MV_NDTCTA", .F., 3) //Quantidade de dias com base na data base do sistema que sera considerado para data inicio
		dDtInicio := dDataBase - nDias
		dDtFim    := dDataBase
		cFormato  := "&formato=json"

		cParUrl := "?token=" + AllTrim(cToken)

		//Setando o Maximo de item de retorno
		//100 ÃƒÂ© o maximo de contiade de retorno
		//Criar um possivel parametro depois para colocar
		cParUrl += "&max_linhas=100"

		//Periodo de pesquisa para retornar os dados da CTA Smart
		//Formato dd/mm/aaaa
		cParUrl += "&data_inicio=" + Day2Str(dDtInicio) + "/" + Month2Str(dDtInicio) + "/" + Year2Str(dDtInicio)
		cParUrl += "&data_fim=" + Day2Str(dDtFim) + "/" + Month2Str(dDtFim) + "/" + Year2Str(dDtFim)

		//Setando o formato de retorno dos dados Json
		cParUrl += cFormato

		aAdd(aHeader, "Content-Type: application/json")

		oSmart := FWRest():New(cUrlSmart)
		oSmart:setPath(cParUrl)
		oSmart:Get(aHeader)

		If FWJsonDeserialize(oSmart:GetResult(), @oObj)

			If Type("oObj:status:codigo") == "C"

				If oObj:status:codigo == "001"

					aBastece := oObj:abastecimentos

					//BEGIN TRANSACTION

					For i := 1 To Len(aBastece)

						cCodErro  := ""
						cDescErro := ""
						lExistSZQ := .F.
						cStatus   := "P"
						nRecnoSZQ := 0
						cNumCMV	  := ""
						cPlaca    := ""
						cCGC      := ""
						cNomeFor  := ""

						cJson := FwJsonSerialize(aBastece[i])

						If Type("aBastece[" + cValToChar(i) + "]:posto:cnpj") == "C"
							cCGC     := aBastece[i]:posto:cnpj
							cNomeFor := aBastece[i]:posto:nome
						EndIf

						//Id do Abastecimento
						If Type("aBastece[" + cValToChar(i) + "]:id") == "C"
							cIdAbastece := aBastece[i]:id
						Else
							Loop
						EndIf

						cIdAbastece := AllTrim(cIdAbastece) + Space(TamSx3("ZQ_ID")[1] - Len(AllTrim(cIdAbastece)))

						DbSelectArea("SZQ")
						SZQ->(DbSetOrder(1))
						If SZQ->(DbSeek(xFilial("SZQ") + cIdAbastece))

							If SZQ->ZQ_STATUS == "E"
								Loop
							EndIf

							lExistSZQ := .T.
							nRecnoSZQ := SZQ->(Recno())

							//Força a Sincronização para CTA Smart
							If SZQ->ZQ_STATUS == "P" .AND. !Empty(SZQ->ZQ_NUM) .AND. SZQ->ZQ_RETCTA == "N"

								If ComunicaCTA(cToken)
									RecLock("SZQ", .F.)
									SZQ->ZQ_RETCTA := "S"
									SZQ->(MsUnLock())
								EndIf

								Loop

							EndIf

						EndIf

						//Verifica se o ID do produto no arquivo Json estÃ¡ relacionado Ã  algum produto na SB1
						//Analisar se realmente Ã© necessario esta validaÃ§Ã£o
						If Type("aBastece[" + cValToChar(i) + "]:combustivel:codigo") == "C"

							If Type("aBastece[" + cValToChar(i) + "]:veiculo:placa") == "C"
								cPlaca := aBastece[i]:veiculo:placa
							EndIf

							cCodProd := aBastece[i]:combustivel:codigo
							cDesc    := aBastece[i]:combustivel:descricao

							If !VldProd(cCodProd,.F.)

								cCodErro  := "Sem Produto"
								cDescErro := "Produto sem Amarração no Cad. de Produto(SB1). Produto CTA Smart: " + cCodProd + "/" + cDesc + ". Favor Realizar a Correção."

								If GravaSZQ(lExistSZQ,nRecnoSZQ,cIdAbastece,cCodErro,cDescErro,"E",cPlaca,aBastece[i]:data_inicio,aBastece[i]:custo_unitario,aBastece[i]:volume,aBastece[i]:odometro,cCodProd,cDesc,cCGC,cNomeFor)
									Loop
								EndIf

							EndIf

						Else
							Loop
						EndIf

						//Verifica se a Placa do veÃ­culo no arquivo Json estÃ¡ relacionado Ã  algum veÃ­culo na DA3
						If Type("aBastece[" + cValToChar(i) + "]:veiculo:placa") == "C"

							cPlaca := aBastece[i]:veiculo:placa

							If !VldPlaca(cPlaca)

								cCodErro  := "Sem Placa"
								cDescErro := "Nenhum Veiculo Cadastrado no Sistema. Placa: " + cPlaca + ". Favor Realizar a Correção."

								If GravaSZQ(lExistSZQ,nRecnoSZQ,cIdAbastece,cCodErro,cDescErro,"E",cPlaca,aBastece[i]:data_inicio,aBastece[i]:custo_unitario,aBastece[i]:volume,aBastece[i]:odometro,cCodProd,cDesc,cCGC,cNomeFor)
									Loop
								EndIf

							EndIf

						Else
							Loop
						EndIf

						//Verifica se o Veí­culo foi cadastrado com o campo proprietário preenchido
						If Type("aBastece[" + cValToChar(i) + "]:veiculo:placa") == "C"

							cPlaca := aBastece[i]:veiculo:placa

							If !VldVeiculo(cPlaca)

								cCodErro  := "Sem Proprietário"
								cDescErro := "Veiculo Sem Vinculo com Proprietário. Placa: " + cPlaca + ". Favor Realizar a Correção."

								If GravaSZQ(lExistSZQ,nRecnoSZQ,cIdAbastece,cCodErro,cDescErro,"E",cPlaca,aBastece[i]:data_inicio,aBastece[i]:custo_unitario,aBastece[i]:volume,aBastece[i]:odometro,cCodProd,cDesc,cCGC,cNomeFor)
									Loop
								EndIf

							EndIf

						Else
							Loop
						EndIf

						//Verifica se no cadastro do veÃ­culo foi informado a despesa do CMV
						If Type("aBastece[" + cValToChar(i) + "]:veiculo:placa") == "C"

							cPlaca := aBastece[i]:veiculo:placa

							If !VldCMV(cPlaca)

								cCodErro  := "Sem CMV"
								cDescErro := "Veiculo Sem Informação Cod. da Despesa Informado. Placa: " + cPlaca + ". Favor Realizar a Correção."

								If GravaSZQ(lExistSZQ,nRecnoSZQ,cIdAbastece,cCodErro,cDescErro,"E",cPlaca,aBastece[i]:data_inicio,aBastece[i]:custo_unitario,aBastece[i]:volume,aBastece[i]:odometro,cCodProd,cDesc,cCGC,cNomeFor)
									Loop
								EndIf

							EndIf

						Else
							Loop
						EndIf

						//Cnpj do Fornecedor
						//desse modo sabemos de onde foi abastecido
						//Verifica se tem Cadastro de Fornecedor
						If Type("aBastece[" + cValToChar(i) + "]:posto:cnpj") == "C"

							cCGC     := aBastece[i]:posto:cnpj
							cNomeFor := aBastece[i]:posto:nome

							If !VldFornece(cCGC,.F.)

								cCodErro  := "Sem Fornecedor"
								cDescErro := "Fornecedor não Cadastrado no Sistema(SA2). Cnpj: " + cCGC + "/" + cNomeFor + ". Favor Realizar a Correção."

								If GravaSZQ(lExistSZQ,nRecnoSZQ,cIdAbastece,cCodErro,cDescErro,"E",cPlaca,aBastece[i]:data_inicio,aBastece[i]:custo_unitario,aBastece[i]:volume,aBastece[i]:odometro,cCodProd,cDesc,cCGC,cNomeFor)
									Loop
								EndIf

							EndIf

						Else
							Loop
						EndIf

						//Caso tudo esteja de acordo ... realiza a gravação do CMV no sistema
						If GravaSZQ(lExistSZQ,nRecnoSZQ,cIdAbastece,cCodErro,cDescErro,"P",cPlaca,aBastece[i]:data_inicio,aBastece[i]:custo_unitario,aBastece[i]:volume,aBastece[i]:odometro,cCodProd,cDesc,cCGC,cNomeFor)

							DbSelectArea("SZQ")
							SZQ->(DbSetOrder(1))
							SZQ->(DbSeek(xFilial("SZQ") + cIdAbastece))

							cNumCMV := GravaCMV()
							If !Empty(cNumCMV)

								RecLock("SZQ", .F.)
								SZQ->ZQ_STATUS	:= "C"
								SZQ->ZQ_NUM     := cNumCMV
								SZQ->ZQ_CODERRO := ""
								SZQ->ZQ_DESCERR := ""
								SZQ->ZQ_DTCERRO := CriaVar("ZQ_DTCERRO")
								SZQ->(MsUnLock())

								If ComunicaCTA(cToken)
									RecLock("SZQ", .F.)
									SZQ->ZQ_RETCTA := "S"
									SZQ->(MsUnLock())
								EndIf

							EndIf

							//Geração de ConOut
							GeraConOut()

						EndIf

					Next i

					//END TRANSACTION

				EndIf

			EndIf

		EndIf

	EndIf

Return


//===========================================================================================
//Verifica se o ID do produto no arquivo Json estÃ¡ relacionado Ã  algum produto na SB1       =
//caso nÃ£o, gera *LOG;                                                                      =
//===========================================================================================
Static Function VldProd(cCodProd,lSeekSB1)

	Local lRet 		:= .F.
	Local cSqlSB1
	Local cAliasSB1 := GetNextAlias()

	cSqlSB1 := "SELECT SB1.R_E_C_N_O_ AS RECNOSB1 " + CRLF
	cSqlSB1 += "FROM " + RetSqlName("SB1") + " SB1 " + CRLF
	cSqlSB1 += "WHERE " + CRLF
	cSqlSB1 += "      SB1.B1_YCODCTA = '" + cCodProd + "' AND " + CRLF
	cSqlSB1 += "      SB1.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSB1),cAliasSB1,.T.,.F.)

	(cAliasSB1)->(DbGoTop())

	If !(cAliasSB1)->(Eof())

		lRet := .T.

		If lSeekSB1
			DbSelectArea("SB1")
			SB1->(DbGoTo((cAliasSB1)->RECNOSB1))
		EndIf

	EndIf
	(cAliasSB1)->(DbCloseArea())

Return lRet


//===========================================================================================
//Verifica se a Placa do veÃ­culo no arquivo Json estÃ¡ relacionado Ã  algum veÃ­culo na DA3    =
//caso nÃ£o, gera *LOG;                                                                      =
//===========================================================================================
Static Function VldPlaca(cPlaca)

	Local lRet 		:= .F.
	Local cSqlDA3
	Local cAliasDA3 := GetNextAlias()

	cSqlDA3 := "SELECT DA3.R_E_C_N_O_ AS RECNODA3 " + CRLF
	cSqlDA3 += "FROM " + RetSqlName("DA3") + " DA3 " + CRLF
	cSqlDA3 += "WHERE " + CRLF
	cSqlDA3 += "      DA3.DA3_PLACA = '" + cPlaca + "' AND " + CRLF
	cSqlDA3 += "      DA3.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlDA3),cAliasDA3,.T.,.F.)

	(cAliasDA3)->(DbGoTop())

	If !(cAliasDA3)->(Eof())
		lRet := .T.
	EndIf
	(cAliasDA3)->(DbCloseArea())

Return lRet


//===========================================================================================
//Verifica se o VeÃ­culo foi cadastrado com o campo proprietÃ¡rio preenchido				    =
//caso nÃ£o, gera *LOG;                                                                      =
//===========================================================================================
Static Function VldVeiculo(cPlaca)

	Local lRet 		:= .F.
	Local cSqlDA3
	Local cAliasDA3 := GetNextAlias()

	cSqlDA3 := "SELECT DA3.R_E_C_N_O_ AS RECNODA3 " + CRLF
	cSqlDA3 += "FROM " + RetSqlName("DA3") + " DA3 " + CRLF
	cSqlDA3 += "WHERE " + CRLF
	cSqlDA3 += "      DA3.DA3_PLACA  = '" + cPlaca + "' AND " + CRLF
	cSqlDA3 += "      DA3.DA3_CODFOR != '' AND " + CRLF
	cSqlDA3 += "      DA3.DA3_LOJFOR != '' AND " + CRLF
	cSqlDA3 += "      DA3.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlDA3),cAliasDA3,.T.,.F.)

	(cAliasDA3)->(DbGoTop())

	If !(cAliasDA3)->(Eof())
		lRet := .T.
	EndIf
	(cAliasDA3)->(DbCloseArea())

Return lRet


//===========================================================================================
//Verifica se no cadastro do veÃ­culo foi informado a despesa do CMV	        			    =
//caso nÃ£o, gera *LOG;                                                                      =
//===========================================================================================
Static Function VldCMV(cPlaca,lSeekDA3)

	Local lRet 		:= .F.
	Local cSqlDA3
	Local cAliasDA3 := GetNextAlias()

	Default lSeekDA3 := .F.

	cSqlDA3 := "SELECT DA3.R_E_C_N_O_ AS RECNODA3 " + CRLF
	cSqlDA3 += "FROM " + RetSqlName("DA3") + " DA3 " + CRLF
	cSqlDA3 += "WHERE " + CRLF
	cSqlDA3 += "      DA3.DA3_PLACA  = '" + cPlaca + "' AND " + CRLF
	cSqlDA3 += "      DA3.DA3_CODFOR != '' AND " + CRLF
	cSqlDA3 += "      DA3.DA3_LOJFOR != '' AND " + CRLF
	cSqlDA3 += "      DA3.DA3_YDESP  != '' AND " + CRLF
	cSqlDA3 += "      DA3.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlDA3),cAliasDA3,.T.,.F.)

	(cAliasDA3)->(DbGoTop())

	If !(cAliasDA3)->(Eof())
		lRet := .T.

		If lSeekDA3
			DbSelectArea("DA3")
			DA3->(DbGoTo((cAliasDA3)->RECNODA3))
		EndIf

	EndIf
	(cAliasDA3)->(DbCloseArea())

Return lRet


//===========================================================================================
//Verifica se Fornecedor esta cadastrado no sistema (SA2)       							=
//caso nÃ£o, gera *LOG;                                                                     =
//===========================================================================================
Static Function VldFornece(cCGC,SeekSA2)

	Local lRet 		:= .F.
	Local cSqlSA2
	Local cAliasSA2 := GetNextAlias()

	cSqlSA2 := "SELECT SA2.R_E_C_N_O_ AS RECNOSA2 " + CRLF
	cSqlSA2 += "FROM " + RetSqlName("SA2") + " SA2 " + CRLF
	cSqlSA2 += "WHERE " + CRLF
	cSqlSA2 += "      SA2.A2_CGC     = '" + cCGC + "' AND " + CRLF
	cSqlSA2 += "      SA2.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSA2),cAliasSA2,.T.,.F.)

	(cAliasSA2)->(DbGoTop())

	If !(cAliasSA2)->(Eof())

		lRet := .T.

		If SeekSA2
			DbSelectArea("SA2")
			SA2->(DbGoTo((cAliasSA2)->RECNOSA2))
		EndIf

	EndIf
	(cAliasSA2)->(DbCloseArea())

Return lRet


//===========================
//Grava o LOG na tabela SZQ	=
//===========================
Static Function GravaSZQ(lExistSZQ,nRecnoSZQ,cIdAbastece,cCodErro,cDescErro,Status,cPlaca,dDtInicio,nValUnit,nVolume,nOdometro,cCodProd,cDesc,cCGC,cNomeFor)

	Local lRet   := .T.
	Local aArea  := GetArea()
	Local lTpGrv := .T.
	Local nTxAdm := 0
	Local nValTx := 0

	Default cCodProd := ""
	Default cDesc    := ""

	DbSelectArea("SZQ")
	SZQ->(DbSetOrder(1))

	If nRecnoSZQ > 0
		lTpGrv := .F.
		SZQ->(DbGoTo(nRecnoSZQ))
	EndIf

	nTxAdm    := GetTxAdm(cCodProd)
	nOdometro := Val(StrTran(nOdometro,",","."))
	nVolume   := Val(StrTran(nVolume,",","."))
	nValUnit  := Val(StrTran(nValUnit,",","."))
	nValTx    := nValUnit + nTxAdm

	RecLock("SZQ", lTpGrv)
	SZQ->ZQ_FILIAL 	:= xFilial("SZQ")
	SZQ->ZQ_ID		:= cIdAbastece
	SZQ->ZQ_STATUS	:= Status
	SZQ->ZQ_DTGRV	:= dDataBase
	SZQ->ZQ_DTABAST := CtoD(dDtInicio)
	SZQ->ZQ_PLACA	:= cPlaca
	SZQ->ZQ_ODOMETR := nOdometro

	//Só Grava os Preços e Taxa quando for na Inclusão
	If lTpGrv
		SZQ->ZQ_VOLUME	:= nVolume
		SZQ->ZQ_PRCUNIT := nValUnit
		SZQ->ZQ_TXADM   := nTxAdm
		SZQ->ZQ_PRCTX   := nValTx
		SZQ->ZQ_VLTOTAL := nVolume * nValTx
	EndIf

	SZQ->ZQ_CODERRO := cCodErro
	SZQ->ZQ_DESCERR := cDescErro
	SZQ->ZQ_JSON	:= cJson
	SZQ->ZQ_DTCERRO := CriaVar("ZQ_DTCERRO")
	SZQ->ZQ_RETCTA  := "N"
	SZQ->ZQ_PRODUT  := cCodProd
	SZQ->ZQ_DESCP   := cDesc
	SZQ->ZQ_CGC     := cCGC
	SZQ->ZQ_NOMEFOR := cNomeFor
	SZQ->(MsUnLock())

	RestArea(aArea)

	//Geração de ConOut
	GeraConOut()

Return lRet


//=======================================
//Busca a Taxa Admnistrativa do Produto	=
//=======================================
Static Function GetTxAdm(cCodProd)

	Local nTxAdm := 0

	If VldProd(cCodProd,.T.)
		nTxAdm := SB1->B1_YTXADM
	EndIf

Return nTxAdm


//===============================
//GravaÃ§Ã£o do CMV no Sistema	=
//===============================
Static Function GravaCMV()

	Local cZ1_NUM := ""

	If !Empty(SZQ->ZQ_NUM)

		cZ1_NUM := SZQ->ZQ_NUM

	Else

		cZ1_NUM := GETSXENUM("SZ1","Z1_NUM")
		RecLock("SZ1", .T.)
		SZ1->Z1_FILIAL	:= xFilial("SZ1")
		SZ1->Z1_NUM		:= cZ1_NUM
		SZ1->Z1_PARCELA	:= "0001"
		SZ1->Z1_EMISSAO	:= SZQ->ZQ_DTABAST
		SZ1->Z1_VENCTO	:= GetDtVenc(SZQ->ZQ_DTABAST)

		//Posiciona na DA3
		VldCMV(SZQ->ZQ_PLACA,.T.)
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(DA3->DA3_FILIAL + DA3->DA3_CODFOR + DA3->DA3_LOJFOR))
		SZ1->Z1_FORNECE	:= SA2->A2_COD
		SZ1->Z1_LOJA	:= SA2->A2_LOJA

		SZ1->Z1_VALOR	:= SZQ->ZQ_VLTOTAL
		SZ1->Z1_SALDO	:= SZQ->ZQ_VLTOTAL
		SZ1->Z1_CODDESP	:= DA3->DA3_YDESP
		SZ1->Z1_CODVEI	:= SZQ->ZQ_PLACA
		SZ1->Z1_HISTORI	:= "Integração CTA Smart"
		SZ1->Z1_ODOMETR	:= SZQ->ZQ_ODOMETR

		//Campos relacionado ao CTA Smart
		SZ1->Z1_ZQID	:= SZQ->ZQ_ID
		SZ1->Z1_VOLUME	:= SZQ->ZQ_VOLUME
		SZ1->Z1_PRCUNIT := SZQ->ZQ_PRCTX
		SZ1->Z1_VLTOTAL := SZQ->ZQ_VLTOTAL
		SZ1->Z1_DTABAST := SZQ->ZQ_DTABAST

		//Posiciona na SB1
		VldProd(SZQ->ZQ_PRODUT,.T.)
		SZ1->Z1_B1COD   := SB1->B1_COD
		SZ1->Z1_B1DESC	:= SB1->B1_DESC

		//Posiciona na SA2
		VldFornece(SZQ->ZQ_CGC,.T.)
		SZ1->Z1_A2COD	:= SA2->A2_COD
		SZ1->Z1_A2LOJA	:= SA2->A2_LOJA
		SZ1->Z1_A2NOME	:= SA2->A2_NOME

		SZ1->(MsUnLock())

		ConfirmSX8()

	Endif

Return cZ1_NUM


//===================================================
//Comunica Sincornismo da CTA Smart com Protheus	=
//===================================================
Static Function ComunicaCTA(cToken)

	Local cSmartOk 	:= GetMv("MV_URLCTA2", .F., "http://ctasmart.com.br:8080")
	Local cUrlPath 	:= "/SvWebInformaSincronismo?token=" + AllTrim(cToken) + "&formato=json"
	Local aHeader  	:= {}
	Local oSmartOk
	Local cJsonOk  	:= ""
	Local lRet 		:= .F.

	Private oObjOk := Nil

	aAdd(aHeader, "Content-Type: application/json")

	cJsonOk := '{'
	cJsonOk += '	"abastecimentos": ['
	cJsonOk += '		{'
	cJsonOk += '			"id": "' + AllTrim(SZQ->ZQ_ID) + '",'
	cJsonOk += '			"status": "Sucesso",'
	cJsonOk += '			"motivo_erro": ""'
	cJsonOk += '		}'
	cJsonOk += '	]'
	cJsonOk += '}'

	oSmartOk := FWRest():New(cSmartOk)
	oSmartOk:setPath(cUrlPath)
	oSmartOk:setPostParams(EncodeUTF8(cJsonOk))
	oSmartOk:Post(aHeader)

	If FWJsonDeserialize(oSmartOk:GetResult(), @oObjOk)

		If Type("oObjOk:status:codigo") == "C"

			If oObjOk:status:codigo == "001"
				lRet := .T.
			EndIf

		EndIf

	EndIf

Return lRet


//===================
//Geração de ConOut	=
//===================
Static Function GeraConOut()

	ConOut(Replicate("=",100))
	Conout("Gravacao do CMV..........: " + SZQ->ZQ_NUM)
	Conout("Gravacao do Abastecimento: " + SZQ->ZQ_ID)
	Conout("Data do Abastecimento....: " + cValToChar(SZQ->ZQ_DTABAST))
	Conout("Data de Gravacao.........: " + cValToChar(SZQ->ZQ_DTGRV))
	Conout("Status do Abastecimento..: " + SZQ->ZQ_STATUS)
	Conout("Placa....................: " + SZQ->ZQ_PLACA)
	Conout("Qtd. Litros..............: " + cValToChar(SZQ->ZQ_VOLUME))
	Conout("Valor Unit...............: " + cValToChar(SZQ->ZQ_PRCUNIT))
	Conout("Taxa Administrativa......: " + cValToChar(SZQ->ZQ_TXADM))
	Conout("Valor Unit c/ Taxa Adm...: " + cValToChar(SZQ->ZQ_PRCTX))
	Conout("Valor Total..............: " + cValToChar(SZQ->ZQ_VLTOTAL))
	Conout("Erro.....................: " + AllTrim(SZQ->ZQ_CODERRO) + "/" + AllTrim(SZQ->ZQ_DESCERR))
	Conout("Produto..................: " + AllTrim(SZQ->ZQ_PRODUT) + "/" + AllTrim(SZQ->ZQ_DESCP))
	Conout("Fornecedor...............: " + AllTrim(SZQ->ZQ_CGC) + "/" + AllTrim(SZQ->ZQ_NOMEFOR))
	Conout("Comnunica Retorno CTA....: " + SZQ->ZQ_RETCTA)
	ConOut(Replicate("=",100))

	Conout(" ")
	Conout(" ")
	Conout(" ")

Return


//=======================================
//Retorna data de Cencimento			=
//Vencimento todo dia 1 do mes seguinte	=
//com base na date do abastecimento		=
//=======================================
Static Function GetDtVenc(dDtBase)

	Local dDtRet 	:= CtoD("  /  /    ")
	Local cMes 	 	:= StrZero((Val(Month2Str(dDtBase)) + 1),2)
	Local cDia   	:= GetMv("MV_DIAVCTA", .F., "01")
	Local cAno   	:= Year2Str(dDtBase)
	Local lDtValida := GetMv("MV_DTVCTA", .F., .F.)

	If Val(cMes) > 12
		cMes := "01"
		cAno := Year2Str(YearSum(dDtBase,1))
	EndIf

	dDtRet := CtoD(cDia + "/" + cMes + "/" + cAno)

	If lDtValida
		While !DataValida(dDtRet)

			dDtRet := DaySum(dDtRet, 1)

		EndDo
	EndIf

Return dDtRet
