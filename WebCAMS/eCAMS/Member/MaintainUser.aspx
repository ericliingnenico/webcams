<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.MaintainUser" Codebehind="MaintainUser.aspx.vb" %>
		<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
					<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="309" border="0" style="WIDTH: 309px; HEIGHT: 118px">
						<tr>
							<td colspan=3>
									<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
							</td>
						</tr>
						<TR>
							<TD width="10"></TD>
							<TD style="WIDTH: 145px">
								<asp:Label id="Label2" runat="server" CssClass="FormDEHeader">User Name</asp:Label></TD>
							<TD>
								<INPUT class="FormDEField" id="txtUserName" type="text" name="txtUserName" runat="server"></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD style="WIDTH: 145px">
								<asp:Label id="Label3" runat="server" CssClass="FormDEHeader">Email Address</asp:Label></TD>
							<TD>
								<INPUT class="FormDEField" id="txtEmailAddress" type="text" name="txtEmailAddress" runat="server"
									disabled></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD style="WIDTH: 145px">
								<asp:Label id="Label1" runat="server" CssClass="FormDEHeader">Phone</asp:Label></TD>
							<TD>
								<INPUT class="FormDEField" id="txtPhone" type="text" name="txtPhone" runat="server"></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD style="WIDTH: 145px">
								<asp:Label id="Label4" runat="server" CssClass="FormDEHeader">Fax</asp:Label></TD>
							<TD>
								<INPUT class="FormDEField" id="txtFax" type="text" name="txtFax" runat="server"></TD>
						</TR>
						<TR>
							<TD width="10"></TD>
							<TD style="WIDTH: 145px"></TD>
							<TD align="right">
								<asp:Button id="btnSave" runat="server" CssClass="FormDEButton" Text="Save"></asp:Button></TD>
						</TR>
					</TABLE>
						<asp:RequiredFieldValidator id="RequiredFieldValidator2" runat="server" CssClass="FormDEError" ErrorMessage="Enter User Name"
							ControlToValidate="txtUserName" Display="None"></asp:RequiredFieldValidator>
						<asp:RequiredFieldValidator id="Requiredfieldvalidator1" runat="server" CssClass="FormDEError" ErrorMessage="Enter Email Address"
							ControlToValidate="txtEmailAddress" Display="None"></asp:RequiredFieldValidator>
						<asp:ValidationSummary id="ValidationSummary1" runat="server" CssClass="FormDEError" ShowMessageBox="True"
							ShowSummary="False"></asp:ValidationSummary>
		</asp:Content>



