#INCLUDE "Protheus.ch"  

User Function _COLABDOCS ; Return  // "dummy" function - Internal Use

//-------------------------------------------------------------------
/*/{Protheus.doc} ColaboracaoDocumentos
Classe para a representação de um documento do TOTVS Colaboração.

@author	Rafael Iaquinto
@since		18/07/2014
@version	11.7

@param cModelo,string, Modelo do documento.

/*/
//-------------------------------------------------------------------

class ColaboracaoDocumentos from LongNameClass
	
	data	cModelo
	data 	cNomeArq
	data	cQueue
	data	cXml
	data	cXmlRet
	data	dDataGer
	data	cHrGer
	data	dDataRet
	data	cHrRet
	data	cAmbiente
	data	cCdStatArq
	data	cDsStatArq
	data	cCdStatDoc
	data	cDsStatDoc
	data	cIdErp
	data	cTipoMov
	data 	cFlag
	data	lHistorico
	data	aHistorico	
	data	cSerie
	data	cNumero
	data	cCodErr
	data	cMsgErr
	data	aNomeArq
	data	cEmpProc
	data	cFilProc
	data	cCodErrErp
	data	cMsgErrErp
	data	cMsgErr024
	data	aQueue
	data	cCnpjImp
	data	aParamMonitor

	method	new()
	
	method transmitir()
	method consultar()	
	method gerararquivo()
	method validatransmissao()
	method buscahistorico()
	method flegadocumento()
	method validaConsulta()
	method buscaListaDocumentos()
	method buscaDocumentosFilial()
	method buscaIdErpPorTempo()
	method buscaIdPorRange()
    method gravaFilialDeProcessamento()
	method gravaErroErp()
	
endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} new
Método de instanciação da classe ColaboracaoDocumentos.

@return		nil

@author	Rafael Iaquinto
@since		18/07/2014
@version	11.7

@param		cModelo, string, Modelo do documento. Valores aceitos:<br>NFE-Nota Fiscal Eletrônica<br>CTE-Controle de Transporte eletrônico<br>MDE-Manifestação do Destinatário<br>MDF-Manifestação de Documentos Fiscais<br>CCE-Carta de correção eletrônica<br>EDI-Documentos de EDI - Pedidos,Espelho de nota e Programação de Entrega			
@param		cNomeArq, string, Nome do arquivo que será gerado, ou já geerado.
@param		cQueue, string, Codigo do EDI disponiblizado pela Neogrid no manual de integração.
@param		cXml, string, XML do documento gerado pelo ERP.<br>Deve obedecer o layout especificado pela NeoGrid.
@param		cXmlRet, string, XML retornado pela NeoGrid.
@param		dDataGer,date, Data de geração do arquivo.
@param		cHrGer, string, Hora de geração do arquivo
@param		dDataRet, date, Data de retorno do arquivo no diretório IN do Integrador da NeoGrid.
@param		cHrRet, string, Hora de reotorno do arquivo no diretório IN do Integrador da NeoGrid.
@param		cCdStatArq	, string, Codigo de Status da tabela CKO.
@param		cDsStatArq	, string, Descrição do Status da tabela CKO.
@param		cCdStatDoc	, string, Codigo de Status da tabela CKQ.
@param		cDsStatDoc	, string, Descrição do Status da tabela CKQ.
@param		cIdErp, string, ID do ERP para documentos do tipo Emissão(deve conter no final o codigo da empresa e filial)
@param		cTipoMov, string, Codigo do Tipo de Movimento: <br>1 - Emissão<br>2 - Recebimento
@param		cFlag, string, Flag de retorno ao ERP: <br>0 - Não Flegado<br>1 - Flegado<br>2 - Flegado com erro
@param		lHistorico	, lógico, Passar .T. para consultar também o histórico de envio de um mesmo documento.<br>Filtra a CKO pelo ID do ERP. Serve somente para o tipo de movimento 1 - Emissão.
@param		aHistorico	, array, Traz o histórico dos documentos, utilizado apenas com o tipo de movimento 1 - Emissão.	
@param		cSerie, string, Serie do documento. Utilizado apenas com o tipo de movimento 1 - Emissão.
@param		cNumero, string, Numero do documento. Utilizado apenas com tipo de movimento 1 - Emissão.
@param		cCodErr, string, Código de erro, retornado nas chamadas incorretas dos métodos.
@param		cMsgErr, string, Mensagem de erro, retornado nas chamadas incorretas dos métodos.
@param		aNomeArq, string, Nome do arquivo gerado automáticamente pelo método transmitir
/*/
//-------------------------------------------------------------------
method new() class ColaboracaoDocumentos
	::cModelo			:= ""
	::cNomeArq			:= "" 
	::cQueue			:= ""
	::cXml				:= ""
	::cXmlRet			:= ""
	::dDataGer			:= cToD( "  /  /  " )
	::cHrGer			:= ""
	::cAmbiente			:= "2"
	::dDataRet			:= cToD( "  /  /  " )
	::cHrRet			:= ""
	::cCdStatArq		:= ""
	::cDsStatArq		:= ""
	::cCdStatDoc		:= ""
	::cDsStatDoc		:= ""
	::cIdErp			:= ""
	::cTipoMov			:= ""
	::cFlag			:= ""
	::lHistorico		:= .F.
	::aHistorico		:= {}	
	::cSerie			:= ""
	::cNumero			:= ""
	::cCodErr			:= ""
	::cMsgErr			:= ""
	::aNomeArq			:= ""
	::cEmpProc			:= ""
	::cFilProc			:= ""
	::cCodErrErp		:= ""
	::cMsgErrErp		:= ""
	::cMsgErr024		:= ""
	::aQueue			:= {}
	::aParamMonitor		:= {}
	
return nil
//-------------------------------------------------------------------
/*/{Protheus.doc} transmitir
Método que envia documentos para transmissão via TOTVS Colaboração.Abaixo os atributos que devem estar preenchidos antes da chamada do método.

