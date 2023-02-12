
'	Github Modserver API test
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	FURTHER READING:
'	https://www.advancedinstaller.com/github-integration-For-updater.html

SuperStrict

'Import bmx.json
'Import bah.libcurl

Import "bin/TGitHub.bmx"
Import "bin/TRepository.bmx"

' Set platform specific filters
Global BLITZMAX_FILTER:String
?linux
		BLITZMAX_FILTER = "linux_x64"
?Win32x86
		BLITZMAX_FILTER = "win32_x86"
?Win32x64
		BLITZMAX_FILTER = "win32_x64"
?MacOSX64
		BLITZMAX_FILTER = "macos_x64"
?raspberrypiARM
		BLITZMAX_FILTER = "rpi_arm"
?

Global repo:String = "BlitzMax"
If AppArgs.length = 2; repo = AppArgs[1]
DebugStop

Local repository:TRepository = New TRepository().find( repo )
Local modserver:TGithub = New TGithub( repository )

Try
	Print "Checking '"+repository.name+"'"
	DebugStop
	Local releases:TList = modserver.getReleases( BLITZMAX_FILTER )
	Print "RELEASES:"
	For Local released:TRelease = EachIn releases
		Print released.reveal()
	Next
	Print "LATEST:"
	Local latest:TRelease = modserver.getLatest()
	Print latest.reveal()
Catch e:String
	Print e
End Try



Rem
node_id" - Update section name (Update key)
"item" - "Name"
"tag_name" - "Version"
"published_at" - "ReleaseDate"
"assets\browser_download_url" - "URL"
"assets\size" - "Size"
"asset\name" - "ServerFileName"
"body" - DescriptionHtml, FeatureHtml, EnhancementHtml, BugFixHtml

end rem