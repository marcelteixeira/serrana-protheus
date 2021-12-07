#INCLUDE "PROTHEUS.CH"
   
/*---------+----------+-------+-----------------------+------+------------+
|Função    |ADDREG    | Autor |KENNY ROGER MARTINS    | Data | 19.04.2011 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |GRAVA REGISTROS NO BANCO                                      |
+----------+--------------------------------------------------------------+
|Uso       |GENERICO                                                      |
+----------+-------------------------------------------------------------*/
USER FUNCTION ADDREG(cTABELA,aHEADER,aCOLS,aCPOEST,aPKEST,cTIPO,cCPOVAL)    
LOCAL cAREA := GETAREA()
LOCAL lRET	:= .T.                             
LOCAL aTAM	:= {}          
LOCAL cPRE	   
LOCAL nPOS  := 1       
//PRIVATE cNIVEL :=9


IF cTIPO == "E"	
	IF SUBSTR(aHEADER[1],3,1) == "_"
		cPRE := SUBSTR(aHEADER[1],1,2)
	ELSE
		cPRE := SUBSTR(aHEADER[1],1,3)
	ENDIF

	RECLOCK(cTABELA, .T.)
	&(cTABELA+"->"+cPRE+"_FILIAL") := XFILIAL(cTABELA)
	FOR nX := 1 TO LEN(aHEADER)
		&(cPRE+"->"+aHEADER[nX]) := &("M->"+aHEADER[nX])
	NEXT
	MSUNLOCK(cTABELA)		                    	
ELSEIF cTIPO == "G"                     
	IF !EMPTY(cCPOVAL)
		nPOS := ASCAN(aHEADER, {|X| X[2] == cCPOVAL})
	ENDIF
	IF nPOS < 1
		nPOS := 1
	ENDIF

	IF SUBSTR(aHEADER[1,2],3,1) == "_"
		cPRE := SUBSTR(aHEADER[1,2],1,2)
	ELSE
		cPRE := SUBSTR(aHEADER[1,2],1,3)
	ENDIF

	FOR nX := 1 TO LEN(aCOLS)   
		aTAM := aCOLS[nX]		
		IF !EMPTY(aTAM[1])
			IF !aTAM[LEN(aTAM)] 
				IF !EMPTY(aTAM[nPOS]) .OR. EMPTY(cCPOVAL)
					RECLOCK(cTABELA, .T.)	
					&(cTABELA+"->"+cPRE+"_FILIAL") := XFILIAL(cTABELA)
					FOR nY := 1 TO LEN(aTAM)
						IF nY <= LEN(aHEADER)
							IF aHEADER[nY,2] == cPRE+"_FILIAL"
								&(cTABELA+"->"+aHEADER[nY,2]) := XFILIAL(cTABELA)
							ELSEIF aHEADER[nY,10] <> "V"
								&(cTABELA+"->"+aHEADER[nY,2]) := aTAM[nY]
							ENDIF
						ENDIF    				
					NEXT      
					FOR nW := 1 TO LEN(aCPOEST)
						&(cTABELA+"->"+aCPOEST[nW]) := &("M->"+aPKEST[nW])
					NEXT
					MSUNLOCK(cTABELA)
				ENDIF
			ENDIF
		ENDIF
	NEXT
ENDIF					      

RESTAREA(cAREA)
                         
RETURN lRET

/*---------+----------+-------+-----------------------+------+------------+
|Função    |EDITREG   | Autor |KENNY ROGER MARTINS    | Data | 19.04.2011 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |ALTERA REGISTROS NO BANCO                                     |
+----------+--------------------------------------------------------------+
|Uso       |GENERICO                                                      |
+----------+-------------------------------------------------------------*/
USER FUNCTION EDITREG(cTABELA,aHEADER,aCOLS,aCPOEST,aPKEST,cTIPO,cCPOVAL,nRECNO)    
LOCAL cAREA   := GETAREA()
LOCAL lRET    := .T.                             
LOCAL aTAM    := {}                                                        
LOCAL cPRE	                                                            
LOCAL nPOS	  := 1
//PRIVATE CNIVEL := 9       

/*------------------------------------------------------------------------+
|ROTINA CHAMADA POR UMA ENCHOICE                                          |
+------------------------------------------------------------------------*/
IF cTIPO == "E"			                     
	IF nRECNO == NIL
		ALERT("ERRO")
		RETURN .F.
	ENDIF
	
	IF SUBSTR(aHEADER[1],3,1) == "_"
		cPRE := SUBSTR(aHEADER[1],1,2)
	ELSE
		cPRE := SUBSTR(aHEADER[1],1,3)
	ENDIF

	DBSELECTAREA(cTABELA)
	DBRLOCK(nRECNO)
	&(cTABELA+"->"+cPRE+"_FILIAL") := XFILIAL(cTABELA)
	FOR nX := 1 TO LEN(aHEADER)                               	
		&(cTABELA+"->"+aHEADER[nX]) := &("M->"+aHEADER[nX])
	NEXT
	DBRUNLOCK(nRECNO)
	DBCLOSEAREA(cTABELA)	