@author	Rafael Iaquinto
@since		18/07/2014
@version	11.7

@param		cModelo, string, Modelo do documento. Valores aceitos:<br>NFE-Nota Fiscal Eletrônica<br>CTE-Controle de Transporte eletrônico<br>MDE-Manifestação do Destinatário<br>MDF-Manifestação de Documentos Fiscais<br>CCE-Carta de correção eletrônica<br>EDI-Documentos de EDI - Pedidos,Espelho de nota e Programação de Entrega
@param		cTipoMov, string, Codigo do Tipo de Movimento: <br>1 - Emissão<br>2 - Recebimento
@param		cXml, string, XML do documento gerado pelo ERP.<br>Deve obedecer o layout especificado pela NeoGrid.
@param		cQueue, string, Codigo do EDI disponiblizado pela Neogrid no manual de integração.
@param		cIdErp, string, ID do ERP para documentos do tipo Emissão(deve conter no final o codigo da empresa e filial)		

@return	nil	 	Em caso de algum problema na chamada do método será retornado valores nos atributos cCodErr e cMsgErr.


/*/
//-------------------------------------------------------------------

	method	transmitir() class ColaboracaoDocumentos
	
	local nOrder1	:= 0
	local nRecno1	:= 0
	local nOrder2	:= 0
	local nRecno2	:= 0
	local lOk		:= .F.
	local lNewReg	:= .F.
	
	lOk := ::validatransmissao()
		
	if lOk
		nOrder1	:= CKQ->( indexOrd() )
		nRecno1	:= CKQ->( recno() )
		
		nOrder2	:= CKO->( indexOrd() )
		nRecno2	:= CKO->( recno() )
		
		CKQ->( dbSetOrder( 1 ) )
		
		if CKQ->( dbSeek( xFilial("CKQ") + PadR( ::cModelo,Len(CKQ->CKQ_MODELO) ) + ::cTipoMov + PadR( ::cIdErp,Len(CKQ->CKQ_IDERP) )  ) ) 			
			//Realiza as validações de STATUS da CKQ
			if Alltrim( CKQ->CKQ_STATUS ) == "1"
				lOk := .F.
				::cCodErr	:= ColGetErro(4)[1]
				::cMsgErr	:= ColGetErro(4)[2]
			endif
		else
			lOk := .T.
			lNewReg := .T.
		endif
		
		if lOk		
			if ::gerararquivo()
				
				Begin Transaction
				
				If ::cTipoMov == "1"
					
					reclock("CKQ",lNewReg)							
					CKQ->CKQ_FILIAL	:=	xFilial("CKQ")
					CKQ->CKQ_MODELO	:= ::cModelo			
					CKQ->CKQ_TP_MOV	:= ::cTipoMov 			
					CKQ->CKQ_CODEDI	:= ::cQueue
					CKQ->CKQ_ARQUIV	:= ::cNomeArq
					CKQ->CKQ_STATUS	:= ColCKQStatus()[1][1]			
					CKQ->CKQ_DESSTA	:= ColCKQStatus()[1][2]			
					CKQ->CKQ_IDERP	:= ::cIdErp
					CKQ->CKQ_SERIE	:= ::cSerie			
					CKQ->CKQ_NUMERO	:= ::cNumero		
					CKQ->CKQ_DT_GER	:=	date()
					CKQ->CKQ_HR_GER	:=	time()		
					CKQ->CKQ_AMBIEN := ::cAmbiente
					CKQ->( msUnlock() )
					MsUnLockAll()		
				
				endif
													
				reclock("CKO",.T.)															
				CKO->CKO_ARQUIV	:=	::cNomeArq
				CKO->CKO_XMLENV	:=	::cXML
				CKO->CKO_XMLRET	:=	""
				CKO->CKO_DT_GER	:=	date()
				CKO->CKO_HR_GER	:=	time()
				CKO->CKO_DT_RET	:=	cToD( "  /  /  " ) 			
				CKO->CKO_HR_RET	:= ""
				CKO->CKO_STATUS	:= ColCKOStatus()[1][1]
				CKO->CKO_DESSTA	:= ColCKOStatus()[1][2]
				CKO->CKO_IDERP	:= ::cIdErp
				CKO->CKO_TP_MOV	:= ::cTipoMov
				CKO->CKO_FLAG		:= "0"
				CKO->CKO_CODEDI	:= ::cQueue
				CKO->( msUnlock() )
				MsUnLockAll()		

				End Transaction				
															
				::dDataGer		:= CKO->CKO_DT_GER
				::cHrGer		:= CKO->CKO_HR_GER								
				::cCdStatArq	:= CKO->CKO_STATUS
				::cDsStatArq	:= CKO->CKO_DESSTA 
				::cFlag		:= CKO->CKO_FLAG
				
				::cCdStatDoc	:= CKQ->CKQ_STATUS
				::cDsStatDoc	:= CKQ->CKQ_DESSTA
				::cSerie		:= CKQ->CKQ_SERIE
				::cNumero		:= CKQ->CKQ_NUMERO	
				
				
				CKQ->(MsUnLock())	
				CKO->(MsUnLock())
				MsUnLockAll()				
			else			
				lOk := .F.
			endif				
				
		endif		
				
		CKQ->( dbSetOrder( nOrder1 ) )	
		CKQ->( dbGoTo( nRecno1 ) )
		
		CKO->( dbSetOrder( nOrder2 ) )	
		CKO->( dbGoTo( nRecno2 ) )
	endif
	
return( lOk )




//-------------------------------------------------------------------
/*/{Protheus.doc} buscahistorico
Metodo que busca o histórico do documento conforme o IDERP. Utilizado apenas para tipo de movimento 1 - Emissão.

