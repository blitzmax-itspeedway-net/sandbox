SuperStrict
' CONVERSION TOOL
' (c) Copyright Si Dunford, Blitz Community, 2022
'
' This tool takes a Wayback Machine archive and makes it usable
'

Import text.regex

Const src:String = "/home/si/archive/mojolabs.nz_2021-05-11/"
Const HEADER_CONTENT:String[][] = [ ..
	[ "home", "Home", "index.html", "" ],..
	[ "forum", "Forums", "forums/index.html", "" ],..
	[ "code", "Code Archives", "codearcs/index.html", "" ],..
	[ "worklogs", "Worklogs", "logs/index.html", "" ],..
	[ "gallery", "Gallery", "gallery/index.html", "" ],..
	[ "specs", "Specs", "sdkspecs/index.html", "" ],..
	[ "website", "Website", "http://blitzdev.org", "Right" ] ]

Function substitute:String( needle:String, haystack:String, replacement:String )
	Local regex:TRegEx = TRegEx.Create( needle )	
	Try
		Return regex.ReplaceAll( haystack, replacement )  
	Catch e:TRegExException
		Print "Error : " + e.toString()
	End Try
	Return ""
End Function  

Function convert:String( file_in:String, file_out:String, active:String )

	Local file:TStream 
	Local content:String
	Local start:Int = MilliSecs()

	Print file_in + " ("+FileSize( file_in )+" bytes)"
	
	' READ THE FILE
	file = ReadFile( file_in )
	content = LoadString( file )
	CloseFile( file )

	' Remove old Menubars
	content = substitute( "<td class=~qmenubarleft~q></td>", content, "" )
	content = substitute( "<td class=~qmenubar~q><table.*</table></td>", content, "" )
	
	' Remove empty table rows
	
	' Inject new header	
	Local header:String = "<div id=~qblitzdev~q><ul>"
	For Local link:String[] = EachIn HEADER_CONTENT
		header :+ "<li"
		Local classes:String = link[3]
		If link[0]=active ; classes :+ " active"
		If classes<>"" ; header :+ " class=#q"+ Trim( classes ) +"~q"
		header :+ "><a href=~q" + link[2] + "~q>" + link[1] + "</a></li>"
	Next
	header :+ "</ul></div>"
	content = substitute( "<body>", content, "<body>"+header )

	' Update single-line HTML to mulit-line to make debugging easier
	content = substitute( "<(?!/)", content, "~n<" )

	' Clean up HTML
	content = substitute( "\s>", content, ">" )		' Spaces before closing ">"

	' WRITE THE FILE
	file = WriteFile( file_out )
	WriteString( file, content )
	CloseFile( file )
	
	Print "- DONE ("+ (MilliSecs()-start) + " ms)"

End Function


Local dst:String = "mojolabs.nz/forums/"
Local data:String = convert( src+"codearcs.php?code=1766", dst+"codearcs-1766.html" )
'Local data:String = convert( src+"forums.html", dst+"forums.html" )

