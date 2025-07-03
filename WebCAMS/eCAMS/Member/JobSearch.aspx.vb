#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/JobSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: JobSearch
'
' Description: 
'   Job Search Criteria page     
'----------------------------------------------------------------

Partial Class JobSearch
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

    Protected Overrides Sub GetContext()

        Dim vWhichJob As String
        With Request
            vWhichJob = .Item("WhichJob")
        End With
        Select Case vWhichJob.ToUpper
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
    End Sub
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Job Search"


        ''Set Info Label
        'Select Case m_DataLayer.SelectedJobTypeForJobSearch
        '    Case "INSTALL"
        '        lblFormTitle.Text = "Browse Installation Jobs"
        '    Case "DEINSTALL"
        '        lblFormTitle.Text = "Browse DeInstallation Jobs"
        '    Case "UPGRADE"
        '        lblFormTitle.Text = "Browse Upgrade Jobs"
        '    Case "CALL"
        '        lblFormTitle.Text = "Browse Swap Jobs"
        '    Case Else
        '        lblFormTitle.Text = ""

        'End Select
        ''Set client Combox
        Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))
        ''Set the selected clientid
        If m_DataLayer.SelectedClientIDForJobSearch <> String.Empty Then
            Call ScrollToCboText(cboClientID, m_DataLayer.SelectedClientIDForJobSearch)
        End If

        ''filter status
        m_DataLayer.CacheJobFilterStatus()

        If m_DataLayer.SelectedJobTypeForJobSearch = "CALL" Then
            cboStatus.DataSource = m_DataLayer.JobFilterStatus.Tables(1)
        Else
            cboStatus.DataSource = m_DataLayer.JobFilterStatus.Tables(0)

        End If

        cboStatus.DataTextField = "FilterStatus"
        cboStatus.DataValueField = "FilterStatusID"

        cboStatus.DataBind()


        ''Set Status Combox
        If m_DataLayer.SelectedStatusForJobSearch <> String.Empty Then
            Call ScrollToCboValue(cboStatus, m_DataLayer.SelectedStatusForJobSearch.ToString)
        End If


        ''state
        m_DataLayer.CacheStateWithAll()

        cboState.DataSource = m_DataLayer.StateWithAll.Tables(0)
        cboState.DataTextField = "State"
        cboState.DataValueField = "State"

        cboState.DataBind()

        ''Set State Combox
        If m_DataLayer.SelectedStateForJobSearch <> String.Empty Then
            Call ScrollToCboText(cboState, m_DataLayer.SelectedStateForJobSearch.ToString)
        End If


        ''Set PageSize Combox
        If m_DataLayer.SelectedPageSize > 0 Then
            Call ScrollToCboText(cboPageSize, m_DataLayer.SelectedPageSize.ToString)
        End If
    End Sub
#End Region


#Region "Event"

    Private Sub btnSearch_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedClientIDForJobSearch = cboClientID.SelectedItem.Value.ToString
        m_DataLayer.SelectedStatusForJobSearch = cboStatus.SelectedItem.Value.ToString
        m_DataLayer.SelectedStateForJobSearch = cboState.SelectedItem.Value.ToString
        m_DataLayer.SelectedPageSize = CType(cboPageSize.SelectedItem.Value, Integer)
        Call Response.Redirect(Request.RawUrl.Replace("JobSearch.aspx", "JobList.aspx"))

    End Sub
#End Region

End Class

End Namespace
