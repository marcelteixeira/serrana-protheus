#include 'protheus.ch'

/*/{Protheus.doc} MultCte
(long_description)
@author    santos.mauricio
@since     16/03/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class MultiCte 

	Data cUrlWS
	Data cCNPJ
	Data cToken
	Data cDataIni
	Data cDataFim
	Data lEventos

	Data lStatus
	Data cMensagem

	Data oWSprotocolos
	Data aXMLReturn

	Data oWDSL 

	Method new() constructor 
	Method ObterProtocolos()
	Method ObterXML()
	Method ConsutaPrtERP()
	Method SaveFileXML()

endclass

/*/{Protheus.doc} new
Metodo construtor
@author    santos.mauricio
@since     16/03/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method new() class MultiCte

	Local oWS  		:= TWsdlManager():NEW()

	::cUrlWS   		:= "https://piracanjuba.multicte.com.br/WebServiceIntegracaoCTe/Transportador/CTe.svc?wsdl"
	::cCNPJ	   		:= SM0->M0_CGC //"05427772000713" //SM0->M0_CGC
	::cToken   		:= SuperGetMv("MV_YTOKEN",.f.,"35b0bec7-2b6b-4b28-8907-2305f6b56cef")//" //SuperGetMv("MV_YTOKEN",.f.,"35b0bec7-2b6b-4b28-8907-2305f6b56cef")
	::cDataIni 		:= CTOD("//")
	::cDataFim 		:= CTOD("//")
	::oWSprotocolos := {}
	::aXMLReturn	:= {}

	::lStatus		:= .F.
	::cMensagem		:= ""
	::lEventos		:= .F.
	oWS:cSSLCACertFile := "\MULTICTE.PEM"
	
	oWS:ParseURL( ::cUrlWS )

	::oWDSL := oWS
	

return oWS

