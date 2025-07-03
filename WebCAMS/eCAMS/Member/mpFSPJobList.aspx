<%@ Page Language="vb" MasterPageFile="~/mPhone.master" AutoEventWireup="false" Inherits="eCAMS.mpFSPJobList" Codebehind="mpFSPJobList.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <panel id="panelJobList"  runat="server">
 <div class="content">
 <ul class="pageitem">
<asp:Repeater ID="Repeater1" runat="server">
    <HeaderTemplate>
    </HeaderTemplate>
    <ItemTemplate>
		<li class="store">
            <a href="mpFSPJob.aspx?id=<%# Eval("JobID") %>&p=1">
                <span class="name">
                    <%# Eval("JobID") %> &nbsp;
                    <%# Eval("JobType") %> &nbsp;
                    <%# Eval("ClientID") %> &nbsp;
                    <%# Eval("DeviceType") %> &nbsp;
                    <%# Eval("Name") %> &nbsp;
                    <%# Eval("Address") %> &nbsp;
                    <b><%# Eval("City") %></b> &nbsp;
                    <%# Eval("PhoneNumber") %> &nbsp;
                    <br/><b><%# Eval("AgentSLADateTimeLocal") %> </b>
                </span>
                <span class="<%# Eval("PhoneIcon") %>"></span>
                <span class="arrow"></span>
                <span class="<%# Eval("APM") %>"></span>
            </a>
        </li>
    </ItemTemplate>
    <FooterTemplate>

    </FooterTemplate>
</asp:Repeater>
		<li class="select">
            <asp:DropDownList ID="cboSort" runat="server" AutoPostBack="True">
                <asp:ListItem Text="Sort By" Value="" />
                <asp:ListItem Text="Sort By Due Date" Value="AgentSLADateTimeLocal" />
                <asp:ListItem Text="Sort By Suburb" Value="City" />
                <asp:ListItem Text="Sort By JobType" Value="JobType" />
                <asp:ListItem Text="Sort By DeviceType" Value="DeviceType" />
                <asp:ListItem Text="Sort By JobID" Value="JobID" />
            </asp:DropDownList>
            <span class="arrow"></span>
        </li>
</ul>

</div>
</panel>
 <asp:Label ID="lblListInfo" runat="server" Text="" class="center"></asp:Label>
</asp:Content>
