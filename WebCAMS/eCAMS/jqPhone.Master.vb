#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 8/08/11 7:52 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/jqPhone.Master.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Imports System.Web.HttpContext
Public Class jqPhone
    Inherits System.Web.UI.MasterPage

    Public Property IsShowMenu As Boolean = True
    Readonly Property  IsiPhone As boolean
        Get
            
            If Current.Session("PhoneDevice") is Nothing then Current.Session("PhoneDevice")=Request.UserAgent
            Return (CType(Current.Session("PhoneDevice"),String).Contains("WebKit") or CType(Current.Session("PhoneDevice"),String).Contains("Android"))
        End Get
    End Property

End Class