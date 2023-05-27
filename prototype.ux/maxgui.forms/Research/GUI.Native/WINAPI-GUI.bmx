SuperStrict
'Win32 Libraries
Import "-lcomctl32"
Import "-lole32"
Import "-loleaut32"
Import "-luuid"
Import "-lmsimg32"







'## DEFINE WinProc

Function ClassWndProc(hwnd%,msg%,wp%,lp%) "win32"
		Local owner:TWindowsGadget
		Local res%
		Local nmhdr:Int Ptr
		
		'?Debug And Win32
		'Print TWindowsDebug.ReverseLookupMsg(msg) + ", hwnd: " + hwnd + ", wp: " + wp + ", lp: " + lp
		'?Win32
		
		Select msg
			
			Case WM_MENUCHAR
				
				If HotKeyEventFromWp(wp & $FF) Then
					Return (MNC_CLOSE Shl 16)
				Else
					Return (MNC_IGNORE Shl 16)
				EndIf
			
			Case WM_SIZE
				
				owner = GadgetFromHwnd(hwnd)
				If owner And Not TWindowsWindow(owner) Then
					If hwnd = owner.Query(QUERY_HWND) Then owner.RethinkClient()
					If hwnd = owner.Query(QUERY_HWND_CLIENT) Then owner.LayoutKids()
				EndIf
			
			Case WM_CTLCOLORSTATIC, WM_CTLCOLOREDIT, WM_CTLCOLORBTN
				
				owner=GadgetFromHwnd(lp)
				
				Select True
					
					Case TWindowsLabel(owner) <> Null
					
						SetBkMode(wp, TRANSPARENT)
						If owner.FgColor() > -1 Then SetTextColor_(wp, owner.FgColor())
						Return owner.CreateControlBrush( owner._hwnd, wp )
				
					Case TWindowsPanel(owner) <> Null
						
						If TWindowsPanel(owner)._type = TWindowsPanel.PANELGROUP Then
							
							SetBkMode(wp, TRANSPARENT)
							If owner.FgColor() > -1 Then SetTextColor_(wp, owner.FgColor())
							Return owner.CreateControlBrush( lp, wp )
							
						EndIf
						
					Case TWindowsTextField(owner) <> Null, TWindowsComboBox(owner) <> Null
						
						If owner.FgColor() > -1 Then SetTextColor_(wp, owner.FgColor())
						If owner.BgBrush() Then SetBkColor(wp, owner.BgColor());Return owner.BgBrush()
						
					Case TWindowsButton(owner) <> Null, TWindowsSlider(owner) <> Null
						
						SetBkMode(wp, TRANSPARENT)
						If owner.FgColor() > -1 Then SetTextColor_(wp, owner.FgColor())
						Return owner.CreateControlBrush( owner._hwnd, wp )
					
				EndSelect
				
				owner = Null
				
			Case WM_COMMAND,WM_HSCROLL,WM_VSCROLL
				If lp Then
					owner=GadgetFromHwnd(lp)
					'Fix for tab control's up/down arrow.
					If Not owner Then owner = GadgetFromHwnd(GetParent_(lp))
				Else
					owner=GadgetFromHwnd(hwnd)		'Fixed for menu events
				EndIf

				If Not owner Then owner = GadgetFromHwnd(hwnd)

				If owner Then
					res=owner.OnCommand(msg,wp)
					If Not res And owner._proc And owner._hwnd = hwnd Return CallWindowProcW(owner._proc,hwnd,msg,wp,lp)
					Return res
				Else
					Return DefWindowProcW( hwnd,msg,wp,lp )
				EndIf
				
			Case WM_NOTIFY
				
				'Gadget tooltips
				nmhdr=Int Ptr(lp)
				owner=GadgetFromHwnd(nmhdr[0])		
				If owner Then
					Select nmhdr[2]
						Case TTN_GETDISPINFOW
							If owner._wstrTooltip Then nmhdr[3] = Int(owner._wstrTooltip)
					EndSelect
					Return owner.OnNotify(wp,lp)
				EndIf
				
			Case WM_SETCURSOR
			
				If _cursor Then
					SetCursor(_cursor)
					Return 1
				EndIf
				
			Case WM_ACTIVATEAPP, WM_ACTIVATE
			
				SystemEmitOSEvent(hwnd,msg,wp,lp,Null)
			
			Case WM_DRAWITEM
				
				Local tmpDrawItemStruct:DRAWITEMSTRUCT = New DRAWITEMSTRUCT
				MemCopy tmpDrawItemStruct, Byte Ptr lp, SizeOf(tmpDrawItemStruct)
				
				owner = GadgetFromHwnd(tmpDrawItemStruct.hwndItem)
				If owner And owner.OnDrawItem( tmpDrawItemStruct ) Then Return True
				
				owner = Null
			
			'Allow BRL.System to handle mouse/key events on sensitive gadgets.
				
			Case WM_CAPTURECHANGED
				
				'For preventing problem where controls which called SetCapture() internally
				'had their capture prematurely released by the ReleaseCapture() call in BRL.System.
				intDontReleaseCapture = False
				'If SetCapture() is called again after BRL.System's call (when the new
				'capture hwnd [lp] = old hwnd [hwnd]) then we dont want to call ReleaseCapture() in BRL.System
				'when WM_MOUSEBUTTONUP is received by the system hook TWindowsGUIDriver.MouseProc().
				If (lp = hwnd) And (Not intEmitOSEvent) Then intDontReleaseCapture = True
			
			Default
				
				'Added preliminary check to avoid searching for a gadget in GadgetMap un-necessarily.
				If (msg = WM_MOUSEWHEEL) Or (msg = WM_MOUSELEAVE) Or (msg>=WM_KEYFIRST And msg<=WM_KEYLAST) Then
					owner=GadgetFromHwnd(hwnd)
					If owner Then
						Select msg
							Case WM_MOUSELEAVE, WM_MOUSEWHEEL
								If (owner.sensitivity&SENSITIZE_MOUSE) Then SystemEmitOSEvent hwnd,msg,wp,lp,owner
							Case WM_KEYDOWN, WM_KEYUP, WM_SYSKEYDOWN, WM_SYSKEYUP, WM_CHAR, WM_SYSCHAR
								If (owner.sensitivity&SENSITIZE_KEYS) And Not GadgetDisabled(owner) Then
									SystemEmitOSEvent hwnd,msg,wp,lp,owner
								EndIf
								If (msg<>WM_CHAR And msg<>WM_SYSCHAR) And HotKeyEventFromWp(wp) Then Return 1
						EndSelect
					EndIf
				EndIf
			
		EndSelect
		
		If Not owner Then owner=GadgetFromHwnd(hwnd)
		If owner Return owner.WndProc(hwnd,msg,wp,lp)
		
		Return DefWindowProcW( hwnd,msg,wp,lp )

	EndFunction


'# WINDOWS MESSAGE CONSTANTS

Const WM_ACTIVATE% = $6
Const WM_ACTIVATEAPP% = $1C
Const WM_AFXFIRST% = $360
Const WM_AFXLAST% = $37F
Const WM_APP% = $8000
Const WM_ASKCBFORMATNAME% = $30C
Const WM_CANCELJOURNAL% = $4B
Const WM_CANCELMODE% = $1F
Const WM_CAPTURECHANGED% = $215
Const WM_CHANGECBCHAIN% = $30D
Const WM_CHANGEUISTATE% = $127
Const WM_CHAR% = $102
Const WM_CHARTOITEM% = $2F
Const WM_CHILDACTIVATE% = $22
Const WM_CLEAR% = $303
Const WM_CLOSE% = $10
Const WM_COMMAND% = $111
Const WM_COMPACTING% = $41
Const WM_COMPAREITEM% = $39
Const WM_CONTEXTMENU% = $7B
Const WM_COPY% = $301
Const WM_COPYDATA% = $4A
Const WM_CREATE% = $1
Const WM_CTLCOLORBTN% = $135
Const WM_CTLCOLORDLG% = $136
Const WM_CTLCOLOREDIT% = $133
Const WM_CTLCOLORLISTBOX% = $134
Const WM_CTLCOLORMSGBOX% = $132
Const WM_CTLCOLORSCROLLBAR% = $137
Const WM_CTLCOLORSTATIC% = $138
Const WM_CUT% = $300
Const WM_DEADCHAR% = $103
Const WM_DELETEITEM% = $2D
Const WM_DESTROY% = $2
Const WM_DESTROYCLIPBOARD% = $307
Const WM_DEVICECHANGE% = $219
Const WM_DEVMODECHANGE% = $1B
Const WM_DISPLAYCHANGE% = $7E
Const WM_DRAWCLIPBOARD% = $308
Const WM_DRAWITEM% = $2B
Const WM_DROPFILES% = $233
Const WM_ENABLE% = $A
Const WM_ENDSESSION% = $16
Const WM_ENTERIDLE% = $121
Const WM_ENTERMENULOOP% = $211
Const WM_ENTERSIZEMOVE% = $231
Const WM_ERASEBKGND% = $14
Const WM_EXITMENULOOP% = $212
Const WM_EXITSIZEMOVE% = $232
Const WM_FONTCHANGE% = $1D
Const WM_GETDLGCODE% = $87
Const WM_GETFONT% = $31
Const WM_GETHOTKEY% = $33
Const WM_GETICON% = $7F
Const WM_GETMINMAXINFO% = $24
Const WM_GETOBJECT% = $3D
Const WM_GETTEXT% = $D
Const WM_GETTEXTLENGTH% = $E
Const WM_HANDHELDFIRST% = $358
Const WM_HANDHELDLAST% = $35F
Const WM_HELP% = $53
Const WM_HOTKEY% = $312
Const WM_HSCROLL% = $114
Const WM_HSCROLLCLIPBOARD% = $30E
Const WM_ICONERASEBKGND% = $27
Const WM_IME_CHAR% = $286
Const WM_IME_COMPOSITION% = $10F
Const WM_IME_COMPOSITIONFULL% = $284
Const WM_IME_CONTROL% = $283
Const WM_IME_ENDCOMPOSITION% = $10E
Const WM_IME_KEYDOWN% = $290
Const WM_IME_KEYLAST% = $10F
Const WM_IME_KEYUP% = $291
Const WM_IME_NOTIFY% = $282
Const WM_IME_REQUEST% = $288
Const WM_IME_SELECT% = $285
Const WM_IME_SETCONTEXT% = $281
Const WM_IME_STARTCOMPOSITION% = $10D
Const WM_INITDIALOG% = $110
Const WM_INITMENU% = $116
Const WM_INITMENUPOPUP% = $117
Const WM_INPUTLANGCHANGE% = $51
Const WM_INPUTLANGCHANGEREQUEST% = $50
Const WM_KEYDOWN% = $100
Const WM_KEYFIRST% = $100
Const WM_KEYLAST% = $108
Const WM_KEYUP% = $101
Const WM_KILLFOCUS% = $8
Const WM_LBUTTONDBLCLK% = $203
Const WM_LBUTTONDOWN% = $201
Const WM_LBUTTONUP% = $202
Const WM_MBUTTONDBLCLK% = $209
Const WM_MBUTTONDOWN% = $207
Const WM_MBUTTONUP% = $208
Const WM_MDIACTIVATE% = $222
Const WM_MDICASCADE% = $227
Const WM_MDICREATE% = $220
Const WM_MDIDESTROY% = $221
Const WM_MDIGETACTIVE% = $229
Const WM_MDIICONARRANGE% = $228
Const WM_MDIMAXIMIZE% = $225
Const WM_MDINEXT% = $224
Const WM_MDIREFRESHMENU% = $234
Const WM_MDIRESTORE% = $223
Const WM_MDISETMENU% = $230
Const WM_MDITILE% = $226
Const WM_MEASUREITEM% = $2C
Const WM_MENUCHAR% = $120
Const WM_MENUCOMMAND% = $126
Const WM_MENUDRAG% = $123
Const WM_MENUGETOBJECT% = $124
Const WM_MENURBUTTONUP% = $122
Const WM_MENUSELECT% = $11F
Const WM_MOUSEACTIVATE% = $21
Const WM_MOUSEFIRST% = $200
Const WM_MOUSEHOVER% = $2A1
Const WM_MOUSELAST% = $20D
Const WM_MOUSELEAVE% = $2A3
Const WM_MOUSEMOVE% = $200
Const WM_MOUSEWHEEL% = $20A
Const WM_MOUSEHWHEEL% = $20E
Const WM_MOVE% = $3
Const WM_MOVING% = $216
Const WM_NCACTIVATE% = $86
Const WM_NCCALCSIZE% = $83
Const WM_NCCREATE% = $81
Const WM_NCDESTROY% = $82
Const WM_NCHITTEST% = $84
Const WM_NCLBUTTONDBLCLK% = $A3
Const WM_NCLBUTTONDOWN% = $A1
Const WM_NCLBUTTONUP% = $A2
Const WM_NCMBUTTONDBLCLK% = $A9
Const WM_NCMBUTTONDOWN% = $A7
Const WM_NCMBUTTONUP% = $A8
Const WM_NCMOUSEMOVE% = $A0
Const WM_NCPAINT% = $85
Const WM_NCRBUTTONDBLCLK% = $A6
Const WM_NCRBUTTONDOWN% = $A4
Const WM_NCRBUTTONUP% = $A5
Const WM_NEXTDLGCTL% = $28
Const WM_NEXTMENU% = $213
Const WM_NOTIFY% = $4E
Const WM_NOTIFYFORMAT% = $55
Const WM_NULL% = $0
Const WM_PAINT% = $F
Const WM_PAINTCLIPBOARD% = $309
Const WM_PAINTICON% = $26
Const WM_PALETTECHANGED% = $311
Const WM_PALETTEISCHANGING% = $310
Const WM_PARENTNOTIFY% = $210
Const WM_PASTE% = $302
Const WM_PENWINFIRST% = $380
Const WM_PENWINLAST% = $38F
Const WM_POWER% = $48
Const WM_POWERBROADCAST% = $218
Const WM_PRINT% = $317
Const WM_PRINTCLIENT% = $318
Const WM_QUERYDRAGICON% = $37
Const WM_QUERYENDSESSION% = $11
Const WM_QUERYNEWPALETTE% = $30F
Const WM_QUERYOPEN% = $13
Const WM_QUEUESYNC% = $23
Const WM_QUIT% = $12
Const WM_RBUTTONDBLCLK% = $206
Const WM_RBUTTONDOWN% = $204
Const WM_RBUTTONUP% = $205
Const WM_RENDERALLFORMATS% = $306
Const WM_RENDERFORMAT% = $305
Const WM_SETCURSOR% = $20
Const WM_SETFOCUS% = $7
Const WM_SETFONT% = $30
Const WM_SETHOTKEY% = $32
Const WM_SETICON% = $80
Const WM_SETREDRAW% = $B
Const WM_SETTEXT% = $C
Const WM_SETTINGCHANGE% = $1A
Const WM_SHOWWINDOW% = $18
Const WM_SIZE% = $5
Const WM_SIZECLIPBOARD% = $30B
Const WM_SIZING% = $214
Const WM_SPOOLERSTATUS% = $2A
Const WM_STYLECHANGED% = $7D
Const WM_STYLECHANGING% = $7C
Const WM_SYNCPAINT% = $88
Const WM_SYSCHAR% = $106
Const WM_SYSCOLORCHANGE% = $15
Const WM_SYSCOMMAND% = $112
Const WM_SYSDEADCHAR% = $107
Const WM_SYSKEYDOWN% = $104
Const WM_SYSKEYUP% = $105
Const WM_TCARD% = $52
Const WM_THEMECHANGED% = $31A
Const WM_TIMECHANGE% = $1E
Const WM_TIMER% = $113
Const WM_UNDO% = $304
Const WM_UNINITMENUPOPUP% = $125
Const WM_USER% = $400
Const WM_USERCHANGED% = $54
Const WM_VKEYTOITEM% = $2E
Const WM_VSCROLL% = $115
Const WM_VSCROLLCLIPBOARD% = $30A
Const WM_WINDOWPOSCHANGED% = $47
Const WM_WINDOWPOSCHANGING% = $46
Const WM_WININICHANGE% = $1A
Const WM_XBUTTONDBLCLK% = $20D
Const WM_XBUTTONDOWN% = $20B
Const WM_XBUTTONUP% = $20C
