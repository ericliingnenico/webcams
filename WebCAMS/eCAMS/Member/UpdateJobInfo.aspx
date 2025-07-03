<%@ Page Language="VB" MasterPageFile="~/MemberPopupMasterPage.master" AutoEventWireup="false" Inherits="Member_UpdateJobInfo" title="Untitled Page" Codebehind="UpdateJobInfo.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
				<TABLE id="Table2" style="WIDTH: 559px; HEIGHT: 286px" cellSpacing="1" cellPadding="1"
					width="559" border="0">
					<TR>
						<TD colspan=3>
							<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
						</TD>
					</TR>
            <asp:Panel ID="panelDetails" runat="server">
			    <asp:Panel ID="panelUpdateInfo" runat="server" >
                
                </asp:Panel>
                            
					<TR>
						<TD  colspan=2>
                            
                        </TD>
						<TD align=left>
							<asp:Button ID="btnSubmit" runat="server" Text="Submit" />&nbsp;
						</TD>
					</TR>
            </asp:Panel>

				</TABLE>

    

</asp:Content>

