#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 10/08/11 15:38 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPStockReturned.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Namespace eCAMS
Public Class mpFSPStockReturned
    Inherits FSPStockReturnedBasePage
        Private Const m_ECN = "[ENTER CONNOTE]"
#Region "Function"

        Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.PDA
    End Sub
    Protected Overrides Sub HideAllPanels()
        panelEdit.Visible = False
        panelScan.Visible = False
        panelAcknowledge.Visible = False
    End Sub

        Protected Overrides Sub ShowEditPanel()
            MyBase.ShowEditPanel()

            panelEdit.Visible = True

            cboFromLocation.DataSource = m_DataLayer.FSPChildren
            cboFromLocation.DataTextField = "FSPDisplayName"
            cboFromLocation.DataValueField = "FSPID"
            cboFromLocation.DataBind()

            ''only display the top level FSP, not children
            cboToLocation.Items.Clear()
            cboToLocation.Items.Add("Ingenico")
            cboToLocation.Items(0).Value = "300"
            cboToLocation.Items.Add("My Swap Pool")
            cboToLocation.Items(1).Value = Convert.ToString(m_DataLayer.FSPChildren.Tables(0).Rows(0)("FSPID"))

            ''show current batch if there is an open one, otherwise, show new batch page
            If m_currentBatchDataRow IsNot Nothing Then
                ''there is an open batch, show it
                txtBatchID.Value = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("BatchID"))
                Call ScrollToCboValue(cboFromLocation, Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("FromLocation")))
                cboFromLocation.Enabled = False
                Call ScrollToCboValue(cboToLocation, Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocation")))
                cboToLocation.Enabled = False
                txtDateReturned.Text = Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("DateReturned")).ToString("dd/MM/yy")
                txtReferenceNo.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ReferenceNo"))
                txtNote.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Note"))
            Else
                txtBatchID.Value = ""
                txtDateReturned.Text = Date.Now.ToString("dd/MM/yy")
            End If

            txtBatchID.Value = m_BatchID.ToString

            ''display scan log
            If m_currentScanLogDataTable IsNot Nothing Then
                RepeaterDevice.DataSource = m_currentScanLogDataTable
                RepeaterDevice.DataBind()
            End If

            'clear txtSerial
            txtSerial.Text = ""

            Panel2.Enabled = (m_BatchID > 0)
            txtReferenceNo.Enabled = (m_BatchID > 0)
            txtNote.Enabled = (m_BatchID > 0)
            txtBoxes.Enabled = (m_BatchID > 0)
            btnClose.Enabled = (m_BatchID > 0)

            If (m_BatchID > 0) Then
                Call SetFocusExt(txtSerial)
            Else
                Call SetFocusExt(txtDateReturned)
            End If


        End Sub
        Protected Overrides Sub ShowScanPanel()
        MyBase.ShowScanPanel()

        panelScan.Visible = True



        End Sub
    Protected Overrides Sub ShowAcknowledgePanel()
        MyBase.ShowAcknowledgePanel

        panelAcknowledge.Visible = True
    End Sub
#End Region

#Region "Event"
        Private Sub btnSave_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click
            If txtReferenceNo.Text = "" Then
                txtReferenceNo.Text = m_ECN
            End If
            Call SaveBatch(Convert.ToInt32(cboFromLocation.SelectedValue),
                                    Convert.ToInt32(cboToLocation.SelectedValue), Convert.ToDateTime(txtDateReturned.Text),
                                    txtReferenceNo.Text, txtNote.Text, txtBatchID.Value)
        End Sub

        Protected Sub btnSaveSerial_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSaveSerial.Click
        Call ScanDevice(txtSerial,txtBatchID.Value)
    End Sub

        Private Sub txtSerial_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSerial.TextChanged
            Call ScanDevice(txtSerial, txtBatchID.Value)
        End Sub

        Private Sub btnClose_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
            m_Service = "close"
            m_box = txtBoxes.Text
            m_BatchID = Convert.ToInt32(txtBatchID.Value)
            m_ReferenceNo = ""
            If m_BatchID > 0 Then
                If Len(txtReferenceNo.Text) > 0 Then
                    If txtReferenceNo.Text = m_ECN Then
                        m_DataLayer.PopupMessage = "<br><br>Please Enter a Valid ConNote No.<br><br><br>"
                        DisplayMessageBox(Me)
                        Call SetFocusExt(txtReferenceNo)
                    Else
                        m_ReferenceNo = txtReferenceNo.Text
                        Call CloseBatch()
                    End If
                End If
            End If
        End Sub
#End Region


    End Class
End Namespace