#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/pFSP.master.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Partial Class Member_pFSP
    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            If CType(Current.Session("IsLogin"), Boolean) Then
                lblLoginInfo.Text = "Hi <b>" & _
                                    Server.HtmlEncode(CType(Current.Session("UserInfo"), UserInformation).UserName) & "</b>"
                pnlMenu.Visible = True
            Else
                lblLoginInfo.Text = ""
                pnlMenu.Visible = False
            End If

    End Sub
End Class

