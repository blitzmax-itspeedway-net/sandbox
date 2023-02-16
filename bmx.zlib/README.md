The pub.ZLib module exposes three C functions:

Rem
bbdoc: Compress a block of data at default compression level
End Rem
?win32 Or ptr32
Function compress:Int( dest:Byte Ptr,dest_len:UInt Var,source:Byte Ptr,source_len:UInt )="int compress(void *, unsigned long *, const void *, unsigned long)"
?ptr64 And Not win32
Function compress:Int( dest:Byte Ptr,dest_len:ULong Var,source:Byte Ptr,source_len:ULong )="int compress(void *, unsigned long *, const void *, unsigned long)"
?

Rem
bbdoc: Compress a block of data at specified compression level
end rem
?win32 Or ptr32
Function compress2:Int( dest:Byte Ptr,dest_len:UInt Var,source:Byte Ptr,source_len:UInt,level:Int )="int compress2(void *, unsigned long *, const void *, unsigned long , int)"
?ptr64 And Not win32
Function compress2:Int( dest:Byte Ptr,dest_len:ULong Var,source:Byte Ptr,source_len:ULong,level:Int )="int compress2(void *, unsigned long *, const void *, unsigned long , int)"
?

Rem
bbdoc: Uncompress a block of data
end rem
?win32 Or ptr32
Function uncompress:Int( dest:Byte Ptr,dest_len:UInt Var,source:Byte Ptr,source_len:UInt )="int uncompress(void *, unsigned long *, const void *, unsigned long)"
?ptr64 And Not win32
Function uncompress:Int( dest:Byte Ptr,dest_len:ULong Var,source:Byte Ptr,source_len:ULong )="int uncompress(void *, unsigned long *, const void *, unsigned long)"
?


