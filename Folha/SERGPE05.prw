#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"


Static cAliasDTY := GetNextAlias()

/*/{Protheus.doc} SERGPE05
Negociacao do de Frete
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERGPE05()
	
	Local oView  	 := Nil
	Local oModel 	 := Nil
	Local lRet		 := .t.
	
	Local aButtons := { {.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL}	,;
						  {.F.,NIL},{.t.,"Integrar Folha"},{.T.,"Fechar"},{.F.,NIL}		,;
						  {.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL} }
	  
	criaSX1("SERGPE05")
	lRet := Pergunte("SERGPE05",.t.)

	If !lRet
		Return
	End IF	  
	  
	oView  	 := FWLoadView("SERGPE05")

	oView:SetModel(oView:GetModel())
	oView:SetOperation(MODEL_OPERATION_UPDATE)  
	oView:SetProgressBar(.t.)
						
	oExecView := FWViewExec():New()
	oExecView:SetButtons(aButtons)
	oExecView:setTitle("TMS x GPE")
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:OpenView(.F.)
	
return

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	Local oModel  	:= Nil
	Local oStCAB  	:= Nil
	Local oStDTY  	:= Nil
	Local bCarga  	:= {|| {xFilial("DTY")}}
    Local bLoadDTY	:= {|oGridModel, lCopy| LoadDTY(oGridModel, lCopy,oModel)}
    Local bCommit 	:= {|| MCommit(oModel)}
    Local oStSRA   	:= FWFormStruct(1, "SRA",{ |x| ALLTRIM(x) $ "RA_FILIAL,RA_MAT,RA_NOME,RA_CC,RA_DESCCC,RA_DEPTO,RA_DDEPTO,RA_PROCES,RA_YRCOMIS,RA_SITFOLH,RA_YFILFRT" })
    Local nPercRe	:= SuperGetMV("MV_YPCFRT",.f.,5)
	
    AreaTrab()
	
	oStCAB	   := FWFormModelStruct():New()
    oStCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)

    // Monta Estrutura baseado na Area de Trabalho da query
    oStDTY := FWFormModelStruct():New()
    oStDTY:AddTable(cAliasDTY,{"",""},"",{|| })
    StrMVC(1,cAliasDTY, oStDTY)
    
    
    oStDTY:AddField("" ,;														// [01] Titulo do campo 		"Descrição"
                "",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
                "CARGA",;														// [03] Id do Field
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
    
      oStSRA:AddField("" ,;														// [01] Titulo do campo 		"Descrição"
                "",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
                "VENDEDOR",;													// [03] Id do Field
                "C"	,;															// [04] Tipo do campo
                30,;															// [05] Tamanho do campo
                0,;																// [06] Decimal do campo
                { || .T. }	,;													// [07] Code-block de validação do campo
                { || .F. }	,;													// [08] Code-block de validação When do campo
                ,;																// [09] Lista de valores permitido do campo
                .F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
                { || "VENDEDOR"},;	                                            // [11] Inicializador Padrão do campo
                ,; 																// [12] 
                ,; 																// [13] 
                .T.	) 															// [14] Virtual  
    
    oStDTY:SetProperty( "DIFERENCA" , MODEL_FIELD_TITULO , "Ganho/Perda" )
    oStDTY:SetProperty( "DIFERENCA" , MODEL_FIELD_TAMANHO, TAMSX3("DTR_VALFRE")[1] )
    oStDTY:SetProperty( "DIFERENCA" , MODEL_FIELD_DECIMAL, TAMSX3("DTR_VALFRE")[2] )
    
    oStSRA:SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
    oStDTY:SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
    
    oModel := MPFormModel():New("MSERGPE05",/*bPre*/,/*bPos*/,bCommit,/*bCancel*/) 
    
    // Cria o modelo
    oModel:AddFields("CABMASTER",/*cOwner*/,oStCAB,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
    oModel:SetPrimaryKey({""})
    
    // Adiciona grid
    oModel:AddGrid( "SRADETAIL"  , "CABMASTER"  , oStSRA  ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bFormula*/)
    oModel:AddGrid( "DTYDETAIL"  , "CABMASTER"  , oStDTY  ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadDTY)
    
    // Seta relacionamento
    oModel:SetRelation("DTYDETAIL" ,{{"DTY_FILIAL" ,"xFilial('DTY')"}},DTY->(IndexKey(1)))
    oModel:SetRelation("SRADETAIL" ,{{"RA_YFILFRT" ,'cFilAnt'}},SRA->(IndexKey(1)))
    // Seta Filtro
    oModel:GetModel( "SRADETAIL" ):SetLoadFilter( { { "RA_YFILFRT", "cFilAnt", MVC_LOADFILTER_EQUAL }, { "RA_YRCOMIS", "'S'", MVC_LOADFILTER_EQUAL }, { "RA_SITFOLH", "'D'", MVC_LOADFILTER_NOT_EQUAL } } )
    // Retira permissoes
    oModel:GetModel("DTYDETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("DTYDETAIL"):SetNoInsertLine(.T.)
    oModel:GetModel("SRADETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SRADETAIL"):SetNoInsertLine(.T.)
    
    bDif 	:= {|| oModel:GetModel("CALC_TOTAL"):GetValue("DTQ_YFREID_T") - oModel:GetModel("CALC_TOTAL"):GetValue("DTY_VALFRE_T")}
    bFunc	:= {|| oModel:GetModel("SRADETAIL"):Length()}
    bPerR	:= {|| nPercRe}
    bBase	:= {|| (oModel:GetModel("CALC_TOTAL"):GetValue("DTY_VALFRE_D") * nPercRe) /100 }
    
    bRateio := {|| oModel:GetModel("CALC_TOTAL"):GetValue("BASE_COMIS") /oModel:GetModel("CALC_TOTAL"):GetValue("QTD_FUNC")  }
    
    // Calculos
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTY_VALFRE","DTY_VIAGEM","COUNT" ,/*bCondition*/, /*bInitValue*/,"Qtd. Viagem" 	 		 ,/**/,13 /*nTamanho*/,2 /*nDecimal*/)
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTQ_YFREID","DTQ_YFREID_T","SUM" ,/*bCondition*/, /*bInitValue*/,"R$ Frete Ideal" 		 ,/**/,13 /*nTamanho*/,2 /*nDecimal*/)
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTY_VALFRE","DTY_VALFRE_T","SUM" ,/*bCondition*/, /*bInitValue*/,"R$ Frete Combinado" 	 ,/**/,13 /*nTamanho*/,2 /*nDecimal*/)
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTY_VALFRE","DTY_VALFRE_D","FORMULA" ,/*bCondition*/, /*bInitValue*/,"R$ Ganho/Perda" 	 ,bDif,13 /*nTamanho*/,2 /*nDecimal*/)
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTY_VALFRE","PERC_COMIS","FORMULA" ,/*bCondition*/, /*bInitValue*/,"% Comissão" 	 		 ,bPerR ,13 /*nTamanho*/,2 /*nDecimal*/)
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTY_VALFRE","BASE_COMIS","FORMULA" ,/*bCondition*/, /*bInitValue*/,"R$ Base" 	 		 	 ,bBase,13/*nTamanho*/,2 /*nDecimal*/)
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTY_VALFRE","QTD_FUNC"  ,"FORMULA" ,/*bCondition*/, /*bInitValue*/,"Qtd. Func." 	 		 ,bFunc,13 /*nTamanho*/,2 /*nDecimal*/)
    oModel:AddCalc("CALC_TOTAL","CABMASTER" ,"DTYDETAIL","DTY_VALFRE","VLR_RATEIO","FORMULA" ,/*bCondition*/, /*bInitValue*/,"R$ Rateio" 	 		 ,bRateio,13 /*nTamanho*/,2 /*nDecimal*/)
                                         
    // ********* ATENÇÃO *********** 
    // É de extrema importancia marcar o SetOnlyQuery para a tabela SRA.
    // Uma vez que a mesma NÃO PODE receber manutenção pois este modelo não possui a regra
    // de negocio que a rotina principal.
	oModel:GetModel("SRADETAIL"):SetOnlyQuery(.T.)  
    
    //Seta descricoes
    oModel:GetModel("DTYDETAIL"):SetDescription("Contrato")
    oModel:GetModel("SRADETAIL"):SetDescription("funcionários")
    oModel:GetModel("CABMASTER"):SetDescription("Cabeçalho")
    oModel:SetDescription("Comissões a Pagar - Cargas") 
    
    oModel:lModify := .t. 
    oModel:SetOnDemand(.t.)
   
Return oModel


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel("SERGPE05")
	Local oView  := Nil
	Local oStSRA := FWFormStruct(2, "SRA",{ |x| ALLTRIM(x) $ "RA_MAT,RA_NOME,RA_CC,RA_DESCCC,RA_DEPTO,RA_DDEPTO,RA_PROCES" })
	Local oCalc  := FWCalcStruct(oModel:GetModel("CALC_TOTAL"))

    //Criação da estrutura de dados da View
    Local oStDTY  := FWFormViewStruct():New()
    
    oView := FWFormView():New()
    
    StrMVC(2,cAliasDTY, oStDTY)
    
    oStDTY:SetProperty( "DIFERENCA" , MVC_VIEW_TITULO , "Ganho/Perda" )
    oStDTY:SetProperty( "DIFERENCA" , MVC_VIEW_PICT, X3Picture("DTY_VALFRE") )
    
 	oStDTY:AddField("CARGA",; //Id do Campo 
                    "00",; //Ordem
                    "",;// Título do Campo
                    "",; //Descrição do Campo
                    {},; //aHelp
                    "L",; //Tipo do Campo	
                    "@BMP"  )//cPicture		   
    
  	oStSRA:AddField("VENDEDOR",; //Id do Campo 
                    "00",; //Ordem
                    "",;// Título do Campo
                    "",; //Descrição do Campo
                    {},; //aHelp
                    "L",; //Tipo do Campo	
                    "@BMP"  )//cPicture	   
                    
    oStDTY:SetProperty( "*", MVC_VIEW_WIDTH, 110 )                
                    
  	//Seta o modelo
    oView:SetModel(oModel)

    //Atribuindo fomulários para interface
    oView:AddGrid("VIEW_DTY"  , oStDTY   , "DTYDETAIL")
    oView:AddGrid("VIEW_SRA"  , oStSRA   , "SRADETAIL")
    
    oView:AddField("VIEW_CALC"  , oCalc  , "CALC_TOTAL")
    oView:AddOtherObject("VIEW_GRAF", {|oPanel| Grafico(oPanel)})
     
    oView:CreateHorizontalBox("SUPERIOR",050)
   // oView:CreateHorizontalBox("CENTRO",010)
    	oView:CreateVerticalBox( "ESQUERDA", 040 ,"SUPERIOR")
    	oView:CreateVerticalBox( "DIREITA" , 060  ,"SUPERIOR")
    		oView:CreateVerticalBox( "GRAFICO" 		, 050  ,"DIREITA")
    		oView:CreateVerticalBox( "CALC_VIAGEM"    , 050  ,"DIREITA")
    oView:CreateHorizontalBox("INFERIOR",050)
    
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
    
    oView:SetOwnerView("VIEW_DTY" ,"ESQUERDA")
    oView:SetOwnerView("VIEW_CALC" ,"CALC_VIAGEM")
    oView:SetOwnerView("VIEW_SRA" ,"INFERIOR")
    oView:SetOwnerView("VIEW_GRAF" ,"GRAFICO")
    
  	//Adicionado Descrições
	oView:EnableTitleView("VIEW_DTY"  , "Negociações de Fretes" )
	oView:EnableTitleView("VIEW_CALC" , "Totalizadores" )
	oView:EnableTitleView("VIEW_SRA"  , "Funcionários" )
	oView:EnableTitleView("VIEW_GRAF"  , "Gráficos" )
	
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty("VIEW_SRA", "GRIDFILTER", {.T.}) 
    oView:SetViewProperty("VIEW_SRA", "GRIDSEEK"  , {.T.})
    
    oView:setUpdateMessage("TMS x Gestão Pessoal", "Concluida com sucesso.")

Return oView

/*/{Protheus.doc} Grafico
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@type function
/*/
Static Function Grafico (oPanel)

	Local oGrafico 	 := FWChartFactory():New()
	Local oModel	 := FwModelActive()
	Local oModelCalc := oModel:GetModel("CALC_TOTAL")

	oGrafico:SetOwner(oPanel)

    //Define o tipo do gráfico - Opções disponiveis | RADARCHART | FUNNELCHART | COLUMNCHART | NEWPIECHART |NEWLINECHART 
    oGrafico:SetChartDefault(COLUMNCHART) 
    
    //Adiciona Legenda - Opções de alinhamento da legenda: 
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_TOP | CONTROL_ALIGN_BOTTOM 
    oGrafico:SetLegend(CONTROL_ALIGN_TOP)
     
    //Opções de alinhamento dos labels(disponível somente no gráfico de funil): CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
    //oGrafico:SetAlignSerieLabel(CONTROL_ALIGN_CENTER)
    
	oGrafico:setTitle( "Negociações", CONTROL_ALIGN_CENTER )
	oGrafico:setLegend( CONTROL_ALIGN_LEFT )
	oGrafico:setMask( "R$ *@* " )
	oGrafico:setPicture( X3Picture("DTY_VALFRE") )
	oGrafico:addSerie( "Ideal", oModelCALC:GetValue("DTQ_YFREID_T") )
	oGrafico:addSerie( "Combinado", oModelCALC:GetValue("DTY_VALFRE_T") )
	oGrafico:addSerie( "Ganho",oModelCALC:GetValue("DTY_VALFRE_D") )
	
	oGrafico:Activate()
    
Return

/*/{Protheus.doc} MCommit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function MCommit(oModel)
	Local lRet := .t. 

	Processa({|| lRet := Commit(oModel)}, "Realizando integração...")

Return lRet

/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function Commit(oModel)

	Local oModelSRA := oModel:GetModel("SRADETAIL")
	Local oModelCALC:= oModel:GetModel("CALC_TOTAL")
	Local nRateio	:= oModelCALC:GetValue("VLR_RATEIO")
	Local nTotSRA	:= oModelSRA:Length()
	Local lRet		:= .t.
	Local cIdCalc	:= SuperGetMV("MV_YIDCFRT",.F.,"0165")
	Local lRateio	:= SuperGetMV("MV_YRATFRT",.f.,.F.)
	Local cFilInt	:= SuperGetMV("MV_YFILNFR",.f., "1001")
	Local cFilBackp	:= cFilAnt
	Local aCab  := {}
	Local aItens 	:= {}
	Local cErroInt	:= ""
	
	Private lMsErroAuto := .F.
	
	
	If lRateio
		nRateio := oModelCALC:GetValue("VLR_RATEIO")
	Else
		nRateio := oModelCALC:GetValue("BASE_COMIS")
	End If
	
	If nRateio <= 0 
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE05","O valor de rateio se encontra zerado ou negativo","") 
		oModel:lModify := .t. 
		Return .F.	
	End IF
	
	
	SRV->(DbSetOrder(2))
	if !SRV->(DbSeek(xFilial("SRV") + cIdCalc ))
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE05","Não localizado verba para o ID de Cálculo (" + cIdCalc + ")","") 
		oModel:lModify := .t. 
		Return .F.
	End iF
	
	If Alltrim(SRV->RV_TIPOCOD) <> '1'
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE05","A verba (" + SRV->RV_COD + "-" + Alltrim(SRV->RV_DESC) + ") não é do tipo Provento","") 
		oModel:lModify := .t. 
		Return .F.	
	End if
	
	
	IF !MSGYESNO( "Deseja realizar a integração (" + SRV->RV_COD + "-" + Alltrim(SRV->RV_DESC) + ") - R$ " + cvaltochar(nRateio)+ "?", "Integração - TMS x GPE" )
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE05","Cancelado pelo usuario","") 
		oModel:lModify := .t. 
		Return .f.
	End If 	
	
	ProcRegua(nTotSRA)
	
	// Troco a filial para que os registros sejam integrados na FILIAL MATRIZ
	// uma vez que a SERRANA cadastra todos os funcionarios na matriz, porem, 
	// no cadastro do funcionario ela informa que aquele funcionario recebe 
	// comissao dos fretes negociados da filial X.
	
	cFilAnt := cFilInt 
	
	BEGIN TRANSACTION
	
	For i:= 1 to nTotSRA
	
		lMsErroAuto := .F.
		oModelSRA:GoLine(i)
	
		aCab 	:= {}
		aItens		:= {}
		lMsErroAuto := .F.
		
		Aadd(aCab, {"RA_FILIAL" , oModelSRA:GetValue("RA_FILIAL")})
		Aadd(aCab, {"RA_MAT"	, oModelSRA:GetValue("RA_MAT")})
		
	    Aadd(aItens,;
		    {{"RK_PD"      , SRV->RV_COD        ,NIL };
		    ,{"RK_VALORTO" , nRateio            ,NIL };
		    ,{"RK_PARCELA" , 1                  ,NIL };
		    ,{"RK_DTVENC"  , ddatabase          ,NIL };
		    ,{"RK_VALORPA" , nRateio            ,NIL };
		    ,{"RK_VLSALDO" , nRateio            ,NIL };
		    ,{"RK_MESDISS" , DTOS(Date())       ,NIL }})
		
		IncProc(oModelSRA:GetValue("RA_NOME"))
		
		MSExecAuto({|a, b, c| GPEA110(a, b, c) }, 3, aCab, aItens)
			
		If lMsErroAuto 
		
			// Pega o retorno do exeauto
			cErroInt := MemoRead(NomeAutoLog())
			// Apaga o arquivo
			FErase(NomeAutoLog())
				
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE05",cErroInt,"") 
			oModel:lModify := .t. 
			DisarmTransaction()				
			Return .f.
		End If

	Next
	
	// Volto a FILIAL de ORIGEM
	cFilAnt := cFilBackp 
	
	End TRANSACTION

Return lRet


/*/{Protheus.doc} AreaTrab
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AreaTrab()

	// Verifica se esta em aberto	
    If select (cAliasDTY) > 0 
        (cAliasDTY)->(DbCloseArea())
    End If

	BeginSQL Alias cAliasDTY
	
		SELECT 
		
		DTQ_VIAGEM
		,DTQ.DTQ_YFREID
		,SUM(DTY_VALFRE) AS DTY_VALFRE
		,DTQ.DTQ_YFREID  - SUM(DTY_VALFRE) AS DIFERENCA
		
		FROM %Table:DTY% DTY
		
		JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial('SA2')%
		AND SA2.A2_COD = DTY.DTY_CODFOR
		AND SA2.A2_LOJA = DTY.DTY_LOJFOR
		AND SA2.D_E_L_E_T_ =''
		
		JOIN %Table:DTQ% DTQ ON DTQ_FILIAL = %Exp:xFilial('DTQ')%
		AND DTQ.DTQ_FILORI = DTY.DTY_FILORI
		AND DTQ.DTQ_VIAGEM = DTY.DTY_VIAGEM
		AND DTQ.D_E_L_E_T_ =''
		
		WHERE DTY.D_E_L_E_T_ =''
		AND DTY.DTY_FILIAL = %Exp:cFilAnt%
		AND DTY.DTY_FILORI = %Exp:cFilAnt%
		
		AND DTY.DTY_DATCTC BETWEEN %Exp:DTos(mv_par01)% AND %Exp:DTos(mv_par02)%
		
		GROUP BY DTY.DTY_FILORI,DTQ.DTQ_VIAGEM,DTQ.DTQ_YFREID

	EndSQL

	TcSetField(cAliasDTY,'DTY_DATCTC','D')

Return


/*/{Protheus.doc} LoadDTY
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadDTY(oGridModel, lCopy,oModel)

    Local aLoad := {}
    
     aLoad := FwLoadByAlias( oGridModel,cAliasDTY, NIL , Nil , Nil , .t. ) 

Return aLoad

/*/{Protheus.doc} StrMVC
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, description
@param cAlias, characters, description
@param oStr, object, description
@param aCampos, array, description
@type function
/*/
Static Function StrMVC(nTipo,cAlias,oStr)

    // Recupera a estrutra da query
    Local aStru := (cAlias)->(dbStruct())
    Default aCampos := aStru

    // Cria estrutura do modelo de dados e da view
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))

    For i:= 1 to Len(aStru)
        
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

/*/{Protheus.doc} criaSX1
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cPerg, characters, description
@type function
/*/
static function criaSX1(cPerg)
	
	Local aDados := {}
	
	aAdd( aDados, {cPerg,'01','Dt Contrato De'    , '','','mv_ch01','D',8						,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','Dt Contrato Ate'   , '','','mv_ch02','D',8						,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
			
	U_AtuSx1(aDados)					
return

