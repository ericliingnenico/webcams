<%@ Control Language="VB" AutoEventWireup="false" Inherits="UserControl_UserPasswordAlert" Codebehind="UserPasswordAlert.ascx.vb" %>
				<asp:label id="lblListInfo1" runat="server" CssClass="MemberInfoAlert" Text="Previous Password Change: {0}"></asp:label><br />
				<asp:label id="lblListInfo2" runat="server" CssClass="MemberInfoAlert" Text="Please click <A HREF='../member/MaintainPWD.aspx'>here</A> to set a new password"></asp:label><br />
				<asp:label id="lblListInfo3" runat="server" CssClass="MemberInfoAlert" Text="You need to notify the FSP about the password change if the PocketCAMS is used by this FSP."></asp:label>
