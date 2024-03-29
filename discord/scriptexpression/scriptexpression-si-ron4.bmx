SuperStrict
Framework Brl.StandardIO
Import Brl.Map
Import Brl.StringBuilder
Import brl.retro	' Hex() in SToken.reveal()

Rem
${.functionName:param1:${.otherFunctionName:param1:param2}}

${.roleName:&quot;die-guid-von-interesse&quot;}
${.roleLastName:&quot;die-guid-von-interesse&quot;}

${.roleLastName:${.castGUID:1}}
-> castGUID:1 -> cast 1 abrufen und dessen GUID ist das Ergebnis
-> roleLastName:ErgebnisGUID -> role "ErgebnisGUID" abrufen und dessen LastName ist das Ergebnis

${.gt:${.worldtimeYear}:2022:&quot;nach 2022&quot;:&quot;2022 oder eher&quot;}
End Rem


Global ScriptExpression:TScriptExpression = New TScriptExpression
Function GetScriptExpressionFunctionHandler:TSEFN_Handler( functionName:String )
	Return ScriptExpression.GetFunctionHandler( functionName )
End Function

	
Const SYM_SPACE:Int 		= 32	' space
Const SYM_DQUOTE:Int 		= 34	' "
Const SYM_DOLLAR:Int		= 36	' $
Const SYM_LPAREN:Int		= 40	' (
Const SYM_RPAREN:Int		= 41	' )
Const SYM_HYPHEN:Int 		= 45	' -
Const SYM_PERIOD:Int 		= 46	' .
Const SYM_COLON:Int 		= 58	' :
Const SYM_BACKSLASH:Int 	= 92	' \
Const SYM_UNDERSCORE:Int	= 95	' _
Const SYM_LBRACE:Int		= 123	' {
Const SYM_RBRACE:Int		= 125	' }

Const TK_EOF:Int 			= 0		' End of File
Const TK_IDENTIFIER:Int		= 1		' Identifier (STRING)
Const TK_NUMBER:Int 		= 2		' Number
Const TK_QSTRING:Int 		= 3		' Quoted String
Const TK_FUNCTION:Int 		= 4		' Function
Const TK_BOOLEAN:Int 		= 5		' Boolean identifiers (true/false)

Const TK_TAB:Int 			= 9		' /t
Const TK_LF:Int 			= 10	' /n
Const TK_CR:Int 			= 13	' /r


Function TokenName:String( id:Int )
	Select id
		Case TK_EOF;		Return "EOF"
		Case TK_IDENTIFIER;	Return "Identifier"
		Case TK_NUMBER;		Return "Number"
		Case TK_QSTRING;	Return "String"
		Case TK_FUNCTION;	Return "Function"
		Case TK_BOOLEAN;	Return "Bool"
		Default
			Return "n/a ("+id+")"
	End Select
End Function




Struct STokenGroup
	Field staticArray token:SToken[10]
	Field dynamicToken:SToken[]
	Field added:Int
	
	Method GetToken:SToken(index:int)
		if index < token.length
			return token[index]
		elseif index < dynamicToken.length - token.length
			return dynamicToken[dynamicToken.length - token.length]
		EndIf
	End Method


	Method AddToken(s:SToken)
		if added < token.length
			token[added] = s
		elseif added < dynamicToken.length + token.length
			dynamicToken[added - token.length] = s
		EndIf
		added :+ 1
	End Method


	Method SetToken(index:int, s:SToken)
		if index < token.length
			token[index] = s
		elseif index < dynamicToken.length + token.length
			dynamicToken[index - token.length] = s
		EndIf
	End Method
End Struct




