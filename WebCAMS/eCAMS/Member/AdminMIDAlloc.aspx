<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.master" CodeBehind="AdminMIDAlloc.aspx.vb" Inherits="eCAMS.AdminMIDAlloc" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
			<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="600" border="0">
				<TR>
					<TD colspan="3">
						<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle">Application MID Allocation Tool</asp:label>
                        <asp:placeholder id="placeholderMsg" runat="server"></asp:placeholder>
					</TD>
				</TR>
          <asp:panel id="panelFullPage" runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblCountryID" runat="server" CssClass="FormDEHeader">Country</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboCountryID" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="2" Selected ="true">New Zealand</asp:ListItem>
				 </asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblPartnerID" runat="server" CssClass="FormDEHeader">Partner</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboPartnerID" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="1" Selected ="true">BNZ</asp:ListItem>
				 </asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblAccountID" runat="server" CssClass="FormDEHeader">AccountID</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtAccountID" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblAccountType" runat="server" CssClass="FormDEHeader">AccountType</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtAccountType" runat="server" CssClass="FormDEField" size="50" Text ="Online"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblApplicationID" runat="server" CssClass="FormDEHeader">ApplicationID</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtApplicationID" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblProductType" runat="server" CssClass="FormDEHeader">ProductType</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtProductType" runat="server" CssClass="FormDEField" size="50" Text="eCommerce/MOTO"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblContactName" runat="server" CssClass="FormDEHeader">ContactName</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtContactName" runat="server" CssClass="FormDEField" size="60"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblGSTNumber" runat="server" CssClass="FormDEHeader">GSTNumber</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtGSTNumber" runat="server" CssClass="FormDEField" size="10"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblTradingName" runat="server" CssClass="FormDEHeader">TradingName</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtTradingName" runat="server" CssClass="FormDEField" size="64"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblLegalName" runat="server" CssClass="FormDEHeader">LegalName</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtLegalName" runat="server" CssClass="FormDEField" size="80"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDescriptionOfBusiness" runat="server" CssClass="FormDEHeader">DescriptionOfBusiness</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDescriptionOfBusiness" runat="server" CssClass="FormDEField" size="90"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblBusinessAddress1" runat="server" CssClass="FormDEHeader">BusinessAddress1</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtBusinessAddress1" runat="server" CssClass="FormDEField" size="64"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblBusinessAddress2" runat="server" CssClass="FormDEHeader">BusinessAddress2</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtBusinessAddress2" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblBusinessCity" runat="server" CssClass="FormDEHeader">BusinessCity</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtBusinessCity" runat="server" CssClass="FormDEField" size="64"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblBusinessState" runat="server" CssClass="FormDEHeader">BusinessState</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboBusinessState" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="9" Selected ="true">NZ</asp:ListItem>
				 </asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblBusinessPostcode" runat="server" CssClass="FormDEHeader">BusinessPostcode</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtBusinessPostcode" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblBusinessCountry" runat="server" CssClass="FormDEHeader">BusinessCountry</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboBusinessCountry" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="2" Selected ="true">New Zealand</asp:ListItem>
				 </asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblIsThePrimaryBusinessFaceToFace" runat="server" CssClass="FormDEHeader">IsThePrimaryBusinessFaceToFace</asp:label></TD>
				<TD height="26">
				 <asp:CheckBox id="chkIsThePrimaryBusinessFaceToFace" runat="server" CssClass="FormDEField" Checked="False" Text=""></asp:CheckBox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblIsBillerProvided" runat="server" CssClass="FormDEHeader">IsBillerProvided</asp:label></TD>
				<TD height="26">
				 <asp:CheckBox id="chkIsBillerProvided" runat="server" CssClass="FormDEField" Checked="False" Text=""></asp:CheckBox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblAnnualCardSalesTurnover" runat="server" CssClass="FormDEHeader">AnnualCardSalesTurnover</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtAnnualCardSalesTurnover" runat="server" CssClass="FormDEField" size="30"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblAverageTicketSize" runat="server" CssClass="FormDEHeader">AverageTicketSize</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtAverageTicketSize" runat="server" CssClass="FormDEField" size="30"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblSubMerchantBusinessIdentifier" runat="server" CssClass="FormDEHeader">SubMerchantBusinessIdentifier</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtSubMerchantBusinessIdentifier" runat="server" CssClass="FormDEField" size="30"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblRefundPolicy" runat="server" CssClass="FormDEHeader">RefundPolicy</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtRefundPolicy" runat="server" CssClass="FormDEField" size="100"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblCancellationPolicy" runat="server" CssClass="FormDEHeader">CancellationPolicy</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtCancellationPolicy" runat="server" CssClass="FormDEField" size="100"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDeliveryTimeframes" runat="server" CssClass="FormDEHeader">DeliveryTimeframes</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDeliveryTimeframes" runat="server" CssClass="FormDEField" size="30"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblPaymentPageSample" runat="server" CssClass="FormDEHeader">PaymentPageSample</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtPaymentPageSample" runat="server" CssClass="FormDEField" size="90"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblReceiptSample" runat="server" CssClass="FormDEHeader">ReceiptSample</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtReceiptSample" runat="server" CssClass="FormDEField" size="90"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblBusinessPhone" runat="server" CssClass="FormDEHeader">BusinessPhone</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtBusinessPhone" runat="server" CssClass="FormDEField" size="30"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblPrivatephone" runat="server" CssClass="FormDEHeader">Privatephone</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtPrivatephone" runat="server" CssClass="FormDEField" size="30"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblWebAddress" runat="server" CssClass="FormDEHeader">WebAddress</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtWebAddress" runat="server" CssClass="FormDEField" size="90"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblEmailAddress" runat="server" CssClass="FormDEHeader">EmailAddress</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtEmailAddress" runat="server" CssClass="FormDEField" size="90"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblFaxNumber" runat="server" CssClass="FormDEHeader">FaxNumber</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtFaxNumber" runat="server" CssClass="FormDEField" size="30"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1Name" runat="server" CssClass="FormDEHeader">Director1Name</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector1Name" runat="server" CssClass="FormDEField" size="90"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1DOB" runat="server" CssClass="FormDEHeader">Director1DOB</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector1DOB" runat="server" CssClass="FormDEField" size="10"></asp:textbox>
						<div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div>
					<asp:label id="Label18" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label>
				</TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1Address1" runat="server" CssClass="FormDEHeader">Director1Address1</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector1Address1" runat="server" CssClass="FormDEField" size="64"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1Address2" runat="server" CssClass="FormDEHeader">Director1Address2</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector1Address2" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1City" runat="server" CssClass="FormDEHeader">Director1City</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector1City" runat="server" CssClass="FormDEField" size="64"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1State" runat="server" CssClass="FormDEHeader">Director1State</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboDirector1State" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="9" Selected ="true">NZ</asp:ListItem>
				 </asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1Postcode" runat="server" CssClass="FormDEHeader">Director1Postcode</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector1Postcode" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector1Country" runat="server" CssClass="FormDEHeader">Director1Country</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboDirector1Country" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="2" Selected ="true">New Zealand</asp:ListItem>
				 </asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2Name" runat="server" CssClass="FormDEHeader">Director2Name</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector2Name" runat="server" CssClass="FormDEField" size="90"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2DOB" runat="server" CssClass="FormDEHeader">Director2DOB</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector2DOB" runat="server" CssClass="FormDEField" size="10"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2Address1" runat="server" CssClass="FormDEHeader">Director2Address1</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector2Address1" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2Address2" runat="server" CssClass="FormDEHeader">Director2Address2</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector2Address2" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2City" runat="server" CssClass="FormDEHeader">Director2City</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector2City" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2State" runat="server" CssClass="FormDEHeader">Director2State</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboDirector2State" runat="server" CssClass="FormDEField">
					<asp:ListItem Value=""></asp:ListItem>
					<asp:ListItem Value="9">NZ</asp:ListItem>
				 </asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2Postcode" runat="server" CssClass="FormDEHeader">Director2Postcode</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector2Postcode" runat="server" CssClass="FormDEField" size="10"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector2Country" runat="server" CssClass="FormDEHeader">Director2Country</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboDirector2Country" runat="server" CssClass="FormDEField">
					<asp:ListItem Value=""></asp:ListItem>
					<asp:ListItem Value="2">New Zealand</asp:ListItem>
				 </asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3Name" runat="server" CssClass="FormDEHeader">Director3Name</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector3Name" runat="server" CssClass="FormDEField" size="90"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3DOB" runat="server" CssClass="FormDEHeader">Director3DOB</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector3DOB" runat="server" CssClass="FormDEField" size="10"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3Address1" runat="server" CssClass="FormDEHeader">Director3Address1</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector3Address1" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3Address2" runat="server" CssClass="FormDEHeader">Director3Address2</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector3Address2" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3City" runat="server" CssClass="FormDEHeader">Director3City</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector3City" runat="server" CssClass="FormDEField" size="64"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3State" runat="server" CssClass="FormDEHeader">Director3State</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboDirector3State" runat="server" CssClass="FormDEField">
					<asp:ListItem Value=""></asp:ListItem>
					<asp:ListItem Value="9">NZ</asp:ListItem>
				 </asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3Postcode" runat="server" CssClass="FormDEHeader">Director3Postcode</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtDirector3Postcode" runat="server" CssClass="FormDEField" size="10"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblDirector3Country" runat="server" CssClass="FormDEHeader">Director3Country</asp:label></TD>
				<TD height="26">
				 <asp:dropdownlist id="cboDirector3Country" runat="server" CssClass="FormDEField">
					<asp:ListItem Value=""></asp:ListItem>
					<asp:ListItem Value="2">New Zealand</asp:ListItem>
				 </asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblMerchantCategoryIndustry" runat="server" CssClass="FormDEHeader">MerchantCategoryIndustry</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtMerchantCategoryIndustry" runat="server" CssClass="FormDEField" size="30"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblMerchantCategoryCode" runat="server" CssClass="FormDEHeader">MerchantCategoryCode</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtMerchantCategoryCode" runat="server" CssClass="FormDEField" size="30"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblExportRestrictionsApply" runat="server" CssClass="FormDEHeader">ExportRestrictionsApply</asp:label></TD>
				<TD height="26">
				 <asp:CheckBox id="chkExportRestrictionsApply" runat="server" CssClass="FormDEField" Checked="False" Text=""></asp:CheckBox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblOfficeID" runat="server" CssClass="FormDEHeader">OfficeID</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtOfficeID" runat="server" CssClass="FormDEField" size="20" Text="16832"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblAccountName" runat="server" CssClass="FormDEHeader">AccountName</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtAccountName" runat="server" CssClass="FormDEField" size="30" Text="Bambora"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="200" height="26">
				 <asp:label id="lblSettlementAccountNumber" runat="server" CssClass="FormDEHeader">SettlementAccountNumber</asp:label></TD>
				<TD height="26">
				 <asp:textbox id="txtSettlementAccountNumber" runat="server" CssClass="FormDEField" size="30" Text="02-1244-0132493-001"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
				<TR>
					<TD width="11" height="17"></TD>
					<TD width="86" height="17"></TD>
					<TD align="right" height="17"></TD>
				</TR>
				<TR>
					<TD width="11" height="10"></TD>
					<TD width="86" height="10"></TD>
					<TD align="right" height="10">
						<INPUT class="FormDEButton" id="btnSave" type="submit" value=" Submit " runat="server"  onclick="return ConfirmWithValidation('Are you sure to submit this request?');"></TD>
				</TR>

		  </asp:panel>

		    <asp:panel id="panelAcknowledge" runat="server">
			    <TR>
				    <TD width="10"></TD>
				    <TD colspan="2" align="left">
					    <asp:label id="lblAcknowledge" runat="server" CssClass="MemberInfo"></asp:label></TD>
				    <TD width="10"></TD>
			    </TR>		
		
		    </asp:panel>

		</TABLE>

	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"
		Width="152px"></asp:ValidationSummary>
    <asp:RequiredFieldValidator ID="rfvcboCountryID" runat="server" ControlToValidate="cboCountryID" InitialValue="0"
        Display="None" ErrorMessage="Please select Country"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvcboPartnerID" runat="server" ControlToValidate="cboPartnerID" InitialValue="0"
        Display="None" ErrorMessage="Please select Partner"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvtxtAccountID" runat="server" ControlToValidate="txtAccountID"
        Display="None" ErrorMessage="Please enter AccountID"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvtxtAccountType" runat="server" ControlToValidate="txtAccountType"
        Display="None" ErrorMessage="Please enter AccountType"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvtxtApplicationID" runat="server" ControlToValidate="txtApplicationID"
        Display="None" ErrorMessage="Please enter ApplicationID"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvtxtProductType" runat="server" ControlToValidate="txtProductType"
        Display="None" ErrorMessage="Please enter ProductType"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvContactName" runat="server" ControlToValidate="txtContactName"
        Display="None" ErrorMessage="Please enter ContactName"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingName" runat="server" ControlToValidate="txtTradingName"
        Display="None" ErrorMessage="Please enter TradingName"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvLegalName" runat="server" ControlToValidate="txtLegalName"
        Display="None" ErrorMessage="Please enter LegalName"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvDescriptionOfBusiness" runat="server" ControlToValidate="txtDescriptionOfBusiness"
        Display="None" ErrorMessage="Please enter DescriptionOfBusiness"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvBusinessAddress1" runat="server" ControlToValidate="txtBusinessAddress1"
        Display="None" ErrorMessage="Please enter BusinessAddress1"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvBusinessCity" runat="server" ControlToValidate="txtBusinessCity"
        Display="None" ErrorMessage="Please enter BusinessCity"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvBusinessPostcode" runat="server" ControlToValidate="txtBusinessPostcode"
        Display="None" ErrorMessage="Please enter BusinessPostcode"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvDirector1Name" runat="server" ControlToValidate="txtDirector1Name"
        Display="None" ErrorMessage="Please enter Director1Name"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvDirector1Address1" runat="server" ControlToValidate="txtDirector1Address1"
        Display="None" ErrorMessage="Please enter Director1Address1"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvDirector1City" runat="server" ControlToValidate="txtDirector1City"
        Display="None" ErrorMessage="Please enter Director1City"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvDirector1Postcode" runat="server" ControlToValidate="txtDirector1Postcode"
        Display="None" ErrorMessage="Please enter Director1Postcode"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvMerchantCategoryIndustry" runat="server" ControlToValidate="txtMerchantCategoryIndustry"
        Display="None" ErrorMessage="Please enter MerchantCategoryIndustry"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvMerchantCategoryCode" runat="server" ControlToValidate="txtMerchantCategoryCode"
        Display="None" ErrorMessage="Please enter MerchantCategoryCode"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvOfficeID" runat="server" ControlToValidate="txtOfficeID"
        Display="None" ErrorMessage="Please enter OfficeID"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvAccountName" runat="server" ControlToValidate="txtAccountName"
        Display="None" ErrorMessage="Please enter AccountName"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvSettlementAccountNumber" runat="server" ControlToValidate="txtSettlementAccountNumber"
        Display="None" ErrorMessage="Please enter SettlementAccountNumber"></asp:RequiredFieldValidator>

    <asp:RequiredFieldValidator ID="rfvcboBusinessState" runat="server" ControlToValidate="cboBusinessState" InitialValue="0"
        Display="None" ErrorMessage="Please select State"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvcboBusinessCountry" runat="server" ControlToValidate="cboBusinessCountry" InitialValue="0"
        Display="None" ErrorMessage="Please select Country"></asp:RequiredFieldValidator>
    <asp:RegularExpressionValidator ID="revDirector1DOBB" runat="server" ControlToValidate="txtDirector1DOB"
        Display="None" ErrorMessage="Invalid DOB" ValidationExpression="(([0-2][0-9])|(3[01]))\/((0[1-9])|(1[012]))\/\d{2}"></asp:RegularExpressionValidator>

