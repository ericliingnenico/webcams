'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:16 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpBulletinViewLog.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On

Namespace eCAMS
    Public Class mpBulletinViewLog
        Inherits BulletinViewLogBasePage

        Protected Overrides Sub Process()
            Call BindGrid(Nothing, Repeater1)
        End Sub

        Protected Overrides sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.PDA
        End Sub

    End Class
End Namespace