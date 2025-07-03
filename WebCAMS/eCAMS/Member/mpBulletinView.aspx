<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpBulletinView.aspx.vb" Inherits="eCAMS.mpBulletinView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <asp:PlaceHolder ID="placeholderBody" runat="server"></asp:PlaceHolder>
            </span>
        </li>
		<li class="menu">
   			<a class="noeffect" href="mpBulletinViewLog.aspx">
		        <span class="smallname">Back to Bulletin ViewLog</span>
                <span class="arrow"></span>
            </a>
        </li>
	</ul>
 </div>
</asp:Content>
