#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#Include "TMSXFUNB.CH"

/*/{Protheus.doc} SERTMS06
Modelo de dados para importacao do CTE
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS06()

	Local aArea   := GetArea()
	Local oBrowse := Nil

	Private aRotina := MenuDef()

	//Instânciando FWMBrowse 
	oBrowse := FWMBrowse():New()

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERTMS06")

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZK")

	//Setando a descrição da rotina
	oBrowse:SetDescription("Ct-e Importados")

	// Adiciona legenda
	oBrowse:AddLegend("!Empty(ZK_DTTMS)" 					  , "BR_VERMELHO"  , "Integrado")
	oBrowse:AddLegend("Empty(ZK_DTTMS) .AND. !EMPTY(ZK_LOG)"  , "BR_AMARELO"   , "Nao Integrado")
	oBrowse:AddLegend("Empty(ZK_DTTMS) .AND. EMPTY(ZK_LOG)"   , "BR_VERDE"	   , "Disponivel")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)	

return


Static Function MenuDef()

	Local aRot := {}

	//Adicionando opções
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERTMS06"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERTMS06"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERTMS06"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERTMS06"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERTMS06"	,0,5,0,NIL})
	aAdd(aRot,{"Imp. TMS" 	,"U_TMS06IMP()"	,0,4,0,NIL})

Return aRot


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel  := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStSZK   := FWFormStruct(1, "SZK")
	Local oStSZL   := FWFormStruct(1, "SZL")
	Local bCommit  := {|oModel| Commit(oModel)} 
	Local bPos     := {|oModel| TudoOK(oModel)} 

	// Cria o modelo
	oModel := MPFormModel():New("MSERTMS06",/*bPre*/, bPos,bCommit,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("SZKMASTER",/*cOwner*/, oStSZK)
	oModel:AddGrid( "SZLDETAIL", "SZKMASTER",oStSZL, /*[ bLinePre ]*/, /*[bLinePost]*/,/*[ bPre ]*/, /*[ bPost ]*/, /*[ bLoad ]*/)

	// Atribui o relacionamento
	oModel:SetRelation("SZLDETAIL", {{"ZL_FILIAL","FwXFilial('SZL')"}, {"ZL_CHVCTE","ZK_CHAVE"} }, SZL->( IndexKey( 1 ) ) )

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)

	//Adicionando descrição ao modelo
	oModel:SetDescription("Ct-e Importados")

	//Descricoes dos modelos de dados
	oModel:GetModel("SZKMASTER"):SetDescription("Conhecimentos de Frete")
	oModel:GetModel("SZLDETAIL"):SetDescription("Notas do CT-e")

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey( {"ZK_FILIAL","ZK_CHAVE"} )

	oModel:GetModel("SZLDETAIL"):SetOptional( .T. )

	//Verifica se realiza ativição do Modelo
	oModel:SetVldActive( { | oModel | ValidActv( oModel ) } )

