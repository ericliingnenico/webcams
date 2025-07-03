#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/01/2018 11:07 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/BulkUpdateJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing
Imports System.Globalization
Namespace eCAMS
	Public Class AdminMIDAlloc
		Inherits MemberPageBase

		Private lblMsg As New Label

		Protected Overrides Sub GetContext()
			With Request
				''m_jobID = Convert.ToInt64(.Item("JID"))
			End With
		End Sub

		Protected Overrides Sub Process()
			SetDE()
		End Sub
		Protected Overrides Sub AddClientScript()
			btnSave.Attributes.Add("onclick", "return ConfirmWithValidation('Are you sure to submit this request?');")
		End Sub
		Private Sub SetDE()
			Me.PageTitle = "MID Allocation"
			Me.RestrictModuleName = "AdminMIDAllocation"
			Call SetFocusExt(txtAccountID)
			DisplayFullPage()
		End Sub
		Private Sub DisplayFullPage()
			Call HidePanels(1)  ''hide top level
			panelFullPage.Visible = True

			PositionMsgLabel(placeholderMsg, lblMsg)

		End Sub

		Private Sub DisplayAcknowledgePage(ByVal pMerchantID As String, ByVal pPayMarkID As String)
			Call HidePanels(1)  ''hide top level
			panelAcknowledge.Visible = True
			lblAcknowledge.Text = String.Format("MerchantID: {0} , PayMarkID: {1} are allocated. ", pMerchantID, pPayMarkID)

		End Sub

		Private Sub HidePanels(ByVal pLevel As Int16)
			Select Case pLevel
				Case 1  ''top level
					panelFullPage.Visible = False
					panelAcknowledge.Visible = False
				Case 2  ''second level
					panelAcknowledge.Visible = False
			End Select
		End Sub
		Protected Sub btnSave_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.ServerClick
			Dim merchantID As String
			Dim payMarkID As Int64
			Dim ret As DataLayerResult
			PositionMsgLabel(placeholderMsg, lblMsg) ''reposition the error message label

			Try
				ret = m_DataLayer.LogApplicationAndAssignMID(merchantID,
					payMarkID,
					cboCountryID.SelectedValue,
					cboPartnerID.SelectedValue,
					txtAccountID.Text,
					txtAccountType.Text,
					txtApplicationID.Text,
					txtProductType.Text,
					txtContactName.Text,
					txtGSTNumber.Text,
					txtTradingName.Text,
					txtLegalName.Text,
					txtDescriptionOfBusiness.Text,
					txtBusinessAddress1.Text,
					txtBusinessAddress2.Text,
					txtBusinessCity.Text,
					cboBusinessState.SelectedValue,
					txtBusinessPostcode.Text,
					cboBusinessCountry.SelectedValue,
					chkIsThePrimaryBusinessFaceToFace.Checked,
					chkIsBillerProvided.Checked,
					txtAnnualCardSalesTurnover.Text,
					txtAverageTicketSize.Text,
					txtSubMerchantBusinessIdentifier.Text,
					txtRefundPolicy.Text,
					txtCancellationPolicy.Text,
					txtDeliveryTimeframes.Text,
					txtPaymentPageSample.Text,
					txtReceiptSample.Text,
					txtBusinessPhone.Text,
					txtPrivatephone.Text,
					txtWebAddress.Text,
					txtEmailAddress.Text,
					txtFaxNumber.Text,
					txtDirector1Name.Text,
					ToYYYYMMDD(txtDirector1DOB.Text),
					txtDirector1Address1.Text,
					txtDirector1Address2.Text,
					txtDirector1City.Text,
					cboDirector1State.SelectedValue,
					txtDirector1Postcode.Text,
					cboDirector1Country.SelectedValue,
					txtDirector2Name.Text,
					ToYYYYMMDD(txtDirector2DOB.Text),
					txtDirector2Address1.Text,
					txtDirector2Address2.Text,
					txtDirector2City.Text,
					cboDirector2State.SelectedValue,
					txtDirector2Postcode.Text,
					cboDirector2Country.SelectedValue,
					txtDirector3Name.Text,
					ToYYYYMMDD(txtDirector3DOB.Text),
					txtDirector3Address1.Text,
					txtDirector3Address2.Text,
					txtDirector3City.Text,
					cboDirector3State.SelectedValue,
					txtDirector3Postcode.Text,
					cboDirector3Country.SelectedValue,
					txtMerchantCategoryIndustry.Text,
					txtMerchantCategoryCode.Text,
					chkExportRestrictionsApply.Checked,
					txtOfficeID.Text,
					txtAccountName.Text,
					txtSettlementAccountNumber.Text,
					True, ''chkIsCreditCheck.Checked,
					True, ''chkIsKYCCheck.Checked,
					True, ''chkIsSignedSubMerchantAgreement.Checked,
					True, ''chkIsWebsiteComplianceCheck.Checked,
					True, ''chkIsHighRiskMCCCodeCheck.Checked,
					True) ''chkIsPCIComplianceCheck.Checked)
				If ret = DataLayerResult.Success Then
					DisplayAcknowledgePage(merchantID.ToString, payMarkID.ToString)
				Else
					DisplayErrorMessage(lblMsg, "Failed to save the application. Please try again.")
				End If
			Catch ex As Exception
				DisplayErrorMessage(lblMsg, ex.Message)
			End Try

		End Sub

		Private Function ToYYYYMMDD(ByVal pDDMMYY As String) As String
			Dim dt As DateTime
			Dim retYYMMDD As String
			Try
				dt = DateTime.ParseExact(pDDMMYY, "dd/MM/yy", CultureInfo.InvariantCulture)
				retYYMMDD = dt.ToString("yyyy-MM-dd")
			Catch ex As Exception
				retYYMMDD = ""
			End Try

			Return retYYMMDD

		End Function

	End Class
End Namespace