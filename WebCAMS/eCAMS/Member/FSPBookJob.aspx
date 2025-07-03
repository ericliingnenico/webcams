<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.master" CodeBehind="FSPBookJob.aspx.vb" Inherits="eCAMS.FSPBookJob"%>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
   <ASP:PlaceHolder runat="server" id="placeholderErrorMsg"></ASP:PlaceHolder>

	<asp:label id="lblFormTitle" runat="server" CssClass="FormTitle"></asp:label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<asp:hyperlink id="SearchAgainURL" runat="server" CssClass="MemberInfo" NavigateUrl="FSPJobList.aspx"
			Width="40px"></asp:hyperlink>
<asp:HiddenField ID="txtJobIDList" runat="server" /> 
		<TABLE id="Table2" style="WIDTH: 816px; HEIGHT: 391px" cellSpacing="1" cellPadding="1"
			width="616" border="0">
			<TR>
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="Label2" runat="server" CssClass="FormDEHeader">Job ID</asp:label></TD>
				<TD height="26">
					<asp:textbox id="txtJobID" runat="server" CssClass="FormDEField" ReadOnly="True"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="146"></TD>
				<TD vAlign="top" width="134" height="146">
					<asp:label id="lblJobDetails" runat="server" CssClass="FormDEHeader">Job Details</asp:label></TD>
				<TD height="100">
					<asp:textbox id="txtJobDetails" runat="server" CssClass="FormDEField" 
                        Width="656px" ReadOnly="True" 
						TextMode="MultiLine" Height="246px"></asp:textbox></TD>
			</TR>
			<TR>
				<TD width="11" height="17"></TD>
				<TD vAlign="top" width="134" height="17">
					<asp:label id="Label1" runat="server" CssClass="FormDEHeader">Multiple Jobs</asp:label></TD>
				<TD align="left" height="17">
					<asp:datagrid id="grdMultipleJob" runat="server" CssClass="FormGrid">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					</asp:datagrid></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD colspan="2" align="left"><asp:label id="Label11" runat="server" CssClass="FormTitle" BackColor="#DDECEF">Make Booking</asp:label></TD>
			</TR>
			<TR  bgColor="#DDECEF">
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="lblBookDate" runat="server" CssClass="FormDEHeader">BookDate</asp:label>
                    
				</TD>
				<TD height="26">
                    <asp:textbox id="txtBookDate" runat="server" CssClass="FormDEField" Width="80px"></asp:textbox>
					<asp:textbox id="txtBookTime" runat="server" CssClass="FormDEField" Width="60px"></asp:textbox>
					<asp:label id="Label9" runat="server" CssClass="FormDEHint">dd/mm/yy hhmm</asp:label>
				</TD>
			</TR>
			<TR  bgColor="#DDECEF">
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="lblBookTo" runat="server" CssClass="FormDEHeader">Book To</asp:label></TD>
				<TD height="26">
					<asp:dropdownlist id="cboBookTo" runat="server" CssClass="FormDEField" Width="352px"></asp:dropdownlist></TD>
			</TR>
			<TR  bgColor="#DDECEF">
				<TD width="11" height="146"></TD>
				<TD vAlign="top" width="134" height="146">
					<asp:label id="Label3" runat="server" CssClass="FormDEHeader">New Notes</asp:label>
                    <asp:label id="Label30" runat="server" CssClass="FormDEHint">Max 2,000 characters</asp:label>
				</TD>
				<TD height="146">
                    <asp:textbox id="txtNote" runat="server" Width="656px" height="146" TextMode="MultiLine" class="txtwithcounter" charlimit="2000" charlimitinfo="Span3"></asp:textbox>
                    <br /><span id="Span3" class="charlimitinfo"></span> 
				</TD>
			</TR>
			<TR  bgColor="#DDECEF">
				<TD width="11" height="10"></TD>
				<TD width="134" height="10"></TD>
				<TD align="right" height="10"><INPUT class="FormDEButton" id="btnBook" type="submit" value="Book" name="btnBook"
						runat="server"></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD colspan="2" align="left"><asp:label id="Label4" runat="server" CssClass="FormTitle" BackColor="#eeeeee">Escalate Booking Exception</asp:label></TD>
			</TR>
			<TR  bgColor="#eeeeee">
				<TD width="11" height="26"></TD>
				<TD width="134" height="26">
					<asp:label id="Label5" runat="server" CssClass="FormDEHeader">Reason</asp:label></TD>
				<TD height="26">
                    <asp:DropDownList ID="cboEscalateReason" runat="server" CssClass="FormDEField" Width="352px">
                    </asp:DropDownList>
			</TR>
			<TR  bgColor="#eeeeee">
				<TD width="11" height="146"></TD>
				<TD vAlign="top" width="134" height="146">
					<asp:label id="Label6" runat="server" CssClass="FormDEHeader">Escalation Notes</asp:label>
                    <asp:label id="Label7" runat="server" CssClass="FormDEHint">Max 2,000 characters</asp:label>
				</TD>
				<TD height="146">
                    <asp:textbox id="txtEscalateNote" runat="server" Width="656px" height="146" TextMode="MultiLine" class="txtwithcounter" charlimit="2000" charlimitinfo="Span1"></asp:textbox>
                    <br /><span id="Span1" class="charlimitinfo"></span> 
				</TD>
			</TR>
			<TR  bgColor="#eeeeee">
				<TD width="11" height="10"></TD>
				<TD width="134" height="10"></TD>
				<TD align="right" height="10"><INPUT class="FormDEButton" id="btnEscalate" type="submit" value="Escalate" name="btnEscalate"
						runat="server"></TD>
			</TR>
			<TR>
				<TD width="11"></TD>
				<TD width="134"></TD>
				<TD align="right"></TD>
			</TR>
		</TABLE>


    <asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>
	<asp:customvalidator id="cvBookDate" runat="server" ErrorMessage="Invalid BookDate" Display="None" Enabled="False" ControlToValidate="txtBookDate" ClientValidationFunction="VerifyDate"></asp:customvalidator>
	<asp:customvalidator id="cvBookTime" runat="server" ErrorMessage="Invalid BookTime" Display="None" Enabled="False" ControlToValidate="txtBookTime" ClientValidationFunction="VerifyTime"></asp:customvalidator>
	<asp:requiredfieldvalidator id="rfvBookDate" runat="server" ErrorMessage="Please enter BookDate" Display="None"	Enabled="False" ControlToValidate="txtBookDate"></asp:requiredfieldvalidator>
	<asp:requiredfieldvalidator id="rfvBookTime" runat="server" ErrorMessage="Please enter BookTime" Display="None"	Enabled="False" ControlToValidate="txtBookTime"></asp:requiredfieldvalidator>
    <asp:RequiredFieldValidator ID="rfvEscalateReason" runat="server" ErrorMessage="Please choose a Reason." ControlToValidate="cboEscalateReason" Display="None" InitialValue="0"></asp:RequiredFieldValidator>
	<asp:requiredfieldvalidator id="rfvEscalateNote" runat="server" ErrorMessage="Please enter Escalation Notes" Display="None" Enabled="False" ControlToValidate="txtEscalateNote"></asp:requiredfieldvalidator>
	<script language="javascript">
				<!--
	    $(function () {

	        if (isIE() && isIE() < 9) {
	            // is IE version less than 9
	            $("#<%=txtBookDate.ClientID%>").datepicker({ dateFormat: 'dd/mm/y'});
	        } else {
	            // is IE 9 and later or not IE
	            $("#<%=txtBookDate.ClientID%>").datetimepicker({ dateFormat: 'dd/mm/y',
	                timeFormat: 'HHmm',
	                hourMin: 7,
	                hourMax: 19,
	                stepMinute: 5,
	                altField: "#<%=txtBookTime.ClientID%>",
	                altFieldTimeOnly: true,
	                oneLine: true
	            });
	        }

	    });

        function isIE() {
            var myNav = navigator.userAgent.toLowerCase();
            return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
        }


	    function ResetAllValidators() {
	        //				could use Page_Validators[] generated on client


	        ValidatorEnable(document.getElementById("<%=cvBookDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=cvBookTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvBookDate.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvBookTime.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvEscalateReason.ClientID%>"), false);
	        ValidatorEnable(document.getElementById("<%=rfvEscalateNote.ClientID%>"), false);
	    }

	    function SetEscalateValidator() {
	        ResetAllValidators();
	        ValidatorEnable(document.getElementById("<%=rfvEscalateReason.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvEscalateNote.ClientID%>"), true);
	    }

	    function SetJobBookValidator() {
	        //debugger

	        ResetAllValidators();

	        ValidatorEnable(document.getElementById("<%=cvBookDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=cvBookTime.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvBookDate.ClientID%>"), true);
	        ValidatorEnable(document.getElementById("<%=rfvBookTime.ClientID%>"), true);

	    }

          								
	// -->
	</script>

</asp:Content>
