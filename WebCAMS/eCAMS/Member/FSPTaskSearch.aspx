<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPTaskSearch" Codebehind="FSPTaskSearch.aspx.vb" %>
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
			<TD width="130" height="26" style="WIDTH: 130px"><asp:label id="lblAssignedTo" runat="server" CssClass="FormDEHeader">Assigned To</asp:label></TD>
			<TD height="26"><asp:dropdownlist id="cboAssignedTo" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16" style="WIDTH: 130px"><asp:label id="Label2" runat="server" CssClass="FormDEHeader">Refresh results every</asp:label></TD>
			<TD height="16"><asp:dropdownlist id="cboRefreshMinute" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="5" Selected="True">5</asp:ListItem>
					<asp:ListItem Value="10">10</asp:ListItem>
					<asp:ListItem Value="15">15</asp:ListItem>
					<asp:ListItem Value="-1">NIL</asp:ListItem>
				</asp:dropdownlist>&nbsp;
				<asp:label id="Label3" runat="server" CssClass="FormDEInfo">minutes (select NIL to stop the refresh)</asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16" style="WIDTH: 130px"><asp:label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:label></TD>
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
			<TD width="130" height="17" style="WIDTH: 130px"></TD>
			<TD align="right" height="17"></TD>
		</TR>
		<TR>
			<TD width="11" height="10"></TD>
			<TD width="130" height="10" style="WIDTH: 130px"></TD>
			<TD align="right" height="10"><INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " runat="server" NAME="btnSearch"></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="130" style="WIDTH: 130px"></TD>
			<TD align="right"></TD>
		</TR>
	</TABLE>
</asp:Content>



