#Region "vss"
'<!--$$Revision: 8 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/02/14 10:57 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPJobList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing

Namespace eCAMS
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: mpFSPJobList
'
' Description: 
'   FSP Open Job List - PDA portal
'----------------------------------------------------------------
Partial Class mpFSPJobList
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
        If m_DataLayer.GetBulletin("", 1) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                Response.Redirect("mpBulletin.aspx")
        End If
        Call SetDE()
        Call BindGrid()
    End Sub

    Protected Overrides Sub GetContext()
        ''clean previous caching sort order, on the first page request
        m_DataLayer.SelectedSortOrder = ""

        ''get sortorder if there is cookie
        If Not HttpContext.Current.Request.Cookies("pcams.joblist.order") is Nothing then
            m_DataLayer.SelectedSortOrder = HttpContext.Current.Request.Cookies("pcams.joblist.order").Value
            ScrollToCboValue(cboSort, m_DataLayer.SelectedSortOrder)
        End If

    End Sub
    Private Sub SetDE()
        Me.PageTitle = "Job List"
    End Sub
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet
        Dim dv As DataView

        If  not m_DataLayer.CurrentUserInformation.CanUseNewPCAMS then
            Response.Redirect("pFSPMain.aspx")
            Return
        End If

        dlResult = m_DataLayer.GetFSPAllOpenJob(m_DataLayer.SelectedAssignedTo, 2, "", "", False, "", "", "",False, "")
        If dlResult = DataLayerResult.Success Then
            If m_DataLayer.dsJobs.Tables(0).Rows.Count >0 then
                ds = m_DataLayer.dsJobs

                ''if datacolumn doesn't contain the sort column, set sortcolumn to empty
                If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not ds.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder) Then
                    m_DataLayer.SelectedSortOrder = String.Empty
                End If

                If ds.Tables(0).Rows.Count >= 0 Then
                    lblListInfo.Text = "Total Jobs: " & ds.Tables(0).Rows.Count.ToString 
                End If
                'bind grid
                Try
                    ''using dataview for sorting on column purpose
                    dv = New DataView(ds.Tables(0))
                    If m_DataLayer.SelectedSortOrder <> String.Empty Then
                        dv.Sort = m_DataLayer.SelectedSortOrder
                    End If
                    Repeater1.DataSource = dv
                    Repeater1.DataBind()
                Catch exc As Exception
                    lblListInfo.Text = exc.Message
                    lblListInfo.ForeColor = Color.Red
                Finally
                End Try

            Else
                panelJobList.Visible = False
                lblListInfo.Text = "No Job"
                lblListInfo.ForeColor = Color.Red
            End If

        End If

    End Sub
#End Region

#Region "Event"
    'Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
    '    Call m_DataLayer.VerifyLogin()
    '    grdJob.CurrentPageIndex = e.NewPageIndex
    '    Call BindGrid()
    'End Sub

    Private Sub cboSort_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cboSort.SelectedIndexChanged
        If m_DataLayer.SelectedSortOrder <> cboSort.SelectedValue Then
            m_DataLayer.SelectedSortOrder = cboSort.SelectedValue
            Call BindGrid()

            ''save the new sortorder
            Dim cookie As new HttpCookie("pcams.joblist.order")  ''pcams.login
            cookie.Value = m_DataLayer.SelectedSortOrder
            cookie.Expires = DateTime.Now.AddDays(90)
            HttpContext.Current.Response.Cookies.Add(cookie)

            
        End If
    End Sub

#End Region


End Class

End Namespace
