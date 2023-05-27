VERSION 5.00
Begin VB.Form frmselect 
   Caption         =   "caption - "
   ClientHeight    =   3615
   ClientLeft      =   1260
   ClientTop       =   2085
   ClientWidth     =   7770
   LinkTopic       =   "Form1"
   ScaleHeight     =   3615
   ScaleWidth      =   7770
   StartUpPosition =   2  'CenterScreen
   Begin VB.ComboBox cbofiletype 
      Height          =   315
      Left            =   240
      Style           =   2  'Dropdown List
      TabIndex        =   8
      Top             =   3120
      Width           =   2655
   End
   Begin VB.FileListBox filfiles 
      Height          =   1650
      Left            =   240
      TabIndex        =   6
      Top             =   960
      Width           =   2655
   End
   Begin VB.TextBox txtfilename 
      Height          =   375
      Left            =   240
      TabIndex        =   5
      Top             =   480
      Width           =   2655
   End
   Begin VB.DriveListBox drvdrive 
      Height          =   315
      Left            =   3240
      TabIndex        =   3
      Top             =   3120
      Width           =   2775
   End
   Begin VB.DirListBox dirdirectory 
      Height          =   1665
      Left            =   3240
      TabIndex        =   2
      Top             =   960
      Width           =   2755
   End
   Begin VB.CommandButton cmdcancel 
      Caption         =   "&Cancel"
      Height          =   495
      Left            =   6360
      TabIndex        =   1
      Top             =   1080
      Width           =   1215
   End
   Begin VB.CommandButton cmdok 
      Caption         =   "&Ok"
      Default         =   -1  'True
      Height          =   495
      Left            =   6360
      TabIndex        =   0
      Top             =   480
      Width           =   1215
   End
   Begin VB.Label lbldrive 
      Caption         =   "Drive:"
      Height          =   255
      Left            =   3240
      TabIndex        =   11
      Top             =   2880
      Width           =   1095
   End
   Begin VB.Label lbldirname 
      Height          =   375
      Left            =   3360
      TabIndex        =   10
      Top             =   480
      Width           =   2175
   End
   Begin VB.Label lbldirectories 
      Caption         =   "Directories:"
      Height          =   255
      Left            =   3360
      TabIndex        =   9
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label lblfiletype 
      Caption         =   "File Type:"
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   2880
      Width           =   1095
   End
   Begin VB.Label lblfilename 
      Caption         =   "Filename"
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   240
      Width           =   1095
   End
End
Attribute VB_Name = "frmselect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdCancel_Click()
    frmmain.Enabled = True
    Unload Me
End Sub

Private Sub cmdok_Click()
Dim x As String, fname As String, y As String
Dim pathandname As String, path As String
    If txtfilename.Text = "" Then
        MsgBox "You must first select a file!"
        Exit Sub
    End If
    If Right(filfiles.path, 1) <> "\" Then
        path = filfiles.path + "\"
    Else
        path = filfiles.path
    End If
    If txtfilename.Text = filfiles.FileName Then
        pathandname = path + filfiles.FileName
    Else
        pathandname = txtfilename.Text
    End If
    
'    x = "C:\rigs\" & Trim(txtfilename.Text)
'   x = "c:\rigs\tr.txt"
    y = "C:\windows\notepad.exe " & pathandname
    Shell y, 3
End Sub

Private Sub filfiles_dblclick()
    txtfilename.Text = filfiles.FileName
    cmdok_Click
End Sub

Sub Sub1()

Dim x As Object

Set x = GetObject(, "notepad.Application")

AppActivate x.Caption

End Sub

Private Sub Form_Load()
    'fill the cbo file type
On Error GoTo loaderror
    cbofiletype.AddItem "Text files(*.TXT)"
    cbofiletype.ListIndex = 0
    dirdirectory.path = "c:\transcript"
    lbldirname.Caption = dirdirectory.path
loaderror:
    If Err.Number <> 0 Then
        MsgBox Err.Description
        Exit Sub
    End If
End Sub

Private Sub drvdrive_change()
On Error GoTo driveerror
    dirdirectory.path = drvdrive.Drive
    Exit Sub
driveerror:
    MsgBox "Drive Error!", vbExclamation, "Error"
    drvdrive.Drive = dirdirectory.path
    Exit Sub
End Sub

Private Sub dirdirectory_change()
    filfiles.path = dirdirectory.path
    lbldirname.Caption = dirdirectory.path
End Sub

Private Sub cbofiletype_click()
    Select Case cbofiletype.ListIndex
    Case 0
         filfiles.Pattern = "*.FRM"
    End Select
        
End Sub

Private Sub filfiles_click()
    txtfilename.Text = filfiles.FileName
End Sub