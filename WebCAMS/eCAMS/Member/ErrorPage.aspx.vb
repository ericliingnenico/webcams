#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/ErrorPage.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On


Namespace eCAMS

Partial Class ErrorPage
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
    Private m_errID As String

#Region "Function"

    Protected Overrides Sub GetContext()
        With Request
            m_errID = .Item("EID")
        End With
    End Sub

    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    Private Sub SetDE()
        Me.PageTitle = "Error Page"

        BackURL.Text = "Back"
        BackURL.NavigateUrl = "../Member/Member.aspx"

        Select Case m_errID
            Case "1"
                lblErrorInfo.Text = "You do not have permission to access this page."
        End Select

    End Sub

#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
    End Sub


#End Region
End Class

End Namespace
