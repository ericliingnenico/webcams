<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpBulletin.aspx.vb" Inherits="eCAMS.mpBulletin" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:HiddenField ID="hdBulletinID" runat="server" />
 <div class="content">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
    <ASP:PlaceHolder runat="server" id="placeholderBody"></ASP:PlaceHolder>
            </span>
        </li>
    <asp:Panel ID="PanelButonAccept" runat="server">
        <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnAccept" runat="server" Text="Accept" />
            </p>
            </span>
        </li>
        <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnDecline" runat="server" Text="Decline" />
            </p>
            </span>
        </li>
    </asp:Panel>    
    <asp:Panel ID="PanelButtonOK" runat="server">
        <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnOK" runat="server" Text="OK" />
            </p>
            </span>
        </li>
    </asp:Panel>    
    </ul>
 </div>

</asp:Content>
