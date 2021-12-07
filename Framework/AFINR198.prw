#include 'protheus.ch'
#include 'parmtype.ch'

user function BFINR198()
	
	Local oReport
	Private cAlias := GetNextAlias()
	
	oReport:= ReportDef()
	oReport:PrintDialog()
	
return

Static Function ReportDef()
	
	Local cTitle	:= "Baixas por Naturezas"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'BFINR198'
	Local oReport
	
	Private oSecao1
	Private oSecao2
	
	//CriaSX1(cPerg)
	
	//Pergunte(cPerg,.F.)
	
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)
	
	oReport:lParamPage := .T.
	
	oSecao1:= TRSection():New(oReport,"",{})
		
	// Pula linha antes de imprimir
	oSecao1:SetLinesBefore(2)

	// Retira todas as bordas da secao 1
	oSecao1:SetBorder("ALL",0,1,.T.)
	
	// Acerta Margens
	oReport:SetLeftMargin(1)
	// Papel A4
	oReport:OPAGE:NPAPERSIZE:= 9
	oSecao1:SetTotalInLine(.F.)
	
	TRCell():New(oSecao1,"ED_PAI" 			,(cAlias) ,"Codigo"			,/*Mascara*/	,10,/*lPixel*/,{|| MascNat((cAlias)->(ED_PAI)) })//,"LEFT"	 ,,"LEFT")
//	TRCell():New(oSecao1,"ED_CODIGO"  		,(cAlias) ,"Natureza"		,/*Mascara*/	,15,/*lPixel*/,{|| MascNat((cAlias)->(ED_CODIGO)) })//,"LEFT",,"LEFT")
	TRCell():New(oSecao1,"DESCPAI"			,(cAlias) ,"Descricao"		,/*Mascara*/	,200,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
//	TRCell():New(oSecao1,"E5_VALOR"			,(cAlias) ,"R$ Valor"		,"@E 999,999,999.99"/*Mascara*/	,20,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
	
	oSecao2:= TRSection():New(oSecao1,"",{})
	oSecao2:SetBorder("ALL",0,1,.T.)
	oSecao2:SetTotalInLine(.f.)
	
	TRCell():New(oSecao2,"ED_CODIGO"  		,(cAlias) ,"Natureza"		,/*Mascara*/	,15,/*lPixel*/,{|| MascNat((cAlias)->(ED_CODIGO)) })//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"ED_DESCRIC"		,(cAlias) ,"Descricao"		,/*Mascara*/	,200,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E5_VALOR"			,(cAlias) ,"R$ Valor"		,"@E 999,999,999.99"/*Mascara*/	,20,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
	
	oSecao2:SetParentQuery()
	oSecao2:SetParentFilter({|cParam| (cAlias)->(ED_PAI) = cParam }, {|| (cAlias)->(ED_PAI) })
	oSecao1:SetPageBreak(.F.)
	
	//INFORMAÇÕES DOS TOTALIZADORES
	TRFunction():New(oSecao2:Cell("E5_VALOR")		,NIL,"SUM")

Return(oReport)

Static Function ReportPrint(oReport)
	
	Local oSecao1 		 := oReport:Section(1)
	Local oSecao2 		 := oReport:Section(1):Section(1)
	
	oSecao1:BeginQuery()
	BeginSQL Alias cAlias
				
		SELECT
			SED.ED_PAI,SEDPAI.ED_DESCRIC AS DESCPAI, SED.ED_CODIGO , SED.ED_DESCRIC, SUM(E5_VALOR)  AS E5_VALOR
		FROM
		   SE5010 SE5 
		
		    JOIN
		      SED010 SED 
		      ON (SED.ED_CODIGO = SE5.E5_NATUREZ 
		      AND SED.ED_FILIAL = SUBSTRING(SE5.E5_FILORIG , 1 , 2) + SPACE(2) 
		      AND SED.D_E_L_E_T_ = ' ' ) 
		      
		       JOIN SED010 SEDPAI 
		      ON (SEDPAI.ED_CODIGO = SED.ED_PAI 
		      AND SEDPAI.ED_FILIAL = SED.ED_FILIAL
		      AND SEDPAI.D_E_L_E_T_ = ' ' )	 
		      
		WHERE
		   (SE5.E5_FILORIG = '1001' OR SE5.E5_FILIAL = '1001' )
		   AND SE5.E5_PREFIXO BETWEEN '   ' AND 'ZZZ' 
		   AND SE5.E5_CLIFOR BETWEEN '      ' AND 'ZZZZZZ' 
		   AND SE5.E5_LOJA BETWEEN '  ' AND 'ZZ' 
		   AND ((SE5.E5_NATUREZ BETWEEN '          ' AND 'ZZZZZZZZZZ') OR ( SE5.R_E_C_N_O_ IN  (SELECT
																			   E5.R_E_C_N_O_ 
																			FROM
																			   SE5010 E5,
																			   SEV010 EV 
																			WHERE
																			   EV.EV_FILIAL = '1001' 
																			   AND EV.EV_PREFIXO = SE5.E5_PREFIXO 
																			   AND EV.EV_NUM = SE5.E5_NUMERO 
																			   AND EV.EV_PARCELA = SE5.E5_PARCELA 
																			   AND EV.EV_TIPO = SE5.E5_TIPO 
																			   AND EV.EV_CLIFOR = SE5.E5_CLIFOR 
																			   AND EV.EV_LOJA = SE5.E5_LOJA 
																			   AND EV.EV_IDENT = '2' 
																			   AND EV.EV_SEQ = SE5.E5_SEQ 
																			   AND EV.EV_NATUREZ BETWEEN '          ' AND 'ZZZZZZZZZZ' 
																			   AND EV.D_E_L_E_T_ = ' ' )))
		   AND SE5.E5_BANCO BETWEEN '   ' AND 'ZZZ' 
		   AND SE5.E5_DATA BETWEEN '20200801' AND '20200831' 
		   AND SE5.E5_DTDIGIT BETWEEN '20200101' AND '20201231' 
		   AND SE5.E5_LOTE BETWEEN '    ' AND 'ZZZZ' 
		   AND SE5.E5_TIPODOC <> '  ' 
		   AND SE5.E5_NUMERO <> '         ' 
		   AND SE5.E5_TIPODOC <> 'CH' 
		   AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','VA')
		   AND SE5.E5_SITUACA NOT IN ('E','X')
		   AND (((SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC <> 'ES') OR (SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC = 'ES'))
		   OR ((SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC <> 'ES') OR (SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC = 'ES')))
		
		   AND SE5.D_E_L_E_T_ = ' '
		      
		   GROUP BY SED.ED_PAI,SEDPAI.ED_DESCRIC, SED.ED_CODIGO , SED.ED_DESCRIC

		   ORDER BY
		   SED.ED_PAI,
		   SED.ED_CODIGO

		
	EndSQL
	
	oSecao1:EndQuery()	
	oSecao1:Print()
return