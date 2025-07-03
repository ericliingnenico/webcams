'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 8/02/13 14:57 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPJobSheetExt.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: FSPJobSheet
'
' Description: 
'   FSP Job Service Request Form
'----------------------------------------------------------------

Imports System.Drawing

Namespace eCAMS

Partial Class Member_FSPJobSheetExt
    Inherits PageBase

    ''Local Variable
    Private m_JobID As String
    '*************** Functions ***************
    Protected Overrides Sub Process()
        Call SetDE()
    End Sub

    '----------------------------------------------------------------
    ' GetContext:
    '   Get pass-in param, such as Query string, form hidden fields
    '----------------------------------------------------------------
    Protected Overrides Sub GetContext()
        With Request
            m_JobID = CType(.QueryString("JID").Trim, String)
        End With
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        Dim dlResult As DataLayerResult
        Dim arr_idx As Integer = 0
        ''Set Info Label
        lblFormTitle.Text = ""
        ''Read data
        Dim arr_JobID As Array = m_JobID.Split(",".ToCharArray())
        Dim myJobID As String
        For Each myJobID In arr_JobID
            dlResult = m_DataLayer.GetFSPJobSheetData(Convert.ToInt64(myJobID))
            If dlResult = DataLayerResult.Success AndAlso m_DataLayer.dsJob.Tables.Count > 0 Then
                If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                    lblFormTitle.Visible = False
                    arr_idx += 1
                    Call LoadJobSheet((arr_idx > 1))
                Else
                    lblFormTitle.Text = "Job [" & myJobID & "] not found"
                    lblFormTitle.ForeColor = Color.Red
                End If
            End If

        Next

    End Sub
    ''' <summary>
    ''' Add css HTML Page break if needs
    ''' </summary>
    ''' <param name="pAddPageBreakBefore"></param>
    ''' <remarks></remarks>
    Private Sub LoadJobSheet(ByVal pAddPageBreakBefore As Boolean)
        Dim oJob As UserControl_JobSheet = CType(LoadControl("~/UserControl/JobSheet.ascx"), UserControl_JobSheet)
        oJob.JobData = m_DataLayer.dsJob
        ''style='page-break-before: always;  not working on IE7
        If pAddPageBreakBefore Then
            Me.placeholderJobSheet.Controls.Add(New LiteralControl("<div style='page-break-after: always; height:1px'></div> "))
        End If
        Me.placeholderJobSheet.Controls.Add(oJob)
        'If pAddPageBreakBefore Then
        '    Me.Controls.Add(New LiteralControl("</p>"))
        'End If


    End Sub

    '*************** Events Handlers ***************
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        'Put user code to initialize the page here
        If Not m_DataLayer.IsLogin Then
            ''Display no permission error message, instead of showing login page
            lblFormTitle.Text = "Your session has expired. Please close the window and re-login."
            lblFormTitle.ForeColor = Color.Red
        Else
            Call GetContext()
            Call SetDE()
        End If

    End Sub

End Class

End Namespace

