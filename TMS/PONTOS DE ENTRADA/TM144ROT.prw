#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#Include "TMSA144.CH"
//-- Diretivas indicando as colunas dos documentos da viagem Do TMSA141
#Define CTSTATUS		1
#Define CTSTROTA		2
#Define CTMARCA			3
#Define CTSEQUEN		4
#Define CTARMAZE		5
#Define CTLOCALI		6
#Define CTFILDOC		7
#Define CTDOCTO			8 
#Define CTSERIE			9
#Define CTREGDES		10
#Define CTDATEMI		11
#Define CTPRZENT		12
#Define CTNOMREM		13
#Define CTNOMDES		14
#Define CTQTDVOL		15
#Define CTVOLORI		16
#Define CTPLIQUI		17
#Define CTPESOM3		18
#Define CTVALMER		19
#Define CTVIAGEM		20
#Define CTSEQDA7		21
#Define CTSOLICI		22			//-- DUE_NOME
#Define CTENDERE		23			//-- DUE_END
#Define CTBAIRRO		24			//-- DUE_BAIRRO
#Define CTMUNICI		25			//-- DUE_MUN
#Define CTDATSOL		26			//-- DT5_DATSOL
#Define CTHORSOL		27			//-- DT5_HORSOL
#Define CTDATPRV		28			//-- DT5_DATPRV
#Define CTHORPRV		29			//-- DT5_HORPRV
#Define CTDOCROT		30			//-- Codigo que identifica a q rota pertence o documento
#Define CTBLQDOC		31			//-- Tipos de bloqueio do documento
#Define CTNUMAGE		32			//-- Numero do Agendamento( Carga Fechada ).
#Define CTITEAGE		33			//-- Item do Agendamento( Carga Fechada ).
#Define CTSERTMS		34			//-- Tipo do Servico.
#Define CTDESSVT		35			//-- Descricao do Servico.
#Define CTESTADO		36
#Define CTDATENT		37
#Define CTUNITIZ		38			//-- Unitizador
#Define CTCODANA		39			//-- Codigo analitico do unitizador.
/*-- 
Defines abaixo precisam ser ajustados conforme TMSA141 
#Define CT40     		40			
#Define CT41     		41			
#Define CT42     		42			
#Define CT43     		43			
#Define CT44     		44			
#Define CT45       	45			
*/
//--- Estrutura da Integracao TMS x GFe - mesma do TMSA140 e TMSA141
#Define CTUFORI      46        //-- UF Origem (Integracao GFE)
#Define CTCDMUNO     47        //-- Cod.Municipio Origem (Integracao GFE)
#Define CTCEPORI     48        //-- Cep Origem (Integracao GFE)
#Define CTUFDES      49        //-- UF Destino (Integracao GFE)
#Define CTCDMUND     50        //-- Cod.Municipio Destino (Integracao GFE)
#Define CTCEPDES     51        //-- Cep Destino (Integracao GFE)
#Define CTTIPVEI     52        //-- Tipo Veiculo (Integracao GFE)
#Define CTCDCLFR     53        //-- Cod.Classificacao Frete (Integracao GFE)
#Define CTCDTPOP     54        //-- Tipo de Operação (Integracao GFE)

#Define CTORIGEM	 55			//-- Origem Carregamento.
//--Estrutura com o retorno das Informações do Roteiro
#Define ROTESTADO   01
#Define ROTFILDOC   02
#Define ROTDOC		03
#Define ROTSERIE    04
#Define ROTCLIREM   05
#Define ROTLOJREM   06
#Define ROTCLIDES   07
#Define ROTLOJDES   08
#Define ROTTIPOPE	09

