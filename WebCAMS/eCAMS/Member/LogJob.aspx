<%@ Page Language="vb" MasterPageFile="~/MemberMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.LogJob" EnableEventValidation="false" Codebehind="LogJob.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<!-- Online HelpTip -->
    <asp:Panel ID="panelHelpTipMID" runat="server" class="help"  style="display:none;">
            <asp:Literal ID="ltlHelpTipMID" runat="server" Text=""></asp:Literal>
    </asp:Panel>
    <asp:Panel ID="panelHelpTipPhone" runat="server" class="help"  style="display:none;">
            <asp:Literal ID="ltlHelpTipPhone" runat="server" Text=""></asp:Literal>
    </asp:Panel>
    <asp:Panel ID="panelHelpTradingHours" runat="server" class="help"  style="display:none;">
            <asp:Literal ID="ltlHelpTradingHours" runat="server" Text=""></asp:Literal>
    </asp:Panel>
<!-- Online HelpTip  -->
	<TABLE id="Table2" style="WIDTH: 520px; HEIGHT: 152px" cellSpacing="1" cellPadding="1"
		width="520" border="0" >
        <tr>
            <td>
                <asp:Label ID="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>
                <asp:HiddenField ID="txtClientID" runat="server" />
                <asp:HiddenField ID="txtJobTypeID" runat="server" />
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <asp:PlaceHolder ID="placeholderMsg" runat="server"></asp:PlaceHolder>
            </td>
        </tr>
		<asp:panel id="panelTIDPage" runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="86" height="26">
					<asp:Label id="lblClientID" runat="server" CssClass="FormDEHeader">Client ID</asp:Label></TD>
				<TD height="26">
					<asp:DropDownList id="cboClientID" runat="server" CssClass="FormDEField" Width="130px"></asp:DropDownList></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="lblTID" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtTID" runat="server" CssClass="FormDEField" size="10"></asp:textbox><asp:label id="lblTIDHint" runat="server" CssClass="FormDEHint"></asp:label></TD>
			</TR>
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="130" height="10"></TD>
				<TD align="left" height="30" style="margin-top:30px;"><input class="FormDEButton" id="btnTIDGo" type="submit" value=" GO " name="btnTIDGo" runat="server"/></TD>
			</TR>
		</asp:panel>
		<asp:panel id="panelFullPage" runat="server">
			<asp:panel id="panelUpgradeJob" runat="server">
				<TR>
					<TD width="11" height="26"></TD>
					<TD width="130" height="26">
						<asp:label id="Label24" runat="server" CssClass="FormDEHeader">Old TerminalID</asp:label></TD>
					<TD height="26">
						<asp:textbox id="txtOldTerminalID" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
				</TR>
				<TR>
					<TD width="11" height="26"></TD>
					<TD width="130" height="26">
						<asp:label id="Label25" runat="server" CssClass="FormDEHeader">Old Terminal Type</asp:label></TD>
					<TD height="26">
						<asp:dropdownlist id="cboOldDeviceType" runat="server" CssClass="FormDEField"></asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
				</TR>
			</asp:panel>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="lblTerminalID" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtTerminalID" runat="server" CssClass="FormDEField" size="10" onkeypress="return isNumberAnd_Key(event)"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
            <asp:panel id="panelFDIAdditionalInfo" visible="False" runat="server">
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="150" height="26">
					    <asp:label id="Label50" runat="server" CssClass="FormDEHeader">Customer Number</asp:label></TD>
				    <TD height="26">
                        <asp:textbox id="txtCustomerNumber1" runat="server" CssClass="FormDEField" size="20"></asp:textbox></TD>
			    </TR>
            </asp:panel>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label2" runat="server" CssClass="FormDEHeader">Ref No</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtProblemNumber" runat="server" CssClass="FormDEField" size="20"></asp:textbox><div id="divProblemNumber" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div></TD>
			</TR>
            <asp:panel id="panelProjectNo" visible="False" runat="server">
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="150" height="26">
					    <asp:label id="lblProjectNo" runat="server" CssClass="FormDEHeader">Project No</asp:label></TD>
				    <TD height="26">
						<asp:dropdownlist id="cboProjectNo" runat="server" AutoPostBack="True"  CssClass="FormDEField"></asp:dropdownlist>
					</TD>
			    </TR>
            </asp:panel>
			<asp:panel id="panelJobMethodAndTerminalType" runat="server">
				<TR>
					<TD width="11" height="26"></TD>
					<TD width="130" height="26">
						<asp:label id="lblJobMethod" runat="server" CssClass="FormDEHeader">Job Method</asp:label></TD>
					<TD height="26">
						<asp:dropdownlist id="cboJobMethod" runat="server" AutoPostBack="True" OnSelectedIndexChanged="cboJobMethod_SelectedIndexChanged" CssClass="FormDEField"></asp:dropdownlist>
						<div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
				</TR>
				<TR>
					<TD width="11" height="26"></TD>
					<TD width="130" height="26">
						<asp:label id="Label4" runat="server" CssClass="FormDEHeader">Terminal Type</asp:label></TD>
					<TD height="26">
						<asp:dropdownlist id="cboDeviceType" runat="server" CssClass="FormDEField"></asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
				</TR>
			</asp:panel>
			<asp:panel id="panelCallTypeSymptomFault" runat="server">
		        <TR>
			        <TD colspan="3">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>			        
	                    <TABLE id="Table1" border="0" >
                            <tr>
                                <td width="96" height="26">
                                    <asp:Label ID="Label26" runat="server" CssClass="FormDEHeader">Terminal Type</asp:Label></td>
                                <td height="26">
                                    <asp:DropDownList ID="cboCallType" runat="server" CssClass="FormDEField" AutoPostBack="true"></asp:DropDownList><div class="FormMandatory" style="display: inline; width: 7px; height: 15px">*</div>
                                </td>
                            </tr>
                            <tr>
                                <td width="96" height="26">
                                    <asp:Label ID="Label27" runat="server" CssClass="FormDEHeader">Symptom</asp:Label></td>
                                <td height="26">
                                    <asp:DropDownList ID="cboSymptom" runat="server" CssClass="FormDEField" AutoPostBack="true"></asp:DropDownList><div class="FormMandatory" style="display: inline; width: 7px; height: 15px">*</div>
                                </td>
                            </tr>
                            <tr>
								
                                <td width="96" height="26">						
                                    <asp:Label ID="lblErrorCode" runat="server" CssClass="FormDEHeader">Error Code</asp:Label></td>
                                <td height="26">
									<br />
                                    <asp:DropDownList ID="cboFault" runat="server" CssClass="FormDEField"></asp:DropDownList>
						<asp:Label ID="lblErrorCodeQty" runat="server" >&nbsp;&nbsp;&nbsp;Qty</asp:Label>
        <asp:DropDownList ID="ddlQuantity" runat="server" CssClass="FormDEField" AutoPostBack="true">
        </asp:DropDownList>

        <asp:Button ID="btnAddErroCode" runat="server" Text="Add" OnClick="BtnAddErroCode_Click" CausesValidation="false" />
									<asp:Label ID="lblErrorCodeLine" runat="server"><hr color= "#f0f0f0" /></asp:Label>
			<!-- GridView to display selected skills and levels -->
				<asp:GridView ID="gvErrorCodes" runat="server" ShowHeaderWhenEmpty="True" AutoGenerateColumns="False" OnRowCommand="GvErrorCodes_RowCommand" DataKeyNames="FaultID">
					<Columns>
						<asp:BoundField DataField="FaultID" HeaderText="FaultID" Visible="false" />
						<asp:BoundField DataField="ErrorCode" HeaderText="Added Parts List">
							<HeaderStyle Width="350px" />
							<ItemStyle Width="350px" />
						</asp:BoundField>
						<asp:BoundField DataField="Quantity" HeaderText="Qty">
							<HeaderStyle Width="50px" />
							<ItemStyle Width="50px" />
						</asp:BoundField>
						<asp:ButtonField CommandName="Remove" Text="Remove" ButtonType="Button" />
					</Columns>
				</asp:GridView>
				<asp:Label ID="lblErrorCodeMessage" runat="server" ForeColor="Red"></asp:Label>
 
                                    <asp:Label ID="lblErrorCodeFormMandatory" runat="server" CssClass="FormMandatory">*</asp:Label>
                                </td>
                            </tr>

                        </TABLE>	
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="cboCallType" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cboSymptom" EventName="SelectedIndexChanged" />

						<asp:AsyncPostBackTrigger ControlID="btnAddErroCode" EventName="Click" />
						<asp:AsyncPostBackTrigger ControlID="gvErrorCodes" EventName="RowCommand" />

                        </Triggers>
                    </asp:UpdatePanel>	                    				        
                     </TD>
		        </TR>					
			</asp:panel>
			<asp:panel id="panelAdditionalServiceType" runat="server">
				<TR>
					<TD width="11" height="26"></TD>
					<TD width="130" height="26">
						<asp:label id="Label30" runat="server" CssClass="FormDEHeader">Additional Service</asp:label></TD>
					<TD height="26">
						<asp:dropdownlist id="cboAdditionalServiceType" runat="server" CssClass="FormDEField"></asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
				</TR>
			</asp:panel>
            <asp:panel id="panelCAIC" visible=false runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label41" runat="server" CssClass="FormDEHeader">CAIC</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtCAIC" runat="server" CssClass="FormDEField" size="20"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
            </asp:panel>

            <asp:panel id="panelCustomerName" visible="False" runat="server">
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="150" height="26">
					    <asp:label id="Label49" runat="server" CssClass="FormDEHeader">Customer Name</asp:label></TD>
				    <TD height="26">
						<asp:dropdownlist id="cboCustomerName" runat="server" AutoPostBack="True"  CssClass="FormDEField"></asp:dropdownlist>
					</TD>
			    </TR>
            </asp:panel>

			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label3" runat="server" CssClass="FormDEHeader">MerchantID</asp:label></TD>
				<TD height="26">
					<asp:label id="lblMIDPrefix" runat="server" CssClass="FormDEHeader" Visible=false>535310</asp:label><asp:textbox id="txtMerchantID" runat="server" size="16" class="helptip" helptipid="" onkeypress="return isNumberKey(event)"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label5" runat="server" CssClass="FormDEHeader">Merchant Name</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtName" runat="server" CssClass="FormDEField" size="50"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label6" runat="server" CssClass="FormDEHeader">Trading Address1</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtAddress" runat="server" CssClass="FormDEField" size="50"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label7" runat="server" CssClass="FormDEHeader">Trading Address2</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtAddress2" runat="server" CssClass="FormDEField" size="50"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label8" runat="server" CssClass="FormDEHeader">Suburb</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtCity" runat="server" onblur="handleSurburbAndPostcodeBlur();" CssClass="FormDEField" size="50"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label11" runat="server" CssClass="FormDEHeader">State</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboState" runat="server" CssClass="FormDEField"></asp:dropdownlist><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label9" runat="server" onblur="handleSurburbAndPostcodeBlur();" CssClass="FormDEHeader">Postcode</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtPostcode" runat="server" CssClass="FormDEField" size="10"></asp:textbox><div class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label31" runat="server" CssClass="FormDEHeader">Region</asp:label></TD>
				<TD height="26">
					<INPUT class="FormDEField" id="txtRegion" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
								type="text" size="15" name="txtRegion" runat="server" readonly="readOnly"></TD>
			</TR>

		    <tr>
                <td colspan="3">
                    <asp:UpdatePanel ID="UpdatePanelSurburbAndPostcode" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                        <ContentTemplate>
                            <table id="Table22" border="0">
                                <asp:Panel ID="panelServiceStatus" Visible="false" runat="server">
                                    <tr>
                                        <td width="96" height="26">
                                            <asp:Label ID="Label29" runat="server" CssClass="FormDEHeader">Service Status</asp:Label></td>
                                        <td height="26">
                                            <input class="FormDEField" id="txtServiceStatus" style="border-top-style: none; border-right-style: none; border-left-style: none; border-bottom-style: none" type="text" size="15" name="txtServiceStatus" runat="server" readonly="readOnly" /></td>
                                    </tr>
                                </asp:Panel>
                            </table>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="txtPostcode" EventName="TextChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </td>
            </tr>

			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label10" runat="server" CssClass="FormDEHeader">Contact Name</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtContact" runat="server" CssClass="FormDEField" size="50"></asp:textbox><div id="divContact" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label12" runat="server" CssClass="FormDEHeader">Phone1</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtPhoneNumber" runat="server" size="15" class="helptip"  onpaste="handlePhoneNumberPaste(event, this)" onkeypress="return isNumberKey(event)" helptipid=""></asp:textbox><div id="divPhone1" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div></TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label13" runat="server" CssClass="FormDEHeader">Phone2</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtPhoneNumber2" runat="server" size="15" class="helptip" onpaste="handlePhoneNumberPaste(event, this)" onkeypress="return isNumberKey(event)" helptipid=""></asp:textbox></TD>
			</TR>

            <asp:panel id="panelNABAdditionalInfo" visible="false" runat="server">
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="Label42" runat="server" CssClass="FormDEHeader">NABContactEmail</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtContactEmail" runat="server" CssClass="FormDEField" size="50"></asp:textbox></TD>
			    </TR>
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="Label43" runat="server" CssClass="FormDEHeader">BankersEmail</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtBankersEmail" runat="server" CssClass="FormDEField" size="50"></asp:textbox></TD>
			    </TR>
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="Label44" runat="server" CssClass="FormDEHeader">MerchantEmail</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtMerchantEmail" runat="server" CssClass="FormDEField" size="50"></asp:textbox><div id="div1" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=true>*</div></TD>
			    </TR>
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="150" height="26">
					    <asp:label id="Label45" runat="server" CssClass="FormDEHeader">CustomerNumber</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtCustomerNumber" runat="server" CssClass="FormDEField" size="20"></asp:textbox><div id="div2" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=true>*</div></TD>
			    </TR>
                <TR>
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="Label46" runat="server" CssClass="FormDEHeader">AltMerchantID</asp:label></TD>
				    <TD height="26">
					    <asp:textbox id="txtAltMerchantID" runat="server" CssClass="FormDEField" size="20"></asp:textbox><div id="div3" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=true>*</div></TD>
			    </TR>
            </asp:panel>

			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label28" runat="server" CssClass="FormDEHeader">BusinessActivity</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtBusinessActivity" runat="server" CssClass="FormDEField" size="40"></asp:textbox></TD>
			</TR>
            <asp:panel id="panelTransendID" visible=false runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label38" runat="server" CssClass="FormDEHeader">TransendID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtTransendID" runat="server" CssClass="FormDEField" size="40"></asp:textbox></TD>
			</TR>
            
            </asp:panel>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label32" runat="server" CssClass="FormDEHeader">Job Notes</asp:label><br/>
					<asp:label id="Label33" runat="server" CssClass="FormDEHint">(Max:400 characters)</asp:label></TD>
				<TD height="78">
					<asp:textbox id="txtJobNote" runat="server" size="100" TextMode="MultiLine" Columns="100" MaxLength="400" Rows="4" class="txtwithcounter" charlimit="400" charlimitinfo="Span1"></asp:textbox>
                    <br /><span id="Span1" class="charlimitinfo"></span> 
                </TD>
			</TR>
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label14" runat="server" CssClass="FormDEHeader">SpecialInstruction</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtSpecInstruct" runat="server" CssClass="FormDEField" size="103"></asp:textbox></TD>
			</TR>
            <TR>  
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label15" runat="server" CssClass="FormDEHeader">Urgent</asp:label></TD>
				<TD height="26">
					<asp:CheckBox id="chbUrgent" runat="server" CssClass="FormDEField" Checked="False" Text=""></asp:CheckBox></TD>
            </TR>
            <asp:panel id="panelLostStolen" visible="False" runat="server">
                <TR>  
				    <TD width="11" height="26"></TD>
				    <TD width="130" height="26">
					    <asp:label id="Label48" runat="server" CssClass="FormDEHeader">Lost/Stolen</asp:label></TD>
				    <TD height="26">
					    <asp:CheckBox id="chbLostStolen" runat="server" CssClass="FormDEField" Checked="False" Text=""></asp:CheckBox>
                       <asp:label id="lblLostStolenSel" runat="server" CssClass="FormDEHint">(Only select if no replacement terminal required)</asp:label></TD>
			</TR>
                </TR>
            </asp:panel>
            <asp:panel id="panelSiteEquiptment" visible="False" runat="server">
                <TR>
				    <TD width="11" height="17"></TD>
				    <TD vAlign="top" width="134" height="17">
					    <asp:label id="Label47" runat="server" CssClass="FormDEHeader">Site Equiptment</asp:label></TD>
				    <TD align="left" height="17">
					    <asp:datagrid id="grdSiteEquiptment" runat="server" CssClass="FormGrid">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
			    </TR>
            </asp:panel>
            <!-- colspan="2" -->
            <asp:panel id="panelTechAtt" runat="server">
			    <TR>
                    <TD width="11" height="26"></TD>
                    <TD colspan="2" width="130" height="26">
					  <asp:label id="lblTechToAttWithoutCall" runat="server" CssClass="FormDEHeader">Tech To Attend Without Calling </asp:label>
                      <asp:CheckBox id="chbTechToAttWithoutCall" runat="server" CssClass="FormDEField" Checked="False" Text=""></asp:CheckBox></TD>
                </TR>	
		    </asp:panel>
			<asp:panel id="panelInstallDate" runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label17" runat="server" CssClass="FormDEHeader">Install Date</asp:label></TD>
				<TD height="36">
					<asp:textbox id="txtInstallDate" runat="server" CssClass="FormDEField" size="10"></asp:textbox>
					<div id="divInstallDate" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px">*</div>
					<asp:label id="Label18" runat="server" CssClass="FormDEHint">(Format: dd/mm/yy)</asp:label></TD>
			</TR>
			</asp:panel>
	        <TR>
		        <TD colspan="3">
                <!-- Need to put the whole junk into a separate table for Ajax to work properly-->
                <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                    <ContentTemplate>	
	                    <TABLE id="Table3" border="0" > 
			            <asp:panel id="panelGetTradingHoursFromSite" runat="server">
		                    <TR>
			                    <TD colspan="2">
				                    <asp:label id="Label40" runat="server" CssClass="FormDEHeader">Get TradingHours from Site </asp:label>
				                    <asp:Button ID="btnGetTradingHoursFromSite" runat="server" Text="Go" OnClientClick="ResetAllValidators();" />
				                </TD>
		                    </TR>
			            </asp:panel>
		                    <TR>
			                    <TD width="100" height="26">
                                    <asp:label id="Label19" runat="server" CssClass="FormDEHeader">Trading Hours</asp:label><br><div id="divTradingHourMFHint" runat="server" class="FormDEHint" visible=false>enter "CLOSED" if no trading MF</div>				                    
                                </TD>
			                    <TD height="52" >
				                    <asp:label id="Label21" width="25" runat="server" CssClass="FormDEHeader">Mon:</asp:label>
				                    <asp:textbox id="txtTradingHoursMon" runat="server" class="helptip" helptipid="" size="12"></asp:textbox><div id="divTradingHourMon" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
				                    <asp:label id="Label34" width="25" runat="server" CssClass="FormDEHeader">Tue:</asp:label>
				                    <asp:textbox id="txtTradingHoursTue" runat="server" class="helptip" helptipid="" size="12"></asp:textbox><div id="divTradingHourTue" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
				                    <asp:label id="Label35" width="25" runat="server" CssClass="FormDEHeader">Wed:</asp:label>
				                    <asp:textbox id="txtTradingHoursWed" runat="server" class="helptip" helptipid="" size="12"></asp:textbox><div id="divTradingHourWed" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
				                    <asp:label id="Label36" width="25" runat="server" CssClass="FormDEHeader">Thu:</asp:label>
				                    <asp:textbox id="txtTradingHoursThu" runat="server" class="helptip" helptipid="" size="12"></asp:textbox><div id="divTradingHourThu" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>
									<br />
				                    <asp:label id="Label37" width="25" runat="server" CssClass="FormDEHeader" style="margin-top:10px;">Fri:</asp:label>
				                    <asp:textbox id="txtTradingHoursFri" runat="server" class="helptip" helptipid="" size="12"></asp:textbox><div id="divTradingHourFri" runat="server" class="FormMandatory" style="DISPLAY: inline; WIDTH: 7px; HEIGHT: 15px" visible=false>*</div>

				                    <asp:label id="Label22" width="25" runat="server" CssClass="FormDEHeader">Sat:</asp:label>
				                    <asp:textbox id="txtTradingHoursSat" runat="server" class="helptip" helptipid="" size="12"></asp:textbox>
				                    <asp:label id="Label23" width="25" runat="server" CssClass="FormDEHeader">Sun:</asp:label>
				                    <asp:textbox id="txtTradingHoursSun" runat="server" class="helptip" helptipid="" size="12"></asp:textbox>
				                    <asp:label id="Label20" runat="server" CssClass="FormDEHint">(Format: hhmm-hhmm)</asp:label>
			                    
				                </TD>
		                    </TR>
	                    </TABLE>	

                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnGetTradingHoursFromSite" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>	                    				        

                 </TD>
	        </TR>			
           <asp:Panel ID="PanelUpdateSiteTradingHours" runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD colspan="2">
					<asp:label id="Label39" runat="server" CssClass="FormDEHeader">Update the site record with the above trading hours </asp:label>
					<asp:CheckBox id="chkUpdateSiteTradingHours" runat="server" CssClass="FormDEField" Checked="True" Text=""></asp:CheckBox></TD>
			</TR>
           </asp:Panel>

			<asp:Panel ID="panelCommsMethod" runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label16" runat="server" CssClass="FormDEHeader">Comms Method</asp:label></TD>
				<TD height="26">
				    <asp:dropdownlist id="cboLineType" runat="server" CssClass="FormDEField">
					    <asp:ListItem Value="">UNKNOWN</asp:ListItem>
					    <asp:ListItem Value="GPRS">GPRS</asp:ListItem>
					    <asp:ListItem Value="Broadband">Broadband</asp:ListItem>
                        <asp:ListItem Value="Dialup">Dialup</asp:ListItem>
                        <asp:ListItem Value="Argent">Argent</asp:ListItem>
				    </asp:dropdownlist>
                </TD>
			</TR>
			</asp:Panel>

			<asp:Panel ID="panelDialPrefix" runat="server">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="130" height="26">
					<asp:label id="Label1" runat="server" CssClass="FormDEHeader">DialPrefix</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtDialPrefix" runat="server" CssClass="FormDEField" size="10"></asp:textbox></TD>
			</TR>
			</asp:Panel>
		    <asp:Panel ID="panelFeature" runat="server">
            </asp:Panel>
		    <asp:Panel ID="panelComponent" runat="server">
            </asp:Panel>            
			<TR>
				<TD width="11" height="10"></TD>
				<TD width="130" height="10"></TD>
				<TD align="left" height="40" style="vertical-align: bottom;">
					<input type="submit"  class="FormDEButton" id="btnSave" value="Submit" name="btnSave" runat="server" />
				</TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="130"></TD>
				<TD align="right"></TD>
			</TR>
		</asp:panel>
		<asp:panel id="panelAcknowledge" runat="server">
			<TR>
				<TD width="10"></TD>
				<TD colspan="2" align="left">
					<asp:label id="lblAcknowledge" runat="server" CssClass="MemberInfo"></asp:label></TD>
				<TD width="10"></TD>
			</TR>		
		
		</asp:panel>

	</TABLE>
	
	<asp:RequiredFieldValidator id="rfvTID" runat="server" ErrorMessage="Please enter TerminalID." ControlToValidate="txtTID"
		Display="None"></asp:RequiredFieldValidator>
	<asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"
		Width="152px"></asp:ValidationSummary>
    <asp:RequiredFieldValidator ID="rfvTerminalID" runat="server" ControlToValidate="txtTerminalID"
        Display="None" ErrorMessage="Please enter TerminalID."></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvDeviceType" runat="server" ErrorMessage="Please choose a device type." ControlToValidate="cboDeviceType" Display="None" InitialValue=""></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvCallType" runat="server" ErrorMessage="Please choose a terminal type." ControlToValidate="cboCallType" Display="None" InitialValue="0"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvSymptom" runat="server" ErrorMessage="Please choose a symptom." ControlToValidate="cboSymptom" Display="None" InitialValue="0"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvFault" runat="server" ErrorMessage="Please choose a default error code." ControlToValidate="cboFault" Display="None" InitialValue="0"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvCAIC" runat="server" ErrorMessage="Please enter CAIC." Display="None" ControlToValidate="txtCAIC"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvMerchantID" runat="server" ErrorMessage="Please enter MerchantID." Display="None" ControlToValidate="txtMerchantID"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvProblemNumber" runat="server" ErrorMessage="Please enter Ref No." Display="None" ControlToValidate="txtProblemNumber"></asp:RequiredFieldValidator>    
    <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Please enter Merchant Name." Display="None" ControlToValidate="txtName"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ErrorMessage="Please enter Trading Address1." ControlToValidate="txtAddress" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvAddress2" runat="server" ErrorMessage="Please enter Trading Address2." ControlToValidate="txtAddress2" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvCity" runat="server" ErrorMessage="Please enter Trading Suburb." ControlToValidate="txtCity" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvPostcode" runat="server" ErrorMessage="Please enter Trading Postcode." ControlToValidate="txtPostcode" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvContact" runat="server" ErrorMessage="Please enter Trading Contact." ControlToValidate="txtContact" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvPhoneNumber" runat="server" ErrorMessage="Please enter Trading Phone1." ControlToValidate="txtPhoneNumber" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvInstallDate" runat="server" ErrorMessage="Please enter Install Date." ControlToValidate="txtInstallDate" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvOldTerminalID" runat="server" ErrorMessage="Please enter Old TerminalID." ControlToValidate="txtOldTerminalID" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvErrorCode" runat="server" ErrorMessage="Please enter error code." ControlToValidate="cboFault" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursMon" runat="server" ErrorMessage="Please enter trading hours Mon." ControlToValidate="txtTradingHoursMon" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursTue" runat="server" ErrorMessage="Please enter trading hours Tue." ControlToValidate="txtTradingHoursTue" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursWed" runat="server" ErrorMessage="Please enter trading hours Wed." ControlToValidate="txtTradingHoursWed" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursThu" runat="server" ErrorMessage="Please enter trading hours Thu." ControlToValidate="txtTradingHoursThu" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursFri" runat="server" ErrorMessage="Please enter trading hours Fri." ControlToValidate="txtTradingHoursFri" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursSat" runat="server" ErrorMessage="Please enter trading hours Sat." ControlToValidate="txtTradingHoursSat" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvTradingHoursSun" runat="server" ErrorMessage="Please enter trading hours Sun." ControlToValidate="txtTradingHoursSun" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvMerchantEmail" runat="server" ErrorMessage="Please enter Merchant Email." ControlToValidate="txtMerchantEmail" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvCustomerNumber" runat="server" ErrorMessage="Please enter Customer Number." ControlToValidate="txtCustomerNumber" Display="None"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="rfvAltMerchantID" runat="server" ErrorMessage="Please enter Alt. Merchant ID." ControlToValidate="txtAltMerchantID" Display="None"></asp:RequiredFieldValidator>

