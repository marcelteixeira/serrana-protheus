#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GRMARKBROWSE
Classe herdada do FWMARKBROWSE
@return Nil
@author Kenny Roger Martins
@since 12/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS GRMARKBROWSE FROM FWMARKBROWSE

	DATA cTableMain
	DATA lMarkBrowse
	DATA cTableName
	DATA cExpSql
	DATA oTableTemp
	DATA cCamposTemp

	METHOD New() CONSTRUCTOR
	METHOD SetTableMain()
	METHOD SetMarkBrowse()
	METHOD SetExpSql()
	METHOD GetTableName()
	METHOD ExecuteSql()
	METHOD ReloadSql()

END CLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor.
/*/
//-------------------------------------------------------------------
METHOD New() CLASS GRMARKBROWSE

	_Super:New()

	Self:cTableMain  := ""
	Self:lMarkBrowse := .F.
	Self:cTableName  := ""
	Self:cExpSql     := ""
	Self:cCamposTemp := ""
	Self:oTableTemp  := Nil

RETURN ( Self )


//-------------------------------------------------------------------
/*/{Protheus.doc} SetTableMain()
Seta tabela principal.
/*/
//-------------------------------------------------------------------
METHOD SetTableMain(cTableMain) CLASS GRMARKBROWSE

	Self:cTableMain := cTableMain

RETURN ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkBrowse()
Habilita coluna de marcação.
/*/
//-------------------------------------------------------------------
METHOD SetMarkBrowse(lMarkBrowse) CLASS GRMARKBROWSE

	Self:lMarkBrowse := lMarkBrowse

RETURN ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} SetExpSql()
Seta expressão SQL.
/*/
//-------------------------------------------------------------------
METHOD SetExpSql(cExpSql) CLASS GRMARKBROWSE

	Self:cExpSql := cExpSql

RETURN ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} GetTableName()
Retorna nome da tabela temporária criada no banco de dados.
/*/
//-------------------------------------------------------------------
METHOD GetTableName() CLASS GRMARKBROWSE

RETURN ( Self:cTableName )


