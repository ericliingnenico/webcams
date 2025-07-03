'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:14 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/BulletinViewLog.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On

Namespace eCAMS
    Partial Class BulletinViewLog
        Inherits BulletinViewLogBasePage
        Protected Overrides Sub Process()
            Call BindGrid(grdLog, Nothing)
        End Sub

        Protected Overrides sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.DeskTop
        End Sub


        Protected Sub grdLog_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
            Call m_DataLayer.VerifyLogin()
            grdLog.CurrentPageIndex = e.NewPageIndex
            Call MyBase.BindGrid(grdLog, Nothing)
        End Sub

        Protected Sub grdLog_SortCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridSortCommandEventArgs) Handles grdLog.SortCommand
            Call m_DataLayer.VerifyLogin()
            ''toggle sort order
            m_DataLayer.SelectedSortOrder = Convert.ToString(IIf(m_DataLayer.SelectedSortOrder = e.SortExpression, e.SortExpression & " DESC", e.SortExpression))
            Call MyBase.BindGrid(grdLog, Nothing)
        End Sub
    End Class
End Namespace
