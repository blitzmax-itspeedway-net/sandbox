SuperStrict
Framework Brl.StandardIO
Import Brl.Map
Import Brl.StringBuilder

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


Global ScriptExpression:TScriptExpression = New TScriptExpression

Type TScriptExpression
	Field conditionHandlers:TStringMap = New TStringMap()
	Field functionHandlers:TStringMap = New TStringMap()

	Method RegisterConditionHandler(conditionName:String, callback:Int(params:Object[]))
		conditionHandlers.Insert(conditionName.ToLower(), New TScriptExpressionConditionHandler(callback))
	End Method


	Method RegisterConditionHandler(conditionName:String, conditionHandler:TScriptExpressionConditionHandler)
		conditionHandlers.Insert(conditionName.ToLower(), conditionHandler)
	End Method


	Method RegisterFunctionHandler(functionName:String, callback:Object(params:Object[], context:Object = Null), paramMinCount:Int = -1, paramMaxCount:Int = -1, resultType:EScriptExpressionResultType)
		functionHandlers.Insert(functionName.ToLower(), New TScriptExpressionFunctionHandler(callback, paramMinCount, paramMaxCount, resultType))
	End Method


	Method RegisterConditionFunctionHandlers(functionName:String, functionHandler:TScriptExpressionFunctionHandler)
		functionHandlers.Insert(functionName.ToLower(), functionHandler)
	End Method


	Method GetFunctionHandler:TScriptExpressionFunctionHandler(functionName:String)
		Return TScriptExpressionFunctionHandler(functionHandlers.ValueForKey(functionName.ToLower()))
	End Method


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

ScriptExpression.RegisterFunctionHandler("not", ScriptExpressionFunctionHandler_Condition_Not, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("and", ScriptExpressionFunctionHandler_Condition_And, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("or", ScriptExpressionFunctionHandler_Condition_Or, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("if", ScriptExpressionFunctionHandler_Condition_If, 1, 3, EScriptExpressionResultType.Text)
ScriptExpression.RegisterFunctionHandler("eq", ScriptExpressionFunctionHandler_Condition_Eq, 1, -1, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("gt", ScriptExpressionFunctionHandler_Condition_Gt, 2, 2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("gte", ScriptExpressionFunctionHandler_Condition_Gte, 2, 2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("lt", ScriptExpressionFunctionHandler_Condition_Lt, 2, 2, EScriptExpressionResultType.NUMERIC)
ScriptExpression.RegisterFunctionHandler("lte", ScriptExpressionFunctionHandler_Condition_Lte, 2, 2, EScriptExpressionResultType.NUMERIC)



'Tests
Print "Tests"
'print ScriptExpressionFunctionHandler_Condition_Or([string(""), "5"]) + " = " + 1

Local test:String

'test = "${.or:${~qhello }~q  }:${  ${0}   }" 'misses } ... incomplete oh noooo!
'print test + "  ->  " + ScriptExpression.Parse(test) + " = 1 ??"

'test = "${.or:${~qhello }~q  }:${  ${0}   }}"
test = "${.or:~qhello~q:${0}}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = 1"

test = "${.if:${.or:~qhello~q:${0}}:~qTrue~q:~qFalse~q}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = True"

test = "${.if:1:~qTrue~q:~qFalse~q}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = True"

test = "${.if:${.not:1}:~qTrue~q:~qFalse~q}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = False"

test = "${.eq:1:2:1}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = 0"

test = "${.eq:1:1:1}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = 1"

test = "${.gt:4:0}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = 1"

test = "${.gt:0:4}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = 0"

test = "${.gte:4:4}"
Print test + "  ->  " + ScriptExpression.Parse(test) + " = 1"

Global bbGCAllocCount:ULong = 0
'Extern
'    Global bbGCAllocCount:ULong="bbGCAllocCount"
'End Extern


Local t:Int = MilliSecs()
Local expr:String = "${.and:${.gte:4:4}:${.gte:5:4}}"
Print ScriptExpression.Parse(expr)
Local allocs:Int = bbGCAllocCount
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
