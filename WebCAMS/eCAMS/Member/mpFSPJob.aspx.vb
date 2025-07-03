#Region "vss"
'<!--$$Revision: 26 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 1/08/16 15:13 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing
Imports System.Security.Cryptography
Imports System.IO
Imports System.Linq
Imports System.Security.Claims
Imports System.IdentityModel.Tokens.Jwt
Imports Microsoft.IdentityModel.Tokens
Imports System.Text.Json
Imports System.Web.HttpContext
Imports eCAMS.AuthWS

Namespace eCAMS

    Partial Class mpFSPJob
        Inherits FSPJobPageBase

        Private m_page As Object
        Private m_action As Object
        Protected m_sigJASON As String
        Private m_lat As String
        Private m_lon As String
        Private Enum pageIndex
            Merchant = 1
            Device = 2
            Survey = 3
            Closure = 4
        End Enum
        Protected Enum sigSize
            width = 300
            height = 200
        End Enum

        Protected Overrides Sub GetContext()
            With Request
                If Not .Item("id") Is Nothing Then
                    m_jobID = Convert.ToInt64(.Item("id"))
                End If
                If Not .Item("p") Is Nothing Then
                    m_page = Convert.ToUInt16(.Item("p"))
                End If
                If Not .Item("a") Is Nothing Then
                    m_action = Convert.ToUInt16(.Item("a"))
                End If
                If Not .Item("lat") Is Nothing Then
                    m_lat = Convert.ToString(.Item("lat"))
                End If
                If Not .Item("lon") Is Nothing Then
                    m_lon = Convert.ToString(.Item("lon"))
                End If
            End With
        End Sub

        Protected Overrides Sub Process()
            SetDE()
            PopulatePartsCbo(cboParts, panelDevicePage.Visible)
            PopulateTechFixCbo(cboTechFix, panelClosurePage.Visible, "")
            PopulateEscalateReasonCbo(cboEscalateReason, panelClosurePage.Visible)
            Dim testInit As UInt16
            If CType(m_page, UInt16) = pageIndex.Merchant AndAlso Not m_action Is Nothing AndAlso UInt16.TryParse(m_action.ToString, testInit) Then
                Select Case CType(m_action, UInt16)
                    Case 1
                        SetJobAsFSPOnSite()
                        ''to do more cases
                End Select

            End If
        End Sub
        Protected Overrides Sub AddClientScript()
            If CType(m_page, UInt16) = pageIndex.Survey Then
                If Not Me.panelSurveyPage Is Nothing Then
                    ''build java script to validate Site Survey selection
                    If m_javaScript.Length > 0 Then
                        ''trim the last && 
                        m_javaScript = Left(m_javaScript, Len(m_javaScript) - 3)

                        'function validateinput(){
                        'if (!((document.getElementById("<%=RADIO_67_Yes.ClientID%>").checked || document.getElementById("<%=RADIO_67_No.ClientID%>").checked)
                        '		&& (document.getElementById("<%=RADIO_67_Yes.ClientID%>").checked || document.getElementById("<%=RADIO_67_No.ClientID%>").checked))) {
                        '		alert("Please complete site survey.");
                        '		return false;
                        '	}
                        '	return true;
                        '}

                        m_javaScript = "<SCRIPT LANGUAGE=""JavaScript""> function validateinput(){if (!(" + m_javaScript + ")) {alert(""Please complete site survey.""); return false;} return true;} </SCRIPT>"
                        Me.Page.ClientScript.RegisterClientScriptBlock(Me.Page.GetType, "jvvalidateinput", m_javaScript)
                        ''Me.btnSurveySave.Attributes.Add("onclick", "if (validateinput() == false) {return false};SetClosureValidator();") ''add onclick to btnClose with input validator as well
                        Me.btnSurveySave.Attributes.Add("onclick", "if (validateinput() == false) {return false};") ''add onclick to btnClose with input validator as well
                    End If

                End If

            End If

        End Sub
        Protected Overrides Sub SetRenderingStyle()
            m_renderingStyle = RenderingStyleType.PDA
        End Sub

        Protected Function GetWebchatClients() As Dictionary(Of String, String)
            Dim clients As New Dictionary(Of String, String)
            Dim config As String() = ConfigurationManager.AppSettings("EnableWebChat").Split(","c)

            For Each client As String In config
                Dim c As String() = client.Split("|"c)
                clients.Add(c(0), c(1))
            Next

            Return clients
        End Function

        Protected Function WebchatEnabled(ClientID As String) As Boolean
            Return GetWebchatClients().ContainsKey(ClientID)
        End Function

        Protected Function GetWebchatQueue(ClientID As String) As String
            If (WebchatEnabled(ClientID)) Then
                Return GetWebchatClients().Item(ClientID)
            Else
                Return ""
            End If
        End Function

        Private Sub SetDE()
            txtJobID.Value = CStr(m_jobID)
            txtPage.Value = CStr(m_page)
            Call DisplayPage()
        End Sub
        Private Sub GetPostbackHiddenID()
            If m_jobID Is Nothing Then
                m_jobID = Convert.ToInt64(txtJobID.Value)
            End If
            If m_page Is Nothing Then
                m_page = Convert.ToInt64(txtPage.Value)
            End If
        End Sub

        Private Sub RenderQuadButton()
            Dim buttonString As String = ""
            ' ''in case the routine is called from page_load ro reinstate the viewstate
            'If m_page is Nothing then
            '    m_page = CType(txtPage.Value,UInt16)
            'End If
            If CType(m_page, UInt16) = pageIndex.Merchant Then
                buttonString += "<a id=""pressed"" href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=1"">Merchant</a>"
            Else
                buttonString += "<a href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=1"">Merchant</a>"
            End If
            If CType(m_page, UInt16) = pageIndex.Device Then
                buttonString += "<a id=""pressed"" href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=2"">Device</a>"
            Else
                buttonString += "<a href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=2"">Device</a>"
            End If
            If CType(m_page, UInt16) = pageIndex.Survey Then
                buttonString += "<a id=""pressed"" href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=3"">Survey</a>"
            Else
                buttonString += "<a href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=3"">Survey</a>"
            End If
            If CType(m_page, UInt16) = pageIndex.Closure Then
                buttonString += "<a id=""pressed"" href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=4"">Closure</a>"
            Else
                buttonString += "<a href=""mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=4"">Closure</a>"
            End If

            panelquadbutton.Controls.Add(New LiteralControl(buttonString))
        End Sub
        Private Sub DisplayPage()
            ''ToDo
            'panelHowTo.Visible = False ''hide HowTo until it is implmented to device level HowTo Document

            If Not m_DataLayer.CurrentUserInformation.CanUseNewPCAMS Then
                Response.Redirect("pFSPMain.aspx")
                Return
            End If
            panelMerchantPage.Visible = False
            panelDevicePage.Visible = False
            panelSurveyPage.Visible = False
            panelSignaturePage.Visible = False
            panelClosurePage.Visible = False
            panelSignatureSignedPage.Visible = False
            Select Case CUShort(m_page)
                Case CUShort(pageIndex.Merchant)
                    DisplayMerchantPage()
                Case CUShort(pageIndex.Device)
                    DisplayDevicePage()
                Case CUShort(pageIndex.Survey)
                    DisplaySurveyPage()
                Case CUShort(pageIndex.Closure)
                    DisplayClosurePage()
            End Select
            If CUShort(m_page) > 0 Then
                lblJobInfo.Text = "JobNo: " + m_jobID.ToString
            End If
        End Sub
        Private Sub DisplayMerchantPage()
            panelMerchantPage.Visible = True
            If m_DataLayer.GetFSPJobSheetData(Convert.ToInt64(m_jobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsJob.Tables.Count > 0 Then
                'FormViewMerchant.DataSource = m_DataLayer.dsJob.Tables(0)
                'FormViewMerchant.DataBind
                ''**remove the extra rows since we use repeater to rendering merchant page
                While m_DataLayer.dsJob.Tables(0).Rows.Count > 1
                    m_DataLayer.dsJob.Tables(0).Rows(m_DataLayer.dsJob.Tables(0).Rows.Count - 1).Delete()
                    m_DataLayer.dsJob.Tables(0).AcceptChanges()
                End While
                RepeaterMerchant.DataSource = m_DataLayer.dsJob.Tables(0)
                RepeaterMerchant.DataBind()

                Dim row As DataRow = m_DataLayer.dsJob.Tables(0).Rows(0)

                If Not (row Is Nothing) Then
                    Dim clientIdStr As String = row("ClientID").ToString()
                    Dim enbaleChat As Boolean = WebchatEnabled(row("ClientID").ToString())
                    If (enbaleChat) Then
                        txtChatAuthToken.Value = GenerateAttributeToken(row("ClientID").ToString(), row("jobID").ToString(), row("installerID").ToString(), row("terminalID").ToString())
                    Else
                        txtChatAuthToken.Value = ""
                    End If
                End If

                'If Not CType(m_DataLayer.dsJob.Tables(0).Rows(0)("HasParentDepot"), Boolean) then
                Me.panelReassignJobBackToDepot.Visible = False
                'End If

                ''rendering KBHelp
                Call RenderJobFSPDownload(Nothing, RepeaterHowTo)


            End If
        End Sub
        Private Sub DisplayDevicePage()
            panelDevicePage.Visible = True
            'panelBundledSIMSwap.Visible = True

            If m_DataLayer.GetFSPJobEquipment(Convert.ToInt64(m_jobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsDevices.Tables.Count > 0 Then
                RepeaterDevice.DataSource = m_DataLayer.dsDevices.Tables(0)
                RepeaterDevice.DataBind()
            End If

            If m_DataLayer.GetFSPJobParts(CType(m_jobID, Long)) = DataLayerResult.Success AndAlso m_DataLayer.dsDevices.Tables.Count > 0 Then
                RepeaterParts.DataSource = m_DataLayer.dsDevices.Tables(0)
                RepeaterParts.DataBind()
            End If

            ''set defaults
            panelDeviceOut.Visible = True
            panelDeviceIn.Visible = True

            ''clear
            txtDeviceOut.Text = String.Empty
            txtDeviceIn.Text = String.Empty

            ''reset based on job type
            If m_DataLayer.GetFSPJob(Convert.ToInt64(m_jobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsJob.Tables.Count > 0 Then
                If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                    If Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType")) = "INSTALL" Then
                        panelDeviceOut.Visible = False
                        rfvDeviceOut.ControlToValidate = "txtDeviceIn" ''point the validating object to existing one to prevent validator failure
                        rfvDeviceOut.ErrorMessage = "" ''dismiss the double dips messages
                    End If
                    If Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType")) = "DEINSTALL" Then
                        panelDeviceIn.Visible = False
                        'panelBundledSIMSwap.Visible = False
                        rfvDeviceIn.ControlToValidate = "txtDeviceOut"
                        rfvDeviceIn.ErrorMessage = ""
                    End If
                    ''tie button or modifyenter key for the deviceout which in pair
                    If panelDeviceIn.Visible And panelDeviceOut.Visible Then
                        Call ModifyEnterKeyPressAsTab(txtDeviceOut, txtDeviceIn)
                        Call TieButton(txtDeviceIn, btnDeviceAdd)
                    ElseIf panelDeviceIn.Visible Then
                        Call TieButton(txtDeviceIn, btnDeviceAdd)
                    ElseIf panelDeviceOut.Visible Then
                        Call TieButton(txtDeviceOut, btnDeviceAdd)
                    End If
                End If
            End If

            Call TieButton(txtPartsQty, btnPartsAdd)

            ''show/hide fsp confirm kitted parts usage button
            RenderFSPKittedPartsUsageButton(panelConfirmKittedPartsUsage)
        End Sub
        Private Sub DisplaySurveyPage()
            ''which page to show: Signature or Survey
            If m_DataLayer.GetSurveyAnswer(Convert.ToString(m_jobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                panelSignaturePage.Visible = True
            Else
                ''if the survey not done yet, display survey
                If m_DataLayer.GetSurvey(Convert.ToString(m_jobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables.Count > 0 AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                    panelSurveyPage.Visible = True
                Else
                    ''no survey required, show signature pad
                    panelSignaturePage.Visible = True
                End If
            End If
            If panelSignaturePage.Visible = True Then
                Dim sigMerchantName As String = Nothing
                Dim sigWidth As Integer
                Dim sigHeight As Integer

                GetSignatureData(sigMerchantName, sigWidth, sigHeight, m_sigJASON)

                If m_sigJASON <> "" Then
                    panelSignaturePage.Visible = False
                    panelSignatureSignedPage.Visible = True
                    txtSignedMerchantName.Text = sigMerchantName
                End If
            End If
        End Sub
        Private Sub DisplayClosurePage()
            'Dim rounded As DateTime

            panelClosurePage.Visible = True
            PopulateOnSiteDateTime(txtOnSiteDate, txtOnSiteTime, txtOffSiteDate, txtOffSiteTime, txtTID, txtClientID)
        End Sub

        Private Overloads Sub RenderSiteSurvey()
            If panelSurveyPage.Visible Then
                If m_DataLayer.GetSurvey(Convert.ToString(m_jobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables.Count > 0 AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                    ''set Survery ID to hidden field
                    txtSurveyID.Value = m_DataLayer.dsTemp.Tables(0).Rows(0)("SurveyID").ToString
                    MyBase.RenderSiteSurvey(Me.panelSurvey, m_DataLayer.dsTemp.Tables(0))
                End If
            End If
        End Sub

        Private Sub SetJobAsFSPOnSite()
            PositionMsgLabel(placeholderMerchantPage, lblMsg) ''floating the error label to survey page

            Try
                ''save the survey results
                m_DataLayer.SetJobAsFSPOnSite(CType(m_jobID, Long), m_lat, m_lon)

            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try
        End Sub


        Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
            If Page.IsPostBack Then
                GetPostbackHiddenID()
            End If
            MyBase.Page_Load(sender, e)

            ''Need to rerender the button bar
            RenderQuadButton()
            RenderSiteSurvey()  ''need to recreate the dynamic control on each round trip in order to get view state!!!
            AddClientScript()

            Dim tempUserName As String = Server.HtmlEncode(CType(Current.Session("UserInfo"), UserInformation).UserName)
            txtDisplayName.Value = RemoveAfterAt(tempUserName)

        End Sub

        Protected Sub RepeaterDevice_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles RepeaterDevice.ItemCommand
            Dim btn As Button
            Dim UpdatedValue As String
            Dim myDeviceKey As DeviceKey

            PositionMsgLabel(placeholderDevicePage, lblMsg)
            btn = CType(e.CommandSource, Button)

            myDeviceKey = GetDeviceKey(e.CommandArgument.ToString)
            Try
                Select Case e.CommandName
                    Case "update"
                        UpdatedValue = CType(btn.Parent.FindControl("txtSerial"), TextBox).Text.ToUpper
                        m_DataLayer.UpdateFSPJobEquipment(CType(m_jobID, Long), myDeviceKey.Serial, myDeviceKey.MMD_ID, UpdatedValue, myDeviceKey.MMD_ID, myDeviceKey.Action)
                    Case "delete"
                        m_DataLayer.DelFSPJobEquipment(CType(m_jobID, Long), myDeviceKey.Serial, myDeviceKey.MMD_ID, myDeviceKey.Action)
                    Case "merchantdamaged"
                        m_DataLayer.SetMerchantDamaged(CType(m_jobID, Long), myDeviceKey.Serial, myDeviceKey.MMD_ID, True)
                End Select
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try

            ''refresh page
            DisplayPage()
        End Sub

        Protected Sub RepeaterDevice_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles RepeaterDevice.ItemDataBound
            ''why do we choose ItemDataBound event? We can access Action and DeviceName column in this event to display confirmation message.
            ''The values of these columns are not available at grd_ItemCreated event.
            Dim itemType As ListItemType = e.Item.ItemType

            If ((itemType = ListItemType.Pager) Or (itemType = ListItemType.Header) Or (itemType = ListItemType.Footer)) Then
                Return
            Else

                Try
                    Dim btn As Button = CType(e.Item.FindControl("btnDeviceUpdate"), Button)
                    Dim javascript As String

                    If Not btn Is Nothing Then
                        'Dim ri As RepeaterItem
                        'Dim txt As TextBox
                        'ri = CType(btn.Parent, RepeaterItem)
                        'txt = ctype(ri.FindControl("txtSerial"),TextBox)

                        ''normal java script no tilted toolbar problem on iphone4
                        javascript = "if (document.getElementById('" + e.Item.FindControl("txtSerial").ClientID + "').value.length == 0)  {alert('Please enter serial.');	return false;}	return true;"


                        btn.Attributes("onclick") = javascript

                        ''tie the textbox with this button
                        TieButton(e.Item.FindControl("txtSerial"), btn)
                    End If

                    btn = CType(e.Item.FindControl("btnDeviceDelete"), Button)
                    If Not btn Is Nothing Then
                        javascript = "return confirm('Are you sure to delete -" + DataBinder.Eval(e.Item.DataItem, "Device").ToString + " [" + DataBinder.Eval(e.Item.DataItem, "Serial").ToString + "]?')"
                        btn.Attributes("onclick") = javascript
                    End If

                    btn = CType(e.Item.FindControl("btnDeviceMerchantDamaged"), Button)
                    If Not btn Is Nothing Then

                        If DataBinder.Eval(e.Item.DataItem, "Action").ToString.ToUpper <> "OUT" Or DataBinder.Eval(e.Item.DataItem, "Serial").ToString.Length < 16 Then
                            btn.Visible = False
                        Else
                            javascript = "return confirm('Are you sure to mark -" + DataBinder.Eval(e.Item.DataItem, "Device").ToString + " [" + DataBinder.Eval(e.Item.DataItem, "Serial").ToString + "] as merchant damaged?')"
                            btn.Attributes("onclick") = javascript
                        End If
                    End If

                Catch ex As Exception
                    ''silence the error
                End Try
            End If
        End Sub
        Protected Sub RepeaterParts_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles RepeaterParts.ItemDataBound
            ''why do we choose ItemDataBound event? We can access Action and DeviceName column in this event to display confirmation message.
            ''The values of these columns are not available at grd_ItemCreated event.
            Dim itemType As ListItemType = e.Item.ItemType

            If ((itemType = ListItemType.Pager) Or (itemType = ListItemType.Header) Or (itemType = ListItemType.Footer)) Then
                Return
            Else
                Try
                    Dim btn As Button
                    Dim javascript As String

                    btn = CType(e.Item.FindControl("btnPartsDelete"), Button)
                    If Not btn Is Nothing Then
                        javascript = "return confirm('Are you sure to delete -" + DataBinder.Eval(e.Item.DataItem, "Device").ToString + "?')"

                        btn.Attributes("onclick") = javascript

                    End If

                Catch ex As Exception
                    ''silence the error
                End Try
            End If
        End Sub
        Protected Sub RepeaterParts_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles RepeaterParts.ItemCommand
            Dim btn As Button

            PositionMsgLabel(placeholderDevicePage, lblMsg)

            btn = CType(e.CommandSource, Button)
            Select Case e.CommandName

                Case "delete"
                    ''Label1.Text = e.CommandArgument.ToString 

                    Try
                        m_DataLayer.DelFSPJobParts(CType(m_jobID, Long), e.CommandArgument.ToString)
                    Catch ex As Exception
                        DisplayErrorMessage(lblMsg, ex.Message)
                    End Try

            End Select

            ''refresh page
            DisplayPage()
        End Sub


        Protected Sub btnSurveySave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSurveySave.Click

            PositionMsgLabel(placeholderSurveyPage, lblMsg) ''floating the error label to survey page

            ''get the survey results
            Dim surveyResults As String
            surveyResults = GetSubmittedSurvey(txtSurveyID.Value, FindChildControl(Me.Page.Form, "panelSurvey"))
            Try
                ''save the survey results
                m_DataLayer.PutSurveyAnswer(CType(m_jobID, Long), surveyResults)

                ''show next page to capture signature
                DisplayPage()
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try
        End Sub

        Protected Sub btnSignatureSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSignatureSave.Click
            ' ''****this block codes are working perfectly, due to need to buy web signature control and save db as image , so put on hold
            'Try
            '    if Not WebSignature1.ExportToStreamOnly() then
            '        DisplayErrorMessage(lblMsg, "Capture signature failed, please sign again.")
            '        Return
            '    End If

            '    Dim myEncrypt As New Encryption64()
            '    Dim keyUsed As String = "$#@!%^7A"

            '    ''Encrypt the string
            '    Dim enData As byte() = myEncrypt.Encrypt(WebSignature1.imageBytes, keyUsed)


            '    ''m_DataLayer.PutMerchantAcceptance(CType(m_jobID, Long),WebSignature1.imageBytes,txtSurveyMerchantName.Text)
            '    m_DataLayer.PutMerchantAcceptance(CType(m_jobID, Long),enData,txtSurveyMerchantName.Text)

            '    Dim deData as Byte()=  myEncrypt.decrypt(enData, keyUsed)


            '    Dim img As Image
            '    'img = Image.FromStream(WebSignature1.imageMemoryStream)

            '    Dim memStream As MemoryStream = new MemoryStream(deData)
            '    img = Image.FromStream(memStream)

            '    Response.Clear()
            '    Response.ContentType = "image/jpeg"
            '    img.Save(Response.OutputStream, Imaging.ImageFormat.Jpeg)
            '    ''img.Save("C:\Content\eCAMSSource2010\eCAMS\p.Jpeg")
            '    'imageFromControl.ImageUrl = WebSignature1.ImageUrl
            'Catch ex As Exception
            '    DisplayErrorMessage(lblMsg, ex.Message)
            'End Try


            ''Dim enData As byte() = EECommon.SignatureData.GetEncryptedData(280,124,GetSignatureLines(sigJSON.Value))

            ''m_DataLayer.PutMerchantAcceptance(CType(m_jobID, Long),enData,txtSurveyMerchantName.Text)

            ''debug
            ''Response.Write (Me.sigJSON.Value)

            'Dim sg As New EECommon.SignatureData(endata)
            'Response.Write (sg.Width)
            'Response.Write (sg.Height)
            'For i = 0 to sg.Lines.Count-1
            '    Response.Write (sg.Lines(i).ToString + "<br>")
            'Next

            PositionMsgLabel(placeholderSignaturePage, lblMsg) ''floating the error label to survey page

            Try
                SaveSignatureData(txtSurveyMerchantName.Text, sigSize.width, sigSize.height, sigJSON.Value)

                ''show closure page
                Response.Redirect("mpFSPJob.aspx?id=" + m_jobID.ToString + "&p=4")
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)

            End Try
        End Sub


        Private Sub btnDeviceAdd_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDeviceAdd.Click
            PositionMsgLabel(placeholderDevicePage, lblMsg) ''floating the error label to device page

            Call AddDevice(txtDeviceIn, txtDeviceOut)

            DisplayPage()
        End Sub

        Protected Sub btnPartsAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnPartsAdd.Click
            PositionMsgLabel(placeholderDevicePage, lblMsg) ''floating the error label to device page

            Call AddParts(cboParts.SelectedValue, txtPartsQty)

            DisplayPage()
        End Sub

        Private Sub btnSwapSIM_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSwapSIM.Click
            PositionMsgLabel(placeholderDevicePage, lblMsg) ''floating the error label to device page

            Call SwapSIM(txtSIMOut, txtSIMIn)

            DisplayPage()
        End Sub

        'Private Sub FormViewMerchant_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles FormViewMerchant.DataBound
        '    Try
        '        Dim oPanel As Panel = CType(FormViewMerchant.FindControl("panelMerchantBusinessActivity"), Panel)
        '        If Not oPanel is Nothing andalso DataBinder.Eval(FormViewMerchant.DataItem, "BusinessActivity").ToString="" then
        '            oPanel.Visible = False
        '        End If

        '        oPanel = CType(FormViewMerchant.FindControl("panelSendMerchantDamagePhoto"), Panel)
        '        If Not oPanel is Nothing andalso DataBinder.Eval(FormViewMerchant.DataItem, "JobType").ToString="INSTALL" then
        '            oPanel.Visible = False
        '        End If

        '        oPanel = CType(FormViewMerchant.FindControl("panelReAssignJob"), Panel)
        '        If Not oPanel is Nothing andalso CType(DataBinder.Eval(FormViewMerchant.DataItem, "HasChildDepot"), Boolean)=false then
        '            oPanel.Visible = False
        '        End If

        '    Catch ex As Exception
        '        ''silence the error
        '    End Try

        'End Sub
        Protected Sub RepeaterMerchant_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles RepeaterMerchant.ItemDataBound
            ''why do we choose ItemDataBound event? We can access Action and DeviceName column in this event to display confirmation message.
            ''The values of these columns are not available at grd_ItemCreated event.
            Dim itemType As ListItemType = e.Item.ItemType

            If ((itemType = ListItemType.Pager) Or (itemType = ListItemType.Header) Or (itemType = ListItemType.Footer)) Then
                Return
            Else
                Try
                    Dim oPanel As Panel = CType(e.Item.FindControl("panelMerchantBusinessActivity"), Panel)
                    If Not oPanel Is Nothing AndAlso DataBinder.Eval(e.Item.DataItem, "BusinessActivity").ToString = "" Then
                        oPanel.Visible = False
                    End If

                    oPanel = CType(e.Item.FindControl("panelSendMerchantDamagePhoto"), Panel)
                    If Not oPanel Is Nothing AndAlso DataBinder.Eval(e.Item.DataItem, "JobType").ToString = "INSTALL" Then
                        oPanel.Visible = False
                    End If

                    oPanel = CType(e.Item.FindControl("panelReAssignJob"), Panel)
                    If Not oPanel Is Nothing AndAlso CType(DataBinder.Eval(e.Item.DataItem, "HasChildDepot"), Boolean) = False AndAlso CType(DataBinder.Eval(e.Item.DataItem, "HasParentDepot"), Boolean) = False Then
                        oPanel.Visible = False
                    End If
                    oPanel = CType(e.Item.FindControl("panelCallMerchantPhon1"), Panel)
                    If Not oPanel Is Nothing AndAlso CType(clsTool.NullToValue(DataBinder.Eval(e.Item.DataItem, "Phone1"), ""), String).Trim() = "" Then
                        oPanel.Visible = False
                    End If
                    oPanel = CType(e.Item.FindControl("panelCallMerchantPhon2"), Panel)
                    If Not oPanel Is Nothing AndAlso CType(clsTool.NullToValue(DataBinder.Eval(e.Item.DataItem, "Phone2"), ""), String).Trim() = "" Then
                        oPanel.Visible = False
                    End If

                Catch ex As Exception
                    ''silence the error
                End Try

            End If
        End Sub

        Private Sub btnClose_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
            PositionMsgLabel(placeholderClosurePage, lblMsg)

            If CloseJob(Convert.ToDateTime(txtOnSiteDate.Text & " " & txtOnSiteTime.Text.Insert(2, ":") & ":00"),
                            Convert.ToDateTime(txtOffSiteDate.Text & " " & txtOffSiteTime.Text.Insert(2, ":") & ":00"),
                            CType(cboTechFix.SelectedValue, Short),
                            txtNotes.Text,
                            "",
                            GetMissingParts(chkMissingParts), 'Handle missing parts CAMS-835
                            CShort(RenderingStyleType.PDA)) Then
                'redirect to job list "Job closure details have been posted successfully."
                Response.Redirect("mpFSPJobList.aspx")
            End If

        End Sub

        Protected Sub btnEscalateJob_Click(sender As Object, e As EventArgs) Handles btnEscalateJob.Click
            PositionMsgLabel(placeholderClosurePage, lblMsg)
            Call EscalateJob(CType(cboEscalateReason.SelectedValue, Short), txtEscalateNotes)
            ''refresh page
            DisplayPage()

        End Sub

        Protected Sub btnAddJobNote_Click(sender As Object, e As EventArgs) Handles btnAddJobNote.Click
            PositionMsgLabel(placeholderMerchantPage, lblMsg) ''floating the error label to merchant page
            Call AddJobNote(txtJobNote)
            ''refresh page
            DisplayPage()
        End Sub

        Protected Sub btnReassignBackToDepot_Click(sender As Object, e As EventArgs) Handles btnReassignBackToDepot.Click
            PositionMsgLabel(placeholderMerchantPage, lblMsg) ''floating the error label to merchant page
            If ReassignJobBackToDepot(txtReassignBackNote) Then
                Response.Redirect("mpFSPJobList.aspx")
            End If
            ''refresh page
            DisplayPage()

        End Sub

        Protected Sub btnConfirmKittedPartsUsage_Click(sender As Object, e As EventArgs) Handles btnConfirmKittedPartsUsage.Click
            PositionMsgLabel(placeholderDevicePage, lblMsg) ''floating the error label to device page
            Call ConfirmKittedPartsUsage()
            ''refresh page
            DisplayPage()
        End Sub

        Protected Sub btnFSPCallMerchant_Click(sender As Object, e As EventArgs) Handles btnFSPCallMerchant.Click
            PositionMsgLabel(placeholderMerchantPage, lblMsg) ''floating the error label to survey page

            FSPCallMerchant(txtPhoneNumber.Value) ''btnFSPCallMerchant.Text.ToString)
            ''refresh page
            DisplayPage()
        End Sub

        Private Sub cboTechFix_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboTechFix.SelectedIndexChanged
            Dim clients As String() = ConfigurationManager.AppSettings("EnableSelectMissingParts").Split(","c)

            If (cboTechFix.SelectedValue = "11" AndAlso clients.Contains(txtClientID.Value)) Then
                missingPartsPanel.Visible = True
                cvMissingParts.Enabled = True
                BindMissingPartsList(chkMissingParts)
            Else
                missingPartsPanel.Visible = False
                cvMissingParts.Enabled = False
            End If
        End Sub

        Protected Function GenerateAttributeToken(clientID As String, jobID As String, installerID As String, terminalID As String) As String

            Dim widgetId As String = ConfigurationManager.AppSettings("WidgetId")
            Dim secretKey As String = ConfigurationManager.AppSettings("ConnectSecretKey")
            Dim utcNow As DateTime = DateTime.UtcNow
            Dim expTime As DateTime = utcNow.AddSeconds(1800) ' Set the expiration time in seconds (30 minutes)

            Dim claims As New List(Of Claim)()
            claims.Add(New Claim(JwtRegisteredClaimNames.Sub, widgetId))
            claims.Add(New Claim(JwtRegisteredClaimNames.Iat, EpochTime.GetIntDate(utcNow).ToString(), ClaimValueTypes.Integer64))
            claims.Add(New Claim(JwtRegisteredClaimNames.Exp, EpochTime.GetIntDate(expTime).ToString(), ClaimValueTypes.Integer64))

            Dim attribPayload As New Dictionary(Of String, Object)() From {
                    {"clientID", clientID},
                    {"tID", terminalID},
                    {"installerID", installerID},
                    {"jobID", jobID},
                    {"queueID", GetWebchatQueue(clientID)}
                }

            Dim payloadStr As String = JsonSerializer.Serialize(attribPayload)
            claims.Add(New Claim("attributes", payloadStr, JsonClaimValueTypes.Json))

            Dim securityKey As New Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
            Dim credentials As New Microsoft.IdentityModel.Tokens.SigningCredentials(securityKey, Microsoft.IdentityModel.Tokens.SecurityAlgorithms.HmacSha256)
            Dim jwtHeader As New JwtHeader(credentials)

            Dim jwtPayload As New JwtPayload(claims)
            Dim jwtToken As New JwtSecurityToken(jwtHeader, jwtPayload)
            Dim jwtHandler As New JwtSecurityTokenHandler()
            Dim encodedToken As String = jwtHandler.WriteToken(jwtToken)

            Return encodedToken

        End Function

        Public Function RemoveAfterAt(str As String) As String
            Dim index As Integer = str.IndexOf("@")
            If index >= 0 Then
                Return str.Substring(0, index)
            Else
                Return str
            End If
        End Function
    End Class
End Namespace