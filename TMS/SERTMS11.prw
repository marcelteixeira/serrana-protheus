#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"


Static cAliasSZK := GetNextAlias()

/*/{Protheus.doc} SERTMS11
Criacao da viagem
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS11()

	Local oView  	  := FWLoadView("SERTMS11")
	Local nBkpModulo  := nModulo

	nModulo := 43

	oView:SetModel(oView:GetModel())
	oView:SetOperation(MODEL_OPERATION_UPDATE)  
	oView:SetProgressBar(.t.)

	oExecView := FWViewExec():New()
	oExecView:setTitle("MultiCte")
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:OpenView(.F.)

	nModulo := nBkpModulo

return


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	Local oStCAB   := Nil
	Local oModel   := Nil
	Local bCarga   := {|| {xFilial("SZK")}}
	Local oStSZK   := Nil
	Local oStDA3   := Nil
	Local bLoadSZK := {|oGridModel, lCopy| LoadSZK(oGridModel, lCopy,oModel)}
	Local bLoadDA3 := {|oGridModel, lCopy| LoadDA3(oGridModel, lCopy,oModel)}
	Local bCommit  := {|oModel| MCommit(oModel)}  
	Local bPos	   := {|oModel| TdOkModel(oModel)}


	// Monta o cabeçalho Fake
	oStCAB	   := FWFormModelStruct():New()
	oStCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)

	AreaTrab()

	// Monta Estrutura baseado na Area de Trabalho da query
	oStSZK := FWFormModelStruct():New()
	oStSZK:AddTable(cAliasSZK,{"",""},"",{|| })
	StrMVC(1,cAliasSZK, oStSZK)

	oStDA3 := FWFormModelStruct():New()
	oStDA3:AddTable(cAliasSZK,{"",""},"",{|| })
	StrMVC(1,cAliasSZK, oStDA3)

	oStSZK:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;															// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZK_MARK",;														// [03] Id do Field
	"L"	,;															// [04] Tipo do campo
	1,;																// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || .F.},;	                                            	 	// [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 															// [14] Virtual

	oStSZK:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;															// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZK_SUM",;														// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "SUMARIO"},;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 															// [14] Virtual

	oStDA3:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"DA3_CARGA",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "CARGA"},;	                                            	// [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 															// [14] Virtual


	oStDA3:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"DA3_CARGA",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "CARGA"},;	                                            	// [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 															// [14] Virtual

	oStDA3:AddField("Cod.1o.Reboq" ,;								// [01] Titulo do campo 
	"Cod.1o.Reboq",;												// [02] ToolTip do campo 	
	"DA3_CODRB1",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	TamSx3("DTR_CODRB1")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_CODRB1")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 

	oStDA3:AddField("Cod.2o.Reboq" ,;								// [01] Titulo do campo 
	"Reboq2",;														// [02] ToolTip do campo 	
	"DA3_CODRB2",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	TamSx3("DTR_CODRB2")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_CODRB2")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 

	oStDA3:AddField("Cod.3o.Reboq" ,;								// [01] Titulo do campo 
	"Cod.3o.Reboq",;												// [02] ToolTip do campo 	
	"DA3_CODRB3",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	TamSx3("DTR_CODRB3")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_CODRB3")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 

	// Permissoes
	oStDA3:SetProperty( '*' 		 , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStDA3:SetProperty( 'DA3_MOTORI' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDA3:SetProperty( 'DA3_CODRB1' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDA3:SetProperty( 'DA3_CODRB2' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDA3:SetProperty( 'DA3_CODRB3' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))

	oStSZK:SetProperty ( '*' 		, MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZK:SetProperty ( 'ZK_MARK'  , MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))

	aAuxGat := FwStruTrigger("DA3_MOTORI","DA3_DESCMO","StaticCall(SERTMS11,GetMotori)",.F.,Nil,Nil,Nil)
	oStDA3:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	oModel := MPFormModel():New("MSERTMS11",/*bPre*/,bPos/*bPos*/,bCommit/*bCommit*/,/*bCancel*/) 

	// Cria os componentes
	oModel:AddFields("CABMASTER", /*cOwner*/	,oStCAB ,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
	oModel:AddGrid( "DA3DETAIL" , "CABMASTER"   ,oStDA3 ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadDA3/*bLoad*/)
	oModel:AddGrid( "SZKDETAIL" , "DA3DETAIL"   ,oStSZK ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadSZK/*bLoad*/)

	// Permite salvar o GRID sem dados.
	oModel:GetModel( "SZKDETAIL" ):SetOptional( .T. )
	oModel:GetModel( "DA3DETAIL" ):SetOptional( .T. )

	// Totalizadores
	oModel:AddCalc("CALC_SZK","DA3DETAIL" ,"SZKDETAIL","ZK_VLPREST","ZK_VLPREST_Q","COUNT" 	, /*bCondition*/,  /*bInitValue*/,"Quantidade"  ,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SZK","DA3DETAIL" ,"SZKDETAIL","ZK_VLPREST","ZK_VLPREST_S","SUM" 	, /*bCondition*/,  /*bInitValue*/,"Total R$"  	,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)

	// Muda a estrutura para inserir ou deletar
	oModel:GetModel("SZKDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SZKDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("DA3DETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("DA3DETAIL"):SetNoInsertLine(.T.)

	// Informa a descricao dos modelos
	oModel:GetModel("SZKDETAIL"):SetDescription("Conhecimento de Frete")
	oModel:GetModel("DA3DETAIL"):SetDescription("Veiculos")
	oModel:GetModel("CABMASTER"):SetDescription("Cabeçalho")
	oModel:SetDescription("Criação da Viagem por Veículos")
	oModel:SetPrimaryKey({""})

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oModel 	:= FWLoadModel("SERTMS11")
	Local oView	 	:= Nil
	Local aFilSZK	:= {}
	Local aFilDA3	:= {}
	Local oCalcSZK  := FWCalcStruct(oModel:GetModel("CALC_SZK"))
	Local bBlocF5   := {|| FWMsgRun(, {||Refresh() }   , "Processando", "SERTMS11 - Atualizando as informações...")}
	

	Local oStSZK  := FWFormViewStruct():New()
	Local oStDA3  := FWFormViewStruct():New()

	AADD(aFilSZK, {"ZK_DOC"})	 ;AADD(aFilSZK,{"ZK_SERIE"})  ;AADD(aFilSZK,{"ZK_DTEMISS"}) ;AADD(aFilSZK,{"ZK_HREMISS"})
	AADD(aFilSZK, {"ZK_XNOMERE"});AADD(aFilSZK,{"ZK_XNOMEDE"});AADD(aFilSZK,{"ZK_VLPREST"});AADD(aFilSZK, {"ZK_CHAVE"}) 

	AADD(aFilDA3, {"DA3_COD"})	 ;AADD(aFilDA3,{"DA3_CODFOR"});AADD(aFilDA3,{"DA3_LOJFOR"}) 
	AADD(aFilDA3, {"DA3_MOTORI"});AADD(aFilDA3,{"DA3_DESCMO"});AADD(aFilDA3,{"DA3_DESCFO"})

	StrMVC(2,cAliasSZK, oStSZK,aFilSZK)
	StrMVC(2,cAliasSZK, oStDA3,aFilDA3)
	
	
	SetKey( VK_F5 , bBlocF5 )
	

	oStSZK:AddField("ZK_MARK",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"")//cPicture	

	oStSZK:AddField("ZK_SUM",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP")//cPicture

	oStDA3:AddField("DA3_CARGA",; //Id do Campo 
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture

	oStDA3:AddField("DA3_CODRB1",; //Id do Campo 
	"97",; //Ordem
	"Reboq1",;// Título do Campo
	"Reboq1",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture		

	oStDA3:AddField("DA3_CODRB2",; //Id do Campo 
	"98",; //Ordem
	"Reboq2",;// Título do Campo
	"Reboq2",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture		

	oStDA3:AddField("DA3_CODRB3",; //Id do Campo 
	"99",; //Ordem
	"Reboq3",;// Título do Campo
	"Reboq3",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture		

	oStSZK:SetProperty( "ZK_DOC" 		, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_SERIE" 		, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_DTEMISS" 	, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_HREMISS" 	, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_VLPREST" 	, MVC_VIEW_WIDTH, 120 )
	oStSZK:SetProperty( "ZK_XNOMERE" 	, MVC_VIEW_WIDTH, 280 )
	oStSZK:SetProperty( "ZK_XNOMEDE" 	, MVC_VIEW_WIDTH, 280 )
	oStSZK:SetProperty( "ZK_CHAVE" 		, MVC_VIEW_WIDTH, 280 )
	oStDA3:SetProperty( "DA3_DESCMO" 	, MVC_VIEW_WIDTH, 280 )
	oStDA3:SetProperty( "DA3_DESCFO" 	, MVC_VIEW_WIDTH, 280 )

	oStDA3:SetProperty( "DA3_CODRB1"	, MVC_VIEW_LOOKUP, "DA3" )
	oStDA3:SetProperty( "DA3_CODRB2"	, MVC_VIEW_LOOKUP, "DA3" )
	oStDA3:SetProperty( "DA3_CODRB3"	, MVC_VIEW_LOOKUP, "DA3" )

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddGrid("VIEW_SZK"   		, oStSZK    , "SZKDETAIL")
	oView:AddGrid("VIEW_DA3"   		, oStDA3    , "DA3DETAIL")
	oView:AddField("VIEW_CALCSZK"  	, oCalcSZK  , "CALC_SZK")

	oView:SetCloseOnOk({||.T.})

	oView:SetProgressBar(.T.)

	oView:CreateHorizontalBox("SUPERIOR",040)
	oView:CreateHorizontalBox("CENTRAL" ,050)
	oView:CreateHorizontalBox("INFERIOR",010)

	oView:SetOwnerView("VIEW_DA3" 		,"SUPERIOR")
	oView:SetOwnerView("VIEW_SZK" 		,"CENTRAL")
	oView:SetOwnerView("VIEW_CALCSZK" 	,"INFERIOR")

	oView:EnableTitleView("VIEW_DA3" , "Veículos" )
	oView:EnableTitleView("VIEW_SZK" , "Conhecimentos de Frete do veículo" )

	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty("*", "GRIDSEEK"  , {.T.})
	oView:SetViewProperty("*", "GRIDFILTER", {.T.}) 

	// configura a pintura do acols
	cCSS := " QTableView "
	cCSS += " { "
	cCSS += "	selection-background-color: #1C9DBD "
	cCSS += " } "

	// configura pintura do aHeader
	cCSS += " QHeaderView::section "
	cCSS += " { "
	cCSS += "	background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #AAAAAA, stop: 0.5 #8E8E8E, stop: 0.6 #8D8D8D, stop:1 #7F7F7F); "
	cCSS += " color: white; "
	cCSS += " border: 1px solid #8E8E8E; "
	cCSS += "	padding-left: 4px; "
	cCSS += " padding-right: 4px; "
	cCSS += " padding-top: 4px; "
	cCSS += " padding-bottom: 4px; "
	cCSS += " } "

	oView:SetViewProperty("*", "SETCSS", { cCSS } )

	oView:SetAfterViewActivate( {|oView,oPanel| SetAfter(oView,oPanel)} )
	oView:AddUserButton("F5 - Refresh","FORM",bBlocF5,"",VK_F5,,.t.)  
	
	
	oView:setUpdateMessage("Geração Viagem", "Realizada com sucesso!!")

Return oView


/*/{Protheus.doc} SetAfter
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oView, object, description
@param oPanel, object, description
@type function
/*/
Static Function SetAfter(oView,oPanel)

	oView:GetViewObj("SZKDETAIL")[3]:oBrowse:oBrowse:bRClicked := { |oPanel,x,y| MenuSZK(oPanel,x,y) }

Return Nil

Static Function Refresh()

	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	
	oModel:DeActivate()
	oModel:Activate()
	
	oView:Refresh()

Return

/*/{Protheus.doc} MenuSZK
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@param x, , description
@param y, , description
@type function
/*/
Static Function MenuSZK(oPanel,x,y)

	Local oModel 	:= FwModelActive()
	Local oModelSZK := oModel:GetModel('SZKDETAIL')
	Local nRecSZK	:= oModelSZK:GetValue("RECSZK")
	Local nRecDT6	:= oModelSZK:GetValue("RECDT6")

	SZK->(DbSetOrder(1))
	SZK->(DbGoTo(nRecSZK))

	DT6->(DbSetOrder(1))
	DT6->(DbGoTo(nRecDT6))

	oMenu := TMenu():New(0,0,0,0,.T.)

	oItemA1 := TMenuItem():New(oMenu,"Dados XML" 	,,,,{|| ViewReg("SERTMS06")}			,,"WATCH",,,,,,,.T.)
	oItemA2 := TMenuItem():New(oMenu,"Marcação"	 	,,,,{|| Marca(oModelSZK)}				,,"SELECTALL",,,,,,,.T.)
	oItemA3 := TMenuItem():New(oMenu,"Desmarcação" 	,,,,{|| Desmarca(oModelSZK)}			,,"UNSELECTALL",,,,,,,.T.)


	oMenu:Add(oItemA1)
	oMenu:Add(oItemA2)
	oMenu:Add(oItemA3)
	oPanel:SetPopup(oMenu)

Return



/*/{Protheus.doc} Marca
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModelSZK, object, description
@type function
/*/
Static Function Marca(oModelSZK)

	Local aSaveLines:= FWSaveRows()
	Local oView		:= FwViewActive()
	Local nTotReg	:= oModelSZK:Length()
	Local i			:= 0

	For i:= 1 to nTotReg
		oModelSZK:GoLine(i)	
		oModelSZK:SetValue("ZK_MARK",.t.)
		If i == nTotReg
			oModelSZK:GoLine(1)	
		End If
	Next

	oView:Refresh("VIEW_SZK")

	FWRestRows( aSaveLines )
Return


/*/{Protheus.doc} Desmarca
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModelSZK, object, description
@type function
/*/
Static Function Desmarca(oModelSZK)

	Local aSaveLines:= FWSaveRows()
	Local oView		:= FwViewActive()
	Local nTotReg	:= oModelSZK:Length()
	Local i			:= 0

	For i:= 1 to nTotReg
		oModelSZK:GoLine(i)	
		oModelSZK:SetValue("ZK_MARK",.F.)

		If i == nTotReg
			oModelSZK:GoLine(1)	
		End If
	Next

	oView:Refresh("VIEW_SZK")
	FWRestRows( aSaveLines )
Return


/*/{Protheus.doc} ViewReg
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cModelo, characters, description
@type function
/*/
Static Function ViewReg(cModelo)

	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	FWExecView('View Registro',cModelo, MODEL_OPERATION_VIEW, , { || .T. }, ,30 ,aButtons )
Return


/*/{Protheus.doc} GetMotori
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GetMotori()

	Local oModel 	:= FwModelActive()
	Local oModelDA3 := oModel:GetModel("DA3DETAIL")
	Local cNome		:= ""

	cNome := Posicione("DA4",1,xFilial("DA4") + oModelDA3:GetValue("DA3_MOTORI"),"DA4_NOME")                                                      

Return cNome


/*/{Protheus.doc} LoadSZK
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadSZK(oGridModel, lCopy,oModel)

	Local aLoad := {}
	Local cCod  := oModel:GetModel("DA3DETAIL"):GetValue("DA3_COD")

	cFilter := "ALLTRIM(DA3_COD) == '" + Alltrim(cCod) + "'"

	(cAliasSZK)->(DBClearFilter())
	(cAliasSZK)->(DBGoTop())

	(cAliasSZK)->(DbSetFilter({|| &cFilter }, cFilter))

	aLoad := FwLoadByAlias( oGridModel,cAliasSZK, NIL , Nil , Nil , .t. ) 

	(cAliasSZK)->(DBClearFilter())

Return aLoad


/*/{Protheus.doc} LoadDA3
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadDA3(oGridModel, lCopy,oModel)

	Local aLoad     := {}
	Local aNewLoad  := {}
	Local i       := 0 
	Local oStr    := oGridModel:GetStruct()
	Local nPosCod := oStr:GetArrayPos({"DA3_COD"})[1]
	Local nPos 	  := 0     

	aLoad := FwLoadByAlias( oGridModel,cAliasSZK, NIL , Nil , Nil , .t. ) 

	For i:= 1 to len(aLoad)

		nPos := ASCAN(aNewLoad, { |x| Alltrim(x[2][nPosCod]) == Alltrim(aLoad[i][2][nPosCod]) }) 

		If nPos == 0
			AADD(aNewLoad,aLoad[i])
		End If 

	Next
Return aNewLoad


/*/{Protheus.doc} AreaTrab
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AreaTrab()

	// Verifica se esta em aberto	
	If select (cAliasSZK) > 0 
		(cAliasSZK)->(DbCloseArea())
	End If

	BeginSQL Alias cAliasSZK

		SELECT 
		SZK.ZK_PLACA
		,SZK.ZK_DOC
		,SZK.ZK_SERIE
		,SZK.ZK_DTEMISS
		,SZK.ZK_HREMISS
		,SZK.ZK_VLPREST
		,SZK.ZK_XNOMERE
		,SZK.ZK_XNOMEDE
		,SZK.ZK_CHAVE 
		,SZK.R_E_C_N_O_ AS RECSZK

		,DT6.R_E_C_N_O_ AS RECDT6

		,DA3.DA3_COD
		,DA3.DA3_CODFOR
		,DA3.DA3_LOJFOR
		,SA2.A2_NOME AS DA3_DESCFO
		,DA3.DA3_MOTORI
		,DA4.DA4_NOME AS DA3_DESCMO

		FROM %Table:SZK% SZK

		JOIN %Table:DA3% DA3 ON DA3.DA3_FILIAL = %Exp:xFilial("DA3")%
		AND DA3.DA3_PLACA = SZK.ZK_PLACA
		AND DA3.D_E_L_E_T_ =''

		JOIN %Table:DT6% DT6 ON DT6.DT6_FILIAL = %Exp:xFilial("DT6")%
		AND DT6.DT6_DOC = SZK.ZK_DOC
		AND DT6.DT6_SERIE = SZK.ZK_SERIE
		AND DT6.DT6_FILORI = %Exp:cFilAnt%
		AND DT6.D_E_L_E_T_ =''		

		LEFT JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial("SA2")%
		AND SA2.A2_COD = DA3.DA3_CODFOR
		AND SA2.A2_LOJA = DA3.DA3_LOJFOR
		AND SA2.D_E_L_E_T_ =''

		LEFT JOIN %Table:DA4%  DA4 ON DA4.DA4_FILIAL = %Exp:xFilial("DA4")%
		AND DA4.DA4_COD = DA3.DA3_MOTORI
		AND DA4.D_E_L_E_T_=''

		LEFT JOIN %Table:DTA% DTA ON DTA.DTA_FILIAL = %Exp:xFilial("DTA")%
		AND DTA.DTA_FILDOC = %Exp:cFilAnt%
		AND DTA.DTA_DOC = SZK.ZK_DOC
		AND DTA.DTA_SERIE = SZK.ZK_SERIE
		AND DTA.D_E_L_E_T_ =''

		LEFT JOIN %Table:SZO% SZO ON SZO.ZO_FILIAL = %Exp:xFilial("SZO")%
		AND SZO.ZO_CHVCTE = SZK.ZK_CHAVE
		AND SZO.D_E_L_E_T_ =''

		WHERE SZK.D_E_L_E_T_ =''
		AND SZK.ZK_FILIAL = %Exp:xFilial("SZK")%
		AND SZK.ZK_DTTMS <> ''
		AND DTA.DTA_DOC IS NULL
		AND SZO.ZO_CHVCTE IS NULL

	EndSQL

	TcSetField(cAliasSZK,'ZK_DTEMISS','D')

Return


/*/{Protheus.doc} TdOkModel
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function TdOkModel(oModel)

	Local lRet 		 := .t. 
	Local i	   		 := 0
	Local oModelDA3  := oModel:GetModel("DA3DETAIL")
	Local oModelSZK  := oModel:GetModel("SZKDETAIL")
	Local nTotReg	 := oModelDA3:Length()
	Local cMsg		 := ""
	Local cSolu		 := ""

	If !MSGYESNO("Deseja prosseguir com a Criação da Viagem?", "Carregamento" )
		cMsg  := "Processo cancelado pelo usuario"
		cSolu := ""
		Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

	For i:= 1 to nTotReg

		oModelDA3:Goline(i)

		// Verifica se existe algum Cte marcado
		If oModelSZK:SeekLine({{"ZK_MARK",.T.}})

			// Verifica o Motorista	
			If Empty(oModelDA3:GetValue("DA3_MOTORI"))

				cMsg  := "O veículo " + oModelDA3:GetValue("DA3_COD") + " se encontra sem motorista informado."
				cSolu := "Favor informar o motorista para criação da viagem."
				Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End If
		End If
	Next

Return lRet


/*/{Protheus.doc} MCommit
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function MCommit(oModel)

	Local lRet := .t.

	oProcess := MsNewProcess():New({|| lRet := Commit(oProcess,oModel)}, "Criando Viagens", "Aguarde...", .T.)
	oProcess:Activate()

Return lRet


/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oProcess, object, description
@param oModel, object, description
@type function
/*/
Static Function Commit(oProcess,oModel)

	Local oModelDA3  := oModel:GetModel("DA3DETAIL")
	Local oModelSZK  := oModel:GetModel("SZKDETAIL")
	Local nTotReg	 := oModelDA3:Length()
	Local i			 := 0
	Local lRet		 := .T.

	oProcess:SetRegua1(nTotReg)

	BEGIN TRANSACTION

		For i:= 1 to nTotReg

			oModelDA3:GoLine(i)

			// Verifica se existe algum Cte marcado
			If oModelSZK:SeekLine({{"ZK_MARK",.T.}})	

				oProcess:IncRegua1("Placa: " + oModelDA3:GetValue("DA3_COD") + " (" + cValToChar(i) + "/" + cValToChar(nTotReg) +")")	

				// Informo que tera 4 processos			
				oProcess:SetRegua2(4)	

				// Cria Viagem
				If lRet
					oProcess:IncRegua2("Criando a Viagem")
					lRet := CriaDTQ(oModel)
				End IF

				// Vincula veiculos da viagem
				If lRet
					oProcess:IncRegua2("Relacionando Veiculo a Viagem")
					lRet := CriaDTR(oModel)
				End if

				// Vincula Motorista da viagem
				If lRet
					oProcess:IncRegua2("Relacionando Motorista a Viagem")
					lRet := CriaDUP(oModel)
				End if

				// Vincula documento do cliente na Viagem
				If lRet
					oProcess:IncRegua2("Relacionando os CTEs emitidos a Viagem")
					lRet := CriaDTA(oModel)
				End if

				If !lRet
					oModel:lModify := .t. 
					DisarmTransaction()		
					Return .f.		
				End If

			End IF
		Next

	END TRANSACTION 	

Return lRet


/*/{Protheus.doc} CriaDTQ
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTQ(oModel)

	Local dData 	:= DATE()
	Local cTime 	:= SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2)
	Local cRota		:= SuperGetMV("MV_YROTXML",.f.,"BRASIL")
	Local lRet		:= .t.
	Local cViagem  	:= NextNumero("DTQ",1,"DTQ_VIAGEM",.T.)

	RecLock("DTQ", .T.)
	DTQ->DTQ_FILIAL := xFilial("DTQ")
	DTQ->DTQ_FILORI := cFilAnt
	DTQ->DTQ_VIAGEM := cViagem
	DTQ->DTQ_TIPVIA := "1"
	DTQ->DTQ_ROTA 	:= cRota
	DTQ->DTQ_DATGER := dData
	DTQ->DTQ_HORGER := cTime
	DTQ->DTQ_SERTMS := "3"
	DTQ->DTQ_TIPTRA := "1"
	DTQ->DTQ_FILATU := cFilAnt
	DTQ->DTQ_FILDES := cFilAnt
	DTQ->DTQ_STATUS := "1"
	DTQ->DTQ_CUSTO1 := 0
	DTQ->DTQ_CUSTO2 := 0
	DTQ->DTQ_CUSTO3 := 0
	DTQ->DTQ_CUSTO4 := 0
	DTQ->DTQ_CUSTO5 := 0
	DTQ->DTQ_QTDPER := 0
	MsUnlock()

Return lRet


/*/{Protheus.doc} CriaDTR
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTR(oModel)

	Local oModelDA3  := oModel:GetModel("DA3DETAIL")
	Local cPlaca	 := oModelDA3:GetValue("DA3_COD")
	Local cRebo1	 := oModelDA3:GetValue("DA3_CODRB1")
	Local cRebo2	 := oModelDA3:GetValue("DA3_CODRB2")
	Local cRebo3	 := oModelDA3:GetValue("DA3_CODRB3")
	Local lRet		 := .t.

	DA3->(DbSetOrder(1))

	// Posiciona no cadastro do veiculo
	DA3->(DbSeek(xFilial("DA3") + cPlaca))

	DTR->( dbSetOrder(3) )

	If !DTR->( dbseek(xFilial("DTR") + cFilAnt + DTQ->DTQ_VIAGEM + DA3->DA3_COD) )

		RecLock("DTR", .T.)

		DTR->DTR_FILIAL	:=	xFilial("DTR")
		DTR->DTR_FILORI	:=	cFilAnt
		DTR->DTR_VIAGEM	:=	DTQ->DTQ_VIAGEM
		DTR->DTR_ITEM	:=	"01"
		DTR->DTR_CODVEI	:=	DA3->DA3_COD
		DTR->DTR_QTDEIX	:=	DA3->DA3_QTDEIX
		DTR->DTR_INSRET	:=	0
		DTR->DTR_VALFRE	:=	0
		DTR->DTR_VALPDG	:=	0
		DTR->DTR_CREADI	:=	DA3->DA3_CODFOR
		DTR->DTR_LOJCRE	:=	DA3->DA3_LOJFOR
		DTR->DTR_NOMCRE	:=	Posicione("SA2", 1, xFilial("SA2")+DTR->DTR_CREADI+DTR->DTR_LOJCRE, "A2_NOME")
		DTR->DTR_ADIFRE	:=	0
		DTR->DTR_FRECAL	:=	"2"
		DTR->DTR_REBTRF	:=	"2"
		DTR->DTR_CODFOR	:=	DA3->DA3_CODFOR
		DTR->DTR_LOJFOR	:=	DA3->DA3_LOJFOR
		DTR->DTR_QTEIXV	:=	DA3->DA3_QTDEIX
		DTR->DTR_VALRB1	:=	0
		DTR->DTR_VALRB2	:=	0
		DTR->DTR_CALRB1	:=	"2"
		DTR->DTR_CALRB2	:=	"2"
		DTR->DTR_CALRB3	:=	"2"
		DTR->DTR_PERADI	:=	0
		DTR->DTR_TIPCRG	:=	"2"
		DTR->DTR_CODRB1	:=	cRebo1
		DTR->DTR_CODRB2	:=	cRebo2
		DTR->DTR_CODRB3	:=	cRebo3

		MsUnlock()

	EndIf

Return lRet


/*/{Protheus.doc} CriaDUP
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDUP(oModel)

	Local oModelDA3  := oModel:GetModel("DA3DETAIL") 
	Local cCodMot	 := oModelDA3:GetValue("DA3_MOTORI")
	Local cPlaca	 := oModelDA3:GetValue("DA3_COD")
	Local lRet		 := .t.

	DUP->( dbSetOrder(2))

	DA3->(DbSetOrder(1))
	// Posiciona no cadastro do veiculo
	DA3->(DbSeek(xFilial("DA3") + cPlaca))

	If !DUP->( dbseek(xFilial("DUP")+cFilAnt+DTQ->DTQ_VIAGEM+cCodMot) )

		RecLock("DUP", .T.)

		DUP->DUP_FILIAL	:=	xFilial("DUP")
		DUP->DUP_FILORI	:=	cFilAnt
		DUP->DUP_VIAGEM	:=	DTQ->DTQ_VIAGEM
		DUP->DUP_ITEDTR	:=	"01"
		DUP->DUP_CODVEI	:=	DA3->DA3_COD
		DUP->DUP_CODMOT	:=	cCodMot
		DUP->DUP_VALSEG	:=	0
		DUP->DUP_CONDUT	:=	"1"
		MsUnlock()

	EndIf

Return lRet


/*/{Protheus.doc} CriaDTA
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTA(oModel)

	Local oModelSZK := oModel:GetModel("SZKDETAIL")
	Local aLinChang := oModelSZK:GetLinesChanged()
	Local z			:= 0
	Local cCte		:= ""
	Local cSerie	:= ""
	Local lAdd		:= .t. 
	Local cZona		:= ""
	Local cSetor	:= ""
	Local cSequen	:= Padl("0",TamSX3("DUD_SEQUEN")[1],"0")
	Local lRet		:= .t.

	For z:= 1 to Len(aLinChang)

		oModelSZK:GoLine(aLinChang[z])

		If oModelSZK:GetValue("ZK_MARK")

			cCte   := oModelSZK:GetValue("ZK_DOC")
			cSerie := oModelSZK:GetValue("ZK_SERIE")
			lAdd   := .T.

			DT6->(DbSetOrder(1))
			//DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			If DT6->(DbSeek(xFilial("DT6") + cFilAnt +  cCte + cSerie))

				// Realiza o carregamento
				DTA->(dbSetOrder(1))
				If DTA->(dbSeek(xFilial("DTA")+DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
					lAdd := .F.
				EndIf

				RecLock("DTA", lAdd)
				DTA->DTA_FILIAL	:=  xFilial("DTA")
				DTA->DTA_FILORI	:=	cFilAnt
				DTA->DTA_VIAGEM	:=	DTQ->DTQ_VIAGEM
				DTA->DTA_FILDOC	:=	DT6->DT6_FILDOC
				DTA->DTA_DOC	:=	DT6->DT6_DOC
				DTA->DTA_SERIE	:=	DT6->DT6_SERIE
				DTA->DTA_QTDVOL	:=	DT6->DT6_QTDVOL
				DTA->DTA_SERTMS	:=	DT6->DT6_SERTMS
				DTA->DTA_TIPTRA	:=	DT6->DT6_TIPTRA
				DTA->DTA_FILATU	:=	cFilAnt
				DTA->DTA_TIPCAR	:=	"2"
				DTA->DTA_FILDCA	:=	cFilAnt
				DTA->DTA_VALFRE	:=	0
				DTA->DTA_CODVEI :=  DA3->DA3_COD

				MsUnlock()

				lAdd := .T. 

				// Cria o Movimento de Viagem
				DUD->( dbSetOrder(1) )
				//DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
				If DUD->( dbSeek(xFilial("DUD")+DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
					lAdd := .F.
				EndIf

				private  cSerTms := DT6->DT6_SERTMS
				TmsA144DA7(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,DTQ->DTQ_ROTA,@cZona,@cSetor,.F.)

				cSequen := SOMA1(cSequen)

				RecLock("DUD", lAdd)
				DUD->DUD_FILIAL	:= xFilial("DUD")
				DUD->DUD_FILORI	:= cFilAnt
				DUD->DUD_FILDOC	:= DT6->DT6_FILDOC
				DUD->DUD_DOC	:= DT6->DT6_DOC
				DUD->DUD_SERIE	:= DT6->DT6_SERIE
				DUD->DUD_SERTMS	:= DT6->DT6_SERTMS
				DUD->DUD_TIPTRA	:= DT6->DT6_TIPTRA
				DUD->DUD_CDRDES	:= DT6->DT6_CDRDES
				DUD->DUD_VIAGEM	:= DTQ->DTQ_VIAGEM
				DUD->DUD_FILDCA	:= cFilAnt
				DUD->DUD_SEQUEN	:= cSequen
				DUD->DUD_GERROM	:= "1"
				DUD->DUD_SERVIC	:= "018"//DT6->DT6_SERVIC //"018"
				DUD->DUD_CDRCAL	:= DT6->DT6_CDRCAL
				DUD->DUD_ENDERE	:= "0"
				DUD->DUD_STROTA	:= "3"
				DUD->DUD_DOCTRF	:= "2"
				DUD->DUD_ZONA	:= cZona
				DUD->DUD_SETOR	:= cSetor
				DUD->DUD_FILATU	:= cFilAnt
				DUD->DUD_CEPENT	:= Posicione("SA1", 1, xFilial("SA1")+DT6->(DT6_CLIDES + DT6_LOJDES), "A1_CEP")
				DUD->DUD_STATUS	:= "3"
				DUD->DUD_SEQENT := "001"
				MsUnlock()

			End if
		End If

	Next

Return lRet


/*/{Protheus.doc} StrMVC
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, description
@param cAlias, characters, description
@param oStr, object, description
@param aCampos, array, description
@type function
/*/
Static Function StrMVC(nTipo,cAlias,oStr,aCampos)

	// Recupera a estrutra da query
	Local aStru := (cAlias)->(dbStruct())
	Local i		:= 0
	Default aCampos := aStru

	// Cria estrutura do modelo de dados e da view
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For i:= 1 to Len(aStru)

		// Verifica os campos para aparecer.
		If Ascan(aCampos,{|x| Alltrim(x[1]) == Alltrim(aStru[i][1]) }) == 0 
			Loop
		End if


		if nTipo == 1 

			If DbSeek(aStru[i][1])

				oStr:AddField(;
				SX3->X3_TITULO,;                                                        // [01]  C   Titulo do campo
				SX3->X3_DESCRIC,;                                                       // [02]  C   ToolTip do campo
				Alltrim(SX3->X3_CAMPO),;                                                // [03]  C   Id do Field
				SX3->X3_TIPO,;                                                          // [04]  C   Tipo do campo
				SX3->X3_TAMANHO,;                                                       // [05]  N   Tamanho do campo
				SX3->X3_DECIMAL,;                                                       // [06]  N   Decimal do campo
				FwBuildFeature( STRUCT_FEATURE_VALID, ".T." ),;                         // [07]  B   Code-block de validação do campo
				FwBuildFeature( STRUCT_FEATURE_WHEN, ".T." ),;                          // [08]  B   Code-block de validação When do campo
				{},;                                                                    // [09]  A   Lista de valores permitido do campo
				.F.,;                                                                   // [10]  L   Indica se o campo tem preenchimento obrigatório
				FwBuildFeature( STRUCT_FEATURE_INIPAD, "" ),;                           // [11]  B   Code-block de inicializacao do campo
				,; 																		// [12] 
				,; 																		// [13] 
				.F.)                                                                    // [14]  L   Indica se o campo é virtual

			Else

				oStr:AddField(aStru[i][1] ,;												// [01] Titulo do campo 		"Descrição"
				aStru[i][1],;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
				aStru[i][1],;															// [03] Id do Field
				aStru[i][2]	,;															// [04] Tipo do campo
				aStru[i][3],;															 // [05] Tamanho do campo
				aStru[i][4],;																		// [06] Decimal do campo
				FwBuildFeature( STRUCT_FEATURE_VALID, ".F." ),;                         // [07]  B   Code-block de validação do campo
				FwBuildFeature( STRUCT_FEATURE_WHEN, ".F." ),;                          // [08]  B   Code-block de validação When do campo
				,;																		// [09] Lista de valores permitido do campo
				.F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
				FwBuildFeature( STRUCT_FEATURE_INIPAD, "" ),;                           // [11]  B   Code-block de inicializacao do campo
				,; 																		// [12] 
				,; 																		// [13] 
				.T.	) 																	// [14] Virtual    
			End If

		Else

			If DbSeek(aStru[i][1])
				oStr:AddField(;
				Alltrim(SX3->X3_CAMPO),;                                                // [01]  C   Nome do Campo
				PADL(cvaltochar(i),2,"0"),;                                             // [02]  C   Ordem
				SX3->X3_TITULO,;                                                        // [03]  C   Titulo do campo
				SX3->X3_DESCRIC,;                                                       // [04]  C   Descricao do campo
				Nil,;                                                                   // [05]  A   Array com Help
				SX3->X3_TIPO,;                                                          // [06]  C   Tipo do campo
				SX3->X3_PICTURE,;                                                       // [07]  C   Picture
				Nil,;                                                                   // [08]  B   Bloco de PictTre Var
				SX3->X3_F3,;                                                            // [09]  C   Consulta F3
				.t.,;                                                        			// [10]  L   Indica se o campo é alteravel
				SX3->X3_FOLDER,;                                                        // [11]  C   Pasta do campo
				SX3->X3_GRPSXG,;                                                        // [12]  C   Agrupamento do campo
				StrTokArr( AllTrim( X3CBox() ),';') ,;                                  // [13]  A   Lista de valores permitido do campo (Combo)
				Nil,;                                                                   // [14]  N   Tamanho maximo da maior opção do combo
				SX3->X3_INIBRW,;                                                        // [15]  C   Inicializador de Browse
				NIL,;                                                        			// [16]  L   Indica se o campo é virtual
				Nil,;                                                                   // [17]  C   Picture Variavel
				Nil)                                                                    // [18]  L   Indica pulo de linha após o campo

			Else

				oStr:AddField(	aStru[i][1],; //Id do Campo
				PADL(cvaltochar(i),2,"0"),; //Ordem
				aStru[i][1],;// Título do Campo
				aStru[i][1],; //Descrição do Campo
				{},; //aHelp
				aStru[i][2],; //Tipo do Campo	
				"")//cPicture
			End If
		End If    
	Next

Return  oStr