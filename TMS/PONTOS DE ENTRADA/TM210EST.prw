#include 'protheus.ch'
#include 'parmtype.ch'

user function TM210EST()

	Local lChek := .t.
	
	/*���Parametros� ExpC1 = Filial de Origem                                   ���
	���          � ExpC2 = Codigo da viagem                                   ���
	���          � ExpL1 = .T. Verifica se a viagem esta em aberto            ���
	���          � ExpL2 = .T. Verifica se ha manifesto                       ���
	���          � ExpL3 = .T. Verifica se ha contrato de carreteiro          ���
	���          � ExpL4 = .T. Emite help se houver restricoes                ���
	���          � ExpL5 = .T. Travar o registro da viagem                    ���
	���          � ExpL6 = .T. Verifica se ha complemento de viagem           ���
	���          � ExpL7 = .T. Verifica se a viagem esta em transito          ���
	���          � ExpL8 = .T. Verifica se viagem vazia                       ���
	���          � ExpL9 = .T. Verifica se a viagem esta bloqueada            ���
	���          � ExpA1 = .T. Vetor contendo as mensagens do Help            ���
	���          � ExpL10= .T. Chegada Parcial ?                              ���
	���          � ExpL11= .T. Verifica Viagem Encerrada ?                    ���
	���          � ExpL12= .T. Verifica Viagem Fechada                        ���
	���          � ExpL13= .T. Verifica se ha operacoes encerradas            ���
	���          � ExpL14= .T. Verifica se a viagem esta cancelada            ���
	���          � ExpL15= .T. Verifica se a viagem � planejada.              ���
	���          � ExpL16= .T. Verifica se ha operacoes encerradas            ���
	���          � ExpL17= .T. Verifica se a viagem esta cancelada            ���
	���          � ExpL18= .T. Verifica se a viagem e planejada.              ���
	���          � ExpC19= Filial Atual                                       ���
	���          � ExpC20= .T. Gerar complemento de viagem vazio    */

	// Verifica se existe contrato de carreteiro
	If !TMSChkViag( DTA->DTA_FILORI, DTA->DTA_VIAGEM,.T.,.F.,.T.,,.F.,.F.,,.T.,,,.F.,.T. )
		Return .f.
	End If
	
return lChek