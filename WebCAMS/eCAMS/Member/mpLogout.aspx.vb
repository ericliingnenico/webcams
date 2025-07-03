'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/07/11 14:24 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpLogout.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On


Namespace eCAMS
Public Class mpLogout
    Inherits  MemberPageBase

    Protected overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) 
        MyBase.Page_Load(sender, e)
        ''hide the menu on the login page
        CType(Page.Master, mPhone).IsShowMenu = False


        If Not Page.IsPostBack Then
            Call m_DataLayer.ClearLoginSession()
        End If

    End Sub

End Class
end Namespace