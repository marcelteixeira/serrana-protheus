#INCLUDE "PROTHEUS.CH"           
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"                                                           
#INCLUDE "TBICONN.CH"
/*---------+----------+-------+-----------------------+------+------------+
|Função    |WIZTMS    | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |WIZARD MÓDULO SIGATMS         								  |
|          |Preparação do ambiente Protheus para utilização do módulo TMS |
|          |nas modalidades disponíveis.                                  |
+----------+--------------------------------------------------------------+
|Retorno   |NENHUM                                                        |
+----------+--------------------------------------------------------------+
|Parâmetros|NENHUM														  |
+----------+--------------------------------------------------------------+
|Uso       |SIGATMS                                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+-----------+----------+--------------------------------------------------+
| Subrotina |   Data   | Descrição                                        |
+-----------+----------+--------------------------------------------------+
|           |          |                       				              |
+-----------+----------+-------------------------------------------------*/
USER FUNCTION WIZTMS                
LOCAL cCADASTRO   := "TOTVS ES | WIZARD SIGATMS"

PRIVATE aFILIAIS    := {}                                           
PRIVATE aEMPRESAS   := {}
                                                
PRIVATE oDLG
PRIVATE aHEADER   := {}
PRIVATE aCOLSFUNC := {}
PRIVATE lMARK     := .F.

//U_UPDSIGAFIS()
//TMSP11R1()

IF ( lOPEN := OPENSM0() )        

	SM0->(DBGOTOP())
	WHILE !SM0->(EOF())
	  	IF !SM0->(DELETED())
			IF ASCAN(aEMPRESAS, {|X| X[2] == M0_CODIGO}) == 0
				AADD(aEMPRESAS, {.T., M0_CODIGO, FWGETCODFILIAL, M0_FILIAL, RECNO()})	     		
			ENDIF		
			AADD(aFILIAIS, {.T., M0_CODIGO, FWGETCODFILIAL, M0_FILIAL, RECNO(), "                    ", "UNI=CTE                                 "})
		ENDIF	
		SM0->(DBSKIP())
	ENDDO
	
	SM0->(DBGOTOP())
	WHILE !SM0->(EOF()) .AND. SM0->(DELETED())
		SM0->(DBSKIP())		
	ENDDO
		
	RpcSetType(3)                                            			
	RpcSetEnv(SM0->M0_CODIGO,FWGETCODFILIAL,,,"TMS")    
	nModulo      := 43 //SIGATMS
	lMsFinalAuto := .F.    

	/*------------------------------------------------------------------------+
	|INSTANCIA OBJETOS GRAFICOS                                               |
	+------------------------------------------------------------------------*/
	oDLG      := MSDIALOG():NEW(0,0,400,530,cCADASTRO,,,,,,,,,.T.)              	       
	
	Z_WZTMS001 := IF(SuperGetMV("Z_WZTMS001", .F.) == .F., "Pendente", "Executado")
	Z_WZTMS002 := IF(SuperGetMV("Z_WZTMS002", .F.) == .F., "Pendente", "Executado")
	Z_WZTMS003 := IF(SuperGetMV("Z_WZTMS003", .F.) == .F., "Pendente", "Executado")
	Z_WZTMS004 := IF(SuperGetMV("Z_WZTMS004", .F.) == .F., "Pendente", "Executado")
	Z_WZTMS005 := IF(SuperGetMV("Z_WZTMS005", .F.) == .F., "Pendente", "Executado")
			
	AADD(aCOLSFUNC,{"LBOK", "WZTMS001", "Emissão Cte e Manifesto", Z_WZTMS001, .F.})
//	AADD(aCOLSFUNC,{"LBNO", "WZTMS002", "Controle de Jornada"    , Z_WZTMS002, .F.})
//	AADD(aCOLSFUNC,{"LBNO", "WZTMS003", "Contrato de Carreteiro" , Z_WZTMS003, .F.})
//	AADD(aCOLSFUNC,{"LBNO", "WZTMS004", "Natureza Financeira"    , Z_WZTMS004, .F.})
//	AADD(aCOLSFUNC,{"LBNO", "WZTMS005", "TES Compras"            , Z_WZTMS005, .F.})
	
	aHEADER      := U_GETHEADER("SB1",.T.,.T.,{"B1_COD","B1_DESC","B1_COD"},.F.)
	aHEADER[2,1] := "Rotina"
	aHEADER[3,1] := "Descrição"
	aHEADER[4,1] := "Status"
	
	oPANTOP := TPANEL():NEW(0,0,"",oDLG,, .T., .T.,,,0,20,.T.,.T.)
	oPANTOP:ALIGN := CONTROL_ALIGN_TOP
	
	oPANBOT := TPANEL():NEW(0,0,"",oDLG,, .T., .T.,,,0,20,.T.,.T.)
	oPANBOT:ALIGN := CONTROL_ALIGN_BOTTOM
	
	oGET    := MSNEWGETDADOS():NEW(0,0,0,0,/*GD_UPDATE*/,"ALLWAYSTRUE", "ALLWAYSTRUE", "", {} /*aALTESOL*/, 000, 999,;
	"ALLWAYSTRUE", "", "ALLWAYSTRUE", oDLG, aHEADER, aCOLSFUNC)
	
	oGET:oBROWSE:ALIGN 			:= CONTROL_ALIGN_ALLCLIENT                          
	oGET:oBROWSE:bLDBLCLICK   := {|| INVERTE()}
//	oGET:oBROWSE:bHEADERCLICK := {|OBRW,NCOL,ADIM| OBRW:NCOLPOS := NCOL, MARCTOT()}
	
	oFONT01   := TFONT():NEW("Courier new",,-16,.T.,.T.)	
	oSAY      := TSAY():NEW(007,010,{||"Selecione os pacotes para instalação..."},oPANTOP,,oFONT01,,,,.T.,CLR_BLACK,CLR_WHITE,400,20)
	oBUTCLOSE := TBUTTON():NEW(6,010,'Fechar',oPANBOT,{||oDLG:END()},40,10,,,,.T.)
	oBUTEMP   := TBUTTON():NEW(6,170,'Empresas',oPANBOT,{||aFILIAIS := tEMPRESA(@aFILIAIS)},40,10,,,,.T.)
	oBUTOK    := TBUTTON():NEW(6,214,'Instalar',oPANBOT,{||fEXECROT(aFILIAIS)},40,10,,,,.T.)
	
	oDLG:lCENTERED	:= .T.
	oDLG:ACTIVATE()                                        
	
ENDIF

RETURN NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |INVERTE   | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |INVERT VALOR DO CHECKBOX                                      |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD SIGATMS                                                |
+----------+-------------------------------------------------------------*/
STATIC FUNCTION INVERTE()                                   

IF oGET:aCOLS[oGET:nAT,1] == "LBNO" //.AND. UPPER(oGET:aCOLS[oGET:nAT,4]) == "PENDENTE"
	oGET:aCOLS[oGET:nAT,1] := "LBOK"
ELSE
	oGET:aCOLS[oGET:nAT,1] := "LBNO"
ENDIF	
oGET:REFRESH()

RETURN NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |MARCTOT   | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |INVERT VALOR DE TODOS OS CHECKBOX                             |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD SIGATMS                                                |
+----------+-------------------------------------------------------------*/
/*
STATIC FUNCTION MARCTOT()
LOCAL nX
                                                     
IF !lMARK
	lMARK := .T.
	FOR nX := 1 TO LEN(oGET:aCOLS) 
		IF UPPER(oGET:aCOLS[oGET:nAT,4]) == "PENDENTE"     
			oGET:aCOLS[oGET:nAT,1] := "LBOK"
		ENDIF
	NEXT
ELSE
	lMARK := .F.
	FOR nX := 1 TO LEN(oGET:aCOLS)     
		oGET:aCOLS[oGET:nAT,1] := "LBNO"
	NEXT
ENDIF

oGET:REFRESH()

RETURN NIL                                          
*/                                                  

/*---------+----------+-------+-----------------------+------+------------+
|Função    |tEMPRESA  | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |EXIBE EMPRESAS SELECIONADAS                                   |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD SIGATMS                                                |
+----------+-------------------------------------------------------------*/           
STATIC FUNCTION tEMPRESA(aFILIAIS)
PRIVATE oDLG                                                  
PRIVATE oOK    := LOADBITMAP(GETRESOURCES(),"LBOK")
PRIVATE oNO    := LOADBITMAP(GETRESOURCES(),"LBNO")
PRIVATE lMARKE := .T.                                         
PRIVATE aLISTA := {}
PRIVATE oLISTA                                  

