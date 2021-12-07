#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} SERTMS02
Cadastro de formula
@type  Function
@author Totvs Vitoria - Mauricio Silva
@since 16/09/2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/ 
User Function SERTMS02()

	Local aArea   := GetArea()
	Local oBrowse

	//Instânciando FWMBrowse
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZ4")

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERTMS02")

	//Setando a descrição da rotina
	oBrowse:SetDescription("Cadastro Formula")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return

/*/{Protheus.doc} MenuDef
MenuDef
@type  Function
@author Totvs Vitoria
@since 16/09/2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

Static Function MenuDef()

	Local aRot := {}

	//Adicionando opções
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERTMS02"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERTMS02"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERTMS02"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERTMS02"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERTMS02"	,0,5,0,NIL})
   
Return aRot

/*/{Protheus.doc} ModelDef
MenuDef
@type  Function
@author Totvs Vitoriaria
@since 16/09/2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

Static Function ModelDef()

    // Criação do objeto do modelo de dados
    Local oModel  := Nil

    // Criação da estrutura de dados utilizada na interface
    Local oStSZ4   := FWFormStruct(1, "SZ4")
    Local oStSZ5   := FWFormStruct(1, "SZ5")
    Local oStSX2   := GetStrX2(1)
    Local oStSX3   := GetStrX3(1)
    Local bLoadSX2 := {|oGridModel, lCopy| LoadSX2(oGridModel, lCopy,oModel)}
    Local bLoadSX3 := {|oGridModel, lCopy| LoadSX3(oGridModel, lCopy,oModel)}
    Local bLinePost:= {|| LinOk(oModel)}    

    // Inicializador Padrão da sequencia.
	oStSZ5:SetProperty("Z5_SEQ", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "StaticCall(SERTMS02,NextSeq)"))
	oStSZ5:SetProperty("Z5_SEQ", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSX3:SetProperty( '*'    , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , '.F.' ))
	oStSX3:SetProperty( '*'    , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSX3:SetProperty( 'X3_CAMPO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
    // Cria o modelo
    oModel := MPFormModel():New("MSERTMS02",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

    // Atribuindo formulários para o modelo
    oModel:AddFields("SZ4MASTER",/*cOwner*/, oStSZ4)

    // Atribuindo Grid ao modelo
	oModel:AddGrid( "SZ5DETAIL", "SZ4MASTER",oStSZ5, /*[ bLinePre ]*/,bLinePost /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "SX2DETAIL", "SZ4MASTER",oStSX2, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, bLoadSX2/*[ bLoad ]*/)
	oModel:AddGrid( "SX3DETAIL", "SX2DETAIL",oStSX3, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, bLoadSX3/*[ bLoad ]*/)

    // Criando Relacionamentos
	oModel:SetRelation("SZ5DETAIL", {{"Z5_FILIAL","FwXFilial('SZ5')"}, {"Z5_NUM","Z4_NUM"} }, SZ5->( IndexKey( 1 ) ) )
	
	oModel:GetModel("SX2DETAIL"):SetOptional( .T. )
	oModel:GetModel("SX3DETAIL"):SetOptional( .T. )
	
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({})

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)
     
    oModel:GetModel("SZ5DETAIL"):SetUniqueLine({'Z5_CHAVE'})
    
    //Adicionando descrição ao modelo
    oModel:SetDescription("Cadastro de Fórmula")

	//Descricoes dos modelos de dados
    oModel:GetModel("SZ4MASTER"):SetDescription("Cadastro de Fórmula")
    oModel:GetModel("SZ5DETAIL"):SetDescription("Fórmulas Configuradas")
    oModel:GetModel("SX2DETAIL"):SetDescription("Tabelas Envolvidas")
    oModel:GetModel("SX3DETAIL"):SetDescription("Variaveis Envolvidas")

	oModel:GetModel("SX2DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SX2DETAIL"):SetNoInsertLine(.T.);oModel:GetModel("SX2DETAIL"):SetNoUpdateLine(.T.)  
	oModel:GetModel("SX3DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SX3DETAIL"):SetNoInsertLine(.T.)  

	oModel:SetActivate({|oModel|ActiveM(oModel)})
	
Return oModel

/*/{Protheus.doc} ActiveM
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function ActiveM(oModel)
	
	Local nOper  := oModel:GetOperation()
	
	If nOper == MODEL_OPERATION_INSERT
	
	oModel:GetModel("SX2DETAIL"):SetNoDeleteLine(.F.); oModel:GetModel("SX2DETAIL"):SetNoInsertLine(.F.);oModel:GetModel("SX2DETAIL"):SetNoUpdateLine(.F.)  
	oModel:GetModel("SX3DETAIL"):SetNoDeleteLine(.F.); oModel:GetModel("SX3DETAIL"):SetNoInsertLine(.F.) 
	
		LoadSX2(,,oModel,.t.)
		
	oModel:GetModel("SX2DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SX2DETAIL"):SetNoInsertLine(.T.);oModel:GetModel("SX2DETAIL"):SetNoUpdateLine(.T.)  
	oModel:GetModel("SX3DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SX3DETAIL"):SetNoInsertLine(.T.) 	
	End If

Return 

Static Function LinOk(oModel)

	Local lRet 		:= .t.
	Local oModelSZ5 := oModel:GetModel("SZ5DETAIL")
	Local nTotLin   := oModelSZ5:Length()
	Local cCodForm  := oModelSZ5:GetValue("Z5_CODFORM")
	Local cMsg		:= ""
	Local cSolu		:= ""
	Local cTipo		:= oModelSZ5:GetValue("Z5_TIPMOV")
	Local nLinha    := oModelSZ5:GetLine()
	
	If cTipo == "C" .AND. VAL(cCodForm) >= 500
		cMsg  := "Movimento Credito apenas aceita codigo inferiores a 500"
        cSolu := "Favor rever o codigo digitado"
        Help(NIL, NIL, "SERTMS02 - LinOk", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
        Return .f.
	ElseIf cTipo == "D" .AND. VAL(cCodForm) < 500
		cMsg  := "Movimento Debito apenas aceita codigo superiores a 499"
        cSolu := "Favor rever o codigo digitado"
        Help(NIL, NIL, "SERTMS02 - LinOk", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
        Return .f.
	End If
	
	// Nao deixa o usuario cadastrar uma formula para movimentos que deixam alterar valor
	// na tela de melhor frete.  Isso pode impactar no relatorio de custo, visto que o rateio
	// ficara incorreto
	If oModelSZ5:GetValue("Z5_DIGITA") == "S" .AND. Alltrim(oModelSZ5:GetValue("Z5_FORMULA")) <> "0"
		cMsg  := "Movimentos digitaveis não podem receber formulas diferente de '0' "
        cSolu := ""
        Help(NIL, NIL, "SERTMS02 - LinOk", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
        Return .f.	
	End If
	
	
	 For i:= 1 to nTotLin

        oModelSZ5:GoLine(i)
        
        If !oModelSZ5:IsDeleted() .and. nLinha <> i
        	
        	// Verifica se ja foi informado este codigo
        	If oModelSZ5:GetValue("Z5_CODFORM") == cCodForm
    			cMsg  := "Este codigo ja foi informado anteriormente (" + cCodForm + ")"
                cSolu := "Favor rever o codigo digitado"
                Help(NIL, NIL, "SERTMS02 - LinOk", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
                Return .f.
        	End If
        
        End If
        
     Next
Return lRet

/*/{Protheus.doc} LoadSX2
//TODO Descrição auto-gerada.
@author kenny.roger
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@param lLoad, logical, description
@type function
/*/
Static Function LoadSX2(oGridModel, lCopy,oModel,lLoad)
	
	Local aLoad := {} 
	Local aTab	:= {"DTQ","DTA","DT6","SF2"} 
	Local oModelSX2 := oModel:GetModel("SX2DETAIL")
	Local i := 0
	
	Default lLoad := .F.
	Default oGridModel := Nil
	Default lCopy := .f.
	
	For i:= 1 to len(aTab)
		aAdd(aLoad,{i,{aTab[i], FWX2Nome( aTab[i])}})
		
		If lLoad
			If !oModelSX2:IsEmpty()
				oModelSX2:AddLine()
			End If 
			oModelSX2:LoadValue("X2_ARQUIVO", aTab[i])
			oModelSX2:LoadValue("X2_NOME"   , SUBSTR(FWX2Nome( aTab[i]),1,25))
			
			LoadSX3(,,oModel,.T.)
		End iF 
		
	next
	
Return aLoad

/*/{Protheus.doc} LoadSX3
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@param lLoad, logical, description
@type function
/*/
Static Function LoadSX3(oGridModel, lCopy,oModel,lLoad)
	Local aLoad	 	:= {} 
	Local oModelSX2 := oModel:GetModel("SX2DETAIL")
	Local oModelSX3 := oModel:GetModel("SX3DETAIL")
	Local cAlias	:= oModelSX2:GetValue("X2_ARQUIVO")
	Local
	Local aCampo	:= FWSX3Util():GetAllFields( cAlias , .F. ) 
	Local cTipo		:= ""
	Local i			:= 0
	
	Default lLoad := .F.
	Default oGridModel := Nil
	Default lCopy := .f.
	
	For i:= 1 to len(aCampo)
		
		cTipo := FWSX3Util():GetFieldType(aCampo[i])

		aAdd(aLoad,{i,{cAlias,cAlias +"->" +  aCampo[i],FWSX3Util():GetDescription( aCampo[i] ), cTipo }})

		If lLoad
			If !oModelSX3:IsEmpty()
				oModelSX3:AddLine()
			End If 
			oModelSX3:LoadValue("X3_ARQUIVO", cAlias)
			oModelSX3:LoadValue("X3_CAMPO"  , cAlias +"->" +  aCampo[i])
			oModelSX3:LoadValue("X3_DESCRIC", SUBSTR(FWSX3Util():GetDescription( aCampo[i] ),1,25))
			oModelSX3:LoadValue("X3_TIPO"   , cTipo)
		End iF 

	next

Return aLoad


/*/{Protheus.doc} ViewDef
MenuDef
@type  Function
@author Totvs Vitoriaria
@since 16/09/2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

Static Function ViewDef()

    // Recupera o modelo de dados
    Local oModel := FWLoadModel("SERTMS02")
    //Criação da estrutura de dados da View
    Local oStSZ4   := FWFormStruct(2, "SZ4")
	Local oStSZ5   := FWFormStruct(2, "SZ5")
	Local oView := Nil
    Local oStSX2   := GetStrX2(2)
    Local oStSX3   := GetStrX3(2)
    
	// Remove os campos de ligação
    oStSZ5:RemoveField("Z5_NUM")
    
    oStSZ5:SetProperty( "Z5_DESCRIC", MVC_VIEW_WIDTH, 250 )
    oStSZ5:SetProperty( "Z5_FORMULA", MVC_VIEW_WIDTH, 250 )
    oStSX3:SetProperty( "X3_DESCRIC", MVC_VIEW_WIDTH, 150 )

	//Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()

	//Seta o modelo
    oView:SetModel(oModel)

    //Atribuindo fomulários para interface
    oView:AddField("VIEW_SZ4"    , oStSZ4   , "SZ4MASTER")
    oView:AddGrid( "VIEW_SZ5"    , oStSZ5	, "SZ5DETAIL") 
    oView:AddGrid( "VIEW_SX2"    , oStSX2	, "SX2DETAIL") 
    oView:AddGrid( "VIEW_SX3"    , oStSX3	, "SX3DETAIL") 


	//Criando os paineis
    oView:CreateHorizontalBox("SUPERIOR", 020)
	oView:CreateHorizontalBox("INFERIOR", 080)
	
	oView:CreateVerticalBox( "ESQUERDA" , 032, "INFERIOR")
	oView:CreateVerticalBox( "DIRETA"   , 068, "INFERIOR")	
	
	oView:CreateHorizontalBox("SUP_ESQUERDA", 040,"ESQUERDA")
	oView:CreateHorizontalBox("INF_ESQUERDA", 060,"ESQUERDA")
	
	//Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZ4","SUPERIOR")
    oView:SetOwnerView("VIEW_SX2","SUP_ESQUERDA")
    oView:SetOwnerView("VIEW_SX3","INF_ESQUERDA")
    oView:SetOwnerView("VIEW_SZ5","DIRETA")

	//Adicionado Descrições
	oView:EnableTitleView("VIEW_SZ4"    , "Dados da tabela" )
	oView:EnableTitleView("VIEW_SX2"    , "Tabelas Envolvidas" )
	oView:EnableTitleView("VIEW_SX3"    , "Variaveis" )
	oView:EnableTitleView("VIEW_SZ5"    , "Fórmulas Configuradas" )

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

Return oView



/*/{Protheus.doc} NextSeq
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function NextSeq()

	Local oModel := FwModelActive()
	Local oModelSZ5 := oModel:GetModel("SZ5DETAIL")
	Local nRegist   := oModelSZ5:Length()
	Local cProxNum  := ""
	Local nLinha	:= 0 

	If nRegist == 0 
		cProxNum := PadL("1",TamSx3("Z5_SEQ")[1],"0")
	Else 
		oModelSZ5:GoLine(nRegist)
		cProxNum := SOMA1(oModelSZ5:GetValue("Z5_SEQ"))
		oModelSZ5:GoLine(nLinha)
	End If 
Return cProxNum



/*/{Protheus.doc} GetStrX2
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, description
@type function
/*/
Static function GetStrX2(nTipo)

	Local oStr := Nil
	
	If nTipo == 1
		
		oStr := FWFormModelStruct():New()

	    oStr:AddField("Tabela" ,;																// [01] Titulo do campo 		
	                    "Tabela.",;														    	// [02] ToolTip do campo 	
	                    "X2_ARQUIVO",;															// [03] Id do Field
	                    "C"	,;																	// [04] Tipo do campo
	                    3,;																		// [05] Tamanho do campo
	                    0,;																		// [06] Decimal do campo
	                    FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ),;  						// [07] Code-block de validação do campo
	                    FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.' )	,;							// [08] Code-block de validação When do campo
	                    ,;																		// [09] Lista de valores permitido do campo
	                    .F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
	                    FwBuildFeature(STRUCT_FEATURE_INIPAD, '' ),;	                        // [11] Inicializador Padrão do campo
	                    ,; 																		// [12] 
	                    ,; 																		// [13] 
	                    .T.	) 																	// [14] Virtual	
	
	    oStr:AddField("Descricao" ,;															// [01] Titulo do campo 		
	                    "Descricao",;														    // [02] ToolTip do campo 	
	                    "X2_NOME",;																// [03] Id do Field
	                    "C"	,;																	// [04] Tipo do campo
	                    25,;																	// [05] Tamanho do campo
	                    0,;																		// [06] Decimal do campo
	                    FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ),;  						// [07] Code-block de validação do campo
	                    FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.' )	,;							// [08] Code-block de validação When do campo
	                    ,;																		// [09] Lista de valores permitido do campo
	                    .F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
	                    FwBuildFeature(STRUCT_FEATURE_INIPAD, '' ),;	                        // [11] Inicializador Padrão do campo
	                    ,; 																		// [12] 
	                    ,; 																		// [13] 
	                    .T.	) 																	// [14] Virtual	                
   Else 
   		
   		  oStr := FWFormViewStruct():New()
   			
	      oStr:AddField("X2_ARQUIVO",; //Id do Campo
	                    "01",; //Ordem
	                    "Tabela",;// Título do Campo
	                    "Tabela",; //Descrição do Campo
	                    {},; //aHelp
	                    "C")
 
 	      oStr:AddField("X2_NOME",; //Id do Campo
	                    "02",; //Ordem
	                    "Descricao",;// Título do Campo
	                    "Descricao",; //Descrição do Campo
	                    {},; //aHelp
	                    "C")
   End If 

return oStr

/*/{Protheus.doc} GetStrX3
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, description
@type function
/*/
Static function GetStrX3(nTipo)

	Local oStr := Nil
	
	If nTipo == 1
		
		oStr := FWFormModelStruct():New()

	    oStr:AddField("Tabela" ,;																// [01] Titulo do campo 		
	                    "Tabela",;														    	// [02] ToolTip do campo 	
	                    "X3_ARQUIVO",;															// [03] Id do Field
	                    "C"	,;																	// [04] Tipo do campo
	                    03,;																	// [05] Tamanho do campo
	                    0,;																		// [06] Decimal do campo
	                    FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ),;  						// [07] Code-block de validação do campo
	                    FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.' )	,;							// [08] Code-block de validação When do campo
	                    ,;																		// [09] Lista de valores permitido do campo
	                    .F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
	                    FwBuildFeature(STRUCT_FEATURE_INIPAD, '' ),;	                        // [11] Inicializador Padrão do campo
	                    ,; 																		// [12] 
	                    ,; 																		// [13] 
	                    .T.	) 		

	    oStr:AddField("Variavel" ,;																// [01] Titulo do campo 		
	                    "Variavel",;														    	// [02] ToolTip do campo 	
	                    "X3_CAMPO",;															// [03] Id do Field
	                    "C"	,;																	// [04] Tipo do campo
	                    15,;																	// [05] Tamanho do campo
	                    0,;																		// [06] Decimal do campo
	                    FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ),;  						// [07] Code-block de validação do campo
	                    FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.' )	,;							// [08] Code-block de validação When do campo
	                    ,;																		// [09] Lista de valores permitido do campo
	                    .F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
	                    FwBuildFeature(STRUCT_FEATURE_INIPAD, '' ),;	                        // [11] Inicializador Padrão do campo
	                    ,; 																		// [12] 
	                    ,; 																		// [13] 
	                    .T.	) 																	// [14] Virtual	
	
	    oStr:AddField("Descricao" ,;															// [01] Titulo do campo 		
	                    "Descricao",;														    // [02] ToolTip do campo 	
	                    "X3_DESCRIC",;															// [03] Id do Field
	                    "C"	,;																	// [04] Tipo do campo
	                    25,;																	// [05] Tamanho do campo
	                    0,;																		// [06] Decimal do campo
	                    FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ),;  						// [07] Code-block de validação do campo
	                    FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.' )	,;							// [08] Code-block de validação When do campo
	                    ,;																		// [09] Lista de valores permitido do campo
	                    .F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
	                    FwBuildFeature(STRUCT_FEATURE_INIPAD, '' ),;	                        // [11] Inicializador Padrão do campo
	                    ,; 																		// [12] 
	                    ,; 																		// [13] 
	                    .T.	) 																	// [14] Virtual	                
 
 	    oStr:AddField("Tipo" ,;																	// [01] Titulo do campo 		
	                    "Tipo",;														        // [02] ToolTip do campo 	
	                    "X3_TIPO",;															    // [03] Id do Field
	                    "C"	,;																	// [04] Tipo do campo
	                    1,;																		// [05] Tamanho do campo
	                    0,;																		// [06] Decimal do campo
	                    FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ),;  						// [07] Code-block de validação do campo
	                    FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.' )	,;							// [08] Code-block de validação When do campo
	                    ,;																		// [09] Lista de valores permitido do campo
	                    .F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
	                    FwBuildFeature(STRUCT_FEATURE_INIPAD, '' ),;	                        // [11] Inicializador Padrão do campo
	                    ,; 																		// [12] 
	                    ,; 																		// [13] 
	                    .T.	) 																	// [14] Virtual	   
 
   Else 
      oStr := FWFormViewStruct():New()
      
      oStr:AddField("X3_CAMPO",; //Id do Campo
                    "01",; //Ordem
                    "Variavel",;// Título do Campo
                    "Variavel",; //Descrição do Campo
                    {},; //aHelp
                    "C")
 
      oStr:AddField("X3_DESCRIC",; //Id do Campo
                "02",; //Ordem
                "Descricao",;// Título do Campo
                "Descricao",; //Descrição do Campo
                {},; //aHelp
                "C")
                    
      oStr:AddField("X3_TIPO",; //Id do Campo
                "03",; //Ordem
                "Tipo",;// Título do Campo
                "Tipo",; //Descrição do Campo
                {},; //aHelp
                "C")
   End If 

return oStr

