
#include 'protheus.ch'
/*/{Protheus.doc} CRIASXE
Ponto de entrada para retornar o próximo número que deve ser utilizado na inicialização da numeração.
Este ponto de entrada é recomendado para casos em que deseja-se alterar a regra padrão de descoberta
do próximo número.
A execução deste ponto de entrada, ocorre em casos de perda das tabelas SXE/SXF ( versões legado ) e
de reinicialização do License Server.
@type function
@author TOTVS - FRANCISCO PASOLINI
@since 09/10/2019
@version P12
/*/

User Function CRIASXE()
Local cNum 			:= NIL
Local aArea 		:= getarea()
Local cAlias    	:= paramixb[1]
Local cCpoSx8   	:= paramixb[2]
Local cAliasSx8 	:= paramixb[3]
Local nOrdSX8   	:= paramixb[4]
Local cUsa 		:= "SA1/SA2"  // colocar os alias que irão permitir a execução do P.E.
Local cWhere		:= ""
Local cXX_SA1SXE	:= SuperGetMV("XX_SA1SXE",.f.,"'C03326','C04539','C04570','C08719','C08720','C08721'")
Local cXX_SA2SXE	:= SuperGetMV("XX_SA2SXE",.f.,"'004169','004221','004222','004223','004255'")

If cAlias $ cUsa .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) )
	qout(cAlias + "-" + cCpoSx8 + "-" + cAliasSx8 + "-" + str(nOrdSX8))

	If cAlias == "SA1"

		// Verifica area aberta
		If Select("TTRB") <> 0
			TTRB->(DBCLOSEAREA())
		EndIF

		cWhere += "% A1_COD NOT IN ( " + cXX_SA1SXE + " )%"

		TTRB := GetNextAlias()

		BeginSql Alias TTRB

		SELECT MAX(A1_COD) ULTNUM
		FROM %Table:SA1% SA1
		WHERE A1_FILIAL = %xFilial:SA1%
		  AND SA1.%NotDel%
		  AND A1_COD LIKE 'C0%'
		  AND %Exp:cWhere%

		EndSql

	ElseIf cAlias == "SA2"

		// Verifica area aberta
		If Select("TTRB") <> 0
			TTRB->(DBCLOSEAREA())
		EndIF

		cWhere += "% A2_COD NOT IN ( " + cXX_SA2SXE + " )%"

		TTRB := GetNextAlias()

		BeginSql Alias TTRB

		SELECT MAX(A2_COD) ULTNUM
		FROM %Table:SA2% SA2
		WHERE A2_FILIAL = %xFilial:SA2%
		  AND SA2.%NotDel%
		  AND A2_COD LIKE '0%'
		  AND %Exp:cWhere%
		  AND LEN(A2_COD)=6

		EndSql


	EndIf

	If  (TTRB)->(!EOF())
		cNum := Soma1(ULTNUM)
	EndIf

	If Select("TTRB") <> 0
		TTRB->(DBCLOSEAREA())
	EndIF

	restarea(aArea)
end

return cNum