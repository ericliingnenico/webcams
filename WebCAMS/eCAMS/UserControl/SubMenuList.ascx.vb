#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:51 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/UserControl/SubMenuList.ascx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On
Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Partial Class UserControl_SubMenuList
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' If SiteMap.CurrentNode is not Nothing, 
        ' bind CurrentNode's ChildNodes to the GridView
        If SiteMap.Providers(CType(Current.Session("UserInfo"), UserInformation).MenuSet).CurrentNode IsNot Nothing Then
            rpSubMenuList.DataSource = SiteMap.Providers(CType(Current.Session("UserInfo"), UserInformation).MenuSet).CurrentNode.ChildNodes
            rpSubMenuList.DataBind()
        End If
    End Sub
End Class
