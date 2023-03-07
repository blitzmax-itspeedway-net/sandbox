
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

' DEBUG COMMAND LINE:	install -in BlitzMaxNG

SuperStrict

Import bmx.json
'Import bah.volumes		' Now part of BlitzMaxNG, see brl.volumes
'Import brl.volumes

Import "bin/config.bmx"
Import "bin/TGitHub.bmx"

Import "bin/cmd_install.bmx"

'Import "bin/GUI.bmx"

Rem ARGUMENTS

bmax --version							Show Application version
bmax list								Show all modules
bmax show <module>						Show Module detail


bmax search <criteria>					NOT IMPLEMENTED
bmax download [package]					NOT IMPLEMENTED
bmax install <package>[.mod] [version]	NOT IMPLEMENTED
bmax uninstall <package>[.mod]			NOT IMPLEMENTED
bmax install -r requirements.txt         NOT IMPLEMENTED

bmax update		Updates self 			NOT IMPLEMENTED 

bmax compile <package> [-h|-a etc]		NOT IMPLEMENTED
bmax makedocs							NOT IMPLEMENTED

/u --update     Updates a package       NOT IMPLEMENTED
-r /r           Use a requirements file NOT IMPLEMENTED
--proxy         Use a proxy server      NOT IMPLEMENTED

End Rem

'Type TStringMapPlus Extends TStringMap
'	Method operator []:String( key:String )
'		Return String( valueForKey( key ) )
'	End Method
'End Type

' Use this for debugging available moduleinfo fields
Global ModInfo:TMap = New TMap()	

'	INITIAISE CONFIG AND CREATE FOLDERS

AppTitle = "bmax"
Local AppVersion:String = "0.0.0"

Try 
	CONFIG.initialise()
Catch Exception:String
	Print Exception
	End
End Try

Rem
	' Set up some operational variables
Global config:TStringMapPlus = New TStringMapPlus()
config["userhome"]      = GetUserHomeDir()
'config["desktop"]       = GetUserDesktopDir()
'config["userdata"]		= GetUserDesktopDir()
'consig["userdocs"]		= GetUserDocumentsDir()
'config["shareddata"]	= GetCustomDir( DT_SHAREDUSERDATA )


config["downloads"]     = config["blitzmax_root"]+config["directoryslash"]
config["blitzmax_bin"]  = config["userhome"]+config["directoryslash"]+"BlitzMax"+config["bin"]
config["blitzmax_src"]  = config["userhome"]+config["directoryslash"]+"BlitzMax"+config["bin"]
config["blitzmax_mod"]  = config["userhome"]+config["directoryslash"]+"BlitzMax"+config["bin"]
End Rem

DebugStop

'	PARSE ARGUMENTS

Local args:String[] = AppArgs[1..]
DebugLog( "## ARG COUNT: "+args.length )
For Local n:Int = 0 Until args.length
	DebugLog n+") "+args[n]
Next
Try
	If args.length = 0; Throw AppTitle+": No argument provided, try '--help' for more information"

	' Identify function
	Select args[0].toLower()
	Case "list"
		cmd_list()
	Case "show"
		Assert args.length=2 Else "?" 'AppTitle+": expected 1 argument, found "+args.length
		cmd_show( AppArgs[2] )
	Case "--debug"
		DebugStop
		cmd_debug( "all-modules.csv" )
	Case "install"
		DebugStop
		' With no arguments, we overwrite existing or install as default
		Select True
		Case args.length = 1
			cmd_install_blitzmax()
		Case args.length = 2 And args[1].toLower() = "--default"
			CONFIG.setRoot( "" )
			cmd_install_blitzmax()
		Case args.length = 3 And args[1].toLower() = "--in"
			CONFIG.setRoot( args[2] )
			cmd_install_blitzmax()
		Case args.length = 2 And Instr( args[1], "." ) > 0
			cmd_install_module()
		Case args.length = 2
			cmd_install_package()
		Default
			Throw( "Invalid arguments" )
		EndSelect
	'Case "search"
	'Case "download"		
	'Case "uninstall"
	'Case "update"
		' With no arguments we update to the latest offical release
	Case "--version"
		Print AppTitle+" "+AppVersion+" in "+AppDir
	Default
		Throw "Unknown command"
	End Select
