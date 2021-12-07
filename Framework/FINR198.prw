#include 'TOTVS.CH'
#include 'FINR198.CH'

Static lIsIssBx   := FindFunction("IsIssBx")
Static cTMPSE5198 := "TMPSE5198"
Static cTMPSED198 := "TMPSED198"
Static lExistFKD

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINR198
Relação de baixas por natureza

@author Marcos Berto
@since 07/01/2013
@version 12
/*/
//------------------------------------------------------------------------------------------
User Function AFINR198()
Local oReport
Local lNatSint		:= SuperGetMV( 'MV_NATSINT', .F., '2' ) == '1'

If !lNatSint
	Help( , , 'MV_NATSINT', , "STR0040" + CRLF + "STR0041" + CRLF + "STR0042", 1, 0 )
EndIf

oReport := ReportDef()
oReport:PrintDialog()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Definição da estrutura do relatório
	Primeira sessão - Dados dos títulos
	Segunda sessão - Totalizador pelas sintéticas

@author    Marcos Berto
@version   11.80
@since     07/01/13

@return oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef()
Local nX		:= 0
Local nPosFim	:= 0
Local nPosNat	:= 0
Local nTam		:= 0
Local oSecTit
Local oSecTot
Local oReport
//GESTAO - inicio
Local oSecFil	:= Nil
//GESTAO - fim

If lExistFKD == Nil
	lExistFKD := TableInDic('FKD')
Endif

oReport:= TReport():New("FINR198",STR0002,"FIN198",{|oReport| ReportPrint(oReport)},STR0002) //"Relação de Baixas por Natureza"
oReport:SetLandscape(.T.)

//GESTAO - inicio
oReport:SetUseGC(.F.)
//GESTAO - fim

dbSelectArea("SE2")

oSecTit := TRSection():New(oReport,STR0003 /*"Movimentos"*/)

TRCell():New(oSecTit,"PREFIXO"	,,STR0015 /*"Prf"	*/				,PesqPict("SE5","E5_PREFIXO")	,TamSX3("E5_PREFIXO")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"NUMERO"	,,STR0016 /*"Numero"*/				,PesqPict("SE5","E5_NUM")		,TamSX3("E5_NUMERO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"PARCELA"	,,STR0017 /*"Prc"*/					,PesqPict("SE5","E5_PARCELA")	,TamSX3("E5_PARCELA")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"TIPO"		,,STR0018 /*"Tp"	*/				,PesqPict("SE5","E5_TIPO")		,TamSX3("E5_TIPO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"CLIFOR"	,,STR0019 /*"Cli/For"*/				,PesqPict("SE5","E5_CLIFOR")	,TamSX3("E5_FORNECE")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"LOJA"		,,STR0020 /*"Lj"*/					,PesqPict("SE5","E5_LOJA")		,TamSX3("E5_LOJA")[1]	,.F.,,,,,,,.F.)

TRCell():New(oSecTit,"NOME"		,,STR0021 /*"Nome"*/				,PesqPict("SE2","E2_NOMFOR")	,15						,.F.,,,.T.,,,,.F.)
TRCell():New(oSecTit,"VENCTO"	,,STR0022 /*"Vencto"*/				,PesqPict("SE5","E5_VENCTO")	,10						,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"DTDIGIT"	,,STR0023 /*"Dt.Dig."*/				,PesqPict("SE5","E5_DTDIGIT")	,10						,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"BAIXA"	,,STR0024 /*"Baixa"*/				,PesqPict("SE5","E5_DATA")		,10						,.F.,,,,,,,.F.)

TRCell():New(oSecTit,"HIST"		,,STR0025 /*"Historico"*/			,PesqPict("SE5","E5_HIST")		,25						,.F.,,,.T.,,,,.F.)
TRCell():New(oSecTit,"VALORIG"	,,STR0004 /*"Valor Orig"*/			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"JURMUL"	,,STR0005 /*"Juros/Multa"*/			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
If lExistFKD 
	TRCell():New(oSecTit,"VALACESS"	,,STR0039 /*"Valores Acessorios"*/	,PesqPict("SE5","E5_VALOR")	,TamSX3("FKD_VLCALC")[1],.F.,,,,,,,.F.)
EndIf
TRCell():New(oSecTit,"VALCORR"	,,STR0006 /*"Correção"*/			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"DESCONT"	,,STR0007 /*"Desconto"*/			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"ABATIM"	,,STR0008 /*"Abatimento"*/			,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"IMPOSTO"	,,STR0009 /*"Imposto"*/				,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"BAIXADO"	,,STR0010 /*"Total Baixado"*/		,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"BANCO"	,,STR0026 /*"Bco"	*/				,PesqPict("SE5","E5_BANCO")		,TamSX3("E5_BANCO")[1]	,.F.,,,,,,,.F.)

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
oSecTot := TRSection():New(oReport,STR0011 /*Totais*/,,,,,,,,,,,,,,.F.)

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

//GESTAO - inicio
//Relacao das filiais selecionadas para compor o relatorio
oSecFil := TRSection():New(oReport,"SECFIL",{"SE1","SED"})
TRCell():New(oSecFil,"CODFIL",,STR0034,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)		//"Código"
TRCell():New(oSecFil,"EMPRESA",,STR0035,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	//"Empresa"
TRCell():New(oSecFil,"UNIDNEG",,STR0036,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	//"Unidade de negócio"
TRCell():New(oSecFil,"NOMEFIL",,STR0037,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	//"Filial"
//GESTAO - fim

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressão do relatório

@author    Marcos Berto
@version   11.80
@since     27/12/12

@param oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local bVlOrig		:= Nil
Local bVlBxd		:= Nil
Local cNatPai		:= ""
Local cNatureza		:= ""
Local cDescricao	:= ""
Local nHandle		:= 0
Local oSecTit		:= oReport:Section(1)
Local oSecTot		:= oReport:Section(2)
Local oBreak		:= Nil
Local oVlOrig		:= Nil
Local oVlBxd		:= Nil
//GESTAO - inicio
Local aSelFil		:= {}
Local nRegSM0		:= 0 
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
//GESTAO - fim
Local cCodNat		:= ""
PRIVATE  aTotais	:= {}
PRIVATE  aTotSint	:= {}

If lExistFKD == Nil
	lExistFKD := TableInDic('FKD')
Endif

//Força preenchimento dos parametros mv_parXX
Pergunte("FIN198",.F.)

//GESTAO - inicio
If MV_PAR36 == 1
	nRegSM0 := SM0->(Recno())
	
	If lSE5Access	//filial nao totalmente compartilhada
		If lGestao
			If FindFunction("FwSelectGC")
				aSelFil := FwSelectGC()
			Else
				aSelFil := AdmGetFil(.F.,.F.,"SE5")
			EndIf
		Else		// Se nao for gestao, usa AdmGetFil()
			aSelFil := AdmGetFil(.F.,.F.,"SE5")
		EndIf
	EndIf
EndIf

If !LockByName("FINR198SE5",.T.,.F.)
	cTMPSE5198 := GetNextAlias()
EndIf

If !LockByName("FINR198SED",.T.,.F.)
	cTMPSED198 := GetNextAlias()
EndIf

If Empty(aSelFil)
	Aadd(aSelFil,cFilAnt)
EndIf

//GESTAO - fim
//Alimenta o arquivo temporário
F198GerTrb(@aSelFil)		
//GESTAO
	
//Totaliza por natureza
F198TotNat()

//GESTAO - inicio
//imprime a lista de filiais selecionadas para o relatorio
If Len(aSelFil) > 1 .And. !((cTMPSE5198)->(Eof()))
	oSecTit:SetHeaderSection(.F.)
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " (" + STR0038 + ")") //"Filiais selecionadas para o relatorio"
	nTamTit := Len(oReport:Title())
	oSecFil:Init()  
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})
	For nX := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nX]})
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
//GESTAO - fim

