#include 'protheus.ch'
#include 'parmtype.ch'

user function SERR0004()
	
	Local oReport
	Private cAlias := GetNextAlias()
	
	oReport:= ReportDef()
	oReport:PrintDialog()
		
Return 


Static Function ReportDef()
	
	Local cTitle	:= "Resultados por clientes"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'SERR0004'
	Local oReport
	
	Private oSecao1
	Private oSecao2
	Private oSecao3
	Private oSecao4
	
	CriaSX1(cPerg)
	
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)
	
	oReport:lParamPage := .t.
	
	oSecao1:= TRSection():New(oReport,"",{})
		
	// Pula linha antes de imprimir
	oSecao1:SetLinesBefore(2)

	// Retira todas as bordas da secao 1
	oSecao1:SetBorder("ALL",0,1,.T.)
	
	// Acerta Margens
	oReport:SetLeftMargin(1)
	// Paisagem
	oReport:SetLandscape()
	// Papel A4
	oReport:OPAGE:NPAPERSIZE:= 9
	oSecao1:SetTotalInLine(.F.)
	
	TRCell():New(oSecao1,"CODIGO" 			,(cAlias) ,"Codigo"				,/*Mascara*/				,35,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"RAZAOSOCIAL"  	,(cAlias) ,"Razao Social"		,/*Mascara*/				,110,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"QTDCTE" 			,(cAlias) ,"Qtd CTE"			,"@E 99,999,999,999"		,25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"PERGANHO" 		,(cAlias) ,"Ganho %"			,"@E 99,999,999,999.99"		,25,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"PERTAXAADM" 		,(cAlias) ,"TX Adm%"			,"@E 99,999,999,999.99"		,30,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"PRODUCAO" 		,(cAlias) ,"(+)Produção "		,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DESCARGA" 		,(cAlias) ,"(+)Descarga "		,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"PEDAGIO" 			,(cAlias) ,"(+)Pedagio "		,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"ACRESCIMOS" 		,(cAlias) ,"(+)Outros Acr. "	,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"ICMSFRETE" 		,(cAlias) ,"(-)ICMS Frete"		,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"VLRTXADM" 		,(cAlias) ,"(-)TX Adm "			,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"DEDUCOES" 		,(cAlias) ,"(-)Outras Decr."	,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"VALORIDEAL" 		,(cAlias) ,"(=)Valor Ideal "	,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"VALORPAGO" 		,(cAlias) ,"Valor Pago "		,"@E 99,999,999,999.99"		,60,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"VLRGANHO" 		,(cAlias) ,"Ganho "				,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")
	TRCell():New(oSecao1,"EFETIVO" 			,(cAlias) ,"Efetivo "			,"@E 99,999,999,999.99"		,50,/*lPixel*/,/*{|| code-block de impressao }*/)//,"LEFT"	 ,,"LEFT")

	//INFORMAÇÕES DOS TOTALIZADORES
	TRFunction():New(oSecao1:Cell("QTDCTE")		,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("PRODUCAO")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("DESCARGA")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("PEDAGIO")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("ACRESCIMOS")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("ICMSFRETE")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("VLRTXADM")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("DEDUCOES")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("VALORIDEAL")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("VLRGANHO")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("VALORPAGO")	,NIL,"SUM")
	TRFunction():New(oSecao1:Cell("EFETIVO")	,NIL,"SUM")
	
	oSecao1:SetPageBreak(.F.)

Return(oReport)


