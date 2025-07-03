<%@ Page Language="vb" MasterPageFile="~/MemberPopupMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.PopupPropertyGrid" Codebehind="PopupPropertyGrid.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P class="MemberInfo">&nbsp;
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"></asp:label></P>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD><asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" ShowHeader="False" AllowPaging="True"
					PageSize="50" GridLines="None" OnPageIndexChanged="grdJob_PageIndexChanged" Width="100%">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
</asp:Content>
