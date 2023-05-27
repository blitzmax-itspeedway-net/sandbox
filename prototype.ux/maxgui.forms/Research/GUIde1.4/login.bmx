'GUIde 1.4 BlitzMAX export
SuperStrict
AppTitle ="Login"
Global frmLogin:TGadget
Global btnOK:TGadget
Global btnCancel:TGadget
Global lblLabel0:TGadget
Global lblLabel1:TGadget
Global txtName:TGadget
Global txtPassword:TGadget
frmLogin=CreateWindow("Login",0,00,314,158,Desktop(),WINDOW_TITLEBAR|WINDOW_STATUS)
	btnOK=CreateButton("OK",152,72,64,24,frmLogin,BUTTON_PUSH)
	btnCancel=CreateButton("Cancel",224,72,64,24,frmLogin,BUTTON_PUSH)
	lblLabel0=CreateLabel("Name:",16,16,64,16,frmLogin,0)
	lblLabel1=CreateLabel("Password:",16,40,64,16,frmLogin,0)
	txtName=CreateTextField(80,16,208,20,frmLogin)
	SetGadgetText txtName,"Username"
	txtPassword=CreateTextField(80,40,208,20,frmLogin)
	SetGadgetText txtPassword,"textfield"

'-mainloop--------------------------------------------------------------

Repeat
	Select WaitEvent()
		Case EVENT_GADGETACTION						' interacted with gadget
			DoGadgetAction()
		Case EVENT_WINDOWCLOSE						' close gadget
			Exit
	End Select
Forever

'-gadget actions--------------------------------------------------------

Function DoGadgetAction()
	Select EventSource()
		Case btnOK	' user pressed button

		Case btnCancel	' user pressed button

		Case txtName
			If EventData() = 13 Then	' user pressed return in textfield
			EndIf

		Case txtPassword
			If EventData() = 13 Then	' user pressed return in textfield
			EndIf

	End Select
End Function

