'package com.stuffwithstuff.bantam;

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

