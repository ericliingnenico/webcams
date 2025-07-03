#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 26/07/12 9:13 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/BulletinViewLogBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On

Namespace eCAMS
    Public Class BulletinViewLogBasePage
            Inherits MemberPageBase
        Protected Sub BindGrid(ByRef pGRD As DataGrid, byref pREP As Repeater)
            Dim dlResult As DataLayerResult
            Dim ds As DataSet
            Dim dv As DataView


            dlResult = m_DataLayer.GetBulletinViewLog(m_renderingStyle)
            If dlResult = DataLayerResult.Success Then
                ds = m_DataLayer.dsTemp
                If m_DataLayer.SelectedSortOrder <> String.Empty AndAlso Not ds.Tables(0).Columns.Contains(m_DataLayer.SelectedSortOrder.Replace(" DESC", "")) Then
                    m_DataLayer.SelectedSortOrder = String.Empty
                End If

                'bind grid
                Try
                    ''using dataview for sorting on column purpose
                    dv = New DataView(ds.Tables(0))
                    If m_DataLayer.SelectedSortOrder <> String.Empty Then
                        dv.Sort = m_DataLayer.SelectedSortOrder
                    End If

                    If Not pGRD is Nothing then
                        pGRD.DataSource = dv
                        pGRD.DataBind()
                    End If
                    If Not pREP is Nothing then
                        pREP.DataSource = dv
                        pREP.DataBind()
                    End If
                Catch exc As Exception
                Finally
                End Try

            End If

        End Sub

    End Class
End Namespace