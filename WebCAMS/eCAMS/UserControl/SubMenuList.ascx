<%@ Control Language="VB" AutoEventWireup="false" Inherits="UserControl_SubMenuList" Codebehind="SubMenuList.ascx.vb" %>
<asp:Repeater ID="rpSubMenuList" runat="server" EnableViewState="False">
    <HeaderTemplate><ul></HeaderTemplate>
    <ItemTemplate>
        <li class="FormTitle"><asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# Eval("Url") %>' Text='<%# Eval("Title") %>'></asp:HyperLink>
                - <%# Eval("Description") %></li>
        <br>&nbsp;<br/>
    </ItemTemplate>
    <FooterTemplate></ul></FooterTemplate>
</asp:Repeater>