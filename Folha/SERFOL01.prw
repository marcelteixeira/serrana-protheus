#include 'protheus.ch'

/*/{Protheus.doc} SERFOL01
(long_description)
@author    Brittes
@since     12/06/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
/* --------------------------------------------------------------------------------------
| Data     |  Autor       | Motivo                                                      |
+----------+--------------+-------------------------------------------------------------+
| 07/12/21 | Givanildo    | Na alteração - Não alterar os campos da SA2 - já alterados  |
+----------+--------------+-------------------------------------------------------------+
*/
Class SERFOL01 

	Data cNome
	Data cNomeComp
	Data cCod
	Data cTipo
	Data cEnderec
	Data cSexo
	Data cUf
	Data cCodMun
	Data cMunip
	Data cCCusto
	Data cPais
	Data cUser
	Data cGrpUser
	Data aCps
	Data aCpsX3
	Data cRuleRet
	Data lRuleRet 
	Data aErros
	Data cBairro
	Data cComplem		
	Data cCep 			
	Data cCGC			
	Data cEmail 
	Data lRet   
	Data cCodMot
	Data cCodFor   
	Data cClass
	Data cCodUsr 
	Data cTel 
	Data lBlocked
	
	Data cNumCnh
	Data cRegCnh
	Data dDtEcnh
	Data dDtVcnh
	Data cMunCnh
	Data cEstCnh
	Data cCatCnh	
	
	Data cRG
	Data cDtRGExp
	Data cRGuF			
	Data cRgOrg
	
	Data cAntt	
	Data cCatEfd
	Data cCnpj	
		
	Method new() constructor 
	Method Rules()  
	Method Load()  
	Method Requests()
	Method Coperate()
	Method Driver()
	Method Supplier()
	Method ClassValue()
	Method Divergen()
	Method Vehicle()

Endclass

