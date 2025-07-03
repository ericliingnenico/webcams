<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pFSPReAssignJob" Codebehind="pFSPReAssignJob.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<asp:label id="lblFormTitle" runat="server" CssClass="pFormTitle"></asp:label><asp:hyperlink id="SearchAgainURL" runat="server" CssClass="pMemberInfo" NavigateUrl="pFSPJobList.aspx"
		Width="152px"> &lt&lt Back</asp:hyperlink><asp:panel id="panelDetail" runat="server" Height="264px">
		<TABLE id="Table1" style="WIDTH: 248px; HEIGHT: 265px" cellSpacing="1" cellPadding="1"
			width="248" border="0">
			<TR>
				<TD width="1" height="20"></TD>
				<TD width="45" height="20">
					<asp:label id="Label2" runat="server" CssClass="pformdeheader">JobID</asp:label></TD>
				<TD height="20">
					<asp:Label id="txtJobID" runat="server" CssClass="pFormDEField" Font-Size="Smaller">txtJobID</asp:Label></TD>
			</TR>
			<TR>
				<TD width="1" height="24"></TD>
				<TD width="45" height="24">
					<asp:label id="Label3" runat="server" CssClass="pformdeheader">Current FSP</asp:label></TD>
				<TD height="24">
					<asp:Label id="txtCurrentAssigned" runat="server" CssClass="pFormDEField" Font-Size="Smaller">txtCurrentAssigned</asp:Label></TD>
			</TR>
			<TR>
				<TD width="1" height="26"></TD>
				<TD width="45" height="26">
					<asp:label id="lblAssignedTo" runat="server" CssClass="pformdeheader">Assing To</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboAssignedTo" runat="server" CssClass="pFormDEField" Width="184px" Font-Size="Smaller"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="1" height="26"></TD>
				<TD width="45" height="26">
					<asp:label id="Label4" runat="server" CssClass="pformdeheader">Details</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtJobDetails" runat="server" CssClass="pFormDEField" Width="224px" Height="104px"
						Font-Size="Smaller" TextMode="MultiLine" Rows="4" ReadOnly="True" Columns="25"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="1" height="17"></TD>
				<TD width="45" height="17"></TD>
				<TD align="right" height="17"></TD>
			</TR>
			<TR>
				<TD width="1" height="10"></TD>
				<TD width="45" height="10"></TD>
				<TD align="left" height="10"><INPUT class="pFormDEButton" id="btnReAssign" type="submit" value=" GO " name="btnSearch"
						runat="server"></TD>
			</TR>
		</TABLE>
	</asp:panel>
</asp:Content>
