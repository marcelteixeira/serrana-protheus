#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SERGPE06
Cadastro tabela de faixa da comissao
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERGPE06()
	Local aArea   := GetArea()
	Local oBrowse

	//Inst�nciando FWMBrowse 
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZ6")

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERGPE06")

	//Setando a descri��o da rotina
	oBrowse:SetDescription("Tabela Comissao por faixa")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
return


/*/{Protheus.doc} MenuDef
//TODO Descri��o auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
	
	Local aRot := {}
	
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERGPE06"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERGPE06"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERGPE06"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERGPE06"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERGPE06"	,0,5,0,NIL})

Return aRot

/*/{Protheus.doc} ModelDef
//TODO Descri��o auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
	
	Local oModel := Nil
	Local oStSZ6 := FWFormStruct(1, "SZ6") 
	Local oStSZ7 := FWFormStruct(1, "SZ7") 
	
	oModel := MPFormModel():New("MSERGPE06",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

    // Atribuindo formul�rios para o modelo
    oModel:AddFields("SZ6MASTER",/*cOwner*/, oStSZ6)

    // Atribuindo Grid ao modelo
	oModel:AddGrid( "SZ7DETAIL", "SZ6MASTER",oStSZ7,/*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)

    // Criando Relacionamentos
	oModel:SetRelation("SZ7DETAIL", {{"Z7_FILIAL","FwXFilial('SZ7')"}, {"Z7_CODTAB","Z6_CODTAB"} }, SZ7->( IndexKey( 1 ) ) )
	
	//Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({})
    
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Tabela Comissao")
    
Retur oModel


/*/{Protheus.doc} ViewDef
//TODO Descri��o auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel("SERGPE06")		
	Local oStSZ6 := FWFormStruct(2, "SZ6") 
	Local oStSZ7 := FWFormStruct(2, "SZ7")
	Local oView  := Nil

	oStSZ7:RemoveField("Z7_CODTAB")

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()

	//Seta o modelo
    oView:SetModel(oModel)

    //Atribuindo fomul�rios para interface
    oView:AddField("VIEW_SZ6"    , oStSZ6   , "SZ6MASTER")
    oView:AddGrid( "VIEW_SZ7"    , oStSZ7	, "SZ7DETAIL") 

	//Criando os paineis
    oView:CreateHorizontalBox("SUPERIOR",020)
	oView:CreateHorizontalBox("INFERIOR",080)
	
		//For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})

	//O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_SZ6","SUPERIOR")
    oView:SetOwnerView("VIEW_SZ7","INFERIOR")
    
    //Adicionado Descri��es
	oView:EnableTitleView("VIEW_SZ7"    , "Faixa de Valores" )

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)


Return oView