/*/{Protheus.doc} new
Metodo construtor
@author    Brittes
@since     12/06/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method new() class SERFOL01

	::cGrpUser 		:= ""
	::cUser 		:= ""

	::aCps			:= {}
	::aCpsX3		:= {}

	::cRuleRet		:= ""
	::lRuleRet 		:= .T.

	::aErros 		:= {}

	::lRet 			:= .T.

	::cCodMot		:= ""
	::cCodFor 		:= ""
	::cClass		:= ""
	::cCodUsr       := ""
	::lBlocked		:= .f.


	IF 	ALTERA

		::cNome     	:= SubStr(SRA->RA_NOME,1,20)
		::cNomeComp 	:= Substr(SRA->RA_NOMECMP,1,40)
		::cCod 			:= Alltrim(SRA->RA_MAT)
		::cTipo 		:= "F"
		::cEnderec 		:= SubStr(Alltrim(SRA->RA_ENDEREC) +" - "+ Alltrim(SRA->RA_NUMENDE),1,20)
		::cSexo 		:= Alltrim(SRA->RA_SEXO)
		::cCCusto 		:= Alltrim(SRA->RA_CC)
		
		::cUf 			:= Alltrim(SRA->ESTADO)
		::cCodMun 		:= Alltrim(SRA->RA_CODMUN)
		::cMunip 		:= Alltrim(SRA->RA_CODMUNE)
		::cPais			:= Alltrim(SRA->RA_NACIONC )
		::cBairro       := Alltrim(SRA->RA_BAIRRO)
		::cComplem		:= Alltrim(SRA->RA_COMPLEM)
		::cCep 			:= Alltrim(SRA->RA_CEP)
		//::cCGC			:= Alltrim(SRA->RA_CIC)
		::cCGC			:= Iif(SRA->RA_PROCES == '00005' .and. !Empty(SRA->RA_YCNPJ),Alltrim(SRA->RA_YCNPJ),Alltrim(SRA->RA_CIC))
		::cEmail        := Alltrim(SRA->RA_EMAIL)
		::cTel          := Alltrim(SRA->RA_TELEFON)
				
		::cNumCnh		:= Alltrim(SRA->RA_HABILIT)
		::cRegCnh		:= Alltrim(SRA->RA_CNHORG)
		::dDtEcnh		:= SRA->RA_DTEMCNH
		::dDtVcnh		:= SRA->RA_DTVCCNH
		//::cMunCnh		:= Alltrim(SRA->RA_)
		::cEstCnh		:= Alltrim(SRA->RA_UFCNH)
		::cCatCnh		:= Alltrim(SRA->RA_CATCNH)
		
		::cRG 			:= Alltrim(SRA->RA_RG)
		::cDtRGExp 		:= Alltrim(SRA->RA_DTRGEXP)
		::cRGuF			:= Alltrim(SRA->RA_RGUF)
		::cRgOrg		:= Alltrim(SRA->RA_RGORG)
		
		::cAntt         := Alltrim(SRA->RA_YANTT)
		::cCatEfd       := Alltrim(SRA->RA_CATEFD)
		::cCnpj         := Alltrim(SRA->RA_YCNPJ)
		::lBlocked		:= IIF(Alltrim(SRA->RA_YSITUA) <> '2', .f.,.t.)
			
	Else

		::cNome     	:= SubStr(M->RA_NOME,1,20)
		::cNomeComp 	:= Substr(M->RA_NOMECMP,1,40)
		::cCod 			:= Alltrim(M->RA_MAT)
		::cTipo 		:= "F"
		::cEnderec 		:= SubStr(Alltrim(M->RA_ENDEREC) +" - "+ Alltrim(M->RA_NUMENDE),1,20)
		::cSexo 		:= Alltrim(M->RA_SEXO)
		::cUf 			:= Alltrim(M->RA_ESTADO)
		::cCodMun 		:= Alltrim(M->RA_CODMUN)
		::cMunip 		:= Alltrim(M->RA_CODMUNE)
		::cCCusto 		:= Alltrim(M->RA_CC)
		::cPais			:= Alltrim(M->RA_NACIONC) //NACIONA
		::cUser 		:= ""
		::cGrpUser 		:= {}
		::cBairro       := Alltrim(M->RA_BAIRRO)
		::cComplem		:= Alltrim(M->RA_COMPLEM)
		::cCep 			:= Alltrim(M->RA_CEP)
		//::cCGC			:= Alltrim(M->RA_CIC)
		::cCGC			:= Iif(M->RA_PROCES == '00005' .and. !Empty(M->RA_YCNPJ),Alltrim(M->RA_YCNPJ),Alltrim(M->RA_CIC))
		::cEmail        := Alltrim(M->RA_EMAIL)
		::cTel          := Alltrim(SRA->RA_TELEFON)
		
		::cNumCnh		:= Alltrim(M->RA_HABILIT)
		::cRegCnh		:= Alltrim(M->RA_CNHORG)
		::dDtEcnh		:= M->RA_DTEMCNH
		::dDtVcnh		:= M->RA_DTVCCNH
		//::cMunCnh		:= Alltrim(M->RA_)
		::cEstCnh		:= Alltrim(M->RA_UFCNH)
		::cCatCnh		:= Alltrim(M->RA_CATCNH)
		
		::cRG 			:= Alltrim(M->RA_RG)
		::cDtRGExp 		:= M->RA_DTRGEXP
		::cRGuF			:= Alltrim(M->RA_RGUF)
		::cRgOrg		:= Alltrim(M->RA_RGORG)
		
		::cAntt         := Alltrim(M->RA_YANTT)
		::cCatEfd       := Alltrim(M->RA_CATEFD)
		::cCnpj         := Alltrim(M->RA_YCNPJ)
		::lBlocked		:= IIF(Alltrim(M->RA_YSITUA) <> '2', .f.,.t.)
		

	Endif	
	
	::cUser 		:= ""
	::cGrpUser 		:= {}

	MsgRun("Efetuando Cadastros", "Aguarde!", {|| ::Load() }) 

return

Method Load() class SERFOL01

	Local aArea := GetArea()

	//Fornecedor
	IF ::cCatEfd $ "734" .OR. !EMPTY(::cCnpj)
		IF !::Supplier()
			::lRet := .F.
			Return()
		Endif
	Endif

	//Classe de Valor
	If !::ClassValue()
		::lRet := .F.
		Return()
	Endif

	//Motorista
	IF ::cCatEfd $ "734"
		If !::Driver()
			::lRet := .F.
			Return()
		Endif
	Endif

	//Solicitante
	//IF !::Requests()
	//	::lRet := .F.
	//	Return()
	//Endif


	//Cooperado
	IF ::lRet
		::Coperate() //Atualiza campos Referencia
		::Vehicle()
	Endif

	RestArea(aArea)

Return 

Method Vehicle() CLass SERFOL01
	
	Local cAliasDA3 := GetNextAlias()
	DA3->(DbSetOrder(1))
	SA2->(DbSetOrder(3))
	
	If SA2->(DbSeek(xFilial("SA2") + ::cCGC))
	
		BeginSql Alias cAliasDA3
		
			SELECT DA3.R_E_C_N_O_ AS RECNO FROM %Table:DA3% DA3
			WHERE DA3.D_E_L_E_T_ =''
			AND DA3.DA3_FILIAL = %Exp:xFilial("DA3")%
			AND DA3.DA3_CODFOR = %Exp:SA2->A2_COD%
			AND DA3.DA3_LOJFOR = %Exp:SA2->A2_LOJA%
		
		EndSql
				
		While (cAliasDA3)->(!EOF()) 
			
			DA3->(DbGoTo((cAliasDA3)->RECNO))
			
			RecLock("DA3",.F.)
				DA3->DA3_MSBLQL	:= IIF(::lBlocked,'1','2')
			DA3->(MsUnlock())
		
			(cAliasDA3)->(DbSkip())
		EndDo
	
	End If

Return

Method Supplier() class SERFOL01

	Local cFields := GetNewPar("MV_YCPOCLI","A2_COD/A2_LOJA/A2_NOME/A2_NREDUZ/A2_TIPO/A2_MUN/A2_END/A2_EST/A2_RNTRC")
	Local aFields := {}
	Local cTable  := "SA2"
	Local lRet	  := .T.
	Local cCod    := ""
	Local cLoja   := ""

	aFields := StrToKarr(cFields,'/')


	DbSelectArea("SA2")
	DbSetOrder(3)
	IF !DbSeek(xFilial("SA2") + ::cCGC)

		//Analisa Regras de Campos Obrigatorios
		::Rules(cTable,aFields)

		If ::lRuleRet

			aVetor := {{"A2_LOJA" ,"01"        ,nil},;
			{"A2_NOME"    ,::cNomeComp     ,nil},;
			{"A2_NREDUZ"  ,::cNome         ,nil},;
			{"A2_END"     ,::cEnderec      ,nil},;
			{"A2_EST"     ,::cUf           ,nil},;
			{"A2_NR_END"  ,"SN"            ,nil},;
			{"A2_TIPO" 	  ,Iif(Len(Alltrim(::cCGC))=11,"F","J")             ,nil},;
			{"A2_FILIAL"  ,xFilial("SA2")  ,nil},;
			{"A2_COD_MUN" ,::cCodMun       ,nil},;
			{"A2_BAIRRO"  ,::cBairro       ,nil},;
			{"A2_COMPLEM" ,::cComplem      ,nil},;
			{"A2_CEP" 	  ,::cCep          ,nil},;
			{"A2_CGC" 	  ,::cCGC          ,nil},;
			{"A2_EMAIL"   ,::cEmail        ,nil},;
			{"A2_MUN" 	  ,::cMunip        ,nil},;
			{"A2_RECINSS" ,"S"		       ,nil},;
			{"A2_CALCIRF" ,"1"		       ,nil},;
			{"A2_RECSEST" ,"1"		       ,nil},;
			{"A2_COND"    ,"001"	       ,nil},;
			{"A2_MINIRF"  ,"1"		       ,nil},;			
			{"A2_RNTRC"   ,::cAntt         ,nil}}

			MSExecAuto({|x,y| Mata020(x,y)},aVetor,3)   

			If lMsErroAuto
				IF MsgYesNo("Deseja Visualizar o Erro?","Estrutura")
					MostraErro()
				Endif

				RollBackSX8() // Se deu algum erro ele libera o n° do auto incremento para ser usado novamente;

				lRet := .F.
			Else

				::cCodFor := SA2->A2_COD

				ConfirmSX8()   // Confirma se o auto incremento foi usado;
			EndIf
		Else
			::Divergen(::aErros)

			lRet := .F.
		Endif	

	Else
		//Analisa Regras de Campos Obrigatorios
		cCod  := SA2->A2_COD
		cLoja := SA2->A2_LOJA
		::Rules(cTable,aFields)

		If ::lRuleRet

			aVetor := {{"A2_COD" ,cCod     ,nil},;
			{"A2_LOJA"    ,cLoja           ,nil},;
			{"A2_NOME"    ,::cNomeComp     ,nil},;
			{"A2_NREDUZ"  ,::cNome         ,nil},;
			{"A2_END"     ,::cEnderec      ,nil},;
			{"A2_EST"     ,::cUf           ,nil},;
			{"A2_COD_MUN" ,::cCodMun       ,nil},;
			{"A2_BAIRRO"  ,::cBairro       ,nil},;
			{"A2_COMPLEM" ,::cComplem      ,nil},;
			{"A2_CEP" 	  ,::cCep          ,nil},;
			{"A2_CGC" 	  ,::cCGC          ,nil},;
			{"A2_EMAIL"   ,::cEmail        ,nil},;
			{"A2_MUN" 	  ,::cMunip        ,nil},;
			{"A2_MSBLQL"   ,IIF(::lBlocked,"1","2"),nil},;			
			{"A2_RNTRC"   ,::cAntt         ,nil}}

			/*{"A2_NR_END"  ,"SN"          ,nil},; */ //GVA [07/12/2021]
			/*{"A2_TIPO" 	,"F"           ,nil},; */ //GVA [07/12/2021]
			/*{"A2_FILIAL"  ,xFilial("SA2"),nil},; */ //GVA [07/12/2021]
			/*{"A2_RECINSS" ,"S"		   ,nil},; */ //GVA [07/12/2021]
			/*{"A2_CALCIRF" ,"1"		   ,nil},; */ //GVA [07/12/2021]
			/*{"A2_RECSEST" ,"1"		   ,nil},; */ //GVA [07/12/2021]
			/*{"A2_COND"    ,"001"	       ,nil},; */ //GVA [07/12/2021]
			/*{"A2_MINIRF"  ,"1"		   ,nil},; */ //GVA [07/12/2021]

			MSExecAuto({|x,y| Mata020(x,y)},aVetor,4)   

			If lMsErroAuto
				IF MsgYesNo("Deseja Visualizar o Erro?","Estrutura")
					MostraErro()
				Endif

				RollBackSX8() // Se deu algum erro ele libera o n° do auto incremento para ser usado novamente;

				lRet := .F.
			Else

				::cCodFor := SA2->A2_COD
				//ConfirmSX8()   // Confirma se o auto incremento foi usado;
			EndIf
		Else
			::Divergen(::aErros)

			lRet := .F.
		Endif	
		
	Endif

