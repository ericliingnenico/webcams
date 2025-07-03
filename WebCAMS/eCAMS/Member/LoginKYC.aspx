<%@ Page Language="VB" AutoEventWireup="false" Inherits="eCAMS.Member_LoginKYC" Codebehind="LoginKYC.aspx.vb" %>
<%@ Register Src="~/UserControl/CopyrightLabel.ascx" TagPrefix="custom" TagName="CopyrightLabel" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
	<HEAD>
		<title>Login</title>
		<meta name="GENERATOR" content="Microsoft Visual Studio.NET 7.0">
		<meta name="CODE_LANGUAGE" content="Visual Basic 7.0">
		<meta name="vs_defaultClientScript" content="JavaScript">
		<meta name="vs_targetSchema" content="http://schemas.microsoft.com/intellisense/ie5">
		<LINK href="../Styles/Styles.css" type="text/css" rel="stylesheet">
		<LINK href="../Styles/keycorp.css" type="text/css" rel="stylesheet">
        <link href="../Images/homescreen.gif" rel="apple-touch-icon" />
        <link href="../Images/CAMS.ico" rel="SHORTCUT ICON"/>  	
	    <style type="text/css">
            .style1
            {
                background-color: #F23D3C;
                height: 26px;
            }
        </style>
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
								<td align="left"  class="style1"><font face="Arial" color="white"><b class="FormHeaderWhite">CAMS Web Portal Login</b></font>
								</td>
							</tr>
							<tr>
								<td height="25" style="WIDTH: 243px">
									<table width="270" style="WIDTH: 270px; HEIGHT: 125px">
										<tr>
											<td style="WIDTH: 88px; HEIGHT: 32px" vAlign="middle">&nbsp;
												<asp:Label id="lblUserName" runat="server" CssClass="FormDEHeader" Width="66px"> UserName</asp:Label>
											</td>
											<td vAlign="middle" style="HEIGHT: 32px"><b><asp:textbox id="UserName" runat="server" CssClass="FormDEField" Width="173px" Height="23px"
														MaxLength="100"></asp:textbox></b></td>
										</tr>
										<tr>
											<td style="WIDTH: 88px; HEIGHT: 31px" vAlign="middle">&nbsp;
												<asp:Label id="lblPassword" runat="server" CssClass="FormDEHeader">Password</asp:Label>
											</td>
											<td vAlign="middle" style="HEIGHT: 31px"><input id="Password" type="password" size="23" name="Password" runat="server" class="FormDEField"
													style="WIDTH: 171px; HEIGHT: 24px"></td>
										</tr>
										<tr>
											<td style="WIDTH: 88px; HEIGHT: 25px" vAlign="middle"></td>
											<td style="HEIGHT: 25px" align="right" vAlign="middle"><input id="btnSingIn" type="submit" value="Login" name="btnSingIn" runat="server" class="FormDEButton"
													style="WIDTH: 77px; HEIGHT: 22px"></td>
										</tr>
										<tr>
											<td align="center" colSpan="2"><asp:Label id="lblErrorMsg" runat="server" CssClass="FormDEErrorr" Visible="False">Invalid&nbsp;UserName or Password!</asp:Label>
											</td>
										</tr>
										<tr>
											<td colspan=2 align=center>
                                                <asp:hyperlink id="backURL" runat="server" NavigateUrl="ForgotPWD.aspx" CssClass="FormDEHeader">Can't access your account?</asp:hyperlink>
                                            </td>
										</tr>
										<tr>
											<td colspan="2" align="center" style="padding: 15px 0;">
												<asp:HyperLink ID="complaintsLink" runat="server" NavigateUrl="#" CssClass="FormDEHeader" Target="_blank">Log a Complaint</asp:HyperLink>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
						<!--END LOGIN MODULE-->
						<asp:RequiredFieldValidator id="RequiredFieldValidator1" CssClass="FormDEError" runat="server" ErrorMessage="Enter UserName"
							ControlToValidate="UserName" Display="None"></asp:RequiredFieldValidator>
						<asp:RequiredFieldValidator id="RequiredFieldValidator2" CssClass="FormDEError" runat="server" ErrorMessage="Enter Password"
							ControlToValidate="Password" Display="None"></asp:RequiredFieldValidator>
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
</HTML>
