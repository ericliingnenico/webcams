#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/SectionPage.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On
Partial Class Member_SectionPage
    Inherits eCAMS.MemberPageBase
    Protected Overrides Sub Process()
        MyBase.Process()
        Me.PageTitle = "Section Page"
    End Sub
End Class
