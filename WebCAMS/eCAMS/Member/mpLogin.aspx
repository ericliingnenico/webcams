<%@ Page Language="vb" MasterPageFile="~/mPhone.master" AutoEventWireup="false" Inherits="eCAMS.mpLogin" Codebehind="mpLogin.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <ul class="pageitem">
        <li class="smallfield">
            <span class="name">UserName:</span><asp:textbox id="UserName" runat="server" placeholder="enter here"></asp:textbox>
        </li>
        <li class="smallfield">
            <span class="name">Password:</span><asp:TextBox id="Password" runat="server" TextMode="Password" placeholder="enter here"></asp:TextBox>
        </li>
        <li class="checkbox">
            <span class="name">Remember Me:</span><asp:checkbox id="chkRememberPassword" runat="server"></asp:checkbox>
        </li>
        <li class="button">
            <INPUT id="btnSingIn"  type="submit" value="Login" name="btnSingIn" runat="server"> 
        </li>
    </ul>
        <asp:Label id="lblErrorMsg" runat="server" Visible="False" ForeColor="Red">Invalid UserName or Password!</asp:Label>		
</asp:Content>
