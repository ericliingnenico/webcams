'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/CallView.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On

Imports System.Drawing
Imports eCAMS.AuthWS

Namespace eCAMS

    '----------------------------------------------------------------
    ' Namespace: eCAMS
    ' Class: CallView
    '
    ' Description: 
    '   Call Details page
    '----------------------------------------------------------------

    Partial Class CallView
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
        Private m_CallNumber As String
        Private m_AssignedTo As Integer
        Protected m_IsOpenJob As Boolean
        Protected m_ExpandJobNote As Boolean = False
        Protected m_NoteSortOrderAsc As Boolean
        Protected m_IsNotTYRMerchant As Boolean
        Protected Overrides Sub Process()
            Call SetDE()
        End Sub

        '----------------------------------------------------------------
        ' GetContext:
        '   Get pass-in param, such as Query string, form hidden fields
        '----------------------------------------------------------------
        Protected Overrides Sub GetContext()
            With Request
                m_CallNumber = .QueryString("CNO").Trim
                If Not .QueryString("XN") Is Nothing AndAlso .QueryString("XN").Trim = "1" Then
                    m_ExpandJobNote = True
                End If

                If String.IsNullOrEmpty(.QueryString("NoteSortAsc")) Then
                    m_NoteSortOrderAsc = False
                Else
                    m_NoteSortOrderAsc = CType(.QueryString("NoteSortAsc").Trim, Boolean)
                End If
            End With

            If m_NoteSortOrderAsc Then
                lnkBtnNoteSortOder.Text = "Desc Order"
            Else
                lnkBtnNoteSortOder.Text = "Asc Order"
            End If
        End Sub

        '----------------------------------------------------------------
        ' SetDE:
        '   Set data entry fields for this page
        '----------------------------------------------------------------
        Private Sub SetDE()
            Dim dlResult As DataLayerResult

            Me.PageTitle = "CallView"

            ' returns Menu_Client_TYR_Merchant_Read
            m_IsNotTYRMerchant = True
            Dim menuSet As String = CStr(CType(Session("UserInfo"), UserInformation).MenuSet)
            If (menuSet = "Menu_Client_TYR_Merchant_Read") Then
                m_IsNotTYRMerchant = False
            End If

            ''Set Info Label
            lblFormTitle.Text = "Details of Job [" & m_CallNumber & "]"
            ''Read data
            dlResult = m_DataLayer.GetCall(m_CallNumber)


            ''Fill in fields
            If dlResult = DataLayerResult.Success Then
                If m_DataLayer.dsCall.Tables(0).Rows.Count > 0 Then
                    With m_DataLayer.dsCall.Tables(0).Rows(0)
                        txtSource.Value = clsTool.NullToValue(.Item("Source").ToString, "")
                        txtJobType.Value = clsTool.NullToValue(.Item("JobType").ToString, "")
                        txtCallNumber.Value = clsTool.NullToValue(.Item("CallNumber").ToString, "")
                        txtTerminalID.Value = clsTool.NullToValue(.Item("TerminalID").ToString, "")
                        If clsTool.NullToValue(.Item("ClientID").ToString, "") = "CBA" Then
                            panelCAIC.Visible = True
                            txtCAIC.Value = clsTool.NullToValue(.Item("CAIC").ToString, "")
                        End If
                        txtMerchantID.Value = clsTool.NullToValue(.Item("MerchantID").ToString, "")
                        txtMerchantName.Text = clsTool.NullToValue(.Item("MerchantName").ToString, "")
                        txtDeviceType.Value = clsTool.NullToValue(.Item("DeviceType").ToString, "")
                        txtFault.Value = clsTool.NullToValue(.Item("Fault").ToString, "")

                        txtLoggedDateTime.Value = clsTool.NullToValue(.Item("LoggedDateTime").ToString, "")
                        ''Set LoggedDateTime TimeZone Text. It is EE System Time Zone.
                        If clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "") <> "" Then
                            lblLoggedTimeZone.Text = lblLoggedTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "")
                        End If
                        txtStatusNote.Value = clsTool.NullToValue(.Item("StatusNote").ToString, "")
                        txtSpecialInstruction.Value = clsTool.NullToValue(.Item("SpecialInstruction").ToString, "")
                        txtJobNote.Text = CommonUtil.SortJobNote(clsTool.NullToValue(.Item("JobNote").ToString, ""), m_NoteSortOrderAsc)
                        txtTradingHours.Value = clsTool.NullToValue(.Item("TradingHours").ToString, "")
                        txtSwapComponent.Value = clsTool.NullToValue(.Item("SwapComponent").ToString, "")
                        txtProblemNumber.Value = clsTool.NullToValue(.Item("ProblemNumber").ToString, "")
                        txtRegion.Value = clsTool.NullToValue(.Item("Region").ToString, "")
                        m_AssignedTo = 0
                        txtDeliveryService.Value = ""
                        panelDeliveryService.Visible = (clsTool.NullToValue(.Item("ClientID").ToString, "") = "NAB") Or (clsTool.NullToValue(.Item("ClientID").ToString, "") = "HIC")
                        If (panelDeliveryService.Visible) Then
                            If Len(clsTool.NullToValue(.Item("AssignedTo").ToString, "")) > 0 Then
                                m_AssignedTo = Convert.ToInt32(.Item("AssignedTo"))
                                If (m_AssignedTo = 328) Or
                                  (m_AssignedTo = 329) Or
                                  (m_AssignedTo = 999) Or
                                  (m_AssignedTo = 3078) Then
                                    txtDeliveryService.Value = "SATCHEL"
                                Else
                                    txtDeliveryService.Value = "TECH"
                                End If
                            End If
                        End If
                        txtLoggedBy.Value = clsTool.NullToValue(.Item("LoggedBy").ToString, "")
                        ''Check the swap job source - Open/Closed
                        m_IsOpenJob = (clsTool.NullToValue(.Item("Source").ToString, "") = "OPEN")
                        If m_IsOpenJob Then
                            txtSLA.Value = clsTool.NullToValue(.Item("SLA").ToString, "")
                            ''Set SLA TimeZone Text
                            If clsTool.NullToValue(.Item("SLATimeZone").ToString, "") <> "" Then
                                lblSLATimeZone.Text = lblSLATimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("SLATimeZone").ToString, "")
                            End If
                            txtStatus.Value = clsTool.NullToValue(.Item("Status").ToString, "")
                            ''only show update job info on open jobs and there is UpdateInfo setup at DB
                            If Convert.ToBoolean(.Item("CanUpdateJobInfo")) Then
                                SearchAgainURL.NavigateUrl = "UpdateJobInfo.aspx?JID=" + clsTool.NullToValue(.Item("CallNumber").ToString, "")
                                If (menuSet = "Menu_Client_TYR_Merchant_Read") Then
                                    SearchAgainURL.Visible = False
                                Else
                                    SearchAgainURL.Visible = True
                                End If
                            End If
                        Else
                            ''Only the closed swap jobs having Fix
                            txtFix.Value = clsTool.NullToValue(.Item("Fix").ToString, "")
                            txtClosedDateTime.Value = clsTool.NullToValue(.Item("ClosedDateTime").ToString, "")
                            If clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "") <> "" And clsTool.NullToValue(.Item("ClosedDateTime").ToString, "") <> "" Then
                                lblClosedDateTimeZone.Text = lblClosedDateTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "")
                            End If
                            txtOnSiteDateTime.Value = clsTool.NullToValue(.Item("OnSiteDateTime").ToString, "")
                            If clsTool.NullToValue(.Item("OnSiteTimeZone").ToString, "") <> "" Then
                                lblOnSiteTimeZone.Text = lblOnSiteTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("OnSiteTimeZone").ToString, "")
                            End If
                        End If
                    End With
                Else
                    lblFormTitle.Text = "Job [" & m_CallNumber & "] not found"
                    lblFormTitle.ForeColor = Color.Red
                End If
            End If
        End Sub

        '*************** Events Handlers ***************
        Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
            MyBase.Page_Load(sender, e)

            If m_ExpandJobNote Then
                Call SetFocus(txtJobNote)
            Else
                Call SetFocus(txtCallNumber)
            End If

        End Sub

        Protected Sub lnkBtnNoteSortOrder_Click(sender As Object, e As EventArgs) Handles lnkBtnNoteSortOder.Click

            If lnkBtnNoteSortOder.Text = "Asc Order" Then
                m_NoteSortOrderAsc = True
            Else
                m_NoteSortOrderAsc = False
            End If


            Dim sUrl As String = HttpContext.Current.Request.Url.ToString()

            If String.IsNullOrEmpty(Request.QueryString("NoteSortAsc")) Then
                Response.Redirect(sUrl + "&NoteSortAsc=" & m_NoteSortOrderAsc, True)
            Else
                Dim sCurrentValue = Request.QueryString("NoteSortAsc")
                sUrl = sUrl.Replace("&NoteSortAsc=" + sCurrentValue, "&NoteSortAsc=" + m_NoteSortOrderAsc.ToString())
                Response.Redirect(sUrl, True)
            End If
        End Sub
    End Class

End Namespace