Return lRet

Method ClassValue() class SERFOL01

	Local cItemConta :="F" + SA2->A2_COD + SA2->A2_LOJA
	Local aDadosAuto := {}
	Local lRet := .T.
			
	Private lMsHelpAuto := .f.
	Private lMsErroAuto := .f.	
	
	DbSelectArea("CTD")
	CTD->(DBSETORDER(1))    
	
	IF ::cCatEfd $ "734" .OR. !EMPTY(::cCnpj)
		IF !CTD->(DBSEEK(XFILIAL("CTD")+"F"+SA2->A2_COD+SA2->A2_LOJA)) 
			
			aDadosAuto:= {	{'CTD_ITEM' , cItemConta	, Nil},	;	// Especifica qual o CÛdigo do item contabil
						{'CTD_CLASSE'   , "2"			, Nil},	;	// Especifica a classe do Centro de Custo, que  poder· ser: - SintÈtica: Centros de Custo totalizadores dos Centros de Custo AnalÌticos - AnalÌtica: Centros de Custo que recebem os valores dos lanÁamentos cont·beis
						{'CTD_NORMAL'   , "0"			, Nil},	;	// Indica a classificaÁ„o do centro de custo. 1-Receita ; 2-Despesa                                        
						{'CTD_DESC01'   , SA2->A2_NOME	, Nil},	;	// Indica a Nomenclatura do item contabil na Moeda 1
						{'CTD_DTEXIS' 	, DATE()		, Nil}}	;	// Especifica qual a Data de InÌcio de ExistÍncia para este Centro de Custo
	
			MSExecAuto({|x, y| CTBA040(x, y)},aDadosAuto, 3)
		
			If lMsErroAuto	
				lRet := .F.	
				MostraErro()
			Else	
		
				::cClass	:= Alltrim(CTD->CTD_ITEM)
			
				lRet := .T.
		
			EndIf
		Endif
	
	Endif	

	IF lRet 
	
		cItemConta :="A" + ::cCod 
	
		DbSelectArea("CTD")
		CTD->(DBSETORDER(1))    
		IF !CTD->(DBSEEK(XFILIAL("CTD")+"A"+::cCod )) 
				
			aDadosAuto:= {	{'CTD_ITEM' , cItemConta	, Nil},	;	// Especifica qual o CÛdigo do item contabil
						{'CTD_CLASSE'   , "2"			, Nil},	;	// Especifica a classe do Centro de Custo, que  poder· ser: - SintÈtica: Centros de Custo totalizadores dos Centros de Custo AnalÌticos - AnalÌtica: Centros de Custo que recebem os valores dos lanÁamentos cont·beis
						{'CTD_NORMAL'   , "0"			, Nil},	;	// Indica a classificaÁ„o do centro de custo. 1-Receita ; 2-Despesa                                        
						{'CTD_DESC01'   , SA2->A2_NOME	, Nil},	;	// Indica a Nomenclatura do item contabil na Moeda 1
						{'CTD_DTEXIS' 	, DATE()		, Nil}}	;	// Especifica qual a Data de InÌcio de ExistÍncia para este Centro de Custo
		
			MSExecAuto({|x, y| CTBA040(x, y)},aDadosAuto, 3)
			
			If lMsErroAuto	
				lRet := .F.	
				MostraErro()
			Else	
			
				::cClass	:= Alltrim(CTD->CTD_ITEM)
				
				lRet := .T.
			
			EndIf
		
		Endif	
	
	Endif
	
