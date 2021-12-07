#Include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} FA080TIT
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 10/09/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function FA080TIT()
	
	Local lRet  := .t.
	Local cTpBx := SuperGetMV("MV_TPCPCMV",.f.,"")
	
	// Verifica se abre a tela do CMV
	If Alltrim(CMOTBX) $ Alltrim(cTpBx)
		
		lRet := ViewCMV() 

	End If
	
	
return lRet


/*/{Protheus.doc} ViewCMV
Abre a tela para criar o CMV
@author mauricio.santos
@since 10/09/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewCMV()

	Local lRet	 := .T.
	Local nRet	 := 0
	Local oModel := Nil
	Local cObs   := ""

	cObs := "TITULO: " + SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) + chr(10)
	cObs += "FORNECEDOR: " + SE2->(E2_FORNECE+E2_LOJA+ '-' + E2_NOMFOR)

	oModel := FWLoadModel("SERGPE01")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oModel:SetValue('SZ1MASTER', 'Z1_HISTORI', cObs)
	oModel:SetValue('SZ1MASTER', 'Z1_VALOR', NVALPGTO)

	FWMsgRun(, {|| nRet := FWExecView("INCLUSAO DO CMV POR BAIXA DE TITULO NO CONTAS A PAGAR.",'SERGPE01', MODEL_OPERATION_INSERT, , { || .T. },,  ,,,,,oModel)}, "Processando", "Carregando CMV")

	// Cancelado pelo usuario
	If nRet == 1
		Help(NIL, NIL, "FA080TIT", NIL, "Cancelado pelo usuario" ,1, 0, NIL, NIL, NIL, NIL, NIL, {"A baixa sera desconsiderada"})
		lRet := .f.
	End if 

Return lRet