<script language="javascript">
		
				function ResetAllValidators()
				{
//				could use Page_Validators[] generated on client


					ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvMerchantID.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvProblemNumber.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvAddress2.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvContact.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvPhoneNumber.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvInstallDate.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvOldTerminalID.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvErrorCode.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursMon.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursTue.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursWed.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursThu.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursFri.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursSat.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvTradingHoursSun.ClientID%>"), false);
					
					//regular expression
					ValidatorEnable(document.getElementById("<%=cvTradingHoursMon.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursTue.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursWed.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursThu.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursFri.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursSat.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=cvTradingHoursSun.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=revInstallDate.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=revTerminalIDBoQ.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=revOldTerminalIDBoQ.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=revMerchantIDBoQ.ClientID%>"), false);
					
					ValidatorEnable(document.getElementById("<%=cvTH.ClientID%>"), false);
				    ValidatorEnable(document.getElementById("<%=cvSWApp.ClientID%>"), false);

				    ValidatorEnable(document.getElementById("<%=revTerminalIDCBA.ClientID%>"), false);
				    ValidatorEnable(document.getElementById("<%=rfvCAIC.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=revMerchantIDCBA.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=revMerchantIDTYR.ClientID%>"), false);

				    ValidatorEnable(document.getElementById("<%=rfvDeviceType.ClientID%>"), false);
				    ValidatorEnable(document.getElementById("<%=rfvCallType.ClientID%>"), false);
				    ValidatorEnable(document.getElementById("<%=rfvSymptom.ClientID%>"), false);
                    ValidatorEnable(document.getElementById("<%=rfvFault.ClientID%>"), false);

                    ValidatorEnable(document.getElementById("<%=rfvMerchantEmail.ClientID%>"), false);
                    ValidatorEnable(document.getElementById("<%=rfvCustomerNumber.ClientID%>"), false);
					ValidatorEnable(document.getElementById("<%=rfvAltMerchantID.ClientID%>"), false);
				}
				
				function SetJobValidator()
				{
					ResetAllValidators();
                    //debugger
                    //special for BOQ
                    switch (document.getElementById("<%=txtClientID.ClientID%>").value) {
                        case "CBA":
                            ValidatorEnable(document.getElementById("<%=revTerminalIDCBA.ClientID%>"), true);
                            if (document.getElementById("<%=txtJobTypeID.ClientID%>").value != 2) {
                                ValidatorEnable(document.getElementById("<%=rfvCAIC.ClientID%>"), true);
                                ValidatorEnable(document.getElementById("<%=revMerchantIDCBA.ClientID%>"), true);
                            }
                            if (document.getElementById("<%=txtJobTypeID.ClientID%>").value == 1 || document.getElementById("<%=txtJobTypeID.ClientID%>").value == 4) {
                                ValidatorEnable(document.getElementById("<%=rfvProblemNumber.ClientID%>"), true);
                            }
                            break;
                    case "BOQ":
                     	ValidatorEnable(document.getElementById("<%=revTerminalIDBoQ.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=revMerchantIDBoQ.ClientID%>"), true);

                        switch (document.getElementById("<%=txtJobTypeID.ClientID%>").value)
					    {
					     case "3":
					        ValidatorEnable(document.getElementById("<%=revOldTerminalIDBoQ.ClientID%>"), true);
					        break;
    					 
					     default:
					        break;

                        }
					    break;

                    case "NAB":
                        ValidatorEnable(document.getElementById("<%=rfvProblemNumber.ClientID%>"), true);

                        switch (document.getElementById("<%=txtJobTypeID.ClientID%>").value)
					    {
					        case "2":
                                ValidatorEnable(document.getElementById("<%=rfvMerchantEmail.ClientID%>"), true);
                                ValidatorEnable(document.getElementById("<%=rfvCustomerNumber.ClientID%>"), true);
                                ValidatorEnable(document.getElementById("<%=rfvAltMerchantID.ClientID%>"), true);
					            break;
    					 
					        default:
					            break;

                        }
                        break;

                    case "HIC":
					    ValidatorEnable(document.getElementById("<%=rfvProblemNumber.ClientID%>"), true);					    
							break;

					case "TYR":
						if (document.getElementById("<%=txtJobTypeID.ClientID%>").value == 1 ||
							document.getElementById("<%=txtJobTypeID.ClientID%>").value == 2 ||
							document.getElementById("<%=txtJobTypeID.ClientID%>").value == 3) 
						{
							ValidatorEnable(document.getElementById("<%=revMerchantIDTYR.ClientID%>"), true);                        
                       	}                      
                        break;
					 
					 default:
					    break;
					 
					}

					//debugger
					switch (document.getElementById("<%=txtJobTypeID.ClientID%>").value)
					{
					 case "1":
					    //install jobs
					    ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvMerchantID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvContact.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvPhoneNumber.ClientID%>"), true);

					    if (document.getElementById("<%=txtClientID.ClientID%>").value != "CBA" && document.getElementById("<%=txtClientID.ClientID%>").value != "BOQ") {
					        ValidatorEnable(document.getElementById("<%=rfvInstallDate.ClientID%>"), true);
					    }
					    ValidatorEnable(document.getElementById("<%=revInstallDate.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvDeviceType.ClientID%>"), true);
					    break;

					 case "2":
					    //deinstall
					    ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvMerchantID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvDeviceType.ClientID%>"), true);
					    break;

					case "3":
					    //upgrade
					    ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvMerchantID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvOldTerminalID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvContact.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvPhoneNumber.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvDeviceType.ClientID%>"), true);
					    
                        if (document.getElementById('<%=chbUrgent.ClientID%>').checked) {
                            ValidatorEnable(document.getElementById("<%=rfvTradingHoursMon.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=rfvTradingHoursTue.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=rfvTradingHoursWed.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=rfvTradingHoursThu.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=rfvTradingHoursFri.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=cvTradingHoursMon.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=cvTradingHoursTue.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=cvTradingHoursWed.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=cvTradingHoursThu.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=cvTradingHoursFri.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=cvTradingHoursSat.ClientID%>"), true);
                            ValidatorEnable(document.getElementById("<%=cvTradingHoursSun.ClientID%>"), true);

					    }
					    break;
					 
					 case "4":
					    ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvMerchantID.ClientID%>"), true);
    					ValidatorEnable(document.getElementById("<%=rfvTradingHoursMon.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursTue.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursWed.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursThu.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursFri.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursMon.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursTue.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursWed.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursThu.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursFri.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursSat.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursSun.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), true);
					    
					    ValidatorEnable(document.getElementById("<%=cvTH.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvSWApp.ClientID%>"), true);

					    ValidatorEnable(document.getElementById("<%=rfvCallType.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvSymptom.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvFault.ClientID%>"), true);
					    break;

					 case "5":
					    ValidatorEnable(document.getElementById("<%=rfvTerminalID.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvMerchantID.ClientID%>"), true);
    					ValidatorEnable(document.getElementById("<%=rfvTradingHoursMon.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursTue.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursWed.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursThu.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvTradingHoursFri.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursMon.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursTue.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursWed.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursThu.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursFri.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursSat.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=cvTradingHoursSun.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvName.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvAddress.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvCity.ClientID%>"), true);
					    ValidatorEnable(document.getElementById("<%=rfvPostcode.ClientID%>"), true);
					    break;
					 
					 default:
					    break;
					 
					}
				}
				function CopyTradingHoursMF(pWeekDay) 
				{
				    var tradinghourDefaultVal = '';
				    //debugger;
				    switch (pWeekDay)
				    {
				        case 1:
				        //use monday value
				            if (document.getElementById('<%=txtTradingHoursMon.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursMon.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursMon.ClientID%>').value;
				            }
				        case 2:
				        //use tuesday value
				            if (document.getElementById('<%=txtTradingHoursTue.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursTue.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursTue.ClientID%>').value;
				            }
				        case 3:
				        //use wednesday value
				            if (document.getElementById('<%=txtTradingHoursWed.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursWed.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursWed.ClientID%>').value;
				            }
				        case 4:
				        //use thursday value
				            if (document.getElementById('<%=txtTradingHoursThu.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursThu.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursThu.ClientID%>').value;
				            }
				        case 5:
				        //use friday value
				            if (document.getElementById('<%=txtTradingHoursFri.ClientID%>').value.length > 0 && validateTradingHours(document.getElementById('<%=txtTradingHoursFri.ClientID%>').value))
				            {
				                tradinghourDefaultVal = document.getElementById('<%=txtTradingHoursFri.ClientID%>').value;
				            }
                        default:
                            break;                            				        
				    }
				    
					if (tradinghourDefaultVal.length > 0)
					{
					    //if there is a default value, fill the empty trading hours with the default value
					    if (document.getElementById('<%=txtTradingHoursMon.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursMon.ClientID%>').value = tradinghourDefaultVal;
						}
					
					    if (document.getElementById('<%=txtTradingHoursTue.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursTue.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursWed.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursWed.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursThu.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursThu.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursFri.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursFri.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursSat.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursSat.ClientID%>').value = tradinghourDefaultVal;
						}
					    if (document.getElementById('<%=txtTradingHoursSun.ClientID%>').value.length == 0)  
					    {
						    document.getElementById('<%=txtTradingHoursSun.ClientID%>').value = tradinghourDefaultVal;
						}

					}
				}	

	            //used by customised validator
	            //Make sure that at least one TradingHours entered on swapcall
	            //or value = close
	            function IsAnyTradingHourEntered(source, args) {
		            args.IsValid = (validateTradingHours(document.getElementById('<%=txtTradingHoursMon.ClientID%>').value) || 
		                            validateTradingHours(document.getElementById('<%=txtTradingHoursTue.ClientID%>').value) ||
		                            validateTradingHours(document.getElementById('<%=txtTradingHoursWed.ClientID%>').value) || 
		                            validateTradingHours(document.getElementById('<%=txtTradingHoursThu.ClientID%>').value) ||
		                            validateTradingHours(document.getElementById('<%=txtTradingHoursFri.ClientID%>').value) || 
		                            validateTradingHours(document.getElementById('<%=txtTradingHoursSat.ClientID%>').value) ||
		                            validateTradingHours(document.getElementById('<%=txtTradingHoursSun.ClientID%>').value));
	            } //function IsAnyTradingHours
            	
	            //Make sure that at least one SoftwareApplications selected on swapcall
	            function IsAnySWAppSelected(source, args) {
		            //debugger
		            args.IsValid = validateSofwareApplicationSelection(document);
	            } //function IsAnySWAppSelected(source, args), attached to txtTradingHoursMon due to SoftwareApplications is dynamically rendering
                //trigger validation prior confirm to submit
	            function ConfirmWithValidation(msg) {
	                if (additionalValidation()) {
	                    SetJobValidator();
	                    if (Page_ClientValidate()) {
	                        return confirm(msg);
	                    }
	                    else {
	                        return false;
	                    }
	                }

	                else {
	                    return false;
	                }
                }
                function additionalValidation() {
                    //debugger;
                    //additional validation: NAB Sagem to Verifone upgrades #7197
                    if (document.getElementById("<%=txtClientID.ClientID%>").value == "NAB" && document.getElementById("<%=txtJobTypeID.ClientID%>").value == "3") {
                        //if (Left(document.getElementById('<%=cboOldDeviceType.ClientID%>').value, 5) == "SAGEM") {
                        if (document.getElementById('<%=cboOldDeviceType.ClientID%>').value.search("SAGEM") > -1 && document.getElementById('<%=chbUrgent.ClientID%>').checked) {
	                        if (Left(document.getElementById('<%=cboDeviceType.ClientID%>').value, 4) != "MOVE") {
	                            alert("Sagem device can only be upgraded to MOVE device. aborted");
	                            return false;
	                        }

	                    }
                    }
                    
                    return true;

	}

    function isNumberKey(evt) {
		var charCode = (evt.which) ? evt.which : evt.keyCode;

		if (document.getElementById("<%=txtClientID.ClientID%>").value == 'TYR') {
			if(charCode >= 48 && charCode <= 57) 
				return true;
			else
				return false;
        }
        return true;
	}

    function isNumberAnd_Key(evt) {
        var charCode = (evt.which) ? evt.which : evt.keyCode;

		if (document.getElementById("<%=txtClientID.ClientID%>").value == 'TYR') {
			if ((charCode == 95) || (charCode >= 48 && charCode <= 57))
				return true;
            else if ((charCode == 68) || (charCode >= 48 && charCode <= 57))
                return true;
			else
				return false;
        }
		return true;
	}

	function handlePhoneNumberPaste(event, input) {

		// Delay the execution of the formatting function to allow the paste to complete
		setTimeout(function () {

			if (document.getElementById("<%=txtClientID.ClientID%>").value == 'TYR') {
				let phoneNumber = input.value;

				// Remove spaces
				phoneNumber = phoneNumber.replace(/\s+/g, '');
				// Remove hyphens
				phoneNumber = phoneNumber.replace(/-/g, '');

				// Replace +61 with 0
				if (phoneNumber.startsWith('61')) {
					phoneNumber = '0' + phoneNumber.substring(2);
				}

				// Replace +61 with 0
				if (phoneNumber.startsWith('+61')) {
					phoneNumber = '0' + phoneNumber.substring(3);
				}
				// Replace +61 with 0
				if (phoneNumber.startsWith('0061')) {
					phoneNumber = '0' + phoneNumber.substring(4);
				}

				// Set the formatted value back to the input
				input.value = phoneNumber;
			}
		}, 0);
		
    }

    function handleSurburbAndPostcodeBlur() {
        //ResetAllValidators();
        var strCity = document.getElementById('<%= txtCity.ClientID %>').value.trim();
            var strPostcode = document.getElementById('<%= txtPostcode.ClientID %>').value.trim();
            var clientID = document.getElementById('<%= txtClientID.ClientID %>').value.trim(); 

            if (clientID == 'CBA' && strCity !== '' && strPostcode !== '') {
                //trigger with txtPostcode
                __doPostBack('<%= txtPostcode.ClientID %>', '');
            }
    }
</script>
	<asp:customvalidator id="cvTradingHoursMon" runat="server" ControlToValidate="txtTradingHoursMon" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursMon (it must be in hhmm-hhmm and 24hr format or with text of 'CLOSED')"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursTue" runat="server" ControlToValidate="txtTradingHoursTue" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursTue (it must be in hhmm-hhmm and 24hr format) or with text of 'CLOSED'"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursWed" runat="server" ControlToValidate="txtTradingHoursWed" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursWed (it must be in hhmm-hhmm and 24hr format) or with text of 'CLOSED'"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursThu" runat="server" ControlToValidate="txtTradingHoursThu" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursThu (it must be in hhmm-hhmm and 24hr format) or with text of 'CLOSED'"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursFri" runat="server" ControlToValidate="txtTradingHoursFri" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid tradinghoursFri (it must be in hhmm-hhmm and 24hr format) or with text of 'CLOSED'"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursSat" runat="server" ControlToValidate="txtTradingHoursSat" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid trading hours Sat (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
	<asp:customvalidator id="cvTradingHoursSun" runat="server" ControlToValidate="txtTradingHoursSun" ClientValidationFunction="VerifyTradingHours"
		Display="None" ErrorMessage="Invalid trading hours Sun (it must be in hhmm-hhmm and 24hr format)"></asp:customvalidator>        
    <!-- no blank trading hours, ControlToValidate can be attached to any control on the tradinghour panel-->
	<asp:customvalidator id="cvTH" runat="server" ControlToValidate="txtTradingHoursMon" ClientValidationFunction="IsAnyTradingHourEntered"
		Display="None" ErrorMessage="Must enter at least one tradinghour"></asp:customvalidator>        
	<asp:customvalidator id="cvSWApp" runat="server" ControlToValidate="txtTradingHoursMon" ClientValidationFunction="IsAnySWAppSelected"
		Display="None" ErrorMessage="Must select at least one Software Applications"></asp:customvalidator>        

    <asp:RegularExpressionValidator ID="revInstallDate" runat="server" ControlToValidate="txtInstallDate"
        Display="None" ErrorMessage="Invalid install date" ValidationExpression="(([0-2][0-9])|(3[01]))\/((0[1-9])|(1[012]))\/\d{2}"></asp:RegularExpressionValidator>
    <asp:RegularExpressionValidator ID="revPhone1" runat="server" ControlToValidate="txtPhoneNumber"
        Display="None" ErrorMessage="Invalid phone number" ValidationExpression="^\d{10}$"></asp:RegularExpressionValidator>        
    <asp:RegularExpressionValidator ID="revPhone2" runat="server" ControlToValidate="txtPhoneNumber2"
        Display="None" ErrorMessage="Invalid phone number 2" ValidationExpression="^\d{10}$"></asp:RegularExpressionValidator>        
    <asp:RegularExpressionValidator ID="revTerminalIDBoQ" runat="server" ControlToValidate="txtTerminalID"
        Display="None" ErrorMessage="Invalid TerminalID" ValidationExpression="\d{8}"></asp:RegularExpressionValidator>        
    <asp:RegularExpressionValidator ID="revOldTerminalIDBoQ" runat="server" ControlToValidate="txtOldTerminalID"
        Display="None" ErrorMessage="Invalid Old TerminalID" ValidationExpression="\d{8}"></asp:RegularExpressionValidator>        
    <asp:RegularExpressionValidator ID="revMerchantIDBoQ" runat="server" ControlToValidate="txtMerchantID"
        Display="None" ErrorMessage="Invalid MerchantID" ValidationExpression="\d{9}"></asp:RegularExpressionValidator>        
    <asp:RegularExpressionValidator ID="revMerchantIDCBA" runat="server" ControlToValidate="txtMerchantID"
        Display="None" ErrorMessage="Invalid MerchantID" ValidationExpression="\d{10}"></asp:RegularExpressionValidator> 
	<asp:RegularExpressionValidator ID="revMerchantIDTYR" runat="server" ControlToValidate="txtMerchantID"
        Display="None" ErrorMessage="Invalid MerchantID" ValidationExpression="^\d{2,8}$"></asp:RegularExpressionValidator>  
    <asp:RegularExpressionValidator ID="revTerminalIDCBA" runat="server" ControlToValidate="txtTerminalID"
        Display="None" ErrorMessage="Invalid TerminalID" ValidationExpression="\d{8}|[zZ]{1}\d{7}|(\d{3}\-\d{3})"></asp:RegularExpressionValidator>        
    <asp:RegularExpressionValidator ID="revJobNoteMaxLength" runat="server" ControlToValidate="txtJobNote"
        Display="None" ErrorMessage="Notes exceed the max length." ValidationExpression="^[\s\S]{0,400}$"></asp:RegularExpressionValidator>        

</asp:Content>
