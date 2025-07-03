Option Strict On
Namespace eCAMS
    Partial Class LoginOTP
        Inherits PageBase

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Call SetFocus(OneTimePassCode)
        End Sub

        Protected Sub btnVerifyOTP_Click(sender As Object, e As EventArgs) Handles btnVerifyOTP.Click

            Dim errorMessage As String = Nothing
            Dim backgroudColour As String = Nothing
            Call OTPLogin(OneTimePassCode.Value, False, "KYC", 10, "Bulletin.aspx", False, errorMessage)

            lblErrorMsg.Text = errorMessage
            If (Not String.IsNullOrEmpty(errorMessage)) Then
                lblErrorMsg.Visible = True
                tdErrorMessageCell.BgColor = "#b9b26a"

                If (errorMessage = TooManyPasscodeReties) Then
                    btnVerifyOTP.Enabled = False
                    btnResendCode.Enabled = False
                Else
                    btnResendCode.Enabled = True
                End If
            Else
                lblErrorMsg.Visible = False
                btnResendCode.Enabled = True
            End If

        End Sub

        Protected Sub btnResendCode_Click(sender As Object, e As EventArgs) Handles btnResendCode.Click

            Dim errorMessage As String = Nothing
            Call CreateAndEmailUsertOTP(errorMessage)
            lblErrorMsg.Text = errorMessage

            If (Not String.IsNullOrEmpty(errorMessage)) Then
                lblErrorMsg.Visible = True
                tdErrorMessageCell.BgColor = "#b9b26a"
            Else
                lblErrorMsg.Visible = False
            End If
            btnResendCode.Enabled = False
        End Sub

        Protected Sub backToLoginURLButton_Click(sender As Object, e As EventArgs) Handles backToLoginURL.DataBinding
            m_DataLayer.Logout()
        End Sub

    End Class

End Namespace