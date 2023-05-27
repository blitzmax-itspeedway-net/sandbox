VERSION 5.00
Begin VB.Form DemoForm
   BackColor = &H00000000&
   Caption = "Screen Blanker Demo"
   ClientHeight = 960
   ClientLeft = 1965
   ClientTop = 1965
   ClientWidth = 7470
   ForeColor = &H00000000&
   Begin Property Font
      name = "MS Sans Serif"
      charset = 0
      .
      .
      .
   End Property
   Height = 5115
   Icon = "Blanker.frx":0018
   Left = 900
   LinkMode = 1                     ' Source
   LinkTopic = "Form1"
   ScaleHeight = 4425
   ScaleWidth = 7470
   Top = 1335
   Width = 7590
   Begin VB.Timer Timer1
      Interval = 1
      Left = 6960
      Top = 120
   End
   Begin VB.CommandButton cmdStartStop
      BackColor = &H00000000&
      Caption = "Start Demo"
      Default = -1
      Height = 390
      Left = 240
      TabIndex = 0
      Top = 120
      Width = 1830
   End
   Begin VB.PictureBox picBall
      AutoSize = -1               ' True
      BackColor = &H00000000&
      BorderStyle = 0               ' None
      ForeColor = &H00FFFFFF&
      Height = 465
      Left = 1800
      Picture = "Blanker.frx":0788
      ScaleHeight = 465
      ScaleWidth = 465
      TabIndex = 1
      Top = 720
      Visible = 0                  ' False
      Width = 465
   End
   .
   .
   .
   Begin VB.Menu mnuOption
      Caption = "&Options"
      Begin VB.Menu mnuLineCtlDemo
         Caption = "&Jumpy Line"
         Checked = -1               ' True
      End
      Begin VB.Menu mnuCtlMoveDemo
         Caption = "Re&bound"
      End
      .
      .
      .
      Begin VB.Menu mnuExit
         Caption = "E&xit"
      End
   End
End
