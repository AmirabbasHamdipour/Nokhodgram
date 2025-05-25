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
	Dim xSupabase As Supabase
	Dim name As String
	Dim phone As String
	Dim Password As String
	Dim bio As String
	Dim Avatar As String
	Dim bmp As Bitmap
	Dim show As Boolean
End Sub

Sub Globals	
	Private AS_Settings1 As AS_Settings
	Private SettingPage2 As AS_SettingsPage
	Private B4XImageView1 As B4XImageView
	Private EditText1 As EditText
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("Settings")
	
	Intialize_SupaBase
	Wait For(Load_Info) Complete (Result As Boolean)
	Log(Result)
	If Avatar="null" Or Avatar="" Then
		bmp.Initialize(File.DirAssets,"Daco_5589426.png")
	Else
		Wait For(File_Check(Avatar)) Complete (Resul As Bitmap)
		bmp.Initialize3(Resul)
	End If
	Settings_Intialize
	Wait For(Load_Info) Complete (Resul1 As Boolean)
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


Sub Load_Info As ResumableSub
	Log("id:   "&File.ReadMap(File.DirInternal,"User.map").Get("id"))
	Dim Query As Supabase_DatabaseSelect = xSupabase.Database.SelectData
	Query.Columns("*").From("NokhodGram_Users")
	Wait For (Query.Execute) Complete (DatabaseResult As SupabaseDatabaseResult)
	xSupabase.Database.PrintTable(DatabaseResult)
	For Each Row As Map In DatabaseResult.Rows
		Log("Id Is:  "&Row.Get("id")&"And File Is:    "&File.ReadMap(File.DirInternal,"User.map").Get("id"))
		If Row.Get("id").As(Int) = File.ReadMap(File.DirInternal,"User.map").Get("id").As(Int) Then
			Log("Yes")
			name=Row.Get("Name")
			Password=Row.Get("Password")
			Avatar=Row.Get("Avatar")
			bio=Row.Get("Bio")
			phone=Row.Get("Phone")
			show=Row.Get("Show")
			Log("All:    "&name&Password&Avatar&bio&phone)
			Return True
		End If
	Next
	Return False
End Sub

Sub Download_Img(name1 As String)As ResumableSub
	Dim DownloadFile As Supabase_StorageFile = xSupabase.Storage.DownloadFile("avatar",name1)
	Wait For (DownloadFile.Execute) Complete (StorageFile As SupabaseStorageFile)
	If StorageFile.Error.Success Then
		Dim Out As OutputStream
		Out = File.OpenOutput(File.dirinternal,name1,True)
		xSupabase.Storage.BytesToImage(StorageFile.FileBody).WriteToStream(Out, 100, "PNG")
		Out.Close
		Return True
	Else
		Log("Error: " & StorageFile.Error.ErrorMessage)
		Return False
	End If
End Sub

Sub File_Check(filename As String)As ResumableSub
	If File.Exists(File.dirinternal,filename)=False Then
		Wait For(Download_Img(filename)) Complete (Resul As Boolean)
	End If
	Return LoadBitmap(File.DirInternal,filename)
End Sub

Private Sub Bio_lbl_Click
	Bio_Click
End Sub

Private Sub Bio_Click
	Dim asdm As ASDraggableBottomCard
	asdm.Initialize(Me,"AS")
	asdm.Create(Activity,60%y,100%y,10%y,100%x,asdm.Orientation_MIDDLE)
	asdm.UserCanClose=True
	Dim l As Label
	l.Initialize("L")
	l.Text="بیوگرافی"
	l.Typeface=Typeface.LoadFromAssets("b-nazanin.ttf")
	l.RemoveView
	asdm.HeaderPanel.AddView(l,0,0,asdm.HeaderPanel.Width,asdm.HeaderPanel.Height)
	Dim et As EditText
	et.Initialize("h")
	et.Gravity=Gravity.RIGHT
	et.Typeface=Typeface.LoadFromAssets("b-nazanin.ttf")
	et.RemoveView
	asdm.BodyPanel.AddView(et,0,0,asdm.BodyPanel.Width,asdm.BodyPanel.Height)
	asdm.Show(False)
End Sub

