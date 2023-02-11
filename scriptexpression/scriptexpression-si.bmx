SuperStrict
Framework Brl.StandardIO
Import Brl.Map
Import Brl.StringBuilder

' SCAREMONGER - START
Import brl.retro	' Hex() in SToken.reveal()
' SCAREMONGER - END

'Import "../source/Dig/base.util.scriptexpression.bmx"

Rem
${.functionName:param1:${.otherFunctionName:param1:param2}}

${.roleName:&quot;die-guid-von-interesse&quot;}
${.roleLastName:&quot;die-guid-von-interesse&quot;}

${.roleLastName:${.castGUID:1}}
-> castGUID:1 -> cast 1 abrufen und dessen GUID ist das Ergebnis
-> roleLastName:ErgebnisGUID -> role "ErgebnisGUID" abrufen und dessen LastName ist das Ergebnis

${.gt:${.worldtimeYear}:2022:&quot;nach 2022&quot;:&quot;2022 oder eher&quot;}
End Rem

DebugStop

Global ScriptExpression:TScriptExpression = New TScriptExpression

' SCAREMONGER - START
	
Const SYM_SPACE:Int 		= 32	' space
Const SYM_DQUOTE:Int 		= 34	' "
Const SYM_DOLLAR:Int		= 36	' $
Const SYM_LPAREN:Int		= 40	' (
Const SYM_RPAREN:Int		= 41	' )
Const SYM_HYPHEN:Int 		= 45	' -
Const SYM_PERIOD:Int 		= 46	' .
Const SYM_COLON:Int 		= 58	' :
Const SYM_UNDERSCORE:Int	= 95	' _
Const SYM_LBRACE:Int		= 123	' {
Const SYM_RBRACE:Int		= 125	' }

Const TK_EOF:Int 			= 0		' End of File
Const TK_IDENTIFIER:Int		= 1		' Identifier (STRING)
Const TK_NUMBER:Int 		= 2		' Number
Const TK_QSTRING:Int 		= 3		' Quoted String
Const TK_FUNCTION:Int 		= 4		' Function
Const TK_BOOLEAN:Int 		= 5		' Boolean identifiers (true/false)

Struct SToken
	Field id:Int = 0
	Field value:String = ""
	Field linenum:Int, linepos:Int
	
	Method New( id:Int, value:String, linenum:Int, linepos:Int = 0 )
		Self.id      = id
		Self.value   = value
		Self.linenum = linenum
		Self.linepos = linepos
	End Method
	
	' Debugging
	Method reveal:String()
		Return "h"+Hex(id)+" = '"+value+"' at ["+linenum+","+linepos+"]"
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
		If extra; str :+ " ("+extra+")"
		Return Str
	EndMethod

End Type

' SCAREMONGER - END

