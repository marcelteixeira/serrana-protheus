#Include 'protheus.ch'
#Include 'parmtype.ch'

/*/{Protheus.doc} SERWF001
Envio de Workflow de Inativação do Cooperado após 180 dias sem movimentos
@author Leandro Maffioletti
@since 12/09/2019
/*/

Static Function SchedDef()
	Local aOrd		:= {}
	Local aParam	:= {}

	aParam := { "P",;               // Tipo R para relatorio P para processo
	"PARAMDEF",;		// Pergunte do relatorio, caso nao use passar ParamDef
	" ",;  				// Alias
	aOrd,;   			// Array de ordens
	" "}   				// Título (para Relatório)

Return aParam


User Function SERWF001()
	Local cDest			:= GetMv("MV_WF001DS",,"leandro.maffioletti@totvs.com.br")
	Local nDiasBlq		:= GetMv("MV_WF001BL",,180)
	Local cDir			:= Alltrim(GetMV("MV_WFDIR"))
	Local cArquivo		:= "WF001.htm"
	Local cAssunto		:= ""
	Local cUnidade		:= ""
	Local cAliasAUT		:= Nil
	Local lBloq			:= SuperGetMV("MV_YATVWF1",.f.,.f.)

	//cDest := "marcel.dti@serrana.coop.br"

	If Empty(cDest)
		Return
	EndIf

//Coloco a barra no final do parametro do diretorio
	If Substr(cDir,Len(cDir),1) != "\"
		cDir += "\"
	Endif

	cDtLimDesl	:= DTOS(dDatabase - nDiasBlq)
	cAliasAUT	:= GetNextAlias()

	BeginSQL Alias cAliasAUT
	
	%noparser%
	
	WITH AUTONOMOS as (
		SELECT RA_FILIAL, RA_MAT, RA_NOME, A2_FILIAL, A2_COD, A2_LOJA, A2_NOME,
			(SELECT MAX(E2_EMISSAO)
			FROM %Table:SE2% SE2
			WHERE
			  // CONSIDERA TODAS AS FILIAIS QUE cooperado trabalha
				E2_FORNECE = A2_COD
				AND E2_LOJA = A2_LOJA
				AND SE2.%NotDel%) E2_EMISSAO
		FROM %Table:SRA% SRA
		JOIN %Table:SA2% SA2 ON A2_FILIAL = LEFT(RA_FILIAL,2) AND A2_COD = RA_YFORN AND A2_MSBLQL <> '1' AND SA2.%NotDel%
		WHERE RA_FILIAL = '1001' 
		AND RA_CATFUNC = 'A'
		AND RA_SITFOLH NOT IN ('D','A')
		AND RA_ADMISSA < %Exp:cDtLimDesl%	

	)
	SELECT RA_FILIAL, RA_MAT, RA_NOME, A2_FILIAL, A2_COD, A2_LOJA, A2_NOME,E2_EMISSAO
	FROM AUTONOMOS
	WHERE E2_EMISSAO = ' ' OR E2_EMISSAO < %Exp:cDtLimDesl%
	
	EndSQL

	While (cAliasAUT)->(!EOF())

		SA2->(dbSeek((cAliasAUT)->(A2_FILIAL+A2_COD)))
		cNomeFor	:= '['+SA2->A2_COD+'] ' + ALLTRIM(SA2->A2_NOME)
		cAssunto	:= dtoc(MsDate())+" - Bloqueio Automatico de Cooperado por Inatividade - " + ALLTRIM(SA2->A2_NOME)
		cUnidade	:= Capital(AllTrim(SM0->M0_NOME))+"/"+Capital(AllTrim(SM0->M0_FILIAL))
		cUltMov		:= DTOC(STOD((cAliasAUT)->E2_EMISSAO))
		cEndFor		:= ALLTRIM(SA2->A2_BAIRRO) + ", " + ALLTRIM(SA2->A2_MUN) + " (" + SA2->A2_EST + ") - CEP: " + Transform(SA2->A2_CEP,"@R 99.999-999")
		cTextoMsg	:= "O Cooperado acima relacionado foi bloqueado automaticamente do sistema devido a inatividade por mais de " + cValToChar(nDiasBlq) + " dias"

		//Verifico se existe o arquivo de workflow
		If !File(cDir+cArquivo)
			Msgstop(">>> Nao foi encontrado o arquivo modelo de Workflow: "+cDir+cArquivo) //">>> Nao foi encontrado o arquivo "
			Return .F.
		EndIf

		//Inicio do processo
		oProcess := TWFProcess():New("WF001","Bloqueio de Cooperado por Inatividade")

		oProcess:NewTask("100001",cDir+cArquivo)
		oProcess:cSubject	:= cAssunto + "..."
		oProcess:cTo		:= cDest
		oProcess:UserSiga	:= "000000"

		oProcess:oHtml:ValByName("cUnid"		,cUnidade) //"Empresa"
		oProcess:oHtml:ValByName("cNomeFor"		,cNomeFor)
		oProcess:oHtml:ValByName("cUltMov"		,cUltMov)
		oProcess:oHtml:ValByName("cEndFor"		,cEndFor)
		oProcess:oHtml:ValByName("CDADOSADIC"	,cTextoMsg)

		oProcess:Start()	// oProcess:Start("\Workflow\copias")
		oProcess:Finish()

		// Chamada a rotina de bloqueio desativada temporariamente até entrada em produção
		If lBloq
			BlqVeic((cAliasAUT)->A2_FILIAL,(cAliasAUT)->A2_COD)
		End IF
		(cAliasAUT)->(dbSkip())

	EndDo

	If Select(cAliasAUT) > 0
		(cAliasAUT)->(dbCloseArea())
	EndIf

