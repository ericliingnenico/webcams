#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPStockList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing
Namespace eCAMS

Partial Class FSPStockList
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
            m_DataLayer.SelectedMode = .Item("md")
        End With
    End Sub

    Protected Overrides Sub Process()
        ''parse user selection on mode
        m_DataLayer.SelectedTransitToEE = False
        m_DataLayer.SelectedCondition = ""
        Select Case m_DataLayer.SelectedMode
            Case "1" ''in transit to FSP
                m_DataLayer.SelectedCondition = "2"
            Case "2" ''on hand - good
                    m_DataLayer.SelectedCondition = "18,19,20,9,66"
            Case "3" ''on hand - for return
                m_DataLayer.SelectedCondition = "31,37,58,59,53,1"
            Case "4" ''In transit to EE
                m_DataLayer.SelectedTransitToEE = True
        End Select


        Call SetDE()
        Call BindGrid()
    End Sub

    Private Sub SetDE()
        Me.PageTitle = "Stock List"

        SearchAgainURL.Text = ""
        SearchAgainURL.NavigateUrl = "../Member/FSPMain.aspx"
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        Dim dv As DataView
        ''Set PageSize to Grid
        grdJob.PageSize = 100 ''m_DataLayer.SelectedPageSize

        dlResult = m_DataLayer.GetFSPStockList(m_DataLayer.CurrentUserInformation.FSPID, m_DataLayer.SelectedCondition, 1, m_DataLayer.SelectedTransitToEE)
        If dlResult = DataLayerResult.Success Then
            ds = m_DataLayer.dsJobs

            ''if datacolumn doesn't contain the sort column, set sortcolumn to empty
            If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not ds.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder.Replace(" DESC", "")) Then
                m_DataLayer.SelectedSortOrder = String.Empty
            End If

            If ds.Tables(0).Rows.Count > 0 Then
                lblListInfo.Text = ds.Tables(0).Rows.Count.ToString & _
                                    " records found."

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
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        Me.PageTitle = "Stock List"

    End Sub
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid()
    End Sub

    Protected Sub grdJob_SortCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridSortCommandEventArgs) Handles grdJob.SortCommand
        Call m_DataLayer.VerifyLogin()
        ''toggle sort order
        m_DataLayer.SelectedSortOrder = Convert.ToString(IIf(m_DataLayer.SelectedSortOrder = e.SortExpression, e.SortExpression & " DESC", e.SortExpression))
        Call BindGrid()
    End Sub
    Private Sub lbDownload_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lbDownload.Click
        Dim fileName As String
        fileName = Date.Now.Today.ToString("yyyyMMdd") & "-" & m_DataLayer.CurrentUserInformation.FSPID & "-Stock"
        ''parse user selection on mode
        Select Case m_DataLayer.SelectedMode
            Case "1" ''in transit to FSP
                fileName = fileName & "InTransitToFSP.xls"
            Case "2" ''on hand - good
                fileName = fileName & "OnHandGood.xls"
            Case "3" ''on hand - for return
                fileName = fileName & "OnHandForReturn.xls"
            Case "4" ''In transit to EE
                fileName = fileName & "InTransitToEE.xls"
        End Select

        ''get data set
        Call BindGrid()

        ''export
        Call ExportToExcel(fileName, "", m_DataLayer.dsJobs.Tables(0))
    End Sub
#End Region


End Class

End Namespace
