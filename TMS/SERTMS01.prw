#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.ch"
#INCLUDE "TBICODE.CH"
#INCLUDE "Directry.ch"
#INCLUDE "HBUTTON.CH"
#INCLUDE "Colors.ch"
#INCLUDE "Font.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE 'FWMVCDef.ch'
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH" 
#Include "APWEBSRV.CH"
#INCLUDE 'FWMVCDEF.CH'

//Constantes
#Define STR_PULA			Chr(13)+Chr(10)		//Pula linha 

/*/
FUNÇÃO PARA CRIAR E CALCULAR LOTE AUTOMATICAMENTE. 
@author FBSolutions
@since 20/07/2019
@version 1.0
@example U_SERTMS01()
@obs 
/*/

//U_FBTMSNFE()
User Function SERTMS01()

Local cReceb    := SuperGetMV("MV_X_IXMLR",.F.,.T.) 
Local cProcess  := SuperGetMV("MV_X_IXMLP",.F.,.T.) 

Local oNF
Local oIDE     := ''
Local oRem     := ''
Local oDest    := ''
Local oItens   := ''
Local oTotalNF := ''
Local aFiles   := {}
Local nI, nIt
Local nPosFrt  := 1
Local cIdenf   := ".-FRETE:"
Local nLenID   := Len(cIdenf)

Private lErro := .F.

Private cCGCRem 	:= ''
Private dDtEmb 		:= ''
Private cCGCDes 	:= ''
Private cCGCCon 	:= ''
Private cCGCDpc 	:= ''
Private cCGCDev 	:= ''
Private cTipTra 	:= ''
Private cTipFre 	:= ''
Private cDocto 	    := ''
Private cSerie 	    := ''
Private dEmiNFC 	:= CTOD("  /  /  ")
Private cCodPro 	:= Space(TamSX3("B1_COD")[1])
Private cCodNCM 	:= ''
Private cCodEmb 	:= ''
Private nQtdVol 	:= 0
Private nValor   	:= 0
Private nValTot     := 0
Private cPlacaVei   := ""
Private nPeso 	    := 0
Private nPesoM3 	:= 0
Private nValSeg 	:= 0
Private cFilDpc 	:= ''
Private cCtrDpc 	:= ''
Private cStatus 	:= ''
Private nMetroM3 	:= 0
Private cSQIDes 	:= ''
Private cCFOPNF 	:= ''
Private nBaseIC 	:= 0
Private nValICM 	:= 0
Private cNFEID 		:= ''
Private nBasIST 	:= 0
Private nValIST 	:= 0
Private cDE7CODCLI  := ''
Private cDE7LOJCLI  := ''
Private cDE7NOMCLI  := ''
Private cDE7PRDEMB  := ''
Private cDE7DSCEMB  := ''

Private aErro       := {}

Private lOKCfg      := .T.

Private cEmpTrans   := "01"

Private aNotaSel    := {}
Private aGerLote    := {}

Private cServLot    := SuperGetMV("MV_X_SERVL",.F.,.T.) 
Private rValFrete   := 0

Private oVeic
Private cVeic := Space(TamSX3("DA3_COD")[01])

Private oReb01
Private cReb01 := Space(TamSX3("DA3_COD")[01])

Private oReb02
Private cReb02 := Space(TamSX3("DA3_COD")[01])

Private oReb03
Private cReb03 := Space(TamSX3("DA3_COD")[01])

Private oMot
Private cMot := Space(TamSX3("DA4_COD")[01])

