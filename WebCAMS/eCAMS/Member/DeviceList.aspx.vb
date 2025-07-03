#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/DeviceList.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: DeviceList
'
' Description: 
'   Device search result page
'----------------------------------------------------------------
Partial Class DeviceList
    Inherits MemberPageBase


#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub

    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region
#Region "Functions"
    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub
    '----------------------------------------------------------------
    ' GetContext:
    '   Get pass-in param, such as Query string, form hidden fields
    '----------------------------------------------------------------
    Protected Overrides Sub GetContext()
        With Request
            ''Only assign the value when it is passed in as query string
            If .QueryString("CID") <> "" Then
                m_DataLayer.SelectedClientIDForDeviceSearch = .QueryString("CID").Trim
            End If

            If .QueryString("SN") <> "" Then
                m_DataLayer.SelectedSerialForDeviceSearch = .QueryString("SN").Trim
            End If

        End With
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Device List"

        ''Set SearchAgainURL
        SearchAgainURL.NavigateUrl = "../Member/DeviceSearch.aspx"
        SearchAgainURL.Text = "" ''"Search again"
    End Sub

    '----------------------------------------------------------------
    ' BindGrid:
    '   Bind the returned dataset to grid
    '----------------------------------------------------------------
    Private Sub BindGrid()
        Dim dlResult As DataLayerResult
        ''Set PageSize to Grid
        grdJob.PageSize = m_DataLayer.SelectedPageSize

        dlResult = m_DataLayer.GetDevices(m_DataLayer.SelectedClientIDForDeviceSearch, m_DataLayer.SelectedSerialForDeviceSearch)
        If dlResult = DataLayerResult.Success Then

            ''Set record found info
            If m_DataLayer.dsDevices.Tables(0).Rows.Count > 0 Then
                lblListInfo.Text = m_DataLayer.dsDevices.Tables(0).Rows.Count.ToString & _
                        " records found  (display page " & _
                        CType((grdJob.CurrentPageIndex + 1), String) & _
                        " with max " & _
                        grdJob.PageSize.ToString & _
                        " records per page)"
            Else
                lblListInfo.Text = "No records found"
            End If
            'bind grid
            Try
                grdJob.DataSource = m_DataLayer.dsDevices
                grdJob.DataBind()
            Catch exc As Exception
            Finally
                ''''Hide the grid when no records returned
                'If grdJob.Items.Count = 0 Then
                '    grdJob.Visible = False
                'End If
            End Try
        End If

    End Sub

#End Region
#Region "Event"
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid()
    End Sub

#End Region


End Class

End Namespace
