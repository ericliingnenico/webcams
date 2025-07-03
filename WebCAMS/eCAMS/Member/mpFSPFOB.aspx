<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpFSPFOB.aspx.vb" Inherits="eCAMS.mpFSPFOB" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
	<ul class="pageitem">
        <ASP:PlaceHolder runat="server" id="placeholderErrorMsg"></ASP:PlaceHolder>
        <li class="textbox">
            <span class="name">
                <p><b>F.O.B. scan:</b> tap and scan barcode</p>
				 <p>
                    <asp:textbox id="txtSerial" runat="server" placeholder="tap and scan barcode" Height="40" Width="92%" Font-Size="12"></asp:textbox>
                 </p>
            </span>
        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <asp:TextBox ID="txtNote" runat="server" Rows="3" TextMode="MultiLine" placeholder="Max 60 characters"></asp:TextBox>
                </p>
            </span>
        </li>
        <li class="textbox">
            <span class="name">
                 <p>
                    <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClientClick="ValidatorEnable(Page_Validators[0], true);" />
                 </p>
            </span>
        </li>
	</ul>
<asp:requiredfieldvalidator id="rfvSerial" runat="server" ErrorMessage="Please enter serial number." ControlToValidate="txtSerial" Display="None" Enabled="False"></asp:requiredfieldvalidator>
	<asp:validationsummary id="ValidationSummary1" runat="server" ShowMessageBox="True" ShowSummary="False"></asp:validationsummary>
</div>
</asp:Content>
