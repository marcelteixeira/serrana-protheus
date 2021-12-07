#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} CNTA300
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CNTA300()

    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.
    Local nLinha := 0
    Local nQtdLinhas := 0
    Local cMsg := ""
 
    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)
 
        If cIdPonto == "MODELPOS"			
		
			xRet := .T.
		
        ElseIf cIdPonto == "FORMPOS"
            cMsg := "Chamada na validação total do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF
 
            If lIsGrid
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            Else
                cMsg += "É um FORMFIELD" + CRLF
            EndIf
 
            xRet := .T.
 
        ElseIf cIdPonto == "FORMLINEPRE"
            If aParam[5] == "DELETE"
                cMsg := "Chamada na pré validação da linha do formulário. " + CRLF
                cMsg += "Onde esta se tentando deletar a linha" + CRLF
                cMsg += "ID " + cIdModel + CRLF
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
                xRet := .T. //ApMsgYesNo(cMsg + " Continua?")
            EndIf
 
        ElseIf cIdPonto == "FORMLINEPOS"
            cMsg := "Chamada na validação da linha do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
            cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            xRet := .T.
 
        ElseIf cIdPonto == "MODELCOMMITTTS"
           
           // Retira vinculo do contrato - Opcao Excluir
           If oObj:GetOperation() == 5
           		xRet:= ClearContr()
           End If
            
        ElseIf cIdPonto == "MODELCOMMITNTTS"
            //ApMsgInfo("Chamada após a gravação total do modelo e fora da transação.")
 
        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
            //ApMsgInfo("Chamada após a gravação da tabela do formulário.")
 
        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
            //ApMsgInfo("Chamada após a gravação da tabela do formulário.")
 
        ElseIf cIdPonto == "MODELCANCEL"
            cMsg := "Deseja realmente sair?"
            xRet := .T.
 
        ElseIf cIdPonto == "BUTTONBAR"
            xRet := nIL //{{"Salvar", "SALVAR", {||u_TSMT030()}}}
        EndIf
    EndIf
Return xRet

/*/{Protheus.doc} ClearContr
Retira o vinculo do contrato com o contrato
gerador.
@author Totvs Vitoria - Mauricio Silva
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ClearContr()
	
	Local aAreaCN9 	:= CN9->(GetArea())
	Local lRet 		:= .t.
	Local cContrato := CN9->CN9_NUMERO

	CN9->(DBOrderNickName("CN9"))
	
	If CN9->(DbSeek(xFilial("CN9") + cContrato))
		
		// Limpa o vinculo
		CN9->(Reclock("CN9",.F.))
			CN9->CN9_YCONTR := ""
		MsUnLock()
	
	End If
	
	SZG->(DbSetOrder(1))
	
	//ZG_FILIAL, ZG_CONTRA, ZG_REVISA, ZG_NUMERO, ZG_FORNECE, ZG_LOJFORN, R_E_C_N_O_, D_E_L_E_T_
	If SZG->(DbSeek(xFilial("SZG") + CN9->(CN9_NUMERO + CN9_REVISA)))
	
		While SZG->(!EOF()) .AND. SZG->(ZG_FILIAL + ZG_CONTRA + ZG_REVISA) == xFilial("SZG") + CN9->(CN9_NUMERO + CN9_REVISA)
			
			RecLock("SZG", .F.)
				dbDelete()
			MsUnLock()
				
			SZG->(DbSkip())
		EndDo
	End If
	
	//ZH_FILIAL, ZH_CONTRA, ZH_REVISA, ZH_NUMERO, ZH_FORNECE, ZH_LOJFORN, ZH_PRODUT, R_E_C_N_O_, D_E_L_E_T_
	SZH->(DbSetOrder(1))
	
	If SZH->(DbSeek(xFilial("SZH") + CN9->(CN9_NUMERO + CN9_REVISA)))
	
		While SZH->(!EOF()) .AND. SZH->(ZH_FILIAL + ZH_CONTRA + ZH_REVISA) == xFilial("SZH") + CN9->(CN9_NUMERO + CN9_REVISA)
			
			RecLock("SZH", .F.)
				dbDelete()
			MsUnLock()
			
			SZH->(DbSkip())
		EndDo
	
	End If
	
	SZI->(DbSetOrder(1))
	//ZI_FILIAL, ZI_CONTRA, ZI_REVISA, ZI_NUMERO, ZI_SEQUENC, ZI_DESCRI, R_E_C_N_O_, D_E_L_E_T_
	If SZI->(DbSeek(xFilial("SZI") + CN9->(CN9_NUMERO + CN9_REVISA)))
	
		While SZI->(!EOF()) .AND. SZI->(ZI_FILIAL + ZI_CONTRA + ZI_REVISA) == xFilial("SZI") + CN9->(CN9_NUMERO + CN9_REVISA)
			
			RecLock("SZI", .F.)
				dbDelete()
			MsUnLock()
			
			SZI->(DbSkip())
		EndDo
	End If
	
	RestArea(aAreaCN9)
Return lRet