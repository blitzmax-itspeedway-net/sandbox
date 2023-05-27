VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Object = "{E7BC34A0-BA86-11CF-84B1-CBC2DA68BF6C}#1.0#0"; "ntsvc.ocx"
Begin VB.Form frmSystemTray 
   Caption         =   "ITSpeedway SYSLOG Server"
   ClientHeight    =   855
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   3735
   Icon            =   "frmSystemTray.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   855
   ScaleWidth      =   3735
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer NTserviceTimer 
      Left            =   120
      Top             =   120
   End
   Begin MSWinsockLib.Winsock wsMain 
      Index           =   0
      Left            =   1080
      Top             =   120
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin NTService.NTService NTServiceOCX 
      Left            =   600
      Top             =   120
      _Version        =   65536
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
      ServiceName     =   "Simple"
      StartMode       =   3
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "Popup"
      Begin VB.Menu mnuService 
         Caption         =   "Service"
         Begin VB.Menu mnuServiceStart 
            Caption         =   "Start"
         End
         Begin VB.Menu mnuServiceRestart 
            Caption         =   "Restart"
         End
         Begin VB.Menu mnuServiceStop 
            Caption         =   "Stop"
         End
      End
      Begin VB.Menu s0 
         Caption         =   "-"
      End
      Begin VB.Menu mnuConfiguration 
         Caption         =   "Reports"
         Tag             =   "Nconsole.module"
         Begin VB.Menu mnuReport7Day 
            Caption         =   "Seven Day Summary"
         End
      End
      Begin VB.Menu mnuPreferences 
         Caption         =   "Preferences..."
      End
      Begin VB.Menu s1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAbout 
         Caption         =   "&About..."
      End
      Begin VB.Menu mnuExit 
         Caption         =   "E&xit"
      End
   End
End
Attribute VB_Name = "frmSystemTray"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'
'' FILE    frmMain.frm
'' AUTHOR  Simon Dunford, August 2000
'' OWNER   (c) Copyright Dorsai Technologies, August 2000. All rights reserved.
'' VERSION 1.0 beta
'' PROGRAM ITS SYSLOG
'' PURPOSE Form containing system tray menu and it's functionality.

Option Explicit

Private Declare Function GetTickCount Lib "kernel32" () As Long

Public Event menuClick(sTag As String)

Private lUnloadImmediately As Boolean
Private nTimerInterval
Private nTCPport As Long    '# Port this service will listen on.

'# Winsock variables
Private m_sCmdBuffer        As String
' this variable stores data sent to the server
Private m_lNumSockets       As Long
' indicates the number of cureently allocated sockets
Private m_bSignals()        As Boolean
' array used as for primitive asynchronous signal indicator

Private Enum WaitResult
  wrSuccess = 0
  wrTimeout = 1
End Enum

Public Event Control(ByVal nEvent As Long)
Public Event Action(ByVal nAction As Long)
Public Event Timer()

'######################################################################
'## Load the form and start the system tray icon
'
Private Sub Form_Load()
On Error Resume Next                   ' Error Handler
Dim sCommandLine As String
Dim nPort As Long
'On Error Resume Next

  '# Set up the NT service OCX control
  With NTServiceOCX
    .Interactive = True                '# Desktop interaction
    .Debug = False
    .DisplayName = App.Title
    .ServiceName = App.Title
    .StartMode = svcStartAutomatic
    .ControlsAccepted = svcCtrlPauseContinue Or svcCtrlShutdown
  End With
  
  '# Work out what we are doing!
  sCommandLine = Trim(LCase$(Command$))
  If Len(sCommandLine) = 0 Then        '# Service is being started
    NTServiceOCX.StartService
    lUnloadImmediately = False         '# Service will remain loaded
  Else
    '# Parse the command line
    lUnloadImmediately = True          '# Service will unload
    Select Case Left(sCommandLine & " ", 2)
      Case "-i", "/i"                  '# Install
        If NTServiceOCX.Install Then
          NTServiceOCX.SaveSetting "Parameters", "Port", "4010"
          MsgBox "Installed successfully."
        Else
          MsgBox "Failed to install."
        End If
        End
      Case "-u", "/u"                  '# Un-install
        If NTServiceOCX.Uninstall Then
          MsgBox "Un-installed successfully."
        Else
          MsgBox "Failed to un-install."
        End If
        End
      Case "-v", "/v"                  '# Version
        MsgBox App.Title & vbCrLf & "Version " & App.Major & "." & App.Minor & "." & App.Revision
        End
      Case "? ", "-?", "/?"            '# HELP !!
        MsgBox App.Title & vbCrLf & _
            "Syntax is: " & vbCrLf & _
            " " & App.EXEName & "</i>|</u>|</v>|</?>" & vbCrLf & vbCrLf & _
            " /i  - Install service." & vbCrLf & _
            " /u  - Un-install service." & vbCrLf & _
            " /v  - Version information." & vbCrLf & _
            " /?  - Help !!" & vbCrLf
        End
      Case Else
        MsgBox "Invalid command line."
        End
    End Select
    
    '# Get service settings
    nTCPport = CInt(NTServiceOCX.GetSetting("Parameters", "Port", "4010"))
    
    '# Enable the timer, and set initial interval to a small value.
    '# This allows the service to call the timer() and set itself up!
    NTserviceTimer.interval = 100
    NTserviceTimer.Enabled = True

    ' Put form into the system tray
    Call SysTray(Me, NIM_ADD, Me.Caption & vbNullChar)

  End If
