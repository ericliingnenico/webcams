<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.master" CodeBehind="BulkUpdateJob.aspx.vb" Inherits="eCAMS.BulkUpdateJob" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
		<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="600" border="0">
				<TR>
					<TD colspan=3>
						<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle">Bulk Update Tool</asp:label>
                        <asp:placeholder id="placeholderMsg" runat="server"></asp:placeholder>
					</TD>
				</TR>
            <asp:panel id="panelFullPage" runat="server">
				<asp:panel id="panelPasteData" runat="server">

				<TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:Label id="lblAction" runat="server" CssClass="FormDEHeader">BulkUpdate</asp:Label></TD>
				    <TD height="26">
                    <asp:DropDownList ID="cboType" runat="server" CssClass="FormDEField" Width="130px">
                        <asp:ListItem Value="0">Please Select</asp:ListItem>
                        
                        <asp:ListItem Value="1">FSP Quote</asp:ListItem>
                        <asp:ListItem Value="2">ExtraTime Unit</asp:ListItem>
                        <asp:ListItem Value="3">Terminal Collected</asp:ListItem>
                     </asp:DropDownList>

				    </TD>
			    </TR>

                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="lblCopy" runat="server" CssClass="FormDEHeader">DataPasted</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtPasteData" runat="server" CssClass="FormDEField"  TextMode="MultiLine" Height="200" Width="400"></asp:textbox><asp:label id="lblTIDHint" runat="server" CssClass="FormDEHint"></asp:label></TD>
			    </TR>
				<asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="false">
				<Columns>
					<asp:BoundField DataField="Id" HeaderText="Id" ItemStyle-Width="30" />
					<asp:BoundField DataField="Name" HeaderText="Name" ItemStyle-Width="150" />
					<asp:BoundField DataField="Country" HeaderText="Country" ItemStyle-Width="150" />
				</Columns>
				</asp:GridView>
				<br />
				<TR>
					<TD width="11" height="17"></TD>
					<TD width="86" height="17"></TD>
					<TD align="right" height="17"></TD>
				</TR>
				<TR>
					<TD width="11" height="10"></TD>
					<TD width="86" height="10"></TD>
					<TD align="right" height="10">
						<INPUT class="FormDEButton" id="btnBulkUpdate" type="submit" value=" GO " runat="server"></TD>
				</TR>
			</asp:panel>
				<asp:panel id="panelDoUpdateButton" runat="server" Visible="false">
				<TR>
					<TD width="11" height="17"></TD>
					<TD colspan="2"></TD>
				</TR>
				<TR>
					<TD colspan="2">
						<ul>
							<li>
								<asp:label id="lblBulkUpdteTitle" runat="server" CssClass="FormDEHeader" text=""></asp:label>
							</li>
							<li>
								<asp:label id="Label1" runat="server" CssClass="FormDEHeader">Bulk Update the following selected jobs</asp:label>&nbsp;<INPUT class="FormDEButton" id="btnDoUpdate" type="submit" value=" GO " runat="server">
							</li>
						</ul>
					</TD>
					<TD width="10"></TD>
				</TR>
				</asp:panel>

				<TR>
					<TD width="10"><asp:HiddenField ID="txtActionTypeID" runat="server" /></TD>
					<TD>
					<!-- Have to place ajax panel here, otherwise will upset bulkprint which calls Respomse.Write()-->		        
					<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
						<ContentTemplate>				
								<asp:datagrid id="grdJob" runat="server" CssClass="FormGrid" Width="100%" AllowPaging="True" PageSize="1000"
										GridLines="None" 
										AllowSorting="True">
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
    <asp:RequiredFieldValidator ID="rfvcboType" runat="server" ControlToValidate="cboType" InitialValue="0"
        Display="None" ErrorMessage="Please select one action"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvPasteData" runat="server" ControlToValidate="txtPasteData"
        Display="None" ErrorMessage="Please paste data in."></asp:RequiredFieldValidator>
<script language="javascript">
				<!--
    function ResetAllValidators() {
        ValidatorEnable(document.getElementById("<%=rfvPasteData.ClientID%>"), false);
    }

    function SetJobValidator() {
        ResetAllValidators();
        //debugger
        switch (document.getElementById("<%=cboType.ClientID%>").value) {
            default:
                ValidatorEnable(document.getElementById("<%=rfvPasteData.ClientID%>"), true);
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
