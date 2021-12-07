#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"

User Function UPDCC()

	Local aArea    := GetArea()
	Local cViagem  := ''
	Local cFilOri  := ''
	Local cDoc     := ''
	Local cSerie   := ''
	Local cCliente := ''
	Local cLoja    := ''
	Local cCCusto  := ''
	Local cQuery   := ""

	Private _cAlias		:= GetNextAlias()

	//------------------------------------------------------------------------------------------------------
	//ATUALIZACAO DO CAMPO CENTRO DE CUSTO PARA TITULOS ORIGINADOS DOS RECIBOS DE CARGAS
	//------------------------------------------------------------------------------------------------------
	//Títulos originados dos Recibos de Cargas
	if SE2->E2_PREFIXO = 'CRR' .and. ALLTRIM(SE2->E2_ORIGEM) == 'SIGATMS'

		//Contrato de carreteiro
		dbSelectArea("DTY")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("DTY")+SE2->E2_NUM)
		cViagem := DTY->DTY_VIAGEM
		cFilOri := DTY->DTY_FILORI

		//Documentos da viagem
		dbSelectArea("DTA")
		dbSetOrder(2) //DTA_FILIAL + DTA_FILORI + DTA_VIAGEM
		dbGoTop()
		dbSeek(xFilial("DTA")+cFilOri+cViagem)
		cDoc   := DTA->DTA_DOC
		cSerie := DTA->DTA_SERIE

		//Nota Fiscal de Saida
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("SF2")+cDoc+cSerie)
		cCliente := SF2->F2_CLIENTE
		cLoja    := SF2->F2_LOJA

		cCCusto := Posicione('SA1',1,xFilial("SA1")+cCliente+cLoja,'A1_YCC')
		RecLock("SE2",.F.)
		SE2->E2_CCUSTO := cCCusto
		MsUnlock("SE2")

	endif
	//------------------------------------------------------------------------------------------------------
	//FINAL DA ATUALIZACAO DO CAMPO CENTRO DE CUSTO PARA TITULOS ORIGINADOS DOS RECIBOS DE CARGAS
	//------------------------------------------------------------------------------------------------------


	//------------------------------------------------------------------------------------------------------
	//ATUALIZACAO DO CAMPO CENTRO DE CUSTO PARA TITULOS ORIGINADOS DAS MEDICOES DE CONTRATOS
	//------------------------------------------------------------------------------------------------------
	//Títulos originados das medicoes de contratos
	//if SE2->E2_PREFIXO = 'MED' .and. ALLTRIM(SE2->E2_TIPO) == 'BOL' .and. ALLTRIM(SE2->E2_ORIGEM) == 'CNTA121'
	if SE2->E2_PREFIXO = 'MED' .and. ALLTRIM(SE2->E2_ORIGEM) == 'CNTA121'

		//Verifica Centro de Custo na medicao do contrato
		if SE2->E2_TIPO $ 'BOL/NDF'
			dbSelectArea("CNE")
			dbSetOrder(1)
			dbGoTop()
			if dbSeek(xFilial("CNE")+SE2->E2_MDCONTR+SE2->E2_MDREVIS+SE2->E2_MDPLANI+SE2->E2_MEDNUME)
				cCCusto := CNE->CNE_CC
			endif
		else
			cQuery := "SELECT E2_MDCONTR, E2_MDREVIS, E2_MDPLANI, E2_MEDNUME "
			cQuery += " FROM "+RetSqlName("SE2")
			cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
			cQuery += " AND E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA = '" + ALLTRIM(SE2->E2_TITPAI) + "' "
			cQuery += " AND D_E_L_E_T_='' "
			TCQUERY cQuery  NEW ALIAS (_cAlias)

			DbSelectArea(_cAlias)
			DbGoTop()

			dbSelectArea("CNE")
			dbSetOrder(1)
			dbGoTop()
			if dbSeek(xFilial("CNE")+(_cAlias)->(E2_MDCONTR)+(_cAlias)->(E2_MDREVIS)+(_cAlias)->(E2_MDPLANI)+(_cAlias)->(E2_MEDNUME))
				cCCusto := CNE->CNE_CC
			endif
			(_cAlias)->(DbCloseArea())
		endif

		RecLock("SE2",.F.)
		SE2->E2_CCUSTO := cCCusto
		MsUnlock("SE2")

	endif

	//------------------------------------------------------------------------------------------------------
	//ATUALIZACAO DO CAMPO CENTRO DE CUSTO PARA TITULOS ORIGINADOS DIRETAMENTE DO CMV
	//------------------------------------------------------------------------------------------------------
	//Títulos originados diretamente do CMV
	if SE2->E2_PREFIXO = 'CMV' .and. ALLTRIM(SE2->E2_ORIGEM) == 'FINA050'

		//Variavel lLoteCMV, instanciada no programa de geração de CMV em Lote(SERAGR04).
		//para que não apareça a tela de Centro de custo toda vez que gera uma NDF
		If Type("lLoteCMV") == "U"

			SetPrvt("_cCCusto")

			_cCCusto := SPACE(09)
			_cDesc   := SPACE(40)

			DEFINE MSDIALOG oDlg TITLE "CENTRO DE CUSTO CMV" FROM 000,000 TO 080,500 PIXEL Style 128
			
            @ 001, 001 TO 040, 300 OF oDlg PIXEL
			@ 012, 014 SAY "Informe o C. de Custo:" SIZE 60, 13 OF oDlg PIXEL
			@ 010, 070 MSGET _cCCusto  F3 "CTT" SIZE 08, 10 OF oDlg HASBUTTON PIXEL VALID ExistCpo("CTT",_cCCusto) .AND. GATCCUSTO()
			@ 010, 120 MSGET _cDesc Size 120, 10 When .F. OF oDlg PIXEL

			@ 025, 215 BUTTON "Ok" SIZE 20,10 ACTION GRAVACC() Of oDlg PIXEL

			oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC quando .F.

			ACTIVATE MSDIALOG oDlg CENTERED

		Else

			If !lProxCC

				SetPrvt("_cCCusto")

				_cCCusto := SPACE(09)
				_cDesc   := SPACE(40)

				DEFINE MSDIALOG oDlg TITLE "CENTRO DE CUSTO CMV" FROM 000,000 TO 080,500 PIXEL Style 128

				@ 001, 001 TO 040, 300 OF oDlg PIXEL
				@ 012, 014 SAY "Informe o C. de Custo:" SIZE 60, 13 OF oDlg PIXEL
				@ 010, 070 MSGET _cCCusto  F3 "CTT" SIZE 08, 10 OF oDlg HASBUTTON PIXEL VALID ExistCpo("CTT",_cCCusto) .AND. GATCCUSTO()
				@ 010, 120 MSGET _cDesc Size 120, 10 When .F. OF oDlg PIXEL

				@ 027, 002 CHECKBOX oProxCC VAR lProxCC PROMPT "Usar Este Centro de Custos nos Proximos Lançamentos" SIZE 170, 008 OF oDlg COLORS 0, 16777215 PIXEL

				@ 025, 215 BUTTON "Ok" SIZE 20,10 ACTION GRAVACC() Of oDlg PIXEL

				oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC quando .F.
				
                ACTIVATE MSDIALOG oDlg CENTERED

				cCCCMV := _cCCusto

			Else

				If Type("cCCCMV") == "C" .AND. !Empty(cCCCMV)

					RecLock("SE2",.F.)
					SE2->E2_CCUSTO := cCCCMV
					MsUnlock("SE2")

				EndIf

			EndIf

		EndIf

	endif

	RestArea(aArea)
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao que busca a descricao do Centro de Custo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GATCCUSTO()
	If POSICIONE("CTT",1,XFILIAL("CTT")+ _cCCusto,"CTT_CLASSE") == '1'
		_cCCusto := SPACE(09)
	else
		_cDesc := POSICIONE("CTT",1,XFILIAL("CTT")+ _cCCusto,"CTT_DESC01")
	endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao que grava o Centro de Custo para titulos CMV
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GRAVACC()
	RecLock("SE2",.F.)
	SE2->E2_CCUSTO := _cCCusto
	MsUnlock("SE2")

	oDlg:End()
Return
