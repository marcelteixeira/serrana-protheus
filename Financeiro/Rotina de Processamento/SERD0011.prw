#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:	23/03/2021

DESCR:	Cadastro de Tipagem de Conta - Serrana 
		
AUTOR:	MAYCON ANHOLETI BIANCHINE - TOTVS
*/
User Function SERD0011()

    Private cCadastro 	:= "Cadastro de Tipagem de Conta"
	Private oBrowse 	:= Nil
	Private aRotina 	:= MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZZD")
	oBrowse:SetDescription(cCadastro)

	oBrowse:Activate()

Return Nil


//=======================
//Definições dos menus	=
//=======================
Static Function MenuDef()

	Local aRotina 	:= {}

	aAdd(aRotina,{"Incluir"	    ,"AxInclui"	,0,3})
	aAdd(aRotina,{"Alterar"	    ,"AxAltera"	,0,4})
	aAdd(aRotina,{"Excluir"		,"AxExclui"	,0,5})
	aAdd(aRotina,{"Visualizar"	,"AxVisual"	,0,2})

Return aRotina
