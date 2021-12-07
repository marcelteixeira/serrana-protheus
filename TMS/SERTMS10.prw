#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} SERTMS10
Monitor de integracao com o ERP
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS10()

	Local oView  	  := FWLoadView("SERTMS10")
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
	Local oStSZK   := FWFormStruct(1, "SZK")
	Local oStSZM   := FWFormStruct(1, "SZM")
	Local oStSZN   := FWFormStruct(1, "SZN")
	Local oStSZP   := FWFormStruct(1, "SZP")
	Local aFilSZK  := {}
	Local aFilSZM  := {}
	Local aFilSZN  := {}
	Local aFilSZP  := {}

	// Monta o cabeçalho Fake
	oStCAB	   := FWFormModelStruct():New()
	oStCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)


	oStSZK:AddField("Status" ,;										// [01] Titulo do campo 		"Descrição"
	"Status",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZK_STATIMP",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "FRTOFFLINE"},;	                                        // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	)

	oStSZM:AddField("Status" ,;										// [01] Titulo do campo 		"Descrição"
	"Status",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZM_STATIMP",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "FRTOFFLINE"},;	                                        // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	)

	oStSZN:AddField("Status" ,;										// [01] Titulo do campo 		"Descrição"
	"Status",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZN_STATIMP",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "FRTOFFLINE"},;	                                        // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	)

	oStSZP:AddField("Status" ,;										// [01] Titulo do campo 		"Descrição"
	"Status",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZP_STATIMP",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "FRTOFFLINE"},;	                                        // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	)

	// Tira a permissao de alterar os campos
	oStSZK:SetProperty ( '*' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZM:SetProperty ( '*' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZN:SetProperty ( '*' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZP:SetProperty ( '*' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))

	oModel := MPFormModel():New("MSERTMS10",/*bPre*/,/*bPos*/,{|| .t. }/*bCommit*/,/*bCancel*/) 

	// Cria os componentes
	oModel:AddFields("CABMASTER", /*cOwner*/	,oStCAB ,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
	oModel:AddGrid( "SZKDETAIL" , "CABMASTER"   ,oStSZK ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid( "SZMDETAIL" , "CABMASTER"   ,oStSZM,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid( "SZNDETAIL" , "CABMASTER"   ,oStSZN,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid( "SZPDETAIL" , "CABMASTER"   ,oStSZP,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetRelation("SZKDETAIL" ,{{"ZK_FILIAL" ,"xFilial('SZK')"}},SZK->(IndexKey(1)))
	oModel:SetRelation("SZMDETAIL" ,{{"ZM_FILIAL" ,"xFilial('SZM')"}},SZM->(IndexKey(1)))
	oModel:SetRelation("SZNDETAIL" ,{{"ZN_FILIAL" ,"xFilial('SZN')"}},SZN->(IndexKey(1)))
	oModel:SetRelation("SZPDETAIL" ,{{"ZP_FILIAL" ,"xFilial('SZP')"}},SZP->(IndexKey(1)))

	AADD(aFilSZK,{'ZK_CGCEMI'	, "SM0->M0_CGC" })
	AADD(aFilSZK,{'ZK_DTTMS' 	, "CTOD('//')" })
	oModel:GetModel( "SZKDETAIL" ):SetLoadFilter( aFilSZK )

	AADD(aFilSZM,{'ZM_CGC'		, "SM0->M0_CGC" })
	AADD(aFilSZM,{'ZM_DTTMS' 	, "CTOD('//')" })
	oModel:GetModel( "SZMDETAIL" ):SetLoadFilter( aFilSZM )

	AADD(aFilSZN,{'ZN_CGCEMIT'	, "SM0->M0_CGC" })
	AADD(aFilSZN,{'ZN_DTTMS' 	, "CTOD('//')" })
	oModel:GetModel( "SZNDETAIL" ):SetLoadFilter( aFilSZN )

	AADD(aFilSZP,{'ZP_CGC'		, "SM0->M0_CGC" })
	AADD(aFilSZP,{'ZP_DTTMS' 	, "CTOD('//')" })
	oModel:GetModel( "SZPDETAIL" ):SetLoadFilter( aFilSZP )

	// Permite salvar o GRID sem dados.
	oModel:GetModel( "SZKDETAIL" ):SetOptional( .T. )
	oModel:GetModel( "SZMDETAIL" ):SetOptional( .T. )
	oModel:GetModel( "SZNDETAIL" ):SetOptional( .T. )
	oModel:GetModel( "SZPDETAIL" ):SetOptional( .T. )

	// Muda a estrutura para inserir ou deletar
	oModel:GetModel("SZKDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SZKDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SZMDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SZMDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SZNDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SZNDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SZPDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SZPDETAIL"):SetNoInsertLine(.T.)

	// Informa a descricao dos modelos
	oModel:GetModel("SZKDETAIL"):SetDescription("Conhecimento de Frete")
	oModel:GetModel("SZMDETAIL"):SetDescription("Eventos de Cancelamentos")
	oModel:GetModel("SZNDETAIL"):SetDescription("Manifesto de Transporte")
	oModel:GetModel("SZPDETAIL"):SetDescription("Eventos dos Manifestos")
	oModel:GetModel("CABMASTER"):SetDescription("Cabeçalho")
	oModel:SetDescription("Monitor de Integrações")
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

	Local oModel 	:= FWLoadModel("SERTMS10")
	Local cFildSZK 	:= "ZK_STATIMP,ZK_DOC,ZK_SERIE,ZK_DTEMISS,ZK_HREMISS,ZK_VLPREST,ZK_TOMA3,ZK_CGCREM,ZK_XNOMERE,ZK_CGCDES,ZK_XNOMEDE,ZK_CHAVE"
	Local aFildSZK 	:= StrTokArr(cFildSZK,",")
	Local cFildSZM 	:= "ZM_STATIMP,ZM_PROTENV,ZM_DTEVENT,ZM_HREVENT,ZM_DESCEVE,ZM_MOTIVO,ZM_CHVCTE"
	Local aFildSZM 	:= StrTokArr(cFildSZM,",")
	Local cFildSZN 	:= "ZN_STATIMP,ZN_MDFE,ZN_SERIE,ZN_DTEMISS,ZN_HREMISS,ZN_PLACA,ZN_CGCPROP,ZN_NOMEPRO,ZN_PLARB1,ZN_PLARB2,ZN_PLARB3,ZN_CHVMDFE"
	Local aFildSZN 	:= StrTokArr(cFildSZN,",")
	Local cFildSZP 	:= "ZP_STATIMP,ZP_PROTENV,ZP_DTEVENT,ZP_HREVENT,ZP_DESCEVE,ZP_MOTIVO,ZP_CHVMDFE"
	Local aFildSZP 	:= StrTokArr(cFildSZP,",")

	Local oStSZK 	:= FWFormStruct(2, "SZK",{ |x| ALLTRIM(x) $ cFildSZK })
	Local oStSZM 	:= FWFormStruct(2, "SZM",{ |x| ALLTRIM(x) $ cFildSZM })
	Local oStSZN 	:= FWFormStruct(2, "SZN",{ |x| ALLTRIM(x) $ cFildSZN })
	Local oStSZP 	:= FWFormStruct(2, "SZP",{ |x| ALLTRIM(x) $ cFildSZP })
	Local oView	 	:= Nil
	Local i			:= 0

	Private bBlocF3   := {|| ImpMultCte() }	
	Private bBlocF4   := {|| ImpXML() }	
	Private bBlocF5   := {|| FWMsgRun(, {||Refresh() }   , "Processando", "SERTMS10 - Atualizando as informações...")}
	Private bBlocF6   := {|| U_SERTMS11() }	

	SetKey( VK_F3 , bBlocF3 )
	SetKey( VK_F4 , bBlocF4 )
	SetKey( VK_F5 , bBlocF5 )
	SetKey( VK_F6 , bBlocF6 )

	oStSZK:AddField("ZK_STATIMP",; //Id do Campo 
	"01",; //Ordem
	"Status",;// Título do Campo
	"Status",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture   

	oStSZM:AddField("ZM_STATIMP",; //Id do Campo 
	"01",; //Ordem
	"Status",;// Título do Campo
	"Status",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture 

	oStSZN:AddField("ZN_STATIMP",; //Id do Campo 
	"01",; //Ordem
	"Status",;// Título do Campo
	"Status",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture   

	oStSZP:AddField("ZP_STATIMP",; //Id do Campo 
	"01",; //Ordem
	"Status",;// Título do Campo
	"Status",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture  



	// Refaz a ordem
	For i := 1 To Len(aFildSZK)
		If i < 10
			oStSZK:SetProperty( aFildSZK[i], MVC_VIEW_ORDEM, '0' + Alltrim(STR(i)))
		Else
			oStSZK:SetProperty( aFildSZK[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	// Refaz a ordem
	For i := 1 To Len(aFildSZM)
		If i < 10
			oStSZM:SetProperty( aFildSZM[i], MVC_VIEW_ORDEM, '0' + Alltrim(STR(i)))
		Else
			oStSZM:SetProperty( aFildSZM[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	For i := 1 To Len(aFildSZN)
		If i < 10
			oStSZN:SetProperty( aFildSZN[i], MVC_VIEW_ORDEM, '0' + Alltrim(STR(i)))
		Else
			oStSZN:SetProperty( aFildSZN[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	For i := 1 To Len(aFildSZP)
		If i < 10
			oStSZP:SetProperty( aFildSZP[i], MVC_VIEW_ORDEM, '0' + Alltrim(STR(i)))
		Else
			oStSZP:SetProperty( aFildSZP[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	oStSZK:SetProperty( "ZK_DOC" 		, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_SERIE" 		, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_DTEMISS" 	, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_HREMISS" 	, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_TOMA3" 		, MVC_VIEW_WIDTH, 090 )
	oStSZK:SetProperty( "ZK_VLPREST" 	, MVC_VIEW_WIDTH, 120 )
	oStSZK:SetProperty( "ZK_CGCREM" 	, MVC_VIEW_WIDTH, 120 )
	oStSZK:SetProperty( "ZK_CGCDES" 	, MVC_VIEW_WIDTH, 120 )
	oStSZK:SetProperty( "ZK_XNOMERE" 	, MVC_VIEW_WIDTH, 300 )
	oStSZK:SetProperty( "ZK_XNOMEDE" 	, MVC_VIEW_WIDTH, 300 )
	oStSZK:SetProperty( "ZK_CHAVE" 		, MVC_VIEW_WIDTH, 300 )

	oStSZN:SetProperty( "ZN_NOMEPRO" 	, MVC_VIEW_WIDTH, 200 )

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddGrid("VIEW_SZK"   , oStSZK    , "SZKDETAIL")
	oView:AddGrid("VIEW_SZM"   , oStSZM    , "SZMDETAIL")
	oView:AddGrid("VIEW_SZN"   , oStSZN    , "SZNDETAIL")
	oView:AddGrid("VIEW_SZP"   , oStSZP    , "SZPDETAIL")

	oView:SetCloseOnOk({||.T.})

	oView:SetProgressBar(.T.)

	oView:CreateHorizontalBox("TOTAL",100)
	oView:CreateFolder("FOLDER","TOTAL")  

	oView:AddSheet("FOLDER", "ABA_CTE"  , "Conhecimento Frete")
	oView:AddSheet("FOLDER", "ABA_MDFE" , "Manifesto de Transporte")

	oView:CreateHorizontalBox("BOX_CTE"  , 060 ,,, "FOLDER", 'ABA_CTE')
	oView:CreateHorizontalBox("BOX_ECTE" , 040 ,,, "FOLDER", 'ABA_CTE')

	oView:CreateHorizontalBox("BOX_MDFE"  , 060 ,,, "FOLDER", 'ABA_MDFE')
	oView:CreateHorizontalBox("BOX_EMDFE" , 040 ,,, "FOLDER", 'ABA_MDFE')

	oView:SetOwnerView("VIEW_SZK" ,"BOX_CTE")
	oView:SetOwnerView("VIEW_SZM" ,"BOX_ECTE")
	oView:SetOwnerView("VIEW_SZN" ,"BOX_MDFE")
	oView:SetOwnerView("VIEW_SZP" ,"BOX_EMDFE")

	oView:EnableTitleView("VIEW_SZK" , "Conhecimento Frete" )
	oView:EnableTitleView("VIEW_SZM" , "Eventos de Cancelamentos" )
	oView:EnableTitleView("VIEW_SZN" , "Manifesto de Transporte" )
	oView:EnableTitleView("VIEW_SZP" , "Eventos do Manifesto de Transporte" )

	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty("VIEW_SZK", "GRIDSEEK"  , {.T.})
	oView:SetViewProperty("VIEW_SZK", "GRIDFILTER", {.T.}) 
	oView:SetViewProperty("VIEW_SZK", "GRIDVSCROLL", {.F.}) 
	
	

	oView:AddUserButton("F3 - Importar MultiCTE","FORM",bBlocF3,"",VK_F3,,.t.) 
	oView:AddUserButton("F4 - Importar XML"   	,"FORM",bBlocF4,"",VK_F4,,.t.)  
	oView:AddUserButton("F5 - Refresh Monitor"	,"FORM",bBlocF5,"",VK_F5,,.t.)  
	oView:AddUserButton("F6 - Criar Viagem"	  	,"FORM",bBlocF6,"",VK_F6,,.t.)  

	oView:SetAfterViewActivate( {|oView,oPanel| SetAfter(oView,oPanel)} )
	oView:AddUserButton("Legenda"       ,"",{|| TMS10LEG() }  ,"")
	
	//oView:SetContinuousForm(.t.)

Return oView

Static Function ImpXML()

	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Private oProcess

	oProcess := MsNewProcess():New({|| U_SERSC002(oProcess)}, "Importando XML", "Aguarde...", .f.)
	oProcess:Activate()

	// Volto o Modelo anterior para evitar erro de atualizacao
	
	FWModelActive(oModel,.t.)

	FWMsgRun(, {||Refresh() }   , "Processando", "SERTMS10 - Atualizando as informações...")

Return

Static Function ImpMultCte()

	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Private oProcess

	oProcess := MsNewProcess():New({|| U_SERSC003(oProcess)}, "Conexão MultiCte", "Aguarde...", .f.)
	oProcess:Activate()

	// Volto o Modelo anterior para evitar erro de atualizacao
	
	FWModelActive(oModel,.t.)

	// Importa os XML
	ImpXML()

Return

/*/{Protheus.doc} TMS10LEG
Legenda
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMS10LEG()

	Local aLegenda := {}

	//Monta as legendas (Cor, Legenda)
	aAdd(aLegenda,{"FRTOFFLINE",     "Integração não realizada"})
	aAdd(aLegenda,{"FRTONLINE" ,    "Integração com sucesso"})

	BrwLegenda("Legenda", "", aLegenda)

Return 

/*/{Protheus.doc} SetAfter
Atribuicao do Menu PopUp
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oView, object, description
@param oPanel, object, description
@type function
/*/
Static Function SetAfter(oView,oPanel)

	oView:GetViewObj("SZKDETAIL")[3]:oBrowse:oBrowse:bRClicked := { |oPanel,x,y| MenuSZK(oPanel,x,y) }
	oView:GetViewObj("SZMDETAIL")[3]:oBrowse:oBrowse:bRClicked := { |oPanel,x,y| MenuSZM(oPanel,x,y) }
	oView:GetViewObj("SZNDETAIL")[3]:oBrowse:oBrowse:bRClicked := { |oPanel,x,y| MenuSZN(oPanel,x,y) }
	oView:GetViewObj("SZPDETAIL")[3]:oBrowse:oBrowse:bRClicked := { |oPanel,x,y| MenuSZP(oPanel,x,y) }
	
Return Nil


/*/{Protheus.doc} MenuSZP
Menu PopUp - Eventos do Mdf-e
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@param x, , description
@param y, , description
@type function
/*/
Static Function MenuSZP(oPanel,x,y)

	Local oModel 	:= FwModelActive()
	Local nRecno	:= oModel:GetModel( 'SZPDETAIL' ):GetDataId()

	SZP->(DbSetOrder(1))
	SZP->(DbGoTo(nRecno))

	oMenu := TMenu():New(0,0,0,0,.T.)

	oItemA1 := TMenuItem():New(oMenu,"Dados Evento"			,,,,{|| AlterReg("SERTMS09")},,"TK_ALTFIN",,,,,,,.T.)
	oItemA2 := TMenuItem():New(oMenu,"Log Integr."			,,,,{|| ViewLog("SZP->ZP_LOG") },,"BPMSDOCE",,,,,,,.T.)
	oItemA3 := TMenuItem():New(oMenu,"Ver XML"				,,,,{|| ViewXML("SZP->ZP_XML") },,"PESQUISA",,,,,,,.T.)

	//oMenu:Add(oItemA)
	oMenu:Add(oItemA1)
	oMenu:Add(oItemA2)
	oMenu:Add(oItemA3)

	oItemD := TMenuItem():New(oMenu,"Reprocessar"			,,,,{|| SZPIMPTMS() },,"PMSRRFSH",,,,,,,.T.)
	oMenu:Add(oItemD)

	oPanel:SetPopup(oMenu) 
Return


Static Function MenuSZN(oPanel,x,y)

	Local oModel 	:= FwModelActive()
	Local nRecno	:= oModel:GetModel( 'SZNDETAIL' ):GetDataId()

	SZN->(DbSetOrder(1))
	SZN->(DbGoTo(nRecno))

	oMenu := TMenu():New(0,0,0,0,.T.)

	oItemA1 := TMenuItem():New(oMenu,"Dados Mdf-e"			,,,,{|| AlterReg("SERTMS08")},,"TK_ALTFIN",,,,,,,.T.)
	oItemA2 := TMenuItem():New(oMenu,"Log Integr."			,,,,{|| ViewLog("SZN->ZN_LOG") },,"BPMSDOCE",,,,,,,.T.)
	oItemA3 := TMenuItem():New(oMenu,"Ver XML"				,,,,{|| ViewXML("SZN->ZN_XML") },,"PESQUISA",,,,,,,.T.)

	//oMenu:Add(oItemA)
	oMenu:Add(oItemA1)
	oMenu:Add(oItemA2)
	oMenu:Add(oItemA3)

	oItemD := TMenuItem():New(oMenu,"Reprocessar"			,,,,{|| SZNIMPTMS() },,"PMSRRFSH",,,,,,,.T.)
	oMenu:Add(oItemD)

	oItemB 	:= TMenuItem():New(oMenu,"Rotinas"				,,,,{||  },,"TK_ALTFIN",,,,,,,.T.)
	oItemB1 := TMenuItem():New(oItemB,"Cadastro Veículos"	,,,,{|| OMSA060()},,"CARGA",,,,,,,.T.)
	oItemB2 := TMenuItem():New(oItemB,"Manifesto Carga"		,,,,{|| TMSA190() },,"CARGASEQ",,,,,,,.T.)
	oItemB3 := TMenuItem():New(oItemB,"Cadastro Autônomo"	,,,,{|| GPEA265() },,"VENDEDOR",,,,,,,.T.)
	oItemB4 := TMenuItem():New(oItemB,"Cadastro Motorista"	,,,,{|| OMSA040() },,"BMPUSER",,,,,,,.T.)
	oItemB5 := TMenuItem():New(oItemB,"Cadastro Fornecedor"	,,,,{|| MATA020() },,"CLIENTE",,,,,,,.T.)

	oMenu:Add(oItemB)
	oItemB:Add(oItemB1)
	oItemB:Add(oItemB2)
	oItemB:Add(oItemB3)
	oItemB:Add(oItemB4)
	oItemB:Add(oItemB5)

	oPanel:SetPopup(oMenu) 
Return


/*/{Protheus.doc} MenuSZM
Menu PopUp - Eventos do Ct-e
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@param x, , description
@param y, , description
@type function
/*/
Static Function MenuSZM(oPanel,x,y)

	Local oModel 	:= FwModelActive()
	Local nRecno	:= oModel:GetModel( 'SZMDETAIL' ):GetDataId()

	SZM->(DbSetOrder(1))
	SZM->(DbGoTo(nRecno))

	oMenu := TMenu():New(0,0,0,0,.T.)

	oItemA1 := TMenuItem():New(oMenu,"Dados Evento"			,,,,{|| AlterReg("SERTMS07")},,"TK_ALTFIN",,,,,,,.T.)
	oItemA2 := TMenuItem():New(oMenu,"Log Integr."			,,,,{|| ViewLog("SZM->ZM_LOG") },,"BPMSDOCE",,,,,,,.T.)
	oItemA3 := TMenuItem():New(oMenu,"Ver XML"				,,,,{|| ViewXML("SZM->ZM_XML") },,"PESQUISA",,,,,,,.T.)

	oMenu:Add(oItemA1)
	oMenu:Add(oItemA2)
	oMenu:Add(oItemA3)

	oItemD := TMenuItem():New(oMenu,"Reprocessar"			,,,,{|| SZMIMPTMS() },,"PMSRRFSH",,,,,,,.T.)
	oMenu:Add(oItemD)

	oItemB 	:= TMenuItem():New(oMenu,"Rotinas"				,,,,{||  },,"TK_ALTFIN",,,,,,,.T.)
	oItemB1 := TMenuItem():New(oItemB,"Viagem Entrega"		,,,,{|| TMSA144D() },,"CARGA",,,,,,,.T.)
	oItemB2 := TMenuItem():New(oItemB,"Contrato Carreteiro"	,,,,{|| TMSA250() },,"CARGASEQ",,,,,,,.T.)
	oItemB3 := TMenuItem():New(oItemB,"Contas a Receber"	,,,,{|| FINA740() },,"TPOPAGTO1",,,,,,,.T.)

	oMenu:Add(oItemB)
	oItemB:Add(oItemB1)
	oItemB:Add(oItemB2)
	oItemB:Add(oItemB3)

	oPanel:SetPopup(oMenu) 
Return


/*/{Protheus.doc} MenuSZK
Menu PopUp - Conhecimento de Frete
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@param x, , description
@param y, , description
@type function
/*/
Static Function MenuSZK(oPanel,x,y)

	Local oModel 	:= FwModelActive()
	Local nRecno	:= oModel:GetModel( 'SZKDETAIL' ):GetDataId()

	SZK->(DbSetOrder(1))
	SZK->(DbGoTo(nRecno))
	
	oMenu := TMenu():New(0,0,0,0,.T.)
	
	oItemA1 := TMenuItem():New(oMenu,"Dados Ct-e"		,,,,{|| AlterReg("SERTMS06")},,"TK_ALTFIN",,,,,,,.T.)
	oItemA2 := TMenuItem():New(oMenu,"Log Integr."		,,,,{|| ViewLog("SZK->ZK_LOG") },,"BPMSDOCE",,,,,,,.T.)
	oItemA3 := TMenuItem():New(oMenu,"Ver XML"			,,,,{|| ViewXML("SZK->ZK_XML") },,"PESQUISA",,,,,,,.T.)

	oMenu:Add(oItemA1)
	oMenu:Add(oItemA2)
	oMenu:Add(oItemA3)

	oItemD := TMenuItem():New(oMenu,"Reprocessar"		,,,,{|| SZKIMPTMS() },,"PMSRRFSH",,,,,,,.T.)
	oMenu:Add(oItemD)

	oItemB 	:= TMenuItem():New(oMenu,"Rotinas"			,,,,{||  },,"TK_ALTFIN",,,,,,,.T.)
	oItemB1 := TMenuItem():New(oItemB,"Contrato Cliente",,,,{|| TECA250() },,"PCO_COINC",,,,,,,.T.)
	oItemB2 := TMenuItem():New(oItemB,"Perfil Cliente"	,,,,{|| TMSA480() },,"BMPGROUP",,,,,,,.T.)
	oItemB3 := TMenuItem():New(oItemB,"Doc. Cliente"	,,,,{|| TMSA050() },,"VERNOTA",,,,,,,.T.)
	oItemB4 := TMenuItem():New(oItemB,"Cadastro Veículos",,,,{|| OMSA060()},,"CARGA",,,,,,,.T.)

	oMenu:Add(oItemB)
	oItemB:Add(oItemB1)
	oItemB:Add(oItemB2)
	oItemB:Add(oItemB3)
	oItemB:Add(oItemB4)

	oItemC  := TMenuItem():New(oMenu,"Incluir"			,,,,{||},,"",,,,,,,.T.)
	oItemC1 := TMenuItem():New(oItemC,"Remetente"		,,,,{||SZKIMPSA1("1")},,"BMPUSER",,,,,,,.T.)
	oItemC2 := TMenuItem():New(oItemC,"Destinatario"	,,,,{||SZKIMPSA1("2")},,"BMPUSER",,,,,,,.T.)
	oMenu:Add(oItemC)
	oItemC:Add(oItemC1)
	oItemC:Add(oItemC2)


	oPanel:SetPopup(oMenu)

Return

Static Function Refresh()

	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()

	oModel:DeActivate()
	oModel:Activate()

	oView:Refresh()

Return

/*/{Protheus.doc} SZKIMPSA1
Cadastramento do cliente Remetente/Destinatario
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cTipo, characters, description
@type function
/*/
Static Function SZKIMPSA1(cTipo)

	Local aErro 	:= {}
	Local oView 	:= FwViewActive()
	Local oModel 	:= oView:GetModel()

	SA1->(DbSetOrder(3))

	// Remetente
	If cTipo == "1"
		cCGC := SZK->ZK_CGCREM
	Else
		// Destinatario
		cCGC := SZK->ZK_CGCDES
	End if

	If SA1->(DbSeek(xFilial("SA1") + cCGC))
		AVISO("Cliente", "Cadastro já existente. Cod: " + SA1->A1_COD + "/" + SA1->A1_LOJA)
	Else

		FWMsgRun(, {|| aErro := U_TMS06SA1(cTipo) }	, "Processando", "SERTMS06 - Cadastrando Cliente")
		
		FWModelActive(oModel,.t.)
	End If
Return


/*/{Protheus.doc} SZMIMPTMS
Reprocessamento - Evento de Cancelamento do Cte
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SZMIMPTMS()

	Local aErro		:= {}
	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Local oModelSZM := oModel:GetModel("SZMDETAIL")

	FWMsgRun(, {|| aErro := U_TMS07IMP() }	, "Processando", "SERTMS07 - Gerando movimentações no SIGATMS")

	// Verifica se integrou com sucesso.
	If Len(aErro) > 0 
		oModelSZM:LoadValue("ZM_STATIMP","FRTOFFLINE")
	Else
		oModelSZM:LoadValue("ZM_STATIMP","FRTONLINE")
	End If
	
	
	FWModelActive(oModel,.t.)
	oView:GetViewObj("SZMDETAIL")[3]:Refresh(.t.,.F.)
Return


/*/{Protheus.doc} SZKIMPTMS
Reprocessamento - Conhecimento de Frete
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SZKIMPTMS()

	Local aErro		:= {}
	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Local oModelSZK := oModel:GetModel("SZKDETAIL")
	Local cbkpFunn  := Funname()
	
	SetFunName("SERTMS10")
	FWMsgRun(, {|| aErro := U_TMS06IMP() }	, "Processando", "SERTMS06 - Gerando movimentações no SIGATMS")
	SetFunName(cbkpFunn)
	
	// Verifica se integrou com sucesso.
	If Len(aErro) > 0 
		oModelSZK:LoadValue("ZK_STATIMP","FRTOFFLINE")
	Else
		oModelSZK:LoadValue("ZK_STATIMP","FRTONLINE")
	End If
	
	FWModelActive(oModel,.t.)
	oView:GetViewObj("SZKDETAIL")[3]:Refresh(.t.,.F.)
Return


/*/{Protheus.doc} SZNIMPTMS
Reprocessamento - Manifesto Eletronico
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SZNIMPTMS()

	Local aErro		:= {}
	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Local oModelSZN := oModel:GetModel("SZNDETAIL")

	FWMsgRun(, {|| aErro := U_TMS08IMP() }	, "Processando", "SERTMS08 - Gerando movimentações no SIGATMS")

	// Verifica se integrou com sucesso.
	If Len(aErro) > 0 
		oModelSZN:LoadValue("ZN_STATIMP","FRTOFFLINE")
	Else
		oModelSZN:LoadValue("ZN_STATIMP","FRTONLINE")
	End If
	
	
	FWModelActive(oModel,.t.)
	oView:GetViewObj("SZNDETAIL")[3]:Refresh(.t.,.F.)
Return

/*/{Protheus.doc} SZPIMPTMS
Reprocessamento - Evento de cancelamento do Mdf-e
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SZPIMPTMS()

	Local aErro		:= {}
	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Local oModelSZP := oModel:GetModel("SZPDETAIL")

	FWMsgRun(, {|| aErro := U_TMS09IMP() }	, "Processando", "SERTMS09 - Gerando movimentações no SIGATMS")

	// Verifica se integrou com sucesso.
	If Len(aErro) > 0 
		oModelSZP:LoadValue("ZP_STATIMP","FRTOFFLINE")
	Else
		oModelSZP:LoadValue("ZP_STATIMP","FRTONLINE")
	End If
	
	
	FWModelActive(oModel,.t.)
	oView:GetViewObj("SZPDETAIL")[3]:Refresh(.t.,.F.)
Return


/*/{Protheus.doc} ViewLog
Visualizacao do Erro de Integracao
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cCampo, characters, description
@type function
/*/
Static Function ViewLog(cCampo)
	AVISO("Log Integração", &(cCampo), {}, 3)
Return


Static Function ViewXML(cCampo)

	Local cTempPath := GetTempPath(.T.)
	Local cFile 	:= cTempPath +'teste.xml'

	oDlg := TDialog():New(150,150,700,900,"XML",,,,,,,,,.T.)

	ofileXML := FCREATE(cFile)
	cContent := &(cCampo)

	If ofileXML > 0
		FWrite(ofileXML, cContent)
		FClose(ofileXML)
	EndIf

	oSize := FwDefSize():New(.F., , , oDlg)
	oSize:AddObject("TXMLViewer", 100, 100, .T., .T.)
	oSize:lProp := .T.
	oSize:Process()

	oXml := TXMLViewer():New(05, 05, oDlg , cFile, 370, 250, .T. )

	if oXml:setXML(cFile)
		Alert("Arquivo não encontrado")
	EndIf

	oDlg:Activate()

	FERASE(cFile)

Return

/*/{Protheus.doc} AlterReg
Visualizacao do Registro
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cModelo, characters, description
@type function
/*/
Static Function AlterReg(cModelo)
	Local oModel   := FWModelActive()
	Local oView    := FWLoadView(cModelo)
	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	
	oView:SetModel(oView:GetModel())
	oView:SetOperation(MODEL_OPERATION_UPDATE)  
	oView:SetProgressBar(.t.)

	oExecView := FWViewExec():New()
	oExecView:setTitle("Alteração")
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:OpenView(.F.)

	//FWExecView('Alteração do Registro',cModelo, MODEL_OPERATION_UPDATE, , { || .T. }, ,30,aButtons )
	
	FWModelActive(oModel,.t.)
Return
