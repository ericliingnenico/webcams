#Region "vss"
'<!--$$Revision: 20 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 21/09/16 12:14 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/DataLayer.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Imports System
Imports System.Data
Imports System.Net
Imports System.Web.Services.Protocols
Imports System.Web.Security
Imports eCAMS.AuthWS
Imports eCAMS.DataWS
Imports Microsoft.VisualBasic
Imports System.Collections

Namespace eCAMS

    Public Enum DataLayerResult
        None = 0
        Success = 1
        ServiceFailure = 2
        UnknownFailure = 3
        ConnectionFailure = 4
        AuthenticationFailure = 5
    End Enum

    Public Class DataLayer
        Inherits DataLayerBase
        Public dsJobs As New DataSet
        Public dsCalls As New DataSet
        Public dsSites As New DataSet
        Public dsDevices As New DataSet
        Public dsFSPs As New DataSet
        Public dsDownloads As New DataSet
        Public dsExceptions As New DataSet
        Public dsStates As New DataSet
        Public dsJobFilterStatus As New DataSet

        Public dsJob As New DataSet
        Public dsCall As New DataSet
        Public dsSite As New DataSet
        Public dsDevice As New DataSet

        Public dsTemp As New DataSet

        Private m_WsData As DataService
        Private m_WsAuth As AuthService
        Private Const c_wsTimeout As Integer = 60000 '60 seconds

        Public Sub New()
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12

            m_WsData = New DataService
            m_WsAuth = New AuthService

            m_WsData.Timeout = c_wsTimeout
            m_WsAuth.Timeout = c_wsTimeout
        End Sub
#Region " Login "
        '----------------------------------------------------------------
        ' Sub VerifyLogin:
        '   Verify the login based on session data 
        '   and force to login page if not login yet
        '----------------------------------------------------------------
        Public Sub VerifyLogin()
            Dim loginURL As String
            ''cache logURL before session cleanup
            loginURL = GetLoginURL()

            If Not IsLogin AndAlso Not IsRememberMeLoginOK() Then

                If (m_TicketState = TICKET_STATE.PENDING_MFA) Then
                    loginURL = "../member/LoginOTP.aspx"
                Else
                    ''Clean up all the session values
                    Call System.Web.HttpContext.Current.Session.Clear()
                    ''Force to Login page
                End If
                Call System.Web.HttpContext.Current.Server.Transfer(loginURL)
            End If

        End Sub

        Public Function IsRememberMeLoginOK() As Boolean
            If Not HttpContext.Current.Request.Cookies("pcams.dl1") Is Nothing Then  ''check pcams.login cookie
                Dim myEncrypt As New Encryption64()
                If Login(myEncrypt.Decrypt(HttpContext.Current.Request.Cookies("pcams.dl1")("p1").ToString, Encrypt_Key_Used), myEncrypt.Decrypt(HttpContext.Current.Request.Cookies("pcams.dl1")("p2").ToString, Encrypt_Key_Used), 4) = DataLayerResult.Success Then
                    Return True
                Else
                    Return False
                End If
            Else
                Return False
            End If
        End Function
        Public Function Login(ByVal pEmailAddress As String, ByVal pPassword As String, ByVal pLogTypeID As Int16) As DataLayerResult
            'save the user information
            If CurrentUserInformation Is Nothing Then
                CurrentUserInformation = New UserInformation
            End If

            'save the user information
            If CurrentUserMFAFeatureParam Is Nothing Then
                CurrentUserMFAFeatureParam = New UserMFAFeatureParam
            End If

            CurrentUserInformation.EmailAddress = pEmailAddress
            CurrentUserInformation.Password = clsTool.EncryptPWD(pPassword)

            'Invalidate current ticket state
            m_TicketState = TICKET_STATE.INVALID

            'try to get a ticket
            Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
            If ticketResult = DataLayerResult.Success Then
                Dim newUserInfo As UserInformation 'automatically set to Nothing
                Dim newUserMFAFeatureParam As UserMFAFeatureParam

                Dim param As New ArrayList(1)
                param.Add(m_Ticket)
                'try to get the current user information
                Try
                    newUserInfo = m_WsAuth.GetUserInfo(param.ToArray)
                    newUserMFAFeatureParam = m_WsAuth.GetUserMFAFeatureParams(param.ToArray)
                Catch ex As Exception
                    Return HandleException(ex)
                End Try

                'this shouldn't happen unless second request fails
                If newUserInfo Is Nothing Or newUserMFAFeatureParam Is Nothing Then
                    Return DataLayerResult.AuthenticationFailure
                End If

                'keep the returned information
                CurrentUserInformation = newUserInfo
                CurrentUserMFAFeatureParam = newUserMFAFeatureParam

                'Only set MFA for the following matched users
                If CheckIfCurrentUserIsConfiguredForMFA(newUserInfo.UserID) Then
                    m_TicketState = TICKET_STATE.PENDING_MFA

                ElseIf (pEmailAddress = newUserInfo.EmailAddress) Then
                    m_TicketState = TICKET_STATE.VALID
                End If

                'IsLogin = True 'comment it out as we are now using m_TicketState

                'cache IsLiveDB
                GetIsLiveDBFlag()

                'Log the login details
                Dim strActionData As String
                strActionData = "<IP>" & HttpContext.Current.Request.UserHostAddress() & "</IP>"
                strActionData = strActionData & "<LoginDateTime>" & Date.Now.ToString("d", New System.Globalization.CultureInfo("en-AU")) & " " & Date.Now.ToString("T") & "</LoginDateTime>"
                Call PutActionLog(pLogTypeID, strActionData)

                Return DataLayerResult.Success
            Else
                Return ticketResult
            End If
        End Function


        Function CheckIfCurrentUserIsConfiguredForMFA(ByVal userID As Integer) As Boolean
            Dim userEmailDomain As String = clsTool.ExtractDomainFromEmail(CurrentUserInformation.EmailAddress)
            If CurrentUserMFAFeatureParam.FeatureName = "MFA" AndAlso
                    CurrentUserMFAFeatureParam.UserID = userID AndAlso
                    CurrentUserMFAFeatureParam.OTPEmailDomainNameList.Contains(userEmailDomain) Then
                Return True
            End If
            Return False
        End Function