End Sub

'######################################################################
'## Initialise the form
'
Private Sub Form_Initialize()
  nTimerInterval = 1000
End Sub

'######################################################################
'## Unload the form, and remove from system tray.
'
Private Sub Form_Unload(Cancel As Integer)
On Error Resume Next                   ' Error Handler
  ' Remove from the system tray
  Call SysTray(Me, NIM_DELETE, vbNull)
End Sub

'######################################################################
'## About box.
'
Private Sub mnuAbout_Click()
On Error Resume Next                   ' Error Handler
Dim fAbout As New frmAbout
  fAbout.Show vbModal, Me
End Sub

'######################################################################
'## Close
'
Private Sub mnuExit_Click()
On Error Resume Next                   ' Error Handler
  Unload Me
'  RaiseEvent CloseMe                   ' User wants to exit, so tell Netropolis
End Sub


'######################################################################
'# SysTray functionality
'######################################################################

'######################################################################
'## manage mouse movements over the system tray icon
'
Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
On Error Resume Next                   ' Error Handler

  Static lngMsg As Long
  Static blnFlag As Boolean
  Dim result As Long
        
lngMsg = X / Screen.TwipsPerPixelX
 
If blnFlag = False Then
  blnFlag = True
  If (lngMsg = WM_RBUTTONUP) Or (lngMsg = WM_LBUTTONUP) Then
    result = SetForegroundWindow(Me.hWnd)
    Me.PopupMenu mnuPopup
  End If
  blnFlag = False
End If
End Sub



'######################################################################
'## 7 Day report
Private Sub mnuReport7Day_Click()

End Sub

'######################################################################
'# NT Service support
'######################################################################

'**********************************************************************
'* Service functionality!
'*
Private Sub NTServiceOCX_Control(ByVal nEvent As Long)
On Error Resume Next
  RaiseEvent Control(nEvent)
End Sub

'**********************************************************************
'* Service should continue
'*
Private Sub NTServiceOCX_Continue(Success As Boolean)
  Success = True
  Me.NTserviceTimer.Enabled = True
'  RaiseEvent Action(SVC_PAUSE)

  '# Start modules
  loadModules

End Sub

'**********************************************************************
'* Service being paused, Modules will be stopped
'*
Private Sub NTServiceOCX_Pause(Success As Boolean)
On Error Resume Next
  Success = True
  Me.NTserviceTimer.Enabled = False
'  RaiseEvent Action(SVC_PAUSE)
  
  '# Stop all modules.
  unloadModules
End Sub

'**********************************************************************
'* Service being started.
'*
Private Sub NTServiceOCX_Start(Success As Boolean)
On Error Resume Next
  Success = True
  Me.NTserviceTimer.Enabled = True
'  RaiseEvent Action(SVC_START)

  '# Load all the modules that are available
  loadModules
  
  '# Start the listening service
  wsMain(0).LocalPort = nTCPport
  wsMain(0).Protocol = sckTCPProtocol
  wsMain(0).Listen
  
  If Err.Number <> 0 Then
    logEvent 0, 4010, "Error " & Err.Number & ": " & Err.Description
  Else
    logEvent 0, 4010, "Listening on port " & nTCPport
  End If
  
End Sub

'**********************************************************************
'* Service being stopped.
Private Sub NTServiceOCX_Stop()
On Error Resume Next
  RaiseEvent Action(SVC_STOP)
  Me.NTserviceTimer.Enabled = False
  
  '# Stop listening service
  wsMain(0).LocalPort = 0
  
  '# Stop all the modules
  unloadModules
  
  '# Unload Service
  Unload Me
End Sub

'**********************************************************************
'* The real work goes in here!
'*
Private Sub NTserviceTimer_Timer()
Static lBeenHere As Boolean
On Error Resume Next

  '# Command line execution exits on first timer tick.
  If lUnloadImmediately Then
    Me.NTserviceTimer.Enabled = False
    Unload Me
    Exit Sub
  End If
  
  '# if this is the first timer tick, then set it to required interval
  If Not lBeenHere Then
    lBeenHere = True
    Me.NTserviceTimer.interval = nTimerInterval
  End If
  
  RaiseEvent Timer
  
