#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/MemberPopupMasterPage.master.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Partial Class MemberPopupMasterPage
    Inherits System.Web.UI.MasterPage

    'Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
    '    If Not Page.IsPostBack Then
    '        If CType(Current.Session("IsLogin"), Boolean) Then
    '            PageHeader1.UserLoginInfo = "Login as <b>" & _
    '                                Server.HtmlEncode(CType(Current.Session("UserInfo"), UserInformation).UserName) & "</b> at " & _
    '                                CType(CType(Current.Session("UserInfo"), UserInformation).LoginDateTime, DateTime).ToString("d/M/yyyy H:mm:ss")
    '        Else
    '            PageHeader1.UserLoginInfo = ""
    '        End If
    '    End If
    'End Sub
End Class

