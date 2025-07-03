<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPCJFPreJob" Codebehind="FSPCJFPreJob.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<asp:Panel id="PanelGrid" runat="server">
		<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
			<TR>
				<TD width="10"></TD>
				<TD>&nbsp;
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"></asp:label><BR>
					&nbsp;&nbsp;•
					<asp:label id="Label1" runat="server" CssClass="MemberInfo" text="To select all billable jobs, click "></asp:label><INPUT class="MemberInfo" id="btnSelectAll" onclick="return selectAllchkBulk(document);"
						type="button" value="Go" name="btnSelectAll"><BR>
					&nbsp;&nbsp;•
					<asp:label id="Label2" runat="server" CssClass="MemberInfo" text="To generate a CJF file on jobs selected as below, click "></asp:label><INPUT class="MemberInfo" id="btnGenerateCJF" onclick="return validateCJF();" type="submit"
						value="Go" name="btnGenerateCJF" runat="server">
				</TD>
				<TD width="10"></TD>
			</TR>
			<TR>
				<TD width="10"></TD>
				<TD>
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>			        
					        <asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" AllowSorting="True" Width="100%"
						        OnSortCommand="grdJob_SortCommand" OnPageIndexChanged="grdJob_PageIndexChanged" GridLines="None"
						        PageSize="50" AllowPaging="True">
					            <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					            <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					            <PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
					        </asp:datagrid>
                        </ContentTemplate>
                        <Triggers>
                        </Triggers>
                    </asp:UpdatePanel>	
				</TD>
				<TD width="10"></TD>
			</TR>
		</TABLE>
	</asp:Panel>
	<asp:Panel id="PanelResult" runat="server">
		<TABLE id="Table3" cellSpacing="1" cellPadding="1" width="100%" border="0">
			<TR>
				<TD width="10"></TD>
				<TD>
					<asp:label id="lblAcknowledge" runat="server" CssClass="MemberInfo"></asp:label></TD>
				<TD width="10"></TD>
			</TR>
		</TABLE>
	</asp:Panel>

<SCRIPT language="JavaScript">
	function validateCJF() {
		var ret=false, msg="";
		ret = validateBulkSelection(document);
		
		if (! ret) {
			msg += "Please make a bulk selection. Aborted\r\n";
			alert(msg);
		}
			
		return ret;	
		
	}
</SCRIPT>

</asp:Content>

