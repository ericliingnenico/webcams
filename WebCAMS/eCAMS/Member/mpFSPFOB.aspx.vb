#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 29/09/11 9:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPFOB.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Namespace eCAMS
Public Class mpFSPFOB
    Inherits FSPFOBBasePage

    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.PDA
    End Sub
    Protected Overrides Sub Process()
        MyBase.Process()
        DisplayScanPage(placeholderErrorMsg)
    End Sub
#Region "Event"
    Private Sub btnSubmit_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSubmit.Click
        Call SaveFOB (txtSerial.Text, txtNote.Text,"../Member/mpFSPMain.aspx",placeholderErrorMsg)
    End Sub
#End Region

End Class
End Namespace