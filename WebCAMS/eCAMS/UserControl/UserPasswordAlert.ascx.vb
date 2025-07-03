Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Imports eCAMS.clsTool

Partial Class UserControl_UserPasswordAlert
    Inherits System.Web.UI.UserControl

    Public Function IsPasswordGoingToExpire() As Boolean
        ''Check if password going to expire in 14 days
        Dim bRet As Boolean = False
        If CType(CType(Current.Session("UserInfo"), UserInformation).ExpiryDate, DateTime) < Now.AddDays(14) And _
                CType(CType(Current.Session("UserInfo"), UserInformation).ExpiryDate, DateTime) > Now Then
            bRet = True
        End If
        Return bRet

    End Function
    Public Function IsPasswordExpired() As Boolean
        ''Check if password going to expire in 14 days
        Dim bRet As Boolean = False
        If CType(CType(Current.Session("UserInfo"), UserInformation).ExpiryDate, DateTime) < Now Then
            bRet = True
        End If
        Return bRet
    End Function
    Public Function IsFSP() As Boolean
        ''Check if password going to expire in 14 days
        Dim bRet As Boolean = False
        If CType(CType(Current.Session("UserInfo"), UserInformation).FSPID, Integer) > 0 Then
            bRet = True
        End If
        Return bRet
    End Function
    Public Function IsDefaultPassword() As Boolean
        Dim bRet As Boolean = False
        ''case2: password is still in default issue password
        If Convert.ToBase64String(CType(Current.Session("UserInfo"), UserInformation).Password) = Convert.ToBase64String(EncryptPWD("9433pass")) Then
            bRet = True
        End If
        Return bRet
    End Function

    Public Function AlertUser() As Boolean
        Return (IsPasswordExpired() Or IsPasswordGoingToExpire() Or IsDefaultPassword())
    End Function
    Public Sub HideAlertMessage()
        lblListInfo1.Visible = False
        lblListInfo2.Visible = False
    End Sub
    Public Sub DisableMenuOnExpiredPassword()
        ''disable menu if the password expired, user has to change password
        Dim myMenu As Menu
        myMenu = CType(Me.Parent.Page.Master.FindControl("Menu1"), Menu)

        myMenu.Enabled = Not IsPasswordExpired()
        ''Disable map path
        Dim myMapPath As SiteMapPath
        myMapPath = CType(Me.Parent.Page.Master.FindControl("mySiteMapPath"), SiteMapPath)
        myMapPath.Enabled = Not IsPasswordExpired()

    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        lblListInfo3.Visible = IsFSP()
        If IsPasswordGoingToExpire() Then
            lblListInfo1.Text = String.Format("Your password is going to expire on {0}. Please change your password.", _
                            CType(CType(Current.Session("UserInfo"), UserInformation).ExpiryDate, DateTime).ToString("d/M/yyyy"))
            lblListInfo1.Font.Bold = True
            lblListInfo1.ForeColor = Drawing.Color.Red
        End If
        If IsPasswordExpired() Then
            lblListInfo1.Text = String.Format("Your password expired on {0}. Please change your password.", _
                            CType(CType(Current.Session("UserInfo"), UserInformation).ExpiryDate, DateTime).ToString("d/M/yyyy"))
            lblListInfo1.Font.Bold = True
            lblListInfo1.ForeColor = Drawing.Color.Red

            DisableMenuOnExpiredPassword()
        End If

    End Sub
End Class
