'package com.stuffwithstuff.bantam;
'
'Import java.util.HashMap;
'Import java.util.Iterator;
'Import java.util.Map;

Import "Token.bmx"

'
' A very primitive lexer. Takes a String And splits it into a series of
' Tokens. Operators And punctuation are mapped To unique keywords. Names,
' which can be any series of letters, are turned into NAME tokens. All other
' characters are ignored (except To separate names). Numbers And strings are
' Not supported. This is really just the bare minimum To give the parser
' something To work with.
'
Type Lexer Implements Iterator<Token>

  Field mPunctuators:Map<Character, TokenType>  = New HashMap<Character, TokenType>()
  Field mText:String 
  Field mIndex:Int = 0

  '
  ' Creates a New Lexer To tokenize the given String.
  ' @param text String To tokenize.
  '
	Method New( text:String ) 
		Local mIndex:Int = 0
		Local mText:String = text 

		' Register all of the TokenTypes that are explicit punctuators.
		For Local TokType:TokenType = EachIn TokenType.values()
			Local punctuator:Character = TokType.punctuator()
			If punctuator <> Null
				mPunctuators.put( punctuator, TokType )
			EndIf
		Next
	End Method
  
  '@Override
  Method hasNext:Int() Override
    Return True
  End Method

  '@Override
  Method Succ:Token() Override
    While mIndex < mText.length()
		mIndex :+ 1
      char c = mText.charAt(mIndex)
      
      If (mPunctuators.containsKey(c))
        ' Handle punctuation.
        Return New Token(mPunctuators.get(c), Character.toString(c));
      Else If (Character.isLetter(c))
        ' Handle names.
        localstart:Int = mIndex - 1
        While mIndex < mText.length()
          If Not Character.isLetter( mText.charAt( mIndex )) Then Exit
          mIndex :+ 1
        Wend
        
        Local name:String = mText.substring(start, mIndex)
        Return New Token(TokenType.NAME, name);
      Else
        ' Ignore all other characters (whitespace, etc.)
      EndIf
    Wend
    
    ' Once we've reached the end of the string, just return EOF tokens. We'll
    ' just keeping returning them as many times as we're asked so that the
    ' parser's lookahead doesn't have to worry about running out of tokens.
    Return New Token( ETokenType.Eof, "" )
  EndMethod

  '@Override
  Method remove() Override
    Throw New UnsupportedOperationException()
  EndMethod

EndType

