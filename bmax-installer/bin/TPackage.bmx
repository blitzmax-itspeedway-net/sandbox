
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

' This type acts as both the package manager AND the package itself

SuperStrict

Import bmx.json

'Import "TModserver.bmx"
'Import "TRelease.bmx"
'Import "TRepository.bmx"
'Import "datetime.bmx"

Type TPackage

	Field name:String
	
	Method New( name:String )
		Self.name = name
	End Method
	
	Method install:Int()
	End Method
	
	Method uninstall:Int()
	End Method
	
End Type

#packages
DefData "BlitzMax", "{