Return


/*/{Protheus.doc} BlqVeic
// Bloqueio dos Veiculos do Cooperado Inativado
@author Leandro Maffioletti
@since 13/09/2019
/*/
Static Function BlqVeic(cFilForn,cCodFor)
	Local cAliasVEI	:= GetNextAlias()
	Local cAliasSRA	:= Nil


	BeginSql Alias cAliasVEI
	SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NOME, DA3_COD, DA3_DESC, DA4_COD, DA4_NOME
	FROM %Table:SA2% SA2
	LEFT JOIN %Table:DA4% DA4 ON DA4_FILIAL = A2_FILIAL AND DA4_CGC = A2_CGC AND DA4.%NotDel%
	LEFT JOIN %Table:DA3% DA3 ON DA3_FILIAL = DA4_FILIAL AND DA3_MOTORI = DA4_COD AND DA3.%NotDel%
	WHERE A2_FILIAL = %Exp:cFilForn%
		AND A2_COD = %Exp:cCodFor%
		AND SA2.%NotDel%	
	EndSQL

	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))

	dbSelectArea("DA3")
	DA3->(dbSetOrder(1))

	dbSelectArea("DA4")
	DA4->(dbSetOrder(1))

	SRA->(dbSetOrder(5))
	//RA_FILIAL+RA_CIC

	While (cAliasVEI)->(!EOF())

		If SA2->(dbSeek((cAliasVEI)->(A2_FILIAL+A2_COD))) .AND. SA2->A2_MSBLQL <> '1'
			recLock("SA2",.F.)
			SA2->A2_MSBLQL	:= '1'
			SA2->(MsUnlock())

			// Desativa o funcionario, Serrana cadastra todos os funcionarios na filial 1001
			IF SRA->(DbSeek('1001' + SA2->A2_CGC)) .AND. SRA->RA_MSBLQL <> '1'
				RecLock("SRA",.F.)
				SRA->RA_MSBLQL	:= '1'
				SRA->RA_YSITUA	:= '2'
				SRA->(MsUnlock())

			elseif !(Empty(SA2->A2_CGC))
				//Verifica o CNPJ, existe contribuinte que não possui CPF e sim CNPJ
				cAliasSRA	:= GetNextAlias()

				BeginSql Alias cAliasSRA

					SELECT R_E_C_N_O_ as recno,* 
						FROM %Table:SRA% SRA
					WHERE 
						SRA.RA_MSBLQL <> '1' 
						AND SRA.D_E_L_E_T_='' 
						AND SRA.RA_YCNPJ<>'' 
						AND SRA.RA_YCNPJ = %Exp:SA2->A2_CGC%
						AND SRA.%NotDel%
						
				EndSQL

				While (cAliasSRA)->(!EOF())
					SRA->(DbGoTo((cAliasSRA)->recno))
					IF  SRA->RA_YCNPJ == SA2->A2_CGC
						RecLock("SRA",.F.)
						SRA->RA_MSBLQL	:= '1'
						SRA->RA_YSITUA	:= '2'
						SRA->(MsUnlock())
					EndIF
					(cAliasSRA)->(dbSkip())
				EndDo

				If Select(cAliasSRA) > 0
					(cAliasSRA)->(dbCloseArea())
				EndIf

			EndIf

		EndIf

		If DA3->(dbSeek((cAliasVEI)->(A2_FILIAL+DA3_COD))) .AND. DA3->DA3_MSBLQL <> '1'
			recLock("DA3",.F.)
			DA3->DA3_MSBLQL	:= '1'
			DA3->(MsUnlock())
		EndIf

		If DA4->(dbSeek((cAliasVEI)->(A2_FILIAL+DA4_COD))) .AND. DA4->DA4_MSBLQL <> '1'
			recLock("DA4",.F.)
			DA4->DA4_MSBLQL	:= '1'
			DA4->(MsUnlock())
		EndIf

		(cAliasVEI)->(dbSkip())
	EndDo

	If Select(cAliasVEI) > 0
		(cAliasVEI)->(dbCloseArea())
	EndIf

Return
