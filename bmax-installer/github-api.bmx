SuperStrict
'https://www.advancedinstaller.com/github-integration-For-updater.html

Import bmx.json
Import bah.libcurl

Const GITHUBAPI:String = "http://api.github.com/repos/"

Global modserver:String = "GITHUB"
Global modrepo:String = "bmx-ng/bmx-ng"
DebugStop
Print AppArgs.length
If AppArgs.length = 2; modrepo = AppArgs[1]

Print "Checking '"+modserver+":"+modrepo+"'"

DebugStop
Local api:String  = GITHUBAPI + modrepo + "/releases"

Local wget:String
Try
	wget = download( api )
	
	Print wget
	
	Local J:JSON = JSON.parse( wget )
	If J.isinvalid()
		Print( J.error() )
		Print( J.GetLastError() )
	Else
		Print J.Prettify()
	End If
Catch Exception:String
	Print Exception
EndTry

Function download:String( url:String )
	Local curl:TCurlEasy = TCurlEasy.Create()
	If curl<>Null
		curl.setWriteString()
		'curl.setOptInt( CURLOPT_VERBOSE, 1 )
		curl.setOptInt( CURLOPT_FOLLOWLOCATION, 1)
		curl.setOptString( CURLOPT_CAINFO, "certificates/cacert.pem" )
		curl.setOptString( CURLOPT_URL, url )
		curl.httpHeader( ["User-Agent: BlitzMaxNG", "Referer:"] )
	EndIf
	Local error:Int = curl.perform()
	If error; Throw CurlError( error )
	curl.cleanup()
	Return curl.toString()
End Function

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