@param		cIdErp, string, ID do ERP para documentos do tipo Emissão(deve conter no final o codigo da empresa e filial)
@param		lHistorico	, lógico, Passar .T. para consultar também o histórico de envio de um mesmo documento.<br>Filtra a CKO pelo ID do ERP. Serve somente para o tipo de movimento 1 - Emissão.
@param		cTipoMov, string, Codigo do Tipo de Movimento deve ser: <br>1 - Emissão

@return		lok		.T. se a consulta do historico foi realizada.

@author	Rafael Iaquinto
@since		18/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------

method buscahistorico() class ColaboracaoDocumentos

	local lOk		:= .T.
	
	if !::lHistorico
		::cCodErr	:= ColGetErro(16)[1]
		::cMsgErr	:= ColGetErro(16)[2]
		lOk			:= .F.
	elseif ::cTipoMov <> "1" 
		::cCodErr	:= ColGetErro(17)[1]
		::cMsgErr	:= ColGetErro(17)[2]
		lOk			:= .F.
	elseif Empty(::cIdErp)
		::cCodErr	:= ColGetErro(18)[1]
		::cMsgErr	:= ColGetErro(18)[2]
		lOk			:= .F.
	endif
	
	::aHistorico	:= {}
	
	if lOk
		::aHistorico := ColGetHist( ::cIdErp )
	endif
	
return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} consultar
Método que realiza a consulta dos documentos nas tabelas CKQ e CKO.

@param		cTipoMov, string, Codigo do Tipo de Movimento: <br>1 - Emissão<br>2 - Recebimento
@param		cModelo, string, Modelo do documento. <b>(Obrigatório se o TIPO de Movimento = 1). Valores aceitos:<br>NFE-Nota Fiscal Eletrônica<br>CTE-Controle de Transporte eletrônico<br>MDE-Manifestação do Destinatário<br>MDF-Manifestação de Documentos Fiscais<br>CCE-Carta de correção eletrônica<br>EDI-Documentos de EDI - Pedidos,Espelho de nota e Programação de Entrega
@param		cIdErp, string, ID do ERP para documentos do tipo Emissão(deve conter no final o codigo da empresa e filial).<br><b>(Obrigatório se o TIPO de Movimento = 2)
@param		cQueue, string, Codigo do EDI disponiblizado pela Neogrid no manual de integração.<br><b>(Obrigatório se o TIPO de Movimento = 2)
@param		cNomeArq, string, Nome do arquivo que será gerado, ou já geerado.<br><b>(Obrigatório se o TIPO de Movimento = 2)
@param		cFlag, string, Flag de retorno ao ERP: <br>0 - Não Flegado<br>1 - Flegado<br><b>(Obrigatório se o TIPO de Movimento = 2)<br>2 - Flegado com erro

@return		nil

