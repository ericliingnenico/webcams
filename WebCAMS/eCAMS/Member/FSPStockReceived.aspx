<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPStockReceived" Codebehind="FSPStockReceived.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>
    <asp:panel id="panelEdit" runat="server" Width="600px">
		<TABLE id="Table2" style="WIDTH: 520px; HEIGHT: 152px" cellSpacing="1" cellPadding="1"
			width="520" border="0">
			<TR>
				<TD width="11" height="18"></TD>
				<TD width="110" height="18">
					<asp:label id="lblDepot" runat="server" CssClass="FormDEHeader"> Depot</asp:label></TD>
				<TD height="18">
					<asp:dropdownlist id="cboDepot" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="24"></TD>
				<TD width="110" height="24">
					<asp:label id="Label2" runat="server" CssClass="FormDEHeader">Date Received</asp:label></TD>
				<TD height="24">
					<asp:textbox id="txtDateReceived" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
					<asp:label id="Label9" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label></TD>
			</TR>
			<TR>
				<TD width="11" height="17"></TD>
				<TD width="110" height="17"></TD>
				<TD align="right" height="17"></TD>
			</TR>
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="110" height="10"></TD>
				<TD align="right" height="10">
                    <INPUT class="FormDEButton" id="btnSave" onclick="ValidatorEnable(Page_Validators[0], false);ValidatorEnable(Page_Validators[1], true);ValidatorEnable(Page_Validators[2], true);"
                         type="submit" value="Save" name="btnSave" runat="server"></TD>

			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="110"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>
	</asp:panel>
    <asp:panel id="panelScan" runat="server">
		<TABLE id="Table3" cellSpacing="1" cellPadding="1" width="100%" border="0">
			<TR>
				<TD width="10"></TD>
				<TD>
					<ul>
					    <li>
					        <asp:label id="lblListInfo1" runat="server" CssClass="MemberInfo" Text="Updating stock as received by Depot-{0} on {1}"></asp:label>
                        </li>
					    <li>
					        <asp:label id="lblListInfo2" runat="server" CssClass="MemberInfo" Text="To change the received date or the depot number, click <A HREF='../member/FSPStockReceived.aspx?sv=edit&id={0}'>Edit</A>"></asp:label>
                        </li>
					    <li>
					        <asp:label id="lblListInfo3" runat="server" CssClass="MemberInfo" Text="To add device as received, scan serial number barcode into the box below"></asp:label>
                        </li>
                        
                    </ul>
				
				</TD>
				<TD width="10"></TD>
			</TR>
			<TR>
				<TD width="10"></TD>
				<TD>
				  <!-- 1. Tie the buuton to the textbox, 2.solved  "this._postBackSettings.async' is null or not an object" error when hit ENTER key-->
				  <asp:Panel ID="Panel1" runat="server"  DefaultButton="btnSaveSerial">
					<asp:label id="lblSerial" runat="server" CssClass="FormDEHeader">Serial No.</asp:label>
					<asp:textbox id="txtSerial" runat="server" CssClass="FormDEField"  Width="220px"></asp:textbox>
					<asp:textbox id="txtBatchID" runat="server" visible="False"></asp:textbox>&nbsp;&nbsp;<asp:Button
                        ID="btnSaveSerial" runat="server" cssclass="FormDEButton" Text="SaveSerial" OnClientClick="ValidatorEnable(Page_Validators[0], true);ValidatorEnable(Page_Validators[1], false);ValidatorEnable(Page_Validators[2], false);"/>
				  </asp:Panel>  
				</TD>
				<TD width="10"></TD>
			</TR>
			<TR>
				<TD width="10"></TD>
				<TD>
					<ul>
					    <li>
					        <asp:label id="lblListInfo4" runat="server" CssClass="MemberInfo" Text="To obtain an Excel file of all devices scanned into this batch, click <A HREF='../member/FSPStockReceived.aspx?sv=download&id={0}'>Download</A> before closing the batch"></asp:label>
                        </li>

					    <li>
					        <asp:label id="lblListInfo5" runat="server" CssClass="MemberInfo" Text="To close the batch and send this batch to Keycorp, click <A HREF='../member/FSPStockReceived.aspx?sv=close&id={0}'>Close</A>"></asp:label>
                        </li>
                    </ul>
				</TD>
				<TD width="10"></TD>
			</TR>
			<TR>
				<TD width="10"></TD>
				<TD class="MemberInfo">Device scanned list: <br />
					<asp:datagrid id="grdDevice" runat="server" CssClass="FormGrid">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
				<TD width="10"></TD>
			</TR>
		</TABLE>
	</asp:panel>
    <asp:panel id="panelAcknowledge" runat="server">
        &nbsp;<br></br>
		The StockReceipt has been closed successfully. <br/>Notification email has been sent to Ingenico Stock Controller.
	</asp:panel>
	<asp:requiredfieldvalidator id="rfvSerial" runat="server" ErrorMessage="Please enter serial number." ControlToValidate="txtSerial" Display="None" Enabled="False"></asp:requiredfieldvalidator>
	<asp:customvalidator id="cvDateReceived" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReceived" ErrorMessage="Invalid Date Received" ClientValidationFunction="VerifyDate"></asp:customvalidator>
    <asp:requiredfieldvalidator id="rfvDateReceived" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReceived"	ErrorMessage="Please enter Date Received."></asp:requiredfieldvalidator>
	<asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>

</asp:Content>