//-------------------------------------------------------------------
/*/{Protheus.doc} ExecuteSql()
Executa expressão SQL.
/*/
//-------------------------------------------------------------------
METHOD ExecuteSql() CLASS GRMARKBROWSE

	Local cExpTmp    := ""
	Local qQueryTmp  := Nil
	Local aStructBc  := {}
	Local aStruct    := {}
	Local cTable     := ""
	Local cTableTemp := ""
	Local aCampos    := {}
	Local aCpoArr    := {}
	Local cCampos    := ""
	Local nX         := 0
	Local nY         := 0
	Local aIndices   := {}
	Local lInclui    := .T.
	Local cTmpIdx    := ""
	Local aChave     := {}
	Local aSeek      := {}
	Local nSeqIdx    := 0
	Local cAliasTmp  := ""
	Local cAliasPeq  := ""
	Local aColumns   := {}
	Local aCpoFil    := {}
	Local cInsert    := ""

	//-----------------------------------------------------------------------
	// Faz um select no banco para retornar a estrutura de campos.
	//-----------------------------------------------------------------------
	cExpTmp := StrTran( Self:cExpSql , "SELECT" , "SELECT TOP 0 " )

	TCQUERY cExpTmp NEW ALIAS qQueryTmp

	aStructBc := qQueryTmp->(DbStruct())

	If Self:lMarkBrowse
		aAdd(aStruct, {'CHECKTMP', 'C', 2, 0})
	EndIf

	For nX := 1 To Len(aStructBc)
		aAdd(aStruct, aStructBc[nX])
	Next

	If !Empty(Self:cTableMain)
		aAdd(aStruct, {'RECNOTMP', 'N', 10, 0})
	EndIf

	qQueryTmp->(DbCloseArea())

	//-----------------------------------------------------------------------
	// Carrega tabela temporária.
	//-----------------------------------------------------------------------
	cTableTemp := GetNextAlias()

	Self:oTableTemp := FWTemporaryTable():New( cTableTemp )
	Self:oTableTemp:SetFields(aStruct)

	//-----------------------------------------------------------------------
	// Carrega os índices da tabela principal.
	//-----------------------------------------------------------------------
	If !Empty( Self:cTableMain )

		SIX->(DbSeek( Self:cTableMain ))

		While SIX->(!Eof()) .And. SIX->INDICE == Self:cTableMain

			aCampos := StrToKarr(Alltrim(SIX->CHAVE), "+")
			aCpoArr := {}

			For nX := 1 To Len(aCampos)

				SX3->(DbSetOrder(2))
				SX3->(DbSeek(aCampos[nX]))

				aAdd( aCpoArr, { AllTrim(SX3->X3_CAMPO), AllTrim(SX3->X3_TIPO), SX3->X3_TAMANHO, SX3->X3_DECIMAL, AllTrim(SX3->X3_TITULO), AllTrim(SX3->X3_PICTURE)})

			Next

			aAdd( aIndices, { "Filial+" + AllTrim(SIX->DESCRICAO), aCpoArr, Alltrim(SIX->CHAVE)})

			SIX->(DbSkip())

		EndDo

	EndIf

	//-----------------------------------------------------------------------
	// Carrega string de campos para montar o Sql.
	//-----------------------------------------------------------------------
	For nX := 1 to Len(aStruct)

		If nX > 1
			cCampos += ","
		EndIf

		cCampos += aStruct[nX][1]

		aAdd(aCampos, aStruct[nX][1])

		//-----------------------------------------------------------------------
		// Monta estrutura de campos para ser apresentando no filtro.
		//-----------------------------------------------------------------------
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(aCampos[nX]))
			aAdd(aCpoFil, {SX3->X3_CAMPO, SX3->X3_TITULO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
		EndIf

	Next

	//-----------------------------------------------------------------------
	// Adiciona o índices da tabela temporária.
	//-----------------------------------------------------------------------
	For nX := 1 To Len(aIndices)

		lInclui := .T.

		cTmpIdx := StrZero(nX, 2)
		aChave	:= StrToKarr(Alltrim(aIndices[nX,3]), "+")

		For nY := 1 To Len(aChave)
			If !(AllTrim(aChave[nY]) $ cCampos)
				lInclui := .F.
			EndIf
		Next

		If lInclui
			Aadd(aSeek, {aIndices[nX][1], aIndices[nX][2]})
			Self:oTableTemp:AddIndex(cTmpIdx, aChave)
		EndIf

		nSeqIdx := nX

	Next

	//-----------------------------------------------------------------------
	// Adiciono demais campos como índice.
	//-----------------------------------------------------------------------
	aCpoArr := {}

	For nX := 1 To Len(aCampos)

		If aScan(aIndices, {|x| AllTrim(aCampos[nX]) $ AllTrim(x[3])}) <= 0

			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aCampos[nX]))

				If SX3->X3_TIPO == "C"

					cTmpIdx := StrZero(nSeqIdx + nX, 2)
					aChave	:= {AllTrim(SX3->X3_CAMPO)}

					aAdd(aCpoArr, {AllTrim(SX3->X3_CAMPO), AllTrim(SX3->X3_TIPO), SX3->X3_TAMANHO, SX3->X3_DECIMAL, AllTrim(SX3->X3_TITULO), AllTrim(SX3->X3_PICTURE)})

					aAdd( aSeek, { AllTrim(SX3->X3_TITULO), aCpoArr})
					Self:oTableTemp:AddIndex(cTmpIdx, aChave)

				EndIf
			Else

                //Alterando estrutura para tela de Gestão de Ocorrencia
				If aCampos[nX] == "RECNODT6" .AND. FunName() == "BRSA001"

					cTmpIdx := StrZero(nSeqIdx + nX, 2)
					aChave	:= {"RECNODT6"}

					//aAdd(aCpoArr, {"RECNODT6", "N", 15, 8, "Recno DT6", ""})

					//aAdd( aSeek, { AllTrim(SX3->X3_TITULO), aCpoArr})
					Self:oTableTemp:AddIndex(cTmpIdx, aChave)

				EndIf

			EndIf

		EndIf

	Next

	//-----------------------------------------------------------------------
	// Criação da tabela temporária no BD.
	//-----------------------------------------------------------------------
	Self:oTableTemp:Create()

	//-----------------------------------------------------------------------
	// Obtenho o nome "verdadeiro" da tabela no BD (criada como temporária)
	//-----------------------------------------------------------------------
	cTable := Self:oTableTemp:GetRealName()

	Self:cTableName  := cTable
	Self:cCamposTemp := cCampos

	//-----------------------------------------------------------------------
	// Preparo o comando para alimentar a tabela temporária.
	//-----------------------------------------------------------------------
	cInsert := " INSERT INTO " + cTable + " (" + cCampos + ") "

	Self:cExpSql := StrTran(Self:cExpSql, "SELECT", "SELECT " + If(Self:lMarkBrowse, "'  ' CHECKTMP, ", ""))

	If !Empty(Self:cTableMain)
		Self:cExpSql := StrTran(Self:cExpSql, "FROM", ", " + Self:cTableMain + ".R_E_C_N_O_ RECNOTMP FROM")
	EndIf

	//-----------------------------------------------------------------------
	// Executo o comando para alimentar a tabela temporária.
	//-----------------------------------------------------------------------
	nStatus := TcSQLExec(cInsert + Self:cExpSql)

	If nStatus < 0
		ConOut("TCSQLError() " + TCSQLError())
		MsgStop("Ocorreu um problema na excutação da rotina, se o problema persistir favor entrar em contato com o Administrador do sistema!")
	EndIf

	//-----------------------------------------------------------------------
	// Retorna Alias da tabela temporária.
	//-----------------------------------------------------------------------
	cAliasTmp := Self:oTableTemp:GetAlias()

	//-----------------------------------------------------------------------
	// Atribui formatação no campos do Browse.
	//-----------------------------------------------------------------------
	For nX := 1 To Len(aStruct)

		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(aStruct[nX][1]))
			If SX3->X3_TIPO $ "DNL"
				TCSetField( cAliasTmp, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL )
			EndIf
		EndIf

	Next

	//-----------------------------------------------------------------------
	// Monta estrutura de colunas apresentadas no browse.
	//-----------------------------------------------------------------------
	For nX := 1 To Len(aStruct)

		If AllTrim(aStruct[nX][1]) $ cCampos .And. AllTrim(aStruct[nX][1]) <> "RECNOTMP" .And. AllTrim(aStruct[nX][1]) <> "CHECKTMP"

			cAliasPeq := SubStr( aStruct[nX][1], 1, At("_", aStruct[nX][1]) - 1)
			cAliasPeq := If(Len(cAliasPeq) == 2, "S" + cAliasPeq, cAliasPeq)

			AAdd(aColumns, FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nX][1]))
			aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])

			SX3->(DbSetOrder(2))

			If SX3->(DbSeek(aStruct[nX][1]))
				aColumns[Len(aColumns)]:SetPicture( PesqPict( cAliasPeq, aStruct[nX][1]))
			Else
				aColumns[Len(aColumns)]:SetPicture( "@!" )
			EndIf

		EndIf

	Next

	Self:SetAlias(cAliasTmp)
	Self:SetColumns(aColumns)
	Self:SetSeek(.T., aSeek)

	If Self:lMarkBrowse

		Self:SetFieldMark("CHECKTMP")

	EndIf

	Self:oBrowse:SetUseFilter(.T.)
	Self:oBrowse:SetDBFFilter()
	Self:oBrowse:SetFieldFilter(aCpoFil)

