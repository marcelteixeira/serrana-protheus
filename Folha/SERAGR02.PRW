#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TOPCONN.CH"

Static Enter   := Chr(13)

//-------------------------------------------------------------------
/*/{Protheus.doc} SAMCDOC
Consulta Personalizada com Alias
@return Nil
@author Kenny Roger Martins
@since 05/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SERAGR02(cAlias, cFilter, cTitle, cExpSql, aResult, lCheck, aTotais, nPercent, aMarcados, lDelete)

	Local aAreaSX3   := SX3->(GetArea())

	Local lConfirma	 := .F.
	Local oBrowse	 := Nil
	Local aCoors     := FWGetDialogSize( oMainWnd )
	Local oDlgMain   := ""
	Local oFWLayer   := ""

	Local nX         := 0
	Local nY         := 0	
	Local xReturn    := {}
	Local nAltura    := 0
	Local nRodape    := 0

	Local oFont      := TFont():New('Courier new',,-10,.T.)
	Local cGet1      := 0
	Local lHasButton := .T.	
	Local cLabel     := ""
	Local cPicture   := ""
	Local cAliasTmp  := Nil
			
	Default cAlias     := ""  // Nome do Alias
	Default cFilter    := ""  // Filtro para ser aplicado no alias
	Default cTitle     := ""  // Título da consulta
	Default cExpSql    := ""  // Exrepssão Sql 
	Default aResult    := {}  // Capos que deverão retornar da consulta
	Default lCheck     := .F. // Ativa a coluna checkbox
	Default aTotais    := {}  // Array para carregar os totais no rodapé
	Default nPercent   := 60  // Percentual do tamanho da tela
	Default aMarcados  := {}  // Array utilizado para marcar registros da consulta
	Default lDelete    := .F. // Exclui os registros conforma array aMarcados

	//-----------------------------------------------------------------------
	// Para utilizar o checkbox é necessário informar a sentença Sql 
	// e os cammpos para retorno.
	//-----------------------------------------------------------------------
	If lCheck .And. Empty(aResult) .And. Empty(cExpSql)

		MsgStop("Para utilizar o checkbox é necessário informar a sentença Sql e os cammpos para retorno!!!")

		Return .F.

	EndIf

	//-----------------------------------------------------------------------
	// Cria tela da consulta padrão.
	//-----------------------------------------------------------------------
	DEFINE MSDIALOG oDlgMain FROM 000,000 TO aCoors[3] * (nPercent / 100), aCoors[4] * (nPercent / 100) PIXEL TITLE cTitle STYLE DS_MODALFRAME

	oFWLayer := FWLayer():New()

	oFWLayer:Init( oDlgMain, .F., .T. )

	If Len(aTotais) > 0

		nAltura := aCoors[3] * (nPercent / 100)
		nRodape := NoRound(12 * 1000 / nAltura, 0)

		oFWLayer:AddLine("LINE01", 100 - nRodape, .T.)
		oFWLayer:AddLine("LINE02", nRodape, .T.)

		oFWLayer:AddCollumn('BOX01', 100, .F., "LINE01")
		oFWLayer:AddCollumn('BOX02', 100, .F., "LINE02")

		oFWLayer:AddWindow( "BOX01", "PANEL01", "Consulta " + cTitle, 100, .F.,,, "LINE01" )
		oFWLayer:AddWindow( "BOX02", "PANEL02", "Totais" , 100, .F., .T.,, "LINE02" )

		oPanel01 := oFWLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )
		oPanel02 := oFWLayer:GetWinPanel( "BOX02", "PANEL02", "LINE02" )

  		oScroll := TScrollBox():New(oPanel02, 0, 0, 0, 0, .F., .T., .F.)
  		oScroll:Align := CONTROL_ALIGN_ALLCLIENT

		nColuna := 10

		For nX := 1 To Len(aTotais)

			oSay := TSay():New( 002, nColuna, &("{|| '" + aTotais[nX][3] + "' }"), oScroll,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

			&("cVar" + cValToChar(nX)) := 0

			bGet := "{ |U| If( PCount() == 0, (cVar" + cValToChar(nX) + "), (cVar" + cValToChar(nX) + ") := U ) }"

			cPicture := aTotais[nX][4]

			&("oGet" + cValToChar(nX)) := TGet():New( 009, nColuna, &(bGet), oScroll, 060, 010, cPicture,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,&('"cVar' + cValToChar(nX) + '"'),,,,lHasButton )

			nColuna += 80
		
		Next

	Else

		oFWLayer:AddLine("LINE01", 100, .F.)

		oFWLayer:AddCollumn('BOX01', 100, .F., "LINE01")

		oFWLayer:AddWindow( "BOX01", "PANEL01", "Consulta " + cTitle, 100, .F.,,, "LINE01" )

		oPanel01 := oFWLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )

	EndIf

	//-----------------------------------------------------------------------
	// Cria objeto MarkBrowse.
	//-----------------------------------------------------------------------
	oMrkBrowse := GRMarkBrowse():New()

	oMrkBrowse:SetOwner(oPanel01)
	oMrkBrowse:SetProfileID(PROCNAME(1))
	oMrkBrowse:SetDescription(cTitle)
	oMrkBrowse:SetFilterDefault(cFilter)
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:DisableReport()
	oMrkBrowse:DisableDetails()
	oMrkBrowse:SetIgnoreARotina(.T.)
	oMrkBrowse:AddButton("Confirma", { || lConfirma := .T., oDlgMain:End()},,,, .F., 2 )
	oMrkBrowse:AddButton("Cancelar", { || lConfirma := .F., oDlgMain:End()},,,, .F., 2 )
	
	If !Empty(cExpSql)

		oMrkBrowse:SetTableMain(cAlias)
		oMrkBrowse:SetMarkBrowse(lCheck) 
		oMrkBrowse:SetExpSql(cExpSql)
		oMrkBrowse:ExecuteSql()

		If lCheck

			oMrkBrowse:SetAllMark({|| FWMsgRun(, {|| AllMark(@oMrkBrowse, aTotais)}, "Processando", "Processando registros...")})
			oMrkBrowse:SetCustomMarkRec({|| FWMsgRun(, {|| SetMark(@oMrkBrowse, aTotais)}, "Processando", "Processando registros...")})

		EndIf

		oMrkBrowse:Activate()

		//-----------------------------------------------------------------------
		// Percorre array aMarcados para marcar os itens marcados anteriormente.
		//-----------------------------------------------------------------------
		cTable := oMrkBrowse:GetTableName()

		For nX := 1 To Len(aMarcados)

			aItem := aMarcados[nX]

			If lDelete
				cUpdate := " UPDATE " + cTable + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
			Else
				cUpdate := " UPDATE " + cTable + " SET CHECKTMP = '" + oMrkBrowse:Mark() + "' "
			EndIf

			For nY := 1 To Len(aItem)

				If nY == 1
					cUpdate += "  WHERE " + aItem[nY][1] + " = '" + aItem[nY][2] + "' "
				Else
					cUpdate += "    AND " + aItem[nY][1] + " = '" + aItem[nY][2] + "' "
				EndIf

			Next

			//-----------------------------------------------------------------------
			// Executo o comando para alimentar a tabela temporária.
			//-----------------------------------------------------------------------
			TcSQLExec(cUpdate)

		Next

		If !Empty(aMarcados)

			AtuTotais(oMrkBrowse, aTotais)				

		EndIf

		oMrkBrowse:Refresh()

		ACTIVATE MSDIALOG oDlgMain CENTERED

		If lConfirma

			If lCheck
				xReturn := GetMark(oMrkBrowse, aResult)
			ElseIf !Empty(aResult)
				cAliasTmp := oMrkBrowse:oBrowse:GetAlias() 
				xReturn := {}
				For nX := 1 To Len(aResult)
					aAdd(xReturn, {aResult[nX], (cAliasTmp)->(&(aResult[nX]))})
				Next
			EndIf

			xReturn := {.T., xReturn}

		Else

			If lCheck .Or. !Empty(aResult)
				xReturn := {}
			EndIf

			xReturn := {.F., xReturn}
						
		EndIf

	Else
		
		oMrkBrowse:SetAlias(cAlias)
		oMrkBrowse:Activate()

		ACTIVATE MSDIALOG oDlgMain CENTERED

		If lConfirma

			If !Empty(aResult)
				cAliasTmp := oMrkBrowse:oBrowse:GetAlias() 
				xReturn := {}
				For nX := 1 To Len(aResult)
					aAdd(xReturn, {aResult[nX], (cAliasTmp)->(&(aResult[nX]))})
				Next
			EndIf

			xReturn := {.T., xReturn}
			
		Else

			If !Empty(aResult)
				xReturn := {}			
			EndIf

			xReturn := {.F., xReturn}

		EndIf

	EndIf

	If oMrkBrowse:oTableTemp <> Nil
		oMrkBrowse:oTableTemp:Delete()
	EndIf

	oMrkBrowse:DeActivate()

	FreeObj(oMrkBrowse)

	RestArea(aAreaSX3)

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTotais
Atualiza campos dos totais.
@return Nil
@author Kenny Roger Martins
@since 10/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuTotais(oMrkBrowse, aTotais)

    Local aAreaTmp  := GetArea()
	Local cAliasTmp := oMrkBrowse:oBrowse:GetAlias() 
    Local cMarcado  := oMrkBrowse:Mark()	
    Local nX        := 0
	Local cSql      := ""
	Local qQuery    := ""

	//-----------------------------------------------------------
	// Zera variáveis utilizadas para os totais e recalcula.
	//-----------------------------------------------------------
	For nX := 1 To Len(aTotais)
		&("cVar" + cValToChar(nX)) := 0
	Next

	cSql := " SELECT "

	For nX := 1 To Len(aTotais)

		cSql += If( nX > 1, ", ", " ")

		cSql += AllTrim(aTotais[nX][2]) + "(" + aTotais[nX][1] + ") " + aTotais[nX][1]

	Next

	cSql += "  FROM " + oMrkBrowse:GetTableName()
	cSql += " WHERE CHECKTMP = '" + cMarcado + "'"

	TCQUERY cSql NEW ALIAS qQuery
        
	//-----------------------------------------------------------
	// Aplica refresh nos Gets.
	//-----------------------------------------------------------
	For nX := 1 To Len(aTotais)

		&("cVar" + cValToChar(nX)) := &("qQuery->" + aTotais[nX][1])

		&("oGet" + cValToChar(nX) + ":Refresh()")

	Next

	qQuery->(DbCloseArea())

    oMrkBrowse:oBrowse:Refresh()    

	RestArea(aAreaTmp)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AllMark
Marca o desmarca todos os registros do browse
@return Nil
@author Kenny Roger Martins
@since 10/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AllMark(oMrkBrowse, aTotais)

    Local aAreaTmp  := GetArea()
	Local cAliasTmp := oMrkBrowse:oBrowse:GetAlias() 
    Local cMarcado  := oMrkBrowse:Mark()	
    Local nX        := 0
	Local cFilter   := "CHECKTMP == '" + cMarcado + "'"

	//-----------------------------------------------------------
	// Aplica filtro no Alias conforme aplicado no oBrowse.
	//-----------------------------------------------------------
	DbSelectArea(cAliasTmp)

	U_GROAFILT(oMrkBrowse, cAliasTmp)
	
    &(cAliasTmp + "->(DbGoTop())")

	If &(cAliasTmp + "->CHECKTMP") == cMarcado
		cMarcado := Space(2)
	EndIf

    While &(cAliasTmp + "->(!Eof())")

        RecLock(cAliasTmp, .F.)
    	&(cAliasTmp + "->CHECKTMP") := cMarcado
        &(cAliasTmp + "->(MsUnLock())")

        &(cAliasTmp + "->(DbSkip())")

	EndDo
    
    SET FILTER TO
                    
    &(cAliasTmp + "->(DbGoTop())")

    oMrkBrowse:oBrowse:Refresh()    

	AtuTotais(oMrkBrowse, aTotais)

	RestArea(aAreaTmp)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMark
Marca o desmarca registro posicionado.
@return Nil
@author Kenny Roger Martins
@since 10/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetMark(oMrkBrowse, aTotais)

	Local cAliasTmp := oMrkBrowse:oBrowse:GetAlias() 
    Local cMarcado  := oMrkBrowse:Mark()	
    Local nX        := 0
	Local cFilter   := "CHECKTMP == '" + cMarcado + "'"

	If &(cAliasTmp + "->CHECKTMP") == cMarcado

        RecLock(cAliasTmp, .F.)
    	&(cAliasTmp + "->CHECKTMP") := Space(2)
        &(cAliasTmp + "->(MsUnLock())")

		For nX := 1 To Len(aTotais)
			If AllTrim(aTotais[nX][2]) == "COUNT"
				&("cVar" + cValToChar(nX)) -= 1
			ElseIf AllTrim(aTotais[nX][2]) == "SUM"
				&("cVar" + cValToChar(nX)) -= &(cAliasTmp + "->" + aTotais[nX][1])
			EndIf
		Next

	Else

        RecLock(cAliasTmp, .F.)
    	&(cAliasTmp + "->CHECKTMP") := cMarcado
        &(cAliasTmp + "->(MsUnLock())")

		For nX := 1 To Len(aTotais)
			If AllTrim(aTotais[nX][2]) == "COUNT"
				&("cVar" + cValToChar(nX)) += 1
			ElseIf AllTrim(aTotais[nX][2]) == "SUM"
				&("cVar" + cValToChar(nX)) += &(cAliasTmp + "->" + aTotais[nX][1])
			EndIf
		Next

	EndIf

	//-----------------------------------------------------------
	// Aplica refresh nos Gets.
	//-----------------------------------------------------------
	For nX := 1 To Len(aTotais)
		&("oGet" + cValToChar(nX) + ":Refresh()")
	Next

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMark
Retorna registros marcados no browse
@return Nil
@author Kenny Roger Martins
@since 10/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetMark(oMrkBrowse, aCampos)

    Local aAreaTmp  := GetArea()
	Local cAliasTmp := oMrkBrowse:oBrowse:GetAlias() 
    Local cMarcado  := oMrkBrowse:Mark()
	Local cFilter   := "CHECKTMP == '" + cMarcado + "'"
	Local aReturn   := {}
	Local aLinha    := {}
	Local nX        := 0

	DbSelectArea(cAliasTmp)
    
	SET FILTER TO &cFilter	

    &(cAliasTmp + "->(DbGoTop())")

    While &(cAliasTmp + "->(!Eof())")

		aLinha := {}

		For nX := 1 To Len(aCampos)

			aAdd(aLinha, {aCampos[nX], &(cAliasTmp + "->(" + aCampos[nX] + ")")} )
			
		Next

		aAdd(aReturn, aLinha)

	    &(cAliasTmp + "->(DbSkip())")

	EndDo
        
    SET FILTER TO
                    
    &(cAliasTmp + "->(DbGoTop())")

	RestArea(aAreaTmp)

Return aReturn
