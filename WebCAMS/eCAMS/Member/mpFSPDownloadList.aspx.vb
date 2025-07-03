'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 3/12/13 11:28 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPDownloadList.aspx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On

Namespace eCAMS
Public Class mpFSPDownloadList
    Inherits FSPDownloadListBasePage

    Protected Overrides Sub Process()
        Call BindGrid(Nothing, Repeater1)
    End Sub
    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.PDA
    End Sub

End Class
End Namespace