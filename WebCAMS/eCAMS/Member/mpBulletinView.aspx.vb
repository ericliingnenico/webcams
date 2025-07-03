'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:16 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpBulletinView.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On

Namespace eCAMS
    Public Class mpBulletinView
        Inherits BulletinViewBasePage
        Protected Overrides Sub Process()
            Call SetDE(me.placeholderBody)
        End Sub
        Protected Overrides sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.PDA
        End Sub
    End Class
End Namespace