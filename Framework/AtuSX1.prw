#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------------
/*/{Protheus.doc} AtuSX1
Atualização do SX1 - Perguntas

@author TOTVS Protheus
@since  19/04/2017
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function AtuSX1(aDados)
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

Default aDados := {}

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

RestArea( aAreaDic )
RestArea( aArea )

Return NIL
