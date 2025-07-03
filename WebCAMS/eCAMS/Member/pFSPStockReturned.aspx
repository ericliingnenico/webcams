<%@ Page Language="vb" MasterPageFile="~/pFSP.master" AutoEventWireup="false" Inherits="eCAMS.pFSPStockReturned" Codebehind="pFSPStockReturned.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:label id="lblFormTitle" runat="server" CssClass="pFormTitle"></asp:label><asp:panel id="panelEdit" runat="server" Width="792px">
		<TABLE id="Table2" height="100%" cellSpacing="1" cellPadding="1" width="248" border="0">
			<TR>
				<TD>
					<asp:label id="lblDepot" runat="server" CssClass="pformdeheader">From</asp:label></TD>
				<TD>
					<asp:dropdownlist id="cboFromLocation" runat="server" CssClass="pFormDEField" Font-Size="Smaller"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD>
					<asp:label id="Label1" runat="server" CssClass="pformdeheader">To</asp:label></TD>
				<TD>
					<asp:dropdownlist id="cboToLocation" runat="server" CssClass="pFormDEField" Font-Size="Smaller"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD>
					<asp:label id="Label2" runat="server" CssClass="pFormDEHeader">Date</asp:label></TD>
				<TD>
					<asp:textbox id="txtDateReturned" runat="server" CssClass="pFormDEField" Font-Size="Smaller"></asp:textbox></TD>
			</TR>
			<TR>
				<TD>
					<asp:label id="Label3" runat="server" CssClass="pFormDEHeader">ConNote</asp:label></TD>
				<TD>
					<asp:textbox id="txtReferenceNo" runat="server" CssClass="pFormDEField" Font-Size="Smaller"></asp:textbox></TD>
			</TR>
			<TR>
				<TD>
					<asp:label id="Label4" runat="server" CssClass="pFormDEHeader">Notes</asp:label><BR>
				</TD>
				<TD>
					<asp:textbox id="txtNote" runat="server" CssClass="pFormDEField" TextMode="MultiLine" Font-Size="Smaller"></asp:textbox></TD>
			</TR>
			<TR>
				<TD></TD>
				<TD align="right" height="10"><INPUT class="pFormDEButton" id="btnSave" onclick="if (!validateDate(txtDateReturned.value)) {alert('Invalid date'); txtDateReturned.focus(); return false;} else {if (txtReferenceNo.value.length==0) {alert('Enter ConNote');txtReferenceNo.focus();return false;} else {return true;}}"
						type="submit" value="Save" name="btnSave" runat="server"></TD>
			</TR>
		</TABLE>
	</asp:panel><asp:panel id="panelScan" runat="server" Width="800px" DESIGNTIMEDRAGDROP="388">
		<TABLE id="tableScan" height="266" cellSpacing="1" cellPadding="1" width="248" border="0">
			<TR>
				<TD height="26">
					<P class="MemberInfo" id="P1" runat="server">
						<asp:label id="lblListInfo1" runat="server" CssClass="pMemberInfo"></asp:label></P>
				</TD>
			</TR>
			<TR>
				<TD>
					<asp:textbox id="txtSerial" runat="server" CssClass="pFormDEField"></asp:textbox>
					<asp:textbox id="txtBatchID" runat="server" visible="False"></asp:textbox>&nbsp;&nbsp;<INPUT class="pFormDEButton" id="btnSaveSerial" onclick="if (txtSerial.value.length==0) {alert('Enter serial'); txtSerial.focus();return false;} else {return true;}" type="submit"
						value="Save" name="btnSaveSerial" runat="server"></TD>
			</TR>
			<TR>
				<TD>
					<P class="pMemberInfo">
					                To obtain an Excel file, click <A HREF='../member/pFSPStockReturned.aspx?sv=download&id=<%=m_BatchID %>'>Download</A> before closing the batch
                                    <br>To close the batch, click <A HREF='../member/pFSPStockReturned.aspx?sv=close&id=<%=m_BatchID %>&box=1'>Close</A>
                                    <br>Device scanned list:
				</TD>
			</TR>
			<TR>
				<TD>
					<asp:datagrid id="grdDevice" runat="server" CssClass="pFormGrid">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
			</TR>
		</TABLE>
	</asp:panel><asp:panel id="panelAcknowledge" runat="server">
		<asp:label id="lblAcknowledge" runat="server" CssClass="pFormTitle"></asp:label>
	</asp:panel></form>
</TD></TR></TBODY></TABLE>
</asp:Content>

