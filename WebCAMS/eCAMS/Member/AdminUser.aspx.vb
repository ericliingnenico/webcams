#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/AdminUser.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Imports eCAMS
Imports eCAMS.AuthWS
Partial Class Member_AdminUser
    Inherits MemberPageBase

    Public Property Current As Object

    Protected Overrides Sub Process()
        SetDE()
    End Sub
    Protected Overrides Sub AddClientScript()

        ''add onblur to txtFSPID
        Me.SetFocus(txtEmailAddress)

        Me.TieButton(txtEmailAddress, btnGetUser)

    End Sub

    Private Sub SetDE()
        Me.RestrictModuleName = "AdminUser"

        Me.PageTitle = "User Admin"
        Me.btnDeActiveUser.Visible = False
        Me.btnResetPWD.Visible = False
        Me.btnAddUser.Visible = True
    End Sub

Protected Sub btnGetUser_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnGetUser.ServerClick
        If m_DataLayer.GetUserList(txtEmailAddress.Text) = DataLayerResult.Success Then
            With m_DataLayer.dsTemp
                If .Tables.Count > 0 AndAlso .Tables(0).Rows.Count > 0 Then
                    txtUserName.Text = Convert.ToString(.Tables(0).Rows(0)("UserName"))
                    txtMenuSetID.Text = Convert.ToString(.Tables(0).Rows(0)("MenuSetID")) 'John added 2021-07-14 (chk1)
                    btnResetPWD.Visible = True
                    btnDeActiveUser.Visible = True
                    btnAddUser.Visible = False
                End If

            End With
        Else
            lblFormTitle.Font.Bold = False
            lblFormTitle.ForeColor = Drawing.Color.Red
            lblFormTitle.Text = "Failed to retrieve user."
        End If
End Sub

Protected Sub btnResetPWD_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnResetPWD.Click
        ''get new password
        Dim newPassword As String

        'Min of 8 characters (min 14 characters for admin accounts)(chk1)
        If txtMenuSetID.Text = "4" Then

            newPassword = Membership.GeneratePassword(14, 0)
        Else

            newPassword = Membership.GeneratePassword(10, 0)
        End If

        'TimeLapse = CType(CType(Session("UserInfo"), UserInformation).UpdateTime, DateTime)
        'Time1 = CStr(DateDiff(DateInterval.Hour, TimeLapse, Now))

        If m_DataLayer.AdminUser(txtEmailAddress.Text, txtUserName.Text, newPassword, "", "", "", 2) = DataLayerResult.Success Then
            lblFormTitle.Font.Bold = False
            lblFormTitle.Text = "Password has been reset to <B>" + newPassword + "</B> Please change this temp password  asap. It expires in 7 days "

        Else
            lblFormTitle.Font.Bold = False
            lblFormTitle.ForeColor = Drawing.Color.Red
            lblFormTitle.Text = "Failed to reset user password."

        End If




    End Sub

Protected Sub btnDeActiveUser_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnDeActiveUser.Click
        If m_DataLayer.AdminUser(txtEmailAddress.Text, "", "", "", "", "", 3) = DataLayerResult.Success Then
            lblFormTitle.Text = "Password has been deactivated."
        Else
            lblFormTitle.Font.Bold = False
            lblFormTitle.ForeColor = Drawing.Color.Red
            lblFormTitle.Text = "Failed to deactivate user."

        End If

End Sub

Protected Sub btnAddUser_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddUser.Click
        ''get new password
        Dim newPassword As String
        'Min of 8 characters (min 14 chracters for admin accounts)(chk1)
        If txtMenuSetID.Text = "4" Then
            newPassword = Membership.GeneratePassword(14, 0)

        Else

            newPassword = Membership.GeneratePassword(10, 0)

        End If

        If m_DataLayer.AdminUser(txtEmailAddress.Text, txtUserName.Text, newPassword, txtClientIDs.Text, txtInstallerID.Text, txtMenuSetID.Text, 1) = DataLayerResult.Success Then
            lblFormTitle.Font.Bold = False
            lblFormTitle.Text = "Password has been reset to <B>" + newPassword + "</B> Please change this temp password  asap. It expires in 7 days "
        Else
            lblFormTitle.Font.Bold = False
            lblFormTitle.ForeColor = Drawing.Color.Red
            lblFormTitle.Text = "Failed to add the user."

        End If

End Sub
End Class
