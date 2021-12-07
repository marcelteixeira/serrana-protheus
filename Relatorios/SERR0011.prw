#include 'totvs.ch'

#DEFINE CRLF CHR(13) + CHR(10)

Static lIsIssBx   := FindFunction("IsIssBx")
Static cTMPSE5198 := "TMPSE5198"
Static cTMPSED198 := "TMPSED198"
Static lExistFKD


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SERR0011
Relação de baixas por natureza

@author Maycon Anholete Bianchine
@since 22/03/2021
@version 12
/*/
//------------------------------------------------------------------------------------------
User Function SERR0011()

	Local oReport
	Local lNatSint  := SuperGetMV( 'MV_NATSINT', .F., '2' ) == '1'
	Local cHelpNat  := "Indica utilização de estrutura de natureza Sintética/Analitica no cadastro de Naturezas (Financeiro). Opções: 1 = Sim ou 2 = Não (padrão) " + CRLF + ;
		"Localize o parâmetro MV_NATSINT e altere o mesmo para 1 (SIM)"

	Private cAliasNat 	:= GetNextAlias()
	Private cAliasReg 	:= GetNextAlias()
	Private cAliasRAgr	:= GetNextAlias()

	If !lNatSint
		Help(,,'MV_NATSINT',,cHelpNat,1,0)
	EndIf

	If Pergunte("FIN198", .T.)
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Definição da estrutura do relatório
	Primeira sessão - Dados dos títulos
	Segunda sessão - Totalizador pelas sintéticas

@return oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef()

	Local nX		:= 0
	Local nPosFim	:= 0
	Local nTam		:= 0
	Local oSecTit
	Local oSecTot
	Local oReport
	Local oSecNat
	Local oSecRegime
	Local oSecRegAgr
	//GESTAO - inicio
	Local oSecFil	:= Nil
	//GESTAO - fim
	Local lAgrFil
	Local oBreak
	Local oBreakSpace
	Local oBreakNv

	If lExistFKD == Nil
		lExistFKD := TableInDic('FKD')
	Endif

	oReport:= TReport():New("SERR0011","Relação de Baixas por Natureza","",{|oReport| ReportPrint(oReport)},"Relação de Baixas por Natureza") //"Relação de Baixas por Natureza"
	oReport:SetLandscape(.T.)

	//GESTAO - inicio
	oReport:SetUseGC(.F.)
	//GESTAO - fim

	dbSelectArea("SE2")

	oSecTit := TRSection():New(oReport,"Movimentos" /*"Movimentos"*/)

	TRCell():New(oSecTit,"PREFIXO"	,,"Prf" /*"Prf"	*/				,PesqPict("SE5","E5_PREFIXO")	,TamSX3("E5_PREFIXO")[1],.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"NUMERO"	,,"Numero" /*"Numero"*/			,PesqPict("SE5","E5_NUM")		,TamSX3("E5_NUMERO")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"PARCELA"	,,"Prc" /*"Prc"*/				,PesqPict("SE5","E5_PARCELA")	,TamSX3("E5_PARCELA")[1],.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"TIPO"		,,"Tp" /*"Tp"	*/				,PesqPict("SE5","E5_TIPO")		,TamSX3("E5_TIPO")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"CLIFOR"	,,"Cli/For" /*"Cli/For"*/		,PesqPict("SE5","E5_CLIFOR")	,TamSX3("E5_FORNECE")[1],.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"LOJA"		,,"Lj" /*"Lj"*/					,PesqPict("SE5","E5_LOJA")		,TamSX3("E5_LOJA")[1]	,.F.,,,,,,,.F.)

	TRCell():New(oSecTit,"NOME"		,,"Nome" /*"Nome"*/				,PesqPict("SE2","E2_NOMFOR")	,15						,.F.,,,.T.,,,,.F.)
	TRCell():New(oSecTit,"VENCTO"	,,"Vencto" /*"Vencto"*/			,PesqPict("SE5","E5_VENCTO")	,10						,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"DTDIGIT"	,,"Dt.Emissao" /*"Dt.Emissao"*/	,PesqPict("SE5","E5_DTDIGIT")	,10						,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"BAIXA"	,,"Baixa" /*"Baixa"*/			,PesqPict("SE5","E5_DATA")		,10						,.F.,,,,,,,.F.)

	TRCell():New(oSecTit,"HIST"		,,"Historico" /*"Historico"*/			,PesqPict("SE5","E5_HIST")		,25						,.F.,,,.T.,,,,.F.)
	TRCell():New(oSecTit,"VALORIG"	,,"Valor Orig" /*"Valor Orig"*/			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"JURMUL"	,,"Juros/Multa" /*"Juros/Multa"*/		,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	If lExistFKD
		TRCell():New(oSecTit,"VALACESS"	,,"Valores Acessorios" /*"Valores Acessorios"*/	,PesqPict("SE5","E5_VALOR")	,TamSX3("FKD_VLCALC")[1],.F.,,,,,,,.F.)
	EndIf
	TRCell():New(oSecTit,"VALCORR"	,,"Correção" /*"Correção"*/				,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"DESCONT"	,,"Desconto" /*"Desconto"*/				,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"ABATIM"	,,"Abatimento" /*"Abatimento"*/			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"IMPOSTO"	,,"Imposto" /*"Imposto"*/				,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"BAIXADO"	,,"Total Baixado" /*"Total Baixado"*/	,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTit,"BANCO"	,,"Bco" /*"Bco"	*/						,PesqPict("SE5","E5_BANCO")		,TamSX3("E5_BANCO")[1]	,.F.,,,,,,,.F.)

	oSecTit:SetTotalInLine(.F.)
	oSecTit:SetHeaderPage(.T.)

	oSecTit:Cell("VALORIG"):SetAlign("RIGHT")
	oSecTit:Cell("JURMUL"):SetAlign("RIGHT")
	If lExistFKD
		oSecTit:Cell("VALACESS"):SetAlign("RIGHT")
	EndIf
	oSecTit:Cell("VALCORR"):SetAlign("RIGHT")
	oSecTit:Cell("DESCONT"):SetAlign("RIGHT")
	oSecTit:Cell("ABATIM"):SetAlign("RIGHT")
	oSecTit:Cell("IMPOSTO"):SetAlign("RIGHT")
	oSecTit:Cell("BAIXADO"):SetAlign("RIGHT")

	oSecTit:Cell("VALORIG"):SetHeaderAlign("RIGHT")
	oSecTit:Cell("JURMUL"):SetHeaderAlign("RIGHT")
	If lExistFKD
		oSecTit:Cell("VALACESS"):SetHeaderAlign("RIGHT")
	EndIf
	oSecTit:Cell("VALCORR"):SetHeaderAlign("RIGHT")
	oSecTit:Cell("DESCONT"):SetHeaderAlign("RIGHT")
	oSecTit:Cell("ABATIM"):SetHeaderAlign("RIGHT")
	oSecTit:Cell("IMPOSTO"):SetHeaderAlign("RIGHT")
	oSecTit:Cell("BAIXADO"):SetHeaderAlign("RIGHT")

	oSecTit:Cell("VALORIG"):SetNegative("PARENTHESES")
	oSecTit:Cell("JURMUL"):SetNegative("PARENTHESES")
	If lExistFKD
		oSecTit:Cell("VALACESS"):SetNegative("PARENTHESES")
	EndIf
	oSecTit:Cell("VALCORR"):SetNegative("PARENTHESES")
	oSecTit:Cell("DESCONT"):SetNegative("PARENTHESES")
	oSecTit:Cell("ABATIM"):SetNegative("PARENTHESES")
	oSecTit:Cell("IMPOSTO"):SetNegative("PARENTHESES")
	oSecTit:Cell("BAIXADO"):SetNegative("PARENTHESES")

	//Configura os totalizadores por natureza sintética
	oSecTot := TRSection():New(oReport,"Totais" /*Totais*/,,,,,,,,,,,,,,.F.)

	//Processa as colunas
	nPosFim := aScan(oSecTit:aCell,{|x| x:cName == "HIST"})

	For nX := 1 to nPosFim
		nTam += oSecTit:Cell(oSecTit:aCell[nX]:cName):GetSize()
		nTam += oReport:nColSpace
	Next nX
	nTam -= oReport:nColSpace

	TRCell():New(oSecTot,"TITULO"		,,"",							, nTam					,.F.,,,,,,,.F.)
	TRCell():New(oSecTot,"VALORIG"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTot,"JURMUL"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	If lExistFKD
		TRCell():New(oSecTot,"VALACESS"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	EndIf
	TRCell():New(oSecTot,"VALCORR"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTot,"DESCONT"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTot,"ABATIM"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTot,"IMPOSTO"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
	TRCell():New(oSecTot,"BAIXADO"		,,"",PesqPict("SE5","E5_VALOR")	, TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)

	oSecTot:SetTotalInLine(.F.)
	oSecTot:SetHeaderPage(.F.)

	oSecTot:Cell("VALORIG"):SetAlign("RIGHT")
	oSecTot:Cell("JURMUL"):SetAlign("RIGHT")
	oSecTot:Cell("VALCORR"):SetAlign("RIGHT")
	oSecTot:Cell("DESCONT"):SetAlign("RIGHT")
	oSecTot:Cell("ABATIM"):SetAlign("RIGHT")
	oSecTot:Cell("IMPOSTO"):SetAlign("RIGHT")
	oSecTot:Cell("BAIXADO"):SetAlign("RIGHT")

	oSecTot:Cell("VALORIG"):SetHeaderAlign("RIGHT")
	oSecTot:Cell("JURMUL"):SetHeaderAlign("RIGHT")
	oSecTot:Cell("VALCORR"):SetHeaderAlign("RIGHT")
	oSecTot:Cell("DESCONT"):SetHeaderAlign("RIGHT")
	oSecTot:Cell("ABATIM"):SetHeaderAlign("RIGHT")
	oSecTot:Cell("IMPOSTO"):SetHeaderAlign("RIGHT")
	oSecTot:Cell("BAIXADO"):SetHeaderAlign("RIGHT")

	oSecTot:Cell("VALORIG"):SetNegative("PARENTHESES")
	oSecTot:Cell("JURMUL"):SetNegative("PARENTHESES")
	oSecTot:Cell("VALCORR"):SetNegative("PARENTHESES")
	oSecTot:Cell("DESCONT"):SetNegative("PARENTHESES")
	oSecTot:Cell("ABATIM"):SetNegative("PARENTHESES")
	oSecTot:Cell("IMPOSTO"):SetNegative("PARENTHESES")
	oSecTot:Cell("BAIXADO"):SetNegative("PARENTHESES")

	If lExistFKD
		oSecTot:Cell("VALACESS"):SetAlign("RIGHT")
		oSecTot:Cell("VALACESS"):SetHeaderAlign("RIGHT")
		oSecTot:Cell("VALACESS"):SetNegative("PARENTHESES")
	EndIf

	//GESTAO - inicio
	//Relacao das filiais selecionadas para compor o relatorio
	oSecFil := TRSection():New(oReport,"SECFIL",{"SE1","SED"})
	TRCell():New(oSecFil,"CODFIL",,"Código",/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)		//"Código"
	TRCell():New(oSecFil,"EMPRESA",,"Empresa",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	//"Empresa"
	TRCell():New(oSecFil,"UNIDNEG",,"Unidade de negócio",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	//"Unidade de negócio"
	TRCell():New(oSecFil,"NOMEFIL",,"Filial",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	//"Filial"
	//GESTAO - fim

	//SERRANA - INICIO
	//Totalizadores por natureza mod 2 - serrana
	//Relacao das filiais selecionadas para compor o relatorio Regime de Caixa - Regime de Caixa - Relação de Agrupamente de Contas - Serrana
	//If MV_PAR38 == 1 .or. MV_PAR38 == 5
		lAgrFil := IIF(MV_PAR37 == 1,.T.,.F.)
		oSecNat := TRSection():New(oReport,"Regime de Caixa - Relação de Agrupamente de Contas - Serrana",{"SE5","SED","ZZD"})
		If !lAgrFil
			TRCell():New(oSecNat, "E5_FILIAL"	,cAliasNat,"Filial"		    ,PesqPict("SE5","E5_FILIAL")	,TamSX3("E5_FILIAL")[1]	    ,.F.,,,,,,,.F.)
		EndIf
		TRCell():New(oSecNat, "ZZD_NIVEL"	,cAliasNat,"Nivel"				,PesqPict("ZZD","ZZD_NIVEL")	,TamSX3("ZZD_NIVEL")[1]		,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "ZZD_DESCRI"	,cAliasNat,"Tipagem de Conta"	,PesqPict("ZZD","ZZD_DESCRI")	,50							,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_NATUREZ"	,cAliasNat,"Natureza"			,PesqPict("SE5","E5_NATUREZ")	,TamSX3("E5_NATUREZ")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "ED_DESCRIC"	,cAliasNat,"Descricao"			,PesqPict("SE5","ED_DESCRIC")	,TamSX3("ED_DESCRIC")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_VALORIG"	,cAliasNat,"Valor Orig."		,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "nBXBruta"	,cAliasNat,"BX Bruta"	    	,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_VLJUROS"	,cAliasNat,"Juros" 		    	,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_VLMULTA"	,cAliasNat,"Multa" 		    	,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_VLCORRE"	,cAliasNat,"Ocorren" 			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_VLDESCO"	,cAliasNat,"Desconto" 			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_ABATIM"	,cAliasNat,"Abatimento" 		,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_IMPOSTO"	,cAliasNat,"Imposto" 			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecNat, "E5_VALOR"	,cAliasNat,"Valor Baixado" 		,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	    ,.F.,,,,,,,.F.)

		oSecNat:Cell("E5_VALORIG"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("nBXBruta"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("E5_VLJUROS"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("E5_VLMULTA"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("E5_VLCORRE"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("E5_VLDESCO"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("E5_ABATIM"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("E5_IMPOSTO"):SetHeaderAlign("RIGHT")
		oSecNat:Cell("E5_VALOR"):SetHeaderAlign("RIGHT")

		//TRBreak():New(oParent,uBreak,uTitle,lTotalInLine,cName,lPageBreak)
		oBreak := TRBreak():New(oSecNat,oSecNat:Cell("ZZD_DESCRI"),"Valor Total Tipagem de Conta (Regime de Caixa)",.F.)
		TRFunction():New(oSecNat:Cell("E5_VALORIG")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("nBXBruta")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLJUROS")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLMULTA")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLCORRE")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLDESCO")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_ABATIM")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_IMPOSTO")	,,"SUM",oBreak,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VALOR")	,,"SUM",oBreak,"",,,.F.,.F.,)

		//TRBreak():New(oParent,uBreak,uTitle,lTotalInLine,cName,lPageBreak)
		oBreakNv := TRBreak():New(oSecNat,oSecNat:Cell("ZZD_NIVEL"),"Valor Total Nivel (Regime de Caixa)",.F.)
		TRFunction():New(oSecNat:Cell("E5_VALORIG")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("nBXBruta")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLJUROS")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLMULTA")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLCORRE")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VLDESCO")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_ABATIM")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_IMPOSTO")	,,"SUM",oBreakNv,"",,,.F.,.F.,)
		TRFunction():New(oSecNat:Cell("E5_VALOR")	,,"SUM",oBreakNv,"",,,.F.,.F.,)

		oBreakSpace := TRBreak():New(oSecNat,oSecNat:Cell("ZZD_DESCRI"),,.F.)

		//lEndSection	Lógico	Se verdadeiro, indica se o totalizador será impresso na quebra de seção
		//lEndReport	Lógico	Se verdadeiro, indica se o totalizador será impresso no final do relatório
		//lEndPage	Lógico	Se verdadeiro, indica se o totalizador será impresso no final de cada página
		//TRFunction():New(                    oCell,,     ,          ,                       ,,,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint)
		TRFunction():New(oSecNat:Cell("E5_VALORIG")	,,"SUM",/*oBreak*/,"Total Valor Orig.....",,,.T.,.F.,.F.)//,,,.F.,.T.,.F.)
		TRFunction():New(oSecNat:Cell("nBXBruta")	,,"SUM",/*oBreak*/,"Total Baixa Bruta....",,,.T.,.F.,.F.)//,,,.F.,.T.,.F.)
		TRFunction():New(oSecNat:Cell("E5_VLJUROS")	,,"SUM",/*oBreak*/,"Total Juros..........",,,.T.,.F.,.F.)
		TRFunction():New(oSecNat:Cell("E5_VLMULTA")	,,"SUM",/*oBreak*/,"Total Multa..........",,,.T.,.F.,.F.)
		TRFunction():New(oSecNat:Cell("E5_VLCORRE")	,,"SUM",/*oBreak*/,"Total Ocorren........",,,.T.,.F.,.F.)
		TRFunction():New(oSecNat:Cell("E5_VLDESCO")	,,"SUM",/*oBreak*/,"Total Desconto.......",,,.T.,.F.,.F.)
		TRFunction():New(oSecNat:Cell("E5_ABATIM")	,,"SUM",/*oBreak*/,"Total Abatimento.....",,,.T.,.F.,.F.)
		TRFunction():New(oSecNat:Cell("E5_IMPOSTO")	,,"SUM",/*oBreak*/,"Total Imposto........",,,.T.,.F.,.F.)
		TRFunction():New(oSecNat:Cell("E5_VALOR")	,,"SUM",/*oBreak*/,"Total Valor Baixado..",,,.T.,.F.,.F.)

		//oSecNat:SetTotalInLine(.F.)
		//oSecNat:SetHeaderPage(.F.)
		//SERRANA - FIM
	//EndIf

	//===========================================================================
	//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
	//===========================================================================
	//If MV_PAR38 == 2	.or. MV_PAR38 == 5
		lAgrFil := IIF(MV_PAR37 == 1,.T.,.F.)
		oSecRegime := TRSection():New(oReport,"Regime de Competência e Econômico - Serrana",{"SE1","SED","ZZD"})

		//TITULOS DO REGIME
		TRCell():New(oSecRegime, "PREFIXO"		,cAliasReg,"Prefixo"		,PesqPict("SE1","E1_PREFIXO")	,TamSX3("E1_PREFIXO")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "NUM"			,cAliasReg,"Numero"			,PesqPict("SE1","E1_NUM")		,TamSX3("E1_NUM")[1]		,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "NATUREZ"		,cAliasReg,"Natureza"		,PesqPict("SE1","E1_NATUREZ")	,TamSX3("E1_NATUREZ")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "PARCELA"		,cAliasReg,"Prc"			,PesqPict("SE1","E1_PARCELA")	,TamSX3("E1_PARCELA")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "TIPO"			,cAliasReg,"Tipo"			,PesqPict("SE1","E1_TIPO")		,TamSX3("E1_TIPO")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "CLIFOR"		,cAliasReg,"Cli/For" 		,PesqPict("SE1","E1_CLIENTE")	,TamSX3("E1_CLIENTE")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "LOJA"			,cAliasReg,"Loja" 		    ,PesqPict("SE1","E1_LOJA")		,TamSX3("E1_LOJA")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "NOME"			,cAliasReg,"Nome" 			,PesqPict("SE1","E1_NOMCLI")	,TamSX3("E1_NOMCLI")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "VENCREA"		,cAliasReg,"Vencimento" 	,PesqPict("SE1","E1_VENCREA")	,25							,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "EMISSAO"		,cAliasReg,"Emissão" 		,PesqPict("SE1","E1_EMISSAO")	,25							,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "BAIXA"		,cAliasReg,"Baixa" 			,PesqPict("SE1","E1_BAIXA")		,25	   				 		,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "HIST"			,cAliasReg,"Histórico" 		,PesqPict("SE1","E1_HIST")		,50	    					,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "VAL_ORIG"		,cAliasReg,"Valor Original" ,PesqPict("SE1","E1_VALOR")		,TamSX3("E1_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecRegime, "VAL_SALDO"	,cAliasReg,"Valor Saldo" 	,PesqPict("SE1","E1_SALDO")		,TamSX3("E1_SALDO")[1]	    ,.F.,,,,,,,.F.)

		oSecRegime:Cell("VAL_ORIG"):SetHeaderAlign("RIGHT")
		oSecRegime:Cell("VAL_SALDO"):SetHeaderAlign("RIGHT")

		TRFunction():New(oSecRegime:Cell("VAL_ORIG")	,,"SUM",/*oBreak*/,"Total Valor Original.....",,,.T.,.F.,.F.)
		TRFunction():New(oSecRegime:Cell("VAL_SALDO")	,,"SUM",/*oBreak*/,"Total Valor Saldo........",,,.T.,.F.,.F.)
	//ENDIF

	//AMOSTRAGEM PELO NIVEL E AGRUPAMENTO POR NATUREZA
	//If MV_PAR38 == 3 .or. MV_PAR38 == 5
		oSecRegAgr := TRSection():New(oReport,"Regime de Competência e Econômico - Agrupamento de Contas - Serrana",{"SE1","SED","ZZD"})
		If !lAgrFil
			TRCell():New(oSecRegAgr, "FILIAL"			,cAliasNat,"Filial"		    ,PesqPict("SE1","E1_FILIAL")	,TamSX3("E1_FILIAL")[1]	    ,.F.,,,,,,,.F.)
		EndIf
		TRCell():New(oSecRegAgr, "ZZD_NIVEL"		,cAliasRAgr,"Nivel"				,PesqPict("ZZD","ZZD_NIVEL")	,TamSX3("E1_PREFIXO")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecRegAgr, "ZZD_DESCRI"		,cAliasRAgr,"Tipagem de Conta"	,PesqPict("ZZD","ZZD_DESCRI")	,50							,.F.,,,,,,,.F.)
		TRCell():New(oSecRegAgr, "NATUREZ"			,cAliasRAgr,"Natureza"			,PesqPict("SE1","E1_NATUREZ")	,TamSX3("E1_NATUREZ")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecRegAgr, "ED_DESCRIC"		,cAliasRAgr,"Descricao"			,PesqPict("SED","ED_DESCRIC")	,TamSX3("ED_DESCRIC")[1]	,.F.,,,,,,,.F.)
		TRCell():New(oSecRegAgr, "VAL_ORIG"			,cAliasRAgr,"Valor Original" 	,PesqPict("SE1","E1_VALOR")		,TamSX3("E1_VALOR")[1]	    ,.F.,,,,,,,.F.)
		TRCell():New(oSecRegAgr, "VAL_SALDO"		,cAliasRAgr,"Valor Saldo" 		,PesqPict("SE1","E1_SALDO")		,TamSX3("E1_SALDO")[1]	    ,.F.,,,,,,,.F.)

		oSecRegAgr:Cell("VAL_ORIG"):SetHeaderAlign("RIGHT")
		oSecRegAgr:Cell("VAL_SALDO"):SetHeaderAlign("RIGHT")

		oBreak2 := TRBreak():New(oSecRegAgr,oSecRegAgr:Cell("ZZD_DESCRI"),"Valor Total Tipagem de Conta (Regime de Competência e Econômico - Serrana)",.F.)
		TRFunction():New(oSecRegAgr:Cell("VAL_ORIG")	,,"SUM",oBreak2,"",,,.F.,.F.,)
		TRFunction():New(oSecRegAgr:Cell("VAL_SALDO")	,,"SUM",oBreak2,"",,,.F.,.F.,)

		oBreakNv2 := TRBreak():New(oSecRegAgr,oSecRegAgr:Cell("ZZD_NIVEL"),"Valor Total Nivel (Regime de Competência e Econômico - Serrana)",.F.)
		TRFunction():New(oSecRegAgr:Cell("VAL_ORIG")	,,"SUM",oBreakNv2,"",,,.F.,.F.,)
		TRFunction():New(oSecRegAgr:Cell("VAL_SALDO")	,,"SUM",oBreakNv2,"",,,.F.,.F.,)

		TRFunction():New(oSecRegAgr:Cell("VAL_ORIG")	,,"SUM",/*oBreak*/,"(Regime de Competência e Econômico - Serrana) Total Valor Original.....",,,.T.,.F.,.F.)
		TRFunction():New(oSecRegAgr:Cell("VAL_SALDO")	,,"SUM",/*oBreak*/,"(Regime de Competência e Econômico - Serrana) Total Valor Saldo........",,,.T.,.F.,.F.)
	//EndIf
	//===========================================================================
	//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
	//===========================================================================

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressão do relatório

@param oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local bVlOrig		:= Nil
	Local bVlBxd		:= Nil
	Local cNatPai		:= ""
	Local cNatureza		:= ""
	Local cDescricao	:= ""
	Local oSecTit		:= oReport:Section(1)
	Local oSecTot		:= oReport:Section(2)
	Local oSecNat		:= oReport:Section(4)
	Local oSecRegime	:= oReport:Section(5)
	Local oSecRegAgr	:= oReport:Section(6)
	Local aSelFil		:= {}
	Local aSM0			:= {}
	Local nTamEmp		:= 0
	Local nTamUnNeg		:= 0
	Local nTamTit		:= 0
	Local nX			:= 0
	Local cFiLSel		:= ""
	Local cTitulo		:= ""
	Local oSecFil		:= oReport:Section("SECFIL")
	Local lGestao		:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
	Local lSE5Access	:= IIf( lGestao, FWModeAccess("SE5",1) == "E", FWModeAccess("SE5",3) == "E")
	Local cCodNat		:= ""
	Local cDscNat       := ""
	Local nSelFil       := 0
	Local lAgrFil

	PRIVATE  aTotais	:= {}
	PRIVATE  aTotSint	:= {}
	PRIVATE  nBXBruta   := 0
	If lExistFKD == Nil
		lExistFKD := TableInDic('FKD')
	Endif

	//Força preenchimento dos parametros mv_parXX
	Pergunte("FIN198", .F.)

	If MV_PAR19 == 1
		oSectit:Cell("NOME"):SetObfuscate( RetGlbLGPD('E1_NOMCLI') )
	else
		oSectit:Cell("NOME"):SetObfuscate( RetGlbLGPD('E2_NOMFOR') )
	Endif

	If MV_PAR36 == 1 .And. lSE5Access
		If lGestao .And. FindFunction("FwSelectGC")
			aSelFil := FwSelectGC()
		Else
			aSelFil := AdmGetFil(.F.,.F.,"SE5")
		EndIf
	EndIf

	If (nSelFil := Len(aSelFil)) == 0
		Aadd(aSelFil, cFilAnt)
		nSelFil := 1
	EndIf

	If !LockByName("FINR198SE5",.T.,.F.)
		cTMPSE5198 := GetNextAlias()
	EndIf

	If !LockByName("FINR198SED",.T.,.F.)
		cTMPSED198 := GetNextAlias()
	EndIf

	//Alimenta o arquivo temporário
	FGerTrb(@aSelFil)

	//Totaliza por natureza
	FTotNat()

	//imprime a lista de filiais selecionadas para o relatorio
	If nSelFil > 1 .And. !((cTMPSE5198)->(Eof()))
		oSecTit:SetHeaderSection(.F.)
		aSM0 := FWLoadSM0()
		nTamEmp := Len(FWSM0LayOut(,1))
		nTamUnNeg := Len(FWSM0LayOut(,2))
		cTitulo := oReport:Title()

		oReport:SetTitle(cTitulo + " (" + "Filiais selecionadas para o relatorio" + ")") //"Filiais selecionadas para o relatorio"
		nTamTit := Len(oReport:Title())
		oSecFil:Init()
		oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
		oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
		oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
		oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})

		For nX := 1 To nSelFil
			nLinha := Ascan(aSM0, {|sm0|, sm0[SM0_CODFIL] == aSelFil[nX]})

			If nLinha > 0
				cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
				cFilSel += " "
				cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
				cFilSel += " "
				cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
				oSecFil:PrintLine()
			EndIf
		Next nX

		oReport:SetTitle(cTitulo)
		oSecFil:Finish()
		oSecTit:SetHeaderSection(.T.)
		oReport:EndPage()
	EndIf

	//Impressão dos dados
	If MV_PAR38 == 1 .or. MV_PAR38 == 5	
		dbSelectArea(cTMPSE5198)
		(cTMPSE5198)->(dbSetOrder(1))
		(cTMPSE5198)->(dbGoTop())

		//Seta os valores nas colunas
		oSecTit:Cell("PREFIXO"):SetBlock({|| (cTMPSE5198)->E5_PREFIXO })
		oSecTit:Cell("NUMERO"):SetBlock({|| (cTMPSE5198)->E5_NUMERO })
		oSecTit:Cell("PARCELA"):SetBlock({|| (cTMPSE5198)->E5_PARCELA })
		oSecTit:Cell("TIPO"):SetBlock({|| (cTMPSE5198)->E5_TIPO })
		oSecTit:Cell("CLIFOR"):SetBlock({|| (cTMPSE5198)->E5_CLIFOR })
		oSecTit:Cell("LOJA"):SetBlock({|| (cTMPSE5198)->E5_LOJA })
		oSecTit:Cell("NOME"):SetBlock({|| (cTMPSE5198)->E5_NOME })
		oSecTit:Cell("VENCTO"):SetBlock({|| (cTMPSE5198)->E5_VENCTO })
		oSecTit:Cell("DTDIGIT"):SetBlock({|| (cTMPSE5198)->E5_DTDIGIT })
		oSecTit:Cell("BAIXA"):SetBlock({|| (cTMPSE5198)->E5_DATA })
		oSecTit:Cell("HIST"):SetBlock({|| (cTMPSE5198)->E5_HISTOR })
		oSecTit:Cell("VALORIG"):SetBlock({|| (cTMPSE5198)->E5_VALORIG })
		oSecTit:Cell("JURMUL"):SetBlock({|| (cTMPSE5198)->E5_VLJUROS+(cTMPSE5198)->E5_VLMULTA })

		If lExistFKD
			oSecTit:Cell("VALACESS"):SetBlock({|| (cTMPSE5198)->VALACESS })
		EndIf

		oSecTit:Cell("VALCORR"):SetBlock({|| (cTMPSE5198)->E5_VLCORRE })
		oSecTit:Cell("DESCONT"):SetBlock({|| (cTMPSE5198)->E5_VLDESCO })
		oSecTit:Cell("ABATIM"):SetBlock({|| (cTMPSE5198)->E5_ABATIM })
		oSecTit:Cell("IMPOSTO"):SetBlock({|| (cTMPSE5198)->E5_IMPOSTO })
		oSecTit:Cell("BAIXADO"):SetBlock({|| (cTMPSE5198)->E5_VALOR })
		oSecTit:Cell("BANCO"):SetBlock({|| (cTMPSE5198)->E5_BANCO })
		oSecTot:Cell("VALORIG"):SetBlock({|| (cTMPSED198)->VALORIG })
		oSecTot:Cell("JURMUL"):SetBlock({|| (cTMPSED198)->VLJUROS+(cTMPSED198)->VLMULTA })

		If lExistFKD
			oSecTot:Cell("VALACESS"):SetBlock({||(cTMPSED198)->VALACESS})
		EndIf

		oSecTot:Cell("VALCORR"):SetBlock({|| (cTMPSED198)->VALCORR })
		oSecTot:Cell("DESCONT"):SetBlock({|| (cTMPSED198)->VLDESCO })
		oSecTot:Cell("ABATIM"):SetBlock({|| (cTMPSED198)->ABATIM })
		oSecTot:Cell("IMPOSTO"):SetBlock({|| (cTMPSED198)->IMPOSTO })
		oSecTot:Cell("BAIXADO"):SetBlock({|| (cTMPSED198)->VALOR })
	ENDIF

	If MV_PAR38 == 2 .or. MV_PAR38 == 5
		lAgrFil := IIF(MV_PAR37 == 1,.T.,.F.)
		If !lAgrFil
			oSecNat:Cell("E5_FILIAL"):SetBlock({|| (cAliasNat)->E5_FILIAL })
		EndIf
		//nBXBruta := (cAliasNat)->(E5_VALOR + E5_VLDESCO - E5_VLMULTA - E5_VLJUROS)
		oSecNat:Cell("ZZD_NIVEL"):SetBlock({|| (cAliasNat)->ZZD_NIVEL })
		oSecNat:Cell("ZZD_DESCRI"):SetBlock({|| (cAliasNat)->ZZD_DESCRI })
		oSecNat:Cell("E5_NATUREZ"):SetBlock({|| (cAliasNat)->E5_NATUREZ })
		oSecNat:Cell("ED_DESCRIC"):SetBlock({|| (cAliasNat)->ED_DESCRIC })
		oSecNat:Cell("E5_VALORIG"):SetBlock({|| (cAliasNat)->E5_VALORIG })
		oSecNat:Cell("nBXBruta"  ):SetBlock({|| (cAliasNat)->(E5_VALOR + E5_VLDESCO - E5_VLMULTA - E5_VLJUROS) })
		oSecNat:Cell("E5_VLJUROS"):SetBlock({|| (cAliasNat)->E5_VLJUROS })
		oSecNat:Cell("E5_VLMULTA"):SetBlock({|| (cAliasNat)->E5_VLMULTA })
		oSecNat:Cell("E5_VLCORRE"):SetBlock({|| (cAliasNat)->E5_VLCORRE })
		oSecNat:Cell("E5_VLDESCO"):SetBlock({|| (cAliasNat)->E5_VLDESCO })
		oSecNat:Cell("E5_ABATIM"):SetBlock({||  (cAliasNat)->E5_ABATIM })
		oSecNat:Cell("E5_IMPOSTO"):SetBlock({|| (cAliasNat)->E5_IMPOSTO })
		oSecNat:Cell("E5_VALOR"):SetBlock({||   (cAliasNat)->E5_VALOR })
	EndIf

	//===========================================================================
	//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
	//===========================================================================
	If MV_PAR38 == 3 .or. MV_PAR38 == 5
		oSecRegime:Cell("PREFIXO"):SetBlock({|| (cAliasReg)->PREFIXO })
		oSecRegime:Cell("NUM"):SetBlock({|| (cAliasReg)->NUM })
		oSecRegime:Cell("NATUREZ"):SetBlock({|| (cAliasReg)->NATUREZ })
		oSecRegime:Cell("PARCELA"):SetBlock({|| (cAliasReg)->PARCELA })
		oSecRegime:Cell("TIPO"):SetBlock({|| (cAliasReg)->TIPO })
		oSecRegime:Cell("CLIFOR"):SetBlock({|| (cAliasReg)->CLIFOR })
		oSecRegime:Cell("LOJA"):SetBlock({|| (cAliasReg)->LOJA })
		oSecRegime:Cell("NOME"):SetBlock({|| (cAliasReg)->NOME })
		oSecRegime:Cell("VENCREA"):SetBlock({|| StoD((cAliasReg)->VENCREA) })
		oSecRegime:Cell("EMISSAO"):SetBlock({|| StoD((cAliasReg)->EMISSAO) })
		oSecRegime:Cell("BAIXA"):SetBlock({|| StoD((cAliasReg)->BAIXA) })
		oSecRegime:Cell("HIST"):SetBlock({|| (cAliasReg)->HIST })
		oSecRegime:Cell("VAL_ORIG"):SetBlock({|| (cAliasReg)->VAL_ORIG })
		oSecRegime:Cell("VAL_SALDO"):SetBlock({|| (cAliasReg)->VAL_SALDO })
	EndIf

	If MV_PAR38 == 4 .or. MV_PAR38 == 5
		lAgrFil := IIF(MV_PAR37 == 1,.T.,.F.)
		If !lAgrFil
			oSecRegAgr:Cell("FILIAL"):SetBlock({|| (cAliasRAgr)->FILIAL })
		EndIf
		oSecRegAgr:Cell("ZZD_NIVEL"):SetBlock({|| (cAliasRAgr)->ZZD_NIVEL })
		oSecRegAgr:Cell("ZZD_DESCRI"):SetBlock({|| (cAliasRAgr)->ZZD_DESCRI })
		oSecRegAgr:Cell("NATUREZ"):SetBlock({|| (cAliasRAgr)->NATUREZ })
		oSecRegAgr:Cell("ED_DESCRIC"):SetBlock({|| (cAliasRAgr)->ED_DESCRIC })
		oSecRegAgr:Cell("VAL_ORIG"):SetBlock({|| (cAliasRAgr)->VAL_ORIG })
		oSecRegAgr:Cell("VAL_SALDO"):SetBlock({|| (cAliasRAgr)->VAL_SALDO })
	EndIf	

	If MV_PAR38 == 1 .or. MV_PAR38 == 5
		//===========================================================================
		//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
		//===========================================================================


		//Regras para soma do valor Original
		bVlOrig := {|| (cTMPSE5198)->E5_ULTBX == "S" .And. FVldBx(cTMPSE5198) }
		bVlBxd  := {|| FVldBx(cTMPSE5198) }

		cCodNat := (cTMPSE5198)->E5_NATUREZ
		cDscNat := (cTMPSE5198)->E5_NATDESC

		While !(cTMPSE5198)->(Eof())
			cNatPai := (cTMPSE5198)->E5_NATPAI
			If MV_PAR38 == 1 .or. MV_PAR38 == 5 //ultima
				oSecTit:Init()

				While (cTMPSE5198)->E5_NATPAI == cNatPai .And. !(cTMPSE5198)->(Eof())
					If cCodNat != (cTMPSE5198)->E5_NATUREZ
						If (cTMPSED198)->(DBSeek(cCodNat))
							oSecTit:Finish()
							oSecTot:Init()
							oSecTot:Cell("TITULO"):SetValue( "TOTAL DA NATUREZA ANALÍTICA " + MascNat( cCodNat,,,"") + " " + cDscNat ) //TOTAL DA NATUREZA ANALÍTICA
							oSecTot:PrintLine()
							oSecTot:Finish()
							FIncTot( oReport, cCodNat, "aTotais" )
							oSecTit:Init()
						EndIf
					EndIf

					oSecTit:PrintLine()
					oReport:IncMeter()
					cNatureza  := (cTMPSE5198)->E5_NATUREZ
					cDescricao := (cTMPSE5198)->E5_NATDESC
					cCodNat    := (cTMPSE5198)->E5_NATUREZ
					cDscNat    := (cTMPSE5198)->E5_NATDESC
					(cTMPSE5198)->(dbSkip())
				EndDo

				oSecTit:Finish()

				If (cTMPSED198)->(DBSeek(cCodNat))
					oSecTot:Init() //Inicializa sessão dos Totais
					oSecTot:Cell("TITULO"):SetValue( "TOTAL DA NATUREZA ANALÍTICA " + MascNat( cCodNat,,,"") + " " + cDscNat ) //TOTAL DA NATUREZA ANALÍTICA
					oSecTot:PrintLine()
					oSecTot:Finish()
					FIncTot(oReport, cCodNat, "aTotais" )
				EndIf

				dbSelectArea(cTMPSED198)
				(cTMPSED198)->(dbGoTop())

				While cNatPai <> ""
					If (cTMPSED198)->(dbSeek(cNatPai))
						If 	(cTMPSED198)->NIVEL == 1 //Só imprime o totalizador da sintética no último nível
							oSecTot:Init()
							oSecTot:Cell("TITULO"):SetValue( "TOTAL DA NATUREZA SINTÉTICA " + MascNat( (cTMPSED198)->NATUREZA,,,"") + " " + (cTMPSED198)->DESCNAT ) //TOTAL DA NATUREZA SINTÉTICA
							oSecTot:PrintLine()
							oSecTot:Finish()
							FIncTot( oReport, (cTMPSED198)->NATUREZA, "aTotSint" )
							oReport:IncMeter()
						Else
							Reclock(cTMPSED198,.F.)
							(cTMPSED198)->NIVEL -= 1
							(cTMPSED198)->(MsUnlock())
						EndIf

						//Controle de atualização das superiores imediatas
						cNatPai := (cTMPSED198)->NATPAI
					Else
						cNatPai := ""
					EndIf

					cCodNat := (cTMPSE5198)->E5_NATUREZ
					(cTMPSED198)->(dbSkip())
				EndDo
			EndIf
		EndDo
	
		(cTMPSE5198)->(dbCloseArea())
		(cTMPSED198)->(dbCloseArea())

		MsErase(cTMPSE5198)
		MsErase(cTMPSED198)

		//===========================================================================
		//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
		//===========================================================================
		oReport:EndPage()
		oSecTit:SetHeaderSection(.F.)
	ENDIF

	If MV_PAR38 == 2 .or. MV_PAR38 == 5	
		oReport:SetTitle("Regime de Caixa - Relação de Agrupamente de Contas - Serrana")
		oSecNat:SetTitle("Regime de Caixa - Relação de Agrupamente de Contas - Serrana")
		oSecNat:Init()
		(cAliasNat)->(DbGoTop())
		While !(cAliasNat)->(Eof())
			
			oSecNat:PrintLine()
			//oSecNat:Finish()
			oReport:IncMeter()

			(cAliasNat)->(DbSkip())
		EndDo
		(cAliasNat)->(DbCloseArea())
		oSecNat:Finish()
		oReport:EndPage()
		oSecTit:SetHeaderSection(.F.)
		// Destruir o objeto
		(cTMPSE5198)->(dbCloseArea())
		(cTMPSED198)->(dbCloseArea())

		MsErase(cTMPSE5198)
		MsErase(cTMPSED198)	
	ENDIF

	If MV_PAR38 == 3 .or. MV_PAR38 == 5
		oReport:SetTitle("Regime de Competência e Econômico - Serrana")
		oSecRegime:SetTitle("Regime de Competência e Econômico - Serrana")
		oSecRegime:Init()
		(cAliasReg)->(DbGoTop())
		While !(cAliasReg)->(Eof())

			oSecRegime:PrintLine()
			//oSecRegime:Finish()
			oReport:IncMeter()
			(cAliasReg)->(DbSkip())
		EndDo
		(cAliasReg)->(DbCloseArea())
		oSecRegime:Finish()

		oReport:EndPage()
		oSecTit:SetHeaderSection(.F.)
		// Destruir o objeto
		//(cTMPSED198)->(dbCloseArea())
		//MsErase(cTMPSED198)		
	ENDIF

	If MV_PAR38 == 4 .or. MV_PAR38 == 5
		oReport:SetTitle("Regime de Competência e Econômico - Agrupamento de Contas - Serrana")
		oSecRegAgr:SetTitle("Regime de Competência e Econômico - Agrupamento de Contas - Serrana")
		oSecRegAgr:Init()
		(cAliasRAgr)->(DbGoTop())
		While !(cAliasRAgr)->(Eof())

			oSecRegAgr:PrintLine()
			//oSecRegime:Finish()
			oReport:IncMeter()
			(cAliasRAgr)->(DbSkip())
		EndDo
		(cAliasRAgr)->(DbCloseArea())
		oSecRegAgr:Finish()
		// Destruir o objeto
		//(cTMPSED198)->(dbCloseArea())
		//MsErase(cTMPSED198)		
	EndIf
	//===========================================================================
	//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
	//===========================================================================

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGerTrb

Gera o arquivo temporário

@param oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function FGerTrb(aSelFil)

	Local aAux			:= {}
	Local aStruct		:= {}
	Local aValores		:= {}
	Local cCposQry		:= ""
	Local cCampo		:= ""
	Local cTipoIn		:= ""
	Local cTipoOut		:= ""
	Local cSituacao		:= MV_PAR23
	Local cQuery		:= ""
	Local cCarteira		:= ""
	Local cAliasQry		:= ""
	Local cChaveCH		:= ""
	Local cTpSel		:= ""
	Local cTpBusc		:= ""
	Local lCreate		:= .F.
	Local nX			:= 0
	Local nI			:= 0
	Local nDecs			:= 0
	Local nTaxa			:= 0
	Local nFator		:= 1
	Local nMoedOrig		:= 1
	Local nBaixado		:= 0
	Local nMovFin		:= 0
	Local nCompensa		:= 0
	Local nFatura		:= 0
	Local nPosNat		:= 0
	Local lMulNat		:= .F.
	Local lEncCH		:= .F.
	Local cQuery2 		:= ''
	Local cTmpFil		:= ""
	Local cDBName		:= Alltrim(Upper(TCGetDB()))
	Local nAux			:= 0
	Local nResto		:= 0
	Local cSitCartei	:= FN022LSTCB(1) + Space(TamSx3("E5_SITCOB")[1])
	Local cAdianta      := MV_CPNEG+"|"+MVPAGANT+"|"+MV_CRNEG+"|"+MVRECANT
	Local cTblReg       := ""
	Local nStruct		:= 0
	Local nValores		:= 0
	Local nMoedaBx      := 0
	Local dDataBx       := dDataBase
	Local oRegistro     := Nil
	Local oRatSev       := Nil
	Local oQryFk1       := Nil
	Local oQryFk2       := Nil
	Local cSqlReg
	Local cSqlRAgr
	Local lAgrFil
	Private dBaixa		:= dDataBase

	/*
	mv_par01 - Do Codigo ?
	mv_par02 - Ate o Codigo ?
	mv_par03 - Da Loja ?
	mv_par04 - Ate a Loja ?
	mv_par05 - Do Prefixo ?
	mv_par06 - Ate o Prefixo ?
	mv_par07 - Da Natureza ?
	mv_par08 - Ate a Natureza ?
	mv_par09 - Do Banco ?
	mv_par10 - Ate o Banco ?
	mv_par11 - Da Data de Baixa ?
	mv_par12 - Ate a Data de Baixa ?
	mv_par13 - Da Data Emissao ?
	mv_par14 - Ate a Data Emissao ?
	mv_par15 - Da Data Vencto Tit. ?
	mv_par16 - Ate Data Vencto Tit. ?
	mv_par17 - Do Lote ?
	mv_par18 - Ate o Lote ?
	mv_par19 - Da Carteira ?
	mv_par20 - Qual Moeda ?
	mv_par21 - Outras Moedas ?
	mv_par22 - Imprime Baixas ?
	mv_par23 - Situacoes ?
	mv_par24 - Cons. Mov. Fin. da Baixa ?
	mv_par25 - Cons. Filiais Abaixo ?
	mv_par26 - Da Filial ?
	mv_par27 - Ate a Filial ?
	mv_par28 - Da Filial Origem ?
	mv_par29 - Ate a Filial de Origem ?
	mv_par30 - Imprimir Tipos ?
	mv_par31 - Nao Imprimir Tipos ?
	mv_par32 - Imprime Incl. Adiantamentos ?
	mv_par33 - Considera Compensados ?
	mv_par34 - Imprime Titulos em Carteira ?
	mv_par35 - Imprime Cheques Aglutinados ?
	mv_par36 - seleciona filiais ?
	mv_par37 - Agrupa Nat por Filial ?
	*/

	nDecs := MsDecimais(mv_par20)

	cCarteira := Iif(mv_par19 = 1,"R","P")


	//===========================================================================
	//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
	//===========================================================================
	//Agrupar por Filial?
	lAgrFil := IIF(MV_PAR37 == 1,.T.,.F.)
	cSqlReg := "SELECT "
	If cCarteira == "R" //Receber
		cSqlReg += "E1_PREFIXO AS PREFIXO, E1_NUM AS NUM, E1_NATUREZ AS NATUREZ, "
		cSqlReg += "E1_PARCELA AS PARCELA, E1_TIPO AS TIPO, E1_CLIENTE AS CLIFOR, E1_LOJA AS LOJA, E1_NOMCLI AS NOME, "
		cSqlReg += "E1_VENCREA AS VENCREA, E1_EMISSAO AS EMISSAO, E1_BAIXA AS BAIXA, E1_HIST AS HIST, "
		cSqlReg += "E1_VALOR AS VAL_ORIG, E1_SALDO AS VAL_SALDO "
		cSqlReg += "FROM "+RetSqlName("SE1")+" SE1 "

		cWhere := "WHERE "
		cWhere += "	  SE1.E1_FILIAL  BETWEEN '" + mv_par26 + "' AND '" + mv_par27 + "' AND "
		cWhere += "	  SE1.E1_PREFIXO BETWEEN '" + mv_par05 + "' AND '"+ mv_par06 + "'  AND "
		cWhere += "	  SE1.E1_CLIENTE BETWEEN '"	+ mv_par01 + "' AND '"+ mv_par02 + "'  AND "
		cWhere += "	  SE1.E1_LOJA    BETWEEN '" + mv_par03 + "' AND '"+ mv_par04 + "'  AND "
		cWhere += "	  SE1.E1_NATUREZ BETWEEN '" + mv_par07 + "' AND '"+ mv_par08 + "'  AND "

		//Considerar Saldo == 0 ?
		//cSqlReg += "	  SE1.E1_SALDO   != 0 AND "

		//Tipos que serão impressos
		If !Empty(mv_par30)
			cTipoIn := FormatIn(mv_par30,";")
			cWhere += "SE1.E1_TIPO IN " +cTipoIn+ " AND "
		EndIf

		//Tipos que não serão impressos
		If !Empty(mv_par31)
			cTipoOut := FormatIn(mv_par31,";")
			cWhere += "SE1.E1_TIPO NOT IN " + cTipoOut + " AND "
		EndIf

		//cSqlReg += "	  SE1.E1_TIPO NOT IN () AND
		cWhere += "	  SE1.E1_EMISSAO BETWEEN '" + DtoS(mv_par13)+ "' AND '"+ DtoS(mv_par14) + "' AND "
		cWhere += "	  SE1.E1_VENCREA BETWEEN '" + DtoS(mv_par15)+ "' AND '"+ DtoS(mv_par16) + "' AND "
		cWhere += "	  SE1.D_E_L_E_T_ = ''"

		cSqlReg += cWhere

		//AGRUPAMENTO POR NIVEL E NATUREZAS - INICIO
		cSqlRAgr := "SELECT "
		If !lAgrFil
			cSqlRAgr += "E1_FILIAL AS FILIAL, "
		EndIf
		cSqlRAgr += "ZZD_NIVEL, ZZD_DESCRI, E1_NATUREZ AS NATUREZ, ED_DESCRIC, "
		cSqlRAgr += "SUM(E1_VALOR) AS VAL_ORIG, SUM(E1_SALDO) AS VAL_SALDO "
		cSqlRAgr += "FROM "+RetSqlName("SE1")+" SE1 "
		cSqlRAgr += "JOIN "+RetSqlName("SED")+" SED "
		cSqlRAgr += "ON "
		cSqlRAgr += "   SED.ED_FILIAL  = '"+xFilial("SED")+"' AND "
		cSqlRAgr += "   SED.ED_CODIGO  = E1_NATUREZ AND "
		cSqlRAgr += "   SED.D_E_L_E_T_ = ' ' "
		cSqlRAgr += "JOIN "+RetSqlName("ZZD")+" ZZD "
		cSqlRAgr += "ON "
		cSqlRAgr += "   ZZD.ZZD_FILIAL = '"+xFilial("ZZD")+"' AND "
		cSqlRAgr += "   ZZD.ZZD_COD    = SED.ED_YTIPAGE AND "
		cSqlRAgr += "   ZZD.D_E_L_E_T_ = ' ' "
		cSqlRAgr += cWhere
		If !lAgrFil
			cSqlRAgr += "GROUP BY E1_FILIAL, ZZD_NIVEL, ZZD_DESCRI, E1_NATUREZ, ED_DESCRIC "
			cSqlRAgr += "ORDER BY E1_FILIAL, ZZD_NIVEL, ZZD_DESCRI, E1_NATUREZ "
		Else
			cSqlRAgr += "GROUP BY ZZD_NIVEL, ZZD_DESCRI, E1_NATUREZ, ED_DESCRIC "
			cSqlRAgr += "ORDER BY ZZD_NIVEL, ZZD_DESCRI, E1_NATUREZ "
		EndIf
		//AGRUPAMENTO POR NIVEL E NATUREZAS - FIM

	Else //Pagar
		cSqlReg += "E2_PREFIXO AS PREFIXO, E2_NUM AS NUM, E2_NATUREZ AS NATUREZ, "
		cSqlReg += "E2_PARCELA AS PARCELA, E2_TIPO AS TIPO, E2_FORNECE AS CLIFOR, E2_LOJA AS LOJA, E2_NOMFOR AS NOME, "
		cSqlReg += "E2_VENCREA AS VENCREA, E2_EMISSAO AS EMISSAO, E2_BAIXA AS BAIXA, E2_HIST AS HIST, "
		cSqlReg += "E2_VALOR AS VAL_ORIG, E2_SALDO AS VAL_SALDO "
		cSqlReg += "FROM "+RetSqlName("SE2")+" SE2 "

		cWhere := "WHERE
		cWhere += "      SE2.E2_FILIAL  BETWEEN '" + mv_par26 + "' AND '" + mv_par27 + "' AND "
		cWhere += "	     SE2.E2_PREFIXO BETWEEN '" + mv_par05 + "' AND '"+ mv_par06 + "'  AND "
		cWhere += "      SE2.E2_FORNECE BETWEEN '" + mv_par01 + "' AND '"+ mv_par02 + "'  AND "
		cWhere += "      SE2.E2_LOJA    BETWEEN '" + mv_par03 + "' AND '"+ mv_par04 + "'  AND "
		cWhere += "      SE2.E2_NATUREZ BETWEEN '" + mv_par07 + "' AND '"+ mv_par08 + "'  AND "

		//Considerar Saldo == 0 ?
		//cSqlReg += "      SE2.E2_SALDO   != 0 AND

		//Tipos que serão impressos
		If !Empty(mv_par30)
			cTipoIn := FormatIn(mv_par30,";")
			cWhere += "SE2.E2_TIPO IN " +cTipoIn+ " AND "
		EndIf

		//Tipos que não serão impressos
		If !Empty(mv_par31)
			cTipoOut := FormatIn(mv_par31,";")
			cWhere += "SE2.E2_TIPO NOT IN " + cTipoOut + " AND "
		EndIf
		//cSqlReg += "SE2.E2_TIPO NOT IN () AND

		cWhere += "	  SE2.E2_EMISSAO BETWEEN '" + DtoS(mv_par13)+ "' AND '"+ DtoS(mv_par14) + "' AND "
		cWhere += "	  SE2.E2_VENCREA BETWEEN '" + DtoS(mv_par15)+ "' AND '"+ DtoS(mv_par16) + "' AND "
		cWhere += "	  SE2.D_E_L_E_T_ = ''"

		cSqlReg += cWhere

		//AGRUPAMENTO POR NIVEL E NATUREZAS - INICIO
		cSqlRAgr := "SELECT "
		If !lAgrFil
			cSqlRAgr += "E2_FILIAL AS FILIAL, "
		EndIf
		cSqlRAgr += "ZZD_NIVEL, ZZD_DESCRI, E2_NATUREZ AS NATUREZ, ED_DESCRIC, "
		cSqlRAgr += "SUM(E2_VALOR) AS VAL_ORIG, SUM(E2_SALDO) AS VAL_SALDO "
		cSqlRAgr += "FROM "+RetSqlName("SE2")+" SE2 "
		cSqlRAgr += "JOIN "+RetSqlName("SED")+" SED "
		cSqlRAgr += "ON "
		cSqlRAgr += "   SED.ED_FILIAL  = '"+xFilial("SED")+"' AND "
		cSqlRAgr += "   SED.ED_CODIGO  = E2_NATUREZ AND "
		cSqlRAgr += "   SED.D_E_L_E_T_ = ' ' "
		cSqlRAgr += "JOIN "+RetSqlName("ZZD")+" ZZD "
		cSqlRAgr += "ON "
		cSqlRAgr += "   ZZD.ZZD_FILIAL = '"+xFilial("ZZD")+"' AND "
		cSqlRAgr += "   ZZD.ZZD_COD    = SED.ED_YTIPAGE AND "
		cSqlRAgr += "   ZZD.D_E_L_E_T_ = ' ' "
		cSqlRAgr += cWhere
		If !lAgrFil
			cSqlRAgr += "GROUP BY E2_FILIAL, ZZD_NIVEL, ZZD_DESCRI, E2_NATUREZ, ED_DESCRIC "
			cSqlRAgr += "ORDER BY E2_FILIAL, ZZD_NIVEL, ZZD_DESCRI, E2_NATUREZ "
		Else
			cSqlRAgr += "GROUP BY ZZD_NIVEL, ZZD_DESCRI, E2_NATUREZ, ED_DESCRIC "
			cSqlRAgr += "ORDER BY ZZD_NIVEL, ZZD_DESCRI, E2_NATUREZ"
		EndIf
		//AGRUPAMENTO POR NIVEL E NATUREZAS - FIM

	EndIf
	cSqlReg := ChangeQuery(cSqlReg)
	cSqlRAgr := ChangeQuery(cSqlRAgr)
	If MV_PAR38 == 3 .or. MV_PAR38 == 5
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cSqlReg),cAliasReg,.F.,.T.)
	ENDIF
	If MV_PAR38 == 4 .or. MV_PAR38 == 5
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cSqlRAgr),cAliasRAgr,.F.,.T.)
	EndIf
	//===========================================================================
	//EXIBINDO OS TITULOS - SE1 / SE2 - CONSIDERANDO A EMISSAO E VENCIMENTO		=
	//===========================================================================


	If MV_PAR38 == 1 .or. MV_PAR38 == 2  .or. MV_PAR38 == 3 .or. MV_PAR38 == 4 .or. MV_PAR38 == 5
		/*
		Seleção de Movimentos
		*/
		IF TCCANOPEN(cTMPSE5198)
			MsErase(cTMPSE5198)
		EndIf

		cCposQry := ""

		DbSelectArea("SE5")
		aEval(SE5->(dbStruct()),{|e| cCposQry += ","+AllTrim(e[1])})

		If cCarteira == "R"
			cCposQry += ",E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_NOMCLI"
			cCposQry += ",E1_TXMOEDA,E1_MOEDA,E1_MULTNAT,E1_VENCTO,E1_SITUACA,E1_VALOR,E1_EMISSAO "
		Else
			cCposQry += ",E2_FILIAL,E2_FORNECE,E2_LOJA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,E2_NOMFOR"
			cCposQry += ",E2_TXMOEDA,E2_MOEDA,E2_MULTNAT,E2_VENCTO,E2_VALOR,E2_EMISSAO "
		EndIf

		cCposQry += ",ED_FILIAL,ED_CODIGO,ED_DESCRIC,ED_PAI "

		cQuery := "SELECT " + SubStr(cCposQry,2) + " FROM " + RetSqlName("SE5") + " SE5 "

		If cCarteira == "R"
			cQuery += "LEFT OUTER JOIN "+ RetSqlName("SE1") +" SE1 ON "
			cQuery += "( SE1.E1_FILIAL = SE5.E5_FILIAL AND "
			cQuery += "	SE1.E1_PREFIXO = SE5.E5_PREFIXO AND "
			cQuery += "	SE1.E1_NUM = SE5.E5_NUMERO AND "
			cQuery += "	SE1.E1_PARCELA = SE5.E5_PARCELA AND "
			cQuery += "	SE1.E1_TIPO = SE5.E5_TIPO AND "
			cQuery += "	SE1.E1_CLIENTE = SE5.E5_CLIFOR AND "
			cQuery += "	SE1.E1_LOJA = SE5.E5_LOJA AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' "
			cQuery += ") "
		ElseIf cCarteira == "P"
			cQuery += "LEFT OUTER JOIN "+ RetSqlName("SE2") +" SE2 ON "
			cQuery += "( SE2.E2_FILIAL = SE5.E5_FILIAL AND "
			cQuery += "	SE2.E2_PREFIXO = SE5.E5_PREFIXO AND "
			cQuery += "	SE2.E2_NUM = SE5.E5_NUMERO AND "
			cQuery += "	SE2.E2_PARCELA = SE5.E5_PARCELA AND "
			cQuery += "	SE2.E2_TIPO = SE5.E5_TIPO AND "
			cQuery += "	SE2.E2_FORNECE = SE5.E5_CLIFOR AND "
			cQuery += "	SE2.E2_LOJA = SE5.E5_LOJA AND "
			cQuery += "	SE2.D_E_L_E_T_ = ' ' "
			cQuery += ") "
		EndIf

		cQuery += "LEFT OUTER JOIN "+ RetSqlName("SED") +" SED ON (SED.ED_CODIGO = SE5.E5_NATUREZ "

		//Tratamento compartilhamento entre SE5 e SED para várias filiais
		Do Case
			// SE compartilhamento for igual -> Filial com filial
		Case 	FWModeAccess("SE5",1) == FWModeAccess("SED",1) .AND. ;
				FWModeAccess("SE5",2) == FWModeAccess("SED",2) .AND. ;
				FWModeAccess("SE5",3) == FWModeAccess("SED",3)

			cQuery += "AND SED.ED_FILIAL = SE5.E5_FILIAL "

			// SE SED totalmente exclusiva, comparar com E5_FILORIG
		Case	FWModeAccess("SED",1) == 'E' .AND. FWModeAccess("SED",2) == "E" .AND. FWModeAccess("SED",3) == "E"

			cQuery += "AND SED.ED_FILIAL = SE5.E5_FILORIG "

			// SE SED totalmente compartilhada, comparar com filial e, branco
		Case	FWModeAccess("SED",1) == 'C' .AND. FWModeAccess("SED",2) == "C" .AND. FWModeAccess("SED",3) == "C"

			cQuery += "AND SED.ED_FILIAL = '" + Space(FWSizeFilial()) + "' "

		Otherwise		// Comparar o E5_FILORIG até onde for o compartilhamento da SED

			If cDBName == "MSSQL" // Para MSSQL não tem RPAD

				nAux := Len(RTrim(FWxFilial("SED")))
				nResto := FWSizeFilial() - nAux

				cQuery += "AND SED.ED_FILIAL = SUBSTRING(SE5.E5_FILORIG,1," + cValToChar(nAux) + ") + SPACE(" + cValToChar(nResto) + ") "

			Else

				cQuery += "AND SED.ED_FILIAL = RPAD( SUBSTRING(SE5.E5_FILORIG,1," + cValToChar(Len(RTrim(FWxFilial("SED")))) +") ," + cValToChar(FWSizeFilial()) + ",' ')"

			EndIf

		EndCase

		cQuery += "AND SED.D_E_L_E_T_ = ' ' ) WHERE "

	   //GESTAO - inicio
		If mv_par36 == 1	// Seleciona Filiais
			cQuery += FinSelFil(aSelFil, "SE5") + "AND "
		ElseIf mv_par25 == 1 //Considera filiais
			If Empty( xFilial("SE5") )
				cQuery += "SE5.E5_FILORIG BETWEEN '"+ mv_par28 + "' AND '" + mv_par29 + "' AND "
			Else
				cQuery += "SE5.E5_FILIAL BETWEEN '"+ mv_par26 + "' AND '" + mv_par27 + "' AND "
			EndIf
		Else
			cQuery += "SE5.E5_FILIAL = '" +xFilial("SE5")+ "' AND "
		Endif

	   //GESTAO - fim
		cQuery += "SE5.E5_PREFIXO BETWEEN '" + mv_par05	+ "' AND '"+ mv_par06 		+ "' AND "
		cQuery += "SE5.E5_CLIFOR BETWEEN '"	+ mv_par01 + "' AND '"+ mv_par02 		+ "' AND "
		cQuery += "SE5.E5_LOJA BETWEEN '" + mv_par03 + "' AND '"+ mv_par04 		+ "' AND "
		cQuery += "(( SE5.E5_NATUREZ BETWEEN '" + mv_par07 + "' AND '"+ mv_par08 		+ "') Or "
		cQuery += " ( SE5.R_E_C_N_O_ IN (SELECT E5.R_E_C_N_O_ FROM " + RetSqlName("SE5") + " E5," + RetSqlName("SEV")+ " EV "
		cQuery	+= " WHERE "
		cQuery += "EV.EV_FILIAL = '" + xFilial("SEV")+ "' AND "
		cQuery += "EV.EV_PREFIXO = SE5.E5_PREFIXO  AND "
		cQuery += "EV.EV_NUM = SE5.E5_NUMERO  AND "
		cQuery += "EV.EV_PARCELA = SE5.E5_PARCELA  AND "
		cQuery += "EV.EV_TIPO = SE5.E5_TIPO  AND "
		cQuery += "EV.EV_CLIFOR = SE5.E5_CLIFOR  AND "
		cQuery += "EV.EV_LOJA = SE5.E5_LOJA  AND "
		cQuery += "EV.EV_IDENT = '2' AND "
		cQuery += "EV.EV_SEQ = SE5.E5_SEQ AND "
		cQuery += "EV.EV_NATUREZ BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' AND "
		cQuery += "EV.D_E_L_E_T_ = ' '  ) ) )AND   "
		cQuery += "SE5.E5_BANCO BETWEEN '" + mv_par09 + "' AND '"+ mv_par10 		+ "' AND "
		cQuery += "SE5.E5_DATA BETWEEN '" + DtoS(mv_par11) + "' AND '"+ DtoS(mv_par12) + "' AND "

		//OLHAR PARA O TITULO SE1 OU SE2 DE ACORDO COM A CARTEIRA - SERRANA
		//cQuery += "SE5.E5_DTDIGIT BETWEEN '" + DtoS(mv_par13)+ "' AND '"+ DtoS(mv_par14) + "' AND "
		//Data de Emissao sera feita em uma nova seção abaixo...
		//If cCarteira == "R"
		//	cQuery += "SE1.E1_EMISSAO BETWEEN '" + DtoS(mv_par13)+ "' AND '"+ DtoS(mv_par14) + "' AND "
		//ElseIf cCarteira == "P"
		//	cQuery += "SE2.E2_EMISSAO BETWEEN '" + DtoS(mv_par13)+ "' AND '"+ DtoS(mv_par14) + "' AND "
		//EndIf

		cQuery += "SE5.E5_LOTE BETWEEN '" + mv_par17 		+ "' AND '"+ mv_par18 		+ "' AND "

		//Outras moedas
		If mv_par21 = 2 //Nao Imprimir
			cQuery += "SE5.E5_MOEDA = '" +PadL(AllTrim(Str(mv_par20)),TamSx3("E5_MOEDA")[1],"0")+ "' AND "
		EndIf

		//Tipos que serão impressos
		If !Empty(mv_par30)
			cTipoIn := FormatIn(mv_par30,";")
			cQuery += "SE5.E5_TIPO IN " +cTipoIn+ " AND "
		EndIf

		//Tipos que não serão impressos
		If !Empty(mv_par31)
			cTipoOut := FormatIn(mv_par31,";")
			cQuery += "SE5.E5_TIPO NOT IN " + cTipoOut + " AND "
		EndIf

	   //Mov. Bancario da Baixa
		If mv_par24 == 2
			cQuery += "SE5.E5_TIPODOC <> '" + Space(TamSX3("E5_TIPODOC")[1]) + "' AND "
			cQuery += "SE5.E5_NUMERO  <> '" + Space(TamSX3("E5_NUMERO")[1]) + "' AND "
			cQuery += "SE5.E5_TIPODOC <> 'CH' AND "
		Endif

		cQuery += "SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','VA') AND "
		cQuery += "SE5.E5_SITUACA NOT IN ('E','X') AND "

		If cCarteira == "R" //Receber
			cQuery += "((SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC <> 'ES') OR "
			cQuery += " (SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC = 'ES')) AND "
		Else //Pagar
			cQuery += "((SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC <> 'ES') OR "
			cQuery += " (SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC = 'ES')) AND "
		EndIf

		If cCarteira == "R" .And. mv_par34 = 1 .And. !Empty(cSitCartei) // //Somente em carteira
			cQuery += " E5_SITCOB IN "+FormatIn(cSitCartei,"|") + " AND "
		EndIf

		cQuery += "SE5.D_E_L_E_T_ = ' ' "

		cQuery += "ORDER BY SED.ED_PAI,SED.ED_CODIGO "

		cAliasQry := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)

	   //Gera o arquivo temporário
		aStruct := SE5->(dbStruct())

		aAdd(aStruct,{"E5_NOME"		,"C",TamSx3("E2_NOMFOR")[1]	,TamSx3("E2_NOMFOR")[2]}	)
		aAdd(aStruct,{"E5_VALORIG"	,"N",TamSx3("E5_VALOR")[1]	,TamSx3("E5_VALOR")[2]}		)
		aAdd(aStruct,{"E5_VALTIT"	,"N",TamSx3("E5_VALOR")[1]	,TamSx3("E5_VALOR")[2]}		)
		aAdd(aStruct,{"E5_ABATIM"	,"N",TamSx3("E5_VALOR")[1]	,TamSx3("E5_VALOR")[2]}		)
		aAdd(aStruct,{"E5_IMPOSTO"	,"N",TamSx3("E5_VALOR")[1]	,TamSx3("E5_VALOR")[2]}		)
		aAdd(aStruct,{"E5_VALBX"	,"N",TamSx3("E5_VALOR")[1]	,TamSx3("E5_VALOR")[2]}		)
		aAdd(aStruct,{"E5_NATPAI"	,"C",TamSx3("E5_NATUREZ")[1],TamSx3("E5_NATUREZ")[2]}	)
		aAdd(aStruct,{"E5_NATDESC"	,"C",TamSx3("ED_DESCRIC")[1],TamSx3("ED_DESCRIC")[2]}	)
		aAdd(aStruct,{"E5_ULTBX"	,"C",1						,0}							)
		aAdd(aStruct,{"VALACESS"	,"N",TamSx3("E5_VALOR")[1]	,TamSx3("E5_VALOR")[2]}		)

	   //Cria o arquivo temporário
		lCreate := MsCreate(cTMPSE5198, aStruct, "TOPCONN")
		nStruct := Len(aStruct)

		If lCreate
			dbSelectArea("SE5")
			SE5->(dbSetOrder(11))

			dbUseArea(.T.,"TOPCONN",cTMPSE5198,cTMPSE5198,.T.,.F.)
			dbSelectArea(cTMPSE5198)
			dbCreateIndex(cTMPSE5198 + "i","E5_NATPAI+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA+E5_SEQ", {|| "E5_NATPAI+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA+E5_SEQ"})
			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())

			While !(cAliasQry)->(Eof())
				If Empty((cAliasQry)->ED_PAI)
					(cAliasQry)->(dbSkip())
					Loop
				EndIf

				If !Empty((cAliasQry)->E5_TIPODOC) .And. !Empty((cAliasQry)->E5_NUMERO)
					//Motivo de baixa - normal/todos
					If mv_par22 == 1 .and. !MovBcoBx((cAliasQry)->E5_MOTBX)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf

					//Adiantamento
					If mv_par32 = 2 .And. (cAliasQry)->E5_TIPO $ cAdianta
						(cAliasQry)->(dbSkip())
						Loop
					EndIf

					//Compensação
					If mv_par33 == 2 .And. (cAliasQry)->E5_TIPO $ cAdianta .And. (cAliasQry)->E5_MOTBX == "CMP"
						(cAliasQry)->(dbSkip())
						Loop
					EndIf

					//Valida informações dos títulos (SE1/SE2)
					If cCarteira == "R" //Receber
						If mv_par34 == 2 .And. !Empty(cSituacao) //Título em carteira já é filtrado na query, situação em branco não filtra
							//Valida situação
							If !Empty((cAliasQry)->E5_SITCOB)
								If !((cAliasQry)->E5_SITCOB $ cSituacao)
									(cAliasQry)->(dbSkip())
									Loop
								EndIf
							ElseIf !Empty((cAliasQry)->E1_SITUACA)
								If !((cAliasQry)->E1_SITUACA $ cSituacao)
									(cAliasQry)->(dbSkip())
									Loop
								EndIf
							EndIf
						EndIf

						//Valida o vencimento do título
						//If (StoD((cAliasQry)->E1_VENCTO) < mv_par15 .OR. StoD((cAliasQry)->E1_VENCTO) > mv_par16)
						//	(cAliasQry)->(dbSkip())
						//	Loop
						//EndIf

					Else //Pagar
						//Valida o vencimento do título
						//If StoD((cAliasQry)->E2_VENCTO) < mv_par15 .OR. StoD((cAliasQry)->E2_VENCTO) > mv_par16
						//	(cAliasQry)->(dbSkip())
						//	Loop
						//EndIf
					EndIf
				EndIf

				cChaveCH := (cAliasQry)->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)

				If mv_par35 == 1
					cTpSel := "BA"
					cTpBusc	:= "CH"
				ElseIf mv_par35 == 2
					cTpSel := "CH"
					cTpBusc	:= "BA"
				EndIf

				If (cAliasQry)->E5_TIPODOC == cTpSel .And. SE5->(dbSeek(xFilial("SE5")+cChaveCH))
					// Procura o cheque, se encontrar, marca e despreza
					While SE5->(!Eof()) .And. SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ) == cChaveCH
						If SE5->E5_TIPODOC == cTpBusc .Or. Empty(SE5->E5_NUMCHEQ)
							lEncCH := .T.
							Exit
						EndIf
						SE5->(dbSkip())
					EndDo

					If lEncCH //Se encontrou o cheque com a caracteristica informada, despreza o registro
						(cAliasQry)->(dbSkip())
						lEncCH := .F.
						Loop
					EndIf
				EndIf

				If oRegistro == Nil
					cQuery2 := "SELECT COUNT(SE5.E5_BANCO) NTOTAL FROM " + RetSqlName( "SE5" ) + " SE5 "
					cQuery2 += "WHERE SE5.E5_BANCO = ? "
					cQuery2 += "AND SE5.E5_AGENCIA = ? "
					cQuery2 += "AND SE5.E5_CONTA = ? "
					cQuery2 += "AND SE5.E5_NUMCHEQ = ? "
					cQuery2 += "AND SE5.E5_FILIAL = ? "
					cQuery2 += "AND SE5.E5_TIPODOC = 'EC' AND SE5.D_E_L_E_T_ = ' ' "
					cQuery2 := ChangeQuery(cQuery2)
					oRegistro := FWPreparedStatement():New(cQuery2)
				EndIf

				oRegistro:SetString(1, (cAliasQry)->E5_BANCO)
				oRegistro:SetString(2, (cAliasQry)->E5_AGENCIA)
				oRegistro:SetString(3,  (cAliasQry)->E5_CONTA)
				oRegistro:SetString(4, (cAliasQry)->E5_NUMCHEQ)
				oRegistro:SetString(5, xFilial("SE5"))
				cQuery2 := oRegistro:GetFixQuery()
				cTblReg := MpSysOpenQuery(cQuery2)

				If (cTblReg)->NTOTAL > 0
					(cTblReg)->(DbCloseArea())
					(cAliasQry)->(dbSkip())
					Loop
				EndIf

				(cTblReg)->(DbCloseArea())
				cTpSel := cTpBusc := ""

				//Recupera os valores do movimento
				aValores := FTotVal(cAliasQry, cCarteira, @oRatSev, @oQryFk1, @oQryFk2)

				If (nValores := Len(aValores)) > 0
					//Grava o registro
					For nI := 1 to nValores
						nFator := 1 //fator de multiplicação
						Reclock(cTMPSE5198,.T.)

						For nX := 1 to nStruct
							cCampo := aStruct[nX,1]

							If cCampo == "VALACESS"
								Loop
							EndIf

							Do Case
							Case cCampo == "E5_NOME"
								xConteudo := Iif(cCarteira == "R", (cAliasQry)->E1_NOMCLI, (cAliasQry)->E2_NOMFOR)
							Case cCampo $ "E5_VALORIG|E5_VALTIT|E5_ABATIM|E5_IMPOSTO|E5_VALBX"
								xConteudo := 0
							Case cCampo == "E5_NATPAI"
								xConteudo := (cAliasQry)->ED_PAI
							Case cCampo == "E5_NATDESC"
								xConteudo := (cAliasQry)->ED_DESCRIC
							Case cCampo == "E5_ULTBX"
								If (cAliasQry)->E5_SEQ == aValores[nI][9] .Or. Empty((cAliasQry)->E5_SEQ) .Or. Empty(aValores[nI][9])
									xConteudo := "S"
								Else
									xConteudo := "N"
								EndIf
							Case cCampo == "E5_HISTOR"
								If aValores[nI][11] //Cancelado
									xConteudo := "CANCELAMENTO DE BAIXA" //CANCELAMENTO DE BAIXA
								ElseIf Empty((cAliasQry)->E5_TIPODOC) .And. Empty((cAliasQry)->E5_NUMERO) .And. Empty((cAliasQry)->E5_HISTOR)
									xConteudo := "MOVIMENTO MANUAL" //MOVIMENTO MANUAL
								ElseIf !Empty((cAliasQry)->E5_NUMCHEQ)
									xConteudo := AllTrim((cAliasQry)->E5_NUMCHEQ)+"/"+Iif(!Empty((cAliasQry)->E5_HISTOR),(cAliasQry)->E5_HISTOR,"CHEQUE") //CHEQUE
								ElseIf !Empty((cAliasQry)->E5_HISTOR)
									xConteudo := (cAliasQry)->E5_HISTOR
								EndIf
							Case cCampo == "E5_DTDIGIT" //ALTERANDO EMISSAO - SERRANA
								If cCarteira == "R" //Receber
									xConteudo := (cAliasQry)->E1_EMISSAO
								ElseIf cCarteira == "P" //Pagar
									xConteudo := (cAliasQry)->E2_EMISSAO
								EndIf
							Otherwise
								xConteudo := (cAliasQry)->&cCampo

								//Ajuste para campos do tipo data
								If aStruct[nX,2] == "D"
									xConteudo := StoD(xConteudo)
								ElseIf aStruct[nX,2] == "L"
									xConteudo := (xConteudo == 'T')
								EndIf
							EndCase

							//Adiciona conteúdo ao campo
							nPosCampo := (cTMPSE5198)->(FieldPos(cCampo))
							(cTMPSE5198)->(FieldPut(nPosCampo, xConteudo))
						Next nX

						//Verifica a taxa de conversão do título, quando aplicável
						If !Empty((cAliasQry)->E5_TXMOEDA) .And. Val((cAliasQry)->E5_MOEDA) = 1
							nTaxa := (cAliasQry)->E5_TXMOEDA
						ElseIf cCarteira == "P"
							If Empty((cAliasQry)->E2_TXMOEDA)
								nTaxa := RecMoeda(StoD((cAliasQry)->E5_DATA),(cAliasQry)->E2_MOEDA)
							Else
								nTaxa := (cAliasQry)->E2_TXMOEDA
							EndIf
						ElseIf cCarteira == "R"
							If Empty((cAliasQry)->E1_TXMOEDA)
								nTaxa := RecMoeda(StoD((cAliasQry)->E5_DATA),(cAliasQry)->E1_MOEDA)
							Else
								nTaxa := (cAliasQry)->E1_TXMOEDA
							EndIf
						EndIf

						If (cAliasQry)->E5_TIPODOC == "ES" //ESTORNO
							nFator := -1
						EndIf

						(cTMPSE5198)->E5_NATUREZ := aValores[nI][1]

						//Altera a natureza Pai
						If MV_MULNATP
							If cCarteira == "R" .And. ((cAliasQry)->E1_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1")
								lMulNat := .T.
							ElseIf cCarteira == "P" .And. ((cAliasQry)->E2_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1")
								lMulNat := .T.
							EndIf

							If lMulNat
								dbSelectArea("SED")
								SED->(dbSetOrder(1))
								If dbSeek(xFilial("SED")+aValores[nI][1])
									(cTMPSE5198)->E5_NATDESC := SED->ED_DESCRIC
									(cTMPSE5198)->E5_NATPAI := SED->ED_PAI
								EndIf
							EndIf
						EndIf

						/*
						aValores
						[x][1] = Natureza, [x][2] = Valor Original, [x][3] = Juros/Multa, [x][4] = Correção
						[x][5] = Desconto, [x][6] = Abatimentos, [x][7] = Impostos, [x][8] = Valor Baixado
						*/
						nMoedaBx := Val((cAliasQry)->E5_MOEDA)
						dDataBx  := StoD((cAliasQry)->E5_DATA)

						(cTMPSE5198)->E5_VALORIG := Round(NoRound(xMoeda(aValores[nI][2],  nMoedaBx, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) * nFator

						If aValores[nI][3] != 0
							(cTMPSE5198)->E5_VLJUROS := Round(NoRound(xMoeda(aValores[nI][3],  nMoedaBx, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) * nFator
						EndIf

						If aValores[nI][4] != 0
							(cTMPSE5198)->E5_VLCORRE := Round(NoRound(xMoeda(aValores[nI][4],  nMoedaBx, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) * nFator
						EndIf

						If aValores[nI][5] != 0
							(cTMPSE5198)->E5_VLDESCO := Round(NoRound(xMoeda(aValores[nI][5],  nMoedaBx, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) * nFator
						EndIf

						If aValores[nI][6] != 0
							(cTMPSE5198)->E5_ABATIM  := Round(NoRound(xMoeda(aValores[nI][6],  nMoedaBx, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) * nFator
						EndIf

						If aValores[nI][10]
							(cTMPSE5198)->E5_VLMULTA := Round(NoRound(xMoeda(aValores[nI][10], nMoedaBx, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) * nFator
						EndIf

						nMoedOrig := 1 //Impostos localizados

						If cPaisLoc == "BRA"
							nMoedOrig := nMoedaBx
						EndIf

						If aValores[nI][7] != 0
							(cTMPSE5198)->E5_IMPOSTO := Round(NoRound(xMoeda(aValores[nI][7], nMoedOrig, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) *  nFator
						EndIf

						If aValores[nI][8] != 0
							(cTMPSE5198)->E5_VALOR   := Round(NoRound(xMoeda(aValores[nI][8], nMoedaBx, mv_par20, dDataBx, nDecs+1, nTaxa), nDecs+1), nDecs) * nFator
						EndIf

						If FVldBx(cAliasQry)
							//Valor dos títulos que serão totalizados
							If (cTMPSE5198)->E5_ULTBX == "S"
								(cTMPSE5198)->E5_VALTIT := (cTMPSE5198)->E5_VALORIG //Considera uma única vez o valor do título para recompor o total
							EndIf

							//Valor baixado que será totalizado
							(cTMPSE5198)->E5_VALBX := (cTMPSE5198)->E5_VALOR
						EndIf

						//Gravando a TABela de Origem
						(cTMPSE5198)->E5_TABORI  := (cAliasQry)->E5_TABORI
						(cTMPSE5198)->E5_IDORIG  := (cAliasQry)->E5_IDORIG
						(cTMPSE5198)->E5_TIPODOC := (cAliasQry)->E5_TIPODOC

						//Ajusta a data de vencimento
						If Empty((cAliasQry)->E5_VENCTO)
							(cTMPSE5198)->E5_VENCTO := StoD(Iif(cCarteira == "R", (cAliasQry)->E1_VENCTO, (cAliasQry)->E2_VENCTO))
						EndIf

						If lExistFKD
							(cTMPSE5198)->VALACESS := FK6Calc((cAliasQry)->E5_TABORI, (cAliasQry)->E5_IDORIG, (cAliasQry)->E5_TIPODOC)
						EndIf

						(cTMPSE5198)->(MsUnlock())

						If ValType("aTotais") <> "U"
							nBaixado 	:= 0
							nMovFin	:= 0
							nCompensa	:= 0
							nFatura	:= 0

							//Atualiza os totais
							If !((cAliasQry)->E5_MOTBX == "CMP" .Or. !MovBcoBx((cAliasQry)->E5_MOTBX)) .And. !Empty((cAliasQry)->(E5_TIPODOC+E5_NUMERO))
								nBaixado := (cTMPSE5198)->E5_VALOR
							EndIf

							If !(cAliasQry)->E5_TIPODOC $ " VL|V2|BA|RA|PA|CP|ES"
								nMovFin	:= (cTMPSE5198)->E5_VALOR
							EndIf

							If (cAliasQry)->E5_TIPODOC == "CP"
								//Títulos compensados são exibidos com sinal negativo (-), sendo necessário fazer a inversao no totalizador
								nCompensa	:= (cTMPSE5198)->E5_VALOR * nFator
							EndIf

							If (cAliasQry)->E5_MOTBX == "FAT"
								nFatura	:= (cTMPSE5198)->E5_VALOR
							EndIf

							nPosNat := aScan(aTotais,{|x| x[1] == (cTMPSE5198)->E5_NATUREZ})

							If nPosNat > 0
								aTotais[nPosNat][3][1][2] += nBaixado
								aTotais[nPosNat][3][2][2] += nMovFin
								aTotais[nPosNat][3][3][2] += nCompensa
								aTotais[nPosNat][3][4][2] += nFatura
							Else
								aAux := {}
								aAdd(aAux, {"Baixados", nBaixado})    //Baixados
								aAdd(aAux, {"Mov. Fin", nMovFin	}) //Mov. Fin
								aAdd(aAux, {"Compensados", nCompensa})   //Compensados
								aAdd(aAux, {"Bx Fatura", nFatura})     //Bx Fatura
								aAdd(aTotais, {(cTMPSE5198)->E5_NATUREZ, (cTMPSE5198)->E5_NATPAI, aAux})
							EndIf
						EndIf
					Next nI
				EndIf

				(cAliasQry)->(dbSkip())
			EndDo

			(cAliasQry)->(dbClearIndex())
			(cAliasQry)->(dbCloseArea())
			MsErase(cAliasQry)

			If !Empty(cTmpFil)
				CtbTmpErase(cTmpFil)
			EndIf

			If oRegistro != Nil
				oRegistro:Destroy()
				oRegistro := Nil
			EndIf

			If oRatSev != Nil
				oRatSev:Destroy()
				oRatSev := Nil
			EndIf

			If oQryFk1 != Nil
				oQryFk1:Destroy()
				oQryFk1 := Nil
			EndIf

			If oQryFk2 != Nil
				oQryFk2:Destroy()
				oQryFk2 := Nil
			EndIf
		EndIf
	EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FTotNat

Totaliza as naturezas analíticas nas sintéticas

@param oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function FTotNat()

	Local aAux			:= {}
	Local aStruct		:= {}
	Local cNatureza		:= ""
	Local cQuery		:= ""
	Local cAliasQry1 	:= ""
	Local cAliasQry2 	:= ""
	Local lCreate		:= .F.
	Local nX			:= 0
	Local oTotais       := Nil
	Local cTblTot       := ""
	Local cSqlNat
	Local lAgrFil

	//Private cAliasNat := GetNextAlias()
	//BUSCA TOTALIZADOR POR NATUREZAS DA SERRANA
	//A cTMPSE5198 JA ESTA COM TODAS AS NATUREZAS DESTACADAS
	//SÓ PEGAR OS DADOS E AGRUPAR - ECONOMIZANDO ASSIM TEMPO E DESENVOLVIMENTO
	If MV_PAR38 == 1 .or. MV_PAR38 == 2 .or. MV_PAR38 == 5
		cSqlNat := "SELECT "

		//Agrupar por Filial?
		lAgrFil := IIF(MV_PAR37 == 1,.T.,.F.)
		If !lAgrFil
			cSqlNat += "E5_FILIAL, "
		EndIf

		cSqlNat += "ZZD_NIVEL, ZZD_DESCRI, E5_NATUREZ, ED_DESCRIC, SUM(E5_VALTIT) E5_VALORIG, "
		cSqlNat += "SUM(E5_VLJUROS) E5_VLJUROS, SUM(E5_VLMULTA) E5_VLMULTA, "
		cSqlNat += "SUM(E5_VLCORRE) E5_VLCORRE, SUM(E5_VLDESCO) E5_VLDESCO, "
		cSqlNat += "SUM(E5_ABATIM) E5_ABATIM, SUM(E5_IMPOSTO) E5_IMPOSTO, "
		cSqlNat += "SUM(E5_VALBX) E5_VALOR "
		cSqlNat += "FROM " + cTMPSE5198 + " "
		cSqlNat += "JOIN "+RetSqlName("SED")+" SED "
		cSqlNat += "ON "
		cSqlNat += "   SED.ED_FILIAL  = '"+xFilial("SED")+"' AND "
		cSqlNat += "   SED.ED_CODIGO  = E5_NATUREZ AND "
		cSqlNat += "   SED.D_E_L_E_T_ = ' ' "
		cSqlNat += "JOIN "+RetSqlName("ZZD")+" ZZD "
		cSqlNat += "ON "
		cSqlNat += "   ZZD.ZZD_FILIAL = '"+xFilial("ZZD")+"' AND "
		cSqlNat += "   ZZD.ZZD_COD    = SED.ED_YTIPAGE AND "
		cSqlNat += "   ZZD.D_E_L_E_T_ = ' ' "
		If !lAgrFil
			cSqlNat += "GROUP BY E5_FILIAL, ZZD_NIVEL, ZZD_DESCRI, E5_NATUREZ, ED_DESCRIC "
			cSqlNat += "ORDER BY E5_FILIAL, ZZD_NIVEL, ZZD_DESCRI, E5_NATUREZ"
		Else
			cSqlNat += "GROUP BY ZZD_NIVEL, ZZD_DESCRI, E5_NATUREZ, ED_DESCRIC "
			cSqlNat += "ORDER BY ZZD_NIVEL, ZZD_DESCRI, E5_NATUREZ"
		EndIf
		cSqlNat := ChangeQuery(cSqlNat)
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cSqlNat),cAliasNat,.F.,.T.)
		//FIM
	  //Endif

		/*
		Busca todas as naturezas sintéticas
		*/
		IF TCCANOPEN(cTMPSED198)
			MsErase(cTMPSED198)
		EndIf

		cQuery := "SELECT SED.ED_CODIGO,SED.ED_DESCRIC,SED.ED_PAI FROM "
		cQuery += RetSqlName("SED") + " SED "
		cQuery += "WHERE "
		cQuery += "SED.ED_FILIAL = '" + xFilial("SED") + "' AND "
		cQuery += "SED.ED_TIPO = '1' AND "
		cQuery += "SED.D_E_L_E_T_ = ' '	"

		cQuery += "ORDER BY ED_CODIGO DESC"

		cQuery := ChangeQuery(cQuery)
		cAliasQry1 := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry1,.F.,.T.)

		//Cria o arquivo temporário
		aAdd(aStruct,{"NATUREZA","C",TamSX3("ED_CODIGO")[1],TamSX3("ED_CODIGO")[2]})
		aAdd(aStruct,{"DESCNAT" ,"C",TamSX3("ED_DESCRIC")[1],TamSX3("ED_DESCRIC")[2]})
		aAdd(aStruct,{"NATPAI"	,"C",TamSX3("ED_CODIGO")[1],TamSX3("ED_CODIGO")[2]})
		aAdd(aStruct,{"VALORIG"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"VLJUROS"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"VLMULTA"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"VALCORR"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"VLDESCO"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"ABATIM"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"IMPOSTO"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"VALOR"	,"N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )
		aAdd(aStruct,{"NIVEL"	,"N",10,0})
		aAdd(aStruct,{"VALACESS","N",TamSx3("E5_VALOR")[1],TamSx3("E5_VALOR")[2]} )

		lCreate := MsCreate(cTMPSED198, aStruct, "TOPCONN")

		If lCreate
			dbUseArea(.T.,"TOPCONN",cTMPSED198,cTMPSED198,.T.,.F.)
			dbSelectArea(cTMPSED198)
			dbCreateIndex(cTMPSED198 + "i","NATUREZA", {|| "NATUREZA"})

			While !(cAliasQry1)->(Eof())
				RecLock(cTMPSED198,.T.)
				(cTMPSED198)->NATUREZA 	:= (cAliasQry1)->ED_CODIGO
				(cTMPSED198)->DESCNAT	:= (cAliasQry1)->ED_DESCRIC
				(cTMPSED198)->NATPAI 	:= (cAliasQry1)->ED_PAI
				(cTMPSED198)->(MsUnlock())

				//Prepara os totalizadores
				If ValType("aTotSint") <> "U"
					aAux := {}
					aAdd(aAux,{"Baixados"	,0	})
					aAdd(aAux,{"Mov. Fin"	,0	})
					aAdd(aAux,{"Compensados"	,0	})
					aAdd(aAux,{"Bx Fatura"	,0 	})

					aAdd(aTotSint,{(cAliasQry1)->ED_CODIGO,(cAliasQry1)->ED_PAI,aAux})
				EndIf

				(cAliasQry1)->(dbSkip())
			EndDo

			/*
			Busca na tabela temporária os registros pertecentes às analíticas
			*/
			For nX := 01 To Len(aTotais)
				If oTotais == Nil //Query agrupadora por Natureza
					cQuery := "SELECT "
					cQuery += "E5_NATUREZ, E5_NATDESC, E5_NATPAI, "
					cQuery += "SUM(E5_VALTIT) E5_VALORIG, "
					cQuery += "SUM(E5_VLJUROS) E5_VLJUROS, "
					cQuery += "SUM(E5_VLMULTA) E5_VLMULTA, "
					cQuery += "SUM(E5_VLCORRE) E5_VLCORRE, "
					cQuery += "SUM(E5_VLDESCO) E5_VLDESCO, "
					cQuery += "SUM(E5_ABATIM) E5_ABATIM,  "
					cQuery += "SUM(E5_IMPOSTO) E5_IMPOSTO, "
					cQuery += "SUM(E5_VALBX) E5_VALOR,    "
					cQuery += "SUM(VALACESS) VALACESS "
					cQuery += "FROM ? "
					cQuery += "WHERE E5_NATUREZ = ? "
					cQuery += "GROUP BY E5_NATUREZ, E5_NATDESC, E5_NATPAI "
					cQuery  := ChangeQuery(cQuery)
					oTotais := FWPreparedStatement():New(cQuery)
				EndIf

				oTotais:SetNumeric(1, cTMPSE5198)
				oTotais:SetString(2, aTotais[nX,01])
				cQuery  := oTotais:GetFixQuery()
				cTblTot := MpSysOpenQuery(cQuery)

				If (cTblTot)->(!Eof())
					dbSelectArea(cTMPSED198)

					If (RecLock(cTMPSED198,.T.)) //Criando novo registro totalizador
						(cTMPSED198)->NATUREZA 	:= (cTblTot)->E5_NATUREZ
						(cTMPSED198)->DESCNAT	:= (cTblTot)->E5_NATDESC
						(cTMPSED198)->NATPAI 	:= (cTblTot)->E5_NATPAI
						(cTMPSED198)->VALORIG	:= (cTblTot)->E5_VALORIG
						(cTMPSED198)->VLJUROS	:= (cTblTot)->E5_VLJUROS
						(cTMPSED198)->VLMULTA	:= (cTblTot)->E5_VLMULTA
						(cTMPSED198)->VALCORR	:= (cTblTot)->E5_VLCORRE
						(cTMPSED198)->VLDESCO	:= (cTblTot)->E5_VLDESCO
						(cTMPSED198)->ABATIM	:= (cTblTot)->E5_ABATIM
						(cTMPSED198)->IMPOSTO	:= (cTblTot)->E5_IMPOSTO
						(cTMPSED198)->VALOR		:= (cTblTot)->E5_VALOR
						(cTMPSED198)->VALACESS	+= (cTblTot)->VALACESS
						(cTMPSED198)->(MsUnlock())
					EndIf
				EndIf

				(cTblTot)->(DbCloseArea())
			Next nX

			//Busca na tabela temporária os registros pertecentes às sintéticas
			cQuery := "SELECT "
			cQuery += "E5_NATPAI, "
			cQuery += "SUM(E5_VALTIT) E5_VALORIG, "
			cQuery += "SUM(E5_VLJUROS) E5_VLJUROS, "
			cQuery += "SUM(E5_VLMULTA) E5_VLMULTA, "
			cQuery += "SUM(E5_VLCORRE) E5_VLCORRE, "
			cQuery += "SUM(E5_VLDESCO) E5_VLDESCO, "
			cQuery += "SUM(E5_ABATIM) E5_ABATIM,  "
			cQuery += "SUM(E5_IMPOSTO) E5_IMPOSTO, "
			cQuery += "SUM(E5_VALBX) E5_VALOR,    "
			cQuery += "SUM(VALACESS) VALACESS "
			cQuery += "FROM " + cTMPSE5198 + " "
			cQuery += "GROUP BY E5_NATPAI "

			cQuery := ChangeQuery(cQuery)
			cAliasQry2 := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry2,.F.,.T.)

			dbSelectArea(cTMPSED198)
			(cTMPSED198)->(dbSetOrder(1))

			While !(cAliasQry2)->(Eof())
				If (cTMPSED198)->(dbSeek((cAliasQry2)->E5_NATPAI))
					cNatureza := (cTMPSED198)->NATUREZA

					While cNatureza <> ""
						If (cTMPSED198)->(dbSeek(cNatureza))
							RecLock(cTMPSED198,.F.)
							(cTMPSED198)->VALORIG	+= (cAliasQry2)->E5_VALORIG
							(cTMPSED198)->VLJUROS	+= (cAliasQry2)->E5_VLJUROS
							(cTMPSED198)->VLMULTA	+= (cAliasQry2)->E5_VLMULTA
							(cTMPSED198)->VALCORR	+= (cAliasQry2)->E5_VLCORRE
							(cTMPSED198)->VLDESCO	+= (cAliasQry2)->E5_VLDESCO
							(cTMPSED198)->ABATIM	+= (cAliasQry2)->E5_ABATIM
							(cTMPSED198)->IMPOSTO	+= (cAliasQry2)->E5_IMPOSTO
							(cTMPSED198)->VALOR		+= (cAliasQry2)->E5_VALOR
							(cTMPSED198)->NIVEL		+= 1
							(cTMPSED198)->VALACESS	+= (cAliasQry2)->VALACESS
							(cTMPSED198)->(MsUnlock())

							//Controle de atualização das superiores imediatas
							cNatureza := (cTMPSED198)->NATPAI
						Else
							cNatureza := ""
						EndIf
					EndDo
				EndIf

				(cAliasQry2)->(dbSkip())
			EndDo

			dbSelectArea(cAliasQry2)
			(cAliasQry2)->(dbCloseArea())
			MsErase(cAliasQry2)

			If oTotais != Nil
				oTotais:Destroy()
				oTotais := Nil
			EndIf
		EndIf

		dbSelectArea(cAliasQry1)
		(cAliasQry1)->(dbCloseArea())
		MsErase(cAliasQry1)

		//Monta os totalizadores por natureza sintética
		FTotSint()
	Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FTotVal

Totaliza os valores de cada movimento

IMPORTANTE: Para utilização desta função deve ser utilizada somente para recompor os valores
deste relatório, uma vez que o alias utilizado é resultado de uma query que concatena 2 ou
mais tabelas

@param cAlias 	- Alias de referência
@param cCarteira 	- Carteira

@return aValores 	- Valores totalizados do movimento

/*/
//------------------------------------------------------------------------------------------
Static Function FTotVal(cAliasQry, cCarteira, oRatSev, oQryFk1, oQryFk2)

	Local aAreaSE1		:= {}
	Local aDados		:= {}
	Local aValMov		:= {}
	Local aValores		:= {}
	Local cQuery		:= ""
	Local nImposto		:= 0
	Local nTotAbImp		:= 0
	Local lMulNat		:= .F.
	Local lCancel		:= .F. //Registros cancelados serão impressos 2 vezes
	Local lPCCBaixa		:= .F.
	Local lIRRFBaixa	:= .F.
	Local lCalcIssBx	:= .F.
	Local nDecs			:= MsDecimais(mv_par20)
	Local nMoedaBx      := 0
	Local lTemRatio     := .F.
	Local cChaveSev     := ""
	Local cEvSeq        := "  "
	Local cEvIdent      := "1"
	Local cTmpSev       :=  ""

	Default cAliasQry := ""
	Default cCarteira := ""
	Default oRatSev   := Nil
	Default oQryFk1   := Nil
	Default oQryFk2   := Nil

	//IMPORTANTE:
	//Os cálculos feitos pela função serão efetuados considerando a moeda do movimento. A conversão na moeda do relatório será efetuada posteriormente.
	If !Empty(cAliasQry) .And. !Empty(cCarteira)
		aValMov := Array(9)
        /*
        aValMov: 
        [1] = Valor Original, [2] = Juros/Multa, [3] = Correção, [4] = Desconto, [5] = Amatimentos
        [6] = Impostos, [7] = Valor Baixado, [8] = Ult. Baixa?, [9] = Multa
        */

		aValMov[1] := (cAliasQry)->E5_VALOR
		nMoedaBx   := Val((cAliasQry)->E5_MOEDA)
		cCarteira  := AllTrim(cCarteira)

		If cCarteira == "R"
			If (cAliasQry)->E1_VALOR <> 0
				aValMov[1] := Round(NoRound(xMoeda((cAliasQry)->E1_VALOR, (cAliasQry)->E1_MOEDA, nMoedaBx, StoD((cAliasQry)->E1_EMISSAO), nDecs+1, (cAliasQry)->E1_TXMOEDA), nDecs+1), nDecs)
			EndIf

			aValMov[8] := SeqBxFKs("FK1", (cAliasQry)->E5_FILIAL, (cAliasQry)->E5_PREFIXO, (cAliasQry)->E5_NUMERO, (cAliasQry)->E5_PARCELA,;
				(cAliasQry)->E5_TIPO, (cAliasQry)->E5_CLIFOR, (cAliasQry)->E5_LOJA, @oQryFk1, Nil)
		Else
			If (cAliasQry)->E2_VALOR <> 0
				aValMov[1] := Round(NoRound(xMoeda((cAliasQry)->E2_VALOR,(cAliasQry)->E2_MOEDA, nMoedaBx, StoD((cAliasQry)->E2_EMISSAO), nDecs+1, (cAliasQry)->E2_TXMOEDA), nDecs+1), nDecs)
			EndIf

			aValMov[8] := SeqBxFKs("FK2", (cAliasQry)->E5_FILIAL, (cAliasQry)->E5_PREFIXO, (cAliasQry)->E5_NUMERO, (cAliasQry)->E5_PARCELA,;
				(cAliasQry)->E5_TIPO, (cAliasQry)->E5_CLIFOR, (cAliasQry)->E5_LOJA, Nil, @oQryFk2)
		EndIf

		lCancel    := (cAliasQry)->E5_SITUACA == "C"
		aValMov[2] := (cAliasQry)->E5_VLJUROS
		aValMov[9] := (cAliasQry)->E5_VLMULTA
		aValMov[3] := (cAliasQry)->E5_VLCORRE
		aValMov[4] := (cAliasQry)->E5_VLDESCO
		aValMov[5] := 0

		If (cAliasQry)->E5_SEQ == aValMov[8]
			If cCarteira == "R"
				//Posiciona no registro da SE1 para auxílio do cálculo
				dbSelectArea("SE1")
				aAreaSE1:= SE1->(GetArea())
				SE1->(dbSetOrder(2))
				SE1->(dbSeek((cAliasQry)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
				aValMov[5] := SumAbatRec((cAliasQry)->E5_PREFIXO, (cAliasQry)->E5_NUMERO, (cAliasQry)->E5_PARCELA, /*Moeda*/, "V", (cAliasQry)->E5_DATA, @nTotAbImp)
				SE1->(RestArea(aAreaSE1))
			Else
				aValMov[5] := SomaAbat((cAliasQry)->E5_PREFIXO, (cAliasQry)->E5_NUMERO, (cAliasQry)->E5_PARCELA, cCarteira, /*Moeda*/, ,(cAliasQry)->E5_CLIFOR, (cAliasQry)->E5_LOJA)
			EndIf
		EndIf

		If cPaisLoc == "BRA"
			If cCarteira == "R"
				lPCCBaixa 	:= FPccBxCr()
				lIRRFBaixa	:= FIrPjBxCr()
				lCalcIssBx  := SuperGetMv("MV_MRETISS", .F., "1") == "2" .And. !Empty(SE1->(FieldPos( "E1_TRETISS")))  //Retencao do ISS pela emissao (1) ou baixa (2)
			Else
				lPCCBaixa  := SuperGetMv("MV_BX10925",.T.,"2") == "1"
				lIRRFBaixa := (Posicione("SA2", 1, xFilial("SA2") + (cAliasQry)->(E2_FORNECE+E2_LOJA), "A2_CALCIRF") == "2") .And. ;
					(Posicione("SED", 1, xfilial("SED") + (cAliasQry)->(E2_NATUREZ), "ED_CALCIRF") = "S")
				lCalcIssBx := SuperGetMv("MV_MRETISS",.F.,"1") == "2"
			EndIf

			nImposto := 0

			If cCarteira == "R"
				//PCC
				If lPCCBaixa .And. Empty((cAliasQry)->E5_PRETPIS) .And. Empty((cAliasQry)->E5_PRETCOF) .And. Empty((cAliasQry)->E5_PRETCSL)
					nImposto += (cAliasQry)->E5_VRETPIS + (cAliasQry)->E5_VRETCOF + (cAliasQry)->E5_VRETCSL
				EndIf
				//IRRF
				If lIRRFBaixa
					nImposto += (cAliasQry)->E5_VRETIRF
				EndIf
				//ISS
				If lCalcIssBx
					nImposto += (cAliasQry)->E5_VRETISS
				EndIf
				//Abatimentos de Impostos
				If (cAliasQry)->E5_SEQ == aValMov[8]
					nImposto   += nTotAbImp
					aValMov[5] -= nTotAbImp //Desconta dos abatimentos o valor que for refente à impostos
				EndIf
			Else
				//PCC
				If lPCCBaixa .And. Empty((cAliasQry)->E5_PRETPIS) .And. Empty((cAliasQry)->E5_PRETCOF) .And. Empty((cAliasQry)->E5_PRETCSL)
					nImposto += (cAliasQry)->E5_VRETPIS + (cAliasQry)->E5_VRETCOF + (cAliasQry)->E5_VRETCSL
				EndIf
				//IR
				If lIRRFBaixa
					nImposto += (cAliasQry)->E5_VRETIRF
				EndIf
				//ISS
				If lCalcIssBx
					nImposto += (cAliasQry)->E5_VRETISS
				EndIf
			EndIf
		Else

			nImposto := 0

			dbSelectArea("SFE")
			SFE->(dbGoTop())

			If cCarteira == "P"
				SFE->(dbSetOrder(2)) //FILIAL + ORDEM DE PAGO
			Else
				SFE->(dbSetOrder(6)) //FILIAL + RECIBO
			EndIf

			If SFE->(dbSeek(xFilial("SFE")+(cAliasQry)->E5_ORDREC))

				While !SFE->(Eof()) .And. SFE->FE_FILIAL == xFilial("SFE") .And.;
						((cCarteira == "P" .And. SFE->FE_ORDPAGO == (cAliasQry)->E5_ORDREC).Or.;
						(cCarteira == "R" .And. SFE->FE_RECIBO == (cAliasQry)->E5_ORDREC))

					nImposto += SFE->FE_RETENC
					SFE->(dbSkip())
				EndDo

			EndIf

		EndIf

		aValMov[6] := nImposto
		aValMov[7] := (cAliasQry)->E5_VALOR

		//Valida se há rateio multinatureza
		If MV_MULNATP
			If cCarteira == "R" .And. ((cAliasQry)->E1_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1")
				lMulNat := .T.
			ElseIf cCarteira == "P" .And. ((cAliasQry)->E2_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1")
				lMulNat := .T.
			EndIf

			If lMulNat
				dbSelectArea("SEV")
				SEV->(dbSetOrder(2))
				cChaveSev := xFilial("SEV")+(cAliasQry)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)

				If SEV->(dbSeek(cChaveSev+"2"+(cAliasQry)->E5_SEQ)) //Pela distribuição da baixa
					lTemRatio := .T.
					cEvIdent  := "2"
					cEvSeq    := (cAliasQry)->E5_SEQ
				ElseIf SEV->(dbSeek(cChaveSev+"1")) //Pela distribuição do título
					lMultNat  := .T.
					lTemRatio := .T.
				EndIf

				If lTemRatio
					If oRatSev == Nil
						cQuery := "SELECT * FROM " + RetSqlName("SEV") + " SEV WHERE "
						cQuery += "SEV.EV_FILIAL = ? "
						cQuery += "AND SEV.EV_PREFIXO = ? "
						cQuery += "AND SEV.EV_NUM = ? "
						cQuery += "AND SEV.EV_PARCELA = ? "
						cQuery += "AND SEV.EV_TIPO = ? "
						cQuery += "AND SEV.EV_CLIFOR = ? "
						cQuery += "AND SEV.EV_LOJA = ? "
						cQuery += "AND SEV.EV_NATUREZ BETWEEN ? AND ? "
						cQuery += "AND SEV.EV_IDENT = ? "
						cQuery += "AND SEV.EV_SEQ = ? "
						cQuery += "AND SEV.D_E_L_E_T_ = ' ' "
						cQuery  := ChangeQuery(cQuery)
						oRatSev := FWPreparedStatement():New(cQuery)
					EndIf

					oRatSev:SetString(1,  xFilial("SEV") )
					oRatSev:SetString(2,  (cAliasQry)->E5_PREFIXO)
					oRatSev:SetString(3,  (cAliasQry)->E5_NUMERO)
					oRatSev:SetString(4,  (cAliasQry)->E5_PARCELA)
					oRatSev:SetString(5,  (cAliasQry)->E5_TIPO)
					oRatSev:SetString(6,  (cAliasQry)->E5_CLIFOR)
					oRatSev:SetString(7,  (cAliasQry)->E5_LOJA)
					oRatSev:SetString(8,  mv_par07)
					oRatSev:SetString(9,  mv_par08)
					oRatSev:SetString(10, cEvIdent)
					oRatSev:SetString(11, cEvSeq)
					cQuery  := oRatSev:GetFixQuery()
					cTmpSev := MpSysOpenQuery(cQuery)

					If (cTmpSev)->(Eof())
						(cTmpSev)->(DbCloseArea())
						cTmpSev := ""
					EndIf
				EndIf
			EndIf
		EndIf

		If !Empty(cTmpSev)
			While (cTmpSev)->(!Eof())
				aDados     := Array(11)
				aDados[1]  := (cTmpSev)->EV_NATUREZ			//NATUREZA
				aDados[2]  := aValMov[1] * (cTmpSev)->EV_PERC	//VALOR ORIGINAL
				aDados[3]  := aValMov[2] * (cTmpSev)->EV_PERC	//JUROS
				aDados[4]  := aValMov[3] * (cTmpSev)->EV_PERC	//CORREÇÃO
				aDados[5]  := aValMov[4] * (cTmpSev)->EV_PERC	//DESCONTO
				aDados[6]  := aValMov[5] * (cTmpSev)->EV_PERC	//ABATIMENTO
				aDados[7]  := aValMov[6] * (cTmpSev)->EV_PERC	//IMPOSTO
				aDados[8]  := aValMov[7] * (cTmpSev)->EV_PERC	//BAIXADO
				aDados[9]  := aValMov[8]							//ULT. BAIXA
				aDados[10] := aValMov[9] * (cTmpSev)->EV_PERC	//MULTA
				aDados[11] := .F.								//CANCELAMENTO

				aAdd(aValores, AClone(aDados))
				FwFreeArray(aDados)

				//Gera o movimento inverso do cancelamento
				If lCancel
					aDados     := Array(11)
					aDados[1]  := (cTmpSev)->EV_NATUREZ					//NATUREZA
					aDados[2]  := (aValMov[1] * (cTmpSev)->EV_PERC) * (-1)	//VALOR ORIGINAL
					aDados[3]  := (aValMov[2] * (cTmpSev)->EV_PERC) * (-1)	//JUROS
					aDados[4]  := (aValMov[3] * (cTmpSev)->EV_PERC) * (-1)	//CORREÇÃO
					aDados[5]  := (aValMov[4] * (cTmpSev)->EV_PERC) * (-1)	//DESCONTO
					aDados[6]  := (aValMov[5] * (cTmpSev)->EV_PERC) * (-1)	//ABATIMENTO
					aDados[7]  := (aValMov[6] * (cTmpSev)->EV_PERC) * (-1)	//IMPOSTO
					aDados[8]  := (aValMov[7] * (cTmpSev)->EV_PERC) * (-1)	//BAIXADO
					aDados[9]  :=  aValMov[8]								//ULT. BAIXA
					aDados[10] := (aValMov[9] * (cTmpSev)->EV_PERC) * (-1)	//MULTA
					aDados[11] := .T.										//CANCELAMENTO

					aAdd(aValores, AClone(aDados))
					FwFreeArray(aDados)
				EndIf

				(cTmpSev)->(DbSkip())
			EndDo
		Else
			aDados     := Array(11)
			aDados[1]  := (cAliasQry)->E5_NATUREZ	//NATUREZA
			aDados[2]  := aValMov[1]					//VALOR ORIGINAL
			aDados[3]  := aValMov[2]					//JUROS/MULTA
			aDados[4]  := aValMov[3]					//CORREÇÃO
			aDados[5]  := aValMov[4]					//DESCONTO
			aDados[6]  := aValMov[5]					//ABATIMENTO
			aDados[7]  := aValMov[6]					//IMPOSTO
			aDados[8]  := aValMov[7]					//BAIXADO
			aDados[9]  := aValMov[8]					//ULT. BAIXA
			aDados[10] := aValMov[9]					//MULTA
			aDados[11] := .F.						//CANCELAMENTO

			aAdd(aValores, AClone(aDados))
			FwFreeArray(aDados)

			//Gera o movimento inverso do cancelamento
			If lCancel
				aDados     := Array(11)
				aDados[1]  := (cAliasQry)->E5_NATUREZ	//NATUREZA
				aDados[2]  := aValMov[1] * (-1)			//VALOR ORIGINAL
				aDados[3]  := aValMov[2] * (-1)			//JUROS
				aDados[4]  := aValMov[3] * (-1)			//CORREÇÃO
				aDados[5]  := aValMov[4] * (-1)			//DESCONTO
				aDados[6]  := aValMov[5] * (-1)			//ABATIMENTO
				aDados[7]  := aValMov[6] * (-1)			//IMPOSTO
				aDados[8]  := aValMov[7] * (-1)			//BAIXADO
				aDados[9]  := aValMov[8]					//ULT. BAIXA
				aDados[10] := aValMov[9] * (-1)			//MULTA
				aDados[11] := .T.						//CANCELAMENTO

				aAdd(aValores, AClone(aDados))
				FwFreeArray(aDados)
			EndIf
		EndIf
	EndIf

	FwFreeArray(aAreaSE1)
	FwFreeArray(aValMov)

Return aValores

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FTotSint

Totaliza os movimentos para as naturezas sintéticas

@Param oReport	- Objeto do Relatório
@Param cNatureza	- Natureza a ser impressa o totalizador

/*/
//------------------------------------------------------------------------------------------
Static Function FTotSint()

	Local nX			:= 0
	Local nY			:= 0
	Local cNatureza 	:= ""
	Local nPosNat		:= ""

	If ValType("aTotais") <> "U" .And. ValType("aTotSint") <> "U"
		For nX := 1 to Len(aTotais)

			cNatureza := aTotais[nX][2]

			While cNatureza <> ""

				nPosNat := aScan(aTotSint,{|x| x[1] == cNatureza})

				If nPosNat > 0
					For nY:= 1 to Len(aTotSint[nPosNat][3])
						aTotSint[nPosNat][3][nY][2] += aTotais[nX][3][nY][2]
					Next nY

					cNatureza := aTotSint[nPosNat][2]
				Else
					cNatureza := ""
				EndIf

			EndDo
		Next nX
	EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIncTot

Impressão de totalizadores

@param oReport	- Objeto do Relatório
@param cNatureza	- Natureza a ser impressa o totalizador
@param cTotaliz	- Array que contém o totalizador

/*/
//------------------------------------------------------------------------------------------
Static Function FIncTot(oReport,cNatureza,cTotaliz)

	Local aTotalNat	:= {}
	Local nX		:= 0
	Local nPosNat	:= 0
	Local nValor	:= 0
	Local nDecs		:= MsDecimais(mv_par20)
	Local nFator	:= 1

	DEFAULT oReport		:= Nil
	DEFAULT cNatureza	:= ""
	DEFAULT cTotaliz	:= ""

	If ValType(cTotaliz) <> "U"

		aTotalNat := &cTotaliz

		nPosNat := aScan(aTotalNat,{|x| x[1] == cNatureza})

		If nPosNat > 0
			For nX := 1 to Len(aTotalNat[nPosNat][3])
				If aTotalNat[nPosNat][3][nX][2] <> 0

					If aTotalNat[nPosNat][3][nX][2] < 0
						nFator := -1
					Else
						nFator := 1
					EndIf

					nValor := aTotalNat[nPosNat][3][nX][2] * nFator

					oReport:PrintText( PadR(aTotalNat[nPosNat][3][nX][1]+": ",15),oReport:nRow )
					If nFator < 0
						oReport:PrintText("("+Transform(nValor, tm(nValor,20,nDecs))+")",oReport:nRow )
					Else
						oReport:PrintText( Transform(nValor, tm(nValor,20,nDecs)),oReport:nRow )
					EndIf
					oReport:SkipLine(1)
				EndIf
			Next nX
		EndIf

	EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FVldBx

Valida os motivos de baixa e/ou tipo do doc. do movimento.

IMPORTANTE: Para validação dos dados, o registro deve estar posicionado.

@param cAlias - Alias em que os dados devem ser validados

@return lRet - Resultado da validação do movimento

/*/
//------------------------------------------------------------------------------------------
Static Function FVldBx(cAlias)

	Local lRet := .T.

	Default cAlias := ""

	If !Empty(cAlias)
		If (cAlias)->E5_MOTBX == "CMP"
			lRet := .F.
		ElseIf !Empty((cAlias)->E5_MOTBX) .And. !MovBcoBx((cAlias)->E5_MOTBX)
			lRet := .F.
		ElseIf (cAlias)->E5_SITUACA == "C"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FK6Calc
Calcula as tabelas da FK6

@param cTabOrig, caracters, Tabela de Origem da SE5
@param cIdOrig , caracters, Chave de Origem da Tabela SE5
@param cTipo   , caracters, O tipo de Documento
/*/
//-------------------------------------------------------------------
Static Function FK6Calc(cTabOrig,cIdOrig,cTipo)

	Local nRet  := 0

	If ExistFunc('FXLOADFK6')
		nRet := FXLOADFK6(cTabOrig,cIdOrig,'VA')[1][2]
	Else
		nRet := 0
	EndIf

	If cTipo == 'ES'

		nRet *= -1

	EndIf

Return nRet

