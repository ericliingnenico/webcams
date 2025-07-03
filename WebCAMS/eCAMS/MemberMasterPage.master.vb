#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/MemberMasterPage.master.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Partial Class MemberMasterPage
    Inherits System.Web.UI.MasterPage


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            PageHeader1.IsTestSite = Not CType(Current.Session("IsLiveDB"), Boolean)
            Context.Request.Browser.Adapters.Clear()  ' vb.net ASP Menu on the other browser
        End If

        Me.mySiteMapDataSource.SiteMapProvider = CType(Current.Session("UserInfo"), UserInformation).MenuSet
        Me.mySiteMapPath.SiteMapProvider = CType(Current.Session("UserInfo"), UserInformation).MenuSet

    End Sub



    Protected Sub Menu1_MenuItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.MenuEventArgs) Handles Menu1.MenuItemDataBound

        ''verify Custom attribute "hide" and hide the menu item
        If Not CType(e.Item.DataItem, SiteMapNode)("hide") Is Nothing AndAlso CType(e.Item.DataItem, SiteMapNode)("hide").ToLower = "yes" Then
            e.Item.Parent.ChildItems.Remove(e.Item)
        End If

    End Sub
End Class

