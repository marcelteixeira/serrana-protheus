#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ M030INC  ºAutor  ³Francisco Pasolini  º Data ³  01/10/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criar item contabil de forma automatica                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cadastro de Clientes                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ± ±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M030INC()

Local aArea  := GetArea() 

Local cItemConta :="C" + SA1->A1_COD + SA1->A1_LOJA
Local aDadosAuto := {}
			
Private lMsHelpAuto := .f.
Private lMsErroAuto := .f.	
 
DbSelectArea("CTD")
CTD->(DBSETORDER(1))    	
IF !CTD->(DBSEEK(XFILIAL("CTD")+cItemConta))
	
	aDadosAuto:= {	{'CTD_ITEM' , cItemConta	    , Nil},	;	// Codigo do item contabil
					{'CTD_CLASSE'   , "2"			, Nil},	;	// Classe do Item Contabil
					{'CTD_NORMAL'   , "0"			, Nil},	;	// Classificao do item contabil. 1-Receita ; 2-Despesa                                        
					{'CTD_DESC01'   , SA1->A1_NOME	, Nil},	;	// Nomenclatura do item contabil na Moeda 1
					{'CTD_DTEXIS' 	, DATE()		, Nil}}		// Data de Início de Existência 
	MSExecAuto({|x, y| CTBA040(x, y)},aDadosAuto, 3)
Endif	 

RestArea(aArea)

Return .t.     