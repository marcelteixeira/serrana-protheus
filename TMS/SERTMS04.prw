#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOTVS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} SERTMS04
Notas fiscais importadas via XML
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function SERTMS04()
	
	Local aArea   := GetArea()
	Local oBrowse := Nil

	Private aRotina := MenuDef()
	
	//Instânciando FWMBrowse 
	oBrowse := FWMBrowse():New()
	
	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SERTMS04")

	//Setando a tabela de cadastro
	oBrowse:SetAlias("SZE")

	//Setando a descrição da rotina
	oBrowse:SetDescription("Notas Fiscais Importadas")

	// Adiciona legenda
	oBrowse:AddLegend("!Empty(ZE_LOTNFC)" , "BR_VERMELHO"	  , "Integrado")
	oBrowse:AddLegend("Empty(ZE_LOTNFC)"  , "BR_VERDE"	  	  , "Disponivel")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
return

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()

	Local aRot := {}

	//Adicionando opções
	aAdd(aRot,{"Pesquisar"	,"VIEWDEF.SERTMS04"	,0,1,0,NIL})
	aAdd(aRot,{"Visualizar"	,"VIEWDEF.SERTMS04"	,0,2,0,NIL})
	aAdd(aRot,{"Incluir" 	,"VIEWDEF.SERTMS04"	,0,3,0,NIL})
	aAdd(aRot,{"Alterar" 	,"VIEWDEF.SERTMS04"	,0,4,0,NIL})
	aAdd(aRot,{"Excluir" 	,"VIEWDEF.SERTMS04"	,0,5,0,NIL})
	aAdd(aRot,{"Importa XML","StaticCall(SERTMS04,ImpXML)"	,0,3,0,NIL})

