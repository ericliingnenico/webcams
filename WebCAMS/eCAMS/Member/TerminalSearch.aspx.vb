'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:51 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/TerminalSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: TerminalSearch
'
' Description: 
'   Terminal search criteria page
'----------------------------------------------------------------
Partial Class TerminalSearch
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
    '*************** Functions ***************
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    Protected Overrides Sub AddClientScript()
        ''tie these textboxes to corresponding buttons
        TieButton(txtTerminalID, btnSearch)
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Device Search"

        ''lblFormTitle.Text = "Search Terminal"
        ''Set client Combox
        Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))
        ''Set the selected clientid
        If m_DataLayer.SelectedClientIDForTerminalSearch <> String.Empty Then
            Call ScrollToCboText(cboClientID, m_DataLayer.SelectedClientIDForTerminalSearch)
        End If
        ''Set PageSize Combox
        If IsNumeric(m_DataLayer.SelectedPageSize) Then
            Call ScrollToCboText(cboPageSize, m_DataLayer.SelectedPageSize.ToString)
        End If

    End Sub


    '*************** Events Handlers ***************
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        ''Set initial Focus
        Call SetFocus(txtTerminalID)
    End Sub


    Private Sub btnSearch_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedClientIDForTerminalSearch = cboClientID.SelectedItem.Value.ToString
        m_DataLayer.SelectedTerminalIDForTerminalSearch = txtTerminalID.Text.ToString.Trim
        m_DataLayer.SelectedPageSize = CType(cboPageSize.SelectedItem.Value, Integer)

        Call Response.Redirect(Request.RawUrl.Replace("TerminalSearch.aspx", "TerminalList.aspx"))
    End Sub
End Class

End Namespace
