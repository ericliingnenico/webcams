<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.TerminalSearch" Codebehind="TerminalSearch.aspx.vb" %>
		<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
					<TABLE id="Table2" style="WIDTH: 344px; HEIGHT: 140px" cellSpacing="1" cellPadding="1"
						width="344" border="0">
						<TR>
							<TD colspan=3>
								<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
							</TD>
						
						<TR>
							<TD style="WIDTH: 11px; HEIGHT: 26px"></TD>
							<TD style="WIDTH: 86px; HEIGHT: 26px">
								<asp:Label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:Label></TD>
							<TD style="HEIGHT: 26px">
								<asp:DropDownList id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:DropDownList></TD>
						</TR>
						<TR>
							<TD style="WIDTH: 11px; HEIGHT: 21px"></TD>
							<TD style="WIDTH: 86px; HEIGHT: 21px">
								<asp:Label id="lblState" runat="server" CssClass="FormDEHeader">Terminal ID</asp:Label></TD>
							<TD style="HEIGHT: 21px">
								<asp:TextBox id="txtTerminalID" runat="server" CssClass="FormDEField"></asp:TextBox></TD>
						</TR>
						<TR>
							<TD style="WIDTH: 11px; HEIGHT: 16px"></TD>
							<TD style="WIDTH: 86px; HEIGHT: 16px">
								<asp:Label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:Label></TD>
							<TD style="HEIGHT: 16px">
								<asp:DropDownList id="cboPageSize" runat="server" CssClass="FormDEField">
									<asp:ListItem Value="20" Selected="True">20</asp:ListItem>
									<asp:ListItem Value="40">40</asp:ListItem>
									<asp:ListItem Value="50">50</asp:ListItem>
									<asp:ListItem Value="60">60</asp:ListItem>
									<asp:ListItem Value="80">80</asp:ListItem>
									<asp:ListItem Value="100">100</asp:ListItem>
								</asp:DropDownList>
								<asp:Label id="Label1" runat="server" CssClass="FormDEInfo">records per page</asp:Label></TD>
						</TR>
						<TR>
							<TD style="WIDTH: 11px; HEIGHT: 17px"></TD>
							<TD style="WIDTH: 86px; HEIGHT: 17px"></TD>
							<TD style="HEIGHT: 17px" align="right"></TD>
						</TR>
						<TR>
							<TD style="WIDTH: 11px; HEIGHT: 10px"></TD>
							<TD style="WIDTH: 86px; HEIGHT: 10px"></TD>
							<TD style="HEIGHT: 10px" align="right">
                                &nbsp;<INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " runat="server"></TD>
						</TR>
						<TR>
							<TD style="WIDTH: 11px"></TD>
							<TD style="WIDTH: 86px"></TD>
							<TD align="right"></TD>
						</TR>
					</TABLE>
				<asp:RequiredFieldValidator id="RequiredFieldValidator1" runat="server" CssClass="FormDEErrorr" ErrorMessage="Enter TerminalID"
					ControlToValidate="txtTerminalID" Display="None"></asp:RequiredFieldValidator>
				<asp:ValidationSummary id="ValidationSummary1" runat="server" CssClass="FormDEErrorr" ShowMessageBox="True"
					ShowSummary="False"></asp:ValidationSummary>
		</asp:Content>



