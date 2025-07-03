<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.FSPTask" Codebehind="FSPTask.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<p><asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<asp:hyperlink id="SearchAgainURL" runat="server" CssClass="MemberInfo" NavigateUrl="FSPTaskList.aspx"
			Width="112px">&lt&ltBack To List</asp:hyperlink></p>
	<asp:panel id="panelDetail" runat="server">
		<TABLE id="Table2" style="WIDTH: 616px; HEIGHT: 391px" cellSpacing="1" cellPadding="1"
			width="616" border="0">
			<TR>
				<TD colSpan="3"></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="lblSerial" runat="server" CssClass="FormDEHeader">Serial No.</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtSerial" runat="server" CssClass="FormDEField" Width="152px"></asp:textbox>
					<asp:textbox id="txtTaskID" runat="server" visible="False"></asp:textbox>&nbsp;&nbsp;<INPUT class="FormDEButton" id="btnSave" onclick="ValidatorEnable(Page_Validators[0], true);ValidatorEnable(Page_Validators[1], false);"
						type="submit" value="Save SerialNo" name="btnSave" runat="server"></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="lblCarrier" runat="server" CssClass="FormDEHeader">Carrier</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboCarrier" runat="server" CssClass="FormDEField" Width="168px"></asp:dropdownlist></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="lblConNoteNo" runat="server" CssClass="FormDEHeader">ConNote No.</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtConNoteNo" runat="server" CssClass="FormDEField" Width="208px"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="53"></TD>
				<TD vAlign="top" width="134" height="53">
					<asp:label id="Label2" runat="server" CssClass="FormDEHeader">Comments</asp:label></TD>
				<TD height="53">
					<asp:textbox id="txtCloseComment" runat="server" CssClass="FormDEField" Width="328px" TextMode="MultiLine"
						Height="52px"></asp:textbox>&nbsp;&nbsp;<INPUT class="FormDEButton" id="btnCloseTask" onclick="ValidatorEnable(Page_Validators[0], false);ValidatorEnable(Page_Validators[1], true);"
						type="submit" value="Close Task" name="btnCloseTask" runat="server"></TD>
			</TR>
			<TR>
				<TD width="11" height="145"></TD>
				<TD vAlign="top" width="134" height="145">
					<asp:label id="lblTaskDetails" runat="server" CssClass="FormDEHeader">Task Details</asp:label></TD>
				<TD height="145">
					<asp:textbox id="txtTaskDetails" runat="server" CssClass="FormDEField" Width="461px" TextMode="MultiLine"
						Height="134px" ReadOnly="True"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="127"></TD>
				<TD width="134" height="127">
					<asp:label id="Label1" runat="server" CssClass="FormDEHeader">Task Equipment</asp:label></TD>
				<TD align="left" height="127">
					<asp:datagrid id="grdDevice" runat="server" CssClass="FormGrid" Height="106px">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
			</TR>
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="134" height="10"></TD>
				<TD align="right" height="10"></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="134"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>
		<asp:requiredfieldvalidator id="rfvSerial" runat="server" Enabled="False" Display="None" ControlToValidate="txtSerial"
			ErrorMessage="Please enter serial number."></asp:requiredfieldvalidator>
		<asp:requiredfieldvalidator id="rfvConNoteNo" runat="server" Enabled="False" Display="None" ControlToValidate="txtConNoteNo"
			ErrorMessage="Please enter ConNote number."></asp:requiredfieldvalidator>
		<asp:validationsummary id="ValidationSummary1" runat="server" ShowSummary="False" ShowMessageBox="True"></asp:validationsummary>
	</asp:panel><asp:panel id="panelException" runat="server" visible="false">
		<TABLE id="Table2" style="WIDTH: 616px; cellSpacing: " cellPadding="1" width="616" border="0">
			<TR>
				<TD colSpan="3">
					<asp:Label id="lblErrorMsg" runat="server" Visible="True" Font-Size="Small" ForeColor="Red"
						Font-Bold="True">No matching device found</asp:Label></TD>
			</TR>
			<asp:panel id="panelSelectDevice" runat="server" visible="false">
				<TR>
					<TD width="11" height="26"></TD>
					<TD width="134" height="26">
						<asp:label id="Label3" runat="server" CssClass="FormDEHeader">Device</asp:label></TD>
					<TD height="26">
						<asp:dropdownlist id="cboDevice" runat="server" CssClass="FormDEField" Width="384px"></asp:dropdownlist></TD>
				</TR>
				<TR>
					<TD width="11" height="10"></TD>
					<TD width="134" height="10"></TD>
					<TD align="right" height="10"><INPUT class="FormDEButton" id="btnSaveDevice" onclick="ValidatorEnable(Page_Validators[0], false);ValidatorEnable(Page_Validators[1], false);"
							type="submit" value="Save" name="btnSave" runat="server">
					</TD>
				</TR>
			</asp:panel>
			<TR>
				<TD width="11"></TD>
				<TD width="134"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>
	</asp:panel>
</asp:Content>



