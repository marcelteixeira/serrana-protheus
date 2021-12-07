#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"

#DEFINE TOTVS_COLAB_ONDEMAND 3100 // TOTVS Colaboracao

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColUsaColab
Realiza a verificação do parâmetro MV_TCNEW, para identificar se o modelo
passado está utilizando o TOTVS Colaboração 2.0
 
@author 	Rafel Iaquinto
@since 		28/07/2014
@version 	11.9
 
@param	cModelo, string, Código do modelo: 0 - todos<br>1-NFE<br>2-CTE<br>3-NFS<br>4-MDe<br>5-MDfe<br>6-Recebimento
 
@return lUsaColab Retorna .T. se o modelo passado existe no parâmetro.
/*/
//-----------------------------------------------------------------------
function ColUsaColab(cModelo)

	local cMVNewTc	:= Alltrim( SuperGetMv("MV_TCNEW", .F. ,"" ) )
	
	local lUsaColab	:= .F.
	
	local nAt			:= 0


	default cModelo	:= ""

	if !Empty(cMVNewTc)
		
		nAt := At(",",cMVNewTc)
		
		if nAt > 0
			aModelos := STRTOKARR(cMVNewTc,",")	
		else
			aModelos := {cMVNewTc}
		endif	
		
		if ascan( aModelos, "0" ) > 0 .Or. ascan( aModelos, cModelo ) > 0 							
			lUsaColab := colCheckLicense()
		endif

	endif	
		
	return lUsaColab

//-----------------------------------------------------------------------
/*/{Protheus.doc} colCheckLicense
Verifica se a empresa tem a licença para utilização do TOTVS Colaboração.
 
@author 	Rafel Iaquinto
@since 		23/09/2014
@version 	11.8

@return lOk Retorna .T. se a empresa tiver a autorização.
/*/
//-----------------------------------------------------------------------
function colCheckLicense()

local lOk	:= .T.
	
	If (FwEmpTeste())

	Elseif	(FindFunction("FWLSEnable"))
	Elseif (FWLSEnable(TOTVS_COLAB_ONDEMAND)) 
	Else
	MsgStop("Ambiente não licenciado para o modelo TOTVS Colaboração")
       lok := .F.
EndIf
	
return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColCheckUpd
Funcao que verifica se o update do TOTVS Colaboração foi aplicado.

@return	lUpdOK		Verdadeiro se estiver ok o Update.

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------

function ColCheckUpd()
local lUpdOK	:= .F. 

If AliasIndic("CKQ") .And. AliasIndic("CKO") .And. AliasIndic("CKP")  .And. RetSqlName("CKO") == "CKOCOL"
	lUpdOk := .T.
endif 

return lUpdOK
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColParValid
Funcao que verifica se a empresa utiliza o novo modelo do TOTVS Colaboraço

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9

@param		cModelo,string, Modelo do documento.<br>NFE - NF eletronica<br>	CTE - CT eletronico<br>CCE - Carta de Correção Eletronica<br>	MDE - Manifestação do Destinatário<br>MDFE - Manifesto de documentos fis. Eletr.<br>NFSE - NF de Serviço eletrônica.						
@param		@cMsg,string, Mensagem de retorno da validação.
		
@return	lOk			Retorna .T. se a configuração estiver Ok.
/*/
//-----------------------------------------------------------------------

function ColParValid(cModelo,cMsg)

local aParam		:= ColListPar(cModelo)

local cConteudo	:= ""
local cMsgIni		:= "Parametros não configurados: "+CRLF+CRLF
local cMsgFim		:= CRLF+"Realizar a configuração necessárias."+CRLF

local nX			:= 0

local lOk			:= .T.

default cMsg := ""

for nx := 1 to len(aParam)
	
	cConteudo := ""
	
	cConteudo := ColGetPar( aParam[nx][01] )
	
	if Empty(cConteudo) .And. ( ;
		aParam[nx][01] <> "MV_NFXJUST" .And. aParam[nx][01] <> "MV_NFINCON" .And. ;
		aParam[nx][01] <> "MV_CTXJUST" .And. aParam[nx][01] <> "MV_CTINCON" .And. ;
		aParam[nx][01] <> "MV_ULTNSU"  .And. aParam[nx][01] <> "MV_MDEFLAG" )
		cMsg += "-> "+aParam[nx][2] + CRLF
	endif	
		
next 
if !empty( cMsg )
	cMsg := cMsgIni +cMsg+ cMsgFim
	lOk := .F.
endif

return ( lOk )


//-----------------------------------------------------------------------
/*/{Protheus.doc} ColGetPar
Funcao que pega o valor do parâmetro da tabela CKP passado.

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9

@param		cParam,string, Parametro a ser verificado.						
@param		[cDefault],string, Valor default caso não seja encontrado o parâmetro.<b>OPCIONAL
		
@return	cConteudo		Conteúdo do parâmetro consultado.
/*/
//-----------------------------------------------------------------------

function ColGetPar( cParam , cDefault )

Local cConteudo	:= ""
Local aArea		:= GetArea()

default cDefault := ""

cParam := PadR(UPPER(cParam),10)

CKP->(dbSetOrder(1))

If CKP->(dbSeek(xFilial("CKP")+cParam))
	cConteudo := AllTrim(CKP->CKP_VALOR)
Else
	cConteudo := cDefault
EndIf

RestArea(aArea)
Return( cConteudo )

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColSetPar
Funcao que atualiza o valor do parâmetro da tabela CKP passado.

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9

@param		cParam, string,	Parâmetro a ser consultado.
@param		cConteudo, string,Conteudo a ser atualizado
@param		cDescr, string,	Parâmetro a ser atualizado.
						  
@return	logico		Retorna .T. se atualizar com sucesso.
/*/
//-----------------------------------------------------------------------
function ColSetPar(cParam,cConteudo,cDescr)

Local aArea 	:= GetArea()
Local lUpd		:= .T.
Local lSeek 	:= .F. 

cParam := PadR(UPPER(cParam),10)

CKP->(dbSetOrder(1))

lSeek := CKP->(dbSeek(xFilial("CKP")+cParam)) 

Default cDescr	:= iif(lSeek,CKP->CKP_DESCRI,"")

if lSeek .And. Alltrim(cConteudo) == Alltrim( CKP->CKP_VALOR ) .And. Alltrim( cDescr ) == AllTrim(CKP->CKP_DESCRI)
	lUpd := .F.
endif

if lUpd
	Begin Transaction
	
	If lSeek
		RecLock("CKP",.F.)
	Else
		RecLock("CKP",.T.)
	EndIf
	
	CKP->CKP_FILIAL	:= xFilial("CKP")	
	CKP->CKP_PARAM	:= cParam
	CKP->CKP_VALOR	:= cConteudo
	CKP->CKP_DESCRI	:= cDescr
	
	End Transaction
	
endif

RestArea(aArea)

Return(.T.)


//-----------------------------------------------------------------------
/*/{Protheus.doc} ColParametros
Função genérica para criação da tela de parâmetros conforme o modelo passado.

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9

@param		cModelo,string,	Modelo desejado: <br>NFE - NF eletronica<br>CTE - CT eletronico<br>CCE - Carta de Correção Eletronica<br>MDE - Manifestação do Destinatário<br>MDFE - Manifesto de documentos fis. Eletr.<br>NFSE - NF de Serviço eletrônica.
						  
@return	Nil
/*/
//-----------------------------------------------------------------------

Function ColParametros( cModelo )

Local nX
Local nSizeJump	:= 15
Local nRowSay	:= 008   
Local nColSay	:= 006
Local nRowGet	:= 006
Local nColGet	:= 100
Local lCont	:= .F.

Local bBloco
Local bBlocoSay  
Local bFun		:= {||}

Local cPicture	:= "" 
Local cPerg		:= ""

Local xVar
Local aParam	:= ColListPar(cModelo)

Local oDlg  := Nil
Local oMainPanel
Local oScroll
Local oPanelPerg
Local oPanelButons
Local oEditControl

oMainWnd:ReadClientCoors()

DEFINE MSDIALOG oDlg TITLE "Parâmetros - TOTVS Colaboração 2.0 - " + cModelo FROM 0,0 TO 300,450 PIXEL OF oMainWnd//"Parâmetros"	

DEFINE FONT oFont BOLD

@00,00 MSPANEL oMainPanel SIZE 15,15 OF oDlg
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

oScroll := TScrollArea():New(oMainPanel,0,0,200,200)
oScroll:Align := CONTROL_ALIGN_TOP

@ 000, 000 MSPANEL oPanelPerg OF oScroll SIZE 200,200
oPanelPerg:Align := CONTROL_ALIGN_ALLCLIENT   	
oScroll:SetFrame(oPanelPerg)

@ 000, 000 MSPANEL oPanelButons OF oMainPanel SIZE 000,(oDlg:nHeight+20)-oDlg:nHeight
oPanelButons:Align := CONTROL_ALIGN_BOTTOM
	
For nX := 1 to len(aParam)
	If aParam[nX][5]		
		bBlocoSay 	:= &("{ | u | If( PCount() == 0, aParam[" + AllTrim(Str(nX)) + "][02], aParam[" + AllTrim(Str(nX)) + "][02] := u ) }")
		bBloco 		:= &("{ | u | If( PCount() == 0, aParam[" + AllTrim(Str(nX)) + "][04], aParam[" + AllTrim(Str(nX)) + "][04] := u ) }")		
		
		If ( ValType(aParam[nX][04]) == "N" )
			cPicture := "@E " + Replicate("9",Len(aParam[nX][04]))
		Else
			cPicture := ""
		EndIf
	  
		oSay := TSay():New( nRowSay, nColSay, bBlocoSay, oPanelPerg,,,,,,.T.,CLR_HBLUE,, 100, 008)
		
		If  aParam[nx][1] == "MV_AMBIENT"
			 aParam[nX][04] := ColGetPar("MV_AMBIENT","2")
		Endif 
		If ( ValType(aParam[nx][03]) == "A" )			
			oEditControl := TComboBox():New(nRowGet, nColGet, bBloco, aParam[nx][03], 120, 008, oPanelPerg,,,,,,.T.,,,,,,,,,aParam[nX][04])		
		Else
			oEditControl := TGet():New( nRowGet, nColGet, bBloco, oPanelPerg, 120, 008,cPicture, ,,,,,,.T.)
		EndIf
		
		nRowSay	:= nRowSay + nSizeJump  
		nRowGet	:= nRowGet + nSizeJump

	endif  		                                                                     		
	
Next nX

oMainWnd:CoorsUpdate()

oBtnOk 		:= TButton():New( 001, oPanelButons:NCLIENTWIDTH-313, "Confirmar", oPanelButons,{|| ColPutArrParam(aParam),ColConfCont(cModelo),oDlg:end() }, 040, 017,,oFont,, .T.) //"Confirmar"
oBtnCancel 	:= TButton():New( 001, oPanelButons:NCLIENTWIDTH-270, "Cancelar", oPanelButons,{|| oDlg:end() }, 040, 017,,oFont,, .T.) //"Cancelar"

ACTIVATE MSDIALOG oDlg CENTERED

//oBtnOk:setCSS( STYLE_BTN_COMFIRM )
//oBtnCancel:setCSS( STYLE_BTN_COMFIRM )

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColDescOpcao
Funcao que busca a descrição da opção passada para um parâmetro.

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9

@param		cParam,string,		Parâmetro a ser verificado.
@param		cVal,string,			Valor da opção que deseja retornar.
						  
@return	cDescri				Descrição do parâmetro passado.
/*/
//-----------------------------------------------------------------------
function ColDescOpcao( cParam, cVal )

local cDescri := ""

local nRet		:= 0
local nX		:= 0

aParam := ColListPar("ALL")
	
nRet := aScan( aParam,{|x| x[1] == cParam } )
	
if nRet > 0
	For nX := 1 to len(aParam[nRet][03])
		if  cVal == ( SubStr(aParam[nRet][03][nx],1,1) )
			cDescri := StrTran(aParam[nRet][03][nx],cVal+"=")
		endif 
	Next
endif
	
return( cDescri )

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColCheckQueue
Verifica se existe o Queue passado pela função.

@param		cQueue,string,	Parâmetro a ser verificado.
						  
@return	lExiste			.T. Se existir.

@author	Rafael Iaquinto
@since		21/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColCheckQueue(cQueue)

local nx := 0
local lExiste	:= .F.

aListQueue	:= ColListQueue()

for nx := 1 to len(aListQueue)
	if aScan(aListQueue[nX],{ |x| x ==  cQueue }) > 0
		lExiste := .T.
		exit
	endif
next	

return lExiste


//-----------------------------------------------------------------------
/*/{Protheus.doc} ColCKQStatus
Função que devolve os códigos e Descrições dos Status da CKQ.

@return	aCKNStatus		Lista dos coidgos e descrições do status:<br>[1]Codigo do Status<br>[2]Descrição do Status.

@author	Rafael Iaquinto
@since		21/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColCKQStatus()

local aCKNStatus := {}

aadd(aCKNStatus, {"1","Enviado"})
aadd(aCKNStatus, {"2","Retornado"})
aadd(aCKNStatus, {"3","Rejeitado"})

return aCKNStatus
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColCKOStatus
Função que devolve os códigos e Descrições dos Status da CKO.

						  
@return	aStatus	Lista dos coidgos e descrições do status:<br>[1]Codigo do Status<br>[2]Descrição do Status.

@author	Rafael Iaquinto
@since		21/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColCKOStatus()

local ACKNSTATUS := {}

aadd(aCKNStatus, {"1","Arquivo gerado"})
aadd(aCKNStatus, {"2","Arquivo Retornado com sucesso"})
aadd(aCKNStatus, {"3","Arquivo com erro no envio"})


return aCKNStatus


//-----------------------------------------------------------------------
/*/{Protheus.doc} ColModelos
Função que devolve o array de modelos disponíveis no TOTVS Colaboração.
						  
@return	aModelos		Array com o codigo do modelo e descrição.<br>[1] - Codigo do modelo<br>[2] - Descrição do Modelo.						

@author	Rafael Iaquinto
@since		21/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColModelos()

local aModelos := {}

aadd(aModelos,{"NFE","Nota Fiscal Eletrônica"})
aadd(aModelos,{"CTE","Controle de Transporte eletrônico"})
aadd(aModelos,{"MDE","Manifestação do Destinatário"})
aadd(aModelos,{"MDF","Manifestação de Documentos Fiscais"})
aadd(aModelos,{"CCE","Carta de correção eletrônica"})
aadd(aModelos,{"EDI","Documentos de EDI - Pedidos,Espelho de nota e Programação de Entrega"})
aadd(aModelos,{"NFS","Nota Fiscal de Serviços Eletrônica"})
aadd(aModelos,{"ICC","Inclusão de condutor"})
aadd(aModelos,{"EPP","Pedido de prorrogação"})
aadd(aModelos,{"CEC","Comprovante de entrega"})

return aModelos

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColcheckModelo
Função que verifica se o modelo passado existe.

@param		cModelo,string,Codigo do modelo a ser verificado.						  
						  
@return	lExiste		.T. se o codigo passado existir.					

@author	Rafael Iaquinto
@since		22/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColcheckModelo( cModelo )

local lExiste := .F.
local aModelos := ColModelos()

if ( ascan(aModelos,{|x| x[1] == cModelo}) ) > 0
	lExiste := .T.
endif 

return lExiste

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColGetHist
Função que busca o histórico de XMLs na tabela CKO, para documentos emitidos.

@param		cIdErp		IdERP do documento solicitado.						  				  
						  
@return	aHist		Array com os XML e alguns dados do arquivo.
						[1] - Nome do arquivo
						[2] - XML retornado
						[3] - XML enviado
						[4] - Data de retorno
						[5] - Hora de retorno	
						[6] - Status da CKO
						[7] - Descricao do STATUS
						[8] - Codigo do EDI				

@author	Rafael Iaquinto
@since		22/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColGetHist( cIdErp, cCodEdi )

local aHist	:= {}

local nOrder1	:= 0
local nRecno1	:= 0

nOrder1	:= CKO->( indexOrd() )
nRecno1	:= CKO->( recno() )

CKO->(dbSetOrder(3))

if CKO->(dbSeek( PADR(cIdErp,Len(CKO->CKO_IDERP)) ) )
	
	While !CKO->(Eof()) .And.  CKO->CKO_IDERP == PADR(cIdErp,Len(CKO->CKO_IDERP))      		
		if Empty(cCodEdi) .or. CKO->CKO_CODEDI == cCodEdi 
			aadd(aHist,{CKO->CKO_ARQUIV,;
						CKO->CKO_XMLRET,;
						CKO->CKO_XMLENV,;
						CKO->CKO_DT_RET,;
						CKO->CKO_HR_RET,;
						CKO->CKO_STATUS,;
						CKO->CKO_DESSTA,;
						CKO->CKO_CODEDI})
		endif			
		CKO->( dbSkip() )
	enddo
endif

CKO->( dbSetOrder( nOrder1 ) )	
CKO->( dbGoTo( nRecno1 ) )

return ( aHist )

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetHistCKQ
Função que busca o histórico de XMLs na tabela CKQ, para documentos emitidos.
@param		cIdErp		IdERP do documento solicitado.						  				  
@return	aHist		Array com os XML e alguns dados do arquivo.
						[1] - Nome do array Historico da CKQ
						[2] - lAchou - Encontrou o historico na tabela
						[3] - Filial
						[4] - Modelo do documento
						[5] - Tipo de movimento	
						[6] - Código usado no EDI Neogrid
						[7] - Nome do arquivo
						[8] - Descricao do STATUS
						[9] - Mensagens de retorno de processamento 
						[10]- Id do documento 
						[11]- Serie da nota
					    [12]- Número da nota
						[13]- Data da geração do arquivo
						[14]- Hora da geração do arquivo
						[15]- Ambiente de geração do arquivo
						[16]- Codigo de erro
						[17]- Filial de processamento 
@author	Cleiton Genuino
@since		28/08/2015
@version	11.9
/*/
//-----------------------------------------------------------------------
function GetHistCKQ( cIdErp, aHist )
local aHistRet	:= {}
local lAchou	:= .F.
local cFilCol	:= aHist [1]
local cMod		:= aHist [2]
local cTipoMov	:= aHist [3]
local cIdErp	:= aHist [4]
CKQ->(dbSetOrder(1))
if CKQ->(dbSeek( cFilCol+cMod+cTipoMov+cIdErp ) )
		lAchou	:= .T.	    		
			aadd(aHistRet,{"Historico da CKQ",;
							lAchou,;
							CKQ->CKQ_FILIAL,;
							CKQ->CKQ_MODELO,;
							CKQ->CKQ_TP_MOV,;
							CKQ->CKQ_CODEDI,;
							CKQ->CKQ_ARQUIV,;
							CKQ->CKQ_STATUS,;
							CKQ->CKQ_DESSTA,;
							CKQ->CKQ_IDERP,;
							CKQ->CKQ_SERIE,;
							CKQ->CKQ_NUMERO,;
							CKQ->CKQ_DT_GER,;
							CKQ->CKQ_HR_GER,;
							CKQ->CKQ_AMBIEN,;
							CKQ->CKQ_CODERR,;
							CKQ->CKQ_FILPRO})		
else
		aHistRet := {}
		aAdd (aHistRet,{	"Historico da CKQ",;
							lAchou,;					
							FwCodFil(),;
							cMod,;
							cTipoMov,;
							"",;
							"",;
							"2"})
endif
return ( aHistRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} ColListaDocumentos
Funcao que retorna os nomes dos arquivos da consulta realizada


@param		cQueue			Codigo Queue (Edi)
			cFlag			Registro ja foi listado
			dDataRet		Data do periodo a ser listado

@return	aNomeArq		Lista com os nomes dos documentos

@author	Douglas Parreja
@since		23/07/2014
@version	11.9
/*/
//-------------------------------------------------------------------
Function ColListaDocumentos( cQueue , cFlag , dDataRet )

	Local cSeek			:= ""
	Local cCondicao		:= ""
	Local lValido			:= .F.
	Local aNomeArq		:= {}
	Local aArea     		:= GetArea()
	Local nCmpEdi			:= Len(CKO->CKO_CODEDI)
	Local nCmpFlag		:= Len(CKO->CKO_FLAG)
	
	Default cQueue 	:= ""
	Default cFlag		:= ""
	
	cQueue	:= PadR(cQueue,nCmpEdi)
	cFlag 	:= PadR(cFlag,nCmpFlag)
	
	If empty(dDataRet)
		cSeek := cQueue + cFlag
		cCondicao := "(CKO->CKO_CODEDI == '" + cQueue + "') .And. (CKO->CKO_FLAG == '" + cFlag + "')"
	Else
		cSeek := cQueue + cFlag + DTOS(dDataRet)
		cCondicao := "(CKO->CKO_CODEDI == '" + cQueue + "') .And. (CKO->CKO_FLAG == '" + cFlag + "')  .And. (CKO->CKO_DT_RET >= STOD('" + DTOS(dDataRet) + "') )"
	EndIf

	CKO->( dbSetOrder( 4 ) ) //"CKO_CODEDI+CKO_FLAG+DTOS(CKO_DT_RET)"
	
	If CKO->( dbSeek( cSeek ) )
		lValido := .T.

		If lValido
			
			While !CKO->(Eof()) .And.  &( cCondicao ) 
				aadd(aNomeArq,{	CKO->CKO_ARQUIV,;
									CKO->CKO_STATUS,;
									CKO->CKO_DT_RET,;
									CKO->CKO_HR_RET})
				CKO->(dbSkip())
			EndDo

		EndIf
	EndIf
	
	RestArea(aArea)

Return aNomeArq
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColGeraArquivo
Função que realiza a geração do arquivo efetivamente no diretório IN do 
integrador da NeoGrid.

@param		cDirOut	Diretório de gravação						  
@param		cNomeArq	Nome do arquivo, opcional caso não seja passado será
						atribuido nesta função.						  
@param		cQueue		Deve ser passado, nos casos do nome do arquivo não
						for passado.
@param		cConteudo	Conteúdo do arquivo que será gerado.						  											  
@param		cMsg		Irá retornar a mensagem de erro caso não consiga criar
						o arquivo no diretório.						  
						  
@return	lGerado	.T. se o arquivo for gerado com sucesso.					

@author	Rafael Iaquinto
@since		22/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColGeraArquivo( cDirOut, cNomeArq , cQueue , cConteudo , cMsg )

