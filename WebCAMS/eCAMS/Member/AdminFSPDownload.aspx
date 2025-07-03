<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.AdminFSPDownload" Codebehind="AdminFSPDownload.aspx.vb" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:UpdatePanel ID="MainUpdatePanel" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
        <ContentTemplate>
            <asp:Panel runat="server" ID="panelNavigation">
                <ul class="ListHorizontal">
                    <li class="FormTitle"><asp:LinkButton id="lbtnUploadFile" runat="server">Upload File</asp:LinkButton></li>
                    <li class="FormTitle"><asp:LinkButton id="lbtnMaintainDownload" runat="server">Maintain Downloads</asp:LinkButton></li>
                    <li class="FormTitle"><asp:LinkButton id="lbtnArchiveFile" runat="server">Archive File</asp:LinkButton></li>
                    <li class="FormTitle"><asp:LinkButton id="lbtnUnarchiveFile" runat="server">Unarchive File</asp:LinkButton></li>
                </ul>
            </asp:Panel>
            <table id="MainTable" cellspacing="1" cellpadding="1" width="520" border="0">
                <tr>
		            <td>
                        <asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>
		            </td>
	            </tr>
                <asp:panel id="panelDetail" runat="server">
                    <asp:Panel id="panelUnarchiveFile" runat="server">
                        <tr>
				            <td width="11"></td>
				            <td>
					            <asp:label id="Label9" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Unarchive File</asp:label>
				            </td>
			            </tr>
                        <tr>
                            <td width="11"></td>
				            <td bgcolor="#eeeeee">
                                <asp:UpdatePanel id="UpdatePanel6" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                                    <ContentTemplate>
                                        <table  id="Table6" style="border-collapse: collapse" cellspacing="0" bgcolor="#eeeeee" border="0">
                                            <tr>
							                    <td width="100">
								                    <asp:label id="Label16" runat="server" CssClass="FormDEHeader">File</asp:label>
							                    </td>
							                    <td colspan="2">
								                    <asp:TreeView ID="treeArchiveDirectory" runat="server" ImageSet="Simple2" ExpandDepth="0" ForeColor="Black" SelectedNodeStyle-BackColor="#0099FF" SelectedNodeStyle-ForeColor="White" SelectedNodeStyle-HorizontalPadding="5" ShowLines="True" />
							                    </td>
						                    </tr>
                                            <tr>
                                                <td>
								                    <asp:label id="Label15" runat="server" CssClass="FormDEHeader"></asp:label>
							                    </td>
                                                <td>
                                                    <asp:DropDownList id="cboFilesUnarchive" runat="server" AutoPostBack="True" Width="304" />
							                    </td>
                                            </tr>
                                            <tr>
                                                <td>
								                    <asp:label id="Label17" runat="server" CssClass="FormDEHeader">New Filename</asp:label>
							                    </td>
                                                <td>
                                                    <asp:TextBox ID="txtUnarchiveName" runat="server" Width="300" /> <asp:Label ID="lblUnarchiveNameExt" runat="server" />
							                    </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="cboFilesUnarchive" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="treeArchiveDirectory" EventName="SelectedNodeChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </asp:Panel>  
                    <asp:Panel id="panelDownloads" runat="server">
                        <tr>
				            <td width="11"></td>
				            <td>
					            <asp:label id="lblDownloadTitle" runat="server" CssClass="FormTitle" BackColor="#eeeeee"></asp:label>
				            </td>
			            </tr>
                        <tr>
				            <td width="11"></td>
				            <td bgcolor="#eeeeee">
                                <asp:UpdatePanel id="UpdatePanel3" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                                    <ContentTemplate>
                                        <table  id="Table3" style="border-collapse: collapse" cellspacing="0" bgcolor="#eeeeee" border="0">
						                    <tr>
							                    <td width="100">
								                    <asp:label id="Label4" runat="server" CssClass="FormDEHeader">Category</asp:label>
							                    </td>
							                    <td colspan="2">
								                    <asp:DropDownList id="cboCategories" runat="server" AutoPostBack="true" Width="304" />
							                    </td>
						                    </tr>
                                            <tr>
							                    <td>
								                    <asp:label id="Label7" runat="server" CssClass="FormDEHeader">Download</asp:label>
							                    </td>
							                    <td colspan="2">
								                    <asp:DropDownList id="cboDownloads" runat="server" AutoPostBack="true" Width="304" />
                                                    <asp:HiddenField ID="txtSeq" runat="server" />
							                    </td>
						                    </tr>
					                    </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostbackTrigger ControlID="btnSave" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
				            </td>
			            </tr>
                        <tr>
				            <td width="11"></td>
				            <td>
					            <asp:label id="Label6" runat="server" CssClass="FormTitle" BackColor="#eeeeee" style="display: inline-block; margin-top: 8px;">Download Details</asp:label>
				            </td>
			            </tr>
                        <tr>
				            <td width="11"></td>
				            <td bgcolor="#eeeeee">
                                <asp:UpdatePanel id="UpdatePanel7" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                                    <ContentTemplate>
                                        <table  id="Table7" style="border-collapse: collapse" cellspacing="0" bgcolor="#eeeeee" border="0">
                                            <tr>
                                                <td width="100">
								                    <asp:label id="Label14" runat="server" CssClass="FormDEHeader">Description</asp:label>
							                    </td>
                                                <td colspan="2">
								                    <asp:TextBox ID="txtDescription" runat="server" Width="300" />
							                    </td>
                                            </tr>
                                            <tr>
                                                <td>
								                    <asp:label id="Label19" runat="server" CssClass="FormDEHeader">Settings</asp:label>
							                    </td>
                                                <td colspan="2">
								                    <asp:CheckBox id="chkIsActive" Checked="true" runat="server" Text="Is Active" />
							                    </td>
                                            </tr>
					                    </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostbackTrigger ControlID="btnSave" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
				            </td>
			            </tr>
                    </asp:Panel>
                    <asp:Panel id="panelArchiveFile" runat="server"></asp:Panel>
                    <asp:Panel id="panelDirectory" runat="server">
                        <tr>
				            <td width="11"></td>
				            <td>
					            <asp:label id="lblDirectoryTitle" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Working Directory</asp:label>
				            </td>
			            </tr>
                        <tr>
                            <td width="11"></td>
                            <td bgcolor="#eeeeee">
                                <asp:UpdatePanel id="UpdatePanel4" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                                    <ContentTemplate>
                                        <table  id="Table4" style="border-collapse: collapse" cellspacing="0" bgcolor="#eeeeee" border="0">
						                    <tr>
							                    <td width="100">
								                    <asp:label id="lblDirectory" runat="server" CssClass="FormDEHeader">Directory</asp:label>
							                    </td>
							                    <td width="200">
								                    <asp:TreeView ID="treeDirectory" runat="server" ImageSet="Simple2" ExpandDepth="0" ForeColor="Black" SelectedNodeStyle-BackColor="#0099FF" SelectedNodeStyle-ForeColor="White" SelectedNodeStyle-HorizontalPadding="5" ShowLines="True" />
							                    </td>
                                                <td>
                                                    <asp:Panel runat="server" ID="panelAddSubdirectory">
                                                        <table>
                                                            <tr>
                                                                <td>
                                                                    <asp:TextBox id="txtDirectoryName" placeholder="Subdirectory Name" runat="server"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <asp:Button CssClass="FormDEButton" id="btnAddDirectory" Text="Add Subdirectory" runat="server" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                </td>
						                    </tr>
                                            <asp:Panel runat="server" ID="panelSelectFile">
                                                <tr>
                                                    <td width="100">
								                        <asp:label id="lblFileSelect" runat="server" CssClass="FormDEHeader"></asp:label>
							                        </td>
                                                    <td colspan="2">
                                                        <asp:DropDownList id="cboFiles" runat="server" AutoPostBack="true" Width="304" />
							                        </td>
                                                </tr>
                                            </asp:Panel>
                                        </table>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </asp:Panel>
                    <asp:Panel id="panelFiles" runat="server">
                        <tr>
				            <td width="11"></td>
				            <td>
					            <asp:label id="Label11" runat="server" CssClass="FormTitle" BackColor="#eeeeee"></asp:label>
				            </td>
			            </tr>
                        <tr>
				            <td width="11"></td>
				            <td bgcolor="#eeeeee">
                                <asp:UpdatePanel id="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                                    <ContentTemplate>
                                        <table  id="Table2" style="border-collapse: collapse" cellspacing="0" bgcolor="#eeeeee" border="0">
                                            <tr>
							                    <td width="100">
								                    <asp:label id="Label1" runat="server" CssClass="FormDEHeader">File</asp:label>
							                    </td>
							                    <td colspan="2">
								                    <asp:FileUpload id="fuFile" runat="server" />
							                    </td>
						                    </tr>
                                            <tr>
                                                <td>
								                    <asp:label id="Label2" runat="server" CssClass="FormDEHeader">Options</asp:label>
							                    </td>
                                                <td>
								                    <asp:CheckBox id="chkOverwrite" runat="server" Text="Overwrite if exists" />
							                    </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td colspan="2" style="padding-top: 5px">
                                                    <asp:Label id="Label8" runat="server" CssClass="FormDEHeader">
                                                        Allowed File Types: <%=ConfigurationManager.AppSettings("Download.AllowedFileTypes") %> | 
                                                        Max File Size (MB): <%=ConfigurationManager.AppSettings("Download.MaxFileSizeMB") %>
                                                    </asp:Label>
                                                </td>
                                            </tr>
					                    </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:PostBackTrigger ControlID="btnSaveWithPostback" />
                                    </Triggers>
                                </asp:UpdatePanel>
				            </td>
			            </tr>
                    </asp:Panel>
                    <asp:Panel id="panelAssociatedDownloads" runat="server">
                        <tr>
				            <td width="11"></td>
				            <td>
					            <asp:label id="Label18" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Associated Downloads</asp:label>
				            </td>
			            </tr>
                        <tr>
                            <td width="11"></td>
                            <td>
                                <asp:UpdatePanel id="UpdatePanel2" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                                    <ContentTemplate>
                                        <asp:datagrid id="grdDownloads" runat="server" CssClass="FormGrid" CellPadding="4" Width="100%" GridLines="None">
					                        <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					                        <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
				                        </asp:datagrid>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="cboFilesUnarchive" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="cboFiles" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </asp:Panel>
                </asp:panel>
                <tr>
                    <td width="11"></td>
                    <td colspan="2" bgcolor="#eeeeee">
                        <asp:UpdatePanel runat="server">
                            <ContentTemplate>
                                <asp:Label runat="server" id="lblStatus"></asp:Label>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </td>
                </tr>
                <tr>
                    <td width="11"></td>
                    <td>
                        <table width="100%">
                            <tr>
                                <td width="50%">
                                    <asp:UpdateProgress id="updateProgress" runat="server">
                                        <ProgressTemplate>
                                            <span style="background-color: yellow">Loading...</span>
                                        </ProgressTemplate>
                                    </asp:UpdateProgress>
                                </td>
                                <td align="right">
                                    <asp:Button CssClass="FormDEButton" style="width: 60px" id="btnSaveWithPostback" Text="Save" runat="server" />
                                    <asp:Button CssClass="FormDEButton" style="width: 60px" id="btnSave" Text="Save" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="lbtnUploadFile" />
            <asp:AsyncPostBackTrigger ControlID="treeDirectory" EventName="SelectedNodeChanged" />
            <asp:AsyncPostbackTrigger ControlID="btnAddDirectory" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="lbtnMaintainDownload" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="lbtnArchiveFile" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="lbtnUnarchiveFile" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="cboDownloads" EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="cboCategories" EventName="SelectedIndexChanged" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>