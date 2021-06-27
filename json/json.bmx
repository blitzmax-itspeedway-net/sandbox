
'   JSON PARSER
'   (c) Copyright Si Dunford, June 2021, All Right Reserved

'   JSON Specification:
'   https://www.json.org/json-en.html

' THis is the JSON Parse
Type JSON

    Public

    ' Error Text, Line and Character
    Global errLine:Int = 0
    Global errPos:Int = 0
	Global errNum:Int = 0
    Global errText:String = ""

    ' Create JSON object from a string
    'Method New( text:String )
    '    root = parsetext( text )
    'End Method

    ' Create a JSON object from a Blitzmax Object (Reflection)
    'Method New( obj:Object )
		'root = reflect( obj )
    'End Method

	' Confirm if there is an error condition
	Method error:Int()
		Return ( errNum > 0 ) 
	End Method
	
    ' Convert text into a JSON object
    Function Parse:JNode( text:String )
        If Not JSON.instance JSON.instance = New JSON()
        Return JSON.instance.parseText( text )
    End Function

    ' Convert JSON into a string
    Function Stringify:String( j:JNode )
		If j Return j.stringify()
		Return ""
    End Function

    ' Convert an Object into a string
    'Function Stringify:String( o:Object )
    'End Function

    ' Convert JSON to an Object
    Function Transpose:Object( J:JNode, typestr:String )
        If J J.transpose( typestr )
    End Function
    
    Private

    ' ##### PARSER

    Const SYM_WHITESPACE:String = " ~t~n~r"
    Const SYM_ALPHA:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjklmnopqrstuvwxyz"
    Const SYM_NUMBER:String = "0123456789"

    Global instance:JSON
    Field tokens:TQueue<JToken> = New TQueue<JToken>
    Field unparsed:String
	'Field root:JNode		' The parsed content of this JSON
	
    Field linenum:Int = 1
    Field linepos:Int = 1

    ' Parse string into a JSON object
    Method parsetext:JNode( text:String )

