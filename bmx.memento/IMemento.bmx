
SuperStrict

Rem
    Need to update this to process a list of objects using IMemento
    Look at backup/restore using TBanks that are added together into a binary stream on disk.
    - Network modules might help with the compressing of data into the bank a bit like a packet.
END REM

Import bmx.json

Interface IMemento
	Method backup:JSON()
	Method restore( J:JSON )
End Interface

Type TAlien Implements IMemento
	Field x:Int, y:Int

	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
	End Method

	Method backup:JSON()
		Local J:JSON = New JSON()
		J["location|x"] = x
		J["location|y"] = y
		Return J
	End Method
	
	Method restore( J:JSON )
		x = J.find("location|x").toInt()
		y = J.find("location|y").toInt()
	End Method
End Type

Type TPlayer Implements IMemento
	Field name:String, x:Int, y:Int

	Method New( name:String, x:Int, y:Int )
		Self.name = name
		Self.x = x
		Self.y = y
	End Method

	Method backup:JSON()
		Local J:JSON = New JSON()
		J["name"] = name
		J["location|x"] = x
		J["location|y"] = y
		Return J
	End Method
	
	Method restore( J:JSON )
		name = J.find("name").toString()
		x = J.find("location|x").toInt()
		y = J.find("location|y").toInt()
	End Method
End Type

' Create some variables
Local alien:TAlien, alienBackup:JSON
Local player:TPlayer, playerBackup:JSON
alien  = New TAlien( 10,20 )
player = New TPlayer( "Scaremonger", 30,16 )

' Backup the data into JSON
alienBackup  = alien.backup()
playerBackup = player.backup()

' Blank the originals
alien  = New TAlien()
player = New TPlayer()

' Restore the data
alien.restore( alienBackup )
player.restore( playerBackup )

' Test!
Print( "PLAYER: "+player.name )
Print( "X:      "+player.x )
Print( "Y:      "+player.y )

Print( "ALIEN:  " )
Print( "X:      "+alien.x )
Print( "Y:      "+alien.y )


