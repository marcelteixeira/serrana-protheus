#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

    // Criação do objeto do modelo de dados
    Local oModel  := Nil

    // Criação da estrutura de dados utilizada na interface
    Local oStCN9   := FWFormStruct(1, "CN9")
    Local oStCNA   := FWFormStruct(1, "CNA")
    Local oStCNB   := FWFormStruct(1, "CNB")
    Local oStSZG   := FWFormStruct(1, "SZG")
    Local oStSZH   := FWFormStruct(1, "SZH")
    Local oStSZI   := FWFormStruct(1, "SZI")
    Local bLoadDADOS := {|oFieldModel, lCopy| loadField(oFieldModel, lCopy)}
    Local bCommit  := {|oModel| Commit(oModel)}  
	Local bPos	   := {|oModel| TdOkModel(oModel)}

	oStCNA:AddField("" ,;															// [01] Titulo do campo 
					"",;														    // [02] ToolTip do campo 	
					"CNA_BUDGET",;												// [03] Id do Field
					"C"	,;															// [04] Tipo do campo
					30,;															// [05] Tamanho do campo
					0,;																// [06] Decimal do campo
					{ || .T. }	,;													// [07] Code-block de validação do campo
					{ || .F. }	,;													// [08] Code-block de validação When do campo
					,;																// [09] Lista de valores permitido do campo
					.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
					{ || "BUDGET"},;	                                            // [11] Inicializador Padrão do campo
					,; 																// [12] 
					,; 																// [13] 
					.T.	) 															// [14] Virtual
					
	oStSZG:AddField("" ,;															// [01] Titulo do campo 
					"",;														    // [02] ToolTip do campo 	
					"ZH_YPERSON",;													// [03] Id do Field
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
					.T.	) 															// [14] Virtual													// [14] Virtual 
      
    // Cria o modelo
    oModel := MPFormModel():New("MSERGCT01",/*bPre*/, bPos,bCommit,/*bCancel*/) 
    
    oStCN9:SetProperty( "*" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , ".F." ))
	oStCNA:SetProperty( "*" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , ".F." )) 
	oStCNB:SetProperty( "*" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , ".F." )) 
     
   	oStSZH:SetProperty( 'ZH_VLUNIT', MODEL_FIELD_VALID , FwBuildFeature(STRUCT_FEATURE_VALID  , 'StaticCall(SERGCT01,VldVlr)'))
          
    // Atribuindo formulários para o modelo
    oModel:AddFields("CN9MASTER",/*cOwner*/, oStCN9) 
    oModel:AddGrid("CNADETAIL","CN9MASTER",oStCNA,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
    oModel:AddGrid("CNBDETAIL","CNADETAIL",oStCNB,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
    oModel:AddGrid("SZGDETAIL","CNADETAIL",oStSZG,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
    oModel:AddGrid("SZIDETAIL","CNADETAIL",oStSZI,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
    oModel:AddGrid("SZHDETAIL","SZGDETAIL",oStSZH,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
        
    oModel:SetRelation("CNADETAIL",{{"CNA_FILIAL","xFilial('CNA')"},{"CNA_CONTRA","CN9_NUMERO"},{"CNA_REVISA","CN9_REVISA"}},CNA->(IndexKey(1)))
    oModel:SetRelation("CNBDETAIL",{{"CNB_FILIAL","xFilial('CNB')"},{"CNB_CONTRA","CN9_NUMERO"},{"CNB_REVISA","CN9_REVISA"},{"CNB_NUMERO","CNA_NUMERO"}},CNB->(IndexKey(1)))
    oModel:SetRelation("SZGDETAIL",{{"ZG_FILIAL","xFilial('SZG')"} ,{"ZG_CONTRA","CN9_NUMERO"},{"ZG_REVISA","CN9_REVISA"},{"ZG_NUMERO","CNA_NUMERO"}},SZG->(IndexKey(1)))
    oModel:SetRelation("SZIDETAIL",{{"ZI_FILIAL","xFilial('SZI')"} ,{"ZI_CONTRA","CN9_NUMERO"},{"ZI_REVISA","CN9_REVISA"},{"ZI_NUMERO","CNA_NUMERO"}},SZI->(IndexKey(1)))
    oModel:SetRelation("SZHDETAIL",{{"ZH_FILIAL","xFilial('SZH')"} ,{"ZH_CONTRA","CN9_NUMERO"},{"ZH_REVISA","CN9_REVISA"},{"ZH_NUMERO","CNA_NUMERO"},{"ZH_FORNECE","ZG_FORNECE"},{"ZH_LOJFORN","ZG_LOJFORN"}},SZH->(IndexKey(1)))
             
    oModel:GetModel( "SZGDETAIL" ):SetUniqueLine( { "ZG_FORNECE" , "ZG_LOJFORN"} )  
        
    oModel:AddCalc("CALC_TX"	,"CNADETAIL" ,"SZIDETAIL","ZI_PORTAXA"	,"ZI_PORTAXA_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"% Total"   ,/*bFormula*/,TAMSX3("ZI_PORTAXA")[1] /*nTamanho*/,TAMSX3("ZI_PORTAXA")[2] /*nDecimal*/)
     
	oModel:GetModel("CN9MASTER"):SetOnlyQuery(.T.)   
     
    oModel:GetModel("CNADETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("CNADETAIL"):SetNoInsertLine(.T.) 
    oModel:GetModel("CNBDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("CNBDETAIL"):SetNoInsertLine(.T.)
    oModel:GetModel("SZHDETAIL"):SetNoInsertLine(.T.)
                                        
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({})

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)
	
	oModel:GetModel("CN9MASTER"):SetOnlyQuery(.T.)
	oModel:GetModel("CNBDETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("CNADETAIL"):SetOnlyQuery(.T.)
	
	oModel:GetModel( "SZIDETAIL" ):SetOptional( .T. )
    
    //Adicionando descrição ao modelo
    oModel:SetDescription("Contrato Venda")
    
	//Descricoes dos modelos de dados
    oModel:GetModel("CN9MASTER"):SetDescription("Dados do Contrato")
    
    oModel:lModify := .t. 
    
    oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )
    
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

    // Recupera o modelo de dados
    Local oModel := FWLoadModel("SERGCT01")
    Local cFieCNA := "CNA_BUDGET,CNA_NUMERO,CNA_REVISA,CNA_CLIENT,CNA_LOJACL,CNA_YNOMCL,CNA_DTINI,CNA_DTFIM,CNA_VLTOT,CNA_SALDO,CNA_DESCRI"
	Local aFieCNA := StrTokArr(cFieCNA,",")
 
    Local cFieCNB := "CNB_ITEM,CNB_PRODUT,CNB_DESCRI,CNB_UM,CNB_QUANT,CNB_VLUNIT,CNB_VLTOT"
	Local aFieCNB := StrTokArr(cFieCNB,",")
	   
    //Criação da estrutura de dados da View
    Local oStCN9 := FWFormStruct(2, "CN9")
    Local oStCNA := FWFormStruct(2, "CNA",{ |x| ALLTRIM(x) $ cFieCNA })
    Local oStCNB := FWFormStruct(2, "CNB",{ |x| ALLTRIM(x) $ cFieCNB })
    Local oStSZG := FWFormStruct(2, "SZG")
    Local oStSZH := FWFormStruct(2, "SZH")
    Local oStSZI := FWFormStruct(2, "SZI")
    Local oCalTX := FWCalcStruct(oModel:GetModel("CALC_TX"))
	Local oView  := Nil
	Local i		 := 0
	
	oStCNA:AddField("CNA_BUDGET",; //Id do Campo 
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture  

	
	oStSZG:AddField("ZH_YPERSON",; //Id do Campo 
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo	
	"@BMP"  )//cPicture  
		
	SetKey( VK_F4 , {|| CargaTX()} )
	SetKey( VK_F5 , {|| CargaProd()} )

	// Refaz a ordem
	For i := 1 To Len(aFieCNA)
		If i < 10
			oStCNA:SetProperty( aFieCNA[i], MVC_VIEW_ORDEM, "0" + Alltrim(STR(i)))
		Else
			oStCNA:SetProperty( aFieCNA[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next

	For i := 1 To Len(aFieCNB)
		If i < 10
			oStCNB:SetProperty( aFieCNB[i], MVC_VIEW_ORDEM, "0" + Alltrim(STR(i)))
		Else
			oStCNB:SetProperty( aFieCNB[i], MVC_VIEW_ORDEM, Alltrim(STR(i)))
		EndIf
	Next
	
	oStCNB:RemoveField("CNB_DESC")
	oStSZG:RemoveField("ZG_CONTRA");oStSZG:RemoveField("ZG_REVISA") ; oStSZG:RemoveField("ZG_NUMERO")
	oStSZI:RemoveField("ZI_CONTRA");oStSZI:RemoveField("ZI_REVISA") ; oStSZI:RemoveField("ZI_NUMERO")
	oStSZH:RemoveField("ZH_CONTRA");oStSZH:RemoveField("ZH_REVISA"); oStSZH:RemoveField("ZH_NUMERO"); oStSZH:RemoveField("ZH_FORNECE");oStSZH:RemoveField("ZH_LOJFORN")

	oStCNA:SetProperty( "CNA_YNOMCL" , MVC_VIEW_WIDTH, 200 )
	oStCNA:SetProperty( "CNA_VLTOT"  , MVC_VIEW_WIDTH, 100 )
	oStCNA:SetProperty( "CNA_SALDO"  , MVC_VIEW_WIDTH, 100 )
	
	//Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()

	//Seta o modelo
    oView:SetModel(oModel)

    //Atribuindo fomulários para interface
   // oView:AddField("VIEW_DADOS" , oStDADOS , "DADOS")
    oView:AddGrid("VIEW_CNA"  , oStCNA , "CNADETAIL")
    oView:AddGrid("VIEW_CNB"  , oStCNB , "CNBDETAIL")
    oView:AddGrid("VIEW_SZG"  , oStSZG , "SZGDETAIL")
    oView:AddGrid("VIEW_SZI"  , oStSZI , "SZIDETAIL")
    oView:AddGrid("VIEW_SZH"  , oStSZH , "SZHDETAIL")
    oView:AddField("VIEW_CAL" , oCalTX , "CALC_TX")
    
    //Autoincremento
    oView:addIncrementField("VIEW_SZI", "ZI_SEQUENC")
    
	//Criando os paineis
    oView:CreateHorizontalBox("PLANILHA",020)
    oView:CreateHorizontalBox("INFERIOR",080)
    
    oView:CreateFolder("FLDINF","INFERIOR")
    
    oView:AddSheet("FLDINF","GRDTAXA","Taxas dedutivas")		
    	oView:CreateHorizontalBox("BOXTAXA",080,/*owner*/,/*lUsePixel*/,"FLDINF","GRDTAXA")
    	oView:CreateHorizontalBox("BOXTCAL",020,/*owner*/,/*lUsePixel*/,"FLDINF","GRDTAXA")
    
    oView:AddSheet("FLDINF","GRDITEM","Itens do contrato")		
    	oView:CreateHorizontalBox("BOXITEM",100,/*owner*/,/*lUsePixel*/,"FLDINF","GRDITEM")
    	
    oView:AddSheet("FLDINF","GRDFORN","Prestadores Serviços")		
    	oView:CreateHorizontalBox("BOXFORN",040,/*owner*/,/*lUsePixel*/,"FLDINF","GRDFORN")
    	oView:CreateHorizontalBox("BOXITFO",060,/*owner*/,/*lUsePixel*/,"FLDINF","GRDFORN")
    		oView:CreateFolder("FLDFOR","BOXITFO")
    			 oView:AddSheet("FLDFOR","GRDITFO","Itens x Prestadores")
    			 	oView:CreateHorizontalBox("ITEMXFO",100,/*owner*/,/*lUsePixel*/,"FLDFOR","GRDITFO")
  
	//Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
       
	//O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_CNA","PLANILHA")
    oView:SetOwnerView("VIEW_SZI","BOXTAXA")
    oView:SetOwnerView("VIEW_CNB","BOXITEM")
    oView:SetOwnerView("VIEW_SZG","BOXFORN")
    oView:SetOwnerView("VIEW_SZH","ITEMXFO")
    oView:SetOwnerView("VIEW_CAL","BOXTCAL")
    
   // oView:EnableTitleView("VIEW_CN9" , "Dados do Contrato" )
    oView:EnableTitleView("VIEW_CNA" 	, "Planilhas" )
 
	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)
	
	oView:AddUserButton("F4 - Carregar Taxas","MAGIC_BMP",{|| CargaTX()},"Comentário do botão")  
	oView:AddUserButton("F5 - Carregar Itens","MAGIC_BMP",{|| CargaProd()},"Comentário do botão")
	
	oView:setUpdateMessage("Contrato de Compra", "Criado com sucesso!!")
	
	// Inicia o valor do frete combinado igual ao valor do frete ideal
	oView:SetAfterViewActivate({|| CargaTX()})
	
Return oView

/*/{Protheus.doc} TdOkModel
TudoOK do modelo de dados
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function TdOkModel(oModel)

	Local lRet	:= .t.
	Local oModelSZG := oModel:GetModel("SZGDETAIL")
	Local nOperation := oModel:GetOperation()
	
	// Se for operacao de exclusao, retorna verdadeiro
	If nOperation == MODEL_OPERATION_DELETE
		Return .t.
	End if

	If oModelSZG:IsEmpty()
		cMsg  := "Os prestadores não foram informados."
		cSolu := "Favor informar antes de continuar."
		Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End if

	If !MSGYESNO("Deseja criar o contrato de compra?", "Geração Contrato" )
		cMsg  := "Processo cancelado pelo usuario"
		cSolu := ""
		Help(NIL, NIL, "TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If
	
Return lRet

/*/{Protheus.doc} ValidActv
Validacao na ativacao do modelo de dados
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function ValidActv(oModel)

	Local lRet	:= .t.
	Local nOperation := oModel:GetOperation()
	
	// Se for operacao de exclusao, retorna verdadeiro
	If nOperation == MODEL_OPERATION_DELETE
		Return .t.
	End if
		
	CN1->(DbSetOrder(1))
	//CN1_FILIAL, CN1_CODIGO, CN1_ESPCTR, R_E_C_N_O_, D_E_L_E_T_
	If CN1->(DbSeek(xFilial("CN1") + CN9->CN9_TPCTO))	
		
		// Contrato Venda
		If Alltrim(CN1->CN1_ESPCTR) <> '2'
			cMsg  := "Apenas contratos do tipo VENDA pode ser informado prestadores de serviço."
			cSolu := "Favor selecionar outro contrato."
			Help(NIL, NIL, "SERGCT01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End if
		
		If Empty(CN1->CN1_YTPCOM)
			cMsg  := "O Tipo de contrato de VENDA não possui o tipo do contrato de COMPRA atrelado."
			cSolu := "Favor revisar o tipo do contrato e preencher o tipo de compra."
			Help(NIL, NIL, "SERGCT01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.		
		End if
	End if
	
	// Verifica se ja existe um contrato vinculado.
	If !Empty(CN9->CN9_YCONTR)

		cMsg  := "Este contrato de VENDA ja possui o contrato de COMPRA: " + Alltrim(CN9->CN9_YCONTR)
		cSolu := "Favor estornar ou escolher um outro contrato."
		Help(NIL, NIL, "SERGCT01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End if

	// Apenas pode gerar contrato de compra se o contrato de venda
	// estiver como virgente.
	If Alltrim(CN9->CN9_SITUAC) != "05"
		cMsg  := "Este contrato de VENDA não se encontra com status VIRGENTE."
		cSolu := "Favor alterar o status para criar o contrato de compra."
		Help(NIL, NIL, "SERGCT01 - ValidActv", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End if	


Return lRet


/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function Commit(oModel)

	Local lRet 		:= .t.
	Local oModelCNT := Nil
	Local oModelCN9	:= oModel:GetModel("CN9MASTER")
	Local oModelCNA	:= oModel:GetModel("CNADETAIL")
	Local oModelCNB := oModel:GetModel("CNBDETAIL")
	Local oModelSZH	:= oModel:GetModel("SZHDETAIL")
	Local oModelSZG := oModel:GetModel("SZGDETAIL")
	Local i			:= 0
	Local y 		:= 0
	Local nTotReg	:= oModelSZG:Length()
	Local nTotSZH	:= 0
	Local nPlan		:= 0
	Local cPlan		:= ""
	Local nItem		:= 0
	Local cItem		:= ""
	Local nRet		:= 0
	Local lRet		:= .t.
	Local cCodTPCTO	:= oModelCN9:GetValue("CN9_TPCTO")
	Local cCodCTOTP := ""

	CN1->(DbSetOrder(1))
	//CN1_FILIAL, CN1_CODIGO, CN1_ESPCTR, R_E_C_N_O_, D_E_L_E_T_
	If CN1->(DbSeek(xFilial("CN1") + cCodTPCTO))	
		
		If Empty(CN1->CN1_YTPCOM)
			cMsg  := "O Tipo de contrato de VENDA não possui o tipo do contrato de COMPRA atrelado."
			cSolu := "Favor revisar o tipo do contrato e preencher o tipo de compra."
			Help(NIL, NIL, "SERGCT01 - Commit", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.		
		End if
		
		cCodCTOTP := CN1->CN1_YTPCOM
	End if

	BEGIN TRANSACTION
	
		lRet := FwFormcommit(oModel)
		
		// Chama a funcao para validar campos
		// obrigatorios do contrato de compras
		CNTSetFun("CNTA300")
		
		oModelCNT := FWLoadModel("CNTA300") //Carrega o modelo
		oModelCNT:SetOperation(MODEL_OPERATION_INSERT) // Seta operação de inclusão
		oModelCNT:Activate() // Ativa o Modelo

		CN9->(Reclock("CN9",.F.))
			CN9->CN9_YCONTR := oModelCNT:GetModel("CN9MASTER"):GetValue("CN9_NUMERO")
		MsUnLock()

		//Cabeçalho do contrato
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'    , 'CN9_ESPCTR'  , "1")
		End if
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'   , 'CN9_TPCTO'   , cCodCTOTP)
		End if
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'    , 'CN9_DTINIC'  , oModelCN9:GetValue("CN9_DTINIC"))
		End if
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'    , 'CN9_UNVIGE'  , oModelCN9:GetValue("CN9_UNVIGE"))
		End if
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'    , 'CN9_VIGE'    , oModelCN9:GetValue("CN9_VIGE"))
		End if
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'    , 'CN9_MOEDA'   , oModelCN9:GetValue("CN9_MOEDA"))
		End if
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'    , 'CN9_CONDPG'  , oModelCN9:GetValue("CN9_CONDPG"))
		End if
		
		If lRet
			lRet := oModelCNT:SetValue( 'CN9MASTER'   , 'CN9_DESCRI'   , oModelCN9:GetValue("CN9_DESCRI"))
		End if

		If lRet
		
			For i:= 1 to  nTotReg
			
				oModelSZG:Goline(i)
				
				// Verifica se esta deletado 
				If oModelSZG:IsDeleted()
					Loop
				End if
				
				// Linha para receber o fornecedor
				If !oModelCNT:GetModel("CNCDETAIL"):IsEmpty()
					oModelCNT:GetModel("CNCDETAIL"):AddLine()
				End if
				
				//Insere os fornecedores
				If lRet
					lRet := oModelCNT:SetValue( 'CNCDETAIL'    , 'CNC_CODIGO'  , oModelSZG:GetValue("ZG_FORNECE"))
				End if
				
				If lRet
					lRet := oModelCNT:SetValue( 'CNCDETAIL'    , 'CNC_LOJA'    , oModelSZG:GetValue("ZG_LOJFORN"))
				End if
				
				// Adiciona Planilha
				If !oModelCNT:GetModel("CNADETAIL"):IsEmpty()
					oModelCNT:GetModel("CNADETAIL"):AddLine()
				End if
				
				// Recupera o numero da planilha
				nPlan := oModelCNT:GetModel("CNADETAIL"):Length() 
				cPlan := strzero(nPlan,TamSX3("CNA_NUMERO")[1])
				
				//Planilhas do Contrato
				If lRet
					lRet := oModelCNT:LoadValue( 'CNADETAIL' 	 , 'CNA_CONTRA'  , oModelCNT:GetModel("CN9MASTER"):GetValue("CN9_NUMERO"))
				End If
				
				If lRet
					lRet := oModelCNT:SetValue(  'CNADETAIL'     , 'CNA_NUMERO'  , cPlan)
				End if
				
				If lRet
					lRet := oModelCNT:SetValue(  'CNADETAIL'     , 'CNA_FORNEC'  , oModelSZG:GetValue("ZG_FORNECE"))
				End if
				
				If lRet
					lRet := oModelCNT:SetValue(  'CNADETAIL'     , 'CNA_LJFORN'  , oModelSZG:GetValue("ZG_LOJFORN"))
				End if
				
				If lRet
					lRet := oModelCNT:SetValue(  'CNADETAIL'     , 'CNA_TIPPLA'  , oModelCNA:GetValue("CNA_TIPPLA"))
				End if
				
				nTotSZH := oModelSZH:Length()
				
				For y := 1 to nTotSZH
					
					oModelSZH:GoLine(y)
					
					// Verifica se esta deletado 
					If oModelSZH:IsDeleted()
						Loop
					End if
					
					If !oModelCNT:GetModel('CNBDETAIL'):IsEmpty()
						oModelCNT:GetModel('CNBDETAIL'):AddLine()
					End if
					
					nItem := oModelCNT:GetModel("CNBDETAIL"):Length() 
					cItem := strzero(nItem,TamSX3("CNB_ITEM")[1])
						
					//Itens da Planilha do Contrato
					If lRet
						lRet := oModelCNT:SetValue( 'CNBDETAIL'    , 'CNB_ITEM'    , cItem)
					End if
					
					If lRet
						lRet := oModelCNT:SetValue( 'CNBDETAIL'    , 'CNB_PRODUT'  , oModelSZH:GetValue("ZH_PRODUT"))
					End IF
					
					If lRet
						lRet := oModelCNT:SetValue( 'CNBDETAIL'    , 'CNB_QUANT'   , oModelSZH:GetValue("ZH_QUANT"))
					End iF
					
					If lRet
						lRet := oModelCNT:SetValue( 'CNBDETAIL'    , 'CNB_VLUNIT'  , oModelSZH:GetValue("ZH_VLUNIT"))
					End if
					
					If lRet
						lRet := oModelCNT:SetValue( 'CNBDETAIL'    , 'CNB_PEDTIT'  , '2') // Titulos
					End if
				Next
			Next
		End if
		
		If !lRet
			cMsg := GetErroModel(oModelCNT)
			cSolu := ""
			Help(NIL, NIL, "SERGCT01 - Commit", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			lRet := .f.
		End if
		
		If lRet
			FWMsgRun(, {|| nRet := FWExecView("Contrato Compras",'CNTA300', MODEL_OPERATION_INSERT, , { || .T. } , ,30,,,,,oModelCNT)}, "Processando", "Carregando dados para o cadastro...")
	        
		  // Verifica se o usuario clicou em cancelar.
			If nRet == 1
				Help(NIL, NIL, "SERGCT01 - CommitData", NIL, "Cancelado pelo usuario" ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
				lRet := .f.
			End if 
		End if
		
//		//Validação e Gravação do Modelo
//		If oModelCNT:VldData()
//		    If !oModelCNT:CommitData()
//				cMsg := GetErroModel(oModelCNT)
//				cSolu := ""
//				Help(NIL, NIL, "SERGCT01 - CommitData", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
//				lRet := .f.
//		    End if
//		Else
//			cMsg := GetErroModel(oModelCNT)
//			cSolu := ""
//			Help(NIL, NIL, "SERGCT01 - VldData", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
//			lRet := .f.
//		EndIf
	
			// Caso encontre algum erro
		If !lRet
			oModel:lModify := .t. 	
			DisarmTransaction()				
		End If
				
	END TRANSACTION 

Return lRet

/*/{Protheus.doc} CargaProd
Realiza a carga dos produtos do contrato
para o fornecedor selecionado.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CargaProd()
	
	Local aSaveLines	:= FWSaveRows()
	Local oModel 		:= FwModelActive()
	Local oView			:= FwViewActive()
	Local oModelCNB		:= oModel:GetModel("CNBDETAIL")
	Local oModelCNA		:= oModel:GetModel("CNADETAIL")
	Local oModelSZG		:= oModel:GetModel("SZGDETAIL")
	Local oModelSZH		:= oModel:GetModel("SZHDETAIL")
	Local nTotReg		:= oModelCNB:Length()
	Local oModelCalc	:= oModel:GetModel("CALC_TX")
	Local nPercTOT		:= oModelCalc:GetValue("ZI_PORTAXA_T")
	Local i				:= 0
	Local nValor		:= 0 
	Local nQtd			:= 0
	Local nTotValor		:= 0

    oModelSZH:SetNoInsertLine(.F.)  
    
    // Verifica se existe alguem na linha
    If oModelSZG:IsEmpty()
    	Return
    End if

	For i:= 1 to nTotReg
		
		oModelCNB:GoLine(i)
			
		if !oModelSZH:SeekLine({{"ZH_ITEM",oModelCNB:GetValue("CNB_ITEM")},{"ZH_PRODUT",oModelCNB:GetValue("CNB_PRODUT")}})
			
			If !oModelSZH:IsEmpty()
				oModelSZH:AddLine()		
			End if
			
			nValor 		:= oModelCNB:GetValue("CNB_VLUNIT")
			nValor 		:= nValor -  (nValor*(nPercTOT/100))
			
			nQtd   		:= oModelCNB:GetValue("CNB_QUANT")
			nTotValor	:=	nQtd * nValor
			
			oModelSZH:SetValue("ZH_ITEM"	, oModelCNB:GetValue("CNB_ITEM"))
			oModelSZH:SetValue("ZH_PRODUT"	, oModelCNB:GetValue("CNB_PRODUT"))
			oModelSZH:SetValue("ZH_DESCRI"	, oModelCNB:GetValue("CNB_DESCRI"))
			oModelSZH:SetValue("ZH_UM"		, oModelCNB:GetValue("CNB_UM"))
			oModelSZH:SetValue("ZH_QUANT"	, nQtd)
			oModelSZH:SetValue("ZH_VLUNIT"	, nValor)
			oModelSZH:SetValue("ZH_VLTOT"	, nTotValor)
		End if
	Next  

    oModelSZH:SetNoInsertLine(.T.)

	FWRestRows( aSaveLines )
	oView:Refresh()
Return 

/*/{Protheus.doc} VldVlr
Validacao do valor do cooperado em 
relacao ao item do contrato
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VldVlr()

	Local oModel 	:= FwModelActive()
	Local oModelCNB	:= oModel:GetModel("CNBDETAIL")
	Local oModelSZH	:= oModel:GetModel("SZHDETAIL")
	Local nTotReg	:= oModelCNB:Length()
	Local i			:= 0
	Local lRet		:= .t.
	Local lVldPrc	:= SuperGetMV("MV_YVLDPRC",.f.,.f.)
	
	// Verifica se o valor e maior do que do contrato para este item.
	If oModelCNB:SeekLine({{"CNB_ITEM",oModelSZH:GetValue("ZH_ITEM")},{"CNB_PRODUT",oModelSZH:GetValue("ZH_PRODUT")}})
		
		If lVldPrc .and. oModelSZH:GetValue("ZH_VLUNIT") > oModelCNB:GetValue("CNB_VLUNIT")
			cMsg  := "O Valor informado é maior do que o valor deste item no contrato de venda."
			cSolu := "Favor informar o valor igual ou menor."
			Help(NIL, NIL, "VldVlr", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End if
	
	End if

	if oModelSZH:GetValue("ZH_VLUNIT") <= 0
		cMsg  := "O Valor informado não pode ser negativo igual a zero."
		cSolu := "Favor informar um valor maior que zero."
		Help(NIL, NIL, "VldVlr", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End if
	
Return lRet

/*/{Protheus.doc} CargaTX
Realiza a inclusao das taxas padroes
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CargaTX()

	Local aTaxas	:= {}
	Local oModel 	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oModelCNA := oModel:GetModel("CNADETAIL")
	Local oModelCN9 := oModel:GetModel("CN9MASTER")
	Local oModelSZI	:= oModel:GetModel("SZIDETAIL")
	Local nPIS		:= GETNEWPAR("MV_TXPIS")
	Local nCOFINS	:= GETNEWPAR("MV_TXCOFIN")
	Local nAliqISS	:= 0
	Local cCodCli	:= oModelCNA:GetValue("CNA_CLIENT")
	Local cCodLoj	:= oModelCNA:GetValue("CNA_LOJACL")
	Local nTxADM	:= oModelCN9:GetValue("CN9_YTXADM")

	nAliqISS	:= POSICIONE('SA1',1,xFilial("SA1") + cCodCli + cCodLoj, 'A1_YALQISS')

	AADD(aTaxas,{"PIS"	 				,nPIS})
	AADD(aTaxas,{"COFINS"				,nCOFINS})
	AADD(aTaxas,{"ISS CLIENTE"			,nAliqISS})
	AADD(aTaxas,{"TX ADMINISTRATIVA"	,nTxADM})
		
	For i:= 1 to Len(aTaxas)

		// Verifica se ja existe alguma taxa
		If !oModelSZI:IsEmpty()
			oModelSZI:AddLine()
		End If
		
		oModelSZI:SetValue("ZI_DESCRI" ,aTaxas[i][1])
		oModelSZI:SetValue("ZI_PORTAXA",aTaxas[i][2])
	Next
	
	oView:Refresh()
Return


/*/{Protheus.doc} GetErroModel
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function GetErroModel(oModel)

	Local aErro := oModel:GetErrorMessage()
	Local cMessage := ""

	cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
	cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
	cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
	cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
	cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
	cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
	cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
	cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
	cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'

	// Informa que o modelo foi alterado para que o sistema realize o committ novamente.
	oModel:lModify := .t. 

Return  cMessage