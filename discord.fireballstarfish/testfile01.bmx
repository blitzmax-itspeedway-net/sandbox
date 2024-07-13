SuperStrict

Framework brl.StandardIO

Extern "C"
    Function bbObjectRegisteredStructs:Byte Ptr Ptr(count:Int Var) = "BBDebugScope** bbObjectRegisteredStructs(int*)!"
    Function bbObjectRegisteredStructsVARIANT(s:Byte Ptr Ptr Var) = "void bbObjectRegisteredStructsVARIANT(void**)!"
End Extern

Local scount:Int,x:Int
Local structArrayVARIANT:Byte Ptr Ptr; bbObjectRegisteredStructsVARIANT(structArrayVARIANT)
Local structArray:Byte Ptr Ptr = bbObjectRegisteredStructs(scount)    ' BBDebugScope**
'!printf("structArray %p\n", bbt_structArray);fflush(stdout);
'!printf("structArrayVARIANT %p\n", bbt_structArrayVARIANT);fflush(stdout);

'!BBBYTE *test = *bbt_structArray;


