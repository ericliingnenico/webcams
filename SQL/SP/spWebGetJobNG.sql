Use CAMS
Go
if object_id('spWebGetJobNG') is null
	exec ('create procedure dbo.spWebGetJobNG as return 1')
go


Alter Procedure dbo.spWebGetJobNG 
	(
		@UserID int,
		@JobID int
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/09/15 14:09 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobNG.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get IMS Job details for the given jobID. The consumer of this proc is JobView web form in eCAMS. 



 SET NOCOUNT ON
 
 --init
 declare @ret int,
	@TMSURL varchar(1000)
	 
 exec @ret = dbo.spWebIsUserAllowedAPIAccessNG @UserID = @UserID, @MethodID = 5	--1: UpdateJobNote; 2: CloseJob; 3: LogNewJob; 4: GetOpenJobList; 5: GetJob; 6: GetCall
 if @ret <> 0 return @ret

 --verification
 IF EXISTS(SELECT 1 FROM vwIMSJob c WITH (NOLOCK) JOIN UserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
			WHERE u.UserID = @UserID
			 	AND JobID = @JobID)
  BEGIN
	 SELECT 'OPEN' AS Source,
		c.JobID,
		dbo.fnGetClientJobType(c.ClientID, c.JobTypeID) as JobType,
		c.JobMethod,
		c.ClientID,
		c.ProblemNumber, 
		c.TerminalID,
		c.MerchantID,
		c.DeviceType,

		c.[Name], 
		c.Address, 
		c.Address2,
		c.City,
		c.State,
		c.Postcode,
		c.Contact, 
		c.PhoneNumber,
		AlternatePhone = c.MobileNumber,

		dbo.fnFormatDateTimeWD(c.LoggedDateTime) AS LoggedDateTime,
		dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,
		c.Status,
		c.StatusNote,
		c.DelayReason,
		CASE WHEN c.StatusID in (6,7,9,10,12) THEN
		     CASE 
			WHEN c.CurrentETADateTimeLocal IS NOT NULL THEN dbo.fnFormatDateTimeWD(c.CurrentETADateTimeLocal)
			WHEN c.AgentSLADateTimeLocal IS NOT NULL THEN dbo.fnFormatDateTimeWD(c.AgentSLADateTimeLocal)
		     	ELSE dbo.fnFormatDateTimeWD(c.RequiredDateTimeLocal)
		     END
		ELSE
		    NULL
		END AS SLA,
		c.DueDateTimeOffset,
		tz.TimeZone as SLATimeZone,
		CASE WHEN c.StatusID in (6,7,9,10,12) THEN
	     		dbo.fnFormatDateTimeWD(c.PFSDueDateTime)
		ELSE
			NULL
		END AS PFSDueDate,
		tzLog.TimeZone as LoggedTimeZone,
		tzPFS.TimeZone as PFSDueTimeZone,
		c.Region,

		c.OldDeviceType,
		c.OldTerminalID,

		Fix = null,
		CloseComment = null,
		OnSiteDateTime = null,
		OnSiteDateTimeOffset = null,
		OnSiteTimeZone = null,


		c.Notes as JobNote,
		c.SpecInstruct as SpecialInstruction,
		dbo.fnGetXMLValue(c.Notes, 'TradingHour') as TradingHours,
		--dbo.fnCanUpdateJobInfo(c.ClientID,c.JobTypeID) as CanUpdateJobInfo,
		c.CAIC,
		c.BusinessActivity,
		TMSURL = @TMSURL

		FROM vwIMSJob c WITH (NOLOCK) JOIN UserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
			LEFT OUTER JOIN tblTimeZone tz WITH (NOLOCK) ON c.State = tz.State
								AND c.DueDateTimeLocal >= tz.FromDate
								AND c.DueDateTimeLocal <= tz.ToDate
			LEFT OUTER JOIN tblTimeZone tzLog WITH (NOLOCK) ON tzLog.State = 'VIC'  ---EE System time
								AND c.LoggedDateTime >= tzLog.FromDate
								AND c.LoggedDateTime <= tzLog.ToDate
			LEFT OUTER JOIN tblTimeZone tzPFS WITH (NOLOCK) ON tzPFS.State = 'VIC'  ---EE System time
								AND c.PFSDueDateTime >= tzPFS.FromDate
								AND c.PFSDueDateTime <= tzPFS.ToDate

		WHERE u.UserID = @UserID
		 	AND c.JobID = @JobID
  END
 ELSE
  BEGIN
	 SELECT 'CLOSED' AS Source,
		c.JobID,
		dbo.fnGetClientJobType(c.ClientID, c.JobTypeID) as JobType,
		c.JobMethod,
		c.ClientID,
		c.ProblemNumber, 
		c.TerminalID,
		c.MerchantID,
		c.DeviceType,

		c.[Name], 
		c.Address, 
		c.Address2,
		c.City,
		c.State,
		c.Postcode,
		c.Contact, 
		c.PhoneNumber,
		AlternatePhone = c.MobileNumber,

		dbo.fnFormatDateTimeWD(c.LoggedDateTime) AS LoggedDateTime,
		dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,

		c.Status,
		c.StatusNote,
		c.DelayReason,
     	dbo.fnFormatDateTimeWD(c.DueDateTimeLocal) AS SLA,

		c.DueDateTimeOffset,
		tz.TimeZone as SLATimeZone,
		PFSDueDate = null,
		tzLog.TimeZone as LoggedTimeZone,
		PFSDueTimeZone = null,
		c.Region,

		c.OldDeviceType,
		c.OldTerminalID,

		c.Fix,
		c.CloseComment,
		dbo.fnFormatDateTimeWD(c.OnSiteDateTimeLocal) as OnSiteDateTime,
		c.OnSiteDateTimeOffset,
		tzOnSite.TimeZone as OnSiteTimeZone,

		c.Notes as JobNote,
		c.SpecInstruct as SpecialInstruction,
		dbo.fnGetXMLValue(c.Notes, 'TradingHour') as TradingHours,
		c.CAIC,
		c.BusinessActivity,
		TMSURL = @TMSURL

		FROM vwIMSJobHistory c WITH (NOLOCK) JOIN UserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
			LEFT OUTER JOIN tblTimeZone tz WITH (NOLOCK) ON c.State = tz.State
								AND c.DueDateTimeLocal >= tz.FromDate
								AND c.DueDateTimeLocal <= tz.ToDate
			LEFT OUTER JOIN tblTimeZone tzOnSite WITH (NOLOCK) ON c.State = tzOnSite.State
								AND c.OnSiteDateTimeLocal >= tzOnSite.FromDate
								AND c.OnSiteDateTimeLocal <= tzOnSite.ToDate
			LEFT OUTER JOIN tblTimeZone tzLog WITH (NOLOCK) ON tzLog.State = 'VIC'  ---EE System time
								AND c.LoggedDateTime >= tzLog.FromDate
								AND c.LoggedDateTime <= tzLog.ToDate

		WHERE u.UserID = @UserID
		 	AND c.JobID = @JobID
  END



GO

Grant EXEC on spWebGetJobNG to eCAMS_Role
Go


/*
 dbo.spWebGetJobNG 
		@UserID = 210001,
		@JobID = 2102883


 dbo.spWebGetJobNG 
		@UserID = 210000,
		@JobID = 2102907

 */