Return aRot

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()

    // Criação do objeto do modelo de dados
    Local oModel  := Nil

    // Criação da estrutura de dados utilizada na interface
    Local oStSZE   := FWFormStruct(1, "SZE")
  
    // Cria o modelo
    oModel := MPFormModel():New("MSERTMS99",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

    // Atribuindo formulários para o modelo
    oModel:AddFields("SZEMASTER",/*cOwner*/, oStSZE)

    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({})

	//Define se a carga dos dados será por demanda.
	oModel:SetOnDemand(.t.)
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Nota Fiscal Importada")

	//Descricoes dos modelos de dados
    oModel:GetModel("SZEMASTER"):SetDescription("Notas Fiscais")
    
Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

    // Recupera o modelo de dados
    Local oModel := FWLoadModel("SERTMS04")
    
    //Criação da estrutura de dados da View
    Local oStSZE := FWFormStruct(2, "SZE")
	Local oView  := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()

	//Seta o modelo
    oView:SetModel(oModel)

    //Atribuindo fomulários para interface
    oView:AddField("VIEW_SZE"    , oStSZE   , "SZEMASTER")

	//Criando os paineis
    oView:CreateHorizontalBox("TOTAL",100)

	//Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZE","TOTAL")
    
	//Ativa ou desativa o uso da MsgRun na carga do formulario
	oView:SetProgressBar(.T.)

Return oView

/*/{Protheus.doc} ImpSZE
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ImpSZE()

	Processa({|| ImpXML()}, "Importando XML...")

Return


/*/{Protheus.doc} ImpXML
Ler os xml e realiza a importacao
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ImpXML()
	
	Local cExtens    := "Arquivos XML ( *.XML ) |*.XML|*.TXT|"
	Local cDirect 	 := ""
	Local aFiles	 := {}
	Local nTotXML	 := 0
	Local nHandle	 := 0
	Local cBuffer	 := ""
	Local cAviso	 := ""
	Local cErro		 := ""
	Local oProtNFe	 := Nil
	Local oNF		 := Nil
	Local aErro		 := {}
	Local aFileTXT	 := {}
	
	Private cDirLido := "LIDOS"
	Private cBarra	 := If(isSrvUnix(),"/","\")
	Private oXML	 := Nil
	
	// Selecione o diretorio
	cDirect := cGetFile( cExtens, "Selecione o diretorio",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY ,.F.)
	
	// Verifica se o usuario selecionou de fato
	cDirect := ALLTRIM( cDirect )
	
	// Caso nao exista caminho, retorne.
	If Empty(cDirect)
		Return
	End If
	
	if SubStr( cDirect, Len(cDirect) ) <> cBarra
		cDirect := cDirect + cBarra
	endif

	If !ExistDir(cDirect + cDirLido )
		If MakeDir(cDirect + cDirLido) > 0 
			Help(NIL, NIL, "ImpXML", NIL, "Não foi possivel criar o diretorio :" + cDirect + cDirLido  ,1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor verificar"})
			Return
		End If
	EndIf	

	// Exporta xML de estiver dentro de
	// arquivos TXT
	FWMsgRun(, {|| ExporXML(cDirect) }, "Processando", "Exportando XML de arquivos *.TXT")

	// Ler o diretorio para buscar arquivos XML
    ADir(cDirect + "*.xml", aFiles)

	// Recupera a quantidade
	nTotXML := len(aFiles)
	
	// Alimenta a regua
	ProcRegua(nTotXML)
	
	SZE->(DbSetOrder(2))
	
	For i:= 1 to nTotXML

        // Monta o caminho do arquivo
        cDirectXML := cDirect + aFiles[i]

		// Regua
		IncProc(cDirectXML)
		
        // Valida se consegue abrir o arquivo
        nHandle := FOpen(cDirectXML,0)

        // Caso nao consiga abrir o arquivo Loop
        If nHandle == -1
            Loop
        End If
		
		//Fecha o arquivo
		FCLOSE(nHandle) 

        // Realiza a leitura do arquivo
        cBuffer := MemoRead( cDirectXML )
	
		// Verifica o conteudo
		If Empty(cBuffer)
			Loop
		End If
    
		// Recupera o XML em formato de Objeto 
        oXML := XmlParser( cBuffer, "_", @cAviso, @cErro )
        
        // Verifica a criação do Objeto
        If oXML <> Nil 
        	
        	// Verifica se o XML e de uma nota fiscal
        	If Type("oXML:_NfeProc") == "U"  .and. Type("oXML:_ProtNFE") == "U" 
        		Loop
        	End If
        	
        	If Type("oXML:_NfeProc") <> "U"
				oNF 	 := oXML:_NFeProc:_NFe
				oProtNFe := oXML:_NFeProc:_ProtNFE
			Else
				oNF 	 := oXML:_NFe
				oProtNFe := oXML:_ProtNFE
			Endif
			
			oNF := oNF:_InfNfe
			
			oIDE     := oNF:_Ide
			oRem     := oNF:_Emit
			oDes     := oNF:_Dest
			oItens   := oNF:_Det
			
			// Verifica se a nota fiscal ja esta cadastrada
			If SZE->(DbSeek(xFilial("SZE") + oProtNFe:_infProt:_chNFe:TEXT))
				Loop
			End If
			
			oModel := FwLoadModel("SERTMS04")
			oModel:SetOperation( MODEL_OPERATION_INSERT )
			oModel:Activate()
			
			oModelSZE := oModel:GetModel("SZEMASTER")
			
			// Salva o XML da nota fiscal
			oModelSZE:SetValue("ZE_XML",cBuffer)
					
			// Preenhe informacao da Nota Fiscal
			DadosNF(oModel,oNF,oProtNFe)
			
			// Preenche informacao do Remetente
			REMDEST(oModel,oRem,"1")
			
			// Preenche informcao do destinatario
			REMDEST(oModel,oDes,"2")
					
			If oModel:VldData()
				oModel:CommitData()
				__CopyFile( cDirectXML, cDirect + cDirLido + cBarra + aFiles[i]) 
				FERASE(cDirectXML)
			Else
				aErro := oModel:GetErrorMessage()
				cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
				cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
				cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
				cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
				cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
				cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
				cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
				cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
				cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'	
				
				Help(NIL, NIL, "Importador XML", NIL, cMessage ,1, 0, NIL, NIL, NIL, NIL, NIL, {""})
			End if

        Else	
        	Loop
        End If
        
   Next

Return


/*/{Protheus.doc} ExporXML
Exporta arquivos xml dentro do txt
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param cDirect, characters, description
@type function
/*/
Static Function ExporXML(cDirect)
	
	Local aFileTXT 	 := {}
	Local i		   	 := 0
	Local nHandle    := 0
	Local nLast		 := 0
	Local cLine		 := ""
	Local cDirectXML := ""
	Local cAviso	 := ""
	Local cErro		 := ""
	Local nHandleTXT := 0
	Private oXML		 := Nil
	
    ADir(cDirect + "*.txt", aFileTXT)
    
    For i:= 1 to len(aFileTXT)
    
	    cDirectTXT := cDirect + aFileTXT[i]
	
		// Valida se consegue abrir o arquivo
		nHandle := FT_FUse(cDirectTXT)
		
		// Caso nao consiga abrir o arquivo Loop
		If nHandle == -1
		    Loop
		End If
		    
		// Posiciona na primeria linha
		FT_FGoTop()
		
		// Retorna o número de linhas do arquivo
		nLast := FT_FLastRec()
        
        While !FT_FEOF()
		    
		    cLine  := LeLinha()
		    
		    oXML := XmlParser( cLine, "_", @cAviso, @cErro )
        
		    // Verifica se e um XML
		    If oXML <> Nil 
		    	
			   // Verifica se o XML e de uma nota fiscal
	        	If Type("oXML:_NfeProc") != "U"  .or. Type("oXML:_ProtNFE") != "U" 
	        		
		        	If Type("oXML:_NfeProc") <> "U"
						oNF 	 := oXML:_NFeProc:_NFe
						oProtNFe := oXML:_NFeProc:_ProtNFE
					Else
						oNF 	 := oXML:_NFe
						oProtNFe := oXML:_ProtNFE
					Endif
			    	
			    	// Cria o arquivo no mesmo diretorio
			    	 nHandleTXT := FCREATE(cDirect + oProtNFe:_infProt:_chNFe:TEXT + ".xml")
			    	 
			    	 // Verifica se conseguiu criar
			    	 if !nHandleTXT = -1
			    	 	// escreve com a linha
		    	         FWrite(nHandleTXT,cLine)
		    	         // Fecha o arquivo.
		    	         FClose(nHandleTXT)
	    	         End If
			    	 
		    	 End If
		    
		    End If
		    
		    FT_FSKIP()
		EndDo
		
		// Fecha o Arquivo
		FT_FUSE()
		
		__CopyFile( cDirectTXT, cDirect + cDirLido + cBarra + aFileTXT[i]) 
		FERASE(cDirectTXT)
        
    Next
    
Return


/*/{Protheus.doc} LeLinha
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function LeLinha()

	Local cLinhaTmp := ""
	Local cLinhaM100 := ""
	
	cLinhaTmp := FT_FReadLN()
	
	If !Empty(cLinhaTmp)
		cIdent:= Substr(cLinhaTmp,1,5)
		If Len(cLinhaTmp) < 1023
			cLinhaM100 := cLinhaTmp
		Else
			cLinAnt := cLinhaTmp
			cLinhaM100 += cLinAnt
			Ft_FSkip()
			cLinProx:= Ft_FReadLN()
			If Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent
				While Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent .and. !Ft_fEof()
					cLinhaM100 += cLinProx
					Ft_FSkip()
					cLinProx := Ft_fReadLn()
					If Len(cLinProx) < 1023 .and. Substr(cLinProx,1,1) <> cIdent
						cLinhaM100 += cLinProx
					Endif
				Enddo
			Else
				cLinhaM100 += cLinProx
			Endif
		Endif
	Endif

Return(cLinhaM100)

/*/{Protheus.doc} DadosNF
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param oDados, object, description
@param oProtNFe, object, description
@type function
/*/
Static Function DadosNF(oModel,oDados,oProtNFe)
	
	Local nPosFrt  := 1
	Local cIdenf   := ".-FRETE:"
	Local nLenID   := Len(cIdenf)
	Local nValFrt  := 0
	Local nQtdVol  := 0
	Local nPesoB   := 0
	Local nPesoL   := 0
	Local nBaseICM := 0
	Local nValICM  := 0
	Local nBaseST  := 0
	Local nValST   := 0
	Local cNota	   := ""
	Local cSerie   := "" 
	Local dData	   := CTOD("//")
	Local nValNF   := 0
	Local cNFEID   := ""
	Local cCNPJTRA := ""
	Local cTipFre  := "1"
	Local cDevFre  := "1"
	Local aitens   := {}
	Local aVol	   := {}
	Local y		   := 0
	Local w		   := 0
	Local cInfComp := ""
	Local cTexto   := ""
	
	Local oModelSZE := oModel:GetModel("SZEMASTER")
	Local lValid	:= .t.
	
	oNF		 := oDados:_Ide
	oTotalNF := oDados:_Total:_ICMSTot
	oTransp  := oDados:_Transp
	oVol	 := IIF(AttIsMemberOf(oTransp,"_Vol"),oTransp:_Vol,NiL)
	oInfAdic := IIF(AttIsMemberOf(oDados,"_InfAdic"),oDados:_InfAdic,NiL) 
	oRem     := oDados:_Emit
	oDes     := oDados:_Dest
	oItens   := oDados:_Det
	
	// Nota Fiscal
	If AttIsMemberOf(oNF,"_nNF") 
        cNota :=  Upper(AllTrim(oNF:_nNF:Text))
        cNota := StrZero(Val(AllTrim(cNota)),TamSx3("F1_DOC")[1])
    End If
    
 	If AttIsMemberOf(oNF,"_serie") 
        cSerie :=  Upper(AllTrim(oNF:_serie:Text))
    End If   

 	If AttIsMemberOf(oNF,"_dHEmi") 
       dData :=  CTOD(SubStr(oNF:_dhEmi:TEXT, 9, 2)+'/'+SubStr(oNF:_dhEmi:TEXT, 6, 2)+'/'+SubStr(oNF:_dhEmi:TEXT, 1, 4))
    End If   
    
    // Totais    
    If AttIsMemberOf(oTotalNF,"_vNF") 
        nValNF :=  Val(oTotalNF:_vNF:Text)
    End If 
    
    If oVol <> Nil
    	
    	if VALTYPE(oVol) == "O"
			AADD(aVol,oVol)
		Else
			aVol := oVol
		End if
    
		For w:= 1 to len(aVol)
		    If AttIsMemberOf(aVol[w],"_qVol") 
		        nQtdVol +=  Val(aVol[w]:_qVol:Text)
		    End If 
		
		    If AttIsMemberOf(aVol[w],"_pesoB") 
		        nPesoB +=  Val(aVol[w]:_pesoB:Text)
		    End If 
		
		    If AttIsMemberOf(aVol[w],"_pesoL") 
		        nPesoL +=  Val(aVol[w]:_pesoL:Text)
		    End If 
	    Next
    End if
    
    
    If nQtdVol == 0 
    
		if VALTYPE(oItens) == "O"
			AADD(aitens,oItens)
		Else
			aitens := oItens
		End if
    	
 
    	For y:=1 to len(aitens)
    
    		 If AttIsMemberOf(aitens[y],"_PROD") 
    		 	
    		 	nQtdVol += Val(aitens[y]:_PROD:_qCom:TEXT)
    		 	
    		 Else
    		 	 nQtdVol++
    		 End IF
    	Next
    
    End if
    

    If AttIsMemberOf(oTotalNF,"_vBC") 
        nBaseICM :=  Val(oTotalNF:_vBC:TEXT)
    End If 

    If AttIsMemberOf(oTotalNF,"_vICMS") 
        nValICM :=  Val(oTotalNF:_vICMS:TEXT)
    End If 
 
     If AttIsMemberOf(oTotalNF,"_vBCST") 
        nBaseST :=  Val(oTotalNF:_vBCST:TEXT)
    End If 
    
     If AttIsMemberOf(oTotalNF,"_vST") 
        nValST :=  Val(oTotalNF:_vST:TEXT)
    End If 
    
    // Chave de Nota Fiscal
    cNFEID  := oProtNFe:_infProt:_chNFe:TEXT
    
    // Busca informacao da Placa
	If Type("oTransp:_veicTransp:_placa:TEXT") <> "U"
	
		cPlacaVei:= POSICIONE("DA3",1,xFilial("DA3") + Alltrim(oTransp:_veicTransp:_placa:TEXT),"DA3_COD")
	Else
		cPlacaVei   := ""
	EndIf	        
	
	If Type("oTransp:_transporta:_CNPJ:TEXT") <> "U"
		cCNPJTRA	:= oTransp:_transporta:_CNPJ:TEXT
	End if
	
	// Verifica quem e o tomador do Frete
	If AttIsMemberOf(oTransp,"_modFrete") 
		If oTransp:_modFrete:TEXT == '0'
	
			cCGCDev := IIF(AttIsMemberOf(oRem,"_CNPJ"),oRem:_CNPJ:TEXT,oRem:_CPF:TEXT)
			cNomeDev:= oRem:_XNOME:TEXT
			cTipFre := '1'
		ElseIf oTransp:_modFrete:TEXT == '1'
		
			cCGCDev := IIF(AttIsMemberOf(oDes,"_CNPJ"),oDes:_CNPJ:TEXT,oDes:_CPF:TEXT)
			cNomeDev:= oDes:_XNOME:TEXT
			cTipFre := '2'		
		Else
			cCGCDev := IIF(AttIsMemberOf(oRem,"_CNPJ"),oRem:_CNPJ:TEXT,oRem:_CPF:TEXT)
			cNomeDev:= oRem:_XNOME:TEXT
			cTipFre := '1'
		End if
	End if
	
	
	If oInfAdic <> Nil
	    // Busca o valor do Frete conforme a Tag
		If AttIsMemberOf(oInfAdic,"_infCpl") 
		
			cTexto := oInfAdic:_infCpl:TEXT
			
			nPosFrt	:= At( cIdenf, oInfAdic:_infCpl:TEXT,nPosFrt)
			
			// Verifica se existe o valor do frete
			If  nPosFrt > 0
				// Recupera o valor do Frete
				nValFrt := Val(StrTran(StrTran(SubStr( cTexto, nPosFrt + nLenID, AT("-.",cTexto,nPosFrt + nLenID) - (nPosFrt + nLenID)),".",""),",","."))
			End if					
		End If
    End iF
    
    // Caso nao encontre, busca o frete da nota fiscal.
	If nValFrt == 0 
		If AttIsMemberOf(oTotalNF,"_vFrete")
			nValFrt   := Val(oTotalNF:_vFrete:TEXT)
		Else
			nValFrt   := 0
		EndIf		
	End IF	
      
    If lValid
		cTipFre := SUBSTR(cTipFre,1,TamSx3("ZE_TIPFRE")[1])
		lValid := oModelSZE:SetValue('ZE_TIPFRE', cTipFre)
	End If 
 
     If lValid
     	iF cTipFre == "1"
     		cDevFre := "1"
		Else
			cDevFre := "2"
		End iF
		
		cDevFre := SUBSTR(cDevFre,1,TamSx3("ZE_DEVFRE")[1])
		lValid := oModelSZE:SetValue('ZE_DEVFRE', cDevFre)
	End If 
      
    If lValid
		cNomeDev := SUBSTR(cNomeDev,1,TamSx3("ZE_NOMDEV")[1])
		lValid := oModelSZE:SetValue('ZE_NOMDEV', cNomeDev)
	End If 

    If lValid
		cCGCDev := SUBSTR(cCGCDev,1,TamSx3("ZE_CGCDEV")[1])
		lValid := oModelSZE:SetValue('ZE_CGCDEV', cCGCDev)
	End If 

    If lValid
		lValid := oModelSZE:SetValue('ZE_CGCTRAN', cCNPJTRA)
	End If      
       
   	If lValid
		lValid := oModelSZE:SetValue('ZE_DOC', cNota)
	End If     

   	If lValid
		lValid := oModelSZE:SetValue('ZE_SERIE', cSerie)
	End If         
       
   	If lValid
		lValid := oModelSZE:SetValue('ZE_EMINFC', dData)
	End If   
	
   	If lValid
		lValid := oModelSZE:SetValue('ZE_VALOR  ', nValNF)
	End If  

   	If lValid
		lValid := oModelSZE:SetValue('ZE_QTDVOL', nQtdVol)
	End If  

   	If lValid
		lValid := oModelSZE:SetValue('ZE_PESO', nPesoB)
	End If 		
	
	If lValid
		lValid := oModelSZE:SetValue('ZE_PESLIQ', nPesoL)
	End If 		

	If lValid
		lValid := oModelSZE:SetValue('ZE_BASEIC ', nBaseICM)
	End If 
	
	If lValid
		lValid := oModelSZE:SetValue('ZE_VALICM ', nValICM)
	End If 

	If lValid
		lValid := oModelSZE:SetValue('ZE_VALIST', nBaseST)
	End If 

	If lValid
		lValid := oModelSZE:SetValue('ZE_BASIST', nValST)
	End If 

	If lValid
		lValid := oModelSZE:SetValue('ZE_VALFRET',nValFrt)
	End If 
	
	If lValid
		lValid := oModelSZE:SetValue('ZE_NFEID', cNFEID)
	End If 

	If lValid
		lValid := oModelSZE:SetValue('ZE_PLACA', cPlacaVei)
	End If 	
	
	If lValid
		If SZE->(FieldPos("ZE_INFNFE")) > 0
			lValid  := oModelSZE:SetValue('ZE_INFNFE',cTexto)
		End If
	End If	
	      
Return lValid

/*/{Protheus.doc} REMDEST
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 05/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param oDados, object, description
@param cTipo, characters, description
@type function
/*/
Static Function REMDEST(oModel,oDados,cTipo)
		
	Local lValid := .t.
	Local cCNPJ	 := ""
	Local cRazao := ""
	Local cFantasia := ""
	Local cIE := ""
	Local cIM := ""
	Local cEndereco := ""
	Local cBairro := ""
	Local cCodMun := ""
	Local cMuncipio :=""
	Local cUF := ""
	Local cCEP := ""
	Local cCodTel := ""
	Local cEmail := ""
	Local oModelSZE := oModel:GetModel("SZEMASTER")
	
	//ctipo - 1 Remetente, 2 Destinatario
			
	If AttIsMemberOf(oDados,"_CNPJ") 
        cCNPJ :=  Upper(AllTrim(oDados:_CNPJ:Text))
    ElseIf AttIsMemberOf(oDados,"_CPF")
    	cCNPJ :=  Upper(AllTrim(oDados:_CPF:Text))
    End If

    If AttIsMemberOf(oDados,"_IE") 
        cIE   :=  Upper(AllTrim(oDados:_IE:Text))
    End If

    If AttIsMemberOf(oDados,"_IM") 
        cIM   :=  Upper(AllTrim(oDados:_IM:Text))
    End If
    
    If AttIsMemberOf(oDados,"_EMAIL") 
        cEmail  :=  Upper(AllTrim(oDados:_EMAIL:Text))
    End If 
    
    If AttIsMemberOf(oDados,"_XNOME") 
        cRazao  :=  Upper(AllTrim(oDados:_XNOME:Text))
    End If

    If AttIsMemberOf(oDados,"_XFANT") 
        cFantasia  :=  Upper(AllTrim(oDados:_XFANT:Text))
    Else
        cFantasia := cRazao
    End If
    
    // Remetente
    If cTipo == "1"
    	If AttIsMemberOf(oDados,"_ENDEREMIT") 
    		oEndre:= oDados:_ENDEREMIT
    	End If
    // Destinarario
    Else
    	If AttIsMemberOf(oDados,"_ENDERDEST") 
    		oEndre:= oDados:_ENDERDEST
    	End if
    End IF
    
    
    If AttIsMemberOf(oEndre,"_CEP") 
        cCEP  :=  Upper(AllTrim(oEndre:_CEP:Text))
    End If
    
  	If AttIsMemberOf(oEndre,"_XMUN") 
        cMuncipio  :=  Upper(AllTrim(oEndre:_XMUN:Text))
    End If

	If AttIsMemberOf(oEndre,"_XBAIRRO") 
        cBairro  :=  Upper(AllTrim(oEndre:_XBAIRRO:Text))
    End If

	If AttIsMemberOf(oEndre,"_UF") 
        cUF  :=  Upper(AllTrim(oEndre:_UF:Text))
    End If

	If AttIsMemberOf(oEndre,"_NRO") 
        cNumero  :=  Upper(AllTrim(oEndre:_NRO:Text))
    End If
    
    If AttIsMemberOf(oEndre,"_XLGR") 
        cEndereco  :=  Upper(AllTrim(oEndre:_XLGR:Text)) + "," + cNumero
    End If
	
	If AttIsMemberOf(oEndre,"_FONE") 
        cCodTel  :=  Upper(AllTrim(oEndre:_FONE:Text))
    End If
	
	If AttIsMemberOf(oEndre,"_CPAIS") 
        cCodPais  :=  Upper(AllTrim(oEndre:_CPAIS:Text))
    End If
    
	If AttIsMemberOf(oEndre,"_CMUN") 
        cCodMun  :=  Upper(AllTrim(oEndre:_CMUN:Text))
    End If  
        

	If lValid
		if cTipo == '1'
			cCNPJ := SUBSTR(cCNPJ,1,TamSx3("ZE_CGCREM")[1])
			lValid := oModelSZE:SetValue('ZE_CGCREM', cCNPJ)
		ElseIf cTipo == '2'
			cCNPJ := SUBSTR(cCNPJ,1,TamSx3("ZE_CGCDES")[1])
			lValid := oModelSZE:SetValue('ZE_CGCDES', cCNPJ)
		End If
	End If 
	
	If lValid
		if cTipo == '1'
			cRazao := SUBSTR(cRazao,1,TamSx3("ZE_NOMREM")[1])
			lValid := oModelSZE:SetValue('ZE_NOMREM', cRazao)
		ElseIf cTipo == '2'
			cRazao := SUBSTR(cRazao,1,TamSx3("ZE_NOMDES")[1])
			lValid := oModelSZE:SetValue('ZE_NOMDES', cRazao)
		End If
	End If 
    
	If lValid
		if cTipo == '1'
			cFantasia := SUBSTR(cFantasia,1,TamSx3("ZE_FANREM")[1])
			lValid := oModelSZE:SetValue('ZE_FANREM', cFantasia)
		ElseIf cTipo == '2'
			cFantasia := SUBSTR(cFantasia,1,TamSx3("ZE_FANDES")[1])
			lValid := oModelSZE:SetValue('ZE_FANDES', cFantasia)
		End If
	End If 

	If lValid
		if cTipo == '1'
			cIE := SUBSTR(cIE,1,TamSx3("ZE_IEREM")[1])
			lValid := oModelSZE:SetValue('ZE_IEREM', cIE)
		ElseIf cTipo == '2'
			cIE := SUBSTR(cIE,1,TamSx3("ZE_IEDES")[1])
			lValid := oModelSZE:SetValue('ZE_IEDES', cIE)
		End If	
	End If 

	If lValid
		if cTipo == '1'
			cIM := SUBSTR(cIM,1,TamSx3("ZE_IMREM")[1])
			lValid := oModelSZE:SetValue('ZE_IMREM', cIM)
		ElseIf cTipo == '2'
			cIM := SUBSTR(cIM,1,TamSx3("ZE_IMDES")[1])
			lValid := oModelSZE:SetValue('ZE_IMDES', cIM)
		End If	
	End If 

	If lValid
		if cTipo == '1'
			cEndereco := SUBSTR(cEndereco,1,TamSx3("ZE_ENDREM")[1])
			lValid := oModelSZE:SetValue('ZE_ENDREM', cEndereco)
		ElseIf cTipo == '2'
			cEndereco := SUBSTR(cEndereco,1,TamSx3("ZE_ENDDES")[1])
			lValid := oModelSZE:SetValue('ZE_ENDDES', cEndereco)
		End If	
	End If 

	If lValid
		if cTipo == '1'
			cBairro := SUBSTR(cBairro,1,TamSx3("ZE_BAIREM")[1])
			lValid := oModelSZE:SetValue('ZE_BAIREM', cBairro)
		ElseIf cTipo == '2'
			cBairro := SUBSTR(cBairro,1,TamSx3("ZE_BAIDES")[1])
			lValid := oModelSZE:SetValue('ZE_BAIDES', cBairro)
		End If	
	End If 
			
	If lValid
		if cTipo == '1'
			cCodMun := SUBSTR(cCodMun,1,TamSx3("ZE_CMUREM")[1])
			lValid := oModelSZE:SetValue('ZE_CMUREM', cCodMun)
		ElseIf cTipo == '2'
			cCodMun := SUBSTR(cCodMun,1,TamSx3("ZE_CMUDES")[1])
			lValid := oModelSZE:SetValue('ZE_CMUDES', cCodMun)
		End If	
	End If 
	
	If lValid
		if cTipo == '1'
			cMuncipio := SUBSTR(cMuncipio,1,TamSx3("ZE_MUNREM")[1])
			lValid := oModelSZE:SetValue('ZE_MUNREM', cMuncipio)
		ElseIf cTipo == '2'
			cMuncipio := SUBSTR(cMuncipio,1,TamSx3("ZE_MUNDES")[1])
			lValid := oModelSZE:SetValue('ZE_MUNDES', cMuncipio)
		End If	
	End If 
		
	If lValid
		if cTipo == '1'
			cUF := SUBSTR(cUF,1,TamSx3("ZE_UFREM")[1])
			lValid := oModelSZE:SetValue('ZE_UFREM', cUF)
		ElseIf cTipo == '2'
			cUF := SUBSTR(cUF,1,TamSx3("ZE_UFDES")[1])
			lValid := oModelSZE:SetValue('ZE_UFDES', cUF)
		End If	
	End If 	

	If lValid
		if cTipo == '1'
			cCEP := SUBSTR(cCEP,1,TamSx3("ZE_CEPREM")[1])
			lValid := oModelSZE:SetValue('ZE_CEPREM', cCEP)
		ElseIf cTipo == '2'
			cCEP := SUBSTR(cCEP,1,TamSx3("ZE_CEPDES")[1])
			lValid := oModelSZE:SetValue('ZE_CEPDES', cCEP)
		End If	
	End If 	

	If lValid
		if cTipo == '1'
			cCodTel := SUBSTR(cCodTel,1,TamSx3("ZE_FONREM")[1])
			lValid := oModelSZE:SetValue('ZE_FONREM', cCodTel)
		ElseIf cTipo == '2'
			cCodTel := SUBSTR(cCodTel,1,TamSx3("ZE_FONDES")[1])
			lValid := oModelSZE:SetValue('ZE_FONDES', cCodTel)
		End If	
	End If 	

	If lValid
		if cTipo == '1'
			cEmail := SUBSTR(cEmail,1,TamSx3("ZE_EMAREM")[1])
			lValid := oModelSZE:SetValue('ZE_EMAREM', cEmail)
		ElseIf cTipo == '2'
			cEmail := SUBSTR(cEmail,1,TamSx3("ZE_EMADES")[1])
			lValid := oModelSZE:SetValue('ZE_EMADES', cEmail)
		End If	
	End If 	
	
Return lValid

