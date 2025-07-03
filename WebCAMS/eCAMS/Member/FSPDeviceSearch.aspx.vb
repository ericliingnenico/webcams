#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPDeviceSearch.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On


Namespace eCAMS

Partial Class FSPDeviceSearch
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

    Protected Overrides Sub GetContext()
        With Request

        End With
    End Sub

    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    Private Sub SetDE()
        ''Page Title
        Me.PageTitle = "FSP Device Search"

        ''lblFormTitle.Text = "FSP Device Search"

        If IsNumeric(m_DataLayer.SelectedPageSize) Then
            Call ScrollToCboText(cboPageSize, m_DataLayer.SelectedPageSize.ToString)
        End If
    End Sub
#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        ''Put your code here
        Call SetFocus(txtSerial)
        Call TieButton(txtSerial, btnSearch)
    End Sub
    Private Sub btnSearch_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.ServerClick
        m_DataLayer.SelectedPageSize = Convert.ToInt32(cboPageSize.SelectedValue)
        m_DataLayer.SelectedSerialForDeviceSearch = txtSerial.Text.ToUpper
        Call Response.Redirect(Request.RawUrl.Replace("FSPDeviceSearch.aspx", "FSPDeviceList.aspx"))
    End Sub
#End Region
End Class

End Namespace
