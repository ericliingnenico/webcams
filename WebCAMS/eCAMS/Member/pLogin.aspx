<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pLogin" Codebehind="pLogin.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table4" cellSpacing="1" cellPadding="1" border="0">
		<TR>
			<TD width="68">
				<asp:Label id="lblUserName" runat="server" CssClass="pFormDEHeader" Width="66px"> UserName</asp:Label></TD>
			<TD>
				<asp:textbox id="UserName" runat="server" CssClass="pFormDEField" Font-Size="Smaller" Columns="15"></asp:textbox></TD>
		</TR>
		<TR>
			<TD width="68">
				<asp:Label id="lblPassword" runat="server" CssClass="pFormDEHeader">Password</asp:Label></TD>
			<TD>
				<asp:TextBox id="Password" runat="server" CssClass="pFormDEField" Font-Size="Smaller" Columns="15"
					TextMode="Password"></asp:TextBox></TD>
		</TR>
		<TR>
			<TD width="68"></TD>
			<TD><INPUT class="pFormDEButton" id="btnSingIn" style="WIDTH: 56px; HEIGHT: 29px" type="submit"
					value="Login" name="btnSingIn" runat="server"></TD>
		</TR>
	</TABLE>
	<P></P>
	<P>
		<asp:Label id="lblErrorMsg" runat="server" CssClass="FormDEErrorr" Visible="False">Invalid&nbsp;UserName or Password!</asp:Label></P>
  </asp:Content>
