#INCLUDE "PROTHEUS.CH"                        
/*
CLASS DBGRID FROM MSNEWGETDADOS

METHOD NEW() CONSTRUCTOR                                                                                                                             

ENDCLASS

METHOD NEW(nTOP,nLEFT,nBOTTOM,nRIGHT,nSTYLE,uLINHAOK,uTUDOOK,cINICPOS,aALTER,nFREEZE,nMAX,cFIELDOK,uSUPERDEL,uDELOK,oWND,aPARHEADER,aPARCOLS,uCHANGE,nALIGN,nOPCX) CLASS DBGRID
:NEW(nTOP,nLEFT,nBOTTOM,nRIGHT,nSTYLE,uLINHAOK,uTUDOOK,cINICPOS,aALTER,nFREEZE,nMAX,cFIELDOK,uSUPERDEL,uDELOK,oWND,aPARHEADER,aPARCOLS,uCHANGE)

::oBROWSE:ALIGN := nALIGN
::lDELETE		:= IF(nSTYLE == 3 .OR. nSTYLE == 4, .T., .F.)

RETURN SELF
*/
/*---------+----------+-------+-----------------------+------+------------+
|Função    |GETHEADER | Autor |KENNY ROGER MARTINS    | Data | 18.04.2011 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |RETORNA CABECALHO PARA USO NO MSNEWGETDADOS                   |
+----------+--------------------------------------------------------------+
|Parâmetros| cTABELA   => TABELA QUE SERÁ CONSULTADA		              |
|          | lVALID    => SE UTILIZA VALIDAÇÃO NO CAMPO	                  |
|          | lCHECKBOX => SE UTILIZA PRIMEIRO CAMPO COMO CHECKBOX         |
|          | aCAMPOS   => ARRAY CASO SEJA NECESSÁRIO FILTRAR CAMPOS       |
+----------+--------------------------------------------------------------+
|Uso       |GENERICO                                                      |
+----------+-------------------------------------------------------------*/
USER FUNCTION GETHEADER(cTABELA,lVALID,lCHECKBOX,aCAMPOS,lRECNO)
LOCAL nUSADO  := 0
LOCAL aHEADER := {}
LOCAL nX
//LOCAL cNIVEL  := 9

IF lCHECKBOX
	AADD(aHEADER,{" ",cTABELA+"_OK","@BMP",02,/*DECIMAL*/,"ALLWAYSTRUE()",/*USADO*/,"C",/*ARQUIVO*/,/*CONTEXT*/})
ENDIF

DBSELECTAREA("SX3")

IF aCAMPOS == NIL
	aCAMPOS := {}
ENDIF

IF LEN(aCAMPOS) > 0
	DBSETORDER(2)
	FOR nX := 1 TO LEN(aCAMPOS)
		DBSEEK(aCAMPOS[nX])
		IF cNIVEL>=X3_NIVEL
			nUSADO++
			IF lVALID == .F.
				AADD(aHEADER, { X3_TITULO, "NO"+SUBSTR(X3_CAMPO,3,8), X3_PICTURE, X3_TAMANHO, ;
				X3_DECIMAL, "ALLWAYSTRUE()", /*X3_USADO*/, X3_TIPO, /*X3_F3*/, /*X3_CONTEXT*/ } )
			ELSE
				AADD(aHEADER, { X3_TITULO, X3_CAMPO, X3_PICTURE, X3_TAMANHO, ;
				X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT } )
			ENDIF
		ENDIF
		//		ELSE
		//			AADD(aHEADER, {" ", aCAMPOS[nX], "@BMP", 2, 0 , ".F.", "", "C", "", "V", "", "", "", "V"})
		//		ENDIF
	NEXT
ELSE
	DBSETORDER(1)
	DBSEEK(cTABELA)
	WHILE !EOF() .AND. X3_ARQUIVO==cTABELA
		IF X3USO(X3_USADO) .AND. cNIVEL>=X3_NIVEL .AND. X3_BROWSE=='S'
			nUSADO++
			IF lVALID == .F.
				AADD(aHEADER, { X3_TITULO, "NO"+SUBSTR(X3_CAMPO,3,8), X3_PICTURE, X3_TAMANHO, ;
				X3_DECIMAL, "ALLWAYSTRUE()", /*X3_USADO*/, X3_TIPO, /*X3_F3*/, /*X3_CONTEXT*/ } )
			ELSE
				AADD(aHEADER, { X3_TITULO, X3_CAMPO, X3_PICTURE, X3_TAMANHO, ;
				X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT } )
			ENDIF
		ENDIF
		SX3->(DBSKIP())
	ENDDO