Static lSelDoc
Static nPosFilD		:= 0
Static nPosDoc		:= 0
Static nPosSerie	:= 0
Static oNoMarked
Static oMarked
Static lTM144CPO	:= ExistBlock("TM144CPO")	//-- Permite modificar os campos a alterar na enchoice
Static lTM144GOk	:= ExistBlock("TM144GOk")	//-- Inibir a validação padrão do sistema para permitir a criação de novas viagens sem conhecimento emitido.
Static lTM144CDC	:= ExistBlock("TM144CDC")	//-- Permite ao usuario, incluir colunas nos documento.
Static lTM144EEX	:= ExistBlock("TM144EEX")	//-- Permite realizar acoes no momento Estorno da Viagem Express
Static lTM144EXC	:= ExistBlock("TM144EXC")	//-- Confirmnacao da Exclusao da Viagem
Static lTM144CEP	:= ExistBlock("TM144CEP")	//-- Confirmacao do Cep do Cliente
Static lTM144FOPE	:= ExistBlock("TM144FOPE")	//-- Operações de Transporte
Static lTM144LOK	:= ExistBlock("TM144LOK")	//-- Apos a validacao da linha de GetDados
Static lTM144ROK	:= ExistBlock("TM144ROK")	//-- validacao se documento pertence a rota
Static lTM144CLN	:= ExistBlock("TM144CLN")	//-- Permite ao usuario, incluir colunas nos itens.
Static lTM144LOT	:= ExistBlock("TM144Lot")
Static lTM144DOCR	:= ExistBlock('TM144DOCR') //-- Filtra Documentos de Redespacho. 
Static aRetTela	    := {}
Static lAltRom		:= .F.
Static lDigRot      := .F.
Static lTmsRdpU 	 := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho

/*/{Protheus.doc} TM144ROT
//TODO Descrição auto-gerada.
@author Totvs Vitoria - Mauricio Silva
@since 13/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function TM144ROT()

	Local aRotina := {}
	Local aSubRot := {}
	Local aSubCte := {}
	Local aSubMdf := {}
	
	//AAdd( aSubRot, { 'Monitor Integracao'   ,'U_SERTMS10'   ,0,3} )
	AAdd( aSubRot, { 'Ct-e Importados' 		,aSubCte   		,0,3} )
	AAdd( aSubRot, { 'Mdf-e Importados' 	,aSubMdf   		,0,3} )
	
	AAdd( aSubCte, { 'Conhecimentos' 		,'U_SERTMS06'   ,0,3} )
	AAdd( aSubCte, { 'Eventos' 				,'U_SERTMS07'   ,0,3} )
	
	AAdd( aSubMdf, { 'Manifestos' 			,'U_SERTMS08'   ,0,4} )
	AAdd( aSubMdf, { 'Eventos' 				,'U_SERTMS09'   ,0,4} )
	
	AAdd( aRotina, { 'Melhor Frete' 		,'u_TelaMFrt'   ,0,4} )
	AAdd( aRotina, { 'Import. XML ' 		,'u_ImpSZE' 	,0,3} )
	AAdd( aRotina, { 'Monta Viagem XML' 	,'u_SERTMS05' 	,0,3} )
	AAdd( aRotina, { 'XML Importados'		,'u_SERTMS04'  	,0,3} )
	AAdd( aRotina, { 'Averbação de Carga' 	,'TMSA296'    	,0,3} )
	AAdd( aRotina, { 'Estornar Viagem'  	,'StaticCall(TM144ROT,EstCarg)'    ,0,3} )
	//AAdd( aRotina, { 'MultiCte'  			,aSubRot   		,0,3} )
	//AAdd( aRotina, { 'Monitor MultiCte' 	,'U_SERTMS10'   ,0,3} )
	
Return aRotina

User Function TelaMFrt()
						
	FWExecView('Tela Melhor Frete','SERTMS03', MODEL_OPERATION_UPDATE, , { || .T. }, , , )							
Return

Static Function EstCarg()
	
	RecLock("DTQ",.f.)
		DTQ->DTQ_STATUS := "5"
	MsUnlock()
	
	TmsA144Exp(DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA)

Return

