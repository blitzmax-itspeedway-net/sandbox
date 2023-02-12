
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

SuperStrict

Type TRepository
	'Const GITHUB:Int = 0

	Global initialised:Int
	Global repositories:TMap
	
	Field name:String
	Field username:String
	Field repo:String
	'Field platform:Int
	
	Function Initialise()
DebugStop
		If initialised; Return
		repositories = New TMap()
		initialised  = True

		Local name:String, username:String, repo:String
		RestoreData repositories
		ReadData( name )
		ReadData( username )
		ReadData( repo )
		
		While Name
			New TRepository( name, username, repo )
			ReadData( name )
			If name
				ReadData( username )
				ReadData( repo )
			End If
		Wend

	End Function

	Method New( name:String, username:String, repo:String )
		Self.name     = name
		Self.username = username
		Self.repo     = repo
		repositories.insert( name.toLower(), Self )
	End Method

	Method find:TRepository( repository:String )
		Return TRepository( repositories.valueForKey( repository.toLower() ) )
	End Method
	
	Method workspace:String()
		Return username + "/" + repo
	End Method

End Type
TRepository.initialise()

#repositories
DefData "BlitzMax", "bmx-ng", "bmx-ng"	'	,TRepository.GITHUB
DefData ""


