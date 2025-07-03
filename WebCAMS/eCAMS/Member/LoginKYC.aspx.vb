Option Strict On
'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 11/07/11 9:28 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/LoginKYC.aspx.vb $-->
'<!--$$NoKeywords: $-->

Imports System.Web.Helpers

Namespace eCAMS
    Partial Class Member_LoginKYC
        Inherits PageBase

        '*************** Functions ***************

        '*************** Events Handlers ***************
        Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
            ' Prevent AntiForgery from adding its own X-Frame-Options header
            AntiForgeryConfig.SuppressXFrameOptionsHeader = True
            If Not Page.IsPostBack Then
                Call LoginBroker()
            End If

            ''default is KYC Master Page
            m_DataLayer.MyMasterPage = "KYC"

            complaintsLink.NavigateUrl = ConfigurationManager.AppSettings("ComplaintsUrl").ToString()

            'Put user code to initialize the page here
            Call SetFocus(UserName)
        End Sub


        Private Sub btnSingIn_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSingIn.ServerClick

            Call Login(UserName.Text, Password.Value, False, "KYC", 1, "Bulletin.aspx", False, lblErrorMsg)

        End Sub

    End Class
End Namespace