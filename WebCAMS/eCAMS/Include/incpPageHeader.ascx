<%@ Control Language="vb" AutoEventWireup="false" Inherits="eCAMS.incpPageHeader" Codebehind="incpPageHeader.ascx.vb" %>
<TABLE id="Table1" style="WIDTH: 312px; HEIGHT: 39px" cellSpacing="0" cellPadding="0" width="312"
	border="0">
	<TR>
		<TD style="WIDTH: 111px; HEIGHT: 49px" align="left"><IMG src="/eCams/Images/LogoKYCPDA.PNG">
		</TD>
		<TD style="HEIGHT: 49px" width="5">&nbsp;</TD>
		<TD style="WIDTH: 1044px; HEIGHT: 49px" vAlign="top"><asp:label id="lblLoginInfo" runat="server" CssClass="PageHeaderSmall"></asp:label>
			<asp:panel id="pnlMenu" runat="server" Width="187px">
<asp:hyperlink id="hlnkHome" CssClass="PageHeaderSmall" runat="server" NavigateUrl="../member/pFSPMain.aspx">Home</asp:hyperlink>&nbsp;&nbsp;|&nbsp;&nbsp; 
<asp:hyperlink id="hlnkLogout" CssClass="PageHeaderSmall" runat="server" NavigateUrl="../member/Logout.aspx">Logout</asp:hyperlink></asp:panel></TD>
	</TR>
	<TR>
		<TD vAlign="middle" bgColor="#003399" colSpan="3" height="2"></TD>
	</TR>
</TABLE>
