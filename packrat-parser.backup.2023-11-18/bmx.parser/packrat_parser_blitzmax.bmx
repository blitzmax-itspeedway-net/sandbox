'  Parser for blitzmax
'
'  DATE:     15 Oct 2023
'  VERSION:  0.00
'
'  ##### WARNING
'  #####
'  ##### This file is generated and all manual changes will be overwritten
'  #####
'  ##### DO NOT UPDATE MANUALLY
'
Rem	
#  PEG Definition
#

EndRem

Type TPackrat_blitzmax Extends TPackrat_Parser

	Method New()

		grammar = New TGrammar( "blitzmax", "START", True )

		' DECLARE RULES
		grammar.declare([  ])
					
		' DEFINE RULES


		' VALIDATE RULES
		validate()

	End Method

End Type
