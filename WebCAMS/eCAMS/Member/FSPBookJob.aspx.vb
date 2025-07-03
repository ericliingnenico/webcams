#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 18/01/16 15:29 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPBookJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS

    Public Class FSPBookJob
        Inherits FSPBookJobBasePage

#Region "Function"
        Protected Overrides Sub AddClientScript()
            ''tie these textboxes to corresponding buttons
            TieButton(txtBookDate, btnBook)
            TieButton(txtBookTime, btnBook)


            btnBook.Attributes.Add("onclick", "SetJobBookValidator();")

            btnEscalate.Attributes.Add("onclick", "SetEscalateValidator();")

        End Sub

        Protected Overrides Sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.DeskTop
        End Sub
        Protected Overrides Sub Process()
            MyBase.Process()
            DisplayBookingPage(txtJobID, txtJobIDList, placeholderErrorMsg, cboBookTo, txtJobDetails, grdMultipleJob, cboEscalateReason)
        End Sub
#End Region

#Region "Event"
        Private Sub btnBook_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnBook.ServerClick
            Call BookJob(txtJobIDList.Value, Convert.ToInt16(cboBookTo.SelectedValue), Convert.ToDateTime(txtBookDate.Text & " " & txtBookTime.Text.Insert(2, ":") & ":00"), txtNote.Text, "../Member/FSPJobList.aspx", placeholderErrorMsg)
        End Sub
        Private Sub btnEscalate_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnEscalate.ServerClick
            Call EscalateJob(txtJobIDList.Value, Convert.ToInt16(cboEscalateReason.SelectedValue), txtEscalateNote.Text, "../Member/FSPJobList.aspx", placeholderErrorMsg)
        End Sub

#End Region

    End Class
End Namespace