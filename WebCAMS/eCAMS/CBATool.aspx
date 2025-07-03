<%@ Page Language="vb" Strict="True" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CBA Tools</title>
    <link href="~/Styles/Styles.css" rel="stylesheet" type="text/css" />
   	<link href="~/Styles/keycorp.css" type="text/css" rel="stylesheet">
    <script src="Scripts/incTool.js"></script>
</head>
<body>
    <form id="form1" runat="server">
	    <TABLE id="Table3" border="0" cellSpacing="0"  > 
            <tr bgcolor="#F6F6F6">
                <td colspan="2">
                   		<asp:label id="Label20" runat="server" CssClass="FormDEHeader" ForeColor="Red">TradingHours Format: <b>hhmm-hhmm</b>. Leave blank if closed</asp:label>
                </td>
            </tr>
		    <TR bgColor="#DDECEF">
			    <TD width="150" height="16">
                    <asp:label id="Label19" runat="server" CssClass="FormDEHeader">1. Enter TradingHours</asp:label><br>
                </TD>
			    <TD height="26">
				    <asp:label id="Label1" runat="server" CssClass="FormDEHeader">Mon-Fri:</asp:label>
				    <asp:textbox id="txtTradingHoursMonFri" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div id="div1" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
				    <asp:label id="Label22" runat="server" CssClass="FormDEHeader">Sat:</asp:label>
				    <asp:textbox id="txtTradingHoursSat" runat="server" CssClass="FormDEField" size="10"></asp:textbox>
				    <asp:label id="Label23" runat="server" CssClass="FormDEHeader">Sun:</asp:label>
				    <asp:textbox id="txtTradingHoursSun" runat="server" CssClass="FormDEField" size="10"></asp:textbox>
			                    
				</TD>
		    </TR>
            <tr bgColor="#DDECEF">
			    <TD width="150" height="16">
                    <asp:label id="Label5" runat="server" CssClass="FormDEHeader">&nbsp;&nbsp;&nbsp;&nbsp;Or pick from list</asp:label>				                    
                </TD>
                <td>
                    <asp:DropDownList ID="cboSp" runat="server">
                        <asp:ListItem Value="">Please Select</asp:ListItem>
                        <asp:ListItem Value="M-F:0900-1700Sat:Sun:">Mon-Fri:0900-1700</asp:ListItem>
                        <asp:ListItem Value="M-F:0900-1700Sat:0900-1700Sun:0900-1700">EveryDay:0900-1700</asp:ListItem>
                        <asp:ListItem Value="Please call to make appointment">Please call to make appointment</asp:ListItem>
                        <asp:ListItem Value="Merchant not available-see Call notes">Merchant not available-see Call notes</asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
            <tr bgColor="#BFD9DA">
			    <TD width="150" height="26">
                    <asp:label id="Label3" runat="server" CssClass="FormDEHeader">2. Select ErrorCode</asp:label>				                    
                </TD>
                <td>
                    <asp:DropDownList ID="cboErrorCode" runat="server">
                        <asp:ListItem Value="">Please Select</asp:ListItem>
                        
                        <asp:ListItem Value="01-Card reader faulty">01-Card reader faulty</asp:ListItem>
                        <asp:ListItem Value="02-Printer faulty">02-Printer faulty</asp:ListItem>
                        <asp:ListItem Value="03-Display faulty (not blank)">03-Display faulty (not blank)</asp:ListItem>
                        <asp:ListItem Value="04-Keypad faulty (incl stuck key)">04-Keypad faulty (incl stuck key)</asp:ListItem>
                        <asp:ListItem Value="05-Terminal blank/frozen/dead">05-Terminal blank/frozen/dead</asp:ListItem>
                        <asp:ListItem Value="06-Charging/battery issue">06-Charging/battery issue</asp:ListItem>
                        <asp:ListItem Value="07-Date issue">07-Date issue</asp:ListItem>
                        <asp:ListItem Value="08-Cable damaged/swap (specify serial or usb)">08-Cable damaged/swap (specify serial or usb)</asp:ListItem>
                        <asp:ListItem Value="09-Software error (please provide error code)">09-Software error (please provide error code)</asp:ListItem>
                        <asp:ListItem Value="10-Comms error (please provide error code)">10-Comms error (please provide error code)</asp:ListItem>
                        <asp:ListItem Value="11-Alert irruption/auth200 error">11-Alert irruption/auth200 error</asp:ListItem>
                        <asp:ListItem Value="12-No payment app (revert to android)">12-No payment app (revert to android)</asp:ListItem>
                        <asp:ListItem Value="13-Bluetooth pairing issue">13-Bluetooth pairing issue</asp:ListItem>
                        <asp:ListItem Value="14-Ghost touch">14-Ghost touch</asp:ListItem>
                        <asp:ListItem Value="15-Sim swap15-Sim swap">15-Sim swap</asp:ListItem>
                        <asp:ListItem Value="16-Merchant refusing to troubleshoot">16-Merchant refusing to troubleshoot</asp:ListItem>
                        <asp:ListItem Value="17-Other (please add comment)">17-Other (please add comment)</asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
            <tr bgColor="#87AAAE">
			    <TD width="150" height="26">
                    <asp:label id="Label4" runat="server" CssClass="FormDEHeader">3. Serial Reset Completed</asp:label>				                    
                </TD>
                <td>
                    <asp:DropDownList ID="cboSerialReset" runat="server">
                        <asp:ListItem Value="">Please Select</asp:ListItem>
                        <asp:ListItem Value="Serial Reset Completed:Yes">Yes</asp:ListItem>
                        <asp:ListItem Value="Serial Reset Completed:N/A">N/A</asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>

            <tr bgColor="#B8BFBB">
			    <TD width="150" height="26">
                    <asp:label id="Label7" runat="server" CssClass="FormDEHeader">4. Tech To Attend Without &nbsp;&nbsp;&nbsp; Calling</asp:label>				                    
                </TD>
                <td>
                    <asp:DropDownList ID="cboTechToAttWithoutCall" runat="server">
                        <asp:ListItem Value="">Please Select</asp:ListItem>
                        <asp:ListItem Value="Tech To Attend Without Calling:Yes">Yes</asp:ListItem>
                        <asp:ListItem Value="Tech To Attend Without Calling:N/A">N/A</asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
           
            <tr bgColor="#999999">
			    <TD colspan="2">
                    <asp:label id="Label2" runat="server" CssClass="FormDEHeader">5. Click&nbsp</asp:label>
                    <asp:Button ID="btnCopy" runat="server" Text="Copy" OnClientClick="return fnSubmit();" />
                    <asp:label id="Label6" runat="server" CssClass="FormDEHeader">&nbsp;and paste into COMMSEE special instructions</asp:label>
                </td>
            </tr>

            <tr bgColor="#F6F6F6">
			    <TD colspan="2">
				    <asp:textbox id="txtReturnValue" runat="server" CssClass="FormDEField" size="120"></asp:textbox>
                </td>

            </tr>
            <tr bgColor="#F6F6F6">
			    <TD colspan="2">
				    &nbsp;
                </td>

            </tr>
	    </TABLE>	
	<asp:customvalidator id="cvTradingHoursMonFri" runat="server" ControlToValidate="txtTradingHoursMonFri" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursMon-Fri (it must be in hhmm-hhmm and 24hr format or with text of 'CLOSED')"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursSat" runat="server" ControlToValidate="txtTradingHoursSat" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid trading hours Sat (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursSun" runat="server" ControlToValidate="txtTradingHoursSun" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid trading hours Sun (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        

	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"
		Width="152px"></asp:ValidationSummary>
    </form>
<script language="javascript">
				<!--

    function fnCopy() {
        //debugger;
        var tradingHR = "";
        //get tradingHR
        if (document.getElementById('<%=cboSp.ClientID%>').value == "") {
            tradingHR += "M-F:" + document.getElementById('<%=txtTradingHoursMonFri.ClientID%>').value;
            tradingHR += "Sat:" + document.getElementById('<%=txtTradingHoursSat.ClientID%>').value;
            tradingHR += "Sun:" + document.getElementById('<%=txtTradingHoursSun.ClientID%>').value;
        }
        else {
            tradingHR += document.getElementById('<%=cboSp.ClientID%>').value + " ";
        }

        tradingHR += "Code:" + document.getElementById('<%=cboErrorCode.ClientID%>').value;
        tradingHR += ". " + document.getElementById('<%=cboSerialReset.ClientID%>').value;
        tradingHR += ". " + document.getElementById('<%=cboTechToAttWithoutCall.ClientID%>').value;
        
        
        document.getElementById('<%=txtReturnValue.ClientID%>').value = tradingHR;
        window.clipboardData.setData("Text", tradingHR);

        
    }

    function fnReset() {
        document.getElementById('<%=txtTradingHoursMonFri.ClientID%>').value = "";

        document.getElementById('<%=txtTradingHoursSat.ClientID%>').value = "";
        document.getElementById('<%=txtTradingHoursSun.ClientID%>').value = "";
        document.getElementById('<%=cboSp.ClientID%>').value = "";
        document.getElementById('<%=cboErrorCode.ClientID%>').value = "";
        document.getElementById('<%=cboSerialReset.ClientID%>').value = "";
        document.getElementById('<%=cboTechToAttWithoutCall.ClientID%>').value = "";
    }

    function fnSubmit() {
        if (Page_ClientValidate()) {
            fnCopy();
            fnReset();
            return false;
        }
        else {
            return false;
        }
    }

				// -->
	</script>

</body>
</html>