<script language="javascript">
				<!--
    function ResetAllValidators() {
		ValidatorEnable(document.getElementById("<%=rfvcboCountryID.ClientID%>"), false);
		ValidatorEnable(document.getElementById("<%=rfvcboPartnerID.ClientID%>"), false);
		ValidatorEnable(document.getElementById("<%=rfvtxtAccountID.ClientID%>"), false);
		ValidatorEnable(document.getElementById("<%=rfvtxtAccountType.ClientID%>"), false);
		ValidatorEnable(document.getElementById("<%=rfvtxtApplicationID.ClientID%>"), false);
		ValidatorEnable(document.getElementById("<%=rfvtxtProductType.ClientID%>"), false);
		ValidatorEnable(document.getElementById("<%=rfvcboBusinessState.ClientID%>"), false);
		ValidatorEnable(document.getElementById("<%=rfvcboBusinessCountry.ClientID%>"), false);
    }

    function SetJobValidator() {
        ResetAllValidators();
        ValidatorEnable(document.getElementById("<%=rfvcboCountryID.ClientID%>"), true);

    }
    function ConfirmWithValidation(msg) {
        //SetJobValidator();
        if (Page_ClientValidate()) {
            return confirm(msg);
        }
        else {
            return false;
        }
    }

				// -->
	</script>

</asp:Content>