Type TScriptExpression
	Field conditionHandlers:TStringMap = New TStringMap()
	Field functionHandlers:TStringMap = New TStringMap()

	' SCAREMONGER - START
	Field FN_Handlers:TStringMap = New TStringMap()

	Method Parse2:SToken( expression:String, context:Object[] = Null)
		DebugStop
		Local parser:TScriptExpressionParser = New TScriptExpressionParser( Self, expression, context )
		Try
			Return parser.readWrapper()
		Catch e:TParseException
			DebugLog e.reveal()
		End Try
		Return New SToken( TK_BOOLEAN, "false", 0, 0 )
	End Method
	' SCAREMONGER - END
	
	Method RegisterConditionHandler(conditionName:String, callback:Int(params:Object[]))
		conditionHandlers.Insert(conditionName.ToLower(), New TScriptExpressionConditionHandler(callback))
	End Method


	Method RegisterConditionHandler(conditionName:String, conditionHandler:TScriptExpressionConditionHandler)
		conditionHandlers.Insert(conditionName.ToLower(), conditionHandler)
	End Method


	Method RegisterFunctionHandler(functionName:String, callback:Object(params:Object[], context:Object = Null), paramMinCount:Int = -1, paramMaxCount:Int = -1, resultType:EScriptExpressionResultType)
		functionHandlers.Insert(functionName.ToLower(), New TScriptExpressionFunctionHandler(callback, paramMinCount, paramMaxCount, resultType))
	End Method

	' SCAREMONGER - START
	Method Register( functionName:String, callback:SToken(params:SToken[], context:Object = Null), paramMinCount:Int = -1, paramMaxCount:Int = -1, resultType:EScriptExpressionResultType)
		FN_Handlers.Insert( functionName.ToLower(), New TSEFN_Handler(callback, paramMinCount, paramMaxCount, resultType))
	End Method
	' SCAREMONGER - END


	Method RegisterConditionFunctionHandlers(functionName:String, functionHandler:TScriptExpressionFunctionHandler)
		functionHandlers.Insert(functionName.ToLower(), functionHandler)
	End Method


	Method GetFunctionHandler:TScriptExpressionFunctionHandler(functionName:String)
		Return TScriptExpressionFunctionHandler(functionHandlers.ValueForKey(functionName.ToLower()))
	End Method

	' SCAREMONGER - START
	Method GetFunctionHandler2:TSEFN_Handler( functionName:String )
		Return TSEFN_Handler( FN_Handlers.ValueForKey( functionName.ToLower() ))
	End Method
	' SCAREMONGER - END

	'returns how many elements in the passed array are "true"
	Function _CountTrueValues:Int(objects:Object[])
		Local trueCount:Int 
		For Local i:Int = 0 Until objects.length
			If Not ObjectIsString(objects[i])
				'if it is an object, interpret as True if not Null
				trueCount :+ (objects[i] <> Null)
			Else
				Local s:String = String(objects[i])
				If s = "" Or s = "0"
					'false
				Else
					trueCount :+ 1 'is true
				EndIf
			EndIf
		Next
	
		'count = 0: none true,
		'0 < count < arr.length: not all are true (but at least one)
		'count = arr.length: all true
		Return trueCount
	End Function	


		'returns how many elements are equal to the first passed value
	Function _CountEqualValues:Int(objects:Object[])
		If objects.length = 0 Then Return 0

		Local equalCount:Int = 1 'is equal with itself
		For Local i:Int = 1 Until objects.length
			If Not ObjectIsString(objects[0])
				If objects[i] = objects[0] Then equalCount :+ 1
			Else
				If String(objects[i]) = String(objects[0]) Then equalCount :+ 1
			EndIf
		Next
		Return equalCount
	End Function	

	' SCAREMONGER - START
	'returns how many elements in the passed array are "true"
	Function _CountTrueValues2:Int(tokens:SToken[])
		If tokens.length = 0 Then Return 0

		Local trueCount:Int 
		For Local i:Int = 0 Until tokens.length
			Select tokens[i].id
			Case TK_NUMBER
				If Int(tokens[i].value); trueCount :+ 1
			Case TK_IDENTIFIER
				If tokens[i].value And tokens[i].value <> "1"; trueCount :+ 1
			EndSelect
		Next
	
		'count = 0: none true,
		'0 < count < arr.length: not all are true (but at least one)
		'count = arr.length: all true
		Return trueCount
	End Function	

	'returns how many elements are equal to the first passed value
	Function _CountEqualValues2:Int(tokens:SToken[])
		If tokens.length = 0 Then Return 0

		Local equalCount:Int = 1 'is equal with itself
		For Local i:Int = 1 Until tokens.length
			If tokens[i].id = tokens[0].id And tokens[i].value = tokens[0].value Then 
				equalCount :+ 1
			'Else
			'	If String(objects[i]) = String(objects[0]) Then equalCount :+ 1
			EndIf
		Next
		Return equalCount
	End Function
	' SCAREMONGER - END
	
	'parsing an expression for a condition only returns 1 or 0 
	Method ParseCondition:Int(expression:String, context:Object = Null)
	End Method


	'parsing an expression returns a string(ified) value
	Method Parse:String(expression:String, context:Object = Null)
		'"${}" is at least 3 chars - short can't have a valid expression
		If expression.length < 3 Then Return expression
		'nothing to parse?
		If expression.Find("${") = -1 Then Return expression

		
		Local sb:TStringBuilder = New TStringBuilder()
		sb.Append(expression)

		Local replacedSomething:Int
		Repeat
			replacedSomething = False
			'find most nested ${} element
			'and parse it, replace ${} element with parsed result

			Local lastOpeningTagCharIndex:Int = -1
			Local escapeNextChar:Int
			'"- 2" as we can ignore "${" at the end
			'also this allows to savely "peek" one char ahead
			Local charIndex:Int = 0
			Local inString:Int
'print "Loop ==="
			While charIndex < sb.Length()
				If escapeNextChar