Return lRet


Return lRet

Method Driver() class SERFOL01

	Local cFields := GetNewPar("MV_YCPODRV","DA4_COD/DA4_NOME/DA4_NREDUZ")
	Local aFields := {}
	Local cTable  := "DA4"
	Local lRet := .F.

	aFields := StrToKarr(cFields,'/')

	If Empty(::cCGC)

		MsgAlert("CPF Nao foi preenchido, motorista nao sera criado")

		Return lRet
	Endif	

	If Len(::cCGC) > 11

		MsgAlert("Informado CNPJ, motorista nao sera criado")

		Return lRet
	Endif	
	::Rules(cTable,aFields)

	If ::lRuleRet

		lRet := .T.

		DBSelectArea("DA4")
		DA4->(DBSETORDER(3))  
		IF !DA4->(DBSEEK(XFILIAL("DA4") + ::cCGC  )) 

			cCod := GetSxEnum("DA4","DA4_COD")

			DA4->(reclock("DA4",.T.))
			//Dados do Motorista
			DA4->DA4_COD 	:= cCod
			DA4->DA4_NOME	:= ::cNomeComp
			DA4->DA4_NREDUZ	:= ::cNome
			DA4->DA4_CGC	:= ::cCGC
			DA4->DA4_END	:= ::cEnderec
			DA4->DA4_BAIRRO	:= ::cBairro
			DA4->DA4_MUN	:= ::cMunip
			DA4->DA4_CODMUN	:= ::cCodMun			
			DA4->DA4_EST	:= ::cUf
			DA4->DA4_CEP	:= ::cCep
			DA4->DA4_FILIAL	:= xFilial("DA4")
			DA4->DA4_TEL	:= ::cTel
			
			//Dados CNH
			DA4->DA4_NUMCNH	:= ::cNumCnh
			DA4->DA4_REGCNH	:= ::cRegCnh
			DA4->DA4_DTECNH	:= ::dDtEcnh
			DA4->DA4_DTVCNH	:= ::dDtVcnh
			//DA4->DA4_MUNCHN	:= ::cMunCnh
			DA4->DA4_ESTCNH	:= ::cEstCnh
			DA4->DA4_CATCNH	:= ::cCatCnh
			
			//Dados RG		
			DA4->DA4_RG 		:= ::cRG 			
			DA4->DA4_RGDT		:= ::cDtRGExp 		
			DA4->DA4_RGEST		:= ::cRGuF			
			DA4->DA4_RGORG		:= ::cRgOrg		
			
			DA4->(msunlock())

			ConfirmSX8() 

			::cCodMot := DA4->DA4_COD

		Else //Alteracao	

			DA4->(reclock("DA4",.F.))
			DA4->DA4_NOME	:= ::cNomeComp
			DA4->DA4_NREDUZ	:= ::cNome
			DA4->DA4_END	:= ::cEnderec
			DA4->DA4_BAIRRO	:= ::cBairro
			DA4->DA4_MUN	:= ::cMunip
			DA4->DA4_CODMUN	:= ::cCodMun			
			DA4->DA4_EST	:= ::cUf
			DA4->DA4_CEP	:= ::cCep
			
			//Dados CNH
			DA4->DA4_NUMCNH	:= ::cNumCnh
			DA4->DA4_REGCNH	:= ::cRegCnh
			DA4->DA4_DTECNH	:= ::dDtEcnh
			DA4->DA4_DTVCNH	:= ::dDtVcnh
			//DA4->DA4_MUNCHN	:= ::cMunCnh
			DA4->DA4_ESTCNH	:= ::cEstCnh
			DA4->DA4_CATCNH	:= ::cCatCnh
			DA4->DA4_MSBLQL	:= IIF(::lblocked, '1', '2')
			
			//Dados RG		
			DA4_RG 			:= ::cRG 			
			DA4_RGDT		:= ::cDtRGExp 		
			DA4_RGUF		:= ::cRGuF			
			DA4_RGORG		:= ::cRgOrg		
			
		
			
			DA4->(msunlock())			

		Endif
	Else
		::Divergen(::aErros)

		lRet := .F.
	Endif	

