Option Strict On
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/04/11 17:09 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/ForgotPWD.aspx.vb $-->
'<!--$$NoKeywords: $-->

Imports System.Web.Helpers

Namespace eCAMS
    Public Class ForgotPWD
        Inherits PageBase

        Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
            ' Prevent AntiForgery from adding its own X-Frame-Options header
            AntiForgeryConfig.SuppressXFrameOptionsHeader = True
        End Sub
        Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnSubmit.Click
            ''get new password
            Dim newPassword As String
            'Minimum of 14 characters (chk1)
            newPassword = Membership.GeneratePassword(14, 0)
            If m_DataLayer.ResetUserPassword(txtEmailAddress.Text, newPassword, "<IP>" & HttpContext.Current.Request.UserHostAddress() & "</IP>") = DataLayerResult.Success Then
                lblFormTitle.Font.Bold = False
                lblFormTitle.Text = "A new password is sent to your email account.Please change this temp password  asap. It expires in 7 days "
                backURL.Visible = True
                lblFormTitle.ForeColor = Drawing.Color.Black
            Else
                lblFormTitle.Font.Bold = False
                lblFormTitle.ForeColor = Drawing.Color.Red
                lblFormTitle.Text = "Failed to reset password."

            End If

        End Sub
    End Class
End Namespace