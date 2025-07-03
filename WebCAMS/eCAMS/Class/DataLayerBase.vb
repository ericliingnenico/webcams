#Region "vss"
'<!--$$Revision: 5 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 20/02/14 9:19 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/DataLayerBase.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Imports System
Imports System.Data
Imports System.Net
Imports System.Web.Services.Protocols
Imports System.Web.Security
Imports eCAMS.AuthWS
Imports eCAMS.DataWS


Namespace eCAMS

    Public MustInherit Class DataLayerBase
#Region "User Session"
        ' Const SESSION_ISLOGIN As String = "IsLogin"
        Const SESSION_USERINFO As String = "UserInfo"
        Const SESSION_TICKET As String = "MyTicket"
        Const SESSION_ISLIVEDB As String = "IsLiveDB"

        Const SESSION_TICKET_STATE As String = "MyTicketState"

        Const SESSION_SELECTED_CLIENTID_JOB As String = "SelectedCID_Job"
        Const SESSION_SELECTED_CLIENTID_QUICKFIND As String = "SelectedCID_QF"
        Const SESSION_SELECTED_CLIENTID_SITEEQPUIPMENT As String = "SelectedCID_SE"
        Const SESSION_SELECTED_CLIENTID_SITE As String = "SelectedCID_Site"
        Const SESSION_SELECTED_CLIENTID_TERMINALLIST As String = "SelectedCID_T"
        Const SESSION_SELECTED_CLIENTID_DEVICEIST As String = "SelectedCID_DL"

        Const SESSION_SELECTED_STATE_JOB As String = "SelectedState_Job"
        Const SESSION_SELECTED_PAGESIZE As String = "SelectedPageSize"
        Const SESSION_SELECTED_STATUS_JOB As String = "SelectedStatus_Job"


        Const SESSION_SELECTED_JOBTYPE_JOB As String = "SelectedJobType_Job"

        Const SESSION_SELECTED_TERMINALID_QUICKFIND As String = "SelectedTID_QF"
        Const SESSION_SELECTED_TERMINALID_SITEEQUIPMENT As String = "SelectedTID_SE"
        Const SESSION_SELECTED_TERMINALID_SITE As String = "SelectedTID_Site"
        Const SESSION_SELECTED_TERMINALID_TERMINALLIST As String = "SelectedTID_T"

        Const SESSION_SELECTED_SERIAL_DEVICELIST As String = "SelectedSN_DL"

        Const SESSION_SELECTED_MERCHANTID_QUICKFIND As String = "SelectedMID_QF"
        Const SESSION_SELECTED_MERCHANTID_SITE As String = "SelectedMID_Site"

        Const SESSION_SELECTED_PROBLEMNUMBER_QUICKFIND As String = "SelectedPN_QF"
        Const SESSION_SELECTED_JOBID_QUICKFIND As String = "SelectedJobID_QF"

        Const SESSION_SELECTED_MERCHANTNAME_SITE As String = "SelectedMName_Site"
        Const SESSION_SELECTED_MERCHANTSUBURB_SITE As String = "SelectedMSuburb_Site"
        Const SESSION_SELECTED_MERCHANTPOSTCODE_SITE As String = "SelectedMPcod_Site"
        Const SESSION_SELECTED_SCOPE_QUICKFIND As String = "SelectedScope_QF"

        Const SESSION_SELECTED_CUSTOMERNUMBER_QUICKFIND As String = "SelectedCN_QF"

        Const SESSION_SELECTED_FROM_DATE As String = "FromDate"
        Const SESSION_SELECTED_TO_DATE As String = "ToDate"


        Const SESSION_SELECTED_ASSIGNED_TO As String = "AssignedTo"


        Const SESSION_GRID_SORT_ORDER As String = "GridSortOrder"

        Const SESSION_LIST_REFRESH_SECOND As String = "RefreshSecond"

        ''cache small dataset
        Const SESSION_FSP_CHILDREN As String = "FSPChildren"
        Const SESSION_FSP_FAMILY As String = "FSPFamily"
        Const SESSION_STATE As String = "StateDS"
        Const SESSION_STATE_INCLUDE_ALL As String = "StateDSAll"

        Const SESSION_JOB_FILTER_STATUS As String = "JobFilterStatusDS"

        Const SESSION_FSP_SHOW_CLOSURE As String = "FSPShowClosure"
        Const SESSION_FSP_SHOW_EXCEPTION As String = "FSPShowException"

        Const SESSION_FSP_DOWNLOADCAT As String = "FSPDownloadCategory"
        Const SESSION_SELECTED_DOWNLOAD_CATEGORY As String = "SelectedDownloadCategoryID"

        Const SESSION_SELECTED_DUEDATE As String = "SelectedDueDate"
        Const SESSION_SELECTED_NO_DEVICE As String = "SelectedNoDeviceReservedOnly"
        Const SESSION_SELECTED_INCLUDE_CHILD_DEPOT As String = "SelectedIncludeChildDepot"
        Const SESSION_SELECTED_TRANSIT_EE As String = "SelectedTransitToEE"

        Const SESSION_SELECTED_CONDITION As String = "SelectedCondition"
        Const SESSION_SELECTED_MODE As String = "SelectedMode"
        Const SESSION_SELECTED_IDS As String = "SelectedIDs"
        Const SESSION_POPUP_MESSAGE As String = "PopupMsg"
        Const SESSION_MASTER_PAGE As String = "MasterPage"

        Const SESSION_SELECTED_PROJECTNO As String = "SelectedProjectNo"
        Const SESSION_SELECTED_SUBURB As String = "SelectedSuburb"
        Const SESSION_SELECTED_POSTCODE As String = "SelectedPostcode"

        Const SESSION_BULLETIN_MORETOSHOW As String = "BulletinMoreToShow"
        Const SESSION_BULLETIN_LOGOFF_DECLINE As String = "BulletinLogoffOnDecline"

        Const SESSION_PARTS_INVENTORY_MODE As String = "PartsInventoryMode"

        Const SESSION_USER_OTP_INFO As String = "UserOTPInformation"
        Const SESSION_USER_OTP_MAX_RETRY_COUNTER As String = "UserOTPMaxRetryCounter"

        Const SESSION_USER_MFA_FEATURE_PARAMS As String = "ClientMFAFeatureParam"

        Protected Friend Encrypt_Key_Used As String = "$#@!%^7A"


        Public Enum TICKET_STATE
            INVALID
            PENDING_MFA
            VALID
        End Enum


        '-------Methods
        Public Function GetLoginURL() As String
            Dim loginURL As String
            loginURL = "../member/Loginkyc.aspx"

            ''Skin related, KYC skin is used, commented out in case for future branding
            'If Not MyMasterPage Is Nothing Then
            '    Select Case MyMasterPage
            '        Case "EE"
            '            loginURL = "../member/Login.aspx"
            '    End Select
            'End If
            Return loginURL
        End Function

        '----------------------------------------------------------------
        ' Sub Logout:
        '   Logout
        '----------------------------------------------------------------
        Public Sub Logout()
            ''Save LoginURL before clean user's session data
            Dim loginURL As String
            loginURL = GetLoginURL()
            ''Clean user's session data
            Call ClearLoginSession()
            ''Force to Login page
            'Call System.Web.HttpContext.Current.Server.Transfer("../member/Login.aspx")
            Call System.Web.HttpContext.Current.Response.Redirect(loginURL)
        End Sub

        '----------------------------------------------------------------
        ' Sub ClearLoginSession:
        '   Clear Login Session data
        '----------------------------------------------------------------
        Public Sub ClearLoginSession()
            ''Clean user's session data
            Call System.Web.HttpContext.Current.Session.Abandon()
            Call System.Web.HttpContext.Current.Session.Clear()
        End Sub


        '-----Properties




        '----------------------------------------------------------------
        ' Property IsLogin:
        '   Wrapper of SESSION_ISLOGIN
        '----------------------------------------------------------------

        Public ReadOnly Property IsLogin() As Boolean
            Get
                Dim myTicketState As TICKET_STATE = CType(System.Web.HttpContext.Current.Session(SESSION_TICKET_STATE), TICKET_STATE)

                If (myTicketState = TICKET_STATE.VALID) Then
                    Return True
                Else
                    Return False
                End If
            End Get
            'Set(ByVal Value As Boolean)
            '    System.Web.HttpContext.Current.Session(SESSION_ISLOGIN) = Value
            'End Set
        End Property

        '----------------------------------------------------------------
        ' Property UserInfo:
        '   Wrapper of SESSION_USERINFO
        '----------------------------------------------------------------
        Public Property CurrentUserInformation() As UserInformation
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_USERINFO), UserInformation)
            End Get
            Set(ByVal Value As UserInformation)
                System.Web.HttpContext.Current.Session(SESSION_USERINFO) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property m_Ticket: Private property 
        '   Wrapper of SESSION_TICKET
        '----------------------------------------------------------------
        Protected Property m_Ticket() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_TICKET), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_TICKET) = Value
            End Set
        End Property


        Public Property m_TicketState() As TICKET_STATE
            Get
                Dim ticketStat As Integer = CType(System.Web.HttpContext.Current.Session(SESSION_TICKET_STATE), Integer)
                Return CType([Enum].Parse(GetType(TICKET_STATE), ticketStat, True), TICKET_STATE)
            End Get
            Protected Set(ByVal Value As TICKET_STATE)
                System.Web.HttpContext.Current.Session(SESSION_TICKET_STATE) = CInt(Value)
            End Set
        End Property


        '----------------------------------------------------------------
        ' Property IsLiveDB:
        '   Wrapper of SESSION_IsLiveDB
        '----------------------------------------------------------------

        Public Property IsLiveDB() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_ISLIVEDB), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_ISLIVEDB) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedClientIDForJobSearch:
        '   Wrapper of SESSION_SELECTED_CLIENTID_JOB
        '----------------------------------------------------------------
        Public Property SelectedClientIDForJobSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_JOB), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_JOB) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedClientIDForQuickFind:
        '   Wrapper of SESSION_SELECTED_CLIENTID_QUICKFIND
        '----------------------------------------------------------------
        Public Property SelectedClientIDForQuickFind() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_QUICKFIND), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_QUICKFIND) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedClientIDForSiteEquipment:
        '   Wrapper of SESSION_SELECTED_CLIENTID_SITEEQPUIPMENT
        '----------------------------------------------------------------
        Public Property SelectedClientIDForSiteEquipment() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_SITEEQPUIPMENT), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_SITEEQPUIPMENT) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedClientIDForSiteSearch:
        '   Wrapper of SESSION_SELECTED_CLIENTID_SITE
        '----------------------------------------------------------------
        Public Property SelectedClientIDForSiteSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_SITE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_SITE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedClientIDForTerminalSearch:
        '   Wrapper of SESSION_SELECTED_CLIENTID_TERMINALLIST
        '----------------------------------------------------------------
        Public Property SelectedClientIDForTerminalSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_TERMINALLIST), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_TERMINALLIST) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedStateForJobSearch:
        '   Wrapper of SESSION_SELECTED_STATE_JOB
        '----------------------------------------------------------------
        Public Property SelectedStateForJobSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_STATE_JOB), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_STATE_JOB) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedPageSize:
        '   Wrapper of SESSION_SELECTED_PAGESIZE
        '----------------------------------------------------------------
        Public Property SelectedPageSize() As Integer
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_PAGESIZE), Integer)
            End Get
            Set(ByVal Value As Integer)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_PAGESIZE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedJobTypeForJobSearch:
        '   Wrapper of SESSION_SELECTED_JOBTYPE_JOB
        '----------------------------------------------------------------
        Public Property SelectedJobTypeForJobSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_JOBTYPE_JOB), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_JOBTYPE_JOB) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedTerminalIDForQuickFind:
        '   Wrapper of SESSION_SELECTED_TERMINALID_QUICKFIND
        '----------------------------------------------------------------
        Public Property SelectedTerminalIDForQuickFind() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_QUICKFIND), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_QUICKFIND) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedTerminalIDForSiteEquipment:
        '   Wrapper of SESSION_SELECTED_TERMINALID_SITEEQUIPMENT
        '----------------------------------------------------------------
        Public Property SelectedTerminalIDForSiteEquipment() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_SITEEQUIPMENT), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_SITEEQUIPMENT) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedTerminalIDForSiteSearch:
        '   Wrapper of SESSION_SELECTED_TERMINALID_SITE
        '----------------------------------------------------------------
        Public Property SelectedTerminalIDForSiteSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_SITE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_SITE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedTerminalIDForTerminalSearch:
        '   Wrapper of SESSION_SELECTED_TERMINALID_TERMINALLIST
        '----------------------------------------------------------------
        Public Property SelectedTerminalIDForTerminalSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_TERMINALLIST), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_TERMINALID_TERMINALLIST) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedMerchantIDForQuickFind:
        '   Wrapper of SESSION_SELECTED_MERCHANTID_QUICKFIND
        '----------------------------------------------------------------
        Public Property SelectedMerchantIDForQuickFind() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTID_QUICKFIND), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTID_QUICKFIND) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedMerchantIDForSiteSearch:
        '   Wrapper of SESSION_SELECTED_MERCHANTID_SITE
        '----------------------------------------------------------------
        Public Property SelectedMerchantIDForSiteSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTID_SITE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTID_SITE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedProblemNumberForQuickFind:
        '   Wrapper of SESSION_SELECTED_PROBLEMNUMBER_QUICKFIND
        '----------------------------------------------------------------
        Public Property SelectedProblemNumberForQuickFind() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_PROBLEMNUMBER_QUICKFIND), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_PROBLEMNUMBER_QUICKFIND) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedJobIDForQuickFind:
        '   Wrapper of SESSION_SELECTED_JOBID_QUICKFIND
        '----------------------------------------------------------------
        Public Property SelectedJobIDForQuickFind() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_JOBID_QUICKFIND), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_JOBID_QUICKFIND) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedCustomerNumberForQuickFind:
        '   Wrapper of SESSION_SELECTED_CUSTOMERNUMBER_QUICKFIND
        '----------------------------------------------------------------
        Public Property SelectedCustomerNumberForQuickFind() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CUSTOMERNUMBER_QUICKFIND), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CUSTOMERNUMBER_QUICKFIND) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedMerchantNameForSiteSearch:
        '   Wrapper of SESSION_SELECTED_MERCHANTNAME_SITE
        '----------------------------------------------------------------
        Public Property SelectedMerchantNameForSiteSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTNAME_SITE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTNAME_SITE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedMerchantSuburbForSiteSearch:
        '   Wrapper of SESSION_SELECTED_MERCHANTSUBURB_SITE
        '----------------------------------------------------------------
        Public Property SelectedMerchantSuburbForSiteSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTSUBURB_SITE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTSUBURB_SITE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedMerchantPostcodeForSiteSearch:
        '   Wrapper of SESSION_SELECTED_MERCHANTPOSTCODE_SITE
        '----------------------------------------------------------------
        Public Property SelectedMerchantPostcodeForSiteSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTPOSTCODE_SITE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_MERCHANTPOSTCODE_SITE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedScopeForQuickFind:
        '   Wrapper of SESSION_SELECTED_SCOPE_QUICKFIND
        '----------------------------------------------------------------
        Public Property SelectedScopeForQuickFind() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_SCOPE_QUICKFIND), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_SCOPE_QUICKFIND) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedClientIDForDeviceSearch:
        '   Wrapper of SESSION_SELECTED_CLIENTID_SERIALLIST
        '----------------------------------------------------------------
        Public Property SelectedClientIDForDeviceSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_DEVICEIST), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CLIENTID_DEVICEIST) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedSerialForDeviceSearch:
        '   Wrapper of SESSION_SELECTED_SERIAL_SERIALLIST
        '----------------------------------------------------------------
        Public Property SelectedSerialForDeviceSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_SERIAL_DEVICELIST), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_SERIAL_DEVICELIST) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedFromDate:
        '   Wrapper of SESSION_SELECTED_FROM_DATE
        '----------------------------------------------------------------
        Public Property SelectedFromDate() As Date
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_FROM_DATE), Date)
            End Get
            Set(ByVal Value As Date)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_FROM_DATE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedToDate:
        '   Wrapper of SESSION_SELECTED_FROM_DATE
        '----------------------------------------------------------------
        Public Property SelectedToDate() As Date
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_TO_DATE), Date)
            End Get
            Set(ByVal Value As Date)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_TO_DATE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedAssignedTo:
        '   Wrapper of SESSION_SELECTED_ASSIGNED_TO
        '----------------------------------------------------------------
        Public Property SelectedAssignedTo() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_ASSIGNED_TO), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_ASSIGNED_TO) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property FSPChildren:
        '   Wrapper of SESSION_FSP_CHILDREN
        '----------------------------------------------------------------
        Public Property FSPChildren() As DataSet
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_FSP_CHILDREN), DataSet)
            End Get
            Set(ByVal Value As DataSet)
                System.Web.HttpContext.Current.Session(SESSION_FSP_CHILDREN) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property FSPFamily:
        '   Wrapper of SESSION_FSP_FAMILY
        '----------------------------------------------------------------
        Public Property FSPFamily() As DataSet
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_FSP_FAMILY), DataSet)
            End Get
            Set(ByVal Value As DataSet)
                System.Web.HttpContext.Current.Session(SESSION_FSP_FAMILY) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property State:
        '   Wrapper of SESSION_STATE
        '----------------------------------------------------------------
        Public Property State() As DataSet
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_STATE), DataSet)
            End Get
            Set(ByVal Value As DataSet)
                System.Web.HttpContext.Current.Session(SESSION_STATE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property State:
        '   Wrapper of SESSION_STATE_INCLUDE_ALL
        '----------------------------------------------------------------
        Public Property StateWithAll() As DataSet
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_STATE_INCLUDE_ALL), DataSet)
            End Get
            Set(ByVal Value As DataSet)
                System.Web.HttpContext.Current.Session(SESSION_STATE_INCLUDE_ALL) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property JobFilterStatus:
        '   Wrapper of SESSION_JOB_FILTER_STATUS
        '----------------------------------------------------------------
        Public Property JobFilterStatus() As DataSet
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_JOB_FILTER_STATUS), DataSet)
            End Get
            Set(ByVal Value As DataSet)
                System.Web.HttpContext.Current.Session(SESSION_JOB_FILTER_STATUS) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedSortOrder:
        '   Wrapper of SESSION_GRID_SORT_ORDER
        '----------------------------------------------------------------
        Public Property SelectedSortOrder() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_GRID_SORT_ORDER), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_GRID_SORT_ORDER) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedRefreshSecond:
        '   Wrapper of SESSION_LIST_REFRESH_SECOND
        '----------------------------------------------------------------
        Public Property SelectedRefreshSecond() As Int32
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_LIST_REFRESH_SECOND), Int32)
            End Get
            Set(ByVal Value As Int32)
                System.Web.HttpContext.Current.Session(SESSION_LIST_REFRESH_SECOND) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property FSPShowClosure:
        '   Wrapper of SESSION_FSP_SHOW_CLOSURE
        '----------------------------------------------------------------

        Public Property FSPShowClosure() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_FSP_SHOW_CLOSURE), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_FSP_SHOW_CLOSURE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property FSPShowException:
        '   Wrapper of SESSION_FSP_SHOW_CLOSURE
        '----------------------------------------------------------------

        Public Property FSPShowException() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_FSP_SHOW_EXCEPTION), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_FSP_SHOW_EXCEPTION) = Value
            End Set
        End Property


        '----------------------------------------------------------------
        ' Property FSPDownloadCategory:
        '   Wrapper of SESSION_FSP_DOWNLOADCAT
        '----------------------------------------------------------------
        Public Property FSPDownloadCategory() As DataSet
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_FSP_DOWNLOADCAT), DataSet)
            End Get
            Set(ByVal Value As DataSet)
                System.Web.HttpContext.Current.Session(SESSION_FSP_DOWNLOADCAT) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedDownloadCategoryID:
        '   Wrapper of SESSION_SELECTED_DOWNLOAD_CATEGORY
        '----------------------------------------------------------------
        Public Property SelectedDownloadCategoryID() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_DOWNLOAD_CATEGORY), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_DOWNLOAD_CATEGORY) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedDueDate:
        '   Wrapper of SESSION_SELECTED_DUEDATE
        '----------------------------------------------------------------
        Public Property SelectedDueDate() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_DUEDATE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_DUEDATE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedNoDeviceReservedOnly:
        '   Wrapper of SESSION_SELECTED_NO_DEVICE
        '----------------------------------------------------------------
        Public Property SelectedNoDeviceReservedOnly() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_NO_DEVICE), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_NO_DEVICE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedIncludeChildDepot:
        '   Wrapper of SESSION_SELECTED_INCLUDE_CHILD_DEPOT
        '----------------------------------------------------------------
        Public Property SelectedIncludeChildDepot() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_INCLUDE_CHILD_DEPOT), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_INCLUDE_CHILD_DEPOT) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedCondition:
        '   Wrapper of SESSION_SELECTED_CONDITION
        '----------------------------------------------------------------
        Public Property SelectedCondition() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_CONDITION), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_CONDITION) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedTransitToEE:
        '   Wrapper of SESSION_SELECTED_TRANSIT_EE
        '----------------------------------------------------------------
        Public Property SelectedTransitToEE() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_TRANSIT_EE), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_TRANSIT_EE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedMode:
        '   Wrapper of SESSION_SELECTED_MODE
        '----------------------------------------------------------------
        Public Property SelectedMode() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_MODE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_MODE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedIDs:
        '   Wrapper of SESSION_SELECTED_IDS
        '----------------------------------------------------------------
        Public Property SelectedIDs() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_IDS), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_IDS) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property PopupMessage:
        '   Wrapper of SESSION_POPUP_MESSAGE
        '----------------------------------------------------------------
        Public Property PopupMessage() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_POPUP_MESSAGE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_POPUP_MESSAGE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property MyMasterPage:
        '   Wrapper of SESSION_MASTER_PAGE
        '----------------------------------------------------------------
        Public Property MyMasterPage() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_MASTER_PAGE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_MASTER_PAGE) = Value
            End Set
        End Property

        '----------------------------------------------------------------
        ' Property SelectedStatusForJobSearch:
        '   Wrapper of SESSION_SELECTED_STATUS_JOB
        '----------------------------------------------------------------
        Public Property SelectedStatusForJobSearch() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_STATUS_JOB), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_STATUS_JOB) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedProjectNo:
        '   Wrapper of SESSION_SELECTED_PROJECTNO
        '----------------------------------------------------------------
        Public Property SelectedProjectNo() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_PROJECTNO), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_PROJECTNO) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedSuburb:
        '   Wrapper of SESSION_SELECTED_SUBURB
        '----------------------------------------------------------------
        Public Property SelectedSuburb() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_SUBURB), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_SUBURB) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property SelectedPostcode:
        '   Wrapper of SESSION_SELECTED_POSTCODE
        '----------------------------------------------------------------
        Public Property SelectedPostcode() As String
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_SELECTED_POSTCODE), String)
            End Get
            Set(ByVal Value As String)
                System.Web.HttpContext.Current.Session(SESSION_SELECTED_POSTCODE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property BulletinMoreToShow:
        '   Wrapper of SESSION_BULLETIN_MORETOSHOW
        '----------------------------------------------------------------
        Public Property BulletinMoreToShow() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_BULLETIN_MORETOSHOW), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_BULLETIN_MORETOSHOW) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property BulletinLogoffOnDecline:
        '   Wrapper of SESSION_BULLETIN_LOGOFF_DECLINE
        '----------------------------------------------------------------
        Public Property BulletinLogoffOnDecline() As Boolean
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_BULLETIN_LOGOFF_DECLINE), Boolean)
            End Get
            Set(ByVal Value As Boolean)
                System.Web.HttpContext.Current.Session(SESSION_BULLETIN_LOGOFF_DECLINE) = Value
            End Set
        End Property
        '----------------------------------------------------------------
        ' Property PartsInventoryMode:
        '   Wrapper of SESSION_PARTS_INVENTORY_MODE
        '----------------------------------------------------------------
        Public Property PartsInventoryMode() As Integer
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_PARTS_INVENTORY_MODE), Integer)
            End Get
            Set(ByVal Value As Integer)
                System.Web.HttpContext.Current.Session(SESSION_PARTS_INVENTORY_MODE) = Value
            End Set
        End Property

        Public Property CurrentUserOTPInformation() As UserOTPInformation
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_USER_OTP_INFO), UserOTPInformation)
            End Get
            Set(ByVal Value As UserOTPInformation)
                System.Web.HttpContext.Current.Session(SESSION_USER_OTP_INFO) = Value
            End Set
        End Property

        Public Property CurrentUserMFAFeatureParam() As UserMFAFeatureParam
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_USER_MFA_FEATURE_PARAMS), UserMFAFeatureParam)
            End Get
            Set(ByVal Value As UserMFAFeatureParam)
                System.Web.HttpContext.Current.Session(SESSION_USER_MFA_FEATURE_PARAMS) = Value
            End Set
        End Property
        Public Property CurrentUserOTPMaxRetryCounter() As Integer
            Get
                Return CType(System.Web.HttpContext.Current.Session(SESSION_USER_OTP_MAX_RETRY_COUNTER), Integer)
            End Get
            Set(ByVal Value As Integer)
                System.Web.HttpContext.Current.Session(SESSION_USER_OTP_MAX_RETRY_COUNTER) = Value
            End Set
        End Property



#End Region

    End Class

End Namespace
