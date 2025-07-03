<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPPartInventory" Codebehind="FSPPartInventory.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P class="MemberInfo"><asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"></asp:label></P>
			</TD>
			<TD width="10"></TD>
		</TR>
      <asp:Panel ID="Panel1" runat="server" DefaultButton="btnSave">
		<TR>
			<TD width="10"></TD>
			<TD>
				<asp:label id="lblUserPrompt" runat="server" CssClass="FormMandatory">
			</asp:label></TD>
		</TR>

		<TR>
			<TD width="10"></TD>
			<TD><asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" AllowPaging="True" PageSize="50"
					GridLines="None" OnPageIndexChanged="grdJob_PageIndexChanged" OnSortCommand="grdJob_SortCommand"
					Width="100%" AllowSorting="True">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD align="right">
                <asp:Button ID="btnSave" CssClass="FormDEButton" runat="server" Text="Submit" onClientClick="return validateQty(document);"/>
			</TD>
			<TD width="10"></TD>
		</TR>
      </asp:Panel>
	</TABLE>
<SCRIPT language="JavaScript">
	function validateQty(pDocument) {
		var i, ret=true;
		//debugger;
		//go through each tran and validate Qty
		var txt = getDocumentAll(pDocument, "txtQtyOnHand"); 
		//alert (chk.length);
        //go through each check box
	    for (i=0; i<txt.length; i++) {
		    ret = isPositiveIntegerOrZero(txt[i].value);
            if (! ret)
                break;
	    }

//		if (pDocument.all("txtQtyOnHand")) {
//		    if (pDocument.all("txtQtyOnHand").length == undefined) {
//		        //single row
//		        ret = isPositiveIntegerOrZero(pDocument.all("txtQtyOnHand").value);
//		    }
//		    else
//		    {
//		        //multiple rows 
//			    for (i=0; i<pDocument.all("txtQtyOnHand").length; i++) {
//			        ret = isPositiveIntegerOrZero(pDocument.all("txtQtyOnHand")[i].value);
//			        if (! ret)
//			            break;
//			    }
//			}
//		}
		
		if (!ret) alert("Invalid quantity entered. Aborted.");
		return ret; 
	}
</SCRIPT>
</asp:Content>