/*------------------------------------------------------------------------+
|ROTINA CHAMADA POR UMA GRID                                              |
+------------------------------------------------------------------------*/
ELSEIF cTIPO == "G"
	IF !EMPTY(cCPOVAL)
		nPOS := ASCAN(aHEADER, {|X| X[2] == cCPOVAL})
	ENDIF
	IF nPOS < 1
		nPOS := 1
	ENDIF

	IF SUBSTR(aHEADER[1,2],3,1) == "_"
		cPRE := SUBSTR(aHEADER[1,2],1,2)
	ELSE
		cPRE := SUBSTR(aHEADER[1,2],1,3)
	ENDIF
	/*------------------------------------------------------------------------+
	|PERCORRE aCOLS                                                           |
	+------------------------------------------------------------------------*/
	FOR nX := 1 TO LEN(aCOLS)
		aTAM := aCOLS[nX]			      
		/*------------------------------------------------------------------------+
		|VERIFICA SE O ÚLTIMO CAMPO DO VETOR ESTA PREENCHIDO COM .T. CASO SIM     |
		|A ROTINA DEVERA VERIFICAR SE EXISTE O REGISTRO NO BANCO CASO SIM         |
		|A ROTINA DEVERA REMOVER O REGISTRO DO BANCO                              |
		+------------------------------------------------------------------------*/
		IF !aTAM[LEN(aTAM)]          
			IF aTAM[LEN(aTAM)-1]==0
				IF !EMPTY(aTAM[nPOS]) .OR. EMPTY(cCPOVAL)		
					RECLOCK(cTABELA, .T.)                                        
					&(cTABELA+"->"+cPRE+"_FILIAL") := XFILIAL(cTABELA)
					FOR nY := 1 TO LEN(aTAM)
						IF nY <= LEN(aHEADER)
							IF aHEADER[nY,2] == cPRE+"_FILIAL"
								&(cTABELA+"->"+aHEADER[nY,2]) := XFILIAL(cTABELA)
							ELSEIF aHEADER[nY,10] <> "V"
								&(cTABELA+"->"+aHEADER[nY,2]) := aTAM[nY]
							ENDIF
						ENDIF    				
					NEXT
					FOR nW := 1 TO LEN(aCPOEST)
						&(cTABELA+"->"+aCPOEST[nW]) := &("M->"+aPKEST[nW])					
					NEXT
					MSUNLOCK(cTABELA)
				ENDIF
			ELSE
				DBSELECTAREA(cTABELA)   
				DBRLOCK(&(cTABELA+"->("+CVALTOCHAR(aTAM[LEN(aTAM)-1])+")"))
				&(cTABELA+"->"+cPRE+"_FILIAL") := XFILIAL(cTABELA)
				
				FOR nY := 1 TO LEN(aTAM)
					IF nY <= LEN(aHEADER)
						IF aHEADER[nY,2] == cPRE+"_FILIAL"
							&(cTABELA+"->"+aHEADER[nY,2]) := XFILIAL(cTABELA)
						ELSEIF aHEADER[nY,10] <> "V"
							&(cTABELA+"->"+aHEADER[nY,2]) := aTAM[nY]
						ENDIF
					ENDIF    				
				NEXT
				FOR nW := 1 TO LEN(aCPOEST)
					&(cTABELA+"->"+aCPOEST[nW]) := &("M->"+aPKEST[nW])
				NEXT
				DBRUNLOCK(&(cTABELA+"->("+CVALTOCHAR(aTAM[LEN(aTAM)-1])+")"))
				DBCLOSEAREA(cTABELA)	
			ENDIF
		ELSEIF aTAM[LEN(aTAM)-1] > 0                                 
			DBSELECTAREA(cTABELA)   
			DBRLOCK(&(cTABELA+"->("+CVALTOCHAR(aTAM[LEN(aTAM)-1])+")"))
			DBDELETE()
			DBRUNLOCK(&(cTABELA+"->("+CVALTOCHAR(aTAM[LEN(aTAM)-1])+")"))
			DBCLOSEAREA(cTABELA)	
		ENDIF
	NEXT
ENDIF					              

RESTAREA(cAREA)

RETURN lRET

/*---------+----------+-------+-----------------------+------+------------+
|Função    |DELREG    | Autor |KENNY ROGER MARTINS    | Data | 19.04.2011 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |EXCLUI REGISTROS DO BANCO                                     |
+----------+--------------------------------------------------------------+
|Uso       |GENERICO                                                      |
+----------+-------------------------------------------------------------*/
USER FUNCTION DELREG(cTABELA,aHEADER,aCOLS,aCPOEST,aPKEST,cTIPO,nRECNO)      
LOCAL cAREA	  := GETAREA()
LOCAL lRET    := .T.                             
LOCAL aTAM    := {}
//PRIVATE CNIVEL:= 9               

/*------------------------------------------------------------------------+
|ROTINA CHAMADA POR UMA ENCHOICE                                          |
+------------------------------------------------------------------------*/
IF cTIPO == "E"			              
	IF nRECNO == NIL
		ALERT("ERRO")
		RETURN .F.
	ENDIF
    
	DBSELECTAREA(cTABELA)
	DBRLOCK(nRECNO)
	DBDELETE()
	DBRUNLOCK(nRECNO)
	DBCLOSEAREA(cTABELA)	
/*------------------------------------------------------------------------+
|ROTINA CHAMADA POR UMA GRID                                              |
+------------------------------------------------------------------------*/
ELSEIF cTIPO == "G"
	/*------------------------------------------------------------------------+
	|PERCORRE aCOLS                                                           |
	+------------------------------------------------------------------------*/
	FOR nX := 1 TO LEN(aCOLS)
		aTAM := aCOLS[nX]			      
		IF !aTAM[LEN(aTAM)]
			IF aTAM[LEN(aTAM)-1] > 0
				DBSELECTAREA(cTABELA)   
				DBRLOCK(&(cTABELA+"->("+CVALTOCHAR(aTAM[LEN(aTAM)-1])+")"))
				DBDELETE()
				DBRUNLOCK(&(cTABELA+"->("+CVALTOCHAR(aTAM[LEN(aTAM)-1])+")"))
				DBCLOSEAREA(cTABELA)	
			ENDIF
		ENDIF
	NEXT
ENDIF					
     
RESTAREA(cAREA)

RETURN lRET

