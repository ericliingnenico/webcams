Use CAMS
Go
if object_id('spWebGetCallNG') is null
	exec ('create procedure dbo.spWebGetCallNG as return 1')
go



Alter Procedure dbo.spWebGetCallNG 
	(
		@UserID int,
		@CallNumber varchar(11)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/09/15 14:09 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetCallNG.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get Call details for the given CallNumber. The consumer of this proc is CallView form in eCAMS.

 DECLARE @SMALLDATE smalldatetime,
		@ret int,
		@TMSURL varchar(1000)

 SET NOCOUNT ON

 exec @ret = dbo.spWebIsUserAllowedAPIAccessNG @UserID = @UserID, @MethodID = 6	--1: UpdateJobNote; 2: CloseJob; 3: LogNewJob; 4: GetOpenJobList; 5: GetJob; 6: GetCall
 if @ret <> 0 return @ret

 --init
 SELECT @SMALLDATE = '1970-01-01'

 IF EXISTS(SELECT 1 FROM vwCalls c  WITH (NOLOCK) JOIN vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
			WHERE u.UserID = @UserID
			 	AND CallNumber = @CallNumber)
  BEGIN
	 SELECT 'OPEN' AS Source,
		dbo.fnGetClientJobType(c.ClientID, 4) as JobType,
		c.CallNumber,
		c.ClientID,
		c.ProblemNumber, 
		c.TerminalID,
		c.MerchantID,
		
		c.[Name],
		c.Address,
		c.Address2,
		c.City,
		c.State,
		c.Postcode,
		c.Caller,
		CallerPhone,
		AlternatePhone = st.PhoneNumber2,

		ISNULL(c.CallType, '') as DeviceType,
		ISNULL(c.Fault, '') as Fault,

		dbo.fnFormatDateTimeWD(c.LoggedDateTime) AS LoggedDateTime,
		dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,

		c.Status,
		c.StatusNote,
		c.Region,
		cm.CallMemo as JobNote,
		c.SpecialConditions1 as SpecialInstruction,
		dbo.fnGetXMLValue(cm.CallMemo, 'SwapComponent') as SwapComponent,

		CASE WHEN c.StatusID IN (2,6,7) THEN
		   CASE
			WHEN RequiredDateTimeLocal >= ISNULL(AgentSLADateTimeLocal, @SMALLDATE) AND RequiredDateTimeLocal >= ISNULL(CurrentETADateTimeLocal, @SMALLDATE) THEN dbo.fnFormatDateTimeWD(RequiredDateTimeLocal) 
			WHEN AgentSLADateTimeLocal >= ISNULL(RequiredDateTimeLocal, @SMALLDATE) AND AgentSLADateTimeLocal >= ISNULL(CurrentETADateTimeLocal, @SMALLDATE) THEN dbo.fnFormatDateTimeWD(AgentSLADateTimeLocal)
		  	ELSE dbo.fnFormatDateTimeWD(CurrentETADateTimeLocal) 
		   END
		ELSE
		   NULL
		END AS SLA,
		c.DueDateTimeOffset,
		tz.TimeZone as SLATimeZone,
		tzLog.TimeZone as LoggedTimeZone,

		Fix = null,
		ClosureComment = null,
		OnSiteDateTime = null,
		OnSiteDateTimeOffset = null,
		OnSiteTimeZone = null,

		dbo.fnGetXMLValue(cm.CallMemo, 'TradingHour') as TradingHours,
		--dbo.fnCanUpdateJobInfo(c.ClientID,4) as CanUpdateJobInfo,
		sm.Acq1CAIC as CAIC,
		c.BusinessActivity,
		TMSURL = @TMSURL
		FROM vwCalls c WITH (NOLOCK) JOIN vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
			LEFT OUTER JOIN tblTimeZone tz WITH (NOLOCK) ON c.State = tz.State
								AND c.DueDateTimeLocal >= tz.FromDate
								AND c.DueDateTimeLocal <= tz.ToDate
			LEFT OUTER JOIN tblTimeZone tzLog WITH (NOLOCK) ON tzLog.State = 'VIC'  ---melbourne time
								AND c.LoggedDateTime >= tzLog.FromDate
								AND c.LoggedDateTime <= tzLog.ToDate
			LEFT OUTER JOIN Call_Memos cm WITH (NOLOCK) ON c.CallNumber = cm.CallNumber
			LEFT OUTER JOIN Site_Maintenance sm WITH (NOLOCK) ON c.ClientID = sm.ClientID
							AND c.TerminalID = sm.TerminalID
							AND c.TerminalNumber = sm.TerminalNumber
			LEFT OUTER JOIN Sites st WITH (NOLOCK) ON c.ClientID = st.ClientID
							AND c.TerminalID = st.TerminalID

		WHERE u.UserID = @UserID
		 	AND c.CallNumber = @CallNumber
  END
 ELSE
  BEGIN
	 SELECT 'CLOSED' AS Source,
		dbo.fnGetClientJobType(c.ClientID, 4) as JobType,
		c.CallNumber,
		c.ClientID,
		c.ProblemNumber, 
		c.TerminalID,
		c.MerchantID,

		c.[Name],
		c.Address,
		c.Address2,
		c.City,
		c.State,
		c.Postcode,
		c.Caller,
		CallerPhone,
		AlternatePhone = st.PhoneNumber2,

		ISNULL(c.CallType, '') as DeviceType,
		ISNULL(c.Fault, '') as Fault,

		dbo.fnFormatDateTimeWD(c.LoggedDateTime) AS LoggedDateTime,
		dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,

		c.Status,
		c.StatusNote,
		c.Region,
		cm.CallMemo as JobNote,
		c.SpecialConditions1 as SpecialInstruction,
		dbo.fnGetXMLValue(cm.CallMemo, 'SwapComponent') as SwapComponent,

	    dbo.fnFormatDateTimeWD(c.DueDateTimeLocal) AS SLA,
		c.DueDateTimeOffset,
		tz.TimeZone as SLATimeZone,
		tzLog.TimeZone as LoggedTimeZone,

		c.Fix,
		ClosureComment = sc.Description,
		dbo.fnFormatDateTimeWD(c.OnSiteDateTimeLocal) as OnSiteDateTime,
		c.OnSiteDateTimeOffset,
		tzOnSite.TimeZone as OnSiteTimeZone,

		dbo.fnGetXMLValue(cm.CallMemo, 'TradingHour') as TradingHours,
		sm.Acq1CAIC as CAIC,
		c.BusinessActivity,
		TMSURL = @TMSURL

		FROM vwCallsHistory c WITH (NOLOCK) JOIN vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
			LEFT OUTER JOIN tblTimeZone tz WITH (NOLOCK) ON c.State = tz.State
								AND c.DueDateTimeLocal >= tz.FromDate
								AND c.DueDateTimeLocal <= tz.ToDate

			LEFT OUTER JOIN tblTimeZone tzOnSite WITH (NOLOCK) ON c.State = tzOnSite.State
								AND c.OnSiteDateTimeLocal >= tzOnSite.FromDate
								AND c.OnSiteDateTimeLocal <= tzOnSite.ToDate
			LEFT OUTER JOIN tblTimeZone tzLog WITH (NOLOCK) ON tzLog.State = 'VIC'  ---melbourne time
								AND c.LoggedDateTime >= tzLog.FromDate
								AND c.LoggedDateTime <= tzLog.ToDate
			LEFT OUTER JOIN Call_Memo_History cm WITH (NOLOCK) ON c.CallNumber = cm.CallNumber
			LEFT OUTER JOIN Site_Maintenance sm WITH (NOLOCK) ON c.ClientID = sm.ClientID
							AND c.TerminalID = sm.TerminalID
							AND c.TerminalNumber = sm.TerminalNumber
			LEFT OUTER JOIN Sites st WITH (NOLOCK) ON c.ClientID = st.ClientID
							AND c.TerminalID = st.TerminalID
			LEFT OUTER JOIN tblCloseComment sc with (nolock) on c.CloseCommentID = sc.CloseCommentID

		WHERE u.UserID = @UserID
		 	AND c.CallNumber = @CallNumber
  END

GO

Grant EXEC on spWebGetCallNG to eCAMS_Role
Go

/*
 dbo.spWebGetCallNG 
		@UserID = 210001,
		@CallNumber = '20150417243'

 dbo.spWebGetCallNG 
		@UserID = 210000,
		@CallNumber = '20150501234'


 */


