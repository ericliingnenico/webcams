<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpFSPDownloadSearch.aspx.vb" Inherits="eCAMS.mpFSPDownloadSearch" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                Download Category
            </span>
        </li>
        <li class="textbox">
            <p>
            <span class="select">
                <asp:dropdownlist id="cboDownloadCategory" runat="server"></asp:dropdownlist>
                <span class="arrow"></span>
            </span>
            </p>
        </li>
        <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnSearch" runat="server" Text="Search" />
            </p>
            </span>
        </li>
        
    </ul>
 </div>

</asp:Content>
