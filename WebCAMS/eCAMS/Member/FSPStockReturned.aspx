<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPStockReturned" Codebehind="FSPStockReturned.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label><asp:panel id="panelEdit" runat="server" Width="810px" Height="801px">
		<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="810" bgColor="#eeeeee"
			border="0" style="height: 100px">
			<TR>
				<TD width="11" height="18"></TD>
				<TD width="110" height="18">
					<asp:label id="lblDepot" runat="server" CssClass="FormDEHeader">From</asp:label></TD>
				<TD height="18">
					<asp:dropdownlist id="cboFromLocation" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="18"></TD>
				<TD width="110" height="18">
					<asp:label id="Label1" runat="server" CssClass="FormDEHeader">To</asp:label></TD>
				<TD height="18">
					<asp:dropdownlist id="cboToLocation" runat="server" CssClass="FormDEField" Width="180px"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="24"></TD>
				<TD width="110" height="24">
					<asp:label id="Label2" runat="server" CssClass="FormDEHeader">Date Returned</asp:label></TD>
				<TD height="24">
					<asp:textbox id="txtDateReturned" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
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
				<TD align="right" height="10"><INPUT class="FormDEButton" id="btnSave" onclick="ValidatorEnable(Page_Validators[0], false);ValidatorEnable(Page_Validators[1], true);ValidatorEnable(Page_Validators[2], true);ValidatorEnable(Page_Validators[3], false);ValidatorEnable(Page_Validators[4], false);"
						type="submit" value="Start Batch" name="btnSave" runat="server"></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="110"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>
         <!-- was 261 -->
        <TABLE id="tableScan" cellSpacing="1" cellPadding="1" width="810" border="0" bgColor="#eeeeee" style="height: 100px">
			<TR>
				<TD width="10"></TD>
				<TD style="width: 764px">
					<ul>
					    <li>
					        <asp:label id="lblListInfo1" runat="server" CssClass="MemberInfo" Text="Updating stock as returned from Depot-{0} to {1} on {2}"></asp:label>
                        </li>
					    <li>
					        <asp:label id="lblListInfo3" runat="server" CssClass="MemberInfo" Text="To add device as returned, scan serial number barcode into the box below"></asp:label>
                        </li>
                    </ul>
                </TD>
				<TD width="10"></TD>
			</TR>
			<TR>
				<TD width="10"></TD>
				<TD style="width: 764px">
				  <!-- 1. Tie the buuton to the textbox, 2.solved  "this._postBackSettings.async' is null or not an object" error when hit ENTER key-->
				  <asp:Panel ID="Panel1" runat="server"  DefaultButton="btnSaveSerial">
					<asp:label id="lblSerial" runat="server" CssClass="FormDEHeader">Serial No.</asp:label>
					<asp:textbox id="txtSerial" runat="server" CssClass="FormDEField" Width="220px"></asp:textbox>
					<asp:textbox id="txtBatchID" runat="server" visible="False"></asp:textbox>&nbsp;&nbsp;<asp:Button
                        ID="btnSaveSerial" runat="server" Text="Save Serial" OnClientClick="ValidatorEnable(Page_Validators[0], true);ValidatorEnable(Page_Validators[1], false);ValidatorEnable(Page_Validators[2], false);ValidatorEnable(Page_Validators[3], false);"/>
				  </asp:Panel>		
				</TD>
				<TD width="10"></TD>
			</TR>
		
			<TR>
				<TD width="10" style="height: 168px"></TD>
				<TD style="width: 764px; height: 168px;">
					<asp:datagrid id="grdDevice" runat="server" CssClass="FormGrid">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
				<TD width="10" style="height: 168px"></TD>
			</TR>
           
         </TABLE>
         <TABLE id="Table3" cellpadding="1" cellspacing="1" height="130" width="810" bgColor="#eeeeee"
			border="0">
            <TR>
				<TD width="11" height="24"></TD>
				<TD width="110" height="24">
					<asp:label id="Label3" runat="server" CssClass="FormDEHeader">ConNote No</asp:label></TD>
				<TD height="24">
					<asp:textbox id="txtReferenceNo" runat="server" CssClass="FormDEField" Width="328px"></asp:textbox></TD>
			</TR>
            <TR>
                <TD width="11" height="91"></TD>
				<TD width="110" height="91">
                    <asp:Label ID="Label4" runat="server" CssClass="FormDEHeader">Notes</asp:Label></BR>
                    <asp:Label ID="Label5" runat="server" CssClass="FormDEHint">(Max 1000 characters)</asp:Label>
                </td>
                <td height="91">
                    <asp:TextBox ID="txtNote" runat="server" CssClass="FormDEField" Height="84px" TextMode="MultiLine" Width="576px"></asp:TextBox>
                </td>
             </TR>
         </TABLE>
         <asp:panel id="panelExcelBox" runat="server" Width="810px" DESIGNTIMEDRAGDROP="388" BackColor="#eeeeee" Height="10px">
             <TABLE id="Table4" cellpadding="1" cellspacing="1" height="50" width="810px" bgColor="#eeeeee"
			    border="0">
                <TR>
                    <TD width="10"></TD>
				    <TD style="width: 764px">
					    <ul>
					        <li>
					            <asp:label id="lblListInfo4" runat="server" CssClass="MemberInfo" Text="To obtain an Excel file of all devices scanned into this batch, click <A HREF='../member/FSPStockReturned.aspx?sv=download&id={0}'>Download</A> before closing the batch"></asp:label>
                            </li>
                            <li>
					            <asp:label id="Label6" runat="server" CssClass="MemberInfo" Text="To close the batch, enter No of boxes "></asp:label>
					            <asp:textbox id="txtBoxes" runat="server" CssClass="FormDEField" Width="20"></asp:textbox>
                            </li>
                        </ul>
				    </TD>
				    <TD width="10"></TD>
                </TR>
             </TABLE>
             <TABLE id="Table5" cellSpacing="1" cellPadding="1" width="810" bgColor="#eeeeee"
			        border="0" style="height: 30px">
			        <TR>
				        <TD width="11" height="10"></TD>
				        <TD width="110" height="10"></TD>
				        <TD align="right" height="10"><INPUT class="FormDEButton" id="btnClose" onclick="ValidatorEnable(Page_Validators[0], false); ValidatorEnable(Page_Validators[1], false); ValidatorEnable(Page_Validators[2], false); ValidatorEnable(Page_Validators[3], true); ValidatorEnable(Page_Validators[4], true);"
						        type="submit" value="Close Batch" name="btnClose" runat="server"></TD>
			        </TR>
             </TABLE>
        </asp:panel>
       
	</asp:panel>
    <asp:panel id="panelScan" runat="server" Width="800px" DESIGNTIMEDRAGDROP="388" BackColor="#eeeeee" Height="1px">
	</asp:panel>
    <asp:panel id="panelAcknowledge" runat="server" ClientIDMode="AutoID">
        &nbsp;<br></br>
        <br></br>
		The StockReturned has been closed successfully. <br/>Notification email has been sent to Ingenico Stock Controller.
	</asp:panel><asp:requiredfieldvalidator id="rfvSerial" runat="server" Enabled="False" Display="None" ControlToValidate="txtSerial"
		ErrorMessage="Please enter serial number."></asp:requiredfieldvalidator><asp:validationsummary id="ValidationSummary1" runat="server" ShowSummary="False" ShowMessageBox="True"></asp:validationsummary><asp:customvalidator id="cvDateReturned" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReturned"
		ErrorMessage="Invalid Date Returned" ClientValidationFunction="VerifyDate"></asp:customvalidator><asp:requiredfieldvalidator id="rfvDateReturned" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReturned"
		ErrorMessage="Please enter Date Returned."></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvReferenceNo" runat="server" Enabled="False" Display="None" ControlToValidate="txtReferenceNo"
		ErrorMessage="Please enter ConNote No."></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvBoxes" runat="server" Enabled="False" Display="None" ControlToValidate="txtBoxes"
        ErrorMessage="Please enter total number of boxes to be returned."></asp:requiredfieldvalidator>
</asp:Content>