local cBarra		:= If(isSrvUnix(),"/","\")
local lGerado		:= .T.
local nHandle		:= 0
local cName		:= ""
local lArqExist	:= .T.

default cNomeArq := ""

if empty( cNomeArq )
	While lArqExist
		
	cNomeArq :=  Alltrim( cQueue + "_"	) + FWTimeStamp() + StrZero( Randomize(0,999),3 ) + "_0001.xml"
		
		lArqExist := ColExistArq(cNomeArq)
		
		if lArqExist
			conout("[ColGeraArquivo] Arquivo de nome " + cNomeArq + " já existe. Será gerado um novo nome.")
			Sleep(1000)
		endif
	end
endif

if SubStr( cDirOut, Len(cDirOut) )<> cBarra
	cName := cDirOut+cBarra+cNomeArq
else
	cName := cDirOut+cNomeArq
endif

nHandle := FCreate(cName)

if nHandle < 0
	cMsg := Alltrim( Str(Ferror()) )		
	lGerado	:= .F.
else
	FWrite( nHandle, cConteudo )   
	FClose(nHandle)
endif

return lGerado

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColGetErro
Função que devolve o erro e deescrição.

@param		nPos, numérico,Posição do erro desejado no array.
						  
@return	aCodErro	Array com o codigo e descrição do erro.
						[1] - Codigo do erro
						[2] - Descrição do erro.	

@author	Rafael Iaquinto
@since		21/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColGetErro(nPos)

local aCodErro	:= {}
local aCodigos	:= {}

aadd(aCodigos, {"001","Algum dos valores não foram passados. ( Modelo - Tipo de Movimento - XML - Queue )"})
aadd(aCodigos, {"002","ID ERP deve ser enviado quando se tratar de emissão!"})
aadd(aCodigos, {"003","Não foi possível criar o diretório no servidor! "})
aadd(aCodigos, {"004/025","Mesmo documento ainda está aguardando o processamento, verificar se os arquivos estão sendo processados corretamente."})
aadd(aCodigos, {"005","Número de Queue não encontrado."})
aadd(aCodigos, {"006","Modelo passado não foi encontrado."})
aadd(aCodigos, {"007","Não foi possível criar o arquivo no diretório. "})
aadd(aCodigos, {"008","Valor não passado. ( Tipo de Movimento )"})
aadd(aCodigos, {"009","Os valores não foram passados. ( Modelo - ID do ERP"})
aadd(aCodigos, {"010","Valor não passado. ( Modelo do Documento )"})
aadd(aCodigos, {"011","Os valores não foram passados. ( Código Queue - Flag - Data de Retorno"})
aadd(aCodigos, {"012","Valor não passado. ( Nome do Arquivo )"})
aadd(aCodigos, {"013","Valor não passado. ( Código Queue )"})
aadd(aCodigos, {"014","Valor não passado. ( Flag )"})
aadd(aCodigos, {"015","Nome de arquivo não encontardo."})
aadd(aCodigos, {"016","O atributo lHistorico deve estar como .T. para o uso do Método"})
aadd(aCodigos, {"017","Método disponível somente para documentos do tipo 1-Emissão"})
aadd(aCodigos, {"018","Para consulta do histórico é necessário passar o ID do ERP."})
aadd(aCodigos, {"019","Flag passado é inválido, valores aceitos 1 - Flegado ou 2 - Não Flegado."})
aadd(aCodigos, {"020","Documento não encontrado, verifique os valores passados."})
aadd(aCodigos, {"021","Não foi possível realizar a transmissão, documento já autorizado."})
aadd(aCodigos, {"022","Autorizado operação em Contingência, por gentileza Cancele o documento transmitido e gere um novo em Contingência"})//VERIFICAR
aadd(aCodigos, {"023","Data e hora incial devem ser passados."})


if Len(aCodigos) >= nPos
 if IsBlind()
 		aCodigos[nPos][2] := NoAcento(aCodigos[nPos][2])
 endif
	aCodErro	:= aCodigos[nPos]
else
	aCodErro	:= {"",""}
endif

return aCodErro

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColDadosXMl
Realiza o parser no XML passado e devolve os valores nas posições correspondentes passadas em aDados. Não busca valores com mais de uma ocorreência.
 
@author 	Rafel Iaquinto
@since 		28/07/2014
@version 	11.9
 
@param	cXml, string, XML do documento.
@param aDados, string, Array de uma dimensão onde cada posição será o caminho no XML que desja que retorne. Separado por pipe "|". Ex: NFEPROC|PROTNFE|INFPROT|CHNFE.<br>Caso a tag não exista ou não seja encontrada será retornado vazio.
@param @cErro, setring, Variável para retornar erro de parser.
@param @cAviso, string, Variável para retornar aviso de parser.

 
@return aRetorno Array de retorno, com os valores solicitados sempre em caracter.
/*/
//-----------------------------------------------------------------------
function ColDadosXMl(cXml, aDados, cErro, cAviso)
local aRetorno := {}
local cPosXMl	 := ""

local nX	:= 0

private oXMl := Nil

default cXml := ""
default aDados := {}
default cErro := ""
default cAviso := ""

if len( aDados ) > 0 
	cXml := XmlClean(cXml)
	
	oXml := XmlParser(encodeUTF8(cXml),"_",@cAviso,@cErro)
	
	if oXml == nil
		oXml := XmlParser(cXml,"_",@cAviso,@cErro) 
	endif
	
	if Empty(cAviso + cErro )
		
		for nX := 1 to Len(aDados)
			cPosXMl := ""
			cPosXMl := StrTran( aDados[nX] , "|" , ":_")
			
			if SubStr(cPosXml,len(cPosXml)-1,2) == ":_"
				cPosXml := SubStr(cPosXml,1,len(cPosXml)-2) 
			endif
			
			cPosXMl := "oXml:_"+cPosXml+":TEXT"
			
			if Type(cPosXMl) <> "U"
				aadd(aRetorno, &(cPosXMl))
			else
				aadd(aRetorno,"")
			endif	

		Next
		
	endif
	
else
	cErro := "Deve ser passado pelo menos uma posição nos dados"
endif

oXml	:= Nil
DelClassIntF()

return aRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} colNfeMonProc
Realiza o processamento do monitor da NFe e CT-e, conforme solicitado pelo ERP.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 
@param	aParam, array,Parametro para a busca dos docuemtnos no TSS, de acordo com o tipo nTpMonitor						
@param	nTpMonitor, inteiro,	Tipo do monitor: 1 - Faixa - 2 - Por Id.(Não desenvolveido por tempo)
@param	cModelo, string, modelo do documento(55 ou 57) 
@param	lCte,lógico, indica se o modelo é Cte			
@param	@cAviso,string, Retorna mensagem em caso de erro no processamento.

@return aRetorno Array de retorno com os dados do documento.
/*/
//-----------------------------------------------------------------------
function colNfeMonProc( aParam, nTpMonitor, cModelo, lCte, cAviso, lMDfe, lTMS ,lUsaColab)
	
	local aRetorno		:= {} 
	local aLote			:= {}
	local aDados			:= {}		
	local aDadosCanc		:= {}
	local aDadEnvCan   	:= {}
	local aDadosInut		:= {}
	local aDocs			:= {}
	local aXMLInf			:= {}
	local aParamBkp		:= Aclone(aParam)
	
	local cId				:= ""
	local cSerie 			:= ""
	local cNota			:= ""
	local cProtocolo		:= ""	
	local cRetCodNfe		:= ""
	local cMsgRetNfe		:= ""
	local cRecomendacao	:= ""
	local cTempoDeEspera	:= ""
	local cErro			:= ""	
	local cXml				:= ""
	local cXmlHist		:= ""
	local cDpecXml		:= ""
	local cDpecProtocolo	:= ""
	local cDtHrRec1		:= ""
	local cCodEdi			:= ""
	local cCodEdiCanc		:= ""
	local cCodEdiInut		:= ""
	local cMsgSef			:= ""
	local cRetCSTAT		:= ""
	local cRetMSG			:= ""

	local dDtRecib		:= CToD("")
	
	local lOk				:= .F.
	local lUpd				:= .F.	

	local nX				:= 0
	local nY				:= 0
	local nTamF2_DOC		:= tamSX3("F2_DOC")[1]
	local nTamF2_SER		:= tamSX3("F2_SERIE")[1]
	local nTamF2_FIL		:= tamSX3("F2_FILIAL")[1]
	local nAmbiente		:= 0
	local nModalidade		:= 0
	local nTempoMedioSef	:= 0
	local nIntervalo		:= 0
	
	local lCTECan			:= SuperGetMv( "MV_CTECAN", .F., .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
	local lRtCTeId			:= SuperGetMv( "MV_RTCTEID", .F., .F. ) //-- Habilita o botão Retorno de Status
	local cIdTMS			:= ''
	local cFilOri			:= ''
	local cSerTMS 			:= ''
	local cDocTMS			:= ''
	local lretUpdCte 		:= ExistFunc( "retUpdCte" )

	private oDoc			:= nil

	default cModelo		:= "55"
	default cAviso		:= ""
	default lCte			:= .F.
	default lMDfe		:= .F.
	default lTMS		:= .F.
	default lUsaColab	:= UsaColaboracao("1")	
		
	//Monitor por Range de notas
	if nTpMonitor == 1
		
		if 	aParam[03] >= aParam[02] 	
			
			aDocs := ColRangeMnt( IIf(lMDfe,"MDF","")+aParam[01]+aParam[02]+ FwGrpCompany()+FwCodFil() , IIf(lMDfe,"MDF","")+aParam[01]+aParam[03]+ FwGrpCompany()+FwCodFil() , iif(cModelo=="55","NFE", iif(cModelo=="57","CTE","MDF")))
			lOk := .T.	
		else
			cAviso	:= "Parâmetros inseridos são inválidos. Nota inicial superior que nota final."
			lOk := .F.
		endif
	
	//monitor por lote de Id
	elseif nTpMonitor == 2
				
		for nX := 1 to len(aParam)
			aadd(aDocs,aParam[nX][1]+ FwGrpCompany()+FwCodFil() )			
		next 
		if Len( aDocs ) > 0
			lOk := .T.			
		else
			cAviso	:= "Parâmetros inseridos são inválidos. Não foi passado nanhum documento para monitoramento."
			lOk := .F.
		endif
	else 
		if valType(aParam[01]) == "N"
			nIntervalo := max((aParam[01]),60)
		else
			nIntervalo := max(val(aParam[01]),60)
		endIf					
		aDocs := ColTimeMnt( nIntervalo, iif(cModelo=="55","NFE","CTE") )
		if Len( aDocs ) > 0
			lOk := .T.	
		endif
	endif
	
	if lOk
		
		//Define o aDados para busca do XML conforme o modelo e tipo de operacao
		if lCte
			
			cCodEdi			:= "199"
			cCodEdiCanc		:= "200"
			cCodEdiInut		:= "201"
			
			aDados 	:= ColDadosNf(1,"57")
			aDadosCanc	:= ColDadosNf(2,"57")
			aDadEnvCan	:= ColDadosNf(4,"57")
			aDadosInut	:= ColDadosNf(3,"57")						
				
		elseIf lMDfe

			cCodEdi		:= "360"
			cCodEdiCanc	:= "362"
			cCodEdiInut	:= "361"

			aDados		:= ColDadosNf(1,"58",lTMS)
			aDadosCanc	:= ColDadosNf(2,"58",lTMS)
			aDadosInut	:= ColDadosNf(3,"58",lTMS)
		else
		
				cCodEdi		:= "170"
				cCodEdiCanc	:= "171"
				cCodEdiInut	:= "172"
			
				aDados		:= ColDadosNf(1,"55")
				aDadosCanc	:= ColDadosNf(2,"55")
				aDadosInut	:= ColDadosNf(3,"55")

		endif
		
		for nx := 1 to Len( aDocs )
			
			oDoc 			:= ColaboracaoDocumentos():new()		
			oDoc:cModelo	:= iif(cModelo=="55","NFE",iif(cModelo=="58","MDF","CTE"))
			oDoc:cTipoMov	:= "1"									
			oDoc:cIDERP	:= aDocs[nX]
			
			if odoc:consultar()
				oDoc:lHistorico	:= .T.	
				oDoc:buscahistorico()
				
				lUpd		:= .T.
				aDadosXml	:= {}
				cErro		:= ""
				cAviso		:= ""
				cXml		:= ""
				cDpecXml	:= ""
				cProtDepec := ""
				nAmbiente	:= 0
				aXMLInf	:= {}
				
				if !Empty(oDoc:cXMLRet)
					cXml	:= oDoc:cXMLRet 
				else
					cXml	:= oDoc:cXml
				endif
												
				do case 
					case oDoc:cQueue == cCodEdi
						aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)
						cRetCSTAT	:= aDadosXml[1]  		
						
					case oDoc:cQueue == cCodEdiCanc
						aDadosXml := ColDadosXMl(cXml, aDadosCanc, @cErro, @cAviso)
						cRetCSTAT	:= IIf(aDadosXml[1]=="135" , "101" , aDadosXml[1] ) 
						
						If (lCTECan .And. lRtCTeId .And. lCte .And. cRetCSTAT $ '220')
							cIdTMS			:= IIf(lMDfe, 'MDF' + SubStr(oDoc:cIdErp,IIf(lMDfe,4,1),nTamF2_SER+nTamF2_DOC+nTamF2_FIL+1),SubStr(oDoc:cIdErp,IIf(lMDfe,4,1),nTamF2_SER+nTamF2_DOC+nTamF2_FIL+1))
							cFilOri			:= padr( substr(cIdTMS, nTamF2_DOC + nTamF2_SER+len(cEmpAnt)+1 ), nTamF2_FIL )
							cSerTMS 		:= IIf(lMDfe, substr(cIdTMS, 4, nTamF2_SER) ,substr(cIdTMS, 1, nTamF2_SER))
							cDocTMS			:= IIf(lMDfe, padr( substr(cIdTMS, 7 ), nTamF2_DOC ) ,padr( substr(cIdTMS, nTamF2_SER+1 ), nTamF2_DOC ))						
							If lretUpdCte
								lUpd 		:= retUpdCte(cFilOri,cDocTMS,cSerTMS,cRetCSTAT) 
							EndIf
						EndIf
					
					case oDoc:cQueue == cCodEdiInut
						aDadosXml := ColDadosXMl(cXml, aDadosInut, @cErro, @cAviso) 
						cRetCSTAT	:= IIf (aDadosXml[1]=="135" , IIf(lMDfe, "132", "102") , aDadosXml[1] )
				end
				
				if '<obsCont xCampo="nRegDPEC">' $ cXml
					cProtDepec := SubStr(cXml,At('<obsCont xCampo="nRegDPEC"><xTexto>',cXml)+35,15)
					aDadosXml[09] := cProtDepec
				endif	 
				
				cId				:= IIf(lMDfe, 'MDF' + SubStr(oDoc:cIdErp,IIf(lMDfe,4,1),nTamF2_SER+nTamF2_DOC),SubStr(oDoc:cIdErp,IIf(lMDfe,4,1),nTamF2_SER+nTamF2_DOC))
				cSerie 		:= IIf(lMDfe, substr(cId, 4, nTamF2_SER) ,substr(cId, 1, nTamF2_SER))
				cNota			:= IIf(lMDfe, padr( substr(cId, 7 ), nTamF2_DOC ) ,padr( substr(cId, nTamF2_SER+1 ), nTamF2_DOC ))						
				cProtocolo		:= Iif(!Empty(aDadosXml[3]),aDadosXml[3],aDadosXml[9])
		 		//Para cancelamento e inutilização o modalidade considerado é sempre o NORMAL
		 		if oDoc:cQueue $ cCodEdiCanc+"|"+cCodEdiInut
		 			nModalidade	:= 1
		 		else
		 			nModalidade	:= iif(!Empty(aDadosXml[5]),Val( aDadosXml[5] ),Val( aDadosXml[7] ) )	
		 		endif
		 			nAmbiente		:= iif(!Empty(aDadosXml[6]),Val( aDadosXml[6] ), Val( aDadosXml[8] ) )
		 		cRetCodNfe		:= cRetCSTAT 
				cMsgRetNfe		:= Iif(cRetCSTAT<>"101",iif(DecodeUtf8(aDadosXml[2])<> nil ,PadR(DecodeUtf8(aDadosXml[2]),100),PadR(aDadosXml[2],100)),"Cancelamento de NF-e homologado")
		 		cTempoDeEspera:= 0
				nTempoMedioSef:= 0
				cDtHrRec1		:= SubStr(aDadosXml[4],12)
				dDtRecib		:= SToD(StrTran(SubStr(aDadosXml[4],1,10),"-",""))
								
				//Ordena o a Historico para trazer o mais recente primeiro.
				aSort(oDoc:aHistorico,,,{|x,y| ( if( Empty(x[4]),"99/99/9999",DToC(x[4])) +x[5] > if(empty(y[4]),"99/99/9999",DToC(x[4]))+y[5])})
				
				
				//Processa o histórico para obter os dados dos lotes transmitidos para o documento 
				aLote := {}
				for ny := 1 to Len( oDoc:aHistorico )
					//Só considera o que for Autorização|Cancelamento|Inutilização
					if oDoc:aHistorico[ny][8] $ cCodEdi+"|"+cCodEdiCanc+"|"+cCodEdiInut
						aDadosXml	:= {}
						cErro		:= ""
						cAviso		:= ""
						cXmlHist	:= ""
						cDpecProtocolo := ""					
						
						if !Empty(oDoc:aHistorico[ny][2])
							cXMLHist	:= oDoc:aHistorico[ny][2] 
						else
							cXMLHist	:= oDoc:aHistorico[ny][3]
						endif
																
						do case 
							case oDoc:aHistorico[ny][08] == cCodEdi     // 170 - Codigo EDI NF-e Emissão
								aDadosXml := ColDadosXMl(cXMLHist, aDados, @cErro, @cAviso)
										
							case oDoc:aHistorico[ny][08] == cCodEdiCanc // 171 - Codigo EDI Cancelamento
								aDadosXml := ColDadosXMl(cXMLHist, aDadosCanc, @cErro, @cAviso)
								
							case oDoc:aHistorico[ny][08] == cCodEdiInut // 172 - Codigo EDI inutilização
								aDadosXml := ColDadosXMl(cXMLHist, aDadosInut, @cErro, @cAviso) 
						end					
						
						if Empty(cErro + cAviso)							
							
							if '<obsCont xCampo="nRegDPEC">' $ cXml
								cDpecProtocolo := SubStr(cXml,At('<obsCont xCampo="nRegDPEC"><xTexto>',cXml)+35,15)
								aDadosXml[09] := cDpecProtocolo
							endif	 
							
							aadd(aLote,{	0,;//Numero Lote - Não tem no XML da NeoGrid.
										oDoc:aHistorico[nY][4],; //Data do Lote - não tem no XML da NeoGrid - pegar do odoc:aHistorico[ny][4]
					 					oDoc:aHistorico[nY][5],; //Hora do Lote - não tem no XML da NeoGrid - pegar do odoc:aHistorico[ny][5]
										0,; //Numero Recibo da Sefaz - Não tem no XML da NeoGrid. O controle de lote é relaizado por eles.
					 					odoc:aHistorico[ny][6],; //Codigo do envio do Lote -não tem no XML da NeoGrid - Usar do odoc:aHistorico[ny][6](CKO)
					 					padr(Alltrim(odoc:aHistorico[ny][7])+" - "+ oDoc:aHistorico[ny][01],100),; //mensagem do envio dolote - não tem no XML da NeoGrid - Usar do odoc:aHistorico[ny][7](CKO)
					 					"",; //Codigo do recibo do lote - Não tem no XML da SEFAZ -  Usar do odoc:aHistorico[ny][6](CKO)
					 					"",;//Mensagem do Recibo do Lote - Não tem no XML da NeoGrid
					 					aDadosXml[01],; //Codigo de retorno da NFe - Pegar do XML da NeoGrid.
					 					IIf ((DecodeUtf8(aDadosXml[02])<> Nil),DecodeUtf8(padr(aDadosXml[02],150)),padr(aDadosXml[02],150)) }) // Mensagem de reotrno da NF-e - Pegar XML da NeoGrid
					 				
					 		
					 		//DPEC gera apenas 1 registro, com autorização do DPEC e com a autorização XML normal.
					 		//Devido a isso deve-se colocar mais uma posição no aLote, para demonstrar as duas autorizações.
							if !Empty(aDadosXml[09])
				 				cDpecProtocolo	:= 	aDadosXml[09] //Codigo do DPEC/EPEC
				 				cDpecXml			:= 	oDoc:aHistorico[ny][02] //XML do DPEC/EPEC
				 				
				 				//Só adiciona mais um registro nas mensagens se a nota já foi autorizada, 
				 				//caso contrário o add acima já está demonstrando o DPEC autorizado.				 				
				 				if !Empty(aDadosXml[3])
					 				aadd(aLote,{	0,;//Numero Lote - Não tem no XML da NeoGrid.
											oDoc:aHistorico[nY][4],; //Data do Lote - não tem no XML da NeoGrid - pegar do odoc:aHistorico[ny][4]
						 					oDoc:aHistorico[nY][5],; //Hora do Lote - não tem no XML da NeoGrid - pegar do odoc:aHistorico[ny][5]
											0,; //Numero Recibo da Sefaz - Não tem no XML da NeoGrid. O controle de lote é relaizado por eles.
						 					odoc:aHistorico[ny][6],; //Codigo do envio do Lote -não tem no XML da NeoGrid - Usar do odoc:aHistorico[ny][6](CKO)
						 					padr(Alltrim(odoc:aHistorico[ny][7])+" - "+ oDoc:aHistorico[ny][01],100),; //mensagem do envio dolote - não tem no XML da NeoGrid - Usar do odoc:aHistorico[ny][7](CKO)
						 					"",; //Codigo do recibo do lote - Não tem no XML da SEFAZ -  Usar do odoc:aHistorico[ny][6](CKO)
						 					"",;//Mensagem do Recibo do Lote - Não tem no XML da NeoGrid
						 					"124",; //Codigo de retorno da NFe - Pegar do XML da NeoGrid.
						 					"DPEC/EPEC recebido pelo Sistema de Contingência Eletrônica"; // Mensagem de reotrno da NF-e - Pegar XML da NeoGrid
						 				})
						 		endif
				 				
				 			endif
					 		
					 	endif
					 endif
				next nY
				
				//Dados da posição 15 do aretorno
				aadd(aXMLInf,cProtocolo)
				aadd(aXMLInf,cXml)
				aadd(aXMLInf,cDpecProtocolo)
				aadd(aXMLInf,cDpecXml)
				aadd(aXMLInf,cDtHrRec1)
				aadd(aXMLInf,dDtRecib)			
				aadd(aXMLInf,cRetCSTAT)
				aadd(aXMLInf,cMsgRetNfe)					
								 			
				
				cRecomendacao	:= colRecomendacao(cModelo,oDoc:cQueue,@cProtocolo,cDpecProtocolo,AllTrim(odoc:cCdStatDoc),aXMLInf [7],aXMLInf [8])
				
				If lCte .And. Substr(cRecomendacao, 1, 3) == "005" .And. nAmbiente = 0
					aDadosXml	:= ColDadosXMl(cXml, aDadEnvCan, @cErro, @cAviso) 
					nAmbiente	:= iif(!Empty(aDadosXml[6]),Val( aDadosXml[6] ), Val( aDadosXml[8] ) )
				EndIf

				//dados para atualização da base
				aadd(aRetorno, {	cId,;
									cSerie,;
									cNota,;
									cProtocolo,;	
									cRetCodNfe,;
									cMsgRetNfe,;
									nAmbiente,;
									nModalidade,;
									cRecomendacao,;
									cTempoDeEspera,;
									nTempomedioSef,;
									aLote,;
									lUpd,;
									.F.,;
									aXMLInf;						
									})
			endif
		Next Nx
		
		//atualiza a base e retorno
		colmonitorupd(aRetorno, lCte, lMDfe,lUsaColab)
		/*
		if len(aRetorno) > 0
			//busca informações complemetares para atualização da base atraves do metodo retornaNotas
				
			nCount:= getXmlNfe(cIdEnt,@aRetorno,if(lCTE,"57","") )
			
			while nCount > 0 .and. nCount <	 len(aRetorno)
				nCount+= getXmlNfe(cIdEnt,@aRetorno,if(lCTE,"57","") )
			EndDo 
	
			//atualiza a base e retorno
			monitorUpd(cIdEnt, aRetorno, lCte)
		endif
		*/
	endif

return( aRetorno )

//-----------------------------------------------------------------------
/*/{Protheus.doc} colNfsMonProc
Realiza o processamento do monitor da NFSe, conforme solicitado pelo ERP.
 
@author 	Flavio Luiz Vicco
@since 		20/08/2014
@version 	11.9
 
@param	aParam, array,Parametro para a busca dos documentos, de acordo com o tipo nTpMonitor						
@param	nTpMonitor, inteiro,	Tipo do monitor: 1 - Faixa - 2 - Por Id.(Não desenvolveido por tempo)
@param	cModelo, string, modelo do documento(56) 
@param	@cAviso,string, Retorna mensagem em caso de erro no processamento.

@return aRetorno Array de retorno com os dados do documento.
/*/
//-----------------------------------------------------------------------
function colNfsMonProc( aParam, nTpMonitor, cModelo, cAviso , lUsaColab )
	local aRetorno			:= {}
	local aLote				:= {}
	local aDados			:= {}
	local aDadosCanc		:= {}
	local aDadosInut		:= {}
	local aDocs				:= {}
	local aParamBkp			:= Aclone(aParam)
	local aDadosXml		:= {}
	
	local cId				:= ""
	local cSerie 			:= ""
	local cRPS	 			:= ""
	local cNota				:= ""
	local cProtocolo		:= ""
	local cCnpjForn			:= ""
	local cRetCodNfe		:= ""
	local cMsgRetNfe		:= ""
	local cRecomendacao		:= ""
	local cErro				:= ""
	local cXml				:= ""
	local cXmlHist			:= ""
	local cDpecXml			:= ""
	local cDpecProtocolo	:= ""
	local cDtHrRec1			:= ""
	local cCodEdi			:= ""
	local cCodEdiCanc		:= ""
	local cCodEdiInut		:= ""
	local cNomeArq		:= ""
	
	local dDtRecib	   		:= CToD("")
	
	local lOk				:= .F.

	local nX				:= 0
	local nY				:= 0
	local nTamF2_DOC		:= tamSX3("F2_DOC")[1]
	local nTamF2_SER		:= tamSX3("F2_SERIE")[1]
	local nTam_NFELE		:= tamSX3("F2_NFELETR")[1]
	local cAmbiente			:= SubStr(ColGetPar("MV_AMBINSE","2"),1,1)
	local nModalidade		:= 0

	private oDoc			:= nil
	private lUsaColab		:= UsaColaboracao("3")

	default cModelo			:= "56"
	default cAviso			:= ""

	//-- Monitor por Range de notas
	if nTpMonitor == 1
		if 	aParam[03] >= aParam[02]
			While aParam[02] <= aParam[03]
				aadd(aDocs,aParam[01]+aParam[02]+ FwGrpCompany()+FwCodFil() )
				aParam[02] := Padr(Soma1(AllTrim(aParam[02])),Len(aParam[03]))
			Enddo

			aParam := Aclone(aParamBkp)
			lOk := .T.
		else
			cAviso := "Parâmetros inseridos são inválidos. Nota inicial superior que nota final."
			lOk := .F.
		endif
			
	//-- monitor por lote de Id
	elseif nTpMonitor == 2
		for nX := 1 to len(aParam)
			aadd(aDocs,aParam[nX][1]+ FwGrpCompany()+FwCodFil() )
		next

		if Len( aDocs ) > 0
			lOk := .T.
		else
			cAviso	:= "Parâmetros inseridos são inválidos. Não foi passado nanhum documento para monitoramento."
			lOk := .F.
		endif
	endif
			
	if lOk
		//-- Define o aDados para busca do XML conforme o modelo e tipo de operacao
		cCodEdi		:= "203"
		cCodEdiCanc	:= "204"
		cCodEdiInut	:= "319"
		
		aDados		:= ColDadosNf(1,"56")
		aDadosCanc	:= ColDadosNf(2,"56")
		aDadosInut	:= ColDadosNf(3,"56")
				
		For Nx := 1 To Len( aDocs )
			oDoc 			:= ColaboracaoDocumentos():new()
			oDoc:cModelo	:= "NFS"
			oDoc:cTipoMov	:= "1"
			oDoc:cIDERP		:= alltrim (aDocs[nX])
			oDoc:cAmbiente	:= cAmbiente
		
			if odoc:consultar()
				oDoc:lHistorico	:= .T.
				odoc:buscahistorico()
		
				aDadosXml	:= {}
				cErro		:= ""
				cAviso		:= ""
				cXml		:= ""
				cDpecXml	:= ""
		
				if !Empty(oDoc:cXMLRet)
					cXml	:= oDoc:cXMLRet
				else
					cXml	:= oDoc:cXml
				endif
		
				do case
				case oDoc:cQueue == cCodEdi 		// 203 - NFS-e Emissão  Retorno da emissão de NFS-e
					aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)
				case oDoc:cQueue == cCodEdiCanc		// 204 - NFS-e Emissão  Retorno do cancelamento de NFS-e
					aDadosXml := ColDadosXMl(cXml, aDadosCanc, @cErro, @cAviso)

				ENDCASE
		
				cId				:= SubStr(oDoc:cIdErp,1,nTamF2_SER+nTamF2_DOC)
				cSerie			:= substr(cId, 1, nTamF2_SER)
				cRPS			:= padr( substr(cId, nTamF2_SER+1 ), nTamF2_DOC )
				cAmbiente		:= oDoc:cAmbiente
				nModalidade	:= 1 //-- 1-Normal
		
				If len (aDadosXml) > 0
					cNota			:= padr( aDadosXml[8], nTam_NFELE )
					cProtocolo		:= Iif(!Empty( aDadosXml[3] ),aDadosXml[3],aDadosXml[9])
					cRetCodNfe		:= aDadosXml[1] // CSTAT
					cMsgRetNfe		:= iif (DecodeUtf8(PadR(aDadosXml[2],150))== nil,PadR(aDadosXml[2],150),DecodeUtf8(PadR(aDadosXml[2],150))) //Descricao
					cDtHrRec1		:= SubStr(aDadosXml[4],12)
					dDtRecib		:= SToD(StrTran(SubStr(aDadosXml[4],1,10),"-",""))
					cCnpjForn		:= aDadosXml[10]
				EndIf
		
				//-- Ordena o a Historico para trazer o mais recente primeiro.
				//Retirada a ordenação, pois o ultimo registro é sempre o autorizado/ou a última tentativa. 
				//aSort(oDoc:aHistorico,,,{|x,y| ( if( Empty(x[4]),"99/99/9999",DToC(x[4]))+x[5] < if(Empty(y[4]),"99/99/9999",DToC(x[4]))+y[5])})

				//-- obtem dados dos lotes transmitidos para o documento
				aLote := {}
		
				//-- Processa o histórico
				for ny := 1 to Len( oDoc:aHistorico )
					//-- considera o que for Autorização|Cancelamento|Inutilização
					if oDoc:aHistorico[ny][8] $ cCodEdi+"|"+cCodEdiCanc+"|"+cCodEdiInut
						aDadosXml	:= {}
						cErro		:= ""
						cAviso		:= ""
						cXmlHist	:= ""
						cDpecProtocolo	:= ""
		
						if !Empty(oDoc:aHistorico[ny][2])
							cXMLHist	:= oDoc:aHistorico[ny][2]
						else
							cXMLHist	:= oDoc:aHistorico[ny][3]
						endif
		
						do case
						case oDoc:aHistorico[ny][08] == cCodEdi //203 - Emissão de RPS
							aDadosXml := ColDadosXMl(cXMLHist, aDados, @cErro, @cAviso)
						case oDoc:aHistorico[ny][08] == cCodEdiCanc //204 - Cancelamento de NFS-e
							aDadosXml := ColDadosXMl(cXMLHist, aDadosCanc, @cErro, @cAviso)
						end
		
						if Empty(cErro + cAviso)

							aadd(aLote,{	(aDadosXml[01]),;					//  1 - Codigo de retorno da NSFe - Pegar do XML da NeoGrid.
											cMsgRetNfe := iif (DecodeUtf8(PadR(aDadosXml[2],150))== nil,PadR(aDadosXml[2],150),DecodeUtf8(PadR(aDadosXml[2],150))),;	//  2 - Mensagem de retorno da NSF-e - Pegar XML da NeoGrid
											aDadosXml[03],;						//  3 - Numero Lote - Não tem no XML da NeoGrid.
											oDoc:aHistorico[nY][4],;			//  4 - Data do Lote - não tem no XML da NeoGrid - pegar do odoc:aHistorico[ny][4]
											oDoc:aHistorico[nY][5],;			//  5 - Hora do Lote - não tem no XML da NeoGrid - pegar do odoc:aHistorico[ny][5]
											aDadosXml[7]+aDadosXml[6],;			//  6 - Numero Recibo da Prefeitura - 	Tabela erros
											padr(odoc:aHistorico[ny][7],100),;	//  7 - mensagem do envio dolote - não tem no XML da NeoGrid - Usar do odoc:aHistorico[ny][7](CKO)
											oDoc:aHistorico[ny][1],;			//  8 - Nome do arquivo
											oDoc:cIDERP })						//  9 - Código de retorno ID (CKO - CKQ )
									
							if  !Empty(aDadosXml[01]) .AND. aDadosXml[01] <> "999" // Status de retorno valido XML único Neogrid
								cRetCSTAT  := aDadosXml[01]
											    cProtocolo := iif (Empty(aDadosXml[03]),aDadosXml[09],aDadosXml[03])//[09] - Código de VerificaNFSe | [03] - Protocolo

							else
								cRetCSTAT  := IIF (Empty(aDadosXml[01]),aDadosXml[01],"999")
								cProtocolo := ""
							endif
						endif
					endif
				next nY
		
				cRecomendacao := colRecomendacao(cModelo,oDoc:cQueue,@cProtocolo,cDpecProtocolo,AllTrim(odoc:cCdStatDoc),cRetCSTAT,cMsgRetNfe)


//		//Retorno Neogrid 100
//		If 		(cRetCodNfe $ "100")
//		 			cRetCodNfe := "111" // Emissao de Nota Autorizada
//		//Retorno Neogrid 101
//		ElseIf (cRetCodNfe $ "101")
//		 			cRetCodNfe := "333" // Cancelamento do RPS Autorizado
//		//Retorno Neogrid 999  - devolver o que vem da prefeitura
//		EndIf
				
				//-- dados para atualização da base
				aadd(aRetorno, {	cRetCodNfe,;
					cId,;
					Val(cAmbiente),;
					nModalidade,;
					cProtocolo,;
					PADR( cRecomendacao, 250 ),;
					cRPS,;
					cNota,;
					aLote })

			endif
				//Atualiza a base e retorno
				Fis022Upd(cProtocolo, cRPS, cSerie, cRecomendacao, cNota, cCnpjForn, dDtRecib, cDtHrRec1,/*cCodMun*/,/*lRegFin*/,/*aMsg*/,lUsaColab )

				//Ponto de entrada para o cliente customizar a gravação de
				//campos proprios no SF2/SF1 a partir do refreh no monitor de notas
				If ExistBlock("FCOLATUNF")
					ExecBlock("FCOLATUNF",.F.,.F.,{cSerie,cRPS,cProtocolo,cRPS,cNota,aDadosXml})
			endif
		Next Nx
	endif
return( aRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} colDtHrUTC
Retorna a Data e Hora no formato UTC

@param dData			Date: Data - YYYY-MM-DD

@param cHora			String: Hora - HH:MM:SS

@param cUF	,string, UF em que se deseja obter a hora 

@param lHVerao,lógico, Indica se iniciou o horario de verao

@return	cRetorno	AAAA-MM-DDTHH:MM:SS-TDZ, onde TDZ<br>-02:00 (Fernando de Noronha)<br>-03:00 (Brasilia)<br>-04:00 (Manaus), no horario de verao serao:<br>-01:00<br>-02:00<br>-03:00, respectivamente

@author Rafael Iaquinto
@since 08.11.2012
@version 12
/*/
//-------------------------------------------------------------------
Function colDtHrUTC(dData,cHora,cUF,lHVerao)

Local cRetorno		:= ""
Local aDataUTC		:= {}
Local cTDZ			:= ""
Local cHorario	:= colGetPar( "MV_HORARIO","2" )


Default dData		:= CToD("")
Default cHora		:= ""
Default cUF		:= Upper(Left(LTrim(SM0->M0_ESTENT),2))
Default lHVerao		:= ""

if lHVerao == ""
	lHVerao		:= iif( colGetPar( "MV_HRVERAO","2" ) == "1", .T., .F. )
endIf

If FindFunction( "FwTimeUF" ) .And. FindFunction( "FwGMTByUF" )

	// Tratamento para Fernando de Noronha
	If "1" $ cHorario
	
		cUF := "FERNANDO DE NORONHA"
	
	Endif	
	
	aDataUTC := FwTimeUF(cUF,,lHVerao)
	
	if empty(dData)
		dData := SToD( aDataUTC[ 1 ] )	
		If Empty( dData )
			dData := Date()
		Endif
	
		cHora := aDataUTC[ 2 ]	
		If Empty( cHora )
			cHora := Time()
		Endif	
	endif

	// Montagem da Data UTC
	cRetorno 	:= StrZero( Year( dData ), 4 )
	cRetorno 	+= "-"
	cRetorno 	+= Strzero( Month( dData ), 2 )
	cRetorno 	+= "-"
	cRetorno 	+= Strzero( Day( dData ), 2 )

	// Montagem da Hora UTC
	cRetorno += "T"
	cRetorno += cHora
	
	// Montagem do TDZ	
	cTDZ := Substr( Alltrim( FwGMTByUF( cUF ) ), 1, 6 )
	
	If !Empty( cTDZ )
	
		If lHVerao
		    
	   		cTDZ := StrTran( cTDZ, Substr( cTDZ, 3, 1 ), Str( Val( Substr( cTDZ, 3, 1 ) ) -1, 1 ) )
			
		Endif
		
		cRetorno += cTDZ

	Endif
	
Endif

Return( cRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} XMLRemCol
Funcao responsavel pela geracao do XML para TOTVS Colaboracao 


@param		cIdErp		Identificacao do arquivo (Serie+NF+Emp+Fil).
			cErro		Variável para retornar erro de parser.
			cXml		Xml do documento.
			cEntSai	Tipo de Movimento 1-Saida / 2-Recebimento.
			cSerie		Serie do documento.
			cNF			Numero do documento.
			cCliente	Codigo do Cliente no qual esta gerando documento.
			cLoja		Codigo da Loja no qual esta gerando documento.
			nXmlSize	Tamanho do Xml.
			nY			Herdado da funcao do SPEDNFE no qual identifica posicao do Array esta sendo gerado.
			aRetCol	Array com o retorno se foi gerado registro ou nao.

@return	lGerado	Retorna se o documento foi gerado.	

@author	Douglas Parreja
@since		25/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
Function XMLRemCol( cIdErp ,cErro , cXml , cEntSai , cSerie, cNF , cCliente , cLoja , nXmlSize , nY , aRetCol, cXmlRet ,lStop )
  
Local aRespNfe		:= {} 
Local aImpNFE		:= {}

Local cMail     	:= ""
Local cAviso    	:= ""					
Local cDpec	  		:= "" 
Local cModelo		:= ""  
Local cModalCTE		:= ""  
Local cChvCtg		:= ""

Local lNfeOk		:= .F.         
Local lGerado		:= .F.

Local nAmbiente		:= 0  
Local nTpEmisCte 		:= 0
Local cErroConv		:= ""

Private oDoc

Default cIdErp		:= ""
Default cErro			:= ""
Default cXml			:= ""
Default cEntSai		:= ""
Default cSerie		:= ""
Default cNF			:= ""
Default cCliente		:= ""
Default cLoja			:= ""
Default cXmlRet		:= ""

Default nXmlSize		:= 0
Default nY			:= 0 

Default aRetCol		:= {}
Default lStop        := .F.

nAmbiente   := Val(SubStr(ColGetPar("MV_AMBIENT","2"),1,1))

cDpec := cXml

If ( !Empty(cXml) .And. !Empty(cNF) )   
	lNfeOk	:= ColNfeConv(@cXml,cIdErp,@cMail,,@cErroConv,@cModelo,@aRespNfe,@aImpNFE,@cModalCTE,@nTpEmisCte)
	
	if lNfeOk
		cNewXML := encodeUTF8( XmlClean (cXml))
		oDoc := XmlParser(cNewXML,"_",@cAviso,@cErro)
		if oDoc == nil
		  	cErro 	:=  ErrNfeConv(oDoc,cXml,cNewXML,@cErroConv,.F.)
		   lNfeOk	:= .F.
		   lStop	:= .T.
		Endif
	else
		cErro := cErroConv
		lNfeOk := .F.
	endif

	If lNfeOk
		cXmlRet := cXml
	
		oTemp := ColaboracaoDocumentos():new()
		
		If Type("oDoc:_NFE:_INFNFE:_IDE:_MOD") <> "U"
			
			cCodMod := (oDoc:_NFE:_INFNFE:_IDE:_MOD:TEXT)				
			cDesMod := ModeloDoc(Alltrim(cCodMod))
			
			oTemp:cModelo 		:= cDesMod														// Modelo do Documento					
			oTemp:cNumero		:= StrZero(Val(oDoc:_NFE:_INFNFE:_IDE:_NNF:TEXT),9,0)	// Numero do Documento
			oTemp:cSerie		:= StrZero(Val(oDoc:_NFE:_INFNFE:_IDE:_SERIE:TEXT),3,0)	// Serie do Documento
			oTemp:cIdErp 		:= cIdErp														// ID Erp		
			oTemp:cXml			:= cXml															// XML
			oTemp:cTipoMov	:= "1"															// Tipo de Movimento 1-Saida / 2-Recebimento  
			oTemp:cQueue		:= "170"														// Codigo Queue (170 - Emissão de NF-e)
			oTemp:cAmbiente	:= SubStr(ColGetPar("MV_AMBIENT","2"),1,1)				// Ambiente NF-e Emissão  Emissão de NF-e

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Metodo Transmitir                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
			lGerado := oTemp:transmitir()
								
			If lGerado
				lAtuSF	:= ColAtuTrans( cEntSai , cSerie, cNF , cCliente , cLoja )
				If lAtuSF
					ColRetTrans( lGerado , nY , @aRetCol )
				EndIf
			Else	
				ColRetTrans( lGerado , nY , @aRetCol )	
			EndIf

		ElseIf Type("oDoc:_MDFE:_INFMDFE:_IDE:_MOD") <> "U"
			
			cCodMod := (oDoc:_MDFE:_INFMDFE:_IDE:_MOD:TEXT)
			cDesMod := ModeloDoc(Alltrim(cCodMod))
			
			oTemp:cModelo 		:= cDesMod													// Modelo do Documento
			oTemp:cNumero		:= StrZero(Val(oDoc:_MDFE:_INFMDFE:_IDE:_NMDF:TEXT),9,0)	// Numero do Documento
			oTemp:cSerie		:= oDoc:_MDFE:_INFMDFE:_IDE:_SERIE:TEXT						// Serie do Documento
			oTemp:cIdErp 		:= cIdErp													// ID Erp
			oTemp:cXml			:= cXml														// XML
			oTemp:cTipoMov		:= "1"														// Tipo de Movimento 1-Saida / 2-Recebimento
			oTemp:cQueue		:= "360"													// Codigo Queue (360 - Emissão de MDF-e)
			oTemp:cAmbiente	:= SubStr(ColGetPar("MV_AMBMDF","2"),1,1)						// Ambiente MDF-e Emissão  Emissão de MDF-e

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Metodo Transmitir                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lGerado := oTemp:transmitir()

			If lGerado
				lAtuSF	:= ColAtuTrans( cEntSai , cSerie, cNF , cCliente , cLoja )
				If lAtuSF
					ColRetTrans( lGerado , nY , @aRetCol )
				EndIf
			Else
				cErro := oTemp:cCodErr+ " - " + oTemp:cMsgErr
				ColRetTrans( lGerado , nY , @aRetCol  )			
			EndIf
		ElseIf Type("oDoc:_CTE:_INFCTE:_IDE:_MOD") <> "U"

			cCodMod := (oDoc:_CTE:_INFCTE:_IDE:_MOD:TEXT)
			cDesMod := ModeloDoc(Alltrim(cCodMod))
			
			oTemp:cModelo 		:= cDesMod														// Modelo do Documento					
			oTemp:cNumero		:= StrZero(Val(oDoc:_CTE:_INFCTE:_IDE:_NCT:TEXT),9,0)	// Numero do Documento
			oTemp:cSerie		:= StrZero(Val(oDoc:_CTE:_INFCTE:_IDE:_SERIE:TEXT),3,0) // Serie do Documento
			oTemp:cIdErp 		:= cIdErp														// ID Erp		
			oTemp:cXml			:= cXml															// XML
			oTemp:cTipoMov	:= "1"															// Tipo de Movimento 1-Saida / 2-Recebimento  
			oTemp:cQueue		:= "199"														// Codigo Queue (199 - Emissão de CT-e)
			oTemp:cAmbiente	:= SubStr(ColGetPar("MV_AMBCTE","2"),1,1)					// Ambiente MDF-e Emissão  Emissão de MDF-e

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Metodo Transmitir                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
			lGerado := oTemp:transmitir()
								
			If lGerado
				cChvCtg := SubStr(NfeIdSPED(cXML,"Id"),4)
				lAtuSF := ColAtuTrans( cEntSai , cSerie, cNF , cCliente , cLoja, .T., cChvCtg, nTpEmisCte )
				If lAtuSF
					ColRetTrans( lGerado , nY , @aRetCol )
				EndIf
			Else	
				ColRetTrans( lGerado , nY , @aRetCol  )			
			EndIf
		
		ElseIf Type("oDoc:_RPS:_IDENTIFICACAO:_TIPO") <> "U"
			cModelo := "56"
			cDesMod := ModeloDoc(Alltrim(cModelo))

			oTemp:cModelo 	:= cDesMod														// Modelo do Documento
			oTemp:cNumero	:= StrZero(Val(oDoc:_RPS:_IDENTIFICACAO:_NUMERORPS:TEXT),9,0)	// Numero do Documento
			oTemp:cSerie	:= oDoc:_RPS:_IDENTIFICACAO:_SERIERPS:TEXT						// Serie do Documento
			oTemp:cIdErp 	:= cIdErp														// ID Erp
			oTemp:cXml		:= cXml															// XML
			oTemp:cTipoMov	:= "1"															// Tipo de Movimento 1-Saida / 2-Recebimento
			oTemp:cQueue	:= "203"														// Codigo Queue (170 - Emissão de NFS-e)
			oTemp:cAmbiente	:= SubStr(ColGetPar("MV_AMBINSE","2"),1,1)						// Ambiente NFS-e Emissão  Emissão de NFS-e 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Metodo Transmitir                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lGerado := oTemp:transmitir()
			If lGerado
				lAtuSF := ColAtuTrans( cEntSai , cSerie, cNF , cCliente , cLoja, /*lCTe*/, /*cChvCtg*/, /*nTpEmisCte*/ , cModelo/*cModelo*/, /*lCanc*/  )
				If lAtuSF
					ColRetTrans( lGerado , nY , @aRetCol )
				EndIf
			Else
				ColRetTrans( lGerado , nY , @aRetCol  )
			EndIf

		ElseIf Type("oDoc:_RPS:_CANCELAMENTO:_MOTCANC") <> "U"

			cModelo := "56"
			cDesMod := ModeloDoc(Alltrim(cModelo))

			oTemp:cModelo 	:= cDesMod														// Modelo do Documento
			oTemp:cNumero	:= StrZero(Val(oDoc:_RPS:_CANCELAMENTO:_NUMERONFSE:TEXT),9,0)	// Numero do Documento
			oTemp:cIdErp 	:= cIdErp														// ID Erp
			oTemp:cXml		:= cXml															// XML
			oTemp:cTipoMov	:= "1"															// Tipo de Movimento 1-Saida / 2-Recebimento
			oTemp:cQueue	:= "204"														// Codigo Queue (204 - Cancelamento de NFS-e)
			oTemp:cAmbiente	:= SubStr(ColGetPar("MV_AMBINSE","2"),1,1)					   	// Ambiente NFS-e Emissão  Cancelamento de NFS-e  

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Metodo Transmitir                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lGerado := oTemp:transmitir()

			If lGerado
				lAtuSF := ColAtuTrans( cEntSai, cSerie, cNF , cCliente , cLoja, /*lCTe*/, /*cChvCtg*/, /*nTpEmisCte*/ , cModelo/*cModelo*/, .T. /*lCanc*/  )
				If lAtuSF
					ColRetTrans( lGerado , nY , @aRetCol )
				EndIf
			Else
				ColRetTrans( lGerado , nY , @aRetCol  )
			EndIf

		EndIf
		FreeObj(oTemp)
		oTemp := Nil
		DelClassIntf()
	EndIf
EndIf

nXmlSize := 0	//Zerando o tamanho do Xml para o proximo documento a ser gerado.

Return ( lGerado )

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColSeqCCe
Devolve o número da próxima sequencia para envio do evento de CC-e.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 
@param	aNFe, array, Array com os dados da NF-e.<br>[1] - Chave<br>[2] - Recno<br>[3] - Serie<br>[4] - Numero						

@return cSequencia string com as a sequencia que deve ser utilizada.
/*/
//-----------------------------------------------------------------------
function ColSeqCCe(aNFe)

local cModelo		:= "CCE"
local cErro		:= ""
local cAviso		:= ""
local cSequencia	:= "01"
local cXMl			:= ""
local lRetorno	:= .F.

local oDoc			:= nil
local aDados		:= {}
local aDadosXml	:= {}

oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov	:= "1"									
oDoc:cIDERP	:= aNfe[3] + aNfe[4] + FwGrpCompany()+FwCodFil()
oDoc:cMOdelo	:= cModelo

if odoc:consultar()
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NPROT")
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NSEQEVENTO")
	aadd(aDados,"ENVEVENTO|EVENTO|INFEVENTO|NSEQEVENTO")
	
	lRetorno := !Empty(oDoc:cXMlRet)
	
	if lRetorno
		cXml := oDoc:cXMLRet
	else
		cXml := oDoc:cXML
	endif
	
	aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)
	
	//Se ja foi autorizado pega o sequencial do XML de envio.
	if lRetorno
		if !Empty( aDadosXml[1] )
			cSequencia := StrZero(Val(Soma1(aDadosXml[2])),2)
		else
			cSequencia := StrZero(Val(aDadosXml[2]),2)
		endif	
	else
		cSequencia := StrZero(Val(aDadosXml[3]),2)
	endif	
	
else
	cSequencia := "01"
endif

oDoc := Nil
DelClassIntf()

return cSequencia

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColMonitCCe
Devolve as informações necessárias para montaro monitor do CC-e.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 
@param	cSerieDoc, string, Serie do documento desejado.						
@param	cDocNfe, string, Número do documento desejado.						
@param	@cErro, string, Referência para retornar erro no processamento.						

@return aDadosXml string com as informações necessárias para o monitor.<br>[1]-Protocolo<br>[2]-Id do CCE<br>[3]-Ambiente<br>[4]-Status evento<br>[5]-Status retorno transmissão
/*/
//-----------------------------------------------------------------------
function ColMonitCCe(cSerieDoc,cDocNfe,cErro,lCte)

local aDados		:= {}
local aDadosXML	:= {} 
local aDadosRet	:= {"","","","",""} 

local lRet			:= .F.
local cAviso		:= ""

local oDoc		:= Nil

Default lCte	:= .F.
If lCte
	aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|NPROT")
	aadd(aDados,"PROCEVENTOCTE|EVENTOCTE|INFEVENTO|ID")
	aadd(aDados,"EVENTOCTE|INFEVENTO|ID")
	aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|TPAMB")
	aadd(aDados,"EVENTOCTE|INFEVENTO|TPAMB")
	aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|CSTAT")
	aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|XMOTIVO")
Else
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NPROT")
	aadd(aDados,"PROCEVENTONFE|EVENTO|INFEVENTO|ID")
	aadd(aDados,"EVENTO|INFEVENTO|ID")
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|TPAMB")
	aadd(aDados,"EVENTO|INFEVENTO|TPAMB")
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|CSTAT")
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|XMOTIVO")
EndIf

oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov	:= "1"									
oDoc:cIDERP	:= cSerieDoc + cDocNfe + FwGrpCompany()+FwCodFil()
oDoc:cModelo	:= "CCE"

if odoc:consultar()
	if !Empty( oDoc:cXMLRet )
		cXML := oDoc:cXMLRet
		lRet := .T.	
	else
		cXML := oDoc:cXML
	endif 
	//Busca os dados no XML
	aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)		
		
	if lRet
		//Protocolo
		aDadosRet[1] := aDadosXml[1]
		//ID do CCE
		aDadosRet[2] := aDadosXml[2]
		//Ambiente
		aDadosRet[3] := aDadosXml[4]		
		//STATUS DO EVENTO
		if aDadosXml[4] == "493"			
			aDadosRet[4] := "3-Evento com falha no schema XML"
		elseif aDadosXml[6] == "135"
			aDadosRet[4] := "6-Evento vinculado"
		else
			aDadosRet[4] := "5-Evento com problemas"
		endif
		//Status retorno transmissão
		aDadosRet[5] := aDadosXml[6] + " - "+DecodeUTF8(aDadosXml[7])										
	else
		//ID do CCE
		aDadosRet[2] := aDadosXml[3]
		//AMBIENTE
		aDadosRet[3] := aDadosXml[5]
		//STATUS DO EVENTO
		aDadosRet[4] := "4-Evento transmitido, aguarde processamento."		
	endif
else
	aDadosRet := {}
	cErro := oDoc:cCodErr + " - " + oDoc:cMsgErr
endif

