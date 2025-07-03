'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/11/12 15:02 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/JobView.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.Drawing
Imports eCAMS.AuthWS

Namespace eCAMS

    '----------------------------------------------------------------
    ' Namespace: eCAMS
    ' Class: JobView
    '
    ' Description: 
    '   Job Details page
    '----------------------------------------------------------------
    Partial Class JobView
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
        Private m_JobID As Integer
        Private m_BookedInstaller As Integer
        Protected m_IsOpenJob As Boolean
        Protected m_IsInstallUpgradeJob As Boolean
        Protected m_IsCloseable As Boolean
        Protected m_UserCanCloseJobs As Boolean
        Protected m_ClosureSuccess As Boolean
        Protected m_NoteSortOrderAsc As Boolean
        Protected m_IsNotTYRMerchant As Boolean

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
                m_JobID = CType(.QueryString("JID").Trim, Integer)
                If String.IsNullOrEmpty(.QueryString("NoteSortAsc")) Then
                    m_NoteSortOrderAsc = True 'set initial value
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

            Me.PageTitle = "JobView"

            ' returns Menu_Client_TYR_Merchant_Read
            m_IsNotTYRMerchant = True
            Dim menuSet As String = CStr(CType(Session("UserInfo"), UserInformation).MenuSet)
            If (menuSet = "Menu_Client_TYR_Merchant_Read") Then
                m_IsNotTYRMerchant = False
            End If

            ''Set Info Label
            lblFormTitle.Text = "Details of Job [" & m_JobID & "]"
            ''Read data
            dlResult = m_DataLayer.GetJob(m_JobID)

            ''Fill in fields
            If dlResult = DataLayerResult.Success Then
                ''Display the job only having data
                If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                    With m_DataLayer.dsJob.Tables(0).Rows(0)
                        txtSource.Value = clsTool.NullToValue(.Item("Source").ToString, "")
                        txtJobID.Value = clsTool.NullToValue(.Item("JobID").ToString, "")
                        txtJobType.Value = clsTool.NullToValue(.Item("JobType").ToString, "")
                        txtJobMethod.Value = clsTool.NullToValue(.Item("JobMethod").ToString, "")
                        txtDeviceType.Value = clsTool.NullToValue(.Item("DeviceType").ToString, "")
                        txtProblemNumber.Value = clsTool.NullToValue(.Item("ProblemNumber").ToString, "")
                        txtTerminalID.Value = clsTool.NullToValue(.Item("TerminalID").ToString, "")
                        txtCAIC.Value = clsTool.NullToValue(.Item("CAIC").ToString, "")
                        If clsTool.NullToValue(.Item("ConNote").ToString, "") <> "" Then
                            'txtConnote.Value = clsTool.NullToValue(.Item("ConNote").ToString, "")

                            txtConnoteHyperLink.Text = clsTool.NullToValue(.Item("ConNote").ToString, "")
                            txtConnoteHyperLink.NavigateUrl = "https://msto.startrack.com.au/track-trace/?id=" + clsTool.NullToValue(.Item("ConNote").ToString, "")

                        Else
                            txtConnoteHyperLink.Text = "n/a"

                        End If
                        txtMerchantID.Value = clsTool.NullToValue(.Item("MerchantID").ToString, "")
                        txtMerchantName.Text = clsTool.NullToValue(.Item("MerchantName").ToString, "")

                        txtLoggedDateTime.Value = clsTool.NullToValue(.Item("LoggedDateTime").ToString, "")
                        ''Set Logged TimeZone Text. It is EE System Time Zone.
                        If clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "") <> "" Then
                            lblLoggedTimeZone.Text = lblLoggedTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "")
                        End If
                        txtStatusNote.Value = clsTool.NullToValue(.Item("StatusNote").ToString, "")
                        txtDelayReason.Value = clsTool.NullToValue(.Item("DelayReason").ToString, "")
                        txtSpecialInstruction.Value = clsTool.NullToValue(.Item("SpecialInstruction").ToString, "")
                        txtJobNote.Text = CommonUtil.SortJobNote(Server.HtmlDecode(clsTool.NullToValue(.Item("JobNote").ToString, "")), m_NoteSortOrderAsc)
                        txtTradingHours.Value = clsTool.NullToValue(.Item("TradingHours").ToString, "")
                        txtProblemNumber.Value = clsTool.NullToValue(.Item("ProblemNumber").ToString, "")
                        txtRegion.Value = clsTool.NullToValue(.Item("Region").ToString, "")
                        m_BookedInstaller = 0
                        txtDeliveryService.Value = ""
                        panelDeliveryService.Visible = (clsTool.NullToValue(.Item("ClientID").ToString, "") = "NAB") Or (clsTool.NullToValue(.Item("ClientID").ToString, "") = "HIC")
                        If (panelDeliveryService.Visible) Then
                            If Len(clsTool.NullToValue(.Item("BookedInstaller").ToString, "")) > 0 Then
                                m_BookedInstaller = Convert.ToInt32(.Item("BookedInstaller"))

                                If (m_BookedInstaller = 328) Or
                  (m_BookedInstaller = 329) Or
                  (m_BookedInstaller = 999) Or
                  (m_BookedInstaller = 3078) Then
                                    txtDeliveryService.Value = "SATCHEL"
                                Else
                                    txtDeliveryService.Value = "TECH"
                                End If

                            End If
                        End If

                        txtLoggedBy.Value = clsTool.NullToValue(.Item("LoggedBy").ToString, "")

                        If (clsTool.NullToValue(.Item("ClientID").ToString, "") = "FDM") Or
              (clsTool.NullToValue(.Item("ClientID").ToString, "") = "PCT") Or
              (clsTool.NullToValue(.Item("ClientID").ToString, "") = "WIR") Or
              (clsTool.NullToValue(.Item("ClientID").ToString, "") = "JPM") Or
              (clsTool.NullToValue(.Item("ClientID").ToString, "") = "MMS") Or
              (clsTool.NullToValue(.Item("ClientID").ToString, "") = "CAL") Then
                            panelFDIAdditionalInfo.Visible = True
                            txtCustomerNumber.Value = clsTool.NullToValue(.Item("CustomerNumber").ToString, "")
                        End If

                        m_IsOpenJob = (clsTool.NullToValue(.Item("Source").ToString, "") = "OPEN")
                        m_IsInstallUpgradeJob = (clsTool.NullToValue(.Item("JobType").ToString, "") = "INSTALL" Or clsTool.NullToValue(.Item("JobType").ToString, "") = "UPGRADE")

                        If m_IsOpenJob Then
                            txtSLA.Value = clsTool.NullToValue(.Item("SLA").ToString, "")
                            ''Set SLA TimeZone Text
                            If clsTool.NullToValue(.Item("SLATimeZone").ToString, "") <> "" Then
                                lblSLATimeZone.Text = lblSLATimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("SLATimeZone").ToString, "")
                            End If

                            txtStatus.Value = clsTool.NullToValue(.Item("Status").ToString, "")
                            ''Hide Fix text for open jobs
                            txtFix.Visible = False
                            lblFix.Visible = False

                            ''only show update job info on open jobs and there is UpdateInfo setup at DB
                            If Convert.ToBoolean(.Item("CanUpdateJobInfo")) Then
                                SearchAgainURL.NavigateUrl = "UpdateJobInfo.aspx?JID=" + clsTool.NullToValue(.Item("JobID").ToString, "")

                                If (menuSet = "Menu_Client_TYR_Merchant_Read") Then
                                    SearchAgainURL.Visible = False
                                Else
                                    SearchAgainURL.Visible = True
                                End If
                            End If

                        Else
                            txtFix.Value = clsTool.NullToValue(.Item("Fix").ToString, "")
                            txtCloseComment.Value = clsTool.NullToValue(.Item("CloseComment").ToString, "")
                            txtClosedDateTime.Value = clsTool.NullToValue(.Item("ClosedDateTime").ToString, "")
                            If clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "") <> "" And clsTool.NullToValue(.Item("ClosedDateTime").ToString, "") <> "" Then
                                lblClosedDateTimeZone.Text = lblClosedDateTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("LoggedTimeZone").ToString, "")
                            End If
                            txtOnSiteDateTime.Value = clsTool.NullToValue(.Item("OnSiteDateTime").ToString, "")
                            ''Set OnSite TimeZone Text
                            If clsTool.NullToValue(.Item("OnSiteTimeZone").ToString, "") <> "" Then
                                lblOnSiteTimeZone.Text = lblOnSiteTimeZone.Text & ". TimeZone: " & clsTool.NullToValue(.Item("OnSiteTimeZone").ToString, "")
                            End If
                        End If

                        txtClientID.Value = .Item("ClientID").ToString()
                        m_IsCloseable = Convert.ToBoolean(.Item("IsCloseable"))

                        If m_DataLayer.CurrentUserInformation.ModuleList.ToUpper.IndexOf("," & "CLOSEDEINSTALLJOB" & ",") > -1 Then
                            m_UserCanCloseJobs = m_IsOpenJob And txtJobType.Value = "DEINSTALL"
                        End If

                        If m_IsCloseable And m_UserCanCloseJobs Then
                            cboFixID.Items.Add(New ListItem("Complete", "1"))
                            cboFixID.Items.Add(New ListItem("Cancelled", "3"))

                            BindClosureReasons()
                        End If
                    End With
                Else
                    ''No job found
                    lblFormTitle.Text = "Job [" & m_JobID.ToString & "] not found"
                    lblFormTitle.ForeColor = Color.Red
                End If
            End If
        End Sub

        Protected Overrides Sub AddClientScript()
            btnCloseJob.Attributes.Add("onclick", "return ConfirmWithValidation('Are you sure you wish to close this job?');")
        End Sub

        '*************** Events Handlers ***************
        Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
            If Not Page.IsPostBack Then
                MyBase.Page_Load(sender, e)
                ''Set initial Focus
                Call SetFocus(txtJobID)
            End If

        End Sub

        Private Sub btnCloseJob_ServerClick(sender As Object, e As EventArgs) Handles btnCloseJob.ServerClick
            Try
                m_DataLayer.CloseDeinstallJob(Convert.ToInt32(txtJobID.Value), Convert.ToInt32(cboFixID.SelectedValue), cboClosureComment.SelectedValue)
                m_ClosureSuccess = True
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try
        End Sub

        Private Sub BindClosureReasons()
            Dim dlResult As DataLayerResult

            dlResult = m_DataLayer.GetClientClosureReasons(txtClientID.Value, txtJobType.Value, Convert.ToInt32(cboFixID.SelectedValue))

            If dlResult = DataLayerResult.Success Then
                cboClosureComment.DataSource = m_DataLayer.dsTemp
                cboClosureComment.DataTextField = "Reason"
                cboClosureComment.DataValueField = "Reason"

                cboClosureComment.DataBind()
            End If
        End Sub

        Private Sub cboFixID_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboFixID.SelectedIndexChanged
            Call BindClosureReasons()
        End Sub



        Protected Sub lnkBtnNoteSortOrder_Click(sender As Object, e As EventArgs) Handles lnkBtnNoteSortOder.Click

            If lnkBtnNoteSortOder.Text = "Asc Order" Then
                m_NoteSortOrderAsc = True
            Else
                m_NoteSortOrderAsc = False
            End If

            'Dim searchString = "NoteSortAsc"
            'Dim textPos = InStr(HttpContext.Current.Request.Url.ToString(), searchString, CompareMethod.Text)

            'If textPos <= 0 Then
            '    Response.Redirect(HttpContext.Current.Request.Url.ToString() + "&NoteSortAsc=" & m_NoteSortOrderAsc, True)
            'Else

            'End If

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

