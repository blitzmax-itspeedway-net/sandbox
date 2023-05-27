
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'SuperStrict



'Import "config.bmx"
'Import "TRelease.bmx"
'Import "TRepository.bmx"

Const MODSERVER_GITHUB:Int = $00
'Const MODSERVER_SOURCEFORGE:Int = $01
'Const MODSERVER_WEBSITE:Int = $02

Const MODSERVER_RELEASE:Int = $10
Const MODSERVER_ZIP:Int = $11

Type TModserver

	' Timer used to display download status
	Global timer:Int

	'Global list:TMap = New TMap()
	
	'Function register( name:String, modserver:TModserver )
	'	list.insert( name, modserver )
	'End Function
	
	'Function find:TModserver( name:String )
	'	Return TModserver( list.valueforkey( name ) )
	'End Function

	'Function remove( name:String )
	'	list.remove( name )
	'End Function
	

	'//

	Field UserAgent:String = "BlitzMaxNG"
	Field CertPath:String  = CONFIG.CERTPATH+CONFIG.CERTIFICATE	'"certificates/cacert.pem"
	'Field repository:TRepository
	'Field description:String

	'Method New( path:String, description:String="" )
	'	Self.repository = TRepository.get( path, path )
	'	Self.description = description
	'End Method
	
	'Method New( repository:TRepository, description:String="" )
	'	Self.repository = repository
	'	Self.description = description
	'End Method
	
	Method downloadString:String( url:String, headers:String[] = [] )
		Local curl:TCurlEasy = TCurlEasy.Create()
		If curl<>Null
			curl.setWriteString()
			'curl.setOptInt( CURLOPT_VERBOSE, 1 )
			curl.setOptInt( CURLOPT_FOLLOWLOCATION, 1)
			curl.setOptString( CURLOPT_CAINFO, CertPath )
			curl.setOptString( CURLOPT_URL, url )
			'curl.setProgressCallback( progressCallback )
			headers :+ ["User-Agent: "+UserAgent, "Referer:"]
			curl.httpHeader( headers )
		EndIf
		Local error:Int = curl.perform()
		If error; Throw CurlError( error )
		curl.cleanup()
		Return curl.toString()
	End Method
	
	Method downloadBinary:Int( url:String, filename:String="" )
		'If filename = ""; filename = repository.name
		filename = CONFIG.DATAPATH+sanitise( filename )
		
		Local curl:TCurlEasy = TCurlEasy.Create()
		Local stream:TStream = WriteStream( filename )
		
		If curl<>Null And stream
			curl.setWriteStream( stream )
			'curl.setOptInt( CURLOPT_VERBOSE, 1 )
			curl.setOptInt( CURLOPT_FOLLOWLOCATION, 1)
			curl.setOptString( CURLOPT_CAINFO, CertPath )
			curl.setOptString( CURLOPT_URL, url )
			curl.setProgressCallback( progressCallback )
			curl.httpHeader( ["User-Agent: "+UserAgent, "Referer:"] )
		EndIf
		Local error:Int = curl.perform()
		CloseStream( stream )
		If error; Throw CurlError( error )
		curl.cleanup()
		'Print filename+", filesize: "+FileSize(filename)
		'Return curl.toString()
		Return FileSize(filename)
	End Method 
	
	Method Jdownload:JSON( url:String )
		Return JSON.parse( downloadString( url ) )
	End Method
	
	Method getReleases:TList( repository:TRepository, filter:String = "" ) Abstract
	Method getLatest:TRelease( repository:TRepository ) Abstract
	
	' Method used to get the modserver.json file from a modserver
	Method getRemoteConfig:JSON( source:TRepository ) Abstract
	
	' Get the last commit of a given file
	Method getLastCommit:String( repository:TRepository, filepath:String ) Abstract
	
	' Santise a filename
	'TODO: Need to improve this
	Function sanitise:String( filename:String )
		'DebugStop
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

	Function progressCallback:Int(data:Object, dltotal:Long, dlnow:Long, ultotal:Long, ulnow:Long)
		'Local this:TModserver = TModserver(data)
		Local now:Int = MilliSecs()
		If now > TModserver.timer
			Print " "+CurrentTime()+" "+ dlnow/1024/1024 +"Mb"
			TModserver.timer = now+5000
		End If
		'Print " ++++ " + dlnow + " bytes"
		Return 0	
	End Function
	
	
End Type
