<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pFSPMain" Codebehind="pFSPMain.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
				<P>
					<asp:HyperLink id="hlnkOpenJobs" runat="server" CssClass="pFormTitle" NavigateUrl="pFSPJobSearch.aspx">Open Jobs</asp:HyperLink>
				</P>
				<P>
					<asp:HyperLink id="Hyperlink2" runat="server" CssClass="pFormTitle" NavigateUrl="pFSPTaskSearch.aspx">Open Tasks</asp:HyperLink>
				</P>
				<P>
					<asp:HyperLink id="Hyperlink3" runat="server" CssClass="pFormTitle" NavigateUrl="pFSPStockReturned.aspx">Stock Returned</asp:HyperLink>
				</P>
				<P>
					<asp:HyperLink id="HyperLink1" runat="server" CssClass="pFormTitle" NavigateUrl="pFSPDownloadList.aspx">Downloads</asp:HyperLink></P>
				<P>
					<asp:HyperLink id="hlnkChangePassword" runat="server" CssClass="pFormTitle" NavigateUrl="pFSPMaintainPWD.aspx">Change Password</asp:HyperLink></P>
</asp:Content>
