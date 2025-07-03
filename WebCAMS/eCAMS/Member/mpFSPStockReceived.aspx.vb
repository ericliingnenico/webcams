#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 5/08/11 14:05 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPStockReceived.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Namespace eCAMS
Public Class mpFSPStockReceived
    Inherits FSPStockReceivedBasePage
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
        MyBase.ShowEditPanel

        panelEdit.Visible = True

        cboDepot.DataSource = m_DataLayer.FSPChildren
        cboDepot.DataTextField = "FSPDisplayName"
        cboDepot.DataValueField = "FSPID"
        cboDepot.DataBind()

        ''show current batch if there is an open one, otherwise, show new batch page
        If m_currentBatchDataRow IsNot Nothing Then
            ''there is an open batch, show it
            txtBatchID.Value = Convert.ToString(m_currentBatchDataRow("BatchID"))
            Call ScrollToCboValue(cboDepot, Convert.ToString(m_currentBatchDataRow("Depot")))
            txtDateReceived.Text = Convert.ToDateTime(m_currentBatchDataRow("DateReceived")).ToString("dd/MM/yy")
        Else
            txtBatchID.Value = ""
            txtDateReceived.Text = Date.Now.ToString("dd/MM/yy")
        End If

    End Sub
    Protected Overrides Sub ShowScanPanel()
        MyBase.ShowScanPanel()

        panelScan.Visible = True

        txtBatchID.Value = m_BatchID.ToString

        'If m_currentBatchDataRow IsNot Nothing Then
        '    ''show info
        '    lblListInfo1.Text = String.Format(lblListInfo1.Text, _
        '                        m_currentBatchDataRow("Depot"), _
        '                        Convert.ToDateTime(m_currentBatchDataRow("DateReceived")).ToString("dd/MM/yyyy"))
        '    lblListInfo2.Text = String.Format(lblListInfo2.Text, _
        '                        m_BatchID)
        '    lblListInfo4.Text = String.Format(lblListInfo4.Text, _
        '                        m_BatchID)
        '    lblListInfo5.Text = String.Format(lblListInfo5.Text, _
        '                        m_BatchID)

        'End If

        ''display scan log
        If m_currentScanLogDataTable IsNot Nothing Then
            RepeaterDevice.DataSource = m_currentScanLogDataTable
            RepeaterDevice.DataBind()
        End If

        ''clear txtSerial
        txtSerial.Text = ""
        Call SetFocusExt(txtSerial)

    End Sub
    Protected Overrides Sub ShowAcknowledgePanel()
        MyBase.ShowAcknowledgePanel

        panelAcknowledge.Visible = True
    End Sub
#End Region

#Region "Event"
    Private Sub btnSave_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click
        Call SaveBatch(Convert.ToInt32(cboDepot.SelectedValue), Convert.ToDateTime(txtDateReceived.Text),txtBatchID.Value)
    End Sub

    Protected Sub btnSaveSerial_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSaveSerial.Click
        Call ScanDevice(txtSerial,txtBatchID.Value)
    End Sub

    Private Sub txtSerial_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSerial.TextChanged
        Call ScanDevice(txtSerial,txtBatchID.Value)
    End Sub
#End Region


End Class
End Namespace