'DebugStop

        'Local node:TMap = New TMap()
        ' For convenience, and empty string is the same as {}
        If text.Trim()="" text = "{}"
        unparsed = text
    
        ' Tokenise the JSON string
        linenum = 1
        linepos = 1
        Tokenise()

		' Dump the tokens, just for debugging purposes
		'For Local t:JToken = EachIn tokens
		'	Print( t.symbol + "  =  "+String(t.value) )
		'Next
		
        ' Parse out the parent object
        If PopToken().symbol <> "{" Return InvalidNode( "Expected '{'" )
        Local node:JNode = ReadObject()
		If node.isInvalid() Return node
        If PopToken().symbol <> "}" Return InvalidNode( "Expected '}'" )
        ' There should be no more characters after the closing braces
        'print tokens.size
        If tokens.isEmpty() Return node
        Return InvalidNode( "Unexpected characters past end" )
    End Method

    ' Reads an Object creating a TMAP
    Method ReadObject:JNode()
        Local node:TMap = New TMap()
        Local token:JToken

		'DebugStop
		
        If PeekToken().symbol = "}" Return New JNode( "object", node )
        Repeat
            ' Only valid option is a string (KEY)
            token = PopToken()
            If token.symbol <> "string" Return InvalidNode( "Expected quoted string" )

			'DebugStop
			'WE ARE LOOKING HERE To CHECK THAT JSON IS DEQUOTED

            Local name:String = Dequote( token.value )
            'DebugLog( name )

            ' Only valid option is a colon
            If Not PopToken().symbol = ":" Return InvalidNode( "Expected ':'" )

            ' Get the value for this KEY
            token = PopToken()
            Select token.symbol
            Case "{"    ' OBJECT
                'PopToken()  ' Throw away the "{"
                Local value:JNode = ReadObject()
                If PopToken().symbol <> "}" Return InvalidNode( "Expected '}'")
                node.insert( name, New JNode( "object", value ) )
            Case "["    ' ARRAY
                'PopToken()  ' Throw away the "{"
                Local value:JNode = ReadArray()
                If PopToken().symbol <> "]" Return InvalidNode( "Expected ']'" )
                node.insert( name, New JNode( "array", value ) )
            Case "string"
                'token = PopToken()
                node.insert( name, New JNode( "string", Dequote(token.value) ) )
            Case "number"
                'token = PopToken()
                node.insert( name, New JNode( "number", token.value ) )
            Case "alpha"
                'token = PopToken()
                Local value:String = token.value
                If value="true" Or value="false" Or value="null"
                    node.insert( name, value )
                Else
                    Return InvalidNode( "Unknown identifier" )
                End If
            Default
                Return InvalidNode()
            End Select

            ' Valid options now are "}" or ","
            token = PeekToken()
            If token.symbol = "}"
                Return New JNode( "object", node )
            ElseIf token.symbol = ","
                PopToken()  ' Remove "," from token list
            Else
                PopToken()  ' Remove Token
                Return InvalidNode( "Unexpected symbol '"+token.value+"'" )
            End If
        Forever
    End Method

	Method dequote:String( text:String )
		If text.startswith( "~q" ) text = text[1..]
		If text.endswith( "~q" ) text = text[..(Len(text)-1)]
		Return text
	End Method

    ' Reads an Array creating a TList
    Method ReadArray:JNode()
        Local node:JNode[]
        Local token:JToken

		'DebugStop
		
        If PeekToken().symbol = "]" Return New JNode( "array", node )
        Repeat
            ' Get the value for this array element
            token = PopToken()
            Select token.symbol
            Case "{"    ' OBJECT
                Local value:JNode = ReadObject()
                If PopToken().symbol <> "}" Return InvalidNode( "Expected '}'" )
                node :+ [ New JNode( "object", value ) ]
            Case "["    ' ARRAY
                Local value:JNode = ReadArray()
                If PopToken().symbol <> "]" Return InvalidNode( "Expected ']'" )
                node :+ [ New JNode( "array", value ) ]
            Case "string"
                'token = PopToken()
                node :+ [ New JNode( "string", Dequote(token.value) ) ]
            Case "number"
                'token = PopToken()
                node :+ [ New JNode( "number", token.value ) ]
            Case "alpha"
                'token = PopToken()
                Local value:String = token.value
                If value="true" Or value="false" Or value="null"
                    node :+ [ New JNode( value, value ) ]
                Else
                    Return InvalidNode( "Unknown identifier '"+token.value+"'" )
                End If
            Default
                Return InvalidNode( "Unknown identifier" )
            End Select

            ' Valid options now are "]" or ","
            token = PeekToken()
            If token.symbol = "]"
                Return New JNode( "array", node )
            ElseIf token.symbol = ","
                PopToken()  ' Remove "," from token list
            Else
                Return InvalidNode( "Unexpected symbol '"+token.symbol+"'" )
            End If
        Forever
    End Method

    ' Pops the first token from the stack
    Method PopToken:JToken()
        ' Whitespace is no longer tokenised
        'while not tokens.isempty() and PeekToken().in( SYM_WHITESPACE ) 
        '    PopToken()
        'wend
        If tokens.isempty() Return New JToken( "EOF","", linenum, linepos)
        Local token:JToken = tokens.dequeue()
        ' Reset the token position
        linenum = token.line
        linepos = token.pos
        Return token
    End Method

    ' Peeks the top of the Token Stack
    Method PeekToken:JToken()
        ' Whitespace is no longer tokenised
        'while not tokens.isempty() and PeekToken().in( SYM_WHITESPACE ) 
        '    PopToken()
        'wend
        If tokens.isempty() Return New JToken( "EOF","", linenum, linepos)
        Return tokens.peek()
    End Method

    ' Returns an invalid node object
    Method InvalidNode:JNode( message:String = "Invalid JSON" )
        'print( "Creating invalid node at "+linenum+","+linepos )
        'print( errtext )
        errNum  = 1
		errLine = linenum
        errPos  = linepos
        errText = message
        Return New JNode( "invalid", message )
    End Method

    ' Returns an error condition
    'Method InvalidJSON:TMap( message:String = "Invalid JSON" )
    '    errNum  = 1
