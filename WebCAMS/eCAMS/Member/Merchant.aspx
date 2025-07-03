<%@ Page Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.Merchant" title="Untitled Page" Codebehind="Merchant.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" style="WIDTH: 520px; HEIGHT: 152px" cellSpacing="1" cellPadding="1"
		width="520" border="0" > 
		<TR>
			<TD colspan="3">
				<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
                <asp:HiddenField ID="txtClientID" runat="server" />
                <asp:placeholder id="placeholderMsg" runat="server"></asp:placeholder>
                </TD>
		</TR>
		<asp:panel id="panelTIDPage" runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="86" height="26">
					<asp:Label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:Label></TD>
				<TD height="26">
					<asp:DropDownList id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:DropDownList></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="lblTID" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtTID" runat="server" CssClass="FormDEField" size="10"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="130" height="10"></TD>
				<TD align="center" height="10"><INPUT class="FormDEButton" id="btnTIDGo" type="submit" value=" GO " name="btnTIDGo" runat="server"></TD>
			</TR>
		</asp:panel>
		<asp:panel id="panelFullPage" runat="server"> 
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="lblTerminalID" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtTerminalID" runat="server" CssClass="FormDEField" size="10" ReadOnly="true"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label3" runat="server" CssClass="FormDEHeader">MerchantID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtMerchantID" runat="server" CssClass="FormDEField" size="16" ReadOnly="true"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label5" runat="server" CssClass="FormDEHeader">Merchant Name</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtName" runat="server" CssClass="FormDEField" size="60"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label6" runat="server" CssClass="FormDEHeader">Trading Address1</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtAddress" runat="server" CssClass="FormDEField" size="60"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label7" runat="server" CssClass="FormDEHeader">Trading Address2</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtAddress2" runat="server" CssClass="FormDEField" size="60"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label8" runat="server" CssClass="FormDEHeader">Suburb</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtCity" runat="server" CssClass="FormDEField" size="50"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="16"></TD>
				<TD width="130" height="16">
					<asp:label id="Label11" runat="server" CssClass="FormDEHeader">State</asp:label></TD>
				<TD height="16">
					<asp:dropdownlist id="cboState" runat="server" CssClass="FormDEField"></asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label9" runat="server" CssClass="FormDEHeader">Postcode</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtPostcode" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label10" runat="server" CssClass="FormDEHeader">Contact Name</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtContact" runat="server" CssClass="FormDEField" size="50"></asp:textbox><div id="divContact" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label12" runat="server" CssClass="FormDEHeader">Phone1</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtPhoneNumber" runat="server" CssClass="FormDEField" size="15"></asp:textbox><div id="divPhone1" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label13" runat="server" CssClass="FormDEHeader">Phone2</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtPhoneNumber2" runat="server" CssClass="FormDEField" size="15"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label19" runat="server" CssClass="FormDEHeader">Trading Hours</asp:label><div id="divTradingHourMFHint" runat="server" class="FormDEHint">enter "CLOSED" if no trading MF</div></TD>
				<TD height="16">
					<asp:label id="Label21" runat="server" CssClass="FormDEHeader">Mon:</asp:label>
					<asp:textbox id="txtTradingHoursMon" runat="server" CssClass="FormDEField" size="12"></asp:textbox><div id="divTradingHourMon" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
					<asp:label id="Label34" runat="server" CssClass="FormDEHeader">Tue:</asp:label>
					<asp:textbox id="txtTradingHoursTue" runat="server" CssClass="FormDEField" size="12"></asp:textbox><div id="divTradingHourTue" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
					<asp:label id="Label35" runat="server" CssClass="FormDEHeader">Wed:</asp:label>
					<asp:textbox id="txtTradingHoursWed" runat="server" CssClass="FormDEField" size="12"></asp:textbox><div id="divTradingHourWed" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
					<asp:label id="Label36" runat="server" CssClass="FormDEHeader">Thu:</asp:label>
					<asp:textbox id="txtTradingHoursThu" runat="server" CssClass="FormDEField" size="12"></asp:textbox><div id="divTradingHourThu" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
					<asp:label id="Label37" runat="server" CssClass="FormDEHeader">Fri:</asp:label>
					<asp:textbox id="txtTradingHoursFri" runat="server" CssClass="FormDEField" size="12"></asp:textbox><div id="divTradingHourFri" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
					<asp:label id="Label22" runat="server" CssClass="FormDEHeader">Sat:</asp:label>
					<asp:textbox id="txtTradingHoursSat" runat="server" CssClass="FormDEField" size="12"></asp:textbox><BR>
					<asp:label id="Label23" runat="server" CssClass="FormDEHeader">Sun:</asp:label>
					<asp:textbox id="txtTradingHoursSun" runat="server" CssClass="FormDEField" size="12"></asp:textbox>
					<asp:label id="Label20" runat="server" CssClass="FormDEHint">(Format: hhmm-hhmm, 24hr format)</asp:label></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD height="26" colspan=2>
					<asp:label id="Label15" runat="server" CssClass="FormDEHeader">Update all the site records with the same MerchantID</asp:label>
					<asp:CheckBox id="chbApplyTheChange" runat="server" CssClass="FormDEField" Checked="True" Text=""></asp:CheckBox></TD>
			</TR>

			<TR>
				<TD width="11" height="10"></TD>
				<TD width="130" height="10"></TD>
				<TD align="center" height="10"><INPUT class="FormDEButton" id="btnSave" type="submit" value=" Submit " name="btnSave"
						runat="server"></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="130"></TD>
				<TD align="right"></TD>
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
	
	<asp:RequiredFieldValidator id="rfvTID" runat="server" ErrorMessage="Please enter TerminalID." ControlToValidate="txtTID"
		Display="None"></asp:RequiredFieldValidator>
	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"
		Width="152px"></asp:ValidationSummary>
    <asp:RequiredFieldValidator ID="rfvTerminalID" runat="server" ControlToValidate="txtTerminalID"
        Display="None" ErrorMessage="Please enter TerminalID."></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvMerchantID" runat="server" ErrorMessage="Please enter MerchantID." Display="None" ControlToValidate="txtMerchantID"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Please enter Merchant Name." Display="None" ControlToValidate="txtName"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ErrorMessage="Please enter Trading Address1." ControlToValidate="txtAddress" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvAddress2" runat="server" ErrorMessage="Please enter Trading Address2." ControlToValidate="txtAddress2" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvCity" runat="server" ErrorMessage="Please enter Trading Suburb." ControlToValidate="txtCity" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvPostcode" runat="server" ErrorMessage="Please enter Trading Postcode." ControlToValidate="txtPostcode" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvContact" runat="server" ErrorMessage="Please enter Trading Contact." ControlToValidate="txtContact" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvPhoneNumber" runat="server" ErrorMessage="Please enter Trading Phone1." ControlToValidate="txtPhoneNumber" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursMon" runat="server" ErrorMessage="Please enter trading hours Mon." ControlToValidate="txtTradingHoursMon" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursTue" runat="server" ErrorMessage="Please enter trading hours Tue." ControlToValidate="txtTradingHoursTue" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursWed" runat="server" ErrorMessage="Please enter trading hours Wed." ControlToValidate="txtTradingHoursWed" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursThu" runat="server" ErrorMessage="Please enter trading hours Thu." ControlToValidate="txtTradingHoursThu" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursFri" runat="server" ErrorMessage="Please enter trading hours Fri." ControlToValidate="txtTradingHoursFri" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursSat" runat="server" ErrorMessage="Please enter trading hours Sat." ControlToValidate="txtTradingHoursSat" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursSun" runat="server" ErrorMessage="Please enter trading hours Sun." ControlToValidate="txtTradingHoursSun" Display="None"></asp:RequiredFieldValidator>

