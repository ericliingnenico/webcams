
Partial Class UserControl_EEPageHeader
    Inherits System.Web.UI.UserControl
    Public Property UserLoginInfo() As String
        Get
            Return lblLoginInfo.Text
        End Get
        Set(ByVal value As String)
            lblLoginInfo.Text = value
        End Set
    End Property

    'Public Sub SetSiteMapProvider(ByVal pMapProvider As String)
    '    mySiteMapPath.SiteMapProvider = pMapProvider
    'End Sub
End Class