Static Function ReportPrint(oReport)
	
	Local oSecao1 	  := oReport:Section(1)
	Local cAliasBD 	  := ""
	Local cErro       := ""
	Local lRet		  := .t.
	
	// Recupera a massa de dados
	lRet := U_GetDataTMS(@cAliasBD,@cErro)
	
	cAliasBD := "%" + cAliasBD + "%"
	
	oSecao1:BeginQuery()
	
	BeginSQL Alias cAlias
		
		%noparser%
		
		WITH DATATMS AS (SELECT * FROM %Exp:cAliasBD%)
		
		SELECT 
		
		DATATMS.A1_COD + DATATMS.A1_LOJA 'CODIGO'
		,UPPER(DATATMS.A1_NOME)  'RAZAOSOCIAL'
		,COUNT(DATATMS.DT6_VALTOT)  'QTDCTE'
		,cast((SUM(DATATMS.RATGANHO) / SUM(DATATMS.RATPRODUCA)) * 100  AS NUMERIC(15,2)) 'PERGANHO'
		,cast((SUM(DATATMS.RATTAXAADM) / SUM(DATATMS.RATPRODUCA)) * 100  AS NUMERIC(15,2)) 'PERTAXAADM'
		,cast(SUM(DATATMS.DT6_VALTOT)	 AS NUMERIC(15,4))  'VALORCTE'
		,cast(SUM(DATATMS.F2_VALICM)	 AS NUMERIC(15,4))  'ICMS'
		,cast(SUM(DATATMS.RATPRODUCA)    AS NUMERIC(15,4))  'PRODUCAO'
		,cast(SUM(DATATMS.RATDESCARG)    AS NUMERIC(15,4))  'DESCARGA'
		,cast(SUM(DATATMS.RATPEDAGIO)    AS NUMERIC(15,4))  'PEDAGIO'
		,cast(SUM(DATATMS.RATACRES)	     AS NUMERIC(15,4))  'ACRESCIMOS'
		,cast(SUM(DATATMS.RATICMFRET)    AS NUMERIC(15,4))  'ICMSFRETE'
		,cast(SUM(DATATMS.RATTAXAADM)    AS NUMERIC(15,4))  'VLRTXADM'
		,cast(SUM(DATATMS.RATDEDUC)	     AS NUMERIC(15,4))  'DEDUCOES'
		,cast(SUM(DATATMS.RATIDEAL)		 AS NUMERIC(15,4))  'VALORIDEAL'
		,cast(SUM(DATATMS.RATPAGO)		 AS NUMERIC(15,5))  'VALORPAGO'
		,cast(SUM(DATATMS.RATGANHO)		 AS NUMERIC(15,5))  'VLRGANHO'
		,cast(SUM(DATATMS.RATTAXAADM)    AS NUMERIC(15,5)) + cast(SUM(DATATMS.RATGANHO)   AS NUMERIC(15,5)) 'EFETIVO'
		
		FROM DATATMS
		
		WHERE DATATMS.DTY_FILORI BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND       DATATMS.A1_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND      DATATMS.A1_LOJA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
		AND   DATATMS.DTY_DATCTC BETWEEN %Exp:DTOS(MV_PAR07)% AND %Exp:DTOS(MV_PAR08)%
		
		GROUP BY A1_COD,A1_LOJA,A1_NOME,A1_YTXADM
		
	EndSQL
	
	oSecao1:EndQuery()	
	oSecao1:Print()

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
	
	U_AtuSx1(aDados)						
return

