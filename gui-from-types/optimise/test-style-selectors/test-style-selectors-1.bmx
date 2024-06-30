SuperStrict
' 290ms
' 270ms after pre-applying # to name
' 245ms after pre-applying "." to classes
' 182ms after moving rootname to outer loop
' 140ms after moving basename to outer loop
' 170ms using cursors to save previous pointers! (Abandoned)
' 		Note: It is quicker to copy a string than to splice the end off existing

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

Local selector:String, rootname:String, basename:String
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
	For Local bitmask:Int = 0 To 3
		rootname = ""
		If (bitmask & $1); rootname = typename
		If (bitmask & $2)
			If Not name; Continue			' If name is blank (should't be)
			rootname :+ widname
		End If
		
		For Local class:Int = -1 Until classes.length
			basename = rootname
			If class>-1; basename :+ classname[class]
			For Local flag:Int = -1 Until flagname.length
				'# Create match string
				selector = basename
				If flag>-1; selector :+ flagname[flag]
				'
				If Not selector; Continue
				'Local t:String = (bitmask+"/"+class+"/"+flag+": ")
				'Print t[..8]+selector

				loops :+1
			Next
		Next	
	Next
'DebugStop
Next
Print "loops="+loops
Print MilliSecs()-start+"ms"