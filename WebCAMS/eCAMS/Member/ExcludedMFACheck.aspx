<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MemberMasterPage.master" CodeBehind="ExcludedMFACheck.aspx.vb" Inherits="Member_ExcludedMFACheck" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <table id="Table2" border="0">
        <thead>
            <tr>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <!-- Client ID Dropdown -->
            <tr>
                <td></td>
                <td>
                    <asp:Label ID="lblClientID" runat="server" CssClass="FormDEHeader"
                        AssociatedControlID="ddlClientID"
                        Text="Client ID"></asp:Label>
                </td>
                <td>
                    <asp:DropDownList ID="ddlClientID" runat="server" CssClass="FormDEField"
                        AppendDataBoundItems="true">
                        <asp:ListItem Text="-- Select Client --" Value="" />
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvClient" runat="server"
                        CssClass="FormDEError"
                        ControlToValidate="ddlClientID"
                        InitialValue=""
                        ErrorMessage="Please select a client."
                        Display="Dynamic" />
                    <asp:Label ID="lblClientHint" runat="server" CssClass="FormDEHint"
                        Text="Only for Client logins"></asp:Label>
                </td>
            </tr>

            <!-- Email Address -->
            <!-- there can type mutiple email addresses with , comma -->
            <tr>
                <td width="10"></td>
                <td width="90">
                    <asp:Label ID="lblEmail" runat="server" CssClass="FormDEHeader"
                        AssociatedControlID="txtEmailAddress"
                        Text="Email Addresses"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtEmailAddress" runat="server" CssClass="FormDEField"
                        TextMode="Email" Placeholder="name@example.com"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                        CssClass="FormDEError"
                        ControlToValidate="txtEmailAddress"
                        ErrorMessage="Email is required."
                        Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server"
                        CssClass="FormDEError"
                        ControlToValidate="txtEmailAddress"
                        ValidationExpression="^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$"
                        ErrorMessage="Invalid email format."
                        Display="Dynamic" />
                </td>
            </tr>

            <!-- Buttons -->
            <tr>
                <td></td>
                <td></td>
                <td align="left">
                    <asp:Button ID="btnSubmit" runat="server" CssClass="FormDEButton"
                        Text="Submit" OnClick="btnSubmit_Click" />
                    &nbsp;&nbsp;
        <asp:Button ID="btnReset" runat="server" CssClass="FormDEButton"
            Text="Reset" OnClick="btnReset_Click" CausesValidation="False" />
                </td>
            </tr>
        </tbody>

    </table>

    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
        CssClass="FormDEError" ShowMessageBox="True" ShowSummary="False" />
</asp:Content>
