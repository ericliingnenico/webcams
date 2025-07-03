<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.Member" Codebehind="Member.aspx.vb" %>

<%@ Register Src="../UserControl/UserPasswordAlert.ascx" TagName="UserPasswordAlert"
    TagPrefix="uc1" %>
		<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
				<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
					<TR>
						<TD width="10"></TD>
						<TD class="PageHeader">
							<P><B>Welcome to CAMS Web Portal</B>
							</P>
							<P>
                                <uc1:UserPasswordAlert ID="UserPasswordAlert1" runat="server" />
                                &nbsp;</P>
							<P>&nbsp;</P>
							<P>&nbsp;</P>
						</TD>
						<TD width="10"></TD>
					</TR>
				</TABLE>
		</asp:Content>



