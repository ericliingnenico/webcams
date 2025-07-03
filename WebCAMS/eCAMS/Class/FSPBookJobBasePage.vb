#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/01/16 9:03 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPBookJobBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
    Public Class FSPBookJobBasePage
        Inherits MemberPageBase

        ''Local Variable
        Protected m_JobID As Int64
        Protected lblMsg As New Label


        Protected Overrides Sub GetContext()
            With Request
                m_JobID = Convert.ToInt64(.Item("jid"))
            End With
        End Sub
        Protected Sub DisplayBookingPage(pTxtJobID As TextBox, ptxtJobIDList As HiddenField, pPlaceholderErrorMsg As PlaceHolder, pCboBookTo As DropDownList, pJobDetails As Object, pMultipleJobList As Object, pCboEscalateReason As DropDownList)
            Dim strJobDetail As String = ""
            pTxtJobID.Text = CStr(m_JobID)
            PositionMsgLabel(pPlaceholderErrorMsg, lblMsg)
            Try
                ''m_DataLayer.GetFSPJobSheetData(m_JobID)



                ''Cache FSPChildren
                m_DataLayer.CacheFSPFamily()
                ''Set FSP Combox
                pCboBookTo.DataSource = m_DataLayer.FSPFamily
                pCboBookTo.DataTextField = "FSPDisplayName"
                pCboBookTo.DataValueField = "FSPID"
                pCboBookTo.DataBind()

                m_DataLayer.GetFSPJobsForBooking(m_JobID)
                ptxtJobIDList.Value = ""
                If m_DataLayer.dsDevices.Tables(0).Rows.Count > 0 Then
                    With m_DataLayer.dsDevices.Tables(0).Rows(0)

                        strJobDetail = "JobID:" + .Item("JobID").ToString + " " + .Item("ClientID").ToString + "  " + .Item("JobType").ToString + " " + .Item("DeviceType").ToString + " " _
                                        + " Name:" + .Item("Name").ToString + " " _
                                        + " Address:" + .Item("Address").ToString + " " + .Item("City").ToString + " " + .Item("Postcode").ToString + " " _
                                        + " Contact:" + .Item("Contact").ToString + " Tel:" + .Item("PhoneNumber").ToString + "," + .Item("MobileNumber").ToString + vbCrLf _
                                        + "Notes:" + .Item("Notes").ToString
                        ptxtJobIDList.Value += .Item("JobID").ToString
                    End With
                End If

                If m_DataLayer.dsDevices.Tables(1).Rows.Count > 0 Then
                    For Each dr As DataRow In m_DataLayer.dsDevices.Tables(1).Rows
                        If dr.Item("JobID").ToString() <> m_JobID.ToString Then
                            ptxtJobIDList.Value += "," + dr.Item("JobID").ToString
                        End If
                    Next
                End If

                If m_renderingStyle = RenderingStyleType.PDA Then
                    CType(pJobDetails, Label).Text = strJobDetail
                    DirectCast(pMultipleJobList, Repeater).DataSource = m_DataLayer.dsDevices.Tables(1)
                    DirectCast(pMultipleJobList, Repeater).DataBind()
                End If
                If m_renderingStyle = RenderingStyleType.DeskTop Then
                    CType(pJobDetails, TextBox).Text = strJobDetail
                    Dim dt As DataTable
                    Dim i As Int32

                    dt = m_DataLayer.dsDevices.Tables(1).Copy  ''copy data structure and data, clone only copy structure

                    For i = dt.Columns.Count - 1 To 0 Step -1
                        If Not (dt.Columns(i).ColumnName = "JobID" Or _
                                dt.Columns(i).ColumnName = "JobType" Or _
                                dt.Columns(i).ColumnName = "TerminalID" Or _
                                dt.Columns(i).ColumnName = "DeviceType" Or _
                                dt.Columns(i).ColumnName = "JobName" Or _
                                dt.Columns(i).ColumnName = "JobCity") Then
                            dt.Columns.RemoveAt(i)
                        End If
                    Next

                    DirectCast(pMultipleJobList, DataGrid).DataSource = dt
                    DirectCast(pMultipleJobList, DataGrid).DataBind()

                End If

                If m_DataLayer.GetFSPEscalateJobBookingReason() = DataLayerResult.Success Then
                    pCboEscalateReason.DataSource = m_DataLayer.dsTemp
                    pCboEscalateReason.DataTextField = "EscalateReason"
                    pCboEscalateReason.DataValueField = "EscalateReasonID"
                    pCboEscalateReason.DataBind()
                End If

            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try
        End Sub
        Protected Sub BookJob(ByVal pJobIDList As String, ByVal pBookTo As Short, ByVal pBookDateTime As Date, ByVal pNotes As String, ByVal pNextPage As String, pPlaceholderErrorMsg As PlaceHolder)
            Dim ret As DataLayerResult
            PositionMsgLabel(pPlaceholderErrorMsg, lblMsg)
            Try
                ret = m_DataLayer.FSPBookJob(pJobIDList, pBookTo, pBookDateTime, pNotes)
                If ret = DataLayerResult.Success Then
                    Response.Redirect(pNextPage)
                End If
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try
        End Sub
        Protected Sub EscalateJob(ByVal pJobIDList As String, ByVal pExceptionID As Short, ByVal pNotes As String, ByVal pNextPage As String, pPlaceholderErrorMsg As PlaceHolder)
            Dim ret As DataLayerResult
            PositionMsgLabel(pPlaceholderErrorMsg, lblMsg)
            Try
                ret = m_DataLayer.EscalateFSPJobBooking(pJobIDList, pExceptionID, pNotes)
                If ret = DataLayerResult.Success Then
                    Response.Redirect(pNextPage)
                End If
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try
        End Sub

    End Class
End Namespace