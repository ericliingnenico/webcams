'<!--$$Revision: 1 $-->
'<!--$$Author: Dhile $-->
'<!--$$Date: 15/01/25 9:28 $-->
'<!--$$Logfile: /eCAMSSource2010/wseCAMS/OTPInfo.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On

Imports System


Public Class UserMFAFeatureParam
    Public UserID As Integer
    Public ClientID As String
    Public FeatureID As Integer
    Public FeatureName As String
    Public OTPEmailDomainNameList As List(Of String)
    Public OTPLength As Integer
    Public OTPExpiryMinute As Integer
    Public OTPMaxNoRetries As Integer
End Class


Public Class UserOTPInformation
    'User OTP 
    Public UserID As Integer
    Public Passcode As Byte()
    Public CreatedDateTime As DateTime
    Public ExpiryDateTime As DateTime
End Class