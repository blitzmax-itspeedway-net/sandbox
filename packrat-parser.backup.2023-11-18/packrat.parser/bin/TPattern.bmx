
Type TPattern
	
	Field this:TTypeId					' This is a reflection of Self
	Field kind:Int '= KIND_NONE
	Field name:String					' Used for named patterns
	Field hidden:Int = False			' Used to hide core rules

	'Field expected:String				' Used in "expected" errors
	'Field quiet:Int = False				' Used to silence "expected" errors

	Field patterns:TPattern[] = []
	
	Field depth:Int 					' Used for tree drawing

	'Method match:TParseNode( text:String, pos:Int=0, tab:String="" ) Abstract
	Method match:TParseNode( doc:TTextDocument, pos:Int=0, depth:Int=0 ) Abstract
	
	Method success:TParseNode()
		Return New TParsenode()
	End Method

	Method success:TParseNode( text:TTextDocument, start:Int, finish:Int, children:TParseNode[]=[] )
		Return New TParsenode( Self, kind, text, start, finish, children )
	End Method
	
	' Get an identifier for this pattern. Used in "Expected" error messages
	Method identifier:String()
		'If expected; Return expected
		If name; Return name
		Return typeof()
	End Method
	
	'Method silent:TPattern( state:Int = True )
	'	quiet = state
	'	Return Self
	'End Method
	
	Method typeof:String()
		If Not this; this=TTypeId.forobject( Self )
		Return this.name()
	End Method
	
	' Obtains the pattern operator name from the type metadata
'	Method getOperatorName:String()
'		If Not this; this=TTypeId.forobject( Self )
'		If this.hasmetadata("operator"); Return this.metadata( "operator" )
'		Return this.name()
'	End Method
	
	'Method failure:TParseNode()
	'	Return New TParsenode( False )
	'End Method

	Method AsString:String()
		If Not this; this=TTypeId.forobject( Self )
		Return this.name()+"{"+name+"}"
	End Method

	Method getid:String()
		If Not this; this=TTypeId.forobject( Self )
		Local id:String = name
		If name=""; id="<noname>"
		Return this.name()+"{"+id+"}"
	End Method

Rem
	Method save:JSON()
		Local J:JSON = New JSON()
		'J["_typeid"]  = TTypeId.forobject( Self ).name()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		If name;     J["name"]     = name
		If hidden;   J["hidden"]   = New JSON(JBOOLEAN,True)
		If quiet;    J["quiet"]    = New JSON(JBOOLEAN,True)
		If expected; J["expected"] = expected
		If patterns.length>0
			Local list:JSON = New JSON( JARRAY )
			For Local pattern:TPattern = EachIn patterns
				list.addlast( pattern.save() )
			Next
			J.set( "patterns", list )
		End If
		Return J
	End Method
EndRem	

Rem
	Method todata:String[][]()
		Local rows:String[][]
		Local row:String[9]
		
		'Local text:String = "DefData "
		row[0] = "~q"+name+"~q"								' NAME
		row[1] = "~q"+TTypeId.forobject( Self ).name()+"~q"	' TYPEID
		row[2] = kind										' KIND
		row[3] = ["False","True"][hidden] 					' CORE (HIDDEN)
		row[4] = "0"										' Case Sensitive
		row[5] = patterns.length							' Count of PATTERNS
		'row[6] ="~q"+expected+"~q"							' EXPECT
		row[6] ="~q~q"										' EXPECT
		row[7] = "~q~q"										' Local pattern
		row[8] = "~q~q"										' Initialisation string
		'TODO: Add Quiet
		
		rows :+ [row]
		If patterns.length>0
			For Local pattern:TPattern = EachIn patterns
				Local data:String[][] = pattern.todata()
				For Local datarow:String[] = EachIn data
					rows :+ [ datarow ]
				Next
			Next
		End If
		Return rows
	End Method
EndRem

	' Writes the expression as PEG
	Method PEG:String() Abstract
	
	' Write expression using parser functions
	Method generate:String( tab:String ) Abstract
	
EndType

'Interface IPattern
'	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
'	Method AsString:String( )
'	Method getID:String()
'	Method save:JSON()
'	Method PEG:String()
'End Interface



Rem
Function debugline:TDebug( pattern:TPattern, text:String, start:Int, finish:Int=0 )
	Local line:String
	If finish=0
		line = text[ start..(start+13)]+".. "
	Else
		line = text[ start..finish ][..15]+" "
	End If
	'Local name:String = TTypeId.forobject( pattern ).name()
	Local name:String = pattern.getid()
	If Len(name)<15; name = name[..15]
	Return New TDebug( line + name )
End Function

Type TDebug
	Const MINIMUM:Int = 15
	
	Global DEBUGGER:Int = False
	
	Field base:String
	Field line:String

	Method New( base:String )
		Self.base = base
	End Method
	
	Function enable()
		DEBUGGER = True
	End Function
	
	Function disable()
		DEBUGGER = False
	End Function
	
	Method reset()
		line = ""
	End Method

	Method reset( text:String )
		line = ""
		add( text )
	End Method

	Method reset( lines:String[] )
		line = ""
		add( lines )
	End Method
	
	Method add( text:String )
		If Len(text) < MINIMUM; text = text[..MINIMUM]
		line :+ cleanse(text) + " "
	End Method

	Method add( lines:String[] )
		For Local text:String = EachIn lines
			add( text )
		Next
	End Method
	
	Method echo()
		If DEBUGGER; Debug base+" "+line
	End Method

	Method echo( text:String )
		add( text )
		If DEBUGGER; Debug base+" "+line
	End Method

	Method echo( lines:String[] )
		add( lines )
		If DEBUGGER; Debug base+" "+line
	End Method
	
EndType
EndRem





