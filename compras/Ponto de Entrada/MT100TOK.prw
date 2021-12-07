//Validar a entrada de nota fiscal.
//Caso haja retencao de IR, torna-se obrigatorio informar o codigo de retencao e Gerar DIRF = SIM
/*/
############################################################################
Programa:  |MT100TOk    |Autor: Francisco Pasolini     |Data:  28/01/2020
############################################################################
Descricao: |PE - LINHA OK DA NOTA FISCAL
############################################################################
Uso:       | COMPRAS			                                        
############################################################################
/*/

#INCLUDE "PROTHEUS.CH"

User Function MT100TOK()
Local lRet := .T.   
Local lIrr := .F.
Local nPos 
Local nCont := 1

If FunName() == "MATA103" //Documento de Entrada

	nPos	:= ASCAN(aHeader,{|x| Alltrim(x[2]) == "D1_VALIRR"      }) 

	While nCont <= Len(aCols) .and. !lIrr 
		If aCols[nCont,Len(aCols[nCont])] == .F. //CHECA SE A LINHA NAO ESTA DELETADA
			if aCols[nCont,nPos] > 0 //VERIFICA SE HOUVE RETENCAO DE IMPOSTO DE RENDA
				lIrr := .T.	
			endif
		endif
		nCont++
	enddo

	if lIrr
		if cDirf <> '1' .or. Empty(cCodRet)
			MsgAlert("Obrigatorio informar Gera Dirf = SIM e Codigo de Retencao para notas fiscais com retenção de imposto de renda!")
			lRet := .F.
			oFolder:nOption := 5
		endif
	endif
endif

Return(lRet)

