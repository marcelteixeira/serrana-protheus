#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"



/*/{Protheus.doc} CNT121BT
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function CNT121BT()

	Local aSerrana := {}

	AAdd( aSerrana, { 'Encerrar Medição' ,'U_EncerCMV' ,0,4} )
	AAdd( aSerrana, { 'Estornar Comp.' 	 ,'U_EstFinMED',0,4} )
	AAdd( aSerrana, { 'Estornar Medição' ,'U_EstMed'   ,0,4} )
	AAdd( aSerrana, { 'Imprimir RPC' 	 ,'U_RPCGCT'   ,0,4} )
	AAdd( aSerrana, { 'Imprimir Folha' 	 ,'U_RPCFOL'   ,0,4} )
	AAdd( aRotina, { 'Funções CMV' 		 ,aSerrana     ,0,4} )
	
	aAdd (aRotina, {'Cópia' 			,'u_cCNTA121()'	,0,9,0,NIL})

return


//Copia de Medição
User Function cCNTA121()

	Private lCNTA121 := .T.

	FWMsgRun(, {|| FWExecView("Inclusão de Medição","CNTA121",9,,{|| .T.}) },"Cópia de Inclusão de Medição","Excutando a Cópia..." )

Return


/*/{Protheus.doc} EncerCMV
Realiza o encerramento da medicao do contrato
com informacoes do CMV.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function EncerCMV()
	FWExecView("CMV","SERGCT02", MODEL_OPERATION_UPDATE, , { || .T. })
Return


