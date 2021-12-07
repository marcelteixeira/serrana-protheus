#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} SERGPE11
Rotina de Cadastro e Controle de Validade de Documentos
@author Leandro Maffioletti
@since 17/09/2019
/*/
User Function SERGPE11()

	Local aArea     := GetArea()
	Private cTitulo	:= "Tipos de Documento"
	Private oBrowse	:= Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZB")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault("ZB_FILIAL = '"+xFilial("SZB")+"'")		// Filtro para a Filial selecionada
	oBrowse:SetMenuDef("SERGPE11")	//SetFunName("SERGPE11")
	
	//Desliga a exibição dos detalhes
	oBrowse:DisableDetails()
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Função MVC para controle do Menu
@author Leandro Maffioletti
@since 13/09/2019
/*/

Static Function MenuDef()

	//Local aRotina := FWMVCMenu('SERGPE11')  // Retorna as opções padrões de menu.
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.SERGPE11"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.SERGPE11"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.SERGPE11"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.SERGPE11"	OPERATION 5 ACCESS 0
	
Return aRotina


/*/{Protheus.doc} ModelDef
Função MVC para controle do Model
@author Leandro Maffioletti
@since 17/09/2019
/*/
Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'SZB', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma função MVC001V que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New('MVCSERGPE11', /*bPreValidacao*/, /*{ | oModel | MVC001V( oModel ) }*/ , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription(cTitulo)

	//Podemos usar as funções INCLUI ou ALTERA
	oStr1:SetProperty('ZB_TPDOC'	, MODEL_FIELD_WHEN,{|| INCLUI })
    
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('SZBMASTER',,oStr1,/*{|oModel|MVC001T(oModel)}*/,,)
	
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({"ZB_FILIAL","ZB_TPDOC"})
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('SZBMASTER'):SetDescription('Tipos de Documento')
	
Return oModel



/*/{Protheus.doc} ViewDef
Função MVC para controle do View
@author Leandro Maffioletti
@since 17/09/2019
/*/
Static Function ViewDef()
	Local oView
	Local oModel	:= ModelDef()
	Local oStr1		:= FWFormStruct(2, 'SZB')
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)
	

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_SZB' , oStr1,'SZBMASTER' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_SZB','PAI')
	oView:EnableTitleView('VIEW_SZB' , 'Tipos de Documento' )	
	oView:SetViewProperty('VIEW_SZB' , 'SETCOLUMNSEPARATOR', {10})
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
Return oView
