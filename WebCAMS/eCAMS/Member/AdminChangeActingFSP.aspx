<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.AdminChnageActingFSP" Codebehind="AdminChangeActingFSP.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="416" border="0">
		<TR>
			<TD colspan="3">
				<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
			</TD>
		</TR>
		<TR>
			<TD width="11" height="26"></TD>
			<TD width="130" height="26"><asp:label id="lblActingFSPID" runat="server" CssClass="FormDEHeader">Acting FSP ID</asp:label></TD>
			<TD height="26"><INPUT class="FormDEField" id="txtFSPID" type="text" size="8" name="txtUserName" runat="server"></TD>
		</TR>
		<TR>
			<TD width="11" height="16"></TD>
			<TD width="130" height="16"></TD>
			<TD height="16">&nbsp;</TD>
		</TR>
		<TR>
			<TD width="11" height="10"></TD>
			<TD width="130" height="10"></TD>
			<TD align="right" height="10"><INPUT class="FormDEButton" id="btnSave" type="submit" value="Save" runat="server" NAME="btnSave"></TD>
		</TR>
		<TR>
			<TD width="11"></TD>
			<TD width="130"></TD>
			<TD align="right"></TD>
		</TR>
	</TABLE>
	<asp:RequiredFieldValidator id="RequiredFieldValidator1" runat="server" ErrorMessage="Please enter Acting FSPID."
		Display="None" ControlToValidate="txtFSPID"></asp:RequiredFieldValidator>
	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:ValidationSummary>
</asp:Content>



