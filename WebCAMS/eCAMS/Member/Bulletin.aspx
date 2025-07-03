<%@ Page Title="" Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.Bulletin" Codebehind="Bulletin.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10" style="height: 16px"></TD>
			<TD style="height: 16px">
    <asp:PlaceHolder ID="placeholderBody" runat="server"></asp:PlaceHolder>
			</TD>
			<TD width="10" style="height: 16px"></TD>
		</TR>
    <asp:Panel ID="PanelButonAccept" runat="server">
		<TR>
			<TD width="10"></TD>
			<TD align="center">        
			    <asp:Button ID="btnAccept" runat="server" Text="Accept" /> &nbsp;&nbsp;&nbsp;
                <asp:Button ID="btnDecline" runat="server" Text="Decline" />
            </TD>
			<TD width="10"></TD>
		</TR>
    

    </asp:Panel>
    <asp:Panel ID="PanelButtonOK" runat="server">
		<TR>
			<TD width="10"></TD>
			<TD align="center">        
                <asp:Button ID="btnOK" runat="server" Text="OK" />
            </TD>
			<TD width="10"></TD>
		</TR>
        
    </asp:Panel>
    <asp:HiddenField ID="hdBulletinID" runat="server" />
	</TABLE>
</asp:Content>

