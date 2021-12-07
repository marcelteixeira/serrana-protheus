#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SERR0006
@author Totvs Vitoria - Mauricio Silva
@author kenny.roger
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERR0006()
	
	Local oReport
	Private cAlias := GetNextAlias()
	
	oReport:= ReportDef()
	oReport:PrintDialog()
	
return



/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()
	
	Local cTitle	:= "Serviços Frete por cooperado"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'SERR0006'
	Local oReport
	
	Private oSecao1
	Private oSecao2
	Private oSecao3
	Private oSecao4
	
	CriaSX1(cPerg)
	
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)
	
	oSecao1:= TRSection():New(oReport,"",{})
		
	// Pula linha antes de imprimir
	oSecao1:SetLinesBefore(2)

	// Retira todas as bordas da secao 1
	oSecao1:SetBorder("ALL",0,1,.T.)
	
	oReport:lParamPage := .t.
	oReport:SetLandscape()
	
	// Acerta Margens
	oReport:SetLeftMargin(1)
	// Papel A4
	oReport:OPAGE:NPAPERSIZE:= 9
	oSecao1:SetTotalInLine(.F.)
	
	TRCell():New(oSecao1,"CODIGO" 				,(cAlias) ,"Codigo"			,/*Mascara*/			,15,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"A2_NOME"  			,(cAlias) ,"Cooperado"		,/*Mascara*/			,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"CN9_TPCTO" 			,(cAlias) ,"Tipo"			,/*Mascara*/			,12,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"CN1_DESCRI" 			,(cAlias) ,"Descricao"		,/*Mascara*/			,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"QTD" 					,(cAlias) ,"Qtd Med."		,/*Mascara*/			,12,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"BRUTO" 				,(cAlias) ,"Vlr. Bruto "	,"@E 99,999,999,999.99"	,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"E2_INSS" 				,(cAlias) ,"INSS"			,"@E 99,999,999,999.99"	,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"E2_IRRF" 				,(cAlias) ,"IRRF "			,"@E 99,999,999,999.99"	,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"E2_SEST" 				,(cAlias) ,"SEST"			,"@E 99,999,999,999.99"	,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"E2_VALOR" 			,(cAlias) ,"Vlr. Liq."		,"@E 99,999,999,999.99"	,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"CMVS" 				,(cAlias) ,"CMVs"			,"@E 99,999,999,999.99"	,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"SALDO" 				,(cAlias) ,"Saldo "			,"@E 99,999,999,999.99"	,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")

	//INFORMAÇÕES DOS TOTALIZADORES
	TRFunction():New(oSecao1:Cell("QTD")		,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("BRUTO")		,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("E2_INSS")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("E2_IRRF")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("E2_SEST")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("E2_VALOR")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("CMVS")		,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("SALDO")		,NIL,"SUM")
	
	oSecao1:SetPageBreak(.F.)

Return(oReport)

/*/{Protheus.doc} ReportPrint
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, description
@type function
/*/
Static Function ReportPrint(oReport)
	
	Local oSecao1 		 := oReport:Section(1)
	Local cTipos		 := SuperGetMV("MV_YTPCTC",.f.,"006/013")
	
	cTipos:= "%" + FormatIn(cTipos,"/") + "%"
		
	oSecao1:BeginQuery()
	BeginSQL Alias cAlias
	
	%noparser%
		
		WITH DATATMS AS (SELECT
						
						SA2.A2_COD
						,SA2.A2_LOJA
						,SA2.A2_NOME
						,CN9.CN9_TPCTO
						,CN1.CN1_DESCRI
						,CND_NUMMED
						,CND_CONTRA
						,CND_REVISA
						,SE2.E2_FILIAL
						,SE2.E2_EMISSAO
						,SE2.E2_MEDNUME
						,SE2.E2_MDCONTR
						,SE2.E2_TIPO
						,SE2.E2_INSS
						,SE2.E2_IRRF
						,SE2.E2_SEST
						,E2_VALOR  + E2_INSS + E2_IRRF + E2_PIS + E2_COFINS + E2_CSLL + E2_SEST AS BRUTO
						,SE2.E2_VALOR
						
						,ISNULL((SELECT SUM(E2_VALOR) FROM %Table:SE2% SE2X 
						WHERE SE2X.E2_FILIAL = CND.CND_FILIAL 
						AND SE2X.E2_MEDNUME = CND.CND_NUMMED 
						AND SE2X.E2_MDCONTR = CND.CND_CONTRA 
						AND SE2X.E2_MDREVIS = CND.CND_REVISA  
						AND SE2X.E2_FORNECE = SE2.E2_FORNECE 
						AND SE2X.E2_LOJA = SE2.E2_LOJA 
						AND SE2X.E2_YTABORI ='SZ2' AND SE2X.D_E_L_E_T_ =''),0) CMVS
						
						FROM %Table:CND% CND
						
						JOIN %Table:CN9% CN9 ON CN9.CN9_FILIAL = CND.CND_FILIAL
						AND CN9.CN9_NUMERO = CND.CND_CONTRA
						AND CN9.D_E_L_E_T_ = ''
						
						JOIN %Table:CN1% CN1 ON CN1.CN1_FILIAL = %Exp:xFilial("CN1")%
						AND CN1.CN1_CODIGO = CN9.CN9_TPCTO
						AND CN1.D_E_L_E_T_ =''
						
						JOIN %Table:SE2% SE2 ON SE2.E2_FILIAL = CND.CND_FILIAL
						AND SE2.E2_MEDNUME = CND.CND_NUMMED
						AND SE2.E2_MDCONTR = CND.CND_CONTRA
						AND SE2.E2_MDREVIS = CND.CND_REVISA
						AND SE2.D_E_L_E_T_ =''
						
						JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial("SA2")%
						AND SA2.A2_COD = SE2.E2_FORNECE
						AND SA2.A2_LOJA = SE2.E2_LOJA
						AND SA2.D_E_L_E_T_ =''
						
						WHERE CND.D_E_L_E_T_ =''
						AND E2_TIPO ='BOL'
						AND CN9.CN9_TPCTO IN %Exp:cTipos%
						AND SE2.E2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
						AND SA2.A2_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
						AND SE2.E2_MDCONTR  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
						AND SE2.E2_MEDNUME  BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
						AND SE2.E2_EMISSAO  BETWEEN %Exp:DTOS(MV_PAR09)% AND %Exp:DTOS(MV_PAR10)%)

		SELECT 
		
		A2_COD + A2_LOJA 			AS CODIGO
		,A2_NOME
		,CN9_TPCTO
		,CN1_DESCRI
		,COUNT(CND_NUMMED) 			AS QTD
		,SUM(BRUTO) 				AS BRUTO
		,SUM(E2_INSS) 				AS E2_INSS
		,SUM(E2_IRRF) 				AS E2_IRRF
		,SUM(E2_SEST) 				AS E2_SEST
		,SUM(E2_VALOR) 				AS E2_VALOR
		,SUM(CMVS) 					AS CMVS
		,SUM(E2_VALOR) - SUM(CMVS)  AS SALDO
		
		FROM DATATMS
		
		
		GROUP BY A2_COD,A2_LOJA, A2_NOME,CN9_TPCTO,CN1_DESCRI


	EndSQL
	
	oSecao1:EndQuery()	
	oSecao1:Print()

return
/*/{Protheus.doc} criaSX1
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cPerg, characters, description
@type function
/*/

static function criaSX1(cPerg)
	
	Local aDados := {}
	
	aAdd( aDados, {cPerg,'01','Filial De'   	 , '','','mv_ch01','C',4,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','Filial Ate'  	 , '','','mv_ch02','C',4,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'03','Cooperado De'   	 , '','','mv_ch03','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'04','Cooperado Ate'  	 , '','','mv_ch04','C',6,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'05','Contrato De'   	 , '','','mv_ch05','C',9,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'06','Contrato Ate'  	 , '','','mv_ch06','C',9,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'07','Medicao De'   	 , '','','mv_ch07','C',6,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'08','Medicao Ate'  	 , '','','mv_ch08','C',6,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'09','Data Emissao De'  , '','','mv_ch09','D',8,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'10','Data Emissao Ate' , '','','mv_ch10','D',8,0,0,'G','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
			
	U_AtuSx1(aDados)						
return
