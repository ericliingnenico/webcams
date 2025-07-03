'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 24/02/14 13:58 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/DeviceSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: DeviceSearch
'
' Description: 
'   Device search criteria page
'----------------------------------------------------------------
Imports System.Text.RegularExpressions


Namespace eCAMS


Partial Class DeviceSearch
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

#Region "Functions"
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub
    Protected Overrides Sub AddClientScript()
        ''tie these textboxes to corresponding buttons
        TieButton(txtSerial, btnSearch)
    End Sub
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Device Search"

        ''lblFormTitle.Text = "Search Device"
        ''Set client Combox
        Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))
        ''Set the selected clientid
        If m_DataLayer.SelectedClientIDForDeviceSearch <> String.Empty Then
            Call ScrollToCboText(cboClientID, m_DataLayer.SelectedClientIDForDeviceSearch)
        End If
        ''Set PageSize Combox
        m_DataLayer.SelectedPageSize = 20
        If IsNumeric(m_DataLayer.SelectedPageSize) Then
            Call ScrollToCboText(cboPageSize, m_DataLayer.SelectedPageSize.ToString)
        End If

    End Sub
#End Region
#Region "Event Handlers"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        ''Set initial Focus
        Call SetFocus(txtSerial)
    End Sub


    Private Sub btnSearch_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        ''Store user's selections in Session
        m_DataLayer.SelectedClientIDForDeviceSearch = cboClientID.SelectedItem.Value.ToString
        m_DataLayer.SelectedSerialForDeviceSearch = txtSerial.Text.ToString.Trim.ToUpper
        m_DataLayer.SelectedPageSize = CType(cboPageSize.SelectedItem.Value, Integer)
        Call Response.Redirect(Request.RawUrl.Replace("DeviceSearch.aspx", "DeviceList.aspx"))
    End Sub

#End Region

End Class

End Namespace
