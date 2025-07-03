'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/03/13 17:26 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPMain.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: FSPMain
'
' Description: 
'   FSP Main page
'----------------------------------------------------------------

Partial Class FSPMain
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
    ''Local Variable
    '*************** Functions ***************
    Protected Overrides Sub Process()
        ' ''force FSP to different pages 
        'If Request.UserAgent.Contains("iPhone")
        '    Response.Redirect("../Member/mpFSPMain.aspx")
        'End If
        'If Request.UserAgent.Contains("Android")
        '    Response.Redirect("../Member/mpFSPMain.aspx")
        'End If
        'If Request.UserAgent.Contains("Blackberry")
        '    Response.Redirect("../Member/jqFSPMain.aspx")
        'End If
        'If Request.UserAgent.Contains("iPad")
        '    Response.Redirect("../Member/jqFSPMain.aspx")
        'End If
        'If Request.Browser.IsMobileDevice then
        '        Response.Redirect("../Member/jqFSPMain.aspx")
        'End If

        Call SetDE()
    End Sub


    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        Me.PageTitle = "FSP Main"

        If Not UserPasswordAlert1.AlertUser Then
            UserPasswordAlert1.Visible = False
        End If
        If Not UserPasswordAlert1.IsPasswordExpired() Then
            If m_DataLayer.GetJobCount = DataLayerResult.Success Then
                ''set swap job hyperlink
                hlSwapJob.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("SwapJobCount").ToString & " " & hlSwapJob.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("SwapJobCount"), Integer) > 0 Then
                    hlSwapJob.NavigateUrl = "../member/FSPJobList.aspx?List=C"
                End If
                ''set install job hyperlink
                hlInstallJob.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("InstallJobCount").ToString & " " & hlInstallJob.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("InstallJobCount"), Integer) > 0 Then
                    hlInstallJob.NavigateUrl = "../member/FSPJobList.aspx?List=I"
                End If
                ''set deinstall job hyperlink
                hlDeinstallJob.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("DeinstallJobCount").ToString & " " & hlDeinstallJob.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("DeinstallJobCount"), Integer) > 0 Then
                    hlDeinstallJob.NavigateUrl = "../member/FSPJobList.aspx?List=D"
                End If
                ''set upgrade job hyperlink
                hlUpgradeJob.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("UpgradeJobCount").ToString & " " & hlUpgradeJob.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("UpgradeJobCount"), Integer) > 0 Then
                    hlUpgradeJob.NavigateUrl = "../member/FSPJobList.aspx?List=U"
                End If
                ''set pickpack task hyperlink
                hlPickPackTask.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("PickPackTaskCount").ToString & " " & hlPickPackTask.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("PickPackTaskCount"), Integer) > 0 Then
                    hlPickPackTask.NavigateUrl = "../member/FSPTaskList.aspx?List=1"
                End If

                ''set stock in transit
                hlStockInTransit.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("StockInTransitCount").ToString & " " & hlStockInTransit.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("StockInTransitCount"), Integer) > 0 Then
                    hlStockInTransit.NavigateUrl = "../member/FSPStockList.aspx?md=1"
                End If

                ''set exception jobs count
                hlFSPException.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("FSPExceptionCount").ToString & " " & hlFSPException.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("FSPExceptionCount"), Integer) > 0 Then
                    hlFSPException.NavigateUrl = "../member/FSPJobExceptionList.aspx"
                End If

                ''set stock returned
                hlStockReturned.Text = m_DataLayer.dsJobs.Tables(0).Rows(0).Item("StockReturnedCount").ToString & " " & hlStockReturned.Text
                If CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("StockReturnedCount"), Integer) > 0 Then
                    hlStockReturned.NavigateUrl = "../member/FSPStockList.aspx?md=3"
                End If

                ''set stock take
                If clsTool.NullToValue(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("StockTakeDate"), "") <> "" then
                    hlStockTake.Text =  hlStockTake.Text & CType(m_DataLayer.dsJobs.Tables(0).Rows(0).Item("StockTakeDate"), Date).ToString("dd/M/yyyy") 
                    hlStockTake.NavigateUrl = "../member/FSPStockTake.aspx"
                Else
                    panelStockTake.Visible = False
               End If

                m_DataLayer.SelectedPageSize = 40
                m_DataLayer.SelectedClientIDForJobSearch = "ALL"
            End If
        End If
    End Sub


    '*************** Events Handlers ***************
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

    End Sub

End Class

End Namespace
