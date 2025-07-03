<%@ Page Language="vb" MasterPageFile="~/MemberPopupMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.SiteView" Codebehind="SiteView.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" style="WIDTH: 559px; HEIGHT: 286px" cellSpacing="1" cellPadding="1"
		width="559" border="0">
		<TR>
			<TD colspan="3">
				<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
			</TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label2" runat="server" CssClass="FormDEHeader">ClienID</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtClientID" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="5" name="txtClientID" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label3" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtTerminalID" type="text" name="txtTerminalID" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label11" runat="server" CssClass="FormDEHeader">MerchantID</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtMerchantID" type="text" name="txtMerchantID" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label5" runat="server" CssClass="FormDEHeader">Site Name</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtName" type="text" size="60" name="txtName" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label4" runat="server" CssClass="FormDEHeader">Address1</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtAddress1" type="text" size="60" name="txtAddress1" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label6" runat="server" CssClass="FormDEHeader">Address2</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtAddress2" type="text" size="60" name="txtAddress2" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10" style="height: 23px"></TD>
			<TD width="145" style="height: 23px"><asp:label id="Label7" runat="server" CssClass="FormDEHeader">City</asp:label></TD>
			<TD style="width: 902px; height: 23px"><INPUT class="FormDEField" id="txtCity" type="text" size="40" name="txtCity" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label8" runat="server" CssClass="FormDEHeader">State</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtState" type="text" size="5" name="txtState" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label9" runat="server" CssClass="FormDEHeader">Postcode</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtPostcode" type="text" size="5" name="txtPostcode" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label10" runat="server" CssClass="FormDEHeader">Contact</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtContact" type="text" size="40" name="txtContact" runat="server"
					style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label1" runat="server" CssClass="FormDEHeader">Phone</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtPhone" type="text" name="txtPhone" runat="server" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label12" runat="server" CssClass="FormDEHeader">Phone2</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtPhone2" type="text" name="txtPhone2" runat="server" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label13" runat="server" CssClass="FormDEHeader">BusinessActivity</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtBusinessActivity" type="text" name="txtBusinessActivity" runat="server" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; width: 248px;" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label14" runat="server" CssClass="FormDEHeader">TradingHours</asp:label></TD>
			<TD style="width: 902px"><INPUT class="FormDEField" id="txtTradingHoursInfo" type="text" name="txtTradingHoursInfo" runat="server" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; width: 440px;" readonly="readOnly"></TD>
		</TR>

	</TABLE>
</asp:Content>

