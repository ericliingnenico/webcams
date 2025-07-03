<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpLogout.aspx.vb" Inherits="eCAMS.mpLogout" %>

<%@ Register Src="~/UserControl/CopyrightLabel.ascx" TagPrefix="custom" TagName="CopyrightLabel" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div id="content">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
            <br />
            <p>
                Thankyou for using <b>PocketCAMS</b>
            </p>
            <br/>
            <p>
                <custom:CopyrightLabel ID="CopyrightLabel1" runat="server" />
            </p>
            </span>
         </li>        
    </ul>
  </div>
</asp:Content>
