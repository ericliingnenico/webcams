<%@ Page Language="VB" AutoEventWireup="false" Inherits="eCAMS.Member_FSPJobSheetExt" Codebehind="FSPJobSheetExt.aspx.vb" %>
<%@ Register Src="../UserControl/JobSheet.ascx" TagName="JobSheet" TagPrefix="uc1" %>
<%@ Reference Control="~/UserControl/JobSheet.ascx" %>
<html>
<head runat="server">
    <title>Press Ctrl+P to print JobSheet </title>
    <link href="../Styles/Styles.css" rel="stylesheet" type="text/css" />    
    <link href="../Styles/barcode.css" rel="stylesheet" type="text/css" />    
<%--    <script type="text/javascript" src="../jquerymobile/jquery-1.8.2.min.js"></script>--%>
    <script type="text/javascript" src="../jquery/jquery.min.js"></script>
    <script type="text/javascript" src="../Scripts/barcode.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:label id="lblFormTitle" runat="server">Label</asp:label>&nbsp;
        <asp:PlaceHolder ID="placeholderJobSheet" runat="server"></asp:PlaceHolder>
    </form>

</body>
</html>
