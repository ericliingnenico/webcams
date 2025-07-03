'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 1/11/13 11:40 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/pFSPDownloadList.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.Drawing
Imports System.Data
Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: pFSPDownloadList
'
' Description: 
'   FSP Software Download List - PDA portal
'----------------------------------------------------------------

Partial Class pFSPDownloadList
    Inherits PDAPageBase

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

#Region "Function"
    Protected Overrides Sub Process()
        Call SetDE()
        Call BindGrid()
    End Sub

    Private Sub SetDE()
        Me.PageTitle = "DownloadList"

        Me.lblListInfo.Text = "PDA Software Download"
    End Sub
    Private Sub BindGrid()
        Dim ds As DataSet
        Dim dlResult As DataLayerResult

        dlResult = m_DataLayer.GetDownload("", "1",m_renderingStyle)
        If dlResult = DataLayerResult.Success Then
            ds = m_DataLayer.dsDownloads

            Try
                grdJob.DataSource = ds
                grdJob.DataBind()
            Catch ex As Exception
                Me.lblListInfo.Text += ". Failed to list the downloads"
            End Try
        End If
    End Sub

#End Region
#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
            Me.lblListInfo.Text = "FSP Only Page. Abort."
            Exit Sub
        End If
    End Sub
    Protected Sub grdJob_PageIndexChanged(ByVal source As System.Object, ByVal e As System.Web.UI.WebControls.DataGridPageChangedEventArgs)
        Call m_DataLayer.VerifyLogin()
        grdJob.CurrentPageIndex = e.NewPageIndex
        Call BindGrid()
    End Sub

#End Region

End Class

End Namespace
