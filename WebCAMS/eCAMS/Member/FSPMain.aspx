<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPMain" Codebehind="FSPMain.aspx.vb" %>

<%@ Register Src="../UserControl/UserPasswordAlert.ascx" TagName="UserPasswordAlert"
    TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD class="PageHeader">
				<P><B>Welcome to CAMS Web Portal </B>
				</P>
				<uc1:UserPasswordAlert ID="UserPasswordAlert1" runat="server" />
				<P><STRONG>You have:</STRONG></P> <!-- "#6699cc", #669900 -->
				<UL>
					<LI>
						<B>
								<asp:HyperLink id="hlSwapJob" runat="server" CssClass="FormDEHeader">Swap Jobs</asp:HyperLink></B><BR>
					<LI>
						<B>
								<asp:HyperLink id="hlInstallJob" runat="server" CssClass="FormDEHeader">Installation Jobs</asp:HyperLink></B><br>
					<LI>
						<B>
								<asp:HyperLink id="hlDeinstallJob" runat="server" CssClass="FormDEHeader">Deinstallation Jobs</asp:HyperLink></B><BR>
					<LI>
						<B>
								<asp:HyperLink id="hlUpgradeJob" runat="server" CssClass="FormDEHeader">Upgrade Jobs</asp:HyperLink></B><BR>
					<LI>
						<B>
								<asp:HyperLink id="hlPickPackTask" runat="server" CssClass="FormDEHeader">PickPack Tasks</asp:HyperLink></B><BR>
					<LI>
						<B>
								<asp:HyperLink id="hlStockInTransit" runat="server" CssClass="FormDEHeader">Stock In-Transit</asp:HyperLink></B><BR>
					<LI>
						<B>
								<asp:HyperLink id="hlFSPException" runat="server" CssClass="FormDEHeader">Job Exception</asp:HyperLink></B><BR>
					</LI>
					<li>
					    <b>
					            <asp:HyperLink ID="hlStockReturned" runat="server" CssClass="FormDEHeader">Stock to be Returned</asp:HyperLink>
					    </b>
					</li>
                    <asp:Panel ID = "panelStockTake" runat = "server" >
					<li>
					    <b>
					            <asp:HyperLink ID="hlStockTake" runat="server" CssClass="FormDEHeader">StockTake due on </asp:HyperLink>
					    </b>
					</li>
                    </asp:Panel>
				</UL>
				<P>&nbsp;</P>
				<P>&nbsp;</P>
			</TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
</asp:Content>



