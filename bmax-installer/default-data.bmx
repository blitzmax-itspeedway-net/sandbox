' DEFAULT DATABASE

' STATIC PACKAGE INFORMATION USED AS DEFAULT

'	name		The name of the package
'	revision	The revision. If higher than existign database, it will be overwritten
'	repository	The repository where this package is located
'	source		The folder in the ZIP file containing the files
'	filter		The path in the ZIP file we will extract
'	target		The folder we will unzip into

' NOT IMPLEMENTED
'	package		PROGRAM/MODULE etc
'	type		RELEASE or ZIP
'	modserver	May be redundant
'	actions		NOT YET IMPLEMENTED

Global DEFAULT_PACKAGES:String = """
[	
	{
		"name":"blitzmax",
		"revision":0,
		"repository":"bmx-ng",
		"folder":"BlitzMax/",
		"target":"", 
		"latest":[ 
			"brl.mod", 
			"pub.mod", 
			"audio.mod", 
			"text.mod", 
			"random.mod", 
			"sdl.mod", 
			"net.mod", 
			"image.mod", 
			"maxgui.mod", 
			"database.mod", 
			"archive.mod", 
			"math.mod" ]
	},{
		"name":"maxide",
		"revision":0,
		"package":"PROGRAM",
		"type":"ZIP",
		"modserver":"blitzmaxng",
		"repository":"maxide"
	},{
		"name":"bmx.json",
		"revision":0,
		"Package":"MODULE",
		"type":"ZIP",
		"modserver":"blitzmaxmods",
		"repository":"bmx.timestamp"
	},{
		"name":"bmx.timestamp",
		"revision":0,
		"Package":"MODULE",
		"type":"ZIP",
		"modserver":"blitzmaxmods",
		"repository":"bmx.timestamp",
		"commit":"timestamp.bmx"
	},{
		"name":"bah.libcurl",
		"revision":0,
		"Package":"MODULE",
		"type":"ZIP",
		"modserver":"maxmods",
		"repository":"bah.mod",
		"folder":"libcurl.mod",
		"target":"mods/bah.mod/libcurl.mod"
	}
]
"""

Global DEFAULT_REPOSITORIES:String = """
[
	{
	"name":"bmx-ng",
	"revision":0,
	"platform":"GITHUB",
	"path":"bmx-ng/bmx-ng"
	},{
	"name":"bah.mod",
	"revision":0,
	"platform":"GITHUB",
	"path":"maxmods/bah.mod"
	},{
	"name":"itspeedway",
	"revision":0,
	"platform":"GITHUB",
	"path":"blitzmax-itspeedway-net/sandbox.mod"
	},{
	"name":"blitzmaxmods",
	"revision":0,
	"platform":"GITHUB",
	"path":"blitzmaxmods/blitzmax-installer"
	}
]
"""


Global DEFAULT_MODSERVERS:String = """
[
	{
		"name":"blitzmaxng",
		"description":"Blitzmax Official Modserver",
		"type":"GITHUB",
		"username":"bmx-ng",
	},{
		"name":"maxmods",
		"description":"Bruceys Modules",
		"type":"GITHUB",
		"username":"maxmods"	
	},{
		"name":"blitzmaxmods",
		"description":"Scaremongers Modules",
		"type":"GITHUB",
		"username":"blitzmaxmods"	
	}
]
"""

'#repositoriesOLD
'DefData "\\"

'       NAME        MODSERVER  REPO      SRC                FOLDER  TARGET
'#packages1
'DefData "blitzmax", "bmx-ng",  "bmx-ng", MODSERVER_RELEASE, "",     ""
'DefData "maxide",   "bmx-ng",  "maxide", MODSERVER_ZIP,     "",     "src/maxide"
'DefData "\\"

'#modserversOLD
'       NAME,           MODSERVER TYPE    REPONAME,  REVISION, DESC
'DefData "bmx-ng",       MODSERVER_GITHUB, "",        0,        "BlitzMaxNG"
'DefData "maxmods",      MODSERVER_GITHUB, "",        0,        "Bruceys Blitzmax Modules"
'DefData "blitzmaxmods", MODSERVER_GITHUB, "sandbox", 0,        "Scaremongers modules"
'DefData ""


'       NAME,            PACKAGE TYPE     MODSERVER       REPONAME         ZIPFILE PATH,  REVISION

