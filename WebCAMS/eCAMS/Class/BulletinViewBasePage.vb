'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/01/16 9:00 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/BulletinViewBasePage.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On

Namespace eCAMS
    Public Class BulletinViewBasePage
        Inherits MemberPageBase
        Dim m_BulletinID As String

        Protected Overrides Sub GetContext()
            With Request
                m_BulletinID = .QueryString("BNO").Trim
            End With

        End Sub
        Protected Sub SetDE(ByRef placeholderBody As PlaceHolder)
            ''set page title
            Me.PageTitle = "Bulletin"
            If m_DataLayer.GetBulletin(m_BulletinID, 3) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                placeholderBody.Controls.Add(New LiteralControl(m_DataLayer.dsTemp.Tables(0).Rows(0)("Body").ToString))
                placeholderBody.Controls.Add(New LiteralControl("<P></P><P>Date Published:" + m_DataLayer.dsTemp.Tables(0).Rows(0)("UpdatedDateTime").ToString + "</P>"))
            End If

        End Sub

    End Class
End Namespace