Return lRet

Method Requests() class SERFOL01

	Local cTable  := "SAI"
	Local cUser   := "" 
	Local cGrUser := ""
	Local lRet 	  := .F.
	Local aGrpUsr := UsrRetGrp(RetCodUsr())
	Local aGrpCom := UsrGrComp(RetCodUsr())

	DBSelectArea("SAI")
	SAI->(DBSETORDER(2))  
	IF ! SAI->(DBSEEK(XFILIAL("SAI")+ RetCodUsr()  )) 

		lRet := .T.

		SAI->(reclock("SAI",.T.))
		SAI->AI_USER 	  := RetCodUsr()	
		SAI->AI_USRNAME	  := UsrFullName(RetCodUsr())	
		SAI->AI_GRUSER	  := aGrpUsr[1]
		SAI->AI_GRUPCOM	  := aGrpCom[1]
		//SAI->AI_QUANT	  := 
		//SAI->AI_GRPNAME := 
		//SAI->AI_GRUPO	  := 
		//SAI->AI_ITEM	  := 
		//SAI->AI_PRODUTO := 
		SAI->(msunlock())

		::cCodUsr := SAI->AI_USER 

	Endif

Return lRet

Method Coperate() class SERFOL01

	Local cTable  := "SRA"

	M->RA_MSBLQL := IIF(::lblocked, '1', '2')

	IF INCLUI

		M->RA_YMOT 		:= ::cCodMot
		M->RA_YFORN		:= ::cCodFor
		//M->RA_YUSR      := ::cCodUsr
		M->RA_YCLASS    := ::cClass	

	Endif

