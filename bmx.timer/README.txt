
LOW RESOLUTION TIMER

I wrote this as more of an experiment!

It all started whilst I was looking at a simple animation in Javascript and I wondered how SetTimeout() and 
setInterval() were implemented because there didn't seem to be any limit on the number you could create. 

In Windows, there is a limit of just 16 timers so you need some careful coding if you want to create lots 
of them (There was a post about this on the old Blitzbasic forum, but I cannot find it).

Behind the scene; Javascript and Node both use a list to hold active timers which is sorted by the time that
the timer will be called. The event loop simply checks the current time against the header of the list and
if it has expired, the callback is executed. setInterval() does exactly the same except it adds itself back
into the list after activation.

A Timeout will wait for the requested time and then run.
An Interval will repeat on the duration you provide.

A Timeout or an Interval can be created to call a Handler function (like Javascript) or send an Event:

USING A HANDLER:

    setInterval( 500, fire )
    setTimeout( 1000, bang )
     
    Function bang( context:Object )
	    Print "BANG!" 
    End Function

    Function fire( context:Object )
	    Print "FIRE!" 
    End Function

USING AN EVENT

    AddHook( EmitEventHook, eventhook )
     
    setInterval( 500 )
    setTimeout( 1000 )
     
    Function eventhook:Object( id:Int, data:Object, context:Object )
	    Local event:TEvent = TEvent( data )
	    If event.id=TIMERTICK Print event.tostring()
	    Return data
    End Function

You can also pass an object or string to the timer as per these examples and they will be passed to your 
handler or event in the context variable. You simply need to typecast this to a string or your object type.

SENDING CONTEXT DATA:

    ' Timers with Handlers
    setInterval( 500, fire, "MyString" )
    setTimeout( 1000, bang, MyObject )
     
    ' Timers with events
    setInterval( 500, "MyString" )
    setTimeout( 1000, MyObject )

If you save the result of the setTimer() or setInterval() into a variable, you have the option of cancelling the timer:

CREATE AND CANCEL

    local myTimeout:TLowResTimer = setInterval( 500 )
    local myInterval:TLowResTimer = setTimeout( 1000 )
     
    clearTimeout( myTimeout )
    clearInterval( myInterval )

clearTimeout() and clearInterval() are identical; they can be interchanged and can also be replaced with the following:

    local myTimeout:TLowResTimer = setInterval( 500 )
    myTimeout.cancel()

To integrate it into your application, you can either call update() within your game loop or attach it to the fliphook:

CALLING UPDATE IN YOUR GAME LOOP:

    Import "timers.bmx"
    Graphics 300,200
    Repeat
	    Cls
	    TLowResTimer.update()      'Update Timers
	    Flip
    Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

Or you can attach it to the Flip Hook, which cleans up your game loop a little:

NOTE: This will reduce the resolution of the timers to about 16ms

ATTACH TO FLIP HOOK

    Import "timers.bmx"
    TLowResTimer.UseFlipHook()      'Attach to Flip Hook

    Graphics 300,200
    Repeat
	    Cls
	    Flip
    Until KeyHit( KEY_ESCAPE ) Or AppTerminate()


