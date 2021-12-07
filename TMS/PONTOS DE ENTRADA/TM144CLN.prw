 
 /*/{Protheus.doc} TM144CLN
//TODO Ponto de entrada para incluir os campos para apresentar na tela de viagem 
@author Pedro Luiz
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TM144CLN()
	
	 Local aNewCol := {}
	
	 Aadd( aNewCol, {'DTA_YFRETE','Posicione("SF2", 1, DTA->(DTA_FILDOC + DTA_DOC + DTA_SERIE), "F2_VALBRUT")' } ) 
	 
 Return aNewCol 
