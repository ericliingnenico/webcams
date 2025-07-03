<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPClosedJobSearch" Codebehind="FSPClosedJobSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" height="216" cellSpacing="1" cellPadding="1" width="496" border="0">
		<TR>
			<TD colSpan="3"><asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="26"></TD>
			<TD width="152" height="26"><asp:label id="lblAssignedTo" runat="server" CssClass="FormDEHeader">Assigned To</asp:label></TD>
			<TD height="26"><asp:dropdownlist id="cboAssignedTo" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="152" height="16"><asp:label id="Label4" runat="server" CssClass="FormDEHeader">JobType</asp:label></TD>
			<TD height="16"><asp:dropdownlist id="cboJobType" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="ALL">ALL</asp:ListItem>
					<asp:ListItem Value="INSTALL">INSTALL</asp:ListItem>
					<asp:ListItem Value="DEINSTALL">DEINSTALL</asp:ListItem>
					<asp:ListItem Value="UPGRADE">UPGRADE</asp:ListItem>
					<asp:ListItem Value="SWAP">SWAP</asp:ListItem>
				</asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11" height="32"></TD>
			<TD width="152" height="32"><asp:label id="lblClientID" runat="server" CssClass="FormDEHeader">From ClosedDate</asp:label></TD>
			<TD height="32"><asp:textbox id="txtFromDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox><asp:label id="Label9" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="24"></TD>
			<TD width="152" height="24"><asp:label id="Label2" runat="server" CssClass="FormDEHeader">To ClosedDate</asp:label></TD>
			<TD height="24"><asp:textbox id="txtToDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox><asp:label id="Label3" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="152" height="16"><asp:label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:label></TD>
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
			<TD width="11" height="10"></TD>
			<TD colSpan="2"></TD>
		</TR>		
		<TR>
			<TD width="11" height="10"></TD>
			<TD colSpan="2">
				<asp:Label id="Label6" runat="server" CssClass="FormDEHeader">Or search on JobIDs only (Comma delimited on multiple JobIDs)</asp:Label></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="152">
				<asp:Label id="Label5" runat="server" CssClass="FormDEHeader">JobIDs</asp:Label></TD>
			<TD align="left"><asp:textbox id="txtJobIDs" runat="server" CssClass="FormDEField" Width="352px"></asp:textbox></TD>
		</TR>
		<TR>
			<TD width="11" height="17"></TD>
			<TD width="152" height="17"></TD>
			<TD align="right" height="17"><INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " name="btnSearch"
					runat="server"></TD>
		</TR>
	</TABLE>
	<asp:customvalidator id="cvFromDate" runat="server" ControlToValidate="txtFromDate" ClientValidationFunction="VerifyDate"
		Display="None" ErrorMessage="Invalid FromDate"></asp:customvalidator><asp:customvalidator id="cvToDate" runat="server" ControlToValidate="txtToDate" ClientValidationFunction="VerifyDate"
		Display="None" ErrorMessage="Invalid ToDate"></asp:customvalidator><asp:requiredfieldvalidator id="rfvFromDate" runat="server" ControlToValidate="txtFromDate" Display="None" ErrorMessage="Please enter FromDate"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvToDate" runat="server" ControlToValidate="txtToDate" Display="None" ErrorMessage="Please enter ToDate"></asp:requiredfieldvalidator><asp:validationsummary id="ValidationSummary1" runat="server" ShowSummary="False" ShowMessageBox="True"></asp:validationsummary>
</asp:Content>