'	'	errLine = linenum
    '    errPos  = linepos
    '    errText = message
    '    Return Null
    'End Method

    '##### TOKENISER

    ' Tokenise an unparsed string
    Method Tokenise()
        tokens.clear()
        ' Toker the unparsed text
        Local token:JToken = ExtractToken()
		'Print( token.symbol )
        While token.symbol <> "EOF"
            tokens.enqueue( token )    ' ListAddLast()
            token = ExtractToken()
			'Print( token.symbol )
        Wend
    End Method

    ' Extract the next Token from the string
    Method ExtractToken:JToken()
    Local char:String = PeekChar()
    Local name:String
    Local token:JToken
    ' Save the Token position
    Local line:Int = linenum
    Local pos:Int = linepos
        ' Identity the symbol
        If char=""
            Return New JToken( "EOF", "", line, pos )
		ElseIf Instr( "{}[]:,", char, 1 )               ' Single character symbol
			PopChar()   ' Move to next character
            Return New JToken( char, char, line, pos )
        ElseIf char="~q"                            ' Quote indicates a string
            Return New JToken( "string", ExtractString(), line, pos )
        ElseIf Instr( SYM_NUMBER+"-", char )     	' Number
            Return New JToken( "number", ExtractNumber(), line, pos )
        ElseIf Instr( SYM_ALPHA, char )             ' Alphanumeric Identifier
            Return New JToken( "alpha", ExtractIdent(), line, pos )
        Else
            PopChar()   ' Throw it away!
            Return New JToken( "invalid", char, line, pos )
        End If
    End Method

    ' Skips leading whitespace and returns next character
    Method PeekChar:String()
        Local char:String
        Repeat
            If unparsed.length = 0 Return ""
            char = unparsed[..1]
            Select char
            Case "~r"   ' CR
                unparsed = unparsed[1..]
            Case "~n"   ' LF
                linenum :+1
                linepos = 1
                unparsed = unparsed[1..]
            Case " ","~t"
                linepos:+1
                unparsed = unparsed[1..]
            End Select
        Until Not Instr( SYM_WHITESPACE, char )
        Return char
    End Method

    ' Skips leading whitespace and Pops next character
    Method PopChar:String()
        Local char:String
        Repeat
            If unparsed.length = 0 Return ""
            char = unparsed[..1]
            Select char
            Case "~r"   ' CR
                unparsed = unparsed[1..]
            Case "~n"   ' LF
                linenum :+ 1
                linepos = 1
                unparsed = unparsed[1..]
            Default
                linepos :+ 1
                unparsed = unparsed[1..]
            End Select
        Until Not Instr( SYM_WHITESPACE, char )
        Return char
    End Method

    Method ExtractIdent:String()
        Local text:String
        Local char:String = peekChar()
        While Instr( SYM_ALPHA, char ) And char<>""
            text :+ popChar()
            char = PeekChar()
        Wend
        Return text
    End Method

    Method ExtractNumber:String()
        Local text:String
        Local char:String = peekChar()
        While Instr( SYM_NUMBER+".", char ) And char<>""
            text :+ popChar()
            char = PeekChar()
        Wend
        Return text
    End Method

    Method ExtractString:String()
'DebugStop
        Local text:String = popChar()   ' This is the leading Quote
        Local char:String 
        Repeat
            char = PopChar()
            text :+ char
        Until char="~q" Or char=""
        Return text
    End Method

    ' Helper Functions
    Function Create:JNode()
        Return New JNode( "object", New TMap() )
    End Function

End Type