Catch Exception:String
	Print AppTitle + ":ERROR, "+ Exception
EndTry
End

' Shows a list of all modules
Function cmd_debug( output:String )

	Local table:String[][] = [[ ..
		"ID", "FULL-CHECKSUM", "PART-CHECKSUM", "VERSION", ..
		"AUTHOR",	"COPYRIGHT", "CREDIT", "LICENSE",	  "TITLE",    "SUBJECT", ..
		"URL", 	"FRAMEWORK", "MODSERVER", "FILESIZE", "FILEDATE", ..
		"DEPENDENCIES" ..
		]]
	
	DebugStop
	Local modules:TList = EnumModules()	
	For Local modid:String = EachIn modules

		' Scan the source file for information
		Local scanner:TScanner = New TScanner()
		scanner.fullScan( modid )
		
		Local row:String[16]
		row[ 0]  = modid
		row[ 1]  = scanner["full-checksum"]
		row[ 2]  = scanner["part-checksum"]
		row[ 3]  = scanner["version"]
		row[ 4]  = scanner["author"]
		row[ 5]  = scanner["copyright"]
		row[ 6]  = scanner["credit"]
		row[ 7]  = scanner["license"]
		row[ 8]  = scanner["title"]
		row[ 9]  = scanner["subject"]
		row[10]  = scanner["url"]
		row[11]  = scanner["framework"]
		row[12]  = scanner["modserver"]
		row[13]  = scanner["filesize"]
		row[14]  = scanner["filedate"]

		Local dependencies:String[]
		For Local dependency:String = EachIn scanner.dependencies
			dependencies :+ [dependency]
		Next
		row[15]  = ";".join(dependencies)

		table :+ [row]
	Next
	
	' Display available ModuleInfo fields
	Print( "~nAVAILABLE MODULEINFO FIELDS:" )
	For Local info:String = EachIn ModInfo.keys()
		Print "ModuleInfo: "+info
	Next
	
	' WRITE TO CSV FILE
	Local file:TStream = WriteFile( output )
	If Not file RuntimeError "could not open debug file '"+output+"'"

	' Loop through rows showing data
	For Local row:Int = 0 Until table.length
		' Add quotes to all fields
		For Local col:Int = 0 Until table[row].length
			table[row][col] = Chr(34)+(table[row][col]).Trim()+Chr(34)
		Next
		Local line:String = ",".join( table[row] )
		WriteLine( file, line )
	Next
	CloseStream file
	Print "~nData written to '"+output+"'"

End Function

' Shows a list of all modules
Function cmd_list()

	Const COL_MODID:Int = 0
	Const COL_CHECKSUM:Int = 1
	Const COL_VERSION:Int = 2
	'Const COL_PATH:Int = 2
	'Const COL_SOURCE:Int = 3
	Local table:String[][] = [["ID","CHECKSUM","VERSION"]]
	'data :+ [["ID","PATH","SOURCE","VERSION"]]
	
	Local modules:TList = EnumModules()	
	For Local modid:String = EachIn modules

		' Scan the source file for information
		Local scanner:TScanner = New TScanner()
		scanner.fullScan( modid )
		
		Local row:String[3]
		row[COL_MODID]   = modid
		'row[COL_PATH]   = ModulePath( modid )
		'row[COL_SOURCE] = Modulesource( modid )
		row[COL_CHECKSUM] = "-"
		' get version
		row[COL_VERSION] = scanner["version"]
		table :+ [row]
	Next
	
	ShowTable( table )

End Function

