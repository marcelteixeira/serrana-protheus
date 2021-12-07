#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} SERTMS05
Rotina para gerar viagens automatica dos xml importados
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS05()

	Local oView  	  := FWLoadView("SERTMS05")
	Local nBkpModulo  := nModulo
	Local nBkpFunname := Funname()

	SetFunname("SERTMS05")

	nModulo := 43

	oView:SetModel(oView:GetModel())
	oView:SetOperation(MODEL_OPERATION_UPDATE)  
	oView:SetProgressBar(.t.)

	oExecView := FWViewExec():New()
	oExecView:setTitle(".")
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:OpenView(.F.)

	nModulo := nBkpModulo

	SetFunname(nBkpFunname)

return


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	Local oModel   := Nil
	Local oStSZE   := FWFormStruct(1, "SZE")
	Local oStLote  := FWFormStruct(1, "SZE",{ |x| ALLTRIM(x) $ "ZE_PLACA,ZE_VALFRET,ZE_QTDVOL,ZE_PESO,ZE_PESLIQ,ZE_VLPEDAG,ZE_VLDESCA"})
	Local oStCAB   := Nil
	Local bCarga   := {|| {xFilial("SZE")}}
	Local bLoadLote:= {|oGridModel, lCopy| LoadLote(oGridModel, lCopy,oModel)}
	Local bCommit  := {|oModel| MCommit(oModel)}  
	Local bPos	   := {|oModel| TdOkModel(oModel)}
	Local lFilCNPJ := SuperGetMV("MV_YFCNPJT",.F.,.T.)
	Local aFilter  := {}

	// Monta o cabeçalho Fake
	oStCAB	   := FWFormModelStruct():New()
	oStCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)

	oStSZE:AddField("SUMARIO" ,;									// [01] Titulo do campo 		"Descrição"
	"SUMARIO",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"SUMARIO",;														// [03] Id do Field
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


	oStSZE:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;															// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZE_MARK",;														// [03] Id do Field
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

	oStSZE:AddField("Vlr Ton." ,;									// [01] Titulo do campo 		"Descrição"
	"Vlr Ton.",;													// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZE_YVLRTON",;													// [03] Id do Field
	"N"	,;															// [04] Tipo do campo
	TamSx3("ZE_PESO")[1],;											// [05] Tamanho do campo
	TamSx3("ZE_PESO")[2],;											// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD,'SZE->(ZE_VALFRET/(ZE_PESO/1000))') ,;	                                            	 	// [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 															// [14] Virtual

	oStLote:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"ZE_CARGA",;													// [03] Id do Field
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
	.T.	) 

	oStLote:AddField("" ,;											// [01] Titulo do campo 
	"",;														    // [02] ToolTip do campo 	
	"ZE_PERSON",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "BMPUSER"},;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 															// [14] Virtual


	oStLote:AddField("Proprietario" ,;								// [01] Titulo do campo 
	"Proprietario",;												// [02] ToolTip do campo 	
	"ZE_DESCFO",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	TamSx3("DA3_DESCFO")[1],;										// [05] Tamanho do campo
	TamSx3("DA3_DESCFO")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 	

	oStLote:AddField("Motorista" ,;									// [01] Titulo do campo 
	"Motorista",;													// [02] ToolTip do campo 	
	"ZE_MOTORI",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	TamSx3("DA3_MOTORI")[1],;										// [05] Tamanho do campo
	TamSx3("DA3_MOTORI")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 


	oStLote:AddField("" ,;											// [01] Titulo do campo 
	"",;														    // [02] ToolTip do campo 	
	"ZE_PERSMO",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "CLIENTE"},;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 				

	oStLote:AddField("" ,;											// [01] Titulo do campo 
	"",;															// [02] ToolTip do campo 	
	"ZE_DESCMO",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	TamSx3("DA4_NOME")[1],;											// [05] Tamanho do campo
	TamSx3("DA4_NOME")[2],;											// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 

	oStLote:AddField("" ,;											// [01] Titulo do campo 
	"",;															// [02] ToolTip do campo 	
	"ZE_QTDNOTA",;													// [03] Id do Field
	"N"	,;															// [04] Tipo do campo
	5,;																// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 

	//	oStLote:AddField("CIOT" ,;										// [01] Titulo do campo 
	//	"CIOT",;														// [02] ToolTip do campo 	
	//	"ZE_CIOT",;														// [03] Id do Field
	//	"C"	,;															// [04] Tipo do campo
	//	TamSx3("DTR_CIOT")[1],;											// [05] Tamanho do campo
	//	TamSx3("DTR_CIOT")[2],;											// [06] Decimal do campo
	//	{ || .T. }	,;													// [07] Code-block de validação do campo
	//	{ || .T. }	,;													// [08] Code-block de validação When do campo
	//	,;																// [09] Lista de valores permitido do campo
	//	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	//	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	//	,; 																// [12] 
	//	,; 																// [13] 
	//	.T.	) 

	oStLote:AddField("Cod.1o.Reboq" ,;									// [01] Titulo do campo 
	"Cod.1o.Reboq",;														// [02] ToolTip do campo 	
	"ZE_CODRB1",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	TamSx3("DTR_CIOT")[1],;											// [05] Tamanho do campo
	TamSx3("DTR_CIOT")[2],;											// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12] 
	,; 																// [13] 
	.T.	) 

	oStLote:AddField("Cod.2o.Reboq" ,;								// [01] Titulo do campo 
	"Reboq2",;														// [02] ToolTip do campo 	
	"ZE_CODRB2",;													// [03] Id do Field
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

	oStLote:AddField("Cod.3o.Reboq" ,;								// [01] Titulo do campo 
	"Cod.3o.Reboq",;												// [02] ToolTip do campo 	
	"ZE_CODRB3",;													// [03] Id do Field
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


//	oStLote:AddField("Rota" ,;										// [01] Titulo do campo 
//	"Rota",;														// [02] ToolTip do campo 	
//	"ZE_ROTA",;														// [03] Id do Field
//	"C"	,;															// [04] Tipo do campo
//	TamSx3("DTQ_ROTA")[1],;											// [05] Tamanho do campo
//	TamSx3("DTQ_ROTA")[2],;											// [06] Decimal do campo
//	{ || .T. }	,;													// [07] Code-block de validação do campo
//	{ || .T. }	,;													// [08] Code-block de validação When do campo
//	,;																// [09] Lista de valores permitido do campo
//	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
//	{ || ""}		,;	                                            // [11] Inicializador Padrão do campo
//	,; 																// [12] 
//	,; 																// [13] 
//	.T.	) 

	// Tira a permissao de alterar os campos
	oStSZE:SetProperty ( '*' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStLote:SetProperty( '*' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))

	// Concede permissao para ser alterados
	oStSZE:SetProperty( 'ZE_MARK'    , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZE:SetProperty( 'ZE_PLACA'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZE:SetProperty( 'ZE_VALFRET' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZE:SetProperty( 'ZE_QTDVOL'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZE:SetProperty( 'ZE_PESO'    , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZE:SetProperty( 'ZE_PESLIQ'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZE:SetProperty( 'ZE_DEVFRE'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZE:SetProperty( 'ZE_VLPEDAG' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN   , '.T.' ))	
	oStSZE:SetProperty( 'ZE_VLDESCA' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN   , '.T.' ))	
	oStSZE:SetProperty( 'ZE_YVLRTON' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN   , '.T.' ))	
	
	
	oStLote:SetProperty( 'ZE_VLPEDAG' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))	
	oStLote:SetProperty( 'ZE_VLDESCA' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))	
	oStLote:SetProperty( 'ZE_MOTORI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStLote:SetProperty( 'ZE_VALFRET' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStLote:SetProperty( 'ZE_CODRB1'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStLote:SetProperty( 'ZE_CODRB2'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStLote:SetProperty( 'ZE_CODRB3'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))

	// Validacoes
	oStSZE:SetProperty( '*'  	   , MODEL_FIELD_VALID , FwBuildFeature(STRUCT_FEATURE_VALID  , 'StaticCall(SERTMS05,PosLinSZE)' ))
	oStSZE:SetProperty( 'ZE_PLACA' , MODEL_FIELD_VALID , FwBuildFeature(STRUCT_FEATURE_VALID  , 'StaticCall(SERTMS05,VerifDA3)' ))
	oStSZE:SetProperty( 'ZE_MARK'  , MODEL_FIELD_VALID , FwBuildFeature(STRUCT_FEATURE_VALID  , 'StaticCall(SERTMS05,ValidChek) .and. StaticCall(SERTMS05,PosLinSZE)'))

	oStLote:SetProperty( 'ZE_VALFRET'  , MODEL_FIELD_VALID , FwBuildFeature(STRUCT_FEATURE_VALID  , 'StaticCall(SERTMS05,RatFrt,"ZE_VALFRET")'))
	oStLote:SetProperty( 'ZE_VLPEDAG'  , MODEL_FIELD_VALID , FwBuildFeature(STRUCT_FEATURE_VALID  , 'StaticCall(SERTMS05,RatFrt,"ZE_VLPEDAG")'))
	oStLote:SetProperty( 'ZE_VLDESCA'  , MODEL_FIELD_VALID , FwBuildFeature(STRUCT_FEATURE_VALID  , 'StaticCall(SERTMS05,RatFrt,"ZE_VLDESCA")'))

	// Gatilhos
	
	aAuxGat := FwStruTrigger("ZE_YVLRTON","ZE_VALFRET","StaticCall(SERTMS05,GetVlrFrt)",.F.,Nil,Nil,Nil)
	oStSZE:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])
	
	aAuxGat := FwStruTrigger("ZE_VALFRET","ZE_YVLRTON","StaticCall(SERTMS05,GetVlrTon)",.F.,Nil,Nil,Nil)
	oStSZE:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])
	
	aAuxGat := FwStruTrigger("ZE_MOTORI","ZE_DESCMO","StaticCall(SERTMS05,GetMotori)",.F.,Nil,Nil,Nil)
	oStLote:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	oModel := MPFormModel():New("MSERTMS05",/*bPre*/,bPos,bCommit/*bCommit*/,/*bCancel*/) 

	// Cria os componentes
	oModel:AddFields("CABMASTER", /*cOwner*/	,oStCAB ,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
	oModel:AddGrid( "SZEDETAIL" , "CABMASTER"   ,oStSZE ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid( "SZELOTE" 	, "CABMASTER"   ,oStLote,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadLote/*bLoad*/)
	
	AADD(aFilter,{ 'ZE_LOTNFC', "''" })
	
	If lFilCNPJ
		AADD(aFilter,{ 'ZE_CGCTRAN', "SM0->M0_CGC" })
	End iF
	
	oModel:GetModel( "SZEDETAIL" ):SetLoadFilter( aFilter )

	//oModel:GetModel("SZEDETAIL"):SetForceLoad(.T.)
	//oModel:GetModel("SZELOTE"):SetForceLoad(.T.)

	// Realiza os relacionamentos
	oModel:SetRelation("SZEDETAIL" ,{{"ZE_FILIAL" ,"xFilial('SZE')"}},SZE->(IndexKey(1)))
	//oModel:SetRelation("SZELOTE" ,{{"ZE_FILIAL" ,"xFilial('SZE')"}},SZE->(IndexKey(1)))

	// Informa a descricao dos modelos
	oModel:GetModel("SZEDETAIL"):SetDescription("Notas Fiscais")
	oModel:GetModel("CABMASTER"):SetDescription("Cabeçalho")
	oModel:GetModel("SZELOTE"):SetDescription("Lotes")
	oModel:SetDescription("Criacao de Viagens") 

	// Muda a estrutura para inserir ou deletar
	oModel:GetModel("SZEDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SZEDETAIL"):SetNoInsertLine(.T.)
	//oModel:GetModel("SZELOTE"):SetNoInsertLine(.T.)

	oModel:SetPrimaryKey({""})

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local cCampo := "ZE_DOC,ZE_SERIE,ZE_EMINFC,ZE_DEVFRE,ZE_NOMREM,ZE_NOMDES,ZE_VALOR,ZE_PLACA,ZE_YVLRTON,ZE_PESO,ZE_VALFRET,ZE_VLPEDAG,ZE_VLDESCA,ZE_QTDVOL,ZE_PESLIQ,ZE_CGCREM,ZE_CGCDES,ZE_NFEID"
	Local aCampo := StrTokArr(cCampo,",")
	Local cCampL := "ZE_CARGA,ZE_PLACA,ZE_PERSON,ZE_DESCFO,ZE_CODRB1,ZE_CODRB2,ZE_CODRB3,ZE_PERSMO,ZE_MOTORI,ZE_DESCMO,ZE_VALFRET,ZE_VLPEDAG,ZE_VLDESCA,ZE_QTDNOTA,ZE_QTDVOL,ZE_PESO,ZE_PESLIQ"
	Local aCampL := StrTokArr(cCampL,",")
	Local oView  := Nil
	Local oModel := FWLoadModel("SERTMS05")
	Local oStSZE := FWFormStruct(2, "SZE",{ |x| ALLTRIM(x) $ cCampo })
	Local oStLote := FWFormStruct(2, "SZE",{ |x| ALLTRIM(x) $ cCampL})
	Local i		 := 0


	SetKey( VK_F1 , {|| MarkAll()} )
	SetKey( VK_F2 , {|| DesMAll()} )
	SetKey( VK_F3 , {|| TMSAE40()} )
	SetKey( VK_F4 , {|| PosLinSZE()} )
	SetKey( VK_F6 , {|| TECA250()} )
	SetKey( VK_F7 , {|| TMSA480()} )
	SetKey( VK_F8 , {|| AltPlaca()} )

	oStSZE:AddField("ZE_MARK",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"")//cPicture	

	oStSZE:AddField("SUMARIO",; //Id do Campo 
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	"@BMP"  )//cPicture  


	oStSZE:AddField("ZE_YVLRTON",; //Id do Campo 
	"00",; //Ordem
	"Vlr Ton.",;// Título do Campo
	"Vlr Ton.",; //Descrição do Campo
	{},; //aHelp
	"N",; //Tipo do Campo	
	X3Picture("ZE_PESO")  )//cPicture 

	oStLote:AddField("ZE_CARGA",; //Id do Campo 
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture  

	oStLote:AddField("ZE_PERSON",; //Id do Campo 
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture  	

	oStLote:AddField("ZE_DESCFO",; //Id do Campo 
	"00",; //Ordem
	"Proprietario",;// Título do Campo
	"Proprietario",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture

	oStLote:AddField("ZE_MOTORI",; //Id do Campo 
	"00",; //Ordem
	"Motorista",;// Título do Campo
	"Motorista",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture

	oStLote:AddField("ZE_PERSMO",; //Id do Campo 
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture 

	oStLote:AddField("ZE_DESCMO",; //Id do Campo 
	"00",; //Ordem
	"Nome Motoris",;// Título do Campo
	"Nome Motoris",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture

	oStLote:AddField("ZE_QTDNOTA",; //Id do Campo 
	"00",; //Ordem
	"Qtd. NFe",;// Título do Campo
	"Qtd. NFe",; //Descrição do Campo
	{},; //aHelp
	"N",; //Tipo do Campo	
	)//cPicture	

	//	oStLote:AddField("ZE_CIOT",; //Id do Campo 
	//	"00",; //Ordem
	//	"CIOT",;// Título do Campo
	//	"CIOT",; //Descrição do Campo
	//	{},; //aHelp
	//	"C",; //Tipo do Campo	
	//	)//cPicture	

	oStLote:AddField("ZE_CODRB1",; //Id do Campo 
	"00",; //Ordem
	"Reboq1",;// Título do Campo
	"Reboq1",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture		

	oStLote:AddField("ZE_CODRB2",; //Id do Campo 
	"00",; //Ordem
	"Reboq2",;// Título do Campo
	"Reboq2",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture		

	oStLote:AddField("ZE_CODRB3",; //Id do Campo 
	"00",; //Ordem
	"Reboq3",;// Título do Campo
	"Reboq3",; //Descrição do Campo
	{},; //aHelp
	"C",; //Tipo do Campo	
	)//cPicture		

//	oStLote:AddField("ZE_ROTA",; //Id do Campo 
//	"00",; //Ordem
//	"Rota",;// Título do Campo
//	"Rota",; //Descrição do Campo
//	{},; //aHelp
//	"C",; //Tipo do Campo	
//	)//cPicture		

	// Refaz a ordem
	For i := 1 To Len(aCampo)
		If i < 10
			oStSZE:SetProperty( aCampo[i], MVC_VIEW_ORDEM, '0' + Alltrim(STR(i)))
		Else
			oStSZE:SetProperty( aCampo[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next


	For i := 1 To Len(aCampl)
		If i < 10
			oStLote:SetProperty( aCampl[i], MVC_VIEW_ORDEM, '0' + Alltrim(STR(i)))
		Else
			oStLote:SetProperty( aCampl[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	// Tratamento dos tamanho dos campos
	oStSZE:SetProperty( "*"     	, MVC_VIEW_WIDTH, 080 )
	oStSZE:SetProperty( "ZE_MARK"   , MVC_VIEW_WIDTH, 001 )
	oStSZE:SetProperty( "ZE_NOMREM" , MVC_VIEW_WIDTH, 220 )
	oStSZE:SetProperty( "ZE_NOMDES" , MVC_VIEW_WIDTH, 220 )
	oStSZE:SetProperty( "ZE_VALOR"  , MVC_VIEW_WIDTH, 100 )
	oStSZE:SetProperty( "ZE_VALFRET", MVC_VIEW_WIDTH, 120 )
	oStSZE:SetProperty( "ZE_CGCREM" , MVC_VIEW_WIDTH, 120 )
	oStSZE:SetProperty( "ZE_CGCDES" , MVC_VIEW_WIDTH, 120 )
	oStSZE:SetProperty( "ZE_NFEID"  , MVC_VIEW_WIDTH, 300 )

	oStLote:SetProperty( "*"     	, MVC_VIEW_WIDTH, 080 )
	oStLote:SetProperty( "ZE_DESCFO", MVC_VIEW_WIDTH, 180 )
	oStLote:SetProperty( "ZE_DESCMO", MVC_VIEW_WIDTH, 180 )
	oStLote:SetProperty( "ZE_VALFRET", MVC_VIEW_WIDTH, 110 )

	// F3
	oStLote:SetProperty( "ZE_MOTORI", MVC_VIEW_LOOKUP, "DA4" )
	oStLote:SetProperty( "ZE_CODRB1", MVC_VIEW_LOOKUP, "DA3" )
	oStLote:SetProperty( "ZE_CODRB2", MVC_VIEW_LOOKUP, "DA3" )
	oStLote:SetProperty( "ZE_CODRB3", MVC_VIEW_LOOKUP, "DA3" )
	//oStLote:SetProperty( "ZE_ROTA"	, MVC_VIEW_LOOKUP, "DU5" )

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddGrid("VIEW_SZE"   , oStSZE    , "SZEDETAIL")
	oView:AddGrid("VIEW_LOTE"  , oStLote   , "SZELOTE")

	oView:CreateHorizontalBox("SUPERIOR",060)
	oView:CreateHorizontalBox("INFERIOR",040)

	//oView:CreateVerticalBox( "ESQUERDA", 025 ,"INFERIOR")
	//oView:CreateVerticalBox( "DIREITA" , 075 ,"INFERIOR")

	oView:SetCloseOnOk({||.T.})

	oView:SetProgressBar(.T.)

	oView:SetOwnerView("VIEW_SZE" ,"SUPERIOR")
	oView:SetOwnerView("VIEW_LOTE" ,"INFERIOR")

	oView:EnableTitleView("VIEW_SZE" , "Documentos Fiscais" )
	oView:EnableTitleView("VIEW_LOTE" , "Lotes por Veículos" )

	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty("VIEW_SZE", "GRIDSEEK"  , {.T.})
	oView:SetViewProperty("VIEW_SZE", "GRIDFILTER", {.T.}) 

	oView:AddUserButton("F1 - Marca todos 	  ","MAGIC_BMP",{|| MarkAll()},"Comentário do botão")
	oView:AddUserButton("F2 - Desmarca todos  ","MAGIC_BMP",{|| DesMAll()},"Comentário do botão")
	oView:AddUserButton("F3 - Produto x Embarcador","MAGIC_BMP",{|| TMSAE40()},"Comentário do botão")
	oView:AddUserButton("F6 - Contrato Cliente","MAGIC_BMP",{|| TECA250()},"Comentário do botão")
	oView:AddUserButton("F7 - Perfil Cliente ","MAGIC_BMP",{|| TMSA480()},"Comentário do botão")
	oView:AddUserButton("F8 - Preencher Placa ","MAGIC_BMP",{|| AltPlaca()},"Comentário do botão")

	oView:setUpdateMessage("Geração Viagem", "Realizada com sucesso!!")

Return oView

/*/{Protheus.doc} LoadLote
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadLote(oGridModel, lCopy,oModel)

	Local aSaveLines := FWSaveRows()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local nTotReg	:= oModelSZE:Length()
	Local oStrLote  := oGridModel:GetStruct() 
	Local aCampos	:= Array(Len(oStrLote:GetFields()))
	Local i			:= 0
	Local aLoad		:= {}
	Local nPos		:= 0

	Local nPosPlaca 	 := oStrLote:GetArrayPos({"ZE_PLACA"})[1]
	Local nPosVFret 	 := oStrLote:GetArrayPos({"ZE_VALFRET"})[1]
	Local nPosQTdVOl  	 := oStrLote:GetArrayPos({"ZE_QTDVOL"})[1]
	Local nPosPeso  	 := oStrLote:GetArrayPos({"ZE_PESO"})[1]
	Local nPosPesoL  	 := oStrLote:GetArrayPos({"ZE_PESLIQ"})[1]
	Local nPosCarga 	 := oStrLote:GetArrayPos({"ZE_CARGA"})[1]
	Local nPosPeson 	 := oStrLote:GetArrayPos({"ZE_PERSON"})[1]
	Local nPosPropr 	 := oStrLote:GetArrayPos({"ZE_DESCFO"})[1]
	Local nPosCodMo		 := oStrLote:GetArrayPos({"ZE_MOTORI"})[1]
	Local nPosPerMo		 := oStrLote:GetArrayPos({"ZE_PERSMO"})[1]
	Local nPosNomMo		 := oStrLote:GetArrayPos({"ZE_DESCMO"})[1]
	Local nPosQtdNF		 := oStrLote:GetArrayPos({"ZE_QTDNOTA"})[1]
	//Local nPosCIOT		 := oStrLote:GetArrayPos({"ZE_CIOT"})[1]
	Local nPosRebo1		 := oStrLote:GetArrayPos({"ZE_CODRB1"})[1]
	Local nPosRebo2		 := oStrLote:GetArrayPos({"ZE_CODRB2"})[1]
	Local nPosRebo3		 := oStrLote:GetArrayPos({"ZE_CODRB3"})[1]
	Local nPosVlPDG		 := oStrLote:GetArrayPos({"ZE_VLPEDAG"})[1]
	Local nPosVlDes		 := oStrLote:GetArrayPos({"ZE_VLDESCA"})[1]
	//Local nPosRota		 := oStrLote:GetArrayPos({"ZE_ROTA"})[1]


	DA3->(DbSetOrder(1))

	For i:= 1 to nTotReg

		oModelSZE:Goline(i)

		If oModelSZE:GetValue("ZE_MARK")

			// Verifica se a placa ja foi incluida no array
			nPos := ASCAN(aLoad, { |x| Alltrim(x[2][nPosPlaca]) == Alltrim(oModelSZE:GetValue("ZE_PLACA")) }) 

			If nPos == 0 

				If DA3->(Dbseek(xFilial("DA3") + oModelSZE:GetValue("ZE_PLACA")))

					acampos[nPosPlaca] 	:= oModelSZE:GetValue("ZE_PLACA")
					acampos[nPosCarga] 	:= "CARGA"//"CARGANEW_MDI"
					acampos[nPosPeson] 	:= "BMPUSER"
					acampos[nPosPropr] 	:= Alltrim(POSICIONE("SA2",1,xFilial("SA2") + DA3->(DA3_CODFOR + DA3_LOJFOR),"A2_NOME"))
					acampos[nPosCodMo] 	:= DA3->DA3_MOTORI
					acampos[nPosPerMo] 	:= "CLIENTE"// "TCFIMG32"  //"CRDIMG32"
					acampos[nPosNomMo] 	:= Alltrim(Posicione("DA4",1,xFilial("DA4")+DA3->DA3_MOTORI,"DA4_NOME"))
					acampos[nPosVFret] 	:= oModelSZE:GetValue("ZE_VALFRET")
					acampos[nPosVlPDG] 	:= oModelSZE:GetValue("ZE_VLPEDAG")
					acampos[nPosVlDes] 	:= oModelSZE:GetValue("ZE_VLDESCA")
					acampos[nPosQTdVOl] := oModelSZE:GetValue("ZE_QTDVOL")
					acampos[nPosPeso]  	:= oModelSZE:GetValue("ZE_PESO")
					acampos[nPosPesoL]  := oModelSZE:GetValue("ZE_PESLIQ")
					acampos[nPosQtdNF]  := 1
					//acampos[nPosCIOT]	:= Space(TamSX3("DTR_CIOT")[1])
					acampos[nPosRebo1]	:= Space(TamSX3("DTR_CODRB1")[1])
					acampos[nPosRebo2]	:= Space(TamSX3("DTR_CODRB2")[1])
					acampos[nPosRebo3]	:= Space(TamSX3("DTR_CODRB3")[1])
					//acampos[nPosRota]	:= Space(TamSX3("DTQ_ROTA")[1])

					aAdd(aLoad,{Len(aLoad),aclone(acampos)})
				End if
			Else	

				aLoad[nPos][2][nPosVFret]  += oModelSZE:GetValue("ZE_VALFRET")
				aLoad[nPos][2][nPosVlPDG]  += oModelSZE:GetValue("ZE_VLPEDAG")
				aLoad[nPos][2][nPosVlDes]  += oModelSZE:GetValue("ZE_VLDESCA")
				aLoad[nPos][2][nPosQTdVOl] += oModelSZE:GetValue("ZE_QTDVOL")
				aLoad[nPos][2][nPosPeso]   += oModelSZE:GetValue("ZE_PESO")
				aLoad[nPos][2][nPosPesoL]  += oModelSZE:GetValue("ZE_PESLIQ")
				aLoad[nPos][2][nPosQtdNF]  += 1
			End if
		End If

	Next

	FWRestRows( aSaveLines )
Return aLoad

/*/{Protheus.doc} MCommit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function MCommit(oModel)

	Local lRet := .t.

	//Processa({|| lRet := Commit(oModel)})

	oProcess := MsNewProcess():New({|| lRet := Commit(oProcess,oModel)}, "Criando Viagens", "Aguarde...", .T.)
	oProcess:Activate()

Return lRet

/*/{Protheus.doc} TdOkModel
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function TdOkModel(oModel)

	Local oModelLote := oModel:GetModel("SZELOTE")
	Local nTotReg	:= oModelLote:Length()
	Local oModelSZE	:= oModel:GetModel("SZEDETAIL")
	Local nTotSZE	:= oModelSZE:Length()
	Local i			:= 0
	Local y			:= 0
	Local cMsg		:= ""
	Local cSolu		:= ""
	Local lRet		:= .t.

	If !MSGYESNO("Deseja prosseguir com Entrada dos Documentos, Geração do Lote, Emissão Cte e Criação da Viagem?", "Carregamento" )
		cMsg  := "Processo cancelado pelo usuario"
		cSolu := ""
		Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

	For y:= 1 to nTotSZE

		oModelSZE:Goline(y)

		If oModelSZE:GetValue("ZE_MARK") .and. oModelSZE:GetValue("ZE_VALFRET") == 0 
			cMsg  := "Existem notas fiscais selecionadas com o valor do frete zerado."
			cSolu := "Favor informar o valor do frete para estas notas fiscais."
			Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End If

	Next

	For i:= 1 to nTotReg

		oModelLote:Goline(i)

		DA3->(DbSetOrder(1))
		DA3->(DbSeek(xFilial("DA3") + oModelLote:GetValue("ZE_PLACA")))

		// Verifica o CIT
		//		If Empty(oModelLote:GetValue("ZE_CIOT"))
		//			
		//			If DA3->DA3_FROVEI <> "1"
		//				cMsg  := "CIOT não informado para o veículo " + oModelLote:GetValue("ZE_PLACA")
		//				cSolu := "Favor preencher quando não for veículo próprio."
		//				Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		//				Return .f.
		//			End if
		//		
		//		End IF

		// Verifica o Motorista	
		If Empty(oModelLote:GetValue("ZE_MOTORI"))

			cMsg  := "O veículo " + oModelLote:GetValue("ZE_PLACA") + " se encontra sem motorista informado."
			cSolu := "Favor informar motorista para criação da viagem."
			Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.

		End If
		
//		If Empty(oModelLote:GetValue("ZE_ROTA"))
//			cMsg  := "O veículo " + oModelLote:GetValue("ZE_PLACA") + " se encontra sem ROTA."
//			cSolu := "Favor informar ROTS para criação da viagem."
//			Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
//			Return .f.
//		End If
	Next

	oModel:lModify := .t. 

Return lRet

/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oProcess, object, description
@param oModel, object, description
@type function
/*/
Static Function Commit(oProcess,oModel)

	Local oModelLote := oModel:GetModel("SZELOTE")
	Local nTotReg	 := oModelLote:Length()
	Local i			 := 0
	Local y			 := 0
	Local nProces	 := 8
	Local lRet		 := .t.
	Local aLotes	 := {}
	Local lTrasLote	 := SuperGetMV("MV_YTRALOTE",.f.,.f.)

	BEGIN TRANSACTION

		oProcess:SetRegua1(nTotReg)

		For i:= 1 to nTotReg

			oModelLote:GoLine(i)

			if oModelLote:IsDeleted()
				Loop
			End if

			oProcess:IncRegua1("Placa: " + oModelLote:GetValue("ZE_PLACA") + " (" + cValToChar(i) + "/" + cValToChar(nTotReg) +")")	

			// Informo que tera 8 processos			
			oProcess:SetRegua2(nProces)			

			// Cria Lote
			If lRet
				oProcess:IncRegua2("Criando Lote")
				lRet := CriaDTP(oModel)
			End if

			// Cria Documento do Cliente
			If lRet
				oProcess:IncRegua2("Criando Documento Entrada Cliente")
				lRet := CriaDTC(oModel)
			End If

			// Calcula o Lote (Geracao do CTE)
			If lRet
				oProcess:IncRegua2("Emitindo os Ctes")
				Private cCadastro 	:= "Calculo do Lote"

				SetFunname("TMSA200")
				Pergunte("TMB200",.F.)

				// Desliga o a transmissao do TSS, pois esta dentro de um 
				// Begin Transaction
				SetMVValue("TMB200","MV_PAR02",2)
				SetMVValue("TMB200","MV_PAR10",1) 

				lRet := TMSA200Prc( DTP->DTP_FILORI, DTP->DTP_LOTNFC )

				SetMVValue("TMB200","MV_PAR02",1)
				SetMVValue("TMB200","MV_PAR10",2)  
				SetFunname("SERTMS05")

			End If

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

			If lTrasLote
				// Lotes para transmitir
				AADD(aLotes,DTP->DTP_LOTNFC)
			End if

		Next

	END TRANSACTION 	

	If lRet
		// Realiza a transmissao do lote fora da transacao
		For y:= 1 to len(aLotes)

			cLotNfc := aLotes[y]

			DTP->(DbSetOrder(1))
			if DTP->(DbSeek(xFilial("DTP") + cLotNfc))
				// Chama a transmissao do lote
				TMSAE70(1,cFilAnt,cLotNfc)
				Tmsa310Grv(3)
			End if
		Next
	End if

Return lRet


/*/{Protheus.doc} CriaDTP
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTP(oModel)

	Local aCab := {}
	Local lRet := .t.
	Local cErro  := ""
	Local oModelLote := oModel:GetModel("SZELOTE")
	Local nQtdNF	 := oModelLote:GetValue("ZE_QTDNOTA")
	Local cPlaca	 := oModelLote:GetValue("ZE_PLACA")
	Private lMsErroAuto := .F.

	DA3->(DbSetOrder(1))

	// Posiciona no cadastro do veiculo
	DA3->(DbSeek(xFilial("DA3") + cPlaca))

	Aadd(aCab,{'DTP_QTDLOT',nQtdNF,NIL})
	Aadd(aCab,{'DTP_TIPLOT','3',NIL})  //--1 Normal, 2- Refaturamento, 3- Eletronico             
	Aadd(aCab,{'DTP_STATUS','1',NIL})  //--1 -Aberto, 2- Digitado, 3- Calculado, 4- Bloqueado, 5- Erro de Gravação                  

	MsExecAuto({|x,y| TmsA170(x,y)},aCab,3)           

	If lMsErroAuto     
		cErro := MostraErro()
		oModel:SetErrorMessage("",,oModel:GetId(),"","CriaDTP","Falha ao criar o lote") 
		lRet := .f.
	End iF


Return lRet

/*/{Protheus.doc} CriaDTC
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTC(oModel)

	Local aSaveLines:= FWSaveRows()
//	Local oModel 	:= FwModelActive()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local oModelLote:= oModel:GetModel("SZELOTE")
	Local nRegTot	:= oModelSZE:Length()
	Local i			:= ""
	Local cCodREM	:= ""
	Local cLojREM	:= ""
	Local cCodDES	:= ""
	Local cLojDES	:= ""
	Local cMsg		:= ""
	Local cSolu		:= ""
	Local cErro		:= ""
	Local lRet		:= .t.
	Local lNovo		:= .t.
	Local cFrtInfor	:= SuperGetMV("MV_YCDFRTE",.f.,"01") // FRETE 	INFORMADO
	Local cPedagio	:= SuperGetMV("MV_YCDPEDA",.f.,"02") // PEGAGIO INFORMADO
	Local cDesca	:= SuperGetMV("MV_YCDDESC",.f.,"03") // DESCARGA INFORMADO
	Local cCodServ  := SuperGetMV("MV_YCODSER",.f.,"019")
	Local cCodProd	:= SuperGetMV("MV_YTMSCOD",.f.,"TMSSRV001")
	Local cObs		:= ""
	Local nPrecoKG	:= ""
	Local cCliEmb	:= SuperGetMV("MV_YCLIEMB",.f.,"00001")
	Local nInfINI	:= SuperGetMV("MV_YINFI",.f.,1)
	Local nInfFIM	:= SuperGetMV("MV_YINFF",.f.,4)

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	// Verifica quais sao as notas fiscais pela placa
	For i := 1 to nRegTot

		oModelSZE:Goline(i)

		aCabDTC := {}
		aItemDTC:= {}

		If oModelSZE:GetValue("ZE_MARK") .AND. Alltrim(oModelSZE:GetValue("ZE_PLACA")) == Alltrim(oModelLote:GetValue("ZE_PLACA"))

			SZE->(DbSetOrder(1))

			SZE->(DbGoTo(oModelSZE:GetDataId()))

			RecLock('SZE', .F.)
			Replace ZE_LOTNFC With DTP->DTP_LOTNFC
			MsUnlock()	

			SA1->(DbSetOrder(3))

			// Localiza o cadastro do Remetente
			If SA1->(DbSeek(xFilial("SA1") + oModelSZE:GetValue("ZE_CGCREM")))
				cCodREM := SA1->A1_COD
				cLojREM := SA1->A1_LOJA
			Else
				cMsg  := "Não foi possível localizar o cadastro do Remetente (" + oModelSZE:GetValue("ZE_CGCREM") + ")"
				cSolu := "Favor realizar o cadastro."
				Help(NIL, NIL, "CriaDTC", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End If

			// Localiza o cadastro do Destinatario
			If SA1->(DbSeek(xFilial("SA1") + oModelSZE:GetValue("ZE_CGCDES")))
				cCodDES := SA1->A1_COD
				cLojDES := SA1->A1_LOJA
			Else
				cMsg  := "Não foi possível localizar o cadastro do Destinatario (" + oModelSZE:GetValue("ZE_CGCREM") + ")"
				cSolu := "Favor realizar o cadastro."
				Help(NIL, NIL, "CriaDTC", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End If 

			//Localiza o cadastro do produto x embarcador
			DE7->(DbSetOrder(1))
			If DE7->(DbSeek(xFilial("DE7") + cCodREM + cLojREM))
				cCodProd := DE7->DE7_CODPRO
			End if
				
			nPrecoKG	:= oModelSZE:GetValue("ZE_VALFRET") / oModelSZE:GetValue("ZE_PESO")
			//nPrecoKG	:= Round(nPrecoKG,3)
			cObs		:= "VALORKG: R$ " + cValtochar(nPrecoKG) + Chr(13) + Chr(10) 
			cObs		+= ", MOTORISTA: " + Alltrim(oModelLote:GetValue("ZE_DESCMO")) + Chr(13) + Chr(10) 
			cObs		+= ", PLACA : " + Alltrim(oModelLote:GetValue("ZE_PLACA")) + Chr(13) + Chr(10) 
			cObs		+= ", NF: " + oModelSZE:GetValue("ZE_DOC") + Chr(13) + Chr(10) 
			
			If SZE->(FieldPos("ZE_INFNFE")) > 0
				If cCodREM $ cCliEmb
					cObs	+=  "EMBARQUE: " + SUBSTR(Alltrim(oModelSZE:GetValue("ZE_INFNFE")), nInfINI, nInfFIM) 
				End If
			End IF
			//{"DTC_DOCTMS" ,"2" 									, Nil},; //Documento de Transporte

			// Dados da Nota Fiscal
			aCabDTC:= {	{"DTC_LOTNFC" ,Alltrim(DTP->DTP_LOTNFC)				, Nil},; //Número Lote
			{"DTC_DATENT" ,dDataBase 							, Nil},; //Data da Entrada
			{"DTC_CLIREM" ,cCodREM 								, Nil},; //Cod. Remetente
			{"DTC_LOJREM" ,cLojREM 								, Nil},; //Loja Remetente
			{"DTC_CLIDES" ,cCodDES 								, Nil},; //Cod. Destinatário
			{"DTC_LOJDES" ,cLojDES 								, Nil},; //Loja Destinatário
			{"DTC_DEVFRE" ,oModelSZE:GetValue("ZE_DEVFRE")		, Nil},; //Devedor do Frete - 1=Remetente;2=Destinatario;3=Consignatario;4=Despachante
			{"DTC_TIPFRE" ,oModelSZE:GetValue("ZE_TIPFRE") 		, Nil},; //Tipo do Frete - 1=CIF;2=FOB
			{"DTC_SERTMS" ,"3" 									, Nil},; //Servico de Transporte - 3 Entrega
			{"DTC_TIPTRA" ,"1" 									, Nil},; //Tipo Transporte - 1=Rodoviario / 2=Aereo / 3=Fluvial.
			{"DTC_TIPNFC" ,"0" 									, Nil},; //Tipo Nf Cli. - 0=Normal;1=Devolucao;2=SubContratacao;3=Nao Fiscal;4=Exportacao;5=Redesp;6=Nao Fiscal 1;7=Nao Fiscal 2;8=Serv Vincul.Multimodal
			{"DTC_SERVIC" ,cCodServ 							, Nil},; //Documento de Transporte
			{"DTC_CODNEG" ,"01" 								, Nil},; //Documento de Transporte
			{"DTC_OBS" 	  ,cObs 								, Nil},; //
			{"DTC_SELORI" ,"2" 									, Nil}} //Seleciona Origem - 1=Transportadora;2=Cliente Remetente;3=Local Coleta

			// Itens da NF
			Aadd(aItemDTC,{ {"DTC_LOTNFC" ,Alltrim(DTP->DTP_LOTNFC)			, Nil},; //Número Lote
			{"DTC_NUMNFC" ,oModelSZE:GetValue("ZE_DOC") 	, Nil},; //Doc.Cliente
			{"DTC_SERNFC" ,oModelSZE:GetValue("ZE_SERIE") 	, Nil},; //Serie Docto. Cliente
			{"DTC_NFEID"  ,oModelSZE:GetValue("ZE_NFEID") 	, Nil},; //Chave Acesso
			{"DTC_CODPRO" ,cCodProd 						, Nil},; //Codigo do Produto
			{"DTC_CODEMB" ,"CX"								, Nil},; //Codigo da Embalagem //POSICIONE("SB1",1,xFilial("SB1") + cCodProd,"B1_UM") 
			{"DTC_EMINFC" ,oModelSZE:GetValue("ZE_EMINFC")  , Nil},; //Dt.Emissao Nf Cliente
			{"DTC_QTDVOL" ,oModelSZE:GetValue("ZE_QTDVOL")  , Nil},; //Quantidade de Volumes da Nota Fiscal do Cliente
			{"DTC_PESO"   ,oModelSZE:GetValue("ZE_PESO") 	, Nil},; //Peso da Nota Fiscal do Cliente.
			{"DTC_PESLIQ" ,oModelSZE:GetValue("ZE_PESLIQ")  , Nil},; //Peso da Nota Fiscal do Cliente.
			{"DTC_VALOR"  ,oModelSZE:GetValue("ZE_VALOR")	, Nil},; //Valor da Nota Fiscal do Cliente
			{"DTC_BASICM" ,oModelSZE:GetValue("ZE_BASEIC")	, Nil},; //Valor BaseICM da Nota Fiscal do Cliente
			{"DTC_VALICM" ,oModelSZE:GetValue("ZE_VALICM")	, Nil},; //Valor ICM da Nota Fiscal do Cliente
			{"DTC_BASESU" ,oModelSZE:GetValue("ZE_BASIST")	, Nil},; //Valor BASE ST da Nota Fiscal do Cliente
			{"DTC_VALIST" ,oModelSZE:GetValue("ZE_VALIST ")	, Nil},; //Valor ST da Nota Fiscal do Cliente
			{"DTC_USUAGD" ,__cUserID 						, Nil},; //Codigo do Usuario Responsável pelo Agendamento de Entrega
			{"DTC_DOCREE" ,"2" 								, Nil},; //Documento de Transporte
			{"DTC_PRVENT" ,dDataBase						, Nil},; //Hora Previsao de Entrega
			{"DTC_NFENTR" ,"2" 								, Nil},; //Nome Expedidor
			{"DTC_EDI"    ,'2' 								, Nil}}) //Nota Fiscal do EDI Indica se a Nota Fiscal é de EDI (Electronic Data Interchange).

			MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)

			If lMsErroAuto
				cErro := MostraErro()
				oModel:SetErrorMessage("",,oModel:GetId(),"","CriaDTC",cErro) 
				Return .f.
			End If

			cNumNFC := oModelSZE:GetValue("ZE_DOC") 
			cSerie	:= oModelSZE:GetValue("ZE_SERIE") 

			cCodLote := PADR(DTP->DTP_LOTNFC, TamSX3("DTC_LOTNFC")[1] ," ")
			cCodREM	 := PADR(cCodREM , TamSX3("DTC_CLIREM")[1] ," ")
			cLojREM	 := PADR(cLojREM , TamSX3("DTC_LOJREM")[1] ," ")
			cCodDES	 := PADR(cCodDES , TamSX3("DTC_CLIDES")[1] ," ")
			cLojDES	 := PADR(cLojDES , TamSX3("DTC_LOJDES")[1] ," ")
			cCodServ := PADR(cCodServ, TamSX3("DTC_SERVIC")[1] ," ")
			cCodProd := PADR(cCodProd, TamSX3("DTC_CODPRO")[1] ," ")
			cNumNFC  := PADR(cNumNFC, TamSX3("DTC_NUMNFC")[1] ," ")
			cSerie   := PADR(cSerie, TamSX3("DTC_SERNFC")[1] ," ")

			// Posiciona na DTC, exeauto nao estava posicionando.
			DTC->(DbSetOrder(1))
			DTC->(DbSeek(xFilial("DTC") + cFilAnt + cCodLote + cCodREM + cLojREM + cCodDES + cLojDES + cCodServ + cCodProd + cNumNFC + cSerie ))

			// Verifica se existe ja um valor frete informado
			DVR->( dbSetOrder(1) ) //DVR_FILIAL + DVR_FILORI + DVR_LOTNFC + DVR_CLIREM + DVR_LOJREM + DVR_CLIDES + DVR_LOJDES + DVR_SERVIC + DVR_NUMNFC + DVR_SERNFC + DVR_CODPRO + DVR_CODPAS + DVR_CODNEG
			DVR->(dbGoTop())

			// Verifica se existe valor informado ja para essa nota fiscal
			If DVR->( dbSeek( xFilial('DVR') + DTC->(DTC_FILORI + DTC_LOTNFC + DTC_CLIREM + DTC_LOJREM + DTC_CLIDES + DTC_LOJDES + DTC_SERVIC + DTC_NUMNFC + DTC_SERNFC + DTC_CODPRO + cFrtInfor + DTC_CODNEG)))
				lNovo := .F.
			else
				lNovo := .T.
			End If

			// Atualiza informacao do Valor Informado
			RecLock('DVR', lNovo)
			Replace DVR_FILIAL	 With xFilial('DVR')
			Replace DVR_FILORI	 With DTC->DTC_FILORI
			Replace DVR_LOTNFC	 With DTC->DTC_LOTNFC
			Replace DVR_CLIREM	 With DTC->DTC_CLIREM
			Replace DVR_LOJREM	 With DTC->DTC_LOJREM
			Replace DVR_CLIDES	 With DTC->DTC_CLIDES
			Replace DVR_LOJDES	 With DTC->DTC_LOJDES
			Replace DVR_SERVIC	 With DTC->DTC_SERVIC
			Replace DVR_NUMNFC	 With DTC->DTC_NUMNFC
			Replace DVR_SERNFC	 With DTC->DTC_SERNFC
			Replace DVR_CODPRO	 With DTC->DTC_CODPRO
			Replace DVR_CODPAS	 With cFrtInfor
			Replace DVR_VALOR	 With oModelSZE:GetValue("ZE_VALFRET")	
			Replace DVR_CODNEG	 With DTC->DTC_CODNEG
			MsUnlock()

			DVR->( dbSetOrder(1) ) //DVR_FILIAL + DVR_FILORI + DVR_LOTNFC + DVR_CLIREM + DVR_LOJREM + DVR_CLIDES + DVR_LOJDES + DVR_SERVIC + DVR_NUMNFC + DVR_SERNFC + DVR_CODPRO + DVR_CODPAS + DVR_CODNEG
			DVR->(dbGoTop())

			// Verifica se existe valor informado ja para essa nota fiscal
			If DVR->( dbSeek( xFilial('DVR') + DTC->(DTC_FILORI + DTC_LOTNFC + DTC_CLIREM + DTC_LOJREM + DTC_CLIDES + DTC_LOJDES + DTC_SERVIC + DTC_NUMNFC + DTC_SERNFC + DTC_CODPRO + cPedagio + DTC_CODNEG)))
				lNovo := .F.
			else
				lNovo := .T.
			End If

			// Valor do Pedagio Informado
			If oModelSZE:GetValue("ZE_VLPEDAG") > 0
				RecLock('DVR', lNovo)
				Replace DVR_FILIAL	 With xFilial('DVR')
				Replace DVR_FILORI	 With DTC->DTC_FILORI
				Replace DVR_LOTNFC	 With DTC->DTC_LOTNFC
				Replace DVR_CLIREM	 With DTC->DTC_CLIREM
				Replace DVR_LOJREM	 With DTC->DTC_LOJREM
				Replace DVR_CLIDES	 With DTC->DTC_CLIDES
				Replace DVR_LOJDES	 With DTC->DTC_LOJDES
				Replace DVR_SERVIC	 With DTC->DTC_SERVIC
				Replace DVR_NUMNFC	 With DTC->DTC_NUMNFC
				Replace DVR_SERNFC	 With DTC->DTC_SERNFC
				Replace DVR_CODPRO	 With DTC->DTC_CODPRO
				Replace DVR_CODPAS	 With cPedagio
				Replace DVR_VALOR	 With oModelSZE:GetValue("ZE_VLPEDAG")	
				Replace DVR_CODNEG	 With DTC->DTC_CODNEG
				MsUnlock()
			End IF

			DVR->( dbSetOrder(1) ) //DVR_FILIAL + DVR_FILORI + DVR_LOTNFC + DVR_CLIREM + DVR_LOJREM + DVR_CLIDES + DVR_LOJDES + DVR_SERVIC + DVR_NUMNFC + DVR_SERNFC + DVR_CODPRO + DVR_CODPAS + DVR_CODNEG
			DVR->(dbGoTop())

			// Verifica se existe valor informado ja para essa nota fiscal
			If DVR->( dbSeek( xFilial('DVR') + DTC->(DTC_FILORI + DTC_LOTNFC + DTC_CLIREM + DTC_LOJREM + DTC_CLIDES + DTC_LOJDES + DTC_SERVIC + DTC_NUMNFC + DTC_SERNFC + DTC_CODPRO + cDesca + DTC_CODNEG)))
				lNovo := .F.
			else
				lNovo := .T.
			End If

			// Valor do Descarga Informado
			If oModelSZE:GetValue("ZE_VLDESCA") > 0
				RecLock('DVR', lNovo)
				Replace DVR_FILIAL	 With xFilial('DVR')
				Replace DVR_FILORI	 With DTC->DTC_FILORI
				Replace DVR_LOTNFC	 With DTC->DTC_LOTNFC
				Replace DVR_CLIREM	 With DTC->DTC_CLIREM
				Replace DVR_LOJREM	 With DTC->DTC_LOJREM
				Replace DVR_CLIDES	 With DTC->DTC_CLIDES
				Replace DVR_LOJDES	 With DTC->DTC_LOJDES
				Replace DVR_SERVIC	 With DTC->DTC_SERVIC
				Replace DVR_NUMNFC	 With DTC->DTC_NUMNFC
				Replace DVR_SERNFC	 With DTC->DTC_SERNFC
				Replace DVR_CODPRO	 With DTC->DTC_CODPRO
				Replace DVR_CODPAS	 With cDesca
				Replace DVR_VALOR	 With oModelSZE:GetValue("ZE_VLDESCA")	
				Replace DVR_CODNEG	 With DTC->DTC_CODNEG
				MsUnlock()
			End IF

		End if

	Next

	FWRestRows( aSaveLines )
Return lRet

/*/{Protheus.doc} CriaDTQ
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTQ(oModel)

	Local dData := DATE()
	Local cTime := SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2)
	Local cRota	:= SuperGetMV("MV_YROTXML",.f.,"BRASIL")//oModelLote:GetValue("ZE_ROTA")
	Local lRet	:= .t.

	cViagem  	:= NextNumero("DTQ",1,"DTQ_VIAGEM",.T.)

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

	//Atualiza informacao na DTP.
	RecLock("DTP",.f.)
	DTP->DTP_VIAGEM := cViagem
	MsUnlock()

Return lRet


/*/{Protheus.doc} CriaDTR
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTR(oModel)

	Local oModelLote := oModel:GetModel("SZELOTE")
	Local cPlaca	 := oModelLote:GetValue("ZE_PLACA")
	//Local cCIOT		 := oModelLote:GetValue("ZE_CIOT")
	Local cRebo1	 := oModelLote:GetValue("ZE_CODRB1")
	Local cRebo2	 := oModelLote:GetValue("ZE_CODRB2")
	Local cRebo3	 := oModelLote:GetValue("ZE_CODRB3")
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
		//DTR->DTR_CIOT	:= cCIOT
		DTR->DTR_CODRB1	:=	cRebo1
		DTR->DTR_CODRB2	:=	cRebo2
		DTR->DTR_CODRB3	:=	cRebo3

		MsUnlock()

	EndIf

Return lRet


/*/{Protheus.doc} CriaDTA
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDTA(oModel)

	Local oModelLote := oModel:GetModel("SZELOTE")	
	Local cPlaca	 := oModelLote:GetValue("ZE_PLACA")
	Local lAdd 		 := .T.	
	Local cZona		 := ""
	Local cSetor	 := ""
	Local cSequen	 := Padl("0",TamSX3("DUD_SEQUEN")[1],"0")

	DA3->(DbSetOrder(1))

	// Posiciona no cadastro do veiculo
	DA3->(DbSeek(xFilial("DA3") + cPlaca))

	DTC->(DbSetOrder(1))

	//DTC_FILIAL, DTC_FILORI, DTC_LOTNFC, DTC_CLIREM, DTC_LOJREM, DTC_CLIDES, DTC_LOJDES, DTC_SERVIC, DTC_CODPRO, DTC_NUMNFC, DTC_SERNFC, R_E_C_N_O_, D_E_L_E_T_
	If DTC->(DbSeek(xFilial("DTC") + cFilAnt + DTP->DTP_LOTNFC))

		While DTC->(!EOF()) .AND. DTC->(DTC_FILIAL + DTC_FILORI + DTC_LOTNFC) == xFilial("DTC") + cFilAnt + DTP->DTP_LOTNFC
			lAdd := .t. 

			DTA->( dbSetOrder(1) )
			If DTA->( dbSeek(xFilial("DTA")+DTC->(DTC_FILDOC + DTC_DOC + DTC_SERNFC)))
				lAdd := .F.
			EndIf

			RecLock("DTA", lAdd)

			DTA->DTA_FILIAL	:=  xFilial("DTA")
			DTA->DTA_FILORI	:=	cFilAnt
			DTA->DTA_VIAGEM	:=	DTQ->DTQ_VIAGEM
			DTA->DTA_FILDOC	:=	DTC->DTC_FILDOC
			DTA->DTA_DOC	:=	DTC->DTC_DOC
			DTA->DTA_SERIE	:=	DTC->DTC_SERIE
			DTA->DTA_QTDVOL	:=	DTC->DTC_QTDVOL
			DTA->DTA_SERTMS	:=	DTC->DTC_SERTMS
			DTA->DTA_TIPTRA	:=	DTC->DTC_TIPTRA
			DTA->DTA_FILATU	:=	cFilAnt
			DTA->DTA_TIPCAR	:=	"2"
			DTA->DTA_FILDCA	:=	cFilAnt
			DTA->DTA_VALFRE	:=	0
			DTA->DTA_CODVEI :=  DA3->DA3_COD

			MsUnlock()

			lAdd := .T. 


			DUD->( dbSetOrder(1) )
			If DUD->( dbSeek(xFilial("DUD")+DTC->(DTC_FILDOC + DTC_DOC + DTC_SERIE)))
				lAdd := .F.
			EndIf

			private  cSerTms := DTC->DTC_SERTMS
			TmsA144DA7(DTC->DTC_FILDOC,DTC->DTC_DOC,DTC->DTC_SERIE,DTQ->DTQ_ROTA,@cZona,@cSetor,.F.)

			cSequen := SOMA1(cSequen)

			RecLock("DUD", lAdd)

			DUD->DUD_FILIAL	:= xFilial("DUD")
			DUD->DUD_FILORI	:= cFilAnt
			DUD->DUD_FILDOC	:= DTC->DTC_FILDOC
			DUD->DUD_DOC	:= DTC->DTC_DOC
			DUD->DUD_SERIE	:= DTC->DTC_SERIE
			DUD->DUD_SERTMS	:= DTC->DTC_SERTMS
			DUD->DUD_TIPTRA	:= DTC->DTC_TIPTRA
			DUD->DUD_CDRDES	:= DTC->DTC_CDRDES
			DUD->DUD_VIAGEM	:= DTQ->DTQ_VIAGEM
			DUD->DUD_FILDCA	:= cFilAnt
			DUD->DUD_SEQUEN	:= cSequen
			DUD->DUD_GERROM	:= "1"
			DUD->DUD_SERVIC	:= "018"//DTC->DTC_SERVIC //"018"
			DUD->DUD_CDRCAL	:= DTC->DTC_CDRCAL
			DUD->DUD_ENDERE	:= "0"
			DUD->DUD_STROTA	:= "3"
			DUD->DUD_DOCTRF	:= "2"
			DUD->DUD_ZONA	:= cZona
			DUD->DUD_SETOR	:= cSetor
			DUD->DUD_FILATU	:= cFilAnt
			DUD->DUD_CEPENT	:= Posicione("SA1", 1, xFilial("SA1")+DTC->(DTC_CLIDES + DTC_LOJDES), "A1_CEP")
			DUD->DUD_STATUS	:= "3"
			DUD->DUD_SEQENT := "001"
			MsUnlock()

			DTC->(DbSkip())
		EndDo
	EndIf 

Return .T.

/*/{Protheus.doc} CriaDUP
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaDUP(oModel)

	Local oModelLote := oModel:GetModel("SZELOTE") 
	Local cCodMot	 := oModelLote:GetValue("ZE_MOTORI")
	Local cPlaca	 := oModelLote:GetValue("ZE_PLACA")
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


/*/{Protheus.doc} GetMotori
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GetMotori()

	Local oModel := FwModelActive()
	Local oModelLote := oModel:GetModel("SZELOTE")
	Local cNome		:= ""

	cNome := Posicione("DA4",1,xFilial("DA4") + oModelLote:GetValue("ZE_MOTORI"),"DA4_NOME")                                                      

Return cNome


/*/{Protheus.doc} GetVlrFrt
Recupera o valor do Frete baseado na tonelada
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GetVlrFrt()

	Local oModel 	:= FwModelActive()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local nVlrTon	:= oModelSZE:GetValue("ZE_YVLRTON")
	Local nVlrPeso  := (oModelSZE:GetValue("ZE_PESO")/1000) //toneladas
	Local nVlrFret  := nVlrTon * nVlrPeso

Return nVlrFret

/*/{Protheus.doc} GetVlrTon
Recupera o valor da tonelada basedo no valor do frete
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GetVlrTon()

	Local oModel 	:= FwModelActive()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local nVlrFret	:= oModelSZE:GetValue("ZE_VALFRET")
	Local nVlrPeso  := (oModelSZE:GetValue("ZE_PESO")/1000) //toneladas
	Local nVlrTon   := nVlrFret / nVlrPeso

Return  nVlrTon


/*/{Protheus.doc} PosLinSZE
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function PosLinSZE()

	Local oModel := FwModelActive()
	Local oView	 := FwViewActive()
	Local oModelLOTE := oModel:GetModel("SZELOTE")
	Local nTot		:= oModelLote:Length()
	Local i			:= 0

	// Atualiza os totalizadores do lote
	If oModelLote:CanClearData() 
		oModelLote:ClearData( .f., .F. )

	Else
		For i:= 1 to nTot

			oModelLote:GoLine(i)
			oModelLote:DeleteLine()
		Next    	
	End if

	oModelLote:DeActivate()
	oModelLote:Activate()

	oView:Refresh("VIEW_LOTE") 


Return .T.

/*/{Protheus.doc} ValidChek
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ValidChek()

	Local lRet  	:= .t.
	Local cMsg  	:= ""
	Local cSolu 	:= ""
	Local oModel 	:= FwModelActive()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local cCodREM	:= ""
	Local cLojREM	:= ""
	Local cCodDES	:= ""
	Local cLojDES	:= ""
	Local cCodCLI	:= ""
	Local cLojCLI	:= ""


	If !oModelSZE:GetValue("ZE_MARK")
		Return .t.
	End If

	//	If oModelSZE:GetValue("ZE_VALFRET") == 0
	//		cMsg  := "Esta nota fiscal se encontra com o valor do Frete zerado"
	//		cSolu := "Favor informar o valor antes de selecionar a nota fiscal."
	//		Help(NIL, NIL, "ValidChek", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
	//		Return .f.
	//	End If

	If oModelSZE:GetValue("ZE_QTDVOL") == 0
		cMsg  := "Esta nota fiscal se encontra com a quantidade de volume zerada"
		cSolu := "Favor informar o valor antes de selecionar a nota fiscal."
		Help(NIL, NIL, "VerifSA1", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

	If Empty(oModelSZE:GetValue("ZE_PLACA"))
		cMsg  := "Esta nota fiscal se encontra sem a Placa"
		cSolu := "Favor informar a placa antes de selecionar a nota fiscal."
		Help(NIL, NIL, "ValidChek", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If   

	If Empty(oModelSZE:GetValue("ZE_PESO"))
		cMsg  := "Esta nota fiscal se encontra sem o Peso"
		cSolu := "Favor informar o Peso antes de selecionar a nota fiscal."
		Help(NIL, NIL, "ValidChek", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If   

	If Empty(oModelSZE:GetValue("ZE_PESLIQ"))
		cMsg  := "Esta nota fiscal se encontra sem o Peso Liq."
		cSolu := "Favor informar o Peso Liq. antes de selecionar a nota fiscal."
		Help(NIL, NIL, "ValidChek", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If   

	// Remetente
	If VerifSA1(oModel,"1")	
		// Cliente fica posicionado
		cCodREM := SA1->A1_COD
		cLojREM := SA1->A1_LOJA
	Else
		Return .f.
	End if

//	//DE7_FILIAL, DE7_CODCLI, DE7_LOJCLI, DE7_CODPRO, R_E_C_N_O_, D_E_L_E_T_
//	DE7->(DbSetOrder(1))
//	If !DE7->(DbSeek(xFilial("DE7") + SA1->(A1_COD + A1_LOJA)))
//		
//		RecLock("DE7", .T.)	
//		DE7->DE7_FILIAL := xFilial("DE7")	
//		DE7->DE7_CODCLI := SA1->A1_COD
//		SA1->A1_LOJA := SA1->A1_LOJA
//		MsUnLock() // Confirma e finaliza a operação
//		
//		cMsg  := "O Devedor do Frete ( " + Alltrim(SA1->(A1_COD + A1_LOJA)) + " - " + Alltrim(SA1->A1_NOME) + ") não possui Produto Predominante cadastrado"
//		cSolu := "Favor realizar o cadastro antes de selecionar a nota fiscal."
//		Help(NIL, NIL, "ValidChek", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
//		Return .f.
//	End If

	// Destinatario
	If VerifSA1(oModel,"2")
		cCodDES := SA1->A1_COD
		cLojDES := SA1->A1_LOJA
	Else
		Return .f.
	End if

	cCodCLI := IIF(oModelSZE:GetValue("ZE_DEVFRE") == "1",cCodREM,cCodDES)
	cLojCLI := IIF(oModelSZE:GetValue("ZE_DEVFRE") == "1",cLojREM,cLojDES)

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + cCodCLI + cLojCLI))


	// Verifica a exitencia do contrato e servico
	AAM->(DbSetOrder(2))
	If !AAM->(DbSeek(xFilial("AAM") + SA1->(A1_COD + A1_LOJA)))
		cMsg  := "O Devedor do Frete ( " + Alltrim(SA1->(A1_COD +A1_LOJA)) + " - " + Alltrim(SA1->A1_NOME) + ") não possui contrato de serviço."
		cSolu := "Favor realizar o cadastro antes de selecionar a nota fiscal."
		Help(NIL, NIL, "ValidChek", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

	// Verifica a existencia do perfil do cliente
	DUO->(DbSetOrder(1))
	If !DUO->(DbSeek(xFilial("DUO") + SA1->(A1_COD + A1_LOJA)))
		cMsg  := "O Devedor do Frete ( " + Alltrim(SA1->(A1_COD + A1_LOJA)) + " - " + Alltrim(SA1->A1_NOME) + ") não possui Perfil Cliente cadastrado"
		cSolu := "Favor realizar o cadastro antes de selecionar a nota fiscal."
		Help(NIL, NIL, "ValidChek", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If


Return lRet

/*/{Protheus.doc} VerifDA3
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VerifDA3()

	Local lRet 		:= .t.
	Local oModel 	:= FwModelActive()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local cCodVeic	:= oModelSZE:GetValue("ZE_PLACA")
	Local cMsg		:= ""
	Local cSolu		:= ""

	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(xFilial("DA3") + cCodVeic))

		// Verifica se existe o tipo cadastrado.
		If Empty(DA3->DA3_TIPVEI)
			cMsg  := "Esse veículo não possui tipo cadastrado e não poderá ser utilizado. Campo 'Tipo Veiculo'."
			cSolu := "Favor revisar o cadastro."
			Help(NIL, NIL, "VerifDA3", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End IF

		// Verifica se o veiculo e do tipo carreta
		DUT->(DbSetOrder(1))
		//DUT_FILIAL, DUT_TIPVEI, R_E_C_N_O_, D_E_L_E_T_
		If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))

			If DUT->DUT_CATVEI == "3"
				cMsg  := "Esse veículo é de categoria 'Carreta'. Só utilize veículos com outras categorias."
				cSolu := "Favor selecionar outro veículo."
				Help(NIL, NIL, "VerifDA3", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})			
				Return .f.
			End if

		Else
			Return .f.
		End If
	Else
		cMsg  := "Veículo não encontrado"
		cSolu := "Favor selecionar outro veículo."
		Help(NIL, NIL, "VerifDA3", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})			
		Return .f.
	End IF

Return lRet

/*/{Protheus.doc} VerifSA1
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param cTipo, characters, description
@type function
/*/
Static Function VerifSA1(oModel,cTipo)

	Local lRet 		:= .t. 
	local nRet		:= 0
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local cCNPJ  	:= ""
	Local cTexto    := ""
	Local cMsg		:= ""
	Local cSolu		:= ""
	Local oModelSA1 := Nil
	Local cCodRegiao := ""

	DUY->(DbSetOrder(6))

	If cTipo == "1"
		cCNPJ  	:= oModelSZE:GetValue("ZE_CGCREM")
		cTexto	:= "Remetente"
	ELse
		cCNPJ  	:= oModelSZE:GetValue("ZE_CGCDES")
		cTexto	:= "Destinatario"
	End If

	SA1->(DbSetOrder(3))

	If SA1->(DbSeek(xFilial("SA1") + cCNPJ))
		lRet := .T.
	Else

		cRazao 		:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_NOMREM") , oModelSZE:GetValue("ZE_NOMDES"))

		If !MSGYESNO( cTexto + " ( " + Alltrim(cRazao) +" ) não cadastrado como cliente, cadastrar agora?","Cadastro cliente" )
			Return .f.
		End If

		cRazao 		:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_NOMREM") , oModelSZE:GetValue("ZE_NOMDES"))
		cFantasia 	:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_FANREM") , oModelSZE:GetValue("ZE_FANDES"))
		cEndereco 	:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_ENDREM") , oModelSZE:GetValue("ZE_ENDDES"))
		cBairro 	:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_BAIREM") , oModelSZE:GetValue("ZE_BAIDES"))
		cUF			:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_UFREM")  , oModelSZE:GetValue("ZE_UFDES"))
		cMuncipio 	:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_MUNREM") , oModelSZE:GetValue("ZE_MUNDES"))
		cCodMun 	:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_CMUREM") , oModelSZE:GetValue("ZE_CMUDES"))
		cCEP		:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_CEPREM") , oModelSZE:GetValue("ZE_CEPDES"))
		cCodTel 	:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_FONREM") , oModelSZE:GetValue("ZE_FONDES"))
		cIE			:= IIF(cTipo == "1", oModelSZE:GetValue("ZE_IEREM")  , oModelSZE:GetValue("ZE_IEDES"))

		// Localiza a regiao do cliente
		If DUY->(DbSeek(xFilial("DUY") + cUF + Substr(cCodMun,3,TAMSX3("A1_COD_MUN")[1])))
			cCodRegiao := DUY->DUY_GRPVEN
		End IF
		
		cCNPJ := Alltrim(cCNPJ)
		
		SetFunName("MATA030")

		oModelSA1 := FWLoadModel("CRMA980")
		oModelSA1:SetOperation(MODEL_OPERATION_INSERT)
		oModelSA1:Activate()

		//oModelSA1:SetValue('SA1MASTER', 'A1_COD'  	  , GETSXENUM("SA1", "A1_COD"))
		oModelSA1:SetValue('SA1MASTER', 'A1_LOJA'    , "01")
		oModelSA1:SetValue('SA1MASTER', 'A1_PESSOA'  , IIF(LEN(cCNPJ) == 14, "J", "F"))
		oModelSA1:SetValue('SA1MASTER', 'A1_TIPO'    , "F")
		oModelSA1:SetValue('SA1MASTER', 'A1_CGC'     , cCNPJ)
		oModelSA1:SetValue('SA1MASTER', 'A1_NOME'    , Substr(cRazao,1,TAMSX3("A1_NOME")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_NREDUZ'  , Substr(cFantasia,1,TAMSX3("A1_NREDUZ")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_END'     , Substr(cEndereco,1,TAMSX3("A1_END")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_BAIRRO'  , Substr(cBairro,1,TAMSX3("A1_BAIRRO")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_EST'     , cUF)
		oModelSA1:SetValue('SA1MASTER', 'A1_MUN'     , Substr(cMuncipio,1,TAMSX3("A1_MUN")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_COD_MUN' ,Alltrim(Substr(cCodMun,3,TAMSX3("A1_COD_MUN")[1])))
		oModelSA1:SetValue('SA1MASTER', 'A1_CEP'     , Substr(cCEP,1,TAMSX3("A1_CEP")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_DDD'     , Substr(cCodTel,1,2))
		oModelSA1:SetValue('SA1MASTER', 'A1_TEL'     , Substr(cCodTel,3,TAMSX3("A1_TEL")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_INSCR'   , Substr(cIE,1,TAMSX3("A1_INSCR")[1]))
		oModelSA1:SetValue('SA1MASTER', 'A1_CDRDES'  , cCodRegiao) //
		oModelSA1:SetValue('SA1MASTER', 'A1_CODPAIS' , "01058")

		FWMsgRun(, {|| nRet := FWExecView("Cadastro",'CRMA980', MODEL_OPERATION_INSERT, , { || .T. } , ,30,,,,,oModelSA1)}, "Processando", "Carregando dados para o cadastro...")

		// Verifica se o usuario clicou em cancelar.
		If nRet == 1
			lRet := .f.
		End if 

		oModelSA1:DeActivate()
		oModelSA1:Destroy()
		oModelSA1 := Nil

		SetFunName("SERTMS05")

		FWModelActive(oModel,.t.)

	End if

	// Apresenta a mensagem ao usuario
	If !lRet	

		cMsg  := "Não foi possível encontrar o cadastro do cliente p/ o " + cTexto + " : " + cCNPJ
		cSolu := "Favor realizar o cadastro para selecionar a nota fiscal."
		Help(NIL, NIL, "VerifSA1", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
	End if

Return lRet

/*/{Protheus.doc} AltPlaca
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AltPlaca()

	Local cCodVei	:= Space(TamSX3("DA3_COD")[1])
	Local lRet		:= .t.
	Local aRet		:= {}
	Local aParamBox := {}

	aAdd(aParamBox, {1, "Veiculo", cCodVei,'','.T.','DA3','.T.',TAMSX3("DA3_COD")[1] * 5,.F.})

	lRet := ParamBox(aParamBox, "Informar Placa", aRet)

	If lRet
		FWMsgRun(, {|| AltSZE(aRet) }, "Processando", "Processando a atualização...")
	End If

Return

/*/{Protheus.doc} AltSZE
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param aRet, array, description
@type function
/*/
Static Function AltSZE(aRet)

	Local aSaveLines := FWSaveRows()
	Local oView 	:= FwViewActive()
	Local oModel	:= oView:GetModel()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local nTotReg	:= oModelSZE:Length()
	Local i			:= 1
	Local cCodVei	:= aRet[1]

	For i:= 1 to nTotReg

		oModelSZE:Goline(i)

		If Empty(oModelSZE:GetValue("ZE_PLACA"))
			oModelSZE:SetValue("ZE_PLACA",cCodVei)
		End if

	Next

	oView:Refresh()

	FWRestRows( aSaveLines )
Return

/*/{Protheus.doc} RatFrt
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function RatFrt(cCampo)

	Local aSaveLines := FWSaveRows()
	Local oMODEL		:= FwModelActive()
	Local oView			:= FwViewActive()
	Local oModelLote	:= oModel:GetModel("SZELOTE")
	Local oModelSZE		:= oModel:GetModel("SZEDETAIL")
	Local nTotReg		:= oModelSZE:Length()
	Local nTotValFrt	:= oModelLote:GetValue(cCampo)
	Local nTotPeso		:= oModelLote:GetValue("ZE_PESO")
	Local nTotQtdNf		:= oModelLote:GetValue("ZE_QTDNOTA")
	Local nValFrtNF		:= 0
	Local nValFrDIST	:= 0
	Local nCont			:= 0
	Local lRet			:= .t.
	Local i				:= 0


	If !MSGYESNO("Foi alterado o valor, sistema ira ratear o valor entre as notas fiscais utilizando o peso como critério. Deseja continuar?","Rateio Peso" )
		Return .f.
	End If

	For i:=1 to nTotReg

		oModelSZE:Goline(i)

		If oModelSZE:GetValue("ZE_MARK") .and. oModelSZE:GetValue("ZE_PLACA") == oModelLote:GetValue("ZE_PLACA")

			nCont++

			// Realiza o rateio do Frete
			nValFrtNF := round((oModelSZE:GetValue("ZE_PESO") / nTotPeso) * nTotValFrt,2)

			nValFrDIST += nValFrtNF

			If nTotQtdNf == nCont
				If nValFrDIST - nTotValFrt  > 0
					nValFrtNF += nTotValFrt - nValFrDIST
				End if 
			End if

			oModelSZE:SetValue(cCampo,nValFrtNF )

		End If

	Next

	FWRestRows( aSaveLines )
	oView:GetViewObj("SZEDETAIL")[3]:Refresh(.t.,.F.)
Return lRet

/*/{Protheus.doc} MarkAll
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0 
@return ${return}, ${return_description}

@type function
/*/
Static Function MarkAll()

	Local aSaveLines := FWSaveRows()
	Local oModel := FwModelActive()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local nTotReg	:= oModelSZE:Length()
	Local i			:= 0

	For i:= 1 to nTotReg

		oModelSZE:Goline(i)

		If !Empty(oModelSZE:GetValue("ZE_PLACA")) .and. !Empty(oModelSZE:GetValue("ZE_PESO")) .AND. !Empty(oModelSZE:GetValue("ZE_PESLIQ"))
			oModelSZE:SetValue("ZE_MARK",.t.)
		End IF

	Next

	FWRestRows( aSaveLines )
Return

/*/{Protheus.doc} DesMAll
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function DesMAll()

	Local aSaveLines := FWSaveRows()
	Local oModel := FwModelActive()
	Local oModelSZE := oModel:GetModel("SZEDETAIL")
	Local nTotReg	:= oModelSZE:Length()
	Local i			:= 0

	For i:= 1 to nTotReg

		oModelSZE:Goline(i)
		oModelSZE:SetValue("ZE_MARK",.F.)
	Next

	FWRestRows( aSaveLines )
Return
