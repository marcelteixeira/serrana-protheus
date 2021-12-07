 
 /*/{Protheus.doc} TMA144OFL
//TODO Ponto de entrada para alterar a posição do campo apresentado na tela de viagem
@author Pedro Luiz
@since 09/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TMA144OFL()
 
	 Local aRetFields  := PARAMIXB
	 Local aYesFields  := {}
	 Local aAuxCampos  := {}
	 Local nX    	   := 0
	 Local aStruct     := {}
	 Local nPos        := 0
	 Local aCampos     := {}
	 Local cCampos     := superGetMv("MV_YPOSC", .f., "DTA_YFRETE:23")
	 Local aAuxCamp    := {}
	 Local cTabela     := ""
	 Local nZ           := 0
	 
	 //Organizando os campos do parametro
	 aCampos := StrTokArr(cCampos,',/')
	 
	 For nZ := 1 to len(aCampos)
	 	Aadd(aAuxCamp,(StrTokArr(aCampos[nZ],':')))
	 next 
	 
	 aCampos := aAuxCamp
	 
	 For nX := 1 to Len(aCampos)
	 
	 	nPos	:= aScan(aRetFields, {|x| AllTrim(x) == aCampos[nX][1]})	
	 	
	 	if(nPos>0)
	 	
		 	ADEL(aRetFields, nPos) 
		 	
		 	AINS(aRetFields, val(aCampos[nX][2]))  
		 	
		 	aRetFields[val(aCampos[nX][2])] := aCampos[nX][1]
		 	
	 	EndIf
	 	
	 	
	 Next
	 
 Return aRetFields //aYesFields    
  
      

                                             
