#include "FINA402.ch"
#include "PROTHEUS.ch"

Static lFWCodFil := .T.
Static _oFINA4021

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes


/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA402    ³ Autor ³ Adilson H Yamaguchia  ³ Data ³ 18.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera dados para IR, INSS e Pagamento de Fornecedores         ³±±
±±³          ³ Autonomos na Folha                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA402()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FINA402A( lAutomato )

Local lPanelFin := IsPanelFin()
Local nOpca := 0
Local oDlg, aButtons := {} , aSays := {}
Local nTamCC	:= Len(CriaVar("CTT_CUSTO"))
Local aHelp := {}

Private cCadastro := STR0001  //"Gera dados para SEFIP"

Default  lAutomato := .F.

pergunte("FIN402A",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros								   ³
//³ mv_par01		// Data Inicial									       ³
//³ mv_par02		// Data Final   									   ³
//³ mv_par03		// Do Fornecedor									   ³
//³ mv_par04		// Ate Fornecedor									   ³
//³ mv_par05		// C.Custo  										   ³
//| mv_par06       	// Do Prefixo										   |
//| mv_par07		// Ate Prefixo                                         |
//| mv_par08       	// Cons. Filiais abaixo?							   |
//| mv_par09       	// Da Filial 										   |
//| mv_par10		// Ate Filial                                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If cPaisLoc == "BRA"
	AADD(aSays, STR0002) //"Este programa tem como objetivo gerar os dados necessarios  "
	AADD(aSays, STR0003) //"para SEFIP na folha."

	If !lAutomato
		If lPanelFin  //Chamado pelo Painel Financeiro
			aButtonTxt := {}
			AADD(aButtonTxt,{STR0009,STR0009, {||Pergunte("FIN402A",.T. )}}) // Parametros
			FaMyFormBatch(aSays,aButtonTxt,{||nOpca:=1},{||nOpca:=0})
		Else
			AADD(aButtons, { 5,.T.,{|| Pergunte("FIN402A",.T. ) } } )
			AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
			AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
			FormBatch( cCadastro, aSays, aButtons )
		Endif
	Else
		nOpcA := 1
	EndIf

Else

	MsgAlert( STR0006,STR0007 ) //"Não foi encontrado o campo E2_SEFIP em sua base. A rotina não continuará seu processamento. Verifique boletim técnico disponível"###"Atenção"

Endif

If nOpcA == 1
	Processa({|lEnd| Fa402AProc(lAutomato)})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O codigo abaixo eh utilizado nesse ponto para garantir que tanto o alias³
//³quanto o browse serao recriados sem problemas na utilizacao do painel   ³
//|financeiro quando a rotina nao eh chamada de forma semi-automatica pois |
//|esse tratamento eh realizado na rotina T	            				   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPanelFin  //Chamado pelo Painel Financeiro
	dbSelectArea(FinWindow:cAliasFile)
	ReCreateBrow(FinWindow:cAliasFile,FinWindow)
Endif


/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa402AProc  ³ Autor ³ Adilson H Yamaguchi   ³ Data ³ 18.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa geracao dos dados da SEFIP para folha                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Fa402AProc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nao ha'                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fa402AProc(lAutomato)

Local cIndex
Local cRaMat
Local aArea := GetArea()
Local cFiltro
Local nIndex
Local aStru    := SE2->(dbStruct()), ni
Local cChave   := ""
Local cAliasTrbA
Local cCPOS_SE2
Local cSepAba    := If("|"$MVABATIM,"|",",")
Local cSepAnt    := If("|"$MVPAGANT,"|",",")
Local cSepNeg    := If("|"$MV_CRNEG,"|",",")
Local cSepProv   := If("|"$MVPROVIS,"|",",")
Local cSepRec    := If("|"$MVRECANT,"|",",")
Local cChaveSE2  := ""
Local nValorTit  := 0 //base
Local nValorINSS := 0
Local nValorIRRF := 0
Local aSaldo     := {0,0}
Local aSaldoIR   := {0,0}
Local nBaseDep   := GetMV("MV_TMSVDEP",,0)
Local lF402GRSRC := Existblock("F402GRSRC")  

//-- Matriz do varialvel aNatureza - Id. Calculo
//-- 218 - Salario Autonomo
Local aNatureza  := {"218"}
Local cNatureza  := ''

Local lSEFIP := cPaisLoc == "BRA"
Local aRecno := {}
Local cRecno := ""
Local cRA_CC := ""
Local cNextPgto
Local lF402SRA  := Existblock("F402SRA")
Local nRecNo    := 0
Local nValorBruto := 0
Local nValorIss	  := 0

Local nCount := 0
Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"

Local lCalcIssBx :=	 .F.

Local lIRPFBaixa :=	.F.

Local nRecnoSA2 := 0
Local lF402GRC := Existblock("F402GRC")
Local lGravaRGB := .T.
Local nRegSM0
Local cFilDe
Local cFilAte
Local cFilialSRA
Local cFilialRGB
Local cSeqBx
Local lGrava:=.F.
Local cMat := ""
Local cCateg	:= ""
Local lF402Natur := ExistBlock("F402NATUR")
LOCAL aSM0		:= AdmAbreSM0()
Local nInc
Local aFilProc  := {}
Local cAuxFil   := cFilAnt
Local aFornAut	:= {}
Local lMultVinc	:= .F.
Local nTamCodFol := TamSx3("RV_CODFOL")[1]
Local cRoteiro	:= MV_PAR12
Local cProcess	:= Substr(SuperGetMv("MV_PROCESS",.T.,""),1,TamSx3("RCH_PROCES")[1])
Local aPerAtual	:= {}
Local lFiltraFil := .T.
Local lF402SEMA := Existblock("F402SEMA")
Local nRecnoSE2 := 0
Local cQueryFIP := ""
Local lReproc	 := .F.
Local lInverte	 := .F.
Local aCampos	 := {}
Local bOk1,bOk2,bProces,bReproc,bWhile
Local nT,nZ
Local nOpca := 0
Local lReCount := .T.

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilFwSE2 := IIF( lGestao, FwFilial("SE2") , xFilial("SE2") )

Local a288289	:= {}
Local l288289	:= .T.
Local cFornAnt	:= ""
Local dDtEmisAnt:= ""
Local cCod288	:= ""
Local cCod289	:= ""
Local cPeriodAnt:= ""
Local cFiliAnt	:= ""
Local lDicFLX	:= AliasInDic("FLX")

Private aRecnoSE2 := {}
Private cMarca    := GetMark( )

dbSelectArea("SM0")
nRegSM0 := SM0->(Recno())

If lF402Natur
	aNatureza := Execblock("F402NATUR",.F.,.F.,{aNatureza})
Endif

//validacoes por filial
For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. Alltrim(aSM0[nInc][2]) >= Alltrim(cFilDe) .AND. Alltrim(aSM0[nInc][2]) <= Alltrim(cFilAte)

		cFilAnt := aSM0[nInc][2]

		DbSelectArea("SRV")
		SRV->(DbSetOrder(1))
		SRV->(DbGoTop())

		If SRV->(dbSeek(xFilial("SRV")+mv_par11))
			If SRV->RV_TIPO != "D" .And. !Empty(SRV->RV_CODFOL)
				MsgAlert(STR0010)
				cFilAnt := cAuxFil
				Return
			EndIf
		Else
			MsgAlert(STR0011)
			cFilAnt := cAuxFil
			Return
		EndIf

		SRV->(DbSetOrder(2))
		SRV->(DbGoTop())

		For nI := 1 To Len(aNatureza)
			nCodFol:= PadL(aNatureza[nI],nTamCodFol,"0")
			DBSeek(xFilial("SRV") + AllTrim(nCodFol))
		 	If SRV->(EOF())
				MsgAlert("Verba nao cadastrada para o Identificador " + nCodFol + ".")
				cFilAnt := cAuxFil
				Return
			EndIf
		Next

		If lSEFIP
			MsgAlert(OemToAnsi(STR0005))
			cFilAnt := cAuxFil
			Return Nil
		EndIf
	EndIf

Next

// Posiciona no ultimo registro do Cadastro de funcionarios
// para verificar a ultima matricula na filial atual
If mv_par08 == 2
	lFiltraFil := .F.
	cFilDe     := cFilAnt
	cFilAte    := cFilAnt
ELSE
	cFilDe     := mv_par09	// Todas as filiais
	cFilAte    := mv_par10
Endif

For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. Alltrim(aSM0[nInc][2]) >= Alltrim(cFilDe) .AND. Alltrim(aSM0[nInc][2]) <= Alltrim(cFilAte)

		lReproc := .F. //Incluido por defeito pré-existente, quando uma das filiais no reprocessamento não possui titulos estava causando error.log, dessa forma a variavel sempre será reiniciada para revalidar, verificar linha 412 aprox.
		cFilAnt := aSM0[nInc][2]

		DBSelectArea("SRA")
		cFilialSRA := xFilial("SRA")
		
		DbSelectArea("RGB")
		cFilialRGB := xFilial("RGB")

		dbSelectArea("SE2")
		dbSetOrder(1)
		cChave := "E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
		nCount    := 0

		If !lFiltraFil .And. Ascan( aFilProc, xFilial("SE2") ) > 0  //se ja processou para este xfilial nao precisa processar novamente
			Loop
		EndIf

		If TcSrvType() != "AS/400"
			cAliasTrbA := GetNextAlias()
			//SELECIONA TITULOS PAGOS
			cCPOS_SE2 := ""
			aEval(DbStruct(),{|e| IIf(!Empty(cCPOS_SE2), cCPOS_SE2 += ", ",""),cCPOS_SE2 += "SE2." + AllTrim(e[1])})
			cQuery := "SELECT COUNT(*) REGISTROS"
			cQuery += " FROM " + RetSqlName("SE2") + " SE2, " +  RetSqlName("SA2") + " SA2 "
			cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVABATIM,cSepAba) + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepAnt) + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  + " and "
			cQuery += " SE2.E2_SEFIP = ' ' and "
			cQuery += " ( SE2.E2_NUMLIQ = '' and SE2.E2_FATURA <> 'NOTFAT') and "
			cQuery += " SE2.D_E_L_E_T_=' ' and SA2.D_E_L_E_T_=' ' and "
			If !Empty(Mv_par01) .And. !Empty(Mv_Par02)
				cQuery += " ( E2_EMISSAO >= '" + Dtos(Mv_par01) + "' and E2_EMISSAO <= '" + Dtos(Mv_par02) + "' ) and "
			EndIf
			cQuery += "(E2_PREFIXO >= '" + mv_par06 +  "' AND E2_PREFIXO <= '" + mv_par07 + "') AND "
			cQuery += " A2_FILIAL = '"+xFilial("SA2") + "' and "
			cQuery += " A2_COD = E2_FORNECE AND"
			cQuery += " A2_LOJA = E2_LOJA AND"
			cQuery += " A2_TIPO = 'F' AND "
			cQuery += " E2_FORNECE BETWEEN '"+ mv_par03 + "' AND '" + mv_par04 + "' AND"

			If lFiltraFil
				cQuery += "  SE2.E2_FILORIG = '" + cFilAnt + "'"
			else
				cQuery += " SE2.E2_FILORIG >= '" + cFilDe + "' AND"
				cQuery += " SE2.E2_FILORIG <= '" + cFilAte + "'"
			EndIf

			cQuery := ChangeQuery(cQuery)
		 	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTrbA,.F.,.T.)
		 	If !(cAliasTrbA)->(EOF())
			 	nCount := (cAliasTrbA)->REGISTROS
			EndIf
			(cAliasTrbA)->(DBCloseArea())


			cQuery := "SELECT " + cCPOS_SE2 + ", SE2.R_E_C_N_O_, SA2.A2_CGC, SA2.A2_NOME, SA2.A2_END, SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST, SA2.A2_CEP, SA2.A2_NUMDEP, SED.ED_CODIGO, SED.ED_CALCINS "
			cQuery += " FROM " + RetSqlName("SE2") + " SE2, " +  RetSqlName("SA2") + " SA2, "+  RetSqlName("SED") + " SED "
			cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVABATIM,cSepAba) + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepAnt) + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " and "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  + " and "
			cQuery += "(E2_PREFIXO >= '" + mv_par06 +  "' AND E2_PREFIXO <= '" + mv_par07 + "') AND "
			cQuery += " SE2.E2_SEFIP = ' ' AND "
			cQuery += " ( SE2.E2_NUMLIQ = '' and SE2.E2_FATURA <> 'NOTFAT') and "				
			cQuery += " SE2.D_E_L_E_T_ = ' ' AND  SA2.D_E_L_E_T_ = ' ' AND  SED.D_E_L_E_T_ = ' ' AND "
			If !Empty(Mv_par01) .And. !Empty(Mv_Par02)
				cQuery += " ( E2_EMISSAO >= '" + Dtos(Mv_par01) + "' and E2_EMISSAO <= '" + Dtos(Mv_par02) + "' ) AND "
			EndIf
			cQuery += " A2_FILIAL = '" + xFilial("SA2") + "' AND "
			cQuery += " A2_COD = E2_FORNECE AND "
			cQuery += " A2_LOJA = E2_LOJA AND "
			cQuery += " A2_TIPO = 'F' AND "
			cQuery += " ED_FILIAL = '" + xFilial("SED") + "' AND "
			cQuery += " ED_CODIGO = E2_NATUREZ AND "
  			cQuery += " E2_FORNECE BETWEEN '"+ mv_par03 + "' AND '" + mv_par04 + "' AND"

			If lFiltraFil
				cQuery += " SE2.E2_FILORIG = '" + cFilAnt + "' AND"
			else
				cQuery += " SE2.E2_FILORIG >= '" + cFilDe + "' AND"
				cQuery += " SE2.E2_FILORIG <= '" + cFilAte + "' AND" 
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PE permite regra customizada para o retorno de titulos     ³
			//³para a SEFIP, podendo por exemplo trazer titulos com valor ³
			//³de INSS zerado.                                            ³
			//³Caso contrario segue a regra padrao, de descartar os que   ³
			//³nao sofreram retencao de INSS e/ou SEST                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If ExistBlock("F402INS")
			 	cQuery += ExecBlock("F402INS",.F.,.F.)
			Else
				cQuery += " (A2_RECINSS = 'S' AND ED_CALCINS = 'S')"
			Endif
			cQuery += " ORDER BY " + SqlOrder(cChave)
			cQuery := ChangeQuery(cQuery)

		 	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTrbA,.F.,.T.)

			For ni := 1 to Len(aStru)
				If aStru[ni,2] != 'C' .and. FieldPos(aStru[ni,1]) > 0
					TCSetField(cAliasTrbA, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
				Endif
			Next
			ProcRegua(nCount)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Monta query para busca de registros já processados         ³
			//³ anteriormente para a SEFIP, podendo optar pelo             ³
			//³ reprocessamento.                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			cAliasTrbB	:= GetNextAlias()
			nPosSEFIP	:= At("SE2.E2_SEFIP = '",cQuery) + Len("SE2.E2_SEFIP = '")
			cQueryFIP	:= SubStr(cQuery,1,nPosSEFIP-1)
			cQueryFIP 	+= "X"
			cQueryFIP	+= SubStr(cQuery,nPosSEFIP+1)
			
			cQueryFIP	:= ChangeQuery(cQueryFIP)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryFIP),cAliasTrbB,.F.,.T.)
			
			If (cAliasTrbB)->(!EOF())
			 	lReproc := .T.
			 	lReCount := .T.
			EndIf
			
		Else
			cAliasTrbA := "SE2"
			cIndex := CriaTrab(nil,.f.)
			cFiltro := " E2_FILIAL == '" +xFilial("SE2") + "' .And. EMPTY(E2_SEFIP) "
			If !Empty(Mv_par01) .And. !Empty(Mv_Par02)
				cFiltro += " .And. DToS(E2_EMISSAO) >= '" + Dtos(Mv_par01) + "'"
				cFiltro += " .And. DToS(E2_EMISSAO) <= '" + Dtos(Mv_par02) + "'"
			EndIf
			cFiltro += " .And. E2_PREFIXO >= '" + mv_par06 + "'"
			cFiltro += " .And. E2_PREFIXO <= '" + mv_par07 + "'"

			If lFiltraFil
				cFiltro += " .And. E2_FILORIG == '" + cFilAnt + "' "
			else
				cQuery += " SE2.E2_FILORIG >= '" + cFilDe + "' .AND."
				cQuery += " SE2.E2_FILORIG <= '" + cFilAte + "' "
			EndIf

			IndRegua("SE2",cIndex,cChave,,cFiltro,STR0005)  //"Selecionando Registros..."
			nIndex := RetIndex("SE2")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			If !(cAliasTrbA)->(EOF())
				COUNT TO nCount
			EndIf
			ProcRegua(nCount)
			dbGoTop()
	
		Endif
		
		fGetPerAtual( @aPerAtual, /*Filial*/, cProcess, cRoteiro )
		
		If !Empty(aPerAtual)
			ProcRegua(nCount)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Monta tela para seleção dos registros já processados       ³
			//³ anteriormente para a SEFIP, que serão reprocessados        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If lReproc
				If lAutomato .or. MsgYesNo(STR0014) //"Foram encontrados registros já processados anteriormente, deseja optar pelo reprocessamento?"

					If Select("SE2TMP") > 0
						SE2TMP->(DbCloseArea())
					EndIf
									
					//------------------
					//Criação da tabela temporaria 
					//------------------
					
					aStruSE2 := SE2->(DbStruct())
					
					If _oFINA4021 <> Nil
						_oFINA4021:Delete()
						_oFINA4021 := Nil
					Endif
					
					_oFINA4021 := FWTemporaryTable():New( "SE2TMP" )  
					_oFINA4021:SetFields(aStruSE2) 	
					_oFINA4021:AddIndex("1", {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO"})	
					_oFINA4021:Create()						
					
					// GRAVAÇÃO DO ARQUIVO SE2 NA SE2TMP
					While (cAliasTrbB)->(!EOF())
						DbSelectArea("SE2TMP")
						RecLock("SE2TMP",.T.)
						For nZ := 1 to fCount()
							If !Empty((cAliasTrbB)->(FieldName(nZ))).AND. SE2TMP->(FieldPos((cAliasTrbB)->(FieldName(nZ)))) > 0
								If (cAliasTrbB)->(ValType(FieldName(nZ))) # "M"
									If TamSX3((cAliasTrbB)->(FieldName(nZ)))[3] == "D"
										SE2TMP->( FieldPut( SE2TMP->(FieldPos((cAliasTrbB)->(FieldName(nZ)))), STOD((cAliasTrbB)->(FieldGet(nZ))) ) )
									Else
										SE2TMP->( FieldPut( SE2TMP->(FieldPos((cAliasTrbB)->(FieldName(nZ)))), (cAliasTrbB)->(FieldGet(nZ)) ) )
									EndIf
								EndIf	
							EndIf	
						Next nZ
						MsUnlock()

						(cAliasTrbB)->(DbSkip()) 
					EndDo
					
					(cAliasTrbB)->(DbCloseArea())
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Montagem dos campos na Array  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCampos := {}
					cCmp	:= "E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_NATUREZ|E2_FORNECE|E2_LOJA|E2_EMISSAO|"+;
							   "E2_VENCTO|E2_VENCREA|E2_VALOR|E2_SALDO|E2_IRRF|E2_INSS|E2_ISS|E2_PIS|E2_COFINS|E2_CSLL|"+;
							   "E2_SEFIP|E2_OK"
					AADD(aCampos,{"E2_OK","","  ",""})
					dbSelectArea("SX3")
					SX3->(dbSetOrder(1))
					dbSeek ("SE2")
					
					//Adiciona o campo E2_FILIAL no browse somente se o SE2 estiver exclusivo e em uso.
					If !Empty( cFilFwSE2 ) .Or. X3USO(x3_usado) .And. cNivel >= x3_nivel
						AADD(aCampos,{X3_CAMPO,"",AllTrim(X3Titulo()),X3_PICTURE})
						SX3->(dbSkip())
					EndIf
					
					While !EOF() .And. (x3_arquivo == "SE2")
						IF  Alltrim(X3_CAMPO) $ cCmp .And. X3USO(x3_usado) .AND. cNivel >= x3_nivel .and. X3_CONTEXT != "V"
							AADD(aCampos,{X3_CAMPO,"",AllTrim(X3Titulo()),X3_PICTURE})
						Endif
						SX3->(dbSkip())
					Enddo
					
					If !lAutomato
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Faz o calculo automatico de dimensoes de objetos     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nOpca := 0
						aSize := MSADVSIZE()
						DEFINE MSDIALOG oDlg1 TITLE STR0015 From aSize[7],00 To aSize[6],aSize[5] PIXEL //"Registros já processados"
	
						DbSelectArea("SE2TMP")
						DbSetorder(0)
						dbGoTop()
	
						/////////////
						// MarkBrowse
						oMark := MsSelect():New("SE2TMP","E2_OK","",aCampos,@lInverte,@cMarca,{oDlg1:nTop,oDlg1:nLeft,oDlg1:nBottom,oDlg1:nRight},,,oDlg1)
						oMark:oBrowse:lhasMark := .T.
						oMark:oBrowse:lCanAllmark := .T.
						oMark:oBrowse:bAllMark := { || FA402Inverte(cMarca,"SE2TMP",@lInverte) }
						oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						// MarkBrowse
						/////////////
						
						bOk1 := {|| nOpca := 1,oDlg1:End()}
						bOk2 := {|| nOpca := 2,oDlg1:End()}
						ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| Eval(bOk1) },{|| Eval(bOk2) }) CENTER
					Else
						FA402Inverte(cMarca,"SE2TMP",@lInverte,lAutomato)
					EndIf
					
					lReproc := nOpca == 1

				Else
					(cAliasTrbB)->(DbCloseArea())
					lReproc := .F.
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//	nT = 1 - Processa para os registros normais.     ³
			//	nT = 2 - Reprocessa os registros anteriores.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			For nT := 1 To 2
				
				If nT == 1
					DbSelectArea(cAliasTrbA)
					(cAliasTrbA)->(DbGoTop())
					cAliasArq := cAliasTrbA
				ElseIf lReproc
					DbSelectArea("SE2TMP")
					SE2TMP->(DbGoTop())
					cAliasArq := "SE2TMP"
				EndIf
				
				bProces := { || (cAliasArq)->(!Eof()) } //Processamento
				bReproc := { || lReproc .And. (cAliasArq)->(!EOF()) } //Reprocessamento
				bWhile 	:= Iif(nT == 1,bProces,bReproc)
	
				While Eval(bWhile)
	
					//Ignora registros não marcados			
					If nT == 2 .And. (cAliasArq)->E2_OK != cMarca
						(cAliasArq)->(DbSkip())
						Loop
					EndIf
	
					//Seleciona o fornecedor		
					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek(xFilial("SA2")+(cAliasArq)->E2_FORNECE+(cAliasArq)->E2_LOJA)
					nRecnoSA2 := SA2->(RECNO())
					
					If !EOF()
						If SA2->A2_TIPO # "F"
							(cAliasArq)->(DbSkip())
							Loop
						EndIf
					Else
						(cAliasArq)->(DbSkip())
						Loop
					EndIf
					
					aRecnoSE2 := {}
					DbSelectArea(cAliasArq)
					If TcSrvType() = "AS/400"
						If (E2_TIPO$FormatIn(MVABATIM,cSepAba)) .Or. (E2_TIPO$FormatIn(MVPAGANT,cSepAnt)) .Or. ;
							(E2_TIPO$FormatIn(MV_CRNEG,cSepNeg)) .Or. (E2_TIPO$FormatIn(MVPROVIS,cSepProv)) .or.;
							(E2_TIPO$FormatIn(MVRECANT,cSepRec))
							DbSkip()
							Loop
						EndIf
						IF !EMPTY(E2_SEFIP)
							DbSkip()
							Loop
						EndIf
					EndIf
		
					DbSelectArea(cAliasArq)
		
					If TcSrvType() != "AS/400"
						If nT == 1
							aAdd(aRecno, R_E_C_N_O_)  //Acumula todos os recnos para update posterior
							aAdd(aRecnoSE2, R_E_C_N_O_)  //acumula apenas os recnos do titulos do fornecedor atual
							nRecnoSE2 := R_E_C_N_O_
						EndIf
					Else
						aAdd(aRecnoSE2, RECNO())  //acumula apenas os recnos do titulos do fornecedor atual
						nRecnoSE2 := RECNO()
						RecLock(cAliasArq,.F.)
						(cAliasArq)->E2_SEFIP := "X"
						MsUnLock()
					EndIf
		
					DBSelectArea(cAliasArq)
					nValImp := 0
		
					lIRPFBaixa 	:=	IIf(cPaisLoc == "BRA", SA2->A2_CALCIRF == "2", .F.)

					lCalcIssBx :=	Posicione("SA2",1,xFilial("SA2")+(cAliasArq)->(E2_FORNECE+E2_LOJA),"A2_TIPO") == "J" .And.;
											GetNewPar("MV_MRETISS","1") == "2" //Retencao do ISS pela emissao (1) ou baixa (2)
		
					nValImp	+= (cAliasArq)->(E2_INSS)
		
					If !lCalcIssBx
						nValImp	+= (cAliasArq)->(E2_ISS)
					EndIf
		
					If !lIRPFBaixa
						nValImp	+= (cAliasArq)->(E2_IRRF)
					EndIf
		
					If !lPccBaixa
						nValImp	+= (cAliasArq)->(E2_PIS+E2_COFINS+E2_CSLL)
					EndIf
		
					nValImp	+= (cAliasArq)->(E2_SEST)
		
					nValorBruto := (cAliasArq)->(E2_VALOR)+nValImp
					nValorIss 	:= (cAliasArq)->(E2_ISS)
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona Registros                                          ³
					//³ Aqui se faz necessaria a cria‡Æo de tratamento de filial de  ³
					//³ origem para quando se tem SE2 compartilhado e SRA e SRC       ³
					//³ exclusivos                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SE2->(FieldPos("E2_MSFIL")) > 0
						If !Empty((cAliasArq)->E2_MSFIL) .and. !(Empty(cFilialSRA))
							cFilialSRA := (cAliasArq)->E2_MSFIL
						Endif
						If !Empty((cAliasArq)->E2_MSFIL) .and. !(Empty(cFilialRGB))
							cFilialRGB := (cAliasArq)->E2_MSFIL
						Endif
					Endif
		
					//valida cadastro de funcionario
					If !Empty(SA2->A2_NUMRA)
						// Busca por Número RA --> Matrícula
						SRA->(DbSetOrder(1))
						If SRA->(DbSeek(cFilialSRA+SA2->A2_NUMRA))
							While SRA->(!Eof()) .And. SA2->A2_NUMRA == SRA->RA_MAT
								If SRA->RA_SITFOLH == "D" .Or. SRA->RA_CATFUNC <> "A"
									lGrava	:= .T.
								Else
									lGrava	:= .F.
									cMat	:= SRA->RA_MAT
								EndIf
								SRA->(DbSkip())
							EndDo
						EndIf
					Else
						// Busca por CPF --> CIC
						SRA->(DbSetOrder(5))
						SRA->(DbSeek(cFilialSRA+SA2->A2_CGC))
	
						If SA2->A2_CGC <> SRA->RA_CIC
							lGrava:=.T.
						Else
							While SRA->(!Eof()) .And. SRA->RA_FILIAL == cFilialSRA .And. Alltrim(SA2->A2_CGC) == SRA->RA_CIC //.And. SRA->RA_CATFUNC <> "A"
								If SRA->RA_SITFOLH=="D" .Or. SRA->RA_CATFUNC <> "A"
									lGrava	:= .T.
								Else
									lGrava	:= .F.
									cMat	:= SRA->RA_MAT
								EndIf
								SRA->(DbSkip())
							EndDo
						EndIf
					EndIf
					If lGrava
						/*
						Verifica se o fornecedor ja existe na base. Em caso afirmativo, o tipo de ocorrencia devera ser alterado para "05" */
						lMultVinc	:= .F.
						cCateg := If(Empty(SA2->A2_CATEG), "15", SA2->A2_CATEG)
						SRA->(DbSetOrder(20))
						If SRA->(DbSeek(Padr(SA2->A2_CGC,TamSX3("RA_CIC")[1])))
							If Val(SRA->RA_MAT) >= 900000
		         				If SRA->RA_CATFUNC == "A"
					         		If SRA->RA_CATEG == "15"
										lMultVinc := .T.
										If Ascan(aFornAut,SA2->A2_CGC) == 0
											Aadd(aFornAut,Padr(SA2->A2_CGC,TamSX3("RA_CIC")[1]))
										Endif
									Endif
								Endif
							Endif
						Endif
						//INCLUI AUTONOMO EM SRA
						SRA->(DbSetOrder(1))
						SRA->(DbSeek(IncLast(cFilialSRA),.T.))
						SRA->(DbSkip(-1))
						cRaMat := Soma1(SRA->RA_MAT,9)
						cRaMat := If(Val(SRA->RA_MAT) < 900000 .And. Val(cRaMat) < 900000, "900000",cRaMat)
						RecLock("SRA",.T.)
						SRA->RA_FILIAL	:= cFilialSRA
						SRA->RA_MAT		:= cRaMat
						SRA->RA_CIC		:= SA2->A2_CGC
						SRA->RA_NOME	:= SA2->A2_NOME
						SRA->RA_TIPOPGT	:= "M"
						SRA->RA_CC		:= mv_par05
						cRA_CC			:= mv_par05
		         		SRA->RA_CATFUNC	:= "A"   //autonomo
						SRA->RA_CATEG	:= cCateg //Categoria de Autonomo utilizado na SEFIP.
						SRA->RA_PIS		:= SA2->A2_CODNIT
						SRA->RA_NASC	:= SA2->A2_DTNASC
		         		If lMultVinc
		         			SRA->RA_OCORREN	:= "05"
						Else
							SRA->RA_OCORREN	:= SA2->A2_OCORREN
		         		Endif
		         		SRA->RA_ENDEREC	:= SA2->A2_END
		         		SRA->RA_BAIRRO	:= SA2->A2_BAIRRO
		         		SRA->RA_MUNICIP	:= SA2->A2_MUN
		         		SRA->RA_ESTADO	:= SA2->A2_EST
		         		SRA->RA_CEP		:= SA2->A2_CEP
		         		SRA->RA_DEPIR	:= StrZero(SA2->A2_NUMDEP,TamSx3("RA_DEPIR")[1])
						SRA->RA_ADMISSA	:= CToD("01/"+StrZero(Month(dDataBase),2)+"/"+StrZero(Year(dDataBase),4))
						SRA->RA_PROCES	:= cProcess
		
						//Ponto de entrada para complemento do cadastro de autonomo gerado a partir da
						//integracao FIN x GPE para SEFIP
						If lF402SRA
							ExecBlock("F402SRA",.F.,.F.,{.F.})
						Endif
						MsUnLock()
					Else
						//Ponto de entrada para complemento do cadastro de autonomo gerado a partir da
						//integracao FIN x GPE para SEFIP
						SRA->(DbSetOrder(1))
						SRA->(DbSeek(cFilialSRA+cMat))
						cRA_CC      := SRA->RA_CC
						
						If lF402SRA
							ExecBlock("F402SRA",.F.,.F.,{.T.})
						Endif
					
					EndIf
		
					cNextPgto := aPerAtual[1][2]
					cSeqRGB   := AllTrim(NextSRC402(SRA->RA_MAT,cFilialRGB))
					lGravaRGB := .T.
	
					//ponto de entrada que permite alterar o conteudo de RC_SEMANA
					If lF402SEMA 
						cNextPgto := ExecBlock("F402SEMA",.F.,.F., {cNextPgto, nRecnoSE2})
					EndIf	
					
					cNextPgto:=PADL(cNextPgto,tamsx3("RGB_SEMANA")[1],"0")
					
					//Ponto de entrada para permitir ou nao a gravacao dos dados no RGB
					If lF402GRC
						lGravaRGB := ExecBlock("F402GRC",.F.,.F.)
					Endif
		
					DBSelectArea("SED")
					SED->(DBSetOrder(1))
					SED->(MSSeek(xFilial("SED")+(cAliasArq)->E2_NATUREZ))
				   //Inclusão do registro correspondente a Verba de Codigo 218.
				   //que recebera o Valor Bruto do Titulo.
					If lGravaRGB .and. Val(cNextPgto) < 100
		
						SRV->(DbSetOrder(2))
						nCodFol:= PadL(aNatureza[1],nTamCodFol,"0")
						SRV->(DBSeek(xFilial("SRV") + nCodFol))
						RGB->(DBSetOrder(7)) //RGB_FILIAL, RGB_MAT, RGB_PD, RGB_CC, RGB_SEMANA, RGB_SEQ, R_E_C_N_O_, D_E_L_E_T_
					  	If !RGB->(DbSeek(cFilialRGB+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cNextPgto))
					  		
							RecLock("RGB",.T.)
							RGB->RGB_FILIAL		:= cFilialRGB
							RGB->RGB_MAT		:= SRA->RA_MAT
							RGB->RGB_PD			:= SRV->RV_COD
							RGB->RGB_TIPO1		:= "V"
							RGB->RGB_QTDSEM		:= 0
							RGB->RGB_HORAS		:= 0
							RGB->RGB_VALOR		:= nValorBruto
							RGB->RGB_PERIOD		:= aPerAtual[1][1]
							RGB->RGB_SEMANA		:= cNextPgto
							RGB->RGB_CC			:= SRA->RA_CC
							RGB->RGB_PARCELA	:= 0
							RGB->RGB_TIPO2		:= "G"
							RGB->RGB_SEQ		:= cSeqRGB
							RGB->RGB_PROCES		:= SRA->RA_PROCES
							RGB_ROTEIR			:= cRoteiro

							lReCount := .F.
							
						Else
						
							RecLock("RGB",.F.)
							IF lReCount
								RGB->RGB_VALOR	:= 0
								lReCount := .F.
							Endif
							RGB->RGB_VALOR	+= nValorBruto
							
						Endif
						RGB->(MsUnlock())
					Endif
		
					//Registro de ISS - Verba cadastrada pelo usuario.
					If lGravaRGB .and. Val(cNextPgto) < 100 .And. nValorIss > 0
		
						SRV->(DbSetOrder(1))
						If SRV->(DBSeek(xFilial("SRV") + mv_par11))
							RGB->(DBSetOrder(7))
						  	If !RGB->(DbSeek(cFilialRGB+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cNextPgto))
						  		
								RecLock("RGB",.T.)
								RGB->RGB_FILIAL	:= cFilialRGB
								RGB->RGB_MAT		:= SRA->RA_MAT
								RGB->RGB_PD		:= SRV->RV_COD
								RGB->RGB_TIPO1	:= "V"
								RGB->RGB_QTDSEM	:= 0
								RGB->RGB_HORAS	:= 0
								RGB->RGB_VALOR	:= nValorIss
								RGB->RGB_PERIOD	:= aPerAtual[1][1]
								RGB->RGB_SEMANA	:= cNextPgto
								RGB->RGB_CC		:= SRA->RA_CC
								RGB->RGB_PARCEL	:= 0
								RGB->RGB_TIPO2	:= "G"
								RGB->RGB_SEQ		:= cSeqRGB
								RGB->RGB_PROCES	:= SRA->RA_PROCES
								RGB_ROTEIR			:= cRoteiro
							Else
								RecLock("RGB",.F.)
								RGB->RGB_VALOR	+= nValorIss
							Endif
							RGB->(MsUnlock())
						EndIf
					Endif
					
					//Verbas com ID de calculo 288 e 289
					If lGravaRGB
					
						If lDicFLX .AND. l288289
							a288289	:= FA402AFLX()
						EndIf
						
						If Len(a288289) > 0 
							cCod288:= PadL("288",nTamCodFol,"0")
							SRV->(dbSetOrder(2))						
							If SRV->(dbSeek(xFilial("SRV")+cCod288))
								RGB->(DBSetOrder(7))
							  	If !RGB->(DbSeek(cFilialRGB+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cNextPgto))
							  		
									RecLock("RGB",.T.)
									RGB->RGB_FILIAL	:= cFilialRGB
									RGB->RGB_MAT	:= SRA->RA_MAT
									RGB->RGB_PD		:= SRV->RV_COD
									RGB->RGB_TIPO1	:= "V"
									RGB->RGB_QTDSEM	:= 0
									RGB->RGB_HORAS	:= 0
									RGB->RGB_VALOR	:= A288289[1][1]
									RGB->RGB_PERIOD	:= aPerAtual[1][1]
									RGB->RGB_SEMANA	:= cNextPgto
									RGB->RGB_CC		:= SRA->RA_CC
									RGB->RGB_PARCEL	:= 0
									RGB->RGB_TIPO2	:= "G"
									RGB->RGB_SEQ	:= cSeqRGB
									RGB->RGB_PROCES	:= SRA->RA_PROCES
									RGB_ROTEIR		:= cRoteiro
								Endif
								RGB->(MsUnlock())
	
							
							EndIf
											
							cCod289:= PadL("289",nTamCodFol,"0")										
							SRV->(dbSetOrder(2))						
							If SRV->(dbSeek(xFilial("SRV")+cCod289))
								RGB->(DBSetOrder(7))
								
							  	If !RGB->(DbSeek(cFilialRGB+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cNextPgto))						  		
									RecLock("RGB",.T.)
									RGB->RGB_FILIAL	:= cFilialRGB
									RGB->RGB_MAT	:= SRA->RA_MAT
									RGB->RGB_PD		:= SRV->RV_COD
									RGB->RGB_TIPO1	:= "V"
									RGB->RGB_QTDSEM	:= 0
									RGB->RGB_HORAS	:= 0
									RGB->RGB_VALOR	:= A288289[1][2]
									RGB->RGB_PERIOD	:= aPerAtual[1][1]
									RGB->RGB_SEMANA	:= cNextPgto
									RGB->RGB_CC		:= SRA->RA_CC
									RGB->RGB_PARCEL	:= 0
									RGB->RGB_TIPO2	:= "G"
									RGB->RGB_SEQ	:= cSeqRGB
									RGB->RGB_PROCES	:= SRA->RA_PROCES
									RGB_ROTEIR		:= cRoteiro
								Else
									 If (cFiliAnt <> (cAliasArq)->E2_FILIAL) .Or. cPeriodAnt <> ALLTRIM(Str(Year((cAliasArq)->E2_EMISSAO))) + STRZERO(MONTH((cAliasArq)->E2_EMISSAO),2)									 
										RecLock("RGB",.F.)
										RGB->RGB_VALOR	+= A288289[1][2]
									EndIf									
								Endif
								RGB->(MsUnlock())							
							EndIf				
							l288289	:= .F.								
						EndIf
					Endif
					
					//Complemento de Gravação na Tabela RGB, antiga SRC
					If lF402GRSRC                                                                  
						ExecBlock("F402GRSRC",.F.,.F.)
					EndIf
					cFiliAnt	:= (cAliasArq)->E2_FILIAL
					cFornAnt	:= (cAliasArq)->E2_FORNECE +(cAliasArq)->E2_LOJA
					dDtEmisAnt  := (cAliasArq)->E2_EMISSAO 
					cPeriodAnt	:= Alltrim(Str(Year(dDtEmisAnt))) + StrZero(Month(dDtEmisAnt),2)
					
					DbSelectArea(cAliasArq)
					DbSkip()
					
					If  (cFiliAnt <> (cAliasArq)->E2_FILIAL) .Or. ;
						( cFornAnt <> (cAliasArq)->E2_FORNECE +(cAliasArq)->E2_LOJA ) .Or. ; 
						cPeriodAnt <> ALLTRIM(Str(Year((cAliasArq)->E2_EMISSAO))) + STRZERO(MONTH((cAliasArq)->E2_EMISSAO),2)  
						l288289	:= .T.
						a288289	:= {}
					EndIf
					IncProc()
				End
				
				//Fecha o arquivo temporário
				If Select(cAliasArq) > 0
					(cAliasArq)->(DbCloseArea())
				EndIf
				
			Next nT
			
		ElseIf Empty(aPerAtual)
			Help( ,,"F402APERCALC",,STR0013, 1, 0 ) //"Não existe o período de cálculo, favor cadastar."
		Else
			(cAliasTrbB)->(DBCloseArea())
		EndIf

			If TcSrvType() != "AS/400"
				If Len(aRecno) > 0
					cRecno:=""
					For nI:=1 To Len(aRecno)
						cRecno += IIf(nI==1,"",",") + Str(aRecno[nI])
					Next
					cQuery := "UPDATE "
					cQuery += RetSqlName("SE2")+" "
					cQuery += "SET E2_SEFIP = 'X'"
					cQuery += " WHERE R_E_C_N_O_ IN (" + cRecno + ") AND "
				  	cQuery += "D_E_L_E_T_ <> '*' "
					TcSqlExec(cQuery)
				EndIf
			Else
				RetIndex("SE2")
				Set Filter To
				dbGoTop()
				Ferase(cIndex+OrdBagExt())
		
			EndIf
		

		aAdd( aFilProc, xFilial("SE2") ) //adiciona xFilial de SE2 para verificar se vai processar novamente
	Endif
