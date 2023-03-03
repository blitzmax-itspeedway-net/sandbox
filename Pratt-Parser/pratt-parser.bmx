
'	Pratt Parser
'	Based on code from here:
'	https://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/
'	https://github.com/munificent/bantam/tree/master/src/com/stuffwithstuff/bantam

SuperStrict

Import "bin/token.bmx"

Enum ETokenType
  LEFT_PAREN,
  RIGHT_PAREN,
  COMMA,
  ASSIGN,
  PLUS,
  MINUS,
  ASTERISK,
  SLASH,
  CARET,
  TILDE,
  BANG,
  QUESTION,
  COLON,
  NAME,
  Eof
Rem 
  '
  ' If the TokenType represents a punctuator (i.e. a token that can split an
  ' identifier like '+', this will get its text.
  '

  Public Character punctuator() {
    switch (this) {
    Case LEFT_PAREN:  Return '(';
    Case RIGHT_PAREN: Return ')';
    Case COMMA:       Return ',';
    Case ASSIGN:      Return '=';
    Case PLUS:        Return '+';
    Case MINUS:       Return '-';
    Case ASTERISK:    Return '*';
    Case SLASH:       Return '/';
    Case CARET:       Return '^';
    Case TILDE:       Return '~';
    Case BANG:        Return '!';
    Case QUESTION:    Return '?';
    Case COLON:       Return ':';
    Default:          Return Null;
    }
  }
EndRem

End Enum

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

