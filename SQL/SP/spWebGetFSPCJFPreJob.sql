use CAMS
go

Alter proc spWebGetFSPCJFPreJob (
	@UserID int)
--<!--$$Revision: 29 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/05/15 15:23 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPCJFPreJob.sql $-->
--<!--$$NoKeywords: $-->
as
--Purpose: Get FSP CJF PreJobs
DECLARE @FSPID int
 SET NOCOUNT ON

 SELECT @FSPID = InstallerID
   FROM webCAMS.dbo.tblUser
  WHERE UserID = @UserID

 --cache FSP and its children
 SELECT * INTO #MyLoc
	FROM dbo.fnGetLocationChildrenExt(@FSPID)


 --Cache CJF Pre Job
 SELECT c.LogID,
	c.SourceID,
	c.JobID,
	c.FSPID,
	j.JobTypeID,
	Cast(c.JobID as varchar(50)) as JobRef,
	Cast(j.JobType as varchar(100)) as JobType,
	j.ClientID,
	Cast(j.Fix as varchar(100)) as Fix,
	Cast(j.Name as varchar(100)) as Name,
	Cast(j.City as varchar(100)) as Suburb,
	j.ClosedDateTime,
	j.ProjectNo,
	cast(0 as bit) as Billable,
	Cast(j.MultipleJobID as varchar(11)) as MultipleJobRef,
	cast(j.FSPExtraTimeUnitsReq as int) as ExtraTime,
	--j.FSPQuote as FixPrice,
	cast(j.Fix as varchar(3)) as AfterHour,
	cast(j.Fix as varchar(3)) as Weekend,
	CAST(0 as int) as ExtTermCollected

  INTO #myCJFPreJob
  FROM tblFSPCJFPreJob c JOIN vwFSPBillableIMSJob j ON 1 = 2

 ---Cache IMS Jobs
 INSERT INTO #myCJFPreJob (
	LogID,
	SourceID,
	JobID,
	FSPID,
	JobTypeID,
	JobRef,
	JobType,
	ClientID,
	Fix,
	Name,
	Suburb,
	ClosedDateTime,
	ProjectNo,
	Billable,
	MultipleJobRef,
	ExtraTime,
	--FixPrice,
	AfterHour,
	Weekend,
	ExtTermCollected)
 SELECT c.LogID,
	c.SourceID,
	c.JobID,
	c.FSPID,
	j.JobTypeID,
	j.JobID,
	j.JobType,
	j.ClientID,
	j.Fix,
	j.Name,
	j.City,
	j.ClosedDateTime,
	j.ProjectNo,
	1,
	j.MultipleJobID,
	case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
		else NULL end as ExtraTime,
	--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
	--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
	--	else NULL end as FixPrice,
    case when cce.Ret = 2 then 'Yes' else 'No' end as AfterHour,
	case when cce.Ret = 1 then 'Yes' else 'No' end as Weekend,
	dbo.fnGetExtraTerminalCollected(j.JobID) as ExtTermCollected

   FROM tblFSPCJFPreJob c JOIN #MyLoc l ON c.FSPID = l.Location
			JOIN vwFSPBillableIMSJob j WITH (NOLOCK) ON c.JobID= j.JobID
			cross apply JobCost.dbo.fnGetChargeCategoryExtTVF(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) cce

  WHERE c.SourceID = 1

 ---Cache Calls
 INSERT INTO #myCJFPreJob (
	LogID,
	SourceID,
	JobID,
	FSPID,
	JobTypeID,
	JobRef,
	JobType,
	ClientID,
	Fix,
	Name,
	Suburb,
	ClosedDateTime,
	ProjectNo,
	Billable,
	MultipleJobRef,
	ExtraTime,
	--FixPrice,
	AfterHour,
	Weekend,
	ExtTermCollected )
 SELECT c.LogID,
	c.SourceID,
	c.JobID,
	c.FSPID,
	4,
	j.CallNumber,
	'SWAP',
	j.ClientID,
	j.Fix,
	j.Name,
	j.City,
	j.ClosedDateTime,
	j.ProjectNo,
	1,
	j.MultipleJobID,
	case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
		else NULL end as ExtraTime,
	--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
	--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
	--	else NULL end as FixPrice,
    case when cce.Ret = 2 then 'Yes' else 'No' end as AfterHour,
	case when cce.Ret = 1 then 'Yes' else 'No' end as Weekend,
	0
   FROM tblFSPCJFPreJob c JOIN #MyLoc l ON c.FSPID = l.Location
			JOIN vwFSPBillableCall j WITH (NOLOCK) ON CAST(c.JobID as varchar) = j.CallNumber
			cross apply JobCost.dbo.fnGetChargeCategoryExtTVF(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) cce

  WHERE c.SourceID = 2

 --Cache Task - ims job
 INSERT INTO #myCJFPreJob (
	LogID,
	SourceID,
	JobID,
	FSPID,
	JobRef,
	JobType,
	ClientID,
	Fix,
	Name,
	Suburb,
	ClosedDateTime,
	ProjectNo,
	Billable,
	ExtTermCollected )
 SELECT c.LogID,
	c.SourceID,
	c.JobID,
	c.FSPID,
	CAST(j.JobID as varchar) + '-' + CAST(c.JobID as varchar),
	t.TaskType,
	'' as ClientID, --jb.ClientID,
	ts.TaskStatus,
	'ShipTo:' + cast(j.ToLocation as varchar),
	m.City,
	j.ClosedDateTime,
	'',
	1,
	0
   FROM tblFSPCJFPreJob c JOIN #MyLoc l ON c.FSPID = l.Location
			JOIN tblTask_History j WITH (NOLOCK) ON c.JobID = j.TaskID
			JOIN tblTaskType t WITH (NOLOCK) ON j.TaskTypeID = t.TaskTypeID
			JOIN tblTaskStatus ts  WITH (NOLOCK)ON j.TaskStatusID = ts.TaskStatusID
			LEFT OUTER JOIN Locations_Master m WITH (NOLOCK) ON j.ToLocation = m.Location
  WHERE c.SourceID = 3
 


 --set Billable to 0 for non return device
 UPDATE c
    SET c.Billable = 0
   FROM #myCJFPreJob c JOIN IMS_Job_Equipment_History je WITH (NOLOCK) ON c.JobID = je.JobID
  WHERE c.JobTypeID IN (2,3) --('UPGRADE', 'DEINSTALL')
	AND dbo.fnIsSerialisedDevice(je.Serial) = 1
	AND je.ActionID = 2 --'REMOVE' 
	AND je.StockReturnTypeID = 0
	and je.MMD_ID not in (select MMD_ID from tblStockReturnCheckByPass)  --bypass no value stock

 UPDATE c
    SET c.Billable = 0
  FROM	#myCJFPreJob c JOIN Call_Equipment_History je WITH (NOLOCK) ON CAST(c.JobID as varchar) = je.CallNumber
 WHERE dbo.fnIsSerialisedDevice(je.Serial) = 1
	AND je.StockReturnTypeID = 0
	and je.MMD_ID not in (select MMD_ID from tblStockReturnCheckByPass)  --bypass no value stock

 --return resultset
 SELECT CASE WHEN c.SourceID IN (1, 2) THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(c.JobID as varchar) + ''')">' + c.JobRef + '</A>' 
		ELSE '<A HREF="#" onclick="javascript:popupwindow(''../Member/PopupPropertyGrid.aspx?Case=1&JID=' + CAST(c.JobID as varchar) + ''')">' + c.JobRef + '</A>'
	END as JobRef,
	c.JobType,
	c.ClientID,
	c.Fix,
	c.FSPID,
	c.Name,
	c.ProjectNo,
	c.ClosedDateTime,
	'<INPUT type="checkbox" name="chkBulk" ' + CASE WHEN c.Billable = 0 THEN 'DISABLED = true TITLE = "Unable to include this job until its devices are returned."' ELSE '' END + ' value="' + cast(c.LogID as varchar) + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">' as [Select],
	CASE WHEN c.Billable = 0 THEN '<A HREF="#" TITLE = "View outstanding devices" onclick="javascript:popupwindow(''../Member/PopupGrid.aspx?Case=1&JID=' + cast(c.JobID as varchar) + ''')">View</A>' ELSE '' END as Action,
	c.MultipleJobRef,
	c.ExtraTime,
	--c.FixPrice,
	c.AfterHour,
	c.Weekend,
	c.ExtTermCollected
   FROM #myCJFPreJob c 
/*
exec spWebGetFSPCJFPreJob @UserID = 199649
select * from tblUSer

select * from tblFSPCJFPreJob

*/
Go

grant EXEC on spWebGetFSPCJFPreJob to CallSysUsers, eCAMS_Role
go


use webCAMS
go

Alter proc spWebGetFSPCJFPreJob (
	@UserID int)
as
 EXEC CAMS.dbo.spWebGetFSPCJFPreJob @UserID= @UserID

GO

grant EXEC on spWebGetFSPCJFPreJob to eCAMS_Role
go

