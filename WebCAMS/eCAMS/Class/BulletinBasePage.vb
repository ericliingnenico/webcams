#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:13 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/BulletinBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
Public Class BulletinBasePage
        Inherits MemberPageBase

        protected Sub SetDE(ByRef hdBulletinID As HiddenField, ByRef placeholderBody As PlaceHolder, ByRef panelButtonOK As Panel, ByRef panelButtonAccept As Panel, ByRef hasBulletinToShow As Boolean)
            ''set page title
            Me.PageTitle = "Bulletin"
            If m_DataLayer.GetBulletin("", 1) = DataLayerResult.Success AndAlso m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
                ''set BulletinID
                hdBulletinID.Value = m_DataLayer.dsTemp.Tables(0).Rows(0)("BulletinID").ToString

                placeholderBody.Controls.Add(New LiteralControl(m_DataLayer.dsTemp.Tables(0).Rows(0)("Body").ToString))
                placeholderBody.Controls.Add(New LiteralControl("<P></P><P>Date Published:" + m_DataLayer.dsTemp.Tables(0).Rows(0)("UpdatedDateTime").ToString + "</P>"))
                If m_DataLayer.dsTemp.Tables(0).Rows(0)("ButtonTypeID").ToString = "1" Then
                    panelButtonOK.Visible = True
                    panelButtonAccept.Visible = False
                Else
                    panelButtonOK.Visible = False
                    panelButtonAccept.Visible = True
                End If
                m_DataLayer.BulletinLogoffOnDecline = (m_DataLayer.dsTemp.Tables(0).Rows(0)("ActionOnDeclined").ToString = "2")
                m_DataLayer.BulletinMoreToShow = (m_DataLayer.dsTemp.Tables(0).Rows.Count > 1)

                hasBulletinToShow = True

            Else
                hasBulletinToShow = False
            End If

        End Sub

        Protected Sub btnOK(ByRef hdBulletinID As HiddenField, ByVal nextPage As String)
            ''log the action
            m_DataLayer.PutBulletinViewLog(CType(hdBulletinID.Value, Int32), 1)
            ''display home page
            If m_DataLayer.BulletinMoreToShow Then
                Call Process()
            Else
                Call Server.Transfer(nextPage)
            End If

        End Sub

        Protected Sub btnAccept(ByRef hdBulletinID As HiddenField, ByVal nextPage As String)
            ''log the action
            m_DataLayer.PutBulletinViewLog(CType(hdBulletinID.Value, Int32), 2)

            ''display home page
            If m_DataLayer.BulletinMoreToShow Then
                Call Process()
            Else
                Call Server.Transfer(nextPage)
            End If

        End Sub

        Protected Sub btnDecline(ByRef hdBulletinID As HiddenField, ByVal nextPage As String, ByVal logoutPage As String)
            ''log the action
            m_DataLayer.PutBulletinViewLog(CType(hdBulletinID.Value, Int32), 3)

            ''display home page
            If m_DataLayer.BulletinLogoffOnDecline Then
                Call Server.Transfer(logoutPage)
            Else
                If m_DataLayer.BulletinMoreToShow Then
                    Call Process()
                Else
                    Call Server.Transfer(nextPage)
                End If

            End If
        End Sub


End Class

End Namespace