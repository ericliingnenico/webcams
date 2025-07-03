'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/clsSgImage.vb $-->
'<!--$$NoKeywords: $-->
Imports Microsoft.VisualBasic

Imports System
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.Caching
Imports System.Data.SqlClient
Imports System.Data
Imports System.IO
Imports System.ComponentModel
Imports System.Web.Security

<Assembly: TagPrefix("eCAMS", "ecams")> 

Namespace eCAMS
    <ToolboxData("<{0}:SgImage Runat=""server"">")> _
    Public Class SgImage
     Inherits System.Web.UI.WebControls.Image
        <Browsable(True), Category("data"), DefaultValue(""), Description("JobID")> _
        Public Property JobID() As Int64
            Get
                Dim o As Object = ViewState("JobID")
                Return IIf(o Is Nothing, 0, Convert.ToInt64(o))
            End Get
            Set(ByVal Value As Int64)
                 ViewState("JobID") = Value
            End Set
        End Property

        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)
            Dim cacheKey As String = "sg" & JobID.ToString
            If HttpContext.Current.Cache(cacheKey) Is Nothing Then
                ''not in the cache, rebuild it
                Dim oSig As New clsSignature
                If oSig.DecodeSignature(0, JobID) Then
                    ''caching the signature, Caching timeout is 5 minutes. 
                    HttpContext.Current.Cache.Insert(cacheKey, oSig.dsSig.Tables(0).Rows(0)(1), Nothing, DateTime.Now.AddMinutes(5), Cache.NoSlidingExpiration)
                Else
                    ''no, this job has no signature
                    Me.Visible = False
                End If

            End If
            ''yes, there is a signature
            ImageUrl = String.Format("~/__ImageGrabber.axd?p1={0}", EncryptionHelper.Encrypt(JobID.ToString))
        End Sub

    End Class

    Public Class ImageGrabber
     Implements IHttpHandler

        Public Sub ProcessRequest(ByVal context As System.Web.HttpContext) Implements System.Web.IHttpHandler.ProcessRequest
            ' Read the query string parameters
            Dim jobID As Int64 = 0
            Dim p1 As String = context.Request("p1")
            If (Not String.IsNullOrEmpty(p1)) Then
                jobID = Convert.ToInt64(EncryptionHelper.Decrypt(p1))

            End If

            Dim image() As Byte = Nothing

            'get caching signature data
            Dim cacheKey As String = "sg" & jobID.ToString
            image = CType(context.Cache(cacheKey), Byte())

            ' Stream the image bits back to the browser
            If Not image Is Nothing Then
                context.Response.ContentType = "image/jpeg"
                context.Response.OutputStream.Write(image, 0, image.Length)

            End If


        End Sub

        Public ReadOnly Property IsReusable() As Boolean Implements System.Web.IHttpHandler.IsReusable
            Get
                 Return True
            End Get
        End Property


    End Class

    public Class EncryptionHelper
        ' This isn't very elegant, but it's effective. Place data
        ' to be encrypted in a FormsAuthenticationTicket's UserData
        ' property and encrypt the ticket. To decrypt, decrypt the
        ' encrypted ticket and extract the UserData property. Use
        ' FormsAuthentication.Encrypt and FormsAuthentication.Decrypt
        ' as work-arounds for ASP.NET's lack of a public API for
        ' encrypting and decrypting data.

        Public Shared Function Encrypt(ByVal input As String) As String

            Dim ticket As FormsAuthenticationTicket = New FormsAuthenticationTicket(1, String.Empty, DateTime.Now, DateTime.MaxValue, False, input)
            Return FormsAuthentication.Encrypt(ticket)

        End Function
        Public Shared Function Decrypt(ByVal input As String) As String
            Dim ticket As FormsAuthenticationTicket = FormsAuthentication.Decrypt(input)
            Return ticket.UserData
        End Function
    End Class

End Namespace
