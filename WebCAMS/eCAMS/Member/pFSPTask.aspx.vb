#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/pFSPTask.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Imports System.Text
Imports System.Data

Namespace eCAMS



Partial Class pFSPTask
    Inherits PDAPageBase

#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub
    Protected WithEvents rfvSerial As System.Web.UI.WebControls.RequiredFieldValidator
    Protected WithEvents ValidationSummary1 As System.Web.UI.WebControls.ValidationSummary
    Protected WithEvents rfvConNoteNo As System.Web.UI.WebControls.RequiredFieldValidator


    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region

    Private m_TaskID As Int64
    Enum MessageType
        Succeed = 1
        Failed
    End Enum

#Region "Function"
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    Protected Overrides Sub GetContext()
        With Request
            m_TaskID = Convert.ToInt64(.Item("JID"))
        End With
    End Sub

    Private Sub SetDE()
        Me.PageTitle = "Task"

        ''Set Info Label
        lblFormTitle.Text = "Task Edit"



        ''get Task details
        If m_DataLayer.GetFSPTask(m_TaskID) <> DataLayerResult.Success Then
            lblFormTitle.Text = "There is an error on retrieving task data."
            Exit Sub
        End If

        txtTaskID.Text = m_TaskID
        txtConNoteNo.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ConNoteNo"))


        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()
        ''Set FSP Combox

        cboCarrier.DataSource = m_DataLayer.dsJob.Tables(1)
        cboCarrier.DataTextField = "Carrier"
        cboCarrier.DataValueField = "CarrierID"
        cboCarrier.DataBind()

        Call ScrollToCboValue(cboCarrier, Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("DefaultCarrierID")))

        ''closure comments
        txtCloseComment.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("CloseComment"))

        ''set task details
        Call DisplayTaskDetails()

        ''set device
        Call DisplayDevice()
    End Sub
    Private Sub DisplayTaskDetails()
        Dim sb As New StringBuilder
        sb.Append("TaskNo: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobID")))
        sb.Append(" - ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("TaskID")))
        sb.Append(vbCrLf)

        sb.Append("Due: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("DueDateTimeLocalView")))
        sb.Append(vbCrLf)

        sb.Append("ClientID: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ClientID")))
        sb.Append(vbCrLf)

        sb.Append("DeviceType: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("DeviceType")))
        sb.Append(vbCrLf)

        sb.Append("TaskSummary: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("TaskSummary")))
        sb.Append(vbCrLf)


        sb.Append("TaskDetails: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("TaskDetails")))
        sb.Append(vbCrLf)

        sb.Append("ToLocation: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocation")))
        sb.Append(vbCrLf)
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocationDesc")))
        sb.Append(vbCrLf)
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocationAddress1")))
        sb.Append(vbCrLf)
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocationAddress2")))
        sb.Append(vbCrLf)
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocationCity")))
        sb.Append(",")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocationPostcode")))
        sb.Append(vbCrLf)

        sb.Append("Contact: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocationContact")))
        sb.Append(",  phone:")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ToLocationPhone")))
        sb.Append(vbCrLf)

        txtTaskDetails.Text = sb.ToString
    End Sub
    Private Sub DisplayDevice()
        Dim dt As DataTable
        Dim i As Int32

        dt = m_DataLayer.dsJob.Tables(0).Copy  ''copy data structure and data, clone only copy structure

        For i = dt.Columns.Count - 1 To 0 Step -1
            If Not (dt.Columns(i).ColumnName = "Serial" Or _
                    dt.Columns(i).ColumnName = "MMD" Or _
                    dt.Columns(i).ColumnName = "DeviceDescription") Then
                dt.Columns.RemoveAt(i)
            End If
        Next

        grdDevice.DataSource = dt
        grdDevice.DataBind()
    End Sub
    Private Sub DisplayExceptionPanel(ByVal pShowDevicePanel As Boolean)
        panelException.Visible = True
        panelSelectDevice.visible = pShowDevicePanel
        panelDetail.Visible = False
    End Sub
    Private Sub ShowAcknowledgePage(ByVal pMsgOption As Short)
        panelException.Visible = False
        panelDetail.Visible = False
        Select Case pMsgOption
            Case MessageType.Succeed
                lblFormTitle.Text = "Saved successfully. Click CloseTask button to close this task."
                Response.Redirect("pFSPTask.aspx?JID=" + txtTaskID.Text)
            Case MessageType.Failed
                lblFormTitle.Text = "Failed to save, Click Back to try again."
        End Select

    End Sub

    Private Sub PostDataToTelstraWebPortal(ByVal pTaskID As Int64)
        Dim dr As DataRow
        Dim dlResult As DataLayerResult
        Dim strPostData As String
        Try
            dlResult = m_DataLayer.GetFSPTaskJobPostData(pTaskID)
            If dlResult = DataLayerResult.Success Then
                If m_DataLayer.dsJob.Tables.Count > 0 Then
                    For Each dr In m_DataLayer.dsJob.Tables(0).Rows
                        strPostData = Convert.ToString(dr("Data"))
                        If strPostData <> String.Empty Then
                            MyBase.PostData(strPostData)
                        End If
                    Next
                End If
            End If

        Catch ex As Exception
            ''do nothing here, resume next
        End Try
    End Sub