' Shows details for a specific module
Function cmd_show( modid:String )
	Const COL_KEY:Int = 0
	Const COL_VALUE:Int = 1
	Local table:String[][]

	' Scan the source file for information
	Local scanner:TScanner = New TScanner()
	scanner.fullScan( modid )
	
	table :+ [ [ "NAME:",			modid ] ]
	table :+ [ [ "VERSION:", 		scanner["version"] ] ]
	table :+ [ [ "AUTHOR:", 		scanner["author"] ] ]
	table :+ [ [ "COPYRIGHT:", 		scanner["copyright"] ] ]
	table :+ [ [ "LICENSE:", 		scanner["license"] ] ]
	table :+ [ [ "TITLE:", 			scanner["title"] ] ]
	table :+ [ [ "SUBJECT:", 		scanner["subject"] ] ]
	table :+ [ [ "PATH:",			ModulePath( modid ) ] ]
	table :+ [ [ "SOURCE:",			Modulesource( modid ) ] ]
	table :+ [ [ "HOME:", 			scanner["url"] ] ]	' URL for download
	table :+ [ [ "FRAMEWORK:", 		scanner["framework"] ] ]
	table :+ [ [ "MODSERVER:", 		scanner["modserver"] ] ]
	table :+ [ [ "FILESIZE:", 		scanner["filesize"] ] ]
	table :+ [ [ "FILEDATE:", 		scanner["filedate"] ] ]
	table :+ [ [ "CHECKSUM:", 		scanner["full-checksum"] ] ]
	table :+ [ [ "DEPENDENCIES:", 	"" ] ]
	 
	ShowTable( table, False )
	
	For Local modname:String = EachIn scanner.dependencies
		Print " - "+modname
	Next
	
End Function

Function ShowTable( data:String[][], header:Int = True )

	' Create column width array
	Local width:Int[] = New Int[ data[0].length ]
	
	' Loop through rows finding column widths
	For Local row:String[] = EachIn data
		For Local col:Int = 0 Until row.length
			width[col] = Max( width[col], row[col].length )
		Next
	Next
	
	' Loop through rows showing data
	For Local row:Int = 0 Until data.length
		Local line:String
		For Local col:Int = 0 Until data[row].length
			line:+(data[row][col])[..width[col]]+" "
		Next
		Print line
		If header And row = 0; Print " "[..line.length].Replace(" ","-")
	Next
	
End Function

' Scans an validates a module and identifies vali
Type TScanner
	Private
	'Field Imports:TList
	'Field includes:TList
	'Field Types:TList
	'Field Functions:TList
	
	Const ST_PUBLIC:Int 		= 0	' Public declarations
	Const ST_PRIVATE:Int 		= 1	' Private / Protected declarations
	Const ST_REMARK:Int 		= 2	' Remarks
	Const ST_DIRECTIVE:Int 		= 3	' Compiler directive
		
	Field source:String
	Field lineno:Int
	Field filepos:Int
	Field line:String
	
	Field data:TStringMap = New TStringMap()
	Field dependencies:TList = New TList()
	
	Public
	
	' Extract everything we can from the module
	Method fullScan( modid:String )
	
		' Validate module
		Local file:String = ModuleSource( modid )
		If FileType( file ) <> FILETYPE_FILE; Return
		If ExtractExt( file ).ToLower() <> "bmx"; Return
		
		' Extract data from file
		data["modpath"]  = ModulePath( modid )
		data["filesize"] = String( FileSize( file ) )
		data["filedate"] = String( FileTime( file ) )
		source 	= LoadText( file )
		data["part-checksum"] = Hex( Adler32_Checksum( source, 1024 ) )
		data["full-checksum"] = Hex( Adler32_Checksum( source) )
		' Set up scanner
		filepos = 0		
		lineno	= 0
		
		'DebugStop
'		Local state:Int = ST_PUBLIC
		While filepos<Len(source)
			getNextLine()
			If Not line; Continue
			
			'DebugStop
			
			' Exclude Pragma
			If line.startswith( "@bmk" ); Continue

			' Strip line comments	
			Local n:Int = FindComment()
			If n>=0; line = line[..n]
			If Not line; Continue
			
			' Get line in lowercase to improve compare
			Local haystack:String = line.toLower()
			Select True
			Case haystack.startswith( "moduleinfo" )
				'DebugStop
				' We will now use the line because haystack is lowercase()
				Local info:String = line[10..].Trim() 
				If info.startswith(Chr(34)) And info.endswith(Chr(34))
					info = info[1..(info.length-1)].Trim()
				End If
				Local items:String[] = info.split(":")
				If items.length < 2; Continue
				items[0] = items[0].Trim().toLower()
				' This is to debug available fields
				ModInfo.insert( items[0], "ModuleInfo" )
				' Validate data
				If items[0] = "authors"; items[0] = "author"	' force into correct field
				If items[0] = "history"; Continue	' we dont need this.
				If items.length = 2
					data[ items[0] ] = items[1].Trim()
				Else ' >2
					data[ items[0] ] = " ".join( items[1..] ).Trim()
				End If
			Case haystack.startswith( "rem" )
				'DebugStop
				Local block:String = scanuntil( ["endrem","end rem"] )
			Case haystack.startswith( "import" )
				importing( line[7..].Trim(), String(data["modpath"]) )
