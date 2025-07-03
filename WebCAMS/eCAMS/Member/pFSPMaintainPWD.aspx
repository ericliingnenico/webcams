<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pFSPMaintainPWD" Codebehind="pFSPMaintainPWD.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:label id="lblFormTitle" runat="server" CssClass="pFormTitle"></asp:label>
	<P></P>
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" border="0">
		<tr>
			<td colspan="3">
				<asp:Label id="lblFormTitle1" runat="server" CssClass="FormTitle"></asp:Label>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<asp:Label id="lblFormTitle3" runat="server" CssClass="FormTitle"></asp:Label>
			</td>
		</tr>
				<tr>
			<td colspan="3">
				<asp:Label id="lblFormTitle4" runat="server" CssClass="FormTitle"></asp:Label>
			</td>
		</tr>
				<tr>
			<td colspan="3">
				<asp:Label id="lblFormTitle5" runat="server" CssClass="FormTitle"></asp:Label>
			</td>
		</tr>
				<tr>
			<td colspan="3">
				<asp:Label id="lblFormTitle6" runat="server" CssClass="FormTitle"></asp:Label>
			</td>
		</tr>

		<TR>
			<TD width="10" height="18"></TD>
			<TD width="145" height="18"><asp:label id="Label2" runat="server" CssClass="pFormDEHeader">New Password</asp:label></TD>
			<TD height="18">
				<asp:TextBox id="txtNewPWD" runat="server" CssClass="pFormDEField" Columns="15" TextMode="Password"></asp:TextBox></TD>
		</TR>
		<TR>
			<TD width="10" height="27"></TD>
			<TD width="145" height="27"><asp:label id="Label3" runat="server" CssClass="pFormDEHeader">ReType New Password</asp:label></TD>
			<TD height="27">
				<asp:TextBox id="txtReTypeNewPWD" runat="server" CssClass="pFormDEField" Columns="15" TextMode="Password"></asp:TextBox></TD>
		</TR>
					<tr>
						<td colspan="3">
							<asp:label id="Label9" runat="server" CssClass="FormDEHint">Password must minimum 8 characters (14 characters for admin acc), at least one uppercase letter, one lowercase letter and one numbers.(NO  special character). Cannot be the same as any of the previous 12 passwords.</asp:label>
						</td>
					</tr>
		<TR>
			<TD width="10"></TD>
			<TD width="145"></TD>
			<TD align="left"><asp:button id="btnSave" runat="server" CssClass="pFormDEButton" Text="Save"></asp:button></TD>
		</TR>
	</TABLE>
	&nbsp;&nbsp;<asp:Label id="ErrMsg" runat="server" CssClass="FormDEError" Visible="False">ErrMsg</asp:Label>
		&nbsp;&nbsp;<asp:Label id="ErrMsg1" runat="server" CssClass="FormDEError" Visible="False">ErrMsg</asp:Label>
</asp:Content>
