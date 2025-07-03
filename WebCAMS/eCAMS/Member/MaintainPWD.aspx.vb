'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/11/12 15:01 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/MaintainPWD.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
'Imports eCAMS
Imports eCAMS.AuthWS 'added 20210716
Imports System.Drawing

Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: MaintainPWD
'
' Description: 
'   Password maintenance page
'----------------------------------------------------------------

Partial Class MaintainPWD
    Inherits MemberPageBase
    Protected WithEvents Label1 As System.Web.UI.WebControls.Label
    Protected WithEvents RequiredFieldValidator1 As System.Web.UI.WebControls.RequiredFieldValidator

#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub

    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region
    ''Local Variable
    '*************** Functions ***************
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Maintain Password"

        ''Set Info Label
        ''lblFormTitle.Text = "Change Password"
    End Sub
    Private Function ValidationOK() As Boolean
        Dim bRet As Boolean = True
            If txtNewPWD.Value = "9433pass" Then
                bRet = False
            End If

            If txtNewPWD.Value.Trim.Length < 8 Or txtNewPWD.Value.Length > 16 Then
                bRet = False
            End If
        End Function

    '*************** Events Handlers ***************
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
            MyBase.Page_Load(sender, e)


            'Dim test As String
            'Dim test1 As String

            'test = CStr((CType(Session("UserInfo"), UserInformation).UserID)) '204406
            'test1 = Convert.ToBase64String(CType(Session("UserInfo"), UserInformation).Password) 'gnppxXSivYbQVcoGHYiU/A==

            'lblFormTitle2.Text = "PageLoad-USerID  is <B>" + test + "<Br>PageLoad- old pass : " + test1

            UserPasswordAlert1.HideAlertMessage()
        UserPasswordAlert1.DisableMenuOnExpiredPassword()

        ''Set initial Focus
        If panelPasswordDE.Visible then
            Call SetFocus(txtNewPWD)
        End If
    End Sub

        Private Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click


            Dim UserID As Integer
            'Dim test As String
            Dim UsertxtNewPWD As String
            Dim UsertxtNewPWDEncrypt As String
            Dim pwdCompare As String
            Dim LastPWD As String

            'Check admin user min 14 
            Dim FlagAdmin As String
            Dim pwdLength As Integer
            Dim FlagAdminCompare As String

            'Check  cannot reset  pwd  twice in 24
            Dim LastUpdateTIme As DateTime
            Dim ExpiryDay As DateTime
            Dim HourLapse As String
            Dim Period As String



            UserID = CInt((CType(Session("UserInfo"), UserInformation).UserID)) '204406
            'test = CStr((CType(Session("UserInfo"), UserInformation).UserID)) '204406

            UsertxtNewPWD = txtNewPWD.Value

            'Check admin user min 14  and std use 8  min here' (chk1)
            FlagAdmin = CStr(CType(Session("UserInfo"), UserInformation).MenuSet)

            pwdLength = txtNewPWD.Value.Length

            'This is  for output  check  per PHP print_r  workaround
            'lblFormTitle3.Text = "FlagAdmin  " + CStr(FlagAdmin) + "<Br>"
            'lblFormTitle4.Text = CStr(pwdLength) + "<Br>"

            If FlagAdmin = "Menu_FSP_Admin" And txtNewPWD.Value.Length < 14 Then

                FlagAdminCompare = "Minimum  14 characters for admin account. Your pwd length is <B>" + CStr(pwdLength)
                lblFormTitle.Text = "Password failed to update."
                lblFormTitle.ForeColor = Color.Red
                lblFormTitle1.Text = FlagAdminCompare
                Exit Sub

            Else

                'standard  users  pass  thru here

            End If


            'Check  cannot reset  pwd  twice in 24 hrs here  OR  change once in 24 hrs (Chk3)
            ' 2 checks  1  UpdateTime and ExpiryDate  is  60  and UpdateTime is more than 24 hrs  from now
            ' Ok to change if TimeLapse  is  > 24 hrs
            'If less than  24 hrs , error  message  --Password cannot be changed twice within any 24  hour period.


            LastUpdateTIme = CType(CType(Session("UserInfo"), UserInformation).UpdateTime, DateTime)
            ExpiryDay = CType(CType(Session("UserInfo"), UserInformation).ExpiryDate, DateTime)
            HourLapse = CStr(DateDiff(DateInterval.Hour, LastUpdateTIme, Now))
            Period = CStr(DateDiff(DateInterval.Day, LastUpdateTIme, ExpiryDay))

            'lblFormTitle3.Text = "LastUpdateTIme " + CStr(LastUpdateTIme) + "<Br>"
            'lblFormTitle4.Text = "ExpiryDay" + CStr(ExpiryDay) + "<Br>"
            'lblFormTitle5.Text = "HourLapse" + HourLapse + "<Br>"
            'lblFormTitle6.Text = "Period" + Period + "<Br>"

            'note  have to set  55  instead of  60 because  difference btw UpdateTime and ExpiryDate  varies from  59  to 61 
            'If (Period > "55" And HourLapse > "24") Or Period < "55" Then
            If (CInt(Period) > 55 And CInt(HourLapse) > 24) Or CInt(Period) < 55 Then
                    ' ok proceed  to next  check

                Else

                pwdCompare = "Password cannot be changed twice within any 24  hour period"
                lblFormTitle.Text = "Password failed to update."
                lblFormTitle.ForeColor = Color.Red
                lblFormTitle1.Text = pwdCompare
                Exit Sub

            End If


            UserID = CInt((CType(Session("UserInfo"), UserInformation).UserID)) '204406
            'test = CStr((CType(Session("UserInfo"), UserInformation).UserID)) '204406

            UsertxtNewPWD = txtNewPWD.Value

            LastPWD = Convert.ToBase64String(CType(Session("UserInfo"), UserInformation).Password) 'gnppxXSivYbQVcoGHYiU/A==
            UsertxtNewPWDEncrypt = Convert.ToBase64String(clsTool.EncryptPWD(txtNewPWD.Value))

            'Check current PWD and new PWD  are the same (chk2)

            If UsertxtNewPWDEncrypt Like LastPWD Then

                pwdCompare = "Password will fail to update if you use  the SAME as last one"
                lblFormTitle.Text = "Password failed to update."
                lblFormTitle.ForeColor = Color.Red
                lblFormTitle1.Text = pwdCompare
                Exit Sub

            Else

                'Exit Sub
            End If

            Dim dlResult As DataLayerResult
            dlResult = m_DataLayer.ChangePassword(clsTool.EncryptPWD(txtNewPWD.Value))
            With lblFormTitle

                If dlResult = DataLayerResult.Success Then
                    .Text = "Password updated successfully."
                    .ForeColor = Color.Green
                    panelPasswordDE.Visible = False
                    UserPasswordAlert1.DisableMenuOnExpiredPassword()
                Else
                    .Text = "Password failed to update."
                    .ForeColor = Color.Red
                End If
            End With

        End Sub
    End Class

End Namespace
