#INCLUDE "TOPCONN.CH"

/*/
PE é executado após o final de todo o processo de gravação dos documentos e da geração das notas de saída. 
@author FBSolutions
@since 24/08/2019
@version 1.0
@example 
@obs 
/*/

User Function TM200FIM()

Return 
//Local cFilDoc  	:= PARAMIXB[1]
//Local cDoc   	:= PARAMIXB[2]
//Local cSerie   	:= PARAMIXB[3]
//Local cDocs 	:= ""
//Local nVol  	:= Posicione("DTC", 3, xFilial("DTC")+cFilDoc+cDoc+cSerie, "DTC_QTDVOL")
//Local cSerTMS 	:= "3"
//Local cTipTra 	:= "1"
//Local cTipCar   := "2"
//Local cTime     := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)
//Local aArea 	:= GetArea()
//
//Private cServic := Posicione("DTC", 3, xFilial("DTC")+cFilDoc+cDoc+cSerie, "DTC_SERVIC")
//Private cCodCDe := Posicione("DTC", 3, xFilial("DTC")+cFilDoc+cDoc+cSerie, "DTC_CLIDES")
//Private cLojCDe := Posicione("DTC", 3, xFilial("DTC")+cFilDoc+cDoc+cSerie, "DTC_LOJDES")
//Private cCEPCDe := Posicione("SA1", 1, xFilial("SA1")+cCodCDe+cLojCDe, "A1_CEP")
//
////Gravando o reboque
//Private cReb01  := ""
//Private cReb02  := ""
//Private cReb03  := ""
//
//	/*If ! Upper(FunName()) $ "SERTMS01"
//		RestArea(aArea)
//		Return
//	endif*/
//	
//	cLote    	:= Posicione("DT6", 1, xFilial("DT6")+cFilDoc+cDoc+cSerie, "DT6_LOTNFC")
//	cCdrCal    	:= Posicione("DT6", 1, xFilial("DT6")+cFilDoc+cDoc+cSerie, "DT6_CDRCAL")
//	cCdrDes    	:= Posicione("DT6", 1, xFilial("DT6")+cFilDoc+cDoc+cSerie, "DT6_CDRDES")
//	cViagem  	:= NextNumero("DTQ",1,"DTQ_VIAGEM",.T.)
//	cCodVei   	:= Posicione("DTP", 1, xFilial("DTP")+cLote, "DTP_X_VEIC") // "ZZZ-0000"
//	cCodMot   	:= Posicione("DTP", 1, xFilial("DTP")+cLote, "DTP_X_MOTO") // "000012"
//	cViagLte   	:= Posicione("DTP", 1, xFilial("DTP")+cLote, "DTP_VIAGEM")
//	cReb01   	:= Posicione("DTP", 1, xFilial("DTP")+cLote, "DTP_X_REB1")
//	cReb02   	:= Posicione("DTP", 1, xFilial("DTP")+cLote, "DTP_X_REB2") 
//	cReb03   	:= Posicione("DTP", 1, xFilial("DTP")+cLote, "DTP_X_REB3")  
//
//	If Empty(cViagLte) //Se viagem esta vazia no lote, entao criar nova viagem e atualizar no lote
//		atualizaLote(cLote, cViagem)
//		GrvDTQ(cViagem)
//		GrvDTR(cViagem, cCodVei, cReb01, cReb02, cReb03)
//		GrvDUP(cViagem, cCodMot, cCodVei)
//		//GrvDTW(.F., cViagem, "049", "000001")
//		//GrvDTW(.F., cViagem, "050", "000002")
//	Else
//		cViagem := cViagLte
//	EndIf
//	
//	cFilOri := cFilDoc
//
//	//Registros DUD e DTA sempre serão criados ou atualizados, pois os numeros de documentos podem mudar a cada calculo
//	GrvDUD(cViagem, cFilDoc, cDoc, cSerie, cCdrCal, cCdrDes)
//	GrvDTA(cFilOri, cViagem, cFilDoc, cDoc, cSerie, nVol, cSerTMS, cTipTra, cFilAnt, cTipCar, cCodVei)
//
//	//SETPRZENT(cFilDoc,cDoc,cSerie) //altera a data do prazo de entrega do CT-e
//	RestArea(aArea)
Return

Static Function GrvDTW(lApt, cViagem, cAtiv, cSequen)
	Local dData := DATE()
	Local cTime := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)

	dbSelectArea("DTW")
	DTW->( dbSetOrder(1) )
	If !DTW->( dbSeek(xFilial("DTW")+cFilAnt+cViagem+cSequen) )

		RecLock("DTW", .T.)

		DTW->DTW_FILIAL	:= ""
		DTW->DTW_FILORI	:= cFilAnt
		DTW->DTW_VIAGEM	:= cViagem
		DTW->DTW_SEQUEN	:= cSequen
		DTW->DTW_TIPOPE	:= "2"
		DTW->DTW_DATPRE	:= dData
		DTW->DTW_HORPRE	:= cTime
		DTW->DTW_FILATI	:= cFilAnt
		If lApt
			DTW->DTW_DATINI	:= dData
			DTW->DTW_HORINI	:= cTime
			DTW->DTW_DATREA	:= dData
			DTW->DTW_HORREA	:= cTime
			DTW->DTW_STATUS	:= "2"
		Else
			DTW->DTW_STATUS	:= "1"
		EndIf
		DTW->DTW_SERVIC	:= cServic //"013"
		DTW->DTW_TAREFA	:= "004"
		DTW->DTW_ATIVID	:= cAtiv
		DTW->DTW_SERTMS	:= "3"
		DTW->DTW_TIPTRA	:= "1"
		DTW->DTW_FILATU	:= cFilAnt
		DTW->DTW_CATOPE	:= "1"
		//DTW->DTW_OBSERV
		//DTW->DTW_DATAJU
		//DTW->DTW_HORAJU
		DTW->DTW_HORATR	:= "000:00"

		MsUnlock()
	EndIf

