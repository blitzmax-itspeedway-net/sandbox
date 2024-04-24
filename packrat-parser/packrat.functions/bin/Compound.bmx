

' Additional core rules
'Global ALPHANUMERIC:TPattern = RANGE( "A-Za-z0-9" )  ' Alphanumeric         

'Global NUMBER:TPattern       = ONEORMORE( DIGIT )          ' Number           DIGIT+

Global QSTRING:TPattern = ..
	SEQUENCE([ ..
		SYMBOL(Chr(34)), ..
		ZEROORMORE( ..
			SEQUENCE([ ..
				NOTPRED(SYMBOL(Chr(34))), ..
				RANGE( Chr($20)+Chr($21)+Chr($22)+Chr($23)+"-"+Chr($7E) ) ..
			]) ..
		), ..
		SYMBOL(Chr(34)) ..
	])
	
' Skips all characters until we find a match
' TODO: Needs optimizing
Function SKIPUNTIL:TPattern( pattern:TPattern )
	Return ZEROORMORE( ..
				CHOICE([ ..
					NOTPRED( pattern ), ..
					ANY() ..
					]) ..
				)
End Function

' Skips all characters until the end
' TODO: Needs optimizing
Function UNTILEND:TPattern()
	Return ZEROORMORE( ANY() )
End Function