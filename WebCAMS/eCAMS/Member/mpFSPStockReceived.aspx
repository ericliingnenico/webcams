<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpFSPStockReceived.aspx.vb" Inherits="eCAMS.mpFSPStockReceived" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
    <asp:panel id="panelEdit" runat="server">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <b>Depot:</b>
            </span>
            <p>
            <span class="select">
                <asp:dropdownlist id="cboDepot" runat="server"></asp:dropdownlist>
                <span class="arrow"></span>
            </span>
            </p>
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>Date Received:</b><asp:textbox id="txtDateReceived" runat="server" placeholder="dd/mm/yy" size="8"></asp:textbox>
                </p>
            </span>

            <span class="name">
            <p>
                <asp:Button ID="btnSave" runat="server" Text="Save" OnClientClick="ValidatorEnable(Page_Validators[0], false);ValidatorEnable(Page_Validators[1], true);ValidatorEnable(Page_Validators[2], true);"/>
            </p>
            </span>
        </li>
	</ul>
    </asp:panel>
    <asp:panel id="panelScan" runat="server">
	<ul class="pageitem">
        <li class="txtbox">
                <p><b>Stock Received</b> tap and scan barcode</p>
				<asp:Panel ID="Panel2" runat="server"  DefaultButton="btnSaveSerial">
				 <p>
                    <asp:textbox id="txtSerial" runat="server" placeholder="tap and scan barcode" Height="40" Width="92%" Font-Size="12"></asp:textbox>
                    <asp:HiddenField ID="txtBatchID" runat="server" />
                 </p>
                 <p>
                    <asp:Button ID="btnSaveSerial" runat="server" Text="Submit" OnClientClick="ValidatorEnable(Page_Validators[0], true);ValidatorEnable(Page_Validators[1], false);ValidatorEnable(Page_Validators[2], false);" />
                 </p>
				</asp:Panel>  
        </li>
		<li class="menu">
   			<a class="noeffect" href="mpFSPStockReceived.aspx?sv=download&id=<%=m_batchID%>"  onclick="return confirm('Download the scanned devices?');">
		        <span class="smallname">Action: Download all devices scanned</span>
                <span class="arrow"></span>
            </a>
        </li>
		<li class="menu">
   			<a class="noeffect" href="mpFSPStockReceived.aspx?sv=close&id=<%=m_batchID%>" onclick="return confirm('Close the batch?');">
		        <span class="smallname">Action: Close and send to Keycorp</span>
                <span class="arrow"></span>
            </a>
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
	</ul>
	</asp:panel>
    <asp:panel id="panelAcknowledge" runat="server">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p>
                    The StockReceipt has been closed successfully. 
                </p>
                <p>&nbsp;</p>
                <p>
                    Notification email has been sent to Ingenico Stock Controller.
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>
<asp:requiredfieldvalidator id="rfvSerial" runat="server" ErrorMessage="Please enter serial number." ControlToValidate="txtSerial" Display="None" Enabled="False"></asp:requiredfieldvalidator>
	<asp:customvalidator id="cvDateReceived" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReceived" ErrorMessage="Invalid Date Received" ClientValidationFunction="VerifyDate"></asp:customvalidator>
    <asp:requiredfieldvalidator id="rfvDateReceived" runat="server" Enabled="False" Display="None" ControlToValidate="txtDateReceived"	ErrorMessage="Please enter Date Received."></asp:requiredfieldvalidator>
	<asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>

</asp:Content>