Struct SToken
	Field id:Int = 0
	'0=string, 1=Long, 2=int
	Field valueType:Int = 0
	Field value:String
	Field valueLong:Long
	Field valueDouble:Double
	Field linenum:Int, linepos:Int
	
	Method New( id:Int, value:String, linenum:Int, linepos:Int = 0 )
		Self.id = id
		Self.value = value
		Self.valueType = 0
		Self.linenum = linenum
		Self.linepos = linepos
	End Method

	Method New( id:Int, valueLong:Long, linenum:Int, linepos:Int = 0 )
		Self.id = id
		Self.valueLong = valueLong
		Self.valueType = 1
		Self.linenum = linenum
		Self.linepos = linepos
	End Method

	Method New( id:Int, valueDouble:Double, linenum:Int, linepos:Int = 0 )
		Self.id = id
		Self.valueDouble = valueDouble
		Self.valueType = 2
		Self.linenum = linenum
		Self.linepos = linepos
	End Method
	
	
	Method CompareWith:Int(other:SToken)
		Local r:Double
		If self.valueType = 1
			If other.valueType = 1
				r = self.valueLong - other.valueLong
			ElseIf other.valueType = 2
				r = self.valueLong - other.valueDouble
			EndIf
		ElseIf self.valueType = 2
			If other.valueType = 1
				r = self.valueDouble - other.valueLong
			ElseIf other.valueType = 2
				r = self.valueDouble - other.valueDouble
			EndIf
		ElseIf self.valueType = 0
			If self.value > other.value
				r = 1
			ElseIf self.value = other.value
				r = 1
			Else
				r = -1
			EndIf
		EndIf

		If r > 0
			Return 1
		Elseif r = 0
			Return 0
		Else
			Return -1
		EndIf
	End Method


	Method GetValueText:String()
		Select valueType
			case 0
				Return value
			case 1
				Return valueLong
			case 2
				Return valueDouble
		End Select
	End Method


	' Debugging
	Method reveal:String()
		Select valueType
			case 0
				Return "h"+Hex(id)+" = '"+value+"' (string, " + TokName()+") at ["+linenum+","+linepos+"]"
			case 1
				Return "h"+Hex(id)+" = '"+valueLong+"' (long, " + TokName()+") at ["+linenum+","+linepos+"]"
			case 2
				Return "h"+Hex(id)+" = '"+valueDouble+"' (double, " + TokName()+") at ["+linenum+","+linepos+"]"
		End Select
	End Method

	
	Method TokName:String()
		Return TokenName( id )
	End Method
End Struct




Type TParseException
	Field error:String
	Field linenum:Int
	Field linepos:Int
	Field extra:String

	Method New( error:String, linenum:Int, linepos:Int, extra:String )
		Self.error = error
		Self.linenum = linenum
		Self.linepos = linepos
		Self.extra = extra
	End Method

	Method New( error:String, token:SToken, extra:String )
		Self.error = error
		Self.linenum = token.linenum
		Self.linepos = token.linepos
		Self.extra = extra
	End Method


	Method reveal:String()
		Local str:String = error + " at " + linenum + ":" + linepos
		If extra Then str :+ " ("+extra+")"
		Return Str
	End Method
End Type




Type TScriptExpression
	Field functionHandlers:TStringMap = New TStringMap()


	Method Parse:SToken( expression:String, context:Object[] = Null)
		'DebugStop
		Local parser:SScriptExpressionParser = New SScriptExpressionParser( expression, context )
		Try
			Return parser.readWrapper()
		Catch e:TParseException
			DebugLog e.reveal()
		End Try
		Return New SToken( TK_BOOLEAN, False, 0, 0 )
	End Method


	Method RegisterFunctionHandler( functionName:String, callback:SToken(params:STokenGroup var, context:Object = Null), paramMinCount:Int = -1, paramMaxCount:Int = -1)
		functionHandlers.Insert( functionName.ToLower(), New TSEFN_Handler(callback, paramMinCount, paramMaxCount))
	End Method


	Method GetFunctionHandler:TSEFN_Handler( functionName:String )
		Return TSEFN_Handler( functionHandlers.ValueForKey( functionName.ToLower() ))
	End Method


	Method GetVariableContent:String(variableKey:String, result:Int Var)
		result = True
		Return variableKey
	End Method


	'returns how many elements in the passed array are "true"
	Function _CountTrueValues:Int(tokens:STokenGroup var, startIndex:Int = 0)
		If tokens.added = 0 Then Return 0

		Local trueCount:Int 
		For Local i:Int = startIndex Until tokens.added
			Local t:SToken = tokens.GetToken(i)
			Select t.id
				Case TK_NUMBER
					If t.valueType = 1 And t.valueLong > 0
						trueCount :+ 1
					ElseIf t.valueType = 2 And t.valueDouble > 0
						trueCount :+ 1
					EndIf
				Case TK_IDENTIFIER
					If t.value Then trueCount :+ 1
				Case TK_QSTRING
					If t.value Then truecount :+ 1
				Case TK_BOOLEAN
					' OPTIMISE: See "counter-on-string-value.bmx"
					' RESULT:   String compare quicker in production