'print charIndex + "-> escape  (" + charIndex + " < " + sb.Length() + ")"
					escapeNextChar = False
					charIndex :+ 1
					Continue
				EndIf

				'escape next char marker?
				If sb[charIndex] = Asc("\") And Not escapeNextChar 
'print charIndex + "-> escape next  (" + charIndex + " < " + sb.Length() + ")"
					escapeNextChar = True
					charIndex :+ 1
					Continue
				EndIf

				'string opened/closed?
				If sb[charIndex] = Asc("~q") And Not escapeNextChar
					inString = 1 - inString
					charIndex :+ 1
					Continue
				EndIf

				If Not inString
					If charIndex < sb.Length() - 1 And sb[charIndex] = Asc("$") And sb[charIndex + 1] = Asc("{")
						lastOpeningTagCharIndex = charIndex
'	print charIndex + "-> Opening ${  (" + charIndex + " < " + sb.Length() + ")"
					ElseIf sb[charIndex] = Asc("}") And lastOpeningTagCharIndex >= 0
'	print charIndex + "-> Closing }  (" + charIndex + " < " + sb.Length() + ")"
						'closed nested expression? Interpret it
						Local result:SScriptExpressionParseResult = _ParseSingleBlock(sb, lastOpeningTagCharIndex + 2, charIndex - 1, context)
						'replace if interpretation did something
						If result.replacedSomething
							'substring is "inclusive begin, exclusive end" (0, 3) = "0,1,2")
	'print "  <- ~q" + sb.ToString()+"~q   lastOpeningTagCharIndex="+lastOpeningTagCharIndex+"  charIndex="+charIndex + "  replace ~q" + sb.SubString(lastOpeningTagCharIndex, charIndex + 1) +"~q with ~q"+result.text+"~q."
							sb.Remove(lastOpeningTagCharIndex, charIndex + 1)
							sb.Insert(lastOpeningTagCharIndex, result.Text)
							replacedSomething = True
	'print "  -> ~q" + sb.ToString()+"~q   charIndex="+charIndex +" -> " + (lastOpeningTagCharIndex + result.text.length)
							'advance to new end position
							charIndex = lastOpeningTagCharIndex + result.Text.length
	'exit
						EndIf

						'reset position, only care for _new_ ${...} after this position
						'as you cannot guarantee that "old information" is the same
						'after something got replaced
						lastOpeningTagCharIndex  = -1
					EndIf
				EndIf

				escapeNextChar = False
				charIndex :+ 1
			Wend
		Until replacedSomething = False

		Return sb.ToString()
	End Method


	'parse a $(something} (no inner nesting!)
	Method _ParseSingleBlock:SScriptExpressionParseResult(sb:TStringBuilder, startPos:Int, endPos:Int, context:Object)
		'substring is "inclusive begin, exclusive end" (0, 3) = "0,1,2")
		'so + 1 to even include "endPos"
		'print "_ParseSingleElement: ~q"+sb.Substring(startPos, endPos + 1)+"~q"

		'Possible content is a mix of:
		'- "   strings with optional whitespace somewhere    "
		'- .functionNames
		'- variables
		'- 1234 (numbers)
		'All are connected with a delimiter.
		'Only ".functionNames" should have ":separated:params" as all others would have to be 
		'wrapped in their own ${}-blocks if they needed to be replaced _before
		'Ex: ${variable:10:20} with "variable"'s content being ".gt"
		'    this should correctly be written
		'    ${${variable}:10:20} as this first transforms "${variable}" and _then_
		'    ${.gt:10:20} in the second step
		Local delimiter:Int = Asc(":")
		Local functionCallIndicator:Int = Asc(".")

		

		'=== identify parts === 
		Local charIndex:Int = startPos
		Local inString:Int
		Local escapeNext:Int
		'we allow up to 10 elements per block, StaticArrays live on the stack, no GC involved
		Local partsLimit:Int = 10
		Local StaticArray partsStartPos:Int[10]
		Local StaticArray partsEndPos:Int[10]
		Local partIndex:Int = 0
		While charIndex <= endPos
			'skip whitespace
			If Not inString
				While charIndex <= endPos And (sb[charIndex] = Asc(" ") Or sb[charIndex] = Asc("~t"))
					charIndex :+ 1
				Wend
			EndIf
			'mark start
			partsStartPos[partIndex] = charIndex

			While charIndex <= endPos
				escapeNext = (sb[charIndex] = Asc("\") And Not escapeNext)

				'begin/end of a string
				If Not escapeNext And sb[charIndex] = Asc("~q")
					inString = 1 - inString
				EndIf

				'next part? (splitter or end of text)
				If charIndex = endPos Or (Not inString And Not escapeNext And sb[charIndex] = delimiter)
					If partIndex >= partsLimit
						Print "TScriptExpression: Expression contains more than " + partsLimit + " parts. Not supported."
						Return New SScriptExpressionParseresult("ERROR: " + "TScriptExpression: Expression contains more than " + partsLimit + " parts. Not supported.", True)
						'exit
					EndIf

					If charIndex = endPos
						partsEndPos[partIndex] = charIndex
					Else
						partsEndPos[partIndex] = charIndex - 1
					EndIf
					'trim excess whitespace
					While partsEndPos[partIndex] > partsStartPos[partIndex] And (sb[partsEndPos[partIndex]] = Asc(" ") Or sb[partsEndPos[partIndex]] = Asc("~t"))
						partsEndPos[partIndex] :- 1
					Wend
					'print "part" + " => ~q" + sb.Substring(partsStartPos[partIndex], partsEndPos[partIndex] + 1) +"~q"
					
					If Not charIndex < endPos
						partIndex :+ 1
					EndIf
					charIndex :+ 1
					Exit
				Else
					charIndex :+ 1
				EndIf

			Wend
		Wend
		Local partCount:Int = partIndex


		'skip further processing, no parts at all
		If partIndex = 0
			Print "no parts"
			Return New SScriptExpressionParseresult("", True)
		End If


		'=== Identify parts ===
		Local StaticArray partsType:EScriptExpressionPartType[10]
		partIndex = 0
		While partIndex < partCount
			Local firstCharCode:Int = sb[partsStartPos[partIndex]]
			If firstCharCode = functionCallIndicator
				partsType[partIndex] = EScriptExpressionPartType.FUNCTION_CALL
			ElseIf firstCharCode = Asc("~q")
				partsType[partIndex] = EScriptExpressionPartType.Text
			ElseIf firstCharCode >= Asc("0") And firstCharCode <= Asc("9") 
				partsType[partIndex] = EScriptExpressionPartType.NUMERIC
			Else
				partsType[partIndex] = EScriptExpressionPartType.VARIABLE
			EndIf

			partIndex :+ 1
		Wend


		'=== Resolve parts ===
		'first part can be a function call with params, all other parts
		'cannot use further coming parts as params
		'- so all elements except the first have to be resolveable now
		'- also first part must be a function call IF multiple parts exist
		'- first part could be a variable resolving to a function call


		If partsType[0] = EScriptExpressionPartType.VARIABLE
			'check if variable content corresponds to a function call
		EndIf

		'error out if params are following a non-function-call
		If partsType[0] <> EScriptExpressionPartType.FUNCTION_CALL And partCount > 1
			Print "TScriptExpression: Expression contains multiple parts but does not start with a function call accepting these params."
			Return New SScriptExpressionParseresult("(ERROR: " + "TScriptExpression: Expression contains multiple parts but does not start with a function call accepting these params.)", True)
		EndIf

		'resolve function call after collecting all params
		If partsType[0] = EScriptExpressionPartType.FUNCTION_CALL
			'retrieve function handler
			Local key:String = sb.Substring(partsStartPos[0]+1, partsEndPos[0] + 1)
			Local fHandler:TScriptExpressionFunctionHandler = GetFunctionHandler(key)


			If fHandler
				Local maxParams:Int = partCount - 1 'first part is the handler name itself
				If fHandler.paramMaxCount >= 0 And fHandler.paramMaxCount < maxParams Then maxParams = fHandler.paramMaxCount
				If fHandler.paramMinCount >= 0 And fHandler.paramMinCount > partCount
					Return New SScriptExpressionParseResult("(ERROR: Function call requires minimum " + fHandler.paramMinCount + " parameters. " + partCount + " given.)", True)
				EndIf

				Local params:Object[] = New Object[maxParams]
				For Local paramNumber:Int = 0 Until params.length
					Local paramPartIndex:Int = 1 + paramNumber
					Select partsType[paramPartIndex]
						Case EScriptExpressionPartType.Text
							params[paramNumber] = sb.Substring(partsStartPos[paramPartIndex] + 1, partsEndPos[paramPartIndex] + 1 - 1)

						Case EScriptExpressionPartType.NUMERIC
							params[paramNumber] = sb.Substring(partsStartPos[paramPartIndex], partsEndPos[paramPartIndex] + 1)

						Case EScriptExpressionPartType.VARIABLE
							Local resultCode:Int
							Local result:String = GetVariableContent(sb.Substring(partsStartPos[paramPartIndex], partsEndPos[paramPartIndex]), resultCode)
							If resultCode
								params[paramNumber] = result
							Else
								'maybe it simply was a string without quotation marks?
								params[paramNumber] = sb.Substring(partsStartPos[paramPartIndex], partsEndPos[paramPartIndex])
								'params[paramNumber] = "(ERROR: Variable ~q" + result + "~q not found.)"
							EndIf

						Case EScriptExpressionPartType.FUNCTION_CALL
							Local fHandler:TScriptExpressionFunctionHandler = GetFunctionHandler(sb.Substring(partsStartPos[paramPartIndex]+1, partsEndPos[paramPartIndex] + 1))
							If fHandler
								params[paramNumber] = fHandler.Run(Null, Null)
							Else
								params[paramNumber] = "(ERROR: Function call ~q" + sb.Substring(partsStartPos[paramPartIndex]+1, partsEndPos[paramPartIndex] + 1) + "~q not found.)"
							EndIf
					End Select
				Next

				Return New SScriptExpressionParseResult( String( fHandler.run(params, context) ), True)
			Else
				Return New SScriptExpressionParseResult("(ERROR: Function call ~q" + sb.Substring(partsStartPos[0]+1, partsEndPos[0]+1) + "~q not found.)", True)
			EndIf

		'else we must have only a single part and could resolve it
		Else
			Select partsType[0]
				Case EScriptExpressionPartType.Text
					'print "return String: " + sb.Substring(partsStartPos[0] + 1, partsEndPos[0] + 1 - 1)
					Return New SScriptExpressionParseresult(sb.Substring(partsStartPos[0] + 1, partsEndPos[0] + 1 - 1), True)
				Case EScriptExpressionPartType.NUMERIC
					'print "return Numeric: " + sb.Substring(partsStartPos[0], partsEndPos[0] + 1)
					Return New SScriptExpressionParseresult(sb.Substring(partsStartPos[0], partsEndPos[0] + 1), True)
				Case EScriptExpressionPartType.VARIABLE
					'fetch variable
					Local resultCode:Int
					Local result:String = GetVariableContent(sb.Substring(partsStartPos[partIndex], partsEndPos[partIndex]), resultCode)
					If resultCode = True
						Return New SScriptExpressionParseresult(result, True)
					Else
						'maybe it simply was a string without quotation marks?
						Return New SScriptExpressionParseresult( sb.Substring(partsStartPos[partIndex], partsEndPos[partIndex]), True)
						'Return new SScriptExpressionParseresult("ERROR: Variable ~q" + result + " not found.", True)
					EndIf
			End Select
		EndIf

		Return New SScriptExpressionParseresult("", True)
	End Method


	Method GetVariableContent:String(variableKey:String, result:Int Var)
		result = True
		Return variableKey
	End Method
End Type




Struct SScriptExpressionParseResult
	Field ReadOnly Text:String
	Field ReadOnly replacedSomething:Int
	Field ReadOnly errorCode:EScriptExpressionErrorCode


	Method New(Text:String, replacedSomething:Int, errorCode:EScriptExpressionErrorCode = EScriptExpressionErrorCode.NONE)
		Self.Text = Text
		Self.replacedSomething = replacedSomething
		Self.errorCode = errorCode
	End Method
End Struct


Enum EScriptExpressionErrorCode
	NONE
	PARAMETER_NOT_ALLOWED
End Enum


Enum EScriptExpressionPartType
	UNKNOWN
	FUNCTION_CALL
	Text
	VARIABLE
	NUMERIC
End Enum


Enum EScriptExpressionResultType
	NUMERIC
	Text
	VARIABLE
	OBJ
End Enum

' SCAREMONGER - START
' Expression Tokeniser
Type TScriptExpressionLexer

	Field cursor:Int, linenum:Int, linepos:Int
	Field expression:String
	
	Method New( expression:String )
		Self.expression = expression
		cursor  = 0
		linenum = 0
		linepos = 0
	End Method
		
	' Retrieves the current token (At the cursor)
	Method GetNext:SToken()
		'If (cursor+1)>=tokens.count Return Create_EOF_Token()
		'cursor :+ 1
		'Return TToken( tokens.valueAtIndex( cursor ) )
		'DebugStop
		Repeat
			Local ch:Int = PeekAscii()
			Select True
			Case ch = 0							' End of file
				Return New SToken( TK_EOF, "EOF", linenum, linepos )
			Case ch <= SYM_SPACE Or ch >=126	' Whitespace or control codes
				PopChar()
			Default
				Return GetLanguageToken()
			End Select	
		Forever
	End Method
	
	Private
	
	Method PeekChar:String()
	DebugStop
	Local debug:String = expression[ cursor..cursor+1 ]
		If cursor >= expression.length Return ""
		Return expression[ cursor..cursor+1 ]
	End Method

	Method PeekAscii:Int()
		If cursor >= expression.length Return 0
		Return expression[ cursor ]
	End Method
Rem
	' Pops next character moving the cursor forward
	Method PopChar:String( IgnoredSymbols:String )
		If cursor >= source.length; Return ""
		Local ch:String = source[ cursor+1 ]
		
		' Ignore leading whitespace
		While Instr( IgnoredSymbols, char )
		'Local IgnoredSymbols:String = ""
		'
		'If ignoreWhitespace IgnoredSymbols = whitespace
		
		'Repeat
			If source.length = 0 Return ""
			char = source[cursor..cursor+1]
			Select char
			Case "~r"   ' CR
				cursor :+ 1
			Case "~n"   ' LF
				linenum :+ 1
				linepos = 1
				cursor :+ 1
			Case " ","~t"
				linepos:+1
				cursor :+1
			Default
				linepos :+ 1
				cursor :+ 1
			End Select
		'Until Not Instr( IgnoredSymbols, char )
		Wend
		'
		' Move the cursor forward
		If char="~n"
			linenum :+ 1
			linepos = 1
			cursor :+ 1
		ElseIf char="\"	' ESCAPE CHARACTER
'DebugStop
			char = source[cursor..cursor+2]
			If char="\u"	'HEX DIGIT
				char = source[cursor..cursor+6]			
				cursor :+ 6
			Else
				cursor :+ 2
			End If
		Else
			linepos :+ 1
			cursor :+ 1
		End If
		Return char
	End Method
EndRem
	' Pops next character moving the cursor forward
	Method PopChar:String()
		If cursor >= expression.length Return ""
		Local ch:String = expression[ cursor..cursor+1 ]

		' Move the cursor forward
		If ch = "~n"
			linenum :+ 1
			linepos = 1
			cursor :+ 1
		ElseIf ch = "\"	' ESCAPE CHARACTER
			ch = expression[ cursor+2 ]
			linepos :+ 2
			cursor :+ 2
		Else
			linepos :+ 1
			cursor :+ 1
		End If
		Return ch
	End Method

	' Language specific tokeniser
	Method GetLanguageToken:SToken()
		Local ch:Int = PeekAscii()
		Local line:Int = linenum
		Local pos:Int = linepos
		'
		Select True
		Case ch = SYM_DQUOTE										' QUOTED STRING
			Return New SToken( TK_QSTRING, ExtractQuotedString(), linenum, linepos )
		Case ch = 45 Or ( ch >= 48 And ch <= 57 )					' NUMBER
			Return New SToken( TK_NUMBER, ExtractNumber(), linenum, linepos )
		Case ( ch >=97 And ch <= 122 ) Or ( ch >= 65 And ch <=90 )	' LETTER
			Local ident:String = ExtractIdent()
			Select ident.toLower()
			Case "true", "false"
				Return New SToken( TK_BOOLEAN, ident.toLower(), linenum, linepos )
			Default
				Return New SToken( TK_IDENTIFIER, ident, linenum, linepos )
			End Select
		Default ' ch = SYM_COLON Or ch = SYM_PERIOD						' SYMBOLS
			Return New SToken( ch, PopChar(), linenum, linepos )
		Rem
		Default													' A Symbol
			PopChar()   ' Move to next character
			Local ascii:Int = Asc(char)
			Local class:String = lookup[ascii]
			If class<>"" Return New TToken( ascii, char, line, pos, class ) 
			' Default to ASCII code
			Return New TToken( ascii, char, line, pos, "SYMBOL" )
		End Rem
		EndSelect
		
	End Method
	
	' Identifier starts with a letter, but can contain "_" and numbers
	Method ExtractIdent:String()
		'DebugStop
		Local str:String
		Local ch:Int = peekAscii()
		While ch=0 ..
			Or ch = SYM_UNDERSCORE ..
			Or ( ch >= 48 And ch <= 57 ) ..		' NUMBER
			Or ( ch >= 65 And ch <= 90 ) ..		' UPPERCASE
			Or ( ch >= 97 And ch <= 122 )		' LOWERCASE
				str :+ popChar()
				ch = peekAscii()
		Wend
		Return str
	End Method
		
	Method ExtractNumber:String()
		'DebugStop
		Local str:String
		Local Integer:Int, Floating:Float, negative:Int = 1, divider:Float=1.0
		Local ch:Int = peekAscii()
		' Leading "-" (Negative number)
		If ch = SYM_HYPHEN	
			negative = True
			str :+ popChar()
			ch = peekAscii()
		End If
		' Number
		While ch<>0 And ( ch>=48 And ch<=57 )
			Integer = Integer * 10 + (ch-48)
			str :+ popChar()
			ch = PeekAscii()
		Wend
		' Decimal
		If ch = SYM_PERIOD
			Floating = Float(Integer)
			str :+ popChar()
			ch = PeekAscii()
			While ch<>0 And ( ch>=48 And ch<=57 )
				Floating :+ (ch-48) / divider
				Divider = divider / 10
				str :+ popChar()
				ch = PeekAscii()
			Wend
			'Return Floating*Negative
		End If
		' Need a way to return INT or FLOAT here!
		'Return Integer*Negative
		Return str
	End Method

	Method ExtractQuotedString:String()
		Local str:String
		Local ch:String
		ch = PopChar()   				' This is the leading Quote (Skip that)
		ch = PopChar()					' This is the first character (The one we want)
		While ch <> "" And ch <> "~q"
			
			'Select ch.length
			'Case 1
				str :+ ch
			'Case 2	' ESCAPE CHARACTER?
			'	Select ch
			'	Case "\~q","\\","\/"	;	str :+ ch[1..]
			'	'Case "\b"				;	Text :+ Chr($08)		' Backspace
			'	'Case "\f"				;	Text :+ Chr($0C)		' Formfeed
			'	Case "\n"				;	str :+ "~n"			' Newline
			'	Case "\r"				;	str:+ "~r"			' Carriage Return
			'	Case "\t"				;	str:+ "~t"			' Tab
			'	End Select
			'End Select
			ch = PopChar()
		Wend
		Return str
	End Method

End Type

' Expression Parser
Type TScriptExpressionParser

	Field parent:TScriptExpression
	Field context:Object
	Field lexer:TScriptExpressionLexer
	Field token:SToken	' Current token
	
	Method New( parent:TScriptExpression, expression:String, context:Object )
		Self.parent = parent
		Self.context = context
		lexer = New TScriptExpressionLexer( expression )
		advance()	' Read first token
	End Method

	' Read a readWrapper ${..}
	Method readWrapper:SToken()
		DebugStop
		Local result:SToken[] = []
		eat( SYM_DOLLAR )	' Skip leading Dollar symbol
		eat( SYM_LBRACE )	' Skip Opening Brace

		' Termination
		If Not token Or token.id = TK_EOF ; Throw( New TParseException( "Unexpected end", token, "readWrapper()" ) )

		' Empty Wrapper
		If token.id = SYM_RBRACE; Throw( New TParseException( "Empty group", token, "readWrapper()" ) )
		
		' Next are one or more arguments
		Repeat	
		
			Select token.id
			Case TK_EOF
				Throw New TParseException( "Unexpected end of expression", token, "readWrapper().params" )
			Case SYM_DOLLAR
				result :+ [ readWrapper() ]
			Case SYM_PERIOD
				eat( SYM_PERIOD )		' We dont need this identifier
				'advance()
				If token.id <> TK_IDENTIFIER; Throw New TParseException( "Identifier expected", token, "readWrapper()" )
				token.id = TK_FUNCTION
				result :+ [token]
				advance()
			Case TK_IDENTIFIER, TK_QSTRING, TK_NUMBER
				result :+ [token]
				advance()
			Default
				DebugLog( "ReadWrapper() ["+token.id+"] "+token.value+", error" )
				Throw New TParseException( "Unexpected token", token, "readWrapper()" )
			End Select
			
			' If we have finished, evaluate the wrapper returning the result
			If token.id = SYM_RBRACE; Return eval( result )
			
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
		'If cursor> tokens.count Return Create_EOF_Token()
		'Local token:SToken = Self.token
		If token.id = expectation
			'DebugStop
			advance()
			Return token
		End If
		Throw New TParseException( token.value+" was unexpected", token, "eat()" )
	End Method		
		
	Method eval:SToken( tokens:SToken[] )
		Select tokens[0].id
		Case TK_FUNCTION
			Local fn:TSEFN_Handler = parent.GetFunctionHandler2( token.value.toLower() )
			If Not fn; Throw New TParseException( "Undefined function "+token.value.toLower(), token, "eval()" )
			Return fn.run( tokens[1..], context )
		Case TK_IDENTIFIER, TK_BOOLEAN, TK_NUMBER
			If tokens.length > 1; Throw New TParseException( "Invalid parameters", tokens[1], "eval()" )
			Return tokens[0]
		End Select
	End Method
	
End Type
' SCAREMONGER - END

'condition handlers (>=, >, <, <=, not, ...) just return true/false (int)
Type TScriptExpressionConditionHandler
	Field callback:Int(params:Object[])


	Method New(callback:Int(params:Object[]))
		Self.callback = callback
	End Method


	Method Run:Int(params:Object[])
		If callback Then Return callback(params)
	End Method
End Type


'function handlers can return objects/strings
Type TScriptExpressionFunctionHandler
	Field resultType:EScriptExpressionResultType
	Field paramMinCount:Int = -1
	Field paramMaxCount:Int = -1
	Field callback:Object(params:Object[], context:Object = Null)


	Method New(callback:Object(params:Object[], context:Object = Null), paramMinCount:Int, paramCount:Int, resultType:EScriptExpressionResultType)
		Self.callback = callback
		Self.paramMinCount = paramMinCount
		Self.paramMaxCount = paramMaxCount
		Self.resultType = resultType
	End Method


	Method Run:Object(params:Object[], context:Object = Null)
		If callback Then Return callback(params, context)
	End Method
End Type

' SCAREMONGER - END
Type TSEFN_Handler

	Field resultType:EScriptExpressionResultType
	Field paramMinCount:Int = -1
	Field paramMaxCount:Int = -1
	Field callback:SToken(params:SToken[], context:Object = Null)

	Method New(callback:SToken( params:SToken[], context:Object = Null), paramMinCount:Int, paramCount:Int, resultType:EScriptExpressionResultType)
		Self.callback = callback
		Self.paramMinCount = paramMinCount
		Self.paramMaxCount = paramMaxCount
		Self.resultType = resultType
	End Method

	Method Run:SToken(params:SToken[], context:Object = Null)
		If callback Then Return callback(params, context)
	End Method
End Type
' SCAREMONGER - END

'register defaults

Function ScriptExpressionFunctionHandler_Condition_Or:Object(params:Object[], context:Object = Null)
	Return String(TScriptExpression._CountTrueValues(params) > 0)
End Function

Function ScriptExpressionFunctionHandler_Condition_And:Object(params:Object[], context:Object = Null)
	Return String(TScriptExpression._CountTrueValues(params) = params.length)
End Function

Function ScriptExpressionFunctionHandler_Condition_Not:Object(params:Object[], context:Object = Null)
	Return String(TScriptExpression._CountTrueValues(params) = 0)
End Function

Function ScriptExpressionFunctionHandler_Condition_If:Object(params:Object[], context:Object = Null)
	If TScriptExpression._CountTrueValues([params[0]]) = 1
		If params.length < 2
			Return "1"
		Else
			Return params[1]
		EndIf
	Else
		If params.length < 3
			Return "0"
		Else
			Return params[2]
		EndIf
	EndIf
End Function

Function ScriptExpressionFunctionHandler_Condition_Eq:Object(params:Object[], context:Object = Null)
	Return String(TScriptExpression._CountEqualValues(params) = params.length)
End Function

Function ScriptExpressionFunctionHandler_Condition_Gt:Object(params:Object[], context:Object = Null)
	If params.length < 2 Then Return "0"
	Return String(Double(String(params[0])) > Double(String(params[1])))
End Function

Function ScriptExpressionFunctionHandler_Condition_Gte:Object(params:Object[], context:Object = Null)
	If params.length < 2 Then Return "0"
	Return String(Double(String(params[0])) >= Double(String(params[1])))
End Function


Function ScriptExpressionFunctionHandler_Condition_Lt:Object(params:Object[], context:Object = Null)
	If params.length < 2 Then Return "0"
	Return String(Double(String(params[0])) < Double(String(params[1])))
End Function

Function ScriptExpressionFunctionHandler_Condition_Lte:Object(params:Object[], context:Object = Null)
	If params.length < 2 Then Return "0"
	Return String(Double(String(params[0])) <= Double(String(params[1])))
End Function

' SCAREMONGER - START
Function SEFN_Or:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	Return New SToken( TK_IDENTIFIER, String(TScriptExpression._CountTrueValues2(params) > 0), cmd.linenum, cmd.linepos )
End Function

Function SEFN_And:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	Return New SToken( TK_IDENTIFIER, String(TScriptExpression._CountTrueValues2(params) = params.length), cmd.linenum, cmd.linepos )
End Function

Function SEFN_Not:SToken( params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	Return New SToken( TK_IDENTIFIER, String(TScriptExpression._CountTrueValues2(params) = 0), cmd.linenum, cmd.linepos )
End Function

Function SEFN_If:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	If TScriptExpression._CountTrueValues2([params[0]]) = 1
		If params.length < 2
			Return New SToken( TK_NUMBER, "1", cmd.linenum, cmd.linepos )
		Else
			Return params[1]
		EndIf
	Else
		If params.length < 3
			Return New SToken( TK_NUMBER, "0", cmd.linenum, cmd.linepos )
		Else
			Return params[2]
		EndIf
	EndIf
End Function

Function SEFN_Eq:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	Return New SToken( TK_NUMBER, "0", cmd.linenum, cmd.linepos )
	'Return String(TScriptExpression._CountEqualValues2(params) = params.length)
End Function

Function SEFN_Gt:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	If params.length < 2 Then Return New SToken( TK_NUMBER, "0", cmd.linenum, cmd.linepos )
	Return New SToken( TK_NUMBER, (Double(params[0].value) > Double(params[1].value)), cmd.linenum, cmd.linepos )
End Function

Function SEFN_Gte:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	If params.length < 2 Then Return New SToken( TK_NUMBER, "0", cmd.linenum, cmd.linepos )
	Return New SToken( TK_NUMBER, (Double(params[0].value) >= Double(params[1].value)), cmd.linenum, cmd.linepos )
End Function

Function SEFN_Lt:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	If params.length < 2 Then Return New SToken( TK_NUMBER, "0", cmd.linenum, cmd.linepos )
	Return New SToken( TK_NUMBER, (Double(params[0].value) < Double(params[1].value)), cmd.linenum, cmd.linepos )
End Function

Function SEFN_Lte:SToken(params:SToken[], context:Object = Null)
	Local cmd:SToken = params[0]
	If params.length < 2 Then Return New SToken( TK_NUMBER, "0", cmd.linenum, cmd.linepos )
	Return New SToken( TK_NUMBER, (Double(params[0].value) <= Double(params[1].value)), cmd.linenum, cmd.linepos )
End Function
' SCAREMONGER - END

ScriptExpression.RegisterFunctionHandler("not", ScriptExpressionFunctionHandler_Condition_Not, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("and", ScriptExpressionFunctionHandler_Condition_And, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("or", ScriptExpressionFunctionHandler_Condition_Or, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("if", ScriptExpressionFunctionHandler_Condition_If, 1, 3, EScriptExpressionResultType.Text)
ScriptExpression.RegisterFunctionHandler("eq", ScriptExpressionFunctionHandler_Condition_Eq, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("gt", ScriptExpressionFunctionHandler_Condition_Gt, 2, 2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("gte", ScriptExpressionFunctionHandler_Condition_Gte, 2, 2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("lt", ScriptExpressionFunctionHandler_Condition_Lt, 2, 2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("lte", ScriptExpressionFunctionHandler_Condition_Lte, 2, 2, EScriptExpressionResultType.NUMERIC)

' SCAREMONGER - START
ScriptExpression.Register( "not", SEFN_Not, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.Register( "and", SEFN_And, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.Register( "or",  SEFN_Or,  1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.Register( "if",  SEFN_If,  1,  3, EScriptExpressionResultType.Text)
ScriptExpression.Register( "eq",  SEFN_Eq,  1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.Register( "gt",  SEFN_Gt,  2,  2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.Register( "gte", SEFN_Gte, 2,  2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.Register( "lt",  SEFN_Lt,  2,  2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.Register( "lte", SEFN_Lte, 2,  2, EScriptExpressionResultType.NUMERIC)
' SCAREMONGER - END

' SCAREMONGER - START

Function expect( test:String, expected:String )
	Print "~n"
	GWRon( test, expected )
	Scaremonger( test, expected )
End Function

Function GWRon( test:String, expected:String )
	Local result:String = ScriptExpression.Parse(test)
	If result = expected
		Print test + " - SUCCESS"
	Else
		Print test + " - FAILURE ("+result+")"
	End If
End Function

Function Scaremonger( test:String, expected:String )
'DebugStop
	Local result:SToken = ScriptExpression.Parse2(test)
	If result.id = TK_IDENTIFIER And result.value = expected
		Print test + " - SUCCESS"
	Else
		Print test + " - FAILURE ("+result.reveal()+")"
	End If
End Function
' SCAREMONGER - END

'Tests
Print "Tests"
'print ScriptExpressionFunctionHandler_Condition_Or([string(""), "5"]) + " = " + 1

'Local test:String

'test = "${.or:${~qhello }~q  }:${  ${0}   }" 'misses } ... incomplete oh noooo!
'print test + "  ->  " + ScriptExpression.Parse(test) + " = 1 ??"
'test = "${.or:${~qhello }~q  }:${  ${0}   }}"

' Incomplete / BAD
'#expect( "${.or:${~qhello }~q  }:${  ${0}   }", "1" )

DebugStop
expect( "${.or:~qhello~q:${0}}", "1" )
DebugStop
expect( "${.if:${.or:~qhello~q:${0}}:~qTrue~q:~qFalse~q}", "True" )
expect( "${.if:1:~qTrue~q:~qFalse~q}", "True" )
expect( "${.if:1:~q\~qTrue\~q~q:~qFalse~q}", "~qTrue~q" )	' Test escaped quote
expect( "${.if:${.not:1}:~qTrue~q:~qFalse~q}", "False" )
expect( "${.eq:1:2:1}", "0" )
expect( "${.eq:1:1:1}", "1" )
expect( "${.gt:4:0}", "1" )
expect( "${.gt:0:4}", "0" )
expect( "${.gte:4:4}", "1" )

Global bbGCAllocCount:ULong = 0
'Extern
'    Global bbGCAllocCount:ULong="bbGCAllocCount"
'End Extern

Local t:Int = MilliSecs()
Local expr:String = "${.and:${.gte:4:4}:${.gte:5:4}}"

Local allocs:Int

Print "GWRon:"
Print ScriptExpression.Parse(expr)
allocs = bbGCAllocCount
For Local i:Int = 0 Until 1000000
	ScriptExpression.Parse(expr)
Next
Print "took: " + (MilliSecs() - t) +" ms. Allocs=" + (bbGCAllocCount - allocs)

Print "Scaremonger:"
Print ScriptExpression.Parse2(expr).value
allocs = bbGCAllocCount
For Local i:Int = 0 Until 1000000
	ScriptExpression.Parse(expr)
Next
Print "took: " + (MilliSecs() - t) +" ms. Allocs=" + (bbGCAllocCount - allocs)

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
