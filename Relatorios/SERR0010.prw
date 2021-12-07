#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"

Static cAliasSE2	:= GetNextAlias()


/*/{Protheus.doc} SERR0002
Imprime o RPC do cooperado
@author Totvs Vitoria - Mauricio Silva
@since 13/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nRecSE2, numeric, description
@type function
/*/
User Function SERR0010(cFornece,cLoja,cPrefixo,cNumero,aObs,oPrint,nLinha)

	Local lPreview			:= .f.
	Private nPosLine			:= 0
	Private oArial13N		:=	TFont():New("Arial",,13,,.T.,,,,,.F.,.F.)
	Private oArial11N		:=	TFont():New("Arial",,11,,.T.,,,,,.F.,.F.)
	Private oArial11  		:=	TFont():New("Arial",,11,,.F.,,,,,.F.,.F.)
	Private oArial8N		:=	TFont():New("Arial",,8,,.T.,,,,,.F.,.F.)
	Private oArial7  		:=	TFont():New("Arial",,7,,.F.,,,,,.F.,.F.)
	Private oArial9N		:=	TFont():New("Arial",,9,,.T.,,,,,.F.,.F.)
	Private oArial9  		:=	TFont():New("Arial",,9,,.F.,,,,,.F.,.F.)
	Private oArial10N		:=	TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
	Private oArial12  		:=	TFont():New("Arial",,12,,.F.,,,,,.F.,.F.)
	Private oArial12N  		:=	TFont():New("Arial",,12,,.T.,,,,,.F.,.F.)
	Private oArial14N		:=	TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Private Courier12  		:=	TFont():New("Courier",,12,,.F.,,,,,.F.,.F.)

	Private lAdjustToLegacy := .T.
	Private lDisableSetup  	:= .T.
	Private	nTotMax			:= 3016 // total que considero da pagina

	Default cFornece 		:= SE2->E2_FORNECE
	Default cLoja 	 		:= SE2->E2_LOJA
	Default cPrefixo 		:= SE2->E2_PREFIXO
	Default cNumero  		:= SE2->E2_NUM
	Default aObs			:= {}
	Default oPrint		:= Nil

	Private oPrinter		:= oPrint

	// Realiza a busca dos titulos envolvidos
	TrabSE2(cFornece,cLoja,cPrefixo,cNumero)

	If oPrinter == Nil
		lPreview := .t.
		oPrinter := FWMSPrinter():New("SERR0010.rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup)

		oPrinter:SetResolution(72)
		oPrinter:SetPortrait()
		oPrinter:SetMargin(5,5,5,5) // nEsquerda, nSuperior, nDireita, nInferior
		oPrinter:SetPaperSize(DMPAPER_A4)
		oPrinter:Setup()

		If !(oPrinter:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
			Return
		End if
	End If


	//Criando nova pagina
	If nLinha >= nLinMax
		nLinha := 0
		oPrinter:StartPage()
		nLinMax := 3000
		nLinha := topoPag(nLinha)
	End If

	nLinha := printPage(aObs,nLinha)



	If lPreview
		oPrinter:Preview()
	End iF
Return nLinha

/*/{Protheus.doc} TrabSE2
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 13/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cFornece, characters, description
@param cLoja, characters, description
@param cPrefixo, characters, description
@param cNumero, characters, description
@type function
/*/
Static Function TrabSE2(cFornece,cLoja,cPrefixo,cNumero)

	Local cSepAba    := If("|"$MVABATIM,"|",",")
	Local cSepAnt    := If("|"$MVPAGANT,"|",",")
	Local cSepNeg    := If("|"$MV_CRNEG,"|",",")
	Local cSepProv   := If("|"$MVPROVIS,"|",",")
	Local cSepRec    := If("|"$MVRECANT,"|",",")

	Local cFiltAba	 := "%" + FormatIn(MVABATIM,cSepAba) + "%"
	Local cFiltAnt	 := "%" + FormatIn(MVPAGANT,cSepAnt) + "%"
	Local cFiltNeg	 := "%" + FormatIn(MV_CRNEG,cSepNeg) + "%"
	Local cFiltProv  := "%" + FormatIn(MVPROVIS,cSepProv ) + "%"
	Local cFiltRec 	 := "%" + FormatIn(MVRECANT,cSepRec ) + "%"

	// Verifica se esta em aberto
	If select (cAliasSE2) > 0
		(cAliasSE2)->(DbCloseArea())
	End If

	BeginSql Alias cAliasSE2

		SELECT SE2.E2_FILIAL 
		,SE2.E2_FORNECE 
		,SE2.E2_LOJA 
		,SA2.A2_NOME
		,SA2.A2_CGC
		,SA2.A2_TIPO
		,SA2.A2_IRPROG
		,SRA.RA_MAT
		,SRA.RA_FICHA
		,SRA.RA_ADMISSA
		,SRA.RA_YPAMCAR
		,SE2.E2_NATUREZ 
		,SED.ED_DESCRIC
		,SE2.E2_PREFIXO 
		,SE2.E2_NUM 
		,SE2.E2_EMISSAO 
		,SE2.E2_PARCELA 
		,SE2.E2_TIPO 
		,SE2.E2_VALOR  + SE2.E2_INSS + SE2.E2_IRRF + SE2.E2_PIS + SE2.E2_COFINS + SE2.E2_CSLL + SE2.E2_SEST AS E2_VALOR
		,SE2.E2_BASEIRF 
		,SE2.E2_IRRF 
		,SE2.E2_BASEINS 
		,SE2.E2_INSS 
		,SE2.E2_SEST 
		,SE2.E2_YPSEST
		,SE2.E2_YPSENAT
		,SE2.E2_MDCONTR
		,SE2.E2_MEDNUME
		,SE2.E2_MDPLANI
		,SE2.E2_MDREVIS
		,DT7.DT7_CODDES 
		,DT7.DT7_DESCRI 
		,SRV.RV_COD 
		,SRV.RV_DESC 

		FROM  %Table:SE2% SE2 

		JOIN  %Table:SA2% SA2 ON SA2.A2_FILIAL =  %Exp:xFilial('SA2')%
		AND SA2.A2_COD = SE2.E2_FORNECE 
		AND SA2.A2_LOJA = SE2.E2_LOJA 
		AND SA2.D_E_L_E_T_ ='' 

		JOIN  %Table:SED% SED ON SED.ED_FILIAL =  %Exp:xFilial('SED')%
		AND SED.ED_CODIGO = SE2.E2_NATUREZ 
		AND SED.D_E_L_E_T_ ='' 

		// A Serrana atualmente cadastra todos seus funcionarios na empresa 01.
		JOIN SRA010 SRA ON SRA.RA_FILIAL =  '1001' //%Exp:xFilial('SRA')%
		AND SRA.RA_YFORN = SE2.E2_FORNECE 
		AND SRA.RA_CATFUNC = 'A' 
		AND SRA.RA_SITFOLH <> 'D'
		AND SRA.D_E_L_E_T_ ='' 

		LEFT JOIN  %Table:DT7% DT7 ON DT7.DT7_FILIAL =  %Exp:xFilial('DT7')%
		AND DT7.DT7_CODDES = SE2.E2_YCODDES 
		AND DT7.D_E_L_E_T_ ='' 

		LEFT JOIN  %Table:SRV% SRV ON SRV.RV_FILIAL =  %Exp:xFilial('SRV')%
		AND SRV.RV_COD = DT7.DT7_YVERBA 
		AND SRV.D_E_L_E_T_ ='' 

		WHERE SE2.D_E_L_E_T_ ='' 
		AND SE2.E2_NUMLIQ = ''
		AND SE2.E2_FATURA <> 'NOTFAT' 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltAba% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltAnt% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltNeg% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltProv% 
		AND SE2.E2_TIPO NOT IN %Exp:cFiltRec% 
		AND SE2.E2_FILORIG 	=  %Exp:cFilAnt%
		AND SE2.E2_FORNECE  =  %Exp:cFornece%
		AND SE2.E2_LOJA  =%Exp:cLoja%
		AND SE2.E2_NUM  =%Exp:cNumero%
		AND SE2.E2_PREFIXO  =%Exp:cPrefixo%
		
		ORDER BY SE2.R_E_C_N_O_

	EndSql

	TcSetField(cAliasSE2,'E2_EMISSAO','D')
	TcSetField(cAliasSE2,'RA_ADMISSA','D')

Return

/*/{Protheus.doc} Cabecalho
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 13/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nLinha, numeric, description
@type function
/*/
Static Function Cabecalho(nLinha)

	Local cLogo   	:= FisxLogo("1")
	Local cPamCard	:= ""

	Default nLinha := 0

	// Posiciona no primeiro registro
	(cAliasSE2)->(DbGoTop())

	oPrinter:Box(nLinha + 50,0105,nLinha + 156,1934)
	oPrinter:Say(nLinha + 91,0133,"Nome:",oArial13N,,0)
	oPrinter:Say(nLinha + 134,0133,Alltrim((cAliasSE2)->A2_NOME),oArial11,,0)

	oPrinter:Box(nLinha + 50,1934,nLinha + 156,2333)
	oPrinter:Say(nLinha + 91,1955,"Código",oArial13N,,0)
	oPrinter:Say(nLinha + 134,1955,Alltrim((cAliasSE2)->E2_FORNECE),oArial11,,0)

	//nLinha := nLinha - 2
	oPrinter:Box(nLinha + 156,0105,nLinha + 243,0884)
	oPrinter:Say(nLinha + 192,0133,"Data Admissão:",oArial13N,,0)
	oPrinter:Say(nLinha + 231,0133,DTOC((cAliasSE2)->RA_ADMISSA),oArial11,,0)

	oPrinter:Box(nLinha + 156,0884,nLinha + 243,1563)
	oPrinter:Say(nLinha + 192,0910,"CPF:",oArial13N,,0)
	oPrinter:Say(nLinha + 231,0910,Alltrim((cAliasSE2)->A2_CGC),oArial11,,0)

	oPrinter:Box(nLinha + 156,1561,nLinha + 243,2333)

	cPamCard := (cAliasSE2)->RA_YPAMCAR

	If !Empty(cPamCard)
		//oPrinter:Box(nLinha + 156,1934,nLinha + 243,2333)
		oPrinter:Say(nLinha + 192,1955,"PamCard",oArial13N,,0)
		oPrinter:Say(nLinha + 231,1955,cPamCard,oArial11,,0)
	End If

	oPrinter:Say(nLinha + 192,1591,"Matrícula:",oArial13N,,0)
	oPrinter:Say(nLinha + 231,1591,Alltrim((cAliasSE2)->RA_FICHA),oArial11,,0)

	//Posição para ajustar o grid
	nPosLine := nLinha + 243

	oPrinter:Say(nLinha + 280,0142,"Código"			,oArial10N,,0)
	oPrinter:Say(nLinha + 280,0324,"Descrição"		,oArial10N,,0)
	oPrinter:Say(nLinha + 280,1071,"Competência"	,oArial10N,,0)
	oPrinter:Say(nLinha + 280,1341,"Referência"		,oArial10N,,0)
	oPrinter:Say(nLinha + 280,1591,"Vencimentos"	,oArial10N,,0)
	oPrinter:Say(nLinha + 280,1955,"Descontos"		,oArial10N,,0)

	//oPrinter:Line(nLinha +  244, 0105, nLinha + 244, 2334) // Superior
	oPrinter:Line(nLinha +  294, 0105, nLinha + 294, 2334) // Inferior

	//Informo a ultima linha usada pelo cabecalho
	nLinha += 300

Return nLinha

/*/{Protheus.doc} printPage
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 13/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function printPage(aObs,nLinha)

	Local aVerbas	:= {}

	Local cVerb0218  := POSICIONE("SRV",2,xFilial('SRV') + "0218","RV_COD") //Autonomo
	Local cVerb1565  := POSICIONE("SRV",2,xFilial('SRV') + "1565","RV_COD") //Frete - Sem Incidência
	Local cVerb1564  := POSICIONE("SRV",2,xFilial('SRV') + "1564","RV_COD") //Frete - Incidência IRRF
	Local cVerb1563  := POSICIONE("SRV",2,xFilial('SRV') + "1563","RV_COD") //Frete - Incidência INSS
	Local cVerb0064	 := POSICIONE("SRV",2,xFilial('SRV') + "0064","RV_COD") //Desconto INSS
	Local cVerb0066	 := POSICIONE("SRV",2,xFilial('SRV') + "0066","RV_COD") //Desconto IRRF
	Local cVerb0437	 := POSICIONE("SRV",2,xFilial('SRV') + "0437","RV_COD") //Desconto SEST
	Local cVerb1456	 := POSICIONE("SRV",2,xFilial('SRV') + "1456","RV_COD") //Desconto SENAT
	Local cNatCTCTMS := SuperGetMV("MV_NATCTC",.f.,"")
	Local cNatureza	 := SuperGetMV("MV_YNATFRT",.f.,cNatCTCTMS)
	Local lRndSest   := SuperGetMv("MV_RNDSEST",.F.,.F.)
	Local lDedINS 	 := SuperGetMv("MV_INSIRF",.F.,"2") == "1"
	Local nVlrVenc	 := 0
	Local nVlrDesc	 := 0
	Local nVlrBIRRF	 := 0
	Local nVlrBINSS	 := 0
	Local cDescVerba := ""
	Local nPBASEIRRF := 0
	Local nPIRRF	 := 0

	Local nPos		 := 0
	Local nSemIndi	 := 0
	Local i			 := 0

	SRV->(DbSetOrder(1))
	SED->(DbSetOrder(1))

	// Imprime o cabecalho
	//nLinha := Cabecalho(nLinha)
	//nLinha += 50 //Ajuste para primeiro dado não ficar colado com cabeçalho

	// Realiza o aglutinado das verbas
	While(cAliasSE2)->(!EOF())

		SED->(DbSeek(xFilial("SED") + (cAliasSE2)->E2_NATUREZ))

		cDescVerba := ""

		If Alltrim((cAliasSE2)->E2_TIPO) $ "NDF"

			SRV->(DbSeek(xFilial("SRV") + (cAliasSE2)->RV_COD))

			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Nota Debito a Fornecedor com as despesas do CMV
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim((cAliasSE2)->RV_COD)})
			If nPos == 0
				AADD(aVerbas, {(cAliasSE2)->RV_COD,(cAliasSE2)->E2_VALOR,cDescVerba,"D",Ctod("//"),0})
			Else
				aVerbas[nPos][2] += (cAliasSE2)->E2_VALOR
			End if


			// Foi solicitado pela Serrana nao desmembrar no recibo, desta forma, coloco como falso este trecho.
			// Verifica se esta natureza ela desmembra em varias verbas
		ElseIf Alltrim((cAliasSE2)->E2_NATUREZ) $ Alltrim(cNatureza) .and. .f.

			SRV->(DbSeek(xFilial("SRV") + cVerb1564))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Frete com indicencia de IRRF - ID 1564
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1564)})
			If nPos == 0
				AADD(aVerbas, {cVerb1564,(cAliasSE2)->E2_BASEIRF,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,0})
			Else
				aVerbas[nPos][2] += (cAliasSE2)->E2_BASEIRF
			End if

			SRV->(DbSeek(xFilial("SRV") + cVerb1563))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Frete com indicencia de INSS - ID 1563
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1563)})
			If nPos == 0
				AADD(aVerbas, {cVerb1563,(cAliasSE2)->E2_BASEINS,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,0})
			ELse
				aVerbas[nPos][2] += (cAliasSE2)->E2_BASEINS
			EndiF

			SRV->(DbSeek(xFilial("SRV") + cVerb1565))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Frete sem indicencia - ID 1565
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1565)})
			nSemIndi := (cAliasSE2)->E2_VALOR - (cAliasSE2)->E2_BASEIRF - (cAliasSE2)->E2_BASEINS
			If nPos == 0
				AADD(aVerbas, {cVerb1565,nSemIndi,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,0})
			Else
				aVerbas[nPos][2] += nSemIndi
			End iF

			// Totalizadores de Bases P/ PROVENTOS
			nVlrBIRRF += (cAliasSE2)->E2_BASEIRF
			nVlrBINSS += (cAliasSE2)->E2_BASEINS

		Else

			// Serrana solicitou que agora o valor da verba do provento seja pego
			// do cadastro da natureza, antes estava pegando tudo do Id de calculo
			// 0218.

			cVerb0218 := SED->ED_YVERBA

			SRV->(DbSeek(xFilial("SRV") + cVerb0218))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			//Pagamento Autonomo - ID 0218
			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0218)})
			If nPos == 0

				// Recupera os numeros de dias trabalhados nos contratos.
				cDiasTrab := GetDiasTrb((cAliasSE2)->E2_MDCONTR, (cAliasSE2)->E2_MEDNUME, (cAliasSE2)->E2_MDPLANI,(cAliasSE2)->E2_MDREVIS)

				AADD(aVerbas, {cVerb0218,(cAliasSE2)->E2_VALOR,cDescVerba,"V",(cAliasSE2)->E2_EMISSAO,cDiasTrab})
			ELse
				aVerbas[nPos][2] += (cAliasSE2)->E2_VALOR
			EndiF

			// Totalizadores de Bases P/ PROVENTOS
			nVlrBIRRF += (cAliasSE2)->E2_BASEIRF
			nVlrBINSS += (cAliasSE2)->E2_BASEINS
		End if


		//============== IMPOSTOS RECOLHIDOS ============================//

		// INSS
		SRV->(DbSeek(xFilial("SRV") + cVerb0064))
		cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

		nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0064)})
		If nPos == 0
			AADD(aVerbas, {cVerb0064,(cAliasSE2)->E2_INSS,cDescVerba,"D",Ctod("//"),SED->ED_BASEINS})
		Else
			aVerbas[nPos][2] += (cAliasSE2)->E2_INSS
		End iF

		// IRRF
		SRV->(DbSeek(xFilial("SRV") + cVerb0066))
		cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

		// Recupera o percentual da faixa do IRRF
		//IRRF Progressivo para pessoas jurídicas, o cálculo deve ser executado igual ao cálculo de pessoa física
		If lDedINS .and. ( Alltrim( (cAliasSE2)->A2_TIPO ) == "F" .or. Alltrim( (cAliasSE2)->A2_IRPROG ) == "1")

			// Retira da base do IRRF o valor do INSS, pois o financeiro guarda essa informacao bruta, porem, existe
			// o parametro que deduz o INSS da base do IRRF.

			If nVlrBIRRF >= (cAliasSE2)->E2_INSS
				nVlrBIRRF -= (cAliasSE2)->E2_INSS
			End IF

			nPIRRF := Fa050TabIr( (cAliasSE2)->E2_BASEIRF - (cAliasSE2)->E2_INSS  )

		Else
			nPIRRF := Fa050TabIr( (cAliasSE2)->E2_BASEIRF)
		End If


		// Verifica qual e a base do IR
		If Alltrim(SED->ED_IRRFCAR) == 'S'
			nPBASEIRRF := SED->ED_BASEIRC
		Else
			If SED->ED_BASEIRF == 0
				nPBASEIRRF := 100
			Else
				nPBASEIRRF := SED->ED_BASEIRF
			End iF
		End If

		nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0066)})
		If nPos == 0
			AADD(aVerbas, {cVerb0066,(cAliasSE2)->E2_IRRF,cDescVerba,"D",Ctod("//"),nPIRRF})
		Else
			aVerbas[nPos][2] += (cAliasSE2)->E2_IRRF
		EndIf

		// SEST/SENAT
		nValor 	   := (cAliasSE2)->E2_VALOR
		nPercSEST  := (cAliasSE2)->E2_YPSEST
		nPercSENAT := (cAliasSE2)->E2_YPSENAT

		// Verifica se este titulo calculou SEST/SENAT
		If (cAliasSE2)->E2_SEST > 0

			//SEST
			nBaseSEST := Iif(lRndSest,Round((nValor 	* (SED->ED_BASESES/100)),2),NoRound((nValor    * (SED->ED_BASESES/100)),2))
			nVlrSEST  := Iif(lRndSest,Round((nBaseSEST 	* (nPercSEST/100)),2)  	   ,NoRound((nBaseSEST * (nPercSEST/100)),2))

			// Verifica se ja existe a verba do SEST
			SRV->(DbSeek(xFilial("SRV") + cVerb0437))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb0437)})
			If nPos == 0
				AADD(aVerbas, {cVerb0437,nVlrSEST ,cDescVerba,"D",Ctod("//"),nPercSEST})
			Else
				aVerbas[nPos][2] += nVlrSEST
			EndIf

			//SENAT
			SRV->(DbSeek(xFilial("SRV") + cVerb1456))
			cDescVerba := IIF(!Empty(SRV->RV_YDESC),SRV->RV_YDESC,SRV->RV_DESC)

			nPos := Ascan(aVerbas,{|w|Alltrim(w[1]) == Alltrim(cVerb1456)})
			If nPos == 0
				AADD(aVerbas, {cVerb1456,(cAliasSE2)->E2_SEST - nVlrSEST ,cDescVerba,"D",Ctod("//"),nPercSENAT})
			Else
				// Pega o valor que o financeiro calculou e subtrai o valor do SENAT
				aVerbas[nPos][2] += (cAliasSE2)->E2_SEST - nVlrSEST
			EndIf
		End If

		(cAliasSE2)->(DbSkip())
	EndDo

	//Verificando se a quantidade de verba cabe no restante da pagina
	if(nLinha + (Len(aVerbas) * 50) > 2500)
		nLinha := 0
		oPrinter:EndPage()
		oPrinter:StartPage()
		nLinha := topoPag(nLinha)
		nLinha := Cabecalho(nLinha)
		nLinha += 50
	else
		nLinha := Cabecalho(nLinha)
		nLinha += 50 //Ajuste para primeiro dado não ficar colado com cabeçalho

	EndIf

	// Imprime as verbas
	For i:= 1 to Len(aVerbas)

		// Imprime verbas apenas com valores
		If aVerbas[i][2] == 0
			Loop
		End IF

		// Codigo da Verba
		oPrinter:Say(nLinha,0142,aVerbas[i][1],oArial12,,0)
		// Descricao da Verba
		oPrinter:Say(nLinha,0324,aVerbas[i][3],oArial12,,0)

		// Referencia
		If !Empty(aVerbas[i][6])


			If ValType(aVerbas[i][6]) == "N"
				oPrinter:Say(nLinha,1341,cValToChar(aVerbas[i][6]),oArial12,,0)
			Else
				oPrinter:Say(nLinha,1341,aVerbas[i][6],oArial12,,0)
			End If

		End If

		// Vencimentos
		If aVerbas[i][4] == "V"

			// Mes de competencia
			oPrinter:Say(nLinha,1071, SUBSTR(MesExtenso(Month(aVerbas[i][5])),1,3) + "/" + cvaltochar(Year(aVerbas[i][5])) ,oArial12,,0)

			// Vencimento
			oPrinter:Say(nLinha,1591,Alltrim(cvaltochar(TRANSFORM(aVerbas[i][2], X3Picture("E2_VALOR")))),oArial12,,0)

			nVlrVenc += aVerbas[i][2]
		Else
			// Descontos
			oPrinter:Say(nLinha,1955,Alltrim(cvaltochar(TRANSFORM(aVerbas[i][2], X3Picture("E2_VALOR")))),oArial12,,0)
			nVlrDesc += aVerbas[i][2]
		EndIf

		//Totais dos grupos
		nPos := Ascan(aTotais,{|w|Alltrim(w[1]) == Alltrim(aVerbas[i][1])})
		If nPos == 0
			AADD(aTotais, {aVerbas[i][1],aVerbas[i][3],1,;
				iif(aVerbas[i][4] == "V",aVerbas[i][2],0),;
				iif(aVerbas[i][4] <> "V",aVerbas[i][2],0) })
		Else
			aTotais[nPos][3]++ // Quantidade
			aTotais[nPos][4]+= iif(aVerbas[i][4] == "V",aVerbas[i][2],0) //valor do vencimento
			aTotais[nPos][5]+= iif(aVerbas[i][4] <> "V",aVerbas[i][2],0)  //valor do vencimento

		End if

		nLinha += 50

	Next

	oPrinter:Line( nPosLine, 0105, nLinha, 0105) // Codigo
	oPrinter:Line( nPosLine, 0300, nLinha, 0300) // Descricao
	oPrinter:Line( nPosLine, 1047, nLinha, 1047) // Compentencia
	oPrinter:Line( nPosLine, 1317, nLinha, 1317) // Referencia
	oPrinter:Line( nPosLine, 1561, nLinha, 1561) // Vencimentos
	oPrinter:Line( nPosLine, 1932, nLinha, 1932) // Descontos
	oPrinter:Line( nPosLine, 2334, nLinha, 2334) // Descontos
	oPrinter:Line( nLinha, 0105, nLinha, 2334) // Inferior

	nLinha += 30 // espaço para o rodape

	// Imprime o totalizador
	nLinha := RODAPE(nLinha,nVlrVenc,nVlrDesc,nVlrBIRRF,nVlrBINSS)


	//nLinha := nLinha - 1480
	// Imprime as observacoes
	//nLinha := IMPOBS(nLinha,aObs)

	// Imprime o texto
	//nLinha := IMPTEXTO(nLinha)

Return nLinha


/*/{Protheus.doc} RODAPE
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 13/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nLinha, numeric, description
@param nVlrVenc, numeric, description
@param nVlrDesc, numeric, description
@param nVlrBIRRF, numeric, description
@param nVlrBINSS, numeric, description
@type function
/*/
Static Function RODAPE(nLinha,nVlrVenc,nVlrDesc,nVlrBIRRF,nVlrBINSS)

	Local nTest1 := 0
	Local nTest2 := 0
	// Verifica se a pagina atual comporta imprimir
	// o rodape com os totalizadores. (420 o tamamnho do rodape )
	If nTotMax - nLinha <= 420
		nLinha := 0
		oPrinter:EndPage()
		oPrinter:StartPage()
		nLinha := topoPag(nLinha)
		nLinha := Cabecalho(nLinha)
	End If

	/*
	oPrinter:Box(nLinha + 007,0105,nLinha + 410,2335) // Box assinatura
	oPrinter:Box(nLinha + 007,0105,nLinha + 257 ,2335) // Box Duvidas

	oPrinter:Say(nLinha + 44 ,0142,"Dúvidas, Reclamações e Sugestões ligue ou acesse:",oArial13N,,0)
	oPrinter:Say(nLinha + 88 ,0142,"(28) 3517-4382 | (28) 99972-0249 | (28) 99959-3360",oArial12,,0)
	oPrinter:Say(nLinha + 128,0142,"www.serrana.coop.br ",oArial12,,0)
	oPrinter:Say(nLinha + 164,0142,"www.facebook.com/serranacoop",oArial12,,0)
	oPrinter:Say(nLinha + 201,0142,"www.instagram.com/serranacoop",oArial12,,0)
	oPrinter:Say(nLinha + 319,0142,"DATA : __________/__________/_____________",oArial10N,,0)
	oPrinter:Say(nLinha + 319,1068,"_______________________________________________________________",oArial10N,,0)
	oPrinter:Say(nLinha + 355,1495,"ASSINATURA",oArial10N,,0)
	*/

	nLinha := nLinha - 66

	oPrinter:Box(nLinha + 007,0105, nLinha + 139, 2333)//Box Total
	oPrinter:Say(nLinha + 048,nTest2 + 0133,"Total de Vencimentos:",oArial12,,0)
	oPrinter:Say(nLinha + 048,nTest2 + 0428,"R$ " + Alltrim(cvaltochar(TRANSFORM(nVlrVenc, X3Picture("E2_VALOR")))),oArial12,,0)

	//oPrinter:Box(nLinha + 130,1225,nLinha + 257,1561)	// Box INSS
	oPrinter:Say(nLinha + 090, 0133,"Base INSS:",oArial12,,0)
	oPrinter:Say(nLinha + 090, 0428,"R$ " + Alltrim(cvaltochar(TRANSFORM(nVlrBINSS, X3Picture("E2_VALOR")))),oArial12,,0)

	//oPrinter:Box(nLinha + 130,1561,nLinha + 257,1934) // Box total Descontos
	oPrinter:Say(nLinha + 052,700,"Total de Descontos:",oArial12,,0)
	oPrinter:Say(nLinha + 052,970,"R$ " + Alltrim(cvaltochar(TRANSFORM(nVlrDesc, X3Picture("E2_VALOR")))),oArial12,,0)

	//oPrinter:Box(nLinha + 007,1225,nLinha + 139,1561) // Box do IRRF
	oPrinter:Say(nLinha + 048, 1311,"Base IRRF:",oArial12,,0)
	oPrinter:Say(nLinha + 048, 1480,"R$ " + Alltrim(cvaltochar(TRANSFORM(nVlrBIRRF, X3Picture("E2_VALOR")))),oArial12,,0)

	oPrinter:Say(nLinha + 090,700,"Valor Líquido:",oArial12,,0)
	oPrinter:Say(nLinha + 090,970,"R$ " + Alltrim( cvaltochar(TRANSFORM(nVlrVenc - nVlrDesc, X3Picture("E2_VALOR")))),oArial12N,,0)

	// Retorno a ultima posicao da linha
	nLinha += 130

Return nLinha


/*/{Protheus.doc} IMPOBS
Imprime as observacoes informado na chamada o relatorio
@author Totvs Vitoria - Mauricio Silva
@since 27/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nLinha, numeric, description
@param aObs, array, description
@type function
/*/
Static Function IMPOBS(nLinha,aObs)

	Local p := 0

	// Pulo 100 linhas para separar os conteudos.
	nLinha += 50

	If Len(aObs) > 0

		oPrinter:Say(nLinha,0105,"Observações",oArial13N,,0)

		nLinha += 40

		For p := 1 to len(aObs)

			// Caso a observacao for muito grande, trate se chegar no final
			// do relatorio ele criar novamente uma nova pagina.
			If nLinha >= nTotMax
				oPrinter:EndPage()
				oPrinter:StartPage()
				nLinha := Cabecalho()
			End If

			oPrinter:Say(nLinha,0105,aObs[p],oArial13N,,0)
			nLinha += 30

		Next
	End If
Return nLinha


/*/{Protheus.doc} IMPTEXTO
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 13/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nLinha, numeric, description
@type function
/*/
Static Function IMPTEXTO(nLinha)

	Local aTexto	:= {}
	Local cTexto	:= ""
	Local aMemo		:= {}
	Local nI		:= 0

	// Pulo 100 linha para separar os conteudos
	nLinha += 100

	AADD(aTexto,'BASE DE RECOLHIMENTO - Base para recolhimento conforme Decreto 4.729 de 09 de junho de 2003, Art. 55, inciso 2°, sancionado pelo Exmo. Presidente Da República,')
	AADD(aTexto,'Luiz Inácio Lula Da Silva. "O salário de contribuição do condutor autônomo de veículo (inclusive o taxista), do auxiliar de condutor autônomo e do operador de máquinas, bem')
	AADD(aTexto,'como do cooperado filiado a cooperativa de transportadores autônomos, conforme estabelecido no inciso 4° do art. 201 RPS, corresponde a 20% ( vinte')
	AADD(aTexto,'por cento) do valor bruto auferido pelo frete". [...]')
	AADD(aTexto,'ALIQUOTA INSS - Instrução Normativa RFB nº 971, de 13 de novembro de 2009 e Ato Declaratório Executivo Codac nº 14, de 02 de junho de 2015, a alíquota é de 20%')
	AADD(aTexto,'(vinte por cento) para cálculo do desconto da contribuição previdenciária devida: II - código 25: Contribuinte individual - Transportador cooperado que presta serviços a')
	AADD(aTexto,'entidade beneficente de assistência social isenta da cota patronal ou a pessoa física, por intermédio da cooperativa de trabalho. § 2º O procedimento descrito neste artigo')
	AADD(aTexto,'aplica-se à contribuição previdenciária sobre a remuneração dos cooperados pelos serviços prestados a quaisquer pessoas, físicas ou jurídicas, isentas ou não da cota patronal. ')
	AADD(aTexto,'RECOLHIMENTO MINIMO - De acordo com o Decreto n° 3.048 de 06 de maio de 1999, Art. 216 Inciso 27, sancionado pelo Exmo. Presidente Da República, Fernando ')
	AADD(aTexto,'Henrique Cardoso. "O contribuinte individual contratado por pessoa jurídica obrigada a proceder à arrecadação e ao recolhimento da contribuição por ele devida, cuja')
	AADD(aTexto,'remuneração recebida ou creditada no mês, por serviços prestados a ela, for inferior ao limite mínimo do salário - de contribuição, é obrigado a')
	AADD(aTexto,'complementar sua contribuição mensal". [...] Sendo assim o cooperado deve em vida fazer o complemento das contribuições que não chegarem ao mínimo devido por')
	AADD(aTexto,'mês. Outrossim, os dependentes não podem fazer tal recolhimento caso ocorra o falecimento do mesmo. Ressalta-se que, a falta de complementação da contribuição')
	AADD(aTexto,'previdenciária poderá acarretar o indeferimento do pedido de aposentadoria por tempo de contribuição, vez que, o recolheu com base inferior ao mínimo legal.')


	cTexto += 'BASE DE RECOLHIMENTO - Base para recolhimento conforme Decreto 4.729 de 09 de junho de 2003, Art. 55, inciso 2°, sancionado pelo Exmo. Presidente Da República, Luiz Inácio Lula Da Silva. "O salário de contribuição do condutor autônomo de veículo (inclusive o taxista), do auxiliar de condutor autônomo e do operador de máquinas, bem como do cooperado filiado a cooperativa de transportadores autônomos, conforme estabelecido no inciso 4° do art. 201 RPS, corresponde a 20% ( vinte por cento) do valor bruto auferido pelo frete". [...]
	cTexto += Chr(13) + Chr(10)
	cTexto += 'ALIQUOTA INSS - Instrução Normativa RFB no 971, de 13 de novembro de 2009 e Ato Declaratório Executivo Codac no 14, de 02 de junho de 2015, a alíquota é de 20% (vinte por cento) para cálculo do desconto da contribuição previdenciária devida: II - código 25: Contribuinte individual - Transportador cooperado que presta serviços a entidade beneficente de assistência social isenta da cota patronal ou a pessoa física, por intermédio da cooperativa de trabalho. § 2o O procedimento descrito neste artigo aplica-se à contribuição previdenciária sobre a remuneração dos cooperados pelos serviços prestados a quaisquer pessoas, físicas ou jurídicas, isentas ou não da cota patronal.
	cTexto += Chr(13) + Chr(10)
	cTexto += 'RECOLHIMENTO MINIMO - De acordo com o Decreto n° 3.048 de 06 de maio de 1999, Art. 216 Inciso 27, sancionado pelo Exmo. Presidente Da República, Fernando Henrique Cardoso. "O contribuinte individual contratado por pessoa jurídica obrigada a proceder à arrecadação e ao recolhimento da contribuição por ele devida, cuja remuneração recebida ou creditada no mês, por serviços prestados a ela, for inferior ao limite mínimo do salário - de contribuição, é obrigado a complementar sua contribuição mensal". [...] Sendo assim o cooperado deve em vida fazer o complemento das contribuições que não chegarem ao mínimo legal.



	//
	//
	//
	//	For p := 1 to len(aTexto)
	//
	//		cTexto += aTexto[p] + " "
	//
	//	Next

	nMemCount := MlCount( cTexto,130 )
	aMemo := {}

	For nI := 1 To nMemCount
		AAdd( aMemo , AllTrim(MemoLine( cTexto, 130, nI ,3,.f.)) )
	Next nI


	For nI:= 1 To Len(aMemo)

		// Caso a observacao for muito grande, trate se chegar no final
		// do relatorio ele criar novamente uma nova pagina.
		If nLinha >= nTotMax
			oPrinter:EndPage()
			oPrinter:StartPage()
			nLinha := Cabecalho()
		End If
		oPrinter:Say(nLinha,0105,aMemo[nI]                             ,Courier12)
		nLinha += 30
	Next nI

	//	For p := 1 to len(aTexto)
	//
	//		// Caso a observacao for muito grande, trate se chegar no final
	//		// do relatorio ele criar novamente uma nova pagina.
	//		If nLinha >= nTotMax
	//			oPrinter:EndPage()
	//			oPrinter:StartPage()
	//			nLinha := Cabecalho()
	//		End If
	//
	//		oPrinter:Say(nLinha,0105,aTexto[p],oArial12,,0)
	//		nLinha += 30
	//
	//	Next

Return nLinha

/*/{Protheus.doc} Fa050TabIr
Recupera o Percetual da tabela do IRRF
@author kenny.roger
@since 27/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nValTitulo, numeric, description
@type function
/*/
Static Function Fa050TabIr( nValTitulo )

	Local nValor:=0,nHdlIrf,nBytes:=0,nTamArq,aTabela:={},lTabela:=.f.,i
	Local nLimInss := GetMv("MV_LIMINSS",.F.,0)
	Local lDedIns	 := (SuperGetMv("MV_INSIRF",.F.,"2") == "1")
	Local lComisVend:= FunName()=="MATA530"
	Local lRound := GetNewPar( "MV_RNDIRF", .T. ) //Arredonda valor do imposto.
	Local lFINA050	:= FunName() $ "FINA050" .or. (FwIsInCallStacK("Fin750050"))
	Local lAluguel	:= 	.T.
	Local lRet		:= .T.
	Local nPercIRRF	:= 0

	nHdlIrf:=FOPEN("SIGAADV.IRF",64)
	If nHdlIrf<0
		Help(" ",1,"TABIRRF")
		Return 0
	EndIf

	nTamArq:=FSEEK(nHdlIrf,0,2)
	FSEEK(nHdlIrf,0,0)			 // Volta para inicio do arquivo

	While nBytes<nTamArq
		xBuffer:=Space(40)
		FREAD(nHdlIrf,@xBuffer,40)
		AADD(aTabela,{Val(SubStr(xBuffer,1,15)),Val(SubStr(xBuffer,17,6)),Val(SubStr(xBuffer,24,15))})
		nBytes+=40
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Este If Len(atabela) == 5 foi colocado pois o txt gravado pelo  ³
		//³ windows dava uma dIferen‡a no registro do End of file, gerando  ³
		//³ uma linha a mais no arquivo TXT.										  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aTabela ) == 5
			Exit
		EndIf
	End

	nValor := 0

	For i = 1 to Len(aTabela)
		If !lTabela
			If nValTitulo<=aTabela[i][1] .or. i = Len(aTabela)
				If lDedIns .And. lComisVend
					nValor:= nValTitulo-nLimInss
					nValor:= nValor*aTabela[i][2]/100
					nValor:= nValor-aTabela[i][3]
					nValor := NoRound(nValor, MsDecimais(2))
					nPercIRRF := aTabela[i][2]
				Else
					nPercIRRF := aTabela[i][2]
					If lRound
						nValor:= Round(nValTitulo*Iif(aTabela[i][2]>0,aTabela[i][2],0)/100,2)-aTabela[i][3]
					Else
						nValor:= NoRound(nValTitulo*Iif(aTabela[i][2]>0,aTabela[i][2],0)/100)-aTabela[i][3]
					Endif
				Endif
				lTabela:=.T.
			EndIf
		EndIf
	Next

	FCLOSE(nHdlIrf)

	nValor := IIF(nValor<0,0,nValor)
Return(nPercIRRF)

/*/{Protheus.doc} GetDiasTrb
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 09/09/2020
@version 1.0
@return ${return}, ${return_description}
@param cContrato, characters, description
@param cMedicao, characters, description
@param cPlan, characters, description
@type function
/*/
Static Function GetDiasTrb(cContrato, cMedicao, cPlan,cRevi)

	Local cAliasCNE := GetNextAlias()
	Local cDiasTrab := ""

	BeginSQL Alias cAliasCNE
	
	   SELECT * FROM %Table:CNE% CNE
	   WHERE CNE.CNE_FILIAL = %Exp:xFilial("CNE")%
	   AND CNE.CNE_CONTRA = %Exp:cContrato%
	   AND CNE.CNE_NUMMED = %Exp:cMedicao%
	   AND CNE.CNE_NUMERO = %Exp:cPlan%
	   AND CNE.CNE_REVISA = %Exp:cRevi%
	   AND CNE.D_E_L_E_T_ =''
	
	EndSQL

	While(cAliasCNE)->(!EOF())

		cDiasTrab += cValtochar((cAliasCNE)->(CNE_QUANT)) + '/'

		(cAliasCNE)->(DbSkip())
	EndDo

	(cAliasCNE)->(DbCloseArea())

	cDiasTrab := SUBSTR(cDiasTrab,1,Len(cDiasTrab)-1)

Return cDiasTrab



 /*/{Protheus.doc} topo
	Topo da pagina com os dados da empresa
	@type  Function
	@author user
	@since 02/12/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
static Function topoPag(nLinha)
	Local nTeste := 0
	Default nLinha := 0

	oPrinter:Line(nLinha + 0050, 100,nLinha + 0050, 02333, 0)
	oPrinter:Say(nLinha + 0100,0100,Alltrim(SM0->M0_NOMECOM) ,oArial13N,,0)
	oPrinter:Say(nLinha + 0100,1765,"CNPJ:" + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99"),oArial13N,,0)
	oPrinter:Say(nLinha + 0130,0100,Alltrim(SM0->M0_FILIAL) ,oArial13N,,0)
	oPrinter:Say(nLinha + 0160,0100,Alltrim(SM0->M0_ENDENT) + " - "+Alltrim(SM0->M0_BAIRENT) +" - "+ Alltrim(SM0->M0_CIDENT)+" - "+Alltrim(SM0->M0_CEPENT) + " - " + "Telefone:" + Alltrim(SM0->M0_TEL) ,oArial11N,,0)
	oPrinter:Say(nLinha + 0190,0100,"Relatório de Folha de Pagamento",oArial11N,,0)
	oPrinter:Line(nLinha + 0210,100,nLinha + 0210,  02333, 0)
	oPrinter:Say(nLinha + 0240,0140,"Mês e Ano:",oArial11N,,0)
	oPrinter:Say(nLinha + 0240,310,SUBSTR(UPPER(MesExtenso(Month(SE2->E2_EMISSAO))),1,3)  + "/" + cvaltochar(Year(SE2->E2_EMISSAO)),oArial11N,,0)
	oPrinter:Say(nLinha + 0240,510,"Dt. Inclusão:",oArial11N,,0)
	oPrinter:Say(nLinha + 0240,700,DTOC(CND->CND_DTINIC),oArial11N,,0)

	oPrinter:Say(nLinha + 0240, 990,"Descr. Contra:",oArial11N,,0)
	oPrinter:Say(nLinha + 0240, 1200,CND->CND_YDESPR,oArial11N,,0)

	oPrinter:Say(nLinha + 270,0140,"Mediçao:",oArial11N,,0)
	oPrinter:Say(nLinha + 270,0270,CND->CND_NUMMED,oArial11N,,0)

	oPrinter:Say(nLinha + 270,510,"Contrato:",oArial11N,,0)
	oPrinter:Say(nLinha + 270,660,CND->CND_CONTRA,oArial11N,,0)


	nLinha := 0270
Return nLinha


user  Function Resul010(nLinha)

	Local nVal1 := 190
	Local nVal2 := 100
	Local nval3 := 0300
	Local nVal4 := 02333
	Local aValGr := {}

	Private oArial13N		:=	TFont():New("Arial",,13,,.T.,,,,,.F.,.F.)
	Private oArial11N		:=	TFont():New("Arial",,11,,.T.,,,,,.F.,.F.)
	Private oArial11  		:=	TFont():New("Arial",,11,,.F.,,,,,.F.,.F.)
	Private oArial8N		:=	TFont():New("Arial",,8,,.T.,,,,,.F.,.F.)
	Private oArial7  		:=	TFont():New("Arial",,7,,.F.,,,,,.F.,.F.)
	Private oArial9N		:=	TFont():New("Arial",,9,,.T.,,,,,.F.,.F.)
	Private oArial9  		:=	TFont():New("Arial",,9,,.F.,,,,,.F.,.F.)
	Private oArial10N		:=	TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
	Private oArial12  		:=	TFont():New("Arial",,12,,.F.,,,,,.F.,.F.)
	Private oArial12N  		:=	TFont():New("Arial",,12,,.T.,,,,,.F.,.F.)
	Private oArial14N		:=	TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Private Courier12  		:=	TFont():New("Courier",,12,,.F.,,,,,.F.,.F.)

	Default nLinha := 0

	//Criando nova pagina para o resultado final
	nLinha := 0
	oPrinter:EndPage()
	oPrinter:StartPage()

	nLinha += topoPag(nLinha)
	nLinha := nLinha - 130

	oPrinter:Say(nLinha + nVal1,nVal2,"RESUMO POR VERBA",oArial11N,,0)
	oPrinter:Line(nLinha + 200,nVal2,nLinha + 200, nVal4, 0)
	oPrinter:Say(nLinha + 230,950,"Quantidade",oArial11N,,0)
	oPrinter:Say(nLinha + 230,1150,"QTDE Hrs",oArial11N,,0)
	oPrinter:Say(nLinha + 230,1350,"Ativos",oArial11N,,0)
	oPrinter:Say(nLinha + 230,1550,"Férias",oArial11N,,0)
	oPrinter:Say(nLinha + 230,1750,"Demitidos",oArial11N,,0)
	oPrinter:Say(nLinha + 230,1950,"Outras",oArial11N,,0)
	oPrinter:Say(nLinha + 230,2150,"Totais",oArial11N,,0)
	oPrinter:Line(nLinha + 250,nVal2,nLinha + 250, nVal4, 0)
	nLinha += 250
	//Proventos
	oPrinter:Say(nLinha + 0030,nVal2,"Proventos",oArial11N,,0)
	nLinha+=10
	for nX := 1 to len(aTotais)

		//Agrupando para os totalizadores
		If len(aValGr) == 0
			aadd(aValGr,{aTotais[nX,1],aTotais[nX,2],aTotais[nX,3],aTotais[nX,4],aTotais[nX,5]})
		Else

			aValGr[1,4] += aTotais[nX,4] // Vencimento
			aValGr[1,5] += aTotais[nX,5] // Desconto
		End if

		//Montrando somente com vencimentos
		If aTotais[nX][4] == 0
			Loop
		End IF

		oPrinter:Say(nLinha + 0060,nVal2,aTotais[nX,1],oArial11,,0)
		oPrinter:Say(nLinha + 0060,200,aTotais[nX,2],oArial11,,0)
		oPrinter:Say(nLinha + 0060,950,AllTrim(cvaltochar(aTotais[nX,3])),oArial11,,0)
		oPrinter:Say(nLinha + 0060,1150,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,1350,AllTrim(cvaltochar(TRANSFORM(aTotais[nX,4], X3Picture("E2_VALOR")))),oArial11,,0)
		oPrinter:Say(nLinha + 0060,1550,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,1750,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,1950,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,2150,AllTrim(cvaltochar(TRANSFORM(aTotais[nX,4], X3Picture("E2_VALOR")))),oArial11,,0)

		nLinha += 40

	next
	//total grupo proventos
	oPrinter:Say(nLinha + 0060,200,"Total do Grupo:",oArial11N,,0)
	//oPrinter:Say(nLinha + 0060,950,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1150,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1350,AllTrim(cvaltochar(TRANSFORM(aValGr[1,4], X3Picture("E2_VALOR")))),oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1550,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1750,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1950,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,2150,AllTrim(cvaltochar(TRANSFORM(aValGr[1,4], X3Picture("E2_VALOR")))),oArial11N,,0)

	oPrinter:Line(nLinha + 0100,nVal2,nLinha + 0100, nVal4, 0)
	nLinha += 100

	//Descontos
	oPrinter:Say(nLinha + 0030,nVal2,"Descontos",oArial11N,,0)
	nLinha+=10
	for nX := 1 to len(aTotais)

		//Montrando somente com vencimentos
		If aTotais[nX][5] == 0
			Loop
		End IF

		oPrinter:Say(nLinha + 0060,nVal2,aTotais[nX,1],oArial11,,0)
		oPrinter:Say(nLinha + 0060,200,aTotais[nX,2],oArial11,,0)
		oPrinter:Say(nLinha + 0060,950,AllTrim(cvaltochar(aTotais[nX,3])),oArial11,,0)
		oPrinter:Say(nLinha + 0060,1150,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,1350,AllTrim(cvaltochar(TRANSFORM(aTotais[nX][5], X3Picture("E2_VALOR")))),oArial11,,0)
		oPrinter:Say(nLinha + 0060,1550,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,1750,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,1950,"0",oArial11,,0)
		oPrinter:Say(nLinha + 0060,2150,AllTrim(cvaltochar(TRANSFORM(aTotais[nX][5], X3Picture("E2_VALOR")))),oArial11,,0)
		nLinha += 40
	Next
	//total grupo
	oPrinter:Say(nLinha + 0060,200,"Total do Grupo:",oArial11N,,0)
	//oPrinter:Say(nLinha + 0060,950,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1150,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1350,AllTrim(cvaltochar(TRANSFORM(aValGr[1,5], X3Picture("E2_VALOR")))),oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1550,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1750,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1950,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,2150,AllTrim(cvaltochar(TRANSFORM(aValGr[1,5], X3Picture("E2_VALOR")))),oArial11N,,0)
	oPrinter:Line(nLinha + 0100,nVal2,nLinha + 0100, nVal4, 0)
	nLinha += 80

	//total liquido a pagar dos grupos
	oPrinter:Say(nLinha + 0060,200,"Total líquido a pagar:",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1350,AllTrim(cvaltochar(TRANSFORM((aValGr[1,4]-aValGr[1,5]), X3Picture("E2_VALOR")))),oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1550,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1750,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,1950,"0",oArial11N,,0)
	oPrinter:Say(nLinha + 0060,2150,AllTrim(cvaltochar(TRANSFORM((aValGr[1,4]-aValGr[1,5]), X3Picture("E2_VALOR")))),oArial11N,,0)
	oPrinter:Line(nLinha + 080,nVal2,nLinha + 080, nVal4, 0)


	//Descontos
	/*oPrinter:Line(nLinha + nVal1,nVal2,nLinha + nval3, nVal4, 0)
	oPrinter:Say(nLinha + nVal1,nVal2,"Total Liquido a Pagar:",oArial11N,,0)
	oPrinter:Say(nLinha + nVal1,nVal2,"24.910,38",oArial11N,,0)
	oPrinter:Say(nLinha + nVal1,nVal2,"Branco",oArial11N,,0)
	oPrinter:Say(nLinha + nVal1,nVal2,"Branco",oArial11N,,0)
	oPrinter:Say(nLinha + nVal1,nVal2,"Branco",oArial11N,,0)
	oPrinter:Say(nLinha + nVal1,nVal2,"24.910,38",oArial11N,,0)
	oPrinter:Line(nLinha + nVal1,nVal2,nLinha + nval3, nVal4, 0)
	*/
Return nLinha

