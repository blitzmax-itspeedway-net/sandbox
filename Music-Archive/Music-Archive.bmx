SuperStrict
' (c) Copyright Si Dunford, April 2023
'Takes a folder full of music files and extracts Artist, Album, Track and name
'Then creates a new folder for it and moves the track

Import Text.RegEx

'DebugStop

Global OUTPUT:String = CurrentDir() + "/Music"

Function parseDir( folder:String, regex:String )
	If folder = OUTPUT; Return
	Print( "DIR     "+folder )
	If StripDir(folder).startswith("."); Return
	Local files:String[] = LoadDir( folder )
	
	For Local name:String = EachIn files
	
		Local path:String = folder + "/" + name
	
		Select FileType( path )
		Case FILETYPE_FILE;		parsefile( folder, name, regex )
		Case FILETYPE_DIR;		parseDir( path, regex )
		Default
			Print "ERROR ("+FileType( path )+") "+path
			End
		End Select
	
	Next
	
End Function

Function parseFile( folder:String, filename:String, regex:String )
	Print( "FILE    "+folder+"/"+filename )
	Local ext:String = Lower( ExtractExt( filename ) )
	If ext = "bmx" Or ext="debug" Or ext="exe"; Return
	
	'DebugStop 
	'Local regex:TRegEx = TRegEx.Create("(.*)\-(.*)[-/]([0-9]*)[-/](.*)")
	'Local regex:TRegEx = TRegEx.Create("(.*)\s?\-\s?(.*)\s?\-\s?([0-9]*)\s?\-\s?(\..*)")
	Local REX:TRegEx = TRegEx.Create(regex)
	Local path:String = folder + "/" + filename
	
	Try

		Local match:TRegExMatch = REX.Find( filename )
		If match
			If match.subcount() = 6
				'DebugStop
				Local Artist:String = Trim( match.SubExp(1) )
				Local Album:String  = Trim( match.SubExp(2) )
				Local Track:String = Trim( match.SubExp(3) )
				Local Name:String  = Trim( match.SubExp(4) )
				Print "Artist: "+Artist+", Album: "+Album+", "+Track+"-"+Name

				Local AName:String = Artist
				If Lower(artist).startswith("the ")
					AName = Artist[4..]+", The"
				End If
				'DebugStop

				' ARTIST ALBUM TRACK NAME
				Local dir:String = OUTPUT+"/"+AName
				If album<>""; dir :+ " - "+Album
				If FileType( dir ) = 0; CreateDir( dir, True )
				
				Local file:String = AName + " - " + Album + " - " + track + "-"+Name
				
				If Not RenameFile( path, dir+"/"+file )
					Print( "FILE    "+folder+"/"+file )
					If FileType( dir+"/"+file )=FILETYPE_FILE
						Print "- File already exists"
					Else
						Print "- Failed to copy"
					End If
				End If
						
			Else
				Print( "FILE    "+folder+"/"+filename )
				Print( "Matches="+match.SubCount() )
				For Local i:Int = 0 Until match.SubCount()
					Print i + ": " + match.SubExp(i)
				Next
				End
			End If
		Else
			Print( "FILE    "+folder+"/"+filename )
			Print( "ERROR: No match" )
			End
		End If
		'While match

		'	Print "~nMATCH-"
		'	For Local i:Int = 0 Until match.SubCount()
		'		Print i + ": " + match.SubExp(i)
		'	Next

		'	match = regex.Find()
		'Wend

	Catch e:TRegExException
		Print( "FILE    "+folder+"/"+filename )
		Print "Error : " + e.ToString()
		End
		
	End Try

	'DebugStop
	
	
End Function

parsedir( CurrentDir(), "(.*)\s+-\s+(.*)\s+-\s+(\d*)[\s-]+(.*)(\..*)" )