END

IF VALTYPE(lRECNO) <> "U"
	IF lRECNO
		AADD( aHEADER, { "Alias WT", PREFIXOCPO(cTABELA)+"_ALI_WT", "", 03, 0, "", , "C", cTABELA, "V"} )
		AADD( aHEADER, { "Recno WT", PREFIXOCPO(cTABELA)+"_REC_WT", "", 10, 0, "", , "N", cTABELA, "V"} )
	ENDIF
ELSE
	AADD( aHEADER, { "Alias WT", PREFIXOCPO(cTABELA)+"_ALI_WT", "", 03, 0, "", , "C", cTABELA, "V"} )
	AADD( aHEADER, { "Recno WT", PREFIXOCPO(cTABELA)+"_REC_WT", "", 10, 0, "", , "N", cTABELA, "V"} )
ENDIF

RETURN aHEADER

/*---------+----------+-------+-----------------------+------+------------+
|Função    |GETCAMPOS | Autor |KENNY ROGER MARTINS    | Data | 18.04.2011 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |RETORNA CAMPOS PARA USO NO MSNEWGETDADOS                      |
+----------+--------------------------------------------------------------+
|Uso       |GENERICO                                                      |
+----------+-------------------------------------------------------------*/
USER FUNCTION GETCAMPOS(cTABELA,lCHECKBOX)
LOCAL aCAMPOS := {}
//LOCAL cNIVEL  := 9

DBSELECTAREA("SX3")
DBSETORDER(1)
DBSEEK(cTABELA)

IF lCHECKBOX
	AADD(aCAMPOS, cTABELA+"_OK")
ENDIF

WHILE !EOF() .AND. X3_ARQUIVO==cTABELA
	IF !(X3_CAMPO $ cTABELA+"_FILIAL") .AND. cNIVEL >= X3_NIVEL;
		.AND. X3USO(X3_USADO) .AND. X3_BROWSE=='S' .AND. X3_VISUAL == "A"
		AADD(aCAMPOS, X3_CAMPO)
	ENDIF
	SX3->(DBSKIP())
ENDDO

RETURN aCAMPOS

/*---------+----------+-------+-----------------------+------+------------+
|Função    |GETACOLS  | Autor |KENNY ROGER MARTINS    | Data | 18.04.2011 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |RETORNA ACOLS PARA USO NO MSNEWGETDADOS                       |
+----------+--------------------------------------------------------------+
|Uso       |GENERICO                                                      |
+----------+-------------------------------------------------------------*/
USER FUNCTION GETACOLS(cTABELA, cPKTAB, cPKEST, nOPC, aHEADER, cCPOINI, cSEQUEN, nINDICE, lCHECKBOX, cFILTRO, bFILTRO, lRECNO)
LOCAL aCOLS  := {}
LOCAL nUSADO := LEN(aHEADER)-2
LOCAL nPRE
//PRIVATE cNIVEL:=9

IF lCHECKBOX
	IF EMPTY(nINDICE)
		nINDICE := 1
	ENDIF
	
	DBSELECTAREA(cTABELA)
	DBSETORDER(nINDICE)
	
	IF cFILTRO <> "" .AND. cFILTRO <> NIL
		DBSETFILTER( {|| &cFILTRO}, cFILTRO )
		DBGOTOP()
	ENDIF
	
	DBSELECTAREA("SX3")
	DBSETORDER(2)                                        		
		
	WHILE !(&(cTABELA)->(EOF()))                         
	
		IF VALTYPE(lRECNO) <> "U"
			IF lRECNO
				AADD(aCOLS, ARRAY(nUSADO+3))
			ELSE
				nUSADO := LEN(aHEADER)
				AADD(aCOLS, ARRAY(nUSADO+1))     					
			ENDIF
		ELSE
			AADD(aCOLS, ARRAY(nUSADO+3))
		ENDIF
			
		FOR nX := 1 TO nUSADO
			IF nX == 1
				aCOLS[LEN(aCOLS),nX] := "LBNO"
			ELSE
				SX3->(DBSEEK(aHEADER[nX,2]))
				aCOLS[LEN(aCOLS),nX] := CRIAVAR(aHEADER[nX,2])
				IF X3_CONTEXT == "V" .AND. !EMPTY(X3_INIBRW)
					aCOLS[LEN(aCOLS),nX] := &X3_INIBRW
				ELSE
					aCOLS[LEN(aCOLS),nX] := &(cTABELA)->(FIELDGET(FIELDPOS(aHEADER[nX,2])))
				ENDIF
			ENDIF
		NEXT                     
		
		IF VALTYPE(lRECNO) <> "U"
			IF lRECNO
				aCOLS[LEN(aCOLS),nUSADO+1] := cTABELA
				aCOLS[LEN(aCOLS),nUSADO+2] := &(cTABELA)->(RECNO())
				aCOLS[LEN(aCOLS),nUSADO+3] := .F.
			ELSE
				aCOLS[LEN(aCOLS),nUSADO+1] := .F.
			ENDIF
		ELSE
			aCOLS[LEN(aCOLS),nUSADO+1] := cTABELA
			aCOLS[LEN(aCOLS),nUSADO+2] := &(cTABELA)->(RECNO())
			aCOLS[LEN(aCOLS),nUSADO+3] := .F.
		ENDIF
		
		&(cTABELA)->(DBSKIP())
	ENDDO
	
	&(cTABELA)->(DBCLOSEAREA())
	