Sub Edit(text As String,Type1 As String)
	Dim id As Int
	id=File.ReadMap(File.DirInternal,"User.map").Get("id")
	Dim Update As Supabase_DatabaseUpdate = xSupabase.Database.UpdateData
	Update.From("NokhodGram_Users")
	Update.Update(CreateMap(Type1:text))
	Update.Eq(CreateMap("id":id))
	Wait For (Update.Execute) Complete (Result As SupabaseDatabaseResult)
	If Result.Error.Success Then
		Wait For(Load_Info) Complete (Resul As Boolean)
		If Avatar="null" Or Avatar="" Then
			bmp.Initialize(File.DirAssets,"Daco_5589426.png")
		Else
			Wait For(File_Check(Avatar)) Complete (Resul6 As Bitmap)
			bmp.Initialize3(Resul6)
		End If
		Wait For(Load_My_Id) Complete (Resul4422 As Boolean)
		ToastMessageShow("با موفقیت انجام شد.",False)
	End If
End Sub

Sub Settings_Intialize
	AS_Settings1.MainPage.AddSpaceItem("","",10%y)
	AS_Settings1.MainPage.AddProperty_Custom("","Custom3",60%x)
	AS_Settings1.MainPage.AddSpaceItem("","",10%y)
	AS_Settings1.MainPage.AddGroup("Basic","تنظیمات حساب")
	AS_Settings1.GroupProperties.HorizontalTextAlignment="RIGHT"
	AS_Settings1.MainPage.AddDescriptionItem("","تغییرات شما در سرور نخودگرام مستقر در برلین،آلمان ذخیره می شوند.به همین دلیل به اتصال اینترنت نیاز است.")
	AS_Settings1.MainPage.AddProperty_Action("Basic","Name","نام کاربری","",Null," ")
	AS_Settings1.MainPage.AddProperty_Action("Basic","Phone","شماره تلفن","",Null," ")
	AS_Settings1.MainPage.AddProperty_Action("Basic","Bio","بیوگرافی","",Null," ")
	AS_Settings1.MainPage.AddProperty_Boolean("Basic","Show_Phone","نمایش شماره تلفن","آیا شماره موبایلتان را به دیگر کاربران نخودگرام نشان دهیم؟",Null,True)
	AS_Settings1.MadeWithLoveTextColor=Colors.Transparent
	AS_Settings1.MainPage.BottomText = "Nokhodgram" & "    V1.0.2"
	AS_Settings1.MainPage.Create
	SettingPage2.Initialize(AS_Settings1,"بیوگرافی")
	SettingPage2.AddGroup("Page2","")
	SettingPage2.Height=60%y
	SettingPage2.AddProperty_Custom("Page2","Custom1",45%y)
	SettingPage2.AddProperty_Custom("Page2","Custom2",5%y)
End Sub

Private Sub AS_Settings1_ValueChanged(Property As AS_Settings_Property, Value As Object)
	Select Property.PropertyName
		Case "Show_Phone"
			Edit(Value,"Show")
	End Select
End Sub

Private Sub AS_Settings1_ActionClicked(Property As AS_Settings_Property)
	If Property.PropertyName = "Bio" Then
		SettingPage2.ShowPage
		Do While EditText1.IsInitialized=False
			Sleep(0)
		Loop
		If bio="null" Then
			EditText1.Text=""
		Else
			EditText1.Text=bio
		End If
		
	Else If Property.PropertyName="Phone" Then
		Dim id As InputDialog
		id.Input=phone
		Dim sf As Object = id.ShowAsync("", "تغییر شماره تلفن", "تایید", "", "انصراف", Null, False)
		Wait For (sf) Dialog_Result(Result As Int)
		If Result = DialogResponse.POSITIVE And id.Input<>"" Then
			Edit(id.Input,"Phone")
		End If
	Else If Property.PropertyName="Name" Then
		Dim id As InputDialog
		id.Input=name
		Dim sf As Object = id.ShowAsync("", "تغییر نام کاربری", "تایید", "", "انصراف", Null, False)
		Wait For (sf) Dialog_Result(Result As Int)
		If Result = DialogResponse.POSITIVE And id.Input<>"" Then
			Edit(id.Input,"Name")
		End If
	End If
End Sub

