#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010
//TODO Descri��o auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 18/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function FINA010()
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
				
			// Obriga o usuario informar os percentuais separados
			// E utilizado no programa SERGPE04
			If M->ED_YSEST + M->ED_YSENAT != M->ED_PERCSES
				cMsg  := "O percentual (ED_PERCSES ( "+ cvaltochar(M->ED_PERCSES)+ " %)) do SEST/SENAT nao foi rateio de forma correta para os campos (ED_YSEST (" +cvaltochar(M->ED_YSEST) + " %)) e ED_YSENAT(" + cvaltochar(M->ED_YSENAT)+ " %))"
				cSolu := "O Somatorio dos dois campos tem que bater com o percentual do ED_PERCSES."
				Help(NIL, NIL, "U_FINA010 - MVC ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
				Return .f.
			End IF			
		
			xRet := .T.
			
 
        ElseIf cIdPonto == "FORMPOS"
            cMsg := "Chamada na valida��o total do formul�rio." + CRLF
            cMsg += "ID " + cIdModel + CRLF
 
            If lIsGrid
                cMsg += "� um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            Else
                cMsg += "� um FORMFIELD" + CRLF
            EndIf
 
            xRet := .T.
 
        ElseIf cIdPonto == "FORMLINEPRE"
            If aParam[5] == "DELETE"
                cMsg := "Chamada na pr� valida��o da linha do formul�rio. " + CRLF
                cMsg += "Onde esta se tentando deletar a linha" + CRLF
                cMsg += "ID " + cIdModel + CRLF
                cMsg += "� um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
                xRet := .T. //ApMsgYesNo(cMsg + " Continua?")
            EndIf
 
        ElseIf cIdPonto == "FORMLINEPOS"
            cMsg := "Chamada na valida��o da linha do formul�rio." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            cMsg += "� um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
            cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            xRet := .T.
 
        ElseIf cIdPonto == "MODELCOMMITTTS"
            //ApMsgInfo("Chamada ap�s a grava��o total do modelo e dentro da transa��o.")
 
        ElseIf cIdPonto == "MODELCOMMITNTTS"
            //ApMsgInfo("Chamada ap�s a grava��o total do modelo e fora da transa��o.")
 
        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
            //ApMsgInfo("Chamada ap�s a grava��o da tabela do formul�rio.")
 
        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
            //ApMsgInfo("Chamada ap�s a grava��o da tabela do formul�rio.")
 
        ElseIf cIdPonto == "MODELCANCEL"
            cMsg := "Deseja realmente sair?"
            xRet := .T.
 
        ElseIf cIdPonto == "BUTTONBAR"
            xRet := nIL //{{"Salvar", "SALVAR", {||u_TSMT030()}}}
        EndIf
    EndIf
Return xRet