#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 3/12/13 11:28 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPDownloadSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Namespace eCAMS
Public Class mpFSPDownloadSearch
    Inherits FSPDownloadSearchBasePage
    Protected Overrides Sub Process()
        Call SetDE(cboDownloadCategory)
    End Sub


    Protected Sub btnSearch_Click(sender As Object, e As EventArgs) Handles btnSearch.Click
        Call Search( cboDownloadCategory,"mpFSPDownloadList.aspx")
    End Sub
End Class
End Namespace