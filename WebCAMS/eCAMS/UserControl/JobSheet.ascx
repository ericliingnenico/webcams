<%@ Control Language="VB" AutoEventWireup="false" Inherits="UserControl_JobSheet" Codebehind="JobSheet.ascx.vb" %>
<%@ Register TagPrefix="ecams" Namespace="eCAMS" Assembly="eCAMS" %>


<table class="JobSheetNormal" width="450">
    <tr>
        <td colspan=4 class="JobSheetLarger">
            <asp:Label ID="lblTitle"  runat="server" Text="SERVICE REQUEST FORM"></asp:Label>
            <asp:Label class="barcode128h" ID="lblBarcode1" runat="server" Text="barcode"></asp:Label>
        </td>
    </tr> 
    <tr>
        <td colspan=4 class="JobSheetLarger">
            <asp:Label ID="lblJobType"  runat="server" Text="SWAP"></asp:Label>
        </td>
    </tr> 

    <tr>
        <td style="width: 15px">JobNo
        </td>
        <td class="JobSheetBold">
            <asp:Label ID="lblJobID" runat="server" Text="Label"></asp:Label><asp:HiddenField ID="hfJobID"
                runat="server" />
        </td>
        <td style="width: 10px">ClientRef
        </td>
        <td class="JobSheetBold" style="width: 164px">
            <asp:Label ID="lblClientRef" runat="server" Text="Label"></asp:Label>
         </td>
    </tr>
    <tr>
        <td style="width: 15px">To
        </td>
        <td class="JobSheetBold">
            <asp:Label ID="lblInstallerName" runat="server" Text="Label"></asp:Label>
        </td>
        <td style="width: 10px">
            InstallerID
        </td>
        <td class="JobSheetBold" style="width: 164px">
            <asp:Label ID="lblInstallerID" runat="server" Text="Label"></asp:Label>
         </td>
    </tr>
    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>
    
    <tr>
        <td style="width: 15px">TerminalID
        </td>
        <td class="JobSheetBold">
            <asp:Label ID="lblTerminalID" runat="server" Text="Label"></asp:Label>
        </td>
        <td style="width: 10px">
            TerminalNo
        </td>
        
            
        <td class="JobSheetBold" style="width: 164px">
            <asp:Label ID="lblTerminalNumber" runat="server" Text="Label"></asp:Label>
         </td>
    </tr>
    <tr>
        <td style="width: 15px">MerchantID
        </td>
        <td class="JobSheetBold">
            <asp:Label ID="lblMerchantID" runat="server" Text="Label"></asp:Label>
        </td>
        <td style="width: 10px">
            DeviceType
        </td>
        
            
        <td class="JobSheetBold" style="width: 164px">
            <asp:Label ID="lblDeviceType" runat="server" Text="Label"></asp:Label>
         </td>

    </tr>

    <tr>
        <td style="width: 15px">TMSVersion
        </td>
        <td class="JobSheetBold">
            <asp:Label ID="lblTMSVersion" runat="server" Text="Label"></asp:Label>
        </td>
        <td style="width: 10px">
            TMSSerial
        </td>
        
            
        <td class="JobSheetBold" style="width: 164px">
            <asp:Label ID="lblTMSSerial" runat="server" Text="Label"></asp:Label>
         </td>

    </tr>

    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>

    <tr>
        <td colspan=4 class="JobSheetLarger">
            <asp:Label ID="lblName" runat="server" Text="Label"></asp:Label>
        </td>
    </tr>

    <tr>
        <td colspan=4 class="JobSheetLarger"> 
            <asp:Label ID="lblAddress" runat="server" Text="Label"></asp:Label>
        </td>
    </tr>
    <tr>
        <td colspan=4 class="JobSheetLarger">
            <asp:Label ID="lblAddress2" runat="server" Text="Label"></asp:Label>
        </td>
    </tr>
    <tr>
        <td colspan=3 class="JobSheetLarger">
            <asp:Label ID="lblCity" runat="server" Text="Label"></asp:Label>
        </td>
        <td class="JobSheetLarger" style="width: 164px">
            <asp:Label ID="lblPostcode" runat="server" Text="Label"></asp:Label>
         </td>

    </tr>
    <tr>
        <td style="width: 15px">Contact
        </td>
        <td class="JobSheetBold">
            <asp:Label ID="lblContact" runat="server" Text="Label"></asp:Label>
        </td>
        <td style="width: 10px">
            Phone
        </td>
            
        <td class="JobSheetBold" style="width: 164px">
            <asp:Label ID="lblPhone" runat="server" Text="Label"></asp:Label>
         </td>
    </tr>
    <tr>
        <td style="width: 15px">
            Business Activity
        </td>
        <td colspan=3 class="JobSheetBold">
            <asp:Label ID="lblBusinessActivity" runat="server" Text="Label"></asp:Label>
        </td>
    </tr>  
    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>

    <tr>
        <td style="width: 15px">Service Required
        </td>
        <td class="JobSheetBold">
            <asp:Label ID="lblService" runat="server" Text="Label"></asp:Label>
        </td>
        <td style="width: 10px">
            SLADate
        </td>
        
        <td class="JobSheetBold" style="width: 164px">
            <asp:Label ID="lblSLA" runat="server" Text="Label"></asp:Label>
         </td>
    </tr>  
    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>

    <tr>
        <td colspan=4>
            <asp:Label ID="lblMerhcantAcceptance" runat="server" Text="MERCHANT ACCEPTANCE"><b>MERCHANT ACCEPTANCE</b><br />