Return

Static Function GrvDTA(cFilOri, cViagem, cFilDoc, cDoc, cSerie, nVol, cSerTMS, cTipTra, cFilAtu, cTipCar)
	Local lAdd := .T.

	dbSelectArea("DTA")
	DTA->( dbSetOrder(1) )
	If DTA->( dbSeek(xFilial("DTA")+cFilDoc+cDoc+cSerie) )
		lAdd := .F.
	EndIf

	RecLock("DTA", lAdd)

	DTA->DTA_FILIAL	:=  xFilial("DTA")
	DTA->DTA_FILORI	:=	cFilOri
	DTA->DTA_VIAGEM	:=	cViagem
	DTA->DTA_FILDOC	:=	cFilDoc
	DTA->DTA_DOC	:=	cDoc
	DTA->DTA_SERIE	:=	cSerie
	DTA->DTA_QTDVOL	:=	nVol
	DTA->DTA_SERTMS	:=	cSerTMS
	DTA->DTA_TIPTRA	:=	cTipTra
	DTA->DTA_FILATU	:=	cFilAtu
	DTA->DTA_TIPCAR	:=	cTipCar
	DTA->DTA_FILDCA	:=	cFilAtu
	DTA->DTA_VALFRE	:=	0
	DTA->DTA_CODVEI := cCodVei

	MsUnlock()

Return Nil

Static Function GrvDUD(cViagem, cFilDoc, cDoc, cSerie, cCdrCal, cCdrDes)
	Local lAdd := .T.

	dbSelectArea("DUD")
	DUD->( dbSetOrder(1) )
	If DUD->( dbSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie) )
		lAdd := .F.
	EndIf

	RecLock("DUD", lAdd)

	DUD->DUD_FILIAL	:= xFilial("DUD")
	DUD->DUD_FILORI	:= cFilAnt
	DUD->DUD_FILDOC	:= cFilDoc
	DUD->DUD_DOC	:= cDoc
	DUD->DUD_SERIE	:= cSerie
	DUD->DUD_SERTMS	:= "3"
	DUD->DUD_TIPTRA	:= "1"
	DUD->DUD_CDRDES	:= cCdrDes
	DUD->DUD_VIAGEM	:= cViagem
	DUD->DUD_FILDCA	:= "01"
	DUD->DUD_SEQUEN	:= "001"
	DUD->DUD_GERROM	:= "1"
	DUD->DUD_SERVIC	:= cServic //"013"
	DUD->DUD_CDRCAL	:= cCdrCal
	DUD->DUD_ENDERE	:= "0"
	DUD->DUD_STROTA	:= "3"
	DUD->DUD_DOCTRF	:= "2"
	DUD->DUD_ZONA	:= "BRASIL"//"ZN001"
	DUD->DUD_SETOR	:= "BRASIL"//"000001"
	DUD->DUD_FILATU	:= cFilAnt
	DUD->DUD_CEPENT	:= cCEPCDe //"14034290"
	DUD->DUD_STATUS	:= "3"
	DUD->DUD_SEQENT := "001"

	MsUnlock()


Return Nil

//Atilio, 04/07/2016, Função não estava sendo utilizada - W0010
/*
Static Function SETPRZENT(cFilDoc,cDocto,cSerie)
Local aArea    := GetArea()
Local dPrvEnt  := DDataBase+SuperGetMV("MV__PRZENT",.F.,2)

If DOW(dPrvEnt) == 1
dPrvEnt := dPrvEnt+1
endIf

If !Empty(dPrvEnt)
dbSelectArea("DT6")
DT6->( dbSetOrder(1) )
If DT6->( dbSeek(xFilial("DT6")+cFilDoc+cDocto+cSerie) )
RecLock("DT6", .F.)
DT6->DT6_PRZENT := dPrvEnt
MsUnlock()
EndIf
DT6->( dbCloseArea() )
EndIf

RestArea(aArea)
Return Nil
*/

Static Function atualizaLote(cLote, cViagem)
	Local aArea    := GetArea()

	dbSelectArea("DTP")
	DTP->( dbSetOrder(1) )
	DTP->( dbSeek(xFilial("DTP") + cLote) )
	RecLock("DTP", .F.)

	DTP->DTP_VIAGEM := cViagem

	MsUnlock()
	RestArea(aArea)
