'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 30/05/11 17:24 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/UpdateJobInfo.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.Data
Partial Class Member_UpdateJobInfo
    Inherits eCAMS.MemberPopupBase

    Private m_JobID As Long
    Private m_javaScript As String = ""

    Protected Overrides Sub Process()
        SetDE()
    End Sub
    Protected Overrides Sub GetContext()
        m_JobID = Convert.ToInt64(Request.QueryString("JID"))
    End Sub
    Protected Overrides Sub AddClientScript()
        If m_javaScript.Length > 0 Then
            ''trim the last && 
            m_javaScript = Left(m_javaScript, Len(m_javaScript) - 3)

        'function validateinput(){
        'if (document.getElementById("<%=txtTerminalID.ClientID%>").value.length == 0 
        '		&& document.getElementById("<%=txtMerchantID.ClientID%>").value.length == 0
        '		&& document.getElementById("<%=txtName.ClientID%>").value.length == 0
        '		&& document.getElementById("<%=txtSuburb.ClientID%>").value.length == 0
        '		&& document.getElementById("<%=txtPostcode.ClientID%>").value.length == 0) {
        '		alert("Please enter at least one criteria.");
        '		return false;
        '	}
        '	return true;
        '}
            m_javaScript = "<SCRIPT LANGUAGE=""JavaScript""> function validateinput(){if (" + m_javaScript + ") {alert(""Please enter at least one field.""); return false;} return true;} </SCRIPT>"
            Me.Page.ClientScript.RegisterClientScriptBlock(Me.Page.GetType, "jvvalidateinput", m_javaScript)
            btnSubmit.Attributes.Add("onclick", "return validateinput();") ''bind the 
        End If
    End Sub
    Private Sub SetDE()
        Me.PageTitle = "UpdateJobInfo"
    End Sub
    ''need to call this routine in Page_init or Page_Load event on postback and non-postback to reserve the viewstate
    ''It is better to recreate dynamic controls in Page_Init event
    Private Sub RenderUpdateJobInfo()
        Dim dr As DataRow
        If m_DataLayer.GetClientUpdateInfoFieldList(m_JobID) = eCAMS.DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
            lblFormTitle.Text = "UpdateJobInfo[" + m_JobID.ToString + "]-" + m_DataLayer.dsTemp.Tables(0).Rows(0)("MerchantName").ToString
            For Each dr In m_DataLayer.dsTemp.Tables(0).Rows
                ''checkbox
                If dr.Item("FieldType").ToString = "1" Then
                    Dim oChk As New CheckBox()
                    Dim oLbl As New Label()
                    oChk.ID = GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Radio) + dr.Item("FieldID").ToString
                    oLbl.ID = GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Label) + dr.Item("FieldID").ToString
                    oLbl.Text = dr.Item("FieldName").ToString
                    panelUpdateInfo.Controls.Add(New LiteralControl("<TR><TD width=""10""></TD><TD width=""145"">"))
                    panelUpdateInfo.Controls.Add(oLbl)
                    panelUpdateInfo.Controls.Add(New LiteralControl("</TD><TD>"))
                    panelUpdateInfo.Controls.Add(oChk)
                    panelUpdateInfo.Controls.Add(New LiteralControl("</TD></TR>"))

                    ''append to input validation java script
                    m_javaScript = m_javaScript + "document.getElementById(""" + oChk.ClientID + """).checked == false && "

                End If

                ''text box
                If dr.Item("FieldType").ToString = "2" Then
                    Dim oTxt As New TextBox()
                    Dim oLbl As New Label()
                    oTxt.ID = GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Text) + dr.Item("FieldID").ToString
                    oTxt.MaxLength = Convert.ToInt16(dr.Item("FieldSize"))
                    If Convert.ToInt16(dr.Item("FieldSize")) > 60 Then
                        oTxt.Columns = 50
                        oTxt.Rows = 3
                        oTxt.TextMode = TextBoxMode.MultiLine
                    Else
                        oTxt.Columns = Convert.ToInt16(dr.Item("FieldSize"))
                    End If

                    oLbl.ID = GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Label) + dr.Item("FieldID").ToString
                    oLbl.Text = dr.Item("FieldName").ToString
                    panelUpdateInfo.Controls.Add(New LiteralControl("<TR><TD width=""10""></TD><TD width=""250"">"))
                    panelUpdateInfo.Controls.Add(oLbl)
                    panelUpdateInfo.Controls.Add(New LiteralControl("</TD><TD>"))
                    panelUpdateInfo.Controls.Add(oTxt)
                    panelUpdateInfo.Controls.Add(New LiteralControl("</TD></TR>"))

                    ''append to input validation java script
                    m_javaScript = m_javaScript + "document.getElementById(""" + oTxt.ClientID + """).value.trim().length == 0 && "

                End If

                ''combo box
                If dr.Item("FieldType").ToString = "3" Then
                    Dim oCbo As New DropDownList
                    Dim oLbl As New Label
                    oCbo.ID = GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Combo) + dr.Item("FieldID").ToString
                    Dim myList As String()
                    Dim myItem As String
                    myList = dr.Item("SelectionValue").ToString.Split(CType("|", Char))
                    ''add a blank default
                    oCbo.Items.Add(" ")

                    For Each myItem In myList
                        oCbo.Items.Add(myItem)
                    Next
                    oLbl.ID = GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Label) + dr.Item("FieldID").ToString
                    oLbl.Text = dr.Item("FieldName").ToString
                    panelUpdateInfo.Controls.Add(New LiteralControl("<TR><TD width=""10""></TD><TD width=""250"">"))
                    panelUpdateInfo.Controls.Add(oLbl)
                    panelUpdateInfo.Controls.Add(New LiteralControl("</TD><TD>"))
                    panelUpdateInfo.Controls.Add(oCbo)
                    panelUpdateInfo.Controls.Add(New LiteralControl("</TD></TR>"))

                    ''append to input validation java script
                    m_javaScript = m_javaScript + "document.getElementById(""" + oCbo.ClientID + """).value.trim().length == 0 && "

                End If

            Next
        Else
            m_DataLayer.PopupMessage = "UpdateJobInfo - No records found! Please notify webmaster at Ingenico."
            DisplayMessageBox(Me)
        End If

    End Sub
    Private Function GetControlPrefix(ByVal pType As Integer) As String
        Dim prefix As String = ""
        Select Case pType
            Case 0
                prefix = "WebUpdateInfoLBL_"
            Case 1
                prefix = "WebUpdateInfoCHK_"
            Case 2
                prefix = "WebUpdateInfoTXT_"
            Case 3
                prefix = "WebUpdateInfoCBO_"
        End Select
        Return prefix
    End Function

    Private Function GetSubmittedInfo() As String


        Dim strTemp As String = ""
        Dim oPanel As Control
        Dim oControl As Control
        oPanel = FindChildControl(Me.Page.Form, "panelUpdateInfo")
        If Not oPanel Is Nothing Then
            For Each oControl In oPanel.Controls
                If TypeOf (oControl) Is TextBox AndAlso oControl.ID.Contains(GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Text)) AndAlso CType(oControl, TextBox).Text.Trim() <> String.Empty Then
                    strTemp = strTemp + CType(FindChildControl(Me.Page, GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Label) + oControl.ID.Substring(oControl.ID.IndexOf("_") + 1)), Label).Text + ": " + CType(oControl, TextBox).Text + vbCrLf
                End If
                If TypeOf (oControl) Is CheckBox AndAlso oControl.ID.Contains(GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Radio)) AndAlso CType(oControl, CheckBox).Checked Then
                    strTemp = strTemp + CType(FindChildControl(Me.Page, GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Label) + oControl.ID.Substring(oControl.ID.IndexOf("_") + 1)), Label).Text + ": Yes" + vbCrLf
                End If
                If TypeOf (oControl) Is DropDownList AndAlso oControl.ID.Contains(GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Combo)) AndAlso CType(oControl, DropDownList).SelectedItem.Text.Trim() <> String.Empty Then
                    strTemp = strTemp + CType(FindChildControl(Me.Page, GetRenderingControlPrefix("WebUpdateInfo",RenderingControlType.Label) + oControl.ID.Substring(oControl.ID.IndexOf("_") + 1)), Label).Text + ": " + CType(oControl, DropDownList).SelectedItem.Text.Trim() + vbCrLf
                End If

            Next

        End If

        Return strTemp
    End Function
#Region "why we do need to recreate dynamic control on each round trip"
'Dynamic Controls and View State
'When a control is created dynamically at run time, some information about the control is stored in the view state that is rendered with the page. 
'When the page is posted back to the server, however, non-dynamic controls (those defined on the page) are instantiated in the Page.Init event and 
'view state information is loaded before the dynamic controls can be recreated (generally in the Page_Load handler). Effectively, before the dynamic 
'controls are recreated, view state is temporarily out of sync with the page's controls. After the Page_Load event has run, but before control event 
'handling methods are called, the remaining view state information is loaded into the dynamically created controls.

'In most scenarios, this view state processing model works fine. Typically, you add dynamic controls to the end of a container's collection of controls. 
'The view state information stored for the dynamic controls is therefore extra information at the end of the view state structure for the appropriate 
'container, and the page can ignore it until after the controls are created.

'However, view state information about dynamically created controls can be a problem in two scenarios: 

'If you insert dynamic controls between existing controls. 
'If you insert controls dynamically and then reinsert them during a round trip, but with different values. 
'If you insert dynamic controls between existing controls, the dynamic control's view state information is inserted into the corresponding location of 
'the view state structure. When the page is posted and the view state is loaded, the dynamic control does not yet exist; therefore, the extra 
'information in view state does not correspond to the right control. The result is usually an error indicating an invalid cast.

'If you reinsert controls with each round trip, each generation of dynamically created controls will pick up property values from the view state of 
'the preceding set of controls. In many cases, you can avoid this problem by setting the EnableViewState property of the container control to false. 
'In that case, no information about the dynamic controls is saved, and there is no conflict with successive versions of the controls.


#End Region
    Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)


        GetContext()
        RenderUpdateJobInfo()  ''need to recreate the dynamic control on each round trip in order to get view state!!!
        AddClientScript() ''to call this rountine after the java script block formulated
    End Sub

Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click
        panelDetails.Visible = False ''hide the details

        ''get submited request details
        ''save to DB
        If m_DataLayer.UpdateJobInfo(m_JobID, GetSubmittedInfo()) = eCAMS.DataLayerResult.Success Then
            lblFormTitle.Text = "Submitted successfully."
        Else
            lblFormTitle.Text = "Submitted failed.Try again."
        End If
End Sub

End Class
