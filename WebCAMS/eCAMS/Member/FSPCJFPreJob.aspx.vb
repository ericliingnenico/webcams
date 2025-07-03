#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPCJFPreJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing
Namespace eCAMS

Partial Class FSPCJFPreJob
    Inherits MemberPageBase
#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub
    Protected WithEvents DataGrid1 As System.Web.UI.WebControls.DataGrid


    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region

#Region "Function"
    Protected Overrides Sub GetContext()
        Dim service As String
        Dim fileName As String
        Dim cjfID As String

        With Request
            service = .Item("svr")
            fileName = .Item("file")
            cjfID = .Item("id")
        End With

        If Not service Is Nothing AndAlso service.ToUpper = "DOWNLOAD" Then
            Call DownloadFile(CInt(cjfID), fileName)
        End If
    End Sub

    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    Private Sub SetDE()
        Me.RestrictModuleName = "FSPCJF"
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        Dim dv As DataView
        'Set PageSize to Grid
        grdJob.PageSize = 400

        dlResult = m_DataLayer.GetFSPCJFPreJob
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

    Private Sub DownloadFile(ByVal pCJFID As Integer, ByVal pCJFFileName As String)
        If m_DataLayer.GetFSPCJFJob(pCJFID) = DataLayerResult.Success Then
            Call ExportToExcel(pCJFFileName, "", m_DataLayer.dsJobs.Tables(0))
        End If
    End Sub
#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        Me.PageTitle = "FSP CJF PreJob List"
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

    Private Sub btnGenerateCJF_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnGenerateCJF.ServerClick
        ''get selection
        Dim logIDs As String
        logIDs = Request.Item("chkBulk")

        If logIDs.Trim.Length > 0 Then
            ''generate CJF file
            Dim cjfFileName As String
            cjfFileName = "CJF-" + Convert.ToString(m_DataLayer.CurrentUserInformation.FSPID) + "-" + Date.Now.ToString("yyyyMMdd-hhmmss.\x\l\s")

            Dim cjfID As Integer
            If m_DataLayer.GenerateFSPCJF(cjfFileName, logIDs, cjfID) = DataLayerResult.Success Then
                ''export to excel
                ''Call DownloadFile(cjfID, cjfFileName)
                PanelGrid.Visible = False
                PanelResult.Visible = True
                lblAcknowledge.Text = "CJF file (<b>" & cjfFileName & "</b>) has been generated successfully. <br><br> " & _
                    "To download the file, click <b><A HREF='../member/FSPCJFPreJob.aspx?svr=download&file=" & Server.UrlEncode(cjfFileName) & "&id=" & cjfID.ToString & "'>here</A></b>"
            End If
        End If
    End Sub

#End Region

End Class

End Namespace