#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)

        MyBase.Page_Load(sender, e)
        Call SetFocus(txtSerial)
    End Sub


    Private Sub btnSave_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.ServerClick
        Dim ds As DataSet
        Dim dlResult As DataLayerResult

        ''validate
        If txtSerial.Text.Trim() = String.Empty Then
            ErrMsg.Text = "Please enter serial number."
            ErrMsg.Visible = True
            Exit Sub
        End If
        Try
            dlResult = m_DataLayer.AddFSPTaskDevice(txtTaskID.Text, txtSerial.Text, "")
            If dlResult = DataLayerResult.Success Then
                ds = m_DataLayer.dsJob
                If ds.Tables(0).Rows.Count = 0 Then
                    lblErrorMsg.Text = "No matching device found, please call EE to verify the serial number."
                    DisplayExceptionPanel(False)
                End If

                If ds.Tables(0).Rows.Count > 1 Then
                    lblErrorMsg.Text = "More than one matching device found, please select one and click Save button."
                    Try
                        cboDevice.DataSource = ds
                        cboDevice.DataTextField = "DeviceDescription"
                        cboDevice.DataValueField = "SerialMMD_ID"
                        cboDevice.DataBind()

                    Catch ex As Exception
                        ''on error resume next

                    End Try
                    DisplayExceptionPanel(True)
                End If

                If ds.Tables(0).Rows.Count = 1 Then
                    Call ShowAcknowledgePage(MessageType.Succeed)
                End If
            End If

        Catch ex As Exception
            Call ShowAcknowledgePage("Failed to save, please try again.")

        End Try
    End Sub

    Private Sub btnSaveDevice_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSaveDevice.ServerClick
        Dim dlResult As DataLayerResult
        Dim strSerialMMD_ID As String
        Try
            strSerialMMD_ID = Convert.ToString(cboDevice.SelectedValue)


            dlResult = m_DataLayer.AddFSPTaskDevice(txtTaskID.Text, _
                                        strSerialMMD_ID.Substring(0, strSerialMMD_ID.IndexOf("^")), _
                                        strSerialMMD_ID.Substring(strSerialMMD_ID.IndexOf("^") + 1))

            If dlResult = DataLayerResult.Success Then
                Call ShowAcknowledgePage(MessageType.Succeed)
            Else
                Call ShowAcknowledgePage(MessageType.Failed)
            End If

        Catch ex As Exception
            Call ShowAcknowledgePage(MessageType.Failed)
        End Try
    End Sub

    Private Sub btnCloseTask_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCloseTask.ServerClick
        Dim dlResult As DataLayerResult
        ''validate
        If txtConNoteNo.Text.Trim() = String.Empty Then
            ErrMsg.Text = "Please enter connote number."
            ErrMsg.Visible = True
            Exit Sub
        End If

        Try
            dlResult = m_DataLayer.PutFSPTask(txtTaskID.Text, CType(cboCarrier.SelectedValue, Short), txtConNoteNo.Text, txtCloseComment.Text)

            dlResult = m_DataLayer.CloseFSPTask(txtTaskID.Text)

            If dlResult = DataLayerResult.Success Then
                ''post data to Telstra web site
                PostDataToTelstraWebPortal(txtTaskID.Text)

                Response.Redirect("pFSPTaskList.aspx")
            Else
                Call ShowAcknowledgePage(MessageType.Failed)
            End If
        Catch ex As Exception
            Call ShowAcknowledgePage(MessageType.Failed)
        End Try
    End Sub

#End Region
End Class

End Namespace
