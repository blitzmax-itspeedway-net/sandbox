
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

SuperStrict

Import bmx.json
Import bah.libcurl

Import "config.bmx"
Import "TRelease.bmx"
Import "TRepository.bmx"

Type TModserver

	Field UserAgent:String = "BlitzMaxNG"
	Field CertPath:String  = CONFIG.CERTPATH+DIRSLASH+CONFIG.CERTIFICATE	'"certificates/cacert.pem"
	Field repository:TRepository
	
	Method New( repository:TRepository )
		Self.repository = repository
	End Method
	
	Method downloadString:String( url:String )
		Local curl:TCurlEasy = TCurlEasy.Create()
		If curl<>Null
			curl.setWriteString()
			'curl.setOptInt( CURLOPT_VERBOSE, 1 )
			curl.setOptInt( CURLOPT_FOLLOWLOCATION, 1)
			curl.setOptString( CURLOPT_CAINFO, CertPath )
			curl.setOptString( CURLOPT_URL, url )
			curl.httpHeader( ["User-Agent: "+UserAgent, "Referer:"] )
		EndIf
		Local error:Int = curl.perform()
		If error; Throw CurlError( error )
		curl.cleanup()
		Return curl.toString()
	End Method
	
	Method downloadBinary( url:String, filename:String="" )
		If filename = ""; filename = repository.name
		filename = sanitise( filename )
	End Method 
	
	Method Jdownload:JSON( url:String )
		Return JSON.parse( downloadString( url ) )
	End Method
	
	Method getReleases:TList( filter:String = "" ) Abstract
	Method getLatest:TRelease() Abstract
	
	' Santise a filename
	'TODO: Need to improve this
	Function sanitise:String( filename:String )
		DebugStop
		Local sanitised:String
		Const VALID:String = " -_,.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
		For Local n:Int = 0 Until filename.length
			Local ch:String = filename[n..n+1]
			If Instr( VALID, ch ) > 0
				sanitised :+ ch
			Else
				sanitised :+ "_"
			End If
		Next
		Return sanitised
	End Function
	
End Type