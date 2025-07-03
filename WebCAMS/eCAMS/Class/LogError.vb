#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/LogError.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Imports System.Diagnostics


Namespace eCAMS

Public NotInheritable Class LogError

    Private Const c_EventSource As String = "eCAMS"
    Private Const c_LogName As String = "Application"

    Public Shared Sub Write(ByVal pErrMsg As String, ByVal WriteToDB As Boolean)
        Dim m_DataLayer As New DataLayer
        Try
            m_DataLayer.PutErrorLog(pErrMsg)
        Catch
        End Try
    End Sub
    Public Shared Sub Write(ByVal pErrMsg As String)
        Try
            'create the event source if neccessary
            If Not EventLog.SourceExists(c_EventSource) Then
                EventLog.CreateEventSource(c_EventSource, c_LogName)
            End If

            'write the message as an error
            Dim msg As EventLog = New EventLog(c_LogName)
            msg.Source = c_EventSource
            msg.WriteEntry(pErrMsg, EventLogEntryType.Error)
        Catch
        End Try
    End Sub

End Class

End Namespace
