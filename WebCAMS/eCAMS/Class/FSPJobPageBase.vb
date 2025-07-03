#Region "vss"
'<!--$$Revision: 12 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 1/08/16 15:11 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPJobPageBase.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Data
Imports System.Drawing
Imports AjaxControlToolkit
Namespace eCAMS

Public Class FSPJobPageBase
    Inherits MemberPageBase

    Protected Structure DeviceKey
        Dim MMD_ID As String
        Dim Serial As String
        Dim Action As Int16
    End Structure

    Protected m_jobID As Object ''define as object for the purpose to use nothing 
    Protected m_javaScript As String = ""
    Protected lblMsg As New Label

    Protected Function GetDeviceKey(ByVal pKeyValue As String) As DeviceKey
        ''parse keys to devicekey structure and return
        Dim myDeviceKey As New DeviceKey
        Dim keys() As String

        ''Keys = 'REMOVE^' + je.MMD_ID + '^' + je.Serial
        keys = pKeyValue.Split("^".ToCharArray())

        If keys.Length <> 3 Then
            Return Nothing
        End If

        myDeviceKey.Action = Convert.ToInt16(IIf(keys(0) = "REMOVE", 2, 1))
        myDeviceKey.MMD_ID = keys(1)
        myDeviceKey.Serial = keys(2)

        Return myDeviceKey

    End Function
    Protected Overridable Function GetSubmittedSurvey(ByVal pSurveyID As String, ByVal pControlContainer As Control) As String
        Dim strTemp As String = "" '' <root><survey><surveyid>1</surveyid><questionid>2</questionid><answer>YES</answer></survey></root>
        Dim oControl As Control
        If Not pControlContainer Is Nothing Then
            For Each oControl In pControlContainer.Controls
                If TypeOf (oControl) Is RadioButton AndAlso oControl.ID.Contains(GetRenderingControlPrefix("WebSurvey",RenderingControlType.Radio)) AndAlso CType(oControl, RadioButton).Checked Then
                    strTemp = strTemp + "<survey><surveyid>" + pSurveyID + "</surveyid><questionid>" + Ctype(oControl,RadioButton).ID.Split({"_"c})(2)  + "</questionid><answer>" + Ctype(oControl,RadioButton).Text + "</answer></survey>" 
                End If
                If TypeOf (oControl) Is DropDownList AndAlso oControl.ID.Contains(GetRenderingControlPrefix("WebSurvey",RenderingControlType.Combo))  Then
                    strTemp = strTemp + "<survey><surveyid>" + pSurveyID + "</surveyid><questionid>" + Ctype(oControl,DropDownList).ID.Split({"_"c})(1)  + "</questionid><answer>" + CType(oControl, DropDownList).SelectedValue + "</answer></survey>" 
                End If
                If TypeOf (oControl) Is TextBox AndAlso oControl.ID.Contains(GetRenderingControlPrefix("WebSurvey",RenderingControlType.Text)) AndAlso CType(oControl, TextBox).Text<>"" Then
                    strTemp = strTemp + "<survey><surveyid>" + pSurveyID + "</surveyid><questionid>" + Ctype(oControl,TextBox).ID.Split({"_"c})(1)  + "</questionid><answer>" + Ctype(oControl,TextBox).Text + "</answer></survey>" 
                End If

            Next
        End If

        Return "<root>" + strTemp + "</root>"
    End Function
    Protected Overridable Sub RenderSiteSurvey(ByVal pSurveyPanel As Panel, byval pSurveyData As DataTable)
        Dim dr As DataRow
        For Each dr In pSurveyData.Rows
            ''Radio Button
            If dr.Item("QuestionTypeID").ToString = "1" Then
                Dim oRadioYes As New RadioButton
                Dim oRadioNo As New RadioButton
                Dim oLbl As New Label()
                oRadioYes.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Radio) + "Yes_" + dr.Item("QuestionID").ToString
                oRadioYes.Text = "Yes"
                oRadioYes.GroupName = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Radio) + dr.Item("QuestionID").ToString  ''forced only one selection

                oRadioNo.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Radio) + "No_" +dr.Item("QuestionID").ToString
                oRadioNo.Text = "No"
                oRadioNo.GroupName = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Radio) + dr.Item("QuestionID").ToString  ''forced only one selection

                oLbl.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Label) + dr.Item("QuestionID").ToString
                oLbl.Text = dr.Item("Text").ToString
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    oRadioYes.CssClass = "FormDEField"
                    oRadioNo.CssClass = "FormDEField"
                    pSurveyPanel.Controls.Add(New LiteralControl("<TR><TD width=""10""></TD><TD width=""560"">"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("<li class=""textbox""><span class=""survey""><p>"))
                End If
                pSurveyPanel.Controls.Add(oLbl)
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("</TD><TD>"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("</p><p>"))
                End If
                pSurveyPanel.Controls.Add(oRadioYes)

                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("<span class=""right"">"))
                Else
                    pSurveyPanel.Controls.Add(New LiteralControl("&nbsp;"))
                End If
                pSurveyPanel.Controls.Add(oRadioNo)
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("</span>"))
                End If


                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("</TD></TR>"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("</p></span></li>"))
                End If

                ''append to input validation java script
                m_javaScript = m_javaScript + "(document.getElementById(""" + oRadioYes.ClientID + """).checked || document.getElementById(""" + oRadioNo.ClientID + """).checked) && "

            End If

            ''combo box
            If dr.Item("QuestionTypeID").ToString = "2" Then
                Dim oCbo As New DropDownList
                Dim oLbl As New Label
                oCbo.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Combo) + dr.Item("QuestionID").ToString
                Dim myList As String()
                Dim myItem As String
                myList = dr.Item("Limitations").ToString.Split(CType("|", Char))
                ''add a blank default
                oCbo.Items.Add("")

                For Each myItem In myList
                    oCbo.Items.Add(myItem)
                Next
                oLbl.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Label) + dr.Item("QuestionID").ToString
                oLbl.Text = dr.Item("Text").ToString
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("<TR><TD width=""10""></TD><TD width=""560"">"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("<li class=""textbox""><span class=""survey""><p>"))
                End If

                pSurveyPanel.Controls.Add(oLbl)
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("</TD><TD colspan=""2"">"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("</p></span><span class=""select"">"))
                End If

                pSurveyPanel.Controls.Add(oCbo)
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("</TD></TR>"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("<span class=""arrow""></span></span></li>"))
                End If

                ''append to input validation java script
                m_javaScript = m_javaScript + "document.getElementById(""" + oCbo.ClientID + """).value.length != 0 && "
            End If

            ''Text Box
            If dr.Item("QuestionTypeID").ToString = "3" Then
                Dim oTxt As New TextBox
                Dim oLbl As New Label
                oTxt.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Text) + dr.Item("QuestionID").ToString
                oLbl.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Label) + dr.Item("QuestionID").ToString
                oLbl.Text = dr.Item("Text").ToString
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("<TR><TD width=""10""></TD><TD width=""560"">"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("<li class=""textbox""><span class=""survey""><p>"))
                End If

                pSurveyPanel.Controls.Add(oLbl)
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("</TD><TD colspan=""2"">"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("</p><p>"))
                End If

                pSurveyPanel.Controls.Add(oTxt)
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("</TD></TR>"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("</p></span></li>"))
                End If


                ''append to input validation java script
                m_javaScript = m_javaScript + "document.getElementById(""" + oTxt.ClientID + """).value.length != 0 && "

            End If

            ''Prompt only
            If dr.Item("QuestionTypeID").ToString = "5" Then
                Dim oLbl As New Label
                oLbl.ID = GetRenderingControlPrefix("WebSurvey",RenderingControlType.Label) + dr.Item("QuestionID").ToString
                oLbl.Text = dr.Item("Text").ToString
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("<TR><TD width=""10""><TD colspan=""3"">"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("<li class=""textbox""><span class=""survey""><p>"))
                End If

                pSurveyPanel.Controls.Add(oLbl)
                If m_renderingStyle = RenderingStyleType.DeskTop then
                    pSurveyPanel.Controls.Add(New LiteralControl("</TD></TR>"))
                End If
                If m_renderingStyle = RenderingStyleType.PDA then
                    pSurveyPanel.Controls.Add(New LiteralControl("</p></span></li>"))
                End If

            End If

        Next
    End Sub

    Protected Sub SaveSignatureData(byval pMerchantName As string, ByVal pSignatureWidth As Integer, ByVal pSignatureHeight As Integer, ByVal pJSON As String)
        ''step1: parser signature data into arraylist
        dim signatureLines As new ArrayList
        ''[{"lx":20,"ly":34,"mx":20,"my":34},{"lx":21,"ly":33,"mx":20,"my":34}]
        pJSON = pJSON.Replace("[{","").Replace("}]","").Replace("""lx"":","").Replace("""ly"":","").Replace("""mx"":","").Replace("""my"":","").Replace("},{","|")
        Dim i As integer
        Dim arrSegment As String() = pjson.split(CChar("|"))

        For i=0 to arrSegment.count-1
            'Dim pt1 As New Point(CType(arrsegment(i).Split(CChar(","))(0), integer),CType(arrsegment(i).Split(CChar(","))(1), integer))
            'points(0)=pt1
            'Dim pt2 As New Point(CType(arrsegment(i).Split(CChar(","))(2), integer),CType(arrsegment(i).Split(CChar(","))(3), integer))
            'points(1)=pt2
            Dim points As Point() = New Point(1){}

            points(0).X=CType(arrsegment(i).Split(CChar(","))(0), integer)
            points(0).y=CType(arrsegment(i).Split(CChar(","))(1), integer)
            points(1).X=CType(arrsegment(i).Split(CChar(","))(2), integer)
            points(1).y=CType(arrsegment(i).Split(CChar(","))(3), integer)
            signatureLines.Add(points)

        Next

        ''encrypt the signature lines and save into database
        Dim enData As byte() = EECommon.SignatureData.GetEncryptedData(pSignatureWidth,pSignatureHeight,signatureLines)

        m_DataLayer.PutMerchantAcceptance(CType(m_jobID, Long),enData,pMerchantName)

    End Sub

    Protected Sub GetSignatureData(byRef pMerchantName As string, ByRef pSignatureWidth As Integer, ByRef pSignatureHeight As Integer, ByRef pJSON As String)
        dim _signature As EECommon.SignatureData
        pJSON = ""
        ''get signature
        If m_DataLayer.GetMerchantAcceptance(CType(m_jobID, Long)) = DataLayerResult.Success Then
            With m_DataLayer.dsJob.Tables(0)
                If .Rows.Count > 0 Then
                    _signature = New EECommon.SignatureData(CType(.Rows(0)(1),Byte()))
                    pMerchantName = .Rows(0)(3).ToString
                End If
            End With
        End If

        If (_signature Is Nothing) Orelse (_signature.Width = 0) Orelse (_signature.Height = 0) Then
            Exit sub
        End If

        pSignatureWidth = _signature.Width
        pSignatureHeight = _signature.Height

        ' Parser each line to JASON format string
        ''[{"lx":20,"ly":34,"mx":20,"my":34},{"lx":21,"ly":33,"mx":20,"my":34}]
        For Each line As Point() In _signature.Lines
            If Not (line Is Nothing) And (line.Length > 0) Then
                pJSON += "{""lx"":" + line(0).X.ToString + ",""ly"":" + line(0).Y.ToString + ",""mx"":" + line(1).X.ToString + ",""my"":" + line(1).Y.ToString + "},"
            End If
        Next

        ''prepare JSON final return
        If pJSON <> "" then
            pJSON = "[" + Left(pJSON, Len(pJSON)-1) + "]"
        End If
    End Sub
    Protected Sub PopulatePartsCbo(pCbo As DropDownList,ByVal pDoPopulate As Boolean)
        ''only populate it when it is visible
        If pDoPopulate Then
            If m_DataLayer.GetFSPParts(Convert.ToInt64(m_jobID)) = DataLayerResult.Success Then
                pCbo.DataSource = m_DataLayer.dsTemp
                pCbo.DataTextField = "Device"
                pCbo.DataValueField = "PartID"
                pCbo.DataBind()
            End If
        End If
    End Sub
    Protected Sub PopulateTechFixCbo(pCbo As DropDownList,ByVal pDoPopulate As Boolean, ByVal pJobType As String)
        ''only populate it when it is visible
        If pDoPopulate Then
            If pJobType="" then
                ''get JobType first if not passed in
                If m_DataLayer.GetFSPJob(Convert.ToInt64(m_JobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsJob.Tables.Count > 0 Then
                    If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                        pJobType=Convert.ToString(m_DataLayer.dsJob.Tables(0).Rows(0)("JobType"))
                    End If
                End If
            End If
            If m_DataLayer.GetTechFix(pJobType) = DataLayerResult.Success Then
                pCbo.DataSource = m_DataLayer.dsTemp
                pCbo.DataTextField = "TechFix"
                pCbo.DataValueField = "TechFixID"
                pCbo.DataBind()
            End If

        End If
    End Sub
    Protected Sub PopulateEscalateReasonCbo(pCbo As DropDownList,ByVal pDoPopulate As Boolean)
        ''only populate it when it is visible
        If pDoPopulate Then
            If m_DataLayer.GetFSPEscalateReason() = DataLayerResult.Success Then
                pCbo.DataSource = m_DataLayer.dsTemp
                pCbo.DataTextField = "EscalateReason"
                pCbo.DataValueField = "EscalateReasonID"
                pCbo.DataBind()
            End If

        End If
    End Sub
    Protected Sub AddDevice(ByVal pDeviceIn As TextBox, ByVal pDeviceOut As textbox)
        Dim ret As DataLayerResult = DataLayerResult.Success

        If m_jobID.ToString.Length = 11 Then
            Try
					ret = m_DataLayer.AddFSPJobEquipment(CType(m_jobID, Long), pDeviceOut.Text.ToUpper, "", pDeviceIn.Text, "", 1)
				Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try

        Else
            If pDeviceIn.Text.Length > 0 Then
                Try
						ret = m_DataLayer.AddFSPJobEquipment(CType(m_jobID, Long), pDeviceIn.Text.ToUpper, "", "", "", 1)
					Catch ex As Exception
                    DisplayErrorMessage(lblMsg, ex.Message)
                End Try

            End If
            If ret = DataLayerResult.Success Then
                ''device-in is OK, now process device-out
                If pDeviceOut.Text.Length > 0 Then
                    Try
							ret = m_DataLayer.AddFSPJobEquipment(CType(m_jobID, Long), pDeviceOut.Text.ToUpper, "", "", "", 2)
						Catch ex As Exception
                        DisplayErrorMessage(lblMsg, ex.Message)
                    End Try

                End If
            End If
        End If

        If ret = DataLayerResult.Success Then
            pDeviceOut.Text = ""
            pDeviceIn.Text = ""
        End If

    End Sub

        Protected Sub AddParts(ByVal pPartID As String, ByVal pPartsQty As TextBox)

            Try
                If m_DataLayer.PutFSPJobParts(CType(m_jobID, Long), pPartID, Convert.ToInt32(pPartsQty.Text)) = DataLayerResult.Success Then
                    pPartsQty.Text = ""
                End If
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try

        End Sub

        Protected Sub SwapSIM(ByVal pSIMOut As TextBox, ByVal pSIMIn As TextBox)
            Dim ret As DataLayerResult = DataLayerResult.Success
            Dim ds As DataSet = Nothing

            Try
                ret = m_DataLayer.SwapBundledSIM(CType(m_jobID, Long), pSIMOut.Text.ToUpper, pSIMIn.Text.ToUpper)
                ds = m_DataLayer.dsTemp

                If ret = DataLayerResult.Success Then
                    If ds.Tables(0).Select("[Errors] is not null").Count() = 0 Then
                        m_DataLayer.PopupMessage = "SIMs swapped successfully!"
                        DisplayMessageBox(Me)
                    End If
                Else
                    Throw New Exception("An unknown error occurred!")
                End If
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try

            If ret = DataLayerResult.Success Then
                pSIMIn.Text = ""
                pSIMOut.Text = ""
            End If
        End Sub

        Protected Function CloseJob(ByVal pOnSiteDateTime As DateTime, ByVal pOffSiteDateTime As DateTime, ByVal pTechFixID As Short, ByVal pNotes As String, ByVal pSurveyID As String, ByVal pMissingParts As String, ByVal pFrom As Short) As Boolean
            Dim ret As DataLayerResult = DataLayerResult.Success

            Try
                ''validate job prior closure
                m_DataLayer.ValidateJobClosure(CType(m_jobID, Long), pFrom)

                ''if need to get survey and save
                If pSurveyID <> "" Then
                    ''get the survey results
                    Dim surveyResults As String
                    surveyResults = GetSubmittedSurvey(pSurveyID, FindChildControl(Me.Page.Form, "panelSurvey"))
                    ''save the survey results
                    m_DataLayer.PutSurveyAnswer(CType(m_jobID, Long), surveyResults)
                End If

                ret = m_DataLayer.CloseFSPJob(CType(m_jobID, Long), pTechFixID, pNotes, pOnSiteDateTime, pOffSiteDateTime)

                If ret = DataLayerResult.Success And pMissingParts <> "" Then
                    m_DataLayer.PutFSPMissingJobParts(CType(m_jobID, Long), pMissingParts)
                End If

                Return True
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
                Return False
            End Try
        End Function
        Protected Sub EscalateJob(ByVal pReasonID As int16 , ByRef pNotes As TextBox)
        Dim ret As DataLayerResult = DataLayerResult.Success

        Try
            if m_DataLayer.EscalateFSPJob(CType(m_jobID, Long), pReasonID, pNotes.Text) = DataLayerResult.Success then
                pNotes.Text = ""
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try

    End Sub
        Protected Sub AddJobNote(ByRef pNotes As TextBox)
            Try
                If m_DataLayer.AddFSPJobNote(CType(m_jobID, Long), pNotes.Text) = DataLayerResult.Success Then
                    pNotes.Text = ""
                End If
            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try

        End Sub


        Protected Function ReassignJobBackToDepot(ByRef pNotes As TextBox) As Boolean
        Try
            if m_DataLayer.ReassignJobBackToDepot(CType(m_jobID, Long), pNotes.Text) = DataLayerResult.Success then
                Return True
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
        Return False
    End Function

        Protected Sub PopulateOnSiteDateTime(ByRef pOnSiteDate As TextBox, ByRef pOnSiteTime As TextBox, ByRef pOffSiteDate As TextBox, ByRef pOffSiteTime As TextBox, ByRef pTxtTID As HiddenField, ByRef pClientID As HiddenField)
            Dim rounded As DateTime

            If m_DataLayer.GetFSPJobSheetData(Convert.ToInt64(m_jobID)) = DataLayerResult.Success AndAlso m_DataLayer.dsJob.Tables.Count > 0 AndAlso m_DataLayer.dsJob.Tables(0).Rows.Count > 1 Then
                ''fill in On/OffSite date captured previously
                If Not m_DataLayer.dsJob.Tables(0).Rows(0)("OnSiteDateTimeLocal") Is System.DBNull.Value AndAlso IsDate(m_DataLayer.dsJob.Tables(0).Rows(0)("OnSiteDateTimeLocal")) Then
                    ''set the default on/off site date & time
                    pOnSiteDate.Text = CType(m_DataLayer.dsJob.Tables(0).Rows(0)("OnSiteDateTimeLocal"), Date).ToString("dd/MM/yy")
                    pOnSiteTime.Text = CType(m_DataLayer.dsJob.Tables(0).Rows(0)("OnSiteDateTimeLocal"), Date).ToString("HHmm")
                End If
                If Not m_DataLayer.dsJob.Tables(0).Rows(0)("OffSiteDateTimeLocal") Is System.DBNull.Value AndAlso IsDate(m_DataLayer.dsJob.Tables(0).Rows(0)("OffSiteDateTimeLocal")) Then
                    pOffSiteDate.Text = CType(m_DataLayer.dsJob.Tables(0).Rows(0)("OffSiteDateTimeLocal"), Date).ToString("dd/MM/yy")
                    pOffSiteTime.Text = CType(m_DataLayer.dsJob.Tables(0).Rows(0)("OffSiteDateTimeLocal"), Date).ToString("HHmm")
                End If
                ''fill with IAmOnSite if FSP press the button
                If pOnSiteDate.Text = "" AndAlso Not m_DataLayer.dsJob.Tables(0).Rows(0)("IAmOnSiteDateLocal") Is System.DBNull.Value AndAlso IsDate(m_DataLayer.dsJob.Tables(0).Rows(0)("IAmOnSiteDateLocal")) Then
                    pOnSiteDate.Text = CType(m_DataLayer.dsJob.Tables(0).Rows(0)("IAmOnSiteDateLocal"), Date).ToString("dd/MM/yy")
                    pOnSiteTime.Text = CType(m_DataLayer.dsJob.Tables(0).Rows(0)("IAmOnSiteDateLocal"), Date).ToString("HHmm")
                    ''set offsite time
                    pOffSiteTime.Text = CType(m_DataLayer.dsJob.Tables(0).Rows(0)("CurrentSiteDateLocal"), Date).ToString("HHmm")
                End If
                pTxtTID.Value = m_DataLayer.dsJob.Tables(0).Rows(0)("TerminalID").ToString
                pClientID.Value = m_DataLayer.dsJob.Tables(0).Rows(0)("ClientID").ToString
            End If

            ' ''fill the default if no previouse capture
            ' ''rounded up to 5 minutes
            ' ''3,000,000,000 ticks = 5 minutes
            'rounded = new DateTime(CLng(( DateTime.Now.Ticks + 250000000) / 3000000000) * 3000000000)

            If pOnSiteDate.Text = "" Then
                ''set the default on/off site date & time
                pOnSiteDate.Text = Date.Now.ToString("dd/MM/yy")
            End If
            If pOffSiteDate.Text = "" Then
                pOffSiteDate.Text = Date.Now.ToString("dd/MM/yy")
            End If

        End Sub
    Protected Sub RenderFSPKittedPartsUsageButton(ByRef pPanel As Panel)
        ''Show/Hide Confirm Kitted Parts Usage button
        pPanel.Visible = False
        If m_jobID.ToString.Length = 11 then
            If m_DataLayer.GetJobKittedDevice(Convert.ToInt64(m_JobID), True) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables.Count > 0  AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0Then
                pPanel.Visible = True
            End If
        End If

    End Sub
    Protected Sub ConfirmKittedPartsUsage()
        Try
            m_DataLayer.ConfirmKittedPartsUsage(CType(m_jobID, Long))
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try

    End Sub
    Protected Sub RenderJobFSPDownload(ByRef pGRID As DataGrid, ByRef pREP As Repeater)
        Try
            if m_DataLayer.GetJobFSPDownload(CType(m_jobID, Long),CType(m_renderingStyle, Short)) = DataLayerResult.Success then
                If Not pGRID is Nothing then
                    pGRID.DataSource = m_DataLayer.dsDownloads.Tables(0)
                    pGRID.DataBind()
                End If
                If Not pREP is Nothing then
                    pREP.DataSource = m_DataLayer.dsDownloads.Tables(0)
                    pREP.DataBind()
                End If

            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
    End Sub
        Protected Sub FSPCallMerchant(ByVal pPhoneNumber As String)
            Try
                ''save the survey results
                m_DataLayer.FSPCallMerchant(CType(m_jobID, Long), pPhoneNumber)

            Catch ex As Exception
                DisplayErrorMessage(lblMsg, ex.Message)
            End Try
        End Sub

        Protected Sub BindMissingPartsList(chkMissingParts As CheckBoxList)
            Dim config As String() = ConfigurationManager.AppSettings("MissingPartsList").Split(","c)

            chkMissingParts.DataSource = config
            chkMissingParts.DataBind()
        End Sub

        Protected Function GetMissingParts(chkMissingParts As CheckBoxList) As String
            Dim partsList As String = ""

            For Each item As ListItem In chkMissingParts.Items
                If (item.Selected) Then
                    partsList += item.Value + ","
                End If
            Next

            Return partsList.TrimEnd(","c)
        End Function
    End Class
End Namespace