return(aDadosRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColEnvEvento
Devolve os dados com a informação desejada conforme modelo e parâmetro nInf.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 
@param cModelo, string, Código do tipo de documento:<br>CCE - Carta de Correção 
@param	aNFe, array, Array com os dados da NF-e.<br>[1] - Chave<br>[2] - Recno<br>[3] - Serie<br>[4] - Numero			
@param	cXml, string, XML no layout do evento. 
@param @cIdEven, string, Referência para retornar o ID do Evento, so retorna se for envaido com sucesso.
@param @cErro, string, Mensagem de erro para ser demonstrada na rotina de transmissão.
@param lInutiliza,logigo,Informa se o documento é uma inutilização.

@return lok lógico .T. quando for gerado o arquivo com sucesso.
/*/
//-----------------------------------------------------------------------
function ColEnvEvento(cModelo,aNfe,cXml,cIdEven,cErro,lInutiliza,cTpEvento,lCte,lMDfe,lEstorno)

local oDoc := nil
local cAviso	:= ""
local cQueue	:= ""
local cIdErp	:= ""
local lOk := .F.
local aDados		:= {}

local aDadosXml	:= {}


Default cModelo := "CCE"
Default lInutiliza	:= .F.
Default cTpEvento	:= ""
Default lCte		:= .F.
Default lMDfe		:= .F.
Default lEstorno    := .F.

if cModelo == "CCE"
	If lCte
		cQueue := "385"
	Else
	cQueue := "301"
	EndIf
	cIdErp := aNfe[3] + aNfe[4] + FwGrpCompany()+FwCodFil()
elseif cModelo == "CEC"
	If lEstorno	//-- Estorno do comprovante de entrega
		cQueue := "590"
	Else		//-- Envio do comprovante de entrega
		cQueue := "589"
	EndIf
	cIdErp := aNfe[3] + aNfe[4] + FwGrpCompany() + FwCodFil()
elseif cModelo == "NFE"
	If lInutiliza
		cQueue := "172"		//Inutilizacao  NF-e	
	Else
		cQueue := "171"		//Cancelamento NF-e
	EndIf
	cIdErp := aNfe[3] + aNfe[4] + FwGrpCompany()+FwCodFil()
elseIf cModelo == "MDE"
	cQueue := "320"
	cIdErp := "MDE"+SubStr(aNfe[01],7,14)+SubStr(aNfe[01],23,3)+SubStr(aNfe[01],26,9)+FwGrpCompany()+FwCodFil()
elseif cModelo == "CTE"
	If lInutiliza
		cQueue := "201"		//Inutilizacao  NF-e
	Else
		cQueue := "200"		//Cancelamento NF-e
	EndIf
	cIdErp := aNfe[3] + aNfe[4] + FwGrpCompany()+FwCodFil()
elseif cModelo == "MDF"
	If lInutiliza
		cQueue := "362"		//Cancelamento MDF-e
	Else
		cQueue := "361"		//Encerramento MDF-e
	EndIf
	If lMDfe
		cIdErp := "MDF"+aNfe[3] + aNfe[4] + FwGrpCompany()+FwCodFil()
	Else
		cIdErp := "MDF"+SubStr(aNfe[01],7,14)+SubStr(aNfe[01],23,3)+SubStr(aNfe[01],26,9)+FwGrpCompany()+FwCodFil()
	EndIf
Elseif cModelo == "EPP"
	If aNfe[5]  $ '111500/111501'
		cQueue := "534"	
	Else
		cQueue := "535"	
	Endif
	cIdErp := aNfe[3] + aNfe[4] + FwGrpCompany()+FwCodFil()
endif

cXml := EncodeUtf8(cXml)

oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov	:= "1"									
oDoc:cIDERP	:= cIdErp
oDoc:cModelo	:= cModelo
oDoc:cXml		:= cXml
oDoc:cQueue	:= cQueue
oDoc:cSerie  	:= aNfe[3]
oDoc:cNumero 	:= aNfe[4]

If lCte		// 57 - CTe evento
	aadd(aDados,"EVENTOCTE|INFEVENTO|ID")
ElseIf lMDfe	// 58 - MDFe evento
	aadd(aDados,"EVENTOMDFE|INFEVENTO|ID")
Else			// 55 - NFe evento
aadd(aDados,"EVENTO|INFEVENTO|ID")	
	aadd(aDados,"INUTNFE|INFINUT|ID")
EndIf
aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)

if odoc:transmitir()
	If  Len (aDadosXml[1]) > 0
	cIdEven := aDadosXml[1]
	Else
		cIdEven := aDadosXml[2]
	Endif
	lOk := .T.	
else
	cErro := oDoc:cCodErr + " - " + oDoc:cMsgErr
endif

oDoc := Nil
DelClassIntF()

return(lOk)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColMsgSefaz
Funcao que devolve o array de mensagem do Documento Autorizado.

@param		cModelo, String, Modelo do documento.
@param		cCod	, String, Codigo do modelo do documento.
@param		@cMsg	, String, Passar como referência para retornar a msg caso encontre.
						  
@return	lAchou	, Logico, Retorna se foi encontrado o modelo do documento.						

@author	Douglas Parreja
@since		05/08/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
Function ColMsgSefaz( cModelo , cCod, cMsg )

Local aMsg		:= {}
Local lAchou		:= .T.

Default cModelo 	:= "NFE"

IF 		cModelo == '55'
	cModelo := 'NFE'
elseif cModelo == '56'
	cModelo := 'NFSE'
elseif cModelo == '57'
	cModelo := 'CTE'
elseif cModelo == '58'
	cModelo := 'MDF'
elseif cModelo == '65'
	cModelo := 'NFCE'
ENDIF

If cModelo $ "NFE|CTE|MDF|NFCE"
	aadd(aMsg,{"102","Inutilização de número homologado"})
	aadd(aMsg,{"110","Uso denegado"})
	aadd(aMsg,{"301","Uso denegado: Irregularidade fiscal do emitente"})
EndIf	

If cModelo $ "NFE|CTE"
	aadd(aMsg,{"100","Autorizado o uso da NF-e"})
	aadd(aMsg,{"101","Cancelamento de NF-e homologado"})
	aadd(aMsg,{"124","DPEC recebido pelo Sistema de Contingência Eletrônica"})
	aadd(aMsg,{"125","DPEC localizado"})
	aadd(aMsg,{"126","Inexiste DPEC para o número de registro de DPEC informado"})
	aadd(aMsg,{"127","Inexiste DPEC para a chave de acesso da NF-e informada"})
	aadd(aMsg,{"150","Autorizado o uso da NF-e, autorização concedida fora de prazo"})
	aadd(aMsg,{"151","Cancelamento de NF-e homologado fora do prazo"})
	aadd(aMsg,{"155","Cancelamento homologado fora de prazo"})
EndIf

If cModelo == "CTE"
	aadd(aMsg,{"100","Autorizado o uso do CT-e"})
	aadd(aMsg,{"101","Cancelamento de CT-e homologado"})
	aadd(aMsg,{"128","CT-e anulado pelo emissor"})
	aadd(aMsg,{"129","CT-e substituído pelo emissor"})
	aadd(aMsg,{"130","Apresentada Carta de Correção Eletrônica – CC-e"})
	aadd(aMsg,{"131","CT-e desclassificado pelo Fisco"})
	aadd(aMsg,{"134","Evento registrado e vinculado ao CT-e com alerta para a situação do documento"})
	aadd(aMsg,{"135","Evento registrado e vinculado a CT-e"})
	aadd(aMsg,{"136","Evento registrado, mas não vinculado a CT-e"})
	aadd(aMsg,{"302","Uso denegado: Irregularidade fiscal do remetente"})
	aadd(aMsg,{"303","Uso Denegado : Irregularidade fiscal do destinatário"})
	aadd(aMsg,{"304","Uso Denegado : Irregularidade fiscal do expedidor"})
	aadd(aMsg,{"305","Uso Denegado : Irregularidade fiscal do recebedor"})
	aadd(aMsg,{"306","Uso Denegado : Irregularidade fiscal do tomador"})  
EndIf

If cModelo == "MDF"
	aadd(aMsg,{"100","Autorizado o uso do MDF-e"})
	aadd(aMsg,{"101","Cancelamento de MDF-e homologado"})
	aadd(aMsg,{"132","Encerramento de MDF-e homologado"})
	aadd(aMsg,{"135","Evento registrado e vinculado a MDF-e"})
	aadd(aMsg,{"136","Evento registrado, mas não vinculado a MDF-e"})
EndIf

If cModelo == "NFSE"
	aadd(aMsg,{"100","Autorizado o uso do NFSE-e"})
	aadd(aMsg,{"101","Cancelamento de NFSE-e homologado"})
EndIf
If Len(aMsg) > 0 
	nX	:= Ascan( aMsg,{|x| x[1] == cCod} )
	If nX == 0
		lAchou := .F.
	EndIf
EndIf

Return ( lAchou )


//-----------------------------------------------------------------------
/*/{Protheus.doc} ColExpDoc
Busca documento para exportação, nas rotinas de exportação do ERP.
 
@author 	Rafel Iaquinto
@since 		07/08/2014
@version 	11.9
 
@param cSerie, string, Série do documento. 
@param	cNumero, string, Número do documento			
@param	cModelo, string, XML no layout do evento. 

@return aInfXML array Informações sobre o XML.<br>[1] - Logico se encotra documento .T.<br>[2] - Chave do documento<br>[3] - XML autorização<br>[4] - XML Cancelamento Evento<br>[5] - XML Ped. Inutilização<br>[6] - XML Prot. Inutilização
/*/
//-----------------------------------------------------------------------
function ColExpDoc(cSerie,cNumero,cModelo)
local cQuery		:= ""
local cXML			:= ""
local cXMLCanc	:= ""
local cXMLPedInu	:= ""
local cXMLInut	:= ""
local cChave		:= ""
local cErro		:= ""
local cAviso		:= ""
local cProt		:= ""
local CSTAT		:= ""
local cChaveSf3	:= ""
Local cEspecie	:= ""
local cAliasTSF3 	:= ""
local cXMOT		:= ""
local lAutorizado	:= .F. 
local lCancela	:= .F.
local lInutiliza	:= .F.	
local cAutoEvent	:=	'101-102-135-151-155-220' // Evento registrado cancelamento e inutilização
local nX		:= 0

local aInfXml := {.F.,"","","","","","","",.F.,.F.,.F.}
local aDados 	:= {}

local lDtcanc := .F.
local lDenega := .F.
local lAchou	:= .F.
local aArea 		:= GetArea()

local oDoc		:= Nil
local cSTATF3 := ""
	//-------------------------------------------
	// Necessário quando a serie usada não especificada no MV_ESPECIE
	// Neste caso a epecie não é gravada no F3_ESPECIE
	//-------------------------------------------
	If cModelo == "NFE"
		cEspecie := "SPED"
	Else
		cEspecie := "CTE"
	Endif


oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov	:= "1"
If cModelo == "MDF"
	oDoc:cIDERP	:= 'MDF' + cSerie + cNumero + FwGrpCompany()+FwCodFil()
Else
	oDoc:cIDERP	:= cSerie + cNumero + FwGrpCompany()+FwCodFil()
EndIf
oDoc:cModelo	:= cModelo


dbSelectArea("SF3")
dbSetOrder(5)
#IFDEF TOP
cAliasTSF3 	:= GetNextAlias()
// Query necessária para tratar nota de entrada no processo de validação do cancelamento
cQuery := " SELECT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_ENTRADA,F3_CFO,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_FORMUL,F3_CODRET ,F3_CHVNFE , F3_CODRSEF"
cQuery += " FROM "+retSqlname("SF3")+" SF3 "
cQuery += " WHERE "
cQuery += " SF3.F3_FILIAL	=  '" + xFilial("SF3")	+ "' AND "
cQuery += " SF3.F3_NFISCAL	=  '" + cNumero			+ "' AND "
cQuery += " SF3.F3_SERIE		=  '" + cSerie         	+ "' AND "
cQuery += " SF3.F3_ESPECIE	=  '" + cEspecie + "' AND "
If cModelo != "CTE"
	If retBancoDados()
		cQuery += " (SUBSTR( F3_CFO, 1, 1 ) < '5' AND SF3.F3_FORMUL='S') "
	Else
		cQuery += "(SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S') "
	EndIf
cQuery += " OR "
cQuery += " SF3.F3_FILIAL	=  '" + xFilial("SF3")	+ "' AND "
cQuery += " SF3.F3_NFISCAL	=  '" + cNumero			+ "' AND "
cQuery += " SF3.F3_SERIE		=  '" + cSerie         	+ "' AND "
cQuery += " SF3.F3_ESPECIE	=  '" + cEspecie + "' AND "
	If retBancoDados()
		cQuery += " SUBSTR( F3_CFO, 1, 1 ) >= '5' AND "
	Else
		cQuery += " SubString(SF3.F3_CFO,1,1) >= '5' AND "
	EndIf
EndIf
cQuery += " SF3.D_E_L_E_T_	= ''"
    cQuery 		:= ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTSF3, .F., .T.)
#ELSE
	MsSeek(xFilial("SF3")+cSerie+cNumero,.T.)
#ENDIF
While !Eof() .And. xFilial("SF3") == (cAliasTSF3)->F3_FILIAL .And.;
	(cAliasTSF3)->F3_SERIE == cSerie .And.;
	(cAliasTSF3)->F3_NFISCAL >= cNumero .And.;
	(cAliasTSF3)->F3_NFISCAL <= cNumero
	dbSelectArea(cAliasTSF3)
	If ( Val( (cAliasTSF3)->F3_NFISCAL ) >= Val( cNumero ) .And. Val ( (cAliasTSF3)->F3_NFISCAL ) <= Val( cNumero )  )
					cChaveSf3 := alltrim ((cAliasTSF3)->F3_CHVNFE)
				   lDtcanc	   := iif (Empty((cAliasTSF3)->F3_DTCANC),.F.,.T.)
				   lDenega	   := iif ((cAliasTSF3)->F3_CODRSEF $ RetCodDene() ,.T.,.F.)
				   cSTATF3		:= (cAliasTSF3)->F3_CODRSEF
			Endif
	dbSelectArea(cAliasTSF3)
	dbSkip()
EndDo

(cAliasTSF3)->(DbCloseArea())
RestArea( aArea )
if odoc:consultar()
	aDados := ConsuQueyArray(@aDados,oDoc:cQUeue,oDoc:cModelo)
	
	//Se for cancelamento tenho que devolver o XML da nota autorizada que sera retornada no historico 
	if !Empty( oDoc:cXMLRet ) .Or. oDoc:cQUeue $ "200-171"
		
		lAchou := .T.
		
		//Busca os dados no XML
		aDadosXml := ColDadosXMl(oDoc:cXMLRet, aDados, @cErro, @cAviso)
		
		
		
		If Len(aDadosXml) > 0
			//Documentos que não necessitam verificar o histórico: Emissao,Inutilização e CCe(NFe e CTe)
			if oDoc:cQueue $ "199-170-301-361-385"
					
				cXML 	:= oDoc:cXMLRet
				cChave	:= IIF ( Empty (aDadosXml[2]) , cChaveSf3 ,aDadosXml[1] )
				cProt	:= aDadosXml[2]
				cSTAT  := IIF ( Empty (aDadosXml[3]), cSTATF3, aDadosXml[3])
				if oDoc:cQueue != "385"
					cXMOT  := aDadosXml[4]
				EndIf		
			elseIf oDoc:cQueue == "170" .And. aDadosXml[3] == "1"
				cChave		:= aDadosXml[1]
			endif
			
			// Nota já foi enviada e está rejeitada foi excluído o documento de saída dtcanc preenchido
			If oDoc:cQueue $ "170-199" .And. ( ( Empty (cChave) .And. Empty (cProt) ) .Or. "Rejeicao" $ cXMOT ).And. !Empty (cSTAT) .And. !lDenega .And. lDtcanc
			   	lInutiliza := .T. // Não foi encontrada nota autorizada e nem cancelamento autorizado.
			// Nota já foi enviada e está aprovada foi excluído o documento de saída dtcanc preenchido 
			Elseif oDoc:cQueue $ "170-199" .And. !Empty (cChave) .And. !Empty (cProt) .And. !Empty (cSTAT) .And. cSTAT $ '100-124-150' .And. lDtcanc
				cChave			:= cChaveSf3
				lAutorizado	:= .T.
				lCancela		:= .T.
			Endif
			  
		
		Endif
					
			//Cancelamento, necessita verificar o histórico para pegar o XML de autorização da nota e Cancelamento
		if oDoc:cQueue $ "200-171-201-172-361" .And. !Empty( aDadosXml[2] ) .And. aDadosXml[3] $ cAutoEvent	 //aDadosXml[2] - Com Protocolo de autorização
			
			//Retorna o XML Apenas se houver protocolo da Inutilização
			if oDoc:cQueue $ "201-172"
				cXMLPedInu	:= ColXmlAdjust(oDoc:cXMLRet,iif( oDoc:cQueue == "201",'inutCTe','inutNFe'))
				cXMLInut	:= oDoc:cXMLRet
				cProt		:= aDadosXml[2]
				cSTAT  	:= aDadosXml[3]
					
			Endif
					
				cXMLCanc 	:= oDoc:cXMLRet
				cChave 	:= aDadosXml[1]
				cProt		:= aDadosXml[2]
				cSTAT  	:= aDadosXml[3]
					
					
			
			//Cancelamento, necessita verificar o histórico para pegar o XML de autorização da nota
		elseif oDoc:cQueue $ "200-171-201-172" .And. Empty( aDadosXml[2] ) //aDadosXml[2] - Sem Protocolo de autorização
			oDoc:lHistorico	:= .T.
			odoc:buscahistorico()
		
			for nx:= 1 to Len( oDoc:aHistorico )
			
			    	aDados := ConsuQueyArray(@aDados,oDoc:aHistorico[nX][8] ,iif(oDoc:aHistorico[nX][8] =="199","CTE","NFE"))
					aDadosXml := ColDadosXMl(oDoc:aHistorico[nX][2], aDados, @cErro, @cAviso)
			
			
					//Se for emissão - CT-e ou NF-e e tiver protocolo
				if 	oDoc:aHistorico[nX][8] $ "199-170" .And. !Empty(oDoc:aHistorico[nX][2])					
					if Len(aDadosXml) > 0 .And. !Empty(aDadosXml[3]) .And. 	aDadosXml[3] $ '100-124-150'
						cXML	:= oDoc:aHistorico[nX][2]
						cChave := cChaveSf3
						cProt	:= aDadosXml[2]
						cSTAT  := aDadosXml[3]
						lAutorizado 	:= .T.
						lCancela		:= .T.
						lInutiliza		:= .F.
					endif
					//Possui um registro na CKOCOL de cancelamento já autorizado.
				elseif (Len(aDadosXml) > 0 .And. oDoc:aHistorico[nX][8]  $ "200-171") .And. (aDadosXml[3] $ cAutoEvent)
					lCancela		:= .F.
					lInutiliza		:= .F.
					//Possui um registro na CKOCOL de inutilização já inutilizado.	 	
				elseif (Len(aDadosXml) > 0 .And. oDoc:aHistorico[nX][8]  $ "201-172") .And. (aDadosXml[3] $ cAutoEvent)
					lCancela		:= .F.
					lInutiliza		:= .F.												 	 						 	 	
				endif
																				 					
			next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avaliação do historico da CKOCOL
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If    ( lAutorizado .And. !lCancela)
					lCancela		:= .T.
					lInutiliza		:= .F.
			Elseif( !lAutorizado .And. !lCancela )
				lInutiliza := .T. // Não foi encontrada nota autorizada e nem cancelamento autorizado.
				cXMLPedInu	:= ColXmlAdjust(oDoc:cXMLRet,iif( oDoc:cQueue == "201",'inutCTe','inutNFe'))
				cXMLInut	:= oDoc:cXMLRet
			Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avaliação do historico da CKOCOL
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		endif
	endif
		
	
	aInfXml[1] :=	lAchou
	aInfXml[2] :=	IIF("NFe" $ cChave, cChave:= SubStr(cChave,4), cChave ) //01 - Chave da Nfe
	aInfXml[3] := cXML
	aInfXml[4] := cXMLCanc
	aInfXml[5] := cXMLPedInu
	aInfXml[6] := cXMLInut
	aInfXml[7] := cProt
	aInfXml[8] := cSTAT
	aInfXml[9] := lAutorizado
	aInfXml[10]:= lCancela
	aInfXml[11]:= lInutiliza
else
// Existe registro na SF3 foi solicitada a exclusao da nota e não possui registro na CKO/CKQ - será inutilizada
 if !cSTATF3 $ cAutoEvent .And. lDtcanc .And. !lDenega
	aInfXml[11]:= .T.
 endif
endif


oDoc := Nil
DelClassIntF()

return (aInfXml)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ConsuQueyArray
Função criada devido ao reuso do conteúdo array que varre o xml de retorno Neogrid

@author Cleiton Genuino     
@since 06.16.2015
@version 1.0 

@param		cQueue - Código da query de integração do modelo unicpo ico
@param		cModelo - Modelo do documento
			
@return aDados Array com a estrutura de retorno do xml a ser processado
/*/
//-----------------------------------------------------------------------

Static function ConsuQueyArray(aDados,cQueue,cModelo)

Default aDados := {}
Default cQueue := ""
Default cModelo:= ""

aDados := {}
	//Caminho do ID dentro do XML para cada Queue
	do case
		
		//Emissao CTe
		case cQueue == "199"
			aadd(aDados,"CTEPROC|CTE|INFCTE|ID")
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|NPROT")			
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|CSTAT")
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|XMOTIVO")
		
		//Eventos - CANC e CCe - Cte
		case cQueue $ "200-385"	
			aadd(aDados,"PROCEVENTOCTE|EVENTOCTE|INFEVENTO|ID")
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|NPROT")
			aadd(aDados,"")
		
		//Inutilizacao CT-e
		case cQueue == "201"
			aadd(aDados,"PROCINUTCTEPROC|RETINUTCTE|INFINUT|ID")
			aadd(aDados,"PROCINUTCTEPROC|RETINUTCTE|INFINUT|NPROT")
			aadd(aDados,"")
		
		//Emissao NFe
		case cQueue == "170"	
			aadd(aDados,"NFEPROC|NFE|INFNFE|ID")
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|NPROT")
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|CSTAT")
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|XMOTIVO")
		
		//Eventos-CANC CCe - NFe
		case cQueue $ "171-301"
			aadd(aDados,"PROCEVENTONFE|EVENTO|INFEVENTO|ID")		   
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NPROT")
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|CSTAT")
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|XMOTIVO")
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|TPEVENTO")
		
		//Inutilizacao NFe
		case cQueue == "172"
			IF cModelo =="CTE"
				aadd(aDados,"PROCINUTNFEPROC|RETINUTCTE|INFINUT|ID")
				aadd(aDados,"PROCINUTNFEPROC|RETINUTCTE|INFINUT|NPROT")
			EndIF
			IF cModelo =="NFE"
				aadd(aDados,"PROCINUTNFE|INUTNFE|INFINUT|ID")
				aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|NPROT")
				aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|CSTAT")
				aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|XMOTIVO")
			EndIF
		//Manifesto - TMS
		case cQueue == "361"
			IF cModelo =="MDF"
				aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|ID")
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|NPROT")
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|CSTAT")
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|XMOTIVO")
			EndIF
	end

return (aDados)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColXmlAdjust
FunşÒo que ajusta o XML de Retorno da NeoGrid conforme necessidade de 
gravaşÒo no TSS.

@author Rafael Iaquinto     
@since 24.11.2010
@version 1.0 

@param		cXML,string, XML que serß ajustado 
@param		cTAG,string, Tag que deverß ser retornada do XML passado.
			
@return cNewXml,string, XML ajustado.
/*/
//-----------------------------------------------------------------------
function ColXmlAdjust(cXML,cTag)

Local cNewXml	:= ""
Local nAtx		:= 0 
Local nAty		:= 0
Local nTamFim	:= 0

nTamFim := Len('</'+cTag+'>')
nAtx:= At('<'+cTag,cXMl) //PosişÒo Inicial
nAty:= At('</'+cTag+'>',cXMl) //PosişÒo Final

If nAtx > 0 .And. nAty > 0
	cNewXml := Substr(cXMl,nAtx,(nAty+nTamFim-nAtx))
EndIf

Return(cNewXml)
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColDadosNf
Devolve os dados com a informação desejada conforme modelo e parâmetro nInf.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 
@param	nInf, inteiro, Codigo da informação desejada:<br>1 - Normal<br>2 - Cancelametno<br>3 - Inutilização						
@param	cModelo, string, modelo do documento(55 ou 57) 

@return aRetorno Array com as posições do XML desejado, sempre deve retornar a mesma quantidade de posições.
/*/
//-----------------------------------------------------------------------
function ColDadosNf(nInf,cModelo,lTMS,lUsaColab)

local aDados	:= {}
local lUsaColab := .F.
local lNFe      := IIf(cModelo == '55',.T.,.F.)
local lNSFe     := IIf(cModelo == '56',.T.,.F.)
local lCte      := IIf(cModelo == '57',.T.,.F.)
local lMDFe     := IIf(cModelo == '58',.T.,.F.)

lUsaColab := UsaColaboracao( IIf(lCte,"2" ,IIf(lMDFe,"5",IIf(lNSFe,"3",IIf(lNFe,"1",""))))) 

if cModelo == "57"
	do case
		case nInf == 1
			//Informaçoes da CT-e
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|DHRECBTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"CTEPROC|CTE|INFCTE|IDE|TPEMIS") //5 - Tipo de Emissao
			aadd(aDados,"CTEPROC|CTE|INFCTE|IDE|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"CTE|INFCTE|IDE|TPEMIS") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"CTE|INFCTE|IDE|TPAMB") //8 - Ambiente de transmissão -  Caso nao tenha retorno			
			aadd(aDados,"CTEPROC|RETEVENTOCTE|INFEVENTO|NPROT") //9 - Numero de autorização EPPEC
			aadd(aDados,"CTEPROC|PROTCTE|INFPROT|CHCTE") //10 - Chave da autorizacao
		
		case nInf == 2	
			//Informacoes do cancelamento - evento
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|DHREGEVENTO")	//4 - Data e hora de recebimento
			aadd(aDados,"") //5 - Tipo de Emissao
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|TPAMB") //6 - Ambiente de transmissão
			aadd(aDados,"") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"PROCEVENTOCTE|EVENTOCTE|INFEVENTO|TPAMB") //8 - Ambiente de transmissão -  Não tem no XML de envio
			aadd(aDados,"") //9 - Numero de autorização DPEC
			aadd(aDados,"") //10 - Chave da autorizacao

		case nInf == 3			
			//Informações da Inutilização
			aadd(aDados,"PROCINUTCTE|RETINUTCTE|INFINUT|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"PROCINUTCTE|RETINUTCTE|INFINUT|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"PROCINUTCTE|RETINUTCTE|INFINUT|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"PROCINUTCTE|RETINUTCTE|INFINUT|DHRECBTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"") //5 - Tipo de Emissao
			aadd(aDados,"PROCINUTCTE|RETINUTCTE|INFINUT|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"INUTCTE|INFINUT|TPAMB	") //8 - Ambiente de transmissão -  Caso nao tenha retorno												
			aadd(aDados,"") //7 - Numero de autorização DPEC
			aadd(aDados,"") //10 - Chave da autorizacao
		
		case nInf == 4
			//Informacoes do cancelamento - evento (Aguardando transmissão)
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|CSTAT") //1 - Codigo Status documento
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|NPROT")	//3 - Protocolo Autporizacao
			aadd(aDados,"PROCEVENTOCTE|RETEVENTOCTE|INFEVENTO|DHREGEVENTO")	//4 - Data e hora de recebimento
			aadd(aDados,"") //5 - Tipo de Emissao
			aadd(aDados,"EVENTOCTE|INFEVENTO|TPAMB") //6 - Ambiente de transmissão
			aadd(aDados,"") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"") //8 - Ambiente de transmissão -  Não tem no XML de envio
			aadd(aDados,"") //9 - Numero de autorização DPEC
			aadd(aDados,"") //10 - Chave da autorizacao

	end
elseif cModelo = "55"
	do case
		case nInf == 1
			//Informaçoes da NF-e
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|DHRECBTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"NFEPROC|NFE|INFNFE|IDE|TPEMIS") //5 - Tipo de Emissao
			aadd(aDados,"NFEPROC|NFE|INFNFE|IDE|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"NFE|INFNFE|IDE|TPEMIS") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"NFE|INFNFE|IDE|TPAMB") //8 - Ambiente de transmissão -  Caso nao tenha retorno			
			aadd(aDados,"NFEPROC|NFE|INFNFE|INFADIC|OBSCONT") //9 - Dados autorizacao DPEC
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|CHNFE") //10 - Chave da autorizacao
		
		case nInf == 2	
			//Informacoes do cancelamento - evento
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|DHREGEVENTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"") //5 - Tipo de Emissao
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"EVENTO|INFEVENTO|TPAMB") //8 - Ambiente de transmissão -  Caso nao tenha retorno
			aadd(aDados,"") //9 - Numero de autorização DPEC
			aadd(aDados,"") //10 - Chave da autorizacao
		
		case nInf == 3	
			//Informações da Inutilização
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|DHRECBTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"") //5 - Tipo de Emissao
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"INUTNFE|INFINUT|TPAMB	") //8 - Ambiente de transmissão -  Caso nao tenha retorno												
			aadd(aDados,"") //9 - Numero de autorização DPEC
			aadd(aDados,"") //10 - Chave da autorizacao
	end
elseif cModelo = "56"
	do case
		case nInf == 1
			//Informaçoes da NSF-e
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|CSTAT")			// 1 - Codigo Status documento
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|XMOTIVO")			// 2 - Motivo do status
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|NPROT")			// 3 - Protocolo Autorizacao
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|DTEMISNFSE")		// 4 - Data e hora de emissao
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|TPRPS")	 		// 5 - Tipo de Emissao  ???
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|NRPS")	 		// 6 - Numero do RPS
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|NSERIERPS")		// 7 - Serie do RPS
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|NNFSE")			// 8 - Numero da NFS-e gerado na prefeitura
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|CVERIFICANFSE")	// 9 - Codigo de Verificacao da NFS-e
			aadd(aDados,"PROCNFSE|ERP|RETNFSE|CCNPJPREST")		//10 - CNPJ prestador

		case nInf == 2
			//Informacoes do cancelamento - evento
			aadd(aDados,"PROCCANCNFSE|ERP|RETCANCNFSE|CSTAT")	//1 - Codigo Status documento
			aadd(aDados,"PROCCANCNFSE|ERP|RETCANCNFSE|XMOTIVO")	//2 - Motivo do status
			aadd(aDados,"PROCCANCNFSE|ERP|RETCANCNFSE|NPROT")	//3 - Protocolo Autorizacao
			aadd(aDados,"PROCCANCNFSE|ERP|RETCANCNFSE|DTCANC")	//4 - Data e hora de cancelamento
			aadd(aDados,"")	//5 - Tipo de Emissao
			aadd(aDados,"")	//6 - Ambiente de transmissão
			aadd(aDados,"")	//7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"")	//8 - Ambiente de transmissão -  Caso nao tenha retorno
			aadd(aDados,"")	//9 - Numero de autorização DPEC
			aadd(aDados,"")	//0 - CNPJ prestador

		case nInf == 3
			//Informações da Inutilização
			aadd(aDados,"")	//1 - Codigo Status documento
			aadd(aDados,"")	//2 - Motivo do status
			aadd(aDados,"")	//3 - Protocolo Autorizacao
			aadd(aDados,"")	//4 - Data e hora de recebimento
			aadd(aDados,"")	//5 - Tipo de Emissao
			aadd(aDados,"")	//6 - Ambiente de transmissão
			aadd(aDados,"")	//7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"")	//8 - Ambiente de transmissão -  Caso nao tenha retorno
			aadd(aDados,"")	//9 - Numero de autorização DPEC
			aadd(aDados,"")	//0 - CNPJ prestador
	end

elseif cModelo = "58"
	If lTMS
		do case
			case nInf == 1
				//Informaçoes do MDF-e
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|CSTAT")		//1 - Codigo de retorno do processamento SEFAZ 
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|XMOTIVO")	//2 - Motivo do processamento da SEFAZ
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|NPROT")		//3 - Protocolo de autorizacao 
				aadd(aDados,"MDFEPROC|MDFE|INFMDFE|IDE|DHEMI")		//4 - Data e hora de emissao
				aadd(aDados,"MDFEPROC|MDFE|INFMDFE|IDE|TPEMIS")		//5 - Modalidade xml de Envio
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|TPAMB")		//6 - Ambiente de transmissão
				aadd(aDados,"MDFE|INFMDFE|IDE|TPEMIS")				//7 - Tipo de Emissao - Caso nao tenha retorno
				aadd(aDados,"MDFE|INFMDFE|IDE|TPAMB")				//8 - Ambiente de transmissão -  Caso nao tenha retorno
				aadd(aDados,"")	//9 - Numero de autorização DPEC
				aadd(aDados,"")	//0 - CNPJ prestador

			case nInf == 2 .Or. nInf == 3 
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|CSTAT")		//1 - Codigo de retorno do processamento SEFAZ 
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|XMOTIVO")	//2 - Motivo do processamento da SEFAZ
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|NPROT")		//3 - Protocolo de autorizacao 
				aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|DHEVENTO")		//4 - Data e hora de emissao
				aadd(aDados,"")													//5 - Modalidade xml de Envio
				aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|TPAMB")		//6 - Ambiente - AUTORIZADO
				aadd(aDados,"")													//7 - Tipo de Emissao - Caso nao tenha retorno
				aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|TPAMB")		//8 - Ambiente - Caso nao tenha retorno
				aadd(aDados,"")													//9 - Numero de autorização DPEC
				aadd(aDados,"")													//0 - CNPJ prestador
			case nInf == 4
				aadd(aDados,"RETCONSMDFENAOENC|INFMDFE|CHMDFE") //1 - Chave MDFe
				aadd(aDados,"RETCONSMDFENAOENC|INFMDFE|NPROT") //2 - Protocolo MDFe
				aadd(aDados,"RETCONSMDFENAOENC|MOTIVO") //3 - Motivo
		end
	Else
		do case
			case nInf == 1
				//Informaçoes do MDF-e
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|NPROT")	//1 - Protocolo de autorizacao 
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|TPAMB") 	//2 - Ambiente xml de retorno
				aadd(aDados,"MDFE|INFMDFE|IDE|TPAMB")			 	//3 - Ambiente xml de ENVIO
				aadd(aDados,"MDFE|INFMDFE|IDE|TPEMIS")				//4 - Modalidade xml de Envio						
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|CSTAT")	//5 - Codigo de retorno do processamento SEFAZ 
				aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|XMOTIVO") //6 - Motivo do processamento da SEFAZ
				aadd(aDados,"MDFEPROC|MDFE|INFMDFE|IDE|TPEMIS")	//7 - Modalidade XML de retorno							

			case nInf == 2 .Or. nInf == 3 
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|NPROT")	//1 - Protocolo de autorizacao 
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|TPAMB") 	//2 - Ambiente - AUTORIZADO
				aadd(aDados,"EVENTOMDFE|INFEVENTO|TPAMB")			//3 - Ambiente - ENVIO
				aadd(aDados,"")				//4 - Modalidade xml de envio não tem esta informação
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|CSTAT")	//5 - Codigo de retorno do processamento SEFAZ 
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|XMOTIVO") //6 - Motivo do processamento da SEFAZ
				aadd(aDados,"")	//7 - Modalidade XML de retorno - não tem estaa informação
				aadd(aDados,"ENVEVENTO|EVENTOS|DETEVENTO|CHNFE") //8 - Chave do MDFe
				aadd(aDados,"MDFE|INFMDFE|INFDOC|INFMUNDESCARGA|CMUNDESCARGA") //9 - Codigo do municipio	
			//***IMPORTANTE: Caso altere a posicao do array acima [9]CMUNDESCARGA precisara alterar na funcao MDFeEvento (Fonte ColabGeneric) no qual chama ele.
			case nInf == 4
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|NPROT") 						
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|TPEVENTO")
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|TPAMB")
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|CSTAT")
				aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|XMOTIVO")
				aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|DETEVENTO|EVINCCONDUTORMDFE|CONDUTOR|CPF")
				aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|DETEVENTO|EVINCCONDUTORMDFE|CONDUTOR|XNOME")			
		end
	EndIf
endif	

	
return(aDados)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColMdeSinc
Realiza a chamada do método para geração do arquivo referênte a consulta de notas destinadas do MD-e para a NeoGrid.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 						
@param	cMsg, string, mensagem do resultado do processamento.

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------
function ColMdeSinc(cMsg,lCheck1)

local oDoc	:= Nil
local lRet := .F.
Default lCheck1  := .F.

oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov	:= "1"
oDoc:cIDERP	:= "SINCRONIZAR"+FwGrpCompany()+FwCodFil()
oDoc:cModelo	:= "MDE"
oDoc:cTipoMov	:= "1"															// Tipo de Movimento 1-Saida / 2-Recebimento  
oDoc:cQueue	:= "443" // Troca do queue de "338" para "443"			// Codigo Queue (443- MD-e - Consulta NF-e Destinada)

if ColParValid("MDE",@cMsg)

	if odoc:consultar() .And. odoc:cCdStatDoc == "1" 
		cMsg := "Ainda existe uma solicitação de sincronização pendente, aguarde o retorno para realizar uma nova solicitação.  " + oDoc:cNomeArq
	else
		//Sempre realizo o retorno antes de realizar um novo envio,
		//para garantir que foi realizado o retorno da consulta anterior.		
		ColMdeCons()
		
		oDoc:cNomeArq	:= "" 
		cXml := ColXmlSinc(/*cAmbiente*/,/*cVerMde*/,/*cCnpj*/,/*cIndNFe*/,/*cUltimoNSU*/,/*cIndEmi*/,/*cUFAutor*/,lCheck1)
		
		oDoc:cXml := cXml
		
		lRet := oDoc:transmitir()
		
		if !lRet
			cMsg := oDoc:cCodErr + " - " + oDoc:cMsgErr
		else
			//Atualiza o Flag para que fique pendente de consulta.
			ColSetPar("MV_MDEFLAG","1")			
		endif 			 	
					
	endif

endif

oDoc := nil
DelClassIntF()

