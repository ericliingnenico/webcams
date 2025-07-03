<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.Master" CodeBehind="FSPDelegationList.aspx.vb" Inherits="eCAMS.FSPDelegationList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P>::&nbsp;&gt;&gt;&nbsp;
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"><%=infoError %></asp:label></P>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD>
                <asp:textbox id="txtFromDate" runat="server" CssClass="FormDEField" Width="60px"></asp:textbox>
                <asp:label id="Label18" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label>
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" OnClientClick ="SetDelegationValidator();"/>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD><asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" Width="100%" OnPageIndexChanged="grdJob_PageIndexChanged"
					GridLines="None" PageSize="50" AllowPaging="True" OnSortCommand="grdJob_SortCommand" AllowSorting="True">
					<AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					<HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					<PagerStyle Position="TopAndBottom" Mode="NumericPages" CssClass="FormGridPagerCell"></PagerStyle>
				</asp:datagrid></TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>
    <asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>
    <asp:customvalidator id="cvFromDate" runat="server" ErrorMessage="Invalid FromDate" Display="None" Enabled="False" ControlToValidate="txtFromDate" ClientValidationFunction="VerifyDate"></asp:customvalidator>
    <asp:requiredfieldvalidator id="rfvFromDate" runat="server" ErrorMessage="Please enter FromDate" Display="None"	Enabled="False" ControlToValidate="txtFromDate"></asp:requiredfieldvalidator>
	<script language="javascript">
	<!--
	    function SetDelegationValidator() {
	        ValidatorEnable(document.getElementById("<%=cvFromDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvFromDate.ClientID%>"), true);
	    }
	// -->
	</script>

</asp:Content>