<script language="javascript">
				<!--
				
				function ResetAllValidators()
				{
//				could use Page_Validators[] generated on client


					ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvMerchantID.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvAddress2.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvContact.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvPhoneNumber.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursMon.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursTue.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursWed.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursThu.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursFri.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursSat.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursSun.ClientID%>"), false);
					
					//Custom validator
					ValidatorEnable(document.getElementById("<%=cvTradingHoursMon.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursTue.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursWed.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursThu.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursFri.ClientID%>"), false);
					
				}
				
				function SetValidator()
				{
				    //disable all the validators
					ResetAllValidators();

                    //selectively enable some validators
                    //Required field validators
					ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), true);
					ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), true);
					ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), true);
					ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), true);


					//Custom validator with java script
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursMon.ClientID%>"), true);
				    ValidatorEnable(document.getElementById("<%=rfvTradingHoursTue.ClientID%>"), true);
				    ValidatorEnable(document.getElementById("<%=rfvTradingHoursWed.ClientID%>"), true);
				    ValidatorEnable(document.getElementById("<%=rfvTradingHoursThu.ClientID%>"), true);
				    ValidatorEnable(document.getElementById("<%=rfvTradingHoursFri.ClientID%>"), true);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursSat.ClientID%>"), true);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursSun.ClientID%>"), true);

				}
				function CopyTradingHoursMF(pWeekDay) 
				{
				    var tradinghourDefaultVal = '';
				    //debugger;
				    switch (pWeekDay)
				    {
				        case 1:
				        //use monday value
				            if (document.getElementById('<%=txtTradingHoursMon.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursMon.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursMon.ClientID%>').value;
				            }
				        case 2:
				        //use tuesday value
				            if (document.getElementById('<%=txtTradingHoursTue.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursTue.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursTue.ClientID%>').value;
				            }
				        case 3:
				        //use wednesday value
				            if (document.getElementById('<%=txtTradingHoursWed.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursWed.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursWed.ClientID%>').value;
				            }
				        case 4:
				        //use thursday value
				            if (document.getElementById('<%=txtTradingHoursThu.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursThu.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursThu.ClientID%>').value;
				            }
				        case 5:
				        //use friday value
				            if (document.getElementById('<%=txtTradingHoursFri.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursFri.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursFri.ClientID%>').value;
				            }
                        default:
                            break;                            				        
				    }
				    
					if (tradinghourDefaultVal.length > 0)
					{
					    //if there is a default value, fill the empty trading hours with the default value
					    if (document.getElementById('<%=txtTradingHoursMon.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursMon.ClientID%>').value = tradinghourDefaultVal;
						}
					
					    if (document.getElementById('<%=txtTradingHoursTue.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursTue.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursWed.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursWed.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursThu.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursThu.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursFri.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursFri.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursSat.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursSat.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursSun.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursSun.ClientID%>').value = tradinghourDefaultVal;
						}

					}
				}				
				
				// -->
</script>
	<asp:customvalidator id="cvTradingHoursMon" runat="server" ControlToValidate="txtTradingHoursMon" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursMon (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursTue" runat="server" ControlToValidate="txtTradingHoursTue" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursTue (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursWed" runat="server" ControlToValidate="txtTradingHoursWed" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursWed (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursThu" runat="server" ControlToValidate="txtTradingHoursThu" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursThu (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursFri" runat="server" ControlToValidate="txtTradingHoursFri" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursFri (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursSat" runat="server" ControlToValidate="txtTradingHoursSat" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid trading hours Sat (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursSun" runat="server" ControlToValidate="txtTradingHoursSun" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid trading hours Sun (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
    <asp:RegularExpressionValidator ID="revPhone1" runat="server" ControlToValidate="txtPhoneNumber"
        Display="None" ErrorMessage="Invalid phone number" ValidationExpression="\d{10}"></asp:RegularExpressionValidator>        
    <asp:RegularExpressionValidator ID="revPhone2" runat="server" ControlToValidate="txtPhoneNumber2"
        Display="None" ErrorMessage="Invalid phone number 2" ValidationExpression="\d{10}"></asp:RegularExpressionValidator>        
</asp:Content>

