#Include 'Protheus.ch'  
#Include 'TopConn.ch'
#Include 'RwMake.ch'
#Include 'TbiConn.ch'
#INCLUDE "FILEIO.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "SCHEDCOMCOL.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �SchedComCol�Autor  �SchedComCol         � Data �  08/06/12   ���
��������������������������������������������������������������������������͹��
���Descricao � Funcao para ser schedulada e processar a importacao dos     ���
���          � arquivos TOTVS Colaboracao.                                 ���
��������������������������������������������������������������������������͹��
���Parametros� aParam: array de parametros recebidos do schedule Protheus. ���
��������������������������������������������������������������������������͹��
���Uso       � SIGACOM                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function SchedComCol(aParam)
Local aProc		:= {}
Local aErros	:= {}
Local aXMLs		:= {}
Local aErroERP	:= {}
Local aEnvErros	:= {}
Local aDocs		:= &(GetNewPar("MV_COLEDI",'{}')) //Recebimento- NF-e, NFS-e, CT-e, AV-e, CTEOS
Local nZ		:= 1
Local nW		:= 1
Local nMsgCol	:= 0
Local nPosMsg	:= 0
Local nCount	:= 0
Local nPos		:= 0
Local nPosErp	:= 0
Local lOk		:= .F.
Local lChanFil	:= .F.
Local cXml		:= ""
Local oColab	:= NIL
Local cEventID	:= "" 
Local cMensagem	:= ""
Local aMsgErr	:= Iif(FindFunction("COLERPERR"),COLERPERR(),{})

If Empty(aDocs)
	aDocs := {"109","214","273","319"}
Endif

//Atualiza dDataBase
IF dDataBase <> DATE()
	dDataBase := DATE()
ENDIF

//Atualiza Empresa/Filial em arquivos na CKO com flag = 0
SCHEDATUEMP()

nMsgCol := SuperGetMV("MV_MSGCOL",.F.,10) 	// Quantidade maxima de mensagens por e-mail

oColab 			:= ColaboracaoDocumentos():New() 
oColab:cQueue 	:= aDocs[1]
oColab:aQueue 	:= aDocs
oColab:cModelo 	:= ""
oColab:cTipoMov := '2'
oColab:cFlag 	:= '0'
oColab:cEmpProc := cEmpAnt
oColab:cFilProc := cFilAnt

//-- Busca na tabela CKO os documentos dispon�veis para a filial
oColab:buscaDocumentosFilial()

