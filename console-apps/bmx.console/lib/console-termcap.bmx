
'
'	Console Library for BlitzMax
'	(c) Copyright Si Dunford [Scaremonger], May 2025
'

Import "TConsoleBase.bmx"
	
?linux

Import "console-termcap.c"
Import "-lncurses"

Extern
	' Get the Terminal type
	Function tgetent:Int( bp:Byte Ptr, name:Byte Ptr )
	' Get terminal capability
	Function tgetflag:Int( id$z )
	Function tgetnum:Int( id$z )
	Function tgetstr$z( id$z, area:Byte Ptr )
	Function tgoto$z( cap$z, col:Int, row:Int )
	Function tputs:Int( str$z, count:Int, putchar:Int(ch:Int) )
	' Putchar
	Function putchar:Int( ch:Int )
End Extern

' Define Terminal Capabilites
Enum TERMCAPS
	cl	' Clear the screen, cursor to 0,0
	cd	' Clear current line and everythign below
	ce	' Clear from cursor to end of line
	ec	' Clear "n" characters from current position
	cm	' Cursor Move
	ho	' Home Cursor
	ll	' Move Cursor to lower left
	cr	' Carriage return (Same line)
	le	' Move left one column
	nd	' Move right one column
	up	' Move cursor up one row
	do	' Move cursor down one row
	nw	' Move cursor to first column of next line
	ch	' Cursor to column in current row
	cv	' Cursor to row in current column
	vs	' Enhanced Cursor
	vi	' Invisible cursor (Hide) 
	ve	' Normal editing cursor
EndEnum
	
Type TConsole Extends TConsoleBase

	'Field termbuf:Byte[2048]
	Field termtype:String
	Field CMD:String[]	' Command codes
	
	' Control codes
Rem
	Field _CL:String	' Clear the screen, cursor to 0,0
	Field _CD:String	' Clear current line and everythign below
	Field _CE:String	' Clear from cursor to end of line
	Field _EC:String	' Clear "n" characters from current position
	Field _CM:String	' Cursor Move
	Field _HO:String	' Home Cursor
	Field _LL:String	' Move Cursor to lower left
	Field _CR:String	' Carriage return (Same line)
	Field _LE:String	' Move left one column
	Field _ND:String	' Move right one column
	Field _UP:String	' Move cursor up one row
	Field _DO:String	' Move cursor down one row
	Field _NW:String	' Move cursor to first column of next line
	Field _CH:String	' Cursor to column in current row
	Field _CV:String	' Cursor to row in current column
	Field _VS:String	' Enhanced Cursor
	Field _VI:String	' Invisible cursor (Hide) 
	Field _VE:String	' Normal editing cursor

	' SCREEN SIZE
	'Field _CO:Int		' co - Number of Columns
	'Field _LI:Int		' li - Number of Lines		
EndRem		
	
	Method New()
	
		termtype = getenv_( "TERM" )
		'DebugLog( "TERMINAL TYPE: "+termtype )
		If termtype = 0
			consoleError( "Please set a terminal type with 'setenv TERM <termtype>'." )
		EndIf
		
		Local state:Int = tgetent( 0, termtype )
		If state<0
			consoleError( "Unable to get termcap database for terminal type '"+termtype+"'." )
		ElseIf state=0
			consoleError( "Terminal type '"+termtype+"' is not defined." )
		EndIf
		DebugLog( "Terminal type '"+termtype+"' exists in termcap database." )
	
		' Extract Control sequences for commands
				
		'Print "LENGTH="+Len(TERMCAPS.values())
		CMD = New String[Len(TERMCAPS.values())]
		For Local CAP:TERMCAPS = EachIn TERMCAPS.values()
			'Print "Reading "+CAP.ToString()
			cmd[CAP] = tgetstr( CAP.ToString(), 0 )
			'If cmd[CAP].ToString() = ""
			'	Print( "FAILED TO GET '"+CAP.ToString()+"'" )
			'	End
			'EndIf
		Next

		' Flags - Not sure what to do with these yet!!
		Local flag:Int = tgetflag( "am" )
		'Print( "AM: "+["FALSE","TRUE"][flag] )
		'flag = tGetFlag( "XXX" )
		'Print( "TEST: "+["FALSE","TRUE"][flag] )
		'Local temp:String = tget

Rem
		_CL = tgetstr( "cl", 0 )
		_CD = tgetstr( "cd", 0 )
		_CE = tgetstr( "ce", 0 )
		_EC = tgetstr( "ec", 0 )
		_CM = tgetstr( "cm", 0 )
		_HO = tgetstr( "ho", 0 )
		_LL = tgetstr( "ll", 0 )
		_CR = tgetstr( "cr", 0 )
		_LE = tgetstr( "le", 0 )
		_ND = tgetstr( "nd", 0 )
		_UP = tgetstr( "up", 0 )
		_DO = tgetstr( "do", 0 )
		_NW = tgetstr( "nw", 0 )
		_CH = tgetstr( "ch", 0 )
		_CV = tgetstr( "cv", 0 )

		If _CL = CMD[TERMCAPS.CL] Print "YAHOO"
EndRem
		'Print "CL     ="+debug(_CL)
		
		
		' SCREEN SIZE
		W = tgetnum( "co" )
		H = tgetnum( "li" )
		'Print( "Screen size: "+ W + "," + H )

	End Method
	
	Method Update()
	End Method

	Method write( Text:String )
		WriteStdout( Text )
	End Method
	
	Method write( x:Int, y:Int, Text:String )
		Local command:String = tgoto( CMD[TERMCAPS.CM], x, y )
		tputs( command, 1, putchar )
		WriteStdout( Text )
	End Method
	
	Method move( x:Int, y:Int )
		WriteStdout( tgoto( CMD[TERMCAPS.CM], x, y ) )
	End Method
	
	Method home()
		WriteStdout( CMD[TERMCAPS.HO] )
	End Method		

End Type

?
