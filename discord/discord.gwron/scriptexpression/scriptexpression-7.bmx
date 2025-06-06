SuperStrict
' VERSION 7.2, 22 JUN 2024

Framework Brl.StandardIO
Import Brl.Map
Import Brl.StringBuilder
Import brl.retro	' Hex() in SToken.reveal()

Rem VERSION 7.2 / Scaremonger (Si) / 22 JUN 2024
* Created function SEFN_DaynameShort()
* Created function SEFN_DaynameFull()
* Registered function SEFN_DaynameShort() as "dayshort"
* Registered function SEFN_DaynameFull() as "dayname"
* Added day of week variables to Scaremonger_variableHandlerCB()
* Added new test.
EndRem

Rem VERSION 7.1 / Scaremonger (Si) / 1 JUN 2024
* Added Constants for SYM_LSS, SYM_EQUAL, SYM_GTR and TK_OPERATOR
* Updated TokenName() to return "Operator" for TK_OPERATOR
* Updated SScriptExpressionLexer.getNext() to detect "<", "=", ">", "==", "<=", "<>", ">=" tokens
* Split SScriptExpressionParser.readWrapper() into readStatement(), readBlock() and readFunction()
* Updated SScriptExpressionParser.readBlock() to add TK_OPERATOR
* Added STokenGroup.New()
* Added STokenGroup.GetTokenGroup()
* Added STokenGroup.reveal() for debugging
* Created function SEFN_NEq()
* Created function SEFN_Hour()
* Registered function SEFN_Eq() as "=="
* Registered function SEFN_Gt() as ">"
* Registered function SEFN_Gte() as ">="
* Registered function SEFN_Lt() as "<"
* Registered function SEFN_Lte() as "<="
* Registered function SEFN_NEq() as "<>"
* Registered function SEFN_Hour() as "hour"

NOTE ON PARSING:

	root       <- "$" wrapper
	wrapper    <- "{" expression "}"
	expression <- (block ":")* block
	block      <- (expression|function|identifier|qstring|number|boolean|variable) (operator block)?
	operator   <- ("<"|">" "=")|"<>"|"=="
	function   <- "." identifier
	identifier <- [a-zA-Z]*
	qstring    <- '"' (!'"')* '"'
	number     <- "-"? [0-9]* ("." [0-9]*)
	boolean    <- true|false
	variable   <- [0-9]*
	
EndRem

Rem VERSION 6 CHANGES / Scaremonger (Si)
* Moved try-catch from parse() and parsetext() up into expect()
* Modified GetToken() to parse SYM_PERIOD followed by an identifier as a TK_FUNCTION, freeing up identifers to be variables.
* Modified readWrapper() to process TK_FUNCTION instead of SYM_PERIOD
* Modifier readWrapper() to process TK_IDENTIFIER seperate from TK_QSTRING, TK_NUMBER and TK_BOOLEAN
* Added TScriptExpressionConfig argument to SScriptExpressionParser.new() so it can access field "config"
* Fixed bug in getNext() where 4 character identifiers were mis-read.
* Fixed bug with escaped quotes in ExtractQuotedString()
End Rem

Rem
${.functionName:param1:${.otherFunctionName:param1:param2}}

${.roleName:&quot;die-guid-von-interesse&quot;}
${.roleLastName:&quot;die-guid-von-interesse&quot;}

${.roleLastName:${.castGUID:1}}
-> castGUID:1 -> cast 1 abrufen und dessen GUID ist das Ergebnis
-> roleLastName:ErgebnisGUID -> role "ErgebnisGUID" abrufen und dessen LastName ist das Ergebnis

${.gt:${.worldtimeYear}:2022:&quot;nach 2022&quot;:&quot;2022 oder eher&quot;}
End Rem

Const SYM_SPACE:Int 		= 32	' space
Const SYM_DQUOTE:Int 		= 34	' "
Const SYM_DOLLAR:Int		= 36	' $
Const SYM_LPAREN:Int		= 40	' (
Const SYM_RPAREN:Int		= 41	' )
Const SYM_HYPHEN:Int 		= 45	' -
Const SYM_PERIOD:Int 		= 46	' .
Const SYM_COLON:Int 		= 58	' :
Const SYM_LSS:Int 			= 60	' <
Const SYM_EQUAL:Int 		= 61	' =
Const SYM_GTR:Int 			= 62	' >
Const SYM_BACKSLASH:Int 	= 92	' \
Const SYM_UNDERSCORE:Int	= 95	' _
Const SYM_LBRACE:Int		= 123	' {
Const SYM_RBRACE:Int		= 125	' }

Const TK_ERROR:Int			= -1	' Invalid token / Error condition
Const TK_EOF:Int 			= 0		' End of File
Const TK_IDENTIFIER:Int		= 1		' Identifier (STRING)
Const TK_NUMBER:Int 		= 2		' Number
Const TK_QSTRING:Int 		= 3		' Quoted String
Const TK_FUNCTION:Int 		= 4		' Function
Const TK_BOOLEAN:Int 		= 5		' Boolean identifiers (true/false)
Const TK_TEXT:Int 			= 6		' Text String
Const TK_OPERATOR:Int 		= 7		' Operator "<","=",">","<=", ">=","<>"

Const TK_TAB:Int 			= 9		' /t
Const TK_LF:Int 			= 10	' /n
Const TK_CR:Int 			= 13	' /r

Function TokenName:String( id:Int )
	If id<32
		Select id
			Case TK_ERROR;	Return "Error"
			Case TK_EOF;		Return "EOF"
			Case TK_IDENTIFIER;	Return "Identifier"
			Case TK_NUMBER;		Return "Number"
			Case TK_TEXT;		Return "Text"
			Case TK_QSTRING;	Return "String"
			Case TK_FUNCTION;	Return "Function"
			Case TK_BOOLEAN;	Return "Bool"
			Case TK_TAB;		Return "TAB"
			Case TK_LF;			Return "LF"
			Case TK_CR;			Return "CR"
			Case TK_OPERATOR;   Return "Operator"
		Default
			Return "n/a ("+id+")"
		End Select
	Else
		Return "CHR='"+Chr(id)+"'"
	End If