//RPCSETTYPE(3) // não consome licença
//Prepare Environment Empresa "01" Filial "01"


	CfgImp()
	
	While lOKCfg .AND. ( Empty(cVeic) .OR. Empty(cMot) )  
		if Empty(cVeic) .AND. Empty(cMot)
			Alert("Para continuar, digite um veiculo e um motorista!")
		elseif Empty(cVeic)
			Alert("Para continuar, digite um veiculo!")
		elseif Empty(cMot)
			Alert("Para continuar, digite um motorista!")
		endif
		
		CfgImp()
	EndDo
	
	
	lOKCfg := .t.
	
	If !lOKCfg
		Alert('Operação cancelada.')
		Return 
	EndIf
	
	cUsr := RetCodUsr()
	
	If !ExistDir(cReceb + cUsr)
		MakeDir(cReceb + cUsr)
	EndIf	
	cReceb := cReceb + cUsr + "\"
	
	If !ExistDir(cProcess + cUsr)
		MakeDir(cProcess + cUsr)
	EndIf	
	cProcess := cProcess + cUsr + "\"
	
	aEval(Directory(cReceb + "*.XML"), { |aFile| FERASE(cReceb + aFile[F_NAME],Nil,.F.) })
	
	/*aEraseFiles := {}
	ADIR(cReceb + "*.XML", aEraseFiles)
	For nErase:=1 to Len(aFiles)
		aEraseFiles
	Next nErase*/
	
	If !CopyFiles(cReceb)
		Alert('Nenhum arquivo selecionado. Tente novamente.')
		Return
	EndIf
	
	ADIR(cReceb + "*.XML", aFiles)
	
	If Len(aFiles) < 1
		Alert('Nenhum arquivo selecionado')
		Return
	EndIf
	
	/*If lCheckBox1 .AND. Len(aFiles) < 5
		Alert("Para emitir CT-e Único é necessário selecionar 5 ou mais arquivos.")
		Return
	EndIf*/
	
	c_Lote := GETSX8NUM("DTP","DTP_LOTNFC")
	RecLock("DTP",.T.)
	
	Replace DTP_FILIAL With xFilial("DTP")
	Replace DTP_FILORI With cFilAnt
	Replace DTP_LOTNFC With c_Lote
	Replace DTP_DATLOT With Date()
	Replace DTP_HORLOT With StrTran(Time(),":","")
	Replace DTP_QTDLOT With Len(aFiles)
	Replace DTP_QTDDIG With Len(aFiles)
	Replace DTP_STATUS With '2'
	Replace DTP_TIPLOT With '3'
	Replace DTP_RATEIO With '2'
	Replace DTP_X_VEIC With cVeic
	Replace DTP_X_MOTO With cMot
	Replace DTP_X_REB1 With cReb01
	Replace DTP_X_REB2 With cReb02
	Replace DTP_X_REB3 With cReb03
	
	MsUnLock()
	
	//TCSQLExec("UPDATE " + RetSQLName("DTP") + " SET DTP_X_VEIC = '" + cVeic + "', DTP_X_MOTO = '" + cMot + "' WHERE D_E_L_E_T_ = ' ' AND DTP_FILORI = '" + cFilAnt + "' AND DTP_LOTNFC = '" + c_Lote + "' ")
	
	For nI:=1 to Len(aFiles)
	
		//Alert(aFiles[nI])
	
		cCGCRem 	:= ''
		dDtEmb 		:= ''
		cCGCDes 	:= ''
		cCGCCon 	:= ''
		cCGCDpc 	:= ''
		cCGCDev 	:= ''
		cTipTra 	:= ''
		cTipFre 	:= ''
		cDocto 		:= ''
		cSerie 		:= ''
		dEmiNFC 	:= CTOD("  /  /  ")
		cCodPro 	:= Space(TamSX3("B1_COD")[1])
		cCodNCM		:= ''
		cCodEmb 	:= ''
		nQtdVol 	:= 0
		nValor 		:= 0
		cPlacaVei   := ""
		nPeso 		:= 0
		nPesoM3 	:= 0
		nValSeg 	:= 0
		cFilDpc 	:= ''
		cCtrDpc 	:= ''
		cStatus 	:= ''
		nMetroM3 	:= 0
		cSQIDes 	:= ''
		cCFOPNF 	:= ''
		nBaseIC 	:= 0
		nValICM 	:= 0
		cNFEID 		:= ''
		nBasIST 	:= 0
		nValIST 	:= 0
		rValFrete   := 0
	
		lErro  := .F.
	
		cFile  := cReceb   + aFiles[nI]
		cFileP := cProcess + aFiles[nI]
	
		nHdl  := fOpen(cFile, 0)
	
		If nHdl == -1
			If !Empty(cFile)
				MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto. Verifique os parametros.","Atencao!")
				//criar log de erro
			Endif
		Else
	
			nTamFile := fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			cBuffer  := Space(nTamFile)
			nBtLidos := fRead(nHdl,@cBuffer,nTamFile)
			fClose(nHdl)
	
			cAviso := ""
			cErro  := ""
			oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)
	
			If Type("oNFe:_NfeProc") <> "U"
				oNF 	:= oNFe:_NFeProc:_NFe
				oProtNFe := oNFe:_NFeProc:_ProtNFE
			Else
				oNF 	:= oNFe:_NFe
				oProtNFe := oNFe:_ProtNFE
			Endif
	
			/*********************************************
			*   Criando atalhos para acessar as tags     *
			*********************************************/
			oIDE     := oNF:_InfNfe:_Ide
			oRem     := oNF:_InfNfe:_Emit
			oDes     := oNF:_InfNfe:_Dest
			oItens   := oNF:_InfNfe:_Det
			oTotalNF := oNF:_InfNfe:_Total:_ICMSTot
			oTransp  := oNF:_InfNfe:_Transp
			oInfAdic := oNF:_InfNfe:_InfAdic
			/*********************************************
			* Fim - Criando atalhos para acessar as tags *
			*********************************************/
	
			/******************************************************
			*  Alimentando as variaveis que serao gravadas        *
			******************************************************/
	
			cCGCRem := oRem:_CNPJ:TEXT
			
			cCliRem := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCRem), "A1_COD")
			cLojRem := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCRem), "A1_LOJA")
					
			If Empty(cCliRem)
				If MsgYesNo('Remetente de CNPJ ' + Transform(cCGCRem, PesqPict("SA1","A1_CGC")) + ' não foi cadastrado. Deseja incluir agora?', 'Cliente não encontrado')
					CadSA1(oRem,oRem:_ENDEREMIT)
					//FWExecView("Inclusão Cliente Remetente - Importação XML", "CRMA980",3)
					cCliRem := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCRem), "A1_COD")
					cLojRem := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCRem), "A1_LOJA")
					If Empty(cCliRem)
						MsgAlert("Inclua o cliente remetente antes de continuar.")
						excLote(c_Lote)
						Return
					EndIf
				Else
					MsgAlert("Inclua o cliente remetente antes de continuar.")
					excLote(c_Lote)
					Return
				EndIf	
			EndIf
			
			dDtEmb  := DATE() //oRem:_CNPJ
			If Type('oDes:_CNPJ:TEXT') == 'U' //Exportação, deve pular o arquivo
				Loop
			EndIf
			cCGCDes := oDes:_CNPJ:TEXT
			
			cCliDes := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCDes), "A1_COD")
			cLojDes := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCDes), "A1_LOJA")
			
			If lCheckBox3
				cCliDes := SubStr(GetMV("MV_X_CLDIV"),1,6)
				cLojDes := SubStr(GetMV("MV_X_CLDIV"),7,2)
			EndIf
			
			If Empty(cCliDes) .AND. !lCheckBox2
				If MsgYesNo('Destinatário de CNPJ ' + Transform(cCGCDes, PesqPict("SA1","A1_CGC")) + ' não foi cadastrado. Deseja incluir agora?', 'Cliente não encontrado')
					
					CadSA1(oDes,oDes:_ENDERDEST)
					//FWExecView("Inclusão Cliente Destinatário - Importação XML", "CRMA980",3)
					cCliDes := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCDes), "A1_COD")
					cLojDes := Posicione("SA1", 3, xFilial("SA1")+AllTrim(cCGCDes), "A1_LOJA")
					If Empty(cCliDes)
						MsgAlert("Inclua o cliente destinatário antes de continuar.")
						excLote(c_Lote)
						Return
					EndIf
				Else
					MsgAlert("Inclua o cliente destinatário antes de continuar.")
					excLote(c_Lote)
					Return
				EndIf	
			EndIf
	
			//cCGCCon := oCon:_CNPJ
			//cCGCDpc := oDpc:_CNPJ
	
			/*
			0- Por conta do emitente;
			1- Por conta do destinatario/remetente;
			2- Por conta de terceiros;
			9- Sem frete. (V2.0)
			*/
	
			If oTransp:_modFrete:TEXT == '0'
				cCGCDev := oRem:_CNPJ:TEXT
				cTipFre := '1'
			ElseIf oTransp:_modFrete:TEXT == '1'
				cCGCDev := oDes:_CNPJ:TEXT
				cTipFre := '2'
			ElseIf oTransp:_modFrete:TEXT == '2'
				cCGCDev := oDev:_CNPJ:TEXT
				cTipFre := '2'
			EndIf
	
			cTipTra := '1'
	
			cDocto  := StrZero(Val(oIDE:_nNF:TEXT), 9)
			cSerie  := StrZero(Val(oIDE:_Serie:TEXT), 3)
			dEmiNFC := CTOD(SubStr(oIDE:_dhEmi:TEXT, 9, 2)+'/'+SubStr(oIDE:_dhEmi:TEXT, 6, 2)+'/'+SubStr(oIDE:_dhEmi:TEXT, 1, 4))
	
			//If Empty(cCodPro)
				//aAdd(aErro, {cDocto, cSerie, 'Produto X Embarcador não cadastrado'})
				//lErro := .T.
			//Else
	
				//nQtdVol := oTotalNF:_
				//nPeso   := nPeso
				//nPesoM3 := oTotalNF:_
				//nValSeg := oTotalNF:_
	
				//cFilDpc := oRem
				//cCtrDpc := oRem
				cStatus := '1'
				//nMetroM3:= oRem
				//cSQIDes := oRem
				//cCFOPNF := IIF(Type(oItens) == 'A', oItens[1]:_Prod:_CFOP:TEXT, oItens:_Prod:_CFOP:TEXT)
				nBaseIC := Val(oTotalNF:_vBC:TEXT)
				nValICM := Val(oTotalNF:_vICMS:TEXT)
				cNFEID  := oProtNFe:_infProt:_chNFe:TEXT
				//nBasIST := oRem
				//nValIST := oRem
	
				/*If ValType(oItens) == 'A'
					For nIt := 1 To Len(oItens)
	
						//nQtdVol += oItens[nIt]:_Prod:_cProd
						cCodEmb := IIF(lCodEmb(oItens[nIt]:_Prod:_uCom:TEXT), oItens[nIt]:_Prod:_uCom:TEXT, "")
						cCodPro := cGetCodPro(cCGCDev, oItens[nIt]:_Prod:_cProd:TEXT, oItens[nIt]:_Prod:_NCM:TEXT)
						nValor  += Val(oItens[nIt]:_Prod:_vProd:TEXT)
						nPeso   += Val(oItens[nIt]:_Prod:_qCom:TEXT)
						//nPesoM3 += Val(oItens[nIt]:_Prod:_cProd:TEXT)
						//nValSeg += oItens[nIt]:_Prod:_cProd
	
						If Empty(cCodPro) .OR. Empty(cCodEmb)
							lErro := .T.
							//adicionar log de produtos nao cadastrados com NCM ou no De/Para
						EndIf
	
						GrvDE5()
	
					Next nIt
				ElseIf ValType(oItens) == 'O'
	
					cCodEmb := IIF(lCodEmb(oItens:_Prod:_uCom:TEXT), oItens:_Prod:_uCom:TEXT, "")
					cCodPro := cGetCodPro(cCGCDev, oItens:_Prod:_cProd:TEXT, oItens:_Prod:_NCM:TEXT)
					nValor  += Val(oItens:_Prod:_vProd:TEXT)
					nPeso   += Val(oItens:_Prod:_qCom:TEXT)
	
					If Empty(cCodPro) .OR. Empty(cCodEmb)
						Alert('Não encontrou Codigo do Produto ou Embalagem')
						lErro := .T.
						//adicionar log de produtos nao cadastrados com NCM ou no De/Para
					EndIf
	
					GrvDE5()
				EndIf*/
	
				/******************************************************
				*  Fim - Alimentando as variaveis que serao gravadas  *
				******************************************************/
				_cCodPro := ""
				If ValType(oItens) == 'A'
					_cCodPro := fGetCodPro(oRem:_CNPJ:TEXT, oItens[1]:_Prod:_cProd:TEXT, oItens[1]:_Prod:_NCM:TEXT)//cGetCodPro(oRem:_CNPJ:TEXT, oItens[1]:_Prod:_cProd:TEXT, oItens[1]:_Prod:_NCM:TEXT)
					
					/*If Empty(_cCodPro)
						//Alert("A referencia do produto " + oItens[1]:_Prod:_cProd:TEXT + " da NF-e " + cDocto + "-" + cSerie + " nao existe no sistema.Ajuste o cadastro e refaça a importação.")
						//Exit
						_cCodPro := cGetCodPro(oRem:_CNPJ:TEXT, oItens[1]:_Prod:_cProd:TEXT, oItens[1]:_Prod:_NCM:TEXT, .T.)
					EndIf */
					
					If Empty(_cCodPro)
						MsgAlert("O produto " + oItens[1]:_Prod:_cProd:TEXT + " do cliente de CNPJ " + Transform(oRem:_CNPJ:TEXT, PesqPict("SA1","A1_CGC")) + " não foi cadastrado. <b>Realize o cadastro antes de continuar. </b>")
						excLote(c_Lote)
						Return
					EndIf 
					
					lTemVol := .F.
					nQtdVol := 0
					For nIt := 1 To Len(oItens)
					
						cCodEmb := cGetEmb(oItens[nIt]:_Prod:_uCom:TEXT)
						cCodPro := fGetCodPro(oRem:_CNPJ:TEXT, oItens[nIt]:_Prod:_cProd:TEXT, oItens[nIt]:_Prod:_NCM:TEXT) //cGetCodPro(oRem:_CNPJ:TEXT, oItens[nIt]:_Prod:_cProd:TEXT, oItens[nIt]:_Prod:_NCM:TEXT)						           
						
						/*If Empty(cCodPro)
							//Alert("A referencia do produto " + oItens[nIt]:_Prod:_cProd:TEXT + " da NF-e " + cDocto + "-" + cSerie + " nao existe no sistema.Ajuste o cadastro e refaca a importacao.")
							cCodPro := cGetCodPro(oRem:_CNPJ:TEXT, oItens[nIt]:_Prod:_cProd:TEXT, oItens[nIt]:_Prod:_NCM:TEXT, .T.)
							//lErro := .T.
							//Exit														
						EndIf */
	
						If Type("oTransp:_Vol:_pesoB:TEXT") <> "U"
							nPeso   := Val(oTransp:_Vol:_pesoB:TEXT)
						Else
							nPeso   := 0
						EndIf	
						
						If Type("oTransp:_Vol:_qVol:TEXT") <> "U"
							nQtdVol := Val(oTransp:_Vol:_qVol:TEXT)
							lTemVol := .T.
						Else
							nQtdVol   := 0
						EndIf	
						
						If Type("oTransp:_veicTransp:_placa:TEXT") <> "U"
							cPlacaVei   := Alltrim(Posicione("DA3", 3, xFilial("DA3") + Substr(oTransp:_veicTransp:_placa:TEXT,1 , 3) + "-" + Substr(oTransp:_veicTransp:_placa:TEXT,4 , 4), "DA3_COD") ) + " " + Alltrim(Posicione("DA3", 3, xFilial("DA3") + Substr(oTransp:_veicTransp:_placa:TEXT,1 , 3) + "-" + Substr(oTransp:_veicTransp:_placa:TEXT,4 , 4), "DA3_DESC") )
						Else
							cPlacaVei   := ""
						EndIf
						
						// Verifica se existe informacoes complementares
						If Type("oInfAdic:_infCpl:TEXT") <> "U"
						
							cTexto := oInfAdic:_infCpl:TEXT
							
							nPosFrt	:= At( cIdenf, oInfAdic:_infCpl:TEXT,nPosFrt)
							
							// Verifica se existe o valor do frete
							If  nPosFrt > 0
								// Recupera o valor do Frete
								rValFrete := Val(StrTran( SubStr( cTexto, nPosFrt + nLenID, AT("-.",cTexto,nPosFrt + nLenID) - (nPosFrt + nLenID)),",","."))
							End if
													
						End If
						
						If rValFrete == 0 
							If Type(oTotalNF:_vFrete:TEXT) <> "U"
								rValFrete   := Val(oTotalNF:_vFrete:TEXT)
							Else
								rValFrete   := 0
							EndIf		
						End IF				
						
						If !lTemVol
							nQtdVol += Val(oItens[1]:_Prod:_qCom:TEXT) 
						EndIf
						
						nValor  := Val(oTotalNF:_vNF:TEXT)
						cCFOPNF := oItens[nIt]:_Prod:_CFOP:TEXT
	
						If AllTrim(_cCodPro) <> AllTrim(cCodPro)
	
							/*Begin Transaction
	
							GrvDTC(c_Lote)
						    If lErro
						    	DisarmTransaction()
						    EndIf
	
						    End Transaction */
						    
						    fGravNotas(c_Lote)
	
							_cCodPro  := cCodPro
							nValor    := 0
							nPeso     := 0
							cPlacaVei := ""							
							rValFrete   := 0
						
						ElseIf nIt == Len(oItens)
							/*Begin Transaction
	
							GrvDTC(c_Lote)
						    If lErro
						    	DisarmTransaction()
						    EndIf
	
						    End Transaction */
						    
						    fGravNotas(c_Lote)
						EndIf
	
					Next nIt
					
				Else
					
					lTemVol := .F.
					_cCodPro := fGetCodPro(oRem:_CNPJ:TEXT, oItens:_Prod:_cProd:TEXT, oItens:_Prod:_NCM:TEXT)//cGetCodPro(oRem:_CNPJ:TEXT, oItens:_Prod:_cProd:TEXT, oItens:_Prod:_NCM:TEXT)
					
					/*If Empty(_cCodPro)
						//Alert("A referencia do produto " + oItens:_Prod:_cProd:TEXT + " da NF-e " + cDocto + "-" + cSerie + " nao existe no sistema.Ajuste o cadastro e refaça a importação.")
						//Exit
						_cCodPro := cGetCodPro(oRem:_CNPJ:TEXT, oItens:_Prod:_cProd:TEXT, oItens:_Prod:_NCM:TEXT, .T.)
					EndIf */
					
					If Empty(_cCodPro)
						MsgAlert("O produto " + oItens:_Prod:_cProd:TEXT + " do cliente de CNPJ " + Transform(oRem:_CNPJ:TEXT, PesqPict("SA1","A1_CGC")) + " não foi cadastrado. <b> Realize o cadastro antes de continuar. </b>")
						excLote(c_Lote)
						Return
					EndIf				
					
					cCodEmb := cGetEmb(oItens:_Prod:_uCom:TEXT)
					cCodPro := fGetCodPro(oRem:_CNPJ:TEXT, oItens:_Prod:_cProd:TEXT, oItens:_Prod:_NCM:TEXT) //cGetCodPro(oRem:_CNPJ:TEXT, oItens:_Prod:_cProd:TEXT, oItens:_Prod:_NCM:TEXT)
					
					/*If Empty(cCodPro)
						//Alert("A referencia do produto " + oItens:_Prod:_cProd:TEXT + " da NF-e " + cDocto + "-" + cSerie + " nao existe no sistema.Ajuste o cadastro e refaca a importacao.")
						cCodPro := cGetCodPro(oRem:_CNPJ:TEXT, oItens:_Prod:_cProd:TEXT, oItens:_Prod:_NCM:TEXT, .T.)
						//lErro := .T.
						//Exit
					EndIf */
	
					If Type("oTransp:_Vol:_pesoB:TEXT") <> "U"
						nPeso   := Val(oTransp:_Vol:_pesoB:TEXT)
					Else
						nPeso   := 0
					EndIf
					
					If Type("oTransp:_veicTransp:_placa:TEXT") <> "U"
						cPlacaVei   := Alltrim(Posicione("DA3", 3, xFilial("DA3") + Substr(oTransp:_veicTransp:_placa:TEXT,1 , 3) + "-" + Substr(oTransp:_veicTransp:_placa:TEXT,4 , 4), "DA3_COD") ) + " " + Alltrim(Posicione("DA3", 3, xFilial("DA3") + Substr(oTransp:_veicTransp:_placa:TEXT,1 , 3) + "-" + Substr(oTransp:_veicTransp:_placa:TEXT,4 , 4), "DA3_DESC") )
					Else
						cPlacaVei   := ""
					EndIf	
					
					// Verifica se existe informacoes complementares
					If Type("oInfAdic:_infCpl:TEXT:TEXT") <> "U"
					
						cTexto := oInfAdic:_infCpl:TEXT
						
						nPosFrt	:= At( cIdenf, oInfAdic:_infCpl:TEXT,nPosFrt)
						
						// Verifica se existe o valor do frete
						If  nPosFrt > 0
							// Recupera o valor do Frete
							rValFrete := Val(SubStr( cTexto, nPosFrt + nLenID, AT("-.",cTexto,nPosFrt + nLenID) - (nPosFrt + nLenID)))
						End if
												
					End If
					
					If rValFrete == 0 
					
						If Type(oTotalNF:_vFrete:TEXT) <> "U"
							rValFrete   := Val(oTotalNF:_vFrete:TEXT)
						Else
							rValFrete   := 0
						EndIf
					End If
					
					If Type("oTransp:_Vol:_qVol:TEXT") <> "U"
						lTemVol := .T.
						nQtdVol := Val(oTransp:_Vol:_qVol:TEXT)
					Else
						nQtdVol   := 0
					EndIf	
					
					If !lTemVol
						nQtdVol += Val(oItens:_Prod:_qCom:TEXT) 
					EndIf
					
					nValor  := Val(oTotalNF:_vNF:TEXT)
					cCFOPNF := oItens:_Prod:_CFOP:TEXT				
						
					/*Begin Transaction
	
					GrvDTC(c_Lote)
				    If lErro
				    	DisarmTransaction()
				    EndIf
	
				    End Transaction */
				    fGravNotas(c_Lote)
	
					_cCodPro  := cCodPro
					nValor    := 0
					nPeso     := 0
					cPlacaVei := ""
					rValFrete   := 0
						
				EndIf
	
				/*If Empty(cCodPro) .OR. Empty(cCodEmb)
					Alert(aFiles[nI]+':Nao encontrou Codigo do Produto ou Embalagem')
					lErro := .T.
					Loop
					//adicionar log de produtos nao cadastrados com NCM ou no De/Para
				EndIf*/
	
			//EndIf
	
	    Endif
	
	    If !lErro
	    	If (FRENAME ( cFile , cFileP ) == -1)
				aAdd(aErro, {cDocto, cSerie, 'Erro ao mover o arquivo ' + aFiles[nI] + '.xml'})
	    	EndIf
	    EndIf
	
	Next nI
	
	ConfirmSX8()
	
	//Corrigir - colocar flag de erro e mudar a mensagem
	//Aviso("Importação", "Importação dos arquivos realizada com sucesso.", {"OK"})
	
	fGeraTela()

Return


/*---------------------------------------------------------------------*
 | Func:  fGeraTela                                                    |
 | Autor: fbsolutions                                                  |
 | Data:  20/07/2019                                                   |
 | Desc:  Função que monta a tela para selecionar as notas do XML      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fGeraTela()
Local 	aPerg     	:= {}
Private cPerg       := "SERTMS01" 
Private cCadastro 	:= "Notas importadas"
Private aRotina 	:= {} 
Private aTitulos	:= {}   
Private aIndexQRY   := {}   
Private aIndexSE2   := {}
Private cExp		:= ""
Private aFiltro 	:= {}   
Private bFiltraBrw	:= {|| Nil }  
Private _cQuery		:= ""      
Private cText		:= ""    
Private aCores		:= {}	
Private aCampos		:= {}
Private cArqTrab    := ""
Private cFiltro		:= ""
Private nOrdPesq    := 1
Private cCondicao 	:= ""

Private aPedSelec   := {} // Array que grava os pedidos selecionados

Private _URL		:= ""
Private _Token		:= ""
Private cDirXML     := ""
Private aCores      := {}						

	
	aAdd(aCampos, {'ZZMARCA'	,   'C',002,0})
	aAdd(aCampos, {'FILORI' 	,  	'C',TAMSX3("DTC_FILORI")[1]	,TAMSX3("DTC_FILORI")[2]})
	aAdd(aCampos, {'LOTNFC'		, 	'C',TAMSX3("DTC_LOTNFC")[1]	,TAMSX3("DTC_LOTNFC")[2]})
	aAdd(aCampos, {'NUMNFC'		,	'C',TAMSX3("DTC_NUMNFC")[1]	,TAMSX3("DTC_NUMNFC")[2]})
	aAdd(aCampos, {'SERNFC'		,	'C',TAMSX3("DTC_SERNFC")[1]	,TAMSX3("DTC_SERNFC")[2]})
	aAdd(aCampos, {'NFEID' 	    ,	'C',TAMSX3("DTC_NFEID")[1]	,TAMSX3("DTC_NFEID")[2]})
	aAdd(aCampos, {'CLIREM' 	,	'C',TAMSX3("A1_NOME")[1]	,TAMSX3("A1_NOME")[2]})
	aAdd(aCampos, {'CLIDES' 	,	'C',TAMSX3("A1_NOME")[1]	,TAMSX3("A1_NOME")[2]})    
	aAdd(aCampos, {'CLIDEV' 	,	'C',TAMSX3("A1_NOME")[1]	,TAMSX3("A1_NOME")[2]}) 
	aAdd(aCampos, {'QTDVOL'	    ,	'C',TAMSX3("DTC_QTDVOL")[1]	,TAMSX3("DTC_QTDVOL")[2]})
  	aAdd(aCampos, {'PESO'   	,	'C',TAMSX3("DTC_PESO")[1]	,TAMSX3("DTC_PESO")[2]})
 	aAdd(aCampos, {'VALOR'  	,	'C',TAMSX3("DTC_VALOR")[1]	,TAMSX3("DTC_VALOR")[2]})	
 	aAdd(aCampos, {'VEIC'     	,	'C',TAMSX3("DA3_DESC")[1]	,TAMSX3("DA3_DESC")[2]})		     
																						
	If !geraBrowse(.F.)
		Return
	EndIf	

	aCpos := {} 
	aAdd(aCpos,{"ZZMARCA"        	,," "            })
	aAdd(aCpos,{"FILORI"      		,,"Fil. Ori."    })
	aAdd(aCpos,{"LOTNFC"    		,,"Lote"         })
	aAdd(aCpos,{"NUMNFC"      		,,"Nota"         })
	aAdd(aCpos,{"SERNFC"     		,,"Serie"        })	      
	aAdd(aCpos,{"NFEID"     		,,"Chave"        })
	aAdd(aCpos,{"VEIC"     		    ,,"Veículo"      })
	aAdd(aCpos,{"CLIREM"     		,,"Cliente Rem." })
	aAdd(aCpos,{"CLIDES"     		,,"Cliente Dest."})
	aAdd(aCpos,{"CLIDEV"     		,,"Cliente Tom." })
	aAdd(aCpos,{"QTDVOL"     		,,"Volume"       })
	aAdd(aCpos,{"PESO"     		    ,,"Peso"         })
	aAdd(aCpos,{"VALOR"     		,,"Valor"        })
	
	cMarca    := Getmark()       
	
	aRotina := {{"Gerar Lote"     ,"u_fGerLote()" ,   0 , 1},;
	            {"Marcar todos"   ,"u_MarPVM01(1)",   0 , 1},;
	            {"Desmarcar todos","u_MarPVM01(2)",   0 , 1},; 
	            {"Parametros"     ,"u_ParBrow()"  ,   0 , 1} }
	                                  
	dbSelectArea("TMPNT")
	TMPNT->(dbGoTop())
	
	MarkBrow("TMPNT","ZZMARCA", ,aCpos, ,cMarca, , , , , , , , , )

Return

/*-------------------------------------------------------------------------------*
 | Func:  ParBrow                                                                |
 | Autor: fbsolutions                                                            |
 | Data:  21/08/2019                                                             |
 | Desc:  Função que atribuirá alguns parametros na tela                         |
 | Obs.:  /                                                                      |
 *-------------------------------------------------------------------------------*/
