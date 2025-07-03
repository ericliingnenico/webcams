#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/PopupMsgBox.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On


Namespace eCAMS

Partial Class PopupMsgBox
    Inherits MemberPopupBase

#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub
    Protected WithEvents lblFormTitle As System.Web.UI.WebControls.Label
    Protected WithEvents lblAssignedTo As System.Web.UI.WebControls.Label
    Protected WithEvents cboAssignedTo As System.Web.UI.WebControls.DropDownList
    Protected WithEvents Label2 As System.Web.UI.WebControls.Label
    Protected WithEvents cboRefreshMinute As System.Web.UI.WebControls.DropDownList
    Protected WithEvents Label3 As System.Web.UI.WebControls.Label
    Protected WithEvents lblPageSize As System.Web.UI.WebControls.Label
    Protected WithEvents cboPageSize As System.Web.UI.WebControls.DropDownList
    Protected WithEvents Label1 As System.Web.UI.WebControls.Label
    Protected WithEvents btnSearch As System.Web.UI.HtmlControls.HtmlInputButton


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
        ''Can not call MyBase.Page_Load(sender, e) to avoid a dead loop
        ''because this page beening reference in the PageBase.Page_Load
        ''so we have to overrdie it here
        lblMsg.Text = m_DataLayer.PopupMessage

    End Sub

#End Region
End Class

End Namespace
