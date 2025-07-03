#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 29/09/11 10:09 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPFOBBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
Public Class FSPFOBBasePage
             Inherits MemberPageBase

    ''Local Variable
    Protected m_JobID As int64
    Protected lblMsg As New Label
    Protected Sub DisplayScanPage(pPlaceholderErrorMsg As PlaceHolder)
        PositionMsgLabel(pPlaceholderErrorMsg, lblMsg) 
    End Sub
    Protected Sub SaveFOB(ByVal pSerial As string, byval pNote As string, ByVal pNextPage As String,pPlaceholderErrorMsg As PlaceHolder)
        Dim ret As DataLayerResult
        PositionMsgLabel(pPlaceholderErrorMsg, lblMsg) 
        Try
            ret = m_DataLayer.AddFaultyOutOfBoxDevice(pSerial,pNote)
            If ret = DataLayerResult.Success Then
                Response.Redirect(pNextPage)
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
    End Sub

End Class
End Namespace

