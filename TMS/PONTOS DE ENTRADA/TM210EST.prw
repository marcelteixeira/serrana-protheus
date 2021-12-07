#include 'protheus.ch'
#include 'parmtype.ch'

user function TM210EST()

	Local lChek := .t.
	
	/*±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
	±±³          ³ ExpC2 = Codigo da viagem                                   ³±±
	±±³          ³ ExpL1 = .T. Verifica se a viagem esta em aberto            ³±±
	±±³          ³ ExpL2 = .T. Verifica se ha manifesto                       ³±±
	±±³          ³ ExpL3 = .T. Verifica se ha contrato de carreteiro          ³±±
	±±³          ³ ExpL4 = .T. Emite help se houver restricoes                ³±±
	±±³          ³ ExpL5 = .T. Travar o registro da viagem                    ³±±
	±±³          ³ ExpL6 = .T. Verifica se ha complemento de viagem           ³±±
	±±³          ³ ExpL7 = .T. Verifica se a viagem esta em transito          ³±±
	±±³          ³ ExpL8 = .T. Verifica se viagem vazia                       ³±±
	±±³          ³ ExpL9 = .T. Verifica se a viagem esta bloqueada            ³±±
	±±³          ³ ExpA1 = .T. Vetor contendo as mensagens do Help            ³±±
	±±³          ³ ExpL10= .T. Chegada Parcial ?                              ³±±
	±±³          ³ ExpL11= .T. Verifica Viagem Encerrada ?                    ³±±
	±±³          ³ ExpL12= .T. Verifica Viagem Fechada                        ³±±
	±±³          ³ ExpL13= .T. Verifica se ha operacoes encerradas            ³±±
	±±³          ³ ExpL14= .T. Verifica se a viagem esta cancelada            ³±±
	±±³          ³ ExpL15= .T. Verifica se a viagem é planejada.              ³±±
	±±³          ³ ExpL16= .T. Verifica se ha operacoes encerradas            ³±±
	±±³          ³ ExpL17= .T. Verifica se a viagem esta cancelada            ³±±
	±±³          ³ ExpL18= .T. Verifica se a viagem e planejada.              ³±±
	±±³          ³ ExpC19= Filial Atual                                       ³±±
	±±³          ³ ExpC20= .T. Gerar complemento de viagem vazio    */

	// Verifica se existe contrato de carreteiro
	If !TMSChkViag( DTA->DTA_FILORI, DTA->DTA_VIAGEM,.T.,.F.,.T.,,.F.,.F.,,.T.,,,.F.,.T. )
		Return .f.
	End If
	
return lChek