'<!--$$Revision: 5 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/07/11 14:24 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpLogin.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: mpLogin 
'
' Description: 
'   FSP login page for PDA
'----------------------------------------------------------------

Partial Class mpLogin
    Inherits MemberPageBase

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

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        If Not HttpContext.Current.Request.Cookies("pcams.dl1") is Nothing then  ''check pcams.login cookie
                Dim myEncrypt As New Encryption64()
                Call Login( myEncrypt.Decrypt(HttpContext.Current.Request.Cookies("pcams.dl1")("p1").ToString,m_DataLayer.Encrypt_Key_Used), myEncrypt.Decrypt(HttpContext.Current.Request.Cookies("pcams.dl1")("p2").ToString,m_DataLayer.Encrypt_Key_Used),False,"",4,"mpFSPMain.aspx",True,lblErrorMsg)
        End If
    End Sub

    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        ''hide the menu on the login page
        CType(Page.Master, mPhone).IsShowMenu = False

        'Put user code to initialize the page here
        If Not IsPostBack Then
            Call GetContext()
            Call SetDE()
        End If
    End Sub

    Private Sub btnSingIn_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSingIn.ServerClick
            Call Login(Me.UserName.Text, Me.Password.Text,Me.chkRememberPassword.Checked,"",4,"mpFSPMain.aspx",True,lblErrorMsg)
    End Sub


End Class

End Namespace
