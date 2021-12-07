#include 'protheus.ch'
#include 'parmtype.ch'

User function Gp265ValPE()

	Local lret  := .T.
	Local aArea := GetArea()
	
	If Inclui
		lret := VerifCPF()
		
		If lRet 
			lret := VerifCNPJ()
		End if
		
	End If
	
	If lret
		lret := U_SERFOL01()
	End IF
	
	RestArea(aArea)
	
return lret


Static Function VerifCPF()

	Local cAliasSRA := GetNextAlias()
	Local cRegistros:= ""
	Local cCIC		:= M->RA_CIC
	Local lSeek		:= .f.
	Local lRet		:= .t.
	
	If Empty(cCIC)
		Return .t.
	End if
	
	BeginSql Alias cAliasSRA
	
		SELECT 'FILIAL: ' + RA_FILIAL + ' - MAT: ' + RA_MAT + ' - ' + RA_NOME  as RA_NOME
	
		FROM %Table:SRA% SRA 
	
		WHERE SRA.RA_CIC = %Exp:cCIC%
		AND D_E_L_E_T_ =''
		
	EndSQL
	
	cRegistros := "Foram encontrados outras matriculas abaixo: " + CHR(10) + CHR(13)
	
	While(cAliasSRA)->(!EOF())
		
		lSeek:= .t. 
		
		cRegistros += (cAliasSRA)->RA_NOME + CHR(10) + CHR(13)
	
		(cAliasSRA)->(DbSkip())
	EndDo
	
	cRegistros += "Deseja continuar com o cadastro ? "
	
	If lSeek .and. !Isblind()
		If MSGYESNO( cRegistros, "Contribuinte Individual Cadastrado")
			lRet := .t. 
		Else
			lRet := .f.
		End If
	End If
	
	(cAliasSRA)->(DbCloseArea())
	
Return lRet


Static Function VerifCNPJ()

	Local cAliasSRA := GetNextAlias()
	Local cRegistros:= ""
	Local cCIC		:= M->RA_YCNPJ
	Local lSeek		:= .f.
	Local lRet 		:= .t.
	
	
	If Empty(cCIC)
		Return .t.
	End if
	
	BeginSql Alias cAliasSRA
	
		SELECT 'FILIAL: ' + RA_FILIAL + ' - MAT: ' + RA_MAT + ' - ' + RA_NOME  as RA_NOME
	
		FROM %Table:SRA% SRA 
	
		WHERE SRA.RA_YCNPJ = %Exp:cCIC%
		AND D_E_L_E_T_ =''
		
	EndSQL
	
	cRegistros := "Foram encontrados outras matriculas abaixo: " + CHR(10) + CHR(13)
	
	While(cAliasSRA)->(!EOF())
		
		lSeek:= .t. 
		
		cRegistros += (cAliasSRA)->RA_NOME + CHR(10) + CHR(13)
	
		(cAliasSRA)->(DbSkip())
	EndDo
	
	cRegistros += "Deseja continuar com o cadastro ? "
	
	If lSeek .and. !Isblind()
		If MSGYESNO( cRegistros, "Contribuinte Individual Cadastrado")
			lRet := .t. 
		Else
			lRet := .f.
		End If
	End If
	
	(cAliasSRA)->(DbCloseArea())
	
Return lRet