Use WebCAMS
Go

Alter Procedure dbo.spWebGetCall 
	(
		@UserID int,
		@CallNumber varchar(11)
	)
	AS
--<!--$$Revision: 31 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/01/11 17:31 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetCall.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetCall @UserID = @UserID, @CallNumber = @CallNumber
/*
spWebGetCall 1, '20030306252'
spWebGetCall 1, '1999100057E'
sp_help calls

select * from calls


*/
Go

Grant EXEC on spWebGetCall to eCAMS_Role
Go

Use CAMS
Go

Alter Procedure dbo.spWebGetCall 
	(
		@UserID int,
		@CallNumber varchar(11)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetCall.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get Call details for the given CallNumber. The consumer of this proc is CallView form in eCAMS.
--		The search is cross Open Call and Closed Call. 
--7/05/2007: Display ETA and Despatch Date only when Status
--ASSIGNED = 2, PDA EXCEPTION = 6 or FSP EXCEPTION = 7
--04/01/2011: Show CAIC field

 DECLARE @SMALLDATE smalldatetime,
		@CRLF varchar(2)

 SET NOCOUNT ON

 --init
 SELECT @SMALLDATE = '1970-01-01',
	@CRLF = char(13) + char(10)

 IF EXISTS(SELECT 1 FROM vwCalls c  WITH (NOLOCK) JOIN WebCams.dbo.vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
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
		
		ISNULL(c.[Name], '') + @CRLF +
		ISNULL(c.Address, '') + ', ' +
		ISNULL(c.City, '') + ' ' +
		ISNULL(c.State, '') + ' ' + ISNULL(c.Postcode, '') + @CRLF +
		ISNULL(c.Caller, '') + ' ph:' + ISNULL(CallerPhone, '') AS MerchantName,

		ISNULL(c.CallType, '') as DeviceType,
		ISNULL(c.Fault, '') as Fault,

		dbo.fnFormatDateTimeWD(c.LoggedDateTime) AS LoggedDateTime,
		dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,

		c.Status,
		c.StatusNote,
		c.Region,
		dbo.fnGetJobNote(c.ClientID, cm.CallMemo, c.ClosedDateTime) as JobNote,
		dbo.fnGetXMLValue(cm.CallMemo, 'WebSpecialInstruction') as SpecialInstruction,
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
		dbo.fnGetXMLValue(cm.CallMemo, 'TradingHour') as TradingHours,
		dbo.fnCanUpdateJobInfo(c.ClientID,4) as CanUpdateJobInfo,
		sm.Acq1CAIC as CAIC
		FROM vwCalls c WITH (NOLOCK) JOIN WebCams.dbo.vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
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

		ISNULL(c.[Name], '') + @CRLF +
		ISNULL(c.Address, '') + @CRLF +
		ISNULL(c.City, '') + ' ' +
		ISNULL(c.State, '') + ' ' + ISNULL(c.Postcode, '') AS MerchantName,

		ISNULL(c.CallType, '') as DeviceType,
		ISNULL(c.Fault, '') as Fault,

		dbo.fnFormatDateTimeWD(c.LoggedDateTime) AS LoggedDateTime,
		dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,

		c.StatusNote,
		c.Region,
		dbo.fnGetJobNote(c.ClientID, cm.CallMemo, c.ClosedDateTime) as JobNote,
		dbo.fnGetXMLValue(cm.CallMemo, 'WebSpecialInstruction') as SpecialInstruction,
		dbo.fnGetXMLValue(cm.CallMemo, 'SwapComponent') as SwapComponent,

		dbo.fnFormatDateTimeWD(c.OnSiteDateTimeLocal) as OnSiteDateTime,
		c.Fix,
	    dbo.fnFormatDateTimeWD(c.DueDateTimeLocal) AS SLA,
		c.DueDateTimeOffset,
		tz.TimeZone as SLATimeZone,
		c.OnSiteDateTimeOffset,
		tzOnSite.TimeZone as OnSiteTimeZone,
		tzLog.TimeZone as LoggedTimeZone,
		dbo.fnGetXMLValue(cm.CallMemo, 'TradingHour') as TradingHours,
		sm.Acq1CAIC as CAIC
		FROM vwCallsHistory c WITH (NOLOCK) JOIN WebCams.dbo.vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
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

		WHERE u.UserID = @UserID
		 	AND c.CallNumber = @CallNumber
  END

GO
Grant EXEC on spWebGetCall to eCAMS_Role
Go