If !Empty(oColab:aNomeArq)
	aXMLs 	:= oColab:aNomeArq
	nFiles	:= Len(aXMLs)

	While !Empty(nFiles)
		nMsgCol := If(nFiles < nMsgCol, nFiles, nMsgCol)
		
		//-- Processa os XML encontrados para a filial		
		For nZ := 1 To nMsgCol
			aErroERP 	:= {}
			aErros		:= {}
			
			oColab:cNomeArq := aXMLs[nCount+nZ][1]
			oColab:cFlag := '0'
			oColab:Consultar()
			cXml := oColab:cXmlRet
			oColab:cNomeArq := aXMLs[nCount+nZ][1]
			SCHEDATUCKO(oColab:cNomeArq,oColab:cXmlRet)
			lOk := ImportCol(aXMLs[nCount+nZ][1],.T.,@aProc,@aErros,cXml,@aErroERP)
			If lOk
				//-- Marca XML como 1-Processado e limpa os dados de erros
				oColab:cFlag := '1'
				If !Empty(oColab:cCodErrErp)
					oColab:cCodErrErp := ""
					oColab:gravaErroErp()
				Endif
			Else
				If Len(aErroErp) > 0
					If Len(aErroErp[1]) > 0
						If AllTrim(aErroErp[1][2]) == "COM002"	// Se o XML pertencer a outra filial deve deixar o Flag = 0 para deixar o schedule processar na filial correta
							oColab:cFlag := '0'
							lChanFil := .T.
						EndIf
					EndIf
				EndIf

				If !Empty(aErros) .And. !lChanFil
					For nW:=1 to Len(aErros)
						Aadd(aEnvErros,aErros[nW])
					Next nW
					//-- Marca XML com erro de processamento
					oColab:cFlag := '2'
				ElseIf !lChanFil
					//-- Marca XML como n�o processado e limpa os dados de erros
					oColab:cFlag := '0'
					oColab:cCodErrErp := ""
					oColab:gravaErroErp()
				Endif
				
				If !Empty(aErroERP)
					//-- Grava erro de Processamento
					If !(aErroERP[1][2] == "COM002" .and. !EMPTY(CKO->CKO_FILPRO))
						oColab:cCodErrErp := aErroERP[1][2]
						
						nPosErp := aScan(aMsgErr,{|x| AllTrim(x) == aErroERP[1][2]})
						
						If nPosErp > 0
							nPos := aScan(aErros,{|x| aMsgErr[nPosErp] == SubSTr(AllTrim(x[2]),1,6)})
							If nPos > 0
								oColab:cMsgErr024 := aErros[nPos,2]
							Endif
						Endif 
						oColab:gravaErroErp()
					Endif
				Endif
			Endif
			//-- Efetiva marca��o
			oColab:FlegaDocumento()
			nPosMsg++
			lChanFil := .F.
		Next nZ
		
		//-- Dispara M-Messenger para erros (evento 052)
		If !Empty(aEnvErros)
			dbSelectarea("SXI")
			dbsetorder(2)
			cEventID := "052" // Evento de Inconsistencia da importa��o NF-e/CT-e [TOTVS COLABORA��O]
		
			If MsSeek ('002' + '001' + cEventID)
				cMensagem := MSGTOTCOL(cEventID,aEnvErros)
				EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0001,cMensagem,.T./*lPublic*/) //"Evento de Inconsistencia da importa��o NF-e/CT-e [TOTVS COLABORA��O]"
			Else
				MEnviaMail("052",aEnvErros)
			Endif
			aEnvErros	:= {}
		EndIf
		
		//-- Dispara M-Messenger para docs disponiveis (evento 053)
		If !Empty(aProc)
			dbSelectarea("SXI")
			dbsetorder(2)
			cEventID := "053" // Evento de Inconsistencia da importa��o NF-e/CT-e [TOTVS COLABORA��O]
		
			If MsSeek ('002' + '001' + cEventID)
				cMensagem := MSGTOTCOL(cEventID,aProc)
				EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0002,cMensagem,.T./*lPublic*/) //"Evento de documentos NF-e/CT-e procesados [TOTVS COLABORA��O]"
			Else
				MEnviaMail("053",aProc)
			Endif
			aProc	:= {}
		EndIf
		nCount  += nPosMsg
		nPosMsg := 0
		nFiles  -= nMsgCol
	Enddo
Endif

Return .T.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � Scheddef  �Autor  �Rodrigo M Pontes    � Data �  05/04/16   ���
��������������������������������������������������������������������������͹��
���Descricao � Tratativa da chamada via scheddef para controle de transa��o���
���          � via framework                                               ���
��������������������������������������������������������������������������͹��
���Uso       � SIGACOM                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;			//Alias
            ,;			//Array de ordens
            }				//Titulo

Return aParam

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MSGTOTCOL �Autor  �Rodrigo M Pontes    � Data �  05/04/16   ���
��������������������������������������������������������������������������͹��
���Descricao � Tratatica para enviar mensagem via event viewer dos         ���
���          � documentos totvs colabora��o                                ���
��������������������������������������������������������������������������͹��
���Uso       � SIGACOM                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function MSGTOTCOL(cEventID,aDados)

Local cRetMsg		:= ""
Local cExecBlock	:= ""
Local cBkpMsg		:= ""
Local nI			:= 0
Local lEditMsg	:= ExistBlock("EVCOL"+Substr(cEventID,1,3))