return( lRet )
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColRetIdErp
Busca uma lista de ID_ERP para os parâmetros passados, na tabel CKQ ou CKO por intervalo
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 						
@param	dDataIni, date, Data inicial que deseja os IDs
@param cTimeIni, string, Hora inicial que deseja os IDs
@param cTipoMov, string, 1 - Para devolver as emissões e 2 - para devolver os recebimentos.
@param 

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------
function ColRetIdErp(dDataIni,cTimeIni,cModelo,cQueue,cIdErpIni,cIdErpFim)

	local cWhere 	:= ""
	local cSelect := ""
	local cTable	:= ""
	local cAlias := GetNextAlias()
	
	local aListNomes:= {}
	local nTamCkqId	:= Len(CKQ->CKQ_IDERP)
	
	default cIdErpIni := ""
	default cIdErpFim := ""
		
	//Monta Query na CKQ
	cTable := "CKQ"
	
	//Select dos Campos da conslta
	cSelect := "%" 
	cSelect += "CKQ_IDERP AS IDERP"
	cSelect +=" %"
	
	//Condição da consulta
	cWhere := "% "
	cWhere += "CKQ_FILIAL= '"+xFilial("CKP")+"'"
	//Faz o filtro por ID ERP
	if !Empty(cIdErpIni) .and. !Empty(cIdErpFim) 		
		cWhere += " AND ( CKQ_IDERP >= '" + PadR(cIdErpIni,nTamCkqId)+"' AND CKQ_IDERP <= '" + PadR(cIdErpFim,nTamCkqId)+"')"
	endif
	//Faz filtro por Data e tempo
	if !Empty(dDataIni) .and. !Empty(cTimeIni)
	cWhere += " AND ( (CKQ_DT_GER > '" + Dtos(dDataIni)+"') OR (CKQ_DT_GER = '" + Dtos(dDataIni)+"' AND CKQ_HR_GER >= '"+cTimeIni+"'))"				
	endif
						
	if !Empty(cModelo)
		cWhere += " AND CKQ_MODELO = '"+ cModelo+"'"
	endif
	if !Empty(cQueue)
		cWhere += " AND CKQ_CODEDI = '"+ cQueue+"'"
	endif
	cWhere +=" %"
	
	//Exceuta a Query
	BeginSql Alias cAlias 
		SELECT %Exp:cSelect%
		FROM %Table:CKQ%
		WHERE 
			%Exp:cWhere% AND
			%NOTDEL%
		ORDER BY IDERP DESC
	EndSql
	
	While (cAlias)->(!EOF())
		
		aadd(aListNomes,(cAlias)->IDERP)
		
		(cAlias)->(dbSkip())
	end
	
	(cAlias)->(dbCloseArea())
		
return aListNomes

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColMdeCons
Realiza a consulta do arquivo de retorno da Sincronização.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 						
@param	@cMsg, string, Variável que irá receber a mensagem do resultado do processamento.

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------
function ColMdeCons(cMsg)

local cChave		:= ""
local cSitConf	:= ""
local cCancNSU	:= ""
local cErro		:= ""
local cAviso		:= ""
local cCNPJEmit	:= ""
local cIeEmit		:= ""
local cNomeEmit	:= ""
local cSituacao	:= ""
local cDesResp	:= ""
local cDesCod		:= ""
local cFileZip	:= ""
local cFileUnZip	:= ""
local cAmbiente	:= ""
local cUltNSU		:= ""
local cMaxNSU		:= ""
local cMotivo		:= ""
local cDhesp		:= ""
local nLenZip		:= 0
local lOk			:= .F.

local dDtEmi		:= CTOD("  \  \  ")
local dDtRec		:= CTOD("  \  \  ")

local nValDoc		:= 0
local nX			:= 0
private cNewFunc	:= ""
private aDocs		:= {}

private oDoc 	:= nil
private oXml	:= nil
private oXmlDoc	:= nil

default cMsg	:= ""

oDoc 			:= ColaboracaoDocumentos():new()		
oDoc:cModelo	:= "MDE"
oDoc:cTipoMov	:= "1"									
oDoc:cIDERP	:= "SINCRONIZAR"+FwGrpCompany()+FwCodFil()

if odoc:consultar() 
	if !Empty( oDoc:cXMLRet ) .And. ColGetPar('MV_MDEFLAG',"0")== "1"
	
		oXML := XmlParser(encodeUTF8(oDoc:cXMLRet),"_",@cAviso,@cErro)
		
			if type("oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_LOTEDISTDFEINT") <> "U"
					if type("oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
						aDocs := oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
			else
						aDocs := {oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP}
			endif
			
				If oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_CSTAT:TEXT == "138"
					for nx:= 1 to Len( aDocs )
						cCancNSU	:= ""
						cErro		:= ""
						cAviso		:= ""
						cCNPJEmit	:= ""
						cIeEmit	:= ""
						cNomeEmit	:= ""
						cSituacao	:= ""
						cDesResp	:= ""
						cDesCod	:= ""
						cAmbiente	:= ""
						cSitConf	:= ""

						cFileZip	:= Decode64( aDocs[nx]:TEXT )
						nLenZip	:= Len( cFileZip )

					// Funcao de descompactacao de arquivos compactados no formato GZip
						if FindFunction("GzStrDecomp")
							cNewFunc 	:= "GzStrDecomp"
							lOk 		:= &cNewFunc.(cFileZip, nLenZip, @cFileUnZip)
						EndIf					
						//lOk :=  &(GzStrDecomp( cFileZip, nLenZip, @cFileUnZip ))
						oXmlDoc := XmlParser( cFileUnZip, "_", @cErro, @cAviso )

					// Ambiente
						If type( "oXml:_PROCNFEDISTDFE:_DISTDFEINT:_TPAMB" ) <> "U"
							cAmbiente	:= oXml:_PROCNFEDISTDFE:_DISTDFEINT:_TPAMB:TEXT
						Endif

					// Ultimo NSU
						If Type( "oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_ULTNSU" ) <> "U"
							cUltNSU 	:= oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_ULTNSU:TEXT
						Endif

					// Maior NSU
						If Type( "oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_MAXNSU" ) <> "U"
							cMaxNSU	:= oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_MAXNSU:TEXT
						Endif

						If Type( "oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_CSTAT" ) <> "U"
							cStat  	:= oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_CSTAT:TEXT
						Endif

						If type( "oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_XMOTIVO" ) <> "U"
							cMotivo	:= oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_XMOTIVO:TEXT
						Endif

						If type( "oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_DHRESP" ) <> "U"
							cDhesp		:= oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_DHRESP:TEXT
						Endif



							If "RESNFE" $ Upper( aDocs[nX]:_SCHEMA:TEXT ) .Or. "PROCNFE" $ Upper( aDocs[nX]:_SCHEMA:TEXT ) .Or. ;
									"PROCEVENTO" $ Upper( aDocs[nX]:_SCHEMA:TEXT ) 

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Schema Resnfe - Resumo da nota baseado no modelo de schema "resNFe_v1.00.xsd" ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								// Resumo da NF-e
								If "RESNFE" $ Upper( aDocs[nX]:_SCHEMA:TEXT )

										cSitConf := "0" // Sem manifestacao

										if type("oXmlDoc:_RESNFE:_RESCANC") <> "U"
											cCancNSU := oXmlDoc:_RESNFE:_RESCANC:TEXT
										endif

										if type( "oXmlDoc:_RESNFE:_CHNFE:TEXT" ) <> "U"
											cChave		:= oXmlDoc:_RESNFE:_CHNFE:TEXT
										endif

										if type( "oXmlDoc:_RESNFE:_CNPJ:TEXT" ) <> "U"
											cCNPJEmit		:= oXmlDoc:_RESNFE:_CNPJ:TEXT
										endif

										if type( "oXmlDoc:_RESNFE:_CPF:TEXT" ) <> "U"
											cCNPJEmit		:= oXmlDoc:_RESNFE:_CPF:TEXT
										endif

										if type( "oXmlDoc:_RESNFE:_XNOME:TEXT" ) <> "U"
											cNomeEmit		:= Upper( NoAcento( oXmlDoc:_RESNFE:_XNOME:TEXT ) )
										endif

										if type( "oXmlDoc:_RESNFE:_IE:TEXT" ) <> "U"
											cIeEmit		:= oXmlDoc:_RESNFE:_IE:TEXT
										endif

										if type( "oXmlDoc:_RESNFE:_DHEMI:TEXT" ) <> "U"
											dDtEmi	:= cToD( subStr( oXmlDoc:_RESNFE:_DHEMI:TEXT, 9, 2 ) + "/" + subStr( oXmlDoc:_RESNFE:_DHEMI:TEXT, 6, 2 ) + "/" + subStr( oXmlDoc:_RESNFE:_DHEMI:TEXT, 1, 4 ) )
										endif

										if type( "oXmlDoc:_RESNFE:_TPNF:TEXT" ) <> "U"
											cDocTpOp		:= oXmlDoc:_RESNFE:_TPNF:TEXT
										endif

										if type( "oXmlDoc:_RESNFE:_VNF:TEXT" ) <> "U"
											nValDoc		:= val( oXmlDoc:_RESNFE:_VNF:TEXT )
										endif

										if type( "oXmlDoc:_RESNFE:_DHRECBTO:TEXT" ) <> "U"
											dDtRec		:= cToD( subStr( oXmlDoc:_RESNFE:_DHRECBTO:TEXT, 9, 2 ) + "/" + subStr( oXmlDoc:_RESNFE:_DHRECBTO:TEXT, 6, 2 ) + "/" + subStr( oXmlDoc:_RESNFE:_DHRECBTO:TEXT, 1, 4 ) )
										endif

										if type( "oXmlDoc:_RESNFE:_CSITNFE:TEXT" ) <> "U"
											cDocSit		:= oXmlDoc:_RESNFE:_CSITNFE:TEXT
										endif

								Endif

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Schema PROCNFE - XML NFe baseado no modelo de schema procNFe_v3.10.xsd 	 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								// Documento da NF-e
								If "PROCNFE" $ Upper( aDocs[nX]:_SCHEMA:TEXT )
								
									cSitConf := "0" // Sem manifestacao

									if type("oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE") <> "U"
										cChave		:= oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
									elseif type("oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE") <> "U"
										cChave		:= oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
									endif

									if type("oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ") <> "U"
										cCNPJEmit	:= oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
									elseif type("oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF") <> "U"
										cCNPJEmit	:= oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT
									endif

									if type("oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE") <> "U"
										cIeEmit	:= oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT
									endif

									if type("oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME") <> "U"
										cNomeEmit	:= 	oXmlDoc:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT
									endif

									if type("oXmlDoc:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI") <> "U"
										dDtEmi	:= 	cToD( subStr( oXmlDoc:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT, 9, 2 ) + "/" + subStr( OXMLDOC:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT, 6, 2 ) + "/" + subStr( OXMLDOC:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT, 1, 4 ) )
									endif
									if type("oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO") <> "U"
										dDtRec	:= 	cToD( subStr( oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT, 9, 2 ) + "/" + subStr( oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT, 6, 2 ) + "/" + subStr( oXmlDoc:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT, 1, 4 ) )
									endif
									if type("oXmlDoc:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF") <> "U"
										nValDoc	:= Val( oXmlDoc:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT )
									endif

								EndIf


								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Schema PROCEVENTO - XML NFe baseado no modelo de schema procEventoNFe_v1.00.xsd  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								// Documento da NF-e - 110111 - Notas Canceladas
								
								If "PROCEVENTO" $ Upper( aDocs[nX]:_SCHEMA:TEXT )  
								
									If type("oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT") <> "U" .And.;
								 	(oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT  $ "|110111|")
									
										cSitConf := "3" //Cancelamento
										
										if type(aDocs[nX]:_NSU:TEXT) <> "U"
											cCancNSU := aDocs[nX]:_NSU:TEXT // NSU do cancelamento
										endif
										
										If Type( "oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_CHNFE:TEXT" ) <> "U"
											cChave		:= oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_CHNFE:TEXT
										Endif
									
										if Empty( cChave )
											cChave := ""
										Endif
									
										If Type( "oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT" ) <> "U"
											cTpEvento	:= Alltrim( oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT )
										Endif
	
										if type("oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_CNPJ") <> "U"
											cCNPJEmit	:= oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_CNPJ:TEXT
										elseif type("oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_CPF") <> "U"
											cCNPJEmit	:= oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_CPF:TEXT
										endif
		
										if type("oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_DHEVENTO") <> "U"
											dDtEmi	:= 	cToD( (subStr( oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_DHEVENTO:TEXT, 9, 2 ) + "/" + subStr( oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_DHEVENTO:TEXT, 6, 2 ) + "/" + subStr( oXmlDoc:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_DHEVENTO:TEXT, 1, 4 )) )
										endif
										if type("oXmlDoc:_PROCEVENTONFE:_RETEVENTO:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO") <> "U"
											dDtRec	:= 	cToD( subStr( oXmlDoc:_PROCEVENTONFE:_RETEVENTO:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT, 9, 2 ) + "/" + subStr( oXmlDoc:_PROCEVENTONFE:_RETEVENTO:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT, 6, 2 ) + "/" + subStr( oXmlDoc:_PROCEVENTONFE:_RETEVENTO:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT, 1, 4 ) )
										endif

									Endif

								EndIf

								cDesResp	:= cMotivo
								cDesCod	:= cStat

								// Esta tag não existe na nova consulta
								if !Empty( cSitConf )
										if SincAtuDados(cChave,cSitConf,cCancNSU)
											MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc)
										endif
								endif
// ------------------------ Documentos não incluidos na sincronização
//								"110110"							// Carta de Correcao
//								"411500|411501|411502|411503"	// Evento de Pedido de Prorrogacao 

							EndIf
					next nx

				//Atualizo com o último NSU
						ColSetPar("MV_ULTNSU",oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_MAXNSU:TEXT)

				//Atualizo o Flag para que não seja atualizado o mesmo retorno.
						ColSetPar("MV_MDEFLAG","0")

				else
				//Atualizo com o último NSU
						ColSetPar("MV_ULTNSU",oXml:_PROCNFEDISTDFE:_RETDISTDFEINT:_MAXNSU:TEXT)

				//Atualizo o Flag para que não seja atualizado o mesmo retorno.
						ColSetPar("MV_MDEFLAG","0")
						cMsg := "Sincronização finalizada não existem mais documentos a serem recebidos no momento."
				endif
			Endif
	elseIf  ColGetPar('MV_MDEFLAG',"0")== "0"
			cMsg := "Solicitação de sincronização já processada, realize uma nova sincronização para trazer novos dados." 
	elseif Empty( oDoc:cXMLRet )
		cMsg := "Solicitação de sincronização ainda não obteve o retorno, aguarde mais alguns segundos. Arquivo de solicitação " + oDoc:cNomeArq	 
	endif
else
	cMsg := "Sincronização não foi solicitada."
endif

oXml 	 := nil
oDoc 	 := nil
aRet 	 := nil
oXmlDoc := nil

delclassintf()

return()
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColMdeDown
Realiza a solicitação do Downlod da NF-e para a NeoGrid.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 						
@param	@cMsg, string, Variável que irá receber a mensagem do resultado do processamento.

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------
function ColMdeDown( aChaves, cMsg )

local cChave		:= ""
local cAmbiente	:= ColGetPar("MV_AMBIENT","2") 
local cCNPJDest	:= SM0->M0_CGC
local cDados		:= ""
local cAviso		:= ""
local nx 			:= 0
local lOk			:= .T.

default cMsg			:= ""

for nx := 1 to len(aChaves)

	cCHave := aChaves[nX]
	
	cDados	:= '<downloadNFe versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'		
	cDados	+= "<tpAmb>" + cAmbiente + "</tpAmb>"
	cDados	+= "<xServ>DOWNLOAD NFE</xServ>"
	cDados	+= "<CNPJ>" + cCNPJDest + "</CNPJ>"
	cDados	+= "<chNFe>" + cChave + "</chNFe>"	
	cDados	+= "</downloadNFe>"
	
	oDoc 			:= ColaboracaoDocumentos():new()		
	oDoc:cModelo	:= "MDE"
	oDoc:cTipoMov	:= "1"
	//Coloca no IDERP o prefixo Down + CNPJ do Emitente + Serie + Numero + Empresa + Filial									
	oDoc:cIDERP	:= "DOWN"+SubStr(aChaves[nX],7,14)+SubStr(aChaves[nX],23,3)+SubStr(aChaves[nX],26,9)+FwGrpCompany()+FwCodFil()
	
	//Caso o documento não esteja flegado não solicita novamente
	if odoc:consultar() .And. oDoc:cFlag == "0"
		cAviso += SubStr(aChaves[nX],23,3)+ "    "+SubStr(aChaves[nX],26,9) + CRLF
		loop
	else								
		oDoc:cNomeArq := ""
		oDoc:cQueue	:= "336" // 336 Download do XML
		oDoc:cIDERP	:= "DOWN"+SubStr(aChaves[nX],7,14)+SubStr(aChaves[nX],23,3)+SubStr(aChaves[nX],26,9)+FwGrpCompany()+FwCodFil()
		oDoc:cXml		:= cDados
		
		
		if odoc:transmitir()		
			cAviso += SubStr(aChaves[nX],23,3)+ "    "+SubStr(aChaves[nX],26,9) + CRLF
		endif
					
	endif
			
next

if !Empty( cAviso )
	cMsg := "Solicitação realizada com sucesso: "+ CRLF + CRLF + "Série  Número" + CRLF + cAviso
else
	cMsg := "Não existem arquivos para serem solicitados."
endif

return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColDownTela
Realiza a montagem da tela de download do MD-e 
 
@author 	Rafel Iaquinto
@since 		20/08/2014
@version 	11.9

@param	aChaves, string, Chaves dos documentos que deseja ser baixado. 						
@param	@cAviso, string, Variável que irá receber a mensagem do resultado do processamento.

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------
function ColDownTela( aChaves )

Local cMsgTitle	:= "Monitor de Download MD-e - TOTVS Colaboração 2.0"
Local aListNotas	:= {}
Local aTitulos	:= {' ', ' ', 'CNPJ Emit.', 'Serie', 'Numero', 'Arquivo'} //Boletim Técnico
Local oDlg		:= Nil
Local oListDocs	:= Nil
Local oBtnOk		:= Nil
Local oBtnBaixar	:= Nil
Local oBtnAtu		:= Nil
Local oBtnLeg		:= Nil
Local oOK := LoadBitmap(GetResources(),'br_verde')
Local oNO := LoadBitmap(GetResources(),'br_vermelho') 
Local oBmpVerm	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oBmpVerd	:= LoadBitmap( GetResources(), "BR_VERDE" )

Local oMNo        := LoadBitMap(GetResources(),"LBNO")
Local oMOk        := LoadBitMap(GetResources(),"LBOK")
Local lMarkAll	:= .T.


aListNotas := getListDown(aChaves)
	


if Len( aListNotas ) > 0
	
	DEFINE MSDIALOG oDlg; 
	TITLE cMsgTitle; 
	FROM 10,10 TO 440,600 PIXEL OF oMainWnd PIXEL
	
	DEFINE FONT oFont BOLD
			
	
	oListDocs := TWBrowse():New( 07,07,280,180,,aTitulos,,oDlg,,,,,,,,,,,,,"ARRAY",.T.)
	oListDocs:SetArray( aListNotas )
	oListDocs:bLine      := {|| { iif(aListNotas[oListDocs:nAt,1] == "2", oOK , oNO ),;
									If(aListNotas[oListDocs:nAt,2], oMOk, oMNo),;
							   		aListNotas[oListDocs:nAT,3],;
									aListNotas[oListDocs:nAT,4],;
									aListNotas[oListDocs:nAT,5],;
									aListNotas[oListDocs:nAT,6] } }
	
	oListDocs:bLDblClick  := {|| aListNotas[oListDocs:nAt,2] := iif(aListNotas[oListDocs:nAt,1] == "1",(Aviso("Arquivo sem retorno, aguarde!","Arquivo com download indisponível não pode ser marcado.",{"Ok"},3),aListNotas[oListDocs:nAt,2]),!aListNotas[oListDocs:nAt,2]), oListDocs:Refresh()}
	oListDocs:bHeaderClick := {|| aEval(aListNotas, {|e| e[2] := iif(e[1] == "2",!e[2],.F.)}), oListDocs:Refresh()}
	
	//======================= Legendas ===========================	
	@ 190,010 BITMAP oBmpVerd RESOURCE "BR_VERDE.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
	@ 190,020 SAY oSay PROMPT "Download Disponível" SIZE 100,010 PIXEL OF oDlg FONT oFont//"Arquivo Retornado"
	
	@ 190,080 BITMAP oBmpVerm RESOURCE "BR_VERMELHO.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
	@ 190,090 SAY oSay PROMPT "Download Indisponível" SIZE 100,010 PIXEL OF oDlg FONT oFont//Arquivo ainda sem retorno	
	//======================= Buttons ===========================	
	@ 200,252 BUTTON oBtnOk  	PROMPT "OK"			ACTION (oDlg:End(),aListNotas:={}) OF oDlg FONT oFont PIXEL SIZE 035,013 //"OK"
	@ 200,215 BUTTON oBtnAtu 	PROMPT "Atualizar"	ACTION (aListNotas := getListDown(aChaves),ColDownRefresh(oDlg, oListDocs, aListNotas)) OF oDlg FONT oFont PIXEL SIZE 035,013 //"Refresh"	
	@ 200,178 BUTTON oBtnBaixar PROMPT "Baixar"		ACTION {|| Aviso("Monitor Download - MDe",ColMdeSave(aListNotas),{"Ok"},3) , aListNotas := getListDown(aChaves), ColDownRefresh(oDlg, oListDocs, aListNotas) } OF oDlg FONT oFont PIXEL SIZE 035,013 //"OK"
									
	ACTIVATE MSDIALOG oDlg CENTERED
else
	Aviso("Monitor Download - MDe","Não foram encontrado arquivos pendentes para download.",{"Ok"},3)	
endif


return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColDownTela
Realiza a montagem da tela de download do MD-e 
 
@author 	Rafel Iaquinto
@since 		20/08/2014
@version 	11.9
 						
@param	@cMsg, string, Variável que irá receber a mensagem do resultado do processamento.

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------
function ColEveMonit(aChaves, cCodEve, cModelo )

local oDoc := Nil
local cIdErp	:= ""
local cOpcUpd := ""
local cErro 	:= ""
local cAviso	:= ""
local cIdEvent:= ""
local cAmbient:= ""
local cStatus	:= ""
local lFilEve	:= .F.

local nx		:= 0

local aMonitor	:= {}
local aDados		:= {}
local aDadosXml	:= {}
Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")

default cModelo:= ""

for nx := 1 to len( aChaves )
	
	cIdErp 	:= ""
	cModelo	:= ""
	cMensagem	:= ""
	cIdEvent	:= ""
	cAmbient	:= ""
	cStatus	:= ""
	cChave		:= ""
	lFilEve	:= .F.
	
	If cCodEve $ "210200-210210-210220-210240" //MDE
		cModelo := "MDE"
		cIdErp  := "MDE"+SubStr(aChaves[nX],7,14)+SubStr(aChaves[nX],23,3)+SubStr(aChaves[nX],26,9)+FwGrpCompany()+FwCodFil()
		cMod	 := ""
		lFilEve := .T.
	EndIf
	
	oDoc := ColaboracaoDocumentos():new()
	oDoc:cTipoMov	:= "1"
	oDoc:cModelo	:= cModelo
	oDoc:cIdErp	:= cIdErp
		
	if odoc:consultar()
				
		aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NPROT")
		aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|CSTAT")
		aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|XMOTIVO")
		aadd(aDados,"PROCEVENTONFE|EVENTO|INFEVENTO|ID")
		aadd(aDados,"EVENTO|INFEVENTO|ID")
		aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|TPAMB")
		aadd(aDados,"EVENTO|INFEVENTO|TPAMB")
		
		
		//Busca os dados do XML
		if !Empty( oDoc:cXMLRet )
			cXml := oDoc:cXMLRet
		else
			cXml := oDoc:cXML
		endif
		aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)
		
		//Filtra por tipo do evento passado por parâmetro
		If !lFilEve .or. (lFilEve .And. ( SubStr(aDadosXml[5],3,6) == cCodEve .Or. SubStr(aDadosXml[4],3,6) == cCodEve ))
			//Faz o tratamento do nStatus
			//para retornar igual ao TSS
			if odoc:cCdStatDoc == "1"			
				//Aguardando processamento
				cStatus	:= "1"
				cMensagem	:= "Envio de Evento realizado - Aguardando processamento"
				cIdEvent	:= aDadosXml[5]
				cAmbient	:= aDadosXml[7]
				
			elseIf !Empty( aDadosXml[1] )			
				//Evento vinculado com sucessl
				cStatus 	:= "6"
				cMensagem	:= aDadosXml[3]
				cIdEvent	:= aDadosXml[4]
				cAmbient	:= aDadosXml[6]
			else			
				//Evento rejeitado
				cStatus 	:= "5"
				cMensagem	:= aDadosXml[3]
				cIdEvent	:= aDadosXml[4]
				cAmbient	:= aDadosXml[6]
				
			endif
			  
				
			AADD( aMonitor, {	If(Empty( aDadosXml[1] ),oNo,oOk),;
											aDadosXml[1],;
											cIdEvent,;
											cAmbient,;	
											cStatus,;
											cMensagem,;
											cXml })
				
			//Atualizacao do Status do registro de saida
			cOpcUpd := "0"				
			If cStatus	== "3" .Or. cStatus == "5"
				cOpcUpd :=	"4"  //Evento rejeitado +msg rejeiçao
			ElseIf cStatus == "6"  
				cOpcUpd := "3"  //Evento vinculado com sucesso
			ElseIf cStatus == "1"
				cOpcUpd := "2"  //Envio de Evento realizado - Aguardando processamento
			EndIF
			
			cChave:= Substr(cIdEvent,9,44)
				
			AtuCodeEve( cChave, cOpcUpd, cCodEve, cMod )
		endif
	
	endif
Next

oDoc := Nil
DelClassIntF()

return (aMonitor)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColMdfMon
Monta o array pronto para o monitor do MDF-e via TOTVS Colaboração 2.0. Deve retornar no mesmo padrão da função MDFeWSMnt
 
@author 	Rafel Iaquinto
@since 		27/08/2014
@version 	11.8
 						
@param	cSerie, string, Serie do documento desejado.
@param	cMdfMin, string, Numero inicial
@param	cMdfFim, string, Numero do MDF Final.
@param	lMonitor, lógico, indica se deve devolver o array do  monitor preenchido.

