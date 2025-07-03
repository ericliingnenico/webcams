#Region "vss"
'<!--$$Revision: 9 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 24/04/13 13:52 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Imports System.Data
Imports System.Drawing
Imports AjaxControlToolkit

Namespace eCAMS

Public Class FSPJob
    Inherits FSPJobPageBase

#Region "Function"

    Protected Overrides Sub GetContext()
        With Request
            m_jobID = Convert.ToInt64(.Item("JID"))
        End With
    End Sub

    Protected Overrides Sub Process()
        SetDE()
        BindGrid(1)
        BindGrid(2)
        PopulatePartsCbo(cboParts,panelJobParts.Visible)
    End Sub
    Protected Overrides Sub AddClientScript()
        ''tie these textboxes to corresponding buttons
        TieButton(txtJobIDDE, btnGetJob)



        TieButton(txtQty, btnAddParts)

        TieButton(txtOnSiteDate, btnClose)
        TieButton(txtOnSiteTime, btnClose)
        TieButton(txtOffSiteDate, btnClose)
        TieButton(txtOffSiteTime, btnClose)

        ''add onblur to txtJobIDE
        txtJobIDDE.Attributes.Add("onblur", "if (isNaN(document.getElementById('" & txtJobIDDE.ClientID & "').value)) {alert('JobID must be a number'); document.getElementById('" & txtJobIDDE.ClientID & "').focus(); return false;}")

        ''add onclik to btnGetJob
        btnGetJob.Attributes.Add("onclick", "SetJobValidator();")

        ''add onclick to btnAddDevice
        btnAddDevice.Attributes.Add("onclick", "SetDeviceValidator();")

        ''add onclick to btnAddDevice
        btnUpdateSIM.Attributes.Add("onclick", "SetSIMValidator();")

        ''add onblur to txtOnSiteDate
        txtOnSiteDate.Attributes.Add("onblur", "CopyOnSiteDateToOffSiteDate();")

        ''add onlcik to btnAddParts
        btnAddParts.Attributes.Add("onclick", "SetPartsValidator();")

        btnConfirmKittedPartsUsage.Attributes.Add("onclick", "ResetAllValidators();")

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
            btnClose.Attributes.Add("onclick", "if (validateinput() == false) {return false}; if (IsOnSiteAfterHourStopper()) {return false}; SetClosureValidator();") ''add onclick to btnClose with input validator as well
        Else
            ''add onclick to btnClose
            btnClose.Attributes.Add("onclick", "if (IsOnSiteAfterHourStopper()) {return false}; SetClosureValidator();")
        End If

        ''add onlcik to btnEscalateJob
        btnEscalateJob.Attributes.Add("onclick", "SetEscalateValidator();")

        ''add onlcik to btnAddJobNotes
        btnAddJobNotes.Attributes.Add("onclick", "SetJobNotesValidator();")
    End Sub
    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.DeskTop
    End Sub

    Private Sub SetDE()
        Me.PageTitle = "FSPJob"

        ''Set Info Label
        lblFormTitle.Text = "" 

        ''retrieve job details only jobid passed in
        If Not m_jobID Is Nothing Then
            m_DataLayer.GetFSPJobClosure(CType(m_jobID, Long))
            DisplayJobPanel()
            DisplayDevicePanel()
            DisplayExceptionPanel()
            DisplayClosurePanel()
        End If

    End Sub
    Private Sub GetPostbackJobID()
        m_jobID = Convert.ToInt64(txtJobID.Value)
    End Sub


    Private Sub DisplayJobPanel()
        txtJobID.Value = String.Empty
        txtJobIDDE.Text = String.Empty
        txtJobType.Text = String.Empty
            txtMerchant.Text = String.Empty
            txtClientID.Value = String.Empty

            If m_DataLayer.dsJob.Tables.Count > 0 Then
                If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                    txtJobID.Value = m_jobID.ToString
                    txtJobIDDE.Text = m_jobID.ToString

                    txtJobType.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType"))
                    txtMerchant.Text = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("MerchantName"))
                    txtClientID.Value = Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("ClientID"))
                Else
                    DisplayErrorMessage(lblMsg, String.Format("Job [{0}] does not exist.", m_jobID.ToString))
            End If

        End If
    End Sub
    Private Sub DisplayDevicePanel()
        ''set defaults
        txtDeviceOut.Enabled = True
			txtDeviceOut.Width = Unit.Pixel(220)
			txtDeviceIn.Enabled = True
			txtDeviceIn.Width = Unit.Pixel(220)

        ''clear
        txtDeviceOut.Text = String.Empty
        txtDeviceIn.Text = String.Empty

        ''reset based on job type
        If m_DataLayer.dsJob.Tables.Count > 0 Then
            If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                If Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType")) = "INSTALL" Then
                    txtDeviceOut.Enabled = False
                    txtDeviceOut.Width = Unit.Pixel(1)
                End If
                If Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType")) = "DEINSTALL" Then
                    txtDeviceIn.Enabled = False
                    txtDeviceIn.Width = Unit.Pixel(1)
                End If
            End If
        End If
        ''tie button or modifyenter key for the deviceout which in pair
        If txtDeviceOut.Enabled and txtDeviceIn.Enabled then
            Call ModifyEnterKeyPressAsTab(txtDeviceOut,txtDeviceIn)
            Call TieButton(txtDeviceIn,btnAddDevice)
        Else If txtDeviceIn.Enabled then
                Call TieButton(txtDeviceIn,btnAddDevice)
            Else If txtDeviceOut.Enabled then
                    Call TieButton(txtDeviceOut,btnAddDevice)
        End If

    End Sub

    Private Sub DisplayClosurePanel()
        txtOnSiteDate.Text = String.Empty
        txtOnSiteTime.Text = String.Empty
        txtOffSiteDate.Text = String.Empty
        txtOffSiteTime.Text = String.Empty

        'panelSIMSwap.Visible = False

        If m_DataLayer.dsJob.Tables.Count > 0 Then
            If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                'If Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType")) IsNot "DEINSTALL" Then
                '    panelSIMSwap.Visible = True
                'End If
                If Not m_DataLayer.dsJob.Tables(0).Rows(0)("OnSiteDateTime") Is DBNull.Value Then
                    txtOnSiteDate.Text = Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("OnSiteDateTime")).ToString("dd/MM/yy")
                    txtOnSiteTime.Text = Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("OnSiteDateTime")).ToString("HHmm")
                End If
                If Not m_DataLayer.dsJob.Tables(0).Rows(0)("OffSiteDateTime") Is DBNull.Value Then
                    txtOffSiteDate.Text = Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("OffSiteDateTime")).ToString("dd/MM/yy")
                    txtOffSiteTime.Text = Convert.ToDateTime(m_DataLayer.dsJob.Tables(0).Rows(0)("OffSiteDateTime")).ToString("HHmm")
                End If
            End If
        End If

        PopulateTechFixCbo(cboTechFix,true,txtJobType.Text)
        PopulateEscalateReasonCbo(cboEscalateReason, true)
    End Sub
    Private Sub DisplayExceptionPanel()
        Dim dlResult As DataLayerResult
        Dim ds As DataSet

        dlResult = m_DataLayer.GetJobExceptionList(CType(m_jobID, Long))

        If dlResult = DataLayerResult.Success AndAlso m_DataLayer.dsExceptions.Tables.Count > 0 AndAlso m_DataLayer.dsExceptions.Tables(0).Rows.Count > 0 Then
            Me.PageTitle = "Job Exception"
            panelException.Visible=True
            ds = m_DataLayer.dsExceptions
            grdException.DataSource = ds.Tables(0)
            grdException.DataBind()
        Else
            panelException.Visible=False
            grdException.DataSource = Nothing
            grdException.DataBind()
        End If
    End Sub

    Private Sub BindGrid(ByVal pWhichGrid As Int16)
    ''pWhichGrid:   1 - Job Device Grid
    ''              2 - Job Parts Grid
        Dim dlResult As DataLayerResult
        Dim ds As New DataSet

        If pWhichGrid = 1 Then
            dlResult = m_DataLayer.GetFSPJobEquipment(CType(m_jobID, Long))
            If dlResult = DataLayerResult.Success AndAlso m_DataLayer.dsDevices.Tables.Count > 0 Then
                ds = m_DataLayer.dsDevices

                grd.DataSource = ds.Tables(0)
                grd.DataKeyField = "Keys"
                    grd.DataBind()
                Else
                grd.DataSource = Nothing
                grd.DataBind()
            End If

        End If
        If pWhichGrid = 2 Then
            dlResult = m_DataLayer.GetFSPJobParts(CType(m_jobID, Long))
            If dlResult = DataLayerResult.Success AndAlso m_DataLayer.dsDevices.Tables.Count > 0 Then
                ds = m_DataLayer.dsDevices

                grdParts.DataSource = ds.Tables(0)
                grdParts.DataKeyField = "Keys"
                grdParts.DataBind()
            Else
                grdParts.DataSource = Nothing
                grdParts.DataBind()
            End If
            ''show/hide fsp confirm kitted parts usage button
            RenderFSPKittedPartsUsageButton(panelConfirmKittedPartsUsage)

        End If

    End Sub

    Protected Overloads Sub RenderSiteSurvey()
        ''in case the routine is called from page_load ro reinstate the viewstate
        If m_jobID is Nothing then
            m_jobID = CType(txtJobIDDE.Text, Long)

        End If
        If m_DataLayer.GetSurvey(Convert.ToString(m_jobID)) = DataLayerResult.Success  AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0  then
            ''set Survery ID to hidden field
            txtSurveyID.Value=m_DataLayer.dsTemp.Tables(0).Rows(0)("SurveyID").ToString
            MyBase.RenderSiteSurvey(panelSurvey,m_DataLayer.dsTemp.Tables(0))
        End If
    End Sub

    Private Sub ReloadJob()
        Response.Redirect("FSPJob.aspx?JID=" & txtJobIDDE.Text)
    End Sub