#End Region
#Region " Auth Service "
        Private Function GetAuthorizationTicket() As DataLayerResult
            Dim param As New ArrayList(2)
            param.Add(CurrentUserInformation.EmailAddress)
            param.Add(CurrentUserInformation.Password)
            Try
                m_Ticket = m_WsAuth.GetAuthorizationTicket(param.ToArray())

            Catch ex As Exception
                m_Ticket = Nothing
                Return HandleException(ex)
            End Try

            If m_Ticket Is Nothing Then
                'username/password failed
                Return DataLayerResult.AuthenticationFailure
            End If

            Return DataLayerResult.Success
        End Function


        Public Function GetUserInfo() As DataLayerResult
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                CurrentUserInformation = m_WsAuth.GetUserInfo(param.ToArray)
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function UpdateUser(ByVal pUserName As String, ByVal pEmailAddress As String, ByVal pPhone As String, ByVal pFax As String, ByVal pFSPID As Integer) As DataLayerResult
            Dim uInfo As UserInformation
            Dim updatedUserInfo As New UserInformation
            ''Get new info
            With updatedUserInfo
                .UserName = pUserName
                .EmailAddress = pEmailAddress
                .Phone = pPhone
                .Fax = pFax
                .FSPID = pFSPID
            End With
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(updatedUserInfo)
            Try
                uInfo = m_WsAuth.UpdateUser(param.ToArray())

                'all eCAMS web services return nothing to indicate an expired ticket
                If uInfo Is Nothing Then
                    'get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    uInfo = m_WsAuth.UpdateUser(param.ToArray)

                    'this next block should never happen. It means it took more than TIMEOUT 
                    '(default is 2 min) between GetAuthTicket and GetProjects
                    If uInfo Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            ''Set new info to currentuserinfo
            If Not uInfo Is Nothing Then
                With CurrentUserInformation
                    .UserName = uInfo.UserName
                    .EmailAddress = uInfo.EmailAddress
                    .Phone = uInfo.Phone
                    .Fax = uInfo.Fax
                End With
            End If
            Return DataLayerResult.Success
        End Function

        Public Function ChangePassword(ByVal pNewPassword As Byte()) As DataLayerResult
            Dim uInfo As UserInformation
            CurrentUserInformation.Password = pNewPassword
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(CurrentUserInformation)
            Try
                uInfo = m_WsAuth.ChangePassword(param.ToArray)

                'all eCAMS web services return nothing to indicate an expired ticket
                If uInfo Is Nothing Then
                    'get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    uInfo = m_WsAuth.ChangePassword(param.ToArray)


                    'this next block should never happen. It means it took more than TIMEOUT 
                    '(default is 2 min) between GetAuthTicket and GetProjects
                    If uInfo Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
                CurrentUserInformation = uInfo

            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function ChangeSelectedUserPassword(ByVal pSelectedUserID As Integer, ByVal pNewPassword As Byte()) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pSelectedUserID)
            param.Add(pNewPassword)

            Try
                ret = m_WsAuth.ChangeSelectedUserPassword(param.ToArray)

                'all eCAMS web services return nothing to indicate an expired ticket
                If ret Is Nothing Then
                    'get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ret = m_WsAuth.ChangeSelectedUserPassword(param.ToArray)

                    'this next block should never happen. It means it took more than TIMEOUT 
                    '(default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function GetUserList(ByVal pEmailAddress As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pEmailAddress)

            Try
                ds = m_WsAuth.GetUL(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsAuth.GetUL(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function

        Public Function AdminUser(ByVal pEmailAddress As String,
                        ByVal pName As String,
                        ByVal pNewPassword As String,
                        ByVal pClientIDs As String,
                        ByVal pInstallerID As String,
                        ByVal pMenuSetID As String,
                        ByVal pFlag As Int16) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(8)

            param.Add(m_Ticket)
            param.Add(pEmailAddress)
            param.Add(pName)
            param.Add(clsTool.EncryptPWD(pNewPassword))
            param.Add(pClientIDs)
            param.Add(pInstallerID)
            param.Add(pMenuSetID)
            param.Add(pFlag)

            Try
                ret = m_WsAuth.AdminUser(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsAuth.AdminUser(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function ResetUserPassword(ByVal pEmailAddress As String,
                        ByVal pNewPassword As String,
                        ByVal pHostInfo As String) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(3)

            param.Add(pEmailAddress)
            param.Add(pNewPassword)
            param.Add(clsTool.EncryptPWD(pNewPassword))
            param.Add(pHostInfo)

            Try
                ret = m_WsAuth.ResetUserPassword(param.ToArray)
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            If CInt(ret) = 0 Then
                Return DataLayerResult.Success
            Else
                Return DataLayerResult.UnknownFailure
            End If

        End Function

#End Region

#Region "OTP Login / Service "

        Public Function GetUserMFAFeatureParams(ByVal newTicket As String) As DataLayerResult
            Dim param As New ArrayList(1)
            param.Add(newTicket)
            Try
                CurrentUserMFAFeatureParam = m_WsAuth.GetUserMFAFeatureParams(param.ToArray)
                If CurrentUserMFAFeatureParam Is Nothing Then
                    Return DataLayerResult.UnknownFailure
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function


        Public Function CreateUserOTP(ByRef pPasscode As String) As DataLayerResult
            Dim uInfo As UserInformation
            Dim passcodeString As String = Nothing
            Dim passcodeByte As Byte() = Nothing
            Dim otpExpiryMinute As Integer

            If (CurrentUserMFAFeatureParam IsNot Nothing AndAlso CurrentUserMFAFeatureParam.OTPLength > 0) Then
                passcodeString = clsTool.GenerateOTP(CurrentUserMFAFeatureParam.OTPLength)
                otpExpiryMinute = CurrentUserMFAFeatureParam.OTPExpiryMinute
            Else
                passcodeString = clsTool.GenerateOTP(6)
                otpExpiryMinute = 10
            End If

            passcodeByte = clsTool.EncryptPWD(passcodeString)

            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(passcodeByte)
            param.Add(otpExpiryMinute)

            Try
                uInfo = m_WsAuth.CreateUserOTP(param.ToArray)
                If uInfo Is Nothing Then
                    'get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    uInfo = m_WsAuth.CreateUserOTP(param.ToArray)

                    'this next block should never happen. It means it took more than TIMEOUT 
                    '(default is 2 min) between GetAuthTicket and CreateUserOTP
                    If uInfo Is Nothing Then
                        Return DataLayerResult.UnknownFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)
            End Try

            pPasscode = passcodeString
            Return DataLayerResult.Success

        End Function


        Public Function GetValidateUserOTP(ByVal passcodeByte As Byte(), ByVal pLogTypeID As Int16) As DataLayerResult
            Dim otpUserID As String
            Dim param As New ArrayList(2)
            param.Add(CurrentUserInformation.EmailAddress)
            param.Add(passcodeByte)

            Try
                'requires emailaddress and passcode
                otpUserID = m_WsAuth.GetValidateUserOTP(param.ToArray)
                'Check if its matched with current userID
                If (Not String.IsNullOrEmpty(otpUserID) AndAlso otpUserID = CurrentUserInformation.UserID) Then
                    m_TicketState = DataLayerBase.TICKET_STATE.VALID
                End If
            Catch ex As Exception
                m_Ticket = Nothing
                Return HandleException(ex)
            End Try

            If otpUserID Is Nothing Then
                'username/password failed
                Return DataLayerResult.AuthenticationFailure
            End If
            'Log the login details
            Dim strActionData As String
            strActionData = "<IP>" & HttpContext.Current.Request.UserHostAddress() & "</IP>"
            strActionData = strActionData & "<LoginDateTime>" & Date.Now.ToString("d", New System.Globalization.CultureInfo("en-AU")) & " " & Date.Now.ToString("T") & "</LoginDateTime>"
            Call PutActionLog(pLogTypeID, strActionData)

            Return DataLayerResult.Success
        End Function

        Public Function GetUserOTPInfo() As DataLayerResult
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                CurrentUserOTPInformation = m_WsAuth.GetUserOTPInfo(param.ToArray)
                If CurrentUserOTPInformation Is Nothing Then
                    'get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket
                    CurrentUserOTPInformation = m_WsAuth.GetUserOTPInfo(param.ToArray)
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success

        End Function

        Public Function EmailUserOTP(ByVal pPasscode As String,
                        ByVal pHostInfo As String, ByRef returnErrorMessage As String) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(3)

            param.Add(CurrentUserInformation.EmailAddress)
            param.Add(pPasscode)
            param.Add(pHostInfo)

            Try
                ret = m_WsAuth.EmailUserOTP(param.ToArray)
                returnErrorMessage = ret.ToString()
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            If CInt(ret) = 0 Then
                Return DataLayerResult.Success
            Else
                Return DataLayerResult.UnknownFailure
            End If

        End Function

#End Region



#Region " Data Service - Job "
        Public Function GetJobCount() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                ds = m_WsData.GetJobCount(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ds = m_WsData.GetJobCount(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJobs = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetJob(ByVal pJobID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetJob(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetJob(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetJobs(ByVal pClientID As String, ByVal pJobType As String, ByVal pState As String, ByVal pStatus As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(5)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pJobType)
            param.Add(pState)
            param.Add(pStatus)

            Try
                ds = m_WsData.GetJobs(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetJobs(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetJobs(ByVal pClientID As String, ByVal pJobType As String, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pJobType)
            param.Add(pFrom)
            Try
                ds = m_WsData.GetFSPJobs(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPJobs(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetQuickFindJobs(ByVal pClientID As String, ByVal pScope As String, ByVal pTerminalID As String, ByVal pMerchantID As String, ByVal pProblemNumber As String, ByVal pJobID As String, ByVal pCustomerNumber As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(8)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pScope)
            param.Add(pTerminalID)
            param.Add(pMerchantID)
            param.Add(pProblemNumber)
            param.Add(pJobID)
            param.Add(pCustomerNumber)

            Try
                ds = m_WsData.GetQuickFindList(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetQuickFindList(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetTerminalJobs(ByVal pClientID As String, ByVal pTerminalID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)

            Try
                ds = m_WsData.GetTerminalJobList(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetTerminalJobList(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsJobs = ds
            Return DataLayerResult.Success
        End Function

        Public Function CloseDeinstallJob(ByVal pJobID As Integer, ByVal pFixID As Integer, ByVal pNotes As String) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pFixID)
            param.Add(pNotes)

            Try
                ret = m_WsData.CloseDeinstallJob(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult

                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.CloseDeinstallJob(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function GetClientClosureReasons(ByVal pClientID As String, ByVal pJobType As String, ByVal pFix As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pJobType)
            param.Add(pFix)

            Try
                ds = m_WsData.GetClientClosureReasons(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetClientClosureReasons(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
#End Region
#Region " Data Service - Log Job/Call "
        Public Function GetClientTerminalConfigField(ByVal pClientID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pClientID)

            Try
                ds = m_WsData.GetClientTerminalConfigField(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetClientTerminalConfigField(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsTemp = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetState(ByVal pAddAll As Boolean) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pAddAll)

            Try
                ds = m_WsData.GetState(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetState(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsStates = ds

            Return DataLayerResult.Success
        End Function
        Public Function GetJobFilterStatus() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)

            Try
                ds = m_WsData.GetJobFilterStatus(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetJobFilterStatus(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJobFilterStatus = ds

            Return DataLayerResult.Success
        End Function

        Public Function GetJobDeviceType(ByVal pClientID As String, ByVal pJobTypeID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pJobTypeID)
            Try
                ds = m_WsData.GetJobDeviceType(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetJobDeviceType(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetJobMethod(ByVal pClientID As String, ByVal pJobTypeID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pJobTypeID)

            Try
                ds = m_WsData.GetJobMethod(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetJobMethod(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetCallType(ByVal pEquipmentCode As String) As DataLayerResult
            ''init
            dsTemp = Nothing
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pEquipmentCode)

            Try
                ds = m_WsData.GetCallType(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetCallType(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetCallTypeSymptom(ByVal pCallTypeID As Integer) As DataLayerResult
            ''init
            dsTemp = Nothing

            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pCallTypeID)

            Try
                ds = m_WsData.GetCallTypeSymptom(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetCallTypeSymptom(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetSymptomFault(ByVal pSymptomID As Integer) As DataLayerResult
            ''init
            dsTemp = Nothing

            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pSymptomID)

            Try
                ds = m_WsData.GetSymptomFault(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetSymptomFault(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetAdditionalServiceType(ByVal pClientID As String) As DataLayerResult
            ''init
            dsTemp = Nothing
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pClientID)

            Try
                ds = m_WsData.GetAdditionalServiceType(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetAdditionalServiceType(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function ValidateTIDBeforeLogJob(ByVal pClientID As String, ByVal pTerminalID As String, ByVal pJobTypeID As Int16) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)
            param.Add(pJobTypeID)
            Try
                ret = m_WsData.ValidateTIDBeforeLogJob(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.ValidateTIDBeforeLogJob(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success

        End Function

        Public Function LogJob(ByRef pJobID As Integer,
                    ByVal pProblemNumber As String,
                    ByVal pClientID As String,
                    ByVal pMerchantID As String,
                    ByVal pTerminalID As String,
                    ByVal pJobTypeID As String,
                    ByVal pJobMethodID As String,
                    ByVal pDeviceType As String,
                    ByVal pSpecInstruct As String,
                    ByVal pInstallDateTime As String,
                    ByVal pName As String,
                    ByVal pAddress As String,
                    ByVal pAddress2 As String,
                    ByVal pCity As String,
                    ByVal pState As String,
                    ByVal pPostcode As String,
                    ByVal pContact As String,
                    ByVal pPhoneNumber As String,
                    ByVal pMobileNumber As String,
                    ByVal pLineType As String,
                    ByVal pDialPrefix As String,
                    ByVal pOldDeviceType As String,
                    ByVal pOldTerminalID As String,
                    ByVal pBusinessActivity As String,
                    ByVal pUrgent As Boolean,
                    ByVal pTradingHoursMon As String,
                    ByVal pTradingHoursTue As String,
                    ByVal pTradingHoursWed As String,
                    ByVal pTradingHoursThu As String,
                    ByVal pTradingHoursFri As String,
                    ByVal pTradingHoursSat As String,
                    ByVal pTradingHoursSun As String,
                    ByVal pUpdateSiteTradingHours As Boolean,
                    ByVal pConfigXML As String,
                    ByVal pJobNote As String,
                    ByVal pCAIC As String,
                    ByVal pContactEmail As String,
                    ByVal pBankersEmail As String,
                    ByVal pMerchantEmail As String,
                    ByVal pCustomerNumber As String,
                    ByVal pAltMerchantID As String,
                    ByVal pLostStolen As Boolean,
                    ByVal pProjectNo As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(35)

            param.Add(m_Ticket)
            param.Add(pProblemNumber)
            param.Add(pClientID)
            param.Add(pMerchantID)
            param.Add(pTerminalID)
            param.Add(pJobTypeID)
            param.Add(pJobMethodID)
            param.Add(pDeviceType)
            param.Add(pSpecInstruct)
            param.Add(pInstallDateTime)
            param.Add(pName)
            param.Add(pAddress)
            param.Add(pAddress2)
            param.Add(pCity)
            param.Add(pState)
            param.Add(pPostcode)
            param.Add(pContact)
            param.Add(pPhoneNumber)
            param.Add(pMobileNumber)
            param.Add(pLineType)
            param.Add(pDialPrefix)
            param.Add(pOldDeviceType)
            param.Add(pOldTerminalID)
            param.Add(pBusinessActivity)
            param.Add(pUrgent)
            param.Add(pTradingHoursMon)
            param.Add(pTradingHoursTue)
            param.Add(pTradingHoursWed)
            param.Add(pTradingHoursThu)
            param.Add(pTradingHoursFri)
            param.Add(pTradingHoursSat)
            param.Add(pTradingHoursSun)
            param.Add(pUpdateSiteTradingHours)
            param.Add(pConfigXML)
            param.Add(pJobNote)
            param.Add(pCAIC)
            param.Add(pContactEmail)
            param.Add(pBankersEmail)
            param.Add(pMerchantEmail)
            param.Add(pCustomerNumber)
            param.Add(pAltMerchantID)
            param.Add(pLostStolen)
            param.Add(pProjectNo)

            Try
                ret = m_WsData.LogJob(param.ToArray, pJobID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    'reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.LogJob(param.ToArray, pJobID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function LogCall(ByRef pCallNumber As String,
                    ByVal pProblemNumber As String,
                    ByVal pClientID As String,
                    ByVal pMerchantID As String,
                    ByVal pTerminalID As String,
                    ByVal pDeviceType As String,
                    ByVal pSpecInstruct As String,
                    ByVal pInstallDateTime As String,
                    ByVal pName As String,
                    ByVal pAddress As String,
                    ByVal pAddress2 As String,
                    ByVal pCity As String,
                    ByVal pState As String,
                    ByVal pPostcode As String,
                    ByVal pContact As String,
                    ByVal pPhoneNumber As String,
                    ByVal pMobileNumber As String,
                    ByVal pLineType As String,
                    ByVal pDialPrefix As String,
                    ByVal pCallTypeID As String,
                    ByVal pSymptomID As String,
                    ByVal pFaultID As String,
                    ByVal pBusinessActivity As String,
                    ByVal pUrgent As Boolean,
                    ByVal pTradingHoursMon As String,
                    ByVal pTradingHoursTue As String,
                    ByVal pTradingHoursWed As String,
                    ByVal pTradingHoursThu As String,
                    ByVal pTradingHoursFri As String,
                    ByVal pTradingHoursSat As String,
                    ByVal pTradingHoursSun As String,
                    ByVal pUpdateSiteTradingHours As Boolean,
                    ByVal pConfigXML As String,
                    ByVal pAddiitonalServcieTypeID As String,
                    ByVal pJobNote As String,
                    ByVal pSwapComponent As String,
                    ByVal pCAIC As String,
                    ByVal pTechToAttWithoutCall As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(35)

            param.Add(m_Ticket)
            param.Add(pProblemNumber)
            param.Add(pClientID)
            param.Add(pMerchantID)
            param.Add(pTerminalID)
            param.Add(pDeviceType)
            param.Add(pSpecInstruct)
            param.Add(pName)
            param.Add(pAddress)
            param.Add(pAddress2)
            param.Add(pCity)
            param.Add(pState)
            param.Add(pPostcode)
            param.Add(pContact)
            param.Add(pPhoneNumber)
            param.Add(pMobileNumber)
            param.Add(pLineType)
            param.Add(pDialPrefix)
            param.Add(pCallTypeID)
            param.Add(pSymptomID)
            param.Add(pFaultID)
            param.Add(pBusinessActivity)
            param.Add(pUrgent)
            param.Add(pTradingHoursMon)
            param.Add(pTradingHoursTue)
            param.Add(pTradingHoursWed)
            param.Add(pTradingHoursThu)
            param.Add(pTradingHoursFri)
            param.Add(pTradingHoursSat)
            param.Add(pTradingHoursSun)
            param.Add(pUpdateSiteTradingHours)
            param.Add(pConfigXML)
            param.Add(pAddiitonalServcieTypeID)
            param.Add(pJobNote)
            param.Add(pSwapComponent)
            param.Add(pCAIC)
            param.Add(pTechToAttWithoutCall) 'CAMS-878

            Try
                ret = m_WsData.LogCall(param.ToArray, pCallNumber)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.LogCall(param.ToArray, pCallNumber)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function GetDeviceComponent(ByVal pClientID As String, ByVal pTerminalID As String, ByVal pCategoryID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)
            param.Add(pCategoryID)

            Try
                ds = m_WsData.GetDeviceComponent(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetDeviceComponent(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function DuplicateJob(ByRef pJobID As Integer,
                        ByVal pClientID As String,
                        ByVal pTerminalID As String,
                        ByVal pNewTerminalID As String,
                        ByVal pNewCAIC As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(4)

            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)
            param.Add(pNewTerminalID)
            param.Add(pNewCAIC)
            Try
                ret = m_WsData.DuplicateJob(param.ToArray, pJobID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.DuplicateJob(param.ToArray, pJobID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

#End Region
#Region " Data Service - Call "

        Public Function GetCall(ByVal pCallNumber As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pCallNumber)

            Try
                ds = m_WsData.GetCall(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetCall(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsCall = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetCalls(ByVal pClientID As String, ByVal pState As String, ByVal pStatus As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pState)
            param.Add(pStatus)
            Try
                ds = m_WsData.GetCalls(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetCalls(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsCalls = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetCalls(ByVal pClientID As String, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pFrom)
            Try
                ds = m_WsData.GetFSPCalls(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPCalls(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsCalls = ds
            Return DataLayerResult.Success
        End Function

#End Region
#Region " Data Service - Site "

        Public Function GetSite(ByVal pClientID As String, ByVal pTerminalID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)
            Try
                ds = m_WsData.GetSite(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetSite(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsSite = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetSites(ByVal pClientID As String, ByVal pTerminalID As String, ByVal pMerchantID As String, ByVal pName As String, ByVal pSuburb As String, ByVal pPostcode As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(7)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)
            param.Add(pMerchantID)
            param.Add(pName)
            param.Add(pSuburb)
            param.Add(pPostcode)

            Try
                ds = m_WsData.GetSites(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetSites(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsSites = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetSiteEquipments(ByVal pClientID As String, ByVal pTerminalID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)
            Try
                ds = m_WsData.GetSiteEquipments(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetSiteEquipments(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsSites = ds
            Return DataLayerResult.Success
        End Function
        Public Function PutSite(ByRef pClientID As String,
                        ByVal pTerminalID As String,
                        ByVal pMerchantID As String,
                        ByVal pName As String,
                        ByVal pAddress As String,
                        ByVal pAddress2 As String,
                        ByVal pCity As String,
                        ByVal pState As String,
                        ByVal pPostcode As String,
                        ByVal pContact As String,
                        ByVal pPhoneNumber As String,
                        ByVal pPhoneNumber2 As String,
                        ByVal pTradingHoursMon As String,
                        ByVal pTradingHoursTue As String,
                        ByVal pTradingHoursWed As String,
                        ByVal pTradingHoursThu As String,
                        ByVal pTradingHoursFri As String,
                        ByVal pTradingHoursSat As String,
                        ByVal pTradingHoursSun As String,
                        ByVal pApplyToOtherMerchantRecord As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(21)

            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pTerminalID)
            param.Add(pMerchantID)
            param.Add(pName)
            param.Add(pAddress)
            param.Add(pAddress2)
            param.Add(pCity)
            param.Add(pState)
            param.Add(pPostcode)
            param.Add(pContact)
            param.Add(pPhoneNumber)
            param.Add(pPhoneNumber2)
            param.Add(pTradingHoursMon)
            param.Add(pTradingHoursTue)
            param.Add(pTradingHoursWed)
            param.Add(pTradingHoursThu)
            param.Add(pTradingHoursFri)

            param.Add(pTradingHoursSat)
            param.Add(pTradingHoursSun)
            param.Add(pApplyToOtherMerchantRecord)

            Try
                ret = m_WsData.PutSite(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutSite(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
#End Region
#Region "Data Service - Device"
        Public Function GetDevices(ByVal pClientID As String, ByVal pSerial As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pSerial)

            Try
                ds = m_WsData.GetDeviceListBySerial(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetDeviceListBySerial(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsDevices = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetDevice(ByVal pClientID As String, ByVal pSerial As String, ByVal pFrom As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pClientID)
            param.Add(pSerial)
            param.Add(pFrom)
            Try
                ds = m_WsData.GetDeviceBySerial(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetDeviceBySerial(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try


            dsDevice = ds
            Return DataLayerResult.Success
        End Function

#End Region

#Region "Client Projects"
        Public Function GetClientProject(ByVal pClientID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)

            Try
                ds = m_WsData.GetClientProjects(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetClientProjects(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
#End Region

#Region "Client-Customers"
        Public Function GetCustomers(ByVal pClientID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pClientID)

            Try
                ds = m_WsData.GetCustomers(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetCustomers(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
#End Region

#Region "Data Service - FSP Job"
        Public Function GMAPGetFSPJob(ByVal pJobViewer As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobViewer)
            Try
                ds = m_WsData.GMapGetFSPJob(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ds = m_WsData.GMapGetFSPJob(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetFSPJob(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetFSPJob(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPJob(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetFSPCall(ByVal pCallNumber As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pCallNumber)
            Try
                ds = m_WsData.GetFSPCall(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPCall(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsCall = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetFSPClosedJobs(ByVal pFSPID As String, ByVal pJobType As String, ByVal pFromDate As Date, ByVal pToDate As Date, ByVal pJobIDs As String, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(7)
            param.Add(m_Ticket)
            param.Add(pFSPID)
            param.Add(pJobType)
            param.Add(pFromDate)
            param.Add(pToDate)
            param.Add(pJobIDs)
            param.Add(pFrom)

            Try
                ds = m_WsData.GetFSPClosedJobs(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPClosedJobs(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try

            dsJobs = ds
            Return DataLayerResult.Success

        End Function

        Public Function GetFSPAllOpenJob(ByVal PFSID As String, ByVal From As Int16, ByVal JobType As String, ByVal DueDateTime As String, ByVal NoDeviceReservedOnly As Boolean, ByVal ProjectNo As String, ByVal City As String, ByVal Postcode As String, ByVal IncludeChildDepot As Boolean, ByVal JobIDs As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(11)
            param.Add(m_Ticket)
            param.Add(PFSID)
            param.Add(From)
            param.Add(JobType)
            param.Add(DueDateTime)
            param.Add(NoDeviceReservedOnly)
            param.Add(ProjectNo)
            param.Add(City)
            param.Add(Postcode)
            param.Add(IncludeChildDepot)
            param.Add(JobIDs)


            Try
                ds = m_WsData.GetFSPAllOpenJob(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPAllOpenJob(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try

            dsJobs = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPJobSheetData(ByVal pJobID As Int64) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)
            Try
                ds = m_WsData.GetFSPJobSheetData(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPJobSheetData(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function FSPReAssignJob(ByVal pJobID As Int64, ByVal pReAssignTo As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pReAssignTo)

            Try
                ret = m_WsData.FSPReAssignJob(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ret = m_WsData.FSPReAssignJob(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function FSPReAssignJobExt(ByVal pJobIDList As String, ByVal pReAssignTo As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pJobIDList)
            param.Add(pReAssignTo)

            Try
                ret = m_WsData.FSPReAssignJobExt(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ret = m_WsData.FSPReAssignJobExt(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function GetFSPClosedJobWithOutstandingDevice(ByVal pFSPID As Integer, ByVal pFromDate As Date, ByVal pToDate As Date, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(5)
            param.Add(m_Ticket)
            param.Add(pFSPID)
            param.Add(pFromDate)
            param.Add(pToDate)
            param.Add(pFrom)

            Try
                ds = m_WsData.GetFSPClosedJobWithOutstandingDevice(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPClosedJobWithOutstandingDevice(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try

            dsJobs = ds
            Return DataLayerResult.Success

        End Function

        Public Function GetFSPJobEquipmentHistory(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetFSPJobEquipmentHistory(param.ToArray())
                If ds Is Nothing Then
                    ''old ticket expired, renew it
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''renew the ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPJobEquipmentHistory(param.ToArray())
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsDevices = ds
            Return DataLayerResult.Success

        End Function
        Public Function SetJobAsFSPOnSite(ByVal pJobID As Int64, ByVal pLatitude As String, ByVal pLongitude As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pLatitude)
            param.Add(pLongitude)

            Try
                ret = m_WsData.SetJobAsFSPOnSite(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ret = m_WsData.SetJobAsFSPOnSite(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function GetJobKittedDevice(ByVal pJobID As Int64, ByVal pCheckFSPConfirmLog As Boolean) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pCheckFSPConfirmLog)

            Try
                ds = m_WsData.GetJobKittedDevice(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ds = m_WsData.GetJobKittedDevice(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function ConfirmKittedPartsUsage(ByVal pJobID As Int64) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ret = m_WsData.ConfirmKittedPartsUsage(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ret = m_WsData.ConfirmKittedPartsUsage(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function SwapBundledSIM(ByVal pJobID As Int64, ByVal pSIMOut As String, ByVal pSIMIn As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pSIMOut)
            param.Add(pSIMIn)

            Try
                ds = m_WsData.SwapBundledSIM(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ds = m_WsData.SwapBundledSIM(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function

        Public Function FSPCallMerchant(ByVal pJobID As Int64, ByVal pPhoneNumber As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pPhoneNumber)

            Try
                ret = m_WsData.FSPCallMerchant(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ret = m_WsData.FSPCallMerchant(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

#End Region
#Region "Data Service - FSP Misc"

        Public Function GetMerchantAcceptance(ByVal pJobID As Int64) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetMerchantAcceptance(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetMerchantAcceptance(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetFSPChildrenExt() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                ds = m_WsData.GetFSPChildrenExt(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPChildrenExt(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsFSPs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetFSPFamilyExt() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                ds = m_WsData.GetFSPFamilyExt(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPFamilyExt(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsFSPs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetDownload(ByVal pSeq As String, ByVal pCategoryID As String, ByVal pFrom As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pSeq)
            param.Add(pCategoryID)
            param.Add(pFrom)


            Try
                ds = m_WsData.GetDownload(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetDownload(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsDownloads = ds
            Return DataLayerResult.Success
        End Function
        Public Function PutDownload(ByRef pSeq As Int16, ByVal pDownloadCategoryID As Int16, ByVal pDownloadDescription As String, ByVal pDownloadURL As String, ByVal pFileSize As String, ByVal pIsActive As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pDownloadCategoryID)
            param.Add(pDownloadDescription)
            param.Add(pDownloadURL)
            param.Add(pFileSize)
            param.Add(pIsActive)

            Try
                ret = m_WsData.PutDownload(param.ToArray, pSeq)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutDownload(param.ToArray, pSeq)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function GetDownloadsByURL(ByVal pDownloadURL As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pDownloadURL)

            Try
                ds = m_WsData.GetDownloadsByURL(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetDownloadsByURL(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsDownloads = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetDownloadCategoryAll() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)

            Try
                ds = m_WsData.GetDownloadCategoryAll(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetDownloadCategoryAll(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsDownloads = ds
            Return DataLayerResult.Success
        End Function
        Public Function CacheFSPChildren() As DataLayerResult
            If FSPChildren Is Nothing Then
                If GetFSPChildrenExt() = DataLayerResult.Success Then
                    FSPChildren = dsFSPs
                End If
            End If
            Return DataLayerResult.Success
        End Function
        Public Function CacheFSPFamily() As DataLayerResult
            If FSPFamily Is Nothing Then
                If GetFSPFamilyExt() = DataLayerResult.Success Then
                    FSPFamily = dsFSPs
                End If
            End If
            Return DataLayerResult.Success
        End Function
        Public Function CacheState() As DataLayerResult
            If State Is Nothing Then
                If GetState(False) = DataLayerResult.Success Then
                    State = dsStates
                End If
            End If
            Return DataLayerResult.Success
        End Function
        Public Function CacheStateWithAll() As DataLayerResult
            If StateWithAll Is Nothing Then
                If GetState(True) = DataLayerResult.Success Then
                    StateWithAll = dsStates
                End If
            End If
            Return DataLayerResult.Success
        End Function

        Public Function CacheJobFilterStatus() As DataLayerResult
            If JobFilterStatus Is Nothing Then
                If GetJobFilterStatus() = DataLayerResult.Success Then
                    JobFilterStatus = dsJobFilterStatus
                End If
            End If
            Return DataLayerResult.Success
        End Function

        Public Function GetTechFix(ByVal jobType As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(jobType)

            Try
                ds = m_WsData.GetTechFix(param.ToArray)
                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    param(0) = m_Ticket
                    ds = m_WsData.GetTechFix(param.ToArray)
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success


        End Function

        Public Function IsTelstraFSP(ByVal pFSPID As Integer, ByRef pIsTelstraFSP As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pFSPID)
            Try
                ret = m_WsData.IsTelstraFSP(param.ToArray, pIsTelstraFSP)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    param(0) = m_Ticket
                    ret = m_WsData.IsTelstraFSP(param.ToArray, pIsTelstraFSP)
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success
        End Function
        Public Function GetIsLiveDBFlag() As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Dim pIsLiveDB As Boolean
            Try
                ret = m_WsData.IsLiveDB(param.ToArray, pIsLiveDB)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    param(0) = m_Ticket
                    ret = m_WsData.IsLiveDB(param.ToArray, pIsLiveDB)
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            IsLiveDB = pIsLiveDB
            Return DataLayerResult.Success
        End Function
        Public Function GetJobFSPDownload(ByVal pJobID As Long, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pFrom)



            Try
                ds = m_WsData.GetJobFSPDownload(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetJobFSPDownload(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsDownloads = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetPostcodeFSPAllocation(ByVal postcode As String, ByVal city As String, ByVal clientID As String, ByVal jobTypeID As Int16, ByVal deviceType As String, ByVal requiredDTLocal As String) As String
            Dim serviceStatus As String
            Dim param As New ArrayList(7)
            param.Add(m_Ticket)
            param.Add(postcode)
            param.Add(city)
            param.Add(clientID)
            param.Add(jobTypeID)
            param.Add(deviceType)
            param.Add(requiredDTLocal)

            Try
                serviceStatus = m_WsData.GetPostcodeFSPAllocation(param.ToArray)

            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return serviceStatus
        End Function

#End Region
#Region "Data Service - Update Job Info"
        Public Function GetClientUpdateInfoFieldList(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetClientUpdateInfoFieldList(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetClientUpdateInfoFieldList(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function UpdateJobInfo(ByRef pJobID As Long,
                        ByVal pJobInfo As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)

            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pJobInfo)
            Try
                ret = m_WsData.UpdateJobInfo(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.UpdateJobInfo(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function


#End Region
#Region "Data Service - FSP Task"
        Public Function GetFSPOpenTaskList(ByVal PFSID As String, ByVal From As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(PFSID)
            param.Add(From)
            Try
                ds = m_WsData.GetFSPOpenTaskList(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPOpenTaskList(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsJobs = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPTask(ByVal pTaskID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pTaskID)

            Try
                ds = m_WsData.GetFSPTask(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPTask(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function PutFSPTask(ByVal pTaskID As Integer, ByVal pCarrierID As String,
                                    ByVal pConNoteNo As String, ByVal pCloseComment As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(5)
            param.Add(m_Ticket)
            param.Add(pTaskID)
            param.Add(pCarrierID)
            param.Add(pConNoteNo)
            param.Add(pCloseComment)


            Try
                ret = m_WsData.PutFSPTask(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPTask(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function AddFSPTaskDevice(ByVal pTaskID As Integer, ByVal pSerial As String, ByVal pMMD_ID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pTaskID)
            param.Add(pSerial)
            param.Add(pMMD_ID)

            Try
                ds = m_WsData.AddFSPTaskDevice(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.AddFSPTaskDevice(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function

        Public Function CloseFSPTask(ByVal pTaskID As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pTaskID)

            Try
                ret = m_WsData.CloseFSPTask(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    'reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.CloseFSPTask(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function GetFSPTaskJobPostData(ByVal pTaskID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pTaskID)
            Try
                ds = m_WsData.GetFSPTaskJobPostData(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    'reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPTaskJobPostData(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetFSPClosedTasks(ByVal pFSPID As String, ByVal pFromDate As Date, ByVal pToDate As Date) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pFSPID)
            param.Add(pFromDate)
            param.Add(pToDate)

            Try
                ds = m_WsData.GetFSPClosedTasks(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPClosedTasks(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetFSPTaskView(ByVal pTaskID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pTaskID)

            Try
                ds = m_WsData.GetFSPTaskView(param.ToArray)

                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''re-buffer ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPTaskView(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds

            Return DataLayerResult.Success
        End Function
#End Region
#Region "Data Service - FSP Stock List"
        Public Function GetFSPStockList(ByVal pFSPID As Integer, ByVal pConditions As String, ByVal pFrom As Int16, ByVal pTransitToEE As Boolean) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pFSPID)
            param.Add(pConditions)
            param.Add(pFrom)
            param.Add(pTransitToEE)

            Try
                ds = m_WsData.GetFSPStockList(param.ToArray)
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPStockList(param.ToArray)

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsJobs = ds
            Return DataLayerResult.Success

        End Function

        Public Function GetFSPDeviceListBySerial(ByVal pSerial As String, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pSerial)
            param.Add(pFrom)
            Try
                ds = m_WsData.GetFSPDeviceListBySerial(param.ToArray)

                If ds Is Nothing Then
                    ''Expired ticket caused nothing returned, so let's renew the ticket
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''pass new ticket into param
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPDeviceListBySerial(param.ToArray)

                    If ds Is Nothing Then
                        ''ticket shoudn't expire again
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Call HandleException(ex)
            End Try

            dsJobs = ds
            Return DataLayerResult.Success

        End Function
#End Region
#Region "Data Service - Stock Received"
        Public Function GetFSPStockReceivedLog(ByVal pBatchID As Integer, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pFrom)
            Try
                ds = m_WsData.GetFSPStockReceivedLog(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPStockReceivedLog(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try

            dsJobs = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPStockReceived(ByVal pBatchID As Integer, ByVal pStatus As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pStatus)
            Try
                ds = m_WsData.GetFSPStockReceived(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPStockReceived(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function PutFSPStockReceived(ByRef pBatchID As Integer, ByVal pDepot As Integer,
                                    ByVal pDateReceived As Date, ByVal pStatus As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            ''        param.Add(pBatchID)
            param.Add(pDepot)
            param.Add(pDateReceived)
            param.Add(pStatus)

            Try
                ret = m_WsData.PutFSPStockReceived(param.ToArray, pBatchID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPStockReceived(param.ToArray, pBatchID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function AddFSPStockReceivedLog(ByVal pBatchID As Integer, ByVal pSerial As String) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pSerial)
            Try
                ret = m_WsData.AddFSPStockReceivedLog(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.AddFSPStockReceivedLog(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success

        End Function
        Public Function CloseFSPStockReceivedAndSendReport(ByVal pBatchID As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pBatchID)

            Try
                ret = m_WsData.CloseFSPStockReceivedAndSendReport(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.CloseFSPStockReceivedAndSendReport(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

#End Region
#Region "Data Service - Stock Returned"
        Public Function GetFSPStockReturnedLog(ByVal pBatchID As Integer, ByVal pFrom As Int16, ByVal pUpdateAsFaulty As Boolean) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pFrom)
            param.Add(pUpdateAsFaulty)
            Try
                ds = m_WsData.GetFSPStockReturnedLog(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPStockReturnedLog(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsJobs = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPStockReturned(ByVal pBatchID As Integer, ByVal pStatus As String, ByVal pUpdateAsFaulty As Boolean) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pStatus)
            param.Add(pUpdateAsFaulty)

            Try
                ds = m_WsData.GetFSPStockReturned(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPStockReturned(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function PutFSPStockReturned(ByRef pBatchID As Integer, ByVal pFromLocation As Integer, ByVal pToLocation As Integer,
                                    ByVal pDateReturned As Date, ByVal pReferenceNo As String, ByVal pNote As String, ByVal pStatus As String, ByVal pUpdateAsFaulty As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(7)
            param.Add(m_Ticket)
            param.Add(pFromLocation)
            param.Add(pToLocation)
            param.Add(pDateReturned)
            param.Add(pReferenceNo)
            param.Add(pNote)
            param.Add(pStatus)
            param.Add(pUpdateAsFaulty)
            Try
                ret = m_WsData.PutFSPStockReturned(param.ToArray, pBatchID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPStockReturned(param.ToArray, pBatchID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function ValidateStockFaulty(ByVal pBatchID As Integer, ByVal pFromLocation As Integer, ByVal pToLocation As Integer,
                                    ByVal pDateReturned As Date, ByVal pReferenceNo As String, ByVal pNote As String, ByVal pStatus As String, ByVal pUpdateAsFaulty As Boolean, ByVal pSerial As String, ByRef pCaseID As Integer, ByVal pValidate As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(12)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pFromLocation)
            param.Add(pToLocation)
            param.Add(pDateReturned)
            param.Add(pReferenceNo)
            param.Add(pNote)
            param.Add(pStatus)
            param.Add(pUpdateAsFaulty)
            param.Add(pSerial)
            param.Add(pCaseID)
            param.Add(pValidate)
            Try
                ret = m_WsData.PutFSPStockReturned(param.ToArray, pCaseID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPStockReturned(param.ToArray, pCaseID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function AddFSPStockReturnedLog(ByVal pBatchID As Integer, ByVal pSerial As String, ByVal pUpdateAsFaulty As Boolean, ByVal pCaseID As Integer) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(5)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pSerial)
            param.Add(pUpdateAsFaulty)
            param.Add(pCaseID)
            Try
                ret = m_WsData.AddFSPStockReturnedLog(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.AddFSPStockReturnedLog(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success

        End Function
        Public Function CloseFSPStockReturnedAndSendReport(ByVal pBatchID As Integer, ByVal pNoOfBox As Integer, ByVal pReferenceNo As String, ByVal pNote As String, ByVal pStockFaulty As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pNoOfBox)
            param.Add(pReferenceNo) 'CAMS-873
            param.Add(pNote) 'CAMS-955
            param.Add(pStockFaulty)

            Try
                ret = m_WsData.CloseFSPStockReturnedAndSendReport(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.CloseFSPStockReturnedAndSendReport(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

#End Region
#Region "Data Service - Stock Take"
        Public Function GetFSPStockTakeLog(ByVal pBatchID As Integer, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pFrom)
            Try
                ds = m_WsData.GetFSPStockTakeLog(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPStockTakeLog(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsJobs = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPStockTakeTarget() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                ds = m_WsData.GetFSPStockTakeTarget(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPStockTakeTarget(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetFSPStockTake(ByVal pBatchID As Integer, ByVal pStatus As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pStatus)
            Try
                ds = m_WsData.GetFSPStockTake(param.ToArray)

                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPStockTake(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsJob = ds
            Return DataLayerResult.Success
        End Function
        Public Function PutFSPStockTake(ByRef pBatchID As Integer, ByVal pDepot As Integer,
                                    ByVal pStockTakeDate As Date, ByVal pNote As String, ByVal pStatus As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(5)
            param.Add(m_Ticket)
            param.Add(pDepot)
            param.Add(pStockTakeDate)
            param.Add(pNote)
            param.Add(pStatus)

            Try
                ret = m_WsData.PutFSPStockTake(param.ToArray, pBatchID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPStockTake(param.ToArray, pBatchID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function AddFSPStockTakeLog(ByVal pBatchID As Integer, ByVal pSerial As String) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBatchID)
            param.Add(pSerial)
            Try
                ret = m_WsData.AddFSPStockTakeLog(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.AddFSPStockTakeLog(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success

        End Function
        Public Function CloseFSPStockTakeAndSendReport(ByVal pBatchID As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pBatchID)

            Try
                ret = m_WsData.CloseFSPStockTakeAndSendReport(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.CloseFSPStockTakeAndSendReport(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
#End Region
#Region "FSP Faulty Out Of Box"
        Public Function AddFaultyOutOfBoxDevice(ByVal pSerial As String, ByVal pNote As String) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pSerial)
            param.Add(pNote)
            Try
                ret = m_WsData.AddFaultyOutOfBoxDevice(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.AddFaultyOutOfBoxDevice(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success

        End Function

#End Region
#Region "FSP CJF"
        Public Function GetFSPCJFPreJob() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                ds = m_WsData.GetFSPCJFPreJob(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPCJFPreJob(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetFSPCJFPreJob
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsJobs = ds
            Return DataLayerResult.Success
        End Function

        Public Function GetFSPCJFJob(ByVal pCJFID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pCJFID)

            Try
                ds = m_WsData.GetFSPCJFJob(param.ToArray)
                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer the ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPCJFJob(param.ToArray)
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Call HandleException(ex)
            End Try
            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetFSPCJF() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                ds = m_WsData.GetFSPCJF(param.ToArray)
                If ds Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer the ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPCJF(param.ToArray)
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Call HandleException(ex)
            End Try
            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function GenerateFSPCJF(ByVal pCJFFileName As String, ByVal pLogIDs As String, ByRef pCJFID As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pCJFFileName)
            param.Add(pLogIDs)
            Try
                ''call web service to generate CJF file
                ret = m_WsData.GenerateFSPCJF(param.ToArray, pCJFID)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.GenerateFSPCJF(param.ToArray, pCJFID)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function
#End Region
#Region "FSP IMSPart Tran"
        Public Function GetFSPPartTran() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)
            Try
                ds = m_WsData.GetFSPPartTran(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPPartTran(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetFSPCJFPreJob
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function FSPSavePartTranReceived(ByVal pTranIDs As String, ByVal pQtyReceiveds As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pTranIDs)
            param.Add(pQtyReceiveds)
            Try
                ''call web service to generate CJF file
                ret = m_WsData.FSPSavePartTranReceived(param.ToArray)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.FSPSavePartTranReceived(param.ToArray)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPPartInventory(ByVal pMode As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pMode)
            Try
                ds = m_WsData.GetFSPPartInventory(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPPartInventory(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetFSPCJFPreJob
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsJobs = ds
            Return DataLayerResult.Success
        End Function
        Public Function FSPSavePartInventory(ByVal pPartNoList As String, ByVal pQtyList As String, ByVal pMode As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pPartNoList)
            param.Add(pQtyList)
            param.Add(pMode)
            Try
                ''call web service to generate CJF file
                ret = m_WsData.FSPSavePartInventory(param.ToArray)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.FSPSavePartInventory(param.ToArray)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function

#End Region
#Region "Data Service - FSP Job Closure"
        Public Function GetFSPJobClosure(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetFSPJobClosure(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPJobClosure(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsJob = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPJobEquipment(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetFSPJobEquipment(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPJobEquipment(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsDevices = ds
            Return DataLayerResult.Success

        End Function
        Public Function DelFSPJobEquipment(ByVal pJobID As Long, ByVal pSerial As String,
                                    ByVal pMMD_ID As String, ByVal pAction As Int16) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pSerial)
            param.Add(pMMD_ID)
            param.Add(pAction)


            Try
                ret = m_WsData.DelFSPJobEquipment(param.ToArray())

                ' All dataservice web services return Nothing  to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.DelFSPJobEquipment(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function UpdateFSPJobEquipment(ByVal pJobID As Long, ByVal pSerial As String,
                                    ByVal pMMD_ID As String, ByVal pNewSerial As String, ByVal pNewMMD_ID As String, ByVal pAction As Int16) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pSerial)
            param.Add(pMMD_ID)
            param.Add(pNewSerial)
            param.Add(pNewMMD_ID)
            param.Add(pAction)


            Try
                ret = m_WsData.UpdateFSPJobEquipment(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.UpdateFSPJobEquipment(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function AddFSPJobEquipment(ByVal pJobID As Long, ByVal pSerial As String,
                                    ByVal pMMD_ID As String, ByVal pNewSerial As String, ByVal pNewMMD_ID As String, ByVal pAction As Int16) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pSerial)
            param.Add(pMMD_ID)
            param.Add(pNewSerial)
            param.Add(pNewMMD_ID)
            param.Add(pAction)

            Try
                ret = m_WsData.AddFSPJobEquipment(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.AddFSPJobEquipment(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function CloseFSPJob(ByVal pJobID As Long, ByVal pTechFixID As Int16,
                                ByVal pNotes As String, ByVal pOnSiteDateTime As DateTime, ByVal pOffSiteDateTime As DateTime) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pTechFixID)
            param.Add(pNotes)
            param.Add(pOnSiteDateTime)
            param.Add(pOffSiteDateTime)


            Try
                ret = m_WsData.CloseFSPJob(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult

                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.CloseFSPJob(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function GetFSPJobParts(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetFSPJobParts(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPJobParts(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsDevices = ds
            Return DataLayerResult.Success

        End Function
        Public Function DelFSPJobParts(ByVal pJobID As Long, ByVal pPartID As String) As DataLayerResult
            Dim param As New ArrayList(3)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pPartID)



            Try
                ret = m_WsData.DelFSPJobParts(param.ToArray())

                ' All dataservice web services return Nothing  to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.DelFSPJobParts(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function PutFSPJobParts(ByVal pJobID As Long, ByVal pPartID As String, ByVal pQty As Integer) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pPartID)
            param.Add(pQty)



            Try
                ret = m_WsData.PutFSPJobParts(param.ToArray())

                ' All dataservice web services return Nothing  to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPJobParts(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function GetFSPParts(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetFSPParts(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPParts(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function
        Public Function PutFSPMissingJobParts(ByVal pJobID As Long, ByVal pPartsList As String) As DataLayerResult
            Dim param As New ArrayList(3)
            Dim ret As Object

            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pPartsList)

            Try
                ret = m_WsData.PutFSPMissingJobParts(param.ToArray())

                ' All dataservice web services return Nothing  to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPMissingJobParts(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

        Public Function SetMerchantDamaged(ByVal pJobID As Long, ByVal pSerial As String,
                                ByVal pMMD_ID As String, ByVal pIsMerchantDamaged As Boolean) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pSerial)
            param.Add(pMMD_ID)
            param.Add(pIsMerchantDamaged)


            Try
                ret = m_WsData.SetMerchantDamaged(param.ToArray())

                ' All dataservice web services return Nothing  to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.SetMerchantDamaged(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
#End Region
#Region "FSP Exception"
        Public Function GetFSPExceptionList(ByVal pFSPID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pFSPID)
            param.Add(1)  ''From option: from web

            Try
                ds = m_WsData.GetFSPExceptionList(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPExceptionList(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsJobs = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetJobExceptionList(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetJobExceptionList(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetJobExceptionList(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsExceptions = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPEscalateReason() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)

            Try
                ds = m_WsData.GetFSPEscalateReason(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPEscalateReason(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function
        Public Function EscalateFSPJob(ByVal pJobID As Long, ByVal pEscalateReasonID As Int16, ByVal pNotes As String) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pEscalateReasonID)
            param.Add(pNotes)


            Try
                ret = m_WsData.EscalateFSPJob(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult

                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.EscalateFSPJob(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function AddFSPJobNote(ByVal pJobID As Long, ByVal pNotes As String) As DataLayerResult
            Dim param As New ArrayList(3)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pNotes)


            Try
                ret = m_WsData.AddFSPJobNote(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult

                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.AddFSPJobNote(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function ReassignJobBackToDepot(ByVal pJobID As Long, ByVal pNotes As String) As DataLayerResult
            Dim param As New ArrayList(3)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pNotes)


            Try
                ret = m_WsData.ReassignJobBackToDepot(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult

                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.ReassignJobBackToDepot(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

#End Region
#Region "FSP Delegation"
        Public Function GetFSPDelegationList(ByVal pFromDate As String, ByVal pFrom As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pFromDate)
            param.Add(1)  ''From option: from web

            Try
                ds = m_WsData.GetFSPDelegationList(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPDelegationList(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPDelegation(ByVal pLogID As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pLogID)

            Try
                ds = m_WsData.GetFSPDelegation(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPDelegation(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function
        Public Function GetFSPDelegationReason() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)

            Try
                ds = m_WsData.GetFSPDelegationReason(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPDelegationReason(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function

        Public Function PutFSPDelegation(ByRef pLogID As Integer,
                        ByVal pFSP As String,
                        ByVal pFromDateTime As DateTime,
                        ByVal pToDateTime As DateTime,
                        ByVal pAssignedToFSP As String,
                        ByVal pNote As String,
                        ByVal pReasonID As String,
                        ByVal pStatusID As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(7)

            param.Add(m_Ticket)
            param.Add(pFSP)
            param.Add(pFromDateTime)
            param.Add(pToDateTime)
            param.Add(pAssignedToFSP)
            param.Add(pNote)
            param.Add(pReasonID)
            param.Add(pStatusID)

            Try
                ret = m_WsData.PutFSPDelegation(param.ToArray, pLogID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutFSPDelegation(param.ToArray, pLogID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function CancelFSPDelegation(ByVal pLogID As Integer) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(2)

            param.Add(m_Ticket)
            param.Add(pLogID)

            Try
                ret = m_WsData.CancelFSPDelegation(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.CancelFSPDelegation(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function GetFSPCalendar(ByVal pFromDate As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pFromDate)

            Try
                ds = m_WsData.GetFSPCalendar(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPCalendar(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function

#End Region
#Region "Bulletin"
        Public Function GetBulletin(ByVal pBullentinID As String, ByVal pModeID As Int16) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBullentinID)
            param.Add(pModeID)
            Try
                ds = m_WsData.GetBulletin(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetBulletin(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetFSPCJFPreJob
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function PutBulletin(ByVal pBulletinID As Integer, ByVal pTitle As String, ByVal pBody As String, ByVal pButtonTypeID As Int16, ByVal pActionOnDecline As Int16, ByVal pTargetTypeID As Int16) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(7)
            param.Add(m_Ticket)
            param.Add(pBulletinID)
            param.Add(pTitle)
            param.Add(pBody)
            param.Add(pButtonTypeID)
            param.Add(pActionOnDecline)
            param.Add(pTargetTypeID)

            Try
                ''call web service to save bulletin
                ret = m_WsData.PutBulletin(param.ToArray)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.PutBulletin(param.ToArray)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function
        Public Function GetBulletinViewLog(ByVal pFrom As Integer) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pFrom)

            Try
                ds = m_WsData.GetBulletinViewLog(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetBulletinViewLog(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetFSPCJFPreJob
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsTemp = ds
            Return DataLayerResult.Success
        End Function

        Public Function PutBulletinViewLog(ByVal pBulletinID As Integer, ByVal pActionTaken As Int16) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pBulletinID)
            param.Add(pActionTaken)

            Try
                ''call web service to save bulletin
                ret = m_WsData.PutBulletinViewLog(param.ToArray)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.PutBulletinViewLog(param.ToArray)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function
#End Region

#Region "Site Survey"
        Public Function GetSurvey(ByVal pJobID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)
            Try
                ds = m_WsData.GetSurvey(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetSurvey(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetFSPCJFPreJob
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsTemp = ds
            Return DataLayerResult.Success
        End Function
        Public Function GetSurveyAnswer(ByVal pJobID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)
            Try
                ds = m_WsData.GetSurveyAnswer(param.ToArray)
                ' All dataservice web services return nothing to indicate an expired ticket
                If ds Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetSurveyAnswer(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetFSPCJFPreJob
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If

            Catch ex As Exception
                Return HandleException(ex)

            End Try


            dsTemp = ds
            Return DataLayerResult.Success
        End Function

        Public Function PutSurveyAnswer(ByVal pJobID As Long, ByVal pSurveyResult As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pSurveyResult)

            Try
                ''call web service to save bulletin
                ret = m_WsData.PutSurveyAnswer(param.ToArray)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.PutSurveyAnswer(param.ToArray)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function
        Public Function PutMerchantAcceptance(ByVal pJobID As Long, ByVal pSignatureDate As Byte(), ByVal pPrintName As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pSignatureDate)
            param.Add(pPrintName)

            Try
                ''call web service to save bulletin
                ret = m_WsData.PutMerchantAcceptance(param.ToArray)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.PutMerchantAcceptance(param.ToArray)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function
        Public Function UploadMerchantSignedJobSheet(ByVal pJobID As Long, ByVal pJobSheet As Byte(), ByVal pContentType As String) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(4)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pJobSheet)
            param.Add(pContentType)

            Try
                ''call web service to save bulletin
                ret = m_WsData.UploadMerchantSignedJobSheet(param.ToArray)
                If ret Is Nothing Then
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''rebuffer ticket
                    param(0) = m_Ticket
                    ret = m_WsData.UploadMerchantSignedJobSheet(param.ToArray)
                    If ret Is Nothing Then
                        ''still a problem, ring the bell
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            Return DataLayerResult.Success

        End Function
        Public Function ValidateJobClosure(ByVal pJobID As Long, ByVal pFrom As Short) As DataLayerResult

            Dim ret As Object
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pJobID)
            param.Add(pFrom)
            Try
                ret = m_WsData.ValidateJobClosure(param.ToArray)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.ValidateJobClosure(param.ToArray)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success

        End Function

#End Region

#Region "FSP Book Job"
        Public Function GetFSPJobsForBooking(ByVal pJobID As Long) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pJobID)

            Try
                ds = m_WsData.GetFSPJobsForBooking(param.ToArray())
                If ds Is Nothing Then
                    ''old ticket expired, renew it
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If
                    ''renew the ticket
                    param(0) = m_Ticket
                    ds = m_WsData.GetFSPJobsForBooking(param.ToArray())
                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsDevices = ds
            Return DataLayerResult.Success

        End Function
        Public Function FSPBookJob(ByVal pJobIDs As String, ByVal pBookTo As Int16,
                                    ByVal pBookDateTime As DateTime, ByVal pNotes As String) As DataLayerResult
            Dim param As New ArrayList(5)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobIDs)
            param.Add(pBookTo)
            param.Add(pBookDateTime)
            param.Add(pNotes)


            Try
                ret = m_WsData.FSPBookJob(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult

                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.FSPBookJob(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
        Public Function GetFSPEscalateJobBookingReason() As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(1)
            param.Add(m_Ticket)

            Try
                ds = m_WsData.GetFSPEscalateJobBookingReason(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetFSPEscalateJobBookingReason(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function
        Public Function EscalateFSPJobBooking(ByVal pJobIDList As String, ByVal pEscalateReasonID As Int16, ByVal pNotes As String) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pJobIDList)
            param.Add(pEscalateReasonID)
            param.Add(pNotes)


            Try
                ret = m_WsData.EscalateFSPJobBooking(param.ToArray())

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult

                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.EscalateFSPJobBooking(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function

#End Region
#Region "Admin BulkJob"
        Public Function GetAdminBulkJob(ByVal pTypeID As Short, ByVal pData As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pTypeID)
            param.Add(pData)

            Try
                ds = m_WsData.GetAdminBulkJob(param.ToArray())
                If ds Is Nothing Then
                    ''refresh ticket and try web service again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ds = m_WsData.GetAdminBulkJob(param.ToArray())

                    If ds Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try
            dsTemp = ds
            Return DataLayerResult.Success

        End Function

        Public Function PutAdminBulkJob(ByVal pTypeID As Short, ByVal pData As String) As DataLayerResult
            Dim param As New ArrayList(4)
            Dim ret As Object
            param.Add(m_Ticket)
            param.Add(pTypeID)
            param.Add(pData)


            Try
                ret = m_WsData.PutAdminBulkJob(param.ToArray())

                ' All dataservice web services return Nothing  to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''set the renewed ticket
                    param(0) = m_Ticket

                    ret = m_WsData.PutAdminBulkJob(param.ToArray())

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
#End Region
#Region "Admin MID Allocation"
        Public Function LogApplicationAndAssignMID(ByRef pMerchantID As String,
                    ByRef pPayMarkID As Int64,
                    ByVal pCountryID As String,
                    ByVal pPartnerID As String,
                    ByVal pAccountID As String,
                    ByVal pAccountType As String,
                    ByVal pApplicationID As String,
                    ByVal pProductType As String,
                    ByVal pContactName As String,
                    ByVal pGSTNumber As String,
                    ByVal pTradingName As String,
                    ByVal pLegalName As String,
                    ByVal pDescriptionOfBusiness As String,
                    ByVal pBusinessAddress1 As String,
                    ByVal pBusinessAddress2 As String,
                    ByVal pBusinessCity As String,
                    ByVal pBusinessState As String,
                    ByVal pBusinessPostcode As String,
                    ByVal pBusinessCountry As String,
                    ByVal pIsThePrimaryBusinessFaceToFace As Boolean,
                    ByVal pIsBillerProvided As Boolean,
                    ByVal pAnnualCardSalesTurnover As String,
                    ByVal pAverageTicketSize As String,
                    ByVal pSubMerchantBusinessIdentifier As String,
                    ByVal pRefundPolicy As String,
                    ByVal pCancellationPolicy As String,
                    ByVal pDeliveryTimeframes As String,
                    ByVal pPaymentPageSample As String,
                    ByVal pReceiptSample As String,
                    ByVal pBusinessPhone As String,
                    ByVal pPrivatephone As String,
                    ByVal pWebAddress As String,
                    ByVal pEmailAddress As String,
                    ByVal pFaxNumber As String,
                    ByVal pDirector1Name As String,
                    ByVal pDirector1DOB As String,
                    ByVal pDirector1Address1 As String,
                    ByVal pDirector1Address2 As String,
                    ByVal pDirector1City As String,
                    ByVal pDirector1State As String,
                    ByVal pDirector1Postcode As String,
                    ByVal pDirector1Country As String,
                    ByVal pDirector2Name As String,
                    ByVal pDirector2DOB As String,
                    ByVal pDirector2Address1 As String,
                    ByVal pDirector2Address2 As String,
                    ByVal pDirector2City As String,
                    ByVal pDirector2State As String,
                    ByVal pDirector2Postcode As String,
                    ByVal pDirector2Country As String,
                    ByVal pDirector3Name As String,
                    ByVal pDirector3DOB As String,
                    ByVal pDirector3Address1 As String,
                    ByVal pDirector3Address2 As String,
                    ByVal pDirector3City As String,
                    ByVal pDirector3State As String,
                    ByVal pDirector3Postcode As String,
                    ByVal pDirector3Country As String,
                    ByVal pMerchantCategoryIndustry As String,
                    ByVal pMerchantCategoryCode As String,
                    ByVal pExportRestrictionsApply As Boolean,
                    ByVal pOfficeID As String,
                    ByVal pAccountName As String,
                    ByVal pSettlementAccountNumber As String,
                    ByVal pIsCreditCheck As Boolean,
                    ByVal pIsKYCCheck As Boolean,
                    ByVal pIsSignedSubMerchantAgreement As Boolean,
                    ByVal pIsWebsiteComplianceCheck As Boolean,
                    ByVal pIsHighRiskMCCCodeCheck As Boolean,
                    ByVal pIsPCIComplianceCheck As Boolean) As DataLayerResult
            Dim ret As Object
            Dim param As New ArrayList(69)

            param.Add(m_Ticket)
            param.Add(pCountryID)
            param.Add(pPartnerID)
            param.Add(pAccountID)
            param.Add(pAccountType)
            param.Add(pApplicationID)
            param.Add(pProductType)
            param.Add(pContactName)
            param.Add(pGSTNumber)
            param.Add(pTradingName)
            param.Add(pLegalName)
            param.Add(pDescriptionOfBusiness)
            param.Add(pBusinessAddress1)
            param.Add(pBusinessAddress2)
            param.Add(pBusinessCity)
            param.Add(pBusinessState)
            param.Add(pBusinessPostcode)
            param.Add(pBusinessCountry)
            param.Add(pIsThePrimaryBusinessFaceToFace)
            param.Add(pIsBillerProvided)
            param.Add(pAnnualCardSalesTurnover)
            param.Add(pAverageTicketSize)
            param.Add(pSubMerchantBusinessIdentifier)
            param.Add(pRefundPolicy)
            param.Add(pCancellationPolicy)
            param.Add(pDeliveryTimeframes)
            param.Add(pPaymentPageSample)
            param.Add(pReceiptSample)
            param.Add(pBusinessPhone)
            param.Add(pPrivatephone)
            param.Add(pWebAddress)
            param.Add(pEmailAddress)
            param.Add(pFaxNumber)
            param.Add(pDirector1Name)
            param.Add(pDirector1DOB)
            param.Add(pDirector1Address1)
            param.Add(pDirector1Address2)
            param.Add(pDirector1City)
            param.Add(pDirector1State)
            param.Add(pDirector1Postcode)
            param.Add(pDirector1Country)
            param.Add(pDirector2Name)
            param.Add(pDirector2DOB)
            param.Add(pDirector2Address1)
            param.Add(pDirector2Address2)
            param.Add(pDirector2City)
            param.Add(pDirector2State)
            param.Add(pDirector2Postcode)
            param.Add(pDirector2Country)
            param.Add(pDirector3Name)
            param.Add(pDirector3DOB)
            param.Add(pDirector3Address1)
            param.Add(pDirector3Address2)
            param.Add(pDirector3City)
            param.Add(pDirector3State)
            param.Add(pDirector3Postcode)
            param.Add(pDirector3Country)
            param.Add(pMerchantCategoryIndustry)
            param.Add(pMerchantCategoryCode)
            param.Add(pExportRestrictionsApply)
            param.Add(pOfficeID)
            param.Add(pAccountName)
            param.Add(pSettlementAccountNumber)
            param.Add(pIsCreditCheck)
            param.Add(pIsKYCCheck)
            param.Add(pIsSignedSubMerchantAgreement)
            param.Add(pIsWebsiteComplianceCheck)
            param.Add(pIsHighRiskMCCCodeCheck)
            param.Add(pIsPCIComplianceCheck)
            Try
                ret = m_WsData.LogApplicationAndAssignMID(param.ToArray, pMerchantID, pPayMarkID)

                ' All dataservice web services return Nothing to indicate an expired ticket
                If ret Is Nothing Then
                    ' Get a new ticket and try the call again
                    Dim ticketResult As DataLayerResult = GetAuthorizationTicket()
                    If ticketResult <> DataLayerResult.Success Then
                        Return ticketResult
                    End If

                    ''reset ticket
                    param(0) = m_Ticket

                    ret = m_WsData.LogApplicationAndAssignMID(param.ToArray, pMerchantID, pPayMarkID)

                    ' This next block should never happen. It means it took more than TIMEOUT 
                    ' (default is 2 min) between GetAuthTicket and GetProjects
                    If ret Is Nothing Then
                        Return DataLayerResult.AuthenticationFailure
                    End If
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return DataLayerResult.Success
        End Function
#End Region
#Region " Helper Functions "
        Public Function HandleException(ByVal ex As Exception) As DataLayerResult
            Dim errorMsg As String
            Dim isSoapException As Boolean
            ''init
            errorMsg = ""
            isSoapException = False

            ''check soap exception & retrieve error message
            If ex.GetType() Is GetType(SoapException) AndAlso CType(ex, SoapException).Detail.InnerText.Length > 0 Then
                errorMsg += CType(ex, SoapException).Detail.InnerText
                isSoapException = True
            Else
                errorMsg += ex.Message
            End If


            ''LogError.Write(ex.Message & vbNewLine & ex.StackTrace)        ''--Log to Event
            LogError.Write(errorMsg & vbNewLine & ex.StackTrace, True)    ''--Log to DB


            ''if the exception is SoapException with detail.innerText, throw message back to GUI
            If isSoapException Then
                Throw (New Exception(errorMsg))
            End If

            ''set return type
            If ex.GetType() Is GetType(WebException) Then
                Return DataLayerResult.ConnectionFailure
            ElseIf ex.GetType() Is GetType(SoapException) Then
                Return DataLayerResult.ServiceFailure
            Else
                Return DataLayerResult.UnknownFailure
            End If
        End Function
        Public Function PutErrorLog(ByVal pMsg As String) As DataLayerResult
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pMsg)
            ''On error resume next, and always return success
            Try
                m_WsData.PutErrorLog(param.ToArray)
            Catch
            End Try
            Return DataLayerResult.Success

        End Function
        Public Function PutActionLog(ByVal pActionTypeID As Integer, ByVal pActionData As String) As DataLayerResult
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pActionTypeID)
            param.Add(pActionData)

            ''Call data layer to save the action log
            Try
                m_WsData.PutActionLog(param.ToArray)

            Catch ex As Exception

            End Try
            Return DataLayerResult.Success
        End Function
        Public Function PutSessionLog(ByVal pSessionID As String, ByVal pSessionData As String) As DataLayerResult
            Dim param As New ArrayList(3)
            param.Add(m_Ticket)
            param.Add(pSessionID)
            param.Add(pSessionData)

            ''Call data layer to save the action log
            Try
                m_WsData.PutSessionLog(param.ToArray)

            Catch ex As Exception

            End Try
            Return DataLayerResult.Success
        End Function
        Public Function GetSessionLog(ByVal pSessionID As String) As DataLayerResult
            Dim ds As DataSet
            Dim param As New ArrayList(2)
            param.Add("GiveMeSessionPlease")  ''special ticket for this one since session timeout aldready, no user info and ticket can be found.
            param.Add(pSessionID)

            Try
                ds = m_WsData.GetSessionLog(param.ToArray)
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            dsTemp = ds
            Return DataLayerResult.Success
        End Function

#End Region


#Region "Application Attribute"



        Public Function GetAppAttribute(ByVal pAttributeName As String) As String
            Dim retValue As String = Nothing
            Dim param As New ArrayList(2)
            param.Add(m_Ticket)
            param.Add(pAttributeName)

            Try
                Dim obj As Object = m_WsData.GetAppAttribute(param.ToArray)
                If (obj IsNot Nothing) Then
                    retValue = obj.ToString()
                End If
            Catch ex As Exception
                Return HandleException(ex)
            End Try

            Return retValue
        End Function
#End Region



    End Class

End Namespace


