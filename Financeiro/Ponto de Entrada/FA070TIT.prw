#Include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

user function FA070TIT()
	Local lRet := .T.
	Local cTpBx := SuperGetMV("MV_TPCRCMV",.f.,"")

	If CMOTBX $ "DESC NDF"
		SetPrvt("_cForn")

		_cForn := SPACE(06)
		_cNome := SPACE(40)

		DEFINE MSDIALOG oDlg TITLE "DESCONTO DE COOPERADO" FROM 000,000 TO 080,500 PIXEL Style 128
		@ 001,001 TO 040, 300 OF oDlg PIXEL
		@ 012,014 SAY "Informe o Cooperado:" SIZE 65, 13 OF oDlg PIXEL   
		@ 010,070 MSGET _cForn  F3 "SA2" SIZE 08, 11 OF oDlg PIXEL VALID ExistCpo("SA2",_cForn) .AND. GATFORN()
		@ 010,110 MSGET _cNome Size 120, 11 When .F. OF oDlg PIXEL

		@ 025,110 BUTTON "Ok" SIZE 20,10 ACTION GeraNDF() Of oDlg PIXEL

		oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC quando .F.
		ACTIVATE MSDIALOG oDlg CENTERED
	Endif

	// Verifica se abre a tela do CMV
	If Alltrim(CMOTBX) $ Alltrim(cTpBx)
		
		lRet := ViewCMV() 

	End If

return lRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao que busca a descricao do Fornecedor
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GATFORN()
	_cNome := POSICIONE("SA2",1,XFILIAL("SA2")+ _cForn,"A2_NOME")
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao que insere o título NDF para o cooperado informado                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraNDF()

	Local aArray	 := {}
	Private lMsErroAuto	:= .f.

	// Gerando NDF para o CMV
	aArray := { { "E2_PREFIXO"  , "COO"       		, NIL },;
	{ "E2_NUM"      , SE1->E1_NUM  		, NIL },;
	{ "E2_PARCELA"  , SE1->E1_PARCELA	, NIL },;
	{ "E2_TIPO"     , "NDF"             , NIL },;
	{ "E2_NATUREZ"  , "203011"          , NIL },;
	{ "E2_FORNECE"  , _cForn            , NIL },;
	{ "E2_LOJA"  	, "01"          	, NIL },;
	{ "E2_EMISSAO"  , DDATABASE			, NIL },;
	{ "E2_VENCTO"   , DDATABASE			, NIL },;
	{ "E2_VENCREA"  , DDATABASE			, NIL },;
	{ "E2_HIST"   	, "DESCONTO REF " + Alltrim(SE1->E1_TIPO) + " " + Alltrim(SE1->E1_NUM), NIL },; 
	{ "E2_VALOR"    , NVALREC      		, NIL } } 

	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3) 

	If lMsErroAuto
		MostraErro()
		Return .f.
	Else
		MsgInfo("Título NDF gerado com sucesso para o cooperado " + _cForn + " - " + Alltrim(_cNome))
	End If 

	oDlg:End()

Return .T.

Static Function ViewCMV()

	Local lRet	 := .T.
	Local nRet	 := 0
	Local oModel := Nil
	Local cObs   := ""

	cObs := "TITULO : " + SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) + chr(10)
	cObs += "CLIENTE: " + SE1->(E1_CLIENTE+E1_LOJA+ '-' + E1_NOMCLI)

	oModel := FWLoadModel("SERGPE01")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oModel:SetValue('SZ1MASTER', 'Z1_HISTORI', cObs)
	oModel:SetValue('SZ1MASTER', 'Z1_VALOR', NVALREC)

	FWMsgRun(, {|| nRet := FWExecView("INCLUSAO DO CMV POR BAIXA DE TITULO NO CONTAS A RECEBER.",'SERGPE01', MODEL_OPERATION_INSERT, , { || .T. },,  ,,,,,oModel)}, "Processando", "Carregando CMV")

	// Cancelado pelo usuario
	If nRet == 1
		Help(NIL, NIL, "FA070TIT", NIL, "Cancelado pelo usuario" ,1, 0, NIL, NIL, NIL, NIL, NIL, {"A baixa sera desconsiderada"})
		lRet := .f.
	End if 

Return lRet

