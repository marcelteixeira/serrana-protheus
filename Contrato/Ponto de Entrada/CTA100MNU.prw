#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} CTA100MNU
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function CTA100MNU()

	AAdd( aRotina, { 'Prest. Serviço' 	,'u_ContrCop'   ,0,4} )
	AAdd( aRotina, { 'Tipo de Contrato' ,'CNTA020'   	,0,3} )

return

/*/{Protheus.doc} ContrCop
Informa quais sao os fornecedores para o contrato de venda
para inclusao automatica do contrato de compra.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ContrCop()

	FWExecView(,"SERGCT01", MODEL_OPERATION_UPDATE, , { || .T. })
Return