End Function

Struct STokenGroup
	Field StaticArray token:SToken[10]
	Field dynamicToken:SToken[]
	Field added:Int
	
	' Creates a Token group seeded with it's first member
	Method New( token:SToken )
		addToken( token )
	End Method
	
	Method GetToken:SToken(index:Int)
		If index < token.Length
			Return token[index]
		ElseIf index < dynamicToken.Length - token.Length
			Return dynamicToken[dynamicToken.Length - token.Length]
		EndIf
	End Method

	' Identical to GetToken, except it returns a new group
	' containing only the requested token. This is used when calling
	' a function when you only have the name and no arguments.
	Method GetTokenGroup:STokenGroup(index:Int)
		If index < token.Length
			Return New STokenGroup( token[index] )
		ElseIf index < dynamicToken.Length - token.Length
			Return New STokenGroup( dynamicToken[dynamicToken.Length - token.Length] )
		EndIf
	End Method

	Method AddToken(s:SToken)
		If added < token.Length
			token[added] = s
		ElseIf added < dynamicToken.Length + token.Length
			dynamicToken[added - token.Length] = s
		EndIf
		added :+ 1
	End Method

	Method SetToken(index:Int, s:SToken)
		If index < token.Length
			token[index] = s
		ElseIf index < dynamicToken.Length + token.Length
			dynamicToken[index - token.Length] = s
		EndIf
	End Method
	
	' TokenGroup Debugging
	Method reveal:String( title:String="")
		Local str:String
		If title; str :+ title + "~n"
		For Local n:Int = 0 Until added
			str :+ n+") "+token[n].reveal()+"~n"
		Next
		Return str
	End Method
End Struct

Struct SToken
	Field id:Int = TK_ERROR
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
	
	' 27 FEB 23, SCAREMONGER: Added new constructor for errors that copy data from token
	Method New( id:Int, value:String, token:SToken )
		Self.id = id
		Self.value = value
		Self.valueType = 0
		Self.linenum = token.linenum
		Self.linepos = token.linepos
	End Method

	Method CompareWith:Int(other:SToken)
		Local r:Double
		If Self.valueType = 1
			If other.valueType = 1
				r = Self.valueLong - other.valueLong
			ElseIf other.valueType = 2
				r = Self.valueLong - other.valueDouble
			EndIf
		ElseIf Self.valueType = 2
			If other.valueType = 1
				r = Self.valueDouble - other.valueLong
			ElseIf other.valueType = 2
				r = Self.valueDouble - other.valueDouble
			EndIf
		ElseIf Self.valueType = 0
			If Self.value > other.value
				r = 1
			ElseIf Self.value = other.value
				r = 1
			Else
				r = -1
			EndIf
		EndIf

		If r > 0
			Return 1
		ElseIf r = 0
			Return 0
		Else
			Return -1
		EndIf
	End Method


	Method GetValueText:String()
		Select id
		Case TK_ERROR
			Return value
		Case TK_EOF
			Return "EOF"
		Default
			Select valueType
				Case 0
					Return value
				Case 1
					Return valueLong
				Case 2
					Return valueDouble
			End Select
		End Select
	End Method


	' Debugging
	Method reveal:String()
		If id=TK_ERROR Then Return "h"+Hex(id)+" = ERROR:"+value+" at ["+linenum+","+linepos+"]"
		Select valueType
			Case 0
				Return "h"+Hex(id)+" = '"+value+"' (string, " + TokName()+") at ["+linenum+","+linepos+"]"
			Case 1
				Return "h"+Hex(id)+" = '"+valueLong+"' (long, " + TokName()+") at ["+linenum+","+linepos+"]"
			Case 2
				Return "h"+Hex(id)+" = '"+valueDouble+"' (double, " + TokName()+") at ["+linenum+","+linepos+"]"
		End Select
	End Method

	
	Method TokName:String()
		Return TokenName( id )
	End Method
End Struct

' 27/FEB/23, SCAREMONGER, Throw returned back to Return
'Type TParseException
'	Field error:String
'	Field linenum:Int
'	Field linepos:Int
'	Field extra:String

'	Method New( error:String, linenum:Int, linepos:Int, extra:String )
'		Self.error = error
'		Self.linenum = linenum
'		Self.linepos = linepos
'		Self.extra = extra
'	End Method

'	Method New( error:String, token:SToken, extra:String )
'		Self.error = error
'		Self.linenum = token.linenum
'		Self.linepos = token.linepos
'		Self.extra = extra
'	End Method


'	Method reveal:String()
'		Local str:String = error + " at " + linenum + ":" + linepos
'		If extra Then str :+ " ("+extra+")"
'		Return Str
'	End Method
'End Type




Struct SScriptExpression
	Method Parse:SToken( expression:String, config:SScriptExpressionConfig, context:Object = Null)
		'DebugStop
		Local parser:SScriptExpressionParser = New SScriptExpressionParser( config, expression, context )
		Return parser.readWrapper()
		'Try
		'	Return parser.readWrapper()
		'Catch e:TParseException
		'	DebugLog e.reveal()
		'End Try
		'Return New SToken( TK_BOOLEAN, False, 0, 0 )
	End Method

	Method ParseText:String( expression:String, config:SScriptExpressionConfig, context:TStringMap=Null )
		Local parser:SScriptExpressionParser = New SScriptExpressionParser( config, expression, context, False )
		Return parser.expandText()
		'Try
		'	Return parser.expandText()
		'Catch e:TParseException
		'	DebugLog e.reveal()
		'	Return e.reveal()
		'End Try
	End Method


	Method GetVariableContent:String(variableKey:String, result:Int Var)
		result = True
		Return variableKey
	End Method
End Struct




