<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPDownloadSearch" Codebehind="FSPDownloadSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table1" cellSpacing="1" cellPadding="1" width="336" border="0" height="75">
		<TR>
			<TD colSpan="3"><asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label></TD>
		</TR>
		<TR>
			<td width="11"></td>
			<TD width="130"><asp:label id="lblCategory" runat="server" CssClass="FormDEHeader">Download Category</asp:label></TD>
			<TD><asp:dropdownlist id="cboDownloadCategory" runat="server" Width="184px"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<td></td>
			<TD></TD>
			<TD align="right"><asp:button id="btnGo" runat="server" Width="38px" Text="Go"></asp:button></TD>
		</TR>
	</TABLE>
</asp:Content>