//Impressão dos dados
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
	oSecTit:Cell("VALACESS"):SetBlock({|| FK6Calc((cTMPSE5198)->E5_TABORI,(cTMPSE5198)->E5_IDORIG,(cTMPSE5198)->E5_TIPODOC) })
EndIf
oSecTit:Cell("VALCORR"):SetBlock({|| (cTMPSE5198)->E5_VLCORRE })
oSecTit:Cell("DESCONT"):SetBlock({|| (cTMPSE5198)->E5_VLDESCO })
oSecTit:Cell("ABATIM"):SetBlock({|| (cTMPSE5198)->E5_ABATIM })
oSecTit:Cell("IMPOSTO"):SetBlock({|| (cTMPSE5198)->E5_IMPOSTO })
oSecTit:Cell("BAIXADO"):SetBlock({|| (cTMPSE5198)->E5_VALOR })
oSecTit:Cell("BANCO"):SetBlock({|| (cTMPSE5198)->E5_BANCO })
	
oSecTot:Cell("VALORIG"):SetBlock({||(cTMPSED198)->VALORIG})
oSecTot:Cell("JURMUL"):SetBlock({||(cTMPSED198)->VLJUROS+(cTMPSED198)->VLMULTA})
oSecTot:Cell("VALCORR"):SetBlock({||(cTMPSED198)->VALCORR})
oSecTot:Cell("DESCONT"):SetBlock({||(cTMPSED198)->VLDESCO}	)
oSecTot:Cell("ABATIM"):SetBlock({||(cTMPSED198)->ABATIM})
oSecTot:Cell("IMPOSTO"):SetBlock({||(cTMPSED198)->IMPOSTO})
oSecTot:Cell("BAIXADO"):SetBlock({||(cTMPSED198)->VALOR})
	
//Regras para soma do valor Original
bVlOrig := {|| (cTMPSE5198)->E5_ULTBX == "S" .And. F198VldBx(cTMPSE5198) }
bVlBxd := {|| F198VldBx(cTMPSE5198) }
	
//Configura as quebras
oBreak := TRBreak():New(oSecTit,{|| (cTMPSE5198)->E5_NATUREZ+(cTMPSE5198)->E5_NATPAI },{|| STR0012+MascNat(cNatureza,,, "")+" "+cDescricao}) /*TOTAL DA NATUREZA ANALÍTICA*/
oVlOrig := TRFunction():New(oSecTit:Cell("VALORIG")	,"","SUM",oBreak,,,,.F.,.F.)
oVlOrig:SetCondition(bVlOrig)
TRFunction():New(oSecTit:Cell("JURMUL")	,"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSecTit:Cell("VALCORR")	,"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSecTit:Cell("DESCONT")	,"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSecTit:Cell("ABATIM")	,"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSecTit:Cell("IMPOSTO")	,"","SUM",oBreak,,,,.F.,.F.)
If lExistFKD 
	TRFunction():New(oSecTit:Cell("VALACESS"),/*[cID*/, "SUM", oBreak , , , /*[ uFormula ]*/ , .F., .F.,) 
EndIf
oVlBxd := TRFunction():New(oSecTit:Cell("BAIXADO")	,"","SUM",oBreak,,,,.F.,.F.)
oVlBxd:SetCondition(bVlBxd)
oBreak:OnPrintTotal({ || F198IncTot(oReport,cNatureza,"aTotais") })
	
While !(cTMPSE5198)->(Eof())
	cNatPai := (cTMPSE5198)->E5_NATPAI
	cCodNat := (cTMPSE5198)->E5_NATUREZ
	oSecTit:Init()
	
	While (cTMPSE5198)->E5_NATPAI == cNatPai .And. !(cTMPSE5198)->( Eof() )
		oSecTit:PrintLine()
		oReport:IncMeter()
		cNatureza  := (cTMPSE5198)->E5_NATUREZ	
		cDescricao := (cTMPSE5198)->E5_NATDESC
		(cTMPSE5198)->(dbSkip())
	EndDo
	
	oSecTit:Finish()
		
	dbSelectArea(cTMPSED198)
	(cTMPSED198)->(dbGoTop())
			
	While cNatPai <> ""
		If (cTMPSED198)->(dbSeek(cNatPai))
			//Só imprime o totalizador da sintética no último nível
			If 	(cTMPSED198)->NIVEL == 1		
				oSecTot:Init()
				oSecTot:Cell("TITULO"):SetTitle( STR0013 + MascNat( (cTMPSED198)->NATUREZA,,,"") + " " + (cTMPSED198)->DESCNAT ) //TOTAL DA NATUREZA SINTÉTICA
				oSecTot:PrintLine()	
				oSecTot:Finish()		
					
				F198IncTot( oReport, (cTMPSED198)->NATUREZA, "aTotSint" )
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
						
		(cTMPSED198)->(dbSkip())	
	EndDo						
EndDo

(cTMPSE5198)->(dbCloseArea())	
(cTMPSED198)->(dbCloseArea())	
MsErase(cTMPSE5198)
MsErase(cTMPSED198)		

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F198GerTrb

Gera o arquivo temporário

@author    Marcos Berto
@version   11.80
@since     27/12/12