' Individual data elemement in a JSON tree
Type JNode

    Public 

    Field class:String

    Method New( class:String, value:Object )
        'logfile.write "Creating new JNode '"+class+"'='"+string(value)
        Self.class=class
        Self.value=value
    End Method
	
    Method toString:String()
		Return String(value)
	End Method

    Method toInt:Int()
		Return Int(String(value))
	End Method

    Method isValid:Int()
		Return ( class <> "invalid" )
	End Method

    Method isInvalid:Int()
		Return ( class = "invalid" )
	End Method

	' Get "string" value of a JNode object's child
	Method operator []:String( key:String )
        If class = "object"
			Local map:TMap = TMap( value )
			If map Return String( map.valueforkey(key) )
		End If
		Return ""
	End Method

    Method Stringify:String()
	
		'DebugStop
		
		Local text:String
		'If Not j Return "~q~q"
		Select class    ' JSON NODE TYPES
		Case "object"
			Local map:TMap = TMap( value )
			text :+ "{"
			If map
				For Local key:String = EachIn map.keys()
                    Local j:JNode = JNode( map[key] )
					text :+ "~q"+key+"~q:"+j.stringify()+","
				Next
				' Strip trailing comma
				If text.endswith(",") text = text[..(Len(text)-1)]
			End If
			text :+ "}"
		Case "number"
			text :+ String(value)
		Case "string"
			text :+ String(value)
		Default
			logfile.write "INVALID SYMBOL: '"+class+"'"
		End Select
		Return text
	End Method

   ' Transpose a JNode object into a Blitzmax Object using Reflection 
   Method transpose:Object( typestr:String )
        DebugLog( "Transpose() start")
        'logfile.write "JNode.Transpose()"

        ' We can only tanspose an object into a Type
        'logfile.write( "I AM TYPE: "+class )
        If class<>"object" Return Null
        
        'debuglog "Creating type "+typestr
        'logfile.write "- Creating type "+typestr
        Local typeid:TTypeId = TTypeId.ForName( typestr )
        If Not typeid
            'debuglog( "- Not a valid type" )
            'logfile.write "- Not a valid type" 
            Return Null
        End If
        Local invoke:Object = typeid.newObject()
        If Not invoke 
            'debuglog( "- Failed to create object" )
            'logfile.write "- Failed to create object"
            Return Null
        End If
    
        ' Enumerate object fields
        Local fields:TMap = New TMap()
        'debuglog( "Object fields:" )
        'logfile.write "- Enumerating objects"

        ' Add Field names and types to map
        For Local fld:TField = EachIn typeid.EnumFields()
            'debuglog( "  "+fld.name() + ":" + fld.typeid.name() )
            'logfile.write( "  "+fld.name() + ":" + fld.typeid.name() )
            fields.insert( fld.name(), fld.typeid.name() )
        Next
    
        ' Extract MAP (of JNodes) from value
        Local map:TMap = TMap( value )
        If Not map Return Null
        'logfile.write( "Map extracted from value successfully" )
        'for local key:string = eachin map.keys()
        '    logfile.write "  "+key+" = "+ JNode(map[key]).toString()
        'next

        'logfile.write( "TRANSPOSING MAP INTO OBJECT")

        For Local fldname:String = EachIn fields.keys()
            Local fldtype:String = String(fields[fldname]).tolower()
            'debuglog( "Field: "+fldname+":"+fldtype )
            'logfile.write "- Field: "+fldname+":"+fldtype
            Local fld:TField = typeid.findField( fldname )
            If fld
                'logfile.write "-- Is not null"
                Try
                    Select fldtype	' BLITZMAX TYPES
                    Case "string"
                        Local J:JNode = JNode(map[fldname])
                        If J fld.setString( invoke, J.tostring() )
                    Case "int"
                        Local J:JNode = JNode(map[fldname])
                        If J fld.setInt( invoke, J.toInt() )
                        'if J 
                        '    local fldvalue:int = J.toInt()
                        '    logfile.write fldname+":"+fldtype+"=="+fldvalue
                        '    fld.setInt( invoke, fldvalue )
                        '    logfile.write "INT FIELD SET"
                        'end if
                    Case "jnode"
                        ' This is a direct copy of JNode
                        Local J:JNode = JNode(map[fldname])
                        fld.set( invoke, J )
                    Default
                        'DebugLog( fldtype + " not currently supported by transpose" )
                        logfile.write "# ERROR: '"+fldtype+"' transpose is not supported"
                    End Select
                Catch Exception:String
                    logfile.write "#CRITICAL: Transpose exception"
                    logfile.write Exception
                End Try
            'else
                'logfile.write "-- Is null"
            End If
        Next		
        Return invoke
    End Method

    Method transpose_object_to_type( obj:Object, j:JNode )

    End Method