ELSEIF nOPC == 3
	AADD(aCOLS, ARRAY(nUSADO+3))
	FOR nX := 1 TO nUSADO
		IF aHEADER[nX,2] == cCPOINI
			aCOLS[1,nX] := cSEQUEN
		ELSE
			aCOLS[1,nX] := CRIAVAR(aHEADER[nX,2])
		ENDIF
	NEXT
	aCOLS[1,nUSADO+1] := cTABELA
	aCOLS[1,nUSADO+2] := 0
	aCOLS[1,nUSADO+3] := .F.
ELSEIF nOPC == 4
	IF EMPTY(nINDICE)
		nINDICE := 1
	ENDIF
	
	aCOLS := {}
	DBSELECTAREA(cTABELA)
	DBSETORDER(nINDICE)             
	
	IF cFILTRO <> "" .AND. VALTYPE(cFILTRO) <> "U"
		DBSETFILTER( {|| &cFILTRO}, cFILTRO )
		DBGOTOP()
	ENDIF	
	
	IF VALTYPE(cPKEST) <> "U"
		DBSEEK(xFILIAL(cTABELA)+cPKEST)
		DBSELECTAREA("SX3")
		DBSETORDER(2)
				
		WHILE !(&(cTABELA)->(EOF())) .AND. &cPKTAB == cPKEST
			IF VALTYPE(lRECNO) <> "U"
				IF lRECNO
					AADD(aCOLS, ARRAY(nUSADO+3))
				ELSE
					nUSADO := LEN(aHEADER)
					AADD(aCOLS, ARRAY(nUSADO+1))     					
				ENDIF
			ELSE
				AADD(aCOLS, ARRAY(nUSADO+3))
			ENDIF
			
			FOR nX := 1 TO nUSADO
				aCOLS[LEN(aCOLS),nX] := CRIAVAR(aHEADER[nX,2])
				SX3->(DBSEEK(aHEADER[nX,2]))
				IF X3_CONTEXT == "V" .AND. !EMPTY(X3_INIBRW)
					aCOLS[LEN(aCOLS),nX] := &X3_INIBRW
				ELSE
					aCOLS[LEN(aCOLS),nX] := &(cTABELA)->(FIELDGET(FIELDPOS(aHEADER[nX,2])))
				ENDIF
			NEXT
			
			IF VALTYPE(lRECNO) <> "U"
				IF lRECNO
					aCOLS[LEN(aCOLS),nUSADO+1] := cTABELA
					aCOLS[LEN(aCOLS),nUSADO+2] := &(cTABELA)->(RECNO())
					aCOLS[LEN(aCOLS),nUSADO+3] := .F.
				ELSE
					aCOLS[LEN(aCOLS),nUSADO+1] := .F.
				ENDIF
			ELSE
				aCOLS[LEN(aCOLS),nUSADO+1] := cTABELA
				aCOLS[LEN(aCOLS),nUSADO+2] := &(cTABELA)->(RECNO())
				aCOLS[LEN(aCOLS),nUSADO+3] := .F.
			ENDIF
			
			&(cTABELA)->(DBSKIP())
		ENDDO
	ELSE
		DBGOTOP()
		DBSELECTAREA("SX3")
		DBSETORDER(2)
				
		WHILE !(&(cTABELA)->(EOF()))
			IF VALTYPE(lRECNO) <> "U"
				IF lRECNO
					AADD(aCOLS, ARRAY(nUSADO+3))
				ELSE
					nUSADO := LEN(aHEADER)
					AADD(aCOLS, ARRAY(nUSADO+1))
				ENDIF
			ELSE
				AADD(aCOLS, ARRAY(nUSADO+3))
			ENDIF
			
			FOR nX := 1 TO nUSADO
				aCOLS[LEN(aCOLS),nX] := CRIAVAR(aHEADER[nX,2])
				SX3->(DBSEEK(aHEADER[nX,2]))
				IF X3_CONTEXT == "V" .AND. !EMPTY(X3_INIBRW)
					aCOLS[LEN(aCOLS),nX] := &X3_INIBRW
				ELSE
					aCOLS[LEN(aCOLS),nX] := &(cTABELA)->(FIELDGET(FIELDPOS(aHEADER[nX,2])))
				ENDIF
			NEXT
			
			IF VALTYPE(lRECNO) <> "U"
				IF lRECNO
					aCOLS[LEN(aCOLS),nUSADO+1] := cTABELA
					aCOLS[LEN(aCOLS),nUSADO+2] := &(cTABELA)->(RECNO())
					aCOLS[LEN(aCOLS),nUSADO+3] := .F.
				ELSE
					aCOLS[LEN(aCOLS),nUSADO+1] := .F.
				ENDIF
			ELSE
				aCOLS[LEN(aCOLS),nUSADO+1] := cTABELA
				aCOLS[LEN(aCOLS),nUSADO+2] := &(cTABELA)->(RECNO())
				aCOLS[LEN(aCOLS),nUSADO+3] := .F.
			ENDIF
			
			&(cTABELA)->(DBSKIP())
		ENDDO
	ENDIF
	
	&(cTABELA)->(DBCLOSEAREA())
