#include 'protheus.ch'

User Function NUMSEQPRD() 
Local _cNumPrd	:= ""
Local _cRet		:= ""
                                  
	_cNumPrd := SBM->BM_YSEQUEN//Posicione("SBM",1,xFilial("SBM")+M->B1_GRUPO,"BM_YSEQUEN")

	If Alltrim(_cNumPrd) = ""
		_cNumPrd := "0001"
	Else
		_cNumPrd := Soma1(_cNumPrd,4)
	EndIf
	
	_cRet := M->B1_GRUPO+_cNumPrd

Return(_cRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT010INC  �Autor  �                    � Data � 12/06/2008  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada na inclus�o do produto                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BrasilPontoCom                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT010INC()

DbSelectArea("SBM")
SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
SBM->(Reclock("SBM",.F.))
	SBM->BM_YSEQUEN := Substr(SB1->B1_COD,5,4)
MsUnLock()

Return()