<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpFSPDownloadList.aspx.vb" Inherits="eCAMS.mpFSPDownloadList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
 <ul class="pageitem">
<asp:Repeater ID="Repeater1" runat="server">
    <HeaderTemplate>
    </HeaderTemplate>
    <ItemTemplate>
		<li class="store">
            <a href="mpFSPDownload.aspx?DLID=<%# Eval("Seq") %>">
                <span class="name">
                    <b><%# Eval("Description") %></b> &nbsp;
                    <br />
                    <%# Eval("FileType") %> &nbsp;&nbsp;
                    <%# Eval("FileSize") %> &nbsp;&nbsp;
                    <%# Eval("EffectiveDate") %> 
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
