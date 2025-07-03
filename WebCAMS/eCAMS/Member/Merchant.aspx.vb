#Region "vss"
'<!--$$Revision: 4 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 29/09/11 11:20 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/Merchant.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing

Namespace eCAMS
Partial Class Merchant
    Inherits MemberPageBase

        ''page level variables
        Private m_TID As String
        Private m_ClientID As String
        Private lblMsg As New Label

#Region "Function"

    Protected Overrides Sub GetContext()
        With Request
            m_TID = .Item("TID")
            m_ClientID = .Item("CID")
        End With
    End Sub

    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    Protected Overrides Sub AddClientScript()
        ''tie these textboxes to corresponding buttons
        txtTradingHoursMon.Attributes.Add("onblur", "CopyTradingHoursMF(1);")
        txtTradingHoursTue.Attributes.Add("onblur", "CopyTradingHoursMF(2);")
        txtTradingHoursWed.Attributes.Add("onblur", "CopyTradingHoursMF(3);")
        txtTradingHoursThu.Attributes.Add("onblur", "CopyTradingHoursMF(4);")
        txtTradingHoursFri.Attributes.Add("onblur", "CopyTradingHoursMF(5);")

        ''add onclik to btnSave to alert user before submit request
        btnSave.Attributes.Add("onclick", "if (confirm('Are you sure to submit this request?')) {SetValidator();} else {return false;}")
    End Sub

    Protected Overrides sub SetRenderingStyle()
        m_renderingStyle = RenderingStyleType.DeskTop
    End Sub

    Private Sub SetDE()
        PositionMsgLabel(placeholderMsg, lblMsg)

        ''hidden field value
        If Not m_TID Is Nothing AndAlso m_TID.Length > 0 Then
            ''TID & ClientID are passed in, the page is called from site list, display the full page
            If GetMerchant() Then
                ''display full page
                DisplayFullPage()
            Else
                ''No record found
                DisplayErrorMessage(lblMsg,"Merchant record is not found")
                ''Display error message only, so hide the other panels
                HidePanels(1)
            End If
        Else
            ''Set client Combox, for multiple clients base such as NAB/HIC
            Call FillCboWithArray(cboClientID, m_DataLayer.CurrentUserInformation.ClientIDs.Split(CType(",", Char)))
            ''Ask user to eneter ClientID/TerminalID 
            DisplayTIDPage()
        End If
    End Sub
    Private Sub HidePanels(ByVal pLevel As Int16)
        Select Case pLevel
            Case 1  ''top level
                panelTIDPage.Visible = False
                panelFullPage.Visible = False
                panelAcknowledge.Visible = False
            Case 2  ''second level
                    ''hide sub panels
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

        panelFullPage.Visible = True

        Call PopulateState()

        Call DisplaySiteDetail()

        PositionMsgLabel(placeholderMsg, lblMsg)

    End Sub

    Private Sub DisplayAcknowledgePage()
        Call HidePanels(1)  ''hide top level
        panelAcknowledge.Visible = True
        lblAcknowledge.Text = "Merchant details has been updated successfully."
    End Sub
    Private Sub PopulateState()
        ''Caching State if needs
        m_DataLayer.CacheState()

        cboState.DataSource = m_DataLayer.State
        cboState.DataTextField = "State"
        cboState.DataValueField = "State"
        cboState.DataBind()
    End Sub
    Private Function GetMerchant() As Boolean
        Dim dlResult As DataLayerResult
        ''Read data
        dlResult = m_DataLayer.GetSite(m_ClientID, m_TID)

        ''Get Site and display it as merchant trading details
        If dlResult = DataLayerResult.Success AndAlso m_DataLayer.dsSite.Tables(0).Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    Private Sub DisplaySiteDetail()
        ''Display merchant details from m_datalayer.dsSite which read via GetMerchant
        If m_DataLayer.dsSite.Tables(0).Rows.Count > 0 Then
            With m_DataLayer.dsSite.Tables(0).Rows(0)
                txtTerminalID.Text = clsTool.NullToValue(.Item("TerminalID").ToString, "")
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

                ''trading hours are stored in CAMS in the format of HH:MM - HH:MM which is WBC CDI format
                ''so we need to trim the space and :
                txtTradingHoursMon.Text = clsTool.NullToValue(.Item("TradingHoursMon").ToString, "").Replace(" ", "").Replace(":", "")
                txtTradingHoursTue.Text = clsTool.NullToValue(.Item("TradingHoursTue").ToString, "").Replace(" ", "").Replace(":", "")
                txtTradingHoursWed.Text = clsTool.NullToValue(.Item("TradingHoursWed").ToString, "").Replace(" ", "").Replace(":", "")
                txtTradingHoursThu.Text = clsTool.NullToValue(.Item("TradingHoursThu").ToString, "").Replace(" ", "").Replace(":", "")
                txtTradingHoursFri.Text = clsTool.NullToValue(.Item("TradingHoursFri").ToString, "").Replace(" ", "").Replace(":", "")
                txtTradingHoursSat.Text = clsTool.NullToValue(.Item("TradingHoursSat").ToString, "").Replace(" ", "").Replace(":", "")
                txtTradingHoursSun.Text = clsTool.NullToValue(.Item("TradingHoursSun").ToString, "").Replace(" ", "").Replace(":", "")

            End With
        Else
            DisplayErrorMessage(lblMsg,"Merchant record is not found")
        End If

    End Sub
    Private Function FormatTradingHour(ByVal pHour As String) As String
        Dim retHour As String = ""
        If pHour.Length > 8 Then
            ''HHMM-HHMM
            retHour = pHour.Insert(7, ":").Insert(2, ":").Replace("-", " - ")
        End If
        Return retHour
    End Function
#End Region

#Region "Event Handler"
    Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        Me.PageTitle = "Update Merchant Details"

        If Page.IsPostBack Then
        End If
    End Sub


    Protected Sub btnSave_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.ServerClick
        ''Save the merchant details
        Dim ret As DataLayerResult

        Try
            ret = m_DataLayer.PutSite(txtClientID.Value, _
                    txtTerminalID.Text, _
                    txtMerchantID.Text, _
                    txtName.Text, _
                    txtAddress.Text, _
                    txtAddress2.Text, _
                    txtCity.Text, _
                    cboState.SelectedValue, _
                    txtPostcode.Text, _
                    txtContact.Text, _
                    txtPhoneNumber.Text, _
                    txtPhoneNumber2.Text, _
                    FormatTradingHour(txtTradingHoursMon.Text), _
                    FormatTradingHour(txtTradingHoursTue.Text), _
                    FormatTradingHour(txtTradingHoursWed.Text), _
                    FormatTradingHour(txtTradingHoursThu.Text), _
                    FormatTradingHour(txtTradingHoursFri.Text), _
                    FormatTradingHour(txtTradingHoursSat.Text), _
                    FormatTradingHour(txtTradingHoursSun.Text), _
                    chbApplyTheChange.Checked)
            If ret = DataLayerResult.Success Then
                DisplayAcknowledgePage()
            Else
                DisplayErrorMessage(lblMsg,"Failed to save this job. Please try again.")
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg,ex.Message)
        End Try

    End Sub

    Protected Sub btnTIDGo_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnTIDGo.ServerClick
        ''get TID and CID
        m_TID = txtTID.Text
        m_ClientID = cboClientID.SelectedValue
        txtClientID.Value = m_ClientID

        If GetMerchant() Then
            ''display full page
            DisplayFullPage()
        Else
            DisplayErrorMessage(lblMsg,"Merchant record is not found")
        End If
    End Sub


#End Region

End Class
End Namespace