Type TScriptExpression
	Global functionHandlers:TStringMap = New TStringMap()
	Field config:TScriptExpressionConfig 

	Method New()
		config = New TScriptExpressionConfig()
	End Method
		

	Method New( config:TScriptExpressionConfig )
		If Not config Then config = New TScriptExpressionConfig()	' Default!
		Self.config = config
	End Method


	Method Parse:SToken( expression:String, context:Object = Null)
		Return New SScriptExpression.Parse(expression, Self.config.s, context)
	End Method


	Method ParseText:String( expression:String, context:TStringMap=Null )
		Return New SScriptExpression.ParseText(expression, Self.config.s, context)
	End Method


	Function RegisterFunctionHandler( functionName:String, callback:SToken(params:STokenGroup Var, context:Object = Null), paramMinCount:Int = -1, paramMaxCount:Int = -1)
		functionHandlers.Insert( functionName.ToLower(), New TSEFN_Handler(callback, paramMinCount, paramMaxCount))
	End Function


	Function GetFunctionHandler:TSEFN_Handler( functionName:String )
		Return TSEFN_Handler( functionHandlers.ValueForKey( functionName.ToLower() ))
	End Function


	'returns how many elements in the passed array are "true"
	Function _CountTrueValues:Int(tokens:STokenGroup Var, startIndex:Int = 0)
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


	Function _IsTrueValue:Int(t:SToken Var)
		Select t.id
			Case TK_NUMBER
				If t.valueType = 1 And t.valueLong > 0
					Return 1
				ElseIf t.valueType = 2 And t.valueDouble > 0
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
	Function _CountEqualValues:Int(tokens:STokenGroup Var, startIndex:Int = 0)
		If tokens.added = 0 Then Return 0

		Local equalCount:Int = 1 'is equal with itself
		Local firstT:SToken = tokens.GetToken(startIndex)
		If firstT.id = TK_NUMBER Or firstT.id = TK_BOOLEAN
			If firstT.valueType = 1 
				For Local i:Int = startIndex + 1 Until tokens.added
					Local t:SToken = tokens.GetToken(i)
					If t.id = firstT.id And ((t.valueType = 1 And t.valueLong = firstT.valueLong) Or (t.valueType = 2 And t.valueDouble = firstT.valueLong))
						equalCount :+ 1
					EndIf
				Next
			ElseIf firstT.valueType = 2
				For Local i:Int = startIndex + 1 Until tokens.added
					Local t:SToken = tokens.GetToken(i)
					If t.id = firstT.id And ((t.valueType = 1 And t.valueLong = firstT.valueDouble) Or (t.valueType = 2 And t.valueDouble = firstT.valueDouble))
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





Struct SScriptExpressionConfig
	Field functionHandlerCB:TSEFN_Handler(functionName:String)
	Field variableHandlerCB:String(variableName:String, context:Object)
	Field errorHandler:String(t:String, context:Object)


	Method New( functionHandlerCB:TSEFN_Handler(functionName:String), variableHandlerCB:String(variableName:String, context:Object), errorHandler:String(t:String, context:Object) )
		Self.functionHandlerCB = functionHandlerCB
		Self.variableHandlerCB = variableHandlerCB
		Self.errorHandler = errorHandler
	End Method

	
	Method GetFunctionHandler:TSEFN_Handler(functionName:String)
		If functionHandlerCB Then Return functionHandlerCB(functionName)
		'fall back to default
		Return TScriptExpression.GetFunctionHandler(functionName)
	End Method


	' Example 
	Method EvaluateVariable( identifier:SToken Var, context:Object = Null)
		If variableHandlerCB
			identifier.value = variableHandlerCB(identifier.GetValueText(), context)
		Else
			identifier.value="<"+identifier.value+">"
		EndIf
	End Method
End Struct




Type TScriptExpressionConfig Final
	Field s:SScriptExpressionConfig
	Field sIsSet:Int

	Method New(config:SScriptExpressionConfig)
		Self.s = config
		Self.sIsSet = True
	End Method

	
	Method New( functionHandlerCB:TSEFN_Handler(functionName:String), variableHandlerCB:String(variableName:String, context:Object), errorHandler:String(t:String, context:Object) )
		Self.s = New SScriptExpressionConfig(functionHandlerCB, variableHandlerCB, errorHandler)
		Self.sIsSet = True
	End Method


	Method GetFunctionHandler:TSEFN_Handler(functionName:String)
		If sIsSet Then Return Self.s.GetFunctionHandler(functionName)
	End Method

	
	Method EvaluateVariable( identifier:SToken Var )
		If sIsSet Then Self.s.EvaluateVariable(identifier)
		'TODO: Throw exception about unset SScriptExpressionConfig
	End Method
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
		linepos = 1
	End Method
	
	Private

	Method PeekChar:Int()
		If cursor >= expression.Length Then Return 0
		Return expression[ cursor ]
	End Method

	' Pops next character moving the cursor forward
	Method PopChar:Int()
		If cursor >= expression.Length Then Return TK_EOF
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
'If ch>=60 And ch<=62; DebugStop
			' Save the line number and position so we can use it later
			Local linenumstart:Int = linenum
			Local lineposstart:Int = linepos
			'DebugStop
			Select True
				' End of file
				Case ch = 0
					Return New SToken( TK_EOF, 1, linenum, linepos )

				' Whitespace or control codes
				Case ch <= SYM_SPACE Or ch >=126
					PopChar()

				' FUNCTION
				Case ch = SYM_PERIOD
					'DebugStop
					' Strip function identifier 
					Popchar()
					'eat( SYM_PERIOD )

					Local ident:String = ExtractIdent()

					'If token.id <> TK_IDENTIFIER Then Throw New TParseException( "Identifier expected", token, "readWrapper()" )
					'token.id = TK_FUNCTION
					'result.AddToken(token)

					'advance()
					Return New SToken( TK_FUNCTION, ident, linenumstart, lineposstart )					

				' QUOTED STRING
				Case ch = SYM_DQUOTE
					Return New SToken( TK_QSTRING, ExtractQuotedString(), linenumstart, lineposstart )

				' NUMBER
				Case ch = 45 Or ( ch >= 48 And ch <= 57 )
					Local valueLong:Long, valueDouble:Double, valueType:Int
					valueType = ExtractNumber(valueLong, valueDouble)
					If valueType = 1
						Return New SToken( TK_NUMBER, valueLong, linenumstart, lineposstart )
					ElseIf valueType = 2
						Return New SToken( TK_NUMBER, valueDouble, linenumstart, lineposstart )
					EndIf

				' LETTER
				Case ( ch >=97 And ch <= 122 ) Or ( ch >= 65 And ch <=90 )
					'DebugStop
					Local ident:String = ExtractIdent()
