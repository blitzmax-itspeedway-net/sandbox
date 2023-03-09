
'	ZLIB wrapper
'	(c) Copyright Si Dunford, March 2023, All Rights reserved
'
'	https://www.zlib.net/manual.html
'
SuperStrict

Import pub.zlib

Extern
	
	Function __adler32_z:UInt(adler:ULong, buf:Byte Ptr, length:Size_T) = "unsigned long adler32_z(unsigned long, const void *, size_t )"
	Function __adler32:UInt(adler:ULong, buf:Byte Ptr, length:UInt) = "unsigned long adler32(unsigned long, const void *, unsigned int)"
	Function __adler32_combine:UInt(adler1:ULong, adler2:ULong, len2:Size_T) = "unsigned long adler32_combine(unsigned long, unsigned long, size_t)"
	Function __adler32_combine64:UInt(adler1:ULong, adler2:ULong, len2:Size_T) = "unsigned long adler32_combine64(unsigned long, unsigned long, size_t)"

?win32 Or ptr32
	Function __compressBound:UInt( sourceLen:UInt ) = "compressBound OF((uLong sourceLen))"
'	Function __compress:Int( dest:Byte Ptr,dest_len:UInt Var,source:Byte Ptr,source_len:UInt )="int compress(void *, unsigned long *, const void *, unsigned long)"
'	Function __compress2:Int( dest:Byte Ptr,dest_len:UInt Var,source:Byte Ptr,source_len:UInt,level:Int )="int compress2(void *, unsigned long *, const void *, unsigned long , int)"
	Function __uncompress:Int( dest:Byte Ptr,dest_len:UInt Var,source:Byte Ptr,source_len:UInt )="int uncompress(void *, unsigned long *, const void *, unsigned long)"
?ptr64 And Not win32
	Function __compressBound:ULong( sourceLen:ULong ) = "compressBound OF((uLong sourceLen))"
'	Function __compress:Int( dest:Byte Ptr,dest_len:ULong Var,source:Byte Ptr,source_len:ULong )="int compress(void *, unsigned long *, const void *, unsigned long)"
'	Function __compress2:Int( dest:Byte Ptr,dest_len:ULong Var,source:Byte Ptr,source_len:ULong,level:Int )="int compress2(void *, unsigned long *, const void *, unsigned long , int)"
	Function __uncompress:Int( dest:Byte Ptr,dest_len:ULong Var,source:Byte Ptr,source_len:ULong )="int uncompress(void *, unsigned long *, const void *, unsigned long)"
?


End Extern

Const Z_DEFAULT_COMPRESSION:Int = 6

Type Zlib

?win32 Or ptr32
	Global BufSize:UInt = 16*1024	
?ptr64 And Not win32
	Global BufSize:ULong = 16*1024
?

	Function adler32:UInt( data:String, initial:ULong=0 )
		Return __adler32( initial, Varptr( data ), UInt(Len( data )) )
	End Function
	
	Function compress:Int( src:String, dst:String )
		'Local srclen:UInt = Len(src)
		'Local dstlen:UInt = Len(dst)
?win32 Or ptr32
'		Return __compress( Varptr( dst ), UInt(Len( dst )), Varptr( src ), UInt(Len( src )) )
?ptr64 And Not win32
'		Return __compress( Varptr( dst ), ULong(Len( dst )), Varptr( src ), ULong(Len( src )) )
?
	End Function

	Function compress:Int( src:String, dst:String, level:Int )
?win32 Or ptr32
'		Return __compress2( Varptr( dst ), UInt(Len( dst )), Varptr( src ), UInt(Len( src )), level )
?ptr64 And Not win32
'		Return __compress2( Varptr( dst ), ULong(Len( dst )), Varptr( src ), ULong(Len( src )), level )
?
	End Function

	Function decompress:Int( src:String, dst:String )
		Local dstbuf:Byte[Zlib.BufSize]
?win32 Or ptr32
		Local dstlen:UInt = __compressBound( Unit(Len(src)) )
	
'		Return __uncompress( dstbuf, UInt(Len( dst )), Varptr( src ), UInt(Len( src )) )

?ptr64 And Not win32
		Local dstlen:UInt = __compressBound( Unit(Len(src)) )
'		Return __uncompress( Varptr( dst ), ULong(Len( dst )), Varptr( src ), ULong(Len( src )) )
?
	End Function

End Type
 