?debug
					truecount :+ t.valueLong			' Quicker in Debug
?Not debug
					If t.valueLong = 1 Then truecount :+ 1	' Quicker in Production
?
			EndSelect
		Next
	
		'count = 0: none true,
		'0 < count < arr.length: not all are true (but at least one)
		'count = arr.length: all true
		Return trueCount
	End Function	


	Function _IsTrueValue:Int(t:SToken var)
		Select t.id
			Case TK_NUMBER
				If t.valueType = 1 and t.valueLong > 0
					Return 1
				ElseIf t.valueType = 2 and t.valueDouble > 0
					Return 1
				EndIf
			Case TK_IDENTIFIER
				If t.value Then Return 1
			Case TK_QSTRING
				If t.value Then Return 1
			Case TK_BOOLEAN
'?debug
'				Return t.valueLong			' Quicker in Debug
'?Not debug
				If t.valueLong = 1 Then Return 1	' Quicker in Production
'?
		End Select
	
		Return 0
	End Function	


	'returns how many elements are equal to the first passed value
	Function _CountEqualValues:Int(tokens:STokenGroup var, startIndex:Int = 0)
		If tokens.added = 0 Then Return 0

		Local equalCount:Int = 1 'is equal with itself
		Local firstT:SToken = tokens.GetToken(startIndex)
		if firstT.id = TK_NUMBER or firstT.id = TK_BOOLEAN
			if firstT.valueType = 1 
				For Local i:Int = startIndex + 1 Until tokens.added
					Local t:SToken = tokens.GetToken(i)
					If t.id = firstT.id And ((t.valueType = 1 and t.valueLong = firstT.valueLong) or (t.valueType = 2 and t.valueDouble = firstT.valueLong))
						equalCount :+ 1
					EndIf
				Next
			ElseIf firstT.valueType = 2
				For Local i:Int = startIndex + 1 Until tokens.added
					Local t:SToken = tokens.GetToken(i)
					If t.id = firstT.id And ((t.valueType = 1 and t.valueLong = firstT.valueDouble) or (t.valueType = 2 and t.valueDouble = firstT.valueDouble))
						equalCount :+ 1
					EndIf
				Next
			EndIf
		Else
			For Local i:Int = startIndex + 1 Until tokens.added
				Local t:SToken = tokens.GetToken(i)
				If t.id = firstT.id And t.value = firstT.value Then 
					equalCount :+ 1
				'Else
				'	If String(objects[i]) = String(objects[0]) Then equalCount :+ 1
				EndIf
			Next
		EndIf
		Return equalCount
	End Function
End Type