User Function ParBrow(cOpc)
Local aArea    := GetArea()
Local aPergs   := {}
Local lRet    
Local aRetP    := {}

Private cVeiDe  := Space(TamSx3("DA3_COD")[01])
Private cVeiAte := Space(TamSx3("DA3_COD")[01])

	aAdd( aPergs ,{1,"Veiculo De : ", cVeiDe ,"@!",'.T.',"DA3",'.T.',30,.F.}) 
	aAdd( aPergs ,{1,"Veiculo Ate: ", cVeiAte,"@!",'.T.',"DA3",'.T.',30,.F.})   
	
	If ParamBox(aPergs ,"Parametros Adicionais", aRetP)            			     
    	cVeiDe   := iif("ZZZZZ" $ aRetP[1], "", aRetP[1])
    	cVeiAte  := iif("ZZZZZ" $ aRetP[2], "", aRetP[2])
         	
    	fLimpGRID()
    	geraBrowse(.T.) 
    	
    	dbSelectArea("TMPNT")
    	TMPNT->(dbGoTop())   		 
	EndIf

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fLimpGRID                                                    |
 | Autor: FbSolutions                                                  |
 | Data:  21/08/2019                                                   |
 | Desc:  Função que limpa os registros listados no GRID               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fLimpGRID()
Local cArea:=alias()
Local nRec :=recno()

	dbSelectArea('TMPNT')
	dbGotop()
	do while !eof()
		reclock('TMPNT',.F.)					
			dbDelete()	
	    msunlock()
		dbSkip()
	enddo

	dbSelectArea(cArea)
	dbGoto(nRec)
return


/*-------------------------------------------------------------------------------*
 | Func:  fGerLote                                                               |
 | Autor: fbsolutions                                                            |
 | Data:  23/07/2019                                                             |
 | Desc:  Função que irá tratar as notas selecionadas e iniciar gravação do lote |
 | Obs.:  /                                                                      |
 *-------------------------------------------------------------------------------*/
User Function fGerLote(cOpc)
Local aArea    := GetArea()
Local cCtrLote := "" // Variavel utilizada para controlar os lotes na hora de calcular.
Local lRetCalc := .T.

Private cMsgErro := ""

	If !MsgNoYes("Confirma geração dos lotes? ", "CONFIRMAÇÃO")
		return
	endif 
	
	TMPNT->(dbGoTop())	
	
	aGerLote := {}
	
	While !TMPNT->(EOF())
		If IsMark("ZZMARCA")	
			
			For iX := 1 to len(aNotaSel)
		
				if (aNotaSel[iX, 2] == TMPNT->FILORI) .AND. (aNotaSel[iX, 3] == TMPNT->LOTNFC) .AND. (aNotaSel[iX, 7] == TMPNT->NUMNFC) ;
				   .AND. (aNotaSel[iX, 6] == TMPNT->SERNFC) .AND. (aNotaSel[iX, 5] == TMPNT->NFEID) 
				
					AADD(aGerLote, aClone(aNotaSel[iX]))
				ENDIF
				
			Next iX 
							      				     			      
		EndIf			
		TMPNT->(dbSkip())
	EndDo
		
	if Len(aGerLote) == 0
		MsgAlert("Nenhuma nota selecionada, selecione ao menos 01 nota.")
		return 
	endif
	
	// Gravo os novos lotes na DTC
	For iX := 1 to Len(aGerLote)		
		GrvDTC2(aGerLote[iX])	
	next iX

	
	If Empty(cMsgErro)
	    
	    //Realizo o cálculo dos lotes	    
	    cCtrLote := aGerLote[1, 2] + aGerLote[1, 3] // Primeiro lote do Array
	    For iX := 1 to Len(aGerLote)
	    		
			if iX == Len(aGerLote) // Se for o ultimo registro eu mando calcular o lote	
				lRetCalc := TMSA200Prc( aGerLote[iX, 2], aGerLote[iX, 3] )
				if lRetCalc == .F. // Se .F. ocorreu algum erro na hora de calcular.
					cMsgErro += "Lote: " + aGerLote[iX, 2] + " " + aGerLote[iX, 3]  + STR_PULA
				endif		
									
			elseif aGerLote[iX + 1, 2] + aGerLote[iX + 1, 3] <> cCtrLote // Se o proximo lote do array for diferente do atual, eu mando calcular o lote
				lRetCalc := TMSA200Prc( aGerLote[iX, 2], aGerLote[iX, 3] )	
				if lRetCalc == .F. // Se .F. ocorreu algum erro na hora de calcular.
					cMsgErro += "Lote: " + aGerLote[iX, 2] + " " + aGerLote[iX, 3]  + STR_PULA
				endif				
				cCtrLote := aGerLote[iX, 2] + aGerLote[iX, 3]
				
			endif
			
		next iX
	    
	    If Empty(cMsgErro)
		    MsgInfo("Lotes criados e calculados com sucesso.")
		    CloseBrowse()
		else
			MsgAlert("<b>Ocorreram erros no calculo dos lotes. Contate o administrador.</b>" + STR_PULA + STR_PULA + cMsgErro)
		endif
	Else
		MsgAlert("<b>Ocorreram erros na criação dos lotes. Contate o administrador.</b>" + STR_PULA + STR_PULA + cMsgErro)		
	EndIf     

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  GrvDTC2                                                      |
 | Autor: fbsolutions                                                  |
 | Data:  23/07/2019                                                   |
 | Desc:  Função que grava o lote na DTC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GrvDTC2(aLote)
Local lRet := .T.		
	
	dbSelectArea('DTC')
	DTC->( dbSetOrder(2) )
	//DTC_FILIAL, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM, DTC_CODPRO, DTC_FILORI, DTC_LOTNFC, R_E_C_N_O_, D_E_L_E_T_
	If DTC->( dbSeek(xFilial('DTC') + aLote[7] + aLote[6] + aLote[14] + aLote[15]) )
		DTC->( dbCloseArea() )
		Return
	EndIf
	DTC->( dbCloseArea() )
	
	RecLock('DTC', .T.)
	
	Replace DTC_FILIAL	 With xFilial("DTC")
	Replace DTC_FILORI	 With aLote[2]
	Replace DTC_LOTNFC	 With aLote[3]
	Replace DTC_DATENT	 With aLote[4]
	Replace DTC_NFEID	 With aLote[5]
	Replace DTC_SERNFC	 With aLote[6]
	Replace DTC_NUMNFC	 With aLote[7]
	Replace DTC_CODPRO	 With aLote[8]
	Replace DTC_CODEMB	 With aLote[9]
	Replace DTC_EMINFC	 With aLote[10]
	Replace DTC_QTDVOL	 With aLote[11]
	Replace DTC_PESO 	 With aLote[12]
	Replace DTC_VALOR	 With aLote[13]
	Replace DTC_CLIREM	 With aLote[14] 
	Replace DTC_LOJREM	 With aLote[15]
	Replace DTC_CLIDES	 With aLote[16]
	Replace DTC_LOJDES	 With aLote[17]
	
	//1=Remetente;2=Destinatario;3=Consignatario;4=Despachante
	Replace DTC_DEVFRE	 With aLote[18]
	Replace DTC_CLIDEV	 With aLote[19]
	Replace DTC_LOJDEV	 With aLote[20]
	Replace DTC_CLICAL	 With aLote[21]
	Replace DTC_LOJCAL	 With aLote[22]
	Replace DTC_TIPFRE	 With aLote[23]
	Replace DTC_SERTMS	 With aLote[24]
	Replace DTC_TIPTRA	 With aLote[25]
	Replace DTC_SERVIC	 With aLote[26]
	Replace DTC_TIPNFC	 With aLote[27]
	Replace DTC_SELORI	 With aLote[28]
	Replace DTC_CDRORI	 With aLote[29]		
	
	Replace DTC_CDRDES	 With aLote[30]
	Replace DTC_CDRCAL	 With aLote[31]
	Replace DTC_EDI	 	 With aLote[32]
	Replace DTC_KM	 	 With aLote[33]
	Replace DTC_DISTIV	 With aLote[34]
	Replace DTC_CODNEG	 With aLote[35]
	Replace DTC_NCONTR	 With aLote[36]
	Replace DTC_DOCTMS	 With aLote[37]
	
	MsUnlock()
	
	//criaTabFrete(GetMV('MV_CDRORI'), aLote[30], cServLot)
	
	if ! fValInfo(aLote)
		cMsgErro += "Problemas para informar valor do frete. Tabela de frete não localizada"  + STR_PULA
	endif
	
	//Dou um dbSeek novamente para confirmar se o lote foi criado
	dbSelectArea('DTC')
	DTC->( dbSetOrder(1) ) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
	If ! DTC->( dbSeek(xFilial('DTC') + aLote[2] + aLote[3] + aLote[14] + aLote[15] ) )		
		cMsgErro += "Lote: " + aLote[2] + " " + aLote[3]  + STR_PULA
	EndIf
	DTC->( dbCloseArea() )

Return

