'<!--$$Revision: 18 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 21/09/16 12:13 $-->
'<!--$$Logfile: /eCAMSSource2010/wseCAMS/DataService.asmx.vb $-->
'<!--$$NoKeywords: $-->
Option Strict On
Imports System
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Xml.Serialization
Imports System.Xml
Imports System.Data
Imports System.Data.SqlClient
Imports System.Web.Security
Imports System.Configuration
Imports Microsoft.ApplicationBlocks.Data
Imports System.Collections
Imports Microsoft.VisualBasic

<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class DataService
     Inherits System.Web.Services.WebService

    Private WithEvents daFSPJob As System.Data.SqlClient.SqlDataAdapter
    Private WithEvents sqlDeleteCommand1 As System.Data.SqlClient.SqlCommand
    Private WithEvents sqlUpdateCommand1 As System.Data.SqlClient.SqlCommand
    Private WithEvents sqlInsertCommand1 As System.Data.SqlClient.SqlCommand
    Private WithEvents sqlSelectCommand1 As System.Data.SqlClient.SqlCommand
    Public WithEvents dbConn As System.Data.SqlClient.SqlConnection

    Private Sub InitializeComponent()
        Me.dbConn = New System.Data.SqlClient.SqlConnection
        Me.sqlSelectCommand1 = New System.Data.SqlClient.SqlCommand
        Me.sqlInsertCommand1 = New System.Data.SqlClient.SqlCommand
        Me.sqlUpdateCommand1 = New System.Data.SqlClient.SqlCommand
        Me.sqlDeleteCommand1 = New System.Data.SqlClient.SqlCommand
        Me.daFSPJob = New System.Data.SqlClient.SqlDataAdapter
        '
        'dbConn
        '
        Dim configurationAppSettings As System.Configuration.AppSettingsReader = New System.Configuration.AppSettingsReader
        Me.dbConn.ConnectionString = CType(configurationAppSettings.GetValue("dbConn.ConnectionString", GetType(System.String)), String) & "user id=webcams101;database=WebCAMS;Persist Security Info=true;password=w!u4f&c;"
        Me.dbConn.FireInfoMessageEventOnUserErrors = False
        '
        'daFSPJob
        '
        Me.daFSPJob.DeleteCommand = Me.sqlDeleteCommand1
        Me.daFSPJob.InsertCommand = Me.sqlInsertCommand1
        Me.daFSPJob.SelectCommand = Me.sqlSelectCommand1
        Me.daFSPJob.UpdateCommand = Me.sqlUpdateCommand1

    End Sub

