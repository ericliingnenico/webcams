#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/JobList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On
Imports System.Data
Imports System.Drawing
Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: JobList
'
' Description: 
'   List Jobs based on type
'----------------------------------------------------------------
Partial Class JobList
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
    Private Const FROM_WEB As Short = 1

#Region "Function"
    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    '----------------------------------------------------------------
    ' GetContext:
    '   Get pass-in param, such as Query string, form hidden fields
    '----------------------------------------------------------------
    Protected Overrides Sub GetContext()
        With Request
            ''process passin params
            If .QueryString("WhichJob") <> "" Then
                Select Case .QueryString("WhichJob").ToUpper
                    Case "I"
                        m_DataLayer.SelectedJobTypeForJobSearch = "INSTALL"
                    Case "D"
                        m_DataLayer.SelectedJobTypeForJobSearch = "DEINSTALL"
                    Case "U"
                        m_DataLayer.SelectedJobTypeForJobSearch = "UPGRADE"
                    Case "C"
                        m_DataLayer.SelectedJobTypeForJobSearch = "CALL"
                    Case Else
                        m_DataLayer.SelectedJobTypeForJobSearch = ""
                End Select
            End If
        End With
    End Sub
    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Job List"

        ''Set SearchAgainURL
        If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
            SearchAgainURL.Text = "" ''"Search again"
            Select Case m_DataLayer.SelectedJobTypeForJobSearch
                Case "INSTALL"
                    SearchAgainURL.NavigateUrl = "../Member/JobSearch.aspx?WhichJob=I"

                Case "DEINSTALL"
                    SearchAgainURL.NavigateUrl = "../Member/JobSearch.aspx?WhichJob=D"

                Case "UPGRADE"
                    SearchAgainURL.NavigateUrl = "../Member/JobSearch.aspx?WhichJob=U"

                Case "CALL"
                    SearchAgainURL.NavigateUrl = "../Member/JobSearch.aspx?WhichJob=C"

                Case Else
                    SearchAgainURL.NavigateUrl = "../Member/Member.aspx"
                    SearchAgainURL.Text = "Home"
            End Select
        Else
            SearchAgainURL.NavigateUrl = "../Member/FSPMain.aspx"
            SearchAgainURL.Text = "" ''"Back"
        End If

    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        Dim dv As DataView

        ''set page title
        Me.PageTitle = "Job List"

            ''Set PageSize to Grid
            grdJob.PageSize = m_DataLayer.SelectedPageSize

            Select Case m_DataLayer.SelectedJobTypeForJobSearch
            Case "CALL"
                If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
                    dlResult = m_DataLayer.GetCalls(m_DataLayer.SelectedClientIDForJobSearch, m_DataLayer.SelectedStateForJobSearch, m_DataLayer.SelectedStatusForJobSearch)
                Else
                    dlResult = m_DataLayer.GetCalls(m_DataLayer.SelectedClientIDForJobSearch, FROM_WEB)
                End If
                If dlResult = DataLayerResult.Success Then
                    ds = m_DataLayer.dsCalls
                End If
            Case "INSTALL", "DEINSTALL", "UPGRADE"
                If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
                    dlResult = m_DataLayer.GetJobs(m_DataLayer.SelectedClientIDForJobSearch, m_DataLayer.SelectedJobTypeForJobSearch, m_DataLayer.SelectedStateForJobSearch, m_DataLayer.SelectedStatusForJobSearch)
                Else
                    dlResult = m_DataLayer.GetJobs(m_DataLayer.SelectedClientIDForJobSearch, m_DataLayer.SelectedJobTypeForJobSearch, FROM_WEB)
                End If
                If dlResult = DataLayerResult.Success Then
                    ds = m_DataLayer.dsJobs
                End If

            Case Else
                ''Nothing matching selected, redirect to member.aspx
                Call Server.Transfer("Member.aspx")

        End Select

        ''if datacolumn doesn't contain the sort column, set sortcolumn to empty
        If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not ds.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder.Replace(" DESC", "")) Then
            m_DataLayer.SelectedSortOrder = String.Empty
        End If

        ''Set record found info
        If ds.Tables(0).Rows.Count > 0 Then
            lblListInfo.Text = ds.Tables(0).Rows.Count.ToString & _
                                " records found  (display page " & _
                                CType((grdJob.CurrentPageIndex + 1), String) & _
                                " with max " & _
                                grdJob.PageSize.ToString & _
                                " records per page)"
                ''appending sorting details
                If m_DataLayer.SelectedSortOrder <> String.Empty Then
                    lblListInfo.Text += ". Sort on " & _
                                    m_DataLayer.SelectedSortOrder
                End If
        Else
            lblListInfo.Text = "No records found"
        End If
        'bind grid

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
    End Sub
#End Region



#Region "Event"
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid()
    End Sub
    Protected Sub grdJob_SortCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridSortCommandEventArgs)
        Call m_DataLayer.VerifyLogin()
        'System.Diagnostics.Debug.WriteLine(e.CommandSource)
        ''toggle sort order
        m_DataLayer.SelectedSortOrder = Convert.ToString(IIf(m_DataLayer.SelectedSortOrder = e.SortExpression, e.SortExpression & " DESC", e.SortExpression))
        Call BindGrid()
    End Sub
#End Region
End Class

End Namespace
