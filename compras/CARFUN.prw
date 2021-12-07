#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFUN   º Autor ³ TIAGO ROSSINI         º Data ³  05/05/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ FUNCOES AUXILIARES                     										º±±
±±ºParametros³                                                    				º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PROTHEUS 11'                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// Retorna nome da filial 
// Consulta de estoque na venda
User Function RetFil(cParam)
Local aArea := GetArea()
Local cNomFil
	
	dbSelectArea("SB2")
	dbSelectArea("SM0")
	dbGotop()
	DbSeek(cEmpAnt+cParam)
	cNomFil := SM0->M0_FILIAL	
	
	RestArea(aArea)
	
Return(cNomFil)		


// Retorna preco de venda1
// Consulta de estoque na venda
User Function RetPrv1(cProd)
Local aArea := GetArea()
Local nPrv1
		
	nPrv1 := Posicione('SB0', 1, xFilial('SB0')+cProd, 'B0_PRV1')
	
	RestArea(aArea)
	
Return(nPrv1)


// Retorna descricao do Cliente/Fornecedor NFS
User Function CARU01(cTipo, cCodigo, cLoja)
Local aArea := GetArea()
Local cNome
		
	If cTipo $ "D/B"
		cNome := Posicione('SA2', 1, xFilial('SA2')+cCodigo+cLoja, 'A2_NOME')
	Else
		cNome := Posicione('SA1', 1, xFilial('SA1')+cCodigo+cLoja, 'A1_NOME')
	EndIf
	
	RestArea(aArea)
	
Return(cNome)


// Retorna descricao do Fornecedor/Cliente NFE
User Function CARU02(cTipo, cCodigo, cLoja)
Local aArea := GetArea()
Local cNome
		
	If cTipo $ "D/B"
		cNome := Posicione('SA1', 1, xFilial('SA1')+cCodigo+cLoja, 'A1_NOME')
	Else
		cNome := Posicione('SA2', 1, xFilial('SA2')+cCodigo+cLoja, 'A2_NOME')
	EndIf
	
	RestArea(aArea)
	
Return(cNome)