@author	Douglas Parreja
@since		21/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
method consultar() class ColaboracaoDocumentos
	
	Local lValida	:= .F.
	Local lOk		:= .F.
	Local lAchou 	:= .F.
	Local lAchouCKO	:= .F.
	
	local nOrder1	:= 0
	local nRecno1	:= 0
	local nOrder2	:= 0
	local nRecno2	:= 0
		
	lValida	:= ::validaConsulta()
	
	If lValida
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tipo de Movimento - Emissao                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ::cTipoMov == "1"
			
			nOrder1	:= CKQ->( indexOrd() )
			nRecno1	:= CKQ->( recno() )
			
			nOrder2	:= CKO->( indexOrd() )
			nRecno2	:= CKO->( recno() )
			
			CKQ->( dbSetOrder( 1 ) )
		
			If CKQ->( dbSeek( xFilial("CKQ") + PadR(::cModelo,Len(CKQ->CKQ_MODELO)) + PadR(::cTipoMov,Len(CKQ->CKQ_TP_MOV) ) + PadR(::cIdErp,Len(CKQ->CKQ_IDERP)) ) )
				lAchou := .T.
			Endif
			
			
			If lAchou
				
				::cModelo			:= Alltrim( CKQ->CKQ_MODELO )
				::cNomeArq			:= Alltrim( CKQ->CKQ_ARQUIV )
				::cQueue			:= Alltrim( CKQ->CKQ_CODEDI )
				::cCdStatDoc		:= Alltrim( CKQ->CKQ_STATUS )
				::cDsStatDoc		:= Alltrim( CKQ->CKQ_DESSTA )
				::cIdErp			:= Alltrim( CKQ->CKQ_IDERP  )
				::cTipoMov			:= Alltrim( CKQ->CKQ_TP_MOV )
				::cSerie			:= Alltrim( CKQ->CKQ_SERIE  )
				::cNumero			:= Alltrim( CKQ->CKQ_NUMERO )
				
				CKO->( dbSetOrder( 1 ) )
				
				If CKO->( dbSeek( ::cNomeArq ) )
					lAchouCKO := .T.
					
					If lAchouCKO
								
						::cXml				:= Alltrim( CKO->CKO_XMLENV )
						::cXmlRet			:= Alltrim( CKO->CKO_XMLRET )
						::dDataGer			:= CKO->CKO_DT_GER
						::cHrGer			:= Alltrim( CKO->CKO_HR_GER )
						::dDataRet			:= CKO->CKO_DT_RET
						::cHrRet			:= Alltrim( CKO->CKO_HR_RET )
						::cCdStatArq		:= Alltrim( CKO->CKO_STATUS )
						::cDsStatArq		:= Alltrim( CKO->CKO_DESSTA )
						::cFlag			:= Alltrim( CKO->CKO_FLAG   )					
						::lHistorico		:= .F.				
						::aHistorico		:= {}						
						::cSerie			:= Alltrim( CKQ->CKQ_SERIE  )
						::cNumero			:= Alltrim( CKQ->CKQ_NUMERO )											
						::cAmbiente		:= CKQ->CKQ_AMBIEN
						
						//Atualiza o STATUS da CKQ com o ultimo da CKO
						if CKQ->CKQ_STATUS <> CKO->CKO_STATUS
							reclock("CKQ",.F.)
							CKQ->CKQ_STATUS	:= ColCKQStatus()[val(CKO->CKO_STATUS)][1]			
							CKQ->CKQ_DESSTA	:= ColCKQStatus()[val(CKO->CKO_STATUS)][2] 
							CKQ->(msunlock())
							
							::cCdStatDoc		:= Alltrim( CKQ->CKQ_STATUS )
							::cDsStatDoc		:= Alltrim( CKQ->CKQ_DESSTA )
						endif
													
					EndIf
				Endif
								
				
				lOk := .T.
			Else
				::cCodErr	:= ColGetErro(20)[1]
				::cMsgErr	:= ColGetErro(20)[2]								
			EndIf
			CKQ->( dbSetOrder( nOrder1 ) )	
			CKQ->( dbGoTo( nRecno1 ) )
			
			CKO->( dbSetOrder( nOrder2 ) )	
			CKO->( dbGoTo( nRecno2 ) )
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tipo de Movimento - Recebimento                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		ElseIf ::cTipoMov == "2"
			nOrder2	:= CKO->( indexOrd() )
			nRecno2	:= CKO->( recno() )
		
			CKO->( dbSetOrder( 1 ) )
				
			If CKO->( dbSeek( ::cNomeArq ) )
				lAchouCKO := .T.
				
				If lAchouCKO
							
					::cXml				:= Alltrim( CKO->CKO_XMLENV )
					::cXmlRet			:= Alltrim( CKO->CKO_XMLRET )
					::dDataGer			:= CKO->CKO_DT_GER
					::cHrGer			:= Alltrim( CKO->CKO_HR_GER )
					::dDataRet			:= CKO->CKO_DT_RET
					::cHrRet			:= Alltrim( CKO->CKO_HR_RET )
					::cCdStatArq		:= Alltrim( CKO->CKO_STATUS )
					::cDsStatArq		:= Alltrim( CKO->CKO_DESSTA )
					::cFlag				:= Alltrim( CKO->CKO_FLAG   )
					::cIdErp			:= Alltrim( CKO->CKO_IDERP  )	 
					::lHistorico		:= .F.				// VERIFICAR
					::aHistorico		:= {}				// VERIFICAR
					::cEmpProc			:= If(CKO->(FieldPos("CKO_EMPPRO"))> 0,Alltrim( CKO->CKO_EMPPRO ),"")
					::cFilProc			:= If(CKO->(FieldPos("CKO_FILPRO"))> 0,Alltrim( CKO->CKO_FILPRO ),"")
					::cCodErrErp		:= If(CKO->(FieldPos("CKO_CODERR"))> 0,Alltrim( CKO->CKO_CODERR ),"")
					::cMsgErrERP		:= ColErroErp( ::cCodErrErp )
					
					If CKO->(FieldPos("CKO_MSGERR")) > 0
						::cMsgErr024		:= CKO->CKO_MSGERR
					Endif
					
					::cCnpjImp			:= If(CKO->(FieldPos("CKO_CNPJIM"))> 0,Alltrim( CKO->CKO_CNPJIM ),"")

					lOk := .T.
										
				EndIf
			Endif
			
			CKO->( dbSetOrder( nOrder2 ) )	
			CKO->( dbGoTo( nRecno2 ) )
		EndIf
	EndIf
	
		
