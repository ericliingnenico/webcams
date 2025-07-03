#Region "vss"
'<!--$$Revision: 4 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 10/08/11 15:37 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPStockReturnedBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS

Public Class FSPStockReturnedBasePage
    Inherits MemberPageBase
    ''form level variable
    Protected m_Service As String
    Protected m_BatchID As Integer
    Protected m_CaseID As Integer
    Protected m_Serial As String
    Protected m_SaveSerial As Boolean
    Protected m_currentBatchDataRow As DataRow
    Protected m_currentScanLogDataTable As DataTable
    Protected m_box As String
    Protected m_ReferenceNo As String
    Protected m_Notes As String
    Protected m_Error As String
    Private m_StockFaulty As Boolean
    Private m_strBatchID As String
    Private m_StockFaultyPos As Integer

    Protected Overrides Sub GetContext()
      With Request
        m_Service = .QueryString("sv")
        m_strBatchID = ""
        m_strBatchID = .QueryString("id")
        If m_strBatchID <> "{0}" Then
          m_BatchID = Convert.ToInt32(.QueryString("id"))
        End If
        m_box = .QueryString("box")

        m_StockFaultyPos = InStr(1, Me.Page.ToString(), "fspstockfaulty")
        m_StockFaulty = (m_StockFaultyPos > 0)
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
          If m_DataLayer.GetFSPStockReturned(m_BatchID, "O", m_StockFaulty) = DataLayerResult.Success Then
            If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
              ''there is an open batch, ask opertor to scan device
              m_BatchID = Convert.ToInt32(m_DataLayer.dsJob.Tables(0).Rows(0)("BatchID"))
              m_Notes = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Note"))
              Call ShowScanPanel()
            End If
            ''ask opertor to create new batch
            Call ShowEditPanel()
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
      HideAllPanels()
      Call GetScanBatchDataRow("")

      ''get scan log
      Call GetScanLogDataTable()

    End Sub
    Protected Overridable Sub ShowAcknowledgePanel()
         HideAllPanels
      End Sub
    Protected Sub ScanDevice(pTxtSerial As TextBox, pBatchID As String, Optional pStockFaulty As Boolean = False)
      Dim commonMsg As String = "<br><br>Please check that serial has been keyed or scanned correctly. <br><br>If this device is being returned following a Service Request, the record for Service Request should be closed or updated before proceeding. <br><br><b>This device should not be returned to Ingenico until the cause of this error has been resolved.<b><br>"

      If pTxtSerial.Text.Trim() = String.Empty Then
        ''No need to process
        Exit Sub
      End If
      m_BatchID = Convert.ToInt32(pBatchID)
      Try
        m_StockFaulty = pStockFaulty
        m_DataLayer.AddFSPStockReturnedLog(m_BatchID, pTxtSerial.Text, m_StockFaulty, m_CaseID)
      Catch ex As Exception
        m_DataLayer.PopupMessage = ex.Message + commonMsg

        If m_renderingStyle = RenderingStyleType.PDA Then
          Call SetFocus(pTxtSerial)
        Else
          ''can not use .net2.0 setfocus method, it cause the popup message windows lose focus
          ''it has to attach java script prior popup messsage box
          Call SetFocusExt(pTxtSerial)

        End If

        Call DisplayMessageBox(Me.Page)
      End Try
      Call ShowScanPanel()
      Call ShowEditPanel()
    End Sub
    Protected Sub ValidateStockFaulty(pBatchID As String, pTxtSerial As TextBox, Optional pStockFaulty As Boolean = False)
      Dim commonMsg As String = "<br><br>Please check that serial has been keyed or scanned correctly."

      'Try
      '  m_BatchID = Convert.ToInt32(pBatchID)
      'Catch ex As Exception

      'End Try
      'm_StockFaulty = pStockFaulty
      'If m_DataLayer.PutFSPStockReturned(m_BatchID, pDepot, pToDepot, pDateReturned, pReferenceNo, pNote, "O", m_StockFaulty) = DataLayerResult.Success Then
      '  Call ShowScanPanel()
      '  Call ShowEditPanel()
      'End If


      If pTxtSerial.Text.Trim() = String.Empty Then
        ''No need to process
        Exit Sub
      End If

      Try
        m_BatchID = Convert.ToInt32(pBatchID)
        'm_Serial = pTxtSerial.Text
        m_StockFaulty = pStockFaulty
        If m_DataLayer.ValidateStockFaulty(m_BatchID, 0, 0, Convert.ToDateTime(Date.Now.ToString("dd/MM/yy")), "", "", "O", m_StockFaulty, pTxtSerial.Text, m_CaseID, True) = DataLayerResult.Success Then
          Call ShowEditPanel()
        End If
      Catch ex As Exception
        m_DataLayer.PopupMessage = ex.Message + commonMsg

        If m_renderingStyle = RenderingStyleType.PDA Then
          Call SetFocus(pTxtSerial)
        Else
          ''can not use .net2.0 setfocus method, it cause the popup message windows lose focus
          ''it has to attach java script prior popup messsage box
          Call SetFocusExt(pTxtSerial)

        End If

        Call DisplayMessageBox(Me.Page)
      End Try
      'Call ShowScanPanel()

    End Sub
    Private Sub GetScanBatchDataRow(ByVal pBatchStatus As String)
      m_currentBatchDataRow = Nothing
      If m_DataLayer.GetFSPStockReturned(m_BatchID, pBatchStatus, m_StockFaulty) = DataLayerResult.Success Then
        If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
          m_currentBatchDataRow = m_DataLayer.dsJob.Tables(0).Rows(0)
        End If
      End If
    End Sub
    Private Sub GetScanLogDataTable()
      m_currentScanLogDataTable = Nothing
      If m_DataLayer.GetFSPStockReturnedLog(m_BatchID, 1, m_StockFaulty) = DataLayerResult.Success Then
        m_currentScanLogDataTable = m_DataLayer.dsJobs.Tables(0)
      End If
    End Sub

    Protected Sub CloseBatch(Optional pStockFaulty As Boolean = False)
      m_StockFaulty = pStockFaulty
      If m_DataLayer.CloseFSPStockReturnedAndSendReport(m_BatchID, Convert.ToInt32(m_box), m_ReferenceNo, m_Notes, pStockFaulty) = DataLayerResult.Success Then
        ''close local variable
        m_Service = ""
        m_BatchID = 0
        m_ReferenceNo = ""
        m_Notes = ""
        m_CaseID = 0
        m_SaveSerial = False
        Call ShowAcknowledgePanel()
      Else
        Call ShowEditPanel()
      End If

    End Sub
    Protected Sub Download()
        ''Download request
        Dim fileName As String
            Dim summary As String = "Excel"
      If m_DataLayer.GetFSPStockReturnedLog(m_BatchID, 1, m_StockFaulty) = DataLayerResult.Success Then
        ''yes, get the log recordset
        ''set file name with MS Excel extension
        fileName = "StockReturnedBatch" & m_BatchID.ToString & ".xls"


        ''get stock Returned details 
        If m_DataLayer.GetFSPStockReturned(m_BatchID, "", m_StockFaulty) = DataLayerResult.Success Then
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
    Protected Sub SaveBatch(ByVal pDepot As Integer, ByVal pToDepot As Integer, ByVal pDateReturned As Date, ByVal pReferenceNo As String, ByVal pNote As String, pBatchID As String, Optional pStockFaulty As Boolean = False)
      Try
        m_BatchID = Convert.ToInt32(pBatchID)
      Catch ex As Exception

      End Try
      m_StockFaulty = pStockFaulty
      If m_DataLayer.PutFSPStockReturned(m_BatchID, pDepot, pToDepot, pDateReturned, pReferenceNo, pNote, "O", m_StockFaulty) = DataLayerResult.Success Then
        Call ShowScanPanel()
        Call ShowEditPanel()
      End If
    End Sub

  End Class
End Namespace