Service Completed, EFTPOS Terminal configuration matches details of Service Order and Merchant has verified that the correct business name and address appears on the logon receipt.<br />
Merchant Damage (Please Circle One)   Y/N<br />
I, the Merchant accept responsibility for any Merchant Damage and any charges that may apply under Merchant agreement with the Bank.<br /></asp:Label>
        </td>
    </tr>         
  <asp:Panel ID="PanelMerchantSignatureRequire" runat=server>
    <tr>
        <td colspan=4 class="JobSheetBold">
            <asp:Label ID="lblSign" runat="server" Text="Label">Site Manager Name:____________________Signature:_______________________Date:____/____/______</asp:Label>
        </td>
    </tr>  
 </asp:Panel>     
  <asp:Panel ID="PanelMerchantSignatureCaptured" runat=server>
    <tr>
        <td colspan=4 class="JobSheetNormal">
            Name:  <asp:Label ID="lblMerchantSigName" CssClass="JobSheetBold" runat="server" Text="Label"></asp:Label>   Signature: <b>Signed</b>  <ecams:SgImage ID="mySgImage" runat="server" />*  Date: <asp:Label ID="lblMerchantSigDate" CssClass="JobSheetBold" runat="server" Text="Label"></asp:Label>
        </td>
    </tr>  
    <tr>
        <td colspan=4 class="JobSheetNormal">
            *Merchant Signature was captured electronically at time of service using pocket CAMS
        </td>
    </tr>  

 </asp:Panel>     

    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>

    <tr>
        <td colspan=4>
            Device list: <br />
					<asp:datagrid id="grdDevice" runat="server" CssClass="FormGrid" AutoGenerateColumns="False" Width="100%">
					    <AlternatingItemStyle CssClass="FormGridAlternatingCell"></AlternatingItemStyle>
					    <HeaderStyle CssClass="FormGridHeaderCell"></HeaderStyle>
					     <Columns>
					        <asp:BoundColumn DataField="InOut" HeaderText="InOut"></asp:BoundColumn>
					        <asp:BoundColumn DataField="Serial" HeaderText="Serial"></asp:BoundColumn>
					        <asp:BoundColumn DataField="MMD" HeaderText="Device"></asp:BoundColumn>
<%--					        <asp:BoundColumn DataField="Is3DES" HeaderText="Is3DES"></asp:BoundColumn>
					        <asp:BoundColumn DataField="IsEMV" HeaderText="IsEMV"></asp:BoundColumn>--%>
				        </Columns>

					</asp:datagrid>
        </td>
    </tr>  
    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>
    
    <tr>
        <td colspan=4>
            <b>Notes:</b><asp:Label ID="lblNote" runat="server" Text="Label"></asp:Label>
        </td>
    </tr> 
    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>

    <tr>
        <td colspan=4>
            <b>Other Info:</b><asp:Label ID="lblInfo" runat="server" Text="Label"></asp:Label>
        </td>
    </tr> 
    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>
    <tr>
        <td colspan=4>
            <b>Site Inspection:</b><br /><asp:Label ID="lblSurvey" runat="server" Text=""></asp:Label>
        </td>
    </tr> 
    <tr>
        <td colspan=4>________________________________________________________________________________________</td>
    </tr>

    <tr>
        <td colspan=4>
            <asp:Label ID="lblTech" runat="server" Text="Technician Reference:"></asp:Label>
            &nbsp;JobID&nbsp;&nbsp;&nbsp;<asp:Label class="barcode128h" ID="lblBarcode" runat="server" Text="barcode"></asp:Label>

        </td>
    </tr> 
    <tr>
        <td style="width: 15px">OnSite:
        </td>
        <td>
            <asp:Label ID="lblOnSiteDateTime" runat="server" Text="Label"></asp:Label>
        </td>
        <td style="width: 10px">
            OffSite:
        </td>
        
        <td style="width: 164px">
            <asp:Label ID="lblOffSiteDateTime" runat="server" Text="Label"></asp:Label>
         </td>
    </tr>


</table>
<script type="text/javascript">
    $(document).ready(function () {
        var strValue = document.getElementById('<%=hfJobID.ClientID%>').value;
        var strBarcodeHTML = code128(strValue);
        document.getElementById('<%=lblBarcode1.ClientID%>').innerHTML = strBarcodeHTML;
        document.getElementById('<%=lblBarcode.ClientID%>').innerHTML = strBarcodeHTML;
    }
    );

</script>
<br /><br />