ELSE
	IF EMPTY(nINDICE)
		nINDICE := 1
	ENDIF
	
	aCOLS := {}
	DBSELECTAREA(cTABELA)
	DBSETORDER(nINDICE)
	DBSEEK(xFILIAL(cTABELA)+cPKEST)
	
	DBSELECTAREA("SX3")
	DBSETORDER(2)
		
	WHILE !(&(cTABELA)->(EOF())) .AND. &cPKTAB == cPKEST
		AADD(aCOLS, ARRAY(nUSADO+3))
		FOR nX := 1 TO nUSADO
			cCAMPO := aHEADER[nX,2]
			aCOLS[LEN(aCOLS),nX] := CRIAVAR(SUBSTR(cTABELA,1,2)+SUBSTR(cCAMPO,3,8))
			SX3->(DBSEEK(aHEADER[nX,2]))
			IF X3_CONTEXT == "V" .AND. !EMPTY(X3_INIBRW)
				aCOLS[LEN(aCOLS),nX] := &X3_INIBRW
			ELSEIF X3_CONTEXT != "V"
				aCOLS[LEN(aCOLS),nX] := &(cTABELA+"->"+SUBSTR(cTABELA,1,2)+SUBSTR(cCAMPO,3,8))
			ENDIF
		NEXT
		aCOLS[LEN(aCOLS),nUSADO+1] := cTABELA
		aCOLS[LEN(aCOLS),nUSADO+2] := &(cTABELA)->(RECNO())
		aCOLS[LEN(aCOLS),nUSADO+3] := .F.
		&(cTABELA)->(DBSKIP())
	ENDDO
	
	&(cTABELA)->(DBCLOSEAREA())
ENDIF

RETURN aCOLS       

/*---------+----------+-------+-----------------------+------+------------+
|Função    |GETACOLS  | Autor |KENNY ROGER MARTINS    | Data | 18.04.2011 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |RETORNA ACOLS PARA USO NO MSNEWGETDADOS                       |
+----------+--------------------------------------------------------------+
|Uso       |GENERICO                                                      |
+----------+-------------------------------------------------------------*/   
USER FUNCTION DKVTK271
LOCAL lRET := .T.    
LOCAL nX
LOCAL aCOLSANT := aCLONE(aCOLS)
LOCAL cPRODUTO := aCOLSANT[oGETTLV:oBROWSE:nAT,2]
FOR nX := 1 TO LEN(aCOLSANT)
	IF nX <> oGETTLV:oBROWSE:nAT
		IF aCOLSANT[nX,2] == cPRODUTO
			lRET := .F.
			ALERT("Produto já informado neste pedido!!!")
		ENDIF
	ENDIF
NEXT
RETURN lRET


