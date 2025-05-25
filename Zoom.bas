B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=13
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	Private Zoom1 As ZoomImageView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("Zoom")
	Dim cs As CSBuilder
	cs.Initialize.Size(15).Typeface(Typeface.FONTAWESOME).Append(Chr(0xF0C7)).PopAll
	Activity.AddMenuItem3(cs,"Save",Null,True)
	Zoom1.SetBitmap(Main.zoo)
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Private Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode=KeyCodes.KEYCODE_BACK Then
		Activity.Finish
		StartActivity(Main)
		Return True
	Else
		Return False
	End If
End Sub

Private Sub Save_Click
	Dim Out As OutputStream
	Out = File.OpenOutput(File.DirRootExternal,DateTime.Time(DateTime.Now)&".png", True)
	Main.zoo.WriteToStream(Out, 100, "PNG")
	Out.Close
	ToastMessageShow("تصویر با موفقیت ذخیره شد.",True)
End Sub