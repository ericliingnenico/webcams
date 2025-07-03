#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 1/11/13 11:40 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPDownloadSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS

Partial Class FSPDownloadSearch
    Inherits FSPDownloadSearchBasePage

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

    Protected Overrides Sub Process()
        Call SetDE(cboDownloadCategory)
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub btnGo_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnGo.Click
        Call Search( cboDownloadCategory,"FSPDownloadList.aspx")
    End Sub
End Class

End Namespace
