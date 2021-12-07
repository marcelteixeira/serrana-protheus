#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"

Static cAliasFGPE := GetNextAlias()



/*/{Protheus.doc} SERGPE04
Integracao da Financeiro para Folha.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User function SERGPE04()

	Local oView  	 := Nil
	Local lRet		 := .t.

	Local aButtons := { {.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL}	,;
		{.F.,NIL},{.t.,"Integrar Folha"},{.T.,"Fechar"},{.F.,NIL}		,;
		{.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL},{.F.,NIL} }

	//Variaveis utilizadas no filtro da consulta padrão RCH - GpRchFiltro
	Private cPeriodo
	Private cCond 		:= "1"
	Private cProcesso 	:= ""
	Private cFilRCJ		:= "" 	//Variavel será alimentada pelo VALID do SX1 (Gpm020SetVar)

	criaSX1("SERGPE04")

	lRet := Pergunte("SERGPE04",.t.)

	If !lRet
		Return
	End IF

	oView  	 := FWLoadView("SERGPE04")

	oView:SetModel(oView:GetModel())
	oView:SetOperation(MODEL_OPERATION_UPDATE)
	oView:SetProgressBar(.t.)

	oExecView := FWViewExec():New()
	oExecView:SetButtons(aButtons)
	oExecView:setTitle(".")
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:OpenView(.F.)

return

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel  := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStSE2P 	:= Nil // Financeiro Proventos
	Local oStSE2D 	:= Nil // Financeiro Descontos
	Local oStSRA  	:= Nil
	Local oStCAB  	:= Nil
	Local oStRGB  	:= FWFormStruct(1, "RGB",{ |x| ALLTRIM(x) $ "RGB_PD,RGB_DESCPD,RGB_TIPO1,RGB_DTREF,RGB_CC,RGB_VALOR" })

	Local bCarga  	:= {|| {xFilial("SRA")}}
	Local bLoadSRA	:= {|oGridModel, lCopy| LoadSRA(oGridModel, lCopy,oModel)}
	Local bLoadSE2D	:= {|oGridModel, lCopy| LoadSE2D(oGridModel, lCopy,oModel)}
	Local bLoadSE2P	:= {|oGridModel, lCopy| LoadSE2P(oGridModel, lCopy,oModel)}
	Local bLoadRGB	:= {|oGridModel, lCopy| LoadRGB(oGridModel, lCopy,oModel)}
	Local bCommit 	:= {|| MCommit(oModel)}


	//Busca os titulos financeiros
	TrabFGPE()

	// Monta o cabeçalho Fake
	oStCAB	   := FWFormModelStruct():New()
	oStCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)

	// Monta Estrutura baseado na Area de Trabalho da query
	oStSRA := FWFormModelStruct():New()
	oStSRA:AddTable(cAliasFGPE,{"",""},"",{|| })
	StrMVC(1,cAliasFGPE, oStSRA)

	oStSE2P := FWFormModelStruct():New()
	oStSE2P:AddTable(cAliasFGPE,{"",""},"",{|| })
	StrMVC(1,cAliasFGPE, oStSE2P)

	oStSE2D := FWFormModelStruct():New()
	oStSE2D:AddTable(cAliasFGPE,{"",""},"",{|| })
	StrMVC(1,cAliasFGPE, oStSE2D)


	oStSRA:AddField("Icone" ,;										// [01] Titulo do campo 		"Descrição"
	"Icone",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"BMPUSER",;														// [03] Id do Field
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


	oStSRA:AddField("Status" ,;										// [01] Titulo do campo 		"Descrição"
	"Status",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Status",;														// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "BR_BRANCO"},;	                                            // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	)


	oStSRA:AddField("Erro" ,;														// [01] Titulo do campo 		"Descrição"
	"Erro",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Erro",;														// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	100000,;														// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .T. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || ""},;	                                            		// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	)

	oStSE2P:AddField("" ,;															// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"SDUSETDEL",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "SDUSETDEL"},;	                                            	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	)

	oStSE2D:AddField("" ,;															// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"SDUSOFTSEEK",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	{ || "SDUSOFTSEEK"},;	                                            	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	)

	oModel := MPFormModel():New("MSERGPE04",/*bPre*/,/*bPos*/,bCommit,/*bCancel*/)

	// Cria o modelo
	oModel:AddFields("CABMASTER",/*cOwner*/,oStCAB,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
	oModel:SetPrimaryKey({""})

	oModel:AddGrid( "SRADETAIL"  , "CABMASTER"  , oStSRA  ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadSRA)
	oModel:AddGrid( "SE2PDETAIL" , "SRADETAIL"  , oStSE2P ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadSE2P)
	oModel:AddGrid( "SE2DDETAIL" , "SRADETAIL"  , oStSE2D ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadSE2D)
	oModel:AddGrid( "RGBDETAIL"  , "SRADETAIL"  , oStRGB  ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,bLoadRGB)

	oModel:SetRelation("SRADETAIL" ,{{"RA_FILIAL" ,"xFilial('SRA')"}},SRA->(IndexKey(1)))

	// Calculos
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_VALOR"	,"E2_VALOR_Q"	,"COUNT" 	, /*bCondition*/,  /*bInitValue*/,"Quantidade"  	,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_VALOR"	,"E2_VALOR_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Valor"  		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_ISS"	,"E2_ISS_T"		,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ ISS"    		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_IRRF"	,"E2_IRRF_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ IRRF"   		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","BCIRRF"	,"BCIRRF_T","SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Base IRRF"   		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_INSS"	,"E2_INSS_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ INSS"   		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_SEST"	,"E2_SEST_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ SEST/SENAT"  	,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_COFINS","E2_COFINS_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ COFINS"  		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_PIS"	,"E2_PIS_T"		,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ PIS"  		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2P","SRADETAIL" ,"SE2PDETAIL","E2_CSLL"	,"E2_CSLL_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ CSLL"  		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)

	oModel:AddCalc("CALC_SE2D","SRADETAIL" ,"SE2DDETAIL","E2_VALOR"	,"E2_VALOR_Q"	,"COUNT" 	, /*bCondition*/,  /*bInitValue*/,"Quantidade"  		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)
	oModel:AddCalc("CALC_SE2D","SRADETAIL" ,"SE2DDETAIL","E2_VALOR"	,"E2_VALOR_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Valor"  		,/*bFormula*/,13 /*nTamanho*/,3 /*nDecimal*/)


	// Preenchimento Opcional
	oModel:GetModel("SRADETAIL"):SetOptional( .T. )
	oModel:GetModel("SE2PDETAIL"):SetOptional( .T. )
	oModel:GetModel("SE2DDETAIL"):SetOptional( .T. )
	oModel:GetModel("RGBDETAIL"):SetOptional( .T. )

	// Muda a estrutura para inserir ou deletar
	oModel:GetModel("SRADETAIL"):SetNoDeleteLine(.T.);  oModel:GetModel("SRADETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SE2PDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SE2PDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SE2DDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SE2DDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("RGBDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("RGBDETAIL"):SetNoInsertLine(.T.)

	oModel:GetModel("SRADETAIL"):SetDescription("Cooperados")
	oModel:GetModel("RGBDETAIL"):SetDescription("Lanc. por Verbas")
	oModel:GetModel("SE2PDETAIL"):SetDescription("Proventos")
	oModel:GetModel("SE2DDETAIL"):SetDescription("Descontos")
	oModel:GetModel("CABMASTER"):SetDescription("Cabeçalho")
	oModel:SetDescription("Integração FIN x GPE")

	oModel:lModify := .t.
	oModel:SetOnDemand(.t.)

	//Verifica se realiza ativição do Modelo
	oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )

