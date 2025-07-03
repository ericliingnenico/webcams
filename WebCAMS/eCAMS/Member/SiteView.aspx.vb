'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:51 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/SiteView.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.Data
Imports System.Data.SqlClient
Imports System.Drawing

Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: SiteView
'
' Description: 
'   Site Details page
'----------------------------------------------------------------

Partial Class SiteView
    Inherits MemberPopupBase

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
    Private m_ClientID, m_TerminalID As String

    '*************** Functions ***************
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    '----------------------------------------------------------------
    ' GetContext:
    '   Get pass-in param, such as Query string, form hidden fields
    '----------------------------------------------------------------
    Protected Overrides Sub GetContext()
        With Request
            m_ClientID = .QueryString("CID").Trim
            m_TerminalID = .QueryString("TID").Trim
        End With
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        Dim dlResult As DataLayerResult

        Me.PageTitle = "SiteView"

        ''Set Info Label
        lblFormTitle.Text = "Details of site [" & m_TerminalID & "]"
        ''Read data
        dlResult = m_DataLayer.GetSite(m_ClientID, m_TerminalID)

        ''Fill in fields
        If dlResult = DataLayerResult.Success Then
            If m_DataLayer.dsSite.Tables(0).Rows.Count > 0 Then
                With m_DataLayer.dsSite.Tables(0).Rows(0)

                    txtClientID.Value = clsTool.NullToValue(.Item("ClientID").ToString, "")
                    txtTerminalID.Value = clsTool.NullToValue(.Item("TerminalID").ToString, "")
                    txtMerchantID.Value = clsTool.NullToValue(.Item("MerchantID").ToString, "")
                    txtName.Value = clsTool.NullToValue(.Item("Name").ToString, "")
                    txtAddress1.Value = clsTool.NullToValue(.Item("Address").ToString, "")
                    txtAddress2.Value = clsTool.NullToValue(.Item("Address2").ToString, "")
                    txtCity.Value = clsTool.NullToValue(.Item("City").ToString, "")
                    txtState.Value = clsTool.NullToValue(.Item("State").ToString, "")
                    txtPostcode.Value = clsTool.NullToValue(.Item("Postcode").ToString, "")
                    txtContact.Value = clsTool.NullToValue(.Item("Contact").ToString, "")
                    txtPhone.Value = clsTool.NullToValue(.Item("Phone").ToString, "")
                    txtPhone2.Value = clsTool.NullToValue(.Item("Phone2").ToString, "")
                    txtBusinessActivity.Value = clsTool.NullToValue(.Item("BusinessActivity").ToString, "")
                    txtTradingHoursInfo.Value = clsTool.NullToValue(.Item("TradingHoursInfo").ToString, "")

                End With
            Else
                lblFormTitle.Text = "Site [" & m_TerminalID & "] not found"
                lblFormTitle.ForeColor = Color.Red
            End If
        End If
    End Sub

    '*************** Events Handlers ***************

    Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        ''Set initial Focus
        Call SetFocus(txtClientID)
    End Sub

End Class

End Namespace


