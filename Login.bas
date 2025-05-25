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
	Private xSupabase As Supabase
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private Name As AS_TextFieldAdvanced
	Private Moblie As AS_TextFieldAdvanced
	Private Password As AS_TextFieldAdvanced
	Private Password_Again As AS_TextFieldAdvanced
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("Login_Page")
	Intialize_SupaBase
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

public Sub Intialize_SupaBase
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

Private Sub Login_Click
	If Password.Text=Password_Again.Text And Name.Text<>"" And Moblie.Text<>"" And Password_Again.Text<>"" And Password.Text<>"" Then
		ProgressDialogShow2("در حال ورود...",False)
		Send_Name(Name.Text,Moblie.Text,Password.Text)
	Else
		Password_Again.ShowDisplayMissingField("باید با بالایی تطابق داشته باشد.")
		Password.ShowDisplayMissingField("نباید خالی باشد.")
		Name.ShowDisplayMissingField("نباید خالی باشد.")
		Moblie.ShowDisplayMissingField("نباید خالی باشد.")
		Sleep(1000)
		Password.HideDisplayMissingField
		Password_Again.HideDisplayMissingField
		Name.HideDisplayMissingField
		Moblie.HideDisplayMissingField
	End If
End Sub

Sub Send_Name(Name1 As String, Phone1 As String,Password1 As String)
	DateTime.TimeFormat="HH:mm"
	Dim Insert As Supabase_DatabaseInsert = xSupabase.Database.InsertData
	Insert.From("NokhodGram_Users")
	Dim InsertMap As Map = CreateMap("Name":Name1,"Phone":Phone1,"Password":Password1,"LastSeen":DateTime.Time(DateTime.Now))
	Wait For (Insert.Insert(InsertMap).Execute) Complete (Result As SupabaseDatabaseResult)
	If Result.Error.Success=True Then
		Load_My_Id(Phone1)
	End If
End Sub

Sub Load_My_Id(Phone2 As String)
	Dim l As List
	l.Initialize
	Dim Query As Supabase_DatabaseSelect = xSupabase.Database.SelectData
	Query.Columns("*").From("NokhodGram_Users")
	Wait For (Query.Execute) Complete (DatabaseResult As SupabaseDatabaseResult)
	xSupabase.Database.PrintTable(DatabaseResult)
	For Each Row As Map In DatabaseResult.Rows
		If Row.Get("Phone")=Phone2 Then
			File.WriteMap(File.DirInternal,"User.map",CreateMap("id":Row.Get("id"),"Name":Row.Get("Name"),"Phone":Row.Get("Phone")))
			ToastMessageShow("خوش آمدید!",False)
			ProgressDialogHide
			Activity.Finish
			StartActivity(Main)
		End If
	Next
End Sub