Rem				'DebugStop
				' Must use line here, not haystack because we need case
				Local modname:String = line[7..].Trim()
				' Dequote filename
				If modname.startswith("~q") And modname.endswith("~q")
					' File imports
					modname = modname[1..(Len(modname)-1)]
					' Only interested in Blitzmax files
					If ExtractExt( modname ) = "bmx"
						'DebugStop
						Local childImport:TScanner = New TScanner()
						Local path:String = String(data["modpath"])
						childImport.scanForDependencies( joinpath(path,modname), dependencies )
					End If
				Else
					' Module Import
					dependencies.addLast( modname )
				End If
EndRem
			Case haystack.startswith( "include" )
				including( line[7..].Trim() )
Rem				DebugStop
				'TabPrint( [modid,"","INCLUDE",haystack[7..].Trim()] )
				'DebugStop
				' Must use line here, not haystack because we need case
				Local file:String = line[7..].Trim()
				' Dequote filename
				If file.startswith("~q") And file.endswith("~q"); file = file[1..(Len(file)-1)]
				' Validate file extension
				If ExtractExt( file ).ToLower() <> "bmx"; Continue
				' Get module path and join to file
				Local filepath:String = modulepath( modid )
				filepath = joinpath( filepath, file )
				' Read included file
				If FileType( filepath ) <> FILETYPE_FILE; Continue
				Local str:String = LoadText( filepath )
				'DebugStop
				' Insert into source stream
				'Print( "BEFORE:~n"+source )
				source = source[..filepos] + str + source[ filepos.. ]
				'Print( "AFTER:~n"+source )
				
				'DebugStop
End Rem
			End Select
		Wend
	End Method
	
	' Searches for a line comment
	' Ensures that the comment is not inside a string
	' There is probably a better way, but this will do for now...
	Method FindComment:Int()
		Local comment:Int = line.find( "'" )
		If comment < 0; Return comment
		' Line contains a comment

		Local quote:Int = line.find( Chr(34) )
		If quote < 0 Or comment < quote; Return comment
		' Line contains a quote before a comment
		'DebugStop
		' Scan the line until we know what is happening		
		Local dq:Int = True
		For Local pos:Int = quote+1 Until line.length
			Local ch:Int = Asc( line[pos..pos+1] )
			If ch=34		' Found a double quote
				dq = Not dq	
			ElseIf ch=39	' Found a single quote
				If Not dq; Return pos	' Comment outside of string
				comment = -1 ' Turn off the previous comment
			End If
		Next
		Return comment
	End Method

	Method scanForDependencies( filename:String, dependencies:TList )
		'DebugStop
		If FileType( filename ) <> FILETYPE_FILE; Return
		If ExtractExt( filename ).ToLower() <> "bmx"; Return
		
		' Extract data from file
		source 	= LoadText( filename )

		' Set up scanner
		filepos = 0		
		lineno	= 0
		
		'DebugStop
		Local state:Int = ST_PUBLIC
		While filepos<Len(source)
			getNextLine()
			If Not line; Continue
			
			'DebugStop
			
			' Exclude Pragma
			If line.startswith( "@bmk" ); Continue

			' Strip line comments
			Local n:Int = line.find( "'" )
			If n>=0; line = line[..n]
			If Not line; Continue
			
			' Get line in lowercase to improve compare
			Local haystack:String = line.toLower()
			Select True
			Case haystack.startswith( "rem" )
				'DebugStop
				Local block:String = scanuntil( ["endrem","end rem"] )
			Case haystack.startswith( "import" )
				importing( line[7..].Trim(), ExtractDir( filename ) )
