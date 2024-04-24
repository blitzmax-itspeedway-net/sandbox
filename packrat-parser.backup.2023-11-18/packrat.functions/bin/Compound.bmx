

' Additional core rules
Global ALPHANUMERIC:TPattern = RANGE( "ALPHANUMERIC", "A-Za-z0-9" )  ' Alphanumeric         

Global NUMBER:TPattern       = ONEORMORE( "NUMBER", DIGIT )          ' Number           DIGIT+

Global QSTRING:TPattern = ..
	SEQUENCE([ ..
		DQUOTE, ..
		ZEROORMORE( ..
			SEQUENCE([ ..
				NOTPRED(DQUOTE), ..
				RANGE( Chr($20)+Chr($21)+Chr($22)+Chr($23)+"-"+Chr($7E) ) ..
			]) ..
		), ..
		DQUOTE ..
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