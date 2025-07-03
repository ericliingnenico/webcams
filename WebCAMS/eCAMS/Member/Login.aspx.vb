'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 11/07/11 9:28 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/Login.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: Login
'
' Description: 
'   Login Page
'----------------------------------------------------------------

Partial Class Login
    Inherits PageBase

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
    Protected Overrides Sub LoginBroker()
        MyBase.LoginBroker()

        ''otherwise, redirect to KYC login page
        Response.Redirect("../Member/LoginKYC.aspx")
    End Sub
    '*************** Functions ***************


    '*************** Events Handlers ***************
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Call LoginBroker()
        End If

        ''Set EE MasterPage , default is KYC Master Page
            m_DataLayer.MyMasterPage = "KYC"

        'Put user code to initialize the page here
        Call SetFocus(UserName)
    End Sub


    Private Sub btnSingIn_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSingIn.ServerClick

        Call Login(UserName.Text, Password.Value,False,"EE",1,"Member.aspx",False,lblErrorMsg)

    End Sub

End Class

End Namespace
