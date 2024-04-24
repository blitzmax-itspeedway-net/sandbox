SuperStrict

'Import packrat.parser
Import "../packrat.parser/parser.bmx"
Import "../packrat.functions/functions.bmx"

Import "../peg.parser/parser.bmx"

Import "../bin/TConfig.bmx"

Import "../gui/gui.bmx"

Const CONFIG_FILE:String = "admin.config"
Local config:TConfig = New TConfig()
config.Load( CONFIG_FILE )

' Create administration interface
'Global ui:Admin = New Admin( 800, 600 )
'ui.treeviewer.setsize( 80 )

' Create Visualiser
Global app:TVisualiser = New TVisualiser()
app.setShape( config.getint("x"), config.getint("y"), config.getint("w"), config.getint("h") )

' Add a tree viewer component
Global viewer:TTreeView = New TTreeView()
app.add( "TREE", Viewer )
'viewer.setTree( root )


'######################################################




'Global view:TViewer = New TViewer()

Local result:TParseTree

'DebugStop ' STARTING

' Match a number [0-9] 
'	REGEX = \d
'	Digit -> "0"/"1"/"2"/"3"/"4"/"5"/"6"/"7"/"8"/"9"
'	Digit -> 

Local sourcecode:String = "This is text with a number 1234.8"
Local int_test:String = "There were 100 of them"

'Local range:String = 
'range = MakeRange( ["AF","af","0-9"] )

Local rules:TDictionary = New TDictionary()

'# DIGIT -> [0-9]
Local digit:TPattern = RANGE( "0-9" )
rules["digit"] = digit

'# ALPHA -> [A-Za-z]
Local alpha:TPattern = RANGE( "A-Za-z" )
rules["alpha"] = alpha

'# ALPHANUMERIC -> [A-Za-z0-9]
Local alphanumeric:TPattern = RANGE( "A-Za-z0-9" )
'# HEXDIGIT -> [A-Fa-f0-9]
Local hexdigit:TPattern = RANGE( "A-Fa-f0-9" )

'# ERR_DIGITEXPECTED -> (!\s .)*
Local ERR_DigitExpected:TPattern = Null

'# NUMBER -> DIGIT+ "." DIGIT+ | DIGIT+ | ERR_DIGITEXPECTED
Local number:TPattern = ..
  CHOICE( "FLOAT", [..
    SEQUENCE([..
      ONEORMORE( digit ), ..
      LITERAL( "." ), .. 
      ONEORMORE( digit ) ..
      ]), ..
    OneOrMore( "INTEGER", digit ), ..
    ERR_DigitExpected ..
    ])
'DebugStop

'# HEXNUMBER -> HEXDIGIT*
'Local hexnumber:TPattern = repeats( hexdigit )
'title( "Digit Match" )
'Print( digit.match( sourcecode, 27 ).AsString() )
'title( "Float Match" )
'Print( number.match( sourcecode, 27 ).AsString() )
'title( "Int Match" )
'Print( number.match( int_test, 11 ).AsString() )

title( "Blitzmax parser build" )
Local parser:TPackratParser = PEG_Parser()	' Create an instance of the PEG Parser
'DebugStop
'Local blitzmax:TParser = TParser.load( "examplecode/blitzmax.pac" )			' Load a previously saved grammar

' Compile a parser from PEG
Local tree:TParseTree = parser.parse( "blitzmaxng.peg", "BMX" )
'New TPackratParser.build( "blitzmaxng.peg", "blitzmaxng" )	

If Not tree
	Print( "** FAILED TO BUILD **" )
End If

' Wait until application finished.
app.Run()

DebugStop
'NEED SOME ERROR DEBUGGING HERE

'TParser.build returns Null, so we have nothing To inspect!

'CONSOLE.SHOW()

DebugStop
'tree.save( "examplecode/blitzmax.pac" ) ' Save a pakrat parser definition

' GET BLITZMAX GRAMMAR FROM PARSE TREE
Local blitzmax:TPackratParser = New TPackratParser( "BlitzMax" )
Local grammar:TGrammar = New TGrammar()
grammar = ExtractGrammar( tree )
blitzmax.setGrammar( grammar )



' USE BLITZMAX PARSER

title( "Blitzmax parser match" )
sourcecode = LoadString( "examplecode/1.bmx" )
Local ptree:TParseTree = blitzmax.parse( sourcecode, "blitzmax" ) 

title( "Other" )

DebugStop
Local HelloPattern:TPattern = literal( "hello" )
result = HelloPattern.match( "hello world" )	'; // -> New Match(text, 0, 5))
If result; Print result.AsString() Else Print( "NULL" )

'view.show( result )

result = HelloPattern.match( "goodbye" )		'; // -> no match (undefined)
If result; Print result.AsString() Else Print( "NULL" )
result = HelloPattern.match( "hello world", 5)		'; // -> no match at index 5
If result; Print result.AsString() Else Print( "NULL" )

DebugStop
Local HelloWorldPattern:TPattern = chain( ..
	[literal("hello"), literal(" "), literal("world")] ..
	)
result = HelloWorldPattern.match("hello world")	'; // -> New Match(text, 0, 11))
If result; Print result.AsString() Else Print( "NULL" )
result = HelloWorldPattern.match("goodbye")		'; // -> undefined
If result; Print result.AsString() Else Print( "NULL" )