' Expression Tokeniser
Struct SScriptExpressionLexer
	Field cursor:Int
	Field linenum:Int
	Field linepos:Int
	Field expression:String

	
	Method New( expression:String )
		Self.expression = expression	'New TStringBuilder( expression )
		cursor = 0
		linenum = 0
		linepos = 0
	End Method
	
	Private

	Method PeekChar:Int()
		If cursor >= expression.length Then Return 0
		Return expression[ cursor ]
	End Method

	' Pops next character moving the cursor forward
	Method PopChar:Int()
		If cursor >= expression.length Then Return TK_EOF
		Local ch:Int = expression[ cursor ]
		' Move the cursor forward
		If ch = TK_LF	' \n
			linenum :+ 1
			linepos = 1
			cursor :+ 1
		Else
			linepos :+ 1
			cursor :+ 1
		End If
		Return ch
	End Method


	' Retrieves the current token (At the cursor)
	Method GetNext:SToken()
		Repeat
			Local ch:Int = PeekChar()

			Select True
				' End of file
				Case ch = 0
					Return New SToken( TK_EOF, 1, linenum, linepos )

				' Whitespace or control codes
				Case ch <= SYM_SPACE Or ch >=126
					PopChar()

				' QUOTED STRING
				Case ch = SYM_DQUOTE
					Return New SToken( TK_QSTRING, ExtractQuotedString(), linenum, linepos )

				' NUMBER
				Case ch = 45 Or ( ch >= 48 And ch <= 57 )
					Local valueLong:Long, valueDouble:Double, valueType:Int
					valueType = ExtractNumber(valueLong, valueDouble)
					If valueType = 1
						Return New SToken( TK_NUMBER, valueLong, linenum, linepos )
					ElseIf valueType = 2
						Return New SToken( TK_NUMBER, valueDouble, linenum, linepos )
					EndIf

				' LETTER
				Case ( ch >=97 And ch <= 122 ) Or ( ch >= 65 And ch <=90 )
					Local ident:String = ExtractIdent()
'rem
					If ident.length = 4 and ident[0] = Asc("t") and ident[1] = Asc("r") and ident[2] = Asc("u") and ident[3] = Asc("e")
						Return New SToken( TK_BOOLEAN, True, linenum, linepos )
					ElseIf ident.length = 5 and ident[0] = Asc("f") and ident[1] = Asc("a") and ident[2] = Asc("l") and ident[3] = Asc("s") and ident[4] = Asc("e")
						Return New SToken( TK_BOOLEAN, False, linenum, linepos )
					Else
					'print "ident ~q"+ident+"~q"
						Return New SToken( TK_IDENTIFIER, ident, linenum, linepos )
					EndIf
'endrem
rem
					lowerCaseCount :+ 1
					Local s:String = ident.toLower()
					Select s
					Case "true"
						Return New SToken( TK_BOOLEAN, True, linenum, linepos )
					Case "false"
						Return New SToken( TK_BOOLEAN, False, linenum, linepos )
					Default
						Return New SToken( TK_IDENTIFIER, ident, linenum, linepos )
					End Select
