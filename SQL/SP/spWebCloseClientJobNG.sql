Use CAMS
Go
if object_id('spWebCloseClientJobNG') is null
	exec ('create procedure dbo.spWebCloseClientJobNG as return 1')
go

Alter Procedure dbo.spWebCloseClientJobNG 
	(
		@UserID int,
		@JobID bigint,
		@FixID smallint,
		@Notes varchar(250),
		@OnSiteDateTime datetime = null,
		@OffSiteDateTime datetime = null
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Chester $-->
--<!--$$Date: 11/09/15 9:38 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseClientJobNG.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Close Job from Web, @ClosedBy  = - (FSP InstallerID): closed by tech via web
--accenture requires onsite datetime is null, set with the current time if it is null
DECLARE @JobTypeID tinyint,
	@ret int,
	@TerminalID varchar(20),
	@ClientID varchar(3),
	@JobExist bit,
	@JobFSP int,

	--call
	@State varchar(5),
	@JobNotes varchar(500),
	@OperatorNumber int,

	@JobIDString varchar(11),

	@CheckKitParts bit


 SET NOCOUNT ON
 
 --init
 exec @ret = dbo.spWebIsUserAllowedAPIAccessNG @UserID = @UserID, @MethodID = 2	--1: UpdateJobNote; 2: CloseJob; 3: LogNewJob; 4: GetOpenJobList; 5: GetJob; 6: GetCall
 if @ret <> 0 return @ret


 SELECT @JobIDString = CAST(@JobID as varchar(11)),
	@ret = 0
 --validation
 SELECT @OperatorNumber = dbo.fnToggleWebUserID(@UserID)

 --since OnSiteDateTime and OffSiteDateTime can be null, Accenture requirement
 if @OnSiteDateTime is null 
  begin
	select @OnSiteDateTime = dbo.fngetdate(),
			@OffSiteDateTime = dbo.fngetdate()
  end

 --verify onsitedatetime, if it is older/newer than 20 days, log an exception
 IF ABS(DateDiff(d, getdate(), @OnSiteDateTime)) >= 20 
  BEGIN
	RAISERROR('OnSiteDateTime is more than 20 days old. Please contact Keycorp to close this job. Abort', 16, 1)

	SELECT @ret = -1

	GOTO Exit_Handle
  END

 IF  @OnSiteDateTime > @OffSiteDateTime
  BEGIN
	RAISERROR('OnSiteDateTime is later than OffSiteDateTime. Abort', 16, 1)

	SELECT @ret = -1

	GOTO Exit_Handle
  END

 

 IF dbo.fnIsSwapCall(@JobID) = 1  --calls only process
  --Swap Calls
  BEGIN
	--get call info
	SELECT @State = State,
		@JobFSP = AssignedTo,
		@TerminalID = TerminalID,
		@ClientID = ClientID,
		@JobTypeID = 4 --swap
	  FROM Calls
	 WHERE CallNumber = @JobID


	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END


   END
 ELSE
   BEGIN
	SELECT @State = State,
		@JobTypeID = JobTypeID,	
		@JobFSP = BookedInstaller,
		@TerminalID = TerminalID,
		@ClientID = ClientID
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

   END

 --verify the job is belong to this user
 IF NOT EXISTS(SELECT 1 FROM UserClientDeviceType WHERE UserID = @UserID and ClientID = @ClientID)
  BEGIN
	IF @JobExist = 1
	 BEGIN
		RAISERROR('Yo do not have permission to process this job [%s]. Abort', 16, 1, @JobIDString)
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




 --appending notes to jobs
 IF @Notes IS NOT NULL
  BEGIN
	SELECT @JobNotes = @Notes + dbo.fnGetOperatorStamp(@UserID)

	IF dbo.fnIsSwapCall(@JobID) = 1
	 BEGIN
		EXEC dbo.spAddNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobNotes,
			@OperatorName = @OperatorNumber
	 END
	ELSE
	 BEGIN
		EXEC dbo.spAddNotesToIMSJob 
			@JobID = @JobID,
			@NewNotes = @JobNotes,
			@OperatorName = @OperatorNumber
	 END
	
  END

  
 --OK, let's close the job
 IF dbo.fnIsSwapCall(@JobID) = 1
  BEGIN
	--close the call
	EXEC @ret = dbo.spCloseCall 
			@CallNumber = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @OperatorNumber,
			@FixID = @FixID
  
	IF @ret <> 0 
	 BEGIN
		GOTO Exit_Handle
	 END

 END
 ELSE
  BEGIN

	--install job
	IF @JobTypeID = 1 --'INSTALL' 
	 BEGIN
		--close the job
		EXEC @ret = dbo.spCloseIMSInstallJob
			@JobID = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @OperatorNumber,
			@CloseComment = NULL,
			@FixID = @FixID,
			@IsPurgeJob = 1

		IF @ret <> 0
		 BEGIN
			--set onsite/offsite datetime
			GOTO Exit_Handle
		 END
	 END


	IF @JobTypeID = 2 --'DEINSTALL'
	 BEGIN
		--verify the deinstall job

		--close it
		EXEC @ret = dbo.spCloseIMSDeInstallJob
			@JobID = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @OperatorNumber,
			@CloseComment = NULL,
			@FixID = @FixID,
			@IsPurgeJob = 1

		IF @ret <> 0 
		 BEGIN

			--set onsite/offsite datetime
			GOTO Exit_Handle
		 END
	 END
	
	IF @JobTypeID = 3 --'UPGRADE'
	 BEGIN
		--verify the upgrade job

		--close it
		EXEC @ret = dbo.spCloseIMSUpgradeJob
			@JobID = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @OperatorNumber,
			@CloseComment = NULL,
			@FixID = @FixID

		IF @ret <> 0
		 BEGIN

			--set onsite/offsite datetime
			GOTO Exit_Handle

		 END
	 END
  END --ims job

Exit_Handle:
  RETURN @ret
GO

Grant EXEC on spWebCloseClientJobNG to eCAMS_Role
Go

/*

spWebCloseClientJobNG @UserID = 217200,
		@JobID = 20150427657, --20150502809,
		@FixID = 1,
		@Notes = 'test on closure notes',
		@OnSiteDateTime = '2015-08-11 14:30:00',
		@OffSiteDateTime = '2015-08-11 15:00:00'

spWebCloseClientJobNG @UserID = 210001,
		@JobID = 20150427657, --20150502809,
		@FixID = 1,
		@Notes = 'test on closure notes',
		@OnSiteDateTime = '2015-08-11 14:30:00',
		@OffSiteDateTime = '2015-08-11 15:00:00'




*/
Go

Grant EXEC on spWebCloseClientJobNG to eCAMS_Role
Go

