#Region "vss"
'<!--$$Revision: 12 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 21/05/15 11:07 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/LogJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing
Namespace eCAMS

    Partial Class LogJob
        Inherits MemberPageBase
        Private m_JobTypeID As Int16
        Private lblMsg As New Label
        Private m_EquipmentCode As String
        Private m_Mode As Int16
        Private m_ClientID As String

        <Serializable()>
        Private Class ErrorCode
            Public Property FaultID As Integer
            Public Property ErrorCode As String
            Public Property Quantity As Integer
        End Class


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
                m_JobTypeID = Convert.ToInt16(.Item("WhichJob"))
                m_Mode = Convert.ToInt16(.Item("M"))
            End With
        End Sub

        Protected Overrides Sub Process()
            Call SetDE()
        End Sub

        Private Sub BindGrid()
            Dim dlResult As DataLayerResult
            Dim dt As DataTable

            dlResult = m_DataLayer.GetSiteEquipments(txtClientID.Value, txtTID.Text) 'CAMS-991
            If dlResult = DataLayerResult.Success Then
                panelSiteEquiptment.Visible = True
                Try

                    dt = m_DataLayer.dsSites.Tables(0).Copy

                    For i = dt.Columns.Count - 1 To 0 Step -1
                        If Not (dt.Columns(i).ColumnName = "Serial" Or
                        dt.Columns(i).ColumnName = "MMD_ID" Or
                        dt.Columns(i).ColumnName = "LastChangedDateTime") Then
                            dt.Columns.RemoveAt(i)
                        End If
                    Next

                    grdSiteEquiptment.DataSource = dt
                    grdSiteEquiptment.DataBind()

                Catch ex As Exception
                    DisplayErrorMessage(lblMsg, ex.Message)
                Finally
                    'Hide the grid if no records.
                    panelSiteEquiptment.Visible = (grdSiteEquiptment.Items.Count > 0)
                End Try
            End If

        End Sub

        Protected Overrides Sub AddClientScript()
            ''tie these textboxes to corresponding buttons
            txtTradingHoursMon.Attributes.Add("onblur", "CopyTradingHoursMF(1);")
            txtTradingHoursTue.Attributes.Add("onblur", "CopyTradingHoursMF(2);")
            txtTradingHoursWed.Attributes.Add("onblur", "CopyTradingHoursMF(3);")
            txtTradingHoursThu.Attributes.Add("onblur", "CopyTradingHoursMF(4);")
            txtTradingHoursFri.Attributes.Add("onblur", "CopyTradingHoursMF(5);")

            ''add onclik to btnSave
            ''btnSave.Attributes.Add("onclick", "if (confirm('Are you sure to submit this request?')) {SetJobValidator();} else {return false;}")
            btnSave.Attributes.Add("onclick", "return ConfirmWithValidation('Are you sure to submit this request?');")

        End Sub

        Protected Overrides Sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.DeskTop
        End Sub

        Private Sub SetDE()
            Me.PageTitle = "Log Job"

            ''Branch pickup
            If m_Mode = 1 Then
                lblTID.Text = "Branch BSB:"
                rfvTID.ErrorMessage = "Please enter BSB."
                lblTIDHint.text = "format ###-###"
            End If
            ''hidden field value
            txtJobTypeID.Value = m_JobTypeID.ToString

            ''Set client Combox
            Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))

            DisplayTIDPage()
        End Sub
        Private Sub HidePanels(ByVal pLevel As Int16)
            Select Case pLevel
                Case 1  ''top level
                    panelTIDPage.Visible = False
                    panelFullPage.Visible = False
                    panelAcknowledge.Visible = False
                Case 2  ''second level
                    ''hide sub panels
                    panelUpgradeJob.Visible = False
                    panelJobMethodAndTerminalType.Visible = False
                    panelCallTypeSymptomFault.Visible = False
                    panelInstallDate.Visible = False
                    panelAdditionalServiceType.Visible = False
                    PanelUpdateSiteTradingHours.Visible = False
                    panelGetTradingHoursFromSite.visible = False
            End Select
        End Sub
        Private Sub DisplayTIDPage()
            Call HidePanels(1)
            panelTIDPage.Visible = True
            ''tie button to txtTID
            Call TieButton(txtTID, btnTIDGo)
            Call SetFocus(txtTID)

            PositionMsgLabel(placeholderMsg, lblMsg)
        End Sub
        Private Sub DisplayFullPage()
            Call HidePanels(1)  ''hide top level
            Call HidePanels(2)  ''hide sub level
            panelFullPage.Visible = True
            chbTechToAttWithoutCall.Visible = False
            lblTechToAttWithoutCall.Visible = False
            If (txtClientID.Value = "FDM") Or
                (txtClientID.Value = "PCT") Or
                (txtClientID.Value = "WIR") Or
                (txtClientID.Value = "JPM") Or
                (txtClientID.Value = "MMS") Or
                (txtClientID.Value = "CAL") Then

                panelFDIAdditionalInfo.Visible = True
            End If
            Select Case m_JobTypeID
                Case 1 ''install
                    panelInstallDate.Visible = True
                    panelJobMethodAndTerminalType.Visible = True

                Case 2 ''deinstall
                    panelJobMethodAndTerminalType.Visible = True

                    If txtClientID.Value = "NAB" Then
                        panelNABAdditionalInfo.Visible = True
                        panelLostStolen.Visible = True
                        Call BindGrid()
                    End If

                Case 3  ''upgrade
                    panelUpgradeJob.Visible = True
                    Call PopulateJobDeviceType(cboOldDeviceType, "2")
                    panelJobMethodAndTerminalType.Visible = True
                    If txtClientID.Value = "NAB" Then
                        Call BindGrid()
                    End If

                Case 4  ''swap
                    panelCallTypeSymptomFault.Visible = True
                    PanelUpdateSiteTradingHours.Visible = True
                    panelGetTradingHoursFromSite.Visible = True
                    If txtClientID.Value = "NAB" Then
                        Call BindGrid()
                    End If

                Case 5 ''additional service
                    panelAdditionalServiceType.Visible = True
                    PanelUpdateSiteTradingHours.Visible = True
                    panelGetTradingHoursFromSite.Visible = True
            End Select

            Call SetMandatoryIndicator()
            Call SetHelpTipContext()
            Call PopulateState()
            Call PopulateJobMethod()
            Call PopulateJobDeviceType(cboDeviceType, IIf(m_JobTypeID = 2, "2", "1").ToString)
            Call PopulateCallType(m_EquipmentCode)
            Call PopulateAdditionalServiceType()

            Call Tyro_Defaults("3") 'SMART

            Call PopulateProjectNo()
            Call PopulateCustomers()

            ''CAIC condituional dsiplay for install/upg/swap/addtional service
            If IsCAICDisplayed(txtClientID.Value, m_JobTypeID) Then
                panelCAIC.Visible = True

            End If

            ''display MID prefix
            If txtClientID.Value = "CBA" Then
                lblMIDPrefix.Visible = True
                chbTechToAttWithoutCall.Visible = (m_JobTypeID = 4) 'CAMS-878
                lblTechToAttWithoutCall.Visible = (m_JobTypeID = 4)
            End If

            PositionMsgLabel(placeholderMsg, lblMsg)

        End Sub
        Private Function IsCAICDisplayed(ByVal pClientID As String, ByVal pJobTypeID As Int16) As Boolean
            Return (pClientID = "CBA" AndAlso (pJobTypeID = 1 Or pJobTypeID = 3 Or pJobTypeID = 4 Or pJobTypeID = 5))
        End Function



        Private Sub SetTradingTimes(ByVal tradingHours As String)
            txtTradingHoursMon.Text = tradingHours
            txtTradingHoursTue.Text = tradingHours
            txtTradingHoursWed.Text = tradingHours
            txtTradingHoursThu.Text = tradingHours
            txtTradingHoursFri.Text = tradingHours
            txtTradingHoursSat.Text = tradingHours
            txtTradingHoursSun.Text = tradingHours
        End Sub
        Private Sub SetMandatoryIndicator()
            ''mandatory field indicator by jobtype
            Select Case m_JobTypeID
                Case 1 ''install
                    divContact.Visible = True
                    divPhone1.Visible = True
                Case 2 ''deinstall


                Case 3  ''upgrade

                Case 4  ''swap
                    SetMandatoryIndicatorOnTradingHourMF()

                Case 5 ''additional service
                    SetMandatoryIndicatorOnTradingHourMF()
            End Select
            ''mandatory field indicator by clientid
            Select Case txtClientID.Value
                Case "NAB", "HIC"
                    divProblemNumber.Visible = True
                Case "CBA"
                    divInstallDate.Visible = False
                    If m_JobTypeID = 1 Or m_JobTypeID = 4 Then
                        divProblemNumber.Visible = True
                    End If
            End Select

        End Sub
        Private Sub SetMandatoryIndicatorOnTradingHourMF()
            divTradingHourMFHint.Visible = True
            divTradingHourMon.Visible = True
            divTradingHourTue.Visible = True
            divTradingHourWed.Visible = True
            divTradingHourThu.Visible = True
            divTradingHourFri.Visible = True
        End Sub
        Private Sub SetHelpTipContext()
            If m_JobTypeID = 1 Or m_JobTypeID = 3 Then
                Select Case txtClientID.Value
                    Case "BOQ"
                        ltlHelpTipMID.Text = "BoQ MerchantID must be 9 digit number."
                        Me.txtMerchantID.Attributes("helptipid") = Me.panelHelpTipMID.ClientID

                    Case "CBA"
                        ltlHelpTipMID.Text = "CBA MerchantID must be 10 digit number."
                        Me.txtMerchantID.Attributes("helptipid") = Me.panelHelpTipMID.ClientID
                End Select
            End If

            ltlHelpTipPhone.Text = "Phone number must be 10 digit number including area code."
            Me.txtPhoneNumber.Attributes("helptipid") = Me.panelHelpTipPhone.ClientID
            Me.txtPhoneNumber2.Attributes("helptipid") = Me.panelHelpTipPhone.ClientID

            ltlHelpTradingHours.Text = "Enter TradingHours as HHMM-HHMM. For example: 0930-1730. <br/> Enter <b>closed</b> if no trading."
            Me.txtTradingHoursMon.Attributes("helptipid") = Me.panelHelpTradingHours.ClientID
            Me.txtTradingHoursTue.Attributes("helptipid") = Me.panelHelpTradingHours.ClientID
            Me.txtTradingHoursWed.Attributes("helptipid") = Me.panelHelpTradingHours.ClientID
            Me.txtTradingHoursThu.Attributes("helptipid") = Me.panelHelpTradingHours.ClientID
            Me.txtTradingHoursFri.Attributes("helptipid") = Me.panelHelpTradingHours.ClientID
            Me.txtTradingHoursSat.Attributes("helptipid") = Me.panelHelpTradingHours.ClientID
            Me.txtTradingHoursSun.Attributes("helptipid") = Me.panelHelpTradingHours.ClientID

            ''multiple textboxs, set helptipboxleft
            Me.txtTradingHoursMon.Attributes("helptipboxleft") = "70"
            Me.txtTradingHoursTue.Attributes("helptipboxleft") = "70"
            Me.txtTradingHoursWed.Attributes("helptipboxleft") = "70"
            Me.txtTradingHoursThu.Attributes("helptipboxleft") = "70"
            Me.txtTradingHoursFri.Attributes("helptipboxleft") = "70"
            Me.txtTradingHoursSat.Attributes("helptipboxleft") = "70"
            Me.txtTradingHoursSun.Attributes("helptipboxleft") = "70"

        End Sub

        Private Sub DisplayAcknowledgePage(ByVal pJobID As String)
            Call HidePanels(1)  ''hide top level
            panelAcknowledge.Visible = True
            lblAcknowledge.Text = "Job (JobID: <B>" & pJobID.ToString & "</B>) has been logged successfully. Click " + GetJobViewerHREF(pJobID) + " to view details."
        End Sub
        Private Sub PopulateState()
            m_DataLayer.CacheState()

            cboState.DataSource = m_DataLayer.State
            cboState.DataTextField = "State"
            cboState.DataValueField = "State"
            cboState.DataBind()
        End Sub
        Private Sub PopulateJobMethod()
            ''only populate it when it is visible
            If panelJobMethodAndTerminalType.Visible Then
                If m_DataLayer.GetJobMethod(txtClientID.Value, txtJobTypeID.Value) = DataLayerResult.Success Then
                    cboJobMethod.DataSource = m_DataLayer.dsTemp
                    cboJobMethod.DataTextField = "JobMethod"
                    cboJobMethod.DataValueField = "JobMethodID"
                    cboJobMethod.DataBind()
                End If
            End If
        End Sub

        Private Sub PopulateProjectNo()
            ''only populate it when it is visible
            If panelProjectNo.Visible Then
                If m_DataLayer.GetClientProject(txtClientID.Value) = DataLayerResult.Success Then
                    cboProjectNo.DataSource = m_DataLayer.dsTemp
                    cboProjectNo.DataTextField = "ProjectNo"
                    cboProjectNo.DataValueField = "ProjectNo"
                    cboProjectNo.DataBind()
                    ' Add an empty item at the first position
                    cboProjectNo.Items.Insert(0, New ListItem(String.Empty, String.Empty))
                End If
            End If
        End Sub

        Private Sub PopulateCustomers()
            ''only populate it when it is visible
            If panelCustomerName.Visible Then
                If m_DataLayer.GetCustomers(txtClientID.Value) = DataLayerResult.Success Then
                    cboCustomerName.DataSource = m_DataLayer.dsTemp
                    cboCustomerName.DataTextField = "Name"
                    cboCustomerName.DataValueField = "CustomerNumber"
                    cboCustomerName.DataBind()
                    ' Add an empty item at the first position
                    cboCustomerName.Items.Insert(0, New ListItem(String.Empty, String.Empty))
                End If
            End If
        End Sub
        Private Sub PopulateJobDeviceType(ByRef pCbo As DropDownList, ByVal pJobTypeID As String)
            ''only populate it when it is visible
            If panelJobMethodAndTerminalType.Visible Or panelUpgradeJob.Visible Then
                If m_DataLayer.GetJobDeviceType(txtClientID.Value, pJobTypeID) = DataLayerResult.Success Then
                    pCbo.DataSource = m_DataLayer.dsTemp
                    pCbo.DataTextField = "DisplayName"
                    pCbo.DataValueField = "DeviceType"
                    pCbo.DataBind()
                End If
            End If
        End Sub
        Private Sub PopulateCallType(ByVal pEquipmentCode As String)
            If panelCallTypeSymptomFault.Visible = True Then
                If m_DataLayer.GetCallType(pEquipmentCode) = DataLayerResult.Success AndAlso Not m_DataLayer.dsTemp Is Nothing Then
                    cboCallType.DataSource = m_DataLayer.dsTemp
                    cboCallType.DataTextField = "CallType"
                    cboCallType.DataValueField = "CallTypeID"
                    cboCallType.DataBind()

                    If m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                        ''more than one calltype found, popualte symptom automatically
                        Call PopulateSymptom(Convert.ToInt32(m_DataLayer.dsTemp.Tables(0).Rows(0)("CallTypeID")))
                    End If
                End If

            End If
        End Sub
        Private Sub PopulateSymptom(ByVal pCallTypeID As Integer)
            If panelCallTypeSymptomFault.Visible = True Then
                If m_DataLayer.GetCallTypeSymptom(pCallTypeID) = DataLayerResult.Success AndAlso Not m_DataLayer.dsTemp Is Nothing Then
                    cboSymptom.DataSource = m_DataLayer.dsTemp
                    cboSymptom.DataTextField = "Symptom"
                    cboSymptom.DataValueField = "SymptomID"
                    cboSymptom.DataBind()
                    If m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                        ''more than one calltype found, popualte fault automatically
                        Call PopulateFault(Convert.ToInt32(m_DataLayer.dsTemp.Tables(0).Rows(0)("SymptomID")))
                    End If

                End If

            End If

        End Sub
        Private Sub PopulateFault(ByVal pSymptomID As Integer)
            If panelCallTypeSymptomFault.Visible = True Then
                If m_DataLayer.GetSymptomFault(pSymptomID) = DataLayerResult.Success AndAlso Not m_DataLayer.dsTemp Is Nothing Then
                    cboFault.DataSource = m_DataLayer.dsTemp
                    cboFault.DataTextField = "Fault"
                    cboFault.DataValueField = "FaultID"
                    cboFault.DataBind()

                    If (txtClientID.Value = "TYR") Then
                        If (cboSymptom.SelectedItem.Text = "ACCESSORY") Then
                            lblErrorCodeLine.Visible = True
                            lblErrorCodeQty.Visible = True
                            ddlQuantity.Visible = True
                            btnAddErroCode.Visible = True
                            gvErrorCodes.Visible = True

                            PopulateQuantity()
                            BindErrorCodeGrid()
                        Else
                            ErrorCodeList = New List(Of ErrorCode)
                            lblErrorCodeLine.Visible = False
                            lblErrorCodeQty.Visible = False
                            ddlQuantity.Visible = False
                            btnAddErroCode.Visible = False
                            gvErrorCodes.Visible = False
                        End If
                    Else
                        ErrorCodeList = New List(Of ErrorCode)
                        lblErrorCodeLine.Visible = False
                        lblErrorCodeQty.Visible = False
                        ddlQuantity.Visible = False
                        btnAddErroCode.Visible = False
                        gvErrorCodes.Visible = False
                    End If

                End If
            End If
        End Sub

        Private Sub PopulateQuantity()

            ddlQuantity.Items.Clear()
            'ddlQuantity.Items.Add(New ListItem("", "0"))

            For i As Integer = 1 To 9
                ddlQuantity.Items.Add(New ListItem(i.ToString(), i.ToString()))
            Next

        End Sub

        Private Sub PopulateAdditionalServiceType()
            ''only populate it when it is visible
            If panelAdditionalServiceType.Visible = True Then
                If m_DataLayer.GetAdditionalServiceType(txtClientID.Value) = DataLayerResult.Success Then
                    cboAdditionalServiceType.DataSource = m_DataLayer.dsTemp
                    cboAdditionalServiceType.DataTextField = "AdditionalServiceTypeDescription"
                    cboAdditionalServiceType.DataValueField = "AdditionalServiceTypeID"
                    cboAdditionalServiceType.DataBind()
                End If
            End If
        End Sub

        Private Sub GetPostbackJobTypeID()
            m_JobTypeID = Convert.ToInt16(txtJobTypeID.Value)
        End Sub

        Private Function GetTrainingFeaturePrefix(ByVal pControlType As String) As String
            Return (pControlType & "TrainingFeature_")
        End Function
        Private Sub RenderFeaturePanel()
            ''this panel has to be rendered in Page_Ini or Page_Load, otherwise, viewstate not persist.
            Dim aRow As Data.DataRow
            Dim panelChk As New Panel
            panelChk.ID = "panelCheckBox"
            Dim panelTxt As New Panel
            panelTxt.ID = "panelTextBox"

            If m_DataLayer.GetClientTerminalConfigField(txtClientID.Value) = DataLayerResult.Success Then
                If m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                    ''build feature options when there are records
                    For Each aRow In m_DataLayer.dsTemp.Tables(0).Rows
                        ''check box
                        If aRow.Item("FieldType").ToString = "1" Then
                            Dim oCheck As New CheckBox
                            oCheck.ID = GetTrainingFeaturePrefix("chk") & aRow.Item("FieldID").ToString
                            oCheck.Text = aRow.Item("FieldName").ToString
                            oCheck.CssClass = "FormDEField"
                            panelChk.Controls.Add(oCheck)
                            panelChk.Controls.Add(New LiteralControl("<br/>"))
                        End If

                        ''textbox
                        If aRow.Item("FieldType").ToString = "2" Then
                            Dim oTxt As New TextBox
                            Dim oLbl As New Label
                            oTxt.ID = GetTrainingFeaturePrefix("txt") & aRow.Item("FieldID").ToString
                            ''oTxt.Text = aRow.Item("FieldName").ToString
                            oTxt.CssClass = "FormDEField"

                            oLbl.ID = GetTrainingFeaturePrefix("lbl") & aRow.Item("FieldID").ToString
                            oLbl.Text = aRow.Item("FieldName").ToString + ":"
                            oLbl.CssClass = "FormDEHeader"
                            oLbl.Style("margin-top") = "10px"
                            oLbl.Width = 100
                            panelTxt.Controls.Add(oLbl)
                            panelTxt.Controls.Add(oTxt)
                            panelTxt.Controls.Add(New LiteralControl("<br/>"))
                        End If

                    Next
                    ''add tr td
                    panelFeature.Controls.Add(New LiteralControl("<TR><TD></TD><TD style='vertical-align:top; padding-top:5px;'>Features <br/>Enabled <br/>For Training</TD><TD>"))

                    ''only add to panelFeature if there are options appended
                    If panelChk.Controls.Count > 0 Then
                        panelFeature.Controls.Add(panelChk)

                    End If

                    If panelTxt.Controls.Count > 0 Then
                        panelFeature.Controls.Add(panelTxt)
                    End If

                    ''add /td /tr
                    panelFeature.Controls.Add(New LiteralControl("</TD></TR>"))


                End If
            End If

            ''finally, do we need to display panelFeature?
            If panelFeature.Controls.Contains(panelChk) Or panelFeature.Controls.Contains(panelTxt) Then
                panelFeature.Visible = True
            Else
                panelFeature.Visible = False
            End If
        End Sub
        Private Function GetFeaturePanelXML() As String
            ''find panel and return XML values
            Dim oPanel As Control
            Dim oControl As Control
            Dim strConfigXML As String
            Dim strXMLTag As String
            strConfigXML = ""

            oPanel = FindChildControl(Me.Page.Form, "panelCheckBox")
            If Not oPanel Is Nothing Then
                For Each oControl In oPanel.Controls
                    If TypeOf (oControl) Is CheckBox Then
                        If CType(oControl, CheckBox).Checked Then
                            ''TrainingFeature_12
                            strXMLTag = oControl.ID.Substring(Len(GetTrainingFeaturePrefix("chk")))
                            strConfigXML += "<" & strXMLTag & ">1</" & strXMLTag & ">"
                        End If
                    End If
                Next
            End If
            oPanel = FindChildControl(Me.Page.Form, "panelTextBox")
            If Not oPanel Is Nothing Then
                For Each oControl In oPanel.Controls
                    If TypeOf (oControl) Is TextBox Then
                        If CType(oControl, TextBox).Text.Trim.Length > 0 Then
                            ''TrainingFeature_12
                            strXMLTag = oControl.ID.Substring(Len(GetTrainingFeaturePrefix("txt")))
                            strConfigXML += "<" & strXMLTag & ">" & CType(oControl, TextBox).Text.Trim & "</" & strXMLTag & ">"
                        End If
                    End If
                Next
            End If

            Return strConfigXML
        End Function
        Private Function GetHardwareComponentPrefix() As String
            Return ("chkHardwareComponent_")
        End Function
        Private Sub RenderHardwareComponentPanel()
            ''this panel has to be rendered in Page_Ini or Page_Load, otherwise, viewstate not persist.
            Dim aRow As Data.DataRow
            Dim panelChk As New Panel
            panelChk.ID = "HardwareComponent_panelCheckBox"

            ''get hardare component
            If m_DataLayer.GetDeviceComponent(txtClientID.Value, txtTID.Text, 1) = DataLayerResult.Success Then
                If m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                    ''build feature options when there are records
                    For Each aRow In m_DataLayer.dsTemp.Tables(0).Rows
                        ''check box
                        Dim oCheck As New CheckBox
                        oCheck.ID = GetHardwareComponentPrefix() & aRow.Item("ComponentID").ToString
                        oCheck.Text = aRow.Item("Component").ToString
                        oCheck.CssClass = "FormDEField"
                        panelChk.Controls.Add(oCheck)
                        panelChk.Controls.Add(New LiteralControl("<br/>"))
                    Next
                    ''add tr td
                    panelComponent.Controls.Add(New LiteralControl("<TR><TD></TD><TD>Swap Components</TD><TD>"))

                    ''only add to panelFeature if there are options appended
                    If panelChk.Controls.Count > 0 Then
                        panelComponent.Controls.Add(panelChk)

                    End If


                    ''add /td /tr
                    panelComponent.Controls.Add(New LiteralControl("</TD></TR>"))


                End If
            End If

            ''finally, do we need to display panelFeature?
            If panelComponent.Controls.Contains(panelChk) Then
                panelComponent.Visible = True
            Else
                panelComponent.Visible = False
            End If
        End Sub
        Private Function GetHardwareComponentPanelSelection() As String
            ''find panel and return XML values
            Dim oPanel As Control
            Dim oControl As Control
            Dim strSelection As String
            strSelection = ""

            oPanel = FindChildControl(Me.Page.Form, "HardwareComponent_panelCheckBox")
            If Not oPanel Is Nothing Then
                For Each oControl In oPanel.Controls
                    If TypeOf (oControl) Is CheckBox Then
                        If CType(oControl, CheckBox).Checked Then
                            strSelection += CType(oControl, CheckBox).Text + ","
                        End If
                    End If
                Next
            End If
            ''trim the last comma
            If Len(strSelection) > 0 Then
                strSelection = strSelection.Remove(strSelection.Length - 1)
            End If

            Return strSelection
        End Function
        Private Function GetSoftwareApplicationPrefix() As String
            Return ("chkSoftwareApplication_")
        End Function

        Private Sub RenderSoftwareApplicationPanel()
            ''this panel has to be rendered in Page_Ini or Page_Load, otherwise, viewstate not persist.
            Dim aRow As Data.DataRow
            Dim panelChk As New Panel
            panelChk.ID = "SoftwareApplication_panelCheckBox"

            ''get software component
            If m_DataLayer.GetDeviceComponent(txtClientID.Value, txtTID.Text, 2) = DataLayerResult.Success Then
                If m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                    ''build feature options when there are records
                    For Each aRow In m_DataLayer.dsTemp.Tables(0).Rows
                        ''check box
                        Dim oControl As New RadioButton
                        oControl.ID = GetSoftwareApplicationPrefix() & aRow.Item("ComponentID").ToString
                        oControl.Text = aRow.Item("Component").ToString
                        oControl.CssClass = "FormDEField"
                        oControl.GroupName = GetSoftwareApplicationPrefix()  ''forced only one selection
                        If aRow.Item("IsSelected").ToString = "1" Then
                            CType(oControl, RadioButton).Checked = True
                        End If
                        panelChk.Controls.Add(oControl)
                        panelChk.Controls.Add(New LiteralControl("<br/>"))
                    Next
                    ''add tr td
                    panelComponent.Controls.Add(New LiteralControl("<TR><TD></TD><TD>Software Applications</TD><TD>"))

                    ''only add to panelFeature if there are options appended
                    If panelChk.Controls.Count > 0 Then
                        panelComponent.Controls.Add(panelChk)

                    End If


                    ''add /td /tr
                    panelComponent.Controls.Add(New LiteralControl("</TD></TR>"))


                End If
            End If

            ''finally, do we need to display panelFeature?
            If panelComponent.Controls.Contains(panelChk) Then
                panelComponent.Visible = True
            Else
                panelComponent.Visible = False
            End If
        End Sub
        Private Function GetSoftwareApplicationPanelSelection() As String
            ''find panel and return XML values
            Dim oPanel As Control
            Dim oControl As Control
            Dim strSelection As String
            strSelection = ""

            oPanel = FindChildControl(Me.Page.Form, "SoftwareApplication_panelCheckBox")
            If Not oPanel Is Nothing Then
                For Each oControl In oPanel.Controls
                    If TypeOf (oControl) Is RadioButton Then
                        If CType(oControl, RadioButton).Checked Then
                            strSelection += CType(oControl, RadioButton).Text + ","
                        End If
                    End If
                Next
            End If
            ''trim the last comma
            If Len(strSelection) > 0 Then
                strSelection = strSelection.Remove(strSelection.Length - 1)
            End If

            Return strSelection
        End Function
        Private Function GetComponentPanelSelection() As String
            ''get software applications and hardware selection
            Dim strSelection As String
            strSelection = GetSoftwareApplicationPanelSelection()
            If Len(strSelection) > 0 Then
                strSelection = strSelection & "," & GetHardwareComponentPanelSelection()
            Else
                strSelection = GetHardwareComponentPanelSelection()
            End If


            Return strSelection
        End Function

        Private Sub DisplaySiteDetail(ByVal pRow As Data.DataRow)
            With pRow
                txtMerchantID.Text = clsTool.NullToValue(.Item("MerchantID").ToString, "")
                txtName.Text = clsTool.NullToValue(.Item("Name").ToString, "")
                txtAddress.Text = clsTool.NullToValue(.Item("Address").ToString, "")
                txtAddress2.Text = clsTool.NullToValue(.Item("Address2").ToString, "")
                txtCity.Text = clsTool.NullToValue(.Item("City").ToString, "")
                Call ScrollToCboText(cboState, clsTool.NullToValue(.Item("State").ToString, ""))
                txtPostcode.Text = clsTool.NullToValue(.Item("Postcode").ToString, "")
                txtContact.Text = clsTool.NullToValue(.Item("Contact").ToString, "")
                ''trim space, () - to pass client side validation
                txtPhoneNumber.Text = clsTool.NullToValue(.Item("Phone").ToString, "").Replace(" ", "").Replace("(", "").Replace(")", "").Replace("-", "")
                txtPhoneNumber2.Text = clsTool.NullToValue(.Item("Phone2").ToString, "").Replace(" ", "").Replace("(", "").Replace(")", "").Replace("-", "")
                txtBusinessActivity.Text = clsTool.NullToValue(.Item("BusinessActivity").ToString, "")
                txtRegion.Value = clsTool.NullToValue(.Item("Region").ToString, "")

                If (clsTool.NullToValue(.Item("ClientID").ToString, "") = "FDM") Or
               (clsTool.NullToValue(.Item("ClientID").ToString, "") = "PCT") Or
               (clsTool.NullToValue(.Item("ClientID").ToString, "") = "WIR") Or
               (clsTool.NullToValue(.Item("ClientID").ToString, "") = "JPM") Or
               (clsTool.NullToValue(.Item("ClientID").ToString, "") = "MMS") Or
               (clsTool.NullToValue(.Item("ClientID").ToString, "") = "CAL") Then
                    txtCustomerNumber1.Text = clsTool.NullToValue(.Item("CustomerNumber").ToString, "")
                Else
                    txtCustomerNumber.Text = clsTool.NullToValue(.Item("CustomerNumber").ToString, "")
                End If

                txtAltMerchantID.Text = clsTool.NullToValue(.Item("AltMerchantID").ToString, "")

                ' ''retrieve TradingHours from Sites
                'txtTradingHoursMon.Text = clsTool.NullToValue(.Item("TradingHoursMon"), "").Replace(":", "")
                'txtTradingHoursTue.Text = clsTool.NullToValue(.Item("TradingHoursTue"), "").Replace(":", "")
                'txtTradingHoursWed.Text = clsTool.NullToValue(.Item("TradingHoursWed"), "").Replace(":", "")
                'txtTradingHoursThu.Text = clsTool.NullToValue(.Item("TradingHoursThu"), "").Replace(":", "")
                'txtTradingHoursFri.Text = clsTool.NullToValue(.Item("TradingHoursFri"), "").Replace(":", "")
                'txtTradingHoursSat.Text = clsTool.NullToValue(.Item("TradingHoursSat"), "").Replace(":", "")
                'txtTradingHoursSun.Text = clsTool.NullToValue(.Item("TradingHoursSun"), "").Replace(":", "")


                If m_JobTypeID = 1 Or m_JobTypeID = 2 Then
                    ''install /deinstall jobs
                    Call ScrollToCboValue(cboDeviceType, clsTool.NullToValue(.Item("DeviceType").ToString, ""))
                End If

                If m_JobTypeID = 3 Then
                    ''upgrade job
                    Call ScrollToCboValue(cboOldDeviceType, clsTool.NullToValue(.Item("DeviceType").ToString, ""))
                End If

                If m_JobTypeID = 4 And clsTool.NullToValue(.Item("ClientID").ToString, "") = "NAB" Then
                    panelTransendID.Visible = True
                    txtTransendID.Text = clsTool.NullToValue(.Item("NetworkTerminalID").ToString, "")
                End If
            End With

        End Sub
        Private Function FormatTradingHour(ByVal pHour As String) As String
            Dim retHour As String = ""
            If pHour.Length > 8 Then
                ''HHMM-HHMM
                retHour = pHour.Insert(7, ":").Insert(2, ":")
            End If
            Return retHour
        End Function
        Private Sub GetTradingHoursFromSite()

            If m_DataLayer.GetSite(txtClientID.Value, txtTerminalID.Text) = DataLayerResult.Success AndAlso m_DataLayer.dsSite.Tables(0).Rows.Count > 0 Then
                With m_DataLayer.dsSite.Tables(0).Rows(0)

                    txtTradingHoursMon.Text = clsTool.NullToValue(.Item("TradingHoursMon"), "").Replace(":", "").Replace(" ", "")
                    txtTradingHoursTue.Text = clsTool.NullToValue(.Item("TradingHoursTue"), "").Replace(":", "").Replace(" ", "")
                    txtTradingHoursWed.Text = clsTool.NullToValue(.Item("TradingHoursWed"), "").Replace(":", "").Replace(" ", "")
                    txtTradingHoursThu.Text = clsTool.NullToValue(.Item("TradingHoursThu"), "").Replace(":", "").Replace(" ", "")
                    txtTradingHoursFri.Text = clsTool.NullToValue(.Item("TradingHoursFri"), "").Replace(":", "").Replace(" ", "")
                    txtTradingHoursSat.Text = clsTool.NullToValue(.Item("TradingHoursSat"), "").Replace(":", "").Replace(" ", "")
                    txtTradingHoursSun.Text = clsTool.NullToValue(.Item("TradingHoursSun"), "").Replace(":", "").Replace(" ", "")

                    ''if some trading hours are blank, then set to CLOSED
                    If txtTradingHoursMon.Text + txtTradingHoursTue.Text + txtTradingHoursWed.Text + txtTradingHoursThu.Text + txtTradingHoursFri.Text + txtTradingHoursSat.Text + txtTradingHoursSun.Text <> "" Then
                        txtTradingHoursMon.Text = IIf(txtTradingHoursMon.Text = "", "CLOSED", txtTradingHoursMon.Text).ToString
                        txtTradingHoursTue.Text = IIf(txtTradingHoursTue.Text = "", "CLOSED", txtTradingHoursTue.Text).ToString
                        txtTradingHoursWed.Text = IIf(txtTradingHoursWed.Text = "", "CLOSED", txtTradingHoursWed.Text).ToString
                        txtTradingHoursThu.Text = IIf(txtTradingHoursThu.Text = "", "CLOSED", txtTradingHoursThu.Text).ToString
                        txtTradingHoursFri.Text = IIf(txtTradingHoursFri.Text = "", "CLOSED", txtTradingHoursFri.Text).ToString
                        txtTradingHoursSat.Text = IIf(txtTradingHoursSat.Text = "", "CLOSED", txtTradingHoursSat.Text).ToString
                        txtTradingHoursSun.Text = IIf(txtTradingHoursSun.Text = "", "CLOSED", txtTradingHoursSun.Text).ToString
                    End If

                End With
            End If

        End Sub
