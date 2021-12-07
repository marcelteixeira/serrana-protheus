#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SERR0003
@author Totvs Vitoria - Mauricio Silva
@author kenny.roger
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERR0003()
	
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
	
	Local cTitle	:= "Negociações de Fretes"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'SERR0003'
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
	
	// Acerta Margens
	oReport:SetLeftMargin(1)
	// Papel A4
	oReport:OPAGE:NPAPERSIZE:= 9
	oSecao1:SetTotalInLine(.F.)
	
	TRCell():New(oSecao1,"DTY_NUMCTC" 			,(cAlias) ,"Num. Contr."	,/*Mascara*/	,15,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_DATCTC"  			,(cAlias) ,"Emissão"		,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_VIAGEM" 			,(cAlias) ,"Viagem"			,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_CODVEI" 			,(cAlias) ,"Veículo"		,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_CODFOR" 			,(cAlias) ,"Codigo"			,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"A2_NOME" 				,(cAlias) ,"Fornecedor "	,/*Mascara*/	,30,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTQ_YFREID" 			,(cAlias) ,"Frete Ideal "	,/*Mascara*/	,15,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_VALFRE" 			,(cAlias) ,"Frete Comb. "	,/*Mascara*/	,15,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DIFERENCA" 			,(cAlias) ,"Ganho/Perda "	,/*Mascara*/	,15,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_QTDDOC" 			,(cAlias) ,"Qtd. Doc. "		,/*Mascara*/	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_QTDVOL" 			,(cAlias) ,"Qtd. Vol. "		,/*Mascara*/	,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DTY_PESO" 			,(cAlias) ,"Peso "			,/*Mascara*/	,12,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")

	//INFORMAÇÕES DOS TOTALIZADORES
	TRFunction():New(oSecao1:Cell("DTQ_YFREID"),NIL,"SUM")
	TRFunction():New(oSecao1:Cell("DTY_VALFRE"),NIL,"SUM")
	TRFunction():New(oSecao1:Cell("DIFERENCA"),NIL,"SUM")
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
	
	oSecao1:BeginQuery()
	BeginSQL Alias cAlias
					
		SELECT 
		
			DTY.DTY_NUMCTC
			,DTY.DTY_DATCTC
			,DTY.DTY_VIAGEM
			,DTY.DTY_CODVEI
			,DTY.DTY_CODFOR
			,SA2.A2_NOME
			,DTQ.DTQ_YFREID
			,DTY.DTY_VALFRE
			,DTQ.DTQ_YFREID - DTY.DTY_VALFRE AS DIFERENCA
			,DTY.DTY_QTDDOC
			,DTY.DTY_QTDVOL
			,DTY.DTY_PESO
		
		FROM %Table:DTY% DTY 
		
		JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial('SA2')%
		AND SA2.A2_COD = DTY.DTY_CODFOR 
		AND SA2.A2_LOJA = DTY.DTY_LOJFOR 
		AND SA2.D_E_L_E_T_ =' ' 
		
		JOIN %Table:DTQ% DTQ ON DTQ_FILIAL = %Exp:xFilial('DTQ')%
		AND DTQ.DTQ_FILORI = DTY.DTY_FILORI 
		AND DTQ.DTQ_VIAGEM = DTY.DTY_VIAGEM 
		AND DTQ.D_E_L_E_T_ =' ' 
		
		WHERE DTY.D_E_L_E_T_ =' ' 
		AND DTY.DTY_FILIAL = %Exp:cFilAnt%
		AND DTY.DTY_FILORI = %Exp:cFilAnt%
		AND DTY.DTY_DATCTC BETWEEN %Exp:DTos(mv_par01)% AND %Exp:DTos(mv_par02)%


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
	
	aAdd( aDados, {cPerg,'01','Dt Contrato De'    , '','','mv_ch01','D',8						,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','Dt Contrato Ate'   , '','','mv_ch02','D',8						,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
			
	U_AtuSx1(aDados)						
return
