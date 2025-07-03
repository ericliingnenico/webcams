<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.SiteSearch" Codebehind="SiteSearch.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
		<SCRIPT LANGUAGE="JavaScript">
		function validateinput(){
		    if (document.getElementById("<%=txtTerminalID.ClientID%>").value.trim().length == 0 
				    && document.getElementById("<%=txtMerchantID.ClientID%>").value.trim().length == 0
				    && document.getElementById("<%=txtName.ClientID%>").value.trim().length == 0
				    && document.getElementById("<%=txtSuburb.ClientID%>").value.trim().length == 0
				    && document.getElementById("<%=txtPostcode.ClientID%>").value.trim().length == 0) {
				alert("Please enter at least one criteria.");
				return false;
			}
			return true;
		}
		</SCRIPT>
				<TABLE id="Table2" style="WIDTH: 344px; HEIGHT: 140px" cellSpacing="1" cellPadding="1"
					width="344" border="0">
					<tr>
						<TD colspan=3>
								<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
						</TD>
					</tr>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 26px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 26px"><asp:label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:label></TD>
						<TD style="HEIGHT: 26px"><asp:dropdownlist id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:dropdownlist></TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 21px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 21px"><asp:label id="lblTerminalID" runat="server" CssClass="FormDEHeader">Terminal ID</asp:label></TD>
						<TD style="HEIGHT: 21px"><asp:textbox id="txtTerminalID" runat="server" CssClass="FormDEField" Width="124px"></asp:textbox></TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 21px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 21px"><asp:label id="lblMerchantID" runat="server" CssClass="FormDEHeader">Merchant ID</asp:label></TD>
						<TD style="HEIGHT: 21px"><asp:textbox id="txtMerchantID" runat="server" CssClass="FormDEField" Width="122px"></asp:textbox></TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 21px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 21px"><asp:label id="lblMerchantName" runat="server" CssClass="FormDEHeader">Name</asp:label></TD>
						<TD style="HEIGHT: 21px"><asp:textbox id="txtName" runat="server" CssClass="FormDEField" Width="214px"></asp:textbox>
							<DIV class="FormDEHint" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">?</DIV>
						</TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 21px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 21px"><asp:label id="lblSuburb" runat="server" CssClass="FormDEHeader">Suburb</asp:label></TD>
						<TD style="HEIGHT: 21px"><asp:textbox id="txtSuburb" runat="server" CssClass="FormDEField" Width="154px"></asp:textbox></TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 21px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 21px"><asp:label id="lblPostcode" runat="server" CssClass="FormDEHeader">Postcode</asp:label></TD>
						<TD style="HEIGHT: 21px"><asp:textbox id="txtPostcode" runat="server" CssClass="FormDEField" Width="52px"></asp:textbox></TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 16px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 16px"><asp:label id="lblPageSize" runat="server" CssClass="FormDEHeader">Page Size</asp:label></TD>
						<TD style="HEIGHT: 16px"><asp:dropdownlist id="cboPageSize" runat="server" CssClass="FormDEField">
								<asp:ListItem Value="20" Selected="True">20</asp:ListItem>
								<asp:ListItem Value="40">40</asp:ListItem>
								<asp:ListItem Value="50">50</asp:ListItem>
								<asp:ListItem Value="60">60</asp:ListItem>
								<asp:ListItem Value="80">80</asp:ListItem>
								<asp:ListItem Value="100">100</asp:ListItem>
							</asp:dropdownlist><asp:label id="Label1" runat="server" CssClass="FormDEInfo">records per page</asp:label></TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 17px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 17px"></TD>
						<TD style="HEIGHT: 17px" align="left">
							<DIV class="FormDEHint" style="DISPLAY: inline; WIDTH: 237px; HEIGHT: 28px">?: 
								Can use % as wildcard&nbsp;to broaden the&nbsp;search</DIV>
						</TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px; HEIGHT: 10px"></TD>
						<TD style="WIDTH: 86px; HEIGHT: 10px"></TD>
						<TD style="HEIGHT: 10px" align="right">
                            &nbsp;<INPUT class="FormDEButton" id="btnSearch" type="submit" value=" GO " name="btnSearch"
								runat="server" language="javascript" onclick="return validateinput();"></TD>
					</TR>
					<TR>
						<TD style="WIDTH: 11px"></TD>
						<TD style="WIDTH: 86px"></TD>
						<TD align="right"></TD>
					</TR>
				</TABLE>
</asp:Content>


