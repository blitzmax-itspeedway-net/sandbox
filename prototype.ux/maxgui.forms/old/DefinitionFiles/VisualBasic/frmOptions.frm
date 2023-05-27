VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmOptions 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Options"
   ClientHeight    =   6285
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   5415
   Icon            =   "frmOptions.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6285
   ScaleWidth      =   5415
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Tag             =   "Options"
   Begin VB.PictureBox Picture1 
      Height          =   4695
      Index           =   3
      Left            =   120
      ScaleHeight     =   4635
      ScaleWidth      =   4995
      TabIndex        =   51
      Top             =   720
      Width           =   5055
      Begin VB.CheckBox chkDebug 
         Caption         =   "Enable debugger information."
         Height          =   315
         Left            =   120
         TabIndex        =   52
         Top             =   120
         Width           =   4575
      End
      Begin VB.Label Label14 
         Caption         =   "Thankyou for helping us improve the service we offer."
         Height          =   375
         Left            =   120
         TabIndex        =   57
         Top             =   3480
         Width           =   4815
      End
      Begin VB.Label Label13 
         Caption         =   $"frmOptions.frx":0642
         Height          =   615
         Left            =   120
         TabIndex        =   56
         Top             =   2640
         Width           =   4815
      End
      Begin VB.Label Label9 
         Caption         =   $"frmOptions.frx":06CE
         Height          =   855
         Left            =   120
         TabIndex        =   55
         Top             =   1800
         Width           =   4815
      End
      Begin VB.Label Label5 
         Caption         =   "Debug information allows ITSpeedway to further develop it's systems by analysing your data."
         Height          =   495
         Left            =   120
         TabIndex        =   54
         Top             =   840
         Width           =   4815
      End
      Begin VB.Label Label7 
         Caption         =   "IP Address information will be stripped from the data when it occurs in the Hostname or Description field of your SYSLOG data. "
         Height          =   375
         Left            =   120
         TabIndex        =   53
         Top             =   1320
         Width           =   4815
      End
   End
   Begin VB.PictureBox Picture1 
      Height          =   1695
      Index           =   2
      Left            =   3360
      ScaleHeight     =   1635
      ScaleWidth      =   1035
      TabIndex        =   24
      Top             =   840
      Width           =   1095
      Begin VB.ComboBox cmbTime 
         Height          =   315
         ItemData        =   "frmOptions.frx":07C5
         Left            =   1320
         List            =   "frmOptions.frx":07C7
         TabIndex        =   49
         Text            =   "Combo1"
         Top             =   2280
         Width           =   975
      End
      Begin VB.CheckBox chkActive 
         Height          =   255
         Left            =   1320
         TabIndex        =   47
         Top             =   120
         Width           =   3135
      End
      Begin VB.CheckBox chkDow 
         Caption         =   "Saturday"
         Height          =   255
         Index           =   6
         Left            =   1320
         TabIndex        =   34
         Top             =   1920
         Width           =   1335
      End
      Begin VB.CheckBox chkDow 
         Caption         =   "Friday"
         Height          =   255
         Index           =   5
         Left            =   1320
         TabIndex        =   33
         Top             =   1680
         Width           =   1335
      End
      Begin VB.CheckBox chkDow 
         Caption         =   "Thursday"
         Height          =   255
         Index           =   4
         Left            =   1320
         TabIndex        =   32
         Top             =   1440
         Width           =   1335
      End
      Begin VB.CheckBox chkDow 
         Caption         =   "Wednesday"
         Height          =   255
         Index           =   3
         Left            =   1320
         TabIndex        =   31
         Top             =   1200
         Width           =   1335
      End
      Begin VB.CheckBox chkDow 
         Caption         =   "Tuesday"
         Height          =   255
         Index           =   2
         Left            =   1320
         TabIndex        =   30
         Top             =   960
         Width           =   1335
      End
      Begin VB.CheckBox chkDow 
         Caption         =   "Monday"
         Height          =   255
         Index           =   1
         Left            =   1320
         TabIndex        =   29
         Top             =   720
         Width           =   1335
      End
      Begin VB.CheckBox chkDow 
         Caption         =   "Sunday"
         Height          =   255
         Index           =   0
         Left            =   1320
         TabIndex        =   28
         Top             =   480
         Width           =   1335
      End
      Begin VB.Label Label11 
         Caption         =   "Activate?"
         Height          =   255
         Left            =   120
         TabIndex        =   48
         Top             =   120
         Width           =   975
      End
      Begin VB.Label txtTime 
         Alignment       =   2  'Center
         Caption         =   "00:00"
         Height          =   255
         Left            =   1320
         TabIndex        =   27
         Top             =   1920
         Width           =   495
      End
      Begin VB.Label Label12 
         Caption         =   "Time:"
         Height          =   255
         Left            =   120
         TabIndex        =   26
         Top             =   2280
         Width           =   1815
      End
      Begin VB.Label Label10 
         Caption         =   "Every:"
         Height          =   375
         Left            =   120
         TabIndex        =   25
         Top             =   480
         Width           =   1095
      End
   End
   Begin MSComctlLib.TabStrip TabStrip1 
      Height          =   495
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4575
      _ExtentX        =   8070
      _ExtentY        =   873
      _Version        =   393216
      BeginProperty Tabs {1EFB6598-857C-11D1-B16A-00C0F0283628} 
         NumTabs         =   4
         BeginProperty Tab1 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "Reports"
            ImageVarType    =   2
         EndProperty
         BeginProperty Tab2 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "Content"
            ImageVarType    =   2
         EndProperty
         BeginProperty Tab3 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "Schedule"
            ImageVarType    =   2
         EndProperty
         BeginProperty Tab4 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "Debugging"
            ImageVarType    =   2
         EndProperty
      EndProperty
   End
   Begin VB.PictureBox Picture1 
      Height          =   1215
      Index           =   1
      Left            =   3840
      ScaleHeight     =   1155
      ScaleWidth      =   1155
      TabIndex        =   11
      Top             =   1680
      Width           =   1215
      Begin VB.CommandButton cmdResetDefault 
         Caption         =   "Defaults"
         Height          =   375
         Left            =   3840
         TabIndex        =   50
         Tag             =   "OK"
         Top             =   120
         Width           =   1095
      End
      Begin VB.TextBox txtTop 
         Alignment       =   1  'Right Justify
         Height          =   315
         Left            =   1920
         TabIndex        =   44
         Text            =   "5"
         Top             =   960
         Width           =   375
      End
      Begin VB.CheckBox chkEvents 
         Caption         =   "With at least"
         Height          =   255
         Left            =   1320
         TabIndex        =   43
         Top             =   1800
         Width           =   1215
      End
      Begin VB.OptionButton optResults 
         Caption         =   "Do not include."
         Height          =   255
         Index           =   2
         Left            =   1320
         TabIndex        =   42
         Top             =   1320
         Width           =   1455
      End
      Begin VB.TextBox txtEvents 
         Alignment       =   1  'Right Justify
         Height          =   315
         Left            =   2520
         TabIndex        =   41
         Text            =   "100"
         Top             =   1800
         Width           =   495
      End
      Begin VB.OptionButton optResults 
         Caption         =   "Top"
         Height          =   255
         Index           =   1
         Left            =   1320
         TabIndex        =   23
         Top             =   960
         Width           =   615
      End
      Begin VB.OptionButton optResults 
         Caption         =   "All devices."
         Height          =   255
         Index           =   0
         Left            =   1320
         TabIndex        =   22
         Top             =   600
         Width           =   2055
      End
      Begin VB.ComboBox cmbPriority 
         Height          =   315
         ItemData        =   "frmOptions.frx":07C9
         Left            =   1320
         List            =   "frmOptions.frx":07CB
         Style           =   2  'Dropdown List
         TabIndex        =   12
         Top             =   120
         Width           =   2295
      End
      Begin VB.Label lblEvents 
         Caption         =   " events."
         Height          =   375
         Left            =   3000
         TabIndex        =   46
         Top             =   1800
         Width           =   615
      End
      Begin VB.Label Label8 
         Caption         =   " devices."
         Height          =   255
         Left            =   2280
         TabIndex        =   45
         Top             =   960
         Width           =   735
      End
      Begin VB.Label Label4 
         Caption         =   "Priority level:"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   120
         Width           =   1215
      End
   End
   Begin VB.PictureBox Picture1 
      Height          =   735
      Index           =   0
      Left            =   120
      ScaleHeight     =   675
      ScaleWidth      =   2715
      TabIndex        =   10
      Top             =   720
      Width           =   2775
      Begin VB.Frame Frame2 
         Caption         =   "Content:"
         Height          =   855
         Left            =   1320
         TabIndex        =   38
         Top             =   2520
         Visible         =   0   'False
         Width           =   3015
         Begin VB.OptionButton optContent 
            Caption         =   "Seven days worth of events."
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   40
            Top             =   240
            Width           =   2775
         End
         Begin VB.OptionButton optContent 
            Caption         =   "All events since previous report."
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   39
            Top             =   480
            Width           =   2775
         End
      End
      Begin VB.Frame Frame1 
         Caption         =   "Format:"
         Height          =   855
         Left            =   1320
         TabIndex        =   35
         Top             =   1560
         Visible         =   0   'False
         Width           =   3015
         Begin VB.OptionButton optFormat 
            Caption         =   "HTML"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   37
            Top             =   240
            Width           =   855
         End
         Begin VB.OptionButton optFormat 
            Caption         =   "Text"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   36
            Top             =   480
            Visible         =   0   'False
            Width           =   855
         End
      End
      Begin VB.TextBox txtSubject 
         Height          =   315
         Left            =   1320
         TabIndex        =   21
         Top             =   1200
         Width           =   3015
      End
      Begin VB.TextBox txtRecipient 
         Height          =   315
         Left            =   1320
         TabIndex        =   18
         Top             =   840
         Width           =   3015
      End
      Begin VB.TextBox txtSender 
         Height          =   315
         Left            =   1320
         TabIndex        =   17
         Top             =   480
         Width           =   3015
      End
      Begin VB.TextBox txtSMTPserver 
         Height          =   315
         Left            =   1320
         TabIndex        =   14
         Top             =   120
         Width           =   3015
      End
      Begin VB.Label Label6 
         Caption         =   "Subject line:"
         Height          =   375
         Left            =   120
         TabIndex        =   20
         Top             =   1200
         Width           =   1215
      End
      Begin VB.Label Label1 
         Caption         =   "SMTP server:"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   120
         Width           =   1215
      End
      Begin VB.Label Label3 
         Caption         =   "Recipient(s):"
         Height          =   255
         Left            =   120
         TabIndex        =   16
         Top             =   840
         Width           =   1215
      End
      Begin VB.Label Label2 
         Caption         =   "Sender:"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   480
         Width           =   1215
      End
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Height          =   375
      Left            =   1800
      TabIndex        =   1
      Tag             =   "OK"
      Top             =   5775
      Width           =   1095
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   3000
      TabIndex        =   2
      Tag             =   "Cancel"
      Top             =   5775
      Width           =   1095
   End
   Begin VB.CommandButton cmdApply 
      Caption         =   "&Apply"
      Height          =   375
      Left            =   4200
      TabIndex        =   3
      Tag             =   "&Apply"
      Top             =   5775
      Width           =   1095
   End
   Begin VB.PictureBox picOptions 
      BorderStyle     =   0  'None
      Height          =   3780
      Index           =   3
      Left            =   -20000
      ScaleHeight     =   3840.968
      ScaleMode       =   0  'User
      ScaleWidth      =   5745.64
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   480
      Width           =   5685
      Begin VB.Frame fraSample4 
         Caption         =   "Sample 4"
         Height          =   2022
         Left            =   505
         TabIndex        =   9
         Tag             =   "Sample 4"
         Top             =   502
         Width           =   2033
      End
   End
   Begin VB.PictureBox picOptions 
      BorderStyle     =   0  'None
      Height          =   3780
      Index           =   2
      Left            =   -20000
      ScaleHeight     =   3840.968
      ScaleMode       =   0  'User
      ScaleWidth      =   5745.64
      TabIndex        =   7
      TabStop         =   0   'False
      Top             =   480
      Width           =   5685
      Begin VB.Frame fraSample3 
         Caption         =   "Sample 3"
         Height          =   2022
         Left            =   406
         TabIndex        =   8
         Tag             =   "Sample 3"
         Top             =   403
         Width           =   2033
      End
   End
   Begin VB.PictureBox picOptions 
      BorderStyle     =   0  'None
      Height          =   3780
      Index           =   1
      Left            =   -20000
      ScaleHeight     =   3840.968
      ScaleMode       =   0  'User
      ScaleWidth      =   5745.64
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   480
      Width           =   5685
      Begin VB.Frame fraSample2 
         Caption         =   "Sample 2"
         Height          =   2022
         Left            =   307
         TabIndex        =   6
         Tag             =   "Sample 2"
         Top             =   305
         Width           =   2033
      End
   End
