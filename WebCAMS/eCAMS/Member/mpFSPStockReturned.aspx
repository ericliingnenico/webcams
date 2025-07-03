<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpFSPStockReturned.aspx.vb" Inherits="eCAMS.mpFSPStockReturned" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
    <asp:panel id="panelEdit" runat="server">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <b>From Depot:</b>
            </span>
            <p>
            <span class="select">
                <asp:dropdownlist id="cboFromLocation" runat="server"></asp:dropdownlist>
                <span class="arrow"></span>
            </span>
            </p>
        </li>
        <li class="textbox">
            <span class="name">
                <b>To Depot:</b>
            </span>
            <p>
            <span class="select">
                <asp:dropdownlist id="cboToLocation" runat="server"></asp:dropdownlist>
                <span class="arrow"></span>
            </span>
            </p>
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>Date Returned:</b><asp:textbox id="txtDateReturned" runat="server" placeholder="dd/mm/yy" size="8"></asp:textbox>
                </p>
            </span>
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>ConNote No:</b><asp:textbox id="txtReferenceNo" runat="server" placeholder="enter conote no." size="18"></asp:textbox>
                </p>
            </span>
            
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>Notes:</b><asp:textbox id="txtNote" runat="server" placeholder="Max 200 characters"  Rows="3" TextMode="MultiLine"></asp:textbox>
                </p>
            </span>

        </li>
        <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnSave" runat="server" Text="Start Batch" OnClientClick="ValidatorEnable(Page_Validators[0], false);ValidatorEnable(Page_Validators[1], true);ValidatorEnable(Page_Validators[2], true);ValidatorEnable(Page_Validators[3], false);ValidatorEnable(Page_Validators[4], false);"/>
            </p>
            </span>
        </li>
        <li class="txtbox">
                <p><b>Stock Returned</b> tap and scan barcode</p>
				<asp:Panel ID="Panel2" runat="server"  DefaultButton="btnSaveSerial">
                    <p>
				       <asp:textbox id="txtSerial" runat="server" placeholder="tap and scan barcode" Height="40" Width="92%" Font-Size="12"></asp:textbox>
                        <asp:HiddenField ID="txtBatchID" runat="server" />
                    </p>
                    <p>
                        <asp:Button ID="btnSaveSerial" runat="server" Text="Save Serial" OnClientClick="ValidatorEnable(Page_Validators[0], true);ValidatorEnable(Page_Validators[1], false);ValidatorEnable(Page_Validators[2], false);ValidatorEnable(Page_Validators[3], false);"/>
                    </p>
				</asp:Panel>  
        </li>
		<li class="menu">
   			<a class="noeffect" href="mpFSPStockReturned.aspx?sv=download&id=<%=m_BatchID%>"  onclick="return confirm('Download the scanned devices?');">
		        <span class="smallname">Action: Download all devices scanned</span>
                <span class="arrow"></span>
            </a>
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>No of boxes:</b><asp:textbox id="txtBoxes" runat="server" size="3"></asp:textbox>
                </p>
            </span>
        </li>
        <asp:Repeater ID="RepeaterDevice" runat="server">
            <ItemTemplate>
                <li class="textbox">
                    <span class="name">
                    <p>
                        <b>No.<%# Eval("Seq") %></b>&nbsp;&nbsp;
                        <b>Serial:</b>&nbsp;&nbsp;
                        <%# Eval("Serial") %></p>
                    <p>
                        <b>Device:</b> &nbsp;<%# Eval("DeviceName") %></p>
                    <p>
                        <b>Status:</b> &nbsp;<%# Eval("CaseDescription") %></p>
                    </span>
                 </li>
            </ItemTemplate>
        </asp:Repeater>
         <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnClose" runat="server" Text="Close Batch" OnClientClick="ValidatorEnable(Page_Validators[0], false);ValidatorEnable(Page_Validators[1], false);ValidatorEnable(Page_Validators[2], false);ValidatorEnable(Page_Validators[3], true);ValidatorEnable(Page_Validators[4], true);"/>
            </p>
            </span>
        </li>
	</ul>
    </asp:panel>
    <asp:panel id="panelScan" runat="server">
	</asp:panel>
    <asp:panel id="panelAcknowledge" runat="server">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p>
                    The StockReturned has been closed successfully. 
                </p>
                <p>&nbsp;</p>
                <p>
                    Notification email has been sent to Ingenico Stock Controller.
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>
<asp:requiredfieldvalidator id="rfvSerial" runat="server" Enabled="False" Display="None" ControlToValidate="txtSerial"	ErrorMessage="Please enter serial number."></asp:requiredfieldvalidator>
<asp:validationsummary id="ValidationSummary1" runat="server" ShowSummary="False" ShowMessageBox="True"></asp:validationsummary>
<asp:customvalidator id="cvDateReturned" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReturned" ErrorMessage="Invalid Date Returned" ClientValidationFunction="VerifyDate"></asp:customvalidator>
<asp:requiredfieldvalidator id="rfvDateReturned" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReturned" ErrorMessage="Please enter Date Returned."></asp:requiredfieldvalidator>
<asp:requiredfieldvalidator id="rfvReferenceNo" runat="server" Enabled="False" Display="None" ControlToValidate="txtReferenceNo" ErrorMessage="Please enter ConNote No."></asp:requiredfieldvalidator>
<asp:requiredfieldvalidator id="rfvBoxes" runat="server" Enabled="False" Display="None" ControlToValidate="txtBoxes" ErrorMessage="Please enter total number of boxes to be returned."></asp:requiredfieldvalidator>
</asp:Content>