'rem
					If ident.Length = 4 
						If ident[0] = Asc("t") And ident[1] = Asc("r") And ident[2] = Asc("u") And ident[3] = Asc("e")
							Return New SToken( TK_BOOLEAN, True, linenumstart, lineposstart )
						ElseIf ident[0] = Asc("n") And ident[1] = Asc("u") And ident[2] = Asc("l") And ident[3] = Asc("l")
							Return New SToken( TK_BOOLEAN, -1, linenumstart, lineposstart )
						EndIf
					ElseIf ident.Length = 5 And ident[0] = Asc("f") And ident[1] = Asc("a") And ident[2] = Asc("l") And ident[3] = Asc("s") And ident[4] = Asc("e")
						Return New SToken( TK_BOOLEAN, False, linenumstart, lineposstart )
					EndIf
					
					'DebugStop
					'print "ident ~q"+ident+"~q"
					Return New SToken( TK_IDENTIFIER, ident, linenumstart, lineposstart )
'endrem
Rem
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
EndRem
				
				' OPERATORS	"<", "<=", "==", ">", ">=" and "<>"
				Case ( ch >= 60 And ch <= 62)
					Local opcode:Int = popChar()
					'
					ch = peekChar()
					If opcode = SYM_LSS
						Select ch
						Case SYM_EQUAL		' LESS THAN OR EQUAL
							popChar()
							Return New SToken( TK_OPERATOR, "<=", linenumstart, lineposstart )						
						Case SYM_GTR		' NOT EQUAL
							popChar()
							Return New SToken( TK_OPERATOR, "<>", linenumstart, lineposstart )						
						Default				' LESS THAN
							Return New SToken( TK_OPERATOR, "<", linenumstart, lineposstart )
						End Select
					Else If opcode = SYM_EQUAL 
						If ch = SYM_EQUAL	' EQUAL
							popChar()
							Return New SToken( TK_OPERATOR, "==", linenumstart, lineposstart )
						Else				' ASSIGNMENT
							'Return New SToken( TK_ASSIGNMENT, "=", linenumstart, lineposstart )
							Return New SToken( TK_OPERATOR, "=", linenumstart, lineposstart )
						EndIf
					Else 'if opcode = SYM_GTR
						If ch = SYM_EQUAL	' GREATER THAN OR EQUAL
							popChar()
							Return New SToken( TK_OPERATOR, ">=", linenumstart, lineposstart )						
						Else				' GREATER THAN
							Return New SToken( TK_OPERATOR, ">", linenumstart, lineposstart )
						End If
					End If
				
				' SYMBOLS
				Default ' ch = SYM_COLON Or ch = SYM_PERIOD
					Return New SToken( ch, PopChar(), linenum, linepos )
			End Select	
		Forever
	End Method
		
	' Read text until it hits a group-wrapper '$' symbol
	Method GetBlock:String()
		'DebugStop
		Local start:Int = cursor	', finish:Int = cursor
		While cursor<expression.Length ..
			And expression[cursor] <> SYM_DOLLAR
			cursor :+ 1
			linepos :+ 1
		Wend
		'Local temp:String = expression[ start..cursor ]		
		'DebugStop
		Return expression[ start..cursor ]		
	End Method

	' SCAREMONGER / Replaced as "ch" not being updated!
	' Identifier starts with a letter, but can contain "_" and numbers
	'Method ExtractIdent:String()
	'	Local start:Int = cursor
	'	If cursor = expression.length Then Return ""
	'	Local ch:Int = expression[cursor]
	'	While ch = SYM_UNDERSCORE ..
	'		Or ( ch >= 48 And ch <= 57 ) ..     ' NUMBER
	'		Or ( ch >= 65 And ch <= 90 ) ..     ' UPPERCASE
	'		Or ( ch >= 97 And ch <= 122 )       ' LOWERCASE
	'		cursor :+ 1
	'		If cursor = expression.length Then Exit
	'	Wend
	'	Return expression[ start..cursor ]
	'End Method
	' SCAREMONGER - END
	
	' Identifier starts with a letter, but can contain "_" and numbers
	Method ExtractIdent:String()
		'DebugStop
		Local start:Int = cursor	', finish:Int = cursor
		While cursor<expression.Length ..
			And ( expression[cursor] = SYM_UNDERSCORE ..
				Or ( expression[cursor] >= 48 And expression[cursor] <= 57 ) ..		' NUMBER
				Or ( expression[cursor] >= 65 And expression[cursor] <= 90 ) ..		' UPPERCASE
				Or ( expression[cursor] >= 97 And expression[cursor] <= 122 ) ..	' LOWERCASE
			)		
			cursor :+ 1
			linepos :+ 1
		Wend
		Return expression[ start..cursor ]
	End Method

	Method ExtractNumber:Int(longValue:Long Var, doubleValue:Double Var)
		longValue = 0
		doubleValue = 0
		If cursor = expression.Length Then Return False

		'DebugStop
		Local negative:Int = False
		Local decimalDivider:Long=10
		Local ch:Int = PeekChar()

		' Leading "-" (Negative number)
		If ch = SYM_HYPHEN	
			negative = True
			cursor :+ 1
			linepos :+ 1
			ch = PeekChar()
		End If
		' Number
		While ch<>0 And ( ch>=48 And ch<=57 )
			longValue = longValue * 10 + (ch-48)
			cursor :+ 1
			linepos :+ 1
			ch = PeekChar()
		Wend

		' Decimal
		If ch = SYM_PERIOD
			doubleValue = longValue
			cursor :+ 1
			linepos :+ 1

			ch = PeekChar()
			While ch<>0 And ( ch>=48 And ch<=57 ) And decimalDivider < 10000000000:Long
				doubleValue :+ Double(ch-48) / decimalDivider
				decimalDivider :* 10
				cursor :+ 1
				linepos :+ 1
				ch = PeekChar()
			Wend
			If negative Then doubleValue :* -1
			Return 2
		End If
		If negative Then longValue :* -1
		Return 1
	End Method


	' Identifier starts with a letter, but can contain "_" and numbers
	Method ExtractQuotedString:String()
		' Skip leading quote
		'DebugStop
		popchar()
		
		Local start:Int = cursor
		While expression[cursor] <> TK_EOF And expression[cursor] <> SYM_DQUOTE
			Select True
			'escape next
			Case expression[cursor] = Asc("\")
			'DebugStop
				cursor :+ 2
				linepos :+ 2
			Case expression[cursor] = TK_LF	'\n
				linenum :+ 1
				linepos = 1
				cursor :+ 1
			Default
				linepos :+ 1
				cursor :+ 1
			End Select
		Wend
		'do not include trailing quote, so subtract in slice again
		popchar()
'		Local temp:String = expression[ start..cursor - 1].Replace("\~q","~q")
'DebugStop
		Return expression[ start..cursor - 1].Replace("\~q","~q")
	End Method
End Struct



' Expression Parser
Struct SScriptExpressionParser
	Field context:Object
	Field lexer:SScriptExpressionLexer
	' Current token
	Field token:SToken
	Field config:SScriptExpressionConfig
	Field configIsSet:Int
	
	Method New( config:SScriptExpressionConfig, expression:String, context:Object = Null, readFirst:Int = True )
		Self.config = config
		Self.configIsSet = True

		Self.context = context
		lexer = New SScriptExpressionLexer( expression )
		
		' Read first token
		' We only do this when parsing a token
		' for strings we need to use the start of line
		If readFirst Then advance()
	End Method

	Method expandText:String()
		
		Local result:String
		'DebugStop
		Repeat
			Local block:String = lexer.getBlock()
			result :+ block
			advance()
			Select token.id
				Case TK_EOF
					Return result
				Case SYM_DOLLAR
					Local token:SToken = readWrapper()
					result :+ token.GetValueText()
			End Select
		Forever
	End Method
	
	' Read a readWrapper ${..}
	Method readWrapper:SToken()
		' Skip leading Dollar symbol
		eat( SYM_DOLLAR )
		Return readStatement()
	End Method
	
	' Read Statement {..}
	Method readStatement:SToken()
		Local result:STokenGroup
		' Skip leading Opening Brace
		If token.id <> SYM_LBRACE; Return New SToken( TK_ERROR, "Expected '{'", token )
		eat( SYM_LBRACE )
		' Termination
		If token.id = TK_EOF Then Return New SToken( TK_ERROR, "Unexpected end of file", token )
		' Empty Wrapper
		If token.id = SYM_RBRACE Then Return New SToken( TK_ERROR, "Empty group", token )
		
		' Next are one or more arguments
		Repeat
			' Get next block
			'DebugStop
			Local block:SToken = readBlock()
			If block.id = TK_ERROR; Return block
			
			' V7.2, Single argument functions need to be evaluated
			If block.id = TK_FUNCTION And result.added>0
				'DebugStop
				Local func:STokenGroup = New STokenGroup()
				func.addToken( block )
				result.addToken( Eval( func ) )
			Else
				result.addToken( block )
				'Print block.reveal()
				'DebugStop
			End If
			
			' If we have finished, evaluate the wrapper and return the result
			If token.id = SYM_RBRACE Then Return eval( result )

			' Next symbol should be a colon
			eat( SYM_COLON )
			If token.id = TK_ERROR; Return block
			
		Forever			
	End Method
	
	' Read a block of tokens (Between Colons)
	Method readBlock:SToken()
		Local result:STokenGroup
		Repeat
		'Print lexer.expression
			'Print " "[..(lexer.cursor-1)]+"^  {"+lexer.linenum+":"+lexer.linepos+"} "+tokenName( token.id )
			Select token.id
				Case TK_EOF
					'Throw New TParseException( "Unexpected end of expression", token, "readWrapper().params" )
					Return New SToken( TK_ERROR, "Unexpected end of expression", token )
					
				Case SYM_DOLLAR		' Embedded Script Expression
					result.AddToken(readWrapper())
					advance()

				Case SYM_LBRACE		' Embedded function
					result.AddToken(readStatement())
					advance()

				Case TK_FUNCTION	' Function
					result.AddToken(token)
					advance()			
					
				Case TK_IDENTIFIER	' Identifiers on their own are variables!
					' Replace the identifier
					If configIsSet Then config.evaluateVariable( token ) 
					result.AddToken(token)
					advance()

				Case TK_QSTRING, TK_NUMBER, TK_BOOLEAN
					result.AddToken(token)
					advance()

				Case TK_OPERATOR
					'DebugStop
					result.AddToken(token)
					advance()

				Default
					'DebugLog( "ReadWrapper() ["+token.id+"] "+token.GetValueText()+", error" )
					'Throw New TParseException( "Unexpected token", token, "readWrapper()" )
					Return New SToken( TK_ERROR, "Unexpected token", token )
			End Select
			
			If token.id = SYM_COLON Or token.id = SYM_RBRACE Or token.id=TK_EOF
				' Single item in the block is returned as an argument
				If result.added = 1; Return result.getToken(0)
				
				' Multiple items in a block need to be evaluated
				'DebugStop
			
				' Check for an operator
				'Print result.reveal()
				'debugstop
				If result.added = 3 And result.getToken(1).id = TK_OPERATOR
					'Print result.reveal()
					'DebugStop
					' Convert operator to a function
					Local optoken:SToken = result.getToken(1)
					optoken.id = TK_FUNCTION
					Local LExpression:STokenGroup = result.GetTokenGroup(0) ' Left expression
					Local RExpression:STokenGroup = result.GetTokenGroup(2) ' Right expression
					'Print( LExpression.reveal("LEFT EXPRESSION:") )
					'Print( RExpression.reveal("RIGHT EXPRESSION:") )
					' Build new function defintion
					Local func:STokenGroup = New STokenGroup()
					func.addToken( optoken )
					func.addToken( eval( LExpression ) )	
					func.addToken( eval( RExpression ) )
					'Print func.reveal("FUNCTION:")
					'DebugStop
					Return eval(func)
				End If				
			End If
			
		Forever
		
	End Method

	' Advances the token
	Method advance()
		'DebugStop
		'Local savecursor:Int = lexer.cursor
		token = lexer.getNext()
		'Print lexer.expression
		'Print " "[..(savecursor)]+"^  {"+token.linenum+":"+token.linepos+"} "+tokenName( token.id )
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
'DebugStop
		'Throw New TParseException( token.GetValueText() + " was unexpected", token, "eat()" )
		Return New SToken( TK_ERROR, token.GetValueText() + " was unexpected", token )
	End Method		

	' Evaluate a Token group
	Method eval:SToken( tokens:STokenGroup Var )
		Local firstToken:SToken = tokens.GetToken(0)

		Select firstToken.id
			Case TK_FUNCTION
				'DebugStop
				Local fn:TSEFN_Handler
				' using an if-else here so config's GetFunctionHandler (or more likely the callback
				' there) could return Null (so "overriding" the existence of defined default functions
				' so the developer recognizes they need to implement it in their custom config)
				If configIsSet
					fn = config.GetFunctionHandler( firstToken.value ) 
				' automatic fallback only if NO config is set
				Else
					fn = TScriptExpression.GetFunctionHandler( firstToken.value )
				EndIf
				'If Not fn Then Throw New TParseException( "Undefined function "+firstToken.value, firstToken, "eval()" )
				If Not fn Then Return New SToken( TK_ERROR, "Undefined function "+firstToken.value, firstToken )

				Return fn.run( tokens, context )

			Case TK_IDENTIFIER, TK_BOOLEAN, TK_NUMBER
				'If tokens.added > 1 Then Throw New TParseException( "Invalid parameters", tokens.GetToken(1), "eval()" )
				If tokens.added > 1 Then Return New SToken( TK_ERROR, "Invalid parameters", tokens.GetToken(1) )

				Return firstToken
		End Select
	End Method

End Struct




Type TSEFN_Handler
	Field paramMinCount:Int = -1
	Field paramMaxCount:Int = -1
	Field callback:SToken(params:STokenGroup Var, context:Object = Null)

	Method New(callback:SToken( params:STokenGroup Var, context:Object = Null), paramMinCount:Int, paramCount:Int)
		Self.callback = callback
		Self.paramMinCount = paramMinCount
		Self.paramMaxCount = paramMaxCount
	End Method


	Method Run:SToken(params:STokenGroup Var, context:Object = Null)
		If callback Then Return callback(params, context)
	End Method
End Type

' Register default functions
Function SEFN_Or:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountTrueValues(params, 1) > 0), first.linenum, first.linepos )
End Function

