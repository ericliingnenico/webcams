#Region "vss"
'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/01/16 9:07 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/UserControl/JobSheet.ascx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Imports System.Data
Imports eCAMS.clsTool
Partial Class UserControl_JobSheet
    Inherits System.Web.UI.UserControl

    Private m_jobData As DataSet
Public Property JobData() As DataSet
    Get
        Return m_jobData
    End Get
    Set(ByVal value As DataSet)
        m_jobData = value
    End Set
End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        With m_jobData.Tables(0).Rows(0)

            lblTitle.Text = Convert.ToString(.Item("CompanyName")) + " " + lblTitle.Text
            lblJobType.Text = Convert.ToString(.Item("ClientID")) + " " + Convert.ToString(.Item("JobType"))

            lblJobID.Text = Convert.ToString(.Item("JobID"))
            hfJobID.Value = " " & Convert.ToString(.Item("JobID"))
            lblClientRef.Text = Convert.ToString(.Item("ClientRef"))
            lblInstallerName.Text = Convert.ToString(.Item("InstallerName"))
            lblInstallerID.Text = Convert.ToString(.Item("InstallerID"))
            lblTerminalID.Text = Convert.ToString(.Item("TIDExt"))
            lblTerminalNumber.Text = Convert.ToString(.Item("TerminalNumber"))
            lblMerchantID.Text = Convert.ToString(.Item("MerchantID"))
            lblDeviceType.Text = Convert.ToString(.Item("DeviceType"))
            lblName.Text = Convert.ToString(.Item("Name"))
            lblAddress.Text = Convert.ToString(.Item("Address"))
            lblAddress2.Text = Convert.ToString(.Item("Address2"))
            lblCity.Text = Convert.ToString(.Item("City"))
            lblPostcode.Text = Convert.ToString(.Item("PostCode"))
            lblContact.Text = Convert.ToString(.Item("Contact"))
            lblPhone.Text = Convert.ToString(.Item("Phone"))
            lblBusinessActivity.Text = Convert.ToString(.Item("BusinessActivity"))
            lblService.Text = Convert.ToString(.Item("Region")) & " " & Convert.ToString(.Item("JobType"))
            lblSLA.Text = Convert.ToString(.Item("AgentSLADateTimeLocal"))
            lblNote.Text = Convert.ToString(.Item("Notes")).Replace("###################", "")
            lblInfo.Text = Convert.ToString(.Item("Info"))
            lblOnSiteDateTime.Text = Convert.ToString(.Item("OnSiteDateTimeLocal"))
            lblOffSiteDateTime.Text = Convert.ToString(.Item("OffSiteDateTimeLocal"))
            lblTMSVersion.Text = Convert.ToString(.Item("TMSSoftwareVersion"))
            lblTMSSerial.Text = Convert.ToString(.Item("TMSSerial"))

            If Convert.ToString(.Item("JobType")) = "INSTALL" Or Convert.ToString(.Item("JobType")) = "UPGRADE" Then
                lblMerhcantAcceptance.Text += "<br/>For New Installs I acknowledge that I have reccieved trainning in the operation of the Terminal."
            End If

            If Convert.ToString(.Item("Survey")).Length > 0 Then
                lblSurvey.Text = Convert.ToString(.Item("Survey")).Replace("[br]", "<br/>")
            End If

            ''default, require signature
            PanelMerchantSignatureRequire.Visible = True
            PanelMerchantSignatureCaptured.Visible = False
            If Not .Item("IsOpen") Then
                ''closed job, check signature and show it
                Dim sg As New eCAMS.clsSignature
                If sg.GetSignature(.Item("JobID")) Then
                    If sg.dsSig.Tables.Count > 0 Then
            '            ''show signature capture
                        PanelMerchantSignatureRequire.Visible = False
                        PanelMerchantSignatureCaptured.Visible = True

                        lblMerchantSigName.Text = sg.dsSig.Tables(0).Rows(0)(3)
                        ''Merchant Signature
                        '''mySgImage.JobID = .Item("JobID")  ''not in this release
                        mySgImage.Visible = False  ''hide the signature

                        lblMerchantSigDate.Text = sg.dsSig.Tables(0).Rows(0)(2)
                    End If

                End If
            End If


        End With
        grdDevice.DataSource = m_jobData.Tables(0)
        grdDevice.DataBind()


    End Sub
End Class
