<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.DeviceSearch" Codebehind="DeviceSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" style="WIDTH: 400px; HEIGHT: 140px" cellSpacing="1" cellPadding="1"
		width="400" border="0">
		<TR>
			<TD colspan="3">
				<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>
				<asp:label id="lblErrorInfo" runat="server" CssClass="FormDEHint"></asp:label>
			</TD>
		</TR>
		<TR>
			<TD width="11" height="26"></TD>
			<TD width="86" height="26"><asp:label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:label></TD>
			<TD height="26"><asp:dropdownlist id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11" height="21"></TD>
			<TD width="86" height="21"><asp:label id="lblState" runat="server" CssClass="FormDEHeader">Serial No.</asp:label></TD>
			<TD height="21"><asp:textbox id="txtSerial" runat="server" CssClass="FormDEField"></asp:textbox><DIV class="FormDEHint" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px"> ?</DIV></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="86" height="16"><asp:label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:label></TD>
			<TD height="16"><asp:dropdownlist id="cboPageSize" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="20" Selected="True">20</asp:ListItem>
					<asp:ListItem Value="40">40</asp:ListItem>
					<asp:ListItem Value="50">50</asp:ListItem>
					<asp:ListItem Value="60">60</asp:ListItem>
					<asp:ListItem Value="80">80</asp:ListItem>
					<asp:ListItem Value="100">100</asp:ListItem>
				</asp:dropdownlist><asp:label id="Label1" runat="server" CssClass="FormDEInfo">records per page</asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="17"></TD>
			<TD width="86" height="17"></TD>
			<TD align="left" height="17">
                <DIV class="FormDEHint" style="DISPLAY: inline; WIDTH: 250px; HEIGHT: 28px">?: 
						Can use % as prefix/affix wildcard to broaden the search and only show the first 20 devices when more than 20 are found.</DIV>
    		</TD>
		</TR>
		<TR>
			<TD width="11" height="10"></TD>
			<TD width="86" height="10"></TD>
			<TD align="center" height="10">
                &nbsp;<INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " name="btnSearch"
					runat="server"></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="86"></TD>
			<TD align="right"></TD>
		</TR>
	</TABLE>
	<asp:requiredfieldvalidator id="rfvtxtSerial" runat="server" CssClass="FormDEErrorr" ErrorMessage="Please enter SerialNo."
		ControlToValidate="txtSerial" Display="None"></asp:requiredfieldvalidator>
    <asp:RegularExpressionValidator ID="revtxtSerial" runat="server" ControlToValidate="txtSerial"
        Display="None" ErrorMessage="SerialNo entered is too short" ValidationExpression="^(.*(\d{4}).*)|(.*(\d{3}-).*)|(.*(-\d{3}).*)$"></asp:RegularExpressionValidator>        
    <asp:validationsummary id="ValidationSummary1" runat="server" CssClass="FormDEErrorr" ShowMessageBox="True"
		ShowSummary="False"></asp:validationsummary>
</asp:Content>