endrem

				' SYMBOLS
				Default ' ch = SYM_COLON Or ch = SYM_PERIOD
					Return New SToken( ch, PopChar(), linenum, linepos )
			End Select	
		Forever
	End Method
		

	' Identifier starts with a letter, but can contain "_" and numbers
	Method ExtractIdent:String()
		Local start:Int = cursor
		If cursor = expression.length Then Return ""

		Local ch:Int = expression[cursor]
		While ch = SYM_UNDERSCORE ..
			Or ( ch >= 48 And ch <= 57 ) ..     ' NUMBER
			Or ( ch >= 65 And ch <= 90 ) ..     ' UPPERCASE
			Or ( ch >= 97 And ch <= 122 )       ' LOWERCASE
			cursor :+ 1
			If cursor = expression.length Then exit

			ch = expression[cursor]
		Wend
		Return expression[ start..cursor ]
	End Method


	Method ExtractNumber:Int(longValue:Long var, doubleValue:Double var)
		longValue = 0
		doubleValue = 0
		If cursor = expression.length Then Return False

		'DebugStop
		Local negative:Int = False
		Local decimalDivider:long=10
		Local ch:Int = PeekChar()

		' Leading "-" (Negative number)
		If ch = SYM_HYPHEN	
			negative = True
			cursor :+ 1
			ch = PeekChar()
		End If
		' Number
		While ch<>0 And ( ch>=48 And ch<=57 )
			longValue = longValue * 10 + (ch-48)
			cursor :+ 1
			ch = PeekChar()
		Wend

		' Decimal
		If ch = SYM_PERIOD
			doubleValue = longValue
			cursor :+ 1
			ch = PeekChar()
			While ch<>0 And ( ch>=48 And ch<=57 ) and decimalDivider < 10000000000:Long
				doubleValue :+ Double(ch-48) / decimalDivider
				decimalDivider :* 10
				cursor :+ 1
				ch = PeekChar()
			Wend
			if negative then doubleValue :* -1
			Return 2
		End If
		if negative then longValue :* -1
		Return 1
	End Method


	' Identifier starts with a letter, but can contain "_" and numbers
	Method ExtractQuotedString:String()
		' Skip leading quote
		cursor :+ 1
		
		Local start:Int = cursor
		While expression[cursor] <> TK_EOF And expression[cursor] <> SYM_DQUOTE
			'escape next
			If expression[cursor] = Asc("\") Then cursor :+ 1
			cursor :+ 1
		Wend
		'do not include trailing quote, so subtract in slice again
		cursor :+ 1

		Return expression[ start..cursor - 1].Replace("\~q","~q")
	End Method
End Struct



' Expression Parser
Struct SScriptExpressionParser
	Field context:Object
	Field lexer:SScriptExpressionLexer
	' Current token
	Field token:SToken
	

	Method New( expression:String, context:Object )
		Self.context = context
		lexer = New SScriptExpressionLexer( expression )
		
		' Read first token
		advance()
	End Method


	' Read a readWrapper ${..}
	Method readWrapper:SToken()
		'DebugStop
		Local result:STokenGroup
		' Skip leading Dollar symbol and Opening Brace
		eat( SYM_DOLLAR )
		eat( SYM_LBRACE )

		' Termination
		If token.id = TK_EOF Then Throw( New TParseException( "Unexpected end", token, "readWrapper()" ) )
		' Empty Wrapper
		If token.id = SYM_RBRACE Then Throw( New TParseException( "Empty group", token, "readWrapper()" ) )
		
		' Next are one or more arguments
		Repeat	
			Select token.id
				Case TK_EOF
					Throw New TParseException( "Unexpected end of expression", token, "readWrapper().params" )

				Case SYM_DOLLAR
					result.AddToken(readWrapper())
					'DebugStop

					advance()

				Case SYM_PERIOD
					' Strip function identifier 
					eat( SYM_PERIOD )

					If token.id <> TK_IDENTIFIER Then Throw New TParseException( "Identifier expected", token, "readWrapper()" )
					token.id = TK_FUNCTION
					result.AddToken(token)

					advance()

				Case TK_IDENTIFIER, TK_QSTRING, TK_NUMBER, TK_BOOLEAN
					result.AddToken(token)

					advance()

				Default
					DebugLog( "ReadWrapper() ["+token.id+"] "+token.GetValueText()+", error" )
					Throw New TParseException( "Unexpected token", token, "readWrapper()" )
			End Select
			
			' If we have finished, evaluate the wrapper returning the result
			If token.id = SYM_RBRACE Then Return eval( result )
			
			' Next should be a ":"
			eat( SYM_COLON )
		Forever			
	End Method

	
	' Advances the token
	Method advance()
		'DebugStop
		token = lexer.getNext()
		'DebugStop
	End Method


	' Consume an expected symbol.
	' If symbol does not exist, create a missing node in it's place
	Method eat:SToken( expectation:Int ) 
		If token.id = expectation
			'DebugStop
			advance()
			Return token
		EndIf

		Throw New TParseException( token.GetValueText() + " was unexpected", token, "eat()" )
	End Method		


	Method eval:SToken( tokens:STokenGroup var )
		Local firstToken:SToken = tokens.GetToken(0)
		Select firstToken.id
			Case TK_FUNCTION
				'DebugStop
				Local fn:TSEFN_Handler = GetScriptExpressionFunctionHandler( firstToken.value )
				If Not fn Then Throw New TParseException( "Undefined function "+firstToken.value, firstToken, "eval()" )

				Return fn.run( tokens, context )

			Case TK_IDENTIFIER, TK_BOOLEAN, TK_NUMBER
				If tokens.added > 1 Then Throw New TParseException( "Invalid parameters", tokens.GetToken(1), "eval()" )

				Return firstToken
		End Select
	End Method
End Struct




Type TSEFN_Handler
	Field paramMinCount:Int = -1
	Field paramMaxCount:Int = -1
	Field callback:SToken(params:STokenGroup var, context:Object = Null)

	Method New(callback:SToken( params:STokenGroup var, context:Object = Null), paramMinCount:Int, paramCount:Int)
		Self.callback = callback
		Self.paramMinCount = paramMinCount
		Self.paramMaxCount = paramMaxCount
	End Method


	Method Run:SToken(params:STokenGroup var, context:Object = Null)
		If callback Then Return callback(params, context)
	End Method
End Type




'register defaults
Function SEFN_Or:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountTrueValues(params, 1) > 0), first.linenum, first.linepos )
End Function

