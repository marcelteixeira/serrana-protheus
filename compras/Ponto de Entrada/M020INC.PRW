#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �
��������������������������������������������������������������������������"��
���Programa  � M020INC  �Autor  �Francisco Pasolini  � Data �  18/12/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Criar item contabil de forma automatica                    ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Fornecedores                                   ���
�������������������������������������������������������������������������ͼ��
� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �
�����������������������������������������������������������������������������
*/

User Function M020INC()

Local aArea  := GetArea() 

Local cItemConta :="F" + SA2->A2_COD + SA2->A2_LOJA
Local aDadosAuto := {}
			
Private lMsHelpAuto := .f.
Private lMsErroAuto := .f.	
 
DbSelectArea("CTD")
CTD->(DBSETORDER(1))    	
IF !CTD->(DBSEEK(XFILIAL("CTD")+cItemConta))
	
	aDadosAuto:= {	{'CTD_ITEM' , cItemConta	    , Nil},	;	// Codigo do item contabil
					{'CTD_CLASSE'   , "2"			, Nil},	;	// Classe do Item Contabil
					{'CTD_NORMAL'   , "0"			, Nil},	;	// Classificao do item contabil. 1-Receita ; 2-Despesa                                        
					{'CTD_DESC01'   , SA2->A2_NOME	, Nil},	;	// Nomenclatura do item contabil na Moeda 1
					{'CTD_DTEXIS' 	, '19800101'	, Nil}}		// Data de In�cio de Exist�ncia 
	MSExecAuto({|x, y| CTBA040(x, y)},aDadosAuto, 3)
Endif	 

RestArea(aArea)

Return .t.     