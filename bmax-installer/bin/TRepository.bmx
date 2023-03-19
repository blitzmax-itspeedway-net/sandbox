
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved



SuperStrict

'Global API:String = "http://api.github.com/repos/{USERNAME}/{REPO}/contents/{FILEPATH}"

Type TRepository
	'Const GITHUB:Int = 0

	Global initialised:Int
	Global repositories:TMap
	
	Field name:String
	Field repo:String
	'Field platform:Int
	
	Function Initialise()
'DebugStop
		If initialised; Return
		repositories = New TMap()
		initialised  = True

		Local name:String, repo:String
		RestoreData repositories
		ReadData( name )
		ReadData( repo )
		
		While Name
			New TRepository( name, repo )
			ReadData( name )
			If name
				ReadData( repo )
			End If
		Wend

	End Function

	Method New( name:String, repo:String )
		Self.name     = name
		Self.repo     = repo
		repositories.insert( name.toLower(), Self )
	End Method

	Method find:TRepository( repository:String )
		Return TRepository( repositories.valueForKey( repository.toLower() ) )
	End Method
	
	'Method workspace:String()
	'	Return username + "/" + repo
	'End Method
	
	' Format a temporary cache filename for this repository
	Method filename:String()
		Return name+"."+repo.Replace("/",".")+".releases.cache"
	End Method

End Type
TRepository.initialise()

#repositories
DefData "BlitzMax", "bmx-ng/bmx-ng"	'	,TRepository.GITHUB
DefData ""


