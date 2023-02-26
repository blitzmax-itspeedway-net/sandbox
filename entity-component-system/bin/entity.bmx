
'	Entity
'	(c) Copyright Si Dunford, Feb 2028, All Rights Reserved

'	EXPERIMENTAL

Rem

	An entity is a handle, but unlike a pure ECS that uses an array, we
	are using Indirection List Handles. 

End Rem

SuperStrict

Import handles.bmx

Type TEntity Extends THandle

	Field tag:String
	'Field context:SContext
	
End Type




