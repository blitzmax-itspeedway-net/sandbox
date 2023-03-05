
'	Pratt Parser
'	Based on code from here:
'	https://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/
'	https://github.com/munificent/bantam/tree/master/src/com/stuffwithstuff/bantam

SuperStrict

Import "bin/Token.bmx"
Import "bin/Lexer.bmx"
'Import "bin/ParseException.bmx"

Rem
Interface Expression
	Method Print( builder:TStringBuilder )
End Interface

class ConditionalExpression Implements Expression {
  Public ConditionalExpression(
      Expression condition,
      Expression thenArm,
      Expression elseArm) {
    this.condition = condition;
    this.thenArm   = thenArm;
    this.elseArm   = elseArm;
  }

  Public Final Expression condition;
  Public Final Expression thenArm;
  Public Final Expression elseArm;
}


}
End Rem

Global sPassed:Int = 0
Global sFailed:Int = 0

'
' Parses the given chunk of code And verifies that it matches the expected
' pretty-printed result.
'
Function test( source:String, expected:String )
	Local lexer:TLexer = New TLexer( source )
	Local parser:TParser = New BantamParser( lexer )

	Try
	  Local result:Expression = parser.parseExpression()
	  Local builder:StringBuilder = New StringBuilder()
	  result.Print(builder)
	  Local actual:String = builder.toString()
	  
	  If (expected.Equals(actual))
		sPassed :+ 1
	  Else
		sFailed :+ 1
		Print( "[FAIL] Expected: " + expected )
		Print( "         Actual: " + actual )
	  End If
	Catch ex:ParseException
	  sFailed :+ 1
	  Print( "[FAIL] Expected: " + expected )
	  Print( "          Error: " + ex.getMessage() )
	End Try
End Function

' Function call.
test("a()", "a()")
test("a(b)", "a(b)")
test("a(b, c)", "a(b, c)")
test("a(b)(c)", "a(b)(c)")
test("a(b) + c(d)", "(a(b) + c(d))")
test("a(b ? c : d, e + f)", "a((b ? c : d), (e + f))")

' Unary precedence.
test("~~!-+a", "(~~(!(-(+a))))")
test("a!!!", "(((a!)!)!)")

' Unary And binary predecence.
test("-a * b", "((-a) * b)")
test("!a + b", "((!a) + b)")
test("~~a ^ b", "((~~a) ^ b)")
test("-a!",    "(-(a!))")
test("!a!",    "(!(a!))")

' Binary precedence.
test("a = b + c * d ^ e - f / g", "(a = ((b + (c * (d ^ e))) - (f / g)))")

' Binary associativity.
test("a = b = c", "(a = (b = c))")
test("a + b - c", "((a + b) - c)")
test("a * b / c", "((a * b) / c)")
test("a ^ b ^ c", "(a ^ (b ^ c))")

' Conditional operator.
test("a ? b : c ? d : e", "(a ? b : (c ? d : e))")
test("a ? b ? c : d : e", "(a ? (b ? c : d) : e)")
test("a + b ? c * d : e / f", "((a + b) ? (c * d) : (e / f))")

' Grouping.
test("a + (b + c) + d", "((a + (b + c)) + d)")
test("a ^ (b + c)", "(a ^ (b + c))")
test("(!a)!",    "((!a)!)")

' Show the results.
If (sFailed = 0)
  Print("Passed all " + sPassed + " tests.")
Else
  Print("----")
  Print("Failed " + sFailed + " out of " + (sFailed + sPassed) + " tests.")
EndIf



