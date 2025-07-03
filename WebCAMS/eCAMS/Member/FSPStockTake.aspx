<%@ Page Title="" Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPStockTake" Codebehind="FSPStockTake.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

	<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label><asp:panel id="panelEdit" runat="server" Width="792px">
		<TABLE id="Table2" height="268" cellSpacing="1" cellPadding="1" width="720" bgColor="#eeeeee"
			border="0">
			<TR>
				<TD width="11" height="18"></TD>
				<TD width="110" height="18">
					<asp:label id="lblDepot" runat="server" CssClass="FormDEHeader">Depot</asp:label></TD>
				<TD height="18">
					<asp:dropdownlist id="cboDepot" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="18"></TD>
				<TD width="110" height="18">
					<asp:label id="Label1" runat="server" CssClass="FormDEHeader">StockTake Date</asp:label></TD>
				<TD height="18">
					<asp:dropdownlist id="cboStockTakeDate" runat="server" CssClass="FormDEField" Width="180px"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="91"></TD>
				<TD width="110" height="91">
					<asp:label id="Label4" runat="server" CssClass="FormDEHeader">Notes</asp:label><BR>
					<asp:label id="Label5" runat="server" CssClass="FormDEHint">(Max 100 characters)</asp:label></TD>
				<TD height="91">
					<asp:textbox id="txtNote" runat="server" CssClass="FormDEField" Width="576px" Height="84px" TextMode="MultiLine"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="17"></TD>
				<TD width="110" height="17"></TD>
				<TD align="right" height="17"></TD>
			</TR>
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="110" height="10"></TD>
				<TD align="right" height="10"><INPUT class="FormDEButton" id="btnSave" onclick="ValidatorEnable(Page_Validators[0], false);"
						type="submit" value="Save" name="btnSave" runat="server"></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="110"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>
	</asp:panel><asp:panel id="panelScan" runat="server" Width="800px" DESIGNTIMEDRAGDROP="388" BackColor="#eeeeee">
		<TABLE id="tableScan" height="266" cellSpacing="1" cellPadding="1" width="792" border="0">
			<TR>
				<TD width="10"></TD>
				<TD>
					<ul>
					    <li>
					        <asp:label id="lblListInfo3" runat="server" CssClass="MemberInfo" Text="Scan serial number barcode into the box below"></asp:label>
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
					<asp:textbox id="txtSerial" runat="server" CssClass="FormDEField" Width="220px"></asp:textbox>
					<asp:textbox id="txtBatchID" runat="server" visible="False"></asp:textbox>&nbsp;&nbsp;<asp:Button
                        ID="btnSaveSerial" runat="server" Text="SaveSerial" OnClientClick="ValidatorEnable(Page_Validators[0], true);"/>
				  </asp:Panel>		
				</TD>
				<TD width="10"></TD>
			</TR>
			
			
			<TR>
				<TD width="10"></TD>
				<TD>
					<ul>
					    <li>
					        <asp:label id="lblListInfo4" runat="server" CssClass="MemberInfo" Text="To obtain an Excel file of all devices scanned into this batch, click <A HREF='../member/FSPStockTake.aspx?sv=download&id={0}'>Download</A> before closing the batch"></asp:label>
                        </li>

					    <li>
					        <asp:label id="Label6" runat="server" CssClass="MemberInfo" Text="To close the batch, click "></asp:label>
					        <A HREF='../member/FSPStockTake.aspx?sv=close&id=<%=m_BatchID%>'>Close</A>
                        </li>
                    </ul>
				</TD>
				<TD width="10"></TD>
			</TR>
			<TR>
				<TD width="10"></TD>
				<TD>
					<asp:datagrid id="grdDevice" runat="server" CssClass="FormGrid">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
				<TD width="10"></TD>
			</TR>
		</TABLE>
	</asp:panel><asp:panel id="panelAcknowledge" runat="server">
		<asp:label id="lblAcknowledge" runat="server" CssClass="FormTitle"></asp:label>
	</asp:panel>
    <asp:requiredfieldvalidator id="rfvSerial" runat="server" Enabled="False" Display="None" ControlToValidate="txtSerial" ErrorMessage="Please enter serial number."></asp:requiredfieldvalidator>
    <asp:validationsummary id="ValidationSummary1" runat="server" ShowSummary="False" ShowMessageBox="True"></asp:validationsummary>

</asp:Content>

