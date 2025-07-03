#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:16 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/mpBulletin.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On

Namespace eCAMS

    Public Class mpBulletin
        Inherits BulletinBasePage

        Protected Overrides Sub Process()
            Dim bShowBulletin As Boolean
            Call MyBase.SetDE(Me.hdBulletinID, Me.placeholderBody, Me.PanelButtonOK, Me.PanelButonAccept, bShowBulletin)
            If bShowBulletin then
                ' ''there is bulletin to be viewed, so disable menu first
                'Dim myMenu As Menu
                'myMenu = CType(Me.Master.FindControl("Menu1"), Menu)
                'myMenu.Enabled = False

            Else
                Call Server.Transfer("mpFSPJobList.aspx")

            End If
        End Sub

        Protected Sub btnAccept_Click(sender As Object, e As EventArgs) Handles btnAccept.Click
            MyBase.btnAccept(Me.hdBulletinID,"mpFSPJobList.aspx")
        End Sub

        Protected Sub btnDecline_Click(sender As Object, e As EventArgs) Handles btnDecline.Click
            MyBase.btnDecline(Me.hdBulletinID, "mpFSPJobList.aspx","mpLogout.aspx")
        End Sub

        Protected Sub btnOK_Click(sender As Object, e As EventArgs) Handles btnOK.Click
            MyBase.btnOK(Me.hdBulletinID, "mpFSPJobList.aspx")
        End Sub
    End Class
End Namespace