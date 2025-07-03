#Region "vss"
'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 4/03/14 10:26 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPDelegationListBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Imports System.Data
Namespace eCAMS
Public Class FSPDelegationListBasePage
        Inherits MemberPageBase

    Protected infoError As String = ""

    Protected Sub BindGrid(ByVal pDate As String, ByRef pGRD As DataGrid, byref pREP As Repeater)
        Dim ds As DataSet
        Dim dlResult As DataLayerResult

        Try
            dlResult = m_DataLayer.GetFSPDelegationList(pDate,CShort(m_renderingStyle))
            If dlResult = DataLayerResult.Success Then
                ds = m_DataLayer.dsTemp
                If Not pGRD is Nothing then
                    pGRD.DataSource = ds.Tables(0)
                    pGRD.DataBind()
                End If
                If Not pREP is Nothing then
                    pREP.DataSource = ds.Tables(0)
                    pREP.DataBind()
                End If
            End If
        Catch ex As Exception
            infoError = "Failed to list the FSP Delegation"
        End Try
    End Sub
    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        If m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
            infoError = "FSP Only Page. Abort."
            Exit Sub
        End If
    End Sub

End Class
End Namespace
