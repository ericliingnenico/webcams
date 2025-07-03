#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/02/14 10:57 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPDelegation.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
Public Class FSPDelegation
    Inherits FSPDelegationBasePage

    Protected Overrides Sub Process()
        Call DisplayFSPDelegation(txtLogID,placeholderErrorMsg,cboFSP,txtFromDate,txtFromTime,txtToDate,txtToTime,cboAssignedToFSP,cboReason,txtNotes, btnSave, btnCancel)
    End Sub

    Protected Sub btnSave_Click(sender As Object, e As EventArgs) Handles btnSave.Click
        Call SaveFSPDelegation(cint(txtLogID.Value), _
                               cboFSP.SelectedValue.ToString, _
                               Convert.ToDateTime(txtFromDate.Text & " " & txtFromTime.Text.Insert(2, ":") & ":00"), _
                               Convert.ToDateTime(txtToDate.Text & " " & txtToTime.Text.Insert(2, ":") & ":00"), _
                               cboAssignedToFSP.SelectedValue.ToString, _
                               txtNotes.Text, _
                               cboReason.SelectedValue.ToString, _
                               "2", _
                               "FSPDelegationList.aspx", _
                               placeholderErrorMsg)
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As EventArgs) Handles btnCancel.Click
        Call CancelFSPDelegation(cint(txtLogID.Value), _
                               "FSPDelegationList.aspx", _
                               placeholderErrorMsg)

    End Sub
End Class
End Namespace