Next
/*
SEFIP
Quando um fornecedor (incluido como autonomo) estiver incluido em mais de uma filial, deve-se atualizar o tipo de ocorrencia
para "05", em todas as filiais onde esse fornecedor aparecer */
Processa({|| F402aAut(Aclone(aFornAut))})
/*-*/
SM0->(dbGoTo(nRegSM0))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

//Deleta tabela temporária criada para o reprocessamento
If _oFINA4021 <> Nil
	_oFINA4021:Delete()
	_oFINA4021 := Nil
Endif

RestArea(aArea)
Return Nil

Static Function IncLast( cString )
Return Left(cString, Len(cString)-1)+;
       CHR(ASC(RIGHT(cString,1))+1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA402   ºAutor  ³Microsiga           º Data ³  06/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NextPgt402(cMAT)
Local aArea := GetArea()
Local cNextPgto := 1
	DbSelectArea("RGB")
	DbSetOrder(1)
	DbSeek(xFilial("RGB")+cMAT)
	If EOF()
		cNextPgto := "1"
	Else
		cNextPgto := Str(Val(RGB_SEMANA) + 1)
	EndIf
	DbSelectArea(aArea)
Return cNextPgto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA402   ºAutor  ³Microsiga           º Data ³  06/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NextSRC402(cMAT)
Local aArea := GetArea()
Local cSeqRGB := "0"
	
	DbSelectArea("RGB")
	DbSetOrder(1)
	RGB->(DbGoTop())
	DbSeek(xFilial("RGB")+cMAT)

	If EOF()
		cSeqRGB := "1"
	Else
		If RGB->(DbSeek(RGB->RGB_FILIAL+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+RGB->RGB_SEMANA+cSeqRGB))
			cSeqRGB := RGB->RGB_SEQ
			While (RGB->(RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_SEMANA+RGB_SEQ)) == ;
					(RGB->RGB_FILIAL + SRA->RA_MAT + SRV->RV_COD + SRA->RA_CC + RGB->RGB_SEMANA + cSeqRGB)
 				cSeqRGB := Soma1(cSeqRGB,Len(cSeqRGB))
				dBSkip()
			EndDo
		EndIf
	Endif
	DbSelectArea(aArea)
Return cSeqRGB

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F402aAuto ºAutor  ³Microsiga           º Data ³ 08/01/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica os fornecedores que pertencem a mais de uma filial º±±
±±º          ³e atualiza o tipo de ocorrencia desses fornecedores para    º±±
±±º          ³"05" - SEFIP.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 */
Static Function F402aAut(aFornAut)
Local cQuery	:= ""
Local cQryFixa	:= ""
Local nLenAut	:= 0
Local nAuton	:= 0
Local aAreaSRA	:= {}
Local aArea		:= {}
Local lErro		:= .F.

Default aFornAut := {}

lErro := .F.
aAreaSRA := {}
cQuery := ""
cQryFixa := ""
nLenAut := Len(aFornAut)
/*-*/
If nLenAut > 0
	ProcRegua(nLenAut)
	aArea := GetArea()
		cQryFixa := "update " + RetSQLName("SRA") + " SET RA_OCORREN = A2_OCORREN "
		cQryFixa += "from " + RetSQLName("SA2") + " SA2, " + RetSQLName("SRA")+ " SRA "
		cQryFixa += " where RA_MAT >= '900000'"		/* os fornecedores sao cadastrados com matriculas iniciando em 900000 (veja a funcao Fa402AProc) */
		cQryFixa += " and RA_CATFUNC = 'A'"   		/* indicacao de autonomo */
		cQryFixa += " and RA_CATEG <> ' ' " 			/* categoria */
		cQryFixa += " and RA_OCORREN = '" + Space(Len(SRA->RA_OCORREN)) + "'"		/* seleciona somente aqueles que ainda nao foram atualizados */		
		cQryFixa += " and SRA.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
		lErro := .F.
		nAuton := 0
		Begin Transaction
			While (nAuton < nLenAut) .And. !lErro
				nAuton++
				cQuery := cQryFixa
				cQuery += " and RA_CIC = '" + aFornAut[nAuton] + "'"
				cQuery += " and A2_CGC = RA_CIC "
				lErro := (TcSQLExec(cQuery) < 0)
				IncProc()
			Enddo
			If lErro
				MsgStop(TcSqlError())
				DisarmTrans()
			Endif
		End Transaction
		
	RestArea(aArea)
Endif
Return(!lErro)

//-------------------------------------------------------------------
/*/{Protheus.doc}Fa402Inverte
Inverte as marcacoes do arquivo exibido em MsSelect

@param cMarca - Assinatura da marca de selecao 
@param cAliasTMP - Alias do arquivo temporario
@param lMarkAll - Marca todos
 
@return nil

@author Leonardo Castro da Silva
@since  09/05/2016
/*/
//-------------------------------------------------------------------

Static Function Fa402Inverte(cMarca,cAliasTMP,lMarkAll,lAutomato)
Local nReg := (cAliasTMP)->(Recno())

DEFAULT cAliasTMP := "SE2TMP"
DEFAULT lMarkAll := .F.
DEFAULT lAutomato := .F.

lMarkAll := !lMarkAll

dbSelectArea(cAliasTMP)
(cAliasTMP)->(DbGoTop())

While !Eof()
		
	Reclock(cAliasTMP,.F.)
	
	IF	lMarkAll
		(cAliasTMP)->E2_OK := cMarca
	Else
		(cAliasTMP)->E2_OK := "  "
	Endif
	
	(cAliasTMP)->(MsUnlock())
	dbSkip()
Enddo

(cAliasTMP)->(dbGoto(nReg))
If !lAutomato
	oMark:oBrowse:Refresh(.t.)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}FA402FLX
