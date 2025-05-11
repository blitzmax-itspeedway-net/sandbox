SuperStrict

Framework brl.StandardIO
Import brl.reflection

Struct SExample
	Field name:String
	Field surname:String 
End Struct

DebugStop
Local example:SExample = New SExample()
Local tid:TTypeId = TTypeId.forObject( example )
'Local tid:TTypeId = TTypeId.forName( "SExample" )

For Local fld:TField = EachIn tid.EnumFields()

	Print "FIELD NAME: "+fld.name()
	If fld.hasmetadata( "title" ); Print "- "+fld.metadata("title")
Next

'GCCollect
Print "Done"





