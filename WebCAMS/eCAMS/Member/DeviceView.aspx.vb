'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/DeviceView.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.Drawing

Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: DeviceView
'
' Description: 
'   Device Details page
'----------------------------------------------------------------

Partial Class DeviceView
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
    Private m_Serial As String
    Private m_ClientID As String
    Private m_From As String

#Region "Functions"
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub
    '----------------------------------------------------------------
    ' GetContext:
    '   Get pass-in param, such as Query string, form hidden fields
    '----------------------------------------------------------------
    Protected Overrides Sub GetContext()
        With Request
            m_Serial = .QueryString("SN").Trim
            m_ClientID = .QueryString("CID").Trim
            m_From = .QueryString("From").Trim
        End With
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        Dim dlResult As DataLayerResult

        Me.PageTitle = "DeviceView"


        ''Set Info Label
        lblFormTitle.Text = "Details of Device [" & m_Serial & "]"
        ''Read data
        dlResult = m_DataLayer.GetDevice(m_ClientID, m_Serial, m_From)


        ''Fill in fields
        If dlResult = DataLayerResult.Success Then
            If m_DataLayer.dsDevice.Tables(0).Rows.Count > 0 Then
                With m_DataLayer.dsDevice.Tables(0).Rows(0)
                    ''Display device details
                    txtSerial.Value = clsTool.NullToValue(.Item("Serial").ToString, "")
                    txtMMDID.Value = clsTool.NullToValue(.Item("MMD_ID").ToString, "")
                    txtMaker.Value = clsTool.NullToValue(.Item("Maker").ToString, "")
                    txtModel.Value = clsTool.NullToValue(.Item("Model").ToString, "")
                    txtDevice.Value = clsTool.NullToValue(.Item("Device").ToString, "")
                    txtStatus.Value = clsTool.NullToValue(.Item("Status").ToString, "")
                    txtNote.Value = clsTool.NullToValue(.Item("Note").ToString, "")

                    ''Last Installed
                    txtTerminalID.Value = clsTool.NullToValue(.Item("TerminalID").ToString, "")
                    txtMerchantID.Value = clsTool.NullToValue(.Item("MerchantID").ToString, "")
                    txtName.Value = clsTool.NullToValue(.Item("Name").ToString, "")
                    txtDateIn.Value = clsTool.NullToValue(.Item("eqDateIn").ToString, "")
                    txtDateOut.Value = clsTool.NullToValue(.Item("eqDateOut").ToString, "")
                    ''Set DateIn Time Zone
                    If clsTool.NullToValue(.Item("DateInTimeZone").ToString, "") <> "" Then
                        lblDateInTimeZone.Text = lblDateInTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("DateInTimeZone").ToString, "")
                    End If
                    ''Set DateOut Time Zone
                    If clsTool.NullToValue(.Item("DateOutTimeZone").ToString, "") <> "" Then
                        lblDateOutTimeZone.Text = lblDateOutTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("DateOutTimeZone").ToString, "")
                    End If

                    ''Hide time zone info if no date value
                    If txtDateIn.Value = "" Then
                        lblDateInTimeZone.Visible = False
                    End If
                    If txtDateOut.Value = "" Then
                        lblDateOutTimeZone.Visible = False
                    End If

                End With
            Else
                lblFormTitle.Text = "Device [" & m_Serial & "] not found"
                lblFormTitle.ForeColor = Color.Red
            End If
        End If
    End Sub

#End Region
#Region "Event Handlers"
    Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        ''Set initial Focus
        Call SetFocus(txtSerial)

    End Sub

#End Region


End Class

End Namespace
