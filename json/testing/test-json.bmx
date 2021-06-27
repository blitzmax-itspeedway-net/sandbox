SuperStrict

'	JSON TYPE TESTING
'	(c) Copyright Si Dunford, June 2021

Include "../json.bmx"

Function LoadFile:String( filename:String )
	Local file:TStream = ReadFile( filename )
	If Not file Return ""
	Local content:String content = ReadString( file, int(file.size()) )
	CloseStream file
	Return content
End Function 

function clean:string( text:string )
		return text.replace("~n","").replace("~r","").replace("~t"," ")
End Function

Function Validate( folder:string, filename:String )
	print "FILE: "+filename
	filename = "../"+folder+"/"+filename
	'DebugStop

	if filetype(filename) <> 1
		debuglog("File does not exist")
		return 
	end if

	Local file:String = LoadFile( filename )
	print "- INPUT:     "+clean(file)
	'print "                   1111111111222222222233333333334444444444"
	'print "         01234567890123456789012345678901234567890123456789"

	debugstop
	Local j:JNode = JSON.Parse( file )
	If j.isInvalid()
		Print "- PARSE:     FAILURE"
		Print "  ERROR:     "+ JSON.errtext + " {"+ JSON.errline+","+JSON.errpos+"}"
		Print "  FILE:      "+clean(file)
		Return
	else
		Print "- PARSE:     SUCCESS"
	End If
	
	'DebugStop
	
	Local str:String = JSON.Stringify( j )
	if str>1
		Print "- STRINGIFY: SUCCESS"
	else
		print "- STRINGIFY: FAILURE"
	end if
	Print "- RESULT:    "+str



End Function

'	TEST KNOWN FAILURES

'Validate( "failure", "char-past-eof.json" )
'Validate( "failure", "missing-comma.json" )
'Validate( "failure", "non-quoted-key.json" )

'	TEST KNOWN SUCCESS

'Validate( "success", "empty-file.json" )
'Validate( "success", "empty-object.json" )
'Validate( "success", "basic.json" )

' 	TEST REAL JSON

Validate( "vscode", "initialize.json" )
Validate( "vscode", "shutdown.json" )
