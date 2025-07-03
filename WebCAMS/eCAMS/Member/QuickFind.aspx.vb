'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/QuickFind.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: QuickFind
'
' Description: 
'   Quick find Criteria page     
'----------------------------------------------------------------
Partial Class QuickFind
    Inherits MemberPageBase

    Protected WithEvents TerminalID As System.Web.UI.WebControls.RequiredFieldValidator
    Protected WithEvents Submit1 As System.Web.UI.HtmlControls.HtmlInputButton

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

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Quick Find"

        ''set title
        ''lblFormTitle.Text = "Quick Find"
        ''Set client Combox
        Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))
        ''Set the selected clientid
        If m_DataLayer.SelectedClientIDForQuickFind <> String.Empty Then
            Call ScrollToCboText(cboClientID, m_DataLayer.SelectedClientIDForQuickFind)
        End If
        ''Set Scope
        If m_DataLayer.SelectedScopeForQuickFind <> String.Empty Then
            Call SelectRadioButtonListValue(rblScope, m_DataLayer.SelectedScopeForQuickFind)
        End If
    End Sub

    '*************** Events Handlers ***************
    Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        SetFocus(txtTerminalID)
        TieButton(txtTerminalID, btnFindTerminalID)
        TieButton(txtMerchantID, btnFindMerchantID)
        TieButton(txtProblemNumber, btnFindProblemNumber)
            TieButton(txtJobID, btnFindJobID)
            TieButton(txtCustomerNumber, btnFindCustomerNumber)
        End Sub


    Private Sub btnFindTerminalID_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnFindTerminalID.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedClientIDForQuickFind = cboClientID.SelectedItem.Value.ToString
        m_DataLayer.SelectedScopeForQuickFind = rblScope.SelectedItem.Value.ToString
        m_DataLayer.SelectedTerminalIDForQuickFind = txtTerminalID.Text.ToString.Trim
        m_DataLayer.SelectedMerchantIDForQuickFind = ""
        m_DataLayer.SelectedProblemNumberForQuickFind = ""
            m_DataLayer.SelectedJobIDForQuickFind = ""
            m_DataLayer.SelectedCustomerNumberForQuickFind = ""

            m_DataLayer.SelectedPageSize = 20
        Call Response.Redirect(Request.RawUrl.Replace("QuickFind.aspx", "QuickFindList.aspx"))
    End Sub

    Private Sub btnFindMerchantID_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnFindMerchantID.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedClientIDForQuickFind = cboClientID.SelectedItem.Value.ToString
        m_DataLayer.SelectedScopeForQuickFind = rblScope.SelectedItem.Value.ToString
        m_DataLayer.SelectedTerminalIDForQuickFind = ""
        m_DataLayer.SelectedMerchantIDForQuickFind = txtMerchantID.Text.ToString.Trim
        m_DataLayer.SelectedProblemNumberForQuickFind = ""
            m_DataLayer.SelectedJobIDForQuickFind = ""
            m_DataLayer.SelectedCustomerNumberForQuickFind = ""

            m_DataLayer.SelectedPageSize = 20
        Call Response.Redirect(Request.RawUrl.Replace("QuickFind.aspx", "QuickFindList.aspx"))

    End Sub

    Private Sub btnFindProblemNumber_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnFindProblemNumber.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedClientIDForQuickFind = cboClientID.SelectedItem.Value.ToString
        m_DataLayer.SelectedScopeForQuickFind = rblScope.SelectedItem.Value.ToString
        m_DataLayer.SelectedTerminalIDForQuickFind = ""
        m_DataLayer.SelectedMerchantIDForQuickFind = ""
        m_DataLayer.SelectedProblemNumberForQuickFind = txtProblemNumber.Text.ToString.Trim
            m_DataLayer.SelectedJobIDForQuickFind = ""
            m_DataLayer.SelectedCustomerNumberForQuickFind = ""

            m_DataLayer.SelectedPageSize = 20

        Call Response.Redirect(Request.RawUrl.Replace("QuickFind.aspx", "QuickFindList.aspx"))

    End Sub

    Protected Sub btnFindJobID_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFindJobID.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedClientIDForQuickFind = cboClientID.SelectedItem.Value.ToString
        m_DataLayer.SelectedScopeForQuickFind = rblScope.SelectedItem.Value.ToString
        m_DataLayer.SelectedTerminalIDForQuickFind = ""
        m_DataLayer.SelectedMerchantIDForQuickFind = ""
        m_DataLayer.SelectedProblemNumberForQuickFind = ""
            m_DataLayer.SelectedJobIDForQuickFind = txtJobID.Text.ToString.Trim
            m_DataLayer.SelectedCustomerNumberForQuickFind = ""

            m_DataLayer.SelectedPageSize = 20

        Call Response.Redirect(Request.RawUrl.Replace("QuickFind.aspx", "QuickFindList.aspx"))
    End Sub

        Private Sub btnFindCustomerNumber_ServerClick(sender As Object, e As EventArgs) Handles btnFindCustomerNumber.ServerClick
            ''Store user's selections in Session
            m_DataLayer.SelectedClientIDForQuickFind = cboClientID.SelectedItem.Value.ToString
            m_DataLayer.SelectedScopeForQuickFind = rblScope.SelectedItem.Value.ToString
            m_DataLayer.SelectedTerminalIDForQuickFind = ""
            m_DataLayer.SelectedMerchantIDForQuickFind = ""
            m_DataLayer.SelectedProblemNumberForQuickFind = ""
            m_DataLayer.SelectedJobIDForQuickFind = ""
            m_DataLayer.SelectedCustomerNumberForQuickFind = txtCustomerNumber.Text.ToString.Trim

            m_DataLayer.SelectedPageSize = 20

            Call Response.Redirect(Request.RawUrl.Replace("QuickFind.aspx", "QuickFindList.aspx"))
        End Sub
    End Class

End Namespace
