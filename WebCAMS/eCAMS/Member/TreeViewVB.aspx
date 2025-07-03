<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.TreeViewVB" Codebehind="TreeViewVB.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
    <ContentTemplate>			        
	<TABLE id="Table2" cellSpacing="1" cellPadding="1" width="100%" border="0">
		<TR>
			<TD width="10"></TD>
			<TD>
				<P class="MemberInfo"><asp:hyperlink id="SearchAgainURL" runat="server" CssClass="MemberInfo" NavigateUrl="http://localhost:4247/ReadDoc.aspx?obj=YFF0iTkb%2fVRoRLfC%2b4vVoA%3d%3d" Target="ifmMyDoc">HyperLink</asp:hyperlink>::&nbsp;&gt;&gt;&nbsp;
					<asp:label id="lblListInfo" runat="server" CssClass="MemberInfo"></asp:label></P>
			</TD>
			<TD width="500"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD vAlign="top" height="600">
                <asp:TreeView  
                    ID="TreeView1"
                    ExpandDepth="0" 
                    PopulateNodesFromClient="true" 
                    ShowLines="true" 
                    ShowExpandCollapse="true"
                    runat="server" />
                &nbsp;
            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
			</TD>
			<TD vAlign="top" width="100%" height="800">
				<iframe id="ifmMyDoc" name="ifmMyDoc" frameBorder="yes" width="100%" scrolling="auto" height="100%" >
				</iframe>
			</TD>
		</TR>
	</TABLE>
    </ContentTemplate>
    <Triggers>
    </Triggers>
</asp:UpdatePanel>					

</asp:Content>


