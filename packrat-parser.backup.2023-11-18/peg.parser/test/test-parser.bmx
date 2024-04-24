
SuperStrict

'	PACKRAT PARSER
'Import packrat.parser
Import "../../packrat.parser/parser.bmx"

'	PARSER GENERATOR
'Import bmx.packrat-gen
Import "../../packrat.generator/generator.bmx"
Import "../../packrat.functions/functions.bmx"
'	PRODUCTION PEG PARSER
Include "../bin/TPackratParser_PEG.bmx"

'	CREATE INSTANCE OF PACKRAT PEG PARSER

Local parser:TPackratParser = New TPackratParser_PEG()

'TODO:
