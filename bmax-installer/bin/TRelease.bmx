
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'SuperStrict

Type TRelease
	Field author:String
	Field name:String
	Field size:Long
	Field url:String
	Field version:String
	'Field published:String
	
	Method New( name:String, version:String, author:String, size:Long, url:String )
		Self.author  = author
		Self.name    = name
		Self.size    = size
		Self.url     = url
		Self.version = version
	End Method
	
	Method reveal:String()
		Return name+", "+version+" by "+author+", "+size+ "bytes" 
	End Method
End Type
