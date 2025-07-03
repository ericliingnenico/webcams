#Region "vss"
'<!--$$Revision: 4 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 3/03/14 15:30 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPReAssignJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: FSPReAssignJob
'
' Description: 
'   FSP ReAssign Job page
'----------------------------------------------------------------

Imports System.Text
Imports System.Data

Namespace eCAMS

Partial Class FSPReAssignJob
    Inherits MemberPageBase

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

    ''Local Variable
    Dim m_JobID As Int64
#Region "Function"
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    '----------------------------------------------------------------
    ' GetContext:
    '   Get pass-in param, such as Query string, form hidden fields
    '----------------------------------------------------------------
    Protected Overrides Sub GetContext()

        With Request
            m_JobID = Convert.ToInt64(.Item("JID"))
        End With
    End Sub
    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        Me.PageTitle = "ReAssign Job"

        ''Set Info Label
        ''lblFormTitle.Text = "ReAssign Job"
        SearchAgainURL.Text = ""

        ''get Job details
        If m_DataLayer.GetFSPJobSheetData(m_JobID) <> DataLayerResult.Success Then
            lblFormTitle.Text = "There is an error on retrieving job data."
            Exit Sub
        End If

        txtJobID.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobID"))

        ''set current assigned
        txtCurrentAssigned.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("InstallerID"))

        ''Cache FSPFamily
        m_DataLayer.CacheFSPFamily()
        ''Set FSP Combox
        cboAssignedTo.DataSource = m_DataLayer.FSPFamily
        cboAssignedTo.DataTextField = "FSPDisplayName"
        cboAssignedTo.DataValueField = "FSPID"
        cboAssignedTo.DataBind()

        ''set job details
        Call DisplayJobDetails()

        ''set device in/out
        Call DisplayDevice()
    End Sub
    Private Sub DisplayJobDetails()
        Dim sb As New StringBuilder
        sb.Append("JobType: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType")))
        sb.Append(vbCrLf)


        sb.Append("ClientID: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ClientID")))
        sb.Append(vbCrLf)

        sb.Append("TerminalID: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("TerminalID")))
        sb.Append(vbCrLf)

        sb.Append("MerchantID: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("MerchantID")))
        sb.Append(vbCrLf)

        sb.Append("RequiredDateTime: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("AgentSLADateTimeLocal")))
        sb.Append(vbCrLf)

        sb.Append("Merchant: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Name")))
        sb.Append(vbCrLf)
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Address")))
        sb.Append(vbCrLf)
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Address2")))
        sb.Append(vbCrLf)
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("City")))
        sb.Append(",")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Postcode")))
        sb.Append(vbCrLf)

        'sb.Append("Contact: ")
        'sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Contact")))
        'sb.Append(",  phone:")
        'sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Phone")))
        'sb.Append(vbCrLf)
        ''some thml tags inside the notes cause validation error on ASP.Net 4 eventhough with ValidateRequest = "false"
        'sb.Append("Notes: ")
        'sb.Append(Server.HtmlEncode(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Notes"))))
        'sb.Append(vbCrLf)

        'sb.Append("Info: ")
        'sb.Append(Server.HtmlEncode(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Info"))))

        txtJobDetails.Text = sb.ToString
    End Sub
    Private Sub DisplayDevice()
        Dim dt As DataTable
        Dim i As Int32

        dt = m_DataLayer.dsJob.Tables(0).Copy  ''copy data structure and data, clone only copy structure

        For i = dt.Columns.Count - 1 To 0 Step -1
            If Not (dt.Columns(i).ColumnName = "Serial" Or _
                    dt.Columns(i).ColumnName = "MMD" Or _
                    dt.Columns(i).ColumnName = "EquipmentType" Or _
                    dt.Columns(i).ColumnName = "InOut") Then
                dt.Columns.RemoveAt(i)
            End If
        Next

        grdDevice.DataSource = dt
        grdDevice.DataBind()
    End Sub
#End Region


#Region "Event"

    Private Sub btnReAssign_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnReAssign.ServerClick
        Dim ret As DataLayerResult
        Try
            ret = m_DataLayer.FSPReAssignJob(Convert.ToInt64(txtJobID.Text), Convert.ToInt32(cboAssignedTo.SelectedValue))
            If ret = DataLayerResult.Success Then
                panelDetail.Visible = False

                lblFormTitle.Text = "<BR/><BR/>This job has been re-assigned to " & cboAssignedTo.SelectedItem.Text & "."
            End If

        Catch ex As Exception
            lblErrorMsg.Text = "Failed to re-assign this job. " + ex.Message
        End Try

    End Sub
#End Region

End Class

End Namespace

