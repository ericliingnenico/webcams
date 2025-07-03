<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pFSPTask" Codebehind="pFSPTask.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:label id="lblFormTitle" runat="server" CssClass="pFormTitle"></asp:label><asp:hyperlink id="SearchAgainURL" runat="server" CssClass="pMemberInfo" NavigateUrl="pFSPTaskList.aspx"
		Width="152px"> &lt&lt Back</asp:hyperlink>
	<asp:panel id="panelDetail" runat="server" Height="264px">&nbsp;&nbsp;
<asp:Label id="ErrMsg" runat="server" CssClass="FormDEError" Visible="False">ErrMsg</asp:Label> 

<TABLE id="Table1" style="WIDTH: 248px; HEIGHT: 265px" cellSpacing="1" cellPadding="1"
			width="248" border="0">
			<TR>
				<TD width="1" height="20"></TD>
				<TD width="45" height="20">
					<asp:label id="Label2" runat="server" CssClass="pformdeheader">Serial</asp:label></TD>
				<TD height="20">
					<asp:textbox id="txtSerial" runat="server" CssClass="pFormDEField" Font-Size="Smaller"></asp:textbox>
					<asp:textbox id="txtTaskID" runat="server" Width="52px" visible="False"></asp:textbox><INPUT class="pFormDEButton" id="btnSave" type="submit" value="Save SerialNo" name="btnSave"
						runat="server"></TD>
			</TR>
			<TR>
				<TD width="1" height="26"></TD>
				<TD width="45" height="26">
					<asp:label id="lblAssignedTo" runat="server" CssClass="pformdeheader">Carrier</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboCarrier" runat="server" CssClass="pFormDEField" Width="184px" Font-Size="Smaller"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="1" height="24"></TD>
				<TD width="45" height="24">
					<asp:label id="Label3" runat="server" CssClass="pformdeheader">ConNote No.</asp:label></TD>
				<TD height="24">
					<asp:textbox id="txtConNoteNo" runat="server" CssClass="pFormDEField" Font-Size="Smaller"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="1" height="26"></TD>
				<TD width="45" height="26">
					<asp:label id="Label1" runat="server" CssClass="pformdeheader">Comments</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtCloseComment" runat="server" CssClass="pFormDEField" Width="176px" Height="32px"
						Font-Size="Smaller" Columns="25" ReadOnly="True" Rows="2" TextMode="MultiLine"></asp:textbox><INPUT class="pFormDEButton" id="btnCloseTask" type="submit" value="Close Task" name="btnCloseTask"
						runat="server"></TD>
			</TR>
			<TR>
				<TD width="1" height="26"></TD>
				<TD width="45" height="26">
					<asp:label id="Label4" runat="server" CssClass="pformdeheader">Details</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtTaskDetails" runat="server" CssClass="pFormDEField" Width="224px" Height="72px"
						Font-Size="Smaller" Columns="25" ReadOnly="True" Rows="4" TextMode="MultiLine"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="1" height="140"></TD>
				<TD width="45" height="140">
					<asp:label id="Label5" runat="server" CssClass="pFormDEHeader">Equipment</asp:label></TD>
				<TD align="left" height="140">
					<asp:datagrid id="grdDevice" runat="server" CssClass="pFormGrid" Height="80px">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
			</TR>
			<TR>
				<TD width="1" height="10"></TD>
				<TD width="45" height="10"></TD>
				<TD align="left" height="10"></TD>
			</TR>
		</TABLE>
	</asp:panel><asp:panel id="panelException" runat="server" visible="false">
		<TABLE id="Table2" style="WIDTH: 248px; cellSpacing: " cellPadding="1" width="248" border="0">
			<TR>
				<TD colSpan="3">
					<asp:Label id="lblErrorMsg" runat="server" CssClass="FormDEError" Visible="True">No matching device found</asp:Label></TD>
			</TR>
			<asp:panel id="panelSelectDevice" runat="server" visible="false">
				<TR>
					<TD width="1" height="26"></TD>
					<TD width="45" height="26">
						<asp:label id="Label6" runat="server" CssClass="pformdeheader">Device</asp:label></TD>
					<TD height="26">
						<asp:dropdownlist id="cboDevice" runat="server" CssClass="pFormDEField" Width="240px"></asp:dropdownlist></TD>
				</TR>
				<TR>
					<TD width="1" height="10"></TD>
					<TD width="45" height="10"></TD>
					<TD align="right" height="10"><INPUT class="pFormDEButton" id="btnSaveDevice" type="submit" value="Save" name="btnSave"
							runat="server">
					</TD>
				</TR>
			</asp:panel>
			<TR>
				<TD width="1"></TD>
				<TD width="45"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>
	</asp:panel>
  </asp:Content>