#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        RenderSiteSurvey()  ''need to recreate the dynamic control on each round trip in order to get view state!!!
        AddClientScript()  ''due to dynamicaly generating objects, need to reattach the java scripts
    End Sub
    Private Sub btnGetJob_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnGetJob.ServerClick
        Call ReloadJob()
        'PositionMsgLabel(placeholderJob, lblMsg)
        'm_jobID = CType(txtJobIDDE.Text, Long)
        'Process()
    End Sub


    Private Sub grd_MerchantDamagedCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridCommandEventArgs) Handles grd.ItemCommand
        GetPostbackJobID()
        PositionMsgLabel(placeholderDevice, lblMsg)

        Dim keyValue As String
        keyValue = Convert.ToString(grd.DataKeys(e.Item.ItemIndex))

        Dim myDeviceKey As DeviceKey
        myDeviceKey = GetDeviceKey(keyValue)

        Try
            Select Case e.CommandName.ToUpper
                Case "EDIT"
                    grd.EditItemIndex = e.Item.ItemIndex
                    grd.SelectedIndex = e.Item.ItemIndex

                Case "CANCEL"
                    grd.EditItemIndex = -1
                    grd.SelectedIndex = e.Item.ItemIndex

                Case "DELETE"
                    m_DataLayer.DelFSPJobEquipment(CType(m_jobID, Long), myDeviceKey.Serial, myDeviceKey.MMD_ID, myDeviceKey.Action)

                Case "UPDATE"
                    Dim UpdatedValue As String
                    UpdatedValue = CType(e.Item.Cells(3).Controls(0), TextBox).Text

                    m_DataLayer.UpdateFSPJobEquipment(CType(m_jobID, Long), myDeviceKey.Serial, myDeviceKey.MMD_ID, UpdatedValue, myDeviceKey.MMD_ID, myDeviceKey.Action)
                    grd.SelectedIndex = e.Item.ItemIndex
                    ReloadJob  ''need to rebind parts grid due to parts appended by kitted device 
                Case "MERCHANTDAMAGED"
                    m_DataLayer.SetMerchantDamaged(CType(m_jobID, Long), myDeviceKey.Serial, myDeviceKey.MMD_ID, true)

            End Select
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try

        BindGrid(1)
        grd.DataBind()

    End Sub

        Private Sub btnAddDevice_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnAddDevice.ServerClick
            GetPostbackJobID()
            PositionMsgLabel(placeholderDevice, lblMsg)

            Call AddDevice(txtDeviceIn, txtDeviceOut)

            BindGrid(1)
            ''only reload parts if there is no error
            If lblMsg.Text = "" Then
                ReloadJob  ''need to rebind parts grid due to parts appended by kitted device 
            End If
        End Sub

        Private Sub btnUpdateSIM_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnUpdateSIM.ServerClick
            GetPostbackJobID()
            PositionMsgLabel(placeholderSIMSwap, lblMsg)
            lblSIMSwapSuccessful.Visible = False

            Call SwapSIM(txtSIMOut, txtSIMIn)

            If lblMsg.Text = "" Then
                lblSIMSwapSuccessful.Visible = True
            End If
        End Sub

        Protected Sub btnAddParts_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddParts.ServerClick
        GetPostbackJobID()
        PositionMsgLabel(placeholderParts, lblMsg)

        Call AddParts(cboParts.SelectedValue, txtQty)

        BindGrid(2)
    End Sub


    Private Sub btnClose_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.ServerClick
        GetPostbackJobID()
        PositionMsgLabel(placeholderClosure, lblMsg)

            If CloseJob(Convert.ToDateTime(txtOnSiteDate.Text & " " & txtOnSiteTime.Text.Insert(2, ":") & ":00"),
                    Convert.ToDateTime(txtOffSiteDate.Text & " " & txtOffSiteTime.Text.Insert(2, ":") & ":00"),
                    CType(cboTechFix.SelectedValue, Short),
                    txtNotes.Text,
                    txtSurveyID.Value,
                    GetMissingParts(chkMissingParts), 'Handle missing parts CAMS-835,
                    CShort(RenderingStyleType.DeskTop)) Then

                panelDetail.Visible = False
                lblFormTitle.Text = "Job closure details have been posted successfully."
            End If

        End Sub

    Private Sub grd_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs) Handles grd.ItemDataBound
        ''why do we choose ItemDataBound event? We can access Action and DeviceName column in this event to display confirmation message.
        ''The values of these columns are not available at grd_ItemCreated event.
        Dim itemType As ListItemType = e.Item.ItemType

        If ((itemType = ListItemType.Pager) Or (itemType = ListItemType.Header) Or (itemType = ListItemType.Footer)) Then
            Return
        Else

            Try
                Dim buttonDel As LinkButton = CType(e.Item.Cells(1).Controls(0), LinkButton)
                Dim javascript As String

                If buttonDel.Text.ToUpper = "DELETE" Then
                    ''build javascript for the confirmation when clicking delete button
                    javascript = "return confirm('Are you sure to delete DEVICE-" + e.Item.Cells(4).Text + " [" + e.Item.Cells(3).Text + "]?')"
                    buttonDel.Attributes("onclick") = javascript
                End If

                Dim buttonMD As LinkButton = CType(e.Item.Cells(6).Controls(0), LinkButton)
                If buttonMD.Text.ToUpper = "MERCHANTDAMAGED" Then
                    If e.Item.Cells(2).Text.ToUpper <> "OUT" then
                        buttonMD.Visible = False
                    Else
                        ''build javascript for the confirmation when clicking delete button
                        javascript = "return confirm('Are you sure to mark the DEVICE-" + e.Item.Cells(4).Text + " [" + e.Item.Cells(3).Text + "] as MerchantDamaged?')"
                        buttonMD.Attributes("onclick") = javascript
                    End If
                End If

            Catch ex As Exception
                ''silence the error
            End Try
        End If
    End Sub

    Private Sub grdParts_DeleteCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataGridCommandEventArgs) Handles grdParts.DeleteCommand
        GetPostbackJobID()
        PositionMsgLabel(placeholderParts, lblMsg)

        Dim keyValue As String
        keyValue = Convert.ToString(grdParts.DataKeys(e.Item.ItemIndex))


        Try
            m_DataLayer.DelFSPJobParts(CType(m_jobID, Long), keyValue)
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try

        BindGrid(2)
        grdParts.DataBind()

    End Sub
    Private Sub grdParts_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs) Handles grdParts.ItemDataBound
        ''why do we choose ItemDataBound event? We can access Action and DeviceName column in this event to display confirmation message.
        ''The values of these columns are not available at grd_ItemCreated event.
        Dim itemType As ListItemType = e.Item.ItemType
        If ((itemType = ListItemType.Pager) Or (itemType = ListItemType.Header) Or (itemType = ListItemType.Footer)) Then
            Return
        Else
            Try
                Dim button As LinkButton = CType(e.Item.Cells(0).Controls(0), LinkButton)
                Dim javascript As String

                If button.Text.ToUpper = "DELETE" Then
                    ''build javascript for the confirmation when clicking delete button
                    javascript = "return confirm('Are you sure to delete this Parts-" + e.Item.Cells(1).Text + " [" + e.Item.Cells(3).Text + "]?')"
                    button.Attributes("onclick") = javascript
                End If
            Catch ex As Exception
                ''silence the error
            End Try
        End If
    End Sub

    Private Sub btnAddJobNotes_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs)  Handles btnAddJobNotes.ServerClick
        GetPostbackJobID()
        PositionMsgLabel(placeholderAddJobNotes, lblMsg)

        Call AddJobNote(txtJobNotes) 
    End Sub

    Private Sub btnEscalateJob_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs)  Handles btnEscalateJob.ServerClick
        GetPostbackJobID()
        PositionMsgLabel(placeholderEscalateJob, lblMsg)

        Call EscalateJob(CType(cboEscalateReason.SelectedValue, Short), txtEscalateNotes) 
    End Sub



    Private Sub fuJobSheet_UploadedComplete(ByVal sender As Object, ByVal e As AjaxControlToolkit.AsyncFileUploadEventArgs) Handles fuJobSheet.UploadedComplete

            'upload JobSheet
            'verify the file content type - the file must be image (jpeg, pnp..) or pdf
            If fuJobSheet.PostedFile.ContentType.StartsWith("image/") or fuJobSheet.PostedFile.ContentType.EndsWith("/pdf") then
                If fuJobSheet.PostedFile.ContentLength < 5000000 then
                    m_DataLayer.UploadMerchantSignedJobSheet(CType(m_jobID, Long),fuJobSheet.FileBytes, fuJobSheet.PostedFile.ContentType)
                Else
                    DisplayErrorMessage(lblMsg, "Invalid file size-must less than 4M") ''not partial rendering, use client side instead
                End If
                
            Else
                DisplayErrorMessage(lblMsg, "Invalid file content type") ''not partial rendering, use client side instead
            End If

    End Sub
        Protected Sub btnConfirmKittedPartsUsage_Click(sender As Object, e As EventArgs) Handles btnConfirmKittedPartsUsage.ServerClick
            GetPostbackJobID()
            PositionMsgLabel(placeholderParts, lblMsg) ''floating the error label to device page
            Call ConfirmKittedPartsUsage
            ''refresh page
            Call ReloadJob()
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

#End Region

    End Class
End Namespace