/*---------------------------------------------------------------------*
 | Func:  fValInfo                                                     |
 | Autor: fbsolutions                                                  |
 | Data:  20/07/2019                                                   |
 | Desc:  Função que pega o val info para atrivuior o valor de frete   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fValInfo(aLotVF)
Local lRet    := .T.
Local aTabFre := {}
Local cTabFre := ""
Local cTipTab := ""
Local lValInf  := .F.


	aTabFre := TmsTabFre(aLotVF[21], aLotVF[22], aLotVF[26], aLotVF[23], aLotVF[35] )
	If !Empty(aTabFre)
		cTabFre   := aTabFre[1]
		cTipTab   := aTabFre[2]		
	EndIf
	
	if Empty(cTabFre)
		cTabFre   := fBuscTF(aLotVF[21], aLotVF[22], "TAB")
		cTipTab   := fBuscTF(aLotVF[21], aLotVF[22], "TIP")
	endif
	
	//cTabFre := "TB02"
	//cTipTab := "01"
	if ! Empty(cTabFre) .AND. ! Empty(cTipTab)
		
		if fConfTB(cTabFre, cTipTab) == .F.
			
			if aLotVF[39] <= 0
			
				dbSelectArea('DVR')
				DVR->( dbSetOrder(1) ) //DVR_FILIAL + DVR_FILORI + DVR_LOTNFC + DVR_CLIREM + DVR_LOJREM + DVR_CLIDES + DVR_LOJDES + DVR_SERVIC + DVR_NUMNFC + DVR_SERNFC + DVR_CODPRO + DVR_CODPAS + DVR_CODNEG
				DVR->(dbGoTop())
				If DVR->( dbSeek( xFilial('DVR') + aLotVF[2] + aLotVF[3] + aLotVF[14] + aLotVF[15] + aLotVF[16] + aLotVF[17] + aLotVF[26] + aLotVF[7] + aLotVF[6] + aLotVF[8] ) )
					
					While (!DVR->(EoF()) ) .AND. (DVR->DVR_FILIAL == xFilial('DVR') ) .AND. (DVR->DVR_FILORI == aLotVF[2]  )	.AND. (DVR->DVR_LOTNFC == aLotVF[3] ) ;
						  .AND. (DVR->DVR_CLIREM = aLotVF[14]) .AND. (DVR->DVR_LOJREM = aLotVF[15]) .AND. (DVR->DVR_CLIDES =  aLotVF[16]) .AND. (DVR->DVR_LOJDES = aLotVF[17]) ;
						  .AND. (DVR->DVR_SERVIC = aLotVF[26]) .AND. (DVR->DVR_NUMNFC = aLotVF[7]) .AND. (DVR->DVR_SERNFC = aLotVF[6]) .AND. (DVR->DVR_CODPRO = aLotVF[8]) 
						
						if DVR->DVR_VALOR > 0 														
							lValInf := .T. // Se .T. indica que ja foi informado valor para esse lote  																		
						endif
						
						DVR->(DbSkip())
					enddo
				endif
				DVR->( dbCloseArea() )
				
				if lValInf == .F. // Só irá apresentar a tela de valor informado caso se .F.
					dbSelectArea('DTC')
					DTC->( dbSetOrder(1) ) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
					If  DTC->( dbSeek(xFilial('DTC') + aLotVF[2] + aLotVF[3] + aLotVF[14] + aLotVF[15] + aLotVF[16] + aLotVF[17] ) )		
						cA050ValInf(4, aLotVF[7], aLotVF[6], aLotVF[8] )
					EndIf
					DTC->( dbCloseArea() )
				endif
				
			else
						
				dbSelectArea('DVR')
				DVR->( dbSetOrder(1) ) //DVR_FILIAL + DVR_FILORI + DVR_LOTNFC + DVR_CLIREM + DVR_LOJREM + DVR_CLIDES + DVR_LOJDES + DVR_SERVIC + DVR_NUMNFC + DVR_SERNFC + DVR_CODPRO + DVR_CODPAS + DVR_CODNEG
				DVR->(dbGoTop())
				If DVR->( dbSeek( xFilial('DVR') + aLotVF[2] + aLotVF[3] + aLotVF[14] + aLotVF[15] + aLotVF[16] + aLotVF[17] + aLotVF[26] + aLotVF[7] + aLotVF[6] + aLotVF[8] ) )
					
					While (!DVR->(EoF()) ) .AND. (DVR->DVR_FILIAL == xFilial('DVR') ) .AND. (DVR->DVR_FILORI == aLotVF[2]  )	.AND. (DVR->DVR_LOTNFC == aLotVF[3] ) ;
						  .AND. (DVR->DVR_CLIREM = aLotVF[14]) .AND. (DVR->DVR_LOJREM = aLotVF[15]) .AND. (DVR->DVR_CLIDES =  aLotVF[16]) .AND. (DVR->DVR_LOJDES = aLotVF[17]) ;
						  .AND. (DVR->DVR_SERVIC = aLotVF[26]) .AND. (DVR->DVR_NUMNFC = aLotVF[7]) .AND. (DVR->DVR_SERNFC = aLotVF[6]) .AND. (DVR->DVR_CODPRO = aLotVF[8]) 
						
						if DVR->DVR_VALOR <= 0 .AND.  DVR->DVR_CODPAS == '01'
							
							RecLock("DVR", .F.)		
							DVR->DVR_VALOR :=  aLotVF[39]				
							('DVR')->(MsUnlock())	
							
						endif
						
						DVR->(DbSkip())
					enddo
				ELSE
					RecLock('DVR', .T.)
			
					Replace DVR_FILIAL	 With xFilial('DVR')
					Replace DVR_FILORI	 With aLotVF[2]
					Replace DVR_LOTNFC	 With aLotVF[3]			
					Replace DVR_CLIREM	 With aLotVF[14] 
					Replace DVR_LOJREM	 With aLotVF[15]
					Replace DVR_CLIDES	 With aLotVF[16]
					Replace DVR_LOJDES	 With aLotVF[17]
					Replace DVR_SERVIC	 With aLotVF[26]
					Replace DVR_NUMNFC	 With aLotVF[7]
					Replace DVR_SERNFC	 With aLotVF[6]
					Replace DVR_CODPRO	 With aLotVF[8]
					Replace DVR_CODPAS	 With '01'
					Replace DVR_VALOR	 With aLotVF[39]				
					Replace DVR_CODNEG	 With aLotVF[35]
								
					MsUnlock()
					
				EndIf
				
				DVR->( dbCloseArea() )
				
			endif
			
			
			dbSelectArea('DVR')
			DVR->( dbSetOrder(1) ) //DVR_FILIAL + DVR_FILORI + DVR_LOTNFC + DVR_CLIREM + DVR_LOJREM + DVR_CLIDES + DVR_LOJDES + DVR_SERVIC + DVR_NUMNFC + DVR_SERNFC + DVR_CODPRO + DVR_CODPAS + DVR_CODNEG
			DVR->(dbGoTop())
			If DVR->( dbSeek( xFilial('DVR') + aLotVF[2] + aLotVF[3] + aLotVF[14] + aLotVF[15] + aLotVF[16] + aLotVF[17] + aLotVF[26] + aLotVF[7] + aLotVF[6] + aLotVF[8] ) )
				
				While (!DVR->(EoF()) ) .AND. (DVR->DVR_FILIAL == xFilial('DVR') ) .AND. (DVR->DVR_FILORI == aLotVF[2]  )	.AND. (DVR->DVR_LOTNFC == aLotVF[3] ) ;
					  .AND. (DVR->DVR_CLIREM = aLotVF[14]) .AND. (DVR->DVR_LOJREM = aLotVF[15]) .AND. (DVR->DVR_CLIDES =  aLotVF[16]) .AND. (DVR->DVR_LOJDES = aLotVF[17]) ;
					  .AND. (DVR->DVR_SERVIC = aLotVF[26]) .AND. (DVR->DVR_NUMNFC = aLotVF[7]) .AND. (DVR->DVR_SERNFC = aLotVF[6]) .AND. (DVR->DVR_CODPRO = aLotVF[8]) 
					
					if DVR->DVR_VALOR <= 0 .AND.  DVR->DVR_CODPAS == '01'					
						lRet := .F.
					endif
					
					DVR->(DbSkip())
				enddo
			else
				lRet := .F.
			endif
			DVR->( dbCloseArea() )
			
		endif
	else
		lRet := .F.
		
	endif
	
return lRet

/*---------------------------------------------------------------------*
 | Func:  fBuscTF                                                      |
 | Autor: fbsolutions                                                  |
 | Data:  03/09/2019                                                   |
 | Desc:  Função q busca a tabela de frete que esta informada no contrato   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fBuscTF(cCliCon, cLojCon, cFlag)
Local cRetTT := ""
Local cQuery := ""
	
	cQuery := "SELECT TOP 1 AAM.AAM_CONTRT, AAM.AAM_CODCLI, AAM.AAM_LOJA " + STR_PULA
	cQuery += "FROM " + RetSQLName("AAM") + " as AAM WITH(NOLOCK) " + STR_PULA	
	cQuery += "WHERE AAM.D_E_L_E_T_ = '' " + STR_PULA			
	cQuery += "AND AAM.AAM_CODCLI = '"+cCliCon+"' "	+ STR_PULA
	cQuery += "AND AAM.AAM_LOJA   = '"+cLojCon+"' "	+ STR_PULA
	cQuery += "AND AAM.AAM_STATUS = '1' " //ATIVO
	
	
	IF SELECT("QRY") > 0   
        QRY->(DbCloseArea())						       
    ENDIF 											       
	TCQuery cQuery Alias "QRY" New
 	DbSelectArea("QRY")
 	
 	QRY->(DbGoTop())	
	if !QRY->(Eof()) 
		if cFlag == "TAB" 
			cRetTT := Posicione("DDA", 1, xFilial("DDA") + QRY->AAM_CONTRT, "DDA_TABFRE") 		
		elseif cFlag == "TIP" 
			cRetTT := Posicione("DDA", 1, xFilial("DDA") + QRY->AAM_CONTRT, "DDA_TIPTAB")
		endif
	endif
	
	QRY->(DbCloseArea())
 
 return cRetTT

/*---------------------------------------------------------------------*
 | Func:  fConfTB                                                      |
 | Autor: fbsolutions                                                  |
 | Data:  03/09/2019                                                   |
 | Desc:  Função que verifica a configuração da tabela de frete (TMSA130)   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fConfTB(cTabCF, cTipCF)
Local lRetCTF := .T.
Local cQuery := ""
	
	cQuery := "SELECT DVE.DVE_CODPAS " + STR_PULA
	cQuery += "FROM " + RetSQLName("DVE") + " as DVE WITH(NOLOCK) " + STR_PULA	
	cQuery += "WHERE DVE.D_E_L_E_T_ = '' " + STR_PULA			
	cQuery += "AND DVE.DVE_FILIAL = '"+xFilial('DVE')+"' "	+ STR_PULA
	cQuery += "AND DVE.DVE_TABFRE = '"+cTabCF+"' "	+ STR_PULA
	cQuery += "AND DVE.DVE_TIPTAB = '"+cTipCF+"' "	+ STR_PULA
	
	
	IF SELECT("QRY") > 0   
        QRY->(DbCloseArea())						       
    ENDIF 											       
	TCQuery cQuery Alias "QRY" New
 	DbSelectArea("QRY")
 	
 	QRY->(DbGoTop())	
	if !QRY->(Eof()) 
		While !QRY->(Eof()) 
			
			if  Posicione("DT3", 1, xFilial("DT3") + QRY->DVE_CODPAS, "DT3_TIPFAI") == "07"
				lRetCTF := .F.
			endif
			
			QRY->(DBSKIP())
		EndDo
	endif
	
	QRY->(DbCloseArea())
 
 return lRetCTF

/*---------------------------------------------------------------------*
 | Func:  geraBrowse                                                   |
 | Autor: fbsolutions                                                  |
 | Data:  20/07/2019                                                   |
 | Desc:  Função que atribui os valores do array na tabela temporária  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function geraBrowse(lExectPar)
Local cQuery := ""
Local cWhe   := ""

	if lExectPar == .T.
		if Empty(cVeiDe) .AND. Empty(cVeiAte)
			lExectPar := .F.
		endif
	endif
	
	If Select("TMPNT") > 0
		TMPNT->(dbCloseArea())
	Endif

	cArq := CriaTrab(aCampos)
	
	DbUseArea( .T.,, cArq, "TMPNT", .T., .F. )

	IndRegua("TMPNT",cArq,"FILORI+LOTNFC+NUMNFC+SERNFC",,,"Criando Controles") 
	       
	For iX := 1 to len(aNotaSel)
		
		if 	lExectPar == .F.
			RecLock("TMPNT", .T.)	
			
			TMPNT->ZZMARCA 	:= ' '		
			TMPNT->FILORI 	:= aNotaSel[iX, 2]
			TMPNT->LOTNFC 	:= aNotaSel[iX, 3]
			TMPNT->NUMNFC 	:= aNotaSel[iX, 7]
			TMPNT->SERNFC 	:= aNotaSel[iX, 6]
			TMPNT->NFEID 	:= aNotaSel[iX, 5]
			TMPNT->VEIC 	:= aNotaSel[iX, 38]
		  	TMPNT->CLIREM 	:= Alltrim(Posicione("SA1", 1, xFilial("SA1") + aNotaSel[iX, 14] + aNotaSel[iX, 15], "A1_NOME") )
			TMPNT->CLIDES 	:= Alltrim(Posicione("SA1", 1, xFilial("SA1") + aNotaSel[iX, 16] + aNotaSel[iX, 17], "A1_NOME") )
			TMPNT->CLIDEV 	:= Alltrim(Posicione("SA1", 1, xFilial("SA1") + aNotaSel[iX, 19] + aNotaSel[iX, 20], "A1_NOME") )
			TMPNT->QTDVOL 	:= AllTrim(Transform(aNotaSel[iX, 11], PesqPict("DTC","DTC_QTDVOL")) )
			TMPNT->PESO 	:= AllTrim(Transform(aNotaSel[iX, 12], PesqPict("DTC","DTC_PESO")) )
			TMPNT->VALOR 	:= AllTrim(Transform(aNotaSel[iX, 13], PesqPict("DTC","DTC_VALOR")) )											 
			
			MsUnlock()	
		else
			if Substr(aNotaSel[iX, 38], 1, len(Space(TamSx3("DA3_COD")[01])) ) >= cVeiDe .AND. Substr(aNotaSel[iX, 38], 1, len(Space(TamSx3("DA3_COD")[01])) ) <= cVeiAte
				RecLock("TMPNT", .T.)	
				
				TMPNT->ZZMARCA 	:= ' '		
				TMPNT->FILORI 	:= aNotaSel[iX, 2]
				TMPNT->LOTNFC 	:= aNotaSel[iX, 3]
				TMPNT->NUMNFC 	:= aNotaSel[iX, 7]
				TMPNT->SERNFC 	:= aNotaSel[iX, 6]
				TMPNT->NFEID 	:= aNotaSel[iX, 5]
				TMPNT->VEIC 	:= aNotaSel[iX, 38]
			  	TMPNT->CLIREM 	:= Alltrim(Posicione("SA1", 1, xFilial("SA1") + aNotaSel[iX, 14] + aNotaSel[iX, 15], "A1_NOME") )
				TMPNT->CLIDES 	:= Alltrim(Posicione("SA1", 1, xFilial("SA1") + aNotaSel[iX, 16] + aNotaSel[iX, 17], "A1_NOME") )
				TMPNT->CLIDEV 	:= Alltrim(Posicione("SA1", 1, xFilial("SA1") + aNotaSel[iX, 19] + aNotaSel[iX, 20], "A1_NOME") )
				TMPNT->QTDVOL 	:= AllTrim(Transform(aNotaSel[iX, 11], PesqPict("DTC","DTC_QTDVOL")) )
				TMPNT->PESO 	:= AllTrim(Transform(aNotaSel[iX, 12], PesqPict("DTC","DTC_PESO")) )
				TMPNT->VALOR 	:= AllTrim(Transform(aNotaSel[iX, 13], PesqPict("DTC","DTC_VALOR")) )											 
				
				MsUnlock()	
			endif						
			
		endif
		
	Next iX
	
	//Verifico se encontrou algum veiculo, caso não tenha encontrado, eu mostro todos.
	if lExectPar == .T.
		TMPNT->(dbGoTop())
		if TMPNT->(EOF())
			MsgAlert("Não foi localizado nenhum veículo com esses parametros.")
			If !geraBrowse(.F.)
				Return
			EndIf
		endif
	endif

Return .T.

/*---------------------------------------------------------------------*
 | Func:  fGravNotas                                                   |
 | Autor: fbsolutions                                                  |
 | Data:  20/07/2019                                                   |
 | Desc:  Função que monta o array com as informações das notas        |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fGravNotas(c_NroLT)

	cCliRem := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_COD")
	cLojRem := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_LOJA")
	
	cCliDes := IIF(lCheckBox2, cCliRedes, cCliDes)
	cLojDes := IIF(lCheckBox2, cLojRedes, cLojDes)
	
	dbSelectArea('DTC')
	DTC->( dbSetOrder(2) )
	//DTC_FILIAL, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM, DTC_CODPRO, DTC_FILORI, DTC_LOTNFC, R_E_C_N_O_, D_E_L_E_T_
	If DTC->( dbSeek(xFilial('DTC')+cDocto+cSerie+cCliRem+cLojRem) )
		DTC->( dbCloseArea() )
		Return
	EndIf
	DTC->( dbCloseArea() )
	
	Aadd(aNotaSel, {} )
	
	Aadd( aNotaSel[len(aNotaSel)],  xFilial("DTC") ) 
	Aadd( aNotaSel[len(aNotaSel)],  cFilAnt )  
	Aadd( aNotaSel[len(aNotaSel)],  c_NroLT ) 
	Aadd( aNotaSel[len(aNotaSel)],  Date() ) 
	Aadd( aNotaSel[len(aNotaSel)],  cNFEID ) 
	Aadd( aNotaSel[len(aNotaSel)],  cSerie ) 
	Aadd( aNotaSel[len(aNotaSel)],  cDocto ) 
	Aadd( aNotaSel[len(aNotaSel)],  cCodPro ) 
	Aadd( aNotaSel[len(aNotaSel)],  "CX" ) 
	Aadd( aNotaSel[len(aNotaSel)],  dEmiNFC ) 
	Aadd( aNotaSel[len(aNotaSel)],  nQtdVol ) 
	Aadd( aNotaSel[len(aNotaSel)],  nPeso ) 
	Aadd( aNotaSel[len(aNotaSel)],  nValor ) 
	Aadd( aNotaSel[len(aNotaSel)],  cCliRem )  
	Aadd( aNotaSel[len(aNotaSel)],  cLojRem ) 
	Aadd( aNotaSel[len(aNotaSel)],  cCliDes ) 
	Aadd( aNotaSel[len(aNotaSel)],  cLojDes ) 
	
	If cTipFre == '1'
		cCliDev := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_COD")
		cLojDev := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_LOJA")
	Else
		cCliDev := Posicione("SA1", 3, xFilial("SA1") + cCGCDes, "A1_COD")
		cLojDev := Posicione("SA1", 3, xFilial("SA1") + cCGCDes, "A1_LOJA")
	EndIf
	
	//1=Remetente;2=Destinatario;3=Consignatario;4=Despachante
	Aadd( aNotaSel[len(aNotaSel)],  cTipFre ) 
	Aadd( aNotaSel[len(aNotaSel)],  cCliDev ) 
	Aadd( aNotaSel[len(aNotaSel)],  cLojDev ) 
	Aadd( aNotaSel[len(aNotaSel)],  cCliDev ) 
	Aadd( aNotaSel[len(aNotaSel)],  cLojDev ) 
	Aadd( aNotaSel[len(aNotaSel)],  '1' ) 
	Aadd( aNotaSel[len(aNotaSel)],  '3' ) 
	Aadd( aNotaSel[len(aNotaSel)],  '1' ) 
	Aadd( aNotaSel[len(aNotaSel)],  cServLot )
	Aadd( aNotaSel[len(aNotaSel)],  '0' ) 
	Aadd( aNotaSel[len(aNotaSel)],  '2' ) 
	Aadd( aNotaSel[len(aNotaSel)],  GetMV('MV_CDRORI') ) 
	
	cRegiaoDes := Posicione("SA1",1,xFilial("SA1")+cCliDes+cLojDes,"A1_CDRDES")
	
	Aadd( aNotaSel[len(aNotaSel)],  cRegiaoDes ) 
	Aadd( aNotaSel[len(aNotaSel)],  cRegiaoDes ) 
	Aadd( aNotaSel[len(aNotaSel)],  '2' ) 
	Aadd( aNotaSel[len(aNotaSel)],  0 ) 
	Aadd( aNotaSel[len(aNotaSel)],  '2' ) 
	Aadd( aNotaSel[len(aNotaSel)],  '01' ) 
	Aadd( aNotaSel[len(aNotaSel)],  '000000000000003' ) 
	Aadd( aNotaSel[len(aNotaSel)],  '2' ) 
	Aadd( aNotaSel[len(aNotaSel)],  cPlacaVei )  
	Aadd( aNotaSel[len(aNotaSel)],  rValFrete )
	
	cSeqEnt := ""		
	

return

/*---------------------------------------------------------------------*
 | Func:  MarPVM01                                                     |
 | Autor: fbsolutions                                                  |
 | Data:  20/07/2019                                                   |
 | Desc:  Função que marca e desmarca todos os itens                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
User Function MarPVM01(nOpc)
Local cArea:=alias()
Local nRec :=recno()

	if OMARK:LINVERT == .T.
		OMARK:LINVERT := .F.
	endif
	TMPNT->(dbGoTop())
	While !TMPNT->(EOF())
		RecLock("TMPNT", .F.)
		If nOpc == 1			
			TMPNT->ZZMARCA := cMarca
		Else			
			TMPNT->ZZMARCA := ' '
		EndIf
		MsUnlock()
		TMPNT->(dbSkip())
	EndDo
	
	dbSelectArea(cArea)
	TMPNT->(dbGoto(nRec))

Return

Static Function GrvDTC(c_NroLT)
Local lRet := .T.

	cCliRem := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_COD")
	cLojRem := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_LOJA")
	
	cCliDes := IIF(lCheckBox2, cCliRedes, cCliDes)
	cLojDes := IIF(lCheckBox2, cLojRedes, cLojDes)
	
	dbSelectArea('DTC')
	DTC->( dbSetOrder(2) )
	//DTC_FILIAL, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM, DTC_CODPRO, DTC_FILORI, DTC_LOTNFC, R_E_C_N_O_, D_E_L_E_T_
	If DTC->( dbSeek(xFilial('DTC')+cDocto+cSerie+cCliRem+cLojRem) )
		DTC->( dbCloseArea() )
		Return
	EndIf
	DTC->( dbCloseArea() )
	
	RecLock('DTC', .T.)
	
	Replace DTC_FILIAL	 With xFilial("DTC")
	Replace DTC_FILORI	 With cFilAnt
	Replace DTC_LOTNFC	 With c_NroLT
	Replace DTC_DATENT	 With Date()
	Replace DTC_NFEID	 With cNFEID
	Replace DTC_SERNFC	 With cSerie
	Replace DTC_NUMNFC	 With cDocto
	Replace DTC_CODPRO	 With cCodPro //Produto de Cálculo
	Replace DTC_CODEMB	 With "CX"
	Replace DTC_EMINFC	 With dEmiNFC
	Replace DTC_QTDVOL	 With nQtdVol
	Replace DTC_PESO 	 With nPeso
	Replace DTC_VALOR	 With nValor
	Replace DTC_CLIREM	 With cCliRem 
	Replace DTC_LOJREM	 With cLojRem
	Replace DTC_CLIDES	 With cCliDes
	Replace DTC_LOJDES	 With cLojDes
	
	/*If _NOT->F2_REDESP <> ' '
		Replace DTC_CLIDPC	 With _SA4->A4_X_CDCLI
		Replace DTC_LOJDPC	 With _SA4->A4_X_CLILJ
		_SA4->(DbCloseArea())
	Endif*/
	
	If cTipFre == '1'
		cCliDev := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_COD")
		cLojDev := Posicione("SA1", 3, xFilial("SA1") + cCGCRem, "A1_LOJA")
	Else
		cCliDev := Posicione("SA1", 3, xFilial("SA1") + cCGCDes, "A1_COD")
		cLojDev := Posicione("SA1", 3, xFilial("SA1") + cCGCDes, "A1_LOJA")
	EndIf
	
	//1=Remetente;2=Destinatario;3=Consignatario;4=Despachante
	Replace DTC_DEVFRE	 With cTipFre
	Replace DTC_CLIDEV	 With cCliDev
	Replace DTC_LOJDEV	 With cLojDev
	Replace DTC_CLICAL	 With cCliDev
	Replace DTC_LOJCAL	 With cLojDev
	Replace DTC_TIPFRE	 With '1'
	Replace DTC_SERTMS	 With '3'
	Replace DTC_TIPTRA	 With '1'
	Replace DTC_SERVIC	 With '013'
	Replace DTC_TIPNFC	 With '0'
	Replace DTC_SELORI	 With '2'
	Replace DTC_CDRORI	 With GetMV('MV_CDRORI')
	
	cRegiaoDes := Posicione("SA1",1,xFilial("SA1")+cCliDes+cLojDes,"A1_CDRDES")
	
	Replace DTC_CDRDES	 With cRegiaoDes
	Replace DTC_CDRCAL	 With cRegiaoDes
	Replace DTC_EDI	 	 With '2'
	Replace DTC_KM	 	 With 0
	Replace DTC_DISTIV	 With '2'
	Replace DTC_CODNEG	 With '01'
	Replace DTC_NCONTR	 With '000000000000003'
	Replace DTC_DOCTMS	 With '2'
	
	cSeqEnt := ""
	
	/*If lCheckBox2
		//cSeqEnt := GrvDUL(cCliDes, cLojDes, cCliRedes, cLojRedes, cRegiaoDes)
	EndIf
	
	If !Empty(cSeqEnt)
	
		//Replace DTC_SQEDES   With cSeqEnt
		
		cRegiaoDes := Posicione("SA1",1,xFilial("SA1")+cCliRedes+cLojRedes,"A1_EST")
	
		Replace DTC_CDRDES	 With cRegiaoDes
		Replace DTC_CDRCAL	 With cRegiaoDes
	
	EndIf*/
	
	MsUnlock()
	
	//criaTabFrete(GetMV('MV_CDRORI'), cRegiaoDes, cServLot)

