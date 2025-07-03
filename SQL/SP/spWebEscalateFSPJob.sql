
Use CAMS
Go

Alter Procedure dbo.spWebEscalateFSPJob 
	(
		@UserID int,
		@JobID bigint,
		@EscalateReasonID tinyint,
		@Notes varchar(500)
	)
	AS
--<!--$$Revision: 12 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/01/15 15:11 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebEscalateFSPJob.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: FSP escalate Job to EE operator via Web

DECLARE @ret int,
	@Location int,
	@JobFSP int,
	@JobExist bit,
	@JobNotes varchar(600),
	@FSPNotes varchar(600),
	@STATUS_PDA_EXCEPTION tinyint,
	@FSPOperatorNumber int,
	@JobIDString varchar(11),
	@EscalateReason varchar(50),
	@RemedyEscalationReasonIDs varchar(50),
	@RemedyDeferralReasonIDs varchar(50),
	@RemedyJobStatus varchar(20) = null


 SET NOCOUNT ON


 --init
 SELECT @STATUS_PDA_EXCEPTION = 6, --'PDA EXCEPTION',
	@JobIDString = CAST(@JobID as varchar(11)),
	@ret = 0
	
 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@Location



 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)


 --validation
 if @EscalateReasonID = 0 --Please Select
  begin
	raiserror('Failed to Escalate - Please choose an escalation reason.', 16, 1)
	select @ret = -1
	goto Exit_Handle
  end

 IF dbo.fnIsSwapCall(@JobID) = 1
  --Swap Calls
  BEGIN
	--get call info
	SELECT @JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID


	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

   END
 ELSE
   BEGIN
	SELECT @JobFSP = BookedInstaller
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

   END

 --verify the job is belong to this user
 IF NOT EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
  BEGIN
	IF @JobExist = 1
	 BEGIN
		RAISERROR('Job [%s] is not assigned to FSP (%d) group. Abort', 16, 1, @JobIDString, @Location)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END
	ELSE
	 BEGIN
		RAISERROR('Job [%s] does not exist. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END

  END

 select @EscalateReason = EscalateReason
  from tblFSPEscalateReason
  where EscalateReasonID = @EscalateReasonID

 select @EscalateReason = ISNULL(@EscalateReason, '')

 --process
 --add escalation info to tblFSPEscalateJobLog
 insert tblFSPEscalateJobLog (
			JobID,
			EscalateReasonID,
			Notes)
	values(
			@JobID,
			@EscalateReasonID,
			@Notes)
 
 --mark job as FSP exception
 --add notes to fsp notes
 SELECT @JobNotes = dbo.fnCRLF() + 'FSP Escalation: ' + dbo.fnCRLF() + ' Reason: ' + @EscalateReason + dbo.fnCRLF() + ' Notes: ' +  @Notes  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()
 SELECT @FSPNotes = @JobNotes

 if dbo.fnIsSwapCall(@JobID) = 1
  begin
	update Calls
		set StatusID = @STATUS_PDA_EXCEPTION,
			AllowPDADownload = 0
		where CallNumber = @JobID

	--append to CallMemo
	EXEC @ret = dbo.spAddNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber
	--append to FaultMemo as well
	EXEC @ret = dbo.spAddFaultNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @FSPNotes ,
			@OperatorName = @FSPOperatorNumber
	
  end
 else
  begin
	update IMS_Jobs
		set StatusID = @STATUS_PDA_EXCEPTION,
			AllowPDADownload = 0
		where JobID = @JobID

	--append to Notes
	EXEC @ret = dbo.spAddNotesToIMSJob
			@JobID = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber

	--append to InstallerNotes
	EXEC @ret = dbo.spAddInstallerNotesToIMSJob
			@JobID = @JobID,
			@NewNotes = @FSPNotes ,
			@OperatorName = @FSPOperatorNumber
  end 

 -- SEND REMEDY UPDATE WHEN NECESSARY (CAMS-840)
 select @RemedyEscalationReasonIDs = AttrValue from tblControl where Attribute = 'RemedyEscalationReasonIDs'
 select @RemedyDeferralReasonIDs = AttrValue from tblControl where Attribute = 'RemedyDeferralReasonIDs'

 select @RemedyJobStatus = case 
		when exists (select 1 from dbo.fnConvertListToTable(@RemedyEscalationReasonIDs) where f = @EscalateReasonID) then 'Escalated'
		when exists (select 1 from dbo.fnConvertListToTable(@RemedyDeferralReasonIDs) where f = @EscalateReasonID) then 'Deferred'
	end

 if @RemedyJobStatus is not null
	begin
		exec @ret = spSendRemedyStatusUpdate @JobID = @JobID, @JobStatus = @RemedyJobStatus, @JobStatusReason = @EscalateReason
	end

Exit_Handle:
  RETURN @ret
GO

Grant EXEC on spWebEscalateFSPJob to eCAMS_Role
Go

Use WebCAMS
Go
Alter Procedure dbo.spWebEscalateFSPJob 
	(
		@UserID int,
		@JobID bigint,
		@EscalateReasonID tinyint,
		@Notes varchar(500)
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebEscalateFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebEscalateFSPJob @UserID = @UserID,
		@JobID = @JobID,
		@EscalateReasonID = @EscalateReasonID,
		@Notes = @Notes

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret
/*

spWebEscalateFSPJob @UserID = 199516,
		@JobID = 221895,
		@Notes = 'test'

*/
Go

Grant EXEC on spWebEscalateFSPJob to eCAMS_Role
Go
