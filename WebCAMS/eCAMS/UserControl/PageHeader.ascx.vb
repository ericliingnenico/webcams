#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:51 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/UserControl/PageHeader.ascx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On
Partial Class UserControl_PageHeader
    Inherits System.Web.UI.UserControl
    Private mIsTestSite As Boolean
    Public Property IsTestSite() As Boolean
        Get
            Return mIsTestSite
        End Get
        Set(ByVal value As Boolean)
            mIsTestSite = value
        End Set
    End Property

    'Public Sub SetSiteMapProvider(ByVal pMapProvider As String)
    '    mySiteMapPath.SiteMapProvider = pMapProvider
    'End Sub

End Class
