#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/07/11 14:24 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/FSPJobException.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On


Namespace eCAMS

Partial Class FSPJobException
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

#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        Server.Transfer("FSPJob.aspx")

    End Sub

#End Region
End Class

End Namespace
