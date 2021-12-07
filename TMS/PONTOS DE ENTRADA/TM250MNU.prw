#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} TM250MNU
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

user function TM250MNU()
	
	aadd(aRotina,{'Estornar Comp.','StaticCall(TM250MNU,ESTCOMP)'  , 0 , 5,0,NIL})
	aadd(aRotina,{'Recibo RPC	.','StaticCall(TM250MNU,RecibRPC)' , 0 , 5,0,NIL})
			
return

/*/{Protheus.doc} RecibRPC
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 14/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function RecibRPC()
	
	Local cFornec  		:= Iif(!Empty(DTY->DTY_CODFAV),DTY->DTY_CODFAV,DTY->DTY_CODFOR)
	Local cLoja    		:= Iif(!Empty(DTY->DTY_LOJFAV),DTY->DTY_LOJFAV,DTY->DTY_LOJFOR)
	Local lEmptyTptCTC 	:= Empty(GetMV('MV_TPTCTC' ,,''))
	Local cTipCTC 	 	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )
	Local cNrContr   	:= DTY->DTY_NUMCTC
	Local cFilDeb  		:= DTY->DTY_FILDEB	
	Local cViagem		:= DTY->DTY_VIAGEM
	Local cParcela  	:= StrZero(1, Len(SE2->E2_PARCELA))
	Local cParc2  		:= PADR("01",TAMSX3("E2_PARCELA")[1])
	Local aObs			:= {}
	Local cMsg			:= ""
	Local cSolu			:= ""
	
	If lEmptyTptCTC
		cTipDeb := Padr( "C"+cFilDeb, Len( SE2->E2_TIPO ) )
		cTipCTC := If(cFilDeb <> cFilAnt, cTipDeb, cTipCTC)
	EndIf
	
	cPrefixo := TMA250GerPrf(cFilDeb)

	If !Empty(cFil:=FwFilial("SE2"))
		cFil := If(cFilDeb <> cFilAnt .And. lEmptyTptCTC, cFilDeb, cFilAnt)
	Else
		cFil:=xFilial("SE2")
	EndIf	
	
	// VERIFICA O TITULO NO FINANCEIRO DEVIDO A PARCELA FOI ALTERADO O TAMANHO NO CONFIGURADO PELA SERRANA
	If SE2->(MsSeek(cFil+cPrefixo+cNrContr+cParcela+cTipCTC+cFornec+cLoja)) .OR. SE2->(MsSeek(cFil+cPrefixo+cNrContr+cParc2+cTipCTC+cFornec+cLoja))
	
		DTR->(DbSetOrder(3))
		
		IF DTR->(DbSeek(xFilial("DTR") + DTY->(DTY_FILORI + DTY_VIAGEM + DTY_CODVEI)))
		
			AADD(aObs,"CONTRATO: " + cNrContr + " / VIAGEM: " + cViagem + " / DATA EMISSÃO: " + DTOC(DTY->DTY_DATCTC) + " / TITULO: " + SE2->(E2_FILIAL+ E2_PREFIXO+ E2_NUM+ E2_PARCELA+ E2_TIPO+ E2_FORNECE+ E2_LOJA))
			AADD(aObs,"VALOR A SER ANTECIPADO: R$ " + Alltrim(cvaltochar(TRANSFORM(DTR->DTR_YFRTAD, X3Picture("E2_VALOR")))))
	
			// Imprime RPC
			U_SERR0002(cFornec,cLoja,cPrefixo,cNrContr,aObs)
		Else
		
			cMsg  := "Não foi localizar o veículo " + Alltrim(DTY->DTY_CODVEI) + " para a viagem " + Alltrim(DTY->DTY_VIAGEM)
			cSolu := "Favor abrir a viagem e verificar se o registro existe."
			Help(NIL, NIL, "RecibRPC", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		End IF
	End If
	
Return
/*/{Protheus.doc} ESTCOMP
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ESTCOMP()
	
	Local nVlrAdiant 	:= 0
	Local nOpc		 	:= 5
	Local aRetorno   	:= {{}}
	Local lEmptyTptCTC 	:= Empty(GetMV('MV_TPTCTC' ,,''))
	Local cTipDeb    	:= ""
	Local cTipCTC 	 	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )
	Local cFilContr  	:= DTY->DTY_FILIAL
	Local cNrContr   	:= DTY->DTY_NUMCTC
	Local cFilOriDTY 	:= DTY->DTY_FILORI
	Local cCodOpe    	:= DTY->DTY_CODOPE
	Local cCtrComp   	:= DTY->DTY_TIPCTC
	Local cFornec    	:= Iif(!Empty(DTY->DTY_CODFAV),DTY->DTY_CODFAV,DTY->DTY_CODFOR)
	Local cLoja      	:= Iif(!Empty(DTY->DTY_LOJFAV),DTY->DTY_LOJFAV,DTY->DTY_LOJFOR)
	Local cViagem	   	:= DTY->DTY_VIAGEM
	Local cParcela  	:= StrZero(1, Len(SE2->E2_PARCELA))
	Local aRecSE2		:= {}
	Local aRecNDF		:= {}
	Local lRet			:= .t.
	
	
	//-- Verifica a Filial de Debito
	cFilDeb  := DTY->DTY_FILDEB
	
	If lEmptyTptCTC
		cTipDeb := Padr( "C"+cFilDeb, Len( SE2->E2_TIPO ) )
		cTipCTC := If(cFilDeb <> cFilAnt, cTipDeb, cTipCTC)
	EndIf
	
	cPrefixo := TMA250GerPrf(cFilDeb)

	If !Empty(cFil:=FwFilial("SE2"))
		cFil := If(cFilDeb <> cFilAnt .And. lEmptyTptCTC, cFilDeb, cFilAnt)
	Else
		cFil:=xFilial("SE2")
	EndIf	

	If SE2->(MsSeek(cFil+cPrefixo+cNrContr+cParcela+cTipCTC+cFornec+cLoja))
		Aadd(aRecSE2,SE2->(RecNo()))
	End If

	cPrefContr := TMA250GerPrf(cFilOriDTY)
	
	aRecNDF    := A250PsqAdi(cFornec,cLoja,cPrefixo,cFilContr,cNrContr,cViagem,/*cCarga*/,@nVlrAdiant,,cPrefContr,cCtrComp,nOpc)

	If AliasIndic('DYI')
		If DYI->(dbSeek(cSeekDYI:= xFilial('DYI')+DTY->(DTY_FILORI+DTY_NUMCTC)))
			While DYI->(!Eof()) .And.  DYI->(DYI_FILIAL+DYI_FILORI+DYI_NUMCTC) == cSeekDYI
				Aadd( aRetorno[1], DYI->DYI_SEQBX )
				DYI->(dbSkip())
			EndDo
		Else
			Help('',1,'TMSA25039') //-- "Contrato de Carreteiro não foi encontrado na Tabela de Acerto Financeiro de Contratos." //--Exclua a baixa no Financeiro e Estorne o Contrato de Carreteiro no SIGATMS
			lRet := .F.
		EndIf
	Else
		Help('',1,'TMSA25040') //-- "Para utilizar o Estorno do Pagamento de Saldo é necessário que exista a tabela DYI." //--Rode o Update ('TMS11R114')
		lRet := .f.
	EndIf
	
	If lRet
		If MSGYESNO( "Deseja estornar as compensações financeiras?", "Estornar Titulos." )
	
			FWMsgRun(, {|| MaIntBxCP(2,aRecSE2,{0,0,0},aRecNDF,Nil,Nil,{ | nRecSE2, cRetorno | A250SeqBx(nRecSE2,cRetorno,DTY->DTY_FILORI,DTY->DTY_NUMCTC,2) }, aRetorno) }	, "Processando", "Estornando as Compensações.")
		End If 
	End If
Return 