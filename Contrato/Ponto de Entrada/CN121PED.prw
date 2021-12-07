#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} CN121PED
Alteracao do Pedido de Venda/Compra.
Utilizado para aglutinar o pedido de venda em apenas
em um item e com uma descricao personalizada.
@author Totvs Vitoria - Mauricio Silva
@since 13/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CN121PED()

	Local aCab 			:= PARAMIXB[1]
	Local aItem 		:= PARAMIXB[2]
	Local nPosPRUNIT	:= 0
	Local nPosDESCRI	:= 0
	Local nPosPRCVEN	:= 0
	Local nPosQTDVEN	:= 0
	Local nTotal		:= 0
	Local 
	Local aNewItem		:= {}
	
	aEval(aItem,{|x| nPosPRUNIT := aScan(x,{|x| AllTrim(x[1]) == "C6_PRUNIT"  })})
	
	// Verifica se aglutina os produtos no PEDIDO DE VENDA.
	If CND->CND_YAGLUT == "S" .and. nPosPRUNIT > 0 

		// Busca as posicoes dos campos
		aEval(aItem,{|x| nPosPRUNIT := aScan(x,{|x| AllTrim(x[1]) == "C6_PRUNIT"  })})
		aEval(aItem,{|x| nPosDESCRI := aScan(x,{|x| AllTrim(x[1]) == "C6_DESCRI"  })})
		aEval(aItem,{|x| nPosPRCVEN := aScan(x,{|x| AllTrim(x[1]) == "C6_PRCVEN"  })})
		aEval(aItem,{|x| nPosQTDVEN := aScan(x,{|x| AllTrim(x[1]) == "C6_QTDVEN"  })})
		
		//Validações do usuario
		If Len(aItem) > 0
			aNewItem := aClone(aItem[1])
			aNewItem[nPosQTDVEN][2] := 1
			
			// Verifica se existe o campo
			If CND->(FieldPos("CND_YDESPR")) > 0 
				
				// Verifica se o usuario informou uma descricao
				IF !empty(CND_YDESPR)
					aNewItem[nPosDESCRI][2] := SubStr(Alltrim(CND->CND_YDESPR),1, TamSX3("C6_DESCRI")[1])
				End if
			End If
		End if
		
		// Zera o valor anterior, visto  pq copia.
		aNewItem[nPosPRUNIT][2] := 0
		
		For i:= 1 to Len(aItem)		
			// Soma o valor unitario com o total de medicao do contrato.	
			aNewItem[nPosPRUNIT][2] += aItem[i][nPosPRUNIT][2] * aItem[i][nPosQTDVEN][2]
			aNewItem[nPosPRCVEN][2] := aNewItem[nPosPRUNIT][2]
		Next
	
		aItem := {aClone(aNewItem)}
	End if
	
Return {aCab,aItem}