DebugStop
Local AddressWorldPattern:TPattern = chain( [ ..
	oneOf( [literal("hello"), literal("goodbye")] ), ..
	literal(" "), literal("world")] ..
	)
result = AddressWorldPattern.match( "hello world" )		'; // -> New Match(text, 0, 11))
If result; Print result.AsString() Else Print( "NULL" )
result = AddressWorldPattern.match( "goodbye world" )	'; // -> New Match(text, 0, 13)
If result; Print result.AsString() Else Print( "NULL" )
result = AddressWorldPattern.match( "hello sky" )		'; // -> undefined
If result; Print result.AsString() Else Print( "NULL" )
DebugStop

' TEST CSV PArsing....

' Equivalent To the regex: [^,\n]*
Local CSVItem:TPattern = named( "ITEM", ..
	capture(..
		Repeats( chain( [negate(literal(",")), negate(literal("~n")), any()] ))..
	))
' Sort of like: CSVItem ("," CSVItem)*
Local CSVLine:TPattern = named( "LINE", ..
	capture(..
	chain( [CSVItem, Repeats( chain([literal(","), CSVItem]))] )..
	))
' Sort of like: CSVLine ("\n" CSVLine)*
Local CSVFile:TPattern = named( "FILE", ..
	capture(..
	chain( [CSVLine, Repeats( chain([literal("~n"), CSVLine]))] )..
	))

' It works (but only For validation)
Local my_file:String = "1,2,3~n4,5,6"

result = CSVFile.match( my_file )	'// New Match(...)
If result; Print result.AsString() Else Print( "NULL" )
If result; Print "VALIDATED"

'view.show( result )

DebugStop

' Sum values in each row of CSV file:
For Local row:TMatch = EachIn result.children
	Local total:Int = 0
	DebugStop
	For Local item_text:String = EachIn row.captures()	'get_captures( row )
		DebugStop
		' total :+ int( item_text )
	Next
	Print "TOTAL:"+total	' Should be 6 and 15
Next

DebugStop
' Grammar Definitions

'Local grammar:TGrammar = New TGrammar()

'grammar["anychar"] = named( "AnyChar", literal(".") )
'grammar["CharSet"] = named( "CharSet", chain( [ ..
'	literal("["), ..
'	Repeats( chain( [Negate(literal("[")), capture(any())), ..
'	literal("]") ] )..
'	]))
DebugStop

' BUILT IN DEFINITIONS
'Local digit:TChain ' = range( ["09"] )
'Local letter:TChain ' = range( ["az","AZ"] )
'Local whitespace:TChain '= set( " ~t~r~n"+chr(0)+"~f~v" )
'Local hexchar:TChain '= range( ["09","af","AF"] )
'Local number:TChain '= repeats( digit )
'Local word:TChain '= repeats( letter )
'Local hexadecimal:TChain '= repeats( hexchar )

'Local peg:TGrammar = New TGrammar()
'Local octet:TChain
'Local ipaddress:TChain = sequence( [octet, ".", octet, ".", octet, ".", octet] )

'Print peg.match( ipaddress, "0.0.0.0" )			' TRUE
'Print peg.match( ipaddress, "192.168.1.202" )	' TRUE
'Print peg.match( ipaddress, "hostname" )		' FALSE
'Print peg.match( ipaddress, "256.1.1.1" )		' FALSE
'Print peg.match( ipaddress, "0.0.Version" )		' FALSE

' Build a Blitzmax Parser Generator
'Local blitzmax:TPattern = New TGrammar( BlitzMaxNG_PEG )

'Local __remark:TPattern = seq( [literal("rem",True),neg(set([range(["az","AZ","09"]),"_"]))]) ' ^'rem'
'Local __endremark:TPattern = seq( 

'Local blitzmaxng:TPattern = seq( [__remark,__any

' Parse a Blitzmax file:
'Local test:String = "REM~nSome stuff+~nENDREM~n"
'Local ast:Int = blitzmaxng.parse( text )

' SYMBOLS AND DEFINITIONS
Rem
	_ 		Whitespace, defined as: [\s\t\n\r]*
	
End Rem
' PEG GRAMMAR PARSER
Rem PEG
	

End Rem

Function title( message:String )
	Global line:String = " "[..40].Replace(" ","==")
	Print "~n"+line+"~n#~t"+message+"~n"+line+"~n"
End Function

'Local blitzmax:TPEGParser = TPEGgenerator.build( EXAMPLE )

'Local program:String = LoadString( "tests/program1.bmx" ) 

' Packrat Parsing
'Local result:TParseTree = blitzmax.parse( program )

' Packrat incremental parsing
' If TParseTree.memoisation is null, then it acts as a parser
' Otherwise it uses the memo table to perform incremental parsing
' 3.3
' Memoisation tables need to have some UNDO/REDO capability
' For example, starting a multiline string will render the entire documen a string!
' Same with a mutli-line remark
'Local memoization:Object 	' New memoization table
'Local result:TParseTree = blitzmax.parse( program, memoization )


DebugStop

Global PEG_BlitzMaxNG:String = """
REMARK:         ^'rem' ![a-z,A-Z,0-9,_]
ENDREMARK:      ^'endrem' / (^'end' ^'rem' )
COMMENTBLOCK:   REMARK COMMENT* ENDREMARK
COMMENT:        COMMENT / (!REMARK !ENDREMARK .)
"""

' Hanging ELSE
' S ← 'if' C ('then'/';') S 'else' S 'endif' / 'if' C ('then'/';' S


