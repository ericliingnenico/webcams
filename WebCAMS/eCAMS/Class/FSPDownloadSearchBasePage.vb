#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/09/13 17:03 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPDownloadSearchBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
Public Class FSPDownloadSearchBasePage
        Inherits MemberPageBase
    Protected Sub SetDE(ByRef pCbo As DropDownList)
        ''Set Category Combox
        If m_DataLayer.FSPDownloadCategory Is Nothing Then
            If m_DataLayer.GetDownloadCategoryAll() = DataLayerResult.Success Then
                m_DataLayer.FSPDownloadCategory = m_DataLayer.dsDownloads
            End If
        End If
        pCbo.DataSource = m_DataLayer.FSPDownloadCategory
        pCbo.DataTextField = "CategoryName"
        pCbo.DataValueField = "DownloadCategoryID"
        pCbo.DataBind()

        ''Set the selected CategoryID
        If m_DataLayer.SelectedDownloadCategoryID <> String.Empty Then
            Call ScrollToCboValue(pCbo, m_DataLayer.SelectedDownloadCategoryID)
        End If
    End Sub

    Protected Sub Search(ByRef pCbo As DropDownList, ByVal pNextPage As String)
        m_DataLayer.SelectedDownloadCategoryID = pCbo.SelectedValue.ToString()
        Call Response.Redirect(pNextPage)
    End Sub

End Class
End Namespace
