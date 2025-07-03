#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPCoverage.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS

Partial Class FSPCoverage
    Inherits MemberPageBase
#Region "Function"



    Protected Overrides Sub Process()
        SetDE()
    End Sub

    Private Sub SetDE()
        ''Set client Combox
        Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))

        ''state
        m_DataLayer.CacheState()

        cboState.DataSource = m_DataLayer.State.Tables(0)
        cboState.DataTextField = "State"
        cboState.DataValueField = "State"

        cboState.DataBind()

    End Sub
#End Region

#Region "Event"
    Protected Sub btnSearch_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        Dim sURL As String
        sURL = System.Configuration.ConfigurationManager.AppSettings("GeoMap.Server")
        sURL = sURL + "GMapViewer.aspx?svr=SCBF&DC=1"
        sURL = sURL & "&RD=" & txtRadius.Text & "&ID=" & cboClientID.SelectedValue & ",0," & txtSuburb.Text & "," & cboState.SelectedValue
        Call PopupPage(Me.Page, sURL)
    End Sub
#End Region
End Class
End Namespace