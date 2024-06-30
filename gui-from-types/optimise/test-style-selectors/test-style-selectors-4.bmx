SuperStrict
Rem TIMINGS
V1 using String
 290ms
 270ms after pre-applying # to name
 245ms after pre-applying "." to classes
 182ms after moving rootname to outer loop
 140ms after moving basename to outer loop

'V2 using SSelector array
' 370ms with stack backup/restore
' 291ms with backup outside loop
' 263ms with restore at loop start
' 259ms with restore in if -1

V3 using SSelector array
 305ms with stack push/pop

V4 using TStringBuilder
 942ms
 334ms Using cursors to remove last run
End Rem

'Next version should keep pointer And truncate/restore the stringbuilder at loop End

Type SFlag
	Field flag:Int
	
	Method New( flag:Int )
		Self.flag = flag
	End Method
	
	Method isSet:Int( mask:Int )
		Return ( flag & mask ) = mask
	End Method
	
	Method set( mask:Int )
		flag :| mask
	End Method
	
	Method unset( mask:Int )
		flag = flag & ~mask
	End Method

	Method isZero:Int()
		Return flag = 0
	End Method

	Method toString:String()
		Return Bin( flag )
	End Method
		
End Type

Const FLAG_DISABLED:Int = $1
Const FLAG_HOVER:Int = $2
Const FLAG_FOCUS:Int = $4

Local typename:String = "tlabel"
Local name:String = "myname"
Local classes:String[] = ["one","two","three"]
Local flags:SFlag = New SFlag(FLAG_DISABLED|FLAG_HOVER|FLAG_FOCUS)


Rem
Local test:SSelector = New SSelector()
test.push( typename )
test.push( "#" )
test.push( name )
test.push( "." )
test.push( "four" )
test.pop()
Print test.toString()
EndRem


Local selector:TStringBuilder = New TStringBuilder()
'Local rootname:TStringBuilder = New TStringBuilder()
'Local basename:TStringBuilder = New TStringBuilder()
Local bitcursor:Int, classcursor:Int

Local loops:Int = 0
Local start:Int = MilliSecs()
For Local iteration:Int = 1 To 10000

	Local flagname:String[]
	'Local attr:Int = flags.flag
	'If ( attr & FLAG_DISABLED ) = FLAG_DISABLED; flagname :+ [":disabled"]
	'If ( attr & FLAG_HOVER ) = FLAG_HOVER; flagname :+ [":hover"]
	'If ( attr & FLAG_FOCUS ) = FLAG_FOCUS; flagname :+ [":focus"]
	If flags.isset( FLAG_DISABLED ); flagname :+ [":disabled"]
	If flags.isset( FLAG_HOVER ); flagname :+ [":hover"]
	If flags.isset( FLAG_FOCUS ); flagname :+ [":focus"]

	Local widname:String = "#"+name
	Local classname:String[] = New String[Len(classes)]
	For Local index:Int = 0 Until classes.length
		classname[index] = "."+classes[index]
	Next
		
	' bitmask
	' 0000 = none
	' 0001 = typename
	' 0010 = name
	' 0011 = typename#name
	'DebugStop
	For Local bitmask:Int = 0 To 3
		selector = New TStringBuilder()
		If (bitmask & $1); selector.append( typename )
		If (bitmask & $2)
			If Not name; Continue			' If name is blank (should't be)
			selector.append( widname )
		End If
		bitcursor = selector.length()
		For Local class:Int = -1 Until classes.length
			'basename = New TStringBuilder( rootname.tostring() )
			If class>-1
				selector.remove( bitcursor, selector.length() )
				selector.append( classname[class] )
			End If
			classcursor = selector.length()
			For Local flag:Int = -1 Until flagname.length
				'# Create match string
				'selector = New TStringBuilder( basename.tostring() )
				If flag>-1
					selector.remove( classcursor, selector.length() )
					selector.append( flagname[flag] )
				EndIf
				'	
				If selector.length()=0; Continue
				'Local t:String = (bitmask+"/"+class+"/"+flag+": ")
				'Print t[..8]+selector.toString()

				loops :+1
			Next
		Next	
	Next
'DebugStop
Next
Print "loops="+loops
Print MilliSecs()-start+"ms"