End Sub

'**********************************************************************
'* Set the timer interval (1000 - 65000 milliseconds)
'*
Public Sub interval(nInterval As Long)
  If nInterval < 1000 Then
    nTimerInterval = 1000
  ElseIf nInterval > 65000 Then
    nTimerInterval = 65000
  Else
    nTimerInterval = nInterval
  End If
End Sub

'**********************************************************************
'* Log an event
'*
Public Function logEvent(nEventType As Integer, nID As Long, sMsg As String) As Boolean
  logEvent = Me.NTServiceOCX.logEvent(nEventType, nID, sMsg)
End Function

'######################################################################
'# WINSOCK STUFF
'######################################################################
Private Sub wsMain_ConnectionRequest(Index As Integer, ByVal requestID As Long)
Dim sEntry As String
Dim wsSlave As Winsock
  ' if someone tries to connect to a sub-socket, bail...
  If Index <> 0 Then Exit Sub
  ' get a new socket to service this client
  Set wsSlave = GetSlaveSocket()
  ' switch this client's connection to the new socket
  wsSlave.Accept requestID
  
' compose and submit a log entry indicating a new client has connected
logEvent 0, 4010, "[" & wsSlave.RemoteHostIP & "]: Connected on socket #" & CStr(wsSlave.Index) & "."
    
End Sub

Private Sub wsMain_DataArrival(Index As Integer, ByVal bytesTotal As Long)
Dim sData       As String
Dim sChar       As String
Dim lCount      As Long
  ' pull the data off the socket
  wsMain(Index).GetData sData
  ' loop through the data, appending it to the command buffer until
  '  you hit a crlf; crlf indicates a complete command
  For lCount = 1 To Len(sData)
    sChar = Mid(sData, lCount, 1)
    If sChar <> vbCr And sChar <> vbLf Then
      m_sCmdBuffer = m_sCmdBuffer & sChar
    ElseIf sChar = vbLf Then
      ' if you've hit a crlf, process the command in the buffer
      ProcessCmd Index
'# This service should work out what to do with incoming data from packet
'# content and pass it to owner module or log an error.
    
'  RaiseEvent DataArrival(sckServer(Index).RemoteHostIP, sStr)
    
    End If
  Next lCount
End Sub

Private Sub wsMain_Error(Index As Integer, ByVal Number As Integer, Description As String, ByVal Scode As Long, ByVal Source As String, ByVal HelpFile As String, ByVal HelpContext As Long, CancelDisplay As Boolean)
  ' if the client disconnects prematurely, shut the socket down gracefully
  If Number = sckConnectAborted Then wsMain_Close Index
End Sub

Private Sub wsMain_SendComplete(Index As Integer)
  ' set the signal for this socket, indicating that the send is finished
  SetSignal Index, True
End Sub

Private Sub wsMain_Close(Index As Integer)
Dim sEntry As String
  ' close the socket
  wsMain(Index).Close
    
' compose and submit a log entry indicating this client is disconnected
logEvent 0, 4010, "[" & wsMain(Index).RemoteHostIP & "]: Disconnected."
End Sub

' ===========================================
' name:     SetSignal
' purpose:  Sets a signal's state to True or False.
' notes:    None.
' ===========================================
Private Sub SetSignal(SocketNumber As Integer, State As Boolean)
  m_bSignals(SocketNumber) = State
End Sub

' ===========================================
' name:     WaitForSignal
' purpose:  Loops until a signal's state is set to True.
' notes:    If [Duration] milliseconds pass, the function returns wrTimeout.
' ===========================================
Private Function WaitForSignal(Index As Integer, Optional Duration As Long = 2000) As WaitResult
Dim lTicks      As Long
  ' get the system up-time (in milliseconds)
  lTicks = GetTickCount()
  ' loop while the number of milliseconds passed is less than [Duration]
  While lTicks - GetTickCount() < Duration
    ' if the signal is set to True, exit returning wrSuccess
    If m_bSignals(Index) Then
      WaitForSignal = wrSuccess
      Exit Function
    End If
    DoEvents
  Wend
  WaitForSignal = wrTimeout
End Function

' ===========================================
' name:     GetSlaveSocket
' purpose:  Returns a free socket.  If all existing ones are in use, a new one is created.
' notes:    None.
' ===========================================
Private Function GetSlaveSocket() As Winsock
Dim wsSlave     As Winsock
Dim lCount      As Long
  ' loop through the array of currently allocated sockets; if one
  '  is available, use it
  For lCount = 1 To m_lNumSockets
    Set wsSlave = wsMain(lCount)
    ' if the socket is cloed (not in use), then we'll use it
    If wsSlave.State = sckClosed Then Exit For
    Set wsSlave = Nothing
  Next lCount
  ' if none of the existing sockets were available, let's
  '  allocate a new one
  If wsSlave Is Nothing Then
    m_lNumSockets = m_lNumSockets + 1
    Load wsMain(m_lNumSockets)
    Set wsSlave = wsMain(m_lNumSockets)
    ' allocate a new signal indicator
    ReDim Preserve m_bSignals(m_lNumSockets)
  End If
  wsSlave.LocalPort = 0
  Set GetSlaveSocket = wsSlave