Return

//04/07/2016, Função não estava sendo utilizada - W0010
/*
Static Function GrvDE5()
Local lRet := .T.

dbSelectArea('DE5')
DE5->( dbSetOrder(1) )
//DE5_FILIAL+DE5_CGCREM+DE5_CGCDES+DE5_SERVIC+DE5_CODPRO+DE5_NUMNFC+DE5_SERNFC+DE5_NUMSOL
If DE5->( dbSeek(xFilial('DE5')+cCGCRem+cDocto+cSerie) )
	DE5->( dbCloseArea() )
	Return
EndIf
DE5->( dbCloseArea() )

RecLock('DE5', .T.)

Replace	DE5_FILIAL	With	xFilial('DE5')
Replace	DE5_CGCREM	With	cCGCRem
Replace	DE5_DTAEMB	With	dDtEmb
Replace	DE5_CGCDES	With	cCGCDes
Replace	DE5_CGCCON	With	cCGCCon
Replace	DE5_CGCDPC	With	cCGCDpc
Replace	DE5_CGCDEV	With	cCGCDev
Replace	DE5_TIPTRA	With	cTipTra
Replace	DE5_TIPFRE	With	cTipFre
Replace	DE5_DOC		With	cDocto
Replace	DE5_SERIE	With	cSerie
Replace	DE5_EMINFC	With	dEmiNFC
Replace	DE5_CODPRO	With	cCodPro
Replace	DE5_CODEMB	With	cCodEmb
Replace	DE5_QTDVOL	With	nQtdVol
Replace	DE5_VALOR	With	nValor
Replace	DE5_PESO	With	nPeso
Replace	DE5_PESOM3	With	nPesoM3
Replace	DE5_VALSEG	With	nValSeg
Replace	DE5_FILDPC	With	cFilDpc
Replace	DE5_CTRDPC	With	cCtrDpc
Replace	DE5_STATUS	With	cStatus
Replace	DE5_METRO3	With	nMetroM3
Replace	DE5_SQIDES	With	cSQIDes
Replace	DE5_CFOPNF	With	cCFOPNF
Replace	DE5_NFEID	With	cNFEID
Replace	DE5_SERTMS	With	"3"
Replace	DE5_TIPTRA	With	"1"
//Replace	DE5_VEIC1	With	cVeic

MsUnlock()

Return
*/

Static Function fGetCodPro(cCNPJ, cPrdEmb, cCodNCM)
Local aArea := GetArea()
Local cQuery  := ''
Local cCodPro := Space(TamSX3("B1_COD")[1])
Local cCodCli := ''
Local cLojCli := ''
Local lAchou  := .F.
Local cMsg    := ""

Default lPad  := .F. //busca pelo padrão

	//Alert('*cGetCodPro*'+cCNPJ)
	dbSelectArea("SA1")
	SA1->( dbSetOrder(3) )
	If SA1->( dbSeek(xFilial("SA1")+cCNPJ) )
	
		cCodCli := SA1->A1_COD
		cLojCli := SA1->A1_LOJA
				
		//While Empty(cCodPro) 
			
			dbSelectArea("DE7")		
			DE7->(dbSetOrder(1)) //DE7_FILIAL, DE7_CODCLI, DE7_LOJCLI, DE7_CODPRO, R_E_C_N_O_, D_E_L_E_T_
			DE7->(dbGoTop())
			//Tenta buscar o produto do cliente
			If ! dbSeek(xFilial("DE7")+cCodCli+cLojCli)
				cMsg += "O cliente de CNPJ " + Transform(cCNPJ, PesqPict("SA1", "A1_CGC")) + " não tem produto predominante cadastrado." + STR_PULA 
				cMsg += "O cadastro será aberto agora para realizar a inclusão." + STR_PULA + STR_PULA  
				cMsg += "Cod/Loj Cliente: <b>" + cCodCli + " " + cLojCli + "</b>" 
				
				MsgAlert(cMsg)
				INCLUI := .T.
				TMSAE40(3)	
			else				
				cCodPro := DE7->DE7_CODPRO				
			EndIf	
			DE7->( dbCloseArea() )
			
			IF Empty(cCodPro)
				dbSelectArea("DE7")		
				DE7->(dbSetOrder(1)) //DE7_FILIAL, DE7_CODCLI, DE7_LOJCLI, DE7_CODPRO, R_E_C_N_O_, D_E_L_E_T_
				DE7->(dbGoTop())
				//Tenta buscar o produto do cliente
				If dbSeek(xFilial("DE7")+cCodCli+cLojCli)							
					cCodPro := DE7->DE7_CODPRO				
				EndIf	
				DE7->( dbCloseArea() )
			endif
			
		//enddo					
	
	EndIf
	
	SA1->( dbCloseArea() )
	
	RestArea(aArea)
	
Return cCodPro


Static Function cGetCodPro(cCNPJ, cPrdEmb, cCodNCM, lPad)
Local aArea := GetArea()
Local cQuery  := ''
Local cCodPro := Space(TamSX3("B1_COD")[1])
Local cCodCli := ''
Local cLojCli := ''
Default lPad  := .F. //busca pelo padrão

	//Alert('*cGetCodPro*'+cCNPJ)
	dbSelectArea("SA1")
	SA1->( dbSetOrder(3) )
	If SA1->( dbSeek(xFilial("SA1")+cCNPJ) )
	
		cCodCli := SA1->A1_COD
		cLojCli := SA1->A1_LOJA
		
		If lPad
			//Alert(FunName())
			dbSelectArea("DE7")
			cDE7CODCLI := cCodCli
			cDE7LOJCLI := cLojCli
			cDE7NOMCLI := Posicione("SA1",1,xFilial("SA1")+cDE7CODCLI+cDE7LOJCLI,"A1_NOME")
			cDE7PRDEMB := "000000000000000"
			cDE7DSCEMB := "PRODUTO DO CLIENTE"
			DE7->(dbSetOrder(1))
			
			//DE7_FILIAL, DE7_CODCLI, DE7_LOJCLI, DE7_CODPRO, R_E_C_N_O_, D_E_L_E_T_
			//Tenta buscar o produto do cliente
			If !dbSeek(xFilial("DE7")+cDE7CODCLI+cDE7LOJCLI)
				MsgAlert("O produto " + cPrdEmb + " do cliente de CNPJ " + Transform(cCNPJ, PesqPict("SA1", "A1_CGC")) + " não está cadastrado. O cadastro será aberto agora para realizar a inclusão.")
				INCLUI := .T.
				TMSAE40(3)	
			EndIf
		EndIf
		
		If !lPad
			cQuery := "SELECT SB1.B1_COD, SB1.B1_POSIPI FROM " + RetSQLName("SB1") + " SB1 "
			cQuery += " 		LEFT JOIN " + RetSQLName("DE7") + " DE7 ON ( SB1.B1_COD = DE7.DE7_CODPRO AND DE7.D_E_L_E_T_ = ' ' ) "
			cQuery += "WHERE SB1.D_E_L_E_T_ = ' ' "
			cQuery += "AND (DE7.DE7_PRDEMB LIKE '%" + AllTrim(cPrdEmb) + "%' OR SB1.B1_POSIPI = '" + AllTrim(cCodNCM) + "') "
			cQuery += "AND DE7_CODCLI = '" + cCodCli + "' AND DE7_LOJCLI = '" + cLojCli + "' "
			cQuery += "ORDER BY SB1.B1_POSIPI DESC "
		Else
			cQuery := "SELECT SB1.B1_COD, SB1.B1_POSIPI FROM " + RetSQLName("SB1") + " SB1 "
			cQuery += " 		LEFT JOIN " + RetSQLName("DE7") + " DE7 ON ( SB1.B1_COD = DE7.DE7_CODPRO AND DE7.D_E_L_E_T_ = ' ' ) "
			cQuery += "WHERE SB1.D_E_L_E_T_ = ' ' "
			cQuery += "AND DE7.DE7_PRDEMB = '000000000000000' " //CASO QUEIRA CRIAR UM ÚNICO PRODUTO, BASTA COLOCAR 000000000000000 NO PRODUTOS X EMBARCADOR
			cQuery += "AND DE7_CODCLI = '" + cCodCli + "' AND DE7_LOJCLI = '" + cLojCli + "' "
			cQuery += "ORDER BY SB1.B1_POSIPI DESC "
		EndIf	
	
		TcQuery cQuery NEW ALIAS "_PROD"
		dbSelectArea("_PROD")
	
		//Alert(cQuery)
	
		Count To nPRODRegs
	
		_PROD->( dbGoTop() )
	
		If nPRODRegs > 0
			cCodPro := _PROD->B1_COD
		Else
			
		EndIf
	
		_PROD->( dbCloseArea() )
	
	EndIf
	
	SA1->( dbCloseArea() )
	
	RestArea(aArea)
	
