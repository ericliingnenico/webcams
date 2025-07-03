#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 4/03/14 10:27 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPDelegationList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS

Public Class FSPDelegationList
    Inherits FSPDelegationListBasePage
    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.DeskTop
    End Sub
    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid(txtFromDate.Text,grdJob,nothing)
    End Sub
    Private Sub SetDE()
        Me.PageTitle = "FSPDelegationList"
        Me.lblListInfo.Text = "Current Delegation"
        If txtFromDate.Text = ""
            txtFromDate.Text = Now.ToString("dd/MM/yy")
        End If
    End Sub
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid(txtFromDate.Text,grdJob, Nothing)
    End Sub
    Protected Sub grdJob_SortCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridSortCommandEventArgs) Handles grdJob.SortCommand
        Call m_DataLayer.VerifyLogin()
        'System.Diagnostics.Debug.WriteLine(e.CommandSource)
        ''toggle sort order
        m_DataLayer.SelectedSortOrder = Convert.ToString(IIf(m_DataLayer.SelectedSortOrder = e.SortExpression, e.SortExpression & " DESC", e.SortExpression))
        Call BindGrid(txtFromDate.Text,grdJob, Nothing)
    End Sub

    Protected Sub btnRefresh_Click(sender As Object, e As EventArgs) Handles btnRefresh.Click
        Call BindGrid(txtFromDate.Text,grdJob, Nothing)
    End Sub
End Class
End Namespace