@return aList array Retorna um array com os dados a serem apresentados no monitor.
/*/
//-----------------------------------------------------------------------
function ColMdfMon(cSerie, cMdfIni, cMdfFim, lMonitor)

local cErro		:= ""
local cAviso		:= ""
local cXml			:= ""
local cProtocolo	:= ""
local cIdMdfe		:= ""
local cAmbiente	:= ""
local cModalidade	:= ""
local cRecomenda	:= ""
local cRetCSTAT 	:= ""
local cMsgRetNfe	:= ""	
local cCodEdiInc	:= ""

local nx			:= 0
local ny			:= 0

local aList		:= {}
local aMsg			:= {}
local aDocs		:= {}
local aDados		:= {}
local aDadosCanc	:= {}
local aDadosEnce	:= {}
local aDadosXml 	:= {}
local aDadosInc		:= {}

local lOk			:= .F.

Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")
local oDoc			:= nil
Local nTamDoc 		:= TamSx3("F2_DOC")[1]
Local nTamSer 		:= TamSx3("F2_SERIE")[1]

default lMonitor	:= .T.

if lMonitor
	if 	cMdfFim >= cMdfIni 	
		While cMdfIni <= cMdfFim								
			aadd(aDocs,"MDF"+cSerie+cMdfIni+ FwGrpCompany()+FwCodFil() )
			cMdfIni := Soma1(cMdfIni)			 
		Enddo		
		lOk := .T.
	endif
	if lOk
		
		cCodEdi			:= "360"
		cCodEdiCanc		:= "362"
		cCodEdiEnc		:= "361"
		cCodEdiInc			:= "420"
		
		aDados		:= ColDadosNf(1,"58")
		aDadosCanc	:= ColDadosNf(2,"58")
		aDadosEnce	:= ColDadosNf(3,"58")
		aDadosInc	:= ColDadosNf(4,"58")
		
		for nX := 1 to len( aDocs )
			cProtocolo		:= ""
			cIdMdfe 		:= ""
			cAmbiente		:= ""
			cModalidade	:= ""	
			cRecomenda		:= "" 
			
			oDoc := ColaboracaoDocumentos():new()
			oDoc:cTipoMov	:= "1"
			oDoc:cModelo	:= "MDF"
			oDoc:cIdErp	:= aDocs[nx]
						
			
			if odoc:consultar()
				oDoc:lHistorico	:= .T.	
				odoc:buscahistorico()
				
				//Busca os dados do XML
				if !Empty( oDoc:cXMLRet )
					cXml := oDoc:cXMLRet
				else
					cXml := oDoc:cXML
				endif
				
				//Pega os dados conforme a situação do documento
				do case 
					case oDoc:cQueue == cCodEdi //360 - MDF-e - Emissão
						aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)					  	
						
					case oDoc:cQueue == cCodEdiCanc //362 - MDF-e - Cancelamento
						aDadosXml := ColDadosXMl(cXml, aDadosCanc, @cErro, @cAviso)
					 						
					case oDoc:cQueue == cCodEdiEnc //361 - MDF-e – Encerramento
						aDadosXml := ColDadosXMl(cXml, aDadosEnce, @cErro, @cAviso) 
					
					case oDoc:cQueue == cCodEdiInc //420 - MDF-e – Inclusão de Condutor 
						aDadosXml := ColDadosXMl(cXml, aDadosInc, @cErro, @cAviso)  					
				end
							
				//Guarda os valores da consulta atual do documento
				cProtocolo		:= aDadosXml[1]
				cIdMdfe		    := "MDF" + Padr(oDoc:cSerie, nTamSer) + Padr(oDoc:cNumero, nTamDoc) + FwGrpCompany()+FwCodFil()
				cAmbiente		:= iif(!Empty(aDadosXml[2]),aDadosXml[2],aDadosXml[3])
				if oDoc:cQueue $ cCodEdiCanc+"|"+cCodEdiEnc+"|"+cCodEdiInc 
					cModalidade	:= "1" //Cancelamento e encerramento sempre é em modalidade normal.
				else
					cModalidade	:= iif(!Empty(aDadosXml[4]),aDadosXml[4],aDadosXml[7])
				endif
					cRetCSTAT := aDadosXml[4]
					cMsgRetNfe:= aDadosXml[6]				

				cRecomenda		:= colRecomendacao("58",oDoc:cQueue,@cProtocolo,,oDoc:cCdStatDoc,cRetCSTAT,cMsgRetNfe)
			
				
				//Não ordenar pois o último registro deve ser o autorizado.
				//aSort(oDoc:aHistorico,,,{|x,y| ( if( Empty(x[4]),"99/99/9999",DToC(x[4])) +x[5] > if(empty(y[4]),"99/99/9999",DToC(x[4]))+y[5])})				
				for ny := 1 to Len( oDoc:aHistorico )
						aDadosXml	:= {}
						cErro		:= ""
						cAviso		:= ""
						cXmlHist	:= ""
							
						
						if !Empty(oDoc:aHistorico[ny][2])
							cXMLHist	:= oDoc:aHistorico[ny][2] 
						else
							cXMLHist	:= oDoc:aHistorico[ny][3]
						endif
																
						do case 
							case oDoc:aHistorico[ny][08] == cCodEdi
								aDadosXml := ColDadosXMl(cXMLHist, aDados, @cErro, @cAviso)
										
							case oDoc:aHistorico[ny][08] == cCodEdiCanc
								aDadosXml := ColDadosXMl(cXMLHist, aDadosCanc, @cErro, @cAviso)
								
							case oDoc:aHistorico[ny][08] == cCodEdiEnc
								aDadosXml := ColDadosXMl(cXMLHist, aDadosEnce, @cErro, @cAviso) 
							
							case oDoc:aHistorico[ny][08] == cCodEdiInc
								aDadosXml := ColDadosXMl(cXMLHist, aDadosInc, @cErro, @cAviso)  
						end
						
						aadd(aMsg,{0,; //Número do Lote - não existe no retorno da NeoGrid
									oDoc:aHistorico[ny][4],; // Data de envio do Lote - utilizar o que está gravado na CKO
									oDoc:aHistorico[ny][5],; // Hora de Envio do Lote - utilizar o que está gravado na CKO
									0,; // Número do recibo do Lote - não existe no retorno da NeoGrid
	 								odoc:aHistorico[ny][6],; //Codigo do envio do Lote -não tem no XML da NeoGrid - Usar do odoc:aHistorico[ny][6](CKO)
				 					padr(Alltrim(odoc:aHistorico[ny][7])+" - "+ oDoc:aHistorico[ny][01],100),; //mensagem do envio dolote - não tem no XML da NeoGrid - Usar do odoc:aHistorico[ny][7](CKO)
	 								"",; //Codigo do recibo do lote - Não tem no XML da SEFAZ -  Usar do odoc:aHistorico[ny][6](CKO)
				 					"",;//Mensagem do Recibo do Lote - Não tem no XML da NeoGrid
									aDadosXml[05],; //Codigo de retorno da NFe - Pegar do XML da NeoGrid.
				 					DecodeUtf8(padr(aDadosXml[06],150))}) // Mensagem de retorno da NF-e - Pegar XML da NeoGrid
				 									 	
													
				next ny			

				aadd(	aList,{ IIf(Empty(cProtocolo),oNo,oOk),;
						cIdMdfe,;
						IIf(cAmbiente=="1","Produção","Homologação"),; //"ProduşÒo"###"HomologaşÒo"
						IIf(cModalidade=="1","Normal","Contingência"),; //"Normal"###"ContingÛncia"
						cProtocolo,;
						cRecomenda,;
						"0",;
						0,;
						aMsg} )
					
				aMsg 		:= {}										
								
			endif
			
		next nx		
	endif

endif

return(aList)

static function ColDownRefresh(oDlg, oListDocs, aListNotas)

Local oOK := LoadBitmap(GetResources(),'br_verde')
Local oNO := LoadBitmap(GetResources(),'br_vermelho')
Local oMNo        := LoadBitMap(GetResources(),"LBNO")
Local oMOk        := LoadBitMap(GetResources(),"LBOK")

oListDocs:SetArray( aListNotas )
oListDocs:bLine      := {|| { iif(aListNotas[oListDocs:nAt,1] == "2", oOK , oNO ),;
								If(aListNotas[oListDocs:nAt,2], oMOk, oMNo),;
						   		aListNotas[oListDocs:nAT,3],;
								aListNotas[oListDocs:nAT,4],;
								aListNotas[oListDocs:nAT,5],;
								aListNotas[oListDocs:nAT,6] } }

oListDocs:nAt:=1
If(Empty(aListNotas),(Aviso("Monitor Download - MDe","Não foram encontrado arquivos pendentes para download.",{"Ok"},3),oDlg:End()),"")
oListDocs:Refresh()
	
return


//-------------------------------------------------------------------
/*/{Protheus.doc} XmlMDFTrans
Funcao responsavel pela geracao do XML de MDFe para TOTVS Colaboracao 


@param		aNotas		Dados do documento a ser processado
			aXML		Xml do MDFe
			oXmlRem	Objeto com os dados MDFe
			
			
@return	lGerado	Retorna se foi gerado o MDFe

@author	Douglas Parreja
@since		27/08/2014
@version	11.7
/*/
//-------------------------------------------------------------------		
Function XmlMDFTrans( aNotas, aXML, cCodMod, cErro, cEvento )

	Local cGrupo			:= FWGrpCompany()		//Retorna o grupo
	Local cFil 			:= FWCodFil()			//Retorna o código da filial
	Local cDesMod			:= ""
	Local cCodQueue		:= ""
	Local cIDErp			:= "" 
	
	Local lGerado			:= .F.
	
	Default aNotas		:= {}
	Default aXML			:= {}
	Default cCodMod		:= ""
	Default cErro			:= ""
	Default cEvento		:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica qual Evento esta passando para gerar o arquivo com Queue correto ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEvento == "110110"		// Emissao MDFe
		cCodQueue := "360"
	ElseIf cEvento == "110111"	// Cancelamento MDFe
		cCodQueue := "362"
	ElseIf cEvento == "110112"	// Encerramento MDFe
		cCodQueue := "361"		
	ElseIf cEvento == "110114"	// Inclusao de condutor MDFe
		cCodQueue := "420"		
	EndIf
	
	// Modelo ICC = Inclusao de condutor MDFe
	If cEvento == "110114"
		cIDErp  := "ICC"+aNotas[2]+aNotas[3]+cGrupo+cFil
	Else 
		cIDErp := "MDF"+aNotas[2]+aNotas[3]+cGrupo+cFil
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MDFe - Manifesto Eletronico de Documentos Fiscais                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesMod := ModeloDoc(Alltrim(cCodMod),cEvento)
	
	oTemp := ColaboracaoDocumentos():new()		
	
	oTemp:cModelo 		:= cDesMod											// Modelo do Documento					
	oTemp:cNumero		:= aNotas[3]										// Numero do Documento
	oTemp:cSerie		:= aNotas[2]										// Serie do Documento
	oTemp:cIdErp 		:= cIDErp											// ID Erp (Serie+NF+Emp+Fil)	
	oTemp:cXml			:= aXml 											// XML
	oTemp:cTipoMov	:= "1"												// Tipo de Movimento 1-Saida / 2-Recebimento  
	oTemp:cQueue		:= cCodQueue										// Codigo Queue 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Metodo Transmitir                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
	lGerado := oTemp:transmitir()
	
	If !lGerado
		cErro := oTemp:cMsgErr
	EndIf
		

Return ( lGerado )

//-----------------------------------------------------------------------
/*/{Protheus.doc} getListDown
Filtra da lista de chaves apenas as que foram solicitadas os downloads. 
 
@author 	Rafel Iaquinto
@since 		20/08/2014
@version 	11.9
 						
@param	@cMsg, string, Variável que irá receber a mensagem do resultado do processamento.

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------
static function getListDown(aChaves)

local nx			:= 0
local aListNotas	:= {}

local oDoc			:= Nil

oDoc := ColaboracaoDocumentos():new()

for nX := 1 to len( aChaves )
	oDoc:cTipoMov	:= "1"
	oDoc:cQueue	:= "336" // 336 - Download de documentos
	oDoc:cModelo	:= "MDE"
	oDoc:cIDERP	:= "DOWN"+SubStr(aChaves[nX],7,14)+SubStr(aChaves[nX],23,3)+SubStr(aChaves[nX],26,9)+FwGrpCompany()+FwCodFil()
	
	if oDoc:consultar() .And. oDoc:cFlag == "0"
		
		AAdd( aListNotas, { oDoc:cCdStatDoc,; //Legenda
					.F.,; //Mark
					SubStr(aChaves[nX],7,14),; //CNPJ Emitente
					SubStr(aChaves[nX],23,3),; //Serie
					SubStr(aChaves[nX],26,9),; //Número
					oDoc:cNomeArq,;//Nome do arquivo
					oDoc:cXMLRet } ) //XML de retorno
	endif 
	
next

return(aListNotas)

static function ColMdeSave(aListNotas)

local nX			:= 0

local cDir			:= ""
local cMsgResult	:= ""
local cChave		:= ""

local lMark		:= .F.

lMark := aScan( aListNotas,{|x| x[2] == .T. } ) > 0

If lMark
	cDir := cGetFile('Arquivo *|*.*|Arquivo JPG|*.Jpg','Retorna Diretorio',0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
	if !Empty( cDir )	
		for nX := 1 to Len( aListNotas )
			cNome	:= ""
			if aListNotas[nX][2] .And. !Empty( aListNotas[nX][7] )
				cChave := SubStr(ColXmlAdjust( aListNotas[nX][7], "chNFe" ),8,44)
				if !Empty( cChave ) .And. ColSaveXML( cDir, cChave, ColXmlAdjust( aListNotas[nX][7], "procNFe" ) ) 									
					cMsgResult += SubStr(cChave,23,3)+ "    "+SubStr(cChave,26,9) + CRLF
					ColFlagDoc(aListNotas[nX][6],"1")
				endif
			endif
		next
		if !Empty( cMsgResult )
			cMsgResult := "Documentos baixados com sucesso" + CRLF + CRLF + cMsgResult			 
		endif		
	endif
else
	cMsgResult := "Nenhum registro foi marcado."
endif

return(cMsgResult)

Static function ColSaveXML(cDir, cNome, cXML )

local nHandle		:= 0
local lRet			:= .F.

nHandle  := FCreate(cDir+cNome+"-"+"procNFe.xml")
If nHandle > 0
	FWrite ( nHandle, cXML)
	FClose(nHandle)
	lRet := .T.
EndIf	

return( lRet )

static function ColFlagDoc(cNomeArq, cFlag)

local oDoc := Nil

oDoc := ColaboracaoDocumentos():new()
oDoc:cNomeArq	:= cNomeArq
oDoc:cFlag		:= cFlag

lFlegado := oDoc:flegadocumento()

oDoc := Nil
DelClassIntF()

return(lFlegado)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColXmlSinc
Monta o XML de sincronização do MDe, via TOTVS Colaboração.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 						
@param	cAmbiente, string, Ambiente para sincronizar<br>1-Produção<br>2-Homologação
@param cVerMde, string, Versão do MDe
@param cCnpj, string, CNPJ dos documentos destinados.
@param cIndNFe,string,Indicador de NF-e consultada
@param cUltimoNSU,string,Último NSU recebido pela Empresa.
@param cIndEmi,string,Indicador do emissor.

@return lRet lógico retorna .T. se a geração do arquivo for feita com sucesso.
/*/
//-----------------------------------------------------------------------

static function ColXmlSinc(cAmbiente,cVerMde,cCnpj,cIndNFe,cUltimoNSU,cIndEmi,cUFAutor,lCheck1)

local cXml			:= ""

default cAmbiente		:= ColGetPar( 'MV_AMBIENT', '2' ) 
default cVerMde 		:= ColGetPar( 'MV_MDEVER','1.00' )
default cUltimoNSU	:= ColGetPar( 'MV_ULTNSU','000000000000000' )
default cIndEmi		:= "0"
default cIndNFe		:= "0"
default cCnpj			:= SM0->M0_CGC
default cUFAutor 		:= GetUFCode(Upper(Alltrim(SM0->M0_ESTENT)))
default lCheck1      := .F.
If Empty(cUltimoNSU) .Or. cUltimoNSU == "0" .Or. lCheck1
	cUltimoNSU := '000000000000000'
EndIf  
//NSU não deve conter tamanho maior que 15 dígitos
cUltimoNSU := IIF ( len (cUltimoNSU) > 15 , substr(cUltimoNSU,-15,15), cUltimoNSU )

cXml	:= '<distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="'+ cVerMde +'">'

cXml	+= "<tpAmb>" + cAmbiente + "</tpAmb>"
cXml	+= "<cUFAutor>"+ cUFAutor +"</cUFAutor>"
cXml	+= "<CNPJ>" + cCnpj + "</CNPJ>"
cXml	+= "<distNSU>"
cXml	+= "<ultNSU>" + cUltimoNSU + "</ultNSU>"
cXml	+= "</distNSU>"
cXml	+= "</distDFeInt>"
	

return( cXml )

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColTimeMnt
Função que devolve a lista de documentos do monitoramento por TEMPO.

@author	Rafael Iaquinto
@since		13/08/2014
@version	11.9

@param		nIntervalo, numerico, Intervalo em minutos a ser consultados. 

@return	aDocs	 Lista dos documentos disponíveis.
/*/
//-----------------------------------------------------------------------

static function ColTimeMnt( nIntervalo,cModelo )

local cHoraIni	:= Time()
local dDataIni	:= Date()
local aDocs		:= {}

default  nIntervalo	:= 30
default cModelo		:= "NFE"

SomaDiaHor(@dDataIni,@cHoraIni,-1*(nIntervalo)/60)

oDoc 			:= ColaboracaoDocumentos():new()		
oDoc:cModelo	:= cModelo
oDoc:cTipoMov	:= "1"

oDoc:buscaIdErpPorTempo(dDataIni,cHoraIni)

aDocs := aClone(oDoc:aNomeArq)

oDoc := Nil
DelClassIntF()

return ( aDocs )

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColRangeMnt
Função que devolve a lista de documentos do monitoramento por RANGE de IDERP.

@author	Rafael Iaquinto
@since		13/08/2014
@version	11.9

@param		nIntervalo, numerico, Intervalo em minutos a ser consultados. 

@return	aDocs	 Lista dos documentos disponíveis.
/*/
//-----------------------------------------------------------------------

static function ColRangeMnt( cIdIni,cIdFim, cModelo)

local aDocs		:= {}

oDoc 			:= ColaboracaoDocumentos():new()		
oDoc:cTipoMov	:= "1"

oDoc:buscaIdPorRange(cIdIni,cIdFim,cModelo)

aDocs := aClone(oDoc:aNomeArq)

oDoc := Nil
DelClassIntF()

return ( aDocs )

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColListPar
Função que devolve a lista de parâmetros para montagem da tela de configuração de parâmetros.

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9

@param		cModelo, string, 	Modelo do documento.
								NFE - NF eletronica
								CTE - CT eletronico
								CCE - Carta de Correção Eletronica
								MDE - Manifestação do Destinatário
								MDFE - Manifesto de documentos fis. Eletr.
								NFS - NF de Serviço eletrônica. 

@return	aListPar			Lista de parâmetros por tipo de documento.
								[1] - Nome do parâmetro
								[2] - Descrição do parâmetro
								[3] - Array com as opções do parâmetro
								[4] - Valor configurado do parâmetro, ou default caso não exista
/*/
//-----------------------------------------------------------------------
static function ColListPar(cModelo)

local aListPar := {}
Local lCTE:=  IIf (FunName()$"SPEDCTE,TMSA200,TMSAE70,TMSA500,TMSA050",.T.,.F.)
Default cModelo := "ALL"


	If cModelo $ "NFE|ALL"
		aadd( aListPar, {"MV_AMBIENT","Ambiente de transmissão", {"1=Produção","2=Homologação"}, ColGetPar("MV_AMBIENT","2"),.T.} )
		aadd( aListPar, {"MV_VERSAO" , "Versão da NF-e", {"3.10","4.00"}, ColGetPar("MV_VERSAO","3.10"),.T. } )
		aadd( aListPar, {"MV_VERDPEC", "Versão da DPEC da NF-e", {"1.01"}, ColGetPar("MV_VERDPEC","1.01"),.T. } )
		//aadd( aListPar, {"MV_VEREPEC", "Versão da EPEC da NF-e" , {"1.01"},ColGetPar("MV_VEREPEC","1.00"),.T. } )
		aadd( aListPar, {"MV_MODALID", "Modalidade de transmissão da NF-e",; 
								{"1=Normal",;
								"2=Contingência FS",;
								"3=Contingência SCAN",;
								"4=Contingência DPEC",;
								"5=Contingência FSDA",;
								"6=Contingência SVC-AN",;
								"7=Contingência SVC-RS"},;
								 ColGetPar("MV_MODALID","1"),.T. } )
		aadd( aListPar, {"MV_HRVERAO", "Horario de verão", {"1=Sim","2=Não"}, ColGetPar("MV_HRVERAO","2"),.T. } )
		aadd( aListPar, {"MV_HORARIO", "Horario", {"1=Fernando de Noronha","2=Brasilia","3=Manaus","4-Acre"}, ColGetPar("MV_HORARIO","2"),.T. } )
		aadd( aListPar, {"MV_NFXJUST", "Justificativa contigência", , ColGetPar("MV_NFXJUST",""),.F. } )
		aadd( aListPar, {"MV_NFINCON", "Data Hora contigência", ,ColGetPar("MV_NFINCON",""),.F. } )
	EndIf
																 
	If cModelo $ "NFS|ALL"
		aadd( aListPar, {"MV_AMBINSE", "Ambiente de transmissão do NFS-e",{"1=Produção","2=Homologação"},ColGetPar("MV_AMBINSE","2"),.T. } )
		aadd( aListPar, {"MV_VERNSE" , "Versão da NFS-e" , {"1.00","9.99"}, ColGetPar("MV_VERNSE","1.00"),.T. } )
	EndIf
				
	If cModelo $ "CTE|ALL"
		aadd( aListPar, {"MV_AMBCTE" , "Ambiente de transmissão do CT-e",{"1=Produção","2=Homologação"},ColGetPar("MV_AMBCTE","2"),.T. } )
		aadd( aListPar, {"MV_VERCTE" , "Versão da CT-e" , {"2.00","3.00"}, ColGetPar("MV_VERCTE","2"),.T. } )
		aadd( aListPar, {"MV_VEREPE" , "Versão EPEC" , {"1.01"}, ColGetPar("MV_VEREPE","1.01"),.T. }  )
		aadd( aListPar, {"MV_MODCTE" , "Modalidade de transmissão do CT-e",; 
								{"1=Normal",;
								"2=Contingência FS",;
								"3=Contingência SCAN",;
								"4=Contingência DPEC",;
								"5=Contingência FSDA",;
								"6=Contingência SVC-AN",;
								"7=Contingência SVC-RS",;
								"8=Contingência SVC-SP"},;
								 ColGetPar("MV_MODCTE","1"),.T. } )
		aadd( aListPar, {"MV_CTXJUST", "Justificativa contigência", , ColGetPar("MV_CTXJUST",""),.F. } )
		aadd( aListPar, {"MV_CTINCON", "Data Hora contigência", ,ColGetPar("MV_CTINCON",""),.F. } )
	EndIf
	
	If cModelo $ "CCE" .And.lCTE
		aadd( aListPar, {"MV_AMBICTE","Ambiente de transmissão CTe"		, {"1=Produção","2=Homologação"}						, ColGetPar("MV_AMBICTE","2"),.T.} )
		aadd( aListPar, {"MV_VLAYCTE","Versao do leiaute CTe"			, {"2.00","3.00"}											, ColGetPar("MV_VLAYCTE","2"),.T.} )
		aadd( aListPar, {"MV_EVENCTE","Versao do leiaute do evento CTe", {"2.00","3.00"}											, ColGetPar("MV_EVENCTE","2"),.T.} )
		aadd( aListPar, {"MV_LAYOCTE","Versao do evento CTe"				, {"2.00","3.00"}											, ColGetPar("MV_LAYOCTE","2"),.T.} )
		aadd( aListPar, {"MV_VERSCTE","Versão CC-e CTe"					, {"2.00","3.00"}											, ColGetPar("MV_VERSCTE","2"),.T.} )
		aadd( aListPar, {"MV_HRVERAO","Horario de verão NFe/CTe"		, {"1=Sim","2=Não"}										, ColGetPar("MV_HRVERAO","2"),.T.} )
		aadd( aListPar, {"MV_HORARIO","Horario NFe/CTe"					, {"1=Fernando de Noronha","2=Brasilia","3=Manaus","4-Acre"}	, ColGetPar("MV_HORARIO","2"),.T.} )
	elseIf cModelo $ "CCE"
		aadd( aListPar, {"MV_AMBIENT","Ambiente de transmissão NFe"		, {"1=Produção","2=Homologação"}						, ColGetPar("MV_AMBIENT","2"),.T.} )
		aadd( aListPar, {"MV_CCEVLAY","Versao do leiaute NFe"			, {"1.00"}													, ColGetPar("MV_CCEVLAY","2"),.T.} )
		aadd( aListPar, {"MV_EVENTOV","Versao do leiaute do evento NFe", {"1.00"}													, ColGetPar("MV_EVENTOV","2"),.T.} )
		aadd( aListPar, {"MV_LAYOUTV","Versao do evento NFe"				, {"1.00"}													, ColGetPar("MV_LAYOUTV","2"),.T.} )
		aadd( aListPar, {"MV_CCEVER" ,"Versão CC-e NFe"					, {"1.00"}													, ColGetPar("MV_CCEVER" ,"2"),.T.} )
		aadd( aListPar, {"MV_HRVERAO","Horario de verão NFe/CTe"		, {"1=Sim","2=Não"}										, ColGetPar("MV_HRVERAO","2"),.T.}	)
		aadd( aListPar, {"MV_HORARIO","Horario NFe/CTe"					, {"1=Fernando de Noronha","2=Brasilia","3=Manaus","4-Acre"}	, ColGetPar("MV_HORARIO","2"),.T.}	)
	EndIf
	
	If cModelo $ "MDE|ALL"			
		aadd( aListPar, {"MV_AMBIENT","Ambiente de transmissão", {"1=Produção","2=Homologação"}, ColGetPar("MV_AMBMDE","2"),.T.} )		
		aadd( aListPar, {"MV_MDEVER" ,"Versão MD-e", {"1.00"}, ColGetPar("MV_MDEVER","2"),.T.} )
		aadd( aListPar, {"MV_ULTNSU","Último NSU","", ColGetPar("MV_ULTNSU","0"),.F. } )				
	EndIf
					
	If cModelo $ "MDF|ALL"	//MDFe
		aadd( aListPar, {"MV_AMBMDF","Ambiente de transmissão", {"1=Produção","2=Homologação"}, ColGetPar("MV_AMBMDF","2"),.T.} )		
		aadd( aListPar, {"MV_MODMDF", "Modalidade de transmissão do MDF-e",; 
								{"1=Normal",;
								"2=Contingência"},;
								 ColGetPar("MV_MODMDF","1"),.T. } )
		aadd( aListPar, {"MV_EVENMDF","Versao do leiaute do evento", {"1.00","3.00"}, ColGetPar("MV_EVENMDF","3.00"),.T.} )
		aadd( aListPar, {"MV_VLAYMDF","Versao do leiaute", {"1.00","3.00"}, ColGetPar("MV_VLAYMDF","3.00"),.T.} )
		aadd( aListPar, {"MV_VERMDF" ,"Versão MDF-e", {"1.00","3.00"}, ColGetPar("MV_VERMDF","3.00"),.T.} )
		aadd( aListPar, {"MV_HRVERAO","Horario de verão NFe/CTe/MDFe"		, {"1=Sim","2=Não"}										, ColGetPar("MV_HRVERAO","2"),.T.}	)
		aadd( aListPar, {"MV_HORARIO","Horario NFe/CTe/MDFe"					, {"1=Fernando de Noronha","2=Brasilia","3=Manaus","4-Acre"}	, ColGetPar("MV_HORARIO","2"),.T.}	)
	EndIf 
	 
	If cModelo $ "EPP|ALL"	//Epp
		aadd( aListPar, {"MV_AMBIEPP","Ambiente de transmissão"		, {"1=Produção","2=Homologação"}						, ColGetPar("MV_AMBIENT","2"),.T.} )
		aadd( aListPar, {"MV_VEREPP", "Versão EPP",			{"1.00"} ,ColGetPar("MV_VEREPP","1.00"),.T. } )
		aadd( aListPar, {"MV_VEREPP1", "Versão Evento EPP",	{"1.00"} ,ColGetPar("MV_VEREPP1","1.00"),.T. } )
		aadd( aListPar, {"MV_VEREPP2", "Layout Evento EPP",	{"1.00"} ,ColGetPar("MV_VEREPP2","1.00"),.T. } )
		aadd( aListPar, {"MV_VEREPP3", "Versão EPP Layout", {"1.00"} ,ColGetPar("MV_VEREPP3","1.00"),.T. } )
		aadd( aListPar, {"MV_HRVERAO","Horario de verão NFe"		, {"1=Sim","2=Não"}										, ColGetPar("MV_HRVERAO","2"),.T.}	)
		aadd( aListPar, {"MV_HORARIO","Horario NFe"					, {"1=Fernando de Noronha","2=Brasilia","3=Manaus","4-Acre"}	, ColGetPar("MV_HORARIO","2"),.T.}	)
	Endif

return ( aListPar )

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColPutAPar
Funcao que atualiza uma lista de parâmetros.

@param		aParam,array,	Lista de parâmetros retornada pela função ColListPar
						  
@return	logico  

@author	Rafael Iaquinto
@since		15/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
static function ColPutArrParam( aParam )

local nx := 0

for nX := 1 to len( aParam )
	ColSetPar( aParam[nx][01], aParam[nX][04], aParam[nX][02] )
next

return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColListQueue
Função que retorna a lista de Queue da NeoGrid.

@param		cModelo	Modelo do documento caso deseja retornar apenas os
						queue do tipo de documento.
						  
@return	aListQueue	.T. Se existir.

@author	Rafael Iaquinto
@since		21/07/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
static function ColListQueue( cModelo )

local aListQueue	:= {}
	
default cModelo	:= "ALL"

if cModelo $ "NFE-ALL"
	//NFE-EMISSOES [1]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "170" ) //Emissão de NF-e
	aadd( atail(aListQueue), "171" ) //Cancelamento de NF-e
	aadd( atail(aListQueue), "172" ) //Inutilização de numeração de NF-e	
	aadd( atail(aListQueue), "206" ) //Consulta situação atual de NF-e
	aadd( atail(aListQueue), "207" ) //Consulta situação da SEFAZ NF-e
	aadd( atail(aListQueue), "197" ) //Consulta cadastro do contribuinte
	aadd( atail(aListQueue), "143" ) //Recebimento de NF-e - Envio
	aadd( atail(aListQueue), "169" ) //Recebimento de cancelamento de NF-e - Envio
	aadd( atail(aListQueue), "339" ) //Recebimento evento de cancelamento de NF-e - Envio	
	aadd( atail(aListQueue), "198" ) //Recebimento de NF-e pelo transportador - Envio
	aadd( atail(aListQueue), "337" ) //Processamento retroativo de XML Recebimento NFe - Envio
	
	//NFE-RETORNOS [2]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "170" ) //Retorno da emissão de NF-e
	aadd( atail(aListQueue), "171" ) //Retorno do cancelamento de NF-e
	aadd( atail(aListQueue), "172" ) //Retorno da inutilização de numeração de NF-e	
	aadd( atail(aListQueue), "206" ) //Retorno Consulta situação atual de NF-e
	aadd( atail(aListQueue), "207" ) //Retorno Consulta situação da SEFAZ NF-e
	aadd( atail(aListQueue), "197" ) //Retorno Consulta cadastro do contribuinte
	aadd( atail(aListQueue), "109" ) //Recebimento de NF-e - Retorno
	aadd( atail(aListQueue), "169" ) //Recebimento de cancelamento de NF-e - Retorno
	aadd( atail(aListQueue), "367" ) //Recebimento evento de cancelamento de NF-e - Envio
	aadd( atail(aListQueue), "322" ) //Recebimento de CC-e de NF-e - Envio
	aadd( atail(aListQueue), "198" ) //Recebimento de NF-e pelo transportador - Envio
		
endif
if cModelo $ "CTE-ALL"
	//CTE-EMISSOES [3]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "199" ) //Emissão de Ct-e
	aadd( atail(aListQueue), "200" ) //Cancelamento de CT-e
	aadd( atail(aListQueue), "201" ) //Inutilização de numeração de CT-e
	aadd( atail(aListQueue), "208" ) //Consulta situação atual de CT-e
	aadd( atail(aListQueue), "209" ) //Consulta situação da SEFAZ CT-e
	aadd( atail(aListQueue), "385" ) //Emissão de CC-e de CT-e
	aadd( atail(aListQueue), "165" ) //Recebimento de CT-e
	aadd( atail(aListQueue), "210" ) //Recebimento de cancelamento de CT-e - Envio
	aadd( atail(aListQueue), "384" ) //Recebimento de evento de cancelamento de CT-e - Envio
	aadd( atail(aListQueue), "382" ) //Recebimento de CC-e de CT-e - Envio
	
	//CTE-RETORNOS [4]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "199" ) //Retorno da emissão de CT-e
	aadd( atail(aListQueue), "200" ) //Retorno da cancelamento de CT-e
	aadd( atail(aListQueue), "201" ) //Retorno da inutilização de numeração de CT-e
	aadd( atail(aListQueue), "208" ) //Retorno Consulta situação atual de CT-e
	aadd( atail(aListQueue), "209" ) //Retorno Consulta situação da SEFAZ CT-e
	aadd( atail(aListQueue), "385" ) //Retorno da emissão de CC-e de CT-e
	aadd( atail(aListQueue), "214" ) //Recebimento de CT-e
	aadd( atail(aListQueue), "273" ) //Recebimento de CTEOS
	aadd( atail(aListQueue), "210" ) //Recebimento de cancelamento de CT-e - Retorno
	aadd( atail(aListQueue), "383" ) //Recebimento de evento de cancelamento de CT-e - Retorno
	aadd( atail(aListQueue), "381" ) //Recebimento de CC-e de CT-e - Retorno

endif
if cModelo $ "MDFE-ALL"
	//MDFE-EMISSOES [5]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "360" ) //MDF-e – Emissão
	aadd( atail(aListQueue), "361" ) //MDF-e – Encerramento
	aadd( atail(aListQueue), "362" ) //MDF-e – Cancelamento
	aadd( atail(aListQueue), "420" ) //MDF-e – Inclusão de Condutor (ainda não definido)
	aadd( atail(aListQueue), "530" ) //MDF-e – Consulta de Não Encerrados)
	
	//MDFE-RETORNOS [6]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "360" ) //MDF-e –Retorno da Emissão
	aadd( atail(aListQueue), "361" ) //MDF-e –Retorno do Encerramento
	aadd( atail(aListQueue), "362" ) //MDF-e –Retorno do Cancelamento
	aadd( atail(aListQueue), "420" ) //MDF-e – Retorno de Inclusão de Condutor (ainda não definido)
	aadd( atail(aListQueue), "530" 	) //MDF-e – Cnsulta de Não Encerrados
endif
if cModelo $ "NFS-ALL"
	//NFSE-EMISSOES [7]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "203" ) //Emissão de NFS-e
	aadd( atail(aListQueue), "204" ) //Cancelamento de NFS-e
	aadd( atail(aListQueue), "319" ) //Recebimento de NFS-e - Envio
	
	//NFSE-RETORNOS [8]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "360" ) //Retorno da emissão de NFS-e
	aadd( atail(aListQueue), "361" ) //Retorno do cancelamento de NFS-e 
	aadd( atail(aListQueue), "362" ) //Recebimento de NFS-e - Retorno
endif

if cModelo $ "CCE-ALL"
	//CCE da NF-e Envio [8]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "301" ) //Emissão de CC-e de NF-e
	aadd( atail(aListQueue), "302" ) //Recebimento de CC-e de NF-e - Envio	
	
	//CCE da NF-e Envio [8]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "301" ) //Retorno da emissão de CC-e da NF-e
	aadd( atail(aListQueue), "302" ) //Recebimento de CC-e de NF-e - Envio	
	
endif

if cModelo $ "MDE-ALL"
	//MDFE-EMISSOES 11]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "443" ) // De 338 para 443 MD-e - Consulta NF-e Destinada
	aadd( atail(aListQueue), "320" ) //MD-e – Manifestação do destinatário
	aadd( atail(aListQueue), "336" ) //MD-e – Download de XML
	
	//MDFE-RETORNOS [12]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "443" ) // De 338 para 443 Envio de Pedido de Compra
	aadd( atail(aListQueue), "320" ) //Retorno da Manifestação do destinatário
	aadd( atail(aListQueue), "336" ) //Retorno do Download de XML
	
endif

//EDI
//Pedido de Compra
if cModelo $ "EDI-ALL"
	//EDI-ENVIOS [11]	
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "005" ) //Envio de Pedido de Compra
	aadd( atail(aListQueue), "027" ) //Envio de Alteração de Pedido de Compra
	aadd( atail(aListQueue), "006" ) //Envio de Espelho de Nota Fiscal
	aadd( atail(aListQueue), "252" ) //Envio de Programação de Entrega
	aadd( atail(aListQueue), "006" ) //Envio de Aviso de Embarque
	//EDI-RETORNO [12]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "005" ) //Recebimento de Pedido de Venda
	aadd( atail(aListQueue), "027" ) //Recebimento de Alteração de Pedido de Venda
	aadd( atail(aListQueue), "025" ) //Recebimento de Documento de Venda (mesmo layout de Pedido de Venda)
	aadd( atail(aListQueue), "006" ) //Recebimento de Espelho de Nota Fiscal
	aadd( atail(aListQueue), "252" ) //Recebimento de Programação de Entrega
	aadd( atail(aListQueue), "006" ) //Recebimento de Aviso de Embarque
	
	
