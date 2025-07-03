<%@ Control Language="VB" AutoEventWireup="false" Inherits="UserControl_PageFooter" Codebehind="PageFooter.ascx.vb" %>

<%@ Register Src="~/UserControl/CopyrightLabel.ascx" TagPrefix="custom" TagName="CopyrightLabel" %>


<!--BEGIN PAGE FOOTER-->
		<TABLE id="tblFooter" width="100%">
			<TR>
				<TD class="footer" vAlign="top">
					<custom:CopyrightLabel ID="CopyrightLabel1" runat="server" />
				</TD>
			</TR>
		</TABLE>
<!--END PAGE FOOTER-->