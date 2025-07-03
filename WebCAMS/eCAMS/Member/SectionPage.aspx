<%@ Page Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="Member_SectionPage" Codebehind="SectionPage.aspx.vb" %>

<%@ Register Src="../UserControl/SubMenuList.ascx" TagName="SubMenuList" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:SubMenuList ID="SubMenuList1" runat="server" />
</asp:Content>