Return oModel


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 26/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	// Recupera o modelo de dados
	Local oModel := FWLoadModel("SERTMS06")

	//Criação da estrutura de dados da View
	Local oStSZK := FWFormStruct(2, "SZK")
	Local oStSZL := FWFormStruct(2, "SZL")
	Local oView  := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Remocao do campo de vinculo
	oStSZL:RemoveField("ZL_CHVCTE")

	//Atribuindo fomulários para interface
	oView:AddField("VIEW_SZK"    , oStSZK   , "SZKMASTER")
	oView:AddGrid("VIEW_SZL"     , oStSZL  	, "SZLDETAIL") 

	//Criando os paineis
	oView:CreateHorizontalBox("SUPERIOR",070)
	oView:CreateHorizontalBox("INFERIOR",030)

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOK({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZK","SUPERIOR")
	oView:SetOwnerView("VIEW_SZL","INFERIOR")

	//Autoincremento
	oView:AddIncrementField("VIEW_SZL", "ZL_SEQUENC")

	//Atribui descricao
	oView:EnableTitleView("VIEW_SZL", "Notas Fiscais do Ct-e" )

	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

Return oView


/*/{Protheus.doc} ValidActv
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function ValidActv(oModel)

	Local lRet := .t.
	Local cMsg := ""
	Local cSolu:= ""
	Local nOper:= oModel:GetOperation()

	If  nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_VIEW
		Return .t.
	End If

	// Verifica se ja foi integrado no ERP.
	If !Empty(SZK->ZK_DTTMS)
		cMsg  := "Este evento já foi integrado no ERP e não será permitido realizar a Alteração\Exclusão."
		cSolu := "Favor selecionar outro registro"
		Help(NIL, NIL, "SERTMS06 - ValidActv ", NIL, cMsg ,1, 0, NIL, NIL, NIL, NIL, NIL, {cSolu})
		Return .f.
	End If

Return lRet


/*/{Protheus.doc} TudoOK
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function TudoOK(oModel)

	Local lRet		:= .t.
	Local oModelSZK := oModel:GetModel("SZKMASTER")
	Local nOperacao := oModel:GetOperation()

	If nOperacao == MODEL_OPERATION_DELETE
		lRet := .t.
		Return lRet
	End If


	// Verifica se a empresa logada possui o CNPJ do emitente informado
	If FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2] != oModelSZK:GetValue("ZK_CGCEMI")
		oModel:SetErrorMessage("",,oModel:GetId(),"","TudoOK","A inclusão deste CT-e só é permitida na empresa emitente.","Favor alterar o CNPJ do emitente.") 
		Return .f.
	End If

	If nOperacao == MODEL_OPERATION_INSERT

		SZK->(DbSetOrder(2))
		If SZK->(DbSeek(oModelSZK:GetValue("ZK_CHAVE")))
			oModel:SetErrorMessage("",,oModel:GetId(),"","TudoOK","Este CT-e ja foi importado.","") 
			Return .f.
		End If
	End If

Return lRet


/*/{Protheus.doc} Commit
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function Commit(oModel)

	Local nBckpModulo := nModulo
	Local lRet		  := .T.
	Local aErro		  := {}
	Local nOp		  := oModel:GetOperation()

	//TMS
	nModulo := 43 

	If lRet
		// Realiza o commit do modelo da tela
		//FWMsgRun(, {|| lRet := FWFormCommit( oModel ) }	, "Processando", "SERTMS06 - Gravando Ct-e...")
		lRet := FWFormCommit( oModel )
	End If

	If lRet .and. nOp == MODEL_OPERATION_INSERT
		// Realiza a integracao no SIGATMS
		//FWMsgRun(, {|| aErro := U_TMS06IMP() }		, "Processando", "SERTMS06 - Gerando movimentações no SIGATMS")
		aErro := U_TMS06IMP()
	End if 	

	nModulo := nBckpModulo
Return lRet


/*/{Protheus.doc} TMS06IMP
Importacao do CTe para o ERP
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TMS06IMP()

	Local aVetDoc  := {}
	Local aVetVlr  := {}
	Local aVetNFc  := {}

	Local aItemDTC := {}
	Local aCabDTC  := {}
	Local aItem    := {}
	Local lCont    := .T.
	Local cLotNfc  := ''
	Local cRet     := ''
	Local aCab     := {}
	Local aErrMsg  := {}

	Local cCodRem  := ""
	Local cLojRem  := ""
	Local cCodDes  := ""
	Local cLojDes  := ""
	Local cCodDev  := ""
	Local cLojDev  := ""
	Local cCodCal  := ""
	Local cLojCal  := ""
	Local cEstCal  := ""

	Local cRegOri  := ""
	Local cRegDes  := ""
	Local cRegCal  := ""

	Local cTomador := ""
	Local cTipoFrt := ""
	Local cCodProd := PADR(SuperGetMV("MV_YTMSCOD",.f.,"TMSSRV001"),TamSX3("B1_COD")[1])
	Local cData	   := ""
	Local cVendPad := SuperGetMV("MV_YVENSU",.f.,"000002")	
	Local cErroInt := ""
	Local lIncSA1  := SuperGetMV("MV_YINCSA1",.F.,.t.)
	Local aErrSA1  := {}
	Local i		   := 1
	Local cAliasSZL:= GetNextAlias()
	Local nQtdNfe  := 0
	Local nCont	   := 0

	Local nDifQtdVol := 0
	Local nDifPesoC	 := 0
	Local nDifPesoD	 := 0
	Local nDifMT	 := 0
	Local nDifVlCarg := 0
	Local cBkpFunname:= Funname()

	lMsErroAuto := .F.
	nModulo     := 43

	// Verifica se a integracao sera realizada na empresa correta
	If Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" })[1][2]) != Alltrim(SZK->ZK_CGCEMI)
		AAdd(aErrMsg,{"A integração deste CT-e só é permitida na empresa emitente.","00",""}) 
		lCont := .f.
	End If

	SA1->(DBSetOrder(3))

	// Verifica se existe cadastro do remetente
	If SA1->(DbSeek(xFilial("SA1") + SZK->ZK_CGCREM))
		cCodRem := SA1->A1_COD
		cLojRem	:= SA1->A1_LOJA
		cRegOri := SA1->A1_CDRDES
	Else
		If lIncSA1
			aErrSA1 := U_TMS06SA1("1",.F.)
			For i:= 1 to Len(aErrSA1)
				AAdd(aErrMsg,{aErrSA1[i],"00",""})
			Next

			If len(aErrMsg) > 0 
				lCont := .f.
			Else
				If SA1->(DbSeek(xFilial("SA1") + SZK->ZK_CGCREM))
					cCodRem := SA1->A1_COD
					cLojRem	:= SA1->A1_LOJA
					cRegOri := SA1->A1_CDRDES
				End If
			End If
		Else
			AAdd(aErrMsg,{"Não foi possivel localizar o Remetente como cliente","00",""})
			lCont := .f.
		End If
	End If

	// Verifica se existe cadastro do Destinatario
	If SA1->(DbSeek(xFilial("SA1") + SZK->ZK_CGCDES))
		cCodDes := SA1->A1_COD
		cLojDes	:= SA1->A1_LOJA
		cRegDes := SA1->A1_CDRDES
		cEstCal := SA1->A1_EST

	Else
		If lIncSA1
			aErrSA1 := U_TMS06SA1("2",.F.)
			For i:= 1 to Len(aErrSA1)
				AAdd(aErrMsg,{aErrSA1[i],"00",""})
			Next

			If len(aErrMsg) > 0 
				lCont := .f.
			Else
				If SA1->(DbSeek(xFilial("SA1") + SZK->ZK_CGCDES))
					cCodDes := SA1->A1_COD
					cLojDes	:= SA1->A1_LOJA
					cRegDes := SA1->A1_CDRDES
					cEstCal := SA1->A1_EST	
				End If
			End If
		Else
			AAdd(aErrMsg,{"Não foi possivel localizar o Destinatario como cliente","00",""})
			lCont := .f.
		End If
	End If	

	If lCont
		DA3->(DbSetOrder(3))
		If !DA3->(DbSeek(xFilial("DA3") + SZK->ZK_PLACA ))
			AAdd(aErrMsg,{"Não foi possivel localizar o Veiculo ("+ SZK->ZK_PLACA + ")","00",""})
			lCont := .f.		
		End If
	End iF

	If lCont
		BEGIN TRANSACTION

			BeginSql Alias cAliasSZL

				SELECT COUNT(*) AS QTDNFE FROM %Table:SZL% SZL
				WHERE SZL.ZL_FILIAL = %Exp:xFilial("SZL")%
				AND SZL.ZL_CHVCTE =  %Exp:SZK->ZK_CHAVE%
				AND SZL.D_E_L_E_T_ =''

			EndSQL

			nQtdNfe := (cAliasSZL)->QTDNFE

			(cAliasSZL)->(DbCloseArea())

			AAdd(aCab,{'DTP_QTDLOT',nQtdNfe,NIL})
			AAdd(aCab,{'DTP_QTDDIG',0,NIL})
			AAdd(aCab,{'DTP_TIPLOT','3',NIL})
			AAdd(aCab,{'DTP_STATUS','1',NIL})	//-- Em aberto

			MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCab,3)
		
			If lMsErroAuto
				// Pega o retorno do exeauto
				cErroInt := MemoRead(NomeAutoLog())
				// Apaga o arquivo
				FErase(NomeAutoLog())	
				lCont   := .F.
				AAdd(aErrMsg,{cErroInt,"00",""})
			Else
				cLotNfc := cRet
			EndIf

			If lCont
				lMsErroAuto := .F.

				// Tomador Remetente
				If SZK->ZK_TOMA3 == "0"
					cCodDev := cCodRem
					cLojDev	:= cLojRem
					cTomador:= "1"
					cTipoFrt:= "1"
					cCodCal := cCodDev
					cLojCal := cLojDev
				Elseif SZK->ZK_TOMA3 == "3"
					cCodDev := cCodDes
					cLojDev	:= cLojDes
					cTomador:= "2"	
					cTipoFrt:= "2"
					cCodCal := cCodDev
					cLojCal := cLojDev
				Else
					cCodDev := cCodRem
					cLojDev	:= cLojRem
					cTomador:= "1"	
					cTipoFrt:= "1"	
					cCodCal := cCodDev
					cLojCal := cLojDe	
				End if

				cRegCal		:= cRegDes

				aCabDTC := {{"DTC_FILORI" ,cFilant  , Nil},;
				{"DTC_LOTNFC" ,cLotNfc, Nil},;
				{"DTC_CLIREM" ,Padr(cCodRem,Len(DTC->DTC_CLIREM)), Nil},;
				{"DTC_LOJREM" ,Padr(cLojRem ,Len(DTC->DTC_LOJREM)), Nil},;
				{"DTC_DATENT" ,DDATABASE	, Nil},;
				{"DTC_CLIDES" ,Padr(cCodDes ,Len(DTC->DTC_CLIREM)), Nil},;
				{"DTC_LOJDES" ,Padr(cLojDes ,Len(DTC->DTC_LOJREM)), Nil},;
				{"DTC_CLIDEV" ,Padr(cCodDev ,Len(DTC->DTC_CLIREM)), Nil},;
				{"DTC_LOJDEV" ,Padr(cLojDev ,Len(DTC->DTC_LOJREM)), Nil},;
				{"DTC_CLICAL" ,Padr(cCodCal ,Len(DTC->DTC_CLIREM)), Nil},;
				{"DTC_LOJCAL" ,Padr(cLojCal ,Len(DTC->DTC_LOJREM)), Nil},;
				{"DTC_DEVFRE" ,cTomador     , Nil},;
				{"DTC_SERTMS" ,"3"       , Nil},;
				{"DTC_TIPTRA" ,"1"       , Nil},;
				{"DTC_SERVIC" ,"019"     , Nil},;
				{"DTC_CODNEG" ,"01"      , Nil},;
				{"DTC_TIPNFC" ,"0"       , Nil},;
				{"DTC_TIPFRE" ,cTipoFrt  , Nil},;
				{"DTC_SELORI" ,"2"       , Nil}}

				SZL->(DbSetOrder(1))
				SZL->(DBSeek(xFilial("SZL") + SZK->ZK_CHAVE))

				While SZL->(!eof()) .AND. SZL->(ZL_FILIAL + ZL_CHVCTE) == xFilial("SZL") + SZK->ZK_CHAVE

					// Recupera "AAMMDD"
					cData := SUBSTR(DTOS(DDATABASE),1,2) + SUBSTR(SZK->ZK_CHAVE,3,4) + "01"

					nCont++

					// Realiza o rateio da Qtd. Volume
					nQtdVol := round((SZK->ZK_QTDVOL/nQtdNfe),TamSX3("DTC_QTDVOL")[2])
					nDifQtdVol += nQtdVol

					// Realiza o rateio do Peso Declarado
					nPesoD := round((SZK->ZK_PESOD/nQtdNfe),TamSX3("DTC_PESO")[2])
					nDifPesoD += nPesoD

					// Realiza o rateio do Peso Cubico
					nPesoC := round((SZK->ZK_PESOC/nQtdNfe),TamSX3("DTC_PESOM3")[2])
					nDifPesoC += nPesoC

					// Realiza o rateio  Metro
					nMT := round((SZK->ZK_MTCUBIC/nQtdNfe),TamSX3("DTC_METRO3")[2])
					nDifMT += nMT

					// Realiza o rateio do Peso Metro
					nVlCarg := round((SZK->ZK_VLCARGA/nQtdNfe),TamSX3("DTC_VALOR")[2])
					nDifVlCarg += nVlCarg

					If nQtdNfe == nCont
						
						// O Restante dos volumes
						nQtdVol += SZK->ZK_QTDVOL - nDifQtdVol
						
						// Peso declaro
						nPesoD += SZK->ZK_PESOD - nDifPesoD
						
						// Peso cubado
						nPesoC += SZK->ZK_PESOC - nDifPesoC
						
						// Metro3
						nMT += SZK->ZK_MTCUBIC - nDifMT
						
						// Valor da carga
						nVlCarg += SZK->ZK_VLCARGA - nDifVlCarg

					End if

					aItem := {  {"DTC_NUMNFC" ,SZL->ZL_NUMNF 	, Nil},;
					{"DTC_SERNFC" ,SZL->ZL_SERIENF  		, Nil},;
					{"DTC_CODPRO" ,cCodProd					, Nil},;
					{"DTC_CODEMB" ,"CX" 					, Nil},;
					{"DTC_EMINFC" ,SZL->ZL_DTEMISS			, Nil},;
					{"DTC_QTDVOL" ,nQtdVol					, Nil},;
					{"DTC_PESO"   ,nPesoD					, Nil},;
					{"DTC_PESOM3" ,nPesoC					, Nil},;
					{"DTC_VALOR"  ,nVlCarg					, Nil},;
					{"DTC_BASSEG" ,0.00 					, Nil},;
					{"DTC_METRO3" ,nMT						, Nil},;
					{"DTC_EDI"    ,'2' 						, Nil},;
					{"DTC_NFEID"  ,SZL->ZL_CHVNFE 			, Nil},; //Chave Acesso
					{"DTC_QTDUNI" ,0 						, Nil}}


					AAdd(aVetNFc,{	{"DTC_CLIREM",Padr(cCodRem,Len(DTC->DTC_CLIREM))},;
					{"DTC_LOJREM", Padr(cLojRem    ,Len(DTC->DTC_LOJREM))},;
					{"DTC_NUMNFC", Padr(SZL->ZL_NUMNF,Len(DTC->DTC_NUMNFC))},;
					{"DTC_SERNFC", Padr(SZL->ZL_SERIENF     ,Len(DTC->DTC_SERNFC))},;
					{"DTC_CODPRO", cCodProd},;
					{"DTC_QTDVOL", nQtdVol},;
					{"DTC_PESO"  , nPesoD},;
					{"DTC_PESOM3", nPesoC},;
					{"DTC_METRO3", nMT},;
					{"DTC_VALOR" , nVlCarg}})

					AAdd(aItemDTC,aClone(aItem))	
					SZL->(DbSkip())
				EndDo

				// Verifica se existe nota fiscal eletronica.
				If Len(aItem) == 0

					AAdd(aErrMsg,{"Não foi possivel localizar as Nf-e transportadas envolvidas para este Ct-e","00",""})
					lCont := .f.
				Else
					// Parametros da TMSA050 (notas fiscais do cliente)
					// xAutoCab - Cabecalho da nota fiscal
					// xAutoItens - Itens da nota fiscal
					// xItensPesM3 - acols de Peso Cubado
					// xItensEnder - acols de Enderecamento
					// nOpcAuto - Opcao rotina automatica
					MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)
					If lMsErroAuto
						// Pega o retorno do exeauto
						cErroInt := MemoRead(NomeAutoLog())
						// Apaga o arquivo
						FErase(NomeAutoLog())	
						lCont   := .F.
						AAdd(aErrMsg,{cErroInt,"00",""})
					Else
						DTC->(dbCommit())
					EndIf
				End if
			EndIf

			If lCont
				AAdd(aVetDoc,{"DT6_FILORI",	cFilAnt})
				AAdd(aVetDoc,{"DT6_LOTNFC",	cLotNfc})
				AAdd(aVetDoc,{"DT6_FILDOC",	cFilAnt})
				AAdd(aVetDoc,{"DT6_DOC"   ,	SZK->ZK_DOC})
				AAdd(aVetDoc,{"DT6_SERIE" ,	SZK->ZK_SERIE})
				AAdd(aVetDoc,{"DT6_DATEMI",	SZK->ZK_DTEMISS})
				AAdd(aVetDoc,{"DT6_HOREMI",	StrTran(SUBSTR(SZK->ZK_HREMISS,1,5),":","")})
				AAdd(aVetDoc,{"DT6_VOLORI", SZK->ZK_QTDVOL})
				AAdd(aVetDoc,{"DT6_QTDVOL", SZK->ZK_QTDVOL})
				AAdd(aVetDoc,{"DT6_PESO"  , SZK->ZK_PESOD})
				AAdd(aVetDoc,{"DT6_PESOM3", 0.0000})
				//AAdd(aVetDoc,{"DT6_PESCOB", SZK->ZK_PESOD})
				//AAdd(aVetDoc,{"DT6_PESLIQ", SZK->ZK_PESOD})
				AAdd(aVetDoc,{"DT6_METRO3", SZK->ZK_MTCUBIC})
				AAdd(aVetDoc,{"DT6_VALMER", SZK->ZK_VLCARGA})
				AAdd(aVetDoc,{"DT6_QTDUNI", 0})
				AAdd(aVetDoc,{"DT6_VALFRE", SZK->ZK_VLPREST})
				AAdd(aVetDoc,{"DT6_VALIMP", SZK->ZK_VLIMP})
				AAdd(aVetDoc,{"DT6_VALTOT", SZK->ZK_VLPREST})
				AAdd(aVetDoc,{"DT6_BASSEG", 0.00})
				AAdd(aVetDoc,{"DT6_SERTMS", "3"}) // Entrega
				AAdd(aVetDoc,{"DT6_TIPTRA", "1"}) // Rodoviario
				AAdd(aVetDoc,{"DT6_DOCTMS", "2"})
				AAdd(aVetDoc,{"DT6_CDRORI", cRegOri})
				AAdd(aVetDoc,{"DT6_CDRDES", cRegDes})
				AAdd(aVetDoc,{"DT6_CDRCAL", cRegCal})
				AAdd(aVetDoc,{"DT6_TABFRE", "RC01"})
				AAdd(aVetDoc,{"DT6_TIPTAB", "01"})
				AAdd(aVetDoc,{"DT6_SEQTAB", "00"})
				AAdd(aVetDoc,{"DT6_TIPFRE", cTipoFrt})
				AAdd(aVetDoc,{"DT6_FILDES", cFilAnt})
				AAdd(aVetDoc,{"DT6_BLQDOC", "2"})
				AAdd(aVetDoc,{"DT6_PRIPER", "2"})
				AAdd(aVetDoc,{"DT6_PERDCO", 0.00000})
				AAdd(aVetDoc,{"DT6_FILDCO", ""})
				AAdd(aVetDoc,{"DT6_DOCDCO", ""})
				AAdd(aVetDoc,{"DT6_SERDCO", ""})
				AAdd(aVetDoc,{"DT6_CLIREM", Padr(cCodRem ,Len(DTC->DTC_CLIREM))})
				AAdd(aVetDoc,{"DT6_LOJREM", Padr(cLojRem ,Len(DTC->DTC_LOJREM))})
				AAdd(aVetDoc,{"DT6_CLIDES", Padr(cCodDes ,Len(DTC->DTC_CLIREM))})
				AAdd(aVetDoc,{"DT6_LOJDES", Padr(cLojDes ,Len(DTC->DTC_LOJREM))})
				AAdd(aVetDoc,{"DT6_CLIDEV", Padr(cCodDev ,Len(DTC->DTC_CLIREM))})
				AAdd(aVetDoc,{"DT6_LOJDEV", Padr(cLojDev ,Len(DTC->DTC_LOJREM))})
				AAdd(aVetDoc,{"DT6_CLICAL", Padr(cCodCal ,Len(DTC->DTC_CLIREM))})
				AAdd(aVetDoc,{"DT6_LOJCAL", Padr(cLojCal ,Len(DTC->DTC_LOJREM))})
				AAdd(aVetDoc,{"DT6_DEVFRE", cTomador})
				AAdd(aVetDoc,{"DT6_FATURA", ""})
				AAdd(aVetDoc,{"DT6_SERVIC", "019"})
				AAdd(aVetDoc,{"DT6_CODNEG", "01"})
				AAdd(aVetDoc,{"DT6_CODMSG", ""})
				AAdd(aVetDoc,{"DT6_STATUS", "1"})
				AAdd(aVetDoc,{"DT6_DATEDI", CToD("  /  /  ")})
				AAdd(aVetDoc,{"DT6_NUMSOL", ""})
				AAdd(aVetDoc,{"DT6_VENCTO", CToD("  /  /  ")})
				AAdd(aVetDoc,{"DT6_FILDEB", cFilAnt})
				AAdd(aVetDoc,{"DT6_PREFIX", ""})
				AAdd(aVetDoc,{"DT6_NUM"   , ""})
				AAdd(aVetDoc,{"DT6_TIPO"  , ""})
				AAdd(aVetDoc,{"DT6_MOEDA" , 1})
				AAdd(aVetDoc,{"DT6_BAIXA" , CToD("  /  /  ")})
				AAdd(aVetDoc,{"DT6_FILNEG", cFIlAnt})
				AAdd(aVetDoc,{"DT6_ALIANC", ""})
				AAdd(aVetDoc,{"DT6_REENTR", 0})
				AAdd(aVetDoc,{"DT6_TIPMAN", ""})
				AAdd(aVetDoc,{"DT6_PRZENT", dDATABASE})
				AAdd(aVetDoc,{"DT6_IDRCTE", SZK->ZK_STATUS})
				AAdd(aVetDoc,{"DT6_PROCTE", SZK->ZK_PROTSEF})
				AAdd(aVetDoc,{"DT6_CHVCTE", SZK->ZK_CHAVE})
				AAdd(aVetDoc,{"DT6_SITCTE", "2"})
				AAdd(aVetDoc,{"DT6_RETCTE", SZK->ZK_STATUS + " - "+ SZK->ZK_MOTIVO })
				AAdd(aVetDoc,{"DT6_AMBIEN", 1})
				AAdd(aVetDoc,{"DT6_FIMP"  , "1"})

				AAdd(aVetVlr,{	{"DT8_CODPAS","01"},;
				{"DT8_VALPAS", SZK->ZK_VLPREST},;
				{"DT8_VALIMP", SZK->ZK_VLIMP},;
				{"DT8_VALTOT", SZK->ZK_VLPREST},;
				{"DT8_FILORI", ""},;
				{"DT8_TABFRE", "RC01"},;
				{"DT8_TIPTAB", "01"},;
				{"DT8_FILDOC", cFilAnt},;
				{"DT8_CODPRO", cCodProd},;
				{"DT8_DOC"   , SZK->ZK_DOC},;
				{"DT8_SERIE" , SZK->ZK_SERIE},;
				{"VLR_ICMSOL",0}})

				AAdd(aVetVlr,{  {"DT8_CODPAS","TF"},;
				{"DT8_VALPAS", SZK->ZK_VLPREST},;
				{"DT8_VALIMP", SZK->ZK_VLIMP},;
				{"DT8_VALTOT", SZK->ZK_VLPREST},;
				{"DT8_FILORI", ""},;
				{"DT8_TABFRE", ""},;
				{"DT8_TIPTAB", ""},;
				{"DT8_FILDOC", cFilAnt},;
				{"DT8_CODPRO", cCodProd},;
				{"DT8_DOC"   , SZK->ZK_DOC},;
				{"DT8_SERIE" , SZK->ZK_SERIE},;
				{"VLR_ICMSOL", 0}})

				Pergunte("TMB200",.F.)
				// Desliga a tela de Preview
				SetMVValue("TMB200","MV_PAR10",2) 
				// Realiza integracao com SIGATMS
				aErrMsg := TMSImpDoc(aVetDoc,aVetVlr,aVetNFc,cLotNfc,.F.,SZK->ZK_PCIMP, 1,.f.,.T.,.T.,.T.)
				// Ativa a tela de Preview
				SetMVValue("TMB200","MV_PAR10",1) 

				If Len(aErrMsg) > 0
					DisarmTransaction()
				Else

					Reclock("SZK",.F.)
					SZK->ZK_LOG	  := ""
					SZK->ZK_DTTMS := DDATABASE
					MsUnLock()

					SF2->(DbSetOrder(1))

					If SF2->(DbSeek(xFilial("SF2") + SZK->(ZK_DOC + ZK_SERIE)))

						SA3->(DbSetOrder(1))
						If !SA3->(DbSeek(xFilial("SA3") + cVendPad))
							cVendPad := ""
						End IF

						Reclock("SF2",.f.)
						SF2->F2_HORA	:= SUBSTR(SZK->ZK_HREMISS,1,5)
						SF2->F2_CHVNFE 	:= SZK->ZK_CHAVE
						SF2->F2_VEND1	:= cVendPad
						SF2->F2_EST		:= cEstCal
						MsUnLock()

						If !Empty(cVendPad)

							SD2->(DbSetOrder(3))
							//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                                                                                     
							If SD2->(DbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))

								While SD2->(!EOF()) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)

									Reclock("SD2",.f.)
									SD2->D2_COMIS1	:= SA3->A3_COMIS
									SD2->D2_EST		:= cEstCal
									MsUnLock()					

									SD2->(DbSkip())
								EndDo
							End If

							SE1->(DbSetOrder(2))
							//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
							If SE1->(DbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC)))

								While SE1->(!EOF()) .and. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC)

									Reclock("SE1",.f.)
									SE1->E1_VEND1	:= SF2->F2_VEND1
									SE1->E1_COMIS1	:= SA3->A3_COMIS
									MsUnLock()	

									SE1->(DbSkip())
								EndDo					

							End If
						End If

						SF3->(DbSetOrder(6))

						If SF3->(DbSeek(xFilial("SF3") + SF2->(F2_DOC + F2_SERIE)))

							While SF3->(!EOF()) .and. SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE) == xFilial("SF3") + SF2->(F2_DOC + F2_SERIE)

								Reclock("SF3",.F.)
								SF3->F3_CODRSEF := SZK->ZK_STATUS
								SF3->F3_CHVNFE  := SZK->ZK_CHAVE
								SF3->F3_ESTADO	:= cEstCal
								SF3->F3_PROTOC  := SZK->ZK_PROTSEF
								SF3->F3_DESCRET := "Autorizado o uso do CT-e"
								SF3->F3_ESPECIE := "CTE"
								MsUnLock()

								SF3->(DbSkip())
							EndDo
						End If

						SFT->(DbSetOrder(1))
						//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
						If SFT->(DbSeek(xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA)))

							While SFT->(!eof()) .AND. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA)
								Reclock("SFT",.f.)
								SFT->FT_CODNFE	:= SZK->ZK_PROTSEF
								SFT->FT_CHVNFE	:= SZK->ZK_CHAVE
								SFT->FT_ESTADO	:= cEstCal
								SFT->FT_ESPECIE := "CTE"
								MsUnLock()		
								SFT->(DbSkip())
							EndDo
						EndIf

						DT6->(DbSetOrder(1))
						If DT6->(DbSeek(xFilial("DT6") + cFilAnt + SF2->(F2_DOC + F2_SERIE)))
							Reclock("DT6",.f.)
							DT6->DT6_IDRCTE	:= SZK->ZK_STATUS
							DT6->DT6_PROCTE	:= SZK->ZK_PROTSEF
							DT6->DT6_SITCTE	:= "2"
							DT6->DT6_RETCTE	:= SZK->ZK_STATUS + " - "+ Alltrim(SZK->ZK_MOTIVO)
							DT6->DT6_AMBIEN	:= 1
							DT6->DT6_CHVCTE := SZK->ZK_CHAVE
							DT6->DT6_HOREMI := StrTran(SUBSTR(SZK->ZK_HREMISS,1,5),":","")
							DT6->DT6_PESCOB := SZK->ZK_PESOD
							DT6->DT6_PESLIQ := SZK->ZK_PESOD							
							MsUnLock()								
						End If
					End If

					// Localiza se existe MDFE-e pronto
					// para este CTE para importar
					TMS06MDF()

				End If
			EndIf	
		END TRANSACTION 

	End If
	If Len(aErrMsg) > 0 
		For i := 1 to len(aErrMsg)
			Reclock("SZK",.F.)
			SZK->ZK_LOG := SZK->ZK_LOG + aErrMsg[i][1] + Chr(13) + Chr(10)
			MsUnLock()
		Next
	End If
	
