<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.master" CodeBehind="FSPDelegation.aspx.vb" Inherits="eCAMS.FSPDelegation" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
   <ASP:PlaceHolder runat="server" id="placeholderErrorMsg"></ASP:PlaceHolder>
   <asp:HiddenField ID="txtLogID" runat="server" />
	<TABLE id="Table2" style="WIDTH: 520px; HEIGHT: 152px" cellSpacing="1" cellPadding="1"
		width="520" border="0" > 
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label8" runat="server" CssClass="FormDEHeader">FSP</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboFSP" runat="server"></asp:dropdownlist>
                </TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label5" runat="server" CssClass="FormDEHeader">FromDateTime</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtFromDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
					<asp:textbox id="txtFromTime" runat="server" CssClass="FormDEField" Width="60px"></asp:textbox>
                    <asp:label id="Label18" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy hhmm)</asp:label></TD>
			</TR>
            <tr>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label1" runat="server" CssClass="FormDEHeader">ToDateTime</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtToDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
					<asp:textbox id="txtToTime" runat="server" CssClass="FormDEField" Width="60px"></asp:textbox>
                    <asp:label id="Label6" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy hhmm)</asp:label></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label2" runat="server" CssClass="FormDEHeader">AssignToFSP</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboAssignedToFSP" runat="server"></asp:dropdownlist>
                </TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label3" runat="server" CssClass="FormDEHeader">Reason</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboReason" runat="server"></asp:dropdownlist>
                </TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label4" runat="server" CssClass="FormDEHeader">Notes</asp:label></TD>
				<TD >
					<asp:textbox id="txtNotes" runat="server" Width="552px" Rows="3" TextMode="MultiLine" class="txtwithcounter" charlimit="200" charlimitinfo="Span1"></asp:textbox>
                     <br /><span id="Span1" class="charlimitinfo"></span> 
				</TD>
			</TR>
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="130" height="10"></TD>
				<TD align="center" height="10">
                    <asp:Button ID="btnSave" runat="server" Text="Save" OnClientClick ="SetDelegationValidator();"/>
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel Delegation" OnClientClick = "return confirm('Are you sure to cancel this delegation?');" />
                </TD>
			</TR>
    </TABLE>
    <asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>
    <asp:customvalidator id="cvFromDate" runat="server" ErrorMessage="Invalid FromDate" Display="None" Enabled="False" ControlToValidate="txtFromDate" ClientValidationFunction="VerifyDate"></asp:customvalidator>
    <asp:customvalidator id="cvFromTime" runat="server" ErrorMessage="Invalid FromTime" Display="None" Enabled="False" ControlToValidate="txtFromTime" ClientValidationFunction="VerifyTime"></asp:customvalidator>
    <asp:requiredfieldvalidator id="rfvFromDate" runat="server" ErrorMessage="Please enter FromDate" Display="None"	Enabled="False" ControlToValidate="txtFromDate"></asp:requiredfieldvalidator>
    <asp:requiredfieldvalidator id="rfvFromTime" runat="server" ErrorMessage="Please enter FromTime" Display="None"	Enabled="False" ControlToValidate="txtFromTime"></asp:requiredfieldvalidator>
    <asp:customvalidator id="cvToDate" runat="server" ErrorMessage="Invalid ToDate" Display="None" Enabled="False" ControlToValidate="txtToDate" ClientValidationFunction="VerifyDate"></asp:customvalidator>
    <asp:customvalidator id="cvToTime" runat="server" ErrorMessage="Invalid ToTime" Display="None" Enabled="False" ControlToValidate="txtToTime" ClientValidationFunction="VerifyTime"></asp:customvalidator>
    <asp:requiredfieldvalidator id="rfvToDate" runat="server" ErrorMessage="Please enter ToDate" Display="None" Enabled="False" ControlToValidate="txtToDate"></asp:requiredfieldvalidator>
    <asp:requiredfieldvalidator id="rfvToTime" runat="server" ErrorMessage="Please enter ToTime" Display="None" Enabled="False" ControlToValidate="txtToTime"></asp:requiredfieldvalidator>
	<script language="javascript">
	<!--
	    function ResetAllValidators() {
	        //				could use Page_Validators[] generated on client
	        ValidatorEnable(document.getElementById("<%=cvFromDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvFromTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvFromDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvFromTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvToDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvToTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvToDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvToTime.ClientID%>"), false);
	    }

	    function SetDelegationValidator() {
	        ValidatorEnable(document.getElementById("<%=cvFromDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=cvFromTime.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvFromDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvFromTime.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=cvToDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=cvToTime.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvToDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvToTime.ClientID%>"), true);
	    }
	// -->
	</script>

</asp:Content>
