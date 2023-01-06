SuperStrict

Local app:TApp = New TApp()

Graphics 320,200

Repeat
	Cls
	Draw()
	Draw( "A) Flip active state ["+["DISABLED","ENABLED"][app.active]+"]" )
	Draw( "M) Add to queue      ["+app.GetNextEventCount+"]" )
	Draw( "Q) Quit" )
	If KeyHit( KEY_A ); app.active = Not app.active
	If KeyHit( KEY_M ); app.add( "Pressed at "+MilliSecs() )
	If KeyHit( KEY_Q ); app.quit = True
	'Delay(1)
	app.update()
	Flip
Until AppTerminate() Or app.quit

Function draw( Text:String="" )
	Global vy:Int = 0
	If Not Text; vy = 0
	DrawText( Text, 5, vy )
	vy :+ 10
End Function

Type TApp

	'Field sleepMutex:TMutex
	'Field sleeper:TCondVar

	'Field queuemutex:TMutex
	Field queue:TList

	'Field thread:TThread
	
	Field active:Int = True
	Field quit:Int = False
	Field playerid:Int = 2

	Method New()
		queue:TList = New TList()
		'queuemutex = CreateMutex()

		'sleeper = CreateCondVar()
		'thread = CreateThread( ThreadFN, Self )		
	End Method
	
	Method add( message:String )
		'LockMutex( queuemutex )
		queue.addlast( message )
		'UnlockMutex( queuemutex )
		'sleeper.signal()
		Print( "ADDED:    '"+message+"'" )
	End Method
	
	Method GetNextEventCount:Int()
		Local count:Int
		'LockMutex( queuemutex )
		count = queue.count()
		'UnlockMutex( queuemutex )
		Return count
	End Method
	
	Method isActive:Int()
		Return active
	End Method
	
	Method update()
		'LockMutex( queuemutex )
		Local message:String = String( queue.removeFirst() )
		'UnlockMutex( queuemutex )

		If Not message; Return
		Print( "RECEIVED: '"+message+"'" )
	End Method
	
	'Function ThreadFN:Object( data:Object )
	'	Local this:TApp = TApp( data )
	'	
	'	Local sleeperMutex:TMutex = CreateMutex()
	'	
	'	Print( "Thread start" )
	'	LockMutex( sleeperMutex )
    '    Repeat
    '        If this.GetNextEventCount() = 0 Or Not this.IsActive()
    '            If Not this.IsActive() And this.playerID = 2
    '                'Delay(1000)
	'				this.sleeper.timedwait( sleeperMutex, 550 )
    '                Print this.playerID + " waiting done " + MilliSecs()
    '            Else
	'				'Delay(50)
    '                this.sleeper.timedwait( sleeperMutex, 50 )
    '            EndIf
	'		End If
	'		this.update()
	'	Until this.quit
	'	UnlockMutex( sleeperMutex )
	'	
	'	Print( "Thread exit" )
	'End Function
	

End Type

' Override Print() with Debuglog()
Function Print( message:String )
	DebugLog( message )
End Function
