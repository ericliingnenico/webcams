'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Include/incpPageHeader.ascx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On
Imports System
Imports System.Web
Imports System.Web.HttpContext
Imports eCAMS.AuthWS


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: incPageHeader
'
' Description: 
'   Page header pagelet
'----------------------------------------------------------------
Partial Class incpPageHeader
    Inherits clsModuleBase

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

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        'Put user code to initialize the page here
        If Not Page.IsPostBack Then
            If CType(Current.Session("IsLogin"), Boolean) Then
                lblLoginInfo.Text = "Hi <b>" & _
                                    Server.HtmlEncode(CType(Current.Session("UserInfo"), UserInformation).UserName) & "</b>"
                pnlMenu.Visible = True
            Else
                lblLoginInfo.Text = ""
                pnlMenu.Visible = False
            End If
        End If
    End Sub

End Class

End Namespace
