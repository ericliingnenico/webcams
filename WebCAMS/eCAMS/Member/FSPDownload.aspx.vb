'<!--$$Revision: 11 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 1/11/13 11:40 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPDownload.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: FSPDownload
'
' Description: 
'   FSP Download page
'----------------------------------------------------------------

Imports System.Web

Namespace eCAMS

    Partial Class FSPDownload
        Inherits FSPDownloadBasePage
        ''inheritae pagebase, no UI inherit

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
        Protected Overrides Sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.DeskTop
        End Sub

        Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
            Call m_DataLayer.VerifyLogin()
            ''login as CLient, quit
            If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
                Response.Redirect("Member.aspx")
                Exit Sub
            End If

            If Not Page.IsPostBack Then
                Call GetContext()
                Call Process()
            End If

        End Sub
#Region "reccycle"
        'Private Sub Download()
        '    If ("123" & Request.Browser.Platform.ToUpper()).IndexOf("WINCE") > 0 Then
        '        ''it is from pocketPC
        '        Call DownloadFromPDA()
        '    Else
        '        Call DownloadFromDesktop()
        '    End If
        'End Sub
        'Private Sub DownloadFromPDA()
        '    ''"content-disposition", "attachment; filename=
        '    '' didn't work on PocketPC IE over HTTPS, but it works with HTTP
        '    '' So we use Redirect which only on PDA folder
        '    Response.Redirect("/eCAMS" & m_downloadURL)
        'End Sub
        'Private Sub DownloadFromDesktop()
        '    ''check if the downloadURL is an external one, if it is, then redirect require
        '    If m_downloadURL.ToLower.StartsWith("http://") or m_downloadURL.ToLower.StartsWith("https://") then
        '        Call StreamVideo
        '    Else
        '        Call DownloadDocument
        '    End If

        'End Sub

        'Sub Redirect(url As String, target As String, windowFeatures As String)
        '	Dim context As HttpContext = HttpContext.Current

        '	If ([String].IsNullOrEmpty(target) OrElse target.Equals("_self", StringComparison.OrdinalIgnoreCase)) AndAlso [String].IsNullOrEmpty(windowFeatures) Then

        '		context.Response.Redirect(url)
        '	Else
        '		Dim page As Page = DirectCast(context.Handler, Page)
        '		If page Is Nothing Then
        '			Throw New InvalidOperationException("Cannot redirect to new window outside Page context.")
        '		End If
        '		url = page.ResolveClientUrl(url)

        '		Dim script As String
        '		If Not [String].IsNullOrEmpty(windowFeatures) Then
        '			script = "window.open(""{0}"", ""{1}"", ""{2}"");"
        '		Else
        '			script = "window.open(""{0}"", ""{1}"");"
        '		End If

        '		script = [String].Format(script, url, target, windowFeatures)
        '		ScriptManager.RegisterStartupScript(page, GetType(Page), "Redirect", script, True)
        '	End If
        'End Sub
#End Region

    End Class

End Namespace
