<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpFSPDownload.aspx.vb" Inherits="eCAMS.mpFSPDownload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <video id="videoPlayerId" ClientIDMode="Static" width="560" height="315" controls runat="server"></video>
    <iframe id="videoIframeId" ClientIDMode="Static" width="560" height="315" frameborder="0" allowfullscreen runat="server"></iframe>


    <script language="javascript" type="text/javascript">
        var clientValue = '<%=videoURL%>';
        const videoPlayer = document.getElementById('videoPlayerId');
        const videoIframeId = document.getElementById('videoIframeId');

        if (clientValue.includes("vimeo") || clientValue.includes("youtube")) {
            videoIframeId.src = clientValue;
            videoPlayer.style.display = "none";
            videoIframeId.style.display = "block";

        } else {
            videoPlayer.src = clientValue;
            videoIframeId.style.display = "none";
            videoPlayer.style.display = "block";
        }

    </script>
</asp:Content>