endif

if cModelo $ "EPP-ALL"
	//EPP-EMISSOES [15]
	aadd(aListQueue,{})	
	aadd( atail(aListQueue), "534" ) //Processamento Pedido de Prorrogação EPP - Envio
	aadd( atail(aListQueue), "535" ) //Processamento Cancelamento Pedido de Prorrogacao EPP - Envio
	
	//EPP-RETORNOS [16]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "536" ) //Retorno emissão de pedido de prorrogação EPP - Retorno		
endif

if cModelo $ "CEC-ALL"
	//CEC Envio [17]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "589" ) //Envio Baixa Comprovante de Entrega
	aadd( atail(aListQueue), "590" ) //Envio Cancelamento Comprovante de Entrega
	
	//CEC Retorno [18]
	aadd(aListQueue,{})
	aadd( atail(aListQueue), "589" ) //Retorno Baixa Comprovante de Entrega
	aadd( atail(aListQueue), "590" ) //Retorno Cancelamento Comprovante de Entrega
endif

return aListQueue

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlClean
Retira e valida algumas informações e caracteres indesejados para o parse do XML.

@author Henrique de Souza Brugugnoli
@since 06/07/2010
@version 1.0 

@param	cXml, string, XML que será feito a validação e a retirada dos caracteres especiais

@return	cRetorno	XML limpo
/*/
//-------------------------------------------------------------------

static function XmlClean( cXml )
    
Local cRetorno		:= "" 

DEFAULT cXml		:= ""

If ( !Empty(cXml) )

	cRetorno := Alltrim(cXml)

	/*
	< - &lt; 
	> - &gt; 
	& - &amp; 
	" - &quot; 
	' - &#39;
	*/
	If !( "&amp;" $ cRetorno .or. "&lt;" $ cRetorno .or. "&gt;" $ cRetorno .or. "&quot;" $ cRetorno .or. "&#39;" $ cRetorno )
		/*Retira caracteres especiais e faz a substituição*/
		cRetorno := StrTran(cRetorno,"&","&amp;amp;")   
	EndIf      
	
EndIf

Return cRetorno   

//-------------------------------------------------------------------
/*/{Protheus.doc} colRecomendacao
Retorna a recomenção da nota após a transmissão para Neogrid 

@author Rafael Iaquinto
@since 31/07/2014
@version 1.0 

@param	cModelo, string, Modelo do documento.
@param cCodEdi, string, Codigo do EDI.
@param cProtocolo, string, Protocolo de auotrização Envio, Cancelamento e Inutilização
@param cDpecProt, string, Protocolo de auotrização DPEC|EPEC
@param cStatus, string, Codigo do STATUS da CKQ.

@return cMsg	Mensagem de recomendação.
/*/
//-------------------------------------------------------------------
static function colRecomendacao(cModelo,cCodEdi,cProtocolo,cDpecProt,cStatus,cRetCSTAT,cRetMSG)

local aMsg			:= {}
//-------------------------------------------------------------------
aMsg := ValMensPad( cModelo,cCodEdi,@cProtocolo,cDpecProt,cStatus,cRetCSTAT,@aMsg,cRetMSG) //Recomendação do monitor faixa
//-------------------------------------------------------------------
do Case
	Case cCodEdi $ "360" //Emissão MDFe
		if  !Empty( cProtocolo )
			cMsg	:= aMsg[1]
		elseif !Empty( cDpecProt )
			cMsg	:= aMsg[7]
		elseif cStatus == "1"
			cMsg	:= aMsg[2]
		else
			cMsg	:= aMsg[3]
		endif
	Case cCodEdi $ "199|203|170" //Emissões
		if  (!Empty( cProtocolo ).And. !("Rejeicao" $ cRetMSG))	.OR. (cRetCSTAT $ RetCodDene())//Nota Denegada
			cMsg	:= aMsg[1]
		elseif !Empty( cDpecProt ).OR. (cRetCSTAT $ RetCodDene())//Nota Denegada
			cMsg	:= aMsg[7]
		elseif cStatus == "1"
			cMsg	:= aMsg[2]
		else
			cMsg	:= aMsg[3]
		endif
	case cCodEdi $ "200|204|362|171" //Cancelamento
		if  Empty( cProtocolo ).And. ColMsgSefaz (cModelo,cRetCSTAT,)
			cProtocolo := 'Autorização Neogrid Sem Protocolo'
			cMsg	:= aMsg[4]
		elseif  !Empty( cProtocolo )	
			cMsg	:= aMsg[4]		
		elseif cStatus == "1"
			cMsg	:= aMsg[5]
		else
			cMsg	:= aMsg[6]
		endif
	case cCodEdi $ "201|172|319" //Inutilização
		if  Empty( cProtocolo ).And. ColMsgSefaz (cModelo,cRetCSTAT,)
			cProtocolo := 'Autorização Neogrid Sem Protocolo'
			cMsg	:= aMsg[8]	
		elseif  !Empty( cProtocolo )				
			cMsg	:= aMsg[8]		
		elseif cStatus == "1"
			cMsg	:= aMsg[9]
		else
			cMsg	:= aMsg[10]
		endif
	case cCodEdi == "361" //MDF-e Encerramento
		if  !Empty( cProtocolo ) 
			cMsg	:= aMsg[13]		
		elseif cStatus == "1"
			cMsg	:= aMsg[11]
		else
			cMsg	:= aMsg[12]
		endif
	case cCodEdi $ "420" //Inutilização
		if  Empty( cProtocolo ).And. ColMsgSefaz (cModelo,cRetCSTAT,)
			cProtocolo := 'Autorização Neogrid Sem Protocolo'
			cMsg	:= if( len(aMsg) > 13, aMsg[14], "")
		elseif  !Empty( cProtocolo )
			cMsg	:= if( len(aMsg) > 13, aMsg[14], "")
		elseif cStatus == "1"
			cMsg	:= if( len(aMsg) > 14, aMsg[15], "")
		else
			cMsg	:= if( len(aMsg) > 15, aMsg[16], "")
		endif
endcase
return(cMsg)
//-------------------------------------------------------------------
/*/{Protheus.doc} ValMensPad
Funcao responsavel por validar a mensagens no padrão TSS para TC2.0
@param		cModelo		Modelo do documento 55-56-57-58
			cCodEdi		Codigo de processamento Edi Neogrid 
			cProtocolo		Protocolo de autorização.
			cDpecProt		Codigo de protocolo Depec.
			cStatus		Codigo do status de processamento do documento.
			cRetCSTAT		Codigo de retorno da entidade de processamento.
			aMSG			Mensagens de retorno após validação
@return	aMsg	Retorna o array com mensagens tratadas 
@author	Cleiton Genuino
@since		12/08/2015
@version	11.8
/*/
//-------------------------------------------------------------------	
Static Function ValMensPad( cModelo,cCodEdi,cProtocolo,cDpecProt,cStatus,cRetCSTAT,aMSG,cRetMSG )
local cMenCancOk	:= ""
local cMenAutoOk	:= ""
local cNome			:= ""
local cDocImp		:= ""
local cEnti         := ""
local cArtigo		:= ""
local cCont			:= ""

Default cRetCSTAT := ""

do case
	case cModelo == "55"
		cNome		:= "NF-e"
		cArtigo	:= "a"
		cDocImp	:= "DANFE"
		cCont	:= "DPEC"
		cEnti  := "SEFAZ"
	case cModelo == "56"
		cNome	:= "NFS-e"
		cArtigo	:= "a"
		cDocImp	:= "nota"
		cCont	:= ""
		cEnti  := "Prefeitura"
	case cModelo == "57"
		cNome		:= "CT-e"
		cArtigo	:= "o"
		cDocImp	:= "DACTE"
		cCont	:= "EPEC"
		cEnti  := "SEFAZ"
	case cModelo == "58"
		cNome		:= "MDF-e"
		cArtigo	:= "o"
		cDocImp	:= "DAMDFE"
		cCont	:= ""
		cEnti  := "SEFAZ"
endcase

		//015 - Foi autorizado a solicitacao de cancelamento da NFe
		//036 - Cancelamento autorizado fora do prazo.
		//	{"Empty(F2_STATUS)",'BR_BRANCO' },;	//
		//	{"F2_STATUS=='015'",'BR_VERDE'},;	//Cancelamento Autorizado, mas com pendencia de processo
		//	{"F2_STATUS=='025'",'BR_LARANJA'},;	//Aguardando Cancelamento
		//	{"F2_STATUS=='026'",'DISABLE'}}		//Cancelamento não autorizado   
IF cModelo $ "55|57" 
		IF 		cCodEdi $ "200|171" //CTe e NFe cancelamento
				do case
					case  cRetCSTAT == '101'
					cMenCancOk := "004/015 - Cancelamento d"+cArtigo+" "+ cNome +" autorizado"
					case  cRetCSTAT == '151'
					cMenCancOk := "004/036 - Cancelamento d"+cArtigo+" "+ cNome +" homologado fora do prazo"
					OtherWise
					cMenCancOk := "004/015 - Cancelamento d"+cArtigo+" "+ cNome +" autorizado"
				endcase	
		ElseIF cCodEdi $ "199|170" //CTe e NFe autorização		
				do case	
					case  cRetCSTAT == '100'
					cMenAutoOk := "001 - Emissão de "+cDocImp+" autorizada"	
					case  cRetCSTAT == '150'
					cMenAutoOk := "001 - Autorizado o uso d"+cArtigo+" "+ cNome +", autorização concedida fora de prazo"
					case  cRetCSTAT $ (RetCodDene())//Nota Denegada
					cMenAutoOk := "003 - "+cNome+" não autorizad"+cArtigo+" uso denegado "+ cRetCSTAT+ cRetMSG + ". "  
					
					OtherWise
					cMenAutoOk := "001 - Emissão de "+cDocImp+" autorizada"		
				endcase
		ElseIF cCodEdi $ "201|172" //CTe e NFe autorização		
				do case	
					case  cRetCSTAT == '102'
					cMenAutoOk := "008/015 - Inutilização de número homologado."	
					
					case  cRetCSTAT == '206'
					cMenAutoOk := "008/015 -"+cDocImp+"já está inutilizada na Base de dados da SEFAZ "
					
					OtherWise
					cMenAutoOk := "008/015 - Inutilização de número homologado."	
				endcase
		EndIF
			aadd(aMsg,cMenAutoOk)
			aadd(aMsg,"002 - "+ Upper( cArtigo ) +" "+ cNome +" foi transmitid"+cArtigo+", aguarde o processamento.")
			aadd(aMsg,"003 - "+cNome+" não autorizad"+cArtigo+" - Corrija o problema e retransmita "+cArtigo+" " + cNome)
			aadd(aMsg,cMenCancOk)
			aadd(aMsg,"005 - Cancelamento d"+cArtigo+" "+ cNome +" transmitido, aguarde o processamento")
			aadd(aMsg,"006/026 - Cancelamento d"+cArtigo+" "+ cNome +" não autorizado. Verifique os motivos junto a "+cEnti+".")
			aadd(aMsg,"007 - "+cCont+" autorizado. Emissão de "+cDocImp+" autorizada")
			aadd(aMsg,"008/015 - Inutilização de número homologado.")
			aadd(aMsg,"009 - Inutilização transmitida, aguardando o processamento.") 
			aadd(aMsg,"010/026 - Inutilização não autorizada. Verifique os motivos junto a SEFAZ.")
			aadd(aMsg,"011 - Encerramento do MDFe transmitido, aguardando processamento.")
			aadd(aMsg,"012 - Encerramento do MDFe . Verifique os motivos junto a SEFAZ.")
			aadd(aMsg,"013 - Encerramento do MDFe autorizado.")

ElseIF cModelo $ "56"

			aadd(aMsg,"100 - Emissão de " +cDocImp+" autorizada"	)
			aadd(aMsg,"002 - "+ Upper( cArtigo ) +" "+ cNome +" foi transmitid"+cArtigo+", aguarde o processamento.")
			aadd(aMsg,cRetCSTAT+" - "+cNome+" não autorizad"+cArtigo+" - Corrija o problema e retransmita "+cArtigo+" " + cNome)
			aadd(aMsg,"333 - Cancelamento d"+cArtigo+" "+ cNome +" autorizado")
			aadd(aMsg,"005 - Cancelamento d"+cArtigo+" "+ cNome +" transmitido, aguarde o processamento")
			aadd(aMsg,cRetCSTAT+" - Nao foi possivel cancelar o RPS. Verifique os motivos junto a "+cEnti+".")
			aadd(aMsg,"007 - ")
			aadd(aMsg,"008 - ")
			aadd(aMsg,"009 - ") 
			aadd(aMsg,"010 - ")
			aadd(aMsg,"011 - ")
			aadd(aMsg,"012 - ")
			aadd(aMsg,"013 - ")

ElseIf cModelo $ "58"
			aadd(aMsg,"001 - Emissão de " +cDocImp+" autorizada")
			aadd(aMsg,"002 - "+ Upper( cArtigo ) +" "+ cNome +" foi transmitid"+cArtigo+", aguarde o processamento.")
			aadd(aMsg,"003 - "+cNome+" não autorizad"+cArtigo+" - Corrija o problema e retransmita "+cArtigo+" " + cNome)
			aadd(aMsg,"004/015 - Cancelamento d"+cArtigo+" "+ cNome +" autorizado")
			aadd(aMsg,"005 - Cancelamento d"+cArtigo+" "+ cNome +" transmitido, aguarde o processamento")
			aadd(aMsg,"006/026 - Cancelamento d"+cArtigo+" "+ cNome +" não autorizado. Verifique os motivos junto a "+cEnti+".")
			aadd(aMsg,"007 - "+cCont+" autorizado. Emissão de "+cDocImp+" autorizada")
			aadd(aMsg,"008/015 - Inutilização de número homologado.")
			aadd(aMsg,"009 - Inutilização transmitida, aguardando o processamento.")
			aadd(aMsg,"010/026 - Inutilização não autorizada. Verifique os motivos junto a SEFAZ.")
			aadd(aMsg,"011 - Encerramento do MDFe transmitido, aguardando processamento.")
			aadd(aMsg,"012 - Encerramento do MDFe . Verifique os motivos junto a SEFAZ.")
			aadd(aMsg,"013 - Encerramento do MDFe autorizado.")
			aadd(aMsg,"014/015 - Inclusão de condutor homologado.")
			aadd(aMsg,"015 - Inclusão de condutor transmitida, aguardando o processamento.")
			aadd(aMsg,"016/026 - Inclusão de condutor não autorizada. Verifique os motivos junto a SEFAZ.")
else
			aadd(aMsg,"001 - Emissão de " +cDocImp+" autorizada")
			aadd(aMsg,"002 - "+ Upper( cArtigo ) +" "+ cNome +" foi transmitid"+cArtigo+", aguarde o processamento.")
			aadd(aMsg,"003 - "+cNome+" não autorizad"+cArtigo+" - Corrija o problema e retransmita "+cArtigo+" " + cNome)
			aadd(aMsg,"004/015 - Cancelamento d"+cArtigo+" "+ cNome +" autorizado")
			aadd(aMsg,"005 - Cancelamento d"+cArtigo+" "+ cNome +" transmitido, aguarde o processamento")
			aadd(aMsg,"006/026 - Cancelamento d"+cArtigo+" "+ cNome +" não autorizado. Verifique os motivos junto a "+cEnti+".")
			aadd(aMsg,"007 - "+cCont+" autorizado. Emissão de "+cDocImp+" autorizada")
			aadd(aMsg,"008/015 - Inutilização de número homologado.")
			aadd(aMsg,"009 - Inutilização transmitida, aguardando o processamento.")
			aadd(aMsg,"010/026 - Inutilização não autorizada. Verifique os motivos junto a SEFAZ.")
			aadd(aMsg,"011 - Encerramento do MDFe transmitido, aguardando processamento.")
			aadd(aMsg,"012 - Encerramento do MDFe . Verifique os motivos junto a SEFAZ.")
			aadd(aMsg,"013 - Encerramento do MDFe autorizado.")
			aadd(aMsg,"014/015 - Inclusão de condutor homologado.")
			aadd(aMsg,"015 - Inclusão de condutor transmitida, aguardando o processamento.")
			aadd(aMsg,"016/026 - Inclusão de condutor não autorizada. Verifique os motivos junto a SEFAZ.")

EndIf

return aMsg
//-------------------------------------------------------------------	

static function ColConfCont(cModelo)

local cAvisoCont	:= ""
local nOpcCont	:= 0

local cDhcont 	:= colDtHrUTC()
 	

if cModelo == "NFE"
	if ColGetPar("MV_MODALID","") <> "1"	
		while Empty(cAvisoCont) .And. nOpcCont<=1
			While .T.
				cAvisoCont := ColGetPar("MV_NFXJUST","")
				
				nOpcCont	:=	Aviso("SPED - Motivo da Contingência",@cAvisoCont,{"Confirma","Cancela"},3,,,,.T.)
				If nOpcCont==2					
					exit
				ElseIf len(alltrim(cAvisoCont)) >= 15
					
					ColSetPar("MV_NFXJUST",cAvisoCont)
					
					if ColGetPar("MV_VERSAO") < "3.10"
						colSetPar("MV_NFINCON",SubStr(cDhcont,1,19))
					else															
						colSetPar("MV_NFINCON",cDhcont)
					endif					
					exit
				else
					MsgAlert('Informar o motivo da Contingência com mais de 15 caracteres. ')					
				endif
			EndDo
		End
		If nOpcCont==2
			//				Aviso("SPED - Motivo da Contingência","A modalidade informada ("+AllTrim(aParam[2])+") não será considerada nas transmissões dos documentos fiscais, pois para que esta modadlidade seja utilizada é necessário se informar o motivo desta alteração, e neste caso não foi informado.",{"Ok"},3)
			Aviso("SPED - Motivo da Contingência","Para a utilização da modalidade ("+colGetPar("MV_MODALID","")+") é obrigatória a descrição do motivo.",{"Ok"},3)
		EndIf		
	else		
		colSetPar("MV_NFXJUST","")
		colSetPar("MV_NFINCON","")
	endif 
elseif cModelo == "CTE"
	if ColGetPar("MV_MODCTE","") <> "1"
		while Empty(cAvisoCont) .And. nOpcCont<=1
			While .T.
				nOpcCont	:=	Aviso("SPED - Motivo da Contingência",@cAvisoCont,{"Confirma","Cancela"},3,,,,.T.)
				If nOpcCont==2					
					exit
				ElseIf len(alltrim(cAvisoCont)) >= 15					
					ColSetPar("MV_CTXJUST",cAvisoCont)
					ColSetPar("MV_CTINCON",cDhcont)
					exit
				else
					MsgAlert('Informar o motivo da Contingência com mais de 15 caracteres. ')					
				endif
			EndDo
		End
		If nOpcCont==2
			//				Aviso("SPED - Motivo da Contingência","A modalidade informada ("+AllTrim(aParam[2])+") não será considerada nas transmissões dos documentos fiscais, pois para que esta modadlidade seja utilizada é necessário se informar o motivo desta alteração, e neste caso não foi informado.",{"Ok"},3)
			Aviso("SPED - Motivo da Contingência","Para a utilização da modalidade ("+colGetPar("MV_MODCTE","")+") é obrigatória a descrição do motivo.",{"Ok"},3)
		EndIf				
	else		
		colSetPar("MV_CTXJUST","")
		colSetPar("MV_CTINCON","")
	endif 
endif

return nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ColAtuTrans
Funcao responsavel por atualizar o cabecalho (SF1 ou SF2).  


@param		cEntSai	Tipo de Movimento 1-Saida / 2-Recebimento.
			cSerie		Serie do documento.
			cNF			Numero do documento.
			cCliente	Codigo do Cliente no qual esta gerando documento.
			cLoja		Codigo da Loja no qual esta gerando documento.
			
@return	lGerado	Retorna se o documento foi gerado.

