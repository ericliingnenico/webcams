<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.QuickFind" Codebehind="QuickFind.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1"
		width="390" border="0">
		<TR>
			<TD colSpan="4"><asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="86"><asp:label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:label></TD>
			<TD><asp:dropdownlist id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="86">
				<asp:label id="Label3" runat="server" CssClass="FormDEHeader">Scope</asp:label></TD>
			<TD>
				<asp:RadioButtonList id="rblScope" runat="server" CssClass="FormDEField" RepeatDirection="Horizontal">
					<asp:ListItem Value="O" Selected="True">Open Jobs</asp:ListItem>
					<asp:ListItem Value="C">Closed Jobs</asp:ListItem>
					<asp:ListItem Value="B">Both</asp:ListItem>
				</asp:RadioButtonList></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD><asp:label id="lblState" runat="server" CssClass="FormDEHeader">Terminal ID</asp:label></TD>
			<TD><asp:textbox id="txtTerminalID" runat="server" CssClass="FormDEField"></asp:textbox></TD>
			<TD align="right">
                &nbsp;<INPUT class="FormDEButton" id="btnFindTerminalID" onclick="ValidatorEnable(Page_Validators[0],false);ValidatorEnable(Page_Validators[1],true);ValidatorEnable(Page_Validators[2],false);ValidatorEnable(Page_Validators[3],false);ValidatorEnable(Page_Validators[4],false);"
					type="submit" value=" GO " name="btnFindTerminalID" runat="server"></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD><asp:label id="Label1" runat="server" CssClass="FormDEHeader">Merchant ID</asp:label></TD>
			<TD><asp:textbox id="txtMerchantID" runat="server" CssClass="FormDEField"></asp:textbox></TD>
			<TD align="right">
                &nbsp;<INPUT class="FormDEButton" id="btnFindMerchantID" onclick="ValidatorEnable(Page_Validators[0],false);ValidatorEnable(Page_Validators[1],false);ValidatorEnable(Page_Validators[2],true);ValidatorEnable(Page_Validators[3],false);ValidatorEnable(Page_Validators[4],false);"
					type="submit" value=" GO " name="btnFindMerchantID" runat="server"></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD><asp:label id="Label2" runat="server" CssClass="FormDEHeader">Client Ref.</asp:label></TD>
			<TD><asp:textbox id="txtProblemNumber" runat="server" CssClass="FormDEField"></asp:textbox></TD>
			<TD align="right">
                &nbsp;<INPUT class="FormDEButton" id="btnFindProblemNumber" onclick="ValidatorEnable(Page_Validators[0],true);ValidatorEnable(Page_Validators[1],false);ValidatorEnable(Page_Validators[2],false);ValidatorEnable(Page_Validators[3],false);ValidatorEnable(Page_Validators[4],false);"
					type="submit" value=" GO " name="btnFindProblemNumber" runat="server"></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD><asp:label id="Label4" runat="server" CssClass="FormDEHeader">JobID</asp:label></TD>
			<TD><asp:textbox id="txtJobID" runat="server" CssClass="FormDEField"></asp:textbox></TD>
			<TD align="right">
                &nbsp;<INPUT class="FormDEButton" id="btnFindJobID" onclick="ValidatorEnable(Page_Validators[0],false);ValidatorEnable(Page_Validators[1],false);ValidatorEnable(Page_Validators[2],false);ValidatorEnable(Page_Validators[3],true);ValidatorEnable(Page_Validators[4],false);"
					type="submit" value=" GO " name="btnFindJobID" runat="server"></TD>
		</TR>
        <TR>
			<TD></TD>
			<TD><asp:label id="Label5" runat="server" CssClass="FormDEHeader">Cust. No.</asp:label></TD>
			<TD><asp:textbox id="txtCustomerNumber" runat="server" CssClass="FormDEField"></asp:textbox></TD>
			<TD align="right">
                &nbsp;<INPUT class="FormDEButton" id="btnFindCustomerNumber" onclick="ValidatorEnable(Page_Validators[0],false);ValidatorEnable(Page_Validators[1],false);ValidatorEnable(Page_Validators[2],false);ValidatorEnable(Page_Validators[3],false);ValidatorEnable(Page_Validators[4],true);"
					type="submit" value=" GO " name="btnFindCustomerNumber" runat="server"></TD>
		</TR>
	</TABLE>
	<asp:requiredfieldvalidator id="rfvProblemNumber" runat="server" CssClass="FormDEErrorr" ErrorMessage="Please enter Client Ref."
		Enabled="False" ControlToValidate="txtProblemNumber" Display="None"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvTerminalID" runat="server" CssClass="FormDEErrorr" ErrorMessage="Please enter TerminalID"
		Enabled="False" ControlToValidate="txtTerminalID" Display="None"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvMerchantID" runat="server" CssClass="FormDEErrorr" ErrorMessage="Please enter MerchantID"
		Enabled="False" ControlToValidate="txtMerchantID" Display="None"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvJobID" runat="server" CssClass="FormDEErrorr" ErrorMessage="Please enter JobID"
		Enabled="False" ControlToValidate="txtJobID" Display="None"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvCustomerNumber" runat="server" CssClass="FormDEErrorr" ErrorMessage="Please enter CustomerNumber"
		Enabled="False" ControlToValidate="txtCustomerNumber" Display="None"></asp:requiredfieldvalidator><asp:validationsummary id="vsMsg" runat="server" CssClass="FormDEErrorr" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>
</asp:Content>


