<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPJobSearch" Codebehind="FSPJobSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" style="WIDTH: 520px; HEIGHT: 152px" cellSpacing="1" cellPadding="1"
		width="520" border="0">
		<TR>
			<TD colSpan="3"><asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label></TD>
		</TR>
		<TR>
			<TD width="11" height="26"></TD>
			<TD width="130" height="26"><asp:label id="lblAssignedTo" runat="server" CssClass="FormDEHeader">Assigned To</asp:label></TD>
			<TD height="26"><asp:dropdownlist id="cboAssignedTo" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"><asp:label id="Label4" runat="server" CssClass="FormDEHeader">JobType</asp:label></TD>
			<TD height="16"><asp:dropdownlist id="cboJobType" runat="server" CssClass="FormDEField">
					<asp:ListItem Value="ALL">ALL</asp:ListItem>
					<asp:ListItem Value="INSTALL">INSTALL</asp:ListItem>
					<asp:ListItem Value="DEINSTALL">DEINSTALL</asp:ListItem>
					<asp:ListItem Value="UPGRADE">UPGRADE</asp:ListItem>
					<asp:ListItem Value="SWAP">SWAP</asp:ListItem>
				</asp:dropdownlist></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"><asp:label id="Label7" runat="server" CssClass="FormDEHeader">ProjectNo</asp:label></TD>
			<TD height="16"><asp:textbox id="txtProjectNo" runat="server" CssClass="FormDEField" Width="154px"></asp:textbox></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"><asp:label id="lblSuburb" runat="server" CssClass="FormDEHeader">Suburb</asp:label></TD>
			<TD height="16"><asp:textbox id="txtSuburb" runat="server" CssClass="FormDEField" Width="200px"></asp:textbox></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"><asp:label id="Label8" runat="server" CssClass="FormDEHeader">Postcode</asp:label></TD>
			<TD height="16"><asp:textbox id="txtPostcode" runat="server" CssClass="FormDEField" Width="40px"></asp:textbox></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"><asp:label id="Label5" runat="server" CssClass="FormDEHeader">Due Date</asp:label></TD>
			<TD height="16">
				<asp:textbox id="txtDueDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
				<asp:label id="Label9" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label>
			</TD>
		</TR>
		<TR>
			<TD width="11" height="26"></TD>
			<TD width="130" height="26"><asp:label id="Label6" runat="server" CssClass="FormDEHeader"> Options</asp:label></TD>
			<TD height="26">
                <asp:CheckBox id="chbIncludeChildDepot" runat="server" CssClass="FormDEField" Text="Include Child Depot"
					BackColor="White" ForeColor="Red"></asp:CheckBox><br>
				<asp:CheckBox id="chbIgnoreDueDate" runat="server" CssClass="FormDEField" Text="Ignore Due Date"
					Checked="True" BackColor="White" ForeColor="Red"></asp:CheckBox><br>
				<asp:CheckBox id="chbNoReservedDeviceOnly" runat="server" CssClass="FormDEField" BackColor="White"
					ForeColor="Red" Text="Upgrade jobs with no reserved devices only"></asp:CheckBox></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"><asp:label id="Label2" runat="server" CssClass="FormDEHeader">Refresh results every</asp:label></TD>
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
			<TD width="11" height="10"></TD>
			<TD colSpan="2"></TD>
		</TR>		
		<TR>
			<TD width="11" height="10"></TD>
			<TD colSpan="2">
				<asp:Label id="Label10" runat="server" CssClass="FormDEHeader">Or search on JobIDs only (Comma delimited on multiple JobIDs)</asp:Label></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="152">
				<asp:Label id="Label11" runat="server" CssClass="FormDEHeader">JobIDs</asp:Label></TD>
			<TD align="left"><asp:textbox id="txtJobIDs" runat="server" CssClass="FormDEField" Width="352px"></asp:textbox></TD>
		</TR>

		<TR>
			<TD width="11" height="17"></TD>
			<TD width="130" height="17"></TD>
			<TD align="right" height="17"></TD>
		</TR>
		<TR>
			<TD width="11" height="10"></TD>
			<TD width="130" height="10"></TD>
			<TD align="right" height="10"><INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " runat="server"></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="130"></TD>
			<TD align="right"></TD>
		</TR>
	</TABLE>
	<asp:CustomValidator id="cvDueDate" runat="server" ErrorMessage="Invalid Due Date" ClientValidationFunction="VerifyDate"
		ControlToValidate="txtDueDate" Display="None"></asp:CustomValidator>
	<asp:RequiredFieldValidator id="rfvDueDate" runat="server" Display="None" ControlToValidate="txtDueDate" ErrorMessage="Please enter DueDate"></asp:RequiredFieldValidator>
	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:ValidationSummary>
</asp:Content>