End
Attribute VB_Name = "frmOptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim aReport(6, 3) As Integer
Dim aDefault

Private Sub cmdApply_Click()
Dim nLoop As Byte
  regPut "", "Configured", "YES"
  'PAGE1
  regPut "SMTP", "Server", txtSMTPserver
  regPut "SMTP", "Sender", txtSender
  regPut "SMTP", "Recipient", txtRecipient
  regPut "Report", "Subject", txtSubject
  regPut "Report", "Format", GetSelectedOptionIndex(optFormat)    '# Text or HTML or RTF etc...
  regPut "Report", "Content", GetSelectedOptionIndex(optContent)
  'PAGE2
  For nLoop = 0 To 6
'    aReport(nLoop, 0) = Val(regGet("Report\Priority." & Str(nLoop), "Result"))
'    aReport(nLoop, 1) = Val(regGet("Report\Priority." & Str(nLoop), "Top"))
'    aReport(nLoop, 2) = Val(regGet("Report\Priority." & Str(nLoop), "Events"))
    regPut "Report\Priority." & Str(nLoop), "Result", Str(aReport(nLoop, 0))
    regPut "Report\Priority." & Str(nLoop), "Top", Str(aReport(nLoop, 1))
    regPut "Report\Priority." & Str(nLoop), "Event", Str(aReport(nLoop, 2))
    regPut "Report\Priority." & Str(nLoop), "Events", Str(aReport(nLoop, 3))
  Next
  'PAGE3
  For nLoop = 0 To 6
    regPut "Report\Schedule", WeekdayName(nLoop + 1), chkDow(nLoop)
  Next
  regPut "Report", "Active", chkActive.Value
  regPut "Report\Schedule", "Time", cmbTime.ListIndex
  '# Reset Scheduler
  'ScheduleNextAction
    
    ' PAGE4 - Debugger
  regPut "Debug", "Send", chkDebug.Value

