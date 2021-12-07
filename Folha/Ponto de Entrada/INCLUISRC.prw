#include 'protheus.ch'
#include 'parmtype.ch'

user function INCLUISRC()

Local aCabec    := {}
Local aItens    := {}
Local aItensFinal := {} //agrupador de itens
 
PRIVATE lMsErroAuto := .F.
aCabec   := {}
//    aadd(aCabec,{"RC_FILIAL"  ,xFilial("SRC")  ,Nil  })
//    aadd(aCabec,{"RC_MAT"     ,"900000" ,Nil  })
    
    
    AADD(aCabec, {{"RC_FILIAL", xFilial("SRC")     , Nil},{"RC_MAT","900000", Nil} } )
	
aItens := {}
    aadd(aItens,{{"RC_FILIAL" , xFILIAL("SRC")            , Nil },;
				{"RC_MAT"     , "900000"            , Nil },;
				{"RC_PD"      , "420"              , Nil },;
				{"RC_TIPO1"   , "V"   , Nil },;
				{"RC_HORAS"   , 100.00              , Nil },;
				{"RC_VALOR"   , 3252.27            , Nil },;
				{"RC_DATA"    , Ctod("31/12/13")  , Nil },;
				{"RC_CC"      , "02006001"         , Nil },;
				{"RC_PARCELA" , "01"               , Nil }})
 
 
MsExecAuto({|w,x,y,z| GPEA090(w,x,y,z)} ,3 ,aCabec, aItens,3 ) // 4 - Inclusão, 4 - Alteração, 5 - Exclusão
If lMsErroAuto     
    MostraErro()
Else     
    Alert("Registro(s) Alterado(s) !!!")      
EndIf
Return()
 