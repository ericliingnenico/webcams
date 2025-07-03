#Region "vss"
'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 10/08/11 15:38 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPReAssign.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Namespace eCAMS
    Public Class mpFSPReAssign
        Inherits FSPReAssignJobBasePage


#Region "Function"
    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.PDA
    End Sub
    Protected Overrides Sub Process()
        MyBase.Process()
        DisplayAssignTo(txtJobID,placeholderErrorMsg,cboAssignedTo,lblJobDetails,RepeaterDevice)
    End Sub

#End Region

#Region "Event"
    Private Sub btnReAssign_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnReAssign.Click
        Call ReAssignJob(Convert.ToInt64(txtJobID.Value), Convert.ToInt32(cboAssignedTo.SelectedValue),"../Member/mpFSPJobList.aspx",placeholderErrorMsg)
    End Sub
#End Region
    End Class
End Namespace