End Sub

Private Sub cmdCancel_Click()
  Unload Me
End Sub

Private Sub cmdOK_Click()
  '# Apply changes before closing
  cmdApply_Click
  Unload Me
End Sub

'# Reset the report details to default settings.
'# Added for v1.1
Private Sub cmdResetDefault_Click()
Dim nLoop
  For nLoop = 0 To 6
    aReport(nLoop, 0) = Str(aDefault(nLoop)(0))
    aReport(nLoop, 1) = Str(aDefault(nLoop)(1))
    aReport(nLoop, 2) = Str(aDefault(nLoop)(2))
    aReport(nLoop, 3) = Str(aDefault(nLoop)(3))
  Next
  cmbPriority.ListIndex = 0
  cmbPriority_Click
End Sub

Private Sub Form_Load()
Dim nLoop As Byte, nInternal As Byte
Dim nSelected As Integer
Dim i As Integer

  '# Resize Tabstrip to page
  With TabStrip1
    .Left = 120
    .Top = 120
    .Height = Me.ScaleHeight - (Me.ScaleHeight - cmdOK.Top) - 240
    .Width = Me.ScaleWidth - 240
  End With
  
  '# Resize pages to Tabstrip
  For i = 0 To TabStrip1.Tabs.Count - 1
    Picture1(i).BorderStyle = 0
    Picture1(i).Move TabStrip1.ClientLeft, _
                     TabStrip1.ClientTop, _
                     TabStrip1.ClientWidth, _
                     TabStrip1.ClientHeight
  Next i

  '# Bring the first page to the front.
  Picture1(0).ZOrder 0
   
  '# Defaults
  aDefault = Array(Array("0", "0", "0", "0"), _
                   Array("0", "0", "0", "0"), _
                   Array("0", "0", "0", "0"), _
                   Array("0", "0", "1", "100"), _
                   Array("1", "10", "1", "100"), _
                   Array("1", "5", "1", "100"), _
                   Array("2", "0", "0", "0"))
  
  '# Fill the fields with current values.
  ' PAGE1
  txtSMTPserver = regGet("SMTP", "Server", "mail@mydomain.com")
  txtSender = regGet("SMTP", "Sender", CHR34 & "ITSpeedway SYSLOG service" & CHR34 & "<its@mydomain.com>")
  txtRecipient = regGet("SMTP", "Recipient", "me@mydomain.com")
  chkActive.Value = Val(regGet("Report", "Active", "0"))
  txtSubject = regGet("Report", "Subject", "ITSpeedway SYSLOG report - %d")
  optFormat(Val(regGet("Report", "Format", "0"))).Value = True
  optContent(Val(regGet("Report", "Content", "0"))).Value = True
  ' PAGE2
  For nLoop = 0 To 6
    aReport(nLoop, 0) = Val(regGet("Report\Priority." & Str(nLoop), "Result", Str(aDefault(nLoop)(0))))
    aReport(nLoop, 1) = Val(regGet("Report\Priority." & Str(nLoop), "Top", Str(aDefault(nLoop)(1))))
    aReport(nLoop, 2) = Val(regGet("Report\Priority." & Str(nLoop), "Event", Str(aDefault(nLoop)(2))))
    aReport(nLoop, 3) = Val(regGet("Report\Priority." & Str(nLoop), "Events", Str(aDefault(nLoop)(3))))
  Next
  With cmbPriority
    .AddItem "Emergencies", 0
    .AddItem "Alerts", 1
    .AddItem "Critical", 2
    .AddItem "Errors", 3
    .AddItem "Warnings", 4
    .AddItem "Notifications", 5
    .AddItem "Informational", 6
  End With
  cmbPriority.ListIndex = 0
  
  ' PAGE3
  For nLoop = 0 To 6
    nSelected = 0
    If Val(regGet("Report\Schedule", WeekdayName(nLoop + 1), "0")) = 1 Then nSelected = 1
    chkDow(nLoop).Value = nSelected
  Next
  For nLoop = 0 To 23
    cmbTime.AddItem Right("0" & nLoop, 2) & ":00", nLoop
  Next
  cmbTime.ListIndex = Val(regGet("Report\Schedule", "Time", "8"))

  ' PAGE4 - Debugger
  chkDebug.Value = Val(regGet("Debug", "Send", "0"))

