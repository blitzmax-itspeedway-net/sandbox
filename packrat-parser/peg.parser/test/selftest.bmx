'	SELFTEST
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
Rem

PERFORM THE FOLLOWING TESTS:

1. TEST PEG PARSING

	Load Manually created DEV parser as "A"
	Generate PEG definition "B" using parser "A"
	Parse PEG definition "B" using parser "A" into ParseTree "C"
	Generate PEG definition "D" from ParseTree "C"
	Parse PEG definition "D" using parser "A" into ParseTree "E"
	Generate PEG definition "F" from ParseTree "E"
	Compare PEG definition B, D and F are identical
	
2. TEST PARSER GENERATOR

	Load Manually created DEV parser as "A"
	Generate PEG Parser as "B" using DEV parser "A"
	Load Procedurally generated PEG Parser "B"
	Generate PEG Parser as "C" using PROD parser "B"
	Compare Parser "B" with Parser "C"

	Note: This will need to import files that have been changed or created
	so will need files to be compiled during execution.

End Rem

'	MANUAL (DEV) PACKRAT PARSER
Include "../bin/TPackratParser_PEG_DEV.bmx"
Include "../bin/TPackratParser_PEG_DEV.bmx"

Global STATE:String = "SUCCESS"

Print "~n## SELF TEST 1 - TEST PEG PARSING"
' ------------------------------------------------------------
Local ParserA:TPackrat_Parser = New TPackratParser_PEG_DEV()
test( ParserA <> Null )
Print "* Load Manually created DEV parser as 'A'"+STATE
' ------------------------------------------------------------
Local PEGB:String = ParserA.grammar.toPEG()
test( PEGB<>"" )
Print "* Generate PEG definition 'B' using parser 'A'"+STATE
Print PEGB
' ------------------------------------------------------------
Local TreeC:TParseTree = ParserA.parse( PEGB )
test( TreeC <> Null And ParserA.errorcount() = 0 ) 
Print "* Parse PEG definition 'B' using parser 'A' into ParseTree 'C'"+STATE
' ------------------------------------------------------------
Local PEGD:String = ParseTree2PEG( TreeC )
test( PEGD<>"" )
Print "* Generate PEG definition 'D' from ParseTree 'C'"+STATE
' ------------------------------------------------------------
Local TreeE:TParseTree = ParserA.parse( PEGD )
test( TreeF <> Null And TreeF.errorcount() = 0 ) 
Print "* Parse PEG definition 'D' using parser 'A' into ParseTree 'E'"+STATE
' ------------------------------------------------------------
Local PEGF:String = ParseTree2PEG( TreeE )
test( PEGF<>"" )
Print "* Generate PEG definition 'F' from ParseTree 'E'"+STATE
' ------------------------------------------------------------
test( PEGB=PEGD And PEGD=PEGF )
Print "* Compare PEG definition B, D And F are identical"+STATE
' ------------------------------------------------------------
Print "~n## SELF TEST 2 - TEST PARSER GENERATOR"

'Local ParserA:TPackratParser = New TPackrat_PEG_Parser_DEV()
test( ParserA <> Null )
Print "* Load Manually created DEV parser as 'A'"+STATE
' ------------------------------------------------------------
Local filename_ParserB:String = "SELFTEST_ParserB.bmx"
Local Generator:TParserGenerator = New TParserGenerator( "SELFTEST", parserA.grammar )
If FileType( filename_ParserB ) = FILETYPE_FILE; DeleteFile( filename_ParserB )
Generator.write( filename_ParserB )
test( FileType( filename_ParserB ) = FILETYPE_FILE )
Print "* Generate PEG Parser as 'B' using DEV parser 'A'"+STATE
' ------------------------------------------------------------
Local commandline:String = BlitzMaxPath + "bcc "+CurrentDir()+"/_selftest_2a.bmx"
DebugStop
End

Local Process1:TProcess = CreateProcess(commandline)
Print "  - Compiling Parser 'B'"
Local timeout:Int = MilliSecs+ 60000
Local compiled:Int = False
Repeat
	Delay(1000)
	compiled = ProcessStatus(Process1)
Until compiled Or MilliSecs() > timeout
Assert compiled, "** FAILED TO COMPILE _selftest_2.bmx"

Local ParserB:TPackratParser = New TPackrat_PEG_Parser_DEV()
Print "* Load Procedurally generated PEG Parser 'B'"+STATE
' ------------------------------------------------------------
Local filename_ParserC:String = "SELFTEST_ParserC.bmx"
Local Generator:TParserGenerator = New TParserGenerator( "SELFTEST", parserB.grammar )
If FileType( filename_ParserC ) = FILETYPE_FILE; DeleteFile( filename_ParserC )
Generator.write( filename_ParserC )
test( FileType( filename_ParserC ) = FILETYPE_FILE )

Print "* Generate PEG Parser as 'C' using PROD parser 'B'"+STATE
commandline = BlitzMaxPath + "bcc "+CurrentDir()+"/_selftest_2b.bmx"
DebugStop
End 
' ------------------------------------------------------------
Local ParserB_Text:String = LoadString( "SELFTEST_ParserB.bmx" )
Local ParserC_Text:String = LoadString( "SELFTEST_ParserC.bmx" )
test( ParserB_Text=ParserC_Text)
Print "* Compare Parser 'B' with Parser 'C'"+STATE
' ------------------------------------------------------------
Print "~nCLEANUP:"
If FileType( filename_ParserB ) = FILETYPE_FILE
	Print "* Deleting "+filename_ParserB
	DeleteFile( filename_ParserB )
End If

Function test( criteria:Int )
	STATE = [" - FAILURE"," - SUCCESS"][criteria]
End Function