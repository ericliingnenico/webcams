#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/pFSPReAssignJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: pFSPReAssignJob 
'
' Description: 
'   FSP ReAssign Job page for PDA
'----------------------------------------------------------------

Imports System.Text


Namespace eCAMS


Partial Class pFSPReAssignJob
    Inherits PDAPageBase

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

    Protected Overrides Sub GetContext()

        With Request
            m_JobID = Convert.ToInt64(.Item("JID"))
        End With
    End Sub
    Private Sub SetDE()
        Me.PageTitle = "ReAssign"

        ''Set Info Label
        lblFormTitle.Text = "ReAssign Job"


        ''get Job details
        If m_DataLayer.GetFSPJobSheetData(m_JobID) <> DataLayerResult.Success Then
            lblFormTitle.Text = "There is an error on retrieving job data."
            Exit Sub
        End If

        txtJobID.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobID"))

        ''set current assigned
        txtCurrentAssigned.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("InstallerID"))

        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()
        ''Set FSP Combox
        cboAssignedTo.DataSource = m_DataLayer.FSPChildren
        cboAssignedTo.DataTextField = "FSPDisplayName"
        cboAssignedTo.DataValueField = "FSPID"
        cboAssignedTo.DataBind()

        ''set job details
        Call DisplayJobDetails()

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

        sb.Append("Contact: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Contact")))
        sb.Append(",  phone:")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Phone")))
        sb.Append(vbCrLf)

        sb.Append("Notes: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Notes")))
        sb.Append(vbCrLf)

        sb.Append("Info: ")
        sb.Append(Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("Info")))

        txtJobDetails.Text = sb.ToString
    End Sub
#End Region

#Region "Event"
    Private Sub btnReAssign_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnReAssign.ServerClick
        panelDetail.Visible = False
        'SearchAgainURL.Visible = True
        'SearchAgainURL.Text = "&lt&ltBack"
        'SearchAgainURL.NavigateUrl = "../Member/FSPJobList.aspx"
        Dim ret As DataLayerResult

        Try
            ret = m_DataLayer.FSPReAssignJob(Convert.ToInt64(txtJobID.Text), Convert.ToInt32(cboAssignedTo.SelectedValue))
            If ret = DataLayerResult.Success Then
                lblFormTitle.Text = "This job has been re-assigned to " & cboAssignedTo.SelectedItem.Text & "."
            Else
                lblFormTitle.Text = "Failed to re-assign this job."
            End If

        Catch ex As Exception
            lblFormTitle.Text = "Failed to re-assign this job. " + ex.Message
        End Try

    End Sub
#End Region

End Class

End Namespace