End Sub

Private Sub TabStrip1_Click()
  Picture1(TabStrip1.SelectedItem.Index - 1).ZOrder 0
End Sub

Private Sub chkEvents_Click()
  aReport(cmbPriority.ListIndex, 2) = chkEvents.Value
End Sub

Private Sub txtEvents_Change()
  aReport(cmbPriority.ListIndex, 3) = txtEvents
End Sub

Private Sub txtTop_Change()
  aReport(cmbPriority.ListIndex, 1) = txtTop
End Sub

Private Sub optResults_Click(Index As Integer)
  aReport(cmbPriority.ListIndex, 0) = Index
  cmbPriority_Click
End Sub

Private Sub cmbPriority_Click()
Dim nOption As Integer
'On Error Resume Next
  nOption = cmbPriority.ListIndex
  optResults(aReport(nOption, 0)).Value = True
  txtTop = aReport(nOption, 1)
  chkEvents.Value = aReport(nOption, 2)
  txtEvents = aReport(nOption, 3)
  If aReport(nOption, 0) <> 2 Then
    chkEvents.Enabled = True
    lblEvents.Enabled = True
    txtEvents.Enabled = True
  Else
    chkEvents.Enabled = False
    lblEvents.Enabled = False
    txtEvents.Enabled = False
  End If
End Sub

'##########
'# Properties
'##########
Public Property Get ReportActive() As Boolean
  ReportActive = (regGet("Report", "Active", "0") = "1")
End Property

Public Property Let ReportActive(ByVal lNewValue As Boolean)
End Property

Public Function scheduledDay(nDOW As Long) As Boolean
Dim nSelected: nSelected = 0
  If Val(regGet("Report\Schedule", WeekdayName(nDOW + 1), "0")) = 1 Then nSelected = 1
  scheduledDay = nSelected
End Function

Public Function scheduledTime() As Long
Dim nHour As Long
nHour = Val(regGet("Report\Schedule", "Time", "8"))
scheduledTime = (nHour * 60) * 60
End Function

