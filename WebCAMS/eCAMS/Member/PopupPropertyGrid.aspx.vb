#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/PopupPropertyGrid.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data

Namespace eCAMS

Partial Class PopupPropertyGrid
    Inherits MemberPopupBase
    Dim caseID As Int16
    Dim jobID As Int64
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
            ''store in datalayer context
            caseID = Convert.ToInt16(.Item("case"))
            jobID = Convert.ToInt64(.Item("jid"))
        End With
    End Sub

    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    Private Sub SetDE()
        Me.PageTitle = "PropertyGrid"
    End Sub

    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet

        ''get dataset by case
        ''case 1: Task
        Select Case caseID
            Case 1 ''task
                dlResult = m_DataLayer.GetFSPTaskView(Convert.ToInt32(jobID))
                ds = m_DataLayer.dsJob
        End Select

        If dlResult = DataLayerResult.Success Then
            Try
                ''reshape the dataset
                ds = ReshapeDataSet(ds)

                ''set grid pagesize to ds.tables(0).rows.count
                grdJob.PageSize = ds.Tables(0).Rows.Count

                ''bind grid
                grdJob.DataSource = ds.Tables(0).DefaultView
                grdJob.DataBind()
            Catch ex As Exception
                lblListInfo.Text = ex.Message
            End Try
        End If
    End Sub

    Public Function ReshapeDataSet(ByVal ds As DataSet) As DataSet
        Dim newDS As New DataSet
        newDS.Tables.Add()
        ''Create Two Columns with names "ColumnName" and "Value" 
        ''ColumnName -> Displays all ColumnNames 
        ''Value -> Displays ColumnData 
        newDS.Tables(0).Columns.Add("ColumnName")
        newDS.Tables(0).Columns.Add("Value")
        ''Dim dr As DataRow
        For Each dr As DataRow In ds.Tables(0).Rows
            For Each dc As DataColumn In ds.Tables(0).Columns
                ''declare array
                Dim myArray() As String = {dc.ColumnName.ToString, dr(dc.ColumnName.ToString).ToString}
                newDS.Tables(0).Rows.Add(myArray)
            Next
        Next
        Return newDS
    End Function
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
