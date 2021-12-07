#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SERR0001
@author Totvs Vitoria - Mauricio Silva
@author kenny.roger
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERR0001()
	
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
	
	Local cTitle	:= "CMV - Despesas em Aberto"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'SERR0001'
	Local oReport
	
	Private oSecao1
	Private oSecao2
	
	CriaSX1(cPerg)
	
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)
	
	oReport:lParamPage := .F.
	
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
	
	TRCell():New(oSecao1,"RA_MAT" 			,(cAlias) ,"Matrícula"		,/*Mascara*/	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"A2_COD"  			,(cAlias) ,"Código"			,/*Mascara*/	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"A2_NOME" 			,(cAlias) ,"Nome"			,/*Mascara*/	,60,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")

	oSecao2:= TRSection():New(oSecao1,"",{})
	oSecao2:SetBorder("ALL",0,1,.T.)
	oSecao2:SetTotalInLine(.f.)
	
	TRCell():New(oSecao2,"DT7_CODDES"  		,(cAlias) ,"Cód. Despesa"	,/*Mascara*/	,20,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"DT7_DESCRI"		,(cAlias) ,"Descrição"		,/*Mascara*/	,30,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z1_NUM"			,(cAlias) ,"Movimento"		,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z1_PARCELA"		,(cAlias) ,"Parc."			,/*Mascara*/	,04,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z1_EMISSAO"		,(cAlias) ,"Emissão"		,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z1_VENCTO"		,(cAlias) ,"Vencimento"		,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z1_VALOR"			,(cAlias) ,"R$ Valor"		,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z1_SALDO"			,(cAlias) ,"R$ Saldo"		,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z1_HISTORI"		,(cAlias) ,"Histórico"		,/*Mascara*/	,63,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")

	oSecao2:SetParentQuery()
	oSecao2:SetParentFilter({|cParam| (cAlias)->(A2_COD) = cParam }, {|| (cAlias)->(A2_COD) })
	
	//INFORMAÇÕES DOS TOTALIZADORES
	TRFunction():New(oSecao2:Cell("Z1_VALOR"),NIL,"SUM")
	TRFunction():New(oSecao2:Cell("Z1_SALDO"),NIL,"SUM")
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
	Local oSecao2 		 := oReport:Section(1):Section(1)
	
	oSecao1:BeginQuery()
	BeginSQL Alias cAlias
					
		SELECT 
		
		SA2.A2_COD
		,SRA.RA_MAT
		,SA2.A2_NOME
		,LTRIM(RTRIM(DT7.DT7_CODDES)) AS DT7_CODDES
		,LTRIM(RTRIM(DT7.DT7_DESCRI)) AS DT7_DESCRI
		,SZ1.Z1_NUM
		,SZ1.Z1_PARCELA
		,SZ1.Z1_EMISSAO
		,SZ1.Z1_VENCTO
		,SZ1.Z1_VALOR
		,SZ1.Z1_SALDO
		,SZ1.Z1_HISTORI
		FROM %Table:SZ1% SZ1 
		
		JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial("SA2")%
		AND SA2.A2_COD = SZ1.Z1_FORNECE
		AND SA2.A2_LOJA = SZ1.Z1_LOJA
		AND SA2.D_E_L_E_T_ =''
		
		JOIN %Table:SRA% SRA ON SRA.RA_FILIAL = %Exp:xFilial("SRA")%
		AND SRA.RA_YFORN = SA2.A2_COD
		AND SRA.D_E_L_E_T_ = ''
		
		JOIN %Table:DT7% DT7 ON DT7.DT7_FILIAL = %Exp:xFilial("DT7")%
		AND DT7.DT7_CODDES = SZ1.Z1_CODDESP
		AND DT7.D_E_L_E_T_ =''
		
		WHERE SZ1.D_E_L_E_T_ =''	
		AND SZ1.Z1_SALDO > 0
		AND SZ1.Z1_FILIAL = %Exp:xFilial("SZ1")%
		AND SZ1.Z1_EMISSAO BETWEEN %Exp:DTos(mv_par01)% AND %Exp:DTos(mv_par02)%
		AND SZ1.Z1_VENCTO  BETWEEN %Exp:DTos(mv_par03)% AND %Exp:DTos(mv_par04)%
		AND DT7.DT7_CODDES BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
		AND SA2.A2_COD 	   BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
		
		ORDER BY SA2.A2_NOME , DT7.DT7_DESCRI , SZ1.Z1_VENCTO
		
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
	
	aAdd( aDados, {cPerg,'01','Emissao De'    , '','','mv_ch01','D',8						,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','Emissao Ate'   , '','','mv_ch02','D',8						,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'03','Vencimento De' , '','','mv_ch03','D',8						,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'04','Vencimento Ate', '','','mv_ch04','D',8						,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'05','Despesa de'	  , '','','mv_ch05','C',TAMSX3("DT7_CODDES")[1]	,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','DT7','','','','',''} )
	aAdd( aDados, {cPerg,'06','Despesa Ate'	  , '','','mv_ch06','C',TAMSX3("DT7_CODDES")[1]	,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','DT7','','','','',''} )
	aAdd( aDados, {cPerg,'07','Fornecedor De' , '','','mv_ch07','C',TAMSX3("A2_COD")[1]		,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
	aAdd( aDados, {cPerg,'08','Fornecedor Ate', '','','mv_ch08','C',TAMSX3("A2_COD")[1]		,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
		
	U_AtuSx1(aDados)					
return
