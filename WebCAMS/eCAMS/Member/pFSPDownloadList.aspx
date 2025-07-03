<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pFSPDownloadList" Codebehind="pFSPDownloadList.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <TABLE id="Table2" cellSpacing="1" cellPadding="1" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>&nbsp;
				<asp:label id="lblListInfo" runat="server" CssClass="pMemberInfo"></asp:label></TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD vAlign="top">
				<asp:datagrid id="grdJob" runat="server" CssClass="pFormGrid" AllowPaging="True" PageSize="20"
					GridLines="None" OnPageIndexChanged="grdJob_PageIndexChanged" Width="472px">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
</asp:Content>
