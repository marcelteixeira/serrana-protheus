#include 'protheus.ch'
#include 'parmtype.ch'


Static Function SchedDef()
	Local aOrd		:= {}
	Local aParam	:= {}

	aParam := { "P",;    // Tipo R para relatorio P para processo   
	"PARAMDEF",;		// Pergunte do relatorio, caso nao use passar ParamDef            
	" ",;  				// Alias
	aOrd,;   			// Array de ordens   
	" "}   				// Título (para Relatório) 

Return aParam

user function SERSC003(oProcess)

	Local oWSCTE 	  := Nil
	Local oWSMDFE 	  := Nil
	Local nSubProc	  := 3
	Default oProcess  := Nil

	// Informo que tera 2 procedimentos
	// A - CTE
	// 1 - Tratando Cte ainda nao cancelados
	// 2 - Obtendo Protocolos novos do Cte
	// 3 - Obtencendo XML dos CTE
	
	// B - MDFE
	// 4 - Tratando Mdfe ainda nao cancelados
	// 5 - Obtendo Protocolos novos do Cte
	// 6 - Obtencendo XML dos MDFE
	
	nTotReg := 2 
	
	oProcess:SetRegua1(nTotReg)
	oProcess:IncRegua1("Conhecimentos de Fretes")	
	oProcess:SetRegua2(nSubProc)

	oWSCTE := MultiCte():New()
	// Trata os Cte da Base (eventos)
	oProcess:IncRegua2("Buscando Cancelamentos - " + cValtochar(1) + "/" + cvaltochar((nSubProc)))			
	oWSCTE:ConsutaPrtERP()
	// Obtem novos Ctes
	oProcess:IncRegua2("Obtendo Protocolos - " + cValtochar(2) + "/" + cvaltochar((nSubProc)))	
	oWSCTE:ObterProtocolos()
	// Obtem os XML 
	oProcess:IncRegua2("Baixando XML - " + cValtochar(3) + "/" + cvaltochar((nSubProc)))	
	oWSCTE:ObterXML()

	oProcess:IncRegua1("Manifestos de Transportes")	
	oProcess:SetRegua2(nSubProc)
	oWSMDFE := MultiMDFe():New()
	
	// Trata os MDFE da Base (eventos)
	oProcess:IncRegua2("Buscando Cancelamentos - " + cValtochar(1) + "/" + cvaltochar((nSubProc)))
	oWSMDFE:ConsutaPrtERP()
	// Obtem novos Ctes
	oProcess:IncRegua2("Obtendo Protocolos - " + cValtochar(2) + "/" + cvaltochar((nSubProc)))	
	oWSMDFE:ObterProtocolos()
	// Obtem os XML dos protocolos
	oProcess:IncRegua2("Baixando XML - " + cValtochar(3) + "/" + cvaltochar((nSubProc)))	
	oWSMDFE:ObterXML()

return
