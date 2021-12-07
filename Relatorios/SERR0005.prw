#include 'protheus.ch'
#include 'parmtype.ch'

user function SERR0005()
	
	Local oReport
	Private cAlias := GetNextAlias()
	
	oReport:= ReportDef()
	oReport:PrintDialog()
		
Return 


Static Function ReportDef()
	
	Local cTitle	:= "Resultados por Cooperados"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'SERR0005'
	Local oReport
	
	Private oSecao1
	Private oSecao2
	Private oSecao3
	Private oSecao4
	
	CriaSX1(cPerg)
	
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)
	
	oReport:lParamPage := .F.
	
	oSecao1:= TRSection():New(oReport,"",{})
		
	// Pula linha antes de imprimir
	oSecao1:SetLinesBefore(2)

	// Retira todas as bordas da secao 1
	oSecao1:SetBorder("ALL",0,1,.T.)
	
	oReport:lParamPage := .t.
	
	// Acerta Margens
	oReport:SetLeftMargin(1)
	// Paisagem
	oReport:SetLandscape()
	// Papel A4
	oReport:OPAGE:NPAPERSIZE:= 9
	oSecao1:SetTotalInLine(.F.)
	
	oSecao1:SetPageBreak(.F.)

Return(oReport)


Static Function ReportPrint(oReport)
	
	Local oSecao1 	  := oReport:Section(1)
	Local oSecao2 	  := oReport:Section(1):Section(1)
	Local cAliasBD 	  := ""
	Local cErro       := ""
	Local lRet		  := .t.
	Local cQuery	  := ""
	Local cGropBY     := ""
	Local cOrdeBY     := ""
	
	// Recupera a massa de dados
	lRet := U_GetDataTMS(@cAliasBD,@cErro)
	
	cAliasBD := "%" + cAliasBD + "%"
	
	If mv_par13 == 1
	
		TRCell():New(oSecao1,"CODIGO" 			,(cAlias) ,"Codigo"				,/*Mascara*/				,40,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"COOPERADO"  		,(cAlias) ,"Cooperado"			,/*Mascara*/				,110,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"QTDCTE" 			,(cAlias) ,"Qtd CTE"			,"@E 99,999,999,999"		,25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"PRODUCAO" 		,(cAlias) ,"(+)Produção "		,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"ACRESCIMOS" 		,(cAlias) ,"(+)Outros Acr. "	,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"ICMSFRETE" 		,(cAlias) ,"(-)ICMS Frete"		,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"VLRTXADM" 		,(cAlias) ,"(-)TX Adm "			,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"DEDUCOES" 		,(cAlias) ,"(-)Outras Decr."	,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"VALORIDEAL" 		,(cAlias) ,"(=)Vlr. Ideal "		,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"VALORPAGO" 		,(cAlias) ,"Vlr. Pago "			,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"VLRGANHO" 		,(cAlias) ,"Ganho "				,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"EFETIVO" 			,(cAlias) ,"Efetivo "			,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"SESTSENAT" 		,(cAlias) ,"Sest"				,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"INSS" 			,(cAlias) ,"INSS"				,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"IRRF" 			,(cAlias) ,"IRRF"				,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"VALORLIQ" 		,(cAlias) ,"Liquido"			,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"CMVS" 			,(cAlias) ,"CMVS "				,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"SALDO" 			,(cAlias) ,"SALDO "				,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	
		oSecao1:Cell("VLRGANHO"):lBold := .T.
		oSecao1:Cell("EFETIVO"):lBold := .T.
	
//		aAdd(oSecao1:Cell("CODIGO"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("COOPERADO"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("QTDCTE"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("PRODUCAO"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("ACRESCIMOS"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("ICMSFRETE"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("VLRTXADM"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("DEDUCOES"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("VALORIDEAL"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("VALORPAGO"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("VLRGANHO"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("EFETIVO"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("SESTSENAT"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("INSS"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("IRRF"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("CMVS"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("VALORLIQ"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao1:Cell("SALDO"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
		
	
		//INFORMAÇÕES DOS TOTALIZADORES
		TRFunction():New(oSecao1:Cell("QTDCTE")		,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("PRODUCAO")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("ACRESCIMOS")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("ICMSFRETE")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("VLRTXADM")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("DEDUCOES")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("VALORIDEAL")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("VLRGANHO")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("VALORPAGO")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("EFETIVO")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("SESTSENAT")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("INSS")		,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("IRRF")		,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("VALORLIQ")	,NIL,"SUM")
		TRFunction():New(oSecao1:Cell("CMVS")		,NIL,"SUM")	
		TRFunction():New(oSecao1:Cell("SALDO")		,NIL,"SUM")
		
	
		cQuery := " DATATMS.A2_COD + DATATMS.A2_LOJA 				   'CODIGO' "
		cQuery += " ,DATATMS.A2_NOME								   'COOPERADO' "
		cQuery += ",COUNT(DATATMS.F2_DOC)  							   'QTDCTE' "
		cQuery += ",count(DISTINCT DATATMS.DTY_NUMCTC) 				   'QTDCONTR' "
		cQuery += ",cast((SUM(DATATMS.RATGANHO) / SUM(DATATMS.RATPRODUCA)) * 100  AS NUMERIC(15,4)) 'PERGANHO' "
		cQuery += ",cast(SUM(DATATMS.RATPRODUCA)    AS NUMERIC(15,4))  'PRODUCAO' "
		cQuery += ",cast(SUM(DATATMS.RATDESCARG)    AS NUMERIC(15,4))  'DESCARGA' "
		cQuery += ",cast(SUM(DATATMS.RATPEDAGIO)    AS NUMERIC(15,4))  'PEDAGIO' "
		cQuery += ",cast(SUM(DATATMS.RATACRES) + SUM(DATATMS.RATDESCARG) + SUM(DATATMS.RATPEDAGIO)	 AS NUMERIC(15,4))  'ACRESCIMOS' "
		cQuery += ",cast(SUM(DATATMS.RATICMFRET)    AS NUMERIC(15,4))  'ICMSFRETE' "
		cQuery += ",cast(SUM(DATATMS.RATTAXAADM)    AS NUMERIC(15,4))  'VLRTXADM' "
		cQuery += ",cast(SUM(DATATMS.RATDEDUC)	    AS NUMERIC(15,4))  'DEDUCOES' "
		cQuery += ",cast(SUM(DATATMS.RATIDEAL)	 	AS NUMERIC(15,4))  'VALORIDEAL' "
		cQuery += ",cast(SUM(DATATMS.RATPAGO)		AS NUMERIC(15,5))  'VALORPAGO' "
		cQuery += ",cast(SUM(DATATMS.RATGANHO)      AS NUMERIC(15,5))  'VLRGANHO' "
		cQuery += ",cast(SUM(DATATMS.RATTAXAADM)    AS NUMERIC(15,5)) + cast(SUM(DATATMS.RATGANHO)   AS NUMERIC(15,5)) 'EFETIVO' "
		cQuery += ",cast(SUM(DATATMS.RATSEST)       AS NUMERIC(15,4))  'SESTSENAT' "
		cQuery += ",cast(SUM(DATATMS.RATINSS)       AS NUMERIC(15,4))  'INSS' "
		cQuery += ",cast(SUM(DATATMS.RATIRRF)       AS NUMERIC(15,4))  'IRRF' "
		cQuery += ",cast(SUM(DATATMS.RATPIS)        AS NUMERIC(15,4))  'PIS' "
		cQuery += ",cast(SUM(DATATMS.RATCOFINS)     AS NUMERIC(15,4))  'COFINS' "
		cQuery += ",cast(SUM(DATATMS.RATCSLL)       AS NUMERIC(15,4))  'CSLL' "
		cQuery += ",cast(SUM(DATATMS.RATVLRLIQ)     AS NUMERIC(15,4))  'VALORLIQ' "
		cQuery += ",cast(SUM(DATATMS.RATCMV)        AS NUMERIC(15,4))  'CMVS' "
		cQuery += ",cast(SUM(DATATMS.RATVLRLIQ) - SUM(DATATMS.RATCMV)   AS NUMERIC(15,4)) 'SALDO' "
		
		cGropBY:= " GROUP BY A2_COD , A2_LOJA,A2_NOME"
		cOrdeBY:= " A2_NOME "
	
	Else
	
		oSecao2:= TRSection():New(oSecao1,"",{})
		oSecao2:SetBorder("ALL",0,1,.T.) // Retira todas as bordas da secao 2
		//Define a impressão dos totalizadores em linhas
		oSecao2:SetTotalInLine(.F.)
	
		TRCell():New(oSecao1,"CODIGO" 			,(cAlias) ,"Codigo"				,/*Mascara*/				,15,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao1,"COOPERADO"  		,(cAlias) ,"Cooperado"			,/*Mascara*/				,110,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		
		TRCell():New(oSecao2,"CONTRATO"  		,(cAlias) ,"Contrato"			,/*Mascara*/				,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"VIAGEM"  			,(cAlias) ,"Viagem"				,/*Mascara*/				,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"NOMECLIENTE"  	,(cAlias) ,"Cliente"			,/*Mascara*/				,120,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"CONHECIMENTO"  	,(cAlias) ,"CTE"				,/*Mascara*/				,40,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"SERIE"  			,(cAlias) ,"Serie"				,/*Mascara*/				,20,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"PRODUCAO" 		,(cAlias) ,"(+)Produção "		,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"ACRESCIMOS" 		,(cAlias) ,"(+)Outros Acr. "	,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"ICMSFRETE" 		,(cAlias) ,"(-)ICMS Frete"		,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"VLRTXADM" 		,(cAlias) ,"(-)TX Adm "			,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"DEDUCOES" 		,(cAlias) ,"(-)Outras Decr."	,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"VALORIDEAL" 		,(cAlias) ,"(=)Vlr. Ideal "		,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"VALORPAGO" 		,(cAlias) ,"Vlr. Pago "			,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"VLRGANHO" 		,(cAlias) ,"Ganho "				,"@E 99,999,999,999.99"		,40,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"EFETIVO" 			,(cAlias) ,"Efetivo "			,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"SESTSENAT" 		,(cAlias) ,"Sest"				,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"INSS" 			,(cAlias) ,"INSS"				,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"IRRF" 			,(cAlias) ,"IRRF"				,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"VALORLIQ" 		,(cAlias) ,"Liquido"			,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"CMVS" 			,(cAlias) ,"CMVS "				,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
		TRCell():New(oSecao2,"SALDO" 			,(cAlias) ,"SALDO "				,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	
	
		oSecao1:Cell("CODIGO"):lBold := .T.
		oSecao1:Cell("COOPERADO"):lBold := .T.
		oSecao2:Cell("VLRGANHO"):lBold := .T.
		oSecao2:Cell("EFETIVO"):lBold := .T.
	
//		aAdd(oSecao2:Cell("CONTRATO"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("VIAGEM"):aFormatCond			, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("NOMECLIENTE"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("CONHECIMENTO"):aFormatCond	, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("SERIE"):aFormatCond			, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("PRODUCAO"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("ACRESCIMOS"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("ICMSFRETE"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("VLRTXADM"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("DEDUCOES"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("VALORIDEAL"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("VALORPAGO"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
//		aAdd(oSecao2:Cell("VLRGANHO"):aFormatCond		, {"ROUND(VLRGANHO,2) < 0.00 " ,CLR_YELLOW,})
		
	
		//INFORMAÇÕES DOS TOTALIZADORES
		TRFunction():New(oSecao2:Cell("CONHECIMENTO"),NIL,"COUNT")
		TRFunction():New(oSecao2:Cell("PRODUCAO")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("ACRESCIMOS")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("ICMSFRETE")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("VLRTXADM")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("DEDUCOES")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("VALORIDEAL")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("VLRGANHO")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("VALORPAGO")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("EFETIVO")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("SESTSENAT")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("INSS")		,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("IRRF")		,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("VALORLIQ")	,NIL,"SUM")
		TRFunction():New(oSecao2:Cell("CMVS")		,NIL,"SUM")	
		TRFunction():New(oSecao2:Cell("SALDO")		,NIL,"SUM")
			
		oSecao2:SetParentQuery()
		oSecao2:SetParentFilter({|cParam| (cAlias)->(CODIGO) = cParam }, {|| (cAlias)->(CODIGO) })
	
		cQuery := " DATATMS.A2_COD + DATATMS.A2_LOJA 			'CODIGO' "
		cQuery += ",DATATMS.A2_NOME								'COOPERADO' "
		cQuery += ",DATATMS.A1_COD + A1_LOJA + '-' + UPPER(DATATMS.A1_NOME)	'NOMECLIENTE' "
		cQuery += ",DATATMS.DTY_NUMCTC							'CONTRATO' "
		cQuery += ",DATATMS.DTQ_VIAGEM							'VIAGEM' "
		cQuery += ",DATATMS.F2_DOC								'CONHECIMENTO' "
		cQuery += ",DATATMS.F2_SERIE							'SERIE' "
		cQuery += ",DATATMS.RATPRODUCA  						'PRODUCAO' "
		cQuery += ",DATATMS.RATDESCARG   						'DESCARGA' "
		cQuery += ",DATATMS.RATPEDAGIO   						'PEDAGIO' "
		cQuery += ",DATATMS.RATACRES + DATATMS.RATDESCARG + DATATMS.RATPEDAGIO 'ACRESCIMOS' "
		cQuery += ",DATATMS.RATICMFRET  						'ICMSFRETE' "
		cQuery += ",DATATMS.RATTAXAADM 							'VLRTXADM' "
		cQuery += ",DATATMS.RATDEDUC  							'DEDUCOES' "
		cQuery += ",DATATMS.RATIDEAL 							'VALORIDEAL' "
		cQuery += ",DATATMS.RATPAGO  							'VALORPAGO' "
		cQuery += ",DATATMS.RATGANHO 							'VLRGANHO' "
		cQuery += ",DATATMS.RATTAXAADM  +  DATATMS.RATGANHO 	'EFETIVO' "
		cQuery += ",DATATMS.RATSEST 							'SESTSENAT' "
		cQuery += ",DATATMS.RATINSS  							'INSS' "
		cQuery += ",DATATMS.RATIRRF  							'IRRF' "
		cQuery += ",DATATMS.RATPIS 								'PIS' "
		cQuery += ",DATATMS.RATCOFINS  							'COFINS' "
		cQuery += ",DATATMS.RATCSLL 							'CSLL' "
		cQuery += ",DATATMS.RATVLRLIQ 							'VALORLIQ' "
		cQuery += ",DATATMS.RATCMV  							'CMVS' "
		cQuery += ",DATATMS.RATVLRLIQ -  DATATMS.RATCMV  		'SALDO' "
	
		cOrdeBY := " A2_NOME,DTY_NUMCTC,F2_DOC,F2_SERIE "
	End If
	
	cGropBY:= "%" + cGropBY + "%"
	cOrdeBY:= "%" + cOrdeBY + "%"
	cQuery := "%" + cQuery + "%"
	
	oSecao1:BeginQuery()
	
	BeginSQL Alias cAlias
		
		%noparser%
		
		WITH DATATMS AS (SELECT * FROM %Exp:cAliasBD%  
						WHERE DTY_FILORI 	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
						AND   A1_COD 		BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
						AND   A1_LOJA 		BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
						AND   DTY_DATCTC 	BETWEEN %Exp:DTOS(MV_PAR07)% AND %Exp:DTOS(MV_PAR08)%
						AND   A2_COD  		BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
						AND   DTY_NUMCTC 	BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR12%)
		SELECT 
		
			%Exp:cQuery%
		
		FROM DATATMS
		
		%Exp:cGropBY%
		ORDER BY %Exp:cOrdeBY%
		
	EndSQL
	
	oSecao1:EndQuery()	
	oSecao1:Print()
	
	If 	mv_par13 == 2
		oSecao2:PrintLine()
	End If

return


Static function criaSX1(cPerg)
	
	Local aDados := {}
	
	aAdd( aDados, {cPerg,'01','Filial De'   	 , '','','mv_ch01','C',4,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','Filial Ate'  	 , '','','mv_ch02','C',4,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'03','Cliente De'   	 , '','','mv_ch03','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'04','Cliente Ate'  	 , '','','mv_ch04','C',6,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'05','Loja De'   	 	 , '','','mv_ch05','C',2,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'06','Loja Ate'  	 	 , '','','mv_ch06','C',2,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'07','Dt Contrato De'   , '','','mv_ch07','D',8,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'08','Dt Contrato Ate'  , '','','mv_ch08','D',8,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'09','Cooperado De'   	 , '','','mv_ch09','C',6,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'10','Cooperado Ate'  	 , '','','mv_ch10','C',6,0,0,'G','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'11','Contrato De'   	 , '','','mv_ch11','C',9,0,0,'G','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'12','Contrato Ate'  	 , '','','mv_ch12','C',9,0,0,'G','','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'13','Modelo'  	 	 , '','','mv_ch13','N',1,0,3,'C','','MV_PAR13','Sintetico'       ,'','','','','Analitico','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
			
	U_AtuSx1(aDados)						
return