#End Region

#Region "Event"

        Protected Sub btnTIDGo_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnTIDGo.ServerClick
            ''init
            lblFormTitle.Text = ""

            ''get postback jobtypeID
            GetPostbackJobTypeID()
            PositionMsgLabel(placeholderMsg, lblMsg) ''reposition the error message label

            ''save JobTypeID and ClientID to hidden fields
            txtJobTypeID.Value = m_JobTypeID.ToString
            txtClientID.Value = cboClientID.SelectedValue
            If m_JobTypeID = 3 Then
                txtOldTerminalID.Text = txtTID.Text
            Else
                txtTerminalID.Text = txtTID.Text
            End If

            ''validation berfore log job
            Dim ret As Integer
            Try
                ret = m_DataLayer.ValidateTIDBeforeLogJob(txtClientID.Value, txtTID.Text, m_JobTypeID)
            Catch ex As Exception
                'lblFormTitle.Text = ex.Message
                'lblFormTitle.ForeColor = Color.Red
                Dim errMsg As String = GetErrorMessage(ex.Message)
                DisplayErrorMessage(lblMsg, errMsg)
                Exit Sub
            End Try


            ''get Merchant details based on ClientID and TerminalID
            Dim dlResult As DataLayerResult
            ''Read data
            dlResult = m_DataLayer.GetSite(txtClientID.Value, txtTID.Text)

            ''Get Site and display it as merchant trading details
            If dlResult = DataLayerResult.Success AndAlso m_DataLayer.dsSite.Tables(0).Rows.Count > 0 Then
                ''store equipemntcode for calltype ComboBox
                m_EquipmentCode = clsTool.NullToValue(m_DataLayer.dsSite.Tables(0).Rows(0).Item("EquipmentCode").ToString, "")
            End If

            ''Display Full Page
            DisplayFullPage()

            ''now display site details if needed
            If dlResult = DataLayerResult.Success AndAlso m_DataLayer.dsSite.Tables(0).Rows.Count > 0 Then
                DisplaySiteDetail(m_DataLayer.dsSite.Tables(0).Rows(0))

                If Not Convert.ToBoolean(m_DataLayer.dsSite.Tables(0).Rows(0)("IsActive")) Then
                    m_DataLayer.PopupMessage = "<b>Warning</b><br><br><br><b>This merchant site is a CLOSED SITE.</b>"

                    Call DisplayMessageBox(Me.Page)
                End If

                PopulateServiceStatus(m_DataLayer.dsSite.Tables(0).Rows(0))
            End If


        End Sub



        Private Function GetErrorMessage(message As String) As String
            ' Regular expression pattern to match a number inside brackets
            Dim pattern As String = "\(\d+\)"

            ' Use Regex.Match to find the first match
            Dim match As Match = Regex.Match(message, pattern)

            ' Check if a match is found
            If match.Success Then
                ' Get the matched value
                Dim matchedValue As String = match.Value
                Dim jobID As String = matchedValue.Replace("(", "").Replace(")", "")

                Dim url As String = "../Member/JobView.aspx?JID=" + jobID

                '<a href = "#" onclick="javascript:popupwindow('../Member/JobView.aspx?JID=3854405')">3854405</a>

                Dim anchorString As String = String.Format("<a href='#' onclick=""javascript: popupwindow('{0}')"">{1}</a>", url, jobID)
                ' Replace the matched value with the replacement string
                Dim replacedString As String = message.Replace(matchedValue, anchorString)

                ' Return the modified string
                Return replacedString
            Else
                ' If no match is found, return the original string
                Return message
            End If
        End Function

        Private Function GetSelectedProjectNo() As String
            If String.IsNullOrEmpty(cboProjectNo.SelectedValue) Then
                Return Nothing
            Else
                Return cboProjectNo.SelectedValue
            End If
        End Function
        Protected Sub btnSave_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.ServerClick
            Dim jobID As Integer
            Dim callNumber As String = ""
            Dim ret As DataLayerResult
            Dim strCAIC As String = ""
            Dim strCustomerNumber As String = ""
            GetPostbackJobTypeID()
            PositionMsgLabel(placeholderMsg, lblMsg) ''reposition the error message label

            If IsCAICDisplayed(txtClientID.Value, m_JobTypeID) Then
                strCAIC = txtCAIC.Text
            End If

            If (txtClientID.Value = "FDM") Or (txtClientID.Value = "PCT") Or (txtClientID.Value = "WIR") Or
               (txtClientID.Value = "JPM") Or (txtClientID.Value = "MMS") Or (txtClientID.Value = "CAL") Then
                strCustomerNumber = txtCustomerNumber1.Text
            ElseIf (txtClientID.Value = "TYR") Then
                If String.IsNullOrEmpty(cboCustomerName.SelectedValue) Then
                    strCustomerNumber = Nothing
                Else
                    strCustomerNumber = cboCustomerName.SelectedValue
                End If
            Else
                strCustomerNumber = txtCustomerNumber.Text
            End If

            ''log job (Install, Deinstall, Upgrade
            If m_JobTypeID = 1 Or m_JobTypeID = 2 Or m_JobTypeID = 3 Then
                Try
                    ret = m_DataLayer.LogJob(jobID,
                        txtProblemNumber.Text,
                        txtClientID.Value,
                        txtMerchantID.Text,
                        txtTerminalID.Text,
                        txtJobTypeID.Value,
                        cboJobMethod.SelectedValue,
                        cboDeviceType.SelectedValue,
                        txtSpecInstruct.Text,
                        txtInstallDate.Text,
                        txtName.Text,
                        txtAddress.Text,
                        txtAddress2.Text,
                        txtCity.Text,
                        cboState.SelectedValue,
                        txtPostcode.Text,
                        txtContact.Text,
                        txtPhoneNumber.Text,
                        txtPhoneNumber2.Text,
                        cboLineType.SelectedValue,
                        txtDialPrefix.Text,
                        cboOldDeviceType.SelectedValue,
                        txtOldTerminalID.Text,
                        txtBusinessActivity.Text,
                        chbUrgent.Checked,
                        FormatTradingHour(txtTradingHoursMon.Text),
                        FormatTradingHour(txtTradingHoursTue.Text),
                        FormatTradingHour(txtTradingHoursWed.Text),
                        FormatTradingHour(txtTradingHoursThu.Text),
                        FormatTradingHour(txtTradingHoursFri.Text),
                        FormatTradingHour(txtTradingHoursSat.Text),
                        FormatTradingHour(txtTradingHoursSun.Text),
                        False,
                        GetFeaturePanelXML(),
                        txtJobNote.Text,
                        strCAIC,
                        txtContactEmail.Text,
                        txtBankersEmail.Text,
                        txtMerchantEmail.Text,
                        strCustomerNumber,
                        txtAltMerchantID.Text,
                        chbLostStolen.Checked,
                        GetSelectedProjectNo())
                    If ret = DataLayerResult.Success Then
                        DisplayAcknowledgePage(jobID.ToString)
                    Else
                        DisplayErrorMessage(lblMsg, "Failed to save this job. Please try again.")
                    End If
                Catch ex As Exception
                    DisplayErrorMessage(lblMsg, ex.Message)
                End Try
            End If

            If m_JobTypeID = 4 Then

                Dim faultCode As String = cboFault.SelectedValue
                If (txtClientID.Value = "TYR" AndAlso cboSymptom.SelectedItem.Text = "ACCESSORY") Then
                    If (ErrorCodeList.Count() <= 0) Then
                        lblErrorCodeMessage.Text = "Add Error Code to Parts List!"
                        Return
                    Else
                        txtJobNote.Text = txtJobNote.Text + vbCr + ErrorCodeNotes
                        If (ErrorCodeList.Count() = 1) Then
                            Dim eCode As ErrorCode = ErrorCodeList.FirstOrDefault()
                            faultCode = eCode.FaultID.ToString()
                        Else
                            faultCode = "5597" 'MULTIPLE ACCESSORIES
                        End If
                    End If
                End If

                Try
                    ret = m_DataLayer.LogCall(callNumber,
                        txtProblemNumber.Text,
                        txtClientID.Value,
                        txtMerchantID.Text,
                        txtTerminalID.Text,
                        cboCallType.SelectedItem.Text,
                        txtSpecInstruct.Text,
                        txtInstallDate.Text,
                        txtName.Text,
                        txtAddress.Text,
                        txtAddress2.Text,
                        txtCity.Text,
                        cboState.SelectedValue,
                        txtPostcode.Text,
                        txtContact.Text,
                        txtPhoneNumber.Text,
                        txtPhoneNumber2.Text,
                        cboLineType.SelectedValue,
                        txtDialPrefix.Text,
                        cboCallType.SelectedValue,
                        cboSymptom.SelectedValue,
                        faultCode,
                        txtBusinessActivity.Text,
                        chbUrgent.Checked,
                        FormatTradingHour(txtTradingHoursMon.Text),
                        FormatTradingHour(txtTradingHoursTue.Text),
                        FormatTradingHour(txtTradingHoursWed.Text),
                        FormatTradingHour(txtTradingHoursThu.Text),
                        FormatTradingHour(txtTradingHoursFri.Text),
                        FormatTradingHour(txtTradingHoursSat.Text),
                        FormatTradingHour(txtTradingHoursSun.Text),
                        chkUpdateSiteTradingHours.Checked,
                        "",
                        "",
                        txtJobNote.Text,
                        GetComponentPanelSelection(),
                        strCAIC,
                        chbTechToAttWithoutCall.Checked) ''CAMS-878
                    If ret = DataLayerResult.Success Then
                        DisplayAcknowledgePage(callNumber)
                    Else
                        DisplayErrorMessage(lblMsg, "Failed to save this job. Please try again.")
                    End If
                Catch ex As Exception
                    DisplayErrorMessage(lblMsg, ex.Message)
                End Try
            End If

            ''additional service
            If m_JobTypeID = 5 Then
                Try
                    ret = m_DataLayer.LogCall(callNumber,
                        txtProblemNumber.Text,
                        txtClientID.Value,
                        txtMerchantID.Text,
                        txtTerminalID.Text,
                        cboAdditionalServiceType.SelectedItem.Text,
                        txtSpecInstruct.Text,
                        txtInstallDate.Text,
                        txtName.Text,
                        txtAddress.Text,
                        txtAddress2.Text,
                        txtCity.Text,
                        cboState.SelectedValue,
                        txtPostcode.Text,
                        txtContact.Text,
                        txtPhoneNumber.Text,
                        txtPhoneNumber2.Text,
                        cboLineType.SelectedValue,
                        txtDialPrefix.Text,
                        "",
                        "",
                        "",
                        txtBusinessActivity.Text,
                        chbUrgent.Checked,
                        FormatTradingHour(txtTradingHoursMon.Text),
                        FormatTradingHour(txtTradingHoursTue.Text),
                        FormatTradingHour(txtTradingHoursWed.Text),
                        FormatTradingHour(txtTradingHoursThu.Text),
                        FormatTradingHour(txtTradingHoursFri.Text),
                        FormatTradingHour(txtTradingHoursSat.Text),
                        FormatTradingHour(txtTradingHoursSun.Text),
                        chkUpdateSiteTradingHours.Checked,
                        GetFeaturePanelXML(),
                        cboAdditionalServiceType.SelectedValue,
                        txtJobNote.Text,
                        "",
                        strCAIC,
                        chbTechToAttWithoutCall.Checked)
                    If ret = DataLayerResult.Success Then
                        DisplayAcknowledgePage(callNumber)
                    Else
                        DisplayErrorMessage(lblMsg, "Failed to save this job. Please try again.")
                    End If
                Catch ex As Exception
                    DisplayErrorMessage(lblMsg, ex.Message)
                End Try
            End If

        End Sub

        Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
            MyBase.Page_Load(sender, e)

            Me.PageTitle = "Log Job"

            If Page.IsPostBack Then

                ''---11/02/2008 Bo ---
                ''Since we moved ScriptManager to Master page for Server side viewstate persisting
                ''So we need to find the script manager first
                Dim oSM As ScriptManager
                oSM = CType(Page.Master.FindControl("ScriptManager1"), ScriptManager)
                If Not oSM Is Nothing AndAlso oSM.IsInAsyncPostBack = True Then
                    ' determine sending control
                    ''Due to the masterpage, control being rendered with long page declaration
                    ''so use IndexOf() to check the partial postback control
                    If oSM.AsyncPostBackSourceElementID.IndexOf("cboCallType") > 0 Then
                        ' populate faults
                        Call PopulateSymptom(Convert.ToInt32(cboCallType.SelectedValue))
                    ElseIf oSM.AsyncPostBackSourceElementID.IndexOf("cboSymptom") > 0 Then
                        ' populate faults
                        Call PopulateFault(Convert.ToInt32(cboSymptom.SelectedValue))
                    ElseIf oSM.AsyncPostBackSourceElementID.IndexOf("btnGetTradingHoursFromSite") > 0 Then
                        Call GetTradingHoursFromSite()
                    ElseIf oSM.AsyncPostBackSourceElementID.IndexOf("txtPostcode") > 0 Then
                        Call PopulateServiceStatus(Nothing)
                    End If
                    'Else
                End If
                ''page is postback and needs to render Feature Panel. The panel has to be rendered here in order to maintain viewstate
                GetPostbackJobTypeID()
                ''save JobTypeID and ClientID to hidden fields
                txtJobTypeID.Value = m_JobTypeID.ToString
                txtClientID.Value = cboClientID.SelectedValue

                ''only render for install/upgrade jobs
                If m_JobTypeID = 1 Or m_JobTypeID = 3 Or m_JobTypeID = 5 Then
                    RenderFeaturePanel()
                End If

                If m_JobTypeID = 4 And txtTID.Text <> "" Then
                    RenderSoftwareApplicationPanel()
                    RenderHardwareComponentPanel()
                End If
                ''End If

            End If


        End Sub

        Protected Sub cboJobMethod_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboJobMethod.SelectedIndexChanged

            Call Tyro_Defaults(cboJobMethod.SelectedItem.Value)

        End Sub


        ''CAMS-1378
        Private Sub Tyro_Defaults(ByVal jobMethod As String)

            If (txtClientID.Value = "TYR") Then

                If (m_JobTypeID = 1 Or m_JobTypeID = 2 Or m_JobTypeID = 3) Then

                    cboJobMethod.SelectedValue = jobMethod 'SMART

                    If (m_JobTypeID = 1 And String.IsNullOrEmpty(txtBusinessActivity.Text)) Then
                        txtBusinessActivity.Text = "N/A"
                    End If

                    panelProjectNo.Visible = True
                End If

                If (m_JobTypeID = 3) Then 'Upgrade
                    txtTerminalID.Text = txtOldTerminalID.Text
                End If

                If (m_JobTypeID = 1) Then
                    panelCustomerName.Visible = True
                    cboState.SelectedValue = "VIC"
                End If

                If (cboJobMethod.SelectedValue = "3" And m_JobTypeID = 1) Then  'SMART 
                    If (String.IsNullOrEmpty(txtInstallDate.Text)) Then
                        txtInstallDate.Text = DateTime.Now.ToString("dd/MM/yy")
                    End If
                End If

                If (cboJobMethod.SelectedValue = "3" Or 'SMART => set trading hours to 0800-1800
                        m_JobTypeID = 4 Or m_JobTypeID = 5) Then
                    If (String.IsNullOrEmpty(txtTradingHoursMon.Text)) Then
                        SetTradingTimes("0800-1800")
                    End If
                End If

                If (cboJobMethod.SelectedValue = "1") Then 'TECH => set trading hours to null
                    SetTradingTimes("")
                    txtInstallDate.Text = String.Empty
                End If

                panelCommsMethod.Visible = False
                panelDialPrefix.Visible = False
                panelFeature.Visible = False

            End If

        End Sub


        Private Sub PopulateServiceStatus(ByVal pRow As Data.DataRow)
            Dim postcode As String
            Dim city As String
            Dim clientID As String
            Dim deviceType As String
            Dim requiredDTLocal As String = DateTime.Now.ToString("dd/MM/yyyy")

            panelServiceStatus.Visible = False

            If (m_JobTypeID = 0) Then
                GetContext()
            End If

            If (pRow IsNot Nothing) Then
                city = clsTool.NullToValue(pRow.Item("City").ToString, "")
                postcode = clsTool.NullToValue(pRow.Item("Postcode").ToString, "")
                clientID = clsTool.NullToValue(pRow.Item("ClientID").ToString, "")
                deviceType = clsTool.NullToValue(pRow.Item("DeviceType").ToString, "")
            Else
                city = txtCity.Text
                postcode = txtPostcode.Text
                clientID = txtClientID.Value
                deviceType = "ALL"
            End If

            'No DEINSTALL/RECOVERY JOB for CBA
            Dim allowedJobTypes = New Short() {1, 3, 4}

            If (clientID = "CBA" AndAlso allowedJobTypes.Contains(m_JobTypeID) AndAlso
                Not String.IsNullOrEmpty(postcode) AndAlso
                    Not String.IsNullOrEmpty(city) AndAlso
                    Not String.IsNullOrEmpty(clientID)) Then
                Try
                    txtServiceStatus.Value = m_DataLayer.GetPostcodeFSPAllocation(postcode, city, clientID, m_JobTypeID, deviceType, requiredDTLocal)
                    panelServiceStatus.Visible = True

                Catch ex As Exception
                    txtServiceStatus.Value = ""
                    DisplayErrorMessage(lblMsg, ex.Message)
                End Try
            End If

        End Sub

        Private Property ErrorCodeList As List(Of ErrorCode)
            Get
                If ViewState("accessoryErrorCodeList") Is Nothing Then
                    ViewState("accessoryErrorCodeList") = New List(Of ErrorCode)()
                End If
                Return CType(ViewState("accessoryErrorCodeList"), List(Of ErrorCode))
            End Get
            Set(value As List(Of ErrorCode))
                ViewState("accessoryErrorCodeList") = value
            End Set
        End Property

        Public ReadOnly Property ErrorCodeNotes As String
            Get
                Dim csvBuilder As New StringBuilder()
                ' Add header
                csvBuilder.AppendLine("ERROR CODES and QUANTITIES:")
                ' Add each skill as a CSV row
                For Each errCode As ErrorCode In ErrorCodeList
                    csvBuilder.AppendLine($"ErrorCode: {errCode.ErrorCode}; Qty: {errCode.Quantity}")
                Next

                Return csvBuilder.ToString()
            End Get
        End Property
        Protected Sub BtnAddErroCode_Click(sender As Object, e As EventArgs) Handles btnAddErroCode.Click
            If cboFault.SelectedValue = "0" Or ddlQuantity.SelectedValue = "0" Then
                lblErrorCodeMessage.Text = "Please select both a Error Code and quantity."
                lblErrorCodeMessage.ForeColor = System.Drawing.Color.Red
            Else
                Dim selectedFaultID As Integer = Integer.Parse(cboFault.SelectedItem.Value)
                Dim selectedFault As String = cboFault.SelectedItem.Text
                Dim selectedQuantity As Integer = Integer.Parse(ddlQuantity.SelectedItem.Text)

                Dim eCode As ErrorCode = New ErrorCode() With {
                    .FaultID = selectedFaultID,
                    .ErrorCode = selectedFault,
                    .Quantity = selectedQuantity
                }

                If Not (ErrorCodeList.Find(Function(s) s.FaultID = eCode.FaultID) IsNot Nothing) Then
                    ErrorCodeList.Add(eCode)
                    ' Re-bind the GridView
                    BindErrorCodeGrid()
                    lblErrorCodeMessage.Text = ""
                    'lblErrorCodeMessage.Text = "Error Code added successfully."
                    'lblErrorCodeMessage.ForeColor = System.Drawing.Color.Green
                    'cboFault.SelectedIndex = 0
                    ddlQuantity.SelectedIndex = 0
                Else
                    lblErrorCodeMessage.Text = "Error Code already exist!"
                End If
            End If
        End Sub

        Private Sub BindErrorCodeGrid()
            ' If SkillsList is empty, create a dummy row
            If ErrorCodeList Is Nothing OrElse ErrorCodeList.Count = 0 Then
                ' Create a dummy list with one empty skill
                Dim dummyList As New List(Of ErrorCode) From {
                    New ErrorCode With {.FaultID = -4, .ErrorCode = String.Empty, .Quantity = 0}
                }
                gvErrorCodes.DataSource = dummyList
                gvErrorCodes.DataBind()

                ' Hide the dummy row after it's bound (in RowDataBound)
            Else
                gvErrorCodes.DataSource = ErrorCodeList
                gvErrorCodes.DataBind()
            End If
        End Sub

        Protected Sub GvErrorCodes_RowCommand(sender As Object, e As GridViewCommandEventArgs)
            If e.CommandName = "Remove" Then
                Dim rowIndex As Integer = Convert.ToInt32(e.CommandArgument)
                ErrorCodeList.RemoveAt(rowIndex)
                BindErrorCodeGrid()
                lblErrorCodeMessage.Text = ""
                ' lblMessage.Text = "ErrorCode removed successfully."
                ' lblMessage.ForeColor = System.Drawing.Color.Green
            End If
        End Sub

        Private Sub LogJob_Load(sender As Object, e As EventArgs) Handles Me.Load

        End Sub

        'Protected Sub cboCallType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cboCallType.SelectedIndexChanged
        '    Call PopulateSymptom(Convert.ToInt32(cboCallType.SelectedValue))
        'End Sub

        'Protected Sub cboSymptom_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cboSymptom.SelectedIndexChanged
        '    Call PopulateFault(Convert.ToInt32(cboSymptom.SelectedValue))

        'End Sub

#End Region

    End Class
End Namespace
