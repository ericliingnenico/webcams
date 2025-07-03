<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pFSPTaskSearch" Codebehind="pFSPTaskSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:label id="lblFormTitle" runat="server" CssClass="pFormTitle"></asp:label>
	<TABLE id="Table1" cellSpacing="1" cellPadding="1" width="296" border="0">
		<TR>
			<TD width="1" height="26"></TD>
			<TD width="19" height="26">
				<asp:label id="lblAssignedTo" runat="server" CssClass="pformdeheader">FSP</asp:label></TD>
			<TD height="26">
				<asp:dropdownlist id="cboAssignedTo" runat="server" CssClass="pFormDEField" Width="184px" Font-Size="Smaller"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="1" height="16"></TD>
			<TD width="19" height="16">
				<asp:label id="lblPageSize" runat="server" CssClass="pFormDEHeader">Size</asp:label></TD>
			<TD height="16">
				<asp:dropdownlist id="cboPageSize" runat="server" CssClass="pFormDEField" Font-Size="Smaller">
					<asp:ListItem Value="20" Selected="True">20</asp:ListItem>
					<asp:ListItem Value="40">40</asp:ListItem>
					<asp:ListItem Value="50">50</asp:ListItem>
					<asp:ListItem Value="60">60</asp:ListItem>
					<asp:ListItem Value="80">80</asp:ListItem>
					<asp:ListItem Value="100">100</asp:ListItem>
				</asp:dropdownlist>&nbsp;
				<asp:label id="Label1" runat="server" CssClass="pMemberInfo">records per page</asp:label></TD>
		</TR>
		<TR>
			<TD width="1" height="17"></TD>
			<TD width="19" height="17"></TD>
			<TD align="right" height="17"></TD>
		</TR>
		<TR>
			<TD width="1" height="10"></TD>
			<TD width="19" height="10"></TD>
			<TD align="left" height="10"><INPUT class="pFormDEButton" id="btnSearch" type="submit" value=" GO " name="btnSearch"
					runat="server"></TD>
		</TR>
		<TR>
			<TD width="1"></TD>
			<TD width="19"></TD>
			<TD align="right"></TD>
		</TR>
	</TABLE>
</asp:Content>
