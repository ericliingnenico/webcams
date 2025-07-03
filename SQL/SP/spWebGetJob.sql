Use WebCAMS
Go

Alter Procedure dbo.spWebGetJob 
	(
		@UserID int,
		@JobID int
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-10-03 09:36:52$-->
--<!--$ModifiedBy: Andrew Falzon <andrew.falzon@bambora.com>$-->
--<!--$Comment: CAMS-761 Add device type to job list and job view screens.$-->
--<!--$Commit$-->
/*
 Purpose: Proxy sp at WebCAMS
*/

 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetJob @UserID = @UserID, @JobID = @JobID
/*
spWebGetJob 1, 158466

spWebGetJob 1,  73468

*/
GO

Grant EXEC on spWebGetJob to eCAMS_Role
Go

Use CAMS
Go

Alter Procedure dbo.spWebGetJob 
	(
		@UserID int,
		@JobID int
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-10-03 09:36:52$-->
--<!--$ModifiedBy: Andrew Falzon <andrew.falzon@bambora.com>$-->
--<!--$Comment: CAMS-761 Add device type to job list and job view screens.$-->
--<!--$Commit$-->
--Purpose: Get IMS Job details for the given jobID. The consumer of this proc is JobView web form in eCAMS. 
--	The jobs are from open and closed jobs.
--16/10/2003: Change SLA to the same logic as in CAMS
--7/05/2007: Display ETA and Despatch Date only when Status
--BOOKED = 9, REF PFS = 10, DESPATCHED= 12, PDA EXCEPTION = 6 or FSP EXCEPTION = 7
--04/01/2011: Show CAIC field

 DECLARE @CRLF varchar(2),
		 @ExtraInfoIDs varchar(400),
		 @ExtraInfoData varchar(4000),
		 @IsCloseableStatusIDs varchar(400)

 SET NOCOUNT ON

 --init
 SELECT @CRLF = char(13) + char(10)

 -- CAMS-844 Add Extra Info details
 SELECT @ExtraInfoIDs = AttrValue FROM CAMS.dbo.tblControl 
 WHERE Attribute = 'WebCAMSJobViewShowExtraInfoIDs'

 -- CAMS-850 Is Job Closeable
 SELECT @IsCloseableStatusIDs = AttrValue FROM CAMS.dbo.tblControl
 WHERE Attribute = 'WebCAMSIsCloseableStatusIDs'

 SELECT @ExtraInfoData = REPLACE((
	SELECT '\n' + ext.ClientID + ' ' + ext.[Type] + ': ' + ex.Notes AS [text()] 
	FROM CAMS.dbo.fnConvertListToTable(@ExtraInfoIDs) c
	INNER JOIN CAMS.dbo.tblJobExtraInfo ex on ex.JobID = @JobID and c.f = ex.TypeID
	INNER JOIN CAMS.dbo.tblJobExtraInfoType ext on ext.TypeID = ex.TypeID
	FOR XML PATH('')
 ), '\n', @CRLF)

 IF EXISTS(SELECT 1 FROM vwIMSJob c WITH (NOLOCK) JOIN WebCams.dbo.tblUserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
			WHERE u.UserID = @UserID
			 	AND JobID = @JobID)
  BEGIN
	 SELECT 'OPEN' AS Source,
		c.JobID,
		dbo.fnGetClientJobType(c.ClientID, c.JobTypeID) as JobType,
		c.JobMethod,
		c.ClientID,
		c.ProblemNumber,
		c.DeviceType,
		c.TerminalID,
		c.MerchantID,

		ISNULL(c.[Name], '') + @CRLF +
		ISNULL(c.Address, '') + ', ' +
		ISNULL(c.City, '') + ' ' +
		ISNULL(c.State, '') + ' ' + ISNULL(c.Postcode, '') + @CRLF +
		ISNULL(c.Contact, '') + ' ph:' + ISNULL(c.PhoneNumber, '') +
		case when isnull(c.MobileNumber,'') <> '' then ',' + c.MobileNumber else '' end +
		ISNULL(@ExtraInfoData, '') + 
		case when c.ClientID = 'NAB' then 
			@CRLF +
			'Bulk Install: ' + (case when c.VipYN = 1 then 'YES' else 'NO' end) + @CRLF +
			'Group Deal Number: ' + ISNULL(c.ProjectNo, '') + @CRLF +
			'Customer Number: ' + ISNULL(c.CustomerNumber, '') + @CRLF +
			'Alt. Merchant ID: ' + ISNULL(c.AltMerchantID, '')
			else ''
		end AS MerchantName,

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
		dbo.fnGetJobNote(c.ClientID, c.Notes, c.ClosedDateTime) as JobNote,
		dbo.fnGetXMLValue(c.Notes, 'WebSpecialInstruction') as SpecialInstruction,
		dbo.fnGetXMLValue(c.Notes, 'TradingHour') as TradingHours,
		dbo.fnCanUpdateJobInfo(c.ClientID,c.JobTypeID) as CanUpdateJobInfo,
		c.CAIC,
		CASE WHEN c.StatusID in (SELECT f FROM dbo.fnConvertListToTable(@IsCloseableStatusIDs)) THEN 1 ELSE 0 END AS IsCloseable

		FROM vwIMSJob c WITH (NOLOCK) JOIN WebCams.dbo.tblUserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
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
		c.DeviceType,
		c.TerminalID,
		c.MerchantID,

		ISNULL(c.[Name], '') + @CRLF +
		ISNULL(c.Address, '') + ', ' +
		ISNULL(c.City, '') + ' ' +
		ISNULL(c.State, '') + ' ' + ISNULL(c.Postcode, '') + @CRLF +
		ISNULL(c.Contact, '') + ' ph:' + ISNULL(c.PhoneNumber, '') +
		case when isnull(c.MobileNumber,'') <> '' then ',' + c.MobileNumber else '' end +
		ISNULL(@ExtraInfoData, '') +
		case when c.ClientID = 'NAB' then 
			@CRLF +
			'Bulk Install: ' + (case when c.VipYN = 1 then 'YES' else 'NO' end) + @CRLF +
			'Group Deal Number: ' + ISNULL(c.ProjectNo, '') + @CRLF +
			'Customer Number: ' + ISNULL(c.CustomerNumber, '') + @CRLF +
			'Alt. Merchant ID: ' + ISNULL(c.AltMerchantID, '')
			else ''
		end AS MerchantName,

		c.StatusNote,
		c.DelayReason,
		c.Fix,
		c.CloseComment,
		dbo.fnFormatDateTimeWD(c.LoggedDateTime) AS LoggedDateTime,
		dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,
		dbo.fnFormatDateTimeWD(c.OnSiteDateTimeLocal) as OnSiteDateTime,
	     	dbo.fnFormatDateTimeWD(c.DueDateTimeLocal) AS SLA,
		c.DueDateTimeOffset,
		tz.TimeZone as SLATimeZone,
		c.OnSiteDateTimeOffset,
		tzOnSite.TimeZone as OnSiteTimeZone,
		tzLog.TimeZone as LoggedTimeZone,
		c.Region,
		dbo.fnGetJobNote(c.ClientID, c.Notes, c.ClosedDateTime) as JobNote,
		dbo.fnGetXMLValue(c.Notes, 'WebSpecialInstruction') as SpecialInstruction,
		dbo.fnGetXMLValue(c.Notes, 'TradingHour') as TradingHours,
		c.CAIC,
		0 as IsCloseable

		FROM vwIMSJobHistory c WITH (NOLOCK) JOIN WebCams.dbo.tblUserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
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

Grant EXEC on spWebGetJob to eCAMS_Role
Go


