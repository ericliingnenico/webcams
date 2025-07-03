'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/clsTool.vb $-->
'<!--$$NoKeywords: $-->

Option Strict On
Imports System
Imports System.Text
Imports System.Web.UI
Imports System.Security.Cryptography


Namespace eCAMS

'----------------------------------------------------------------
' Namespace: eCAMS
' Class: clsTool
'
' Description: 
'   Wrapper of tools used in CAMS
'----------------------------------------------------------------

Public Class clsTool
    '----------------------------------------------------------------
    ' NullToValue:
    '   Fill a combox with elements in an array
    '----------------------------------------------------------------
    Public Shared Function NullToValue(ByVal pData As Object, ByVal pValue As Integer) As Integer
        If pData Is System.DBNull.Value Then
            Return pValue
        Else
            Return CType(pData, Integer)
        End If
    End Function
    Public Shared Function NullToValue(ByVal pData As Object, ByVal pValue As Long) As Long
        If pData Is System.DBNull.Value Then
            Return pValue
        Else
            Return CType(pData, Long)
        End If
    End Function
    Public Shared Function NullToValue(ByVal pData As Object, ByVal pValue As Boolean) As Boolean
        If pData Is System.DBNull.Value Then
            Return pValue
        Else
            Return CType(pData, Boolean)
        End If
    End Function
    Public Shared Function NullToValue(ByVal pData As Object, ByVal pValue As String) As String
        If pData Is System.DBNull.Value Then
            Return pValue
        Else
            Return CType(pData, String)
        End If
    End Function
    Public Shared Function NullToValue(ByVal pData As Object, ByVal pValue As Date) As Date
        If pData Is System.DBNull.Value Then
            Return pValue
        Else
            Return CType(pData, Date)
        End If
    End Function

        '----------------------------------------------------------------
        ' EncryptPWD:
        '   Encrypt pPWD, MD5 encrypt.
        '----------------------------------------------------------------

        Public Shared Function EncryptPWD(ByVal pPWD As String) As Byte()
            'Encrypt the password before saving it in the database
            Dim MD5Hasser As New MD5CryptoServiceProvider
            Dim Encoder As New UTF8Encoding

            Return MD5Hasser.ComputeHash(Encoder.GetBytes(pPWD))

        End Function


        ' Helper function to generate random OTP
        Public Shared Function GenerateOTP(length As Integer) As String
            Dim random As New Random()
            Dim otpBuilder As New StringBuilder()

            For i As Integer = 1 To length
                otpBuilder.Append(random.Next(0, 10).ToString())
            Next

            Return otpBuilder.ToString()
        End Function


        ' Function to extract the domain from an email address
        Public Shared Function ExtractDomainFromEmail(email As String) As String
            ' Find the position of the '@' symbol
            Dim atSymbolIndex As Integer = email.IndexOf("@")

            ' If the '@' symbol exists, extract the domain
            If atSymbolIndex >= 0 Then
                Return email.Substring(atSymbolIndex + 1)
            Else
                Throw New ArgumentException("Invalid email address: '@' symbol not found.")
            End If
        End Function
    End Class
'----------------------------------------------------------------
' Namespace: eCAMS
' Class: crTool
'
' Description: 
'   Crystal report tool
'----------------------------------------------------------------

Public Class crTool
        'Public Shared Sub LogonToReport(ByRef pReport As ReportDocument, _
        '                        ByVal pServer As String, _
        '                        ByVal pDatabase As String, _
        '                        ByVal pID As String, _
        '                        ByVal pPassword As String)
        '    Dim logonInfo As New TableLogOnInfo()
        '    Dim table As Table

        '    ' Set the logon information for each table.
        '    For Each table In pReport.Database.Tables
        '        ' Get the TableLogOnInfo object.
        '        logonInfo = table.LogOnInfo
        '        ' Set the server or ODBC data source name, database name, 
        '        ' user ID, and password.
        '        logonInfo.ConnectionInfo.ServerName = pServer
        '        logonInfo.ConnectionInfo.DatabaseName = pDatabase
        '        logonInfo.ConnectionInfo.UserID = pID
        '        logonInfo.ConnectionInfo.Password = pPassword
        '        ' Apply the connection information to the table.
        '        table.ApplyLogOnInfo(logonInfo)
        '    Next table
        'End Sub

End Class
End Namespace
