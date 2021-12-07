
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F050IRF   �Autor  �Francisco Pasolini  � Data �  19/06/20   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza o  campo Natureza Financeira uma vez que temos duas���
���          �naturezas possiveis, sendo que a default esta no parametro. ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F050IRF()

if Alltrim(SE2->E2_ORIGEM) == 'MATA100'
	SE2->E2_NATUREZ := '202011'
endif

//Atualiza��o do c�digo de reten��o referente ao Imposto de Renda
if SE2->E2_PREFIXO $ 'CRR/MED' .and. Alltrim(SE2->E2_TIPO) == 'TX' .and. Alltrim(SE2->E2_NATUREZ) == '202004'
	SE2->E2_CODRET := '0588'
	SE2->E2_DIRF := '1'
endif

U_UPDCC()

Return() 