Rem				'DebugStop
				' Must use line here, not haystack because we need case
				Local modname:String = line[7..].Trim()
				' Dequote filename
				If modname.startswith("~q") And modname.endswith("~q")
					' File imports
					modname = modname[1..(Len(modname)-1)]
					' Only interested in Blitzmax files
					If ExtractExt( modname ) = "bmx"
						'DebugStop
						Local path:String = ExtractDir( filename )
						Local childImport:TScanner = New TScanner()
						childImport.scanForDependencies( joinpath(path,modname), dependencies )
					End If
				Else
					' Module Imports
					dependencies.addLast( modname )
				End If
End Rem
			Case haystack.startswith( "include" )
				including( line[7..].Trim() )
Rem				'DebugStop
				'TabPrint( [modid,"","INCLUDE",haystack[7..].Trim()] )
				'DebugStop
				' Must use line here, not haystack because we need case
				Local file:String = line[7..].Trim()
				' Dequote filename
				If file.startswith("~q") And file.endswith("~q"); file = file[1..(Len(file)-1)]
				' Validate file extension
				If ExtractExt( file ).ToLower() <> "bmx"; Continue
				' Get module path and join to file
				Local path:String = ExtractDir( filename )
				path = joinpath( path, file )
				' Read included file
				If FileType( path ) <> FILETYPE_FILE; Continue
				Local str:String = LoadText( path )
				'DebugStop
				' Insert into source stream
				'Print( "BEFORE:~n"+source )
				source = source[..filepos] + str + source[ filepos.. ]
				'Print( "AFTER:~n"+source )
				
				'DebugStop
EndRem
			End Select
		Wend
	End Method

	Method importing( modname:String, folder:String )
		' Dequote filename
		If modname.startswith("~q") And modname.endswith("~q")
			' File imports
			modname = modname[1..(Len(modname)-1)]	' Dequote
			' Only interested in Blitzmax files
			If ExtractExt( modname ) = "bmx"
				Local scanner:TScanner = New TScanner()
				scanner.scanForDependencies( joinpath(folder,modname), dependencies )
			End If
		Else
			' Module Imports
			dependencies.addLast( modname )
		End If
	End Method
	
	Method including( file:String )
		' Dequote filename
		If file.startswith("~q") And file.endswith("~q"); file = file[1..(Len(file)-1)]
		' Validate file extension
		If ExtractExt( file ).ToLower() <> "bmx"; Return
		' Get module path and join to file
		Local path:String = ExtractDir( file )
		path = joinpath( path, file )
		' Read included file
		If FileType( path ) <> FILETYPE_FILE; Return
		Local str:String = LoadText( path )
		' Insert into source stream
		source = source[..filepos] + str + source[ filepos.. ]
	End Method		
Rem
	Method scantype( modid:String, typename:String )
		Local state:Int = ST_PUBLIC
		While filepos<Len(source)
			getNextLine()
			If Not line; Continue
			
			' Strip line comments
			Local n:Int = line.find( "'" )
			If n>=0; line = line[..n].Trim()
			If Not line; Continue
			
			' Deal with PRIVATE, PROTECTED and PUBLIC
			If line.startswith( "private" ) Or line.startswith( "protected" )
				scanuntil( ["endtype", "end type", "public"] )
				If Not line.startswith( "public" ); Return
				' Public can be followed by a method or field or function
				line = line[5..].Trim()
			End If
			
			' Get line in lowercase to improve compare
			Local haystack:String = line.toLower()
			Select True
			Case haystack.startswith( "field" )
'				DebugStop
				TabPrint( [modid,typename,"FIELD",line[5..].Trim()] )
			Case haystack.startswith( "global" )
'				DebugStop
				TabPrint( [modid,typename,"GLOBAL",line[6..].Trim()] )
			Case haystack.startswith( "function" )
'				DebugStop
				TabPrint( [modid,typename,"FUNCTION",line[8..].Trim()] )
				scanuntil( ["endfunction","end function"] )
			Case haystack.startswith( "method" )
'				DebugStop
				TabPrint( [modid,typename,"METHOD",line[6..].Trim()] )
				scanuntil( ["endmethod","end method"] )
			Case haystack.startswith( "type" )
				scanuntil( ["endtype","end type"] )
			Case haystack.startswith( "rem" )
				scanuntil( ["endrem","end rem"] )
			Case haystack.startswith( "endtype" ) Or haystack.startswith( "end type" )
				Return 
			End Select	
		Wend
	End Method
