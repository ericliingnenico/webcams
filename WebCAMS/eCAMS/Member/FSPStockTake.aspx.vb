#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPStockTake.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing
Namespace eCAMS


Partial Class FSPStockTake
    Inherits MemberPageBase

    ''form level variable
    Private m_Service As String
    Protected m_BatchID As Integer

#Region "Function"

    Protected Overrides Sub GetContext()
        With Request
            m_Service = .QueryString("sv")
            m_BatchID = Convert.ToInt32(.QueryString("id"))
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
                If m_DataLayer.GetFSPStockTake(m_BatchID, "O") = DataLayerResult.Success Then
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
        ''lblFormTitle.Text = "Stock Return - Edit Batch Details"


        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()
        ''Set FSP Combox

        cboDepot.DataSource = m_DataLayer.FSPChildren
        cboDepot.DataTextField = "FSPDisplayName"
        cboDepot.DataValueField = "FSPID"
        cboDepot.DataBind()

        ''Display StockTakeDate
        m_DataLayer.GetFSPStockTakeTarget()
        cboStockTakeDate.DataSource = m_DataLayer.dsJob.Tables(0)
        cboStockTakeDate.DataTextField = "StockTakeDate"
        cboStockTakeDate.DataValueField = "StockTakeDate"
        cboStockTakeDate.DataBind()


        ''get FSP stock Take details, 
        ''if no batchid specified, get the batch if there is an open batch for this FSP, otherqise, display new
        If m_DataLayer.GetFSPStockTake(m_BatchID, "O") = DataLayerResult.Success Then
            If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                ''there is an open batch, populate it
                txtBatchID.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("BatchID"))
                Call ScrollToCboValue(cboDepot, Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Depot")))
                cboDepot.Enabled = False
                Call ScrollToCboValue(cboStockTakeDate, Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("StockTakeDate")).ToString("dd/MM/yy"))
                txtNote.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Note"))
            Else
                txtBatchID.Text = ""
            End If
        End If
        ''display on the edit panel
    End Sub
    Private Sub ShowScanPanel()
        panelEdit.Visible = False
        panelAcknowledge.Visible = False
        panelScan.Visible = True

        ''Set Info Label
        ''lblFormTitle.Text = "Stock Return - Scan Device"

        txtBatchID.Text = m_BatchID.ToString

        If m_DataLayer.GetFSPStockTake(m_BatchID, "") = DataLayerResult.Success Then
            If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                ''show info
                lblListInfo4.Text = String.Format(lblListInfo4.Text, _
                                    m_BatchID)

                ''high light return to my swap pool
                lblFormTitle.Text = "StockTake " & Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("StockTakeDate")).ToString("dd/MM/yy")

            End If
        End If


        ''clear txtSerial
        txtSerial.Text = ""
        ''can not use .net2.0 setfocus method, it cause the popup message windows lose focus
        Call SetFocusExt(txtSerial)
        ''display scan log
        If m_DataLayer.GetFSPStockTakeLog(m_BatchID, 1) = DataLayerResult.Success Then
            grdDevice.DataSource = m_DataLayer.dsJobs.Tables(0)
            grdDevice.DataBind()
        End If

    End Sub
    Private Sub ScanDevice()
        Dim commonMsg As String = "<br><br>Please check that serial has been keyed or scanned correctly. <br><br>"
        If txtSerial.Text.Trim() = String.Empty Then
            ''No need to process
            Exit Sub
        End If
        m_BatchID = Convert.ToInt32(txtBatchID.Text)
        txtSerial.Attributes.Remove("onfocus")
        Try
            m_DataLayer.AddFSPStockTakeLog(m_BatchID, txtSerial.Text)
        Catch ex As Exception
            m_DataLayer.PopupMessage = ex.Message + commonMsg

            ''can not use .net2.0 setfocus method, it cause the popup message windows lose focus
            Call SetFocusExt(txtSerial)

            Call DisplayMessageBox(Me.Page)

        End Try

        Call ShowScanPanel()
    End Sub
    Private Sub CloseBatch()
        If m_DataLayer.CloseFSPStockTakeAndSendReport(m_BatchID) = DataLayerResult.Success Then
            ''close local variable
            m_Service = ""
            m_BatchID = 0
            Call ShowAcknowledgePanel()
        Else
            Call ShowScanPanel()
        End If

    End Sub
    Private Sub ShowAcknowledgePanel()
        panelEdit.Visible = False
        panelScan.Visible = False
        panelAcknowledge.Visible = True
        lblFormTitle.Text = "The StockTake has been closed successfully."

    End Sub
    Private Sub Download()
        ''Download request
        Dim fileName As String
        Dim summary As String
        If m_DataLayer.GetFSPStockTakeLog(m_BatchID, 1) = DataLayerResult.Success Then
            ''yes, get the log recordset
            ''set file name with MS Excel extension
            fileName = "StockTakeBatch" & m_BatchID.ToString & ".xls"


            ''get stock Take details 
            If m_DataLayer.GetFSPStockTake(m_BatchID, "") = DataLayerResult.Success Then
                summary = String.Format("StockTake: BatchID: {0}, Depot: {1},  StockTakeDate: {2}", _
                                    m_BatchID, _
                                    m_DataLayer.dsJob.Tables(0).Rows(0)("Depot"), _
                                    Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("StockTakeDate")).ToString("dd/MM/yyyy"))

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

        If m_DataLayer.PutFSPStockTake(m_BatchID, Convert.ToInt32(cboDepot.SelectedValue), _
                                            Convert.ToDateTime(cboStockTakeDate.SelectedValue), _
                                            txtNote.Text, "O") = DataLayerResult.Success Then
            Call ShowScanPanel()
        End If
    End Sub

    'Private Sub btnSaveSerial_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSaveSerial.ServerClick
    '    Call ScanDevice()
    'End Sub

    Private Sub txtSerial_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSerial.TextChanged
        Call ScanDevice()
    End Sub

    Protected Sub btnSaveSerial_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveSerial.Click
        Call ScanDevice()
    End Sub
#End Region



    End Class
End Namespace