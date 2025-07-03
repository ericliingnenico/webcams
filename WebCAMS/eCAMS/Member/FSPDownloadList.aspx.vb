'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 1/11/13 11:40 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPDownloadList.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On

Namespace eCAMS
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: FSPDownloadList
'
' Description: 
'   FSP Software Download List
'----------------------------------------------------------------
Partial Class FSPDownloadList
    Inherits FSPDownloadListBasePage

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
    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.DeskTop
    End Sub
    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid(grdJob,nothing)
    End Sub
    Private Sub SetDE()
        Me.PageTitle = "Download"
        Me.lblListInfo.Text = "Available Downloads"
    End Sub
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid(grdJob, Nothing)
    End Sub
    Protected Sub grdJob_SortCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridSortCommandEventArgs) Handles grdJob.SortCommand
        Call m_DataLayer.VerifyLogin()
        'System.Diagnostics.Debug.WriteLine(e.CommandSource)
        ''toggle sort order
        m_DataLayer.SelectedSortOrder = Convert.ToString(IIf(m_DataLayer.SelectedSortOrder = e.SortExpression, e.SortExpression & " DESC", e.SortExpression))
        Call BindGrid(grdJob, Nothing)
    End Sub
End Class

End Namespace
