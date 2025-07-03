<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPReAssignJob" Codebehind="FSPReAssignJob.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<asp:hyperlink id="SearchAgainURL" runat="server" CssClass="MemberInfo" NavigateUrl="FSPJobList.aspx"
			Width="40px">&lt&ltBack</asp:hyperlink>
	<asp:panel id="panelDetail" runat="server">
		<TABLE id="Table2" style="WIDTH: 616px; HEIGHT: 391px" cellSpacing="1" cellPadding="1"
			width="616" border="0">
			<TR>
				<TD colSpan="3">
					<asp:Label id="lblErrorMsg" runat="server" CssClass="FormDEError"></asp:Label></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="Label2" runat="server" CssClass="FormDEHeader">Job ID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtJobID" runat="server" CssClass="FormDEField" ReadOnly="True"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="lblCurrentAssigned" runat="server" CssClass="FormDEHeader">Current Assigned To</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtCurrentAssigned" runat="server" CssClass="FormDEField" ReadOnly="True"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="lblAssignedTo" runat="server" CssClass="FormDEHeader">Re-Assigned To</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboAssignedTo" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="146"></TD>
				<TD vAlign="top" width="134" height="146">
					<asp:label id="lblJobDetails" runat="server" CssClass="FormDEHeader">Job Details</asp:label></TD>
				<TD height="146">
					<asp:textbox id="txtJobDetails" runat="server" CssClass="FormDEField" 
                        Width="456px" ReadOnly="True" 
						TextMode="MultiLine" Height="146px"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="17"></TD>
				<TD width="134" height="17">
					<asp:label id="Label1" runat="server" CssClass="FormDEHeader">Device In/Out</asp:label></TD>
				<TD align="left" height="17">
					<asp:datagrid id="grdDevice" runat="server" CssClass="FormGrid">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
			</TR>
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="134" height="10"></TD>
				<TD align="right" height="10"><INPUT class="FormDEButton" id="btnReAssign" type="submit" value="Re-Assign" name="btnReAssign"
						runat="server"></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="134"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>
	</asp:panel>
</asp:Content>



