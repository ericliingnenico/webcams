#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPTaskSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Namespace eCAMS

Partial Class FSPTaskSearch
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
    End Sub
    Private Sub SetDE()
        Me.PageTitle = "Task Search"

        ''Set Info Label
        ''lblFormTitle.Text = "Browse Tasks"

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

        ''set refresh combo
        If m_DataLayer.SelectedRefreshSecond >= 0 Then
            Call ScrollToCboText(cboRefreshMinute, Convert.ToString(m_DataLayer.SelectedRefreshSecond / 60))
        Else
            Call ScrollToCboText(cboRefreshMinute, "NIL")
        End If
    End Sub

#End Region

#Region "Event"
    Private Sub btnSearch_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedAssignedTo = cboAssignedTo.SelectedItem.Value.ToString
        m_DataLayer.SelectedPageSize = CType(cboPageSize.SelectedItem.Value, Integer)
        m_DataLayer.SelectedRefreshSecond = CType(cboRefreshMinute.SelectedItem.Value, Int32) * 60  ''convert to second
        Call Response.Redirect("FSPTaskList.aspx")

    End Sub
#End Region

End Class

End Namespace
