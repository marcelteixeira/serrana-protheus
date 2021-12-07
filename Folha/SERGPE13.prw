
/*/{Protheus.doc} SERGPE13

Fonte responsável por deletar verba de DSR de Motoristas Horistas 
de acordo com a necessidade da Serrana.

Chamada realizada nas fórmulas e roteiros de cálculo da Folha de Pagamento

@author    Raphael Bosser
@since     20/09/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/

User Function SERGPE13(cPdRot)

	cVerbaRot 	:= cPdRot
	cRGB_PD     := ""
	nRGB_HORAS	:= ""
		
	Begin Sequence
		If ( AbortProc() )
			Break
		EndIf
		
		If SRA->RA_CATFUNC == "H" .AND. SRA->RA_YDSR == "2"
		
			fDelPd("022",cSemana)
			fDelPd("021",cSemana)
	
	// 		COMENTADO POR FABRICIO VETTLER - 24/04/2020		
	//		FGERAVERBA("021",(150*SRA->RA_SALARIO),150,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)
			
	//		TRECHO INCLUIDO POR FABRICIO VETTLER - 24/04/2020
			cRGB_PD		:= POSICIONE("RGB",1, XFILIAL("RGB") + SRA->RA_MAT,"RGB_PD")
			nRGB_HORAS	:= POSICIONE("RGB",1, XFILIAL("RGB") + SRA->RA_MAT + "021","RGB_HORAS")
			
			If  cRGB_PD = "021"
			
				FGERAVERBA("021",(nRGB_HORAS*SRA->RA_SALARIO),nRGB_HORAS,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)	
			
			Else
			
				FGERAVERBA("021",(150*SRA->RA_SALARIO),150,CSEMANA,SRA->RA_CC,,"G",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)
			
			EndIf	

		EndIf	
		
	End Sequence

Return