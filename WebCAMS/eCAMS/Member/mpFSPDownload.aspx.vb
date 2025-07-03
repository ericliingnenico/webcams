#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 3/12/13 11:28 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPDownload.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On

Namespace eCAMS

Public Class mpFSPDownload
    Inherits FSPDownloadBasePage

    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.PDA
    End Sub

    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        Call m_DataLayer.VerifyLogin()
        ''login as CLient, quit
        If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
            Response.Redirect("Member.aspx")
            Exit Sub
        End If

        If Not Page.IsPostBack Then
            Call GetContext()
            Call Process()
        End If

    End Sub


End Class
End Namespace