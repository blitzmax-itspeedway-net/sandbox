

Const KIND_NONE:Int             = 0
Const KIND_CHAR:Int             = 1  ' Any character

Const KIND_DIGIT:Int            = 2  ' [0-9]
Const KIND_ALPHA:Int            = 3  ' [A-Z,a-z]
Const KIND_ALPHANUMERIC:Int     = 4  ' [A-Z,a-z,0-9]
Const KIND_HEXDIGIT:Int         = 5  ' [A-Z,a-f,0-9]

Const KIND_SQUOTE:Int           = 6  ' Single Quote

Const KIND_NUMBER:Int           = 7  ' [0-9]* "." [0-9* / [0-9]*
Const KIND_ANY:Int              = 8  ' .

Const KIND_LITERAL:Int          = 9  ' 
Const KIND_CAPTURE:Int          = 10  ' 
Const KIND_CHOICE:Int           = 11  ' 
Const KIND_NAMED:Int            = 12  ' 
Const KIND_SEQUENCE:Int         = 13  ' ? / ? ..
Const KIND_FLOAT:Int            = 14  ' nnnn.nn

Const KIND_ERROR:Int            = 15
Const KIND_WHITESPACE:Int       = 16  ' \s\t\n\r
Const KIND_EOL:Int              = 17

Global KINDSTR:String[] = [..
	"NONE", "CHAR", "DIGIT", "ALPHA", "ALPHANUMERIC", "HEXDIGIT", ..
	"SQUOTE", "NUMBER", "ANY", "LITERAL", "CAPTURE", "CHOICE", "NAMED", ..
	"SEQUENCE", "FLOAT", "ERROR", "WHITESPACE", "EOL"..
	]


