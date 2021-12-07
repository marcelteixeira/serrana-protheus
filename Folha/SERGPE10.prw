#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} SERGPE10
Rotina de Cadastro e Controle de Validade de Documentos
@author Leandro Maffioletti
@since 13/09/2019
/*/
User Function SERGPE10(cFiltro)

	Local aArea     := GetArea()
	Local cExpress  := ""
	Private cTitulo	:= "Controle de Documentos"
	Private oBrowse	:= Nil
	Private aRotina := MenuDef()
	
	Default cFiltro := ""
	
	cExpress := "ZA_FILIAL = '"+xFilial("SZA")+"'"
	
	If !Empty(cFiltro)
		cExpress += " .AND. " + cFiltro
	End If

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZA")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault(cExpress)		// Filtro para a Filial selecionada
	oBrowse:SetMenuDef("SERGPE10")
	
	//Desliga a exibição dos detalhes
	//oBrowse:DisableDetails()
	
	// Adiciona legenda no Browse
	oBrowse:AddLegend('ZA_VENCTO < dDatabase',"RED","Vencimento Expirado")
	oBrowse:AddLegend('ZA_VENCTO >= dDatabase',"GREEN","Vencimento Atualizado")

	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Função MVC para controle do Menu
@author Leandro Maffioletti
@since 13/09/2019
/*/

Static Function MenuDef()

	//Local aRotina := FWMVCMenu('SERGPE10')  // Retorna as opções padrões de menu.
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.SERGPE10"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.SERGPE10"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.SERGPE10"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.SERGPE10"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.SERGPE10"	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.SERGPE10"	OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Tipos Doc."	ACTION "U_SERGPE11()"		OPERATION 2 ACCESS 0

Return aRotina


/*/{Protheus.doc} ModelDef
Função MVC para controle do Model
@author Leandro Maffioletti
@since 13/09/2019
/*/
Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'SZA', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma função MVC001V que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New('MVCSERGPE10', /*bPreValidacao*/, /*{ | oModel | MVC001V( oModel ) }*/ , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription(cTitulo)
	
	//Iniciar o campo ZA_ENTIDAD com o conteudo padrao
	//oStr1:SetProperty('ZA_ENTIDAD' , MODEL_FIELD_INIT,{||'21'} )

	//Bloquear/liberar os campos para edição
	//oStr1:SetProperty('ZA_ENTIDAD' , MODEL_FIELD_WHEN,{|| .F. })

	//Podemos usar as funções INCLUI ou ALTERA
	oStr1:SetProperty('ZA_ENTIDAD'	, MODEL_FIELD_WHEN,{|| INCLUI })
	oStr1:SetProperty('ZA_CODIGO'	, MODEL_FIELD_WHEN,{|| INCLUI })
    
	//Ou usar a propriedade GetOperation que captura a operação que está sendo executada
	//oStr1:SetProperty("ZA_CODIGO"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	
	//oStr1:RemoveField( 'ZA_FILIAL' )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('SZAMASTER',,oStr1,/*{|oModel|MVC001T(oModel)}*/,,)
	
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({"ZA_FILIAL","ZA_ENTIDAD","ZA_CODIGO","ZA_TPDOC" })
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('SZAMASTER'):SetDescription('Documentos')
	
Return oModel



/*/{Protheus.doc} ViewDef
Função MVC para controle do View
@author Leandro Maffioletti
@since 13/09/2019
/*/
Static Function ViewDef()
	Local oView
	Local oModel	:= ModelDef()
	Local oStr1		:= FWFormStruct(2, 'SZA')
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)
	
	oStr1:SetProperty( 'ZA_CODIGO' , MVC_VIEW_LOOKUP    ,{ || GPE10Conpd(oModel)} )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_SZA' , oStr1,'SZAMASTER' )

	//Remove os campos que não irão aparecer	
	//oStr1:RemoveField( 'ZA_FILIAL' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_SZA','PAI')
	oView:EnableTitleView('VIEW_SZA' , 'Documentos' )	
	oView:SetViewProperty('VIEW_SZA' , 'SETCOLUMNSEPARATOR', {10})
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
Return oView


/*/{Protheus.doc} GPE10Conpd
Retorna o tipo de consulta padrão conforme entidade
@author Leandro Maffioletti
@since 16/09/2019
/*/
Static Function GPE10Conpd(oModel)
Local cConpad	:= ''
Local cEntity	:= oModel:GetModel("SZAMASTER"):GetValue("ZA_ENTIDAD")

If !Empty( cEntity )
	Do Case
		Case cEntity == '1'
			cConpad := 'SRA'
		Case cEntity == '2'
			cConpad := 'SA2DOC'
		Case cEntity == '3'
			cConpad := 'DA4'
		Case cEntity == '4'
			cConpad := 'DA3'
	EndCase
EndIf

Return( cConpad )


/*/{Protheus.doc} SERTRG01
Função utilizada como gatilho do campo ZA_CODIGO
@author Leandro Maffioletti
@since 17/09/2019
@version 1.0
/*/
User Function SERTRG01(cEntity,cCodigo)
Local cRet		:= ""
cCodigo			:= AllTrim(cCodigo)

If !Empty( cEntity )
	Do Case
		Case cEntity == '1'
			cRet := Posicione("SRA",1,xFilial("SRA")+cCodigo,"RA_NOME")
		Case cEntity == '2'
			cRet := Posicione("SA2",1,xFilial("SA2")+cCodigo,"A2_NOME")
		Case cEntity == '3'
			cRet := Posicione("DA4",1,xFilial("DA4")+cCodigo,"DA4_NOME")
		Case cEntity == '4'
			cRet := Posicione("DA3",1,xFilial("DA3")+cCodigo,"DA3_DESC")
	EndCase
EndIf

Return cRet
