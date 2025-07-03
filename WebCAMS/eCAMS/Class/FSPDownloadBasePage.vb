#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/09/13 17:02 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPDownloadBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Imports System.IO
Imports System.Text
Imports System.Data
Imports System.Web

Namespace eCAMS
Public Class FSPDownloadBasePage
        Inherits PageBase
    Private m_DownloadID As Integer
    Private m_downloadURL As String
    Private m_fileName As String
    Protected videoURL As string
    Protected playerOption As String = "alwaysShowControls: true"
    Protected playerWidth As String = "640"
    Protected playerHeight As String = "360"

    Protected Overrides  Sub GetContext()
        With Request
            m_DownloadID = CType(.QueryString("DLID").Trim, Integer)
        End With
        If Request.Browser.IsMobileDevice or Request.UserAgent.Contains("Android") then ''IsMobileDevice doesn't recongnise Android device
            playerWidth = "320" 
            playerHeight = "280"
        End If
    End Sub
    Protected Overrides Sub Process()
        Call GetDownloadDetails()
        Call Download()
    End Sub
    Private Sub GetDownloadDetails()
        Dim ds As DataSet
        Dim dlResult As DataLayerResult
        dlResult = m_DataLayer.GetDownload(m_DownloadID.ToString, "",m_renderingStyle)
        If dlResult = DataLayerResult.Success Then
            ds = m_DataLayer.dsDownloads

            If ds.Tables(0).Rows.Count > 0 Then
                m_downloadURL = Convert.ToString(ds.Tables(0).Rows(0)("DownloadURL"))
                m_fileName = Path.GetFileName(Convert.ToString(ds.Tables(0).Rows(0)("DownloadURL")))

                ''check if the download item need an audit
                If Convert.ToBoolean(ds.Tables(0).Rows(0)("IsAudit")) Then
                    Dim strActionData As String
                    ''Item Downloaded
                    strActionData = "<ItemID>" & Convert.ToString(ds.Tables(0).Rows(0)("Seq")) & "</ItemID>"
                    ''IP address
                    strActionData = strActionData & "<IP>" & HttpContext.Current.Request.UserHostAddress() & "</IP>"

                    ''Call datalayer to log with ActionTypeID = 5 (FSP download Audit)
                    Call m_DataLayer.PutActionLog(5, strActionData)

                End If
            End If
        End If

    End Sub
    Private Sub Download()
            ''check if the downloadURL is an external one, if it is, then redirect require
            If m_downloadURL.ToLower.StartsWith("http://") Or m_downloadURL.ToLower.StartsWith("https://") Then
                Call StreamVideo()
            Else
                Call DownloadDocument()
            End If
        End Sub
    Private sub DownloadDocument()
        'Response.Redirect("/eCAMS" & m_downloadURL)

        '****The code is working. 
        '****In order to make it work: page html code need to be emptied. Otherwise, the html code will be steamed out via Response object

        '''get download URL
        Dim path As String = Server.MapPath("/eCAMS" & m_downloadURL)

        Dim fs As FileStream

        ' Open the stream and read it back.
        fs = File.OpenRead(path)

        Dim b() As Byte
        ReDim b(Convert.ToInt32(fs.Length) - 1) ''the array index starts from ZERO

        fs.Read(b, 0, b.Length)

        fs.Close()

        Response.ContentType = "application/x-octetstream"
        Response.AddHeader("content-disposition", "attachment; filename=""" & m_fileName & """")

        Response.BinaryWrite(b)
        Response.End()
''''++++++++++++++
'switch ( fileExtension )
'{
'    case "pdf": Response.ContentType = "application/pdf"; break; 
'    case "swf": Response.ContentType = "application/x-shockwave-flash"; break; 

'    case "gif": Response.ContentType = "image/gif"; break; 
'    case "jpeg": Response.ContentType = "image/jpg"; break; 
'    case "jpg": Response.ContentType = "image/jpg"; break; 
'    case "png": Response.ContentType = "image/png"; break; 

'    case "mp4": Response.ContentType = "video/mp4"; break; 
'    case "mpeg": Response.ContentType = "video/mpeg"; break; 
'    case "mov": Response.ContentType = "video/quicktime"; break; 
'    case "wmv":
'    case "avi": Response.ContentType = "video/x-ms-wmv"; break; 

'    //and so on          

'    default: Response.ContentType = "application/octet-stream"; break; 
'}
''''++++++++++++++
    end Sub
        Private Sub StreamVideo()
            videoURL = m_downloadURL
        End Sub


        Private Sub encryptURL(ByRef pURL As String)
        ''sample url: http://www.keycorp.net/video.php?v=^1050^&f=mp4
        Dim urlParts As string() = pURL.Split(CChar("^"))
        pURL = urlParts(0) & HttpUtility.UrlEncode(EncryptionRijndael.EncryptString(Now.ToUniversalTime.ToString("yyyyMMdd")& "|" & urlParts(1))) & urlParts(2)
    End sub

End Class
End Namespace