<%@ Page Language="vb" MasterPageFile="~/MemberPopupMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.DeviceView" Codebehind="DeviceView.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
				<TABLE id="Table2" style="WIDTH: 559px; HEIGHT: 286px" cellSpacing="1" cellPadding="1"
					width="559" border="0">
					<TR>
						<TD colspan=3>
							<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
						</TD>
					</TR>
					
					<TR>
						<TD width="10"></TD>
						<TD width="145"><asp:label id="Label4" runat="server" CssClass="FormDEHeader">Serial No.</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtSerial" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; HEIGHT: 17px; BORDER-BOTTOM-STYLE: none"
								type="text" size="40" name="txtSource" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD width="145"><asp:label id="Label2" runat="server" CssClass="FormDEHeader">MMD ID</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtMMDID" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" size="15" name="txtJobID" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD width="145"><asp:label id="Label5" runat="server" CssClass="FormDEHeader">Maker</asp:label></TD>
						<TD style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"><INPUT class="FormDEField" id="txtMaker" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" name="txtMaker" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD width="145"><asp:label id="Label6" runat="server" CssClass="FormDEHeader">Model</asp:label></TD>
						<TD style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"><INPUT class="FormDEField" id="txtModel" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" name="txtModel" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD width="145"><asp:label id="lblDevice" runat="server" CssClass="FormDEHeader">Device</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtDevice" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" size="40" name="txtSLA" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD width="145"><asp:label id="lblStatus" runat="server" CssClass="FormDEHeader">Status</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtStatus" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" size="40" name="txtStatus" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD width="145"><asp:label id="Label7" runat="server" CssClass="FormDEHeader">Note</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtNote" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" size="80" name="txtNote" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD width="145" colspan="2"><asp:label id="lblSep" runat="server" CssClass="FormDEHeader">Last Installed At:</asp:label></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD align="right" width="145"><asp:label id="Label3" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
						<TD style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"><INPUT class="FormDEField" id="txtTerminalID" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" name="txtTerminalID" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD align="right" width="145"><asp:label id="Label11" runat="server" CssClass="FormDEHeader">MerchantID</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtMerchantID" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" name="txtMerchantID" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD align="right" width="145"><asp:label id="lblName" runat="server" CssClass="FormDEHeader">Name</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtName" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" size="60" name="txtDelayReason" runat="server" readonly="readOnly"></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD align="right" width="145"><asp:label id="Label1" runat="server" CssClass="FormDEHeader">Date In</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtDateIn" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; width: 168px;"
								type="text" name="txtDateIn" runat="server" readonly="readOnly">
							<asp:label id="lblDateInTimeZone" runat="server" CssClass="FormDEHint">CAMS System Time</asp:label></TD>
					</TR>
					<TR>
						<TD width="10"></TD>
						<TD align="right" width="145"><asp:label id="lblDateOut" runat="server" CssClass="FormDEHeader">Date Out</asp:label></TD>
						<TD><INPUT class="FormDEField" id="txtDateOut" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; HEIGHT: 17px; BORDER-BOTTOM-STYLE: none; width: 168px;"
								type="text" name="txtDateOut" runat="server" readonly="readOnly">
							<asp:label id="lblDateOutTimeZone" runat="server" CssClass="FormDEHint">CAMS System Time</asp:label></TD>
					</TR>
				</TABLE>
</asp:Content>