<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.SiteEquipmentList" Codebehind="SiteEquipmentList.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
    <ContentTemplate>			        

	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P class="MemberInfo">
					<asp:HyperLink id="SearchAgainURL" runat="server" NavigateUrl="JobSearch.aspx" CssClass="MemberInfo">HyperLink</asp:HyperLink>::&nbsp;&gt;&gt;&nbsp;
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"></asp:label></P>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD>
				<asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" Width="100%" AllowPaging="True" PageSize="50"
					GridLines="None" OnPageIndexChanged="grdJob_PageIndexChanged"
					 OnSortCommand="grdJob_SortCommand" AllowSorting="True">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
    </ContentTemplate>
    <Triggers>
    </Triggers>
</asp:UpdatePanel>	
</asp:Content>



