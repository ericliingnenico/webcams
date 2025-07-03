<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ForgotPWD.aspx.vb" Inherits="eCAMS.ForgotPWD" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Register Src="~/UserControl/CopyrightLabel.ascx" TagPrefix="custom" TagName="CopyrightLabel" %>

<HTML>
	<HEAD>
		<title>Login</title>
		<meta name="GENERATOR" content="Microsoft Visual Studio.NET 7.0">
		<meta name="CODE_LANGUAGE" content="Visual Basic 7.0">
		<meta name="vs_defaultClientScript" content="JavaScript">
		<meta name="vs_targetSchema" content="http://schemas.microsoft.com/intellisense/ie5">
		<LINK href="../Styles/Styles.css" type="text/css" rel="stylesheet">
		<LINK href="../Styles/keycorp.css" type="text/css" rel="stylesheet">
</HEAD>
	<body>
		<form id="Form1" method="post" runat="server">
			<!-- Anti-Forgery token here -->
    <%: System.Web.Helpers.AntiForgery.GetHtml() %>
<TABLE id="Table1" cellSpacing="2" cellPadding="2" width="100%" border="0">
    <tr style="height: 10px;"></tr>
	<TR>
		<TD class="header">
			<A href="http://www.ingenico.com/"><IMG alt="Ingenico" hspace="20" src="../images/kyc/ingenico_logo.png"
					border="0"></A>
		</TD>
	</TR>
    <tr style="height: 10px;"></tr>
	<tr>
		<TD vAlign="top" class="contentborder">
						<table cellSpacing="0" cellPadding="5" width="100%" border="0">
							<tr>
								<td align="left"  class="sectionbar"><font face="Arial" color="white"><b class="FormHeaderWhite">Forgot your password?</b></font>
								</td>
							</tr>
							<tr>
								<td height="25" style="WIDTH: 243px">
									<table width="270" style="WIDTH: 320px; HEIGHT: 125px">
   										<tr>
											<td colspan=2 align=left>
                                                <asp:Label id="lblFormTitle" runat="server" CssClass="FormDEHeader">To reset your password, type the email address you use to login to your Account. </asp:Label>
                                            </td>
										</tr>

										<tr>
											<td>
												<asp:Label id="lblEmailAddress" runat="server" CssClass="FormDEHeader" Width="66px">EmailAddress</asp:Label>
											</td>
											<td><asp:textbox id="txtEmailAddress" runat="server" CssClass="FormDEField" Width="200px" MaxLength="100"></asp:textbox></td>
										</tr>
										<tr>
											<td></td>
											<td align="right">
                                                <asp:Button ID="btnSubmit" runat="server" Text="Submit" />
                                            </td>
										</tr>
										<tr>
											<td align="center" colSpan="2"><asp:Label id="lblErrorMsg" runat="server" CssClass="FormDEErrorr" Visible="False">Failed to reset password!</asp:Label>
											</td>
										</tr>
										<tr>
											<td colspan=2 align=center>
                                                <asp:hyperlink id="backURL" runat="server" NavigateUrl="Login.aspx" CssClass="FormDEHeader" Visible="False">Back to Login</asp:hyperlink>
                                            </td>
										</tr>

									</table>
								</td>
							</tr>
						</table>
						<!--END LOGIN MODULE-->
						<asp:RequiredFieldValidator id="RequiredFieldValidator1" CssClass="FormDEError" runat="server" ErrorMessage="Enter Email Address"
							ControlToValidate="txtEmailAddress" Display="None"></asp:RequiredFieldValidator>
						<asp:ValidationSummary id="ValidationSummary1" CssClass="FormDEError" runat="server" ShowSummary="False"
							ShowMessageBox="True"></asp:ValidationSummary>
		</TD>
	</tr>
</TABLE>
		<TABLE id="tblFooter" width="100%">
			<TR>
				<TD class="footer" vAlign="top"><custom:CopyrightLabel ID="CopyrightLabel1" runat="server" />
				</TD>
			</TR>
		</TABLE>

		</form>
	</body>
</html>
