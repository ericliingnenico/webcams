#Region "vss"
'<!--$$Revision: 8 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 19/03/14 14:19 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/FSPDelegationBasePage.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Web.HttpContext
Imports eCAMS.AuthWS
Namespace eCAMS
Public Class FSPDelegationBasePage
        Inherits MemberPageBase
    ''Local Variable
    Protected m_LogID As Integer
    Protected m_Date As String
    Protected m_FSP As String
    Protected lblMsg As New Label
    Protected Overrides Sub GetContext()
        With Request
            m_LogID = Convert.ToInt32(.Item("id"))
            m_Date = Convert.ToString(.Item("dt"))
            m_FSP = Convert.ToString(.Item("fd"))
        End With
    End Sub
    Protected Sub PopulateFSP(pCbo As DropDownList)
        ''Cache FSPChildren
        m_DataLayer.CacheFSPChildren()

        ''Set FSP Combox
        pCbo.DataSource = m_DataLayer.FSPChildren.tables(0)
        pCbo.DataTextField = "FSPDisplayName"
        pCbo.DataValueField = "FSPID"
        pCbo.DataBind()
    End Sub
    Protected Sub PopulateAssignedToFSP(pCbo As DropDownList)
        Dim dt As DataTable
        Dim row As DataRow
        Dim dv As DataView
        ''Cache FSPChildren
        m_DataLayer.CacheFSPFamily()

        dt = m_DataLayer.FSPFamily.tables(0).Copy
        row = dt.NewRow
        row("FSPID") = DBNull.Value
        row("FSPDisplayName") = "Depot Unavailable"
        dt.Rows.Add(row)

        If CType(Current.Session("UserInfo"), UserInformation).MenuSet = "Menu_FSP_Admin" then
            row = dt.NewRow
            row("FSPID") = 328
            row("FSPDisplayName") = "To 328"
            dt.Rows.Add(row)

            row = dt.NewRow
            row("FSPID") = -1
            row("FSPDisplayName") = "Over Capacity"
            dt.Rows.Add(row)
        End If

        dv=New DataView(dt)
        dv.Sort = "FSPDisplayName"

        ''Set FSP Combox
        pCbo.DataSource = dv
        pCbo.DataTextField = "FSPDisplayName"
        pCbo.DataValueField = "FSPID"
        pCbo.DataBind()
    End Sub
    Protected Sub PopulateReason(pCbo As DropDownList)
        If m_DataLayer.GetFSPDelegationReason() = DataLayerResult.Success Then
            pCbo.DataSource = m_DataLayer.dsTemp
            pCbo.DataTextField = "Reason"
            pCbo.DataValueField = "ReasonID"
            pCbo.DataBind()
        End If
    End Sub
    Protected Sub DisplayFSPDelegation(pTxtLogID As HiddenField, pPlaceholderErrorMsg As PlaceHolder,  pcboFSP As DropDownList, _
                                  pTxtFromDate As TextBox, pTxtFromTime As TextBox, pTxtToDate As TextBox, pTxtToTime As TextBox, _
                                  pCboAssignedToFSP As DropDownList, pCboReason As DropDownList, pTxtNote As TextBox, _
                                  pbtnSave As Button, pbtnCancel As Button)
        Dim ds As DataSet
        pTxtLogID.Value = CStr(m_LogID)
        PositionMsgLabel(pPlaceholderErrorMsg, lblMsg) 
        pbtnCancel.Visible = False  ''hide cancel button first
        Try
            Call PopulateFSP(pcboFSP)
            Call PopulateAssignedToFSP(pcboAssignedToFSP)
            Call PopulateReason(pcboReason)

            If m_DataLayer.GetFSPDelegation(m_LogID) = DataLayerResult.Success Then
                ds = m_DataLayer.dsTemp
                With ds.Tables(0)
                    If .Rows.Count > 0 Then
                        If Not .Rows(0)("FromDate") Is DBNull.Value Then
                            ptxtFromDate.Text = Convert.ToDateTime(.Rows(0)("FromDate")).ToString("dd/MM/yy")
                            ptxtFromTime.Text = Convert.ToDateTime(.Rows(0)("FromDate")).ToString("HHmm")
                        End If
                        If Not .Rows(0)("ToDate") Is DBNull.Value Then
                            ptxtToDate.Text = Convert.ToDateTime(.Rows(0)("ToDate")).ToString("dd/MM/yy")
                            ptxtToTime.Text = Convert.ToDateTime(.Rows(0)("ToDate")).ToString("HHmm")
                        End If
                        If Not .Rows(0)("FSP") Is DBNull.Value Then
                            ScrollToCboValue(pcboFSP, .Rows(0)("FSP").ToString)
                        End If
                        If Not .Rows(0)("AssignToFSP") Is DBNull.Value Then
                            ScrollToCboValue(pcboAssignedToFSP, .Rows(0)("AssignToFSP").ToString)
                        Else
                            ScrollToCboText(pcboAssignedToFSP, "Depot Unavailable")
                        End If
                        If Not .Rows(0)("ReasonID") is DBNull.Value then
                            ScrollToCboValue(pCboReason, .Rows(0)("ReasonID").ToString)
                        End If
                        If Not .Rows(0)("StatusID") is DBNull.Value andalso .Rows(0)("StatusID").ToString= "4" then
                            pbtnSave.Text = "Activate Delegation"
                        End If
                        If Not .Rows(0)("Note") is DBNull.Value then
                            pTxtNote.Text = .Rows(0)("Note").ToString
                        End If
                        
                        pbtnCancel.Visible = True
                    Else
                        If m_LogID = -1 then  ''add new delegation
                            ''no matching Delegation record found
                            If pTxtFromDate.Text = "" andalso m_Date <> "" then
                                pTxtFromDate.Text = m_Date
                                pTxtToDate.Text = m_Date
                            End If
                            If m_FSP <> "" then
                                ScrollToCboValue(pcboFSP, m_FSP)
                            End If
                        Else
                            DisplayErrorMessage(lblMsg, "No record found!")
                        End If
                    End If

                End With
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
    End Sub
    Protected Sub SaveFSPDelegation(
                    ByRef pLogID As Integer, _
                    ByVal pFSP As String, _
                    ByVal pFromDateTime As DateTime, _
                    ByVal pToDateTime As DateTime, _
                    ByVal pAssignedToFSP As String, _
                    ByVal pNote As String, _
                    ByVal pReasonID As String, _
                    ByVal pStatusID As String, _                                   
                    ByVal pNextPage As String, _
                    pPlaceholderErrorMsg As PlaceHolder)
        PositionMsgLabel(pPlaceholderErrorMsg, lblMsg) 
        Try
            If m_DataLayer.PutFSPDelegation(pLogID, pFSP, pFromDateTime, pToDateTime, pAssignedToFSP, pNote, pReasonID, pStatusID) = DataLayerResult.Success Then
                Response.Redirect(pNextPage)
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
    End Sub
    Protected Sub CancelFSPDelegation(
                    ByRef pLogID As Integer, _
                    ByVal pNextPage As String, _
                    pPlaceholderErrorMsg As PlaceHolder)
        PositionMsgLabel(pPlaceholderErrorMsg, lblMsg) 
        Try
            If m_DataLayer.CancelFSPDelegation(pLogID) = DataLayerResult.Success Then
                Response.Redirect(pNextPage)
            End If
        Catch ex As Exception
            DisplayErrorMessage(lblMsg, ex.Message)
        End Try
    End Sub

End Class
End Namespace
