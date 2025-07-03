#Region "vss"
'<!--$$Revision: 3 $-->
'<!--$$Author: Minh $-->
'<!--$$Date: 10/08/11 15:38 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPStockFaulty.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Imports System.Drawing

Namespace eCAMS
Partial Class FSPStockFaulty
    Inherits FSPStockReturnedBasePage
    Protected WithEvents tableSc As System.Web.UI.HtmlControls.HtmlTable

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
         MyBase.ShowEditPanel()

      panelEdit.Visible = True

      ''show current batch if there is an open one, otherwise, show new batch page
      If m_currentBatchDataRow IsNot Nothing Then
        ''there is an open batch, show it
        txtBatchID.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("BatchID"))
        txtNote.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Note"))
      Else
        txtBatchID.Text = ""
      End If

      txtBatchID.Text = m_BatchID.ToString

      txtCaseID.Text = m_CaseID.ToString

      ''display scan log
      If m_currentScanLogDataTable IsNot Nothing Then
        grdDevice.DataSource = m_currentScanLogDataTable
        grdDevice.DataBind()
      End If

      ''clear txtSerial
      'txtSerial.Text = ""

      Panel1.Enabled = (m_BatchID > 0)
      txtNote.Enabled = (m_BatchID > 0)
      btnClose.Disabled = (m_BatchID = 0)

      If (m_BatchID > 0) Then
        Call SetFocusExt(txtSerial)
      End If

      If m_CaseID = 2 Then
        m_DataLayer.PopupMessage = "<br><br>Error:Device not at expected location<br><br><br>"
        DisplayMessageBox(Me)
        Call SetFocusExt(txtSerial)
        txtCaseID.Text = ""
      ElseIf m_CaseID = -1 And m_SaveSerial Then
        txtLastSerial.Text = txtSerial.Text
        m_DataLayer.PopupMessage = "<br><br>Device not at expected condition. Serial will not be updated. Please escalate to FSP Management. Click on Close to proceed with batch<br><br><br>"
        DisplayMessageBox(Me)
        m_CaseID = 3
        Call ScanDevice(txtSerial, txtBatchID.Text, True)
        m_CaseID = 0
        txtCaseID.Text = ""
        txtSerial.Text = ""
        txtLastSerial.Text = ""
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
      Call SaveBatch(0, 0, Convert.ToDateTime(Date.Now.ToString("dd/MM/yy")), "", txtNote.Text, txtBatchID.Text, True)
    End Sub
    Private Sub txtSerial_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSerial.TextChanged
      m_SaveSerial = False
      If txtSerial.Text.Trim() = String.Empty Then
        m_CaseID = 0
        txtCaseID.Text = ""
      End If

      Call ValidateStockFaulty(txtBatchID.Text, txtSerial, True)

      If m_CaseID > 0 And m_CaseID <> 2 Then
        Call ScanDevice(txtSerial, txtBatchID.Text, True)
        m_CaseID = 0
        txtCaseID.Text = ""
        txtSerial.Text = ""
        txtLastSerial.Text = ""
      End If

    End Sub

    Protected Sub btnSaveSerial_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveSerial.Click
      m_SaveSerial = True
      If txtSerial.Text.Trim() = String.Empty Then
        m_CaseID = 0
        txtCaseID.Text = ""
      End If

      Call ValidateStockFaulty(txtBatchID.Text, txtSerial, True)

      If m_CaseID > 0 And m_CaseID <> 2 Then
        Call ScanDevice(txtSerial, txtBatchID.Text, True)
        m_CaseID = 0
        txtCaseID.Text = ""
        txtSerial.Text = ""
        txtLastSerial.Text = ""
      End If


    End Sub

    Private Sub btnClose_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.ServerClick
      m_Service = "close"
      m_box = "1"
      m_ReferenceNo = ""
      m_BatchID = Convert.ToInt32(txtBatchID.Text)
      m_Notes = txtNote.Text
      If m_BatchID > 0 Then
        If Len(m_Notes.Trim()) > 65 Then
          m_DataLayer.PopupMessage = "<br><br>Please enter a valid note length.<br><br><br>"
          DisplayMessageBox(Me)
          Call SetFocusExt(txtNote)
        Else
          Call CloseBatch(True)
        End If
      End If
    End Sub
#End Region


  End Class

End Namespace