Return cCodPro

//04/07/2016, Função não estava sendo utilizada - W0010
/*
Static Function cGetProXNCM(cNCM)
Local aArea := GetArea()
Local cQuery  := ''
Local cCodPro := ''

cQuery := " SELECT B1_COD FROM " + RetSQLName('SB1') + " WHERE D_E_L_E_T_ = ' ' AND B1_POSIPI = '" + AllTrim(cNCM) + "' "

TcQuery cQuery NEW ALIAS "_SB1"
dbSelectArea("_SB1")

Count To nSB1Regs

_SB1->( dbGoTop() )

If nSB1Regs > 0
	cCodPro := _SB1->SB1_POSIPI
EndIf

_SB1->( dbCloseArea() )

RestArea(aArea)
Return cCodPro
*/

Static Function cGetEmb(cDesEmb)
Local aArea 	:= GetArea()
Local cQuery 	:= ""
Local cCodEmb   := ""

cQuery 	:= "SELECT * FROM " + RetSQLName("SX5") + " "
cQuery 	+= "WHERE D_E_L_E_T_ = ' ' "
cQuery 	+= "AND X5_TABELA = 'MG' "
cQuery 	+= "AND X5_CHAVE = '" + AllTrim(cDesEmb) + "' "

TcQuery cQuery NEW ALIAS "ESP"
dbSelectArea("ESP")

If !ESP->( EOF() )
	cCodEmb := ESP->X5_CHAVE
Else
	cCodEmb := ""
EndIf

ESP->( dbCloseArea() )

RestArea(aArea)
Return cCodEmb

//-----------------------------------------

Static Function CopyFiles(cDest)

LOCAL cDirectory := ""
LOCAL aArquivos := {}
LOCAL nArq := 0
PRIVATE aParamFile:= ARRAY(1)

// Exibe a estrutura de diretorio e permite a selecao dos arquivos que serao processados

//04/07/2016, alterando para Teste, too many parameters - W0007
cDirectory := ALLTRIM(cGetFile( '*.XML' , 'Arquivos (XML)', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. ))
If Empty(cDirectory)
	Return .F.
EndIf
//cDirectory := ALLTRIM(cGetFile( '*.XML' , 'Arquivos (XML)'))
aArquivos := Directory(cDirectory+"*.XML")

FOR nArq := 1 TO Len(aArquivos)
	IF Empty(aArquivos[nArq][1])
		LOOP
	ENDIF
	//<...processamento...>
	CpyT2S( cDirectory + aArquivos[nArq][1], cDest )
NEXT nArq
RETURN .T.



Static Function CfgImp()
Static oDlgImpCfg
Static oButton1
Static oButton2

Static oCheckBox1
Static lCheckBox1 := .F.
Static oCheckBox2
Static lCheckBox2 := .F.
Static oCheckBox3
Static lCheckBox3 := .F.

Static oCliRedes
Static cCliRedes := Space(TamSX3("A1_COD")[01])

Static oLojRedes
Static cLojRedes := Space(TamSX3("A1_LOJA")[01])

Static oSay1
Static oSay2
Static oSay3
Static oSayR1
Static oSayR2
Static oSayR3
 
  DEFINE MSDIALOG oDlgImpCfg TITLE "Conf. Importação" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

    //@ 032, 041 CHECKBOX oCheckBox1 VAR lCheckBox1 PROMPT "Cte Único?" SIZE 057, 016 OF oDlgImpCfg COLORS 0, 16777215 PIXEL
    @ 010, 041 CHECKBOX oCheckBox2 VAR lCheckBox2 PROMPT "Redespacho?" SIZE 056, 018 OF oDlgImpCfg COLORS 0, 16777215 PIXEL
    @ 020, 042 SAY oSay1 PROMPT "Caso for redespacho, selecione a transportadora" SIZE 133, 007 OF oDlgImpCfg COLORS 0, 16777215 PIXEL
    
    @ 030, 041 MSGET oCliRedes VAR cCliRedes SIZE 048, 010 OF oDlgImpCfg VALID ValidCliRedes() COLORS 0, 16777215 F3 "SA1" PIXEL
    @ 030, 106 MSGET oLojRedes VAR cLojRedes SIZE 023, 010 OF oDlgImpCfg COLORS 0, 16777215 PIXEL
    
    @ 045, 041 CHECKBOX oCheckBox3 VAR lCheckBox3 PROMPT "CT-e Único?" SIZE 056, 018 OF oDlgImpCfg COLORS 0, 16777215 PIXEL
    
    @ 055, 042 SAY oSay2 PROMPT "Veiculo" SIZE 133, 007 OF oDlgImpCfg  COLORS 0, 16777215 PIXEL
    @ 055, 107 SAY oSay3 PROMPT "Motorista" SIZE 133, 007 OF oDlgImpCfg  COLORS 0, 16777215 PIXEL
    @ 065, 041 MSGET oVeic VAR cVeic SIZE 048, 010 OF oDlgImpCfg VALID ValidVeic() COLORS 0, 16777215 F3 "DA3" PIXEL
    @ 065, 106 MSGET oMot VAR cMot SIZE 048, 010 OF oDlgImpCfg VALID ValidMot() COLORS 0, 16777215 F3 "DA4" PIXEL
    
    @ 085, 042 SAY oSayR1 PROMPT "1º Reboque" SIZE 133, 007 OF oDlgImpCfg  COLORS 0, 16777215 PIXEL
    @ 085, 107 SAY oSayR2 PROMPT "2º Reboque" SIZE 133, 007 OF oDlgImpCfg  COLORS 0, 16777215 PIXEL
    @ 085, 172 SAY oSayR3 PROMPT "3º Reboque" SIZE 133, 007 OF oDlgImpCfg  COLORS 0, 16777215 PIXEL
    @ 095, 041 MSGET oReb01 VAR cReb01 SIZE 048, 010 OF oDlgImpCfg VALID ValidReb("1") COLORS 0, 16777215 F3 "DA3" PIXEL
    @ 095, 107 MSGET oReb02 VAR cReb02 SIZE 048, 010 OF oDlgImpCfg VALID ValidReb("2") COLORS 0, 16777215 F3 "DA3" PIXEL
    @ 095, 172 MSGET oReb03 VAR cReb03 SIZE 048, 010 OF oDlgImpCfg VALID ValidReb("3") COLORS 0, 16777215 F3 "DA3" PIXEL
    
    @ 0120, 159 BUTTON oButton1 PROMPT "OK" SIZE 039, 014 OF oDlgImpCfg ACTION OKCfg() PIXEL
    @ 0120, 204 BUTTON oButton2 PROMPT "Cancela" SIZE 039, 014 OF oDlgImpCfg ACTION CancCfg() PIXEL
  ACTIVATE MSDIALOG oDlgImpCfg

Return

Static Function OKCfg()
	Close(oDlgImpCfg)
	lOKCfg := .T.       	
Return
       
Static Function CancCfg()
	Close(oDlgImpCfg)
	lOKCfg := .F.       	
Return
       

Static Function ValidCliRedes()

	/*If lCheckBox2 .AND. Empty(cCliRedes) .AND. Empty(cLojRedes)
		Alert("Se transporte redespacho, preencher transportadora")
		Return .F.
	EndIf */

Return .T.


/*---------------------------------------------------------------------*
 | Func:  ValidReb                                                     |
 | Autor: FBSolutions                                                  |
 | Data:  05/09/2019                                                   |
 | Desc:  Função que valida o reboque digitado                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ValidReb(cReb)
Local lRetReb := .T. 
Local cMsg    := ""
Local cRetRV  := ""
Local cTPVei  := ""
Local cRebV   := iif(cReb="1", cReb01, iif(cReb="2", cReb02, cReb03)) 

	If ! Empty(cRebV)
		
		If Empty(cVeic)
			cMsg += "Informe o veículo primeiro."
			Alert(cMsg)
			lRetReb := .F.
			Return lRetReb
		endif
		
		if SuperGetMV("MV_TMSALOC",.F.,.T.) == .T.
			cRetRV := fVldViagem(cRebV, "R")
		endif
		
		if Empty(cRetRV)
			
			cTPVei := Posicione("DA3", 1, xFilial("DA3") + cRebV, "DA3_TIPVEI")
			if Empty(cTPVei)
				cMsg += "Esse reboque não possui tipo cadastrado e não poderá ser utilizado. Campo 'Tipo Veiculo'." + STR_PULA
				cMsg += "Reboque: <b>" + cRebV + " - " + Posicione("DA3", 1, xFilial("DA3") + cRebV, "DA3_DESC") +"</b>"
				Alert(cMsg)
				lRetReb := .F.
			else
				if Posicione("DUT", 1, xFilial("DUT") + cTPVei, "DUT_CATVEI") <> "3" //Tem que ser carreta
					cMsg += "Esse reboque não é da categoria 'Carreta'. Só utilize reboques com essa categoria." + STR_PULA
					cMsg += "Reboque: <b>" + cRebV + " - " + Posicione("DA3", 1, xFilial("DA3") + cRebV, "DA3_DESC") +"</b>"
					Alert(cMsg)
					lRetReb := .F.
				else
					cMot := Posicione("DA3", 1, xFilial("DA3") + cRebV, "DA3_MOTORI")
				endif
			endif
				
			
		else
			cMsg += "Esse reboque pertence a uma viagem que não esta encerrada ou cancelada e não poderá ser utilizado." + STR_PULA
			cMsg += "Viagem: <b>" + cRetRV + "</b>"
			Alert(cMsg)
			lRetReb := .F.
		endif
	EndIf
	

Return lRetReb

/*---------------------------------------------------------------------*
 | Func:  ValidVeic                                                    |
 | Autor: FBSolutions                                                  |
 | Data:  03/09/2019                                                   |
 | Desc:  Função que valida o veiculo digitado                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ValidVeic()
Local lRetVeic := .T. 
Local cMsg     := ""
Local cRetVV   := ""
Local cTPVei   := ""

	If ! Empty(cVeic)
		
		if SuperGetMV("MV_TMSALOC",.F.,.T.) == .T.
			cRetVV := fVldViagem(cVeic, "V")
		endif
		
		if Empty(cRetVV)
			
			cTPVei := Posicione("DA3", 1, xFilial("DA3") + cVeic, "DA3_TIPVEI")
			if Empty(cTPVei)
				cMsg += "Esse veículo não possui tipo cadastrado e não poderá ser utilizado. Campo 'Tipo Veiculo'." + STR_PULA
				cMsg += "Veiculo: <b>" + cVeic + " - " + Posicione("DA3", 1, xFilial("DA3") + cVeic, "DA3_DESC") +"</b>"
				Alert(cMsg)
				lRetVeic := .F.
			else
				if Posicione("DUT", 1, xFilial("DUT") + cTPVei, "DUT_CATVEI") == "3" //Não pode ser carreta
					cMsg += "Esse veículo é de categoria 'Carreta'. Só utilize veículos com outras categorias." + STR_PULA
					cMsg += "Veiculo: <b>" + cVeic + " - " + Posicione("DA3", 1, xFilial("DA3") + cVeic, "DA3_DESC") +"</b>"
					Alert(cMsg)
					lRetVeic := .F.
				else
					if ! Empty(Posicione("DA3", 1, xFilial("DA3") + cVeic, "DA3_MOTORI"))
						cMot := Posicione("DA3", 1, xFilial("DA3") + cVeic, "DA3_MOTORI")
					endif
				endif
			endif
				
			
		else
			cMsg += "Esse veículo pertence a uma viagem que não esta encerrada ou cancelada e não poderá ser utilizado." + STR_PULA
			cMsg += "Viagem: <b>" + cRetVV + "</b>"
			Alert(cMsg)
			lRetVeic := .F.
		endif
	EndIf

Return lRetVeic

/*---------------------------------------------------------------------*
 | Func:  ValidMot                                                     |
 | Autor: FBSolutions                                                  |
 | Data:  03/09/2019                                                   |
 | Desc:  Função que valida o motorista digitado                       |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ValidMot()
Local lRetMot  := .T. 
Local cMsg     := ""
Local cRetVM   := ""

	If ! Empty(cMot)
		if SuperGetMV("MV_TMSALOC",.F.,.T.) == .T.
			cRetVM := fVldViagem(cMot, "M")
		endif
		
		if Empty(cRetVM)
			if ! Empty(Posicione("DA3", 2, xFilial("DA3") + cMot, "DA3_COD"))
				cVeic := Posicione("DA3", 2, xFilial("DA3") + cMot, "DA3_COD")
			endif	
		else
			cMsg += "Esse motorista pertence a uma viagem que não esta encerrada ou cancelada e não poderá ser utilizado." + STR_PULA
			cMsg += "Viagem: <b>" + cRetVM + "</b>"
			Alert(cMsg)
			lRetMot := .F.
		endif
	EndIf

Return lRetMot

/*---------------------------------------------------------------------*
 | Func:  fVldViagem                                                   |
 | Autor: FBSolutions                                                  |
 | Data:  03/09/2019                                                   |
 | Desc:  Função que valida a viagem e o motorista em viagem           |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fVldViagem(cFilUP, cFlag)
Local cRet   := ""
Local cQuery := ""
Local cWhe   := ""

	if cFlag == "V" //Veiculo
		cWhe += "AND DUP.DUP_CODVEI = '"+cFilUP+"' "
	elseif cFlag == "M" //Motorista
		cWhe += "AND DUP.DUP_CODMOT = '"+cFilUP+"' "
	elseif cFlag == "R" //Motorista
		cWhe += "AND (DTR.DTR_CODRB1 = '"+cFilUP+"' OR DTR.DTR_CODRB2 = '"+cFilUP+"' OR DTR.DTR_CODRB3 = '"+cFilUP+"'  )  "
	endif
	
	cQuery := "SELECT TOP 1 DUP.DUP_FILORI, DUP.DUP_VIAGEM " + STR_PULA
	cQuery += "FROM " + RetSQLName("DUP") + " as DUP WITH(NOLOCK) " + STR_PULA
	cQuery += "LEFT HASH JOIN " + RetSQLName("DTQ") + " as DTQ WITH(NOLOCK) ON DTQ.DTQ_FILIAL = DUP.DUP_FILIAL AND DTQ.DTQ_FILORI = DUP.DUP_FILORI AND DTQ.DTQ_VIAGEM = DUP.DUP_VIAGEM AND DTQ.D_E_L_E_T_ = '' " + STR_PULA
	cQuery += "LEFT HASH JOIN " + RetSQLName("DTR") + " as DTR WITH(NOLOCK) ON DTR.DTR_FILIAL = DUP.DUP_FILIAL AND DTR.DTR_FILORI = DUP.DUP_FILORI AND DTR.DTR_VIAGEM = DUP.DUP_VIAGEM AND DTR.D_E_L_E_T_ = '' " + STR_PULA
	cQuery += "WHERE DUP.D_E_L_E_T_ = '' " + STR_PULA		
	cQuery += cWhe
	cQuery += "AND DTQ.DTQ_STATUS NOT IN ('3', '9') "	
	
	IF SELECT("QRY") > 0   
        QRY->(DbCloseArea())						       
    ENDIF 											       
	TCQuery cQuery Alias "QRY" New
 	DbSelectArea("QRY")
 	
 	QRY->(DbGoTop())	
	if !QRY->(Eof()) 
		cRet   := QRY->DUP_FILORI + " " + QRY->DUP_VIAGEM
	endif
	
	QRY->(DbCloseArea())

Return cRet


#include "rwmake.ch"
#include "topconn.ch"

/*U_IGTMSM02()
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IGTMSM02  ºAutor  ³Microsiga           º Data ³  03/21/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para excluir lotes, caso seja necessário estornar    º±±
±±º          ³alguma importação                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÔGÚtHÚtHÚ¿
//³Deve ser executada somente pelo analista³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÔGÚÙ
ENDDOC*/
Static Function excLote(cLote)
Processa({|| RunExcl(cLote) },"Excluindo Lote...")
Return

