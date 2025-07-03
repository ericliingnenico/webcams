#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/pFSPMaintainPWD.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On

Imports System.Drawing  'added  20210725  for color
Imports eCAMS.AuthWS


Namespace eCAMS

    '----------------------------------------------------------------
    ' Namespace: eCAMS
    ' Class: pFSPMaintainPWD
    '
    ' Description: 
    '   Maintain User's PWD - PDA portal
    '----------------------------------------------------------------
    Partial Class pFSPMaintainPWD
        Inherits PDAPageBase

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

#Region "Function"
        Protected Overrides Sub Process()
            Call SetDE()
        End Sub

        '----------------------------------------------------------------
        ' SetDE:
        '   Set data entry fields for this page
        '----------------------------------------------------------------
        Private Sub SetDE()
            Me.PageTitle = "Maintain"

            ''Set Info Label
            lblFormTitle.Text = "Change Password"
        End Sub
        ''validate password
        Private Function ValidationOK() As Boolean


            ''trim the password
            txtNewPWD.Text = txtNewPWD.Text.Trim()
            txtReTypeNewPWD.Text = txtReTypeNewPWD.Text.Trim()

            ''hide the error msg
            ErrMsg.Visible = False

            ''verify if it is too short
            ''pwd  new rules  apply  min 8
            If txtNewPWD.Text.Length < 8 Or
         Not IsAlphaNumeric(txtNewPWD.Text) Then
                ErrMsg.Text = "Password must minimum 8 characters (14 characters for admin acc), at least one uppercase letter, one lowercase letter and one numbers.(NO  special character). Cannot be the same as any of the previous 12 passwords."
                ErrMsg.Visible = True
                Return False
            End If

            ''verify if the two password are the same
            If txtNewPWD.Text <> txtReTypeNewPWD.Text Then
                ErrMsg.Text = "Passwords are not the same. Please enter again."
                ErrMsg.Visible = True
                Return False
            End If

            Return True
        End Function
        'Private Function IsAlphaNumeric(ByVal strText As String) As Boolean
        '    Dim i As Integer
        '    Dim ch As String
        '    Dim IsNum As Boolean
        '    Dim IsAlpha As Boolean

        '    IsNum = False : IsAlpha = False

        '    For i = 1 To Len(strText)
        '        ch = Mid(strText, i, 1)
        '        If IsNumeric(ch) Then
        '            IsNum = True
        '        Else
        '            IsAlpha = True
        '        End If
        '    Next
        '    Return IsNum And IsAlpha
        'End Function
        Private Function IsAlphaNumeric(ByVal strText As String) As Boolean
            Dim i As Integer
            Dim ch As String
            Dim IsNum As Boolean
            Dim IsAlpha As Boolean


            IsNum = False : IsAlpha = False

            For i = 1 To Len(strText)
                ch = Mid(strText, i, 1)
                If IsNumeric(ch) Then
                    IsNum = True
                End If
            Next

            'Check Min 8 characters (14 for admin ), at least one uppercase letter, one lowercase letter and one numbers.(NO  special character)
            If System.Text.RegularExpressions.Regex.IsMatch(strText, "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$") Then
                IsAlpha = True
            Else
                IsAlpha = False
            End If


            Return IsNum And IsAlpha
        End Function


#End Region

#Region "Event"
        Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
            MyBase.Page_Load(sender, e)

            ''Set initial Focus
            Call SetFocus(txtNewPWD)
        End Sub

        Private Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click
            Dim dlResult As DataLayerResult

            Dim UserID As Integer
            Dim test As String
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



            'Check admin user min 14  and std use 8  min here' (chk1)
            FlagAdmin = CStr(CType(Session("UserInfo"), UserInformation).MenuSet)

            pwdLength = txtNewPWD.Text.Length

            'lblFormTitle3.Text = "FlagAdmin  " + CStr(FlagAdmin) + "<Br>"
            'lblFormTitle4.Text = CStr(pwdLength) + "<Br>"

            If FlagAdmin = "Menu_FSP_Admin" And txtNewPWD.Text.Length < 14 Then

                FlagAdminCompare = "Minimum  14 characters for admin account. Your pwd length is <B>" + CStr(pwdLength)
                lblFormTitle.Text = "Password failed to update."
                lblFormTitle.ForeColor = Color.Red
                lblFormTitle1.Text = FlagAdminCompare
                Exit Sub

            Else

                'standard  users  pass  thru here

            End If



            'Check  cannot reset  pwd  twice in 24 hrs here  OR  change once in 24 hrs (chk3)
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
                'Exit Sub
            Else

                pwdCompare = "Password cannot be changed twice within any 24  hour period"
                lblFormTitle.Text = "Password failed to update."
                lblFormTitle.ForeColor = Color.Red
                lblFormTitle1.Text = pwdCompare
                Exit Sub

            End If


            UserID = CInt((CType(Session("UserInfo"), UserInformation).UserID)) '204406
            test = CStr((CType(Session("UserInfo"), UserInformation).UserID)) '204406
            ErrMsg1.Text = pwdCompare

            UsertxtNewPWD = txtNewPWD.Text

            LastPWD = Convert.ToBase64String(CType(Session("UserInfo"), UserInformation).Password) 'gnppxXSivYbQVcoGHYiU/A==
            UsertxtNewPWDEncrypt = Convert.ToBase64String(clsTool.EncryptPWD(txtNewPWD.Text))


            'Check current PWD and new PWD  are the same (chk1)

            If UsertxtNewPWDEncrypt Like LastPWD Then

                'pwdCompare = "Password will fail to update if you use  SAME as last one"
                'ErrMsg.Text = "Password failed to update."
                'ErrMsg1.Text = pwdCompare
                'Exit Sub
                pwdCompare = "Password will fail to update if you use  the SAME as last one"
                lblFormTitle.Text = "Password failed to update."
                lblFormTitle.ForeColor = Color.Red
                lblFormTitle1.Text = pwdCompare
                Exit Sub
            Else

                'Exit Sub
            End If

            If ValidationOK() Then
                dlResult = m_DataLayer.ChangePassword(clsTool.EncryptPWD(txtNewPWD.Text))
                If dlResult = DataLayerResult.Success Then
                    ErrMsg.Text = "Password was updated successfully."
                    ErrMsg.ForeColor = Color.Green
                    ErrMsg.Visible = True
                    Label9.Visible = False
                Else
                    ErrMsg.Text = "Password was failed to update"
                    ErrMsg.Visible = True
                End If

            End If
        End Sub

#End Region


    End Class

End Namespace
