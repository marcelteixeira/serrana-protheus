/*/{Protheus.doc} PN80GRBH
PE para gravar somente o saldo do banco de horas na tabela SPB (resultados).
@SELITA
@author Fabrício Vettler - TOTVS ES
@since 13/02/2019
@version P12
/*/

#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function PN80GRBH()

Local aSaveArea  := GetArea()
Local cEveProv   := Paramixb[1]//Evento de Provento do Banco de Horas
Local cEveDesc   := Paramixb[2]//Evento de Desconto do Banco de Horas
Local aSPI       := Paramixb[3]//Array com os Valores do Banco de Horas
Local aDelSPI    := Paramixb[4]//Array com os Registros a serem Baixados
Local dDataGrv   := Paramixb[5]//Data Para a Gravacao dos Valores nos Resultados
Local cEveResc   := Paramixb[6]//Evento de Base para total de meses do B.Horas
Local nRES       := 0
Local cVerba 	 := ""
Local cEvento	 := ""
Private cEOL     := Chr(13)+Chr(10)

//Grava apenas o RESULTADO
cSql := " select "  + cEol
cSql += "		(SELECT ISNULL(Sum(PB_HORAS), 0) PB_HORAS"  + cEol
cSql += "          FROM "+RetSQLName("SPB")+" SPB"  + cEol
cSql += "         WHERE PB_FILIAL = '"+SRA->RA_FILIAL+"' "  + cEol
cSql += " 	        AND PB_MAT = '"+SRA->RA_MAT+"' "  + cEol
cSql += "    	    AND PB_PD = "+cEveProv+" "  + cEol
cSql += "       	AND D_E_L_E_T_ = ' ') crd, "  + cEol
cSql += "       (SELECT ISNULL(Sum(PB_HORAS), 0) PB_HORAS"  + cEol
cSql += "          FROM "+RetSQLName("SPB")+" SPB"  + cEol
cSql += "         WHERE PB_FILIAL = '"+SRA->RA_FILIAL+"'"  + cEol
cSql += "        	AND PB_MAT = '"+SRA->RA_MAT+"'"  + cEol
cSql += "        	AND PB_PD = "+cEveDesc+" "  + cEol
cSql += "           AND D_E_L_E_T_ = ' ') dois,"  + cEol
cSql += "   "  + cEol
cSql += "       (SELECT ISNULL(Sum(PB_HORAS), 0) PB_HORAS "  + cEol
cSql += "          FROM "+RetSQLName("SPB")+" SPB"  + cEol
cSql += "		  WHERE PB_FILIAL = '"+SRA->RA_FILIAL+"' "  + cEol
cSql += "			AND PB_MAT = '"+SRA->RA_MAT+"' "  + cEol
cSql += "			AND PB_PD = "+cEveProv+" "  + cEol
cSql += "			AND D_E_L_E_T_ = ' ')-(SELECT ISNULL(Sum(PB_HORAS), 0) PB_HORAS"  + cEol
cSql += "			                         FROM "+RetSQLName("SPB")+" SPB"  + cEol
cSql += "				                    WHERE PB_FILIAL = '"+SRA->RA_FILIAL+"' "  + cEol
cSql += "				                      AND PB_MAT = '"+SRA->RA_MAT+"' "  + cEol
cSql += "				                      AND PB_PD = "+cEveDesc+" "  + cEol
cSql += "				 	                  AND D_E_L_E_T_ = ' ') R "  + cEol

tcquery cSql new Alias "_R"
_R->(DBGOTOP())
nRes := _R->R
SPB->(DBSETORDER(1))

_R->(DbCloseArea())


if Alltrim(GetMV("MV_YBHNEGA")) = '1' //Mantém o saldo positivo ou negativo após fechamento B.H. para a rotina de Resultados.
	
	if nRES > 0
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveProv+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->PB_HORAS := nRes
			SBP->(msunlock())
		end
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveDesc+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->(dbdelete())
			SBP->(msunlock())
		end
	else
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveProv+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->(dbdelete())
			SBP->(msunlock())
		end
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveDesc+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->PB_HORAS := nRes * (-1)
			SBP->(msunlock())
		end
		
	end
	
elseif Alltrim(GetMV("MV_YBHNEGA")) = '2' //Mantém somente o positivo e deleta o saldo negativo após o fechamento do B.H. para a rotina resultados.
	
	if nRES > 0
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveProv+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->PB_HORAS := nRes
			SBP->(msunlock())
		end
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveDesc+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->(dbdelete())
			SBP->(msunlock())
		end
	else
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveProv+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->(dbdelete())
			SBP->(msunlock())
		end
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveDesc+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->(dbdelete())
			SBP->(msunlock())
		end
		
	end

elseif Alltrim(GetMV("MV_YBHNEGA")) = '3' //Se o saldo for negativo, retorna para o B.H. (tabela SPI)
	
	if nRES > 0
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveProv+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->PB_HORAS := nRes
			SBP->(msunlock())
		end
		IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveDesc+SRA->RA_CC)))
			SPB->(Reclock("SPB",.F.))
			SPB->(dbdelete())
			SBP->(msunlock())
		end
	else
		//			IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveProv+SRA->RA_CC)))
		//				SPB->(Reclock("SPB",.F.))
		//				SPB->(dbdelete())
		//				SBP->(msunlock())
		//			end
		//			IF (SPB->(DBSEEK(SRA->RA_FILIAL+SRA->RA_MAT+cEveDesc+SRA->RA_CC)))
		//				SPB->(Reclock("SPB",.F.))
		//				SPB->(dbdelete())
		//				SBP->(msunlock())
		//			end
		chkfile("SPI")
		dbSelectArea("SPI")
		
		RecLock("SPI",.T.)
		SPI->PI_FILIAL  	:= xFilial("SPI")
		SPI->PI_MAT			:= SRA->RA_MAT
		SPI->PI_DATA   		:= ddatabase
		SPI->PI_PD  		:= GetNewPar("MV_YPDBH","149")
		SPI->PI_CC			:= SRA->RA_CC
		SPI->PI_QUANT		:= ABS(nRES)
		SPI->PI_QUANTV		:= ABS(nRES)
		SPI->PI_FLAG  		:= "I"
		
		
		SPI->( msUnLock() )
		
	end
	
end

RestArea(aSaveArea)

Return
