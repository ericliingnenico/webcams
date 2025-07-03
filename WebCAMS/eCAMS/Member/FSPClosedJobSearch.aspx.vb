#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPClosedJobSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: FSPClosedJobSearch
'
' Description: 
'   FSP Closed Job Search Criteria page     
'----------------------------------------------------------------

Partial Class FSPClosedJobSearch
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

    ''Local Variable
#Region "Function"

    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        Me.PageTitle = "Closed Job Search"


        ''lblFormTitle.Text = "Search Closed Jobs"

        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()
        ''Set FSP Combox
        cboAssignedTo.DataSource = m_DataLayer.FSPChildren
        cboAssignedTo.DataTextField = "FSPDisplayName"
        cboAssignedTo.DataValueField = "FSPID"
        cboAssignedTo.DataBind()


        ''Set the selected AssginedTo
        If m_DataLayer.SelectedAssignedTo <> String.Empty Then
            Call ScrollToCboValue(cboAssignedTo, m_DataLayer.SelectedAssignedTo)
        End If

        ''Set PageSize Combox
        If m_DataLayer.SelectedPageSize > 0 Then
            Call ScrollToCboText(cboPageSize, m_DataLayer.SelectedPageSize.ToString)
        End If
        If m_DataLayer.SelectedFromDate > Convert.ToDateTime("1998-01-01") Then
            txtFromDate.text = m_DataLayer.SelectedFromDate.ToString("dd/MM/yy")
        Else
            txtFromDate.Text = Date.Now.ToString("dd/MM/yy")
        End If

        If m_DataLayer.SelectedToDate > Convert.ToDateTime("1998-01-01") Then
            txtToDate.Text = m_DataLayer.SelectedToDate.ToString("dd/MM/yy")
        Else
            txtToDate.Text = Date.Now.ToString("dd/MM/yy")
        End If


    End Sub
#End Region


#Region "Event"
    Private Sub btnSearch_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedAssignedTo = cboAssignedTo.SelectedItem.Value.ToString
        m_DataLayer.SelectedJobTypeForJobSearch = cboJobType.SelectedItem.Value.ToString
        m_DataLayer.SelectedFromDate = Convert.ToDateTime(txtFromDate.Text)
        m_DataLayer.SelectedToDate = Convert.ToDateTime(txtToDate.Text)
        m_DataLayer.SelectedPageSize = CType(cboPageSize.SelectedItem.Value, Integer)
        m_DataLayer.SelectedIDs = txtJobIDs.Text


        Call Response.Redirect("FSPClosedJobList.aspx")

    End Sub
#End Region

End Class

End Namespace