return	( lOk )

//-------------------------------------------------------------------
/*/{Protheus.doc} buscaListaDocumentos
Método que realiza a bsuca de uma lista de documentos disponíveis conforme atributos passados.

@param		cQueue, string, Codigo do EDI disponiblizado pela Neogrid no manual de integração.<br><b>(Obrigatório se o TIPO de Movimento = 2)
@param		cFlag, string, Flag de retorno ao ERP: <br>0 - Não Flegado<br>1 - Flegado<br><b>(Obrigatório se o TIPO de Movimento = 2)<br>2 - Flegado com erro
@param		dDataRet,date, Informar esta data quando desejar retornar arquivos á partir dela.<br><b>Não Obrigatório

@return	lOk Retorna .T. se for executado corretamente.Coloca no atributo aHistorico a lista de  com os nomes dos documentos caso encontre. 

@author	Douglas Parreja
@since		23/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
method buscaListaDocumentos() class ColaboracaoDocumentos

	Local lValido	:= .F.
	Local lOk		:= .F.

	
	lValido	:= ::validaConsulta()
	//dDataRet nao eh um objeto obrigatorio a ser informado por isso nao eh validado no method validaConsulta
	
	If lValido			
						
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para Buscar os nomes dos arquivos                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		::aNomeArq	:= ColListaDocumentos( ::cQueue , ::cFlag , ::dDataRet )
			
		lOk := .T.
	
	EndIf
	
Return ( lOk )


//-------------------------------------------------------------------
/*/{Protheus.doc} flegadocumento
Metodo que flega o documento conforme o nome do arquivo passado.

@param		cNomeArq, string, Nome do arquivo que será flegado.
@param		cFlag, string, Flag que deseja atualizar no registro: <br>0 - Não Flegado<br>1 - Flegado<br>2 - Flegado com erro<br><b>Caso não seja passado considera-se 1

@return	lok		.T. se o documento for flegado com suceso.

@author	Rafael Iaquinto
@since		28/07/2014
@version	11.7x
/*/
//-------------------------------------------------------------------
method flegadocumento() class ColaboracaoDocumentos
	local lOk		:= .T.
	local nOrder1	:= 0
	local nRecno1	:= 0
	
	If empty(	::cNomeArq )
		::cCodErr	:= ColGetErro(12)[1]
		::cMsgErr	:= ColGetErro(12)[2]	
		lOk		:= .F.	
	endIf
	
	if lOk
		If empty(	::cFlag )
			::cFlag := "1" //Se o Flag não for passado será sempre considerado 1 - Flegado
		endif		
		if !( ::cFlag  $  "0|1|2" ) 
			::cCodErr	:= ColGetErro(19)[1]
			::cMsgErr	:= ColGetErro(19)[2]	
			lOk		:= .F.	
		endIf
	endif	
			
	if lOk
		nOrder1	:= CKQ->( indexOrd() )
		nRecno1	:= CKQ->( recno() )
		
		CKO->( dbSetOrder( 1 ) )
		if CKO->( dbSeek(PADR(Lower(::cNomeArq),Len(CKO->CKO_ARQUIV))))
			
			Begin Transaction
			
				reclock("CKO",.F.)
				CKO->CKO_FLAG	:= ::cFlag
				CKO->(msunlock())
			
			End Transaction
			
			msunlockall()
		else
			::cCodErr	:= ColGetErro(15)[1]
			::cMsgErr	:= ColGetErro(15)[2]	
			lOk		:= .F.
		endif 
		
		CKQ->( dbSetOrder( nOrder1 ) )	
		CKQ->( dbGoTo( nRecno1 ) )		
	endif
	
return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} buscaIdErpPorTempo
Método que busca uma lista de IDs do ERP por intervalo de tempo fixo.

@param		dDataIni, data, Data inicial da busca.
@param		cTimeIni, data, Data inicial da busca.

@return	lOk Retorna .T. se a validação foi realizada com sucesso. E coloca a lista de documentos no aNomeArq.

@author	Rafael Iaquinto
@since		18/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
method buscaIdErpPorTempo(dDataIni,cTimeIni) class ColaboracaoDocumentos
	
	local lOk	:= .T.
	
	
	if Empty(dDataIni) .Or. Empty(cTimeIni)
		::cCodErr	:= ColGetErro(23)[1]
		::cMsgErr	:= ColGetErro(23)[2]	
		lOk		:= .F.
	elseIf Empty(::cTipoMov)
		::cCodErr	:= ColGetErro(8)[1]
		::cMsgErr	:= ColGetErro(8)[2]	
		lOk		:= .F.
	elseIf ::cTipoMov <> "1"
		::cCodErr	:= ColGetErro(17)[1]
		::cMsgErr	:= ColGetErro(17)[2]	
		lOk		:= .F.
	endif
	
	::aNomeArq := ColRetIdErp(dDataIni,cTimeIni,::cModelo,::cQueue)
	
return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} buscaIdPorRange
Método que busca uma lista de IDs do ERP por range de IDERP.

@param		cIdErpIni, string, Id do ERP inicial
@param		cIdErpFim, string, Id do ERP final

@return	lOk Retorna .T. se a validação foi realizada com sucesso. E coloca a lista de documentos no aNomeArq.

@author	Rafael Iaquinto
@since		18/09/2014
@version	11.8
/*/
//-------------------------------------------------------------------
method buscaIdPorRange(cIdErpIni,cIdErpFim,cModelo) class ColaboracaoDocumentos
	
	local lOk	:= .T.
	local dDataIni:= CTOD(" \ \ ")
	
	::aNomeArq := ColRetIdErp(dDataIni,"",cModelo,"",cIdErpIni,cIdErpFim)
	