/*/{Protheus.doc} RPCGCT
Imprime o RPC via medicao de contrato
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function RPCGCT()

	Local cAliasSE2 := GetNextAlias()
	Local cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),TAMSX3("E2_PREFIXO")[1])
	Local cTpTit	:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),TAMSX3("E2_TIPO")[1])
	Local cParcela	:= StrZero(1,TAMSX3("E2_PARCELA")[1])
	Local cForDe	:= PADL(" ",TamSX3("A2_COD")[1])
	Local cLojDE	:= PADL(" ",TamSX3("A2_LOJA")[1])
	Local cForAte	:= PADL("Z",TamSX3("A2_COD")[1],"Z")
	Local cLojAte	:= PADL("Z",TamSX3("A2_LOJA")[1],"Z")

	Local lRet		:= .t.
	Local aRet		:= {}
	Local aParamBox := {}
	Private lAdjustToLegacy := .T.
	Private lDisableSetup  	:= .T.
	Private oPrinter		:= Nil

	// Valida se a medicao se encontra encerrada
	IF CND->CND_SITUAC <> "E"
		cMsg  := "O status desta medição se encontra diferente de encerrada."
		cSolu := "Favor selecionar medição com status de encerrada."
		Help(NIL, NIL, "RPCGCT", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End IF

	aAdd(aParamBox, {1, "Fornecedor De" , cForDe,'','.T.','SA2','.T.',TAMSX3("A2_COD")[1] * 5,.F.})
	aAdd(aParamBox, {1, "Loja De" 		, cLojDE,'','.T.','','.T.',TAMSX3("A2_LOJA")[1] * 5,.F.})
	aAdd(aParamBox, {1, "Fornecedor Ate", cForAte,'','.T.','SA2','.T.',TAMSX3("A2_COD")[1] * 5,.F.})
	aAdd(aParamBox, {1, "Loja Ate" 		, cLojAte,'','.T.','','.T.',TAMSX3("A2_LOJA")[1] * 5,.F.})

	lRet := ParamBox(aParamBox, "Filtrar Fornecedores", aRet)

	If !lRet
		Return
	End If

	cForDe  := aRet[1]
	cLojDE  := aRet[2]
	cForAte := aRet[3]
	cLojAte := aRet[4]

	BeginSQL Alias cAliasSE2

		SELECT SE2.R_E_C_N_O_ AS SE2RECNO FROM %Table:SE2% SE2 

		// A Serrana atualmente cadastra todos seus funcionarios na empresa 01.
		JOIN SRA010 SRA ON SRA.RA_FILIAL =  '1001' //%Exp:xFilial('SRA')%
		AND SRA.RA_YFORN = SE2.E2_FORNECE 
		AND SRA.RA_CATFUNC = 'A' 	// Autonomo
		AND SRA.RA_SITFOLH <> 'D'	// Demitidos
		AND SRA.D_E_L_E_T_ ='' 		

		WHERE SE2.D_E_L_E_T_ =''
		AND SE2.E2_FILIAL  = %Exp:xFilial("SE2")%
		AND SE2.E2_MDCONTR = %Exp:CND->CND_CONTRA%
		AND SE2.E2_MEDNUME = %Exp:CND->CND_NUMMED%
		AND SE2.E2_PREFIXO = %Exp:cRetPrf%
		AND SE2.E2_TIPO    = %Exp:cTpTit%
		AND (SE2.E2_PARCELA = %Exp:cParcela% OR SE2.E2_PARCELA = '01')
		AND SE2.E2_FORNECE BETWEEN %Exp:cForDe% AND %Exp:cForAte%
		AND SE2.E2_LOJA	   BETWEEN %Exp:cLojDE% AND %Exp:cLojAte%

	EndSQL

	// Verifica se a query possui resultado
	If (cAliasSE2)->(EOF())
		cMsg  := "Não foi encontrados titulos no financeiro para esta medição onde os fornecedores envolvidos são cadastrados como autônomo (SRA)."
		cSolu := "Favor verificar se esta medição geram titulos no contas a pagar e que os fornecedores são considerados como autônomo."
		Help(NIL, NIL, "RPCGCT", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

	oPrinter := FWMSPrinter():New("SERR0002.rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup)

	oPrinter:SetResolution(72)
	oPrinter:SetPortrait()
	oPrinter:SetMargin(5,5,5,5) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:Setup()

	If !(oPrinter:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
		Return
	End if

	CN9->(DbSetOrder(1))

	While(cAliasSE2)->(!EOF())

		aObs := {}

		SE2->(DbGoTo((cAliasSE2)->SE2RECNO))

		cContrato := SE2->E2_MDCONTR
		cNumMedic := SE2->E2_MEDNUME
		cPlanilha := SE2->E2_MDPLANI

		CN9->(DbSeek(xFilial("CN9") + CND->(CND_CONTRA + CND_REVISA)))

		// Imprime o RPC, o titulo ja esta posicionado
		AADD(aObs,"CONTRATO: " + cContrato + " / MEDIÇÃO: " + cNumMedic + " / PLANILHA: " + cPlanilha + " / TITULO: " + SE2->(E2_FILIAL+ E2_PREFIXO+ E2_NUM+ E2_PARCELA+ E2_TIPO+ E2_FORNECE+ E2_LOJA))
		AADD(aObs,"DESCRIÇÃO: " + Alltrim(CND->CND_YDESPR))

		U_SERR0002(,,,,aObs,oPrinter)

		(cAliasSE2)->(DbSkip())
	EndDo
	oPrinter:Preview()
	(cAliasSE2)->(DbCloseArea())

Return

/*/{Protheus.doc} EstFinMED
Estorna a compensacao financeira das NDF
criadas pelo encerramento da medicao utilizando
o CMV
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function EstFinMED()

	Local cAliasSE2 := GetNextAlias()
	Local cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),TAMSX3("E2_PREFIXO")[1])
	Local cTpTit	:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),TAMSX3("E2_TIPO")[1])
	Local cParcela	:= StrZero(1,TAMSX3("E2_PARCELA")[1])
	Local nPosFor	:= 0
	Local aFor		:= {}
	Local aRecSE2	:= {}
	Local aRecNDF	:= {}
	Local aRetorno  := {{}}
	Local lRet		:= .t.
	Local cChave	:= ""


	IF CND->CND_SITUAC <> "E"
		cMsg  := "O status desta medição se encontra diferente de encerrada."
		cSolu := "Favor selecionar medição com status de encerrada."
		Help(NIL, NIL, "EstFinMED", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End IF


	If !MSGYESNO( "Deseja estornar as compensações financeiras?", "Estornar Titulos." )
		Return
	End If

	BeginSQL Alias cAliasSE2

		SELECT SE2.R_E_C_N_O_ AS SE2RECNO,E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA FROM %Table:SE2% SE2 

		// A Serrana atualmente cadastra todos seus funcionarios na empresa 01.
		JOIN SRA010 SRA ON SRA.RA_FILIAL =  '1001' //%Exp:xFilial('SRA')%
		AND SRA.RA_YFORN = SE2.E2_FORNECE 
		AND SRA.RA_CATFUNC = 'A' 	// Autonomo
		AND SRA.RA_SITFOLH <> 'D'	// Demitidos
		AND SRA.D_E_L_E_T_ ='' 

		WHERE SE2.D_E_L_E_T_ =''
		AND SE2.E2_FILIAL  = %Exp:xFilial("SE2")%
		AND SE2.E2_MDCONTR = %Exp:CND->CND_CONTRA%
		AND SE2.E2_MEDNUME = %Exp:CND->CND_NUMMED%
		AND SE2.E2_PREFIXO = %Exp:cRetPrf%
		AND (SE2.E2_TIPO   = %Exp:cTpTit% OR SE2.E2_TIPO = 'NDF')
		AND SE2.E2_PARCELA = %Exp:cParcela%

		ORDER BY SE2.E2_FORNECE,SE2.E2_LOJA

	EndSQL

	While (cAliasSE2)->(!EOF())

		nPosFor := Ascan(aFor,{|x|Alltrim(x[1]) == Alltrim((cAliasSE2)->E2_FORNECE)})

		If nPosFor == 0
			AADD(aFor,{(cAliasSE2)->E2_FORNECE,{{},{},{}}})
			nPosFor := len(aFor)
		End if

		If Alltrim((cAliasSE2)->E2_TIPO) == "NDF"
			AADD(aFor[nPosFor][2][2],(cAliasSE2)->SE2RECNO)

			cChave  := (cAliasSE2)->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO +  E2_FORNECE + E2_LOJA)
			cChave	:= PadR(cChave,TamSX3("E5_DOCUMEN")[1])
			AADD(aFor[nPosFor][2][3],{cChave})
		Else
			AADD(aFor[nPosFor][2][1],(cAliasSE2)->SE2RECNO)
		End if

		(cAliasSE2)->(DbSkip())
	EndDo

	For i:= 1 to len(aFor)

		aRecSE2 := aClone(aFor[i][2][1])
		aRecNDF := aClone(aFor[i][2][2])
		aRetorno:= aClone(aFor[i][2][3])

		If Len(aRecNDF) > 0

			FWMsgRun(, {|| MaIntBxCP(2,aRecSE2,{0,0,0},aRecNDF,Nil,Nil,Nil, aRetorno) }	, "Processando", "Estornando as Compensações.")

			if !lRet
				cMsg  := "Não foi possível descompensar os titulos para esta medição."
				cSolu := "Favor verificar o estorno no financeiro."
				Help(NIL, NIL, "CNT121BT - EstFinMED ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End If
		End if
	Next

Return

/*/{Protheus.doc} EstMed
Estorna a medicao do contrato.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function EstMed()

	Local aAreaSE2	:= SE2->(GetArea())
	Local lRet 		:= .t.
	Local cMedErro	:= ""
	Local cAliasSE2	:= GetNextAlias()
	Local cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),TAMSX3("E2_PREFIXO")[1])

	Private lMsErroAuto := .f.

	IF CND->CND_SITUAC <> "E"
		cMsg  := "O status desta medição se encontra diferente de encerrada."
		cSolu := "Favor selecionar medição com status de encerrada."
		Help(NIL, NIL, "EstMed", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End IF

	BEGIN TRANSACTION

		// Solicita o estorno de encerramento
		lRet := CN121Estorn(.f.)

		if lRet

			SE2->(DbSetOrder(1))

			BeginSQL Alias cAliasSE2

				SELECT SE2.R_E_C_N_O_ AS SE2RECNO FROM %Table:SE2% SE2 

				// A Serrana atualmente cadastra todos seus funcionarios na empresa 01.
				JOIN SRA010 SRA ON SRA.RA_FILIAL =  '1001' //%Exp:xFilial('SRA')%
				AND SRA.RA_YFORN = SE2.E2_FORNECE 
				AND SRA.RA_CATFUNC = 'A' 	// Autonomo
				AND SRA.RA_SITFOLH <> 'D'	// Demitidos
				AND SRA.D_E_L_E_T_ ='' 

				WHERE SE2.D_E_L_E_T_ =''
				AND SE2.E2_FILIAL  = %Exp:xFilial("SE2")%
				AND SE2.E2_MDCONTR = %Exp:CND->CND_CONTRA%
				AND SE2.E2_MEDNUME = %Exp:CND->CND_NUMMED%
				AND SE2.E2_PREFIXO = %Exp:cRetPrf%
				AND SE2.E2_TIPO    = 'NDF'

				ORDER BY SE2.E2_FORNECE,SE2.E2_LOJA

			EndSQL

			While(cAliasSE2)->(!EOF())

				aTitulo := {}

				lMsErroAuto := .f.

				SE2->(DbGoTo((cAliasSE2)->(SE2RECNO)))

				aAdd(aTitulo,{"E2_FILIAL"	, SE2->E2_FILIAL	,NIL})
				aAdd(aTitulo,{"E2_PREFIXO"	, SE2->E2_PREFIXO	,NIL})
				aAdd(aTitulo,{"E2_NUM"		, SE2->E2_NUM	  	,NIL})
				aAdd(aTitulo,{"E2_TIPO"		, SE2->E2_TIPO		,NIL})
				aAdd(aTitulo,{"E2_ORIGEM"	, "CNTA121"			,NIL})

				MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)//Exclui títulos à pagar

				If lMsErroAuto
					MOSTRAERRO()
					lRet:= .F.
					Exit
				Else
					lRet := .t.
				End if

				(cAliasSE2)->(DbSkip())
			EndDo
		End if

		// Caso encontre algum erro
		If !lRet
			DisarmTransaction()
		End If

	END TRANSACTION

	RestArea(aAreaSE2)
Return lRet





/*/{Protheus.doc} RPCFOL
Imprime a folha
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function RPCFOL()

	Local cAliasSE2 := GetNextAlias()
	Local cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),TAMSX3("E2_PREFIXO")[1])
	Local cTpTit	:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),TAMSX3("E2_TIPO")[1])
	Local cParcela	:= StrZero(1,TAMSX3("E2_PARCELA")[1])
	Local cForDe	:= PADL(" ",TamSX3("A2_COD")[1])
	Local cLojDE	:= PADL(" ",TamSX3("A2_LOJA")[1])
	Local cForAte	:= PADL("Z",TamSX3("A2_COD")[1],"Z")
	Local cLojAte	:= PADL("Z",TamSX3("A2_LOJA")[1],"Z")

	Local lRet		:= .t.
	Local aRet		:= {}
	Local aParamBox := {}
	Local nLinha    := 0
	Private nLinMax := 0
	Private lAdjustToLegacy := .T.
	Private lDisableSetup  	:= .T.
	Private oPrinter		:= Nil
	Private lPagina			:= .T.
	Private aTotais			:= {}



	// Valida se a medicao se encontra encerrada
	IF CND->CND_SITUAC <> "E"
		cMsg  := "O status desta medição se encontra diferente de encerrada."
		cSolu := "Favor selecionar medição com status de encerrada."
		Help(NIL, NIL, "RPCGCT", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End IF

	aAdd(aParamBox, {1, "Fornecedor De" , cForDe,'','.T.','SA2','.T.',TAMSX3("A2_COD")[1] * 5,.F.})
	aAdd(aParamBox, {1, "Loja De" 		, cLojDE,'','.T.','','.T.',TAMSX3("A2_LOJA")[1] * 5,.F.})
	aAdd(aParamBox, {1, "Fornecedor Ate", cForAte,'','.T.','SA2','.T.',TAMSX3("A2_COD")[1] * 5,.F.})
	aAdd(aParamBox, {1, "Loja Ate" 		, cLojAte,'','.T.','','.T.',TAMSX3("A2_LOJA")[1] * 5,.F.})

	lRet := ParamBox(aParamBox, "Filtrar Fornecedores", aRet)

	If !lRet
		Return
	End If

	cForDe  := aRet[1]
	cLojDE  := aRet[2]
	cForAte := aRet[3]
	cLojAte := aRet[4]

	BeginSQL Alias cAliasSE2

		SELECT SE2.R_E_C_N_O_ AS SE2RECNO FROM %Table:SE2% SE2 

		// A Serrana atualmente cadastra todos seus funcionarios na empresa 01.
		JOIN SRA010 SRA ON SRA.RA_FILIAL =  '1001' //%Exp:xFilial('SRA')%
		AND SRA.RA_YFORN = SE2.E2_FORNECE 
		AND SRA.RA_CATFUNC = 'A' 	// Autonomo
		AND SRA.RA_SITFOLH <> 'D'	// Demitidos
		AND SRA.D_E_L_E_T_ ='' 		

		WHERE SE2.D_E_L_E_T_ =''
		AND SE2.E2_FILIAL  = %Exp:xFilial("SE2")%
		AND SE2.E2_MDCONTR = %Exp:CND->CND_CONTRA%
		AND SE2.E2_MEDNUME = %Exp:CND->CND_NUMMED%
		AND SE2.E2_PREFIXO = %Exp:cRetPrf%
		AND SE2.E2_TIPO    = %Exp:cTpTit%
		AND (SE2.E2_PARCELA = %Exp:cParcela% OR SE2.E2_PARCELA = '01')
		AND SE2.E2_FORNECE BETWEEN %Exp:cForDe% AND %Exp:cForAte%
		AND SE2.E2_LOJA	   BETWEEN %Exp:cLojDE% AND %Exp:cLojAte%

		 ORDER BY E2_NOMFOR ASC 
		 
	EndSQL

	// Verifica se a query possui resultado
	If (cAliasSE2)->(EOF())
		cMsg  := "Não foi encontrados titulos no financeiro para esta medição onde os fornecedores envolvidos são cadastrados como autônomo (SRA)."
		cSolu := "Favor verificar se esta medição geram titulos no contas a pagar e que os fornecedores são considerados como autônomo."
		Help(NIL, NIL, "RPCGCT", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

	oPrinter := FWMSPrinter():New("SERR0010.rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup)

	oPrinter:SetResolution(72)
	oPrinter:SetPortrait()
	oPrinter:SetMargin(5,5,5,5) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:Setup()

	If !(oPrinter:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
		Return
	End if

	CN9->(DbSetOrder(1))

	While(cAliasSE2)->(!EOF())

		aObs := {}

		SE2->(DbGoTo((cAliasSE2)->SE2RECNO))

		cContrato := SE2->E2_MDCONTR
		cNumMedic := SE2->E2_MEDNUME
		cPlanilha := SE2->E2_MDPLANI

		CN9->(DbSeek(xFilial("CN9") + CND->(CND_CONTRA + CND_REVISA)))

		// Imprime o RPC, o titulo ja esta posicionado
		AADD(aObs,"CONTRATO: " + cContrato + " / MEDIÇÃO: " + cNumMedic + " / PLANILHA: " + cPlanilha + " / TITULO: " + SE2->(E2_FILIAL+ E2_PREFIXO+ E2_NUM+ E2_PARCELA+ E2_TIPO+ E2_FORNECE+ E2_LOJA))
		AADD(aObs,"DESCRIÇÃO: " + Alltrim(CND->CND_YDESPR))

		nLinha := U_SERR0010(,,,,aObs,oPrinter,nLinha)

		(cAliasSE2)->(DbSkip())
	EndDo

	nLinha := U_RESUL010(nLinha)

	oPrinter:Preview()
	(cAliasSE2)->(DbCloseArea())

Return
