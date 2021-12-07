#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} SERR0008
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/08/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User function SERR0008()
	
	Local oReport
	Private cAlias := GetNextAlias()
	
	oReport:= ReportDef()
	oReport:PrintDialog()
	
return


/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/08/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()
	
	Local cTitle	:= "Visão Financeira por Cooperado "
	Local cNomeRep	:= 'SERR0008'
	Local cPerg     := 'SERR0008'
	Local oReport
	
	Private oSecao1
	Private oSecao2
	
	CriaSX1(cPerg)
	
	Pergunte(cPerg,.F.)
	
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
	
	TRCell():New(oSecao1,"RA_CIC" 				,(cAlias) ,"CPF/CNPJ"		,/*Mascara*/		,20,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"E2_FORNECE" 			,(cAlias) ,"Codigo"			,/*Mascara*/		,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"E2_LOJA"  			,(cAlias) ,"Loja"			,/*Mascara*/		,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"RA_MAT"  				,(cAlias) ,"Matricula"		,/*Mascara*/		,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"RA_NOME" 				,(cAlias) ,"Cooperado"		,/*Mascara*/		,120,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	
	oSecao1:Cell("E2_FORNECE"):lBold := .T.
	oSecao1:Cell("E2_LOJA"):lBold 	 := .T.
	oSecao1:Cell("RA_MAT"):lBold 	 := .T.
	oSecao1:Cell("RA_NOME"):lBold 	 := .T.
	oSecao1:Cell("RA_CIC"):lBold 	 := .T.
	
	oSecao2:= TRSection():New(oSecao1,"",{})
	oSecao2:SetBorder("ALL",0,1,.T.)
	oSecao2:SetTotalInLine(.f.)
	
	TRCell():New(oSecao2,"E2_PREFIXO"  			,(cAlias) ,"Prefixo"		,/*Mascara*/		,15,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_NUM"				,(cAlias) ,"Numero"			,/*Mascara*/		,25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_PARCELA"			,(cAlias) ,"Parc."			,/*Mascara*/		,10,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_TIPO"				,(cAlias) ,"Tipo"			,/*Mascara*/		,10,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_EMISSAO"			,(cAlias) ,"Emissao"		,/*Mascara*/		,10,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_VALOR"				,(cAlias) ,"R$ Valor"		,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_IRRF"				,(cAlias) ,"R$ IRRF"		,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_INSS"				,(cAlias) ,"R$ INSS"		,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_SEST"				,(cAlias) ,"R$ SEST/SENAT"	,"@E 999,999,999.99",30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"BCIRRF"				,(cAlias) ,"R$ BC IRRF"		,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
	TRCell():New(oSecao2,"E2_BASEINS"			,(cAlias) ,"R$ BC INSS"		,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"E2_NATUREZ"			,(cAlias) ,"Natureza"		,/*Mascara*/		,20,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"ED_DESCRIC"			,(cAlias) ,"Descrição"		,/*Mascara*/		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
		
	//INFORMAÇÕES DOS TOTALIZADORES
	TRFunction():New(oSecao2:Cell("E2_VALOR")	,NIL,"SUM")
	TRFunction():New(oSecao2:Cell("E2_IRRF")	,NIL,"SUM")
	TRFunction():New(oSecao2:Cell("E2_INSS")	,NIL,"SUM")	
	TRFunction():New(oSecao2:Cell("E2_SEST")	,NIL,"SUM")
	TRFunction():New(oSecao2:Cell("BCIRRF")		,NIL,"SUM")
	TRFunction():New(oSecao2:Cell("E2_BASEINS")	,NIL,"SUM")	
			
	oSecao2:SetParentQuery()
	oSecao2:SetParentFilter({|cParam| (cAlias)->(RA_NOME) = cParam }, {|| (cAlias)->(RA_NOME) })
	oSecao1:SetPageBreak(.F.)

Return(oReport)

/*/{Protheus.doc} ReportPrint
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/08/2020
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, description
@type function
/*/
Static Function ReportPrint(oReport)
	
	Local oSecao1    := oReport:Section(1)
	Local oSecao2    := oReport:Section(1):Section(1)
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

	oSecao1:BeginQuery()
	
	BeginSQL Alias cAlias

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
		AND SE2.E2_TIPO NOT IN ('NDF')
		AND SRA.RA_PROCES = %Exp:MV_PAR05%
		AND SRA.RA_CC BETWEEN %Exp:mv_par10% AND %Exp:mv_par11%
		AND SE2.E2_NATUREZ BETWEEN %Exp:mv_par08% AND %Exp:mv_par09%
		AND SE2.E2_FILORIG BETWEEN %Exp:mv_par06% AND %Exp:mv_par07% 

		AND SE2.E2_PREFIXO IN %Exp:cPrfxInt%
		AND (SED.ED_YVERBA <> '' OR DT7.DT7_YVERBA IS NOT NULL)
		
		ORDER BY RA_NOME,E2_TIPO DESC,E2_EMISSAO,E2_NUM,E2_PARCELA

	EndSQL

	
	oSecao1:EndQuery()	
	oSecao1:Print()
return


/*/{Protheus.doc} criaSX1
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/08/2020
@version 1.0
@return ${return}, ${return_description}
@param cPerg, characters, description
@type function
/*/
static function criaSX1(cPerg)
	
	Local aDados := {}
	
	aAdd( aDados, {cPerg,'01','Emissao De'    , '','','mv_ch1','D',8						,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','Emissao Ate'   , '','','mv_ch2','D',8						,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'03','Fornecedor De' , '','','mv_ch3','C',TAMSX3("A2_COD")[1]		,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
	aAdd( aDados, {cPerg,'04','Fornecedor Ate', '','','mv_ch4','C',TAMSX3("A2_COD")[1]		,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
	aAdd( aDados, {cPerg,'05','Processo' 	  , '','','mv_ch5','C',5						,0,0,'G','Gpem020VldPrc() .and. Gpm020SetVar()','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','RCJ','','','','',''} )
	aAdd( aDados, {cPerg,'06','Filial De'     , '','','mv_ch6','C',4						,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','SM0_01','','','','',''} )
	aAdd( aDados, {cPerg,'07','Filial Ate'    , '','','mv_ch7','C',4						,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SM0_01','','','','',''} )
	aAdd( aDados, {cPerg,'08','Natureza De'   , '','','mv_ch8','C',TAMSX3("E2_NATUREZ")[1]  ,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','SED','','','','',''} )
	aAdd( aDados, {cPerg,'09','Natureza Ate'  , '','','mv_ch9','C',TAMSX3("E2_NATUREZ")[1]  ,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','SED','','','','',''} )
	aAdd( aDados, {cPerg,'10','C. Custo De'   , '','','mv_chA','C',TAMSX3("RA_CC")[1]		,0,0,'G','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','SED','','','','',''} )
	aAdd( aDados, {cPerg,'11','C. Custo Ate'  , '','','mv_chB','C',TAMSX3("RA_CC")[1]		,0,0,'G','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','SED','','','','',''} )
	U_AtuSx1(aDados)					
return
