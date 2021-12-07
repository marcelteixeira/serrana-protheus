#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} TMAGRVPED
Informa o codigo do vendedor(supervisor) para receber
comissao dos conhecimentos de Fretes
@author mauricio.santos
@since 10/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function TMAGRVPED()
	
	Local cVendPad	:= SuperGetMV("MV_YVENSU",.f.,"000002")	
	
	SA3->(DbSetOrder(1))
	If SA3->(DbSeek(xFilial("SA3") + cVendPad))
		SC5->C5_VEND1  := SA3->A3_COD
		SC5->C5_COMIS1 := SA3->A3_COMIS
	End IF
	
return