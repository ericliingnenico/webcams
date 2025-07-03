<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPDeviceSearch" Codebehind="FSPDeviceSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" style="WIDTH: 520px; HEIGHT: 152px" cellSpacing="1" cellPadding="1"
		width="520" border="0">
		<TR>
			<TD colspan="3">
				<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
			</TD>
		</TR>
		<TR>
			<TD width="11" height="26"></TD>
			<TD width="130" height="26"><asp:label id="lblSerial" runat="server" CssClass="FormDEHeader">Serial Number</asp:label></TD>
			<TD height="26">
				<asp:textbox id="txtSerial" runat="server" CssClass="FormDEField"></asp:textbox></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"><asp:label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:label></TD>
			<TD height="16"><asp:dropdownlist id="cboPageSize" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="20">20</asp:ListItem>
					<asp:ListItem Value="40">40</asp:ListItem>
					<asp:ListItem Value="50" Selected="True">50</asp:ListItem>
					<asp:ListItem Value="60">60</asp:ListItem>
					<asp:ListItem Value="80">80</asp:ListItem>
					<asp:ListItem Value="100">100</asp:ListItem>
				</asp:dropdownlist>&nbsp;
				<asp:label id="Label1" runat="server" CssClass="FormDEInfo">records per page</asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="17"></TD>
			<TD width="130" height="17"></TD>
			<TD align="right" height="17"></TD>
		</TR>
		<TR>
			<TD width="11" height="10"></TD>
			<TD width="130" height="10"></TD>
			<TD align="right" height="10"><INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " runat="server" NAME="btnSearch"></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="130"></TD>
			<TD align="right"></TD>
		</TR>
	</TABLE>
	<asp:RequiredFieldValidator id="rfvSerial" runat="server" ErrorMessage="Please enter Serial Number." ControlToValidate="txtSerial"
		Display="None"></asp:RequiredFieldValidator>
	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"
		Width="152px"></asp:ValidationSummary>
</asp:Content>



