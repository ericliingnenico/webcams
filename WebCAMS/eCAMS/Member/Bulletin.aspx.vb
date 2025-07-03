'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:14 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/Bulletin.aspx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On

Imports System
Imports System.Data

Namespace eCAMS
    Partial Class Bulletin
        Inherits BulletinBasePage

#Region "Functions"
        Protected Overrides Sub Process()
            Dim bShowBulletin As Boolean
            Call MyBase.SetDE(Me.hdBulletinID, Me.placeholderBody, Me.PanelButtonOK, Me.PanelButonAccept, bShowBulletin)
            If bShowBulletin Then
                ''there is bulletin to be viewed, so disable menu first
                Dim myMenu As Menu
                myMenu = CType(Me.Master.FindControl("Menu1"), Menu)
                myMenu.Enabled = False

            Else
                Call Server.Transfer("Member.aspx")

            End If
        End Sub
        'Private Sub SetDE()
        '    ''set page title
        '    Me.PageTitle = "Bulletin"
        '    If m_DataLayer.GetBulletin("", 1) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
        '        ''set BulletinID
        '        hdBulletinID.Value = m_DataLayer.dsTemp.Tables(0).Rows(0)("BulletinID").ToString

        '        Me.placeholderBody.Controls.Add(New LiteralControl(m_DataLayer.dsTemp.Tables(0).Rows(0)("Body").ToString))
        '        Me.placeholderBody.Controls.Add(New LiteralControl("<P></P><P>Date Published:" + m_DataLayer.dsTemp.Tables(0).Rows(0)("UpdatedDateTime").ToString + "</P>"))
        '        If m_DataLayer.dsTemp.Tables(0).Rows(0)("ButtonTypeID").ToString = "1" Then
        '            Me.PanelButtonOK.Visible = True
        '            Me.PaneButonAceept.Visible = False
        '        Else
        '            Me.PanelButtonOK.Visible = False
        '            Me.PaneButonAceept.Visible = True
        '        End If
        '        m_DataLayer.BulletinLogoffOnDecline = (m_DataLayer.dsTemp.Tables(0).Rows(0)("ActionOnDeclined").ToString = "2")
        '        m_DataLayer.BulletinMoreToShow = (m_DataLayer.dsTemp.Tables(0).Rows.Count > 1)

        '        ''there is bulletin to be viewed, so disable menu first
        '        Dim myMenu As Menu
        '        myMenu = CType(Me.Master.FindControl("Menu1"), Menu)
        '        myMenu.Enabled = False

        '    Else
        '        Call Server.Transfer("Member.aspx")
        '    End If

        'End Sub
#End Region

#Region "Events"

        Protected Sub btnOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnOK.Click
            Call MyBase.btnOK(Me.hdBulletinID, "Member.aspx")
            ' ''log the action
            'm_DataLayer.PutBulletinViewLog(CType(hdBulletinID.Value, Int32), 1)
            ' ''display home page
            'If m_DataLayer.BulletinMoreToShow Then
            '    Call Process()
            'Else
            '    Call Server.Transfer("Member.aspx")
            'End If

        End Sub

        Protected Sub btnAccept_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAccept.Click
            Call MyBase.btnAccept(Me.hdBulletinID, "Member.aspx")

            ' ''log the action
            'm_DataLayer.PutBulletinViewLog(CType(hdBulletinID.Value, Int32), 2)

            ' ''display home page
            'If m_DataLayer.BulletinMoreToShow Then
            '    Call Process()
            'Else
            '    Call Server.Transfer("Member.aspx")
            'End If

        End Sub

        Protected Sub btnDecline_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnDecline.Click
            Call MyBase.btnDecline(Me.hdBulletinID, "Member.aspx", "Logout.aspx")
            ' ''log the action
            'm_DataLayer.PutBulletinViewLog(CType(hdBulletinID.Value, Int32), 3)

            ' ''display home page
            'If m_DataLayer.BulletinLogoffOnDecline Then
            '    Call Server.Transfer("Logout.aspx")
            'Else
            '    If m_DataLayer.BulletinMoreToShow Then
            '        Call Process()
            '    Else
            '        Call Server.Transfer("Member.aspx")
            '    End If

            'End If
        End Sub
#End Region

    End Class

End Namespace
