'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/Logout.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.IO

Namespace eCAMS

   '----------------------------------------------------------------
   ' Namespace: eCAMS
   ' Class: Logout
   '
   ' Description: 
   '   Logout page
   '----------------------------------------------------------------

   Partial Class PrivacyStatement
      Inherits PageBase

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

      '*************** Functions ***************

      '*************** Events Handlers ***************
      Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
         MyBase.Page_Load(sender, e)

         If Not Page.IsPostBack Then
                'Dim strFileName = "AU-GM-SUP-017 Privacy Statement.pdf"
                'Dim strDownloadURL = "/FSPDownload/FSPManuals/AU-GM-SUP-017 Privacy Statement.pdf"
                'Dim path As String = Server.MapPath("/eCAMS" & strDownloadURL)

                'Dim fs As FileStream

                '' Open the stream and read it back.
                'fs = File.OpenRead(path)

                'Dim b() As Byte
                'ReDim b(Convert.ToInt32(fs.Length) - 1) ''the array index starts from ZERO

                'fs.Read(b, 0, b.Length)

                'fs.Close()

                'Response.ContentType = "application/x-octetstream"
                'Response.AddHeader("content-disposition", "attachment; filename=""" & strFileName & """")

                'Response.BinaryWrite(b)
                'Response.End()

                Dim privacyLink As String = m_DataLayer.GetAppAttribute("PrivacyStatementURL")
                ' Redirect the user to a new URL
                Response.Redirect(privacyLink)
            End If
        End Sub

   End Class

End Namespace
