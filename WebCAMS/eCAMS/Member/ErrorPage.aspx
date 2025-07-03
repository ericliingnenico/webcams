<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.ErrorPage" Codebehind="ErrorPage.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P class="MemberInfo"><asp:hyperlink id="BackURL" runat="server" CssClass="MemberInfo" NavigateUrl="Member.aspx">HyperLink</asp:hyperlink>::&nbsp;&gt;&gt;&nbsp;An error has occurred</P>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD>
				<asp:label id="lblErrorInfo" runat="server" CssClass="FormDEError"></asp:label></TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
</asp:Content>