EndRem	

	Method scanUntil:String( closure:String[] )
		'Local state:Int = ST_PUBLIC
		
		Local block:String
		While filepos<Len(source)
			getNextLine()
			If Not line; Continue
		
			' Strip line comments
			Local n:Int = line.find( "'" )
			If n>=0; line = line[..n].Trim()
			If Not line; Continue
			
			' Get line in lowercase to improve compare
			Local haystack:String = line.toLower()
			
			Select True
			Case haystack.startswith( "rem" )
				scanuntil( ["endrem","end rem"] )
			Case haystack.startswith( "type" )
				scanuntil( ["endtype","end type"] )
			Case haystack.startswith( "function" )
				scanuntil( ["endfunction","end function"] )
			Case haystack.startswith( "method" )
				scanuntil( ["endmethod","end method"] )
			Case haystack.startswith( "extern" )
				skipUntil( ["endextern","end extern"] )
			Default
				For Local str:String = EachIn closure
					If haystack.startswith( str ) ; Return block
				Next
			EndSelect
			block :+ line + "~n"		
		Wend
		Return block
	End Method

	Method skipUntil:String( closure:String[] )
		'Local state:Int = ST_PUBLIC
		Local block:String
		While filepos<Len(source)
			getNextLine()
			If Not line; Continue
		
			' Strip line comments
			Local n:Int = line.find( "'" )
			If n>=0; line = line[..n].Trim()
			If Not line; Continue
			
			' Get line in lowercase to improve compare
			Local haystack:String = line.toLower()

			Select True
			Case haystack.startswith( "rem" )
				skipuntil( ["endrem","end rem"] )
			'Case haystack.startswith( "type" )
			'	scanuntil( ["endtype","end type"] )
			'Case haystack.startswith( "function" )
			'	scanuntil( ["endfunction","end function"] )
			'Case haystack.startswith( "method" )
			'	scanuntil( ["endmethod","end method"] )
			'Case haystack.startswith( "extern" )
			'	skipUntil( ["endextern","end extern"] )
			Default
				For Local str:String = EachIn closure
					If haystack.startswith( str ) ; Return block
				Next
			EndSelect
			block :+ line + "~n"		
		Wend
		Return block	
	End Method

	Method getNextLine()
		Local eol:Int = source.find( "~n", filepos )
		If eol = -1; eol = Len(source)	' End of file?
		lineno :+ 1
		line = source[ filepos..eol ].Trim()
		filepos = eol + 1
		'DebugStop
	End Method
	
'	Method EvalOpt:Int( state:Int, opt:String )
'		Return ST_PUBLIC
'	End Method
	
?win32
	Const DIR_SEPERATOR:String = "\"
?Not win32
	Const DIR_SEPERATOR:String = "/"
?
	
	Method joinpath:String( path1:String, path2:String )
		path1 = path1.Replace("\","/")
		path2 = path2.Replace("\","/")
		Local stub1:String[] = path1.split("/")
		For Local str:String = EachIn path2.split("/")
			If str="." Or str=""; Continue
			If str=".."
				stub1 = stub1[..(Len(stub1)-1)]
			Else
				stub1 :+ [str]
			End If
		Next
		Return DIR_SEPERATOR.join( stub1 )
	End Method
	
	Method operator []:String( key:String )
		If data.contains( key ); Return String(data.valueforkey( key ))
		Return "-"
	End Method
	
End Type

' Implementation of the Adler-32 algorithm
' https://en.wikipedia.org/wiki/Adler-32
' Author: Si Dunford
Function Adler32_Checksum:Int( data:String, bytes:Int = 0 )
	Local A:Int = 1, B:Int = 0, ch:Byte, n:ULong
	Local size:Int = Len( data )
	If bytes > 0; size = Min( bytes, size )
	For n = 0 Until size
		ch = data[n]
		A = (A+ch) Mod $FFFF
		B = (B+A) Mod $FFFF	
	Next
	Return B Shl 16 | A
End Function
