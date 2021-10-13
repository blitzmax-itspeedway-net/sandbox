
'	WORKSPACE MANAGER
'	(c) Copyright Si Dunford, October 2021, All Rights Reserved

Type Workspaces

	Global list:TMap = New TMap()
	
	' workspace/did_change_workspace_folders
	Function did_change_workspace_folders( event:String )	':JSON )
		
		'added = event.find( "added" )
		'removed = event.find( "removed" )
		
		Rem
		for local item:string = eachin removed
			list.remove( item )
		next
		
		for local item:string = eachin added
			local file_uri:string = item.find("uri")
			list.insert( 
			
			' workspaceconfig = config.config( file_uri, default_options )
			list.insert( file_uri, new TWorkspace( file_uri )
		next
		
		
		End Rem
		
	End Function

	' Find a workspace for a given file
	Method get:TWorkspace( file_uri:String )
		If Not file_uri ; Return Null
		
		Local doc:URI = URI.file( file_uri )
		
		' Match workspaces
		For Local workspace:TWorkspace = EachIn list
			If workspace.workspace.scheme = doc.scheme And ...
			   workspace.workspace.authority = doc.authority And ...
			   workspace.workspace.path = doc.path Then
				Return workspace
			End If
		Next
		
	End Method
	

End Type

Type TWorkspace

	Field workspace:URI

	Field documents:TMap
	Field rooturi:String

	Method New( rooturi:String )
		Self.rooturi = rooturi
		documents = New TMap()
	End Method

	Method documents:TMap()
		Return documents()
	End Method
	
	' Return or Create a given document
	Method get:TTextDocument( doc_uri:String )
		Local document:TTextDocument = TTextDocument( documents.valueForKey( doc_uri ) )
		If document ; Return document
		Return CreateDocument( doc_uri )
	End Method
	
	Method Create:TTextDocument( doc_uri:String, content:String = "", version:ULong = 0 )
		Return New TTextDocument( doc_uri, content, version )
	End Method
	
	Method remove( doc_uri:String )
		documents.remove( doc_uri )
	End Method
	
	Method update( doc_uri, change, version:ULong=0 )
		Local document:TTextDocument = TTextDocument( documents.valueForKey( doc_uri ) )
		If Not document ; Return
		document.applychange( chnage )
		document.version = version
	End Method
	
	Function finduri( uri )
	
End Type