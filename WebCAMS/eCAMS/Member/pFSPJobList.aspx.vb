#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/02/14 10:57 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/pFSPJobList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing
Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: pFSPJobList
'
' Description: 
'   FSP Open Job List - PDA portal
'----------------------------------------------------------------
Partial Class pFSPJobList
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

#Region "Function"

    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    Protected Overrides Sub GetContext()
        ''clean previous caching sort order, on the first page request
        m_DataLayer.SelectedSortOrder = ""
    End Sub
    Private Sub SetDE()
        Me.PageTitle = "Job List"
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        ''Set PageSize to Grid
        grdJob.PageSize = m_DataLayer.SelectedPageSize

        dlResult = m_DataLayer.GetFSPAllOpenJob(m_DataLayer.SelectedAssignedTo, 2, "", "", False, "", "", "", False, "")
        If dlResult = DataLayerResult.Success Then
            ds = m_DataLayer.dsJobs

            ''if datacolumn doesn't contain the sort column, set sortcolumn to empty
            If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not ds.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder) Then
                m_DataLayer.SelectedSortOrder = String.Empty
            End If

            If ds.Tables(0).Rows.Count > 0 Then
                lblListInfo.Text = ds.Tables(0).Rows.Count.ToString & _
                                    " records found"
                ''appending sorting details
                If m_DataLayer.SelectedSortOrder <> String.Empty Then
                    lblListInfo.Text = lblListInfo.Text & _
                                    ". Sort on " & _
                                    m_DataLayer.SelectedSortOrder
                End If
            Else
                lblListInfo.Text = "No records found"
            End If
            'bind grid
            Try
                grdJob.DataSource = ds.Tables(0)
                grdJob.DataBind()
            Catch exc As Exception
                lblListInfo.Text = exc.Message
                lblListInfo.ForeColor = Color.Red
            Finally
            End Try

        End If

    End Sub
#End Region

#Region "Event"
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid()
    End Sub

#End Region


End Class

End Namespace
