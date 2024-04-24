
Rem
Change comments To "//" And possibly /*..*/

Add support For directives:
! KEY = VALUE

(The only currentl directive is !START=Blitzmax)
! RESERVEDWORDS=	' Used to prevent keywords from being reserved words


CASE INSENSITIVE USING A TILDE: ~"FUNCTION"

$expression - Return matched text instead of match

{ Post-processing metadata }

	{ ONSUCCESS, ONFAILURE }

	Used For error recovery, perhaps.
	
Add callback For errors To parser; Or maybe simply call Self.errorhandler( ... ) 

	MATCH error thrown when a match fails
	SYNTAX error thrown when no matches in a choice match
	
String = '"' value:(!(eol / '"') .)+ '"' { return value; }
       / '"' value:(!(eol / '"') .)+     { error('unterminated string constant'); return value; }

"EXPECTED" ERROR MESSAGES

    number -> [0-9]*
    sum => number "+" number

grammar.parse( "3 + A" )    "Expected 'number' at 5"

    number "integer" -> [0-9]*
    sum => number "+" number

grammar.parse( "3 + A" )    "Expected 'integer' at 5"

SILENT ERRORS
Error is Not generated on fail

    number -> #quiet( [0-9]* ) / #EXPECTED("identifier")


EndRem


Type TGrammar Extends TDictionary
	Field name:String = "UNDEFINED"	' Name of the grammar
	Field start:String = "START"	' Starting rule name
	
	Method New( name:String, start:String, core:Int=True )
		Super.New()
		Self.name  = name
		Self.start = start
	
		' Install core rules
		If core
		
			'Self["ALPHA"]  = CHARSET( MakeRange([ "AZ", "az" ]) )		' Case insensitive A-Z
			'Self["CHAR"]   = CHARSET( Makerange( Chr($34)+Chr($7F) ))	' 7 BIt ASCII except CTRL
			'Self["CR"]     = CHARSET( Chr($0D) )						' Carriage Return
			'Self["CRLF"]   = CHARSET( Chr($0D)+Chr($0A) )				' Newline
			'Self["DIGIT"]  = CHARSET( MakeRange( "09" ) )				' Number 0 to 9
			'Self["DQUOTE"] = CHARSET( Chr($22) )                        ' Double Quote 
			'Self["HEXDIG"] = CHARSET( MakeRange([ "09", "AF", "af" ]))  ' Hexadecimal digits
			'Self["HTAB"]   = CHARSET( Chr($09) )                        ' Horizontal Tab
			'Self["LF"]     = CHARSET( Chr($0A) )						' Line Feed
			'Self["OCTET"]  = CHARSET( Makerange( Chr($00)+Chr($FF) ))	' Any 8 bit character
			'Self["SP"]     = CHARSET( Chr($20) )                        ' Space
			'Self["VCHAR"]  = CHARSET( Makerange( Chr($21)+Chr($7E) ))   ' visible (printing) characters
			'Self["WSP"]    = oneOrMore( "WSP", choice([ SP, HTAB  ]) )  ' Whitespace
			'
			Self["ALPHA"]    = RANGE([ "AZ", "az" ])         ' Case insensitive A-Z
			Self["CHAR"]     = RANGE( Chr($34)+Chr($7F) )    ' 7 BIt ASCII except CTRL
			Self["CR"]       = SYMBOL( $0D )                 ' Carriage Return \r
			Self["CRLF"]     = CHARSET( Chr($0D)+Chr($0A) )  ' Newline \r\n
			Self["DIGIT"]    = RANGE( "09" )                 ' Digit 0 to 9
			Self["DQUOTE"]   = SYMBOL( $22 )                 ' Double Quote 
			Self["HEXDIGIT"] = RANGE([ "09", "AF", "af" ])   ' Hexadecimal digits
			Self["HTAB"]     = SYMBOL( $09 )                 ' Horizontal Tab
			Self["LF"]       = SYMBOL( $0A )                 ' Line Feed \n
			'Self["OCTET"]    = RANGE( Chr($00)+Chr($FF) )    ' Any 8 bit character
			'Self["VCHAR"]    = RANGE( Chr($21)+Chr($7E) )    ' visible (printing) characters
			Self["SP"]       = SYMBOL( $20 )                 ' Space
			Self["WSP"]      = CHOICE([ SP, HTAB ])          ' Whitespace
			'
			
			' WHITESPACE SHORTCUT
			Local _:TPattern = ZEROORMORE( __("WSP") )

			' EXTENDED CORE DEFINTIONS
			Self["NUMBER"]  = ONEORMORE( "NUMBER", DIGIT )               	' Number
			Self["QSTRING"] = SEQUENCE([ DQUOTE, ZEROORMORE( SEQUENCE([ NOTPRED(DQUOTE), RANGE([Chr($20),Chr($21),Chr($23)+Chr($7E)]) ]) ), DQUOTE ])
			Self["EOF"]     = NOTPRED( ANY() )
			Self["EOL"]     = SEQUENCE( "EOL", [ _, OPTIONAL( __("CR") ), __("LF") ] )

			'Self["UNTILEOL"] = SEQUENCE( [ ZEROORMORE( SEQUENCE([ NOTPRED( __("EOL") ), ANY() ]) ), __("EOL") ])

			' Flag all core rules to prevent them being shown in output
			For Local rule:String = EachIn Self.keys()
				Local pattern:TPattern = TPattern( Self[rule] )
				pattern.hidden = True
			Next
	
		End If
	End Method

	' Declare rules to allow reference before definition
	Method declare( patterns:String[] )
		For Local pattern:String = EachIn patterns
			'Print( "DECLARING '"+pattern+"'" )
			'If contains(pattern); Print "- Already defined"
			Assert Not contains(pattern), "Pattern '"+pattern+"' already exists and cannot be re-declared"
			Self[pattern] = "DECLARED"
		Next
	End Method

	Method setStart( start:String )
		Self.start = start
	End Method

	Method getStart:String()
		Return start
	End Method
	
	Method StartRule:TPattern()
		Return TPattern( Self[ start ] )
	End Method
	
	' Non-Terminal runtime lookup
	Method NonTerminal:TPattern( name:String )
		Return New TNonTerminal( name, Self )
	End Method

	' Shortcut to NonTerminal
	Method __:TPattern( name:String )
		Assert Self.contains( name ), "Undefined Pattern '"+name+"' in definition"
		Return New TNonTerminal( name, Self )
	End Method

	' Get a key
	Method Operator []:TPattern( key:String )
		Local link:TLink = TLink( index.valueforkey( key ) )
		If link; Return TPattern( link.value() )
		Return Null
	End Method
	
	Method toPEG:String( showCoreRules:Int = False )
		Local peg:String = "# PEG Definition for "+name+"~n#~n# Starting rule: "+start+"~n~n"
		For Local rulename:String = EachIn Self.keys()
			Local rule:TPattern =  TPattern( Self[rulename] )
			If rule.hidden And Not showCoreRules; Continue
			peg :+ rulename + " -> " + rule.peg() + "~n"
		Next
		Return peg
	End Method
	
