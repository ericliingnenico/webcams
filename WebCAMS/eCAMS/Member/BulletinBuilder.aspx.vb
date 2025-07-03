'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/BulletinBuilder.aspx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On
Imports System

Namespace eCAMS

    Partial Class BulletinBuilder
        Inherits MemberPageBase

        Protected Overrides Sub Process()
            Call SetDE()
        End Sub

        Private Sub SetDE()
            ''set page title
            Me.PageTitle = "BulletinBuilder"
            PopulateBulletinCbo()

        End Sub
        Private Sub PopulateBulletinCbo()
            ''only populate it when it is visible
            If m_DataLayer.GetBulletin("", 2) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                ''add New to the top of rows
                Dim dtRow As Data.DataRow
                dtRow = m_DataLayer.dsTemp.Tables(0).NewRow()
                dtRow("BulletinID") = 0
                dtRow("Title") = "<New>"

                m_DataLayer.dsTemp.Tables(0).Rows.InsertAt(dtRow, 0)
                cboBulletin.DataSource = m_DataLayer.dsTemp
                cboBulletin.DataTextField = "Title"
                cboBulletin.DataValueField = "BulletinID"
                cboBulletin.DataBind()
            End If
        End Sub
        Private Sub ShowBulletinDetail(ByVal pBulletinID As String)
            If pBulletinID = "0" Then
                ''new
                Me.txtTitle.Text=""
                Me.txtBody.Value = "" ''clean up
            Else
                If m_DataLayer.GetBulletin(pBulletinID, 2) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                    Me.txtBody.Value = m_DataLayer.dsTemp.Tables(0).Rows(0)("Body").ToString
                    Me.txtTitle.Text = m_DataLayer.dsTemp.Tables(0).Rows(0)("Title").ToString
                    Call ScrollToCboValue(cboActionOnDecline, m_DataLayer.dsTemp.Tables(0).Rows(0)("ActionOnDeclined").ToString)
                    Call ScrollToCboValue(cboButtonType, m_DataLayer.dsTemp.Tables(0).Rows(0)("ButtonTypeID").ToString)
                End If

            End If

        End Sub
        Private Sub SaveBulletin()
            m_DataLayer.PutBulletin(Convert.ToInt32(cboBulletin.SelectedValue), txtTitle.Text, txtBody.Value, Convert.ToInt16(cboButtonType.SelectedValue), Convert.ToInt16(cboActionOnDecline.SelectedValue), 1)
        End Sub
        'Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        '    MyBase.Page_Load(sender, e)

        '    If Page.IsPostBack Then
        '        Call PopulateBulletinCbo()

        '    End If
        'End Sub


        Protected Sub cboBulletin_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cboBulletin.SelectedIndexChanged
            Call ShowBulletinDetail(cboBulletin.SelectedValue)
        End Sub

        Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
            Call SaveBulletin()
            Response.Redirect("SectionPage.aspx?q=5")
        End Sub
    End Class
End Namespace