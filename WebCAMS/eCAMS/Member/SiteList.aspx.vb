#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:51 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/SiteList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On
Imports System.Data
Imports System.Drawing
Namespace eCAMS
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: SiteList
'
' Description: 
'   Site search result page
'----------------------------------------------------------------

Partial Class SiteList
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

    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Site List"


        ''Set SearchAgainURL
        SearchAgainURL.NavigateUrl = "../Member/SiteSearch.aspx"
        SearchAgainURL.Text = "" ''"Search again"
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim dv As DataView

        ''set page title
        Me.PageTitle = "Site List"

        ''Set PageSize to Grid
        grdJob.PageSize = m_DataLayer.SelectedPageSize

        dlResult = m_DataLayer.GetSites(m_DataLayer.SelectedClientIDForSiteSearch, _
                            m_DataLayer.SelectedTerminalIDForSiteSearch, _
                            m_DataLayer.SelectedMerchantIDForSiteSearch, _
                            m_DataLayer.SelectedMerchantNameForSiteSearch, _
                            m_DataLayer.SelectedMerchantSuburbForSiteSearch, _
                            m_DataLayer.SelectedMerchantPostcodeForSiteSearch)
        If dlResult = DataLayerResult.Success Then
            ''if datacolumn doesn't contain the sort column, set sortcolumn to empty
            If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not m_DataLayer.dsSites.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder.Replace(" DESC", "")) Then
                m_DataLayer.SelectedSortOrder = String.Empty
            End If

            ''Set record found info
            If m_DataLayer.dsSites.Tables(0).Rows.Count > 0 Then
                lblListInfo.Text = m_DataLayer.dsSites.Tables(0).Rows.Count.ToString & _
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
            Try
                ''using dataview for sorting on column purpose
                dv = New DataView(m_DataLayer.dsSites.Tables(0))
                If m_DataLayer.SelectedSortOrder <> String.Empty Then
                    dv.Sort = m_DataLayer.SelectedSortOrder
                End If
                grdJob.DataSource = dv
                grdJob.DataBind()

            Catch exc As Exception
                lblListInfo.Text = exc.Message
                lblListInfo.ForeColor = Color.Red

            Finally
                ''''Hide the grid when no records returned
                'If grdJob.Items.Count = 0 Then
                '    grdJob.Visible = False
                'End If
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
