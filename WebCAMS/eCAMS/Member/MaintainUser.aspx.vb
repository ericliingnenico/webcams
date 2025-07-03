'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:50 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/MaintainUser.aspx.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System.Drawing

Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: MaintainUser
'
' Description: 
'   User details maintenance page
'----------------------------------------------------------------


Partial Class MaintainUser
    Inherits MemberPageBase
    Protected WithEvents CompareValidator1 As System.Web.UI.WebControls.CompareValidator

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
        Call SetDE()
    End Sub

    '----------------------------------------------------------------
    ' SetDE:
    '   Set data entry fields for this page
    '----------------------------------------------------------------
    Private Sub SetDE()
        ''set page title
        Me.PageTitle = "Maintain user"

        ''Set Info Label
        ''lblFormTitle.Text = "Update User"
        ''Set current details
        With m_DataLayer.CurrentUserInformation
            txtUserName.Value = .UserName
            txtEmailAddress.Value = .EmailAddress
            txtPhone.Value = .Phone
            txtFax.Value = .Fax
        End With
    End Sub

    '*************** Events Handlers ***************
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)

        ''Set initial Focus
        Call SetFocus(txtUserName)
    End Sub

    Private Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click
        Dim dlResult As DataLayerResult
        dlResult = m_DataLayer.UpdateUser(txtUserName.Value, txtEmailAddress.Value, txtPhone.Value, txtFax.Value, m_DataLayer.CurrentUserInformation.FSPID)
        With lblFormTitle
            If dlResult = DataLayerResult.Success Then
                .Text = "User details were updated successfully."
                ''.ForeColor = Color.Red
            Else
                .Text = "User details were failed to update."
                .ForeColor = Color.Red
            End If
        End With

    End Sub

End Class

End Namespace