End Function

' ===========================================
' name:     ProcessCmd
' purpose:  Parses and executes commands sent to the server.
' notes:    None.
' ===========================================
Private Sub ProcessCmd(SocketNumber As Integer)
Dim nSpace1, nSpace2 As Long
Dim sRequestURI As String
On Error Resume Next
    Dim sCommand        As String
    Dim sEntry          As String
    Dim sResponseInfo     As String
    Dim sPrefix         As String
    
    ' get the command and reset the command buffer
    sCommand = m_sCmdBuffer
    m_sCmdBuffer = ""
    
' build and submit a log entry that will record the command
logEvent 0, 4010, "[" & wsMain(SocketNumber).RemoteHostIP & "]: " & vbCrLf & "Command:'" & sCommand & "'"
    
    '# Obtain the command GET|HEAD|POST and URL
    nSpace1 = InStr(sCommand, " ")
    nSpace2 = InStr(nSpace1 + 1, sCommand, " ")
    sPrefix = UCase$(Left$(sCommand, nSpace1 - 1))
    sRequestURI = UCase$(Mid$(sCommand, nSpace1 + 1, nSpace2 - nSpace1 - 1))
    
    '# Expand "/" to "index.html"
    If sRequestURI = "/" Then sRequestURI = "/index.html"
       
    ' get the finger data for the user name that was passed
    sResponseInfo = GetResponseInfo(sRequestURI)
    
    ' reset the signal and send the finger data
    SetSignal SocketNumber, False
    wsMain(SocketNumber).SendData sResponseInfo
    
    ' wait for the data to be sent
    WaitForSignal SocketNumber, 2000
    
    ' close the connection to the client
wsMain_Close SocketNumber
    
End Sub

' ===========================================
'For HTML & TEXT FILES:
'  "HTTP/1.0 200 OK"+vbcrlf+"MIME-Version: 1.0"+vbcrlf+"Content-Type: text/html"+vbcrlf+vbcrlf
'For JPG FILES:
'  "HTTP/1.0 200 OK"+vbcrlf+"MIME-Version: 1.0"+vbcrlf+"Content-Type: image/jpeg"+vbcrlf+vbcrlf
'For GIF FILES:
'  "HTTP/1.0 200 OK"+vbcrlf+"MIME-Version: 1.0"+vbcrlf+"Content-Type: image/gif"+vbcrlf+vbcrlf
Private Function GetResponseInfo(sFile) As String
    Dim sInfo       As String
    Dim sPlan       As String
'    Dim hFile As Scripting.TextStream
    Dim sExt As String
    
    If Len(sFile) = 0 Then     '# Empty command, return NOT FOUND
      sInfo = "HTTP/1.0 404 Not Found" + vbCrLf
    Else
      
      sInfo = "HTTP/1.0 200 OK" & vbCrLf & "MIME-Version: 1.0" & vbCrLf
      sInfo = sInfo & "Content-Type: text/html" + vbCrLf + vbCrLf
      sInfo = sInfo & "<HTML><BODY><H1>ITS</H1><HR>"
      sInfo = sInfo & Time$
      sInfo = sInfo & "</BODY></HTML>"
      
      'If fso.FileExists(App.Path & "\www" & sFile) Then
      '  '# Apply header
      '  sInfo = "HTTP/1.0 200 OK" & vbCrLf & "MIME-Version: 1.0" & vbCrLf
      '  sExt = UCase(Right(sFile, Len(sFile) - InStr(sFile, ".")))
      '  Select Case sExt
      '    Case "GIF":
      '      sInfo = sInfo & "Content-Type: image/gif" + vbCrLf + vbCrLf
      '    Case "JPG":
      '      sInfo = sInfo & "Content-Type: image/jpeg" + vbCrLf + vbCrLf
      '    Case Else
      '      sInfo = sInfo & "Content-Type: text/html" + vbCrLf + vbCrLf
      '  End Select
      '  '# Read file
      '  hFile = fso.OpenTextFile(App.Path & "\www" & sFile, ForReading, False)
      '  sInfo = sInfo & hFile.ReadAll
      '  hFile.Close
      'Else
      '  sInfo = "HTTP/1.0 404 Not Found" + vbCrLf
      'End If
    End If
    
    GetResponseInfo = sInfo

End Function

'######################################################################
'# Miscellaneous
'######################################################################

