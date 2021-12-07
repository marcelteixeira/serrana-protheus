#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} CN120ESY
Altera a query para adicionar mais campos 
para o ponto de entrada CN120CMP
@author Totvs Vitoria - Mauricio Silva
@since 20/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function CN120ESY()
	Local cQuery  := PARAMIXB[1]

	Local nPos	:= 1
	Local cProc := "CN9_NUMERO,"
	Local cSub := "CN9_NUMERO, CN9_DESCRI,CN9_ESPCTR, "

	cQuery := StrTran( cQuery, cProc, cSub)

return cQuery