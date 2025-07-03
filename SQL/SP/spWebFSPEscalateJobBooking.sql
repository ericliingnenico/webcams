
Use CAMS
Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebFSPEscalateJobBooking]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebFSPEscalateJobBooking]
GO

Create Procedure dbo.spWebFSPEscalateJobBooking 
	(
		@UserID int,
		@JobID bigint,
		@EscalateReasonID tinyint,
		@Notes varchar(5000)
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 9:53 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebFSPEscalateJobBooking.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: FSP escalate Job to EE operator via Web

DECLARE @ret int,
	@Location int,
	@JobFSP int,
	@JobExist bit,
	@JobNotes varchar(6000),
	@FSPNotes varchar(6000),
	@STATUS_PDA_EXCEPTION tinyint,
	@FSPOperatorNumber int,
	@JobIDString varchar(11),
	@EscalateReason varchar(50),
	@State varchar(10)


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
	SELECT @JobFSP = AssignedTo,
		@State = State
	  FROM Calls
	 WHERE CallNumber = @JobID


	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

   END
 ELSE
   BEGIN
	SELECT @JobFSP = case when isnull(BookedInstaller, 0) <> 0 then BookedInstaller else ProposedInstaller end,
		@State = State
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
  from tblFSPEscalateJobBookingReason
  where EscalateReasonID = @EscalateReasonID

 select @EscalateReason = ISNULL(@EscalateReason, '')

 --process
 --add escalation info to tblFSPEscalateJobLog
 insert tblFSPEscalateJobBookingLog (
			JobID,
			EscalateReasonID,
			Notes)
	values(
			@JobID,
			@EscalateReasonID,
			@Notes)
 
 --mark job as FSP exception
 --add notes to fsp notes
 SELECT @JobNotes = dbo.fnCRLF() + 'FSP Job Booking Escalation: ' + dbo.fnCRLF() + ' Reason: ' + @EscalateReason + dbo.fnCRLF() + ' Notes: ' +  @Notes  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()
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
	if @EscalateReasonID = 3	--Called and/or Left Messag
	 begin
			update IMS_Jobs
				set StatusID = 11,--called
					DelayReasonID = 3, --@UNABLETOCONTACT,
					NextFollowUpDateTime = dbo.fnDateAddWExt(@State,GETDATE(), 1),
					NextFollowUpDateTimeOffset = 0,
					StatusNote = convert(varchar, getdate(), 103) + ' RANG AND/OR LEFT VOICEMAIL'
			 where JobID = @JobID

	 end
	else
	 begin
		update IMS_Jobs
			set StatusID = @STATUS_PDA_EXCEPTION,
				AllowPDADownload = 0
			where JobID = @JobID
	 end
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


Exit_Handle:
  RETURN @ret
GO

Grant EXEC on spWebFSPEscalateJobBooking to eCAMS_Role
Go

Use WebCAMS
Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebFSPEscalateJobBooking]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebFSPEscalateJobBooking]
GO

Create Procedure dbo.spWebFSPEscalateJobBooking 
	(
		@UserID int,
		@JobIDs varchar(4000),
		@EscalateReasonID tinyint,
		@Notes varchar(5000)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 9:44 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebFSPEscalateJobBooking.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int,
	@JobID bigint

 	SELECT JobID = f into #Job
	 FROM CAMS.dbo.fnConvertListToTable(@JobIDs)

	while exists(select 1 from #Job)
	 begin
		select top 1 @JobID = JobID from #Job

		 exec @ret = Cams.dbo.spWebFSPEscalateJobBooking @UserID = @UserID,
				@JobID = @JobID,
				@EscalateReasonID = @EscalateReasonID,
				@Notes = @Notes

		if @ret <> 0
		 begin
			goto Exit_Handle
		 end

		delete #Job
			where JobID = @JobID

	 end

Exit_Handle:
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret
/*

exec spWebFSPEscalateJobBooking @UserID=199649,@JobIDs='2147419,2147420,2147421,2147422,2147423',@EscalateReasonID=5,@Notes='1 main street'

*/
Go

Grant EXEC on spWebFSPEscalateJobBooking to eCAMS_Role
Go
