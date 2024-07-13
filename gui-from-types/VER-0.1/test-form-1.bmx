SuperStrict

Import "TForm.bmx"

Type TExample Implements IForm {title="Example"}

    Field Username:String    {Type="textbox" label="User Name" Length=10}
    Field Password:String    {Type="password"}    
    Field ok:String = "OK"     {Type="button"}
    
    Method New()
    End Method
    
    Method onclick( fld:TFormField )
        Print( "onclick() -> "+fld.fldName )
    End Method
    
End Type

Graphics 800,600

Local myform:TExample = New TExample()

Local form:TForm = New TForm( myform )

Repeat
    SetClsColor( $cc,$cc,$cc )
    Cls

    form.show()

    Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()