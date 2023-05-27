VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "Mswinsck.ocx"
Begin VB.Form frmMain1 
   Caption         =   "ITspeedway server"
   ClientHeight    =   3855
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7785
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   ScaleHeight     =   3855
   ScaleWidth      =   7785
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtLog 
      BackColor       =   &H00C0C0C0&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FF0000&
      Height          =   3150
      Left            =   90
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   1
      Top             =   135
      Width           =   7590
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "Exit"
      Default         =   -1  'True
      Height          =   390
      Left            =   6750
      TabIndex        =   0
      Top             =   3360
      Width           =   945
   End
   Begin MSWinsockLib.Winsock wsMain 
      Index           =   0
      Left            =   120
      Top             =   3360
      _ExtentX        =   741
      _ExtentY        =   741
      LocalPort       =   80
   End
End
Attribute VB_Name = "frmMain1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_lbMain            As LogBook
' the LogBook used to record server activity

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

Private Declare Function GetTickCount Lib "kernel32" () As Long

Private Const PLANPATH = "C:\USERS\"
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
        If wsSlave.State = sckClosed Then _
            Exit For
            
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

Private Sub cmdExit_Click()
    
    Unload Me
    
End Sub

Private Sub Form_Load()
    
    ' create a new LogBook and open it
    Set m_lbMain = New LogBook
    m_lbMain.OpenLog txtLog
    
    ' tell the main server socket to begin listening for connections
    wsMain(0).Protocol = sckTCPProtocol
    wsMain(0).LocalPort = 80
    wsMain(0).Listen
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    
    ' close the log
    If (m_lbMain Is Nothing) = False Then
        m_lbMain.CloseLog
        Set m_lbMain = Nothing
    End If
    
End Sub



Private Sub wsMain_Close(Index As Integer)
    
    Dim sEntry      As String
    
    ' close the socket
    wsMain(Index).Close
    
    ' compose and submit a log entry indicating this client is disconnected
    sEntry = "[" & wsMain(Index).RemoteHostIP & "]: Disconnected."
    m_lbMain.AddEntry sEntry
    
End Sub

Private Sub wsMain_ConnectionRequest(Index As Integer, ByVal requestID As Long)

    Dim sEntry      As String
    Dim wsSlave     As Winsock
    
    ' if someone tries to connect to a sub-socket, bail...
    If Index <> 0 Then Exit Sub
    
    ' get a new socket to service this client
    Set wsSlave = GetSlaveSocket()
    
    ' switch this client's connection to the new socket
    wsSlave.Accept requestID
    
    ' compose and submit a log entry indicating a new client has connected
    sEntry = "[" & wsSlave.RemoteHostIP & "]: Connected on socket #" & CStr(wsSlave.Index) & "."
    m_lbMain.AddEntry sEntry
    
End Sub

Private Sub wsMain_DataArrival(Index As Integer, ByVal bytesTotal As Long)
Dim sEntry As String
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

    sEntry = "[" & wsMain(Index).RemoteHostIP & "]: Command...<" & m_sCmdBuffer & ">"
    m_lbMain.AddEntry sEntry


            If http.processCommand(Index, m_sCmdBuffer) Then
              SetSignal Index, False
              wsMain(Index).SendData http.getResponse(Index)
              '# wait for the data to be sent
              WaitForSignal Index, 2000
              '# Close this socket - We have finished
              wsMain_Close Index
              Exit For
            End If
            m_sCmdBuffer = ""
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


