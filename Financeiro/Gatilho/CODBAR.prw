#include "rwmake.ch"

/*      
PROGRAMA  : CODBAR
DATA      : 17/09/19
DESCRIÇÃO : Converte a linha digitavel em codigo de barras, para os CNAB's a Pagar.
UTILIZAÇÃO: Gatilho no campo E2_LINDIG, retorno para o campo E2_CODBAR.
*/

User Function CODBAR()

SetPrvt("_CRETORNO,")

_cRetorno := M->E2_LINDIG

IF LEN(ALLTRIM(M->E2_LINDIG))== 47
   _cRetorno := Substr(M->E2_LINDIG,1,4) + ;                 // BANCO + MOEDA
   Substr(M->E2_LINDIG,33,1) + ;                             // DV GERAL
   Substr(M->E2_LINDIG,34,4) + ;                             // FATOR VENCIMENTO
   StrZero(Val(Alltrim(Substr(M->E2_LINDIG,38,10))),10) + ;  // VALOR
   Substr(M->E2_LINDIG,5,5) + ;                              // CAMPO LIVRE
   Substr(M->E2_LINDIG,11,10) + ;
   Substr(M->E2_LINDIG,22,10)
ELSEIF LEN(ALLTRIM(M->E2_LINDIG)) <> 47 .AND. LEN(ALLTRIM(M->E2_LINDIG)) <> 44
    // Concessionarias e tributos
   _cRetorno := Substr(M->E2_LINDIG,1,11) + Substr(M->E2_LINDIG,13,11) + Substr(M->E2_LINDIG,25,11) + Substr(M->E2_LINDIG,37,11)
ENDIF

Return(_cRetorno)