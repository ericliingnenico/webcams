#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/EEMemberMasterPage.master.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Partial Class EEMemberMasterPage
    Inherits System.Web.UI.MasterPage
        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If CType(Current.Session("IsLogin"), Boolean) Then
                EEPageHeader1.UserLoginInfo = "Login as <b>" & _
                                    Server.HtmlEncode(CType(Current.Session("UserInfo"), UserInformation).UserName) & "</b> at " & _
                                    CType(CType(Current.Session("UserInfo"), UserInformation).LoginDateTime, DateTime).ToString("d/M/yyyy H:mm:ss")
            Else
                EEPageHeader1.UserLoginInfo = ""
            End If
            Context.Request.Browser.Adapters.Clear()  ' vb.net ASP Menu on the other browser
        End If

        Me.mySiteMapDataSource.SiteMapProvider = CType(Current.Session("UserInfo"), UserInformation).MenuSet
        Me.mySiteMapPath.SiteMapProvider = CType(Current.Session("UserInfo"), UserInformation).MenuSet

    End Sub

    Protected Sub Menu1_MenuItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.MenuEventArgs) Handles Menu1.MenuItemDataBound
        ''verify Custom attribute "hide" and hide the menu item
        If Not CType(e.Item.DataItem, SiteMapNode)("hide") Is Nothing AndAlso CType(e.Item.DataItem, SiteMapNode)("hide") = "yes" Then
            e.Item.Parent.ChildItems.Remove(e.Item)
        End If
    End Sub
End Class