@author	Douglas Parreja
@since		01/08/2014
@version	11.7
/*/
//-------------------------------------------------------------------	
Function ColAtuTrans( cEntSai, cSerie, cNF , cCliente , cLoja, lCTe, cChvCtg, nTpEmisCte , cModelo, lCanc  )


	Local cEspecie  := ""
	Local lGerado	:= .F.
	Local lGerSF2	:= .F.
	Local lGerSF3	:= .F.
	Local nTamDoc	:= 0
	Local nTamSer	:= 0
	Local nTamCli	:= 0
	Local nTamLoj	:= 0
	local aArea 	:= GetArea()
	local aAreaSF3:= SF3->(GetArea())
	
	Default cEntSai	:=	""
	Default cSerie	:=	""
	Default cNF		:=	""
	Default cCliente	:=	""
	Default cLoja		:=	""
	Default lCTe		:= .F.
	Default lCanc		:= .F.
	Default cChvCtg	:= ""
	Default nTpEmisCte	:= 1
	Default cModelo		:= ""


		//-----------------------------------------
		// SF3 - Informar flags e atualizações na transmissão
		// Obs.: Alteracao realizada para AutoNFe
		//-----------------------------------------
			If cModelo $ "56"
				cEspecie := "RPS"
			Endif
		//-----------------------------------------
		//  Obs.: Alteracao realizada para AutoNFe/AutoNFSe
		//-----------------------------------------



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NF de Entrada                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If cEntSai == "0"
		nTamDoc := TamSx3("F1_DOC")[1]
		nTamSer := TamSx3("F1_SERIE")[1]
		nTamCli := TamSx3("F1_FORNECE")[1]
		nTamLoj := TamSx3("F1_LOJA")[1]
	
		If SF1->(FieldPos("F1_FIMP"))>0
			dbSelectArea("SF1")
		If Empty (cCliente) .or. Empty (cLoja)
		   		If DbSeek(xFilial("SF1")+ cNF + cSerie)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para cada NFe transmitida verificado se os campos estão preenchidos ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
								cCliente	:= SF1->F1_FORNECE
								cLoja		:= SF1->F1_LOJA
				EndIf								
		EndIf				
			dbSetOrder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
			If DbSeek(xFilial("SF1")+Padr(cNF,nTamDoc)+ Padr(cSerie,nTamSer)+Padr(cCliente,nTamCli)+Padr(cLoja,nTamLoj)) .And. SF1->F1_FIMP$"S,N, "
				RecLock("SF1",.F.)
				If !Empty( Alltrim(cSerie)+Alltrim(cNF) )
					SF1->F1_FIMP := "T"
				Else
					SF1->F1_FIMP := "N"
				EndIf
				MsUnlock()
				lGerado := .T.
			EndIf
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NF de Saida                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Else	
		//-----------------------------------------
		// SX2 - Verifica tamanho dos campos
		//-----------------------------------------
		nTamDoc := TamSx3("F2_DOC")[1]
		nTamSer := TamSx3("F2_SERIE")[1]
		nTamCli := TamSx3("F2_CLIENTE")[1]
		nTamLoj := TamSx3("F2_LOJA")[1]
		
		//-----------------------------------------
		// Posiciona no registro para flegar
		//-----------------------------------------	
		dbSelectArea("SF2")
		dbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If Empty (cCliente) .or. Empty (cLoja)
		   		If DbSeek(xFilial("SF2")+ Padr(cNF,nTamDoc) + Padr(cSerie,nTamSer))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para cada NFe transmitida verificado se os campos estão preenchidos ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
								cCliente	:= SF2->F2_CLIENTE
								cLoja		:= SF2->F2_LOJA
				EndIf											
		EndIf	
		If DbSeek(xFilial("SF2")+Padr(cNF,nTamDoc)+ Padr(cSerie,nTamSer)+Padr(cCliente,nTamCli)+Padr(cLoja,nTamLoj)) .And. SF2->F2_FIMP$"T,S,N, "
			RecLock("SF2",.F.)
			If !Empty( cSerie+cNF )
				SF2->F2_FIMP := "T"
			Else
				SF2->F2_FIMP := "N"
			EndIf
			MsUnlock()		
			lGerSF2 := .T.	
		EndIf
		//-----------------------------------------
		// SX3 - Verifica tamanho dos campos
		// Obs.: Alteracao realizada para AutoNFe
		//-----------------------------------------
		nTamDoc := TamSx3("F3_NFISCAL")[1]
		nTamSer := TamSx3("F3_SERIE")[1]
		nTamCli := TamSx3("F3_CLIEFOR")[1]
		nTamLoj := TamSx3("F3_LOJA")[1]
		
		//-----------------------------------------
		// Posiciona no registro para flegar
		//-----------------------------------------	
		dbSelectArea("SF3")
		dbSetOrder(6)	
		If Empty (cCliente) .or. Empty (cLoja)
		   		If DbSeek(xFilial("SF3")+ cNF + cSerie)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Para cada NFe transmitida verificado se os campos estão preenchidos ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
								cCliente	:= SF3->F3_CLIEFOR
								cLoja		:= SF3->F3_LOJA
				EndIf											
		EndIf	
		If SF3->(FieldPos("F3_CODRET")) > 0
			SF3->( dbSetOrder(4) ) //F3_FILIAL+      F3_CLIEFOR     +       F3_LOJA      +      F3_NFISCAL  +       F3_SERIE
			If SF3->( dbSeek( xFilial("SF3")+ Padr(cCliente,nTamCli)+ Padr(cLoja,nTamLoj)+ Padr(cNF,nTamDoc)+ Padr(cSerie,nTamSer) ) )				
				Do While (SF3->F3_NFISCAL == Padr(cNF,nTamDoc)) .And. (SF3->F3_SERIE == Padr(cSerie,nTamSer))
					RecLock("SF3",.F.)
					If !Empty( cSerie+cNF )
						SF3->F3_CODRET := "T"	// Transmitido	
						If	lCanc
							SF3->F3_CODRSEF := "C"	// Cancelada
						EndIf	
						If Empty(SF3->F3_ESPECIE) .And. cModelo $ "56"
							SF3->F3_ESPECIE := cEspecie
						EndIf
					EndIf
					MsUnlock()
					SF3->(dbSkip())
				EndDo				
				lGerSF3 := .T.
			Endif
		Endif
		
		//-----------------------------------------
		// CTe - Quando for CTe
		//-----------------------------------------
		If lCte
			DT6->(dbSetOrder(1))
			If	DT6->(MsSeek(xFilial("DT6")+cFilAnt+PadR(cNF, nTamDoc)+Padr(cSerie,nTamSer)))
				RecLock("DT6",.F.)
				If !Empty( cSerie+cNF )
					DT6->DT6_AMBIEN := Val(SubStr(ColGetPar("MV_AMBCTE","2"),1,1))
					DT6->DT6_SITCTE := "1"
					DT6->DT6_RETCTE := "002 - O CT-e foi transmitido, aguarde o processamento."
					If nTpEmisCte == 5 .And. !Empty(cChvCtg) .And. Empty(DT6->DT6_CHVCTG)
						DT6->DT6_CHVCTG := cChvCtg
					EndIf
				EndIf
				MsUnlock()
			EndIf
		EndIf
		//Retorno se foi gerado na SF2 e SF3
		lGerado := Iif( lGerSF3,.T.,.F.)
	EndIf
	
RestArea( aAreaSF3 )
RestArea( aArea )
Return ( lGerado )

//-------------------------------------------------------------------
/*/{Protheus.doc} ColRetTrans
Funcao responsavel pela geracao do XML para TOTVS Colaboracao 


@param		cEntSai	Tipo de Movimento 1-Saida / 2-Recebimento.
			cSerie		Serie do documento.
			cNF			Numero do documento.
			cCliente	Codigo do Cliente no qual esta gerando documento.
			cLoja		Codigo da Loja no qual esta gerando documento.
			
@return	lGerado	Retorna se o documento foi gerado.

@author	Douglas Parreja
@since		25/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------			
Function ColRetTrans( lGerado , nY , aRetCol )

	Default aRetCol	:= {}
	Default lGerado	:= .F.
	Default nY		:= 0
	
	If lGerado
		aAdd(aRetCol,{})
		aAdd(aRetCol[nY] , lGerado)				// 1-Registro gerado CKQ/CKO
		aAdd(aRetCol[nY] , oTemp:cSerie)		// 2-Serie do documento
		aAdd(aRetCol[nY] , oTemp:cNumero)		// 3-Numero do documento
		aAdd(aRetCol[nY] , oTemp:cDsStatArq)	// 4-Descricao do arquivo gerado
		aAdd(aRetCol[nY] , oTemp:cIdErp)		// 5-Id do ERP (Serie+NumeroNF+Empresa+Filial)
		aAdd(aRetCol[nY] , oTemp:cModelo)		// 6-Modelo do documento
	Else
		aAdd(aRetCol,{})
		aAdd(aRetCol[nY] , lGerado)				// 1-Registro gerado CKQ/CKO
		aAdd(aRetCol[nY] , oTemp:cSerie)		// 2-Serie do documento
		aAdd(aRetCol[nY] , oTemp:cNumero)		// 3-Numero do documento
		aAdd(aRetCol[nY] , oTemp:cIdErp)		// 4-Id do ERP (Serie+NumeroNF+Empresa+Filial)
		aAdd(aRetCol[nY] , oTemp:cCodErr)		// 5-Codigo do Erro
		aAdd(aRetCol[nY] , oTemp:cMsgErr)		// 6-Descricao do Erro	
	EndIf

Return 							
	//-------------------------------------------------------------------
/*/{Protheus.doc} ColInutTrans
Funcao responsavel pela geracao do XML de Inutilizacao para TOTVS Colaboracao 


@param		aNFeCol	Documento a ser processado.
			cXjust		Justificativa da Inutilizacao
			cModelo	Modelo do documento
						
@return	cXmlDados	Retorna XML de Inutilizacao.

@author	Douglas Parreja
@since		14/08/2014
@version	11.7
/*/
//-------------------------------------------------------------------		
Function ColInutTrans( aNFeCol , cXjust , cModelo )

	Local cXmlDados	:= ""
	Local cUF 		:= (SM0->M0_ESTENT) //SM0->M0_ESTCOB
	Local cCNPJ		:= (SM0->M0_CGC)
	Local cVersao		:= ColGetPar( "MV_VERSAO" , "3.10" )
	Local cVerCte	:= ColGetPar( "MV_VERCTE" , "2.00" )
	Local nAmbiente 	:= Val(SubStr(ColGetPar("MV_AMBIENT","2"),1,1))
	Local cSerie	:= ""
	Local cNumIni		:= ""
	Local cNumFim		:= ""
	
	Default aNFeCol	:= {}
	Default cXjust	:= ""
	Default cModelo	:= "55"
	
	If Len(aNFeCol) > 0
		cSerie		:= AllTrim(StrZero(Val(aNFeCol[3]),3))
		cNumIni	:= AllTrim(StrZero(Val(aNFeCol[4]),9))
		cNumFim	:= AllTrim(StrZero(Val(aNFeCol[4]),9))
	EndIf
	
	cXmlDados := ''
	If cModelo == "57"
		cXmlDados += '<inutCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'		
	Else
	cXmlDados += '<inutNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="'+cVersao+'">'	
	EndIf
	cXmlDados += '<infInut Id="ID'+GetUFCode(cUF)+;
										IIF(cModelo=="57","",ColDateConv(Date(),"YY"))+;
									AllTrim(cCNPJ)+;
									cModelo+;
									cSerie+;
									cNumIni+;
									cNumFim+'">'
	cXmlDados  += "<tpAmb>"+Str(nAmbiente,1)+"</tpAmb>"
	cXmlDados += "<xServ>INUTILIZAR</xServ>"
	cXmlDados += "<cUF>"+GetUFCode(cUF)+"</cUF>"
	cXmlDados += "<ano>"+ColDateConv(Date(),"YY")+"</ano>"
	cXmlDados += "<CNPJ>"+cCNPJ+"</CNPJ>"
	cXmlDados += "<mod>"+ cModelo +"</mod>"
	cXmlDados += "<serie>" +AllTrim(Str(Val(cSerie),Len(cSerie)))+"</serie>"
	If cModelo == "57"
		cXmlDados += "<nCTIni>"+AllTrim(Str(Val(cNumIni),Len(cNumIni)))+"</nCTIni>"
		cXmlDados += "<nCTFin>"+AllTrim(Str(Val(cNumFim),Len(cNumFim)))+"</nCTFin>"
	Else
	cXmlDados += "<nNFIni>"+AllTrim(Str(Val(cNumIni),Len(cNumIni)))+"</nNFIni>"
	cXmlDados += "<nNFFin>"+AllTrim(Str(Val(cNumFim),Len(cNumFim)))+"</nNFFin>"
	EndIf
	If !Empty(cXjust) .And. Len(cXjust)<255 .And. Len(cXjust)>15
		cXmlDados += '<xJust>'+cXjust+'</xJust>'
	Else
		cXmlDados += "<xJust>Cancelamento de nota fiscal eletronica por emissao indevida, sem transmissao a SEFAZ</xJust>"
	EndIf
	cXmlDados += "</infInut>"
	If cModelo == "57"
		cXmlDados += "</inutCTe>"
	Else
	cXmlDados += "</inutNFe>"
	EndIf
	
Return cXmlDados
	
//-------------------------------------------------------------------
/*/{Protheus.doc} ColDateConv
Funcao responsavel pela geracao do XML de Inutilizacao para TOTVS Colaboracao 


@param		dData		Data a ser consultado.
			cMasc		Mascara da data ser retornada. 
						DD = Dia
						MM = Mes
						YYYY ou YY = Ano 
			
@return	cResult	Retorna a mascara da data conforme solicitou.

@author	Douglas Parreja
@since		14/08/2014
@version	11.7
/*/
//-------------------------------------------------------------------		
Static Function ColDateConv(dData,cMasc)

	Local cDia    := ""
	Local cMes    := ""
	Local cAno    := ""
	Local cData   := Dtos(dData)
	Local cResult := ""
	Local cAux    := ""
	
	DEFAULT cMasc := "DDMMYYYY"
	
	cDia := SubStr(cData,7,2)
	cMes := SubStr(cData,5,2)
	cAno := SubStr(cData,1,4)
	
	While !Empty(cMasc)
		cAux := SubStr(cMasc,1,2)
		Do Case
			Case cAux == "DD"
				cResult += cDia
			Case cAux == "MM"
				cResult += cMes
			Case cAux == "YY"
				If SubStr(cMasc,1,4) == "YYYY"
					cResult += cAno
					cMasc := SubStr(cMasc,3)
				Else
					cResult += SubStr(cAno,3)
				EndIf			
		EndCase
		cMasc := SubStr(cMasc,3)
	EndDo
	
Return(cResult)	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GetUFCode ³ Rev.  ³Eduardo Riera          ³ Data ³11.05.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de recuperacao dos codigos de UF do IBGE             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Estado ou UF                               ³±±
±±³          ³ExpC2: lForceUf                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao tem como objetivo retornar o codigo do IBGE da  ³±±
±±³          ³UF                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Totvs SPED Services Gateway                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetUFCode(cUF,lForceUF)

Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}
DEFAULT lForceUF := .F.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][IIF(!lForceUF,2,1)]
	EndIf
Else
	cRetorno := aUF
EndIf
Return(cRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModeloDoc 
Funcao responsavel por retornar o modelo do documento 


@param		cCodMod	Codigo Modelo do documento	

@return	cDesMod	Descricao do Modelo do documento

@author	Douglas Parreja
@since		28/07/2014
@version	11.7
/*/
//-------------------------------------------------------------------
Static Function ModeloDoc(cCodMod,cEvento)

	Local 	 cDesMod	:= ""
	Default cCodMod	:= ""
	Default cEvento	:= ""
	
	If cCodMod == "55"		//NF-e
		cDesMod := "NFE"
	ElseIf cCodMod == "56"	//NFS-e	
		cDesMod := "NFS"
	ElseIf cCodMod == "57"	//CT-e	
		cDesMod := "CTE"
	ElseIf cCodMod == "58"	//MDF-e	
		If cEvento == "110114"// Inclusao de condutor
			cDesMod := "ICC" 
		Else
			cDesMod := "MDF"
		Endif
	EndIf

Return cDesMod
			   
//-------------------------------------------------------------------
/*/{Protheus.doc} ColListaFiliais
Funcao que retorna os nomes dos arquivos da consulta realizada por 
filial de processamento


@param		cQueue			Codigo Queue (Edi)
			cFlag			Registro ja foi listado
			cEmpProc	    Empresa de Processamento
			cFilProc	    Filial de Processamento
			dDataRet		Data do periodo a ser listado

@return	aNomeArq		Lista com os nomes dos documentos

@author	Flavio Lopes Rasta
@since		13/10/2014
@version	11.9
/*/
//-------------------------------------------------------------------
Function ColListaFiliais( cQueue , cFlag , cEmpProc , cFilProc , dDataRet, aQueue )

	Local cSeek			:= ""
	Local cCondicao		:= ""
	Local lValido		:= .F.
	Local aNomeArq		:= {}
	Local aArea     	:= GetArea()
	Local nCmpEdi		:= Len(CKO->CKO_CODEDI)
	Local nCmpFlag		:= Len(CKO->CKO_FLAG)
	Local lQueue			:= .F.
	Local cQueueSQL		:= ""
	Local nI				:= 0
	Local lFilRep		:= SuperGetMV("MV_FILREP",.F.,.T.)
	
	Default cQueue 	:= ""
	Default cFlag		:= ""
	
	cQueue	:= PadR(cQueue,nCmpEdi)
	cFlag 	:= PadR(cFlag,nCmpFlag)
	
	If ValType(aQueue) == "A" .And. Len(aQueue) > 0
		lQueue := .T.
		For nI := 1 To Len(aQueue)
			If nI == 1
				cQueueSQL += aQueue[nI]
			Else
				cQueueSQL += "','" + aQueue[nI]
			Endif
		Next nI
	Else
		cQueueSQL := cQueue
	Endif
	
	If !lQueue		
		If empty(dDataRet)
			cCondicao := "(TRBCKO->CKO_CODEDI == '" + cQueue + "') .And. (TRBCKO->CKO_FLAG == '" + cFlag + "')"
		Else
			cCondicao := "(TRBCKO->CKO_CODEDI == '" + cQueue + "') .And. (TRBCKO->CKO_FLAG == '" + cFlag + "')  .And. (TRBCKO->CKO_DT_RET >= '" + DtoS(dDataRet) + "' )"
		EndIf
	Endif
	
	If lFilRep
		BeginSQL Alias "TRBCKO"
			SELECT *
			FROM
				CKOCOL
			WHERE
				%NotDel% AND
				CKO_CODEDI IN (%exp:cQueueSQL%) AND
				CKO_FLAG = %exp:cFlag% AND
				CKO_EMPPRO IN ('   ',%exp:cEmpProc%) AND
				CKO_FILPRO IN ('   ',%exp:cFilProc%) AND
				CKO_DT_RET >= %exp:dDataRet%
		EndSQL
	Else
		BeginSQL Alias "TRBCKO"
			SELECT *
			FROM
				CKOCOL
			WHERE
				%NotDel% AND
				CKO_CODEDI IN (%exp:cQueueSQL%) AND
				CKO_FLAG = %exp:cFlag% AND
				CKO_DT_RET >= %exp:dDataRet%
		EndSQL
	Endif

	While !TRBCKO->(Eof()) .And. Iif(lQueue,.T.,&(cCondicao)) 
		aadd(aNomeArq,{	TRBCKO->CKO_ARQUIV,;
							TRBCKO->CKO_STATUS,;
							TRBCKO->CKO_DT_RET,;
							TRBCKO->CKO_HR_RET})
		TRBCKO->(dbSkip())
	EndDo
	
	TRBCKO->(dbCloseArea())
	
	RestArea(aArea)

Return aNomeArq


//-----------------------------------------------------------------------
/*/{Protheus.doc} ColErroErp
Função que devolve o erro e descrição por módulo.

@param		cCod, string,Codigo do erro por módulo.
						  
@return	aCodErro	Array com o codigo e descrição do erro.
						[1] - Codigo do erro
						[2] - Descrição do erro.	

@author	Flavio Lopes Rasta
@since		16/10/2014
@version	11.9
/*/
//-----------------------------------------------------------------------
function ColErroErp(cCod)

Local nPos
local aCodErro	:= {}
local aCodigos	:= {}

aadd(aCodigos, {"COM001","Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência."})
aadd(aCodigos, {"COM002","Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente."})
aadd(aCodigos, {"COM003","Documento complemento de preço icms/ipi não é tratado pelo TOTVS Colaboração.Gere o documento complementeo de preço icms/ipi manualmente através da rotina documento de entrada."})
aadd(aCodigos, {"COM004","Tipo NF-e de ajustes não será tratado pelo TOTVS Colaboração.Gere o documento de ajustes de forma manual através da rotina documento de entrada."})
aadd(aCodigos, {"COM005","ID de NF-e já registrado na NF do fornecedor."})
aadd(aCodigos, {"COM006","ID de NF-e já registrado na NF do Do Cliente."})
aadd(aCodigos, {"COM007","Fornecedor/Cliente inexistente na base. Gere cadastro para este fornecedor/cliente."})
aadd(aCodigos, {"COM008","O Cliente Emitente não está cadastrado: Inclua o emitente manualmente."})
aadd(aCodigos, {"COM009","Não foi possível incluir o destinatário. Inclua o destinatário  manualmente."})
aadd(aCodigos, {"COM010","Não foi possível incluir o local de entrega. Inclua o local de entrega  manualmente."})
aadd(aCodigos, {"COM011","Não foi possível atualizar o local de entrega. Atualize o local de entrega manualmente."})
aadd(aCodigos, {"COM012","Fornecedor sem cadastro de Produto X Fornecedor."})
aadd(aCodigos, {"COM013","Nota fiscal possui itens com valor zerado.Verifique a nota recebida do fornecedor."})
aadd(aCodigos, {"COM014","Não foi identificado nenhum pedido de compra referente ao item."})
aadd(aCodigos, {"COM015","Verifique as informações da Nf-e."})
aadd(aCodigos, {"COM016","DS_PLIQUI - O tamanho do campo não suporta o valor fornecido."})
aadd(aCodigos, {"COM017","DS_PBRUTO - O tamanho do campo não suporta o valor fornecido."})
aadd(aCodigos, {"COM018","Este XML possui um codigo de Serviço que não está cadastrado em um produto na empresa/filial corrente."})
aadd(aCodigos, {"COM019","ID de CT-e já registrado na NF."})
aadd(aCodigos, {"COM020","Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada."})
aadd(aCodigos, {"COM021","TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente."})
aadd(aCodigos, {"COM022","Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro"})
aadd(aCodigos, {"COM023","Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro."})
aadd(aCodigos, {"COM024","Corrija a inconsistência apontada no log."})
aadd(aCodigos, {"COM025","Documento já processado."})
aadd(aCodigos, {"COM026","O tamanho de um dos campos de volume não suporta o valor fornecido."})
aadd(aCodigos, {"COM027","Cliente sem cadastro de Produto X Cliente."})
aadd(aCodigos, {"COM028","CNPJ fornecedor/cliente duplicado."})
aadd(aCodigos, {"COM029","Quantidade nos Pedidos (P.E A140IVPED) é maior que a quantidade do XML"})
aadd(aCodigos, {"COM030","Fornecedor/Cliente bloqueado na base. Faça o desbloqueio do cadastro para este fornecedor/cliente."})
aadd(aCodigos, {"COM031","TES bloqueado. Verifique a configuração do cadastro."})
aadd(aCodigos, {"COM032","Retorno do ponto de entrada A116ICOMP inconsistente. Verifique a documentacao do mesmo no portal TDN."})
aadd(aCodigos, {"COM033","Inscrição Estadual do Fornecedor/Cliente não identificada. Verifique o cadastro do Fornecedor/Cliente."})
aadd(aCodigos, {"COM034","Tag _DTEMISNFSE não encontrada. Verificar com quem originou o XML."})
aadd(aCodigos, {"COM035","Tag _NNFSE não encontrada. Verificar com quem originou o XML."})
aadd(aCodigos, {"COM036","CT-e cancelado."})
aadd(aCodigos, {"COM037","CT-e rejeitado."})
aadd(aCodigos, {"COM038","Tag _UFTOM não encontrada. Verificar com quem originou o XML."})
aadd(aCodigos, {"COM039","Valor total da prestação de serviço e valor a receber estão zerados."})
aadd(aCodigos, {"COM040","NF-e cancelada."})
aadd(aCodigos, {"COM041","NF-e rejeitada"})
aadd(aCodigos, {"COM042","Existe mais de uma Empresa/Filial para este XML."})
aadd(aCodigos, {"COM043","Aliquota de imposto igual ou superior a 100%.Verificar com quem originou o XML."})
aadd(aCodigos, {"COM044","Documento de entrada existente na base. Processe o recebimento deste documento de entrada para importar o CTE corretamente"})
aadd(aCodigos, {"COM045","CTEOS cancelada."})
aadd(aCodigos, {"COM046","CTEOS rejeitada."})
aadd(aCodigos, {"COM047","Complemento de imposto não é tratado pelo Totvs Colaboração/Importador."})

If (nPos := (aScan(aCodigos,{|x| x[1] == cCod}))) > 0
	aCodErro	:= aCodigos[nPos][2]
else
	aCodErro	:= {"",""}
endif

return aCodErro
//--------------------------------------------------------
function UsaColaboracao(cModelo)
Local lUsa := .F.

//If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
//endif
return (lUsa)
//--------------------------------------------------------
static function ModeloColab(cModelo)

	local 	 cModTC := ""
	default cModelo := ""

	if cModelo == "55"
		cModTC := "1"			// NFE
	elseIf cModelo == "57" 
		cModTC := "2"			// CTE
	elseIf cModelo == "58" 
		cModTC := "5"			// MDFE
	endIf

return cModTC
//--------------------------------------------------------

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColExistArq
Função que verifica se o nome do arquivo existe na tabela CKO.

@param		cNomeArq, string,Nome do arquivo a ser consultado.
						  
@return	lExist,lógico, .T. se o nome for encontrado na tabela e .F. se não existir.	

@author	Rafael Iaquinto
@since		02/08/2016
@version	12.1.7
/*/
//-----------------------------------------------------------------------
static function ColExistArq(cNomeArq)
local aArea	:= GetArea()
local lExist	:= .F.

CKO->(dbSetOrder(1))

lExist	:= CKO->( dbseek(PadR(cNomeArq,LEN(CKO->CKO_ARQUIV))))

RestArea(aArea)
return lExist
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColMonIncC
Devolve as informações necessárias para montar o monitor do Inclusao de condutor 
 
@author	Feranndo Bastos 
@since		13/07/2017
@version	12.1.17
 
@param    cSerieDoc, string, Serie do documento desejado.                        
@param    cDocNfe, string, Número do documento desejado.                        
@param    @cErro, string, Referência para retornar erro no processamento.                        

@return aDadosXml string com as informações necessárias para o monitor.<br>[1]-Protocolo<br>[2]-Id do CCE<br>[3]-Ambiente<br>[4]-Status evento<br>[5]-Status retorno transmissão
/*/
//-----------------------------------------------------------------------
function ColMonIncC (cSerieDoc,cDocNfe)

Local cAviso		:= ""
Local cErro		:= ""
Local aDados		:= {}
Local aDadosRet	:= {} 
Local aDadosXML	:= {}
Local nX			:= 0
Local lRet			:= .F.


Local oDoc        := Nil
Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")

//Retorno da NeoGrid
aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|NPROT")  
aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|TPEVENTO")
aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|TPAMB")
aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|CSTAT")
aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|XMOTIVO")
aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|DETEVENTO|EVINCCONDUTORMDFE|CONDUTOR|XNOME")
aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|DETEVENTO|EVINCCONDUTORMDFE|CONDUTOR|CPF")
  		
oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov		:= "1"
oDoc:cNumero		:= cDocNfe                                   
oDoc:cSerie		:= cSerieDoc		
oDoc:cIDERP		:= "ICC" + cSerieDoc + cDocNfe + FwGrpCompany()+FwCodFil()
oDoc:cModelo		:= "ICC"
oDoc:cQueue		:= "420"
if odoc:consultar()
	oDoc:lHistorico	:= .T.	
	oDoc:buscahistorico()
    if !Empty( oDoc:cXMLRet )
        cXML := oDoc:cXMLRet
        lRet := .T.
    else
        cXML := oDoc:cXML 
        lRet := .T.      
    endif 
    
	For nX := 1 to Len(oDoc:aHistorico)
		If (oDoc:aHistorico[nX][8]) == "420"
		   
		    //Busca os dados no XML
		    aDadosXml := ColDadosXMl(oDoc:aHistorico[nX][2], aDados, @cErro, @cAviso)        
			
			if lRet 	
				AADD( aDadosRet, { IIf(Empty(aDadosXml[1]),oNo,oOk),;													// Bolinha da legenda 
						aDadosXml[1],;																						// Protocolo 
						aDadosXml[2],;																						// ID do Evento 
						aDadosXml[3],;																						// Ambiente 
						Iif(!Empty(aDadosXml[4]),aDadosXml[4],"4-Evento transmitido, aguarde processamento."),;		// Status evento
						aDadosXml[5],;																						// Retorno da transmissão 
						"",;																									// Espaco da grid  
						"",;																									// Espaco da grid 
						aDadosXml[6],;																						// CPF
						aDadosXml[7],;																						// Nome do Condutor	
						oDoc:cNomeArq,;																						// Nome do arquivo Totvs Colab
						oDoc:cXmlRet})
			endif
		Endif
	Next nX
else
    aDadosRet := {}
    cErro := oDoc:cCodErr + " - " + oDoc:cMsgErr
endif
iF 	Empty(aDadosRet)
	AADD(aDadosRet,{ oNo,"","","","","","","","","","",""})	
Endif

return(aDadosRet)
//-----------------------------------------------------------------------
/*/{Protheus.doc} ColSeqIncC
Devolve o número da próxima sequencia para envio do inclusao de condutor.
 
@author 	Fernando Bastos 
@since 		17/07/2017
@version 	11.9
 
@param	aNfe, Array com as dados da nota  						

@return cSequencia string com as a sequencia que deve ser utilizada.
/*/
//-----------------------------------------------------------------------
function ColSeqIncC(aNfe)

local cModelo		:= "MDF"
local cErro		:= ""
local cAviso		:= ""
local cSequencia	:= "01"
local cXMl			:= ""
local lRetorno	:= .F.

local oDoc			:= nil
local aDados		:= {}
local aDadosXml	:= {}

oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov	:= "1"									
oDoc:cIDERP	:= "ICC" + aNfe[2] + aNfe[3] + FwGrpCompany()+FwCodFil()
oDoc:cModelo	:= "ICC"

if odoc:consultar()
	aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|NPROT") 
	aadd(aDados,"PROCEVENTOMDFE|RETEVENTOMDFE|INFEVENTO|NSEQEVENTO")   
	aadd(aDados,"PROCEVENTOMDFE|EVENTOMDFE|INFEVENTO|NSEQEVENTO")
	
	lRetorno := !Empty(oDoc:cXMlRet)
	
	if lRetorno
		cXml := oDoc:cXMLRet
	else
		cXml := oDoc:cXML
	endif
	
	aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)
	
	//Se ja foi autorizado pega o sequencial do XML de envio.
	if lRetorno
		if !Empty( aDadosXml[1] )
			cSequencia := StrZero(Val(Soma1(aDadosXml[2])),2)
		else
			cSequencia := StrZero(Val(aDadosXml[2]),2)
		endif	
	else
		cSequencia := StrZero(Val(aDadosXml[3]),2)
	endif
	//Tratamento para deixar padrao a se cSequencia quando o retorno vem zerado
	If	cSequencia == '0' .Or. cSequencia == '00' .Or. Empty(cSequencia) 
		cSequencia := "01"
	Endif	 
else
	cSequencia := "01"
endif

oDoc := Nil
DelClassIntf()

return cSequencia

//-----------------------------------------------------------------------
