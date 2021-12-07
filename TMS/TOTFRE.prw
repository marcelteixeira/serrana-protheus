#include "Protheus.ch"
#include "Topconn.ch"

user function TOTFRE()

	Local cQuery    := "" 
	Local nValorFr	:= 0
	Local cAlias    := GetNextAlias()
	
	BeginSQL Alias cAlias
	
    	SELECT 
    	
    		SUM(F2_VALBRUT) AS F2_VALBRUT
    	
    	FROM %Table:DTA% AS DTA
    	
    	JOIN %Table:SF2% AS SF2
    		ON DTA_DOC 	   = F2_DOC 
    		AND DTA_SERIE  = F2_SERIE 
    		AND DTA_FILORI = F2_FILIAL
    		AND SF2.D_E_L_E_T_=' '
    	WHERE  
    		DTA_FILIAL = %xFilial:DTA%
    		AND DTA.D_E_L_E_T_ = ' ' 
    		AND DTA_VIAGEM = %exp:M->DTQ_VIAGEM%
    		
	  EndSql
 
    nValorFr := (cAlias)->F2_VALBRUT
											       
	(cAlias)->(DbCloseArea())


Return nValorFr