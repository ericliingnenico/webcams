use CAMS
go

Alter proc spWebGetFSPCJFJob (
	@UserID int,
	@CJFID int)
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/11/12 10:59 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPCJFJob.sql $-->
--<!--$$NoKeywords: $-->
as
--purpose: get FSP CJF job for download
DECLARE @FSPID int


 SET NOCOUNT ON

 SELECT @FSPID = InstallerID
   FROM webCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT cast(j.JobID as varchar) as JobRef,
	LineNote1=ISNULL(j.ClientID, '') + ' ' + ISNULL(j.Region, '') + ' ' + ISNULL(j.JobType, '') + ' ' + ISNULL(j.Fix, ''),
	LineNote2=case when ISNULL(j.MultipleJobID, '') <>'' then 'MultipleJob:' + cast(j.MultipleJobID as varchar)+ ' ' else '' end
		+ case when j.FSPExtraTimeAndQuoteApproved = 1 then case when j.FSPExtraTimeUnitsReq>0 then 'ExtraTimeUnit:'+cast(j.FSPExtraTimeUnitsReq as varchar) + ' ' else '' end	else '' end
	    + case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'AfterHourJob ' else '' end
		+ case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'WeekendJob ' else '' end
		+ case when dbo.fnGetExtraTerminalCollected(j.JobID) > 0 then 'ExtTermCollected:' + CAST(dbo.fnGetExtraTerminalCollected(j.JobID) as varchar) else '' end,
	'$0.00' as InvoiceAmount,
	j.JobType,
	j.ClientID,
	j.Fix,
	c.FSPID as AssignedTo,
	j.Name as MerchantName,
	j.City as Suburb,
	j.Postcode,
	j.ProjectNo,
	j.OnSiteDateTimeLocal as OnSite,
	j.OffSiteDateTimeLocal as OffSite,
	j.AgentSLADateTimeLocal as SLA,
	CASE WHEN j.AgentSLAMet=1 THEN 'Yes' ELSE 'No' END as SLAMet,
	datediff(mi, j.OnSiteDateTime, j.OffSiteDateTime) as Minutes,
	j.ClosedDateTime as Closed,
	j.MultipleJobID,
	case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
		else NULL end as ExtraTime,
	case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		case when j.FSPQuote>0 then j.FSPQuote else NULL end
		else NULL end as FixPrice,
    case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
	case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
	dbo.fnGetExtraTerminalCollected(j.JobID) as ExtTermCollected

   FROM tblFSPCJFJob c JOIN tblFSPCJF f ON c.CJFID = f.CJFID
			JOIN vwIMSJobHistory j WITH (NOLOCK) ON c.JobID = j.JobID
  WHERE c.CJFID = @CJFID
	AND f.FSPID = @FSPID
	AND c.SourceID = 1

 UNION
 SELECT j.CallNumber as JobRef,
	LineNote1=ISNULL(j.ClientID, '') + ' ' + ISNULL(j.Region, '') + ' Swap ' + ISNULL(j.Fix, ''),
	LineNote2=case when ISNULL(j.MultipleJobID, '') <>'' then 'MultipleJob:' + cast(j.MultipleJobID as varchar)+ ' ' else '' end
		+ case when j.FSPExtraTimeAndQuoteApproved = 1 then case when j.FSPExtraTimeUnitsReq>0 then 'ExtraTimeUnit:'+cast(j.FSPExtraTimeUnitsReq as varchar) + ' ' else '' end	else '' end
	    + case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'AfterHourJob ' else '' end
		+ case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'WeekendJob ' else '' end,
	'$0.00' as InvoiceAmount,
	'SWAP' as JobType,
	j.ClientID,
	j.Fix,
	c.FSPID as AssignedTo,
	j.Name as MerchantName,
	j.City as Suburb,
	j.Postcode,
	j.ProjectNo,
	j.OnSiteDateTimeLocal as OnSite,
	j.OffSiteDateTimeLocal as OffSite,
	j.AgentSLADateTimeLocal as SLA,
	CASE WHEN j.AgentSLAMet=1 THEN 'Yes' ELSE 'No' END as SLAMet,
	datediff(mi, j.OnSiteDateTime, j.OffSiteDateTime) as Minutes,
	j.ClosedDateTime as Closed,
	j.MultipleJobID,
	case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
		else NULL end as ExtraTime,
	case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		case when j.FSPQuote>0 then j.FSPQuote else NULL end
		else NULL end as FixPrice,
    case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
	case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
	0 as ExtTermCollected
   FROM tblFSPCJFJob c JOIN tblFSPCJF f ON c.CJFID = f.CJFID
			JOIN vwCallsHistory j WITH (NOLOCK) ON CAST(c.JobID AS Varchar) = j.CallNumber
  WHERE c.CJFID = @CJFID
	AND f.FSPID = @FSPID
	AND c.SourceID = 2

 UNION
 SELECT CAST(j.JobID as varchar) + '-' + CAST(j.TaskID as varchar) as JobRef,
	LineNote1='TASK',
	LineNote2='',
	'$0.00' as InvoiceAmount,
	j.TaskType as JobType,
 	ClientID = CASE WHEN j.SourceID = 1 THEN jb.ClientID ELSE jc.ClientID END,
	j.TaskStatus as Fix,
	c.FSPID as AssignedTo,
	j.ToLocationDesc as MerchantName,
	j.ToLocationCity as Suburb,
	j.ToLocationPostcode as Postcode,
	'' as ProjectNo,
	'' as OnSite,
	'' as OffSite,
	j.DueDateTimeLocal as SLA,
	'' as SLAMet,
	'' as Minutes,
	j.ClosedDateTime as Closed,
	NULL as MultipleJobID,
	NULL as ExtraTime,
	NULL as FixPrice,
	NULL as AfterHour,
	NULL as Weekend,
	0  as ExtTermCollected
   FROM tblFSPCJFJob c JOIN tblFSPCJF f ON c.CJFID = f.CJFID
			JOIN vwTask j WITH (NOLOCK) ON c.JobID = j.TaskID
			LEFT OUTER JOIN vwIMSJob jb WITH (NOLOCK) ON jb.JobID = j.JobID AND j.SourceID = 1
			LEFT OUTER JOIN vwCallsHistory jc WITH (NOLOCK) ON jc.CallNumber  = CAST(j.JobID as varchar) AND j.SourceID = 2
  WHERE c.CJFID = @CJFID
	AND f.FSPID = @FSPID
	AND c.SourceID = 3


 ORDER BY j.ClosedDateTime

/*
 
exec spWebGetFSPCJFJob @UserID = 199649, @CJFID = 1340

select * from tblFSPCJFJob

*/

go

grant exec on spWebGetFSPCJFJob to CALLSYSUSERS, eCAMS_Role
go

use webCAMS
go

alter proc spWebGetFSPCJFJob (
	@UserID int,
	@CJFID int)
as
 
EXEC CAMS.dbo.spWebGetFSPCJFJob @UserID = @UserID, @CJFID = @CJFID
GO

grant exec on spWebGetFSPCJFJob to eCAMS_Role
go
