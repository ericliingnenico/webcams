'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 10/08/11 15:38 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpMaintainPWD.aspx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On
Imports eCAMS.AuthWS 'added 20210719
Namespace eCAMS
Public Class mpMaintainPWD
    Inherits MemberPageBase

        Private Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click

            'pwd  complexity rules 
            Dim pwdCompare As String
            Dim UsertxtNewPWD As String
            Dim UsertxtNewPWDEncrypt As String
            Dim LastPWD As String

            'Check admin user min 14 
            Dim FlagAdmin As String
            Dim pwdLength As Integer
            'Dim FlagAdminCompare As String

            'Check  cannot reset  pwd  twice in 24
            Dim LastUpdateTIme As DateTime
            Dim ExpiryDay As DateTime
            Dim HourLapse As String
            Dim Period As String


            'Check admin user min 14  and std use 8  min here' (chk1)
            FlagAdmin = CStr(CType(Session("UserInfo"), UserInformation).MenuSet)

            pwdLength = txtNewPWD.Text.Length

            If FlagAdmin = "Menu_FSP_Admin" And txtNewPWD.Text.Length < 14 Then
                'Check admin user min 14 
                panelAcknowledgeFailed3.Visible = True
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

            'lblFormTitle3.Text = "LastUpdateTIme " + CStr(LastUpdateTIme) + "<Br>"
            'lblFormTitle4.Text = "ExpiryDay" + CStr(ExpiryDay) + "<Br>"
            'lblFormTitle6.Text = "Period" + Period + "<Br>"



            'note  have to set  55  instead of  60 because  difference bte UpdateTime and ExpiryDate  varies from  59  to 61 
            If (CInt(Period) > 55 And CInt(HourLapse) > 24) Or CInt(Period) < 55 Then

                ' ok proceed  to next  check
                'panelAcknowledgeFailed3.Visible = True
                'Exit Sub
            Else
                ' error message
                panelAcknowledgeFailed2.Visible = True
                Exit Sub

            End If


            UsertxtNewPWD = txtNewPWD.Text

            LastPWD = Convert.ToBase64String(CType(Session("UserInfo"), UserInformation).Password) 'gnppxXSivYbQVcoGHYiU/A==
            UsertxtNewPWDEncrypt = Convert.ToBase64String(clsTool.EncryptPWD(txtNewPWD.Text))


            'Check current PWD and new PWD  are the same (chk2)
            'IsPostback - if nec
            If UsertxtNewPWDEncrypt Like LastPWD Then
                'Fails  when curre and new PWD  are the same
                panelAcknowledgeFailed1.Visible = True

                Exit Sub

            Else

                'Exit Sub
            End If



            If m_DataLayer.ChangePassword(clsTool.EncryptPWD(txtNewPWD.Text)) = DataLayerResult.Success Then
                panelMain.Visible = False
                panelAcknowledgeSuccess.Visible = True
                panelAcknowledgeFailed1.Visible = False

            Else
                panelAcknowledgeFailed.Visible = True
            End If
        End Sub
    End Class
End Namespace