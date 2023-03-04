
' Low Resolution Timers for Blitzmax
' Public Domain, Supplied without warranty
' Author Si Dunford, May 2021

Rem CHANGE LOG

V1.0 - Created setTimeout(), setInterval(), TLowResTimer (Using events)
V1.1 - Added useflip as option instead of update() plus onexit to detach fliphook
V1.2 - Expanded settimeout() and setinterval() to use handlers
V1.3 - Replaced list sort with insert that maintains sort order (10*faster)
V1.4 - Fixed timer accuracy - Thanks @Midimaster :)

End Rem

SuperStrict

'Import brl.event

Global TIMERTICK:Int = AllocUserEventId( "TimerTick" )

Function setTimeout:TLowResTimer( duration:Int, context:Object = Null )
	Return New TLowResTimer( duration, 0, Null, context )
End Function

Function setTimeout:TLowResTimer( duration:Int, handler( context:Object ), context:Object = Null )
	Return New TLowResTimer( duration, 0, handler, context )
End Function

Function setInterval:TLowResTimer( frequency:Int, context:Object = Null )
	Return New TLowResTimer( frequency, frequency, Null, context )
End Function

Function setInterval:TLowResTimer( frequency:Int, handler( context:Object ), context:Object = Null )
	Return New TLowResTimer( frequency, frequency, handler, context )
End Function

Function clearTimeout( timer:TLowResTimer )
	If timer timer.cancel()
End Function

Function clearInterval( timer:TLowResTimer )
	If timer timer.cancel()
End Function

Type TLowResTimer

	Private
	
	Global list:TList = New TList
	Global initialised:Int = False
	Global useflip:Int = False

	Field link:TLink
	
	Field timeout:Int				' When to activate
	Field frequency:Int				' Repeating interval
	Field handler( context:Object )	' Handler function
	
	Public
	
	Field context:Object			' Object context

	Method New( timer:Int, frequency:Int, handler( context:Object ), context:Object )
		If Not initialised initialise()
		Self.timeout   = MilliSecs() + timer
		Self.frequency = frequency
		Self.handler   = handler
		Self.context   = context
		Self.link      = insert( Self )
	End Method

	Method cancel()
		link.remove()
	End Method

	' Manual method
	Function update()
		For Local timer:TLowResTimer = EachIn list
			If timer.timeout>MilliSecs() Exit
			timer.activate()
		Next
	End Function

	' Add "On-Flip" event handler
	Function UseFlipHook()
		If Not initialised initialise()
		If Not useflip AddHook( FlipHook, TLowResTimer.hook )
		useflip = True
	End Function
	
	Private

	' Add event handler and exit function
	Function initialise()
		If Not initialised OnEnd( TLowResTimer.depart )
		initialised = True
	End Function

	' Insert into list maintaining sort order
	Function insert:TLink( timer:TLowResTimer )
		Local t:TLowResTimer
		Local link:TLink = TLowResTimer.list.firstlink()
		While link 
			t = TLowResTimer(link.value())
			If t.timeout > timer.timeout Return list.insertBeforeLink( timer, link )
			link = link.nextlink()
		Wend
		' Not found, add to end
		Return ListAddLast( list, timer )
	End Function
		
	Method activate()
		link.remove()	' Kill existing timer
		' Repeat timer
		If frequency>0
            ' @Midimaster - Fix timing accuracy problem
			timeout = timeout + frequency
            'timeout = MilliSecs() + frequency
            ' @Midimaster - END
			link = insert( Self )
		End If

		If handler
			handler( context )
		Else
			Local event:TEvent = CreateEvent( TIMERTICK, Self, 0, 0, 0, 0,context )
			EmitEvent( event )
		End If
	End Method
	
	' Flip hook
	Function hook:Object( id:Int, data:Object, context:Object )
		TLowResTimer.update()
		Return data
	End Function

	' Exit function
	Function depart()
		If useflip RemoveHook( FlipHook, hook )
		useflip = False
	End Function	

End Type


