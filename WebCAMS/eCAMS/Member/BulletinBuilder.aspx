
<%@ Page Title="" Language="VB" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.BulletinBuilder" Codebehind="BulletinBuilder.aspx.vb" %>
<%@ Register Assembly="FredCK.FCKeditorV2" Namespace="FredCK.FCKeditorV2" TagPrefix="FCKeditorV2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">


	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
        
		<TR>
			<TD width="10">
			    <asp:Label id="lblTitle" runat="server" CssClass="FormDEHeader">Choose</asp:Label>
			</TD>
			<TD>
                <asp:DropDownList ID="cboBulletin" runat="server" AutoPostBack="True" CssClass="FormDEField">
                </asp:DropDownList>
			</TD>
			<TD width="10"></TD>
		</TR>

		<TR>
			<TD width="10">
			    <asp:Label id="Label4" runat="server" CssClass="FormDEHeader">Title</asp:Label>
			</TD>
			<TD>
                <asp:TextBox ID="txtTitle" runat="server" Width="507px"></asp:TextBox>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10">
			    <asp:Label id="Label1" runat="server" CssClass="FormDEHeader">Detail</asp:Label>
			</TD>

			<TD>
                <FCKeditorV2:FCKeditor ID="txtBody" runat="server" BasePath="~/fckeditor/" Height="500px">
                </FCKeditorV2:FCKeditor>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10">
			    <asp:Label id="Label2" runat="server" CssClass="FormDEHeader">ButtonType</asp:Label>
			</TD>

			<TD>
                <asp:DropDownList ID="cboButtonType" runat="server" CssClass="FormDEField">
                    <asp:ListItem Text="OK" Value=1></asp:ListItem>
                    <asp:ListItem Text="Accept" Value=2></asp:ListItem>
                </asp:DropDownList>
			</TD>
			<TD width="10"></TD>
		</TR>
		<TR>
			<TD width="10">
			    <asp:Label id="Label3" runat="server" CssClass="FormDEHeader">ActionOnDecline</asp:Label>
			</TD>

			<TD>
                <asp:DropDownList ID="cboActionOnDecline" runat="server" CssClass="FormDEField">
                    <asp:ListItem Text="No Action" Value=1></asp:ListItem>
                    <asp:ListItem Text="LogOff" Value=2></asp:ListItem>
                </asp:DropDownList>
			</TD>
			<TD width="10"></TD>
		</TR>

		<TR>
			<TD width="10"></TD>
			<TD align="center">        
                <asp:Button ID="btnSave" runat="server" Text="Save" />
            </TD>
			<TD width="10"></TD>
		</TR>
	</TABLE>

</asp:Content>