Function SEFN_And:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountTrueValues(params, 1) = params.added - 1), first.linenum, first.linepos )
End Function

Function SEFN_Not:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountTrueValues(params, 1) = 0), first.linenum, first.linepos )
End Function

Function SEFN_If:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added > 1
		Local t:SToken = params.GetToken(1)
		If TScriptExpression._IsTrueValue(t)
			' Expression is TRUE
			If params.added < 3
				Return New SToken( TK_BOOLEAN, True, first.linenum, first.linepos )
			Else
				Return params.GetToken(2)
			EndIf
		Else
			' Expression is FALSE
			If params.added < 4
				Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
			Else
				Return params.GetToken(3)
			EndIf
		EndIf
	EndIf
End Function

Function SEFN_Eq:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountEqualValues(params, 1) = params.added - 1), first.linenum, first.linepos )
End Function

Function SEFN_Gt:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) > 0), first.linenum, first.linepos )
End Function

Function SEFN_Gte:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) >= 0), first.linenum, first.linepos )
End Function

Function SEFN_Lt:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) < 0), first.linenum, first.linepos )
End Function

Function SEFN_Lte:SToken(params:STokenGroup var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) <= 0), first.linenum, first.linepos )
End Function


ScriptExpression.RegisterFunctionHandler( "not", SEFN_Not, 1, -1)
ScriptExpression.RegisterFunctionHandler( "and", SEFN_And, 1, -1)
ScriptExpression.RegisterFunctionHandler( "or",  SEFN_Or,  1, -1)
ScriptExpression.RegisterFunctionHandler( "if",  SEFN_If,  1,  3)
ScriptExpression.RegisterFunctionHandler( "eq",  SEFN_Eq,  1, -1)
ScriptExpression.RegisterFunctionHandler( "gt",  SEFN_Gt,  2,  2)
ScriptExpression.RegisterFunctionHandler( "gte", SEFN_Gte, 2,  2)
ScriptExpression.RegisterFunctionHandler( "lt",  SEFN_Lt,  2,  2)
ScriptExpression.RegisterFunctionHandler( "lte", SEFN_Lte, 2,  2)



' test functionality
Print "Tests"

