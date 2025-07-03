<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.JobSearch" Codebehind="JobSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
			<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="344" border="0">
				<TR>
					<TD colspan=3>
						<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>
					</TD>
				</TR>
			
				<TR>
					<TD width="11" height="26"></TD>
					<TD width="86" height="26">
						<asp:Label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:Label></TD>
					<TD height="26">
						<asp:DropDownList id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:DropDownList></TD>
				</TR>
				<TR>
					<TD width="11" height="21"></TD>
					<TD width="86" height="21">
						<asp:Label id="Label2" runat="server" CssClass="FormDEHeader">Status</asp:Label></TD>
					<TD height="21">
                        <asp:DropDownList id="cboStatus" runat="server" CssClass="FormDEField">
						</asp:DropDownList>

                    </TD>
				</TR>
				
				<TR>
					<TD width="11" height="21"></TD>
					<TD width="86" height="21">
						<asp:Label id="lblState" runat="server" CssClass="FormDEHeader">State</asp:Label></TD>
					<TD height="21">
                        <asp:DropDownList id="cboState" runat="server" CssClass="FormDEField">
						</asp:DropDownList>

                    </TD>
				</TR>
				<TR>
					<TD width="11" height="16"></TD>
					<TD width="86" height="16">
						<asp:Label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:Label></TD>
					<TD height="16">
						<asp:DropDownList id="cboPageSize" runat="server" CssClass="FormDEField">
							<asp:ListItem Value="20" Selected="True">20</asp:ListItem>
							<asp:ListItem Value="40">40</asp:ListItem>
							<asp:ListItem Value="50">50</asp:ListItem>
							<asp:ListItem Value="60">60</asp:ListItem>
							<asp:ListItem Value="80">80</asp:ListItem>
							<asp:ListItem Value="100">100</asp:ListItem>
						</asp:DropDownList>&nbsp;
						<asp:Label id="Label1" runat="server" CssClass="FormDEInfo">records per page</asp:Label></TD>
				</TR>
				<TR>
					<TD width="11" height="17"></TD>
					<TD width="86" height="17"></TD>
					<TD align="right" height="17"></TD>
				</TR>
				<TR>
					<TD width="11" height="10"></TD>
					<TD width="86" height="10"></TD>
					<TD align="right" height="10">
						<INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " runat="server"></TD>
				</TR>
				<TR>
					<TD width="11"></TD>
					<TD width="86"></TD>
					<TD align="right"></TD>
				</TR>
			</TABLE>
</asp:Content>



