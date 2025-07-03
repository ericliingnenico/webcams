'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/Member.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.Web.Security
Imports eCAMS.AuthWS

Namespace eCAMS

    '----------------------------------------------------------------
    ' Namespace: eCAMS
    ' Class: Member
    '
    ' Description: 
    '   Member home page
    '----------------------------------------------------------------

    Partial Class Member
        Inherits MemberPageBase

#Region " Web Form Designer Generated Code "

        'This call is required by the Web Form Designer.
        <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

        End Sub

        Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
            'CODEGEN: This method call is required by the Web Form Designer
            'Do not modify it using the code editor.
            InitializeComponent()
        End Sub

#End Region



        Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
            MyBase.Page_Load(sender, e)
            If Not Page.IsPostBack Then
                If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then

                    If UserPasswordAlert1.AlertUser Then
                        'Dim myMenu As Menu
                        'myMenu = CType(Me.Master.FindControl("Menu1"), Menu)

                        'myMenu.Enabled = False
                    Else

                        Dim menuSet As String = CStr(CType(Session("UserInfo"), UserInformation).MenuSet)
                        If (menuSet = "Menu_Client_TYR_Merchant_Read") Then
                            Response.Redirect("SectionPage.aspx?q=1")
                        Else
                            Call Server.Transfer("QuickFind.aspx")
                        End If
                    End If

                Else
                    Call Server.Transfer("FSPMain.aspx")
                End If
            End If
        End Sub
    End Class

End Namespace
