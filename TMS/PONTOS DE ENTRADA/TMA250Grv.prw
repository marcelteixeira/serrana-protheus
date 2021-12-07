#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TMA250Grv
Guarda o total dos ctes envolvidos no contrato
@author mauricio.santos
@since 08/08/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function TMA250Grv()

	Local cAliasDTY  := GetNextAlias()
	
	BeginSQL Alias cAliasDTY
	
		SELECT SUM(DT6.DT6_VALTOT) DT6_VALTOT FROM %Table:DTA% DTA
	
		JOIN %Table:DT6% DT6 ON DT6.DT6_FILIAL = %Exp:xFilial("DT6")%
		AND DT6.DT6_FILORI = DTA.DTA_FILORI
		AND DT6.DT6_DOC = DTA.DTA_DOC
		AND DT6.DT6_SERIE = DTA.DTA_SERIE
		AND DT6.D_E_L_E_T_ =''
		
		WHERE DTA.DTA_FILORI = %Exp:DTY->DTY_FILORI%
		AND DTA.DTA_FILIAL = %Exp:xFilial("DTA")%
		AND DTA.DTA_VIAGEM = %Exp:DTY->DTY_VIAGEM%
		AND DTA.D_E_L_E_T_ =''
		
	EndSQL
	
	Reclock("DTY",.f.)
		DTY->DTY_YFRETE := (cAliasDTY)->DT6_VALTOT
	DTY->(MsUnLock())
	
	(cAliasDTY)->(DbCloseArea())
return
