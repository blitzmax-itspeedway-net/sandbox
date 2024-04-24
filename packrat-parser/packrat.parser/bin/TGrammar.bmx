

Type TGrammar Extends TDictionary
	Field name:String = "UNDEFINED"	' Name of the grammar
	Field start:String = "START"	' Starting rule name
	
	Method New( name:String, start:String = "START", core:Int=True )
		Super.New()
		Self.name  = name
		Self.start = start
	
		' Install core rules
		If core
					'

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
	
	'Method getrule:TPattern( name:String )
	'	Return TPattern( Self[ name ] )
	'End Method
	
	'Method StartRule:TPattern()
	'	Return New TNonTerminal( start, Self )
	'	'Return TPattern( Self[ start ] )
	'End Method
	
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

	' Set a key
	Method Operator []=( key:String, value:TPattern )
		Local link:TLink
		' Delete old record and update it
		If index.contains( key )
			link = TLink( index.valueforkey( key ) )
			link.remove()
		End If
		' Create a new key
		'value.name = key				' Rules are always named
		link = list.addlast( value )
		index[key] = link
	End Method
	
	Method toPEG:String( showCoreRules:Int = False )
		Local peg:String = "# PEG Definition for "+name+"~n#~n# Starting rule: "+start+"~n~n"
		For Local rulename:String = EachIn Self.keys()
			Local rule:TPattern =  TPattern( Self[rulename] )
			If rule.hidden And Not showCoreRules; Continue
			peg :+ rulename + " <- " + rule.peg() + "~n"
		Next
		Return peg
	End Method


	
Rem
Due to a bug in Blitzmax; data defintions must be in the same file as the
readdata and restoredata and therefore this doesn't work without a lot of messing about.

	Method toDataDef:String()
		Local def:String
		
		' Header
		def :+ "'~tPEG DEFINITION FOR "+Upper(name)+"~n~n"
		
		def :+ "#PEGDefinition~n"
		Local biggest:Int = 5+Max( Len(name), Len(start) )
		def :+ "DefData "+("~q"+name+"~q")[..biggest]+"' Grammar Name~n"
		def :+ "DefData "+("~q"+start+"~q")[..biggest]+"' Starting Rule Name~n"
		
		' Calculate tabstops
		
		Local tabs:Int[10]
		' Allow extra space for boolean fields
		tabs[3] = 8		
		tabs[4] = 8

		Local title:String[] = ["NAME","TYPEID","KIND","CORE","CASE","PATTERNS","EXPECT","PATTERN  ","INIT"]
		For Local n:Int = 0 Until title.length
			tabs[n] = Max( tabs[n], 2+title[n].length )
		Next

		For Local key:String = EachIn Self.keys()
			Local pattern:TPattern = TPattern( Self[key] )
			tabs[0] = Max( tabs[0], 3+key.length )
			tabs[1] = Max( tabs[1], 3+Len( TTypeId.forobject( pattern ).name() ) )
			tabs[6] = Max( tabs[6], 3+Len( pattern.identifier() ) )
		Next
		
		tabs[7]=0
		tabs[8]=0
		
		' Create Rules
		def :+ "~n'~tRULE DEFINITION FOR "+Upper(name)+"~n~n"
		def :+ "'       "+ padline( title, tabs, "")+"~n"
		
		' Output the rules
		For Local key:String = EachIn Self.keys()
			Local pattern:TPattern = TPattern( Self[key] )
			def :+ "' "+ key + " <- "+pattern.PEG()+"~n"
			'DebugStop
			Local data:String[][] = pattern.toData()
			'Print data.length
			'Local dims:Int[] = data.dimensions()
			'Print dims
			'DebugStop
			For Local n:Int = 0 Until data.length
				Local row:String[] = data[n]
				Local line:String = padline( row, tabs )
				'For Local fld:Int = 0 Until row.length
				'	line :+ (row[fld]+", ")[..tabs[fld]]
				'Next
				def :+ "DefData "+line+"~n"
			Next			
		Next
		def :+ "DefData ~q#END#~q"
		Return def
		
		' TAB of 0 is "Auto-grow"
		Function padline:String( row:String[], tabs:Int[], sep:String="," )
			Local line:String
			If tabs.length < row.length; tabs = tabs[..(row.length)]
			For Local fld:Int = 0 Until row.length
				If tabs[fld] = 0
					line :+ row[fld]+sep+" "
				ElseIf row[fld].length > tabs[fld]
					Print "Field too large: "+ row[fld]
					Print "Expected "+tabs[fld]+" but length is "+row[fld].length
					End
				Else
					line :+ (row[fld]+sep)[..tabs[fld]]
				End If
			Next
			line = Trim(line)
			Return line[..Len(line)-Len(sep)]	' Strip trailing seperator
		End Function
		
	End Method
EndRem	

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