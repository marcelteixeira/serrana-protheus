#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Ap5Mail.ch'


User Function SERFRW01(cPara,cAssunto,cMensagem,aArquivos)
	Local cMsg := ""
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.T.)
	Local nPorta := 587 //informa a porta que o servidor SMTP ir� se comunicar, podendo ser 25 ou 587

	//A porta 25, por ser utilizada h� mais tempo, possui uma vulnerabilidade maior a 
	//ataques e intercepta��o de mensagens, al�m de n�o exigir autentica��o para envio 
	//das mensagens, ao contr�rio da 587 que oferece esta seguran�a a mais.
			
	Private cMailConta	:= NIL
	Private cMailServer	:= Nil //"SEUIP" //Provis�rio, pois no parametro j� existe a porta
	Private cMailSenha	:= NIL
	
	Default aArquivos := {}

	cMailConta := If(cMailConta == NIL,GETMV("MV_RELACNT"),cMailConta)             //Conta utilizada para envio do email
	cMailServer:= If(cMailServer == NIL,GETMV("MV_RELSERV"),cMailServer)           //Servidor SMTP
	cMailSenha := If(cMailSenha == NIL,GETMV("MV_RELPSW"),cMailSenha)             //Senha da conta de e-mail utilizada para envio
   	oMessage:= TMailMessage():New()
	oMessage:Clear()
   
	oMessage:cDate	 := cValToChar( Date() )
	oMessage:cFrom 	 := cMailConta
	oMessage:cTo 	 := cPara
	oMessage:cSubject:= cAssunto
	oMessage:cBody 	 := cMensagem
	
	If Len(aArquivos) > 0
		For nArq := 1 To Len(aArquivos)
			xRet := oMessage:AttachFile( aArquivos[nArq] )
			if xRet < 0
				cMsg := "O arquivo " + aArquivos[nArq] + " n�o foi anexado!"
				ConOut( cMsg )
				return
			endif
		Next nArq
	EndIf		
	   
	oServer := tMailManager():New()
	oServer:SetUseTLS( .F. ) //Indica se ser� utilizar� a comunica��o segura atrav�s de SSL/TLS (.T.) ou n�o (.F.)
   
	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		ConOut("O servidor SMTP n�o foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif
   
	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		ConOut("N�o foi poss�vel definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	endif
   
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		ConOut("N�o foi poss�vel conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif
   
	if lMailAuth
		//O m�todo SMTPAuth ao tentar realizar a autentica��o do 
		//usu�rio no servidor de e-mail, verifica a configura��o 
		//da chave AuthSmtp, na se��o [Mail], no arquivo de 
		//configura��o (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			ConOut( cMsg )
			oServer:SMTPDisconnect()
			return
		endif
   	Endif
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		ConOut("N�o foi poss�vel enviar mensagem: " + oServer:GetErrorString( xRet ))
	endif
   
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		ConOut("N�o foi poss�vel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	endif
return