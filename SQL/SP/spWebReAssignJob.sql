Use CAMS
Go

Alter Procedure dbo.spWebReAssignJob 
	(
		@UserID int,
		@JobID bigint,
		@ReAssignTo int
	)
	AS
--<!--$$Revision: 24 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/02/14 15:26 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebReAssignJob.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Top level FSP is able to re-assign open job (Install/DeInstall/Upgrade/Swap) to its children
 SET NOCOUNT ON
 DECLARE @ret int,
	@FSPID int,
	@FSPOperatorNumber int,
	@JobFSPID int,
	@IsOK bit,
	@JobNotes varchar(600)
		
 SELECT @ret  = 0,
	@IsOK = 0

 --get installerid
 SELECT @FSPID = InstallerID FROM WebCams.dbo.tblUser Where UserID = @UserID

 SELECT @FSPOperatorNumber = -@FSPID

 select * into #MyFSPFamily
	from dbo.fnGetLocationFamily(@FSPID)

 --not a FSP, return (Warning? Save WebService respond time, just return)
 IF @FSPID IS NULL
  BEGIN
	RAISERROR('The user is not a FSP. Abort.', 16, 1)
	SELECT @ret = -1
	GOTO Exit_Handle
  END

 --Verify if the AssignTo is a child of the FSP
 IF not exists(select 1 from #MyFSPFamily where Location = @ReAssignTo)
  BEGIN
	RAISERROR('The re-assign-to FSP is not member of FSP group. Abort.', 16, 1)
	SELECT @ret = -1
	GOTO Exit_Handle
  END


 --Exame in details for Calls/IMS Jobs
 IF Len(@JobID) = 11
  -- it is a call
  BEGIN
	--the call doesn't exist
	IF NOT EXISTS(SELECT 1 FROM Calls WHERE CallNumber = @JobID)
	 BEGIN
		RAISERROR('Call (%d) does not exist.', 16, 1 , @JobID)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END

	--get current FSP ID of this job
	SELECT 	@JobFSPID = AssignedTo
	  FROM Calls
  	 WHERE CallNumber = @JobID


	--verify the ReAssignTo
	IF @JobFSPID = @ReAssignTo
	  BEGIN
		RAISERROR('The FSPID and re-assign-to FSPID are the same. Abort.', 16, 1)
		SELECT @ret = -1
		GOTO Exit_Handle
	  END

	IF not exists(select 1 from #MyFSPFamily where Location = @JobFSPID)
	  BEGIN
		RAISERROR('The job FSP is not a member of the FSP group. Abort.', 16, 1)
		SELECT @ret = -1
		GOTO Exit_Handle
	  END
  END
 ELSE
  --it is ims jobs
  BEGIN
	--verify if the job exists
	IF NOT EXISTS(SELECT 1 FROM IMS_Jobs WHERE JobID = @JobID)
	 BEGIN
		RAISERROR('Job (%d) does not exist. Abort.', 16, 1, @JobID)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END

	--get job fsp
	SELECT @JobFSPID = BookedInstaller
	  FROM IMS_Jobs
	 WHERE JobID = @JobID

	IF @JobFSPID = @ReAssignTo
	  BEGIN
		RAISERROR('The Job FSPID and re-assign-to FSPID are the same. Abort.', 16, 1)
		SELECT @ret = -1
		GOTO Exit_Handle
	  END
	
	IF not exists(select 1 from #MyFSPFamily where Location = @JobFSPID)
	  BEGIN
		RAISERROR('The job FSP is not a member of the FSP group. Abort.', 16, 1)
		SELECT @ret = -1
		GOTO Exit_Handle
	  END
  END --it is ims job

 --Validation is OK, now it is time to start the transaction
 SET @IsOK = 1

 SELECT @JobNotes = dbo.fnCRLF() + 'Job was reassigned to ' + CAST(@ReAssignTo as varchar) + ' '  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()

 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN

 --Process
 IF Len(@JobID) = 11
  -- it is a call
  BEGIN
	--Update Assign and activate AllowPDADownload
	UPDATE Calls
 	   SET AssignedTo = @ReAssignTo,
		AllowPDADownload = 1
	  WHERE CallNumber = @JobID
	
	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO RollBack_Handle
	
	--append to CallMemo
	EXEC @ret = dbo.spAddNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber
	--append to FaultMemo as well
	EXEC @ret = dbo.spAddFaultNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber
			
  END
 ELSE
  --it is ims jobs
  BEGIN
	UPDATE IMS_Jobs
	   SET BookedInstaller = @ReAssignTo,
		AllowPDADownload = 1
	 WHERE JobID = @JobID
	
	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO RollBack_Handle
		
	--append to Notes
	EXEC @ret = dbo.spAddNotesToIMSJob
			@JobID = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber

	--append to InstallerNotes
	EXEC @ret = dbo.spAddInstallerNotesToIMSJob
			@JobID = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber		
  END

 --log this re-assign action
 INSERT tblFSPReAssignLog (JobID, FromFSPID, ToFSPID, UpdateDateTime, UserID)
	VALUES(@JobID, @JobFSPID, @ReAssignTo, GetDate(), @UserID)

 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN

Exit_Handle:
 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle


GO

Grant EXEC on spWebReAssignJob to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebReAssignJob 
	(
		@UserID int,
		@JobID bigint,
		@ReAssignTo int
	)
	AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 1/06/04 1:36p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebReAssignJob.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/

 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebReAssignJob 
		@UserID =@UserID,
		@JobID = @JobID,
		@ReAssignTo = @ReAssignTo


 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret


/*
Declare @ret int
EXEC @ret =spWebReAssignJob 
		@UserID =199516,
		@JobID = 237832,
		@ReAssignTo = 463
select @ret

select * from webCAMS.dbo.tblUser

*/			
Go

Grant EXEC on spWebReAssignJob to eCAMS_Role
Go
