<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.master" CodeBehind="FSPJob.aspx.vb" Inherits="eCAMS.FSPJob" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:HiddenField ID="txtClientID" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
    <ContentTemplate>					

	<TABLE id="Table1" cellSpacing="1" cellPadding="1" width="688" border="0">
		<TR>
			<TD colSpan="3"><asp:label id="lblFormTitle" runat="server" CssClass="FormTitle">Job Clsoure</asp:label><asp:hyperlink id="SearchAgainURL" runat="server" CssClass="MemberInfo" NavigateUrl="FSPJobList.aspx"
					Width="40px"></asp:hyperlink></TD>
		</TR>
		<asp:panel id="panelDetail" runat="server">
			<TR>
				<TD width="11"></TD>
				<TD>
					<asp:label id="Label11" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Job Details</asp:label>
					<asp:placeholder id="placeholderJob" runat="server"></asp:placeholder></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD bgColor="#eeeeee">
					<TABLE  id="Table2" style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
						<TR>
							<TD>
								<asp:label id="Label12" runat="server" CssClass="FormDEHeader">JobID</asp:label></TD>
							<TD>
								<asp:textbox id="txtJobIDDE" runat="server" CssClass="FormDEField" Width="96px"></asp:textbox>
								<asp:HiddenField ID="txtJobID" runat="server" /> <INPUT class="FormDEButton" id="btnGetJob" type="submit" value="Get Job" name="btnGetJob"
									runat="server"></TD>
							<TD></TD>
						</TR>
						<TR>
							<TD>
								<asp:label id="Label13" runat="server" CssClass="FormDEHeader">JobType</asp:label></TD>
							<TD>
								<asp:textbox id="txtJobType" runat="server" CssClass="FormDEField" Width="96px" ReadOnly="True"></asp:textbox></TD>
							<TD></TD>
						</TR>
						<TR>
							<TD>
								<asp:label id="Label14" runat="server" CssClass="FormDEHeader">Merchant</asp:label></TD>
							<TD>
								<asp:textbox id="txtMerchant" runat="server" CssClass="FormDEField" Width="376px" ReadOnly="True"></asp:textbox></TD>
							<TD></TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			<asp:panel id="panelException" runat="server">
				<TR>
					<TD width="11"></TD>
					<TD>
						<asp:label id="Label17" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Exception</asp:label></TD>
				</TR>
				<TR>
					<TD width="11"></TD>
					<TD bgColor="#eeeeee">
						<TABLE id="Table3" style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
							<TR>
								<TD colSpan="2">
									<asp:label id="Label10" runat="server" CssClass="FormDEHint">Please click "Edit" or "Delete" links in JobDevice section below to correct the serial number. <br>
								If the exception can not be corrected, please enter serial no. into notes - serial no. will be passed to EE Service Desk for investigation.<br>
								After all details have been corrected or entered, please click on "Save Changes" below to confirm.
								</asp:label></TD>
							</TR>
							<TR>
								<TD colSpan="2">
									<asp:PlaceHolder id="placeholderException" runat="server"></asp:PlaceHolder>
									<asp:datagrid id="grdException" runat="server" CssClass="FormGrid">
					                    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					                    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
									</asp:datagrid></TD>
							</TR>
						</TABLE>
					</TD>
				</TR>
			</asp:panel>
			<TR>
				<TD width="11"></TD>
				<TD><!--fff4c2 -->
					<asp:label id="Label1" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Job Device</asp:label>
					</TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD bgColor="#eeeeee">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>					
					<TABLE  id="Table4"  style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
					    <tr>
					        <td colspan="5">
					            <asp:PlaceHolder id="placeholderDevice" runat="server"></asp:PlaceHolder>
					        </td>
					    </tr>
						<TR>
							<TD colSpan="5">
								<asp:label id="Label15" runat="server" CssClass="FormDEHint">Click Edit to update a device, click Delete to delete a device</asp:label>
						    </TD>
						</TR>
						<TR>
							<TD colSpan="5">
								<asp:datagrid id="grd" runat="server" CssClass="FormDEGrid" AutoGenerateColumns="False">
									<SelectedItemStyle BackColor="PaleGoldenrod"></SelectedItemStyle>
									<AlternatingItemStyle BackColor="#e5ecf9"></AlternatingItemStyle>
									<HeaderStyle BackColor="LightSteelBlue"></HeaderStyle>
									<Columns>
										<asp:EditCommandColumn ButtonType="LinkButton" UpdateText="Update" CancelText="Cancel" EditText="Edit"></asp:EditCommandColumn>
										<asp:ButtonColumn Text="Delete" CommandName="Delete"></asp:ButtonColumn>
										<asp:BoundColumn DataField="Action" ReadOnly="True" HeaderText="Action"></asp:BoundColumn>
										<asp:BoundColumn DataField="Serial" HeaderText="Serial"></asp:BoundColumn>
										<asp:BoundColumn DataField="Device" ReadOnly="True" HeaderText="Device"></asp:BoundColumn>
                                        <asp:BoundColumn DataField="Damaged" ReadOnly="True" HeaderText="Damaged"></asp:BoundColumn>
                                        <asp:ButtonColumn Text="MerchantDamaged" CommandName="MerchantDamaged"></asp:ButtonColumn>
									</Columns>
								</asp:datagrid></TD>
						</TR>
						<TR>
							<TD colSpan="5">
								<asp:label id="Label21" runat="server" CssClass="FormDEHint">Add additional devices</asp:label></TD>
						</TR>
						<TR>
							<TD>
								<asp:label id="Label3" runat="server" CssClass="FormDEHeader">DeviceOut</asp:label></TD>
							<TD>
								<asp:textbox id="txtDeviceOut" runat="server" CssClass="FormDEField" Width="220px"></asp:textbox></TD>
							<TD>
								<asp:label id="Label4" runat="server" CssClass="FormDEHeader">DeviceIn</asp:label></TD>
							<TD>
								<asp:textbox id="txtDeviceIn" runat="server" CssClass="FormDEField" Width="220px"></asp:textbox></TD>
							<TD><INPUT class="FormDEButton" id="btnAddDevice" type="submit" value="Add Device" name="btnAddDevice"
									runat="server"></TD>
						</TR>
					</TABLE>
                        </ContentTemplate>
                        <Triggers>
