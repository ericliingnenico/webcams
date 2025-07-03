<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPDownloadList" Codebehind="FSPDownloadList.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P>::&nbsp;&gt;&gt;&nbsp;
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"><%=infoError %></asp:label></P>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD><asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" Width="100%" OnPageIndexChanged="grdJob_PageIndexChanged"
					GridLines="None" PageSize="50" AllowPaging="True" OnSortCommand="grdJob_SortCommand" AllowSorting="True">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
</asp:Content>