Static Function RunExcl(cLote)
Local aArea := GetArea()
ProcRegua(3)

c_Query := "SELECT * FROM " + RetSQLName("DTP") + " "
c_Query += "WHERE D_E_L_E_T_ = ' ' "
c_Query += "AND DTP_STATUS IN ('1','2') "
c_Query += "AND DTP_LOTNFC = '"+cLote+"' "

TcQuery c_Query NEW ALIAS "_LOT"
DbSelectArea("_LOT")

IncProc("Excluindo Doc Entrada Cliente...")
DbGoTop()
While !Eof()
	c_Sql := "UPDATE " + RetSQLName("DTC") + " SET D_E_L_E_T_ = '*' "
	c_Sql += "WHERE D_E_L_E_T_ = ' ' AND DTC_LOTNFC = '"+_LOT->DTP_LOTNFC+"' "
	TCSQLEXEC(c_Sql)

	DbSelectArea("_LOT")
	DbSkip()
EndDo

IncProc("Excluindo Lote...")
DbGoTop()
While !Eof()
	c_Sql := "UPDATE " + RetSQLName("DTP") + " SET D_E_L_E_T_ = '*' "
	c_Sql += "WHERE D_E_L_E_T_ = ' ' AND DTP_LOTNFC = '"+_LOT->DTP_LOTNFC+"' "
	TCSQLEXEC(c_Sql)

	DbSelectArea("_LOT")
	DbSkip()
EndDo
_LOT->(DbCloseArea())

RestArea(aArea)
Return

Static Function criaTabFrete(cCdrOri, cCdrDes, cServic)
Local aArea := GetArea()                              

Local cTab1 := "0001"

	cCdrOri := PADR(cCdrOri, 6)
	cCdrDes := PADR(cCdrDes, 6)
	                           
	dbSelectArea("DT0")
	
	//se o serviço é 013, cria tabela de frete
	//If AllTrim(cServic) == '013'
	
		DT0->( dbSetOrder(1) )
		If ( !DT0->( dbSeek(xFilial("DT0")+cTab1+"01"+cCdrOri+cCdrDes) ) )
			RecLock("DT0", .T.)
			Replace DT0_TABFRE With cTab1
			Replace DT0_TIPTAB With "01"
			Replace DT0_CDRORI With cCdrOri
			Replace DT0_CDRDES With cCdrDes
			Replace DT0_TABTAR With cTab1
			Replace DT0_CATTAB With "1"
			MsUnLock()            
		EndIf
		
	//EndIf
	     
	RestArea(aArea)      	
	
Return Nil 


/*---------------------------------------------------------------------*
 | Func:  cA050ValInf                                                  |
 | Autor: FBSolutions                                                  |
 | Data:  10/09/2019                                                   |
 | Desc:  Função para informar em tela os valores de frete             |
 | Obs.:  Tabela DVR                                                   |
 *---------------------------------------------------------------------*/
Static Function cA050ValInf(nOpcx,cNumNfc,cSerNfc,cCodPro)
Local nCnt      := 0
Local aTabFre   := {}
Local cTabFre   := ''
Local cTipTab   := ''
Local lContinua := .T.
Local cFilOri   := DTC->DTC_FILORI
Private aValInf := {}

	If Empty(cNumNfc) .Or. Empty(cCodPro)
		Help("",1,"TMSA05066") //Para apresentar o valor informado, devera ser digitada a nota fiscal e o produto
	Else
	
		//-- Na inclusao, verifica se existe valor informado na cotacao.
		If nOpcx == 3
			If !Empty(DTC->DTC_NUMCOT) .And. Empty(aValInf)
				If !Empty(DTC->DTC_FILCFS)
					cFilOri := DTC->DTC_FILCFS
				EndIf
				TmsValInf(aValInf,'3',cFilOri,DTC->DTC_NUMCOT,,,,,,,,,,nOpcx,,,,,DTC->DTC_CODNEG)
				For nCnt := 1 To Len(aValInf)
					//-- Atualiza a nota fiscal do valor informado para o produto atual.
					If aValInf[nCnt,6] == cCodPro
						aValInf[nCnt,4] := cNumNfc
						aValInf[nCnt,5] := cSerNfc
					Else
						//-- Inicializa deletado o valor informado de outros produtos.
						//-- Qdo executar a rotina para o produto referente ao valor informado o mesmo sera reativado.
						aValInf[nCnt,3] := .T.
					EndIf
				Next nCnt
			Else
				For nCnt := 1 To Len(aValInf)
					//-- Atualiza a nota fiscal do valor informado para o produto atual.
					If	aValInf[nCnt,6] == cCodPro .And. aValInf[nCnt,4] <> cNumNfc .And. aValInf[nCnt,5] <> cSerNfc
						aValInf[nCnt,4] := cNumNfc
						aValInf[nCnt,5] := cSerNfc
						aValInf[nCnt,3] := .F.
					EndIf
				Next nCnt
			EndIf
		EndIf
	
		//-- Pesquisa a tabela de frete do cliente
		If (nOpcx == 3 .Or. nOpcx == 4)
			lContinua := .F.
			aTabFre := TmsTabFre(DTC->DTC_CLICAL,DTC->DTC_LOJCAL,DTC->DTC_SERVIC,DTC->DTC_TIPFRE,DTC->DTC_CODNEG)
			If !Empty(aTabFre)
				cTabFre   := aTabFre[1]
				cTipTab   := aTabFre[2]
				lContinua := .T.
			EndIf
	
			If !lContinua .And. (Empty(cTabFre) .Or. Empty(cTipTab))
				If MsgYesNo( "Tabela de Frete não localizada, deseja apresentar todos componentes do tipo valor informado ?" ) 
					lContinua := .T.
				EndIf
			EndIf
		EndIf
	
		//-- Valor Informado da nota fiscal
		If lContinua
			cTmsValInf(aValInf,'2',DTC->DTC_FILORI,,DTC->DTC_LOTNFC,DTC->DTC_CLIREM,DTC->DTC_LOJREM,DTC->DTC_CLIDES,DTC->DTC_LOJDES,DTC->DTC_SERVIC,cNumNfc,cSerNfc,cCodPro,nOpcx,,cTabFre,cTipTab,,DTC->DTC_CODNEG)
		EndIf
	
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  cTmsValInf                                                   |
 | Autor: FBSolutions                                                  |
 | Data:  10/09/2019                                                   |
 | Desc:  Função para montar a tela pra digitar o val info             |
 | Obs.:  Tabela DVR                                                   |
 *---------------------------------------------------------------------*/
Static Function cTmsValInf(aValInf,cAcao,cFilOri,cNumCot,cLotNfc,cCliRem,cLojRem,cCliDes,;
					 cLojDes,cServic,cNumNfc,cSerNfc,cCodPro,nOpcx,cViagem,cTabFre,cTipTab,aAutoVInf,cCodNeg)
Local aCmpInf      := {}
Local aDelInf      := {}
Local cCampo       := ""
Local cSeek        := ""
Local nCntFor      := 0
Local nItem        := 0
Local nOpcA        := 0
Local nSeek        := 0
Local oDlgCmp
Local aSomaButtons := {}
Local lTabDFI      := nModulo<>43
Local cIdent       := ""
Local nOpc 			:= Nil

Local aNoFields    := {}
Local aBkpCols     := {}
Local aaCampos     := {} //Variavel utilizada para informar os campos que serão alterados
Local cQuery       := ""
Local cAliasQry    := ""
Local lAutoDVT     := .F.
Local cRotOri      := ""  //-- Tratamento Rentabilidade/Ocorrencia
Local lCpoOri      := .f. //-- Tratamento Rentabilidade/Ocorrencia
SaveInter()

//-- GetDados
Private aKeyCmp  := {}
Private aHeadDVR := {}
Private aHeader  := {}
Private aColsDVR := {}
Private aColsAux := {}
Private oGetCmp

