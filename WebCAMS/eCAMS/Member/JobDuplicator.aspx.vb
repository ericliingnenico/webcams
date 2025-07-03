#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 18/10/2017 11:07 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/JobDuplicator.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing
Namespace eCAMS

    Partial Class JobDuplicator
        Inherits MemberPageBase

        Private lblMsg As New Label

        Protected Overrides Sub GetContext()
            With Request
                ''m_jobID = Convert.ToInt64(.Item("JID"))
            End With
        End Sub

        Protected Overrides Sub Process()
            SetDE()
        End Sub
        Protected Overrides Sub AddClientScript()
            btnDuplicate.Attributes.Add("onclick", "return ConfirmWithValidation('Are you sure to submit this request?');")
        End Sub
        Private Sub SetDE()
            Me.PageTitle = "Duplicate Job"

            ''Set client Combox
            Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))

			Call SetFocusExt(txtTerminalID)

		End Sub
        Private Sub DisplayFullPage()
            Call HidePanels(1)  ''hide top level
            panelFullPage.Visible = True

            PositionMsgLabel(placeholderMsg, lblMsg)

        End Sub

        Private Sub DisplayAcknowledgePage(ByVal pJobID As String)
			''Call HidePanels(1)  ''hide top level
			'panelAcknowledge.Visible = True
			'lblAcknowledge.Text = "Job (JobID: <B>" & pJobID.ToString & "</B>) has been logged successfully. Click " + GetJobViewerHREF(pJobID) + " to view details."

			lblMsg.BackColor = Color.White
			lblMsg.ForeColor = Color.Black

			lblMsg.Text = "Job (JobID: <B>" & pJobID.ToString & "</B>) has been logged successfully. Click " + GetJobViewerHREF(pJobID) + " to view details."


			txtNewTerminalID.Text = ""
			txtNewCAIC.Text = ""

			Call SetFocusExt(txtNewTerminalID)
		End Sub

        Private Sub HidePanels(ByVal pLevel As Int16)
            Select Case pLevel
                Case 1  ''top level
                    panelFullPage.Visible = False
                    panelAcknowledge.Visible = False
				Case 2  ''second level
					panelAcknowledge.Visible = False
			End Select
        End Sub

        Protected Sub btnDuplicate_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnDuplicate.ServerClick
            Dim jobID As Integer
            Dim ret As DataLayerResult
            PositionMsgLabel(placeholderMsg, lblMsg) ''reposition the error message label

            Try
                ret = m_DataLayer.DuplicateJob(jobID, _
                                cboClientID.SelectedValue, _
                                txtTerminalID.Text, _
                                txtNewTerminalID.Text, _
                                txtNewCAIC.Text)

				If ret = DataLayerResult.Success Then
					DisplayAcknowledgePage(jobID.ToString)
				Else
					DisplayErrorMessage(lblMsg, "Failed to save this job. Please try again.")
				End If
			Catch ex As Exception
				DisplayErrorMessage(lblMsg, ex.Message)
				lblMsg.BackColor = Color.Yellow
				lblMsg.ForeColor = Color.Red
			End Try
        End Sub

    End Class
End Namespace