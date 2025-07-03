<%@ Page Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPCoverage" title="FSPCoverage" Codebehind="FSPCoverage.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
			<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="344" border="0">
				<TR>
					<TD colspan=3>
						<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>
					</TD>
				</TR>
			
				<TR>
					<TD width="11" height="21"></TD>
					<TD width="86" height="21">
						<asp:Label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:Label></TD>
					<TD style="HEIGHT: 26px">
						<asp:DropDownList id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:DropDownList></TD>
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
			        <TD width="11" height="21"></TD>
			        <TD width="86" height="21"><asp:label id="lblSuburb" runat="server" CssClass="FormDEHeader">Suburb</asp:label></TD>
			        <TD height="21">
				        <asp:textbox id="txtSuburb" runat="server" CssClass="FormDEField" Width="224px"></asp:textbox></TD>
		        </TR>
		        <TR>
			        <TD width="11" height="21"></TD>
			        <TD width="86" height="21"><asp:label id="Label1" runat="server" CssClass="FormDEHeader">Radius</asp:label></TD>
			        <TD height="21">
				        <asp:textbox id="txtRadius" runat="server" CssClass="FormDEField" Width="48px"></asp:textbox><asp:label id="lblSerialHint" runat="server" CssClass="FormDEHint">KM</asp:label></TD>
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

