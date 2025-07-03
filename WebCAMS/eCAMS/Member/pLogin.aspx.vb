'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 11/07/11 9:28 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/pLogin.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: pLogin 
'
' Description: 
'   FSP login page for PDA
'----------------------------------------------------------------

Partial Class pLogin
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
    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        Me.PageTitle = "Login"
    End Sub

    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        'it is needed to bypass default rendering process
        If Not IsPostBack Then
            Call GetContext()
            Call SetDE()
        End If
    End Sub
    Private Sub btnSingIn_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSingIn.ServerClick
        Call Login(Me.UserName.Text, Me.Password.Text,false,"",4,"pFSPMain.aspx",True,lblErrorMsg)
    End Sub
End Class

End Namespace