End Type

Type TDictionary 

	Field index:TMap		' Index of TLINK (Into list)
	Field list:TList		' List of TPattern
	
	Method New()
		index = New TMap()
		list  = New TList()
	End Method

'	Method addFirst( key:String, value:Object )
'		index.addFirst( key )
'		list.insert( key, value )		
'	End Method

'	Method addLast( key:String, value:Object )
'		index.addLast( key )
'		list.insert( key, value )		
'	End Method

'	Method first:Object()
'		Return list.valueforkey( String(index.first()) )
'	End Method

	Method count:Int()
		If list; Return list.count()
	End Method

	Method keys:TMapEnumerator() 
		Return index.keys()
	End Method

	Method contains:Int( key:String )
		Return index.contains( key )
	End Method
	
	' Assign a new key
	Method Operator []=( key:String, value:Object )
		Local link:TLink
		' Delete old record and update it
		If index.contains( key )
			link = TLink( index.valueforkey( key ) )
			link.remove()
		End If
		' Create a new key
		link = list.addlast( value )
		index[key] = link
	End Method
	
	' Get a key
	Method Operator []:Object( key:String )
		Local link:TLink = TLink( index.valueforkey( key ) )
		If link; Return link.value()
		Return Null
	End Method
	
End Type

Rem
DebugStop

Type TTest
	Field name:String
	
	Method New( name:String )
		Self.name = name
	End Method
	
End Type

Local dict:TDictionary = New TDictionary()

dict["ONE"] = New TTest( "ONE" )
dict["TWO"] = New TTest( "TWO" )
dict["THREE"] = New TTest( "THREE" )

Print TTest(dict["ONE"]).name
Print TTest(dict["TWO"]).name
Print TTest(dict["THREE"]).name

dict["TWO"] = New TTest( "FOUR" )

Print TTest(dict["ONE"]).name
Print TTest(dict["TWO"]).name
Print TTest(dict["THREE"]).name
end rem