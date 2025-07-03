#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPClosedTaskList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data

Namespace eCAMS

Partial Class FSPClosedTaskList
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
        Me.PageTitle = "Closed Task List"

        SearchAgainURL.Text = "" ''"Search again"
        SearchAgainURL.NavigateUrl = "../Member/FSPClosedTaskSearch.aspx"
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        ''Set PageSize to Grid
        grdJob.PageSize = m_DataLayer.SelectedPageSize

        dlResult = m_DataLayer.GetFSPClosedTasks(m_DataLayer.SelectedAssignedTo, m_DataLayer.SelectedFromDate, m_DataLayer.SelectedToDate)
        If dlResult = DataLayerResult.Success Then
            ds = m_DataLayer.dsJobs
            If ds.Tables(0).Rows.Count > 0 Then
                lblListInfo.Text = ds.Tables(0).Rows.Count.ToString & _
                                    " records found  (display page " & _
                                    CType((grdJob.CurrentPageIndex + 1), String) & _
                                    " with max " & _
                                    grdJob.PageSize.ToString & _
                                    " records per page)"
            Else
                lblListInfo.Text = "No records found"
            End If
            'bind grid
            Try
                grdJob.DataSource = ds
                grdJob.DataBind()
            Catch exc As Exception
            Finally
                ''''Hide the grid when no records returned
                'If grdJob.Items.Count = 0 Then
                '    grdJob.Visible = False
                'End If
            End Try

        End If
        ''Set record found info

    End Sub

#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

    End Sub
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid()
    End Sub

#End Region
End Class

End Namespace