Return nil

Static Function GrvDTQ(cViagem)
	Local aArea    := GetArea()
	Local dData := DATE()
	Local cTime := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)

	RecLock("DTQ", .T.)

	DTQ->DTQ_FILIAL := xFilial("DTQ")
	DTQ->DTQ_FILORI := cFilAnt
	DTQ->DTQ_VIAGEM := cViagem
	DTQ->DTQ_TIPVIA := "1"
	DTQ->DTQ_ROTA 	:= "BRASIL"
	DTQ->DTQ_DATGER := dData
	DTQ->DTQ_HORGER := cTime
	DTQ->DTQ_SERTMS := "3"
	DTQ->DTQ_TIPTRA := "1"
	DTQ->DTQ_FILATU := cFilAnt
	DTQ->DTQ_FILDES := cFilAnt
	DTQ->DTQ_STATUS := "1"
	DTQ->DTQ_CUSTO1 := 0
	DTQ->DTQ_CUSTO2 := 0
	DTQ->DTQ_CUSTO3 := 0
	DTQ->DTQ_CUSTO4 := 0
	DTQ->DTQ_CUSTO5 := 0
	DTQ->DTQ_QTDPER := 0

	MsUnlock()
	RestArea(aArea)
	Return

Return nil


Static Function GrvDTR(cViagem, cCodVei, cReb01, cReb02, cReb03)
	Local aArea  := GetArea()
	dbSelectArea("DTR")
	DTR->( dbSetOrder(3) )
	DTR->( dbGoTop() )

	If !DTR->( dbseek(xFilial("DTR") + cFilAnt + cViagem + cCodVei) ) .AND. !Empty(cCodVei)

		RecLock("DTR", .T.)

		DTR->DTR_FILIAL	:=	xFilial("DTR")
		DTR->DTR_FILORI	:=	cFilAnt
		DTR->DTR_VIAGEM	:=	cViagem
		DTR->DTR_ITEM	:=	"01"
		DTR->DTR_CODVEI	:=	cCodVei
		DTR->DTR_QTDEIX	:=	Posicione("DA3", 1, xFilial("DA3")+cCodVei, "DA3_QTDEIX")
		DTR->DTR_INSRET	:=	0
		DTR->DTR_VALFRE	:=	0
		DTR->DTR_VALPDG	:=	0
		DTR->DTR_CREADI	:=	Posicione("DA3", 1, xFilial("DA3")+cCodVei, "DA3_CODFOR")
		DTR->DTR_LOJCRE	:=	Posicione("DA3", 1, xFilial("DA3")+cCodVei, "DA3_LOJFOR")
		DTR->DTR_NOMCRE	:=	Posicione("SA2", 1, xFilial("SA2")+DTR->DTR_CREADI+DTR->DTR_LOJCRE, "A2_NOME")
		DTR->DTR_ADIFRE	:=	0
		DTR->DTR_FRECAL	:=	"2"
		DTR->DTR_REBTRF	:=	"2"
		DTR->DTR_CODFOR	:=	Posicione("DA3", 1, xFilial("DA3")+cCodVei, "DA3_CODFOR")
		DTR->DTR_LOJFOR	:=	Posicione("DA3", 1, xFilial("DA3")+cCodVei, "DA3_LOJFOR")
		DTR->DTR_QTEIXV	:=	Posicione("DA3", 1, xFilial("DA3")+cCodVei, "DA3_QTDEIX")
		DTR->DTR_VALRB1	:=	0
		DTR->DTR_VALRB2	:=	0
		DTR->DTR_CALRB1	:=	"2"
		DTR->DTR_CALRB2	:=	"2"
		DTR->DTR_CALRB3	:=	"2"
		DTR->DTR_PERADI	:=	0
		DTR->DTR_TIPCRG	:=	"2"
		DTR->DTR_CODRB1	:=	cReb01
		DTR->DTR_CODRB2	:=	cReb02
		DTR->DTR_CODRB3	:=	cReb03

		MsUnlock()

	EndIf

	DTR->( dbCloseArea() )

	RestArea(aArea)
Return Nil

Static Function GrvDUP(cViagem, cCodMot, cCodVei)
	Local aArea  := GetArea()
	dbSelectArea("DUP")
	DUP->( dbSetOrder(2) )
	DUP->( dbGoTop() )

	If !DUP->( dbseek(xFilial("DUP")+cFilAnt+cViagem+cCodMot) ) .AND. !Empty(cCodMot)

		RecLock("DUP", .T.)

		DUP->DUP_FILIAL	:=	xFilial("DUP")
		DUP->DUP_FILORI	:=	cFilAnt
		DUP->DUP_VIAGEM	:=	cViagem
		DUP->DUP_ITEDTR	:=	"01"
		DUP->DUP_CODVEI	:=	cCodVei
		DUP->DUP_CODMOT	:=	cCodMot
		DUP->DUP_VALSEG	:=	0
		DUP->DUP_CONDUT	:=	"1"

		MsUnlock()

	EndIf

	DUP->( dbCloseArea() )

	RestArea(aArea)
Return Nil