If cEventId == "052" //Inconsistencias
	cRetMsg := '<html>'
	cRetMsg += '	<body>'
	cRetMsg += '		<h3>'
	cRetMsg += '			<strong style="font-weight: bold; color: gray;">'
	cRetMsg += STR0003 //"Aviso de inconsist�ncias da importa��o NF-e/CT-e [TOTVS Colabora��o]"
	cRetMsg += '			</strong>'
	cRetMsg += '		</h3>'
	cRetMsg += '		<p>'
	cRetMsg += STR0004 + FWEmpName(FWCodEmp()) //"Empresa: " 
	cRetMsg += '			<br>'
	cRetMsg += STR0005 + FWFilialName() //"Filial: "
	cRetMsg += '			<br>'
	cRetMsg += STR0006 + DtoC(Date()) //"Data: "
	cRetMsg += '			<br>'
	cRetMsg += STR0007 + Time() //"Hora: "
	cRetMsg += '		</p>'
	cRetMsg += '		<hr/>'
	cRetMsg += '		<p>'
	cRetMsg += STR0008 //"Um ou mais arquivos de NF-e recebidos via TOTVS Colabora��o apresentaram inconsist�ncias durante o processamento."
	cRetMsg += STR0009 //"Tais arquivos foram marcados como inconsistentes e deixar�o de ser processados."
	cRetMsg += '			<br>'
	
	If IsInCallStack("MATA140I")
		cRetMsg += STR0010 //"Corrija as ocorr�ncias listadas abaixo e providencie o reprocessamento destes arquivos atrav�s da rotina Pr�-nota, op��o Entrada Nf-e."
	Else
		cRetMsg += STR0011 //"Corrija as ocorr�ncias listadas abaixo e providencie o reprocessamento destes arquivos no monitor TOTVS Colabora��o."
	Endif
	
	cRetMsg += '			<br><br>'
	cRetMsg += STR0012 //"* Estes arquivos n�o ser�o reprocessados automaticamente."  
	cRetMsg += '		</p>'
	cRetMsg += '		<table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="1">'
	cRetMsg += '			<thead>'
	cRetMsg += '				<tr>'
	cRetMsg += '					<th scope="col" style="background-color: gray; font-weight: bold; color: white" >'
	cRetMsg += STR0013 //"Arquivo"
	cRetMsg += '					</th>'
	cRetMsg += '					<th scope="col" style="background-color: gray; font-weight: bold; color: white" >'
	cRetMsg += STR0014 //"Ocorrencia"
	cRetMsg += '					</th>'
	cRetMsg += '					<th scope="col" style="background-color: gray; font-weight: bold; color: white" >'
	cRetMsg += STR0015 //"Solu��o"
	cRetMsg += '					</th>'
	cRetMsg += '				</tr>'
	cRetMsg += '			</thead>'
	cRetMsg += '			<tbody>'
	
	For nI := 1 To Len(aDados)
		cRetMsg += '				<tr>'
		cRetMsg += '					<td valign="center">'
		cRetMsg += 						aDados[nI,1]
		cRetMsg += '					</td>
		cRetMsg += '					<td valign="center">'
		cRetMsg += 						aDados[nI,2]
		cRetMsg += '					</td>
		cRetMsg += '					<td valign="center">'
		cRetMsg += 						aDados[nI,3]
		cRetMsg += '					</td>
		cRetMsg += '				</tr>'
	Next nI
	
	cRetMsg += '			</tbody>'
	cRetMsg += '		</table>'
	cRetMsg += '	</body>'
	cRetMsg += '</html>'

