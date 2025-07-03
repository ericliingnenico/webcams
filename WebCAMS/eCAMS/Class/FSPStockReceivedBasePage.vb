#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 10/08/11 15:37 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPStockReceivedBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
Public Class FSPStockReceivedBasePage
    Inherits MemberPageBase
    
    ''form level variable
    Protected m_Service As String
    Protected m_BatchID As Integer
    Protected m_currentBatchDataRow As DataRow
    Protected m_currentScanLogDataTable As DataTable

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
                If m_DataLayer.GetFSPStockReceived(m_BatchID, "O") = DataLayerResult.Success Then
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
    Protected Overridable Sub HideAllPanels()

    End Sub
    Protected Overridable Sub ShowEditPanel()
        HideAllPanels
        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()

        ''get bacth data row if there is one, let child page to display
        Call GetScanBatchDataRow("O")
    End Sub
    Protected Overridable Sub ShowScanPanel()
        HideAllPanels
        Call GetScanBatchDataRow("")

        ''get scan log
        Call GetScanLogDataTable()

    End Sub
    Protected Overridable Sub ShowAcknowledgePanel()
        HideAllPanels
    End Sub

    Protected Sub ScanDevice(pTxtSerial As TextBox, pBatchID As string)
        If pTxtSerial.Text.Trim() = String.Empty Then
            ''No need to process
            Exit Sub
        End If
        m_BatchID = Convert.ToInt32(pBatchID)
        Try
            m_DataLayer.AddFSPStockReceivedLog(m_BatchID, pTxtSerial.Text)
        Catch ex As Exception
            m_DataLayer.PopupMessage = ex.Message

            If m_renderingStyle = RenderingStyleType.PDA
                Call SetFocus(pTxtSerial)
            Else
                ''can not use .net2.0 setfocus method, it cause the popup message windows lose focus
                ''it has to attach java script prior popup messsage box
                Call SetFocusExt(pTxtSerial)

            End If

            Call DisplayMessageBox(Me.Page)
        End Try
        Call ShowScanPanel()
    End Sub
    Private Sub GetScanBatchDataRow(ByVal pBatchStatus As string)
        m_currentBatchDataRow = Nothing
        If m_DataLayer.GetFSPStockReceived(m_BatchID, pBatchStatus) = DataLayerResult.Success Then
            If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                m_currentBatchDataRow= m_DataLayer.dsJob.Tables(0).Rows(0)
            End If
        End If
    End Sub
    Private Sub GetScanLogDataTable()
        m_currentScanLogDataTable = Nothing
        If m_DataLayer.GetFSPStockReceivedLog(m_BatchID, 1) = DataLayerResult.Success Then
            m_currentScanLogDataTable = m_DataLayer.dsJobs.Tables(0)
        End If
    End Sub

    Private Sub CloseBatch()
        If m_DataLayer.CloseFSPStockReceivedAndSendReport(m_BatchID) = DataLayerResult.Success Then
            ''close local variable
            m_Service = ""
            m_BatchID = 0
            Call ShowAcknowledgePanel()
        Else
            Call ShowScanPanel()
        End If

    End Sub
    Protected Sub Download()
        ''Download request
        Dim fileName As String
            Dim summary As String = "Excel"
        If m_DataLayer.GetFSPStockReceivedLog(m_BatchID, 1) = DataLayerResult.Success Then
            ''yes, get the log recordset
            ''set file name with MS Excel extension
            fileName = "StockReceivedBatch" & m_BatchID.ToString & ".xls"


            ''get stock received details 
            If m_DataLayer.GetFSPStockReceived(m_BatchID, "") = DataLayerResult.Success Then
                summary = String.Format("StockReceipt: BatchID: {0}, Depot: {1}, DateReceived: {2}", _
                                    m_BatchID, _
                                    m_DataLayer.dsJob.Tables(0).Rows(0)("Depot"), _
                                    Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("DateReceived")).ToString("dd/MM/yyyy"))

            End If

            Call ExportToExcel(fileName, summary, m_DataLayer.dsJobs.Tables(0))
        Else
            ''failed to this output request

        End If
    End Sub
    Protected Sub SaveBatch(ByVal pDepot As Integer, ByVal pDateReceived As Date, pBatchID As String)
        Try
            m_BatchID = Convert.ToInt32(pBatchID)
        Catch ex As Exception

        End Try

        If m_DataLayer.PutFSPStockReceived(m_BatchID, pDepot, pDateReceived, "O") = DataLayerResult.Success Then
            Call ShowScanPanel()
        End If
    End Sub


End Class
End Namespace