Private Sub AS_Settings1_CustomDrawCustomProperty(CustomProperty As AS_Settings_CustomDrawCustomProperty)
	Select CustomProperty.Property.PropertyName
		Case "Custom1"
			CustomProperty.BackgroundPanel.LoadLayout("frm_CustomLayout_1")
		Case "Custom2"
			CustomProperty.BackgroundPanel.LoadLayout("BTN1")
		Case "Custom3"
			CustomProperty.BackgroundPanel.LoadLayout("IMG")
			B4XImageView1.Bitmap=bmp
			B4XImageView1.ResizeMode="FILL_NO_DISTORTIONS"
			B4XImageView1.RoundedImage=True
	End Select
End Sub

Private Sub AMButton1_Click
	If EditText1.Text<>"" Then
		SettingPage2.ClosePage(SettingPage2)
		Edit(EditText1.Text,"Bio")
	End If
End Sub

Private Sub Panel1_Click
	Show_FileSelector
End Sub

Private Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode=KeyCodes.KEYCODE_BACK Then
		Activity.Finish
		StartActivity(Main)
		Return True
	End If
	Return False
End Sub

Sub Show_FileSelector
	Dim Chooser As ContentChooser
	Chooser.Initialize("chooser")
	Chooser.Show("image/*", "Select image")
End Sub

Sub chooser_Result (Success As Boolean, Dir As String, FileName As String)
	If Success Then
		Msgbox2Async("آیا از انتخاب تصویر مطمئنید؟", "آپلود", "بله", "انصراف", "", Null, False)
		Wait For Msgbox_Result (Result As Int)
		If Result = DialogResponse.POSITIVE Then
			ProgressDialogShow2("در حال آپلود...",False)
			Dim a As String=GenerateUniqueText&".png"
			File.Copy(Dir,FileName,File.dirinternal,a)
			Upload_File(File.dirinternal,a)
		End If
	Else
		ToastMessageShow("تصویری انتخاب نشده", True)
	End If
End Sub

Sub Upload_File(Dir As String,FileName As String)
	Dim UploadFile As Supabase_StorageFile = xSupabase.Storage.UploadFile("avatar",FileName)
	UploadFile.FileBody(xSupabase.Storage.ConvertFile2Binary(Dir,FileName))
	Wait For (UploadFile.Execute) Complete (StorageFile As SupabaseStorageFile)
	If StorageFile.Error.Success Then
		Log($"File ${"test.jpg"} successfully uploaded "$)
		Edit(FileName,"Avatar")
		ProgressDialogHide
	Else
		Log("Error: " & StorageFile.Error.ErrorMessage)
	End If
End Sub

Sub GenerateUniqueText As String
	Dim now As Long = DateTime.Now
	Dim year As Int = DateTime.GetYear(now)
	Dim month As Int = DateTime.GetMonth(now)
	Dim day As Int = DateTime.GetDayOfMonth(now)
	Dim hour As Int = DateTime.GetHour(now)
	Dim minute As Int = DateTime.GetMinute(now)
	Dim second As Int = DateTime.GetSecond(now)
    
	'Generate a random part
	Dim randomPart As String = GenerateRandomString(8)
    
	'Combine all parts to create a unique string
	Dim uniqueString As String = $"${year}${month}${day}_${hour}${minute}${second}$_${randomPart}"$
    
	Return uniqueString
End Sub

Sub GenerateRandomString(Length As Int) As String
	Dim sb As StringBuilder
	sb.Initialize
	Dim chars As String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	For i = 1 To Length
		Dim index As Int = Rnd(0, chars.Length)
		sb.Append(chars.CharAt(index))
	Next
	Return sb.ToString
End Sub

Sub Load_My_Id As ResumableSub
	Dim l As List
	l.Initialize
	Dim Query As Supabase_DatabaseSelect = xSupabase.Database.SelectData
	Query.Columns("*").From("NokhodGram_Users")
	Wait For (Query.Execute) Complete (DatabaseResult As SupabaseDatabaseResult)
	xSupabase.Database.PrintTable(DatabaseResult)
	For Each Row As Map In DatabaseResult.Rows
		If Row.Get("id").As(Int)=File.ReadMap(File.DirInternal,"User.map").Get("id").As(Int) Then
			File.WriteMap(File.DirInternal,"User.map",CreateMap("id":Row.Get("id"),"Name":Row.Get("Name"),"Phone":Row.Get("Phone")))
			Return True
		End If
	Next
	Return False
End Sub