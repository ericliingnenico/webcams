
<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPMaintainPWD" Codebehind="FSPMaintainPWD.aspx.vb" %>
		<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<%@ Register Src="../UserControl/UserPasswordAlert.ascx" TagName="UserPasswordAlert"
    TagPrefix="uc1" %>		
				<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="500" border="0" style="WIDTH: 500px; HEIGHT: 118px">
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
					<tr>
						<td colspan="3">
							<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>
					<tr>
						<td colspan="3">
							<asp:Label id="lblFormTitle1" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>
					<tr>
						<td colspan="3">
							<uc1:UserPasswordAlert ID="UserPasswordAlert1" runat="server" />
						</td>
					</tr>
                <asp:Panel ID="panelPasswordDE" runat="server">
                    <tr>
				        <td width="11" height="26"></td>
				        <td width="145" height="26">
					        <asp:label id="Label8" runat="server" CssClass="FormDEHeader">FSP</asp:label></td>
				        <td height="26">
					        <asp:dropdownlist id="cboFSP" runat="server"></asp:dropdownlist>
                        </td>
			        </tr>
					<tr>
						<td colspan="3">
							<asp:label id="Label9" runat="server" CssClass="FormDEHint">Min 8 characters (14 for admin ), at least one uppercase letter, one lowercase letter and one numbers.(NO  special character)<br/><br/>Please ask Administrator  for assistance to reset your password if it has expired
</asp:label>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<asp:Label id="lblFormTitle3" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<asp:Label id="lblFormTitle4" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<asp:Label id="lblFormTitle5" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>	
					<tr>
						<td colspan="6">
							<asp:Label id="lblFormTitle6" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<asp:Label id="lblFormTitle7" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<asp:Label id="lblFormTitle8" runat="server" CssClass="FormTitle"></asp:Label>
						</td>
					</tr>
					<tr>
						<td width="10"></td>
						<td width="145">
							<asp:Label id="Label2" runat="server" CssClass="FormDEHeader">New Password</asp:Label></td>
						<td width="145">
							<input class="FormDEField" id="txtNewPWD" type="password" name="txtNewPWD" runat="server" /></td>
					</tr>
					<tr>
						<td width="10"></td>
						<td width="145">
							<asp:Label id="Label3" runat="server" CssClass="FormDEHeader">ReType New Password</asp:Label></td>
						<td width="145">
							<input class="FormDEField" id="txtReTypeNewPWD" type="password" name="txtReTypeNewPWD" runat="server" /></td>
					</tr>
					<tr>
						<td width="10"></td>
						<td style="WIDTH: 145px"></td>
						<td align="right" style="width: 135px">
							<asp:Button id="btnSave" runat="server" CssClass="FormDEButton" Text="Save"></asp:Button></td>
					</tr>
					<asp:RequiredFieldValidator id="RequiredFieldValidator2" runat="server" CssClass="FormDEError" ErrorMessage="Enter new password"
						ControlToValidate="txtNewPWD" Display="None"></asp:RequiredFieldValidator>
					<asp:CompareValidator id="CompareValidator1" runat="server" CssClass="FormDEError" ErrorMessage="New password and ReType password are not the same value"
						ControlToValidate="txtNewPWD" ControlToCompare="txtReTypeNewPWD" Display="None"></asp:CompareValidator>
                    <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtNewPWD"
                            Display="None" ErrorMessage="Min 8 characters (14 for admin ), at least one uppercase letter, one lowercase letter and one numbers.(NO  special character)
" ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$"></asp:RegularExpressionValidator>
					<asp:ValidationSummary id="ValidationSummary1" runat="server" CssClass="FormDEError" ShowMessageBox="True"
						ShowSummary="False"></asp:ValidationSummary>
                </asp:Panel>
				</TABLE>
		</asp:Content>



