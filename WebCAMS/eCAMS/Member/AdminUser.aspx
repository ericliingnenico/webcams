<%@ Page Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="Member_AdminUser" title="Untitled Page" Codebehind="AdminUser.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
					<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0" >
						<tr>
							<td colspan=3>
									<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
							</td>
						</tr>
						<TR>
							<TD width="10"></TD>
							<TD width="90">
								<asp:Label id="Label3" runat="server" CssClass="FormDEHeader">Email Address</asp:Label></TD>
							<TD >
							<asp:TextBox ID="txtEmailAddress" CssClass="FormDEField" runat="server"></asp:TextBox>
							<INPUT class="FormDEButton" id="btnGetUser" type="submit" value="Get User" name="btnGetUser"
									runat="server"  onclick="ValidatorEnable(Page_Validators[0], true);"></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD width="90">
								<asp:Label id="Label2" runat="server" CssClass="FormDEHeader">User Name</asp:Label></TD>
							<TD >
								<asp:TextBox ID="txtUserName" CssClass="FormDEField" runat="server"></asp:TextBox></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD width="90">
								<asp:Label id="Label5" runat="server" CssClass="FormDEHeader">MenuSetID</asp:Label></TD>
							<TD >
								<asp:TextBox ID="txtMenuSetID" CssClass="FormDEField" runat="server"></asp:TextBox><asp:label id="Label9" runat="server" CssClass="FormDEHint">1-Read Only, 2-Read/Write 3-FSP, 6-CBA, 9-TYR-Merchant</asp:label></TD>
						</TR>						

						<TR>
							<TD width="10"></TD>
							<TD width="90">
								<asp:Label id="Label1" runat="server" CssClass="FormDEHeader">ClientIDs</asp:Label></TD>
							<TD >
								<asp:TextBox ID="txtClientIDs" CssClass="FormDEField" runat="server"></asp:TextBox><asp:label id="Label6" runat="server" CssClass="FormDEHint">Only enter ClientID for Client Login</asp:label></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD width="90">
								<asp:Label id="Label4" runat="server" CssClass="FormDEHeader">InstallerID</asp:Label></TD>
							<TD >
								<asp:TextBox ID="txtInstallerID" CssClass="FormDEField" runat="server"></asp:TextBox><asp:label id="Label7" runat="server" CssClass="FormDEHint">Only enter InstallerID for FSP Login</asp:label></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD width="90"></TD>
							<TD align="left" >
								<asp:Button id="btnResetPWD" runat="server" CssClass="FormDEButton" Text="Reset PWD"></asp:Button>&nbsp;&nbsp;
								<asp:Button id="btnDeActiveUser" runat="server" CssClass="FormDEButton" Text="DeActive User"></asp:Button>&nbsp;&nbsp;
								<asp:Button id="btnAddUser" runat="server" CssClass="FormDEButton" Text="Add User"></asp:Button></TD>
						</TR>
					</TABLE>
    
						<asp:RequiredFieldValidator id="RequiredFieldValidator1" runat="server" CssClass="FormDEError" ErrorMessage="Enter User EmailAddress"
							ControlToValidate="txtEmailAddress" Display="None" Enabled=false></asp:RequiredFieldValidator>
						<asp:ValidationSummary id="ValidationSummary1" runat="server" CssClass="FormDEError" ShowMessageBox="True"
							ShowSummary="False"></asp:ValidationSummary>

</asp:Content>