@param oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function F198GerTrb(aSelFil)
Local aAux			:= {}
Local aStruct		:= {}
Local aValores		:= {}
Local aAreaSE5		:= {}
Local cCposQry		:= ""
Local cCampo		:= ""
Local cTipoIn		:= ""
Local cTipoOut		:= ""
Local cSituacao		:= ""
Local cQuery		:= ""
Local cCarteira		:= ""
Local cAliasQry		:= ""
Local cAliasSEV		:= ""
Local cChaveCH		:= ""
Local cTpSel		:= ""
Local cTpBusc		:= ""
Local dDtReaj		:= dDataBase
Local lCreate		:= .F.
Local nX			:= 0
Local nI			:= 0
Local nDecs			:= 0
Local nTaxa			:= 0
Local nHandle		:= 0
Local nFator		:= 1
Local nMoedOrig		:= 1
Local nBaixado		:= 0
Local nMovFin		:= 0
Local nCompensa		:= 0
Local nFatura		:= 0
Local nPosNat		:= 0
Local nPosNatPai	:= 0
Local lMulNat		:= .F.
Local lEncCH		:= .F.
Local cQuery2 		:= ''
Local cAliasTOT		:= ''
Local nReg			:= ''
//GESTAO - inicio
Local cTmpFil		:= ""
//GESTAO - fim
Local cDBName		:= Alltrim(Upper(TCGetDB()))
Local nAux			:= 0
Local nResto		:= 0

Private dBaixa	:= dDataBase

/****************************************
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
mv_par13 - Da Data Digitacao ?
mv_par14 - Ate a Data Digitacao ?
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
*****************************************/

nDecs := MsDecimais(mv_par20)

cCarteira := Iif(mv_par19 = 1,"R","P")

/*****************************
 Seleção de Movimentos
******************************/
IF TCCANOPEN(cTMPSE5198)
	MsErase(cTMPSE5198)
EndIf

cCposQry := ""

DbSelectArea("SE5")
aEval(SE5->(dbStruct()),{|e| cCposQry += ","+AllTrim(e[1])})

If cCarteira == "R"
	cCposQry += ",E1_FILIAL"
	cCposQry += ",E1_CLIENTE"
	cCposQry += ",E1_LOJA"
	cCposQry += ",E1_PREFIXO"
	cCposQry += ",E1_NUM"
	cCposQry += ",E1_PARCELA"
	cCposQry += ",E1_TIPO"
	cCposQry += ",E1_NATUREZ"
	cCposQry += ",E1_NOMCLI"
	cCposQry += ",E1_TXMOEDA"
	cCposQry += ",E1_MOEDA"
	cCposQry += ",E1_MULTNAT"
	cCposQry += ",E1_VENCTO"
	cCposQry += ",E1_SITUACA"
	cCposQry += ",E1_VALOR"
	cCposQry += ",E1_EMISSAO"
Else
	cCposQry += ",E2_FILIAL"
	cCposQry += ",E2_FORNECE"
	cCposQry += ",E2_LOJA"
	cCposQry += ",E2_PREFIXO"
	cCposQry += ",E2_NUM"
	cCposQry += ",E2_PARCELA"
	cCposQry += ",E2_TIPO"
	cCposQry += ",E2_NATUREZ"
	cCposQry += ",E2_NOMFOR"
	cCposQry += ",E2_TXMOEDA"
	cCposQry += ",E2_MOEDA"
	cCposQry += ",E2_MULTNAT"
	cCposQry += ",E2_VENCTO"
	cCposQry += ",E2_VALOR"
	cCposQry += ",E2_EMISSAO"
EndIf

cCposQry += ",ED_FILIAL"
cCposQry += ",ED_CODIGO"
cCposQry += ",ED_DESCRIC"
cCposQry += ",ED_PAI"

cQuery := "SELECT "+SubStr(cCposQry,2)+" FROM "
cQuery += 		RetSqlName("SE5") + " SE5 " 

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

cQuery += "LEFT OUTER JOIN "+ RetSqlName("SED") +" SED ON "
cQuery += "(SED.ED_CODIGO = SE5.E5_NATUREZ "
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
cQuery += "AND SED.D_E_L_E_T_ = ' ' ) "

cQuery += "WHERE "
 
//GESTAO - inicio
If mv_par36 == 1	// Seleciona Filiais
	cQuery += "(SE5.E5_FILORIG " + GetRngFil(aSelFil,"SE5",.T., @cTmpFil) + " OR "
	cQuery += "SE5.E5_FILIAL " + GetRngFil(aSelFil,"SE5",.T., @cTmpFil) + ") AND "
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
cQuery += "SE5.E5_DTDIGIT BETWEEN '" + DtoS(mv_par13)+ "' AND '"+ DtoS(mv_par14) + "' AND "
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

//Cria o arquivo temporário
lCreate := MsCreate(cTMPSE5198,aStruct,"TOPCONN")	
	