Function SEFN_And:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountTrueValues(params, 1) = params.added - 1), first.linenum, first.linepos )
End Function

Function SEFN_Not:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountTrueValues(params, 1) = 0), first.linenum, first.linepos )
End Function

Function SEFN_If:SToken(params:STokenGroup Var, context:Object = Null)
	' Get the IF token so we can use the line number and position
	Local first:SToken = params.GetToken(0)
	
	' Process results
	If params.added > 1
		Local t:SToken = params.GetToken(1)
		'Print t.reveal()
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

Function SEFN_Eq:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	
	Print params.reveal()

	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountEqualValues(params, 1) = params.added - 1), first.linenum, first.linepos )
End Function

Function SEFN_NEq:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Return New SToken( TK_BOOLEAN, Long(TScriptExpression._CountEqualValues(params, 1) <> params.added - 1), first.linenum, first.linepos )
End Function

Function SEFN_Gt:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) > 0), first.linenum, first.linepos )
End Function

Function SEFN_Gte:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) >= 0), first.linenum, first.linepos )
End Function

Function SEFN_Lt:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) < 0), first.linenum, first.linepos )
End Function

Function SEFN_Lte:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	If params.added < 3 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Return New SToken( TK_BOOLEAN, Long(params.GetToken(1).CompareWith(params.GetToken(2)) <= 0), first.linenum, first.linepos )
End Function

