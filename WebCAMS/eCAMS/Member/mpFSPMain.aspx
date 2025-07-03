<%@ Page Language="vb" MasterPageFile="~/mPhone.master" AutoEventWireup="false" Inherits="eCAMS.mpFSPMain" Codebehind="mpFSPMain.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div id="content">
	<ul class="pageitem">
		<li class="menu">
            <a href="mpFSPJobList.aspx">
<%--                <img alt="list" src="../thumbs/plugin.png" />--%>
		        <span class="name">Open Jobs List</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
            <a href="mpGMapViewer.aspx?svr=FJ&torefresh=<%= Date.Now.ToString("yyyMMddMMhhmmss") %>">
		        <span class="name">Jobs on Map</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
            <a href="mpFSPStockReceived.aspx">
		        <span class="name">Stock Received</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
            <a href="mpFSPStockReturned.aspx">
		        <span class="name">Stock Returned</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
            <a href="mpFSPFOB.aspx">
		        <span class="name">Faulty Out Of Box</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
            <a href="mpBulletinViewLog.aspx">
		        <span class="name">Bulletin View Log</span>
                <span class="arrow"></span>
            </a>
        </li>
<%--
		<li class="menu">
            <a href="#">
		        <span class="name">Stock Take</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
            <a href="#">
		        <span class="name">Help Documents and Videos</span>
                <span class="arrow"></span>
            </a>
        </li>
--%>
		<li class="menu">
            <a href="mpMaintainPWD.aspx">
		        <span class="name">Change Password</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
<%--            <a href="javascript:window.opener='x';window.close();">--%>
             <a href="mpLogout.aspx">
		        <span class="name">Log Out</span>
                <span class="arrow"></span>
            </a>
        </li>
	</ul>
</div>
</asp:Content>