AADD(aLISTA, " ")
AADD(aLISTA, "Empresa")
AADD(aLISTA, "Filial")
AADD(aLISTA, "Nome")
AADD(aLISTA, "Id.")
AADD(aLISTA, "ANTT")
AADD(aLISTA, "Especie")

DEFINE MSDIALOG oDLG TITLE 'Selecione as Empresas para a instalação...' From 9,0 To 30,52

oLista := TWBrowse():New(005,005,155,145,,aLISTA,,oDlg,,,,,,,,,,,,, "ARRAY", .T. )
oLista:SetArray( aFILIAIS )
oLista:bLine := {|| {	If(aFILIAIS[oLista:nAT,1], oOk, oNo),;
						aFILIAIS[oLista:nAT,2],;
						aFILIAIS[oLista:nAT,3],;
						aFILIAIS[oLista:nAT,4],;
						aFILIAIS[oLista:nAT,5],;
						aFILIAIS[oLista:nAT,6],;
						aFILIAIS[oLista:nAT,7]}}

//oLista:bLDblClick := {|| aFILIAIS[oLista:nAt,1] := !aFILIAIS[oLista:nAt,1], oLista:Refresh()}
oLista:bLDblClick := {|| ALTERA(@aFILIAIS)}

DEFINE SBUTTON FROM    4,170 TYPE  1 ACTION (oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 18.5,170 TYPE 11 ACTION (Aeval(aFILIAIS,{|aElem|aElem[1] := lMARKE}),;
lMARKE := !lMARKE,,oLISTA:REFRESH()) ONSTOP 'Marca/Desmarca' ENABLE OF oDLG

ACTIVATE MSDIALOG oDLG CENTERED

RETURN aFILIAIS                

STATIC FUNCTION ALTERA(aFILIAIS)             
	IF oLISTA:nCOLPOS == 1
		aFILIAIS[oLista:nAt,1] := !aFILIAIS[oLista:nAt,1]
	ELSEIF oLISTA:nCOLPOS == 6 .OR. oLISTA:nCOLPOS == 7
		lEDITCELL(@aFILIAIS, oLISTA, "", oLISTA:nCOLPOS)
	ENDIF
	oLISTA:REFRESH()
RETURN .T.

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fEXECROT  | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |EXECUTA PROCESSO DE INSTAÇÃO                                  |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/    
STATIC FUNCTION fEXECROT(aFILIAIS)
LOCAL lEXEC := .F.                                 
LOCAL nX                          
LOCAL aCOLSFUNC := ACLONE(oGET:aCOLS)
                                                                                    
FOR nX := 1 TO LEN(aCOLSFUNC)
	IF aCOLSFUNC[nX,1] == "LBOK" .AND. aCOLSFUNC[nX,2] == "WZTMS001"         
		MSGRUN("Aguarde o termino da instalação...",,{|| WZTMS001(aFILIAIS) })
		lEXEC := .T.
	ENDIF
NEXT

IF lEXEC                                                    
	AVISO("Aviso","Instalação concluída com sucesso!!!",{"Continuar"},2)
ELSE                                              
	AVISO("Aviso","Nenhum programa foi selecionado!!!",{"Continuar"},2)
ENDIF

RETURN NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |WZTMS001  | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |CONFIGURA EMISSÃO DE CTe E MANIFESTO ELETRÔNICO               |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/    
STATIC FUNCTION WZTMS001(aFILIAIS)
LOCAL lOPEN
LOCAL nFILIAL

FOR nFILIAL := 1 TO LEN(aFILIAIS)
	IF aFILIAIS[nFILIAL,1]
		RPCCLEARENV()	
		lOPEN := OPENSM0()
		IF lOPEN
			SM0->(DBGOTO(aFILIAIS[nFILIAL,5]))
			RPCSETTYPE(3)                           			
			IF RpcSetEnv(SM0->M0_CODIGO,FWGETCODFILIAL,,,"TMS")
				nMODULO      := 43
				lMSFINALAUTO := .F.                       
				                    
				/*------------------------------------------------------------------------+
				| ATUALIZA PARÂMETROS                                                     |
				+------------------------------------------------------------------------*/
				fPARAME(nFILIAL)
			ENDIF
		ENDIF
	ENDIF
NEXT

RETURN NIL
                      
/*---------+----------+-------+-----------------------+------+------------+
|Função    |OPENSM0   | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |ABRE ARQUIVO SIGAMAT EM MODO EXCLUSIVO                        |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/    
STATIC FUNCTION OPENSM0()
LOCAL lOPEN := .F.
LOCAL nLOOP := 0

FOR nLOOP := 1 TO 20
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")        
		SET DELETED ON
		Exit
	EndIf
	Sleep( 500 )
Next nLoop

If !lOpen
	MsgAlert( "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !" )
EndIf       

RETURN lOPEN                                

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fPARAME   | Autor |KENNY ROGER MARTINS    | Data | 30.03.2015 |
+----------+----------+-------+-----------------------+------+------------+                        
|Descrição |ATUALIZA PARÂMETROS                                           |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fPARAME(nFILIAL)
LOCAL cCODFIL := cCODCLI := cCODROT := cCODSEG := cSERCAR := cANTT := cESPECI := cESTADO := ""
LOCAL aSEROPE := {}
        
cCODFIL := fREGIAO()
cCODCLI := fCLIGEN(SM0->M0_ESTCOB,cCODFIL)
fCADPRO()
fCADTES()
aSEROPE := fCADTAR(cCODCLI,nFILIAL)
cSERCAR := aSEROPE[2]
cCODSEG := fCADSEG(SM0->M0_ESTCOB)  
cANTT   := aFILIAIS[nFILIAL,6]
cESPECI := aFILIAIS[nFILIAL,7]     
cESTADO := SM0->M0_ESTCOB

fADDPAR(nFILIAL, "Z_WZTMS001", "L", ".T."   , "Informa se o pacote WZTMS001 foi aplicado na Base.", "                                                  ", "")
fADDPAR(nFILIAL, "MV_ESTADO" , "C", cESTADO , "Sigla do estado da empresa usuaria do Sistema, pa-", "ra efeito de calculo de ICMS (7, 12 ou 18%).      ", "")
fADDPAR(nFILIAL, "MV_INTTMS" , "L", ".T."   , "Identifica se o Modulo do TMS esta integrado aos  ", "outros modulos.                                   ", "")
fADDPAR(nFILIAL, "MV_TMSCFEC", "L", ".T."   , "Indica se as funcionalidades de carga fechada     ", "estao ativas.                                     ", "")
fADDPAR(nFILIAL, "MV_TMSCTE" , "L", ".T."   , "Habilita o Ct-e - Conhecimento de transp.Eletronic", "o.                                                ", "")
fADDPAR(nFILIAL, "MV_TMSMFAT", "C", "1"     , "Modo de Faturamento do TMS. 1- Faturamento a pa   ", "r do SE1; 2- Faturamento a partir do DT6          ", "")
fADDPAR(nFILIAL, "MV_TMSEXP" , "L", ".T."   , "Controla modo express                             ", "                                                  ", "")
fADDPAR(nFILIAL, "MV_TMSTIPT", "C", "NF=CTE", "Tipo de Titulo a ser gerado no Contas a Receber   ", "                                                  ", "")
fADDPAR(nFILIAL, "MV_CLIGEN" , "C", cCODCLI , "Define o codigo do Cliente / Loja que serao utili-", "zados nos Contratos Genericos (Modulo TMS).       ", "")
fADDPAR(nFILIAL, "MV_CDRORI" , "C", "BRA"   , "Define o codigo da regiao de origem               ", "                                                  ", "")
fADDPAR(nFILIAL, "MV_TESDR"  , "C", "481"   , "TES pre-determinado para geracao de movimentos de ", "vasilhames ou mercadorias a serem transportadas r ", "emetidos por terceiros.                           ")
fADDPAR(nFILIAL, "MV_TESDD"  , "C", "981"   , "TES pre-determinado para geracao de movimentos de ", "vasilhames ou mercadorias a serem transportadas r ", "emetidos por terceiros.                           ")
fADDPAR(nFILIAL, "MV_ROTGENT", "C", cCODROT , "Rota generica para entrega                        ", "                                                  ", "")
fADDPAR(nFILIAL, "MV_SVCENT" , "C", "002"   , "Codigo do servico p/ carregamento de entrega do mo", "dulo TMS.                                         ", "")
fADDPAR(nFILIAL, "MV_ATIVCHG", "C", "050"   , "Atividade de Chegada de Viagem                    ", "                                                  ", "")
fADDPAR(nFILIAL, "MV_ATIVSAI", "C", "049"   , "Atividade de Saida de Viagem                      ", "                                                  ", "")
fADDPAR(nFILIAL, "MV_FORSEG" , "C", cCODSEG , "Define o codigo do Fornecedor / Loja que serao  u-", "tilizados na geracao de titulos a pagar de seguro ", "")
fADDPAR(nFILIAL, "MV_TMSANTT", "C", cANTT   , "Numero do registro na ANTT.                       ", "                                                  ", "")
fADDPAR(nFILIAL, "MV_ESPECIE", "C", cESPECI , "Contem tipos de documentos fiscais utilizados na  ", "emissao de notas fiscais                          ", "")
fADDPAR(nFILIAL, "MV_TPNRNFS", "C", "3"     , "Define o tipo de controle da numeracao dos documen", "tos de saida ( 1-SX5 | 2-SXE/SXF | 3-SD9 ).       ", "")
fADDPAR(nFILIAL, "MV_MCUSTO" , "C", "1"     , "Moeda utilizada para verificacao do limite de cre-", "dito que foi informado no cadastro de clientes.   ", "")
fADDPAR(nFILIAL, "MV_BLOQUEI", "L", "F"     , "Informe T para submeter todas liberacoes de pedido", "a aprovacao do credito caso contrario informe F.  ", "")

RETURN NIL

                             
/*---------+----------+-------+-----------------------+------+------------+
|Função    |fREGIAO   | Autor |KENNY ROGER MARTINS    | Data | 26.02.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |CRIA CADASTRO DE REGIÕES                                      |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/   
STATIC FUNCTION fREGIAO()
LOCAL aESTADOS := {}                         
LOCAL cSEQ     := "0"                   
LOCAL cCODFIL  := ""
                                            
DBSELECTAREA("DUY")
DUY->(DBSETORDER(1))
IF DUY->(DBSEEK(xFILIAL("DUY")))
	IF !DUY->(DBSEEK(xFILIAL("DUY") + SM0->(M0_CODIGO + M0_CODFIL)))
		RECLOCK("DUY",.T.)                                      
		DUY->DUY_FILIAL := xFILIAL("DUY")
		DUY->DUY_GRPVEN := SM0->(M0_CODIGO + M0_CODFIL)
		DUY->DUY_DESCRI := SM0->M0_FILIAL
		DUY->DUY_GRPSUP := SM0->M0_ESTCOB
		DUY->DUY_EST    := SM0->M0_ESTCOB
		DUY->DUY_FILDES := SM0->M0_CODFIL
		DUY->DUY_CDRCOL := ""
		DUY->DUY_CATREG := "1"
		DUY->DUY_CDRTAX := ""
		DUY->DUY_CATGRP := "2"
		DUY->DUY_REGISE := "2"
		DUY->DUY_ALQISS := 0
		DUY->DUY_PAIS   := "105"
		DUY->DUY_CODMUN := ""
		DUY->DUY_PORTMS := "2"
		MSUNLOCK()
	ENDIF
ELSE
	RECLOCK("DUY",.T.)
	DUY->DUY_FILIAL := xFILIAL("DUY")
	DUY->DUY_GRPVEN := "BRA"
	DUY->DUY_DESCRI := "BRASIL"
	DUY->DUY_GRPSUP := "MAINGR"
	DUY->DUY_EST    := ""
	DUY->DUY_FILDES := SM0->M0_CODFIL
	DUY->DUY_CDRCOL := ""
	DUY->DUY_CATREG := "1"
	DUY->DUY_CDRTAX := ""
	DUY->DUY_CATGRP := "3"
	DUY->DUY_REGISE := "2"
	DUY->DUY_ALQISS := 0      
	DUY->DUY_PAIS   := "105"
	DUY->DUY_CODMUN := ""
	DUY->DUY_PORTMS := "2"
	MSUNLOCK()
	      
	DBSELECTAREA("SX5")
	SX5->(DBSETORDER(1))
	SX5->(DBSEEK(xFILIAL("SX5") + "12"))
	
	WHILE SX5->(!EOF()) .AND. SX5->(X5_FILIAL + X5_TABELA) == xFILIAL("SX5") + "12"   
		IF ALLTRIM(SX5->X5_CHAVE) == "EX"
			RECLOCK("DUY",.T.)
			DUY->DUY_FILIAL := xFILIAL("DUY")
			DUY->DUY_GRPVEN := SX5->X5_CHAVE
			DUY->DUY_DESCRI := SX5->X5_DESCRI
			DUY->DUY_GRPSUP := "MAINGR"
			DUY->DUY_EST    := SX5->X5_CHAVE
			DUY->DUY_FILDES := SM0->M0_CODFIL
			DUY->DUY_CDRCOL := ""
			DUY->DUY_CATREG := "1"
			DUY->DUY_CDRTAX := ""
			DUY->DUY_CATGRP := "3"
			DUY->DUY_REGISE := "2"
			DUY->DUY_ALQISS := 0      
			DUY->DUY_PAIS   := "105"
			DUY->DUY_CODMUN := ""
			DUY->DUY_PORTMS := "2"
			MSUNLOCK()
		ELSE                          
			RECLOCK("DUY",.T.)
			DUY->DUY_FILIAL := xFILIAL("DUY")
			DUY->DUY_GRPVEN := SX5->X5_CHAVE
			DUY->DUY_DESCRI := SX5->X5_DESCRI
			DUY->DUY_GRPSUP := "BRA"
			DUY->DUY_EST    := SX5->X5_CHAVE
			DUY->DUY_FILDES := SM0->M0_CODFIL
			DUY->DUY_CDRCOL := ""
			DUY->DUY_CATREG := "1"
			DUY->DUY_CDRTAX := ""
			DUY->DUY_CATGRP := "1"
			DUY->DUY_REGISE := "2"
			DUY->DUY_ALQISS := 0      
			DUY->DUY_PAIS   := "105"
			DUY->DUY_CODMUN := ""
			DUY->DUY_PORTMS := "2"
			MSUNLOCK()                     
			
			cSEQ := SOMA1(cSEQ)
			AADD(aESTADOS, {SX5->X5_CHAVE, cSEQ})
		ENDIF                         
		SX5->(DBSKIP())
	ENDDO              
	SX5->(DBCLOSEAREA())                  
	
	RECLOCK("DUY",.T.)                                      
	DUY->DUY_FILIAL := xFILIAL("DUY")
	DUY->DUY_GRPVEN := SM0->(M0_CODIGO + M0_CODFIL)
	DUY->DUY_DESCRI := SM0->M0_FILIAL
	DUY->DUY_GRPSUP := SM0->M0_ESTCOB
	DUY->DUY_EST    := SM0->M0_ESTCOB
	DUY->DUY_FILDES := SM0->M0_CODFIL
	DUY->DUY_CDRCOL := ""
	DUY->DUY_CATREG := "1"
	DUY->DUY_CDRTAX := ""
	DUY->DUY_CATGRP := "2"
	DUY->DUY_REGISE := "2"
	DUY->DUY_ALQISS := 0
	DUY->DUY_PAIS   := "105"
	DUY->DUY_CODMUN := ""
	DUY->DUY_PORTMS := "2"
	MSUNLOCK()
	                              
	DBSELECTAREA("CC2")          
	DBSETORDER(4)
	WHILE CC2->(!EOF())                               
		cCODMUN := aESTADOS[ASCAN(aESTADOS, {|X| ALLTRIM(X[1]) == ALLTRIM(CC2->CC2_EST)}), 2] + CC2->CC2_CODMUN
		IF CC2->CC2_CODMUN == SM0->M0_CODMUN .AND. CC2->CC2_EST = SM0->M0_ESTCOB
			cCODFIL := cCODMUN
		ENDIF
		RECLOCK("DUY",.T.)
		DUY->DUY_FILIAL := xFILIAL("DUY")
		DUY->DUY_GRPVEN := cCODMUN
		DUY->DUY_DESCRI := CC2->CC2_MUN
		DUY->DUY_GRPSUP := CC2->CC2_EST
		DUY->DUY_EST    := CC2->CC2_EST
		DUY->DUY_FILDES := SM0->M0_CODFIL
		DUY->DUY_CDRCOL := ""
		DUY->DUY_CATREG := "1"
		DUY->DUY_CDRTAX := ""
		DUY->DUY_CATGRP := "3"
		DUY->DUY_REGISE := "2"
		DUY->DUY_ALQISS := 0
		DUY->DUY_PAIS   := ""
		DUY->DUY_CODMUN := CC2->CC2_CODMUN
		DUY->DUY_PORTMS := "2"
		MSUNLOCK()
		
		CC2->(DBSKIP())
	ENDDO                     
ENDIF	                  
	
RETURN cCODFIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fCLIGEN   | Autor |KENNY ROGER MARTINS    | Data | 03.03.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |CRIA CLIENTE GENERICO UTILIZADO NO SIGATMS                    |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fCLIGEN(cESTADO, cREGIAO)
LOCAL cCODIGO

DBSELECTAREA("SA1")
SA1->(DBSETORDER(2))
IF SA1->(DBSEEK(xFILIAL("SA1") + "CLIENTE GENERICO TMS"))
	cCODIGO := SA1->(A1_COD+A1_LOJA)
ELSE
	cCODIGO := GETSXENUM("SA1")
	CONFIRMSX8()

	RECLOCK("SA1", .T.)
	SA1->A1_FILIAL := xFILIAL("SA1")
	SA1->A1_COD    := cCODIGO
	SA1->A1_LOJA   := "01"
	SA1->A1_PESSOA := "J"
	SA1->A1_TIPO   := "F"
	SA1->A1_NOME   := "CLIENTE GENERICO TMS"
	SA1->A1_NREDUZ := "CLIENTE GENERICO TMS"
	SA1->A1_END    := "BRASIL"
	SA1->A1_MUN    := "BRASIL"
	SA1->A1_EST    := cESTADO
	SA1->A1_REGIAO := "BRA"
	SA1->(MSUNLOCK())                
	
	cCODIGO := cCODIGO + "01"	
ENDIF
SA1->(DBCLOSEAREA())

RETURN cCODIGO           

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fCADPRO   | Autor |KENNY ROGER MARTINS    | Data | 30.03.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |CRIA PRODUTO GENERICO UTILIZADO NO SIGATMS                    |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fCADPRO()
LOCAL cCODIGO := "TMSSRV001"

DBSELECTAREA("SB1")
SB1->(DBSETORDER(1))
IF !SB1->(DBSEEK(xFILIAL("SB1") + "TMSSRV001"))
	RECLOCK("SB1", .T.)
	SB1->B1_FILIAL := xFILIAL("SB1")
	SB1->B1_COD    := cCODIGO
	SB1->B1_DESC   := "PRODUTO GENERICO TMS"
	SB1->B1_TIPO   := "ME"
	SB1->B1_UM     := "UN"
	SB1->B1_LOCPAD := "01"
	SB1->(MSUNLOCK())
ENDIF
SB1->(DBCLOSEAREA())

RETURN cCODIGO

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fCADSEG   | Autor |KENNY ROGER MARTINS    | Data | 30.03.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |CRIA FORNECEDOR SEGURADORA UTILIZADO NO SIGATMS               |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fCADSEG(cESTADO)
LOCAL cCODIGO

DBSELECTAREA("SA2")
SA2->(DBSETORDER(2))
IF SA2->(DBSEEK(xFILIAL("SA2") + "SEGURADORA GENERICA TMS"))
	cCODIGO := SA2->(A2_COD+A2_LOJA)
ELSE
	cCODIGO := GETSXENUM("SA2")
	CONFIRMSX8()

	RECLOCK("SA2", .T.)
	SA2->A2_FILIAL := xFILIAL("SA2")
	SA2->A2_COD    := cCODIGO
	SA2->A2_LOJA   := "01"
	SA2->A2_TIPO   := "J"
	SA2->A2_NOME   := "SEGURADORA GENERICA TMS"
	SA2->A2_NREDUZ := "SEGURADORA GENERICA TMS"
	SA2->A2_END    := "BRASIL"
	SA2->A2_MUN    := "BRASIL"
	SA2->A2_EST    := cESTADO
	SA2->(MSUNLOCK())
ENDIF
SA2->(DBCLOSEAREA())

RETURN cCODIGO                                      
                             
/*---------+----------+-------+-----------------------+------+------------+
|Função    |fCADTES   | Autor |KENNY ROGER MARTINS    | Data | 30.03.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |CRIA TES QUE SERÃO UTILIZADAS NO SIGATMS                      |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fCADTES()
fADDTES("481", "E", "N", "N", "000 ", "TMS | MOV.MERCADORIA", "N")
fADDTES("981", "S", "N", "N", "000 ", "TMS | MOV.MERCADORIA", "N")
fADDTES("982", "S", "S", "S", "5352", "TMS | EST.INDUSTRIAL", "T")
fADDTES("983", "S", "S", "S", "5353", "TMS | EST.COMERCIAL ", "T")
RETURN NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fADDTES   | Autor |KENNY ROGER MARTINS    | Data | 30.03.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |ADICIONA A TES NO BANCO DE DADOS                              |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fADDTES(cCODIGO, cTIPO, cDUPLIC, cICMS, cCF, cTEXTO, cLIVRO)               
DBSELECTAREA("SF4")
SF4->(DBSETORDER(1))
IF !SF4->(DBSEEK(xFILIAL("SF4") + cCODIGO))
	RECLOCK("SF4", .T.)                       	
	SF4->F4_FILIAL  := xFILIAL("SF4")
	SF4->F4_CODIGO  := cCODIGO
	SF4->F4_TIPO    := cTIPO
	SF4->F4_CREDICM := "N"
	SF4->F4_CREDIPI := "N"
	SF4->F4_DUPLIC  := cDUPLIC
	SF4->F4_ESTOQUE := "N"
	SF4->F4_PODER3  := "N"
	SF4->F4_ICM     := cICMS
	SF4->F4_IPI     := "N"
	SF4->F4_CF      := cCF
	SF4->F4_TEXTO   := cTEXTO
	SF4->F4_LFICM   := cLIVRO
	SF4->F4_LFIPI   := "N"
	SF4->F4_DESTACA := "N"
	SF4->F4_INCIDE  := "N"
	SF4->F4_COMPL   := "N"
	SF4->(MSUNLOCK())
ENDIF
RETURN NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fADDPAR   | Autor |KENNY ROGER MARTINS    | Data | 30.03.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |ADICIONA PARÂMETROS                                           |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fADDPAR(nFILIAL, cPARAMETRO, cTIPO, cCONTEUDO, cDESC1, cDESC2, cDESC3)
SX6->(DBSETORDER(1))
IF SX6->(DBSEEK(aFILIAIS[nFILIAL,3] + cPARAMETRO))
	RECLOCK("SX6", .F.)	
	SX6->X6_CONTEUD := cCONTEUDO
	SX6->X6_DEFPOR  := cCONTEUDO
	MSUNLOCK("SX6")
ELSE
	RECLOCK("SX6", .T.)
	SX6->X6_FIL     := aFILIAIS[nFILIAL,3]
	SX6->X6_VAR     := cPARAMETRO
	SX6->X6_TIPO    := cTIPO
	SX6->X6_DESCRIC := cDESC1
	SX6->X6_DESC1   := cDESC2
	SX6->X6_DESC2   := cDESC3
	SX6->X6_PROPRI  := "S"
	SX6->X6_PYME    := "S"
	SX6->X6_CONTEUD := cCONTEUDO
	SX6->X6_DEFPOR  := cCONTEUDO
	MSUNLOCK("SX6")
ENDIF
RETURN NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |fCADTAR   | Autor |KENNY ROGER MARTINS    | Data | 30.03.2015 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |CADASTRA TAREFAS E ATIVIDADES                                 |
+----------+--------------------------------------------------------------+
|Uso       |WIZARD TMS                                                    |
+----------+-------------------------------------------------------------*/ 
STATIC FUNCTION fCADTAR(cCODCLI,nFILIAL)
LOCAL lINCLUI := .T.            
LOCAL cTARTRA := cTARNEG := cATINEG := cSERNEG := cSEROPE := cCODPAG := cCODCON := ""    
LOCAL cCODCOM := cCODIND := ""

DBSELECTAREA("SX5")
DBSETORDER(1)              
                   
/*------------------------------------------------------------------------+
| REGISTRA SEGMENTOS T3                                                   |
+------------------------------------------------------------------------*/    
lINCLUI := .T.
DBSEEK(xFILIAL("SX5")+"T3")
WHILE !EOF() .AND. SX5->(X5_FILIAL+X5_TABELA) == xFILIAL("SX5")+"T3"       
	IF ALLTRIM(SX5->X5_DESCRI) == "ESTABEL.COMERCIAL"
 		cCODCOM  := ALLTRIM(SX5->X5_CHAVE)
		lINCLUI := .F.
		EXIT
	ENDIF
	cCODCOM := ALLTRIM(SX5->X5_CHAVE)
	DBSKIP()
ENDDO      

IF lINCLUI                   
	cCODCOM := SOMA1(cCODCOM)
	RECLOCK("SX5", .T.)
	SX5->X5_FILIAL := xFILIAL("SX5")
	SX5->X5_TABELA := "T3"
	SX5->X5_CHAVE  := cCODCOM
	SX5->X5_DESCRI := "ESTABEL.COMERCIAL"
	MSUNLOCK()
ENDIF                                             

lINCLUI := .T.
DBSEEK(xFILIAL("SX5")+"T3")
WHILE !EOF() .AND. SX5->(X5_FILIAL+X5_TABELA) == xFILIAL("SX5")+"T3"       
	IF ALLTRIM(SX5->X5_DESCRI) == "ESTABEL.INDUSTRIAL
 		cCODIND  := ALLTRIM(SX5->X5_CHAVE)
		lINCLUI := .F.
		EXIT
	ENDIF
	cCODIND := ALLTRIM(SX5->X5_CHAVE)
	DBSKIP()
ENDDO      

IF lINCLUI                   
	cCODIND := SOMA1(cCODIND)
	RECLOCK("SX5", .T.)
	SX5->X5_FILIAL := xFILIAL("SX5")
	SX5->X5_TABELA := "T3"
	SX5->X5_CHAVE  := cCODIND
	SX5->X5_DESCRI := "ESTABEL.INDUSTRIAL"
	MSUNLOCK()
ENDIF

                                  
/*------------------------------------------------------------------------+
| TAREFA TRANSPORTE RODOVIÁRIO TABELA L2                                  |
+------------------------------------------------------------------------*/    
lINCLUI := .T.
DBSEEK(xFILIAL("SX5")+"L2")
WHILE !EOF() .AND. SX5->(X5_FILIAL+X5_TABELA) == xFILIAL("SX5")+"L2"       
	IF ALLTRIM(SX5->X5_DESCRI) == "TRANSPORTE RODOVIARIO"
 		cTARTRA  := ALLTRIM(SX5->X5_CHAVE)
		lINCLUI := .F.
		EXIT
	ENDIF
	cTARTRA := ALLTRIM(SX5->X5_CHAVE)
	DBSKIP()
ENDDO      

IF lINCLUI                   
	cTARTRA := SOMA1(cTARTRA)
	RECLOCK("SX5", .T.)
	SX5->X5_FILIAL := xFILIAL("SX5")
	SX5->X5_TABELA := "L2"
	SX5->X5_CHAVE  := cTARTRA
	SX5->X5_DESCRI := "TRANSPORTE RODOVIARIO"
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| TAREFA NEGOCIACAO COMERCIAL TABELA L2                                   |
+------------------------------------------------------------------------*/
lINCLUI := .T.
DBSEEK(xFILIAL("SX5")+"L2")
WHILE !EOF() .AND. SX5->(X5_FILIAL+X5_TABELA) == xFILIAL("SX5")+"L2"       
	IF ALLTRIM(SX5->X5_DESCRI) == "NEGOCIACAO COMERCIAL"
 		cTARNEG  := ALLTRIM(SX5->X5_CHAVE)
		lINCLUI := .F.
		EXIT
	ENDIF
	cTARNEG := ALLTRIM(SX5->X5_CHAVE)
	DBSKIP()
ENDDO      

IF lINCLUI                           
	cTARNEG := SOMA1(cTARNEG)
	RECLOCK("SX5", .T.)
	SX5->X5_FILIAL := xFILIAL("SX5")
	SX5->X5_TABELA := "L2"
	SX5->X5_CHAVE  := cTARNEG
	SX5->X5_DESCRI := "NEGOCIACAO COMERCIAL"
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| ATIVIDADE NEGOCIACAO COMERCIAL TABELA L3                                |
+------------------------------------------------------------------------*/
lINCLUI := .T.
DBSEEK(xFILIAL("SX5")+"L3")
WHILE !EOF() .AND. SX5->(X5_FILIAL+X5_TABELA) == xFILIAL("SX5")+"L3"
	IF ALLTRIM(SX5->X5_DESCRI) == "NEGOCIACAO COMERCIAL"
 		cATINEG  := ALLTRIM(SX5->X5_CHAVE)
		lINCLUI := .F.
		EXIT
	ENDIF
	cATINEG := ALLTRIM(SX5->X5_CHAVE)
	DBSKIP()
ENDDO      

IF lINCLUI                   
	cATINEG := SOMA1(cATINEG)
	RECLOCK("SX5", .T.)
	SX5->X5_FILIAL := xFILIAL("SX5")
	SX5->X5_TABELA := "L3"
	SX5->X5_CHAVE  := cATINEG
	SX5->X5_DESCRI := "NEGOCIACAO COMERCIAL"
	MSUNLOCK()
ENDIF               
                                                
/*------------------------------------------------------------------------+
| SERVIÇO NEGOCIACAO COMERCIAL TABELA L4                                  |
+------------------------------------------------------------------------*/
lINCLUI := .T.
DBSEEK(xFILIAL("SX5")+"L4")
WHILE !EOF() .AND. SX5->(X5_FILIAL+X5_TABELA) == xFILIAL("SX5")+"L4"
	IF ALLTRIM(SX5->X5_DESCRI) == "TRANSPORTE NACIONAL"
 		cSEROPE  := ALLTRIM(SX5->X5_CHAVE)
		lINCLUI := .F.
		EXIT
	ENDIF
	cSEROPE := ALLTRIM(SX5->X5_CHAVE)
	DBSKIP()
ENDDO      

IF lINCLUI                   
	cSEROPE := SOMA1(cSEROPE)
	RECLOCK("SX5", .T.)
	SX5->X5_FILIAL := xFILIAL("SX5")
	SX5->X5_TABELA := "L4"
	SX5->X5_CHAVE  := cSEROPE
	SX5->X5_DESCRI := "TRANSPORTE NACIONAL"
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| SERVIÇO NEGOCIACAO COMERCIAL TABELA L4                                  |
+------------------------------------------------------------------------*/
lINCLUI := .T.
DBSEEK(xFILIAL("SX5")+"L4")
WHILE !EOF() .AND. SX5->(X5_FILIAL+X5_TABELA) == xFILIAL("SX5")+"L4"
	IF ALLTRIM(SX5->X5_DESCRI) == "NEGOCIACAO COMERCIAL"
 		cSERNEG  := ALLTRIM(SX5->X5_CHAVE)
		lINCLUI := .F.
		EXIT
	ENDIF
	cSERNEG := ALLTRIM(SX5->X5_CHAVE)
	DBSKIP()
ENDDO      

IF lINCLUI                   
	cSERNEG := SOMA1(cSERNEG)
	RECLOCK("SX5", .T.)
	SX5->X5_FILIAL := xFILIAL("SX5")
	SX5->X5_TABELA := "L4"
	SX5->X5_CHAVE  := cSERNEG
	SX5->X5_DESCRI := "NEGOCIACAO COMERCIAL"
	MSUNLOCK()
ENDIF                   

/*------------------------------------------------------------------------+
| TAREFA CARREGAR VEÍCULO                                                 |
+------------------------------------------------------------------------*/
DBSELECTAREA("DC6")
DBSETORDER(1)
IF DC6->(!DBSEEK(xFILIAL("DC6")+"004"))
	RECLOCK("DC6", .T.)
	DC6->DC6_FILIAL := xFILIAL("DC6")
	DC6->DC6_TAREFA := "004"
	DC6->DC6_ORDEM  := "01"
	DC6->DC6_ATIVID := "048"
	DC6->DC6_DURAC  := "000:00"
	DC6->DC6_TPAGLU := "1"	
	MSUNLOCK()
ENDIF
                                            
/*------------------------------------------------------------------------+
| TAREFA TRANSPORTE RODOVIÁRIO                                            |
+------------------------------------------------------------------------*/
DBSELECTAREA("DC6")
DBSETORDER(1)
IF DC6->(!DBSEEK(xFILIAL("DC6")+cTARTRA))
	RECLOCK("DC6", .T.)
	DC6->DC6_FILIAL := xFILIAL("DC6")
	DC6->DC6_TAREFA := cTARTRA
	DC6->DC6_ORDEM  := "01"
	DC6->DC6_ATIVID := "049"
	DC6->DC6_DURAC  := "000:00"
	DC6->DC6_FILATI := aFILIAIS[nFILIAL,3]
	DC6->DC6_TPAGLU := "1"	
	MSUNLOCK()
	
	RECLOCK("DC6", .T.)
	DC6->DC6_FILIAL := xFILIAL("DC6")
	DC6->DC6_TAREFA := cTARTRA
	DC6->DC6_ORDEM  := "02"
	DC6->DC6_ATIVID := "050"
	DC6->DC6_DURAC  := "000:00"
	DC6->DC6_FILATI := aFILIAIS[nFILIAL,3]
	DC6->DC6_TPAGLU := "1"	
	MSUNLOCK()	
ENDIF
                                                
/*------------------------------------------------------------------------+
| TAREFA NEGOCIAÇÃO                                                       |
+------------------------------------------------------------------------*/
DBSELECTAREA("DC6")
DBSETORDER(1)
IF DC6->(!DBSEEK(xFILIAL("DC6")+cTARNEG))
	RECLOCK("DC6", .T.)
	DC6->DC6_FILIAL := xFILIAL("DC6")
	DC6->DC6_TAREFA := cTARNEG
	DC6->DC6_ORDEM  := "01"
	DC6->DC6_ATIVID := cATINEG
	DC6->DC6_DURAC  := "000:00"
	DC6->DC6_TPAGLU := "1"	
	MSUNLOCK()
ENDIF
                                           
/*------------------------------------------------------------------------+
| SERVIÇO OPERACIONAL                                                     |
+------------------------------------------------------------------------*/
DBSELECTAREA("DC5")
DBSETORDER(1)
IF DC5->(!DBSEEK(xFILIAL("DC5")+cSEROPE))
	RECLOCK("DC5", .T.)
	DC5->DC5_FILIAL := xFILIAL("DC5")
	DC5->DC5_SERVIC := cSEROPE
	DC5->DC5_TIPO   := "1"
	DC5->DC5_ORDEM  := "01"
	DC5->DC5_TAREFA := cTARTRA
	DC5->DC5_SERTMS := "3"
	DC5->DC5_TIPTRA := "1"
	DC5->DC5_CATSER := "2"
	DC5->DC5_TPSELE := "1"
	DC5->DC5_TIPRAT := "0"
	DC5->DC5_TPEXEC := "1"
	DC5->DC5_UTSUBS := "2"	
	MSUNLOCK()
ENDIF
IF DC5->(!DBSEEK(xFILIAL("DC5")+"002"))
	RECLOCK("DC5", .T.)
	DC5->DC5_FILIAL := xFILIAL("DC5")
	DC5->DC5_SERVIC := "002"
	DC5->DC5_TIPO   := "1"
	DC5->DC5_ORDEM  := "01"
	DC5->DC5_TAREFA := "004"
	DC5->DC5_SERTMS := "3"
	DC5->DC5_TIPTRA := "1"
	DC5->DC5_CATSER := "2"
	DC5->DC5_TPSELE := "1"
	DC5->DC5_TIPRAT := "0"
	DC5->DC5_TPEXEC := "1"
	DC5->DC5_UTSUBS := "2"	
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| SERVIÇO NEGOCIAÇÃO                                                      |
+------------------------------------------------------------------------*/
DBSELECTAREA("DC5")
DBSETORDER(1)
IF DC5->(!DBSEEK(xFILIAL("DC5")+cSERNEG))
	RECLOCK("DC5", .T.)
	DC5->DC5_FILIAL := xFILIAL("DC5")
	DC5->DC5_SERVIC := cSERNEG
	DC5->DC5_TIPO   := "1"
	DC5->DC5_ORDEM  := "01"
	DC5->DC5_TAREFA := cTARNEG
	DC5->DC5_SERTMS := "3"
	DC5->DC5_TIPTRA := "1"
	DC5->DC5_CATSER := "1"
	DC5->DC5_DOCTMS := "2"
	DC5->DC5_TPSELE := "1"
	DC5->DC5_SEROPE := cSEROPE
	DC5->DC5_TIPRAT := "0"
	DC5->DC5_TPEXEC := "1"
	DC5->DC5_UTSUBS := "2"	
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| REGISTRA COMPLEMENTO REGIÃO                                             |
+------------------------------------------------------------------------*/
DBSELECTAREA("DTN")
DBSETORDER(1)
IF DTN->(!DBSEEK(xFILIAL("DTN")+"BRA"))
	RECLOCK("DTN", .T.)
	DTN->DTN_FILIAL := xFILIAL("DTN")
	DTN->DTN_GRPVEN := "BRA"
	DTN->DTN_ITEM   := "01"
	DTN->DTN_SERTMS := "3"
	DTN->DTN_TIPTRA := "1"
	DTN->DTN_TIPREG := "3"
	MSUNLOCK()
ENDIF                        

/*------------------------------------------------------------------------+
| REGISTRA ZONAS                                                          |
+------------------------------------------------------------------------*/
DBSELECTAREA("DA5")
DBSETORDER(1)
IF DA5->(!DBSEEK(xFILIAL("DA5")+"BRASIL"))
	RECLOCK("DA5", .T.)
	DA5->DA5_FILIAL := xFILIAL("DA5")
	DA5->DA5_COD    := "BRASIL"
	DA5->DA5_DESC   := "BRASIL"
	DA5->DA5_TEMPO  := "0000:00"
	MSUNLOCK()
ENDIF    

/*------------------------------------------------------------------------+
| REGISTRA SETORES                                                        |
+------------------------------------------------------------------------*/
DBSELECTAREA("DA6")
DBSETORDER(1)
IF DA6->(!DBSEEK(xFILIAL("DA6")+"BRASIL"))
	RECLOCK("DA6", .T.)
	DA6->DA6_FILIAL := xFILIAL("DA6")
	DA6->DA6_PERCUR := "BRASIL"
	DA6->DA6_ROTA   := "BRASIL"
	DA6->DA6_REF    := "BRASIL"	
	DA6->DA6_TEMPO  := "0000:00"
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| REGISTRA PONTOS                                                         |
+------------------------------------------------------------------------*/
DBSELECTAREA("DA7")
DBSETORDER(1)
IF DA7->(!DBSEEK(xFILIAL("DA7")+"BRASIL"))
	RECLOCK("DA7", .T.)
	DA7->DA7_FILIAL := xFILIAL("DA7")
	DA7->DA7_PERCUR := "BRASIL"
	DA7->DA7_ROTA   := "BRASIL"
	DA7->DA7_SEQUEN := "000001"
	DA7->DA7_CEPDE  := "00000000"
	DA7->DA7_CEPATE := "99999999"
	DA7->DA7_REF    := "BRASIL"	
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| REGISTRA ROTAS                                                         |
+------------------------------------------------------------------------*/
DBSELECTAREA("DA8")
DBSETORDER(1)
IF DA8->(!DBSEEK(xFILIAL("DA8")+"BRASIL"))
	RECLOCK("DA8", .T.)
	DA8->DA8_FILIAL := xFILIAL("DA8")
	DA8->DA8_COD    := "BRASIL"
	DA8->DA8_DESC   := "ROTA GENERICA"
	DA8->DA8_LIMMAX := 0
	DA8->DA8_ATIVO  := "1"
	DA8->DA8_TEMPO  := "0000:00"
	DA8->DA8_TIPROT := "07"
	DA8->DA8_CDRORI := "BRA"
	DA8->DA8_SERVIC := cSEROPE
	DA8->DA8_SERTMS := "3"
	DA8->DA8_TIPTRA := "1"
	DA8->DA8_ROTMUN := "2"
	MSUNLOCK()
ENDIF      

DBSELECTAREA("DA9")
DBSETORDER(1)
IF DA9->(!DBSEEK(xFILIAL("DA9")+"BRASIL"))
	RECLOCK("DA9", .T.)
	DA9->DA9_FILIAL := xFILIAL("DA9")
	DA9->DA9_ROTEIR := "BRASIL"
	DA9->DA9_SEQUEN := "000010"
	DA9->DA9_PERCUR := "BRASIL"
	DA9->DA9_ROTA   := "BRASIL"
	DA9->DA9_REF    := "ROTA GENERICA"
	MSUNLOCK()
ENDIF                 

/*------------------------------------------------------------------------+
| REGISTRA COMPONENTES                                                    |
+------------------------------------------------------------------------*/
DBSELECTAREA("DT3")
DBSETORDER(1)
IF DT3->(!DBSEEK(xFILIAL("DT3")+"01"))
	RECLOCK("DT3", .T.)
	DT3->DT3_FILIAL := xFILIAL("DT3")
	DT3->DT3_CODPAS := "01"
	DT3->DT3_DESCRI := "FRETE INFORMADO"
	DT3->DT3_TIPFAI := "07"
	DT3->DT3_FAIXA  := "07"
	DT3->DT3_APLDES := "1"
	DT3->DT3_AGRVAL := "1"
	DT3->DT3_CALPES := "0"
	DT3->DT3_FRACAO := "1"
	DT3->DT3_TAXA   := "2"
	DT3->DT3_PSQTXA := "2"
	DT3->DT3_PSQTAB := "2"
	DT3->DT3_TIPCMP := "1"
	MSUNLOCK()
ENDIF      
IF DT3->(!DBSEEK(xFILIAL("DT3")+"02"))
	RECLOCK("DT3", .T.)
	DT3->DT3_FILIAL := xFILIAL("DT3")
	DT3->DT3_CODPAS := "02"
	DT3->DT3_DESCRI := "PEDAGIO INFORMADO"
	DT3->DT3_TIPFAI := "07"
	DT3->DT3_FAIXA  := "07"
	DT3->DT3_APLDES := "1"
	DT3->DT3_AGRVAL := "1"
	DT3->DT3_CALPES := "0"
	DT3->DT3_FRACAO := "1"
	DT3->DT3_TAXA   := "2"
	DT3->DT3_PSQTXA := "2"
	DT3->DT3_PSQTAB := "2"
	DT3->DT3_TIPCMP := "4"
	MSUNLOCK()
ENDIF      
IF DT3->(!DBSEEK(xFILIAL("DT3")+"11"))
	RECLOCK("DT3", .T.)
	DT3->DT3_FILIAL := xFILIAL("DT3")
	DT3->DT3_CODPAS := "11"
	DT3->DT3_DESCRI := "FRETE PESO"
	DT3->DT3_TIPFAI := "01"
	DT3->DT3_FAIXA  := "01"
	DT3->DT3_APLDES := "1"
	DT3->DT3_AGRVAL := "1"
	DT3->DT3_CALPES := "2"
	DT3->DT3_FRACAO := "1"
	DT3->DT3_TAXA   := "2"
	DT3->DT3_PSQTXA := "2"
	DT3->DT3_PSQTAB := "2"
	DT3->DT3_TIPCMP := "1"
	MSUNLOCK()
ENDIF      
IF DT3->(!DBSEEK(xFILIAL("DT3")+"12"))
	RECLOCK("DT3", .T.)
	DT3->DT3_FILIAL := xFILIAL("DT3")
	DT3->DT3_CODPAS := "12"
	DT3->DT3_DESCRI := "FRETE VALOR"
	DT3->DT3_TIPFAI := "02"
	DT3->DT3_FAIXA  := "02"
	DT3->DT3_APLDES := "1"
	DT3->DT3_AGRVAL := "1"
	DT3->DT3_CALPES := "0"
	DT3->DT3_FRACAO := "1"
	DT3->DT3_TAXA   := "2"
	DT3->DT3_PSQTXA := "2"
	DT3->DT3_PSQTAB := "2"
	DT3->DT3_TIPCMP := "5"
	MSUNLOCK()
ENDIF      
IF DT3->(!DBSEEK(xFILIAL("DT3")+"13"))
	RECLOCK("DT3", .T.)
	DT3->DT3_FILIAL := xFILIAL("DT3")
	DT3->DT3_CODPAS := "13"
	DT3->DT3_DESCRI := "PEDAGIO"
	DT3->DT3_TIPFAI := "09"
	DT3->DT3_FAIXA  := "09"
	DT3->DT3_APLDES := "1"
	DT3->DT3_AGRVAL := "1"
	DT3->DT3_CALPES := "0"
	DT3->DT3_FRACAO := "1"
	DT3->DT3_TAXA   := "2"
	DT3->DT3_PSQTXA := "2"
	DT3->DT3_PSQTAB := "2"
	DT3->DT3_TIPCMP := "4"
	MSUNLOCK()
ENDIF      

/*------------------------------------------------------------------------+
| REGISTRA CONFIG.TABELA DE FRETE                                         |
+------------------------------------------------------------------------*/
DBSELECTAREA("DTL")
DBSETORDER(1)
IF DTL->(!DBSEEK(xFILIAL("DTL")+"0001"))
	RECLOCK("DTL", .T.)
	DTL->DTL_FILIAL := xFILIAL("DTL")
	DTL->DTL_TABFRE := "0001"
	DTL->DTL_TIPTAB := "01"
	DTL->DTL_DATDE  := DATE()
	DTL->DTL_CATTAB := "1"
	DTL->DTL_NUMDEC := 2
	DTL->DTL_MOEDA  := 1
	MSUNLOCK()
ENDIF                   

/*------------------------------------------------------------------------+
| REGISTRA ITENS CONFIG.TABELA DE FRETE                                   |
+------------------------------------------------------------------------*/
DBSELECTAREA("DVE")
DBSETORDER(1)
IF DVE->(!DBSEEK(xFILIAL("DVE")+"000101"))
	RECLOCK("DVE", .T.)
	DVE->DVE_FILIAL := xFILIAL("DVE")
	DVE->DVE_TABFRE := "0001"
	DVE->DVE_TIPTAB := "01"
	DVE->DVE_ITEM   := "01"
	DVE->DVE_CODPAS := "01"
	DVE->DVE_COMOBR := "1"
	DVE->DVE_BASIMP := "1"
	MSUNLOCK()         
	
	RECLOCK("DVE", .T.)
	DVE->DVE_FILIAL := xFILIAL("DVE")
	DVE->DVE_TABFRE := "0001"
	DVE->DVE_TIPTAB := "01"
	DVE->DVE_ITEM   := "02"
	DVE->DVE_CODPAS := "02"
	DVE->DVE_COMOBR := "2"
	DVE->DVE_BASIMP := "1"
	MSUNLOCK()
ENDIF                         
                         
/*------------------------------------------------------------------------+
| REGISTRA CONDIÇÃO DE PAGAMENTO                                          |
+------------------------------------------------------------------------*/
DBSELECTAREA("SE4")
DBSETORDER(1)                
WHILE !EOF()
	IF ALLTRIM(SE4->E4_DESCRI) == "A VISTA"
		cCODPAG := SE4->E4_CODIGO
	ENDIF                                     
	DBSKIP()
ENDDO
IF EMPTY(cCODPAG)
	cCODPAG := GETSXENUM("SE4","E4_CODIGO")
	CONFIRMSX8()
	
	RECLOCK("SE4", .T.)
	SE4->E4_FILIAL := xFILIAL("SE4")
	SE4->E4_CODIGO := cCODPAG
	SE4->E4_TIPO   := "1"
	SE4->E4_COND   := "0"
	SE4->E4_DESCRI := "A VISTA"	
	MSUNLOCK()   
ENDIF

/*------------------------------------------------------------------------+
| REGISTRA CONTRATO GENÉRICO                                              |
+------------------------------------------------------------------------*/
DBSELECTAREA("AAM")
DBSETORDER(2)
IF AAM->(!DBSEEK(xFILIAL("AAM")+cCODCLI))                
	cCODCON := GETSXENUM("AAM","AAM_CONTRT")
	CONFIRMSX8()
	
	RECLOCK("AAM", .T.)
	AAM->AAM_FILIAL := xFILIAL("AAM")
	AAM->AAM_CONTRT := cCODCON
	AAM->AAM_CODCLI := SUBSTR(cCODCLI, 1, 6)
	AAM->AAM_LOJA   := SUBSTR(cCODCLI, 7, 2)
	AAM->AAM_TPCONT := "1"
	AAM->AAM_CLASSI := "001"
	AAM->AAM_ABRANG := "1"
	AAM->AAM_STATUS := "1"
	AAM->AAM_INIVIG := DATE()
	AAM->AAM_CPAGPV := cCODPAG
	AAM->AAM_TIPFRE := "3"
	AAM->AAM_REAAUT := "2"
	AAM->AAM_SELSER := "2"
	AAM->AAM_AGRNFC := "1"
	AAM->AAM_TAXCTR := "2"
	AAM->AAM_AJUOBR := "2"
	AAM->AAM_PRCPRD := "1"
	MSUNLOCK()
ENDIF                  

/*------------------------------------------------------------------------+
| REGISTRA ITENS DO CONTRATO GENÉRICO                                     |
+------------------------------------------------------------------------*/
DBSELECTAREA("DUX")
DBSETORDER(1)                                   
IF !EMPTY(cCODCON)
	IF DUX->(!DBSEEK(xFILIAL("DUX")+cCODCON))
		RECLOCK("DUX", .T.)
		DUX->DUX_FILIAL := xFILIAL("DUX")
		DUX->DUX_NCONTR := cCODCON
		DUX->DUX_ITEM   := "01"
		DUX->DUX_SERVIC := cSERNEG
		DUX->DUX_TABFRE := "0001"
		DUX->DUX_TIPTAB := "01"
		DUX->DUX_PORTMS := "2"
		DUX->DUX_EDITMS := "2"
		MSUNLOCK()
	ENDIF
ENDIF

/*------------------------------------------------------------------------+
| REGISTRA CONFIG.DOCUMENTOS                                              |
+------------------------------------------------------------------------*/
DBSELECTAREA("DUI")
DBSETORDER(1)                                   
IF DUI->(!DBSEEK(xFILIAL("DUI")+"2"))
	RECLOCK("DUI", .T.)
	DUI->DUI_FILIAL := xFILIAL("DUI")
	DUI->DUI_DOCTMS := "2"
	DUI->DUI_SERIE  := "UNI"
	DUI->DUI_CODPRO := "TMSSRV001"	
	MSUNLOCK()
ENDIF

/*------------------------------------------------------------------------+
| REGISTRA REGRAS DE TRIBUTACAO                                           |
+------------------------------------------------------------------------*/
DBSELECTAREA("DUF")
DBSETORDER(1)                                   
IF DUF->(!DBSEEK(xFILIAL("DUF")+"01"))
	RECLOCK("DUF", .T.)
	DUF->DUF_FILIAL := xFILIAL("DUF")
	DUF->DUF_REGTRI := "01"
	DUF->DUF_TIPFRE := "3"
	MSUNLOCK()
ENDIF                        

/*------------------------------------------------------------------------+
| REGISTRA ITENS REGRAS DE TRIBUTACAO                                     |
+------------------------------------------------------------------------*/
DBSELECTAREA("DUG")
DBSETORDER(1)                                   
IF DUG->(!DBSEEK(xFILIAL("DUG")+"01"))
	RECLOCK("DUG", .T.)
	DUG->DUG_FILIAL := xFILIAL("DUG")
	DUG->DUG_REGTRI := "01"
	DUG->DUG_TIPFRE := "3"
	DUG->DUG_ITEM   := "01"
	DUG->DUG_TES    := "982"    
	DUG->DUG_SATIV  := cCODIND
	DUG->DUG_CONSIG := "3"	
	MSUNLOCK()
	
	RECLOCK("DUG", .T.)
	DUG->DUG_FILIAL := xFILIAL("DUG")
	DUG->DUG_REGTRI := "01"
	DUG->DUG_TIPFRE := "3"
	DUG->DUG_ITEM   := "01"
	DUG->DUG_TES    := "983"    
	DUG->DUG_SATIV  := cCODCOM
	DUG->DUG_CONSIG := "3"	
	MSUNLOCK()	
ENDIF              

/*------------------------------------------------------------------------+
| REGISTRA ITENS REGRAS DE TRIBUTACAO                                     |
+------------------------------------------------------------------------*/
DBSELECTAREA("DV1")
DBSETORDER(1)                                   
IF DV1->(!DBSEEK(xFILIAL("DV1")+cCODCLI))
	RECLOCK("DV1", .T.)
	DV1->DV1_FILIAL := xFILIAL("DV1")
	DV1->DV1_CODCLI := SUBSTR(cCODCLI,1,6)
	DV1->DV1_LOJCLI := SUBSTR(cCODCLI,7,2)
	DV1->DV1_DOCTMS := "2"
	DV1->DV1_REGTRI := "01"
	DV1->DV1_TIPNFC := "0"
	MSUNLOCK()
ENDIF                                

/*------------------------------------------------------------------------+
| REGISTRA PERFIL DO CLIENTE                                              |
+------------------------------------------------------------------------*/
DBSELECTAREA("DUO")
DBSETORDER(1)                                   
IF DUO->(!DBSEEK(xFILIAL("DUO")+cCODCLI))
	RECLOCK("DUO", .T.)
	DUO->DUO_FILIAL := xFILIAL("DUO")
	DUO->DUO_CODCLI := SUBSTR(cCODCLI,1,6)
	DUO->DUO_LOJCLI := SUBSTR(cCODCLI,7,2)
	DUO->DUO_CNDFRE := "01"
	DUO->DUO_FOBDIR := "2"
	DUO->DUO_CUBAGE := "1"
	DUO->DUO_BASFAT := "1"
	DUO->DUO_SEPPRO := "2"
	DUO->DUO_SEPTRA := "2"
	DUO->DUO_SEPFRE := "2"
	DUO->DUO_TAXCTR := "2"
	DUO->DUO_AJUOBR := "2"
	DUO->DUO_SEPREM := "0"
	DUO->DUO_AGRNFC := "1"
	DUO->DUO_SEPENT := "2"
	DUO->DUO_RECFRE := "1"
	DUO->DUO_TPDIAS := "2"
	DUO->DUO_PGREEN := "2"
	DUO->DUO_PGREFA := "2"
	DUO->DUO_PGARMZ := "2"
	DUO->DUO_PRCPRD := "1"
	DUO->DUO_SEPSRV := "2"
	DUO->DUO_EDIAUT := "0"
	DUO->DUO_EDILOT := "0"
	DUO->DUO_PGPEDG := "2"
	DUO->DUO_BASREE := "1"
	MSUNLOCK()
ENDIF                              

/*------------------------------------------------------------------------+
| REGISTRA OCORRÊNCIA                                                     |
+------------------------------------------------------------------------*/
DBSELECTAREA("DT2")
DBSETORDER(1)                                   
IF DT2->(!DBSEEK(xFILIAL("DT2")+"0001"))
	RECLOCK("DT2", .T.)
	DT2->DT2_FILIAL := xFILIAL("DT2")
	DT2->DT2_CODOCO := "0001"
	DT2->DT2_DESCRI := "PROCESSO CONCLUIDO"
	DT2->DT2_SERTMS := "3"
	DT2->DT2_TIPOCO := "01"
	DT2->DT2_RESOCO := "1"
	DT2->DT2_CATOCO := "2"
	DT2->DT2_ATIVO  := "1"
	DT2->DT2_MAILDV := "2"
	DT2->DT2_MAILRE := "2"
	DT2->DT2_MAILDT := "2"
	DT2->DT2_MAILCS := "2"
	DT2->DT2_MAILDP := "2"
	DT2->DT2_ODOCHG := "2"
	DT2->DT2_TIPRDP := "1"
	MSUNLOCK()
ENDIF

RETURN {cSERNEG, cSEROPE}
