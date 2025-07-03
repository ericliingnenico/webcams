'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:14 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/BulletinView.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On

Namespace eCAMS
    Partial Class BulletinView
        Inherits BulletinViewBasePage
        Protected Overrides Sub Process()
            Call SetDE(me.placeholderBody)
        End Sub
        Protected Overrides sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.DeskTop
        End Sub

    End Class
End Namespace