'finds an array index within a string array saved in a stringmap...!
Function lookupstring:String( within:TStringMap, key:String, index:Int )
	If Not within Or Not within.contains( key ) Then Return "<null>"
	Local array:String[] = String[]( within.valueforkey( key ) )
	If array.Length < index Then Return "#"+index
	Return array[index-1]
End Function

Function SEFN_Rolename:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Local idx:Int
	'DebugStop
	
	Local within:TStringMap = TStringMap( context )
	
	If params.added > 1 Then idx = params.getToken(1).valueLong
	
	Local lookup:String = lookupString( TStringMap( context ), "rolename", idx )
	
	Return New SToken( TK_IDENTIFIER, lookup, first.linenum, first.linepos )
End Function

Function SEFN_Castname:SToken(params:STokenGroup Var, context:Object = Null)
	Local first:SToken = params.GetToken(0)
	Local idx:Int
	'DebugStop
	
	If params.added > 1 Then idx = params.getToken(1).valueLong
	
	Local lookup:String = lookupString( TStringMap( context ), "castname", idx )
	
	Return New SToken( TK_IDENTIFIER, lookup, first.linenum, first.linepos )
End Function

Function SEFN_Concat:SToken(params:STokenGroup Var, context:Object = Null)
	'DebugStop
	Local first:SToken = params.GetToken(0)
	Local result:String
	
	For Local n:Int = 1 Until params.added
		result :+ params.getToken(n).value
	Next
		
	Return New SToken( TK_TEXT, result, first.linenum, first.linepos )
End Function

