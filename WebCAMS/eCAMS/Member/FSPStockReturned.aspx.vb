#Region "vss"
'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 10/08/11 15:38 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPStockReturned.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Imports System.Drawing

Namespace eCAMS
Partial Class FSPStockReturned
    Inherits FSPStockReturnedBasePage
        Protected WithEvents tableSc As System.Web.UI.HtmlControls.HtmlTable
        Private Const m_ECN = "[ENTER CONNOTE]"

#Region " Web Form Designer Generated Code "

        'This call is required by the Web Form Designer.
        <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub


    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region


#Region "Function"
    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.DeskTop
    End Sub
    Protected Overrides Sub HideAllPanels()
        panelEdit.Visible = False
        panelScan.Visible = False
        panelAcknowledge.Visible = False
    End Sub

        Protected Overrides Sub ShowEditPanel()
            MyBase.ShowEditPanel

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
                txtBatchID.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("BatchID"))
                Call ScrollToCboValue(cboFromLocation, Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("FromLocation")))
                cboFromLocation.Enabled = False
                Call ScrollToCboValue(cboToLocation, Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocation")))
                cboToLocation.Enabled = False
                txtDateReturned.Text = Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("DateReturned")).ToString("dd/MM/yy")
                txtReferenceNo.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ReferenceNo"))
                txtNote.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Note"))
            Else
                txtBatchID.Text = ""
                txtDateReturned.Text = Date.Now.ToString("dd/MM/yy")
            End If

            txtBatchID.Text = m_BatchID.ToString

            If m_currentBatchDataRow IsNot Nothing Then
                ''show info
                lblListInfo1.Text = String.Format(lblListInfo1.Text,
                                m_currentBatchDataRow("FromLocation"),
                                m_currentBatchDataRow("ToLocation"),
                                Convert.ToDateTime(m_currentBatchDataRow("DateReturned")).ToString("dd/MM/yyyy"))

                lblListInfo4.Text = String.Format(lblListInfo4.Text,
                                    m_BatchID)

                ''high light return to my swap pool
                If Convert.ToInt32(m_currentBatchDataRow("ToLocation")) = 300 Then
                    lblFormTitle.Text = "Stock returns to Ingenico"
                Else
                    lblFormTitle.Text = "Stock returns to my swap pool"
                    panelScan.BackColor = Color.FromArgb(255, 244, 194)
                End If

            End If

            ''display scan log
            If m_currentScanLogDataTable IsNot Nothing Then
                grdDevice.DataSource = m_currentScanLogDataTable
                grdDevice.DataBind()
            End If

            ''clear txtSerial
            txtSerial.Text = ""

            Panel1.Enabled = (m_BatchID > 0)
            txtReferenceNo.Enabled = (m_BatchID > 0)
            txtNote.Enabled = (m_BatchID > 0)
            txtBoxes.Enabled = (m_BatchID > 0)
            btnClose.Disabled = (m_BatchID = 0)
            panelExcelBox.Enabled = (m_BatchID > 0)

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
        Private Sub btnSave_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.ServerClick
            If txtReferenceNo.Text = "" Then
                txtReferenceNo.Text = m_ECN
            End If
            Call SaveBatch(Convert.ToInt32(cboFromLocation.SelectedValue),
                                                Convert.ToInt32(cboToLocation.SelectedValue), Convert.ToDateTime(txtDateReturned.Text),
                                                txtReferenceNo.Text, txtNote.Text, txtBatchID.Text)
        End Sub
        Private Sub txtSerial_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSerial.TextChanged
            Call ScanDevice(txtSerial, txtBatchID.Text)
        End Sub

        Protected Sub btnSaveSerial_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveSerial.Click
            Call ScanDevice(txtSerial, txtBatchID.Text)
        End Sub

        Private Sub btnClose_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.ServerClick
            m_Service = "close"
            m_box = txtBoxes.Text
            m_BatchID = Convert.ToInt32(txtBatchID.Text)
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
