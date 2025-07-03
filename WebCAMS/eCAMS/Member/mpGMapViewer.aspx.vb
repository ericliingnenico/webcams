#Region "vss"
'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 10/08/11 15:38 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpGMapViewer.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing
Imports System.IO

Namespace eCAMS

Public Class mpGMapViewer
    Inherits GMapBase
        Protected Overrides Sub GetContext()
            MyBase.GetContext()
            m_jobViewer = "mpFSPJob.aspx"
        End Sub

        Protected Overrides Sub DisplayPage(showMap As Boolean)
	        MyBase.DisplayPage(showMap)

	        lblMsg.Visible = Not showMap
	        lblMsg.Text = m_exceptionMsg
        End Sub


End Class
End Namespace