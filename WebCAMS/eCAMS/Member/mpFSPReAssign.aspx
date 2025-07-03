<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpFSPReAssign.aspx.vb" Inherits="eCAMS.mpFSPReAssign" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:HiddenField ID="txtJobID" runat="server" />
 <div class="content">
	<ul class="pageitem">
    <ASP:PlaceHolder runat="server" id="placeholderErrorMsg"></ASP:PlaceHolder>
        <li class="textbox">
            <span class="name">
                <p>Assign Job [<asp:Label ID="lblJobDetails" runat="server" Text=""></asp:Label>] To:</p>
            </span>
        </li>
        <li class="textbox">
            <p>
            <span class="select">
                <asp:dropdownlist id="cboAssignedTo" runat="server"></asp:dropdownlist>
                <span class="arrow"></span>
            </span>
            </p>
        </li>
        <asp:Repeater ID="RepeaterDevice" runat="server">
            <ItemTemplate>
                <li class="textbox">
                    <p><b><%# Eval("EquipmentType") %>&nbsp;<%# Eval("InOut") %></b>&nbsp;&nbsp;
                        <%# Eval("Serial") %></p>
                    <p>
                        <b><%# Eval("EquipmentType") %>:</b> &nbsp;<%# Eval("MMD") %></p>
                 </li>
            </ItemTemplate>
        </asp:Repeater>
        <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnReAssign" runat="server" Text="Submit" />
            </p>
            </span>
        </li>
        
    </ul>
 </div>
</asp:Content>
