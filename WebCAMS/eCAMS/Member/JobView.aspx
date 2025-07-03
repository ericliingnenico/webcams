<%@ Page Language="vb" MasterPageFile="~/MemberPopupMasterPage.master" AutoEventWireup="false" Inherits="eCAMS.JobView" Codebehind="JobView.aspx.vb" EnableEventValidation="false" ValidateRequest="false" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script type="text/javascript">
    var jobnoteControlHeight;
    var jobnoteControlWidth;
    var hasActivated = false;
    function ResizeJobNote(checkActiveBefore) {
        if ((!checkActiveBefore) || (!hasActivated && checkActiveBefore)) {
            hasActivated = true;
            var jobnoteControl = document.getElementById("<%=txtJobNote.ClientID%>");
           var resizeControl = document.getElementById("<%=lblResizeJobNote.ClientID%>");

            //debugger;
            if (resizeControl.innerHTML.toLowerCase() == "expandnote") {
                jobnoteControlHeight = jobnoteControl.style.height;
                jobnoteControlWidth = jobnoteControl.style.width;
                jobnoteControl.style.height = jobnoteControl.scrollHeight + "px";
                jobnoteControl.style.width = document.body.clientWidth + "px";
                resizeControl.innerHTML = "CollapseNote";

            }
            else {
                jobnoteControl.style.height = jobnoteControlHeight;
                jobnoteControl.style.width = jobnoteControlWidth;
                resizeControl.innerHTML = "ExpandNote";
            }
        }

    }

</script>
    <asp:HiddenField ID="txtClientID" runat="server" />
	<TABLE id="Table2" style="WIDTH: 559px; HEIGHT: 400px" cellSpacing="1" cellPadding="1"
		width="559" border="0">
		<TR>
			<TD colspan="3">
				<asp:Label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:Label>&nbsp;::&nbsp;&gt;&gt;&nbsp;
				<asp:hyperlink id="SearchAgainURL" runat="server" NavigateUrl="UpdateJobInfo.aspx" CssClass="FormDEHeader" Visible="False">Update Job Info</asp:hyperlink>
			</TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label4" runat="server" CssClass="FormDEHeader">Type</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtSource" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="15" name="txtSource" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label2" runat="server" CssClass="FormDEHeader">JobID</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtJobID" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="15" name="txtJobID" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label7" runat="server" CssClass="FormDEHeader">JobType</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtJobType" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="15" name="txtJobType" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label6" runat="server" CssClass="FormDEHeader">JobMethod</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtJobMethod" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="15" name="txtJobMethod" runat="server" readonly="readOnly"></TD>
		</TR>
        <TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label15" runat="server" CssClass="FormDEHeader">DeviceType</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtDeviceType" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="15" name="txtDeviceType" runat="server" readonly="readOnly"></TD>
		</TR>
        <asp:panel id="panelFDIAdditionalInfo" visible="False" runat="server">
            <TR>
                <TD width="10"></TD>
			    <TD width="145"><asp:label id="Label18" runat="server" CssClass="FormDEHeader">CustomerNumber</asp:label></TD>
			    <TD><INPUT class="FormDEField" id="txtCustomerNumber" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtCustomerNumber" runat="server" readonly="readOnly"></TD>
			</TR>
        </asp:panel>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label5" runat="server" CssClass="FormDEHeader">Ref No</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtProblemNumber" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtProblemNumber" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label3" runat="server" CssClass="FormDEHeader">TerminalID</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtTerminalID" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtTerminalID" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label14" runat="server" CssClass="FormDEHeader">CAIC</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtCAIC" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtCAIC" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label21" runat="server" CssClass="FormDEHeader">ConNote</asp:label></TD>
