SuperStrict


Type TEST
	Field _meta:String="n/a"

	Method New()
		Local T:TTypeId = TTypeId.ForObject( Self )
		DebugStop
		If T.hasMetaData( "name" ) Print "HAS META"
		_meta = T.Metadata( "name" )
		show()
	End Method

	Method show()
		Local T:TTypeId = TTypeId.ForObject( Self )
		Print "META:"+_meta+" ("+T.metadata("name")
		
	End Method

 
	
End Type


Type EXAMPLE Extends TEST {name="example"}
	'Method New()
	'	Local T:TTypeId = TTypeId.ForObject( Self )
	'	DebugStop
	'	If T.hasMetaData( "name" ) Print "HAS META"
	'	_meta = T.Metadata( "name" )
	'End Method
End Type
DebugStop
DebugStop

Local T:Test = New Test()
Local E:Example = New Example()

t.show
e.show