Obtem a base retida e o valor retido de INSS por outras empresas

@return aRet[1] - Valor base INSS
 		aRet[2] - Valor do INSS

@author Simone Mie Sato Kakinoana
@since  29/09/2017
/*/
//-------------------------------------------------------------------
Static Function FA402AFLX(cPeriodo)

Local cQuery	:= ""
Local aRet		:= {}
Local cAliasFLX:= ""

cAliasFLX := GetNextAlias()

cQuery	:= " SELECT FLX_BASE, FLX_INSS " 
cQuery	+= " FROM " + RetSqlName("FLX") + " FLX "
cQuery	+= " WHERE FLX_FILIAL ='" + xFilial("FLX")+"' "
cQuery	+= " AND FLX_FORNEC ='" + (cAliasArq)->E2_FORNECE+"' "
cQuery	+= " AND FLX_LOJA ='" + (cAliasArq)->E2_LOJA+"' "
cQuery  += " AND FLX_DTINI <= '" + DTOS((cAliasArq)->E2_EMISSAO)+"' "
cQuery  += " AND FLX_DTFIM  >= '" + DTOS((cAliasArq)->E2_EMISSAO)+"' "
cQuery	+= " AND FLX.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

If Select("cAliasFLX") > 0
	(cAliasFLX)->(DbCloseArea())
EndIf
				
dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasFLX,.F.,.T.)

TcSetField(cAliasFLX, "FLX_BASE", "N", TamSx3("FLX_BASE")[1], TamSx3("FLX_BASE")[2])
TcSetField(cAliasFLX, "FLX_INSS", "N", TamSx3("FLX_INSS")[1], TamSx3("FLX_INSS")[2])

If !(cAliasFLX)->(EOF())
	AADD( aRet, { (cAliasFLX)->FLX_BASE, (cAliasFLX)->FLX_INSS } )
EndIf
(cAliasFLX)->(DBCloseArea())

Return(aRet)