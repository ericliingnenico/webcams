#Region "vss"
'<!--$$Revision: 5 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:16 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpFSPMain.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Namespace eCAMS
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: mpFSPMain
'
' Description: 
'   Home Page - PDA portal
'----------------------------------------------------------------
Partial Class mpFSPMain
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

#Region "Function"
    Protected Overrides Sub Process()
        Call SetDE()
        If Not m_DataLayer.CurrentUserInformation.CanUseNewPCAMS then
                Response.Redirect("pFSPMain.aspx")
        End If
    End Sub
    Private Sub SetDE()
        Me.PageTitle = "Main"
    End Sub

#End Region
#Region "Event"

#End Region
End Class

End Namespace