DEFAULT aValInf   := {}
DEFAULT cCodPro   := Space(Len(SB1->B1_COD))
DEFAULT cTabFre   := ''
DEFAULT cTipTab   := ''
DEFAULT aAutoVInf := {}
DEFAULT cServic   := ""
DEFAULT cCodNeg   := ""


	If cAcao == '2'
		//Query passada na FillGetDados para preencher o aCols
		cQuery := "SELECT *"
		cQuery += " FROM " + RetSqlName("DVR")+ " DVR "
		cQuery += " WHERE DVR_FILIAL = '" + xFilial("DVR") + "'"
		cQuery += "   AND DVR_FILORI = '" + cFilOri + "'"
		cQuery += "   AND DVR_LOTNFC = '" + cLotNfc + "'"
		cQuery += "   AND DVR_CLIREM = '" + cCliRem + "'"
		cQuery += "   AND DVR_LOJREM = '" + cLojRem + "'"
		cQuery += "   AND DVR_CLIDES = '" + cCliDes + "'"
		cQuery += "   AND DVR_LOJDES = '" + cLojDes + "'"
		cQuery += "   AND DVR_CODNEG = '" + cCodNeg + "'"
		cQuery += "   AND DVR_SERVIC = '" + cServic + "'"
		cQuery += "   AND DVR_NUMNFC = '" + cNumNfc + "'"
		cQuery += "   AND DVR_SERNFC = '" + cSerNfc + "'"
		cQuery += "   AND DVR_CODPRO = '" + cCodPro + "'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
	
		aNoFields := {"DVR_FILORI","DVR_LOTNFC","DVR_CLIREM","DVR_LOJREM","DVR_CLIDES","DVR_LOJDES","DVR_SERVIC","DVR_NUMNFC","DVR_SERNFC","DVR_CODPRO"}
		Aadd(aNoFields,"DVR_CODNEG")
		
		//-- Preenche aHeader
	
		FillGetDados(nOpcx,"DVR",1, /*cSeek*/, /*{|| &cWhile }*/, {||.T.}, aNoFields, /*aYesFields*/, /*lOnlyYes*/, cQuery, /*bMontCols*/)
	
		aBkpCols := aClone(aCols)		
		aCols  := {}
		
		aHeadDVR  := aClone(aHeader)
	
		/*Aadd(aHeadDVR,{"Componente", "DVR_CODPAS", "@!", TamSX3("DVR_CODPAS")[01],0,".T.",".T.","C", "", "", ""})
		Aadd(aHeadDVR,{"Descricao" , "DVR_DESPAS", "@!", TamSX3("DVR_DESPAS")[01],0,".T.",".T.","C", "", "", ""})
		Aadd(aHeadDVR,{"Qtde"      , "DVR_VALOR", "@E 999,999,999.9999", 14, 4,".T.",".T.","N", "", "", ""})
		
		AAdd( aColsDVR, {"01",;
		              "FRETE INFORMADO",;
		              0,;
		              .F.}) */
		              
	   nOpc 	 := GD_INSERT+GD_DELETE+GD_UPDATE
		
		//-- Preenche aCols baseado na digitacao de valor informado x documento
		nSeek := AScan(aValInf,{|x|x[4]+x[5]+x[6]==cNumNfc+cSerNfc+cCodPro})
		If	Empty(nSeek)
			DVR->(DbSetOrder(2)) //DVR_FILIAL+DVR_FILORI+DVR_LOTNFC+DVR_CLIREM+DVR_LOJREM+DVR_CLIDES+DVR_LOJDES+DVR_SERVIC+DVR_NUMNFC+DVR_SERNFC+DVR_CODPRO+DVR_CODPAS
			If	DVR->(MsSeek(cSeek:=xFilial('DVR')+cFilOri+cLotNfc+cCliRem+cLojRem+cCliDes+cLojDes+cCodNeg+cServic))
				While DVR->( ! Eof() .And. DVR->DVR_FILIAL+DVR->DVR_FILORI+DVR->DVR_LOTNFC+DVR->DVR_CLIREM+DVR->DVR_LOJREM+DVR->DVR_CLIDES+DVR->DVR_LOJDES+DVR->DVR_CODNEG+DVR->DVR_SERVIC == cSeek )
					If	AScan(aValInf,{|x|x[4]+x[5]+x[6]+x[1]==DVR->DVR_NUMNFC + DVR->DVR_SERNFC + DVR->DVR_CODPRO + DVR->DVR_CODPAS})==0
						AAdd(aValInf,{DVR->DVR_CODPAS,DVR->DVR_VALOR,.F.,DVR->DVR_NUMNFC,DVR->DVR_SERNFC,DVR->DVR_CODPRO})
					EndIf
					If	DVR->DVR_NUMNFC + DVR->DVR_SERNFC + DVR->DVR_CODPRO == cNumNfc + cSerNfc + cCodPro
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
						nItem := Len(aCols)
						GDFieldPut('DVR_CODPAS',DVR->DVR_CODPAS,nItem)
						GDFieldPut('DVR_DESPAS',M_Posicione('DT3',1,xFilial('DT3')+DVR->DVR_CODPAS,'DT3_DESCRI'),nItem)
						GDFieldPut('DVR_VALOR' ,DVR->DVR_VALOR,nItem)
						GDFieldPut('DVR_ALI_WT',"DVR",nItem)
						GDFieldPut('DVR_REC_WT',DVR->(Recno()),nItem)
						aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					EndIf
					DVR->(DbSkip())
				EndDo
			EndIf
	
			If	Empty(aCols) .And. nOpcx <> 2 .And. nOpcx <> 5
				//-- Obtem todos os componentes do tipo valor informado
				aCmpInf := TmsCompFre(StrZero(7,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab)
				If	! Empty(aCmpInf)
					For nCntFor := 1 To Len(aCmpInf)
						//-- Monta uma linha em branco
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
						nItem := Len(aCols)
						GDFieldPut('DVR_CODPAS',aCmpInf[nCntFor,1],nItem)
						GDFieldPut('DVR_DESPAS',aCmpInf[nCntFor,2],nItem)
						GDFieldPut('DVR_VALOR' ,0,nItem)
						GDFieldPut('DVR_ALI_WT',"DVR",nItem)
						GDFieldPut('DVR_REC_WT',0,nItem)
						aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					Next
				EndIf
			EndIf		
		
		EndIf 
		
		//Se o aCols esta vazio, retorno o aCols(aBkpCols) que foi criado pela fillgetdados, que contem
		//o alias e o recno
		If	Empty(aCols)
			aCols := aClone(aBkpCols)
		EndIf
	
		aaCampos := { aHeadDVR[3,2] }
		aKeyCmp	 := {'DVR_CODPAS'}					//-- Variavel utilizada pela funcao TmsLOkCmp()
		cCadastro := 'Valor Informado' //'Valor Informado'
		DEFINE MSDIALOG oDlgCmp TITLE cCadastro FROM 094,104 TO 410,690 PIXEL
			@ 030, 003 SAY AllTrim(FwX3Titulo('DTC_NUMNFC')+' / '+ FwX3Titulo('DTC_SERNFC')) SIZE 56 ,9 OF oDlgCmp PIXEL
			@ 030, 056 SAY cNumNfc+' / '+cSerNfc SIZE 56 ,9 OF oDlgCmp PIXEL
	
			@ 030, 100 SAY FwX3Titulo('DTC_CODPRO') SIZE 56 ,9 OF oDlgCmp PIXEL
			@ 030, 140 SAY cCodPro SIZE 100 ,9 OF oDlgCmp PIXEL
			//               MsGetDados(nT , nL,  nB,  nR,                 nOpc,   cLinhaOk,    cTudoOk,cIniCpos,lDeleta,    aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
			
			//oGetCmp :=    MSGetDados():New( 30, 02, 105, 243, 4,'AllwaysTrue()','AllwaysTrue()',,.T.,aaCampos,,,)
			
			oGetCmp := MsNewGetDados():New( 40, 02, 145, 280, nOpc, "AllwaysTrue()", , "", aaCampos, , , , , , oDlgCmp, aHeader, aCols)
			
			oGetCmp:SetArray(aCols)
			//TMSA011AjuMin(aColsAux, aCols)
			oGetCmp:Refresh(.T.)
	
		ACTIVATE MSDIALOG oDlgCmp ON INIT EnchoiceBar(oDlgCmp,{||Iif( oGetCmp:TudoOk(), (nOpca := 1,oDlgCmp:End()), nOpca :=0 )},{||nOpca:=0,oDlgCmp:End()},,aSomaButtons)	
					
	
		If	nOpca == 1
			dbSelectArea('DVR')
			
			For nCntFor := 1 To Len(oGetCmp:aCols)
				RecLock('DVR', .T.)
			
				Replace DVR_FILIAL	 With xFilial('DVR')
				Replace DVR_FILORI	 With cFilOri
				Replace DVR_LOTNFC	 With cLotNfc			
				Replace DVR_CLIREM	 With cCliRem 
				Replace DVR_LOJREM	 With cLojRem
				Replace DVR_CLIDES	 With cCliDes
				Replace DVR_LOJDES	 With cLojDes
				Replace DVR_SERVIC	 With cServic
				Replace DVR_NUMNFC	 With cNumNfc
				Replace DVR_SERNFC	 With cSerNfc
				Replace DVR_CODPRO	 With cCodPro
				Replace DVR_CODPAS	 With oGetCmp:aCols[nCntFor][1]
				Replace DVR_VALOR	 With oGetCmp:aCols[nCntFor][3]			
				Replace DVR_CODNEG	 With cCodNeg
							
				MsUnlock()
			Next nCntFor
			
			DVR->( dbCloseArea() )
			
		EndIf 
	//-- Inicializa aValInf na alteracao da cotacao de frete(tmsa040)
	endif

	RestInter()

Return( Nil )

Static Function CadSA1(oBjt,oEndre)

	Local oModel	:= Nil
	Local oView		:= Nil
	Local cCNPJ		:= ""
	Local cIE		:= ""
	Local cFantasia	:= ""
	Local cRazao	:= ""
	
	Local cCep		:= ""
	Local cCodMun	:= ""
	Local cCodPais	:= ""
	Local cCodTel	:= ""
	Local cNumero	:= ""
	Local cUF		:= ""
	Local cBairro	:= ""
	Local cEndereco	:= ""
	Local cMuncipio	:= ""
	Local cCodRegiao := ""
		
	
    If AttIsMemberOf(oBjt,"_CNPJ") 
        cCNPJ :=  Upper(AllTrim(oBjt:_CNPJ:Text))
    End If

    If AttIsMemberOf(oBjt,"_IE") 
        cIE   :=  Upper(AllTrim(oBjt:_IE:Text))
    End If
    
    If AttIsMemberOf(oBjt,"_XNOME") 
        cRazao  :=  Upper(AllTrim(oBjt:_XNOME:Text))
    End If

    If AttIsMemberOf(oBjt,"_XFANT") 
        cFantasia  :=  Upper(AllTrim(oBjt:_XFANT:Text))
    Else
        cFantasia := cRazao
    End If
    
    If AttIsMemberOf(oEndre,"_CEP") 
        cCEP  :=  Upper(AllTrim(oEndre:_CEP:Text))
    End If
    
  	If AttIsMemberOf(oEndre,"_XMUN") 
        cMuncipio  :=  Upper(AllTrim(oEndre:_XMUN:Text))
    End If

	If AttIsMemberOf(oEndre,"_XBAIRRO") 
        cBairro  :=  Upper(AllTrim(oEndre:_XBAIRRO:Text))
    End If

	If AttIsMemberOf(oEndre,"_UF") 
        cUF  :=  Upper(AllTrim(oEndre:_UF:Text))
    End If

	If AttIsMemberOf(oEndre,"_NRO") 
        cNumero  :=  Upper(AllTrim(oEndre:_NRO:Text))
    End If
    
    If AttIsMemberOf(oEndre,"_XLGR") 
        cEndereco  :=  Upper(AllTrim(oEndre:_XLGR:Text)) + "," + cNumero
    End If
	
	If AttIsMemberOf(oEndre,"_FONE") 
        cCodTel  :=  Upper(AllTrim(oEndre:_FONE:Text))
    End If
	
	If AttIsMemberOf(oEndre,"_CPAIS") 
        cCodPais  :=  Upper(AllTrim(oEndre:_CPAIS:Text))
    End If
    
	If AttIsMemberOf(oEndre,"_CMUN") 
        cCodMun  :=  Upper(AllTrim(oEndre:_CMUN:Text))
    End If  
    
    
    DUY->(DbSetOrder(6))
    // Localiza a regiao do cliente
    If DUY->(DbSeek(xFilial("DUY") + cUF + Substr(cCodMun,3,TAMSX3("A1_COD_MUN")[1])))
    	cCodRegiao := DUY->DUY_GRPVEN
    End IF
    
  
    oModel := FWLoadModel("CRMA980")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    
    oModel:SetValue('SA1MASTER', 'A1_COD'  	  , GETSXENUM("SA1", "A1_COD"))
    oModel:SetValue('SA1MASTER', 'A1_LOJA'    , "01")
    oModel:SetValue('SA1MASTER', 'A1_PESSOA'  , IIF(LEN(cCNPJ) == 14, "J", "F"))
    oModel:SetValue('SA1MASTER', 'A1_TIPO'    , "F")
    oModel:SetValue('SA1MASTER', 'A1_CGC'     , cCNPJ)
    oModel:SetValue('SA1MASTER', 'A1_NOME'    , Substr(cRazao,1,TAMSX3("A1_NOME")[1]))
    oModel:SetValue('SA1MASTER', 'A1_NREDUZ'  , Substr(cFantasia,1,TAMSX3("A1_NREDUZ")[1]))
    oModel:SetValue('SA1MASTER', 'A1_END'     , Substr(cEndereco,1,TAMSX3("A1_END")[1]))
    oModel:SetValue('SA1MASTER', 'A1_BAIRRO'  , Substr(cBairro,1,TAMSX3("A1_BAIRRO")[1]))
    oModel:SetValue('SA1MASTER', 'A1_EST'     , cUF)
    oModel:SetValue('SA1MASTER', 'A1_MUN'     , Substr(cMuncipio,1,TAMSX3("A1_MUN")[1]))
    oModel:SetValue('SA1MASTER', 'A1_COD_MUN' , Substr(cCodMun,3,TAMSX3("A1_COD_MUN")[1]))
    oModel:SetValue('SA1MASTER', 'A1_CEP'     , Substr(cCEP,1,TAMSX3("A1_CEP")[1]))
    oModel:SetValue('SA1MASTER', 'A1_DDD'     , Substr(cCodTel,1,2))
    oModel:SetValue('SA1MASTER', 'A1_TEL'     , Substr(cCodTel,3,TAMSX3("A1_TEL")[1]))
    oModel:SetValue('SA1MASTER', 'A1_INSCR'   , Substr(cIE,1,TAMSX3("A1_INSCR")[1]))
    oModel:SetValue('SA1MASTER', 'A1_CDRDES'  , cCodRegiao)
    oModel:SetValue('SA1MASTER', 'A1_CODPAIS' , "01058")
    
    
    
   FWMsgRun(, {|| nRet := FWExecView("Cadastro",'CRMA980', MODEL_OPERATION_INSERT, , { || .T. } , ,,,,,,oModel)}, "Processando", "Carregando dados para o cadastro...")
        
        
rETURN




//04/07/2016, Função não estava sendo utilizada
/*
Static Function GrvDUL(cCodCli, cLojCli, cCodEnt, cLojEnt, cRegDes) //codigo destinatario transportadora
Local aArea  := GetArea()
Local aDados := buscaCLIENT(cCodCli, cLojCli, cCodEnt, cLojEnt)
Local cSeq   := ""

cSeq := seqDUL(cCodCli, cLojCli, cCodEnt, cLojEnt)

If Len(aDados) > 0

	RecLock("DUL", .T.)

	DUL->DUL_FILIAL := xFilial("DUL")
	DUL->DUL_DDD 	:= aDados[1][1]
	DUL->DUL_TEL 	:= aDados[1][2]
	DUL->DUL_CODCLI := cCodCli
	DUL->DUL_LOJCLI := cLojCli
	DUL->DUL_SEQEND	:= cSeq
	DUL->DUL_END 	:= aDados[1][5]
	DUL->DUL_BAIRRO := aDados[1][6]
	DUL->DUL_MUN	:= aDados[1][7]
	DUL->DUL_EST	:= aDados[1][8]
	DUL->DUL_CDRDES	:= cRegDes
	DUL->DUL__CLENT	:= cCodEnt
	DUL->DUL__LJENT	:= cLojEnt
	DUL->DUL_TDA	:= "2"

	MsUnlock()

Else

EndIf
RestArea(aArea)
Return cSeq
*/

/*
Static Function seqDUL(cCodCli, cLojCli, cCodEnt, cLojEnt)
Local c_Query := "SELECT MAX(DUL_SEQEND) AS SEQ FROM DUL"+cEmpTrans+"0 WHERE D_E_L_E_T_ = ' ' AND DUL_CODCLI = '" + cCodCli + "' AND DUL_LOJCLI = '" + cLojCli + "' AND DUL__CLENT = '"+ cCodEnt +"' AND DUL__LJENT = '"+ cLojEnt +"' "

TcQuery c_Query NEW ALIAS "_DUL"
DbSelectArea("_DUL")

Count To n_RegDUL

_DUL->( dbGoTop() )

If n_RegDUL > 0
	While !_DUL->( EOF() )
		If Empty(_DUL->SEQ)
			cSeq := "01"
		Else
			cSeq := StrZero(Val(_DUL->SEQ) + 1, 2)
		EndIf
		_DUL->( dbSkip() )
	EndDo
EndIf
_DUL->( dbCloseArea() )

Return cSeq
*/

/*
Static Function buscaCLIENT(cCodCli, cLojCli, cCodEnt, cLojEnt)
Local aArea := GetArea()
Local c_Query := ""
Local c_Query2 := ""
Local cCNPJ   := ""
Local aDados  := {}

c_Query2 := "SELECT DUL__CLENT+DUL__LJENT FROM DUL"+cEmpTrans+"0 WHERE D_E_L_E_T_ = ' ' AND DUL_CODCLI = '" + cCodCli + "' AND DUL_LOJCLI = '" + cLojCli + "' AND DUL__CLENT = '" + cCodEnt + "' AND DUL__LJENT = '" + cLojEnt + "'"

c_Query := "SELECT * "
c_Query += "FROM SA1010 "
c_Query += "WHERE D_E_L_E_T_ = ' ' AND A1_COD = '" + cCodEnt + "' AND A1_LOJA = '" + cLojEnt + "' AND A1_COD+A1_LOJA NOT IN ( " + c_Query2 + " ) "

TcQuery c_Query NEW ALIAS "_SA1"
DbSelectArea("_SA1")

Count To n_RegSA1

_SA1->( dbGoTop() )

If n_RegSA1 > 0
	While !_SA1->( EOF() )
		aAdd(aDados, {_SA1->A1_DDD,;
			_SA1->A1_TEL, ;
			_SA1->A1_COD, ;
			_SA1->A1_LOJA, ;
			_SA1->A1_END, ;
			_SA1->A1_BAIRRO,;
			_SA1->A1_MUN, ;
			_SA1->A1_EST, ;
			_SA1->A1_CDRDES})

		_SA1->( dbSkip() )
	EndDo
EndIf
_SA1->( dbCloseArea() )

RestArea(aArea)
Return aDados
*/