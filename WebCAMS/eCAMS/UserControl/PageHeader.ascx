<%@ Control Language="VB" AutoEventWireup="false" Inherits="UserControl_PageHeader" Codebehind="PageHeader.ascx.vb" %>
<TABLE id="Table1" cellSpacing="2" cellPadding="2" width="100%" border="0">
    <tr style="height: 10px;"></tr>
	<TR>
		<TD class="header">
			<A href="http://www.ingenico.com/"><IMG alt="Ingenico" vtop="0" hspace="20" src="/ecams/images/kyc/ingenico_logo.png"
					border="0"></A>
		</TD>
	</TR>
    <tr style="height: 10px;"></tr>
	<% If IsTestSite Then%>
	
	<tr  class="PageHeader">
	    <td bgcolor="#31C0DB">
	        <b>
                <asp:Label ID="Label1" runat="server" Text="This is a TEST website. Ingenico will not take any action on the jobs logged from this site." ForeColor="White"></asp:Label></b>
	    </td>
	</tr>
    <script type="text/javascript">
    <!--
        //debugger;
        //blink the warning meesage
        blinkElement('<%=Label1.ClientID%>');
        
        
        var g_blinkTime = 1000;
        var g_blinkCounter = 0;
        function blinkElement(elementId)
        {
             if ( (g_blinkCounter % 2) == 0 )
             {
              if ( document.getElementById )
              {
               document.getElementById(elementId).style.visibility = 'visible';
              }
              // IE 4...
              else if ( document.all )
              {
               document.all[elementId].style.visibility = 'visible';
              }
              // NS 4...
              else if ( document.layers )
              {
               document.layers[elementId].visibility = 'visible';
              }
             }
             else
             {
              if ( document.getElementById )
              {
               document.getElementById(elementId).style.visibility = 'hidden';
              }
              // IE 4...
              else if ( document.all )
              {
               document.all[elementId].style.visibility = 'hidden';
              }
              // NS 4...
              else if ( document.layers )
              {
               document.layers[elementId].visibility = 'hidden';
              }
             }
             if ( g_blinkCounter < 1 )
             {
              g_blinkCounter++;
             } 
             else
             {
              g_blinkCounter--
             }
             window.setTimeout('blinkElement(\"' + elementId + '\")', g_blinkTime);
        }
    // -->
    </script>

	<%End If%>
</TABLE>