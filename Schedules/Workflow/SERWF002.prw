#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SERWF002
Envio de Workflow de Notificação de Vencimento de Documentos
@author Leandro Maffioletti
@since 17/09/2019
/*/

Static Function SchedDef()
Local aOrd		:= {}
Local aParam	:= {}

aParam := { "P",;               // Tipo R para relatorio P para processo   
			"PARAMDEF",;		// Pergunte do relatorio, caso nao use passar ParamDef            
			" ",;  				// Alias
			aOrd,;   			// Array de ordens   
			" "}   				// Título (para Relatório) 

Return aParam


User Function SERWF002()
Local cDest			:= GetMv("MV_WF002DS",,"leandro.maffioletti@totvs.com.br")
Local cDir			:= Alltrim(GetMV("MV_WFDIR"))
Local cArquivo		:= "WF002.htm"
Local cAssunto		:= ""
Local cUnidade		:= ""
Local cAliasDOC		:= Nil
Local cTextoMsg		:= ""

If Empty(cDest)
	Return
EndIf

//Coloco a barra no final do parametro do diretorio
If Substr(cDir,Len(cDir),1) != "\"
	cDir += "\"
Endif

cAliasDOC	:= GetNextAlias()

BeginSQL Alias cAliasDOC

	SELECT ZA_FILIAL, ZA_ENTIDAD, ZA_CODIGO, ZA_NOME, ZA_TPDOC, ZB_DESC, ZA_DESCRI, ZA_NUMERO, ZA_VENCTO, DATEADD(day, -ZB_DIASANT,ZA_VENCTO) DATALIM
	FROM %Table:SZA% SZA
	JOIN %Table:SZB% SZB ON ZB_FILIAL = %xFilial:SZB% AND ZB_TPDOC = ZA_TPDOC AND SZB.%NotDel%
	WHERE ZA_FILIAL = %xFilial:SZA%  
	AND SZA.%NotDel%
	AND ZA_MSBLQL <> '1'
	AND DATEADD(day,-ZB_DIASANT,ZA_VENCTO) <= %Exp:dDatabase%
	ORDER BY ZA_FILIAL, ZA_ENTIDAD, ZA_CODIGO, ZA_TPDOC
	
EndSQL

If (cAliasDOC)->(EOF())
	(cAliasDOC)->(dbCloseArea())
	Return
EndIf

cAssunto	:= dtoc(MsDate())+" - Notificação de Vencimento de Documentos"
cUnidade	:= Capital(AllTrim(SM0->M0_NOME))+"/"+Capital(AllTrim(SM0->M0_FILIAL))
cUltMov		:= ""
cTextoMsg	:= "" 

//Verifico se existe o arquivo de workflow
If !File(cDir+cArquivo)
	Msgstop(">>> Nao foi encontrado o arquivo modelo de Workflow: "+cDir+cArquivo)
	Return .F.
EndIf

//Inicio do processo
oProcess := TWFProcess():New("WF002","Notificação de Vencimento de Documentos")

oProcess:NewTask("100002",cDir+cArquivo)
oProcess:cSubject	:= cAssunto
oProcess:cTo		:= cDest
oProcess:UserSiga	:= "000000"

oProcess:oHtml:ValByName("cUnidade"		,cUnidade)		//"Empresa"
oProcess:oHtml:ValByName("cDtEnvio"		,DTOC(dDatabase))
//oProcess:oHtml:ValByName("cUltMov"		,cUltMov)
oProcess:oHtml:ValByName("CDADOSADIC"	,cTextoMsg)

While (cAliasDOC)->(!EOF())
	
	aAdd(oProcess:oHtml:ValByName("it1.cEntidade")		,X3Combo("ZA_ENTIDAD", (cAliasDOC)->ZA_ENTIDAD))
	aAdd(oProcess:oHtml:ValByName("it1.cNome")			,'[' + Alltrim((cAliasDOC)->ZA_CODIGO) + '] ' + (cAliasDOC)->ZA_NOME)
	aAdd(oProcess:oHtml:ValByName("it1.cDocumento")		,(cAliasDOC)->ZB_DESC)
	aAdd(oProcess:oHtml:ValByName("it1.cDescri")		,(cAliasDOC)->ZA_NUMERO + "  " + (cAliasDOC)->ZA_DESCRI)
	aAdd(oProcess:oHtml:ValByName("it1.cVencto")		,DTOC(STOD((cAliasDOC)->ZA_VENCTO)))

	(cAliasDOC)->(dbSkip())
	
EndDo

oProcess:Start()		// oProcess:Start("\Workflow\copias")
oProcess:Finish()

If Select(cAliasDOC) > 0
	(cAliasDOC)->(dbCloseArea())
EndIf

Return
