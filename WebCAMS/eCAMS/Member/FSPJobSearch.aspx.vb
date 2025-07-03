#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/02/14 10:57 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPJobSearch.aspx.vb $-->
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

Partial Class FSPJobSearch
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
        Me.PageTitle = "Job Search"

        ''Set Info Label
        ''lblFormTitle.Text = "Browse Jobs"

        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()
        ''Set FSP Combox
        cboAssignedTo.DataSource = m_DataLayer.FSPChildren
        cboAssignedTo.DataTextField = "FSPDisplayName"
        cboAssignedTo.DataValueField = "FSPID"
        cboAssignedTo.DataBind()

        'Call FillCboWithArray(cboAssignedTo, ("ALL," & m_DataLayer.CurrentUserInformation.ClientIDs).Split(CType(",", Char)))

        ''Set the selected AssginedTo
        If m_DataLayer.SelectedAssignedTo <> String.Empty Then
            Call ScrollToCboValue(cboAssignedTo, m_DataLayer.SelectedAssignedTo)
        End If
        If m_DataLayer.SelectedJobTypeForJobSearch <> String.Empty Then
            Call ScrollToCboValue(cboJobType, m_DataLayer.SelectedJobTypeForJobSearch)
        End If
        m_DataLayer.SelectedDueDate = String.Empty
        If m_DataLayer.SelectedDueDate <> String.Empty Then
            txtDueDate.Text = Convert.ToDateTime(m_DataLayer.SelectedDueDate).ToString("dd/MM/yy")
            chbIgnoreDueDate.Checked = False
        Else
            txtDueDate.Text = Date.Now.ToString("dd/MM/yy")
            chbIgnoreDueDate.Checked = True
        End If
        chbNoReservedDeviceOnly.Checked = m_DataLayer.SelectedNoDeviceReservedOnly
        chbIncludeChildDepot.Checked = m_DataLayer.SelectedIncludeChildDepot
        If chbIncludeChildDepot.Checked then
            chbIncludeChildDepot.BackColor = Drawing.Color.Yellow
        Else
            chbIncludeChildDepot.BackColor = Drawing.Color.White
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
    Protected Overrides Sub AddClientScript()
        ''tie these textboxes to corresponding buttons
        TieButton(txtJobIDs, btnSearch)

        ''add onclik to btnGetJob
        chbIncludeChildDepot.Attributes.Add("onclick", "ChangeCheckBoxBackColor('"+ chbIncludeChildDepot.ClientID + "','yellow','white');")
    End Sub
    
#End Region


#Region "Event"
    Private Sub btnSearch_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedAssignedTo = cboAssignedTo.SelectedItem.Value.ToString
        m_DataLayer.SelectedJobTypeForJobSearch = cboJobType.SelectedItem.Value.ToString
        m_DataLayer.SelectedDueDate = Convert.ToString(IIf(chbIgnoreDueDate.Checked, String.Empty, Convert.ToDateTime(txtDueDate.Text).ToString("yyyy-MM-dd")))
        m_DataLayer.SelectedNoDeviceReservedOnly = chbNoReservedDeviceOnly.Checked
        If m_DataLayer.SelectedNoDeviceReservedOnly Then
            m_DataLayer.SelectedJobTypeForJobSearch = "UPGRADE"
        End If
        m_DataLayer.SelectedProjectNo = txtProjectNo.Text
        m_DataLayer.SelectedSuburb = txtSuburb.Text
        m_DataLayer.SelectedPostcode = txtPostcode.Text
        m_DataLayer.SelectedPageSize = CType(cboPageSize.SelectedItem.Value, Integer)
        m_DataLayer.SelectedRefreshSecond = CType(cboRefreshMinute.SelectedItem.Value, Int32) * 60  ''convert to second
        m_DataLayer.SelectedIncludeChildDepot = chbIncludeChildDepot.Checked
        m_DataLayer.SelectedIDs = txtJobIDs.Text

        Call Response.Redirect(Request.RawUrl.Replace("FSPJobSearch.aspx", "FSPJobList.aspx"))

    End Sub
#End Region

End Class

End Namespace