Elseif cEventId == "053" //Documento Processados
	cRetMsg := '<html>'
	cRetMsg += '	<body>'
	cRetMsg += '		<h3>'
	cRetMsg += '			<strong style="font-weight: bold; color: gray;">'
	cRetMsg += STR0016 //"NF-e dispon�veis [TOTVS Colabora��o]"
	cRetMsg += '			</strong>'
	cRetMsg += '		</h3>'
	cRetMsg += '		<p>'
	cRetMsg += STR0004 + FWEmpName(FWCodEmp()) //"Empresa: " 
	cRetMsg += '			<br>'
	cRetMsg += STR0005 + FWFilialName() //"Filial: "
	cRetMsg += '			<br>'
	cRetMsg += STR0006 + DtoC(Date()) //"Data: "
	cRetMsg += '			<br>'
	cRetMsg += STR0007 + Time() //"Hora: "
	cRetMsg += '		</p>'
	cRetMsg += '		<hr/>'
	cRetMsg += '		<p>'
	
	If IsInCallStack("MATA140I")
		cRetMsg += STR0017 //"Um ou mais arquivos de NF-e foram recebidos via TOTVS Colabora��o e est�o dispon�veis para gera��o de documento fiscal atrav�s da rotina Pr�-Nota op��o Entrada NF-e."
	Else
		cRetMsg += STR0018 //"Um ou mais arquivos de NF-e foram recebidos via TOTVS Colabora��o e est�o dispon�veis para gera��o de documento fiscal no monitor TOTVS Colabora��o."
	Endif
	
	cRetMsg += '			<br><br>'
	cRetMsg += STR0012 //"* Estes arquivos n�o ser�o reprocessados automaticamente."
	cRetMsg += '		</p>'
	cRetMsg += '		<table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="1">'
	cRetMsg += '			<thead>'
	cRetMsg += '				<tr>'
	cRetMsg += '					<th scope="col" style="background-color: gray; font-weight: bold; color: white" >'
	cRetMsg += STR0019 //"Documento"
	cRetMsg += '					</th>'
	cRetMsg += '					<th scope="col" style="background-color: gray; font-weight: bold; color: white" >'
	cRetMsg += STR0020 //"Serie"
	cRetMsg += '					</th>'
	cRetMsg += '					<th scope="col" style="background-color: gray; font-weight: bold; color: white" >'
	cRetMsg += STR0021 //"Fornecedor"
	cRetMsg += '					</th>'
	cRetMsg += '					<th scope="col" style="background-color: gray; font-weight: bold; color: white" >'
	cRetMsg += STR0022 //"Filial"
	cRetMsg += '					</th>'
	cRetMsg += '				</tr>'
	cRetMsg += '			</thead>'
	cRetMsg += '			<tbody>'
	
	For nI := 1 To Len(aDados)
		cRetMsg += '				<tr>'
		cRetMsg += '					<td valign="center">'
		cRetMsg += 						aDados[nI,1]
		cRetMsg += '					</td>
		cRetMsg += '					<td valign="center">'
		cRetMsg += 						aDados[nI,2]
		cRetMsg += '					</td>
		cRetMsg += '					<td valign="center">'
		cRetMsg += 						aDados[nI,3]
		cRetMsg += '					</td>'
		If Len(aDados[nI]) > 3
			cRetMsg += '					<td valign="center">'
			cRetMsg += 						aDados[nI,4]
			cRetMsg += '					</td>
		Endif
		cRetMsg += '				</tr>'
	Next nI
	
	cRetMsg += '			</tbody>'
	cRetMsg += '		</table>'
	cRetMsg += '	</body>'
	cRetMsg += '</html>'
Endif

If lEditMsg
	cBkpMsg := cRetMsg
	
	cExecBlock:= "EVCOL"+Substr(cEventId,1,3)
	
	cRetMsg := ExecBlock(cExecBlock,.F.,.F.,{aDados,cRetMsg})
	
	If Valtype(cRetMsg) <> "C"
		cRetMsg := cBkpMsg
	EndIf
EndIf

Return cRetMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} SCHEDREP
Chamada para reprocessar arquivos da CKO ao finalizar a tela do
reprocessar

@author	rodrigo.mpontes
@since		22/03/2019
@version	12.1.17
/*/
//------------------------------------------------------------------- 

Function SCHEDREP()

Local aEmpPro	:= {}
Local cQry		:= ""
Local cAliasQry	:= GetNextAlias()

cQry := " SELECT CKO_EMPPRO, CKO_FILPRO"
cQry += " FROM " + RetSqlName("CKO")
cQry += " WHERE CKO_FLAG = '0'"
cQry += " AND CKO_EMPPRO <> ' '"
cQry += " AND D_E_L_E_T_ = ' '"
cQry += " GROUP  BY CKO_EMPPRO,CKO_FILPRO"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliasQry,.T.,.T.)

While (cAliasQry)->(!Eof())
	aAdd(aEmpPro,{AllTrim((cAliasQry)->CKO_EMPPRO),AllTrim((cAliasQry)->CKO_FILPRO)})
	(cAliasQry)->(DbSkip())
Enddo

(cAliasQry)->(DbCloseArea())

If Len(aEmpPro) > 0
	StartJob("SCHEDEMP",GetEnvServer(),.F.,aEmpPro)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SCHEDEMP
Chamada para reprocessar arquivos da CKO por empresa/filial

@author	rodrigo.mpontes
@since		22/03/2019
@version	12.1.17
/*/
//------------------------------------------------------------------- 

