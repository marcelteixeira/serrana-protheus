#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*---------+----------+-------+-----------------------+------+------------+
|Fun��o    |SERR001   | Autor |                       | Data | 03.09.2019 |
+----------+----------+-------+-----------------------+------+------------+
|Descri��o |AJUSTE DE CODIGOS DE FORNECEDOR						          |
+----------+--------------------------------------------------------------+
|Retorno   |NENHUM                                                        |
+----------+--------------------------------------------------------------+
|Par�metros|NENHUM														  |
+----------+--------------------------------------------------------------+
|Uso       |SERRANA                                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+-----------+----------+--------------------------------------------------+
| Subrotina |   Data   | Descri��o                                        |
+-----------+----------+--------------------------------------------------+
|           |          |                       				              |
+-----------+----------+-------------------------------------------------*/

USER FUNCTION SERR001()

	LOCAL nOPCA    := 0
	LOCAL aSAYS    := {}
	LOCAL aBUTTONS := {}
	PRIVATE cCADASTRO := "AJUSTE DE CODIGOS DE FORNECEDOR	"

	PROCLOGINI( aBUTTONS ) // Inicializa o log de processamento

	AADD(aBUTTONS, { 1,.T.,{|o| nOPCA := 1, O:oWND:END()}} )
	AADD(aBUTTONS, { 2,.T.,{|o| O:oWND:END() }} )
	AADD(aBUTTONS, { 5,.T.,{|| PERGUNTE(cPERGUNTE, .T.) } } )

	AADD (aSAYS, OemToAnsi("Este programa tem como objetivo ajustar os c�digos"))
	AADD (aSAYS, OemToAnsi("de fornecedor."))

	FORMBATCH( cCADASTRO, aSAYS, aBUTTONS,,,420)

	IF nOPCA == 1
		ProcLogAtu("INICIO") 			// Atualiza o log de processamento
		Processa({|lEnd| EXECUTA()}) // Chamada da funcao
		ProcLogAtu("FIM") 				// Atualiza o log de processamento
	ENDIF

RETURN NIL


/*---------+----------+-------+-----------------------+------+------------+
|Fun��o    |EXECUTA   | Autor |                       | Data |            |
+----------+----------+-------+-----------------------+------+------------+
|Descri��o |				                                              |
+----------+--------------------------------------------------------------+
|Uso       |                                                              |
+----------+-------------------------------------------------------------*/

STATIC FUNCTION EXECUTA()

	LOCAL aAREA      := {}
	LOCAL cARQUIVO   := ALLTRIM(MV_PAR01)
	LOCAL cCOMPET    := ALLTRIM(MV_PAR02)          
	LOCAL nLINHA     := 1
	LOCAL cBUFFER
	LOCAL cTABELA
	LOCAL aARQUIVOS  := {}
	LOCAL aDADOS     := {}    
	LOCAL nCon   	 := 0	  
	LOCAL aAreaAnt
	Local nProxN	 := 590 



	PROCREGUA(0)
	INCPROC(1)
	INCPROC(1)

	DBSELECTAREA("SRA")
	SRA->(DBSETORDER(1))
	SRA->(dbGoTop())

	nCon := 1
	nProxN := 590
	While !(SRA->(Eof())) .AND. nCon <= 5

		If (SUBSTR(SRA->RA_YFORN,1,4)) == "SEST" 
			MsgAlert("Funcionario: " + SRA->RA_NOME)


			AtuForn(SRA->RA_YFORN, nProxN)
			AtuItem(SRA->RA_YFORN, nProxN)

			SA2->(DBCLOSEAREA())
			

			RECLOCK("SRA",.F.)
			SRA->RA_YFORN := "000" + (Str(NProxN))
			SRA->(MSUNLOCK())

			VERIFICAR O PQ DE O CODIGO N�O ESTAR RECEBENDO O SEQUENCIAL
			GERAR ALERTA PARA VERIFICAR?

			nCon ++

			nProxN ++

		EndIf

		SRA->(dbSkip())           


	EndDo

	SRA->(DBCLOSEAREA())


RETURN NIL

Static Function AtuForn(cCod2,nProxN2)

Local aAreaAnt := GETAREA()

	DBSELECTAREA("SA2")
	SA2->(DBSETORDER(1))
	POSICIONE("SA2",1,xFilial("SA2") + Alltrim(cCod2), "A2_COD")
	
	If !Empty(SA2->A2_COD)
		
		MsgAlert("Fornecedor: " + SA2->A2_NOME)

		RECLOCK("SA2",.F.)
		SA2->A2_COD := "000" + (Str(cProxN2))
		SA2->(MSUNLOCK())

	EndIf

RESTAREA(aAreaAnt)

Return

Static Function AtuItem(cCod3,nProxN3)

Local aAreaAnt := GETAREA()
	
	DBSELECTAREA("CTD")
	DBSETORDER(1)
	POSICIONE("CTD",1,xFilial("CTD") + "F" + ALLTRIM(cCod3) + "01", "CTD_ITEM")
	
	If !Empty(CTD->CTD_ITEM)
		MsgAlert("Item: " + CTD->CTD_ITEM)

		RECLOCK("CTD",.F.)
		CTD->CTD_ITEM := "F000" + Str(cProxN3) + "01"
		CTD->(MSUNLOCK())
	EndIF
	
	CTD->(DBCLOSEAREA())
	

RESTAREA(aAreaAnt) 
Return