Return 

Method Rules(cTable,aFields) class SERFOL01 

	Local lRet 		:= .F.
	Local aObrigt 	:= {}

	::lRuleRet := .T.

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cTable)
	//Analisa campos obrigatorios
	While !Eof() .And. SX3->X3_ARQUIVO = cTable

		If x3uso(SX3->X3_USADO) .and. ((SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == "x") .or. VerByte(SX3->x3_reserv,7))

			Aadd(aObrigt,SX3->X3_CAMPO)
		EndIf     

		DbSkip()      

	Enddo

	//Compara Estrutura Atual com a Antiga 
	For nCount := 1 To Len(aObrigt) 

		nPos := aScan(aFields, Alltrim(aObrigt[nCount])) 

		If nPos < 1
			::cRuleRet := aObrigt[nCount] 
			::lRuleRet := .F.

			aAdd(::aErros,{aObrigt[nCount],"Campo nao consta na estrutura"}) 

		Endif			
	Next

Return 
Method Divergen() Class  SERFOL01

	Local nCol     	:= oMainWnd:nClientWidth
	Local nLin     	:= oMainWnd:nClientHeight
	Local nOpca     	:= 0                                        
	Local cVar      	:= ""

	Local nSuperior 	:= 015
	Local nEsquerda 	:= 005
	Local nInferior  	:= 165
	Local nDireita   	:= 370  

	Local oDlgDiverg
	Local oDiverg

	DEFINE MSDIALOG oDlgDiverg TITLE "Divergencias" FROM 0,0 To 390,750 PIXEL

	@ nSuperior,nEsquerda LISTBOX oDiverg VAR cVar Fields HEADER OemtoAnsi("Campo"),OemtoAnsi("Divergencia") SIZE nDireita,nInferior OF oDlgDiverg PIXEL

	oDiverg:SetArray(::aErros)
	oDiverg:bLine:={|| {::aErros[oDiverg:nAT,1],::aErros[oDiverg:nAT,2]}}
	oDiverg:Refresh()

	ACTIVATE MSDIALOG oDlgDiverg CENTERED ON INIT EnchoiceBar(oDlgDiverg,{|| nOpca:=1,oDlgDiverg:End()},{|| oDlgDiverg:End()})   

Return
User function SERFOL01()

	Local oSerFol01 := Nil

	oSerFol01 := SERFOL01():New()

Return  oSerFol01:lRet