return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} validatransmissao
Método chamado internamente pelo método transmitir, valida os dados passados pelo método.Valida também os parâmetros MV_NGOUT,MV_NGINN e MV_NGLIDOS.

@param		cModelo, string, Modelo do documento. Valores aceitos:<br>NFE-Nota Fiscal Eletrônica<br>CTE-Controle de Transporte eletrônico<br>MDE-Manifestação do Destinatário<br>MDF-Manifestação de Documentos Fiscais<br>CCE-Carta de correção eletrônica<br>EDI-Documentos de EDI - Pedidos,Espelho de nota e Programação de Entrega
@param		cTipoMov, string, Codigo do Tipo de Movimento: <br>1 - Emissão<br>2 - Recebimento
@param		cXml, string, XML do documento gerado pelo ERP.<br>Deve obedecer o layout especificado pela NeoGrid.
@param		cQueue, string, Codigo do EDI disponiblizado pela Neogrid no manual de integração.
@param		cIdErp, string, ID do ERP para documentos do tipo Emissão(deve conter no final o codigo da empresa e filial)

@return	lValido Retorna .T. se a validação foi realizada com sucesso.

@author	Rafael Iaquinto
@since		18/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
static method validatransmissao() class ColaboracaoDocumentos
	
	Local cBarra		:= If(isSrvUnix(),"/","\")
	
	local cDirOut		:= AllTrim(GetNewPar("MV_NGOUT","\NeoGrid\OUT"))
	local cDirIn		:= AllTrim(GetNewPar("MV_NGINN","\NeoGrid\IN"))
	local cDirLido	:= AllTrim(GetNewPar("MV_NGLIDOS","\NeoGrid\LIDOS"))
	
	local lValido	:= .T.
	
	
	if cBarra == "/"
		cDirOut	:= StrTran(cDirOut,"\","/")
		cDirIn		:= StrTran(cDirIn,"\","/")
		cDirLido	:= StrTran(cDirLido,"\","/")
	else
		cDirOut	:= StrTran(cDirOut,"/","\")
		cDirIn		:= StrTran(cDirIn,"/","\")
		cDirLido	:= StrTran(cDirLido,"/","\")
	endif
	
	//Cria pasta no server para geração do arquivo.
	If !ExistDir(cDirOut)
		if Makedir( cDirOut ) != 0
			::cCodErr	:= ColGetErro(3)[1]
			::cMsgErr	:= ColGetErro(3)[2]+	cDirOut + ". Erro " + cValToChar( FError() ) + ". Verificar parâmetro MV_NGOUT." 
			lValido	:= .F. 							
		endif
	EndIf
	
	If lValido .And. !ExistDir(cDirIn)
		if Makedir( cDirIn ) != 0
			::cCodErr	:= ColGetErro(3)[1]
			::cMsgErr	:= ColGetErro(3)[2]+	cDirIn + ". Erro " + cValToChar( FError() ) + ". Verificar parâmetro MV_NGINN." 
			lValido	:= .F. 
		endif
	EndIf
	
	If lValido .And. !ExistDir( cDirLido)
		if Makedir( cDirLido ) != 0
			::cCodErr	:= ColGetErro(3)[1]
			::cMsgErr	:= ColGetErro(3)[2]+	cDirLido + ". Erro " + cValToChar( FError() ) + ". Verificar parâmetro MV_NGLIDOS." 
			
			lValido	:= .F. 					
		endif
	EndIf
	
	if lValido 
		if empty( ::cModelo ) .or. empty( ::cTipoMov ) .Or. empty(::cXMl) .or. empty(::cQueue)
			::cCodErr	:= ColGetErro(1)[1]
			::cMsgErr	:= ColGetErro(1)[2]	
			lValido	:= .F. 
		elseif empty( ::cIDERP ) .And. ::cTipoMov == "1" 
			::cCodErr	:= ColGetErro(2)[1]
			::cMsgErr	:= ColGetErro(2)[2]	
			lValido	:= .F.		
		elseif !( ColCheckQueue(::cQueue) )
			::cCodErr	:= ColGetErro(5)[1]
			::cMsgErr	:= ColGetErro(5)[2]	
			lValido	:= .F.
		elseif !( ColcheckModelo(::cModelo) )
			::cCodErr	:= ColGetErro(6)[1]
			::cMsgErr	:= ColGetErro(6)[2]
			lValido	:= .F.
		endif
		
	endif
			
return ( lValido )

//-------------------------------------------------------------------
/*/{Protheus.doc} gerararquivo
Método que gera o arquivo no diretório do integrador da NeoGrid.

@return		lGerado .T. quando o for gerado com sucesso.

@author	Rafael Iaquinto
@since		18/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
static method gerararquivo() class ColaboracaoDocumentos
	
	local lGerado := .F.
	local cMsg
	
	local cDirOut		:= AllTrim(GetNewPar("MV_NGOUT","\NeoGrid\OUT"))	
	
	if ColGeraArquivo( cDirOut, @::cNomeArq , ::cQueue , ::cXML ,@cMsg)
		lGerado	:= .T.	
	else
		cCodErr	:= ColGetErro(7)[1]
		cMsgErr	:= ColGetErro(7)[2] + cMsg
	endif

return lGerado

//-------------------------------------------------------------------
/*/{Protheus.doc} validaConsulta
Método chamado internamente pelo método consulta, valida os dados passados pelo método.

@param		cTipoMov, string, Codigo do Tipo de Movimento: <br>1 - Emissão<br>2 - Recebimento
@param		cModelo, string, Modelo do documento. Valores aceitos:<br>NFE-Nota Fiscal Eletrônica<br>CTE-Controle de Transporte eletrônico<br>MDE-Manifestação do Destinatário<br>MDF-Manifestação de Documentos Fiscais<br>CCE-Carta de correção eletrônica<br>EDI-Documentos de EDI - Pedidos,Espelho de nota e Programação de Entrega
@param		cIdErp, string, ID do ERP para documentos do tipo Emissão(deve conter no final o codigo da empresa e filial)
@param		cQueue, string, Codigo do EDI disponiblizado pela Neogrid no manual de integração.
@param		cFlag, string, Flag de retorno ao ERP: <br>0 - Não Flegado<br>1 - Flegado<br>2 - Flegado com erro
@param		dDataRet, date, Data de retorno do arquivo no diretório IN do Integrador da NeoGrid.

@return	lValido Retorna .T. se a validacao foi realizada com sucesso.

@author	Douglas Parreja
@since		21/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
static method validaConsulta() class ColaboracaoDocumentos
	
	Local lValido	:= .T.
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo de Movimento - nao foi passado 								 	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If empty( ::cTipoMov )
		::cCodErr	:= ColGetErro(8)[1]
		::cMsgErr	:= ColGetErro(8)[2]	
		lValido	:= .F.	
	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tipo de Movimento - Emissao (Tabela CKQ)                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ::cTipoMov == "1"
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Modelo / Tipo Movimento - ID Erp nao foram passados                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If empty( ::cModelo ) .AND. empty( ::cIdErp )
				::cCodErr	:= ColGetErro(9)[1]
				::cMsgErr	:= ColGetErro(9)[2]	
				lValido	:= .F. 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Modelo - nao foi passado 											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf empty( ::cModelo )  .AND. !empty( ::cIdErp ) 		
				::cCodErr	:= ColGetErro(10)[1]
				::cMsgErr	:= ColGetErro(10)[2]	
				lValido	:= .F. 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ID do Erp - nao foi passado 											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf !empty( ::cModelo ) .AND. empty( ::cIdErp )
				::cCodErr	:= ColGetErro(2)[1]
				::cMsgErr	:= ColGetErro(2)[2]	
				lValido	:= .F.					
			EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tipo de Movimento - Recebimento (Tabela CKO)                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf ::cTipoMov == "2"
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Codigo Queue / Flag / Data de Retorno - nao foram passados  		       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If empty(	::cQueue ) .AND. empty(	 ::cFlag ) .AND. empty( ::dDataRet )
				::cCodErr	:= ColGetErro(11)[1]
				::cMsgErr	:= ColGetErro(11)[2]	
				lValido		:= .F.	
			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Queue - nao foi passado 	ou codigo passado invalido    		           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If empty(	::cQueue )
				::cCodErr	:= ColGetErro(13)[1]
				::cMsgErr	:= ColGetErro(13)[2]
				lValido		:= .F.
			EndIf	
			If !( ColCheckQueue(::cQueue) )
				::cCodErr	:= ColGetErro(5)[1]
				::cMsgErr	:= ColGetErro(5)[2]	
				lValido	:= .F.
			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Flag - nao foi passado 							    		           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			If empty(	::cFlag )
				::cCodErr	:= ColGetErro(14)[1]
				::cMsgErr	:= ColGetErro(14)[2]	
				lValido		:= .F.	
			EndIf
			
		EndIf
	
	EndIf
	
return ( lValido )

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaFilialDeProcessamento
Método que grava a filial de processamento do xml


@return	lOk Retorna .T. se gravou ou .F. se não gravou

@author	Flavio Lopes Rasta
@since		07/10/2014
@version	11.7
/*/
//-------------------------------------------------------------------
method gravaFilialDeProcessamento() class ColaboracaoDocumentos
	local lOk		:= .T.
	local nOrder1	:= 0
	local nRecno1	:= 0
	
	If empty(	::cNomeArq )
		::cCodErr	:= ColGetErro(12)[1]
		::cMsgErr	:= ColGetErro(12)[2]	
		lOk		:= .F.	
	endIf
	
	if lOk
		If Empty(::cFilProc ) .And. Empty(::cEmpProc ) .And. Empty(::cCnpjImp)
			lOk			:= .F.
		endif		
	endif	
			
	if lOk
		nOrder1	:= CKQ->( indexOrd() )
		nRecno1	:= CKQ->( recno() )
		
		CKO->( dbSetOrder( 1 ) )
		if CKO->( dbSeek(PADR(Lower(::cNomeArq),Len(CKO->CKO_ARQUIV))))
			
			Begin Transaction
			
				reclock("CKO",.F.)
				CKO->CKO_EMPPRO	:= ::cEmpProc
				CKO->CKO_FILPRO	:= ::cFilProc
				If CKO->(FieldPos("CKO_CNPJIM")) > 0
					CKO->CKO_CNPJIM	:= ::cCnpjImp
				EndIf
				CKO->(msunlock())
			
			End Transaction
			
			msunlockall()
		else
			::cCodErr	:= ColGetErro(15)[1]
			::cMsgErr	:= ColGetErro(15)[2]	
			lOk		:= .F.
		endif 
		
		CKQ->( dbSetOrder( nOrder1 ) )	
		CKQ->( dbGoTo( nRecno1 ) )		
	endif
	
return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} buscaDocumentosFilial
Método que realiza a bsuca de uma lista de documentos disponíveis conforme atributos passados.

@param		cQueue, string, Codigo do EDI disponiblizado pela Neogrid no manual de integração.<br><b>(Obrigatório se o TIPO de Movimento = 2)
@param		cFlag, string, Flag de retorno ao ERP: <br>0 - Não Flegado<br>1 - Flegado<br><b>(Obrigatório se o TIPO de Movimento = 2)
@param		dDataRet,date, Informar esta data quando desejar retornar arquivos á partir dela.<br><b>Não Obrigatório

@return	lOk Retorna .T. se for executado corretamente.Coloca no atributo aHistorico a lista de  com os nomes dos documentos caso encontre. 

@author	Douglas Parreja
@since		23/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
method buscaDocumentosFilial() class ColaboracaoDocumentos

	Local lValido	:= .F.
	Local lOk		:= .F.

	
	lValido	:= ::validaConsulta()
	//dDataRet nao eh um objeto obrigatorio a ser informado por isso nao eh validado no method validaConsulta
	
	If lValido			
						
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para Buscar os nomes dos arquivos                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		::aNomeArq	:= ColListaFiliais( ::cQueue , ::cFlag , ::cEmpproc , ::cFilproc ,::dDataRet, ::aQueue, ::aParamMonitor )
			
		lOk := .T.
	
	EndIf
	
Return ( lOk )

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaErroErp
Método que grava o erro de processamento na tabela CKO


@return	lOk Retorna .T. se gravou ou .F. se não gravou

@author	Flavio Lopes Rasta
@since		07/10/2014
@version	11.7
/*/
//-------------------------------------------------------------------
method gravaErroErp() class ColaboracaoDocumentos
	local lOk		:= .T.
	local nOrder1	:= 0
	local nRecno1	:= 0
	
	If empty(	::cNomeArq )
		::cCodErr	:= ColGetErro(12)[1]
		::cMsgErr	:= ColGetErro(12)[2]	
		lOk		:= .F.	
	endIf
					
	if lOk
		nOrder1	:= CKQ->( indexOrd() )
		nRecno1	:= CKQ->( recno() )
		
		CKO->( dbSetOrder( 1 ) )
		if CKO->( dbSeek(PADR(Lower(::cNomeArq),Len(CKO->CKO_ARQUIV))))
			
			Begin Transaction
			
				reclock("CKO",.F.)
				CKO->CKO_CODERR	:= ::cCodErrErp
				
				If CKO->(FieldPos("CKO_MSGERR")) > 0 .And. !Empty(::cMsgErr024)
					CKO->CKO_MSGERR := ::cMsgErr024
				Endif
				
				CKO->(msunlock())
			
			End Transaction
			
			msunlockall()
		else
			::cCodErr	:= ColGetErro(15)[1]
			::cMsgErr	:= ColGetErro(15)[2]	
			lOk		:= .F.
		endif 
		
		CKQ->( dbSetOrder( nOrder1 ) )	
		CKQ->( dbGoTo( nRecno1 ) )		
	endif
	
return lOk