Function SEFN_Hour:SToken(params:STokenGroup Var, context:Object = Null)
	'Print params.reveal("PARAMS: "+ params.added)
	'DebugStop
	Local first:SToken = params.GetToken(0)
	If params.added > 1 Then Return New SToken( TK_BOOLEAN, False, first.linenum, first.linepos )
	Local Hour:String = CurrentDate( "%H" )
	Return New SToken( TK_NUMBER, Int(hour), first.linenum, first.linepos )
End Function

' Return full day name (Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday)
' V7.2 - Scaremonger
Function SEFN_DaynameFull:SToken(params:STokenGroup Var, context:Object = Null)
'DebugStop
	Local first:SToken = params.GetToken(0)
	If params.added > 1 Then Return New SToken( TK_TEXT, "", first.linenum, first.linepos )
	Local Weekday:String = CurrentDate( "%A" )
	Return New SToken( TK_IDENTIFIER, Weekday, first.linenum, first.linepos )
End Function

' Return short day name (mon,tue,wed,thu,fri,sat,sun)
' V7.2 - Scaremonger
Function SEFN_DaynameShort:SToken(params:STokenGroup Var, context:Object = Null)
'DebugStop
	Local first:SToken = params.GetToken(0)
	If params.added > 1 Then Return New SToken( TK_TEXT, "", first.linenum, first.linepos )
	Local Weekday:String = CurrentDate( "%a" )
	Return New SToken( TK_IDENTIFIER, Weekday, first.linenum, first.linepos )
End Function

' Register the functions
' The two numbers are MInimum and Maximum number of allowed parameters
TScriptExpression.RegisterFunctionHandler( "not", SEFN_Not, 1, -1)
TScriptExpression.RegisterFunctionHandler( "and", SEFN_And, 1, -1)
TScriptExpression.RegisterFunctionHandler( "or",  SEFN_Or,  1, -1)
TScriptExpression.RegisterFunctionHandler( "if",  SEFN_If,  1,  3)
TScriptExpression.RegisterFunctionHandler( "eq",  SEFN_Eq,  1, -1)
TScriptExpression.RegisterFunctionHandler( "gt",  SEFN_Gt,  2,  2)
TScriptExpression.RegisterFunctionHandler( "gte", SEFN_Gte, 2,  2)
TScriptExpression.RegisterFunctionHandler( "lt",  SEFN_Lt,  2,  2)
TScriptExpression.RegisterFunctionHandler( "lte", SEFN_Lte, 2,  2)
TScriptExpression.RegisterFunctionHandler( "concat", SEFN_Concat, 2,  2)
TScriptExpression.RegisterFunctionHandler( "hour", SEFN_Hour, 0,  0)
TScriptExpression.RegisterFunctionHandler( "dayname", SEFN_DaynameFull, 0,  0)
TScriptExpression.RegisterFunctionHandler( "dayshort", SEFN_DaynameShort, 0,  0)
' Boolean operators
TScriptExpression.RegisterFunctionHandler( "==", SEFN_Eq,  2, 2)
TScriptExpression.RegisterFunctionHandler( ">",  SEFN_Gt,  2, 2)
TScriptExpression.RegisterFunctionHandler( ">=", SEFN_Gte, 2, 2)
TScriptExpression.RegisterFunctionHandler( "<",  SEFN_Lt,  2, 2)
TScriptExpression.RegisterFunctionHandler( "<=", SEFN_Lte, 2, 2)
TScriptExpression.RegisterFunctionHandler( "<>", SEFN_NEq, 2, 2)
' ASSIGNMENT - Reserved for future expansion
'TScriptExpression.RegisterFunctionHandler( "=", SEFN_SetVariable,  2, 2)

' TEST FUNCTIONALITY

Print "TESTS"

' sample functions (normally registered in other files with access to the
' individual elements like "TRole"
TScriptExpression.RegisterFunctionHandler( "rolename", SEFN_Rolename, 2,  2)
TScriptExpression.RegisterFunctionHandler( "castname", SEFN_Castname, 2,  2)


' make a global available TScriptExpression instance so "expect()" does not need
' to get an instance passed
Global ScriptExpressionConfig:TScriptExpressionConfig = New TScriptExpressionConfig(Null, Scaremonger_variableHandlerCB, Null)
Global ScriptExpression:TScriptExpression = New TScriptExpression( ScriptExpressionConfig )

Function expect( test:String, expected:String, token:Int, note:String="" )
	If note Then note = "  ** "+note+" **"
	'Try
		Local result:SToken = ScriptExpression.Parse( test )
		If result.id = TK_ERROR
			Print "~n" + test + " -> ERROR "+ note
			If result.linenum=0 Then Print( " "[..(result.linepos-1)]+"^  "+result.reveal() )	
		ElseIf result.id = token And (result.value = expected Or (result.valueType = 1 And result.valueLong = expected) Or (result.valueType = 2 And result.valueDouble = expected))
			Print "~n" + test + " -> SUCCESS  ["+result.TokName()+"]='"+expected+"'" + note
		Else
			Print "~n" + test + " -> FAILURE  ["+result.TokName()+"]='" + result.GetValueText() + "', expected ["+TokenName(token)+"]='"+expected+"' )" + note
		End If
	'Catch e:TParseException
	'	Print "~n" + test + " -> ERROR "+ note
	'	If e.linenum=0 Then Print( " "[..(e.linepos-1)]+"^  "+e.reveal() )
	'End Try
End Function

Rem
Local se:SScriptExpressionLexer = New SScriptExpressionLexer("1.2345678")
Local valueLong:Long, valueDouble:Double, valueType:Int
valueType = se.ExtractNumber(valueLong, valueDouble)
print "valueLong="+valueLong
print "valueDouble="+valueDouble
print "valueType="+valueType
EndRem