<%--                            <asp:AsyncPostBackTrigger ControlID="grd" EventName="CancelCommand" />
                            <asp:AsyncPostBackTrigger ControlID="grd" EventName="EditCommand" />
                            <asp:AsyncPostBackTrigger ControlID="grd" EventName="DeleteCommand" />
                            <asp:AsyncPostBackTrigger ControlID="grd" EventName="UpdateCommand" />
--%>                            <asp:AsyncPostBackTrigger ControlID="grd" EventName="ItemCommand" />
                            <asp:AsyncPostBackTrigger ControlID="btnAddDevice" EventName="ServerClick" />
                        </Triggers>
                    </asp:UpdatePanel>	  					
				</TD>
			</TR>
			<asp:panel id="panelJobParts" runat="server">

			<TR>
				<TD width="11"></TD>
				<TD><!--fff4c2 -->
					<asp:label id="Label8" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Job Parts</asp:label>
					</TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD bgColor="#eeeeee">
                    <asp:UpdatePanel ID="UpdatePanel4" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>					
					<TABLE  id="Table6"  style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
					    <tr>
					        <td colspan="5">
					            <asp:PlaceHolder id="placeholderParts" runat="server"></asp:PlaceHolder>
					        </td>
					    </tr>
						<TR>
							<TD colSpan="5">
								<asp:label id="Label16" runat="server" CssClass="FormDEHint">Click Delete to delete a parts</asp:label>
						    </TD>
						</TR>
						<TR>
							<TD colSpan="5">
								<asp:datagrid id="grdParts" runat="server" CssClass="FormDEGrid" AutoGenerateColumns="False">
									<SelectedItemStyle BackColor="PaleGoldenrod"></SelectedItemStyle>
									<AlternatingItemStyle BackColor="#e5ecf9"></AlternatingItemStyle>
									<HeaderStyle BackColor="LightSteelBlue"></HeaderStyle>
									<Columns>
										<asp:ButtonColumn Text="Delete" CommandName="Delete"></asp:ButtonColumn>
										<asp:BoundColumn DataField="PartID" ReadOnly="True" HeaderText="PartID"></asp:BoundColumn>
										<asp:BoundColumn DataField="Qty" ReadOnly="True" HeaderText="Quantity"></asp:BoundColumn>
										<asp:BoundColumn DataField="Device" ReadOnly="True" HeaderText="Device"></asp:BoundColumn>
									</Columns>
								</asp:datagrid></TD>
						</TR>
						<TR>
							<TD colSpan="5">
								<asp:label id="Label18" runat="server" CssClass="FormDEHint">Add additional parts</asp:label></TD>
						</TR>
						<TR>
							<TD>
								<asp:label id="Label19" runat="server" CssClass="FormDEHeader">Parts</asp:label></TD>
							<TD colSpan="4">
							    <asp:dropdownlist id="cboParts" runat="server" CssClass="FormDEField"></asp:dropdownlist>
							    <asp:textbox id="txtQty" runat="server" CssClass="FormDEField" Width="20px"></asp:textbox>
                                &nbsp;&nbsp;<INPUT class="FormDEButton" id="btnAddParts" type="submit" value="Add Parts" name="btnAddParts"
									runat="server">
							</TD>
							<TD></TD>
						</TR>
                     <asp:panel id="panelConfirmKittedPartsUsage" runat="server">
						<TR>
							<TD colSpan="5">
                                    <asp:Label ID="Label29" runat="server" forecolor="red" font="bold" Text="Kitted device is used for the job. I acknowledge that kitted parts being used are entered correctly."></asp:Label>
							</TD>
							<TD><INPUT class="FormDEButton" id="btnConfirmKittedPartsUsage" type="submit" value="Confirm" name="btnConfirmKittedPartsUsage"
									runat="server"></TD>
						</TR>
                     </asp:panel>

					</TABLE>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="grdParts" EventName="DeleteCommand" />
                            <asp:AsyncPostBackTrigger ControlID="btnAddParts" EventName="ServerClick" />
                        </Triggers>
                    </asp:UpdatePanel>	  					
				</TD>
			</TR>
            </asp:Panel>
            <asp:panel id="panelSIMSwap" runat="server" Visible="False">

			<TR>
				<TD width="11"></TD>
				<TD><!--fff4c2 -->
					<asp:label id="Label31" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Bundled SIM Swap</asp:label>
					</TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD bgColor="#eeeeee">
                    <asp:UpdatePanel ID="UpdatePanel8" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>
                            <TABLE  id="Table10"  style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
                                <tr>
					                <td colspan="5">
					                    <asp:PlaceHolder id="placeholderSIMSwap" runat="server"></asp:PlaceHolder>
                                        <asp:label id="lblSIMSwapSuccessful" runat="server" CssClass="FormDESuccess" Visible="False">
                                            SIM's Swapped Successfully!
                                        </asp:label>
					                </td>
					            </tr>
                                <TR>
							        <TD>
								        <asp:label id="Label32" runat="server" CssClass="FormDEHeader">SIM Out</asp:label></TD>
							        <TD>
								        <asp:textbox id="txtSIMOut" runat="server" CssClass="FormDEField" Width="220px"></asp:textbox></TD>
							        <TD>
								        <asp:label id="Label33" runat="server" CssClass="FormDEHeader">SIM In</asp:label></TD>
							        <TD>
								        <asp:textbox id="txtSIMIn" runat="server" CssClass="FormDEField" Width="220px"></asp:textbox></TD>
							        <TD><INPUT class="FormDEButton" id="btnUpdateSIM" type="submit" value="Update SIM" name="btnUpdateSIM"
									        runat="server"></TD>
						        </TR>
                            </TABLE>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnUpdateSIM" EventName="ServerClick" />
                        </Triggers>
                    </asp:UpdatePanel>
				</TD>
			</TR>
            </asp:Panel>
			<asp:panel id="panelClosure" runat="server">
                <!--JobSheet-->
				<TR>
					<TD width="11"></TD>
					<TD><!-- e5ecf9 -->
						<asp:label id="Label2" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Upload Merchant Signed JobSheet</asp:label>
					</TD>
				</TR>
				<TR>
					<TD width="11"></TD>
					<TD bgColor="#eeeeee">
                        <asp:label id="Label26" runat="server" CssClass="FormDEHint">Scan the jobsheet in image or pdf format. The file size must be less than 4M</asp:label>
					</TD>
				</TR>
				<TR>
					<TD width="11"></TD>
					<TD bgColor="#eeeeee">
                    <asp:UpdatePanel ID="UpdatePanel5" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>					
						<TABLE  id="Table7" style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
							<TR>
								<TD colSpan="4">
									<asp:label id="lblAsynUpload_Err" runat="server" CssClass="FormDEError" BackColor="#eeeeee"></asp:label>
								</TD>
							</TR>						

							<TR>
								<TD width="96" height="26">
                                    <asp:label id="Label23" runat="server" CssClass="FormDEHeader">JobSheet</asp:label></TD>
								<TD colSpan="3">
                                    <asp:AsyncFileUpload ID="fuJobSheet" runat="server" OnClientUploadComplete="uploadComplete" />
									</TD>
							</TR>
						</TABLE>
                    <script type="text/javascript">
                        function uploadComplete(sender, args) {
                            var contentType = args.get_contentType();
                            var fileSize = args.get_length();
                            //debugger;

                            var lbl = document.getElementById("<%= lblAsynUpload_Err.ClientID %>");
                            lbl.innerHTML = ""; //clean up
                            if (!(contentType.substring(0, 6) == "image/" || contentType.substring(contentType.length - 4) == "/pdf")) {
                                lbl.innerHTML = "Invalid file content type - must be image or pdf";
                            }

                            if (fileSize > 5000000000) {
                                lbl.innerHTML = "Invalid file size - must less than 4M.";
                            }

                        }
                    </script>
                        </ContentTemplate>
                    </asp:UpdatePanel>	 						
					</TD>
				</TR>
                <!--FSP Add Job Notes-->
				<TR>
					<TD width="11"></TD>
					<TD><!-- e5ecf9 -->
						<asp:label id="Label28" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Add Job Notes</asp:label>
					</TD>
				</TR>
				<TR>
					<TD width="11"></TD>
					<TD bgColor="#eeeeee">
                    <asp:UpdatePanel ID="UpdatePanel7" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>					

						<TABLE  id="Table9" style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
							<TR>
								<TD colSpan="4">
									<asp:PlaceHolder id="placeholderAddJobNotes" runat="server"></asp:PlaceHolder>
								</TD>
							</TR>						
							<TR>
								<TD colSpan="4">
									<asp:label id="Label30" runat="server" CssClass="FormDEHint">Job Notes. Max 200 characters</asp:label></TD>
							</TR>
							<TR>
								<TD colSpan="4">
									<asp:textbox id="txtJobNotes" runat="server" Width="552px" Rows="3" TextMode="MultiLine" class="txtwithcounter" charlimit="200" charlimitinfo="Span3"></asp:textbox>
                                    <INPUT class="FormDEButton" id="btnAddJobNotes" style="WIDTH: 92px; HEIGHT: 24px" type="submit" value="Add Job Notes" name="btnAddJobNotes" runat="server">
                                    <br /><span id="Span3" class="charlimitinfo"></span> 
								</TD>
							</TR>
						</TABLE>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnAddJobNotes" EventName="ServerClick" /> 
                        </Triggers>
                    </asp:UpdatePanel>	 						
					</TD>
				</TR>

                <!--Survey-->
				<TR>
					<TD width="11"></TD>
					<TD><!-- e5ecf9 -->
						<asp:label id="Label20" runat="server" CssClass="FormTitle" BackColor="#eeeeee">JobClosure Site Survey</asp:label>
					</TD>
				</TR>

				<TR>
					<TD width="11"></TD>
					<TD bgColor="#eeeeee">
                    <asp:UpdatePanel ID="UpdatePanel3" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>					

						<TABLE  id="Table5" style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
							<TR>
								<TD colSpan="4">
									<asp:PlaceHolder id="placeholderClosure" runat="server"></asp:PlaceHolder>
								</TD>
							</TR>						
							<TR>
								<TD colSpan="4">
                                    <table>
                                        <asp:HiddenField ID="txtSurveyID" runat="server" />
                                        <asp:Panel ID="panelSurvey" runat="server">
                                        </asp:Panel>
                                    </table>
									
								</TD>
							</TR>		
                            				
							<TR>
								<TD colSpan="4">
									<asp:label id="Label9" runat="server" CssClass="FormDEHint">Datetime format: dd/mm/yy hhmm, and in merchant's local time</asp:label></TD>
							</TR>
							<TR>
								<TD width="96" height="26">
									<asp:label id="Label5" runat="server" CssClass="FormDEHeader">OnSiteDateTime</asp:label></TD>
								<TD width="160" height="26">
									<asp:textbox id="txtOnSiteDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
									<asp:textbox id="txtOnSiteTime" runat="server" CssClass="FormDEField" Width="60px"></asp:textbox></TD>
								<TD width="95" height="26">
									<asp:label id="Label6" runat="server" CssClass="FormDEHeader">OffSiteDateTime</asp:label></TD>
								<TD width="160" height="26">
									<asp:textbox id="txtOffSiteDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
									<asp:textbox id="txtOffSiteTime" runat="server" CssClass="FormDEField" Width="60px"></asp:textbox></TD>
							</TR>
							<TR>
								<TD width="96" height="42">
									<asp:label id="Label7" runat="server" CssClass="FormDEHeader">Options</asp:label></TD>
								<TD colSpan="3" height="42">
									<asp:dropdownlist id="cboTechFix" runat="server" Width="328px" AutoPostBack="true"></asp:dropdownlist></TD>
							</TR>
                            <TR>
                                <TD colspan="4">
                                    <asp:Panel ID="missingPartsPanel" runat="server" Visible="false">
                                        <span>Please select the missing components:</span>
                                        <p><asp:CheckBoxList ID="chkMissingParts" runat="server"></asp:CheckBoxList></p>
                                    </asp:Panel>
                                </TD>
                            </TR>
							<TR>
								<TD colSpan="4">
									<asp:label id="Label22" runat="server" CssClass="FormDEHint">Closure Notes. Max 200 characters</asp:label></TD>
							</TR>
							<TR>
								<TD colSpan="4">
									<asp:textbox id="txtNotes" runat="server" Width="552px" Rows="3" TextMode="MultiLine" class="txtwithcounter" charlimit="200" charlimitinfo="Span1"></asp:textbox>
                                    <INPUT class="FormDEButton" id="btnClose" style="WIDTH: 92px; HEIGHT: 24px" type="submit" value="Save Changes" name="btnClose" runat="server">
                                    <br /><span id="Span1" class="charlimitinfo"></span> 
								</TD>
							</TR>
						</TABLE>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnClose" EventName="ServerClick" /> 
                            <asp:AsyncPostBackTrigger ControlID="cboTechFix" EventName="SelectedIndexChanged" /> 
                        </Triggers>
                    </asp:UpdatePanel>	 						
					</TD>
				</TR>
                <!--Escalate-->
				<TR>
					<TD width="11"></TD>
					<TD><!-- e5ecf9 -->
						<asp:label id="Label24" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Escalate This Job</asp:label>
					</TD>
				</TR>
				<TR>
					<TD width="11"></TD>
					<TD bgColor="#eeeeee">
                    <asp:UpdatePanel ID="UpdatePanel6" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>					

						<TABLE  id="Table8" style="BORDER-COLLAPSE: collapse" cellSpacing="0" bgColor="#eeeeee" border="0">
							<TR>
								<TD colSpan="4">
									<asp:PlaceHolder id="placeholderEscalateJob" runat="server"></asp:PlaceHolder>
								</TD>
							</TR>						

							<TR>
								<TD width="96" height="42">
									<asp:label id="Label25" runat="server" CssClass="FormDEHeader">Reason</asp:label></TD>
								<TD colSpan="3" height="42">
									<asp:dropdownlist id="cboEscalateReason" runat="server" Width="328px"></asp:dropdownlist></TD>
							</TR>
							<TR>
								<TD colSpan="4">
									<asp:label id="Label27" runat="server" CssClass="FormDEHint">Escalation Notes. Max 200 characters</asp:label></TD>
							</TR>
							<TR>
								<TD colSpan="4">
									<asp:textbox id="txtEscalateNotes" runat="server" Width="552px" Rows="3" TextMode="MultiLine" class="txtwithcounter" charlimit="200" charlimitinfo="Span2"></asp:textbox>
                                    <INPUT class="FormDEButton" id="btnEscalateJob" style="WIDTH: 92px; HEIGHT: 24px" type="submit" value="Escalate Job" name="btnEscalateJob" runat="server">
                                    <br /><span id="Span2" class="charlimitinfo"></span> 
								</TD>
							</TR>
						</TABLE>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnEscalateJob" EventName="ServerClick" /> 
                        </Triggers>
                    </asp:UpdatePanel>	 						
					</TD>
				</TR>
			</asp:panel>
		</asp:panel>
	</TABLE>
    </ContentTemplate>
    <Triggers>
        <asp:AsyncPostBackTrigger ControlID="btnGetJob" EventName="ServerClick" />
        <asp:AsyncPostBackTrigger ControlID="btnClose" EventName="ServerClick" />
        <asp:AsyncPostBackTrigger ControlID="btnUpdateSIM" EventName="ServerClick" />
    </Triggers>
