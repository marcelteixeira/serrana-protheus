#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} CN120CMP
Inclui novos campos na tela da escolha
do contrato a ser medido
@author Totvs Vitoria - Mauricio Silva
@since 20/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CN120CMP()
	Local ExpA1  := PARAMIXB[1]
	Local ExpA2  := PARAMIXB[2]

	AAdd( ExpA1, GetSx3Cache( "CN9_DESCRI", "X3_TITULO" ) )
	Aadd( ExpA2, { "CN9_DESCRI", GetSx3Cache( "CN9_DESCRI", "X3_TIPO" ), GetSx3Cache( "CN9_DESCRI", "X3_CONTEXT" ),GetSx3Cache( "CN9_DESCRI", "X3_PICTURE" ) } )

	AAdd( ExpA1, GetSx3Cache( "CN9_ESPCTR", "X3_TITULO" ) )
	Aadd( ExpA2, { "CN9_ESPCTR", GetSx3Cache( "CN9_ESPCTR", "X3_TIPO" ), GetSx3Cache( "CN9_ESPCTR", "X3_CONTEXT" ),GetSx3Cache( "CN9_ESPCTR", "X3_PICTURE" ) } )

	//Validações do Usuário

Return {ExpA1,ExpA2}
