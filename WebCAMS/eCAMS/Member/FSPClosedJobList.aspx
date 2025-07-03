<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPClosedJobList" Codebehind="FSPClosedJobList.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
		        

	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>		
			<TD>
						<asp:hyperlink id="SearchAgainURL" runat="server" NavigateUrl="JobSearch.aspx" CssClass="FormDEHeader">HyperLink</asp:hyperlink>::&nbsp;&gt;&gt;&nbsp;
						<asp:label id="lblListInfo" runat="server" CssClass="FormDEHeader"></asp:label>

			</TD>
			<TD width="10"></TD>
		</TR>
	
		<TR>
			<TD width="10"></TD>
			<TD>
				<ul>
					<li>
						<asp:label id="Label3" runat="server" CssClass="FormDEHeader" text="To select all jobs, click "></asp:label><INPUT class="MemberInfo" id="btnSelectAll" onclick="return selectAllchkBulk(document);"
						type="button" value=" GO " name="btnSelectAll">
                    </li>						
					<li>
						<asp:label id="Label5" runat="server" CssClass="FormDEHeader">Bulk print the following selected jobs </asp:label><INPUT id="btnBulkPrint" type="submit" value=" GO " name="btnBulkPrint" class="FormDEButton"
							onclick="return validateBulkPrint();" runat="server">
                    </li>
					<li>
						<asp:label id="Label1" runat="server" CssClass="FormDEHeader">Download all the jobs found to an excel file </asp:label>  
                        <asp:Button ID="btnDownload" runat="server" Text=" GO " /></li>                  
				</ul>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD>
            <!-- Have to place ajax panel here, otherwise will upset bulkprint which calls Respomse.Write()-->		        
            <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>				
			        <asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" AllowPaging="True" PageSize="50"
			            OnSortCommand="grdJob_SortCommand" AllowSorting="True"
				        GridLines="None" OnPageIndexChanged="grdJob_PageIndexChanged" Width="100%">
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
    <SCRIPT language="JavaScript">
	    function validateBulkPrint() {
		    var ret=false, msg="";
		    ret = validateBulkSelection(document);
    		
		    if (! ret) {
			    msg += "Please make a bulk selection\r\n";
			    alert(msg);
		    }
		    return ret;	
	    }
    </SCRIPT>

</asp:Content>



