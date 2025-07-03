<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.master" CodeBehind="JobDuplicator.aspx.vb" Inherits="eCAMS.JobDuplicator" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
		<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="344" border="0">
				<TR>
					<TD colspan=3>
						<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>
                        <asp:placeholder id="placeholderMsg" runat="server"></asp:placeholder>
					</TD>
				</TR>
            <asp:panel id="panelFullPage" runat="server">
				<TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:Label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:Label></TD>
				    <TD height="26">
					    <asp:DropDownList id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:DropDownList></TD>
			    </TR>
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="lblTID" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtTerminalID" runat="server" CssClass="FormDEField" size="20"></asp:textbox><asp:label id="lblTIDHint" runat="server" CssClass="FormDEHint"></asp:label></TD>
			    </TR>
			    <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="Label3" runat="server" CssClass="FormDEHeader">New TerminalID</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtNewTerminalID" runat="server" CssClass="FormDEField" size="20"></asp:textbox><asp:label id="Label4" runat="server" CssClass="FormDEHint"></asp:label></TD>
			    </TR>
			    <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="Label5" runat="server" CssClass="FormDEHeader">New CAIC</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtNewCAIC" runat="server" CssClass="FormDEField" size="20"></asp:textbox><asp:label id="Label6" runat="server" CssClass="FormDEHint"></asp:label></TD>
			    </TR>
				<TR>
					<TD width="11" height="17"></TD>
					<TD width="86" height="17"></TD>
					<TD align="right" height="17"></TD>
				</TR>
				<TR>
					<TD width="11" height="10"></TD>
					<TD width="86" height="10"></TD>
					<TD align="right" height="10">
						<INPUT class="FormDEButton" id="btnDuplicate" type="submit" value=" GO " runat="server"></TD>
				</TR>
				<TR>
					<TD width="11"></TD>
					<TD width="86"></TD>
					<TD align="right"></TD>
				</TR>
		    </asp:panel>

		    <asp:panel id="panelAcknowledge" runat="server">
			    <TR>
				    <TD width="10"></TD>
				    <TD colspan="2" align="left">
					    <asp:label id="lblAcknowledge" runat="server" CssClass="MemberInfo"></asp:label></TD>
				    <TD width="10"></TD>
			    </TR>		
		
		    </asp:panel>

		</TABLE>
	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"
		Width="152px"></asp:ValidationSummary>
    <asp:RequiredFieldValidator ID="rfvTerminalID" runat="server" ControlToValidate="txtTerminalID"
        Display="None" ErrorMessage="Please enter TerminalID."></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvNewTerminalID" runat="server" ControlToValidate="txtNewTerminalID"
        Display="None" ErrorMessage="Please enter New TerminalID."></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvNewCAIC" runat="server" ControlToValidate="txtNewCAIC"
        Display="None" ErrorMessage="Please enter New CAIC."></asp:RequiredFieldValidator>
<script language="javascript">
				<!--
    function ResetAllValidators() {
        ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), false);
        ValidatorEnable(document.getElementById("<%=rfvNewTerminalID.ClientID%>"), false);
        ValidatorEnable(document.getElementById("<%=rfvNewCAIC.ClientID%>"), false);
    }

    function SetJobValidator() {
        ResetAllValidators();
        //debugger
        switch (document.getElementById("<%=cboClientID.ClientID%>").value) {
            case "CBA":
                ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), true);
                ValidatorEnable(document.getElementById("<%=rfvNewTerminalID.ClientID%>"), true);
                ValidatorEnable(document.getElementById("<%=rfvNewCAIC.ClientID%>"), true);
                break;

            default:
                ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), true);
                ValidatorEnable(document.getElementById("<%=rfvNewTerminalID.ClientID%>"), true);
                break;
        }

    }
    function ConfirmWithValidation(msg) {
        SetJobValidator();
        if (Page_ClientValidate()) {
            return confirm(msg);
        }
        else {
            return false;
        }
    }

				// -->
	</script>

</asp:Content>