If lCreate
	dbUseArea(.T.,"TOPCONN",cTMPSE5198,cTMPSE5198,.T.,.F.)
	dbSelectArea(cTMPSE5198)
	dbCreateIndex(cTMPSE5198 + "i","E5_NATPAI+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA+E5_SEQ", {|| "E5_NATPAI+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA+E5_SEQ"})
	
	//Grava o retorno no arquivo temporário
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	
	While !(cAliasQry)->(Eof())
	
		/**********************************
		 Valida se imprime os movimentos
		***********************************/		
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
			If mv_par32 = 2 .And. (cAliasQry)->E5_TIPO $ MV_CPNEG+"|"+MVPAGANT+"|"+MV_CRNEG+"|"+MVRECANT
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
			
			//Compensação
			If ((cAliasQry)->E5_TIPO $ MVRECANT+"|"+MV_CRNEG+"|"+MVPAGANT+"|"+MV_CPNEG .And.;
			 	mv_par33 = 2 .And. (cAliasQry)->E5_MOTBX == "CMP")
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
			
			//Valida informações dos títulos (SE1/SE2)
			If cCarteira == "R" //Receber
				If mv_par34 = 1 //Somente em carteira
					cSituacao := "0" 
				Else
					cSituacao := AllTrim(mv_par23)
				EndIf
				
				//Valida o vencimento do título
				If !Empty((cAliasQry)->E5_SITCOB)
					If !(AllTrim((cAliasQry)->E5_SITCOB) $ cSituacao) 	
						(cAliasQry)->(dbSkip())
						Loop		
					EndIf
				ElseIf !Empty((cAliasQry)->E1_SITUACA)
					If !(AllTrim((cAliasQry)->E1_SITUACA) $ cSituacao) 	
						(cAliasQry)->(dbSkip())
						Loop		
					EndIf
				EndIf
				
				//Valida o vencimento do título
				If (StoD((cAliasQry)->E1_VENCTO) < mv_par15 .OR. StoD((cAliasQry)->E1_VENCTO) > mv_par16)	
					(cAliasQry)->(dbSkip())
					Loop		
				EndIf
				
			Else //Pagar	
				//Valida o vencimento do título
				If StoD((cAliasQry)->E2_VENCTO) < mv_par15 .OR. StoD((cAliasQry)->E2_VENCTO) > mv_par16	
					(cAliasQry)->(dbSkip())
					Loop		
				EndIf
			EndIf
		EndIf
		
		/**********************************
		 Valida a impressao de cheques
		***********************************/
		cChaveCH := (cAliasQry)->E5_BANCO + (cAliasQry)->E5_AGENCIA + (cAliasQry)->E5_CONTA + (cAliasQry)->E5_NUMCHEQ
		If mv_par35 == 1 
			cTpSel := "BA"
			cTpBusc	:= "CH"
		ElseIf mv_par35 == 2 
			cTpSel := "CH"
			cTpBusc	:= "BA"	
		EndIf
		
		If (cAliasQry)->E5_TIPODOC == cTpSel
			dbSelectArea("SE5")
			aAreaSE5 := SE5->(GetArea())
			SE5->(dbSetOrder(11))
			
			If SE5->(dbSeek(xFilial("SE5")+cChaveCH))					
				// Procura o cheque, se encontrar, marca e despreza
				While SE5->(!Eof()) .And. SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ == cChaveCH
					If SE5->E5_TIPODOC == cTpBusc .or. Empty(SE5->E5_NUMCHEQ)
						lEncCH := .T.
						Exit
					EndIf
					SE5->(dbSkip())
				EndDo
			EndIf
			RestArea(aAreaSE5)
			
			//Se encontrou o cheque com a caracteristica informada, despreza o registro
			If lEncCH
				(cAliasQry)->(dbSkip())
				lEncCH := .F.
				Loop
			EndIf
		EndIf	
		
		cQuery2 := " SELECT COUNT(SE5.E5_BANCO) NTOTAL	"
		cQuery2 += " FROM " + RetSqlName( "SE5" ) + " SE5 "
		cQuery2 += " WHERE SE5.E5_BANCO    = '" + (cAliasQry)->E5_BANCO   + "'"
		cQuery2 += " AND SE5.E5_AGENCIA    = '" + (cAliasQry)->E5_AGENCIA + "'"
		cQuery2 += " AND SE5.E5_CONTA      = '" + (cAliasQry)->E5_CONTA   + "'"
		cQuery2 += " AND SE5.E5_NUMCHEQ    = '" + (cAliasQry)->E5_NUMCHEQ + "'"
		cQuery2 += " AND SE5.E5_FILIAL     = '" +  xFilial("SE5")         + "'"
		cQuery2 += " AND SE5.E5_TIPODOC    = 'EC'"
		cQuery2 += " AND SE5.D_E_L_E_T_ = ' ' "
		
		cQuery2 := ChangeQuery( cQuery2 )
		cAliasTOT := GetNextAlias()
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery2) , cAliasTOT )
		(cAliasTOT)->(DbGoTop())
		nReg := (cAliasTOT)->NTOTAL
		(cAliasTOT)->(dbCloseArea())
		
		If nReg > 0
			lEncCH := .T.
		EndIf

		If lEncCH
			(cAliasQry)->(dbSkip())
			Loop
		EndIf 
			
		cTpSel := ""
		cTpBusc := ""
		
		//Recupera os valores do movimento
		aValores := F198TotVal(cAliasQry,cCarteira)
								
		//Grava o registro 
		For nI := 1 to Len(aValores)
			Reclock(cTMPSE5198,.T.)
			For nX := 1 to Len(aStruct)
				
				cCampo := aStruct[nX,1]
				
				Do Case			
					Case cCampo == "E5_NOME"
						If cCarteira == "R"
							xConteudo := 	(cAliasQry)->E1_NOMCLI		
						Else
							xConteudo := 	(cAliasQry)->E2_NOMFOR
						EndIf
					Case cCampo == "E5_VALORIG"
						xConteudo := 0
					Case cCampo == "E5_VALTIT"
						xConteudo := 0	
					Case cCampo == "E5_ABATIM"
						xConteudo := 0	
					Case cCampo == "E5_IMPOSTO"
						xConteudo := 0	
					Case cCampo == "E5_VALBX"
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
							xConteudo := STR0033 //CANCELAMENTO DE BAIXA								
						ElseIf Empty((cAliasQry)->E5_TIPODOC) .And. Empty((cAliasQry)->E5_NUMERO) .And. Empty((cAliasQry)->E5_HISTOR)  	
							xConteudo := STR0027 //MOVIMENTO MANUAL
						ElseIf !Empty((cAliasQry)->E5_NUMCHEQ)
							xConteudo := AllTrim((cAliasQry)->E5_NUMCHEQ)+"/"+Iif(!Empty((cAliasQry)->E5_HISTOR),(cAliasQry)->E5_HISTOR,STR0028) //CHEQUE
						ElseIf !Empty((cAliasQry)->E5_HISTOR)
							xConteudo := (cAliasQry)->E5_HISTOR
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
				(cTMPSE5198)->(FieldPut(nPosCampo,xConteudo))
				
			Next nX
			
			/****************************************
			 Recompoe os valores que serão impressos
			*****************************************/
			
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
			
			//Valida o fator de multiplicação
			If (cAliasQry)->E5_TIPODOC == "ES" //ESTORNO
				nFator := -1
			Else
				nFator := 1
			EndIf
			
			(cTMPSE5198)->E5_NATUREZ := aValores[nI][1]
			
			//Altera a natureza Pai
			If cCarteira == "R" //Receber
				If MV_MULNATP .And. ( (cAliasQry)->E1_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1" )
					lMulNat := .T.	
				EndIf
			ElseIf cCarteira == "P" //Pagar
				If MV_MULNATP .And. ( (cAliasQry)->E2_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1" )
					lMulNat := .T. 	
				EndIf
			EndIf
			
			If lMulNat
				dbSelectArea("SED")
				SED->(dbSetOrder(1))
				If dbSeek(xFilial("SED")+aValores[nI][1])
					(cTMPSE5198)->E5_NATDESC := SED->ED_DESCRIC
					(cTMPSE5198)->E5_NATPAI := SED->ED_PAI	
				EndIf
			EndIf
			
			/*
			aValores
				[x][1] = Natureza
				[x][2] = Valor Original
				[x][3] = Juros/Multa
				[x][4] = Correção
				[x][5] = Desconto
				[x][6] = Abatimentos
				[x][7] = Impostos
				[x][8] = Valor Baixado
		 	*/
			
			(cTMPSE5198)->E5_VALORIG 	:= Round(NoRound(xMoeda(aValores[nI][2],Val((cAliasQry)->E5_MOEDA),mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) * nFator
			(cTMPSE5198)->E5_VLJUROS 	:= Round(NoRound(xMoeda(aValores[nI][3],Val((cAliasQry)->E5_MOEDA),mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) * nFator
			(cTMPSE5198)->E5_VLCORRE 	:= Round(NoRound(xMoeda(aValores[nI][4],Val((cAliasQry)->E5_MOEDA),mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) * nFator
			(cTMPSE5198)->E5_VLDESCO 	:= Round(NoRound(xMoeda(aValores[nI][5],Val((cAliasQry)->E5_MOEDA),mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) * nFator
			(cTMPSE5198)->E5_ABATIM 	:= Round(NoRound(xMoeda(aValores[nI][6],Val((cAliasQry)->E5_MOEDA),mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) * nFator	
			(cTMPSE5198)->E5_VLMULTA 	:= Round(NoRound(xMoeda(aValores[nI][10],Val((cAliasQry)->E5_MOEDA),mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) * nFator
			If cPaisLoc == "BRA"
				nMoedOrig := Val((cAliasQry)->E5_MOEDA)
			Else
				//Impostos localizados são gravados sempre na moeda 1 na tabela de certificados de retenção.
				nMoedOrig := 1
			EndIf
			(cTMPSE5198)->E5_IMPOSTO 	:= Round(NoRound(xMoeda(aValores[nI][7],nMoedOrig,mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) *  nFator
			(cTMPSE5198)->E5_VALOR 		:= Round(NoRound(xMoeda(aValores[nI][8],Val((cAliasQry)->E5_MOEDA),mv_par20,StoD((cAliasQry)->E5_DATA),nDecs+1,nTaxa),nDecs+1),nDecs) * nFator
			
			//Valor dos títulos que serão totalizados	  
			If (cTMPSE5198)->E5_ULTBX == "S" .And. F198VldBx(cAliasQry) 
				(cTMPSE5198)->E5_VALTIT := (cTMPSE5198)->E5_VALORIG //Considera uma única vez o valor do título para recompor o total
			EndIf
			
			//Valor baixado que será totalizado
			If F198VldBx(cAliasQry)
				(cTMPSE5198)->E5_VALBX := (cTMPSE5198)->E5_VALOR
			EndIf	
			
			//Gravando a TABela de Origem
			(cTMPSE5198)->E5_TABORI  := (cAliasQry)->E5_TABORI
			(cTMPSE5198)->E5_IDORIG  := (cAliasQry)->E5_IDORIG
			(cTMPSE5198)->E5_TIPODOC := (cAliasQry)->E5_TIPODOC
						
			//Ajusta a data de vencimento
			If Empty((cAliasQry)->E5_VENCTO)
				If cCarteira == "R"
					(cTMPSE5198)->E5_VENCTO := StoD((cAliasQry)->E1_VENCTO)	
				Else
					(cTMPSE5198)->E5_VENCTO := StoD((cAliasQry)->E2_VENCTO)	
				EndIf
			EndIf	
				
			(cTMPSE5198)->(MsUnlock())
			
			If ValType("aTotais") <> "U"
															
				nBaixado 	:= 0
				nMovFin	:= 0
				nCompensa	:= 0
				nFatura	:= 0
				
				//Atualiza os totais
				If ((cAliasQry)->E5_MOTBX == "CMP" .Or. !MovBcoBx((cAliasQry)->E5_MOTBX)) .Or. (Empty((cAliasQry)->E5_TIPODOC) .And. Empty((cAliasQry)->E5_NUMERO))  
					nBaixado	:= 0
				Else
					nBaixado	:= (cTMPSE5198)->E5_VALOR
				EndIf
				
				If !(cAliasQry)->E5_TIPODOC $ " VL|V2|BA|RA|PA|CP|ES"
					nMovFin	:= (cTMPSE5198)->E5_VALOR
				EndIf
				
				If (cAliasQry)->E5_TIPODOC == "CP"
					/*Títulos compensados são exibidos com sinal negativo (-), 
					  sendo necessário fazer a inversao no totalizador*/
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
					aAdd(aAux,{STR0029 /*"Baixados"*/		,nBaixado	})
					aAdd(aAux,{STR0030 /*"Mov. Fin"*/		,nMovFin	})
					aAdd(aAux,{STR0031 /*"Compensados"*/	,nCompensa	})
					aAdd(aAux,{STR0032 /*"Bx Fatura"*/		,nFatura 	})
				
					aAdd(aTotais,{(cTMPSE5198)->E5_NATUREZ,(cTMPSE5198)->E5_NATPAI,aAux})
				EndIf
			EndIf
		
		Next nI		
		(cAliasQry)->(dbSkip())
	EndDo
	
	(cAliasQry)->(dbClearIndex()) 
	(cAliasQry)->(dbCloseArea()) 
	MsErase(cAliasQry)
	
	//GESTAO - inicio
	If !Empty(cTmpFil)
		CtbTmpErase(cTmpFil)
	EndIf
	//GESTAO - fim

EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F198TotNat

Totaliza as naturezas analíticas nas sintéticas

@author    Marcos Berto
@version   11.80
@since     27/12/12

@param oReport - Objeto de Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function F198TotNat()
Local aAux			:= {}
Local aStruct		:= {}
Local cNatureza		:= ""
Local cQuery		:= ""
Local cAliasQry1 	:= ""
Local cAliasQry2 	:= ""
Local lCreate		:= .F.
Local nX			:= 0
Local nHandle		:= 0

/*************************************
 Busca todas as naturezas sintéticas
**************************************/
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

lCreate := MsCreate(cTMPSED198,aStruct,"TOPCONN")
		
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
	
	/******************************************************************
	 Busca na tabela temporária os registros pertecentes às sintéticas
	*******************************************************************/	
	cQuery := "SELECT "
	cQuery += "E5_NATPAI, "
	cQuery += "SUM(E5_VALTIT) E5_VALORIG, "
	cQuery += "SUM(E5_VLJUROS) E5_VLJUROS, "
	cQuery += "SUM(E5_VLMULTA) E5_VLMULTA, "
	cQuery += "SUM(E5_VLCORRE) E5_VLCORRE, "
	cQuery += "SUM(E5_VLDESCO) E5_VLDESCO, "
	cQuery += "SUM(E5_ABATIM) E5_ABATIM,  "
	cQuery += "SUM(E5_IMPOSTO) E5_IMPOSTO, "
	cQuery += "SUM(E5_VALBX) E5_VALOR    "
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
EndIf

dbSelectArea(cAliasQry1)
(cAliasQry1)->(dbCloseArea())
MsErase(cAliasQry1)

//Monta os totalizadores por natureza sintética
F198TotSint()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F198TotVal

Totaliza os valores de cada movimento

IMPORTANTE: Para utilização desta função deve ser utilizada somente para recompor os valores 
deste relatório, uma vez que o alias utilizado é resultado de uma query que concatena 2 ou 
mais tabelas

@author    Marcos Berto
@version   11.80
@since     08/01/13

@param cAlias 	- Alias de referência
@param cCarteira 	- Carteira

@return aValores 	- Valores totalizados do movimento

/*/
//------------------------------------------------------------------------------------------
Static Function F198TotVal(cAliasQry,cCarteira)
Local aAreaSE1		:= {}
Local aDados		:= Array(11)
Local aValMov		:= Array(9)
Local aValores		:= {}
Local cAliasSEV		:= ""
Local cQuery		:= ""
Local nImposto		:= 0
Local nTotAbImp		:= 0
Local lMulNat		:= .F.
Local lCancel		:= .F. //Registros cancelados serão impressos 2 vezes
Local lPCCBaixa		:= .F.
Local lIRRFBaixa	:= .F.
Local lCalcIssBx	:= .F.
Local nDecs			:= MsDecimais(mv_par20)

DEFAULT cAliasQry	:= ""
DEFAULT cCarteira	:= "" 

//IMPORTANTE: 
//Todos os cálculos feitos pela função serão efetuados considerando a moeda do movimento.
//A conversão na moeda do relatório será efetuada posteriormente.
If !Empty(cAliasQry) .And. !Empty(cCarteira)

	//-------------------------------------------------
	//SOMA OS VALORES PARA COMPOSIÇÃO DAS COLUNAS
	//-------------------------------------------------	
	//aValMov
	//	[1] = Valor Original
	//	[2] = Juros/Multa
	//	[3] = Correção
	//	[4] = Desconto
	//	[5] = Amatimentos
	//	[6] = Impostos
	//	[7] = Valor Baixado
	//	[8] = Ult. Baixa?
	//	[9] = Multa
	If cCarteira == "R" //Receber
		If (cAliasQry)->E1_VALOR <> 0 
			aValMov[1] := Round(NoRound(xMoeda((cAliasQry)->E1_VALOR,(cAliasQry)->E1_MOEDA,Val((cAliasQry)->E5_MOEDA),StoD((cAliasQry)->E1_EMISSAO),nDecs+1,(cAliasQry)->E1_TXMOEDA),nDecs+1),nDecs)	
		Else
			aValMov[1] :=	(cAliasQry)->E5_VALOR	
		EndIf	
	Else //Pagar
		If (cAliasQry)->E2_VALOR <> 0
			aValMov[1] := Round(NoRound(xMoeda((cAliasQry)->E2_VALOR,(cAliasQry)->E2_MOEDA,Val((cAliasQry)->E5_MOEDA),StoD((cAliasQry)->E2_EMISSAO),nDecs+1,(cAliasQry)->E2_TXMOEDA),nDecs+1),nDecs)
		Else
			aValMov[1] :=	(cAliasQry)->E5_VALOR	
		EndIf
	EndIf
	
	If (cAliasQry)->E5_SITUACA == "C"
		lCancel := .T.
	EndIf
	
	aValMov[2] := (cAliasQry)->E5_VLJUROS
	aValMov[9] := (cAliasQry)->E5_VLMULTA
	aValMov[3] := (cAliasQry)->E5_VLCORRE
	aValMov[4] := (cAliasQry)->E5_VLDESCO
	aValMov[8] := FGetSE5Seq((cAliasQry)->E5_FILIAL,(cAliasQry)->E5_PREFIXO,(cAliasQry)->E5_NUMERO,(cAliasQry)->E5_PARCELA,(cAliasQry)->E5_TIPO,(cAliasQry)->E5_CLIFOR,(cAliasQry)->E5_LOJA)
	
	If (cAliasQry)->E5_SEQ == aValMov[8]
		If cCarteira == "R"
			
				//Posiciona no registro da SE1 para auxílio do cálculo
				dbSelectArea("SE1")
				aAreaSE1:= SE1->(GetArea())
				SE1->(dbSetOrder(2))
				SE1->(dbSeek((cAliasQry)->E1_FILIAL+(cAliasQry)->E1_CLIENTE+(cAliasQry)->E1_LOJA+(cAliasQry)->E1_PREFIXO+(cAliasQry)->E1_NUM+(cAliasQry)->E1_PARCELA+(cAliasQry)->E1_TIPO))	
				aValMov[5] := SumAbatRec((cAliasQry)->E5_PREFIXO,(cAliasQry)->E5_NUMERO,(cAliasQry)->E5_PARCELA,/*Moeda*/,"V",(cAliasQry)->E5_DATA,@nTotAbImp)
				SE1->(RestArea(aAreaSE1))
		Else
			aValMov[5] := SomaAbat((cAliasQry)->E5_PREFIXO,(cAliasQry)->E5_NUMERO,(cAliasQry)->E5_PARCELA,cCarteira,/*Moeda*/,,(cAliasQry)->E5_CLIFOR,(cAliasQry)->E5_LOJA)	
		EndIf
	Else
		aValMov[5] := 0	
	EndIf
	
	If cPaisLoc == "BRA"
			
		If cCarteira == "R"
			//Valida o uso de Pis/Cofins/Csll na Baixa
			lPCCBaixa 	:= FPccBxCr()
			
			lIRRFBaixa	:= FIrPjBxCr()
			
			lCalcIssBx := !Empty( SE1->( FieldPos( "E1_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
			
			
		Else
			//Valida o uso de Pis/Cofins/Csll na Baixa
			lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"		
			//Valida o uso de IRRF na baixa		 
			lIRRFBaixa := ( Posicione("SA2",1,xFilial("SA2") + (cAliasQry)->(E2_FORNECE+E2_LOJA),"A2_CALCIRF") == "2") .And. ;
			              ( Posicione("SED",1,xfilial("SED") + (cAliasQry)->(E2_NATUREZ),"ED_CALCIRF") = "S"  )   
		
		
			//Valida o uso de ISS na Baixa
			lCalcIssBx :=	IIF(lIsIssBx, IsIssBx("P"), SuperGetMv("MV_MRETISS",.F.,"1") == "2" )
			
		EndIf			 
		
		nImposto := 0
		
		If cCarteira == "R"
			
			If lPCCBaixa
				If Empty((cAliasQry)->E5_PRETPIS) .And. Empty((cAliasQry)->E5_PRETCOF) .And. Empty((cAliasQry)->E5_PRETCSL)
					nImposto += (cAliasQry)->E5_VRETPIS + (cAliasQry)->E5_VRETCOF + (cAliasQry)->E5_VRETCSL
				EndIf
			EndIf
			
			//IR
			If lIRRFBaixa
				nImposto += (cAliasQry)->E5_VRETIRF
			EndIf
			
			//ISS
			If lCalcIssBx
				nImposto += (cAliasQry)->E5_VRETISS
			EndIf
			
			//Abatimentos de Impostos
			If (cAliasQry)->E5_SEQ == aValMov[8]
				nImposto += nTotAbImp
				
				//Desconta dos abatimentos o valor que for refente à impostos
				aValMov[5] -= nTotAbImp		
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
	If cCarteira == "R" //Receber
		If MV_MULNATP .And. ( (cAliasQry)->E1_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1" ) 
			lMulNat := .T.	
		EndIf
	ElseIf cCarteira == "P" //Pagar
		If MV_MULNATP .And. ( (cAliasQry)->E2_MULTNAT == "1" .Or. (cAliasQry)->E5_MULTNAT == "1" )
			lMulNat := .T. 	
		EndIf
	EndIf
	
	If lMulNat
		dbSelectArea("SEV")
		dbSetOrder(2)       				
		//Pela distribuição da baixa
		If SEV->(dbSeek(xFilial("SEV")+(cAliasQry)->E5_PREFIXO+(cAliasQry)->E5_NUMERO+(cAliasQry)->E5_PARCELA+(cAliasQry)->E5_TIPO+(cAliasQry)->E5_CLIFOR+(cAliasQry)->E5_LOJA+"2"+(cAliasQry)->E5_SEQ))
			// Obtem os registros a serem processados
			cQuery := "SELECT * "
			cQuery += "FROM " + RetSqlName("SEV")+" SEV "
			cQuery += "WHERE " 
			cQuery += "SEV.EV_FILIAL = '" + xFilial("SEV")+ "' AND "
			cQuery += "SEV.EV_PREFIXO = '" + (cAliasQry)->E5_PREFIXO + "' AND "
			cQuery += "SEV.EV_NUM = '" + (cAliasQry)->E5_NUMERO + "' AND "
			cQuery += "SEV.EV_PARCELA = '" + (cAliasQry)->E5_PARCELA + "' AND "
			cQuery += "SEV.EV_TIPO = '" + (cAliasQry)->E5_TIPO + "' AND "
			cQuery += "SEV.EV_CLIFOR = '" + (cAliasQry)->E5_CLIFOR + "' AND "
			cQuery += "SEV.EV_LOJA = '" + (cAliasQry)->E5_LOJA + "' AND "
			cQuery += "SEV.EV_IDENT = '2' AND "						
			cQuery += "SEV.EV_SEQ = '" + (cAliasQry)->E5_SEQ + "' AND "
			cQuery += "SEV.EV_NATUREZ BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' AND "
			cQuery += "SEV.D_E_L_E_T_ = ' ' "
		//Pela distribuição do título
		Else 
			If SEV->( dbSeek( xFilial("SEV") + (cAliasQry)->E5_PREFIXO + (cAliasQry)->E5_NUMERO + (cAliasQry)->E5_PARCELA + (cAliasQry)->E5_TIPO + (cAliasQry)->E5_CLIFOR + (cAliasQry)->E5_LOJA + "1" ) )
				lMultNat := .T.
				cQuery := "SELECT * "
				cQuery += "FROM " + RetSqlName("SEV") + " SEV "
				cQuery += "WHERE EV_FILIAL = '" + xFilial("SEV") + "' AND "
				cQuery += "SEV.EV_PREFIXO = '" + (cAliasQry)->E5_PREFIXO + "' AND "
				cQuery += "SEV.EV_NUM = '" + (cAliasQry)->E5_NUMERO + "' AND "
				cQuery += "SEV.EV_PARCELA = '" + (cAliasQry)->E5_PARCELA + "' AND "
				cQuery += "SEV.EV_TIPO = '" + (cAliasQry)->E5_TIPO + "' AND "
				cQuery += "SEV.EV_CLIFOR = '" + (cAliasQry)->E5_CLIFOR + "' AND "
				cQuery += "SEV.EV_LOJA = '" + (cAliasQry)->E5_LOJA + "' AND "
				cQuery += "SEV.EV_IDENT = '1' AND "
				cQuery += "SEV.EV_NATUREZ BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' AND "
				cQuery += "SEV.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf	
	
	EndIf

	If !Empty(cQuery)	
		cAliasSEV := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSEV,.F.,.T.)	
		
		dbSelectArea(cAliasSEV)
		(cAliasSEV)->(dbGoTop())
		
		If !(cAliasSEV)->(Eof())
			While !(cAliasSEV)->(Eof())
				aDados[1] := (cAliasSEV)->EV_NATUREZ			//NATUREZA
				aDados[2] := aValMov[1] * (cAliasSEV)->EV_PERC	//VALOR ORIGINAL
				aDados[3] := aValMov[2] * (cAliasSEV)->EV_PERC	//JUROS
				aDados[4] := aValMov[3] * (cAliasSEV)->EV_PERC	//CORREÇÃO
				aDados[5] := aValMov[4] * (cAliasSEV)->EV_PERC	//DESCONTO
				aDados[6] := aValMov[5] * (cAliasSEV)->EV_PERC	//ABATIMENTO
				aDados[7] := aValMov[6] * (cAliasSEV)->EV_PERC	//IMPOSTO
				aDados[8] := aValMov[7] * (cAliasSEV)->EV_PERC	//BAIXADO
				aDados[9] := aValMov[8]							//ULT. BAIXA
				aDados[10]:= aValMov[9] * (cAliasSEV)->EV_PERC	//MULTA
				aDados[11]:= .F.								//CANCELAMENTO
				
				aAdd(aValores,aDados)
				aDados  := Array(11)
				
				//Gera o movimento inverso do cancelamento
				If lCancel
					aDados[1] := (cAliasSEV)->EV_NATUREZ					//NATUREZA
					aDados[2] := (aValMov[1] * (cAliasSEV)->EV_PERC) * (-1)	//VALOR ORIGINAL
					aDados[3] := (aValMov[2] * (cAliasSEV)->EV_PERC) * (-1)	//JUROS
					aDados[4] := (aValMov[3] * (cAliasSEV)->EV_PERC) * (-1)	//CORREÇÃO
					aDados[5] := (aValMov[4] * (cAliasSEV)->EV_PERC) * (-1)	//DESCONTO
					aDados[6] := (aValMov[5] * (cAliasSEV)->EV_PERC) * (-1)	//ABATIMENTO
					aDados[7] := (aValMov[6] * (cAliasSEV)->EV_PERC) * (-1)	//IMPOSTO
					aDados[8] := (aValMov[7] * (cAliasSEV)->EV_PERC) * (-1)	//BAIXADO
					aDados[9] :=  aValMov[8]								//ULT. BAIXA
					aDados[10]:= (aValMov[9] * (cAliasSEV)->EV_PERC) * (-1)	//MULTA
					aDados[11]:= .T.										//CANCELAMENTO
					
					aAdd(aValores,aDados)
					aDados  := Array(11)	
				EndIf
				
				(cAliasSEV)->(dbSkip())
			EndDo
		EndIf
		
		(cAliasSEV)->(dbCloseArea())
	Else
		aDados[1] := (cAliasQry)->E5_NATUREZ	//NATUREZA
		aDados[2] := aValMov[1]					//VALOR ORIGINAL					
		aDados[3] := aValMov[2]					//JUROS/MULTA	
		aDados[4] := aValMov[3]					//CORREÇÃO	
		aDados[5] := aValMov[4]					//DESCONTO	
		aDados[6] := aValMov[5]					//ABATIMENTO		
		aDados[7] := aValMov[6]					//IMPOSTO											
		aDados[8] := aValMov[7]					//BAIXADO
		aDados[9] := aValMov[8]					//ULT. BAIXA
		aDados[10]:= aValMov[9]					//MULTA
		aDados[11]:= .F.						//CANCELAMENTO
		
		aAdd(aValores,aDados)
		
		//Gera o movimento inverso do cancelamento
		If lCancel
			aDados  := Array(11)
			aDados[1] := (cAliasQry)->E5_NATUREZ	//NATUREZA
			aDados[2] := aValMov[1] * (-1)			//VALOR ORIGINAL
			aDados[3] := aValMov[2] * (-1)			//JUROS
			aDados[4] := aValMov[3] * (-1)			//CORREÇÃO
			aDados[5] := aValMov[4] * (-1)			//DESCONTO
			aDados[6] := aValMov[5] * (-1)			//ABATIMENTO
			aDados[7] := aValMov[6] * (-1)			//IMPOSTO
			aDados[8] := aValMov[7] * (-1)			//BAIXADO
			aDados[9] := aValMov[8]					//ULT. BAIXA
			aDados[10]:= aValMov[9] * (-1)			//MULTA
			aDados[11]:= .T.						//CANCELAMENTO
			
			aAdd(aValores,aDados)
		EndIf
	EndIf
EndIf
		
Return aValores

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F198TotSint

Totaliza os movimentos para as naturezas sintéticas

@author    Marcos Berto
@version   11.80
@since     08/01/13

@Param oReport	- Objeto do Relatório
@Param cNatureza	- Natureza a ser impressa o totalizador

/*/
//------------------------------------------------------------------------------------------
Static Function F198TotSint()
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
/*/{Protheus.doc} F198IncTot

Impressão de totalizadores

@author    Marcos Berto
@version   11.80
@since     08/01/13

@param oReport	- Objeto do Relatório
@param cNatureza	- Natureza a ser impressa o totalizador
@param cTotaliz	- Array que contém o totalizador

/*/
//------------------------------------------------------------------------------------------
Static Function F198IncTot(oReport,cNatureza,cTotaliz)
Local aTotalNat	:= {}
Local nX		:= 0
Local nPosNat	:= 0
Local nValor	:= 0
Local nAcmVal	:= 0
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
/*/{Protheus.doc} F198VldBx

Valida os motivos de baixa e/ou tipo do doc. do movimento.

IMPORTANTE: Para validação dos dados, o registro deve estar posicionado.

@author    Marcos Berto
@version   11.80
@since     08/01/13

@param cAlias - Alias em que os dados devem ser validados

@return lRet - Resultado da validação do movimento

/*/
//------------------------------------------------------------------------------------------
Static Function F198VldBx(cAlias)
Local lRet := .T.

DEFAULT cAlias := ""

If !Empty(cAlias)	
	If !Empty((cAlias)->E5_MOTBX)
		If (cAlias)->E5_MOTBX == "CMP"
			lRet := .F.	
		ElseIf !MovBcoBx((cAlias)->E5_MOTBX)
			lRet := .F.
		EndIf	
	EndIf	
	
	If (cAlias)->E5_SITUACA == "C"
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}SE5compSED
verifica se o nivel de compartilhamento da SE5 ‚ maior que a SED
@author Caio Quiqueto dos Santos	
@since  21/12/2016
@version 11
/*/
//-------------------------------------------------------------------
Static Function SE5compSED()
Local lRet := .T.

	IF FWModeAccess("SE5",1) == "C"
		lRet := .F.
	ElseIf FWModeAccess("SED",3) == "E"
		lRet := .F.
	ElseIf FWModeAccess("SE5",2) == FWModeAccess("SED",2) .and. FWModeAccess("SE5",3) == FWModeAccess("SED",3)
		lRet := .F.
	ElseIF FWModeAccess("SED",3) = "C" .and.(FWModeAccess("SE5",2) == "C" .and. FWModeAccess("SED",2) = "E")
 		lRet := .F.
 	EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FK6Calc
Calcula as tabelas da FK6
@author jose.aribeiro
@since 10/08/2016
@version V12
@param cTabOrig, caracters, Tabela de Origem da SE5
@param cIdOrig , caracters, Chave de Origem da Tabela SE5
@param cTipo   , caracters, O tipo de Documento 
/*/
//-------------------------------------------------------------------
Static Function FK6Calc(cTabOrig,cIdOrig,cTipo)
Local nRet  := 0

If ExistFunc('FXLOADFK6')	
	nRet := FXLOADFK6(cTabOrig,cIdOrig)[1][2]
Else
	nRet := 0
EndIf

If cTipo == 'ES'
	
	nRet *= -1
	
EndIf
	
Return nRet
