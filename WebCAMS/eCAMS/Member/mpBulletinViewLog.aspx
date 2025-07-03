<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpBulletinViewLog.aspx.vb" Inherits="eCAMS.mpBulletinViewLog" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
 <ul class="pageitem">
<asp:Repeater ID="Repeater1" runat="server">
    <HeaderTemplate>
    </HeaderTemplate>
    <ItemTemplate>
		<li class="store">
            <a href="mpBulletinView.aspx?BNO=<%# Eval("BulletinID") %>">
                <span class="name">
                    <%# Eval("Title") %> &nbsp;
                    <b><%# Eval("ActionTaken") %></b> &nbsp;
                    <br/><b><%# Eval("LoggedDateTime") %> </b>
                </span>
                <span class="arrow"></span>
            </a>
        </li>
    </ItemTemplate>
    <FooterTemplate>

    </FooterTemplate>
</asp:Repeater>
</ul>
</div>

</asp:Content>