'		##### JSON HELPER
'		##### Old version replaced on 27 JUN 2021

    ' Set the value of a JNode
    Method set( value:String )
        ' If existing value is NOT a string, overwrite it
		If class<>"string" class="string"
		Self.value = value 
    End Method

    Method set( value:Int )
        ' If existing value is NOT a number, overwrite it
		If class<>"number" class="number"
		Self.value = String(value)
    End Method

    Method Set( route:String, value:String )
		'_set( route, value, "string" )
		Local J:JNode = find( route, True )	' Find route and create if missing
		j.set( value )
    End Method

    Method Set( route:String, value:Int )
		'_set( route, value, "number" )
		Local J:JNode = find( route, True )	' Find route and create if missing
		j.set( value )
    End Method

    Method Set( route:String, values:String[][] )
		Local J:JNode = find( route, True )	' Find route and create if missing
		For Local value:String[] = EachIn values
			'_set( route+"|"+value[0], value[1], "string" )
			If value.length=2
				Local node:JNode = J.find( value[0], True )
				node.set( value[1] )
			End If
		Next
    End Method

	Method find:JNode( route:String, createme:Int = False )
        ' Ignore empty route
        route = Trim(route)
        If route="" Return Null
		' Split up the path
        Return find( route.split("|"), createme )
	End Method
	
	Method find:JNode( path:String[], createme:Int = False )
	'DebugStop
		If path.length=0		' Found!
			Return Self
		Else
			' If child is specified then I MUST be an object right?
			Local child:JNode, map:TMap
			If class="object" ' Yay, I am an object.				
				map = TMap( value )
			Else 
				If Not createme Return Null	' Not found
				' I must now evolve into an object, destroying my previous identity!
				map = New TMap()
				class = "object"
				value = map
			End If
			' Does child exist?
			child = JNode( map.valueforkey( path[0] ) )
			If Not child 
				If Not createme Return Null ' Not found
				' Add a new child
				child = New JNode( "string", "" )
				map.insert( path[0], child )
			End If
			Return child.find( path[1..], createme )
		End If
	End Method


    Private

    Field value:Object

	Rem DEPRECIATED 27 JUN 2021
    Method _set( route:String, value:String, classtext:String="string" )
		' First off, we can only set children of object types
        ' Array is currently not supported by this function
        If class<>"object" Return
        ' Ignore empty route
        route = Trim(route)
        If route="" Return
        ' Make sure we are a valid object node
        Local map:TMap = TMap( Self.value )
        If Not map Return
        ' Split up the path
        Local path:String[] = route.split("|")
        If path.length=1 
            ' Get child node            
            Local J:JNode = JNode( map.valueforkey( path[0] ) )
            If J And J.class = classtext
                ' Update node
                J.set( value )
            Else
                ' Add or Replace existing node
                map.insert( path[0], New JNode( classtext, String(value) ))
            End If
		Else ' A path indicates that the child MUST be an "object"
            ' Get child node            
            Local J:JNode = JNode( map.valueforkey( path[0] ) )
			If J And J.class = "object"
				J._set( "|".join( path[1..] ), value, classtext )
			Else ' Add or replace existing node
				J = New JNode( "object", New TMap() )
				map.insert( path[0], J )
				J._set( "|".join( path[1..] ), value, classtext )
			End If
        End If
    End Method
	End Rem
	
End Type

Type JToken
    Field symbol:String, value:String, line:Int, pos:Int

    Method New( symbol:String, value:String, line:Int, pos:Int )
        'print( "## "+symbol+", "+value+", "+line+", "+pos )
        Self.symbol = symbol
        Self.value = value
        Self.line = line
        Self.pos = pos 
    End Method
End Type