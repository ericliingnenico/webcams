#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPClosedJobWODList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing

Namespace eCAMS

Partial Class FSPClosedJobWODList
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


#Region "Function"
    Protected Overrides Sub GetContext()
        With Request

        End With
    End Sub

    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    Private Sub SetDE()
        Me.PageTitle = "Closed Job With Outstanding Device List"

        SearchAgainURL.Text = "" ''"Search again"
        SearchAgainURL.NavigateUrl = "../Member/FSPClosedJobWOD.aspx"
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        Dim dv As DataView

        Me.PageTitle = "Closed Job With Outstanding Device List"
        ''Set PageSize to Grid
        grdJob.PageSize = m_DataLayer.SelectedPageSize

        dlResult = m_DataLayer.GetFSPClosedJobWithOutstandingDevice(Convert.ToInt32(m_DataLayer.SelectedAssignedTo), m_DataLayer.SelectedFromDate, m_DataLayer.SelectedToDate, 1)
        If dlResult = DataLayerResult.Success Then
            ds = m_DataLayer.dsJobs

            ''if datacolumn doesn't contain the sort column, set sortcolumn to empty
            If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not ds.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder.Replace(" DESC", "")) Then
                m_DataLayer.SelectedSortOrder = String.Empty
            End If

            If ds.Tables(0).Rows.Count > 0 Then
                lblListInfo.Text = ds.Tables(0).Rows.Count.ToString & _
                                    " records found"

                ''appending sorting details
                If m_DataLayer.SelectedSortOrder <> String.Empty Then
                    lblListInfo.Text += ". Sort on " & _
                                    m_DataLayer.SelectedSortOrder
                End If
            Else
                lblListInfo.Text = "No records found"
            End If
            'bind grid
            Try
                ''using dataview for sorting on column purpose
                dv = New DataView(ds.Tables(0))
                If m_DataLayer.SelectedSortOrder <> String.Empty Then
                    dv.Sort = m_DataLayer.SelectedSortOrder
                End If
                grdJob.DataSource = dv
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

    Protected Sub grdJob_SortCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridSortCommandEventArgs) Handles grdJob.SortCommand
        Call m_DataLayer.VerifyLogin()
        'System.Diagnostics.Debug.WriteLine(e.CommandSource)
        ''toggle sort order
        m_DataLayer.SelectedSortOrder = Convert.ToString(IIf(m_DataLayer.SelectedSortOrder = e.SortExpression, e.SortExpression & " DESC", e.SortExpression))
        Call BindGrid()
    End Sub

    Private Sub lbDownload_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lbDownload.Click
        Dim fileName As String
        fileName = Date.Now.Today.ToString("yyyyMMdd") & "-" & m_DataLayer.CurrentUserInformation.FSPID & "-ClosedJobWODList.xls"

        ''get data set
        Dim dlResult As DataLayerResult
        dlResult = m_DataLayer.GetFSPClosedJobWithOutstandingDevice(Convert.ToInt32(m_DataLayer.SelectedAssignedTo), m_DataLayer.SelectedFromDate, m_DataLayer.SelectedToDate, 3)
        If dlResult = DataLayerResult.Success Then
            ''export
            Call ExportToExcel(fileName, "", m_DataLayer.dsJobs.Tables(0))
        End If
    End Sub
#End Region
End Class

End Namespace
