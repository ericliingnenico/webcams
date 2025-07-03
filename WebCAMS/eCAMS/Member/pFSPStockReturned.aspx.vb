#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/pFSPStockReturned.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing

Namespace eCAMS

Partial Class pFSPStockReturned
    Inherits PDAPageBase
        ''form level variable
        Private m_Service As String
        Protected m_BatchID As Integer
        Private m_box As String
        Protected m_ReferenceNo As String
        Protected WithEvents tableSc As System.Web.UI.HtmlControls.HtmlTable
#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub
    Protected WithEvents Label9 As System.Web.UI.WebControls.Label


    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region


#Region "Function"

    Protected Overrides Sub GetContext()
        With Request
            m_Service = .QueryString("sv")
            m_BatchID = Convert.ToInt32(.QueryString("id"))
            m_box = .QueryString("box")
        End With
    End Sub

    Protected Overrides Sub Process()
        ''parse service
        Select Case m_Service
            Case "edit"
                Call ShowEditPanel()
            Case "close"
                Call CloseBatch()
            Case "download"
                Call Download()
            Case Else
          ''verify if there is an open batch
          If m_DataLayer.GetFSPStockReturned(m_BatchID, "O", False) = DataLayerResult.Success Then
            If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
              ''there is an open batch, ask opertor to scan device
              m_BatchID = Convert.ToInt32(m_DataLayer.dsJob.Tables(0).Rows(0)("BatchID"))
              Call ShowScanPanel()
            Else
              ''ask opertor to create new batch
              Call ShowEditPanel()
            End If
          End If


      End Select
    End Sub
    Private Sub ShowEditPanel()
        panelEdit.Visible = True
        panelScan.Visible = False
        panelAcknowledge.Visible = False

        ''Set Info Label
        lblFormTitle.Text = "Stock Return - Edit Batch Details"

        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()
        ''Set FSP Combox

        cboFromLocation.DataSource = m_DataLayer.FSPChildren
        cboFromLocation.DataTextField = "FSPDisplayName"
        cboFromLocation.DataValueField = "FSPID"
        cboFromLocation.DataBind()

        ''only display the top level FSP, not children
        cboToLocation.Items.Clear()
        cboToLocation.Items.Add("Keycorp")
        cboToLocation.Items(0).Value = "300"
        cboToLocation.Items.Add("My Swap Pool")
        cboToLocation.Items(1).Value = Convert.ToString(m_DataLayer.FSPChildren.Tables(0).Rows(0)("FSPID"))

      ''get FSP stock Returned details, 
      ''if no batchid specified, get the batch if there is an open batch for this FSP, otherqise, display new
      If m_DataLayer.GetFSPStockReturned(m_BatchID, "O", False) = DataLayerResult.Success Then
        If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
          ''there is an open batch, populate it
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
      End If
      ''display on the edit panel
    End Sub
    Private Sub ShowScanPanel()
        panelEdit.Visible = False
        panelAcknowledge.Visible = False
        panelScan.Visible = True

        ''Set Info Label
        lblFormTitle.Text = "Stock Return - Scan Device"

        txtBatchID.Text = m_BatchID.ToString

      If m_DataLayer.GetFSPStockReturned(m_BatchID, "", False) = DataLayerResult.Success Then
        If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
          ''show info
          lblListInfo1.Text = String.Format("StockReturned from Depot-{0} to {1} " &
                                    "<br>To change the returned details, click <A HREF='../member/pFSPStockReturned.aspx?sv=edit&id={2}'>Edit</A>" &
                                    "<br>To add device as returned, scan serial in:",
                                    m_DataLayer.dsJob.Tables(0).Rows(0)("FromLocation"),
                                    m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocation"),
                                    m_BatchID)


          ''high light return to my swap pool
          If Convert.ToInt32(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocation")) = 300 Then
            lblFormTitle.Text = "Stock returns to Ingenico"
          Else
            lblFormTitle.Text = "Return to my swap pool"
            panelScan.BackColor = Color.FromArgb(255, 244, 194)
          End If

        End If
      End If


      ''clear txtSerial
      txtSerial.Text = ""
        Call SetFocus(txtSerial)
      ''display scan log
      If m_DataLayer.GetFSPStockReturnedLog(m_BatchID, 1, False) = DataLayerResult.Success Then
        grdDevice.DataSource = m_DataLayer.dsJobs.Tables(0)
        grdDevice.DataBind()
      End If

    End Sub
    Private Sub ScanDevice()
        Dim commonMsg As String = "<br><br>Please check that serial has been keyed or scanned correctly. <br><br>If this device is being returned following a Service Request, the record for Service Request should be closed or updated before proceeding. <br><br><b>This device should not be returned to EE until the cause of this error has been resolved.<b><br>"
        If txtSerial.Text.Trim() = String.Empty Then
            ''No need to process
            Exit Sub
        End If
        m_BatchID = Convert.ToInt32(txtBatchID.Text)
        txtSerial.Attributes.Remove("onfocus")
        Try
        m_DataLayer.AddFSPStockReturnedLog(m_BatchID, txtSerial.Text, False, 0)
      Catch ex As Exception
            'm_DataLayer.PopupMessage = ex.Message + commonMsg
            'Call SetFocus(txtSerial)
            'Call DisplayMessageBox(Me.Page)
            Dim msg As String
            msg = ex.Message.Replace("<br>", "").Replace("<b>", "").Replace("</b>", "").Replace("     ", "")
            ''java script to alert user with exception message
            txtSerial.Attributes.Add("onfocus", "alert('" + msg + "');s")
            Call SetFocus(txtSerial)
        End Try

        Call ShowScanPanel()

    End Sub
    Private Sub CloseBatch()
      If m_DataLayer.CloseFSPStockReturnedAndSendReport(m_BatchID, Convert.ToInt32(m_box), m_ReferenceNo, "", False) = DataLayerResult.Success Then
        ''close local variable
        m_Service = ""
        m_BatchID = 0
        m_ReferenceNo = ""
        Call ShowAcknowledgePanel()
      Else
        Call ShowScanPanel()
        End If

    End Sub
    Private Sub ShowAcknowledgePanel()
        panelEdit.Visible = False
        panelScan.Visible = False
        panelAcknowledge.Visible = True
        lblFormTitle.Text = "The StockReturned has been closed successfully."

    End Sub
    Private Sub Download()
        ''Download request
        Dim fileName As String
        Dim summary As String
      If m_DataLayer.GetFSPStockReturnedLog(m_BatchID, 1, False) = DataLayerResult.Success Then
        ''yes, get the log recordset
        ''set file name with MS Excel extension
        fileName = "StockReturnedBatch" & m_BatchID.ToString & ".xls"


        ''get stock Returned details 
        If m_DataLayer.GetFSPStockReturned(m_BatchID, "", False) = DataLayerResult.Success Then
          summary = String.Format("StockReturned: BatchID: {0}, From: {1}, To: {2}, ReferenceNo: {3}, DateReturned: {4}",
                                    m_BatchID,
                                    m_DataLayer.dsJob.Tables(0).Rows(0)("FromLocation"),
                                    m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocation"),
                                    m_DataLayer.dsJob.Tables(0).Rows(0)("ReferenceNo"),
                                    Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("DateReturned")).ToString("dd/MM/yyyy"))

        End If

        Call ExportToExcel(fileName, summary, m_DataLayer.dsJobs.Tables(0))
      Else
        ''failed to this output request

      End If

    End Sub
    Private Sub SetDE()

    End Sub
#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        ''Put your code here

    End Sub


    Private Sub btnSave_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.ServerClick
        Try
            m_BatchID = Convert.ToInt32(txtBatchID.Text)
        Catch ex As Exception

        End Try

         If m_DataLayer.PutFSPStockReturned(m_BatchID, Convert.ToInt32(cboFromLocation.SelectedValue),
                                            Convert.ToInt32(cboToLocation.SelectedValue), Convert.ToDateTime(txtDateReturned.Text),
                                            txtReferenceNo.Text, txtNote.Text, "O", False) = DataLayerResult.Success Then
            Call ShowScanPanel()
         End If
      End Sub

    Private Sub btnSaveSerial_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSaveSerial.ServerClick
        Call ScanDevice()
    End Sub

    Private Sub txtSerial_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSerial.TextChanged
        Call ScanDevice()
    End Sub

#End Region
End Class

End Namespace

