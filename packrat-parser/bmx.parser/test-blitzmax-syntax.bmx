'   NAME
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'

SuperStrict

'------------------------------------------------------------
'TDebug.enable()
Title( "BLITZMAX" )

Rem PASCAL NESTED COMMENTS:
Begin ← '(*'
End   ← '*)'
C     ← Begin N* End
N     ← C / (!Begin !End Z)
Z     ← any single character
End Rem

grammar = New TGrammar()
grammar.predefine([ "REM_BEGIN", "REM_END", "REM_BODY", "REMARK" ])

' REM must be followed by whitespace, CR or LF to be accepted
grammar[ "REM_BEGIN" ] = SEQUENCE([ keyword( "Rem" ), ANDPRED( choice([ WSP, CR, LF ]) ) ])
' ENDREM or REM must be followed by whitespace, CR or LF to be accepted
grammar[ "REM_END" ] = SEQUENCE([ choice([ keyword( "ENDREM" ), keyword( "END REM" ) ]), ANDPRED( choice([ WSP, CR, LF ]) ) ])

grammar[ "REMARK" ] = SEQUENCE( "Remark", [ ..
	grammar.NonTerminal( "REM_BEGIN" ), ..
	ZEROORMORE( grammar.NonTerminal( "REM_BODY" ) ), ..
	grammar.NonTerminal( "REM_END" ) ..
	])
	
grammar[ "REM_BODY" ] = CHOICE([ ..
	grammar.NonTerminal( "REMARK" ), ..
	SEQUENCE([..
		NOTPRED( grammar.NonTerminal( "REM_BEGIN" ) ), ..
		NOTPRED( grammar.NonTerminal( "REM_END" ) ), ..
		ANY() ..
		])..
	])

'Local comment:TPattern = SEQUENCE( rem_start, ZEROORMORE( rem_body ), rem_end )
'Local remark:TPattern = grammar["REMARK"]
'Local remark:TPattern = sequence([ ..
'	_rem, ..
'	choice([
'		NEG( REMARK ), ..
'		sequence([ ..
'			NEG( _endrem ), ..
'			any() ..
'			]) ..
'		]), ..
'	_endrem ])

'sequence([ negate(__("DQUOTE")), any() ])), __("DQUOTE") ])

pattern = grammar["REM_BEGIN"]
code = "Rem~nThis is an example~nEndRem"
FOUND( "REM..", pattern.match( code ), True)

pattern = grammar["REM_END"]
code = "Rem~nThis is an example~nEndRem"
FOUND( "ENDREM", pattern.match( code,23 ), True)
code = "Rem~nThis is an example~nEnd Rem"
FOUND( "ENDREM", pattern.match( code,23 ), True)

pattern = grammar["REMARK"]
code = "Rem~nThis is an example~nEndRem"
FOUND( "REM..ENDREM", pattern.match( code ))
code = "Rem~nThis is an example~nEnd Rem"
FOUND( "REM..END REM", pattern.match( code ))
code = "Rem~nThis is an exampleREM~nThis is a nested remark~nendrem~nEnd Rem"
FOUND( "Nested REM..END REM", pattern.match( code ), True )
DebugStop


