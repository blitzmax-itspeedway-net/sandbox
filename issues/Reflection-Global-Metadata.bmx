SuperStrict

Framework BRL.Reflection
Import BRL.StandardIO
DebugStop

Type Test
    Global Tx1:Int { test="hello!" }
	Field Tx2:Int { testing="Hi" }
End Type

Local tid:TTypeId=TTypeId.ForName( "Test" )

Local g:TGlobal=tid.FindGlobal( "Tx1" )
Local f:TField=tid.FindField( "Tx2" )

Print g.name()
Print g.MetaData( "test" )

Print f.name()
Print f.MetaData( "testing" )
