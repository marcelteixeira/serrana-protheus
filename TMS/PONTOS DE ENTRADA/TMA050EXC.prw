#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} TMA050EXC
Estorno do Documento de Entrada
@author Totvs Vitoria - Mauricio Silva
@since 06/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TMA050EXC()
	Local aNfs 		:= PARAMIXB[1]
	Local lRet		:= PARAMIXB[2]
	Local cChave	:= ""
	Local nCnt := 0

	If !lRet
		Return
	End if

	// Localiza a nota fiscal pela chave e retira o numero do lote.
	SZE->(DbSetOrder(2))

	For nCnt := 1 To Len(aNfs)
	
		cChave := aNfs[nCnt,8]
		
		If SZE->(DbSeek(xFilial("SZE") + cChave))
			
			Reclock("SZE",.f.)
				SZE->ZE_LOTNFC := ""
			MsUnlock()
		End if
	Next nCnt

Return Nil