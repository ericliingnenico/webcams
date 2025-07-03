'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 11/07/11 9:28 $-->
'<!--$$Logfile: /eCAMSSource2010/wseCAMS/UserInformation.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On

Imports System


Public Class UserInformation
    Public UserID As Integer
    Public EmailAddress As String
    Public Password As Byte()
    Public UserName As String
    Public Phone As String
    Public Fax As String
    Public FSPID As Integer
    Public IsActive As Boolean
    Public UpdateTime As DateTime
    Public MenuSet As String
    Public ExpiryDate As DateTime
    ''Expanded attributes
    Public ClientIDs As String
    Public LoginDateTime As DateTime
    Public IsLoginAsClient As Boolean
    Public ModuleList As String
    Public CanUseNewPCAMS As Boolean
End Class

