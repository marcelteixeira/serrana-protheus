#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"


//Static Function SchedDef()
//Local aOrd		:= {}
//Local aParam	:= {}
//
//aParam := { "P",;               // Tipo R para relatorio P para processo   
//			"PARAMDEF",;		// Pergunte do relatorio, caso nao use passar ParamDef            
//			" ",;  				// Alias
//			aOrd,;   			// Array de ordens   
//			" "}   				// Título (para Relatório) 
//
//Return aParam


/*/{Protheus.doc} SERSC001
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERSC001()

	Local cAliasDep	
	
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '1001'
	
		cAliasDep	:= GetNextAlias()
		
		BeginSQL Alias cAliasDep
	
			SELECT 
			SA2.A2_COD
			,SA2.A2_LOJA
			,SA2.A2_NOME
			,SRB.RB_MAT
			,SA2.A2_NUMDEP
			,COUNT(*) QTD
			
			FROM %Table:SRB% SRB
			
			JOIN %Table:SRA% SRA ON SRA.RA_FILIAL = %xFilial:SRA%
			AND SRA.RA_MAT = SRB.RB_MAT
			AND SRA.D_E_L_E_T_ =''
			
			JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = RA_YFORN
			AND SA2.A2_LOJA	= '01'
			AND SA2.D_E_L_E_T_ =''
			
			WHERE SRB.D_E_L_E_T_ =''
			AND SRB.RB_TIPIR NOT IN ('4')
			AND SRB.RB_FILIAL = %xFilial:SRB%
			AND (RB_TIPIR = '2'  AND DATEDIFF(YY,CAST(SRB.RB_DTNASC as DATETIME),GETDATE()) <= 21) 
			OR (RB_TIPIR = '3'  AND DATEDIFF(YY,CAST(SRB.RB_DTNASC as DATETIME),GETDATE()) <= 24 OR
			RB_TIPIR = '1')
			
			GROUP BY SA2.A2_COD,SA2.A2_LOJA,SA2.A2_NOME, SRB.RB_MAT,SA2.A2_NUMDEP
			
			HAVING COUNT(*) <> SA2.A2_NUMDEP
	
		EndSQL
		
		SA2->(DbSetOrder(1))
		
		CONOUT("***** ATUALIZACAO DE DEPENTENTES SRA X SA2")
		
		While(cAliasDep)->(!EOF())
			
			If SA2->(DbSeek(xFilial("SA2") + (cAliasDep)->(A2_COD + A2_LOJA)))
			
				CONOUT("Qtd. Dep. " + cvaltochar(SA2->A2_NUMDEP) + " p/ " + cvaltochar((cAliasDep)->QTD) + " "  + SA2->A2_NOME)
			
				Reclock("SA2",.F.)
					SA2->A2_NUMDEP :=  (cAliasDep)->QTD
				MsUnLock()
		
			End IF
		
			(cAliasDep)->(DbSkip())
		EndDo
		
		(cAliasDep)->(DbCloseArea())
	
	RESET ENVIRONMENT

return