' sample override to have a custom "evaluateVariable()" implementation
' instead of a custom callback.
' 7.2 - Scaremonger: Added varMonday thru' varSunday
Function Scaremonger_variableHandlerCB:String(variableName:String, context:Object)
	'DebugStop
	Select variableName
		Case "name"
			Return "Scaremonger"
		Case "varMonday"
			Return "Monday"
		Case "varTuesday"
			Return "Tuesday"
		Case "varWednesay"
			Return "Wednesay"
		Case "varThursday"
			Return "Thursday"
		Case "varFriday"
			Return "Friday"
		Case "varSaturday"
			Return "Saturday"
		Case "varSunday"
			Return "Sunday"
		Default
			Return "<"+variableName+">"
	End Select
End Function


'Local test:String
Local expr:String

'test = "${.or:${~qhello }~q  }:${  ${0}   }" 'misses } ... incomplete oh noooo!
'print test + "  ->  " + ScriptExpression.Parse(test) + " = 1 ??"
'test = "${.or:${~qhello }~q  }:${  ${0}   }}"

' Incomplete / BAD
'#expect( "${.or:${~qhello }~q  }:${  ${0}   }", "1" )
'DebugStop

expect( "${.or:${~qhello }~q  }:${  ${0}   }", "1", TK_QSTRING, "This should fail" )
expect( "${.bad:~qhello~q:${0}}", "1", TK_BOOLEAN, "This should fail" )
'DebugStop
expect( "${.or:~qhello~q:${0}}", "1", TK_BOOLEAN )
expect( "${.if:${.or:~qhello~q:${0}}:~qTrue~q:~qFalse~q}", "True", TK_QSTRING )
expect( "${.if:1:~qTrue~q:~qFalse~q}", "True", TK_QSTRING )
' Additonal test [SCAREMONGER]
'DebugStop
expect( "${.if:1:True:False}", True, TK_BOOLEAN, "This should fail" )
expect( "${.if:1:true:false}", True, TK_BOOLEAN )
'DebugStop
expect( "${.if:1:~q\~qTrue\~q~q:~qFalse~q}", "~qTrue~q", TK_QSTRING )	' Test escaped quote
expect( "${.if:${.not:1}:~qTrue~q:~qFalse~q}", "False", TK_QSTRING )
expect( "${.eq:1:2:1}", "0", TK_BOOLEAN )
'DebugStop
expect( "${.eq:1:1:1}", "1", TK_BOOLEAN )
expect( "${.gt:4:0}", "1", TK_BOOLEAN )
expect( "${.gt:0:4}", "0", TK_BOOLEAN )
expect( "${.gte:4:4}", "1", TK_BOOLEAN )

'DebugStop
expect( "${.concat:name:~q,~q:age:~q,~q:postcode}", "Scaremonger,<age>,<postcode>", TK_TEXT )

'Local expr2:String = "${.and:${.gte:4:4}:${.gte:5:4}}"
expr = "${.if:${.and:${.gte:4:4}:${.gte:5:4}}:~qis true~q:~qis false~q}"
Print expr
Print "Parse : " + ScriptExpression.Parse(expr).GetValueText()

'end

' Expansion to Script Expression 29 May 2024 / Operators and inline functions

DebugStop

' THIS WILL ONLY WORK AFTER 6PM"
'expr = "${.if:.timeOfDay<=6:~qNight~q:~qDay Or evening~q}"
expr = "${.if:.hour>=18:~qNight~q:~qDay Or evening~q}"
expect( expr, "Night", TK_QSTRING )

' THIS WILL ONLY WORK BEFORE 6PM"
expr = "${.if:.hour<18:~qDay Or evening~q:~qNight~q}"
expect( expr, "Day Or evening", TK_QSTRING )

' THIS FAIL BECAUSE '=' WAS USED INSTEAD OF '=='"
expr = "${.if:.hour=12:~qLunchtime~q:~qNot Lunchtime~q}"
expect( expr, "Lunchtime", TK_QSTRING, "This should fail" )

' THIS WILL ONLY WORK BETWEEN 12:00 and 12:59"
expr = "${.if:.hour==12:~qLunchtime~q:~qNot Lunchtime~q}"
expect( expr, "Lunchtime", TK_QSTRING )

' ?? THIS WILL ONLY WORK OUTSIDE OF 12:00 and 12:59"
expr = "${.if:.hour<>12:~qNot Lunchtime~q:~qLunchtime~q}"
expect( expr, "Not Lunchtime", TK_QSTRING )

' THIS WILL ONLY WORK BETWEEN 08:00 And 08:59"
expr = "${.if:.hour==8:~qComputer Time~q:~qNot Computer Time~q}"
expect( expr, "Computer Time", TK_QSTRING )

'THIS ONLY WORKS ON A SATURDAY
DebugStop
expr = "${.eq:.dayname:varSaturday}"
expect( expr, True, TK_BOOLEAN )


DebugStop

Print "~nPARSETEXT:"
Local context:TStringMap = New TStringMap()
Local descr:String = "The big boss '${.rolename:1}' is played by ${.castname:1} and will win this time"

Print( "No Rolename or Castname: "+ScriptExpression.ParseText( descr, context ) )

context.insert( "rolename", ["James Bond"] )
Print( "Rolename, no Castname:   "+ScriptExpression.ParseText( descr, context ) )

context.insert( "castname", ["Sean Connery"] )
Print( "Rolename and Castname:   "+ScriptExpression.ParseText( descr, context ) )

descr = "${.rolename:1} is the boss played by ${.castname:1}"
Print( "Begin and End:           "+ScriptExpression.ParseText( descr, context ) )

descr = "Testing ${.rolename:1}${.castname:1} together"
Print( "Consecutive:             "+ScriptExpression.ParseText( descr, context ) )

' ---------- TIMINGS ----------

Print "~nTIMINGS:"

Global bbGCAllocCount:ULong = 0
'Extern
'    Global bbGCAllocCount:ULong="bbGCAllocCount"
'End Extern

Local time:Int = MilliSecs()
expr = "${.and:${.gte:4:4}:${.gte:5:4}}"
Local allocs:Int

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

' ----------------



'print ScriptExpression.Parse("${.or:1:2}") + " = 1"
'print ScriptExpression.Parse("${.or:0:~q~q}") + " = 0"
Print "Done."

