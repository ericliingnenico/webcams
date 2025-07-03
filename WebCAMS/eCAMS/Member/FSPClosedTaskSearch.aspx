<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPClosedTaskSearch" Codebehind="FSPClosedTaskSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="496" border="0" height="208">
		<TR>
			<TD colspan="3">
				<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
			</TD>
		</TR>
		<TR>
			<TD width="11" height="26"></TD>
			<TD width="122" height="26"><asp:label id="lblAssignedTo" runat="server" CssClass="FormDEHeader">Assigned To</asp:label></TD>
			<TD height="26"><asp:dropdownlist id="cboAssignedTo" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11" height="27"></TD>
			<TD width="122" height="27" vAlign="top">
				<asp:Label id="lblClientID" runat="server" CssClass="FormDEHeader">From ClosedDate</asp:Label></TD>
			<TD height="27">
				<asp:textbox id="txtFromDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
				<asp:label id="Label9" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="25"></TD>
			<TD width="122" height="25" vAlign="top">
				<asp:Label id="Label2" runat="server" CssClass="FormDEHeader">To ClosedDate</asp:Label></TD>
			<TD height="25">
				<asp:textbox id="txtToDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
				<asp:label id="Label4" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="122" height="16">
				<asp:Label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:Label></TD>
			<TD height="16">
				<asp:DropDownList id="cboPageSize" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="20">20</asp:ListItem>
					<asp:ListItem Value="40">40</asp:ListItem>
					<asp:ListItem Value="50" Selected="True">50</asp:ListItem>
					<asp:ListItem Value="60">60</asp:ListItem>
					<asp:ListItem Value="80">80</asp:ListItem>
					<asp:ListItem Value="100">100</asp:ListItem>
				</asp:DropDownList>&nbsp;
				<asp:Label id="Label1" runat="server" CssClass="FormDEInfo">records per page</asp:Label></TD>
		</TR>
		<TR>
			<TD width="11" height="17"></TD>
			<TD width="122" height="17"></TD>
			<TD align="right" height="17"><INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " name="btnSearch"
					runat="server"></TD>
		</TR>
		<TR>
			<TD width="11" height="10"></TD>
			<TD width="122" height="10"></TD>
			<TD align="right" height="10"></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="122"></TD>
			<TD align="right"></TD>
		</TR>
	</TABLE>
	<asp:CustomValidator id="cvFromDate" runat="server" ErrorMessage="Invalid FromDate" ClientValidationFunction="VerifyDate"
		ControlToValidate="txtFromDate" Display="None"></asp:CustomValidator>
	<asp:CustomValidator id="cvToDate" runat="server" ErrorMessage="Invalid ToDate" Display="None" ClientValidationFunction="VerifyDate"
		ControlToValidate="txtToDate"></asp:CustomValidator>
	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:ValidationSummary>
	<asp:RequiredFieldValidator id="rfvFromDate" runat="server" Display="None" ControlToValidate="txtFromDate" ErrorMessage="Please enter FromDate"></asp:RequiredFieldValidator>
	<asp:RequiredFieldValidator id="rfvToDate" runat="server" Display="None" ControlToValidate="txtToDate" ErrorMessage="Please enter ToDate"></asp:RequiredFieldValidator>
</asp:Content>



