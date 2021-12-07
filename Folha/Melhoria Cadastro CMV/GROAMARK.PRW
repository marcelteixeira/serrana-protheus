#Include "FWMVCDef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} GROAMARK
Descrição: Substitui método padrão para respeitar o filtro
@author Kenny Roger Martins
/*/
//-------------------------------------------------------------------
User Function GROAMARK(oBrwsTmp, cTabela, cCampo)

    Local cMarca  := oBrwsTmp:Mark()
    Local aArea   := GetArea()
    Local aCampos := FWSX3Util():GetAllFields(cTabela)
    Local i	
    
	ProcRegua(0)	
	IncProc(1)
	IncProc(1)
	
	npos := ascan(aCampos,{|x| "_FILIAL" $ alltrim(x)})

    U_GROAFILT(oBrwsTmp, cTabela)

    &(cTabela + "->(DbGoTop())")
    
    While &(cTabela + "->(!Eof())")
    	if npos > 0 .AND. &(cTabela + "->" + aCampos[npos]) != xfilial(cTabela)
    		&(cTabela + "->(DbSkip())")
    		loop 
    	EndIf
        RecLock(cTabela, .F.)
        &(cTabela + "->" + cCampo) := if(&(cTabela + "->" + cCampo) == cMarca, "", cMarca)
        &(cTabela + "->(MsUnLock())")
        &(cTabela + "->(DbSkip())")
    EndDo

    SET FILTER TO
                    
    &(cTabela + "->(DbGoTop())")

    oBrwsTmp:oBrowse:Refresh()    
    oBrwsTmp:oBrowse:Refresh()    

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GROAFILT
Descrição: Substitui método padrão para respeitar o filtro
@author Kenny Roger Martins
/*/
//-------------------------------------------------------------------
User Function GROAFILT(oBrwsTmp, cTabela)
	Local i       := 0
	Local oFilter := oBrwsTmp:FWFilter()
	Local aFilter := oFilter:GetFilter(.F.)
	local cFilter := ""
    Local aStruct := &("(cTabela)->(DbStruct())") 
  
	For i := 1 To Len(aFilter)
		If i == 1
			cFilter +=  aFilter[i][2]
		Else
			cFilter += ' .And. ' + aFilter[i][2]
		EndIf
	Next

    For i := 1 To Len(aStruct) 
    	If (aStruct[i][1] $ cFilter .And. aStruct[i][2] == 'C')
   			cFilter :=	StrTran(cFilter, aStruct[i][1], 'AllTrim(' + aStruct[i][1] + ')')
   		EndIf
    Next

	If Empty(cFilter)
		(cTabela)->(DBClearFilter())
	Else
		(cTabela)->(DbSetFilter({|| &cFilter}, cFilter))
	EndIf

Return Nil

