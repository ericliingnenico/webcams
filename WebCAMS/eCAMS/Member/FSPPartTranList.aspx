<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPPartTranList" Codebehind="FSPPartTranList.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P class="MemberInfo">
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"></asp:label></P>
			</TD>
			<TD width="10"></TD>
		</TR>
       <asp:Panel ID="Panel1" runat="server" DefaultButton="btnSave">
		<TR>
			<TD width="10"></TD>
			<TD><asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" AllowSorting="True" Width="100%"
					OnSortCommand="grdJob_SortCommand" OnPageIndexChanged="grdJob_PageIndexChanged" GridLines="None"
					PageSize="50" AllowPaging="True">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD align="right">
                <asp:Button ID="btnSave" CssClass="FormDEButton" runat="server" Text="Save Parts Received" OnClientClick="return validatePartTran();"/>
			</TD>
			<TD width="10"></TD>
		</TR>
      </asp:Panel>
	</TABLE>
<SCRIPT language="JavaScript">
	function validatePartTran() {
		//debugger
		var ret=false, msg="";
		ret = validateBulkSelection(document);
		
		if (! ret) {
			msg += "Please make a receipt acknowledgement selection. Aborted\r\n";
			alert(msg);
		}
		else
		{ 
			ret = validateQty(document);
			if (! ret) {
				msg += "Invalid ReceivedQty entered. Aborted\r\n";
				alert(msg);
			}
		}	
		return ret;	
				
	}
	
	function validateQty(pDocument) {
	    //debugger;
		var i;
		var txtQty;
		//debugger;
		//go through each tran and validate Qty

		var chk = getDocumentAll(pDocument, "chkBulk"); 
		//alert (chk.length);
        //go through each check box
	    for (i=0; i<chk.length; i++) {
		    if (chk[i].checked) {
				txtQty = "txtQtyReceived" + chk[i].value;
		        if (!isPositiveIntegerOrZero(pDocument.getElementById(txtQty).value))  //return null in firefox, don't know why
		        	return false;
		    }
	    }
		
//		if (pDocument.all("chkBulk")) {
//		    //single row of check box
//		    if (pDocument.all("chkBulk").length == undefined) {
//	    		txtQty = "txtQtyReceived" + pDocument.all("chkBulk").value;
//		        return isPositiveIntegerOrZero(pDocument.all(txtQty).value);
//		    }

//		    //multiple rows of check box
//			for (i=0; i<pDocument.all("chkBulk").length; i++) {
//				if (pDocument.all("chkBulk")[i].checked) {
//					txtQty = "txtQtyReceived" + pDocument.all("chkBulk")[i].value;
//			        if (!isPositiveIntegerOrZero(pDocument.all(txtQty).value))
//						return false;
//				}
//			}
//		    
//		}
		
		return true; 
	}
</SCRIPT>
</asp:Content>



