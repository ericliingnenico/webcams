#Region "vss"
'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 11/07/11 9:28 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/mPhone.master.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Partial Class mPhone
    Inherits System.Web.UI.MasterPage
    Public Property IsShowMenu As Boolean = True
    ReadOnly Property GMapAPIKey As String
        Get
            Return ConfigurationManager.AppSettings("GMapAPIKey").ToString()
        End Get
    End Property

    ReadOnly Property  IsiPhone As boolean
        Get
            
            If Current.Session("PhoneDevice") is Nothing then Current.Session("PhoneDevice")=Request.UserAgent
            Return (CType(Current.Session("PhoneDevice"),String).Contains("WebKit") or CType(Current.Session("PhoneDevice"),String).Contains("Android"))
        End Get
    End Property

End Class

