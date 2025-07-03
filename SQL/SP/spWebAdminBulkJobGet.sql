Use CAMS
Go

if object_id('spWebAdminBulkJobGet ') is not null
   drop procedure dbo.spWebAdminBulkJobGet 
GO

create Procedure dbo.spWebAdminBulkJobGet  
	(
		@UserID int,
		@ActionID int,
		@Data varchar(4000) = null
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-03-15 14:52:58$-->
--<!--$ModifiedBy: Bo Li <bo.li@bambora.com>$-->
--<!--$Comment: icm-57$-->
---Admin Bulk Update 
--
declare @Action varchar(20)

 select @Action = case when @ActionID = 1 then 'FSPQuote:' 
						when @ActionID = 2 then 'ExtraTimeUnit:' 
						when @ActionID = 3 then 'TerminalCollected:' 
						else  ''
					end

 
 select JobID = cast(f1 as bigint),
		Qty=f2,
		IsActionOK = cast(0 as bit)
  into #tmpJob
 from dbo.fnConvertListToTableWithMultipleField(@Data,',','|')

 update t
	set IsActionOK = case when @ActionID in (1,2) then 1
						when @ActionID in (3) and j.ClientID = 'CBA' and j.JobTypeID in (2) then 1
						else 0 end
	from #tmpJob t join vwFSPBillableIMSJob j on j.JobID = t.JobID

 update t
	set IsActionOK = case when @ActionID in (1,2) then 1
						else 0 end
	from #tmpJob t join vwFSPBillableCall j on j.CallNumber = cast(t.JobID as varchar)


--2. spWebAdminBulkJobGet (@UserID, @ActionID, @Data (,,|,,|)
--	Check if user has tblUserMNodule
--	JobID, ClientID, JobType, DeviceType, BookedInstaller, ViewNote, Bulk (refer to spWebGetFSPAllOpenJob)

 select 
		JobID = cast(j.JobID as bigint),
		[Action] = case when IsActionOK = 1 then @Action + t.Qty else 'InvalidAction' end,
		j.ClientID, 
		j.JobType,
		j.DeviceType,
		FSP = j.BookedInstaller,
		[Name] as MerchantName,
		Fix,
		j.ClosedDateTime,
		--CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN 
		--		'<A HREF="../Member/FSPReAssignJob.aspx?JID=' + cast(j.JobID as varchar) + '">ReAssign</A>  - 
		--		<A HREF="../Member/FSPJob.aspx?JID=' + cast(j.JobID as varchar) + '">Closure</A>'
		--	ELSE ''
		--END 
		--+ case when dbo.fnCanFSPBookJob(@FSPID) = 1 then ' - <A HREF="../Member/FSPBookJob.aspx?JID=' + cast(j.JobID as varchar) + '">Book</A>' else '' end		
		--as [Action],
		'<INPUT type="checkbox" name="chkBulk" value="' + cast(j.JobID as varchar) + '|' + t.Qty + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')" class="clsjobid" jobid="' + cast(j.JobID as varchar) + '"  ' + case when IsActionOK = 1 then 'checked' else '' end +'>' as [Bulk]
	from vwFSPBillableIMSJob j with (nolock) JOIN #tmpJob t ON j.JobID = t.JobID
 union
 select 
		j.CallNumber as JobID,
		[Action] = case when IsActionOK = 1 then @Action + t.Qty else 'Error-Invalid Action' end,
		j.ClientID, 
		'SWAP' as JobType,
		DeviceType = j.CallType,
		FSP = AssignedTo,
		[Name] as MerchantName,
		Fix,
		j.ClosedDateTime,

		--CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN 
		--		'<A HREF="../Member/FSPReAssignJob.aspx?JID=' + j.CallNumber + '">ReAssign</A> -
		--		<A HREF="../Member/FSPJob.aspx?JID=' + j.CallNumber + '">Closure</A>'
		--	ELSE '' 
		--END as [Action],
		'<INPUT type="checkbox" name="chkBulk" value="' + j.CallNumber + + '|' + t.Qty + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')" class="clsjobid" jobid="' + j.CallNumber + '" ' + case when IsActionOK = 1 then 'checked' else '' end +'>' as [Bulk]
	from vwFSPBillableCall j with (nolock)  JOIN #tmpJob t ON j.CallNumber = cast(t.JobID as varchar)
				--left outer join Call_Memos cm with (nolock) on j.CallNumber = cm.CallNumber
	Order by JobID


GO

Grant EXEC on spWebAdminBulkJobGet  to eCAMS_Role
Go

/*
spWebAdminBulkJobGet  199649, 1, '20160705117|8|,20160725104|19|,20160800615|12|,20160801730|11|,20160803885|11|,20160807456|15|,20160809776|21|,20160810602|15|,20160812158|8|,20160812310|9|,2273447|19|,2303868|20|,2303869|20|,2313457|13|,2322676|19|,2323464|19|,2340973|15|,2358149|14|,2371129|19|,2384818|12|,'

*/


Use WebCAMS
Go

if object_id('spWebAdminBulkJobGet ') is not null
   drop procedure dbo.spWebAdminBulkJobGet 
GO

create Procedure dbo.spWebAdminBulkJobGet  
	(
		@UserID int,
		@ActionID int,
		@Data varchar(4000) = null
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAdminBulkJobGet .sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON

  if not exists(select 1 from tblUserModule where UserID = @UserID and ModuleID = 5)
   begin
	raiserror ('Permission denied. Abort.',16,1)
	return 
   end

  
 EXEC Cams.dbo.spWebAdminBulkJobGet  
			@UserID = @UserID, 
			@ActionID = @ActionID, 
			@Data = @Data

/*
select * from webcams.dbo.tblUser

spWebAdminBulkJobGet  199649, 1, '20160705117|8|,20160725104|19|,20160800615|12|,20160801730|11|,20160803885|11|,20160807456|15|,20160809776|21|,20160810602|15|,20160812158|8|,20160812310|9|,2273447|19|,2303868|20|,2303869|20|,2313457|13|,2322676|19|,2323464|19|,2340973|15|,2358149|14|,2371129|19|,2384818|12|,'

*/
Go

Grant EXEC on spWebAdminBulkJobGet  to eCAMS_Role
Go
