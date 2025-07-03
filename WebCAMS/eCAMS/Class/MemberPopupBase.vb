#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/08/11 18:02 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/MemberPopupBase.vb $-->
'<!--$$NoKeywords: $-->
#End Region



Option Strict On
Option Explicit On 

Imports System
Imports System.Drawing
Imports System.Web
Imports System.Web.UI
Imports System.ComponentModel
Imports System.Data


Namespace eCAMS


Public Class MemberPopupBase
    Inherits PageBase


    ''Set on Page - Use it in Header
    Public Property PageTitle() As String
        Get
            Return (title)
        End Get
        Set(ByVal Value As String)
                Me.Page.Title = Value
        End Set
    End Property

        'Protected Overrides Sub OnInit(ByVal e As System.EventArgs)
        ''has to be in OnInit, otherwise, viewstate is not saved

        ''Put your member template layout here

        'Me.Controls.AddAt(0, New LiteralControl("<TABLE id='Table1' style='Z-INDEX: 101; LEFT: 8px; WIDTH: 656px; POSITION: absolute; TOP: 8px; HEIGHT: 418px' height='418' cellSpacing='1' cellPadding='1' width='650' border='0'>"))
        'Me.Controls.AddAt(1, New LiteralControl("<TR><TD width='10'></TD><TD>"))
        'Me.Controls.AddAt(2, LoadControl("/eCAMS/Include/incPageHeader.ascx"))
        'Me.Controls.AddAt(3, New LiteralControl("</TD></TR>"))
        'Me.Controls.AddAt(4, New LiteralControl("<TD width='10'></TD><TD vAlign='middle' bgColor='#003399' height='2'></TD></TR>"))
        'Me.Controls.AddAt(5, New LiteralControl("<TR><TD width='10'></TD><TD>"))

        ' ''main page should only contain <form ...
        'MyBase.OnInit(e)

        'Me.Controls.Add(New LiteralControl("</TD></TR>"))
        'Me.Controls.Add(New LiteralControl("<TR><TD width='10'></TD><TD vAlign='middle' bgColor='#003399' height='2'></TD></TR>"))
        'Me.Controls.Add(New LiteralControl("<TR><TD width='10'></TD><TD>&nbsp;</TD></TR>"))
        'Me.Controls.Add(New LiteralControl("<TR><TD width='10'></TD><TD align='center'><INPUT class='formdefield' onclick='javascript: return self.close();' type='button' value='Close'></TR>"))
        'Me.Controls.Add(New LiteralControl("<TR><TD width='10'></TD><TD>&nbsp;</TD></TR>"))
        'Me.Controls.Add(New LiteralControl("<TR><TD width='10'></TD><TD>"))
        'Me.Controls.Add(LoadControl("/eCAMS/Include/incPageFooter.ascx"))
        'Me.Controls.Add(New LiteralControl("</TD></TR></TABLE>"))

        'End Sub



        '----------------------------------------------------------------
        ' Sub New:
        '   Constructor. Initialize private members.
        '----------------------------------------------------------------
        Public Sub New()
            MyBase.New()
        End Sub


        'Protected Overrides Sub Render(ByVal writer As System.Web.UI.HtmlTextWriter)
        ''we have to render outer html elements here, since title property is only accessible after the onload event

        'writer.WriteLine("<HTML>")
        'writer.WriteLine("  <HEAD>")
        'writer.WriteLine("      <title>" + title + "</title>")
        'writer.WriteLine("      <meta content='JavaScript' name='vs_defaultClientScript'>")
        'writer.WriteLine("      <meta content='http://schemas.microsoft.com/intellisense/ie5' name='vs_targetSchema'>")
        'writer.WriteLine("      <LINK href='../Styles/Styles.css' type='text/css' rel='stylesheet'>")
        'writer.WriteLine("  </HEAD>")
        'writer.WriteLine("  <BODY onblur='javascript:self.focus();' >")

        'MyBase.Render(writer)

        'writer.WriteLine("  </BODY>")
        'writer.WriteLine("</HTML>")
        'End Sub

        ''virtual event handler on Page Load
        Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
            MyBase.Page_Load(sender, e)

            If Not m_DataLayer.IsLogin Then
                ''need to reload bradning, so redirect to a common page - PopupMsgBox
                ''and in PopUpMsgBox, we need to override page_load to avoid deadloop
                m_DataLayer.PopupMessage = "Your session has expired. Please close the window and re-login."
                Response.Redirect("../member/PopupMsgBox.aspx")
            Else
                If Not Page.IsPostBack Then
                    Call GetContext()
                    Call Process()
                End If
            End If
        End Sub
        Protected Overridable Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreInit
            ''Skin related, KYC skin is used, commented out in case for future branding
            ' ''change master page here before init
            'If Not m_DataLayer.MyMasterPage Is Nothing Then
            '    ''only set master page if it is specified in session
            '    Select Case m_DataLayer.MyMasterPage
            '        Case "EE"
            '            Me.MasterPageFile = "/ecams/EEMemberPopupMasterPage.master"
            '        ''Case "KYC" ''default master page

            '    End Select
            'End If
        End Sub
    End Class

End Namespace