#Region "Client/FSP Common"
    <WebMethod()> _
    Public Function GetJobCount(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String

        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJobCount", userID)
            ds.Tables(0).TableName = "JobCount"
        Finally
            dbConn.Close()
        End Try

        Return ds

    End Function

#End Region
#Region "Client - Job"
    <WebMethod()> _
    Public Function GetJob(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Integer

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJob", userID, jobID)
            ds.Tables(0).TableName = "Job"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()>
    Public Function GetJobs(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim clientID As String
        Dim jobType As String
        Dim state As String
        Dim statusID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        jobType = Convert.ToString(myParam(2))
        state = Convert.ToString(myParam(3))
        statusID = Convert.ToString(myParam(4))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetOpenJobList", userID, clientID, jobType, statusID, state)
            ds.Tables(0).TableName = "Jobs"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()>
    Public Function CloseDeinstallJob(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Integer
        Dim fixID As Integer
        Dim notes As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt32(myParam(1))
        fixID = Convert.ToInt32(myParam(2))
        notes = Convert.ToString(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebCloseDeinstallJob", userID, jobID, fixID, EmptyToNull(notes))
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()>
    Public Function GetClientClosureReasons(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim jobType As String
        Dim fix As Integer

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        jobType = Convert.ToString(myParam(2))
        fix = Convert.ToInt32(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetClientClosureReasons", userID, clientID, jobType, fix)
            ds.Tables(0).TableName = "ClosureReasons"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region

#Region "Client - Log Job/Call"
    <WebMethod()> _
    Public Function GetClientTerminalConfigField(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim clientID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetClientTerminalConfigField", userID, clientID)
            ds.Tables(0).TableName = "Jobs"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetState(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim addAll As Boolean

        ticket = Convert.ToString(myParam(0))
        addAll = Convert.ToBoolean(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetState", userID, addAll)
            ds.Tables(0).TableName = "State"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetJobFilterStatus(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String

        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJobFilterStatus", userID)
            ds.Tables(0).TableName = "Status"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GetJobDeviceType(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim clientID As String
        Dim jobtypeID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        jobtypeID = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJobDeviceType", userID, clientID, jobtypeID)
            ds.Tables(0).TableName = "JobType"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetJobMethod(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim clientID As String
        Dim jobtypeID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        jobtypeID = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJobMethod", userID, clientID, jobtypeID)
            ds.Tables(0).TableName = "JobMethod"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetCallType(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim equipmentCode As String

        ticket = Convert.ToString(myParam(0))
        equipmentCode = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetCallType", userID, equipmentCode)
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetCallTypeSymptom(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim callTypeID As Integer

        ticket = Convert.ToString(myParam(0))
        callTypeID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetCallTypeSymptom", userID, callTypeID)
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetSymptomFault(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim symptomID As Integer

        ticket = Convert.ToString(myParam(0))
        symptomID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetSymptomFault", userID, symptomID)
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetAdditionalServiceType(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim clientID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetAdditionalServiceType", userID, clientID)
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
   <WebMethod()>
   Public Function ValidateTIDBeforeLogJob(ByVal myParam As ArrayList) As Object
      Dim ticket As String
      Dim clientID As String
      Dim terminalID As String
      Dim jobTypeID As Int16

      ticket = Convert.ToString(myParam(0))
      clientID = Convert.ToString(myParam(1))
      terminalID = Convert.ToString(myParam(2))
      jobTypeID = Convert.ToInt16(myParam(3))


      If Not IsTicketValid(ticket, False) Then Return Nothing

      Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

      Dim ret As Object
      Try
         ret = SqlHelper.ExecuteScalar(dbConn, "spWebValidateTIDBeforeLogJob", userID, clientID, terminalID, jobTypeID)
      Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
         ret = -1
         ThrowMySoapException(ex.Message, ex.Number)

      Finally
         dbConn.Close()
      End Try

      Return ret
   End Function
   <WebMethod()> _
    Public Function LogJob(ByVal myParam As ArrayList, ByRef pJobID As Integer) As Object
      Dim ticket As String
      Dim problemNumber As String
      Dim clientID As String
      Dim merchantID As String
      Dim terminalID As String
      Dim jobTypeID As Int16
      Dim jobMethodID As Int16
      Dim deviceType As String
      Dim specInstruct As String

      Dim installDateTime As String


      Dim name As String
      Dim address As String
      Dim address2 As String
      Dim city As String
      Dim state As String
      Dim postcode As String
      Dim contact As String
      Dim phoneNumber As String
      Dim mobileNumber As String
      Dim lineType As String
      Dim dialPrefix As String

      Dim oldDeviceType As String
      Dim oldTerminalID As String
      Dim businessActivity As String

      Dim urgent As Boolean

      Dim tradingHoursMon As String
      Dim tradingHoursTue As String
      Dim tradingHoursWed As String
      Dim tradingHoursThu As String
      Dim tradingHoursFri As String
      Dim tradingHoursSat As String
      Dim tradingHoursSun As String

      Dim updateSiteTradingHours As Boolean

      Dim configXML As String
      Dim jobNote As String
      Dim CAIC As String

      Dim contactEmail As String
      Dim bankersEmail As String
      Dim merchantEmail As String
      Dim customerNumber As String
      Dim altMerchantID As String
        Dim lostStolen As Boolean
        Dim projectNo As String


        ticket = Convert.ToString(myParam(0))
      problemNumber = Convert.ToString(myParam(1)).ToUpper()
      clientID = Convert.ToString(myParam(2)).ToUpper()
      merchantID = Convert.ToString(myParam(3)).ToUpper()
      terminalID = Convert.ToString(myParam(4)).ToUpper()
      jobTypeID = Convert.ToInt16(myParam(5))
      jobMethodID = Convert.ToInt16(myParam(6))
      deviceType = Convert.ToString(myParam(7)).ToUpper()
      specInstruct = Convert.ToString(myParam(8)).ToUpper()

      If IsDate(myParam(9).ToString) Then
         installDateTime = "20" & myParam(9).ToString.Substring(6, 2) & "-" & myParam(9).ToString.Substring(3, 2) & "-" & myParam(9).ToString.Substring(0, 2)
      Else
         installDateTime = ""
      End If

      name = Convert.ToString(myParam(10)).ToUpper()
      address = Convert.ToString(myParam(11)).ToUpper()
      address2 = Convert.ToString(myParam(12)).ToUpper()
      city = Convert.ToString(myParam(13)).ToUpper()
      state = Convert.ToString(myParam(14)).ToUpper()
      postcode = Convert.ToString(myParam(15)).ToUpper()
      contact = Convert.ToString(myParam(16)).ToUpper()
      phoneNumber = Convert.ToString(myParam(17)).ToUpper()
      mobileNumber = Convert.ToString(myParam(18)).ToUpper()
      lineType = Convert.ToString(myParam(19)).ToUpper()
      dialPrefix = Convert.ToString(myParam(20)).ToUpper()
      oldDeviceType = Convert.ToString(myParam(21)).ToUpper()
      oldTerminalID = Convert.ToString(myParam(22)).ToUpper()
      businessActivity = Convert.ToString(myParam(23)).ToUpper()
      urgent = Convert.ToBoolean(myParam(24))
      tradingHoursMon = Convert.ToString(myParam(25))
      tradingHoursTue = Convert.ToString(myParam(26))
      tradingHoursWed = Convert.ToString(myParam(27))
      tradingHoursThu = Convert.ToString(myParam(28))
      tradingHoursFri = Convert.ToString(myParam(29))

      tradingHoursSat = Convert.ToString(myParam(30))
      tradingHoursSun = Convert.ToString(myParam(31))

      updateSiteTradingHours = Convert.ToBoolean(myParam(32))

      configXML = Convert.ToString(myParam(33))
      jobNote = Convert.ToString(myParam(34))
      CAIC = Convert.ToString(myParam(35))

      contactEmail = Convert.ToString(myParam(36))
      bankersEmail = Convert.ToString(myParam(37))
      merchantEmail = Convert.ToString(myParam(38))
      customerNumber = Convert.ToString(myParam(39))
      altMerchantID = Convert.ToString(myParam(40))
        lostStolen = Convert.ToBoolean(myParam(41))
      projectNo = Convert.ToString(myParam(42))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)


        ''create stock received batch
        Dim paraJobID As SqlParameter
        paraJobID = New SqlParameter("@JobID", SqlDbType.Int, 4)
        paraJobID.Direction = ParameterDirection.InputOutput
        paraJobID.Value = pJobID


        Dim ret As Object
        Try

            ''only this virtual function supports output parameter. (refer SqlHelper for details)
            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebLogJob",
               New SqlParameter("@UserID", userID),
               paraJobID,
               New SqlParameter("@ProblemNumber", problemNumber),
               New SqlParameter("@ClientID", clientID),
               New SqlParameter("@MerchantID", merchantID),
               New SqlParameter("@TerminalID", terminalID),
               New SqlParameter("@JobTypeID", jobTypeID),
               New SqlParameter("@JobMethodID", jobMethodID),
               New SqlParameter("@DeviceType", deviceType),
               New SqlParameter("@SpecInstruct", EmptyToNull(specInstruct)),
               New SqlParameter("@InstallDateTime", EmptyToNull(installDateTime)),
               New SqlParameter("@Name", name),
               New SqlParameter("@Address", address),
               New SqlParameter("@Address2", EmptyToNull(address2)),
               New SqlParameter("@City", city),
               New SqlParameter("@State", state),
               New SqlParameter("@Postcode", postcode),
               New SqlParameter("@Contact", contact),
               New SqlParameter("@PhoneNumber", phoneNumber),
               New SqlParameter("@MobileNumber", EmptyToNull(mobileNumber)),
               New SqlParameter("@LineType", EmptyToNull(lineType)),
               New SqlParameter("@DialPrefix", EmptyToNull(dialPrefix)),
               New SqlParameter("@OldDeviceType", EmptyToNull(oldDeviceType)),
               New SqlParameter("@OldTerminalID", EmptyToNull(oldTerminalID)),
               New SqlParameter("@BusinessActivity", EmptyToNull(businessActivity)),
               New SqlParameter("@Urgent", urgent),
               New SqlParameter("@TradingHoursMon", EmptyToNull(tradingHoursMon)),
               New SqlParameter("@TradingHoursTue", EmptyToNull(tradingHoursTue)),
               New SqlParameter("@TradingHoursWed", EmptyToNull(tradingHoursWed)),
               New SqlParameter("@TradingHoursThu", EmptyToNull(tradingHoursThu)),
               New SqlParameter("@TradingHoursFri", EmptyToNull(tradingHoursFri)),
               New SqlParameter("@TradingHoursSat", EmptyToNull(tradingHoursSat)),
               New SqlParameter("@TradingHoursSun", EmptyToNull(tradingHoursSun)),
               New SqlParameter("@UpdateSiteTradingHours", updateSiteTradingHours),
               New SqlParameter("@ConfigXML", configXML),
               New SqlParameter("@JobNote", jobNote),
               New SqlParameter("@CAIC", EmptyToNull(CAIC)),
               New SqlParameter("@ContactEmail", EmptyToNull(contactEmail)),
               New SqlParameter("@BankersEmail", EmptyToNull(bankersEmail)),
               New SqlParameter("@MerchantEmail", EmptyToNull(merchantEmail)),
               New SqlParameter("@CustomerNumber", EmptyToNull(customerNumber)),
               New SqlParameter("@AltMerchantID", EmptyToNull(altMerchantID)),
               New SqlParameter("@LostStolen", lostStolen),
               New SqlParameter("@ProjectNo", projectNo))

            ''set return value of batchid
            pJobID = Convert.ToInt32(paraJobID.Value)

        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ret = -1
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret


    End Function
    <WebMethod()> _
    Public Function LogCall(ByVal myParam As ArrayList, ByRef pCallNumber As String) As Object
        Dim ticket As String
        Dim problemNumber As String
        Dim clientID As String
        Dim merchantID As String
        Dim terminalID As String
        Dim deviceType As String
        Dim specInstruct As String


        Dim name As String
        Dim address As String
        Dim address2 As String
        Dim city As String
        Dim state As String
        Dim postcode As String
        Dim contact As String
        Dim phoneNumber As String
        Dim mobileNumber As String
        Dim lineType As String
        Dim dialPrefix As String

        Dim callTypeID As String
        Dim symptomID As String
        Dim faultID As String
        Dim businessActivity As String

        Dim urgent As Boolean

        Dim tradingHoursMon As String
        Dim tradingHoursTue As String
        Dim tradingHoursWed As String
        Dim tradingHoursThu As String
        Dim tradingHoursFri As String

        Dim tradingHoursSat As String
        Dim tradingHoursSun As String

        Dim updateSiteTradingHours As Boolean

        Dim configXML As String
        Dim additionalServiceTypeID As String
        Dim jobNote As String
        Dim swapComponent As String
        Dim CAIC As String
        Dim techToAttWithoutCall As Boolean



        ticket = Convert.ToString(myParam(0))
        problemNumber = Convert.ToString(myParam(1)).ToUpper()
        clientID = Convert.ToString(myParam(2)).ToUpper()
        merchantID = Convert.ToString(myParam(3)).ToUpper()
        terminalID = Convert.ToString(myParam(4)).ToUpper()
        deviceType = Convert.ToString(myParam(5)).ToUpper()
        specInstruct = Convert.ToString(myParam(6)).ToUpper()


        name = Convert.ToString(myParam(7)).ToUpper()
        address = Convert.ToString(myParam(8)).ToUpper()
        address2 = Convert.ToString(myParam(9)).ToUpper()
        city = Convert.ToString(myParam(10)).ToUpper()
        state = Convert.ToString(myParam(11)).ToUpper()
        postcode = Convert.ToString(myParam(12)).ToUpper()
        contact = Convert.ToString(myParam(13)).ToUpper()
        phoneNumber = Convert.ToString(myParam(14)).ToUpper()
        mobileNumber = Convert.ToString(myParam(15)).ToUpper()
        lineType = Convert.ToString(myParam(16)).ToUpper()
        dialPrefix = Convert.ToString(myParam(17)).ToUpper()
        callTypeID = Convert.ToString(myParam(18)).ToUpper()
        symptomID = Convert.ToString(myParam(19)).ToUpper()
        faultID = Convert.ToString(myParam(20)).ToUpper()
        businessActivity = Convert.ToString(myParam(21)).ToUpper()
        urgent = Convert.ToBoolean(myParam(22))
        tradingHoursMon = Convert.ToString(myParam(23))
        tradingHoursTue = Convert.ToString(myParam(24))
        tradingHoursWed = Convert.ToString(myParam(25))
        tradingHoursThu = Convert.ToString(myParam(26))
        tradingHoursFri = Convert.ToString(myParam(27))

        tradingHoursSat = Convert.ToString(myParam(28))
        tradingHoursSun = Convert.ToString(myParam(29))

        updateSiteTradingHours = Convert.ToBoolean(myParam(30))

        configXML = Convert.ToString(myParam(31))
        additionalServiceTypeID = Convert.ToString(myParam(32))
        jobNote = Convert.ToString(myParam(33))
        swapComponent = Convert.ToString(myParam(34))
        CAIC = Convert.ToString(myParam(35))
        techToAttWithoutCall = Convert.ToBoolean(myParam(36))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)


        ''create stock received batch
        Dim paraJobID As SqlParameter
        paraJobID = New SqlParameter("@CallNumber", SqlDbType.VarChar, 11)
        paraJobID.Direction = ParameterDirection.InputOutput
        paraJobID.Value = pCallNumber



        Dim ret As Object
        Try

            ''only this virtual function supports output parameter. (refer SqlHelper for details)
            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebLogCall",
               New SqlParameter("@UserID", userID),
               paraJobID,
               New SqlParameter("@ProblemNumber", problemNumber),
               New SqlParameter("@ClientID", clientID),
               New SqlParameter("@MerchantID", merchantID),
               New SqlParameter("@TerminalID", terminalID),
               New SqlParameter("@DeviceType", EmptyToNull(deviceType)),
               New SqlParameter("@SpecInstruct", EmptyToNull(specInstruct)),
               New SqlParameter("@Name", name),
               New SqlParameter("@Address", address),
               New SqlParameter("@Address2", EmptyToNull(address2)),
               New SqlParameter("@City", city),
               New SqlParameter("@State", state),
               New SqlParameter("@Postcode", postcode),
               New SqlParameter("@Contact", EmptyToNull(contact)),
               New SqlParameter("@PhoneNumber", phoneNumber),
               New SqlParameter("@MobileNumber", EmptyToNull(mobileNumber)),
               New SqlParameter("@LineType", EmptyToNull(lineType)),
               New SqlParameter("@DialPrefix", EmptyToNull(dialPrefix)),
               New SqlParameter("@CallTypeID", EmptyToNull(callTypeID)),
               New SqlParameter("@SymptomID", EmptyToNull(symptomID)),
               New SqlParameter("@FaultID", EmptyToNull(faultID)),
               New SqlParameter("@BusinessActivity", EmptyToNull(businessActivity)),
               New SqlParameter("@Urgent", urgent),
               New SqlParameter("@TradingHoursMon", EmptyToNull(tradingHoursMon)),
               New SqlParameter("@TradingHoursTue", EmptyToNull(tradingHoursTue)),
               New SqlParameter("@TradingHoursWed", EmptyToNull(tradingHoursWed)),
               New SqlParameter("@TradingHoursThu", EmptyToNull(tradingHoursThu)),
               New SqlParameter("@TradingHoursFri", EmptyToNull(tradingHoursFri)),
               New SqlParameter("@TradingHoursSat", EmptyToNull(tradingHoursSat)),
               New SqlParameter("@TradingHoursSun", EmptyToNull(tradingHoursSun)),
               New SqlParameter("@UpdateSiteTradingHours", updateSiteTradingHours),
               New SqlParameter("@ConfigXML", configXML),
               New SqlParameter("@AdditionalServiceTypeID", EmptyToNull(additionalServiceTypeID)),
               New SqlParameter("@JobNote", jobNote),
               New SqlParameter("@SwapComponent", swapComponent),
               New SqlParameter("@CAIC", EmptyToNull(CAIC)),
               New SqlParameter("@TechToAttWithoutCall", techToAttWithoutCall))


            ''set return value of batchid
            pCallNumber = Convert.ToString(paraJobID.Value)

        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ret = -1
            ThrowMySoapException(ex.Message, ex.Number)

        Finally
            dbConn.Close()
        End Try

        Return ret


    End Function
    <WebMethod()> _
    Public Function GetDeviceComponent(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim clientID As String
        Dim terminalID As String
        Dim categoryID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        terminalID = Convert.ToString(myParam(2))
        categoryID = Convert.ToString(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetDeviceComponent", userID, clientID, terminalID, categoryID)
            ds.Tables(0).TableName = "Components"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function DuplicateJob(ByVal myParam As ArrayList, ByRef pJobID As Integer) As Object
        Dim ticket As String
        Dim clientID As String
        Dim terminalID As String
        Dim newTerminalID As String
        Dim newCAIC As String


        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1)).ToUpper()
        terminalID = Convert.ToString(myParam(2)).ToUpper()
        newTerminalID = Convert.ToString(myParam(3)).ToUpper()
        newCAIC = Convert.ToString(myParam(4)).ToUpper()
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)


        ''create stock received batch
        Dim paraJobID As SqlParameter
        paraJobID = New SqlParameter("@NewJobID", SqlDbType.Int, 4)
        paraJobID.Direction = ParameterDirection.InputOutput
        paraJobID.Value = pJobID


        Dim ret As Object
        Try

            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebDuplicateJob", _
               New SqlParameter("@UserID", userID), _
               New SqlParameter("@ClientID", clientID), _
               New SqlParameter("@TerminalID", terminalID), _
               New SqlParameter("@NewTerminalID", newTerminalID), _
               New SqlParameter("@NewCAIC", EmptyToNull(newCAIC)), _
               paraJobID)

            ''set return value of batchid
            pJobID = Convert.ToInt32(paraJobID.Value)

        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ret = -1
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret


    End Function

#End Region

#Region "Client - Call"
    <WebMethod()> _
    Public Function GetCall(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim callNumber As String

        ticket = Convert.ToString(myParam(0))
        callNumber = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetCall", userID, callNumber)
            ds.Tables(0).TableName = "Call"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GetCalls(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim state As String
        Dim statusID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        state = Convert.ToString(myParam(2))
        statusID = Convert.ToString(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetOpenCallList", userID, clientID, statusID, state)
            ds.Tables(0).TableName = "Calls"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region

#Region "Client - Site"
    <WebMethod()> _
    Public Function GetSite(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim TerminalID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        TerminalID = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetSite", userID, clientID, _
                                                EmptyToNull(TerminalID))
            ds.Tables(0).TableName = "Site"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetSites(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim TerminalID As String
        Dim MerchantID As String
        Dim Name As String
        Dim Suburb As String
        Dim Postcode As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        TerminalID = Convert.ToString(myParam(2))
        MerchantID = Convert.ToString(myParam(3))
        Name = Convert.ToString(myParam(4))
        Suburb = Convert.ToString(myParam(5))
        Postcode = Convert.ToString(myParam(6))



        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetSiteList", userID, clientID, _
                                                EmptyToNull(TerminalID), EmptyToNull(MerchantID), _
                                                EmptyToNull(Name), EmptyToNull(Suburb), _
                                                EmptyToNull(Postcode))
            ds.Tables(0).TableName = "Sites"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

   <WebMethod()>
   Public Function GetSiteEquipments(ByVal myParam As ArrayList) As DataSet
      Dim ticket As String
      Dim clientID As String
      Dim TerminalID As String
      ticket = Convert.ToString(myParam(0))
      clientID = Convert.ToString(myParam(1))
      TerminalID = Convert.ToString(myParam(2))

      If Not IsTicketValid(ticket, False) Then Return Nothing

      Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

      Dim ds As DataSet
      Try
         ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetSiteEquipmentList", userID, clientID, TerminalID)
         ds.Tables(0).TableName = "SiteEquipments"
      Finally
         dbConn.Close()
      End Try

      Return ds
   End Function

   <WebMethod()> _
    Public Function PutSite(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim clientID As String
        Dim terminalID As String
        Dim merchantID As String
        Dim name As String
        Dim address As String
        Dim address2 As String
        Dim postcode As String
        Dim city As String
        Dim state As String
        Dim contact As String
        Dim phoneNumber As String
        Dim phoneNumber2 As String
        Dim tradingHoursMon As String
        Dim tradingHoursTue As String
        Dim tradingHoursWed As String
        Dim tradingHoursThu As String
        Dim tradingHoursFri As String
        Dim tradinghoursSat As String
        Dim tradinghoursSun As String
        Dim applyChangeToOtherMerchantRecord As Boolean
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1)).ToUpper
        terminalID = Convert.ToString(myParam(2)).ToUpper
        merchantID = Convert.ToString(myParam(3)).ToUpper
        name = Convert.ToString(myParam(4)).ToUpper
        address = Convert.ToString(myParam(5)).ToUpper
        address2 = Convert.ToString(myParam(6)).ToUpper
        city = Convert.ToString(myParam(7)).ToUpper
        state = Convert.ToString(myParam(8)).ToUpper
        postcode = Convert.ToString(myParam(9)).ToUpper
        contact = Convert.ToString(myParam(10)).ToUpper
        phoneNumber = Convert.ToString(myParam(11))
        phoneNumber2 = Convert.ToString(myParam(12))
        tradingHoursMon = Convert.ToString(myParam(13))
        tradingHoursTue = Convert.ToString(myParam(14))
        tradingHoursWed = Convert.ToString(myParam(15))
        tradingHoursThu = Convert.ToString(myParam(16))
        tradingHoursFri = Convert.ToString(myParam(17))
        tradinghoursSat = Convert.ToString(myParam(18))
        tradinghoursSun = Convert.ToString(myParam(19))
        applyChangeToOtherMerchantRecord = Convert.ToBoolean(myParam(20))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            'EXEC @ret = CAMS.dbo.spWebPutSite @UserID = @UserID, 
            '			@ClientID = @ClientID, 
            '			@TerminalID = @TerminalID,
            '			@MerchantID = @MerchantID, 
            '			@Name = @Name, 
            '			@Address = @Address,
            '			@Address2 = @Address2, 
            '			@City = @City, 
            '			@State = @State, 
            '			@Postcode = @Postcode, 
            '			@Contact = @Contact, 
            '			@PhoneNumber = @PhoneNumber, 
            '			@PhoneNumber2 = @PhoneNumber2, 
            '      @TradingHoursMon = @TradingHoursMon,
            '      @TradingHoursTue = @TradingHoursTue,
            '      @TradingHoursWed = @TradingHoursWed,
            '      @TradingHoursThu = @TradingHoursThu,
            '      @TradingHoursFri = @TradingHoursFri,
            ''			@TradingHoursSat = @TradingHoursSat, 
            '			@TradingHoursSun = @TradingHoursSun, 
            '			@ApplyChangeToOtherMerchantRecord = @ApplyChangeToOtherMerchantRecord
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutSite", userID, clientID, terminalID, merchantID, _
                                name, address, EmptyToNull(address2), city, state, postcode, _
                                EmptyToNull(contact), EmptyToNull(phoneNumber), EmptyToNull(phoneNumber2), _
                                EmptyToNull(tradingHoursMon), EmptyToNull(tradingHoursTue), EmptyToNull(tradingHoursWed), _
                                EmptyToNull(tradingHoursThu), EmptyToNull(tradingHoursFri), EmptyToNull(tradinghoursSat), EmptyToNull(tradinghoursSun), _
                                applyChangeToOtherMerchantRecord)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
#End Region

#Region "Client - QuickFind"
    <WebMethod()> _
    Public Function GetQuickFindList(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim scope As String
        Dim terminalID As String
        Dim merchantID As String
        Dim problemNumber As String
        Dim jobID As String
        Dim customerNumber As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        scope = Convert.ToString(myParam(2))
        terminalID = Convert.ToString(myParam(3))
        merchantID = Convert.ToString(myParam(4))
        problemNumber = Convert.ToString(myParam(5))
        jobID = Convert.ToString(myParam(6))
        customerNumber = Convert.ToString(myParam(7))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebQuickFind", userID, clientID, scope,
                                                EmptyToNull(terminalID), EmptyToNull(merchantID),
                                                EmptyToNull(problemNumber), EmptyToNull(jobID),
                                                EmptyToNull(customerNumber))
            ds.Tables(0).TableName = "QuickFind"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region

#Region "Client - TerminalJobList"
    <WebMethod()> _
    Public Function GetTerminalJobList(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim clientID As String
        Dim terminalID As String
        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        terminalID = Convert.ToString(myParam(2))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetTerminalList", userID, clientID, _
                                                EmptyToNull(terminalID))
            ds.Tables(0).TableName = "TermianlJob"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region
#Region "Client - Device"
    <WebMethod()> _
    Public Function GetDeviceListBySerial(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim serial As String
        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        serial = Convert.ToString(myParam(2))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetDeviceListBySerial", userID, clientID, _
                                                EmptyToNull(serial))
            ds.Tables(0).TableName = "DeviceList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GetDeviceBySerial(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim serial As String
        Dim from As String
        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        serial = Convert.ToString(myParam(2))
        from = Convert.ToString(myParam(3))



        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetDeviceBySerial", userID, clientID, _
                                                EmptyToNull(serial), EmptyToNull(from))
            ds.Tables(0).TableName = "Device"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region
#Region "Client - Update Job Info"
    <WebMethod()> _
    Public Function GetClientUpdateInfoFieldList(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetClientUpdateInfoFieldList", userID, jobID)
            ds.Tables(0).TableName = "Job"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function UpdateJobInfo(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim jobInfo As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        JobID = Convert.ToInt64(myParam(1))
        JobInfo = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebUpdateJobInfo", userID, jobID, jobInfo)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

#End Region


#Region "Client - Related Items"
    <WebMethod()>
    Public Function GetClientProjects(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetClientProject", userID, clientID)
            ds.Tables(0).TableName = "ProjectList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region

#Region "Client - Customers"
    <WebMethod()>
    Public Function GetCustomers(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String

        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetCustomers", userID, clientID)
            ds.Tables(0).TableName = "CustomerList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region
#Region "FSP - Job"
    <WebMethod()> _
    Public Function GetFSPJob(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPJobID As Long
        ticket = Convert.ToString(myParam(0))
        FSPJobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPJob", userID, FSPJobID)
            ds.Tables(0).TableName = "FSPJob"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    '<WebMethod()> _
    'Public Function GetFSPJobDS(ByVal myParam As ArrayList) As DatasetFSPJob
    '    Dim ticket As String
    '    ticket = Convert.ToString(myParam(0))

    '    If Not IsTicketValid(ticket, False) Then Return Nothing

    '    Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

    '    Dim ds As New DatasetFSPJob
    '    daFSPJob.SelectCommand.Parameters("@UserID").Value = userID
    '    daFSPJob.Fill(ds, "FSPJobs")

    '    Return ds
    'End Function
    '<WebMethod()> _
    'Public Function UpdateFSPJobDS(ByVal myParam As ArrayList) As DatasetFSPJob
    '    Dim ticket As String
    '    Dim dsFSPJobs As DatasetFSPJob
    '    ticket = Convert.ToString(myParam(0))
    '    dsFSPJobs = CType(myParam(1), DatasetFSPJob)


    '    If Not IsTicketValid(ticket, False) Then Return Nothing

    '    Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)


    '    'we're doing a loop on the update function and breaking out on a successful update
    '    'or returning prematurely from a data collision, this allows us to handle
    '    'missing data without returning to the client.
    '    Do
    '        Try
    '            'try to update the db
    '            daFSPJob.Update(dsFSPJobs, "FSPJobs")
    '            Exit Do 'this is the most common path
    '        Catch dbEx As DBConcurrencyException
    '            'we're here because either the row was changed by someone else
    '            'or deleted by the dba, let's try get the updated row
    '            Dim ds As New DataSet
    '            Dim cmd As New SqlCommand("spWebGetFSPJob", dbConn)
    '            cmd.CommandType = CommandType.StoredProcedure

    '            'get the updated row
    '            Dim da As New SqlDataAdapter(cmd)
    '            da.SelectCommand.Parameters.AddWithValue("@UserID", dbEx.Row.Item("UserID"))
    '            da.SelectCommand.Parameters.AddWithValue("@JobID", dbEx.Row.Item("JobID"))
    '            da.Fill(ds)

    '            'if the row still exists
    '            If ds.Tables(0).Rows.Count > 0 Then
    '                Dim proposedRow As DataRow = dbEx.Row.Table.NewRow()
    '                Dim databaseRow As DataRow = ds.Tables(0).Rows(0)

    '                'copy the attempted changes
    '                proposedRow.ItemArray = dbEx.Row.ItemArray

    '                'set the row with what's in the database and then re-apply
    '                'the proposed changes.
    '                With dbEx.Row
    '                    Dim oCol As DataColumn
    '                    For Each oCol In .Table.Columns
    '                        If oCol.ColumnName <> "OnSiteDateTime" AndAlso oCol.ColumnName <> "OffSiteDateTime" Then
    '                            oCol.ReadOnly = False
    '                        End If
    '                    Next
    '                    .ItemArray = databaseRow.ItemArray
    '                    .AcceptChanges()
    '                    .ItemArray = proposedRow.ItemArray

    '                    For Each oCol In .Table.Columns
    '                        If oCol.ColumnName <> "OnSiteDateTime" AndAlso oCol.ColumnName <> "OffSiteDateTime" Then
    '                            oCol.ReadOnly = True
    '                        End If
    '                    Next

    '                    '.Table.Columns("UserID").ReadOnly = False
    '                    '.Table.Columns("JobID").ReadOnly = False
    '                    '.ItemArray = databaseRow.ItemArray
    '                    '.AcceptChanges()
    '                    '.ItemArray = proposedRow.ItemArray
    '                    '.Table.Columns("UserID").ReadOnly = True
    '                    '.Table.Columns("JobID").ReadOnly = True
    '                End With

    '                'note: because this row trigger an ADO.NET exception,
    '                'the row was tagged with a rowerror property which we'll leave for the client app
    '                Return dsFSPJobs
    '            Else
    '                'row was deleted from underneath user, deletion always wins
    '                dbEx.Row.Delete()
    '                dbEx.Row.AcceptChanges()
    '            End If
    '        End Try
    '    Loop

    '    'all updates successful
    '    'dump the data and get a clean tasks table
    '    dsFSPJobs.Clear()
    '    daFSPJob.SelectCommand.Parameters("@UserID").Value = userID
    '    daFSPJob.Fill(dsFSPJobs, "FSPJobs")

    '    Return dsFSPJobs
    'End Function

    <WebMethod()> _
    Public Function GetFSPJobs(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim jobType As String
        Dim from As Int16
        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        jobType = Convert.ToString(myParam(2))
        from = Convert.ToInt16(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPOpenJobList", userID, clientID, jobType, from)
            ds.Tables(0).TableName = "FSPJobs"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region
#Region "FSP - Call"
    <WebMethod()> _
    Public Function GetFSPCall(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim callNumber As String
        ticket = Convert.ToString(myParam(0))
        callNumber = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPCall", userID, callNumber)
            ds.Tables(0).TableName = "Call"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPCalls(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim clientID As String
        Dim from As Int16
        ticket = Convert.ToString(myParam(0))
        clientID = Convert.ToString(myParam(1))
        from = Convert.ToInt16(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPOpenCallList", userID, clientID, from)
            ds.Tables(0).TableName = "FSPCalls"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GMapGetFSPJob(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobViewer As String
        ticket = Convert.ToString(myParam(0))
        jobViewer = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGMapGetFSPJob", userID, jobViewer)
            ds.Tables(0).TableName = "FSPJob"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region
#Region "FSP Closed Jobs"
    <WebMethod()> _
    Public Function GetFSPClosedJobs(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPID As String
        Dim jobType As String
        Dim fromDate As DateTime
        Dim toDate As DateTime
        Dim jobIDs As String
        Dim from As Int16

        ticket = Convert.ToString(myParam(0))
        FSPID = Convert.ToString(myParam(1))
        jobType = Convert.ToString(myParam(2))
        fromDate = Convert.ToDateTime(myParam(3))
        toDate = Convert.ToDateTime(myParam(4))
        jobIDs = Convert.ToString(myParam(5))
        from = Convert.ToInt16(myParam(6))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPClosedJobList", userID, EmptyToNull(FSPID), EmptyToNull(jobType), fromDate, toDate, EmptyToNull(jobIDs), from)
            ds.Tables(0).TableName = "FSPClosedJobList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPClosedJobWithOutstandingDevice(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPID As String
        Dim fromDate As DateTime
        Dim toDate As DateTime
        Dim from As Int16

        ticket = Convert.ToString(myParam(0))
        FSPID = Convert.ToString(myParam(1))
        fromDate = Convert.ToDateTime(myParam(2))
        toDate = Convert.ToDateTime(myParam(3))
        from = Convert.ToInt16(myParam(4))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPClosedJobWithOutstandingDevice", userID, FSPID, fromDate, toDate, from)
            ds.Tables(0).TableName = "FSPClosedJobList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GetFSPJobEquipmentHistory(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPJobEquipmentHistory", userID, jobID)
            ds.Tables(0).TableName = "FSPJobEquipmentHistory"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "FSP Open Jobs"
    <WebMethod()> _
    Public Function GetFSPAllOpenJob(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPID As String
        Dim from As Int16
        Dim jobtype As String
        Dim duedatetime As String
        Dim NoDeviceReservedOnly As Boolean
        Dim projectNo As String
        Dim city As String
        Dim postcode As String
        Dim IncludeChildDepot As Boolean
        Dim jobIDs As String


        ticket = Convert.ToString(myParam(0))
        FSPID = Convert.ToString(myParam(1))
        from = Convert.ToInt16(myParam(2))
        jobtype = Convert.ToString(myParam(3))
        duedatetime = Convert.ToString(myParam(4))
        NoDeviceReservedOnly = Convert.ToBoolean(myParam(5))
        projectNo = Convert.ToString(myParam(6))
        city = Convert.ToString(myParam(7))
        postcode = Convert.ToString(myParam(8))
        IncludeChildDepot = Convert.ToBoolean(myParam(9))
        jobIDs = Convert.ToString(myParam(10))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPAllOpenJob", userID, EmptyToNull(FSPID), from, EmptyToNull(jobtype), EmptyToNull(duedatetime), NoDeviceReservedOnly, EmptyToNull(projectNo), EmptyToNull(city), EmptyToNull(postcode), IncludeChildDepot, EmptyToNull(jobIDs))
            ds.Tables(0).TableName = "FSPOpenJobList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "FSP Book Job"
    <WebMethod()> _
    Public Function GetFSPJobsForBooking(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As String


        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToString(myParam(1))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPJobsForBooking", userID, jobID)
            ds.Tables(0).TableName = "FSPJobsForBooking"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function FSPBookJob(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobIDs As String
        Dim bookInstaller As Integer
        Dim bookForDateTime As DateTime
        Dim notes As String

        ticket = Convert.ToString(myParam(0))
        jobIDs = Convert.ToString(myParam(1))
        bookInstaller = Convert.ToInt32(myParam(2))
        bookForDateTime = Convert.ToDateTime(myParam(3))
        notes = Convert.ToString(myParam(4))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebFSPBookJob", userID, jobIDs, bookInstaller, bookForDateTime, notes)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function GetFSPEscalateJobBookingReason(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String


        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPEscalateJobBookingReason", userID)
            ds.Tables(0).TableName = "FSPEscalateJobBookingReason"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function EscalateFSPJobBooking(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobIDList As String
        Dim escalateReasonId As Int16
        Dim notes As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobIDList = Convert.ToString(myParam(1))
        escalateReasonId = Convert.ToInt16(myParam(2))
        notes = Convert.ToString(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebFSPEscalateJobBooking", userID, jobIDList, escalateReasonId, EmptyToNull(notes))
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
#End Region
#Region "FSP Open Tasks"
    <WebMethod()> _
    Public Function GetFSPOpenTaskList(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPID As String
        Dim from As Int16

        ticket = Convert.ToString(myParam(0))
        FSPID = Convert.ToString(myParam(1))
        from = Convert.ToInt16(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPOpenTaskList", userID, EmptyToNull(FSPID), from)
            ds.Tables(0).TableName = "FSPOpenTaskList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GetFSPTask(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPTaskID As Integer

        ticket = Convert.ToString(myParam(0))
        FSPTaskID = Convert.ToInt32(myParam(1))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPTask", userID, FSPTaskID)
            ds.Tables(0).TableName = "FSPTask"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function PutFSPTask(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim FSPTaskID As Integer
        Dim carrierID As String
        Dim conNoteNo As String
        Dim closeComment As String

        ticket = Convert.ToString(myParam(0))
        FSPTaskID = Convert.ToInt32(myParam(1))
        carrierID = Convert.ToString(myParam(2))
        conNoteNo = Convert.ToString(myParam(3))
        closeComment = Convert.ToString(myParam(4))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)


        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutFSPTask", userID, FSPTaskID, _
                                                        EmptyToNull(carrierID), EmptyToNull(conNoteNo), _
                                                        EmptyToNull(closeComment))
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function AddFSPTaskDevice(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPTaskID As Integer
        Dim serial As String
        Dim MMD_ID As String

        ticket = Convert.ToString(myParam(0))
        FSPTaskID = Convert.ToInt32(myParam(1))
        serial = Convert.ToString(myParam(2))
        MMD_ID = Convert.ToString(myParam(3))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebAddFSPTaskDevice", userID, FSPTaskID, _
                                                    serial, EmptyToNull(MMD_ID))
            ds.Tables(0).TableName = "FSPDevice"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function CloseFSPTask(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim FSPTaskID As Integer

        ticket = Convert.ToString(myParam(0))
        FSPTaskID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebCloseFSPTask", userID, FSPTaskID)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function GetFSPTaskJobPostData(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPTaskID As Integer

        ticket = Convert.ToString(myParam(0))
        FSPTaskID = Convert.ToInt32(myParam(1))
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebFSPGetTaskJobPostData", userID, FSPTaskID)
            ds.Tables(0).TableName = "FSPTask"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPTaskView(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPTaskID As Integer

        ticket = Convert.ToString(myParam(0))
        FSPTaskID = Convert.ToInt32(myParam(1))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPTaskView", userID, FSPTaskID)
            ds.Tables(0).TableName = "FSPTask"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "FSP Closed Tasks"
    <WebMethod()> _
    Public Function GetFSPClosedTasks(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPID As String
        Dim fromDate As Date
        Dim toDate As Date

        ticket = Convert.ToString(myParam(0))
        FSPID = Convert.ToString(myParam(1))
        fromDate = Convert.ToDateTime(myParam(2))
        toDate = Convert.ToDateTime(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPClosedTaskList", userID, EmptyToNull(FSPID), fromDate, toDate)
            ds.Tables(0).TableName = "FSPClosedTaskList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

#End Region
#Region "FSP Job Closure"
    <WebMethod()> _
    Public Function GetFSPJobClosure(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPJobClosure", userID, jobID)
            ds.Tables(0).TableName = "FSPJob"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPJobEquipment(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPJobEquipment", userID, jobID)
            If ds.Tables.Count > 0 Then
                ds.Tables(0).TableName = "FSPJobEq"
            End If

        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function DelFSPJobEquipment(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim serial As String
        Dim mmd_id As String
        Dim action As Int16
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        serial = Convert.ToString(myParam(2))
        mmd_id = Convert.ToString(myParam(3))
        action = Convert.ToInt16(myParam(4))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebDelFSPJobEquipment", userID, jobID, serial, EmptyToNull(mmd_id), action)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function UpdateFSPJobEquipment(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim serial As String
        Dim mmd_id As String
        Dim newSerial As String
        Dim newMmd_id As String
        Dim action As Int16
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        serial = Convert.ToString(myParam(2))
        mmd_id = Convert.ToString(myParam(3))
        newSerial = Convert.ToString(myParam(4))
        newMmd_id = Convert.ToString(myParam(5))
        action = Convert.ToInt16(myParam(6))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
			ret = SqlHelper.ExecuteScalar(dbConn, "spWebUpdateFSPJobEquipment", userID, jobID, serial, EmptyToNull(mmd_id), newSerial, EmptyToNull(newMmd_id), action)
		Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function AddFSPJobEquipment(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim serial As String
        Dim mmd_id As String
        Dim newSerial As String
        Dim newMmd_id As String
        Dim action As Int16
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        serial = Convert.ToString(myParam(2))
        mmd_id = Convert.ToString(myParam(3))
        newSerial = Convert.ToString(myParam(4))
        newMmd_id = Convert.ToString(myParam(5))
        action = Convert.ToInt16(myParam(6))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
			ret = SqlHelper.ExecuteScalar(dbConn, "spWebAddFSPJobEquipment", userID, jobID, serial, EmptyToNull(mmd_id), newSerial, EmptyToNull(newMmd_id), action)
		Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()>
    Public Function CloseFSPJob(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim techFixID As Int16
        Dim notes As String
        Dim onSiteDateTime As DateTime
        Dim offSiteDateTime As DateTime
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        techFixID = Convert.ToInt16(myParam(2))
        notes = Convert.ToString(myParam(3))
        onSiteDateTime = Convert.ToDateTime(myParam(4))
        offSiteDateTime = Convert.ToDateTime(myParam(5))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebCloseFSPJob", userID, jobID, techFixID, EmptyToNull(notes), onSiteDateTime, offSiteDateTime)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function GetFSPJobParts(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPJobParts", userID, jobID)
            If ds.Tables.Count > 0 Then
                ds.Tables(0).TableName = "FSPJobParts"
            End If

        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function DelFSPJobParts(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim partID As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        partID = Convert.ToString(myParam(2))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebDelFSPJobParts", userID, jobID, partID)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function PutFSPJobParts(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim partID As String
        Dim qty As Integer
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        partID = Convert.ToString(myParam(2))
        qty = Convert.ToInt32(myParam(3))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutFSPJobParts", userID, jobID, partID, qty)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function

    <WebMethod()>
    Public Function GetFSPParts(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPParts", userID, jobID)
            If ds.Tables.Count > 0 Then
                ds.Tables(0).TableName = "FSPJobParts"
            End If

        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()>
    Public Function PutFSPMissingJobParts(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobID As Long
        Dim partsList As String

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        partsList = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutMissingParts", jobID, partsList, userID)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function SetMerchantDamaged(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim serial As String
        Dim mmd_id As String
        Dim isMerchantDamaged As Boolean
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        serial = Convert.ToString(myParam(2))
        mmd_id = Convert.ToString(myParam(3))
        isMerchantDamaged = Convert.ToBoolean(myParam(4))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebSetMerchantDamaged", userID, jobID, serial, mmd_id, isMerchantDamaged)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function GetJobKittedDevice(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        Dim checkFSPConfirmLog As Boolean
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        checkFSPConfirmLog = Convert.ToBoolean(myParam(2))
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJobKittedDevice", userID, jobID, checkFSPConfirmLog)
            If ds.Tables.Count > 0 Then
                ds.Tables(0).TableName = "KittedDevice"
            End If

        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function ConfirmKittedPartsUsage(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebConfirmKittedPartsUsage", userID, jobID)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function

    <WebMethod()>
    Public Function SwapBundledSIM(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        Dim simOut As String
        Dim simIn As String

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        simOut = Convert.ToString(myParam(2))
        simIn = Convert.ToString(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebSwapBundledSIM", userID, jobID, simOut, simIn)
            If ds.Tables.Count > 0 Then
                ds.Tables(0).TableName = "BundledSIMSwap"
            End If
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "FSP Stock Search"
    <WebMethod()> _
    Public Function GetFSPStockList(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPID As Integer
        Dim conditions As String
        Dim from As Int16
        Dim transitToEE As Boolean
        ticket = Convert.ToString(myParam(0))
        FSPID = Convert.ToInt32(myParam(1))
        conditions = Convert.ToString(myParam(2))
        from = Convert.ToInt16(myParam(3))
        transitToEE = Convert.ToBoolean(myParam(4))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPStockList", userID, FSPID, conditions, from, transitToEE)
            ds.Tables(0).TableName = "FSPStockList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPDeviceListBySerial(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim serial As String
        Dim from As Int16
        ticket = Convert.ToString(myParam(0))
        serial = Convert.ToString(myParam(1))
        from = Convert.ToInt16(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPDeviceListBySerial", userID, serial, from)
            ds.Tables(0).TableName = "FSPDeviceList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "FSP Stock Received"
    <WebMethod()> _
    Public Function GetFSPStockReceivedLog(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim batchID As Integer
        Dim from As Int16
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))
        from = Convert.ToInt16(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPStockReceivedLog", userID, batchID, from)
            ds.Tables(0).TableName = "FSPStockReceivedLog"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GetFSPStockReceived(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim batchID As Integer
        Dim status As String
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))
        status = Convert.ToString(myParam(2))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPStockReceived", userID, "W", batchID, EmptyToNull(status))
            ds.Tables(0).TableName = "FSPStockReceived"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function PutFSPStockReceived(ByVal myParam As ArrayList, ByRef pBatchID As Integer) As Object
        Dim ticket As String
        ''Dim batchID As Integer
        Dim depot As Integer
        Dim dateReceived As Date
        Dim status As String
        ticket = Convert.ToString(myParam(0))
        ''batchID = Convert.ToInt32(myParam(1))
        depot = Convert.ToInt32(myParam(1))
        dateReceived = Convert.ToDateTime(myParam(2))
        status = Convert.ToString(myParam(3))



        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)


        ''create stock received batch
        Dim paraBatchID As SqlParameter
        paraBatchID = New SqlParameter("@BatchID", SqlDbType.Int, 4)
        paraBatchID.Direction = ParameterDirection.InputOutput
        paraBatchID.Value = pBatchID



        Dim ret As Object
        Try

            ''only this virtual function supports output parameter. (refer SqlHelper for details)
            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebPutFSPStockReceived", _
               New SqlParameter("@UserID", userID), _
               New SqlParameter("@SourceID", "W"), _
               paraBatchID, _
               New SqlParameter("@Depot", depot), _
               New SqlParameter("@DateReceived", dateReceived), _
               New SqlParameter("@Status", status))

            ''set return value of batchid
            pBatchID = Convert.ToInt32(paraBatchID.Value)
        Finally
            dbConn.Close()
        End Try

        Return ret


    End Function
    <WebMethod()> _
    Public Function AddFSPStockReceivedLog(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim batchID As Integer
        Dim serial As String
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))
        serial = Convert.ToString(myParam(2))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebAddFSPStockReceivedLog", userID, batchID, _
                                                    serial)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)

        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function CloseFSPStockReceivedAndSendReport(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim batchID As Integer
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebCloseFSPStockReceivedAndSendReport", userID, batchID)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function


#End Region
#Region "FSP Stock Returned"
  <WebMethod()>
  Public Function GetFSPStockReturnedLog(ByVal myParam As ArrayList) As DataSet
    Dim ticket As String
    Dim batchID As Integer
    Dim from As Int16
    Dim updAsFaulty As Boolean
    Dim spName As String
    Dim tbName As String

    ticket = Convert.ToString(myParam(0))
    batchID = Convert.ToInt32(myParam(1))
    from = Convert.ToInt16(myParam(2))
    updAsFaulty = Convert.ToBoolean(myParam(3))

    If Not IsTicketValid(ticket, False) Then Return Nothing

    Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

    ''only this virtual function supports output parameter. (refer SqlHelper for details)
    spName = IIf(updAsFaulty, "spWebGetFSPStockFaultyLog", "spWebGetFSPStockReturnedLog").ToString
    tbName = IIf(updAsFaulty, "FSPStockFaultyLog", "FSPStockReturnedLog").ToString

    Dim ds As DataSet
    Try
      ds = SqlHelper.ExecuteDataset(dbConn, spName, userID, batchID, from)
      ds.Tables(0).TableName = tbName
    Finally
      dbConn.Close()
    End Try

    Return ds
  End Function

  <WebMethod()>
  Public Function GetFSPStockReturned(ByVal myParam As ArrayList) As DataSet
    Dim ticket As String
    Dim batchID As Integer
    Dim status As String
    Dim updAsFaulty As Boolean
    Dim spName As String
    Dim tbName As String

    ticket = Convert.ToString(myParam(0))
    batchID = Convert.ToInt32(myParam(1))
    status = Convert.ToString(myParam(2))
    updAsFaulty = Convert.ToBoolean(myParam(3))


    If Not IsTicketValid(ticket, False) Then Return Nothing

    Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

    spName = IIf(updAsFaulty, "spWebGetFSPStockFaulty", "spWebGetFSPStockReturned").ToString
    tbName = IIf(updAsFaulty, "FSPStockFaulty", "FSPStockReturned").ToString

    Dim ds As DataSet
    Try
      ds = SqlHelper.ExecuteDataset(dbConn, spName, userID, "W", batchID, EmptyToNull(status))
      ds.Tables(0).TableName = tbName
    Finally
      dbConn.Close()
    End Try

    Return ds
  End Function
  <WebMethod()> _
    Public Function PutFSPStockReturned(ByVal myParam As ArrayList, ByRef pBatchID As Integer) As Object
    Dim ticket As String
    Dim batchID As Integer
    Dim fromLocation As Integer
    Dim toLocation As Integer
    Dim dateReturned As Date
    Dim referenceNo As String
    Dim note As String
    Dim status As String
    Dim updAsFaulty As Boolean
    Dim spName1 As String
    Dim spName2 As String
    Dim strSerial As String
    Dim caseid As Integer
    Dim validateFaultyStock As Boolean
    Dim listCount As Integer
    Dim ret As Object

    listCount = myParam.Count
    validateFaultyStock = False

    ticket = Convert.ToString(myParam(0))
    If listCount = 8 Then
      fromLocation = Convert.ToInt32(myParam(1))
      toLocation = Convert.ToInt32(myParam(2))
      dateReturned = Convert.ToDateTime(myParam(3))
      referenceNo = Convert.ToString(myParam(4))
      note = Convert.ToString(myParam(5))
      status = Convert.ToString(myParam(6))
      updAsFaulty = Convert.ToBoolean(myParam(7))
    Else
      batchID = Convert.ToInt32(myParam(1))
      fromLocation = Convert.ToInt32(myParam(2))
      toLocation = Convert.ToInt32(myParam(3))
      dateReturned = Convert.ToDateTime(myParam(4))
      referenceNo = Convert.ToString(myParam(5))
      note = Convert.ToString(myParam(6))
      status = Convert.ToString(myParam(7))
      updAsFaulty = Convert.ToBoolean(myParam(8))
      strSerial = Convert.ToString(myParam(9))
      caseid = Convert.ToInt32(myParam(10))
      validateFaultyStock = Convert.ToBoolean(myParam(11))
    End If

    If Not IsTicketValid(ticket, False) Then Return Nothing

    Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

    Dim paraID As SqlParameter
    If validateFaultyStock Then
      ''create stock received batch
      paraID = New SqlParameter("@RetCaseID", SqlDbType.Int, 4)
      paraID.Direction = ParameterDirection.InputOutput
      paraID.Value = 0
    Else
      ''create stock received batch
      paraID = New SqlParameter("@BatchID", SqlDbType.Int, 4)
      paraID.Direction = ParameterDirection.InputOutput
      paraID.Value = pBatchID
    End If
    Try

      ''only this virtual function supports output parameter. (refer SqlHelper for details)
      If validateFaultyStock Then
        spName1 = "spWebValidateStockFaulty"
        ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, spName1,
               New SqlParameter("@UserID", userID),
               New SqlParameter("@BatchID", batchID),
               New SqlParameter("@Serial", strSerial),
               paraID)
      Else

        spName2 = IIf(updAsFaulty, "spWebPutFSPStockFaulty", "spWebPutFSPStockReturned").ToString

        ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, spName2,
               New SqlParameter("@UserID", userID),
               New SqlParameter("@SourceID", "W"),
               paraID,
               New SqlParameter("@FromLocation", fromLocation),
               New SqlParameter("@ToLocation", toLocation),
               New SqlParameter("@DateReturned", dateReturned),
               New SqlParameter("@ReferenceNo", EmptyToNull(referenceNo)),
               New SqlParameter("@Note", EmptyToNull(note)),
               New SqlParameter("@Status", EmptyToNull(status)))

        ''set return value of batchid

      End If
      pBatchID = Convert.ToInt32(paraID.Value)
    Finally
      dbConn.Close()
    End Try

    Return ret


  End Function
    <WebMethod()> _
    Public Function AddFSPStockReturnedLog(ByVal myParam As ArrayList) As Object
    Dim ticket As String
    Dim batchID As Integer
    Dim serial As String
    Dim updAsFaulty As Boolean
    Dim caseID As Integer
    Dim spName As String

    ticket = Convert.ToString(myParam(0))
    batchID = Convert.ToInt32(myParam(1))
    serial = Convert.ToString(myParam(2))
    updAsFaulty = Convert.ToBoolean(myParam(3))
    caseID = Convert.ToInt32(myParam(4))

    If Not IsTicketValid(ticket, False) Then Return Nothing

    Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

    Dim ret As Object

    Try

      spName = IIf(updAsFaulty, "spWebAddStockFaultyLog", "spWebAddFSPStockReturnedLog").ToString

      If updAsFaulty Then
        ret = SqlHelper.ExecuteScalar(dbConn, spName, userID, batchID, serial, caseID)
      Else
        ret = SqlHelper.ExecuteScalar(dbConn, spName, userID, batchID, serial)
      End If


    Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
      ThrowMySoapException(ex.Message, ex.Number)

    Finally
      dbConn.Close()
    End Try

    Return ret
    End Function
  <WebMethod()>
  Public Function CloseFSPStockReturnedAndSendReport(ByVal myParam As ArrayList) As Object
    Dim ticket As String
    Dim batchID As Integer
    Dim NoOfBox As Integer
    Dim referenceNo As String
    Dim updAsFaulty As Boolean
    Dim spName As String
    Dim ret As Object
    Dim sNotes As String

    ticket = Convert.ToString(myParam(0))
    batchID = Convert.ToInt32(myParam(1))
    NoOfBox = Convert.ToInt32(myParam(2))
    referenceNo = Convert.ToString(myParam(3)) 'CAMS-873
    sNotes = Convert.ToString(myParam(4))
    updAsFaulty = Convert.ToBoolean(myParam(5))

    If Not IsTicketValid(ticket, False) Then Return Nothing

    Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

    spName = IIf(updAsFaulty, "spWebCloseFSPStockFaulty", "spWebCloseFSPStockReturnedAndSendReport").ToString

    Try
      If updAsFaulty Then
        ret = SqlHelper.ExecuteScalar(dbConn, spName, userID, batchID, NoOfBox, referenceNo, sNotes) 'CAMS-955
      Else
        ret = SqlHelper.ExecuteScalar(dbConn, spName, userID, batchID, NoOfBox, referenceNo) 'CAMS-873
      End If


    Finally
      dbConn.Close()
    End Try

    Return ret
  End Function


#End Region
#Region "FSP StockTake"
  <WebMethod()> _
    Public Function GetFSPStockTakeLog(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim batchID As Integer
        Dim from As Int16
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))
        from = Convert.ToInt16(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPStockTakeLog", userID, batchID, from)
            ds.Tables(0).TableName = "FSPStockTakeLog"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPStockTakeTarget(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPStockTakeTarget", userID)
            ds.Tables(0).TableName = "FSPStockTakeTarget"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPStockTake(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim batchID As Integer
        Dim status As String
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))
        status = Convert.ToString(myParam(2))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPStockTake", userID, "W", batchID, EmptyToNull(status))
            ds.Tables(0).TableName = "FSPStockTake"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function PutFSPStockTake(ByVal myParam As ArrayList, ByRef pBatchID As Integer) As Object
        Dim ticket As String
        Dim depot As Integer
        Dim stockTakeDate As Date
        Dim note As String
        Dim status As String

        ticket = Convert.ToString(myParam(0))
        depot = Convert.ToInt32(myParam(1))
        stockTakeDate = Convert.ToDateTime(myParam(2))
        note = Convert.ToString(myParam(3))
        status = Convert.ToString(myParam(4))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)


        ''create stock received batch
        Dim paraBatchID As SqlParameter
        paraBatchID = New SqlParameter("@BatchID", SqlDbType.Int, 4)
        paraBatchID.Direction = ParameterDirection.InputOutput
        paraBatchID.Value = pBatchID



        Dim ret As Object
        Try

            ''only this virtual function supports output parameter. (refer SqlHelper for details)
            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebPutFSPStockTake", _
               New SqlParameter("@UserID", userID), _
               New SqlParameter("@SourceID", "W"), _
               paraBatchID, _
               New SqlParameter("@Depot", depot), _
               New SqlParameter("@StockTakeDate", stockTakeDate), _
               New SqlParameter("@Note", EmptyToNull(note)), _
               New SqlParameter("@Status", EmptyToNull(status)))

            ''set return value of batchid
            pBatchID = Convert.ToInt32(paraBatchID.Value)
        Finally
            dbConn.Close()
        End Try

        Return ret


    End Function
    <WebMethod()> _
    Public Function AddFSPStockTakeLog(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim batchID As Integer
        Dim serial As String
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))
        serial = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebAddFSPStockTakeLog", userID, batchID, serial)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function CloseFSPStockTakeAndSendReport(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim batchID As Integer
        ticket = Convert.ToString(myParam(0))
        batchID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebCloseFSPStockTakeAndSendReport", userID, batchID)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function


#End Region
#Region "FSP Faulty Out Of Box"
    <WebMethod()> _
    Public Function AddFaultyOutOfBoxDevice(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim serial As String
        Dim note As String
        ticket = Convert.ToString(myParam(0))
        serial = Convert.ToString(myParam(1))
        note = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ret As Object
        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebAddFaultyOutOfBoxDevice", userID, serial, note)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function

#End Region
#Region "FSP Job Exception"
    <WebMethod()> _
    Public Function GetFSPExceptionList(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim FSPID As String
        Dim from As Int16


        ticket = Convert.ToString(myParam(0))
        FSPID = Convert.ToString(myParam(1))
        from = Convert.ToInt16(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPExceptionList", userID, EmptyToNull(FSPID), from)
            ds.Tables(0).TableName = "FSPExceptionList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetJobExceptionList(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long


        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJobExceptionList", userID, jobID)
            ds.Tables(0).TableName = "JobExceptionList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPEscalateReason(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String


        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPEscalateReason", userID)
            ds.Tables(0).TableName = "FSPEscalateReason"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function EscalateFSPJob(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim escalateReasonId As Int16
        Dim notes As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        escalateReasonId = Convert.ToInt16(myParam(2))
        notes = Convert.ToString(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebEscalateFSPJob", userID, jobID, escalateReasonId, EmptyToNull(notes))
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

    <WebMethod()> _
    Public Function AddFSPJobNote(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim notes As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        notes = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebAddFSPJobNote", userID, jobID, EmptyToNull(notes))
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

    <WebMethod()> _
    Public Function ReassignJobBackToDepot(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim jobID As Long
        Dim notes As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        notes = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebReassignJobBackToDepot", userID, jobID, EmptyToNull(notes))
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
#End Region
#Region "FSP CJF"
    <WebMethod()> _
    Public Function GetFSPCJFPreJob(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String


        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPCJFPreJob", userID)
            ds.Tables(0).TableName = "FSPCJFPreJob"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPCJFJob(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim cjfID As Integer
        ticket = Convert.ToString(myParam(0))
        cjfID = Convert.ToInt32(myParam(1))
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPCJFJob", userID, cjfID)
            ds.Tables(0).TableName = "FSPCJFJob"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GetFSPCJF(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPCJF", userID)
            ds.Tables(0).TableName = "FSPCJF"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function GenerateFSPCJF(ByVal myParam As ArrayList, ByRef pCJFID As Integer) As Object
        Dim ticket As String
        Dim cjfFileName As String
        Dim logIDs As String

        ticket = Convert.ToString(myParam(0))
        cjfFileName = Convert.ToString(myParam(1))
        logIDs = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
        Dim ret As Object

        ''CJFID output parameter
        Dim paraCJFID As SqlParameter
        paraCJFID = New SqlParameter("@CJFID", SqlDbType.Int, 4)
        paraCJFID.Direction = ParameterDirection.InputOutput
        paraCJFID.Value = pCJFID

        Try
            ''only this virtual function supports output parameter in ExecuteScalar
            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebGenerateFSPCJF", _
                    New SqlParameter("@UserID", userID), _
                    New SqlParameter("@CJFFileName", cjfFileName), _
                    New SqlParameter("@LogIDs", logIDs), _
                    paraCJFID)

            ''set output value
            pCJFID = Convert.ToInt32(paraCJFID.Value)

        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try
        Return ret
    End Function
#End Region
#Region "FSP Job Sheet Data"
    <WebMethod()> _
    Public Function GetFSPJobSheetData(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPJobSheetData", userID, jobID)
            ds.Tables(0).TableName = "FSPJobSheet"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "FSP ReAssign Job"
    <WebMethod()> _
    Public Function FSPReAssignJob(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobID As Long
        Dim reassignTo As Integer
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        reassignTo = Convert.ToInt32(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebReAssignJob", userID, jobID, reassignTo)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

    <WebMethod()> _
    Public Function FSPReAssignJobExt(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobIDList As String
        Dim reassignTo As Integer
        ticket = Convert.ToString(myParam(0))
        jobIDList = Convert.ToString(myParam(1))
        reassignTo = Convert.ToInt32(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebReAssignJobExt", userID, jobIDList, reassignTo)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

#End Region
#Region "Admin BulkUpdate"
	<WebMethod()>
	Public Function GetAdminBulkJob(ByVal myParam As ArrayList) As DataSet
		Dim ticket As String
		Dim typeID As Short
		Dim data As String
		ticket = Convert.ToString(myParam(0))
		typeID = Convert.ToInt16(myParam(1))
		data = Convert.ToString(myParam(2))

		If Not IsTicketValid(ticket, False) Then Return Nothing

		Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

		Dim ds As DataSet
		Try
			ds = SqlHelper.ExecuteDataset(dbConn, "spWebAdminBulkJobGet", userID, typeID, data)
			ds.Tables(0).TableName = "BulkJob"
		Finally
			dbConn.Close()
		End Try

		Return ds
	End Function
	<WebMethod()>
	Public Function PutAdminBulkJob(ByVal myParam As ArrayList) As Object
		Dim ret As Object
		Dim ticket As String
		Dim typeID As Short
		Dim data As String
		ticket = Convert.ToString(myParam(0))
		typeID = Convert.ToInt16(myParam(1))
		data = Convert.ToString(myParam(2))

		If Not IsTicketValid(ticket, False) Then Return Nothing

		Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

		Try
			ret = SqlHelper.ExecuteScalar(dbConn, "spWebAdminBulkJobPut", userID, typeID, data)
		Catch ex As SqlException
			ThrowMySoapException(ex.Message, ex.Number)
		Finally
			dbConn.Close()
		End Try

		Return ret

	End Function
#End Region

#Region "FSP Common"
	<WebMethod()> _
    Public Function GetFSPChildrenExt(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPChildrenExt", userID)
            ds.Tables(0).TableName = "FSPChildren"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPFamilyExt(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPFamilyExt", userID)
            ds.Tables(0).TableName = "FSPChildren"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()>
    Public Function GetDownload(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim Seq As String
        Dim CategoryID As String
        Dim ifrom As Int16

        ticket = Convert.ToString(myParam(0))
        Seq = Convert.ToString(myParam(1))
        CategoryID = Convert.ToString(myParam(2))
        ifrom = Convert.ToInt16(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetDownload",
                                            EmptyToNull(Seq),
                                            EmptyToNull(CategoryID),
                                            ifrom,
                                            userID)
            ds.Tables(0).TableName = "Download"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()>
    Public Function PutDownload(ByVal myParam As ArrayList, ByRef pSeq As Int16) As Object
        Dim ticket As String
        Dim ret As Object

        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            Dim Seq As SqlParameter
            Seq = New SqlParameter("@Seq", SqlDbType.Int, 4)
            Seq.Direction = ParameterDirection.InputOutput
            Seq.Value = pSeq

            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebPutDownload",
                                          Seq,
                                          New SqlParameter("@DownloadCategoryID", myParam(1)),
                                          New SqlParameter("@DownloadDescription", myParam(2)),
                                          New SqlParameter("@DownloadURL", myParam(3)),
                                          New SqlParameter("@FileSize", myParam(4)),
                                          New SqlParameter("@DisplayOrder", 1),
                                          New SqlParameter("@IsActive", myParam(5)),
                                          New SqlParameter("@IsAudit", 1),
                                          New SqlParameter("@UserID", userID))

            pSeq = Convert.ToInt16(Seq.Value)
        Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()>
    Public Function GetDownloadsByURL(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim DownloadURL As String

        ticket = Convert.ToString(myParam(0))
        DownloadURL = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetDownloadsByURL",
                                            EmptyToNull(DownloadURL))
            ds.Tables(0).TableName = "Download"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()>
    Public Function GetDownloadCategoryAll(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetDownloadCategoryAll")
            ds.Tables(0).TableName = "DownloadCategory"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetTechFix(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobtype As String
        ticket = Convert.ToString(myParam(0))
        jobtype = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetTechFix", jobtype)
            ds.Tables(0).TableName = "TechFix"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function IsTelstraFSP(ByVal myParam As ArrayList, ByRef pIsTelstraFSP As Boolean) As Object
        Dim ret As Object
        Dim ticket As String
        Dim fspID As Integer
        ticket = Convert.ToString(myParam(0))
        fspID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            Dim paraIsTelstraFSP As SqlParameter
            paraIsTelstraFSP = New SqlParameter("@IsTelstraFSP", SqlDbType.Bit, 1)
            paraIsTelstraFSP.Direction = ParameterDirection.InputOutput
            paraIsTelstraFSP.Value = pIsTelstraFSP

            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebIsTelstraFSP", _
                New SqlParameter("@FSPID", fspID), paraIsTelstraFSP)

            pIsTelstraFSP = Convert.ToBoolean(paraIsTelstraFSP.Value)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function IsLiveDB(ByVal myParam As ArrayList, ByRef pIsLiveDB As Boolean) As Object
        Dim ret As Object
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            Dim paraIsLiveDB As SqlParameter
            paraIsLiveDB = New SqlParameter("@IsLiveDB", SqlDbType.Bit, 1)
            paraIsLiveDB.Direction = ParameterDirection.InputOutput
            paraIsLiveDB.Value = pIsLiveDB

            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebIsLiveDB", paraIsLiveDB)

            pIsLiveDB = Convert.ToBoolean(paraIsLiveDB.Value)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function SetJobAsFSPOnSite(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobID As String
        Dim latitude As String
        Dim longitude As String
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToString(myParam(1))
        latitude = Convert.ToString(myParam(2))
        longitude = Convert.ToString(myParam(3))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebSetJobAsFSPOnSite", userID, jobID, EmptyToNull(latitude), EmptyToNull(longitude))
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function FSPCallMerchant(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobID As String
        Dim phoneNumber As String
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToString(myParam(1))
        phoneNumber = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebFSPCallMerchant", userID, jobID, phoneNumber)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function GetJobFSPDownload(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        Dim iFrom As Int16
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.Toint64(myParam(1))
        iFrom = Convert.ToInt16(myParam(2))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetJobFSPDownload", userID, jobID, iFrom)
            ds.Tables(0).TableName = "JobFSPDownload"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()>
    Public Function GetPostcodeFSPAllocation(ByVal myParam As ArrayList) As String

        Dim ticket As String
        ticket = Convert.ToString(myParam(0))
        Dim postcode As String = Convert.ToString(myParam(1))
        Dim city As String = Convert.ToString(myParam(2))
        Dim clientID As String = Convert.ToString(myParam(3))
        Dim jobTypeID As Int16 = Convert.ToInt16(myParam(4))
        Dim deviceType As String = Convert.ToString(myParam(5))
        Dim requiredDateTime As String = Convert.ToString(myParam(6))

        'dbo.fnGetPostcodeFSPAllocation('3550','BENDIGO','cba',4,'i5100','2013-12-25')

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim ret As String
        Try
            ret = CStr(SqlHelper.ExecuteScalar(dbConn, "spWebGetPostcodeFSPAllocation", postcode, city, clientID, jobTypeID, deviceType, requiredDateTime))
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function

#End Region
#Region "FSP MerchantAcceptance"
    <WebMethod()> _
    Public Function GetMerchantAcceptance(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As Long
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetMerchantAcceptance", jobID, userID)
            ds.Tables(0).TableName = "FSPClosedJobList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "FSP IMSPart Tran"
    <WebMethod()> _
    Public Function GetFSPPartTran(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPPartTran", userID)
            ds.Tables(0).TableName = "FSPPartTran"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function FSPSavePartTranReceived(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim tranIDs As String
        Dim qtyReceiveds As String
        ticket = Convert.ToString(myParam(0))
        tranIDs = Convert.ToString(myParam(1))
        qtyReceiveds = Convert.ToString(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebFSPSavePartTranReceived", userID, tranIDs, qtyReceiveds)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function GetFSPPartInventory(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim mode As Integer
        ticket = Convert.ToString(myParam(0))
        mode = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPPartInventory", userID, mode)
            ds.Tables(0).TableName = "FSPPartInv"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function FSPSavePartInventory(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim partNoList As String
        Dim qtyList As String
        Dim mode As Integer
        ticket = Convert.ToString(myParam(0))
        partNoList = Convert.ToString(myParam(1))
        qtyList = Convert.ToString(myParam(2))
        mode = Convert.ToInt32(myParam(3))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebFSPSavePartInventory", userID, partNoList, qtyList, mode)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

#End Region
#Region "FSP Delegation"
    <WebMethod()> _
    Public Function GetFSPDelegationList(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim from As int16
        Dim fromDate As String


        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        If IsDate(myParam(1).ToString) Then
            fromDate = "20" & myParam(1).ToString.Substring(6, 2) & "-" & myParam(1).ToString.Substring(3, 2) & "-" & myParam(1).ToString.Substring(0, 2)
        Else
            fromDate = ""
        End If
        from = Convert.ToInt16(myParam(2))

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPDelegationList", userID, from, EmptyToNull(fromDate))
            ds.Tables(0).TableName = "FSPDelegationList"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPDelegation(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim logID As Integer
        ticket = Convert.ToString(myParam(0))
        logID = Convert.ToInt32(myParam(1))
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPDelegation", userID, logID)
            ds.Tables(0).TableName = "FSPDelegation"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetFSPDelegationReason(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String


        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPDelegationReason", userID)
            ds.Tables(0).TableName = "FSPDelegationReason"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function PutFSPDelegation(ByVal myParam As ArrayList, ByRef pLogID As Integer) As Object
        Dim ticket As String
        Dim FSP As String
        Dim FromDateTime As DateTime
        Dim ToDateTime As DateTime
        Dim AssignedToFSP As String
        Dim note As String
        Dim reasonID As Int16
        Dim statusID As Int16

        ticket = Convert.ToString(myParam(0))
        FSP = Convert.ToString(myParam(1))
        FromDateTime = Convert.ToDateTime(myParam(2))
        ToDateTime = Convert.ToDateTime(myParam(3))
        AssignedToFSP = Convert.ToString(myParam(4))
        note = Convert.ToString(myParam(5))
        reasonID = Convert.ToInt16(myParam(6))
        statusID = Convert.ToInt16(myParam(7))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
        Dim ret As Object

        ''LogID output parameter
        Dim paraLogID As SqlParameter
        paraLogID = New SqlParameter("@LogID", SqlDbType.Int, 4)
        paraLogID.Direction = ParameterDirection.InputOutput
        paraLogID.Value = pLogID

        Try
            ''only this virtual function supports output parameter in ExecuteScalar
            ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebPutFSPDelegation", _
                    New SqlParameter("@UserID", userID), _
                    New SqlParameter("@FSP", EmptyToNull(FSP)), _
                    New SqlParameter("@FromDate", FromDateTime), _
                    New SqlParameter("@ToDate", ToDateTime), _
                    New SqlParameter("@AssignToFSP", EmptyToNull(AssignedToFSP)), _
     New SqlParameter("@Note", note), _
     New SqlParameter("@ReasonID", reasonID), _
     New SqlParameter("@StatusID", statusID), _
                    paraLogID)

            ''set output value
            pLogID = Convert.ToInt32(paraLogID.Value)

        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try
        Return ret
    End Function
    <WebMethod()> _
    Public Function CancelFSPDelegation(ByVal myParam As ArrayList) As Object
        Dim ticket As String
        Dim logID As Integer

        ticket = Convert.ToString(myParam(0))
        logID = Convert.ToInt32(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
        Dim ret As Object


        Try
            ''only this virtual function supports output parameter in ExecuteScalar
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebCancelFSPDelegation", userID, logID)

        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try
        Return ret
    End Function
    <WebMethod()> _
    Public Function GetFSPCalendar(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim fromDate As String


        ticket = Convert.ToString(myParam(0))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        If IsDate(myParam(1).ToString) Then
            fromDate = "20" & myParam(1).ToString.Substring(6, 2) & "-" & myParam(1).ToString.Substring(3, 2) & "-" & myParam(1).ToString.Substring(0, 2)
        Else
            fromDate = ""
        End If

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetFSPCalendar", userID, EmptyToNull(fromDate))
            ds.Tables(0).TableName = "FSPCalendar"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region
#Region "Bulletin"
    <WebMethod()> _
    Public Function GetBulletin(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim bulletinID As String
        Dim modeID As Int16
        ticket = Convert.ToString(myParam(0))
        bulletinID = Convert.ToString(myParam(1))
        modeID = Convert.ToInt16(myParam(2))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetBulletin", userID, EmptyToNull(bulletinID), modeID)
            ds.Tables(0).TableName = "Bulletin"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function PutBulletin(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim bulletinID As Integer
        Dim title As String
        Dim body As String
        Dim buttonTypeID As Int16
        Dim actionOnDeclined As Int16
        Dim targetTypeID As Int16

        ticket = Convert.ToString(myParam(0))
        bulletinID = Convert.ToInt32(myParam(1))
        title = Convert.ToString(myParam(2))
        body = Convert.ToString(myParam(3))
        buttonTypeID = Convert.ToInt16(myParam(4))
        actionOnDeclined = Convert.ToInt16(myParam(5))
        targetTypeID = Convert.ToInt16(myParam(6))



        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutBulletin", userID, bulletinID, title, body, buttonTypeID, actionOnDeclined, targetTypeID)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function GetBulletinViewLog(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim ifrom As Int16
        ticket = Convert.ToString(myParam(0))
        ifrom = Convert.ToInt16(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetBulletinViewLog", userID, ifrom)
            ds.Tables(0).TableName = "BulletinViewLog"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function PutBulletinViewLog(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim bulletinID As Integer
        Dim actionTakenID As Int16

        ticket = Convert.ToString(myParam(0))
        bulletinID = Convert.ToInt32(myParam(1))
        actionTakenID = Convert.ToInt16(myParam(2))



        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutBulletinViewLog", userID, bulletinID, actionTakenID)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

#End Region

#Region "Site Survey"
    <WebMethod()> _
    Public Function GetSurvey(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As String
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetSurvey", userID, jobID)
            ds.Tables(0).TableName = "Survey"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
    <WebMethod()> _
    Public Function GetSurveyAnswer(ByVal myParam As ArrayList) As DataSet
        Dim ticket As String
        Dim jobID As String
        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetSurveyAnswer", userID, jobID)
            ds.Tables(0).TableName = "Survey"
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function

    <WebMethod()> _
    Public Function PutSurveyAnswer(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobID As Long
        Dim surveyResult As String

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        surveyResult = Convert.ToString(myParam(2))



        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutSurveyAnswer", userID, jobID, surveyResult)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function PutMerchantAcceptance(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobID As Long
        Dim signatureData As Byte()
        Dim printName As String

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        signatureData = CType(myParam(2), Byte())
        printName = Convert.ToString(myParam(3))



        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebPutMerchantAcceptance", userID, jobID, signatureData, printName)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function
    <WebMethod()> _
    Public Function UploadMerchantSignedJobSheet(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim jobID As Long
        Dim jobSheet As Byte()
        Dim contentType As String

        ticket = Convert.ToString(myParam(0))
        jobID = Convert.ToInt64(myParam(1))
        jobSheet = CType(myParam(2), Byte())
        contentType = Convert.ToString(myParam(3))


        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteScalar(dbConn, "spWebUploadMerchantSignedJobSheet", userID, jobID, jobSheet, contentType)
        Catch ex As SqlException
            ThrowMySoapException(ex.Message, ex.Number)
        Finally
            dbConn.Close()
        End Try

        Return ret

    End Function

   <WebMethod()>
   Public Function ValidateJobClosure(ByVal myParam As ArrayList) As Object
      Dim ticket As String
      Dim jobID As Long
      Dim from As Int16

      ticket = Convert.ToString(myParam(0))
      jobID = Convert.ToInt64(myParam(1))
      from = Convert.ToInt16(myParam(2))

      If Not IsTicketValid(ticket, False) Then Return Nothing

      Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

      Dim ret As Object
      Try
         ret = SqlHelper.ExecuteScalar(dbConn, "spWebValidateJobClosure", userID, jobID, from)
      Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
         ret = -1
         ThrowMySoapException(ex.Message, ex.Number)

      Finally
         dbConn.Close()
      End Try

      Return ret
   End Function

#End Region
#Region "Common - ErrorLog"
   <WebMethod()> _
    Public Function PutErrorLog(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim Msg As String
        ticket = Convert.ToString(myParam(0))
        Msg = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteNonQuery(dbConn, "spWebPutErrorLog", userID, Msg)
        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function

#End Region
#Region "Common - ActionLog"
    <WebMethod()> _
    Public Function PutActionLog(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim actionTypeID As Integer
        Dim actionData As String
        ticket = Convert.ToString(myParam(0))
        actionTypeID = Convert.ToInt32(myParam(1))
        actionData = Convert.ToString(myParam(2))

        ''verify if the ticket is validate
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteNonQuery(dbConn, "spWebPutActionLog", actionTypeID, actionData, userID)

        Catch ex As Exception

        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
#End Region
#Region "Session Log"
    <WebMethod()> _
    Public Function PutSessionLog(ByVal myParam As ArrayList) As Object
        Dim ret As Object
        Dim ticket As String
        Dim sessionID As String
        Dim sessionData As String
        ticket = Convert.ToString(myParam(0))
        sessionID = Convert.ToString(myParam(1))
        sessionData = Convert.ToString(myParam(2))

        ''verify if the ticket is validate
        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)

        Try
            ret = SqlHelper.ExecuteNonQuery(dbConn, "spWebPutSessionLog", sessionID, sessionData)

        Catch ex As Exception

        Finally
            dbConn.Close()
        End Try

        Return ret
    End Function
    <WebMethod()> _
    Public Function GetSessionLog(ByVal myParam As ArrayList) As DataSet

        Dim ticket As String
        Dim sessionID As String

        ticket = Convert.ToString(myParam(0))
        sessionID = Convert.ToString(myParam(1))

        If ticket <> "GiveMeSessionPlease" Then Return Nothing

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetSessionLog", sessionID)
        Finally
            dbConn.Close()
        End Try

        Return ds
    End Function
#End Region

#Region "Application Attribute"
    <WebMethod()>
    Public Function GetAppAttribute(ByVal myParam As ArrayList) As Object
        Dim retValue As Object
        Dim ticket As String
        Dim attributeName As String

        ticket = Convert.ToString(myParam(0))
        attributeName = Convert.ToString(myParam(1))

        If Not IsTicketValid(ticket, False) Then Return Nothing

        Dim ds As DataSet
        Try
            ds = SqlHelper.ExecuteDataset(dbConn, "spWebGetControlAttribute", attributeName)
            If (ds IsNot Nothing) Then
                With ds.Tables(0).Rows(0)
                    retValue = .Item("AttrValue").ToString()
                End With
            End If
        Finally
            dbConn.Close()
        End Try


        Return retValue
    End Function

#End Region

#Region "Helper"
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
    Private Function EmptyToNull(ByVal pData As String) As Object
        If pData.Trim = String.Empty Then
            Return DBNull.Value
        Else
            Return pData
        End If
    End Function
    Private Sub ThrowMySoapException(ByVal pMsg As String, ByVal pErrNumber As Long)

        If pErrNumber = -2 Then ''Number: -2 TimeOut
            pMsg += ". Please try again later..."
            Try
                SqlHelper.ExecuteScalar(dbConn, "spRollBackTran")
            Catch ex1 As SqlException
                ''bypass Transaction count after EXECUTE indicates a mismatching number of BEGIN and COMMIT statements. Previous count = 1, current count = 0.
            End Try
        End If

        ' Build the detail element of the SOAP fault.
        Dim doc As New System.Xml.XmlDocument
        Dim node As System.Xml.XmlNode = doc.CreateNode(XmlNodeType.Element, _
            SoapException.DetailElementName.Name, _
            SoapException.DetailElementName.Namespace)

        ''set InnerText = pMsg
        node.InnerText = pMsg

        ' Throw the exception.    
        Dim se As New SoapException("Fault occurred", SoapException.ClientFaultCode, _
                                    Context.Request.Url.AbsoluteUri, node)
        Throw se
        Return
    End Sub

#End Region
#Region "Admin MID Allocation"
	<WebMethod()>
	Public Function LogApplicationAndAssignMID(ByVal myParam As ArrayList, ByRef pMerchantID As String, ByRef pPayMarkID As Int64) As Object
		Dim ticket As String

		Dim countryID As String
		Dim partnerID As String
		Dim accountID As String
		Dim accountType As String
		Dim applicationID As String
		Dim productType As String
		Dim contactName As String
		Dim gSTNumber As String
		Dim tradingName As String
		Dim legalName As String
		Dim descriptionOfBusiness As String
		Dim businessAddress1 As String
		Dim businessAddress2 As String
		Dim businessCity As String
		Dim businessState As String
		Dim businessPostcode As String
		Dim businessCountry As String
		Dim isThePrimaryBusinessFaceToFace As Boolean
		Dim isBillerProvided As Boolean
		Dim annualCardSalesTurnover As String
		Dim averageTicketSize As String
		Dim subMerchantBusinessIdentifier As String
		Dim refundPolicy As String
		Dim cancellationPolicy As String
		Dim deliveryTimeframes As String
		Dim paymentPageSample As String
		Dim receiptSample As String
		Dim businessPhone As String
		Dim privatephone As String
		Dim webAddress As String
		Dim emailAddress As String
		Dim faxNumber As String
		Dim director1Name As String
		Dim director1DOB As String
		Dim director1Address1 As String
		Dim director1Address2 As String
		Dim director1City As String
		Dim director1State As String
		Dim director1Postcode As String
		Dim director1Country As String
		Dim director2Name As String
		Dim director2DOB As String
		Dim director2Address1 As String
		Dim director2Address2 As String
		Dim director2City As String
		Dim director2State As String
		Dim director2Postcode As String
		Dim director2Country As String
		Dim director3Name As String
		Dim director3DOB As String
		Dim director3Address1 As String
		Dim director3Address2 As String
		Dim director3City As String
		Dim director3State As String
		Dim director3Postcode As String
		Dim director3Country As String
		Dim merchantCategoryIndustry As String
		Dim merchantCategoryCode As String
		Dim exportRestrictionsApply As Boolean
		Dim officeID As String
		Dim accountName As String
		Dim settlementAccountNumber As String
		Dim isCreditCheck As Boolean
		Dim isKYCCheck As Boolean
		Dim isSignedSubMerchantAgreement As Boolean
		Dim isWebsiteComplianceCheck As Boolean
		Dim isHighRiskMCCCodeCheck As Boolean
		Dim isPCIComplianceCheck As Boolean



		ticket = Convert.ToString(myParam(0))

		countryID = Convert.ToString(myParam(1))
		partnerID = Convert.ToString(myParam(2))
		accountID = Convert.ToString(myParam(3))
		accountType = Convert.ToString(myParam(4))
		applicationID = Convert.ToString(myParam(5))
		productType = Convert.ToString(myParam(6))
		contactName = Convert.ToString(myParam(7))
		gSTNumber = Convert.ToString(myParam(8))
		tradingName = Convert.ToString(myParam(9))
		legalName = Convert.ToString(myParam(10))
		descriptionOfBusiness = Convert.ToString(myParam(11))
		businessAddress1 = Convert.ToString(myParam(12))
		businessAddress2 = Convert.ToString(myParam(13))
		businessCity = Convert.ToString(myParam(14))
		businessState = Convert.ToString(myParam(15))
		businessPostcode = Convert.ToString(myParam(16))
		businessCountry = Convert.ToString(myParam(17))
		isThePrimaryBusinessFaceToFace = Convert.ToBoolean(myParam(18))
		isBillerProvided = Convert.ToBoolean(myParam(19))
		annualCardSalesTurnover = Convert.ToString(myParam(20))
		averageTicketSize = Convert.ToString(myParam(21))
		subMerchantBusinessIdentifier = Convert.ToString(myParam(22))
		refundPolicy = Convert.ToString(myParam(23))
		cancellationPolicy = Convert.ToString(myParam(24))
		deliveryTimeframes = Convert.ToString(myParam(25))
		paymentPageSample = Convert.ToString(myParam(26))
		receiptSample = Convert.ToString(myParam(27))
		businessPhone = Convert.ToString(myParam(28))
		privatephone = Convert.ToString(myParam(29))
		webAddress = Convert.ToString(myParam(30))
		emailAddress = Convert.ToString(myParam(31))
		faxNumber = Convert.ToString(myParam(32))
		director1Name = Convert.ToString(myParam(33))
		director1DOB = Convert.ToString(myParam(34))
		director1Address1 = Convert.ToString(myParam(35))
		director1Address2 = Convert.ToString(myParam(36))
		director1City = Convert.ToString(myParam(37))
		director1State = Convert.ToString(myParam(38))
		director1Postcode = Convert.ToString(myParam(39))
		director1Country = Convert.ToString(myParam(40))
		director2Name = Convert.ToString(myParam(41))
		director2DOB = Convert.ToString(myParam(42))
		director2Address1 = Convert.ToString(myParam(43))
		director2Address2 = Convert.ToString(myParam(44))
		director2City = Convert.ToString(myParam(45))
		director2State = Convert.ToString(myParam(46))
		director2Postcode = Convert.ToString(myParam(47))
		director2Country = Convert.ToString(myParam(48))
		director3Name = Convert.ToString(myParam(49))
		director3DOB = Convert.ToString(myParam(50))
		director3Address1 = Convert.ToString(myParam(51))
		director3Address2 = Convert.ToString(myParam(52))
		director3City = Convert.ToString(myParam(53))
		director3State = Convert.ToString(myParam(54))
		director3Postcode = Convert.ToString(myParam(55))
		director3Country = Convert.ToString(myParam(56))
		merchantCategoryIndustry = Convert.ToString(myParam(57))
		merchantCategoryCode = Convert.ToString(myParam(58))
		exportRestrictionsApply = Convert.ToBoolean(myParam(59))
		officeID = Convert.ToString(myParam(60))
		accountName = Convert.ToString(myParam(61))
		settlementAccountNumber = Convert.ToString(myParam(62))
		isCreditCheck = Convert.ToBoolean(myParam(63))
		isKYCCheck = Convert.ToBoolean(myParam(64))
		isSignedSubMerchantAgreement = Convert.ToBoolean(myParam(65))
		isWebsiteComplianceCheck = Convert.ToBoolean(myParam(66))
		isHighRiskMCCCodeCheck = Convert.ToBoolean(myParam(67))
		isPCIComplianceCheck = Convert.ToBoolean(myParam(68))



		If Not IsTicketValid(ticket, False) Then Return Nothing

		Dim userID As Integer = CInt(FormsAuthentication.Decrypt(ticket).Name)
		pMerchantID = ""
		Dim paraMerchantID As SqlParameter
		paraMerchantID = New SqlParameter("@MerchantID", SqlDbType.VarChar, 20)
		paraMerchantID.Direction = ParameterDirection.InputOutput
		paraMerchantID.Value = pMerchantID

		Dim paraPayMarkID As SqlParameter
		paraPayMarkID = New SqlParameter("@PayMarkID", SqlDbType.BigInt, 8)
		paraPayMarkID.Direction = ParameterDirection.InputOutput
		paraPayMarkID.Value = pPayMarkID


		Dim ret As Object
		Try

			''only this virtual function supports output parameter. (refer SqlHelper for details)
			ret = SqlHelper.ExecuteScalar(dbConn, CommandType.StoredProcedure, "spWebLogApplicationAndAssignMID",
			   New SqlParameter("@UserID", userID),
			   paraMerchantID,
			   paraPayMarkID,
			   New SqlParameter("@CountryID", countryID),
			   New SqlParameter("@PartnerID", partnerID),
			   New SqlParameter("@AccountID", accountID),
			   New SqlParameter("@AccountType", accountType),
			   New SqlParameter("@ApplicationID", applicationID),
			   New SqlParameter("@ProductType", productType),
			   New SqlParameter("@ContactName", contactName),
			   New SqlParameter("@GSTNumber", EmptyToNull(gSTNumber)),
			   New SqlParameter("@TradingName", tradingName),
			   New SqlParameter("@LegalName", legalName),
			   New SqlParameter("@DescriptionOfBusiness", descriptionOfBusiness),
			   New SqlParameter("@BusinessAddress1", businessAddress1),
			   New SqlParameter("@BusinessAddress2", EmptyToNull(businessAddress2)),
			   New SqlParameter("@BusinessCity", businessCity),
			   New SqlParameter("@BusinessState", businessState),
			   New SqlParameter("@BusinessPostcode", businessPostcode),
			   New SqlParameter("@BusinessCountry", businessCountry),
			   New SqlParameter("@IsThePrimaryBusinessFaceToFace", isThePrimaryBusinessFaceToFace),
			   New SqlParameter("@IsBillerProvided", isBillerProvided),
			   New SqlParameter("@AnnualCardSalesTurnover", EmptyToNull(annualCardSalesTurnover)),
			   New SqlParameter("@AverageTicketSize", EmptyToNull(averageTicketSize)),
			   New SqlParameter("@SubMerchantBusinessIdentifier", EmptyToNull(subMerchantBusinessIdentifier)),
			   New SqlParameter("@RefundPolicy", EmptyToNull(refundPolicy)),
			   New SqlParameter("@CancellationPolicy", EmptyToNull(cancellationPolicy)),
			   New SqlParameter("@DeliveryTimeframes", EmptyToNull(deliveryTimeframes)),
			   New SqlParameter("@PaymentPageSample", EmptyToNull(paymentPageSample)),
			   New SqlParameter("@ReceiptSample", EmptyToNull(receiptSample)),
			   New SqlParameter("@BusinessPhone", businessPhone),
			   New SqlParameter("@Privatephone", EmptyToNull(privatephone)),
			   New SqlParameter("@WebAddress", webAddress),
			   New SqlParameter("@EmailAddress", emailAddress),
			   New SqlParameter("@FaxNumber", EmptyToNull(faxNumber)),
			   New SqlParameter("@Director1Name", director1Name),
			   New SqlParameter("@Director1DOB", director1DOB),
			   New SqlParameter("@Director1Address1", director1Address1),
			   New SqlParameter("@Director1Address2", EmptyToNull(director1Address2)),
			   New SqlParameter("@Director1City", director1City),
			   New SqlParameter("@Director1State", director1State),
			   New SqlParameter("@Director1Postcode", director1Postcode),
			   New SqlParameter("@Director1Country", director1Country),
			   New SqlParameter("@Director2Name", EmptyToNull(director2Name)),
			   New SqlParameter("@Director2DOB", EmptyToNull(director2DOB)),
			   New SqlParameter("@Director2Address1", EmptyToNull(director2Address1)),
			   New SqlParameter("@Director2Address2", EmptyToNull(director2Address2)),
			   New SqlParameter("@Director2City", EmptyToNull(director2City)),
			   New SqlParameter("@Director2State", EmptyToNull(director2State)),
			   New SqlParameter("@Director2Postcode", EmptyToNull(director2Postcode)),
			   New SqlParameter("@Director2Country", EmptyToNull(director2Country)),
			   New SqlParameter("@Director3Name", EmptyToNull(director3Name)),
			   New SqlParameter("@Director3DOB", EmptyToNull(director3DOB)),
			   New SqlParameter("@Director3Address1", EmptyToNull(director3Address1)),
			   New SqlParameter("@Director3Address2", EmptyToNull(director3Address2)),
			   New SqlParameter("@Director3City", EmptyToNull(director3City)),
			   New SqlParameter("@Director3State", EmptyToNull(director3State)),
			   New SqlParameter("@Director3Postcode", EmptyToNull(director3Postcode)),
			   New SqlParameter("@Director3Country", EmptyToNull(director3Country)),
			   New SqlParameter("@MerchantCategoryIndustry", merchantCategoryIndustry),
			   New SqlParameter("@MerchantCategoryCode", merchantCategoryCode),
			   New SqlParameter("@ExportRestrictionsApply", exportRestrictionsApply),
			   New SqlParameter("@OfficeID", officeID),
			   New SqlParameter("@AccountName", accountName),
			   New SqlParameter("@SettlementAccountNumber", settlementAccountNumber),
			   New SqlParameter("@IsCreditCheck", isCreditCheck),
			   New SqlParameter("@IsKYCCheck", isKYCCheck),
			   New SqlParameter("@IsSignedSubMerchantAgreement", isSignedSubMerchantAgreement),
			   New SqlParameter("@IsWebsiteComplianceCheck", isWebsiteComplianceCheck),
			   New SqlParameter("@IsHighRiskMCCCodeCheck", isHighRiskMCCCodeCheck),
			   New SqlParameter("@IsPCIComplianceCheck", isPCIComplianceCheck))

			''set return value
			pPayMarkID = Convert.ToInt64(paraPayMarkID.Value)
			pMerchantID = Convert.ToString(paraMerchantID.Value)

		Catch ex As SqlException  ''only catch sql exception, other exceptions will throw back by default
			ret = -1
			ThrowMySoapException(ex.Message, ex.Number)
		Finally
			dbConn.Close()
		End Try

		Return ret


	End Function
#End Region



End Class
