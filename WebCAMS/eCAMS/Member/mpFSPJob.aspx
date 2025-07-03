<%@ Page Title="" Language="VB" MasterPageFile="~/mPhone.master" AutoEventWireup="false" Inherits="eCAMS.mpFSPJob" Codebehind="mpFSPJob.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<asp:HiddenField ID="txtJobID" runat="server" />
<asp:HiddenField ID="txtPage" runat="server" />
<asp:HiddenField ID="txtSurveyID" runat="server" />
<asp:HiddenField ID="txtPhoneNumber" runat="server" />
<asp:HiddenField ID="geoLatitude" runat="server" />
<asp:HiddenField ID="geoLongitude" runat="server" />
<asp:HiddenField ID="txtTID" runat="server" />
<asp:HiddenField ID="txtClientID" runat="server" />
<asp:HiddenField ID="txtDisplayName" runat="server" />
<asp:HiddenField ID="txtChatAuthToken" runat="server" />

 <div id="quadbutton">
    <div class="links">
        <asp:panel id="panelquadbutton" runat="server">
        </asp:panel>
    </div>
 </div>
<asp:ScriptManager runat="server"></asp:ScriptManager>
 <div class="content">
   <asp:panel id="panelMerchantPage" runat="server">
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <asp:Button ID="btnFSPCallMerchant" runat="server" Text="" style="display: none;"/>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnFSPCallMerchant" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
	<ul class="pageitem">
        <ASP:PlaceHolder runat="server" id="placeholderMerchantPage"></ASP:PlaceHolder>
        <asp:Repeater ID="RepeaterMerchant" runat="server">
            <ItemTemplate>
		        <li class="textbox">
                 <span class="name">
                    <p>JobNo: <b><%# Eval("JobID") %></b>&nbsp;&nbsp;<%# Eval("ClientID") %>&nbsp;<%# Eval("Region") %>&nbsp;<%# Eval("JobType") %></p>
                    <p>Device: <b><%# Eval("DeviceType") %></b>&nbsp;RefNo: <%# Eval("ClientRef") %></p>
			        <p>TID: <b><%# Eval("TIDExt") %></b>&nbsp;MID: <b><%# Eval("MerchantID") %></b></p>
                    <p>SLADate: <b><%# Eval("AgentSLADateTimeLocal") %></b></p>
                    <p>TMSVersion: <b><%# Eval("TMSSoftwareVersion") %></b></p>
                    <p>TMSSerial: <b><%# Eval("TMSSerial") %></b></p>
                  </span>
		        </li>
		        <li class="textbox">
                 <span class="name">
   			        <p><%# Eval("Name") %> </p>
			        <p><%# Eval("Address") %></p>
                    <p><%# Eval("Address2") %></p>
                    <p><%# Eval("City") %> &nbsp;<%# Eval("PostCode") %></p>
                    <p>Contact: <%# Eval("Contact") %>&nbsp;tel: <b><%# Eval("Phone") %></b></p>
                   <asp:Panel id="panelMerchantBusinessActivity"  runat="server" >
                    <p>Business: <%# Eval("BusinessActivity") %></p>
                   </asp:Panel>
                  </span>
		        </li>
		        <li class="textbox">
                 <span class="name">
   			        <p>Note: <%# Eval("Notes").ToString.Replace("###################", "") %></p>
			        <p>Info: <%# Eval("Info") %></p>
                  </span>
		        </li>
		        <li class="menu">
   			        <a class="noeffect" href="http://maps.google.com/?ie=UTF8&q=<%# Eval("JobID") %>@<%# Eval("Latitude") %>,<%# Eval("Longitude") %>">
		                <span class="smallname">Location: Maps and Directions</span>
                        <span class="arrow"></span>
                    </a>
                </li>
              <asp:Panel id="panelCallMerchantPhon1"  runat="server" class="menu">
		        <li class="menu">
   			        <a class="noeffect" href="tel:<%# Eval("Phone1")%>" onclick="return FSPCallMerchant('<%# Eval("Phone1")%>');">
		                <span class="smallname">Comm: Call Merchant on <%# Eval("Phone1") %></span>
                        <span class="arrow"></span>
                    </a>
                </li>
              </asp:Panel>
              <asp:Panel id="panelCallMerchantPhon2"  runat="server" class="menu">
		        <li class="menu">
   			        <a class="noeffect" href="tel:<%# Eval("Phone2")%>"  onclick="return FSPCallMerchant('<%# Eval("Phone2")%>');">
		                <span class="smallname">Comm: Call Merchant on <%# Eval("Phone2") %></span>
                        <span class="arrow"></span>
                    </a>
                </li>
              </asp:Panel>
		        <li class="menu" <%#IIf(WebchatEnabled(Eval("ClientID")), "", "style='display:none;'")%>>
                    <a class="noeffect" target="_blank" id="amazonChatAnchor" >
		                <span class="smallname">WebChat: FSP Support</span>
                        <span class="arrow"></span>
                    </a>
                </li>
		        <li class="menu">
   			        <a class="noeffect" href="mpFSPJob.aspx?id=<%# Eval("JobID") %>&p=1&a=1" onclick="this.href = this.href + '&lat=' + document.getElementById('<%=geoLatitude.ClientID%>').value + '&lon=' + document.getElementById('<%=geoLongitude.ClientID%>').value; return confirm('Report I-AM-ONSITE?');">
		                <span class="smallname">Teamwork: I Am OnSite</span>
                        <span class="arrow"></span>
                    </a>
                </li>
              <asp:Panel id="panelReAssignJob"  runat="server" class="menu">
		        <li class="menu">
   			        <a class="noeffect" href="mpFSPReAssign.aspx?id=<%# Eval("JobID") %>">
		                <span class="smallname">Teamwork: Reassign this job</span>
                        <span class="arrow"></span>
                    </a>
                </li>
              </asp:Panel>
              <asp:Panel id="panelSendMerchantDamagePhoto"  runat="server" class="menu" Visible='<%# Eval("ClientID") <> "UPI" %>'>
		        <li class="menu">
   			        <a class="noeffect" href="mailto:aus_stockteam@ingenico.com?subject=MerchantDamaged-<%# Eval("JobID") %>">
		                <span class="smallname">Comm: Send MerchantDamaged Photos</span>
                        <span class="arrow"></span>
                    </a>
                </li>
              </asp:Panel>
		        <li class="menu">
   			        <a class="noeffect" href="mailto:FSPManagement@ingenico.com?subject=Jobsheet-<%# Eval("JobID") %>">
		                <span class="smallname">Comm: Send MerchantSigned JobSheet</span>
                        <span class="arrow"></span>
                    </a>
                </li>
                <div id="Div1" runat="server" class="menu" Visible='<%# Eval("ClientID") = "UPI" %>'>
                <li class="menu">
   			        <a class="noeffect" href="mailto:FSPManagement@ingenico.com?subject=<%# Eval("ClientID") %>-SitePhotos-JobID-<%# Eval("JobID") %>">
		                <span class="smallname">Comm: Send Site Photos</span>
                        <span class="arrow"></span>
                    </a>
                </li>
                </div>

