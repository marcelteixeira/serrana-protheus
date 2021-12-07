#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} SERR0007
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/08/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User function SERR0007()
	
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
	
	Local cTitle	:= "Extrato - Capital Social Integralizado"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'SERR0007'
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
	
	TRCell():New(oSecao1,"Z3_FORNECE" 			,(cAlias) ,"Codigo"				,/*Mascara*/			,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"Z3_LOJA"  			,(cAlias) ,"Loja"				,/*Mascara*/			,10,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"A2_NOME" 				,(cAlias) ,"Cooperado"			,/*Mascara*/			,120,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"SALDOANT" 			,(cAlias) ,"R$ 	Saldo Anterior"	,"@E 999,999,999.99"	,60,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
	
	oSecao1:Cell("Z3_FORNECE"):lBold := .T.
	oSecao1:Cell("Z3_LOJA"):lBold := .T.
	oSecao1:Cell("A2_NOME"):lBold := .T.
	oSecao1:Cell("SALDOANT"):lBold := .T.
	
	oSecao2:= TRSection():New(oSecao1,"",{})
	oSecao2:SetBorder("ALL",0,1,.T.)
	oSecao2:SetTotalInLine(.f.)
	
	TRCell():New(oSecao2,"Z3_DATA"  		,(cAlias) ,"Data"			,/*Mascara*/	,15,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z3_TIPOLAN"		,(cAlias) ,"Movimento"		,/*Mascara*/	,15,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"Z3_HISTOR"		,(cAlias) ,"Historico"		,/*Mascara*/	,100,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"VALOR"			,(cAlias) ,"R$ Valor"		,"@E 999,999,999.99"/*Mascara*/	,20,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
	TRCell():New(oSecao2,"Z3_TIPMOV1"		,(cAlias) ,""				,/*Mascara*/	,05,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT",,"LEFT")
	TRCell():New(oSecao2,"SALDO"			,(cAlias) ,"R$ Saldo Atual"	,"@E 999,999,999.99"/*Mascara*/	,20,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
	
	oSecao2:Cell("Z3_TIPMOV1"):lBold := .T.
	
	TRFunction():New(oSecao2:Cell("SALDO"),"","ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| RetTotRel()}/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
	
	aAdd(oSecao2:Cell("VALOR"):aFormatCond			, {"Z3_TIPMOV1 == 'D' " ,,CLR_RED})
	aAdd(oSecao2:Cell("Z3_TIPMOV1"):aFormatCond		, {"Z3_TIPMOV1 == 'D' " ,,CLR_RED})
	
	oSecao2:SetParentQuery()
	oSecao2:SetParentFilter({|cParam| (cAlias)->(Z3_FORNECE + Z3_LOJA) = cParam }, {|| (cAlias)->(Z3_FORNECE + Z3_LOJA) })
	oSecao1:SetPageBreak(.F.)

Return(oReport)


/*/{Protheus.doc} RetTotRel
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 14/08/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function RetTotRel ()

	Local cAliasTot := GetNextAlias()
	Local nValor	:= 0
	
	BeginSQL Alias cAliasTot
	
		SELECT SUM(CASE WHEN SZ3.Z3_TIPMOV = 'C' THEN SZ3.Z3_VALOR ELSE SZ3.Z3_VALOR * -1 END) AS Z3_VALOR  
		FROM %Table:SZ3% SZ3
		WHERE SZ3.D_E_L_E_T_ 	=''
		AND SZ3.Z3_FORNECE  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND EXISTS (SELECT * FROM %Table:SZ3% SZ3A
					WHERE SZ3A.Z3_FILIAL = SZ3.Z3_FILIAL 
					AND SZ3A.Z3_FORNECE = SZ3.Z3_FORNECE 
					AND SZ3A.Z3_LOJA    = SZ3.Z3_LOJA
					AND SZ3A.Z3_DATA BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
					AND SZ3A.D_E_L_E_T_ ='')
	EndSQL
	
	nValor := (cAliasTot)->Z3_VALOR
	(cAliasTot)->(DbCloseArea())

Return nValor

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
	
	Local oSecao1 		 := oReport:Section(1)
	Local oSecao2 		 := oReport:Section(1):Section(1)
	
	oSecao1:BeginQuery()
	BeginSQL Alias cAlias
					
		
		SELECT
	    Z3_DATA
	    ,Z3_TIPMOV
		,Z3_FORNECE
		,Z3_LOJA
		,A2_NOME
		,Z3_TIPOLAN
		,Z3_TIPMOV AS Z3_TIPMOV1
		,Z3_DATA
		,UPPER(LTRIM(RTRIM(Z3_HISTOR))) Z3_HISTOR
		
		,ISNULL((SELECT SUM(CASE WHEN SZ3X.Z3_TIPMOV = 'C' THEN SZ3X.Z3_VALOR ELSE SZ3X.Z3_VALOR * -1 END) AS Z3_VALOR  
				FROM %Table:SZ3% SZ3X 
				WHERE SZ3X.D_E_L_E_T_ 	=''
				AND SZ3X.Z3_FILIAL  = SZ3.Z3_FILIAL
				AND SZ3X.Z3_FORNECE = SZ3.Z3_FORNECE
				AND SZ3X.Z3_LOJA 	= SZ3.Z3_LOJA
				AND SZ3X.Z3_DATA    < %Exp:DTOS(MV_PAR01)% ),0) AS SALDOANT
				
		,CASE WHEN SZ3.Z3_TIPMOV = 'D' THEN SZ3.Z3_VALOR ELSE 0 END DEBITO
		,CASE WHEN SZ3.Z3_TIPMOV = 'C' THEN SZ3.Z3_VALOR ELSE 0 END CREDITO
		,Z3_VALOR * CASE WHEN Z3_TIPMOV = 'D' THEN -1 ELSE 1 END AS VALOR
		
		,(SELECT SUM(Z3_VALOR * CASE WHEN S.Z3_TIPMOV = 'D' THEN -1 ELSE 1 END) FROM %Table:SZ3% AS S
		     WHERE S.Z3_FORNECE = SZ3.Z3_FORNECE 
		     AND S.Z3_FILIAL = SZ3.Z3_FILIAL
		     AND S.Z3_DATA + CAST(S.R_E_C_N_O_ AS varchar(10))  <= SZ3.Z3_DATA + CAST(SZ3.R_E_C_N_O_ AS varchar(10))
		     AND S.D_E_L_E_T_='') AS SALDO
		     
		FROM %Table:SZ3% SZ3
		
		JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial("SA2")%
		AND SA2.A2_COD = SZ3.Z3_FORNECE
		AND SA2.A2_LOJA = SZ3.Z3_LOJA
		AND SA2.D_E_L_E_T_ =''
		
		WHERE   SZ3.Z3_DATA 	BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		AND 	SZ3.Z3_FORNECE  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
				
		ORDER BY SZ3.Z3_FORNECE,SZ3.Z3_DATA, SZ3.R_E_C_N_O_
		
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
	
	aAdd( aDados, {cPerg,'01','DT Movimento'    , '','','mv_ch01','D',8						,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'02','DT Movimento'   	, '','','mv_ch02','D',8						,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''	,'','','','',''} )
	aAdd( aDados, {cPerg,'03','Fornecedor De' 	, '','','mv_ch03','C',TAMSX3("A2_COD")[1]	,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
	aAdd( aDados, {cPerg,'04','Fornecedor Ate'	, '','','mv_ch04','C',TAMSX3("A2_COD")[1]	,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','SA2','','','','',''} )
		
	U_AtuSx1(aDados)					
return
