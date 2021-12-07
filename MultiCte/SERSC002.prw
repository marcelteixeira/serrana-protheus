#include 'protheus.ch'
#include 'parmtype.ch'
#include "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} SchedDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 23/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SchedDef()
	Local aOrd		:= {}
	Local aParam	:= {}

	aParam := { "P",;    // Tipo R para relatorio P para processo   
	"PARAMDEF",;		// Pergunte do relatorio, caso nao use passar ParamDef            
	" ",;  				// Alias
	aOrd,;   			// Array de ordens   
	" "}   				// Título (para Relatório) 

Return aParam

/*/{Protheus.doc} SERSC002
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 24/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERSC002(oProcess)

	Local cDirIn 	:= "\MultiCte\IN\"
	Local cDirOut 	:= "\MultiCte\Lidos\"
	Local aDirImpor := DIRECTORY(AllTrim(cDirIn) + "*.XML" ) //somente arquivos de recebimento de CTe
	Local cXMLArq	:= ""
	Local cXMLOut	:= ""
	Local aProx		:= {} , aErros := {}
	Local i			:= 0

	Default  oProcess    := Nil

	Private aXMLMDfes	:= {} // Manifesto Eltronico
	Private aXMLCTes	:= {} // Conhecimento de Frete
	Private aXMLECTE  	:= {} // Cancelamento Ct-e
	Private aXMLEMDFE	:= {} // Cancelamento MDF-e

	Private aDados		:= {}
	Private aEvento		:= {}
	Private aMDFE		:= {}
	Private aCanMDFE	:= {}


	CteStr()
	EvnStr()
	MDFeStr()
	MdfeEvSt()

	// Informo que tera 5 procedimentos
	// 1 - Separar os arquivos
	// 2 - Importar Ct-e
	// 3 - Importar Mdf-e
	// 4 - Importar Evento Mdf-e
	// 5 - IMportar Evento Ct-e
	nTotReg := 5 

	oProcess:SetRegua1(nTotReg)
	oProcess:IncRegua1("Separando arquivos XML (Ct-e, MDf-e e Eventos)")	
	oProcess:SetRegua2(len(aDirImpor))


	// Verificacao dos XML da pasta para
	// serem integrados na ordem abaixo
	For i:= 1 to len(aDirImpor)

		nPos :=  At("_",aDirImpor[i][1],1) 

		If nPos > 0
			cPrtcWS := SUBSTR(aDirImpor[i][1],1,nPos-1)
		Else
			cPrtcWS := ""
		End If

		cXMLArq := cDirIn + aDirImpor[i][1]
		cXMLOut := cDirOut + aDirImpor[i][1]

		oProcess:IncRegua2("Processados: " + cValtochar(i) + "/" + cvaltochar(len(aDirImpor)))		

		ImpXML(cXMLArq,@aProx,@aErros,cPrtcWS)
	Next

	oProcess:IncRegua1("Importando os Conhecimento de Fretes")	
	oProcess:SetRegua2(len(aXMLCTes))

	// 1 - Conhecimento de Frete
	For i:= 1 to len(aXMLCTes)

		oProcess:IncRegua2("Processados: " + cValtochar(i) + "/" + cvaltochar(len(aXMLCTes)))		

		If ImpCte(aXMLCTes[i][1],aXMLCTes[i][2],aXMLCTes[i][3],aXMLCTes[i][4])

			cXMLArq := aXMLCTes[i][3]
			cXMLOut := StrTran(cXMLArq,cDirIn,cDirOut)
			__CopyFilee(cXMLArq,cXMLOut)
			FERASE( cXMLArq )
		End If
	Next

	oProcess:IncRegua1("Importando os Manifestos de Transportes")	
	oProcess:SetRegua2(len(aXMLMDfes))

	// 2 - Manisfesto Eletronico
	For i := 1 to len(aXMLMDfes)

		oProcess:IncRegua2("Processados: " + cValtochar(i) + "/" + cvaltochar(len(aXMLMDfes)))		

		If ImpMdfe(aXMLMDfes[i][1],aXMLMDfes[i][2],aXMLMDfes[i][3],aXMLMDfes[i][4])
			cXMLArq := aXMLMDfes[i][3]
			cXMLOut := StrTran(cXMLArq,cDirIn,cDirOut)
			__CopyFilee(cXMLArq,cXMLOut)
			FERASE( cXMLArq )
		End If
	Next

	oProcess:IncRegua1("Importando os Eventos dos MDF-e")	
	oProcess:SetRegua2(len(aXMLEMDFE))

	// 3 - Cancelamento/Encerramento Manifesto
	For i := 1 to len(aXMLEMDFE)

		oProcess:IncRegua2("Processados: " + cValtochar(i) + "/" + cvaltochar(len(aXMLEMDFE)))		

		If MdfeEnv(aXMLEMDFE[i][1],aXMLEMDFE[i][2],aXMLEMDFE[i][3],aXMLEMDFE[i][4])
			cXMLArq := aXMLEMDFE[i][3]
			cXMLOut := StrTran(cXMLArq,cDirIn,cDirOut)
			__CopyFilee(cXMLArq,cXMLOut)
			FERASE( cXMLArq )
		End If
	Next

	oProcess:IncRegua1("Importando os Eventos dos Ct-e")	
	oProcess:SetRegua2(len(aXMLECTE))

	// 4 - Cancelamentos do Ct-e
	For i:= 1 to Len (aXMLECTE)

		oProcess:IncRegua2("Processados: " + cValtochar(i) + "/" + cvaltochar(len(aXMLECTE)))		

		If CteEnv(aXMLECTE[i][1],aXMLECTE[i][2],aXMLECTE[i][3],aXMLECTE[i][4])
			cXMLArq := aXMLECTE[i][3]
			cXMLOut := StrTran(cXMLArq,cDirIn,cDirOut)
			__CopyFilee(cXMLArq,cXMLOut)
			FERASE( cXMLArq )
		End If
	Next


return


/*/{Protheus.doc} ImpXML
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 24/03/2020
@version 1.0
@return ${return}, ${return_description}
@param cXMLFile, characters, description
@param aProc, array, description
@param aErros, array, description
@type function
/*/
Static Function ImpXML(cXMLFile,aProc,aErros,cPrtcWS)
	Local cError   		:= ""
	Local cWarning 		:= ""
	Local nHandle 		:= 0
	Local lRet			:= .T.

	Default aProc   	:= {}
	Default aErros  	:= {}

	Private oXML 		:= NIL
	Private cBuffer 	:= ''
	Private nSize

	nHandle := FOpen(cXMLFile,FO_READ+FO_SHARED) //Parametros: Arquivo, Leitura - Escrita, Servidor

	If nHandle < 0
		cError := str(FError())
		aAdd(aErros,{cXMLFile,"Erro ao abrir arquivo: ( " + cError + CHR(13)+CHR(10), ")" + GFERetFError(FError())})
		Return .F.
	EndIf

	nSize := FSeek(nHandle,FS_SET,FS_END)
	FSeek(nHandle,0)
	FRead(nHandle,@cBuffer,nSize)

	oXML  := XmlParser( cBuffer , "_", @cError, @cWarning)
	FClose(nHandle)
	nHandle   := -1

	cArquivo := cXMLFile 

	If ValType(oXML)=="O"

		// Conhecimento de Frete
		If ValType(XmlChildEx(oXML,"_CTEPROC")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_CTE")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_VERSAO")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_PROTCTE")) == "O" //-- Arquivo de RETORNO de Nota de transporte
			oXML := oXML:_CTeProc
			AADD(aXMLCTes,{oXML,cBuffer,cArquivo,cPrtcWS})
		ElseIf ValType(XmlChildEx(oXML,"_CTE")) == "O" //-- Arquivo de REMESSA de Nota de transporte
			oXML := oXML:_Cte
			AADD(aXMLCTes,{oXML,cBuffer,cArquivo,cPrtcWS})
			// Evento de Cancelamento CTE	
		ElseIf ValType(XmlChildEx(oXML,"_ENVICTE")) == "O" .And. ValType(XmlChildEx(oXML:_enviCT,"_CTE"))  //-- Arquivo de Evento Cte
			oXML := oXML:_enviCTe:_Cte
			AADD(aXMLCTes,{oXML,cBuffer,cArquivo,cPrtcWS})
		ElseIf ValType(XmlChildEx(oXML,"_PROCEVENTOCTE")) == "O" //-- Arquivo de RETORNO de Evento Cte/Cancelamento
			oXML := oXML:_procEventoCTe
			AADD(aXMLECTE,{oXML,cBuffer,cArquivo,cPrtcWS})

			// Manifesto Eletronico	
		ElseIf ValType(XmlChildEx(oXML,"_MDFEPROC")) == "O" .and. ValType(XmlChildEx(oXML:_MDFEPROC,"_MDFE"))  == "O"
			oXML := oXML:_MDFEPROC
			AADD(aXMLMDfes,{oXML,cBuffer,cArquivo,cPrtcWS})
			// Evento de Cancelamento MDFE	
		ElseIf ValType(XmlChildEx(oXML,"_MDFEPROC")) == "O" .and. ValType(XmlChildEx(oXML:_MDFEPROC,"_EVENTOMDFE"))  == "O"
			oXML := oXML:_MDFEPROC
			AADD(aXMLEMDFE,{oXML,cBuffer,cArquivo,cPrtcWS})		
		ElseiF  ValType(XmlChildEx(oXML,"_PROCEVENTOMDFE")) == "O"
			oXML := oXML:_PROCEVENTOMDFE
			AADD(aXMLEMDFE,{oXML,cBuffer,cArquivo,cPrtcWS})
		Else
			If cError = ''
				cError := 'Arquivo com tag principal inválida.'
			EndIf

			aAdd(aErros,{cXMLFile,"Erro >> Arquivo: " + cError + CHR(13)+CHR(10), ""})
			lRet := .F.
			Return lRet
		EndIf
	Else
		Return .f.
	EndIf

Return lRet


/*/{Protheus.doc} ImpCte
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 24/03/2020
@version 1.0
@return ${return}, ${return_description}
@param oXML, object, description
@param cBuffer, characters, description
@type function
/*/
Static Function ImpCte(oXML,cBuffer,cArquivo,cPrtcWS)

	Local i			:= 0 , y := 0, Z := 0
	Local lRet		:= .t.
	Local aArquivos	:= {}
	Local cDestinat := SuperGetMV("MV_YEMLCTE",.F.,"santos.mauricio@totvs.com.br")
	Local nTotSZL	:= 0

	Private oXMLCTE		:= Nil
	Private oDest 		:= Nil
	Private oEmit 		:= Nil
	Private oRece 		:= Nil
	Private oReme 		:= Nil
	Private oExpe		:= Nil
	Private oIDE  		:= Nil
	Private oVpre 		:= Nil
	Private oImpo 		:= Nil
	Private oProc 		:= Nil
	Private oInfCTE		:= Nil
	Private oInfCTENORM := Nil
	Private oInfCarga 	:= Nil
	Private oInfDoc		:= Nil
	Private oInfNFe		:= Nil
	Private oInfModal 	:= NIl
	Private oImpICMS	:= Nil
	Private oInfOut		:= Nil

	//dE PARA
	oProc 		:= oXML:_protCTe:_infProt
	oXMLCTE 	:= oXML:_Cte

	oInfCTE  	:= IIF(ValType(XmlChildEx(oXMLCTE,"_INFCTE")) 		  	== "O" ,oXMLCTE:_INFcte			,Nil)
	oIDE  		:= IIF(ValType(XmlChildEx(oInfCTE,"_IDE")) 		  		== "O" ,oInfCTE:_IDE			,Nil)
	oEmit 		:= IIF(ValType(XmlChildEx(oInfCTE,"_EMIT")) 	  		== "O" ,oInfCTE:_Emit			,Nil) 
	oReme 		:= IIF(ValType(XmlChildEx(oInfCTE,"_REM")) 		  		== "O" ,oInfCTE:_Rem			,Nil) 
	oDest 		:= IIF(ValType(XmlChildEx(oInfCTE,"_DEST")) 	  		== "O" ,oInfCTE:_Dest			,Nil) 
	oRece 		:= IIF(ValType(XmlChildEx(oInfCTE,"_RECEB")) 	  		== "O" ,oInfCTE:_Receb			,Nil) 
	oExpe 		:= IIF(ValType(XmlChildEx(oInfCTE,"_EXPED")) 	 		== "O" ,oInfCTE:_Exped			,Nil) 
	oVpre 		:= IIF(ValType(XmlChildEx(oInfCTE,"_VPREST")) 	 		== "O" ,oInfCTE:_vPrest			,Nil) 
	oInfCTENORM := IIF(ValType(XmlChildEx(oInfCTE,"_INFCTENORM")) 		== "O" ,oInfCTE:_INFCTENORM	 	,Nil) 
	oInfCarga 	:= IIF(ValType(XmlChildEx(oInfCTENORM,"_INFCARGA")) 	== "O" ,oInfCTENORM:_INFCARGA	,Nil) 
	oInfDoc 	:= IIF(ValType(XmlChildEx(oInfCTENORM,"_INFDOC")) 		== "O" ,oInfCTENORM:_INFDOC		,Nil) 
	oInfNFe 	:= IIF(ValType(XmlChildEx(oInfDoc,"_INFNFE")) 		 	<> "U" ,oInfDoc:_INFNFE			,Nil) 
	oImpICMS	:= IIF(ValType(XmlChildEx(oInfCTE:_IMP,"_ICMS"))  		== "O" ,oInfCTE:_IMP:_ICMS		,Nil) 

	oModel := FWLoadModel("SERTMS06")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:SetValue('SZKMASTER', 'ZK_XML' 	 ,cBuffer)
	oModel:SetValue('SZKMASTER', 'ZK_PRTCWS' ,cPrtcWS)

	// Dados unicos
	For i:= 1 to len(aDados)
		For y:= 1 to len(aDados[i])

			If Type(aDados[i][y][1]) == "O" 
				If &("AttIsMemberOf(" + aDados[i][y][1] + ",'" + aDados[i][y][2] + "')")
					&("oModel:SetValue('" + aDados[i][y][3]   + "', '" + aDados[i][y][4]  + "' , " + (aDados[i][y][5]) + ")" )
				End If
			End If
		Next
	Next

	// Documentos nao eletronicos
	If ValType(oInfDoc) == "O" 

		If AttIsMemberOf(oInfDoc,'_INFOUTROS')

			//DADOS DAS NOTAS FISCAIS
			IF ValType(XmlChildEx(oInfDoc,"_INFOUTROS")) != "A"
				XmlNode2Arr( oInfDoc:_INFOUTROS, "_INFOUTROS" )
			End iF

			oInfOut := oInfDoc:_INFOUTROS

			For z:= 1 to len(oInfOut)
				If !oModel:GetModel("SZLDETAIL"):IsEmpty()
					oModel:GetModel("SZLDETAIL"):AddLine()
				End IF

				nTotSZL := oModel:GetModel("SZLDETAIL"):Length()
				cTotLin := PADL(nTotSZL,TamSX3("ZL_SEQUENC")[1],"0")

				oModel:SetValue("SZLDETAIL","ZL_SEQUENC",cTotLin)
				oModel:SetValue("SZLDETAIL","ZL_NUMNF"	,PadL( oInfOut[z]:_nDOC:Text, TamSx3('ZK_DOC')[1], '0' ))
				oModel:SetValue("SZLDETAIL","ZL_SERIENF",oInfOut[z]:_tpDOC:Text)
				oModel:SetValue("SZLDETAIL","ZL_DTEMISS",STOD(StrTran(SUBSTR(oInfOut[z]:_dEmi:text,1,10),'-','')))

			Next


		End if
	End if


	If ValType(oInfNFe) == "O" 
		If AttIsMemberOf(oInfNFe,'_CHAVE')

			//DADOS DAS NOTAS FISCAIS
			IF ValType(XmlChildEx(oInfNFe,"_CHAVE")) != "A"
				XmlNode2Arr( oInfNFe:_CHAVE, "_CHAVE" )
			End iF

			For z:= 1 to len(oInfNFe:_CHAVE)
				If !oModel:GetModel("SZLDETAIL"):IsEmpty()
					oModel:GetModel("SZLDETAIL"):AddLine()
				End IF

				nTotSZL := oModel:GetModel("SZLDETAIL"):Length()
				cTotLin := PADL(nTotSZL,TamSX3("ZL_SEQUENC")[1],"0")

				oModel:SetValue("SZLDETAIL","ZL_SEQUENC",cTotLin)
				oModel:SetValue("SZLDETAIL","ZL_CHVNFE"	,oInfNFe:_chave[z]:Text)
				oModel:SetValue("SZLDETAIL","ZL_NUMNF"	,SUBSTR(oInfNFe:_chave[z]:Text,26,9))
				oModel:SetValue("SZLDETAIL","ZL_SERIENF",SUBSTR(oInfNFe:_chave[z]:Text,23,3))

				cData := SUBSTR(DTOS(DDATABASE),1,2) + SUBSTR(oInfNFe:_chave[z]:Text,3,4) + "01"

				oModel:SetValue("SZLDETAIL","ZL_DTEMISS",Stod(cData))

			Next
		End If

	Elseif ValType(oInfNFe) == "A" 

		For z:= 1 to len(oInfNFe)
			If !oModel:GetModel("SZLDETAIL"):IsEmpty()
				oModel:GetModel("SZLDETAIL"):AddLine()
			End IF

			nTotSZL := oModel:GetModel("SZLDETAIL"):Length()
			cTotLin := PADL(nTotSZL,TamSX3("ZL_SEQUENC")[1],"0")

			oModel:SetValue("SZLDETAIL","ZL_SEQUENC",cTotLin)
			oModel:SetValue("SZLDETAIL","ZL_CHVNFE"	,oInfNFe[z]:_chave:Text)
			oModel:SetValue("SZLDETAIL","ZL_NUMNF"	,SUBSTR(oInfNFe[z]:_chave:Text,26,9))
			oModel:SetValue("SZLDETAIL","ZL_SERIENF",SUBSTR(oInfNFe[z]:_chave:Text,23,3))

			cData := SUBSTR(DTOS(DDATABASE),1,2) + SUBSTR(oInfNFe[z]:_chave:Text,3,4) + "01"

			oModel:SetValue("SZLDETAIL","ZL_DTEMISS",Stod(cData))
		Next

	End IF

	//DADOS DA CARGA
	IF ValType(XmlChildEx(oInfCarga,"_INFQ")) != "A"
		XmlNode2Arr( oInfCarga:_INFQ, "_INFQ" )
	End iF

	If ValType(oInfCarga) == "O" 
		If AttIsMemberOf(oInfCarga,'_INFQ')

			For z:= 1 to len(oInfCarga:_INFQ)

				If oInfCarga:_INFQ[z]:_cUnid:Text == "00"
					oModel:SetValue("SZKMASTER","ZK_MTCUBIC",Val(oInfCarga:_INFQ[z]:_qCarga:Text))
				End IF

				If oInfCarga:_INFQ[z]:_cUnid:Text == "03"
					oModel:SetValue("SZKMASTER","ZK_QTDVOL" ,Val(oInfCarga:_INFQ[z]:_qCarga:Text))
				End If

				If UPPER(Alltrim(oInfCarga:_INFQ[z]:_TPMED:Text))  $ 'KILOGRAMAS/PESO DECLARADO/PESO LIQUIDO' 
					oModel:SetValue("SZKMASTER","ZK_PESOD"	,Val(oInfCarga:_INFQ[z]:_qCarga:Text))
				End if

				If 'CUBADO' $ oInfCarga:_INFQ[z]:_TPMED:Text 
					oModel:SetValue("SZKMASTER","ZK_PESOC"	,Val(oInfCarga:_INFQ[z]:_qCarga:Text))
				End if
			Next
		End If
	End IF

	If oModel:VldData()
		If oModel:CommitData()
			lRet := .t.
			cPara := cDestinat
			cAssunto := "XML CTE SERRANA"
			cMensagem := "Segue em anexo o arquivo XML"
			AADD(aArquivos,cArquivo )
			U_SERFRW01(cPara,cAssunto,cMensagem,aArquivos)
		Else
			lRet := .f.
		End If
	Else
		lRet:= .f.
	End IF

Return lRet

/*/{Protheus.doc} CteEnv
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 24/03/2020
@version 1.0
@return ${return}, ${return_description}
@param oXML, object, description
@param cBuffer, characters, description
@type function
/*/
Static Function CteEnv(oXML,cBuffer,cArquivo,cPrtcWS)

	Local oModel := Nil
	Local i:= 0, y:= 0
	Local lRet 	:= .t.

	Private oEvento		:= Nil
	Private oInfEnv		:= Nil
	Private oDetEvn		:= Nil
	Private oInfRet		:= Nil
	Private oRetEnv		:= Nil

	oEvento := IIF(ValType(XmlChildEx(oXML,"_EVENTOCTE")) 	 	== "O" ,oXML:_EVENTOCTE			,Nil)
	oInfEnv := IIF(ValType(XmlChildEx(oEvento,"_INFEVENTO")) 	== "O" ,oEvento:_INFEVENTO		,Nil)
	oDetEvn := IIF(ValType(XmlChildEx(oInfEnv,"_DETEVENTO"))	== "O" ,oInfEnv:_DETEVENTO		,Nil)
	oInfRet := IIF(ValType(XmlChildEx(oXML,"_RETEVENTOCTE")) 	== "O" ,oXML:_RETEVENTOCTE		,Nil)
	oRetEnv := IIF(ValType(XmlChildEx(oInfRet,"_INFEVENTO"))	== "O" ,oInfRet:_INFEVENTO		,Nil)

	oModel := FWLoadModel("SERTMS07")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:SetValue('SZMMASTER', 'ZM_XML' 	,cBuffer)
	oModel:SetValue('SZMMASTER', 'ZM_PRTCWS' ,cPrtcWS)

	// Dados unicos
	For i:= 1 to len(aEvento)
		For y:= 1 to len(aEvento[i])

			If Type(aEvento[i][y][1]) == "O" 
				If &("AttIsMemberOf(" + aEvento[i][y][1] + ",'" + aEvento[i][y][2] + "')")
					&("oModel:SetValue('" + aEvento[i][y][3]   + "', '" + aEvento[i][y][4]  + "' , " + (aEvento[i][y][5]) + ")" )
				End If
			End If
		Next
	Next

	If oModel:VldData()
		If !oModel:CommitData()
			lRet := .f.
		End If
	Else
		lRet:= .f.
	End IF
Return lRet


/*/{Protheus.doc} ImpMDFE
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}
@param oXML, object, description
@param cBuffer, characters, description
@type function
/*/
Static Function ImpMDFE(oXML,cBuffer,cArquivo,cPrtcWS)

	Local oModel		:= Nil
	Local i				:= 0 , y:= 0, z:= 0
	Local lRet			:= .t. 

	Private oMDFE		:= Nil
	Private oInfMDFE	:= Nil
	Private oIDEMDFE	:= Nil
	Private oEmitMDFE	:= Nil
	Private oProtMDFE	:= Nil
	Private oInfProt	:= Nil
	Private oInfModal	:= Nil
	Private oRodo		:= Nil
	Private oVeicTrac   := Nil
	Private oVeicReb	:= Nil
	Private oCondutor	:= Nil
	Private oInfDOCMDFE := Nil
	Private oMunDesc	:= Nil


	oMDFE 	  := IIF(ValType(XmlChildEx(oXML,"_MDFE")) 			== "O" ,oXML:_MDFE			,Nil)	
	oProtMDFE := IIF(ValType(XmlChildEx(oXML,"_PROTMDFE"))		== "O" ,oXML:_PROTMDFE		,Nil)	
	oInfMDFE  := IIF(ValType(XmlChildEx(oMDFE,"_INFMDFE"))		== "O" ,oMDFE:_INFMDFE		,Nil)

	oEmitMDFE := IIF(ValType(XmlChildEx(oInfMDFE,"_EMIT")) 		== "O" ,oInfMDFE:_EMIT		,Nil)
	oInfModal := IIF(ValType(XmlChildEx(oInfMDFE,"_INFMODAL")) 	== "O" ,oInfMDFE:_INFMODAL	,Nil)
	oIDEMDFE  := IIF(ValType(XmlChildEx(oInfMDFE,"_IDE")) 		== "O" ,oInfMDFE:_IDE		,Nil)
	oInfProt  := IIF(ValType(XmlChildEx(oProtMDFE,"_INFPROT"))	== "O" ,oProtMDFE:_INFPROT	,Nil)

	oRodo	  :=  IIF(ValType(XmlChildEx(oInfModal,"_RODO")) 	== "O" ,oInfModal:_RODO		,Nil)
	oVeicTrac :=  IIF(ValType(XmlChildEx(oRodo,"_VEICTRACAO")) 	== "O" ,oRodo:_VEICTRACAO	,Nil)
	oVeicReb  :=  IIF(ValType(XmlChildEx(oRodo,"_VEICREBOQUE")) == "O" ,oRodo:_VEICREBOQUE	,Nil)
	oCondutor :=  IIF(ValType(XmlChildEx(oVeicTrac,"_CONDUTOR")) == "O",oVeicTrac:_CONDUTOR	,Nil)
	oInfDOCMDFE := IIF(ValType(XmlChildEx(oInfMDFE,"_INFDOC")) 	== "O" ,oInfMDFE:_INFDOC	,Nil)	

	oMunDesc	:=  IIF(ValType(XmlChildEx(oInfDOCMDFE,"_INFMUNDESCARGA")) == "O" ,oInfDOCMDFE:_INFMUNDESCARGA		,Nil)

	oModel := FWLoadModel("SERTMS08")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:SetValue('SZNMASTER', 'ZN_XML' 	 ,cBuffer)
	oModel:SetValue('SZNMASTER', 'ZN_PRTCWS' ,cPrtcWS)

	// Dados unicos
	For i:= 1 to len(aMDFE)
		For y:= 1 to len(aMDFE[i])

			If Type(aMDFE[i][y][1]) == "O" 
				If &("AttIsMemberOf(" + aMDFE[i][y][1] + ",'" + aMDFE[i][y][2] + "')")
					&("oModel:SetValue('" + aMDFE[i][y][3]   + "', '" + aMDFE[i][y][4]  + "' , " + (aMDFE[i][y][5]) + ")" )
				End If
			End If
		Next
	Next

	//DADOS DOS REBOQUES

	if AttIsMemberOf(oRodo,'_VEICREBOQUE')
		IF ValType(XmlChildEx(oRodo,"_VEICREBOQUE")) != "A"
			XmlNode2Arr( oRodo:_VEICREBOQUE, "_VEICREBOQUE" )
			oVeicReb := oRodo:_VEICREBOQUE
		End iF	

		If ValType(oRodo) == "O" 

			For z:= 1 to len(oRodo:_VEICREBOQUE)

				If z <= 3 
					oModel:SetValue("SZNMASTER","ZN_PLARB" + cValToChar(z)	,oRodo:_VEICREBOQUE[Z]:_PLACA:text)
				End IF
			Next

		End If
	End If


	//DADOS DAS NOTAS FISCAIS
	IF ValType(XmlChildEx(oInfDOCMDFE,"_INFMUNDESCARGA")) != "A"
		XmlNode2Arr( oInfDOCMDFE:_INFMUNDESCARGA, "_INFMUNDESCARGA" )
	End iF

	If ValType(oInfDOCMDFE) == "O" 
		If AttIsMemberOf(oInfDOCMDFE,'_INFMUNDESCARGA')

			For z:= 1 to len(oInfDOCMDFE:_INFMUNDESCARGA)

				IF ValType(XmlChildEx(oInfDOCMDFE:_INFMUNDESCARGA[Z],"_INFCTE")) != "A"
					XmlNode2Arr( oInfDOCMDFE:_INFMUNDESCARGA[Z]:_INFCTE, "_INFCTE" )
				End if

				For y:= 1 to len(oInfDOCMDFE:_INFMUNDESCARGA[Z]:_INFCTE)

					If !oModel:GetModel("SZODETAIL"):IsEmpty()
						oModel:GetModel("SZODETAIL"):AddLine()
					End IF

					oModel:SetValue("SZODETAIL","ZO_CHVCTE"	,oInfDOCMDFE:_INFMUNDESCARGA[Z]:_INFCTE[y]:_chCTe:text)
					oModel:SetValue("SZODETAIL","ZO_NUMCTE"	,SUBSTR(oInfDOCMDFE:_INFMUNDESCARGA[Z]:_INFCTE[y]:_chCTe:text,26,9))
					oModel:SetValue("SZODETAIL","ZO_SERIE"	,SUBSTR(oInfDOCMDFE:_INFMUNDESCARGA[Z]:_INFCTE[y]:_chCTe:text,23,3))					
					oModel:SetValue("SZODETAIL","ZO_CMUNI"	,oInfDOCMDFE:_INFMUNDESCARGA[Z]:_CMUNDESCARGA:text)
					oModel:SetValue("SZODETAIL","ZO_MUNI"	,oInfDOCMDFE:_INFMUNDESCARGA[Z]:_XMUNDESCARGA:text)				
				Next
			Next
		End If
	End IF	

	If oModel:VldData()
		If !oModel:CommitData()
			lRet := .f.
		End If
	Else
		lRet:= .f.
	End IF

Return lRet

Static Function MdfeEnv(oXML,cBuffer,cArquivo,cPrtcWS)

	Local oModel := Nil
	Local i:= 0, y:= 0
	Local lRet 	:= .t.

	Private oEvento		:= Nil
	Private oInfEnv		:= Nil
	Private oDetEvn		:= Nil
	Private oInfRet		:= Nil
	Private oRetEnv		:= Nil
	Private oMdfeRe	:= Nil

	oEvento := IIF(ValType(XmlChildEx(oXML,"_EVENTOMDFE")) 	 	== "O" ,oXML:_EVENTOMDFE		,Nil)
	oInfEnv := IIF(ValType(XmlChildEx(oEvento,"_INFEVENTO")) 	== "O" ,oEvento:_INFEVENTO		,Nil)
	oDetEvn := IIF(ValType(XmlChildEx(oInfEnv,"_DETEVENTO"))	== "O" ,oInfEnv:_DETEVENTO		,Nil)

	oMdfeRe := IIF(ValType(XmlChildEx(oXML,"_MDFERECEPCAOEVENTORESULT")) == "O" ,oXML:_MDFERECEPCAOEVENTORESULT	,Nil)

	If ValType(oMdfeRe) == "O" 
		oInfRet := IIF(ValType(XmlChildEx(oMdfeRe,"_RETEVENTOMDFE")) 	== "O" ,oMdfeRe:_RETEVENTOMDFE		,Nil)
	Else
		oInfRet := IIF(ValType(XmlChildEx(oXML,"_RETEVENTOMDFE")) 	== "O" ,oXML:_RETEVENTOMDFE		,Nil)
	End if

	oRetEnv := IIF(ValType(XmlChildEx(oInfRet,"_INFEVENTO"))	== "O" ,oInfRet:_INFEVENTO		,Nil)

	oModel := FWLoadModel("SERTMS09")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:SetValue('SZPMASTER', 'ZP_XML' 	 ,cBuffer)
	oModel:SetValue('SZPMASTER', 'ZP_PRTCWS' ,cPrtcWS)

	// Dados unicos
	For i:= 1 to len(aCanMDFE)
		For y:= 1 to len(aCanMDFE[i])

			If Type(aCanMDFE[i][y][1]) == "O" 
				If &("AttIsMemberOf(" + aCanMDFE[i][y][1] + ",'" + aCanMDFE[i][y][2] + "')")
					&("oModel:SetValue('" + aCanMDFE[i][y][3]   + "', '" + aCanMDFE[i][y][4]  + "' , " + (aCanMDFE[i][y][5]) + ")" )
				End If
			End If
		Next
	Next

	If oModel:VldData()
		If !oModel:CommitData()
			lRet := .f.
		End If
	Else
		lRet:= .f.
	End IF
Return lRet


/*/{Protheus.doc} CteStr
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 24/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CteStr()

	Local aIDE  		:= {}
	Local aEmit 		:= {}
	Local aReme 		:= {}
	Local aDest 		:= {}
	Local aRece 		:= {}
	Local aExpe 		:= {}
	Local aVpre 		:= {}
	Local aProc 		:= {}
	Local aInfCarga		:= {}
	Local aImpICMS		:= {}

	//Dados do Cte
	AADD(aIDE, {"oIDE","_cCT"							, "SZKMASTER", "ZK_NUM"		, "oIDE:_cCT:Text"} )
	AADD(aIDE, {"oIDE","_cDV"							, "SZKMASTER", "ZK_DV" 		, "oIDE:_cDV:Text"} )
	AADD(aIDE, {"oIDE","_CFOP"							, "SZKMASTER", "ZK_CFOP"	, "oIDE:_CFOP:Text"} )
	AADD(aIDE, {"oIDE","_indGlobalizado"				, "SZKMASTER", "ZK_CTEGLOB"	, "oIDE:_indGlobalizado:Text"} )
	AADD(aIDE, {"oIDE","_cMunEnv"						, "SZKMASTER", "ZK_MUNENV"	, "oIDE:_cMunEnv:Text"} )
	AADD(aIDE, {"oIDE","_cMunFim"						, "SZKMASTER", "ZK_MUNFIM"	, "oIDE:_cMunFim:Text"} )
	AADD(aIDE, {"oIDE","_cMunIni"						, "SZKMASTER", "ZK_MUNINI"	, "oIDE:_cMunIni:Text"} )
	AADD(aIDE, {"oIDE","_indIEToma"						, "SZKMASTER", "ZK_INDTOMA"	, "oIDE:_indIEToma:Text"} )
	AADD(aIDE, {"oIDE","_modal"							, "SZKMASTER", "ZK_MODAL"	, "oIDE:_modal:Text"} )
	AADD(aIDE, {"oIDE","_nCT"							, "SZKMASTER", "ZK_DOC"		, "PadL( oIDE:_nCT:Text, TamSx3('ZK_DOC')[1], '0' )"} )
	AADD(aIDE, {"oIDE","_serie"							, "SZKMASTER", "ZK_SERIE"	, "oIDE:_serie:Text"} )
	AADD(aIDE, {"oIDE","_procEmi"						, "SZKMASTER", "ZK_PROCEMI"	, "oIDE:_procEmi:Text"} )
	AADD(aIDE, {"oIDE","_retira"						, "SZKMASTER", "ZK_RETIRA"	, "oIDE:_retira:Text"} )	
	AADD(aIDE, {"oIDE:_TOMA3","_toma"					, "SZKMASTER", "ZK_TOMA3"	, "oIDE:_TOMA3:_toma:Text"} )	
	AADD(aIDE, {"oIDE","_tpAmb"							, "SZKMASTER", "ZK_TPAMB"	, "oIDE:_tpAmb:Text"} )
	AADD(aIDE, {"oIDE","_tpCTe"							, "SZKMASTER", "ZK_TPCTE"	, "oIDE:_tpCTe:Text"} )
	AADD(aIDE, {"oIDE","_tpEmis"						, "SZKMASTER", "ZK_TPEMISS"	, "oIDE:_tpEmis:Text"} )
	AADD(aIDE, {"oIDE","_tpServ"						, "SZKMASTER", "ZK_TPSERV"	, "oIDE:_tpServ:Text"} )
	AADD(aIDE, {"oIDE","_UFEnv"							, "SZKMASTER", "ZK_UFENV"	, "oIDE:_UFEnv:Text"} )
	AADD(aIDE, {"oIDE","_UFFim"							, "SZKMASTER", "ZK_UFFIM"	, "oIDE:_UFFim:Text"} )
	AADD(aIDE, {"oIDE","_UFIni"							, "SZKMASTER", "ZK_UFINI"	, "oIDE:_UFIni:Text"} )
	AADD(aIDE, {"oIDE","_verProc"						, "SZKMASTER", "ZK_VERPROC"	, "oIDE:_verProc:Text"} )
	AADD(aIDE, {"oIDE","_xDetRetira"					, "SZKMASTER", "ZK_XDETRET"	, "oIDE:_xDetRetira:Text"} )
	AADD(aIDE, {"oIDE","_xMunEnv"						, "SZKMASTER", "ZK_XMUNENV"	, "oIDE:_xMunEnv:Text"} )
	AADD(aIDE, {"oIDE","_xMunFim"						, "SZKMASTER", "ZK_XMUNFIM"	, "oIDE:_xMunFim:Text"} )
	AADD(aIDE, {"oIDE","_xMunIni"						, "SZKMASTER", "ZK_XMUNINI"	, "oIDE:_xMunIni:Text"} )
	AADD(aIDE, {"oIDE","_dhEmi"							, "SZKMASTER", "ZK_DTEMISS"	, "STOD(StrTran(SUBSTR(oIDE:_dhEmi:text,1,10),'-',''))"} )
	AADD(aIDE, {"oIDE","_dhEmi"							, "SZKMASTER", "ZK_HREMISS"	, "SUBSTR(oIDE:_dhEmi:text,12,8)"} )

	AADD(aIDE, {"oInfCTE:_COMPL","_xobs"				, "SZKMASTER", "ZK_XOBS"	, "oInfCTE:_COMPL:_xobs:Text"} )	
	AADD(aIDE, {"oInfCTE:_COMPL","_xobs"				, "SZKMASTER", "ZK_PLACA"	, "GetPlaca(oInfCTE:_COMPL:_xobs:Text)"} )	
	AADD(aIDE, {"oInfCTE:_COMPL","_xobs"				, "SZKMASTER", "ZK_CPFMOTO"	, "GetCPFMot(oInfCTE:_COMPL:_xobs:Text)"} )	

	//Dados Financeiros
	AADD(aVpre,{"oVpre","_vRec"							, "SZKMASTER", "ZK_VREC"	, "val(oVpre:_vRec:Text)"} )
	AADD(aVpre,{"oVpre","_vTPrest"						, "SZKMASTER", "ZK_VLPREST"	, "val(oVpre:_vTPrest:Text)"} )

	//Dados do Emitente
	AADD(aEmit,{"oEmit","_CNPJ"							, "SZKMASTER", "ZK_CGCEMI"	, "oEmit:_CNPJ:Text"} )

	//Dados do Remetente
	AADD(aReme,{"oReme","_CNPJ"							, "SZKMASTER", "ZK_CGCREM"	, "oReme:_CNPJ:Text"} )
	AADD(aReme,{"oReme","_CPF"							, "SZKMASTER", "ZK_CGCREM"	, "oReme:_CPF:Text"} )
	AADD(aReme,{"oReme","_IE"							, "SZKMASTER", "ZK_IEREM"	, "oReme:_IE:Text"} )
	AADD(aReme,{"oReme","_xNome"						, "SZKMASTER", "ZK_XNOMERE"	, "oReme:_xNome:Text"} )
	AADD(aReme,{"oReme","_xFant"						, "SZKMASTER", "ZK_XFANTRE"	, "oReme:_xFant:Text"} )
	AADD(aReme,{"oReme","_email"						, "SZKMASTER", "ZK_EMAIREM"	, "oReme:_email:Text"} )
	AADD(aReme,{"oReme","_fone"							, "SZKMASTER", "ZK_FONEREM"	, "oReme:_fone:Text"} )
	AADD(aReme,{"oReme:_enderReme","_xCpl"				, "SZKMASTER", "ZK_CPLREM"	, "oReme:_enderReme:_xCpl:Text"} )
	AADD(aReme,{"oReme:_enderReme","_CEP"				, "SZKMASTER", "ZK_CEPREM"	, "oReme:_enderReme:_CEP:Text"} )
	AADD(aReme,{"oReme:_enderReme","_cMun"				, "SZKMASTER", "ZK_CMUREM"	, "oReme:_enderReme:_cMun:Text"} )	
	AADD(aReme,{"oReme:_enderReme","_nro"				, "SZKMASTER", "ZK_NROREM"	, "oReme:_enderReme:_nro:Text"} )	
	AADD(aReme,{"oReme:_enderReme","_UF"				, "SZKMASTER", "ZK_UFREM"	, "oReme:_enderReme:_UF:Text"} )		
	AADD(aReme,{"oReme:_enderReme","_xBairro"			, "SZKMASTER", "ZK_BAIREM"	, "oReme:_enderReme:_xBairro:Text"} )
	AADD(aReme,{"oReme:_enderReme","_xLgr"				, "SZKMASTER", "ZK_ENDREM"	, "oReme:_enderReme:_xLgr:Text"} )	
	AADD(aReme,{"oReme:_enderReme","_xMun"				, "SZKMASTER", "ZK_MUNREM"	, "oReme:_enderReme:_xMun:Text"} )	
	AADD(aReme,{"oReme:_enderReme","_cPais"				, "SZKMASTER", "ZK_PAISREM"	, "oReme:_enderReme:_cPais:Text"} )
	AADD(aReme,{"oReme:_enderReme","_xPais"				, "SZKMASTER", "ZK_NPAISRE"	, "oReme:_enderReme:_xPais:Text"} )		

	//Dados do Destinatario
	AADD(aDest,{"oDest","_CNPJ"							, "SZKMASTER", "ZK_CGCDES"	, "oDest:_CNPJ:Text"} )
	AADD(aDest,{"oDest","_CPF"							, "SZKMASTER", "ZK_CGCDES"	, "oDest:_CPF:Text"} )
	AADD(aDest,{"oDest","_IE"							, "SZKMASTER", "ZK_IEDES"	, "oDest:_IE:Text"} )
	AADD(aDest,{"oDest","_xNome"						, "SZKMASTER", "ZK_XNOMEDE"	, "oDest:_xNome:Text"} )
	AADD(aDest,{"oDest","_xFant"						, "SZKMASTER", "ZK_XFANTDE"	, "oDest:_xFant:Text"} )
	AADD(aDest,{"oDest","_email"						, "SZKMASTER", "ZK_EMAIREM"	, "oDest:_email:Text"} )
	AADD(aDest,{"oDest","_fone"							, "SZKMASTER", "ZK_FONEDES"	, "oDest:_fone:Text"} )
	AADD(aDest,{"oDest:_enderDest","_CEP"				, "SZKMASTER", "ZK_CEPDES"	, "oDest:_enderDest:_CEP:Text"} )
	AADD(aDest,{"oDest:_enderDest","_xCpl"				, "SZKMASTER", "ZK_CPLDES"	, "oDest:_enderDest:_xCpl:Text"} )
	AADD(aDest,{"oDest:_enderDest","_cMun"				, "SZKMASTER", "ZK_CMUDES"	, "oDest:_enderDest:_cMun:Text"} )	
	AADD(aDest,{"oDest:_enderDest","_nro"				, "SZKMASTER", "ZK_NRODES"	, "oDest:_enderDest:_nro:Text"} )	
	AADD(aDest,{"oDest:_enderDest","_UF"				, "SZKMASTER", "ZK_UFDES"	, "oDest:_enderDest:_UF:Text"} )		
	AADD(aDest,{"oDest:_enderDest","_xBairro"			, "SZKMASTER", "ZK_BAIDES"	, "oDest:_enderDest:_xBairro:Text"} )
	AADD(aDest,{"oDest:_enderDest","_xLgr"				, "SZKMASTER", "ZK_ENDDES"	, "oDest:_enderDest:_xLgr:Text"} )	
	AADD(aDest,{"oDest:_enderDest","_xMun"				, "SZKMASTER", "ZK_MUNDES"	, "oDest:_enderDest:_xMun:Text"} )	
	AADD(aDest,{"oDest:_enderDest","_cPais"				, "SZKMASTER", "ZK_PAISDES"	, "oDest:_enderDest:_cPais:Text"} )
	AADD(aDest,{"oDest:_enderDest","_xPais"				, "SZKMASTER", "ZK_NPAIDES"	, "oDest:_enderDest:_xPais:Text"} )	

	//Dados do Recebedor
	AADD(aRece,{"oRece","_CNPJ"							, "SZKMASTER", "ZK_CGCRCB"	, "oRece:_CNPJ:Text"} )
	AADD(aRece,{"oRece","_CPF"							, "SZKMASTER", "ZK_CGCRCB"	, "oRece:_CPF:Text"} )
	AADD(aRece,{"oRece","_IE"							, "SZKMASTER", "ZK_IERCB"	, "oRece:_IE:Text"} )
	AADD(aRece,{"oRece","_xNome"						, "SZKMASTER", "ZK_XNOMERC"	, "oRece:_xNome:Text"} )
	AADD(aRece,{"oRece","_xFant"						, "SZKMASTER", "ZK_XFANTRC"	, "oRece:_xFant:Text"} )
	AADD(aRece,{"oRece","_email"						, "SZKMASTER", "ZK_EMAIRCB"	, "oRece:_email:Text"} )
	AADD(aRece,{"oRece","_fone"							, "SZKMASTER", "ZK_FONERCB"	, "oRece:_fone:Text"} )
	AADD(aRece,{"oRece:_enderReceb","_CEP"				, "SZKMASTER", "ZK_CEPRCB"	, "oRece:_enderReceb:_CEP:Text"} )
	AADD(aRece,{"oRece:_enderReceb","_xCpl"				, "SZKMASTER", "ZK_CPLRCB"	, "oRece:_enderReceb:_xCpl:Text"} )
	AADD(aRece,{"oRece:_enderReceb","_cMun"				, "SZKMASTER", "ZK_CMURCB"	, "oRece:_enderReceb:_cMun:Text"} )	
	AADD(aRece,{"oRece:_enderReceb","_nro"				, "SZKMASTER", "ZK_NRORCB"	, "oRece:_enderReceb:_nro:Text"} )	
	AADD(aRece,{"oRece:_enderReceb","_UF"				, "SZKMASTER", "ZK_UFRCB"	, "oRece:_enderReceb:_UF:Text"} )		
	AADD(aRece,{"oRece:_enderReceb","_xBairro"			, "SZKMASTER", "ZK_BAIRCB"	, "oRece:_enderReceb:_xBairro:Text"} )
	AADD(aRece,{"oRece:_enderReceb","_xLgr"				, "SZKMASTER", "ZK_ENDRCB"	, "oRece:_enderReceb:_xLgr:Text"} )	
	AADD(aRece,{"oRece:_enderReceb","_xMun"				, "SZKMASTER", "ZK_MUNRCB"	, "oRece:_enderReceb:_xMun:Text"} )	
	AADD(aRece,{"oRece:_enderReceb","_cPais"			, "SZKMASTER", "ZK_PAISRCB"	, "oRece:_enderReceb:_cPais:Text"} )
	AADD(aRece,{"oRece:_enderReceb","_xPais"			, "SZKMASTER", "ZK_NPAIRCB"	, "oRece:_enderReceb:_xPais:Text"} )

	//Dados do Expedidor
	AADD(aExpe,{"oExpe","_CNPJ"							, "SZKMASTER", "ZK_CGCEXP"	, "oExpe:_CNPJ:Text"} )
	AADD(aExpe,{"oExpe","_CPF"							, "SZKMASTER", "ZK_CGCEXP"	, "oExpe:_CPF:Text"} )
	AADD(aExpe,{"oExpe","_IE"							, "SZKMASTER", "ZK_IEEXP"	, "oExpe:_IE:Text"} )
	AADD(aExpe,{"oExpe","_xNome"						, "SZKMASTER", "ZK_XNOMEEX"	, "oExpe:_xNome:Text"} )
	AADD(aExpe,{"oExpe","_xFant"						, "SZKMASTER", "ZK_XFANTEX"	, "oExpe:_xFant:Text"} )
	AADD(aExpe,{"oExpe","_email"						, "SZKMASTER", "ZK_EMAIEXP"	, "oExpe:_email:Text"} )
	AADD(aExpe,{"oExpe","_fone"							, "SZKMASTER", "ZK_FONEEXP"	, "oExpe:_fone:Text"} )
	AADD(aExpe,{"oExpe:_enderExped","_CEP"				, "SZKMASTER", "ZK_CEPEXP"	, "oExpe:_enderExped:_CEP:Text"} )
	AADD(aExpe,{"oExpe:_enderExped","_xCpl"				, "SZKMASTER", "ZK_CPLEXP"	, "oExpe:_enderExped:_xCpl:Text"} )
	AADD(aExpe,{"oExpe:_enderExped","_cMun"				, "SZKMASTER", "ZK_CMUEXP"	, "oExpe:_enderExped:_cMun:Text"} )	
	AADD(aExpe,{"oExpe:_enderExped","_nro"				, "SZKMASTER", "ZK_NROEXP"	, "oExpe:_enderExped:_nro:Text"} )	
	AADD(aExpe,{"oExpe:_enderExped","_UF"				, "SZKMASTER", "ZK_UFEXP"	, "oExpe:_enderExped:_UF:Text"} )		
	AADD(aExpe,{"oExpe:_enderExped","_xBairro"			, "SZKMASTER", "ZK_BAIEXP"	, "oExpe:_enderExped:_xBairro:Text"} )
	AADD(aExpe,{"oExpe:_enderExped","_xLgr"				, "SZKMASTER", "ZK_ENDEXP"	, "oExpe:_enderExped:_xLgr:Text"} )	
	AADD(aExpe,{"oExpe:_enderExped","_xMun"				, "SZKMASTER", "ZK_MUNEXP"	, "oExpe:_enderExped:_xMun:Text"} )	
	AADD(aExpe,{"oExpe:_enderExped","_cPais"			, "SZKMASTER", "ZK_PAISEXP"	, "oExpe:_enderExped:_cPais:Text"} )
	AADD(aExpe,{"oExpe:_enderExped","_xPais"			, "SZKMASTER", "ZK_NPAISEX"	, "oExpe:_enderExped:_xPais:Text"} )

	//Dados Protocolo
	AADD(aProc,{"oProc","_chCTe"						, "SZKMASTER", "ZK_CHAVE"	, "oProc:_chCTe:Text"} )
	AADD(aProc,{"oProc","_cStat"						, "SZKMASTER", "ZK_STATUS"	, "oProc:_cStat:Text"} )
	AADD(aProc,{"oProc","_dhRecbto"						, "SZKMASTER", "ZK_DTPROTO"	, "STOD(StrTran(SUBSTR(oProc:_dhRecbto:text,1,10),'-',''))"} )
	AADD(aProc,{"oProc","_dhRecbto"						, "SZKMASTER", "ZK_HRPROTO"	, "SUBSTR(oProc:_dhRecbto:text,12,8)"} )
	AADD(aProc,{"oProc","_nProt"						, "SZKMASTER", "ZK_PROTSEF"	, "oProc:_nProt:Text"} )
	AADD(aProc,{"oProc","_verAplic"						, "SZKMASTER", "ZK_VERAPLI"	, "oProc:_verAplic:Text"} )	
	AADD(aProc,{"oProc","_xMotivo"						, "SZKMASTER", "ZK_MOTIVO"	, "oProc:_xMotivo:Text"} )	

	//Dados da Carga
	AADD(aInfCarga,{"oInfCarga","_vCarga"				, "SZKMASTER", "ZK_VLCARGA"	, "Val(oInfCarga:_vCarga:Text)"} )
	AADD(aInfCarga,{"oInfCarga","_proPred"				, "SZKMASTER", "ZK_PRODPRE"	, "oInfCarga:_proPred:Text"} )

	//Dados dos Impostos
	AADD(aImpICMS,{"oImpICMS:_ICMS00","_CST"			, "SZKMASTER", "ZK_CST"		, "oImpICMS:_ICMS00:_CST:Text"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS00","_VICMS"			, "SZKMASTER", "ZK_VLIMP"	, "Val(oImpICMS:_ICMS00:_VICMS:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS00","_VBC"			, "SZKMASTER", "ZK_BASIMP"	, "Val(oImpICMS:_ICMS00:_VBC:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS00","_PICMS"			, "SZKMASTER", "ZK_PCIMP"	, "Val(oImpICMS:_ICMS00:_PICMS:Text)"} )

	AADD(aImpICMS,{"oImpICMS:_ICMS20","_CST"			, "SZKMASTER", "ZK_CST"		, "oImpICMS:_ICMS20:_CST:Text"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS20","_VICMS"			, "SZKMASTER", "ZK_VLIMP"	, "Val(oImpICMS:_ICMS20:_VICMS:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS20","_VBC"			, "SZKMASTER", "ZK_BASIMP"	, "Val(oImpICMS:_ICMS20:_VBC:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS20","_PICMS"			, "SZKMASTER", "ZK_PCIMP"	, "Val(oImpICMS:_ICMS20:_PICMS:Text)"} )

	AADD(aImpICMS,{"oImpICMS:_ICMS45","_CST"			, "SZKMASTER", "ZK_CST"		, "oImpICMS:_ICMS45:_CST:Text"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS45","_VICMS"			, "SZKMASTER", "ZK_VLIMP"	, "0"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS45","_VBC"			, "SZKMASTER", "ZK_BASIMP"	, "0"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS45","_PICMS"			, "SZKMASTER", "ZK_PCIMP"	, "0"} )
	
	AADD(aImpICMS,{"oImpICMS:_ICMS60","_CST"			, "SZKMASTER", "ZK_CST"		, "oImpICMS:_ICMS60:_CST:Text"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS60","_VICMSSTRET"		, "SZKMASTER", "ZK_VLIMP"	, "Val(oImpICMS:_ICMS60:_VICMSSTRET:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS60","_VBCSTRET"		, "SZKMASTER", "ZK_BASIMP"	, "Val(oImpICMS:_ICMS60:_VBCSTRET:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS60","_PICMSSTRET"		, "SZKMASTER", "ZK_PCIMP"	, "Val(oImpICMS:_ICMS60:_PICMSSTRET:Text)"} )
	
	AADD(aImpICMS,{"oImpICMS:_ICMS90","_CST"			, "SZKMASTER", "ZK_CST"		, "oImpICMS:_ICMS90:_CST:Text"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS90","_VICMS"			, "SZKMASTER", "ZK_VLIMP"	, "Val(oImpICMS:_ICMS90:_VICMS:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS90","_VBC"			, "SZKMASTER", "ZK_BASIMP"	, "Val(oImpICMS:_ICMS90:_VBC:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMS90","_PICMS"			, "SZKMASTER", "ZK_PCIMP"	, "Val(oImpICMS:_ICMS90:_PICMS:Text)"} )

	AADD(aImpICMS,{"oImpICMS:_ICMSOutraUF","_CST"			, "SZKMASTER", "ZK_CST"		, "oImpICMS:_ICMSOutraUF:_CST:Text"} )
	AADD(aImpICMS,{"oImpICMS:_ICMSOutraUF","_vICMSOutraUF"	, "SZKMASTER", "ZK_VLIMP"	, "Val(oImpICMS:_ICMSOutraUF:_vICMSOutraUF:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMSOutraUF","_vBCOutraUF"	, "SZKMASTER", "ZK_BASIMP"	, "Val(oImpICMS:_ICMSOutraUF:_vBCOutraUF:Text)"} )
	AADD(aImpICMS,{"oImpICMS:_ICMSOutraUF","_pICMSOutraUF"	, "SZKMASTER", "ZK_PCIMP"	, "Val(oImpICMS:_ICMSOutraUF:_pICMSOutraUF:Text)"} )

	AADD(aDados,aIDE)
	AADD(aDados,aVpre)
	AADD(aDados,aEmit)
	AADD(aDados,aReme)
	AADD(aDados,aDest)
	AADD(aDados,aRece)
	AADD(aDados,aExpe)
	AADD(aDados,aProc)
	AADD(aDados,aInfCarga)
	AADD(aDados,aImpICMS)

Return

/*/{Protheus.doc} EvnStr
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 24/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function EvnStr()

	Local aCancEv := {}

	AADD(aCancEv,{"oInfEnv","_ID"						, "SZMMASTER", "ZM_ID"		, "oInfEnv:_ID:Text"} )
	AADD(aCancEv,{"oInfEnv","_cOrgao"					, "SZMMASTER", "ZM_ORGAO"	, "oInfEnv:_cOrgao:Text"} )
	AADD(aCancEv,{"oInfEnv","_chCte"					, "SZMMASTER", "ZM_CHVCTE"	, "oInfEnv:_chCte:Text"} )
	AADD(aCancEv,{"oInfEnv","_tpAmb"					, "SZMMASTER", "ZM_TPAMB"	, "oInfEnv:_tpAmb:Text"} )
	AADD(aCancEv,{"oInfEnv","_CNPJ"						, "SZMMASTER", "ZM_CGC"		, "oInfEnv:_CNPJ:Text"} )
	AADD(aCancEv,{"oInfEnv","_dhEvento"					, "SZMMASTER", "ZM_DTEVENT"	, "STOD(StrTran(SUBSTR(oInfEnv:_dhEvento:text,1,10),'-',''))"} )
	AADD(aCancEv,{"oInfEnv","_dhEvento"					, "SZMMASTER", "ZM_HREVENT"	, "SUBSTR(oInfEnv:_dhEvento:text,12,8)"} )
	AADD(aCancEv,{"oInfEnv","_tpEvento"					, "SZMMASTER", "ZM_TPEVENT"	, "oInfEnv:_tpEvento:Text"} )
	AADD(aCancEv,{"oInfEnv","_nSeqEvento"				, "SZMMASTER", "ZM_SEQEVEN"	, "oInfEnv:_nSeqEvento:Text"} )

	AADD(aCancEv,{"oDetEvn:_evCancCTe","_descEvento"	, "SZMMASTER", "ZM_DESCEVE"	, "oDetEvn:_evCancCTe:_descEvento:Text"} )
	AADD(aCancEv,{"oDetEvn:_evCancCTe","_nProt"			, "SZMMASTER", "ZM_PROTENV"	, "oDetEvn:_evCancCTe:_nProt:Text"} )
	AADD(aCancEv,{"oDetEvn:_evCancCTe","_xJust"			, "SZMMASTER", "ZM_MOTIVO"	, "oDetEvn:_evCancCTe:_xJust:Text"} )

	AADD(aCancEv,{"oRetEnv","_cStat"					, "SZMMASTER", "ZM_STATUS"	, "oRetEnv:_cStat:Text"} )
	AADD(aCancEv,{"oRetEnv","_xMotivo"					, "SZMMASTER", "ZM_DESCSTA"	, "oRetEnv:_xMotivo:Text"} )
	AADD(aCancEv,{"oRetEnv","_nProt"					, "SZMMASTER", "ZM_PROCRET"	, "oRetEnv:_nProt:Text"} )

	AADD(aEvento,aCancEv)
Return


/*/{Protheus.doc} MDFeStr
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MDFeStr()

	Local aIDE := {}
	Local aEmit:= {}
	Local aProt:= {}
	Local aVeic:= {}
	Local aProp:= {}

	AADD(aIDE,{"oIDEMDFE","_cUF"						, "SZNMASTER", "ZN_UFEMITE"		, "oIDEMDFE:_cUF:Text"} )
	AADD(aIDE,{"oIDEMDFE","_tpAmb"						, "SZNMASTER", "ZN_TPAMB"		, "oIDEMDFE:_tpAmb:Text"} )
	AADD(aIDE,{"oIDEMDFE","_tpEmit"						, "SZNMASTER", "ZN_TPEMITE"		, "oIDEMDFE:_tpEmit:Text"} )
	AADD(aIDE,{"oIDEMDFE","_tpTransp"					, "SZNMASTER", "ZN_TPTRANP"		, "oIDEMDFE:_tpTransp:Text"} )
	AADD(aIDE,{"oIDEMDFE","_nMDF"						, "SZNMASTER", "ZN_MDFE"		, "PadL(oIDEMDFE:_nMDF:Text, TamSx3('ZN_MDFE')[1], '0' )"})
	AADD(aIDE,{"oIDEMDFE","_serie"						, "SZNMASTER", "ZN_SERIE"		, "oIDEMDFE:_serie:Text"} )
	AADD(aIDE,{"oIDEMDFE","_cDV"						, "SZNMASTER", "ZN_DV"			, "oIDEMDFE:_cDV:Text"} )
	AADD(aIDE,{"oIDEMDFE","_modal"						, "SZNMASTER", "ZN_MODAL"		, "oIDEMDFE:_modal:Text"} )
	AADD(aIDE,{"oIDEMDFE","_dhEmi"						, "SZNMASTER", "ZN_DTEMISS"		, "STOD(StrTran(SUBSTR(oIDEMDFE:_dhEmi:text,1,10),'-',''))"} )
	AADD(aIDE,{"oIDEMDFE","_dhEmi"						, "SZNMASTER", "ZN_HREMISS"		, "SUBSTR(oIDEMDFE:_dhEmi:text,12,8)"} )
	AADD(aIDE,{"oIDEMDFE","_tpEmis"						, "SZNMASTER", "ZN_TPEMISS"		, "oIDEMDFE:_tpEmis:Text"} )
	AADD(aIDE,{"oIDEMDFE","_UFIni"						, "SZNMASTER", "ZN_UFINI"		, "oIDEMDFE:_UFIni:Text"} )
	AADD(aIDE,{"oIDEMDFE","_UFFim"						, "SZNMASTER", "ZN_UFFIM"		, "oIDEMDFE:_UFFim:Text"} )

	AADD(aEmit,{"oEmitMDFE","_CNPJ"						, "SZNMASTER", "ZN_CGCEMIT"		, "oEmitMDFE:_CNPJ:Text"} )

	AADD(aProt,{"oInfProt","_chMDFe"					, "SZNMASTER", "ZN_CHVMDFE"		, "oInfProt:_chMDFe:Text"} )
	AADD(aProt,{"oInfProt","_dhRecbto"					, "SZNMASTER", "ZN_DTPROTO"		, "STOD(StrTran(SUBSTR(oInfProt:_dhRecbto:text,1,10),'-',''))"} )
	AADD(aProt,{"oInfProt","_dhRecbto"					, "SZNMASTER", "ZN_HRPROTO"		, "SUBSTR(oInfProt:_dhRecbto:text,12,8)"} )
	AADD(aProt,{"oInfProt","_nProt"						, "SZNMASTER", "ZN_PROTOCO"		, "oInfProt:_nProt:Text"} )
	AADD(aProt,{"oInfProt","_cStat"						, "SZNMASTER", "ZN_STATUS"		, "oInfProt:_cStat:Text"} )
	AADD(aProt,{"oInfProt","_xMotivo"					, "SZNMASTER", "ZN_MOTIVO"		, "oInfProt:_xMotivo:Text"} )

	AADD(aVeic,{"oVeicTrac","_cInt"						, "SZNMASTER", "ZN_CODVEIC"		, "oVeicTrac:_cInt:Text"} )
	AADD(aVeic,{"oVeicTrac","_placa"					, "SZNMASTER", "ZN_PLACA"		, "oVeicTrac:_placa:Text"} )
	AADD(aVeic,{"oVeicTrac","_RENAVAM"					, "SZNMASTER", "ZN_RENAVAM"		, "oVeicTrac:_RENAVAM:Text"} )
	AADD(aVeic,{"oVeicTrac","_tara"						, "SZNMASTER", "ZN_TARA"		, "Val(oVeicTrac:_tara:Text)"} )
	AADD(aVeic,{"oVeicTrac","_capKG"					, "SZNMASTER", "ZN_CAPMAX"		, "Val(oVeicTrac:_capKG:Text)"} )

	AADD(aProp,{"oVeicTrac:_prop","_CPF"				, "SZNMASTER", "ZN_CGCPROP"		, "oVeicTrac:_prop:_CPF:Text"} )
	AADD(aProp,{"oVeicTrac:_prop","_CNPJ"				, "SZNMASTER", "ZN_CGCPROP"		, "oVeicTrac:_prop:_CNPJ:Text"} )
	AADD(aProp,{"oVeicTrac:_prop","_RNTRC"				, "SZNMASTER", "ZN_PRNTRC"		, "oVeicTrac:_prop:_RNTRC:Text"} )
	AADD(aProp,{"oVeicTrac:_prop","_xNome"				, "SZNMASTER", "ZN_NOMEPRO"		, "oVeicTrac:_prop:_xNome:Text"} )
	AADD(aProp,{"oVeicTrac:_prop","_IE"					, "SZNMASTER", "ZN_IEPROPR"		, "oVeicTrac:_prop:_IE:Text"} )
	AADD(aProp,{"oVeicTrac:_prop","_UF"					, "SZNMASTER", "ZN_UFPROPR"		, "oVeicTrac:_prop:_UF:Text"} )
	AADD(aProp,{"oVeicTrac:_prop","_tpProp"				, "SZNMASTER", "ZN_TPPROPR"		, "oVeicTrac:_prop:_tpProp:Text"} )

	AADD(aProp,{"oCondutor","_CPF"						, "SZNMASTER", "ZN_CGCMOTO"		, "oCondutor:_CPF:Text"} )
	AADD(aProp,{"oCondutor","_XNOME"					, "SZNMASTER", "ZN_NOMEMOT"		, "oCondutor:_XNOME:Text"} )

	AADD(aMDFE,aIDE)
	AADD(aMDFE,aEmit)
	AADD(aMDFE,aProt)
	AADD(aMDFE,aVeic)
	AADD(aMDFE,aProp)
Return


Static Function MdfeEvSt()

	Local aCancEv := {}

	AADD(aCancEv,{"oInfEnv","_ID"						, "SZPMASTER", "ZP_ID"		, "oInfEnv:_ID:Text"} )
	AADD(aCancEv,{"oInfEnv","_cOrgao"					, "SZPMASTER", "ZP_ORGAO"	, "oInfEnv:_cOrgao:Text"} )
	AADD(aCancEv,{"oInfEnv","_chMDFe"					, "SZPMASTER", "ZP_CHVMDFE"	, "oInfEnv:_chMDFe:Text"} )
	AADD(aCancEv,{"oInfEnv","_tpAmb"					, "SZPMASTER", "ZP_TPAMB"	, "oInfEnv:_tpAmb:Text"} )
	AADD(aCancEv,{"oInfEnv","_CNPJ"						, "SZPMASTER", "ZP_CGC"		, "oInfEnv:_CNPJ:Text"} )
	AADD(aCancEv,{"oInfEnv","_dhEvento"					, "SZPMASTER", "ZP_DTEVENT"	, "STOD(StrTran(SUBSTR(oInfEnv:_dhEvento:text,1,10),'-',''))"} )
	AADD(aCancEv,{"oInfEnv","_dhEvento"					, "SZPMASTER", "ZP_HREVENT"	, "SUBSTR(oInfEnv:_dhEvento:text,12,8)"} )
	AADD(aCancEv,{"oInfEnv","_tpEvento"					, "SZPMASTER", "ZP_TPEVENT"	, "oInfEnv:_tpEvento:Text"} )
	AADD(aCancEv,{"oInfEnv","_nSeqEvento"				, "SZPMASTER", "ZP_SEQEVEN"	, "oInfEnv:_nSeqEvento:Text"} )

	// Cada XML possui apenas um evento
	AADD(aCancEv,{"oDetEvn:_evCancMDFe","_descEvento"	, "SZPMASTER", "ZP_DESCEVE"	, "oDetEvn:_evCancMDFe:_descEvento:Text"} )
	AADD(aCancEv,{"oDetEvn:_evCancMDFe","_nProt"		, "SZPMASTER", "ZP_PROTENV"	, "oDetEvn:_evCancMDFe:_nProt:Text"} )
	AADD(aCancEv,{"oDetEvn:_evCancMDFe","_xJust"		, "SZPMASTER", "ZP_MOTIVO"	, "oDetEvn:_evCancMDFe:_xJust:Text"} )

	AADD(aCancEv,{"oDetEvn:_evEncMDFe","_descEvento"	, "SZPMASTER", "ZP_DESCEVE"	, "oDetEvn:_evEncMDFe:_descEvento:Text"} )
	AADD(aCancEv,{"oDetEvn:_evEncMDFe","_nProt"			, "SZPMASTER", "ZP_PROTENV"	, "oDetEvn:_evEncMDFe:_nProt:Text"} )

	AADD(aCancEv,{"oRetEnv","_cStat"					, "SZPMASTER", "ZP_STATUS"	, "oRetEnv:_cStat:Text"} )
	AADD(aCancEv,{"oRetEnv","_xMotivo"					, "SZPMASTER", "ZP_DESCSTA"	, "oRetEnv:_xMotivo:Text"} )
	AADD(aCancEv,{"oRetEnv","_nProt"					, "SZPMASTER", "ZP_PROCRET"	, "oRetEnv:_nProt:Text"} )


	AADD(aCanMDFE,aCancEv)
Return

Static Function GetPlaca(cObs)

	Local nPosPLC  	:= 1
	Local cStrPLC 	:= "Placa: "
	Local nLenID   	:= Len(cStrPLC)
	Local cPlaca	:= ""

	nPosPLC	:= At( UPPER(cStrPLC), UPPER(cObs),nPosPLC)

	If nPosPLC > 0 	
		cPlaca := Alltrim(SubStr( cObs, nPosPLC + nLenID,TamSX3("DA3_PLACA")[1]))
	Else
		cStrPLC 	:= "PLACA : "
		nPosPLC  	:= 1
		nPosPLC	:= At( UPPER(cStrPLC), UPPER(cObs),nPosPLC)

		If nPosPLC > 0
			cPlaca := Alltrim(SubStr( cObs, nPosPLC + nLenID,TamSX3("DA3_PLACA")[1]))
		End If
	End If

Return cPlaca

Static Function GetCPFMot(cObs)

	Local nPosCPF  	:= 1
	Local cStrCPF 	:= "CPF "
	Local nLenID   	:= Len(cStrCPF)
	Local cCPF	:= ""

	nPosCPF	:= At( cStrCPF, cObs,nPosCPF)

	If nPosCPF > 0 
		cCPF := Alltrim(SubStr( cObs, nPosCPF + nLenID,11))
	End If

Return cCPF