<%--			<TD><INPUT class="FormDEField" id="txtConnote" style="width: 357px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtConnote" runat="server" readonly="readOnly"></TD>--%>
			<td>
				<asp:HyperLink  id="txtConnoteHyperLink" NavigateUrl=""  CssClass="FormDEHeader" Visible="True" Target="_new" Text="n/a" runat="server"/>
			</td>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label11" runat="server" CssClass="FormDEHeader">MerchantID</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtMerchantID" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtMerchantID" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label13" runat="server" CssClass="FormDEHeader">Merchant</asp:label></TD>
			<TD>
                <asp:TextBox ID="txtMerchantName" runat="server" CssClass="FormDEField" ReadOnly="true" TextMode="MultiLine" Columns="80" Rows="6" Height="155px"></asp:TextBox></TD>
		</TR>			
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label12" runat="server" CssClass="FormDEHeader">Region</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtRegion" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtRegion" runat="server" readonly="readOnly"></TD>
		</TR>
         <asp:panel id="panelDeliveryService" visible="False" runat="server">
            <TR>
                <TD width="10"></TD>
			    <TD width="145"><asp:label id="Label20" runat="server" CssClass="FormDEHeader">DeliveryService</asp:label></TD>
			    <TD><INPUT class="FormDEField" id="txtDeliveryService" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtDeliveryService" runat="server" readonly="readOnly"></TD>
			</TR>
        </asp:panel>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label16" runat="server" CssClass="FormDEHeader">LoggedBy</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtLoggedBy" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="80" name="txtLoggedBy" runat="server" readonly="readOnly"></TD>
		</TR>
		
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label1" runat="server" CssClass="FormDEHeader">Logged DateTime</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtLoggedDateTime" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; width: 152px;"
					type="text" name="txtLoggedDateTime" runat="server" readonly="readOnly">
				<asp:label id="lblLoggedTimeZone" runat="server" CssClass="FormDEHint">CAMS System Time</asp:label></TD>
		</TR>
		<%If m_IsOpenJob Then%>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="lblSLA" runat="server" CssClass="FormDEHeader"> ETA</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtSLA" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; width: 152px;"
					type="text" name="txtSLA" runat="server" readonly="readOnly">
				<asp:label id="lblSLATimeZone" runat="server" CssClass="FormDEHint">Merchant's local time</asp:label></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="lblStatus" runat="server" CssClass="FormDEHeader">Status</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtStatus" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" name="txtStatus" runat="server" readonly="readOnly"></TD>
		</TR>
		<%End If%>

		<% If m_IsNotTYRMerchant Then%>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="lblStatusNote" runat="server" CssClass="FormDEHeader">Status Note</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtStatusNote" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="80" name="txtStatusNote" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="lblDelayReason" runat="server" CssClass="FormDEHeader">Delay Reason</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtDelayReason" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="60" name="txtDelayReason" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label8" runat="server" CssClass="FormDEHeader">SpecialInstruction</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtSpecialInstruction" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="80" name="txtSpecialInstruction" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label10" runat="server" CssClass="FormDEHeader">JobNote</asp:label><br />
			    <a href="#atgJobNote"  onclick="ResizeJobNote(false);"><asp:label id="lblResizeJobNote" runat="server">ExpandNote</asp:label></a>
				<br />
				<asp:LinkButton Text="Asc Order" runat="server" ID="lnkBtnNoteSortOder"></asp:LinkButton>
			</TD>
			<TD>
                <a id="atgJobNote" onactivate="ResizeJobNote(true);">
                    <asp:TextBox ID="txtJobNote" Readonly="true" runat="server" CssClass="FormDEField" TextMode="MultiLine" Columns="80" Rows="6" style="HEIGHT: 88px; WIDTH: 512px" ></asp:TextBox>
                </a>
            </TD>
		</TR>					
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label9" runat="server" CssClass="FormDEHeader">TradingHours</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtTradingHours" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="80" name="txtTradingHours" runat="server" readonly="readOnly"></TD>
		</TR>
        <%End If%>

        <%If m_UserCanCloseJobs Then%>
        <TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label17" runat="server" CssClass="FormDEHeader">Closure</asp:label></TD>
			<TD>
                <%If m_IsCloseable Then%>
                <asp:UpdatePanel runat="server" ID="ClosureUpdatePanel" UpdateMode="Conditional" ChildrenAsTriggers="False">
                    <ContentTemplate>
                        <asp:DropDownList id="cboFixID" AutoPostBack="True" runat="server" CssClass="FormDEField" Width="100px" />
                        <asp:DropDownList id="cboClosureComment" runat="server" />  
                        <input class="FormDEButton" id="btnCloseJob" type="submit" value=" Close Job " runat="server" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="cboFixID" EventName="SelectedIndexChanged" />
                        <asp:PostBackTrigger ControlID="btnCloseJob" />
                    </Triggers>
                </asp:UpdatePanel>
			    <%Else %>
                This job cannot be closed due to its status.
                <%End If%>
            </TD>
		</TR>
        <%End If%>
		
		<%If not m_IsOpenJob Then%>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="lblFix" runat="server" CssClass="FormDEHeader">Fix</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtFix" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="60" name="txtFix" runat="server" readonly="readOnly"></TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="lblCloseComment" runat="server" CssClass="FormDEHeader">Closure Comment</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtCloseComment" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"
					type="text" size="60" name="txtCloseComment" runat="server" readonly="readOnly"></TD>
		</TR>
        <TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="Label19" runat="server" CssClass="FormDEHeader">Closed DateTime</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtClosedDateTime" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; HEIGHT: 17px; BORDER-BOTTOM-STYLE: none; width: 144px;"
					type="text" name="txtClosedDateTime" runat="server" readonly="readOnly">
                    <asp:label id="lblClosedDateTimeZone" runat="server" CssClass="FormDEHint">CAMS System Time</asp:label>
			</TD>
		</TR>
		<TR>
			<TD width="10"></TD>
			<TD width="145"><asp:label id="lblOnSiteDateTime" runat="server" CssClass="FormDEHeader">OnSite DateTime</asp:label></TD>
			<TD><INPUT class="FormDEField" id="txtOnSiteDateTime" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; HEIGHT: 17px; BORDER-BOTTOM-STYLE: none; width: 144px;"
					type="text" name="txtOnSiteDateTime" runat="server" readonly="readOnly">
				<asp:label id="lblOnSiteTimeZone" runat="server" CssClass="FormDEHint">Merchant's local time</asp:label></TD>
		</TR>
		<%End If%>
	</TABLE>
    <asp:label id="lblMsg" runat="server" CssClass="FormDEError"></asp:label>
    <asp:ValidationSummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"
		Width="152px"></asp:ValidationSummary>
    <%If m_ClosureSuccess Then%>
    <script type="text/javascript" language="javascript">
        window.opener.location.reload();
        window.close();
    </script>
    <%End If %>
    <script type="text/javascript" language="javascript">
		<!--
    function ConfirmWithValidation(msg) {
        return confirm(msg);
    }
		// -->
    </script>
</asp:Content>