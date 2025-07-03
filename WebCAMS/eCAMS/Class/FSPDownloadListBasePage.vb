#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/09/13 17:03 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPDownloadListBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Imports System.Data
Namespace eCAMS
Public Class FSPDownloadListBasePage
        Inherits MemberPageBase

    Protected infoError As String = ""

    Protected Sub BindGrid(ByRef pGRD As DataGrid, byref pREP As Repeater)
        Dim ds As DataSet
        Dim dlResult As DataLayerResult
        Dim selectedCategoryID As String
        Dim dv As DataView

        Try
            selectedCategoryID = m_DataLayer.SelectedDownloadCategoryID

            dlResult = m_DataLayer.GetDownload("", selectedCategoryID, m_renderingStyle)
            If dlResult = DataLayerResult.Success Then
                ds = m_DataLayer.dsDownloads
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
            End If
        Catch ex As Exception
            infoError = "Failed to list the downloads"
        End Try
    End Sub
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
            infoError = "FSP Only Page. Abort."
            Exit Sub
        End If
        MyBase.Page_Load(sender, e)
    End Sub

End Class
End Namespace