Function SCHEDEMP(aParametro)

Local nI := 1

For nI := 1 To len(aParametro)
	RpcSetType(3)
	RpcSetEnv(aParametro[nI,1],aParametro[nI,2],,,'COM')
	
	SchedComCol()

	RpcClearEnv()
Next nI

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SCHEDATUCKO
Atualiza novos campos da CKO (Doc, Serie, Nome Fornecedor)

@author	rodrigo.mpontes
@since		22/03/2019
@version	12.1.17
/*/
//------------------------------------------------------------------- 

Static Function SCHEDATUCKO(cFileAtu,cXmlAtu)

Local lCkoRepro		:= CKO->(FieldPos("CKO_DOC")) > 0 .And. CKO->(FieldPos("CKO_SERIE")) > 0 .And. CKO->(FieldPos("CKO_NOMFOR")) > 0 .And. !Empty(SDS->(IndexKey(4)))
Local lCkoEmp		:= CKO->(FieldPos("CKO_EMPPRO")) > 0 .And. CKO->(FieldPos("CKO_FILPRO")) > 0
Local lColGrvDados	:= FindFunction("COLGRVDADOS")
Local nTamCKOARQ	:= TamSX3("CKO_ARQUIV")[1]
Local aCkoDados		:= {}

cFileAtu := Padr(cFileAtu,nTamCKOARQ) 

If lCkoRepro .And. lColGrvDados
	aCkoDados := GetAdvFVal("CKO",{"CKO_DOC","CKO_SERIE","CKO_NOMFOR"},cFileAtu,1)
	If Len(aCkoDados) > 0 .And. (Empty(aCkoDados[1]) .Or. Empty(aCkoDados[2]) .Or. Empty(aCkoDados[3]))
		aCkoDados := COLGRVDADOS(cXmlAtu,1)
		If Len(aCkoDados) > 0
			CKO->(dbSetorder(1))
			If CKO->(DbSeek(cFileAtu))
				If RecLock("CKO",.F.)
					CKO->CKO_DOC	:= aCKODados[1]
					CKO->CKO_SERIE	:= aCKODados[2]
					CKO->CKO_NOMFOR	:= aCKODados[3]
					CKO->(MsUnlock())
				Endif
			Endif
		Endif
	Endif
Endif

If lCkoEmp .And. lColGrvDados
	aCkoDados := COLGRVDADOS(cXmlAtu,2)
	If Len(aCkoDados) > 0
		CKO->(dbSetorder(1))
		If CKO->(DbSeek(cFileAtu))
			If RecLock("CKO",.F.)
				CKO->CKO_EMPPRO	:= aCKODados[1]
				CKO->CKO_FILPRO	:= aCKODados[2]
				CKO->(MsUnlock())
			Endif
		Endif
	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SCHEDATUEMP
Atualiza campos da CKO (Empresa / Filial)

@author	rodrigo.mpontes
@since		22/03/2019
@version	12.1.17
/*/
//------------------------------------------------------------------- 

Static Function SCHEDATUEMP()

Local cQry		:= ""
Local cXmlRet	:= ""
Local cTmpQry	:= GetNextAlias()

cQry := " SELECT CKO_ARQUIV"
cQry += " FROM " + RetSqlName("CKO")
cQry += " WHERE CKO_EMPPRO = ''"
cQry += " AND CKO_FILPRO = ''"
cQry += " AND CKO_FLAG = '0'"
cQry += " AND D_E_L_E_T_ = ' '"

cQry := ChangeQuery(cQry)
																			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTmpQry,.T.,.T.) 

If (cTmpQry)->(!EOF())
	While (cTmpQry)->(!EOF())
		cXmlRet := ""
		cXmlRet	:= GetAdvFVal("CKO","CKO_XMLRET",(cTmpQry)->CKO_ARQUIV,1)

		If !Empty(cXmlRet)
			SCHEDATUCKO((cTmpQry)->CKO_ARQUIV,cXmlRet)
		Endif
		(cTmpQry)->(DbSkip())
	Enddo
Endif

Return
