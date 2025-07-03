#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 24/02/14 14:47 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPReAssignJobBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
Public Class FSPReAssignJobBasePage
            Inherits MemberPageBase

    ''Local Variable
    Protected m_JobID As int64
    Protected lblMsg As New Label


    Protected Overrides Sub GetContext()
        With Request
            m_JobID = Convert.ToInt64(.Item("id"))
        End With
    End Sub
    Protected Sub DisplayAssignTo(pTxtJobID As HiddenField, pPlaceholderErrorMsg As PlaceHolder,  pCboAssignedTo As DropDownList, pLblJobDetails As Label, pRepeaterDevice As Repeater)
        pTxtJobID.Value = CStr(m_jobID)
        PositionMsgLabel(pPlaceholderErrorMsg, lblMsg) 
        Try
            m_DataLayer.GetFSPJobSheetData(m_JobID)

            ''Cache FSPChildren
            m_DataLayer.CacheFSPFamily()
            ''Set FSP Combox
            pCboAssignedTo.DataSource = m_DataLayer.FSPFamily
            pCboAssignedTo.DataTextField = "FSPDisplayName"
            pCboAssignedTo.DataValueField = "FSPID"
            pCboAssignedTo.DataBind()

            With m_DataLayer.dsJob.Tables(0).Rows(0)
                pLblJobDetails.Text = "<b>" + .Item("JobID").ToString  + " " _
                                + .Item("ClientID").ToString  + " " _
                                + .Item("JobType").ToString   + " " _
                                + .Item("City").ToString   + " " _
                                + .Item("Name").ToString   + "</b> "
            End With

            pRepeaterDevice.DataSource = m_DataLayer.dsJob.Tables(0)
            pRepeaterDevice.DataBind()

        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
    End Sub
    Protected Sub ReAssignJob(ByVal pJobID As Int64, byval pReAssignTo As Int32, ByVal pNextPage As String,pPlaceholderErrorMsg As PlaceHolder)
        Dim ret As DataLayerResult
        PositionMsgLabel(pPlaceholderErrorMsg, lblMsg) 
        Try
            ret = m_DataLayer.FSPReAssignJob(pJobID,pReAssignTo)
            If ret = DataLayerResult.Success Then
                Response.Redirect(pNextPage)
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
    End Sub

End Class
End Namespace