Return aErrMsg

/*/{Protheus.doc} TMS06MDF
Processo o MDF-e que contem esse CTe se ja estiver
importado.
@author mauricio.santos
@since 14/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TMS06MDF()

	Local cAliasMDF := GetNextAlias()
	Local aArea		:= GetArea()
	Local aAreaSZL  := SZL->(GetArea())
	Local aAreaSZK  := SZK->(GetArea())
	Local aAreaSZM  := SZM->(GetArea())
	Local aAreaSZN  := SZN->(GetArea())
	Local aAreaSZO  := SZO->(GetArea())
	Local aAreaSZP  := SZP->(GetArea())

	BeginSQL Alias cAliasMDF
		SELECT * FROM %Table:SZO% SZO
		JOIN %Table:SZN% SZN ON SZN.ZN_FILIAL = %Exp:xFilial("SZN")%
		AND SZN.ZN_CHVMDFE = SZO.ZO_CHVMDFE
		AND SZN.D_E_L_E_T_ =''
		WHERE SZO.ZO_FILIAL = %Exp:xFilial("SZO")%
		AND SZO.D_E_L_E_T_ =''
		AND SZO.ZO_CHVCTE = %Exp:SZK->ZK_CHAVE%
		AND SZN.ZN_DTTMS =''
	EndSQL

	While (cAliasMDF)->(!EOF()) 

		SZN->(DbSetOrder(1))
		//ZN_FILIAL+ZN_CHVMDFE
		If SZN->(DbSeek((cAliasMDF)->(ZN_FILIAL+ZN_CHVMDFE)))
			U_TMS08IMP()
		End If
		(cAliasMDF)->(DBSkip())
	EndDo

	RestArea(aArea)
	RestArea(aAreaSZK)
	RestArea(aAreaSZL)
	RestArea(aAreaSZM)
	RestArea(aAreaSZN)
	RestArea(aAreaSZO)
	RestArea(aAreaSZP)	

Return


/*/{Protheus.doc} TMS06SA1
Cadastramento da entidade cliente Remetente/Destinatario
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cTipo, characters, description
@param lTela, logical, description
@type function
/*/
User Function TMS06SA1(cTipo,lTela)

	Local oModelSA1 := Nil
	Local cCodRegiao := ""
	Local aErro		 := {}

	Default lTela := .t.

	//Remetente
	If cTipo == "1" 
		cCNPJ 	  := SZK->ZK_CGCREM 
		cIE		  := SZK->ZK_IEREM  
		cRazao 	  := SZK->ZK_XNOMERE
		cFantasia := SZK->ZK_XFANTRE
		cEndereco := Alltrim(SZK->ZK_ENDREM) + ", " + Alltrim(SZK->ZK_NROREM)   
		cBairro	  := SZK->ZK_BAIREM 
		cUF		  := SZK->ZK_UFREM  
		cMuncipio := SZK->ZK_MUNREM 
		cCodMun   := SZK->ZK_CMUREM 
		cCEP	  := SZK->ZK_CEPREM 
		cTelefone := SZK->ZK_FONEREM
		cEmail	  := SZK->ZK_EMAIREM

		// Destinatario
	ElseIf cTipo == "2"
		cCNPJ 	  := SZK->ZK_CGCDES  
		cIE		  := SZK->ZK_IEDES    
		cRazao 	  := SZK->ZK_XNOMEDE
		cFantasia := SZK->ZK_XFANTDE
		cEndereco := Alltrim(SZK->ZK_ENDDES) + ", " + Alltrim(SZK->ZK_NRODES)    
		cBairro	  := SZK->ZK_BAIDES  
		cUF		  := SZK->ZK_UFDES    
		cMuncipio := SZK->ZK_MUNDES 
		cCodMun   := SZK->ZK_CMUDES  
		cCEP	  := SZK->ZK_CEPDES  
		cTelefone := SZK->ZK_FONEDES
		cEmail	  := SZK->ZK_EMAIDES
	End if

	DUY->(DbSetOrder(6))

	If Empty(cFantasia)
		cFantasia := cRazao
	End If

	// Localiza a regiao do cliente
	If DUY->(DbSeek(xFilial("DUY") + cUF + Substr(cCodMun,3,TAMSX3("A1_COD_MUN")[1])))
		cCodRegiao := DUY->DUY_GRPVEN
	End IF

	oModelSA1 := FWLoadModel("CRMA980")
	oModelSA1:SetOperation(MODEL_OPERATION_INSERT)
	oModelSA1:Activate()

	//oModelSA1:SetValue('SA1MASTER', 'A1_COD'  	 , GETSXENUM("SA1", "A1_COD"))
	oModelSA1:SetValue('SA1MASTER', 'A1_LOJA'    , "01")
	oModelSA1:SetValue('SA1MASTER', 'A1_PESSOA'  , IIF(LEN(cCNPJ) == 14, "J", "F"))
	oModelSA1:SetValue('SA1MASTER', 'A1_TIPO'    , "F")
	oModelSA1:LoadValue('SA1MASTER', 'A1_CGC'     , cCNPJ)
	oModelSA1:SetValue('SA1MASTER', 'A1_NOME'    , Substr(cRazao,1,TAMSX3("A1_NOME")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_NREDUZ'  , Substr(cFantasia,1,TAMSX3("A1_NREDUZ")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_END'     , Substr(cEndereco,1,TAMSX3("A1_END")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_BAIRRO'  , Substr(cBairro,1,TAMSX3("A1_BAIRRO")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_EST'     , cUF)
	oModelSA1:SetValue('SA1MASTER', 'A1_MUN'     , Substr(cMuncipio,1,TAMSX3("A1_MUN")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_COD_MUN' , Alltrim(Substr(cCodMun,3,TAMSX3("A1_COD_MUN")[1])))
	oModelSA1:SetValue('SA1MASTER', 'A1_CEP'     , Substr(cCEP,1,TAMSX3("A1_CEP")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_DDD'     , Substr(cTelefone,1,2))
	oModelSA1:SetValue('SA1MASTER', 'A1_TEL'     , Substr(cTelefone,3,TAMSX3("A1_TEL")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_INSCR'   , Substr(cIE,1,TAMSX3("A1_INSCR")[1]))
	oModelSA1:SetValue('SA1MASTER', 'A1_CDRDES'  , cCodRegiao)
	oModelSA1:SetValue('SA1MASTER', 'A1_EMAIL'  , cEmail)
	oModelSA1:SetValue('SA1MASTER', 'A1_CODPAIS' , "01058")
	oModelSA1:SetValue('SA1MASTER', 'A1_PAIS' 	 , "105")

	If lTela  
		FWMsgRun(, {|| nRet := FWExecView("Cadastro",'CRMA980', MODEL_OPERATION_INSERT, , { || .T. } , ,30,,,,,oModelSA1)}, "Processando", "Carregando dados para o cadastro...")
	Else
		Private l030Auto := .t. 
		If oModelSA1:VldData()
			If !oModelSA1:CommitData()
				AAdd(aErro,{GetErroModel(oModelSA1),"00",""})
			End If
		Else
			AAdd(aErro,{GetErroModel(oModelSA1),"00",""})
		End IF
	End If
	oModelSA1:DeActivate()
	oModelSA1:Destroy()
	oModelSA1 := Nil

Return aErro


/*/{Protheus.doc} GetErroModel
//TODO Descrição auto-gerada.
@author mauricio.santos
@since 13/04/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function GetErroModel(oModel)

	Local aErro := oModel:GetErrorMessage()
	Local cMessage := ""

	cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
	cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
	cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
	cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
	cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
	cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
	cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
	cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
	cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'

	// Informa que o modelo foi alterado para que o sistema realize o committ novamente.
	oModel:lModify := .t. 

Return  cMessage

User Function TMSA144Vge()
Local cRet     := ""
Local cFunName := Substr(FunName(),1,7)

If cFunName == "TMSA144" .Or. cFunName == "TMSA145"
	If TmsExp() .And. cSerTms $ "23"
		cRet := M->DTQ_VIAGEM
	EndIf
EndIf

Return( cRet )