'#packagesOLD
'DefData "blitzmaxng",    PACKAGE_PROGRAM, "blitzmaxng",   "bmx-ng",        "",            0
'DefData "blitzmax",      PACKAGE_PROGRAM, "blitzmaxng",   "bmx-ng",        "",            0
'DefData "bcc",           PACKAGE_PROGRAM, "blitzmaxng",   "bcc",           "",            0
'DefData "bmk",           PACKAGE_PROGRAM, "blitzmaxng",   "bmk",           "",            0
'DefData "bls",           PACKAGE_PROGRAM, "blitzmaxmods", "bls",           "",            0
'DefData "bmax",          PACKAGE_PROGRAM, "blitzmaxmods", "bmax",          "",            0

'DefData "bah.libcurl",   PACKAGE_MODULE,  "maxmods",      "bah.mod",       "libcurl.mod", 0       
'DefData "bmx.timestamp", PACKAGE_MODULE,  "blitzmaxmods", "bmx.timestamp", "",            0        
'DefData "bmx.json",      PACKAGE_MODULE,  "blitzmaxmods", "bmx.json",      "",            0        
'DefData "bmx.observer",  PACKAGE_MODULE,  "blitzmaxmods", "bmx.observer",  "",            0     

#help_syntax
DefData ""
DefData "Syntax:"
DefData "    bmax <command> <options>"
DefData "    bmax help <command>"
DefData ""
DefData "Commands:"
DefData "  help       - Provides help on given command"
DefData "  install    - Install a package"
DefData "  remove     - Remove a package"
DefData "  update     - Update installed packages"
DefData "  list       - Show installed packages"
DefData "  modserver  - Maintain repositories"
DefData "  repo       - (Alias for modserver)"
DefData "  version    - Show current bmax version"
DefData "  set        - Manage configuration"
DefData ""
DefData "install options:"
DefData ""
DefData "set options:"
DefData "\\"

'
'   },
'  "installer":{
'    "bah.libcurl": {
'      "modserver": "maxmods",
'      "repository": "",
'      "download":{
'        "url":"",
'        "unzip": 1,
'        "sourcepath": ""
'		},
'      "target": "mods/bah.mod/libcurl.mod/",
'      "compile": {
'		}
'	},
'  },
'}
'"""

'#modservers
'       NAME,           MODSERVER TYPE    REPONAME,  REVISION, DESC
'DefData "bmx-ng",       MODSERVER_GITHUB, "",        0,        "BlitzMaxNG"
'DefData "maxmods",      MODSERVER_GITHUB, "",        0,        "Bruceys modules"
'DefData "blitzmaxmods", MODSERVER_GITHUB, "sandbox", 0,        "Scaremongers modules"
'DefData ""

'#packages
'       NAME,            PACKAGE TYPE     MODSERVER       REPONAME         ZIPFILE PATH,  REVISION
'DefData "maxide",        PACKAGE_PROGRAM, "blitzmaxng",   "maxide",        "",            0
'DefData "bmx.timestamp", PACKAGE_MODULE,  "blitzmaxmods", "bmx.timestamp", "",            0
'DefData "bah.libcurl",   PACKAGE_MODULE,  "maxmods",      "bah.mod",       "libcurl.mod", 0         
'DefData ""

'#installer
'       NAME      SOURCE PATH   EXEPATH
'DefData "maxide", "${BMX_SRC}", "${BMX_ROOT}" 
'DefData ""

'DefData "blitzmaxng",    PACKAGE_PROGRAM, "blitzmaxng",   "bmx-ng",        "",            0
'DefData "blitzmax",      PACKAGE_PROGRAM, "blitzmaxng",   "bmx-ng",        "",            0
'DefData "bcc",           PACKAGE_PROGRAM, "blitzmaxng",   "bcc",           "",            0
'DefData "bmk",           PACKAGE_PROGRAM, "blitzmaxng",   "bmk",           "",            0
'DefData "bls",           PACKAGE_PROGRAM, "blitzmaxmods", "bls",           "",            0
'DefData "bmax",          PACKAGE_PROGRAM, "blitzmaxmods", "bmax",          "",            0

'DefData "bah.libcurl",   PACKAGE_MODULE,  "maxmods",      "bah.mod",       "libcurl.mod", 0       
'DefData "bmx.timestamp", PACKAGE_MODULE,  "blitzmaxmods", "bmx.timestamp", "",            0        
'DefData "bmx.json",      PACKAGE_MODULE,  "blitzmaxmods", "bmx.json",      "",            0        
'DefData "bmx.observer",  PACKAGE_MODULE,  "blitzmaxmods", "bmx.observer",  "",            0       