Return oModel


Static Function ValidActv( oModel )

	Local lRet := .t.
	Local aAreaSQL := GetArea((cAliasFGPE))

	Local cVerb0218  := POSICIONE("SRV",2,xFilial('SRV') + "0218","RV_COD") //Autonomo
	Local cVerb1565  := POSICIONE("SRV",2,xFilial('SRV') + "1565","RV_COD") //Frete - Sem Incidência
	Local cVerb1564  := POSICIONE("SRV",2,xFilial('SRV') + "1564","RV_COD") //Frete - Incidência IRRF
	Local cVerb1563  := POSICIONE("SRV",2,xFilial('SRV') + "1563","RV_COD") //Frete - Incidência INSS
	Local cVerb0064	 := POSICIONE("SRV",2,xFilial('SRV') + "0064","RV_COD") //Desconto INSS
	Local cVerb0066	 := POSICIONE("SRV",2,xFilial('SRV') + "0066","RV_COD") //Desconto IRRF
	Local cVerb0437	 := POSICIONE("SRV",2,xFilial('SRV') + "0437","RV_COD") //Desconto SEST
	Local cVerb1456	 := POSICIONE("SRV",2,xFilial('SRV') + "1456","RV_COD") //Desconto SENAT
	Local cBase0221	 := POSICIONE("SRV",2,xFilial('SRV') + "0221","RV_COD") //Base INSS
	Local cBase0015	 := POSICIONE("SRV",2,xFilial('SRV') + "0015","RV_COD") //Base IRRF
	Local cBase0047	 := POSICIONE("SRV",2,xFilial('SRV') + "0047","RV_COD") //Liquido
	Local cCodDesp	 := ""
	Local aCodDesp	 := {}

	// Verifica se existe verbas para os ID
	If Empty(cVerb0218)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 0218"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cVerb1565)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 1565"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cVerb1564)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 1564"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cVerb1563)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 1563"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cVerb0064)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 0064"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cVerb0066)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 0066"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cVerb0437)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 0437"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cVerb1456)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 1456"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL,NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cBase0221)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 0221"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL,NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cBase0015)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 0015"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL,NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	ElseIf Empty(cBase0047)
		cMsg  := "Nao foi possivel localizar uma verba para o ID de calculo: 0047"
		cSolu := "Favor cadastrar uma verba para este ID de calculo"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL,NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End IF

	While (cAliasFGPE)->(!EOF())

		// Verifica se existe desconto sem verba atrelada
		If !Empty((cAliasFGPE)->DT7_CODDES) .and. Empty((cAliasFGPE)->RV_COD)
			cCodDesp := Alltrim((cAliasFGPE)->DT7_CODDES)

			nPos := Ascan(aCodDesp,{|w|Alltrim(w) == Alltrim(cCodDesp)})

			If nPos == 0
				AADD(aCodDesp,cCodDesp)
			End If
		End if

		(cAliasFGPE)->(DbSkip())
	EndDo

	cCodDesp := ""
	For i:= 1 to len(aCodDesp)
		cCodDesp += aCodDesp[i] + "/ "
	Next

	If !Empty(cCodDesp)
		cMsg  := "Nao foi possivel localizar as verbas para estas despesas: " + cCodDesp
		cSolu := "Favor cadastrar uma verba para estas despesas primeiro"
		Help(NIL, NIL, "SERGPE04 - ValidActv ", NIL, cMsg ,1, 0, NIL,NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End IF

	RestArea(aAreaSQL)

Return lRet


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel("SERGPE04")
	Local oView  := Nil
	Local aFilSE2D := {}
	Local aFilSE2P:= {}

	//Criação da estrutura de dados da View
	Local oStSRA  := FWFormViewStruct():New()
	Local oStSE2D := FWFormViewStruct():New()
	Local oStSE2P := FWFormViewStruct():New()
	Local oStRGB  := FWFormStruct(2, "RGB",{ |x| ALLTRIM(x) $ "RGB_PD,RGB_DESCPD,RGB_TIPO1,RGB_DTREF,RGB_CC,RGB_VALOR" })
	Local oCalcSE2P := FWCalcStruct(oModel:GetModel("CALC_SE2P"))
	Local oCalcSE2D := FWCalcStruct(oModel:GetModel("CALC_SE2D"))
	oView := FWFormView():New()

	// Proventos
	AADD(aFilSE2P, {"E2_PREFIXO"});AADD(aFilSE2P,{"E2_NUM"})	;AADD(aFilSE2P,{"E2_EMISSAO"}) 	;AADD(aFilSE2P,{"E2_PARCELA"})	;AADD(aFilSE2P,{"E2_PARCELA"})
	AADD(aFilSE2P, {"E2_TIPO"})	  ;AADD(aFilSE2P,{"E2_NATUREZ"});AADD(aFilSE2P,{"E2_VALOR"}) 	;AADD(aFilSE2P,{"ED_DESCRIC"})
	AADD(aFilSE2P, {"E2_IRRF"})	  ;AADD(aFilSE2P,{"E2_INSS"})	;AADD(aFilSE2P,{"E2_SEST"})		;AADD(aFilSE2P,{"BCIRRF"})
	AADD(aFilSE2P, {"E2_BASEINS"});AADD(aFilSE2P,{"ED_YVERBA"}) //;AADD(aFilSE2P,{"E2_PIS"})	;AADD(aFilSE2P,{"E2_CSLL"})

	// Descontos
	AADD(aFilSE2D, {"E2_PREFIXO"});AADD(aFilSE2D,{"E2_NUM"})	;AADD(aFilSE2D,{"E2_EMISSAO"}) 	;AADD(aFilSE2D,{"E2_PARCELA"})	;AADD(aFilSE2D,{"E2_PARCELA"})
	AADD(aFilSE2D, {"E2_TIPO"})	  ;AADD(aFilSE2D,{"E2_NATUREZ"});AADD(aFilSE2D,{"E2_VALOR"}) 	;AADD(aFilSE2D,{"ED_DESCRIC"})
	AADD(aFilSE2D, {"DT7_CODDES"});AADD(aFilSE2D,{"DT7_DESCRI"});AADD(aFilSE2D,{"RV_COD"})

	StrMVC(2,cAliasFGPE  , oStSRA , {{"RA_MAT"},{"RA_CC"},{"RA_CATFUNC"},{"RA_PROCES"},{"E2_FORNECE"},{"RA_CIC"},{"RA_NOME"},{"RGB_PERIOD"},{"RGB_SEMANA"},{"RGB_ROTEIR"}})
	StrMVC(2,cAliasFGPE  , oStSE2D, aFilSE2D)
	StrMVC(2,cAliasFGPE  , oStSE2P, aFilSE2P)

	oStSE2D:SetProperty( "*"    		, MVC_VIEW_WIDTH, 90 )
	oStSE2D:SetProperty( "ED_DESCRIC"   , MVC_VIEW_WIDTH, 200 )
	oStSE2D:SetProperty( "E2_VALOR"     , MVC_VIEW_WIDTH, 110 )
	oStSE2D:SetProperty( "DT7_CODDES"   , MVC_VIEW_WIDTH, 110 )
	oStSE2D:SetProperty( "DT7_DESCRI"   , MVC_VIEW_WIDTH, 200 )
	oStSE2P:SetProperty( "*"    		, MVC_VIEW_WIDTH, 80 )
	oStSE2P:SetProperty( "ED_DESCRIC"   , MVC_VIEW_WIDTH, 200 )
	oStSE2P:SetProperty( "E2_VALOR"     , MVC_VIEW_WIDTH, 110 )
	//oStSE2P:SetProperty( "E2_BASEIRF"   , MVC_VIEW_WIDTH, 110 )
	oStSE2P:SetProperty( "E2_BASEINS"   , MVC_VIEW_WIDTH, 110 )

	oStSE2P:SetProperty( "BCIRRF"    , MVC_VIEW_TITULO , "Base IRRF" )
	oStSE2P:SetProperty( "BCIRRF"    , MVC_VIEW_PICT, X3Picture("E2_BASEIRF"))
	oStSE2P:SetProperty( "BCIRRF"	 , MVC_VIEW_WIDTH, 110 )

	oStSRA:SetProperty( "*"     , MVC_VIEW_WIDTH, 100 )
	oStSRA:SetProperty( "RA_NOME", MVC_VIEW_WIDTH, 200 )

	oStSE2D:SetProperty( "*"	, MVC_VIEW_CANCHANGE, .f. )
	oStSE2P:SetProperty( "*"	, MVC_VIEW_CANCHANGE, .f. )
	oStSRA:SetProperty ( "*"	, MVC_VIEW_CANCHANGE, .f. )
	oStRGB:SetProperty ( "*"	, MVC_VIEW_CANCHANGE, .f. )

	oStSRA:AddField("BMPUSER",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStSRA:AddField("Status",; //Id do Campo
	"01",; //Ordem
	"Status",;// Título do Campo
	"Status",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStSE2P:AddField("SDUSETDEL",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStSE2D:AddField("SDUSOFTSEEK",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	//Seta o modelo
	oView:SetModel(oModel)

	//Atribuindo fomulários para interface
	oView:AddGrid("VIEW_SRA"  , oStSRA   , "SRADETAIL")
	oView:AddGrid("VIEW_SE2P" , oStSE2P  , "SE2PDETAIL")
	oView:AddGrid("VIEW_SE2D" , oStSE2D  , "SE2DDETAIL")
	oView:AddGrid("VIEW_RGB"  , oStRGB   , "RGBDETAIL")

	oView:AddField("VIEW_CALC_SE2P"  , oCalcSE2P  , "CALC_SE2P")
	oView:AddField("VIEW_CALC_SE2D"  , oCalcSE2D  , "CALC_SE2D")

	oView:CreateHorizontalBox("SUPERIOR",30)
	oView:CreateHorizontalBox("INFERIOR",70)

	oView:CreateFolder("FOLDER_VISOES","INFERIOR")

	oView:AddSheet("FOLDER_VISOES", "VISAO_FIN" , "Visão Financeira" )
	oView:AddSheet("FOLDER_VISOES", "VISAO_GPE" , "Visão Gestão Pessoal" )

	oView:CreateHorizontalBox("BOX_VISAO_FIN" 	  , 100 ,,, "FOLDER_VISOES", "VISAO_FIN")
	oView:CreateHorizontalBox("BOX_VISAO_GPE" 	  , 100 ,,, "FOLDER_VISOES", "VISAO_GPE")

	oView:CreateFolder("FOLDER_VISAO_FIN","BOX_VISAO_FIN")

	oView:AddSheet("FOLDER_VISAO_FIN", "ABA_PROVENTO" , "Proventos" )
	oView:CreateHorizontalBox("BOX_PROV" 	  , 60 ,,, "FOLDER_VISAO_FIN", "ABA_PROVENTO")
	oView:CreateHorizontalBox("BOX_PROV_CALC" , 40 ,,, "FOLDER_VISAO_FIN", "ABA_PROVENTO")

	oView:AddSheet("FOLDER_VISAO_FIN", "ABA_DESCONTO" , "Descontos" )
	oView:CreateHorizontalBox("BOX_DESC" 	  , 70 ,,, "FOLDER_VISAO_FIN", "ABA_DESCONTO")
	oView:CreateHorizontalBox("BOX_DESC_CALC" , 30 ,,, "FOLDER_VISAO_FIN", "ABA_DESCONTO")


	oView:CreateFolder("FOLDER_VISAO_GPE","BOX_VISAO_GPE")

	oView:AddSheet("FOLDER_VISAO_GPE", "ABA_VERBAS" , "Por Verbas" )
	oView:CreateHorizontalBox("BOX_VERBAS" 	  , 100 ,,, "FOLDER_VISAO_GPE", "ABA_VERBAS")

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	oView:SetOwnerView("VIEW_SRA" ,"SUPERIOR")
	oView:SetOwnerView("VIEW_RGB","BOX_VERBAS")
	oView:SetOwnerView("VIEW_SE2P","BOX_PROV")
	oView:SetOwnerView("VIEW_SE2D","BOX_DESC")

	//Totalizadores
	oView:SetOwnerView("VIEW_CALC_SE2P","BOX_PROV_CALC")
	oView:SetOwnerView("VIEW_CALC_SE2D","BOX_DESC_CALC")

	//Adicionado Descrições
	oView:EnableTitleView("VIEW_SRA" , "Cooperados" )

	oView:EnableTitleView("VIEW_CALC_SE2P", "Totais Proventos/Impostos" )
	oView:EnableTitleView("VIEW_CALC_SE2D", "Totais Descontos" )

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

	oView:SetViewProperty("*", "GRIDSEEK"  , {.T.})
	oView:SetViewProperty("*", "GRIDFILTER", {.T.})

	oView:SetViewProperty("VIEW_SRA", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| ExibErro(oFormulario,cFieldName,nLineGrid,nLineModel)}})

	oView:AddUserButton("Legenda"       ,"",{|| Legenda() }  ,"")

	oView:setUpdateMessage("Financeiro x Gestão Pessoal", "Concluida com sucesso.")

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

Return oView

Static Function ExibErro(oFormulario,cFieldName,nLineGrid,nLineModel)

	Local oModelSRA := oFormulario:GetModel()
	Local cNome		:= Alltrim(oModelSRA:GetValue("RA_NOME"))

	If !Empty(oModelSRA:GetValue("Erro"))
		AVISO("Erro Integração - " + cNome, oModelSRA:GetValue("Erro"), {}, 3)
	End If

Return .f.

/*/{Protheus.doc} Legenda
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function Legenda()

	Local aLegenda := {}

	//Monta as legendas (Cor, Legenda)
	aAdd(aLegenda,{"BR_BRANCO",      "À Integrar"})
	aAdd(aLegenda,{"BR_VERDE",       "Integrado"})
	aAdd(aLegenda,{"BR_VERMELHO",    "Não Integrado"})

	BrwLegenda("Legenda", "Cooperados", aLegenda)

Return

/*/{Protheus.doc} MCommit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
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
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function Commit(oModel)

	Local oModelSRA := oModel:GetModel("SRADETAIL")
	Local oModelRGB := oModel:GetModel("RGBDETAIL")
	Local nTotSRA 	:= oModelSRA:Length()
	Local nTotRGB	:= 0
	Local aLinha	:= {}
	Local cErroInt	:= ""
	Local lErro		:= .f.
	Local oView		:= FwViewActive()

	Local aCabAuto  := {}
	Local aItemAuto := {}
	Local i 		:= 0
	Local y 		:= 0

	Private lMsErroAuto := .F.

	IF !MSGYESNO( "Deseja realizar a integração?", "Integração - FIN x GPE" )
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE04","Cancelado pelo usuario","")
		oModel:lModify := .t.
		Return .f.
	End If

	//Repocicionando na tabela RCH por motivos de segurança
	//RCH_FILIAL + RCH_PROCES + RCH_PER + RCH_NUMPAG + RCH_ROTEIR
	Pergunte("SERGPE04", .F.)
	RCH->(DbSetOrder(1))
	If !RCH->(DbSeek(xFilial("RCH") + MV_PAR05 + MV_PAR06 + MV_PAR07))
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE04","Erro ao Reposicionar na Tabela RCH.", "Favor rever os parametros.")
		oModel:lModify := .t.
		Return .f.
	EndIf

	//RFQ_FILIAL + RFQ_PROCES + RFQ_PERIOD + RFQ_NUMPAG
	RFQ->(DbSetOrder(1))
	If RFQ->(DbSeek(xFilial("RFQ") + RCH->RCH_PROCES + RCH->RCH_PER + RCH->RCH_NUMPAG))
		If RFQ->RFQ_STATUS == "2" //Lançamento Fechado
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE04","Ja existe Lançamento Fechado para Processo/Cod. Periodo/Numero Pagto: " + RCH->RCH_PROCES + "/" + RCH->RCH_PER + "/" + RCH->RCH_NUMPAG, "Favor selecionar outro periodo ou realizar manutenção")
			oModel:lModify := .t.
			Return .f.
		EndIf
	EndIf

	//RC_FILIAL, RC_PROCES, RC_PERIODO, RC_SEMANA, RC_ROTEIR, RC_CC, RC_MAT, R_E_C_N_O_, D_E_L_E_T_
	SRC->(DbSetOrder(12))
	If SRC->(DbSeek(xFilial("SRC") + RCH->RCH_PROCES + RCH->RCH_PER + RCH->RCH_NUMPAG + RCH->RCH_ROTEIR))
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE04","Ja existem lançamentos na tabela SRC para este Processo/Periodo/Num. Pag/Roteiro","Favor selecionar outro periodo ou realizar manutenção")
		oModel:lModify := .t.
		Return .f.
	EndIf

	ProcRegua(nTotSRA)

	BEGIN TRANSACTION

		For i:= 1 to nTotSRA

			oModelSRA:GoLine(i)

			// Nao integrar novamente.
			If Alltrim(oModelSRA:GetValue("Status")) == "BR_VERDE"
				Loop
			End IF

			IncProc(oModelSRA:GetValue("RA_NOME"))

			aCabAuto 	:= {}
			aLinha	 	:= {}
			aItemAuto	:= {}
			lMsErroAuto := .F.

			//			aAdd( aCabAuto,{ 'RA_FILIAL' , xFilial("SRA") 					, nil })
			//			aAdd( aCabAuto,{ 'RA_MAT' 	 , oModelSRA:GetValue("RA_MAT") 	, nil })
			//			aAdd( aCabAuto,{ 'CROTEIRO'  , oModelSRA:GetValue("RGB_ROTEIR") , nil })
			//			aAdd( aCabAuto,{ 'CNUMPAGTO' , oModelSRA:GetValue("RGB_SEMANA") , nil })
			//			aAdd( aCabAuto,{ 'CPERIODO'  , oModelSRA:GetValue("RGB_PERIOD") , nil })

			nTotRGB := oModelRGB:Length()

			// Verifica se esta vazio as verbas
			If !oModelRGB:IsEmpty()

				// Adiciona cada verba no array
				For y := 1 to nTotRGB

					oModelRGB:GoLine(y)

					aLinha := {}

					//					// Verifica se existe codigo da verba
					//					If !Empty(oModelRGB:GetValue("RGB_PD"))
					//
					//						aadd(aLinha,{'RGB_SEMANA' , oModelSRA:GetValue("RGB_SEMANA") , nil})
					//						aadd(aLinha,{'RGB_PD' 	  , oModelRGB:GetValue("RGB_PD") 	 , nil})
					//						aadd(aLinha,{'RGB_TIPO1 ' , oModelRGB:GetValue("RGB_TIPO1")  , nil})
					//						aadd(aLinha,{'RGB_VALOR ' , oModelRGB:GetValue("RGB_VALOR")  , nil})
					//						aadd(aLinha,{'RGB_DTREF ' , oModelRGB:GetValue("RGB_DTREF")  , nil})
					//						aadd(aLinha,{'RGB_CC ' 	  , oModelRGB:GetValue("RGB_CC") 	 , nil})
					//						aadd(aLinha,{'RGB_PARCEL' , 1 								 , nil})
					//						aadd(aItemAuto,aclone(aLinha))
					//					End If

					RECLOCK("SRC",.T.)

					SRC->RC_FILIAL   := xFilial("SRC")
					SRC->RC_MAT      := oModelSRA:GetValue("RA_MAT")
					SRC->RC_PD    	 := oModelRGB:GetValue("RGB_PD")
					SRC->RC_TIPO1    := oModelRGB:GetValue("RGB_TIPO1")
					SRC->RC_DATA     := oModelRGB:GetValue("RGB_DTREF")
					SRC->RC_DTREF    := oModelRGB:GetValue("RGB_DTREF")
					SRC->RC_HORAS    := 0
					SRC->RC_CC       := oModelRGB:GetValue("RGB_CC")
					SRC->RC_TIPO2    := "I"
					SRC->RC_PARCELA	 := 1
					SRC->RC_DEPTO	 := oModelSRA:GetValue("RA_DEPTO")
					SRC->RC_VALOR    := oModelRGB:GetValue("RGB_VALOR")
					SRC->RC_SEMANA   := oModelSRA:GetValue("RGB_SEMANA")
					SRC->RC_ROTEIR	 := oModelSRA:GetValue("RGB_ROTEIR")
					SRC->RC_PROCES	 := oModelSRA:GetValue("RA_PROCES")
					SRC->RC_PERIODO	 := oModelSRA:GetValue("RGB_PERIOD")

					SRC->(MSUNLOCK())

				Next

				//Chama a rotina
				//MsExecAuto({|a, b, c, d| GPEA580(a,b,c,d)},nil, aCabAuto, aItemAuto,3)

				lMsErroAuto := .f.

				If lMsErroAuto
					// Pega o retorno do exeauto
					cErroInt := MemoRead(NomeAutoLog())
					// Apaga o arquivo
					FErase(NomeAutoLog())
					// Coloca o erro no modelo
					oModelSRA:LoadValue("Erro",cErroInt)
					// Muda a legenda para nao integrado
					oModelSRA:LoadValue("Status","BR_VERMELHO")
					// Seta a variavel erro para informar que existem pelo menos um cooperado
					// nao integrado
					lErro := .t.
				Else
					// Muda a legenda para integrado com sucesso.
					oModelSRA:LoadValue("Status","BR_VERDE")

					// Integra no Financeiro
					IntSE2(oModel)

				End If
			End if

		Next

	END TRANSACTION

	// Verifica se existe algum erro de integracao
	If lErro
		// Seta no modelo para informar ao usuario
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERGPE04","Existem cooperados que não foram integrados","Visualize o erro executando double click no cooperado.")
		oModel:lModify := .t.
		// Da um refresh para atualizar a legenda na tela
		oView:Refresh()
	End if

Return !lErro

/*/{Protheus.doc} IntSE2
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function IntSE2(oModel)

	Local oModelSE2D := oModel:GetModel("SE2DDETAIL")
	Local oModelSE2P := oModel:GetModel("SE2PDETAIL")
	Local nTotSE2D	 := oModelSE2D:Length()
	Local nTotSE2P	 := oModelSE2P:Length()
	Local i := 0
	Local y := 0
	Local aSaveLines := FWSaveRows()

	SE2->(DbSetOrder(1))

	// Verifica se existem lancamentos de Proventos
	If !oModelSE2P:IsEmpty()

		For y:= 1 to nTotSE2P

			oModelSE2P:Goline(y)

			SE2->(DbGoTo(oModelSE2P:GetValue("RECSE2")))

			Reclock("SE2",.f.)
			SE2->E2_SEFIP := "x"
			MsUnLock()

		Next
	End If

	// Verifica se existem lancamentos de Descontos
	If !oModelSE2D:IsEmpty()
		For i:= 1 to nTotSE2D

			oModelSE2D:Goline(i)

			If Empty(oModelSE2D:GetValue("RV_COD"))
				Loop
			End If

			SE2->(DbGoTo(oModelSE2D:GetValue("RECSE2")))

			Reclock("SE2",.f.)
			SE2->E2_SEFIP := "x"
			MsUnLock()

		Next
	End If

	FWRestRows( aSaveLines )

Return


/*/{Protheus.doc} LoadSRA
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadSRA(oGridModel, lCopy,oModel)

	Local aLoad     := {}
	Local aNewLoad  := {}
	Local i       := 0
	Local oStr    := oGridModel:GetStruct()
	Local nPosCod := oStr:GetArrayPos({"E2_FORNECE"})[1]
	Local nPosPer := oStr:GetArrayPos({"RGB_PERIOD"})[1]
	Local nPosNPG := oStr:GetArrayPos({"RGB_SEMANA"})[1]
	Local nPosPro := oStr:GetArrayPos({"RA_PROCES"})[1]
	Local nPosRot := oStr:GetArrayPos({"RGB_ROTEIR"})[1]
	Local nPos 	  := 0
	Local aPerAtual := {}
	Local cRoteiro := "AUT"

	aLoad := FwLoadByAlias( oGridModel,cAliasFGPE, NIL , Nil , Nil , .t. )

	For i:= 1 to len(aLoad)

		nPos := ASCAN(aNewLoad, { |x| Alltrim(x[2][nPosCod]) == Alltrim(aLoad[i][2][nPosCod]) })

		If nPos == 0

			fGetPerAtual( @aPerAtual, /*Filial*/, aLoad[i][2][nPosPro] , cRoteiro )

			If Len(aPerAtual) > 0
				aLoad[i][2][nPosPer] := MV_PAR06
				aLoad[i][2][nPosNPG] := MV_PAR07
				aLoad[i][2][nPosRot] := RCH->RCH_ROTEIR // Posicionado pela SX1
			End IF

			AADD(aNewLoad,aLoad[i])
		End If

	Next

Return aNewLoad


/*/{Protheus.doc} LoadSE2P
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadSE2P(oGridModel, lCopy,oModel)

	Local aLoad := {}
	Local cCod  := oModel:GetModel("SRADETAIL"):GetValue("E2_FORNECE")
	Local cLoja := oModel:GetModel("SRADETAIL"):GetValue("E2_LOJA")

	cFilter := "ALLTRIM(E2_FORNECE + E2_LOJA) == '" + Alltrim(cCod + cLoja) + "' .AND. Alltrim(E2_TIPO) <> 'NDF'"

	(cAliasFGPE)->(DBClearFilter())
	(cAliasFGPE)->(DBGoTop())

	(cAliasFGPE)->(DbSetFilter({|| &cFilter }, cFilter))

	aLoad := FwLoadByAlias( oGridModel,cAliasFGPE, NIL , Nil , Nil , .t. )

	(cAliasFGPE)->(DBClearFilter())

Return aLoad



/*/{Protheus.doc} LoadSE2D
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadSE2D(oGridModel, lCopy,oModel)

	Local aLoad := {}
	Local cCod  := oModel:GetModel("SRADETAIL"):GetValue("E2_FORNECE")
	Local cLoja := oModel:GetModel("SRADETAIL"):GetValue("E2_LOJA")

	cFilter := "ALLTRIM(E2_FORNECE + E2_LOJA) == '" + Alltrim(cCod + cLoja) + "' .AND. Alltrim(E2_TIPO) == 'NDF'"

	(cAliasFGPE)->(DBClearFilter())
	(cAliasFGPE)->(DBGoTop())

	(cAliasFGPE)->(DbSetFilter({|| &cFilter }, cFilter))

	aLoad := FwLoadByAlias( oGridModel,cAliasFGPE, NIL , Nil , Nil , .t. )

	(cAliasFGPE)->(DBClearFilter())

Return aLoad

/*/{Protheus.doc} LoadRGB
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadRGB(oGridModel, lCopy,oModel)

	Local aLoad 	:= {}
	Local oModelSE2D:= oModel:GetModel("SE2DDETAIL")
	Local oModelSE2P:= oModel:GetModel("SE2PDETAIL")
	Local nTotProv	:= oModelSE2P:Length()
	Local nTotReg 	:= 0
	Local nSemIndi	:= 0

	Local cVerba	:= ""
	Local cDescVerb := ""
	Local nVlrVerb 	:= 0
	Local oStr    	:= oGridModel:GetStruct()
	Local cNatCTCTMS := SuperGetMV("MV_NATCTC",.f.,"")
	Local cNatureza	 := SuperGetMV("MV_YNATFRT",.f.,cNatCTCTMS)

	Local cVerb0218  := POSICIONE("SRV",2,xFilial('SRV') + "0218","RV_COD") //Autonomo
	Local cVerb1565  := POSICIONE("SRV",2,xFilial('SRV') + "1565","RV_COD") //Frete - Sem Incidência
	Local cVerb1564  := POSICIONE("SRV",2,xFilial('SRV') + "1564","RV_COD") //Frete - Incidência IRRF
	Local cVerb1563  := POSICIONE("SRV",2,xFilial('SRV') + "1563","RV_COD") //Frete - Incidência INSS
	Local cVerb0064	 := POSICIONE("SRV",2,xFilial('SRV') + "0064","RV_COD") //Desconto INSS
	Local cVerb0066	 := POSICIONE("SRV",2,xFilial('SRV') + "0066","RV_COD") //Desconto IRRF
	Local cVerb0437	 := POSICIONE("SRV",2,xFilial('SRV') + "0437","RV_COD") //Desconto SEST
	Local cVerb1456	 := POSICIONE("SRV",2,xFilial('SRV') + "1456","RV_COD") //Desconto SENAT
	Local cBase0221	 := POSICIONE("SRV",2,xFilial('SRV') + "0221","RV_COD") //Base INSS
	Local cBase0015	 := POSICIONE("SRV",2,xFilial('SRV') + "0015","RV_COD") //Base IRRF
	Local cBase0047	 := POSICIONE("SRV",2,xFilial('SRV') + "0047","RV_COD") //Liquido

	Local cTipo1	:= "V"
	Local cCentrC	:= oModel:GetModel("SRADETAIL"):GetValue("RA_CC")
	Local acampos	:= Array(Len(oStr:GetFields()))
	Local nPosStrVerb := oStr:GetArrayPos({"RGB_PD"})[1]
	Local nPosStrVlr := oStr:GetArrayPos({"RGB_VALOR"})[1]

	// Como estou buscando a RGB do dicionario, o posicionamento do aLoad tem que ser
	// da mesma forma, se nao, os dados fica em colunas diferentes.
	Local nPosRGB_PD 	 := oStr:GetArrayPos({"RGB_PD"})[1]
	Local nPosRGB_DESCPD := oStr:GetArrayPos({"RGB_DESCPD"})[1]
	Local nPosRGB_TIPO1  := oStr:GetArrayPos({"RGB_TIPO1"})[1]
	Local nPosRGB_DTREF  := oStr:GetArrayPos({"RGB_DTREF"})[1]
	Local nPosRGB_CC  	 := oStr:GetArrayPos({"RGB_CC"})[1]
	Local nPosRGB_VALOR  := oStr:GetArrayPos({"RGB_VALOR"})[1]
	Local lRndSest  	 := SuperGetMv("MV_RNDSEST",.F.,.F.)
	Local aVerbImp		 := {}
	Local nValProv		 := 0
	Local nValDesp		 := 0
	Local nValImp		 := 0
	Local x			     := 0
	Local i 			 := 0

	SED->(DbSetOrder(1))

	For x:= 1 to nTotProv

		oModelSE2P:Goline(x)

		// Posiciona na Natureza
		SED->(DbSeek(xFilial("SED") + oModelSE2P:GetValue("E2_NATUREZ")))

		//Base do IRRF
		nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cBase0015)})
		If nPos == 0
			AADD(aVerbImp, {cBase0015,oModelSE2P:GetValue("BCIRRF")})
		Else
			aVerbImp[nPos][2] += oModelSE2P:GetValue("BCIRRF")
		End if

		//Base do INSS
		nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cBase0221)})
		If nPos == 0
			AADD(aVerbImp, {cBase0221,oModelSE2P:GetValue("E2_BASEINS")})
		ELse
			aVerbImp[nPos][2] += oModelSE2P:GetValue("E2_BASEINS")
		EndiF

		// Verifica se a natureza e para separar Frete INSS, IRRF e sem indicencia
		If Alltrim(oModelSE2P:GetValue("E2_NATUREZ")) $ Alltrim(cNatureza)

			//Frete com indicencia de IRRF - ID 1564
			nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb1564)})
			If nPos == 0
				AADD(aVerbImp, {cVerb1564,oModelSE2P:GetValue("E2_BASEIRF")})
			Else
				aVerbImp[nPos][2] += oModelSE2P:GetValue("E2_BASEIRF")
			End if

			//Frete com indicencia de INSS - ID 1563
			nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb1563)})
			If nPos == 0
				AADD(aVerbImp, {cVerb1563,oModelSE2P:GetValue("E2_BASEINS")})
			ELse
				aVerbImp[nPos][2] += oModelSE2P:GetValue("E2_BASEINS")
			EndiF

			//Frete sem indicencia - ID 1565
			nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb1565)})
			nSemIndi := oModelSE2P:GetValue("E2_VALOR") - oModelSE2P:GetValue("E2_BASEIRF") - oModelSE2P:GetValue("E2_BASEINS")
			If nPos == 0
				AADD(aVerbImp, {cVerb1565,nSemIndi})
			Else
				aVerbImp[nPos][2] += nSemIndi
			End iF

		Else
			// Serrana solicitou que agora o valor da verba do provento seja pego
			// do cadastro da natureza, antes estava pegando tudo do Id de calculo
			// 0218.
			cVerb0218 := oModelSE2P:GetValue("ED_YVERBA")

			//Pagamento Autonomo - ID 0218
			nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb0218)})

			If nPos == 0
				AADD(aVerbImp, {cVerb0218,oModelSE2P:GetValue("E2_VALOR")})
			ELse
				aVerbImp[nPos][2] += oModelSE2P:GetValue("E2_VALOR")
			EndiF

		End if

		// total provento
		nValProv += oModelSE2P:GetValue("E2_VALOR")

		// INSS
		nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb0064)})
		If nPos == 0
			AADD(aVerbImp, {cVerb0064,oModelSE2P:GetValue("E2_INSS")})
		Else
			aVerbImp[nPos][2] += oModelSE2P:GetValue("E2_INSS")
		End iF

		// Valor do INSS
		nValImp += oModelSE2P:GetValue("E2_INSS")

		// IRRF
		nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb0066)})
		If nPos == 0
			AADD(aVerbImp, {cVerb0066,oModelSE2P:GetValue("E2_IRRF")})
		Else
			aVerbImp[nPos][2] += oModelSE2P:GetValue("E2_IRRF")
		EndIf

		// Valor do IRRF
		nValImp += oModelSE2P:GetValue("E2_IRRF")

		//============== Calculo do SEST ============================//

		nValor 	   := oModelSE2P:GetValue("E2_VALOR")
		nPercSEST  := oModelSE2P:GetValue("E2_YPSEST")
		nPercSENAT := oModelSE2P:GetValue("E2_YPSENAT")

		// Verifica se este titulo calculou SEST/SENAT
		If oModelSE2P:GetValue("E2_SEST") > 0
			nBaseSEST := Iif(lRndSest,Round((nValor 	* (SED->ED_BASESES/100)),2),NoRound((nValor    * (SED->ED_BASESES/100)),2))
			nVlrSEST  := Iif(lRndSest,Round((nBaseSEST 	* (nPercSEST/100)),2)  	   ,NoRound((nBaseSEST * (nPercSEST/100)),2))

			// Verifica se ja existe a verba do SEST
			nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb0437)})
			If nPos == 0
				AADD(aVerbImp, {cVerb0437,nVlrSEST })
			Else
				aVerbImp[nPos][2] += nVlrSEST
			EndIf

			// Valor do SEST
			nValImp += nVlrSEST

			//============== Calculo do SENAT ============================//
			nPos := Ascan(aVerbImp,{|w|Alltrim(w[1]) == Alltrim(cVerb1456)})
			If nPos == 0
				AADD(aVerbImp, {cVerb1456,oModelSE2P:GetValue("E2_SEST") - nVlrSEST })
			Else
				// Pega o valor que o financeiro calculou e subtrai o valor do SENAT
				aVerbImp[nPos][2] += oModelSE2P:GetValue("E2_SEST") - nVlrSEST
			EndIf

			// Valor do SENAT
			nValImp += oModelSE2P:GetValue("E2_SEST") - nVlrSEST

		End If
	Next

	SRV->(DbSetOrder(1))

	For i:= 1 to len(aVerbImp)

		SRV->(dbSeek(xFilial("SRV")+aVerbImp[i][1]))

		If aVerbImp[i][2] <> 0
			acampos[nPosRGB_PD] 	:= SRV->RV_COD
			acampos[nPosRGB_DESCPD] := SRV->RV_DESC
			acampos[nPosRGB_TIPO1]  := SRV->RV_TIPO
			acampos[nPosRGB_DTREF]  := RCH->RCH_DTFIM//IIF(SRV->RV_LCTODIA == "S",ddatabase,CTOD("//"))
			acampos[nPosRGB_VALOR]  := aVerbImp[i][2]
			acampos[nPosRGB_CC]     := cCentrC

			aAdd(aLoad,{0,aclone(acampos)})
		End If

	Next

	// Verifica se existem descontos
	If oModel:GetModel("SE2DDETAIL"):IsEmpty()
		nTotReg := 0
	Else
		nTotReg :=  oModelSE2D:Length()
	End If

	//Aglutina as verbas
	For i:= 1 to nTotReg

		oModelSE2D:GoLine(i)

		// Recupera a verba
		cVerba 	 := Alltrim(oModelSE2D:GetValue("RV_COD"))
		// Recupera o valor da verba
		nVlrVerb := oModelSE2D:GetValue("E2_VALOR")
		// Recupera a descricao da verba
		cDescVerb:= oModelSE2D:GetValue("RV_DESC")

		SRV->(DbSetOrder(1))
		SRV->(dbSeek(xFilial("SRV")+cVerba))

		// Verifica se ja foi aglutinado
		nPosVerb := ASCAN(aLoad, { |x| Alltrim(x[2][nPosStrVerb]) == cVerba })

		If nPosVerb > 0
			// Aglutina os valores
			aLoad[nPosVerb][2][nPosStrVlr] += nVlrVerb
		Else
			// Adiciona no array
			acampos[nPosRGB_PD] 	:= cVerba
			acampos[nPosRGB_DESCPD] := cDescVerb
			acampos[nPosRGB_TIPO1]  := cTipo1
			acampos[nPosRGB_DTREF]  := RCH->RCH_DTFIM //IIF(SRV->RV_LCTODIA == 'S', ddatabase , CTOD("//"))
			acampos[nPosRGB_VALOR]  := nVlrVerb
			acampos[nPosRGB_CC]     := cCentrC

			aAdd(aLoad,{i,aclone(acampos)})
		End If

		// Total Despesas
		nValDesp += oModelSE2D:GetValue("E2_VALOR")
	Next

	// Inclui o valor liquido na verbas
	SRV->(DbSetOrder(1))
	SRV->(dbSeek(xFilial("SRV")+cBase0047))

	acampos[nPosRGB_PD] 	:= SRV->RV_COD
	acampos[nPosRGB_DESCPD] := SRV->RV_DESC
	acampos[nPosRGB_TIPO1]  := cTipo1
	acampos[nPosRGB_DTREF]  := RCH->RCH_DTFIM //IIF(SRV->RV_LCTODIA == 'S', ddatabase , CTOD("//"))
	acampos[nPosRGB_VALOR]  := nValProv - nValDesp - nValImp
	acampos[nPosRGB_CC]     := cCentrC

	aAdd(aLoad,{i + 1 ,aclone(acampos)})

Return aLoad


/*/{Protheus.doc} TrabFGPE
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TrabFGPE()

	Local cSepAba    := If("|"$MVABATIM,"|",",")
	Local cSepAnt    := If("|"$MVPAGANT,"|",",")
	Local cSepNeg    := If("|"$MV_CRNEG,"|",",")
	Local cSepProv   := If("|"$MVPROVIS,"|",",")
	Local cSepRec    := If("|"$MVRECANT,"|",",")
	Local cDedIns	 := " 1=1 "
	Local cPrfxInt	 := "%" + FormatIn(SuperGetMV("MV_YPRFINT",.F.,"MED,CRR"),",") + "%"

	Local cFiltAba	 := "%" + FormatIn(MVABATIM,cSepAba)  + "%"
	Local cFiltAnt	 := "%" + FormatIn(MVPAGANT,cSepAnt)  + "%"
	Local cFiltNeg	 := "%" + FormatIn(MV_CRNEG,cSepNeg)  + "%"
	Local cFiltProv  := "%" + FormatIn(MVPROVIS,cSepProv) + "%"
	Local cFiltRec 	 := "%" + FormatIn(MVRECANT,cSepRec)  + "%"
	Local lDedIns	 := (SuperGetMv("MV_INSIRF",.F.,"2") == "1")

	If lDedIns
		cDedIns := " 1=1 "
	Else
		cDedIns := " 1=2 "
	End If

	cDedIns := '%' + cDedIns + '%'

	// Verifica se esta em aberto
	If select (cAliasFGPE) > 0
		(cAliasFGPE)->(DbCloseArea())
	End If

	BeginSQL Alias cAliasFGPE

		SELECT 

		SE2.E2_FILIAL
		,SE2.R_E_C_N_O_ AS RECSE2 
		,SE2.E2_FORNECE
		,SE2.E2_LOJA		
		,SRA.RA_MAT 		 
		,SRA.RA_NOME 
		,SRA.RA_CIC
		,SRA.RA_CC
		,SRA.RA_CATFUNC
		,SRA.RA_PROCES
		,SRA.RA_DEPTO
		,SA2.A2_TIPO
		,SA2.A2_IRPROG
		,'' AS RGB_PERIOD
		,'' AS RGB_SEMANA 
		,'' AS RGB_ROTEIR

		,SE2.E2_NATUREZ
		,SED.ED_DESCRIC
		,SED.ED_YVERBA
		,SE2.E2_PREFIXO
		,SE2.E2_NUM
		,SE2.E2_EMISSAO
		,SE2.E2_PARCELA
		,SE2.E2_TIPO
		//		,SE2.E2_VALOR
		,SE2.E2_VALOR  + SE2.E2_INSS + SE2.E2_IRRF + SE2.E2_PIS + SE2.E2_COFINS + SE2.E2_CSLL + SE2.E2_SEST AS E2_VALOR
		,SE2.E2_ISS

		,CASE SED.ED_CALCIRF WHEN 'S' THEN CASE WHEN SA2.A2_TIPO = 'F' AND %Exp:cDedIns% THEN SE2.E2_BASEIRF - SE2.E2_INSS  ELSE
	CASE SA2.A2_IRPROG WHEN '1' THEN SE2.E2_BASEIRF - SE2.E2_INSS ELSE SE2.E2_BASEIRF END END  ELSE 0 END AS BCIRRF
		,CASE LTRIM(RTRIM(SED.ED_CALCIRF)) WHEN 'S' THEN SE2.E2_BASEIRF ELSE 0 END AS E2_BASEIRF
		,SE2.E2_IRRF
		,CASE LTRIM(RTRIM(SED.ED_CALCINS))  WHEN 'S' THEN SE2.E2_BASEINS ELSE 0 END AS E2_BASEINS
		,SE2.E2_INSS
		,SE2.E2_SEST
		,SE2.E2_YPSEST
		,SE2.E2_YPSENAT
		,SE2.E2_BASECOF
		,SE2.E2_COFINS
		,SE2.E2_BASEPIS
		,SE2.E2_PIS
		,SE2.E2_BASECSL 
		,SE2.E2_CSLL

		,DT7.DT7_CODDES
		,DT7.DT7_DESCRI
		,SRV.RV_COD
		,SRV.RV_DESC
		,SRV.RV_LCTODIA

		FROM %Table:SE2% SE2 

		JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial('SA2')%
		AND SA2.A2_COD = SE2.E2_FORNECE
		AND SA2.A2_LOJA = SE2.E2_LOJA
		AND SA2.D_E_L_E_T_ =''

		// A Serrana atualmente cadastra todos seus funcionarios na empresa 01.
		JOIN SRA010 SRA ON SRA.RA_FILIAL =  '1001' //%Exp:xFilial('SRA')%
		AND SRA.RA_YFORN = SE2.E2_FORNECE
		AND SRA.RA_CATFUNC = 'A'
		AND SRA.RA_SITFOLH <> 'D'
		AND SRA.D_E_L_E_T_ =''

		JOIN %Table:SED% SED ON SED.ED_FILIAL = %Exp:xFilial('SED')%
		AND SED.ED_CODIGO = SE2.E2_NATUREZ
		AND SED.D_E_L_E_T_ =''

		LEFT JOIN %Table:DT7% DT7 ON DT7.DT7_FILIAL = %Exp:xFilial('DT7')%
		AND DT7.DT7_CODDES = SE2.E2_YCODDES
		AND DT7.D_E_L_E_T_ =''

		LEFT JOIN %Table:SRV% SRV ON SRV.RV_FILIAL = %Exp:xFilial('SRV')%
		AND SRV.RV_COD = DT7.DT7_YVERBA
		AND SRV.D_E_L_E_T_ =''


		WHERE SE2.D_E_L_E_T_ =''
		AND SE2.E2_NUMLIQ = '' 
		AND SE2.E2_FATURA <> 'NOTFAT'
		AND SE2.E2_EMISSAO BETWEEN %Exp:DTos(mv_par01)% AND %Exp:DTos(mv_par02)%
		AND SE2.E2_FORNECE BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		AND SE2.E2_TIPO NOT IN %Exp:cFiltAba% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltAnt% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltNeg% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltProv% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltRec% 
		AND SRA.RA_PROCES = %Exp:MV_PAR05%
		AND SE2.E2_FILORIG BETWEEN %Exp:mv_par08% AND %Exp:mv_par09% 
		AND SE2.E2_SEFIP = ''
		AND SE2.E2_PREFIXO IN %Exp:cPrfxInt%
		AND (SED.ED_YVERBA <> '' OR DT7.DT7_YVERBA IS NOT NULL)

	EndSQL

	TcSetField(cAliasFGPE,'E2_EMISSAO','D')

Return


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

/*/{Protheus.doc} criaSX1
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cPerg, characters, description
@type function
/*/
static function criaSX1(cPerg)

	Local aDados := {}

	aAdd( aDados, {cPerg,'01','Emissao De'    , '','','mv_ch01','D',8						,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','Emissao Ate'   , '','','mv_ch02','D',8						,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'03','Fornecedor De' , '','','mv_ch03','C',TAMSX3("A2_COD")[1]		,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
	aAdd( aDados, {cPerg,'04','Fornecedor Ate', '','','mv_ch04','C',TAMSX3("A2_COD")[1]		,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
	aAdd( aDados, {cPerg,'05','Processo' 	  , '','','mv_ch05','C',5						,0,0,'G','Gpem020VldPrc() .and. Gpm020SetVar()','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','RCJ','','','','',''} )
	aAdd( aDados, {cPerg,'06','Periodo'		  , '','','mv_ch06','C',6						,0,0,'G','NaoVazio() .and. Gpm015Per(1, MV_PAR05, MV_PAR06)','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','RCH','','','','',''} )
	aAdd( aDados, {cPerg,'07','Nro. Pagamento', '','','mv_ch07','C',2						,0,0,'G','Gpm015Per(2, MV_PAR05, MV_PAR06, MV_PAR07)','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','RCH01 ','','','','',''} )
	aAdd( aDados, {cPerg,'08','Filial De'     , '','','mv_ch08','C',4						,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','SM0_01','','','','',''} )
	aAdd( aDados, {cPerg,'09','Filial Ate'    , '','','mv_ch09','C',4						,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','SM0_01','','','','',''} )

	U_AtuSx1(aDados)
return
