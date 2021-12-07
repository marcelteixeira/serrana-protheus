#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Parmtype.ch"
#INCLUDE "TOTVS.CH"

Static cAliasDT6 := GetNextAlias()
Static cAliasDA4 := GetNextAlias()
Static cAliasVia := GetNextAlias()

Static aRatCte   := {}
/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel  := Nil

	// Criação da estrutura de dados utilizada na interface

	Local oStDTQ   := FWFormStruct(1, "DTQ")
	Local oStDTR   := FWFormStruct(1, "DTR")
	Local oStDTA   := FWFormStruct(1, "DTA")
	Local oStSDG   := FWFormStruct(1, "SDG")
	Local oStSZ1   := FWFormStruct(1, "SZ1")
	Local oStSZ4   := FWFormStruct(1, "SZ4",{ |x| ALLTRIM(x) $ "Z4_NUM, Z4_DESCRIC" } )
	Local oStSZ5   := FWFormStruct(1, "SZ5")
	//	Local oStDT6   := FWFormStruct(1, "DT6")
	Local bSumSel  := {|| }
	Local bVlSaldo := {|| SaldoMov()}
	Local bFormula := {|oGridModel, lCopy| LoadSZ5(oGridModel, lCopy,oModel)}
	Local bLoadDT6 := {|oGridModel, lCopy| LoadDT6(oGridModel, lCopy,oModel)}
	Local bLoadDA4 := {|oGridModel, lCopy| LoadDA4(oGridModel, lCopy,oModel)}
	Local bCommit  := {|oModel| Commit(oModel)}
	Local bPos	   := {|oModel| TdOkModel(oModel)}
	Local oStDT6   := Nil
	Local oStDA4   := Nil

	// Execulta query
	TrabCte()
	TrabMot()

	oStDT6 := FWFormModelStruct():New()
	oStDT6:AddTable(cAliasDT6,{""},"Conhecimentos",{|| })
	StrMVC(1,cAliasDT6, oStDT6)

	oStDA4 := FWFormModelStruct():New()
	oStDA4:AddTable(cAliasDA4,{""},"Motorista Viagem",{|| })
	StrMVC(1,cAliasDA4, oStDA4)

	oStDTR:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"DTR_YLEGE",;													// [03] Id do Field
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

	oStSZ5:AddField("Valor" ,;										// [01] Titulo do campo 		"Descrição"
	"Valor",;														// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Z5_YVALOR",;													// [03] Id do Field
	"N"	,;															// [04] Tipo do campo
	TamSx3("DTR_VALFRE")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_VALFRE")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	FwBuildFeature(STRUCT_FEATURE_WHEN  , 'IIF(SZ5->Z5_DIGITA == "S",.T.,.F.)')	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD,'0')	,;	            	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.f.	) 															// [14] Virtual

	oStSZ5:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Z5_YLEGE",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(SZ5->Z5_TIPMOV == 'C','BR_VERDE','BR_VERMELHO')"),;	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual


	oStDTR:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"DTR_PERSON",;													// [03] Id do Field
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

	oStSZ1:AddField(	"",; //Título do campo
	"",; //cToolTip
	"Z1_MARK",;// Id do Campo
	"L",; //cTipo
	1,; //Tamanho do Campo
	0,; //Decimal
	{|oModel| ValidMark(oModel)},; //Code-block de validação do campo
	)

	oStSZ1:AddField("" ,;											// [01] Titulo do campo 		"Descrição"
	"",;														    // [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
	"Z1_YLEGE",;													// [03] Id do Field
	"C"	,;															// [04] Tipo do campo
	30,;															// [05] Tamanho do campo
	0,;																// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(SZ1->Z1_VENCTO < DDATABASE,'F10_VERM','F10_VERD')"),;	                    // [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual

	oStDTR:AddField("IRRF" ,;										// [01] Titulo do campo
	"IRRF",;														// [02] ToolTip do campo
	"DTR_IRRF",;													// [03] Id do Field
	"N"	,;															// [04] Tipo do campo
	TamSx3("DTR_VALFRE")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_VALFRE")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD,'0')	,;	            	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual

	oStDTR:AddField("INSS" ,;										// [01] Titulo do campo
	"INSS",;														// [02] ToolTip do campo
	"DTR_INSS",;													// [03] Id do Field
	"N"	,;															// [04] Tipo do campo
	TamSx3("DTR_VALFRE")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_VALFRE")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD,'0')	,;	            	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual

	oStDTR:AddField("SEST" ,;										// [01] Titulo do campo
	"SEST",;														// [02] ToolTip do campo
	"DTR_SEST",;													// [03] Id do Field
	"N"	,;															// [04] Tipo do campo
	TamSx3("DTR_VALFRE")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_VALFRE")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD,'0')	,;	            	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual

	oStDTR:AddField("ISS" ,;										// [01] Titulo do campo
	"ISS",;															// [02] ToolTip do campo
	"DTR_ISS",;														// [03] Id do Field
	"N"	,;															// [04] Tipo do campo
	TamSx3("DTR_VALFRE")[1],;										// [05] Tamanho do campo
	TamSx3("DTR_VALFRE")[2],;										// [06] Decimal do campo
	{ || .T. }	,;													// [07] Code-block de validação do campo
	{ || .F. }	,;													// [08] Code-block de validação When do campo
	,;																// [09] Lista de valores permitido do campo
	.F.	,;															// [10]	Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD,'0')	,;	            	// [11] Inicializador Padrão do campo
	,; 																// [12]
	,; 																// [13]
	.T.	) 															// [14] Virtual

	// Todos os campos bloqueados
	oStDTQ:SetProperty( '*'  	  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStDTR:SetProperty( '*'  	  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStDTA:SetProperty( '*'  	  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZ1:SetProperty( '*'       , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZ4:SetProperty( '*'       , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStSZ5:SetProperty( '*'       , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStDT6:SetProperty( '*'       , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))
	oStDA4:SetProperty( '*'       , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.' ))

	// Campos permitidos para alteracao.
//	oStDTR:SetProperty( 'DTR_YNUMCO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' )) 
//	oStDTR:SetProperty( 'DTR_YAGENC', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' )) 
//	oStDTR:SetProperty( 'DTR_YBANCO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' )) 
	oStDTR:SetProperty( 'DTR_YFRTAD', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDTR:SetProperty( 'DTR_VALFRE', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDTQ:SetProperty( 'DTQ_YFREID', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDTR:SetProperty( 'DTR_IRRF'	, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDTR:SetProperty( 'DTR_INSS'	, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDTR:SetProperty( 'DTR_SEST'	, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStDTR:SetProperty( 'DTR_ISS'	, MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZ5:SetProperty( 'Z5_YVALOR' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , 'StaticCall(SERTMS03,WhenValor)'))
	oStSZ1:SetProperty( 'Z1_SALDO'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))
	oStSZ1:SetProperty( 'Z1_MARK'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.T.' ))

	// Inicializacoes Padroes
	oStSZ1:SetProperty( 'Z1_MARK'   , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, '.F.'))

	// Todos os campos validos
	oStDTQ:SetProperty( '*'  	  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , '.T.' ))
	oStDTR:SetProperty( '*'  	  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , '.T.' ))
	oStDTA:SetProperty( '*'  	  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , '.T.' ))
	oStSZ5:SetProperty( '*'  	  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , '.T.' ))

	oStSZ1:SetProperty( 'Z1_SALDO', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'StaticCall(SERTMS03,ValidSaldo)'))

	aAuxGat := FwStruTrigger("DTR_VALFRE","DTR_VALFRE","StaticCall(SERTMS03,FrtLiq)",.F.,Nil,Nil,Nil)
	oStDTR:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	aAuxGat := FwStruTrigger("DTR_VALFRE","DTR_YFRTAD","StaticCall(SERTMS03,CalcAdia)",.F.,Nil,Nil,Nil)
	oStDTR:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	aAuxGat := FwStruTrigger("Z5_YVALOR","Z5_YVALOR","StaticCall(SERTMS03,AtulizFrt)",.F.,Nil,Nil,Nil)
	oStSZ5:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	// Cria o modelo
	oModel := MPFormModel():New("MSERTMS03",/*bPre*/, bPos,bCommit,/*bCancel*/)

	// É necessário que haja alguma alteração na estrutura Field
	oModel:SetActivate({ |oModel| ForceValue(oModel)})

	oModel:AddFields("DTQMASTER",/*cOwner*/	, oStDTQ	,/*bPreValidacao*/,/*bPosVldMdl*/,/*[ bLoad ]*/)

	// Atribuindo Grid ao modelo
	oModel:AddGrid( "DTRDETAIL", "DTQMASTER",oStDTR, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "DT6DETAIL", "DTQMASTER",oStDT6, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/,bLoadDT6 /*[ bLoad ]*/)
	oModel:AddGrid( "DA4DETAIL", "DTQMASTER",oStDA4, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/,bLoadDA4 /*[ bLoad ]*/)

	// Atenç˜ão este modelo de dados sempre tem que vim do banco, pois utilizo  oModelSZ1:GetDataId() na função da BaixSZ1()
	// se for realizar o bLoad para este grid se atentar colocar os RECNO certos.
	oModel:AddGrid( "SZ1DETAIL", "DTRDETAIL",oStSZ1, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "SDGDETAIL", "DTRDETAIL",oStSDG, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "DTADETAIL", "DTQMASTER",oStDTA, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "SZ4DETAIL", "DTQMASTER",oStSZ4, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)
	oModel:AddGrid( "SZ5DETAIL", "SZ4DETAIL",oStSZ5, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, bFormula/*[ bLoad ]*/)

	// Criando Relacionamentos
	oModel:SetRelation("DTRDETAIL", {{"DTR_FILIAL","FwXFilial('DTR')"}, {"DTR_FILORI","DTQ_FILORI"}, {"DTR_VIAGEM","DTQ_VIAGEM"}  }, DTR->( IndexKey( 1 ) ) )
	oModel:SetRelation("DTADETAIL", {{"DTA_FILIAL","FwXFilial('DTA')"}, {"DTA_SERTMS","DTQ_SERTMS"}, {"DTA_TIPTRA","DTQ_TIPTRA"} , {"DTA_FILORI","DTQ_FILORI"} , {"DTA_VIAGEM","DTQ_VIAGEM"} }, DTA->( IndexKey( 4 ) ) )
	oModel:SetRelation("SZ1DETAIL", {{"Z1_FILIAL" ,"FwXFilial('SZ1')"}, {"Z1_FORNECE","StaticCall(SERTMS03,GetCodFor,'DTR_CODFOR')"}, {"Z1_LOJA","StaticCall(SERTMS03,GetCodFor,'DTR_LOJFOR')"}  }, SZ1->( IndexKey( 4 ) ) )
	oModel:SetRelation("SZ4DETAIL", {{"Z4_FILIAL","FwXFilial('SZ4')"}}, SZ4->( IndexKey( 1 ) ) )
	oModel:SetRelation("SZ5DETAIL", {{"Z5_FILIAL","FwXFilial('SZ5')"} , {"Z5_NUM", "oModel:GetModel('SZ4DETAIL'):GetValue('Z4_NUM')"} }, SZ5->( IndexKey( 1 ) ) )

	// Informa filtro - Todos os descontos vencitos até hoje.
	oModel:GetModel( "SZ1DETAIL" ):SetLoadFilter( { { "Z1_VENCTO", "'" + DTOS(DDATABASE) + "'", MVC_LOADFILTER_LESS_EQUAL } ,  { "Z1_SALDO", "0", MVC_LOADFILTER_GREATER }} )

	bSumSel :=  {|| oModel:GetModel("SZ1DETAIL"):Getvalue("Z1_MARK") == .T. }

	//Calculos
	oModel:AddCalc("CALC_MFRT"	,"DTQMASTER" ,"DTRDETAIL","DTR_VALFRE"	,"DTR_VALFRE_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Frete Combinado"   ,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_CMV"	,"DTRDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"Z1_SALDO_T"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Saldo Total"   ,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_CMV"	,"DTRDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"Z1_SALDO_S"	,"SUM" 		, bSumSel/*bCondition*/,  /*bInitValue*/,"R$ À Descontar"   , /*bFormula*/ ,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_FRT"	,"SZ4DETAIL" ,"SZ5DETAIL","Z5_YVALOR"	,"Z5_YVALOR_C"	,"SUM" 		, {|| oModel:GetModel("SZ5DETAIL"):Getvalue("Z5_TIPMOV") == "C" } /*bCondition*/,  /*bInitValue*/,"R$ À Crédito"   ,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_FRT"	,"SZ4DETAIL" ,"SZ5DETAIL","Z5_YVALOR"	,"Z5_YVALOR_D"	,"SUM" 		, {|| oModel:GetModel("SZ5DETAIL"):Getvalue("Z5_TIPMOV") == "D" } /*bCondition*/,  /*bInitValue*/,"R$ À Débito"    ,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_FRT"	,"SZ4DETAIL" ,"SZ5DETAIL","Z5_YVALOR"	,"FreteIdeal"	,"FORMULA" 	, /*bCondition*/,  /*bInitValue*/,"R$ Frete Ideal" ,bVlSaldo/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_MFRT"	,"DTQMASTER" ,"DTRDETAIL","DTR_VALFRE"	,"DIFERENCA"	,"FORMULA" 	, /*bCondition*/,  /*bInitValue*/,"R$ Ganho/Perda Frete" 	,{|| DifFrete()}/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_MFRT"	,"DTQMASTER" ,"DTRDETAIL","DTR_VALFRE"	,"PERCREPASS"   ,"FORMULA" 	, /*bCondition*/,  /*bInitValue*/,"% Repasse"   		 	,{|| PercRepas()}/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_MFRT"	,"DTQMASTER" ,"DTRDETAIL","DTR_VALFRE"	,"PERCAPROVE"   ,"FORMULA" 	, /*bCondition*/,  /*bInitValue*/,"% Aproveitamento"  		,{|| PercAprov()}/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_RCOO"	,"DTRDETAIL" ,"DTRDETAIL","DTR_VALFRE"	,"FRTCOMBCO"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Frete Combinado (Base p/ Imp.)"   	,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_RCOO"	,"DTRDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"Z1_SALDO_S"	,"SUM" 		, bSumSel/*bCondition*/,  /*bInitValue*/,"R$ Total Descontos"   , /*bFormula*/ ,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_RCOO"	,"DTRDETAIL" ,"SZ1DETAIL","Z1_SALDO"	,"FRTLIQUIDO"	,"FORMULA"  , /*bCondition*/,  /*bInitValue*/,"R$ Frete Bruto a Receber (S/ Imp.)"   	,{|| FrtLiq(.t.)} /*bFormula*/ ,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_DOCFRT","DTQMASTER" ,"DT6DETAIL","DT6_DOC"   	,"DT6_DOC_Q"	,"COUNT" 	, /*bCondition*/,  /*bInitValue*/,"Qtd. Ct-e"   	,/*bFormula*/,TAMSX3("DT6_QTDVOL")[1] /*nTamanho*/,TAMSX3("DT6_QTDVOL")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_DOCFRT","DTQMASTER" ,"DT6DETAIL","DT6_VALTOT"	,"DT6_VALTOT_S"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Total Frete"   ,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_DOCFRT","DTQMASTER" ,"DT6DETAIL","DT6_PESO"  	,"DT6_PESO_S"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"Total Peso"   	,/*bFormula*/,TAMSX3("DT6_PESO")[1] /*nTamanho*/,TAMSX3("DT6_PESO")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_DOCFRT","DTQMASTER" ,"DT6DETAIL","DT6_QTDVOL"	,"DT6_QTDVOL_S"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"Total Volume"   	,/*bFormula*/,TAMSX3("DT6_QTDVOL")[1] /*nTamanho*/,TAMSX3("DT6_QTDVOL")[2] /*nDecimal*/)
	oModel:AddCalc("CALC_DOCFRT","DTQMASTER" ,"DT6DETAIL","DT6_VALMER"	,"DT6_VALMER_S"	,"SUM" 		, /*bCondition*/,  /*bInitValue*/,"R$ Total Mercad.",/*bFormula*/,TAMSX3("DT6_VALMER")[1] /*nTamanho*/,TAMSX3("DT6_VALMER")[2] /*nDecimal*/)

	//	oModel:AddCalc("CALC_RCOO"	,"DTRDETAIL" ,"DTRDETAIL","DTR_IRRF"	,"IRRF"	,"SUM" 	, /*bCondition*/,  /*bInitValue*/,"R$ IRRF" 	,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	//	oModel:AddCalc("CALC_RCOO"	,"DTRDETAIL" ,"DTRDETAIL","DTR_INSS"	,"INSS" ,"SUM" 	, /*bCondition*/,  /*bInitValue*/,"R$ INSS"   	,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	//	oModel:AddCalc("CALC_RCOO"	,"DTRDETAIL" ,"DTRDETAIL","DTR_SEST"	,"SEST" ,"SUM" 	, /*bCondition*/,  /*bInitValue*/,"R$ SEST"  	,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	//	oModel:AddCalc("CALC_RCOO"	,"DTRDETAIL" ,"DTRDETAIL","DTR_ISS"	,"ISS"  ,"SUM" 	, /*bCondition*/,  /*bInitValue*/,"R$ ISS"  	,/*bFormula*/,TAMSX3("DTR_VALFRE")[1] /*nTamanho*/,TAMSX3("DTR_VALFRE")[2] /*nDecimal*/)
	//
	//
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({})

	// Apenas Consultas
	//oModel:GetModel("DTQMASTER"):SetOnlyQuery(.T.)
	oModel:GetModel("SZ1DETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("SDGDETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("DTADETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("SZ4DETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("SZ5DETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("DT6DETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("DA4DETAIL"):SetOnlyQuery(.T.)

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)

	// Permite salvar o GRID sem dados.
	oModel:GetModel( "SDGDETAIL" ):SetOptional( .T. )
	oModel:GetModel( "SZ1DETAIL" ):SetOptional( .T. )

	//Adicionando descrição ao modelo
	oModel:SetDescription("Tela de Frete Ideial")

	//Descricoes dos modelos de dados
	oModel:GetModel("DTQMASTER"):SetDescription("Dados da Viagem")
	oModel:GetModel("DTRDETAIL"):SetDescription("Veiculos")
	oModel:GetModel("DTADETAIL"):SetDescription("Documentos da Viagem")

	oModel:GetModel("DTRDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("DTRDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("DTADETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("DTADETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("DTRDETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("DTRDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SZ1DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SZ1DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SZ4DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SZ4DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("SZ5DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("SZ5DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("DT6DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("DT6DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("DA4DETAIL"):SetNoDeleteLine(.T.); oModel:GetModel("DA4DETAIL"):SetNoInsertLine(.T.)

	//Verifica se realiza ativição do Modelo
	oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )

Return oModel


/*/{Protheus.doc} WhenValor
@author Totvs Vitoria - Mauricio Silva
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function WhenValor()
	Local oModel := FwModelActive()
	Local lRet := oModel:GetModel("SZ5DETAIL"):GetValue("Z5_DIGITA") == "S"

Return lRet


/*/{Protheus.doc} CalcAdia
Calcula o percentual de adiantamento conforme parametro
@author Totvs Vitoria - Mauricio Silva
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CalcAdia()

	Local oModel    := FwModelActive()
	Local oModelDTR := oModel:GetModel("DTRDETAIL")
	Local nFrtComb	:= oModelDTR:GetValue("DTR_VALFRE")
	Local nPercAdi  := SuperGetMV("MV_YPFADI",.F.,80)
	Local nAdiFrt	:= nFrtComb * (nPercAdi /100)

	Local cBanco	:= SuperGetMV("MV_YBCFRT",.f.,"")
	Local cAgencia	:= SuperGetMV("MV_YAGFRT",.f.,"")
	Local cConta	:= SuperGetMV("MV_YCOFRT",.f.,"")

//	If Empty(oModelDTR:GetValue("DTR_YBANCO")) .and. Empty(oModelDTR:GetValue("DTR_YAGENC")) .and. Empty(oModelDTR:GetValue("DTR_YNUMCO"))
//		oModelDTR:SetValue("DTR_YBANCO",cBanco)
//		oModelDTR:SetValue("DTR_YAGENC",cAgencia)
//		oModelDTR:SetValue("DTR_YNUMCO",cConta)
//	End if

Return nAdiFrt

/*/{Protheus.doc} ValidActv
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function ValidActv( oModel )

	Local lRet 	:= .t.
	Local cMsg	:= ""
	Local cSolu	:= ""

	DTY->(DbSetOrder(2))

	If DTY->(DbSeek(xFilial("DTY") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
		cMsg  := "Viagem ja possuem contrato. (" + DTY->DTY_NUMCTC + ")"
		cSolu := "Favor estornar o contrato ou escolha uma outra viagem."
		Help(NIL, NIL, "SERTMS03 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End if

	DTA->(DbSetOrder(2))

	If DTA->(DbSeek(xFilial("DTA") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))

		While DTA->(!EOF()) .AND. DTA->(DTA_FILIAL + DTA_FILORI + DTA_VIAGEM) == xFilial("DTA") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)

			DT6->(DbSetOrder(1))
			//DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE, R_E_C_N_O_, D_E_L_E_T_

			If DT6->(DbSeek(xFilial("DT6") + DTA->(DTA_FILDOC + DTA_DOC + DTA_SERIE)))

				If Alltrim(DT6->DT6_IDRCTE) == "100" .or. ! Empty(DT6->DT6_CHVCTG) .or. Alltrim(DT6->DT6_IDRCTE) == "136"
					lRet := .t.
				Else
					cMsg  := "O documento " + Alltrim(DT6->DT6_DOC) + "/" + Alltrim(DT6->DT6_SERIE) + " - CT-e não autorizado ou não enviado para Sefaz.(DT6_IDRCTE)"
					cSolu := "Favor verificar tal documento antes de gerar o contrato de carreteiro."
					Help(NIL, NIL, "SERTMS03 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
					Return .f.
				End If
			End if

			DTA->(DbSkip())
		EndDo
	Else
		cMsg  := "Esta viagem não possui documentos carregados."
		cSolu := "Favor realizar o carregamento antes de gerar o contrato de carreteiro"
		Help(NIL, NIL, "SERTMS03 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End if

Return lRet



/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function ViewDef()

	// Recupera o modelo de dados
	Local oModel   := FWLoadModel("SERTMS03")
	Local aStrDTQ  := StrDTQ()
	Local oStDTQ   := StrucView("DTQ",aStrDTQ)
	Local oStDTR   := StrucView("DTR",{'DTR_CODVEI','DTR_MODVEI','DTR_PROVEI','DTR_VALFRE','DTR_YFRTAD'})//,'DTR_YFRTAD','DTR_YBANCO','DTR_YAGENC','DTR_YNUMCO'
	Local oStDTA   := StrucView("DTA")
	Local oStSZ1   := StrucView("SZ1",{"Z1_MARK","Z1_YLEGE","Z1_DESPESA","Z1_SALDO","Z1_NUM","Z1_PARCELA","Z1_EMISSAO","Z1_VENCTO","Z1_VALOR","Z1_HISTORI"})
	Local oStSDG   := FWFormStruct(2, "SDG")
	Local oStSZ4   := FWFormStruct(2, "SZ4",{ |x| ALLTRIM(x) $ "Z4_NUM,Z4_DESCRIC" } )
	Local oStSZ5   := FWFormStruct(2, "SZ5",{ |x| ALLTRIM(x) $ "Z5_TIPMOV,Z5_DESCRIC,Z5_DIGITA" } )
	Local oStDT6   := FWFormViewStruct():New()
	Local oStDA4   := FWFormViewStruct():New()
	Local oCalcCMV := FWCalcStruct(oModel:GetModel("CALC_CMV"))
	Local oCalcFRT := FWCalcStruct(oModel:GetModel("CALC_FRT"))
	Local oCalcMFRT:= FWCalcStruct(oModel:GetModel("CALC_MFRT"))
	Local oCalcRCOO:= FWCalcStruct(oModel:GetModel("CALC_RCOO"))
	Local oCalcDocF:= FWCalcStruct(oModel:GetModel("CALC_DOCFRT"))


	Local oView := Nil

	SetKey( VK_F4 , {|| AtulizFrt()} )

	// Monta Estrutura da View conforme Alias passado.
	StrMVC(2,cAliasDT6  , oStDT6)
	StrMVC(2,cAliasDA4  , oStDA4)

	oStDTR:AddField("DTR_YLEGE",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStDTR:AddField("DTR_PERSON",; //Id do Campo
	"02",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStSZ5:AddField("Z5_YLEGE",; //Id do Campo
	"02",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	oStSZ5:AddField("Z5_YVALOR",; //Id do Campo
	"99",; //Ordem
	"Valor",;// Título do Campo
	"Valor",; //Descrição do Campo
	{},; //aHelp
	"N",; //Tipo do Campo
	X3Picture("DTR_VALFRE")  )//cPicture

	oStSZ1:AddField("Z1_MARK",; //Id do Campo
	"00",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"")//cPicture

	oStSZ1:AddField("Z1_YLEGE",; //Id do Campo
	"01",; //Ordem
	"",;// Título do Campo
	"",; //Descrição do Campo
	{},; //aHelp
	"L",; //Tipo do Campo
	"@BMP"  )//cPicture

	//    oStDTR:AddField("DTR_IRRF",; //Id do Campo
	//                    "99",; //Ordem
	//                    "IRRF",;// Título do Campo
	//                    "IRRF",; //Descrição do Campo
	//                    {},; //aHelp
	//                    "N",; //Tipo do Campo
	//                    X3Picture("DTR_VALFRE")  )//cPicture
	//
	//    oStDTR:AddField("DTR_INSS",; //Id do Campo
	//                    "99",; //Ordem
	//                    "INSS",;// Título do Campo
	//                    "INSS",; //Descrição do Campo
	//                    {},; //aHelp
	//                    "N",; //Tipo do Campo
	//                    X3Picture("DTR_VALFRE")  )//cPicture
	//
	//
	//    oStDTR:AddField("DTR_SEST",; //Id do Campo
	//                    "99",; //Ordem
	//                    "SEST",;// Título do Campo
	//                    "SEST",; //Descrição do Campo
	//                    {},; //aHelp
	//                    "N",; //Tipo do Campo
	//                    X3Picture("DTR_VALFRE")  )//cPicture
	//
	//    oStDTR:AddField("DTR_ISS",; //Id do Campo
	//                    "99",; //Ordem
	//                    "ISS",;// Título do Campo
	//                    "ISS",; //Descrição do Campo
	//                    {},; //aHelp
	//                    "N",; //Tipo do Campo
	//                    X3Picture("DTR_VALFRE")  )//cPicture


	oStSZ1:SetProperty( "Z1_SALDO"  , MVC_VIEW_CANCHANGE ,.T.)
	oStSZ4:SetProperty( "Z4_DESCRIC", MVC_VIEW_CANCHANGE ,.F.)
	oStSZ4:SetProperty( "Z4_NUM"  	, MVC_VIEW_LOOKUP , "SZ4")


	//	oStDTR:SetProperty( "DTR_IRRF"  , MVC_VIEW_CANCHANGE ,.F.)
	//	oStDTR:SetProperty( "DTR_INSS"  , MVC_VIEW_CANCHANGE ,.F.)
	//	oStDTR:SetProperty( "DTR_SEST"  , MVC_VIEW_CANCHANGE ,.F.)
	//	oStDTR:SetProperty( "DTR_ISS"   , MVC_VIEW_CANCHANGE ,.F.)

	oStDTR:SetProperty( "*"    		, MVC_VIEW_WIDTH, 080 )
	oStDTR:SetProperty( "DTR_VALFRE", MVC_VIEW_WIDTH, 098 )
	oStDTR:SetProperty( "DTR_YFRTAD", MVC_VIEW_WIDTH, 098 )
	oStDTR:SetProperty( "DTR_PROVEI", MVC_VIEW_WIDTH, 230 )

	oStSZ5:SetProperty( "Z5_DESCRIC", MVC_VIEW_WIDTH, 150 )
	oStSZ5:SetProperty( "Z5_YVALOR" , MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_DESPESA", MVC_VIEW_WIDTH, 200 )
	oStSZ1:SetProperty( "Z1_SALDO"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_NUM"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_PARCELA", MVC_VIEW_WIDTH, 070 )
	oStSZ1:SetProperty( "Z1_VALOR"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_EMISSAO", MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_VENCTO"	, MVC_VIEW_WIDTH, 080 )
	oStSZ1:SetProperty( "Z1_HISTORI", MVC_VIEW_WIDTH, 090 )

	oStDT6:SetProperty( "DT6_NOMREM", MVC_VIEW_WIDTH, 250 )
	oStDT6:SetProperty( "DT6_NOMDES", MVC_VIEW_WIDTH, 250 )

	oStDA4:SetProperty( "DA4_COD"	, MVC_VIEW_WIDTH, 080 )
	oStDA4:SetProperty( "DA4_RG"	, MVC_VIEW_WIDTH, 080 )
	oStDA4:SetProperty( "DA4_DTVCNH", MVC_VIEW_WIDTH, 150 )
	oStDA4:SetProperty( "DA4_NOME"	, MVC_VIEW_WIDTH, 250 )

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	// ESQUEDA
	oView:AddGrid("VIEW_SZ4"        , oStSZ4  	, "SZ4DETAIL") // Tabela
	oView:AddGrid("VIEW_SZ5"  		, oStSZ5	, "SZ5DETAIL") // Formulas
	oView:AddField("VIEW_CALC_FRT"  , oCalcFRT  , "CALC_FRT")  // Resultado
	oView:AddField("VIEW_CALC_MFRT" , oCalcMFRT  , "CALC_MFRT")  // Resultado

	// DIRETA
	oView:AddGrid("VIEW_DTR"  		, oStDTR	, "DTRDETAIL") // Veiculos
	oView:AddGrid("VIEW_SZ1"  		, oStSZ1	, "SZ1DETAIL") // CMV
	oView:AddGrid("VIEW_DT6"  		, oStDT6  	, "DT6DETAIL") // Documentos Viagem
	oView:AddGrid("VIEW_DA4"  		, oStDA4	, "DA4DETAIL") // Formulas

	oView:AddField("VIEW_CALC_CMV"  , oCalcCMV  , "CALC_CMV") // Totais CMV
	oView:AddField("VIEW_CALC_RCOO" , oCalcRCOO , "CALC_RCOO") // Totais CMV

	oView:AddField("VIEW_CALC_DOCFRT" , oCalcDocF , "CALC_DOCFRT") // Totais Conhecimentos

	oView:CreateVerticalBox( "ESQUERDA", 035 )
	oView:CreateVerticalBox( "MEIO"    , 0.5 )
	oView:CreateVerticalBox( "DIRETA"  , 064.5 )

	//Criando os paineis
	oView:CreateHorizontalBox("TABELA"  ,015 ,"ESQUERDA")
	oView:CreateHorizontalBox("TABFORM" ,043 ,"ESQUERDA")
	oView:CreateHorizontalBox("FRTIDEAL",021 ,"ESQUERDA")
	oView:CreateHorizontalBox("FRTCOMBI",021 ,"ESQUERDA")

	oView:CreateHorizontalBox("SUPERIOR",015,"DIRETA")
	oView:CreateHorizontalBox("INFERIOR",064,"DIRETA")
	oView:CreateHorizontalBox("RESULTCO",021,"DIRETA")

	oView:CreateFolder("FOLDER_INF","INFERIOR")

	//oView:AddSheet("FOLDER_INF", "ABA_DEP" , "Dependentes" )

	oView:AddSheet("FOLDER_INF", "ABA_CMV" , "CMV Cooperado" )

	oView:CreateHorizontalBox("BOX_1_CMV" , 064.5 ,,, "FOLDER_INF", 'ABA_CMV')
	oView:CreateHorizontalBox("BOX_2_CMV" , 035.5 ,,, "FOLDER_INF", 'ABA_CMV')

	oView:AddSheet("FOLDER_INF", "ABA_CTE"  , "Conhecimentos da Viagem" )
	oView:CreateHorizontalBox("BOX_1_CTE" , 064.5 ,,, "FOLDER_INF", 'ABA_CTE')
	oView:CreateHorizontalBox("BOX_2_CTE" , 035.5 ,,, "FOLDER_INF", 'ABA_CTE')

	oView:AddSheet("FOLDER_INF", "ABA_MOT"  , "Motoristas" )
	oView:CreateHorizontalBox("BOX_1_MOT" , 100 ,,, "FOLDER_INF", 'ABA_MOT')


	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	oView:SetOwnerView("VIEW_SZ4","TABELA")
	oView:SetOwnerView("VIEW_SZ5","TABFORM")
	oView:SetOwnerView("VIEW_CALC_FRT","FRTIDEAL")
	oView:SetOwnerView("VIEW_CALC_MFRT","FRTCOMBI")

	oView:SetOwnerView("VIEW_DTR","SUPERIOR")
	oView:SetOwnerView("VIEW_SZ1","BOX_1_CMV")

	//oView:SetOwnerView("VIEW_SDG","BOX_1_CMV")

	oView:SetOwnerView("VIEW_CALC_CMV","BOX_2_CMV")

	oView:SetOwnerView("VIEW_DT6","BOX_1_CTE")
	oView:SetOwnerView("VIEW_DA4","BOX_1_MOT")
	oView:SetOwnerView("VIEW_CALC_DOCFRT","BOX_2_CTE")

	oView:SetOwnerView("VIEW_CALC_RCOO","RESULTCO")

	oView:EnableTitleView("VIEW_DTR"     , "Veiculos Envolvidos" )
	oView:EnableTitleView("VIEW_SZ4"	 , "Tabelas Formulas" )
	oView:EnableTitleView("VIEW_SZ5"	 , "Cálculo do Frete" )
	oView:EnableTitleView("VIEW_CALC_FRT", "Frete Ideal ")
	oView:EnableTitleView("VIEW_CALC_MFRT", "Frete Combinado" )
	oView:EnableTitleView("VIEW_CALC_CMV", "Totais CMV" )
	oView:EnableTitleView("VIEW_CALC_RCOO", "Totais do Cooperado" )
	oView:EnableTitleView("VIEW_CALC_DOCFRT", "Totais Conhecimentos da Viagem" )

	oView:SetViewProperty( 'VIEW_SZ4', "CHANGELINE", {{ |oView, cViewID| ChangeLine(oView, cViewID) }} )

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

	// Inicia o valor do frete combinado igual ao valor do frete ideal
	oView:SetAfterViewActivate({||AtulizFrt() })

	oView:setUpdateMessage("Geração Contrato", "Realizada com sucesso!!")

Return oView


/*/{Protheus.doc} AtulizFrt
Atualiza as informacoes do valor do frete combinado igual o frete ideal.
@author Totvs Vitoria - Mauricio Silva
@since 27/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AtulizFrt()

	Local oModel := FwModelActive()
	Local oModelDTR := oModel:GetModel("DTRDETAIL")
	Local oModelSZ5	:= oModel:GetModel("SZ5DETAIL")
	Local oModelSZ1	:= oModel:GetModel("SZ1DETAIL")
	Local nTotReg	:= oModelSZ5:Length()
	Local i := 0
	Local nCredito := 0
	Local nDebito	:= 0
	Local oView		:= FwViewActive()
	Local aSaveLines := FWSaveRows()

	For i:= 1 to nTotReg

		oModelSZ5:Goline(i)

		If oModelSZ5:GetValue("Z5_TIPMOV") == 'C'
			nCredito += oModelSZ5:GetValue("Z5_YVALOR")
		Else
			nDebito += oModelSZ5:GetValue("Z5_YVALOR")
		End IF

	Next

	oModelDTR:SetValue("DTR_VALFRE",nCredito - nDebito)

	If oModelSZ1:IsEmpty()
		oModelSZ1:SetNoUpdateLine(.t.)
	Else
		oModelSZ1:SetNoUpdateLine(.f.)
	End If

	oView:Refresh("VIEW_DTR")

	FWRestRows( aSaveLines )
Return


/*/{Protheus.doc} TdOkModel
Validacao do TudoOK do modelo de dados
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/

Static Function TdOkModel(oModel)

	Local lRet := .t.
	Local oModelFRT  := oModel:GetModel("CALC_FRT")
	Local oModelDTR  := oModel:GetModel("DTRDETAIL")
	Local oModelDTQ	 := oModel:GetModel("DTQMASTER")
	Local nFrtIdeal  := 0
	Local nReg		 := oModelDTR:Length()
	Local nLinPos 	 := oModelDTR:GetLine()
	Local i 		 := 0
	Local cMsg	     := ""
	Local cSolu		 := ""

	// Recupera o valor do Frete Ideal da tabela posicionada
	nFrtIdeal:= oModelFRT:GetValue("FreteIdeal")

	For i := 1 to nReg

		oModelDTR:Goline(i)

		// Verifica se o valor do Frete foi informado.
		If oModelDTR:GetValue("DTR_VALFRE") == 0

			cMsg  := "Não foi informado Frete Combinado para o veiculo: " + oModelDTR:GetValue("DTR_CODVEI")
			cSolu := "Favor informar o valor do Frete."
			Help(NIL, NIL, "SERTMS03 - TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.

		End If

		// Verifica se foi informado valor de adiantamento e nao foi informado
		// os dados bancarios que e obrigatorio neste situacao.

//		If  oModelDTR:GetValue("DTR_YFRTAD") > 0 ;
//		.and. Empty(oModelDTR:GetValue("DTR_YBANCO")) ;
//		.and. Empty(oModelDTR:GetValue("DTR_YAGENC")) ;
//		.and. Empty(oModelDTR:GetValue("DTR_YNUMCO"))
//			
//			cMsg  := "Quando informado valor do adiantamento, deve ser informado os dados bancarios."
//			cSolu := "Favor preencher os dados bancarios para efetuar o adiantamento."
//			Help(NIL, NIL, "SERTMS03 - TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
//			Return .f.
//		End If 

		//Atualiza o valor do Frete Ideal para calculo da comissão posteriomente.
		If !oModelDTQ:SetValue("DTQ_YFREID", nFrtIdeal)

			cMsg := GetErroModel(oModel)
			cSolu := ""
			Help(NIL, NIL, "SERTMS03 - TdOkModel", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.
		End If
	Next

Return lRet


Static Function MsgCalcImp()

	FWMsgRun(, {|| CalcImp() }	, "Processando", "Calculando Impostos do Carreteiro...")

Return

/*/{Protheus.doc} CalcImp
Calculo do imposto para o fornecedor.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/

Static Function CalcImp()

	Local aAreaSE2	 := SE2->(GetArea())
	Local aAerea	 := GetArea()
	Local oModel	 := FwModelActive()
	Local oModelDTR	 := oModel:GetModel("DTRDETAIL")
	Local nValFrete  := oModelDTR:GetValue("DTR_VALFRE")
	Local nTotValAdi := oModelDTR:GetValue("DTR_ADIFRE")
	Local cCodFor    := GetCodFor("DTR_CODFOR")
	Local cLojFor    := GetCodFor("DTR_LOJFOR")
	Local nINSSRET   := oModelDTR:GetValue("DTR_INSRET")
	Local cFilORi	 := oModelDTR:GetValue("DTR_FILORI")
	Local cViagem	 := oModelDTR:GetValue("DTR_VIAGEM")
	Local cCnpjFor	 := ""
	Local cNatuCTC   := ""
	Local lTM250Par  := ExistBlock('TM250PAR')

	Local nValIRRF	:= 0
	Local nValINSS	:= 0
	Local nValSEST	:= 0
	Local nValISS	:= 0
	Local nValRetPIS:= 0
	Local nValRetCOF:= 0
	Local nBasImp	:= 0
	Local nOpcx 	:= 3
	Local cContrat 	:= ""
	Local cTipCont  := "1" // Por Viagem
	Local cGerPC	:= "2" // Nao Gera
	Local cDedPDG   := "2" //-- Deduz valor do Pedagio do valor da Base de Impostos (Somente para "CALCULO DOS IMPOSTOS")
	Local nValPedag := oModelDTR:GetValue("DTR_VALPDG")
	Local aMsgErr   := {}

	//-- Variaveis utilizadas pela funcao FA050NAT2 (Fina050)
	Private lF050Auto := .T.
	Private lAltera   := .F.
	Private nOldValor := 0
	Private nOldIrr   := 0
	Private lAltVcto  := .f.
	Private nOldIss   := 0
	Private nOldInss  := 0
	Private nOldSEST  := 0
	Private nValDig   := 0
	Private aAutoCab  := {}
	Private lGerTit   := GetMV('MV_GERTIT' ,,.T.) // Verifica se devera gerar ou nao contas a pagar (SE2)
	Private INCLUI   := .T.


	SA2->(dbSetOrder(1))
	If SA2->(MsSeek(xFilial('SA2')+ cCodFor +  cLojFor ))
		cCodFor		:= SA2->A2_COD
		cLojFor		:= SA2->A2_LOJA
		cCnpjFor 	:= SA2->A2_CGC

		If !Empty(SA2->A2_NATUREZ)
			cNatuCTC := SA2->A2_NATUREZ
		Else
			If lTM250Par
				cNatuCTC := ExecBlock('TM250PAR',.F.,.F.,{1})
				If ValType(cNatuCTC) <> 'C'
					cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
				EndIf
			Else
				cNatuCTC := TMSA250Var("NAT") //-- Natureza Contrato de Carreteiro
			EndIf
		EndIf

	EndIf

	nOldValor := 0
	nOldIrr   := 0
	nOldIss   := 0
	nOldInss  := 0
	nOldSEST  := 0
	nValDig   := 0

	//	SetFunname("TMSA250")
	//
	//	RegToMemory("SE2",.T.)
	//	M->E2_VALOR   := nValDig := IIf(nBasImp > 0, nBasImp, nValFrete)
	//
	//    TM250CIMP(SA2->A2_TIPO,"DTY",.F./*lCtrPremio*/,cTipCont,cGerPC,cDedPDG,nValFrete,nTotValAdi,nValPedag,nBasImp,@nValIRRF,@nValINSS,@nValSEST,@nValISS,@nValRetPIS,@nValRetCOF,,,nOpcx,,,,,@aMsgErr,cContrat,cCodFor,cLojFor,,,cNatuCTC)

	//
	//    SE2->(DbCloseArea())
	//   SetFunname("SERTMS03")

	//-- Nao for Contrato de Premio, Calcula o ISS que sera gravado
	RegToMemory("SE2",.T.)
	SED->(dbSetOrder(1))
	SED->(MsSeek(xFilial("SED")+cNatuCTC))
	M->E2_NATUREZ := SED->ED_CODIGO
	M->E2_INSSRET := DTR->DTR_INSRET

	TM250ClISS(cDedPDG,nValPedag)
	TM250ClINS()

	If lGerTit
		//-- Calcula o IRRF
		SA2->(dbSetOrder(1))
		SA2->(MsSeek(xFilial('SA2')+cCodFor+cLojFor))
		M->E2_FORNECE := SA2->A2_COD
		M->E2_LOJA    := SA2->A2_LOJA
		M->E2_VALOR   := nValDig := IIf(nBasImp > 0, nBasImp, nValFrete)
		FA050NAT2()
		nValIRRF := Max(0,M->E2_IRRF)
	Else
		aRet := Tm250IrCar(cCodForn,cLojForn,nBasImp,nValFrete,cCondPag)
		nValIRRF := aRet[1][1]
	EndIf
	//-- O ISS somente devera ser cobrado nas viagens que utilizam Rotas Municipais.
	//-- Portanto, se a Rota da Viagem NAO for Municipal (DA8_ROTMUN == 2), zerar o ISS
	//-- calculado pelo financeiro
	cRota := Posicione("DTQ",2,xFilial('DTQ') + DTR->DTR_FILORI + DTR->DTR_VIAGEM,"DTQ_ROTA")
	DA8->(DbSetOrder(1))
	If DA8->(MsSeek(xFilial("DA8")+cRota))
		If DA8->DA8_ROTMUN == StrZero(2,Len(DA8->DA8_ROTMUN))
			M->E2_ISS := 0
		EndIf
	EndIf

	nValINSS   := M->E2_INSS
	nValSEST   := M->E2_SEST
	nValISS    := M->E2_ISS
	nValRetPIS := M->E2_PIS
	nValRetCOF := M->E2_COFINS



	//    oModelDTR:SetValue("DTR_IRRF",nValIRRF)
	//    oModelDTR:SetValue("DTR_INSS",nValINSS)
	//    oModelDTR:SetValue("DTR_SEST",nValSEST)
	//    oModelDTR:SetValue("DTR_ISS",nValISS)

	RestArea(aAreaSE2)
	RestArea(aAerea)
Return {nValIRRF,nValINSS,nValSEST,nValISS}

/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/

Static Function Commit(oModel)

	Local lRet 		:= .t.
	Local nBckpModulo := nModulo


	//TMS
	nModulo := 43

	BEGIN TRANSACTION

		If lRet
			// Realiza o commit do modelo da tela
			FWMsgRun(, {|| lRet := FWFormCommit( oModel ) }	, "Processando", "SERTMS03 - Gravando Frete Combinado....")
		End If

		If lRet
			// Cria as despesa do contrato
			FWMsgRun(, {|| lRet := CriaSDG(oModel) }		, "Processando", "SERTMS03 - Gerando Movimento de Custo do Transporte TMS")
		End if

		If lRet
			// Gera contrato de carreteiro para esta viagem.
			FWMsgRun(, {|| lRet := GeraContr(oModel) }		, "Processando", "SERTMS03 - Gerando o(s) contrato(s) do(s) Carreteiro(s)...")
		End if

		If lRet
			// Gera memoria de calculo conforme a tabela de formula.
			FWMsgRun(, {|| lRet := GeraMemoria(oModel) }	, "Processando", "SERTMS03 - Gerando memoria de calculo do Melhor Frete...")
		End if

		If lRet
			// Realiza integracao dos titulos do contrato e imprime o RPC
			FWMsgRun(, {|| lRet := FinContr(oModel) }		, "Processando", "SERTMS03 - Integrando no Financeiro...")
		End if

		// Caso encontre algum erro
		If !lRet
			DisarmTransaction()
		End If

	END TRANSACTION

	nModulo := nBckpModulo

Return lRet


Static Function GeraMemoria(oModel)

	Local lRet 		:= .t.
	Local aAreaDTY  := DTY->(GetArea())
	Local cAliasDTY	:= GetNextAlias()
	Local oModelSZ5 := oModel:GetModel("SZ5DETAIL")
	Local oModelDTQ := oModel:GetModel("DTQMASTER")
	Local oModelDT6 := oModel:GetModel("DT6DETAIL")
	Local oCalcCTE  := oModel:GetModel("CALC_DOCFRT")
	Local nTotSZ5 	:= oModelSZ5:Length()
	Local nTotDT6   := oModelDT6:Length()
	Local nI      	:= 0
	Local nTotPeso  := oCalcCTE:GetValue("DT6_PESO_S")
	Local cViagem	:= oModelDTQ:GetValue("DTQ_VIAGEM")
	Local cFilOrig  := oModelDTQ:GetValue("DTQ_FILORI")

	// Recupera os contratos de uma determinada viagem
	BeginSQL Alias cAliasDTY
		SELECT DTY.R_E_C_N_O_ DTYRECNO FROM %Table:DTY% DTY 
		WHERE DTY_FILIAL = %Exp:xFilial("DTY")%
		AND DTY_FILORI = %Exp:cFilOrig%
		AND DTY_VIAGEM =%Exp:cViagem%
		AND D_E_L_E_T_ ='' 

	EndSQL

	DTY->(DbSetOrder(1))
	DTY->(DbGoto( (cAliasDTY)->(DTYRECNO) ) )

	(cAliasDTY)->(DbCloseArea())

	// Deleta se tiver memoria
	ClearSZ8(DTY->DTY_NUMCTC)

	// Salva a memoria de calculo
	For nI := 1 to nTotSZ5

		oModelSZ5:Goline(nI)

		// Verifica se este codigo de formula foi reateado por cte
		nPos := aScan(aRatCte, {|x| Alltrim(x[1]) ==  oModelSZ5:GetValue("Z5_CODFORM") })

		If nPOs == 0

			For nY := 1 to nTotDT6

				oModelDT6:GoLine(nY)

				If oModelSZ5:GetValue("Z5_YVALOR") > 0
					Reclock("SZ8",.T.)
					SZ8->Z8_FILIAL  := DTY->DTY_FILORI
					SZ8->Z8_CONTRAT := DTY->DTY_NUMCTC
					SZ8->Z8_CODTABE := oModelSZ5:GetValue("Z5_NUM")
					SZ8->Z8_CODFORM := oModelSZ5:GetValue("Z5_CODFORM")
					SZ8->Z8_DOC     := oModelDT6:GetValue("DT6_DOC")
					SZ8->Z8_SERIE   := oModelDT6:GetValue("DT6_SERIE")
					SZ8->Z8_VALOR   := (oModelDT6:GetValue("DT6_PESO")/nTotPeso) * oModelSZ5:GetValue("Z5_YVALOR") // Rateio por peso
					SZ8->(MsUnLock())
				End If
			End If
		Else

			For nO := 1 to Len(aRatCte[nPos])

				If nO > 1
					If aRatCte[nPos][nO][3]  > 0
						Reclock("SZ8",.T.)
						SZ8->Z8_FILIAL  := DTY->DTY_FILORI
						SZ8->Z8_CONTRAT := DTY->DTY_NUMCTC
						SZ8->Z8_CODTABE := oModelSZ5:GetValue("Z5_NUM")
						SZ8->Z8_CODFORM := oModelSZ5:GetValue("Z5_CODFORM")
						SZ8->Z8_DOC     := aRatCte[nPos][nO][1]
						SZ8->Z8_SERIE   := aRatCte[nPos][nO][2]
						SZ8->Z8_VALOR   := aRatCte[nPos][nO][3]
						SZ8->(MsUnLock())
					End if
				End If
			Next

		End If

	Next
	RestArea(aAreaDTY)
Return lRet

Static Function ClearSZ8(cContrato)

	SZ8->(DbSetOrder(1))
	//Z8_FILIAL, Z8_CONTRAT, Z8_CODFORM, R_E_C_N_O_, D_E_L_E_T_
	If SZ8->(DbSeek(xFilial("SZ8") + cContrato))

		While SZ8->(!EOF()) .AND. SZ8->(Z8_FILIAL + Z8_CONTRAT) == xFilial("SZ8") + cContrato
			Reclock("SZ8",.f.)
			SZ8->(DbDelete())
			SZ8->(MsUnLock())
			SZ8->(DbSkip())
		EndDo

	End If


Return

//User Function AliSZ8()
//
//
//	Local cALias := GetNextAlias()
//	
//	BeginSQL Alias cALias
//	
//		SELECT DTQ.R_E_C_N_O_ RECNO FROM DTY010 DTY
//		JOIN DTQ010 DTQ ON DTQ.DTQ_FILORI = DTY.DTY_FILORI
//		AND DTQ.DTQ_VIAGEM = DTY.DTY_VIAGEM
//		AND DTQ.D_E_L_E_T_ =''
//		WHERE DTY.D_E_L_E_T_ =''
//		AND NOT EXISTS (SELECT * FROM SZ8010 WHERE Z8_FILIAL = DTQ_FILORI AND Z8_CONTRAT = DTY.DTY_NUMCTC AND D_E_L_E_T_ ='')
//		
//	EndSQL
//	
//	DTQ->(DbSetOrder(1))
//	
//	While (cAlias)->(!EOF())
//		DTQ->(DbGoTo((cAlias)->RECNO))
//		
//		cFilant := DTQ->DTQ_FILORI
//		
//		oModelDTQ := FWLoadModel("SERTMS03")
//		oModelDTQ:SetOperation( MODEL_OPERATION_UPDATE )
//		oModelDTQ:lModify := .t. 
//		oModelDTQ:Activate()
//		If oModelDTQ:VldData()
//			if oModelDTQ:CommitData()
//			
//			End If
//		End If
//		
//		(cAlias)->(DbSkip())
//	EndDo
//	
//Return


/*/{Protheus.doc} FinContr
Realiza as baixa do CMV e cria as NDF das despesas
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/

Static Function FinContr(oModel)

	Local cAliasDTY 	:= GetNextAlias()
	Local oModelDTQ 	:= oModel:GetModel("DTQMASTER")
	Local oModelDTR		:= oModel:GetModel("DTRDETAIL")
	Local oModelSZ1		:= oModel:GetModel("SZ1DETAIL")
	Local cViagem		:= oModelDTQ:GetValue("DTQ_VIAGEM")
	Local cFilOrig  	:= oModelDTQ:GetValue("DTQ_FILORI")
	Local lEmptyTptCTC 	:= Empty(GetMV('MV_TPTCTC' ,,''))	// Verifica se o parametro de Tipo do Contrato de Carreteiro esta vazio
	Local cTipCTC    	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
	Local cParcela   	:= StrZero(1, Len(SE2->E2_PARCELA))
	Local cFilContr  	:= DTY->DTY_FILIAL
	Local cNrContr   	:= DTY->DTY_NUMCTC
	Local cFilOriDTY 	:= DTY->DTY_FILORI
	Local cCodOpe    	:= DTY->DTY_CODOPE
	Local cCtrComp   	:= DTY->DTY_TIPCTC
	Local cFornec    	:= Iif(!Empty(DTY->DTY_CODFAV),DTY->DTY_CODFAV,DTY->DTY_CODFOR)
	Local cLoja      	:= Iif(!Empty(DTY->DTY_LOJFAV),DTY->DTY_LOJFAV,DTY->DTY_LOJFOR)
	Local nVlrAdiant 	:= 0
	Local cPrefContr 	:= ""
	Local lRet		 	:= .t.
	Local aRecSE2 	 	:= {}
	Local aRecCOMP	 	:= {}
	Local aRecPA		:= {}
	Local aRet			:= {}
	Local aLinChang		:= {}
	Local cIdMOVSZ1		:= ""
	Local cLog			:= ""
	Local cTextMsg		:= ""
	Local nRecPA		:= 0
	Local aObs			:= {}

	// Recupera os contratos de uma determinada viagem
	BeginSQL Alias cAliasDTY
		SELECT DTY.R_E_C_N_O_ DTYRECNO FROM %Table:DTY% DTY 
		WHERE DTY_FILIAL = %Exp:xFilial("DTY")%
		AND DTY_FILORI = %Exp:cFilOrig%
		AND DTY_VIAGEM =%Exp:cViagem%
		AND D_E_L_E_T_ ='' 

	EndSQL

	DTY->(DbSetOrder(1))
	DT7->(DbSetOrder(1))

	(cAliasDTY)->(DbGoTop())

	While (cAliasDTY)->(!EOF())

		// Posiciona no contrato
		DTY->(DbGoto( (cAliasDTY)->(DTYRECNO) ) )

		cFilContr  := DTY->DTY_FILIAL
		cNrContr   := DTY->DTY_NUMCTC
		cFilOriDTY := DTY->DTY_FILORI
		cCodOpe    := DTY->DTY_CODOPE
		cCtrComp   := DTY->DTY_TIPCTC
		cFornec    := Iif(!Empty(DTY->DTY_CODFAV),DTY->DTY_CODFAV,DTY->DTY_CODFOR)
		cLoja      := Iif(!Empty(DTY->DTY_LOJFAV),DTY->DTY_LOJFAV,DTY->DTY_LOJFOR)
		//-- Verifica a Filial de Debito
		cFilDeb  := DTY->DTY_FILDEB
		If lEmptyTptCTC
			cTipDeb := Padr( "C"+cFilDeb, Len( SE2->E2_TIPO ) )
			cTipCTC := If(cFilDeb <> cFilAnt, cTipDeb, cTipCTC)
		EndIf

		cPrefixo := TMA250GerPrf(cFilDeb)

		aRecSE2  := {}

		If !Empty(cFil:=FwFilial("SE2"))
			cFil := If(cFilDeb <> cFilAnt .And. lEmptyTptCTC, cFilDeb, cFilAnt)
		Else
			cFil:= xFilial("SE2")
		EndIf

		If SE2->(MsSeek(cFil+cPrefixo+cNrContr+cParcela+cTipCTC+cFornec+cLoja))
			Aadd(aRecSE2,SE2->(RecNo()))
		End If

		cTextMsg   := "Contrato: " + cNrContr + " - " + SE2->E2_NOMFOR

		cPrefContr := TMA250GerPrf(cFilOriDTY)

		//Posiciona o registro no SZ1 pelo o veiculos, uma vez que
		//somente pode ter um veiculo por viagem.
		If oModelDTR:SeekLine({{"DTR_CODVEI",DTY->DTY_CODVEI}})

			// Recupera as linhas modificadas na SZ1
			aLinChang := oModelSZ1:GetLinesChanged()

//			If oModelDTR:GetValue("DTR_YFRTAD") > 0
//				cLog:= "Criando PA do adiantamento"
//				MsgRun (cLog  ,cTextMsg , {|| aRet := GeraPA(oModel) } )
//				
//				// Verifica se conseguiu criar a PA com sucesso.
//				If !aRet[1] 
//					Return .f. 
//				End if 
//				
//				// Guarda o Recno da PA 
//				nRecPA := aRet[2] 
//				
//			End If

			// Varre as linhas modificadas no modelo.
			For w:= 1 to len(aLinChang)

				//Posiciona na linha da SZ1
				oModelSZ1:GoLine(aLinChang[w])

				// Verifica se a linha esta' marcada para ser descontada
				If oModelSZ1:GetValue("Z1_MARK")

					// Posiciona no cadastro de despesa
					DT7->(DbSeek(xFilial("DT7") + oModelSZ1:GetValue("Z1_CODDESP")))

					cLog:= "Baixando CMV - Despesa: " + DT7->DT7_DESCRI

					// Realiza a baixa do CMV posicionado
					//FWMsgRun(, {|| aRet := BaixSZ1(oModel) }		, "Processando",cLog)
					MsgRun (cLog  ,cTextMsg , {|| aRet := BaixSZ1(oModel) } )

					// Verifica se realizou a baixa do CMV corretamente
					If !aRet[1]
						Return .f.
					End if

					// Recupera o codigo do id do movimento da baixa do SZ2.
					cIdMOVSZ1 := aRet[2]

					cLog:= "Criando NDF - Despesa: " + DT7->DT7_DESCRI
					// Realiza a geracao da NDF da despesa
					//FWMsgRun(, {|| aRet := GeraNDF(oModel,cIdMOVSZ1) }		, "Processando",cLog)

					MsgRun (cLog  ,cTextMsg , {|| aRet := GeraNDF(oModel,cIdMOVSZ1) } )

					// Verifica se conseguiu gerar NDF
					if !aRet[1]
						Return .f.
					End iF

				End If
			Next

		End if

		// Pesquisa as NDF do contrato para serem compensadas
		MsgRun ("Localizando as NDF do contrato..." ,cTextMsg , {|| aRecCOMP :=A250PsqAdi(cFornec,cLoja,cPrefixo,cFilContr,cNrContr,cViagem,"",@nVlrAdiant,,cPrefContr,cCtrComp) } )

		// Alimenta aqui o REC da PA para compensar o titulo no financeiro
		//AADD(aRecCOMP,nRecPA)

		// Realiza a compensacao das NDF com o Frete
		//lRet :=

		If len(aRecCOMP) > 0
			MsgRun ("Compensando Títulos no Financeiro...",  cTextMsg , {|| lRet := MaIntBxCP(2,aRecSE2,,aRecCOMP   ,,{.T.,.F.,.F.,.F.,.F.,.F.},{ | nRecSE2, cRetorno | A250SeqBx(nRecSE2,cRetorno,DTY->DTY_FILORI,DTY->DTY_NUMCTC) }) } )

			If !lRet
				oModel:SetErrorMessage("",,oModel:GetId(),"","MaIntBxCP","Nao possivel realizar compensacao dos titulos.")
				Return .f.
			End If

		End IF

		// Imprime o RPC, o titulo ja esta posicionado
		AADD(aObs,"CONTRATO: " + cNrContr + " / VIAGEM: " + cViagem + " / DATA EMISSÃO: " + DTOC(DTY->DTY_DATCTC) + " / TITULO: " + SE2->(E2_FILIAL+ E2_PREFIXO+ E2_NUM+ E2_PARCELA+ E2_TIPO+ E2_FORNECE+ E2_LOJA))
		AADD(aObs,"VALOR A SER ANTECIPADO: R$ " + Alltrim(cvaltochar(TRANSFORM(oModelDTR:GetValue("DTR_YFRTAD"), X3Picture("E2_VALOR")))))

		U_SERR0002(,,,,aObs)

		(cAliasDTY)->(DbSkip())
	EndDo

	(cAliasDTY)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} GeraPA
Realiza a criacao da PA junto com o contrato.
@author Totvs Vitoria - Mauricio Silva
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function GeraPA(oModel)

	Local aAreaSE2  := SE2->(GetArea())
	Local aArray	:= {}
	Local oModelDTR	:= oModel:GetModel("DTRDETAIL")
	Local cNrContr   := DTY->DTY_NUMCTC
	Local cFornec    := Iif(!Empty(DTY->DTY_CODFAV),DTY->DTY_CODFAV,DTY->DTY_CODFOR)
	Local cLoja      := Iif(!Empty(DTY->DTY_LOJFAV),DTY->DTY_LOJFAV,DTY->DTY_LOJFOR)
	Local cNatDeb	 := SuperGetMV("MV_NATDEB",.f.,"")
	Local cNatPA	 := SuperGetMV("MV_YNATPAF",.f.,cNatDeb)
	Local nVlrAdi	 := oModelDTR:GetValue("DTR_YFRTAD")
	Local cBanco	 := oModelDTR:GetValue("DTR_YBANCO")
	Local cAgencia	 := oModelDTR:GetValue("DTR_YAGENC")
	Local cContaBCO	 := oModelDTR:GetValue("DTR_YNUMCO")
	Local cMsg		 := ""
	Local cSolu		 := ""
	Local lRet		 := .T.

	Private lMsErroAuto := .F.

	//Cria a PA com as mesmas informacoes do titulo de pagamento do contrato

	aAdd(aArray,{ "E2_PREFIXO" 		, SE2->E2_PREFIXO	, NIL })
	aAdd(aArray,{ "E2_NUM" 			, SE2->E2_NUM 		, NIL })
	aAdd(aArray,{ "E2_TIPO" 		, "PA" 				, NIL })
	aAdd(aArray,{ "E2_PARCELA" 		, "01" 				, NIL })
	aAdd(aArray,{ "E2_NATUREZ" 		, cNatPA 			, NIL })
	aAdd(aArray,{ "E2_FORNECE" 		, SE2->E2_FORNECE	, NIL })
	aAdd(aArray,{ "E2_LOJA" 		, SE2->E2_LOJA		, NIL })
	aAdd(aArray,{ "E2_EMISSAO" 		, SE2->E2_EMISSAO	, NIL })
	aAdd(aArray,{ "E2_VENCTO" 		, SE2->E2_VENCTO	, NIL })
	aAdd(aArray,{ "E2_VENCREA" 		, SE2->E2_VENCREA   , NIL })
	aAdd(aArray,{ "E2_VALOR" 		, nVlrAdi 			, NIL })
	aAdd(aArray,{ "AUTBANCO" 		, cBanco 			, NIL })
	aAdd(aArray,{ "AUTAGENCIA" 		, cAgencia			, NIL })
	aAdd(aArray,{ "AUTCONTA" 		, cContaBCO 		, NIL })

	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

	If lMsErroAuto
		cMsg := memoread(NomeAutoLog())
		FErase(NomeAutoLog())
		cSolu := ""
		oModel:SetErrorMessage("",,oModel:GetId(),"","GeraPA",cMsg)
		Return {.f.,0}
	End If

	nRecno := SE2->(RECNO())

	RestArea(aAreaSE2)

Return {lRet,nRecno}

/*/{Protheus.doc} GeraNDF
Gera NDF da despesa no Financeiro
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param cIdBaixa, characters, description
@type function
/*/

Static Function GeraNDF(oModel,cIdBaixa)

	Local aAreaSE2  := SE2->(GetArea())
	Local aArray 	:= {}
	Local cAliasSE2 := GetNextAlias()
	Local oModelSZ1 := oModel:GetModel("SZ1DETAIL")
	Local nValor	:= oModelSZ1:GetValue("Z1_SALDO")
	Local cNatDeb	:= ""
	Local cTipo		:= Padr( "NDF", Len( SE2->E2_TIPO ) )
	Local lRet  	:= .t.
	Local cParcela	:= ""
	Local nRecno	:= 0
	Local cNatuDeb	:= ""

	// Verifica se na despesa existe uma natureza
	If Empty(DT7->DT7_YNATUR)
		cNatuDeb := Padr(SuperGetMV("MV_NATDEB",.f.,""), Len( SE2->E2_NATUREZ ) )
	Else
		cNatuDeb := Padr(DT7->DT7_YNATUR,Len( SE2->E2_NATUREZ ) )
	EndIf

	PRIVATE lMsErroAuto := .F.

	BeginSql Alias cAliasSE2

		SELECT MAX(E2_PARCELA) AS E2_PARCELA FROM %Table:SE2% SE2
		WHERE D_E_L_E_T_ ='' 
		AND SE2.E2_FILIAL = %Exp:SE2->E2_FILIAL%
		AND SE2.E2_PREFIXO =%Exp:SE2->E2_PREFIXO%
		AND SE2.E2_NUM =%Exp:SE2->E2_NUM%
		AND SE2.E2_TIPO ='NDF'
		AND SE2.E2_FORNECE =%Exp:SE2->E2_FORNECE%
		AND SE2.E2_LOJA  =%Exp:SE2->E2_LOJA%

	EndSql

	cParcela := SOMA1((cAliasSE2)->E2_PARCELA)

	(cAliasSE2)->(DbCloseArea())

	cFilContr  := DTY->DTY_FILIAL
	cNrContr   := DTY->DTY_NUMCTC
	cFilOriDTY := DTY->DTY_FILORI
	cCodOpe    := DTY->DTY_CODOPE
	cCtrComp   := DTY->DTY_TIPCTC
	cFornec    := Iif(!Empty(DTY->DTY_CODFAV),DTY->DTY_CODFAV,DTY->DTY_CODFOR)
	cLoja      := Iif(!Empty(DTY->DTY_LOJFAV),DTY->DTY_LOJFAV,DTY->DTY_LOJFOR)


	cParcela := PADL(cParcela,Len( SE2->E2_PARCELA ), "0")

	// Gerando NDF para o contrato
	aArray := { { "E2_PREFIXO"  , SE2->E2_PREFIXO   , NIL },;
		{ "E2_NUM"      , SE2->E2_NUM       , NIL },;
		{ "E2_PARCELA"  , cParcela   		, NIL },;
		{ "E2_TIPO"     , "NDF"             , NIL },;
		{ "E2_NATUREZ"  , cNatuDeb          , NIL },;
		{ "E2_FORNECE"  , SE2->E2_FORNECE   , NIL },;
		{ "E2_LOJA"  	, SE2->E2_LOJA   	, NIL },;
		{ "E2_EMISSAO"  , SE2->E2_EMISSAO	, NIL },;
		{ "E2_VENCTO"   , SE2->E2_VENCTO	, NIL },;
		{ "E2_VENCREA"  , SE2->E2_VENCREA	, NIL },;
		{ "E2_ORIGEM"   , "SIGATMS"			, NIL },;
		{ "E2_HIST"   	, SUBSTR(oModelSZ1:GetValue("Z1_DESPESA"),1,LEN(SE2->E2_HIST)), NIL },;
		{ "E2_YTABORI"  ,"SZ2"				, NIL },;
		{ "E2_YIDORIG"  ,cIdBaixa			, NIL },;
		{ "E2_YCODDES"  ,oModelSZ1:GetValue("Z1_CODDESP"), NIL },;
		{ "E2_VALOR"    , nValor     		, NIL } }

	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)

	If lMsErroAuto
		cMsg := memoread(NomeAutoLog())
		FErase(NomeAutoLog())
		cSolu := ""
		oModel:SetErrorMessage("",,oModel:GetId(),"","GeraNDF",cMsg)
		Return {.f.,0}
	End If

	nRecno := SE2->(RECNO())

	RestArea(aAreaSE2)
Return {lRet,nRecno}

/*/{Protheus.doc} GeraContr
Gera o contrato de carreteiro da viagem
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/

Static Function GeraContr(oModel)

	Local oModelDTQ := oModel:GetModel("DTQMASTER")
	Local lConfirma := .f. // Não aparecer a tela de confirmação
	Local cGerar    := "1" // Gera contrato
	Local lRet  	:= .T.
	//Local cBkpName	:= Funname()
	Private cCadastro :="Contrato de Carreteiro"


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³a Variavel aRotina foi declarada dentro desta funçao      ³
	//³para que seja possivel a visualização da tabela BOS       ³
	//³evitando o seguinte erro:                                 ³
	//³array out of bounds [2] of [0] on MSMGET:NEW(MSMGETPR.PRW)³
	//³quando chama a funçao AxVisual no trecho do codigo		 ³
	//³oBOS:oBrowse:BlDblClick ...								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

	Private aRotina := {}
	aAdd(aRotina, {"Pesquisar" , "AxPesqui", 0, 1})
	aAdd(aRotina, {"Visualizar", "AxVisual", 0, 2})
	aAdd(aRotina, {"Incluir"   , "AxInclui", 0, 3})
	aAdd(aRotina, {"Alterar"   , "AxAltera", 0, 4})
	aAdd(aRotina, {"Excluir"   , "AxDeleta", 0, 5})

	
	//SetFunname("TMA250")
	Pergunte("TMA250",.F.)

	// -- Se a rotina que Gera o contrato do Carreteiro estiver sendo
	// --  executada por outro usuario o sistema nao gera o contrato.
	If LockByName("GERCTC",.T.,.F.)

		//pergunte padrao para gerar Contrato por Viagem
		SetMVValue("TMA250","MV_PAR01",oModelDTQ:GetValue("DTQ_VIAGEM")) //VIAGEM DE
		SetMVValue("TMA250","MV_PAR02",oModelDTQ:GetValue("DTQ_VIAGEM")) //VIAGEM ATE
		SetMVValue("TMA250","MV_PAR03",2) //Mostra lanctos contabeis
		SetMVValue("TMA250","MV_PAR04",2) //Aglutina lanctos
		SetMVValue("TMA250","MV_PAR05",1) //Tipo de Frota
		SetMVValue("TMA250","MV_PAR09",1) //Preview Frete para o usuario visualizar os impostos
	Else
		lRet := .F.
	EndIf

	UnLockByName("GERCTC",.T.,.F.) // Libera Lock
	
	lRet := TMSA250Mnt('DTY',,3,,lConfirma,,,cGerar)

	If !lRet
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(CRIASDG-GeraContr)","Não foi possivel gerar o contrato.") 
	End If
	
	//SetFunname("TMA250")

Return lRet

/*/{Protheus.doc} CriaSDG
Cria a despesa do CMV na rotina Movimento custo de transporta do TMS
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function CriaSDG(oModel)

	LocaL oModelSZ1 := oModel:GetModel("SZ1DETAIL")
	Local oModelDTR := oModel:GetModel("DTRDETAIL")
	Local oModelDTQ := oModel:GetModel("DTQMASTER")
	Local nRegDTR	:= oModelDTR:Length()
	Local aLinDTR 	:= oModelDTR:GetLinesChanged()
	Local aLinSZ1	:= {}
	Local oModelSDG := Nil
	Local oModelFSDG := Nil
	Local oModelGSDG := Nil
	Local lValid	 := .t.
	Local cErro		:= ""

	Local cFilial  := ""
	Local cMoviment:= ""
	Local cParcela := ""
	Local cFornece := ""
	Local cLoja	   := ""
	Local aRet	   := {}
	Local cIdMOVSZ1:= ""

	DT7->(DbSetOrder(1))
	SZ1->(DbSetOrder(1))

	oModelSDG := FWLoadModel("TMSA070")
	oModelSDG:SetOperation( MODEL_OPERATION_INSERT )
	oModelSDG:GetModel("MdGridSDG"):SetUniqueLine({"DG_ITEM"})
	oModelSDG:Activate()

	// Recupera os modelos de dados
	oModelFSDG := oModelSDG:GetModel("MdFieldSDG")
	oModelGSDG := oModelSDG:GetModel("MdGridSDG")

	// Seta o cabeçalho
	oModelFSDG:SetValue("DG_DOC",   NextNumero("SDG",1,"DG_DOC",.T.))

	// Localiza qual foram os motorista que sofreram alteração
	For i:= 1 to nRegDTR

		oModelDTR:Goline(i)

		// Busca quais foram as linhas (Despesas) que sofreram alterações
		aLinSZ1 := oModelSZ1:GetLinesChanged()

		For y := 1 to Len(aLinSZ1)

			// Posiciona na linha
			oModelSZ1:Goline(aLinSZ1[y])

			// Verifica se marcou o registro
			If !oModelSZ1:GetValue("Z1_MARK")
				Loop
			End IF

			// Verifica se está vazio
			If !oModelGSDG:IsEmpty()
				// Adiciona mais uma linha
				oModelGSDG:Addline()
			End If

			// Posiciona no cadastro de despesa
			DT7->(DbSeek(xFilial("DT7") + oModelSZ1:GetValue("Z1_CODDESP")))

			// Realiza as validações dos campos
			If lValid
				lValid := oModelGSDG:SetValue("DG_ITEM"  ,   StrZero(oModelGSDG:Length() ,Len(SDG->DG_ITEM)))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_CODDES",  oModelSZ1:GetValue("Z1_CODDESP"))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_CODVEI",  oModelDTR:GetValue("DTR_CODVEI"))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_FILORI",  oModelDTQ:GetValue("DTQ_FILORI"))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_VIAGEM",  oModelDTQ:GetValue("DTQ_VIAGEM"))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_DATVENC",  oModelSZ1:GetValue("Z1_VENCTO"))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_CODFOR",  oModelSZ1:GetValue("Z1_FORNECE"))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_LOJFOR",  oModelSZ1:GetValue("Z1_LOJA"))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_CUSTO1",   oModelSZ1:GetValue("Z1_SALDO"))
			End If

			// Aqui eu informo que essa despesa foi gerado pelo contrato de carreteiro para
			// que a mesma seja excluida automaticamente quando excluido o contrato de carreteiro.
			If lValid
				lValid := oModelGSDG:SetValue("DG_ORIGEM",  "DTY")
			End If

			// Aqui eu informo que essa despesa ja gerou titulo no financeiro, sendo assim, pelo padrao
			// o sistema nao vai considerar a mesma na geracao do contrato de carretiro para gera a NDF
			If lValid
				lValid := oModelGSDG:SetValue("DG_TITGER",  "1")
			End If

			// Aqui eu informo que o titulo NDF desta despesa foi criada pela rotina SERTMS03 - Tela de melhor frete.
			// Pela regra de negocio da Serrana o sistema tem que gera para cada despesa uma NDF no financeiro.
			//Pelo padrao do TMS o sistema soma todas as despesas e gera apenas uma NDF.
			If lValid
				lValid := oModelGSDG:SetValue("DG_ORITIT",  "SERTMS03")
			End If

			If lValid
				lValid := oModelGSDG:SetValue("DG_HISTOR",  Substr(oModelSZ1:GetValue("Z1_HISTORI"),1,TamSX3("DG_HISTOR")[1]))
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_CLVL",    DT7->DT7_CLVL)
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_ITEMCTA", DT7->DT7_ITEMCT)
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_CONTA",   DT7->DT7_CONTA)
			End If
			If lValid
				lValid := oModelGSDG:SetValue("DG_CC",      DT7->DT7_CC)
			End If

			// Verifica se o modelo ficou com algum erro após atribuição dos valores
			If oModelSDG:HasErrorMessage() .and. !lValid
				// Recupera o erro do modelo da Despesa
				cErro := GetErroModel(oModelSDG)
				// Seta erro dentro do Modelo Principal - Tela de melhor Frete
				oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(CRIASDG-ValidCampo)",cErro)
				Return .f.
			End If

		Next

	Next

	// Verifica se foi adicionado alguma informação dentro do modelo da despesa do TMS
	If !oModelGSDG:IsEmpty()

		If oModelSDG:VldData()

			If !oModelSDG:CommitData()
				// Recupera o erro do modelo da Despesa
				cErro := GetErroModel(oModelSDG)
				// Seta erro dentro do Modelo Principal - Tela de melhor Frete
				oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(CRIASDG-CommitData)",cErro)
				Return .f.
			End if

		Else
			// Recupera o erro do modelo da Despesa
			cErro := GetErroModel(oModelSDG)
			// Seta erro dentro do Modelo Principal - Tela de melhor Frete
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(CRIASDG-VldData)",cErro)
			Return .f.
		End if
	Else
		oModelSDG:Destroy()
	End If

Return .t.

/*/{Protheus.doc} BaixSZ1
Realiza a baixa do CMV
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/

Static Function BaixSZ1(oModel)

	Local oModelSZ1   := oModel:GetModel("SZ1DETAIL")
	Local oModelDTQ   := oModel:GetModel("DTQMASTER")
	Local oModelBXSZ1 := Nil
	Local oModelSZ2   := Nil
	Local cErro		  := ""
	Local lValid	  := .T.
	Local cIdMov 	  := ""
	// Recupera os valores da CMV posicionada para realizar a baixa
	Local cFilial  := oModelSZ1:GetValue("Z1_FILIAL")
	Local cMoviment:= oModelSZ1:GetValue("Z1_NUM")
	Local cParcela := oModelSZ1:GetValue("Z1_PARCELA")
	Local cFornece := oModelSZ1:GetValue("Z1_FORNECE")
	Local cLoja	   := oModelSZ1:GetValue("Z1_LOJA")
	Local cChave   := cFilial + cFornece + cLoja + cMoviment + cParcela

	// Posiciona no registro
	SZ1->(DbGoto( oModelSZ1:GetDataId() ) )

	//Carrega o modelo
	oModelBXSZ1 := FWLoadModel("SERGPE01")
	oModelBXSZ1:SetOperation(MODEL_OPERATION_UPDATE)

	// Verifica se conseguiu ativar o modelo
	if !oModelBXSZ1:Activate()

		// Verifica o motivo de não ativação do modelo
		If oModelBXSZ1:HasErrorMessage()
			// Recupera o erro
			cErro := GetErroModel(oModelBXSZ1)
			// Seta erro dentro do Modelo Principal - Tela de melhor Frete
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(CRIASDG-BaixSZ1-Activate)",cErro)
			Return { .f., cIdMov }
		End If

	End if

	// Recupera o modelo da baixa
	oModelSZ2 := oModelBXSZ1:GetModel("SZ2DETAIL")

	// Verifica se o registro possui alguma baixa
	If !oModelSZ2:IsEmpty()
		// Adiciona uma linha no modelo.
		oModelSZ2:AddLine()
	End If

	If lValid
		lValid := oModelSZ2:SetValue("Z2_VALOR"  , oModelSZ1:GetValue("Z1_SALDO") )
	End If

	If lValid
		lValid := oModelSZ2:SetValue("Z2_HISTOR" , "Realizado via Viagem: " + oModelDTQ:GetValue("DTQ_VIAGEM") + "/Contrato:" + DTY->DTY_NUMCTC)
	End If

	If lValid
		lValid := oModelSZ2:SetValue("Z2_TIPMOV"  , "A" )
	End if

	If lValid
		// Informa que foi integrado via contrato, uma vez que a exclusao
		// da baixa so deixa excluir pela rotina geradora.
		lValid := oModelSZ2:SetValue("Z2_ROTINA"  , "TMSA250" )
	End if

	// Verifica o motivo de não ativação do modelo
	If oModelBXSZ1:HasErrorMessage() .and. !lValid
		// Recupera o erro
		cErro := GetErroModel(oModelBXSZ1)
		// Seta erro dentro do Modelo Principal - Tela de melhor Frete
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(BaixSZ1-ValidCampo)",cErro)
		Return { .f., cIdMov }
	End If

	// Recupera o ID do movimento
	cIdMov := oModelSZ2:GetValue("Z2_IDMOV")

	if Empty(cIdMov)
		cErro:= "O Código do movimento da baixa do CMV :" + cChave + " retornou em branco (Z2_IDMOV)"
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(BaixSZ1)",cErro)
		Return { .f., cIdMov }
	End If

	// Realiza a validação do modelo
	If oModelBXSZ1:VldData()

		// Verifica se realizou o commit
		If !oModelBXSZ1:CommitData()
			// Recupera o erro do modelo
			cErro := GetErroModel(oModelBXSZ1)
			// Seta erro dentro do Modelo Principal - Tela de melhor Frete
			oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(BaixSZ1-CommitData)",cErro)
			Return { .f., cIdMov }
		End if
	Else
		// Recupera o erro do modelo
		cErro := GetErroModel(oModelBXSZ1)
		// Seta erro dentro do Modelo Principal - Tela de melhor Frete
		oModel:SetErrorMessage("",,oModel:GetId(),"","SERTMS03 - COMMIT(BaixSZ1-VldData)",cErro)
		Return { .f., cIdMov }
	End if

Return { .T., cIdMov }

/*/{Protheus.doc} GetErroModel
Retorna o erro do modelo de dados
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
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


/*/{Protheus.doc} ChangeLine
Atualizar os totalizadores na mudanca da tabela de formula
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, description
@param cViewID, characters, description
@type function
/*/

Static Function ChangeLine(oView, cViewID)

	Local oModel 	 := FwModelActive()
	Local nRetDif 	 := DifFrete()
	Local nPercRepas := PercRepas()
	Local nPercAprov := PercAprov()

	Local oModelMFRT := oModel:GetModel("CALC_MFRT")

	oModelMFRT:SetValue("DIFERENCA",nRetDif)
	oModelMFRT:SetValue("PERCREPASS",nPercRepas)
	oModelMFRT:SetValue("PERCAPROVE",nPercAprov)
	oView:GetViewObj("SZ4DETAIL")[3]:Refresh(.t.,.F.)
Return

Static Function loadField(oFieldModel, lCopy)
	Local aLoad := {}

	aAdd(aLoad, {" ", " "}) //dados
	aAdd(aLoad, 0) //recno

Return aLoad


/*/{Protheus.doc} GetCodFor
No TMS alguns campos nao sao exibidos em modulo algum, sendo assim,
tratativa para buscar seus valores.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cCampo, characters, description
@type function
/*/
Static Function GetCodFor(cCampo)

	Local oModel := FwModelActive()
	Local oModelDTR := oModel:GetModel("DTRDETAIL")
	Local cFilial	:= oModelDTR:GetValue("DTR_FILIAL")
	Local cFilOri	:= oModelDTR:GetValue("DTR_FILORI")
	Local cViagem	:= oModelDTR:GetValue("DTR_VIAGEM")
	Local cItem	    := oModelDTR:GetValue("DTR_ITEM")
	Local cReturn 	:= ""

	DTR->(DbSetOrder(1))

	if DTR->(DbSeek(cFilial + cFilOri + cViagem + cItem))

		cReturn := DTR->(&(cCampo))

	End If

Return cReturn


/*/{Protheus.doc} DifFrete
Realiza o calculo da diferenca do frete e atualiza os totalizadores
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function DifFrete()

	Local oModel := Nil
	Local oModelFRT := Nil
	Local oModelMFRT := Nil
	Local nRet := 0
	Local nTxAprv 	:= 0

	oModel := FwModelActive()

	If oModel <> Nil

		oModelFRT := oModel:GetModel("CALC_FRT")
		oModelMFRT := oModel:GetModel("CALC_MFRT")

		If oModelFRT:IsActive() .and. oModelMFRT:IsActive()

			// Frete Ideial - Frete Combinado
			//nRet := oModelFRT:GetValue("FreteIdeal") - oModelMFRT:GetValue("DTR_VALFRE_T")

			nRet := (oModelFRT:Getvalue("Z5_YVALOR_C") - oModelFRT:Getvalue("Z5_YVALOR_D")) - oModelMFRT:GetValue("DTR_VALFRE_T")


		End If
	End If

Return nRet


/*/{Protheus.doc} PercRepas
Realiza o calculo do percentual de repasse do valor do frete.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function PercRepas()

	Local oModel := FwModelActive()
	Local oModelFRT := oModel:GetModel("CALC_FRT")
	Local oModelMFRT := oModel:GetModel("CALC_MFRT")
	Local nPercRepas	:= 0
	Local nFrtIdeal	:= 0

	If oModel <> Nil

		oModelFRT  := oModel:GetModel("CALC_FRT")
		oModelMFRT := oModel:GetModel("CALC_MFRT")

		If oModelFRT:IsActive() .and. oModelMFRT:IsActive()

			nFrtIdeal := (oModelFRT:Getvalue("Z5_YVALOR_C") - oModelFRT:Getvalue("Z5_YVALOR_D"))

			if nFrtIdeal > 0
				nPercRepas:= (oModelMFRT:GetValue("DTR_VALFRE_T") / nFrtIdeal ) * 100
			End IF
		End IF

	End If
Return nPercRepas


/*/{Protheus.doc} PercAprov
Realiza o calculo do percentual de aproveitamento da negociacao.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function PercAprov()

	Local oModel := FwModelActive()
	Local oModelMFRT := oModel:GetModel("CALC_MFRT")
	Local oModelFRT := oModel:GetModel("CALC_FRT")
	Local nTxAprv	:= 0

	If oModelMFRT:IsActive()

		nTxAprv:= 100 - oModelMFRT:GetValue("PERCREPASS")
	End If
Return nTxAprv


/*/{Protheus.doc} FrtLiq
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param lCalc, logical, description
@type function
/*/

Static Function FrtLiq(lCalc)

	Local oModel 	 := FwModelActive()
	Local oModelRCoo := oModel:GetModel("CALC_RCOO")
	Local nRet 		 := 0
	Default lCalc	 := .f.

	If oModelRCoo:IsActive()
		nRet:=  oModelRCoo:GetValue("FRTCOMBCO") - oModelRCoo:GetValue("Z1_SALDO_S")

		If !lCalc
			oModelRCoo:SetValue("FRTLIQUIDO",nRet)
		End If

	End If
Return nRet

/*/{Protheus.doc} LoadSZ5
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/
Static Function LoadSZ5(oGridModel, lCopy,oModel)

	Local aAreaDTA	 := DTA->(GetArea())
	Local aAreaDT6	 := DT6->(GetArea())
	Local aAreaSF2	 := SF2->(GetArea())
	Local aLoad 	 := FormLoadGrid(oGridModel, .F.)
	Local oModelSZ5  := oModel:GetModel("SZ5DETAIL")
	Local oStrSZ5 	 := oModelSZ5:GetStruct()
	Local nPosChave  := oStrSZ5:GetArrayPos({"Z5_CHAVE"})[1]
	Local nPosFormu  := oStrSZ5:GetArrayPos({"Z5_FORMULA"})[1]
	Local nPosValor  := oStrSZ5:GetArrayPos({"Z5_YVALOR"})[1]
	Local nPosCodFor := oStrSZ5:GetArrayPos({"Z5_CODFORM"})[1]
	Local aResult	 := {}
	Local nPosX	 	 := 1
	Local nPosL		 := 0
	Local nRet		 := 0
	Private xFormula := ""

	DTA->(DbSetOrder(1))
	DT6->(DbSetOrder(1))
	SF2->(DbSetOrder(1))

	TrabViagem()

	// Zera toda vez quando passar no Load
	aRatCte := {}

	For i:=1 to Len(aLoad)

		For y:= 1 to len (aLoad)
			aLoad[i][2][nPosFormu] := StrTran( StrTran(aLoad[i][2][nPosFormu]," ","") , "%" + Alltrim(aLoad[y][2][nPosChave]) + "%" ,((aLoad[y][2][nPosFormu])))
		Next

		IF "->" $ aLoad[i][2][nPosFormu]

			nRet:= 0

			(cAliasVia)->(DbGoTop())

			While (cAliasVia)->(!EOF())

				DTA->(DbGoTo( (cAliasVia)->(DTARECNO) ) )
				DT6->(DbGoTo( (cAliasVia)->(DT6RECNO) ) )
				SF2->(DbGoTo( (cAliasVia)->(SF2RECNO) ) )

				nRet += &(aLoad[i][2][nPosFormu])

				nPos := aScan(aRatCte, {|x| Alltrim(x[1]) ==  aLoad[i][2][nPosCodFor] })

				If nPos == 0
					AADD(aRatCte,{aLoad[i][2][nPosCodFor]})

					AADD(aRatCte[Len(aRatCte)],{DT6->DT6_DOC, DT6->DT6_SERIE,&(aLoad[i][2][nPosFormu])})

				Else
					AADD(aRatCte[nPos],{DT6->DT6_DOC, DT6->DT6_SERIE,&(aLoad[i][2][nPosFormu])})

				End if

				(cAliasVia)->(DbSkip())
			EndDo

			aLoad[i][2][nPosValor] := nRet
		Else
			aLoad[i][2][nPosValor] := &(aLoad[i][2][nPosFormu])
		End If

	Next

	RestArea(aAreaDTA)
	RestArea(aAreaDT6)
	RestArea(aAreaSF2)

Return aLoad

/*/{Protheus.doc} TrabViagem
Area de trabalho para realizar a aplicacao das formulas
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/


Static Function TrabViagem()

	If SELECT(cAliasVia) > 0
		(cAliasVia)->(DbCloseArea())
	End If

	BeginSQL Alias cAliasVia

		SELECT 

		DTA.R_E_C_N_O_ AS DTARECNO
		,DT6.R_E_C_N_O_ AS DT6RECNO
		,SF2.R_E_C_N_O_ AS SF2RECNO

		FROM %Table:DTA% DTA 

		JOIN %Table:SF2% SF2 ON SF2.F2_FILIAL = DTA.DTA_FILORI
		AND SF2.F2_DOC = DTA.DTA_DOC 
		AND SF2.F2_SERIE = DTA.DTA_SERIE
		AND SF2.D_E_L_E_T_ ='' 

		JOIN %Table:DT6% DT6 ON DT6.DT6_FILIAL =%Exp:xFilial("DT6")%
		AND DT6.DT6_FILDOC = DTA.DTA_FILDOC 
		AND DT6.DT6_DOC = DTA.DTA_DOC 
		AND DT6.DT6_SERIE = DTA.DTA_SERIE 
		AND DT6.DT6_FILORI = DTA.DTA_FILORI
		AND DT6.D_E_L_E_T_ =''

		WHERE DTA.DTA_FILIAL =%Exp:xFilial("DTA")%
		AND DTA.DTA_FILORI =%Exp:cFilAnt%
		AND DTA.DTA_FILDOC =%Exp:cFilAnt%
		AND DTA.DTA_VIAGEM =%Exp:DTQ->DTQ_VIAGEM%
		AND DTA.D_E_L_E_T_ =''

	EndSQL
Return

/*/{Protheus.doc} LoadDT6
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/


Static Function LoadDT6(oGridModel, lCopy,oModel)

	Local aLoad := {}

	//Recupera os conhecimentos da viagem
	TrabCte(.t.)

	aLoad := FwLoadByAlias( oGridModel,cAliasDT6, NIL , Nil , Nil , .t. )

Return aLoad

/*/{Protheus.doc} LoadDA4
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, description
@param lCopy, logical, description
@param oModel, object, description
@type function
/*/

Static Function LoadDA4(oGridModel, lCopy,oModel)

	Local aLoad := {}

	//Recupera os motoristas
	TrabMot(.t.)

	aLoad := FwLoadByAlias( oGridModel,cAliasDA4, NIL , Nil , Nil , .t. )

Return aLoad

/*/{Protheus.doc} SaldoMov
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SaldoMov()

	Local oModel := FwModelActive()
	Local oModelCALC := oModel:GetModel("CALC_FRT")
	Local oModelDTR := oModel:GetModel("DTRDETAIL")
	Local nValorC := oModelCALC:Getvalue("Z5_YVALOR_C")
	Local nValorD := oModelCALC:Getvalue("Z5_YVALOR_D")
	Local nRet    := nValorC - nValorD

	//If oModelDTR:GetValue("DTR_VALFRE") == 0

	//oModelDTR:SetValue("DTR_VALFRE",nRet)

	//End If

Return nRet


/*/{Protheus.doc} ValidSaldo
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ValidSaldo()

	Local oModel := FwModelActive()
	Local oModelSZ1 := oModel:GetModel("SZ1DETAIL")
	Local cCodigo	:= oModelSZ1:GetValue("Z1_NUM")
	Local cFilial	:= oModelSZ1:GetValue("Z1_FILIAL")
	Local cParcela	:= oModelSZ1:GetValue("Z1_PARCELA")
	Local cFornece 	:= oModelSZ1:GetValue("Z1_FORNECE")
	Local cLoja		:= oModelSZ1:GetValue("Z1_LOJA")
	Local nSaldo 	:= oModelSZ1:GetValue("Z1_SALDO")
	Local cMsg		:= ""
	Local cSolu		:= ""
	Local lRet		:= .t.

	SZ1->(DbSetOrder(1))

	If SZ1->(DbSeek(cFilial + cFornece + cLoja + cCodigo + cParcela))

		If nSaldo > SZ1->Z1_SALDO

			cMsg  := "O valor não pode ser maior do que o saldo desta despesa - Saldo Atual (R$ " + cvaltochar(SZ1->Z1_SALDO ) + ")"
			cSolu := "Favor informar o saldo igual ou menor do que o saldo atual."
			Help(NIL, NIL, "SERTMS03 - ValidSaldo", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
			Return .f.

		End if

	End If

Return lRet



/*/{Protheus.doc} StrDTQ
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function StrDTQ()

	Local lTMS3GFE   := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
	Static lTmsRdpU	 := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
	Local lTipOpVg   := DTQ->(ColumnPos('DTQ_TPOPVG')) > 0
	Local aVisual	 := {}

	//AAdd(aVisual, "DTQ_FILORI")
	AAdd(aVisual, "DTQ_VIAGEM")
	AAdd(aVisual, "DTQ_DATGER")
	AAdd(aVisual, "DTQ_HORGER")
	AAdd(aVisual, "DTQ_ROTA"  )
	AAdd(aVisual, "DTQ_DESROT")
	AAdd(aVisual, "DTQ_OBS"   )
	AAdd(aVisual, "DTQ_IDOPE"   )
	AAdd(aVisual, "DTQ_IDCLI")

	If DTQ->(ColumnPos("DTQ_KMVGE")> 0)
		AAdd(aVisual, "DTQ_KMVGE"   )
	EndIf
	If DTQ->(ColumnPos("DTQ_ROTEIR")> 0)
		AAdd(aVisual, "DTQ_ROTEIR")
		AAdd(aVisual, "DTQ_CDRORI")
		AAdd(aVisual, "DTQ_CDRDES")
	EndIf

	If lTMS3GFE .Or. lTmsRdpU   //-- Integracao Viagem TMS x GFE
		AAdd( aVisual, 'DTQ_PAGGFE' )
		AAdd( aVisual, 'DTQ_TPFRRD' )
		AAdd( aVisual, 'DTQ_UFORI' )
		AAdd( aVisual, 'DTQ_CDMUNO' )
		AAdd( aVisual, 'DTQ_MUNORI' )
		AAdd( aVisual, 'DTQ_CEPORI' )
		AAdd( aVisual, 'DTQ_UFDES' )
		AAdd( aVisual, 'DTQ_CDMUND' )
		AAdd( aVisual, 'DTQ_MUNDES' )
		AAdd( aVisual, 'DTQ_CEPDES' )
		AAdd( aVisual, 'DTQ_TIPVEI' )
		AAdd( aVisual, 'DTQ_DESTIP' )
		AAdd( aVisual, 'DTQ_CDTPOP' )
		AAdd( aVisual, 'DTQ_DSTPOP' )
		AAdd( aVisual, 'DTQ_CDCLFR' )
		AAdd( aVisual, 'DTQ_DSCLFR' )
		AAdd( aVisual, 'DTQ_CHVEXT' )
	EndIf

	If lTipOpVg
		AAdd(aVisual, "DTQ_TPOPVG")
		AAdd(aVisual, "DTQ_DESTPO")
	EndIf


Return aVisual

/*/{Protheus.doc} StrucView
O TMS tem campos que nao sao exibidos em modulo algum, sendo assim,
o MVC nao apresenta os campos utilizados nesta rotina. Portanto, criei na mao.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param aCampoExib, array, description
@type function
/*/

Static Function StrucView(cAlias,aCampoExib)

	Local oStrModel := FWFormStruct(1,cAlias)
	Local aCampos 	:= oStrModel:GetFields()
	Local oStrView  := FWFormViewStruct():New()
	Local i         := 1

	Default aCampoExib := {}

	// Cria estrutura do modelo de dados e da view
	SX3->(DbSetOrder(2))

	//Iguala a estrutura
	If len(aCampoExib) == 0

		For i:= 1 to len(aCampos)
			AADD(aCampoExib,aCampos[i][3])
		Next

	End if

	For i:= 1 to Len(aCampoExib)

		If SX3->(DbSeek(aCampoExib[i]))

			oStrView:AddField(;
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
			aCampos[i][9],;                                                         // [13]  A   Lista de valores permitido do campo (Combo)
			Nil,;                                                                   // [14]  N   Tamanho maximo da maior opção do combo
			SX3->X3_INIBRW,;                                                        // [15]  C   Inicializador de Browse
			NIL,;                                                        			// [16]  L   Indica se o campo é virtual
			Nil,;                                                                   // [17]  C   Picture Variavel
			Nil)                                                                    // [18]  L   Indica pulo de linha após o campo
		End if
	Next

Return  oStrView

/*/{Protheus.doc} TrabCte
Recupera os Conhecimentos utilizados na viagem
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param lRetDados, logical, description
@type function
/*/


Static Function TrabCte(lRetDados)

	Local cFilter := "% AND 1 = 1 %"
	Default lRetDados := .f.

	If !lRetDados
		cFilter := "% AND 1 <> 1 %"
	End iF

	If select (cAliasDT6) > 0
		(cAliasDT6)->(DbCloseArea())
	End If

	BeginSql Alias cAliasDT6

		SELECT 
		(SELECT A1_COD + A1_LOJA +' - ' +  A1_NREDUZ FROM %Table:SA1% SA1REM WHERE SA1REM.A1_FILIAL = %exp:xFilial("SA1")% AND SA1REM.A1_COD = DT6.DT6_CLIREM AND SA1REM.A1_LOJA = DT6.DT6_LOJREM AND SA1REM.D_E_L_E_T_ ='' ) AS DT6_NOMREM
		, (SELECT A1_COD + A1_LOJA +' - ' +  A1_NREDUZ FROM %Table:SA1% SA1DES WHERE SA1DES.A1_FILIAL = %exp:xFilial("SA1")% AND SA1DES.A1_COD = DT6.DT6_CLIDES AND SA1DES.A1_LOJA = DT6.DT6_LOJDES AND SA1DES.D_E_L_E_T_ ='' ) AS DT6_NOMDES
		,DT6.DT6_DOC
		,DT6.DT6_SERIE
		,DT6.DT6_DATEMI
		,DT6.DT6_VALFRE
		,DT6.DT6_VALIMP
		,DT6.DT6_VALTOT			
		,DT6.DT6_QTDVOL
		,DT6.DT6_PESO
		,DT6.DT6_VALMER

		FROM %Table:DTA% DTA

		JOIN %Table:DT6% DT6 ON DT6.DT6_FILIAL = %exp:xFilial("DT6")%
		AND DT6.DT6_FILDOC = DTA.DTA_FILDOC 
		AND DT6.DT6_DOC = DTA.DTA_DOC 
		AND DT6.DT6_SERIE = DTA.DTA_SERIE 
		AND DT6.DT6_FILORI = DTA.DTA_FILORI
		AND DT6.D_E_L_E_T_ =''

		WHERE DTA.D_E_L_E_T_ =''
		%Exp:cFilter%
		AND DTA.DTA_FILIAL =%Exp:xFilial("DT6")%
		AND DTA.DTA_FILORI =%Exp:cFilAnt%
		AND DTA.DTA_FILDOC =%Exp:cFilAnt%
		AND DTA.DTA_VIAGEM =%Exp:DTQ->DTQ_VIAGEM%

	EndSQL

	TcSetField(cAliasDT6,'DT6_DATEMI','D')

Return

Static Function TrabMot(lRetDados)

	Local cFilter := "% AND 1 = 1 %"
	Default lRetDados := .f.

	If !lRetDados
		cFilter := "% AND 1 <> 1 %"
	End iF

	If select (cAliasDA4) > 0
		(cAliasDA4)->(DbCloseArea())
	End If

	BeginSql Alias cAliasDA4

		SELECT 

		DUP.DUP_CODVEI
		,DA4.DA4_COD
		,DA4.DA4_NOME
		,DA4.DA4_NUMCNH
		,DA4.DA4_DTVCNH
		,DA4.DA4_RG

		FROM %Table:DUP% DUP

		JOIN %Table:DA4% DA4 ON DA4.DA4_FILIAL = %exp:xFilial("DA4")%
		AND DA4.DA4_COD = DUP.DUP_CODMOT
		AND DA4.D_E_L_E_T_ =''

		WHERE  DUP.D_E_L_E_T_ =''
		%Exp:cFilter%
		AND DUP.DUP_FILIAL = %exp:xFilial("DUP")%
		AND DUP_VIAGEM = %Exp:DTQ->DTQ_VIAGEM% 
		AND DUP.DUP_FILORI =%Exp:cFilAnt%

	EndSql

	TcSetField(cAliasDA4,'DA4_DTVCNH','D')

Return

/*/{Protheus.doc} StrMVC
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, description
@param cAlias, characters, description
@param oStr, object, description
@type function
/*/
Static Function StrMVC(nTipo,cAlias,oStr)

	// Recupera a estrutra da query
	aStru := (cAlias)->(dbStruct())

	// Cria estrutura do modelo de dados e da view
	DbSelectArea("SX3")
	DbSetOrder(2)

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
				Nil,;                                                         			// [13]  A   Lista de valores permitido do campo (Combo)
				Nil,;                                                                   // [14]  N   Tamanho maximo da maior opção do combo
				SX3->X3_INIBRW,;                                                        // [15]  C   Inicializador de Browse
				NIL,;                                                        			// [16]  L   Indica se o campo é virtual
				Nil,;                                                                   // [17]  C   Picture Variavel
				Nil)                                                                    // [18]  L   Indica pulo de linha após o campo

			End If
		End If
	Next

Return oStr

Static Function ForceValue(oModel)

	Local i
	Local nTanSZ1 := oModel:GetModel():GetModel("SZ1DETAIL"):Length()
	Local nSaldo  := 0

	For i := 1 To nTanSZ1

		oModel:GetModel():GetModel("SZ1DETAIL"):GoLine(i)
		oModel:GetModel():GetModel("SZ1DETAIL"):SetLine(i)

		//desconsidera a linha deletada
		If oModel:GetModel():GetModel("SZ1DETAIL"):IsDeleted()
			Loop
		EndIf

		oModel:LoadValue("SZ1DETAIL", "Z1_MARK", .T.)
		oModel:GetModel("SZ1DETAIL"):SetValue("Z1_MARK") := .T.

		nSaldo += oModel:GetModel("SZ1DETAIL"):Getvalue("Z1_SALDO")

	Next i

	oModel:LoadValue("CALC_CMV", "Z1_SALDO_S", nSaldo)
	oModel:LoadValue("CALC_RCOO", "Z1_SALDO_S", nSaldo)

	oModel:GetModel():GetModel("SZ1DETAIL"):GoLine(1)
	oModel:GetModel():GetModel("SZ1DETAIL"):SetLine(1)

Return

Static Function ValidMark(oModel)

	Local lRet    	 := .T.
	Local oBtOk
	Local oGroup1
	Local oCodLogin
	Local cCodLogin  := Space(50)
	Local oSayLog
	Local oSaySen
	Local oCodSenha
	Local cCodSenha  := Space(50)
	Local oDlgUsr
	Local lMark 	 := !(oModel:GetModel():GetModel("SZ1DETAIL"):GetValue("Z1_MARK")) //Neste momento ja vem marcado ou desmarcado
	Local lConfirma  := .F. 

	If lMark

		DEFINE MSDIALOG oDlgUsr TITLE "Autorização por Senha" FROM 000, 000  TO 132, 210 COLORS 0, 16777215 PIXEL

		@ 002, 002 GROUP oGroup1 TO 050, 102 PROMPT "Insira Login e Senha de Autorização" OF oDlgUsr COLOR 0, 16777215 PIXEL

		@ 016, 005 SAY oSayLog PROMPT "Login" SIZE 025, 007 OF oDlgUsr COLORS 0, 16777215 PIXEL
		@ 015, 037 MSGET oCodLogin VAR cCodLogin SIZE 060, 010 OF oDlgUsr COLORS 0, 16777215 PIXEL

		@ 032, 005 SAY oSaySen PROMPT "Senha" SIZE 025, 007 OF oDlgUsr COLORS 0, 16777215 PIXEL
		@ 031, 037 MSGET oCodSenha VAR cCodSenha PASSWORD SIZE 060, 010 OF oDlgUsr COLORS 0, 16777215 PIXEL

		@ 051, 064 BUTTON oBtOk PROMPT "Ok" SIZE 037, 012 OF oDlgUsr ACTION {|| ;
		FWMsgRun(, {|| lRet := ValidUsr(AllTrim(cCodLogin),AllTrim(cCodSenha)) }, "Autorização", "Verificando Autorização..."),;
		IIF(lRet,(lConfirma := .T., oDlgUsr:End()),Nil)} PIXEL

		ACTIVATE MSDIALOG oDlgUsr CENTERED

		If !lConfirma
			lRet := .F.
		EndIf

	EndIf

Return lRet


//======================================
//VALIDAÇÃO DA SENHA DIGITADA		   =	
//======================================
Static Function ValidUsr(cNomeUser,cCodSenha)

	Local lRetUser := .F.
	Local cUsrAut  := AllTrim(GetMv("ZZ_USRAUT", .F., cUserName))
	Local cUsrOld  := cUserName

	If !(cNomeUser $ cUsrAut)

		MsgAlert("Usuário " + cNomeUser + " não tem Autorização.", "Atenção")

		Return .F.

	EndIf

	//1 - ID do usuário/grupo
	//2 - Nome do usuário/grupo
	//3 - Senha do usuário
	//4 - E-mail do usuário
	PswOrder(2)

	If PswSeek(cNomeUser, .T.)
	
		If PswName(cCodSenha)

			lRetUser := .T.

		Else

			MsgAlert("Senha Incorreta!", "Atenção")

		EndIf

	EndIf

	//Por Segurança, volta para usuario normal
	PswOrder(2)
	PswSeek(cUsrOld, .T.)

Return lRetUser
