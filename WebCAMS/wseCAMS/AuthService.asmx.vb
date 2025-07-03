'<!--$$Revision: 3 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 11/07/11 9:28 $-->
'<!--$$Logfile: /eCAMSSource2010/wseCAMS/AuthService.asmx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On
Imports System
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Web.Security
Imports System.Text
Imports System.Configuration
Imports System.Security.Cryptography
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.ApplicationBlocks.Data
Imports System.Collections
Imports Microsoft.VisualBasic

<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class AuthService
     Inherits System.Web.Services.WebService


    Public WithEvents dbConn As System.Data.SqlClient.SqlConnection
    <WebMethod()>
    Public Function GetAuthorizationTicket(ByVal myParam As ArrayList) As String
        'try to authenticate the user
        Dim userID As String
        Dim EmailAddress As String
        Dim Password As Byte()
        EmailAddress = Convert.ToString(myParam(0))
        Password = CType(myParam(1), Byte())
        Try
            userID = CStr(SqlHelper.ExecuteScalar(dbConn, "spWebValidateUser", EmailAddress, Password))
        Finally
            dbConn.Close()
        End Try

        If userID Is Nothing Then
            ' The user name and password combination is not valid.
            Return Nothing
        End If

        'create the ticket
        Dim ticket As New FormsAuthenticationTicket(userID, False, 1)
        Dim encryptedTicket As String = FormsAuthentication.Encrypt(ticket)

        'get the ticket timeout in minutes
        Dim configurationAppSettings As AppSettingsReader = New AppSettingsReader
        Dim timeout As Integer = CInt(configurationAppSettings.GetValue("AuthenticationTicket.Timeout", GetType(Integer)))

        'cache the ticket
        Context.Cache.Insert(encryptedTicket, userID, Nothing, DateTime.Now.AddMinutes(timeout), TimeSpan.Zero)

        Return encryptedTicket
    End Function

    <WebMethod()> _
        Public Function GetUserInfo(ByVal myParam As ArrayList) As UserInformation
        Dim ticket As String

        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds, dsClientIDs, dsModules As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetUser", userID)
            dsClientIDs = SqlHelper.ExecuteDataset(dbConn, "spWebGetUserClientList", userID)
            dsModules = SqlHelper.ExecuteDataset(dbConn, "spWebGetUserModuleList", userID)
        Finally
            dbConn.Close()
        End Try

        Dim userInfo As New UserInformation
        With ds.Tables(0).Rows(0)
            userInfo.UserID = userID
            userInfo.EmailAddress = CStr(.Item("EmailAddress"))
            userInfo.Password = CType(.Item("Password"), Byte())
            userInfo.UserName = CStr(.Item("UserName"))
            userInfo.Phone = IIf(IsDBNull(.Item("Phone")), String.Empty, .Item("Phone")).ToString
            userInfo.Fax = IIf(IsDBNull(.Item("Fax")), String.Empty, .Item("Fax")).ToString
            userInfo.FSPID = CInt(IIf(IsDBNull(.Item("InstallerID")), -999, .Item("InstallerID")))
            userInfo.MenuSet = CStr(.Item("MenuSet"))
            userInfo.UpdateTime = CDate(.Item("UpdateTime"))
            userInfo.ExpiryDate = CDate(.Item("ExpiryDate"))

            userInfo.IsActive = CBool(.Item("IsActive"))
            userInfo.IsLoginAsClient = (userInfo.FSPID = -999)
            userInfo.LoginDateTime = Now()
            userInfo.CanUseNewPCAMS = CBool(.Item("CanUseNewPCAMS"))
        End With
        ''Get ClientID list
        Dim strClientIDs As String = "", i As Integer
        For i = 0 To dsClientIDs.Tables(0).Rows.Count - 1
            strClientIDs = strClientIDs & dsClientIDs.Tables(0).Rows(i)("ClientID").ToString() & ","
        Next
        If i > 0 Then
            strClientIDs = strClientIDs.Substring(0, strClientIDs.Length - 1)
        End If
        userInfo.ClientIDs = strClientIDs

        ''Get ClientID list
        Dim strModules As String = ","
        For i = 0 To dsModules.Tables(0).Rows.Count - 1
            strModules = strModules & dsModules.Tables(0).Rows(i)("ModuleName").ToString() & ","
        Next
        userInfo.ModuleList = strModules

        Return userInfo
    End Function
    <WebMethod()> _
    Public Function UpdateUser(ByVal myParam As ArrayList) As UserInformation
        Dim ticket As String
        Dim userInfo As UserInformation

        ticket = Convert.ToString(myParam(0))
        userInfo = CType(myParam(1), UserInformation)

        If Not IsTicketValid(ticket, True) Then Return Nothing
        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim result As Integer
        Try
            With userInfo
                result = SqlHelper.ExecuteNonQuery(dbConn, "spWebPutUser", _
                    userID, .UserName, .EmailAddress, .Phone, _
                    .Fax, .FSPID)
            End With
        Finally
            dbConn.Close()
        End Try

        If result = 1 Then
            Return userInfo
        Else
            Return Nothing
        End If
    End Function

    <WebMethod()>
    Public Function ChangePassword(ByVal myParam As ArrayList) As UserInformation
        Dim ticket As String
        Dim userInfo As UserInformation

        ticket = Convert.ToString(myParam(0))
        userInfo = CType(myParam(1), UserInformation)

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim result As Integer
        Try
            result = SqlHelper.ExecuteNonQuery(dbConn, "spWebSetUserPWD", userID, userInfo.Password)
        Finally
            dbConn.Close()
        End Try

        If result = 1 Then
            ''refresh user info with new expiry date
            userInfo = GetUserInfo(myParam)
            Return userInfo
        Else
            Return Nothing
        End If
    End Function

    <WebMethod()>
    Public Function ChangeSelectedUserPassword(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim selectedUserID As Integer
        Dim password As Object

        ticket = Convert.ToString(myParam(0))
        selectedUserID = Convert.ToInt32(myParam(1))
        password = myParam(2)

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim result As Integer
        Try
            result = SqlHelper.ExecuteNonQuery(dbConn, "spWebSetUserPWD", selectedUserID, password)
        Finally
            dbConn.Close()
        End Try

        Return result
    End Function
    <WebMethod()> _
    Public Function GetUL(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim emailAddress As String
        ticket = Convert.ToString(myParam(0))
        emailAddress = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetUserList", userID, emailAddress)
            ds.Tables(0).TableName = "UserList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function AdminUser(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim emailAddress As String
        Dim name As String
        Dim newPassword As Byte()
        Dim clientIDs As String
        Dim installerID As String
        Dim menuSetID As String
        Dim flag As Int16


        ticket = Convert.ToString(myParam(0))
        emailAddress = Convert.ToString(myParam(1))
        name = Convert.ToString(myParam(2))
        newPassword = CType(myParam(3), Byte())
        clientIDs = Convert.ToString(myParam(4))
        installerID = Convert.ToString(myParam(5))
        menuSetID = Convert.ToString(myParam(6))
        flag = Convert.ToInt16(myParam(7))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)



        Dim ret As Object
        Try

            ''only this virtual function supports output parameter. (refer SqlHelper for details)
            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebAdminUser", _
               New SqlParameter("@UserID", userID), _
               New SqlParameter("@EmailAddress", emailAddress), _
               New SqlParameter("@Name", name), _
               New SqlParameter("@NewPassword", newPassword), _
               New SqlParameter("@ClientIDs", EmptyToNull(clientIDs)), _
               New SqlParameter("@InstallerID", EmptyToNull(installerID)), _
               New SqlParameter("@MenuSetID", menuSetID), _
               New SqlParameter("@Flag", flag))

        Finally
            dbConn.Close()
        End Try

        Return ret


    End Function

   <WebMethod()> _
    Public Function ResetUserPassword(ByVal myParam As ArrayList) As Object
        Dim emailAddress As String
        Dim newPWDText As String
        Dim newPassword As Byte()
        Dim hostInfo As String

        emailAddress = Convert.ToString(myParam(0))
        newPWDText = Convert.ToString(myParam(1))
        newPassword = CType(myParam(2), Byte())
        hostInfo = Convert.ToString(myParam(3))

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebResetUserPWD", emailAddress, newPWDText, newPassword, hostInfo)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    ''Failed to use base class to inherit the following function at design time, due VD IDE limit
    Private Function IsTicketValid(ByVal ticket As String, ByVal IsAdminCall As Boolean) As Boolean
        If ticket Is Nothing OrElse Context.Cache(ticket) Is Nothing Then
            'not authenticated
            Return False
        Else
            'check the user authorization
            Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

            Dim ds As DataSet
            Try
                ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetUser", userID)
            Finally
                dbConn.Close()
            End Try

            Dim userInfo As New UserInformation
            With ds.Tables(0).Rows(0)
                userInfo.IsActive = CBool(.Item("IsActive"))
            End With

            If Not userInfo.IsActive Then
                Return False
            Else
                'check admin status (for admin required calls)
                If IsAdminCall And Not userInfo.IsActive Then
                    Return False
                End If

                Return True
            End If
        End If
    End Function


    <WebMethod()>
    Public Function GetValidateUserOTP(ByVal myParam As ArrayList) As String
        'try to authenticate the user
        Dim userID As String
        Dim EmailAddress As String
        Dim Passcode As Byte()
        EmailAddress = Convert.ToString(myParam(0))
        Passcode = CType(myParam(1), Byte())
        Try
            userID = CStr(SqlHelper.ExecuteScalar(dbConn, "spWebValidateUserOTP", EmailAddress, Passcode))
        Finally
            dbConn.Close()
        End Try

        If userID Is Nothing Then
            ' The EmailAddress and Passcode combination is not valid.
            Return Nothing
        End If

        Return userID
    End Function

    <WebMethod()>
    Public Function GetUserOTPInfo(ByVal myParam As ArrayList) As UserOTPInformation
        Dim ticket As String
        Dim userOTPInfo As New UserOTPInformation
        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetUserOTP", userID)
            With ds.Tables(0).Rows(0)
                userOTPInfo.UserID = CInt(.Item("UserID"))
                userOTPInfo.Passcode = CType(.Item("Passcode"), Byte())
                userOTPInfo.CreatedDateTime = CDate(.Item("CreatedDateTime"))
                userOTPInfo.ExpiryDateTime = CDate(.Item("ExpiryDateTime"))
            End With
        Finally
            dbConn.Close()
        End Try

        Return userOTPInfo
    End Function


    <WebMethod()>
    Public Function CreateUserOTP(ByVal myParam As ArrayList) As UserInformation
        Dim ticket As String
        Dim userInfo As UserInformation
        Dim passCode As Byte()
        Dim otpExpiryMinute As Integer

        ticket = Convert.ToString(myParam(0))
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
        passCode = CType(myParam(1), Byte())
        otpExpiryMinute = Convert.ToInt32(myParam(2))

        Dim result As Integer
        Try
            result = SqlHelper.ExecuteNonQuery(dbConn, "spWebCreateUserOTP", userID, passCode, otpExpiryMinute)

        Finally
            dbConn.Close()
        End Try

        If result = 1 Then
            userInfo = GetUserInfo(myParam)
            Return userInfo
        Else
            Return Nothing
        End If
    End Function


    <WebMethod()>
    Public Function GetUserMFAFeatureParams(ByVal myParam As ArrayList) As UserMFAFeatureParam
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetUserMFAFeatureParams", userID)
        Finally
            dbConn.Close()
        End Try

        Dim userMFAFeatureParam As New UserMFAFeatureParam
        With ds.Tables(0).Rows(0)

            If (userID = CInt(.Item("UserID")) AndAlso IsDBNull(.Item("ClientID")) = False) Then
                userMFAFeatureParam.UserID = CInt(.Item("UserID"))
                userMFAFeatureParam.ClientID = CStr(.Item("ClientID"))

                If (IsDBNull(.Item("FeatureName")) = False AndAlso
                     CStr(.Item("FeatureName")) = "MFA") Then
                    userMFAFeatureParam.FeatureID = CInt(.Item("FeatureID"))
                    userMFAFeatureParam.FeatureName = CStr(.Item("FeatureName"))

                    Dim domainNames As String = CStr(.Item("OTPEmailDomainNames"))
                    If (Not String.IsNullOrEmpty(domainNames)) Then
                        userMFAFeatureParam.OTPEmailDomainNameList = domainNames.Split(CChar(","))?.ToList()
                    End If

                    userMFAFeatureParam.OTPLength = CInt(.Item("OTPLength"))
                    userMFAFeatureParam.OTPExpiryMinute = CInt(.Item("OTPExpiryMinute"))
                    userMFAFeatureParam.OTPMaxNoRetries = CInt(.Item("OTPMaxNoRetries"))
                End If
            End If
        End With

        Return userMFAFeatureParam
    End Function


    Private Function EncryptPWD(ByVal pPWD As String) As Byte()
        'Encrypt the password before saving it in the database
        Dim MD5Hasser As New MD5CryptoServiceProvider
        Dim Encoder As New UTF8Encoding

        Return MD5Hasser.ComputeHash(Encoder.GetBytes(pPWD))

    End Function

    <WebMethod()>
    Public Function EmailUserOTP(ByVal myParam As ArrayList) As Object
        Dim emailAddress As String
        Dim passcode As String
        Dim hostInfo As String

        emailAddress = Convert.ToString(myParam(0))
        passcode = Convert.ToString(myParam(1))
        hostInfo = Convert.ToString(myParam(2))

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebEmailUserOTP", emailAddress, passcode, hostInfo)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function


    Private Sub InitializeComponent()
        Me.dbConn = New System.Data.SqlClient.SqlConnection
        '
        'dbConn
        '
        Dim configurationAppSettings As System.Configuration.AppSettingsReader = New System.Configuration.AppSettingsReader
        Me.dbConn.ConnectionString = CType(configurationAppSettings.GetValue("dbConn.ConnectionString", GetType(System.String)), String) & "user id=webcams101;database=WebCAMS;Persist Security Info=true;password=w!u4f&c;"
        Me.dbConn.FireInfoMessageEventOnUserErrors = False

    End Sub
    Private Function EmptyToNull(ByVal pData As String) As Object
        If pData.Trim = String.Empty Then
            Return DBNull.Value
        Else
            Return pData
        End If
    End Function

End Class