method ObterProtocolos() Class MultiCte

	Local cSchema 	 := ""
	Local cOperation := "ObterProtocolos"
	Local cMeg		 := ""
	Local oXMl		 := Nil
	Local cError	 := ""
	Local cWarning	 := ""
	Local aRetorno	 := {}
	Local i			 := 0
	Local nDias		 := SuperGetMV("MV_QDIAWS",.f.,3)

	// Se for Segunda-Feira, pega o periodo 
	// de sabado ate segunda
	//nDias := IIF(Dow(Date()) == 2 ,2,1)

	cSchema += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
	cSchema += '<soapenv:Header/>'
	cSchema += '<soapenv:Body>'
	cSchema += '   <tem:ObterProtocolos>'
	cSchema += '      <!--Optional:-->'
	cSchema += '      <tem:cnpj>' + ::cCNPJ + '</tem:cnpj>'
	cSchema += '      <!--Optional:-->'
	cSchema += '      <tem:token>' + ::cToken + '</tem:token>'
	cSchema += '      <!--Optional:-->'
	cSchema += '      <tem:dataInicial>' +  DTOC(DATE()- nDias) + '</tem:dataInicial>'//	cSchema += '      <!--Optional:-->'
	cSchema += '      <tem:dataFinal>' + DTOC(DATE()) + '</tem:dataFinal>'
	cSchema += '       <!--Optional:-->'
	cSchema += '      <tem:serie>?</tem:serie>'
	cSchema += '   </tem:ObterProtocolos>'
	cSchema += '</soapenv:Body>'
	cSchema += '</soapenv:Envelope>'

	xRet := ::oWDSL:SetOperation(cOperation)

	// Verifica se conseguiu setar a operação
	if !xRet
		cMeg := "Falha ao setar operacao (" + Alltrim(cOperation) + ")" + Chr(13) + Chr(10) 
		cMeg += "Erro: " + ::oWDSL:cError 

		Help(NIL, NIL, "ObterProtocolos", NIL, cMeg, 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
		Return Nil
	endif

	// Envia a mensagem
	xRet := ::oWDSL:SendSoapMsg(cSchema)

	if xRet == .F.
		conout( "Erro: " + ::oWDSL:cError )
		Return
	endif

	// Pega a mensagem de resposta
	xRet := ::oWDSL:GetSoapResponse()

	// Monta o XML
	oXMl := XmlParser( xRet, "_", @cError, @cWarning )
	XmlC14N( xRet , "" , @cError , @cWarning )

	// Busca o Status da conexao
	::lStatus 		:= IIF(Alltrim(OXML:_S_ENVELOPE:_S_BODY:_OBTERPROTOCOLOSRESPONSE:_OBTERPROTOCOLOSRESULT:_A_STATUS:TEXT) == "true",.t.,.f.)
	::cMensagem		:= Alltrim(OXML:_S_ENVELOPE:_S_BODY:_OBTERPROTOCOLOSRESPONSE:_OBTERPROTOCOLOSRESULT:_A_MENSAGEM:TEXT)

	If ValType(XmlChildEx(OXML:_S_ENVELOPE:_S_BODY:_OBTERPROTOCOLOSRESPONSE:_OBTERPROTOCOLOSRESULT:_A_OBJETO,"_B_INT")) <> "U"
	
		// Busca os protocolos retornados
		If ValType(OXML:_S_ENVELOPE:_S_BODY:_OBTERPROTOCOLOSRESPONSE:_OBTERPROTOCOLOSRESULT:_A_OBJETO:_B_INT) == "O"
			AADD(aRetorno,OXML:_S_ENVELOPE:_S_BODY:_OBTERPROTOCOLOSRESPONSE:_OBTERPROTOCOLOSRESULT:_A_OBJETO:_B_INT)
		Else
			aRetorno := OXML:_S_ENVELOPE:_S_BODY:_OBTERPROTOCOLOSRESPONSE:_OBTERPROTOCOLOSRESULT:_A_OBJETO:_B_INT
		End If
	
	
		// Adiciona na propriedade
		For i:= 1 to len(aRetorno)
			AADD(::oWSprotocolos,aRetorno[i]:text)
		Next
	End if
Return

method ObterXML() Class MultiCte

	Local cSchema 	 := ""
	Local cSchCabe	 := ""
	Local cSchRoda	 := ""
	Local cOperation := "ObterXML"
	Local xRet		 := .F.
	Local cMeg		 := ""
	Local cError	 := ""
	Local cWarning	 := ""
	Local oObjXML	 := Nil
	Local i			 := 0 , w:= 0 , z:= 0, k:= 0
	Local aPrtWS     := {}
	Local aRetorno	 := {}


	cSchCabe += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:tem="http://tempuri.org/">
	cSchCabe += '   <soapenv:Header />
	cSchCabe += '   <soapenv:Body>
	cSchCabe += '      <tem:ObterXML xmlns="http://tempuri.org/">
	cSchCabe += '         <!--Optional:-->
	cSchCabe += '         <tem:cnpj>' + ::cCNPJ + '</tem:cnpj>
	cSchCabe += '         <!--Optional:-->
	cSchCabe += '         <tem:token>' + ::cToken + '</tem:token>
	cSchCabe += '         <!--Optional:-->
	cSchCabe += '         <tem:protocolos>	
	cSchCabe += '            <!--Zero or more repetitions:-->

	For w := 1 to Len(::oWSprotocolos)

		If Len(aPrtWS) == 0 .OR. Len(aPrtWS[Len(aPrtWS)]) >= 100
			AADD(aPrtWS,{::oWSprotocolos[w]})
		Else
			AADD(aPrtWS[Len(aPrtWS)],::oWSprotocolos[w])
		End If
	Next

	cSchRoda += '         </tem:protocolos>
	cSchRoda += '      </tem:ObterXML>
	cSchRoda += '   </soapenv:Body>
	cSchRoda += '</soapenv:Envelope>

	xRet := ::oWDSL:SetOperation(cOperation)

	// Zera os XML da consulta anterior
	::aXMLReturn := {}

	// Verifica se conseguiu setar a operação
	if !xRet
		cMeg := "Falha ao setar operacao (" + Alltrim(cOperation) + ")" + Chr(13) + Chr(10) 
		cMeg += "Erro: " + ::oWDSL:cError 
		Help(NIL, NIL, "ObterXML", NIL, cMeg, 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
		Return Nil
	endif

	For z:= 1 to Len(aPrtWS)

		cSchema := ""
		cSchema += cSchCabe

		For k:= 1 to Len(aPrtWS[z])
			cSchema += '            <arr:int>' + aPrtWS[z][k] + '</arr:int>' 
		Next

		cSchema += cSchRoda

		// Envia a mensagem
		xRet := ::oWDSL:SendSoapMsg(cSchema)

		if xRet == .F.
			conout( "Erro: " + ::oWDSL:cError )
			Return
		endif

		// Pega a mensagem de resposta
		xRet := ::oWDSL:GetSoapResponse()

		// Monta o XML
		oXMl := XmlParser( xRet, "_", @cError, @cWarning )

		// Busca o Status da conexao
		::lStatus 		:= IIF(Alltrim(OXML:_S_ENVELOPE:_S_BODY:_OBTERXMLRESPONSE:_OBTERXMLRESULT:_A_STATUS:TEXT) == "true",.t.,.f.)
		::cMensagem		:= Alltrim(OXML:_S_ENVELOPE:_S_BODY:_OBTERXMLRESPONSE:_OBTERXMLRESULT:_A_MENSAGEM:TEXT)

		If ValType(OXML:_S_ENVELOPE:_S_BODY:_OBTERXMLRESPONSE:_OBTERXMLRESULT:_A_OBJETO:_A_RETORNOCONSULTAXML) == "O"
			AADD(aRetorno,OXML:_S_ENVELOPE:_S_BODY:_OBTERXMLRESPONSE:_OBTERXMLRESULT:_A_OBJETO:_A_RETORNOCONSULTAXML)
		Else
			aRetorno := OXML:_S_ENVELOPE:_S_BODY:_OBTERXMLRESPONSE:_OBTERXMLRESULT:_A_OBJETO:_A_RETORNOCONSULTAXML
		End If

		For i:= 1 to len(aRetorno)
			
			//Apenas importa evento do CTE consultado
			If ::lEventos .and. UPPER(SubStr(aRetorno[i]:_A_TIPOXML:TEXT,1,3)) == "AUT" 
				Loop
			End If

			oObjXML 		   := MultiXML():NEW()
			oObjXML:cChave 	   := aRetorno[i]:_A_CHAVE:TEXT
			oObjXML:cProtocolo := aRetorno[i]:_A_PROTOCOLO:TEXT
			oObjXML:cXML 	   := aRetorno[i]:_A_XML:TEXT
			oObjXML:cTipoXML   := aRetorno[i]:_A_TIPOXML:TEXT

			AADD(::aXMLReturn,oObjXML)
		Next
	Next 
	
	If Len(aPrtWS) > 0 
		// Chama o method para salvar os XML
		::SaveFileXML()
	End if
	
Return 

Method SaveFileXML() Class MultiCte

	Local i 	 	:= 1
	Local cDirIn 	:= "\MultiCte\IN" //Alltrim( GetNewPar("MV_NGINN"  ,"\NeoGrid\IN") )
	local cBarra 	:= If(isSrvUnix(),"/","\") 
	Local cNome	 	:= ""
	Local lCriaArq 	:= .t. 

	if SubStr( cDirIn, Len(cDirIn) ) <> cBarra
		cDirIn := cDirIn+cBarra
	Else
		cDirIn := cDirIn
	endif

	// Verifica se existe a pasta de XML 
	If !ExistDir( cDirIn ) 
		If MakeDir( cDirIn ) >  0 
			Help(NIL, NIL, "XMLIMPORT", NIL, "Não foi possivel criar o diretorio :" + cDirIn  ,1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor verificar"})	
			Return
		End If
	End if

	For i:= 1 to len (::aXMLReturn)

		lCriaArq := .T.

		// Verifica se este protocolo ja foi importado
		// para nao precisar criar o arquivo XML novamente
		If UPPER(SubStr(::aXMLReturn[i]:cTipoXML,1,3)) == "AUT"

			SZK->(DbSetOrder(4))
			// ZK_FILIAL+ZK_PRTCWS
			// Verifica se achou Cte com este protocolo
			If SZK->(DbSeek(xFilial("SZK") + Alltrim(::aXMLReturn[i]:cProtocolo)))
				lCriaArq := .f.
			End If

		Else

			SZM->(DbSetOrder(3))
			//ZN_FILIAL+ZN_PRTCWS
			// Verifica se achou Cancelamento com este protocolo
			If SZM->(DbSeek(xFilial("SZM") + Alltrim(::aXMLReturn[i]:cProtocolo)))
				lCriaArq := .f.
			End If	

		End if

		IF lCriaArq
			// 421432_AUT_321322443546531253423125342.xml 
			cNome := ::aXMLReturn[i]:cProtocolo + "_" + UPPER(SubStr(::aXMLReturn[i]:cTipoXML,1,3)) + "_" + ::aXMLReturn[i]:cCHave + ".xml"
			MemoWrite( cDirIn + cNome , ::aXMLReturn[i]:cXML )
		End if

	Next

Return

Method ConsutaPrtERP() Class MultiCte

	Local nQtdDias	:= SuperGetMV("MV_YCTEQTD",.F.,8)
	Local cAliasSZK	:= GetNextAlias()
	
	//Busca os conhecimentos de fretes que ainda nao possui
	//evento de cancelamento importado ate 7 dias da emissao.
	
	BeginSQL Alias cAliasSZK

		SELECT SZK.ZK_PRTCWS FROM %Table:SZK% SZK

		LEFT JOIN %Table:SZM% SZM ON SZM.ZM_FILIAL = %Exp:xFilial("SZM")%
		AND SZM.ZM_CHVCTE = SZK.ZK_CHAVE
		AND SZM.D_E_L_E_T_ =''

		WHERE SZK.D_E_L_E_T_ =''
		AND SZK.ZK_FILIAL = %Exp:xFilial("SZK")%
		AND DATEDIFF(DD,CAST(SZK.ZK_DTEMISS as DATETIME),GETDATE()) <= %Exp:nQtdDias%
		AND SZK.ZK_PRTCWS <> ''
		AND SZM.ZM_CHVCTE IS NULL

	EndSQL

	// Limpa todos os protocolos que estiveram informados na classe.
	::oWSprotocolos := {}

	While (cAliasSZK)->(!EOF())

		// Adiciona os protocolos da base para consultas
		AADD(::oWSprotocolos,(cAliasSZK)->ZK_PRTCWS)

		(cAliasSZK)->(DbSkip())
	EndDo

	// Verifica se retornou protocolos
	If Len(::oWSprotocolos) == 0
		Return 
	End If
	
	// Informa que o method ObterXML vai trabalhar
	// somente para pegar os eventos do Cte para ser 
	// importados ao ERP.
	::lEventos := .t.

	// Chama o method de obter os XML dos protocolos informados
	::ObterXML()
	
	// Volta para buscar todos os XML
	::lEventos := .f.

	(cAliasSZK)->(DbCloseArea())

Return


Class MultiXML

	Data cCHave
	Data cProtocolo
	Data cXML
	Data cTipoXML
	method new() constructor 
EndClass

Method New(cCHave,cProtocolo,cXML,cTipoXML) Class MultiXML

	Default cCHave := ""
	Default cProtocolo := 0
	Default cXML := ""
	Default cTipoXML := ""

	::cChave 	 := cCHave
	::cProtocolo := cProtocolo
	::cXML		 := cXML
	::cTipoXML	 := cTipoXML

Return


User Function MultiCte()

	Local oWSMult 	:= Nil
	
	oWSMult := MultiCte():New()
	
	// Trata os Cte da Base (eventos)
	oWSMult:ConsutaPrtERP()
	// Obtem novos Ctes
	oWSMult:ObterProtocolos()
	// Obtem os XML dos protocolos
	oWSMult:ObterXML()

Return
