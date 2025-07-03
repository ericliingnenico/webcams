<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPStockList" Codebehind="FSPStockList.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P class="MemberInfo"><asp:hyperlink id="SearchAgainURL" runat="server" NavigateUrl="JobSearch.aspx" CssClass="MemberInfo">HyperLink</asp:hyperlink>::&nbsp;&gt;&gt;&nbsp;
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"></asp:label>
					&nbsp;&nbsp;To obtain an Excel file of all devices, click <asp:LinkButton id="lbDownload" runat="server" CssClass="MemberInfo">Download</asp:LinkButton></P>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD><asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" AllowPaging="True" PageSize="50"
					GridLines="None" OnPageIndexChanged="grdJob_PageIndexChanged" OnSortCommand="grdJob_SortCommand"
					Width="100%" AllowSorting="True">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
</asp:Content>



