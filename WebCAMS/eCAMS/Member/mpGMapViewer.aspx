<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/mPhone.master" CodeBehind="mpGMapViewer.aspx.vb" Inherits="eCAMS.mpGMapViewer" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <div class="content">
	<ul class="pageitem">
    <asp:Label ID="lblMsg" runat="server" Text="msg" CssClass="info"></asp:Label>    
    <div id="map_canvas"></div>
    <script type="text/javascript">
        $(document).ready(function () {
                SetMapDivToViewportSize();
                CreateMap();
            }
        );

        function SetMapDivToViewportSize() {
            var viewportWidth = $(window).width();
            var viewportHeight = $(window).height()+20;
            var element = document.getElementById('map_canvas');

            element.style.height = viewportHeight + 'px';
            element.style.width = viewportWidth + 'px';
        }

        $(window).resize(function () {
                SetMapDivToViewportSize();
                google.maps.event.trigger(document.getElementById('map_canvas'), 'resize');
            }
        );

    </script>
    </ul>
</div>

</asp:Content>