RETURN ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} ReloadSql()
Executa expressão SQL.
/*/
//-------------------------------------------------------------------
METHOD ReloadSql() CLASS GRMARKBROWSE

	Local cInsert    := ""
	Local cDelete    := ""
	Local nStatus    := 0

	//-----------------------------------------------------------------------
	// Exclui os registros da tabela temporária.
	//-----------------------------------------------------------------------
	nStatus := TcSQLExec( " DELETE FROM " + Self:cTableName )

	If nStatus < 0
		ConOut("TCSQLError() " + TCSQLError())
		MsgStop("Ocorreu um problema na excutação da rotina, se o problema persistir favor entrar em contato com o Administrador do sistema!")
	EndIf

	//-----------------------------------------------------------------------
	// Preparo o comando para alimentar a tabela temporária.
	//-----------------------------------------------------------------------
	cInsert := " INSERT INTO " + Self:cTableName + " (" + Self:cCamposTemp + ") "

	If Empty(Self:cTableMain)
		Self:cExpSql := StrTran(Self:cExpSql, "FROM", If(Self:lMarkBrowse, ", '  ' CHECKTMP", "") + " FROM")
	Else
		Self:cExpSql := StrTran(Self:cExpSql, "FROM", If(Self:lMarkBrowse, ", '  ' CHECKTMP", "") + ", " + Self:cTableMain + ".R_E_C_N_O_ RECNOTMP FROM")
	EndIf

	//-----------------------------------------------------------------------
	// Executo o comando para alimentar a tabela temporária.
	//-----------------------------------------------------------------------
	nStatus := TcSQLExec(cInsert + Self:cExpSql)

	If nStatus < 0
		ConOut("TCSQLError() " + TCSQLError())
		MsgStop("Ocorreu um problema na excutação da rotina, se o problema persistir favor entrar em contato com o Administrador do sistema!")
	EndIf

	Self:oBrowse:Refresh()

RETURN ( Nil )
