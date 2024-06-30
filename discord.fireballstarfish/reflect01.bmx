SuperStrict

Framework brl.StandardIO
Import brl.reflection

Type TExample
	Field name:String
	Field surname:String 
End Type

DebugStop
Local example:TExample = New TExample()
Local tid:TTypeId = TTypeId.forObject( example )
'Local tid:TTypeId = TTypeId.forName( "TExample" )

'For Local fld:TField = EachIn tid.EnumFields()
'
'	Print "FIELD: "+fld.name()
'	If fld.hasmetadata( "title" ); Print "- "+fld.metadata("title")
'Next

Print "Done"