</asp:UpdatePanel>	  					
	
	<asp:requiredfieldvalidator id="rfvDeviceIn" runat="server" ErrorMessage="Please enter DeviceIn serial number."
		Display="None" Enabled="False" ControlToValidate="txtDeviceIn"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvDeviceOut" runat="server" ErrorMessage="Please enter DeviceOut serial number."
		Display="None" Enabled="False" ControlToValidate="txtDeviceOut"></asp:requiredfieldvalidator>

    <asp:requiredfieldvalidator id="rfvSIMIn" runat="server" ErrorMessage="Please enter SIM In serial number."
		Display="None" Enabled="False" ControlToValidate="txtSIMIn"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvSIMOut" runat="server" ErrorMessage="Please enter SIM Out serial number."
		Display="None" Enabled="False" ControlToValidate="txtSIMOut"></asp:requiredfieldvalidator>

    <asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary><asp:customvalidator id="cvOnSiteDate" runat="server" ErrorMessage="Invalid OnSiteDate" Display="None"
		Enabled="False" ControlToValidate="txtOnSiteDate" ClientValidationFunction="VerifyDate"></asp:customvalidator><asp:customvalidator id="cvOnSiteTime" runat="server" ErrorMessage="Invalid OnSiteTime" Display="None"
		Enabled="False" ControlToValidate="txtOnSiteTime" ClientValidationFunction="VerifyTime"></asp:customvalidator><asp:requiredfieldvalidator id="rfvOnSiteDate" runat="server" ErrorMessage="Please enter OnSiteDate" Display="None"
		Enabled="False" ControlToValidate="txtOnSiteDate"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvOnSiteTime" runat="server" ErrorMessage="Please enter OnSiteTime" Display="None"
		Enabled="False" ControlToValidate="txtOnSiteTime"></asp:requiredfieldvalidator><asp:customvalidator id="cvOffSiteDate" runat="server" ErrorMessage="Invalid OffSiteDate" Display="None"
		Enabled="False" ControlToValidate="txtOffSiteDate" ClientValidationFunction="VerifyDate"></asp:customvalidator><asp:customvalidator id="cvOffSiteTime" runat="server" ErrorMessage="Invalid OffSiteTime" Display="None"
		Enabled="False" ControlToValidate="txtOffSiteTime" ClientValidationFunction="VerifyTime"></asp:customvalidator><asp:requiredfieldvalidator id="rfvOffSiteDate" runat="server" ErrorMessage="Please enter OffSiteDate" Display="None"
		Enabled="False" ControlToValidate="txtOffSiteDate"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvOffSiteTime" runat="server" ErrorMessage="Please enter OffSiteTime" Display="None"
		Enabled="False" ControlToValidate="txtOffSiteTime"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvNotes" runat="server" ErrorMessage="Please enter Notes" Display="None" Enabled="False"
		ControlToValidate="txtNotes"></asp:requiredfieldvalidator><asp:requiredfieldvalidator id="rfvJobID" runat="server" ErrorMessage="Please enter Job ID." Display="None"
		Enabled="False" ControlToValidate="txtJobIDDE"></asp:requiredfieldvalidator><asp:customvalidator id="cvPartsQty" runat="server" ErrorMessage="Invalid Parts Qty" Display="None"
		Enabled="False" ControlToValidate="txtQty" ClientValidationFunction="VerifyPositiveIntegerOrZero"></asp:customvalidator><asp:requiredfieldvalidator id="rfvcvPartsQty" runat="server" ErrorMessage="Please enter Parts Qty." Display="None"
		Enabled="False" ControlToValidate="txtQty"></asp:requiredfieldvalidator>
        <asp:requiredfieldvalidator id="rfvEscalateNote" runat="server" ErrorMessage="Please enter Escalation Notes" Display="None" Enabled="False" ControlToValidate="txtEscalateNotes"></asp:requiredfieldvalidator>
        <asp:requiredfieldvalidator id="rfvJobNotes" runat="server" ErrorMessage="Please enter Job Notes" Display="None" Enabled="False" ControlToValidate="txtJobNotes"></asp:requiredfieldvalidator>
        <asp:customvalidator id="cvMissingParts" runat="server" ErrorMessage="Must select a missing part" Display="None" Enabled="False" ClientValidationFunction="ValidateMissingParts"></asp:customvalidator>
	<script language="javascript">
				<!--
	    function IsJobExisting() {
	        //debugger
	        if (document.getElementById("<%=txtJobID.ClientID%>").value.length == 0) {
	            return false;
	        }
	        return true;
	    }

	    function ResetAllValidators() {
	        //				could use Page_Validators[] generated on client


	        ValidatorEnable(document.getElementById("<%=rfvDeviceIn.ClientID%>"), false);
            ValidatorEnable(document.getElementById("<%=rfvDeviceOut.ClientID%>"), false);
            ValidatorEnable(document.getElementById("<%=rfvSIMIn.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvSIMOut.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvOnSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvOnSiteTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOnSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOnSiteTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvOffSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvOffSiteTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOffSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOffSiteTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvNotes.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvJobID.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvPartsQty.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvcvPartsQty.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvEscalateNote.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvJobNotes.ClientID%>"), false);
	    }

	    function SetJobValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvJobID.ClientID%>"), true);
	    }

	    function SetDeviceValidator() {  //debugger

	        ResetAllValidators();

	        ValidatorEnable(document.getElementById("<%=rfvDeviceIn.ClientID%>"), !document.getElementById('<%=txtDeviceIn.ClientID%>').disabled);
	        ValidatorEnable(document.getElementById("<%=rfvDeviceOut.ClientID%>"), !document.getElementById('<%=txtDeviceOut.ClientID%>').disabled);

	        if (document.getElementById('<%=txtJobType.ClientID%>').value == 'UPGRADE') {
	            if (document.getElementById('<%=txtDeviceIn.ClientID%>').value.length > 0 || document.getElementById('<%=txtDeviceOut.ClientID%>').value.length > 0) {
	                ValidatorEnable(document.getElementById('<%=rfvDeviceIn.ClientID%>'), false);
	                ValidatorEnable(document.getElementById('<%=rfvDeviceOut.ClientID%>'), false);
	            }
	        }
	        //verify if jobid has been retrieved, otherwise, ask user to enter jobid
	        if (!IsJobExisting())
	            SetJobValidator();


        }

        function SetSIMValidator() {  //debugger

	        ResetAllValidators();

	        ValidatorEnable(document.getElementById("<%=rfvSIMIn.ClientID%>"), !document.getElementById('<%=txtSIMIn.ClientID%>').disabled);
	        ValidatorEnable(document.getElementById("<%=rfvSIMOut.ClientID%>"), !document.getElementById('<%=txtSIMOut.ClientID%>').disabled);
            
	        //verify if jobid has been retrieved, otherwise, ask user to enter jobid
	        if (!IsJobExisting())
	            SetJobValidator();
	    }

	    function SetPartsValidator() {  //debugger

	        ResetAllValidators();

	        ValidatorEnable(document.getElementById("<%=cvPartsQty.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvcvPartsQty.ClientID%>"), true);
	        //verify if jobid has been retrieved, otherwise, ask user to enter jobid
	        if (!IsJobExisting())
	            SetJobValidator();


	    }

	    function SetEscalateValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvEscalateNote.ClientID%>"), true);
	    }
	    function SetJobNotesValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvJobNotes.ClientID%>"), true);
	    }

	    function SetClosureValidator() {
	        //debugger

	        ResetAllValidators();

	        ValidatorEnable(document.getElementById("<%=cvOnSiteDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=cvOnSiteTime.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvOnSiteDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvOnSiteTime.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=cvOffSiteDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=cvOffSiteTime.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvOffSiteDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvOffSiteTime.ClientID%>"), true);


	        //verify if jobid has been retrieved, otherwise, ask user to enter jobid
	        if (!IsJobExisting())
	            SetJobValidator();

	    }

	    function CopyOnSiteDateToOffSiteDate() {
	        if (document.getElementById('<%=txtOnSiteDate.ClientID%>').value.length > 0 && document.getElementById('<%=txtOffSiteDate.ClientID%>').value.length == 0) {
	            document.getElementById('<%=txtOffSiteDate.ClientID%>').value = document.getElementById('<%=txtOnSiteDate.ClientID%>').value;
	        }
	    }
	    //trigger validation prior confirm to submit
        //check if OnSite is after hour & ask user to confirm
	    function IsOnSiteAfterHourStopper() {
	        if (document.getElementById('<%=txtOnSiteTime.ClientID%>').value.length > 0 && (document.getElementById('<%=txtOnSiteTime.ClientID%>').value < '0800' || document.getElementById('<%=txtOnSiteTime.ClientID%>').value > '1800')) {
                //debugger;
	        	return !confirm('OnSiteTime is after hour. Are you sure to proceed?');
	        }
	        else {
	        	return false;
	        }
        }

        function ValidateMissingParts(source, args) {
            args.IsValid = ValidateCheckedAtLeastOne('<%=chkMissingParts.ClientID %>');
        }
	// -->
	</script>
</asp:Content>

