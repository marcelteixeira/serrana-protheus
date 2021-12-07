#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} GPE10MENU
Adicionar rotinas no MENU
@author Totvs Vitoria - Mauricio Silva
@since 13/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

user function GPE10MENU()

	Local cRotina := Funname()
	Local aCapital:= {}
		
	
	
	If cRotina == "GPEA265"
	
		aAdd(aCapital, { "Capital Cooperado" ,"U_SERGPE02(SRA->RA_YFORN)"		, 0, 4, 0, Nil })
		aAdd(aCapital, { "Gerar Capital Sub.","StaticCall(SERGPE02,GeraCapSub,SRA->RA_YFORN)", 0, 4, 0, Nil })
		aAdd(aCapital, { "Desfiliar"		 ,"StaticCall(SERGPE02,Desfiliar,SRA->RA_YFORN) ", 0, 4, 0, Nil })
		aAdd(aCapital, { "Estorno Desfiliar" ,"StaticCall(SERGPE02,EstDesf,SRA->RA_MAT) ", 0, 4, 0, Nil })
		aAdd(aCapital, { "Cadastro CMV"		 ,"U_SERGPE01(SRA->RA_YFORN) "		, 0, 4, 0, Nil })
		aAdd(aCapital, { "Contr. Doc."		 ,"U_ASERGPE10() "					, 0, 4, 0, Nil })
		
		aAdd(aRotina,  { "Cooperado" 		 , aCapital							, 0, 4, 0, Nil })
	
	End If 

return


User Function ASERGPE10()

	Local cFiltro := " ZA_CODIGO = '" + SRA->RA_MAT +"' .AND. ZA_ENTIDAD = '1'"

	U_SERGPE10(cFiltro)

Return
