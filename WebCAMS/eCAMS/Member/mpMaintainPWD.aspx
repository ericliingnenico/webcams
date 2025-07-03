<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpMaintainPWD.aspx.vb" Inherits="eCAMS.mpMaintainPWD" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
    <asp:panel id="panelMain" runat="server">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p>
                    <b>New Password:</b><asp:textbox id="txtNewPWD"  TextMode="Password" runat="server" placeholder="enter password" size="18"></asp:textbox>
                </p>
            </span>

        </li>
        <li class="textbox">
            <span class="name">
                <p>
                    <b>ReType New Password:</b><asp:textbox id="txtReTypeNewPWD"  TextMode="Password" runat="server" placeholder="re-enter password" size="18"></asp:textbox>
                </p>
            </span>

        </li>
        <li class="button">
            <asp:Button id="btnSave" runat="server" CssClass="FormDEButton" Text="Save"></asp:Button>
        </li>
    </ul>
    </asp:panel>
    <asp:panel id="panelAcknowledgeSuccess" runat="server" Visible="false">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p style="color:green;font:500">
                    Password was updated successfully.
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>
    <asp:panel id="panelAcknowledgeFailed" runat="server" Visible="false">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p style="color:red;font:500">
                    Password was failed to update. 
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>
    <asp:panel id="panelAcknowledgeFailed1" runat="server" Visible="false">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p style="color:red;font:500">
                    Password failed to update if you use  SAME as last one
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>
         <asp:panel id="panelAcknowledgeFailed2" runat="server" Visible="false">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p style="color:red;font:500">
                    Password failed to update.Password cannot be changed twice within any 24  hour period
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>
     	</asp:panel>
         <asp:panel id="panelAcknowledgeFailed3" runat="server" Visible="false">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p style="color:red;font:500">
                    Password failed to update.Minimum  14 characters for admin account
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>
         <asp:panel id="panelAcknowledgeFailed4" runat="server" Visible="false">
	<ul class="pageitem">
        <li class="textbox">
            <span class="name">
                <p style="color:red;font:500">
                    test
                </p>
            </span>
        </li>
	</ul>
	</asp:panel>




		<asp:RequiredFieldValidator id="RequiredFieldValidator2" runat="server" ErrorMessage="Enter new password" ControlToValidate="txtNewPWD" Display="None"></asp:RequiredFieldValidator>
		<asp:CompareValidator id="CompareValidator1" runat="server" ErrorMessage="New password and ReType password are not the same value"	ControlToValidate="txtNewPWD" ControlToCompare="txtReTypeNewPWD" Display="None"></asp:CompareValidator>
        <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtNewPWD" Display="None" ErrorMessage="Min 8 characters (14 for admin ), at least one uppercase letter, one lowercase letter and one numbers.(NO  special character)<" ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$"></asp:RegularExpressionValidator>
		<asp:ValidationSummary id="ValidationSummary1" runat="server" CssClass="FormDEError" ShowMessageBox="True" ShowSummary="False"></asp:ValidationSummary>
 </div>

</asp:Content>
