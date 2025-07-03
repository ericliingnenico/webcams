'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/02/14 10:57 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPJobList.aspx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On
Imports System.IO
Imports System.Data
Imports System.Drawing
Namespace eCAMS
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: FSPJobList
'
' Description: 
'   FSP Open List Jobs
'----------------------------------------------------------------

Partial Class FSPJobList
    Inherits MemberPageBase

#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub
    Protected WithEvents hlStockInTransit As System.Web.UI.WebControls.HyperLink


    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region

    '*************** Functions ***************
    Protected Overrides Sub GetContext()
        ''set selected assignedto with this login FSPID if request from FSPMain.aspx
        With Request
            If .Item("List") <> "" Then
                If m_DataLayer.SelectedAssignedTo = String.Empty Then
                    m_DataLayer.SelectedAssignedTo = m_DataLayer.CurrentUserInformation.FSPID.ToString
                End If
                Select Case .Item("List")
                    Case "I"
                        m_DataLayer.SelectedJobTypeForJobSearch = "INSTALL"
                    Case "D"
                        m_DataLayer.SelectedJobTypeForJobSearch = "DEINSTALL"
                    Case "U"
                        m_DataLayer.SelectedJobTypeForJobSearch = "UPGRADE"
                    Case "C"
                        m_DataLayer.SelectedJobTypeForJobSearch = "SWAP"

                End Select
                m_DataLayer.SelectedRefreshSecond = 300
                ''clear previous selected search 
                m_DataLayer.SelectedIncludeChildDepot = False
                m_DataLayer.SelectedIDs = ""
                m_DataLayer.SelectedDueDate = ""
            End If

            If .Item("opc") <>"" andalso .Item("opc").Contains("|") Then
                m_DataLayer.SelectedAssignedTo = .Item("opc").Split(CChar("|"))(0)
                m_DataLayer.SelectedDueDate = .Item("opc").Split(CChar("|"))(1)
                m_DataLayer.SelectedRefreshSecond = 300
                ''clear previous selected search 
                m_DataLayer.SelectedIncludeChildDepot = True
                m_DataLayer.SelectedIDs = ""
                m_DataLayer.SelectedJobTypeForJobSearch =""
            End If
        End With
    End Sub

    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()

        SearchAgainURL.Text = "" ''"Search again"
        SearchAgainURL.NavigateUrl = "../Member/FSPJobSearch.aspx"

        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()
        ''Set FSP Combox

        cboAssignedTo.DataSource = m_DataLayer.FSPChildren
        cboAssignedTo.DataTextField = "FSPDisplayName"
        cboAssignedTo.DataValueField = "FSPID"
        cboAssignedTo.DataBind()
        txtFSPID.Value = m_DataLayer.SelectedAssignedTo
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        Dim dv As DataView
        Dim criteria As String



        ''build search criteria string
        criteria = " on JobType=" + m_DataLayer.SelectedJobTypeForJobSearch
        If m_DataLayer.SelectedDueDate <> String.Empty Then
            criteria += ", DueDate=" + m_DataLayer.SelectedDueDate
        End If
        If m_DataLayer.SelectedIncludeChildDepot Then
            criteria += ", IncludeChildDepot=Yes"
        End If
        If m_DataLayer.SelectedNoDeviceReservedOnly Then
            criteria += ", NoReservedDeviceOnly=Yes"
        End If
        If m_DataLayer.SelectedProjectNo <> String.Empty Then
            criteria += ", ProjectNo=" + m_DataLayer.SelectedProjectNo
        End If
        If m_DataLayer.SelectedSuburb <> String.Empty Then
            criteria += ", Suburb=" + m_DataLayer.SelectedSuburb
        End If
        If m_DataLayer.SelectedPostcode <> String.Empty Then
            criteria += ", Postcode=" + m_DataLayer.SelectedPostcode
        End If
        criteria += ". "

        ''Set PageSize to Grid
        grdJob.PageSize = m_DataLayer.SelectedPageSize

        dlResult = m_DataLayer.GetFSPAllOpenJob(m_DataLayer.SelectedAssignedTo, _
                                                1, _
                                                m_DataLayer.SelectedJobTypeForJobSearch, _
                                                m_DataLayer.SelectedDueDate, _
                                                m_DataLayer.SelectedNoDeviceReservedOnly, _
                                                m_DataLayer.SelectedProjectNo, _
                                                m_DataLayer.SelectedSuburb, _
                                                m_DataLayer.SelectedPostcode, _
                                                m_DataLayer.SelectedIncludeChildDepot, _
                                                m_DataLayer.SelectedIDs)
        If dlResult = DataLayerResult.Success Then
            ds = m_DataLayer.dsJobs

            ''if datacolumn doesn't contain the sort column, set sortcolumn to empty
            If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not ds.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder.Replace(" DESC", "")) Then
                m_DataLayer.SelectedSortOrder = String.Empty
            End If

            If ds.Tables(0).Rows.Count > 0 Then
                lblListInfo.Text = ds.Tables(0).Rows.Count.ToString & _
                                    " records found" & _
                                    criteria

                ''set last refresh datetime
                lblListInfo.Text += "Last update at: <b>" & Now.ToString("d/M/yyyy H:mm:ss") & "</b>"

                ''appending sorting details
                If m_DataLayer.SelectedSortOrder <> String.Empty Then
                    lblListInfo.Text += ". Sort on " & _
                                    m_DataLayer.SelectedSortOrder
                End If

            Else
                lblListInfo.Text = "No records found" & criteria
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


    '*************** Events Handlers ***************

    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        Me.PageTitle = "Job List"
        ''only auto refresh the page when it is between 6:00 and 22:00
        If DateTime.Now.Hour > 6 And DateTime.Now.Hour < 22 Then
            Call RefreshPage(Page, m_DataLayer.SelectedRefreshSecond) ''Set timer to refresh the page
        End If
    End Sub
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

    Private Sub btnBulkReAssign_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnBulkReAssign.ServerClick
        Dim ret As DataLayerResult
        Dim jobIDList As String
        jobIDList = Request.Item("chkBulk")
        Try
            ret = m_DataLayer.FSPReAssignJobExt(jobIDList, Convert.ToInt32(cboAssignedTo.SelectedValue))
            'If ret = DataLayerResult.Success Then
            'End If

            Call BindGrid()
        Catch ex As Exception
            lblListInfo.Text = "Failed to bulk re-assign jobs. " + ex.Message
            lblListInfo.ForeColor = Color.Red
        End Try

    End Sub

    Private Sub btnBulkPrint_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnBulkPrint.ServerClick
        Dim jobIDList As String
        jobIDList = Request.Item("chkBulk")

            Response.Write(String.Format("<script>window.open('FSPJobSheetExt.aspx?JID={0}', 'JobSheet','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,width=700,height=800,alwaysRaised')</script>", jobIDList))
        End Sub

        Protected Sub btnDownload_Click(sender As Object, e As EventArgs) Handles btnDownload.Click
            If m_DataLayer.GetFSPAllOpenJob(m_DataLayer.SelectedAssignedTo,
                                                    3,
                                                    m_DataLayer.SelectedJobTypeForJobSearch,
                                                    m_DataLayer.SelectedDueDate,
                                                    m_DataLayer.SelectedNoDeviceReservedOnly,
                                                    m_DataLayer.SelectedProjectNo,
                                                    m_DataLayer.SelectedSuburb,
                                                    m_DataLayer.SelectedPostcode,
                                                    m_DataLayer.SelectedIncludeChildDepot,
                                                    m_DataLayer.SelectedIDs) = DataLayerResult.Success Then
                Dim fileName As String
                fileName = "OpenJobs_" + Date.Today.ToString("yyyyMMdd") + ".xls"
                ExportToExcel(fileName, "", m_DataLayer.dsJobs.Tables(0))
            End If
        End Sub

    End Class

End Namespace