User Function GetDataTMS(cAliasBD,cErro)

	Local cAlias  	:= GetNextAlias()
	Local cAliaTemp := GetNextAlias()
	Local aFileds 	:= {}
	Local aCpoData	:= {}
	Local cFields 	:= ""
	Local cQuery  	:= ""
	Local lRet		:= .T.
	Local nY		:= 0
	Local oTable  	:= Nil

	BeginSql Alias cALias
		
		SELECT
		A.RATPRODUCA + A.RATDESCARG + A.RATPEDAGIO + A.RATACRES - A.RATICMFRET - A.RATTAXAADM - A.RATDEDUC RATIDEAL
		,((A.RATPRODUCA + A.RATDESCARG + A.RATPEDAGIO + A.RATACRES - A.RATICMFRET - A.RATTAXAADM - A.RATDEDUC) / A.DTQ_YFREID) * A.DTY_VALFRE RATPAGO
		,((A.RATPRODUCA + A.RATDESCARG + A.RATPEDAGIO + A.RATACRES - A.RATICMFRET - A.RATTAXAADM - A.RATDEDUC) / A.DTQ_YFREID) * A.GANHOVGM RATGANHO
		,A.*
		
		FROM 
		(SELECT 
		SF2.F2_FILIAL
		,DTY.DTY_FILORI
		,DTY.DTY_NUMCTC
		,DTY.DTY_DATCTC
		,DTQ.DTQ_VIAGEM
		,DTY.DTY_QTDDOC
		,DTY.DTY_YFRETE
		,DTQ.DTQ_YFREID
		,DTY.DTY_VALFRE
		,DTQ.DTQ_YFREID - DTY.DTY_VALFRE AS GANHOVGM
		,SA2.A2_COD
		,SA2.A2_LOJA
		,SA2.A2_NOME
		,DTY.DTY_SEST
		,DTY.DTY_INSS
		,DTY.DTY_IRRF
		,DTY.DTY_PIS
		,DTY.DTY_COFINS
		,DTY.DTY_CSLL
		
		,ISNULL((SELECT SUM(E2_VALOR)  FROM %Table:SE2% SE2 
				WHERE E2_NUM = DTY.DTY_NUMCTC
				AND E2_FILIAL = DTY.DTY_FILORI
				AND E2_FORNECE = DTY.DTY_CODFOR
				AND E2_LOJA = DTY.DTY_LOJFOR
				AND E2_TIPO ='RC'
				AND D_E_L_E_T_ =''),0) AS VLRLIQ
		
		,ISNULL((SELECT SUM(E2_VALOR)  FROM %Table:SE2% SE2 
				WHERE E2_NUM = DTY.DTY_NUMCTC
				AND E2_FILIAL = DTY.DTY_FILORI
				AND E2_YTABORI ='SZ2'
				AND D_E_L_E_T_ =''),0) AS CMV
		,SF2.F2_DOC
		,SF2.F2_SERIE
		,SF2.F2_EMISSAO
		,SA1.A1_COD
		,SA1.A1_LOJA 
		,SA1.A1_NOME
		,SA1.A1_YTXADM
		,SD2.D2_PICM
		,SA1.A1_YTXADM + SD2.D2_PICM AS TXBRUT
		,DT6.DT6_VALTOT
		,SF2.F2_VALICM
		,ISNULL((SELECT SUM(SZ8.Z8_VALOR) FROM %Table:SZ8%  SZ8 WHERE SZ8.Z8_FILIAL = DTY.DTY_FILORI AND SZ8.Z8_CONTRAT = DTY.DTY_NUMCTC AND SZ8.Z8_CODFORM = '001' AND SZ8.Z8_DOC = DT6.DT6_DOC AND SZ8.Z8_SERIE = DT6.DT6_SERIE AND  SZ8.D_E_L_E_T_ = ''),0) AS RATPRODUCA
		,ISNULL((SELECT SUM(SZ8.Z8_VALOR) FROM %Table:SZ8%  SZ8 WHERE SZ8.Z8_FILIAL = DTY.DTY_FILORI AND SZ8.Z8_CONTRAT = DTY.DTY_NUMCTC AND SZ8.Z8_CODFORM = '002' AND SZ8.Z8_DOC = DT6.DT6_DOC AND SZ8.Z8_SERIE = DT6.DT6_SERIE AND  SZ8.D_E_L_E_T_ = ''),0) AS RATDESCARG
		,ISNULL((SELECT SUM(SZ8.Z8_VALOR) FROM %Table:SZ8%  SZ8 WHERE SZ8.Z8_FILIAL = DTY.DTY_FILORI AND SZ8.Z8_CONTRAT = DTY.DTY_NUMCTC AND SZ8.Z8_CODFORM = '003' AND SZ8.Z8_DOC = DT6.DT6_DOC AND SZ8.Z8_SERIE = DT6.DT6_SERIE AND  SZ8.D_E_L_E_T_ = ''),0) AS RATPEDAGIO
		,ISNULL((SELECT SUM(SZ8.Z8_VALOR) FROM %Table:SZ8%  SZ8 WHERE SZ8.Z8_FILIAL = DTY.DTY_FILORI AND SZ8.Z8_CONTRAT = DTY.DTY_NUMCTC AND SZ8.Z8_CODFORM = '501' AND SZ8.Z8_DOC = DT6.DT6_DOC AND SZ8.Z8_SERIE = DT6.DT6_SERIE AND  SZ8.D_E_L_E_T_ = ''),0) AS RATICMFRET
		,ISNULL((SELECT SUM(SZ8.Z8_VALOR) FROM %Table:SZ8%  SZ8 WHERE SZ8.Z8_FILIAL = DTY.DTY_FILORI AND SZ8.Z8_CONTRAT = DTY.DTY_NUMCTC AND SZ8.Z8_CODFORM = '502' AND SZ8.Z8_DOC = DT6.DT6_DOC AND SZ8.Z8_SERIE = DT6.DT6_SERIE AND  SZ8.D_E_L_E_T_ = ''),0) AS RATTAXAADM
		,ISNULL((SELECT SUM(SZ8.Z8_VALOR) FROM %Table:SZ8%  SZ8 WHERE SZ8.Z8_FILIAL = DTY.DTY_FILORI AND SZ8.Z8_CONTRAT = DTY.DTY_NUMCTC AND SZ8.Z8_CODFORM NOT IN('001','002','003') AND SZ8.Z8_CODFORM < 500 AND SZ8.Z8_DOC = DT6.DT6_DOC AND SZ8.Z8_SERIE = DT6.DT6_SERIE AND  SZ8.D_E_L_E_T_ = ''),0) AS 'RATACRES'
		,ISNULL((SELECT SUM(SZ8.Z8_VALOR) FROM %Table:SZ8%  SZ8 WHERE SZ8.Z8_FILIAL = DTY.DTY_FILORI AND SZ8.Z8_CONTRAT = DTY.DTY_NUMCTC AND SZ8.Z8_CODFORM NOT IN('502','501') AND SZ8.Z8_CODFORM >= 500 AND SZ8.Z8_DOC = DT6.DT6_DOC AND SZ8.Z8_SERIE = DT6.DT6_SERIE AND  SZ8.D_E_L_E_T_ = ''),0)      AS 'RATDEDUC'
		
		,(DT6.DT6_VALFRE / DTY.DTY_YFRETE ) * DTY.DTY_INSS   AS RATINSS
		,(DT6.DT6_VALFRE / DTY.DTY_YFRETE ) * DTY.DTY_SEST   AS RATSEST
		,(DT6.DT6_VALFRE / DTY.DTY_YFRETE ) * DTY.DTY_IRRF   AS RATIRRF
		,(DT6.DT6_VALFRE / DTY.DTY_YFRETE ) * DTY.DTY_PIS    AS RATPIS
		,(DT6.DT6_VALFRE / DTY.DTY_YFRETE ) * DTY.DTY_CSLL   AS RATCSLL
		,(DT6.DT6_VALFRE / DTY.DTY_YFRETE ) * DTY.DTY_COFINS AS RATCOFINS
		
		,(DT6.DT6_VALFRE / DTY.DTY_YFRETE ) * ISNULL((SELECT SUM(E2_VALOR)  FROM %Table:SE2% SE2 
											WHERE E2_NUM = DTY.DTY_NUMCTC
											AND E2_FILIAL = DTY.DTY_FILORI
											AND E2_YTABORI ='SZ2'
											AND D_E_L_E_T_ =''),0) AS RATCMV
		
		,(DT6.DT6_PESCOB / DTY.DTY_PESO ) * ISNULL((SELECT SUM(E2_VALOR)  FROM %Table:SE2% SE2 
											WHERE E2_NUM = DTY.DTY_NUMCTC
											AND E2_FILIAL = DTY.DTY_FILORI
											AND E2_FORNECE = DTY.DTY_CODFOR
											AND E2_LOJA = DTY.DTY_LOJFOR
											AND E2_TIPO ='RC'
											AND D_E_L_E_T_ =''),0)  AS RATVLRLIQ
		
		FROM %Table:DTY% DTY 
		
		JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %Exp:xFilial("SA2")%
		AND SA2.A2_COD = DTY.DTY_CODFOR
		AND SA2.A2_LOJA = DTY.DTY_LOJFOR
		AND SA2.D_E_L_E_T_ =''
		
		JOIN %Table:DTQ% DTQ ON DTQ.DTQ_FILIAL = %Exp:xFilial("DTQ")%
		AND DTQ.DTQ_FILORI = DTY.DTY_FILORI
		AND DTQ.DTQ_VIAGEM = DTY.DTY_VIAGEM
		AND DTQ.D_E_L_E_T_ =''
		
		JOIN %Table:DTA% DTA ON DTA.DTA_FILORI = DTY.DTY_FILORI
		AND DTA.DTA_FILIAL = %Exp:xFilial("DTA")%
		AND DTA.DTA_VIAGEM = DTY.DTY_VIAGEM
		AND DTA.D_E_L_E_T_ =''
		
		JOIN %Table:DT6% DT6 ON DT6.DT6_FILIAL = %Exp:xFilial("DT6")%
		AND DT6.DT6_FILORI = DTA.DTA_FILORI
		AND DT6.DT6_DOC = DTA.DTA_DOC
		AND DT6.DT6_SERIE = DTA.DTA_SERIE
		AND DT6.D_E_L_E_T_ =''
		
		JOIN %Table:SF2% SF2 ON SF2.F2_FILIAL = DTY.DTY_FILORI
		AND SF2.F2_DOC = DTA.DTA_DOC
		AND SF2.F2_SERIE = DTA.DTA_SERIE
		AND SF2.D_E_L_E_T_ =''

		JOIN %Table:SD2% SD2 ON SD2.D2_FILIAL  = SF2.F2_FILIAL
		AND SD2.D2_DOC = SF2.F2_DOC
		AND SD2.D2_SERIE = SF2.F2_SERIE
		AND SD2.D_E_L_E_T_ =''

		JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %Exp:xFilial("SA1")%
		AND SA1.A1_COD = SF2.F2_CLIENTE
		AND SA1.A1_LOJA = SF2.F2_LOJA
		AND SA1.D_E_L_E_T_ =''
		
		WHERE DTY.D_E_L_E_T_='' )A
	
	EndSQL
	
	// Recupera os campos da query
	aFileds := (cAlias)->(DBStruct())
	
	For nY:= 1 to Len(aFileds) 
		// Crio com array com os campos da tabela
		aAdd(aCpoData, {Alltrim(aFileds[nY][1]), aFileds[nY][2] , aFileds[nY][3] ,  aFileds[nY][4]})
		
		cFields += Alltrim(aFileds[nY][1]) + ','
	Next
	
	// Remove a ultima virgula
	cFields := Left(cFields, Len(cFields) -1)
	
	// Cria o objeto
	oTable  := FwTemporaryTable():New(cAliaTemp)
	
	// Adiciono os campos na tabela
	oTable:SetFields(aCpoData)
	
	// Adiciono os índices da tabela
	//oTable:AddIndex('01', {'F2_FILIAL','DTY_NUMCTC','DTQ_VIAGEM'})
	
	// Crio a tabela no banco de dados
	oTable:Create()
	
	// Recupera o nome real 
	cAliasBD := oTable:GetRealName()
	
	// Popula a tabela temporaria
	cQuery := "INSERT INTO " + cAliasBD
	cQuery += " (" + cFields + ") "
	cQuery += GetLastquery()[2]
	
	// Executo o comando SQL
	If(TcSqlExec(cQuery) < 0 .and. !Empty(TcSqlError()))
		MsgAlert('Ocorreu um erro ao executar o comando SQL!' + CRLF + CRLF + TcSqlError(), 'Erro ao popular tabela')
		lRet := .f.
		cErro := ""
    Endif
    
    (cAlias)->(DbCloseArea())
	
Return lRet