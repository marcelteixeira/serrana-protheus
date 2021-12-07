#include "rwmake.ch"
/*
  Desenvolovido por Vanderlei Wikianovski - 20/05/2015
  Processa os arquvos de clientes e fornecedores incluíndo 
  na base da ITEM Conta (CTD)
  IV2 Tecnologia

*/

User function iCliente()

	If MsgYesNo("Processo Item Conta para Cliente?", "Cliente")
		Processa( {|| pCliente() }, "Aguarde...", "Carregando Dados Item Conta... SA1",.F.)
	Endif

	If MsgYesNo("Processo Item Conta para Fornecedor?", "Fornecedor")
		Processa( {|| pFornec()  }, "Aguarde...", "Carregando Dados Item Conta... SA2",.F.)
	Endif
	
	Alert("Finalizado !")

Return

//Static 
STATIC function pCliente()
//***********************
Local cItemConta
Local aDadosAuto := {}
Private lMsHelpAuto := .f.
Private lMsErroAuto := .f.

dbSelectArea("SA1")
dbSetOrder(1)

ProcRegua(Reccount())

SA1->(dbGotop())

While ! SA1->(Eof())
	
	cItemConta:="C" + SA1->A1_COD + SA1->A1_LOJA
	
	//Verifica se o Item Contabil existe
	dbSelectArea("CTD")                
	dbSetOrder(1)
	dbGoTop()
		
	If !dbSeek(xFilial("CTD")+cItemConta)    

		cDataIn:=Date()

		aDadosAuto:= {	{'CTD_ITEM'   	, cItemConta				, Nil},	;	// Especifica qual o Código do item contabil
						{'CTD_CLASSE'   , "2"						, Nil},	;	// Especifica a classe do Centro de Custo, que  poderá ser: - Sintética: Centros de Custo totalizadores dos Centros de Custo Analíticos - Analítica: Centros de Custo que recebem os valores dos lançamentos contábeis
						{'CTD_NORMAL'   , "0"						, Nil},	;	// Indica a classificação do centro de custo. 1-Receita ; 2-Despesa                                        
						{'CTD_DESC01'   , SA1->A1_NOME				, Nil},	;	// Indica a Nomenclatura do item contabil na Moeda 1
						{'CTD_DTEXIS' 	, cDataIn					, Nil}}		// Especifica qual a Data de Início de Existência para este Centro de Custo

		MSExecAuto({|x, y| CTBA040(x, y)},aDadosAuto, 3)

		If lMsErroAuto	
			lRetorno := .F.	
			MostraErro()    
			lMsErroAuto:=.f.			
		Else	
			lRetorno:=.T.
		EndIF
	Endif               
	SA1->(dbSkip())
	IncProc()
End While	

Return

//Static 
STATIC function pFornec()
//***********************
Local cItemConta
Local aDadosAuto := {}
Private lMsHelpAuto := .f.
Private lMsErroAuto := .f.

dbSelectArea("SA2")
dbSetOrder(1)

ProcRegua(Reccount())

SA2->(dbGotop())

While ! SA2->(Eof())

	cItemConta:="F" + SA2->A2_COD + SA2->A2_LOJA

	//Verifica se o Item Contabil existe
	dbSelectArea("CTD")                
	dbSetOrder(1)
	dbGoTop()
		
	If !dbSeek(xFilial("CTD")+cItemConta)
	
		cDataIn:=Date()

		aDadosAuto:= {	{'CTD_ITEM'   	, cItemConta				, Nil},	;	// Especifica qual o Código do item contabil
							{'CTD_CLASSE'   , "2"						, Nil},	;	// Especifica a classe do Centro de Custo, que  poderá ser: - Sintética: Centros de Custo totalizadores dos Centros de Custo Analíticos - Analítica: Centros de Custo que recebem os valores dos lançamentos contábeis
							{'CTD_NORMAL'   , "0"						, Nil},	;	// Indica a classificação do centro de custo. 1-Receita ; 2-Despesa                                        
							{'CTD_DESC01'   , SA2->A2_NOME				, Nil},	;	// Indica a Nomenclatura do item contabil na Moeda 1
							{'CTD_DTEXIS' 	, cDataIn					, Nil}}		// Especifica qual a Data de Início de Existência para este Centro de Custo

		MSExecAuto({|x, y| CTBA040(x, y)},aDadosAuto, 3)

		If lMsErroAuto	
			lRetorno := .F.	
			MostraErro() 
			lMsErroAuto:=.f.
			
		Else	
			lRetorno:=.T.
		EndIf               
	Endif
	SA2->(dbSkip())
	IncProc()
End While	

Return