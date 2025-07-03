<%@ Page Language="VB" AutoEventWireup="false" Inherits="eCAMS.LoginOTP" CodeBehind="LoginOTP.aspx.vb" %>

<%@ Register Src="~/UserControl/CopyrightLabel.ascx" TagPrefix="custom" TagName="CopyrightLabel" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>OTP Validation</title>
	<meta name="vs_defaultClientScript" content="JavaScript">
	<meta name="vs_targetSchema" content="http://schemas.microsoft.com/intellisense/ie5">
    <link href="../Styles/Styles.css" type="text/css" rel="stylesheet">
    <link href="../Styles/keycorp.css" type="text/css" rel="stylesheet">
    <link href="../Images/homescreen.gif" rel="apple-touch-icon" />
    <link href="../Images/CAMS.ico" rel="SHORTCUT ICON" />
    <style type="text/css">
        .style1 {
            background-color: #F23D3C;
            height: 26px;
        }
    </style>
</head>
<body>
		<form id="Form1" method="post" runat="server">
        <table id="Table1" cellspacing="2" cellpadding="2" width="100%" border="0">
            <tr>
                <td class="header">
                    <a href="http://www.ingenico.com/">
                        <img alt="Ingenico" hspace="20" src="../images/kyc/ingenico_logo.png"
                            border="0"></a>
                </td>
            </tr>
            <tr>
                <td valign="top" class="contentborder">
                    <table cellspacing="0" cellpadding="5" width="100%" border="0">
                        <tr>
                            <td align="left" class="style1"><font face="Arial" color="white"><b class="FormHeaderWhite">Verify your One Time Code</b></font>
                            </td>
                        </tr>
                         <tr><td>
                     <br>
                                <font face="Arial"  CssClass="FormDEHeader" color="black" class="FormDEField">Passcode has been sent to your registered email.</font>
                            </td>
                        </tr>
                        <tr>
                            <td height="25" style="width: 243px">
                                <table width="270" >
                                    <tr>
                                        <td style="width: 200px; height: 32px" valign="middle">
												<asp:Label ID="lblPasscode" valign="middle" runat="server" CssClass="FormDEHeader" Width="100px">Enter Passcode</asp:Label>
                                        </td>
                                        <td valign="middle" >
                                            <input id="OneTimePassCode" type="text" size="23" name="OneTimePassCode" runat="server" class="FormDEField" align="right"
                                                style="width: 130px; height: 24px" oninput="this.value = this.value.replace(/[^0-9]/g, '')" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 88px; height: 25px" valign="middle"></td>
                                        <td align="right" valign="middle" >

                                            <asp:Button class="FormDEButton" ID="btnVerifyOTP"  ValidationGroup="GroupVerifyPasscode" runat="server"  Text="Verify" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td id="tdErrorMessageCell"  runat="server" align="center" colspan="2" style="padding-top: 5px; padding-bottom: 5px;">
                                            <asp:Label ID="lblErrorMsg" style="display: block; width: 100%; height: 100%; padding: 10px; box-sizing: border-box;" runat="server" CssClass="FormDEErrorr" Visible="False">Invalid&nbsp;passcode!</asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td  align="left">
		                                            <asp:LinkButton  ID="backToLoginURL" runat="server" CssClass="FormDEHeader" OnClick="backToLoginURLButton_Click">Back to Login</asp:LinkButton>
                                        </td>
                                        <td align="right" valign="middle">
                                            <asp:Button class="FormDEButton" ID="btnResendCode"  runat="server"  Text="Resend Passcode" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <!--END LOGIN MODULE-->
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" CssClass="FormDEError" runat="server" ErrorMessage="Enter Passcode"  ValidationGroup="GroupVerifyPasscode"
                        ControlToValidate="OneTimePassCode" Display="None"></asp:RequiredFieldValidator>
                    <asp:ValidationSummary ID="ValidationSummary1" CssClass="FormDEError" runat="server" ShowSummary="False"
                        ShowMessageBox="True"></asp:ValidationSummary>
                </td>
            </tr>
        </table>


        <table id="tblFooter" width="100%">
            <tr>
                <td class="footer" valign="top">
                    <custom:CopyrightLabel ID="CopyrightLabel1" runat="server" />
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
