SuperStrict

'Framework BRL.StandardIO

'Import brl.textstream
Import BRL.ByteBuffer
'Import BRL.Retro
'Import BRL.timer

Print "* Loading file "

Local int_array:Int[]
Local byte_array:Byte[]
Local compress_array:Byte[]
Local stream:TStream = ReadStream("top_level.bit")

int_array = int_array[ .. StreamSize:Long( stream:TStream ) ]  ' debug for testing
Print int_array.length ' prints the same as above

If Not stream RuntimeError "Failed to open a ReadStream "

' load bitfile in one go
byte_array=LoadByteArray:Byte[](stream)        ' this works

Local sliding_window:TByteArrayBuffer = New TByteArrayBuffer( byte_array ) '.length)
sliding_window.PutBytes(byte_array, byte_array.length)    ' this creates an error say putbytes not found


Print " closing file "
CloseStream(stream)

'sync word 0xAA995566 start of file
' will have to reverse bit order
Local nibble_reverse_array:Byte[] = [0,8,4,$C,2,$A,6,$E,1,9,5,$D,3,$B,7,$F]
Local reversed_byte:Byte
Local timeclk:Int = MilliSecs () ' profile code
For Local j:Int = 0 To byte_array.length-1
'  reversed_byte=0
  reversed_byte=nibble_reverse_array[(byte_array[j] & $0F)] Shl 4
  reversed_byte=nibble_reverse_array[((byte_array[j] & $F0) Shr 4)] ~ reversed_byte ' OR together
  'Print Hex(reversed_byte)
Next
timeclk=MilliSecs()-timeclk ' end profile code time
Print timeclk                ' time taken to reverse byte bits i.e. 7<>0, 6<>1 etc

Print " end *"
