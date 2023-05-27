
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

' This type acts as both the package manager AND the package itself

'SuperStrict

'Import "TModserver.bmx"
'Import "config.bmx"
'Import "TRelease.bmx"
'Import "TRepository.bmx"
'Import "datetime.bmx"

Const PACKAGE_NONE:Int = 0
Const PACKAGE_CURRENT:Int = 1
Const PACKAGE_OFFICIAL:Int = 2
Const PACKAGE_LATEST:Int = 3

Const PACKAGE_MODULE:Int = 0
Const PACKAGE_PROGRAM:Int = 1	' BCC, BMK, MAXIDE, BLS, BMAX, etc.
Const PACKAGE_SOURCE:Int = 2	

Type TPackage
	Global list:TMap = New TMap()

	Field name:String
	Field description:String
	Field revision:Int = 0
	'Field package:String
	'Field modserver:String
	'Field class:String		{serializedname="type"}				' (0) = Module, (1)=Program
	Field repository:String
	Field commitfile:String {serializedname="commit"}

	' Fields used to access data inside an archive file
	Field folder:String		' Folder inside archive
	Field target:String		' Target folder (Relative to BMX_ROOT)

	'Field modserver:TModserver
	'Field username:String
	'Field repository:String
	'Field zippath:String
	'Field ismodule:Int = False

	'Field installed:Int = PACKAGE_NONE

	'Field versions:TPackageDetail[3]
	
	'Field current:TPackageDetail		' The installed version
	'Field official:TPackageDetail		' The offical version
	'Field latest:TPackageDetail			' The latest version

	'Function find:TPackage( name:String )
	'	Return TPackage( list.valueforkey( name ) )
	'End Function
	

	
	' UNTESTED
	'Function load( db:JSON )
	'	DebugStop
	'	Local junction:JSON = db.find( "packages", True )
	'	For Local package:TPackage = EachIn junction.keys()
	'		DebugStop
	'		list.insert( package.name, package )
	'	Next
	'End Function
	
	' UNTESTED
	'Function save( db:JSON )
	'	DebugStop
	'	Local junction:JSON = db.find( "packages", True )
	'	For Local package:TPackage = EachIn list
	'		Local J:JSON = New JSON.serialise( package )
	''		junction.addlast( J )
	'	Next
	'End Function
	
	'Function add( package:TPackage )
	'	If package And package.name; list.insert( package.name, package )
	'End Function

	'Method New( name:String )
	'	Self.name = name
	'End Method
	
	'Method New( name:String, class:Int, modserver:TModserver, username:String, reponame:String, zippath:String )
	'	Self.name = name
	'	Self.class = class
	'	Self.modserver = modserver
	'	Self.username = username
	'	Self.reponame = reponame
	'	Self.zippath = zippath
	'End Method
	
	'Method install:Int( revision:Int )
		' Update the official/latest package details
	'	If revision = PACKAGE_NONE; Return uninstall()
		
		' Get installer.json from modserver
		'modserver.getfile( "installer.json", username, reponame, zippath, revision )
	'End Method
	
	'Method uninstall:Int()
		' Uninstall is simply the removal of the module / package...
		' ha ha... not actually that simple...
	'End Method

	' Retrieve a Repository for a package
	Function get:TPackage( name:String )		
		' Get package from database
		Local JPackage:JSON = DATABASE.get( "packages", name )
		If Not JPackage; Return Null
		' Create package object
		'Local package:TPackage = New TPackage( JPackage )
		'Return package
		Return TPackage( JPackage.Transpose( "TPackage" ) )
	End Function
	
	'Method New( JPackage:JSON )
	'	name       = JPackage.find( "name" ).toString()
	'	repository = JPackage.find( "repository" ).toString()
	'End Method

	Method getLastCommit:String()
		Local repo:TRepository = New TRepository().get( repository )
		If Not repo Return ""
		
		DebugStop
		Local commit:String = commitfile
		If commit = ""; commit = "package.json"
		
		Local lastcommit:String = repo.getLastCommit( commit )
	End Method
	
End Type

'Type TPackageDetail
'	Field checksum:Long
'	Field version:String
'	Field filedate:Long	'TIMESTAMP
'End Type








