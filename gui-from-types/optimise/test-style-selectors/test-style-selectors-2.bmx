SuperStrict
'V2 using String
' 290ms
' 270ms after pre-applying # to name
' 245ms after pre-applying "." to classes
' 182ms after moving rootname to outer loop
' 140ms after moving basename to outer loop

'V2 using SSelector array
' 370ms with stack backup/restore
' 291ms with backup outside loop
' 263ms with restore at loop start
' 259ms with restore in if -1

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

Type SSelector

	Field data:String[10]
	Field cursor:Int = 0
	
	Method push( value:String )
		data[cursor]=value
		cursor :+ 1
	End Method
	
	Method pop:String()
		'data[cursor]=""
		cursor :- 1
		If cursor<0; cursor = 0
	End Method

	Method backup:Int()
		Return cursor
	End Method

	Method restore( backup:Int )
		'data[cursor]=""
		cursor = backup
		'If cursor<0; cursor = 0
	End Method
		
	Method toString:String()
		Return "".join(data[..cursor])
	End Method
	
	Method isEmpty:Int()
		Return ( cursor = 0 )
	End Method
	
	Method clear()
		cursor = 0
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


Local selector:SSelector = New SSelector()
Local bitbackup:Int, classbackup:Int

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
		selector.clear()
		If (bitmask & $1); selector.push( typename )
		If (bitmask & $2)
			If Not name; Continue			' If name is blank (should't be)
			selector.push( widname )
		End If
		
		bitbackup = selector.backup()
		For Local class:Int = -1 Until classes.length
			If class>-1
				selector.restore( bitbackup )
				selector.push( classname[class] )
			End If
			classbackup = selector.backup()
			For Local flag:Int = -1 Until flagname.length
				If flag>-1
					selector.restore( classbackup )
					selector.push( flagname[flag] )
				End If
				'
				If selector.isEmpty(); Continue
					'Local t:String = (bitmask+"/"+class+"/"+flag+": ")
					'Print t[..8]+selector.toString()
					
					loops :+1
				'End If
			Next
			
		Next	
	Next
'DebugStop
Next
Print "loops="+loops
Print MilliSecs()-start+"ms"