<%@ Page Title="" Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.BulletinViewLog" Codebehind="BulletinViewLog.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:datagrid id="grdLog" runat="server" CssClass="FormGrid" Width="100%" 
                            AllowPaging="True" PageSize="50"
					            GridLines="None" OnPageIndexChanged="grdLog_PageIndexChanged" OnSortCommand="grdLog_SortCommand"
					            AllowSorting="True">
        <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
        <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
        <PagerStyle Position="TopAndBottom" Mode="NumericPages" 
                                    CssClass="FormGridPagerCell"></PagerStyle>
    </asp:datagrid>
</asp:Content>