Function expect( test:String, expected:String, token:Int )
	Local result:SToken = ScriptExpression.Parse(test)
	If result.id = token And (result.value = expected or (result.valueType = 1 and result.valueLong = expected) or (result.valueType = 2 and result.valueDouble = expected)) 
		Print "~n" + test + " -> " + "SUCCESS  ["+result.TokName()+"] '"+expected+"'"
	Else
		Print "~n" + test + " -> " + "FAILURE  ["+result.TokName()+"] '" + result.GetValueText() + "', expected ["+TokenName(token)+"] '"+expected+"' )"
	End If
End Function

rem
Local se:SScriptExpressionLexer = New SScriptExpressionLexer("1.2345678")
Local valueLong:Long, valueDouble:Double, valueType:Int
valueType = se.ExtractNumber(valueLong, valueDouble)
print "valueLong="+valueLong
print "valueDouble="+valueDouble
print "valueType="+valueType
endrem


'Local test:String

'test = "${.or:${~qhello }~q  }:${  ${0}   }" 'misses } ... incomplete oh noooo!
'print test + "  ->  " + ScriptExpression.Parse(test) + " = 1 ??"
'test = "${.or:${~qhello }~q  }:${  ${0}   }}"

' Incomplete / BAD
'#expect( "${.or:${~qhello }~q  }:${  ${0}   }", "1" )

DebugStop
expect( "${.or:~qhello~q:${0}}", "1", TK_BOOLEAN )
expect( "${.if:${.or:~qhello~q:${0}}:~qTrue~q:~qFalse~q}", "True", TK_QSTRING )
expect( "${.if:1:~qTrue~q:~qFalse~q}", "True", TK_QSTRING )
' Additonal test [SCAREMONGER]
DebugStop
expect( "${.if:1:True:False}", True, TK_BOOLEAN )
'DebugStop
expect( "${.if:1:~q\~qTrue\~q~q:~qFalse~q}", "~qTrue~q", TK_QSTRING )	' Test escaped quote
expect( "${.if:${.not:1}:~qTrue~q:~qFalse~q}", "False", TK_QSTRING )
expect( "${.eq:1:2:1}", "0", TK_BOOLEAN )
'DebugStop
expect( "${.eq:1:1:1}", "1", TK_BOOLEAN )
expect( "${.gt:4:0}", "1", TK_BOOLEAN )
expect( "${.gt:0:4}", "0", TK_BOOLEAN )
expect( "${.gte:4:4}", "1", TK_BOOLEAN )


'Local expr2:String = "${.and:${.gte:4:4}:${.gte:5:4}}"
Local expr2:String = "${.if:${.and:${.gte:4:4}:${.gte:5:4}}:~qis true~q:~qis false~q}"
print expr2
print "Parse : " + ScriptExpression.Parse(expr2).GetValueText()

'end

'Global bbGCAllocCount:ULong = 0
Extern
    Global bbGCAllocCount:ULong="bbGCAllocCount"
End Extern

Local time:Int = MilliSecs()
Local expr:String = "${.and:${.gte:4:4}:${.gte:5:4}}"
Local allocs:Int

Print "~nTIMINGS:"
Print "expression: "+ScriptExpression.Parse(expr).GetValueText()
allocs = bbGCAllocCount
For Local i:Int = 0 Until 1000000
	ScriptExpression.Parse(expr)
Next
time = (MilliSecs() - time)
Print "took: " + time +" ms. Allocs=" + (bbGCAllocCount - allocs)

Rem
expr = "4 >= 4 && 5 >= 4"
'expr = "(4 >= 4) && (5 >= 4)" 'even slower
'Print GetScriptExpression().Eval(expr)
allocs = bbGCAllocCount
t = MilliSecs()
For Local i:Int = 0 Until 1000000
	GetScriptExpression().Eval(expr)
Next
Print "took: " + (MilliSecs() - t) +" ms. Allocs=" + (bbGCAllocCount - allocs)
End Rem

'print ScriptExpression.Parse("${.or:1:2}") + " = 1"
'print ScriptExpression.Parse("${.or:0:~q~q}") + " = 0"
Print "Done."

