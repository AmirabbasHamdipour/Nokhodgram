B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=13
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Dim ID As Int=Main.HisID
	Type Info(ID As Int,Name As String,Bio As String,Phone As String,Show As Boolean,Avatar As String)
	Private xSupabase As Supabase
	Private B4XImageView1 As B4XImageView
	Private Bio_lbl As Label
	Private Name_lbl As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("HisProf")
	intialize_SupaBase
	Wait For(Load_He_INF)Complete(Res As Info)
	If Res.Bio="" Or Res.Bio="null" Then
		Bio_lbl.Text="این کاربر برای خود بیوگرافی تعیین نکرده است."
	Else
		Bio_lbl.Text="بیوگرافی:   "&CRLF&Res.Bio
	End If
	Name_lbl.Text=Res.Name
	Wait For(File_CheckForAvatar(Res.Avatar))Complete(resault As String)
	B4XImageView1.Bitmap=LoadBitmap(File.DirInternal,resault)
	B4XImageView1.RoundedImage=True
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


public Sub intialize_SupaBase
	'Please Intialize Your SupaBase With Your Project URL And Your API_Key
	xSupabase.InitializeEvents(Me,"Supabase")
	Wait For (xSupabase.Auth.isUserLoggedIn) Complete (isLoggedIn As Boolean)
	If isLoggedIn = False Then
		Wait For (xSupabase.Auth.LogIn_Anonymously) Complete (User As SupabaseUser)
		If User.Error.Success Then
			Log("successfully logged in with ")
		Else
			Log("Error: " & User.Error.ErrorMessage)
			Return
		End If
	End If
End Sub

Sub Load_He_INF As ResumableSub
	Dim Query As Supabase_DatabaseSelect = xSupabase.Database.SelectData
	Query.Columns("*").From("NokhodGram_Users")
	Wait For (Query.Execute) Complete (DatabaseResult As SupabaseDatabaseResult)
	xSupabase.Database.PrintTable(DatabaseResult)
	For Each Row As Map In DatabaseResult.Rows
		If Row.Get("id").As(Int)=ID Then
			Dim a As Info
			a.Initialize
			a.ID=Row.Get("id")
			a.Bio=Row.Get("Bio")
			a.Name=Row.Get("Name")
			a.Phone=Row.Get("Phone")
			a.Avatar=Row.Get("Avatar")
			a.Show=Row.Get("Show").As(Boolean)
			Return a
		End If
	Next
	Return a
End Sub

Sub File_CheckForAvatar(filename As String)As ResumableSub
	If File.Exists(File.dirinternal,filename)=False Then
		Wait For(Download_ImgForAvatar(filename)) Complete (Result As Boolean)
	End If
	Return filename
End Sub

Sub Download_ImgForAvatar(name As String)As ResumableSub
	Dim DownloadFile As Supabase_StorageFile = xSupabase.Storage.DownloadFile("avatar",name)
	Wait For (DownloadFile.Execute) Complete (StorageFile As SupabaseStorageFile)
	If StorageFile.Error.Success Then
		BytesToFile(File.DirInternal,name,StorageFile.FileBody)
		Return True
	Else
		Log("Error: " & StorageFile.Error.ErrorMessage)
		Return False
	End If
End Sub

Sub BytesToFile (Dir As String, FileName As String, Data() As Byte)
	Dim out As OutputStream = File.OpenOutput(Dir, FileName, False)
	out.WriteBytes(Data, 0, Data.Length)
	out.Close
End Sub