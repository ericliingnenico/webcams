#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/02/14 10:57 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/AdminChangeActingFSP.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing

Namespace eCAMS

Partial Class AdminChnageActingFSP
    Inherits MemberPageBase

#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub
    Protected WithEvents btnSearch As System.Web.UI.HtmlControls.HtmlInputButton


    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region


#Region "Function"

    Protected Overrides Sub GetContext()
        With Request

        End With
    End Sub

    Protected Overrides Sub Process()
        SetDE()
    End Sub
    Protected Overrides Sub AddClientScript()

        ''add onblur to txtFSPID
        txtFSPID.Attributes.Add("onblur", "if (isNaN(document.getElementById('" & txtFSPID.ClientID & "').value)) {alert('txtFSPID must be a number'); document.getElementById('" & txtFSPID.ClientID & "').focus(); return false;}")

        Me.SetFocus(txtFSPID)

        Me.TieButton(txtFSPID, btnSave)

    End Sub

    Private Sub SetDE()
        Me.RestrictModuleName = "FSPAdminActingFSP"
        txtFSPID.Value = m_DataLayer.CurrentUserInformation.FSPID.ToString

    End Sub
#End Region

#Region "Event"
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)



    End Sub


    Private Sub btnSave_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.ServerClick
        If m_DataLayer.UpdateUser(m_DataLayer.CurrentUserInformation.UserName, _
                                m_DataLayer.CurrentUserInformation.EmailAddress, _
                                m_DataLayer.CurrentUserInformation.Phone, _
                                m_DataLayer.CurrentUserInformation.Fax, _
                                CType(txtFSPID.Value, Integer)) = DataLayerResult.Success Then
            lblFormTitle.Text = "Acting FSP ID has been changed successfully."

            ''refresh userinfo
            m_DataLayer.GetUserInfo()
            m_DataLayer.FSPChildren = Nothing
            m_DataLayer.FSPFamily = Nothing
        Else
            lblFormTitle.Text = "Failed to change the Acting FSP ID."
            lblFormTitle.ForeColor = Color.Red
        End If
    End Sub
#End Region

End Class

End Namespace