<%--		        <li class="menu">
   			        <a class="noeffect" href="mailto:aus_camsdevmelb@ingenico.com?subject=OfflineJobSheet-<%# Eval("JobID") %>">
		                <span class="smallname">Comm: Request Offline JobSheet</span>
                        <span class="arrow"></span>
                    </a>
                </li>
--%>            </ItemTemplate>
        </asp:Repeater>
		        <li class="menu">
   			        <a class="drilldownheading" href="#" rotateval="0" contentclassidx="1">
		                <span class="smallname">Comm: Add Job Notes</span>
                        <span class="arrow"></span>
                    </a>
                </li>
                <li class="textbox">
                    <div class="drilldowncontent1">
                        <span class="name">
                        <p>
                            <asp:TextBox ID="txtJobNote" runat="server" Rows="4" TextMode="MultiLine" placeholder="Enter Job Notes. Max 200 characters"></asp:TextBox>
                        </p>
                        </span>
                        <asp:Button ID="btnAddJobNote" runat="server" Text="Add Notes To This Job" OnClientClick="SetJobNoteValidator();" name="btnAddJobNote"/>  
                    </div>
                </li>
              <asp:Panel id="panelReassignJobBackToDepot"  runat="server">
		        <li class="menu">
   			        <a class="drilldownheading" href="#" rotateval="0" contentclassidx="2">
		                <span class="smallname">Teamwork: Reassign this job back to depot</span>
                        <span class="arrow"></span>
                    </a>
                </li>
                <li class="textbox">
                    <div class="drilldowncontent2">
                        <span class="name">
                        <p>
                            <asp:TextBox ID="txtReassignBackNote" runat="server" Rows="3" TextMode="MultiLine" placeholder="Enter Reassign Notes. Max 200 characters"></asp:TextBox>
                        </p>
                        </span>
                        <asp:Button ID="btnReassignBackToDepot" runat="server" Text="Reassign This Job Back To Depot" OnClientClick="SetReAssignValidator();" name="btnReassignBackToDepot"/>  
                    </div>
                </li>
              </asp:Panel>
              <asp:Panel id="panelHowTo"  runat="server">
		        <li class="menu">
   			        <a class="drilldownheading" href="#" rotateval="0" contentclassidx="3">
		                <span class="smallname">HowTo: Help Documents and Videos</span>
                        <span class="arrow"></span>
                    </a>
                </li>
                <div class="drilldowncontent3">
                    <asp:Repeater ID="RepeaterHowTo" runat="server">
                        <ItemTemplate>
		                        <li class="store">
                                    <a href='mpFSPDownload.aspx?DLID=<%# Eval("Seq") %>'>
                                        <span class="name">
                                            <b><%# Eval("Description") %> </b>&nbsp;
                                            <br/><%# Eval("FileType") %> &nbsp;<%# Eval("FileSize") %>&nbsp; <%# Eval("EffectiveDate") %> 
                                        </span>
                                        <span class="arrow"></span>
                                    </a>
                                </li>
                        </ItemTemplate>
                    </asp:Repeater>
		            <li class="store">
                        <a href="mpFSPDownloadSearch.aspx">
                            <span class="name">
                                <b>Search More Help Document...</b>
                            </span>
                            <span class="arrow"></span>
                        </a>
                    </li>
                </div>
             </asp:Panel>
	</ul>
    <div class="drilldownanchor"></div>
    <asp:requiredfieldvalidator id="rfvJobNote" runat="server" ErrorMessage="Please enter Job Notes" Display="None" Enabled="False" ControlToValidate="txtJobNote"></asp:requiredfieldvalidator>
    <asp:requiredfieldvalidator id="rfvReassignBackNote" runat="server" ErrorMessage="Please enter Reassign Notes" Display="None" Enabled="False" ControlToValidate="txtReassignBackNote"></asp:requiredfieldvalidator>
    <script type="text/javascript">
        // Initialise amazon chat
        (function (w, d, x, id) {
            s = d.createElement('script');
            s.src = 'https://d1nv5i00u1m742.cloudfront.net/amazon-connect-chat-interface-client.js';
            s.async = 1;
            s.id = id;
            d.getElementsByTagName('head')[0].appendChild(s);
            w[x] = w[x] || function () { (w[x].ac = w[x].ac || []).push(arguments) };
        })(window, document, 'amazon_connect', '4a4d6fcf-5fac-46ae-ba0d-81486880e68d');
        amazon_connect('styles', { openChat: { color: '#ffffff', backgroundColor: '#6d84a2' }, closeChat: { color: '#ffffff', backgroundColor: '#6d84a2' } });
        amazon_connect('snippetId', 'QVFJREFIaDJSeExmZC9mdkhGcGpyYSs4Zm9SMXpVL2FlMFF2aEpVbzNKb3oyNCtZekFGWWM0T0lBWEFsUll2QmM2eCtEMXRlQUFBQWJqQnNCZ2txaGtpRzl3MEJCd2FnWHpCZEFnRUFNRmdHQ1NxR1NJYjNEUUVIQVRBZUJnbGdoa2dCWlFNRUFTNHdFUVFNSmJSVW56bFdFN3h1Zk1QdkFnRVFnQ3Z4TUYrRDBBZDM3L0t2NXA2UmNqc2JkSUJmdmpwRU1IdkE2U0Z2am9Wb083Nk0vN1FtSUhPM3ZvUjM6Om5QMmxzWEoxeGEzKzh3MmIwT3BCb0V6bmJ3UjFlRXEzMXFNZCtORmEyNE9uRjV1bHdPNG5oTXA2c25FT1ZFa2hyTDBXYkppMEQ5S3RkMGNneURVT25jRjcyRk9XWFJtclhkRHBtYXYwQ21qYS9NSWgvVXZ3dDFPeWxKc21lZjBxdmp0Z2Z6STVTRkluVklLTjEyUXdOTHZyWmZHbnJUOD0=');
        amazon_connect('supportedMessagingContentTypes', ['text/plain', 'text/markdown']);
		var chatAttributeToken = document.getElementById('<%=txtChatAuthToken.ClientID%>').value;
		amazon_connect('authenticate', function (callback) {
                callback(chatAttributeToken);
            });
        $('#amazon-connect-chat-widget').hide(); //hide chat icon 


        window.onload = function () {
            var chatAttributeToken = document.getElementById('<%=txtChatAuthToken.ClientID%>').value;

            if (chatAttributeToken) {
                $('#amazon-connect-chat-widget').show(); //show chat icon
                amazon_connect('customerDisplayName', function (callback) {
                    const displayName = document.getElementById('<%=txtDisplayName.ClientID%>').value;
                                callback(displayName);
                });

                amazon_connect('authenticate', function (callback) {
                    callback(chatAttributeToken);
                });

                positionAmazonChatIcon();
            }
            else {
                $('#amazon-connect-chat-widget').hide();
            }
        }

        window.onscroll = () => {
            var chatAttributeToken = document.getElementById('<%=txtChatAuthToken.ClientID%>').value;
            if (chatAttributeToken) {
                positionAmazonChatIcon()
            }
        }


        function positionAmazonChatIcon() {
            // Find the div element by its ID
            var chatWidget1 = document.getElementById("amazon-connect-chat-widget");
            //console.log("visible");

            // Find the button inside the div
            var chatButton = chatWidget1.querySelector('button'); // You can use appropriate selector here

            // Get the target element's position
            var targetElement = document.getElementById("amazonChatAnchor");
            var targetRect = targetElement.getBoundingClientRect();

            // Set the position and height of the button
            chatButton.style.position = 'fixed'; // Example: Sets the position to absolute
            chatButton.style.width = '40px'; // Example: Sets the height to 50 pixels
            chatButton.style.height = '40px'; // Example: Sets the height to 50 pixels	

            chatButton.style.top = targetRect.top + 2 + 'px';
            chatButton.style.left = targetRect.right - 45 + 'px';           
        }

	    function ResetAllValidators() {
	        // could use Page_Validators[] generated on client
	        ValidatorEnable(document.getElementById("<%=rfvJobNote.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvReassignBackNote.ClientID%>"), false);
	    }

	    function SetJobNoteValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvJobNote.ClientID%>"), true);
	    }

	    function SetReAssignValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvReassignBackNote.ClientID%>"), true);
	    }

	    function FSPCallMerchant(phoneno) {
	        //debugger;
            var btnObj=document.getElementById("<%=btnFSPCallMerchant.ClientID%>");
            var txtPhone = document.getElementById("<%=txtPhoneNumber.ClientID%>");
            txtPhone.value=phoneno;
            btnObj.click();  
            return true;
        }
        //geoFindMe(); //do not turn it on
        function geoFindMe() {
            if (!navigator.geolocation) {
                alert('Geolocation service is not supported');
                return;
            }

            navigator.geolocation.getCurrentPosition(
            function (position) {
                //alert("Lat1: " + position.coords.latitude + "\nLon1: " + position.coords.longitude);
                var txtLat = document.getElementById("<%=geoLatitude.ClientID%>");
                var txtLon = document.getElementById("<%=geoLongitude.ClientID%>");
                txtLat.value = position.coords.latitude;
                txtLon.value = position.coords.longitude;

            },
            function (error) {
                alert(error.message);
            },
            {
                enableHighAccuracy: true, timeout: 10000
            });
        }
    </script>

    </asp:panel>

    <asp:panel id="panelDevicePage" runat="server">
	<ul class="pageitem">
        <ASP:PlaceHolder runat="server" id="placeholderDevicePage"></ASP:PlaceHolder>
        <asp:Repeater ID="RepeaterDevice" runat="server">
            <ItemTemplate>
                <li class="textbox">
                    <span class="name">
                    <p>
                        <b>Device<%# Eval("Action") %>:</b>&nbsp;&nbsp;
                        <%# Eval("Serial") %>
                    </p>
                    <p>
                        <b>Device:</b> &nbsp;<%# Eval("Device") %></p>
                    <p>
                        <b>SW-Ver:</b> &nbsp;<%# Eval("SW") %>&nbsp;&nbsp;<b>HW-Ver:</b> &nbsp;<%# Eval("HW") %></p>
                    <p>
                        <b>New Serial:</b><asp:TextBox ID="txtSerial" runat="server" name='<%# Eval("Keys") %>' Width="220px"></asp:TextBox>
                    </p>
                    <p>
                        <asp:Button ID="btnDeviceUpdate" runat="server" CommandArgument='<%# Eval("Keys") %>' CommandName="update" Text="Update" />
                        <asp:Button ID="btnDeviceDelete" runat="server" CommandArgument='<%# Eval("Keys") %>' CommandName="delete" Text="Delete" />
                        <asp:Button ID="btnDeviceMerchantDamaged" runat="server" CommandArgument='<%# Eval("Keys") %>' CommandName="merchantdamaged"  Text="Damaged" />
                    </p>
                    </span>
                 </li>
            </ItemTemplate>
        </asp:Repeater>
                <li class="textbox">
                    <span class="name">
                <asp:panel id="panelDeviceOut" runat="server">
                    <p>
                        <b>DeviceOUT:</b><asp:TextBox ID="txtDeviceOut" runat="server" Width="220px"></asp:TextBox>
                    </p>
                </asp:panel>
                <asp:panel id="panelDeviceIn" runat="server">
                    <p>
                        <b>DeviceIN:</b><asp:TextBox ID="txtDeviceIn" runat="server" Width="220px"></asp:TextBox>
                    </p>
                </asp:panel>
                    <p>
                        <asp:Button ID="btnDeviceAdd" runat="server" Text="Add Device" OnClientClick="SetDeviceValidator();"/>
                    </p>
                    </span>
                 </li>
        <asp:Repeater ID="RepeaterParts" runat="server">
            <ItemTemplate>
                <li class="textbox">
                    <span class="name">
                    <p>
                        <b>Parts<%# Eval("Action") %>:</b> &nbsp;<%# Eval("Device") %></p>
                    <p>
                        <b>Qty:</b> &nbsp;<%# Eval("Qty") %>&nbsp;&nbsp;
                        <asp:Button ID="btnPartsDelete" runat="server" CommandArgument='<%# Eval("Keys") %>' CommandName="delete" Text="Delete Parts" />
                    </p>
                    </span>
                 </li>
            </ItemTemplate>
        </asp:Repeater>
                <li class="textbox">
                    <span class="select">
                        <asp:dropdownlist id="cboParts" runat="server"></asp:dropdownlist>
                        <span class="arrow"></span>
                    </span>
                    <span class="name">
                    <p>
                        <b>Quantity:</b><asp:TextBox ID="txtPartsQty" runat="server" size=2></asp:TextBox>
                        <asp:Button ID="btnPartsAdd" runat="server" Text="Add Parts" OnClientClick="SetPartsValidator();"/>
                    </p>
                    </span>
                 </li>
        <asp:panel id="panelConfirmKittedPartsUsage" runat="server">
            <li class="textbox">
                <span class="name">
                </span>
            </li>
            <li class="textbox">
                <span class="name">
                <p>
                    <asp:Label ID="Label1" runat="server" forecolor="red" font="bold" Text="Kitted device is used for the job. I acknowledge that kitted parts being used are entered correctly."></asp:Label>
                    <asp:Button ID="btnConfirmKittedPartsUsage" runat="server" Text="Confirm" OnClientClick=" ResetAllValidators();"/>
                </p>
                </span>
            </li>
        </asp:panel>
	</ul>
    <asp:panel id="panelBundledSIMSwap" runat="server" Visible="False">
        <ul class="pageitem">
            <li class="textbox">
                <h3>Bundled SIM Swap</h3>
                <span class="name">
                    <asp:panel id="simOut" runat="server">
                        <p>
                            <b>SIM OUT:</b><asp:TextBox ID="txtSIMOut" runat="server" Width="220px"></asp:TextBox>
                        </p>
                    </asp:panel>
                    <asp:panel id="simIn" runat="server">
                        <p>
                            <b>SIM IN:</b><asp:TextBox ID="txtSIMIn" runat="server" Width="220px"></asp:TextBox>
                        </p>
                    </asp:panel>
                        <p>
                            <asp:Button ID="btnSwapSIM" runat="server" Text="Update SIM" OnClientClick="SetSIMValidator();" />
                        </p>
                </span>
            </li>
        </ul>
    </asp:panel>
	<asp:requiredfieldvalidator id="rfvDeviceIn" runat="server" ErrorMessage="Please enter DeviceIn serial number."	Display="None" ControlToValidate="txtDeviceIn"></asp:requiredfieldvalidator>
    <asp:requiredfieldvalidator id="rfvDeviceOut" runat="server" ErrorMessage="Please enter DeviceOut serial number." Display="None" ControlToValidate="txtDeviceOut"></asp:requiredfieldvalidator>
    <asp:customvalidator id="cvPartsQty" runat="server" ErrorMessage="Invalid Parts Qty" Display="None" ControlToValidate="txtPartsQty" ClientValidationFunction="VerifyPositiveIntegerOrZero"></asp:customvalidator>
    <asp:requiredfieldvalidator id="rfvcvPartsQty" runat="server" ErrorMessage="Please enter Parts Qty." Display="None" ControlToValidate="txtPartsQty"></asp:requiredfieldvalidator>
    <asp:requiredfieldvalidator id="rfvSIMIn" runat="server" ErrorMessage="Please enter SIM In serial number." Display="None" ControlToValidate="txtSIMIn"></asp:requiredfieldvalidator>
    <asp:requiredfieldvalidator id="rfvSIMOut" runat="server" ErrorMessage="Please enter SIM Out serial number." Display="None" ControlToValidate="txtSIMOut"></asp:requiredfieldvalidator>

	<script language="javascript">
	<!--
	    function ResetAllValidators() {
	        //				could use Page_Validators[] generated on client
	        ValidatorEnable(document.getElementById("<%=rfvDeviceIn.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvDeviceOut.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvPartsQty.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvcvPartsQty.ClientID%>"), false);
            ValidatorEnable(document.getElementById("<%=rfvSIMIn.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvSIMOut.ClientID%>"), false);
	    }

	    function SetDeviceValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvDeviceIn.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvDeviceOut.ClientID%>"), true);
        }

        function SetSIMValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvSIMIn.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvSIMOut.ClientID%>"), true);
	    }

	    function SetPartsValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=cvPartsQty.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvcvPartsQty.ClientID%>"), true);
	    }
		// -->
	</script>

    </asp:panel>

    <asp:panel id="panelSurveyPage" runat="server">
	<ul class="pageitem">
        <ASP:PlaceHolder runat="server" id="placeholderSurveyPage"></ASP:PlaceHolder>
        <asp:Panel ID="panelSurvey" runat="server">
        </asp:Panel>
        <li class="textbox">
            <span class="name">
            <p>
                <asp:Button ID="btnSurveySave" runat="server" Text="Submit Survey" />
            </p>
            </span>
         </li>

	</ul>
    </asp:panel>

    <asp:panel id="panelSignaturePage" runat="server">
	<script language="javascript">
	<!--
	    function validateAcknowledge(src, arg) {
	        arg.IsValid = document.getElementById('<%=chkSurveyAcknowledge.ClientID%>').checked;
	    }
				
	// -->
	</script>

	<ul class="pageitem">
        <ASP:PlaceHolder runat="server" id="placeholderSignaturePage"></ASP:PlaceHolder>
        <li class="textbox">
            <p>
                <ASP:CheckBox runat="server" id="chkSurveyAcknowledge" text="I acknowledge that the information recorded for this service attendance is correct." forecolor="red" font="bold">
                </ASP:CheckBox>
            </p>
            <asp:customvalidator id="cvSurveyAcknowledge" runat="server" ErrorMessage="Please tick acknowledge" Display="None" ClientValidationFunction="validateAcknowledge"></asp:customvalidator>

         </li>
        <li class="textbox">
            <p>
                <b>Print Name:</b><asp:TextBox ID="txtSurveyMerchantName" runat="server"></asp:TextBox>
            </p>
            <ASP:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Enter Merchant Name" ControlToValidate="txtSurveyMerchantName" Display="None">Enter Merchant Name</ASP:RequiredFieldValidator>

         </li>

        <li class="textbox">
                <div  class="sigPad">
		            <div class="clearButton"><a href="#clear">Clear</a></div>
		            <div class="sig sigWrapper">
			            <canvas class="pad" width="<%=sigSize.width %>" height="<%=sigSize.height %>"></canvas>
                        <input id="output" type="hidden" class="output"/><asp:HiddenField ID="sigJSON"  runat="server" />
		            </div>
                     <asp:Button ID="btnSignatureSave" runat="server" Text="Submit Signature" class="submit" style="height:40px;width:auto"/>
                    <script type="text/javascript" src="../signature/assets/jquery.signaturepad.min.js"></script>
                    <script type="text/javascript">
	                    var api;

	                    $(document).ready(function () {
	                        api = $('.sigPad').signaturePad({ drawOnly: true, bgColour: '#efd' });
	                    });
	                    $(".submit").click(function () { $("#<%=sigJSON.ClientID%>").val(api.getSignatureString()); });
	                    
	                </script>
                    <script type="text/javascript" src="../signature/assets/json2.min.js"></script>

                </div>
         </li>
    </ul>
    </asp:panel>

    <asp:panel id="panelSignatureSignedPage" runat="server">
	<ul class="pageitem">
        <ASP:PlaceHolder runat="server" id="placeholderSignatureSignedPage"></ASP:PlaceHolder>
        <li class="textbox">
            <span class="name">
            <p>
                <ASP:CheckBox runat="server" id="chkSignedAcknowledge" text="I acknowledge that the information recorded for this service attendance is correct." forecolor="red" font="bold" value="checked">
                </ASP:CheckBox>
            </p>
            </span>
         </li>
        <li class="textbox">
            <span class="name">
            <p>
                Print Name:<asp:TextBox ID="txtSignedMerchantName" runat="server"></asp:TextBox>
            </p>
            </span>
         </li>

        <li class="textbox">
            <span class="name">
                <div  class="sigPad">
		            <div class="sig sigWrapper">
                        <canvas class="pad" width="<%=sigSize.width %>" height="<%=sigSize.height %>"></canvas>
		            </div>
	                <script type="text/javascript" src="../signature/assets/jquery.signaturepad.min.js"></script>
	                <script type="text/javascript" src="../signature/assets/json2.min.js"></script>
	                <script type="text/javascript">
	                    var sig=<%=m_sigJASON%>;
	                    $(document).ready(function () {
	                        $('.sigPad').signaturePad({displayOnly:true, bgColour:'#efd'}).regenerate(sig);
	                    });
	                </script>

                </div>
            </span>
         </li>
    </ul>
    </asp:panel>

    <asp:panel id="panelClosurePage" runat="server">
	<ul class="pageitem">
        <ASP:PlaceHolder runat="server" id="placeholderClosurePage"></ASP:PlaceHolder>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>OnSite Date:</b><asp:textbox id="txtOnSiteDate" runat="server" placeholder="dd/mm/yy" size="8"></asp:textbox>
                    <b>Time:</b><asp:textbox id="txtOnSiteTime" runat="server" placeholder="hhmm" size="5"></asp:textbox>
                </p>
                <p>
                    <b>OffSite Date:</b><asp:textbox id="txtOffSiteDate" runat="server" placeholder="dd/mm/yy" size="8"></asp:textbox>
                    <b>Time:</b><asp:textbox id="txtOffSiteTime" runat="server" placeholder="hhmm" size="5"></asp:textbox>
                </p>
            </span>
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>Options:</b>
                </p>
            </span>
            <span class="select">
                <asp:dropdownlist id="cboTechFix" runat="server" AutoPostBack="true"></asp:dropdownlist>
                <span class="arrow"></span>
            </span>
            <asp:Panel ID="missingPartsPanel" runat="server" Visible="false">
                <p>Please select the missing components:</p>
                <asp:CheckBoxList ID="chkMissingParts" runat="server" CssClass="missingParts"></asp:CheckBoxList>
            </asp:Panel>
        </li>

        <li class="textbox">
            <span class="name">
            <p>
                <asp:TextBox ID="txtNotes" runat="server" Rows="3" TextMode="MultiLine" placeholder="Max 200 characters"></asp:TextBox>
            </p>
            </span>
         </li>
        <li class="textbox">
          <div id="divTIDEnter">
            <span class="name">
            <p>
               EnterTID:<asp:TextBox ID="txtTIDEnter" runat="server" size="15" placeholder="from logon receipt"></asp:TextBox>
            </p>
            </span>
         </div>

         </li>
        <li class="textbox">
            <asp:Button ID="btnClose" runat="server" Text="Submit Closure" OnClientClick="if (IsOnSiteAfterHourStopper() || IsTIDMatch()) {return false}; SetClosureValidator();"/>  
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>Escalation Reason:</b>
                </p>
            </span>
            <span class="select">
                <asp:dropdownlist id="cboEscalateReason" runat="server"></asp:dropdownlist>
                <span class="arrow"></span>
            </span>
        </li>
        <li class="textbox">
            <span class="name">
            <p>
                <asp:TextBox ID="txtEscalateNotes" runat="server" Rows="4" TextMode="MultiLine" placeholder="Enter Escalation Notes. Max 200 characters"></asp:TextBox>
            </p>
            </span>
         </li>

        <li class="textbox">
            <asp:Button ID="btnEscalateJob" runat="server" Text="Escalate This Job" OnClientClick="SetEscalateValidator();"/>  
        </li>
	</ul>
        <asp:customvalidator id="cvOnSiteDate" runat="server" ErrorMessage="Invalid OnSiteDate" Display="None"	Enabled="True" ControlToValidate="txtOnSiteDate" ClientValidationFunction="VerifyDate"></asp:customvalidator>
        <asp:customvalidator id="cvOnSiteTime" runat="server" ErrorMessage="Invalid OnSiteTime" Display="None"	Enabled="True" ControlToValidate="txtOnSiteTime" ClientValidationFunction="VerifyTime"></asp:customvalidator>
        <asp:requiredfieldvalidator id="rfvOnSiteDate" runat="server" ErrorMessage="Please enter OnSiteDate" Display="None"	Enabled="True" ControlToValidate="txtOnSiteDate"></asp:requiredfieldvalidator>
        <asp:requiredfieldvalidator id="rfvOnSiteTime" runat="server" ErrorMessage="Please enter OnSiteTime" Display="None"	Enabled="True" ControlToValidate="txtOnSiteTime"></asp:requiredfieldvalidator>
        <asp:customvalidator id="cvOffSiteDate" runat="server" ErrorMessage="Invalid OffSiteDate" Display="None" Enabled="True" ControlToValidate="txtOffSiteDate" ClientValidationFunction="VerifyDate"></asp:customvalidator>
        <asp:customvalidator id="cvOffSiteTime" runat="server" ErrorMessage="Invalid OffSiteTime" Display="None" Enabled="True" ControlToValidate="txtOffSiteTime" ClientValidationFunction="VerifyTime"></asp:customvalidator>
        <asp:requiredfieldvalidator id="rfvOffSiteDate" runat="server" ErrorMessage="Please enter OffSiteDate" Display="None" Enabled="True" ControlToValidate="txtOffSiteDate"></asp:requiredfieldvalidator>
        <asp:requiredfieldvalidator id="rfvOffSiteTime" runat="server" ErrorMessage="Please enter OffSiteTime" Display="None" Enabled="True" ControlToValidate="txtOffSiteTime"></asp:requiredfieldvalidator>
        <asp:requiredfieldvalidator id="rfvEscalateNote" runat="server" ErrorMessage="Please enter Escalation Notes" Display="None" Enabled="True" ControlToValidate="txtEscalateNotes"></asp:requiredfieldvalidator>
        <asp:customvalidator id="cvMissingParts" runat="server" ErrorMessage="Must select a missing part" Display="None" Enabled="False" ClientValidationFunction="ValidateMissingParts"></asp:customvalidator>
	<script language="javascript">
	<!--
	    function ResetAllValidators() {
	        //				could use Page_Validators[] generated on client
	        ValidatorEnable(document.getElementById("<%=cvOnSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvOnSiteTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOnSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOnSiteTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvOffSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvOffSiteTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOffSiteDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvOffSiteTime.ClientID%>"), false);
            ValidatorEnable(document.getElementById("<%=rfvEscalateNote.ClientID%>"), false);
	    }

	    function SetEscalateValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvEscalateNote.ClientID%>"), true);
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

	    }
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
	    //check if TIDEnter match job TID
	    function IsTIDMatch() {
	        if (ShowTIDEnter() && (document.getElementById('<%=txtTID.ClientID%>').value.trim().length > 0 && (document.getElementById('<%=txtTIDEnter.ClientID%>').value.trim().toUpperCase() != document.getElementById('<%=txtTID.ClientID%>').value.trim().toUpperCase()))) {
	            //debugger;
	            return !alert('TID you entered is incorrect. ');
	        }
	        else {
	            return false;
	        }
	    }
	    function ShowTIDEnter() {
            var TIDEnterClient = "NAB,HIC"
	        return (TIDEnterClient.indexOf(document.getElementById('<%=txtClientID.ClientID%>').value.trim().toUpperCase()) != -1);
	    }
        //show/hide TIDEnter and prevent paste
	    $(document).ready(function () {
	        if (ShowTIDEnter()) {
	            $('#<%=txtTIDEnter.ClientID%>').bind("paste", function (e) {
	                e.preventDefault();
	            });
	        }
	        else {
	            document.getElementById("divTIDEnter").style.display = "none";
	        }

	    });

        function ValidateMissingParts(source, args) {
            args.IsValid = ValidateCheckedAtLeastOne('<%=chkMissingParts.ClientID %>');
        }
		// -->
	</script>
    </asp:panel>
    <asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>
    <asp:Label ID="lblJobInfo" runat="server" Text="" class="center"></asp:Label>

 </div>
</asp:Content>

